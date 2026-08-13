-- ========== W424HUB v4.3 – FIXED (No Actors) ==========
print("=== LOADING W424HUB v4.3 ===")

local Kairo = loadstring(game:HttpGet("https://raw.githubusercontent.com/Itzzavi335/Kairo-Ui-Library/refs/heads/main/source.luau"))()
if not Kairo then return warn("Kairo failed") end

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

-- ============================================
-- WINDOW
-- ============================================
local Window = Kairo:CreateWindow({
    Title = "W424HUB",
    Theme = "Ocean",
    Size = UDim2.fromOffset(500, 520),
    Center = true,
    Draggable = true,
    Resize = false,
    Badges = {"v4.3"},
    MinimizeKey = Enum.KeyCode.RightShift,
    MinimizeButton = true,
    Config = { Enabled = true, Folder = "W424HUB_Config", AutoLoad = true }
})
if not Window then return end

Window:Notify({Title="W424HUB v4.3", Description="Fixed! No Actors needed.", Color=Color3.fromRGB(0,200,50), Delay=3})

-- ============================================
-- TAB MAIN – Player & Arsenal Mods
-- ============================================
local TabMain = Window:CreateTab("Main", "rbxassetid://16932740082")
Window:AddParagraph(TabMain, "Player Mods", "Character & weapon tweaks")

local noRecoil = false
local noSpread = false
local antiRagdoll = false
local antiAFK = false

Window:AddToggle(TabMain, "No Recoil (Camera)", "Hilangkan getaran senjata", false, function(s) noRecoil = s end)
Window:AddToggle(TabMain, "No Spread", "Akurasi sempurna", false, function(s) noSpread = s end)
Window:AddToggle(TabMain, "Anti Ragdoll", "Cegah jatuh / ragdoll", false, function(s) antiRagdoll = s end)
Window:AddToggle(TabMain, "Anti AFK", "Gerak otomatis agar tidak di-kick", false, function(s) antiAFK = s end)

Window:AddDivider(TabMain, "Arsenal Mods")

local infiniteAmmo = false
local fastFire = false
local fastReload = false
local arsenalNoRecoil = false
local arsenalNoSpread = false
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

        if fastFire then
            if weapon:FindFirstChild("FireRate") then weapon.FireRate.Value = 0.01 end
            if weapon:FindFirstChild("BFireRate") then weapon.BFireRate.Value = 0.01 end
        else
            if weapon:FindFirstChild("FireRate") and defaults.FireRate then weapon.FireRate.Value = defaults.FireRate end
            if weapon:FindFirstChild("BFireRate") and defaults.BFireRate then weapon.BFireRate.Value = defaults.BFireRate end
        end

        if fastReload then
            if weapon:FindFirstChild("ReloadTime") then weapon.ReloadTime.Value = 0.01 end
        else
            if weapon:FindFirstChild("ReloadTime") and defaults.ReloadTime then weapon.ReloadTime.Value = defaults.ReloadTime end
        end

        if arsenalNoRecoil then
            if weapon:FindFirstChild("RecoilControl") then weapon.RecoilControl.Value = 0 end
        else
            if weapon:FindFirstChild("RecoilControl") and defaults.RecoilControl then weapon.RecoilControl.Value = defaults.RecoilControl end
        end

        if arsenalNoSpread then
            if weapon:FindFirstChild("MaxSpread") then weapon.MaxSpread.Value = 0.01 end
            if weapon:FindFirstChild("SpreadRecovery") then weapon.SpreadRecovery.Value = 0.01 end
        else
            if weapon:FindFirstChild("MaxSpread") and defaults.MaxSpread then weapon.MaxSpread.Value = defaults.MaxSpread end
            if weapon:FindFirstChild("SpreadRecovery") and defaults.SpreadRecovery then weapon.SpreadRecovery.Value = defaults.SpreadRecovery end
        end
    end
end

Window:AddToggle(TabMain, "Infinite Ammo", "Ammo tidak habis", false, function(s)
    infiniteAmmo = s
    if s then
        pcall(function()
            if ReplicatedStorage:FindFirstChild("wkspc") and ReplicatedStorage.wkspc:FindFirstChild("CurrentCurse") then
                ReplicatedStorage.wkspc.CurrentCurse.Value = 'Infinite Ammo'
            end
        end)
    end
end)

Window:AddToggle(TabMain, "Fast Fire Rate", "Tembak super cepat (Arsenal)", false, function(s)
    fastFire = s
    applyWeaponMods()
end)

Window:AddToggle(TabMain, "Fast Reload", "Reload hampir instan", false, function(s)
    fastReload = s
    applyWeaponMods()
end)

