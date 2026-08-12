-- ========== W424HUB v5.0 - WindUI Edition ==========
print("=== W424HUB - WindUI Loading ===")

-- ========== LOAD WINDUI ==========
local WindUI = loadstring(game:HttpGet("https://raw.githubusercontent.com/Footagesus/WindUI/main/dist/main.lua"))()
if not WindUI then
    warn("❌ Gagal load WindUI!")
    return
end
print("✅ WindUI loaded")

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

-- ========== BUAT WINDOW ==========
local Window = WindUI:CreateWindow({
    Title = "W424HUB",
    Icon = "target",                   -- Ikon dari Lucide
    Author = "W424",
    Folder = "W424HUB_WindUI",
    Transparency = 0.85,               -- Background transparan (glass effect)
    Theme = {
        Background = Color3.fromRGB(15, 15, 25),   -- Warna dasar gelap
        Accent = Color3.fromRGB(220, 50, 50),      -- Warna aksen merah (Crimson)
        Text = Color3.fromRGB(255, 255, 255),
        Border = Color3.fromRGB(60, 60, 80)
    }
})

-- Notifikasi awal
WindUI:Notify({
    Title = "W424HUB",
    Description = "Loaded with WindUI!",
    Icon = "check",
    Duration = 4
})

-- ========== TAB ==========
local TabAim = Window:CreateTab({ Name = "Aim", Icon = "crosshair" })
local TabVisual = Window:CreateTab({ Name = "Visual", Icon = "eye" })
local TabPlayer = Window:CreateTab({ Name = "Player", Icon = "user" })
local TabArsenal = Window:CreateTab({ Name = "Arsenal", Icon = "sword" })

-- =====================================================
-- VARIABLES GLOBAL
-- =====================================================
-- Aimbot
local aimbotEnabled = false
local aimMode = "Camera"
local aimTrigger = "On Shoot"
local isShooting = false
local targetPart = "Head"
local headshotOnly = false
local fovRadius = 100
local maxDistance = 300
local usePrediction = false
local predFactor = 0.2
local useVisCheck = true
local useTeamCheck = true
local smoothness = 1
local target = nil

-- ESP
local espEnabled = false
local espColor = Color3.fromRGB(255, 0, 0)
local espTeam = true
local espTransparency = 0.3
local highlightObjects = {}

-- Player
local noRecoil = false
local noSpread = false
local antiRagdoll = false

-- Arsenal
local fastFire = false
local fastReload = false
local infiniteAmmo = false
local arsenalNoRecoil = false
local arsenalNoSpread = false

-- Silent Hitbox
local silentHitbox = false
local hitboxExpansion = 13
local hitboxAlpha = 0.3
local targetPartsChoice = "All"
local silentLoopRunning = false
local silentLoopStop = false

-- Reduce Map
local reduceMap = false

-- FPS Ping
local statsOn = false
local statsFrame = nil
local statsText = nil

-- =====================================================
-- AIMBOT
-- =====================================================
TabAim:CreateSection({ Name = "Aimbot Settings" })

TabAim:CreateToggle({
    Name = "Enable Aimbot",
    Callback = function(v) aimbotEnabled = v end
})

TabAim:CreateDropdown({
    Name = "Aim Mode",
    Options = {"Camera", "Silent"},
    Default = "Camera",
    Callback = function(v) aimMode = v end
})

TabAim:CreateDropdown({
    Name = "Trigger",
    Options = {"On Shoot", "Always"},
    Default = "On Shoot",
    Callback = function(v) aimTrigger = v end
})

TabAim:CreateDropdown({
    Name = "Target Part",
    Options = {"Head", "HumanoidRootPart", "Torso", "UpperTorso"},
    Default = "Head",
    Callback = function(v) targetPart = v end
})

TabAim:CreateToggle({
    Name = "Headshot Only",
    Callback = function(v)
        headshotOnly = v
        if v then targetPart = "Head" end
    end
})

TabAim:CreateToggle({
    Name = "Anti Team",
    Default = true,
    Callback = function(v) useTeamCheck = v end
})

TabAim:CreateToggle({
    Name = "Visibility Check",
    Default = true,
    Callback = function(v) useVisCheck = v end
})

TabAim:CreateToggle({
    Name = "Prediction",
    Callback = function(v) usePrediction = v end
})

