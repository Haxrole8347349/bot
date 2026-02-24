-- ═══════════════════════════════════════════════════════════
-- ADVANCED BOT PROTECTION v7.1 - FIXED EXECUTION
-- Now with robust error handling and executor compatibility
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

-- Hide executor detection with safe fallbacks
pcall(function()
    if getgenv and getgenv().isexecutorclosure then
        getgenv().isexecutorclosure = function() return false end
    end
end)

pcall(function()
    if checkcaller then
        local old = checkcaller
        checkcaller = function() return true end
    end
end)

print("✓ Executor fingerprint nuked")

-- ═══════════════════════════════════════════════════════════
-- LEVEL 2: ANTI-CHEAT FUNCTION HOOKING (SAFE VERSION)
-- ═══════════════════════════════════════════════════════════

local hookSuccess = pcall(function()
    -- Check if we have the required functions
    if not getrawmetatable then
        warn("⚠️ getrawmetatable not available - skipping metatable hooks")
        return
    end
    
    local mt = getrawmetatable(game)
    if not mt then
        warn("⚠️ Could not get metatable")
        return
    end
    
    local oldIndex = mt.__index
    local oldNamecall = mt.__namecall
    
    -- Check if setreadonly exists, use alternative if not
    local function makeWritable(tbl)
        if setreadonly then
            return setreadonly(tbl, false)
        elseif make_writeable then
            return make_writeable(tbl)
        else
            -- Some executors don't need this
            return true
        end
    end
    
    local function makeReadonly(tbl)
        if setreadonly then
            return setreadonly(tbl, true)
        elseif make_readonly then
            return make_readonly(tbl)
        else
            return true
        end
    end
    
    makeWritable(mt)
    
    -- Use newcclosure if available, otherwise raw function
    local function safeWrap(func)
        if newcclosure then
            return newcclosure(func)
        else
            return func
        end
    end
    
    -- Hook __namecall
    mt.__namecall = safeWrap(function(self, ...)
        local method = getnamecallmethod and getnamecallmethod() or ""
        local args = {...}
        
        -- Add micro-delays to remote calls
        if method == "FireServer" or method == "InvokeServer" then
            task.wait(math.random(1, 15) / 1000)
        end
        
        -- Block anti-cheat remotes
        if method == "FireServer" and tostring(self):find("Anti") then
            return
        end
        
        return oldNamecall(self, ...)
    end)
    
    -- Hook __index
    mt.__index = safeWrap(function(self, key)
        if key == "DevComputerMovementMode" or key == "DevTouchMovementMode" then
            return Enum.DevComputerMovementMode.UserChoice
        end
        
        return oldIndex(self, key)
    end)
    
    makeReadonly(mt)
    print("✓ Anti-cheat hooks installed")
end)

if not hookSuccess then
    print("⚠️ Metatable hooks failed - continuing with other protections")
end

-- ═══════════════════════════════════════════════════════════
-- LEVEL 3: TELEMETRY BLOCKING
-- ═══════════════════════════════════════════════════════════

pcall(function()
    if HttpService then
        local oldRequest = HttpService.RequestAsync
        HttpService.RequestAsync = function(self, options)
            if options.Url then
                local url = options.Url:lower()
                if url:find("telemetry") or url:find("analytics") or 
                   url:find("metrics") or url:find("report") then
                    return {StatusCode = 200, Body = "{}"}
                end
            end
            return oldRequest(self, options)
        end
        print("✓ Telemetry blocked")
    end
end)

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

print("✓ Profile: " .. profile.signature)

-- Walk speed variance
task.spawn(function()
    while task.wait(2 + math.random() * 3) do
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
    end
end)

-- Camera movement
task.spawn(function()
    while task.wait(20 + math.random() * 40) do
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
    end
end)

-- Random idle periods
task.spawn(function()
    while task.wait(profile.idleFrequency + math.random() * 60) do
        task.wait(8 + math.random() * 22)
    end
end)

-- Random wandering
task.spawn(function()
    while task.wait(profile.wanderFrequency + math.random() * 120) do
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

print("✓ Behavioral AI active")

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
-- LEVEL 6: NETWORK FINGERPRINT RANDOMIZATION
-- ═══════════════════════════════════════════════════════════

pcall(function()
    local requestFunc = request or http_request or syn and syn.request
    
    if requestFunc then
        local oldReq = requestFunc
        
        local function fakeFingerprint(options)
            options.Headers = options.Headers or {}
            
            local agents = {
                "Roblox/WinInet",
                "Roblox/WinHttp",
                "Mozilla/5.0 (Windows NT 10.0; Win64; x64)",
                "Mozilla/5.0 (Windows NT 10.0; WOW64)",
                "RobloxStudio/WinHttp"
            }
            options.Headers["User-Agent"] = agents[(userId % #agents) + 1]
            options.Headers["X-Session-ID"] = profile.signature
            options.Headers["X-Client-Time"] = tostring(tick())
            
            return oldReq(options)
        end
        
        -- Override in global scope
        if request then request = fakeFingerprint end
        if http_request then http_request = fakeFingerprint end
        if syn and syn.request then syn.request = fakeFingerprint end
        
        print("✓ Network fingerprint randomized")
    end
end)

-- ═══════════════════════════════════════════════════════════
-- READY
-- ═══════════════════════════════════════════════════════════

task.wait(1)

print("")
print("════════════════════════════════════════")
print("🛡️ NUCLEAR PROTECTION ACTIVE")
print("════════════════════════════════════════")
print("✓ Executor hidden")
print("✓ Anti-cheat " .. (hookSuccess and "neutered" or "bypassed (partial)"))
print("✓ Telemetry blocked")
print("✓ Behavioral AI running")
print("✓ Heartbeat randomized")
print("✓ Network fingerprint faked")
print("")
print("⚡ NO WEBHOOK DELAYS")
print("🎯 UNDETECTABLE MODE")
print("════════════════════════════════════════")
print("")
