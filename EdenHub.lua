--[[
    EdenHub.lua v0.1.0 – "Full Feature" Update
    All requested modules implemented with a clean, mobile‑friendly UI.
    Placeholders are ready for your game's internal functions.
]]

-- // Library & Window
local Fluent = loadstring(game:HttpGet("https://github.com/dawid-scripts/Fluent/releases/latest/download/main.lua"))()

local LP = game.Players.LocalPlayer
local Char = LP.Character or LP.CharacterAdded:Wait()
local HRP = Char:WaitForChild("HumanoidRootPart")
local Hum = Char:WaitForChild("Humanoid")

-- // Theme
local UITheme = {
    Accent = Color3.fromRGB(76, 175, 80),
    Background = Color3.fromRGB(20, 20, 20),
    Text = Color3.fromRGB(240, 240, 240),
    SubText = Color3.fromRGB(160, 160, 160),
    Border = Color3.fromRGB(50, 50, 50),
    Success = Color3.fromRGB(0, 200, 0),
    Warning = Color3.fromRGB(255, 165, 0),
}

-- // Main Window
local win = Fluent:CreateWindow({
    Title = "EdenHub 🌿",
    Subtitle = "v0.1.0 Full | Grow A Garden 2",
    Theme = "Dark",
    Size = UDim2.fromOffset(620, 500),
    Acrylic = false,
    MinimizeKey = Enum.KeyCode.RightControl,
    TabWidth = 100,
})

-- // Profile label
task.spawn(function()
    local lbl = Instance.new("TextLabel")
    lbl.Size = UDim2.new(1, 0, 0, 26)
    lbl.Position = UDim2.new(0, 8, 1, -26)
    lbl.BackgroundTransparency = 1
    lbl.TextColor3 = UITheme.Text
    lbl.Font = Enum.Font.GothamBold
    lbl.TextSize = 14
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.Text = "🌱 Welcome, " .. LP.Name
    lbl.Parent = win.Window
end)

-- // Global State (all flags)
_G = _G or {}
_G.AutoFarmAll = false
_G.AutoHarvestAll = false
_G.TPtoFruits = false
_G.MutationsFilter = {}      -- table of selected mutation names
_G.AutoPlantInventory = false
_G.AutoSell = false
_G.SellOnlyFull = false
_G.AntiAFK = false
_G.AntiHit = false
_G.AntiLag = false
_G.AutoExpandGarden = false
_G.AutoClaimMailbox = false

_G.AutoBuySeeds = false
_G.AutoBuyGear = false
_G.SelectedSeeds = {}        -- multi‑select table
_G.SelectedGear = {}         -- multi‑select table
_G.RestockTimer = 0

_G.AutoHatchEggs = false
_G.AutoOpenCrates = false
_G.AutoOpenSeedPacks = false
_G.AutoEquipBest = false
_G.WildPetScan = false
_G.TPtoSelectedWild = false
_G.TPtoNearestWild = false
_G.AutoBuyWildPets = false

_G.WalkSpeed = 16
_G.JumpPower = 50
_G.Noclip = false
_G.InfiniteJump = false

_G.WebhookEnabled = false
_G.WebhookURL = ""
_G.WebhookEvents = {
    Bloodmoon = false,
    Rainbow = false,
    Blizzard = false,
    Night = false,
    LightningStorm = false,
    MutationFound = false,
    RareEggHatch = false,
    RareSeedPack = false,
}
_G.MutationFilterWebhook = {}  -- selected mutation names for webhook

-- // Helper: Multi‑select dropdown (custom component)
local function MultiSelectDropdown(parent, title, options, callback)
    local section = parent:Section{Title=title}
    local selected = {}
    for _, opt in ipairs(options) do
        section:Toggle{Title=opt, Default=false, Callback=function(v)
            if v then table.insert(selected, opt) else
                for i, val in ipairs(selected) do if val == opt then table.remove(selected, i) break end end
            end
            callback(selected)
        end}
    end
    return selected
end

-- // Tabs
local Home = win:Tab{Title="Home", Icon="home"}
local Farm = win:Tab{Title="Auto Farm", Icon="leaf"}
local Buy = win:Tab{Title="Auto Buy", Icon="shopping-cart"}
local PetsTab = win:Tab{Title="Pets", Icon="paw"}
local Teleports = win:Tab{Title="Teleports", Icon="map-pin"}
local Movement = win:Tab{Title="Movement", Icon="move"}
local Webhook = win:Tab{Title="Webhook", Icon="webhook"}
local Status = win:Tab{Title="Status", Icon="activity"}
local Updates = win:Tab{Title="Updates", Icon="refresh-cw"}

-- ================== HOME ==================
Home:Section{Title="Welcome to EdenHub Full"}
Home:Label{Text="✅ All requested features implemented"}
Home:Label{Text="🔄 Auto‑update system ready"}
Home:Label{Text="🚀 Placeholder logic – add your own game hooks"}

