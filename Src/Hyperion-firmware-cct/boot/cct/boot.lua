--:Minify:--
local BOOT_DRIVE_PATH=({...})[1] or "/$"
---@diagnostic disable-next-line: undefined-global
local term = term
local os = os
local function write(text)
    local x, y = term.getCursorPos()
    local w, h = term.getSize()

    for i = 1, #text do
        local c = text:sub(i, i)

        if c == "\n" then
            y = y + 1
            x = 1
            if y-1 >= h then
                term.scroll(1)
                y = h
                term.setCursorPos(x, y)
            end
        elseif c == "\t" then
            local tabSize = 4
            local spaces = tabSize - ((x - 1) % tabSize)
            term.write(string.rep(" ", spaces))
            x = x + spaces
        elseif c == "\b" then
            if x > 1 then
                x = x - 1
                term.setCursorPos(x, y)
                term.write(" ")
                term.setCursorPos(x, y)
            end
        else
            if x <= w and y <= h then
                term.setCursorPos(x, y)
                term.write(c)
                x = x + 1
            end
        end

        if x > w then
            x = 1
            y = y + 1
        end

        if y-1 >= h then
            term.scroll(1)
            y = h
            term.setCursorPos(x, y)
        end
    end

    term.setCursorPos(x, y)
end

local function displaySuperBadError(err)
    term.setBackgroundColor(0x1)
    term.setTextColor(0x4)
    term.clear()
    term.setCursorPos(1, 1)
    term.write("A critical error occurred while loading the system:")
    term.setCursorPos(1, 3)
    write(err)
    while true do end
end

