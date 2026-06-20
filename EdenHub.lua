--[[
    EdenHub v0.0.1 – Full UI Script for Grow a Garden 2
    All features are stubbed – replace the placeholder functions with actual automation logic.
]]

-- ======================== JSON Library (lightweight) =========================
-- Simple encode/decode for saving/loading config
local JSON = {}
function JSON.encode(t)
    local function serialize(val)
        if type(val) == "table" then
            local items = {}
            for k, v in pairs(val) do
                local key = type(k) == "string" and string.format("%q", k) or tostring(k)
                table.insert(items, key .. ":" .. serialize(v))
            end
            return "{" .. table.concat(items, ",") .. "}"
        elseif type(val) == "string" then
            return string.format("%q", val)
        elseif type(val) == "number" then
            return tostring(val)
        elseif type(val) == "boolean" then
            return tostring(val)
        else
            return "null"
        end
    end
    return serialize(t)
end
function JSON.decode(str)
    -- Simple but robust; use loadstring for safety (only trusted input)
    local f, err = loadstring("return " .. str)
    if f then
        return f()
    else
        return nil
    end
end

-- ============================ UI Library ====================================
local UILib = {}
UILib.Objects = {}  -- store created controls for saving/loading

-- Main window
function UILib:CreateWindow(title, version)
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "EdenHub"
    screenGui.ResetOnSpawn = false
    screenGui.Parent = game:GetService("CoreGui")

    local mainFrame = Instance.new("Frame")
    mainFrame.Name = "MainFrame"
    mainFrame.Size = UDim2.new(0, 500, 0, 600)
    mainFrame.Position = UDim2.new(0.5, -250, 0.5, -300)
    mainFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
    mainFrame.BackgroundTransparency = 0.15
    mainFrame.BorderSizePixel = 0
    mainFrame.Parent = screenGui
    local corner = Instance.new("UICorner", mainFrame)
    corner.CornerRadius = UDim.new(0, 12)

    -- Blur effect (optional, may not work on all executors)
    local blur = Instance.new("BlurEffect", game:GetService("Lighting"))
    blur.Size = 0

    -- Title bar (draggable)
    local titleBar = Instance.new("Frame")
    titleBar.Size = UDim2.new(1, 0, 0, 30)
    titleBar.BackgroundColor3 = Color3.fromRGB(40, 40, 55)
    titleBar.BackgroundTransparency = 0.2
    titleBar.BorderSizePixel = 0
    titleBar.Parent = mainFrame
    local titleCorner = Instance.new("UICorner", titleBar)
    titleCorner.CornerRadius = UDim.new(0, 12)

    local titleLabel = Instance.new("TextLabel")
    titleLabel.Size = UDim2.new(1, -60, 1, 0)
    titleLabel.Position = UDim2.new(0, 10, 0, 0)
    titleLabel.BackgroundTransparency = 1
    titleLabel.Text = title .. " " .. version
    titleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    titleLabel.TextScaled = true
    titleLabel.Font = Enum.Font.GothamBold
    titleLabel.TextXAlignment = Enum.TextXAlignment.Left
    titleLabel.Parent = titleBar

    -- Close button
    local closeBtn = Instance.new("TextButton")
    closeBtn.Size = UDim2.new(0, 25, 0, 25)
    closeBtn.Position = UDim2.new(1, -30, 0, 2.5)
    closeBtn.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
    closeBtn.Text = "X"
    closeBtn.TextColor3 = Color3.fromRGB(255,255,255)
    closeBtn.TextScaled = true
    closeBtn.Font = Enum.Font.GothamBold
    closeBtn.BorderSizePixel = 0
    closeBtn.Parent = titleBar
    local closeCorner = Instance.new("UICorner", closeBtn)
    closeCorner.CornerRadius = UDim.new(0, 8)
    closeBtn.MouseButton1Click:Connect(function()
        screenGui.Enabled = not screenGui.Enabled
    end)

    -- Make window draggable (simple)
    local dragging, dragInput, dragStart, startPos
    titleBar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            dragStart = input.Position
            startPos = mainFrame.Position
        end
    end)
    titleBar.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = false
        end
    end)
    game:GetService("UserInputService").InputChanged:Connect(function(input)
        if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            local delta = input.Position - dragStart
            mainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)

    -- Tab container
    local tabBar = Instance.new("Frame")
    tabBar.Size = UDim2.new(1, 0, 0, 30)
    tabBar.Position = UDim2.new(0, 0, 0, 30)
    tabBar.BackgroundTransparency = 1
    tabBar.Parent = mainFrame

    -- Content container (will hold tab frames)
    local content = Instance.new("Frame")
    content.Size = UDim2.new(1, -10, 1, -70)
    content.Position = UDim2.new(0, 5, 0, 65)
    content.BackgroundTransparency = 1
    content.Parent = mainFrame

    -- Store references
    local self = {
        ScreenGui = screenGui,
        MainFrame = mainFrame,
        Content = content,
        TabBar = tabBar,
        TitleBar = titleBar,
        Tabs = {},
        CurrentTab = nil,
        Controls = {}  -- for saving
    }

    -- Create a tab
    function self:CreateTab(name)
        local btn = Instance.new("TextButton")
        btn.Size = UDim2.new(0, 70, 1, 0)
        btn.BackgroundTransparency = 1
        btn.Text = name
        btn.TextColor3 = Color3.fromRGB(200,200,200)
        btn.TextScaled = true
        btn.Font = Enum.Font.GothamMedium
        btn.BorderSizePixel = 0
        btn.Parent = tabBar

        local tabFrame = Instance.new("ScrollingFrame")
        tabFrame.Size = UDim2.new(1, 0, 1, 0)
        tabFrame.BackgroundTransparency = 1
        tabFrame.BorderSizePixel = 0
        tabFrame.Parent = content
        tabFrame.Visible = false
        tabFrame.ScrollBarThickness = 4
        tabFrame.ScrollBarImageColor3 = Color3.fromRGB(100,100,100)

        local layout = Instance.new("UIListLayout")
        layout.Parent = tabFrame
        layout.SortOrder = Enum.SortOrder.LayoutOrder
        layout.Padding = UDim.new(0, 5)

        local padding = Instance.new("UIPadding")
        padding.Parent = tabFrame
        padding.PaddingTop = UDim.new(0, 5)
        padding.PaddingBottom = UDim.new(0, 5)

        -- Click to switch
        btn.MouseButton1Click:Connect(function()
            for _, v in pairs(content:GetChildren()) do
                if v:IsA("ScrollingFrame") then v.Visible = false end
            end
            tabFrame.Visible = true
            self.CurrentTab = name
            -- Update button color
            for _, b in pairs(tabBar:GetChildren()) do
                if b:IsA("TextButton") then
                    b.TextColor3 = Color3.fromRGB(200,200,200)
                end
            end
            btn.TextColor3 = Color3.fromRGB(255,255,255)
        end)

        -- If first tab, show it
        if not self.CurrentTab then
            tabFrame.Visible = true
            self.CurrentTab = name
            btn.TextColor3 = Color3.fromRGB(255,255,255)
        end

        self.Tabs[name] = {Button = btn, Frame = tabFrame, Layout = layout}
        return tabFrame
    end

    -- Helper: create a section header
    function self:CreateHeader(parent, text)
        local lbl = Instance.new("TextLabel")
        lbl.Size = UDim2.new(1, -10, 0, 25)
        lbl.Position = UDim2.new(0, 5, 0, 0)
        lbl.BackgroundTransparency = 1
        lbl.Text = text
        lbl.TextColor3 = Color3.fromRGB(180,180,220)
        lbl.TextScaled = true
        lbl.Font = Enum.Font.GothamBold
        lbl.TextXAlignment = Enum.TextXAlignment.Left
        lbl.Parent = parent
        return lbl
    end

    -- Helper: create a control row (frame with label and control)
    function self:CreateControlRow(parent, labelText, control)
        local row = Instance.new("Frame")
        row.Size = UDim2.new(1, -10, 0, 30)
        row.BackgroundTransparency = 1
        row.Parent = parent

        local lbl = Instance.new("TextLabel")
        lbl.Size = UDim2.new(0.5, -5, 1, 0)
        lbl.Position = UDim2.new(0, 5, 0, 0)
        lbl.BackgroundTransparency = 1
        lbl.Text = labelText
        lbl.TextColor3 = Color3.fromRGB(220,220,220)
        lbl.TextScaled = true
        lbl.Font = Enum.Font.Gotham
        lbl.TextXAlignment = Enum.TextXAlignment.Left
        lbl.Parent = row

        control.Position = UDim2.new(0.5, 5, 0, 0)
        control.Size = UDim2.new(0.5, -10, 1, 0)
        control.Parent = row

        return row
    end

    -- Toggle
    function self:CreateToggle(parent, label, default, callback)
        local toggle = Instance.new("TextButton")
        toggle.BackgroundColor3 = default and Color3.fromRGB(100,200,100) or Color3.fromRGB(200,80,80)
        toggle.Text = default and "ON" or "OFF"
        toggle.TextColor3 = Color3.fromRGB(255,255,255)
        toggle.TextScaled = true
        toggle.Font = Enum.Font.GothamBold
        toggle.BorderSizePixel = 0
        local corner = Instance.new("UICorner", toggle)
        corner.CornerRadius = UDim.new(0, 4)

        local state = default
        toggle.MouseButton1Click:Connect(function()
            state = not state
            toggle.BackgroundColor3 = state and Color3.fromRGB(100,200,100) or Color3.fromRGB(200,80,80)
            toggle.Text = state and "ON" or "OFF"
            if callback then callback(state) end
        end)

        self:CreateControlRow(parent, label, toggle)
        -- Store for saving
        table.insert(self.Controls, {Type = "Toggle", Object = toggle, Label = label, Get = function() return state end, Set = function(v)
            state = v
            toggle.BackgroundColor3 = v and Color3.fromRGB(100,200,100) or Color3.fromRGB(200,80,80)
            toggle.Text = v and "ON" or "OFF"
        end})
        return toggle
    end

    -- Slider
    function self:CreateSlider(parent, label, min, max, default, callback)
        local sliderFrame = Instance.new("Frame")
        sliderFrame.Size = UDim2.new(1, 0, 1, 0)
        sliderFrame.BackgroundTransparency = 1

        local valueLabel = Instance.new("TextLabel")
        valueLabel.Size = UDim2.new(0.2, 0, 1, 0)
        valueLabel.Position = UDim2.new(0.8, 0, 0, 0)
        valueLabel.BackgroundTransparency = 1
        valueLabel.Text = tostring(default)
        valueLabel.TextColor3 = Color3.fromRGB(255,255,200)
        valueLabel.TextScaled = true
        valueLabel.Font = Enum.Font.Gotham
        valueLabel.Parent = sliderFrame

        local slider = Instance.new("Frame")
        slider.Size = UDim2.new(0.75, 0, 0.4, 0)
        slider.Position = UDim2.new(0, 0, 0.3, 0)
        slider.BackgroundColor3 = Color3.fromRGB(60,60,80)
        slider.BorderSizePixel = 0
        slider.Parent = sliderFrame
        local sliderCorner = Instance.new("UICorner", slider)
        sliderCorner.CornerRadius = UDim.new(0, 4)

        local fill = Instance.new("Frame")
        fill.Size = UDim2.new((default - min) / (max - min), 0, 1, 0)
        fill.BackgroundColor3 = Color3.fromRGB(100,200,255)
        fill.BorderSizePixel = 0
        fill.Parent = slider
        local fillCorner = Instance.new("UICorner", fill)
        fillCorner.CornerRadius = UDim.new(0, 4)

        local dragging = false
        local function update(pos)
            local rel = (pos.X - slider.AbsolutePosition.X) / slider.AbsoluteSize.X
            rel = math.clamp(rel, 0, 1)
            local val = min + (max - min) * rel
            val = math.round(val)
            fill.Size = UDim2.new(rel, 0, 1, 0)
            valueLabel.Text = tostring(val)
            if callback then callback(val) end
        end

        slider.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 then
                dragging = true
                update(input.Position)
            end
        end)
        game:GetService("UserInputService").InputChanged:Connect(function(input)
            if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
                update(input.Position)
            end
        end)
        game:GetService("UserInputService").InputEnded:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 then
                dragging = false
            end
        end)

        self:CreateControlRow(parent, label, sliderFrame)
        table.insert(self.Controls, {Type = "Slider", Object = slider, Label = label, Get = function() return tonumber(valueLabel.Text) end, Set = function(v)
            local rel = (v - min) / (max - min)
            rel = math.clamp(rel, 0, 1)
            fill.Size = UDim2.new(rel, 0, 1, 0)
            valueLabel.Text = tostring(v)
        end})
        return slider
    end

    -- Dropdown
    function self:CreateDropdown(parent, label, options, defaultIndex, callback)
        local drop = Instance.new("TextButton")
        drop.BackgroundColor3 = Color3.fromRGB(50,50,70)
        drop.Text = options[defaultIndex] or options[1]
        drop.TextColor3 = Color3.fromRGB(255,255,255)
        drop.TextScaled = true
        drop.Font = Enum.Font.Gotham
        drop.BorderSizePixel = 0
        local corner = Instance.new("UICorner", drop)
        corner.CornerRadius = UDim.new(0, 4)

        local selectedIndex = defaultIndex or 1
        drop.MouseButton1Click:Connect(function()
            -- Simple cycle through options
            selectedIndex = selectedIndex % #options + 1
            drop.Text = options[selectedIndex]
            if callback then callback(options[selectedIndex], selectedIndex) end
        end)

        self:CreateControlRow(parent, label, drop)
        table.insert(self.Controls, {Type = "Dropdown", Object = drop, Label = label, Options = options, Get = function() return options[selectedIndex] end, Set = function(idx)
            selectedIndex = idx
            drop.Text = options[idx]
        end})
        return drop
    end

    -- Input box
    function self:CreateInput(parent, label, placeholder, callback)
        local box = Instance.new("TextBox")
        box.BackgroundColor3 = Color3.fromRGB(50,50,70)
        box.Text = ""
        box.PlaceholderText = placeholder
        box.TextColor3 = Color3.fromRGB(255,255,255)
        box.TextScaled = true
        box.Font = Enum.Font.Gotham
        box.BorderSizePixel = 0
        local corner = Instance.new("UICorner", box)
        corner.CornerRadius = UDim.new(0, 4)

        box.FocusLost:Connect(function(enter)
            if enter and callback then callback(box.Text) end
        end)

        self:CreateControlRow(parent, label, box)
        table.insert(self.Controls, {Type = "Input", Object = box, Label = label, Get = function() return box.Text end, Set = function(v) box.Text = v end})
        return box
    end

    -- Button
    function self:CreateButton(parent, label, callback)
        local btn = Instance.new("TextButton")
        btn.Size = UDim2.new(0.8, 0, 0, 30)
        btn.Position = UDim2.new(0.1, 0, 0, 0)
        btn.BackgroundColor3 = Color3.fromRGB(70,70,120)
        btn.Text = label
        btn.TextColor3 = Color3.fromRGB(255,255,255)
        btn.TextScaled = true
        btn.Font = Enum.Font.GothamBold
        btn.BorderSizePixel = 0
        local corner = Instance.new("UICorner", btn)
        corner.CornerRadius = UDim.new(0, 6)

        btn.MouseButton1Click:Connect(callback)

        btn.Parent = parent
        return btn
    end

    -- Keybind (simple toggle with input)
    function self:CreateKeybind(parent, label, defaultKey, callback)
        local btn = Instance.new("TextButton")
        btn.Size = UDim2.new(0.4, 0, 1, 0)
        btn.Position = UDim2.new(0.6, 0, 0, 0)
        btn.BackgroundColor3 = Color3.fromRGB(50,50,70)
        btn.Text = "Set Key"
        btn.TextColor3 = Color3.fromRGB(255,255,255)
        btn.TextScaled = true
        btn.Font = Enum.Font.Gotham
        btn.BorderSizePixel = 0
        local corner = Instance.new("UICorner", btn)
        corner.CornerRadius = UDim.new(0, 4)

        local key = defaultKey
        local listening = false

        btn.MouseButton1Click:Connect(function()
            listening = not listening
            btn.Text = listening and "Press any key..." or "Set Key"
            if not listening and callback then callback(key) end
        end)

        game:GetService("UserInputService").InputBegan:Connect(function(input, processed)
            if processed then return end
            if listening and input.KeyCode ~= Enum.KeyCode.Unknown then
                key = input.KeyCode
                listening = false
                btn.Text = "Set Key"
                if callback then callback(key) end
            end
        end)

        self:CreateControlRow(parent, label, btn)
        table.insert(self.Controls, {Type = "Keybind", Object = btn, Label = label, Get = function() return key end, Set = function(k) key = k end})
        return btn
    end

    return self
