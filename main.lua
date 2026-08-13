print("=== W424HUB - VoltilsUI Edition ===")

-- =============================================
-- [1] LOAD VOLTILSUI dengan error handling
-- =============================================
local VoltilsUI
local loadSuccess, loadErr = pcall(function()
    VoltilsUI = loadstring(game:HttpGet("https://bloxvault.org/load/qLALM"))()
end)

if not loadSuccess or not VoltilsUI then
    warn("❌ Gagal load VoltilsUI! Error:", loadErr or "Library nil")
    game:GetService("StarterGui"):SetCore("SendNotification", {
        Title = "W424HUB Error",
        Text = "Gagal load VoltilsUI! Cek koneksi atau gunakan executor yang support.",
        Duration = 5
    })
    return
else
    print("✅ VoltilsUI loaded successfully!")
end

-- =============================================
-- [2] INIT WINDOW (tanpa IntroSoundId)
-- =============================================
local UI = VoltilsUI:Init({
    title = "W424HUB",
    company = "W424",
    DiscordInvite = "discord.gg/example",
    LogoIcon = "93061773121162",
    -- IntroSoundId dihapus agar tidak error
    backgroundTransparency = 0,
    SelectorUserImages = true,
    Resizable = true,
    WindowMinSize = Vector2.new(360, 300),
    WindowMaxSize = Vector2.new(900, 620),
    InterfaceKey = Enum.KeyCode.RightShift,
    RainbowEnabled = true,
    Hints = {"W424HUB - VoltilsUI Edition", "Tekan RightShift untuk buka/tutup"},
    KeySystem = false,
})

print("✅ Window created!")

-- =============================================
-- [3] BUAT TAB
-- =============================================
local TabAim = UI:NewTab("Aim", "crosshair")
local TabVisual = UI:NewTab("Visual", "eye")
local TabPlayer = UI:NewTab("Player", "user")
local TabArsenal = UI:NewTab("Arsenal", "sword")

print("✅ Tabs created")

-- =============================================
-- [4] VARIABLES GLOBAL (sama)
-- =============================================
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local camera = workspace.CurrentCamera
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local CoreGui = game:GetService("CoreGui")
local StarterGui = game:GetService("StarterGui")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")
local Lighting = game:GetService("Lighting")

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

-- Player Mods
local noRecoil = false
local noSpread = false
local antiRagdoll = false

-- Arsenal Mods
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

-- =============================================
-- [5] TAB AIM
-- =============================================
TabAim:EnableSplitSections({ Sides = 2 })

TabAim:NewSection("Aimbot Settings", "Left")

TabAim:NewToggle("Enable Aimbot", false, function(v) aimbotEnabled = v end)

TabAim:NewSelector("Aim Mode", "Camera", {"Camera", "Silent"}, function(v) aimMode = v end)

TabAim:NewSelector("Trigger", "On Shoot", {"On Shoot", "Always"}, function(v) aimTrigger = v end)

TabAim:NewSelector("Target Part", "Head", {"Head", "HumanoidRootPart", "Torso", "UpperTorso"}, function(v) targetPart = v end)

TabAim:NewToggle("Headshot Only", false, function(v) 
    headshotOnly = v
    if v then targetPart = "Head" end
end)

TabAim:NewToggle("Anti Team", true, function(v) useTeamCheck = v end)

TabAim:NewToggle("Visibility Check", true, function(v) useVisCheck = v end)

TabAim:NewToggle("Prediction", false, function(v) usePrediction = v end)

TabAim:NewSection("Aimbot Values", "Right")

TabAim:NewSlider("FOV Radius", "px", false, "/", {min = 30, max = 400, default = 100}, function(v) fovRadius = v end)

TabAim:NewSlider("Max Distance", "stud", false, "/", {min = 50, max = 500, default = 300}, function(v) maxDistance = v end)

TabAim:NewSlider("Prediction Factor", "%", false, "/", {min = 0, max = 100, default = 20}, function(v) predFactor = v / 100 end)

