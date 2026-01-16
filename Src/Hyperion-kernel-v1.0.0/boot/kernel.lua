--:Minify:--
local args = {...}
local apis = args[1]
local disks = args[2]
local arch = args[3]
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
kernel.status = "start"
kernel.key = {}
kernel.cache = {}
kernel.cache.preload = {}
kernel._G=_G
kernel.sleep=sleep

_G.sleep=nil
local windowsExp = false

function kernel.log(msg, level)
    LOG_Text = LOG_Text..tostring(computer:time()).." "..kernel.user.." "..kernel.process.."["..tostring(level or "INFO").."]: "..msg.."\n"
    if kernel.status == "start" then
        screen:print(tostring(computer:time()).." "..kernel.user.." "..kernel.process.."["..tostring(level or "INFO").."]: "..msg)
    elseif kernel.status == "init" then
        kernel.standbyTask=kernel.currentTask
        kernel.currentTask=kernel.kernelTask
        kernel.tty.print(tostring(computer:time()).." "..kernel.user.." "..kernel.process.."["..tostring(level or "INFO").."]: "..msg)
        kernel.currentTask=kernel.standbyTask
    end
end

function kernel.PANIC(msg)
    if kernel.status~="Panic" then
        kernel.log("PANIC: "..msg, "PANIC")
        pcall(kernel["saveLog"])
        kernel.status="Panic"
        kernel.reason=msg
        screen:setTextColor(2)
        screen:setBackgroundColor(0)
        screen:clear()
        screen:setCursorPos(1,1)
        screen:print(LOG_Text)
        screen:print("KERNEL PANIC!\n"..msg.."\nSystem halted.")
        screen:print("Press any key to continue...")
        kernel.exitMain = true
    end
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

kernel.log("Kernel loaded.")
kernel.log("Mounting init disks...")
disks.refresh()
ifs.update(disks)
kernel.disks={}
for _,v in disks.list() do
    kernel.disks[v.address] = v
end
ifs.mount("$", "/")

local fstab=ifs.readAllText("/boot/fstab")
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

if not ifs.isFile("/boot/boot.cfg") then
    kernel.log("boot.cfg missing or corrupted!, Attempting to write recovery boot.cfg", "ERROR")
    ifs.writeAllText("/boot/boot.cfg",ifs.readAllText("/boot/safeboot.cfg"))
end

local initCfgFunc, err = load(ifs.readAllText("/boot/boot.cfg"), "@boot.cfg")
if not initCfgFunc then
    kernel.PANIC("Failed to load /boot/boot.cfg: "..tostring(err))
end

---@diagnostic disable-next-line: param-type-mismatch
local initCfgStatus, config = pcall(initCfgFunc)
if not initCfgStatus then
    kernel.PANIC("Error in /boot/boot.cfg: "..tostring(config))
end
kernel.config = config

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
        ifs.mount(id,path)
        ::endline::
    end
end
kernel.log("Disks initialized")

function kernel.saveLog()
    ifs.writeAllText("/var/log/syslog.log", LOG_Text)
end

ifs.remove("/tmp")
ifs.makeDir("/tmp")

function kernel.newFifo()
    local fifo = {}
    fifo.push=function(data)
        table.insert(fifo, data)
    end
    fifo.pop=function()
        return table.remove(fifo,1)
    end
    return fifo
end

function kernel.newUUID()
    local template = "xxxxxxxx-xxxx-4xxx-yxxx-xxxxxxxxxxxx"
    local uuid = ""
    for i = 1, #template do
        local c = template:sub(i,i)
        if c == "x" then
            uuid = uuid .. string.format("%x", math.random(0, 15))
        elseif c == "y" then
            uuid = uuid .. string.format("%x", math.random(8, 11))
        else
            uuid = uuid .. c
        end
    end
    return uuid
end

kernel.syscalls={}
local modules={[0]={}}
for i=0, 100 do
    modules[i]={}
end

kernel.log("Gathering modules")
for _, i in ipairs(ifs.list("/lib/modules")) do
    for _,v in ipairs(ifs.list("/lib/modules/"..i)) do
        local prior=tonumber(v:sub(1,2))
        modules[prior+1][#modules[prior+1]+1]="/lib/modules/"..i.."/"..v
    end
end

kernel.ifs=ifs
kernel.apis=apis
kernel.computer=computer
kernel.arch=arch
kernel.initdisks=disks
kernel.screen=screen
kernel.processes={}
kernel.fstab=fstab

kernel.kernelTask = {
    name="kernel",
    status="R",
    pid=0,
    tgid=0,
    user="root",
    uid=0,
    fd={},
    exit="",
    sleep=0,
    ivs=0,
    vs=0,
    children={},
    syscallReturn={},
    cwd="/",
    timeSlice=0,
    lastTime=0,
    totalTime=0,
    numRuns=0
}
kernel.currentTask = kernel.kernelTask

function kernel.shutdown()
    kernel.computer:shutdown()
end

function kernel.reboot()
    kernel.computer:reboot()
end

kernel.syscalls["OS_time"]=function() return kernel.computer:time() end
kernel.syscalls["OS_log"]=kernel.log

kernel.log("Running modules")
for _,p in ipairs(modules) do
    for _,v in ipairs(p) do
        local code=ifs.readAllText(v)
        if not code then 
            kernel.log("ModuReadErr: "..v, "WARN") 
            goto skip
        end
        local func,err=load(code,"@"..v)
        if not func then kernel.panic("ModuLoadErr: "..tostring(err)) goto skip end
        local status, err = xpcall(func,debug.traceback, kernel)
        if not status then kernel.panic("ModuRunErr: "..tostring(err)) end
        ::skip::
    end
end

kernel.log("Kernel initialized successfully.")
kernel.status="running"
kernel.main()
if kernel.status=="panic" then
    kernel.panic()
end
kernel.PANIC("Execution complete")