end

-- =========================== Main Script ====================================

local Eden = UILib:CreateWindow("EdenHub", "v2.0")

-- Utility functions (placeholders)
local function log(msg)
    print("[EdenHub] " .. msg)
end

-- ============================ TABS =========================================

-- 1. Player Tab
local playerTab = Eden:CreateTab("Player")
Eden:CreateHeader(playerTab, "Movement")
Eden:CreateSlider(playerTab, "WalkSpeed", 16, 100, 16, function(v)
    -- apply to player
    local plr = game.Players.LocalPlayer
    if plr.Character and plr.Character:FindFirstChild("Humanoid") then
        plr.Character.Humanoid.WalkSpeed = v
    end
end)
Eden:CreateSlider(playerTab, "JumpPower", 50, 200, 50, function(v)
    local plr = game.Players.LocalPlayer
    if plr.Character and plr.Character:FindFirstChild("Humanoid") then
        plr.Character.Humanoid.JumpPower = v
    end
end)
Eden:CreateToggle(playerTab, "Noclip", false, function(state)
    -- noclip logic (placeholder)
    log("Noclip: " .. tostring(state))
end)
Eden:CreateToggle(playerTab, "Infinite Jump", false, function(state)
    -- infinite jump logic
    log("Infinite Jump: " .. tostring(state))
end)
Eden:CreateToggle(playerTab, "Anti-AFK", false, function(state)
    log("Anti-AFK: " .. tostring(state))
end)
Eden:CreateToggle(playerTab, "Anti-Sit", false, function(state)
    log("Anti-Sit: " .. tostring(state))
end)

