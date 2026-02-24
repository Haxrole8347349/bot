-- ═══════════════════════════════════════════════════════════
-- STANDALONE BEHAVIORAL PROTECTION v4.0
-- Run this BEFORE your Vic Bee script
-- Makes you look human without touching Vic Bee code
-- ═══════════════════════════════════════════════════════════

local HttpService = game:GetService("HttpService")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local player = Players.LocalPlayer

print("🛡️ Standalone Protection Loading...")
print("⚠️ Make sure to inject Vic Bee AFTER this script!")

-- ═══════════════════════════════════════════════════════════
-- GENERATE UNIQUE BEHAVIORAL PROFILE
-- ═══════════════════════════════════════════════════════════

local function generateProfile()
    local userId = player.UserId
    math.randomseed(userId + tick())
    
    return {
        -- Timing patterns (each account different)
        reactionMin = 0.4 + (math.random() * 0.6),      -- 0.4-1.0s
        reactionMax = 1.5 + (math.random() * 2.0),      -- 1.5-3.5s
        
        -- Movement personality  
        walkSpeed = 14 + (math.random() * 4),           -- 14-18
        walkVariance = 0.1 + (math.random() * 0.15),    -- ±10-25%
        
        -- Activity rates
        idleChance = 0.12 + (math.random() * 0.20),     -- 12-32%
        wanderChance = 0.08 + (math.random() * 0.15),   -- 8-23%
        
        -- Network timing
        webhookDelayMin = 2.5 + (math.random() * 2.5),  -- 2.5-5s
        webhookDelayMax = 6 + (math.random() * 8),      -- 6-14s
        requestJitter = 1200 + math.random(2800),       -- 1.2-4s
        
        -- Session patterns
        breakEvery = (40 + math.random() * 35) * 60,    -- 40-75 min
        breakLength = (4 + math.random() * 8) * 60,     // 4-12 min
        
        -- Unique ID
        id = HttpService:GenerateGUID(false):sub(1, 8),
        
        -- State
        lastIdle = 0,
        lastWander = 0,
        sessionStart = tick(),
        lastBreak = 0,
        onBreak = false
    }
end

local PROFILE = generateProfile()

print(string.format("🎭 Profile: %s | React: %.1f-%.1fs | Walk: %.1f", 
    PROFILE.id, PROFILE.reactionMin, PROFILE.reactionMax, PROFILE.walkSpeed))

-- ═══════════════════════════════════════════════════════════
-- OVERRIDE REQUEST FUNCTIONS (BEFORE VIC BEE LOADS)
-- ═══════════════════════════════════════════════════════════

local _originalRequest = request or http_request or syn.request

