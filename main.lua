-- ============================================================
--  W43 HUB
-- ============================================================
print("=== W424 HUB  ===")

local Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/Naellx/Oxidelib/main/Oxidelib.lua"))()
if not Library then return warn("Oxidelib gagal dimuat") end

Library:SetTheme("OLED")

local MY_LOGO = "rbxassetid://70773874533764" -- logo default

-- ============================================================
--  WINDOW UTAMA (GROWAGARDEN2 STYLE)
-- ============================================================
local Window = Library:CreateWindow({
    Name = "W424 HUB",
    BrandSubtitle = "v5.3",
    Logo = MY_LOGO,
    LogoZoom = 1.5,
    ToggleKey = Enum.KeyCode.F3,
    ProfileKey = Enum.KeyCode.K,
    Size = UDim2.fromOffset(720, 500),
    LoadingText = "W424 HUB",
    LoadingSubtitle = "Loading v5.3 Final...",
})

-- Watermark
task.spawn(function()
    task.wait(0.5)
    if Window.Watermark then
        Window.Watermark.ImageTransparency = 0.4
    end
end)

-- Mobile Bubble (salin dari growagarden2)
task.spawn(function()
    pcall(function()
        local sg = Window.ScreenGui
        if not sg then return end
        
        local btn = Instance.new("TextButton")
        btn.Name = "W424MobileBubble"
        btn.Size = UDim2.new(0, 56, 0, 56)
        btn.Position = UDim2.new(0.1, 0, 0.4, 0)
        btn.BackgroundColor3 = Color3.fromRGB(15, 15, 20)
        btn.BackgroundTransparency = 0.1
        btn.Text = ""
        btn.ZIndex = 999
        btn.Parent = sg
        
        local corner = Instance.new("UICorner", btn)
        corner.CornerRadius = UDim.new(0, 16)
        
        local stroke = Instance.new("UIStroke", btn)
        stroke.Color = Color3.fromRGB(167, 200, 244)
        stroke.Thickness = 1.5
        
        local icon = Instance.new("ImageLabel", btn)
        icon.Size = UDim2.new(0.8, 0, 0.8, 0)
        icon.Position = UDim2.new(0.1, 0, 0.1, 0)
        icon.BackgroundTransparency = 1
        icon.Image = MY_LOGO
        icon.ScaleType = Enum.ScaleType.Fit
        icon.ZIndex = 1000
        
        btn.MouseButton1Click:Connect(function() Window:ToggleUI() end)
        
        local UserInputService = game:GetService("UserInputService")
        local dragging, dragStart, startPos = false, nil, nil
        
        btn.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                dragging, dragStart, startPos = true, input.Position, btn.Position
            end
        end)
        
        UserInputService.InputChanged:Connect(function(input)
            if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
                local delta = input.Position - dragStart
                btn.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
            end
        end)
        
        UserInputService.InputEnded:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                dragging = false
            end
        end)
    end)
end)

-- ============================================================
--  GLOBAL FEATURES
-- ============================================================
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local camera = workspace.CurrentCamera
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local CoreGui = game:GetService("CoreGui")
local StarterGui = game:GetService("StarterGui")

local Features = {
    noRecoil = false,
    noSpread = false,
    antiRagdoll = false,
    antiAFK = false,

    aimbotEnabled = false,
    aimMode = "Always",
    targetPart = "Head",
    headshotOnly = true,
    aimSmoothness = 5,
    useTeamCheck = true,
    fovRadius = 70,
    maxAimDistance = 800,
    usePrediction = true,
    predictionFactor = 0.5,
    bulletSpeed = 1000,

    espEnabled = false,
    espColor = Color3.fromRGB(255, 0, 0),
    espTransparency = 0.3,
    espTeamCheck = true,

    reduceMap = false,
}

-- ============================================================
--  FOV CIRCLE
-- ============================================================
local fovGui = Instance.new("ScreenGui", CoreGui)
fovGui.Name = "W424HUB_FOV"
fovGui.IgnoreGuiInset = true
fovGui.DisplayOrder = 999

local fovFrame = Instance.new("Frame", fovGui)
fovFrame.BackgroundTransparency = 1
fovFrame.AnchorPoint = Vector2.new(0.5, 0.5)
fovFrame.Size = UDim2.new(0, Features.fovRadius * 2, 0, Features.fovRadius * 2)
fovFrame.Visible = false

local fovStroke = Instance.new("UIStroke", fovFrame)
fovStroke.Color = Color3.fromRGB(255, 255, 255)
fovStroke.Thickness = 2
Instance.new("UICorner", fovFrame).CornerRadius = UDim.new(1, 0)