-- 2. Automation Tab (shops, auto collect/plant/sell, etc.)
local autoTab = Eden:CreateTab("Automation")
Eden:CreateHeader(autoTab, "Shop")
Eden:CreateDropdown(autoTab, "Seed to Buy", {"Tomato", "Apple", "Strawberry", "Pineapple"}, 1, function(seed)
    log("Selected seed: " .. seed)
end)
Eden:CreateButton(autoTab, "Start Auto-Buy Seed", function()
    log("Starting auto-buy seed...")
end)
Eden:CreateButton(autoTab, "Auto Buy All Seeds", function()
    log("Buying all seeds...")
end)

Eden:CreateHeader(autoTab, "Gear")
Eden:CreateDropdown(autoTab, "Gear to Buy", {"Shovel", "Watering Can", "Trowel"}, 1, function(gear)
    log("Selected gear: " .. gear)
end)
Eden:CreateButton(autoTab, "Start Auto-Buy Gear", function()
    log("Auto-buy gear...")
end)
Eden:CreateButton(autoTab, "Auto Buy All Gear", function()
    log("Buying all gear...")
end)

Eden:CreateHeader(autoTab, "Crates & Pets")
Eden:CreateButton(autoTab, "Auto Buy Crates", function()
    log("Auto buying crates...")
end)
Eden:CreateToggle(autoTab, "Auto Equip Pets", false, function(state)
    log("Auto equip pets: " .. tostring(state))
end)
Eden:CreateDropdown(autoTab, "Pet to Buy", {"Common", "Uncommon", "Rare", "Legendary"}, 1, function(rarity)
    log("Pet rarity: " .. rarity)
end)
Eden:CreateButton(autoTab, "Auto Buy Pet", function()
    log("Auto buying pet...")
end)
Eden:CreateToggle(autoTab, "Auto Server Hop for Pet", false, function(state)
    log("Auto server hop: " .. tostring(state))
end)
Eden:CreateSlider(autoTab, "Hop Delay (s)", 0, 10, 2, function(v)
    log("Hop delay: " .. v .. "s")
end)

