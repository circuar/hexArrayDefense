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
    [1] = api.getUnitById(1122055055),

    [2] = api.getUnitById(1181778872),
    [3] = api.getUnitById(1150015667),
    [4] = api.getUnitById(1222282001),
    [5] = api.getUnitById(1475375461),
    [6] = api.getUnitById(1939557934),
    [7] = api.getUnitById(1387961347),

    [8] = api.getUnitById(1293434707),
    [9] = api.getUnitById(1659147921),
    [10] = api.getUnitById(1504719041),
    [11] = api.getUnitById(1212741960),
    [12] = api.getUnitById(1028351174),
    [13] = api.getUnitById(2073263738),
    [14] = api.getUnitById(1657782345),
    [15] = api.getUnitById(1534112645),
    [16] = api.getUnitById(2104180859),
    [17] = api.getUnitById(1898002724),
    [18] = api.getUnitById(2116841467),
    [19] = api.getUnitById(1238631952),

    [20] = api.getUnitById(2132410328),
    [21] = api.getUnitById(1722483554),
    [22] = api.getUnitById(1050724702),
    [23] = api.getUnitById(1305458635),
    [24] = api.getUnitById(1201086558),
    [25] = api.getUnitById(1061917797),
    [26] = api.getUnitById(1754007022),
    [27] = api.getUnitById(1300562598),
    [28] = api.getUnitById(1939245999),
    [29] = api.getUnitById(1926341027),
    [30] = api.getUnitById(1797086022),
    [31] = api.getUnitById(1028164136),
    [32] = api.getUnitById(2066379444),
    [33] = api.getUnitById(2057208474),
    [34] = api.getUnitById(1618245449),
    [35] = api.getUnitById(1184601803),
    [36] = api.getUnitById(1797658640),
    [37] = api.getUnitById(1453953026),
    [38] = api.getUnitById(1991902532),
    [39] = api.getUnitById(1116388393),
    [40] = api.getUnitById(1365831028),
    [41] = api.getUnitById(2062560358),
    [42] = api.getUnitById(1313405155),
    [43] = api.getUnitById(1803532998),
    [44] = api.getUnitById(1293173458),
    [45] = api.getUnitById(2024564367),
    [46] = api.getUnitById(1067020627),
    [47] = api.getUnitById(1019752356),
    [48] = api.getUnitById(1628890058),
    [49] = api.getUnitById(1769303687),
    [50] = api.getUnitById(1378837570),
    [51] = api.getUnitById(1720095643),
    [52] = api.getUnitById(1714297318),
    [53] = api.getUnitById(1536915027),
    [54] = api.getUnitById(1140804308),
    [55] = api.getUnitById(1938308050),

    [56] = api.getUnitById(1549093997),
    [57] = api.getUnitById(1024263829),
    [58] = api.getUnitById(1913695513),
    [59] = api.getUnitById(1612610812),
    [60] = api.getUnitById(1525930073),
    [61] = api.getUnitById(1163847806),
    [62] = api.getUnitById(1785253713),
    [63] = api.getUnitById(1711681210),
    [64] = api.getUnitById(1363969639),
    [65] = api.getUnitById(1239188740),
    [66] = api.getUnitById(2146181628),
    [67] = api.getUnitById(2047579873),
    [68] = api.getUnitById(1314225960),
    [69] = api.getUnitById(1570592874),
    [70] = api.getUnitById(2055617385),
    [71] = api.getUnitById(1834752042),
    [72] = api.getUnitById(1871092280),
    [73] = api.getUnitById(1782357082),
    [74] = api.getUnitById(1230285039),
    [75] = api.getUnitById(1401581483),
    [76] = api.getUnitById(1625205278),
    [77] = api.getUnitById(2001664338),
    [78] = api.getUnitById(1730650811),
    [79] = api.getUnitById(1505421803),
    [80] = api.getUnitById(1215306582),
    [81] = api.getUnitById(1595541296),
    [82] = api.getUnitById(1256242556),
    [83] = api.getUnitById(1750449034),
    [84] = api.getUnitById(2003759545),
    [85] = api.getUnitById(1008321933),
    [86] = api.getUnitById(1124134819),
    [87] = api.getUnitById(1208207803),
    [88] = api.getUnitById(1705491382),
    [89] = api.getUnitById(1300621307),
    [90] = api.getUnitById(1438323335),
    [91] = api.getUnitById(1043873191)
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
