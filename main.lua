-- ============================================================
-- W424 HUB | ARSENAL v5.6 (SMART INTEGRATED)
-- UI Framework: Oxidelib
-- Features: Wall Check, Velocity Predict, Reduce Map Fix
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
local Toggles = { Aimbot = false, Silent = false, WallCheck = true, Predict = true, FOV_Circle = false, ArsenalMods = false }
local Settings = { Smoothness = 3, FovRadius = 150, TargetPart = "Head", BulletSpeed = 900, PredFactor = 0.5 }

-- [ FUNCTIONS ]
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
            if plr.Team == LocalPlayer.Team then continue end
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
    BrandSubtitle = "Arsenal: Aim & Predict v5.6",
    Logo = MY_LOGO,
    ToggleKey = Enum.KeyCode.RightShift,
    Size = UDim2.fromOffset(720, 550),
})

local TabAim = Window:AddTab({ Name = "Aim", Icon = "target" })
local TabPred = Window:AddTab({ Name = "Predict", Icon = "trending-up" })
local TabMods = Window:AddTab({ Name = "Mods", Icon = "zap" })

-- ===== AIM TAB =====
local SubAim = TabAim:AddSubTab("Aimbot")
SubAim:AddSection("CAMERA AIM")
SubAim:AddToggle({ Name = "Enable Aimbot", Default = false, Callback = function(v) Toggles.Aimbot = v end })
SubAim:AddSlider({ Name = "Smoothness", Min = 1, Max = 10, Default = 3, Callback = function(v) Settings.Smoothness = v end })
SubAim:AddDropdown({ Name = "Target Part", Options = {"Head", "HumanoidRootPart", "LowerTorso"}, Default = "Head", Callback = function(v) Settings.TargetPart = v end })

SubAim:AddSection("SILENT AIM")
SubAim:AddToggle({ Name = "Enable Silent Aim", Default = false, Callback = function(v) Toggles.Silent = v end })

-- ===== PREDICT TAB =====
local SubPred = TabPred:AddSubTab("Engine")
SubPred:AddToggle({ Name = "Enable Prediction", Default = true, Callback = function(v) Toggles.Predict = v end })
SubPred:AddSlider({ Name = "Prediction Power", Min = 1, Max = 100, Default = 50, Callback = function(v) Settings.PredFactor = v/100 end })
SubPred:AddSlider({ Name = "Bullet Speed", Min = 500, Max = 3000, Default = 900, Callback = function(v) Settings.BulletSpeed = v end })

-- ===== MODS TAB =====
local SubMods = TabMods:AddSubTab("Weapon Mods")
SubMods:AddToggle({ Name = "Infinite Ammo", Default = false, Callback = function(v) 
    if v then pcall(function() ReplicatedStorage.wkspc.CurrentCurse.Value = 'Infinite Ammo' end) end 
end })
SubMods:AddButton({ Name = "Reduce Map (FPS Boost)", Callback = function()
    pcall(function() game:GetService("StarterGui"):SetCore("MinimapEnabled", false) end)
end })

-- [ LOOPS ]
RunService.RenderStepped:Connect(function(dt)
    if Toggles.Aimbot then
        local target = getBestTarget()
        if target and (UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton1) or UserInputService.TouchEnabled) then
            local pos = target.Position
            if Toggles.Predict then
                local time = (Camera.CFrame.Position - pos).Magnitude / Settings.BulletSpeed
                pos = pos + (target.AssemblyLinearVelocity * time * Settings.PredFactor)
            end
            local targetCF = CFrame.new(Camera.CFrame.Position, pos)
            Camera.CFrame = Camera.CFrame:Lerp(targetCF, 1 - math.exp(-Settings.Smoothness * dt * 2))
        end
    end
end)

Window:Notify({ Title = "W424 HUB", Content = "Arsenal PRO Loaded!", Type = "success" })
