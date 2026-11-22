local listeners = {}

listeners.but_myprogram = function(target)
    MENU.group.isVisible = false
    PROGRAMS = require 'Interfaces.programs'
    PROGRAMS.create()
    PROGRAMS.group.isVisible = true
end

function _supportOldestVersion(data, link)
    local script = GET_GAME_SCRIPT(link, 1, data)

    if not data.folders then
        data.folders = {
            scripts = {{'1', data.scripts, false}},
            images = {{'1', data.resources.images, false}},
            sounds = {{'1', data.resources.sounds, false}},
            videos = {{'1', data.resources.videos, false}},
            others = {{'1', data.resources.others, false}},
            fonts = {{'1', data.resources.fonts, false}}
        }
    end

    if not data.resources.levels then
        data.resources.levels = {}
        data.folders.levels = {{'1', {}, false}}
    end

    if script and script.custom then
        DEL_GAME_SCRIPT(link, 1, data)
        table.remove(data.scripts, 1)
    end

    if tonumber(data.build) < 1370 then
        for i = 1, #data.scripts do
            local scriptData, nestedInfo, isEdited = GET_FULL_DATA(GET_GAME_SCRIPT(link, i, data))
            for j = 1, #scriptData.params do
                local name = scriptData.params[j].name
                if (name == 'showGroup' or name == 'hideGroup') and not scriptData.params[j].params[2] then
                    scriptData.params[j].params[2] = {{'yes', 'sl'}}
                    isEdited = true
                end
            end
            if isEdited then
                SET_GAME_SCRIPT(link, GET_NESTED_DATA(scriptData, nestedInfo, INFO), i, data)
            end
        end
    end

    if tonumber(data.build) < 1371 then
        for i = 1, #data.scripts do
            local scriptData, nestedInfo, isEdited = GET_FULL_DATA(GET_GAME_SCRIPT(link, i, data))
            for j = 1, #scriptData.params do
                for _, param in ipairs(scriptData.params[j].params) do
                    if type(param) == 'table' then
                        for index, token in ipairs(param) do
                            if type(token) == 'table' and (token[1] == 'finger_touching_screen_x' or token[1] == 'finger_touching_screen_y') then
                                if type(param[index + 1]) ~= 'table' or param[index + 1][1] ~= '(' or param[index + 1][2] ~= 's' then
                                    table.insert(param, index + 1, {')', 's'})
                                    table.insert(param, index + 1, {'(', 's'})
                                    isEdited = true
                                end
                            end
                        end
                    end
                end
            end
            if isEdited then
                SET_GAME_SCRIPT(link, GET_NESTED_DATA(scriptData, nestedInfo, INFO), i, data)
            end
        end
    end

    if tonumber(data.build) < BUILD then
        data.build = tostring(BUILD)
    end

    LFS.mkdir(DOC_DIR .. '/' .. link .. '/Levels')

    return data
end

listeners.but_continue = function(target)
    if LOCAL.last == '' then
        MENU.group.isVisible = false
        PROGRAMS = require 'Interfaces.programs'
        PROGRAMS.create()
        PROGRAMS.group.isVisible = true
    else
        local data = GET_GAME_CODE(LOCAL.last_link)

        if tonumber(data.build) > 1170 then
            data = _supportOldestVersion(data, LOCAL.last_link)
            SET_GAME_CODE(LOCAL.last_link, data)

            MENU.group.isVisible = false
            PROGRAMS = require 'Interfaces.programs'
            PROGRAMS.create()
            CURRENT_LINK = LOCAL.last_link

            PROGRAMS.group.isVisible = false
            PROGRAM = require 'Interfaces.program'
            PROGRAM.create(LOCAL.last, data.noobmode)
            PROGRAM.group.isVisible = true
        end
    end
end

listeners.but_settings = function(target)
    MENU.group.isVisible = false
    SETTINGS = require 'Interfaces.settings'
    SETTINGS.create()
    SETTINGS.group.isVisible = true
end

listeners.but_social = function(target)
    system.openURL('https://discord.gg/7eYnvAgXdX')
end

listeners.but_tg = function(target)
    system.openURL('https://t.me/ccode_official')
    system.openURL('https://t.me/ganin_official')
end

listeners.but_ad = function(target)
    system.openURL('https://forms.gle/kSAGfqkr1e86GKfn7')
    system.openURL('https://t.me/ganin_official/576')
end

listeners.but_dogs = function(target)
    MENU.group.isVisible = false
    ROBODOG = require 'Interfaces.robodog'
    ROBODOG.create()
    ROBODOG.group.isVisible = true
end

return function(e)
    if MENU.group.isVisible and ALERT then
        if e.phase == 'began' then
            display.getCurrentStage():setFocus(e.target)
            e.target.click = true
            if e.target.button == 'but_social'
            then e.target.alpha = 0.7
            else e.target.alpha = 0.6 end
        elseif e.phase == 'moved' and (math.abs(e.x - e.xStart) > 30 or math.abs(e.y - e.yStart) > 30) then
            e.target.click = false
            if e.target.button == 'but_social'
            then e.target.alpha = 1
            else e.target.alpha = 0.9 end
        elseif e.phase == 'ended' or e.phase == 'cancelled' then
            display.getCurrentStage():setFocus(nil)
            if e.target.click then
                e.target.click = false
                if e.target.button == 'but_social'
                then e.target.alpha = 1
                else e.target.alpha = 0.9 end
                listeners[e.target.button](e.target)
            end
        end
        return true
    end
end
