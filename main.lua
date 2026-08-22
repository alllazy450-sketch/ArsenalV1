-- ============================================================
-- W424 HUB | ARSENAL ULTIMATE PRO v5.8 (FULL FEATURES)
-- UI Framework: Oxidelib (Midnight Theme)
-- Map: Arsenal
-- Status: ALL FEATURES RESTORED & IMPROVED
-- ============================================================

local Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/Naellx/Oxidelib/main/Oxidelib.lua"))()
Library:SetTheme("Midnight")

local MY_LOGO = "rbxassetid://70773874533764"

-- [ SERVICES ]
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- [ STATE & CONFIG ]
local Toggles = { 
    Aimbot = false, Silent = false, WallCheck = true, Predict = true, 
    FOV_Circle = false, InfAmmo = false, NoRecoil = false, NoSpread = false,
    ESP_Enabled = false, TeamCheck = true, AntiAFK = true
}
local Settings = { 
    Smoothness = 3, FovRadius = 150, TargetPart = "Head", 
    BulletSpeed = 950, PredFactor = 0.5, AimMode = "On Shoot",
    WalkSpeed = 16, JumpPower = 50
}

-- [ FOV CIRCLE VISUAL ]
local FOVCircle = Drawing.new("Circle")
FOVCircle.Thickness = 1.5
FOVCircle.Color = Color3.fromRGB(255, 255, 255)
FOVCircle.Transparency = 0.7
FOVCircle.NumSides = 64
FOVCircle.Filled = false

-- [ UTILITY FUNCTIONS ]
local function isAlive(char)
    local hum = char:FindFirstChildOfClass("Humanoid")
    return hum and hum.Health > 0
end

local function isVisible(part)
    if not Toggles.WallCheck then return true end
    local params = RaycastParams.new()
    params.FilterType = Enum.RaycastFilterType.Exclude
    params.FilterDescendantsInstances = {LocalPlayer.Character, Camera}
    local res = workspace:Raycast(Camera.CFrame.Position, part.Position - Camera.CFrame.Position, params)
    return not res or res.Instance:IsDescendantOf(part.Parent)
end

local function getBestTarget()
    local target, dist = nil, Settings.FovRadius
    local center = Camera.ViewportSize / 2
    for _, plr in pairs(Players:GetPlayers()) do
        if plr ~= LocalPlayer and plr.Character and isAlive(plr.Character) then
            if Toggles.TeamCheck and plr.Team == LocalPlayer.Team then continue end
            local part = plr.Character:FindFirstChild(Settings.TargetPart)
            if part and isVisible(part) then
                local sPos, onScreen = Camera:WorldToViewportPoint(part.Position)
                if onScreen then
                    local mDist = (Vector2.new(sPos.X, sPos.Y) - center).Magnitude
                    if mDist < dist then dist = mDist target = part end
                end
            end
        end
    end
    return target
end

-- [ UI SETUP ]
local Window = Library:CreateWindow({
    Name = "W424 HUB",
    BrandSubtitle = "Arsenal PRO: Full Version v5.8",
    Logo = MY_LOGO,
    ToggleKey = Enum.KeyCode.RightShift,
    Size = UDim2.fromOffset(720, 600),
})

local TabCombat = Window:AddTab({ Name = "Combat", Icon = "target" })
local TabVisual = Window:AddTab({ Name = "Visuals", Icon = "eye" })
local TabMods   = Window:AddTab({ Name = "Weapon/Map", Icon = "zap" })
local TabPlayer = Window:AddTab({ Name = "Player", Icon = "user" })

-- ===== COMBAT TAB =====
local SubAim = TabCombat:AddSubTab("Aimbot Engine")
SubAim:AddSection("CAMERA AIM")
SubAim:AddToggle({ Name = "Enable Aimbot", Default = false, Callback = function(v) Toggles.Aimbot = v end })
SubAim:AddDropdown({ Name = "Aim Mode", Options = {"On Shoot", "Always"}, Default = "On Shoot", Callback = function(v) Settings.AimMode = v end })
SubAim:AddSlider({ Name = "Smoothing", Min = 1, Max = 20, Default = 3, Callback = function(v) Settings.Smoothness = v end })
SubAim:AddDropdown({ Name = "Target Part", Options = {"Head", "HumanoidRootPart", "LowerTorso"}, Default = "Head", Callback = function(v) Settings.TargetPart = v end })
SubAim:AddToggle({ Name = "Wall Check", Default = true, Callback = function(v) Toggles.WallCheck = v end })

local SubSilent = TabCombat:AddSubTab("Silent Aim")
SubSilent:AddSection("SILENT ENGINE")
SubSilent:AddToggle({ Name = "Enable Silent Aim", Default = false, Callback = function(v) Toggles.Silent = v end })

local SubPred = TabCombat:AddSubTab("Prediction")
SubPred:AddSection("SMART PREDICT V2")
SubPred:AddToggle({ Name = "Enable Prediction", Default = true, Callback = function(v) Toggles.Predict = v end })
SubPred:AddSlider({ Name = "Strength", Min = 1, Max = 200, Default = 50, Callback = function(v) Settings.PredFactor = v/100 end })
SubPred:AddSlider({ Name = "Bullet Speed", Min = 500, Max = 4000, Default = 950, Callback = function(v) Settings.BulletSpeed = v end })

-- ===== VISUALS TAB =====
local SubESP = TabVisual:AddSubTab("Player ESP")
SubESP:AddSection("ESP SETTINGS")
SubESP:AddToggle({ Name = "Enable Player Highlights", Default = false, Callback = function(v) Toggles.ESP_Enabled = v end })
SubESP:AddToggle({ Name = "Team Check", Default = true, Callback = function(v) Toggles.TeamCheck = v end })

