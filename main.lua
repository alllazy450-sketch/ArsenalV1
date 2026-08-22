-- ============================================================
-- W424 HUB | ARSENAL ULTIMATE PRO v6.0 (FULL FEATURES + ALL NEW)
-- UI Framework: Oxidelib (Midnight Theme)
-- Map: Arsenal
-- Status: ALL FEATURES RESTORED, IMPROVED & EXPANDED
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

-- [ FOV CIRCLE VISUAL ]
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

local function getTargetPart(plr)
    return plr.Character:FindFirstChild(Settings.TargetPart) or plr.Character:FindFirstChild("HumanoidRootPart")
end

local function getClosestToCrosshair()
    local center = (Settings.FOVPosition == "Center") and FOVCenter or UserInputService:GetMouseLocation()
    local best, bestDist = nil, math.huge
    for _, plr in pairs(Players:GetPlayers()) do
        if plr ~= LocalPlayer and plr.Character and isAlive(plr.Character) then
            if Toggles.TeamCheck and plr.Team == LocalPlayer.Team then continue end
            local part = getTargetPart(plr)
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
    local data = {
        Toggles = Toggles,
        Settings = Settings,
        Keybinds = Keybinds
    }
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

-- [ SILENT AIM & NO RECOIL/SPREAD ]
local function getWeapon()
    local char = LocalPlayer.Character
    if not char then return nil end
    local tool = char:FindFirstChildOfClass("Tool")
    return tool
end

-- Hook untuk Silent Aim (mengubah mouse.Hit saat menembak)
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
        local newHit = CFrame.new(origin + dir * 10, origin + dir * 100)
        -- Simpan mouse.Hit asli dan ganti
        oldMouseHit = Mouse.Hit
        Mouse.Hit = newHit
        -- Kembalikan setelah tembakan selesai? Kita akan reset di loop
    end
end

-- Reset mouse.Hit setelah tembakan
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    if input.UserInputType == Enum.UserInputType.MouseButton1 and Toggles.Silent then
        silentAimFire()
        -- Reset setelah beberapa frame
        task.spawn(function()
            task.wait(0.05)
            if oldMouseHit then Mouse.Hit = oldMouseHit end
        end)
    end
end)

-- No Recoil & No Spread: kita bisa set properti weapon atau override Camera
RunService.RenderStepped:Connect(function()
    if Toggles.NoRecoil or Toggles.NoSpread then
        local weapon = getWeapon()
        if weapon then
            -- Contoh: jika ada atribut recoil/spread
            pcall(function()
                if weapon:FindFirstChild("Recoil") then weapon.Recoil.Value = 0 end
                if weapon:FindFirstChild("Spread") then weapon.Spread.Value = 0 end
                if weapon:FindFirstChild("Accuracy") then weapon.Accuracy.Value = 100 end
            end)
        end
    end
end)

