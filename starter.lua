local function openApp()
    MENU.group.isVisible = false
    PROGRAMS = require 'Interfaces.programs'
    PROGRAMS.create()

    local data = GET_GAME_CODE(CURRENT_LINK)
    local script = GET_GAME_SCRIPT(CURRENT_LINK, 1, data)
    PROGRAM = require 'Interfaces.program'
    PROGRAM.create('App', data.noobmode)

    if script and script.custom then
        DEL_GAME_SCRIPT(CURRENT_LINK, 1, data)
        table.remove(data.scripts, 1)
        SET_GAME_CODE(CURRENT_LINK, data)
    end

    SCRIPTS = require 'Interfaces.scripts'
    SCRIPTS.create()
    CURRENT_SCRIPT = 1
    BLOCKS = require 'Interfaces.blocks'
    BLOCKS.create()
    BLOCKS.group.isVisible = true
end

local function selectLang(onComplete)
    local scroll = WIDGET.newScrollView({
        width = DISPLAY_WIDTH,
        height = 100 * #LANGS_TRANSLATE,
        x = CENTER_X,
        y = CENTER_Y,
        hideScrollBar = true,
        horizontalScrollDisabled = true,
        isBounceEnabled = true,
        hideBackground = true
    })

    local y = 50
    for i = 1, #LANGS_TRANSLATE do
        local button = display.newRect(CENTER_X, y, DISPLAY_WIDTH, 100)
        button:setFillColor(unpack(LOCAL.themes.bg))

        local text = display.newText(LANGS_TRANSLATE[i], CENTER_X, y, 'ubuntu', 40)

        button:addEventListener('touch', function(e)
            if e.phase == 'began' then
                display.getCurrentStage():setFocus(e.target)
                e.target:setFillColor(unpack(LOCAL.themes.bgAdd3Color))
                e.target.click = true
            elseif e.phase == 'moved' and (math.abs(e.yDelta) > 30 or math.abs(e.xDelta) > 30) then
                scroll:takeFocus(e)
                e.target.click = false
                e.target:setFillColor(unpack(LOCAL.themes.bg))
            elseif e.phase == 'ended' or e.phase == 'cancelled' then
                display.getCurrentStage():setFocus(nil)
                e.target:setFillColor(unpack(LOCAL.themes.bg))
                if e.target.click then
                    e.target.click = false
                    LOCAL.lang = LANGS[i]
                    STR = LANG[LOCAL.lang]

                    for k, v in pairs(LANG.ru) do
                        if not STR[k] then
                            STR[k] = LANG.en[k] or v
                        elseif type(STR[k]) == 'table' then
                            for k2, v2 in ipairs(LANG.ru[k]) do
                                if not STR[k][k2] then
                                    STR[k][k2] = (LANG.en[k] and LANG.en[k][k2]) and LANG.en[k][k2] or v2
                                end
                            end
                        end
                    end

                    NEW_DATA()
                    MENU.group:removeSelf()
                    MENU.group = nil
                    MENU.create()
                    MENU.group.isVisible = true
                    scroll:removeSelf()
                    onComplete()
                end
            end
            return true
        end)

        scroll:insert(button)
        scroll:insert(text)
        y = y + 100
    end
end

