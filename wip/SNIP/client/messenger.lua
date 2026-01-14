local ws = http.websocket("wss://ip.astronand.dev")

local OP_DATA = 0x10

-- Example IPs (replace with assigned ones)
local my_ip = {10,0,0,2}
local peers = {}

local function pack_u32(n)
    return string.char(
        bit32.rshift(n,24) & 0xFF,
        bit32.rshift(n,16) & 0xFF,
        bit32.rshift(n,8) & 0xFF,
        n & 0xFF
    )
end

local function pack_ip(ip)
    return string.char(ip[1], ip[2], ip[3], ip[4])
end

local function send_chat(dst_ip, username, msg)
    local payload = "CHAT|" .. username .. "|" .. msg
    local packet =
        string.char(OP_DATA) ..
        pack_ip(my_ip) ..
        pack_ip(dst_ip) ..
        pack_u32(#payload) ..
        payload

    ws.send(packet)
end

-- Receiver
local function receiver()
    while true do
        local msg = ws.receive()
        if msg then
            local op = string.byte(msg, 1)
            if op == OP_DATA then
                local payload = msg:sub(14)
                if payload:sub(1,5) == "CHAT|" then
                    local _, _, user, text =
                        payload:find("CHAT|(.-)|(.*)")
                    print(user .. ": " .. text)
                end
            end
        end
    end
end

-- Sender
local function sender()
    write("Username: ")
    local username = read()

    while true do
        local msg = read()
        for _, ip in pairs(peers) do
            send_chat(ip, username, msg)
        end
    end
end

parallel.waitForAny(receiver, sender)
