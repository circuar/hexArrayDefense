---@module "api"
local api = {}

--- 获取指定索引的玩家对象
--- @param index integer 玩家索引
--- @return Role 玩家对象
function api.getPlayer(index)
    return GameAPI.get_all_valid_roles()[index]
end

--- 获取所有有效的玩家对象列表
--- @return Role[] 玩家对象数组
function api.getPlayers()
    return GameAPI.get_all_valid_roles()
end

--- 发送全局自定义事件
--- @param event string 事件名称
--- @param data table 事件数据
function api.sendGlobalCustomEvent(event, data)
    LuaAPI.global_send_custom_event(event, data)
end

--- 向指定玩家发送UI自定义事件
--- @param player Role 玩家对象
--- @param event string 事件名称
--- @param data table 事件数据
function api.sendUICustomEvent(player, event, data)
    player.send_ui_custom_event(event, data)
end

--- 获取玩家的存档数据
--- @param player Role 玩家对象
--- @param type Enums.ArchiveType 存档类型
--- @param id integer 存档ID
--- @return any 存档数据
function api.fetchArchiveData(player, type, id)
    return player.get_archive_by_type(type, id)
end

--- 保存玩家的存档数据
--- @param player Role 玩家对象
--- @param type Enums.ArchiveType 存档类型
--- @param id integer 存档ID
--- @param data any 存档数据
function api.saveArchiveData(player, type, id, data)
    player.set_archive_by_type(type, id, data)
end

--- 延迟指定帧数后执行回调函数
--- @param callback function 回调函数
--- @param delayFrames integer 延迟帧数
function api.setTimeout(callback, delayFrames)
    LuaAPI.call_delay_frame(delayFrames, callback)
end

--- 根据单位ID获取单位对象
--- @param id integer 单位ID
--- @return Unit 单位对象
function api.getUnitById(id)
    return GameAPI.get_unit(id)
end

--- 注册全局自定义事件监听器
--- @param event string 事件名称
--- @param callback function 回调函数
function api.registerGlobalCustomEventListener(event, callback)
    LuaAPI.global_register_custom_event(event, callback)
end

--- 设置玩家的摄像机绑定模式
--- @param player Role 玩家对象
--- @param mode Enums.CameraBindMode 绑定模式
function api.setCameraBindMode(player, mode)
    player.set_camera_bind_mode(mode)
end

--- 设置摄像机跟随指定单位
--- @param player Role 玩家对象
--- @param unit Unit 单位对象
--- @param followRotation boolean 是否跟随旋转
function api.setCameraFollowUnit(player, unit, followRotation)
    ---@diagnostic disable-next-line: undefined-field
    GlobalAPI.set_camera_follow_unit(player, unit, followRotation)
end

--- 设置指定玩家的相机属性。
--- @param player Role 需要设置相机属性的玩家对象。
--- @param propertyEnum Enums.CameraPropertyType 表示要修改的相机属性的枚举值。
--- @param value number 要赋给指定相机属性的值。
function api.setCameraProperty(player, propertyEnum, value)
    player.set_camera_property(propertyEnum, value)
end

--- 批量设置玩家相机的多个属性。
--- @param player Role 玩家对象，需要设置相机属性的目标玩家。
--- @param properties table<Enums.CameraPropertyType, number> 包含属性键值对的表，每个键为Enums.CameraPropertyType枚举，值为对应的浮点数属性值。
--- @usage api.setCameraProperties(player, {[Enums.CameraPropertyType.Fov] = 90.0, [Enums.CameraPropertyType.Distance] = 10.0})
function api.setCameraProperties(player, properties)
    for propertyEnum, value in pairs(properties) do
        api.setCameraProperty(player, propertyEnum, value)
    end
end

---添加直线运动
---@param unit Unit 单位
---@param vec Vector3 速度向量
---@param localAxis boolean 是否局部空间
function api.addLinearMotor(unit, vec, time, localAxis)
    unit.add_linear_motor(vec, time, localAxis)
end