RunService.RenderStepped:Connect(function()
    if fovFrame.Visible then
        local viewport = camera.ViewportSize
        fovFrame.Position = UDim2.new(0, viewport.X / 2, 0, viewport.Y / 2)
    end
end)

-- ============================================================
--  ESP – HIGHLIGHT
-- ============================================================
local espHighlights = {}

local function clearESP()
    for _, h in pairs(espHighlights) do
        if h then h:Destroy() end
    end
    espHighlights = {}
end

local function updateESP()
    if not Features.espEnabled then
        clearESP()
        return
    end

    for _, player in ipairs(Players:GetPlayers()) do
        if player == LocalPlayer then continue end
        local char = player.Character
        if not char or not char:FindFirstChildOfClass("Humanoid") or char:FindFirstChildOfClass("Humanoid").Health <= 0 then
            if espHighlights[player] then
                espHighlights[player]:Destroy()
                espHighlights[player] = nil
            end
            continue
        end

        if Features.espTeamCheck and LocalPlayer.Team and player.Team and LocalPlayer.Team == player.Team then
            if espHighlights[player] then
                espHighlights[player].Enabled = false
            end
            continue
        end

        if not espHighlights[player] then
            local h = Instance.new("Highlight")
            h.Parent = char
            h.FillColor = Features.espColor
            h.OutlineColor = Features.espColor
            h.FillTransparency = Features.espTransparency
            h.OutlineTransparency = 0.5
            h.Enabled = true
            espHighlights[player] = h
        else
            espHighlights[player].Parent = char
            espHighlights[player].Enabled = true
            espHighlights[player].FillColor = Features.espColor
            espHighlights[player].FillTransparency = Features.espTransparency
        end
    end

    for player, h in pairs(espHighlights) do
        if not player.Parent or not player.Character or not player.Character:FindFirstChildOfClass("Humanoid") or player.Character:FindFirstChildOfClass("Humanoid").Health <= 0 then
            h:Destroy()
            espHighlights[player] = nil
        end
    end
end

Players.PlayerAdded:Connect(updateESP)
Players.PlayerRemoving:Connect(function(p)
    if espHighlights[p] then
        espHighlights[p]:Destroy()
        espHighlights[p] = nil
    end
end)

-- ============================================================
--  UTILITIES
-- ============================================================
local function applyReduceMap(state)
    pcall(function() StarterGui:SetCore("MinimapEnabled", not state) end)
    for _, gui in ipairs(CoreGui:GetChildren()) do
        if gui:IsA("ScreenGui") and (gui.Name:lower():find("map") or gui.Name:lower():find("hud")) then
            gui.Enabled = not state
        end
    end
end

local antiAFKConnection
local function toggleAntiAFK(state)
    if state then
        antiAFKConnection = RunService.Heartbeat:Connect(function()
            if tick() % 30 < 0.1 then
                UserInputService:SetMouseDelta(Vector2.new(1, 0))
            end
        end)
    else
        if antiAFKConnection then
            antiAFKConnection:Disconnect()
            antiAFKConnection = nil
        end
    end
end

local function isAlive(char)
    if not char then return false end
    local hum = char:FindFirstChildOfClass("Humanoid")
    return hum and hum.Health > 0
end

local function getTargetPart(char)
    if Features.headshotOnly then
        return char:FindFirstChild("Head") or char:FindFirstChild("head")
    end
    return char:FindFirstChild(Features.targetPart) or char:FindFirstChild("Head") or char:FindFirstChild("HumanoidRootPart")
end

-- ============================================================
--  AIMBOT CORE
-- ============================================================
local function getBestTarget()
    local targets = {}
    local myChar = LocalPlayer.Character
    if not myChar then return nil end
    local myRoot = myChar:FindFirstChild("HumanoidRootPart")
    if not myRoot then return nil end
    local myPos = myRoot.Position
    local myTeam = LocalPlayer.Team

    for _, player in ipairs(Players:GetPlayers()) do
        if player == LocalPlayer then continue end
        local char = player.Character
        if not char or not isAlive(char) then continue end
        if Features.useTeamCheck and myTeam and player.Team == myTeam then continue end

        local part = getTargetPart(char)
        if not part then continue end

        local targetPos = part.Position
        local dist = (targetPos - myPos).Magnitude
        if dist > Features.maxAimDistance then continue end

        local screenPos, onScreen = camera:WorldToViewportPoint(targetPos)
        if not onScreen then continue end
        
        local center = camera.ViewportSize / 2
        local screenDist = (Vector2.new(screenPos.X, screenPos.Y) - center).Magnitude
        if screenDist > Features.fovRadius then continue end

        if Features.usePrediction then
            local hrp = char:FindFirstChild("HumanoidRootPart")
            if hrp then
                local vel = hrp.Velocity or Vector3.new()
                local travelTime = dist / Features.bulletSpeed
                targetPos = targetPos + (vel * travelTime * Features.predictionFactor)
            end
        end

        table.insert(targets, {
            Player = player,
            Character = char,
            Position = targetPos,
            ScreenDist = screenDist,
            Distance = dist,
        })
    end

    table.sort(targets, function(a, b) return a.ScreenDist < b.ScreenDist end)
    return targets[1]
