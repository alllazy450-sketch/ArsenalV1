-- ========== W424HUB v3.9 FINAL – AGGRESSIVE TRIGGERBOT ==========
print("=== LOADING W424HUB v3.9 ===")

local Kairo = loadstring(game:HttpGet("https://raw.githubusercontent.com/Itzzavi335/Kairo-Ui-Library/refs/heads/main/source.luau"))()
if not Kairo then return warn("Kairo failed") end

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local camera = workspace.CurrentCamera
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local CoreGui = game:GetService("CoreGui")
local StarterGui = game:GetService("StarterGui")
local Lighting = game:GetService("Lighting")
local Workspace = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local VirtualInputManager = game:GetService("VirtualInputManager")

-- WINDOW
local Window = Kairo:CreateWindow({
    Title = "W424HUB",
    Theme = "Ocean",
    Size = UDim2.fromOffset(500, 450),
    Center = true,
    Draggable = true,
    Resize = false,
    Badges = {"v3.9"},
    MinimizeKey = Enum.KeyCode.RightShift,
    MinimizeButton = true,
    Config = { Enabled = true, Folder = "W424HUB_Config", AutoLoad = true }
})
if not Window then return end

Window:Notify({Title="W424HUB", Description="Loaded! Enable features manually.", Color=Color3.fromRGB(0,200,50), Delay=3})

-- TABS
local TabAim = Window:CreateTab("Aim", "rbxassetid://16932740082")
local TabVisual = Window:CreateTab("Visual", "rbxassetid://16932740082")
local TabPlayer = Window:CreateTab("Player", "rbxassetid://16932740082")
local TabArsenal = Window:CreateTab("Arsenal", "rbxassetid://16932740082")

-- ========================================
-- TAB AIM (AIMBOT CAMERA + TRIGGERBOT)
-- ========================================
Window:AddParagraph(TabAim, "Aimbot", "Camera aimbot")

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
local target = nil

-- TRIGGERBOT (AGGRESSIVE)
local triggerbotEnabled = false
local triggerDelay = 0.1
local triggerFOV = 30
local triggerCooldown = 0
local aggressiveMode = false
local burstShots = 3
local burstDelay = 0.03
local autoRecoilReset = false

-- VISIBILITY
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

-- GET BEST TARGET
local function getBestTarget()
    if not aimbotEnabled and not triggerbotEnabled then return nil end
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

-- FOV CIRCLE
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

-- UI
Window:AddToggle(TabAim, "Aimbot", "Enable", false, function(s) aimbotEnabled = s end)
Window:AddDropdown(TabAim, "Trigger", "When to aim", {"On Shoot","Always"}, false, "On Shoot", function(v) aimTrigger = v end)
Window:AddToggle(TabAim, "FOV Circle", "Show circle", false, function(s) fovFrame.Visible = s end)
Window:AddSlider(TabAim, "FOV Radius", "30-400", 30, 400, 100, function(v) fovRadius = v; updateFOVSize() end)
Window:AddSlider(TabAim, "Max Distance", "50-500", 50, 500, 300, function(v) maxAimDistance = v end)
Window:AddToggle(TabAim, "Anti Team", "Avoid teammates", true, function(s) useTeamCheck = s end)
Window:AddToggle(TabAim, "Vis Check", "Check walls", true, function(s) useVisibilityCheck = s end)
Window:AddToggle(TabAim, "Prediction", "Aim ahead", false, function(s) usePrediction = s end)
Window:AddSlider(TabAim, "Pred Factor", "0-100", 0, 100, 20, function(v) predictionFactor = v/100 end)
Window:AddToggle(TabAim, "Headshot Only", "Force head", false, function(s) headshotOnly = s; if s then targetPartName = "Head" end end)
Window:AddDropdown(TabAim, "Target Part", "Body part", {"Head","HumanoidRootPart","Torso","UpperTorso"}, false, "Head", function(v) if not headshotOnly then targetPartName = v end end)
Window:AddSlider(TabAim, "Smoothness", "1-10", 1, 10, 10, function(v) aimSmoothness = v/10 end)

