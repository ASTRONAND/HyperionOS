--:Minify:--
local apis=...
local keys=apis.keys
local tKeys = {}
tKeys[keys.space] = ' '
tKeys[keys.grave] = '`'
tKeys[keys.comma] = ','
tKeys[keys.minus] = '-'
tKeys[keys.period] = '.'
tKeys[keys.slash] = '/'
tKeys[keys.zero] = '0'
tKeys[keys.one] = '1'
tKeys[keys.two] = '2'
tKeys[keys.three] = '3'
tKeys[keys.four] = '4'
tKeys[keys.five] = '5'
tKeys[keys.six] = '6'
tKeys[keys.seven] = '7'
tKeys[keys.eight] = '8'
tKeys[keys.nine] = '9'
tKeys[keys.semicolon or keys.semiColon] = ';'
tKeys[keys.equals] = '='
tKeys[keys.a] = 'a'
tKeys[keys.b] = 'b'
tKeys[keys.c] = 'c'
tKeys[keys.d] = 'd'
tKeys[keys.e] = 'e'
tKeys[keys.f] = 'f'
tKeys[keys.g] = 'g'
tKeys[keys.h] = 'h'
tKeys[keys.i] = 'i'
tKeys[keys.j] = 'j'
tKeys[keys.k] = 'k'
tKeys[keys.l] = 'l'
tKeys[keys.m] = 'm'
tKeys[keys.n] = 'n'
tKeys[keys.o] = 'o'
tKeys[keys.p] = 'p'
tKeys[keys.q] = 'q'
tKeys[keys.r] = 'r'
tKeys[keys.s] = 's'
tKeys[keys.t] = 't'
tKeys[keys.u] = 'u'
tKeys[keys.v] = 'v'
tKeys[keys.w] = 'w'
tKeys[keys.x] = 'x'
tKeys[keys.y] = 'y'
tKeys[keys.z] = 'z'
tKeys[keys.leftBracket] = '['
tKeys[keys.backslash] = '\\'
tKeys[keys.rightBracket] = ']'
tKeys[keys.apostrophe] = "'"
tKeys[keys.enter] = '\n'
tKeys[keys.tab] = '\t'
tKeys[keys.backspace] = '\b'
tKeys[keys.insert] = '\x1b[2~'
tKeys[keys.delete] = '\x1b[3~'
tKeys[keys.right] = '\x1b[C'
tKeys[keys.left] = '\x1b[D'
tKeys[keys.down] = '\x1b[B'
tKeys[keys.up] = '\x1b[A'
tKeys[keys.pageUp] = '\x1b[5~'
tKeys[keys.pageDown] = '\x1b[6~'
tKeys[keys.home] = '\x1b[1~'
tKeys[keys["end"]] = '\x1b[4~'
tKeys[keys.capsLock] = '\x1b[capsLock'
tKeys[keys.scrollLock] = '\x1b[scrollLock'
tKeys[keys.numLock] = '\x1b[numLock'
if keys.printScreen then
    tKeys[keys.printScreen] = '\x1b[printScreen'
end
tKeys[keys.pause] = '\x1b[pause'
tKeys[keys.f1] = '\x1b[11~'
tKeys[keys.f2] = '\x1b[12~'
tKeys[keys.f3] = '\x1b[13~'
tKeys[keys.f4] = '\x1b[14~'
tKeys[keys.f5] = '\x1b[15~'
tKeys[keys.f6] = '\x1b[17~'
tKeys[keys.f7] = '\x1b[18~'
tKeys[keys.f8] = '\x1b[19~'
tKeys[keys.f9] = '\x1b[20~'
tKeys[keys.f10] = '\x1b[21~'
tKeys[keys.f11] = '\x1b[23~'
tKeys[keys.f12] = '\x1b[24~'
--tKeys[keys.f13] = '\x1b[25~'
--tKeys[keys.f14] = '\x1b[26~'
--tKeys[keys.f15] = '\x1b[28~'
--tKeys[keys.f16] = '\x1b[29~'
--tKeys[keys.f17] = '\x1b[31~'
--tKeys[keys.f18] = '\x1b[32~'
--tKeys[keys.f19] = '\x1b[33~'
--tKeys[keys.f20] = '\x1b[34~'
--tKeys[keys.f21] = '\x1b[42~'
--tKeys[keys.f22] = '\x1b[43~'
--tKeys[keys.f23] = '\x1b[44~'
--tKeys[keys.f24] = '\x1b[45~'
--tKeys[keys.f25] = '\x1b[46~'

