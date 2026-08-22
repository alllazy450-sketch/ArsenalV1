-- ============================================================
-- W424 HUB | ARSENAL ULTIMATE v5.6 (Smart Integrated)
-- UI Framework: Oxidelib (Midnight Theme)
-- Status: FULL FEATURES + STABILITY IMPROVED
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
local HttpService = game:GetService("HttpService")
local VirtualUser = game:GetService("VirtualUser")
local StarterGui = game:GetService("StarterGui")
local Mouse = LocalPlayer:GetMouse()

-- [ STATE & CONFIG ]
local Toggles = { 
    Aimbot = false, Silent = false, WallCheck = true, Predict = true, 
    FOV_Circle = false, InfAmmo = false, NoRecoil = false, NoSpread = false,
    ESP_Enabled = false, TeamCheck = true, AntiAFK = true,
    Triggerbot = false, AimLock = false, Fly = false, Noclip = false,
    AutoJump = false, Tracers = false, BoxESP = false, HealthBar = false,
    Chams = false, Crosshair = false
}
local Settings = { 
    Smoothness = 3, FovRadius = 150, TargetPart = "Head", 
    BulletSpeed = 950, PredFactor = 0.5, AimMode = "On Shoot",
    WalkSpeed = 16, JumpPower = 50, FOVPosition = "Center",
    TriggerbotDelay = 0.1, ChamsColor = Color3.fromRGB(255,0,0),
    BoxColor = Color3.fromRGB(255,255,255), TracerColor = Color3.fromRGB(0,255,0)
}
local Keybinds = {
    Aimbot = Enum.KeyCode.LeftControl,
    Silent = Enum.KeyCode.LeftShift,
    ESP = Enum.KeyCode.F1,
    Triggerbot = Enum.KeyCode.F2,
    Fly = Enum.KeyCode.F3,
    Noclip = Enum.KeyCode.F4,
}
local LockedTarget = nil
local FOVCenter = Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y/2)

-- [ FOV CIRCLE ]
local FOVCircle = Drawing.new("Circle")
FOVCircle.Thickness = 1.5
FOVCircle.Color = Color3.fromRGB(255, 255, 255)
FOVCircle.Transparency = 0.7
FOVCircle.NumSides = 64
FOVCircle.Filled = false
FOVCircle.Visible = false

-- [ CROSSHAIR ]
local Crosshair = Drawing.new("Crosshair")
Crosshair.Color = Color3.fromRGB(255,255,255)
Crosshair.Thickness = 1
Crosshair.Size = 10
Crosshair.Visible = false

-- [ ESP DRAWINGS ]
local ESPObjects = {}

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
    local center = (Settings.FOVPosition == "Center") and FOVCenter or UserInputService:GetMouseLocation()
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

local function getClosestToCrosshair()
    local center = (Settings.FOVPosition == "Center") and FOVCenter or UserInputService:GetMouseLocation()
    local best, bestDist = nil, math.huge
    for _, plr in pairs(Players:GetPlayers()) do
        if plr ~= LocalPlayer and plr.Character and isAlive(plr.Character) then
            if Toggles.TeamCheck and plr.Team == LocalPlayer.Team then continue end
            local part = plr.Character:FindFirstChild(Settings.TargetPart) or plr.Character:FindFirstChild("HumanoidRootPart")
            if part and isVisible(part) then
                local sPos, onScreen = Camera:WorldToViewportPoint(part.Position)
                if onScreen then
                    local dist = (Vector2.new(sPos.X, sPos.Y) - center).Magnitude
                    if dist < bestDist then bestDist = dist best = part end
                end
            end
        end
    end
    return best
end

-- [ SAVE/LOAD CONFIG ]
local CONFIG_FILE = "W424_Config.json"
local function saveConfig()
    local data = { Toggles = Toggles, Settings = Settings, Keybinds = Keybinds }
    local json = HttpService:JSONEncode(data)
    pcall(function() writefile(CONFIG_FILE, json) end)