local function ProtectedRequest(options)
    -- Realistic delay (humans don't send webhooks instantly)
    local delay = PROFILE.webhookDelayMin + (math.random() * (PROFILE.webhookDelayMax - PROFILE.webhookDelayMin))
    task.wait(delay)
    
    -- Network jitter
    task.wait(PROFILE.requestJitter / 1000)
    
    -- Add fingerprint headers
    options.Headers = options.Headers or {}
    options.Headers["X-Client-ID"] = PROFILE.id
    options.Headers["X-Session"] = tostring(math.floor(tick() - PROFILE.sessionStart))
    options.Headers["X-Timestamp"] = tostring(tick())
    
    -- Randomize user agent
    local agents = {
        "Roblox/WinInet",
        "Roblox/WinHttp",
        "Mozilla/5.0 (Windows NT 10.0; Win64; x64)",
        "RobloxStudio/WinHttp"
    }
    options.Headers["User-Agent"] = agents[math.random(1, #agents)]
    
    return _originalRequest(options)
end

-- Override ALL request functions globally
request = ProtectedRequest
http_request = ProtectedRequest
if syn and syn.request then syn.request = ProtectedRequest end

print("✅ Request functions overridden with protection")

-- ═══════════════════════════════════════════════════════════
-- REALISTIC WALK SPEED VARIATION
-- ═══════════════════════════════════════════════════════════

task.spawn(function()
    while task.wait(3 + math.random() * 4) do
        if PROFILE.onBreak then continue end
        
        local char = player.Character
        if char then
            local humanoid = char:FindFirstChild("Humanoid")
            if humanoid and humanoid.Health > 0 then
                -- Fluctuate speed (keyboard input variance)
                local variance = (math.random() - 0.5) * 2 * PROFILE.walkVariance
                local speed = PROFILE.walkSpeed + (PROFILE.walkSpeed * variance)
                humanoid.WalkSpeed = speed
            end
        end
    end
end)

-- ═══════════════════════════════════════════════════════════
-- HUMAN-LIKE BEHAVIORS (BACKGROUND LOOP)
-- ═══════════════════════════════════════════════════════════

local function idleBehavior()
    if tick() - PROFILE.lastIdle < 90 then return end
    PROFILE.lastIdle = tick()
    
    print("🧍 Idling for " .. math.floor(8 + math.random() * 18) .. "s")
    task.wait(8 + math.random() * 18)  -- Stand still 8-26s
end

local function wanderBehavior()
    if tick() - PROFILE.lastWander < 150 then return end
    PROFILE.lastWander = tick()
    
    local char = player.Character
    if not char then return end
    
    local humanoid = char:FindFirstChild("Humanoid")
    local hrp = char:FindFirstChild("HumanoidRootPart")
    if not humanoid or not hrp then return end
    
    print("🚶 Wandering randomly")
    
    -- Random nearby point
    local offset = Vector3.new(
        (math.random() - 0.5) * 80,
        0,
        (math.random() - 0.5) * 80
    )
    
    humanoid:MoveTo(hrp.Position + offset)
    
    -- Stop after a bit
    task.delay(4 + math.random() * 6, function()
        if humanoid then
            humanoid:MoveTo(hrp.Position)
        end
    end)
end

-- Background behavior loop
task.spawn(function()
    while task.wait(25 + math.random() * 50) do  -- Every 25-75s
        if PROFILE.onBreak then continue end
        
        local roll = math.random()
        
        if roll < PROFILE.idleChance then
            task.spawn(idleBehavior)
        elseif roll < PROFILE.idleChance + PROFILE.wanderChance then
            task.spawn(wanderBehavior)
        end
    end
end)

-- ═══════════════════════════════════════════════════════════
-- SESSION BREAK SYSTEM
-- ═══════════════════════════════════════════════════════════

task.spawn(function()
    while true do
        task.wait(60)  -- Check every minute
        
        local timeSinceBreak = tick() - PROFILE.lastBreak
        
        if not PROFILE.onBreak and timeSinceBreak > PROFILE.breakEvery then
            PROFILE.onBreak = true
            PROFILE.lastBreak = tick()
            
            local mins = math.floor(PROFILE.breakLength / 60)
            print(string.format("☕ BREAK TIME - %d minutes", mins))
            
            task.wait(PROFILE.breakLength)
            
            PROFILE.onBreak = false
            print("✅ Break over")
        end
    end
end)

-- ═══════════════════════════════════════════════════════════
-- SUBTLE CAMERA DRIFT
-- ═══════════════════════════════════════════════════════════

task.spawn(function()
    while task.wait(35 + math.random() * 55) do
        if PROFILE.onBreak then continue end
        
        local camera = workspace.CurrentCamera
        if camera and camera.CameraType == Enum.CameraType.Custom then
            local drift = (math.random() - 0.5) * 0.08
            camera.CFrame = camera.CFrame * CFrame.Angles(
                math.rad(drift),
                math.rad(drift * 1.3),
                0
            )
        end
    end
end)

-- ═══════════════════════════════════════════════════════════
-- READY
-- ═══════════════════════════════════════════════════════════

task.wait(2)  -- Give everything time to initialize

print("")
print("════════════════════════════════════════")
print("✅ PROTECTION ACTIVE")
print("════════════════════════════════════════")
print("✓ Request protection: ENABLED")
print("✓ Walk speed variance: ENABLED")
print("✓ Random idle/wander: ENABLED")
print("✓ Session breaks: ENABLED")
print("✓ Camera drift: ENABLED")
print("")
print("🎯 NOW INJECT YOUR VIC BEE SCRIPT")
print("════════════════════════════════════════")
print("")
