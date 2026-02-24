-- ═══════════════════════════════════════════════════════════
-- ADVANCED BOT PROTECTION v7.4 - DELAYED HOOK INSTALLATION
-- Waits for game to fully load before hooking to prevent crashes
-- ═══════════════════════════════════════════════════════════

local gameJobId = game.JobId

if not _G.ProtectionServers then _G.ProtectionServers = {} end
if _G.ProtectionServers[gameJobId] then return end
_G.ProtectionServers[gameJobId] = true

print("🔒 NUCLEAR PROTECTION LOADING...")

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local HttpService = game:GetService("HttpService")
local player = Players.LocalPlayer

-- Wait for player to fully load (prevents nil errors during teleport)
if not player then
    repeat task.wait(0.1) until Players.LocalPlayer
    player = Players.LocalPlayer
end

-- ═══════════════════════════════════════════════════════════
-- LEVEL 1: EXECUTOR FINGERPRINT ANNIHILATION
-- ═══════════════════════════════════════════════════════════

local nukeGlobals = {
    "syn", "SENTINEL_V2", "KRNL_LOADED", "PROTOSMASHER_LOADED",
    "is_synapse_function", "pebc_execute", "EVON_LOADED",
    "is_sirhurt_closure", "FLUXUS_LOADED", "OXYGEN_LOADED",
    "secure_load", "crypt", "make_writeable", "make_readonly",
    "isexecutorclosure", "checkcaller", "islclosure"
}

for _, name in ipairs(nukeGlobals) do
    pcall(function()
        if getgenv and getgenv()[name] then getgenv()[name] = nil end
        if _G[name] then _G[name] = nil end
    end)
end

pcall(function()
    if getgenv and getgenv().isexecutorclosure then
        getgenv().isexecutorclosure = function() return false end
    end
end)

pcall(function()
    if checkcaller then
        checkcaller = function() return true end
    end
end)

print("✓ Executor fingerprint nuked")

-- ═══════════════════════════════════════════════════════════
-- LEVEL 2: DELAYED REMOTE HOOKING
-- Wait 3 seconds before installing hooks (let other scripts load)
-- ═══════════════════════════════════════════════════════════

print("⏳ Remote hooks will install in 3 seconds...")

task.delay(3, function()
    local hookedCount = 0
    
    local function hookRemote(remote)
        if not remote then return end
        if not (remote:IsA("RemoteEvent") or remote:IsA("RemoteFunction")) then return end
        
        pcall(function()
            if remote.FireServer then
                local oldFire = remote.FireServer
                
                remote.FireServer = function(self, ...)
                    task.wait(math.random(1, 15) / 1000)
                    
                    local remoteName = tostring(self):lower()
                    if remoteName:find("anti") or remoteName:find("detect") or remoteName:find("check") then
                        return
                    end
                    
                    return oldFire(self, ...)
                end
                
                hookedCount = hookedCount + 1
            end
            
            if remote.InvokeServer then
                local oldInvoke = remote.InvokeServer
                
                remote.InvokeServer = function(self, ...)
                    task.wait(math.random(1, 15) / 1000)
                    
                    local remoteName = tostring(self):lower()
                    if remoteName:find("anti") or remoteName:find("detect") or remoteName:find("check") then
                        return
                    end
                    
                    return oldInvoke(self, ...)
                end
            end
        end)
    end
    
    for _, obj in ipairs(game:GetDescendants()) do
        hookRemote(obj)
    end
    
    game.DescendantAdded:Connect(function(obj)
        task.wait(0.05)
        hookRemote(obj)
    end)
    
    print("✓ Hooked " .. hookedCount .. " remotes")
end)

-- ═══════════════════════════════════════════════════════════
-- LEVEL 3: TELEMETRY BLOCKING (PASSIVE - NO DELAYS)
-- ═══════════════════════════════════════════════════════════

local telemetryHooked = false

pcall(function()
    if HttpService and HttpService.RequestAsync then
        local oldRequest = HttpService.RequestAsync
        
        HttpService.RequestAsync = function(self, options)
            if options and options.Url then
                local url = options.Url:lower()
                if url:find("telemetry") or url:find("analytics") or 
                   url:find("metrics") or url:find("report") or
                   url:find("logging") then
                    return {StatusCode = 200, Body = "{}"}
                end
            end
            return oldRequest(self, options)
        end
        
        telemetryHooked = true
    end
end)

if telemetryHooked then
    print("✓ Telemetry blocked")
else
    print("⚠️ Telemetry hook skipped")
end

-- ═══════════════════════════════════════════════════════════
-- LEVEL 4: BEHAVIORAL AI
-- ═══════════════════════════════════════════════════════════

local userId = player.UserId
math.randomseed(userId + tick())

local profile = {
    walkSpeed = 14 + math.random() * 4,
    walkVariance = 0.15 + (math.random() * 0.15),
    idleFrequency = 120 + math.random(180),
    wanderFrequency = 240 + math.random(240),
    signature = string.format("%x", userId % 0xFFFFFF)
}

