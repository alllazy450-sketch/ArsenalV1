-- ============================================================
--  W424HUB ULTIMATE IMPROVEMENT v5.4
--  Optimized Performance | Smart Prediction | Wall Check
-- ============================================================

-- [BOOTSTRAP & UI SETUP]
local function instanceLoading()
    local gui = Instance.new("ScreenGui", game:GetService("CoreGui"))
    local label = Instance.new("TextLabel", gui)
    label.Size = UDim2.fromOffset(300, 50)
    label.Position = UDim2.fromScale(0.5, 0.5)
    label.AnchorPoint = Vector2.new(0.5, 0.5)
    label.BackgroundTransparency = 1
    label.TextColor3 = Color3.fromRGB(0, 255, 150)
    label.TextSize = 20
    label.Text = "Applying Smart Improvements..."
    return function() gui:Destroy() end
end
local dismiss = instanceLoading()

-- [SERVICES]
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- [UI LIBRARY]
local repo = 'https://raw.githubusercontent.com/deividcomsono/Obsidian/main/'
local Library = loadstring(game:HttpGet(repo .. 'Library.lua'))()
local Options = Library.Options
local Toggles = Library.Toggles

local Window = Library:CreateWindow({
    Title = 'W424HUB v5.4 | Smart Integrated',
    Footer = 'Optimized for Mobile & PC',
    Center = true,
    AutoShow = true,
    Size = UDim2.fromOffset(750, 650),
})

-- [TABS]
local Tabs = {
    Combat = Window:AddTab('aim & predict', 'swords'),
    AutoFarm = Window:AddTab('greedy growers', 'leaf'),
    Visuals = Window:AddTab('visuals', 'eye'),
    Character = Window:AddTab('character', 'user'),
    Misc = Window:AddTab('misc', 'sparkles'),
}

-- [PRE-REQUISITES: FOV CIRCLE]
local FOVCircle = Drawing.new("Circle")
FOVCircle.Visible = false
FOVCircle.Thickness = 1.5
FOVCircle.Color = Color3.fromRGB(0, 255, 255)
FOVCircle.Transparency = 0.8
FOVCircle.NumSides = 60

-- ============================================================
--  UTILITY FUNCTIONS (IMPROVED)
-- ============================================================
local function isAlive(char)
    local hum = char:FindFirstChildOfClass("Humanoid")
    return hum and hum.Health > 0
end

-- Wall Check (Mengecek apakah target terhalang tembok)
local function isVisible(part)
    if not Toggles.WallCheck.Value then return true end
    local castPoints = {Camera.CFrame.Position, part.Position}
    local params = RaycastParams.new()
    params.FilterType = Enum.RaycastFilterType.Exclude
    params.FilterDescendantsInstances = {LocalPlayer.Character, Camera}
    
    local result = workspace:Raycast(castPoints[1], castPoints[2] - castPoints[1], params)
    return not result or result.Instance:IsDescendantOf(part.Parent)
end

-- Velocity Prediction (Memprediksi posisi jalan musuh)
local function getPredictedPosition(part)
    if not Toggles.UsePrediction.Value then return part.Position end
    local velocity = part.AssemblyLinearVelocity
    local distance = (Camera.CFrame.Position - part.Position).Magnitude
    local bulletSpeed = Options.BulletSpeed.Value or 800
    local timeToHit = distance / bulletSpeed
    
    return part.Position + (velocity * timeToHit * Options.PredFactor.Value)
end

-- Cari Target Terbaik
local function getBestTarget()
    local target, minDist = nil, Options.FovRadius.Value
    local center = Camera.ViewportSize / 2
    
    for _, plr in ipairs(Players:GetPlayers()) do
        if plr ~= LocalPlayer and plr.Character and isAlive(plr.Character) then
            if Toggles.TeamCheck.Value and plr.Team == LocalPlayer.Team then continue end
            
            local part = plr.Character:FindFirstChild(Options.TargetPart.Value) or plr.Character.PrimaryPart
            if part and isVisible(part) then
                local screenPos, onScreen = Camera:WorldToViewportPoint(part.Position)
                if onScreen then
                    local dist = (Vector2.new(screenPos.X, screenPos.Y) - center).Magnitude
                    if dist < minDist then
                        minDist = dist
                        target = part
                    end
                end
            end
        end
    end
    return target