Window:AddToggle(TabMain, "No Recoil (Arsenal)", "Set RecoilControl ke 0", false, function(s)
    arsenalNoRecoil = s
    applyWeaponMods()
end)

Window:AddToggle(TabMain, "No Spread (Arsenal)", "Set MaxSpread & SpreadRecovery", false, function(s)
    arsenalNoSpread = s
    applyWeaponMods()
end)

Window:AddDivider(TabMain, "Camera / FOV")

local fovSliderValue = 70
Window:AddSlider(TabMain, "Field of View (FOV)", "60-120 (CSGO/Valorant style)", 60, 120, 70, function(v)
    fovSliderValue = v
    pcall(function() workspace.CurrentCamera.FieldOfView = v end)
end, "FOVSlider", true)

pcall(function()
    if workspace.CurrentCamera then workspace.CurrentCamera.FieldOfView = 70 end
end)

-- ============================================
-- TAB COMBAT – Aimbot, Silent Aim, Triggerbot
-- ============================================
local TabCombat = Window:CreateTab("Combat", "rbxassetid://16932740082")

Window:AddParagraph(TabCombat, "Aimbot", "Camera aimbot (visible)")

-- Variabel Camera Aimbot
local aimbotEnabled = false
local aimTrigger = "On Shoot"
local isShooting = false
local targetPartName = "Head"
local headshotOnly = false
local aimSmoothness = 1
local useTeamCheck = true
local fovRadius = 100
local maxAimDistance = 300
local usePrediction = false
local predictionFactor = 0.2
local useVisibilityCheck = true

-- Variabel Silent Aim (tanpa Actors)
local silentAimEnabled = false
local silentAimFOV = 150
local silentAimDistance = 300
local silentAimTargetPart = "Head"
local silentAimWallbang = false
local silentAimTeamCheck = true
local silentAimPrediction = false
local silentAimPredFactor = 0.2
local silentHookActive = false
local silentOriginalCast = nil
local aimMode = "Camera"

-- FOV Circle
local fovGui = Instance.new("ScreenGui")
fovGui.Name = "W424_FOV_GUI"
fovGui.Parent = CoreGui
fovGui.ResetOnSpawn = false
fovGui.IgnoreGuiInset = true

local fovFrame = Instance.new("Frame")
fovFrame.BackgroundTransparency = 1
fovFrame.AnchorPoint = Vector2.new(0.5, 0.5)
fovFrame.Position = UDim2.new(0.5, 0, 0.5, 0)
fovFrame.Size = UDim2.new(0, fovRadius * 2, 0, fovRadius * 2)
fovFrame.Visible = false
fovFrame.Parent = fovGui
Instance.new("UIStroke", fovFrame).Color = Color3.fromRGB(255,255,255)
Instance.new("UICorner", fovFrame).CornerRadius = UDim.new(1,0)

local function updateFOVSize() fovFrame.Size = UDim2.new(0, fovRadius * 2, 0, fovRadius * 2) end

-- ===== SILENT AIM (LANGSUNG, TANPA ACTORS) =====
local function getSilentBestTarget()
    local center = camera.ViewportSize / 2
    local best, bestDist = nil, math.huge
    local myChar = LocalPlayer.Character
    if not myChar then return nil end
    local myRoot = myChar:FindFirstChild("HumanoidRootPart")
    if not myRoot then return nil end
    local myPos = myRoot.Position
    local myTeam = LocalPlayer.Team

    for _, p in ipairs(Players:GetPlayers()) do
        if p == LocalPlayer then continue end
        local c = p.Character
        if not c then continue end
        local hum = c:FindFirstChildOfClass("Humanoid")
        if not hum or hum.Health <= 0 then continue end
        if silentAimTeamCheck and myTeam and p.Team and myTeam == p.Team then continue end

        local part = c:FindFirstChild(silentAimTargetPart)
        if not part then
            part = c:FindFirstChild("Head") or c:FindFirstChild("HumanoidRootPart") or c:FindFirstChild("Torso") or c:FindFirstChild("UpperTorso")
        end
        if not part then continue end

        local targetPos = part.Position
        if silentAimPrediction then
            targetPos = targetPos + (part.Velocity or Vector3.new()) * silentAimPredFactor
        end

        local dist = (targetPos - myPos).Magnitude
        if dist > silentAimDistance then continue end

        if not silentAimWallbang then
            local origin = camera.CFrame.Position
            local params = RaycastParams.new()
            params.FilterType = Enum.RaycastFilterType.Exclude
            params.FilterDescendantsInstances = {myChar}
            params.IgnoreWater = true
            local result = workspace:Raycast(origin, (targetPos - origin), params)
            if result then
                local hitChar = result.Instance:FindFirstAncestorOfClass("Model")
                if not (hitChar and Players:GetPlayerFromCharacter(hitChar)) then
                    continue
                end
            end
        end

        local pos, on = camera:WorldToViewportPoint(targetPos)
        if on then
            local screenDist = (Vector2.new(pos.X, pos.Y) - center).Magnitude
            if screenDist <= silentAimFOV and screenDist < bestDist then
                bestDist = screenDist
                best = { Part = part, Position = targetPos, Player = p }
            end
        end
    end
    return best
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
        Window:Notify({Title="Silent Aim Error", Description="Tidak menemukan fungsi 'cast'", Color=Color3.fromRGB(255,0,0), Delay=3})
        return
    end
    silentOriginalCast = castTable.cast
    if not silentOriginalCast then return end
    silentHookActive = true
    castTable.cast = function(p1, p2, p3)
        if silentAimEnabled then
            local best = getSilentBestTarget()
            if best and best.Part then
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

