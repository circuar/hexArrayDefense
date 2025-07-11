local api = require("api")

local gameCameraBindUnit = api.getUnitById(1268527012)
local turretCollision = api.getUnitById(1555432595)

api.setUnitVisible(turretCollision, false)

local baseHexComponentId = {
    -- c1
    [1] = 1122055055,
    -- c2
    [2] = 1181778872,
    [3] = 1150015667,
    [4] = 1222282001,
    [5] = 1475375461,
    [6] = 1939557934,
    [7] = 1387961347,
    -- c3
    [8] = 1293434707,
    [9] = 1659147921,
    [10] = 1504719041,
    [11] = 1212741960,
    [12] = 1028351174,
    [13] = 2073263738,
    [14] = 1657782345,
    [15] = 1534112645,
    [16] = 2104180859,
    [17] = 1898002724,
    [18] = 2116841467,
    [19] = 1238631952,
    -- c4
    [20] = 2132410328,
    [21] = 1722483554,
    [22] = 1050724702,
    [23] = 1305458635,
    [24] = 1201086558,
    [25] = 1061917797,
    [26] = 1754007022,
    [27] = 1300562598,
    [28] = 1939245999,
    [29] = 1926341027,
    [30] = 1797086022,
    [31] = 1028164136,
    [32] = 2066379444,
    [33] = 2057208474,
    [34] = 1618245449,
    [35] = 1184601803,
    [36] = 1797658640,
    [37] = 1453953026,
    -- c5
    [38] = 1991902532,
    [39] = 1116388393,
    [40] = 1365831028,
    [41] = 2062560358,
    [42] = 1313405155,
    [43] = 1803532998,
    [44] = 1293173458,
    [45] = 2024564367,
    [46] = 1067020627,
    [47] = 1019752356,
    [48] = 1628890058,
    [49] = 1769303687,
    [50] = 1378837570,
    [51] = 1720095643,
    [52] = 1714297318,
    [53] = 1536915027,
    [54] = 1140804308,
    [55] = 1938308050,
    [56] = 1549093997,
    [57] = 1024263829,
    [58] = 1913695513,
    [59] = 1612610812,
    [60] = 1525930073,
    [61] = 1163847806,
    -- c6
    [62] = 1785253713,
    [63] = 1711681210,
    [64] = 1363969639,
    [65] = 1239188740,
    [66] = 2146181628,
    [67] = 2047579873,
    [68] = 1314225960,
    [69] = 1570592874,
    [70] = 2055617385,
    [71] = 1834752042,
    [72] = 1871092280,
    [73] = 1782357082,
    [74] = 1230285039,
    [75] = 1401581483,
    [76] = 1625205278,
    [77] = 2001664338,
    [78] = 1730650811,
    [79] = 1505421803,
    [80] = 1215306582,
    [81] = 1595541296,
    [82] = 1256242556,
    [83] = 1750449034,
    [84] = 2003759545,
    [85] = 1008321933,
    [86] = 1124134819,
    [87] = 1208207803,
    [88] = 1705491382,
    [89] = 1300621307,
    [90] = 1438323335,
    [91] = 1043873191
}

-- 阵基初始化
local baseHexComponent = {}
for index, value in ipairs(baseHexComponentId) do
    baseHexComponent[index] = api.getUnitById(value)
end

