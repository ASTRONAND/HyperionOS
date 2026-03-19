--:Minify:--
local BOOT_DRIVE_PATH = ({...})[1] or "/$"
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

        if y - 1 >= h then
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
    local apis = {BOOT_DRIVE_PATH = BOOT_DRIVE_PATH}

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

    local acekeys={
        [apis.keys.enter]="\n",
        [apis.keys.tab]="\t",
        [apis.keys.backspace]="\b",
        [apis.keys.up]="\17",
        [apis.keys.down]="\18",
        [apis.keys.left]="\19",
        [apis.keys.right]="\20",
    }

    function sleep(time)
        local stoptime = apis.os.clock() + (time)
        while stoptime > apis.os.clock() do end
    end

    apis.term.setPaletteColor(0x1, 0xFFFFFF) -- #000000
    apis.term.setPaletteColor(0x2, 0xFF0000) -- #FFFFFF
    apis.term.setPaletteColor(0x4, 0x00FF00) -- #FF0000
    apis.term.setPaletteColor(0x8, 0x0000FF) -- #00FF00
    apis.term.setPaletteColor(0x10, 0x00FFFF) -- #0000FF
    apis.term.setPaletteColor(0x20, 0xFF00FF) -- #00FFFF
    apis.term.setPaletteColor(0x40, 0xFFFF00) -- #FF00FF
    apis.term.setPaletteColor(0x80, 0xFF6D00) -- #FFFF00
    apis.term.setPaletteColor(0x100, 0x6DFF55) -- #FF6D00
    apis.term.setPaletteColor(0x200, 0x24FFFF) -- #6DFF55
    apis.term.setPaletteColor(0x400, 0x924900) -- #24FFFF
    apis.term.setPaletteColor(0x800, 0x6D6D55) -- #924900
    apis.term.setPaletteColor(0x1000, 0xDBDBAA) -- #6D6D55
    apis.term.setPaletteColor(0x2000, 0x6D00FF) -- #DBDBAA
    apis.term.setPaletteColor(0x4000, 0xB6FF00) -- #6D00FF
    apis.term.setPaletteColor(0x8000, 0x000000) -- #B6FF00

    local function getFile(path)
        local file = apis.fs.open(path, "r")
        if not file then
            displaySuperBadError("Could not open file: " .. path)
        end
        local content = file.readAll()
        file.close()
        return content
    end

    local Kernel = load(getFile(BOOT_DRIVE_PATH .. "/boot/kernel.lua"),"@Kernel")
    local initFs = load(getFile(BOOT_DRIVE_PATH .. "/boot/cct/initdisks"),"@Init_disks")(apis)
    local fs = load(getFile(BOOT_DRIVE_PATH .. "/boot/initfs"), "@InitFs")()

    if not Kernel then displaySuperBadError("Could not load kernel.") end
    if not initFs then displaySuperBadError("Could not load initdisks.") end
    if not fs then displaySuperBadError("Could not load initfs.") end

    if not apis.fs.exists("/nvram.dat") then
        local file = apis.fs.open("/nvram.dat", "w")
        file.write("Hello, World!")
        file.close()
    end

    local eeprom
    if apis.fs.exists("/startup.lua") then
        eeprom="/startup.lua"
    elseif apis.fs.exists("/eeprom") then
        eeprom="/eeprom"
    end

    local eventQueue = {}

    local function queueEvent(event, ...)
        table.insert(eventQueue, {event, ...})
    end

    local colors = {
        [0x000000]=0x0001,
        [0xFFFFFF]=0x0002,
        [0xFF0000]=0x0004,
        [0x00FF00]=0x0008,
        [0x0000FF]=0x0010,
        [0x00FFFF]=0x0020,
        [0xFF00FF]=0x0040,
        [0xFFFF00]=0x0080,
        [0xFF6D00]=0x0100,
        [0x6DFF55]=0x0200,
        [0x24FFFF]=0x0400,
        [0x924900]=0x0800,
        [0x6D6D55]=0x1000,
        [0xDBDBAA]=0x2000,
        [0x6D00FF]=0x4000,
        [0xB6FF00]=0x8000
    }

    local fg,bg=0x6D6D55,0x000000
    local l1f,l1d,l2,ops={},{},{},0

    local function findClosest(tbl, target)
        local closest = nil
        local smallestDiff = math.huge

        for k, _ in pairs(tbl) do
            if k==target then return k end
            local diff = math.abs(k - target)
            if diff < smallestDiff then
                smallestDiff = diff
                closest = k
            end
        end

        return closest
    end

    local function aprox(c24)
        ops = ops + 1

        if ops % 1024 == 0 then
            l1d = {}
            l1f = {}
        end

        if ops % 8192 == 0 then
            l2 = {}
        end

        if l2[c24] ~= nil then
            return l2[c24]
        end

        if l1d[c24] ~= nil then
            l1f[c24] = l1f[c24] + 1

            if l1f[c24] >= 16 then
                l2[c24] = l1d[c24]
                l1d[c24] = nil
                l1f[c24] = nil
                return l2[c24]
            end

            return l1d[c24]
        end

        local closestKey = findClosest(colors, c24)
        if not closestKey then return nil end

        local value = colors[closestKey]

        l1d[c24] = value
        l1f[c24] = 1

        return value
    end

    local EFI = {
        getEpochMs = function() return apis.os.epoch("utc") end,
        getUptime = function() return apis.os.clock() * 1000 end,
        date = function() return apis.os.date("!%Y-%m-%dT%H:%M:%SZ", apis.os.epoch("utc") / 1000) end,
        getMachineEvent = function()
            if #eventQueue > 0 then
                return table.unpack(table.remove(eventQueue, 1))
            else
                return nil
            end
        end,
        getEEPROM = function() return getFile(eeprom) end,
        setEEPROM = function(_, text)
            local h = apis.fs.open(eeprom, "w")
            h.write(text)
            h.close()
        end,
        initfs=fs,
        disks=initFs,
        screenCtl={
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
                apis.term.setBackgroundColor(aprox(color))
            end,
            setTextColor = function(_, color)
                apis.term.setTextColor(aprox(color))
            end,
            getBackgroundColor = function()
                return bg
            end,
            getTextColor = function()
                return fg
            end,
            enable=function() end,
            disable=function() end
        },
        architecture="cct",
        getNvram = function() return getFile("/nvram.dat") end,
        setNvram = function(_, text)
            local h = apis.fs.open("/nvram.dat", "w")
            h.write(text)
            h.close()
        end,
        firmware=apis,
        reboot=false
    }

    apis.term.setBackgroundColor(0x8000)
    apis.term.setTextColor(0x1000)
    apis.term.clear()
    apis.term.setCursorPos(1, 1)

    local kernelCoro = coroutine.create(function()
        ---@diagnostic disable-next-line: param-type-mismatch
        local ok, err = xpcall(Kernel, debug.traceback, EFI)
        if not ok and not EFI.reboot then displaySuperBadError(err) end
        if err then
            apis.os.reboot()
        else
            apis.os.shutdown()
        end
    end)

    function coroutine.resumeWithTimeout(co, timeout, ...)
        local startTime = EFI.getEpochMs()
        debug.sethook(co, function()
            if EFI.getEpochMs() > startTime + timeout then
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
            if EFI.reboot then
                apis.os.reboot()
            end
            displaySuperBadError("Kernel error: " .. tostring(err))
            coroutine.yield("key")
        end
        initFs:refresh()
    end
end, debug.traceback)

if not ok then displaySuperBadError("Fatal error during boot: " .. err) end
while true do coroutine.yield("key") end
