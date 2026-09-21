local home = os.getenv("HOME")
local hypr = home .. "/.config/hypr"
local caelestia = home .. "/.config/caelestia"

package.path = package.path .. ";" .. hypr .. "/?.lua;" .. hypr .. "/?/init.lua;" .. caelestia .. "/?.lua"

local binds = {}
local unbinds = {}

local function read_file(path)
    local f = io.open(path, "r")
    if not f then return "" end
    local content = f:read("*a")
    f:close()
    return content
end

-- Parse comments and variable names from variables.lua
local var_categories = {}
local var_comments = {}

local function parse_variable_metadata()
    local content = read_file(hypr .. "/variables.lua")
    local current_cat = "General"
    local last_comment = ""
    for line in content:gmatch("[^\r\n]+") do
        local cat = line:match("^%s*%-%-%s*([^%-].-)$")
        if cat and not line:find("=====") and not line:find("%-%-%-%-") then
            cat = cat:gsub("^%s+", ""):gsub("%s+$", "")
            if #cat > 1 and cat ~= "HYPRLAND" and cat ~= "KEYBINDS" and cat ~= "Modifier only, the actual binds will be mod + 0-9. These should be strings and not arrays." and not cat:find("All the following") then
                current_cat = cat
            end
            last_comment = cat
        end
        local var_name = line:match("^%s*([%w_]+)%s*=")
        if var_name then
            var_categories[var_name] = current_cat
            if last_comment ~= "" and last_comment ~= current_cat then
                var_comments[var_name] = last_comment
            end
        end
    end
end

parse_variable_metadata()

-- Load variables with user overrides
local vars = require("variables")
local ok_overrides, overrides = pcall(require, "hypr-vars")
if ok_overrides and type(overrides) == "table" then
    for k, v in pairs(overrides) do
        vars[k] = v
    end
end

local key_to_var = {}
for k, v in pairs(vars) do
    if type(v) == "string" then
        key_to_var[v:gsub("%s+", ""):lower()] = k
    elseif type(v) == "table" then
        for _, item in ipairs(v) do
            if type(item) == "string" then
                key_to_var[item:gsub("%s+", ""):lower()] = k
            end
        end
    end
end

-- Mock fn (utils.functions)
local fn = {
    wsaction = function(action, range, i)
        local desc = ""
        if action == "focus" and range == "" then
            desc = "Focus workspace " .. i
        elseif action == "move" and range == "" then
            desc = "Move active window to workspace " .. i
        elseif action == "focus" and range == "group" then
            desc = "Focus workspace group " .. i
        elseif action == "move" and range == "group" then
            desc = "Move active window to workspace group " .. i
        end
        local eval = string.format('local fn = require("utils.functions"); fn.wsaction(%q, %q, %d)()', action, range, i)
        return {
            __is_fn = true,
            desc = desc,
            eval = eval,
            category = "Workspaces"
        }
    end,
    resize_active_window = function(x, y)
        local direction = ""
        if x < 0 then direction = "Decrease window width (" .. math.abs(x) .. "%)"
        elseif x > 0 then direction = "Increase window width (" .. x .. "%)"
        elseif y < 0 then direction = "Decrease window height (" .. math.abs(y) .. "%)"
        elseif y > 0 then direction = "Increase window height (" .. y .. "%)"
        end
        local eval = string.format('local fn = require("utils.functions"); fn.resize_active_window(%d, %d)()', x, y)
        return {
            __is_fn = true,
            desc = direction,
            eval = eval,
            category = "Window Actions"
        }
    end,
    toggle = function(special_workspace)
        local names = {
            specialws = "Toggle special workspace",
            sysmon = "Toggle system monitor (btop)",
            music = "Toggle music player",
            communication = "Toggle communication apps (Discord / WhatsApp)",
            todo = "Toggle todo workspace"
        }
        local eval = string.format('local fn = require("utils.functions"); fn.toggle(%q)()', special_workspace)
        return {
            __is_fn = true,
            desc = names[special_workspace] or ("Toggle special workspace: " .. special_workspace),
            eval = eval,
            category = "Special Workspaces"
        }
    end,
    resize_by_screen = function(x, y) return { x = x, y = y } end,
    move_actions = function() return {} end
}
package.loaded["utils.functions"] = fn