print("✓ Profile: " .. profile.signature)

task.spawn(function()
    while true do
        pcall(function()
            local char = player.Character
            if char then
                local hum = char:FindFirstChild("Humanoid")
                if hum and hum.Health > 0 then
                    local variance = (math.random() - 0.5) * 2 * profile.walkVariance
                    hum.WalkSpeed = profile.walkSpeed + (profile.walkSpeed * variance)
                end
            end
        end)
        task.wait(2 + math.random() * 3)
    end
end)

print("✓ Walk randomizer active")

task.spawn(function()
    while true do
        pcall(function()
            local cam = workspace.CurrentCamera
            if cam and cam.CameraType == Enum.CameraType.Custom then
                local drift = (math.random() - 0.5) * 0.08
                cam.CFrame = cam.CFrame * CFrame.Angles(
                    math.rad(drift),
                    math.rad(drift * 1.2),
                    0
                )
            end
        end)
        task.wait(20 + math.random() * 40)
    end
end)

print("✓ Camera drift enabled")

task.spawn(function()
    while true do
        task.wait(profile.idleFrequency + math.random() * 60)
        task.wait(8 + math.random() * 22)
    end
end)

print("✓ Idle behavior running")

task.spawn(function()
    while true do
        task.wait(profile.wanderFrequency + math.random() * 120)
        pcall(function()
            local char = player.Character
            if char then
                local hum = char:FindFirstChild("Humanoid")
                local hrp = char:FindFirstChild("HumanoidRootPart")
                if hum and hrp and hum.Health > 0 then
                    local offset = Vector3.new(
                        math.random(-60, 60),
                        0,
                        math.random(-60, 60)
                    )
                    hum:MoveTo(hrp.Position + offset)
                    task.wait(4 + math.random() * 5)
                    hum:MoveTo(hrp.Position)
                end
            end
        end)
    end
end)

print("✓ Wander AI active")

-- ═══════════════════════════════════════════════════════════
-- LEVEL 5: HEARTBEAT RANDOMIZATION
-- ═══════════════════════════════════════════════════════════

local lastStutter = tick()

RunService.Heartbeat:Connect(function()
    local now = tick()
    if now - lastStutter > (6 + math.random() * 6) and math.random() > 0.5 then
        task.wait(math.random(3, 25) / 1000)
        lastStutter = now
    end
end)

print("✓ Heartbeat randomized")

-- ═══════════════════════════════════════════════════════════
-- LEVEL 6: SELECTIVE NETWORK FINGERPRINT
-- Only spoof non-critical requests, leave game API alone
-- ═══════════════════════════════════════════════════════════

local networkHooked = false

pcall(function()
    if request then
        local oldReq = request
        
        local agents = {
            "Roblox/WinInet",
            "Roblox/WinHttp",
            "Mozilla/5.0 (Windows NT 10.0; Win64; x64)",
            "Mozilla/5.0 (Windows NT 10.0; WOW64)",
            "RobloxStudio/WinHttp"
        }
        
        request = function(options)
            options = options or {}
            
            -- Whitelist critical game API endpoints
            local url = options.Url or ""
            local isCritical = url:find("roblox.com/v1/games") or 
                              url:find("roblox.com/v2/games") or
                              url:find("assetdelivery.roblox.com") or
                              url:find("discord.com/api/webhooks") -- Don't break webhooks
            
            -- Pass through critical requests untouched
            if isCritical then
                return oldReq(options)
            end
            
            -- Spoof everything else
            options.Headers = options.Headers or {}
            options.Headers["User-Agent"] = agents[(userId % #agents) + 1]
            options.Headers["X-Session-ID"] = profile.signature
            options.Headers["X-Client-Time"] = tostring(tick())
            
            return oldReq(options)
        end
        
        networkHooked = true
    end
end)

if networkHooked then
    print("✓ Network fingerprint faked (critical APIs whitelisted)")
else
    print("⚠️ Network hook skipped")
end

-- ═══════════════════════════════════════════════════════════
-- READY
-- ═══════════════════════════════════════════════════════════

task.wait(0.5)

print("")
print("════════════════════════════════════════")
print("🛡️ NUCLEAR PROTECTION ONLINE")
print("════════════════════════════════════════")
print("✓ Executor hidden")
print("⏳ Remotes hooking in 3s (delayed start)")
print(telemetryHooked and "✓ Telemetry blocked" or "⚠️ Telemetry N/A")
print("✓ 4 AI behaviors active")
print("✓ Heartbeat randomized")
print(networkHooked and "✓ Network spoofed (critical whitelisted)" or "⚠️ Network N/A")
print("")
print("🎯 BEE SWARM SIMULATOR MODE")
print("⚡ ALL SYSTEMS GO")
print("════════════════════════════════════════")
print("")