-- FUNGSI VISIBILITY & GET TARGET UNTUK CAMERA AIMBOT
local function isVisible(part)
    if not useVisibilityCheck or not part then return true end
    local origin = camera.CFrame.Position
    local params = RaycastParams.new()
    params.FilterType = Enum.RaycastFilterType.Exclude
    params.FilterDescendantsInstances = {LocalPlayer.Character}
    params.IgnoreWater = true
    local result = workspace:Raycast(origin, (part.Position - origin), params)
    if result then
        local hitChar = result.Instance:FindFirstAncestorOfClass("Model")
        return hitChar and Players:GetPlayerFromCharacter(hitChar) ~= nil
    end
    return true
end

local function getBestTarget()
    if not aimbotEnabled and not triggerbotEnabled and not wallbangEnabled then return nil end
    local center = camera.ViewportSize / 2
    local best, bestDist = nil, math.huge
    local myChar = LocalPlayer.Character
    if not myChar then return nil end
    local myRoot = myChar:FindFirstChild("HumanoidRootPart")
    if not myRoot then return nil end
    local myPos = myRoot.Position

    for _, p in ipairs(Players:GetPlayers()) do
        if p == LocalPlayer then continue end
        local c = p.Character
        if not c then continue end
        local hum = c:FindFirstChildOfClass("Humanoid")
        if not hum or hum.Health <= 0 then continue end
        if useTeamCheck and LocalPlayer.Team and p.Team and LocalPlayer.Team == p.Team then continue end

        local part = headshotOnly and c:FindFirstChild("Head") or c:FindFirstChild(targetPartName)
        if not part then
            part = c:FindFirstChild("Head") or c:FindFirstChild("HumanoidRootPart") or c:FindFirstChild("Torso") or c:FindFirstChild("UpperTorso")
        end
        if not part then continue end

        local targetPos = part.Position
        if usePrediction then
            targetPos = targetPos + (part.Velocity or Vector3.new()) * predictionFactor
        end
        if headshotOnly then
            targetPos = targetPos + Vector3.new(0, 0.5, 0)
        end

        local dist = (targetPos - myPos).Magnitude
        if dist > maxAimDistance then continue end
        if not isVisible(part) then continue end

        local pos, on = camera:WorldToViewportPoint(targetPos)
        if on then
            local screenDist = (Vector2.new(pos.X, pos.Y) - center).Magnitude
            if screenDist <= fovRadius and screenDist < bestDist then
                bestDist = screenDist
                best = { Part = part, Position = targetPos, Player = p }
            end
        end
    end
    return best
end

-- ===== UI COMBAT =====
Window:AddParagraph(TabCombat, "Aim Mode")
Window:AddDropdown(TabCombat, "Aim Mode", "Camera (visible) or Silent (invisible)", {"Camera","Silent"}, false, "Camera", function(v)
    aimMode = v
    if v == "Silent" then
        aimbotEnabled = false
        if silentAimEnabled and not silentHookActive then setupSilentHook() end
    else
        if silentHookActive then removeSilentHook() end
    end
end)

