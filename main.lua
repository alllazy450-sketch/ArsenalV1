-- ========== W424HUB v4.2 – TRIGGERBOT FIX ==========
print("=== LOADING W424HUB v4.2 ===")

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
local Actors = game:GetService("Actors")

-- WINDOW
local Window = Kairo:CreateWindow({
    Title = "W424HUB",
    Theme = "Ocean",
    Size = UDim2.fromOffset(500, 520),
    Center = true,
    Draggable = true,
    Resize = false,
    Badges = {"v4.2"},
    MinimizeKey = Enum.KeyCode.RightShift,
    MinimizeButton = true,
    Config = { Enabled = true, Folder = "W424HUB_Config", AutoLoad = true }
})
if not Window then return end

Window:Notify({Title="W424HUB v4.2", Description="Triggerbot improved!", Color=Color3.fromRGB(0,200,50), Delay=3})

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

-- Variabel Silent Aim
local silentAimEnabled = false
local silentAimFOV = 150
local silentAimDistance = 300
local silentAimTargetPart = "Head"
local silentAimWallbang = false
local silentAimTeamCheck = true
local silentAimPrediction = false
local silentAimPredFactor = 0.2
local silentAimActor = nil
local silentAimRunning = false
local aimMode = "Camera" -- "Camera" atau "Silent"

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

-- FUNGSI SILENT AIM (ACTOR) - sama seperti sebelumnya, tidak diubah
local function getOrCreateActor()
    if silentAimActor and silentAimActor.Parent then return silentAimActor end
    local actor = Instance.new("Actor")
    actor.Name = "W424_SilentAim"
    actor.Parent = workspace
    actor.ResetOnSpawn = false
    actor.AutoRun = true
    silentAimActor = actor
    return actor
end

local function runSilentAimScript()
    local actor = getOrCreateActor()
    if not actor then return end
    pcall(function() actor:Stop() end)
    task.wait(0.1)

    local scriptCode = [=[
        local Players = game:GetService("Players")
        local LocalPlayer = Players.LocalPlayer
        local workspace = game:GetService("Workspace")
        local RunService = game:GetService("RunService")
        local camera = workspace.CurrentCamera

        local function getConfig()
            local actor = script.Parent
            if not actor then return {} end
            return {
                enabled = actor:GetAttribute("Enabled") or false,
                fov = actor:GetAttribute("FOV") or 150,
                distance = actor:GetAttribute("Distance") or 300,
                targetPart = actor:GetAttribute("TargetPart") or "Head",
                wallbang = actor:GetAttribute("Wallbang") or false,
                teamCheck = actor:GetAttribute("TeamCheck") or true,
                prediction = actor:GetAttribute("Prediction") or false,
                predFactor = actor:GetAttribute("PredFactor") or 0.2,
            }
        end

        local function isVisible(part, wallbang)
            if wallbang then return true end
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
            local config = getConfig()
            if not config.enabled then return nil end
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
                if config.teamCheck and myTeam and p.Team and myTeam == p.Team then continue end

                local part = c:FindFirstChild(config.targetPart)
                if not part then
                    part = c:FindFirstChild("Head") or c:FindFirstChild("HumanoidRootPart") or c:FindFirstChild("Torso") or c:FindFirstChild("UpperTorso")
                end
                if not part then continue end

                local targetPos = part.Position
                if config.prediction then
                    targetPos = targetPos + (part.Velocity or Vector3.new()) * config.predFactor
                end

                local dist = (targetPos - myPos).Magnitude
                if dist > config.distance then continue end
                if not isVisible(part, config.wallbang) then continue end

                local pos, on = camera:WorldToViewportPoint(targetPos)
                if on then
                    local screenDist = (Vector2.new(pos.X, pos.Y) - center).Magnitude
                    if screenDist <= config.fov and screenDist < bestDist then
                        bestDist = screenDist
                        best = { Part = part, Position = targetPos, Player = p }
                    end
                end
            end
            return best
        end

        local target = nil
        RunService.RenderStepped:Connect(function()
            target = getBestTarget()
        end)

        local function hookCast()
            for i, v in pairs(getgc()) do
                if type(v) == "function" and islclosure(v) then
                    if debug.info(v, "a") == 2 and #debug.getupvalues(v) == 2 and #debug.getconstants(v) == 17 and debug.info(v,"n"):len() <= 10 then
                        local old
                        old = hookfunction(v, function(p1, p2)
                            if target and target.Position then
                                local config = getConfig()
                                if config.enabled then
                                    local mychar = LocalPlayer.Character
                                    if mychar then
                                        local originPart = mychar:FindFirstChild("Head") or mychar:FindFirstChild("HumanoidRootPart")
                                        if originPart then
                                            local direction = (target.Position - originPart.Position)
                                            p1 = Ray.new(originPart.Position, direction)
                                        end
                                    end
                                end
                            end
                            return old(p1, p2)
                        end)
                        break
                    end
                end
            end
        end

        task.wait(0.5)
        hookCast()
        print("[Silent Aim] Actor running!")
    ]=]

    actor:SetAttribute("Enabled", silentAimEnabled)
    actor:SetAttribute("FOV", silentAimFOV)
    actor:SetAttribute("Distance", silentAimDistance)
    actor:SetAttribute("TargetPart", silentAimTargetPart)
    actor:SetAttribute("Wallbang", silentAimWallbang)
    actor:SetAttribute("TeamCheck", silentAimTeamCheck)
    actor:SetAttribute("Prediction", silentAimPrediction)
    actor:SetAttribute("PredFactor", silentAimPredFactor)

    pcall(function() actor:Run(scriptCode) end)
    silentAimRunning = true
    print("[Silent Aim] Actor started")