-- [ INFINITE AMMO ]
task.spawn(function()
    while task.wait(0.5) do
        if Toggles.InfAmmo then
            local weapon = getWeapon()
            if weapon then
                pcall(function()
                    if weapon:FindFirstChild("Ammo") then weapon.Ammo.Value = weapon.MaxAmmo.Value end
                    if weapon:FindFirstChild("CurrentAmmo") then weapon.CurrentAmmo.Value = weapon.MaxAmmo.Value end
                end)
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
    if Toggles.Noclip then
        pcall(function()
            LocalPlayer.Character:FindFirstChild("HumanoidRootPart").CanCollide = false
        end)
    else
        pcall(function()
            LocalPlayer.Character:FindFirstChild("HumanoidRootPart").CanCollide = true
        end)
    end
end

-- [ AUTO JUMP ]
RunService.Heartbeat:Connect(function()
    if Toggles.AutoJump and LocalPlayer.Character then
        local hum = LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
        if hum and hum.MoveDirection.Magnitude > 0 and hum.FloorMaterial ~= Enum.Material.Air then
            hum.Jump = true
        end
    end
end)

-- [ TRIGGERBOT ]
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    if Toggles.Triggerbot and input.UserInputType == Enum.UserInputType.MouseButton2 then
        local target = getClosestToCrosshair()
        if target then
            local weapon = getWeapon()
            if weapon then
                weapon:Activate()
                task.wait(Settings.TriggerbotDelay)
                weapon:Deactivate()
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
            -- Arahkan kamera ke target (sama seperti aimbot)
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

-- [ ESP SYSTEM (Box, Name, Health, Tracer, Chams) ]
local function updateESP()
    -- Hapus semua ESP lama
    for _, obj in pairs(ESPObjects) do
        if obj and obj.Destroy then obj:Destroy() end
    end
    ESPObjects = {}
    if not Toggles.ESP_Enabled then return end

    for _, plr in pairs(Players:GetPlayers()) do
        if plr == LocalPlayer then continue end
        local char = plr.Character
        if not char or not isAlive(char) then continue end
        local teamCheck = Toggles.TeamCheck and plr.Team == LocalPlayer.Team
        if teamCheck and not Toggles.ESP_Enabled then continue end -- jika team check aktif dan sama, skip

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

        -- Box ESP
        if Toggles.BoxESP then
            local box = Drawing.new("Square")
            box.Position = topLeft
            box.Size = Vector2.new(width, height)
            box.Thickness = 1
            box.Color = teamCheck and Color3.fromRGB(0,255,0) or Settings.BoxColor
            box.Transparency = 0.5
            box.Filled = false
            table.insert(ESPObjects, box)
        end

        -- Health Bar
        if Toggles.HealthBar then
            local hum = char:FindFirstChildOfClass("Humanoid")
            if hum then
                local healthPercent = hum.Health / hum.MaxHealth
                local barBg = Drawing.new("Line")
                barBg.From = Vector2.new(topLeft.X - 6, topLeft.Y)
                barBg.To = Vector2.new(topLeft.X - 6, bottomRight.Y)
                barBg.Color = Color3.fromRGB(50,50,50)
                barBg.Thickness = 4
                table.insert(ESPObjects, barBg)
                local barFill = Drawing.new("Line")
                barFill.From = Vector2.new(topLeft.X - 6, bottomRight.Y - (bottomRight.Y - topLeft.Y) * healthPercent)
                barFill.To = Vector2.new(topLeft.X - 6, bottomRight.Y)
                barFill.Color = healthPercent > 0.5 and Color3.fromRGB(0,255,0) or (healthPercent > 0.25 and Color3.fromRGB(255,255,0) or Color3.fromRGB(255,0,0))
                barFill.Thickness = 4
                table.insert(ESPObjects, barFill)
            end
        end

        -- Name
        local nameText = Drawing.new("Text")
        nameText.Position = Vector2.new(sPos.X, sHead.Y - 20)
        nameText.Text = plr.Name
        nameText.Size = 14
        nameText.Color = teamCheck and Color3.fromRGB(0,255,0) or Color3.fromRGB(255,255,255)
        nameText.Center = true
        nameText.Outline = true
        nameText.OutlineColor = Color3.fromRGB(0,0,0)
        table.insert(ESPObjects, nameText)

        -- Tracer
        if Toggles.Tracers then
            local tracer = Drawing.new("Line")
            tracer.From = Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y)
            tracer.To = Vector2.new(sPos.X, sPos.Y)
            tracer.Color = teamCheck and Color3.fromRGB(0,255,0) or Settings.TracerColor
            tracer.Thickness = 1
            table.insert(ESPObjects, tracer)
        end

        -- Chams (Highlight)
        if Toggles.Chams then
            local highlight = char:FindFirstChildOfClass("Highlight") or Instance.new("Highlight", char)
            highlight.Enabled = not teamCheck
            highlight.FillColor = teamCheck and Color3.fromRGB(0,255,0) or Settings.ChamsColor
            highlight.OutlineTransparency = 0.5
            table.insert(ESPObjects, highlight)
        end
    end
end

-- Update ESP setiap 0.2 detik
task.spawn(function()
    while task.wait(0.2) do
        updateESP()
    end
end)

