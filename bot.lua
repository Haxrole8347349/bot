-- ═══════════════════════════════════════════════════════════
-- ADVANCED BOT PROTECTION v7.0 - NUCLEAR OPTION
-- Hooks into game anti-cheat, blocks telemetry, hides executor
-- No mercy, no detection, no flags
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
        if getgenv()[name] then getgenv()[name] = nil end
        if _G[name] then _G[name] = nil end
    end)
end

-- Hide common executor detection methods
if getgenv().isexecutorclosure then
    local old = getgenv().isexecutorclosure
    getgenv().isexecutorclosure = function() return false end
end

if checkcaller then
    local old = checkcaller
    checkcaller = function() return true end -- Always claim we're Roblox
end

print("✓ Executor fingerprint nuked")

-- ═══════════════════════════════════════════════════════════
-- LEVEL 2: ANTI-CHEAT FUNCTION HOOKING
-- Neuter the game's detection methods
-- ═══════════════════════════════════════════════════════════

pcall(function()
    local mt = getrawmetatable(game)
    local oldIndex = mt.__index
    local oldNamecall = mt.__namecall
    
    setreadonly(mt, false)
    
    -- Hook __namecall to add variance to EVERYTHING
    mt.__namecall = newcclosure(function(self, ...)
        local method = getnamecallmethod()
        local args = {...}
        
        -- Add micro-delays to remote calls (undetectable, just breaks patterns)
        if method == "FireServer" or method == "InvokeServer" then
            wait(math.random(1, 15) / 1000) -- 0.001-0.015s
        end
        
        -- Block known anti-cheat remotes (BSS-specific)
        if method == "FireServer" and tostring(self):find("Anti") then
            return -- Silently drop anti-cheat reports
        end
        
        return oldNamecall(self, ...)
    end)
    
    -- Hook __index to hide suspicious properties
    mt.__index = newcclosure(function(self, key)
        -- If game tries to check for exploit properties, lie
        if key == "DevComputerMovementMode" or key == "DevTouchMovementMode" then
            return Enum.DevComputerMovementMode.UserChoice
        end
        
        return oldIndex(self, key)
    end)
    
    setreadonly(mt, true)
    print("✓ Anti-cheat hooks installed")
end)

-- ═══════════════════════════════════════════════════════════
-- LEVEL 3: TELEMETRY BLOCKING
-- Stop game from reporting suspicious activity
-- ═══════════════════════════════════════════════════════════

-- Hook HttpService to block telemetry endpoints
if HttpService then
    local oldRequest = HttpService.RequestAsync
    HttpService.RequestAsync = function(self, options)
        -- Block known Roblox telemetry endpoints
        if options.Url then
            local url = options.Url:lower()
            if url:find("telemetry") or url:find("analytics") or 
               url:find("metrics") or url:find("report") then
                return {StatusCode = 200, Body = "{}"}  -- Fake success
            end
        end
        return oldRequest(self, options)
    end
    print("✓ Telemetry blocked")
end

-- ═══════════════════════════════════════════════════════════
-- LEVEL 4: ADVANCED BEHAVIORAL AI
-- Each account acts like a different human
-- ═══════════════════════════════════════════════════════════

local userId = player.UserId
math.randomseed(userId + tick())

local profile = {
    -- Movement personality
    walkSpeed = 14 + math.random() * 4,
    walkVariance = 0.15 + (math.random() * 0.15),
    
    -- Action timing (each account different)
    baseDelay = 0.3 + (math.random() * 0.7),
    delayVariance = 0.5 + (math.random() * 1.5),
    
    -- Behavioral patterns
    idleFrequency = 120 + math.random(180), -- Idle every 2-5 min
    wanderFrequency = 240 + math.random(240), -- Wander every 4-8 min
    
    -- Unique fingerprint
    signature = string.format("%x", userId % 0xFFFFFF)
}

print("✓ Profile: " .. profile.signature)

-- Walk speed with realistic variance
spawn(function()
    while wait(2 + math.random() * 3) do
        local char = player.Character
        if char then
            local hum = char:FindFirstChild("Humanoid")
            if hum and hum.Health > 0 then
                local variance = (math.random() - 0.5) * 2 * profile.walkVariance
                hum.WalkSpeed = profile.walkSpeed + (profile.walkSpeed * variance)
            end
        end
    end
end)

-- Camera movement (not frozen like bot)
spawn(function()
    while wait(20 + math.random() * 40) do
        local cam = workspace.CurrentCamera
        if cam and cam.CameraType == Enum.CameraType.Custom then
            -- Realistic camera drift
            local drift = (math.random() - 0.5) * 0.08
            cam.CFrame = cam.CFrame * CFrame.Angles(
                math.rad(drift),
                math.rad(drift * 1.2),
                0
            )
        end
    end
end)

-- Random idle periods (like tabbing out)
spawn(function()
    while wait(profile.idleFrequency + math.random() * 60) do
        wait(8 + math.random() * 22) -- Idle 8-30s
    end
end)

-- Random wandering
spawn(function()
    while wait(profile.wanderFrequency + math.random() * 120) do
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
                wait(4 + math.random() * 5)
                hum:MoveTo(hrp.Position)
            end
        end
    end
end)

print("✓ Behavioral AI active")

-- ═══════════════════════════════════════════════════════════
-- LEVEL 5: HEARTBEAT RANDOMIZATION
-- Break perfect loop timing
-- ═══════════════════════════════════════════════════════════

local lastStutter = tick()
RunService.Heartbeat:Connect(function()
    local now = tick()
    if now - lastStutter > (6 + math.random() * 6) and math.random() > 0.5 then
        wait(math.random(3, 25) / 1000) -- 0.003-0.025s stutter
        lastStutter = now
    end
end)

print("✓ Heartbeat randomized")

-- ═══════════════════════════════════════════════════════════
-- LEVEL 6: NETWORK FINGERPRINT RANDOMIZATION
-- Make each account look different at network level
-- ═══════════════════════════════════════════════════════════

-- This doesn't delay webhooks, just adds fingerprint variance
if request or http_request then
    local oldReq = request or http_request
    
    local function fakeFingerprint(options)
        options.Headers = options.Headers or {}
        
        -- Randomize user agent per account
        local agents = {
            "Roblox/WinInet",
            "Roblox/WinHttp",
            "Mozilla/5.0 (Windows NT 10.0; Win64; x64)",
            "Mozilla/5.0 (Windows NT 10.0; WOW64)",
            "RobloxStudio/WinHttp"
        }
        options.Headers["User-Agent"] = agents[(userId % #agents) + 1]
        
        -- Add "realistic" client fingerprints
        options.Headers["X-Session-ID"] = profile.signature
        options.Headers["X-Client-Time"] = tostring(tick())
        
        return oldReq(options)
    end
    
    request = fakeFingerprint
    http_request = fakeFingerprint
    print("✓ Network fingerprint randomized")
end

-- ═══════════════════════════════════════════════════════════
-- READY
-- ═══════════════════════════════════════════════════════════

wait(1)

print("")
print("════════════════════════════════════════")
print("🛡️ NUCLEAR PROTECTION ACTIVE")
print("════════════════════════════════════════")
print("✓ Executor hidden")
print("✓ Anti-cheat neutered")
print("✓ Telemetry blocked")
print("✓ Behavioral AI running")
print("✓ Heartbeat randomized")
print("✓ Network fingerprint faked")
print("")
print("⚡ NO WEBHOOK DELAYS")
print("🎯 UNDETECTABLE MODE")
print("════════════════════════════════════════")
print("")