---设置组件直线运动器速度向量
---@param unit Unit
---@param index integer
---@param vector Vector3
---@param localAxis boolean
function api.setLinerMotorVelocity(unit, index, vector, localAxis)
    unit.set_linear_motor_velocity(index, vector, localAxis)
end

---添加环绕运动
---@param unit Unit 单位
---@param target Unit 环绕目标
---@param angularVelocity Vector3 角速度
---@param duration Fixed 时间
---@param followRotation  boolean? 是否跟随旋转
function api.addSurroundMotor(unit, target, angularVelocity, duration, followRotation)
    unit.add_surround_motor(target, angularVelocity, duration, followRotation)
end

---获取组件坐标
---@param unit Unit
---@return Vector3
function api.positionOf(unit)
    return unit.get_position()
end

---设置单位坐标
---@param unit Unit
---@param pos Vector3
function api.setPosition(unit, pos)
    unit.set_position(pos)
end

---禁用运动器
---@param unit Unit
---@param index integer
function api.disableMotor(unit, index)
    unit.disable_motor(index)
end

---创建特效
---@param effectKey integer 特效编号
---@param pos Vector3 特效创建位置
---@param rotation Quaternion? 旋转
---@param zoom Fixed? 特效缩放
---@param duration Fixed? 持续时间
---@param speed Fixed? 播放速度
---@param soundEnabled boolean? 开启声音，默认关闭
function api.createVFX(effectKey, pos, rotation, zoom, duration, speed, soundEnabled)
    GameAPI.play_sfx_by_key(
        effectKey,
        pos,
        rotation or math.Quaternion(0, 0, 0),
        zoom or 1.0,
        duration or 5.0,
        speed or 1.0,
        soundEnabled or false
    )
end

---创建绑定特效
---@param vfxKey integer 特效编号
---@param unit Unit 绑定到的组件
---@param socket Enums.ModelSocket 挂载点
---@param zoom number 缩放倍数
---@param duration number 持续时间
---@param bindType Enums.BindType 绑定类型
function api.createVFXWithSocket(vfxKey, unit, socket, zoom, duration, bindType)
    GameAPI.create_sfx_with_socket(vfxKey, unit, socket, zoom, duration, bindType)
end

---设置单位旋转角
---@param unit Unit
---@param rotation Quaternion
function api.setUnitRotation(unit, rotation)
    unit.set_orientation(rotation)
end

---注册帧回调函数
---@param preHandler function 帧前回调函数
---@param afterHandler function 帧后回调函数
function api.setFrameHandler(preHandler, afterHandler)
    LuaAPI.set_tick_handler(preHandler, afterHandler)
end

---创建组件
---@param unitKey UnitKey
---@param position Vector3
---@param rotation Quaternion
---@param zoom Vector3
---@param player Role?
---@return Obstacle
function api.createComponent(unitKey, position, rotation, zoom, player)
    return GameAPI.create_obstacle(unitKey, position, rotation, zoom, player)
end

---创建组件组
---@param unitGroupKey UnitGroupKey
---@param position Vector3
---@param rotation Quaternion
---@param player Role?
---@return UnitGroup
function api.createComponentGroup(unitGroupKey, position, rotation, player)
    return GameAPI.create_unit_group(unitGroupKey, position, rotation, player)
end

---创建触发区域
---@param triggerSpaceKey CustomTriggerSpaceKey 触发区域编号
---@param position Vector3 位置
---@param rotation Quaternion 旋转
---@param zoom Vector3 缩放
---@param player Role? 所属玩家
---@return CustomTriggerSpace 创建出的触发区域
function api.createTriggerSpace(triggerSpaceKey, position, rotation, zoom, player)
    return GameAPI.create_customtriggerspace(triggerSpaceKey, position, rotation, zoom, player)
end

-- ---添加绑定
-- ---@param obstacle Obstacle 被绑定的组件
-- ---@param unitKey UnitKey 绑定单位编号
-- ---@param socket Enums.ModelSocket 挂点
-- ---@param offset Vector3? 偏移
-- ---@param rotation Quaternion? 旋转
-- ---@param zoom Vector3? 缩放
-- ---@return string 绑定ID
-- function api.bindModel(obstacle, unitKey, socket, offset, rotation, zoom)
--     return obstacle.bind_model(unitKey, socket, offset, rotation, zoom)
-- end

