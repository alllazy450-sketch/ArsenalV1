-- ============================================================
--  W424HUB v5.3 – AIM & PREDICT TAB (Reduce Map Fixed)
--  Mobile Friendly | Accurate Prediction | Headshot Only
-- ============================================================
print("=== LOADING W424HUB v5.3 (Reduce Map Fixed) ===")

-- ============================================================
--  LOAD UI LIBRARY
-- ============================================================
local Kairo = loadstring(game:HttpGet("https://raw.githubusercontent.com/Itzzavi335/Kairo-Ui-Library/refs/heads/main/source.luau"))()
if not Kairo then return warn("Kairo failed") end

-- ============================================================
--  SERVICES
-- ============================================================
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local camera = workspace.CurrentCamera
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local CoreGui = game:GetService("CoreGui")
local StarterGui = game:GetService("StarterGui")
local Workspace = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local VirtualInputManager = game:GetService("VirtualInputManager")

-- ============================================================
--  WINDOW
-- ============================================================
local Window = Kairo:CreateWindow({
    Title = "W424HUB v5.3",
    Theme = "Ocean",
    Size = UDim2.fromOffset(480, 450),
    Center = true,
    Draggable = true,
    Resize = false,
    Badges = {"Aim+Pred", "v5.3"},
    MinimizeKey = Enum.KeyCode.RightShift,
    MinimizeButton = true,
    Config = { Enabled = true, Folder = "W424HUB_v5_Config", AutoLoad = true }
})
if not Window then return end

Window:Notify({Title="W424HUB v5.3", Description="Reduce Map fixed!", Color=Color3.fromRGB(0,200,50), Delay=3})

-- ============================================================
--  GLOBAL VARIABLES
-- ============================================================
local Features = {
    noRecoil = false,
    noSpread = false,
    antiRagdoll = false,
    antiAFK = false,
    infiniteAmmo = false,
    fastFire = false,
    fastReload = false,
    arsenalNoRecoil = false,
    arsenalNoSpread = false,

    aimbotEnabled = false,
    aimTrigger = "On Shoot",
    targetPart = "Head",
    headshotOnly = false,
    aimSmoothness = 0.3,
    useTeamCheck = true,
    fovRadius = 150,
    maxAimDistance = 400,
    useVisibilityCheck = true,
    hitboxExpansion = 0,
    targetPriority = "FOV",

    usePrediction = true,
    predictionFactor = 0.3,
    bulletSpeed = 800,

    silentAimEnabled = false,
    silentAimFOV = 200,
    silentAimDistance = 400,
    silentAimTargetPart = "Head",
    silentAimWallbang = true,
    silentAimTeamCheck = true,
    silentAimPrediction = true,
    silentAimPredFactor = 0.3,

    triggerbotEnabled = false,
    triggerDelay = 0.08,
    triggerFOV = 35,
    triggerHeadshotOnly = false,
    aggressiveMode = false,
    burstShots = 3,
    burstDelay = 0.03,
    triggerMethod = "Remote",
    triggerDebug = false,

    wallbangEnabled = false,

    espEnabled = false,
    espColor = Color3.fromRGB(255, 0, 0),
    espTeamCheck = true,
    espTransparency = 0.3,

    fovValue = 70,
    statsEnabled = false,
    reduceMap = false,
}

-- ============================================================
--  REDUCE MAP – IMPROVED (deteksi minimap secara agresif)
-- ============================================================
local foundMinimap = nil
local minimapWatchConnections = {}

local function findMinimap()
    -- Cari di CoreGui
    for _, gui in ipairs(CoreGui:GetChildren()) do
        if gui:IsA("ScreenGui") then
            local name = gui.Name:lower()
            if name:find("minimap") or name:find("map") or name:find("hud") then
                -- Cek apakah ada ViewportFrame (tanda minimap)
                local vp = gui:FindFirstChildWhichIsA("ViewportFrame")
                if vp then return gui end
                for _, child in ipairs(gui:GetDescendants()) do
                    if child:IsA("ViewportFrame") then return gui end
                end
            end
        end
    end
    
    -- Cari di PlayerGui
    local playerGui = LocalPlayer:FindFirstChild("PlayerGui")
    if playerGui then
        for _, gui in ipairs(playerGui:GetChildren()) do
            if gui:IsA("ScreenGui") then
                local name = gui.Name:lower()
                if name:find("minimap") or name:find("map") or name:find("hud") then
                    local vp = gui:FindFirstChildWhichIsA("ViewportFrame")
                    if vp then return gui end
                    for _, child in ipairs(gui:GetDescendants()) do
                        if child:IsA("ViewportFrame") then return gui end
                    end
                end
            end
        end
    end
    return nil
end

local function applyReduceMap(shouldHide)
    -- Metode 1: SetCore (standar)
    pcall(function() StarterGui:SetCore("MinimapEnabled", not shouldHide) end)
    
    -- Metode 2: Cari GUI minimap dan sembunyikan
    if not foundMinimap then
        foundMinimap = findMinimap()
    end
    
    if foundMinimap then
        if shouldHide then
            if not foundMinimap:GetAttribute("OriginalSize") then
                foundMinimap:SetAttribute("OriginalSize", foundMinimap.Size)
            end
            foundMinimap.Visible = false
            foundMinimap.Size = UDim2.new(0,0,0,0)
        else
            foundMinimap.Visible = true
            local orig = foundMinimap:GetAttribute("OriginalSize")
            if orig then
                foundMinimap.Size = orig
            else
                foundMinimap.Size = UDim2.new(1,0,1,0)
            end
        end
    end