-- [ AIMBOT + PREDICTION + FOV ]
RunService.RenderStepped:Connect(function(dt)
    -- FOV Circle
    if Toggles.FOV_Circle then
        FOVCircle.Visible = true
        FOVCircle.Radius = Settings.FovRadius
        if Settings.FOVPosition == "Center" then
            FOVCircle.Position = FOVCenter
        else
            FOVCircle.Position = UserInputService:GetMouseLocation()
        end
    else
        FOVCircle.Visible = false
    end

    -- Crosshair
    if Toggles.Crosshair then
        Crosshair.Visible = true
        Crosshair.Position = FOVCenter
    else
        Crosshair.Visible = false
    end

    -- Aimbot (hanya jika AimLock tidak aktif, karena AimLock sudah menangani)
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

    -- Player movement (WalkSpeed, JumpPower)
    local char = LocalPlayer.Character
    if char and char:FindFirstChildOfClass("Humanoid") then
        char.Humanoid.WalkSpeed = Settings.WalkSpeed
        char.Humanoid.JumpPower = Settings.JumpPower
    end

    -- Fly & Noclip update
    if Toggles.Fly then
        if not flyBodyVelocity then toggleFly() end
        -- Kontrol: WASD + Space/Ctrl
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

    if Toggles.Noclip then
        toggleNoclip()
    else
        -- Kembalikan jika mati
        pcall(function()
            if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
                LocalPlayer.Character.HumanoidRootPart.CanCollide = true
            end
        end)
    end
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
        Toggles.Aimbot = not Toggles.Aimbot
        Library:Notify({Title = "Aimbot", Content = tostring(Toggles.Aimbot), Type = "info"})
    elseif input.KeyCode == Keybinds.Silent then
        Toggles.Silent = not Toggles.Silent
        Library:Notify({Title = "Silent Aim", Content = tostring(Toggles.Silent), Type = "info"})
    elseif input.KeyCode == Keybinds.ESP then
        Toggles.ESP_Enabled = not Toggles.ESP_Enabled
        Library:Notify({Title = "ESP", Content = tostring(Toggles.ESP_Enabled), Type = "info"})
    elseif input.KeyCode == Keybinds.Triggerbot then
        Toggles.Triggerbot = not Toggles.Triggerbot
        Library:Notify({Title = "Triggerbot", Content = tostring(Toggles.Triggerbot), Type = "info"})
    elseif input.KeyCode == Keybinds.Fly then
        Toggles.Fly = not Toggles.Fly
        Library:Notify({Title = "Fly", Content = tostring(Toggles.Fly), Type = "info"})
        toggleFly()
    elseif input.KeyCode == Keybinds.Noclip then
        Toggles.Noclip = not Toggles.Noclip
        Library:Notify({Title = "Noclip", Content = tostring(Toggles.Noclip), Type = "info"})
        toggleNoclip()
    end
end)

-- [ UI SETUP ]
local Window = Library:CreateWindow({
    Name = "W424 HUB",
    BrandSubtitle = "Arsenal ULTIMATE v6.0 - All Features",
    Logo = MY_LOGO,
    ToggleKey = Enum.KeyCode.RightShift,
    Size = UDim2.fromOffset(800, 650),
})

-- === TABS ===
local TabCombat = Window:AddTab({ Name = "Combat", Icon = "target" })
local TabVisual = Window:AddTab({ Name = "Visuals", Icon = "eye" })
local TabWeapon = Window:AddTab({ Name = "Weapon", Icon = "zap" })
local TabMovement = Window:AddTab({ Name = "Movement", Icon = "user" })
local TabUtility = Window:AddTab({ Name = "Utility", Icon = "settings" })
local TabConfig = Window:AddTab({ Name = "Config", Icon = "save" })

-- === COMBAT TAB ===
local SubAim = TabCombat:AddSubTab("Aimbot")
SubAim:AddSection("MAIN AIMBOT")
SubAim:AddToggle({ Name = "Enable Aimbot", Default = Toggles.Aimbot, Callback = function(v) Toggles.Aimbot = v saveConfig() end })
SubAim:AddToggle({ Name = "Aim Lock (Lock target)", Default = Toggles.AimLock, Callback = function(v) Toggles.AimLock = v saveConfig() end })
SubAim:AddDropdown({ Name = "Aim Mode", Options = {"On Shoot", "Always"}, Default = Settings.AimMode, Callback = function(v) Settings.AimMode = v saveConfig() end })
SubAim:AddSlider({ Name = "Smoothing", Min = 1, Max = 20, Default = Settings.Smoothness, Callback = function(v) Settings.Smoothness = v saveConfig() end })
SubAim:AddDropdown({ Name = "Target Part", Options = {"Head", "HumanoidRootPart", "LowerTorso"}, Default = Settings.TargetPart, Callback = function(v) Settings.TargetPart = v saveConfig() end })
SubAim:AddToggle({ Name = "Wall Check", Default = Toggles.WallCheck, Callback = function(v) Toggles.WallCheck = v saveConfig() end })

local SubSilent = TabCombat:AddSubTab("Silent Aim")
SubSilent:AddSection("SILENT ENGINE")
SubSilent:AddToggle({ Name = "Enable Silent Aim", Default = Toggles.Silent, Callback = function(v) Toggles.Silent = v saveConfig() end })