TabAim:CreateSlider({
    Name = "FOV Radius",
    Min = 30,
    Max = 400,
    Default = 100,
    Suffix = "px",
    Callback = function(v) fovRadius = v end
})

TabAim:CreateSlider({
    Name = "Max Distance",
    Min = 50,
    Max = 500,
    Default = 300,
    Suffix = "stud",
    Callback = function(v) maxDistance = v end
})

TabAim:CreateSlider({
    Name = "Prediction Factor",
    Min = 0,
    Max = 100,
    Default = 20,
    Suffix = "%",
    Callback = function(v) predFactor = v / 100 end
})

TabAim:CreateSlider({
    Name = "Smoothness",
    Min = 1,
    Max = 100,
    Default = 100,
    Suffix = "%",
    Callback = function(v) smoothness = v / 100 end
})

-- FOV Circle (WindUI tidak punya bawaan, kita buat manual)
local fovCircle = Drawing.new("Circle")
fovCircle.Visible = false
fovCircle.Radius = fovRadius
fovCircle.Color = Color3.new(1, 1, 1)
fovCircle.Thickness = 2
fovCircle.Filled = false
fovCircle.Position = Vector2.new(camera.ViewportSize.X / 2, camera.ViewportSize.Y / 2)

RunService.RenderStepped:Connect(function()
    fovCircle.Position = Vector2.new(camera.ViewportSize.X / 2, camera.ViewportSize.Y / 2)
end)

TabAim:CreateToggle({
    Name = "Show FOV Circle",
    Callback = function(v) fovCircle.Visible = v end
})

-- =====================================================
-- VISUAL TAB
-- =====================================================
TabVisual:CreateSection({ Name = "ESP Chams" })

TabVisual:CreateToggle({
    Name = "Enable ESP",
    Callback = function(v) espEnabled = v; if not v then clearESP() end end
})

TabVisual:CreateToggle({
    Name = "ESP Team Check",
    Default = true,
    Callback = function(v) espTeam = v end
})

TabVisual:CreateColorPicker({
    Name = "ESP Color",
    Default = Color3.fromRGB(255,0,0),
    Callback = function(c)
        espColor = c
        for _, h in pairs(highlightObjects) do if h then h.FillColor = c end end
    end
})

TabVisual:CreateSlider({
    Name = "ESP Transparency",
    Min = 0,
    Max = 10,
    Default = 3,
    Suffix = "/10",
    Callback = function(v)
        espTransparency = v / 10
        for _, h in pairs(highlightObjects) do if h then h.FillTransparency = espTransparency end end
    end
})

-- Reduce Map
TabVisual:CreateSection({ Name = "Optimization" })
TabVisual:CreateToggle({
    Name = "Reduce Map (Disable Minimap)",
    Callback = function(v)
        reduceMap = v
        if v then
            pcall(function() StarterGui:SetCore("MinimapEnabled", false) end)
            for _, gui in ipairs(CoreGui:GetChildren()) do
                if gui.Name:lower():find("minimap") then gui.Enabled = false end
            end
            for _, gui in ipairs(LocalPlayer.PlayerGui:GetChildren()) do
                if gui.Name:lower():find("minimap") then gui.Enabled = false end
            end
        else
            pcall(function() StarterGui:SetCore("MinimapEnabled", true) end)
            for _, gui in ipairs(CoreGui:GetChildren()) do
                if gui.Name:lower():find("minimap") then gui.Enabled = true end
            end
            for _, gui in ipairs(LocalPlayer.PlayerGui:GetChildren()) do
                if gui.Name:lower():find("minimap") then gui.Enabled = true end
            end
        end
    end
})