term.setCursorBlink(false)
local ok, err = xpcall(function()
    local apis={BOOT_DRIVE_PATH=BOOT_DRIVE_PATH}

    local lua = {
        coroutine = true,
        debug = true,
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

    local debug = debug
    for i,v in pairs(_G) do
        if not lua[i] or lua[i]==nil then
            apis[i]=v
            _G[i]=nil
        end
    end

    function sleep(time)
        local stoptime = apis.os.clock() + (time)
        while stoptime > apis.os.clock() do end
    end

    apis.term.setPaletteColor(0x1,    0x000000) -- #000000
    apis.term.setPaletteColor(0x2,    0xFFFFFF) -- #FFFFFF
    apis.term.setPaletteColor(0x4,    0xFF0000) -- #FF0000
    apis.term.setPaletteColor(0x8,    0x00FF00) -- #00FF00
    apis.term.setPaletteColor(0x10,   0x0000FF) -- #0000FF
    apis.term.setPaletteColor(0x20,   0x00FFFF) -- #00FFFF
    apis.term.setPaletteColor(0x40,   0xFF00FF) -- #FF00FF
    apis.term.setPaletteColor(0x80,   0xFFFF00) -- #FFFF00
    apis.term.setPaletteColor(0x100,  0xFF6D00) -- #FF6D00
    apis.term.setPaletteColor(0x200,  0x6DFF55) -- #6DFF55
    apis.term.setPaletteColor(0x400,  0x24FFFF) -- #24FFFF
    apis.term.setPaletteColor(0x800,  0x924900) -- #924900
    apis.term.setPaletteColor(0x1000, 0x6D6D55) -- #6D6D55
    apis.term.setPaletteColor(0x2000, 0xDBDBAA) -- #DBDBAA
    apis.term.setPaletteColor(0x4000, 0x6D00FF) -- #6D00FF
    apis.term.setPaletteColor(0x8000, 0xB6FF00) -- #B6FF00

    local function getFile(path)
        local file = apis.fs.open(path, "r")
        if not file then displaySuperBadError("Could not open file: "..path) end
        local content = file.readAll()
        file.close()
        return content
    end

    local Kernel = load(getFile(BOOT_DRIVE_PATH.."/boot/kernel.lua"),"@Kernel")
    local initFs = load(getFile(BOOT_DRIVE_PATH.."/boot/cct/initdisks"),"@Init_disks")(apis)
    local fs = load(getFile(BOOT_DRIVE_PATH.."/boot/initfs"),"@InitFs")()
    local key = load(getFile(BOOT_DRIVE_PATH.."/boot/cct/keys.lua"),"@keyhelper")(apis)
    if not Kernel then
        displaySuperBadError("Could not load kernel.")
    end
    if not initFs then
        displaySuperBadError("Could not load initdisks.")
    end
    if not fs then
        displaySuperBadError("Could not load initfs.")
    end
    if not key then
        displaySuperBadError("Could not load key helper.")
    end

    local eventQueue = {}

    local function queueEvent(event, ...)
        table.insert(eventQueue, {event, ...})
    end

    local computer = {
        time = function() return apis.os.epoch("utc") end,
        clock = function() return apis.os.clock()*1000 end,
        shutdown = apis.os.shutdown,
        reboot = apis.os.reboot,
        getMachineEvent = function()
            if #eventQueue > 0 then
                return table.unpack(table.remove(eventQueue, 1))
            else
                return nil
            end
        end,
        getEEPROM = function()
            return getFile("/startup.lua")
        end,
        setEEPROM = function(_,text)
            local h = apis.fs.open("/startup.lua", "w")
            h.write(text)
            h.close()
        end
    }

    local icolors={
        [0x1]    =0,  -- #000000
        [0x2]    =1,  -- #FFFFFF
        [0x4]    =2,  -- #FF0000
        [0x8]    =3,  -- #00FF00
        [0x10]   =4,  -- #0000FF
        [0x20]   =5,  -- #00FFFF
        [0x40]   =6,  -- #FF00FF
        [0x80]   =7,  -- #FFFF00
        [0x100]  =8,  -- #FF6D00
        [0x200]  =9,  -- #6DFF55
        [0x400]  =10, -- #24FFFF
        [0x800]  =11, -- #924900
        [0x1000] =12, -- #6D6D55
        [0x2000] =13, -- #DBDBAA
        [0x4000] =14, -- #6D00FF
        [0x8000] =15  -- #B6FF00
    }

    local colors={
        [0]=0x0001, -- #000000
        0x0002, -- #FFFFFF
        0x0004, -- #FF0000
        0x0008, -- #00FF00
        0x0010, -- #0000FF
        0x0020, -- #00FFFF
        0x0040, -- #FF00FF
        0x0080, -- #FFFF00
        0x0100, -- #FF6D00
        0x0200, -- #6DFF55
        0x0400, -- #24FFFF
        0x0800, -- #924900
        0x1000, -- #6D6D55
        0x2000, -- #DBDBAA
        0x4000, -- #6D00FF
        0x8000  -- #B6FF00
    }

    apis.term.setBackgroundColor(0x1)
    apis.term.setTextColor(0x1000)
    apis.term.clear()
    apis.term.setCursorPos(1, 1)

    local kernelCoro = coroutine.create(function()
        ---@diagnostic disable-next-line: param-type-mismatch
        local ok, err = xpcall(Kernel, debug.traceback, apis, initFs, "cct", "/sbin/init", {
            print=function(_,text) write(text.."\n") end,
            printInline=function(_,text) write(text) end,
            clear=function() apis.term.clear() apis.term.setCursorPos(1,1) end,
            setCursorPos=function(_,x,y) apis.term.setCursorPos(x,y) end,
            getCursorPos=function() return apis.term.getCursorPos() end,
            getSize=function() return apis.term.getSize() end,
            setBackgroundColor=function(_,color) apis.term.setBackgroundColor(colors[color]) end,
            setTextColor=function(_,color) apis.term.setTextColor(colors[color]) end,
            getBackgroundColor=function() return icolors[apis.term.getBackgroundColor()] end,
            getTextColor=function() return icolors[apis.term.getTextColor()] end
        }, computer, fs, "$")
        if not ok then
            displaySuperBadError(err)
        end
    end)

    -- time is in milliseconds
    function coroutine.resumeWithTimeout(co, timeout, ...)
        local startTime = computer.time()
        debug.sethook(co, function()
            if computer.time() > startTime + timeout then
                return coroutine.yield("timeout")
            end
        end, "", 1000)
        local ret = {coroutine.resume(co, ...)}
        if ret[1] and ret[2]=="timeout" then
            return "timeout"
        elseif ret[1]==false then
            return "error", ret[2]
        else
            debug.sethook(co)
            return "success", table.unpack(ret, 2)
        end
    end

    write("Loaded in "..tostring(apis.os.clock()).." seconds.\n")

    while true do
        local status, err = coroutine.resumeWithTimeout(kernelCoro, 50)
        apis.os.queueEvent("NoSleep")
        local exit = false
        while not exit do
            local event = {coroutine.yield()}
            if event[1] == "key" then
                queueEvent("keyPressed", 1, event[2])
                key(event, queueEvent)
            elseif event[1] == "key_up" then
                queueEvent("keyReleased", 1, event[2])
                key(event, queueEvent)
            elseif event[1] == "disk" then
                queueEvent("componentAdded", "disk")
            elseif event[1] == "disk_eject" then
                queueEvent("componentRemoved", "disk")
            elseif event[1] == "NoSleep" then
                exit=true
            end
        end
        if status == "error" or coroutine.status(kernelCoro)=="dead" then
            displaySuperBadError("Kernel error: "..tostring(err))
            coroutine.yield("key")
        end
    end
end, debug.traceback)

if not ok then
    displaySuperBadError("Fatal error during boot: "..err)
end
while true do coroutine.yield() end