end

-- ============================================================
--  DETEKSI TEMBAKAN
-- ============================================================
local isShooting = false

UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    if input.UserInputType == Enum.UserInputType.MouseButton1 or 
       input.UserInputType == Enum.UserInputType.Touch then
        isShooting = true
    end
end)
UserInputService.InputEnded:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    if input.UserInputType == Enum.UserInputType.MouseButton1 or 
       input.UserInputType == Enum.UserInputType.Touch then
        isShooting = false
    end
end)

local function setupTool(tool)
    if not tool then return end
    tool.Activated:Connect(function()
        isShooting = true
    end)
    tool.Deactivated:Connect(function()
        isShooting = false
    end)
end

local function onCharacterAdded(char)
    for _, tool in ipairs(char:GetChildren()) do
        if tool:IsA("Tool") then
            setupTool(tool)
        end
    end
    char.ChildAdded:Connect(function(child)
        if child:IsA("Tool") then
            setupTool(child)
        end
    end)
end

LocalPlayer.CharacterAdded:Connect(onCharacterAdded)
if LocalPlayer.Character then
    onCharacterAdded(LocalPlayer.Character)
end

-- ============================================================
--  RENDER LOOP
-- ============================================================
RunService.RenderStepped:Connect(function(dt)
    pcall(function()
        -- Aimbot
        if Features.aimbotEnabled then
            local best = getBestTarget()
            if best then
                local shouldAim = (Features.aimMode == "Always") or (Features.aimMode == "When Shoot" and isShooting)
                if shouldAim then
                    local currentCF = camera.CFrame
                    local targetCF = CFrame.new(currentCF.Position, best.Position)
                    local alpha = math.clamp(dt * Features.aimSmoothness * 15, 0.01, 1)
                    camera.CFrame = currentCF:Lerp(targetCF, alpha)
                end
            end
        end

        -- ESP
        updateESP()

        -- No Recoil / Spread
        if Features.noRecoil or Features.noSpread then
            local char = LocalPlayer.Character
            if char then
                local tool = char:FindFirstChildOfClass("Tool")
                if tool then
                    for _, child in ipairs(tool:GetDescendants()) do
                        if child:IsA("NumberValue") or child:IsA("FloatValue") then
                            if child.Name:lower():find("recoil") and Features.noRecoil then
                                child.Value = 0
                            end
                            if child.Name:lower():find("spread") and Features.noSpread then
                                child.Value = 0
                            end
                        end
                    end
                end
            end
        end

        -- Anti Ragdoll
        local char = LocalPlayer.Character
        if char and Features.antiRagdoll then
            local hum = char:FindFirstChildOfClass("Humanoid")
            if hum then
                hum.PlatformStand = false
                hum.Sit = false
            end
        end
    end)
end)

-- ============================================================
--  UI TABS 
-- ============================================================

-- TAB 1: MAIN (Player Tweaks)
local TabMain = Window:AddTab({ Name = "Main", Icon = "home" })
local SubPlayer = TabMain:AddSubTab("Player Tweaks")

SubPlayer:AddSection("Player Tweaks")
SubPlayer:AddToggle({ Name = "No Recoil", Default = false, Callback = function(v) Features.noRecoil = v end })
SubPlayer:AddToggle({ Name = "No Spread", Default = false, Callback = function(v) Features.noSpread = v end })
SubPlayer:AddToggle({ Name = "Anti Ragdoll", Default = false, Callback = function(v) Features.antiRagdoll = v end })
SubPlayer:AddToggle({ Name = "Anti AFK", Default = false, Callback = function(v) Features.antiAFK = v; toggleAntiAFK(v) end })

-- TAB 2: AIM (Aggressive Aimbot)
local TabAim = Window:AddTab({ Name = "Aim", Icon = "target" })
local SubAim = TabAim:AddSubTab("Aggressive Aimbot")

