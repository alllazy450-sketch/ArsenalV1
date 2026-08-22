-- ============================================================
--  W424 HUB | ARSENAL ULTIMATE v5.6 (SEDERHANA & LENGKAP)
--  Aimbot: 1 toggle + 2 mode (Always / On Shoot) dengan FOV
--  FOV Circle: muncul & radius bisa diatur (range aimbot)
--  Fitur: BunnyHop, InstantReload, RapidFire, HitSound, dll.
-- ============================================================

-- [LOAD UI LIBRARY]
local Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/Naellx/Oxidelib/main/Oxidelib.lua"))()
if not Library then return warn("Oxidelib gagal dimuat") end

Library:SetTheme("Ocean")

local MY_LOGO = "rbxassetid://70773874533764"

local Window = Library:CreateWindow({
    Name = "W424 HUB",
    BrandSubtitle = "Arsenal ULTIMATE v5.6",
    Logo = MY_LOGO,
    LogoZoom = 1.5,
    ToggleKey = Enum.KeyCode.RightShift,
    ProfileKey = Enum.KeyCode.K,
    Size = UDim2.fromOffset(800, 650),
    LoadingText = "W424 HUB",
    LoadingSubtitle = "Loading Arsenal v5.6...",
})

-- ============================================================
--  SERVICES
-- ============================================================
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local HttpService = game:GetService("HttpService")
local VirtualUser = game:GetService("VirtualUser")
local StarterGui = game:GetService("StarterGui")
local Mouse = LocalPlayer:GetMouse()

-- ============================================================
--  FUNGSI KONVERSI WARNA
-- ============================================================
local function color3ToTable(c)
    return {R = c.R, G = c.G, B = c.B}
end
local function tableToColor3(t)
    return Color3.new(t.R, t.G, t.B)
end

-- ============================================================
--  STATE & CONFIG
-- ============================================================
local Toggles = {
    Aimbot = false,
    Silent = false,
    WallCheck = true,
    Predict = true,
    GravityPred = false,
    FOV_Circle = false,
    InfAmmo = false,
    NoRecoil = false,
    NoSpread = false,
    ESP_Enabled = false,
    TeamCheck = true,
    AntiAFK = true,
    Triggerbot = false,
    Fly = false,
    Noclip = false,
    AutoJump = false,
    Tracers = false,
    BoxESP = false,
    HealthBar = false,
    Chams = false,
    Crosshair = false,
    TriggerbotAuto = false,
    BunnyHop = false,
    InstantReload = false,
    RapidFire = false,
    HitSound = false,
}
local Settings = {
    Smoothness = 3,
    FovRadius = 150,
    TargetPart = "Head",
    BulletSpeed = 950,
    PredFactor = 0.5,
    AimMode = "On Shoot",  -- "Always" or "On Shoot"
    WalkSpeed = 16,
    JumpPower = 50,
    FOVPosition = "Center",
    TriggerbotDelay = 0.1,
    ChamsColor = Color3.fromRGB(255,0,0),
    BoxColor = Color3.fromRGB(255,255,255),
    TracerColor = Color3.fromRGB(0,255,0),
    FlySpeed = 50,
    RapidFireDelay = 0.05,
    HitSoundVolume = 0.5,
}
local Keybinds = {
    Aimbot = Enum.KeyCode.LeftControl,
    Silent = Enum.KeyCode.LeftShift,
    ESP = Enum.KeyCode.F1,
    Triggerbot = Enum.KeyCode.F2,
    Fly = Enum.KeyCode.F3,
    Noclip = Enum.KeyCode.F4,
}

-- ============================================================
--  SAVE / LOAD CONFIG
-- ============================================================
local CONFIG_FILE = "W424_Arsenal_Config.json"
local function saveConfig()
    local data = {
        Toggles = Toggles,
        Settings = {
            Smoothness = Settings.Smoothness,
            FovRadius = Settings.FovRadius,
            TargetPart = Settings.TargetPart,
            BulletSpeed = Settings.BulletSpeed,
            PredFactor = Settings.PredFactor,
            AimMode = Settings.AimMode,
            WalkSpeed = Settings.WalkSpeed,
            JumpPower = Settings.JumpPower,
            FOVPosition = Settings.FOVPosition,
            TriggerbotDelay = Settings.TriggerbotDelay,
            ChamsColor = color3ToTable(Settings.ChamsColor),
            BoxColor = color3ToTable(Settings.BoxColor),
            TracerColor = color3ToTable(Settings.TracerColor),
            FlySpeed = Settings.FlySpeed,
            RapidFireDelay = Settings.RapidFireDelay,
            HitSoundVolume = Settings.HitSoundVolume,
        },
        Keybinds = Keybinds,
    }
    local json = HttpService:JSONEncode(data)
    pcall(function() writefile(CONFIG_FILE, json) end)
end

