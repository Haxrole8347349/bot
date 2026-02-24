-- STANDALONE PROTECTION v4.0 - CLEAN VERSION
-- Run this FIRST, then Vic Bee after

local HttpService = game:GetService("HttpService")
local Players = game:GetService("Players")
local player = Players.LocalPlayer

print("Protection loading...")

-- Generate unique profile per account
local function makeProfile()
    local userId = player.UserId
    math.randomseed(userId + tick())
    
    -- Fallback ID generation (some executors don't have GenerateGUID)
    local id = ""
    for i = 1, 8 do
        id = id .. string.char(97 + math.random(0, 25))
    end
    
    return {
        reactionMin = 0.4 + (math.random() * 0.6),
        reactionMax = 1.5 + (math.random() * 2.0),
        walkSpeed = 14 + (math.random() * 4),
        walkVariance = 0.1 + (math.random() * 0.15),
        idleChance = 0.12 + (math.random() * 0.20),
        wanderChance = 0.08 + (math.random() * 0.15),
        webhookDelayMin = 2.5 + (math.random() * 2.5),
        webhookDelayMax = 6 + (math.random() * 8),
        requestJitter = 1200 + math.random(2800),
        breakEvery = (40 + math.random() * 35) * 60,
        breakLength = (4 + math.random() * 8) * 60,
        id = id,
        lastIdle = 0,
        lastWander = 0,
        sessionStart = tick(),
        lastBreak = 0,
        onBreak = false
    }
end

local PROFILE = makeProfile()
print("Profile created: " .. PROFILE.id)

-- Override request functions BEFORE Vic Bee loads
local originalRequest = request or http_request or (syn and syn.request)

if not originalRequest then
    warn("No request function found - webhook protection disabled")
else
    local function protectedRequest(options)
        local delay = PROFILE.webhookDelayMin + (math.random() * (PROFILE.webhookDelayMax - PROFILE.webhookDelayMin))
        task.wait(delay)
        task.wait(PROFILE.requestJitter / 1000)
        
        options.Headers = options.Headers or {}
        options.Headers["X-Client-ID"] = PROFILE.id
        options.Headers["X-Session"] = tostring(math.floor(tick() - PROFILE.sessionStart))
        
        return originalRequest(options)
    end
    
    request = protectedRequest
    http_request = protectedRequest
    if syn and syn.request then syn.request = protectedRequest end
    
    print("Request protection enabled")
end

-- Walk speed variation
task.spawn(function()
    while task.wait(3 + math.random() * 4) do
        if PROFILE.onBreak then continue end
        
        local char = player.Character
        if char then
            local humanoid = char:FindFirstChild("Humanoid")
            if humanoid and humanoid.Health > 0 then
                local variance = (math.random() - 0.5) * 2 * PROFILE.walkVariance
                local speed = PROFILE.walkSpeed + (PROFILE.walkSpeed * variance)
                humanoid.WalkSpeed = speed
            end
        end
    end
end)

-- Idle behavior
local function doIdle()
    if tick() - PROFILE.lastIdle < 90 then return end
    PROFILE.lastIdle = tick()
    task.wait(8 + math.random() * 18)
end

-- Wander behavior
local function doWander()
    if tick() - PROFILE.lastWander < 150 then return end
    PROFILE.lastWander = tick()
    
    local char = player.Character
    if not char then return end
    
    local humanoid = char:FindFirstChild("Humanoid")
    local hrp = char:FindFirstChild("HumanoidRootPart")
    if not humanoid or not hrp then return end
    
    local offset = Vector3.new(
        (math.random() - 0.5) * 80,
        0,
        (math.random() - 0.5) * 80
    )
    
    humanoid:MoveTo(hrp.Position + offset)
    
    task.delay(4 + math.random() * 6, function()
        if humanoid then humanoid:MoveTo(hrp.Position) end
    end)
end

-- Random behavior loop
task.spawn(function()
    while task.wait(25 + math.random() * 50) do
        if PROFILE.onBreak then continue end
        
        local roll = math.random()
        if roll < PROFILE.idleChance then
            task.spawn(doIdle)
        elseif roll < PROFILE.idleChance + PROFILE.wanderChance then
            task.spawn(doWander)
        end
    end
end)

-- Break system
task.spawn(function()
    while true do
        task.wait(60)
        local timeSinceBreak = tick() - PROFILE.lastBreak
        
        if not PROFILE.onBreak and timeSinceBreak > PROFILE.breakEvery then
            PROFILE.onBreak = true
            PROFILE.lastBreak = tick()
            print("Taking break for " .. math.floor(PROFILE.breakLength / 60) .. " minutes")
            task.wait(PROFILE.breakLength)
            PROFILE.onBreak = false
            print("Break over")
        end
    end
end)

-- Camera drift
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

task.wait(2)

print("================================")
print("PROTECTION ACTIVE")
print("Now inject Vic Bee script")
print("================================")
