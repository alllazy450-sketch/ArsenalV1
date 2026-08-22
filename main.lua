-- ============================================================
-- W424 HUB | ARSENAL ULTIMATE PRO v5.7 (SMART INTEGRATED)
-- UI Framework: Oxidelib (Midnight Theme)
-- Map: Arsenal
-- Features: Wall Check, Smart Predict v2, Arsenal Mods, FPS Boost
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
    Aimbot = false, 
    WallCheck = true, 
    Predict = true, 
    FOV_Circle = false, 
    InfAmmo = false,
    FastFire = false,
    TeamCheck = true
}
local Settings = { 
    Smoothness = 3, 
    FovRadius = 150, 
    TargetPart = "Head", 
    BulletSpeed = 900, 
    PredFactor = 0.5 
}

-- [ FOV CIRCLE VISUAL ]
local FOVCircle = Drawing.new("Circle")
FOVCircle.Thickness = 1.5
FOVCircle.Color = Color3.fromRGB(255, 255, 255)
FOVCircle.Transparency = 0.7
FOVCircle.NumSides = 64

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
                    if mDist < dist then
                        dist = mDist
                        target = part
                    end
                end
            end
        end
    end
    return target
end

-- [ UI SETUP ]
local Window = Library:CreateWindow({
    Name = "W424 HUB",
    BrandSubtitle = "Arsenal PRO: Ultimate v5.7",
    Logo = MY_LOGO,
    ToggleKey = Enum.KeyCode.RightShift,
    Size = UDim2.fromOffset(720, 600),
})

local TabAim = Window:AddTab({ Name = "Aimbot", Icon = "target" })
local TabMods = Window:AddTab({ Name = "Weapon/Map", Icon = "zap" })
local TabVis = Window:AddTab({ Name = "Visuals", Icon = "eye" })

-- ===== AIM TAB =====
local SubAim = TabAim:AddSubTab("Engine")
SubAim:AddSection("MAIN AIMBOT")
SubAim:AddToggle({ Name = "Enable Aimbot", Default = false, Callback = function(v) Toggles.Aimbot = v end })
SubAim:AddToggle({ Name = "Wall Check (Visible Only)", Default = true, Callback = function(v) Toggles.WallCheck = v end })
SubAim:AddSlider({ Name = "Smoothing", Min = 1, Max = 20, Default = 3, Callback = function(v) Settings.Smoothness = v end })
SubAim:AddDropdown({ Name = "Target Part", Options = {"Head", "HumanoidRootPart", "LowerTorso"}, Default = "Head", Callback = function(v) Settings.TargetPart = v end })

local SubPred = TabAim:AddSubTab("Prediction")
SubPred:AddSection("SMART PREDICT V2")
SubPred:AddToggle({ Name = "Enable Velocity Predict", Default = true, Callback = function(v) Toggles.Predict = v end })
SubPred:AddSlider({ Name = "Predict Strength", Min = 1, Max = 200, Default = 50, Callback = function(v) Settings.PredFactor = v/100 end })
SubPred:AddSlider({ Name = "Bullet Speed Simulator", Min = 500, Max = 4000, Default = 950, Callback = function(v) Settings.BulletSpeed = v end })

-- ===== MODS TAB =====
local SubWeapon = TabMods:AddSubTab("Weapon Mods")
SubWeapon:AddToggle({ Name = "Infinite Ammo (Curse)", Default = false, Callback = function(v) 
    Toggles.InfAmmo = v
end })
SubWeapon:AddToggle({ Name = "Fast Fire Rate", Default = false, Callback = function(v) Toggles.FastFire = v end })

local SubMap = TabMods:AddSubTab("Map/FPS")
SubMap:AddButton({ Name = "Reduce Map (Anti-Lag)", Callback = function()
    pcall(function() game:GetService("StarterGui"):SetCore("MinimapEnabled", false) end)
    for _, obj in ipairs(workspace:GetDescendants()) do
        if obj:IsA("BasePart") then obj.Material = Enum.Material.SmoothPlastic
        elseif obj:IsA("Texture") or obj:IsA("Decal") then obj:Destroy() end
    end
end })

-- ===== VISUALS TAB =====
local SubVisual = TabVis:AddSubTab("Overlays")
SubVisual:AddToggle({ Name = "Show FOV Circle", Default = false, Callback = function(v) Toggles.FOV_Circle = v end })
SubVisual:AddSlider({ Name = "FOV Size", Min = 30, Max = 500, Default = 150, Callback = function(v) Settings.FovRadius = v end })
SubVisual:AddToggle({ Name = "Team Check", Default = true, Callback = function(v) Toggles.TeamCheck = v end })

-- [ LOOPS ]

-- Arsenal Specific: Infinite Ammo Loop
task.spawn(function()
    while task.wait(0.5) do
        if Toggles.InfAmmo then
            pcall(function()
                ReplicatedStorage.wkspc.CurrentCurse.Value = 'Infinite Ammo'
            end)
        end
    end
end)

-- Main Render Loop
RunService.RenderStepped:Connect(function(dt)
    -- 1. Update FOV Circle
    FOVCircle.Visible = Toggles.FOV_Circle
    FOVCircle.Radius = Settings.FovRadius
    FOVCircle.Position = UserInputService:GetMouseLocation()
    
    -- 2. Aimbot & Prediction Logic
    if Toggles.Aimbot then
        local target = getBestTarget()
        -- Trigger: Mouse1 pressed or Touch screen
        local isShooting = UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton1) or UserInputService.TouchEnabled
        
        if target and isShooting then
            local targetPos = target.Position
            
            -- Smart Prediction Calculation
            if Toggles.Predict then
                local distance = (Camera.CFrame.Position - targetPos).Magnitude
                local timeToHit = distance / Settings.BulletSpeed
                local velocity = target.AssemblyLinearVelocity
                targetPos = targetPos + (velocity * timeToHit * Settings.PredFactor)
            end
            
            -- Smooth Camera Movement (Exponential Smoothing)
            local targetCF = CFrame.new(Camera.CFrame.Position, targetPos)
            local smoothAlpha = 1 - math.exp(-Settings.Smoothness * dt * 2)
            Camera.CFrame = Camera.CFrame:Lerp(targetCF, smoothAlpha)
        end
    end
end)

Window:Notify({ Title = "W424 HUB", Content = "Arsenal Ultimate v5.7 Loaded!", Type = "success" })