---注册单位触发器
---@param unit Unit 单位
---@param eventData any[] 事件名及注册参数
---@param callback function 回调
---@return integer 触发器ID
function api.registerUnitTriggerEventListener(unit, eventData, callback)
    return LuaAPI.unit_register_trigger_event(unit, eventData, callback)
end

---获取对象的旋转
---@param unit Unit
---@return Quaternion
function api.rotationOf(unit)
    return unit.get_orientation()
end

---获取对象的线速度
---@param unit Unit
---@return Vector3
function api.velocityOf(unit)
    return unit.get_linear_velocity()
end

---设置受力物体的线速度
---@param unit Unit
---@param velocity Vector3
function api.setUnitLinerVelocity(unit, velocity)
    unit.set_linear_velocity(velocity)
end

-- EXTRA =======================================================================
local vector = {}
local json = {}
local logger = {}
local extra = {}

-- vector:

--- 将二维或三维向量转化为单位向量
--- @param v Vector3
--- @return Vector3 单位向量
function vector.normalizeVec(v)
    local x, y, z = v.x, v.y, v.z
    local mag = x * x + y * y + z * z
    if mag == 0 then
        return math.Vector3(0, 0, 0)
    end
    mag = math.sqrt(mag)
    return math.Vector3(x / mag, y / mag, z / mag)
end

--- 标量线性插值（Lerp）
--- @param a number 起点
--- @param b number 终点
--- @param t number 插值因子 [0,1]
--- @return number 插值结果
function vector.lerp(a, b, t)
    return a + (b - a) * t
end

--- 三维向量线性插值
--- @param a Vector3
--- @param b Vector3
--- @param t number 插值因子 [0,1]
--- @return Vector3 插值结果
function vector.lerpVec3(a, b, t)
    return math.Vector3(
        vector.lerp(a.x, b.x, t),
        vector.lerp(a.y, b.y, t),
        vector.lerp(a.z, b.z, t)
    )
end

--- 计算x-z平面内向量与x正向朝向z正向旋转的夹角（度）
--- @param v Vector3
--- @return number
function vector.angleWithX(v)
    local angle = math.atan2(v.z, v.x) * 180 / math.pi
    if angle < 0 then
        angle = angle + 360
    end
    return angle
end

---计算从一个向量旋转到另一个向量的旋转角
---@param a Vector3
---@param b Vector3
---@return Quaternion
function vector.rotationBetweenVec(a, b)
    -- 读取 a、b 的 yaw/pitch
    local yawA   = a.yaw
    local pitchA = a.pitch
    local yawB   = b.yaw
    local pitchB = b.pitch

    -- 构造仅含 yaw/pitch 的四元数，roll 始终为 0
    local qFrom  = math.Quaternion(pitchA, yawA, 0)
    local qTo    = math.Quaternion(pitchB, yawB, 0)

    -- 返回从 qFrom 到 qTo 的旋转增量
    qFrom:inverse()
    return qTo * qFrom
end

--- 使用四元数旋转一个向量
---@param vec Vector3  原始向量
---@param quat Quaternion  旋转四元数
---@return Vector3  旋转后的新向量
function vector.rotateVectorByQuaternion(vec, quat)
    -- 将 vec 转换为纯四元数（w = 0）
    local vx, vy, vz = vec.x, vec.y, vec.z
    local qw, qx, qy, qz = quat.w, quat.x, quat.y, quat.z

    -- 计算 q * v
    local ix = qw * vx + qy * vz - qz * vy
    local iy = qw * vy + qz * vx - qx * vz
    local iz = qw * vz + qx * vy - qy * vx
    local iw = -qx * vx - qy * vy - qz * vz

    -- 计算 (q * v) * q^-1
    local rx = ix * qw + iw * -qx + iy * -qz - iz * -qy
    local ry = iy * qw + iw * -qy + iz * -qx - ix * -qz
    local rz = iz * qw + iw * -qz + ix * -qy - iy * -qx

    return math.Vector3(rx, ry, rz)
end

