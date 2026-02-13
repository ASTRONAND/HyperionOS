--:Minify:--
local kernel=...
local fs=require("sys.fs")

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
                syscall.setUsername("User")
                syscall.setuid(1)
                local status, err = pcall(startupFunc)
                if not status then
                    kernel.log("Error executing startup script '" .. filepath .. "': " .. err, "ERROR")
                else
                    kernel.log("Successfully executed startup script: " .. filepath, "INFO")
                end
            end, "startup:" .. v)
        end
    end
end

while true do
    sleep(1)
    kernel.saveLog()
end