TabAim:NewSlider("Smoothness", "%", false, "/", {min = 1, max = 100, default = 100}, function(v) smoothness = v / 100 end)

-- FOV Circle
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

TabAim:NewToggle("Show FOV Circle", false, function(v) fovCircle.Visible = v end)

-- =============================================
-- [6] TAB VISUAL
-- =============================================
TabVisual:EnableSplitSections({ Sides = 2 })

TabVisual:NewSection("ESP Chams", "Left")

TabVisual:NewToggle("Enable ESP", false, function(v)
    espEnabled = v
    if not v then clearESP() end
end)

TabVisual:NewToggle("ESP Team Check", true, function(v) espTeam = v end)

-- Color picker menggunakan pilihan warna
local colorOptions = {"Merah", "Hijau", "Biru", "Kuning", "Ungu", "Putih"}
local colorMap = {
    Merah = Color3.fromRGB(255,0,0),
    Hijau = Color3.fromRGB(0,255,0),
    Biru = Color3.fromRGB(0,0,255),
    Kuning = Color3.fromRGB(255,255,0),
    Ungu = Color3.fromRGB(255,0,255),
    Putih = Color3.fromRGB(255,255,255)
}
TabVisual:NewSelector("ESP Color", "Merah", colorOptions, function(v)
    espColor = colorMap[v]
    for _, h in pairs(highlightObjects) do 
        if h then h.FillColor = espColor end 
    end
end)

TabVisual:NewSlider("ESP Transparency", "/10", false, "/", {min = 0, max = 10, default = 3}, function(v)
    espTransparency = v / 10
    for _, h in pairs(highlightObjects) do 
        if h then h.FillTransparency = espTransparency end 
    end
end)

TabVisual:NewSection("Optimization", "Right")

TabVisual:NewToggle("Reduce Map (Disable Minimap)", false, function(v)
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
end)

TabVisual:NewToggle("Show FPS & Ping", false, function(v)
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
end)

-- =============================================
-- [7] TAB PLAYER
-- =============================================
TabPlayer:NewSection("Player Mods")
TabPlayer:NewToggle("No Recoil", false, function(v) noRecoil = v end)
TabPlayer:NewToggle("No Spread", false, function(v) noSpread = v end)
TabPlayer:NewToggle("Anti Ragdoll", false, function(v) antiRagdoll = v end)

-- =============================================
-- [8] TAB ARSENAL
-- =============================================
TabArsenal:EnableSplitSections({ Sides = 2 })

TabArsenal:NewSection("Arsenal Mods", "Left")

TabArsenal:NewToggle("Fast Fire Rate", false, function(v)
    fastFire = v
    local weapons = ReplicatedStorage:FindFirstChild("Weapons")
    if weapons then
        for _, w in ipairs(weapons:GetChildren()) do
            if w:FindFirstChild("FireRate") then w.FireRate.Value = v and 0.01 or 0.1 end
            if w:FindFirstChild("BFireRate") then w.BFireRate.Value = v and 0.01 or 0.1 end
        end
    end
end)

TabArsenal:NewToggle("Fast Reload", false, function(v)
    fastReload = v
    local weapons = ReplicatedStorage:FindFirstChild("Weapons")
    if weapons then
        for _, w in ipairs(weapons:GetChildren()) do
            if w:FindFirstChild("ReloadTime") then w.ReloadTime.Value = v and 0.01 or 1.5 end
        end
    end
end)

TabArsenal:NewToggle("Infinite Ammo", false, function(v)
    infiniteAmmo = v
    if v then
        pcall(function()
            local wkspc = ReplicatedStorage:FindFirstChild("wkspc")
            if wkspc and wkspc:FindFirstChild("CurrentCurse") then
                wkspc.CurrentCurse.Value = 'Infinite Ammo'
            end
        end)
    end
end)