--- 保持方向，将向量长度设置为指定值
--- @param v Vector3 原向量
--- @param length number 目标长度
--- @return Vector3 方向不变、长度为 newLen 的新向量
function vector.resetVectorLength(v, length)
    -- 拷贝一个向量，避免修改原向量
    local out = math.Vector3(v.x, v.y, v.z)
    -- normalize() 会把 out 单位化，并返回原来的长度
    local oldLen = out:normalize()
    -- 如果原向量不是零向量，按比例缩放
    if oldLen > 0 then
        out.x = out.x * length
        out.y = out.y * length
        out.z = out.z * length
    end
    -- 返回新的向量
    return out
end

-- json:

-- 辅助函数：转义字符串
function json.escapeStr(s)
    s = s:gsub('\\', '\\\\')
    s = s:gsub('"', '\\"')
    s = s:gsub('\n', '\\n')
    s = s:gsub('\r', '\\r')
    s = s:gsub('\t', '\\t')
    return s
end

--- table转json字符串
---  @param obj table
--- @return string
function json.stringify(obj)
    local t = type(obj)
    if t == "number" or t == "boolean" then
        return tostring(obj)
    elseif t == "string" then
        return '"' .. json.escapeStr(obj) .. '"'
    elseif t == "table" then
        local isArray = true
        local idx = 1
        for k, _ in pairs(obj) do
            if k ~= idx then
                isArray = false
                break
            end
            idx = idx + 1
        end
        local result = {}
        if isArray then
            for i = 1, #obj do
                table.insert(result, json.stringify(obj[i]))
            end
            return '[' .. table.concat(result, ',') .. ']'
        else
            for k, v in pairs(obj) do
                local key = type(k) == "number" and ('"' .. k .. '"') or json.stringify(k)
                table.insert(result, key .. ':' .. json.stringify(v))
            end
            return '{' .. table.concat(result, ',') .. '}'
        end
    else
        return 'null'
    end
end

-- 跳过空白字符
function json.skipWhitespace(str, i)
    while i <= #str and str:sub(i, i):match('%s') do
        i = i + 1
    end
    return i
end

-- 解析字符串
function json.parseString(str, i)
    i = i + 1 -- skip '"'
    local res = ''
    while i <= #str do
        local c = str:sub(i, i)
        if c == '"' then
            return res, i + 1
        elseif c == '\\' then
            local next = str:sub(i + 1, i + 1)
            if next == '"' then
                res = res .. '"'
            elseif next == '\\' then
                res = res .. '\\'
            elseif next == '/' then
                res = res .. '/'
            elseif next == 'b' then
                res = res .. '\b'
            elseif next == 'f' then
                res = res .. '\f'
            elseif next == 'n' then
                res = res .. '\n'
            elseif next == 'r' then
                res = res .. '\r'
            elseif next == 't' then
                res = res .. '\t'
            else
                error('Invalid escape at ' .. i)
            end
            i = i + 2
        else
            res = res .. c
            i = i + 1
        end
    end
    error('Unclosed string at ' .. i)
end

-- 解析数字
function json.parseNumber(str, i)
    local numPat = '^%-?%d+%.?%d*[eE]?[%+%-]?%d*'
    local s = str:sub(i)
    local num = s:match(numPat)
    if not num then error('Invalid number at ' .. i) end
    local isFloat = num:find('%.') or num:find('e') or num:find('E')
    local val = 0
    if isFloat then
        -- 浮点数解析
        local sign, int, frac, exp = num:match('^(%-?)(%d*)%.?(%d*)[eE]?([%+%-]?%d*)$')
        int = int or ""
        frac = frac or ""
        exp = exp or ""
        val = 0
        for j = 1, #int do
            val = val * 10 + (int:byte(j) - 48)
        end
        local fracVal = 0
        for j = #frac, 1, -1 do
            fracVal = (fracVal + (frac:byte(j) - 48)) / 10
        end
        val = val + fracVal
        if sign == '-' then val = -val end
        if exp ~= "" then
            local expN = 0
            local expSign = 1
            if exp:sub(1, 1) == '-' then
                expSign = -1; exp = exp:sub(2)
            end
            if exp:sub(1, 1) == '+' then exp = exp:sub(2) end
            for j = 1, #exp do
                expN = expN * 10 + (exp:byte(j) - 48)
            end
            expN = expN * expSign
            if expN > 0 then
                for _ = 1, expN do val = val * 10 end
            elseif expN < 0 then
                for _ = 1, -expN do val = val / 10 end
            end
        end
    else
        -- 整数解析
        local sign, digits = num:match('^(%-?)(%d+)$')
        val = 0
        for j = 1, #digits do
            val = val * 10 + (digits:byte(j) - 48)
        end
        if sign == '-' then val = -val end
    end
    return val, i + #num
