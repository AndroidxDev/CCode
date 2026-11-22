LANG, STR = {}, {}

CLASS = require 'Data.class'
THEMES = require 'Data.themes'
ADS = require 'plugin.unityads.v4'
CLIENT = require 'Network.client'
SERVER = require 'Network.server'
APPMETRICA = require 'plugin.appmetrica'
RENDER = require 'Core.Simulation.render'
NOTIFICATIONS = require 'plugin.notifications.v2'
PARTICLE = require 'Emitter.particleDesigner'
NOISE = require 'Core.Modules.noise'
CAMERA = require 'Core.Modules.camera'
RESIZE = require 'Core.Modules.app-resize'
INPUT = require 'Core.Modules.interface-input'
WINDOW = require 'Core.Modules.interface-window'
EXITS = require 'Core.Interfaces.exits'
BITMAP = require 'plugin.memoryBitmap'
FILE = require 'plugin.cnkFileManager'
FILEPICKER = require 'plugin.androidFilePicker'
EXPORT = require 'plugin.exportFile'
ORIENTATION = require 'plugin.orientation'
IMPACK = require 'plugin.impack'
SVG = require 'plugin.nanosvg'
UTF8 = require 'plugin.utf8'
ZIP = require 'plugin.zip'
PHYSICS = require 'physics'
JSON = require 'json'
LFS = require 'lfs'
WIDGET = require 'widget'
CRYPTO = require 'crypto'
MIME = require 'mime'

PASTEBOARD = {
    copy = function(_, text) GANIN.pasteboardCopy(text) end,
    clear = function() GANIN.pasteboardClear() end,
    paste = function(listener) GANIN.pasteboardPaste(listener) end
}

SIZE = 1.0
BUFFER = {}
LIVE = false
ALERT = true
INDEX_LIST = 0
SEED = os.time()
NOOBMODE = false
MORE_LIST = true
BUFFER_EVENT = {}
LAST_CHECKBOX = 0
ORIENTATION.init()
BLOCK_CENTER_X = 0
CURRENT_SCRIPT = 0
GAME_GROUP_OPEN = ''
CURRENT_LINK = 'App1'
LAST_CURRENT_SCRIPT = 0
DEVICE_ID = 'qwertyuiop12345'
CURRENT_ORIENTATION = 'portrait'
CENTER_X = display.contentCenterX
CENTER_Y = display.contentCenterY
DISPLAY_WIDTH = display.actualContentWidth
DISPLAY_HEIGHT = display.actualContentHeight
IS_WIN = system.getInfo 'platform' ~= 'android'
IS_SIM = system.getInfo 'environment' == 'simulator'
DOC_DIR = system.pathForFile('', system.DocumentsDirectory)
BUILD = (not IS_SIM and not IS_WIN) and system.getInfo('androidAppVersionCode') or 1387
MY_PATH = '/data/data/' .. tostring(system.getInfo('androidAppPackageName')) .. '/files/ganin'
RES_PATH = '/data/data/' .. tostring(system.getInfo('androidAppPackageName')) .. '/files/coronaResources'
MASK = graphics.newMask('Sprites/mask.png')
SOLAR = _G.B .. _G.D .. _G.A .. _G.C
KEYORDER = {
    'build', 'version', 'package', 'orientation', 'title', 'link', 'resources', 'scripts',
    'settings', 'fonts', 'others', 'videos', 'sounds', 'images', 'funs', 'tables',
    'len', 'vars', 'name', 'custom', 'event', 'nested', 'comment', 'params', 'created', 'folders',
    'face', 'eyes', 'ears', 'mouth', 'accessories'
} for i = 10000, 1, -1 do table.insert(KEYORDER, 1, tostring(i)) end

ADS.setPrivacyMode('mixed')
ADS.setPersonalizedAds(true)

ADS.showAd = function()
    if ADS.isLoaded('AndroidVideo') then
        ADS.show('AndroidVideo')
    else
        ADS.load('AndroidVideo')
    end
end

GET_SAFE_AREA = function()
    TOP_HEIGHT, LEFT_HEIGHT, BOTTOM_HEIGHT, RIGHT_HEIGHT = display.getSafeAreaInsets()
    BOTTOM_HEIGHT = (system.getInfo('deviceID') == 'd5e815039ddf2736' and 90 or BOTTOM_HEIGHT) + LOCAL.bottom_height
    ZERO_X = CENTER_X - DISPLAY_WIDTH / 2 + LEFT_HEIGHT
    ZERO_Y = CENTER_Y - DISPLAY_HEIGHT / 2 + TOP_HEIGHT
    MAX_X = CENTER_X + DISPLAY_WIDTH / 2 - RIGHT_HEIGHT
    MAX_Y = CENTER_Y + DISPLAY_HEIGHT / 2 - BOTTOM_HEIGHT
