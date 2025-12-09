local args = {...}
local apis = args[1]
local disks = args[2]
local arch = args[3]
local initPath = args[4]
local screen = args[5]
local computer = args[6]
local ifs = args[7]
local LOG_Text = ""
local kernel = {}
kernel.process = "Kernel"
kernel.user = "root"
kernel.group = "root"
kernel.groups = {0}
kernel.uid = 0
kernel.gid = 0
kernel.stage = "start"
kernel.key = {}
kernel.chache = {}
kernel.chache.preload = {}
local windowsExp = false

function kernel.log(msg, level)
    LOG_Text = LOG_Text..tostring(computer.time()).." "..kernel.user.." "..kernel.process.."["..tostring(level or "INFO").."]: "..msg.."\n"
    if kernel.stage == "start" then
        screen:print(tostring(computer.time()).." "..kernel.user.." "..kernel.process.."["..tostring(level or "INFO").."]: "..msg)
    end
end

function kernel.PANIC(msg)
    kernel.log("PANIC: "..msg, "PANIC")
    pcall(kernel["saveLog"])
    screen:setTextColor(2)
    screen:setBackgroundColor(0)
    screen:clear()
    screen:setCursorPos(1,1)
    screen:print(LOG_Text)
    screen:print("KERNEL PANIC!\n"..msg.."\nSystem halted.")
    screen:print("Press any key to continue...")
    while true do 
        local event={computer:getMachineEvent()}
        if event[1]=="keyPressed" then
            break
        end
    end
    computer:reboot()
end
kernel.panic=kernel.PANIC

if windowsExp then
    screen:setTextColor(1)
    screen:setBackgroundColor(4)
    screen:clear()
    local w,h = screen:getSize()
    screen:setCursorPos(3,5)
    screen:print(":(")
    screen:setCursorPos(3,7)
    screen:print("Your PC ran into a problem and needs to restart. We're just collecting some error")
    screen:setCursorPos(3,8)
    screen:print("info, and then we'll restart for you.\n")
    screen:setCursorPos(3,h-5)
    screen:print("Stop code: average windows experience")
    screen:setCursorPos(1,h)
    screen:print("Press any key to continue... jk reboot it yourself lazy")
    while true do end
end

kernel.log("Kernel loaded.", "INFO")
kernel.log("Mounting disks...", "INFO")
disks.refresh()
ifs.update(disks)
ifs.mount("$", "/")

function kernel.saveLog()
    ifs.writeAllText("/var/log/syslog.log", LOG_Text)
end

local fstab=ifs.readAllText("/etc/fstab")
local split = function(str, delim, maxResultCountOrNil)
    assert(#delim == 1, "only delim len 1 supported for now")
    maxResultCountOrNil = (maxResultCountOrNil or 0)-1
    local rv = {}
    local buf = ""
    for i = 1, #str do
        local c = string.sub(str,i,i)
        if #rv ~= maxResultCountOrNil and c == delim then
            table.insert(rv, buf)
            buf = ""
        else
            buf = buf..c
        end
    end
    table.insert(rv, buf)
    return rv
end

for i,v in ipairs(split(fstab,"\n")) do
    if v:sub(1,1)=="U" then
        local id=""
        for i=3,#v do
            if v:sub(i,i)==";" then
                if i==3 then kernel.log("Invalid fstab line... Skipping.","WARN") goto endline end
                id=v:sub(3,i-1)
            end
        end
        local path=v:sub(#id+4)
        kernel.log("Mounted "..id.." to "..path)
        ifs.mount(id,path)
        ::endline::
    end
end

ifs.remove("/tmp")
ifs.makeDir("/tmp")

local drivers={}
drivers.raw={}
drivers.processes={}
drivers.prior={}
drivers.type={}
for i=0, 99 do
    drivers.prior[i]={}
end

function drivers.register(prior,object)
    drivers.raw[#drivers.raw+1]=object
    if object.main then drivers.processes[#drivers.processes+1]=object.main end
    if drivers.prior[prior]==nil then drivers.prior[prior]={} end
    drivers.prior[prior][#drivers.prior[prior]+1]=object
    if drivers.type[object.type]==nil then drivers.type[object.type]={} end
    drivers.type[object.type][#drivers.type[object.type]+1]=object
end

local modules={}
for i=0, 99 do
    modules[i]={}
end

for i,v in ipairs(ifs.list("/lib/modules/Hyperion/")) do
    local prior=tonumber(v:sub(1,2))
    modules[prior][#modules[prior]+1]="/lib/modules/Hyperion/"..v
end

kernel.drivers=drivers
kernel.ifs=ifs
kernel.apis=apis
kernel.computer=computer
kernel.initPath=initPath
kernel.arch=arch
kernel.initdisks=initdisks
kernel.screen=screen
for _,p in ipairs(modules) do
    for _,v in ipairs(p) do
        local code=ifs.readAllText(v)
        local func,err=load(code,"@"..v)
        if not func then kernel.log("ModuLoadErr: "..tostring(err)) goto skip end
        local status, err = xpcall(func,debug.traceback,kernel)
        if not status then goto skip end
        if not err then goto skip end
        if not err.init then goto skip end
        local ok, err = xpcall(status.main,debug.traceback)
        if not ok then kernel.log("ModuInitErr: "..tostring(err)) end
        ::skip::
    end
end
kernel.PANIC("Execution complete")