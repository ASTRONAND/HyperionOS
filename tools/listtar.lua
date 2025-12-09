-- tar_list.lua
-- List all paths stored in a TAR file (no extraction)

local function octal_to_number(str)
    str = str:gsub("%z", ""):match("^%s*(.-)%s*$")
    return tonumber(str, 8) or 0
end

local file = ({...})[1]
if not file then
    print("Usage: tar_list <tarfile>")
    return
end

local f = fs.open(file, "r")
local tar = f.readAll()
f.close()

local i = 1
local len = #tar

while i + 512 <= len do
    local header = tar:sub(i, i + 511)

    if header:match("^\0+$") then break end

    -- Extract raw name & prefix
    local name  = header:sub(1, 100):gsub("%z.*","")
    local prefix = header:sub(346, 500):gsub("%z.*","")

    local size = octal_to_number(header:sub(125, 136))
    i = i + 512

    -- Skip file contents
    local pad = (512 - (size % 512)) % 512
    i = i + size + pad

    local full
    if prefix ~= "" then
        full = prefix .. "/" .. name
    else
        full = name
    end

    -- Print exactly what Windows Explorer stored
    print(full)
end