Eden:CreateHeader(autoTab, "Auto Collect")
Eden:CreateToggle(autoTab, "Auto Collect Plants", false, function(state)
    log("Auto collect: " .. tostring(state))
end)
Eden:CreateSlider(autoTab, "Weight Threshold (kg)", 0, 10, 1, function(v)
    log("Weight threshold: " .. v .. "kg")
end)
Eden:CreateToggle(autoTab, "Harvest Highest Value First", false, function(state)
    log("Harvest highest value: " .. tostring(state))
end)
Eden:CreateToggle(autoTab, "Auto-TP to Garden", false, function(state)
    log("Auto-TP: " .. tostring(state))
end)
Eden:CreateToggle(autoTab, "Auto Collect Event Seeds", false, function(state)
    log("Collect event seeds: " .. tostring(state))
end)
Eden:CreateToggle(autoTab, "Auto Collect Dropped Seeds", false, function(state)
    log("Collect dropped seeds: " .. tostring(state))
end)

Eden:CreateHeader(autoTab, "Auto Plant")
Eden:CreateDropdown(autoTab, "Plant Seed", {"Tomato", "Apple", "Strawberry", "Pineapple"}, 1, function(seed)
    log("Plant seed: " .. seed)
end)
Eden:CreateButton(autoTab, "Start Auto-Plant", function()
    log("Starting auto-plant...")
end)
Eden:CreateInput(autoTab, "Save CFrame", "Position", function(pos)
    log("Saved CFrame: " .. pos)
end)