-- TRIGGERBOT UI (AGGRESSIVE)
Window:AddDivider(TabAim, "Triggerbot (Auto Shoot)")
Window:AddToggle(TabAim, "Enable Triggerbot", "Shoot automatically when crosshair on enemy", false, function(v) triggerbotEnabled = v end)
Window:AddSlider(TabAim, "Trigger Delay", "0.01-0.5s (smaller = faster)", 1, 50, 10, function(v) triggerDelay = v/100 end)
Window:AddSlider(TabAim, "Trigger FOV", "Pixel radius from crosshair (5-100)", 5, 100, 30, function(v) triggerFOV = v end)

Window:AddToggle(TabAim, "Aggressive Mode", "Spam shoot! Faster than humanly possible", false, function(v)
    aggressiveMode = v
    if v then
        triggerDelay = 0.01
        triggerFOV = math.max(triggerFOV, 40)
        Window:Notify({Title="Aggressive Mode ON", Description="Trigger will spam shots!", Color=Color3.fromRGB(255,0,0), Delay=2})
    else
        triggerDelay = 0.1
        Window:Notify({Title="Aggressive Mode OFF", Description="Back to normal", Color=Color3.fromRGB(0,255,0), Delay=2})
    end
end)
Window:AddSlider(TabAim, "Burst Shots", "Shots per trigger (1-10)", 1, 10, 3, function(v) burstShots = v end)
Window:AddSlider(TabAim, "Burst Delay", "Delay between burst shots (0.01-0.1s)", 1, 10, 3, function(v) burstDelay = v/100 end)

-- AUTO RECOIL RESET
Window:AddDivider(TabAim, "Recoil Control")
Window:AddToggle(TabAim, "Auto Recoil Reset", "Pull mouse down automatically", false, function(v) autoRecoilReset = v end)

-- INPUT SHOOT
UserInputService.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then isShooting = true end
end)
UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then isShooting = false end
end)