Window:AddDivider(TabCombat, "Camera Aimbot (visible)")
Window:AddToggle(TabCombat, "Enable Camera Aimbot", "Gerakkan kamera ke target", false, function(s)
    aimbotEnabled = s
    if aimMode == "Camera" then
        if s and silentHookActive then removeSilentHook() end
    end
end)
Window:AddDropdown(TabCombat, "Trigger", "Kapan aim aktif", {"On Shoot","Always"}, false, "On Shoot", function(v) aimTrigger = v end)
Window:AddToggle(TabCombat, "FOV Circle", "Tampilkan lingkaran FOV", false, function(s) fovFrame.Visible = s end)
Window:AddSlider(TabCombat, "FOV Radius", "30-400", 30, 400, 100, function(v) fovRadius = v; updateFOVSize() end)
Window:AddSlider(TabCombat, "Max Distance", "50-500", 50, 500, 300, function(v) maxAimDistance = v end)
Window:AddToggle(TabCombat, "Anti Team", "Hindari tim sendiri", true, function(s) useTeamCheck = s end)
Window:AddToggle(TabCombat, "Vis Check", "Periksa tembok", true, function(s) useVisibilityCheck = s end)
Window:AddToggle(TabCombat, "Prediction", "Aim ke depan target", false, function(s) usePrediction = s end)
Window:AddSlider(TabCombat, "Pred Factor", "0-100", 0, 100, 20, function(v) predictionFactor = v/100 end)
Window:AddToggle(TabCombat, "Headshot Only", "Hanya Head", false, function(s) headshotOnly = s; if s then targetPartName = "Head" end end)
Window:AddDropdown(TabCombat, "Target Part", "Bagian tubuh", {"Head","HumanoidRootPart","Torso","UpperTorso"}, false, "Head", function(v) if not headshotOnly then targetPartName = v end end)
Window:AddSlider(TabCombat, "Smoothness", "1-10", 1, 10, 10, function(v) aimSmoothness = v/10 end)

Window:AddDivider(TabCombat, "Silent Aim (invisible)")
Window:AddToggle(TabCombat, "Enable Silent Aim", "Aim tanpa gerak kamera (hook 'cast')", false, function(s)
    silentAimEnabled = s
    if aimMode == "Silent" then
        if s then setupSilentHook() else removeSilentHook() end
    end
end)
Window:AddSlider(TabCombat, "Silent FOV", "30-400", 30, 400, 150, function(v) silentAimFOV = v end)
Window:AddSlider(TabCombat, "Silent Distance", "50-500", 50, 500, 300, function(v) silentAimDistance = v end)
Window:AddDropdown(TabCombat, "Silent Target Part", "Bagian tubuh", {"Head","HumanoidRootPart","Torso","UpperTorso"}, false, "Head", function(v) silentAimTargetPart = v end)
Window:AddToggle(TabCombat, "Silent Wallbang", "Tembus tembok", false, function(s) silentAimWallbang = s end)
Window:AddToggle(TabCombat, "Silent Anti Team", "Hindari tim", true, function(s) silentAimTeamCheck = s end)
Window:AddToggle(TabCombat, "Silent Prediction", "Prediksi", false, function(s) silentAimPrediction = s end)
Window:AddSlider(TabCombat, "Silent Pred Factor", "0-100", 0, 100, 20, function(v) silentAimPredFactor = v/100 end)

-- WALLBANG (Camera mode)
local wallbangEnabled = false
local originalCast = nil
local castHookActive = false

local function setupWallbang()
    if castHookActive then return end
    local castTable = nil
    for i, v in pairs(getgc(true)) do
        if type(v) == "table" and rawget(v, "cast") then
            castTable = v
            break
        end
    end
    if not castTable then
        Window:Notify({Title="Wallbang Error", Description="Tidak menemukan fungsi 'cast'", Color=Color3.fromRGB(255,0,0), Delay=3})
        return
    end
    originalCast = castTable.cast
    if not originalCast then return end
    castHookActive = true
    castTable.cast = function(p1, p2, p3)
        if wallbangEnabled and aimMode == "Camera" then
            local best = getBestTarget()
            if best and best.Part then
                return best.Part, best.Position, Vector3.new(0,1,0), best.Part.Material
            end
        end
        return originalCast(p1, p2, p3)
    end
    Window:Notify({Title="Wallbang", Description="Hook installed!", Color=Color3.fromRGB(0,255,0), Delay=2})
end

local function removeWallbang()
    if not castHookActive then return end
    local castTable = nil
    for i, v in pairs(getgc(true)) do
        if type(v) == "table" and rawget(v, "cast") then
            castTable = v
            break
        end
    end
    if castTable and originalCast then
        castTable.cast = originalCast
    end
    castHookActive = false
    originalCast = nil
    Window:Notify({Title="Wallbang", Description="Hook removed", Color=Color3.fromRGB(255,255,0), Delay=2})
end

Window:AddDivider(TabCombat, "Wallbang (Camera mode)")
Window:AddToggle(TabCombat, "Enable Wallbang", "Tembus tembok (hook 'cast')", false, function(v)
    wallbangEnabled = v
    if aimMode == "Camera" then
        if v then setupWallbang() else removeWallbang() end
    else
        Window:Notify({Title="Wallbang", Description="Gunakan Silent Wallbang", Color=Color3.fromRGB(255,255,0), Delay=2})
    end
end)

