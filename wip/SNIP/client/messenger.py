import asyncio
import struct
import ipaddress
import websockets
import sys

SERVER = "wss://ip.astronand.dev"

OP_IP_REQUEST = 0x01
OP_IP_ASSIGN  = 0x02
OP_DATA       = 0x10
ASSIGN_OK     = 0x00

DATA_HEADER = "!4s4sI"
HEADER_SIZE = struct.calcsize(DATA_HEADER)

servers = {}      # ip -> name
server_ip = "0.0.0.1"
room = "general"

def encode(src, dst, payload: bytes):
    return (
        bytes([OP_DATA]) +
        struct.pack(DATA_HEADER, src, dst, len(payload)) +
        payload
    )

def chat(tp, room, user, data=""):
    return f"CHAT|{tp}|{room}|{user}|{data}".encode()

async def main():
    global server_ip, room

    username = input("Username: ").strip()

    async with websockets.connect(SERVER, max_size=2**20) as ws:
        # DHCP
        await ws.send(b"\x01\x00")
        reply = await ws.recv()
        my_ip = reply[2:6]

        print("Assigned IP:", ipaddress.IPv4Address(my_ip))

        async def receiver():
            async for msg in ws:
                if not isinstance(msg, bytes) or msg[0] != OP_DATA:
                    continue

                src, _, length = struct.unpack(
                    DATA_HEADER, msg[1:1+HEADER_SIZE]
                )
                payload = msg[1+HEADER_SIZE:]
                if len(payload) != length:
                    continue

                text = payload.decode(errors="ignore")
                if not text.startswith("CHAT|"):
                    continue

                _, tp, rm, user, data = text.split("|", 4)

                if tp == "SERVER_HELLO":
                    servers[src] = data
                    print(f"🖥️ Server: {data} @ {ipaddress.IPv4Address(src)}")

                elif tp == "ROOM_LIST":
                    print("📂 Rooms:", data)

                elif tp in ("MSG", "INFO"):
                    print(f"[#{rm}] {user}: {data}")

        async def sender():
            global server_ip
            loop = asyncio.get_event_loop()

            while server_ip is None:
                await asyncio.sleep(1)
                if servers:
                    server_ip = next(iter(servers))

            await ws.send(encode(
                my_ip, server_ip,
                chat("HELLO", "*", username)
            ))
            await ws.send(encode(
                my_ip, server_ip,
                chat("JOIN", room, username)
            ))

            while True:
                line = await loop.run_in_executor(None, sys.stdin.readline)
                line = line.strip()
                if not line:
                    continue

                if line == "/servers":
                    for ip, name in servers.items():
                        print(ipaddress.IPv4Address(ip), name)

                elif line == "/rooms":
                    await ws.send(encode(
                        my_ip, server_ip,
                        chat("ROOM_LIST", "*", username)
                    ))

                elif line.startswith("/join "):
                    room = line.split(" ", 1)[1]
                    await ws.send(encode(
                        my_ip, server_ip,
                        chat("JOIN", room, username)
                    ))

                else:
                    await ws.send(encode(
                        my_ip, server_ip,
                        chat("MSG", room, username, line)
                    ))

        print("Commands: /servers /rooms /join <room>")
        await asyncio.gather(receiver(), sender())

asyncio.run(main())