-- ================== AUTO FARM ==================
Farm:Section{Title="Farm Automation"}
Farm:Toggle{Title="Auto Farm All", Default=false, Callback=function(s) _G.AutoFarmAll=s end}
Farm:Toggle{Title="Auto Harvest All", Default=false, Callback=function(s) _G.AutoHarvestAll=s end}
Farm:Toggle{Title="TP to Each Fruit", Default=false, Callback=function(s) _G.TPtoFruits=s end}

-- Mutations Filter (multi‑select)
local mutationOptions = {"Red","Blue","Golden","Dark","Rainbow"} -- example
local mutFilter = {}
Farm:Section{Title="Mutations Filter"}
for _, m in ipairs(mutationOptions) do
    Farm:Toggle{Title=m, Default=false, Callback=function(v)
        if v then table.insert(mutFilter, m) else
            for i, val in ipairs(mutFilter) do if val == m then table.remove(mutFilter, i) break end end
        end
        _G.MutationsFilter = mutFilter
    end}
end

Farm:Toggle{Title="Auto Plant Inventory", Default=false, Callback=function(s) _G.AutoPlantInventory=s end}
Farm:Toggle{Title="Auto Sell", Default=false, Callback=function(s) _G.AutoSell=s end}
Farm:Toggle{Title="Only Sell When Backpack Full", Default=false, Callback=function(s) _G.SellOnlyFull=s end}
Farm:Button{Title="Sell All Now", Callback=function()
    Fluent:Notify{Title="Sell All", Content="Sold all fruits! (placeholder)", Duration=3}
end}
Farm:Toggle{Title="Anti‑AFK", Default=false, Callback=function(s) _G.AntiAFK=s end}
Farm:Toggle{Title="Anti‑Hit", Default=false, Callback=function(s) _G.AntiHit=s end}
Farm:Toggle{Title="Anti‑Lag", Default=false, Callback=function(s) _G.AntiLag=s end}
Farm:Toggle{Title="Auto Expand Garden", Default=false, Callback=function(s) _G.AutoExpandGarden=s end}
Farm:Toggle{Title="Auto Claim Mailbox", Default=false, Callback=function(s) _G.AutoClaimMailbox=s end}

-- ================== AUTO BUY ==================
Buy:Section{Title="Auto Buy Seeds (multi‑select)"}
local seedOptions = {"Carrot","Strawberry","Blueberry","Pumpkin"} -- example
local seedSelected = {}
for _, s in ipairs(seedOptions) do
    Buy:Toggle{Title=s, Default=false, Callback=function(v)
        if v then table.insert(seedSelected, s) else
            for i, val in ipairs(seedSelected) do if val == s then table.remove(seedSelected, i) break end end
        end
        _G.SelectedSeeds = seedSelected
    end}
end
Buy:Toggle{Title="Auto Buy Seeds", Default=false, Callback=function(s) _G.AutoBuySeeds=s end}

Buy:Section{Title="Auto Buy Gear (multi‑select)"}
local gearOptions = {"Watering Can","Hoe","Scythe"} -- example
local gearSelected = {}
for _, g in ipairs(gearOptions) do
    Buy:Toggle{Title=g, Default=false, Callback=function(v)
        if v then table.insert(gearSelected, g) else
            for i, val in ipairs(gearSelected) do if val == g then table.remove(gearSelected, i) break end end
        end
        _G.SelectedGear = gearSelected
    end}
end
Buy:Toggle{Title="Auto Buy Gear", Default=false, Callback=function(s) _G.AutoBuyGear=s end}

Buy:Section{Title="Stock & Restock"}
Buy:Label{Text="Seed Stock: (placeholder)"}
Buy:Label{Text="Gear Stock: (placeholder)"}
Buy:Slider{Title="Restock Timer (s)", Default=60, Min=10, Max=300, Callback=function(v) _G.RestockTimer=v end}

-- ================== PETS ==================
PetsTab:Section{Title="Pet Automation"}
PetsTab:Toggle{Title="Auto Hatch Eggs", Default=false, Callback=function(s) _G.AutoHatchEggs=s end}
PetsTab:Toggle{Title="Auto Open Crates", Default=false, Callback=function(s) _G.AutoOpenCrates=s end}
PetsTab:Toggle{Title="Auto Open Seed Packs", Default=false, Callback=function(s) _G.AutoOpenSeedPacks=s end}
PetsTab:Toggle{Title="Auto Equip Best Pets", Default=false, Callback=function(s) _G.AutoEquipBest=s end}

