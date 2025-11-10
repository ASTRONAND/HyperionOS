local computer = component.getFirst("computer")
local screen=component.getFirst("screen")
if not screen then
    local function e(...)end
    screen = {
        print=e,
        printInline=e,
        clear=e
    }
end

local ok,err = xpcall(function()
    -- Init components
    _G._DEVELOPMENT=true
    _G.component=component

    local printed=""
    local print=function(text)
        printed=printed..text.."\n"
        screen.print(text)
    end

    -- Get CFG
    local biosCfg = {}
    local i=1
    while i<=256 do
        biosCfg[i]=computer.getData(i) or ""
        i=i+1
    end
    computer.beep(800,0.2)
    -- Difine functions
    local function copy(tabl)
        local out = {}
        for i,v in pairs(tabl) do
            local t=type(v)
            if t=="table" then
                if i == "_G" then
                    out._G=out
                else
                    out[i]=copy(v)
                end
            else
                out[i]=v
            end
        end
        return out
    end

    local function save(table)
        while i<=256 do
            computer.setData(i, table[i] or nil)
            i=i+1
        end
    end

    local function hasKey(tabl, query)
        for i,v in pairs(tabl) do
            if i==query then
                return true
            end
        end
        return false
    end

    -- Start boot seq
    local disks={}
    for i,v in component.list() do
        if i=="disk" then
            disks[v.id]=v
            if v.type=="udd" then
                v:writeBytes(0, "HDS") -- "HDS"
                local tmp = v:readBytes(0,512) -- Just to make sure it writes the data
                print(tmp)
            end
        end
    end

    local idx = 1
    local bootOption=1
    while true do
        if biosCfg[idx]=="$EOF" then break end
        print("Atempting boot option "..tostring(bootOption).." labled \""..biosCfg[idx].."\".")
        bootOption=bootOption+1
        local drive={}
        idx=idx+1
        if not hasKey(disks,biosCfg[idx]) then
            print("└─ Drive not found.")
            print(" ")
            idx=idx+3
            goto invalid_boot
        else
            drive=disks[biosCfg[idx]]
            print("├─ Drive found with id of \""..drive.id.."\"")
        end
        idx=idx+1
        local path
        local code
        if drive.type=="udd" then
            print("├─ Drive is Unmanaged, looking for MBR...")
            sleep(0.02)
            print("├─ Reading MBR...")
            local tmp = drive.readBytes(0,512)
            print("├─ MBR found, compiling bootloader...")
            code = table.concat(tmp)
        else
            if not drive:fileExists(biosCfg[idx]) then
                print("└─ Path not found.")
                print(" ")
                idx=idx+2
                goto invalid_boot
            else
                print("├─ Kernel exists at path \""..biosCfg[idx].."\"")
                path=biosCfg[idx]
            end
            code = drive:open(path).read()
        end
        idx=idx+1
        local _VG=copy(_G)
        print("├─ Created virtual ENV.")
        local _,func = pcall(load,code,drive.id.." | "..path,nil,_VG)
        if not func then
            print("└─ Compilation failure.")
            print(" ")
            idx=idx+1
            goto invalid_boot
        else
            print("├─ Executing.")
        end
        local cmd=biosCfg[idx] or ""
        idx=idx+1
        local biosData = {}
        biosData.bootDrive=drive
        biosData.term=screen
        screen.clear()
        local ok, err = xpcall(func, debug.traceback, biosData, cmd)
        screen.clear()
        screen.print(printed)
        if not ok then
            print("└─ OS exited with error: "..err)
            print(" ")
        else
            print("└─ OS exited.")
            print(" ")
        end
        screen.print("Press enter to continue...")
        while true do
            local event = {computer.getMachineEvent()}
            if event[1] == "keyTyped" then
                if event[3] == "\n" then
                    break
                end
            end
            sleep(0.02)
        end
        ::invalid_boot::
    end
    computer.beep(400,0.4)
    print("No boot options available")
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
end, debug.traceback)
if not ok then
    screen.clear()
    screen.print("BIOS PANIC: "..err)
    computer.beep(800,0.2)
    sleep(0.02)
    computer.beep(800,0.2)
    sleep(0.02)
    computer.beep(800,0.2)
    sleep(0.02)
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