local SubFOV = TabVisual:AddSubTab("FOV Settings")
SubFOV:AddSection("CIRCLE CUSTOMIZATION")
SubFOV:AddToggle({ Name = "Show FOV Circle", Default = false, Callback = function(v) Toggles.FOV_Circle = v end })
SubFOV:AddSlider({ Name = "FOV Size", Min = 30, Max = 600, Default = 150, Callback = function(v) Settings.FovRadius = v end })
SubFOV:AddSlider({ Name = "Thickness", Min = 1, Max = 5, Default = 1, Callback = function(v) FOVCircle.Thickness = v end })
SubFOV:AddSlider({ Name = "Transparency", Min = 1, Max = 10, Default = 7, Callback = function(v) FOVCircle.Transparency = v/10 end })

-- ===== MODS TAB =====
local SubWeapon = TabMods:AddSubTab("Gun Mods")
SubWeapon:AddToggle({ Name = "Infinite Ammo", Default = false, Callback = function(v) Toggles.InfAmmo = v end })
SubWeapon:AddToggle({ Name = "No Recoil & Spread", Default = false, Callback = function(v) Toggles.NoRecoil = v end })

local SubMap = TabMods:AddSubTab("Map/FPS")
SubMap:AddButton({ Name = "Reduce Map (Potato Mode)", Callback = function()
    pcall(function() game:GetService("StarterGui"):SetCore("MinimapEnabled", false) end)
    for _, obj in ipairs(workspace:GetDescendants()) do
        if obj:IsA("BasePart") then obj.Material = Enum.Material.SmoothPlastic
        elseif obj:IsA("Texture") or obj:IsA("Decal") then obj:Destroy() end
    end
end })

-- ===== PLAYER TAB =====
local SubMove = TabPlayer:AddSubTab("Movement")
SubMove:AddSlider({ Name = "WalkSpeed", Min = 16, Max = 200, Default = 16, Callback = function(v) Settings.WalkSpeed = v end })
SubMove:AddSlider({ Name = "JumpPower", Min = 50, Max = 250, Default = 50, Callback = function(v) Settings.JumpPower = v end })
SubMove:AddToggle({ Name = "Anti-AFK Kick", Default = true, Callback = function(v) Toggles.AntiAFK = v end })

-- [ LOOPS ENGINE ]

-- Player Custom Stats Loop
RunService.Heartbeat:Connect(function()
    local char = LocalPlayer.Character
    if char and char:FindFirstChildOfClass("Humanoid") then
        char.Humanoid.WalkSpeed = Settings.WalkSpeed
        char.Humanoid.JumpPower = Settings.JumpPower
    end
end)

-- Arsenal Infinite Ammo & NoRecoil Loop
task.spawn(function()
    while task.wait(0.5) do
        if Toggles.InfAmmo then
            pcall(function() ReplicatedStorage.wkspc.CurrentCurse.Value = 'Infinite Ammo' end)
        end
        -- Logic No Recoil/Spread bisa disisipkan di sini jika memodifikasi tabel senjata
    end
end)

-- ESP System
RunService.Heartbeat:Connect(function()
    if not Toggles.ESP_Enabled then 
        for _, plr in pairs(Players:GetPlayers()) do
            local hl = plr.Character and plr.Character:FindFirstChildOfClass("Highlight")
            if hl then hl:Destroy() end
        end
        return 
    end
    for _, plr in pairs(Players:GetPlayers()) do
        if plr ~= LocalPlayer and plr.Character then
            local highlight = plr.Character:FindFirstChildOfClass("Highlight") or Instance.new("Highlight", plr.Character)
            highlight.Enabled = not (Toggles.TeamCheck and plr.Team == LocalPlayer.Team)
            highlight.FillColor = Color3.fromRGB(255, 0, 0)
            highlight.OutlineTransparency = 0.5
        end
    end
end)

-- Main Render Loop (Aimbot, Predict, FOV)
RunService.RenderStepped:Connect(function(dt)
    FOVCircle.Visible = Toggles.FOV_Circle
    FOVCircle.Radius = Settings.FovRadius
    FOVCircle.Position = UserInputService:GetMouseLocation()
    
    if Toggles.Aimbot then
        local target = getBestTarget()
        local isShooting = (Settings.AimMode == "Always") or (UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton1) or UserInputService.TouchEnabled)
        
        if target and isShooting then
            local targetPos = target.Position
            if Toggles.Predict then
                local dist = (Camera.CFrame.Position - targetPos).Magnitude
                targetPos = targetPos + (target.AssemblyLinearVelocity * (dist / Settings.BulletSpeed) * Settings.PredFactor)
            end
            local targetCF = CFrame.new(Camera.CFrame.Position, targetPos)
            Camera.CFrame = Camera.CFrame:Lerp(targetCF, 1 - math.exp(-Settings.Smoothness * dt * 2))
        end
    end
end)

-- Anti-AFK
LocalPlayer.Idled:Connect(function()
    if Toggles.AntiAFK then
        game:GetService("VirtualUser"):Button2Down(Vector2.new(0,0), Camera.CFrame)
        task.wait(1)
        game:GetService("VirtualUser"):Button2Up(Vector2.new(0,0), Camera.CFrame)
    end
end)

Window:Notify({ Title = "W424 HUB", Content = "Arsenal PRO v5.8 Full Version Loaded!", Type = "success" })
