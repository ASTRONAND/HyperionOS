local biosData = ({...})[1]
local disks = {}

for i,v in component.list() do
    if i == "disk" then
        disks[v.id]=v
    end
end

local bootDisk = disks[biosData.bootDrive.open("/config").read()]

if not bootDisk.type=="udd" then
    error("invalid")
end