-- FPS & Ping
TabVisual:CreateToggle({
    Name = "Show FPS & Ping",
    Callback = function(v)
        statsOn = v
        if v then
            if not statsFrame then
                statsFrame = Drawing.new("Frame")
                statsFrame.Visible = true
                statsFrame.ZIndex = 999
                statsFrame.BackgroundColor = Color3.new(0,0,0)
                statsFrame.BackgroundTransparency = 0.7
                statsFrame.Position = Vector2.new(10, 10)
                statsFrame.Size = Vector2.new(160, 30)
                statsFrame.BorderColor = Color3.new(0.5,0.5,0.5)
                statsFrame.BorderThickness = 1

                statsText = Drawing.new("Text")
                statsText.Visible = true
                statsText.Position = Vector2.new(15, 16)
                statsText.Size = 14
                statsText.Color = Color3.new(0,1,0.5)
                statsText.Outline = true
                statsText.OutlineColor = Color3.new(0,0,0)
                statsText.Font = Drawing.Fonts.UI
                statsText.Text = "FPS: 0 | Ping: 0ms"
            end
            statsFrame.Visible = true
            statsText.Visible = true
        else
            if statsFrame then statsFrame.Visible = false end
            if statsText then statsText.Visible = false end
        end
    end
})

-- =====================================================
-- PLAYER TAB
-- =====================================================
TabPlayer:CreateSection({ Name = "Player Mods" })

TabPlayer:CreateToggle({
    Name = "No Recoil",
    Callback = function(v) noRecoil = v end
})

TabPlayer:CreateToggle({
    Name = "No Spread",
    Callback = function(v) noSpread = v end
})

TabPlayer:CreateToggle({
    Name = "Anti Ragdoll",
    Callback = function(v) antiRagdoll = v end
})

-- =====================================================
-- ARSENAL TAB
-- =====================================================
TabArsenal:CreateSection({ Name = "Arsenal Mods" })

TabArsenal:CreateToggle({
    Name = "Fast Fire Rate",
    Callback = function(v)
        fastFire = v
        local weapons = ReplicatedStorage:FindFirstChild("Weapons")
        if weapons then
            for _, w in ipairs(weapons:GetChildren()) do
                if w:FindFirstChild("FireRate") then w.FireRate.Value = v and 0.01 or 0.1 end
                if w:FindFirstChild("BFireRate") then w.BFireRate.Value = v and 0.01 or 0.1 end
            end
        end
    end
})

TabArsenal:CreateToggle({
    Name = "Fast Reload",
    Callback = function(v)
        fastReload = v
        local weapons = ReplicatedStorage:FindFirstChild("Weapons")
        if weapons then
            for _, w in ipairs(weapons:GetChildren()) do
                if w:FindFirstChild("ReloadTime") then w.ReloadTime.Value = v and 0.01 or 1.5 end
            end
        end
    end
})

TabArsenal:CreateToggle({
    Name = "Infinite Ammo",
    Callback = function(v)
        infiniteAmmo = v
        if v then
            pcall(function()
                local wkspc = ReplicatedStorage:FindFirstChild("wkspc")
                if wkspc and wkspc:FindFirstChild("CurrentCurse") then
                    wkspc.CurrentCurse.Value = 'Infinite Ammo'
                end
            end)
        end
    end
})

TabArsenal:CreateToggle({
    Name = "No Recoil (Arsenal)",
    Callback = function(v)
        arsenalNoRecoil = v
        local weapons = ReplicatedStorage:FindFirstChild("Weapons")
        if weapons then
            for _, w in ipairs(weapons:GetChildren()) do
                if w:FindFirstChild("RecoilControl") then w.RecoilControl.Value = v and 0 or 1 end
            end
        end
    end
})

TabArsenal:CreateToggle({
    Name = "No Spread (Arsenal)",
    Callback = function(v)
        arsenalNoSpread = v
        local weapons = ReplicatedStorage:FindFirstChild("Weapons")
        if weapons then
            for _, w in ipairs(weapons:GetChildren()) do
                if w:FindFirstChild("MaxSpread") then w.MaxSpread.Value = v and 0.01 or 1 end
                if w:FindFirstChild("SpreadRecovery") then w.SpreadRecovery.Value = v and 0.01 or 0.5 end
            end
        end
    end
})

-- Unlock All & Skin Changer
TabArsenal:CreateSection({ Name = "Unlock & Skin Changer" })