-- TRIGGERBOT (IMPROVED)
local triggerbotEnabled = false
local triggerDelay = 0.1
local triggerFOV = 30
local triggerLastShot = 0
local aggressiveMode = false
local burstShots = 3
local burstDelay = 0.03
local autoRecoilReset = false
local triggerMethod = "Remote"
local triggerDebug = false

Window:AddDivider(TabCombat, "Triggerbot (Auto Shoot)")
Window:AddToggle(TabCombat, "Enable Triggerbot", "Tembak otomatis saat crosshair di musuh", false, function(v) triggerbotEnabled = v end)
Window:AddSlider(TabCombat, "Trigger Delay", "0.01-0.5s", 1, 50, 10, function(v) triggerDelay = v/100 end)
Window:AddSlider(TabCombat, "Trigger FOV", "Pixel radius (5-100)", 5, 100, 30, function(v) triggerFOV = v end)
Window:AddToggle(TabCombat, "Aggressive Mode", "Spam tembakan super cepat", false, function(v)
    aggressiveMode = v
    if v then
        triggerDelay = 0.01
        triggerFOV = math.max(triggerFOV, 40)
        Window:Notify({Title="Aggressive Mode ON", Description="Spam aktif!", Color=Color3.fromRGB(255,0,0), Delay=2})
    else
        triggerDelay = 0.1
        Window:Notify({Title="Aggressive Mode OFF", Description="Normal", Color=Color3.fromRGB(0,255,0), Delay=2})
    end
end)
Window:AddSlider(TabCombat, "Burst Shots", "Tembakan per trigger (1-10)", 1, 10, 3, function(v) burstShots = v end)
Window:AddSlider(TabCombat, "Burst Delay", "Jeda antar burst (0.01-0.1s)", 1, 10, 3, function(v) burstDelay = v/100 end)
Window:AddDropdown(TabCombat, "Trigger Method", "Cara mengirim tembakan", {"Remote","MouseClick"}, false, "Remote", function(v) triggerMethod = v end)
Window:AddToggle(TabCombat, "Trigger Debug", "Tampilkan notifikasi saat tembak", false, function(v) triggerDebug = v end)
Window:AddToggle(TabCombat, "Auto Recoil Reset", "Geser mouse ke bawah otomatis", false, function(v) autoRecoilReset = v end)

-- INPUT SHOOT
UserInputService.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then isShooting = true end
end)
UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then isShooting = false end
end)

-- FUNGSI TEMBAK YANG ROBUST
local function fireShot(targetPos)
    local success = false
    if triggerMethod == "Remote" then
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
    
    if not success or triggerMethod == "MouseClick" then
        pcall(function()
            VirtualInputManager:SendMouseButtonEvent(Enum.UserInputType.MouseButton1, 0, true, game, 0)
            task.wait(0.01)
            VirtualInputManager:SendMouseButtonEvent(Enum.UserInputType.MouseButton1, 0, false, game, 0)
            success = true
        end)
    end
    
    if triggerDebug and success then
        Window:Notify({Title="Trigger", Description="Shot fired!", Color=Color3.fromRGB(255,255,0), Delay=0.5})
    end
end

-- MAIN LOOP
RunService.RenderStepped:Connect(function(dt)
    local best = nil
    if aimbotEnabled or triggerbotEnabled or wallbangEnabled then
        best = getBestTarget()
    end

    -- Camera Aimbot
    if aimMode == "Camera" and aimbotEnabled and best then
        local canAim = (aimTrigger == "On Shoot" and isShooting) or (aimTrigger == "Always")
        if canAim then
            local targetPos = best.Position
            local currentCF = camera.CFrame
            local targetCF = CFrame.new(currentCF.Position, targetPos)
            local smoothFactor = 1 - math.exp(-aimSmoothness * dt * 5)
            camera.CFrame = currentCF:Lerp(targetCF, smoothFactor)
        end
    end

    -- TRIGGERBOT
    if triggerbotEnabled and best then
        local pos, onScreen = camera:WorldToViewportPoint(best.Position)
        if onScreen then
            local center = camera.ViewportSize / 2
            local distFromCrosshair = (Vector2.new(pos.X, pos.Y) - center).Magnitude
            local currentFOV = aggressiveMode and triggerFOV * 1.5 or triggerFOV

            if distFromCrosshair < currentFOV then
                local now = tick()
                local effectiveDelay = aggressiveMode and triggerDelay * 0.3 or triggerDelay
                effectiveDelay = math.max(effectiveDelay, 0.005)

                if now - triggerLastShot >= effectiveDelay then
                    triggerLastShot = now
                    local shotsToFire = aggressiveMode and burstShots or 1
                    for i = 1, shotsToFire do
                        fireShot(best.Position)
                        if i < shotsToFire then
                            local burstWait = aggressiveMode and burstDelay * 0.5 or burstDelay
                            task.wait(math.max(burstWait, 0.005))
                        end
                    end
                    if aggressiveMode then
                        triggerLastShot = now - effectiveDelay * 0.5
                    end
                end
            end
        end
    end

    -- Auto Recoil Reset
    if autoRecoilReset and triggerbotEnabled and best then
        pcall(function()
            local screenPos, on = camera:WorldToViewportPoint(best.Position)
            if on then
                local center = camera.ViewportSize / 2
                local offsetY = (screenPos.Y - center.Y) * 0.5
                VirtualInputManager:SendMouseMovement(0, offsetY, game)
            end
        end)
    end
end)

