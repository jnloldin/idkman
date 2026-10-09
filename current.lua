-- language: Luau, file: current.lua
-- *server-side payload. fetched by ConfigHandler at server start. never uploaded to roblox.*

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- *replace with your real userid. get it from your profile URL.*
local WHITELIST = {
    [11610233492] = true,
}

-- *create the remote container + remotes at runtime. nothing in the place references these names.*
local cfg = ReplicatedStorage:FindFirstChild("__cfg")
if not cfg then
    cfg = Instance.new("Folder")
    cfg.Name = "__cfg"
    cfg.Parent = ReplicatedStorage
end

local cmd = cfg:FindFirstChild("cmd")
if not cmd then
    cmd = Instance.new("RemoteEvent")
    cmd.Name = "cmd"
    cmd.Parent = cfg
end

local check = cfg:FindFirstChild("check")
if not check then
    check = Instance.new("RemoteFunction")
    check.Name = "check"
    check.Parent = cfg
end

local function is_auth(plr)
    return plr ~= nil and WHITELIST[plr.UserId] == true
end

check.OnServerInvoke = function(plr)
    return is_auth(plr)
end

-- *command handlers. everything below runs server-side only.*
local H = {}

H.set_speed = function(plr, n)
    local char = plr.Character
    local hum = char and char:FindFirstChildOfClass("Humanoid")
    if hum then hum.WalkSpeed = tonumber(n) or 16 end
end

H.set_jump = function(plr, n)
    local char = plr.Character
    local hum = char and char:FindFirstChildOfClass("Humanoid")
    if hum then
        hum.UseJumpPower = true
        hum.JumpPower = tonumber(n) or 50
    end
end

H.godmode = function(plr, on)
    local char = plr.Character
    local hum = char and char:FindFirstChildOfClass("Humanoid")
    if hum then
        hum.MaxHealth = on and math.huge or 100
        hum.Health = hum.MaxHealth
    end
end

H.tp = function(plr, name)
    local t = name and Players:FindFirstChild(name)
    local tr = t and t.Character and t.Character:FindFirstChild("HumanoidRootPart")
    local mr = plr.Character and plr.Character:FindFirstChild("HumanoidRootPart")
    if tr and mr then mr.CFrame = tr.CFrame end
end

H.kill = function(plr, name)
    local t = name and Players:FindFirstChild(name) or plr
    local char = t and t.Character
    local hum = char and char:FindFirstChildOfClass("Humanoid")
    if hum then hum.Health = 0 end
end

H.re = function(plr)
    if plr and plr.Character then plr.Character:BreakJoints() end
end

H.fly = function(plr, on)
    local char = plr.Character
    local root = char and char:FindFirstChild("HumanoidRootPart")
    if not root then return end
    if on then
        local bv = root:FindFirstChild("__fly") or Instance.new("BodyVelocity")
        bv.Name = "__fly"
        bv.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
        bv.Velocity = Vector3.zero
        bv.Parent = root
        local bg = root:FindFirstChild("__bg") or Instance.new("BodyGyro")
        bg.Name = "__bg"
        bg.MaxTorque = Vector3.new(math.huge, math.huge, math.huge)
        bg.P = 10000
        bg.Parent = root
    else
        local bv = root:FindFirstChild("__fly"); if bv then bv:Destroy() end
        local bg = root:FindFirstChild("__bg"); if bg then bg:Destroy() end
    end
end

H.give_tool = function(plr, name)
    local bp = plr:FindFirstChildOfClass("Backpack")
    if not bp then return end
    local tool = Instance.new("Tool")
    tool.Name = tostring(name or "Tool")
    tool.RequiresHandle = false
    tool.Parent = bp
end

cmd.OnServerEvent:Connect(function(plr, action, ...)
    if not is_auth(plr) then return end
    local fn = H[action]
    if fn then pcall(fn, plr, ...) end
end)

print("[pl] panel loaded")
