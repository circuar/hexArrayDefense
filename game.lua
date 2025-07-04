local constant = require("constant")
local api      = require("api")
local logger   = require("api").logger

local object   = {}
local frame    = {}
local camera   = {}
local hud      = {}



-- 场景单位=====================================================================
object.data = {
    --游戏时长（秒）
    timeCount = 0,

    --等级
    level = 1,

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

}



object.enemyObjectArray = {}
object.baseMatrixObjectArray = {

}



-- test
object.enemyObjectArray[1] = api.getUnitById(1912830340)

-- 帧===========================================================================
frame.tickPreHandlerList = {}
frame.tickAfterHandlerList = {}

---设置帧开始时的回调
---@param callback function
---@return integer
function frame.addPreTickHandler(callback)
    local pointer = #frame.tickPreHandlerList + 1
    frame.tickPreHandlerList[pointer] = callback
    return pointer
end

---设置帧结束时的回调
---@param callback function
---@return integer
function frame.addAfterTickHandler(callback)
    local pointer = #frame.tickAfterHandlerList + 1
    frame.tickAfterHandlerList[pointer] = callback
    return pointer
end

function frame.cancelPreCallback(index)
    table.remove(frame.tickPreHandlerList, index)
end

function frame.cancelAfterCallback(index)
    table.remove(frame.tickAfterHandlerList, index)
end

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
    camera.updater.targetUnit = nil
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
    if (endPos - startPos):length() < 0.1 then
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
    api.setLinerMotorVelocity(camera.cameraBindComponent, camera.defaultCameraMoveMotorIndex, math.Vector3(0, 0, 0),
        false)
    api.disableMotor(camera.cameraBindComponent, camera.defaultCameraMoveMotorIndex)

    hud.updateCameraPosition(api.positionOf(camera.cameraBindComponent))

    logger.debug("camera stop.")

    -- 搜索敌方单位
    for _, value in ipairs(object.enemyObjectArray) do
        if (api.positionOf(camera.cameraBindComponent) - api.positionOf(value)):length() < 15 then
            camera.lockToUnit(value)
            hud.setCursorStatus(1)
            break
        end
    end
end

---控制相机朝方向移动
---如果开启了高度检查，相机开始移动后的一帧会卡一下
---@param towards Vector3 相机移动方向
---@param restoreInitHeight boolean 开启相机所在平面校准，会自动检查相机高度并校准
function camera.ctrlMove(towards, restoreInitHeight)
    camera.isCtrlMoving = true
    hud.setCursorStatus(0)
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

-- END==========================================================================

return {
    camera = camera,
    frame = frame,
    hud = hud,
    object = object
}
