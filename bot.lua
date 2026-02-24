-- SILENT LOCK PREVENTION v2.0
-- Runs in background, doesnt interfere with farming
-- No logouts, no active hour checks, just protection

local HttpService = game:GetService("HttpService")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local player = Players.LocalPlayer

print("=== SILENT PROTECTION LOADING ===")

-- Generate unique behavioral signature per account
local function generateProfile()
    local userId = player.UserId
    math.randomseed(userId + tick())
    
    local profile = {
        -- Speed modifiers (each bot moves/acts at different pace)
        speedMultiplier = 0.7 + (math.random() * 0.6),
        
        -- Delay patterns (random but consistent per account)
        baseDelay = 0.8 + (math.random() * 1.5),
        
        -- Network timing jitter
        requestJitter = math.random(1000, 4000),
        
        -- Unique ID
        signature = HttpService:GenerateGUID(false):sub(1, 8)
    }
    
    return profile
end

local myProfile = generateProfile()
getgenv().PROTECTION_PROFILE = myProfile

print("[PROTECT] Identity created: " .. myProfile.signature)
print("  Speed: " .. string.format("%.2f", myProfile.speedMultiplier) .. "x")
print("  Base delay: " .. string.format("%.2f", myProfile.baseDelay) .. "s")

-- SMART DELAY FUNCTION (use this instead of wait in Vic Bee)
function getgenv().ProtectedWait(seconds)
    local adjustedTime = (seconds or 1) * myProfile.baseDelay
    local jitter = (math.random(-200, 200) / 1000)
    task.wait(adjustedTime + jitter)
end

-- NETWORK REQUEST WRAPPER (makes webhooks look different)
if request or http_request then
    local oldRequest = request or http_request
    
    getgenv().ProtectedRequest = function(options)
        -- Add random delay before request
        task.wait(myProfile.requestJitter / 1000)
        
        -- Add unique headers per account
        options.Headers = options.Headers or {}
        options.Headers["X-Client-ID"] = myProfile.signature
        options.Headers["X-Session"] = tostring(tick())
        
        return oldRequest(options)
    end
    
    -- Override global request functions
    if request then request = getgenv().ProtectedRequest end
    if http_request then http_request = getgenv().ProtectedRequest end
end

-- SUBTLE CAMERA MOVEMENT (not aggressive like Phantom Engine)
local lastCameraUpdate = tick()
task.spawn(function()
    while task.wait(math.random(45, 90)) do
        if tick() - lastCameraUpdate < 30 then
            continue
        end
        
        lastCameraUpdate = tick()
        
        local camera = workspace.CurrentCamera
        if camera and camera.CameraType == Enum.CameraType.Custom then
            -- Tiny drift (barely noticeable)
            local drift = math.random(-1, 1) * 0.05
            camera.CFrame = camera.CFrame * CFrame.Angles(
                math.rad(drift),
                math.rad(drift * 2),
                0
            )
        end
    end
end)

-- MOVEMENT SPEED VARIATION (if Vic Bee moves character)
task.spawn(function()
    while task.wait(5) do
        local char = player.Character
        if char then
            local humanoid = char:FindFirstChild("Humanoid")
            if humanoid then
                -- Apply unique speed modifier
                local baseSpeed = 16
                humanoid.WalkSpeed = baseSpeed * myProfile.speedMultiplier
            end
        end
    end
end)

print("=== SILENT PROTECTION ACTIVE ===")
print("Running in background - will not interfere with farming")
print("Now inject your Vic Bee script")