-- ============================================
-- TAB VISUAL – ESP, Line, Reduce Map, FPS/Ping
-- ============================================
local TabVisual = Window:CreateTab("Visual", "rbxassetid://16932740082")

-- ESP
Window:AddParagraph(TabVisual, "ESP Chams")
local espEnabled = false
local espColor = Color3.fromRGB(255, 0, 0)
local espTeam = true
local fillTrans = 0.3
local highlightObjects = {}

local function clearESP()
    for _, h in pairs(highlightObjects) do pcall(function() h:Destroy() end) end
    highlightObjects = {}
end

Window:AddToggle(TabVisual, "Enable ESP", "Highlight musuh", false, function(s)
    espEnabled = s
    if not s then clearESP() end
end)
Window:AddColorPicker(TabVisual, "ESP Color", "", Color3.fromRGB(255, 0, 0), function(c)
    espColor = c
    for _, h in pairs(highlightObjects) do if h then h.FillColor = c end end
end)
Window:AddSlider(TabVisual, "Transparency", "0-10", 0, 10, 3, function(v)
    fillTrans = v/10
    for _, h in pairs(highlightObjects) do if h then h.FillTransparency = fillTrans end end
end)
Window:AddToggle(TabVisual, "Team Check", "Sembunyikan tim", true, function(s)
    espTeam = s
    if espEnabled then
        clearESP()
        for _, p in ipairs(Players:GetPlayers()) do
            if p ~= LocalPlayer then
                local char = p.Character
                if char then
                    local h = Instance.new("Highlight")
                    h.Parent = char
                    h.FillColor = espColor
                    h.OutlineColor = espColor
                    h.FillTransparency = fillTrans
                    h.OutlineTransparency = 0.5
                    h.Enabled = true
                    highlightObjects[p] = h
                end
            end
        end
    end
end)

local function updateESP()
    if not espEnabled then clearESP(); return end
    for _, p in ipairs(Players:GetPlayers()) do
        if p == LocalPlayer then continue end
        local char = p.Character
        if not char then
            if highlightObjects[p] then highlightObjects[p]:Destroy(); highlightObjects[p] = nil end
            continue
        end
        if espTeam and LocalPlayer.Team and p.Team and LocalPlayer.Team == p.Team then
            if highlightObjects[p] then highlightObjects[p].Enabled = false end
            continue
        end
        if not highlightObjects[p] then
            local h = Instance.new("Highlight")
            h.Parent = char
            h.FillColor = espColor
            h.OutlineColor = espColor
            h.FillTransparency = fillTrans
            h.OutlineTransparency = 0.5
            h.Enabled = true
            highlightObjects[p] = h
        else
            highlightObjects[p].Parent = char
            highlightObjects[p].Enabled = true
        end
    end
    for p, h in pairs(highlightObjects) do
        if not p.Parent or not Players:FindFirstChild(p.Name) then
            h:Destroy()
            highlightObjects[p] = nil
        end
    end
end

Players.PlayerAdded:Connect(updateESP)
Players.PlayerRemoving:Connect(function(p) if highlightObjects[p] then highlightObjects[p]:Destroy(); highlightObjects[p] = nil end end)
RunService.RenderStepped:Connect(updateESP)

-- LINE ESP
Window:AddDivider(TabVisual, "Line ESP (Tracer)")
local lineESPEnabled = false
local lineColor = Color3.fromRGB(0, 255, 255)
local lineThickness = 1

local lineGui = Instance.new("ScreenGui")
lineGui.Name = "W424_LINE_ESP"
lineGui.Parent = CoreGui
lineGui.ResetOnSpawn = false
lineGui.IgnoreGuiInset = true
local lineObjects = {}

local function clearLines()
    for _, obj in pairs(lineObjects) do if obj then obj:Destroy() end end
    lineObjects = {}
end

