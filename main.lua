-- ========== W424HUB v3.8 LITE ==========
print("=== W424HUB LOADING ===")

local Kairo = loadstring(game:HttpGet("https://raw.githubusercontent.com/Itzzavi335/Kairo-Ui-Library/refs/heads/main/source.luau"))()
if not Kairo then warn("❌ Kairo failed to load!") return end

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

-- ========== MAIN WINDOW (SIZE 480x480) ==========
local Window = Kairo:CreateWindow({
    Title = "W424HUB",
    Theme = "Ocean",
    Size = UDim2.fromOffset(480, 480),   -- <-- UKURAN BARU
    Center = true,
    Draggable = true,
    Resize = false,
    Badges = {"v3.8"},
    MinimizeKey = Enum.KeyCode.RightShift,
    MinimizeButton = true,
    Config = { Enabled = true, Folder = "W424HUB_Config", AutoLoad = true }
})

if not Window then warn("❌ Failed to create window!") return end

Window:Notify({
    Title = "W424HUB v3.8",
    Description = "Loaded successfully!",
    Content = "Silent Hitbox & Reduce Map included",
    Color = Color3.fromRGB(0, 200, 50),
    Delay = 3
})

-- ========== CREATE TABS ==========
local TabAim = Window:CreateTab("Aim", "rbxassetid://16932740082")
local TabVisual = Window:CreateTab("Visual", "rbxassetid://16932740082")
local TabPlayer = Window:CreateTab("Player", "rbxassetid://16932740082")
local TabArsenal = Window:CreateTab("Arsenal", "rbxassetid://16932740082")

-- =====================================================
-- TAB AIM - AIMBOT + SILENT AIM + AUTO SHOOT
-- =====================================================
Window:AddParagraph(TabAim, "Aimbot", "Camera & Silent")

local aimbotEnabled = false
local aimMode = "Camera"
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
local silentAimEnabled = false
local silentAimFOV = 30
local autoShootEnabled = false
local autoShootDelay = 0.1

-- VISIBILITY CHECK
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

-- EXPANDED HITBOX (untuk Silent Aim)
local function getExpandedTargetPosition(character)
    if not character then return nil end
    local possible = {"Head","HumanoidRootPart","Torso","UpperTorso","RightUpperLeg","LeftUpperLeg","RightLowerLeg","LeftLowerLeg"}
    local bestPart, maxSize = nil, 0
    for _, name in ipairs(possible) do
        local part = character:FindFirstChild(name)
        if part and part.Size.Magnitude > maxSize then
            maxSize = part.Size.Magnitude
            bestPart = part
        end
    end
    return bestPart
end

-- GET BEST TARGET
local function getBestTarget()
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

        local part
        if silentAimEnabled then
            part = getExpandedTargetPosition(c)
        else
            part = headshotOnly and c:FindFirstChild("Head") or c:FindFirstChild(targetPartName)
            if not part then
                part = c:FindFirstChild("Head") or c:FindFirstChild("HumanoidRootPart") or c:FindFirstChild("Torso") or c:FindFirstChild("UpperTorso")
            end
        end
        if not part then continue end

        local targetPos = part.Position
        if usePrediction then
            targetPos = targetPos + (part.Velocity or Vector3.new()) * predictionFactor
        end
        if headshotOnly and not silentAimEnabled then
            targetPos = targetPos + Vector3.new(0, 0.5, 0)
        end

        local dist = (targetPos - myPos).Magnitude
        if dist > maxAimDistance then continue end
        if not isVisible(part) then continue end

        local pos, on = camera:WorldToViewportPoint(targetPos)
        if on then
            local screenDist = (Vector2.new(pos.X, pos.Y) - center).Magnitude
            local fovLimit = silentAimEnabled and silentAimFOV or fovRadius
            if screenDist <= fovLimit and screenDist < bestDist then
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

local function updateFOVSize()
    fovFrame.Size = UDim2.new(0, fovRadius * 2, 0, fovRadius * 2)
end

-- UI
Window:AddToggle(TabAim, "Aimbot", "Enable", false, function(s) aimbotEnabled = s end)
Window:AddDropdown(TabAim, "Mode", "Camera / Silent", {"Camera","Silent"}, false, "Camera", function(v) aimMode = v end)
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

Window:AddDivider(TabAim, "Silent Aim + Hitbox")
Window:AddToggle(TabAim, "Silent Aim", "Aim without moving camera", false, function(s)
    silentAimEnabled = s
    if s then aimMode = "Silent" end
end)
Window:AddSlider(TabAim, "Silent FOV", "1-100", 1, 100, 30, function(v) silentAimFOV = v end)
Window:AddToggle(TabAim, "Auto Shoot", "Shoot automatically when on target", false, function(s) autoShootEnabled = s end)
Window:AddSlider(TabAim, "Auto Shoot Delay", "0.05-0.5s", 5, 50, 10, function(v) autoShootDelay = v/100 end)