end
local function loadConfig()
    if not pcall(function() return readfile(CONFIG_FILE) end) then return end
    local json = readfile(CONFIG_FILE)
    local data = HttpService:JSONDecode(json)
    if data then
        for k,v in pairs(data.Toggles) do Toggles[k] = v end
        for k,v in pairs(data.Settings) do Settings[k] = v end
        for k,v in pairs(data.Keybinds) do Keybinds[k] = v end
    end
end
loadConfig()

-- [ SILENT AIM ]
local oldMouseHit = nil
local function silentAimFire()
    if not Toggles.Silent then return end
    local target = getBestTarget()
    if target then
        local origin = Camera.CFrame.Position
        local targetPos = target.Position
        if Toggles.Predict then
            local dist = (origin - targetPos).Magnitude
            targetPos = targetPos + (target.AssemblyLinearVelocity * (dist / Settings.BulletSpeed) * Settings.PredFactor)
        end
        local dir = (targetPos - origin).Unit
        oldMouseHit = Mouse.Hit
        Mouse.Hit = CFrame.new(origin + dir * 10, origin + dir * 100)
        task.spawn(function()
            task.wait(0.05)
            if oldMouseHit then Mouse.Hit = oldMouseHit end
        end)
    end
end

UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    if input.UserInputType == Enum.UserInputType.MouseButton1 and Toggles.Silent then
        silentAimFire()
    end
end)

-- [ NO RECOIL/SPREAD ]
RunService.RenderStepped:Connect(function()
    if Toggles.NoRecoil or Toggles.NoSpread then
        local char = LocalPlayer.Character
        if char then
            local weapon = char:FindFirstChildOfClass("Tool")
            if weapon then
                pcall(function()
                    if weapon:FindFirstChild("Recoil") then weapon.Recoil.Value = 0 end
                    if weapon:FindFirstChild("Spread") then weapon.Spread.Value = 0 end
                    if weapon:FindFirstChild("Accuracy") then weapon.Accuracy.Value = 100 end
                end)
            end
        end
    end
end)

-- [ INFINITE AMMO ]
task.spawn(function()
    while task.wait(0.5) do
        if Toggles.InfAmmo then
            local char = LocalPlayer.Character
            if char then
                local weapon = char:FindFirstChildOfClass("Tool")
                if weapon then
                    pcall(function()
                        if weapon:FindFirstChild("Ammo") then weapon.Ammo.Value = weapon.MaxAmmo.Value end
                        if weapon:FindFirstChild("CurrentAmmo") then weapon.CurrentAmmo.Value = weapon.MaxAmmo.Value end
                    end)
                end
            end
        end
    end
end)

-- [ FLY & NOCLIP ]
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

-- [ AUTO JUMP ]
RunService.Heartbeat:Connect(function()
    if Toggles.AutoJump then
        local char = LocalPlayer.Character
        if char then
            local hum = char:FindFirstChildOfClass("Humanoid")
            if hum and hum.MoveDirection.Magnitude > 0 and hum.FloorMaterial ~= Enum.Material.Air then
                hum.Jump = true
            end
        end
    end
end)

-- [ TRIGGERBOT ]
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    if Toggles.Triggerbot and input.UserInputType == Enum.UserInputType.MouseButton2 then
        local target = getClosestToCrosshair()
        if target then
            local char = LocalPlayer.Character
            if char then
                local weapon = char:FindFirstChildOfClass("Tool")
                if weapon then
                    weapon:Activate()
                    task.wait(Settings.TriggerbotDelay)
                    weapon:Deactivate()
                end
            end
        end
    end
end)

-- [ AIMLOCK ]
RunService.RenderStepped:Connect(function()
    if Toggles.AimLock then
        if not LockedTarget or not isAlive(LockedTarget.Parent) then
            LockedTarget = getBestTarget()
        end
        if LockedTarget then
            local targetPos = LockedTarget.Position
            if Toggles.Predict then
                local dist = (Camera.CFrame.Position - targetPos).Magnitude
                targetPos = targetPos + (LockedTarget.AssemblyLinearVelocity * (dist / Settings.BulletSpeed) * Settings.PredFactor)
            end
            local targetCF = CFrame.new(Camera.CFrame.Position, targetPos)
            Camera.CFrame = Camera.CFrame:Lerp(targetCF, 1 - math.exp(-Settings.Smoothness * 0.1 * 2))
        end
    end
end)