end

if IS_SIM or IS_WIN then
    FILEPICKER = require 'plugin.tinyfiledialogs'

    FILE.pickFile = function(path, listener, file, p1, mime)
        local filter_patterns = mime == 'image/*' and {'*.png', '*.jpg', '*.jpeg', '*.gif'}
        or mime == 'audio/*' and {'*.wav', '*.mp3', '*.ogg'} or mime == 'ccode/*' and {'*.ccode', '*.zip'}
        or mime == 'text/x-lua' and {'*.lua', '*.txt'} or mime == 'video/*' and {'*.mov', '*.mp4', '*.m4v', '*.3gp'} or nil
        local pathToFile, path = path .. '/' .. file, FILEPICKER.openFileDialog({filter_patterns = filter_patterns})
        if path then OS_COPY(path, pathToFile) end listener({done = path and 'ok' or 'error', origFileName = path})
    end

    EXPORT.export = function(config)
        local path, listener = config.path, config.listener
        local pathToFile = FILEPICKER.saveFileDialog({filter_patterns = {'*.ccode'}})
        if path then OS_COPY(path, pathToFile) end listener()
    end
end

if IS_SIM or IS_WIN then
    GANIN = {
        az = function() end,
        relaunch = function() end,
        perm = function() end,
        bluetooth = function() end,
        path = function() return '/data/data' end,
        webview = function(listener) listener() end,
        widgets = function() return '' end,
        za = function() end
    }
else
    GANIN = require 'plugin.ganin'
end

if (not IS_SIM) and (not LIVE) then
    require('Core.Share.build').reset()

    FILE.pickFile = function(path, listener, file, p1, mime)
        FILEPICKER.show(mime, path .. '/' .. file, function(e)
            listener({done = e.isError and 'error' or 'ok', origFileName = e.filename})
        end)
    end
end

function encodeURIComponent(str)
    if str then
        local safe = {
            ['-'] = true, ['_'] = true, ['.'] = true, ['!'] = true,
            ['~'] = true, ['*'] = true, ['\''] = true, ['('] = true, [')'] = true
        }
        local function toHex(char)
            return string.format('%%%02X', string.byte(char))
        end
        local result = {}
        for i = 1, #str do
            local char = str:sub(i, i)
            if char:match('[a-zA-Z0-9]') or safe[char] then
                table.insert(result, char)
            else
                table.insert(result, toHex(char))
            end
        end
        return table.concat(result)
    end
    return nil
end