local SubPred = TabCombat:AddSubTab("Prediction")
SubPred:AddSection("SMART PREDICT V2")
SubPred:AddToggle({ Name = "Enable Prediction", Default = Toggles.Predict, Callback = function(v) Toggles.Predict = v saveConfig() end })
SubPred:AddSlider({ Name = "Strength", Min = 1, Max = 200, Default = Settings.PredFactor*100, Callback = function(v) Settings.PredFactor = v/100 saveConfig() end })
SubPred:AddSlider({ Name = "Bullet Speed", Min = 500, Max = 4000, Default = Settings.BulletSpeed, Callback = function(v) Settings.BulletSpeed = v saveConfig() end })

local SubTrigger = TabCombat:AddSubTab("Triggerbot")
SubTrigger:AddSection("AUTO SHOOT")
SubTrigger:AddToggle({ Name = "Enable Triggerbot", Default = Toggles.Triggerbot, Callback = function(v) Toggles.Triggerbot = v saveConfig() end })
SubTrigger:AddSlider({ Name = "Delay (sec)", Min = 0.05, Max = 0.5, Default = Settings.TriggerbotDelay, Callback = function(v) Settings.TriggerbotDelay = v saveConfig() end })

-- === VISUALS TAB ===
local SubESP = TabVisual:AddSubTab("ESP")
SubESP:AddSection("ESP SETTINGS")
SubESP:AddToggle({ Name = "Enable ESP", Default = Toggles.ESP_Enabled, Callback = function(v) Toggles.ESP_Enabled = v saveConfig() end })
SubESP:AddToggle({ Name = "Box ESP", Default = Toggles.BoxESP, Callback = function(v) Toggles.BoxESP = v saveConfig() end })
SubESP:AddToggle({ Name = "Health Bar", Default = Toggles.HealthBar, Callback = function(v) Toggles.HealthBar = v saveConfig() end })
SubESP:AddToggle({ Name = "Tracers", Default = Toggles.Tracers, Callback = function(v) Toggles.Tracers = v saveConfig() end })
SubESP:AddToggle({ Name = "Chams (Highlight)", Default = Toggles.Chams, Callback = function(v) Toggles.Chams = v saveConfig() end })
SubESP:AddToggle({ Name = "Team Check", Default = Toggles.TeamCheck, Callback = function(v) Toggles.TeamCheck = v saveConfig() end })
SubESP:AddColorPicker({ Name = "Box Color", Default = Settings.BoxColor, Callback = function(c) Settings.BoxColor = c saveConfig() end })
SubESP:AddColorPicker({ Name = "Tracer Color", Default = Settings.TracerColor, Callback = function(c) Settings.TracerColor = c saveConfig() end })
SubESP:AddColorPicker({ Name = "Chams Color", Default = Settings.ChamsColor, Callback = function(c) Settings.ChamsColor = c saveConfig() end })

local SubFOV = TabVisual:AddSubTab("FOV & Crosshair")
SubFOV:AddSection("FOV CIRCLE")
SubFOV:AddToggle({ Name = "Show FOV Circle", Default = Toggles.FOV_Circle, Callback = function(v) Toggles.FOV_Circle = v saveConfig() end })
SubFOV:AddSlider({ Name = "FOV Size", Min = 30, Max = 600, Default = Settings.FovRadius, Callback = function(v) Settings.FovRadius = v saveConfig() end })
SubFOV:AddSlider({ Name = "Thickness", Min = 1, Max = 5, Default = FOVCircle.Thickness, Callback = function(v) FOVCircle.Thickness = v end })
SubFOV:AddSlider({ Name = "Transparency", Min = 1, Max = 10, Default = FOVCircle.Transparency*10, Callback = function(v) FOVCircle.Transparency = v/10 end })
SubFOV:AddDropdown({ Name = "FOV Position", Options = {"Center", "Mouse"}, Default = Settings.FOVPosition, Callback = function(v) Settings.FOVPosition = v saveConfig() end })
SubFOV:AddSection("CROSSHAIR")
SubFOV:AddToggle({ Name = "Show Crosshair", Default = Toggles.Crosshair, Callback = function(v) Toggles.Crosshair = v saveConfig() end })

-- === WEAPON TAB ===
local SubWeapon = TabWeapon:AddSubTab("Gun Mods")
SubWeapon:AddToggle({ Name = "Infinite Ammo", Default = Toggles.InfAmmo, Callback = function(v) Toggles.InfAmmo = v saveConfig() end })
SubWeapon:AddToggle({ Name = "No Recoil", Default = Toggles.NoRecoil, Callback = function(v) Toggles.NoRecoil = v saveConfig() end })
SubWeapon:AddToggle({ Name = "No Spread", Default = Toggles.NoSpread, Callback = function(v) Toggles.NoSpread = v saveConfig() end })