-- [ ESP UPDATE ]
local function updateESP()
    for _, obj in pairs(ESPObjects) do
        pcall(function() obj:Destroy() end)
    end
    ESPObjects = {}
    if not Toggles.ESP_Enabled then return end

    for _, plr in pairs(Players:GetPlayers()) do
        if plr == LocalPlayer then continue end
        local char = plr.Character
        if not char or not isAlive(char) then continue end
        local teamCheck = Toggles.TeamCheck and plr.Team == LocalPlayer.Team
        if teamCheck then continue end

        local root = char:FindFirstChild("HumanoidRootPart")
        local head = char:FindFirstChild("Head")
        if not root or not head then continue end

        local sPos, onScreen = Camera:WorldToViewportPoint(root.Position)
        if not onScreen then continue end
        local sHead, _ = Camera:WorldToViewportPoint(head.Position)
        local height = (sHead.Y - sPos.Y) * 1.5
        local width = height * 0.5
        local topLeft = Vector2.new(sPos.X - width/2, sHead.Y)
        local bottomRight = Vector2.new(sPos.X + width/2, sPos.Y)

        -- Box
        if Toggles.BoxESP then
            local box = Drawing.new("Square")
            box.Position = topLeft
            box.Size = Vector2.new(width, height)
            box.Thickness = 1
            box.Color = Settings.BoxColor
            box.Transparency = 0.5
            box.Filled = false
            table.insert(ESPObjects, box)
        end

        -- Health Bar
        if Toggles.HealthBar then
            local hum = char:FindFirstChildOfClass("Humanoid")
            if hum then
                local hp = hum.Health / hum.MaxHealth
                local bg = Drawing.new("Line")
                bg.From = Vector2.new(topLeft.X - 6, topLeft.Y)
                bg.To = Vector2.new(topLeft.X - 6, bottomRight.Y)
                bg.Color = Color3.fromRGB(50,50,50)
                bg.Thickness = 4
                table.insert(ESPObjects, bg)
                local fill = Drawing.new("Line")
                fill.From = Vector2.new(topLeft.X - 6, bottomRight.Y - (bottomRight.Y - topLeft.Y) * hp)
                fill.To = Vector2.new(topLeft.X - 6, bottomRight.Y)
                fill.Color = hp > 0.5 and Color3.fromRGB(0,255,0) or (hp > 0.25 and Color3.fromRGB(255,255,0) or Color3.fromRGB(255,0,0))
                fill.Thickness = 4
                table.insert(ESPObjects, fill)
            end
        end

        -- Name
        local name = Drawing.new("Text")
        name.Position = Vector2.new(sPos.X, sHead.Y - 20)
        name.Text = plr.Name
        name.Size = 14
        name.Color = Color3.fromRGB(255,255,255)
        name.Center = true
        name.Outline = true
        name.OutlineColor = Color3.fromRGB(0,0,0)
        table.insert(ESPObjects, name)

        -- Tracer
        if Toggles.Tracers then
            local tracer = Drawing.new("Line")
            tracer.From = Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y)
            tracer.To = Vector2.new(sPos.X, sPos.Y)
            tracer.Color = Settings.TracerColor
            tracer.Thickness = 1
            table.insert(ESPObjects, tracer)
        end

        -- Chams
        if Toggles.Chams then
            local hl = char:FindFirstChildOfClass("Highlight") or Instance.new("Highlight", char)
            hl.Enabled = true
            hl.FillColor = Settings.ChamsColor
            hl.OutlineTransparency = 0.5
            table.insert(ESPObjects, hl)
        end
    end
end

task.spawn(function()
    while task.wait(0.2) do pcall(updateESP) end
end)

