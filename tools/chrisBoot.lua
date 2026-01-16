local file = fs.open("/disk/boot/cct/eeprom")
local text = file.readAll()
file.close()

local func = load(text, "@bios.lua")

func()