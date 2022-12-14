-- Cosine API
-- Cosine is a small multi-accounting and permissions manager for ComputerCraft.

local sha256 = require "cos-api.sha256"
local function deepcopy(t)
    local t2 = {}
    for k, v in t do
        if type(v) == 'table' then
            t2[k] = deepcopy(v)
        else
            t2[k] = v
        end
    end
    return t2
end

local cos_idx = {}
cos = {} -- global Cosine API namespace

cos[cos_idx] = {
    apis = {
        commands = commands,
        disk = disk,
        fs = fs,
        gps = gps,
        http = http,
        -- io = io,
        rednet = rednet,
        redstone = redstone,
        settings = settings,
        shell = shell,
        turtle = turtle,
    },
    connected_user = nil,
    users = settings.get("cos_users", {})
} -- original APIs, overwritten by Cosine

if cos[cos_idx].users.root == nil then
    cos[cos_idx].users.root = {
        password = sha256('toor'),
        permissions = {
            fs = {
                '/'
            },
            commands = true,
            disk = true,
            gps = true,
            http = true,
            rednet = true,
            redstone = true,
            settings = true,
            shell = true,
            turtle = true,
            manage_users = true,
        }
    }
end

function cos.login(username, password)
    if username == nil then
        error('missing username', 2)
    end
    if password == nil then
        error('missing password', 2)
    end
    if cos[cos_idx].users[username] == nil then
        error('did not find user', 2)
    end
    if sha256(password) ~= cos[cos_idx].users[username].password then
        error('wrong password', 2)
    end
    cos[cos_idx].connected_user = username
    cos[cos_idx].apis.settings.set("cos_users", cos[cos_idx].users)
    return true
end

function cos.logout()
    cos[cos_idx].connected_user = nil
    return true
end

function cos.getUsername()
    return cos[cos_idx].connected_user
end

function cos.getPermissions()
    local user = cos[cos_idx].connected_user
    if user == nil then
        return nil
    end
    return cos[cos_idx].users[user].permissions
end

function cos.createUser(username, password)
    local perms = cos.getPermissions()
    if perms == nil then
        error('not logged in', 2)
    end
    if not perms.manage_users then
        error('missing permission "manage_users" for user '..cos.getUsername(), 2)
    end
    cos[cos_idx].users[username] = {
        password = sha256(password),
        permissions = {
            fs = {
                '/usr/'..username,
                '/usr/shared'
            },
            commands = false,
            disk = true,
            gps = false,
            http = false,
            rednet = true,
            redstone = true,
            settings = true,
            shell = true,
            turtle = true,
            manage_users = false
        }
    }
    cos[cos_idx].apis.settings.set("cos_users", cos[cos_idx].users)
    return true
end

function cos.removeUser(username)
    local perms = cos.getPermissions()
    if perms == nil then
        error('not logged in', 2)
    end
    if not perms.manage_users then
        error('missing permission "manage_users" for user '..cos.getUsername(), 2)
    end
    if username == 'root' then
        error('cannot delete root user', 2)
    end
    cos[cos_idx].users[username] = nil
    cos[cos_idx].apis.settings.set("cos_users", cos[cos_idx].users)
    return true
end

function cos.changePassword(username, old_password, new_password)
    local perms = cos.getPermissions()
    if perms == nil then
        error('not logged in', 2)
    end
    if cos.getUsername() ~= username and not perms.manage_users then
        error('missing permission "manage_users" for user '..cos.getUsername(), 2)
    end
    if sha256(old_password) ~= cos[cos_idx].users[username].password then
        error('wrong initial password', 2)
    end
    if old_password == new_password then
        error('cannot change to the password already in use', 2)
    end
    cos[cos_idx].users[username].password = sha256(new_password)
    return true
end