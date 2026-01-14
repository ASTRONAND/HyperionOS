import asyncio
import struct
import ipaddress
import websockets
import random
import time

SERVER = "ws://localhost:8765"
CLIENT_COUNT = 5000
SEND_INTERVAL = (0.2, 0.5)  # safer backpressure

IP_PACKET_HEADER = "!4s4sI"
HEADER_SIZE = struct.calcsize(IP_PACKET_HEADER)

# Opcodes
OP_IP_REQUEST = 0x01
OP_IP_ASSIGN = 0x02
OP_DATA = 0x10
ASSIGN_OK = 0x00

STATIC_IP_BASE = ipaddress.IPv4Address("10.0.0.10")
assigned_ips: set[bytes] = set()
assigned_ips_lock = asyncio.Lock()


def random_payload(my_ip: bytes) -> bytes:
    return f"hello from {ipaddress.IPv4Address(my_ip)} @ {time.time():.2f}".encode()


async def virtual_node(node_id: int):
    my_ip = None
    try:
        async with websockets.connect(SERVER, max_size=2**20) as ws:
            # -------------------------
            # CONTROL PLANE: IP REQUEST
            # -------------------------
            role = random.random()
            if role < 0.70:
                await ws.send(bytes([OP_IP_REQUEST, 0x00]))
            elif role < 0.90:
                static_ip = (STATIC_IP_BASE + node_id).packed
                await ws.send(bytes([OP_IP_REQUEST, 0x01]) + static_ip)
            elif role < 0.95:
                bad_ip = ipaddress.IPv4Address(random.getrandbits(32)).packed
                await ws.send(bytes([OP_IP_REQUEST, 0x01]) + bad_ip)
            else:
                fake_packet = bytes([OP_DATA]) + b"\x00" * (HEADER_SIZE + 10)
                await ws.send(fake_packet)
                return

            reply = await ws.recv()
            if not isinstance(reply, bytes) or len(reply) != 6:
                return
            if reply[0] != OP_IP_ASSIGN or reply[1] != ASSIGN_OK:
                return

            my_ip = reply[2:6]

            async with assigned_ips_lock:
                assigned_ips.add(my_ip)

            # -------------------------
            # RECEIVER
            # -------------------------
            async def receiver():
                try:
                    async for msg in ws:
                        if not isinstance(msg, bytes):
                            continue
                        if msg[0] != OP_DATA:
                            continue
                        if len(msg) < 1 + HEADER_SIZE:
                            continue
                        src, dst, length = struct.unpack(
                            IP_PACKET_HEADER, msg[1:1 + HEADER_SIZE]
                        )
                        payload = msg[1 + HEADER_SIZE:]
                        if len(payload) != length:
                            continue
                except websockets.ConnectionClosed:
                    pass

            # -------------------------
            # SENDER
            # -------------------------
            async def sender():
                while True:
                    await asyncio.sleep(random.uniform(*SEND_INTERVAL))
                    async with assigned_ips_lock:
                        if not assigned_ips:
                            continue
                        dst = random.choice(list(assigned_ips))
                    if dst == my_ip:
                        continue
                    payload = random_payload(my_ip)
                    packet = (
                        bytes([OP_DATA])
                        + struct.pack(IP_PACKET_HEADER, my_ip, dst, len(payload))
                        + payload
                    )
                    await ws.send(packet)

            await asyncio.gather(receiver(), sender())

    finally:
        async with assigned_ips_lock:
            assigned_ips.discard(my_ip)


async def main():
    print(f"🚀 Starting {CLIENT_COUNT} virtual nodes")
    tasks = [asyncio.create_task(virtual_node(i)) for i in range(CLIENT_COUNT)]
    await asyncio.gather(*tasks)


asyncio.run(main())
