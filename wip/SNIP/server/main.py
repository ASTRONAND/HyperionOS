import asyncio
import struct
import ipaddress
import websockets

HOST = "0.0.0.0"
PORT = 8765
ENABLE_PACKET_LOGGING = True
ENABLE_IP_INFO_LOGGING = True

NETWORK = ipaddress.IPv4Network("0.0.0.0/0")
STATIC_IPS: set[int] = set()

clients: dict[int, websockets.WebSocketServerProtocol] = {}
leases: dict[websockets.WebSocketServerProtocol, int] = {}

clients_lock = asyncio.Lock()
leases_lock = asyncio.Lock()

DATA_HEADER = "!4s4sI"
DATA_HEADER_SIZE = struct.calcsize(DATA_HEADER)

NET_START = int(NETWORK.network_address) + 1
NET_END = int(NETWORK.broadcast_address) - 1


def int_to_bytes(ip: int) -> bytes:
    return ip.to_bytes(4, "big")


def bytes_to_int(b: bytes) -> int:
    return int.from_bytes(b, "big")


def allocate_dhcp_ip() -> int | None:
    """Lazy allocation of first free IP."""
    for ip in range(NET_START, NET_END + 1):
        if ip not in clients and ip not in STATIC_IPS:
            return ip
    return None


async def safe_send(ws: websockets.WebSocketServerProtocol, msg: bytes):
    """Fire-and-forget safe send with cleanup."""
    try:
        await ws.send(msg)
    except websockets.ConnectionClosed:
        async with leases_lock:
            ip = leases.pop(ws, None)
        if ip is not None:
            async with clients_lock:
                clients.pop(ip, None)
            if ENABLE_IP_INFO_LOGGING:
                print(f"Released {ipaddress.IPv4Address(ip)} (peer closed)")

async def debug():
    while True:
        print(len(clients))
        await asyncio.sleep(1)

async def handle_websocket(ws: websockets.WebSocketServerProtocol):
    try:
        async for msg in ws:
            if not msg:
                continue

            if not isinstance(msg, bytes):
                msg = msg.encode()

            opcode = msg[0]

            # --------------------
            # IP REQUEST
            # --------------------
            if opcode == 0x01:
                async with leases_lock:
                    if ws in leases:
                        continue

                flags = msg[1]
                static = False

                if flags == 0x00:  # DHCP
                    ip = allocate_dhcp_ip()
                    if ip is None:
                        await ws.send(b"\x02\x02\x00\x00\x00\x00")
                        continue

                elif flags == 0x01 and len(msg) == 6:
                    requested = bytes_to_int(msg[2:6])
                    if requested not in STATIC_IPS:
                        await ws.send(b"\x02\x01\x00\x00\x00\x00")
                        continue
                    async with clients_lock:
                        if requested in clients:
                            await ws.send(b"\x02\x01\x00\x00\x00\x00")
                            continue
                    ip = requested
                    static = True
                else:
                    continue

                async with leases_lock:
                    leases[ws] = ip
                async with clients_lock:
                    clients[ip] = ws

                await ws.send(b"\x02\x00" + int_to_bytes(ip))
                label = "static" if static else "dynamic"
                if ENABLE_IP_INFO_LOGGING:
                    print(f"Assigned {label} {ipaddress.IPv4Address(ip)}")

            # --------------------
            # DATA PLANE
            # --------------------
            elif opcode == 0x10:
                async with leases_lock:
                    if ws not in leases:
                        continue

                if len(msg) < 1 + DATA_HEADER_SIZE:
                    continue

                try:
                    src_b, dst_b, length = struct.unpack(
                        DATA_HEADER, msg[1:1 + DATA_HEADER_SIZE]
                    )
                except struct.error:
                    continue

                payload = msg[1 + DATA_HEADER_SIZE:]
                if len(payload) != length:
                    continue

                src = bytes_to_int(src_b)
                dst = bytes_to_int(dst_b)

                if ENABLE_PACKET_LOGGING:
                    print(f"{ipaddress.IPv4Address(src)} > {ipaddress.IPv4Address(dst)}: {payload}")

                async with clients_lock:
                    receiver = clients.get(dst)
                if receiver:
                    # Fire-and-forget send
                    asyncio.create_task(safe_send(receiver, msg))

    except websockets.ConnectionClosed:
        pass

    finally:
        async with leases_lock:
            ip = leases.pop(ws, None)
        if ip is not None:
            async with clients_lock:
                clients.pop(ip, None)
            if ENABLE_IP_INFO_LOGGING:
                print(f"Released {ipaddress.IPv4Address(ip)}")


async def main():
    async with websockets.serve(handle_websocket, HOST, PORT, max_size=2**20, max_queue=65535):
        print(f"IPoW router listening on {PORT}")
        await asyncio.Future()


if __name__ == "__main__":
    asyncio.run(main())
