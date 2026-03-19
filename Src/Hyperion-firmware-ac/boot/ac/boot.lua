--:Minify:--
local args={...}
local bootdrive=args[1]
local gpu=components:getFirst("gpu")
local screenTextBuffer=nil
local cursorX,cursorY=0,0
local screenSizeX,screenSizeY=128,25


if gpu then
    screenTextBuffer=gpu:newBuffer(screenSizeX,screenSizeY)
    for t,v in components:list() do
		if t == "screen" then
			gpu:assignBuffer(screenTextBuffer, v)
		end
	end
end

local function write(text)
	cursorX, cursorY = screenTextBuffer:pasteText(cursorX, cursorY, "SCROLL_SPILL_CLEAR", text)
	cursorY = cursorY + 1
	cursorX = 0
	if cursorY >= screenSizeY then
		cursorY = screenSizeY-1
		screenTextBuffer:newline()
	end
end

local function displaySuperBadError(err)
    gpu:freeAllBuffers()
    screenTextBuffer=gpu:newBuffer(screenSizeX,screenSizeY)
    for t,v in components:list() do
		if t == "screen" then
			gpu:assignBuffer(screenTextBuffer, v)
		end
	end
    term.setBackgroundColor(0x1)
    term.setTextColor(0x4)
    term.clear()
    term.setCursorPos(1, 1)
    term.write("A critical error occurred while loading the system:")
    term.setCursorPos(1, 3)
    write(err)
    while true do end
end