end

-- 解析数组
function json.parseArray(str, i)
    i = i + 1 -- skip '['
    local arr = {}
    i = json.skipWhitespace(str, i)
    if str:sub(i, i) == ']' then return arr, i + 1 end
    while true do
        local val
        val, i = json.parseValue(str, i)
        table.insert(arr, val)
        i = json.skipWhitespace(str, i)
        local c = str:sub(i, i)
        if c == ']' then return arr, i + 1 end
        if c ~= ',' then error('Expected , or ] at ' .. i) end
        i = json.skipWhitespace(str, i + 1)
    end
end

-- 解析对象
function json.parseObject(str, i)
    i = i + 1 -- skip '{'
    local obj = {}
    i = json.skipWhitespace(str, i)
    if str:sub(i, i) == '}' then return obj, i + 1 end
    while true do
        local key
        key, i = json.parseString(str, i)
        i = json.skipWhitespace(str, i)
        if str:sub(i, i) ~= ':' then error('Expected : at ' .. i) end
        i = json.skipWhitespace(str, i + 1)
        local val
        val, i = json.parseValue(str, i)
        obj[key] = val
        i = json.skipWhitespace(str, i)
        local c = str:sub(i, i)
        if c == '}' then return obj, i + 1 end
        if c ~= ',' then error('Expected , or } at ' .. i) end
        i = json.skipWhitespace(str, i + 1)
    end
end

-- 解析值
function json.parseValue(str, i)
    i = json.skipWhitespace(str, i)
    local c = str:sub(i, i)
    if c == '{' then
        return json.parseObject(str, i)
    elseif c == '[' then
        return json.parseArray(str, i)
    elseif c == '"' then
        return json.parseString(str, i)
    elseif c:match('[%d%-]') then
        return json.parseNumber(str, i)
    elseif str:sub(i, i + 3) == 'true' then
        return true, i + 4
    elseif str:sub(i, i + 4) == 'false' then
        return false, i + 5
    elseif str:sub(i, i + 3) == 'null' then
        return nil, i + 4
    else
        error('Invalid JSON value at position ' .. i)
    end
end

--- 解析JSON字符串为Lua表
--- @param str string 需要解析的JSON字符串
--- @return any
--- @throws 当JSON字符串存在多余内容时抛出错误
function json.parse(str)
    if str == nil or str == "" then
        return {}
    end

    local res, i = json.parseValue(str, 1)
    i = json.skipWhitespace(str, i)
    if i <= #str then error('Trailing garbage at ' .. i) end
    return res
end

-- logger:

logger.levels = { DEBUG = 1, INFO = 2, WARN = 3, ERROR = 4 }
logger.level = logger.levels.DEBUG

local levelNames = { [1] = "DEBUG", [2] = "INFO", [3] = "WARN", [4] = "ERROR" }

function logger.setLevel(level)
    if type(level) == "string" then
        level = logger.levels[level:upper()] or logger.levels.DEBUG
    end
    logger.level = level
end

local function log(level, ...)
    if level < logger.level then return end
    local msg = table.concat({ ... }, " ")
    print(string.format("[%s] %s", levelNames[level], msg))
end

function logger.debug(...) log(logger.levels.DEBUG, ...) end

function logger.info(...) log(logger.levels.INFO, ...) end

function logger.warn(...) log(logger.levels.WARN, ...) end

function logger.error(...) log(logger.levels.ERROR, ...) end

-- extra:


