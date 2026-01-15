local kernel=...
local fs=require("sys.fs")
syscall.TTY_bind("tty0")

for i,v in ipairs(kernel.)
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
            syscall.HPV_spawn(function()
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
    kernel.saveLog()
    sleep(1000)
end