local function updateLineESP()
    if not lineESPEnabled then clearLines(); return end
    local myChar = LocalPlayer.Character
    if not myChar then return end
    local root = myChar:FindFirstChild("HumanoidRootPart")
    if not root then return end

    for _, p in ipairs(Players:GetPlayers()) do
        if p == LocalPlayer then continue end
        local char = p.Character
        if not char then
            if lineObjects[p] then lineObjects[p]:Destroy(); lineObjects[p] = nil end
            continue
        end
        local hum = char:FindFirstChildOfClass("Humanoid")
        if not hum or hum.Health <= 0 then
            if lineObjects[p] then lineObjects[p]:Destroy(); lineObjects[p] = nil end
            continue
        end
        local targetRoot = char:FindFirstChild("HumanoidRootPart") or char:FindFirstChild("Torso") or char:FindFirstChild("UpperTorso")
        if not targetRoot then
            if lineObjects[p] then lineObjects[p]:Destroy(); lineObjects[p] = nil end
            continue
        end

        local myPos, on1 = camera:WorldToViewportPoint(root.Position)
        local targetPos, on2 = camera:WorldToViewportPoint(targetRoot.Position)
        if not on1 or not on2 then
            if lineObjects[p] then lineObjects[p]:Destroy(); lineObjects[p] = nil end
            continue
        end

        if not lineObjects[p] then
            local line = Instance.new("Frame")
            line.BackgroundColor3 = lineColor
            line.BackgroundTransparency = 0.5
            line.BorderSizePixel = 0
            line.Parent = lineGui
            lineObjects[p] = line
        end

        local line = lineObjects[p]
        local dx = targetPos.X - myPos.X
        local dy = targetPos.Y - myPos.Y
        local length = math.sqrt(dx*dx + dy*dy)
        local angle = math.atan2(dy, dx)

        line.Position = UDim2.new(0, myPos.X, 0, myPos.Y)
        line.Size = UDim2.new(0, length, 0, lineThickness)
        line.Rotation = math.deg(angle)
        line.BackgroundColor3 = lineColor
        line.Visible = true
    end

    for p, obj in pairs(lineObjects) do
        if not Players:FindFirstChild(p.Name) then
            obj:Destroy()
            lineObjects[p] = nil
        end
    end
end

Window:AddToggle(TabVisual, "Enable Line ESP", "Gambar garis ke musuh", false, function(s)
    lineESPEnabled = s
    if not s then clearLines() end
end)
Window:AddColorPicker(TabVisual, "Line Color", "", Color3.fromRGB(0, 255, 255), function(c) lineColor = c end)
Window:AddSlider(TabVisual, "Line Thickness", "1-5", 1, 5, 1, function(v) lineThickness = v end)

RunService.RenderStepped:Connect(updateLineESP)
Players.PlayerAdded:Connect(updateLineESP)
Players.PlayerRemoving:Connect(updateLineESP)

-- REDUCE MAP SMOOTH
Window:AddDivider(TabVisual, "Minimap Optimization")
local reduceMap = false
local mapOpacity = 1
local minimapContainer = nil

local function findMinimapContainer()
    for _, gui in ipairs(CoreGui:GetChildren()) do
        if gui:IsA("ScreenGui") then
            local name = gui.Name:lower()
            if name:find("minimap") or name:find("map") or name:find("hud") then
                local vp = gui:FindFirstChildWhichIsA("ViewportFrame")
                if vp then return gui end
            end
        end
    end
    for _, gui in ipairs(LocalPlayer.PlayerGui:GetChildren()) do
        if gui:IsA("ScreenGui") then
            local name = gui.Name:lower()
            if name:find("minimap") or name:find("map") then
                return gui
            end
        end
    end
    return nil
end

local function applyOpacityToChildren(parent, opacity)
    if not parent then return end
    for _, child in ipairs(parent:GetDescendants()) do
        if child:IsA("ImageLabel") or child:IsA("ImageButton") or child:IsA("Frame") then
            pcall(function()
                child.BackgroundTransparency = 1 - opacity
                child.ImageTransparency = 1 - opacity
            end)
        end
        if child:IsA("ViewportFrame") then
            pcall(function() child.ImageTransparency = 1 - opacity end)
        end
    end
end

local function updateMinimap()
    if not minimapContainer then minimapContainer = findMinimapContainer() end
    if not minimapContainer then
        pcall(function() StarterGui:SetCore("MinimapEnabled", not reduceMap) end)
        return
    end

    if reduceMap then
        minimapContainer.Visible = false
        pcall(function() minimapContainer.Size = UDim2.new(0,0,0,0) end)
    else
        minimapContainer.Visible = true
        pcall(function()
            if minimapContainer:GetAttribute("OriginalSize") then
                minimapContainer.Size = minimapContainer:GetAttribute("OriginalSize")
            else
                minimapContainer.Size = UDim2.new(1,0,1,0)
            end
        end)
        applyOpacityToChildren(minimapContainer, mapOpacity)
    end
end

