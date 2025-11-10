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
    xpcall = true,
    _G=true
}

for i,v in pairs(_G) do
    if not lua[i] or lua[i]==nil then
        apis[i]=v
        _G[i]=nil
    end
end

function sleep(time)
    coroutine.yield("CC_TIMER", time)
end

local function catErr(text)
    apis.term.setCursorPos(1,1)
    apis.term.write(text)
    while true do
        coroutine.yield()
    end
end

local function getFile(path)
    if path:sub(1,1) ~= "/" then
        path="/"..path
    end
    path="/disk"..path
    if not apis.fs.exists(path) then error("File does not exist") end
    if apis.fs.isDir(path) then error("Cannot open a directory") end
    return {
        readAllText=function()
            local file = apis.fs.open(path, "r")
            local text = file.readAll()
            file.close()
            return text
        end,
        writeAllText=function(text)
            local file = apis.fs.open(path, "w")
            file.write(text)
            file.close()
        end
    }
end

-- Prints text handling \n, \t, and \b with scrolling (no wrapping)
local function write(text)
    local x, y = apis.term.getCursorPos()
    local w, h = apis.term.getSize()

    for i = 1, #text do
        local c = text:sub(i, i)

        if c == "\n" then
            y = y + 1
            x = 1
        elseif c == "\t" then
            local tabSize = 4
            local spaces = tabSize - ((x - 1) % tabSize)
            apis.term.write(string.rep(" ", spaces))
            x = x + spaces
        elseif c == "\b" then
            if x > 1 then
                x = x - 1
                apis.term.setCursorPos(x, y)
                apis.term.write(" ")
                apis.term.setCursorPos(x, y)
            end
        else
            if x <= w and y <= h then
                apis.term.setCursorPos(x, y)
                apis.term.write(c)
                x = x + 1
            end
        end

        -- Handle scrolling if we go past bottom
        if y > h then
            apis.term.scroll(1)
            y = h
            apis.term.setCursorPos(x, y)
        end
    end

    apis.term.setCursorPos(x, y)
end


local event_queue = {}
local function addEventRaw(...)
    event_queue[#event_queue+1] = {...}
end

local function getEvent()
    local event = event_queue[1]
    event_queue = {table.unpack(event_queue, 2)}
    return table.unpack(event or {})
end

local lkeys={}
lkeys[apis.keys.enter]="\n"
lkeys[apis.keys.backspace]="\b"
lkeys[apis.keys.tab]="\t"

local computer={}
computer.beep=function() end
computer.shutdown=apis.os.shutdown
computer.reboot=apis.os.reboot
computer.time=function()
    return apis.os.epoch("utc")
end
computer.getMachineEvent=getEvent
computer.date=apis.os.date

local function list(path)
    if path:sub(1,1) ~= "/" then
        path="/"..path
    end
    path="/disk"..path
    if not apis.fs.isDir(path) then return {} end
    return apis.fs.list(path)
end

function coroutine.resumeWithTimeout(CORO, LINES, ...)
    local yeildKey = {}
    debug.sethook(CORO, function()
        coroutine.yield(yeildKey)
    end, "l", LINES)
    local ret = {coroutine.resume(CORO, ...)}
    debug.sethook(CORO)
    if ret[2]==yeildKey then return false else return true, table.unpack(ret, 2) end
end

local kernel = load(getFile("/boot/HBoot.sys").readAllText(), "@kernel", "t", _G)
if not kernel then
    catErr("BOOT COMPILE ERR")
end
local kernel_coro = coroutine.create(function()
    local ok,err = pcall(function()
        local ok, err=xpcall(kernel, debug.traceback, "cc", apis, "disk", {
            print=function(text)
                write(text.."\n")
            end,
            printInline=function(text)
                write(text)
            end,
            clear=function()
                apis.term.clear()
                apis.term.setCursorPos(1,1)
            end,
            getSize=function ()
                return apis.term.getSize()
            end
        }, getFile, list, computer)
        if not ok then
            write(err)
            while true do
                coroutine.yield()
            end
        end
    end)
    if not ok then
        catErr(err)
    end
end)

apis.term.setCursorBlink(false)
while true do
    local ret = {coroutine.resumeWithTimeout(kernel_coro, 200)}
    if coroutine.status(kernel_coro) == "dead" then
        catErr("KERNEL EXITED")
    end
    if ret[1] then
        if ret[2]=="CC_TIMER" and ret[3]~=nil and type(ret[3])=="number" then
            local timer = apis.os.startTimer(ret[3])
            repeat
                local _, param = coroutine.yield("timer")
            until param == timer
        end
    end
    apis.os.queueEvent("nosleep")
    local exit = false
    repeat
        local event = {coroutine.yield()}
        if event[1] == "nosleep" then
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
            addEventRaw("componentAdded", "disk")
        elseif event[1]=="disk_eject" then
            addEventRaw("componentRemoved", "disk")
        end
    until exit
end
apis.os.reboot()