local function loadConfig()
    if not pcall(function() return readfile(CONFIG_FILE) end) then return end
    local json = readfile(CONFIG_FILE)
    local data = HttpService:JSONDecode(json)
    if data then
        for k,v in pairs(data.Toggles) do Toggles[k] = v end
        for k,v in pairs(data.Settings) do
            if k == "ChamsColor" or k == "BoxColor" or k == "TracerColor" then
                Settings[k] = tableToColor3(v)
            else
                Settings[k] = v
            end
        end
        for k,v in pairs(data.Keybinds) do Keybinds[k] = v end
    end
end
loadConfig()

-- ============================================================
--  UI – TAB COMBAT
-- ============================================================
local TabCombat = Window:AddTab({ Name = "Combat", Icon = "target" })

-- SubTab: Aimbot (sederhana, 1 toggle + mode + FOV)
local SubAim = TabCombat:AddSubTab("Aimbot")
SubAim:AddSection("MAIN AIMBOT")
SubAim:AddToggle({ Name = "Enable Aimbot", Default = Toggles.Aimbot, Callback = function(v) Toggles.Aimbot = v; saveConfig() end })
SubAim:AddDropdown({ Name = "Aim Mode", Options = {"On Shoot", "Always"}, Default = Settings.AimMode, Callback = function(v) Settings.AimMode = v; saveConfig() end })
SubAim:AddSlider({ Name = "Smoothing", Min = 1, Max = 20, Default = Settings.Smoothness, Callback = function(v) Settings.Smoothness = v; saveConfig() end })
SubAim:AddDropdown({ Name = "Target Part", Options = {"Head", "HumanoidRootPart", "LowerTorso"}, Default = Settings.TargetPart, Callback = function(v) Settings.TargetPart = v; saveConfig() end })
SubAim:AddToggle({ Name = "Wall Check", Default = Toggles.WallCheck, Callback = function(v) Toggles.WallCheck = v; saveConfig() end })
SubAim:AddSlider({ Name = "FOV Radius (range)", Min = 30, Max = 600, Default = Settings.FovRadius, Callback = function(v) Settings.FovRadius = v; saveConfig() end })

-- SubTab: Silent Aim
local SubSilent = TabCombat:AddSubTab("Silent Aim")
SubSilent:AddSection("SILENT ENGINE")
SubSilent:AddToggle({ Name = "Enable Silent Aim", Default = Toggles.Silent, Callback = function(v) Toggles.Silent = v; saveConfig() end })

-- SubTab: Prediction
local SubPred = TabCombat:AddSubTab("Prediction")
SubPred:AddSection("SMART PREDICT")
SubPred:AddToggle({ Name = "Enable Prediction", Default = Toggles.Predict, Callback = function(v) Toggles.Predict = v; saveConfig() end })
SubPred:AddToggle({ Name = "Gravity Prediction", Default = Toggles.GravityPred, Callback = function(v) Toggles.GravityPred = v; saveConfig() end })
SubPred:AddSlider({ Name = "Strength", Min = 1, Max = 200, Default = Settings.PredFactor*100, Callback = function(v) Settings.PredFactor = v/100; saveConfig() end })
SubPred:AddSlider({ Name = "Bullet Speed", Min = 500, Max = 4000, Default = Settings.BulletSpeed, Callback = function(v) Settings.BulletSpeed = v; saveConfig() end })

-- SubTab: Triggerbot
local SubTrigger = TabCombat:AddSubTab("Triggerbot")
SubTrigger:AddSection("AUTO SHOOT")
SubTrigger:AddToggle({ Name = "Enable Triggerbot", Default = Toggles.Triggerbot, Callback = function(v) Toggles.Triggerbot = v; saveConfig() end })
SubTrigger:AddToggle({ Name = "Auto Mode (hold/toggle)", Default = Toggles.TriggerbotAuto, Callback = function(v) Toggles.TriggerbotAuto = v; saveConfig() end })
SubTrigger:AddSlider({ Name = "Delay (sec)", Min = 0.05, Max = 0.5, Default = Settings.TriggerbotDelay, Callback = function(v) Settings.TriggerbotDelay = v; saveConfig() end })

-- ============================================================
--  UI – TAB VISUALS
-- ============================================================
local TabVisual = Window:AddTab({ Name = "Visuals", Icon = "eye" })

local SubESP = TabVisual:AddSubTab("ESP")
SubESP:AddSection("ESP SETTINGS")
SubESP:AddToggle({ Name = "Enable ESP", Default = Toggles.ESP_Enabled, Callback = function(v) Toggles.ESP_Enabled = v; saveConfig() end })
SubESP:AddToggle({ Name = "Box ESP", Default = Toggles.BoxESP, Callback = function(v) Toggles.BoxESP = v; saveConfig() end })
SubESP:AddToggle({ Name = "Health Bar", Default = Toggles.HealthBar, Callback = function(v) Toggles.HealthBar = v; saveConfig() end })
SubESP:AddToggle({ Name = "Tracers", Default = Toggles.Tracers, Callback = function(v) Toggles.Tracers = v; saveConfig() end })
SubESP:AddToggle({ Name = "Chams (Highlight)", Default = Toggles.Chams, Callback = function(v) Toggles.Chams = v; saveConfig() end })
SubESP:AddToggle({ Name = "Team Check", Default = Toggles.TeamCheck, Callback = function(v) Toggles.TeamCheck = v; saveConfig() end })

