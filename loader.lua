local constant = require("constant")
local game     = require("game")
local api      = require("api")
local logger   = require("api").logger
local json     = require("api").json

---显示加载界面
---@param player Role 指定玩家
local function showLoadingUI(player)
    api.sendUICustomEvent(player, constant.UI_SHOW_LOADING_EVENT, {})
end

---隐藏加载界面
---@param player Role
local function hideLoadingUI(player)
    api.sendUICustomEvent(player, constant.UI_HIDE_LOADING_EVENT, {})
end

---加载玩家设置
---@param player Role
---@param settingRef table
local function loadPlayerSettings(player, settingRef)
    -- 加载玩家设置
    local settingsJson = api.fetchArchiveData(player, Enums.ArchiveType.Str, 1001)
    local savedSettings = json.parse(settingsJson) or {}

    for key, value in pairs(settingRef) do
        settingRef[key] = savedSettings[key] or value
    end

    logger.debug("player settings loaded: " .. json.stringify(settingRef))
end

---上传玩家设置
---@param player Role
local function uploadPlayerSettings(player)
    local settingsJson = json.stringify(PlayerSettings)
    logger.debug("uploading player settings: " .. settingsJson)
    api.saveArchiveData(player, Enums.ArchiveType.Str, 1001, settingsJson)
end

local function loadPlayerGameStats(player, statsRef)
    -- 加载游戏统计数据
    local statsJson = api.fetchArchiveData(player, Enums.ArchiveType.Str, 1002)
    local savedStats = json.parse(statsJson) or {}

    for key, value in pairs(statsRef) do
        statsRef[key] = savedStats[key] or value
    end

    logger.debug("game stats loaded: " .. json.stringify(statsRef))
end


---刷新UI设置界面
local function refreshSettingsUI()
    api.sendGlobalCustomEvent(constant.UI_BRIDGE_SET_VFX_SETTING_TEXT, {
        text = PlayerSettings.enableVfx and "特效渲染：#G开启" or "特效渲染：#R关闭"
    })
    api.sendGlobalCustomEvent(constant.UI_BRIDGE_SET_AD_SETTING_TEXT, {
        text = PlayerSettings.enableAdService and "广告服务：#G开启" or "广告服务：#R关闭"
    })
end

---刷新游戏统计界面
local function refreshGameStatsUI()
    logger.info("refreshing game stats UI...")
    local data = {
        [1] = "总游戏次数: #O" .. GameStats.totalGames,
        [2] = "总击败敌人数: #O" .. GameStats.totalKills,
        [3] = "总伤害: #O" .. GameStats.totalDamage,
        [4] = "总承受伤害: #O" .. GameStats.totalDamageTaken,
        [5] = "最大生存时间: #O" .. GameStats.maxSurvivalTime
    }

    api.sendGlobalCustomEvent(constant.UI_BRIDGE_SET_GAME_STATS_TEXT, { data = data })
end



local function checkSavedGameArchive()
    local gameArchiveJson = api.fetchArchiveData(Player, Enums.ArchiveType.Str, 1003)
    if (gameArchiveJson == nil or gameArchiveJson == "") then
        return false
    end
    return true
end

---清除存档
local function deleteSavedGameArchive()
    api.saveArchiveData(Player, Enums.ArchiveType.Str, 1003, "")
    logger.info("Game archive saved successfully.")
end

local showDeleteArchiveUI = function()
    api.sendUICustomEvent(Player, constant.UI_SHOW_DELETE_ARCHIVE_EVENT, {})
end


local function loadGame()
    local gameArchiveJson = api.fetchArchiveData(Player, Enums.ArchiveType.Str, 1003)
    logger.info("Game archive loaded")
    logger.debug("Game archive data: " .. gameArchiveJson)
    -- doLoadSavedGameArchive(game.object.data , gameArchiveJson)
    game.object.init(json.parse(gameArchiveJson))
end




-- LOAD GAME ===================================================================





local function doStartNewGame()
    showLoadingUI(Player)


    -- 加载游戏数据
    api.setTimeout(function()
        loadGame()
    end, 30)



    api.setTimeout(function()
        logger.info("close main menu")
        api.sendUICustomEvent(Player, constant.UI_HIDE_MAIN_MENU_EVENT, {})
        logger.info("show hud ui")
        api.sendUICustomEvent(Player, constant.UI_SHOW_HUD_EVENT, {})
        logger.info("register hud listener")

        game.hud.fullUpdate()
        game.hud.registerListener()
    end, 35)



    api.setTimeout(function()
        logger.info("camera init")
        local cameraComponent = api.getUnitById(constant.GAME_CAMERA_COMPONENT_ID)
        game.camera.init(cameraComponent)
    end, 40)

    api.setTimeout(function()
        logger.info("main turret lock init")
        game.object.enableMainTurretTowardsToCursor()
    end, 45)

    -- 注册相机手势监听
    api.setTimeout(function()
        logger.info("register camera move listener")

        -- 移动监听器
        api.registerGlobalCustomEventListener(constant.UI_CAMERA_MOVE_EVENT,
            function(unit, name, data)
                logger.debug("camera move event")
                local xzVec = game.camera.slidAngleTransform(data.angle)
                game.camera.ctrlMove(xzVec, false)
            end)

        --停止监听器
        api.registerGlobalCustomEventListener(constant.UI_CAMERA_MOVE_STOP_EVENT,
            function(unit, name, data)
                logger.debug("camera move stop")
                game.camera.ctrlMoveStop()
            end)
    end, 50)

    --场景初始化处理
    api.setTimeout(function()
        game.scene.gameStartHexRunMotor()
        game.scene.initEnemyUnitGenerator()
    end, 80)

    api.setTimeout(function()
        hideLoadingUI(Player)
    end, 90)
