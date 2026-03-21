term.clear()
term.setTextColor(colors.white)
term.setCursorPos(1,1)
print("HyperionOS CCT Installer //")
local w,h = term.getSize()
local exitall,releasename,packagelist=false,"",{}

local function printc(...)
    local args={...}
    for i=1, #args do
        if type(args[i]) == "number" then
            term.setTextColor(args[i])
        else
            term.write(args[i])
        end
    end
    print("")
end

local function download(url)
    printc(colors.gray, "[ ", colors.green, " FETCH ", colors.gray, " ] ", colors.white, url)
    local data,err=http.get(url)
    if not data then error(err) end
    local text=data.readAll()
    data.close()
    return text
end

local function writeFile(path, data)
    printc(colors.gray, "[ ", colors.green, "WRITING", colors.gray, " ] ", colors.white, path)
    local file=fs.open(path, "w")
    file.write(data)
    file.close()
end

print("Installing JSON to /hyinstall/json...")
writeFile("/hyinstall/json",download("https://git.astronand.dev/Hyperion/HyperionOS/raw/branch/main/misc/json"))
print("Loading JSON...")
local json=loadfile("/hyinstall/json")()

local function printTitle()
    term.clear()
    term.setCursorPos(1,1)
    term.setTextColor(colors.white)
    print("HyperionOS CCT Installer //")
    print("Orange is prerelease...")
    term.setCursorPos(1,h-1)
    print("DESCLAIMER: This will wipe your system on install...")
    term.write("Bspc: Back | Enter: execute | Tab: description")
end
printTitle()

local function pc(text, y, c)
    local x=(w/2)-#text/2
    term.setTextColor(c)
    term.setCursorPos(x, y)
    term.write(text)
end

local function drawMenu(menu, sel)
    local y=(h/2)-#menu/2
    for i,v in ipairs(menu) do
        if i==sel then
            pc("[ "..v.name.." ]", y+i, v.color)
        else
            pc(v.name, y+i, v.color)
        end
    end
end

local function desc(description)
    term.clear()
    term.setTextColor(colors.white)
    term.setCursorPos(1,1)
    print("HyperionOS CCT Installer //\n")
    print(description)
    term.setCursorPos(1,h)
    term.write("Press enter to continue...")
    while not exitall do
        local _,key = os.pullEvent("key")
        if key==keys.enter then
            break
        end
    end
end

local function menu(m)
    local exit,sel=false,1
    while not exit and not exitall do
        printTitle()
        drawMenu(m, sel)
        local _,key = os.pullEvent("key")
        if key==keys.down then
            if sel<#m then
                sel=sel+1
            end
        elseif key==keys.up then
            if sel>1 then
                sel=sel-1
            end
        elseif key==keys.enter then
            m[sel].func()
        elseif key==keys.tab then
            desc(m[sel].desc)
        elseif key==keys.backspace then
            exit=true
        end
    end
end

local releases,page={},1
while true do
    local handle=http.get("https://git.astronand.dev/api/v1/repos/Hyperion/HyperionOS/releases?page="..tostring(page).."&limit=1")
    local raw=handle.readAll()
    handle.close()
    if raw=="[]\n" then
        break
    end
    releases[page]=json.decode(raw)[1]
    page=page+1
end

local function makePage(start, num)
    local m={}
    for i=start, num do
        if not releases[i] then break end
        local release=releases[i]
        m[#m+1]={
            name=release.name,
            desc=release.body,
            color=release.prerelease and colors.orange or colors.white,
            func=function()
                local data=download("https://git.astronand.dev/Hyperion/HyperionOS/raw/tag/"..release.tag_name.."/Src/install.json")
                if not data then
                    term.clear()
                    term.setCursorPos(1,1)
                    print("Unable to find package list for ver "..release.tag_name..":\n"..err)
                    sleep(3)
                    return
                end
                releasename=release.tag_name
                packagelist=json.decode(data)
                exitall=true
            end
        }
    end
    if #releases>start+num then
        m[#m+1]={
            name="Next",
            desc="Next menu",
            color=colors.cyan,
            func=function()
                local menudata=makePage(start+num, num)
                menu(menudata)
            end
        }
    end
    return m
end

menu(makePage(1,5))
term.clear()
term.setCursorPos(1,1)
term.setTextColor(colors.white)
term.write("Formating disk in ")
for i=5, 1, -1 do
    term.write(tostring(i))
    sleep(.25)
    for v=1, 3 do
        term.write(".")
        sleep(.25)
    end
end
print("")

local function delDir(dir)
    printc(colors.gray, "[ ", colors.green, " LSDIR ", colors.gray, " ] ", colors.white, dir)
    local list=fs.list(dir)
    printc(colors.gray, "[ ", colors.red, " DELET ", colors.gray, " ] ", colors.white, dir)
    for i=1, #list do
        if fs.isDir(dir..list[i]) then
            if dir..list[i] ~= "/rom" then
                delDir(dir..list[i].."/")
                fs.delete(dir..list[i])
            end
        else
            fs.delete(dir..list[i])
            printc(colors.gray, "[ ", colors.red, " DELET ", colors.gray, " ] ", colors.white, dir..list[i])
        end
        sleep(.1)
    end
end

delDir("/")

print("")
printc(colors.cyan, "       \\\\Installing//")
print("")
printc(colors.white, "Getting package list...")

local function installdir(path, dir, pkg)
    local data=json.decode(download("https://git.astronand.dev/api/v1/repos/Hyperion/HyperionOS/contents/prod/"..pkg..dir.."?ref="..releasename))
    if not data then error("Uh Oh: JSON decode error...") end
    for i=1, #data do
        local entry=data[i]
        if entry.type == "dir" then
            installdir(path, dir..entry.name.."/", pkg)
        elseif entry.type == "file" then
            writeFile(path..dir..entry.name, download(entry.download_url))
        else
            error("Uh Oh: unknown entrytype "..entry.path)
        end
    end
end

local function installpkg(pkg)
    installdir("/$", "/", pkg)
end

for i=1, #packagelist do
    installpkg(packagelist[i])
end

installpkg("Hyperion-firmware-cct")
fs.copy("/$/boot/cct/eeprom", "/startup.lua")

printc(colors.white, "Rebooting...")
sleep(1)
os.reboot()