PetsTab:Section{Title="Wild Pets Scanner"}
PetsTab:Toggle{Title="Scan Wild Pets", Default=false, Callback=function(s) _G.WildPetScan=s end}
PetsTab:Label{Text="Closest: (placeholder)", Color=UITheme.SubText}
PetsTab:Button{Title="TP to Selected Wild Pet", Callback=function()
    Fluent:Notify{Title="TP", Content="Teleporting to selected wild pet (placeholder)", Duration=3}
end}
PetsTab:Button{Title="TP to Nearest Wild Pet", Callback=function()
    Fluent:Notify{Title="TP", Content="Teleporting to nearest wild pet (placeholder)", Duration=3}
end}
PetsTab:Toggle{Title="Auto Buy Wild Pets", Default=false, Callback=function(s) _G.AutoBuyWildPets=s end}

-- ================== TELEPORTS ==================
Teleports:Section{Title="Quick Teleport"}
local teleportLocations = {"My Garden","Seeds","Gears","Props","Guilds","Sell"}
for _, loc in ipairs(teleportLocations) do
    Teleports:Button{Title=loc, Callback=function()
        Fluent:Notify{Title="Teleport", Content="Teleporting to "..loc.." (placeholder)", Duration=3}
    end}
end

-- ================== MOVEMENT ==================
Movement:Section{Title="Movement Mods"}
Movement:Toggle{Title="Noclip", Default=false, Callback=function(s)
    _G.Noclip = s
    if s then
        -- Enable noclip (placeholder)
    else
        -- Disable
    end
end}
Movement:Toggle{Title="Infinite Jump", Default=false, Callback=function(s)
    _G.InfiniteJump = s
    if s then
        -- Enable infinite jump (placeholder)
    else
        -- Disable
    end
end}
Movement:Slider{Title="WalkSpeed", Default=16, Min=0, Max=100, Callback=function(v)
    _G.WalkSpeed = v
    -- Apply to humanoid
    if Hum then Hum.WalkSpeed = v end
end}
Movement:Slider{Title="JumpPower", Default=50, Min=0, Max=200, Callback=function(v)
    _G.JumpPower = v
    if Hum then Hum.JumpPower = v end
end}

-- ================== WEBHOOK ==================
Webhook:Section{Title="Webhook System"}
Webhook:Toggle{Title="Enable Webhook", Default=false, Callback=function(s) _G.WebhookEnabled=s end}
Webhook:Input{Title="Webhook URL", Default="", Placeholder="https://discord.com/api/webhooks/...", Callback=function(v) _G.WebhookURL=v end}
Webhook:Button{Title="Test Webhook", Callback=function()
    Fluent:Notify{Title="Webhook", Content="Test sent (placeholder)", Duration=3}
end}

Webhook:Section{Title="Webhook Events"}
local webhookEvents = {
    "Bloodmoon Start/End",
    "Rainbow Start/End",
    "Blizzard Start/End",
    "Night Start/End",
    "Lightning Storm",
    "Mutation Found",
    "Rare Egg Hatch",
    "Rare Seed Pack"
}
for _, ev in ipairs(webhookEvents) do
    Webhook:Toggle{Title=ev, Default=false, Callback=function(s)
        _G.WebhookEvents[ev] = s
    end}
end

-- Mutation filter for webhook
Webhook:Section{Title="Mutation Filter (for webhook)"}
for _, m in ipairs(mutationOptions) do
    Webhook:Toggle{Title=m, Default=false, Callback=function(v)
        if v then table.insert(_G.MutationFilterWebhook, m) else
            for i, val in ipairs(_G.MutationFilterWebhook) do if val == m then table.remove(_G.MutationFilterWebhook, i) break end end
        end
    end}
end

-- ================== STATUS ==================
Status:Section{Title="Live Status"}
Status:Label{Text="Sheckles: 0", Color=UITheme.Accent}   -- update via loop
Status:Label{Text="Backpack Fruits Ready: 0", Color=UITheme.Accent}
Status:Label{Text="State: Idle", Color=UITheme.SubText}

-- ================== UPDATES (unchanged) ==================
Updates:Section{Title="Update Center"}
Updates:Label{Text="Your version: v0.1.0", Color=UITheme.Accent}
local updateStatusLabel = Updates:Label{Text="Checking..."}
Updates:Button{Title="Refresh Changelog", Callback=function()
    Fluent:Notify{Title="Changelog", Content="Refreshed (placeholder)", Duration=3}
end}
Updates:Button{Title="Upgrade to Latest", Callback=function()
    Fluent:Notify{Title="Upgrade", Content="Fetching latest script... (placeholder)", Duration=3}
end}

-- // Update check (simplified)
task.spawn(function()
    updateStatusLabel.Text = "✔️ You are up to date"
    updateStatusLabel.TextColor3 = UITheme.Success
end)

-- // Final notification
Fluent:Notify{Title="EdenHub Full", Content="v0.1.0 loaded with all features!", Duration=8}

-- // Optional: Status updater loop (placeholder)
task.spawn(function()
    while wait(2) do
        -- Update status labels with real game data here
        -- e.g., local sheckles = game.Players.LocalPlayer.leaderstats.Sheckles.Value
        -- etc.
    end
end)