end

-- Listener untuk minimap yang muncul belakangan
local function watchForMinimap()
    -- CoreGui
    local conn1 = CoreGui.ChildAdded:Connect(function(child)
        if child:IsA("ScreenGui") then
            task.wait(0.5)
            local name = child.Name:lower()
            if name:find("minimap") or name:find("map") or name:find("hud") then
                local vp = child:FindFirstChildWhichIsA("ViewportFrame")
                if vp then
                    foundMinimap = child
                    if Features.reduceMap then
                        applyReduceMap(true)
                    end
                end
            end
        end
    end)
    table.insert(minimapWatchConnections, conn1)
    
    -- PlayerGui
    local playerGui = LocalPlayer:FindFirstChild("PlayerGui")
    if playerGui then
        local conn2 = playerGui.ChildAdded:Connect(function(child)
            if child:IsA("ScreenGui") then
                task.wait(0.5)
                local name = child.Name:lower()
                if name:find("minimap") or name:find("map") or name:find("hud") then
                    local vp = child:FindFirstChildWhichIsA("ViewportFrame")
                    if vp then
                        foundMinimap = child
                        if Features.reduceMap then
                            applyReduceMap(true)
                        end
                    end
                end
            end
        end)
        table.insert(minimapWatchConnections, conn2)
    end
end

-- Jalankan watch
watchForMinimap()

-- ============================================================
--  HELPER FUNCTIONS
-- ============================================================
local function isAlive(character)
    if not character then return false end
    local hum = character:FindFirstChildOfClass("Humanoid")
    return hum and hum.Health > 0
end

local function getPart(character, partName, headshotOnly)
    if headshotOnly then
        return character:FindFirstChild("Head") or character:FindFirstChild("head")
    end
    local part = character:FindFirstChild(partName)
    if not part then
        part = character:FindFirstChild("Head") or character:FindFirstChild("HumanoidRootPart") or character:FindFirstChild("UpperTorso") or character:FindFirstChild("Torso")
    end
    return part
end

local function isVisible(origin, targetPos, ignoreList)
    if not Features.useVisibilityCheck then return true end
    local params = RaycastParams.new()
    params.FilterType = Enum.RaycastFilterType.Exclude
    params.FilterDescendantsInstances = ignoreList or {LocalPlayer.Character}
    params.IgnoreWater = true
    local result = workspace:Raycast(origin, (targetPos - origin), params)
    if result then
        local hitChar = result.Instance:FindFirstAncestorOfClass("Model")
        if hitChar then
            return Players:GetPlayerFromCharacter(hitChar) ~= nil
        end
        return false
    end
    return true
end

-- ============================================================
--  AIMBOT CORE
-- ============================================================
local function getTargets()
    local targets = {}
    local myChar = LocalPlayer.Character
    if not myChar then return targets end
    local myRoot = myChar:FindFirstChild("HumanoidRootPart")
    if not myRoot then return targets end
    local myPos = myRoot.Position
    local myTeam = LocalPlayer.Team

    for _, player in ipairs(Players:GetPlayers()) do
        if player == LocalPlayer then continue end
        local char = player.Character
        if not char then continue end
        if not isAlive(char) then continue end

        if Features.useTeamCheck and myTeam and player.Team == myTeam then
            continue
        end

        local part = getPart(char, Features.targetPart, Features.headshotOnly)
        if not part then continue end

        local targetPos = part.Position
        local dist = (targetPos - myPos).Magnitude
        if dist > Features.maxAimDistance then continue end

        if Features.hitboxExpansion > 0 and part.Name == "Head" then
            targetPos = targetPos + (part.CFrame.UpVector * Features.hitboxExpansion * 0.15)
        end

        local screenPos, onScreen = camera:WorldToViewportPoint(targetPos)
        if not onScreen then continue end
        local center = camera.ViewportSize / 2
        local screenDist = (Vector2.new(screenPos.X, screenPos.Y) - center).Magnitude
        if screenDist > Features.fovRadius then continue end

        local predictedPos = targetPos
        if Features.usePrediction then
            local hrp = char:FindFirstChild("HumanoidRootPart")
            if hrp then
                local vel = hrp.Velocity or Vector3.new()
                local travelTime = dist / Features.bulletSpeed
                local predFactor = Features.predictionFactor * travelTime
                predictedPos = targetPos + vel * predFactor
            end
        end

        table.insert(targets, {
            Player = player,
            Character = char,
            Part = part,
            Position = predictedPos,
            ScreenDist = screenDist,
            WorldDist = dist,
        })
    end

    return targets
end

local function getBestTarget()
    local targets = getTargets()
    if #targets == 0 then return nil end

    if Features.targetPriority == "FOV" then
        table.sort(targets, function(a, b) return a.ScreenDist < b.ScreenDist end)
    else
        table.sort(targets, function(a, b) return a.WorldDist < b.WorldDist end)
    end

    return targets[1]
end

-- ============================================================
--  SILENT AIM
-- ============================================================
local silentHookActive = false
local silentOriginalCast = nil

