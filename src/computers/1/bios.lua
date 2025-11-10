local computer = component.getFirst("computer")
local screen=component.getFirst("screen")
if not screen then
    computer.beep(400,0.2)
    sleep(0.2)
    computer.beep(400,0.2)
    while true do
        computer.shutdown()
    end
end
local idx = 1
local ok, err = xpcall(function()
    for t, a in component.list() do
        if t == "disk" then
            if a:fileExists("boot.lua") then
                screen.print("Bootable file found on "..a.id.." - reading...")
                local code = a:open("boot.lua").read()
                screen.print("Compiling boot.lua...")
                local f = load(code)
                if not f then error("bios boot compilation failed") end
                screen.print("Booting...")
                ---@diagnostic disable-next-line: need-check-nil         
                local ok, err = xpcall(f, debug.traceback)
                if not ok then screen.print(err); sleep(3) end
                break
            else
                idx = idx+1
            end
        end
    end
end, debug.traceback)
if not ok then
    screen.print("BIOS error: "..err)
    computer.beep(800,0.2)
    osleep(0.02)
    screen.print("Press enter to continue...")
    while true do
        local event = {computer.getMachineEvent()}
        if event[1] == "keyTyped" then
            if event[3] == "\n" then
                computer.shutdown()
            end
        end
        sleep(0.02)
    end
end
computer.beep(400,0.4)
screen.print("No bootable filesystem found!")
screen.print("Press enter to continue...")
while true do
    local event = {computer.getMachineEvent()}
    if event[1] == "keyTyped" then
        if event[3] == "\n" then
            computer.shutdown()
        end
    end
    sleep(0.02)
end