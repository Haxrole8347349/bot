-- PHANTOM BEHAVIOR ENGINE v2.6 - Subtle human behaviors
-- INJECT THIS FIRST, BEFORE YOUR VIC SCRIPT
-- Won't pull bots from spawn, just adds micro-movements

-- Auto-clear previous instances (no more re-injection issues)
_G.PhantomEngineActive = nil
_G._PhantomProfile = nil

warn("=== PHANTOM ENGINE v2.6 STARTING ===")

local HttpService = game:GetService("HttpService")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

warn("[1/6] Services loaded")

local player = Players.LocalPlayer
warn("[2/6] Player: " .. player.Name)

local char = player.Character
if not char then
    warn("[3/6] Waiting for character...")
    char = player.CharacterAdded:Wait()
else
    warn("[3/6] Character already loaded")
end

local humanoid = char:WaitForChild("Humanoid", 10)
local rootPart = char:WaitForChild("HumanoidRootPart", 10)

if not humanoid or not rootPart then
    warn("[ERROR] Failed to find Humanoid or RootPart!")
    return
end

warn("[4/6] Character components found")

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
        baseWalkSpeed = math.random(14, 17),
        lateralDrift = math.random(1, 4) / 100,  -- Reduced drift
        reactionTimeMin = math.random(200, 400) / 1000,
        reactionTimeMax = math.random(500, 1000) / 1000,
        cameraShakeIntensity = math.random(1, 3) / 100,  -- Reduced shake
        lookAroundFrequency = math.random(20, 45),  -- Less frequent
        fidgetDistance = math.random(5, 15) / 10,  -- 0.5-1.5 studs only!
        fidgetChance = 15,  -- Lower chance
    }
    
    _G._PhantomProfile = profile
    math.randomseed(tick())
    
    warn(string.format("[5/6] Profile: Speed=%.1f, Drift=%.1f%%, Fidget=%.1f studs", 
        profile.baseWalkSpeed, profile.lateralDrift * 100, profile.fidgetDistance))
    
    return profile
end

local profile = generateProfile()

-- Subtle camera drift (runs every frame)
local lastCameraShift = tick()
RunService.RenderStepped:Connect(function()
    if not _G.PhantomEngineActive then return end
    
    local camera = workspace.CurrentCamera
    if not camera or camera.CameraType ~= Enum.CameraType.Custom then return end
    
    local now = tick()
    if now - lastCameraShift < 1 or math.random(1, 100) > 20 then return end  -- Less frequent
    
    lastCameraShift = now
    local shakeX = (math.random() - 0.5) * profile.cameraShakeIntensity
    local shakeY = (math.random() - 0.5) * profile.cameraShakeIntensity
    camera.CFrame = camera.CFrame * CFrame.Angles(math.rad(shakeY * 5), math.rad(shakeX * 5), 0)
end)

-- Minimal looking around (subtle head turns)
task.spawn(function()
    while _G.PhantomEngineActive do
        task.wait(profile.lookAroundFrequency + math.random(-10, 10))
        if math.random(1, 100) <= 40 then  -- Lower chance
            local camera = workspace.CurrentCamera
            if camera and camera.CameraType == Enum.CameraType.Custom then
                local lookDirection = math.random(0, 360)
                local lookIntensity = math.random(10, 30)  -- Reduced intensity
                local targetRotation = CFrame.Angles(
                    math.rad(math.random(-8, 8)),  -- Less vertical movement
                    math.rad(math.cos(math.rad(lookDirection)) * lookIntensity),
                    0
                )
                local steps = math.random(12, 20)  -- Smoother
                for i = 1, steps do
                    if camera and _G.PhantomEngineActive then
                        camera.CFrame = camera.CFrame:Lerp(camera.CFrame * targetRotation, 1 / steps)
                    end
                    task.wait(0.04)
                end
            end
        end
    end
end)

-- MINIMAL idle fidgeting (stays near spawn!)
task.spawn(function()
    while _G.PhantomEngineActive do
        task.wait(math.random(45, 120))  -- Way less frequent (45-120 sec)
        if math.random(1, 100) <= profile.fidgetChance and rootPart then
            local fidgetAngle = math.random(0, 360)
            local fidgetTarget = rootPart.Position + Vector3.new(
                math.cos(math.rad(fidgetAngle)) * profile.fidgetDistance,  -- 0.5-1.5 studs max
                0,
                math.sin(math.rad(fidgetAngle)) * profile.fidgetDistance
            )
            humanoid:MoveTo(fidgetTarget)
            task.wait(math.random(0.5, 1.5))  -- Quick fidget
            humanoid:MoveTo(rootPart.Position)  -- Return to center
        end
    end
end)

-- Character respawn handler
player.CharacterAdded:Connect(function(newChar)
    char = newChar
    humanoid = newChar:WaitForChild("Humanoid", 10)
    rootPart = newChar:WaitForChild("HumanoidRootPart", 10)
    
    if humanoid and rootPart then
        task.wait(1)
        humanoid.WalkSpeed = profile.baseWalkSpeed
        warn("[RESPAWN] Phantom behaviors reattached")
    end
end)

-- Set initial walk speed
humanoid.WalkSpeed = profile.baseWalkSpeed

warn("[6/6] PHANTOM ENGINE ACTIVE ✓")
warn(">>> Subtle human behaviors running (minimal movement)")
warn(">>> Your Vic script will work normally!")
warn("===========================================")
