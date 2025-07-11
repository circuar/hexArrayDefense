---@diagnostic disable: need-check-nil
local constant  = require("constant")
local api       = require("api")
local logger    = require("api").logger
local manager   = require("manager")
local resource  = require("resource")
local vfxRender = require("vfxRender")
local bridgeLib = require("bridgeLib")
-- local UINodes  = require("Data.UINodes")

local object    = {}
local frame     = {}
local camera    = {}
local hud       = {}
local scene     = {}


local originCreateBullet  = function(bulletTemplateIndex, createPosition, initialRotation)
    local bulletTemplate = resource.bulletTemplates[bulletTemplateIndex]
    local bullet = api.createComponent(
        bulletTemplate.presetId,
        createPosition,
        initialRotation,
        bulletTemplate.defaultZoom)
    api.setUnitCollisionStatusWith(bullet, resource.gameCameraBindUnit, false)

    api.extra.addObstacleDestroyListener(bullet, function()
        local presetParam = bulletTemplate.destroyEffectPreset
        vfxRender.createVfx(
            presetParam.id,
            api.positionOf(bullet),
            presetParam.rotation,
            presetParam.zoom,
            presetParam.duration,
            presetParam.speed, false)
    end)

    return bullet
end

local originDestroyBullet = function(bulletTemplateIndex, bulletUnit)
    api.destroyUnitWithSubUnit(bulletUnit)
end

local apiExport           = {

    createBullet = originCreateBullet,
    destroyBullet = originDestroyBullet,

}


---设置缓存状态
---@param status boolean
local function setComponentCacheCreateStatus(status)
    if status then
        apiExport.createBullet = manager.bulletCreateProxy
        apiExport.destroyBullet = manager.bulletDestroyProxy
    else
        apiExport.createBullet = originCreateBullet
        apiExport.destroyBullet = originDestroyBullet
    end
end


-- 场景单位=====================================================================
-- 游戏数据，runtime & save data
object.data = {
    --游戏时长（秒）
    timeCount = 0, ---1009

    --等级
    level = 1, --- 1010

    --层数
    layer = 1, ---1011

    --生命值
    health = 3600,    ---1012

    maxHealth = 3600, ---1020

    --护盾值
    defense = 1800,    ---1013

    maxDefense = 1800, --- 1021

    --升级所需经验值
    totalExp = 150, --- 1022

    --当前经验值
    currentExp = 0, ---1014

    --游戏统计数据
    gameStats = {
        --击败敌人数
        kill = 0,            ---1015
        --总伤害
        totalDamage = 0,     ---1016
        --总承伤
        totalDefenseAtk = 0, ---1017
    },

    gameSettings = {
        autoAimEnabled = true ---1018
    },

    --伤害倍数
    damageMultiple = 1.0, ---1023
}

---@class EnemyUnitData
---@field base Unit
---@field centerComponent Unit
---@field templateIndex integer
---@field currentHealth integer
---@field currentDefense integer
---@field maxHealth integer
---@field maxDefense integer
---@field bulletTemplateIndex integer
---@field bulletSpeed number
---@field atkIntervalFrame integer
---@field damageValuePerBullet integer
---@field isDestroyed boolean
---@field bulletNumPerAtk integer
---@field bulletIntervalFrame integer
---@field exp integer

---@class TurretStatusData
---@field coolDownStatus boolean


---@type integer[]
object.turretAutoAtkScanIndexSequence = {}

object.turretAutoAtkScanFrameHandlerIndex = nil

---敌方单位数组
---@type EnemyUnitData[]
object.enemyUnitArray = {}
---阵基组件数组
---@type Unit[]
object.baseHexComponent = {}

-- 炮台组件数据对象数组
object.turretComponentData = {}

---@type TurretStatusData[]
object.turretStatusData = {}

-- 主炮台朝向光标帧更新处理器索引
object.mainTurretCursorFrmHandlerIndex = nil

object.enemyUnitTemplates = {}

object.enemyUnitProperties = {}

object.bulletTemplates = {}

object.mainTurretExtraData = {
    maxBulletNum = 20,
    bulletLoadFrame = 60,
    remainBulletNum = 20,

    rapidIsCoolDown = false,
    rapidMaxBulletNum = 60,
    remainRapidBulletNum = 60,
    rapidLoadFrame = 450,
    rapidIntervalFrame = 3,
    rapidBulletSpeed = 200,
    damageValuePerRapidBullet = 25,

    rapidBulletCreateLeftOffset = math.Vector3(-3.75, 0.5, 5),
    rapidBulletCreateRightOffset = math.Vector3(3.75, 0.5, 5),
    leftOrRightSelect = true,

    fireEffectPreset = {
        id = 2134,
        ---x:径向 y:竖直
        localOffset = { x = 2, y = 0 },
        towardsReferenceVec = math.Vector3(0, 0, 1),

        zoom = 4.0,
        duration = 1.0,
        speed = 1.0
    }

}

function object.startTimer()
    api.setTimeout(function()
        object.data.timeCount = object.data.timeCount + 1
        hud.updateTimer()
        object.startTimer()
    end, constant.LOGIC_FPS)
end

function object.turretCoolDown(turretComponentDataIndex, callback)
    local turretData = object.turretComponentData[turretComponentDataIndex]
    object.turretStatusData[turretComponentDataIndex].coolDownStatus = true
    api.setTimeout(function()
        object.turretStatusData[turretComponentDataIndex].coolDownStatus = false
        callback()
    end, turretData.atkCoolDownFrame)
end

---初始化游戏对象
function object.init(archiveData)
    if archiveData ~= nil then
        object.data = archiveData
    end

    ---@type Unit[]
    object.baseHexComponent = resource.baseHexComponent
    object.turretComponentData = resource.turretComponentData
    object.enemyUnitTemplates = resource.enemyUnitTemplates
    object.enemyUnitProperties = resource.enemyUnitProperties
    object.bulletTemplates = resource.bulletTemplates

    for index, value in ipairs(object.turretComponentData) do
        object.turretStatusData[index] = {
            coolDownStatus = false,
        }
    end



    -- 防御塔下移20（-60）
    for i = 2, #object.baseHexComponent, 1 do
        local curComp = object.baseHexComponent[i]
        local curPos = api.positionOf(curComp)
        local offsetPos = math.Vector3(curPos.x, -80, curPos.z)
        api.setPosition(object.baseHexComponent[i], offsetPos)
    end
    logger.debug("hex component position set")
end

--relations

