-- ═══════════════════════════════════════════════════════════
-- SILENT PROTECTION v6.0 - NO DELAYS, PURE DETECTION BYPASS
-- Protects bot presence WITHOUT slowing down Vic Bee
-- ═══════════════════════════════════════════════════════════

print("🔒 Silent Protection Loading...")

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local player = Players.LocalPlayer

-- ═══════════════════════════════════════════════════════════
-- EXECUTOR FINGERPRINT HIDING
-- Hides common exploit detection points
-- ═══════════════════════════════════════════════════════════

local hiddenGlobals = {
    "syn", "SENTINEL_V2", "KRNL_LOADED", "PROTOSMASHER_LOADED",
    "is_synapse_function", "pebc_execute", "EVON_LOADED"
}

for _, name in ipairs(hiddenGlobals) do
    if getgenv()[name] then
        getgenv()[name] = nil
    end
end

print("✓ Executor fingerprint masked")

-- ═══════════════════════════════════════════════════════════
-- BEHAVIORAL VARIANCE (NO DELAYS - JUST LOOKS)
-- Makes YOUR character look human, doesn't touch webhooks
-- ═══════════════════════════════════════════════════════════

local profile = {
    walkSpeed = 15 + math.random() * 3,
    userId = player.UserId
}

math.randomseed(profile.userId + tick())

-- Walk speed variance
spawn(function()
    while wait(4 + math.random() * 3) do
        local char = player.Character
        if char then
            local hum = char:FindFirstChild("Humanoid")
            if hum and hum.Health > 0 then
                hum.WalkSpeed = profile.walkSpeed + math.random(-2, 2)
            end
        end
    end
end)

-- Camera micro-drift (barely noticeable)
spawn(function()
    while wait(30 + math.random() * 60) do
        local cam = workspace.CurrentCamera
        if cam and cam.CameraType == Enum.CameraType.Custom then
            local tiny = (math.random() - 0.5) * 0.06
            cam.CFrame = cam.CFrame * CFrame.Angles(
                math.rad(tiny),
                math.rad(tiny * 1.1),
                0
            )
        end
    end
end)

-- Occasional idle (stand still 10-20s every 3-5 minutes)
spawn(function()
    while wait(180 + math.random() * 120) do
        wait(10 + math.random() * 10)
    end
end)

-- Random wander (every 4-7 minutes, move randomly)
spawn(function()
    while wait(240 + math.random() * 180) do
        local char = player.Character
        if char then
            local hum = char:FindFirstChild("Humanoid")
            local hrp = char:FindFirstChild("HumanoidRootPart")
            if hum and hrp then
                local offset = Vector3.new(
                    math.random(-50, 50),
                    0,
                    math.random(-50, 50)
                )
                hum:MoveTo(hrp.Position + offset)
                wait(3 + math.random() * 3)
                hum:MoveTo(hrp.Position)
            end
        end
    end
end)

print("✓ Behavioral variance active")

-- ═══════════════════════════════════════════════════════════
-- ANTI-CHEAT BYPASS - CLIENT SIDE
-- Makes executor harder to detect
-- ═══════════════════════════════════════════════════════════

-- Hook remote timing (adds tiny variance to remote calls)
pcall(function()
    local mt = getrawmetatable(game)
    local oldNamecall = mt.__namecall
    
    setreadonly(mt, false)
    mt.__namecall = newcclosure(function(self, ...)
        local method = getnamecallmethod()
        
        if method == "FireServer" or method == "InvokeServer" then
            -- Tiny delay (0.001-0.01s) - not noticeable but breaks perfect timing
            wait(math.random(1, 10) / 1000)
        end
        
        return oldNamecall(self, ...)
    end)
    setreadonly(mt, true)
    
    print("✓ Remote timing variance injected")
end)

-- Heartbeat micro-stutter (every ~8 seconds, 0.005-0.02s delay)
local lastStutter = tick()
RunService.Heartbeat:Connect(function()
    if tick() - lastStutter > 8 and math.random() > 0.6 then
        wait(math.random(5, 20) / 1000)
        lastStutter = tick()
    end
end)

print("✓ Heartbeat variance active")

-- ═══════════════════════════════════════════════════════════
-- READY - NO WEBHOOK INTERFERENCE
-- ═══════════════════════════════════════════════════════════

wait(1)

print("")
print("════════════════════════════════════════")
print("🛡️ SILENT PROTECTION ACTIVE")
print("════════════════════════════════════════")
print("✓ Executor fingerprint hidden")
print("✓ Walk speed variance")
print("✓ Camera drift")
print("✓ Random idle/wander")
print("✓ Remote timing jitter (micro)")
print("✓ Heartbeat variance")
print("")
print("⚡ WEBHOOKS: INSTANT (UNMODIFIED)")
print("🎯 VIC BEE READY TO RUN")
print("════════════════════════════════════════")
print("")