-- Numpad
tKeys[keys.numPad0] = '0'
tKeys[keys.numPad1] = '1'
tKeys[keys.numPad2] = '2'
tKeys[keys.numPad3] = '3'
tKeys[keys.numPad4] = '4'
tKeys[keys.numPad5] = '5'
tKeys[keys.numPad6] = '6'
tKeys[keys.numPad7] = '7'
tKeys[keys.numPad8] = '8'
tKeys[keys.numPad9] = '9'

--tKeys[340] = 'leftShift'
--tKeys[341] = 'leftCtrl'
--tKeys[342] = 'leftAlt'
--tKeys[343] = 'leftSuper'
--tKeys[344] = 'rightShift'
--tKeys[345] = 'rightCtrl'
--tKeys[346] = 'rightAlt'
--tKeys[347] = 'rightSuper'
--tKeys[348] = 'menu'

local shift = false
local ctrl = false
local alt = false

local function s(char)
    if not shift then return char end
    -- Letters
    if char == "a" then return "A" end
    if char == "b" then return "B" end
    if char == "c" then return "C" end
    if char == "d" then return "D" end
    if char == "e" then return "E" end
    if char == "f" then return "F" end
    if char == "g" then return "G" end
    if char == "h" then return "H" end
    if char == "i" then return "I" end
    if char == "j" then return "J" end
    if char == "k" then return "K" end
    if char == "l" then return "L" end
    if char == "m" then return "M" end
    if char == "n" then return "N" end
    if char == "o" then return "O" end
    if char == "p" then return "P" end
    if char == "q" then return "Q" end
    if char == "r" then return "R" end
    if char == "s" then return "S" end
    if char == "t" then return "T" end
    if char == "u" then return "U" end
    if char == "v" then return "V" end
    if char == "w" then return "W" end
    if char == "x" then return "X" end
    if char == "y" then return "Y" end
    if char == "z" then return "Z" end
    -- Symbols
    if char == "`" then return "~" end
    if char == "1" then return "!" end
    if char == "2" then return "@" end
    if char == "3" then return "#" end
    if char == "4" then return "$" end
    if char == "5" then return "%" end
    if char == "6" then return "^" end
    if char == "7" then return "&" end
    if char == "8" then return "*" end
    if char == "9" then return "(" end
    if char == "0" then return ")" end
    if char == "-" then return "_" end
    if char == "=" then return "+" end
    if char == "[" then return "{" end
    if char == "]" then return "}" end
    if char == "\\" then return "|" end
    if char == ";" then return ":" end
    if char == "'" then return '"' end
    if char == "," then return "<" end
    if char == "." then return ">" end
    if char == "/" then return "?" end
    return char or ""
end

local function p()
    local str = ""
    if alt then
        str=str.."\x1b"
    end
    if ctrl then
        str=str.."^"
    end
    return str
end

return function(event, q)
    if event[1] == "key" then
        if event[2]==keys.leftCtrl or event[2]==keys.rightCtrl then ctrl=true return
        elseif event[2]==keys.leftAlt or event[2]==keys.rightAlt then alt=true return
        elseif event[2]==keys.leftShift or event[2]==keys.rightCtrl then shift=true return
        end
        q("keyTyped", 1, p()..s(tKeys[event[2]]))
    elseif event[1] == "key_up" then
        if event[2]==keys.leftCtrl or event[2]==keys.rightCtrl then ctrl=false return
        elseif event[2]==keys.leftAlt or event[2]==keys.rightAlt then alt=false return
        elseif event[2]==keys.leftShift or event[2]==keys.rightCtrl then shift=false return
        end
    end
end