local function getSilentTargets()
    local targets = {}
    local myChar = LocalPlayer.Character
    if not myChar then return targets end
    local myRoot = myChar:FindFirstChild("HumanoidRootPart")
    if not myRoot then return targets end
    local myPos = myRoot.Position
    local myTeam = LocalPlayer.Team

    for _, player in ipairs(Players:GetPlayers()) do
        if player == LocalPlayer then continue end
        local char = player.Character
        if not char then continue end
        if not isAlive(char) then continue end

        if Features.silentAimTeamCheck and myTeam and player.Team == myTeam then
            continue
        end

        local part = getPart(char, Features.silentAimTargetPart, false)
        if not part then continue end

        local targetPos = part.Position
        local dist = (targetPos - myPos).Magnitude
        if dist > Features.silentAimDistance then continue end

        if not Features.silentAimWallbang then
            if not isVisible(camera.CFrame.Position, targetPos, {myChar}) then
                continue
            end
        end

        local screenPos, onScreen = camera:WorldToViewportPoint(targetPos)
        if not onScreen then continue end
        local center = camera.ViewportSize / 2
        local screenDist = (Vector2.new(screenPos.X, screenPos.Y) - center).Magnitude
        if screenDist > Features.silentAimFOV then continue end

        if Features.silentAimPrediction then
            local hrp = char:FindFirstChild("HumanoidRootPart")
            if hrp then
                local vel = hrp.Velocity or Vector3.new()
                local travelTime = dist / Features.bulletSpeed
                local predFactor = Features.silentAimPredFactor * travelTime
                targetPos = targetPos + vel * predFactor
            end
        end

        table.insert(targets, {
            Player = player,
            Character = char,
            Part = part,
            Position = targetPos,
            ScreenDist = screenDist,
            WorldDist = dist,
        })
    end

    table.sort(targets, function(a, b) return a.ScreenDist < b.ScreenDist end)
    return targets[1]
end

local function setupSilentHook()
    if silentHookActive then return end
    local castTable = nil
    for i, v in pairs(getgc(true)) do
        if type(v) == "table" and rawget(v, "cast") then
            castTable = v
            break
        end
    end
    if not castTable then
        Window:Notify({Title="Silent Aim Error", Description="Fungsi 'cast' tidak ditemukan", Color=Color3.fromRGB(255,0,0), Delay=3})
        return
    end
    silentOriginalCast = castTable.cast
    if not silentOriginalCast then return end
    silentHookActive = true
    castTable.cast = function(p1, p2, p3)
        if Features.silentAimEnabled then
            local best = getSilentTargets()
            if best then
                return best.Part, best.Position, Vector3.new(0,1,0), best.Part.Material
            end
        end
        return silentOriginalCast(p1, p2, p3)
    end
    Window:Notify({Title="Silent Aim", Description="Hook installed!", Color=Color3.fromRGB(0,255,0), Delay=2})
end

local function removeSilentHook()
    if not silentHookActive then return end
    local castTable = nil
    for i, v in pairs(getgc(true)) do
        if type(v) == "table" and rawget(v, "cast") then
            castTable = v
            break
        end
    end
    if castTable and silentOriginalCast then
        castTable.cast = silentOriginalCast
    end
    silentHookActive = false
    silentOriginalCast = nil
    Window:Notify({Title="Silent Aim", Description="Hook removed", Color=Color3.fromRGB(255,255,0), Delay=2})
end

-- ============================================================
--  WALLBANG HOOK
-- ============================================================
local wallbangHookActive = false
local wallbangOriginalCast = nil

local function setupWallbangHook()
    if wallbangHookActive then return end
    local castTable = nil
    for i, v in pairs(getgc(true)) do
        if type(v) == "table" and rawget(v, "cast") then
            castTable = v
            break
        end
    end
    if not castTable then
        Window:Notify({Title="Wallbang Error", Description="Fungsi 'cast' tidak ditemukan", Color=Color3.fromRGB(255,0,0), Delay=3})
        return
    end
    wallbangOriginalCast = castTable.cast
    if not wallbangOriginalCast then return end
    wallbangHookActive = true
    castTable.cast = function(p1, p2, p3)
        if Features.wallbangEnabled then
            local best = getBestTarget()
            if best then
                return best.Part, best.Position, Vector3.new(0,1,0), best.Part.Material
            end
        end
        return wallbangOriginalCast(p1, p2, p3)
    end
    Window:Notify({Title="Wallbang", Description="Hook installed!", Color=Color3.fromRGB(0,255,0), Delay=2})
end

local function removeWallbangHook()
    if not wallbangHookActive then return end
    local castTable = nil
    for i, v in pairs(getgc(true)) do
        if type(v) == "table" and rawget(v, "cast") then
            castTable = v
            break
        end
    end
    if castTable and wallbangOriginalCast then
        castTable.cast = wallbangOriginalCast
    end
    wallbangHookActive = false
    wallbangOriginalCast = nil
    Window:Notify({Title="Wallbang", Description="Hook removed", Color=Color3.fromRGB(255,255,0), Delay=2})
end

-- ============================================================
--  TRIGGERBOT FIRE
-- ============================================================
local isShooting = false
UserInputService.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        isShooting = true
    end
end)
UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        isShooting = false
    end
end)