SubAim:AddSection("Aimbot Settings")
SubAim:AddToggle({ Name = "Enable Aimbot", Default = false, Callback = function(v) Features.aimbotEnabled = v end })
SubAim:AddDropdown({
    Name = "Aim Mode",
    Options = {"Always", "When Shoot"},
    Default = "Always",
    Callback = function(v) Features.aimMode = v end
})
SubAim:AddToggle({ Name = "FOV Circle", Default = false, Callback = function(v) fovFrame.Visible = v end })
SubAim:AddSlider({
    Name = "FOV Radius",
    Min = 30,
    Max = 300,
    Default = 70,
    Callback = function(v) 
        Features.fovRadius = v 
        fovFrame.Size = UDim2.new(0, v * 2, 0, v * 2)
    end
})
SubAim:AddSlider({ Name = "Max Distance", Min = 100, Max = 2000, Default = 800, Callback = function(v) Features.maxAimDistance = v end })
SubAim:AddToggle({ Name = "Headshot Only", Default = true, Callback = function(v) Features.headshotOnly = v end })
SubAim:AddToggle({ Name = "Team Check", Default = true, Callback = function(v) Features.useTeamCheck = v end })
SubAim:AddSlider({ Name = "Aim Smoothness", Min = 1, Max = 10, Default = 5, Callback = function(v) Features.aimSmoothness = v end })
SubAim:AddDropdown({
    Name = "Target Part",
    Options = {"Head", "HumanoidRootPart", "Torso"},
    Default = "Head",
    Callback = function(v) Features.targetPart = v end
})

-- TAB 3: PREDICT (Prediction Settings)
local TabPredict = Window:AddTab({ Name = "Predict", Icon = "chart" })
local SubPred = TabPredict:AddSubTab("Prediction Settings")

SubPred:AddSection("Prediction")
SubPred:AddToggle({ Name = "Enable Prediction", Default = true, Callback = function(v) Features.usePrediction = v end })
SubPred:AddSlider({ Name = "Prediction Factor", Min = 0, Max = 100, Default = 50, Callback = function(v) Features.predictionFactor = v/100 end })
SubPred:AddSlider({ Name = "Bullet Speed", Min = 200, Max = 2000, Default = 1000, Callback = function(v) Features.bulletSpeed = v end })

-- TAB 4: VISUAL (ESP & Map)
local TabVisual = Window:AddTab({ Name = "Visual", Icon = "eye" })
local SubVisual = TabVisual:AddSubTab("ESP & Map")

SubVisual:AddSection("ESP Highlight")
SubVisual:AddToggle({ Name = "Enable ESP Highlight", Default = false, Callback = function(v) 
    Features.espEnabled = v 
    if not v then clearESP() end
end })
SubVisual:AddColorPicker({
    Name = "ESP Color",
    Default = Color3.fromRGB(255, 0, 0),
    Callback = function(c) 
        Features.espColor = c 
        for _, h in pairs(espHighlights) do
            if h then h.FillColor = c; h.OutlineColor = c end
        end
    end
})
SubVisual:AddSlider({
    Name = "ESP Transparency",
    Min = 0,
    Max = 10,
    Default = 3,
    Callback = function(v) 
        Features.espTransparency = v/10
        for _, h in pairs(espHighlights) do
            if h then h.FillTransparency = Features.espTransparency end
        end
    end
})
SubVisual:AddToggle({ Name = "Team Check (ESP)", Default = true, Callback = function(v) 
    Features.espTeamCheck = v 
    if Features.espEnabled then updateESP() end
end })

SubVisual:AddSection("Map & Camera")
SubVisual:AddToggle({ Name = "Reduce Map", Default = false, Callback = function(v) Features.reduceMap = v; applyReduceMap(v) end })
SubVisual:AddSlider({ Name = "Camera FOV", Min = 60, Max = 120, Default = 70, Callback = function(v) camera.FieldOfView = v end })

-- TAB 5: CONFIG (Save/Load)
local TabConfig = Window:AddTab({ Name = "Config", Icon = "gear" })
local SubConfig = TabConfig:AddSubTab("Manager")

SubConfig:AddSection("Configuration")
SubConfig:AddButton({ Name = "Save Config", Callback = function()
    Window:SaveConfig()
    Window:Notify({ Title = "W424HUB HUB", Content = "Settings saved!", Type = "success", Duration = 2 })
end })
SubConfig:AddButton({ Name = "Load Config", Callback = function()
    Window:LoadConfig()
    Window:Notify({ Title = "W424 HUB", Content = "Settings loaded!", Type = "success", Duration = 2 })
end })

-- ============================================================
--  NOTIFIKASI AWAL
-- ============================================================
Window:Notify({
    Title = "W424HUB",
    Content = "ESP Highlight & Aimbot When Shoot fixed!",
    Type = "success",
    Duration = 4
})

print("✅ W424HUB – LET'S KILL!!!")
