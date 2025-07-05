local constant = require("constant")
local api      = require("api")
local logger   = require("api").logger

local object   = {}
local frame    = {}
local camera   = {}
local hud      = {}
local scene    = {}



-- 场景单位=====================================================================
-- 游戏数据，runtime & save data
object.data = {
    --游戏时长（秒）
    timeCount = 0,

    --等级
    level = 1,

    --层数
    layer = 6,

    --生命值
    health = 300,

    --护盾值
    defense = 600,

    --能量值
    energy = 50,

    --游戏存档数据格式版本
    version = 1,

    --总经验值
    totalExp = 0,

    --游戏统计数据
    gameStats = {
        --击败敌人数
        kill = 0,
        --总伤害
        totalDamage = 0,
        --总承伤
        totalDefenseAtk = 0,
    },

    gameSettings = {
        autoAimEnabled = true
    }

}

---@class EnemyUnitData
---@field base Unit
---@field centerComponent Unit
---@field templateIndex integer
---@field currentHealth integer
---@field currentDefense integer
---@field maxHealth integer
---@field maxDefense integer

---敌方单位数组
---@type EnemyUnitData[]
object.enemyUnitArray = {}
---阵基组件数组
---@type Unit[]
object.baseHexComponent = {}

-- 炮台组件数据对象数组
object.turretComponentData = {}

-- 主炮台朝向光标帧更新处理器索引
object.mainTurretCursorFrmHandlerIndex = nil


object.enemyUnitTemplate = {}

object.enemyUnitProperties = {}

function object.loadArchiveData(data)
    for key, value in pairs(object.data) do
        object.data[key] = data[key] or value
    end
end

---初始化游戏对象
function object.init(archiveData)
    object.loadArchiveData(archiveData)
    local resource = require("resource")
    ---@type Unit[]
    object.baseHexComponent = resource.baseHexComponent
    object.turretComponentData = resource.turretComponentData
    object.enemyUnitTemplate = resource.enemyUnitTemplate
    object.enemyUnitProperties = resource.enemyUnitProperties
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
    return (level + 2) / 3
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
    return 3 * layer ^ 2 - 9 * layer + 8
end

-- index.max = layer == 1 ? 1 : 3 * layer ^ 2 - 3 * layer + 1
function object.calHexArrayIndexMaxByLayer(layer)
    if (layer == 1) then
        return 1
    end
    return 3 * layer ^ 2 - 3 * layer + 1;
end

-- 敌方单位的等级和游戏等级的关系
function object.getEnemyTemplateMinIndexByLevel()
    return 1
end

function object.getEnemyTemplateMaxIndexByLevel()
    return 1
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

    local xzVector = math.Vector3(towardsVec.x, 0, towardsVec.z)
    local constrainedXzVector = api.vector.setVectorLength(
        xzVector,
        math.max(
            minDistanceLimit or 10,
            xzVector:length()
        )
    )
    local constrainedTowardsVec = math.Vector3(constrainedXzVector.x, towardsVec.y, constrainedXzVector.z)

    api.extra.setUnitTowardsTo(turretRotationComp, constrainedTowardsVec, turretCompData.towardsReferenceVec)
end

function object.enableMainTurretTowardsToCursor()
    local function handler()
        object.setTurretTowards(1, api.positionOf(camera.cameraBindComponent), constant.MAIN_TURRET_MIN_ATK_DISTANCE)
    end
    object.mainTurretLockToCursorFrameHandlerIndex = api.extra.addFramePreHandler(handler)
end

function object.createEnemyUnit(templateIndex, position, rotation)
    local templateData = object.enemyUnitTemplate[templateIndex]
    return api.createComponent(templateData.presetId, position, rotation, templateData.defaultZoom)
end

-- test
-- object.enemyUnitArray[1].base = api.getUnitById(1912830340)

--游戏相机======================================================================

camera.cameraBindComponent = nil
camera.minCameraDistance = 50
camera.cameraTowards = math.Vector3(-0.57735, -0.57735, -0.57735)
camera.cameraSpeed = 40
camera.cameraDefaultHeight = 80

camera.cameraSmoothFactor = 0.6
camera.defaultCameraMoveMotorIndex = 0

