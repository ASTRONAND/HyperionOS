-- Minimal ISO9660 parser
-- Provides: ISO.open(path) -> iso object
-- Methods: :close(), :readPVD(), :listRoot(), :readFile(path)

local M = {}

local SECTOR_SIZE = 2048

local function readBytes(f, pos, len)
    f:seek("set", pos)
    return f:read(len)
end

local function u8(s, i)
    return string.byte(s, i)
end

local function u16le(s, i)
    local b1 = string.byte(s, i)
    local b2 = string.byte(s, i+1)
    return b1 + b2 * 256
end

local function u32le(s, i)
    local b1 = string.byte(s, i)
    local b2 = string.byte(s, i+1)
    local b3 = string.byte(s, i+2)
    local b4 = string.byte(s, i+3)
    return b1 + b2*256 + b3*65536 + b4*16777216
end

local function trimVersion(name)
    -- remove ;1 version and trailing dots
    local n = name:gsub(";1$", "")
    n = n:gsub("%.$", "")
    return n
end

local ISO = {}
ISO.__index = ISO

function M.open(path)
    local f, err = io.open(path, "rb")
    if not f then return nil, err end
    local self = setmetatable({ f = f, path = path }, ISO)
    return self
end

function ISO:close()
    if self.f then self.f:close(); self.f = nil end
end

function ISO:readSector(n)
    local pos = n * SECTOR_SIZE
    return readBytes(self.f, pos, SECTOR_SIZE)
end

function ISO:readPVD()
    -- Primary Volume Descriptor at sector 16 (index 16)
    local pvd = self:readSector(16)
    if not pvd or #pvd < SECTOR_SIZE then return nil, "cannot read PVD" end
    local typecode = u8(pvd,1)
    local id = pvd:sub(2,6)
    if typecode ~= 1 or id ~= "CD001" then return nil, "no primary volume descriptor" end

    local volumeIdentifier = pvd:sub(41,72):gsub('%z+$','')
    -- root directory record starts at offset 157 (1-based index)
    local rdOffset = 157
    local rdLen = u8(pvd, rdOffset)
    local extent = u32le(pvd, rdOffset + 2)
    local dataLen = u32le(pvd, rdOffset + 10)

    self.pvd = {
        volumeIdentifier = volumeIdentifier,
        root = { extent = extent, size = dataLen }
    }
    return self.pvd
end

local function parseDirRecords(buffer, bytesToRead)
    local records = {}
    local offset = 1
    local total = bytesToRead or #buffer
    while offset <= total do
        local len = string.byte(buffer, offset)
        if not len or len == 0 then
            -- padding to sector boundary, move to next byte
            offset = offset + 1
        else
            local rec = {}
            rec.len = len
            rec.extAttrLen = string.byte(buffer, offset+1)
            rec.extent = u32le(buffer, offset+2)
            rec.size = u32le(buffer, offset+10)
            rec.recordingDate = buffer:sub(offset+18, offset+24)
            rec.flags = string.byte(buffer, offset+25)
            rec.fileUnitSize = string.byte(buffer, offset+26)
            rec.interleaveGapSize = string.byte(buffer, offset+27)
            rec.volumeSeq = u16le(buffer, offset+29)
            local fiLen = string.byte(buffer, offset+32)
            local idStart = offset + 33
            local idEnd = idStart + fiLen - 1
            local fileId = buffer:sub(idStart, idEnd)
            -- strip trailing ;1 and dots
            rec.fileIdentifier = fileId
            rec.fileName = trimVersion(fileId)
            rec.isDirectory = (rec.flags & 0x02) ~= 0
            table.insert(records, rec)
            offset = offset + len
        end
    end
    return records
end

function ISO:listRoot()
    if not self.pvd then self:readPVD() end
    local root = self.pvd.root
    local extent = root.extent
    local size = root.size
    local pos = extent * SECTOR_SIZE
    local buffer = readBytes(self.f, pos, size)
    local records = parseDirRecords(buffer, size)
    -- filter out '.' and '..' and entries with empty name
    local out = {}
    for _, r in ipairs(records) do
        local name = r.fileName
        if name and name ~= "" and name ~= "\0" and name ~= "\1" and name ~= "." and name ~= ".." then
            table.insert(out, { name = name, isDirectory = r.isDirectory, extent = r.extent, size = r.size })
        end
    end
    return out
end

local function splitPath(path)
    local parts = {}
    for part in path:gmatch('[^/\\]+') do parts[#parts+1]=part end
    return parts
end

function ISO:findEntryByPath(path)
    if not self.pvd then self:readPVD() end
    local parts = splitPath(path)
    local curExtent = self.pvd.root.extent
    local curSize = self.pvd.root.size
    for i, part in ipairs(parts) do
        -- read directory entries for curExtent
        local buffer = readBytes(self.f, curExtent * SECTOR_SIZE, curSize)
        local records = parseDirRecords(buffer, curSize)
        local found = nil
        for _, r in ipairs(records) do
            local name = trimVersion(r.fileIdentifier)
            if name:lower() == part:lower() then
                found = r; break
            end
        end
        if not found then return nil, "path not found: " .. part end
        if i < #parts then
            if not found.isDirectory then return nil, "not a directory: "..part end
            curExtent = found.extent
            curSize = found.size
        else
            return found
        end
    end
    return nil, "empty path"
end

function ISO:readFile(path)
    local rec, err = self:findEntryByPath(path)
    if not rec then return nil, err end
    if rec.isDirectory then return nil, "path is a directory" end
    local pos = rec.extent * SECTOR_SIZE
    return readBytes(self.f, pos, rec.size)
end

-- return module
return M
