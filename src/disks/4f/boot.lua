local disk = (...)[1] -- hopefully us
component.getFirst("bios").setData(disk:open("bios.lua").read())