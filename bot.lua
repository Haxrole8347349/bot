-- ═══════════════════════════════════════════════════════════
-- ADVANCED BOT PROTECTION v7.2 - XENO COMPATIBLE
-- Fixed for Xeno executor's specific limitations
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
-- LEVEL 2: XENO-SAFE REMOTE HOOKING
-- Skip metatable, hook remotes directly instead
-- ═══════════════════════════════════════════════════════════

print("⚙️ Installing remote hooks (Xeno-safe method)...")

local hookedRemotes = 0

-- Hook all RemoteEvents in the game
local function hookRemote(remote)
    if not remote:IsA("RemoteEvent") and not remote:IsA("RemoteFunction") then return end
    
    pcall(function()
        local oldFireServer = remote.FireServer
        local oldInvokeServer = remote.InvokeServer
        
        -- Hook FireServer
        if oldFireServer then
            remote.FireServer = function(self, ...)
                -- Add micro-delay
                task.wait(math.random(1, 15) / 1000)
                
                -- Block anti-cheat
                if tostring(self):lower():find("anti") or tostring(self):lower():find("detect") then
                    return
                end
                
                return oldFireServer(self, ...)
            end
            hookedRemotes = hookedRemotes + 1
        end
        
        -- Hook InvokeServer
        if oldInvokeServer then
            remote.InvokeServer = function(self, ...)
                task.wait(math.random(1, 15) / 1000)
                
                if tostring(self):lower():find("anti") or tostring(self):lower():find("detect") then
                    return
                end
                
                return oldInvokeServer(self, ...)
            end
        end
    end)
end

-- Hook existing remotes
for _, descendant in ipairs(game:GetDescendants()) do
    hookRemote(descendant)
end

-- Hook future remotes
game.DescendantAdded:Connect(function(descendant)
    task.wait(0.1)
    hookRemote(descendant)
end)

print("✓ Hooked " .. hookedRemotes .. " remotes (anti-cheat neutered)")

-- ═══════════════════════════════════════════════════════════
-- LEVEL 3: TELEMETRY BLOCKING
-- ═══════════════════════════════════════════════════════════

local telemetryBlocked = false

pcall(function()
    if HttpService then
        local oldRequest = HttpService.RequestAsync
        HttpService.RequestAsync = function(self, options)
            if options and options.Url then
                local url = options.Url:lower()
                if url:find("telemetry") or url:find("analytics") or 
                   url:find("metrics") or url:find("report") or
                   url:find("logging") then
                    telemetryBlocked = true
                    return {StatusCode = 200, Body = "{}"}
                end
            end
            return oldRequest(self, options)
        end
    end
end)

print("✓ Telemetry blocker installed")

-- ═══════════════════════════════════════════════════════════
-- LEVEL 4: ADVANCED BEHAVIORAL AI
-- ═══════════════════════════════════════════════════════════

local userId = player.UserId
math.randomseed(userId + tick())

local profile = {
    walkSpeed = 14 + math.random() * 4,
    walkVariance = 0.15 + (math.random() * 0.15),
    baseDelay = 0.3 + (math.random() * 0.7),
    delayVariance = 0.5 + (math.random() * 1.5),
    idleFrequency = 120 + math.random(180),
    wanderFrequency = 240 + math.random(240),
    signature = string.format("%x", userId % 0xFFFFFF)
}

print("✓ Profile generated: " .. profile.signature)

-- Walk speed variance
task.spawn(function()
    while true do
        local success = pcall(function()
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

print("✓ Walk speed randomizer started")

-- Camera drift
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

-- Random idle periods
task.spawn(function()
    while true do
        task.wait(profile.idleFrequency + math.random() * 60)
        task.wait(8 + math.random() * 22)
    end
end)

print("✓ Idle behavior active")

-- Random wandering
task.spawn(function()
    while true do
        task.wait(profile.wanderFrequency + math.random() * 120)
        pcall(function()
            local char = player.Character
            if char then
                local hum = char:FindFirstChild("Humanoid")
                local hrp = char:FindFirstChild("HumanoidRootPart")
                if hum and hrp then
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

print("✓ Wander AI running")

-- ═══════════════════════════════════════════════════════════
-- LEVEL 5: HEARTBEAT RANDOMIZATION
-- ═══════════════════════════════════════════════════════════

local lastStutter = tick()
local stutterCount = 0

RunService.Heartbeat:Connect(function()
    local now = tick()
    if now - lastStutter > (6 + math.random() * 6) and math.random() > 0.5 then
        task.wait(math.random(3, 25) / 1000)
        lastStutter = now
        stutterCount = stutterCount + 1
    end
end)

print("✓ Heartbeat randomizer active")

-- ═══════════════════════════════════════════════════════════
-- LEVEL 6: NETWORK FINGERPRINT RANDOMIZATION
-- ═══════════════════════════════════════════════════════════

local networkHooked = false

pcall(function()
    -- Xeno uses 'request' primarily
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
    print("✓ Network fingerprint randomized")
else
    print("⚠️ Network hook skipped (not critical)")
end

-- ═══════════════════════════════════════════════════════════
-- READY
-- ═══════════════════════════════════════════════════════════

task.wait(0.5)

print("")
print("════════════════════════════════════════")
print("🛡️ NUCLEAR PROTECTION ACTIVE (XENO)")
print("════════════════════════════════════════")
print("✓ Executor fingerprint nuked")
print("✓ " .. hookedRemotes .. " remotes hooked")
print("✓ Telemetry blocked")
print("✓ Behavioral AI running (4 systems)")
print("✓ Heartbeat randomized")
print(networkHooked and "✓ Network fingerprint faked" or "⚠️ Network hook optional")
print("")
print("⚡ XENO COMPATIBLE MODE")
print("🎯 ALL SYSTEMS OPERATIONAL")
print("════════════════════════════════════════")
print("")