-- INPUT SHOOT
UserInputService.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then isShooting = true end
end)
UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then isShooting = false end
end)

-- MAIN LOOP (RINGAN)
RunService.RenderStepped:Connect(function(dt)
    -- Camera Aimbot
    if aimbotEnabled and aimMode == "Camera" then
        local canAim = (aimTrigger == "On Shoot" and isShooting) or (aimTrigger == "Always")
        if canAim then
            local best = getBestTarget()
            if best then
                target = best
                local targetPos = best.Position
                local currentCF = camera.CFrame
                local targetCF = CFrame.new(currentCF.Position, targetPos)
                local smoothFactor = 1 - math.exp(-aimSmoothness * dt * 5)
                camera.CFrame = currentCF:Lerp(targetCF, smoothFactor)
            end
        end
    end

    -- Auto Shoot
    if autoShootEnabled and target then
        local pos, on = camera:WorldToViewportPoint(target.Position)
        if on and (Vector2.new(pos.X, pos.Y) - camera.ViewportSize/2).Magnitude < 15 then
            pcall(function()
                local mouse = LocalPlayer:GetMouse()
                if mouse then
                    mouse.Button1Down:Fire()
                    task.wait(autoShootDelay)
                    mouse.Button1Up:Fire()
                end
            end)
        end
    end

    -- Silent Aim (update target saja)
    if aimbotEnabled and aimMode == "Silent" and silentAimEnabled then
        local best = getBestTarget()
        if best then target = best end
    end
end)

-- ===== SILENT AIM HOOK (DIJALANKAN DENGAN DELAY AGAR TIDAK FREEZE) =====
task.spawn(function()
    task.wait(1) -- beri waktu startup
    local hooked = false
    local gc = getgc()
    for i, v in pairs(gc) do
        if hooked then break end
        if type(v) == "function" and islclosure(v) then
            local constants = debug.getconstants(v)
            local hasKeyword = false
            for _, c in pairs(constants) do
                if type(c) == "string" and (c:lower():find("fire") or c:lower():find("shoot") or c:lower():find("ray") or c:lower():find("bullet")) then
                    hasKeyword = true
                    break
                end
            end
            if hasKeyword then
                local old = v
                hookfunction(v, function(p1, p2)
                    if aimbotEnabled and aimMode == "Silent" then
                        local canAim = (aimTrigger == "On Shoot" and isShooting) or (aimTrigger == "Always")
                        if canAim then
                            local best = getBestTarget()
                            if best then
                                local myChar = LocalPlayer.Character
                                if myChar then
                                    local startPart = myChar:FindFirstChild("Head") or myChar:FindFirstChild("HumanoidRootPart")
                                    if startPart then
                                        pcall(function()
                                            local dir = (best.Position - startPart.Position)
                                            if type(p1) == "userdata" and p1:IsA("Ray") then
                                                p1 = Ray.new(startPart.Position, dir)
                                            elseif type(p2) == "userdata" and p2:IsA("CFrame") then
                                                p2 = CFrame.new(startPart.Position, startPart.Position + dir)
                                            elseif type(p1) == "Vector3" and type(p2) == "Vector3" then
                                                p1 = startPart.Position
                                                p2 = dir
                                            end
                                        end)
                                    end
                                end
                            end
                        end
                    end
                    return old(p1, p2)
                end)
                hooked = true
                print("✅ Silent Aim hook installed!")
            end
        end
    end
    if not hooked then warn("⚠️ Silent Aim hook not found!") end
end)

-- =====================================================
-- TAB VISUAL - ESP + OPTIMIZATION + REDUCE MAP + LINE ESP
-- =====================================================
Window:AddParagraph(TabVisual, "ESP Chams", "Highlight enemy bodies")

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

-- ===== ULTRA LOW MODE =====
Window:AddDivider(TabVisual, "Optimization")
local ultraLow = false
local function disableParticles(instance)
    if not ultraLow then return end
    for _, child in ipairs(instance:GetDescendants()) do
        if child:IsA("ParticleEmitter") or child:IsA("Trail") or child:IsA("Smoke") or child:IsA("Fire") or child:IsA("Sparkles") then child.Enabled = false end
        if child:IsA("Decal") or child:IsA("Texture") then pcall(function() child.Transparency = 1 end) end
    end
end