TabArsenal:CreateButton({
    Name = "Unlock All Items",
    Callback = function()
        local items = ReplicatedStorage:FindFirstChild("ItemData")
        if not items then return end
        local invData = nil
        for _, v in next, getgc(true) do
            if typeof(v) == 'table' and rawget(v, 'Loadout') and typeof(v.Items) == 'table' then
                invData = v.Items
                break
            end
        end
        if not invData then return end
        local images = items:FindFirstChild("Images")
        if images then
            for _, cat in ipairs(images:GetChildren()) do
                if invData[cat.Name] then
                    for _, item in ipairs(cat:GetChildren()) do
                        if not invData[cat.Name][item.Name] then
                            invData[cat.Name][item.Name] = 1
                        end
                    end
                end
            end
        end
        WindUI:Notify({ Title = "Unlock All", Description = "All items unlocked!", Icon = "check", Duration = 3 })
    end
})

-- Fungsi helper skin changer
local function ChangeSkin(skinType, skinName)
    if skinType == "Character" then
        if LocalPlayer:FindFirstChild("Data") and LocalPlayer.Data:FindFirstChild("Skin") then
            LocalPlayer.Data.Skin.Value = skinName
        end
    elseif skinType == "Melee" then
        if LocalPlayer:FindFirstChild("Data") and LocalPlayer.Data:FindFirstChild("Melee") then
            LocalPlayer.Data.Melee.Value = skinName
        end
    elseif skinType == "GunSkin" then
        if LocalPlayer:FindFirstChild("Equipped") then
            LocalPlayer.Equipped.Value = skinName
        end
    elseif skinType == "KillEffect" then
        if LocalPlayer:FindFirstChild("Data") and LocalPlayer.Data:FindFirstChild("KillEffect") then
            LocalPlayer.Data.KillEffect.Value = skinName
        end
    elseif skinType == "Announcer" then
        if LocalPlayer:FindFirstChild("Data") and LocalPlayer.Data:FindFirstChild("Announcer") then
            LocalPlayer.Data.Announcer.Value = skinName
        end
    end
end

local function GetSkinList(category)
    local list = {"Default"}
    local images = ReplicatedStorage:FindFirstChild("ItemData") and ReplicatedStorage.ItemData:FindFirstChild("Images")
    if images then
        for _, cat in ipairs(images:GetChildren()) do
            if cat.Name == category then
                for _, item in ipairs(cat:GetChildren()) do
                    table.insert(list, item.Name)
                end
            end
        end
    end
    return list
end

-- Dropdown skin
local charSkins = GetSkinList("Character")
TabArsenal:CreateDropdown({
    Name = "Character Skin",
    Options = charSkins,
    Default = charSkins[1] or "Default",
    Callback = function(v) ChangeSkin("Character", v) end
})

local meleeSkins = GetSkinList("Melee")
TabArsenal:CreateDropdown({
    Name = "Melee Skin",
    Options = meleeSkins,
    Default = meleeSkins[1] or "Default",
    Callback = function(v) ChangeSkin("Melee", v) end
})

local gunSkins = GetSkinList("Gun")
TabArsenal:CreateDropdown({
    Name = "Gun Skin",
    Options = gunSkins,
    Default = gunSkins[1] or "Default",
    Callback = function(v) ChangeSkin("GunSkin", v) end
})

local killSkins = GetSkinList("KillEffect")
TabArsenal:CreateDropdown({
    Name = "Kill Effect",
    Options = killSkins,
    Default = killSkins[1] or "Default",
    Callback = function(v) ChangeSkin("KillEffect", v) end
})

local announcerSkins = GetSkinList("Announcer")
TabArsenal:CreateDropdown({
    Name = "Announcer",
    Options = announcerSkins,
    Default = announcerSkins[1] or "Default",
    Callback = function(v) ChangeSkin("Announcer", v) end
})

-- =====================================================
-- SILENT HITBOX
-- =====================================================
TabArsenal:CreateSection({ Name = "Silent Hitbox" })

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

local function hitboxLoop()
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

local function startHitbox()
    if silentLoopRunning then return end
    silentLoopRunning = true
    silentLoopStop = false
    task.spawn(hitboxLoop)
end

local function stopHitbox()
    silentLoopStop = true
    task.wait(0.4)
    silentLoopRunning = false
    -- Reset
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

TabArsenal:CreateToggle({
    Name = "Enable Silent Hitbox",
    Callback = function(v)
        silentHitbox = v
        if v then startHitbox() else stopHitbox() end
    end
})

TabArsenal:CreateDropdown({
    Name = "Target Parts",
    Options = {"All", "Head", "Torso", "Legs"},
    Default = "All",
    Callback = function(v)
        targetPartsChoice = v
        if silentHitbox then
            stopHitbox()
            startHitbox()
        end
    end
})

