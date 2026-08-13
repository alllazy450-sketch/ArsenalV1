-- =================================
-- UI LIBRARY (W424_UI)
-- =================================
local W424UI = loadstring(game:HttpGet("https://raw.githubusercontent.com/willrev-424/W424HUB/refs/heads/main/W424_UI.lua"))()

local Window = W424UI:Window({
    Title = "W424 HUB",
    Footer = "",
    Image = "109462748520607",
    Icon = "rbxassetid://109462748520607",
    Color = Color3.fromRGB(30, 132, 243),
    ["Tab Width"] = 130,
    Version = 3
})

Window:Tag({
    Title = "Executor: " .. identifyexecutor(),
    Color = Color3.fromRGB(100, 100, 100),
    Radius = 13
})

-- =================================
-- FUNGSI KONTROL (Menghubungkan ke actor)
-- =================================
local actor = getactors()[1]

local function SetFeature(name, value)
    if actor and shared and shared.SetFeature then
        shared.SetFeature(name, value)
        print("Set " .. name .. " to " .. tostring(value))
    else
        warn("Actor atau shared.SetFeature tidak tersedia!")
    end
end

local function GetFeature(name)
    if actor and shared and shared.GetFeature then
        return shared.GetFeature(name)
    end
    return nil
end

-- =================================
-- BUAT TAB (Gunakan method "Tap")
-- =================================
local TabArsenal = Window:Tap({
    Title = "Arsenal",
    Icon = "rbxassetid://109462748520607"
})

-- =================================
-- SECTION: FITUR ARSENAL
-- =================================
TabArsenal:Section("Fitur Arsenal")

TabArsenal:Toggle({
    Title = "Infinite Ammo",
    Default = true, -- sesuai default di source
    Callback = function(v) SetFeature("InfiniteAmmo", v) end
})

TabArsenal:Toggle({
    Title = "No Recoil",
    Default = true,
    Callback = function(v) SetFeature("NoRecoil", v) end
})

TabArsenal:Toggle({
    Title = "Fast Fire Rate",
    Default = true,
    Callback = function(v) SetFeature("FastFire", v) end
})

TabArsenal:Toggle({
    Title = "No Spread",
    Default = true,
    Callback = function(v) SetFeature("NoSpread", v) end
})

TabArsenal:Toggle({
    Title = "Fast Reload",
    Default = true,
    Callback = function(v) SetFeature("FastReload", v) end
})

-- =================================
-- SECTION: SILENT AIM (DARI SOURCE KEDUA)
-- =================================
TabArsenal:Section("Silent Aim")

TabArsenal:Toggle({
    Title = "Enable Silent Aim",
    Default = false,
    Callback = function(v)
        if v then
            -- Jalankan script silent aim di dalam actor
            if actor then
                run_on_actor(actor, [=[
                    -- Kode silent aim dari source kedua (dimodifikasi agar menggunakan Features.SilentAim)
                    local target = nil
                    local function isVisible(target)
                        local origin = game.workspace.CurrentCamera.CFrame
                        local params = RaycastParams.new()
                        params.FilterType = Enum.RaycastFilterType.Exclude
                        params.FilterDescendantsInstances = {game.Players.LocalPlayer.Character}
                        params.IgnoreWater = true
                        local direction = (target.Position - origin.Position)
                        local result = workspace:Raycast(origin.Position, direction, params)
                        if result then
                            return game.Players:GetPlayerFromCharacter(result.Instance:FindFirstAncestorOfClass("Model")) ~= nil
                        else
                            return true
                        end
                    end
                    local function GetClosestPlayer()
                        local closestDistance = math.huge
                        local closest = nil
                        local camera = workspace.CurrentCamera
                        for _, v in pairs(game.Players:GetPlayers()) do
                            if v == game.Players.LocalPlayer then continue end
                            local char = v.Character
                            if not char then continue end
                            local hrp = char:FindFirstChild("HumanoidRootPart")
                            if not hrp then continue end
                            local hum = char:FindFirstChild("Humanoid")
                            if not hum or hum.Health <= 0 then continue end
                            local myteam = game.Players.LocalPlayer.Team and game.Players.LocalPlayer.Team.Name
                            local theirTeam = v.Team and v.Team.Name
                            if myteam == theirTeam then continue end
                            local head = char:FindFirstChild("Head")
                            if not head then continue end
                            local screenPos, onScreen = camera:WorldToViewportPoint(hrp.Position)
                            if onScreen then
                                local distance = (Vector2.new(screenPos.X, screenPos.Y) - camera.ViewportSize / 2).Magnitude
                                if distance < closestDistance then
                                    if not isVisible(head) then continue end
                                    closestDistance = distance
                                    closest = head
                                end
                            end
                        end
                        return closest
                    end
                    game:GetService("RunService").RenderStepped:Connect(function()
                        target = GetClosestPlayer()
                    end)
                    for i, v in pairs(getgc()) do   
                        if type(v) == "function" and islclosure(v) then
                            if debug.info(v, "a") == 2 and #debug.getupvalues(v) == 2 and #debug.getconstants(v) == 17 and debug.info(v,"n"):len() <= 10 then
                                local old
                                old = hookfunction(v, function(p1,p2)
                                    if target and target.Position then
                                        local mychar = game.Players.LocalPlayer.Character
                                        if mychar then
                                            local head = mychar:FindFirstChild("Head")
                                            if head then
                                                local direction = (target.Position - head.Position) 
                                                p1 = Ray.new(head.Position, direction)
                                            end
                                        end
                                    end
                                    return old(p1,p2)
                                end)
                            end
                        end
                    end
                ]=])
            end
        else
            -- Matikan silent aim (perlu me-reset hook atau kita abaikan)
            -- Karena hook tidak bisa di-unhook mudah, kita bisa matikan dengan mengosongkan target
            if actor then
                run_on_actor(actor, [[ target = nil ]])
            end
        end
    end
})

-- =================================
-- NOTIFIKASI
-- =================================
Window:Notify({
    Title = "W424HUB",
    Description = "Loaded with W424_UI & Actor Control!",
    Duration = 3
})

print("✅ UI siap!")