SubESP:AddColorPicker({
    Name = "Box Color",
    Default = Settings.BoxColor,
    Callback = function(c)
        if type(c) == "table" and c.R and c.G and c.B then
            Settings.BoxColor = Color3.new(c.R, c.G, c.B)
        else
            Settings.BoxColor = c
        end
        saveConfig()
    end
})
SubESP:AddColorPicker({
    Name = "Tracer Color",
    Default = Settings.TracerColor,
    Callback = function(c)
        if type(c) == "table" and c.R and c.G and c.B then
            Settings.TracerColor = Color3.new(c.R, c.G, c.B)
        else
            Settings.TracerColor = c
        end
        saveConfig()
    end
})
SubESP:AddColorPicker({
    Name = "Chams Color",
    Default = Settings.ChamsColor,
    Callback = function(c)
        if type(c) == "table" and c.R and c.G and c.B then
            Settings.ChamsColor = Color3.new(c.R, c.G, c.B)
        else
            Settings.ChamsColor = c
        end
        saveConfig()
    end
})

-- SubTab: FOV & Crosshair
local SubFOV = TabVisual:AddSubTab("FOV & Crosshair")
SubFOV:AddSection("FOV CIRCLE")
SubFOV:AddToggle({ Name = "Show FOV Circle", Default = Toggles.FOV_Circle, Callback = function(v) Toggles.FOV_Circle = v; saveConfig() end })
SubFOV:AddSlider({ Name = "FOV Size", Min = 30, Max = 600, Default = Settings.FovRadius, Callback = function(v) Settings.FovRadius = v; saveConfig() end })
SubFOV:AddDropdown({ Name = "FOV Position", Options = {"Center", "Mouse"}, Default = Settings.FOVPosition, Callback = function(v) Settings.FOVPosition = v; saveConfig() end })
SubFOV:AddSection("CROSSHAIR")
SubFOV:AddToggle({ Name = "Show Crosshair", Default = Toggles.Crosshair, Callback = function(v) Toggles.Crosshair = v; saveConfig() end })

-- ============================================================
--  UI – TAB WEAPON
-- ============================================================
local TabWeapon = Window:AddTab({ Name = "Weapon", Icon = "zap" })
local SubWeapon = TabWeapon:AddSubTab("Gun Mods")
SubWeapon:AddSection("AMMO & RECOIL")
SubWeapon:AddToggle({ Name = "Infinite Ammo", Default = Toggles.InfAmmo, Callback = function(v) Toggles.InfAmmo = v; saveConfig() end })
SubWeapon:AddToggle({ Name = "No Recoil", Default = Toggles.NoRecoil, Callback = function(v) Toggles.NoRecoil = v; saveConfig() end })
SubWeapon:AddToggle({ Name = "No Spread", Default = Toggles.NoSpread, Callback = function(v) Toggles.NoSpread = v; saveConfig() end })
SubWeapon:AddToggle({ Name = "Instant Reload", Default = Toggles.InstantReload, Callback = function(v) Toggles.InstantReload = v; saveConfig() end })
SubWeapon:AddToggle({ Name = "Rapid Fire", Default = Toggles.RapidFire, Callback = function(v) Toggles.RapidFire = v; saveConfig() end })
SubWeapon:AddSlider({ Name = "Rapid Fire Delay (sec)", Min = 0.01, Max = 0.2, Decimal = 2, Default = Settings.RapidFireDelay, Callback = function(v) Settings.RapidFireDelay = v; saveConfig() end })

local SubMap = TabWeapon:AddSubTab("Map/FPS")
SubMap:AddSection("PERFORMANCE")
SubMap:AddButton({ Name = "Reduce Map (Potato Mode)", Callback = function()
    pcall(function()
        StarterGui:SetCore("MinimapEnabled", false)
        for _, obj in ipairs(workspace:GetDescendants()) do
            if obj:IsA("BasePart") then
                pcall(function() obj.Material = Enum.Material.SmoothPlastic end)
            elseif obj:IsA("Texture") or obj:IsA("Decal") then
                pcall(function() obj:Destroy() end)
            end
        end
    end)
    Window:Notify({ Title = "Map Reduced", Content = "Potato mode activated!", Type = "success" })
end })

