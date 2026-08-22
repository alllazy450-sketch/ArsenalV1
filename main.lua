-- ============================================================
--  W424HUB v6.0 – Gabungan Source Old + Fitur Baru
--  Oxidelib UI | Aimbot, Silent, Trigger, Wallbang, ESP,
--  BunnyHop, InstantReload, RapidFire, HitSound, dll.
-- ============================================================

-- [LOAD UI LIBRARY] – Oxidelib
local Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/Naellx/Oxidelib/main/Oxidelib.lua"))()
if not Library then return warn("Oxidelib gagal dimuat") end

Library:SetTheme("Ocean")

local MY_LOGO = "rbxassetid://70773874533764" -- ganti jika perlu

local Window = Library:CreateWindow({
    Name = "W424 HUB",
    BrandSubtitle = "Arsenal ULTIMATE v6.0",
    Logo = MY_LOGO,
    LogoZoom = 1.5,
    ToggleKey = Enum.KeyCode.RightShift,
    ProfileKey = Enum.KeyCode.K,
    Size = UDim2.fromOffset(800, 650),
    LoadingText = "W424 HUB",
    LoadingSubtitle = "Loading v6.0...",
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
local CoreGui = game:GetService("CoreGui")
local VirtualInputManager = game:GetService("VirtualInputManager")
local Mouse = LocalPlayer:GetMouse()

-- ============================================================
--  KONVERSI WARNA (untuk save/load)
-- ============================================================
local function color3ToTable(c) return {R=c.R, G=c.G, B=c.B} end
local function tableToColor3(t) return Color3.new(t.R, t.G, t.B) end

-- ============================================================
--  STATE & CONFIG
-- ============================================================
local Toggles = {
    -- Aimbot
    Aimbot = false,
    FOV_Circle = false,
    UseTeamCheck = true,
    UseVisibilityCheck = true,
    HeadshotOnly = false,
    SilentAim = false,
    Wallbang = false,
    Triggerbot = false,
    TriggerbotAuto = false,
    TriggerDebug = false,
    Prediction = true,
    GravityPred = false,

    -- Weapon Mods
    NoRecoil = false,
    NoSpread = false,
    InfiniteAmmo = false,
    FastFire = false,
    FastReload = false,
    ArsenalNoRecoil = false,
    ArsenalNoSpread = false,
    InstantReload = false,
    RapidFire = false,

    -- Movement
    Fly = false,
    Noclip = false,
    AutoJump = false,
    BunnyHop = false,
    AntiAFK = false,

    -- Visual
    ESP_Enabled = false,
    Stats_Enabled = false,
    ReduceMap = false,
    Crosshair = false,

    -- Sound
    HitSound = false,
}

local Settings = {
    -- Aimbot
    TargetPart = "Head",
    AimSmoothness = 3,
    FovRadius = 150,
    MaxAimDistance = 400,
    HitboxExpansion = 0,
    TargetPriority = "FOV",
    AimTrigger = "On Shoot", -- "On Shoot" or "Always"

    -- Silent
    SilentFOV = 200,
    SilentDistance = 400,
    SilentTargetPart = "Head",
    SilentPredFactor = 0.3,

    -- Trigger
    TriggerDelay = 0.08,
    TriggerFOV = 35,
    TriggerHeadshotOnly = false,
    BurstShots = 3,
    BurstDelay = 0.03,
    TriggerMethod = "Remote",

    -- Prediction
    PredictionFactor = 0.3,
    BulletSpeed = 800,

    -- Movement
    WalkSpeed = 16,
    JumpPower = 50,
    FlySpeed = 50,

    -- Visual
    ESPColor = Color3.fromRGB(255,0,0),
    ESPTransparency = 0.3,
    ESPTeamCheck = true,

    -- Sound
    HitSoundVolume = 0.5,

    -- Rapid Fire
    RapidFireDelay = 0.05,
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
local CONFIG_FILE = "W424_v6_Config.json"
local function saveConfig()
    local data = {
        Toggles = Toggles,
        Settings = {
            TargetPart = Settings.TargetPart,
            AimSmoothness = Settings.AimSmoothness,
            FovRadius = Settings.FovRadius,
            MaxAimDistance = Settings.MaxAimDistance,
            HitboxExpansion = Settings.HitboxExpansion,
            TargetPriority = Settings.TargetPriority,
            AimTrigger = Settings.AimTrigger,
            SilentFOV = Settings.SilentFOV,
            SilentDistance = Settings.SilentDistance,
            SilentTargetPart = Settings.SilentTargetPart,
            SilentPredFactor = Settings.SilentPredFactor,
            TriggerDelay = Settings.TriggerDelay,
            TriggerFOV = Settings.TriggerFOV,
            TriggerHeadshotOnly = Settings.TriggerHeadshotOnly,
            BurstShots = Settings.BurstShots,
            BurstDelay = Settings.BurstDelay,
            TriggerMethod = Settings.TriggerMethod,
            PredictionFactor = Settings.PredictionFactor,
            BulletSpeed = Settings.BulletSpeed,
            WalkSpeed = Settings.WalkSpeed,
            JumpPower = Settings.JumpPower,
            FlySpeed = Settings.FlySpeed,
            ESPColor = color3ToTable(Settings.ESPColor),
            ESPTransparency = Settings.ESPTransparency,
            ESPTeamCheck = Settings.ESPTeamCheck,
            HitSoundVolume = Settings.HitSoundVolume,
            RapidFireDelay = Settings.RapidFireDelay,
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
            if k == "ESPColor" then Settings.ESPColor = tableToColor3(v)
            else Settings[k] = v end
        end
        for k,v in pairs(data.Keybinds) do Keybinds[k] = v end
    end
end
loadConfig()

-- ============================================================
--  UI – TABS & SUBTABS
-- ============================================================

-- ===== TAB COMBAT =====
local TabCombat = Window:AddTab({ Name = "Combat", Icon = "target" })

-- SubTab: Aimbot
local SubAim = TabCombat:AddSubTab("Aimbot")
SubAim:AddSection("MAIN AIMBOT")
SubAim:AddToggle({ Name = "Enable Aimbot", Default = Toggles.Aimbot, Callback = function(v) Toggles.Aimbot = v; saveConfig() end })
SubAim:AddDropdown({ Name = "Trigger", Options = {"On Shoot","Always"}, Default = Settings.AimTrigger, Callback = function(v) Settings.AimTrigger = v; saveConfig() end })
SubAim:AddSlider({ Name = "Smoothness", Min = 1, Max = 10, Default = Settings.AimSmoothness, Callback = function(v) Settings.AimSmoothness = v; saveConfig() end })
SubAim:AddDropdown({ Name = "Target Part", Options = {"Head","HumanoidRootPart","UpperTorso","Torso"}, Default = Settings.TargetPart, Callback = function(v) Settings.TargetPart = v; saveConfig() end })
SubAim:AddSlider({ Name = "FOV Radius", Min = 30, Max = 400, Default = Settings.FovRadius, Callback = function(v) Settings.FovRadius = v; saveConfig() end })
SubAim:AddSlider({ Name = "Max Distance", Min = 50, Max = 500, Default = Settings.MaxAimDistance, Callback = function(v) Settings.MaxAimDistance = v; saveConfig() end })
SubAim:AddToggle({ Name = "Team Check", Default = Toggles.UseTeamCheck, Callback = function(v) Toggles.UseTeamCheck = v; saveConfig() end })
SubAim:AddToggle({ Name = "Visibility Check", Default = Toggles.UseVisibilityCheck, Callback = function(v) Toggles.UseVisibilityCheck = v; saveConfig() end })
SubAim:AddToggle({ Name = "Headshot Only", Default = Toggles.HeadshotOnly, Callback = function(v) Toggles.HeadshotOnly = v; saveConfig() end })
SubAim:AddSlider({ Name = "Hitbox Expansion", Min = 0, Max = 5, Default = Settings.HitboxExpansion, Callback = function(v) Settings.HitboxExpansion = v; saveConfig() end })
SubAim:AddDropdown({ Name = "Target Priority", Options = {"FOV","Distance"}, Default = Settings.TargetPriority, Callback = function(v) Settings.TargetPriority = v; saveConfig() end })

-- SubTab: Silent Aim
local SubSilent = TabCombat:AddSubTab("Silent Aim")
SubSilent:AddSection("SILENT AIM (hook 'cast')")
SubSilent:AddToggle({ Name = "Enable Silent Aim", Default = Toggles.SilentAim, Callback = function(v) Toggles.SilentAim = v; saveConfig() end })
SubSilent:AddSlider({ Name = "FOV", Min = 30, Max = 400, Default = Settings.SilentFOV, Callback = function(v) Settings.SilentFOV = v; saveConfig() end })
SubSilent:AddSlider({ Name = "Distance", Min = 50, Max = 500, Default = Settings.SilentDistance, Callback = function(v) Settings.SilentDistance = v; saveConfig() end })
SubSilent:AddDropdown({ Name = "Target Part", Options = {"Head","HumanoidRootPart","UpperTorso","Torso"}, Default = Settings.SilentTargetPart, Callback = function(v) Settings.SilentTargetPart = v; saveConfig() end })
SubSilent:AddToggle({ Name = "Wallbang", Default = Toggles.Wallbang, Callback = function(v) Toggles.Wallbang = v; saveConfig() end })
SubSilent:AddToggle({ Name = "Team Check", Default = Toggles.UseTeamCheck, Callback = function(v) Toggles.UseTeamCheck = v; saveConfig() end })

-- SubTab: Triggerbot
local SubTrigger = TabCombat:AddSubTab("Triggerbot")
SubTrigger:AddSection("AUTO SHOOT")
SubTrigger:AddToggle({ Name = "Enable Triggerbot", Default = Toggles.Triggerbot, Callback = function(v) Toggles.Triggerbot = v; saveConfig() end })
SubTrigger:AddToggle({ Name = "Auto Mode (hold/toggle)", Default = Toggles.TriggerbotAuto, Callback = function(v) Toggles.TriggerbotAuto = v; saveConfig() end })
SubTrigger:AddSlider({ Name = "Delay (sec)", Min = 0.01, Max = 0.5, Default = Settings.TriggerDelay, Callback = function(v) Settings.TriggerDelay = v; saveConfig() end })
SubTrigger:AddSlider({ Name = "FOV (pixels)", Min = 5, Max = 100, Default = Settings.TriggerFOV, Callback = function(v) Settings.TriggerFOV = v; saveConfig() end })
SubTrigger:AddToggle({ Name = "Headshot Only", Default = Settings.TriggerHeadshotOnly, Callback = function(v) Settings.TriggerHeadshotOnly = v; saveConfig() end })
SubTrigger:AddToggle({ Name = "Aggressive Mode (spam)", Default = false, Callback = function(v)
    if v then
        Settings.TriggerDelay = 0.01
        Settings.TriggerFOV = math.max(Settings.TriggerFOV, 40)
        Window:Notify({Title="Aggressive ON", Content="Spam mode active", Type="warning"})
    else
        Settings.TriggerDelay = 0.08
        Window:Notify({Title="Aggressive OFF", Content="Normal mode", Type="info"})
    end
    saveConfig()
end })
SubTrigger:AddSlider({ Name = "Burst Shots", Min = 1, Max = 10, Default = Settings.BurstShots, Callback = function(v) Settings.BurstShots = v; saveConfig() end })
SubTrigger:AddSlider({ Name = "Burst Delay", Min = 0.01, Max = 0.1, Default = Settings.BurstDelay, Callback = function(v) Settings.BurstDelay = v; saveConfig() end })
SubTrigger:AddDropdown({ Name = "Trigger Method", Options = {"Remote","MouseClick"}, Default = Settings.TriggerMethod, Callback = function(v) Settings.TriggerMethod = v; saveConfig() end })
SubTrigger:AddToggle({ Name = "Trigger Debug", Default = Toggles.TriggerDebug, Callback = function(v) Toggles.TriggerDebug = v; saveConfig() end })

-- SubTab: Prediction
local SubPred = TabCombat:AddSubTab("Prediction")
SubPred:AddSection("PREDICTION")
SubPred:AddToggle({ Name = "Enable Prediction", Default = Toggles.Prediction, Callback = function(v) Toggles.Prediction = v; saveConfig() end })
SubPred:AddToggle({ Name = "Gravity Prediction", Default = Toggles.GravityPred, Callback = function(v) Toggles.GravityPred = v; saveConfig() end })
SubPred:AddSlider({ Name = "Prediction Factor", Min = 0, Max = 100, Default = Settings.PredictionFactor*100, Callback = function(v) Settings.PredictionFactor = v/100; saveConfig() end })
SubPred:AddSlider({ Name = "Bullet Speed", Min = 500, Max = 1500, Default = Settings.BulletSpeed, Callback = function(v) Settings.BulletSpeed = v; saveConfig() end })

-- ===== TAB WEAPON =====
local TabWeapon = Window:AddTab({ Name = "Weapon", Icon = "zap" })
local SubWeapon = TabWeapon:AddSubTab("Gun Mods")
SubWeapon:AddSection("CAMERA MODS")
SubWeapon:AddToggle({ Name = "No Recoil (Camera)", Default = Toggles.NoRecoil, Callback = function(v) Toggles.NoRecoil = v; saveConfig() end })
SubWeapon:AddToggle({ Name = "No Spread", Default = Toggles.NoSpread, Callback = function(v) Toggles.NoSpread = v; saveConfig() end })
SubWeapon:AddToggle({ Name = "Infinite Ammo", Default = Toggles.InfiniteAmmo, Callback = function(v) Toggles.InfiniteAmmo = v; saveConfig() end })
SubWeapon:AddToggle({ Name = "Fast Fire Rate", Default = Toggles.FastFire, Callback = function(v) Toggles.FastFire = v; saveConfig() end })
SubWeapon:AddToggle({ Name = "Fast Reload", Default = Toggles.FastReload, Callback = function(v) Toggles.FastReload = v; saveConfig() end })
SubWeapon:AddToggle({ Name = "Instant Reload", Default = Toggles.InstantReload, Callback = function(v) Toggles.InstantReload = v; saveConfig() end })
SubWeapon:AddToggle({ Name = "Rapid Fire", Default = Toggles.RapidFire, Callback = function(v) Toggles.RapidFire = v; saveConfig() end })
SubWeapon:AddSlider({ Name = "Rapid Fire Delay", Min = 0.01, Max = 0.2, Default = Settings.RapidFireDelay, Callback = function(v) Settings.RapidFireDelay = v; saveConfig() end })

-- ===== TAB MOVEMENT =====
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

-- ===== TAB VISUALS =====
local TabVisual = Window:AddTab({ Name = "Visuals", Icon = "eye" })
local SubESP = TabVisual:AddSubTab("ESP")
SubESP:AddSection("ESP HIGHLIGHT")
SubESP:AddToggle({ Name = "Enable ESP", Default = Toggles.ESP_Enabled, Callback = function(v) Toggles.ESP_Enabled = v; saveConfig() end })
SubESP:AddColorPicker({ Name = "ESP Color", Default = Settings.ESPColor, Callback = function(c)
    if type(c)=="table" and c.R and c.G and c.B then Settings.ESPColor = Color3.new(c.R,c.G,c.B)
    else Settings.ESPColor = c end
    saveConfig()
end })
SubESP:AddSlider({ Name = "Transparency", Min = 0, Max = 10, Default = Settings.ESPTransparency*10, Callback = function(v) Settings.ESPTransparency = v/10; saveConfig() end })
SubESP:AddToggle({ Name = "Team Check", Default = Settings.ESPTeamCheck, Callback = function(v) Settings.ESPTeamCheck = v; saveConfig() end })

local SubFOV = TabVisual:AddSubTab("FOV & Crosshair")
SubFOV:AddSection("FOV CIRCLE")
SubFOV:AddToggle({ Name = "Show FOV Circle", Default = Toggles.FOV_Circle, Callback = function(v) Toggles.FOV_Circle = v; saveConfig() end })
SubFOV:AddSlider({ Name = "FOV Size", Min = 30, Max = 400, Default = Settings.FovRadius, Callback = function(v) Settings.FovRadius = v; saveConfig() end })
SubFOV:AddSection("CROSSHAIR")
SubFOV:AddToggle({ Name = "Show Crosshair", Default = Toggles.Crosshair, Callback = function(v) Toggles.Crosshair = v; saveConfig() end })

-- ===== TAB UTILITY =====
local TabUtil = Window:AddTab({ Name = "Utility", Icon = "settings" })

-- SubTab: Reduce Map & Stats
local SubMisc = TabUtil:AddSubTab("Misc")
SubMisc:AddSection("OPTIMIZATION")
SubMisc:AddToggle({ Name = "Reduce Map (hide minimap)", Default = Toggles.ReduceMap, Callback = function(v)
    Toggles.ReduceMap = v
    if v then
        pcall(function() StarterGui:SetCore("MinimapEnabled", false) end)
        -- juga cari GUI minimap
        for _, gui in ipairs(CoreGui:GetChildren()) do
            if gui:IsA("ScreenGui") and (gui.Name:lower():find("minimap") or gui.Name:lower():find("map")) then
                gui.Visible = false
            end
        end
    else
        pcall(function() StarterGui:SetCore("MinimapEnabled", true) end)
    end
    saveConfig()
end })
SubMisc:AddToggle({ Name = "FPS & Ping Stats", Default = Toggles.Stats_Enabled, Callback = function(v) Toggles.Stats_Enabled = v; saveConfig() end })

-- SubTab: Sounds
local SubSound = TabUtil:AddSubTab("Sounds")
SubSound:AddSection("HIT SOUND")
SubSound:AddToggle({ Name = "Enable Hit Sound", Default = Toggles.HitSound, Callback = function(v) Toggles.HitSound = v; saveConfig() end })
SubSound:AddSlider({ Name = "Volume", Min = 0, Max = 1, Default = Settings.HitSoundVolume, Callback = function(v) Settings.HitSoundVolume = v; saveConfig() end })

-- SubTab: Keybinds
local SubKeys = TabUtil:AddSubTab("Keybinds")
SubKeys:AddSection("KEYBINDS")
SubKeys:AddKeybind({ Name = "Aimbot Toggle", Default = Keybinds.Aimbot, Callback = function(k) Keybinds.Aimbot = k; saveConfig() end })
SubKeys:AddKeybind({ Name = "Silent Aim Toggle", Default = Keybinds.Silent, Callback = function(k) Keybinds.Silent = k; saveConfig() end })
SubKeys:AddKeybind({ Name = "ESP Toggle", Default = Keybinds.ESP, Callback = function(k) Keybinds.ESP = k; saveConfig() end })
SubKeys:AddKeybind({ Name = "Triggerbot Toggle", Default = Keybinds.Triggerbot, Callback = function(k) Keybinds.Triggerbot = k; saveConfig() end })
SubKeys:AddKeybind({ Name = "Fly Toggle", Default = Keybinds.Fly, Callback = function(k) Keybinds.Fly = k; saveConfig() end })
SubKeys:AddKeybind({ Name = "Noclip Toggle", Default = Keybinds.Noclip, Callback = function(k) Keybinds.Noclip = k; saveConfig() end })

-- SubTab: Config
local SubConfig = TabUtil:AddSubTab("Save/Load")
SubConfig:AddSection("CONFIGURATION")
SubConfig:AddButton({ Name = "Save Config", Callback = function() saveConfig(); Window:Notify({Title="Config Saved", Content="Saved to "..CONFIG_FILE, Type="success"}) end })
SubConfig:AddButton({ Name = "Load Config", Callback = function() loadConfig(); Window:Notify({Title="Config Loaded", Content="Settings restored!", Type="success"}) end })
SubConfig:AddButton({ Name = "Reset Defaults", Callback = function()
    for k,v in pairs(Toggles) do Toggles[k] = false end
    Settings.TargetPart = "Head"; Settings.AimSmoothness = 3; Settings.FovRadius = 150; Settings.MaxAimDistance = 400; Settings.HitboxExpansion = 0; Settings.TargetPriority = "FOV"; Settings.AimTrigger = "On Shoot"
    Settings.SilentFOV = 200; Settings.SilentDistance = 400; Settings.SilentTargetPart = "Head"; Settings.SilentPredFactor = 0.3
    Settings.TriggerDelay = 0.08; Settings.TriggerFOV = 35; Settings.TriggerHeadshotOnly = false; Settings.BurstShots = 3; Settings.BurstDelay = 0.03; Settings.TriggerMethod = "Remote"
    Settings.PredictionFactor = 0.3; Settings.BulletSpeed = 800
    Settings.WalkSpeed = 16; Settings.JumpPower = 50; Settings.FlySpeed = 50
    Settings.ESPColor = Color3.fromRGB(255,0,0); Settings.ESPTransparency = 0.3; Settings.ESPTeamCheck = true
    Settings.HitSoundVolume = 0.5; Settings.RapidFireDelay = 0.05
    saveConfig()
    Window:Notify({Title="Defaults Reset", Content="All settings reset", Type="warning"})
end })

-- ============================================================
--  FUNGSI UTAMA (diambil dari source old)
-- ============================================================

-- Helper
local function isAlive(char)
    local hum = char:FindFirstChildOfClass("Humanoid")
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
    if not Toggles.UseVisibilityCheck then return true end
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
--  AIMBOT CORE (dari source old)
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

        if Toggles.UseTeamCheck and myTeam and player.Team == myTeam then
            continue
        end

        local part = getPart(char, Settings.TargetPart, Toggles.HeadshotOnly)
        if not part then continue end

        local targetPos = part.Position
        local dist = (targetPos - myPos).Magnitude
        if dist > Settings.MaxAimDistance then continue end

        if Settings.HitboxExpansion > 0 and part.Name == "Head" then
            targetPos = targetPos + (part.CFrame.UpVector * Settings.HitboxExpansion * 0.15)
        end

        local screenPos, onScreen = Camera:WorldToViewportPoint(targetPos)
        if not onScreen then continue end
        local center = Camera.ViewportSize / 2
        local screenDist = (Vector2.new(screenPos.X, screenPos.Y) - center).Magnitude
        if screenDist > Settings.FovRadius then continue end

        -- Prediction
        local predictedPos = targetPos
        if Toggles.Prediction then
            local hrp = char:FindFirstChild("HumanoidRootPart")
            if hrp then
                local vel = hrp.Velocity or Vector3.new()
                local travelTime = dist / Settings.BulletSpeed
                local predFactor = Settings.PredictionFactor * travelTime
                predictedPos = targetPos + vel * predFactor
                if Toggles.GravityPred then
                    local grav = workspace.Gravity * 0.5 * travelTime^2
                    predictedPos = predictedPos + Vector3.new(0, -grav, 0)
                end
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

    if Settings.TargetPriority == "FOV" then
        table.sort(targets, function(a, b) return a.ScreenDist < b.ScreenDist end)
    else
        table.sort(targets, function(a, b) return a.WorldDist < b.WorldDist end)
    end

    return targets[1]
end

-- ============================================================
--  SILENT AIM (hook 'cast') dari source old
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

        if Toggles.UseTeamCheck and myTeam and player.Team == myTeam then continue end

        local part = getPart(char, Settings.SilentTargetPart, false)
        if not part then continue end

        local targetPos = part.Position
        local dist = (targetPos - myPos).Magnitude
        if dist > Settings.SilentDistance then continue end

        if not Toggles.Wallbang then
            if not isVisible(Camera.CFrame.Position, targetPos, {myChar}) then
                continue
            end
        end

        local screenPos, onScreen = Camera:WorldToViewportPoint(targetPos)
        if not onScreen then continue end
        local center = Camera.ViewportSize / 2
        local screenDist = (Vector2.new(screenPos.X, screenPos.Y) - center).Magnitude
        if screenDist > Settings.SilentFOV then continue end

        -- Prediction
        if Toggles.Prediction then
            local hrp = char:FindFirstChild("HumanoidRootPart")
            if hrp then
                local vel = hrp.Velocity or Vector3.new()
                local travelTime = dist / Settings.BulletSpeed
                local predFactor = Settings.SilentPredFactor * travelTime
                targetPos = targetPos + vel * predFactor
                if Toggles.GravityPred then
                    local grav = workspace.Gravity * 0.5 * travelTime^2
                    targetPos = targetPos + Vector3.new(0, -grav, 0)
                end
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
        Window:Notify({Title="Silent Aim Error", Content="Fungsi 'cast' tidak ditemukan", Type="error"})
        return
    end
    silentOriginalCast = castTable.cast
    if not silentOriginalCast then return end
    silentHookActive = true
    castTable.cast = function(p1, p2, p3)
        if Toggles.SilentAim then
            local best = getSilentTargets()
            if best then
                return best.Part, best.Position, Vector3.new(0,1,0), best.Part.Material
            end
        end
        return silentOriginalCast(p1, p2, p3)
    end
    Window:Notify({Title="Silent Aim", Content="Hook installed!", Type="success"})
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
    Window:Notify({Title="Silent Aim", Content="Hook removed", Type="info"})
end

-- ============================================================
--  WALLBANG HOOK (mirip silent)
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
        Window:Notify({Title="Wallbang Error", Content="Fungsi 'cast' tidak ditemukan", Type="error"})
        return
    end
    wallbangOriginalCast = castTable.cast
    if not wallbangOriginalCast then return end
    wallbangHookActive = true
    castTable.cast = function(p1, p2, p3)
        if Toggles.Wallbang then
            local best = getBestTarget()
            if best then
                return best.Part, best.Position, Vector3.new(0,1,0), best.Part.Material
            end
        end
        return wallbangOriginalCast(p1, p2, p3)
    end
    Window:Notify({Title="Wallbang", Content="Hook installed!", Type="success"})
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
    Window:Notify({Title="Wallbang", Content="Hook removed", Type="info"})
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
    if Settings.TriggerMethod == "Remote" then
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

    if not success or Settings.TriggerMethod == "MouseClick" then
        pcall(function()
            VirtualInputManager:SendMouseButtonEvent(Enum.UserInputType.MouseButton1, 0, true, game, 0)
            task.wait(0.01)
            VirtualInputManager:SendMouseButtonEvent(Enum.UserInputType.MouseButton1, 0, false, game, 0)
            success = true
        end)
    end

    if Toggles.TriggerDebug and success then
        Window:Notify({Title="Trigger", Content="Shot fired!", Type="info", Duration=0.5})
    end
end

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

        if Toggles.FastFire then
            if weapon:FindFirstChild("FireRate") then weapon.FireRate.Value = 0.01 end
            if weapon:FindFirstChild("BFireRate") then weapon.BFireRate.Value = 0.01 end
        else
            if weapon:FindFirstChild("FireRate") and defaults.FireRate then weapon.FireRate.Value = defaults.FireRate end
            if weapon:FindFirstChild("BFireRate") and defaults.BFireRate then weapon.BFireRate.Value = defaults.BFireRate end
        end

        if Toggles.FastReload then
            if weapon:FindFirstChild("ReloadTime") then weapon.ReloadTime.Value = 0.01 end
        else
            if weapon:FindFirstChild("ReloadTime") and defaults.ReloadTime then weapon.ReloadTime.Value = defaults.ReloadTime end
        end

        if Toggles.ArsenalNoRecoil then
            if weapon:FindFirstChild("RecoilControl") then weapon.RecoilControl.Value = 0 end
        else
            if weapon:FindFirstChild("RecoilControl") and defaults.RecoilControl then weapon.RecoilControl.Value = defaults.RecoilControl end
        end

        if Toggles.ArsenalNoSpread then
            if weapon:FindFirstChild("MaxSpread") then weapon.MaxSpread.Value = 0.01 end
            if weapon:FindFirstChild("SpreadRecovery") then weapon.SpreadRecovery.Value = 0.01 end
        else
            if weapon:FindFirstChild("MaxSpread") and defaults.MaxSpread then weapon.MaxSpread.Value = defaults.MaxSpread end
            if weapon:FindFirstChild("SpreadRecovery") and defaults.SpreadRecovery then weapon.SpreadRecovery.Value = defaults.SpreadRecovery end
        end
    end
end

-- ============================================================
--  INJECT FITUR BARU (BunnyHop, InstantReload, RapidFire, HitSound, dll)
-- ============================================================

-- Bunny Hop & Auto Jump di Heartbeat
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

-- Instant Reload
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

-- Rapid Fire
local rapidFireActive = false
UserInputService.InputBegan:Connect(function(input)
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
UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        rapidFireActive = false
    end
end)

-- Hit Sound
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
                            sound.SoundId = "rbxassetid://9120390793" -- ganti dengan suara favorit
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

-- Fly & Noclip
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
--  ESP HIGHLIGHT
-- ============================================================
local highlightObjects = {}

local function clearESP()
    for _, h in pairs(highlightObjects) do
        pcall(function() h:Destroy() end)
    end
    highlightObjects = {}
end

local function updateESP()
    if not Toggles.ESP_Enabled then
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
        if Settings.ESPTeamCheck and LocalPlayer.Team and player.Team == LocalPlayer.Team then
            if highlightObjects[player] then
                highlightObjects[player].Enabled = false
            end
            continue
        end

        if not highlightObjects[player] then
            local highlight = Instance.new("Highlight")
            highlight.Parent = char
            highlight.FillColor = Settings.ESPColor
            highlight.OutlineColor = Settings.ESPColor
            highlight.FillTransparency = Settings.ESPTransparency
            highlight.OutlineTransparency = 0.5
            highlight.Enabled = true
            highlightObjects[player] = highlight
        else
            highlightObjects[player].Parent = char
            highlightObjects[player].FillColor = Settings.ESPColor
            highlightObjects[player].FillTransparency = Settings.ESPTransparency
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

Players.PlayerAdded:Connect(function() task.wait(0.5); updateESP() end)
Players.PlayerRemoving:Connect(function(player)
    if highlightObjects[player] then
        highlightObjects[player]:Destroy()
        highlightObjects[player] = nil
    end
end)
RunService.RenderStepped:Connect(updateESP)

-- ============================================================
--  FPS & PING STATS
-- ============================================================
local statsGui = Instance.new("ScreenGui")
statsGui.Name = "W424_STATS"
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
    if Toggles.Stats_Enabled then
        frameCount = frameCount + 1
        timeAcc = timeAcc + dt
        if timeAcc >= 1 then
            local ping = 0
            pcall(function() ping = LocalPlayer:GetNetworkPing() * 1000 end)
            statsText.Text = string.format(" FPS:%d  Ping:%.0fms", frameCount, ping)
            frameCount = 0
            timeAcc = 0
        end
        statsFrame.Visible = true
    else
        statsFrame.Visible = false
    end
end)

-- ============================================================
--  FOV CIRCLE & CROSSHAIR
-- ============================================================
local fovGui = Instance.new("ScreenGui")
fovGui.Name = "W424_FOV"
fovGui.Parent = CoreGui
fovGui.ResetOnSpawn = false
fovGui.IgnoreGuiInset = true

local fovFrame = Instance.new("Frame")
fovFrame.BackgroundTransparency = 1
fovFrame.AnchorPoint = Vector2.new(0.5, 0.5)
fovFrame.Position = UDim2.new(0.5, 0, 0.5, 0)
fovFrame.Size = UDim2.new(0, Settings.FovRadius * 2, 0, Settings.FovRadius * 2)
fovFrame.Visible = false
fovFrame.Parent = fovGui
Instance.new("UIStroke", fovFrame).Color = Color3.fromRGB(255,255,255)
Instance.new("UICorner", fovFrame).CornerRadius = UDim.new(1,0)

local function updateFOVSize()
    fovFrame.Size = UDim2.new(0, Settings.FovRadius * 2, 0, Settings.FovRadius * 2)
end

-- Crosshair
local crosshairGui = Instance.new("ScreenGui")
crosshairGui.Name = "W424_CROSSHAIR"
crosshairGui.Parent = CoreGui
crosshairGui.ResetOnSpawn = false

local crosshairFrame = Instance.new("Frame")
crosshairFrame.Size = UDim2.new(0, 20, 0, 20)
crosshairFrame.Position = UDim2.new(0.5, -10, 0.5, -10)
crosshairFrame.BackgroundTransparency = 1
crosshairFrame.Visible = false
crosshairFrame.Parent = crosshairGui

-- Garis crosshair sederhana
local function makeLine(pos, size, color)
    local line = Instance.new("Frame")
    line.Size = size
    line.Position = pos
    line.BackgroundColor3 = color
    line.BackgroundTransparency = 0
    line.Parent = crosshairFrame
    return line
end
makeLine(UDim2.new(0.5, -8, 0, 8), UDim2.new(0, 16, 0, 2), Color3.fromRGB(255,255,255))
makeLine(UDim2.new(0, 8, 0.5, -8), UDim2.new(0, 2, 0, 16), Color3.fromRGB(255,255,255))

-- ============================================================
--  MAIN LOOP (Aimbot, Triggerbot, Movement, dll)
-- ============================================================
local triggerLastShot = 0

RunService.RenderStepped:Connect(function(dt)
    pcall(function()
        -- FOV Circle
        if Toggles.FOV_Circle then
            fovFrame.Visible = true
            fovFrame.Size = UDim2.new(0, Settings.FovRadius * 2, 0, Settings.FovRadius * 2)
        else
            fovFrame.Visible = false
        end

        -- Crosshair
        crosshairFrame.Visible = Toggles.Crosshair

        -- Aimbot
        local best = nil
        if Toggles.Aimbot or Toggles.Triggerbot or Toggles.Wallbang then
            best = getBestTarget()
        end

        if Toggles.Aimbot and best then
            local canAim = (Settings.AimTrigger == "Always") or (Settings.AimTrigger == "On Shoot" and isShooting)
            if canAim then
                local targetPos = best.Position
                local currentCF = Camera.CFrame
                local targetCF = CFrame.new(currentCF.Position, targetPos)
                local smooth = 1 - math.exp(-(Settings.AimSmoothness/10) * dt * 10)
                Camera.CFrame = currentCF:Lerp(targetCF, smooth)
            end
        end

        -- Triggerbot
        if Toggles.Triggerbot and best then
            local screenPos, onScreen = Camera:WorldToViewportPoint(best.Position)
            if onScreen then
                local center = Camera.ViewportSize / 2
                local dist = (Vector2.new(screenPos.X, screenPos.Y) - center).Magnitude
                local currentFOV = Settings.TriggerFOV
                if dist < currentFOV then
                    if Settings.TriggerHeadshotOnly and best.Part.Name ~= "Head" then
                        return
                    end
                    local now = tick()
                    local delay = Settings.TriggerDelay
                    if now - triggerLastShot >= delay then
                        triggerLastShot = now
                        local shots = Settings.BurstShots
                        for i = 1, shots do
                            fireShot(best.Position)
                            if i < shots then task.wait(Settings.BurstDelay) end
                        end
                    end
                end
            end
        end

        -- Movement
        local char = LocalPlayer.Character
        if char then
            local hum = char:FindFirstChildOfClass("Humanoid")
            if hum then
                hum.WalkSpeed = Settings.WalkSpeed
                hum.JumpPower = Settings.JumpPower
            end
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
--  PLAYER MODS LOOP (No Recoil, No Spread, Infinite Ammo, dll)
-- ============================================================
task.spawn(function()
    while true do
        pcall(function()
            local char = LocalPlayer.Character
            if not char then task.wait(1) return end
            local hum = char:FindFirstChildOfClass("Humanoid")
            if not hum then task.wait(1) return end

            if Toggles.AntiAFK then
                local hrp = char:FindFirstChild("HumanoidRootPart")
                if hrp then
                    hrp.CFrame = hrp.CFrame * CFrame.Angles(0, math.rad(1), 0)
                    hrp.Velocity = Vector3.new(math.random(-1,1), 0, math.random(-1,1))
                end
            end

            local tool = char:FindFirstChildOfClass("Tool")
            if tool then
                if Toggles.NoRecoil then
                    for _, prop in ipairs({"Recoil","recoil","Kickback","GunRecoil","Shake","CameraRecoil"}) do
                        local success, val = pcall(function() return tool[prop] end)
                        if success and val ~= nil and type(val) == "number" then tool[prop] = 0 end
                    end
                    if tool:FindFirstChild("Recoil") and tool.Recoil:IsA("NumberValue") then tool.Recoil.Value = 0 end
                end
                if Toggles.NoSpread then
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
                        if Toggles.NoRecoil and (name:find("recoil") or name:find("kick") or name:find("shake")) then child.Value = 0 end
                        if Toggles.NoSpread and (name:find("spread") or name:find("inaccuracy") or name:find("accuracy") or name:find("deviation")) then child.Value = 0 end
                    end
                end
            end

            -- Infinite Ammo
            if Toggles.InfiniteAmmo then
                if tool then
                    for _, child in ipairs(tool:GetDescendants()) do
                        if child:IsA("NumberValue") or child:IsA("IntValue") or child:IsA("FloatValue") then
                            local name = child.Name:lower()
                            if name:find("ammo") or name:find("clip") or name:find("mag") then
                                child.Value = 999
                            end
                        end
                    end
                end
            end

            -- Arsenal Weapon Mods (Fast Fire, Fast Reload, No Recoil, No Spread)
            applyWeaponMods()
        end)
        task.wait(0.2)
    end
end)

-- ============================================================
--  SILENT & WALLBANG HOOK ACTIVATION
-- ============================================================
task.spawn(function()
    while not ReplicatedStorage do task.wait() end
    -- Silent Aim
    if Toggles.SilentAim then
        setupSilentHook()
    end
    -- Wallbang
    if Toggles.Wallbang then
        setupWallbangHook()
    end
    -- Auto apply weapon mods saat weapon ditambahkan
    if Weapons then
        Weapons.ChildAdded:Connect(applyWeaponMods)
        for _, weapon in ipairs(Weapons:GetChildren()) do
            weapon.ChildAdded:Connect(applyWeaponMods)
        end
    end
end)

-- ============================================================
--  KEYBINDS
-- ============================================================
UserInputService.InputBegan:Connect(function(input, gp)
    if gp then return end
    if input.KeyCode == Keybinds.Aimbot then
        Toggles.Aimbot = not Toggles.Aimbot
        Window:Notify({Title="Aimbot", Content=tostring(Toggles.Aimbot), Type="info"})
        saveConfig()
    elseif input.KeyCode == Keybinds.Silent then
        Toggles.SilentAim = not Toggles.SilentAim
        if Toggles.SilentAim then setupSilentHook() else removeSilentHook() end
        Window:Notify({Title="Silent Aim", Content=tostring(Toggles.SilentAim), Type="info"})
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
--  ANTI-AFK (VirtualUser)
-- ============================================================
LocalPlayer.Idled:Connect(function()
    if Toggles.AntiAFK then
        VirtualUser:Button2Down(Vector2.new(0,0), Camera.CFrame)
        task.wait(0.5)
        VirtualUser:Button2Up(Vector2.new(0,0), Camera.CFrame)
    end
end)

-- ============================================================
--  NOTIFIKASI AWAL
-- ============================================================
Window:Notify({
    Title = "W424 HUB v6.0",
    Content = "Gabungan Source Old + Fitur Baru Loaded!",
    Type = "success",
    Duration = 4
})

print("✅ W424 HUB v6.0 loaded – gabungan source old + fitur baru")
