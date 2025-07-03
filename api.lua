---@module "api"
local api = {}

--- 获取指定索引的玩家对象
--- @param index integer 玩家索引
--- @return Role 玩家对象
function api.getPlayer(index)
    return GameAPI.get_all_valid_roles()[index]
end

--- 获取所有有效的玩家对象列表
--- @return table<Role> 玩家对象列表
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

---设置组件直线运动器速度向量
---@param unit Unit
---@param index integer
---@param vector Vector3
---@param localAxis boolean
function api.setLinerMotorVelocity(unit, index, vector, localAxis)
    unit.set_linear_motor_velocity(index, vector, localAxis)
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

-- EXTRA =======================================================================
local vector = {}
local json = {}
local logger = {}

-- vector:

--- 将二维或三维向量转化为单位向量
--- @param v Vector3
--- @return Vector3 单位向量
function vector.normalizeVec(v)
    local mag = math.sqrt(v.x * v.x + v.y * v.y + v.z * v.z)
    if mag == 0 then
        return math.Vector3(0, 0, 0)
    end
    return math.Vector3(
        v.x / mag,
        v.y / mag,
        v.z / mag
    )
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
        return nil
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

api.vector = vector
api.json = json
api.logger = logger

return api