-- ============================================================
--  UI – TAB MOVEMENT
-- ============================================================
local TabMove = Window:AddTab({ Name = "Movement", Icon = "user" })
local SubMove = TabMove:AddSubTab("Movement")
SubMove:AddSection("SPEED & JUMP")
SubMove:AddSlider({ Name = "WalkSpeed", Min = 16, Max = 200, Default = Settings.WalkSpeed, Callback = function(v) Settings.WalkSpeed = v; saveConfig() end })
SubMove:AddSlider({ Name = "JumpPower", Min = 50, Max = 250, Default = Settings.JumpPower, Callback = function(v) Settings.JumpPower = v; saveConfig() end })
SubMove:AddToggle({ Name = "Auto Jump", Default = Toggles.AutoJump, Callback = function(v) Toggles.AutoJump = v; saveConfig() end })
SubMove:AddToggle({ Name = "Bunny Hop", Default = Toggles.BunnyHop, Callback = function(v) Toggles.BunnyHop = v; saveConfig() end })
SubMove:AddToggle({ Name = "Fly", Default = Toggles.Fly, Callback = function(v) Toggles.Fly = v; saveConfig() end })
SubMove:AddSlider({ Name = "Fly Speed", Min = 10, Max = 200, Default = Settings.FlySpeed, Callback = function(v) Settings.FlySpeed = v; saveConfig() end })
SubMove:AddToggle({ Name = "Noclip", Default = Toggles.Noclip, Callback = function(v) Toggles.Noclip = v; saveConfig() end })
SubMove:AddToggle({ Name = "Anti-AFK", Default = Toggles.AntiAFK, Callback = function(v) Toggles.AntiAFK = v; saveConfig() end })

-- ============================================================
--  UI – TAB UTILITY
-- ============================================================
local TabUtil = Window:AddTab({ Name = "Utility", Icon = "settings" })

local SubKeys = TabUtil:AddSubTab("Keybinds")
SubKeys:AddSection("SET KEYBINDS")
SubKeys:AddKeybind({ Name = "Aimbot Toggle", Default = Keybinds.Aimbot, Callback = function(k) Keybinds.Aimbot = k; saveConfig() end })
SubKeys:AddKeybind({ Name = "Silent Aim Toggle", Default = Keybinds.Silent, Callback = function(k) Keybinds.Silent = k; saveConfig() end })
SubKeys:AddKeybind({ Name = "ESP Toggle", Default = Keybinds.ESP, Callback = function(k) Keybinds.ESP = k; saveConfig() end })
SubKeys:AddKeybind({ Name = "Triggerbot Toggle", Default = Keybinds.Triggerbot, Callback = function(k) Keybinds.Triggerbot = k; saveConfig() end })
SubKeys:AddKeybind({ Name = "Fly Toggle", Default = Keybinds.Fly, Callback = function(k) Keybinds.Fly = k; saveConfig() end })
SubKeys:AddKeybind({ Name = "Noclip Toggle", Default = Keybinds.Noclip, Callback = function(k) Keybinds.Noclip = k; saveConfig() end })

local SubConfig = TabUtil:AddSubTab("Save/Load")
SubConfig:AddSection("CONFIGURATION")
SubConfig:AddButton({ Name = "Save Config", Callback = function() saveConfig(); Window:Notify({ Title = "Config Saved", Content = "Saved to "..CONFIG_FILE, Type = "success" }) end })
SubConfig:AddButton({ Name = "Load Config", Callback = function() loadConfig(); Window:Notify({ Title = "Config Loaded", Content = "Settings restored!", Type = "success" }) end })
SubConfig:AddButton({ Name = "Reset Defaults", Callback = function()
    for k,v in pairs(Toggles) do Toggles[k] = false end
    Settings.Smoothness = 3; Settings.FovRadius = 150; Settings.TargetPart = "Head"; Settings.BulletSpeed = 950; Settings.PredFactor = 0.5; Settings.AimMode = "On Shoot"; Settings.WalkSpeed = 16; Settings.JumpPower = 50; Settings.FOVPosition = "Center"; Settings.TriggerbotDelay = 0.1; Settings.ChamsColor = Color3.fromRGB(255,0,0); Settings.BoxColor = Color3.fromRGB(255,255,255); Settings.TracerColor = Color3.fromRGB(0,255,0); Settings.FlySpeed = 50; Settings.RapidFireDelay = 0.05; Settings.HitSoundVolume = 0.5
    saveConfig()
    Window:Notify({ Title = "Defaults Reset", Content = "All settings reset", Type = "warning" })
end })

-- SubTab: Sounds
local SubSound = TabUtil:AddSubTab("Sounds")
SubSound:AddSection("HIT SOUND")
SubSound:AddToggle({ Name = "Enable Hit Sound", Default = Toggles.HitSound, Callback = function(v) Toggles.HitSound = v; saveConfig() end })
SubSound:AddSlider({ Name = "Volume", Min = 0, Max = 1, Default = Settings.HitSoundVolume, Callback = function(v) Settings.HitSoundVolume = v; saveConfig() end })

-- ============================================================
--  FUNGSI UTAMA
-- ============================================================

local function isAlive(char)
    local hum = char:FindFirstChildOfClass("Humanoid")
    return hum and hum.Health > 0
end