-- MAIN LOOP (AIMBOT + AGGRESSIVE TRIGGERBOT + RECOIL RESET)
RunService.RenderStepped:Connect(function(dt)
    local best = nil

    if aimbotEnabled or triggerbotEnabled then
        best = getBestTarget()
    end

    -- AIMBOT
    if aimbotEnabled and best then
        local canAim = (aimTrigger == "On Shoot" and isShooting) or (aimTrigger == "Always")
        if canAim then
            local targetPos = best.Position
            local currentCF = camera.CFrame
            local targetCF = CFrame.new(currentCF.Position, targetPos)
            local smoothFactor = 1 - math.exp(-aimSmoothness * dt * 5)
            camera.CFrame = currentCF:Lerp(targetCF, smoothFactor)
        end
    end

    -- ===== AGGRESSIVE TRIGGERBOT =====
    if triggerbotEnabled and best then
        local pos, onScreen = camera:WorldToViewportPoint(best.Position)
        if onScreen then
            local center = camera.ViewportSize / 2
            local distFromCrosshair = (Vector2.new(pos.X, pos.Y) - center).Magnitude

            local currentFOV = aggressiveMode and triggerFOV * 1.5 or triggerFOV

            if distFromCrosshair < currentFOV then
                triggerCooldown = triggerCooldown - dt

                local effectiveDelay = aggressiveMode and triggerDelay * 0.3 or triggerDelay
                effectiveDelay = math.max(effectiveDelay, 0.005)

                if triggerCooldown <= 0 then
                    triggerCooldown = effectiveDelay

                    local shotsToFire = aggressiveMode and burstShots or 1

                    for i = 1, shotsToFire do
                        pcall(function()
                            local shootRemote = ReplicatedStorage:FindFirstChild("Remotes") and ReplicatedStorage.Remotes:FindFirstChild("Shoot")
                            if shootRemote then
                                shootRemote:FireServer(best.Position)
                            else
                                local remotes = ReplicatedStorage:FindFirstChild("Remotes")
                                if remotes then
                                    local found = false
                                    for _, child in ipairs(remotes:GetChildren()) do
                                        local name = child.Name:lower()
                                        if name:find("shoot") or name:find("fire") or name:find("gun") then
                                            child:FireServer(best.Position)
                                            found = true
                                            break
                                        end
                                    end
                                    if not found then
                                        VirtualInputManager:SendMouseButtonEvent(Enum.UserInputType.MouseButton1, 0, true, game, 0)
                                        task.wait(0.01)
                                        VirtualInputManager:SendMouseButtonEvent(Enum.UserInputType.MouseButton1, 0, false, game, 0)
                                    end
                                else
                                    VirtualInputManager:SendMouseButtonEvent(Enum.UserInputType.MouseButton1, 0, true, game, 0)
                                    task.wait(0.01)
                                    VirtualInputManager:SendMouseButtonEvent(Enum.UserInputType.MouseButton1, 0, false, game, 0)
                                end
                            end
                        end)

                        if i < shotsToFire then
                            local burstWait = aggressiveMode and burstDelay * 0.5 or burstDelay
                            task.wait(math.max(burstWait, 0.005))
                        end
                    end

                    if aggressiveMode then
                        triggerCooldown = effectiveDelay * 0.5
                    end
                end
            else
                triggerCooldown = 0
            end
        end
    end

    -- AUTO RECOIL RESET
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

-- ========================================
-- TAB VISUAL (ESP, LINE, REDUCE MAP, FOV SLIDER)
-- ========================================
Window:AddParagraph(TabVisual, "ESP Chams", "Highlight enemies")

local espEnabled = false
local espColor = Color3.fromRGB(255, 0, 0)
local espTeam = true
local fillTrans = 0.3
local highlightObjects = {}

local function clearESP()
    for _, h in pairs(highlightObjects) do pcall(function() h:Destroy() end) end
    highlightObjects = {}
end

Window:AddToggle(TabVisual, "Enable ESP", "Highlight enemies", false, function(s)
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
Window:AddToggle(TabVisual, "Team Check", "Hide teammates", true, function(s)
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

Window:AddToggle(TabVisual, "Enable Line ESP", "Draw tracers", false, function(s)
    lineESPEnabled = s
    if not s then clearLines() end
end)
Window:AddColorPicker(TabVisual, "Line Color", "", Color3.fromRGB(0, 255, 255), function(c) lineColor = c end)
Window:AddSlider(TabVisual, "Line Thickness", "1-5", 1, 5, 1, function(v) lineThickness = v end)

RunService.RenderStepped:Connect(updateLineESP)
Players.PlayerAdded:Connect(updateLineESP)
Players.PlayerRemoving:Connect(updateLineESP)

-- ===== FOV SLIDER (FPS STYLE) =====
Window:AddDivider(TabVisual, "FOV (First Person Shooter)")
local fovSliderValue = 70
Window:AddSlider(TabVisual, "Field of View", "60-120 (CSGO/Valorant style)", 60, 120, 70, function(v)
    fovSliderValue = v
    pcall(function() workspace.CurrentCamera.FieldOfView = v end)
end, "FOVSlider", true)

pcall(function()
    if workspace.CurrentCamera then workspace.CurrentCamera.FieldOfView = 70 end
end)

-- ===== REDUCE MAP (SMOOTH VERSION) =====
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
            local found = gui:FindFirstChild("Minimap", true) or gui:FindFirstChild("Map", true) or gui:FindFirstChild("ViewportFrame", true)
            if found then return found.Parent or found end
        end
    end
    for _, gui in ipairs(LocalPlayer.PlayerGui:GetChildren()) do
        if gui:IsA("ScreenGui") then
            local name = gui.Name:lower()
            if name:find("minimap") or name:find("map") then
                return gui
            end
            local found = gui:FindFirstChild("Minimap", true) or gui:FindFirstChild("Map", true) or gui:FindFirstChild("ViewportFrame", true)
            if found then return found.Parent or found end
        end
    end
    return nil
end

local function applyOpacityToChildren(parent, opacity)
    if not parent then return end
    for _, child in ipairs(parent:GetDescendants()) do
        if child:IsA("ImageLabel") or child:IsA("ImageButton") or child:IsA("Frame") then
            pcall(function()
                if not child:GetAttribute("OriginalTransparency") then
                    child:SetAttribute("OriginalTransparency", child.BackgroundTransparency or 0)
                end
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

Window:AddToggle(TabVisual, "Reduce Map", "Sembunyikan minimap sepenuhnya", false, function(s)
    reduceMap = s
    if not s then applyOpacityToChildren(minimapContainer, mapOpacity) end
    updateMinimap()
end)

Window:AddSlider(TabVisual, "Map Opacity", "Transparansi minimap (0-100%)", 0, 100, 100, function(v)
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

-- ========================================
-- TAB PLAYER
-- ========================================
Window:AddParagraph(TabPlayer, "Player Mods", "Character features")
local noRecoil = false; local noSpread = false; local antiRagdoll = false
Window:AddToggle(TabPlayer, "No Recoil", "Remove shake", false, function(s) noRecoil = s end)
Window:AddToggle(TabPlayer, "No Spread", "Perfect accuracy", false, function(s) noSpread = s end)
Window:AddToggle(TabPlayer, "Anti Ragdoll", "Prevent falling", false, function(s) antiRagdoll = s end)

RunService.RenderStepped:Connect(function()
    local char = LocalPlayer.Character
    if not char then return end
    local hum = char:FindFirstChildOfClass("Humanoid")
    if not hum then return end
    if antiRagdoll then
        if hum.PlatformStand or hum.Sit then
            hum.PlatformStand = false
            hum.Sit = false
            local hrp = char:FindFirstChild("HumanoidRootPart")
            if hrp then hrp.Velocity = Vector3.new(); hrp.RotVelocity = Vector3.new() end
        end
        if hum.SeatPart then hum.Sit = false end
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

-- ========================================
-- TAB ARSENAL (SILENT HITBOX EXPANSION)
-- ========================================
Window:AddParagraph(TabArsenal, "Arsenal Mods", "Fast Fire, Reload, Skins")

local fastFire = false
local fastReload = false
local infiniteAmmo = false
local arsenalNoRecoil = false
local arsenalNoSpread = false
local Weapons = ReplicatedStorage:FindFirstChild("Weapons")
local Items = ReplicatedStorage:FindFirstChild("ItemData") and ReplicatedStorage.ItemData:FindFirstChild("Images")
local InventoryData = nil

pcall(function()
    for i,v in next, getgc(true) do
        if typeof(v) == 'table' and rawget(v, 'Loadout') and typeof(v.Items) == 'table' then
            InventoryData = v.Items
            break
        end
    end
end)

local function AddEveryItem()
    if not InventoryData or not Items then return end
    for _, v in ipairs(Items:GetChildren()) do
        if InventoryData[v.Name] then
            for _, f in ipairs(v:GetChildren()) do
                if not InventoryData[v.Name][f.Name] then
                    InventoryData[v.Name][f.Name] = 1
                end
            end
        end
    end
    Window:Notify({Title="Unlock All Items", Description="All items unlocked!", Color=Color3.fromRGB(0,200,50), Delay=2})
end

local function ChangeArsenalSkin(skinType, skinName)
    local data = LocalPlayer:FindFirstChild("Data")
    if not data then return end
    if skinType == "Character" and data:FindFirstChild("Skin") then data.Skin.Value = skinName
    elseif skinType == "Melee" and data:FindFirstChild("Melee") then data.Melee.Value = skinName
    elseif skinType == "KillEffect" and data:FindFirstChild("KillEffect") then data.KillEffect.Value = skinName
    elseif skinType == "Announcer" and data:FindFirstChild("Announcer") then data.Announcer.Value = skinName
    elseif skinType == "GunSkin" and LocalPlayer:FindFirstChild("Equipped") then LocalPlayer.Equipped.Value = skinName end
end

local function GetSkinList(category)
    local list = {"Default"}
    if not Items then return list end
    for _, v in ipairs(Items:GetChildren()) do
        if v.Name == category then
            for _, f in ipairs(v:GetChildren()) do
                table.insert(list, f.Name)
            end
        end
    end
    return list
end

Window:AddToggle(TabArsenal, "Infinite Ammo", "Unlimited ammo", false, function(s)
    infiniteAmmo = s
    if s then
        pcall(function()
            if ReplicatedStorage:FindFirstChild("wkspc") and ReplicatedStorage.wkspc:FindFirstChild("CurrentCurse") then
                ReplicatedStorage.wkspc.CurrentCurse.Value = 'Infinite Ammo'
            end
        end)
    end
end)
Window:AddToggle(TabArsenal, "Fast Fire Rate", "Super fast shooting", false, function(s)
    fastFire = s
    if Weapons then
        for _, v in ipairs(Weapons:GetChildren()) do
            if v:FindFirstChild("FireRate") then v.FireRate.Value = s and 0.01 or 0.1 end
            if v:FindFirstChild("BFireRate") then v.BFireRate.Value = s and 0.01 or 0.1 end
        end
    end
end)
Window:AddToggle(TabArsenal, "Fast Reload", "Almost instant reload", false, function(s)
    fastReload = s
    if Weapons then
        for _, v in ipairs(Weapons:GetChildren()) do
            if v:FindFirstChild("ReloadTime") then v.ReloadTime.Value = s and 0.01 or 1.5 end
        end
    end
end)
Window:AddToggle(TabArsenal, "No Recoil (Arsenal)", "Set RecoilControl to 0", false, function(s)
    arsenalNoRecoil = s
    if Weapons then
        for _, v in ipairs(Weapons:GetChildren()) do
            if v:FindFirstChild("RecoilControl") then v.RecoilControl.Value = s and 0 or 1 end
        end
    end
end)
Window:AddToggle(TabArsenal, "No Spread (Arsenal)", "Set MaxSpread & SpreadRecovery", false, function(s)
    arsenalNoSpread = s
    if Weapons then
        for _, v in ipairs(Weapons:GetChildren()) do
            if v:FindFirstChild("MaxSpread") then v.MaxSpread.Value = s and 0.01 or 1 end
            if v:FindFirstChild("SpreadRecovery") then v.SpreadRecovery.Value = s and 0.01 or 0.5 end
        end
    end
end)

Window:AddDivider(TabArsenal, "Unlock & Skin Changer")
Window:AddButton(TabArsenal, "Unlock All Items", "Unlock all skins & items", AddEveryItem)

local charSkins = GetSkinList("Character")
Window:AddDropdown(TabArsenal, "Character Skin", "Select character skin", charSkins, false, charSkins[1] or "Default", function(v) ChangeArsenalSkin("Character", v) end)
local meleeSkins = GetSkinList("Melee")
Window:AddDropdown(TabArsenal, "Melee Skin", "Select melee skin", meleeSkins, false, meleeSkins[1] or "Default", function(v) ChangeArsenalSkin("Melee", v) end)
local gunSkins = GetSkinList("Gun")
Window:AddDropdown(TabArsenal, "Gun Skin", "Select gun skin", gunSkins, false, gunSkins[1] or "Default", function(v) ChangeArsenalSkin("GunSkin", v) end)
local killSkins = GetSkinList("KillEffect")
Window:AddDropdown(TabArsenal, "Kill Effect", "Select kill effect", killSkins, false, killSkins[1] or "Default", function(v) ChangeArsenalSkin("KillEffect", v) end)
local announcerSkins = GetSkinList("Announcer")
Window:AddDropdown(TabArsenal, "Announcer", "Select announcer voice", announcerSkins, false, announcerSkins[1] or "Default", function(v) ChangeArsenalSkin("Announcer", v) end)

-- ===== SILENT HITBOX (EXPANSION) =====
Window:AddDivider(TabArsenal, "Hitbox Expansion")
local silentHitbox = false
local hitboxExpansion = 13
local hitboxAlpha = 0.3
local targetPartsChoice = "All"
local silentLoopRunning = false
local silentLoopStop = false

local function getTargetParts(char)
    local parts = {}
    if not char then return parts end
    if targetPartsChoice == "All" or targetPartsChoice == "Head" then
        local head = char:FindFirstChild("Head")
        if head then table.insert(parts, head) end
        local headHB = char:FindFirstChild("HeadHB")
        if headHB then table.insert(parts, headHB) end
    end
    if targetPartsChoice == "All" or targetPartsChoice == "Torso" then
        local torso = char:FindFirstChild("Torso") or char:FindFirstChild("UpperTorso")
        if torso then table.insert(parts, torso) end
        local hrp = char:FindFirstChild("HumanoidRootPart")
        if hrp then table.insert(parts, hrp) end
    end
    if targetPartsChoice == "All" or targetPartsChoice == "Legs" then
        for _, name in pairs({"RightUpperLeg","LeftUpperLeg","RightLowerLeg","LeftLowerLeg"}) do
            local leg = char:FindFirstChild(name)
            if leg then table.insert(parts, leg) end
        end
    end
    return parts
end

local function silentHitboxLoop()
    while silentLoopRunning and not silentLoopStop do
        if silentHitbox then
            for _, player in ipairs(Players:GetPlayers()) do
                if player ~= LocalPlayer and player.Character then
                    local parts = getTargetParts(player.Character)
                    for _, part in ipairs(parts) do
                        pcall(function()
                            part.Transparency = hitboxAlpha
                            part.CanCollide = false
                            part.Size = Vector3.new(hitboxExpansion, hitboxExpansion, hitboxExpansion)
                        end)
                    end
                end
            end
        else
            for _, player in ipairs(Players:GetPlayers()) do
                if player ~= LocalPlayer and player.Character then
                    local parts = getTargetParts(player.Character)
                    for _, part in ipairs(parts) do
                        pcall(function()
                            part.Transparency = 0
                            part.CanCollide = true
                            local name = part.Name
                            if name == "HumanoidRootPart" then part.Size = Vector3.new(2,2,1)
                            elseif name:find("Leg") then part.Size = Vector3.new(1,2,1)
                            elseif name == "Head" or name == "HeadHB" then part.Size = Vector3.new(2,1,1)
                            elseif name == "Torso" or name == "UpperTorso" then part.Size = Vector3.new(2,1.5,1)
                            else part.Size = Vector3.new(1,1,1) end
                        end)
                    end
                end
            end
        end
        task.wait(0.3)
    end
end

local function startSilentHitbox()
    if silentLoopRunning then return end
    silentLoopRunning = true
    silentLoopStop = false
    task.spawn(silentHitboxLoop)
end

local function stopSilentHitbox()
    silentLoopStop = true
    task.wait(0.4)
    silentLoopRunning = false
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character then
            local parts = getTargetParts(player.Character)
            for _, part in ipairs(parts) do
                pcall(function()
                    part.Transparency = 0
                    part.CanCollide = true
                    local name = part.Name
                    if name == "HumanoidRootPart" then part.Size = Vector3.new(2,2,1)
                    elseif name:find("Leg") then part.Size = Vector3.new(1,2,1)
                    elseif name == "Head" or name == "HeadHB" then part.Size = Vector3.new(2,1,1)
                    elseif name == "Torso" or name == "UpperTorso" then part.Size = Vector3.new(2,1.5,1)
                    else part.Size = Vector3.new(1,1,1) end
                end)
            end
        end
    end
end

Window:AddToggle(TabArsenal, "Hitbox Expansion", "Expand enemy hitboxes", false, function(v)
    silentHitbox = v
    if v then startSilentHitbox() else stopSilentHitbox() end
end)
Window:AddDropdown(TabArsenal, "Target Parts", "Select body part", {"All","Head","Torso","Legs"}, false, "All", function(v)
    targetPartsChoice = v
    if silentHitbox then stopSilentHitbox(); startSilentHitbox() end
end)
Window:AddSlider(TabArsenal, "Hitbox Size", "1-30", 1, 30, 13, function(v) hitboxExpansion = v end)
Window:AddSlider(TabArsenal, "Hitbox Alpha", "Transparency 0-10", 0, 10, 3, function(v) hitboxAlpha = v / 10 end)
Window:AddButton(TabArsenal, "Reset Hitbox", "Restore default sizes", function()
    stopSilentHitbox()
    if silentHitbox then startSilentHitbox() end
    Window:Notify({Title="Reset Hitbox", Description="Hitbox restored to default", Color=Color3.fromRGB(255,255,0), Delay=2})
end)

-- ========================================
-- FPS & PING DRAGGABLE
-- ========================================
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
Window:AddToggle(TabVisual, "FPS & Ping", "Show stats", false, function(s)
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

print("✅ W424HUB v3.9 FINAL loaded – Aggressive Triggerbot + Burst + Recoil Reset ready!")