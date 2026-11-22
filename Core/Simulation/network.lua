local CALC = require 'Core.Simulation.calc'
local M = {}

M['getDonation'] = function(params)
    local desc, donateId, amount = CALC(params[1]), CALC(params[2], '0'), CALC(params[3], '100')

    GAME.lua = GAME.lua .. '\n pcall(function() local desc, donateId, amount = ' .. desc .. ', ' .. donateId .. ', ' .. amount
    GAME.lua = GAME.lua .. '\n local url = \'http://213.108.4.150:3000/create-payment?\''
    GAME.lua = GAME.lua .. '\n url = url .. \'deviceId=\' .. tostring(GAME_DEVICE_ID)'
    GAME.lua = GAME.lua .. '\n url = url .. \'&amount=\' .. tostring(amount)'
    GAME.lua = GAME.lua .. '\n url = url .. \'&donateId=\' .. tostring(donateId)'
    GAME.lua = GAME.lua .. '\n url = url .. \'&desc=\' .. encodeURIComponent(desc)'
    GAME.lua = GAME.lua .. '\n network.request(url, \'GET\', function(e)'
    GAME.lua = GAME.lua .. '\n local response = e.response and JSON.decode(e.response)'
    GAME.lua = GAME.lua .. '\n system.openURL(response.url) end) end)'
end

M['checkDonation'] = function(params)
    local donateId, listener = CALC(params[1], '0'), CALC(params[2], 'a', true)

    GAME.lua = GAME.lua .. '\n pcall(function() local donateId, listener = ' .. donateId .. ', ' .. listener
    GAME.lua = GAME.lua .. '\n local url = \'http://213.108.4.150:3000/check-payment?\''
    GAME.lua = GAME.lua .. '\n url = url .. \'deviceId=\' .. tostring(GAME_DEVICE_ID)'
    GAME.lua = GAME.lua .. '\n url = url .. \'&donateId=\' .. tostring(donateId)'
    GAME.lua = GAME.lua .. '\n network.request(url, \'GET\', function(e)'
    GAME.lua = GAME.lua .. '\n local response = e.response and JSON.decode(e.response)'
    GAME.lua = GAME.lua .. '\n if response.status == \'completed\' then listener({check = true})'
    GAME.lua = GAME.lua .. '\n else listener({check = false}) end end) end)'
end

M['createBluetooth'] = function(params)
    GAME.lua = GAME.lua .. '\n pcall(function() GIVE_PERMISSION_DATA() GANIN.bluetooth(\'host\','
    GAME.lua = GAME.lua .. '\n function(e) ' .. CALC(params[1], 'a', true) .. '(e) end) end)'
end

M['connectBluetooth'] = function(params)
    GAME.lua = GAME.lua .. '\n pcall(function() GIVE_PERMISSION_DATA() GANIN.bluetooth(\'connect\', ' .. CALC(params[1], '\'\'') .. ','
    GAME.lua = GAME.lua .. '\n function(e) ' .. CALC(params[2], 'a', true) .. '(e) end) end)'
end

M['sendBluetooth'] = function(params)
    GAME.lua = GAME.lua .. '\n pcall(function() GIVE_PERMISSION_DATA() GANIN.bluetooth(\'send\', ' .. CALC(params[1], '\'{}\'') .. ') end)'
end

M['createServer'] = function(params)
    GAME.lua = GAME.lua .. '\n pcall(function() table.insert(GAME.group.stops, SERVER.createServer('
    GAME.lua = GAME.lua .. CALC(params[1], '22222') .. ', function(e) if GAME.hash == hash then'
    GAME.lua = GAME.lua .. '\n return ' .. CALC(params[2], 'a', true) .. '(e) end end)) end)'
end

M['connectToServer'] = function(params)
    GAME.lua = GAME.lua .. '\n pcall(function() table.insert(GAME.group.stops, CLIENT.createClientLoop('
    GAME.lua = GAME.lua .. CALC(params[1], 'nil') .. ', ' .. CALC(params[2], '22222') .. ','
    GAME.lua = GAME.lua .. '\n function(e) if GAME.hash == hash then return ' .. CALC(params[3], 'a', true) .. '(e) end end)) end)'
end