-- WALLCHECK MULTI-POINT
local function isVisible(character)
    if not Toggles.WallCheck then return true end
    if not character then return false end

    local parts = {
        character:FindFirstChild("Head"),
        character:FindFirstChild("UpperTorso") or character:FindFirstChild("HumanoidRootPart"),
        character:FindFirstChild("LowerTorso")
    }
    local origin = Camera.CFrame.Position
    local params = RaycastParams.new()
    params.FilterType = Enum.RaycastFilterType.Exclude
    params.FilterDescendantsInstances = {LocalPlayer.Character, Camera}

    for _, part in ipairs(parts) do
        if part then
            local ray = workspace:Raycast(origin, (part.Position - origin), params)
            if not ray then
                return true
            end
        end
    end
    return false
end

-- PEMILIHAN TARGET (berdasarkan FOV radius)
local function getBestTarget()
    local center = (Settings.FOVPosition == "Center") 
        and Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y/2) 
        or UserInputService:GetMouseLocation()
    
    local bestTarget = nil
    local bestScore = math.huge
    local maxDist = 5000

    for _, plr in pairs(Players:GetPlayers()) do
        if plr == LocalPlayer then continue end
        if not plr.Character or not isAlive(plr.Character) then continue end

        if Toggles.TeamCheck and plr.Team and LocalPlayer.Team and plr.Team == LocalPlayer.Team then
            continue
        end

        local root = plr.Character:FindFirstChild("HumanoidRootPart")
        if not root then continue end
        if not isVisible(plr.Character) then continue end

        local screenPos, onScreen = Camera:WorldToViewportPoint(root.Position)
        if not onScreen then continue end

        local fovDist = (Vector2.new(screenPos.X, screenPos.Y) - center).Magnitude
        if fovDist > Settings.FovRadius then continue end  -- range sesuai FOV

        local worldDist = (root.Position - Camera.CFrame.Position).Magnitude
        if worldDist > maxDist then continue end

        local score = (fovDist / Settings.FovRadius) + (worldDist / maxDist)
        if score < bestScore then
            bestScore = score
            bestTarget = root
        end
    end
    return bestTarget
end

-- PREDICTION
local function getBulletSpeed()
    local char = LocalPlayer.Character
    if not char then return Settings.BulletSpeed end
    local weapon = char:FindFirstChildOfClass("Tool")
    if weapon then
        local prop = weapon:FindFirstChild("BulletSpeed") or weapon:FindFirstChild("ProjectileSpeed") or weapon:FindFirstChild("Speed")
        if prop and type(prop.Value) == "number" and prop.Value > 0 then
            return prop.Value
        end
    end
    return Settings.BulletSpeed
end

local function predictPosition(targetPart)
    if not Toggles.Predict then return targetPart.Position end

    local origin = Camera.CFrame.Position
    local targetPos = targetPart.Position
    local velocity = targetPart.AssemblyLinearVelocity or Vector3.new()
    local bulletSpeed = getBulletSpeed()
    local dist = (origin - targetPos).Magnitude
    local timeToHit = dist / (bulletSpeed + 0.001)

    local predicted = targetPos + velocity * timeToHit * Settings.PredFactor

    if Toggles.GravityPred then
        local grav = workspace.Gravity * 0.5 * timeToHit^2
        predicted = predicted + Vector3.new(0, -grav, 0)
    end
    return predicted
end

-- ============================================================
--  SILENT AIM (via remote)
-- ============================================================
local function silentFire()
    if not Toggles.Silent then return end
    local target = getBestTarget()
    if not target then return end

    local origin = Camera.CFrame.Position
    local targetPos = predictPosition(target)
    local direction = (targetPos - origin).Unit

    local char = LocalPlayer.Character
    if char then
        local weapon = char:FindFirstChildOfClass("Tool")
        if weapon then
            local remote = ReplicatedStorage:FindFirstChild("Fire") or ReplicatedStorage:FindFirstChild("Shoot")
            if remote and remote:IsA("RemoteEvent") then
                remote:FireServer(direction)
                return
            end
        end
    end

    -- fallback
    local oldCF = Camera.CFrame
    local newCF = CFrame.new(origin, origin + direction * 100)
    Camera.CFrame = newCF
    task.wait(0.02)
    Camera.CFrame = oldCF
end

UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        if Toggles.Silent then
            silentFire()
        end
    end
end)

-- ============================================================
--  NO RECOIL / SPREAD
-- ============================================================
RunService.RenderStepped:Connect(function()
    if Toggles.NoRecoil or Toggles.NoSpread then
        local char = LocalPlayer.Character
        if char then
            local weapon = char:FindFirstChildOfClass("Tool")
            if weapon then
                pcall(function()
                    if Toggles.NoRecoil and weapon:FindFirstChild("Recoil") then
                        weapon.Recoil.Value = 0
                    end
                    if Toggles.NoSpread then
                        if weapon:FindFirstChild("Spread") then weapon.Spread.Value = 0 end
                        if weapon:FindFirstChild("Accuracy") then weapon.Accuracy.Value = 100 end
                    end
                end)
            end
        end
    end
end)

