-- ========================== 2026 UI LIBRARY ================================
-- Glassmorphism, responsive, animated, mobile+PC ready

local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")

local UILib = {}
UILib.Objects = {}

function UILib:CreateWindow(title, version)
    -- Create ScreenGui with a blur backdrop (if supported)
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "EdenHub"
    screenGui.ResetOnSpawn = false
    screenGui.Parent = game:GetService("CoreGui")

    -- Background blur (optional)
    local blur = Instance.new("BlurEffect")
    blur.Name = "EdenBlur"
    blur.Size = 0
    blur.Parent = game:GetService("Lighting")

    -- Main container with glass effect
    local mainFrame = Instance.new("Frame")
    mainFrame.Name = "MainFrame"
    mainFrame.Size = UDim2.new(0, 520, 0, 640)
    mainFrame.Position = UDim2.new(0.5, -260, 0.5, -320)
    mainFrame.BackgroundColor3 = Color3.fromRGB(20, 22, 30)
    mainFrame.BackgroundTransparency = 0.25
    mainFrame.BorderSizePixel = 0
    mainFrame.Parent = screenGui

    -- Glass border (inner glow)
    local border = Instance.new("Frame")
    border.Size = UDim2.new(1, 0, 1, 0)
    border.BackgroundTransparency = 1
    border.BorderSizePixel = 2
    border.BorderColor3 = Color3.fromRGB(80, 180, 255)
    border.BackgroundColor3 = Color3.new(1,1,1)
    border.Parent = mainFrame
    local borderCorner = Instance.new("UICorner", border)
    borderCorner.CornerRadius = UDim.new(0, 16)

    local corner = Instance.new("UICorner", mainFrame)
    corner.CornerRadius = UDim.new(0, 16)

    -- Shadow (use a separate frame)
    local shadow = Instance.new("ImageLabel")
    shadow.Size = UDim2.new(1, 20, 1, 20)
    shadow.Position = UDim2.new(-0.02, 0, -0.02, 0)
    shadow.BackgroundTransparency = 1
    shadow.Image = "rbxassetid://1316045299" -- shadow asset
    shadow.ImageTransparency = 0.5
    shadow.Parent = mainFrame

    -- Title bar with drag handle
    local titleBar = Instance.new("Frame")
    titleBar.Size = UDim2.new(1, 0, 0, 40)
    titleBar.BackgroundColor3 = Color3.fromRGB(30, 32, 45)
    titleBar.BackgroundTransparency = 0.3
    titleBar.BorderSizePixel = 0
    titleBar.Parent = mainFrame
    local titleCorner = Instance.new("UICorner", titleBar)
    titleCorner.CornerRadius = UDim.new(0, 16)

    local titleLabel = Instance.new("TextLabel")
    titleLabel.Size = UDim2.new(1, -80, 1, 0)
    titleLabel.Position = UDim2.new(0, 20, 0, 0)
    titleLabel.BackgroundTransparency = 1
    titleLabel.Text = title .. " " .. version
    titleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    titleLabel.TextScaled = true
    titleLabel.Font = Enum.Font.GothamBold
    titleLabel.TextXAlignment = Enum.TextXAlignment.Left
    titleLabel.Parent = titleBar

    -- Close button (with animation)
    local closeBtn = Instance.new("TextButton")
    closeBtn.Size = UDim2.new(0, 32, 0, 32)
    closeBtn.Position = UDim2.new(1, -40, 0, 4)
    closeBtn.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
    closeBtn.Text = "✕"
    closeBtn.TextColor3 = Color3.fromRGB(255,255,255)
    closeBtn.TextScaled = true
    closeBtn.Font = Enum.Font.GothamBold
    closeBtn.BorderSizePixel = 0
    closeBtn.Parent = titleBar
    local closeCorner = Instance.new("UICorner", closeBtn)
    closeCorner.CornerRadius = UDim.new(0, 8)
    closeBtn.MouseButton1Click:Connect(function()
        screenGui.Enabled = not screenGui.Enabled
        blur.Size = screenGui.Enabled and 0 or 24
    end)

    -- Dragging logic (works on mobile too)
    local dragging, dragInput, dragStart, startPos
    titleBar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = mainFrame.Position
        end
    end)
    titleBar.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = false
        end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            local delta = input.Position - dragStart
            mainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)

    -- Responsive scaling
    local scale = Instance.new("UIScale")
    scale.Parent = mainFrame
    -- Auto-scale based on screen size (keep it proportional)
    local function updateScale()
        local screenSize = game:GetService("GuiService").AbsoluteSize
        local desiredWidth = 520
        local desiredHeight = 640
        local scaleX = screenSize.X / desiredWidth
        local scaleY = screenSize.Y / desiredHeight
        local s = math.min(scaleX, scaleY, 1.2) -- cap at 1.2x
        scale.Scale = s
    end
    updateScale()
    game:GetService("GuiService").ScreenSizeChanged:Connect(updateScale)

    -- Tab bar (PC: top, Mobile: bottom)
    local isMobile = UserInputService.TouchEnabled
    local tabBar = Instance.new("Frame")
    if isMobile then
        tabBar.Size = UDim2.new(1, 0, 0, 50)
        tabBar.Position = UDim2.new(0, 0, 1, -50)
    else
        tabBar.Size = UDim2.new(1, 0, 0, 36)
        tabBar.Position = UDim2.new(0, 0, 0, 40)
    end
    tabBar.BackgroundTransparency = 0.2
    tabBar.BackgroundColor3 = Color3.fromRGB(15, 17, 25)
    tabBar.BorderSizePixel = 0
    tabBar.Parent = mainFrame
    local tabCorner = Instance.new("UICorner", tabBar)
    tabCorner.CornerRadius = UDim.new(0, isMobile and 16 or 0)

    -- Content container
    local content = Instance.new("Frame")
    if isMobile then
        content.Size = UDim2.new(1, -10, 1, -100)
        content.Position = UDim2.new(0, 5, 0, 50)
    else
        content.Size = UDim2.new(1, -10, 1, -80)
        content.Position = UDim2.new(0, 5, 0, 80)
    end
    content.BackgroundTransparency = 1
    content.Parent = mainFrame

    -- Status bar (like your screenshot)
    local statusBar = Instance.new("Frame")
    statusBar.Size = UDim2.new(1, 0, 0, 30)
    statusBar.Position = UDim2.new(0, 0, 0, isMobile and 50 or 40)
    statusBar.BackgroundColor3 = Color3.fromRGB(10, 12, 20)
    statusBar.BackgroundTransparency = 0.4
    statusBar.BorderSizePixel = 0
    statusBar.Parent = mainFrame
    local statusCorner = Instance.new("UICorner", statusBar)
    statusCorner.CornerRadius = UDim.new(0, 8)

    local statusLabel = Instance.new("TextLabel")
    statusLabel.Size = UDim2.new(1, -10, 1, 0)
    statusLabel.Position = UDim2.new(0, 5, 0, 0)
    statusLabel.BackgroundTransparency = 1
    statusLabel.Text = "💰 321.74K  |  🪣 Shovel  |  🌱 Bamboo Seed  |  🫐 Blueberry 1.45kg"
    statusLabel.TextColor3 = Color3.fromRGB(200, 210, 255)
    statusLabel.TextScaled = true
    statusLabel.Font = Enum.Font.Gotham
    statusLabel.TextXAlignment = Enum.TextXAlignment.Left
    statusLabel.Parent = statusBar

    -- Store references
    local self = {
        ScreenGui = screenGui,
        MainFrame = mainFrame,
        Content = content,
        TabBar = tabBar,
        TitleBar = titleBar,
        StatusBar = statusBar,
        StatusLabel = statusLabel,
        Tabs = {},
        CurrentTab = nil,
        Controls = {},
        IsMobile = isMobile
    }

    -- Create a tab
    function self:CreateTab(name)
        local btn = Instance.new("TextButton")
        if isMobile then
            btn.Size = UDim2.new(1 / 7, 0, 1, 0) -- 7 tabs max
        else
            btn.Size = UDim2.new(0, 70, 1, 0)
        end
        btn.BackgroundTransparency = 1
        btn.Text = name
        btn.TextColor3 = Color3.fromRGB(180, 180, 200)
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
        tabFrame.ScrollBarImageColor3 = Color3.fromRGB(100, 100, 140)

        local layout = Instance.new("UIListLayout")
        layout.Parent = tabFrame
        layout.SortOrder = Enum.SortOrder.LayoutOrder
        layout.Padding = UDim.new(0, 6)

        local padding = Instance.new("UIPadding")
        padding.Parent = tabFrame
        padding.PaddingTop = UDim.new(0, 6)
        padding.PaddingBottom = UDim.new(0, 6)

        -- Click to switch (with animation)
        btn.MouseButton1Click:Connect(function()
            for _, v in pairs(content:GetChildren()) do
                if v:IsA("ScrollingFrame") then
                    v.Visible = false
                end
            end
            tabFrame.Visible = true
            self.CurrentTab = name
            for _, b in pairs(tabBar:GetChildren()) do
                if b:IsA("TextButton") then
                    b.TextColor3 = Color3.fromRGB(180, 180, 200)
                end
            end
            btn.TextColor3 = Color3.fromRGB(100, 220, 255)
            -- animate content fade
            tabFrame.BackgroundTransparency = 1
            TweenService:Create(tabFrame, TweenInfo.new(0.3), {BackgroundTransparency = 0}):Play()
        end)

        if not self.CurrentTab then
            tabFrame.Visible = true
            self.CurrentTab = name
            btn.TextColor3 = Color3.fromRGB(100, 220, 255)
        end

        self.Tabs[name] = {Button = btn, Frame = tabFrame, Layout = layout}
        return tabFrame
    end

    -- Helper: section header (with accent line)
    function self:CreateHeader(parent, text)
        local frame = Instance.new("Frame")
        frame.Size = UDim2.new(1, -10, 0, 28)
        frame.BackgroundTransparency = 1
        frame.Parent = parent

        local line = Instance.new("Frame")
        line.Size = UDim2.new(0, 4, 1, -6)
        line.Position = UDim2.new(0, 0, 0, 3)
        line.BackgroundColor3 = Color3.fromRGB(80, 200, 255)
        line.BorderSizePixel = 0
        line.Parent = frame
        local lineCorner = Instance.new("UICorner", line)
        lineCorner.CornerRadius = UDim.new(0, 2)

        local lbl = Instance.new("TextLabel")
        lbl.Size = UDim2.new(1, -12, 1, 0)
        lbl.Position = UDim2.new(0, 10, 0, 0)
        lbl.BackgroundTransparency = 1
        lbl.Text = text
        lbl.TextColor3 = Color3.fromRGB(200, 210, 240)
        lbl.TextScaled = true
        lbl.Font = Enum.Font.GothamBold
        lbl.TextXAlignment = Enum.TextXAlignment.Left
        lbl.Parent = frame
        return frame
    end

    -- Control row with hover animation
    function self:CreateControlRow(parent, labelText, control)
        local row = Instance.new("Frame")
        row.Size = UDim2.new(1, -10, 0, 34)
        row.BackgroundTransparency = 1
        row.Parent = parent

        -- hover highlight
        local hover = Instance.new("Frame")
        hover.Size = UDim2.new(1, 0, 1, 0)
        hover.BackgroundColor3 = Color3.fromRGB(60, 70, 100)
        hover.BackgroundTransparency = 0.8
        hover.BorderSizePixel = 0
        hover.Parent = row
        local hoverCorner = Instance.new("UICorner", hover)
        hoverCorner.CornerRadius = UDim.new(0, 8)
        hover.Visible = false

        row.MouseEnter:Connect(function() hover.Visible = true end)
        row.MouseLeave:Connect(function() hover.Visible = false end)

        local lbl = Instance.new("TextLabel")
        lbl.Size = UDim2.new(0.5, -5, 1, 0)
        lbl.Position = UDim2.new(0, 5, 0, 0)
        lbl.BackgroundTransparency = 1
        lbl.Text = labelText
        lbl.TextColor3 = Color3.fromRGB(220, 220, 235)
        lbl.TextScaled = true
        lbl.Font = Enum.Font.Gotham
        lbl.TextXAlignment = Enum.TextXAlignment.Left
        lbl.Parent = row

        control.Position = UDim2.new(0.5, 5, 0, 2)
        control.Size = UDim2.new(0.5, -10, 1, -4)
        control.Parent = row

        return row
    end

    -- Toggle (slider style)
    function self:CreateToggle(parent, label, default, callback)
        local toggle = Instance.new("Frame")
        toggle.BackgroundColor3 = default and Color3.fromRGB(60, 200, 120) or Color3.fromRGB(80, 80, 100)
        toggle.BorderSizePixel = 0
        local corner = Instance.new("UICorner", toggle)
        corner.CornerRadius = UDim.new(0, 12)

        local thumb = Instance.new("Frame")
        thumb.Size = UDim2.new(0.4, -4, 1, -4)
        thumb.Position = UDim2.new(default and 0.6 or 0, 2, 0, 2)
        thumb.BackgroundColor3 = Color3.fromRGB(255,255,255)
        thumb.BorderSizePixel = 0
        thumb.Parent = toggle
        local thumbCorner = Instance.new("UICorner", thumb)
        thumbCorner.CornerRadius = UDim.new(0, 10)

        local state = default
        toggle.MouseButton1Click:Connect(function()
            state = not state
            local targetPos = state and 0.6 or 0
            local targetColor = state and Color3.fromRGB(60, 200, 120) or Color3.fromRGB(80, 80, 100)
            TweenService:Create(thumb, TweenInfo.new(0.2), {Position = UDim2.new(targetPos, 2, 0, 2)}):Play()
            TweenService:Create(toggle, TweenInfo.new(0.2), {BackgroundColor3 = targetColor}):Play()
            if callback then callback(state) end
        end)

        self:CreateControlRow(parent, label, toggle)
        table.insert(self.Controls, {Type = "Toggle", Object = toggle, Label = label, Get = function() return state end, Set = function(v)
            state = v
            thumb.Position = UDim2.new(v and 0.6 or 0, 2, 0, 2)
            toggle.BackgroundColor3 = v and Color3.fromRGB(60, 200, 120) or Color3.fromRGB(80, 80, 100)
        end})
        return toggle
    end

    -- Slider (animated)
    function self:CreateSlider(parent, label, min, max, default, callback)
        local sliderFrame = Instance.new("Frame")
        sliderFrame.Size = UDim2.new(1, 0, 1, 0)
        sliderFrame.BackgroundTransparency = 1

        local valueLabel = Instance.new("TextLabel")
        valueLabel.Size = UDim2.new(0.2, 0, 1, 0)
        valueLabel.Position = UDim2.new(0.8, 0, 0, 0)
        valueLabel.BackgroundTransparency = 1
        valueLabel.Text = tostring(default)
        valueLabel.TextColor3 = Color3.fromRGB(200, 230, 255)
        valueLabel.TextScaled = true
        valueLabel.Font = Enum.Font.Gotham
        valueLabel.Parent = sliderFrame

        local slider = Instance.new("Frame")
        slider.Size = UDim2.new(0.7, 0, 0.35, 0)
        slider.Position = UDim2.new(0, 0, 0.3, 0)
        slider.BackgroundColor3 = Color3.fromRGB(50, 55, 75)
        slider.BorderSizePixel = 0
        slider.Parent = sliderFrame
        local sliderCorner = Instance.new("UICorner", slider)
        sliderCorner.CornerRadius = UDim.new(0, 4)

        local fill = Instance.new("Frame")
        fill.Size = UDim2.new((default - min) / (max - min), 0, 1, 0)
        fill.BackgroundColor3 = Color3.fromRGB(80, 200, 255)
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
            if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                dragging = true
                update(input.Position)
            end
        end)
        UserInputService.InputChanged:Connect(function(input)
            if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
                update(input.Position)
            end
        end)
        UserInputService.InputEnded:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
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

    -- Dropdown (with popup, not implemented for brevity – you can keep simple cycle)
    function self:CreateDropdown(parent, label, options, defaultIndex, callback)
        -- Same as before, but with styling
        local drop = Instance.new("TextButton")
        drop.BackgroundColor3 = Color3.fromRGB(45, 50, 70)
        drop.Text = options[defaultIndex] or options[1]
        drop.TextColor3 = Color3.fromRGB(255,255,255)
        drop.TextScaled = true
        drop.Font = Enum.Font.Gotham
        drop.BorderSizePixel = 0
        local corner = Instance.new("UICorner", drop)
        corner.CornerRadius = UDim.new(0, 6)

        local selectedIndex = defaultIndex or 1
        drop.MouseButton1Click:Connect(function()
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

    -- Input
    function self:CreateInput(parent, label, placeholder, callback)
        local box = Instance.new("TextBox")
        box.BackgroundColor3 = Color3.fromRGB(40, 44, 60)
        box.Text = ""
        box.PlaceholderText = placeholder
        box.TextColor3 = Color3.fromRGB(255,255,255)
        box.TextScaled = true
        box.Font = Enum.Font.Gotham
        box.BorderSizePixel = 0
        local corner = Instance.new("UICorner", box)
        corner.CornerRadius = UDim.new(0, 6)

        box.FocusLost:Connect(function(enter)
            if enter and callback then callback(box.Text) end
        end)

        self:CreateControlRow(parent, label, box)
        table.insert(self.Controls, {Type = "Input", Object = box, Label = label, Get = function() return box.Text end, Set = function(v) box.Text = v end})
        return box
    end

    -- Button (with pulse animation)
    function self:CreateButton(parent, label, callback)
        local btn = Instance.new("TextButton")
        btn.Size = UDim2.new(0.7, 0, 0, 34)
        btn.Position = UDim2.new(0.15, 0, 0, 0)
        btn.BackgroundColor3 = Color3.fromRGB(60, 70, 160)
        btn.Text = label
        btn.TextColor3 = Color3.fromRGB(255,255,255)
        btn.TextScaled = true
        btn.Font = Enum.Font.GothamBold
        btn.BorderSizePixel = 0
        local corner = Instance.new("UICorner", btn)
        corner.CornerRadius = UDim.new(0, 8)

        btn.MouseButton1Click:Connect(function()
            TweenService:Create(btn, TweenInfo.new(0.1), {BackgroundColor3 = Color3.fromRGB(100, 130, 255)}):Play()
            task.wait(0.1)
            TweenService:Create(btn, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(60, 70, 160)}):Play()
            if callback then callback() end
        end)

        btn.Parent = parent
        return btn
    end

    -- Keybind (same as before but with better styling)
    function self:CreateKeybind(parent, label, defaultKey, callback)
        local btn = Instance.new("TextButton")
        btn.Size = UDim2.new(0.4, 0, 1, 0)
        btn.Position = UDim2.new(0.6, 0, 0, 0)
        btn.BackgroundColor3 = Color3.fromRGB(45, 50, 70)
        btn.Text = "Set Key"
        btn.TextColor3 = Color3.fromRGB(255,255,255)
        btn.TextScaled = true
        btn.Font = Enum.Font.Gotham
        btn.BorderSizePixel = 0
        local corner = Instance.new("UICorner", btn)
        corner.CornerRadius = UDim.new(0, 6)

        local key = defaultKey
        local listening = false

        btn.MouseButton1Click:Connect(function()
            listening = not listening
            btn.Text = listening and "Press any key..." or "Set Key"
            if not listening and callback then callback(key) end
        end)

        UserInputService.InputBegan:Connect(function(input, processed)
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

    -- Method to update status bar text
    function self:UpdateStatus(text)
        self.StatusLabel.Text = text
    end

    return self
end

-- =================== Keep existing config save/load ========================
-- (Copy the SaveConfig/LoadConfig functions from the previous script, they remain unchanged)
-- ... (include them here, or they can stay as is)