local function fireShot(targetPos)
    local success = false
    if Features.triggerMethod == "Remote" then
        local remotes = {
            ReplicatedStorage:FindFirstChild("Remotes") and ReplicatedStorage.Remotes:FindFirstChild("Shoot"),
            ReplicatedStorage:FindFirstChild("Shoot"),
            ReplicatedStorage:FindFirstChild("Fire"),
            ReplicatedStorage:FindFirstChild("GunEvent"),
            ReplicatedStorage:FindFirstChild("RemoteEvent"),
            ReplicatedStorage:FindFirstChild("Weapon") and ReplicatedStorage.Weapon:FindFirstChild("Fire"),
        }
        for _, remote in ipairs(remotes) do
            if remote then
                pcall(function() remote:FireServer(targetPos) end)
                success = true
                break
            end
        end
        if not success then
            for _, child in ipairs(ReplicatedStorage:GetChildren()) do
                if child:IsA("RemoteEvent") or child:IsA("RemoteFunction") then
                    local name = child.Name:lower()
                    if name:find("shoot") or name:find("fire") or name:find("gun") or name:find("attack") then
                        pcall(function() child:FireServer(targetPos) end)
                        success = true
                        break
                    end
                end
            end
        end
    end

    if not success or Features.triggerMethod == "MouseClick" then
        pcall(function()
            VirtualInputManager:SendMouseButtonEvent(Enum.UserInputType.MouseButton1, 0, true, game, 0)
            task.wait(0.01)
            VirtualInputManager:SendMouseButtonEvent(Enum.UserInputType.MouseButton1, 0, false, game, 0)
            success = true
        end)
    end

    if Features.triggerDebug and success then
        Window:Notify({Title="Trigger", Description="Shot fired!", Color=Color3.fromRGB(255,255,0), Delay=0.5})
    end
end

-- ============================================================
--  FOV CIRCLE
-- ============================================================
local fovGui = Instance.new("ScreenGui")
fovGui.Name = "W424_FOV_GUI"
fovGui.Parent = CoreGui
fovGui.ResetOnSpawn = false
fovGui.IgnoreGuiInset = true

local fovFrame = Instance.new("Frame")
fovFrame.BackgroundTransparency = 1
fovFrame.AnchorPoint = Vector2.new(0.5, 0.5)
fovFrame.Position = UDim2.new(0.5, 0, 0.5, 0)
fovFrame.Size = UDim2.new(0, Features.fovRadius * 2, 0, Features.fovRadius * 2)
fovFrame.Visible = false
fovFrame.Parent = fovGui
Instance.new("UIStroke", fovFrame).Color = Color3.fromRGB(255,255,255)
Instance.new("UICorner", fovFrame).CornerRadius = UDim.new(1,0)

local function updateFOVSize()
    fovFrame.Size = UDim2.new(0, Features.fovRadius * 2, 0, Features.fovRadius * 2)
end

-- ============================================================
--  MAIN LOOP
-- ============================================================
local triggerLastShot = 0

RunService.RenderStepped:Connect(function(dt)
    local best = nil
    if Features.aimbotEnabled or Features.triggerbotEnabled or Features.wallbangEnabled then
        best = getBestTarget()
    end

    if Features.aimbotEnabled and best then
        local canAim = (Features.aimTrigger == "Always") or (Features.aimTrigger == "On Shoot" and isShooting)
        if canAim then
            local targetPos = best.Position
            local currentCF = camera.CFrame
            local targetCF = CFrame.new(currentCF.Position, targetPos)
            local smooth = 1 - math.exp(-Features.aimSmoothness * dt * 10)
            camera.CFrame = currentCF:Lerp(targetCF, smooth)
        end
    end

    if Features.triggerbotEnabled and best then
        local screenPos, onScreen = camera:WorldToViewportPoint(best.Position)
        if onScreen then
            local center = camera.ViewportSize / 2
            local dist = (Vector2.new(screenPos.X, screenPos.Y) - center).Magnitude
            local currentFOV = Features.aggressiveMode and Features.triggerFOV * 1.5 or Features.triggerFOV

            if dist < currentFOV then
                if Features.triggerHeadshotOnly and best.Part.Name ~= "Head" then
                    return
                end

                local now = tick()
                local effectiveDelay = Features.aggressiveMode and Features.triggerDelay * 0.3 or Features.triggerDelay
                effectiveDelay = math.max(effectiveDelay, 0.005)

                if now - triggerLastShot >= effectiveDelay then
                    triggerLastShot = now
                    local shotsToFire = Features.aggressiveMode and Features.burstShots or 1
                    for i = 1, shotsToFire do
                        fireShot(best.Position)
                        if i < shotsToFire then
                            local burstWait = Features.aggressiveMode and Features.burstDelay * 0.5 or Features.burstDelay
                            task.wait(math.max(burstWait, 0.005))
                        end
                    end
                    if Features.aggressiveMode then
                        triggerLastShot = now - effectiveDelay * 0.5
                    end
                end
            end
        end
    end
end)