-- ============================================================
--  INFINITE AMMO
-- ============================================================
task.spawn(function()
    while task.wait(0.5) do
        if Toggles.InfAmmo then
            local char = LocalPlayer.Character
            if char then
                local weapon = char:FindFirstChildOfClass("Tool")
                if weapon then
                    pcall(function()
                        if weapon:FindFirstChild("Ammo") then weapon.Ammo.Value = weapon.MaxAmmo.Value end
                        if weapon:FindFirstChild("CurrentAmmo") then weapon.CurrentAmmo.Value = weapon.MaxAmmo.Value end
                    end)
                end
            end
        end
    end
end)

-- ============================================================
--  INSTANT RELOAD
-- ============================================================
task.spawn(function()
    while task.wait(0.1) do
        if Toggles.InstantReload then
            local char = LocalPlayer.Character
            if char then
                local weapon = char:FindFirstChildOfClass("Tool")
                if weapon then
                    local ammo = weapon:FindFirstChild("Ammo")
                    local maxAmmo = weapon:FindFirstChild("MaxAmmo")
                    local currentAmmo = weapon:FindFirstChild("CurrentAmmo")
                    if ammo and maxAmmo and ammo.Value < maxAmmo.Value then
                        ammo.Value = maxAmmo.Value
                        if currentAmmo then currentAmmo.Value = maxAmmo.Value end
                        local reloadEvent = weapon:FindFirstChild("Reload") or weapon:FindFirstChild("ReloadEvent")
                        if reloadEvent and reloadEvent:IsA("RemoteEvent") then
                            reloadEvent:FireServer()
                        end
                    end
                end
            end
        end
    end
end)

-- ============================================================
--  RAPID FIRE
-- ============================================================
local rapidFireActive = false

UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    if Toggles.RapidFire and input.UserInputType == Enum.UserInputType.MouseButton1 then
        rapidFireActive = true
        task.spawn(function()
            while rapidFireActive and Toggles.RapidFire do
                local char = LocalPlayer.Character
                if char then
                    local weapon = char:FindFirstChildOfClass("Tool")
                    if weapon then
                        weapon:Activate()
                        task.wait(Settings.RapidFireDelay)
                        weapon:Deactivate()
                        task.wait(Settings.RapidFireDelay)
                    end
                end
                task.wait()
            end
        end)
    end
end)

UserInputService.InputEnded:Connect(function(input, gameProcessed)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        rapidFireActive = false
    end
end)

-- ============================================================
--  HIT SOUND
-- ============================================================
local lastHealth = {}

task.spawn(function()
    while task.wait(0.1) do
        if Toggles.HitSound then
            for _, plr in pairs(Players:GetPlayers()) do
                if plr == LocalPlayer then continue end
                local char = plr.Character
                if char then
                    local hum = char:FindFirstChildOfClass("Humanoid")
                    if hum then
                        local current = hum.Health
                        local prev = lastHealth[plr] or current
                        if current < prev and current > 0 then
                            local sound = Instance.new("Sound")
                            sound.SoundId = "rbxassetid://9120390793"
                            sound.Volume = Settings.HitSoundVolume
                            sound.Parent = Camera
                            sound:Play()
                            game:GetService("Debris"):AddItem(sound, 0.5)
                        end
                        lastHealth[plr] = current
                    end
                end
            end
        end
    end
end)

-- ============================================================
--  FLY & NOCLIP
-- ============================================================
local flyBodyVelocity = nil
local function toggleFly()
    local char = LocalPlayer.Character
    if not char then return end
    local hum = char:FindFirstChildOfClass("Humanoid")
    if not hum then return end
    if Toggles.Fly then
        hum.PlatformStand = true
        flyBodyVelocity = Instance.new("BodyVelocity")
        flyBodyVelocity.MaxForce = Vector3.new(1e6,1e6,1e6)
        flyBodyVelocity.Velocity = Vector3.new(0,0,0)
        flyBodyVelocity.Parent = char:FindFirstChild("HumanoidRootPart")
    else
        if flyBodyVelocity then flyBodyVelocity:Destroy() end
        hum.PlatformStand = false
    end
end

local function toggleNoclip()
    pcall(function()
        local root = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
        if root then root.CanCollide = not Toggles.Noclip end
    end)
end

-- ============================================================
--  AUTO JUMP & BUNNY HOP
-- ============================================================
RunService.Heartbeat:Connect(function()
    local char = LocalPlayer.Character
    if not char then return end
    local hum = char:FindFirstChildOfClass("Humanoid")
    if not hum then return end

    if Toggles.AutoJump then
        if hum.MoveDirection.Magnitude > 0 and hum.FloorMaterial ~= Enum.Material.Air then
            hum.Jump = true
        end
    end

    if Toggles.BunnyHop then
        if hum.MoveDirection.Magnitude > 0 and hum.FloorMaterial == Enum.Material.Air then
            hum.Jump = true
        end
    end
end)

-- ============================================================
--  TRIGGERBOT
-- ============================================================
local triggerbotCooldown = false

