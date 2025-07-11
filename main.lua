local loader    = require("loader")
local api       = require("api")
local logger    = require("api").logger

-- 全局运行时变量
---@type Role
Player          = nil

---@type table<string, any>
PlayerSettings  = {
    enableVfx = true,             -- 是否启用特效
    enableAdService = true,       -- 是否启用广告
    enableComponentCache = false, --是否启用缓存创建子弹
}

GameStats       = {
    totalGames = 0,       -- 总游戏次数
    totalKills = 0,       -- 总击杀数
    totalDamage = 0,      -- 总伤害数
    totalDamageTaken = 0, -- 总承受伤害
    maxSurvivalTime = 0,  -- 最大生存时间（秒）
}

GameRuntimeData = {
    playTime = 0,         -- 游戏总时长（秒）
    energy = 0,           -- 当前能量
    totalKills = 0,       -- 总击杀数
    totalDamage = 0,      -- 总伤害数
    totalDamageTaken = 0, -- 总承受伤害
    mainTowerLevel = 0,   -- 主塔等级
    mainTowerHealth = 0,  -- 主塔生命值
}



logger.setLevel("DEBUG")
logger.info("game is starting...")

Player = api.getPlayer(1)




logger.info("player joined: [" .. Player.get_name() .. "]")
logger.info("initializing game...")

-- 延迟15帧后进行初始化逻辑
api.setTimeout(function()
    loader.init()
    loader.showMainMenu(Player)
    logger.info("game initialized successfully.")
end, 10)

-- 加载玩家设置
api.setTimeout(function()
    logger.info("loading player settings...")
    loader.loadPlayerSettings(Player, PlayerSettings)

    -- 刷新UI设置界面
    loader.refreshSettingsUI()
end, 15)

-- 加载游戏统计数据
api.setTimeout(function()
    logger.info("loading game stats...")
    loader.loadPlayerGameStats(Player, GameStats)
    -- 刷新游戏统计界面
    loader.refreshGameStatsUI()
end, 20)



-- 关闭加载界面
api.setTimeout(function()
    loader.hideLoadingUI(Player)
end, 30)