local bulletTemplates = {
    [1] = {
        presetId = 1073774641,
        towardsReferenceVec = math.Vector3(0, 1, 0),
        defaultZoom = math.Vector3(0.3, 5, 0.3),
        destroyEffectPreset = {
            id = 4136,
            rotation = math.Quaternion(0, 0, 0),
            zoom = 2.0,
            duration = 5.0,
            speed = 1.0
        }
    },
    [2] = {
        presetId = 1073832018,
        towardsReferenceVec = math.Vector3(0, 1, 0),
        defaultZoom = math.Vector3(0.2, 4, 0.2),
        destroyEffectPreset = {
            id = 2540,
            rotation = math.Quaternion(0, 0, 0),
            zoom = 1.5,
            duration = 5.0,
            speed = 1.0
        }
    },
    [3] = {
        presetId = 1073836043,
        towardsReferenceVec = math.Vector3(0, 1, 0),
        defaultZoom = math.Vector3(0.3, 4, 0.3),
        destroyEffectPreset = {
            id = 829,
            rotation = math.Quaternion(0, 0, 0),
            zoom = 3.0,
            duration = 5.0,
            speed = 1.0
        }
    },
    --green
    [4] = {
        presetId = 1073864761,
        towardsReferenceVec = math.Vector3(0, 1, 0),
        defaultZoom = math.Vector3(0.3, 8, 0.3),
        destroyEffectPreset = {
            id = 2286,
            rotation = math.Quaternion(0, 0, 0),
            zoom = 10.0,
            duration = 5.0,
            speed = 1.0
        }
    },
    [5] = {
        presetId = 1073868866,
        towardsReferenceVec = math.Vector3(0, 1, 0),
        defaultZoom = math.Vector3(0.2, 5, 0.2),
        destroyEffectPreset = {
            id = 2286,
            rotation = math.Quaternion(0, 0, 0),
            zoom = 3.0,
            duration = 5.0,
            speed = 1.0
        }
    },
    [6] = {
        presetId = 1073872942,
        towardsReferenceVec = math.Vector3(0, 1, 0),
        defaultZoom = math.Vector3(0.2, 5, 0.2),
        destroyEffectPreset = {
            id = 2286,
            rotation = math.Quaternion(0, 0, 0),
            zoom = 3.0,
            duration = 5.0,
            speed = 1.0
        }
    }
}



---@class TurretFireEffectData
---@field id integer
---@field towardsReferenceVec Vector3
---@field localOffset table
---@field zoom Fixed
---@field duration Fixed
---@field speed Fixed

---@class SearchEnemyAngle
---@field min integer
---@field max integer


---@class TurretComponentData
---@field base Unit 组件实体
---@field rotationPart Unit|nil 旋转部分实体
---@field rotationPartBaseOffset Vector3|nil 旋转部分相对组件实体世界坐标偏移
---@field towardsReferenceVec Vector3|nil 旋转部分朝向参考向量
---@field bulletCreateOffset Vector3|nil 子弹创建时相对于旋转部分的世界坐标偏移
---@field bulletTemplateIndex integer|nil 子弹模板的索引
---@field isMainTurret boolean 是否为主炮塔
---@field atkMethodType integer 攻击方式（1：单发，2：连发，3：激光）
---@field atkCoolDownFrame number|nil 连发时攻击间隔，或主炮塔的攻击间隔
---@field consecutiveShotCount integer|nil 连发时连续攻击次数
---@field laserSocket Unit|nil 激光攻击时特效的起始挂载点
---@field bulletSpeed number|nil 子弹的速度
---@field damageValuePerBullet integer 单发子弹的伤害值
---@field fireEffectPreset TurretFireEffectData|nil 开火特效数据
---@field searchEnemyAngle SearchEnemyAngle 锁敌角度范围（相对于x轴正向，度）
---@field enabled boolean 是否启用，用于防御塔自动攻击帧回调函数的检查