Window:AddToggle(TabVisual, "Reduce Map", "Sembunyikan minimap", false, function(s)
    reduceMap = s
    if not s then applyOpacityToChildren(minimapContainer, mapOpacity) end
    updateMinimap()
end)

Window:AddSlider(TabVisual, "Map Opacity", "Transparansi (0-100%)", 0, 100, 100, function(v)
    mapOpacity = v / 100
    if not reduceMap and minimapContainer then
        applyOpacityToChildren(minimapContainer, mapOpacity)
    end
end, "MapOpacity", true)

local function refreshMinimap()
    minimapContainer = findMinimapContainer()
    if minimapContainer then
        if not minimapContainer:GetAttribute("OriginalSize") then
            minimapContainer:SetAttribute("OriginalSize", minimapContainer.Size)
        end
        updateMinimap()
    end
end

task.wait(1)
refreshMinimap()
CoreGui.ChildAdded:Connect(function() task.wait(0.5); refreshMinimap() end)
LocalPlayer.PlayerGui.ChildAdded:Connect(function() task.wait(0.5); refreshMinimap() end)

-- FPS & PING
Window:AddDivider(TabVisual, "Stats")
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

local statsOn = false
Window:AddToggle(TabVisual, "FPS & Ping", "Tampilkan FPS dan ping", false, function(s)
    statsOn = s
    statsFrame.Visible = s
end)

local frameCount = 0
local timeAcc = 0
RunService.RenderStepped:Connect(function(dt)
    if statsOn then
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

-- ============================================
-- TAB CONFIG
-- ============================================
local TabConfig = Window:CreateTab("Config", "rbxassetid://16932740082")

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
Window:AddParagraph(TabConfig, "Version", "W424HUB v4.3")
Window:AddParagraph(TabConfig, "Features", "Aimbot, Silent Aim, Triggerbot, Wallbang, ESP, Hitbox Expansion, Fast Fire, Reload, dll.")

-- ============================================
-- MAIN LOOP – PLAYER MODS
-- ============================================
task.spawn(function()
    while true do
        pcall(function()
            local char = LocalPlayer.Character
            if not char then task.wait(1) return end
            local hum = char:FindFirstChildOfClass("Humanoid")
            if not hum then task.wait(1) return end

            if antiRagdoll then
                if hum.PlatformStand or hum.Sit then
                    hum.PlatformStand = false
                    hum.Sit = false
                    local hrp = char:FindFirstChild("HumanoidRootPart")
                    if hrp then hrp.Velocity = Vector3.new(); hrp.RotVelocity = Vector3.new() end
                end
                if hum.SeatPart then hum.Sit = false end
            end

            if antiAFK then
                local hrp = char:FindFirstChild("HumanoidRootPart")
                if hrp then
                    hrp.CFrame = hrp.CFrame * CFrame.Angles(0, math.rad(1), 0)
                    hrp.Velocity = Vector3.new(math.random(-1,1), 0, math.random(-1,1))
                end
            end

            local tool = char:FindFirstChildOfClass("Tool")
            if tool then
                if noRecoil then
                    for _, prop in ipairs({"Recoil","recoil","Kickback","GunRecoil","Shake","CameraRecoil"}) do
                        local success, val = pcall(function() return tool[prop] end)
                        if success and val ~= nil and type(val) == "number" then tool[prop] = 0; break end
                    end
                    if tool:FindFirstChild("Recoil") and tool.Recoil:IsA("NumberValue") then tool.Recoil.Value = 0 end
                end
                if noSpread then
                    for _, prop in ipairs({"Spread","spread","Accuracy","Inaccuracy","BulletSpread","Deviation"}) do
                        local success, val = pcall(function() return tool[prop] end)
                        if success and val ~= nil and type(val) == "number" then tool[prop] = 0; break end
                    end
                    if tool:FindFirstChild("Spread") and tool.Spread:IsA("NumberValue") then tool.Spread.Value = 0 end
                    if tool:FindFirstChild("Inaccuracy") and tool.Inaccuracy:IsA("NumberValue") then tool.Inaccuracy.Value = 0 end
                end
                for _, child in ipairs(tool:GetDescendants()) do
                    if child:IsA("NumberValue") or child:IsA("IntValue") or child:IsA("FloatValue") then
                        local name = child.Name:lower()
                        if noRecoil and (name:find("recoil") or name:find("kick") or name:find("shake")) then child.Value = 0 end
                        if noSpread and (name:find("spread") or name:find("inaccuracy") or name:find("accuracy") or name:find("deviation")) then child.Value = 0 end
                    end
                end
            end
        end)
        task.wait(0.2)
    end
end)

print("✅ W424HUB v4.3 loaded – Fixed! No Actors, no SurfaceGui errors!")