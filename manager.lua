local resource = require("resource")
local api      = require("api")
local constant = require("constant")

---@class BulletCacheSlot
---@field unitBase Obstacle
---@field defaultSlotPosition Vector3

local manager  = {
    bulletCacheSlotSize = { x = 100, z = 100, spacing = 1 },
    bulletCacheSlotHeight = 800,
    bulletCache = {
        [1] = {
            ---@type BulletCacheSlot[]
            cacheCircularQueue = {},
            --第一个未使用的索引
            queuePointer = 1,
            --最后一个未使用的元素的下一个索引
            queueTailNextPointer = 1,
            defaultQueueSize = 100,
        }
    }
}



local function calBulletDefaultSlotPos(generateSequence, slotXSize, slotZSize, spacing)
    local slotX = generateSequence % slotXSize
    local slotZ = generateSequence / slotXSize

    if slotZ > slotZSize then
        api.logger.error("<bullet cache manager> the number of slots created exceeds the limit")
    end

    local slotXPosition = slotX * spacing
    local slotZPosition = slotZ * spacing

    return math.Vector3(slotXPosition, manager.bulletCacheSlotHeight, slotZPosition)
end

--初始化bulletCache
function manager.bulletCacheInit()
    local bulletTemplates = resource.bulletTemplates
    local generateCount = 0

    for index, value in ipairs(manager.bulletCache) do
        local bltTemplate = bulletTemplates[index]
        for iterator = 1, manager.bulletCache[index].defaultQueueSize do
            generateCount = generateCount + 1

            local defaultPosition = calBulletDefaultSlotPos(
                generateCount,
                manager.bulletCacheSlotSize.x,
                manager.bulletCacheSlotSize.z,
                manager.bulletCacheSlotSize.spacing
            )

            local bullet = api.createComponent(bltTemplate.presetId, defaultPosition, math.Quaternion(0, 0, 0),
                bltTemplate.defaultZoom)
            api.setUnitCollisionStatusWith(bullet, resource.gameCameraBindUnit, false)
            ---@type BulletCacheSlot
            local bulletCacheData = {
                unitBase = bullet,
                defaultSlotPosition = defaultPosition
            }

            --加入缓存
            table.insert(value.cacheCircularQueue, bulletCacheData)
        end
    end
end

function manager.cacheInit()
    api.logger.info("cache init ...")
    -- 初始化子弹缓存
    api.setTimeout(function()
        manager.bulletCacheInit()
    end, 1)
end

---使用缓存代理创建子弹对象
---当缓存为空时会导致缓存失效
---@param bulletTemplateIndex integer
---@return Obstacle
function manager.bulletCreateProxy(bulletTemplateIndex, createPosition, initialRotation)
    local cache = manager.bulletCache[bulletTemplateIndex]
    local pointer = cache.queuePointer
    api.logger.warn(pointer)

    -- 队列为空
    -- 触发新对象生成
    -- 生成一个新的对象直接返回，且不进行数组物理扩容
    -- 当原对象返回缓存时直接销毁，维持缓存最大长度不变
    if cache.cacheCircularQueue[pointer].unitBase == nil then
        local bulletTemplate = resource.bulletTemplates[bulletTemplateIndex]
        local bullet = api.createComponent(
            bulletTemplate.presetId,
            createPosition,
            initialRotation,
            bulletTemplate.defaultZoom)
        api.setUnitCollisionStatusWith(bullet, resource.gameCameraBindUnit, false)
        return bullet
    end

    local bullet = cache.cacheCircularQueue[pointer].unitBase
    api.setPosition(bullet, createPosition)
    api.setUnitRotation(bullet, initialRotation)

    cache.cacheCircularQueue[pointer].unitBase = nil
    -- 缓存指针偏移处理
    cache.queuePointer = pointer % cache.defaultQueueSize + 1

    -- local closureUnit = bullet
    -- local closureUnitTemplateIndex = bulletTemplateIndex
    -- api.setTimeout(function()
    --     manager.bulletDestroyProxy(closureUnitTemplateIndex, closureUnit)
    -- end, 5 * constant.LOGIC_FPS)

    return bullet
end

---回收使用的组件
---@param bulletTemplateIndex integer
---@param bulletUnit Unit
function manager.bulletDestroyProxy(bulletTemplateIndex, bulletUnit)
    local cache = manager.bulletCache[bulletTemplateIndex]
    local tailNextPointer = cache.queueTailNextPointer

    --判断队列是否已满
    if cache.cacheCircularQueue[tailNextPointer].unitBase ~= nil then
        api.destroyUnitWithSubUnit(bulletUnit)
    end


    api.setPosition(bulletUnit, cache.cacheCircularQueue[tailNextPointer].defaultSlotPosition)
    ---@diagnostic disable-next-line: assign-type-mismatch
    cache.cacheCircularQueue[tailNextPointer].unitBase = bulletUnit

    cache.queueTailNextPointer = tailNextPointer % cache.defaultQueueSize + 1
end

return manager
