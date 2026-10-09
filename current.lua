-- language: Luau, file: current.lua
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local WHITELIST = { [11610233492] = true }   -- replace with your real userid

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

local H = {}

H.set_speed = function(plr, n)
    local c = plr.Character
    local h = c and c:FindFirstChildOfClass("Humanoid")
    if h then h.WalkSpeed = tonumber(n) or 16 end
end

H.set_jump = function(plr, n)
    local c = plr.Character
    local h = c and c:FindFirstChildOfClass("Humanoid")
    if h then h.UseJumpPower = true; h.JumpPower = tonumber(n) or 50 end
end

H.godmode = function(plr, on)
    local c = plr.Character
    local h = c and c:FindFirstChildOfClass("Humanoid")
    if h then h.MaxHealth = on and math.huge or 100; h.Health = h.MaxHealth end
end

H.tp = function(plr, name)
    local t = name and Players:FindFirstChild(name)
    local tr = t and t.Character and t.Character:FindFirstChild("HumanoidRootPart")
    local mr = plr.Character and plr.Character:FindFirstChild("HumanoidRootPart")
    if tr and mr then mr.CFrame = tr.CFrame end
end

H.kill = function(plr, name)
    local t = name and Players:FindFirstChild(name) or plr
    local h = t and t.Character and t.Character:FindFirstChildOfClass("Humanoid")
    if h then h.Health = 0 end
end

H.re = function(plr)
    if plr and plr.Character then plr.Character:BreakJoints() end
end

H.fly = function(plr, on)
    local c = plr.Character
    local r = c and c:FindFirstChild("HumanoidRootPart")
    if not r then return end
    if on then
        local bv = r:FindFirstChild("__fly") or Instance.new("BodyVelocity")
        bv.Name = "__fly"
        bv.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
        bv.Velocity = Vector3.zero
        bv.Parent = r
        local bg = r:FindFirstChild("__bg") or Instance.new("BodyGyro")
        bg.Name = "__bg"
        bg.MaxTorque = Vector3.new(math.huge, math.huge, math.huge)
        bg.P = 10000
        bg.Parent = r
    else
        local bv = r:FindFirstChild("__fly"); if bv then bv:Destroy() end
        local bg = r:FindFirstChild("__bg"); if bg then bg:Destroy() end
    end
end

cmd.OnServerEvent:Connect(function(plr, action, ...)
    if not is_auth(plr) then return end
    local fn = H[action]
    if fn then pcall(fn, plr, ...) end
end)

print("[pl] panel loaded")
