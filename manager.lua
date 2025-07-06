local constant = require("constant")

---@class BulletCacheData
---@field unitBase Unit
---@field available boolean





local manager = {
    cacheConfig = constant.cacheConfig,
    bulletCache = {
        [1] = {
            cacheCircularQueue = {},
            queuePointer = 1,
            queueSize = 0,
        }
    }
}

function manager.cacheInit()

end

return manager
