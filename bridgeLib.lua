local api = require "api"
local constant = require "constant"
local bridgeLib = {

}

---创建连接特效
---@param vfxKey integer
---@param start Unit
---@param startSocket Enums.ModelSocket
---@param with Unit
---@param withSocket Enums.ModelSocket
---@param duration Fixed
function bridgeLib.createLinkedVfx(vfxKey, start, startSocket, with, withSocket, duration)
    api.sendGlobalCustomEvent(constant.BRIDGE_CREATE_LINKED_EFFECT_EVENT, {
        start = start,
        startSocket = startSocket,
        with = with,
        withSocket = withSocket,
        duration = duration,
    })
end

return bridgeLib
