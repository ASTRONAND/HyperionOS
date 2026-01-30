--:Minify:--
local kernel=...
local fs=require("sys.fs")
syscall.TTY_bind("tty0")
syscall.IO_bind("raw")

for i,v in pairs(kernel.processes) do
    kernel.log("Spawning kernel task "..i)
    syscall.spawn(function()
        local status, err = pcall(v)
        if not status then
            kernel.log("Error executing kernel task '" .. i .. "': " .. err, "ERROR")
        else
            kernel.log("Successfully executed kernel task: " .. i, "INFO")
        end
    end, i)
end

local eventQueues = {}
local files = fs.list("/bin/startup")
if not files then error("Failed to list /bin/startup") end
for i,v in ipairs(files) do
    if v:sub(-4) == ".lua" then
        local filepath = "/bin/startup/" .. v
        kernel.log("Executing startup script: " .. filepath, "INFO")
        local startupFunc, err = load(fs.readAllText(filepath), "@" .. filepath)
        if not startupFunc then
            kernel.log("Error loading startup script '" .. filepath .. "': " .. err, "ERROR")
        else
            syscall.spawn(function()
                syscall.IO_bind("eventQueue:"..tostring(i))
                local spot = #eventQueues+1
                eventQueues[spot]="eventQueue:"..tostring(i)
                local status, err = pcall(startupFunc)
                if not status then
                    kernel.log("Error executing startup script '" .. filepath .. "': " .. err, "ERROR")
                else
                    kernel.log("Successfully executed startup script: " .. filepath, "INFO")
                end
                local event={true}
                while #event~=0 do
                    event={syscall.IO_pullEvent()}
                end
            end, "startup:" .. v)
        end
    end
end

local timeout=false
while true do
    local event = {syscall.IO_pullEvent()}
    if event[1] then
        for i,v in ipairs(eventQueues) do
            syscall.IO_pushEvent(v, table.unpack(event))
        end
        timeout=false
    else
        timeout=true
    end
    if timeout then
        sleep(.05)
    end
    kernel.saveLog()
end