---将一个组件旋转到朝向指定向量方向
---@param unit Unit 单位
---@param towards Vector3 指向向量
---@param reference Vector3? 参考向量
function extra.setUnitTowardsTo(unit, towards, reference)
    local referenceVec = reference or math.Vector3(1, 0, 0)
    api.setUnitRotation(unit, vector.rotationBetweenVec(referenceVec, towards))
end

local framePreHandlerList = {}
local frameAfterHandlerList = {}
local tickCallbackEnabled = false

local function startTick()
    tickCallbackEnabled = true
    local function pre()
        for _, value in ipairs(framePreHandlerList) do
            value()
        end
    end

    local function after()
        for _, value in ipairs(frameAfterHandlerList) do
            value()
        end
    end

    api.setFrameHandler(pre, after)
end


function extra.addFramePreHandler(handler)
    framePreHandlerList[#framePreHandlerList + 1] = handler
    if not tickCallbackEnabled then
        startTick()
    end
    return #framePreHandlerList + 1
end

function extra.addFrameAfterHandler(handler)
    frameAfterHandlerList[#frameAfterHandlerList + 1] = handler
    if not tickCallbackEnabled then
        startTick()
    end
end

function extra.unRegisterPreHandler(index)
    table.remove(framePreHandlerList, index)
end

function extra.unRegisterAfterHandler(index)
    table.remove(frameAfterHandlerList, index)
end

--random:
---@class random
---@field seed number
local random   = {}
random.__index = random

local MASK32   = 0xFFFFFFFF

--- 构造一个 Random 实例
--- @param seed integer? 初始种子（可选，不传则用61）
--- @return random
function random.new(seed)
    local self = setmetatable({}, random)
    seed = seed or 61

    self.state = (seed ~= 0) and (seed & MASK32) or 1
    return self
end

--- 重置种子
--- @param seed integer 新种子
function random:setSeed(seed)
    seed = seed & MASK32
    self.state = (seed ~= 0) and seed or 1
end

--- 核心：生成下一个 bits 位随机数
--- @param bits integer 欲取出的位数 (1–32)
--- @return integer  [0, 2^bits)
function random:next(bits)
    local x = self.state
    -- xor shift 32 算法
    x = (x ~ ((x << 13) & MASK32)) & MASK32
    x = (x ~ (x >> 17)) & MASK32
    x = (x ~ ((x << 5) & MASK32)) & MASK32
    self.state = x

    -- 取高 bits 位
    if bits == 32 then
        return x
    else
        return (x >> (32 - bits)) & ((1 << bits) - 1)
    end
end

--- 生成 32 位随机整数（[0,2^32)）
--- @return integer
function random:nextInt()
    return self:next(32)
end

--- 生成 [0, bound) 之间的均匀随机整数
--- @param bound integer 上界（>0）
--- @return integer
function random:nextIntBound(bound)
    if bound <= 0 then error("bound must be positive") end
    -- 若为 2 的幂，直接掩码
    if (bound & (bound - 1)) == 0 then
        return self:next(31) & (bound - 1)
    end
    -- 拒绝采样保证无偏
    while true do
        local bits = self:next(31)
        local val  = bits % bound
        if bits - val + (bound - 1) >= 0 then
            return val
        end
    end
end

--- 生成 [0.0, 1.0) 双精度浮点数
--- @return number
function random:nextDouble()
    -- 用 32 位随机数作分子，除以 2^32
    return self:next(32) / (2 ^ 32)
end

--- 生成 [0.0, 1.0) 单精度浮点数
--- @return number
function random:nextFloat()
    return self:next(24) / (2 ^ 24)
end

--- 生成布尔值
--- @return boolean
function random:nextBoolean()
    return self:next(1) == 1
end

--- 生成一个“64 位”随机整数（安全到 53 位）
--- @return number
function random:nextLong()
    -- 用 21 位高随机 + 32 位低随机，合成最多 53 位
    local high = self:next(21)
    local low  = self:next(32)
    return high * (2 ^ 32) + low
end

api.vector = vector
api.json = json
api.logger = logger
api.extra = extra
api.random = random
return api