---@type TurretComponentData[]
local turretComponentData = {

    -- LAYER: 1 ================================================================
    --主炮台
    [1] = {
        base = api.getUnitById(1466853682),

        rotationPart = api.getUnitById(1812918448),
        rotationPartBaseOffset = math.Vector3(0, 5, 0),
        towardsReferenceVec = math.Vector3(0, 0, 1),
        bulletCreateOffset = math.Vector3(0, -0.5, 14),
        bulletTemplateIndex = 1,
        isMainTurret = true,
        -- 1：普通单发
        -- 2：连发
        -- 3：激光
        atkMethodType = 2,
        atkCoolDownFrame = 7,
        laserSocket = nil,
        consecutiveShotCount = nil, --使用extraData中的数值，此处已弃用
        bulletSpeed = 150,
        damageValuePerBullet = 140,
        fireEffectPreset = {
            id = 2523,
            ---x:径向 y:竖直
            localOffset = { x = 2, y = 0 },
            towardsReferenceVec = math.Vector3(0, 0, 1),

            zoom = 1.5,
            duration = 1.0,
            speed = 1.0
        },
        searchEnemyAngle = { min = 0, max = 360 },
        enabled = true
    },


    -- LAYER: 2 ================================================================
    [2] = {
        base = api.getUnitById(1356177493),
        rotationPart = api.getUnitById(1060738399),
        rotationPartBaseOffset = math.Vector3(0, 7, 0),
        towardsReferenceVec = math.Vector3(1, 0, 0),
        bulletCreateOffset = math.Vector3(8, 0, 0),
        bulletTemplateIndex = 1,
        isMainTurret = false,
        -- 1：普通单发
        -- 2：连发
        -- 3：激光
        atkMethodType = 1,
        atkCoolDownFrame = nil,
        laserSocket = nil,
        consecutiveShotCount = 5,
        bulletSpeed = 150,
        damageValuePerBullet = 30,
        fireEffectPreset = {
            id = 2523,
            ---x:径向 y:竖直
            localOffset = { x = -3, y = 0 },
            towardsReferenceVec = math.Vector3(0, 0, 1),

            zoom = 1.5,
            duration = 1.0,
            speed = 1.0
        },
        searchEnemyAngle = { min = 300, max = 60 },
        enabled = false
    },
    [4] = {
        base = api.getUnitById(1810461588),
        rotationPart = api.getUnitById(1252930496),
        rotationPartBaseOffset = math.Vector3(0, 7, 0),
        towardsReferenceVec = math.Vector3(1, 0, 0),
        bulletCreateOffset = math.Vector3(8, 0, 0),
        bulletTemplateIndex = 1,
        isMainTurret = false,
        -- 1：普通单发
        -- 2：连发
        -- 3：激光
        atkMethodType = 1,
        atkCoolDownFrame = nil,
        laserSocket = nil,
        consecutiveShotCount = nil,
        bulletSpeed = 150,
        damageValuePerBullet = 30,
        fireEffectPreset = {
            id = 2523,
            ---x:径向 y:竖直
            localOffset = { x = -3, y = 0 },
            towardsReferenceVec = math.Vector3(0, 0, 1),

            zoom = 1.5,
            duration = 1.0,
            speed = 1.0
        },
        searchEnemyAngle = { min = 60, max = 180 },
        enabled = false

    },
    [6] = {
        base = api.getUnitById(1251513144),
        rotationPart = api.getUnitById(1619392026),
        rotationPartBaseOffset = math.Vector3(0, 7, 0),
        towardsReferenceVec = math.Vector3(1, 0, 0),
        bulletCreateOffset = math.Vector3(8, 0, 0),
        bulletTemplateIndex = 1,
        isMainTurret = false,
        -- 1：普通单发
        -- 2：连发
        -- 3：激光
        atkMethodType = 1,
        atkCoolDownFrame = nil,
        laserSocket = nil,
        consecutiveShotCount = nil,
        bulletSpeed = 150,
        damageValuePerBullet = 30,
        fireEffectPreset = {
            id = 2523,
            ---x:径向 y:竖直
            localOffset = { x = -3, y = 0 },
            towardsReferenceVec = math.Vector3(0, 0, 1),

            zoom = 1.5,
            duration = 1.0,
            speed = 1.0
        },
        searchEnemyAngle = { min = 180, max = 300 },
        enabled = false
    },
    -- LAYER: 3 ================================================================
    [10] = {
        base = api.getUnitById(1558813753),
        rotationPart = api.getUnitById(1472105670),
        rotationPartBaseOffset = math.Vector3(0, 6, 0),
        towardsReferenceVec = math.Vector3(1, 0, 0),
        bulletCreateOffset = math.Vector3(11.5, -0.25, 0),
        bulletTemplateIndex = 1,
        isMainTurret = false,
        -- 1：普通单发
        -- 2：连发
        -- 3：激光
        atkMethodType = 2,
        atkCoolDownFrame = 4,
        laserSocket = nil,
        consecutiveShotCount = 7,
        bulletSpeed = 150,
        damageValuePerBullet = 30,
        fireEffectPreset = {
            id = 2523,
            ---x:径向 y:竖直
            localOffset = { x = 0, y = 0 },
            towardsReferenceVec = math.Vector3(0, 0, 1),

            zoom = 1.5,
            duration = 1.0,
            speed = 1.0
        },
        searchEnemyAngle = { min = 0, max = 120 },
        enabled = false
    },
    [14] = {
        base = api.getUnitById(1700501453),
        rotationPart = api.getUnitById(1727518411),
        rotationPartBaseOffset = math.Vector3(0, 6, 0),
        towardsReferenceVec = math.Vector3(1, 0, 0),
        bulletCreateOffset = math.Vector3(11.5, -0.25, 0),
        bulletTemplateIndex = 1,
        isMainTurret = false,
        -- 1：普通单发
        -- 2：连发
        -- 3：激光
        atkMethodType = 2,
        atkCoolDownFrame = 4,
        laserSocket = nil,
        consecutiveShotCount = 7,
        bulletSpeed = 150,
        damageValuePerBullet = 30,
        fireEffectPreset = {
            id = 2523,
            ---x:径向 y:竖直
            localOffset = { x = 0, y = 0 },
            towardsReferenceVec = math.Vector3(0, 0, 1),

            zoom = 1.5,
            duration = 1.0,
            speed = 1.0
        },
        searchEnemyAngle = { min = 120, max = 240 },
        enabled = false
    },
    [18] = {
        base = api.getUnitById(1884850600),
        rotationPart = api.getUnitById(1712830570),
        rotationPartBaseOffset = math.Vector3(0, 6, 0),
        towardsReferenceVec = math.Vector3(1, 0, 0),
        bulletCreateOffset = math.Vector3(11.5, -0.25, 0),
        bulletTemplateIndex = 1,
        isMainTurret = false,
        -- 1：普通单发
        -- 2：连发
        -- 3：激光
        atkMethodType = 2,
        atkCoolDownFrame = 4,
        laserSocket = nil,
        consecutiveShotCount = 7,
        bulletSpeed = 150,
        damageValuePerBullet = 30,
        fireEffectPreset = {
            id = 2523,
            ---x:径向 y:竖直
            localOffset = { x = 0, y = 0 },
            towardsReferenceVec = math.Vector3(0, 0, 1),

            zoom = 1.5,
            duration = 1.0,
            speed = 1.0
        },
        searchEnemyAngle = { min = 240, max = 360 },
        enabled = false
    },
    -- LAYER: 4 ================================================================
    [21] = {
        base = api.getUnitById(1431539842),
        rotationPart = api.getUnitById(1431539842),
        rotationPartBaseOffset = math.Vector3(0, 6, 0),
        towardsReferenceVec = math.Vector3(1, 0, 0),
        bulletCreateOffset = math.Vector3(11.5, -0.25, 0),
        bulletTemplateIndex = 4,
        isMainTurret = false,
        -- 1：普通单发
        -- 2：连发
        -- 3：激光
        atkMethodType = 1,
        atkCoolDownFrame = 3,
        laserSocket = nil,
        consecutiveShotCount = 10,
        bulletSpeed = 100,
        damageValuePerBullet = 30,
        fireEffectPreset = {
            id = 2523,
            ---x:径向 y:竖直
            localOffset = { x = 0, y = 0 },
            towardsReferenceVec = math.Vector3(0, 0, 1),

            zoom = 1.5,
            duration = 1.0,
            speed = 1.0
        },
        searchEnemyAngle = { min = 0, max = 60 },
        enabled = false
    },
    [25] = {
        base = api.getUnitById(1073256995),
        rotationPart = api.getUnitById(2101972419),
        rotationPartBaseOffset = math.Vector3(0, 7, 0),
        towardsReferenceVec = math.Vector3(1, 0, 0),
        bulletCreateOffset = math.Vector3(8, 0, 0),
        bulletTemplateIndex = 4,
        isMainTurret = false,
        -- 1：普通单发
        -- 2：连发
        -- 3：激光
        atkMethodType = 1,
        atkCoolDownFrame = 30,
        laserSocket = nil,
        consecutiveShotCount = nil,
        bulletSpeed = 100,
        damageValuePerBullet = 30,
        fireEffectPreset = {
            id = 2523,
            ---x:径向 y:竖直
            localOffset = { x = -3, y = 0 },
            towardsReferenceVec = math.Vector3(0, 0, 1),

            zoom = 1.5,
            duration = 1.0,
            speed = 1.0
        },
        searchEnemyAngle = { min = 60, max = 120 },
        enabled = false
    },
    [27] = {
        base = api.getUnitById(1840082656),
        rotationPart = api.getUnitById(1023066084),
        rotationPartBaseOffset = math.Vector3(0, 7, 0),
        towardsReferenceVec = math.Vector3(1, 0, 0),
        bulletCreateOffset = math.Vector3(8, 0, 0),
        bulletTemplateIndex = 4,
        isMainTurret = false,
        -- 1：普通单发
        -- 2：连发
        -- 3：激光
        atkMethodType = 1,
        atkCoolDownFrame = 30,
        laserSocket = nil,
        consecutiveShotCount = nil,
        bulletSpeed = 100,
        damageValuePerBullet = 30,
        fireEffectPreset = {
            id = 2523,
            ---x:径向 y:竖直
            localOffset = { x = -3, y = 0 },
            towardsReferenceVec = math.Vector3(0, 0, 1),

            zoom = 1.5,
            duration = 1.0,
            speed = 1.0
        },
        searchEnemyAngle = { min = 120, max = 180 },
        enabled = false
    },
    [31] = {
        base = api.getUnitById(1041227517),
        rotationPart = api.getUnitById(1047567524),
        rotationPartBaseOffset = math.Vector3(0, 7, 0),
        towardsReferenceVec = math.Vector3(1, 0, 0),
        bulletCreateOffset = math.Vector3(8, 0, 0),
        bulletTemplateIndex = 4,
        isMainTurret = false,
        -- 1：普通单发
        -- 2：连发
        -- 3：激光
        atkMethodType = 1,
        atkCoolDownFrame = 30,
        laserSocket = nil,
        consecutiveShotCount = nil,
        bulletSpeed = 100,
        damageValuePerBullet = 30,
        fireEffectPreset = {
            id = 2523,
            ---x:径向 y:竖直
            localOffset = { x = -3, y = 0 },
            towardsReferenceVec = math.Vector3(0, 0, 1),

            zoom = 1.5,
            duration = 1.0,
            speed = 1.0
        },
        searchEnemyAngle = { min = 180, max = 240 },
        enabled = false
    },
    [33] = {
        base = api.getUnitById(1931749291),
        rotationPart = api.getUnitById(1583833186),
        rotationPartBaseOffset = math.Vector3(0, 7, 0),
        towardsReferenceVec = math.Vector3(1, 0, 0),
        bulletCreateOffset = math.Vector3(8, 0, 0),
        bulletTemplateIndex = 4,
        isMainTurret = false,
        -- 1：普通单发
        -- 2：连发
        -- 3：激光
        atkMethodType = 1,
        atkCoolDownFrame = 30,
        laserSocket = nil,
        consecutiveShotCount = nil,
        bulletSpeed = 100,
        damageValuePerBullet = 30,
        fireEffectPreset = {
            id = 2523,
            ---x:径向 y:竖直
            localOffset = { x = -3, y = 0 },
            towardsReferenceVec = math.Vector3(0, 0, 1),

            zoom = 1.5,
            duration = 1.0,
            speed = 1.0
        },
        searchEnemyAngle = { min = 240, max = 300 },
        enabled = false
    },
    [37] = {
        base = api.getUnitById(1414683949),
        rotationPart = api.getUnitById(2013346141),
        rotationPartBaseOffset = math.Vector3(0, 7, 0),
        towardsReferenceVec = math.Vector3(1, 0, 0),
        bulletCreateOffset = math.Vector3(8, 0, 0),
        bulletTemplateIndex = 4,
        isMainTurret = false,
        -- 1：普通单发
        -- 2：连发
        -- 3：激光
        atkMethodType = 1,
        atkCoolDownFrame = 30,
        laserSocket = nil,
        consecutiveShotCount = nil,
        bulletSpeed = 100,
        damageValuePerBullet = 30,
        fireEffectPreset = {
            id = 2523,
            ---x:径向 y:竖直
            localOffset = { x = -3, y = 0 },
            towardsReferenceVec = math.Vector3(0, 0, 1),

            zoom = 1.5,
            duration = 1.0,
            speed = 1.0
        },
        searchEnemyAngle = { min = 300, max = 360 },
        enabled = false
    },
    -- LAYER: 5 ================================================================
    [42] = {
        base = api.getUnitById(2109476092),
        rotationPart = nil,
        rotationPartBaseOffset = nil,
        towardsReferenceVec = nil,
        bulletCreateOffset = nil,
        bulletTemplateIndex = nil,
        isMainTurret = false,
        -- 1：普通单发
        -- 2：连发
        -- 3：激光
        atkMethodType = 3,
        atkCoolDownFrame = nil,
        laserSocket = api.getUnitById(1488090547),
        consecutiveShotCount = nil,
        bulletSpeed = nil,
        damageValuePerBullet = 80,
        fireEffectPreset = nil,
        searchEnemyAngle = { min = 0, max = 120 },
        enabled = false
    },
    [50] = {
        base = api.getUnitById(2021013517),
        rotationPart = nil,
        rotationPartBaseOffset = nil,
        towardsReferenceVec = nil,
        bulletCreateOffset = nil,
        bulletTemplateIndex = nil,
        isMainTurret = false,
        -- 1：普通单发
        -- 2：连发
        -- 3：激光
        atkMethodType = 3,
        atkCoolDownFrame = nil,
        laserSocket = api.getUnitById(2003057836),
        consecutiveShotCount = nil,
        bulletSpeed = nil,
        damageValuePerBullet = 80,
        fireEffectPreset = nil,
        searchEnemyAngle = { min = 120, max = 240 },
        enabled = false
    },
    [58] = {
        base = api.getUnitById(1634135289),
        rotationPart = nil,
        rotationPartBaseOffset = nil,
        towardsReferenceVec = nil,
        bulletCreateOffset = nil,
        bulletTemplateIndex = nil,
        isMainTurret = false,
        -- 1：普通单发
        -- 2：连发
        -- 3：激光
        atkMethodType = 3,
        atkCoolDownFrame = nil,
        laserSocket = api.getUnitById(1594483526),
        consecutiveShotCount = nil,
        bulletSpeed = nil,
        damageValuePerBullet = 80,
        fireEffectPreset = nil,
        searchEnemyAngle = { min = 240, max = 360 },
        enabled = false
    },
    -- LAYER: 6 ================================================================
    [62] = {
        base = api.getUnitById(1550430116),
        rotationPart = nil,
        rotationPartBaseOffset = nil,
        towardsReferenceVec = nil,
        bulletCreateOffset = nil,
        bulletTemplateIndex = nil,
        isMainTurret = false,
        -- 1：普通单发
        -- 2：连发
        -- 3：激光
        atkMethodType = 3,
        atkCoolDownFrame = nil,
        laserSocket = api.getUnitById(2003089849),
        consecutiveShotCount = nil,
        bulletSpeed = nil,
        damageValuePerBullet = 80,
        fireEffectPreset = nil,
        searchEnemyAngle = { min = 300, max = 60 },
        enabled = false
    },
    [66] = {
        base = api.getUnitById(1072591452),
        rotationPart = api.getUnitById(1566713407),
        rotationPartBaseOffset = math.Vector3(0, 5, 0),
        towardsReferenceVec = math.Vector3(-1.7321, 1, 0),
        bulletCreateOffset = nil,
        bulletTemplateIndex = nil,
        isMainTurret = false,
        -- 1：普通单发
        -- 2：连发
        -- 3：激光
        atkMethodType = 3,
        atkCoolDownFrame = nil,
        laserSocket = api.getUnitById(1289343131),
        consecutiveShotCount = nil,
        bulletSpeed = nil,
        damageValuePerBullet = 80,
        fireEffectPreset = nil,
        searchEnemyAngle = { min = 0, max = 120 },
        enabled = false
    },
    [68] = {
        base = api.getUnitById(1168666431),
        rotationPart = api.getUnitById(1309320028),
        rotationPartBaseOffset = math.Vector3(0, 5, 0),
        towardsReferenceVec = math.Vector3(-1.7321, 1, 0),
        bulletCreateOffset = nil,
        bulletTemplateIndex = nil,
        isMainTurret = false,
        -- 1：普通单发
        -- 2：连发
        -- 3：激光
        atkMethodType = 3,
        atkCoolDownFrame = nil,
        laserSocket = api.getUnitById(1156742984),
        consecutiveShotCount = nil,
        bulletSpeed = nil,
        damageValuePerBullet = 80,
        fireEffectPreset = nil,
        searchEnemyAngle = { min = 0, max = 120 },
        enabled = false
    },
    [72] = {
        base = api.getUnitById(1965111546),
        rotationPart = nil,
        rotationPartBaseOffset = nil,
        towardsReferenceVec = nil,
        bulletCreateOffset = nil,
        bulletTemplateIndex = nil,
        isMainTurret = false,
        -- 1：普通单发
        -- 2：连发
        -- 3：激光
        atkMethodType = 3,
        atkCoolDownFrame = nil,
        laserSocket = api.getUnitById(1095471515),
        consecutiveShotCount = nil,
        bulletSpeed = nil,
        damageValuePerBullet = 80,
        fireEffectPreset = nil,
        searchEnemyAngle = { min = 60, max = 180 },
        enabled = false
    },
    [76] = {
        base = api.getUnitById(1478067303),
        rotationPart = api.getUnitById(1558804697),
        rotationPartBaseOffset = math.Vector3(0, 5, 0),
        towardsReferenceVec = math.Vector3(-1.7321, 1, 0),
        bulletCreateOffset = nil,
        bulletTemplateIndex = nil,
        isMainTurret = false,
        -- 1：普通单发
        -- 2：连发
        -- 3：激光
        atkMethodType = 3,
        atkCoolDownFrame = nil,
        laserSocket = api.getUnitById(1750897763),
        consecutiveShotCount = nil,
        bulletSpeed = nil,
        damageValuePerBullet = 80,
        fireEffectPreset = nil,
        searchEnemyAngle = { min = 120, max = 240 },
        enabled = false
    },
    [78] = {
        base = api.getUnitById(1141834972),
        rotationPart = api.getUnitById(1311782128),
        rotationPartBaseOffset = math.Vector3(0, 5, 0),
        towardsReferenceVec = math.Vector3(-1.7321, 1, 0),
        bulletCreateOffset = nil,
        bulletTemplateIndex = nil,
        isMainTurret = false,
        -- 1：普通单发
        -- 2：连发
        -- 3：激光
        atkMethodType = 3,
        atkCoolDownFrame = nil,
        laserSocket = api.getUnitById(1755754311),
        consecutiveShotCount = nil,
        bulletSpeed = nil,
        damageValuePerBullet = 80,
        fireEffectPreset = nil,
        searchEnemyAngle = { min = 120, max = 240 },
        enabled = false
    },
    [82] = {
        base = api.getUnitById(1278787008),
        rotationPart = nil,
        rotationPartBaseOffset = nil,
        towardsReferenceVec = nil,
        bulletCreateOffset = nil,
        bulletTemplateIndex = nil,
        isMainTurret = false,
        -- 1：普通单发
        -- 2：连发
        -- 3：激光
        atkMethodType = 3,
        atkCoolDownFrame = nil,
        laserSocket = api.getUnitById(1195608726),
        consecutiveShotCount = nil,
        bulletSpeed = nil,
        damageValuePerBullet = 80,
        fireEffectPreset = nil,
        searchEnemyAngle = { min = 180, max = 300 },
        enabled = false
    },
    [86] = {
        base = api.getUnitById(1158544945),
        rotationPart = api.getUnitById(1270479475),
        rotationPartBaseOffset = math.Vector3(0, 5, 0),
        towardsReferenceVec = math.Vector3(-1.7321, 1, 0),
        bulletCreateOffset = nil,
        bulletTemplateIndex = nil,
        isMainTurret = false,
        -- 1：普通单发
        -- 2：连发
        -- 3：激光
        atkMethodType = 3,
        atkCoolDownFrame = nil,
        laserSocket = api.getUnitById(2130635584),
        consecutiveShotCount = nil,
        bulletSpeed = nil,
        damageValuePerBullet = 80,
        fireEffectPreset = nil,
        searchEnemyAngle = { min = 240, max = 360 },
        enabled = false
    },
    [88] = {
        base = api.getUnitById(1660367281),
        rotationPart = api.getUnitById(1102081559),
        rotationPartBaseOffset = math.Vector3(0, 5, 0),
        towardsReferenceVec = math.Vector3(-1.7321, 1, 0),
        bulletCreateOffset = nil,
        bulletTemplateIndex = nil,
        isMainTurret = false,
        -- 1：普通单发
        -- 2：连发
        -- 3：激光
        atkMethodType = 3,
        atkCoolDownFrame = nil,
        laserSocket = api.getUnitById(1630039992),
        consecutiveShotCount = nil,
        bulletSpeed = nil,
        damageValuePerBullet = 80,
        fireEffectPreset = nil,
        searchEnemyAngle = { min = 240, max = 360 },
        enabled = false
    }

}