local function triggerShoot(targetPart)
    if triggerbotCooldown then return end
    triggerbotCooldown = true

    local char = LocalPlayer.Character
    if char then
        local weapon = char:FindFirstChildOfClass("Tool")
        if weapon and weapon:FindFirstChild("Activate") then
            weapon:Activate()
            task.wait(Settings.TriggerbotDelay)
            weapon:Deactivate()
        end
    end

    task.wait(Settings.TriggerbotDelay)
    triggerbotCooldown = false
end

UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    if Toggles.Triggerbot and not Toggles.TriggerbotAuto then
        if input.UserInputType == Enum.UserInputType.MouseButton2 then
            local target = getBestTarget()
            if target then
                triggerShoot(target)
            end
        end
    end
end)

task.spawn(function()
    while task.wait(0.05) do
        if Toggles.Triggerbot and Toggles.TriggerbotAuto then
            local target = getBestTarget()
            if target then
                triggerShoot(target)
            end
        end
    end
end)

-- ============================================================
--  ESP
-- ============================================================
local ESPObjects = {}
local function updateESP()
    for _, obj in pairs(ESPObjects) do
        pcall(function() obj:Destroy() end)
    end
    ESPObjects = {}
    if not Toggles.ESP_Enabled then return end

    for _, plr in pairs(Players:GetPlayers()) do
        if plr == LocalPlayer then continue end
        local char = plr.Character
        if not char or not isAlive(char) then continue end
        local teamCheck = Toggles.TeamCheck and plr.Team == LocalPlayer.Team
        if teamCheck then continue end

        local root = char:FindFirstChild("HumanoidRootPart")
        local head = char:FindFirstChild("Head")
        if not root or not head then continue end

        local sPos, onScreen = Camera:WorldToViewportPoint(root.Position)
        if not onScreen then continue end
        local sHead, _ = Camera:WorldToViewportPoint(head.Position)
        local height = (sHead.Y - sPos.Y) * 1.5
        local width = height * 0.5
        local topLeft = Vector2.new(sPos.X - width/2, sHead.Y)
        local bottomRight = Vector2.new(sPos.X + width/2, sPos.Y)

        if Toggles.BoxESP then
            local box = Drawing.new("Square")
            box.Position = topLeft; box.Size = Vector2.new(width, height)
            box.Thickness = 1; box.Color = Settings.BoxColor
            box.Transparency = 0.5; box.Filled = false
            table.insert(ESPObjects, box)
        end

        if Toggles.HealthBar then
            local hum = char:FindFirstChildOfClass("Humanoid")
            if hum then
                local hp = hum.Health / hum.MaxHealth
                local bg = Drawing.new("Line")
                bg.From = Vector2.new(topLeft.X - 6, topLeft.Y)
                bg.To = Vector2.new(topLeft.X - 6, bottomRight.Y)
                bg.Color = Color3.fromRGB(50,50,50); bg.Thickness = 4
                table.insert(ESPObjects, bg)
                local fill = Drawing.new("Line")
                fill.From = Vector2.new(topLeft.X - 6, bottomRight.Y - (bottomRight.Y - topLeft.Y) * hp)
                fill.To = Vector2.new(topLeft.X - 6, bottomRight.Y)
                fill.Color = hp > 0.5 and Color3.fromRGB(0,255,0) or (hp > 0.25 and Color3.fromRGB(255,255,0) or Color3.fromRGB(255,0,0))
                fill.Thickness = 4
                table.insert(ESPObjects, fill)
            end
        end

        local name = Drawing.new("Text")
        name.Position = Vector2.new(sPos.X, sHead.Y - 20)
        name.Text = plr.Name; name.Size = 14
        name.Color = Color3.fromRGB(255,255,255)
        name.Center = true; name.Outline = true; name.OutlineColor = Color3.fromRGB(0,0,0)
        table.insert(ESPObjects, name)

        if Toggles.Tracers then
            local tracer = Drawing.new("Line")
            tracer.From = Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y)
            tracer.To = Vector2.new(sPos.X, sPos.Y)
            tracer.Color = Settings.TracerColor; tracer.Thickness = 1
            table.insert(ESPObjects, tracer)
        end

        if Toggles.Chams then
            local hl = char:FindFirstChildOfClass("Highlight") or Instance.new("Highlight", char)
            hl.Enabled = true; hl.FillColor = Settings.ChamsColor
            hl.OutlineTransparency = 0.5
            table.insert(ESPObjects, hl)
        end
    end
end

task.spawn(function()
    while task.wait(0.2) do pcall(updateESP) end
end)

-- ============================================================
--  FOV & CROSSHAIR DRAWING
-- ============================================================
local FOVCircle = Drawing.new("Circle")
FOVCircle.Thickness = 1.5
FOVCircle.Color = Color3.fromRGB(255,255,255)
FOVCircle.Transparency = 0.7
FOVCircle.NumSides = 64
FOVCircle.Filled = false
FOVCircle.Visible = false

local Crosshair = Drawing.new("Crosshair")
Crosshair.Color = Color3.fromRGB(255,255,255)
Crosshair.Thickness = 1
Crosshair.Size = 10
Crosshair.Visible = false