-- ============================================================
--  PLAYER MODS LOOP
-- ============================================================
task.spawn(function()
    while true do
        pcall(function()
            local char = LocalPlayer.Character
            if not char then task.wait(1) return end
            local hum = char:FindFirstChildOfClass("Humanoid")
            if not hum then task.wait(1) return end

            if Features.antiRagdoll then
                hum.PlatformStand = false
                hum.Sit = false
                local hrp = char:FindFirstChild("HumanoidRootPart")
                if hrp then hrp.Velocity = Vector3.new(); hrp.RotVelocity = Vector3.new() end
            end

            if Features.antiAFK then
                local hrp = char:FindFirstChild("HumanoidRootPart")
                if hrp then
                    hrp.CFrame = hrp.CFrame * CFrame.Angles(0, math.rad(1), 0)
                    hrp.Velocity = Vector3.new(math.random(-1,1), 0, math.random(-1,1))
                end
            end

            local tool = char:FindFirstChildOfClass("Tool")
            if tool then
                if Features.noRecoil then
                    for _, prop in ipairs({"Recoil","recoil","Kickback","GunRecoil","Shake","CameraRecoil"}) do
                        local success, val = pcall(function() return tool[prop] end)
                        if success and val ~= nil and type(val) == "number" then tool[prop] = 0 end
                    end
                    if tool:FindFirstChild("Recoil") and tool.Recoil:IsA("NumberValue") then tool.Recoil.Value = 0 end
                end
                if Features.noSpread then
                    for _, prop in ipairs({"Spread","spread","Accuracy","Inaccuracy","BulletSpread","Deviation"}) do
                        local success, val = pcall(function() return tool[prop] end)
                        if success and val ~= nil and type(val) == "number" then tool[prop] = 0 end
                    end
                    if tool:FindFirstChild("Spread") and tool.Spread:IsA("NumberValue") then tool.Spread.Value = 0 end
                    if tool:FindFirstChild("Inaccuracy") and tool.Inaccuracy:IsA("NumberValue") then tool.Inaccuracy.Value = 0 end
                end
                for _, child in ipairs(tool:GetDescendants()) do
                    if child:IsA("NumberValue") or child:IsA("IntValue") or child:IsA("FloatValue") then
                        local name = child.Name:lower()
                        if Features.noRecoil and (name:find("recoil") or name:find("kick") or name:find("shake")) then child.Value = 0 end
                        if Features.noSpread and (name:find("spread") or name:find("inaccuracy") or name:find("accuracy") or name:find("deviation")) then child.Value = 0 end
                    end
                end
            end
        end)
        task.wait(0.2)
    end
end)

-- ============================================================
--  ESP DEFAULT (HIGHLIGHT)
-- ============================================================
local highlightObjects = {}

local function clearESP()
    for _, h in pairs(highlightObjects) do
        pcall(function() h:Destroy() end)
    end
    highlightObjects = {}
end

local function updateESP()
    if not Features.espEnabled then
        clearESP()
        return
    end

    for _, player in ipairs(Players:GetPlayers()) do
        if player == LocalPlayer then continue end
        local char = player.Character
        if not char then
            if highlightObjects[player] then
                highlightObjects[player]:Destroy()
                highlightObjects[player] = nil
            end
            continue
        end
        if not isAlive(char) then
            if highlightObjects[player] then
                highlightObjects[player]:Destroy()
                highlightObjects[player] = nil
            end
            continue
        end
        if Features.espTeamCheck and LocalPlayer.Team and player.Team == LocalPlayer.Team then
            if highlightObjects[player] then
                highlightObjects[player].Enabled = false
            end
            continue
        end

        if not highlightObjects[player] then
            local highlight = Instance.new("Highlight")
            highlight.Parent = char
            highlight.FillColor = Features.espColor
            highlight.OutlineColor = Features.espColor
            highlight.FillTransparency = Features.espTransparency
            highlight.OutlineTransparency = 0.5
            highlight.Enabled = true
            highlightObjects[player] = highlight
        else
            highlightObjects[player].Parent = char
            highlightObjects[player].FillColor = Features.espColor
            highlightObjects[player].FillTransparency = Features.espTransparency
            highlightObjects[player].Enabled = true
        end
    end

    for player, obj in pairs(highlightObjects) do
        if not player.Parent or not Players:FindFirstChild(player.Name) then
            obj:Destroy()
            highlightObjects[player] = nil
        end
    end
end

Players.PlayerAdded:Connect(function()
    task.wait(0.5)
    updateESP()
end)
Players.PlayerRemoving:Connect(function(player)
    if highlightObjects[player] then
        highlightObjects[player]:Destroy()
        highlightObjects[player] = nil
    end
end)
RunService.RenderStepped:Connect(updateESP)

-- ============================================================
--  WEAPON MODS (Arsenal)
-- ============================================================
local Weapons = ReplicatedStorage:FindFirstChild("Weapons")
local weaponDefaults = {}

if Weapons then
    for _, weapon in ipairs(Weapons:GetChildren()) do
        local data = {}
        if weapon:FindFirstChild("FireRate") then data.FireRate = weapon.FireRate.Value end
        if weapon:FindFirstChild("BFireRate") then data.BFireRate = weapon.BFireRate.Value end
        if weapon:FindFirstChild("ReloadTime") then data.ReloadTime = weapon.ReloadTime.Value end
        if weapon:FindFirstChild("RecoilControl") then data.RecoilControl = weapon.RecoilControl.Value end
        if weapon:FindFirstChild("MaxSpread") then data.MaxSpread = weapon.MaxSpread.Value end
        if weapon:FindFirstChild("SpreadRecovery") then data.SpreadRecovery = weapon.SpreadRecovery.Value end
        weaponDefaults[weapon.Name] = data
    end