end

local function stopSilentAim()
    if silentAimActor then
        pcall(function() silentAimActor:Stop() end)
        pcall(function() silentAimActor:Destroy() end)
        silentAimActor = nil
    end
    silentAimRunning = false
    print("[Silent Aim] Actor stopped")
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
        if silentAimEnabled and not silentAimRunning then runSilentAimScript() end
    else
        if silentAimRunning then stopSilentAim() end
    end
end)

Window:AddDivider(TabCombat, "Camera Aimbot (visible)")
Window:AddToggle(TabCombat, "Enable Camera Aimbot", "Gerakkan kamera ke target", false, function(s)
    aimbotEnabled = s
    if aimMode == "Camera" then
        if s and silentAimRunning then stopSilentAim() end
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
Window:AddToggle(TabCombat, "Enable Silent Aim", "Aim tanpa gerak kamera (Actor-based)", false, function(s)
    silentAimEnabled = s
    if aimMode == "Silent" then
        if s then runSilentAimScript() else stopSilentAim() end
    end
    if silentAimActor then silentAimActor:SetAttribute("Enabled", s) end
end)
Window:AddSlider(TabCombat, "Silent FOV", "30-400", 30, 400, 150, function(v)
    silentAimFOV = v
    if silentAimActor then silentAimActor:SetAttribute("FOV", v) end
end)
Window:AddSlider(TabCombat, "Silent Distance", "50-500", 50, 500, 300, function(v)
    silentAimDistance = v
    if silentAimActor then silentAimActor:SetAttribute("Distance", v) end
end)
Window:AddDropdown(TabCombat, "Silent Target Part", "Bagian tubuh", {"Head","HumanoidRootPart","Torso","UpperTorso"}, false, "Head", function(v)
    silentAimTargetPart = v
    if silentAimActor then silentAimActor:SetAttribute("TargetPart", v) end
end)
Window:AddToggle(TabCombat, "Silent Wallbang", "Tembus tembok", false, function(s)
    silentAimWallbang = s
    if silentAimActor then silentAimActor:SetAttribute("Wallbang", s) end
end)
Window:AddToggle(TabCombat, "Silent Anti Team", "Hindari tim", true, function(s)
    silentAimTeamCheck = s
    if silentAimActor then silentAimActor:SetAttribute("TeamCheck", s) end
end)
Window:AddToggle(TabCombat, "Silent Prediction", "Prediksi", false, function(s)
    silentAimPrediction = s
    if silentAimActor then silentAimActor:SetAttribute("Prediction", s) end
end)
Window:AddSlider(TabCombat, "Silent Pred Factor", "0-100", 0, 100, 20, function(v)
    silentAimPredFactor = v/100
    if silentAimActor then silentAimActor:SetAttribute("PredFactor", silentAimPredFactor) end
end)

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
local triggerMethod = "Remote" -- "Remote" atau "MouseClick"
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
        -- Coba berbagai kemungkinan remote
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
        -- Jika masih gagal, coba cari di semua anak ReplicatedStorage
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
    
    -- Fallback ke Mouse Click
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

    -- TRIGGERBOT (perbaikan)
    if triggerbotEnabled and best then
        local pos, onScreen = camera:WorldToViewportPoint(best.Position)
        if onScreen then
            local center = camera.ViewportSize / 2
            local distFromCrosshair = (Vector2.new(pos.X, pos.Y) - center).Magnitude
            local currentFOV = aggressiveMode and triggerFOV * 1.5 or triggerFOV

            if distFromCrosshair < currentFOV then
                -- Gunakan tick() untuk cooldown lebih akurat
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
                        triggerLastShot = now - effectiveDelay * 0.5 -- reset lebih cepat
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

