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






-- 防御塔模板数据
local turretTemplateMetaData = {
    [1] = {
        templateId = 1466853682,
        extraComponents = {
            yawAxis = {
                type = "common",
                templateId = 1079155529,
                offset = math.Quaternion(0, 6.5, 0),
            },
            pitchAxis = {
                type = "common",
                templateId = 1413387284,
                offset = math.Quaternion(2.35, 6, 0),
            }
        }
    },
    [2] = {
        templateId = 1466853682,
        extraComponents = {
            yawAxis = {
                type = "common",
                templateId = 1079155529,
                offset = math.Quaternion(0, 6.5, 0),
            },
            pitchAxis = {
                type = "common",
                templateId = 1413387284,
                offset = math.Quaternion(2.35, 6, 0),
            }
        }
    },
    [3] = {
        templateId = 1466853682,
        extraComponents = {
            yawAxis = {
                type = "common",
                templateId = 1079155529,
                offset = math.Quaternion(0, 6.5, 0),
            },
            pitchAxis = {
                type = "common",
                templateId = 1413387284,
                offset = math.Quaternion(2.35, 6, 0),
            }
        }
    },
    [4] = {
        templateId = 1466853682,
        extraComponents = {
            yawAxis = {
                type = "common",
                templateId = 1079155529,
                offset = math.Quaternion(0, 6.5, 0),
            },
            pitchAxis = {
                type = "common",
                templateId = 1413387284,
                offset = math.Quaternion(2.35, 6, 0),
            }
        }
    },
    [5] = {
        templateId = 1466853682,
        extraComponents = {
            yawAxis = {
                type = "common",
                templateId = 1079155529,
                offset = math.Quaternion(0, 6.5, 0),
            },
            pitchAxis = {
                type = "common",
                templateId = 1413387284,
                offset = math.Quaternion(2.35, 6, 0),
            }
        }
    },
    [6] = {
        templateId = 1466853682,
        extraComponents = {
            yawAxis = {
                type = "common",
                templateId = 1079155529,
                offset = math.Quaternion(0, 6.5, 0),
            },
            pitchAxis = {
                type = "common",
                templateId = 1413387284,
                offset = math.Quaternion(2.35, 6, 0),
            }
        }
    },
    [7] = {
        templateId = 1466853682,
        extraComponents = {
            yawAxis = {
                type = "common",
                templateId = 1079155529,
                offset = math.Quaternion(0, 6.5, 0),
            },
            pitchAxis = {
                type = "common",
                templateId = 1413387284,
                offset = math.Quaternion(2.35, 6, 0),
            }
        }
    }
}

-- 防御塔模板组件
local turretTemplateComponent = {}

-- 初始化

for index, data in ipairs(turretTemplateMetaData) do
    local cmpData = {}
    cmpData.base = api.getUnitById(data.templateId)
    cmpData.extra = {}
    for key, value in pairs(data.extraComponents) do
        cmpData.extra[key] = api.getUnitById(value.templateId)
    end
    turretTemplateComponent[index] = cmpData
end





return {
    baseHexComponentId,
    baseHexComponent,
    turretTemplateMetaData,
    turretTemplateComponent,

}