--敌方单位模型数据
local enemyUnitTemplates = {
    [1] = {
        presetId = 1073840162,
        towardsReferenceVector = math.Vector3(1, 0, 0),
        defaultZoom = math.Vector3(1.92, 0.17, 2.00),
    },
    [2] = {
        presetId = 1073844327,
        towardsReferenceVector = math.Vector3(1, 0, 0),
        defaultZoom = math.Vector3(0.96, 0.33, 1.00),
    },
    [3] = {
        presetId = 1073848383,
        towardsReferenceVector = math.Vector3(1, 0, 0),
        defaultZoom = math.Vector3(1.15, 1.20, 1.20),
    },
    [4] = {
        presetId = 1073852479,
        towardsReferenceVector = math.Vector3(1, 0, 0),
        defaultZoom = math.Vector3(0.94, 2.60, 0.97),
    },
    [5] = {
        presetId = 1073856531,
        towardsReferenceVector = math.Vector3(1, 0, 0),
        defaultZoom = math.Vector3(1.92, 0.33, 2.00),
    },
    [6] = {
        presetId = 1073860631,
        towardsReferenceVector = math.Vector3(0, 0, 1),
        defaultZoom = math.Vector3(1.00, 1.00, 1.04),
    },
}

--敌方单位属性
local enemyUnitProperties = {
    [1] = {
        templateUnitIndex = 1,
        atkMethodType = 1,
        damageValuePerBullet = 20,
        maxHealthValue = 1000,
        maxDefenseValue = 600,
        bulletTemplateIndex = 3,
        bulletSpeed = 100,
        atkIntervalFrame = 101,
        bulletNumPerAtk = 3,
        bulletIntervalFrame = 17,
        exp = 300
    },
    [2] = {
        templateUnitIndex = 2,
        atkMethodType = 1,
        damageValuePerBullet = 30,
        maxHealthValue = 2000,
        maxDefenseValue = 1600,
        bulletTemplateIndex = 3,
        bulletSpeed = 100,
        atkIntervalFrame = 101,
        bulletNumPerAtk = 3,
        bulletIntervalFrame = 17,
        exp = 300
    },
    [3] = {
        templateUnitIndex = 3,
        atkMethodType = 1,
        damageValuePerBullet = 40,
        maxHealthValue = 3000,
        maxDefenseValue = 2600,
        bulletTemplateIndex = 5,
        bulletSpeed = 100,
        atkIntervalFrame = 101,
        bulletNumPerAtk = 3,
        bulletIntervalFrame = 17,
        exp = 300
    },
    [4] = {
        templateUnitIndex = 4,
        atkMethodType = 1,
        damageValuePerBullet = 50,
        maxHealthValue = 4000,
        maxDefenseValue = 3600,
        bulletTemplateIndex = 5,
        bulletSpeed = 100,
        atkIntervalFrame = 101,
        bulletNumPerAtk = 3,
        bulletIntervalFrame = 17,
        exp = 300
    },
    [5] = {
        templateUnitIndex = 5,
        atkMethodType = 1,
        damageValuePerBullet = 60,
        maxHealthValue = 5000,
        maxDefenseValue = 4600,
        bulletTemplateIndex = 6,
        bulletSpeed = 100,
        atkIntervalFrame = 101,
        bulletNumPerAtk = 3,
        bulletIntervalFrame = 17,
        exp = 300
    },
    [6] = {
        templateUnitIndex = 6,
        atkMethodType = 1,
        damageValuePerBullet = 70,
        maxHealthValue = 6000,
        maxDefenseValue = 5600,
        bulletTemplateIndex = 6,
        bulletSpeed = 100,
        atkIntervalFrame = 101,
        bulletNumPerAtk = 3,
        bulletIntervalFrame = 17,
        exp = 300
    }
}




return {
    gameCameraBindUnit = gameCameraBindUnit,
    turretCollision = turretCollision,
    baseHexComponent = baseHexComponent,
    turretComponentData = turretComponentData,
    enemyUnitTemplates = enemyUnitTemplates,
    enemyUnitProperties = enemyUnitProperties,
    bulletTemplates = bulletTemplates
}
