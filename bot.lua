-- PHANTOM BEHAVIOR ENGINE v2.5 - Makes each bot move like a human
-- INJECT THIS FIRST, BEFORE YOUR VIC SCRIPT
-- It won't interfere - just runs in background adding human behaviors

local HttpService = game:GetService("HttpService")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

local player = Players.LocalPlayer
local char = player.Character or player.CharacterAdded:Wait()
local humanoid = char:WaitForChild("Humanoid")
local rootPart = char:WaitForChild("HumanoidRootPart")

-- Singleton check
if _G.PhantomEngineActive then
    warn("Phantom Engine already running!")
    return
end
_G.PhantomEngineActive = true

-- Generate unique personality based on username
local function generateProfile()
    if _G._PhantomProfile then return _G._PhantomProfile end
    
    local seed = 0
    for i = 1, #player.Name do
        seed = seed + string.byte(player.Name, i) * i
    end
    math.randomseed(seed)
    
    local profile = {
        baseWalkSpeed = math.random(14, 18),
        sprintChance = math.random(25, 75),
        lateralDrift = math.random(3, 12) / 100,
        reactionTimeMin = math.random(150, 350) / 1000,
        reactionTimeMax = math.random(400, 900) / 1000,
        pauseChance = math.random(2, 8),
        movementErrorRate = math.random(3, 12),
        jumpWhileMovingChance = math.random(5, 20),
        lookAroundFrequency = math.random(8, 25),
        cameraShakeIntensity = math.random(2, 8) / 100,
    }
    
    _G._PhantomProfile = profile
    math.randomseed(tick())
    
    print(string.format("🎭 Phantom Profile: Speed=%.1f, Drift=%.1f%%, Reaction=%.2f-%.2fs", 
        profile.baseWalkSpeed, profile.lateralDrift * 100, profile.reactionTimeMin, profile.reactionTimeMax))
    
    return profile
end

local profile = generateProfile()

-- Automatic camera drift (runs every frame)
local lastCameraShift = tick()
RunService.RenderStepped:Connect(function()
    if not _G.PhantomEngineActive then return end
    
    local camera = workspace.CurrentCamera
    if not camera or camera.CameraType ~= Enum.CameraType.Custom then return end
    
    local now = tick()
    if now - lastCameraShift < 0.5 or math.random(1, 100) > 30 then return end
    
    lastCameraShift = now
    local shakeX = (math.random() - 0.5) * profile.cameraShakeIntensity
    local shakeY = (math.random() - 0.5) * profile.cameraShakeIntensity
    camera.CFrame = camera.CFrame * CFrame.Angles(math.rad(shakeY * 10), math.rad(shakeX * 10), 0)
end)

-- Random looking around
task.spawn(function()
    while _G.PhantomEngineActive do
        task.wait(profile.lookAroundFrequency + math.random(-5, 5))
        if math.random(1, 100) <= 60 then
            local camera = workspace.CurrentCamera
            if camera and camera.CameraType == Enum.CameraType.Custom then
                local lookDirection = math.random(0, 360)
                local lookIntensity = math.random(15, 60)
                local targetRotation = CFrame.Angles(
                    math.rad(math.random(-15, 15)),
                    math.rad(math.cos(math.rad(lookDirection)) * lookIntensity),
                    0
                )
                local steps = math.random(8, 15)
                for i = 1, steps do
                    if camera and _G.PhantomEngineActive then
                        camera.CFrame = camera.CFrame:Lerp(camera.CFrame * targetRotation, 1 / steps)
                    end
                    task.wait(0.03)
                end
            end
        end
    end
end)

-- Idle fidgeting
task.spawn(function()
    while _G.PhantomEngineActive do
        task.wait(math.random(30, 90))
        if math.random(1, 100) <= 25 and rootPart then
            local fidgetDistance = math.random(2, 5)
            local fidgetAngle = math.random(0, 360)
            local fidgetTarget = rootPart.Position + Vector3.new(
                math.cos(math.rad(fidgetAngle)) * fidgetDistance,
                0,
                math.sin(math.rad(fidgetAngle)) * fidgetDistance
            )
            humanoid:MoveTo(fidgetTarget)
            task.wait(math.random(1, 3))
        end
    end
end)

-- Character respawn handler
player.CharacterAdded:Connect(function(newChar)
    char = newChar
    humanoid = newChar:WaitForChild("Humanoid")
    rootPart = newChar:WaitForChild("HumanoidRootPart")
    task.wait(1)
    humanoid.WalkSpeed = profile.baseWalkSpeed
    print("🔄 Phantom behaviors reattached")
end)

-- Set initial walk speed
humanoid.WalkSpeed = profile.baseWalkSpeed

print("✅ PHANTOM ENGINE ACTIVE - Human behaviors running in background")
print("✅ Your Vic script will work normally - this won't interfere!")