Eden:CreateHeader(autoTab, "Auto Shovel")
Eden:CreateToggle(autoTab, "Auto Shovel", false, function(state)
    log("Auto shovel: " .. tostring(state))
end)
Eden:CreateDropdown(autoTab, "Shovel Filter", {"All", "Mutation", "Weight"}, 1, function(f)
    log("Shovel filter: " .. f)
end)
Eden:CreateToggle(autoTab, "Ignore Favorited", false, function(state)
    log("Ignore fav: " .. tostring(state))
end)

Eden:CreateHeader(autoTab, "Auto Sell")
Eden:CreateToggle(autoTab, "Auto Sell when Full", false, function(state)
    log("Auto sell full: " .. tostring(state))
end)
Eden:CreateSlider(autoTab, "Sell Interval (s)", 1, 60, 10, function(v)
    log("Sell interval: " .. v)
end)
Eden:CreateToggle(autoTab, "Auto Bargain Sell (5x)", false, function(state)
    log("Bargain sell: " .. tostring(state))
end)
Eden:CreateInput(autoTab, "Protect Fruits", "fruit1, fruit2", function(v)
    log("Protected fruits: " .. v)
end)

Eden:CreateHeader(autoTab, "Wishlist (Reroll)")
Eden:CreateInput(autoTab, "Target Seed", "Apple", function(v)
    log("Wishlist target: " .. v)
end)
Eden:CreateButton(autoTab, "Start Reroll", function()
    log("Starting reroll...")
end)

