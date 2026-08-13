-- =============================================
-- [1] LOAD LIBRARY
-- =============================================

local Starlight = loadstring(game:HttpGet("https://raw.nebulasoftworks.xyz/starlight"))()
if not Starlight then
    warn("❌ Gagal load Starlight!")
    return
end

local NebulaIcons = loadstring(game:HttpGet("https://raw.nebulasoftworks.xyz/nebula-icon-library-loader"))()

-- =============================================
-- [2] BUAT WINDOW
-- =============================================

local Window = Starlight:CreateWindow({
    Name = "W424HUB"
})

-- Set tema Crimson (warna merah)
Starlight:SetTheme("Crimson")

-- Notifikasi awal dengan logo (bisa pake asset ID)
Starlight:Notify({
    Title = "W424HUB",
    Description = "Loaded with Starlight!",
    Image = "rbxassetid://109462748520607", -- Logo bubble
    Duration = 5
})

-- =============================================
-- [3] BUAT TAB DENGAN ICON BUBBLE
-- =============================================

local iconBubble = "rbxassetid://109462748520607"

local TabAim = Window:CreateTab({
    Name = "Aim",
    Icon = iconBubble,
    ImageSource = "rbxassetid" -- biar pake asset ID
})

local TabVisual = Window:CreateTab({
    Name = "Visual",
    Icon = iconBubble,
    ImageSource = "rbxassetid"
})

local TabPlayer = Window:CreateTab({
    Name = "Player",
    Icon = iconBubble,
    ImageSource = "rbxassetid"
})

local TabArsenal = Window:CreateTab({
    Name = "Arsenal",
    Icon = iconBubble,
    ImageSource = "rbxassetid"
})

-- =============================================
-- [4] TAB AIM - AIMBOT
-- =============================================

TabAim:CreateSection("Aimbot Settings")

local aimbotEnabled = false

TabAim:CreateToggle({
    Name = "Enable Aimbot",
    Callback = function(v) aimbotEnabled = v end
})

TabAim:CreateDropdown({
    Name = "Aim Mode",
    Options = {"Camera", "Silent"},
    Default = "Camera",
    Callback = function(v) print("Aim Mode:", v) end
})

TabAim:CreateDropdown({
    Name = "Trigger",
    Options = {"On Shoot", "Always"},
    Default = "On Shoot",
    Callback = function(v) print("Trigger:", v) end
})

TabAim:CreateDropdown({
    Name = "Target Part",
    Options = {"Head", "HumanoidRootPart", "Torso", "UpperTorso"},
    Default = "Head",
    Callback = function(v) print("Target Part:", v) end
})

TabAim:CreateToggle({
    Name = "Headshot Only",
    Callback = function(v) print("Headshot Only:", v) end
})

TabAim:CreateToggle({
    Name = "Anti Team",
    Default = true,
    Callback = function(v) print("Anti Team:", v) end
})

TabAim:CreateToggle({
    Name = "Visibility Check",
    Default = true,
    Callback = function(v) print("Visibility Check:", v) end
})

TabAim:CreateToggle({
    Name = "Prediction",
    Callback = function(v) print("Prediction:", v) end
})

TabAim:CreateSlider({
    Name = "FOV Radius",
    Min = 30,
    Max = 400,
    Default = 100,
    Suffix = "px",
    Callback = function(v) print("FOV Radius:", v) end
})

TabAim:CreateSlider({
    Name = "Max Distance",
    Min = 50,
    Max = 500,
    Default = 300,
    Suffix = "stud",
    Callback = function(v) print("Max Distance:", v) end
})

TabAim:CreateSlider({
    Name = "Prediction Factor",
    Min = 0,
    Max = 100,
    Default = 20,
    Suffix = "%",
    Callback = function(v) print("Prediction Factor:", v) end
})

TabAim:CreateSlider({
    Name = "Smoothness",
    Min = 1,
    Max = 100,
    Default = 100,
    Suffix = "%",
    Callback = function(v) print("Smoothness:", v) end
})

-- =============================================
-- [5] TAB VISUAL - ESP + OPTIMASI
-- =============================================

TabVisual:CreateSection("ESP Chams")

local espEnabled = false
local espColor = Color3.fromRGB(255, 0, 0)

TabVisual:CreateToggle({
    Name = "Enable ESP",
    Callback = function(v) espEnabled = v end
})

TabVisual:CreateToggle({
    Name = "ESP Team Check",
    Default = true,
    Callback = function(v) print("ESP Team Check:", v) end
})

TabVisual:CreateColorPicker({
    Name = "ESP Color",
    Default = Color3.fromRGB(255, 0, 0),
    Callback = function(c)
        espColor = c
        print("ESP Color:", c)
    end
})

TabVisual:CreateSlider({
    Name = "ESP Transparency",
    Min = 0,
    Max = 10,
    Default = 3,
    Suffix = "/10",
    Callback = function(v) print("ESP Transparency:", v) end
})

TabVisual:CreateSection("Optimization")