-- Mock hl environment
hl = {
    bind = function(key, action, flags)
        flags = flags or {}
        local act_type = "unknown"
        local act_detail = ""
        local act_eval = ""
        local desc = flags.description or ""
        local category = nil

        if type(action) == "table" then
            if action.__is_fn then
                act_type = "function"
                desc = desc ~= "" and desc or action.desc
                act_eval = action.eval
                category = action.category
            else
                act_type = action.dsp or "dispatcher"
                if type(action.arg) == "table" then
                    local parts = {}
                    for k, v in pairs(action.arg) do table.insert(parts, k .. "=" .. tostring(v)) end
                    act_detail = "{" .. table.concat(parts, ", ") .. "}"
                elseif action.arg ~= nil then
                    act_detail = tostring(action.arg)
                end
                if action.raw_eval then
                    act_eval = action.raw_eval
                end
            end
        elseif type(action) == "function" then
            act_type = "function"
            act_detail = "Lua function"
        elseif type(action) == "string" then
            act_type = "string"
            act_detail = action
        end

        table.insert(binds, {
            key = key,
            norm_key = key:gsub("%s+", ""):lower(),
            flags = flags,
            desc = desc,
            category = category,
            act_type = act_type,
            act_detail = act_detail,
            act_eval = act_eval,
            source = "default"
        })
    end,
    unbind = function(key)
        table.insert(unbinds, key)
    end,
    config = function() end,
    dispatch = function(...) end,
    get_active_workspace = function() return { id = 1 } end,
    get_active_monitor = function() return { width = 1920, height = 1080, scale = 1, x = 0, y = 0 } end,
    get_active_window = function() return { address = "0x1", size = { x = 800, y = 600 }, floating = false } end,
    get_windows = function() return {} end,
    get_active_special_workspace = function() return nil end,
    window_rule = function(...) end,
    layer_rule = function(...) end,
    monitor = function(...) end,
    exec = function(...) end,
    exec_once = function(...) end,
    dsp = setmetatable({}, {
        __index = function(t, k)
            return setmetatable({}, {
                __index = function(t2, k2)
                    return function(arg)
                        local dsp_name = k .. "." .. k2
                        local raw_eval = "hl.dispatch(hl.dsp." .. dsp_name .. "("
                        if type(arg) == "table" then
                            local fields = {}
                            for fk, fv in pairs(arg) do
                                table.insert(fields, fk .. " = " .. string.format("%q", tostring(fv)))
                            end
                            raw_eval = raw_eval .. "{" .. table.concat(fields, ", ") .. "}"
                        elseif arg ~= nil then
                            raw_eval = raw_eval .. string.format("%q", tostring(arg))
                        end
                        raw_eval = raw_eval .. "))"
                        return { dsp = dsp_name, arg = arg, raw_eval = raw_eval }
                    end
                end,
                __call = function(t2, arg)
                    local raw_eval = "hl.dispatch(hl.dsp." .. k .. "("
                    if type(arg) == "table" then
                        local fields = {}
                        for fk, fv in pairs(arg) do
                            table.insert(fields, fk .. " = " .. string.format("%q", tostring(fv)))
                        end
                        raw_eval = raw_eval .. "{" .. table.concat(fields, ", ") .. "}"
                    elseif arg ~= nil then
                        raw_eval = raw_eval .. string.format("%q", tostring(arg))
                    end
                    raw_eval = raw_eval .. "))"
                    return { dsp = k, arg = arg, raw_eval = raw_eval }
                end
            })
        end
    })
}

-- Load default keybinds
require("hyprland.keybinds")

-- Attach variable metadata
for _, b in ipairs(binds) do
    local var_name = key_to_var[b.norm_key]
    if var_name then
        b.var_name = var_name
        if not b.category then
            b.category = var_categories[var_name] or "General"
        end
    end
end

-- Parse comments from hypr-user.lua
local function parse_user_comments()
    local content = read_file(caelestia .. "/hypr-user.lua")
    local user_comments = {}
    local last_comment = ""
    for line in content:gmatch("[^\r\n]+") do
        local comment = line:match("^%s*%-%-%s*([^%-].-)$")
        if comment and not comment:find("=====") then
            last_comment = comment:gsub("^%s+", ""):gsub("%s+$", "")
        else
            local key = line:match('hl%.bind%s*%(%s*["\']([^"\']+)["\']')
            if key and last_comment ~= "" then
                user_comments[key:gsub("%s+", ""):lower()] = last_comment
                last_comment = ""
            elseif not line:match("^%s*$") and not line:match("^%s*%-%-") then
                last_comment = ""
            end
        end
    end
    return user_comments
end

local user_comments = parse_user_comments()

-- Load user keybinds from hypr-user.lua
local user_binds_start = #binds + 1
local ok_user, err_user = pcall(require, "hypr-user")
for i = user_binds_start, #binds do
    binds[i].source = "user"
    binds[i].category = "User Custom"
    local c = user_comments[binds[i].norm_key]
    if c and c ~= "" and binds[i].desc == "" then
        binds[i].desc = c
    end
end

-- Apply unbinds
local active_binds = {}
local unbind_map = {}
for _, u in ipairs(unbinds) do
    unbind_map[u:gsub("%s+", ""):lower()] = true
end

for _, b in ipairs(binds) do
    if not unbind_map[b.norm_key] then
        table.insert(active_binds, b)
    end
end

-- Output as JSON
local json_res = {}
for _, b in ipairs(active_binds) do
    table.insert(json_res, string.format([[{"key":%q,"category":%q,"desc":%q,"act_type":%q,"act_detail":%q,"act_eval":%q,"source":%q,"var_name":%q}]],
        b.key,
        b.category or "General",
        b.desc or "",
        b.act_type or "",
        b.act_detail or "",
        b.act_eval or "",
        b.source or "default",
        b.var_name or ""
    ))
end

print("[" .. table.concat(json_res, ",") .. "]")
