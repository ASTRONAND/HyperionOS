term.clear()
term.setCursorPos(1,1)
print("HyperionOS CCT Installer //")
local w,h = term.getSize()
local install,releasename=function()end,""
local exitall=false

local function download(url)
    shell.run("wget "..url.." /tmp/download")
    local lib = require("tmp.download")
    fs.delete("/tmp/download")
    return lib
end

print("Installing JSON...")
local json = download("https://git.astronand.dev/Hyperion/HyperionOS/raw/branch/main/misc/install/data/json")

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
    while not exit or not exitall do
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
    local raw=http.get("https://git.astronand.dev/api/v1/repos/Hyperion/HyperionOS/releases?page="..tostring(page).."&limit=1")
    if raw=="[]" then
        break
    end
    releases[#releases+1]=json.decode(raw)[1]
end

local function makePage(start, num)
    local m,nonext={},false
    for i=start, num do
        if not releases[i] then nonext=true; break end
        local release=releases[i]
        m[#m+1]={
            name=release.name,
            desc=release.body,
            color=release.prerelease and colors.orange or colors.white,
            func=function()
                local data, err=http.get("https://git.astronand.dev/Hyperion/HyperionOS/raw/tag/"..release.tag_name.."/misc/cct/installcc.lua")
                releasename=release.tag_name
                if not data then
                    term.clear()
                    term.setCursorPos(1,1)
                    print("Unable to install "..release.tag_name..":\n"..err)
                    sleep(3)
                    return
                end
                local func, err = load(data.readAll(), "@Installer")
                if not func then
                    term.clear()
                    term.setCursorPos(1,1)
                    print("Unable to load Installer "..release.tag_name..":\n"..err)
                    sleep(3)
                    return
                end
                install=func
            end
        }
    end
    if not nonext then
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
end

menu(makePage(1,5))
term.clear()
term.setCursorPos(1,1)
term.setTextColor(colors.white)
term.write("Formating disk in ")
for i=5, 0, -1 do
    term.write(tostring(i))
    sleep(.25)
    for v=1, 3 do
        term.write(".")
        sleep(.25)
    end
end

local function printc(text, c)
    term.setTextColor(c)
    print(text)
end

local function delDir(dir)
    printc("ls "..dir, colors.green)
    local list=fs.list(dir)
    printc("rm -rf "..dir, colors.red)
    for i=1, #list do
        if fs.isDir(dir..list[i]) then
            if dir..list[i] ~= "/rom" then
                delDir(dir..list[i].."/")
                fs.delete(dir..list[i])
            end
        else
            fs.delete(dir..list[i])
            printc("rm "..dir..list[i], colors.orange)
        end
    end
end

delDir("/")
install(releasename)