camera.isCtrlMoving = false

camera.updater = {
    ---@type Unit
    targetUnit = nil,
    updateFrameInterval = 3,
    -- enabled = false
}


function camera.updater.lockTo(unit)
    camera.updater.targetUnit = unit
    hud.setCursorStatus(constant.cursorStatusEnum.LOCKED)
end

--- 相机随帧更新
function camera.updater.run()
    if camera.isCtrlMoving then
        camera.updater.cancelLock()
        return
    end

    if camera.updater.targetUnit == nil then
        return
    end

    local targetPosition = api.positionOf(camera.updater.targetUnit)
    local currentPosition = api.positionOf(camera.cameraBindComponent)
    camera.stepSmoothMove(currentPosition, targetPosition, camera.updater.updateFrameInterval)
    hud.updateCameraPosition(currentPosition)


    api.setTimeout(camera.updater.run, camera.updater.updateFrameInterval)
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
---@param cameraComponent Unit
function camera.init(cameraComponent)
    camera.cameraBindComponent = cameraComponent
    api.setPosition(camera.cameraBindComponent, math.Vector3(50, 80, 50))

    api.setCameraBindMode(Player, Enums.CameraBindMode.BIND)
    api.setCameraFollowUnit(Player, cameraComponent, false)
    api.setCameraProperties(Player, {
        [Enums.CameraPropertyType.BIND_MODE_OFFSET_X] = (-camera.minCameraDistance * camera.cameraTowards).x,
        [Enums.CameraPropertyType.BIND_MODE_OFFSET_Y] = (-camera.minCameraDistance * camera.cameraTowards).y,
        [Enums.CameraPropertyType.BIND_MODE_OFFSET_Z] = (-camera.minCameraDistance * camera.cameraTowards).z,
        [Enums.CameraPropertyType.DIST] = 50.0,
        [Enums.CameraPropertyType.BIND_MODE_YAW] = -135.0,
        [Enums.CameraPropertyType.BIND_MODE_PITCH] = 35.0,
        [Enums.CameraPropertyType.FOV] = 60.0
    })
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

function camera.lockToUnit(unit)
    camera.updater.lockTo(unit)
    camera.updater.run()
    logger.debug("camera locked.")
end

function camera.cancelLock()
    camera.updater.cancelLock()
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
    api.disableMotor(camera.cameraBindComponent, camera.defaultCameraMoveMotorIndex)

    hud.updateCameraPosition(api.positionOf(camera.cameraBindComponent))

    logger.debug("camera stop.")

    if object.data.gameSettings.autoAimEnabled then
        -- 搜索敌方单位
        for _, value in ipairs(object.enemyUnitArray) do
            if (api.positionOf(camera.cameraBindComponent) - api.positionOf(value.base)):length() < 15 then
                camera.lockToUnit(value.base)
                break
            end
        end
    end
end

---控制相机朝方向移动
---如果开启了高度检查，相机开始移动后的一帧会卡一下
---@param towards Vector3 相机移动方向
---@param restoreInitHeight boolean 开启相机所在平面校准，会自动检查相机高度并校准
function camera.ctrlMove(towards, restoreInitHeight)
    camera.isCtrlMoving = true
    -- hud.setCursorStatus(constant.hudStatusEnum.NORMAL)
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

function hud.updateTargetInfo(totalHealth, currentHealth, totalDefense, currentDefense, healthSmearDuration)
    api.sendGlobalCustomEvent(constant.UI_BRIDGE_SET_TARGET_INFO, {
        maxHealth = totalHealth,
        maxDefense = totalDefense,
        currentHealth = currentHealth,
        currentDefense = currentDefense,
        healthSmearDuration = healthSmearDuration,
    })
end

function hud.updateSelfInfo(totalHealth, currentHealth, totalDefense, currentDefense)
    api.sendGlobalCustomEvent(constant.UI_BRIDGE_SET_SELF_INFO, {
        maxHealth = totalHealth,
        currentHealth = currentHealth,
        maxDefense = totalDefense,
        currentDefense = currentDefense
    })
end

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
end