end

-- 开始游戏逻辑=================================================================
local function startNewGame()
    if (checkSavedGameArchive) then
        logger.warn("Saved game archive found when starting a new game.")
        showDeleteArchiveUI()
        return
    end

    logger.info("No saved game archive found, starting a new game.")
    doStartNewGame()
end


local function continueGame()
    logger.info("Continuing game from saved archive.")
    doStartNewGame()
end






---显示主菜单
---@param player Role 指定玩家
local function showMainMenu(player)
    logger.info("Showing main menu...")

    logger.debug("Setting camera")
    api.setCameraBindMode(player, Enums.CameraBindMode.BIND)

    local cameraComponent = api.getUnitById(1853491973)

    api.setCameraFollowUnit(player, cameraComponent, true)

    api.setCameraProperties(player, {
        [Enums.CameraPropertyType.BIND_MODE_OFFSET_X] = 12.0,
        [Enums.CameraPropertyType.BIND_MODE_OFFSET_Y] = 15.0,
        [Enums.CameraPropertyType.BIND_MODE_OFFSET_Z] = -20.0,
        [Enums.CameraPropertyType.BIND_MODE_PITCH] = 50.0,
        [Enums.CameraPropertyType.BIND_MODE_YAW] = 0.0,
    })

    -- 显示画布
    api.sendUICustomEvent(player, constant.UI_SHOW_MAIN_MENU_EVENT, {})
end

---初始化游戏逻辑
local function init()
    --注册新游戏监听器
    api.registerGlobalCustomEventListener(constant.UI_NEW_GAME_EVENT, function()
        logger.info("new game started")
        startNewGame()
    end)

    --注册继续游戏监听器
    api.registerGlobalCustomEventListener(constant.UI_CONTINUE_GAME_EVENT, function()
        logger.info("continue game started")
        continueGame()
    end)

    --注册关于界面监听器
    api.registerGlobalCustomEventListener(constant.UI_ABOUT_EVENT, function()
        logger.info("show about info")
    end)

    --注册设置界面监听器
    api.registerGlobalCustomEventListener(constant.UI_SETTINGS_EVENT, function()
        logger.info("show settings")
        api.sendUICustomEvent(Player, constant.UI_HIDE_STATS_EVENT, {})
    end)

    --注册游戏统计界面监听器
    api.registerGlobalCustomEventListener(constant.UI_GAME_STATS_EVENT, function()
        logger.info("game stat info")
        api.sendUICustomEvent(Player, constant.UI_HIDE_SETTINGS_EVENT, {})
        refreshGameStatsUI()
    end)

    --注册特效设置开关监听器
    api.registerGlobalCustomEventListener(constant.UI_VFX_SETTING_SWITCH_EVENT, function()
        logger.info("VFX setting toggled")
        PlayerSettings.enableVfx = not PlayerSettings.enableVfx
        refreshSettingsUI()
        uploadPlayerSettings(Player)
        game.scene.setVfxRenderingStatus(PlayerSettings.enableVfx)
    end)

    --注册广告设置开关监听器
    api.registerGlobalCustomEventListener(constant.UI_AD_SETTING_SWITCH_EVENT, function()
        logger.info("Ad setting toggled")
        PlayerSettings.enableAdService = not PlayerSettings.enableAdService
        refreshSettingsUI()
        uploadPlayerSettings(Player)
    end)

    api.registerGlobalCustomEventListener(constant.UI_CONFIRM_DELETE_ARCHIVE_EVENT, function()
        logger.info("confirm delete saved game data")
        deleteSavedGameArchive()
        api.sendUICustomEvent(Player, constant.UI_HIDE_DELETE_ARCHIVE_EVENT, {})
        doStartNewGame()
    end)

    api.registerGlobalCustomEventListener(constant.UI_CANCEL_DELETE_ARCHIVE_EVENT, function()
        logger.info("cancel delete saved game data")
        api.sendUICustomEvent(Player, constant.UI_HIDE_DELETE_ARCHIVE_EVENT, {})
    end)


    -- test








end





























local loader = {
    init = init,
    hideLoadingUI = hideLoadingUI,
    showLoadingUI = showLoadingUI,
    showMainMenu = showMainMenu,
    loadPlayerSettings = loadPlayerSettings,
    loadPlayerGameStats = loadPlayerGameStats,
    uploadPlayerSettings = uploadPlayerSettings,
    refreshSettingsUI = refreshSettingsUI,
    refreshGameStatsUI = refreshGameStatsUI
}

return loader