local SubMap = TabWeapon:AddSubTab("Map/FPS")
SubMap:AddButton({ Name = "Reduce Map (Potato Mode)", Callback = function()
    pcall(function() StarterGui:SetCore("MinimapEnabled", false) end)
    for _, obj in ipairs(workspace:GetDescendants()) do
        if obj:IsA("BasePart") then obj.Material = Enum.Material.SmoothPlastic
        elseif obj:IsA("Texture") or obj:IsA("Decal") then obj:Destroy() end
    end
    Library:Notify({Title = "Map Reduced", Content = "Potato mode activated!", Type = "success"})
end })

-- === MOVEMENT TAB ===
local SubMove = TabMovement:AddSubTab("Movement")
SubMove:AddSlider({ Name = "WalkSpeed", Min = 16, Max = 200, Default = Settings.WalkSpeed, Callback = function(v) Settings.WalkSpeed = v saveConfig() end })
SubMove:AddSlider({ Name = "JumpPower", Min = 50, Max = 250, Default = Settings.JumpPower, Callback = function(v) Settings.JumpPower = v saveConfig() end })
SubMove:AddToggle({ Name = "Auto Jump", Default = Toggles.AutoJump, Callback = function(v) Toggles.AutoJump = v saveConfig() end })
SubMove:AddToggle({ Name = "Fly", Default = Toggles.Fly, Callback = function(v) Toggles.Fly = v; toggleFly(); saveConfig() end })
SubMove:AddToggle({ Name = "Noclip", Default = Toggles.Noclip, Callback = function(v) Toggles.Noclip = v; toggleNoclip(); saveConfig() end })
SubMove:AddToggle({ Name = "Anti-AFK", Default = Toggles.AntiAFK, Callback = function(v) Toggles.AntiAFK = v saveConfig() end })

-- === UTILITY TAB ===
local SubKeys = TabUtility:AddSubTab("Keybinds")
SubKeys:AddSection("SET KEYBINDS (Click to change)")
SubKeys:AddKeybind({ Name = "Aimbot Toggle", Default = Keybinds.Aimbot, Callback = function(k) Keybinds.Aimbot = k saveConfig() end })
SubKeys:AddKeybind({ Name = "Silent Aim Toggle", Default = Keybinds.Silent, Callback = function(k) Keybinds.Silent = k saveConfig() end })
SubKeys:AddKeybind({ Name = "ESP Toggle", Default = Keybinds.ESP, Callback = function(k) Keybinds.ESP = k saveConfig() end })
SubKeys:AddKeybind({ Name = "Triggerbot Toggle", Default = Keybinds.Triggerbot, Callback = function(k) Keybinds.Triggerbot = k saveConfig() end })
SubKeys:AddKeybind({ Name = "Fly Toggle", Default = Keybinds.Fly, Callback = function(k) Keybinds.Fly = k saveConfig() end })
SubKeys:AddKeybind({ Name = "Noclip Toggle", Default = Keybinds.Noclip, Callback = function(k) Keybinds.Noclip = k saveConfig() end })

-- === CONFIG TAB ===
local SubConfig = TabConfig:AddSubTab("Save/Load")
SubConfig:AddButton({ Name = "Save Config", Callback = function() saveConfig(); Library:Notify({Title = "Config Saved", Content = "Settings saved to "..CONFIG_FILE, Type = "success"}) end })
SubConfig:AddButton({ Name = "Load Config", Callback = function() loadConfig(); Library:Notify({Title = "Config Loaded", Content = "Settings loaded!", Type = "success"}) end })
SubConfig:AddButton({ Name = "Reset Defaults", Callback = function()
    -- Reset semua ke default (hanya untuk toggles & settings, keybinds tetap)
    for k,v in pairs(Toggles) do Toggles[k] = false end
    Settings.Smoothness = 3; Settings.FovRadius = 150; Settings.TargetPart = "Head"; Settings.BulletSpeed = 950; Settings.PredFactor = 0.5; Settings.AimMode = "On Shoot"; Settings.WalkSpeed = 16; Settings.JumpPower = 50; Settings.FOVPosition = "Center"; Settings.TriggerbotDelay = 0.1; Settings.ChamsColor = Color3.fromRGB(255,0,0); Settings.BoxColor = Color3.fromRGB(255,255,255); Settings.TracerColor = Color3.fromRGB(0,255,0)
    Library:Notify({Title = "Defaults Reset", Content = "All settings reset to default", Type = "warning"})
    saveConfig()
end })

-- [ NOTIFICATION ON LOAD ]
Window:Notify({ Title = "W424 HUB", Content = "Arsenal ULTIMATE v6.0 Full Features Loaded!", Type = "success" })