-- 3. Plants Tab
local plantTab = Eden:CreateTab("Plants")
Eden:CreateHeader(plantTab, "Auto Water")
Eden:CreateToggle(plantTab, "Auto Water", false, function(state)
    log("Auto water: " .. tostring(state))
end)
Eden:CreateSlider(plantTab, "Plants per Cycle", 1, 10, 5, function(v)
    log("Water per cycle: " .. v)
end)

Eden:CreateHeader(plantTab, "Auto Trowel")
Eden:CreateToggle(plantTab, "Auto Trowel", false, function(state)
    log("Auto trowel: " .. tostring(state))
end)
Eden:CreateInput(plantTab, "Target CFrame", "CFrame", function(v)
    log("Trowel target: " .. v)
end)
Eden:CreateSlider(plantTab, "Max per Cycle", 1, 20, 5, function(v)
    log("Trowel max: " .. v)
end)

Eden:CreateHeader(plantTab, "Auto Sprinkler")
Eden:CreateDropdown(plantTab, "Sprinkler Type", {"Basic", "Advanced", "Premium"}, 1, function(t)
    log("Sprinkler type: " .. t)
end)
Eden:CreateButton(plantTab, "Place Sprinkler", function()
    log("Placing sprinkler...")
end)

Eden:CreateHeader(plantTab, "Auto Favourite")
Eden:CreateToggle(plantTab, "Auto Favourite (Backpack)", false, function(state)
    log("Auto fav backpack: " .. tostring(state))
end)
Eden:CreateToggle(plantTab, "Auto Favourite (Garden)", false, function(state)
    log("Auto fav garden: " .. tostring(state))
end)
Eden:CreateDropdown(plantTab, "Favourite by", {"Plant", "Mutation", "Weight"}, 1, function(f)
    log("Fav by: " .. f)
end)

-- 4. Misc Tab
local miscTab = Eden:CreateTab("Misc")
Eden:CreateHeader(miscTab, "Seed Pack")
Eden:CreateButton(miscTab, "Auto Skip/Open Pack", function()
    log("Opening pack...")
end)
Eden:CreateToggle(miscTab, "Remove Roll UI", false, function(state)
    log("Remove roll UI: " .. tostring(state))
end)
Eden:CreateToggle(miscTab, "Auto Accept Gift", false, function(state)
    log("Auto accept gift: " .. tostring(state))
end)

Eden:CreateHeader(miscTab, "Auto Trader")
Eden:CreateInput(miscTab, "Target Username", "user", function(v)
    log("Target: " .. v)
end)
Eden:CreateInput(miscTab, "Offer Message", "trade pls", function(v)
    log("Offer msg: " .. v)
end)
Eden:CreateToggle(miscTab, "Auto Accept Incoming", false, function(state)
    log("Auto accept incoming: " .. tostring(state))
end)
Eden:CreateButton(miscTab, "Start Trading", function()
    log("Starting trade...")
end)
Eden:CreateToggle(miscTab, "Webhook on Success", false, function(state)
    log("Webhook success: " .. tostring(state))
end)