TabArsenal:CreateSlider({
    Name = "Hitbox Expansion",
    Min = 1,
    Max = 30,
    Default = 13,
    Suffix = "x",
    Callback = function(v) hitboxExpansion = v end
})

TabArsenal:CreateSlider({
    Name = "Hitbox Alpha",
    Min = 0,
    Max = 10,
    Default = 3,
    Suffix = "/10",
    Callback = function(v) hitboxAlpha = v / 10 end
})

TabArsenal:CreateButton({
    Name = "Reset Hitbox",
    Callback = function()
        stopHitbox()
        if silentHitbox then startHitbox() end
        WindUI:Notify({ Title = "Reset", Description = "Hitbox reset to default", Icon = "refresh-cw", Duration = 2 })
    end
})

-- =====================================================
-- AIMBOT FUNCTIONS (Camera & Silent)
-- =====================================================
local function isVisible(part)
    if not useVisCheck or not part then return true end
    local success, result = pcall(function()
        local origin = camera.CFrame.Position
        local params = RaycastParams.new()
        params.FilterType = Enum.RaycastFilterType.Exclude
        params.FilterDescendantsInstances = {LocalPlayer.Character}
        params.IgnoreWater = true
        local direction = (part.Position - origin)
        return workspace:Raycast(origin, direction, params)
    end)
    if success and result then
        local hitChar = result.Instance:FindFirstAncestorOfClass("Model")
        if hitChar then
            local player = Players:GetPlayerFromCharacter(hitChar)
            return player ~= nil
        end
        return false
    else
        return true
    end
end

local function getBestTarget()
    local center = camera.ViewportSize / 2
    local best, bestDist = nil, math.huge
    local myChar = LocalPlayer.Character
    if not myChar then return nil end
    local myPos = myChar:FindFirstChild("HumanoidRootPart")
    if not myPos then return nil end
    myPos = myPos.Position

    for _, p in ipairs(Players:GetPlayers()) do
        if p == LocalPlayer then continue end
        local c = p.Character
        if not c then continue end
        local hum = c:FindFirstChildOfClass("Humanoid")
        if not hum or hum.Health <= 0 then continue end
        if useTeamCheck and LocalPlayer.Team and p.Team and LocalPlayer.Team == p.Team then continue end

        local part
        if headshotOnly then
            part = c:FindFirstChild("Head")
        else
            part = c:FindFirstChild(targetPart)
        end
        if not part then
            part = c:FindFirstChild("Head") or c:FindFirstChild("HumanoidRootPart") or c:FindFirstChild("Torso") or c:FindFirstChild("UpperTorso")
        end
        if not part then continue end

        local targetPos = part.Position
        if usePrediction then
            local velocity = part.Velocity or Vector3.new(0,0,0)
            targetPos = targetPos + (velocity * predFactor)
        end
        if headshotOnly then targetPos = targetPos + Vector3.new(0, 0.5, 0) end

        local jarak = (targetPos - myPos).Magnitude
        if jarak > maxDistance then continue end
        if not isVisible(part) then continue end

        local pos, on = camera:WorldToViewportPoint(targetPos)
        if on then
            local dist = (Vector2.new(pos.X, pos.Y) - center).Magnitude
            if dist <= fovRadius and dist < bestDist then
                bestDist = dist
                best = { Part = part, Position = targetPos, Player = p }
            end
        end
    end
    return best
end

-- Camera Aimbot
local frameSkip = 0
RunService.RenderStepped:Connect(function()
    frameSkip = frameSkip + 1
    if frameSkip % 3 ~= 0 then return end

    if not aimbotEnabled or aimMode ~= "Camera" then return end
    local canAim = (aimTrigger == "On Shoot" and isShooting) or (aimTrigger == "Always")
    if not canAim then return end
    local best = getBestTarget()
    if best then
        target = best
        local targetPos = best.Position
        local targetCF = CFrame.new(camera.CFrame.Position, targetPos)
        camera.CFrame = smoothness >= 1 and targetCF or camera.CFrame:Lerp(targetCF, smoothness)
    else target = nil end
end)

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