Window:AddToggle(TabVisual, "Ultra Low Mode", "Potato mode", false, function(s)
    ultraLow = s
    if s then
        pcall(function() StarterGui:SetCore("MinimapEnabled", false) end)
        pcall(function() Lighting.GlobalShadows = false; Lighting.Brightness = 0.5; Lighting.Ambient = Color3.new(0.5,0.5,0.5); Lighting.OutdoorAmbient = Color3.new(0.5,0.5,0.5) end)
        for _, child in ipairs(Lighting:GetChildren()) do
            if child:IsA("BloomEffect") or child:IsA("ColorCorrectionEffect") or child:IsA("SunRaysEffect") or child:IsA("BlurEffect") or child:IsA("DepthOfFieldEffect") then child.Enabled = false end
            if child:IsA("Atmosphere") then child.Enabled = false end
        end
        pcall(function() local settings = UserSettings(); if settings and settings.GameSettings then settings.GameSettings.GraphicsQualityLevel = 1 end end)
        pcall(function() disableParticles(Workspace) end)
    else
        pcall(function() Lighting.GlobalShadows = true; Lighting.Brightness = 1; Lighting.Ambient = Color3.new(1,1,1); Lighting.OutdoorAmbient = Color3.new(1,1,1) end)
        pcall(function() local settings = UserSettings(); if settings and settings.GameSettings then settings.GameSettings.GraphicsQualityLevel = 10 end end)
    end
end)

-- ===== REDUCE MAP (SAFE) =====
local reduceMap = false
Window:AddToggle(TabVisual, "Reduce Map", "Disable minimap", false, function(s)
    reduceMap = s
    pcall(function()
        if s then
            pcall(function() StarterGui:SetCore("MinimapEnabled", false) end)
            for _, gui in ipairs(CoreGui:GetChildren()) do
                pcall(function() if gui.Name and gui.Name:lower():find("minimap") then gui.Enabled = false end end)
            end
            for _, gui in ipairs(LocalPlayer.PlayerGui:GetChildren()) do
                pcall(function() if gui.Name and gui.Name:lower():find("minimap") then gui.Enabled = false end end)
            end
        else
            pcall(function() StarterGui:SetCore("MinimapEnabled", true) end)
            for _, gui in ipairs(CoreGui:GetChildren()) do
                pcall(function() if gui.Name and gui.Name:lower():find("minimap") then gui.Enabled = true end end)
            end
            for _, gui in ipairs(LocalPlayer.PlayerGui:GetChildren()) do
                pcall(function() if gui.Name and gui.Name:lower():find("minimap") then gui.Enabled = true end end)
            end
        end
    end)
end)

-- ===== LINE ESP (TRACER) =====
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

Window:AddToggle(TabVisual, "Enable Line ESP", "Draw tracers to enemies", false, function(s)
    lineESPEnabled = s
    if not s then clearLines() end
end)
Window:AddColorPicker(TabVisual, "Line Color", "", Color3.fromRGB(0, 255, 255), function(c) lineColor = c end)
Window:AddSlider(TabVisual, "Line Thickness", "1-5", 1, 5, 1, function(v) lineThickness = v end)

RunService.RenderStepped:Connect(updateLineESP)
Players.PlayerAdded:Connect(updateLineESP)
Players.PlayerRemoving:Connect(updateLineESP)

-- =====================================================
-- TAB PLAYER - NO RECOIL, NO SPREAD, ANTI RAGDOLL
-- =====================================================
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

-- =====================================================
-- TAB ARSENAL - ARSENAL SPECIFIC + SILENT HITBOX
-- =====================================================
Window:AddParagraph(TabArsenal, "Arsenal Mods", "Fast Fire, Fast Reload, Unlock, Skin Changer")

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

-- ========== SILENT HITBOX ==========
Window:AddDivider(TabArsenal, "Silent Hitbox")
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

Window:AddToggle(TabArsenal, "Silent Hitbox", "Expand enemy hitboxes", false, function(v)
    silentHitbox = v
    if v then startSilentHitbox() else stopSilentHitbox() end
end)

Window:AddDropdown(TabArsenal, "Target Parts", "Select body part", {"All","Head","Torso","Legs"}, false, "All", function(v)
    targetPartsChoice = v
    if silentHitbox then stopSilentHitbox(); startSilentHitbox() end
end)

Window:AddSlider(TabArsenal, "Hitbox Expansion", "Size (1-30)", 1, 30, 13, function(v) hitboxExpansion = v end)
Window:AddSlider(TabArsenal, "Hitbox Alpha", "Transparency (0-10)", 0, 10, 3, function(v) hitboxAlpha = v / 10 end)

Window:AddButton(TabArsenal, "Reset Hitbox", "Restore default sizes", function()
    stopSilentHitbox()
    if silentHitbox then startSilentHitbox() end
    Window:Notify({Title="Reset Hitbox", Description="Hitbox restored to default", Color=Color3.fromRGB(255,255,0), Delay=2})
end)

-- =====================================================
-- FPS & PING DRAGGABLE
-- =====================================================
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

print("✅ W424HUB v3.8 LITE loaded - Size 500x300, optimized!")