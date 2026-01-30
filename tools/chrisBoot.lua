---@diagnostic disable: undefined-global
local diskpath="put your path here"
periphemu.create("right", "drive")
disk.insertDisk("right", diskpath)
local file = fs.open("/disk/boot/cct/eeprom", "r")
local text = file.readAll()
file.close()

local func = load(text, "@bios.lua")

---@diagnostic disable-next-line: need-check-nil
func("/disk")