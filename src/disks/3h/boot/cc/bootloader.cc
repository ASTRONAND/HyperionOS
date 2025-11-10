local apis={}

local lua = {
    coroutine = true,
    debug = true,
    _HOST = true,
    _VERSION = true,
    assert = true,
    collectgarbage = true,
    error = true,
    gcinfo = true,
    getfenv = true,
    getmetatable = true,
    ipairs = true,
    __inext = true,
    load = true,
    math = true,
    next = true,
    pairs = true,
    pcall = true,
    rawequal = true,
    rawget = true,
    rawlen = true,
    rawset = true,
    select = true,
    setfenv = true,
    setmetatable = true,
    string = true,
    table = true,
    tonumber = true,
    tostring = true,
    type = true,
    xpcall = true
}

for i,v in ipairs(_G) do
    if not lua[i] then
        apis[i]=v
        _G[i]=nil
    end
end

local function getFile(path)
    if path:sub(1,1) ~= "/" then
        path="/"..path
    end
    local file = apis.fs.open("/root"..path)
end

local function write(text)
    
end

local event_queue = {}
local function addEventRaw(...)
    event_queue[#event_queue+1] = {...}
end

local function getEvent()
    local event = event_queue[1]
    event_queue = {table.unpack(event_queue, 2)}
    return table.unpack(event)
end

local lkeys={}
lkeys[keys.enter]="\n"
lkeys[keys.backspace]="\b"
lkeys[keys.tab]="\t"

local kernel = load(getFile("/boot/Hyprkrnl.sys"), "@kernel", "t", _G)
local kernel_coro = coroutine.create(function()
    kernel("cc", apis, "internal", {
        print=function(text)
            write(text)
            write("\n")
        end,
        printInline=function(text)
            write(text)
        end,
        clear=function()
            apis.term.clear()
            apis.term.setCursorPos(1,1)
        end
    }, getEvent)
end)

debug.sethook(kernel_coro, function() coroutine.yield("CC:TWEAKED", "CORO_TIMEOUT") end, "l", 3000)
while true do
    local ret = {coroutine.resume(kernel_coro)}
    if coroutine.status(kernel_coro) == "dead" then
        break
    end
    local timer = os.startTimer(0)
    local exit = false
    repeat
        local event = {coroutine.yield()}
        if event[1] == "timer" and event[2]==timer then
            exit=true
        elseif event[1]==nil then
        elseif event[1]=="key" then
            addEventRaw("keyPressed", 1, event[2])
            if lkeys[event[2]] then
                addEventRaw("keyTyped", 1, lkeys[event[2]])
            end
        elseif event[1]=="char" then
            addEventRaw("keyTyped", 1, event[2])
        elseif event[1]=="key_up" then
            addEventRaw("keyReleased", 1, event[2])
        elseif event[1]=="disk" then
            addEventRaw("componentAdded", "disk", sandboxedFS.new(api.disk.getMountPath(event[2]), apis.disk.getID(event[2])))
        elseif event[1]=="disk_eject" then
            addEventRaw("componentRemoved", "disk")
        end
    until exit
end