local ok, err = xpcall(function()
    local apis = {}

    local lua = {
        coroutine = true,
        debug = true,
        _VERSION = true,
        assert = true,
        collectgarbage = true,
        error = true,
        gcinfo = true,
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
        setmetatable = true,
        string = true,
        table = true,
        tonumber = true,
        tostring = true,
        type = true,
        xpcall = true,
        _G = true
    }

    local debug = debug
    for i, v in pairs(_G) do
        if not lua[i] or lua[i] == nil then
            apis[i] = v
            _G[i] = nil
        end
    end

    local function string_file(file)
        local str = file:read()
        local buf = {str or ""}
        local pos = 1
        local closed = false

        local function content()
            return table.concat(buf)
        end

        local function set_content(s)
            buf = {s}
        end

        local function flush()
            file.write(content())
        end

        local file = {}

        function file:read(n)
            assert(not closed, "file is closed")

            local s = content()
            local len = #s

            if not n then
                local out = s:sub(pos)
                pos = len + 1
                return out
            end

            local out = s:sub(pos, pos + n - 1)
            pos = pos + #out
            return out
        end

        function file:write(data)
            assert(not closed, "file is closed")

            local s = content()
            local before = s:sub(1, pos - 1)
            local after = s:sub(pos + #data)

            set_content(before .. data .. after)
            pos = pos + #data

            return true
        end

        function file:seek(whence, offset)
            assert(not closed, "file is closed")

            local s = content()
            local len = #s

            whence = whence or "cur"
            offset = offset or 0

            if whence == "set" then
                pos = offset + 1
            elseif whence == "cur" then
                pos = pos + offset
            elseif whence == "end" then
                pos = len + offset + 1
            else
                error("invalid whence")
            end

            if pos < 1 then pos = 1 end
            if pos > len + 1 then pos = len + 1 end

            return pos - 1
        end

        function file:close()
            assert(not closed, "file is closed")
            flush()
            closed = true
        end

        function file:flush()
            assert(not closed, "file is closed")
            flush()
        end

        return file
    end

    local function getFile(path)
        local file = bootdrive:open(path, "r")
        if not file then
            displaySuperBadError("Could not open file: " .. path)
        end
        local content = file:read()
        return content
    end

    local Kernel = load(getFile("/boot/kernel.lua"),"@Kernel")
    local initFs = load(getFile("/boot/ac/initdisks"),"@Init_disks")(apis)
    local fs = load(getFile("/boot/initfs"), "@InitFs")()

    if not Kernel then displaySuperBadError("Could not load kernel.") end
    if not initFs then displaySuperBadError("Could not load initdisks.") end
    if not fs then displaySuperBadError("Could not load initfs.") end

    local computercomp=apis.components:getFirst("computer")
    local uefi=apis.components:getFirst("uefi")
    local computer = {
        time = function() return apis.os.epoch("utc") end,
        clock = function() return apis.os.clock() * 1000 end,
        shutdown = apis.os.shutdown,
        reboot = apis.os.reboot,
        getMachineEvent = function()
            return computercomp:getMachineEvent()
        end,
        getEEPROM = function() return uefi.data end,
        setEEPROM = function(_, text)
            uefi.data=text
        end
    }

    local icolors = {
        [0x1] = 1, -- #000000
        [0x2] = 2, -- #FFFFFF
        [0x4] = 3, -- #FF0000
        [0x8] = 4, -- #00FF00
        [0x10] = 5, -- #0000FF
        [0x20] = 6, -- #00FFFF
        [0x40] = 7, -- #FF00FF
        [0x80] = 8, -- #FFFF00
        [0x100] = 9, -- #FF6D00
        [0x200] = 10, -- #6DFF55
        [0x400] = 11, -- #24FFFF
        [0x800] = 12, -- #924900
        [0x1000] = 13, -- #6D6D55
        [0x2000] = 14, -- #DBDBAA
        [0x4000] = 15, -- #6D00FF
        [0x8000] = 16 -- #B6FF00
    }

    local colors = {
        0x0001, -- #000000
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

    apis.term.setBackgroundColor(0x8000)
    apis.term.setTextColor(0x1000)
    apis.term.clear()
    apis.term.setCursorPos(1, 1)

    local kernelCoro = coroutine.create(function()
        ---@diagnostic disable-next-line: param-type-mismatch
        local ok, err = xpcall(Kernel, debug.traceback, apis, initFs, "cct", "/sbin/init",
        {
            print = function(_, text) write(text .. "\n") end,
            printInline = function(_, text) write(text) end,
            clear = function()
                apis.term.clear()
                apis.term.setCursorPos(1, 1)
            end,
            setCursorPos = function(_, x, y)
                apis.term.setCursorPos(x, y)
            end,
            getCursorPos = function() return apis.term.getCursorPos() end,
            getSize = function() return apis.term.getSize() end,
            setBackgroundColor = function(_, color)
                apis.term.setBackgroundColor(colors[color])
            end,
            setTextColor = function(_, color)
                apis.term.setTextColor(colors[color])
            end,
            getBackgroundColor = function()
                return icolors[apis.term.getBackgroundColor()]
            end,
            getTextColor = function()
                return icolors[apis.term.getTextColor()]
            end
        }, computer, fs, "$")
        if not ok then displaySuperBadError(err) end
    end)

    function coroutine.resumeWithTimeout(co, timeout, ...)
        local startTime = computer.time()
        debug.sethook(co, function()
            if computer.time() > startTime + timeout then
                return coroutine.yield("timeout")
            end
        end, "", 1000)
        local ret = {coroutine.resume(co, ...)}
        if ret[1] and ret[2] == "timeout" then
            return "timeout"
        elseif ret[1] == false then
            return "error", ret[2]
        else
            debug.sethook(co)
            return "success", table.unpack(ret, 2)
        end
    end

    write("Loaded in " .. tostring(apis.os.clock()) .. " seconds.\n")

    while true do
        local status, err = coroutine.resumeWithTimeout(kernelCoro, 50)
        apis.os.queueEvent("NoSleep")
        local exit = false
        while not exit do
            local event = {coroutine.yield()}
            if event[1] == "key" then
                queueEvent("keyPressed", 1, event[2])
                if acekeys[event[2]] then
                    queueEvent("keyTyped", 1, acekeys[event[2]])
                end
            elseif event[1] == "char" then
                queueEvent("keyTyped", 1, event[2])
            elseif event[1] == "key_up" then
                queueEvent("keyReleased", 1, event[2])
            elseif event[1] == "disk" then
                queueEvent("componentAdded", "disk")
            elseif event[1] == "disk_eject" then
                queueEvent("componentRemoved", "disk")
            elseif event[1] == "modem_message" then
                queueEvent("modem_message", table.unpack(event, 2))
            elseif event[1] == "rednet_message" then
                queueEvent("rednet_message", table.unpack(event, 2))
            elseif event[1] == "http_success" then
                queueEvent("http_success", table.unpack(event, 2))
            elseif event[1] == "http_failure" then
                queueEvent("http_failure", table.unpack(event, 2))
            elseif event[1] == "NoSleep" then
                exit = true
            end
        end
        if status == "error" or coroutine.status(kernelCoro) == "dead" then
            displaySuperBadError("Kernel error: " .. tostring(err))
            coroutine.yield("key")
        end
    end
end, debug.traceback)

if not ok then displaySuperBadError("Fatal error during boot: " .. err) end
while true do coroutine.yield() end
