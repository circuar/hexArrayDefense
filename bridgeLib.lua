local api = require "api"
local constant = require "constant"
local bridgeLib = {

}

---创建激光特效
---@param start Unit
---@param with Unit
---@param duration Fixed
function bridgeLib.createLaserVfx(start, with, duration)
    api.sendGlobalCustomEvent(constant.BRIDGE_CREATE_LASER_EFFECT_EVENT, {
        start = start,
        with = with,
        duration = duration,
    })
end

function bridgeLib.createLinkedVfx(start, with)
    api.sendGlobalCustomEvent(constant.BRIDGE_CREATE_LINKED_EFFECT_EVENT, {
        start = start,
        with = with
    })
end

return bridgeLib
