local api = require("api")


local vfxRender = {
    createVfx = api.createVFX,
    createVfxWithSocket = api.createVFXWithSocket,
}



---设置场景特效状态
---@param status boolean
function vfxRender.setVfxRenderingStatus(status)
    if status then
        vfxRender.createVfx = api.createVfxApi
        vfxRender.createVfxWithSocket = api.createVFXWithSocket
    else
        vfxRender.createVfx = function() end
        vfxRender.createVfxWithSocket = function() end
    end
end

return vfxRender