GET_NESTED_DATA = function(script, nestedInfo, INFO)
    local script = COPY_TABLE(script)

    for i = #nestedInfo, 1, -1 do
        local current_params = nestedInfo[i]

        if script.params[current_params].event then
            local fixIndex = current_params + 1

            for j = fixIndex, #script.params do
                if script.params[fixIndex].event then break end
                table.insert(script.params[current_params].nested, script.params[fixIndex])
                table.remove(script.params, fixIndex)
            end
        elseif INFO.listNested[script.params[current_params].name] then
            local endIndex = #INFO.listNested[script.params[current_params].name]
            local fixIndex = current_params + 1
            local nestedEndIndex = 1

            for j = fixIndex, #script.params do
                if not script.params[fixIndex].event then
                    local name = script.params[fixIndex].name
                    local notNested = not (script.params[fixIndex].nested
                    and #script.params[fixIndex].nested > 0)
                    table.insert(script.params[current_params].nested, script.params[fixIndex])
                    table.remove(script.params, fixIndex)

                    if name == script.params[current_params].name and notNested then
                        nestedEndIndex = nestedEndIndex + 1
                    elseif name == INFO.listNested[script.params[current_params].name][endIndex] then
                        nestedEndIndex = nestedEndIndex - 1
                        if nestedEndIndex == 0 then break end
                    end
                else
                    fixIndex = fixIndex + 1
                end
            end
        end
    end

    return script
end

GET_FULL_DATA = function(script)
    local script, nestedInfo = COPY_TABLE(script), {}
    local blockIndex = 0

    while blockIndex < #script.params do
        blockIndex = blockIndex + 1

        if script.params[blockIndex].nested and #script.params[blockIndex].nested > 0 then
            table.insert(nestedInfo, blockIndex)

            for j = 1, #script.params[blockIndex].nested do
                local blockIndex, blockData = blockIndex + j, script.params[blockIndex].nested[j]
                table.insert(script.params, blockIndex, blockData)
            end

            script.params[blockIndex].nested = {}
        end
    end

    return script, nestedInfo
end

GET_GL_NUM = function(name)
    return ({
        GL_ZERO = 0,
        GL_ONE = 1,
        GL_DST_COLOR = 774,
        GL_ONE_MINUS_DST_COLOR = 775,
        GL_SRC_ALPHA = 770,
        GL_ONE_MINUS_SRC_ALPHA = 771,
        GL_DST_ALPHA = 772,
        GL_ONE_MINUS_DST_ALPHA = 773,
        GL_SRC_ALPHA_SATURATE = 776,
        GL_SRC_COLOR = 768,
        GL_ONE_MINUS_SRC_COLOR = 769
    })[name] or 0
end

GIVE_PERMISSION_DATA = function()
    GANIN.perm()
end

GET_SCROLL_HEIGHT = function(group)
    if not (group and #group.blocks > 0) then return 0 end

    local b1 = group.blocks[1].y - group.blocks[1].block.height / 2
    local b2 = group.blocks[#group.blocks].y + group.blocks[#group.blocks].block.height / 2

    return math.abs(b1 - b2) + 100
end

READ_FILE = function(path, bin)
    local file, data = io.open(path or '', bin and 'rb' or 'r'), nil

    if file then
        data = file:read('*a')
        io.close(file)
    end

    return data
end

WRITE_FILE = function(path, data, bin)
    local file = io.open(path, bin and 'wb' or 'w')

    if file then
        file:write(tostring(data))
        io.close(file)
    end
end

IS_FOLDER = function(path)
    return LFS.attributes(path, 'mode') == 'directory'
end

IS_IMAGE = function(path, filter)
    display.setDefault('magTextureFilter', filter) display.setDefault('minTextureFilter', filter)
    local image = display.newImage2(path, system.DocumentsDirectory, 10000, 10000)
    local is_image = type(image) == 'table' and image.width > 0 and image.height > 0
    pcall(function() image:removeSelf() image = nil end) return is_image
end

IS_ZERO_TABLE = function(t)
    local result = true

    pcall(function()
        for key, value in pairs(t) do
            result = false
            break
        end
    end)

    return result
end

COPY_TABLE = function(t, isSim)
    local result = {}

    pcall(function() if t then
        for key, value in pairs(t) do
            if type(value) == 'table' and key ~= '_class' and key ~= '_tableListeners' then
                result[key] = COPY_TABLE(value, isSim)
            elseif (not isSim) or (key ~= '_tableListeners' and key ~= '_class') then
                result[key] = value
            end
        end
    end end)

    return result
end

COPY_TABLE_P = function(t, isSim)
    local result = {}

    pcall(function()
        if type(t[1]) == 'table' and #t == 1 then
            result = COPY_TABLE(t[1], isSim)
        else
            result = COPY_TABLE(t, isSim)
        end
    end)

    return result
end

GET_SIZE = function(path, baseDir, width, height, count)
    local onComplete, result = pcall(function()
        local image = display.newImage(path, baseDir)
        local width, height = image.width / count, image.height image:removeSelf()
        return {width, height, count}
    end) if onComplete then return result end return {width, height, count}
end

SET_X = function(x, obj)
    if obj and (obj._isGroup or obj._snapshot or obj._container) then return x end
    return type(x) == 'number' and ((obj and obj._scroll and GAME_widgets[obj._scroll]
    and GAME_widgets[obj._scroll].wtype == 'scroll')
    and x + GAME_widgets[obj._scroll].width / 2 or CENTER_X + x) or 0
end

SET_Y = function(y, obj)
    if obj and obj._isGroup then return type(y) == 'number' and ((obj and obj._scroll and GAME_widgets[obj._scroll]
    and GAME_widgets[obj._scroll].wtype == 'scroll') and 0 - y - CENTER_Y or 0 - y) or 0 end
    return type(y) == 'number' and (((obj and obj._scroll and GAME_widgets[obj._scroll]
    and GAME_widgets[obj._scroll].wtype == 'scroll') or (obj and (obj._snapshot or obj._container))) and 0 - y or CENTER_Y - y) or 0
end

GET_X = function(x, obj)
    if obj and (obj._isGroup or obj._snapshot or obj._container) then return x end
    return type(x) == 'number' and ((obj and obj._scroll and GAME_widgets[obj._scroll]
    and GAME_widgets[obj._scroll].wtype == 'scroll')
    and x - GAME_widgets[obj._scroll].width / 2 or x - CENTER_X) or 0
end

GET_Y = SET_Y

GUID = function()
    return ({('xxxxxxxx-xxxx-4xxx-yxxx-xxxxxxxxxxxx'):gsub('[xy]', function(c)
        local v = c == 'x' and math.random(0, 0xf) or math.random(8, 0xb)
        return ('%x'):format(v)
    end)})[1]
end

NEW_DATA = function()
    local saveData = COPY_TABLE(LOCAL) saveData.__table__.niocc__set = '<type \'function\' is not supported by JSON.>'
    WRITE_FILE(system.pathForFile('local.json', system.DocumentsDirectory), ENCRYPT(JSON.encode3(saveData)))
end

GET_GAME_CODE = function(link)
    return JSON.decode(READ_FILE(DOC_DIR .. '/' .. link .. '/game.json'))
end

SET_GAME_CODE = function(link, data)
    WRITE_FILE(DOC_DIR .. '/' .. link .. '/game.json', JSON.encode3(data, {keyorder = KEYORDER}))
end

GET_INDEX_SCRIPT = function(link)
    local numScript = 1 while true do if READ_FILE(DOC_DIR .. '/' .. link .. '/Scripts/Script' .. numScript)
    then numScript = numScript + 1 else break end end return numScript
end

DEL_GAME_SCRIPT = function(link, index, code)
    OS_REMOVE(DOC_DIR .. '/' .. link .. '/Scripts/Script' .. (code or GET_GAME_CODE(link)).scripts[index])
end

GET_GAME_SCRIPT = function(link, index, code)
    local code = code or GET_GAME_CODE(link)
    return code.scripts[index] and JSON.decode(READ_FILE(DOC_DIR .. '/' .. link .. '/Scripts/Script' .. code.scripts[index])) or nil
end

SET_GAME_SCRIPT = function(link, data, index, code)
    local code = code or GET_GAME_CODE(link) if not code.scripts[index] then
    local numScript = 1 while true do if READ_FILE(DOC_DIR .. '/' .. link .. '/Scripts/Script' .. numScript) then numScript = numScript + 1
    else table.insert(code.scripts, index, numScript) SET_GAME_CODE(link, code) break end end end
    WRITE_FILE(DOC_DIR .. '/' .. link .. '/Scripts/Script' .. code.scripts[index], JSON.encode3(data, {keyorder = KEYORDER}))
end

GET_GAME_CUSTOM = function()
    return JSON.decode(READ_FILE(DOC_DIR .. '/custom.json'))
end

SET_GAME_CUSTOM = function(data)
    WRITE_FILE(DOC_DIR .. '/custom.json', JSON.encode3(data, {keyorder = KEYORDER}))
end

GET_GAME_SAVE = function(link)
    return JSON.decode(READ_FILE(DOC_DIR .. '/' .. link .. '/save.json'))
end

SET_GAME_SAVE = function(link, data)
    WRITE_FILE(DOC_DIR .. '/' .. link .. '/save.json', JSON.encode(data))
end

OS_REMOVE = function(link, recur)
    if IS_SIM or IS_WIN then
        link = UTF8.gsub(link, '/', '\\')
        if recur then os.execute('rd /s /q "' .. link .. '"')
        else os.execute('del /q "' .. link .. '"') end
    else
        os.execute('rm -' .. (recur and 'rf' or 'f') .. ' "' .. link .. '"')
    end
end

OS_MOVE = function(link, link2)
    if IS_SIM or IS_WIN then
        link = UTF8.gsub(link, '/', '\\')
        link2 = UTF8.gsub(link2, '/', '\\')
        os.execute('move /y "' .. link .. '" "' .. link2 .. '"')
    else
        os.execute('mv -f "' .. link .. '" "' .. link2 .. '"')
    end
end

OS_COPY = function(link, link2, recur)
    if IS_SIM or IS_WIN then
        link = UTF8.gsub(link, '/', '\\')
        link2 = UTF8.gsub(link2, '/', '\\')
        os.execute('copy /y "' .. link .. '" "' .. link2 .. '"')
    elseif recur then
        os.execute('cp -rf "' .. link .. '" "' .. link2 .. '"')
    else
        os.execute('cp -f "' .. link .. '" "' .. link2 .. '"')
    end
end

GET_UNIX_MINUTE = function(listener)
    network.request('https://currentmillis.com/time/minutes-since-unix-epoch.php', 'GET', function(e)
        if not e.isError then
            listener(tonumber(e.response) or 0)
        else
            listener(0)
        end
    end)
end

ENCRYPT = function(text, isUn)
    return isUn and MIME.unb64(text or '') or MIME.b64(text or '')
end

ENCRYPT_SSL = function(text, isUn)
    return text
end

NEW_APP_CODE = function(title, link, checkbox)
    return {
        build = tostring(BUILD),
        created = tostring(BUILD),
        noobmode = checkbox,
        id = DEVICE_ID,
        title = title,
        link = link,
        tables = {},
        vars = {},
        funs = {},
        settings = {
            build = 1,
            version = '1.0',
            package = 'com.example.app' .. math.random(111111, 999999),
            orientation = 'portrait'
        },
        folders = {
            scripts = {{'1', {}, false}},
            levels = {{'1', {}, false}},
            images = {{'1', {}, false}},
            sounds = {{'1', {}, false}},
            videos = {{'1', {}, false}},
            others = {{'1', {}, false}},
            fonts = {{'1', {}, false}}
        },
        resources = {
            images = {},
            levels = {},
            sounds = {},
            videos = {},
            others = {},
            fonts = {}
        },
        scripts = {}
    }
end

audio.setVolume(1)
PHYSICS.setAverageCollisionPositions(true)
WIDGET.setTheme('widget_theme_android_holo_dark')
UNPACK = function(t) if #t > 0 then return unpack(t) end return t end
PHYSICS.setReportCollisionsInContentCoordinates(true) math.randomseed(SEED)
DEVELOPERS = {['Ganin'] = true, ['DanilNik'] = true, ['MikhailStudio'] = true}

JSON.encode3 = require('Data.json').encode
JSON.decode2, JSON.decode = JSON.decode, function(str) return type(str) == 'string' and (JSON.decode2(str) or {}) or nil end
math.factorial = function(num) if num == 0 then return 1 else return num * math.factorial(num - 1) end end
math.hex = function(hex) local r, g, b = hex:match('(..)(..)(..)') return {tonumber(r, 16), tonumber(g, 16), tonumber(b, 16)} end
UTF8.split = function(text, sep) local result = {} for s in text:gmatch('[^' .. sep .. ']+') do result[#result + 1] = s end return result end
UTF8.trim = function(s) return UTF8.gsub(UTF8.gsub(s, '^%s+', ''), '%s+$', '') end
UTF8.trimLeft = function(s) return UTF8.gsub(s, '^%s+', '') end
UTF8.trimRight = function(s) return UTF8.gsub(s, '%s+$', '') end
UTF8.trimFull = function(s) return UTF8.trim(UTF8.gsub(s, '%s+', ' ')) end
timer.new = function(sec, rep, lis) return timer.performWithDelay(sec, lis, rep) end
math.sum = function(...) local args, num = {...}, 0 for i = 1, #args do num = num + args[i] end return num end
math.getMaskBits = function(t) local s = 0 for j = 1, #t do s = s + math.getBit(t[j]) end return s end
math.getBit = function(i) return 2 ^ (i - 1) end
UTF8.toAscii, table.len, math.round, table.merge = function(text)
    local text = tostring(text) or '' local result = '' UTF8.gsub(text, '.',
    function(symbol) result = result .. '_' .. UTF8.byte(symbol) end) return result
end, function(t)
    return type(t) == 'table' and ((type(#t) == 'number' and #t > 0) and #t
    or (function() local i = 0 for k in pairs(t) do i = i + 1 end return i end)()) or 0
end, function(num, exp)
    if (not exp) or (not tonumber(exp)) then return tonumber(string.match(tostring(num), '(.*)%.')) or num
    else local isMinus, oldNum = tonumber(num) and tonumber(num) < 0, tonumber(num) or 0
    local exps, factor = string.match(tostring(num), '%.(.*)'), tonumber(exp) == 0 and '0.' or '0.0'
    if not exps then return num end for i = 1, tonumber(exp) - 1 do factor = factor .. '0' end factor = factor .. '5' num = tonumber(num)
    and num + factor or 0 exp = string.match(tostring(num), '%.(.*)') and string.match(tostring(num), '%.(.*)'):sub(1, tonumber(exp))
    or '0' num = string.match(tostring(num), '(.*)%.') or tostring(num) num = tonumber(num .. '.' .. exp)
    return isMinus and (oldNum > -0.5 and 0 or num - 1) or num end
end, function(t1, t2)
    for k, v in pairs(t2) do if (type(v) == 'table') and (type(t1[k] or false) == 'table')
    then table.merge(t1[k], t2[k]) else t1[k] = v end end return t1
end

dump = function(t)
    print(_G.type(t) == 'table' and JSON.prettify(t) or t)
end

display.newImage2, display.newImage = display.newImage, function(link, ...)
    local image = display.newImage2(link, ...)

    if image and not (type(image) == 'table' and image.width > 0 and image.height > 0) then
        local args = {...} image = SVG.newImage({
            filename = link, baseDir = args[1],
            x = type(args[1]) == 'userdata' and (args[2] or 0) or (args[1] or 0),
            y = type(args[1]) == 'userdata' and (args[3] or 0) or (args[2] or 0)
        })
    end

    return (type(image) == 'table' and image.width > 0 and image.height > 0) and image or nil
end

LOCAL = require 'Data.local' GET_SAFE_AREA()
LANGS = {'en', 'ru', 'pt', 'es', 'de', 'pl', 'ua', 'by', 'cn', 'jp', 'custom'}
LANGS_TRANSLATE, LANG = {
    'English', 'Русский', 'Brasileiro', 'Español', 'Deutsch',
    'Polski', 'Українська', 'Беларускі', '中文', '日本語'
}, {
    custom = {}, ru = {}, en = {}, pt = {}, es = {}, de = {},
    pl = {}, ua = {}, by = {}, cn = {}, jp = {}
}

for i = 1, #LANGS do
    local langData = JSON.decode(READ_FILE(system.pathForFile('Strings/' .. LANGS[i] .. '.json')))
    if langData then for _, langT in pairs(langData) do for key, str in pairs(langT) do LANG[LANGS[i]][key] = str end end end
end

for i = 1, #LANGS do if LANGS[i] == LOCAL.lang then break elseif i == #LANGS then LOCAL.lang = 'en' end end
STR = LANG[LOCAL.lang] for k, v in pairs(LANG.ru) do if not STR[k] then STR[k] = LANG.en[k] or v
elseif type(STR[k]) == 'table' then for k2, v2 in ipairs(LANG.ru[k]) do if not STR[k][k2]
then STR[k][k2] = (LANG.en[k] and LANG.en[k][k2]) and LANG.en[k][k2] or v2 end end end end

if IS_SIM then
    JSON.encode, JSON.encode2, JSON.encode4 = JSON.prettify, JSON.encode, JSON.encode3
    JSON.encode3 = function(s, opt) local opt = opt or {} opt.indent = opt.indent == nil and true or opt.indent return JSON.encode4(s, opt) end
else
    JSON.encode2 = JSON.encode
end

display.setDefault('background', unpack(LOCAL.themes.bg))
INFO = require('Data.info') require('Core.Modules.custom-block').getBlocks()
if LOCAL.orientation == 'landscape' then setOrientationApp({type = 'landscape'}) end

SET_FOCUS = function(target, id)
    if id then
        display.getCurrentStage():setFocus(target, id)
    else
        display.getCurrentStage():setFocus(target)
    end

    target.isFocus = true
end

NIL_FOCUS = function(target, id)
    if id then
        display.getCurrentStage():setFocus(target, nil)
    else
        display.getCurrentStage():setFocus(nil)
    end

    target.isFocus = nil
end

BUTTONS_LISTENER = function(e, listener)
    if e.phase == 'began' then
        SET_FOCUS(e.target)
        handlerTouch(e)
        listener(e)
    elseif e.phase == 'moved' and (math.abs(e.xDelta) > 30 or math.abs(e.yDelta) > 30) then
        NIL_FOCUS(e.target)
        handlerTouch({phase = 'ended', id = e.id})
        listener(e)
    elseif e.phase == 'ended' or e.phase == 'cancelled' then
        handlerTouch(e)

        if e.target.isFocus then
            e.phase = 'ended'
            NIL_FOCUS(e.target)
            listener(e)
        end
    end

    return true
end

FINGERS = {}
FINGERS_ARRAY = {}

function handlerTouch(e)
    local id = e.id and tostring(e.id) or 'userdata: 00000001'

    if e.phase == 'began' then
        table.insert(FINGERS_ARRAY, {x = e.x, y = e.y, id = id})
        FINGERS[id] = #FINGERS_ARRAY
    elseif e.phase == 'moved' then
        if not FINGERS[id] then
            return
        end

        FINGERS_ARRAY[FINGERS[id]].x = e.x
        FINGERS_ARRAY[FINGERS[id]].y = e.y
    elseif e.phase == 'ended' or e.phase == 'cancelled' then
        if not FINGERS[id] then
            return
        end

        for i = FINGERS[id] + 1, #FINGERS_ARRAY do
            FINGERS[FINGERS_ARRAY[i].id] = i - 1
        end

        table.remove(FINGERS_ARRAY, FINGERS[id])
        FINGERS[id] = nil
    end
end

GET_GLOBAL_TABLE = function()
    return {
        sendLaunchAnalytics = sendLaunchAnalytics, transition = transition, tostring = tostring, tonumber = tonumber,
        gcinfo = gcinfo, assert = assert, GAME = GAME, collectgarbage = collectgarbage, GANIN = GANIN,
        os = os, display = display, module = module, media = media, OS_REMOVE = OS_REMOVE, funsS = G_funsS, funsP = G_funsP,
        native = native, coroutine = coroutine, CENTER_X = CENTER_X, CENTER_Y = CENTER_Y, JSON = JSON, ipairs = ipairs,
        TOP_HEIGHT = TOP_HEIGHT, network = network, _network_pathForFile = _network_pathForFile, print5 = require,
        pcall = pcall, BUILD = BUILD, MAX_Y = MAX_Y, MAX_X = MAX_X, string = string, SIZE = SIZE, print = print,
        xpcall = xpcall, ZERO_Y = ZERO_Y, ZERO_X = ZERO_X, package = package, OS_MOVE = OS_MOVE, RENDER = RENDER,
        table = table, lpeg = lpeg, COPY_TABLE = COPY_TABLE, DISPLAY_HEIGHT = DISPLAY_HEIGHT, OS_COPY = OS_COPY,
        unpack = unpack, setmetatable = setmetatable, next = next, RIGHT_HEIGHT = RIGHT_HEIGHT,
        graphics = graphics, system = system, rawequal = rawequal, getmetatable = getmetatable, FILE = FILE,
        timer = timer, BOTTOM_HEIGHT = BOTTOM_HEIGHT, newproxy = newproxy, metatable = metatable, NOISE = NOISE,
        al = al, rawset = rawset, easing = easing, coronabaselib = coronabaselib, DOC_DIR = DOC_DIR,
        LEFT_HEIGHT = LEFT_HEIGHT, cloneArray = cloneArray, DISPLAY_WIDTH = DISPLAY_WIDTH, type = type,
        audio = audio, pairs = pairs, select = select, rawget = rawget, Runtime = Runtime, error = error,
        fun = G_fun, math = G_math, other = G_other, device = G_device, prop = G_prop, PASTEBOARD = PASTEBOARD,
        varsE = G_varsE, varsS = G_varsS, varsP = G_varsP, tablesE = G_tablesE, tablesS = G_tablesS, tablesP = G_tablesP
    }
end

ORIGINAL_SIGNATURE = '308203753082025da00302010202043f1db95b300d06092a864886f70d01010b0500306b310b30090603550406130272753110300e06035504081307556e6b6e6f776e310f300d060355040713064d6f73636f773110300e060355040a1307556e6b6e6f776e3110300e060355040b1307556e6b6e6f776e311530130603550403130c4c656f6e69642047616e696e301e170d3232303231373036353031305a170d3439303730353036353031305a306b310b30090603550406130272753110300e06035504081307556e6b6e6f776e310f300d060355040713064d6f73636f773110300e060355040a1307556e6b6e6f776e3110300e060355040b1307556e6b6e6f776e311530130603550403130c4c656f6e69642047616e696e30820122300d06092a864886f70d01010105000382010f003082010a0282010100a9bad7fe4a47853729a82eb8af8b725b94f66cbbc3c274ce8047502f77cf521d299461ca49d2c42b8e20bc6569d5853fd97d8c4df61f100e18628814a388ec8a296b28d53517e2f13f9f29e08af509aec50be97a3701fb845480d89bdcd8bfdfaea6bac683bba84320074b2a6529158bdd3003bc3564290a8b427e0463a7de1f7b23c6021d7ed014d66c3ddfcc296e3a9b0efc1db09b57287ed1fd831af3ad5afc1e3a09296591e0c7b0b7e70c8d163b014ada4b0629f4da8c81f31beac9c104f739bf249e5cd8568ccd0bad63833c352ff10c166d11f8ea5c219364045281946456064a56eddde4503828aaff7bf4791fe160d52bec59ebe910bb3b18c685290203010001a321301f301d0603551d0e0416041460c5717d5e8c9f1b8dd744ce9e65110b8aa2a085300d06092a864886f70d01010b05000382010100a759fb6e58371e73f487d3ce04ac66eae94805adbe15cd1389ff47f9cd3b783fd0abfc5a98ddb43aeedc5af3d3b9d71eddce3d0a554ea0ba385116128ccb8b85e272b9890661259b1067432bf284546cca17b4406aa88a7b85a999ba92eed827e2d1b600a6a079ff240ca0c3da5307d8439ac83863a87f5ad2923f9af29a15f72b38f597f967e48619ce4d1d4ee4414eb31dc296ee160e312ba6ff129a59fd1e194e7184b2e43930a4d9a827ca6eec2ccd6522314d302660bae79937c16e4c2b2c9285d83b1f671acad66a2e41e18ff900642eec45f867691244cff84ea715d1af315c1009411bcbcd8a6de901bd1147869a9c072198046137012bece52d44f4'
GOOGLE_PLAY_SIGNATURE = '3082058830820370a00302010202144aab867c12d4246d5792c232ef3b689037e3bd55300d06092a864886f70d01010b05003074310b3009060355040613025553311330110603550408130a43616c69666f726e6961311630140603550407130d4d6f756e7461696e205669657731143012060355040a130b476f6f676c6520496e632e3110300e060355040b1307416e64726f69643110300e06035504031307416e64726f69643020170d3231303731313130353934385a180f32303531303731313130353934385a3074310b3009060355040613025553311330110603550408130a43616c69666f726e6961311630140603550407130d4d6f756e7461696e205669657731143012060355040a130b476f6f676c6520496e632e3110300e060355040b1307416e64726f69643110300e06035504031307416e64726f696430820222300d06092a864886f70d01010105000382020f003082020a028202010095c70e49588c66cfea4df6e11396f8d28397a6ce7f617a2dfcfcc474df492215592fa14acdceef07505d8e81a50c6d585cabdb6f7351bb576bcea0d0705189e2ca8e68ebb2a2a3f6e027f607f753b0f3b28b3356264ba9e5d4762d237ee40f42dc2f1738643a2d5ed1fe4df97f393d7958d44ef8e2fbfce460f263586ab18c5175a7e846bd06db811410d1e226b7a0889ff16143e91856a1d361454b70538c12e04fc62ce8ad5f8e9f4add1debfe272a6792542082f31bd87f41cbd1508b4bc656771b95185c1c343609fe1e8f21ab1423681be8acbb16aa07f8790c82401905eb06a11b9574f29620ce6bda6f586a1bc115114faac5917332b4269dfc73904fa0fdd709b14359d398599d9cb2c69dafff80023a0daa5732c2accb2ecb7c2f1cb552ab7ebea71ee3cdd53c7706dd3b3b8bfe885acb33509d80d944637bb0f523d33809808bb1ff31bea6b0e3d01aa0793abc69dd54703c2438c8b0fc1e2c4912569ced272b4f31e5b72ada77b87026057982c1ad0a0d87a931d3b84b6582d2a0303b9cb6861e01f6c252239c5ab4cd8a21b44dc514665f5d536f6427a3a000f41939cdd2cbc72019117d7310d6cdac724897a3feb834d64abd1219cff7562f35a0fbc7858e1d91f7659337d5e62bdd4ee7cdeda46b215abed8e81bcedd5737b13904bba6b16de9ad99e6f454cff056dc1a2ac8aa4a6ddcc9b901ae78584854dd0203010001a310300e300c0603551d13040530030101ff300d06092a864886f70d01010b05000382020100614026b14ef7457e84babeac8711e465759b5e8f256c1f394689b8fab9814e40ce62786c2e969a259193f0f6d03b4e5d1ea76f2c0584a8cfd2c7c6e92e4139dd4f2b0257b3ecea7d9e46a6b995374d6043d24e77a750bbc932c00d0bdfa3c628380ae1d91eb2233d1593b3fb9653b5b0ee49054eae6cac1ba0a92c7d506e43dd992e03891a56f66b5d1a81e3e8501f9358635a04693e765e5024491ace254e3015c4c4c81263eccc3d0d5081081abbc5c1e977c6f1359f294835f418092b97c6e3013088587c95d1600ebadee976db9ad0cbcf1e6f3c642de6169ecd873f14bb7f9dcfdae29e6da068dc925b3c795813f032410d96ef833a4b129f2f31ff0a8b5c5f8ae7b13f973dce0fda31cfd13118bc30463c0502c3819e5d9fb1db0df40071b13ba1c14b03990e5ceb3e19ba9dfd8d11a04320d07f38d6063e08360910d34de6015cc42bf19503a65fd377810f60f2c088d93f9dfa4b983c198d23094fca6274c4d2cc67f2a86fc953b60441f405157a724a75fa0e80636d1dc800440a52d887125979d62c1bdc1680455920bc875b38080cacb49ad1012639bfe78b4a33b15e168ea7fd794458771c4975aef198960ea44eaabc21aea53e7bf676da4d20ec89cbee7b3c9485523aa53ffd52a43ddf92f147b382ab4c4a1331e7002def9b379072c0ebdaeb9ff1b2745205fbc137e663581b88eafafce22005f2ed055ec8'

local function isClockwise(shape)
    if #shape < 6 then return true end
    local sum = 0
    for i = 1, #shape / 2 do
        local x1, y1 = shape[(i - 1) * 2 + 1], shape[(i - 1) * 2 + 2]
        local x2, y2 = shape[i * 2 % #shape + 1], shape[i * 2 % #shape + 2]
        local x3, y3 = shape[(i + 1) * 2 % #shape + 1], shape[(i + 1) * 2 % #shape + 2]
        sum = sum + (x2 - x1) * (y3 - y1) - (y2 - y1) * (x3 - x1)
    end
    return sum > 0
end

local function reverseShape(shape)
    local result = {}
    for i = #shape, 1, -2 do
        table.insert(result, shape[i - 1])
        table.insert(result, shape[i])
    end
    return result
end

function safeBody(shape)
    if shape and #shape >= 6 then
        if not isClockwise(shape) then
            shape = reverseShape(shape)
        end
    end
    return shape
end