end

-- ============================================================
--  SECTION: COMBAT (SMOOTH AIM + PREDICT)
-- ============================================================
local AimGroup = Tabs.Combat:AddLeftGroupbox("advanced aimbot")
AimGroup:AddToggle("AimbotEnable", {Text = "enable aimbot", Default = false})
AimGroup:AddToggle("WallCheck", {Text = "wall check (anti-wall)", Default = true})
AimGroup:AddDropdown("TargetPart", {Text = "hit part", Default = "Head", Values = {"Head", "HumanoidRootPart", "Torso"}})
AimGroup:AddSlider("AimSmoothness", {Text = "smoothness", Default = 3, Min = 1, Max = 10, Rounding = 1})

local PredGroup = Tabs.Combat:AddRightGroupbox("prediction engine")
PredGroup:AddToggle("UsePrediction", {Text = "enable prediction", Default = true})
PredGroup:AddSlider("PredFactor", {Text = "prediction power", Default = 0.5, Min = 0.1, Max = 2, Rounding = 2})
PredGroup:AddSlider("BulletSpeed", {Text = "simulated bullet speed", Default = 900, Min = 100, Max = 3000})

local FovGroup = Tabs.Combat:AddLeftGroupbox("visuals")
FovGroup:AddToggle("FovCircle", {Text = "show fov circle", Default = false})
FovGroup:AddSlider("FovRadius", {Text = "fov size", Default = 150, Min = 30, Max = 500})
FovGroup:AddToggle("TeamCheck", {Text = "team check", Default = true})

-- ============================================================
--  SECTION: GREEDY GROWERS (SMART FARM)
-- ============================================================
local GGEngine = { FarmRunning = false, PlantDied = false, Remote = {} }
local SEEDS = {"Oak","Pine","Apple","Peach","Fig","Orange","Lemon","Avocado","Cherry","Mango","Coconut","Banana","Starfruit","Dragon Fruit","Void"}

-- Initialize Remotes
task.spawn(function()
    local KnitServices
    repeat pcall(function() KnitServices = ReplicatedStorage.Packages._Index["sleitnick_knit@1.6.0"].knit.Services end); task.wait(1) until KnitServices
    local function sg(fn) local ok,r = pcall(fn); if ok then return r end end
    GGEngine.Remote.StartRound = sg(function() return KnitServices.PlantRoundService.RF.StartRound end)
    GGEngine.Remote.CollectDeadTree = sg(function() return KnitServices.PlantRoundService.RF.CollectDeadTree end)
    GGEngine.Remote.SellAll = sg(function() return KnitServices.SellStandService.RF.SellAll end)
    GGEngine.Remote.ToggleEquip = sg(function() return KnitServices.ToolService.RE.ToggleEquip end)
end)

local GGFarm = Tabs.AutoFarm:AddLeftGroupbox("smart farming")
GGFarm:AddToggle("AutoFarmEnable", {Text = "enable smart farm", Default = false})
GGFarm:AddDropdown("SelectedSeed", {Text = "seed type", Default = "Oak", Values = SEEDS})
GGFarm:AddSlider("GrowthMaxWait", {Text = "max wait (safety)", Default = 20, Min = 5, Max = 60})