-- scene =======================================================================
scene.random = api.random.new(666)
scene.vfxRenderApiExport = {
    ---创建特效
    ---@param effectKey integer 特效编号
    ---@param pos Vector3 特效创建位置
    ---@param rotation Quaternion? 旋转
    ---@param zoom Fixed? 特效缩放
    ---@param duration Fixed? 持续时间
    ---@param speed Fixed? 播放速度
    ---@param soundEnabled boolean? 开启声音，默认关闭
    createVfxApi = function(effectKey, pos, rotation, zoom, duration, speed, soundEnabled)
        api.createVFX(effectKey, pos, rotation, zoom, duration, speed, soundEnabled)
    end,
    ---创建绑定特效
    ---@param vfxKey integer 特效编号
    ---@param unit Unit 绑定到的组件
    ---@param socket Enums.ModelSocket 挂载点
    ---@param zoom number 缩放倍数
    ---@param duration number 持续时间
    ---@param bindType Enums.BindType 绑定类型
    createVfxWithSocketApi = function(vfxKey, unit, socket, zoom, duration, bindType)
        api.createVFXWithSocket(vfxKey, unit, socket, zoom, duration, bindType)
    end
}
scene.vfxRender = {
    createVfx = scene.vfxRenderApiExport.createVfxApi,
    createVfxWithSocket = scene.vfxRenderApiExport.createVfxWithSocketApi
}


---设置场景特效状态
---@param status boolean
function scene.setVfxRenderingStatus(status)
    if status then
        scene.vfxRender.createVfx = scene.vfxRenderApiExport.createVfxApi
        scene.vfxRender.createVfxWithSocket = scene.vfxRenderApiExport.createVfxWithSocketApi
    else
        scene.vfxRender.createVfx = function() end
        scene.vfxRender.createVfxWithSocket = function() end
    end
end

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

    local enemyUnitTemplate = object.enemyUnitTemplate[generateIndex]
    local rotation = api.vector.rotationBetweenVec(enemyUnitTemplate.towardsReferenceVector, initialTowards)

    --环绕中心组件
    local centerComponent = nil

    api.setTimeout(function()
        scene.vfxRender.createVfx(3218, initialPos, math.Quaternion(0, 0, 0), 3.0, 3.0, 1.0, false)
    end, 2)

    -- 推迟中心组件的创建，防止同一帧中创建组件过多导致卡顿
    api.setTimeout(function()
        centerComponent = api.createComponent(1101635, center, math.Quaternion(0, 0, 0), math.Vector3(1, 1, 1))
    end, 2)


    api.setTimeout(function()
        local enemyUnitBase = object.createEnemyUnit(generateIndex, initialPos, rotation)
        ---@diagnostic disable-next-line: param-type-mismatch
        api.addSurroundMotor(enemyUnitBase, centerComponent, angularVelocity, 9999.0, true)

        local enemyUnitProperties = object.enemyUnitProperties[generateIndex]

        ---@type EnemyUnitData
        local enemyUnitData = {
            base = enemyUnitBase,
            ---@diagnostic disable-next-line: assign-type-mismatch
            centerComponent = centerComponent,
            templateIndex = generateIndex,
            currentHealth = enemyUnitProperties.maxHealthValue,
            currentDefense = enemyUnitProperties.currentDefense,
            maxHealth = enemyUnitProperties.maxHealthValue,
            maxDefense = enemyUnitProperties.maxDefenseValue
        }

        table.insert(
            object.enemyUnitArray, enemyUnitData)
        logger.debug("enemy unit finished")
        -- logger.debug("createPosition: " .. generatePosition .. ", towardsVec: " .. towardsVec)
    end, 3)
    logger.debug("enemy unit prepared")
end

function scene.initEnemyUnitGenerator()
    local function delayCallback()
        scene.generateEnemyUnit()
        api.setTimeout(delayCallback, scene.random:nextIntBound(10 * constant.LOGIC_FPS) + 5 * constant.LOGIC_FPS)
        -- debug
        -- api.setTimeout(delayCallback, 2)
    end
    api.setTimeout(delayCallback, 15 * constant.LOGIC_FPS
    )
end

-- END==========================================================================

return {
    camera = camera,
    frame = frame,
    hud = hud,
    object = object,
    scene = scene
}