-- Silent Aimbot (hook)
pcall(function()
    local gc = getgc()
    for _, v in pairs(gc) do
        if type(v) == "function" and islclosure(v) then
            local constants = debug.getconstants(v)
            local hasKeyword = false
            for _, c in pairs(constants) do
                if type(c) == "string" then
                    local lower = c:lower()
                    if lower:find("fire") or lower:find("shoot") or lower:find("ray") or lower:find("bullet") then
                        hasKeyword = true
                        break
                    end
                end
            end
            if hasKeyword then
                local old
                old = hookfunction(v, function(p1, p2)
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
                                            if type(p1) == "userdata" and p1:IsA("Ray") then
                                                local direction = (best.Position - startPart.Position)
                                                p1 = Ray.new(startPart.Position, direction)
                                            elseif type(p2) == "userdata" and p2:IsA("CFrame") then
                                                local direction = (best.Position - startPart.Position)
                                                p2 = CFrame.new(startPart.Position, startPart.Position + direction)
                                            end
                                        end)
                                    end
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
end)

-- =====================================================
-- ESP FUNCTIONS
-- =====================================================
local function clearESP()
    for _, h in pairs(highlightObjects) do pcall(function() h:Destroy() end) end
    highlightObjects = {}
end

local function updateESP()
    if not espEnabled then clearESP(); return end
    for _, p in ipairs(Players:GetPlayers()) do
        if p == LocalPlayer then continue end
        local char = p.Character
        if not char then
            if highlightObjects[p] then pcall(function() highlightObjects[p]:Destroy() end); highlightObjects[p] = nil end
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
            h.FillTransparency = espTransparency
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
            pcall(function() h:Destroy() end)
            highlightObjects[p] = nil
        end
    end
end

Players.PlayerAdded:Connect(updateESP)
Players.PlayerRemoving:Connect(function(p) if highlightObjects[p] then pcall(function() highlightObjects[p]:Destroy() end); highlightObjects[p] = nil end end)
task.spawn(function()
    while true do
        task.wait(2)
        pcall(updateESP)
    end
end)

-- =====================================================
-- NO RECOIL / NO SPREAD / ANTI RAGDOLL
-- =====================================================
RunService.RenderStepped:Connect(function()
    local char = LocalPlayer.Character
    if not char then return end
    local hum = char:FindFirstChildOfClass("Humanoid")
    if not hum then return end

    if antiRagdoll then
        pcall(function()
            if hum.PlatformStand or hum.Sit then
                hum.PlatformStand = false
                hum.Sit = false
                local hrp = char:FindFirstChild("HumanoidRootPart")
                if hrp then hrp.Velocity = Vector3.new(0,0,0); hrp.RotVelocity = Vector3.new(0,0,0) end
            end
            if hum.SeatPart then hum.Sit = false end
        end)
    end

    local tool = char:FindFirstChildOfClass("Tool")
    if tool then
        if noRecoil then
            for _, prop in ipairs({"Recoil","recoil","Kickback","GunRecoil","Shake","CameraRecoil"}) do
                pcall(function() if tool[prop] ~= nil and type(tool[prop]) == "number" then tool[prop] = 0 end end)
            end
        end
        if noSpread then
            for _, prop in ipairs({"Spread","spread","Accuracy","Inaccuracy","BulletSpread","Deviation"}) do
                pcall(function() if tool[prop] ~= nil and type(tool[prop]) == "number" then tool[prop] = 0 end end)
            end
        end
    end
end)

-- =====================================================
-- FPS & PING UPDATER
-- =====================================================
local fpsCounter = 0
local fpsTime = 0

RunService.RenderStepped:Connect(function(dt)
    if statsOn and statsText then
        fpsCounter = fpsCounter + 1
        fpsTime = fpsTime + dt
        if fpsTime >= 1 then
            local ping = 0
            pcall(function() ping = LocalPlayer:GetNetworkPing() * 1000 end)
            statsText.Text = string.format("FPS: %d | Ping: %.0fms", fpsCounter, ping)
            fpsCounter = 0
            fpsTime = 0
        end
    end
end)

-- =====================================================
-- SELESAI
-- =====================================================
print("✅ W424HUB - WindUI Edition loaded!")
WindUI:Notify({
    Title = "W424HUB",
    Description = "All features ready!",
    Icon = "check",
    Duration = 3
})