end

local function applyWeaponMods()
    if not Weapons then return end
    for _, weapon in ipairs(Weapons:GetChildren()) do
        local defaults = weaponDefaults[weapon.Name]
        if not defaults then continue end

        if Features.fastFire then
            if weapon:FindFirstChild("FireRate") then weapon.FireRate.Value = 0.01 end
            if weapon:FindFirstChild("BFireRate") then weapon.BFireRate.Value = 0.01 end
        else
            if weapon:FindFirstChild("FireRate") and defaults.FireRate then weapon.FireRate.Value = defaults.FireRate end
            if weapon:FindFirstChild("BFireRate") and defaults.BFireRate then weapon.BFireRate.Value = defaults.BFireRate end
        end

        if Features.fastReload then
            if weapon:FindFirstChild("ReloadTime") then weapon.ReloadTime.Value = 0.01 end
        else
            if weapon:FindFirstChild("ReloadTime") and defaults.ReloadTime then weapon.ReloadTime.Value = defaults.ReloadTime end
        end

        if Features.arsenalNoRecoil then
            if weapon:FindFirstChild("RecoilControl") then weapon.RecoilControl.Value = 0 end
        else
            if weapon:FindFirstChild("RecoilControl") and defaults.RecoilControl then weapon.RecoilControl.Value = defaults.RecoilControl end
        end

        if Features.arsenalNoSpread then
            if weapon:FindFirstChild("MaxSpread") then weapon.MaxSpread.Value = 0.01 end
            if weapon:FindFirstChild("SpreadRecovery") then weapon.SpreadRecovery.Value = 0.01 end
        else
            if weapon:FindFirstChild("MaxSpread") and defaults.MaxSpread then weapon.MaxSpread.Value = defaults.MaxSpread end
            if weapon:FindFirstChild("SpreadRecovery") and defaults.SpreadRecovery then weapon.SpreadRecovery.Value = defaults.SpreadRecovery end
        end
    end
end

-- ============================================================
--  FPS & PING STATS
-- ============================================================
local statsGui = Instance.new("ScreenGui")
statsGui.Name = "W424_STATS_GUI"
statsGui.Parent = CoreGui
statsGui.ResetOnSpawn = false
statsGui.IgnoreGuiInset = true

local statsFrame = Instance.new("Frame")
statsFrame.Size = UDim2.new(0, 140, 0, 28)
statsFrame.Position = UDim2.new(0, 10, 0, 10)
statsFrame.BackgroundTransparency = 0.5
statsFrame.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
statsFrame.Visible = false
statsFrame.Parent = statsGui
Instance.new("UICorner", statsFrame).CornerRadius = UDim.new(0, 4)

local statsText = Instance.new("TextLabel")
statsText.Size = UDim2.new(1, 0, 1, 0)
statsText.BackgroundTransparency = 1
statsText.TextColor3 = Color3.fromRGB(0, 255, 100)
statsText.Font = Enum.Font.GothamBold
statsText.TextSize = 12
statsText.Text = " FPS:0  Ping:0ms"
statsText.Parent = statsFrame

local frameCount = 0
local timeAcc = 0
RunService.RenderStepped:Connect(function(dt)
    if Features.statsEnabled then
        frameCount = frameCount + 1
        timeAcc = timeAcc + dt
        if timeAcc >= 1 then
            local ping = 0
            pcall(function() ping = LocalPlayer:GetNetworkPing() * 1000 end)
            statsText.Text = string.format(" FPS:%d  Ping:%.0fms", frameCount, ping)
            frameCount = 0
            timeAcc = 0
        end
    end
end)

-- ============================================================
--  UI BUILDING
-- ============================================================

-- ===== TAB MAIN =====
local TabMain = Window:CreateTab("Main")
Window:AddParagraph(TabMain, "Player Mods", "Character & weapon tweaks")
Window:AddToggle(TabMain, "No Recoil (Camera)", "Hilangkan getaran senjata", false, function(s) Features.noRecoil = s end)
Window:AddToggle(TabMain, "No Spread", "Akurasi sempurna", false, function(s) Features.noSpread = s end)
Window:AddToggle(TabMain, "Anti Ragdoll", "Cegah jatuh / ragdoll", false, function(s) Features.antiRagdoll = s end)
Window:AddToggle(TabMain, "Anti AFK", "Gerak otomatis agar tidak di-kick", false, function(s) Features.antiAFK = s end)

Window:AddDivider(TabMain, "Arsenal Mods")
Window:AddToggle(TabMain, "Infinite Ammo", "Ammo tidak habis", false, function(s)
    Features.infiniteAmmo = s
    if s then
        pcall(function()
            if ReplicatedStorage:FindFirstChild("wkspc") and ReplicatedStorage.wkspc:FindFirstChild("CurrentCurse") then
                ReplicatedStorage.wkspc.CurrentCurse.Value = 'Infinite Ammo'
            end
        end)
    end
end)
Window:AddToggle(TabMain, "Fast Fire Rate", "Tembak super cepat (Arsenal)", false, function(s)
    Features.fastFire = s
    applyWeaponMods()
end)
Window:AddToggle(TabMain, "Fast Reload", "Reload hampir instan", false, function(s)
    Features.fastReload = s
    applyWeaponMods()
end)
Window:AddToggle(TabMain, "No Recoil (Arsenal)", "Set RecoilControl ke 0", false, function(s)
    Features.arsenalNoRecoil = s
    applyWeaponMods()
end)
Window:AddToggle(TabMain, "No Spread (Arsenal)", "Set MaxSpread & SpreadRecovery", false, function(s)
    Features.arsenalNoSpread = s
    applyWeaponMods()
end)