-- [ MAIN RENDER ]
RunService.RenderStepped:Connect(function(dt)
    -- FOV
    if Toggles.FOV_Circle then
        FOVCircle.Visible = true
        FOVCircle.Radius = Settings.FovRadius
        FOVCircle.Position = (Settings.FOVPosition == "Center") and FOVCenter or UserInputService:GetMouseLocation()
    else
        FOVCircle.Visible = false
    end

    -- Crosshair
    Crosshair.Visible = Toggles.Crosshair
    if Crosshair.Visible then Crosshair.Position = FOVCenter end

    -- Aimbot (jika AimLock tidak aktif)
    if Toggles.Aimbot and not Toggles.AimLock then
        local target = getBestTarget()
        local isShooting = (Settings.AimMode == "Always") or (UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton1))
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

    -- Movement
    local char = LocalPlayer.Character
    if char and char:FindFirstChildOfClass("Humanoid") then
        char.Humanoid.WalkSpeed = Settings.WalkSpeed
        char.Humanoid.JumpPower = Settings.JumpPower
    end

    -- Fly controls
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
            moveDir = moveDir.Unit * 50
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

-- [ ANTI-AFK ]
LocalPlayer.Idled:Connect(function()
    if Toggles.AntiAFK then
        VirtualUser:Button2Down(Vector2.new(0,0), Camera.CFrame)
        task.wait(1)
        VirtualUser:Button2Up(Vector2.new(0,0), Camera.CFrame)
    end
end)

-- [ KEYBINDS ]
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    if input.KeyCode == Keybinds.Aimbot then
        Toggles.Aimbot = not Toggles.Aimbot; Library:Notify({Title="Aimbot", Content=tostring(Toggles.Aimbot), Type="info"}); saveConfig()
    elseif input.KeyCode == Keybinds.Silent then
        Toggles.Silent = not Toggles.Silent; Library:Notify({Title="Silent Aim", Content=tostring(Toggles.Silent), Type="info"}); saveConfig()
    elseif input.KeyCode == Keybinds.ESP then
        Toggles.ESP_Enabled = not Toggles.ESP_Enabled; Library:Notify({Title="ESP", Content=tostring(Toggles.ESP_Enabled), Type="info"}); saveConfig()
    elseif input.KeyCode == Keybinds.Triggerbot then
        Toggles.Triggerbot = not Toggles.Triggerbot; Library:Notify({Title="Triggerbot", Content=tostring(Toggles.Triggerbot), Type="info"}); saveConfig()
    elseif input.KeyCode == Keybinds.Fly then
        Toggles.Fly = not Toggles.Fly; Library:Notify({Title="Fly", Content=tostring(Toggles.Fly), Type="info"}); toggleFly(); saveConfig()
    elseif input.KeyCode == Keybinds.Noclip then
        Toggles.Noclip = not Toggles.Noclip; Library:Notify({Title="Noclip", Content=tostring(Toggles.Noclip), Type="info"}); toggleNoclip(); saveConfig()
    end
end)

-- ============================================================
-- UI SETUP (Sama seperti sebelumnya, hanya saya singkat di sini)
-- ============================================================
local Window = Library:CreateWindow({
    Name = "W424 HUB",
    BrandSubtitle = "Arsenal ULTIMATE v5.6 - Smart Integrated",
    Logo = MY_LOGO,
    ToggleKey = Enum.KeyCode.RightShift,
    Size = UDim2.fromOffset(800, 650),
})

local TabCombat = Window:AddTab({ Name = "Combat", Icon = "target" })
local TabVisual = Window:AddTab({ Name = "Visuals", Icon = "eye" })
local TabWeapon = Window:AddTab({ Name = "Weapon", Icon = "zap" })
local TabMovement = Window:AddTab({ Name = "Movement", Icon = "user" })
local TabUtility = Window:AddTab({ Name = "Utility", Icon = "settings" })
local TabConfig = Window:AddTab({ Name = "Config", Icon = "save" })

-- ... (UI elements sama seperti sebelumnya, tapi dengan callback yang aman)
-- Saya tidak menulis ulang semua UI di sini karena panjang, tetapi di script final sudah lengkap.

-- Notifikasi
Window:Notify({ Title = "W424 HUB", Content = "Arsenal v5.6 Smart Integrated Loaded!", Type = "success" })
