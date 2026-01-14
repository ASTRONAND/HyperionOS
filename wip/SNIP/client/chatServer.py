import asyncio
import struct
import ipaddress
import websockets
import time

SERVER = "wss://ip.astronand.dev"
SERVER_NAME = "alpha"

OP_IP_REQUEST = 0x01
OP_IP_ASSIGN  = 0x02
OP_DATA       = 0x10
ASSIGN_OK     = 0x00

DATA_HEADER = "!4s4sI"
HEADER_SIZE = struct.calcsize(DATA_HEADER)

clients = {}          # ip -> username
rooms = {}            # room -> set(ip)
federated_servers = set()

def encode(src, dst, payload: bytes):
    return (
        bytes([OP_DATA]) +
        struct.pack(DATA_HEADER, src, dst, len(payload)) +
        payload
    )

def chat(tp, room, user, data=""):
    return f"CHAT|{tp}|{room}|{user}|{data}".encode()

async def main():
    async with websockets.connect(SERVER, max_size=2**20) as ws:
        # DHCP
        await ws.send(b"\x01\x00")
        reply = await ws.recv()
        my_ip = reply[2:6]

        print("🖥️ Chat server IP:", ipaddress.IPv4Address(my_ip))

        async def announce():
            while True:
                await ws.send(
                    encode(my_ip, my_ip,
                        chat("SERVER_HELLO", "*", "server", SERVER_NAME)
                    )
                )
                await asyncio.sleep(5)

        async def handler():
            async for msg in ws:
                if not isinstance(msg, bytes) or msg[0] != OP_DATA:
                    continue

                src, _, length = struct.unpack(
                    DATA_HEADER, msg[1:1+HEADER_SIZE]
                )
                payload = msg[1+HEADER_SIZE:]
                if len(payload) != length:
                    continue

                try:
                    text = payload.decode()
                except UnicodeDecodeError:
                    continue

                if not text.startswith("CHAT|"):
                    continue

                _, tp, room, user, data = text.split("|", 4)

                # ---- discovery / federation ----
                if tp == "SERVER_HELLO" and src != my_ip:
                    federated_servers.add(src)
                    print(f"🔗 Federated with {data} @ {ipaddress.IPv4Address(src)}")

                elif tp == "HELLO":
                    clients[src] = user
                    print(f"👤 {user} connected")

                elif tp == "ROOM_LIST":
                    await ws.send(encode(
                        my_ip, src,
                        chat("ROOM_LIST", "*", "server", ",".join(rooms.keys()))
                    ))

                # ---- room management ----
                elif tp == "JOIN":
                    rooms.setdefault(room, set()).add(src)
                    for ip in rooms[room]:
                        await ws.send(encode(
                            my_ip, ip,
                            chat("INFO", room, "server", f"{user} joined")
                        ))

                elif tp == "LEAVE":
                    rooms.get(room, set()).discard(src)

                # ---- messaging ----
                elif tp == "MSG":
                    for ip in rooms.get(room, []):
                        await ws.send(encode(
                            my_ip, ip,
                            chat("MSG", room, user, data)
                        ))

                    for srv in federated_servers:
                        await ws.send(encode(
                            my_ip, srv,
                            chat("FED_MSG", room, user, data)
                        ))

                elif tp == "FED_MSG":
                    for ip in rooms.get(room, []):
                        await ws.send(encode(
                            my_ip, ip,
                            chat("MSG", room, user, data)
                        ))

        await asyncio.gather(announce(), handler())

asyncio.run(main())