TabArsenal:NewToggle("No Recoil (Arsenal)", false, function(v)
    arsenalNoRecoil = v
    local weapons = ReplicatedStorage:FindFirstChild("Weapons")
    if weapons then
        for _, w in ipairs(weapons:GetChildren()) do
            if w:FindFirstChild("RecoilControl") then w.RecoilControl.Value = v and 0 or 1 end
        end
    end
end)

TabArsenal:NewToggle("No Spread (Arsenal)", false, function(v)
    arsenalNoSpread = v
    local weapons = ReplicatedStorage:FindFirstChild("Weapons")
    if weapons then
        for _, w in ipairs(weapons:GetChildren()) do
            if w:FindFirstChild("MaxSpread") then w.MaxSpread.Value = v and 0.01 or 1 end
            if w:FindFirstChild("SpreadRecovery") then w.SpreadRecovery.Value = v and 0.01 or 0.5 end
        end
    end
end)

TabArsenal:NewSection("Unlock & Skin Changer", "Right")

-- Unlock All Items
local function AddEveryItem()
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
    game:GetService("StarterGui"):SetCore("SendNotification", {
        Title = "Unlock All",
        Text = "All items unlocked!",
        Duration = 3
    })
end

TabArsenal:NewButton("Unlock All Items", AddEveryItem)

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

local charSkins = GetSkinList("Character")
TabArsenal:NewSelector("Character Skin", charSkins[1] or "Default", charSkins, function(v) ChangeSkin("Character", v) end)

local meleeSkins = GetSkinList("Melee")
TabArsenal:NewSelector("Melee Skin", meleeSkins[1] or "Default", meleeSkins, function(v) ChangeSkin("Melee", v) end)

local gunSkins = GetSkinList("Gun")
TabArsenal:NewSelector("Gun Skin", gunSkins[1] or "Default", gunSkins, function(v) ChangeSkin("GunSkin", v) end)

local killSkins = GetSkinList("KillEffect")
TabArsenal:NewSelector("Kill Effect", killSkins[1] or "Default", killSkins, function(v) ChangeSkin("KillEffect", v) end)

local announcerSkins = GetSkinList("Announcer")
TabArsenal:NewSelector("Announcer", announcerSkins[1] or "Default", announcerSkins, function(v) ChangeSkin("Announcer", v) end)

-- =============================================
-- [9] SILENT HITBOX
-- =============================================
TabArsenal:NewSection("Silent Hitbox", "Left")

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

TabArsenal:NewToggle("Enable Silent Hitbox", false, function(v)
    silentHitbox = v
    if v then startHitbox() else stopHitbox() end
end)

TabArsenal:NewSelector("Target Parts", "All", {"All", "Head", "Torso", "Legs"}, function(v)
    targetPartsChoice = v
    if silentHitbox then
        stopHitbox()
        startHitbox()
    end
end)

TabArsenal:NewSlider("Hitbox Expansion", "x", false, "/", {min = 1, max = 30, default = 13}, function(v) hitboxExpansion = v end)

TabArsenal:NewSlider("Hitbox Alpha", "/10", false, "/", {min = 0, max = 10, default = 3}, function(v) hitboxAlpha = v / 10 end)

TabArsenal:NewButton("Reset Hitbox", function()
    stopHitbox()
    if silentHitbox then startHitbox() end
    game:GetService("StarterGui"):SetCore("SendNotification", {
        Title = "Reset",
        Text = "Hitbox reset to default",
        Duration = 2
    })
end)

-- =============================================
-- [10] FUNGSI AIMBOT & ESP
-- =============================================
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

-- Silent Aimbot
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

-- ESP Functions
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

-- =============================================
-- [11] NO RECOIL / NO SPREAD / ANTI RAGDOLL
-- =============================================
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

-- =============================================
-- [12] FPS & PING UPDATER
-- =============================================
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

-- =============================================
-- [13] SELESAI
-- =============================================
print("✅ W424HUB - VoltilsUI Edition loaded!")
game:GetService("StarterGui"):SetCore("SendNotification", {
    Title = "W424HUB",
    Text = "All features ready! Tekan RightShift untuk buka GUI.",
    Duration = 3
})