-- ===== TAB AIM =====
local TabAim = Window:CreateTab("Aim")
Window:AddParagraph(TabAim, "Aimbot", "Camera aimbot settings")

Window:AddToggle(TabAim, "Enable Aimbot", "Gerakkan kamera ke target", false, function(s) Features.aimbotEnabled = s end)
Window:AddDropdown(TabAim, "Trigger", "Kapan aim aktif", {"On Shoot","Always"}, false, "On Shoot", function(v) Features.aimTrigger = v end)
Window:AddToggle(TabAim, "FOV Circle", "Tampilkan lingkaran FOV", false, function(s) fovFrame.Visible = s end)
Window:AddSlider(TabAim, "FOV Radius", "30-400", 30, 400, 150, function(v) Features.fovRadius = v; updateFOVSize() end)
Window:AddSlider(TabAim, "Max Distance", "50-500", 50, 500, 400, function(v) Features.maxAimDistance = v end)
Window:AddToggle(TabAim, "Anti Team", "Hindari tim sendiri", true, function(s) Features.useTeamCheck = s end)
Window:AddToggle(TabAim, "Vis Check", "Periksa tembok", true, function(s) Features.useVisibilityCheck = s end)
Window:AddToggle(TabAim, "Headshot Only", "Hanya Head", false, function(s) Features.headshotOnly = s end)
Window:AddDropdown(TabAim, "Target Part", "Bagian tubuh", {"Head","HumanoidRootPart","UpperTorso","Torso"}, false, "Head", function(v) Features.targetPart = v end)
Window:AddSlider(TabAim, "Smoothness", "1-10", 1, 10, 3, function(v) Features.aimSmoothness = v/10 end)
Window:AddSlider(TabAim, "Hitbox Expansion", "0-5 (perbesar target)", 0, 5, 0, function(v) Features.hitboxExpansion = v end)
Window:AddDropdown(TabAim, "Target Priority", "FOV or Distance", {"FOV","Distance"}, false, "FOV", function(v) Features.targetPriority = v end)

Window:AddDivider(TabAim, "Silent Aim")
Window:AddToggle(TabAim, "Enable Silent Aim", "Aim tanpa gerak kamera (hook 'cast')", false, function(s)
    Features.silentAimEnabled = s
    if s then setupSilentHook() else removeSilentHook() end
end)
Window:AddSlider(TabAim, "Silent FOV", "30-400", 30, 400, 200, function(v) Features.silentAimFOV = v end)
Window:AddSlider(TabAim, "Silent Distance", "50-500", 50, 500, 400, function(v) Features.silentAimDistance = v end)
Window:AddDropdown(TabAim, "Silent Target Part", "Bagian tubuh", {"Head","HumanoidRootPart","UpperTorso","Torso"}, false, "Head", function(v) Features.silentAimTargetPart = v end)
Window:AddToggle(TabAim, "Silent Wallbang", "Tembus tembok", true, function(s) Features.silentAimWallbang = s end)
Window:AddToggle(TabAim, "Silent Anti Team", "Hindari tim", true, function(s) Features.silentAimTeamCheck = s end)

Window:AddDivider(TabAim, "Wallbang (Camera mode)")
Window:AddToggle(TabAim, "Enable Wallbang", "Tembus tembok (hook 'cast')", false, function(v)
    Features.wallbangEnabled = v
    if v then setupWallbangHook() else removeWallbangHook() end
end)

Window:AddDivider(TabAim, "Triggerbot (Auto Shoot)")
Window:AddToggle(TabAim, "Enable Triggerbot", "Tembak otomatis saat crosshair di musuh", false, function(v) Features.triggerbotEnabled = v end)
Window:AddSlider(TabAim, "Trigger Delay", "0.01-0.5s", 1, 50, 8, function(v) Features.triggerDelay = v/100 end)
Window:AddSlider(TabAim, "Trigger FOV", "Pixel radius (5-100)", 5, 100, 35, function(v) Features.triggerFOV = v end)
Window:AddToggle(TabAim, "Trigger Headshot Only", "Hanya tembak jika target Head", false, function(v) Features.triggerHeadshotOnly = v end)
Window:AddToggle(TabAim, "Aggressive Mode", "Spam tembakan super cepat", false, function(v)
    Features.aggressiveMode = v
    if v then
        Features.triggerDelay = 0.01
        Features.triggerFOV = math.max(Features.triggerFOV, 40)
        Window:Notify({Title="Aggressive Mode ON", Description="Spam aktif!", Color=Color3.fromRGB(255,0,0), Delay=2})
    else
        Features.triggerDelay = 0.08
        Window:Notify({Title="Aggressive Mode OFF", Description="Normal", Color=Color3.fromRGB(0,255,0), Delay=2})
    end
end)
Window:AddSlider(TabAim, "Burst Shots", "Tembakan per trigger (1-10)", 1, 10, 3, function(v) Features.burstShots = v end)
Window:AddSlider(TabAim, "Burst Delay", "Jeda antar burst (0.01-0.1s)", 1, 10, 3, function(v) Features.burstDelay = v/100 end)
Window:AddDropdown(TabAim, "Trigger Method", "Cara mengirim tembakan", {"Remote","MouseClick"}, false, "Remote", function(v) Features.triggerMethod = v end)
Window:AddToggle(TabAim, "Trigger Debug", "Tampilkan notifikasi saat tembak", false, function(v) Features.triggerDebug = v end)