-- 层数与等级关系
-- layer = (level + 2) / 3
function object.calLayerNumByLevel(level)
    return math.min((level + 2) // 3, 6)
end

function object.isLayerUpLevel(level)
    return (level - 1) % 3 == 0 and level <= 16
end

-- 总防御塔数量与layer层数关系
-- n = layer == 1 ? 1 : (layer - 1) * 6
function object.calTurretNumByLayer(layer)
    if layer == 1 then
        return 1
    end
    return (layer - 1) * 6
end

-- 数组索引范围与层数关系
-- index.min = layer == 1 ? 1 : 3 * layer ^ 2 - 9 * layer + 8
function object.calHexArrayIndexMinByLayer(layer)
    if layer == 1 then
        return 1
    end
    return math.tointeger(3 * layer ^ 2 - 9 * layer + 8)
end

-- index.max = layer == 1 ? 1 : 3 * layer ^ 2 - 3 * layer + 1
function object.calHexArrayIndexMaxByLayer(layer)
    if (layer == 1) then
        return 1
    end
    return math.tointeger(3 * layer ^ 2 - 3 * layer + 1)
end

-- 敌方单位的等级和游戏等级的关系
function object.getEnemyTemplateMinIndexByLevel()
    return 1
end

function object.getEnemyTemplateMaxIndexByLevel()
    return object.calLayerNumByLevel(object.data.level)
end

---该等级升级到下一级所需经验值
---@param level integer 等级
---@return integer 升级所需经验值
function object.getCurrentLevelExp(level)
    return 75 * level + 75
end

---设置炮塔指向
---@param turretComponentDataIndex integer 索引
---@param targetPos Vector3 目标位置
---@param minDistanceLimit number? 最小水平距离限制
function object.setTurretTowards(turretComponentDataIndex, targetPos, minDistanceLimit)
    -- 获取旋转组件

    local turretCompData = object.turretComponentData[turretComponentDataIndex]
    local turretRotationComp = turretCompData.rotationPart

    -- 判断是否带有可旋转部分
    if turretRotationComp == nil then
        return
    end

    local towardsVec = targetPos - (api.positionOf(turretCompData.rotationPart))

    local XZVector = math.Vector3(towardsVec.x, 0, towardsVec.z)
    local constrainedXZVector = api.vector.resetVectorLength(
        XZVector,
        math.max(
            minDistanceLimit or 10,
            XZVector:length()
        )
    )
    local constrainedTowardsVec = math.Vector3(constrainedXZVector.x, towardsVec.y, constrainedXZVector.z)

    api.extra.setUnitTowardsTo(turretRotationComp, constrainedTowardsVec, turretCompData.towardsReferenceVec)
end

function object.enableMainTurretTowardsToCursor()
    local function handler()
        object.setTurretTowards(1, api.positionOf(camera.cameraBindComponent), constant.MAIN_TURRET_MIN_ATK_DISTANCE)
    end
    object.mainTurretLockToCursorFrameHandlerIndex = api.extra.addFramePreHandler(handler)
end

function object.createEnemyUnit(templateIndex, position, rotation)
    local templateData = object.enemyUnitTemplates[templateIndex]
    return api.createComponent(templateData.presetId, position, rotation, templateData.defaultZoom)
end

---敌方单位攻击
---@param enemyUnitData EnemyUnitData
function object.enemyUnitAtk(enemyUnitData)
    local bulletCreatePosition = api.positionOf(enemyUnitData.base)
    local bulletTemplateIndex = enemyUnitData.bulletTemplateIndex
    local bulletTemplate = object.bulletTemplates[bulletTemplateIndex]
    local towards = math.Vector3(0, 0, 0) - bulletCreatePosition

    local bullet = apiExport.createBullet(bulletTemplateIndex, bulletCreatePosition,
        api.vector.rotationBetweenVec(bulletTemplate.towardsReferenceVec, towards))
    --设置自身碰撞关闭
    api.setUnitCollisionStatusWith(bullet, enemyUnitData.base, false)

    api.setTimeout(function()
        api.setUnitLinerVelocity(bullet, api.vector.resetVectorLength(towards, enemyUnitData.bulletSpeed))

        api.extra.addUnitCollisionListener(bullet, function(selfUnit, withUnit, position)
            apiExport.destroyBullet(1, bullet)
            -- apiExport.createVfx(4136, position)

            object.dealDamageToMainTurret(enemyUnitData.damageValuePerBullet)
        end)
    end, 1)
end

---@param enemyUnit EnemyUnitData
function object.enableEnemyUnitAtkSearch(enemyUnit)
    local enemyUnitAtkInterval = enemyUnit.atkIntervalFrame

    local function delayCallback()
        if enemyUnit.isDestroyed then
            return
        end
        if (api.positionOf(enemyUnit.base) - math.Vector3(0, 80, 0)):length() < constant.ENEMY_ATK_MAX_DISTANCE then
            local bulletNumLoop = 0
            local function bulletLoopCallback()
                if enemyUnit.isDestroyed or bulletNumLoop >= enemyUnit.bulletNumPerAtk then
                    return
                end
                object.enemyUnitAtk(enemyUnit)
                bulletNumLoop = bulletNumLoop + 1
                api.setTimeout(bulletLoopCallback, enemyUnit.bulletIntervalFrame)
            end
            bulletLoopCallback()
        end
        api.setTimeout(delayCallback, enemyUnitAtkInterval)
    end
    delayCallback()
end

---对敌方单位造成伤害
---@param enemyUnitData EnemyUnitData
---@param damageValue integer
function object.dealDamageToEnemyUnit(enemyUnitData, damageValue)
    local multipleDamage = damageValue * object.data.damageMultiple

    object.data.gameStats.totalDamage = object.data.gameStats.totalDamage + multipleDamage

    local realDamage = multipleDamage - enemyUnitData.currentDefense
    if realDamage > 0 then
        local healthAfterDamage = enemyUnitData.currentHealth - realDamage
        if healthAfterDamage < 0 then
            object.defeatEnemyUnit(enemyUnitData)
            return
        end
        enemyUnitData.currentHealth = healthAfterDamage
    end
    enemyUnitData.currentDefense = math.max(0, enemyUnitData.currentDefense - multipleDamage)
    hud.updateTargetInfoIfFocus(enemyUnitData, true)
end

---击败敌方单位
---@param enemyUnitData EnemyUnitData
function object.defeatEnemyUnit(enemyUnitData)
    --特效创建
    --（战火四溅）
    vfxRender.createVfx(2609, api.positionOf(enemyUnitData.base), math.Quaternion(0, 0, 0), 2.0, 1.0, 1.0, false)

    -- 数组移除
    for index, value in ipairs(object.enemyUnitArray) do
        if value == enemyUnitData then
            table.remove(object.enemyUnitArray, index)
            break
        end
    end
    enemyUnitData.isDestroyed = true
    --相机处理
    if camera.updater.targetUnit == enemyUnitData.base then
        camera.updater.cancelLock()
        hud.setCurrentTargetInfoDisplayStatus(false)
    end

    --经验值
    object.addExp(enemyUnitData.exp)

    object.data.gameStats.kill = object.data.gameStats.kill + 1

    hud.updateEnemyNumInfo()

    api.destroyUnit(enemyUnitData.base)
    enemyUnitData.base = nil
end

---comment
---@param targetUnitCurrentPosition Vector3
---@param targetVelocity Vector3
---@param distance number
---@param bulletSpeed number
---@return Vector3
function object.calMovingUnitExpectPosition(
    targetUnitCurrentPosition,
    targetVelocity,
    distance,
    bulletSpeed
)
    local t = distance / bulletSpeed
    local x = (targetVelocity * t):length()
    return api.vector.resetVectorLength(targetVelocity, x) + targetUnitCurrentPosition
end

-- ---计算子弹创建位置
-- ---@deprecated
-- ---@param turretComponentData TurretComponentData
-- ---@param rawOffsetVector Vector3
-- ---@return Vector3
-- local function calBulletCreatePosition(turretComponentData, rawOffsetVector)
--     -- local rawBulletCreateOffset = turretComponentData.bulletCreateOffset
--     local turretRotation = api.rotationOf(turretComponentData.rotationPart)
--     return api.positionOf(turretComponentData.base) + turretComponentData.rotationPartBaseOffset +
--         api.vector.rotateVectorByQuaternion(rawOffsetVector, turretRotation)
-- end

---计算防御塔旋转部分坐标与目标位置连线的方向向量
---@param turretBasePosition Vector3
---@param rotationPartOffset Vector3
---@param targetPosition Vector3
---@return Vector3
local function calTurretTowardsVector(turretBasePosition, rotationPartOffset, targetPosition)
    return targetPosition - (turretBasePosition + rotationPartOffset)
end

---计算防御塔旋转部分的旋转变换角度
---@param turretTowardsReferenceVec any
---@param towardsVec any
---@return Quaternion
local function calTurretRotation(turretTowardsReferenceVec, towardsVec)
    return api.vector.rotationBetweenVec(turretTowardsReferenceVec, towardsVec)
end

---计算子弹创建位置
---@param turretData TurretComponentData
---@param bulletCreateOffsetVec Vector3
---@param turretRotation Quaternion
---@return Vector3
local function calBulletCreatePosition(turretData, bulletCreateOffsetVec, turretRotation)
    return api.positionOf(turretData.base) + turretData.rotationPartBaseOffset +
        api.vector.rotateVectorByQuaternion(bulletCreateOffsetVec, turretRotation)
end


local function calBulletTowardsVector(bulletCreatePosition, targetPosition)
    return targetPosition - bulletCreatePosition
end


function object.mainTurretAtk()
    --判断是否处于冷却状态
    local turretStatusData = object.turretStatusData[1]
    if turretStatusData.coolDownStatus then
        return
    end

    --主塔数据
    local turretData = object.turretComponentData[1]
    local turretPosition = api.positionOf(turretData.base)

    --子弹落点位置
    local bulletTargetPosition = nil
    --判断是否有锁定的目标
    local cameraTargetUnit = camera.updater.targetUnit
    if cameraTargetUnit then
        --目标位置
        local targetUnitPosition = api.positionOf(cameraTargetUnit)
        -- 目标速度
        local targetVel = api.velocityOf(cameraTargetUnit)
        --距离计算(估计)，由于此时未计算子弹创建位置，暂时使用炮塔位置进行计算
        local distance = (targetUnitPosition - turretPosition):length()
        --预计目标位置
        bulletTargetPosition = object.calMovingUnitExpectPosition(
            targetUnitPosition,
            targetVel,
            distance,
            turretData.bulletSpeed
        )
    else
        local cameraPosition = api.positionOf(camera.cameraBindComponent)
        local targetXZPosition = math.Vector3(cameraPosition.x, 0, cameraPosition.z)
        if targetXZPosition:length() < constant.MAIN_TURRET_MIN_ATK_DISTANCE then
            targetXZPosition = api.vector.resetVectorLength(targetXZPosition, constant.MAIN_TURRET_MIN_ATK_DISTANCE)
        end
        bulletTargetPosition = math.Vector3(targetXZPosition.x, cameraPosition.y, targetXZPosition.z)
    end

    local turretTowardsVec = calTurretTowardsVector(turretPosition, turretData.rotationPartBaseOffset,
        bulletTargetPosition)
    local turretRotation = calTurretRotation(turretData.towardsReferenceVec, turretTowardsVec)

    --设置组件旋转
    api.setUnitRotation(turretData.rotationPart, turretRotation)

    --子弹创建位置数据计算
    local bulletCreatePosition = calBulletCreatePosition(turretData, turretData.bulletCreateOffset, turretRotation)
    local bulletTowardsVec = calBulletTowardsVector(bulletCreatePosition, bulletTargetPosition)

    --子弹模板数据
    local bulletTemplate = object.bulletTemplates[turretData.bulletTemplateIndex]

    --子弹旋转
    local bulletRotation = api.vector.rotationBetweenVec(bulletTemplate.towardsReferenceVec, bulletTowardsVec)

    --创建子弹
    local bullet = apiExport.createBullet(1, bulletCreatePosition, bulletRotation)

    --设置子弹禁用护盾碰撞体积
    api.setUnitCollisionStatusWith(bullet, resource.turretCollision, false)

    -- 开火特效
    local effectData = turretData.fireEffectPreset
    vfxRender.createVfx(
        effectData.id,
        bulletCreatePosition + api.vector.resetVectorLength(bulletTowardsVec, effectData.localOffset.x) +
        math.Vector3(0, effectData.localOffset.y, 0),
        api.vector.rotationBetweenVec(effectData.towardsReferenceVec, bulletTowardsVec),
        effectData.zoom,
        effectData.duration,
        effectData.speed,
        false
    )

    -- apiExport.createVfx()

    api.setTimeout(function()
        api.setUnitLinerVelocity(bullet, api.vector.resetVectorLength(bulletTowardsVec, turretData.bulletSpeed))
        local collisionCallback = function(selfUnit, withUnit, position)
            apiExport.destroyBullet(1, bullet)
            -- apiExport.createVfx(4136, position)
            for index, value in ipairs(object.enemyUnitArray) do
                if value.base == withUnit then
                    object.dealDamageToEnemyUnit(value, turretData.damageValuePerBullet)
                end
            end
        end
        -- api.registerUnitTriggerEventListener(bullet, { EVENT.SPEC_OBSTACLE_CONTACT_BEGAN }, collisionCallback)
        api.extra.addUnitCollisionListener(bullet, collisionCallback)
    end, 1)


    -- 进入冷却
    local mainTurretExtraData = object.mainTurretExtraData
    mainTurretExtraData.remainBulletNum = mainTurretExtraData.remainBulletNum - 1

    hud.setBulletNumText(mainTurretExtraData.remainBulletNum)


    if mainTurretExtraData.remainBulletNum <= 0 then
        -- 进入重新装填状态
        turretStatusData.coolDownStatus = true
        hud.setBulletLoadProgress(0, 0.2)
        api.setTimeout(function()
            hud.setBulletLoadProgress(100, (mainTurretExtraData.bulletLoadFrame - 6.0) / constant.LOGIC_FPS)
        end, 6)
        api.setTimeout(function()
            mainTurretExtraData.remainBulletNum = mainTurretExtraData.maxBulletNum
            hud.setBulletNumText(mainTurretExtraData.remainBulletNum)
            turretStatusData.coolDownStatus = false
        end, mainTurretExtraData.bulletLoadFrame)
    else
        hud.setBulletLoadProgress((mainTurretExtraData.remainBulletNum * 100 // mainTurretExtraData.maxBulletNum), 0.2)
        object.turretCoolDown(1, function() end)
    end
end

function object.mainTurretRapidAttack()
    local turretExtData = object.mainTurretExtraData

    if turretExtData.rapidIsCoolDown then
        return
    end

    -- 进入重新装填状态
    turretExtData.rapidIsCoolDown = true

    --更新UI ===================================================================
    hud.setRapidBulletProgress(0, 0.0)

    local timerLoopCount = 0
    local function loadTimer()
        api.setTimeout(function()
            timerLoopCount = timerLoopCount + 5
            hud.setRapidBulletProgress(timerLoopCount / turretExtData.rapidLoadFrame * 100, 5.0 / constant.LOGIC_FPS)
            if timerLoopCount >= turretExtData.rapidLoadFrame then
                return
            end
            loadTimer()
        end, 5)
    end
    loadTimer()

    --装载完成回调
    api.setTimeout(function()
        turretExtData.remainRapidBulletNum = turretExtData.rapidMaxBulletNum
        turretExtData.rapidIsCoolDown = false
        hud.setRapidBulletInfo(turretExtData.remainRapidBulletNum, turretExtData.rapidMaxBulletNum)
        hud.setRapidBulletProgress(100.0, 5.0 / constant.LOGIC_FPS)
    end, turretExtData.rapidLoadFrame)

    --更新UI END ===================================================================

    local turretData = object.turretComponentData[1]
    local turretPosition = api.positionOf(turretData.base)
    local bulletSpeed = turretExtData.rapidBulletSpeed
    local bulletTemplate = object.bulletTemplates[2]

    local function atkLoop()
        turretExtData.leftOrRightSelect = not turretExtData.leftOrRightSelect
        local bulletCreateOffset =
            turretExtData.leftOrRightSelect
            and
            turretExtData.rapidBulletCreateLeftOffset
            or
            turretExtData.rapidBulletCreateRightOffset

        -- local bulletCreatePosition = calBulletCreatePosition(turretComponentData,)

        -- local bulletTargetDirection = calMainTurretBulletTowards(bulletCreatePosition, bulletSpeed)
        -- local bulletRotation = api.vector.rotationBetweenVec(bulletTemplate.towardsReferenceVec, bulletTargetDirection)

        local bulletTargetPosition = nil
        --判断是否有锁定的目标
        local cameraTargetUnit = camera.updater.targetUnit
        if cameraTargetUnit then
            --目标位置
            local targetUnitPosition = api.positionOf(cameraTargetUnit)
            -- 目标速度
            local targetVel = api.velocityOf(cameraTargetUnit)
            --距离计算(估计)，由于此时未计算子弹创建位置，暂时使用炮塔位置进行计算
            local distance = (targetUnitPosition - turretPosition):length()
            --预计目标位置
            bulletTargetPosition = object.calMovingUnitExpectPosition(
                targetUnitPosition,
                targetVel,
                distance,
                bulletSpeed
            )
        else
            local cameraPosition = api.positionOf(camera.cameraBindComponent)
            local targetXZPosition = math.Vector3(cameraPosition.x, 0, cameraPosition.z)
            if targetXZPosition:length() < constant.MAIN_TURRET_MIN_ATK_DISTANCE then
                targetXZPosition = api.vector.resetVectorLength(targetXZPosition, constant.MAIN_TURRET_MIN_ATK_DISTANCE)
            end
            bulletTargetPosition = math.Vector3(targetXZPosition.x, cameraPosition.y, targetXZPosition.z)
        end

        local turretTowardsVec = calTurretTowardsVector(turretPosition, turretData.rotationPartBaseOffset,
            bulletTargetPosition)
        local turretRotation = calTurretRotation(turretData.towardsReferenceVec, turretTowardsVec)

        --设置组件旋转
        api.setUnitRotation(turretData.rotationPart, turretRotation)

        --子弹创建位置数据计算
        local bulletCreatePosition = calBulletCreatePosition(turretData, bulletCreateOffset, turretRotation)
        local bulletTowardsVec = calBulletTowardsVector(bulletCreatePosition, bulletTargetPosition)

        --子弹旋转
        local bulletRotation = api.vector.rotationBetweenVec(bulletTemplate.towardsReferenceVec, bulletTowardsVec)

        --创建子弹
        local bullet = apiExport.createBullet(2, bulletCreatePosition, bulletRotation)

        --设置子弹禁用护盾碰撞体积
        api.setUnitCollisionStatusWith(bullet, resource.turretCollision, false)

        -- 开火特效
        local effectData = turretExtData.fireEffectPreset
        vfxRender.createVfx(
            effectData.id,
            bulletCreatePosition + api.vector.resetVectorLength(bulletTowardsVec, effectData.localOffset.x) +
            math.Vector3(0, effectData.localOffset.y, 0),
            api.vector.rotationBetweenVec(effectData.towardsReferenceVec, bulletTowardsVec),
            effectData.zoom,
            effectData.duration,
            effectData.speed,
            false
        )


        api.setUnitCollisionStatusWith(bullet, resource.turretCollision, false)
        --添加逻辑
        api.setTimeout(function()
            api.setUnitLinerVelocity(bullet, api.vector.resetVectorLength(bulletTowardsVec, bulletSpeed))
            local collisionCallback = function(selfUnit, withUnit, position)
                apiExport.destroyBullet(2, bullet)
                -- apiExport.createVfx(4136, position)

                for index, value in ipairs(object.enemyUnitArray) do
                    if value.base == withUnit then
                        object.dealDamageToEnemyUnit(value, turretExtData.damageValuePerRapidBullet)
                    end
                end
            end
            api.extra.addUnitCollisionListener(bullet, collisionCallback)
        end, 1)


        turretExtData.remainRapidBulletNum = turretExtData.remainRapidBulletNum - 1
        hud.setRapidBulletInfo(turretExtData.remainRapidBulletNum, turretExtData.rapidMaxBulletNum)
        if turretExtData.remainRapidBulletNum <= 0 then
            return
        end
        api.setTimeout(atkLoop, turretExtData.rapidIntervalFrame)
    end
    atkLoop()
end

function object.gameOver()
    logger.info("game over")
    hud.showGameOverUI()
end

function object.dealDamageToMainTurret(damageValue)
    object.data.gameStats.totalDefenseAtk = object.data.gameStats.totalDefenseAtk + damageValue


    local originDefense = object.data.defense
    local realDamage = damageValue - originDefense

    if realDamage > 0 then
        object.data.health = object.data.health - realDamage
    end

    if object.data.health <= 0 then
        object.gameOver()
    end

    object.data.defense = math.max(originDefense - damageValue, 0)

    hud.updateSelfInfo()
end

---生成扫描序列
---@param turretDataArray TurretComponentData
---@param output table
local function generateScanIndexSequence(turretDataArray, output)
    for index = 2, 91 do
        if turretDataArray[index] ~= nil then
            table.insert(output, index)
        end
    end

    api.extra.shuffle(output)
end



function object.enableTurretAutoAtk()
    logger.info("enable turret auto attack")

    -- 初始化扫描索引
    object.turretAutoAtkScanIndexSequence = {}
    generateScanIndexSequence(object.turretComponentData, object.turretAutoAtkScanIndexSequence)

    local frameLoopInterval = constant.TURRET_AUTO_ATK_SCAN_INTERVAL -- 60

    local sequencePointer = 1
    local frameStatusCount = 0

    local function frameLoop()
        if sequencePointer <= #object.turretAutoAtkScanIndexSequence then
            local operationTurretDataIndex = object.turretAutoAtkScanIndexSequence[sequencePointer]
            if frameStatusCount % 2 == 0 and object.turretComponentData[operationTurretDataIndex].enabled then
                object.turretAttack(operationTurretDataIndex)
            end
        end

        frameStatusCount = (frameStatusCount + 1) % frameLoopInterval -- [0, 59]
        sequencePointer = frameStatusCount // 2 + 1
    end

    object.turretAutoAtkScanFrameHandlerIndex = api.extra.addFramePreHandler(frameLoop)
end

local function isAngleInRange(angle, minAngle, maxAngle)
    local range = ((maxAngle - minAngle) % 360 + 360) % 360
    local delta = ((angle - minAngle) % 360 + 360) % 360
    return delta <= range
end

local function searchEnemy(minAngle, maxAngle)
    for index, enemy in ipairs(object.enemyUnitArray) do
        local pos = api.positionOf(enemy.base)
        local angle = api.vector.angleWithX(pos)

        if isAngleInRange(angle, minAngle, maxAngle) then
            return enemy
        end
    end
    return nil
end

---单次子弹攻击
---@param turretData TurretComponentData
---@param targetData EnemyUnitData
local function doTurretBulletAtk(turretData, targetData)
    local targetUnit = targetData.base
    local turretPosition = api.positionOf(turretData.base)
    local targetPosition = api.positionOf(targetData.base)
    local distance = (targetPosition - api.positionOf(turretData.base)):length()

    --估计目标位置
    local expectTargetPosition = object.calMovingUnitExpectPosition(
        targetPosition,
        api.velocityOf(targetUnit),
        distance,
        turretData.bulletSpeed
    )

    local turretTowardsVector = calTurretTowardsVector(turretPosition, turretData.rotationPartBaseOffset,
        expectTargetPosition)
    local turretRotation = calTurretRotation(turretData.towardsReferenceVec, turretTowardsVector)

    --设置炮塔朝向
    api.setUnitRotation(turretData.rotationPart, turretRotation)

    local bulletCreatePosition = calBulletCreatePosition(turretData, turretData.bulletCreateOffset, turretRotation)

    --计算子弹朝向
    local bulletTowardsVec = calBulletTowardsVector(bulletCreatePosition, expectTargetPosition)

    --获取子弹模板数据
    local bulletTemplate = object.bulletTemplates[turretData.bulletTemplateIndex]

    --创建开火特效
    local effectData = turretData.fireEffectPreset
    vfxRender.createVfx(

        effectData.id,
        bulletCreatePosition + api.vector.resetVectorLength(bulletTowardsVec, effectData.localOffset.x) +
        math.Vector3(0, effectData.localOffset.y, 0),
        api.vector.rotationBetweenVec(effectData.towardsReferenceVec, bulletTowardsVec),
        effectData.zoom,
        effectData.duration,
        effectData.speed,
        false
    )

    --创建子弹模型
    local bullet = apiExport.createBullet(
        turretData.bulletTemplateIndex,
        bulletCreatePosition,
        api.vector.rotationBetweenVec(bulletTemplate.towardsReferenceVec, bulletTowardsVec))

    api.setUnitCollisionStatusWith(bullet, resource.turretCollision, false)
    -- 延迟创建子弹逻辑
    api.setTimeout(function()
        ---@diagnostic disable-next-line: param-type-mismatch
        api.setUnitLinerVelocity(bullet, api.vector.resetVectorLength(bulletTowardsVec, turretData.bulletSpeed))
        local collisionCallback = function(selfUnit, withUnit, position)
            apiExport.destroyBullet(1, bullet)
            for _, value in ipairs(object.enemyUnitArray) do
                if value.base == withUnit then
                    object.dealDamageToEnemyUnit(value, turretData.damageValuePerBullet)
                end
            end
        end
        -- api.registerUnitTriggerEventListener(bullet, { EVENT.SPEC_OBSTACLE_CONTACT_BEGAN }, collisionCallback)
        ---@diagnostic disable-next-line: param-type-mismatch
        api.extra.addUnitCollisionListener(bullet, collisionCallback)
    end, 1)
end

---连续攻击
---@param turretData TurretComponentData
---@param targetData EnemyUnitData
local function doTurretContinuousAtk(turretData, targetData)
    local interval = turretData.atkCoolDownFrame
    local atkCount = 0
    local atkMaxCount = turretData.consecutiveShotCount

    local function delayCallback()
        if atkCount >= atkMaxCount or targetData.isDestroyed then
            return
        end
        doTurretBulletAtk(turretData, targetData)

        atkCount = atkCount + 1

        ---@diagnostic disable-next-line: param-type-mismatch
        api.setTimeout(delayCallback, interval)
    end

    delayCallback()
end

---激光攻击
---@param turretData TurretComponentData
---@param targetData EnemyUnitData
local function doTurretLaserAtk(turretData, targetData)
    --炮塔朝向
    if turretData.rotationPart ~= nil then
        local turretTowardsVec = calTurretTowardsVector(api.positionOf(turretData.base),
            turretData.rotationPartBaseOffset, api.positionOf(targetData.base))
        local turretRotation = calTurretRotation(turretData.towardsReferenceVec, turretTowardsVec)
        api.setUnitRotation(turretData.rotationPart, turretRotation)
    end

    bridgeLib.createLaserVfx(turretData.laserSocket, targetData.base, 0.7)
    object.dealDamageToEnemyUnit(targetData, turretData.damageValuePerBullet)
end



function object.turretAttack(turretDataIndex)
    local turretData = object.turretComponentData[turretDataIndex]
    if turretData == nil then
        return
    end

    local targetEnemy = searchEnemy(turretData.searchEnemyAngle.min, turretData.searchEnemyAngle.max)
    if targetEnemy == nil then
        return
    end

    if turretData.atkMethodType == 1 then
        doTurretBulletAtk(turretData, targetEnemy)
    elseif turretData.atkMethodType == 2 then
        doTurretContinuousAtk(turretData, targetEnemy)
    elseif turretData.atkMethodType == 3 then
        doTurretLaserAtk(turretData, targetEnemy)
    end
end

-- ---搜索半径内敌方单位
-- ---@param centerPos Vector3
-- ---@param radius number
-- function object.searchEnemy(centerPos, radius)
--     local stdCenterPos = centerPos
--     stdCenterPos.y = 0
--     for index, value in ipairs(object.enemyUnitArray) do
--         local stdEnemyUnitPos = api.positionOf(value.base)
--         stdEnemyUnitPos.y = 0

--         if (stdCenterPos - stdEnemyUnitPos):length() <= radius then
--             return value
--         end
--     end
-- end


-- ---单次子弹攻击操作
-- ---@param turretData TurretComponentData
-- ---@param targetEnemyUnitData EnemyUnitData
-- local function doTurretBulletAtk(turretData, targetEnemyUnitData)
--     local bulletCreatePosition = calBulletCreatePosition(turretData, turretData.bulletCreateOffset)

--     --计算子弹朝向
--     local towards = calTurretBulletTowards(bulletCreatePosition, turretData.bulletSpeed, targetEnemyUnitData.base)

--     --设置炮塔朝向
--     api.setUnitRotation(turretData.rotationPart,
--         api.vector.rotationBetweenVec(turretData.towardsReferenceVec, towards))

--     --获取子弹模板数据
--     local bulletTemplate = object.bulletTemplates[turretData.bulletTemplateIndex]

--     --创建开火特效
--     local effectData = turretData.fireEffectPreset
--     vfxRender.createVfx(
--         effectData.id,
--         bulletCreatePosition + api.vector.resetVectorLength(towards, effectData.localOffset.x) +
--         math.Vector3(0, effectData.localOffset.y, 0),
--         api.vector.rotationBetweenVec(effectData.towardsReferenceVec, towards),
--         effectData.zoom,
--         effectData.duration,
--         effectData.speed,
--         false
--     )
--     local bullet = nil
--     -- 子弹模型创建
--     api.setTimeout(function()
--         bullet = apiExport.createBullet(
--             turretData.bulletTemplateIndex,
--             bulletCreatePosition,
--             api.vector.rotationBetweenVec(bulletTemplate.towardsReferenceVec, towards))
--     end, 1)


--     -- 延迟创建子弹逻辑
--     api.setTimeout(function()
--         ---@diagnostic disable-next-line: param-type-mismatch
--         api.setUnitLinerVelocity(bullet, api.vector.resetVectorLength(towards, turretData.bulletSpeed))
--         local collisionCallback = function(selfUnit, withUnit, position)
--             apiExport.destroyBullet(1, bullet)
--             -- apiExport.createVfx(4136, position)
--             for index, value in ipairs(object.enemyUnitArray) do
--                 if value.base == withUnit then
--                     object.dealDamageToEnemyUnit(value, turretData.damageValuePerBullet)
--                 end
--             end
--         end
--         -- api.registerUnitTriggerEventListener(bullet, { EVENT.SPEC_OBSTACLE_CONTACT_BEGAN }, collisionCallback)
--         ---@diagnostic disable-next-line: param-type-mismatch
--         api.extra.addUnitCollisionListener(bullet, collisionCallback)
--     end, 2)
-- end


-- ---单次激光攻击操作
-- ---@param turretData TurretComponentData
-- ---@param targetEnemyUnitData EnemyUnitData
-- local function doTurretLaserAtk(turretData, targetEnemyUnitData)
--     --炮塔朝向
--     if turretData.rotationPart ~= nil then
--         local bulletCreatePosition = calBulletCreatePosition(turretData, turretData.bulletCreateOffset)
--         --计算炮塔朝向
--         local towards = calTurretBulletTowards(bulletCreatePosition, turretData.bulletSpeed, targetEnemyUnitData.base)
--         api.setUnitRotation(turretData.rotationPart,
--             api.vector.rotationBetweenVec(turretData.towardsReferenceVec, towards))
--     end

--     ---@diagnostic disable-next-line: param-type-mismatch
--     bridgeLib.createLinkedVfx(nil, turretData.laserSocket, nil, targetEnemyUnitData.base, nil, 3)
--     object.dealDamageToEnemyUnit(targetEnemyUnitData, turretData.damageValuePerBullet)
-- end


-- ---comment
-- ---@param turretComponentDataIndex integer
-- ---@param targetEnemyUnitData EnemyUnitData
-- function object.turretAtk(turretComponentDataIndex, targetEnemyUnitData)
--     local turretData = object.turretComponentData[turretComponentDataIndex]

--     if turretData.atkMethodType == 1 then
--         doTurretBulletAtk(turretData, targetEnemyUnitData)
--     elseif turretData.atkMethodType == 2 then
--         local count = 0
--         local function delayCallback()
--             if count >= turretData.consecutiveShotCount or targetEnemyUnitData.isDestroyed then
--                 return
--             end
--             doTurretBulletAtk(turretData, targetEnemyUnitData)
--             count = count + 1
--             api.setTimeout(delayCallback, 7)
--         end
--         delayCallback()
--     else
--         doTurretLaserAtk(turretData, targetEnemyUnitData)
--     end
-- end

-- function object.activeTurretAutoAtk(turretComponentDataIndex)
--     local turretData = object.turretComponentData[turretComponentDataIndex]
--     local function atkIntervalCallback()
--         print("atk callback")
--         local searchEnemyAngle = turretData.searchEnemyAngle

--         local stdAngleMax = (searchEnemyAngle.max - searchEnemyAngle.min) % 360

--         for index, value in ipairs(object.enemyUnitArray) do
--             local enemyAngle = math.ceil(api.vector.angleWithX(api.positionOf(value.base)))

--             if (enemyAngle - searchEnemyAngle.min) % 360 <= stdAngleMax then
--                 print("atk")
--                 object.turretAtk(turretComponentDataIndex, value)
--                 break
--             end
--         end

--         api.setTimeout(atkIntervalCallback, turretData.atkCoolDownFrame)
--     end
--     atkIntervalCallback()
-- end

---激活防御塔
function object.enableTurret(turretDataIndex)
    object.turretComponentData[turretDataIndex].enabled = true
    logger.debug("active turret: " .. turretDataIndex)
end

function object.activeDefense()
    api.setUnitVisible(resource.turretCollision, true)
    -- api.createVFX(2207, math.Vector3(0, -20, 0), math.Quaternion(0, 0, 0), 50.0, 999999.0, 0.2, false)
end

---用于升级后激活防御塔
---@param turretDataIndex integer
function object.levelUpActiveTurret(turretDataIndex)
    api.addLinearMotor(object.baseHexComponent[turretDataIndex], math.Vector3(0, 20, 0), 4.0, false)

    local turretData = object.turretComponentData[turretDataIndex]
    api.setTimeout(function()
        if turretData ~= nil then
            object.enableTurret(turretDataIndex)
        end
    end, 5 * constant.LOGIC_FPS)
end

function object.levelUpHandler()
    --激活防御塔
    if object.isLayerUpLevel(object.data.level) then
        object.data.layer = object.data.layer + 1
        local minIndex = object.calHexArrayIndexMinByLayer(object.data.layer)
        local maxIndex = object.calHexArrayIndexMaxByLayer(object.data.layer)

        local delay = 0
        for i = minIndex, maxIndex do
            api.setTimeout(function()
                object.levelUpActiveTurret(i)
            end, 15 * delay)
            delay = delay + 1
        end
    end

    --恢复护盾和生命值
    object.data.defense = object.data.maxDefense
    object.data.health = math.min(
        object.data.health + math.tointeger(object.data.maxHealth * 0.2),
        object.data.maxHealth
    )
    hud.updateSelfInfo()
end

function object.addExp(value)
    local expSum = object.data.currentExp + value


    if expSum >= object.data.totalExp then
        object.data.level = object.data.level + 1
        object.data.currentExp = expSum - object.data.totalExp
        object.data.totalExp = object.getCurrentLevelExp(object.data.level)
        object.levelUpHandler()
        logger.info("level up")
    else
        object.data.currentExp = expSum
    end

    hud.updateLevelInfo()
end

function object.resurrect()
    object.data.health = object.data.maxHealth
    object.data.defense = object.data.maxDefense
    hud.hideGameOverUI()
end

-- test
-- object.enemyUnitArray[1].base = api.getUnitById(1912830340)

--游戏相机======================================================================

camera.cameraBindComponent = nil
camera.minCameraDistance = 50
camera.cameraTowards = math.Vector3(-0.57735, -0.57735, -0.57735)
camera.cameraSpeed = 60
camera.cameraDefaultHeight = 80

camera.cameraSmoothFactor = 1
camera.defaultCameraMoveMotorIndex = 0

camera.isCtrlMoving = false

camera.updater = {
    ---@type Unit
    targetUnit = nil,
    updateFrameInterval = 5,
    running = false,
    updaterFrameHandlerIndex = nil
}


function camera.updater.lockTo(unit)
    camera.updater.targetUnit = unit
    hud.setCursorStatus(constant.cursorStatusEnum.LOCKED)
end

--- 相机随帧更新
function camera.updater.run()
    --- 加互斥锁，防止多次进入重复创建帧回调导致StackOverflow

    if camera.updater.running then
        return
    end

    camera.updater.running = true

    local function updateCamera()
        if camera.isCtrlMoving then
            camera.updater.cancelLock()
            camera.updater.running = false
            return
        end

        if camera.updater.targetUnit == nil then
            camera.updater.running = false
            return
        end

        local targetPosition = api.positionOf(camera.updater.targetUnit)
        local currentPosition = api.positionOf(camera.cameraBindComponent)
        camera.stepSmoothMove(currentPosition, targetPosition, camera.updater.updateFrameInterval)
        hud.updateCameraPosition(currentPosition)

        api.setTimeout(updateCamera, camera.updater.updateFrameInterval)
    end

    updateCamera()
end

function camera.updater.cancelLock()
    if camera.updater.targetUnit == nil then
        return
    end

    if not camera.isCtrlMoving then
        api.setLinerMotorVelocity(
            camera.cameraBindComponent,
            camera.defaultCameraMoveMotorIndex,
            math.Vector3(0, 0, 0),
            false
        )
        api.disableMotor(camera.cameraBindComponent, camera.defaultCameraMoveMotorIndex)
    end

    camera.updater.targetUnit = nil
    hud.setCursorStatus(constant.cursorStatusEnum.NORMAL)
    logger.debug("camera updater set to disabled.")
end

---返回单位方向向量
function camera.slidAngleTransform(angle)
    local rad = math.pi * angle / 180
    -- 屏幕坐标
    local dxScreen = math.sin(rad)
    local dzScreen = -math.cos(rad)
    -- 旋转-135度映射到世界x-z
    local theta = -math.pi * 135 / 180
    local dx = dxScreen * math.cos(theta) - dzScreen * math.sin(theta)
    local dz = dxScreen * math.sin(theta) + dzScreen * math.cos(theta)

    return math.Vector3(dx, 0, dz)
end

---初始化
function camera.init()
    camera.cameraBindComponent = resource.gameCameraBindUnit
    api.setPosition(camera.cameraBindComponent, math.Vector3(50, 80, 50))

    api.setCameraBindMode(Player, Enums.CameraBindMode.BIND)
    api.setCameraFollowUnit(Player, camera.cameraBindComponent, false)
    api.setCameraProperties(Player, {
        [Enums.CameraPropertyType.BIND_MODE_OFFSET_X] = (-camera.minCameraDistance * camera.cameraTowards).x,
        [Enums.CameraPropertyType.BIND_MODE_OFFSET_Y] = (-camera.minCameraDistance * camera.cameraTowards).y,
        [Enums.CameraPropertyType.BIND_MODE_OFFSET_Z] = (-camera.minCameraDistance * camera.cameraTowards).z,
        [Enums.CameraPropertyType.DIST] = 50.0,
        [Enums.CameraPropertyType.BIND_MODE_YAW] = -135.0,
        [Enums.CameraPropertyType.BIND_MODE_PITCH] = 35.0,
        [Enums.CameraPropertyType.FOV] = 60.0
    })

    bridgeLib.createLinkedVfx(object.turretComponentData[1].rotationPart, camera.cameraBindComponent)
end

---@param vec Vector3 单位方向向量
function camera.move(vec)
    local moveVec = vec * camera.cameraSpeed
    api.setLinerMotorVelocity(camera.cameraBindComponent, camera.defaultCameraMoveMotorIndex, moveVec, false)
end

---@param startPos Vector3
---@param endPos Vector3
function camera.stepSmoothMove(startPos, endPos, duration)
    if (endPos - startPos):length() < 0.5 then
        return
    end

    local stepPos = api.vector.lerpVec3(startPos, endPos, camera.cameraSmoothFactor)
    api.setLinerMotorVelocity(camera.cameraBindComponent, camera.defaultCameraMoveMotorIndex,
        (stepPos - startPos) * constant.LOGIC_FPS / duration, false)
end

---@param enemyUnitData EnemyUnitData
function camera.lockToUnit(enemyUnitData)
    camera.updater.lockTo(enemyUnitData.base)
    camera.updater.run()

    hud.setCurrentTargetInfo(enemyUnitData.currentHealth, enemyUnitData.maxHealth, false, enemyUnitData.currentDefense,
        enemyUnitData.maxDefense)
    hud.setCurrentTargetInfoDisplayStatus(true)

    logger.debug("camera locked.")
end

function camera.cancelLock()
    camera.updater.cancelLock()
    hud.setCurrentTargetInfoDisplayStatus(false)
    logger.debug("camera cancel lock.")
end

function camera.ctrlMoveStop()
    camera.isCtrlMoving = false

    -- 停止运动（此处清除的是由ctrlMove引起的速度向量）
    api.setLinerMotorVelocity(
        camera.cameraBindComponent,
        camera.defaultCameraMoveMotorIndex,
        math.Vector3(0, 0, 0),
        false
    )

    hud.updateCameraPosition(api.positionOf(camera.cameraBindComponent))

    logger.debug("camera stop.")

    if object.data.gameSettings.autoAimEnabled then
        -- 搜索敌方单位
        for _, value in ipairs(object.enemyUnitArray) do
            if (api.positionOf(camera.cameraBindComponent) - api.positionOf(value.base)):length() < constant.CAMERA_ADSORBED_DISTANCE then
                camera.lockToUnit(value)
                break
            end
        end
    end
end

function camera.handlerCameraStopCtrlMoveEvent()
    -- 判断是否是开火动作
    -- isCtrlMoving为false表示没有拖动操作
    -- 此时为开火动作
    if not camera.isCtrlMoving then
        object.mainTurretAtk()
        if (api.positionOf(camera.cameraBindComponent) - math.Vector3(0, constant.GLOBAL_BASE_HEIGHT, 0)):length() < constant.MAIN_TURRET_MIN_ATK_DISTANCE then
            hud.setCursorStatus(constant.cursorStatusEnum.WARN)
        end

        return
    end

    camera.ctrlMoveStop()
end

---控制相机朝方向移动
---如果开启了高度检查，相机开始移动后的一帧会卡一下
---@param towards Vector3 相机移动方向
---@param restoreInitHeight boolean 开启相机所在平面校准，会自动检查相机高度并校准
function camera.ctrlMove(towards, restoreInitHeight)
    camera.isCtrlMoving = true
    -- hud.setCursorStatus(constant.hudStatusEnum.NORMAL)

    hud.setCurrentTargetInfoDisplayStatus(false)

    if restoreInitHeight then
        local expectPosition = api.positionOf(camera.cameraBindComponent)
        expectPosition.y = camera.cameraDefaultHeight
        api.setPosition(camera.cameraBindComponent, expectPosition)
    end

    camera.move(towards)
end

-- HUD =========================================================================

---更新相机位置
---@param position Vector3
function hud.updateCameraPosition(position)
    local text = string.format("[ x = %.3f, y = %.3f, z = %.3f ]", position.x, position.y, position.z)
    api.sendGlobalCustomEvent(constant.UI_BRIDGE_UPDATE_CAMERA_POS, { text = text })
end

---设置准星状态
function hud.setCursorStatus(status)
    api.sendGlobalCustomEvent(constant.UI_BRIDGE_SET_CURSOR_STATUS, { status = status })
end

---@deprecated
function hud.updateTargetInfo(totalHealth, currentHealth, totalDefense, currentDefense, healthSmearDuration)
    api.sendGlobalCustomEvent(constant.UI_BRIDGE_SET_TARGET_INFO, {
        maxHealth = totalHealth,
        maxDefense = totalDefense,
        currentHealth = currentHealth,
        currentDefense = currentDefense,
        healthSmearDuration = healthSmearDuration,
    })
end

function hud.updateSelfInfo()
    local totalHealth = object.data.maxHealth
    local currentHealth = object.data.health
    local totalDefense = object.data.maxDefense
    local currentDefense = object.data.defense

    api.setUIProgressBarData(Player, "1519736575|1156235444", currentHealth, totalHealth, 0.3)
    api.setUIProgressBarData(Player, "1519736575|1943658332", currentDefense, totalDefense, 0.3)
end

---@deprecated
function hud.updateMatrixStatusInfo(activeNodeNum, totalNodeNum, level)
    api.sendGlobalCustomEvent(constant.UI_BRIDGE_SET_MATRIX_INFO, {
        activeNodeNum = activeNodeNum,
        totalNodeNum = totalNodeNum,
        level = level
    })
end

function hud.updateUIAutoAimStatus(status)
    api.sendGlobalCustomEvent(constant.UI_BRIDGE_SET_AUTO_AIM_STATUS, { status = status })
end

function hud.registerListener()
    -- 注册自动锁敌功能状态切换事件
    api.registerGlobalCustomEventListener(constant.UI_SWITCH_AUTO_AIM_STATUS_EVENT, function()
        local status = not object.data.gameSettings.autoAimEnabled
        object.data.gameSettings.autoAimEnabled = status

        if not status then
            camera.updater.cancelLock()
        end

        hud.updateUIAutoAimStatus(status)
    end)
end

function hud.fullUpdate()
    hud.updateUIAutoAimStatus(object.data.gameSettings.autoAimEnabled)
    hud.updateLevelInfo()
    hud.updateSelfInfo()
end

function hud.setBulletLoadProgress(percentage, duration)
    api.sendGlobalCustomEvent(constant.UI_BRIDGE_SET_BULLET_LOAD_PROGRESS,
        { percentage = percentage, duration = duration })
end

function hud.setBulletNumText(num)
    api.setUILabelText(Player, "1519736575|2033443810", tostring(num))
end

---注意，这个函数使用的参数是浮点数而非整数
---@param percentage number
---@param duration number
function hud.setRapidBulletProgress(percentage, duration)
    api.sendGlobalCustomEvent(constant.UI_BRIDGE_SET_RAPID_BULLET_PROGRESS,
        { percentage = percentage, duration = duration })
end

function hud.setRapidBulletInfo(currentBulletNum, maxBulletNum)
    api.sendGlobalCustomEvent(constant.UI_BRIDGE_SET_RAPID_BULLET_DATA,
        { remainRapidBulletNum = currentBulletNum, maxRapidBulletNum = maxBulletNum })
    -- hud.setBulletLoadProgress(currentBulletNum * 100 // maxBulletNum, 0.1)
end

function hud.setCurrentTargetInfo(currentHealth, maxHealth, smearEnabled, currentDefense, maxDefense)
    api.setUIProgressBarData(Player, "1519736575|1722939135", currentHealth, maxHealth, 0.0)
    if smearEnabled then
        api.setUIProgressBarData(Player, "1519736575|1220800494", currentHealth, maxHealth, 0.4)
    else
        api.setUIProgressBarData(Player, "1519736575|1220800494", currentHealth, maxHealth, 0.3)
    end

    api.setUIProgressBarData(Player, "1519736575|1653360581", currentDefense, maxDefense, 0.3)
end

---设置目标信息是否显示
---@param visible any
function hud.setCurrentTargetInfoDisplayStatus(visible)
    api.setUINodeVisibleStatus(Player, "1519736575|1376576541", visible)
end

---如果是目标，就更新targetInfo
---@param enemyUnitData EnemyUnitData
function hud.updateTargetInfoIfFocus(enemyUnitData, smearEnabled)
    if camera.updater.targetUnit == enemyUnitData.base then
        hud.setCurrentTargetInfo(enemyUnitData.currentHealth, enemyUnitData.maxHealth, smearEnabled,
            enemyUnitData.currentDefense, enemyUnitData.maxDefense)
    end
end

function hud.updateLevelInfo()
    local data = object.data

    --设置等级信息
    local levelString = "LEVEL: "
    if data.level < 10 then
        levelString = levelString .. "0"
    end
    levelString = levelString .. tostring(data.level)

    api.setUILabelText(Player, "1519736575|2102862090", tostring(data.level))
    api.setUILabelText(Player, "1519736575|1117223670", levelString)

    --设置经验值信息
    local maxExp = data.totalExp
    local currentExp = data.currentExp

    api.setUILabelText(Player, "1519736575|1902544434", tostring(currentExp) .. " / " .. tostring(maxExp))

    --设置经验进度条
    api.setUIProgressBarData(Player, "1519736575|1049374565", currentExp, maxExp, 0.3)
end

function hud.updateEnemyNumInfo()
    local currentEnemyCount = #object.enemyUnitArray
    local maxEnemyUnitNum = constant.ENEMY_UNIT_MAX_NUM

    local labelText = ""

    if currentEnemyCount < 10 then
        labelText = labelText .. "00"
    else
        labelText = labelText .. "0"
    end

    labelText = labelText .. currentEnemyCount .. " / " .. "0" .. maxEnemyUnitNum



    api.setUILabelText(Player, "1519736575|1860759049", labelText)
    api.setUIProgressBarData(Player, "1519736575|1591783785", currentEnemyCount, maxEnemyUnitNum, 0.4)
end

local gameOverUIShowStatus = false


function hud.showGameOverUI()
    if gameOverUIShowStatus then
        return
    end

    local buffer = ""
    buffer = buffer .. "击败敌人数 DEFEATED     " .. object.data.gameStats.kill .. "\n"
    buffer = buffer .. "总伤害 TOTAL DAMAGE     " .. object.data.gameStats.totalDamage .. "\n"
    buffer = buffer .. "总承受伤害 TAKE DAMAGE  " .. object.data.gameStats.totalDefenseAtk .. "\n"
    buffer = buffer ..
        "每秒伤害 DPS            " .. math.tointeger(object.data.gameStats.totalDamage / object.data.timeCount)


    api.setUILabelText(Player, "1519736575|1052370863", buffer)

    api.sendUICustomEvent(Player, "UI_SHOW_GAME_OVER", {})
    gameOverUIShowStatus = true
end

function hud.hideGameOverUI()
    gameOverUIShowStatus = false
    api.sendUICustomEvent(Player, "UI_HIDE_GAME_OVER", {})
end

function hud.updateTimer()
    local timerCount = object.data.timeCount
    local sec = timerCount % 60
    local secString = sec < 10 and "0" .. tostring(sec) or tostring(sec)

    timerCount = timerCount // 60

    local min = timerCount % 60
    local minString = min < 10 and "0" .. tostring(min) or tostring(min)

    timerCount = timerCount // 60

    local hour = timerCount % 60
    local hourString = hour < 10 and "0" .. tostring(hour) or tostring(hour)

    api.setUILabelText(Player, "1519736575|1675256029", hourString .. ":" .. minString .. ":" .. secString)
end

-- scene =======================================================================
scene.random = api.random.new(666)

function scene.gameStartHexRunMotor()
    local iterationMaxIndex = object.calHexArrayIndexMaxByLayer(object.data.layer)
    local delayOffset = 0
    local delayOffsetStep = 10 * constant.LOGIC_FPS / (iterationMaxIndex - 2)

    for i = 2, iterationMaxIndex do
        api.setTimeout(function()
            api.addLinearMotor(object.baseHexComponent[i], math.Vector3(0, 20, 0), 4.0, false)
        end, delayOffset)

        ---@diagnostic disable-next-line: cast-local-type
        delayOffset = math.tointeger(delayOffset + delayOffsetStep)
    end
end

function scene.gameStartActiveTurret()
    for iterator = 2, object.calHexArrayIndexMaxByLayer(object.data.layer) do
        if not (object.turretComponentData[iterator] == nil) then
            object.enableTurret(iterator)
        end
    end
    logger.info("game start turret active")
end

function scene.generateEnemyUnit()
    logger.debug("start enemy unit generate")
    local minEnemyUnitTemplateIndex = object.getEnemyTemplateMinIndexByLevel()
    local maxEnemyUnitTemplateIndex = object.getEnemyTemplateMaxIndexByLevel()
    local scope = maxEnemyUnitTemplateIndex - minEnemyUnitTemplateIndex + 1

    local generateIndex = scene.random:nextInt() % scope + minEnemyUnitTemplateIndex
    local height = constant.GLOBAL_BASE_HEIGHT
    local centerDistance = constant.ENEMY_GENERATE_CENTER_DISTANCE

    -- 随机正方形分布
    local center = math.Vector3(scene.random:nextFloat() * 2 - 1, 0, scene.random:nextFloat() * 2 - 1)

    -- 求环绕圆心坐标
    center = api.vector.normalizeVec(center)
    center = center * centerDistance
    center.y = height

    -- 求环绕圆心向量
    local radiusVec = center - math.Vector3(0, height, 0)
    radiusVec.y = 0

    -- 求敌方单位创建位置
    local initialPos = radiusVec * 3
    initialPos.y = height

    -- 初始朝向
    local isClockwise = scene.random:nextBoolean()
    local initialTowards = nil
    local angularVelocity = nil
    if isClockwise then
        initialTowards = math.Vector3(radiusVec.z, 0, -radiusVec.x)
        angularVelocity = math.Vector3(0, constant.ENEMY_ANGULAR_SPEED_RATE, 0)
    else
        initialTowards = math.Vector3(-radiusVec.z, 0, radiusVec.x)
        angularVelocity = math.Vector3(0, -constant.ENEMY_ANGULAR_SPEED_RATE, 0)
    end

    local enemyUnitTemplate = object.enemyUnitTemplates[generateIndex]
    local rotation = api.vector.rotationBetweenVec(enemyUnitTemplate.towardsReferenceVector, initialTowards)

    local enemyUnitProperties = object.enemyUnitProperties[generateIndex]

    local centerComponent = nil
    local enemyUnitBase = nil

    -- 创建初始特效
    api.setTimeout(function()
        vfxRender.createVfx(4191, initialPos, math.Quaternion(0, 0, 0), 3.0, 6.0, 1.0, false)
        logger.debug("enemy unit initial vfx created")
    end, 1)

    -- 创建中心组件
    api.setTimeout(function()
        centerComponent = api.createComponent(1101635, center, math.Quaternion(0, 0, 0), math.Vector3(1, 1, 1))
        logger.debug("enemy unit center unit created")
    end, 2)

    -- 创建模型
    api.setTimeout(function()
        enemyUnitBase = object.createEnemyUnit(generateIndex, initialPos, rotation)
        logger.debug("enemy unit model created")
    end, 3)

    -- 添加运动
    api.setTimeout(function()
        ---@diagnostic disable-next-line: param-type-mismatch
        api.addSurroundMotor(enemyUnitBase, centerComponent, angularVelocity, 9999.0, true)
        logger.debug("enemy unit motor created")
    end, 4)

    --数据写入enemyUnitArray
    api.setTimeout(function()
        ---@type EnemyUnitData
        local enemyUnitData = {
            ---@diagnostic disable-next-line: assign-type-mismatch
            base = enemyUnitBase,
            ---@diagnostic disable-next-line: assign-type-mismatch
            centerComponent = centerComponent,
            templateIndex = generateIndex,
            currentHealth = enemyUnitProperties.maxHealthValue,
            currentDefense = enemyUnitProperties.maxDefenseValue,
            maxHealth = enemyUnitProperties.maxHealthValue,
            maxDefense = enemyUnitProperties.maxDefenseValue,
            bulletTemplateIndex = enemyUnitProperties.bulletTemplateIndex,
            bulletSpeed = enemyUnitProperties.bulletSpeed,
            damageValuePerBullet = enemyUnitProperties.damageValuePerBullet,
            atkIntervalFrame = enemyUnitProperties.atkIntervalFrame,
            isDestroyed = false,
            bulletNumPerAtk = enemyUnitProperties.bulletNumPerAtk,
            bulletIntervalFrame = enemyUnitProperties.bulletIntervalFrame,
            exp = enemyUnitProperties.exp
        }

        table.insert(
            object.enemyUnitArray, enemyUnitData)

        hud.updateEnemyNumInfo()

        object.enableEnemyUnitAtkSearch(enemyUnitData)

        logger.debug("enemy unit finished")
    end, 6)

    logger.debug("enemy unit create prepared")
end

function scene.initEnemyUnitGenerator()
    local function delayCallback()
        if #object.enemyUnitArray < constant.ENEMY_UNIT_MAX_NUM then
            scene.generateEnemyUnit()
        else
            logger.info("<enemy unit generator> the maximum number (" ..
                constant.ENEMY_UNIT_MAX_NUM .. ") of units in the scene has been reached.")
        end
        api.setTimeout(delayCallback, scene.random:nextIntBound(10 * constant.LOGIC_FPS) + 5 * constant.LOGIC_FPS)
        -- debug
        -- api.setTimeout(delayCallback, 2)
    end
    api.setTimeout(delayCallback, 20 * constant.LOGIC_FPS)
end

function scene.init()
    scene.gameStartActiveTurret()
    -- 开启炮塔自动攻击
    api.setTimeout(object.enableTurretAutoAtk, 15 * constant.LOGIC_FPS)
    object.activeDefense()
end

-- END==========================================================================


return {
    setComponentCacheCreateStatus = setComponentCacheCreateStatus,
    camera = camera,
    frame = frame,
    hud = hud,
    object = object,
    scene = scene
}