local function checkFirstLaunch(onComplete, onBeginnerComplete)
    if IS_SIM and LOCAL and LOCAL.first_launch then
        onComplete()
        return
    end

    timer.new(2, 1, function()
        if LOCAL.first_launch then
            if LOCAL.age and LOCAL.age >= 5 and LOCAL.age <= 90 then
                MENU.group.isVisible = true
                onComplete()
            else
                WINDOW.new(STR['beginner.age.banned'], {STR['button.okay']}, function()
                    native.requestExit()
                end)
                WINDOW.buttons[1].x = WINDOW.bg.x + WINDOW.bg.width / 4 - 5
                WINDOW.buttons[1].text.x = WINDOW.buttons[1].x
            end
        else
            selectLang(function()
                MENU.group.isVisible = true
                WINDOW.new(STR['beginner.start.message'], {STR['beginner.start.button.anonim'], STR['button.okay']}, function(e)
                    if e.index == 1 then
                        LOCAL.name = STR['beginner.start.button.anonim']
                        LOCAL.gender = 'man'
                        LOCAL.age = 18
                        LOCAL.first_launch = true
                        NEW_DATA()
                    elseif e.index == 2 then
                        timer.new(1, 1, function()
                            WINDOW.new(STR['beginner.gender.what'], {STR['beginner.gender.woman'], STR['beginner.gender.man']}, function(e)
                                if e.index == 0 then
                                    native.requestExit()
                                else
                                    LOCAL.gender = e.index == 1 and 'woman' or 'man'
                                    timer.new(1, 1, function()
                                        WINDOW.new(STR['beginner.age.what'], {STR['button.okay']}, function()
                                            INPUT.new(STR['beginner.age'], function(event)
                                                if (event.phase == 'ended' or event.phase == 'submitted') and not ALERT then
                                                    INPUT.remove(true, event.target.text)
                                                end
                                            end, function(e)
                                                local age = tonumber(e.text)
                                                if age then
                                                    LOCAL.age = age
                                                    NEW_DATA()
                                                end

                                                if age and age >= 5 and age <= 90 then
                                                    WINDOW.new(STR['beginner.name.what'], {STR['button.okay']}, function()
                                                        INPUT.new(STR['beginner.name'], function(event)
                                                            if (event.phase == 'ended' or event.phase == 'submitted') and not ALERT then
                                                                INPUT.remove(true, event.target.text)
                                                            end
                                                        end, function(e)
                                                            LOCAL.name = e.text
                                                            LOCAL.first_launch = true
                                                            NEW_DATA()
                                                            timer.new(1, 1, function()
                                                                WINDOW.new(STR['beginner.entrance'], {STR['button.okay']}, function()
                                                                    onBeginnerComplete()
                                                                end)
                                                                WINDOW.buttons[1].x = WINDOW.bg.x + WINDOW.bg.width / 4 - 5
                                                                WINDOW.buttons[1].text.x = WINDOW.buttons[1].x
                                                            end)
                                                        end)
                                                    end)
                                                    WINDOW.buttons[1].x = WINDOW.bg.x + WINDOW.bg.width / 4 - 5
                                                    WINDOW.buttons[1].text.x = WINDOW.buttons[1].x
                                                else
                                                    WINDOW.new(STR['beginner.age.banned'], {STR['button.okay']}, function()
                                                        native.requestExit()
                                                    end)
                                                    WINDOW.buttons[1].x = WINDOW.bg.x + WINDOW.bg.width / 4 - 5
                                                    WINDOW.buttons[1].text.x = WINDOW.buttons[1].x
                                                end
                                            end, '14')
                                        end)
                                        WINDOW.buttons[1].x = WINDOW.bg.x + WINDOW.bg.width / 4 - 5
                                        WINDOW.buttons[1].text.x = WINDOW.buttons[1].x
                                    end)
                                end
                            end)
                        end)
                    end
                end)
            end)
        end
    end)
end

if IS_SIM then
    MENU.create()
    checkFirstLaunch(openApp, openApp)
end

if not IS_SIM and not LIVE then
    local function startApp()
        DEVICE_ID = CRYPTO.hmac(CRYPTO.sha256, system.getInfo('deviceID'), system.getInfo('deviceID') .. 'md5')
        MENU.create()
        MENU.group.isVisible = false
        GANIN.az()
        pcall(function() end)

        function ADS_INIT(e)
            if e.phase == 'init' then
                ADS.setHasUserConsent(true)
            elseif e.phase == 'loaded' then
                ADS.show('AndroidVideo')
            elseif e.phase == 'completed' then
                CCOIN.set(tonumber(LOCAL.niocc) + 20)
            elseif e.phase == 'failed' then
                LOCAL.ads_time = 0
                NEW_DATA()
            end
        end

        ADS.init(function(e)
            if GAME and GAME.isStarted then
                pcall(function()
                    if e.phase == 'failed' or e.phase == 'skipped' or e.phase == 'displayed' or e.phase == 'completed' then
                        GAME.adsListener(e)
                    elseif e.phase == 'loaded' then
                        ADS.show('AndroidVideo')
                    end
                end)
            elseif not GAME then
                ADS_INIT(e)
            end
        end, {gameId = '5407408'})

        APPMETRICA.init('71559e59-d97b-4fb9-b1fc-a1259372d051')
        APPMETRICA.setLocationTracking(false)

        local permissions = system.getInfo('grantedAppPermissions')
        local dogImg = display.newImage('Sprites/Face/cdogFace1.png', 10000, 10000)
        local animeImg = display.newImage('Sprites/anime.png', 10000, 10000)
        system.getInfo('androidAppPackageName')
        GIVE_PERMISSION_DATA()

        pcall(function()
            if dogImg and animeImg then
                dogImg:removeSelf()
                animeImg:removeSelf()
                for i = 1, #permissions do
                    if permissions[i] == 'android.permission.INTERNET' then
                        checkFirstLaunch(function() end, function() end)
                        break
                    end
                end
            end
        end)

        if false then
            MENU.group.isVisible = false
            timer.new(1000, 1, function()
                MENU.group.isVisible = false
            end)
            PROGRAMS = require 'Interfaces.programs'
            PROGRAMS.create()

            local data = GET_GAME_CODE(CURRENT_LINK)
            local script = GET_GAME_SCRIPT(CURRENT_LINK, 1, data)
            PROGRAM = require 'Interfaces.program'
            PROGRAM.create('App', data.noobmode)

            if script and script.custom then
                DEL_GAME_SCRIPT(CURRENT_LINK, 1, data)
                table.remove(data.scripts, 1)
                SET_GAME_CODE(CURRENT_LINK, data)
            end

            SCRIPTS = require 'Interfaces.scripts'
            SCRIPTS.create()
            LEVELS = require 'Interfaces.levels'
            LEVELS.create()
            LEVELS_VIEW = require 'Core.Levels.view'
            LEVELS_VIEW:create()
        end
    end

    pcall(function()
        OS_REMOVE(MY_PATH .. '/tester.apk')
    end)

    startApp()
end