-- Smart Farm Loop (No more static wait)
task.spawn(function()
    while true do task.wait(0.5)
        if Toggles.AutoFarmEnable.Value and not GGEngine.FarmRunning then
            GGEngine.FarmRunning = true
            if GGEngine.Remote.StartRound then
                -- Step 1: Equip
                pcall(function() GGEngine.Remote.ToggleEquip:FireServer(true, Options.SeedSlot and Options.SeedSlot.Value or 1) end)
                task.wait(0.3)
                -- Step 2: Plant
                pcall(function() GGEngine.Remote.StartRound:InvokeServer(Options.SelectedSeed.Value, "Basic") end)
                
                -- Step 3: Smart Wait (Menunggu sampai mati atau mencapai batas waktu)
                local start = tick()
                GGEngine.PlantDied = false
                repeat task.wait(0.5) 
                until GGEngine.PlantDied or (tick() - start > Options.GrowthMaxWait.Value)
                
                -- Step 4: Harvest & Sell
                pcall(function() GGEngine.Remote.CollectDeadTree:InvokeServer() end)
                if Toggles.AutoSell and Toggles.AutoSell.Value then 
                    task.wait(0.5)
                    pcall(function() GGEngine.Remote.SellAll:InvokeServer() end) 
                end
            end
            GGEngine.FarmRunning = false
        end
    end
end)

-- ============================================================
--  MAIN UNIFIED LOOP (OPTIMIZED)
-- ============================================================
RunService.RenderStepped:Connect(function(dt)
    -- 1. FOV Visual Update
    FOVCircle.Visible = Toggles.FovCircle.Value
    FOVCircle.Radius = Options.FovRadius.Value
    FOVCircle.Position = UserInputService:GetMouseLocation()

    -- 2. Aimbot Logic
    if Toggles.AimbotEnable.Value then
        local best = getBestTarget()
        if best then
            local isPressed = UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton1) or UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton2)
            if isPressed or UserInputService.TouchEnabled then
                local predictedPos = getPredictedPosition(best)
                local targetCF = CFrame.new(Camera.CFrame.Position, predictedPos)
                -- Exponential Smoothing
                local smooth = 1 - math.exp(-(Options.AimSmoothness.Value) * dt * 2)
                Camera.CFrame = Camera.CFrame:Lerp(targetCF, smooth)
            end
        end
    end
end)

-- ============================================================
--  ADDITIONAL FEATURES (POTATO, AFK, ETC)
-- ============================================================
local VisGroup = Tabs.Visuals:AddLeftGroupbox("optimization")
VisGroup:AddButton("Potato Mode (No Lag)", function()
    for _, obj in ipairs(workspace:GetDescendants()) do
        if obj:IsA("BasePart") then obj.Material = Enum.Material.SmoothPlastic
        elseif obj:IsA("Texture") or obj:IsA("Decal") then obj:Destroy() end
    end
end)

local MiscGroup = Tabs.Misc:AddLeftGroupbox("anti-afk & system")
MiscGroup:AddToggle("AntiAFK", {Text = "anti afk kick", Default = true})
task.spawn(function()
    LocalPlayer.Idled:Connect(function()
        if Toggles.AntiAFK.Value then
            game:GetService("VirtualUser"):Button2Down(Vector2.new(0,0), Camera.CFrame)
            task.wait(1)
            game:GetService("VirtualUser"):Button2Up(Vector2.new(0,0), Camera.CFrame)
        end
    end)
end)

-- Mobile Support Bubble
if UserInputService.TouchEnabled then
    local sg = Instance.new("ScreenGui", game:GetService("CoreGui"))
    local btn = Instance.new("ImageButton", sg)
    btn.Size = UDim2.fromOffset(50, 50)
    btn.Position = UDim2.new(0, 10, 0.5, 0)
    btn.Image = "rbxassetid://70773874533764"
    btn.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    Instance.new("UICorner", btn).CornerRadius = UDim.new(1, 0)
    btn.MouseButton1Click:Connect(function() Library:Toggle() end)
end

-- [FINALIZE]
dismiss()
Library:Notify("v5.4 Improvements Applied Successfully!", 5)