-- ===== TAB PREDICT =====
local TabPredict = Window:CreateTab("Predict")
Window:AddParagraph(TabPredict, "Prediction", "Aim prediction for moving targets")

Window:AddToggle(TabPredict, "Enable Prediction", "Aim ke depan target berdasarkan kecepatan", true, function(s) Features.usePrediction = s end)
Window:AddSlider(TabPredict, "Prediction Factor", "0-100 (semakin tinggi semakin agresif)", 0, 100, 30, function(v) Features.predictionFactor = v/100 end)
Window:AddSlider(TabPredict, "Bullet Speed", "500-1500 (simulasi kecepatan peluru)", 500, 1500, 800, function(v) Features.bulletSpeed = v end)

-- ===== TAB VISUAL =====
local TabVisual = Window:CreateTab("Visual")
Window:AddParagraph(TabVisual, "ESP Highlight", "Tandai musuh dengan warna")
Window:AddToggle(TabVisual, "Enable ESP", "Aktifkan Highlight", false, function(s) Features.espEnabled = s; if not s then clearESP() end end)
Window:AddColorPicker(TabVisual, "ESP Color", "", Color3.fromRGB(255, 0, 0), function(c) Features.espColor = c; updateESP() end)
Window:AddSlider(TabVisual, "Transparency", "0-10", 0, 10, 3, function(v) Features.espTransparency = v/10; updateESP() end)
Window:AddToggle(TabVisual, "Team Check", "Sembunyikan tim", true, function(s) Features.espTeamCheck = s; updateESP() end)

Window:AddDivider(TabVisual, "Minimap Optimization")
Window:AddToggle(TabVisual, "Reduce Map", "Sembunyikan minimap", false, function(s)
    Features.reduceMap = s
    applyReduceMap(s)
end)

Window:AddDivider(TabVisual, "Field of View")
Window:AddSlider(TabVisual, "FOV (Field of View)", "60-120", 60, 120, 70, function(v) Features.fovValue = v; pcall(function() workspace.CurrentCamera.FieldOfView = v end) end, "FOVSlider", true)
pcall(function() workspace.CurrentCamera.FieldOfView = 70 end)

Window:AddDivider(TabVisual, "Stats")
Window:AddToggle(TabVisual, "FPS & Ping", "Tampilkan FPS dan ping", false, function(s) Features.statsEnabled = s; statsFrame.Visible = s end)

-- ===== TAB CONFIG =====
local TabConfig = Window:CreateTab("Config")
Window:AddParagraph(TabConfig, "Configuration", "Save & Load settings")
Window:AddButton(TabConfig, "Save Config", "Simpan setting ke file", function()
    Window:Save()
    Window:Notify({Title="Config", Description="Settings saved!", Color=Color3.fromRGB(0,255,0), Delay=2})
end)
Window:AddButton(TabConfig, "Load Config", "Muat setting dari file", function()
    Window:Load()
    Window:Notify({Title="Config", Description="Settings loaded!", Color=Color3.fromRGB(0,255,0), Delay=2})
end)
Window:AddDivider(TabConfig, "Reset")
Window:AddButton(TabConfig, "Reset All Settings", "Kembalikan semua ke default", function()
    Window:Reset()
    Window:Notify({Title="Config", Description="All settings reset!", Color=Color3.fromRGB(255,255,0), Delay=2})
end)
Window:AddDivider(TabConfig, "Info")
Window:AddParagraph(TabConfig, "Version", "W424HUB v5.3")
Window:AddParagraph(TabConfig, "Features", "Aimbot, Silent Aim, Triggerbot, Wallbang, Prediction (bullet speed), ESP Highlight, Fast Fire, Reload, Reduce Map")

-- ============================================================
--  DRAGGABLE STATS FRAME
-- ============================================================
local dragging = false
local dragStart, startPos
UserInputService.InputBegan:Connect(function(input, gp)
    if gp then return end
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        local mousePos = input.Position
        local framePos = statsFrame.AbsolutePosition
        local frameSize = statsFrame.AbsoluteSize
        if mousePos.X >= framePos.X and mousePos.X <= framePos.X + frameSize.X and
           mousePos.Y >= framePos.Y and mousePos.Y <= framePos.Y + frameSize.Y then
            dragging = true
            dragStart = input.Position
            startPos = statsFrame.Position
        end
    end
end)
UserInputService.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
        if dragging then
            local delta = input.Position - dragStart
            statsFrame.Position = UDim2.new(0, startPos.X.Offset + delta.X, 0, startPos.Y.Offset + delta.Y)
        end
    end
end)
UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = false
    end
end)

-- ============================================================
--  FINAL INIT
-- ============================================================
print("✅ W424HUB v5.3 – loaded!")
Window:Notify({Title="W424HUB v5.3", Description="Reduce Map fixed!", Color=Color3.fromRGB(0,200,50), Delay=3})