Eden:CreateHeader(miscTab, "Auto Steal (Night Fruit)")
Eden:CreateToggle(miscTab, "Auto Steal", false, function(state)
    log("Auto steal: " .. tostring(state))
end)
Eden:CreateSlider(miscTab, "Min Value", 0, 1000, 100, function(v)
    log("Min steal value: " .. v)
end)
Eden:CreateSlider(miscTab, "Fruits per Trip", 1, 5, 3, function(v)
    log("Fruits per trip: " .. v)
end)
Eden:CreateToggle(miscTab, "Anti-Hit", false, function(state)
    log("Anti-hit: " .. tostring(state))
end)
Eden:CreateToggle(miscTab, "Center in Garden", false, function(state)
    log("Center garden: " .. tostring(state))
end)

Eden:CreateHeader(miscTab, "Auto Mail")
Eden:CreateInput(miscTab, "Send To", "username", function(v)
    log("Mail recipient: " .. v)
end)
Eden:CreateInput(miscTab, "Items (max items)", "pet1, seed2", function(v)
    log("Mail items: " .. v)
end)
Eden:CreateToggle(miscTab, "Auto Send", false, function(state)
    log("Auto send: " .. tostring(state))
end)
Eden:CreateToggle(miscTab, "Auto Accept Incoming", false, function(state)
    log("Auto accept mail: " .. tostring(state))
end)
Eden:CreateToggle(miscTab, "Anti-Malicious Scripts", false, function(state)
    log("Anti-malicious: " .. tostring(state))
end)

-- 5. Utility Tab
local utilTab = Eden:CreateTab("Utility")
Eden:CreateHeader(utilTab, "Server")
Eden:CreateInput(utilTab, "Join JobId", "jobid", function(v)
    log("Join JobId: " .. v)
end)
Eden:CreateInput(utilTab, "PlaceVersion", "version", function(v)
    log("PlaceVersion: " .. v)
end)
Eden:CreateSlider(utilTab, "Hop Delay (s)", 0, 10, 2, function(v)
    log("Hop delay: " .. v)
end)
Eden:CreateButton(utilTab, "Hop to Target", function()
    log("Hopping...")
end)

Eden:CreateHeader(utilTab, "Optimizations")
Eden:CreateToggle(utilTab, "FPS Boost", false, function(state)
    log("FPS boost: " .. tostring(state))
end)
Eden:CreateToggle(utilTab, "Low Graphics", false, function(state)
    log("Low graphics: " .. tostring(state))
end)
Eden:CreateToggle(utilTab, "Black/White Screen", false, function(state)
    log("Black/white: " .. tostring(state))
end)
Eden:CreateToggle(utilTab, "Hide All Plants", false, function(state)
    log("Hide plants: " .. tostring(state))
end)
Eden:CreateButton(utilTab, "Delete Other Players' Plants", function()
    log("Deleting plants...")
end)
Eden:CreateButton(utilTab, "Delete All Plants", function()
    log("Deleting all plants...")
end)

Eden:CreateHeader(utilTab, "Calculations")
Eden:CreateToggle(utilTab, "Show Fruit Prices", false, function(state)
    log("Show fruit prices: " .. tostring(state))
end)
Eden:CreateToggle(utilTab, "Show Pet Prices", false, function(state)
    log("Show pet prices: " .. tostring(state))
end)

Eden:CreateHeader(utilTab, "Webhook")
Eden:CreateInput(utilTab, "Webhook URL", "https://discord.com/api/webhooks/...", function(v)
    log("Webhook URL set")
end)
Eden:CreateToggle(utilTab, "Status Webhook Loop", false, function(state)
    log("Status webhook: " .. tostring(state))
end)
Eden:CreateSlider(utilTab, "Loop Interval (s)", 10, 300, 60, function(v)
    log("Webhook interval: " .. v)
end)

Eden:CreateHeader(utilTab, "RakNet Desync")
Eden:CreateToggle(utilTab, "RakNet Desync (Anti-TP)", false, function(state)
    log("RakNet desync: " .. tostring(state) .. " (use with caution!)")
end)