M['requestFirebase'] = function(params, method)
    local link, value = CALC(params[1]), (method == 'GET' or method == 'DELETE') and 'nil' or CALC(params[2])
    local key = (method == 'GET' or method == 'DELETE') and CALC(params[2], '\'\'') or CALC(params[3], '\'\'')
    local link = '\'https://\' .. tostring(' .. link .. ') .. \'.firebaseio.com/\' .. tostring(' .. key .. ') .. \'.json\''
    local listener = (method == 'GET' or method == 'DELETE') and CALC(params[3], 'a', true) or CALC(params[4], 'a', true)

    GAME.lua = GAME.lua .. '\n pcall(function() local value = ' .. value
    GAME.lua = GAME.lua .. '\n if type(value) == \'number\' or type(value) == \'boolean\' then value = tostring(value)'
    GAME.lua = GAME.lua .. '\n elseif type(value) == \'string\' then value = \'"\' .. value .. \'"\''
    GAME.lua = GAME.lua .. '\n elseif type(value) == \'table\' then value = JSON.encode(value) end'
    GAME.lua = GAME.lua .. '\n table.insert(GAME_networks,'
    GAME.lua = GAME.lua .. '\n network.request(' .. link .. ', \'' .. method .. '\', function(e) pcall(function() if GAME.hash'
    GAME.lua = GAME.lua .. '\n == hash then ' .. listener .. '(e.response) end end) end, {body = value})) end)'
end

M['requestNetwork'] = function(params, method)
    local link, body, timeout = CALC(params[1]), CALC(params[2], '\'{}\''), CALC(params[7], '30')
    local headers, listener = CALC(params[3], '{}'), CALC(params[4], 'a', true)
    local progress = UTF8.match(CALC(params[5]), '%(select%[\'(.+)\'%]') or 'nil'
    local progress = progress == 'progressDownload' and 'download' or progress == 'progressUpload' and 'upload' or 'nil'
    local redirect = UTF8.match(CALC(params[6]), '%(select%[\'(.+)\'%]') or 'nil'
    local redirect = redirect == 'redirectsFalse' and 'false' or 'true'

    GAME.lua = GAME.lua .. '\n pcall(function() table.insert(GAME_networks,'
    GAME.lua = GAME.lua .. '\n network.request(' .. link .. ', \'' .. method .. '\','
    GAME.lua = GAME.lua .. '\n function(e) pcall(function() if GAME.hash == hash then ' .. listener .. '(e) end end) end, {body'
    GAME.lua = GAME.lua .. '\n = ' .. body .. ', headers = ' .. headers .. ', progress = ' .. progress .. ','
    GAME.lua = GAME.lua .. '\n handleRedirects = ' .. redirect .. ', timeout = ' .. timeout .. '})) end)'
end

M['requestGET'] = function(params) M['requestNetwork'](params, 'GET') end
M['requestPOST'] = function(params) M['requestNetwork'](params, 'POST') end
M['requestPUT'] = function(params) M['requestNetwork'](params, 'PUT') end
M['requestPATCH'] = function(params) M['requestNetwork'](params, 'PATCH') end
M['requestHEAD'] = function(params) M['requestNetwork'](params, 'HEAD') end
M['requestDELETE'] = function(params) M['requestNetwork'](params, 'DELETE') end
M['firebasePUT'] = function(params, method) M['requestFirebase'](params, 'PUT') end
M['firebasePATCH'] = function(params, method) M['requestFirebase'](params, 'PATCH') end
M['firebaseGET'] = function(params, method) M['requestFirebase'](params, 'GET') end
M['firebaseDELETE'] = function(params, method) M['requestFirebase'](params, 'DELETE') end

M['openURL'] = function(params)
    GAME.lua = GAME.lua .. '\n pcall(function() system.openURL(' .. CALC(params[1]) .. ')  end)'
end

M['initUnityAds'] = function(params)
    if GAME.isBuild then
        GAME.lua = GAME.lua .. '\n pcall(function() local dataID = ' .. CALC(params[1], '\'\'')
        GAME.lua = GAME.lua .. '\n GAME.adsListener = ' .. CALC(params[2], 'a', true)
        GAME.lua = GAME.lua .. '\n ADS.init(function(e) pcall(function()'
        GAME.lua = GAME.lua .. '\n if e.phase == \'init\' or e.phase == \'failed\' or e.phase == \'skipped\''
        GAME.lua = GAME.lua .. '\n or e.phase == \'displayed\' then GAME.adsListener(e) elseif e.phase == \'loaded\''
        GAME.lua = GAME.lua .. '\n then ADS.show(\'AndroidVideo\') end end) end, {gameId = tostring(dataID)}) end)'
    else
        GAME.lua = GAME.lua .. '\n pcall(function() GAME.adsListener = ' .. CALC(params[2], 'a', true)
        GAME.lua = GAME.lua .. '\n GAME.adsListener({phase = \'init\'}) end)'
    end
end

M['showUnityAds'] = function(params)
    GAME.lua = GAME.lua .. '\n pcall(function() ADS.showAd() end)'
end

return M