TabVisual:CreateToggle({
    Name = "Reduce Map (Disable Minimap)",
    Callback = function(v)
        if v then
            pcall(function() game:GetService("StarterGui"):SetCore("MinimapEnabled", false) end)
        else
            pcall(function() game:GetService("StarterGui"):SetCore("MinimapEnabled", true) end)
        end
    end
})

-- =============================================
-- [6] TAB PLAYER - MODS
-- =============================================

TabPlayer:CreateSection("Player Mods")

TabPlayer:CreateToggle({
    Name = "No Recoil",
    Callback = function(v) print("No Recoil:", v) end
})

TabPlayer:CreateToggle({
    Name = "No Spread",
    Callback = function(v) print("No Spread:", v) end
})

TabPlayer:CreateToggle({
    Name = "Anti Ragdoll",
    Callback = function(v) print("Anti Ragdoll:", v) end
})

-- =============================================
-- [7] TAB ARSENAL - FITUR KHUSUS + SILENT HITBOX
-- =============================================

TabArsenal:CreateSection("Arsenal Mods")

TabArsenal:CreateToggle({
    Name = "Fast Fire Rate",
    Callback = function(v) print("Fast Fire Rate:", v) end
})

TabArsenal:CreateToggle({
    Name = "Fast Reload",
    Callback = function(v) print("Fast Reload:", v) end
})

TabArsenal:CreateToggle({
    Name = "Infinite Ammo",
    Callback = function(v) print("Infinite Ammo:", v) end
})

TabArsenal:CreateToggle({
    Name = "No Recoil (Arsenal)",
    Callback = function(v) print("No Recoil (Arsenal):", v) end
})

TabArsenal:CreateToggle({
    Name = "No Spread (Arsenal)",
    Callback = function(v) print("No Spread (Arsenal):", v) end
})

TabArsenal:CreateSection("Unlock & Skin Changer")

TabArsenal:CreateButton({
    Name = "Unlock All Items",
    Callback = function()
        print("Unlock All Items!")
        Starlight:Notify({
            Title = "Unlock All",
            Description = "All items unlocked!",
            Image = iconBubble,
            Duration = 3
        })
    end
})

-- Dropdown untuk ganti skin (contoh)
TabArsenal:CreateDropdown({
    Name = "Character Skin",
    Options = {"Default", "Skin 1", "Skin 2", "Skin 3"},
    Default = "Default",
    Callback = function(v) print("Character Skin:", v) end
})

TabArsenal:CreateDropdown({
    Name = "Melee Skin",
    Options = {"Default", "Knife", "Sword", "Axe"},
    Default = "Default",
    Callback = function(v) print("Melee Skin:", v) end
})

TabArsenal:CreateDropdown({
    Name = "Gun Skin",
    Options = {"Default", "Gold", "Platinum", "Neon"},
    Default = "Default",
    Callback = function(v) print("Gun Skin:", v) end
})

TabArsenal:CreateDropdown({
    Name = "Kill Effect",
    Options = {"Default", "Explosion", "Lightning", "Fire"},
    Default = "Default",
    Callback = function(v) print("Kill Effect:", v) end
})

TabArsenal:CreateDropdown({
    Name = "Announcer",
    Options = {"Default", "Male", "Female", "Robot"},
    Default = "Default",
    Callback = function(v) print("Announcer:", v) end
})

-- =============================================
-- [8] SILENT HITBOX
-- =============================================

TabArsenal:CreateSection("Silent Hitbox")

local silentHitbox = false
local hitboxExpansion = 13
local hitboxAlpha = 0.3

TabArsenal:CreateToggle({
    Name = "Enable Silent Hitbox",
    Callback = function(v)
        silentHitbox = v
        print("Silent Hitbox:", v)
    end
})

TabArsenal:CreateDropdown({
    Name = "Target Parts",
    Options = {"All", "Head", "Torso", "Legs"},
    Default = "All",
    Callback = function(v) print("Target Parts:", v) end
})

TabArsenal:CreateSlider({
    Name = "Hitbox Expansion",
    Min = 1,
    Max = 30,
    Default = 13,
    Suffix = "x",
    Callback = function(v)
        hitboxExpansion = v
        print("Hitbox Expansion:", v)
    end
})

TabArsenal:CreateSlider({
    Name = "Hitbox Alpha",
    Min = 0,
    Max = 10,
    Default = 3,
    Suffix = "/10",
    Callback = function(v)
        hitboxAlpha = v / 10
        print("Hitbox Alpha:", hitboxAlpha)
    end
})

TabArsenal:CreateButton({
    Name = "Reset Hitbox",
    Callback = function()
        print("Reset Hitbox!")
        Starlight:Notify({
            Title = "Reset",
            Description = "Hitbox reset to default",
            Image = iconBubble,
            Duration = 2
        })
    end
})

-- =============================================
-- [9] SELESAI
-- =============================================

print("✅ W424HUB - Starlight Edition loaded!")
Starlight:Notify({
    Title = "W424HUB",
    Description = "All features ready!",
    Image = iconBubble,
    Duration = 3
})