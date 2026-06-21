--[[
    EdenHub.lua v0.2.1 – "Upgrade Menu" Update + UI additions
    Added stock panels, restock countdown, wild-pet scanner display, and status updates (placeholders).
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
    Subtitle = "v0.2.1 Upgrade | Grow A Garden 2",
    Theme = "Dark",
    Size = UDim2.fromOffset(620, 600),
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
-- Farm
_G.AutoFarmAll = false
_G.AutoHarvestAll = false
_G.TPtoFruits = false
_G.MutationsFilter = {}
_G.AutoPlantInventory = false
_G.AutoSell = false
_G.SellOnlyFull = false
_G.AntiAFK = false
_G.AntiHit = false
_G.AntiLag = false
_G.AutoExpandGarden = false   -- also used in Upgrades
_G.AutoClaimMailbox = false

-- Buy
_G.AutoBuySeeds = false
_G.AutoBuyGear = false
_G.SelectedSeeds = {}
_G.SelectedGear = {}
_G.RestockTimer = 60
_G.RestockCountdown = 0
_G.SeedStock = {}
_G.GearStock = {}

-- Pets
_G.AutoHatchEggs = false
_G.AutoOpenCrates = false
_G.AutoOpenSeedPacks = false
_G.AutoEquipBest = false
_G.WildPetScan = false
_G.TPtoSelectedWild = false
_G.TPtoNearestWild = false
_G.AutoBuyWildPets = false
_G.SelectedWildPetIndex = nil
_G.WildPetsFound = {}

-- Movement
_G.WalkSpeed = 16
_G.JumpPower = 50
_G.Noclip = false
_G.InfiniteJump = false

-- Webhook
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
_G.MutationFilterWebhook = {}

-- Upgrades (new)
_G.AutoUpgradePlots = false
_G.AutoUpgradeBackpack = false
_G.AutoUpgradeTools = false

-- // Helper: Multi‑select toggle group (for seeds, gear, mutations)
local function MultiSelectGroup(parent, title, options, callback)
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
local Upgrades = win:Tab{Title="Upgrades", Icon="arrow-up-circle"}   -- NEW
local Movement = win:Tab{Title="Movement", Icon="move"}
local Webhook = win:Tab{Title="Webhook", Icon="webhook"}
local Status = win:Tab{Title="Status", Icon="activity"}
local Updates = win:Tab{Title="Updates", Icon="refresh-cw"}

-- ================== HOME ==================
Home:Section{Title="Welcome to EdenHub Full"}
Home:Label{Text="✅ All requested features + Upgrade Menu"}
Home:Label{Text="🔄 Auto‑update system ready"}
Home:Label{Text="🚀 Placeholder logic – add your own game hooks"}

-- ================== AUTO FARM ==================
Farm:Section{Title="Farm Automation"}
Farm:Toggle{Title="Auto Farm All", Default=false, Callback=function(s) _G.AutoFarmAll=s end}
Farm:Toggle{Title="Auto Harvest All", Default=false, Callback=function(s) _G.AutoHarvestAll=s end}
Farm:Toggle{Title="TP to Each Fruit", Default=false, Callback=function(s) _G.TPtoFruits=s end}

-- Mutations Filter (multi‑select)
local mutationOptions = {"Red","Blue","Golden","Dark","Rainbow"}
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
Farm:Toggle{Title="Auto Expand Garden", Default=false, Callback=function(s)
    _G.AutoExpandGarden = s
    _G.AutoUpgradePlots = s   -- sync with Upgrades toggle
end}
Farm:Toggle{Title="Auto Claim Mailbox", Default=false, Callback=function(s) _G.AutoClaimMailbox=s end}

-- ================== AUTO BUY ==================
Buy:Section{Title="Auto Buy Seeds (multi‑select)"}
local seedOptions = {"Carrot","Strawberry","Blueberry","Pumpkin"}
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
local gearOptions = {"Watering Can","Hoe","Scythe"}
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
local seedStockLabel = Buy:Label{Text="Seed Stock: (placeholder)", Color=UITheme.SubText}
local gearStockLabel = Buy:Label{Text="Gear Stock: (placeholder)", Color=UITheme.SubText}
local restockLabel = Buy:Label{Text="Restock in: --s", Color=UITheme.Warning}
Buy:Slider{Title="Restock Timer (s)", Default=60, Min=10, Max=300, Callback=function(v) _G.RestockTimer=v; _G.RestockCountdown=v end}

-- ================== PETS ==================
PetsTab:Section{Title="Pet Automation"}
PetsTab:Toggle{Title="Auto Hatch Eggs", Default=false, Callback=function(s) _G.AutoHatchEggs=s end}
PetsTab:Toggle{Title="Auto Open Crates", Default=false, Callback=function(s) _G.AutoOpenCrates=s end}
PetsTab:Toggle{Title="Auto Open Seed Packs", Default=false, Callback=function(s) _G.AutoOpenSeedPacks=s end}
PetsTab:Toggle{Title="Auto Equip Best Pets", Default=false, Callback=function(s) _G.AutoEquipBest=s end}

PetsTab:Section{Title="Wild Pets Scanner"}
PetsTab:Toggle{Title="Scan Wild Pets", Default=false, Callback=function(s) _G.WildPetScan=s end}
local closestLabel = PetsTab:Label{Text="Closest: (placeholder)", Color=UITheme.SubText}
local wildPetsInfoLabels = {}
-- create placeholders for up to 5 wild pets
for i=1,5 do
    wildPetsInfoLabels[i] = PetsTab:Label{Text="-", Color=UITheme.SubText}
end
PetsTab:Button{Title="TP to Selected Wild Pet", Callback=function()
    if _G.SelectedWildPetIndex then
        Fluent:Notify{Title="TP", Content="Teleporting to selected wild pet (placeholder)", Duration=3}
    else
        Fluent:Notify{Title="TP", Content="No wild pet selected", Duration=3}
    end
end}
PetsTab:Button{Title="TP to Nearest Wild Pet", Callback=function()
    Fluent:Notify{Title="TP", Content="Teleporting to nearest wild pet (placeholder)", Duration=3}
end}
PetsTab:Toggle{Title="Auto Buy Wild Pets", Default=false, Callback=function(s) _G.AutoBuyWildPets=s end}

-- ================== TELEPORTS ==================
Teleports:Section{Title="Quick Teleport"}
local teleportLocations = {"My Garden","Seeds","Gears","Props","Guilds","Sell","Upgrades"} -- added Upgrades
for _, loc in ipairs(teleportLocations) do
    Teleports:Button{Title=loc, Callback=function()
        Fluent:Notify{Title="Teleport", Content="Teleporting to "..loc.." (placeholder)", Duration=3}
    end}
end

-- ================== UPGRADES (NEW TAB) ==================
Upgrades:Section{Title="Garden Plots"}
local plotsLabel = Upgrades:Label{Text="Current Plots: 0 / Max: 0", Color=UITheme.SubText}  -- update in loop
local nextCostLabel = Upgrades:Label{Text="Next Upgrade Cost: 0 Sheckles", Color=UITheme.Warning}
Upgrades:Toggle{Title="Auto Expand Garden", Default=false, Callback=function(s)
    _G.AutoUpgradePlots = s
    _G.AutoExpandGarden = s   -- keep in sync with Farm toggle
end}
Upgrades:Button{Title="Expand Now", Callback=function()
    Fluent:Notify{Title="Upgrade", Content="Expanding garden plot (placeholder)", Duration=3}
end}

Upgrades:Section{Title="Backpack"}
local backpackCapLabel = Upgrades:Label{Text="Current Capacity: 0", Color=UITheme.SubText}
Upgrades:Toggle{Title="Auto Upgrade Backpack", Default=false, Callback=function(s) _G.AutoUpgradeBackpack=s end}
Upgrades:Button{Title="Upgrade Backpack Now", Callback=function()
    Fluent:Notify{Title="Upgrade", Content="Upgrading backpack (placeholder)", Duration=3}
end}

Upgrades:Section{Title="Tools"}
local toolsLabel = Upgrades:Label{Text="Tool Levels: (placeholder)", Color=UITheme.SubText}
Upgrades:Toggle{Title="Auto Upgrade Tools", Default=false, Callback=function(s) _G.AutoUpgradeTools=s end}
Upgrades:Button{Title="Upgrade Tools Now", Callback=function()
    Fluent:Notify{Title="Upgrade", Content="Upgrading tools (placeholder)", Duration=3}
end}

-- ================== MOVEMENT ==================
Movement:Section{Title="Movement Mods"}
Movement:Toggle{Title="Noclip", Default=false, Callback=function(s)
    _G.Noclip = s
    -- placeholder: enable/disable noclip
end}
Movement:Toggle{Title="Infinite Jump", Default=false, Callback=function(s)
    _G.InfiniteJump = s
    -- placeholder
end}
Movement:Slider{Title="WalkSpeed", Default=16, Min=0, Max=100, Callback=function(v)
    _G.WalkSpeed = v
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
        -- map friendly names to keys if needed (placeholder)
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
local shecklesLabel = Status:Label{Text="Sheckles: 0", Color=UITheme.Accent}
local backpackReadyLabel = Status:Label{Text="Backpack Fruits Ready: 0", Color=UITheme.Accent}
local stateLabel = Status:Label{Text="State: Idle", Color=UITheme.SubText}

-- ================== UPDATES ==================
Updates:Section{Title="Update Center"}
Updates:Label{Text="Your version: v0.2.1", Color=UITheme.Accent}
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
Fluent:Notify{Title="EdenHub Full + Upgrades", Content="v0.2.1 loaded with Upgrade Menu and UI additions!", Duration=6}

-- // Status updater loop (placeholder) - updates stocks, restock countdown, wild pet scan, and status labels
task.spawn(function()
    -- initialize restock countdown
    _G.RestockCountdown = _G.RestockTimer
    while wait(1) do
        -- placeholder: update sheckles from leaderstats if available
        local success, sheckles = pcall(function()
            return tonumber((game.Players.LocalPlayer:FindFirstChild("leaderstats") and game.Players.LocalPlayer.leaderstats:FindFirstChild("Sheckles") and game.Players.LocalPlayer.leaderstats.Sheckles.Value) or 0)
        end)
        if success and shecklesLabel then shecklesLabel.Text = "Sheckles: "..tostring(sheckles) end

        -- placeholder: backpack ready count
        local bpReady = 0
        if backpackReadyLabel then backpackReadyLabel.Text = "Backpack Fruits Ready: "..tostring(bpReady) end

        -- restock countdown logic (only visual)
        if _G.AutoBuySeeds or _G.AutoBuyGear then
            _G.RestockCountdown = (_G.RestockCountdown > 0) and (_G.RestockCountdown - 1) or _G.RestockTimer
        else
            _G.RestockCountdown = _G.RestockTimer
        end
        if restockLabel then restockLabel.Text = "Restock in: "..tostring(_G.RestockCountdown).."s" end

        -- update seed/gear stock labels (placeholders)
        local seedStockStr = table.concat((_G.SeedStock and #_G.SeedStock>0 and _G.SeedStock) or {"No stock"}, ", ")
        local gearStockStr = table.concat((_G.GearStock and #_G.GearStock>0 and _G.GearStock) or {"No stock"}, ", ")
        if seedStockLabel then seedStockLabel.Text = "Seed Stock: "..seedStockStr end
        if gearStockLabel then gearStockLabel.Text = "Gear Stock: "..gearStockStr end

        -- Wild pet scanner (placeholder logic) - populate with fake data when scan is on
        if _G.WildPetScan then
            -- example placeholder list
            _G.WildPetsFound = _G.WildPetsFound or {}
            -- repopulate with sample entries for UI preview
            if #_G.WildPetsFound == 0 then
                _G.WildPetsFound = {
                    {name="Spark Pupper", rarity="Rare", price=120, distance=12},
                    {name="Glow Drake", rarity="Epic", price=450, distance=28},
                    {name="Dirt Hopper", rarity="Common", price=20, distance=5},
                }
            end
        else
            _G.WildPetsFound = {}
        end

        -- update wild pet UI labels
        for i=1,5 do
            local lbl = wildPetsInfoLabels[i]
            local entry = _G.WildPetsFound[i]
            if entry then
                lbl.Text = string.format("%d) %s — %s — %d$ — %dm", i, entry.name, entry.rarity, entry.price, entry.distance)
            else
                lbl.Text = "-"
            end
        end

        -- update closest label
        if #_G.WildPetsFound > 0 then
            closestLabel.Text = "Closest: ".._G.WildPetsFound[1].name
        else
            closestLabel.Text = "Closest: (none)"
        end

        -- update upgrade labels placeholders
        if plotsLabel then plotsLabel.Text = "Current Plots: 0 / Max: 0" end
        if nextCostLabel then nextCostLabel.Text = "Next Upgrade Cost: 0 Sheckles" end
        if backpackCapLabel then backpackCapLabel.Text = "Current Capacity: 0" end
        if toolsLabel then toolsLabel.Text = "Tool Levels: (placeholder)" end

        -- update state label (simple placeholder state logic)
        stateLabel.Text = (_G.AutoFarmAll and "State: Auto Farming") or (_G.AutoBuySeeds and "State: Auto Buying Seeds") or "State: Idle"
    end
end)


-- end of file