-- ============================================================
--  MAIN RENDER LOOP
-- ============================================================
RunService.RenderStepped:Connect(function(dt)
    pcall(function()
        -- FOV Circle (muncul jika di-toggle)
        if Toggles.FOV_Circle then
            FOVCircle.Visible = true
            FOVCircle.Radius = Settings.FovRadius
            FOVCircle.Position = (Settings.FOVPosition == "Center") and 
                Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y/2) or 
                UserInputService:GetMouseLocation()
        else
            FOVCircle.Visible = false
        end

        -- Crosshair
        Crosshair.Visible = Toggles.Crosshair
        if Crosshair.Visible then
            Crosshair.Position = Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y/2)
        end

        -- Aimbot (1 toggle + mode Always / On Shoot)
        if Toggles.Aimbot then
            local target = getBestTarget()
            local isShooting = (Settings.AimMode == "Always") or 
                               UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton1)
            if target and isShooting then
                local targetPos = predictPosition(target)
                local targetCF = CFrame.new(Camera.CFrame.Position, targetPos)
                Camera.CFrame = Camera.CFrame:Lerp(targetCF, 1 - math.exp(-Settings.Smoothness * dt * 2))
            end
        end

        -- Movement
        local char = LocalPlayer.Character
        if char and char:FindFirstChildOfClass("Humanoid") then
            char.Humanoid.WalkSpeed = Settings.WalkSpeed
            char.Humanoid.JumpPower = Settings.JumpPower
        end

        -- Fly
        if Toggles.Fly then
            if not flyBodyVelocity then toggleFly() end
            local moveDir = Vector3.new()
            if UserInputService:IsKeyDown(Enum.KeyCode.W) then moveDir = moveDir + Camera.CFrame.LookVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.S) then moveDir = moveDir - Camera.CFrame.LookVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.A) then moveDir = moveDir - Camera.CFrame.RightVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.D) then moveDir = moveDir + Camera.CFrame.RightVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.Space) then moveDir = moveDir + Vector3.new(0,1,0) end
            if UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) then moveDir = moveDir - Vector3.new(0,1,0) end
            if moveDir.Magnitude > 0 then
                moveDir = moveDir.Unit * Settings.FlySpeed
                if flyBodyVelocity then flyBodyVelocity.Velocity = moveDir end
            else
                if flyBodyVelocity then flyBodyVelocity.Velocity = Vector3.new(0,0,0) end
            end
        else
            if flyBodyVelocity then toggleFly() end
        end

        -- Noclip
        toggleNoclip()
    end)
end)

-- ============================================================
--  ANTI-AFK
-- ============================================================
LocalPlayer.Idled:Connect(function()
    if Toggles.AntiAFK then
        local randomWait = math.random(5, 15) / 10
        VirtualUser:Button2Down(Vector2.new(0,0), Camera.CFrame)
        task.wait(randomWait)
        VirtualUser:Button2Up(Vector2.new(0,0), Camera.CFrame)
    end
end)

-- ============================================================
--  KEYBINDS
-- ============================================================
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    if input.KeyCode == Keybinds.Aimbot then
        Toggles.Aimbot = not Toggles.Aimbot
        Window:Notify({Title="Aimbot", Content=tostring(Toggles.Aimbot), Type="info"})
        saveConfig()
    elseif input.KeyCode == Keybinds.Silent then
        Toggles.Silent = not Toggles.Silent
        Window:Notify({Title="Silent Aim", Content=tostring(Toggles.Silent), Type="info"})
        saveConfig()
    elseif input.KeyCode == Keybinds.ESP then
        Toggles.ESP_Enabled = not Toggles.ESP_Enabled
        Window:Notify({Title="ESP", Content=tostring(Toggles.ESP_Enabled), Type="info"})
        saveConfig()
    elseif input.KeyCode == Keybinds.Triggerbot then
        Toggles.Triggerbot = not Toggles.Triggerbot
        Window:Notify({Title="Triggerbot", Content=tostring(Toggles.Triggerbot), Type="info"})
        saveConfig()
    elseif input.KeyCode == Keybinds.Fly then
        Toggles.Fly = not Toggles.Fly
        Window:Notify({Title="Fly", Content=tostring(Toggles.Fly), Type="info"})
        toggleFly()
        saveConfig()
    elseif input.KeyCode == Keybinds.Noclip then
        Toggles.Noclip = not Toggles.Noclip
        Window:Notify({Title="Noclip", Content=tostring(Toggles.Noclip), Type="info"})
        toggleNoclip()
        saveConfig()
    end
end)

-- ============================================================
--  NOTIFIKASI AWAL
-- ============================================================
Window:Notify({
    Title = "W424 HUB",
    Content = "Arsenal ULTIMATE v5.6 (Sederhana + Lengkap) Loaded!",
    Type = "success",
    Duration = 4
})

print("✅ W424 HUB – Arsenal ULTIMATE v5.6 (Sederhana + Lengkap) loaded!")