-- 6. Pet Finder Tab
local petTab = Eden:CreateTab("PetFinder")
Eden:CreateHeader(petTab, "Live Wild Pet Feed")
Eden:CreateToggle(petTab, "Enable Feed", false, function(state)
    log("Pet feed enabled: " .. tostring(state))
end)
Eden:CreateDropdown(petTab, "Tier", {"Keyless", "AED+", "Freshest"}, 1, function(t)
    log("Tier: " .. t)
end)
Eden:CreateInput(petTab, "Search", "pet name", function(v)
    log("Search: " .. v)
end)
Eden:CreateButton(petTab, "Sort", function()
    log("Sorting feed...")
end)
Eden:CreateButton(petTab, "Join Selected", function()
    log("Joining...")
end)

-- 7. Settings Tab
local settingsTab = Eden:CreateTab("Settings")
Eden:CreateHeader(settingsTab, "UI")
Eden:CreateKeybind(settingsTab, "Menu Toggle", Enum.KeyCode.RightShift, function(key)
    log("Menu keybind set to: " .. tostring(key))
end)
Eden:CreateToggle(settingsTab, "Auto Execute on Load", false, function(state)
    log("Auto execute: " .. tostring(state))
end)
Eden:CreateToggle(settingsTab, "Auto Reconnect", false, function(state)
    log("Auto reconnect: " .. tostring(state))
end)
Eden:CreateToggle(settingsTab, "Rejoin on Ping Freeze", false, function(state)
    log("Rejoin on freeze: " .. tostring(state))
end)
Eden:CreateToggle(settingsTab, "Custom Cursor", false, function(state)
    log("Custom cursor: " .. tostring(state))
end)
Eden:CreateToggle(settingsTab, "Watermark", true, function(state)
    log("Watermark: " .. tostring(state))
end)
Eden:CreateToggle(settingsTab, "Notifications", true, function(state)
    log("Notifications: " .. tostring(state))
end)
Eden:CreateSlider(settingsTab, "DPI Scale", 0.5, 2, 1, function(v)
    log("DPI scale: " .. v)
end)

Eden:CreateHeader(settingsTab, "Config")
Eden:CreateButton(settingsTab, "Save Config", function()
    SaveConfig()
end)
Eden:CreateButton(settingsTab, "Load Config", function()
    LoadConfig()
end)

-- ============================ Config Save/Load =============================

local CONFIG_FILE = "EdenHubConfig.json"

function SaveConfig()
    local config = {}
    for _, c in ipairs(Eden.Controls) do
        if c.Type == "Toggle" then
            config[c.Label] = {Type = "Toggle", Value = c.Get()}
        elseif c.Type == "Slider" then
            config[c.Label] = {Type = "Slider", Value = c.Get()}
        elseif c.Type == "Dropdown" then
            -- save selected index by finding the option
            local current = c.Get()
            local idx = 1
            for i, opt in ipairs(c.Options) do
                if opt == current then idx = i; break end
            end
            config[c.Label] = {Type = "Dropdown", Value = idx}
        elseif c.Type == "Input" then
            config[c.Label] = {Type = "Input", Value = c.Get()}
        elseif c.Type == "Keybind" then
            config[c.Label] = {Type = "Keybind", Value = tostring(c.Get())}
        end
    end
    local json = JSON.encode(config)
    if writefile then
        writefile(CONFIG_FILE, json)
        log("Config saved to " .. CONFIG_FILE)
    else
        log("writefile not available – config not saved")
    end
end

function LoadConfig()
    if not readfile then
        log("readfile not available – cannot load config")
        return
    end
    local data = readfile(CONFIG_FILE)
    if not data then
        log("No config file found")
        return
    end
    local config = JSON.decode(data)
    if not config then
        log("Failed to parse config")
        return
    end
    for _, c in ipairs(Eden.Controls) do
        local entry = config[c.Label]
        if entry then
            if c.Type == "Toggle" then
                c.Set(entry.Value)
            elseif c.Type == "Slider" then
                c.Set(entry.Value)
            elseif c.Type == "Dropdown" then
                c.Set(entry.Value)
            elseif c.Type == "Input" then
                c.Set(entry.Value)
            elseif c.Type == "Keybind" then
                -- convert string to KeyCode
                local success, key = pcall(function() return Enum.KeyCode[entry.Value] end)
                if success and key then
                    c.Set(key)
                end
            end
        end
    end
    log("Config loaded from " .. CONFIG_FILE)
end

-- ============================ Auto-Execute ================================
-- If AutoExecute is on, run any startup logic here

-- ============================ Main Loop (optional) ========================
-- Any background tasks can be added here

log("EdenHub loaded successfully!")
