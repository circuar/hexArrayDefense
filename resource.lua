local api = require("api")

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
        defaultZoom = math.Vector3(0.5, 5, 0.5)
    },
    [2] = {

    },
    [3] = {

    }
}




---@class TurretComponentData
---@field base Unit
---@field basePosition Vector3
---@field rotationPart Unit
---@field rotationPartBaseOffset Vector3
---@field towardsReferenceVec Vector3
---@field bulletCreateOffset Vector3
---@field bulletTemplateIndex integer
---@field isMainTurret boolean
---@field atkMethodType integer
---@field atkCoolDown number
---@field bulletSpeed number
---松散数组
---@type TurretComponentData[]
local turretComponentData = {
    --无运动器，未绑定
    [1] = {
        base = api.getUnitById(1466853682),
        basePosition = math.Vector3(0, 59, 0),
        rotationPart = api.getUnitById(1812918448),
        rotationPartBaseOffset = math.Vector3(0, 5, 0),
        towardsReferenceVec = math.Vector3(0, 0, 1),
        bulletCreateOffset = math.Vector3(0, 5, 13.5),
        bulletTemplateIndex = 1,
        isMainTurret = true,
        atkMethodType = 1,
        atkCoolDown = 0.3,
        bulletSpeed = 150
    },
    -- [2] = {
    --     base = api.getUnitById(),
    --     rotationPart = api.getUnitById(),
    --     towardsReferenceVec = math.Vector3(),
    --     bulletCreatePoint = math.Vector3(),
    --     bulletTemplateIndex = 1
    -- },

}


local enemyUnitTemplates = {
    [1] = {
        presetId = 1073823833,
        towardsReferenceVector = math.Vector3(1, 0, 0),
        defaultZoom = math.Vector3(1.92, 0.17, 2.00),
    },
}

local enemyUnitProperties = {
    [1] = {
        templateUnitIndex = 1,
        atkMethodType = 1,
        damageValuePerBullet = 20,
        maxHealthValue = 400,
        maxDefenseValue = 300,
        bulletTemplateIndex = 1
    }
}




return {
    baseHexComponent = baseHexComponent,
    turretComponentData = turretComponentData,
    enemyUnitTemplates = enemyUnitTemplates,
    enemyUnitProperties = enemyUnitProperties,
    bulletTemplates = bulletTemplates
}
