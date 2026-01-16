local fs = require("sys.fs")
local stuff = fs.list("")
for i,v in ipairs(stuff) do
    if fs.isDir(v) then
        print(v.."/")
    else
        print(v)
    end
end