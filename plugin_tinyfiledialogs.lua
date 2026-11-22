local lib = require('CoronaLibrary'):new({
    name = 'plugin.tinyfiledialogs',
    publisherId = 'com.xibalbastudios'
})

local function defaultFunction()
    return false
end

for _, name in ipairs({
    'colorChooser',
    'inputBox',
    'messageBox',
    'openFileDialog',
    'saveFileDialog',
    'selectFolderDialog'
}) do
    lib[name] = defaultFunction
end

return lib
