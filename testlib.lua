--[[
    CLANK UI Library
    A sleek, dark-themed UI library for Roblox scripts
]]

local CLANKLib = {}
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local CoreGui = game:GetService("CoreGui")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

-- Constants and Theme
local Themes = {
    Default = {
        BACKGROUND_COLOR = Color3.fromRGB(13, 13, 13),
        SIDEBAR_COLOR = Color3.fromRGB(18, 18, 18),
        ACCENT_COLOR = Color3.fromRGB(0, 255, 255),
        TEXT_COLOR = Color3.fromRGB(255, 255, 255),
        SECONDARY_COLOR = Color3.fromRGB(30, 30, 30),
        TERTIARY_COLOR = Color3.fromRGB(40, 40, 40),
        TOGGLE_OFF_COLOR = Color3.fromRGB(60, 60, 60),
        TOGGLE_ON_COLOR = Color3.fromRGB(0, 200, 200)
    },
    Dark = {
        BACKGROUND_COLOR = Color3.fromRGB(10, 10, 10),
        SIDEBAR_COLOR = Color3.fromRGB(15, 15, 15),
        ACCENT_COLOR = Color3.fromRGB(0, 200, 200),
        TEXT_COLOR = Color3.fromRGB(240, 240, 240),
        SECONDARY_COLOR = Color3.fromRGB(25, 25, 25),
        TERTIARY_COLOR = Color3.fromRGB(35, 35, 35),
        TOGGLE_OFF_COLOR = Color3.fromRGB(50, 50, 50),
        TOGGLE_ON_COLOR = Color3.fromRGB(0, 180, 180)
    },
    Light = {
        BACKGROUND_COLOR = Color3.fromRGB(240, 240, 240),
        SIDEBAR_COLOR = Color3.fromRGB(220, 220, 220),
        ACCENT_COLOR = Color3.fromRGB(0, 150, 150),
        TEXT_COLOR = Color3.fromRGB(30, 30, 30),
        SECONDARY_COLOR = Color3.fromRGB(200, 200, 200),
        TERTIARY_COLOR = Color3.fromRGB(180, 180, 180),
        TOGGLE_OFF_COLOR = Color3.fromRGB(150, 150, 150),
        TOGGLE_ON_COLOR = Color3.fromRGB(0, 180, 180)
    }
}

-- Current theme (default)
local CurrentTheme = Themes.Default

-- Utility Functions
local function CreateInstance(className, properties)
    local instance = Instance.new(className)
    for k, v in pairs(properties or {}) do
        instance[k] = v
    end
    return instance
end

local function Tween(instance, properties, duration, easingStyle, easingDirection)
    local tween = TweenService:Create(
        instance,
        TweenInfo.new(duration or 0.3, easingStyle or Enum.EasingStyle.Quad, easingDirection or Enum.EasingDirection.Out),
        properties
    )
    tween:Play()
    return tween
end

local function MakeDraggable(frame, dragArea)
    local dragging, dragInput, dragStart, startPos
    
    local function Update(input)
        local delta = input.Position - dragStart
        frame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end
    
    dragArea.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            dragStart = input.Position
            startPos = frame.Position
            
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                end
            end)
        end
    end)
    
    dragArea.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement then
            dragInput = input
        end
    end)
    
    UserInputService.InputChanged:Connect(function(input)
        if input == dragInput and dragging then
            Update(input)
        end
    end)
end

-- Apply theme to UI elements
local function ApplyTheme(theme, ui)
    if not ui then return end
    
    -- Main elements
    if ui.MainFrame then
        ui.MainFrame.BackgroundColor3 = theme.BACKGROUND_COLOR
    end
    
    if ui.SidebarFrame then
        ui.SidebarFrame.BackgroundColor3 = theme.SIDEBAR_COLOR
        ui.SidebarFixer.BackgroundColor3 = theme.SIDEBAR_COLOR
    end
    
    -- Text elements
    if ui.TitleLabel then
        ui.TitleLabel.TextColor3 = theme.TEXT_COLOR
    end
    
    if ui.SubtitleLabel then
        ui.SubtitleLabel.TextColor3 = Color3.fromRGB(150, 150, 150)
    end
    
    if ui.CurrentTabLabel then
        ui.CurrentTabLabel.TextColor3 = theme.TEXT_COLOR
    end
    
    if ui.CloseButton then
        ui.CloseButton.TextColor3 = theme.TEXT_COLOR
    end
    
    -- Update all tabs and their content
    if ui.Tabs then
        for _, tab in pairs(ui.Tabs) do
            -- Update tab content elements
            if tab.Content then
                for _, child in pairs(tab.Content:GetDescendants()) do
                    if child:IsA("Frame") and child.Name:find("Section") then
                        child.BackgroundColor3 = theme.SECONDARY_COLOR
                    elseif child:IsA("TextLabel") or child:IsA("TextButton") then
                        child.TextColor3 = theme.TEXT_COLOR
                    elseif child:IsA("Frame") and child.Name:find("Button") then
                        child.BackgroundColor3 = theme.TERTIARY_COLOR
                    elseif child:IsA("Frame") and child.Name:find("Toggle") then
                        -- Only update if it's the toggle background, not the circle
                        if child.Name == "ToggleButton" then
                            -- Check if toggle is on or off
                            local isOn = child.ToggleCircle.Position.X.Scale > 0.5 or child.ToggleCircle.Position.X.Offset > 10
                            child.BackgroundColor3 = isOn and theme.TOGGLE_ON_COLOR or theme.TOGGLE_OFF_COLOR
                        end
                    elseif child:IsA("Frame") and child.Name:find("Slider") then
                        if child.Name == "SliderBackground" then
                            child.BackgroundColor3 = theme.TERTIARY_COLOR
                        elseif child.Name == "SliderFill" then
                            child.BackgroundColor3 = theme.ACCENT_COLOR
                        end
                    elseif child:IsA("Frame") and child.Name:find("Dropdown") then
                        if child.Name == "DropdownButton" or child.Name == "DropdownContent" then
                            child.BackgroundColor3 = theme.TERTIARY_COLOR
                        end
                    end
                end
            end
        end
    end
end

-- Create Main UI
function CLANKLib:CreateWindow(title)
    -- Check if UI already exists and remove it
    if CoreGui:FindFirstChild("CLANKLibUI") then
        CoreGui:FindFirstChild("CLANKLibUI"):Destroy()
    end
    
    -- Main UI Components
    local CLANKLibUI = CreateInstance("ScreenGui", {
        Name = "CLANKLibUI",
        Parent = CoreGui,
        ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
        ResetOnSpawn = false
    })
    
    local MainFrame = CreateInstance("Frame", {
        Name = "MainFrame",
        Parent = CLANKLibUI,
        BackgroundColor3 = CurrentTheme.BACKGROUND_COLOR,
        BorderSizePixel = 0,
        Position = UDim2.new(0.5, -400, 0.5, -250),
        Size = UDim2.new(0, 800, 0, 500),
        ClipsDescendants = true
    })
    
    local UICorner = CreateInstance("UICorner", {
        Parent = MainFrame,
        CornerRadius = UDim.new(0, 8)
    })
    
    local SidebarFrame = CreateInstance("Frame", {
        Name = "SidebarFrame",
        Parent = MainFrame,
        BackgroundColor3 = CurrentTheme.SIDEBAR_COLOR,
        BorderSizePixel = 0,
        Position = UDim2.new(0, 0, 0, 0),
        Size = UDim2.new(0, 200, 1, 0)
    })
    
    local UICornerSidebar = CreateInstance("UICorner", {
        Parent = SidebarFrame,
        CornerRadius = UDim.new(0, 8)
    })
    
    local SidebarFixer = CreateInstance("Frame", {
        Name = "SidebarFixer",
        Parent = SidebarFrame,
        BackgroundColor3 = CurrentTheme.SIDEBAR_COLOR,
        BorderSizePixel = 0,
        Position = UDim2.new(1, -10, 0, 0),
        Size = UDim2.new(0, 10, 1, 0)
    })
    
    local TitleLabel = CreateInstance("TextLabel", {
        Name = "TitleLabel",
        Parent = SidebarFrame,
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 10, 0, 10),
        Size = UDim2.new(1, -20, 0, 30),
        Font = Enum.Font.GothamBold,
        Text = title or "CLANK Scripts",
        TextColor3 = CurrentTheme.TEXT_COLOR,
        TextSize = 18,
        TextXAlignment = Enum.TextXAlignment.Left
    })
    
    local SubtitleLabel = CreateInstance("TextLabel", {
        Name = "SubtitleLabel",
        Parent = SidebarFrame,
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 10, 0, 35),
        Size = UDim2.new(1, -20, 0, 20),
        Font = Enum.Font.Gotham,
        Text = "Create & Execute",
        TextColor3 = Color3.fromRGB(150, 150, 150),
        TextSize = 12,
        TextXAlignment = Enum.TextXAlignment.Left
    })
    
    local TabsContainer = CreateInstance("ScrollingFrame", {
        Name = "TabsContainer",
        Parent = SidebarFrame,
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 0, 0, 70),
        Size = UDim2.new(1, 0, 1, -130),
        CanvasSize = UDim2.new(0, 0, 0, 0),
        ScrollBarThickness = 0,
        ScrollingDirection = Enum.ScrollingDirection.Y,
        AutomaticCanvasSize = Enum.AutomaticSize.Y
    })
    
    local TabsLayout = CreateInstance("UIListLayout", {
        Parent = TabsContainer,
        Padding = UDim.new(0, 5),
        SortOrder = Enum.SortOrder.LayoutOrder,
        HorizontalAlignment = Enum.HorizontalAlignment.Center
    })
    
    local UserInfoFrame = CreateInstance("Frame", {
        Name = "UserInfoFrame",
        Parent = SidebarFrame,
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 0, 1, -60),
        Size = UDim2.new(1, 0, 0, 60),
        BorderSizePixel = 0
    })
    
    local UserAvatar = CreateInstance("ImageLabel", {
        Name = "UserAvatar",
        Parent = UserInfoFrame,
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 15, 0.5, -15),
        Size = UDim2.new(0, 30, 0, 30),
        Image = "rbxasset://textures/ui/GuiImagePlaceholder.png"
    })
    
    local UICornerAvatar = CreateInstance("UICorner", {
        Parent = UserAvatar,
        CornerRadius = UDim.new(1, 0)
    })
    
    local UserNameLabel = CreateInstance("TextLabel", {
        Name = "UserNameLabel",
        Parent = UserInfoFrame,
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 55, 0.5, -15),
        Size = UDim2.new(1, -70, 0, 30),
        Font = Enum.Font.GothamSemibold,
        Text = LocalPlayer.Name,
        TextColor3 = CurrentTheme.TEXT_COLOR,
        TextSize = 14,
        TextXAlignment = Enum.TextXAlignment.Left
    })
    
    local ContentContainer = CreateInstance("Frame", {
        Name = "ContentContainer",
        Parent = MainFrame,
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 200, 0, 0),
        Size = UDim2.new(1, -200, 1, 0)
    })
    
    local TopBar = CreateInstance("Frame", {
        Name = "TopBar",
        Parent = ContentContainer,
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 0, 0, 0),
        Size = UDim2.new(1, 0, 0, 50)
    })
    
    local CurrentTabLabel = CreateInstance("TextLabel", {
        Name = "CurrentTabLabel",
        Parent = TopBar,
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 20, 0, 10),
        Size = UDim2.new(0, 200, 0, 30),
        Font = Enum.Font.GothamBold,
        Text = "Main",
        TextColor3 = CurrentTheme.TEXT_COLOR,
        TextSize = 18,
        TextXAlignment = Enum.TextXAlignment.Left
    })
    
    local CloseButton = CreateInstance("TextButton", {
        Name = "CloseButton",
        Parent = TopBar,
        BackgroundTransparency = 1,
        Position = UDim2.new(1, -40, 0, 10),
        Size = UDim2.new(0, 30, 0, 30),
        Font = Enum.Font.GothamBold,
        Text = "+",
        TextColor3 = CurrentTheme.TEXT_COLOR,
        TextSize = 24,
        Rotation = 45
    })
    
    CloseButton.MouseButton1Click:Connect(function()
        CLANKLibUI:Destroy()
    end)
    
    -- Make the entire top bar draggable (including title label)
    MakeDraggable(MainFrame, TopBar)
    MakeDraggable(MainFrame, TitleLabel)
    
    -- Set up avatar image
    pcall(function()
        local userId = LocalPlayer.UserId
        local thumbType = Enum.ThumbnailType.HeadShot
        local thumbSize = Enum.ThumbnailSize.Size420x420
        local content = Players:GetUserThumbnailAsync(userId, thumbType, thumbSize)
        UserAvatar.Image = content
    end)
    
    -- UI elements reference for theme application
    local UIElements = {
        MainFrame = MainFrame,
        SidebarFrame = SidebarFrame,
        SidebarFixer = SidebarFixer,
        TitleLabel = TitleLabel,
        SubtitleLabel = SubtitleLabel,
        CurrentTabLabel = CurrentTabLabel,
        CloseButton = CloseButton,
        Tabs = {}
    }
    
    -- Library object
    local Window = {}
    Window.Tabs = {}
    Window.CurrentTab = nil
    Window.UIElements = UIElements
    
    -- Function to set theme
    function Window:SetTheme(themeName)
        if Themes[themeName] then
            CurrentTheme = Themes[themeName]
            ApplyTheme(CurrentTheme, self.UIElements)
        end
    end
    
    -- Function to create a new tab
    function Window:CreateTab(tabName, icon)
        -- Create tab button
        local TabButton = CreateInstance("TextButton", {
            Name = tabName .. "Tab",
            Parent = TabsContainer,
            BackgroundTransparency = 1,
            Size = UDim2.new(0.9, 0, 0, 36),
            Font = Enum.Font.Gotham,
            Text = "",
            TextColor3 = CurrentTheme.TEXT_COLOR,
            TextSize = 14,
            AutoButtonColor = false
        })
        
        local TabIcon = CreateInstance("ImageLabel", {
            Name = "TabIcon",
            Parent = TabButton,
            BackgroundTransparency = 1,
            Position = UDim2.new(0, 15, 0.5, -8),
            Size = UDim2.new(0, 16, 0, 16),
            Image = icon or "rbxassetid://7733715400", -- Default icon
            ImageColor3 = CurrentTheme.TEXT_COLOR
        })
        
        local TabLabel = CreateInstance("TextLabel", {
            Name = "TabLabel",
            Parent = TabButton,
            BackgroundTransparency = 1,
            Position = UDim2.new(0, 40, 0, 0),
            Size = UDim2.new(1, -50, 1, 0),
            Font = Enum.Font.Gotham,
            Text = tabName,
            TextColor3 = CurrentTheme.TEXT_COLOR,
            TextSize = 14,
            TextXAlignment = Enum.TextXAlignment.Left
        })
        
        -- Create tab content
        local TabContent = CreateInstance("ScrollingFrame", {
            Name = tabName .. "Content",
            Parent = ContentContainer,
            BackgroundTransparency = 1,
            Position = UDim2.new(0, 0, 0, 50),
            Size = UDim2.new(1, 0, 1, -50),
            CanvasSize = UDim2.new(0, 0, 0, 0),
            ScrollBarThickness = 4,
            ScrollingDirection = Enum.ScrollingDirection.Y,
            Visible = false,
            AutomaticCanvasSize = Enum.AutomaticSize.Y,
            BottomImage = "rbxassetid://6889812791",
            MidImage = "rbxassetid://6889812721",
            TopImage = "rbxassetid://6889812642",
            ScrollBarImageColor3 = CurrentTheme.ACCENT_COLOR
        })
        
        local ContentPadding = CreateInstance("UIPadding", {
            Parent = TabContent,
            PaddingLeft = UDim.new(0, 20),
            PaddingRight = UDim.new(0, 20),
            PaddingTop = UDim.new(0, 10),
            PaddingBottom = UDim.new(0, 10)
        })
        
        local ContentLayout = CreateInstance("UIListLayout", {
            Parent = TabContent,
            Padding = UDim.new(0, 10),
            SortOrder = Enum.SortOrder.LayoutOrder,
            HorizontalAlignment = Enum.HorizontalAlignment.Center
        })
        
        -- Tab object
        local Tab = {}
        Tab.Name = tabName
        Tab.Content = TabContent
        
        -- Function to select this tab
        function Tab:Select()
            -- Update UI
            for _, otherTab in pairs(Window.Tabs) do
                otherTab.Content.Visible = false
            end
            
            TabContent.Visible = true
            CurrentTabLabel.Text = tabName
            Window.CurrentTab = Tab
        end
        
        -- Tab button click handler
        TabButton.MouseButton1Click:Connect(function()
            Tab:Select()
        end)
        
        -- Section creator function
        function Tab:CreateSection(sectionName)
            local SectionFrame = CreateInstance("Frame", {
                Name = sectionName .. "Section",
                Parent = TabContent,
                BackgroundColor3 = CurrentTheme.SECONDARY_COLOR,
                BorderSizePixel = 0,
                Size = UDim2.new(1, 0, 0, 36),
                AutomaticSize = Enum.AutomaticSize.Y
            })
            
            local UICornerSection = CreateInstance("UICorner", {
                Parent = SectionFrame,
                CornerRadius = UDim.new(0, 6)
            })
            
            local SectionLabel = CreateInstance("TextLabel", {
                Name = "SectionLabel",
                Parent = SectionFrame,
                BackgroundTransparency = 1,
                Position = UDim2.new(0, 10, 0, 0),
                Size = UDim2.new(1, -20, 0, 36),
                Font = Enum.Font.GothamSemibold,
                Text = sectionName,
                TextColor3 = CurrentTheme.TEXT_COLOR,
                TextSize = 14,
                TextXAlignment = Enum.TextXAlignment.Left
            })
            
            local SectionContent = CreateInstance("Frame", {
                Name = "SectionContent",
                Parent = SectionFrame,
                BackgroundTransparency = 1,
                Position = UDim2.new(0, 0, 0, 36),
                Size = UDim2.new(1, 0, 0, 0),
                AutomaticSize = Enum.AutomaticSize.Y
            })
            
            local SectionPadding = CreateInstance("UIPadding", {
                Parent = SectionContent,
                PaddingLeft = UDim.new(0, 10),
                PaddingRight = UDim.new(0, 10),
                PaddingBottom = UDim.new(0, 10)
            })
            
            local SectionLayout = CreateInstance("UIListLayout", {
                Parent = SectionContent,
                Padding = UDim.new(0, 8),
                SortOrder = Enum.SortOrder.LayoutOrder
            })
            
            -- Section object
            local Section = {}
            
            -- Toggle creator function
            function Section:CreateToggle(toggleName, defaultState, callback)
                local ToggleFrame = CreateInstance("Frame", {
                    Name = toggleName .. "Toggle",
                    Parent = SectionContent,
                    BackgroundTransparency = 1,
                    Size = UDim2.new(1, 0, 0, 30)
                })
                
                local ToggleLabel = CreateInstance("TextLabel", {
                    Name = "ToggleLabel",
                    Parent = ToggleFrame,
                    BackgroundTransparency = 1,
                    Position = UDim2.new(0, 0, 0, 0),
                    Size = UDim2.new(1, -50, 1, 0),
                    Font = Enum.Font.Gotham,
                    Text = toggleName,
                    TextColor3 = CurrentTheme.TEXT_COLOR,
                    TextSize = 14,
                    TextXAlignment = Enum.TextXAlignment.Left
                })
                
                local ToggleButton = CreateInstance("Frame", {
                    Name = "ToggleButton",
                    Parent = ToggleFrame,
                    BackgroundColor3 = defaultState and CurrentTheme.TOGGLE_ON_COLOR or CurrentTheme.TOGGLE_OFF_COLOR,
                    Position = UDim2.new(1, -40, 0.5, -10),
                    Size = UDim2.new(0, 40, 0, 20),
                    BorderSizePixel = 0
                })
                
                local UICornerToggle = CreateInstance("UICorner", {
                    Parent = ToggleButton,
                    CornerRadius = UDim.new(1, 0)
                })
                
                local ToggleCircle = CreateInstance("Frame", {
                    Name = "ToggleCircle",
                    Parent = ToggleButton,
                    BackgroundColor3 = Color3.fromRGB(255, 255, 255),
                    Position = defaultState and UDim2.new(1, -18, 0.5, -8) or UDim2.new(0, 2, 0.5, -8),
                    Size = UDim2.new(0, 16, 0, 16),
                    BorderSizePixel = 0
                })
                
                local UICornerCircle = CreateInstance("UICorner", {
                    Parent = ToggleCircle,
                    CornerRadius = UDim.new(1, 0)
                })
                
                -- Toggle state and functionality
                local Toggled = defaultState or false
                
                local function UpdateToggle()
                    Toggled = not Toggled
                    
                    if Toggled then
                        Tween(ToggleButton, {BackgroundColor3 = CurrentTheme.TOGGLE_ON_COLOR}, 0.2)
                        Tween(ToggleCircle, {Position = UDim2.new(1, -18, 0.5, -8)}, 0.2)
                    else
                        Tween(ToggleButton, {BackgroundColor3 = CurrentTheme.TOGGLE_OFF_COLOR}, 0.2)
                        Tween(ToggleCircle, {Position = UDim2.new(0, 2, 0.5, -8)}, 0.2)
                    end
                    
                    if callback then
                        callback(Toggled)
                    end
                end
                
                -- Make the entire frame clickable
                ToggleFrame.InputBegan:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.MouseButton1 then
                        UpdateToggle()
                    end
                end)
                
                -- Toggle object
                local Toggle = {}
                
                function Toggle:Set(state)
                    if state ~= Toggled then
                        UpdateToggle()
                    end
                end
                
                function Toggle:Get()
                    return Toggled
                end
                
                return Toggle
            end
            
            -- Slider creator function
            function Section:CreateSlider(sliderName, min, max, defaultValue, callback)
                local SliderFrame = CreateInstance("Frame", {
                    Name = sliderName .. "Slider",
                    Parent = SectionContent,
                    BackgroundTransparency = 1,
                    Size = UDim2.new(1, 0, 0, 50)
                })
                
                local SliderLabel = CreateInstance("TextLabel", {
                    Name = "SliderLabel",
                    Parent = SliderFrame,
                    BackgroundTransparency = 1,
                    Position = UDim2.new(0, 0, 0, 0),
                    Size = UDim2.new(1, -50, 0, 20),
                    Font = Enum.Font.Gotham,
                    Text = sliderName,
                    TextColor3 = CurrentTheme.TEXT_COLOR,
                    TextSize = 14,
                    TextXAlignment = Enum.TextXAlignment.Left
                })
                
                local ValueLabel = CreateInstance("TextLabel", {
                    Name = "ValueLabel",
                    Parent = SliderFrame,
                    BackgroundTransparency = 1,
                    Position = UDim2.new(1, -40, 0, 0),
                    Size = UDim2.new(0, 40, 0, 20),
                    Font = Enum.Font.Gotham,
                    Text = tostring(defaultValue),
                    TextColor3 = CurrentTheme.TEXT_COLOR,
                    TextSize = 14,
                    TextXAlignment = Enum.TextXAlignment.Right
                })
                
                local SliderBackground = CreateInstance("Frame", {
                    Name = "SliderBackground",
                    Parent = SliderFrame,
                    BackgroundColor3 = CurrentTheme.TERTIARY_COLOR,
                    BorderSizePixel = 0,
                    Position = UDim2.new(0, 0, 0, 25),
                    Size = UDim2.new(1, 0, 0, 6)
                })
                
                local UICornerSliderBg = CreateInstance("UICorner", {
                    Parent = SliderBackground,
                    CornerRadius = UDim.new(1, 0)
                })
                
                local SliderFill = CreateInstance("Frame", {
                    Name = "SliderFill",
                    Parent = SliderBackground,
                    BackgroundColor3 = CurrentTheme.ACCENT_COLOR,
                    BorderSizePixel = 0,
                    Size = UDim2.new((defaultValue - min) / (max - min), 0, 1, 0)
                })
                
                local UICornerSliderFill = CreateInstance("UICorner", {
                    Parent = SliderFill,
                    CornerRadius = UDim.new(1, 0)
                })
                
                local SliderButton = CreateInstance("TextButton", {
                    Name = "SliderButton",
                    Parent = SliderBackground,
                    BackgroundColor3 = Color3.fromRGB(255, 255, 255),
                    Position = UDim2.new((defaultValue - min) / (max - min), -6, 0.5, -6),
                    Size = UDim2.new(0, 12, 0, 12),
                    Text = "",
                    BorderSizePixel = 0
                })
                
                local UICornerSliderButton = CreateInstance("UICorner", {
                    Parent = SliderButton,
                    CornerRadius = UDim.new(1, 0)
                })
                
                -- Slider functionality
                local Value = defaultValue or min
                local Dragging = false
                
                local function UpdateSlider(input)
                    -- Calculate the position and value
                    local pos = math.clamp((input.Position.X - SliderBackground.AbsolutePosition.X) / SliderBackground.AbsoluteSize.X, 0, 1)
                    local value = math.floor(min + ((max - min) * pos) + 0.5)
                    Value = value
                    
                    -- Update UI
                    SliderButton.Position = UDim2.new(pos, -6, 0.5, -6)
                    SliderFill.Size = UDim2.new(pos, 0, 1, 0)
                    ValueLabel.Text = tostring(value)
                    
                    if callback then
                        callback(value)
                    end
                end
                
                -- Handle slider input
                SliderButton.InputBegan:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.MouseButton1 then
                        Dragging = true
                    end
                end)
                
                SliderButton.InputEnded:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.MouseButton1 then
                        Dragging = false
                    end
                end)
                
                SliderBackground.InputBegan:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.MouseButton1 then
                        UpdateSlider(input)
                        Dragging = true
                    end
                end)
                
                UserInputService.InputChanged:Connect(function(input)
                    if Dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
                        UpdateSlider(input)
                    end
                end)
                
                UserInputService.InputEnded:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.MouseButton1 then
                        Dragging = false
                    end
                end)
                
                -- Slider object
                local Slider = {}
                
                function Slider:Set(value)
                    value = math.clamp(value, min, max)
                    Value = value
                    
                    local pos = ((value - min) / (max - min))
                    SliderButton.Position = UDim2.new(pos, -6, 0.5, -6)
                    SliderFill.Size = UDim2.new(pos, 0, 1, 0)
                    ValueLabel.Text = tostring(value)
                    
                    if callback then
                        callback(value)
                    end
                end
                
                function Slider:Get()
                    return Value
                end
                
                return Slider
            end
            
            -- Button creator function
            function Section:CreateButton(buttonName, callback)
                local ButtonFrame = CreateInstance("Frame", {
                    Name = buttonName .. "Button",
                    Parent = SectionContent,
                    BackgroundTransparency = 1,
                    Size = UDim2.new(1, 0, 0, 30)
                })
                
                local Button = CreateInstance("TextButton", {
                    Name = "Button",
                    Parent = ButtonFrame,
                    BackgroundColor3 = CurrentTheme.TERTIARY_COLOR,
                    Size = UDim2.new(1, 0, 1, 0),
                    Font = Enum.Font.Gotham,
                    Text = buttonName,
                    TextColor3 = CurrentTheme.TEXT_COLOR,
                    TextSize = 14,
                    BorderSizePixel = 0,
                    AutoButtonColor = false
                })
                
                local UICornerButton = CreateInstance("UICorner", {
                    Parent = Button,
                    CornerRadius = UDim.new(0, 4)
                })
                
                -- Button functionality
                Button.MouseEnter:Connect(function()
                    Tween(Button, {BackgroundColor3 = Color3.fromRGB(60, 60, 60)}, 0.2)
                end)
                
                Button.MouseLeave:Connect(function()
                    Tween(Button, {BackgroundColor3 = CurrentTheme.TERTIARY_COLOR}, 0.2)
                end)
                
                Button.MouseButton1Down:Connect(function()
                    Tween(Button, {BackgroundColor3 = Color3.fromRGB(80, 80, 80)}, 0.1)
                end)
                
                Button.MouseButton1Up:Connect(function()
                    Tween(Button, {BackgroundColor3 = Color3.fromRGB(60, 60, 60)}, 0.1)
                    if callback then
                        callback()
                    end
                end)
                
                -- Button object
                local ButtonObj = {}
                
                function ButtonObj:SetText(text)
                    Button.Text = text
                end
                
                return ButtonObj
            end
            
            -- Dropdown creator function
            function Section:CreateDropdown(dropdownName, options, defaultOption, callback)
                local DropdownFrame = CreateInstance("Frame", {
                    Name = dropdownName .. "Dropdown",
                    Parent = SectionContent,
                    BackgroundTransparency = 1,
                    Size = UDim2.new(1, 0, 0, 30),
                    ClipsDescendants = true
                })
                
                local DropdownLabel = CreateInstance("TextLabel", {
                    Name = "DropdownLabel",
                    Parent = DropdownFrame,
                    BackgroundTransparency = 1,
                    Position = UDim2.new(0, 0, 0, 0),
                    Size = UDim2.new(1, 0, 0, 20),
                    Font = Enum.Font.Gotham,
                    Text = dropdownName,
                    TextColor3 = CurrentTheme.TEXT_COLOR,
                    TextSize = 14,
                    TextXAlignment = Enum.TextXAlignment.Left
                })
                
                local DropdownButton = CreateInstance("TextButton", {
                    Name = "DropdownButton",
                    Parent = DropdownFrame,
                    BackgroundColor3 = CurrentTheme.TERTIARY_COLOR,
                    Position = UDim2.new(0, 0, 0, 25),
                    Size = UDim2.new(1, 0, 0, 30),
                    Font = Enum.Font.Gotham,
                    Text = "  " .. (defaultOption or "Select..."),
                    TextColor3 = CurrentTheme.TEXT_COLOR,
                    TextSize = 14,
                    BorderSizePixel = 0,
                    TextXAlignment = Enum.TextXAlignment.Left
                })
                
                local UICornerDropdown = CreateInstance("UICorner", {
                    Parent = DropdownButton,
                    CornerRadius = UDim.new(0, 4)
                })
                
                local DropdownIcon = CreateInstance("ImageLabel", {
                    Name = "DropdownIcon",
                    Parent = DropdownButton,
                    BackgroundTransparency = 1,
                    Position = UDim2.new(1, -25, 0.5, -8),
                    Size = UDim2.new(0, 16, 0, 16),
                    Image = "rbxassetid://7072706663", -- Down arrow icon
                    ImageColor3 = CurrentTheme.TEXT_COLOR
                })
                
                local DropdownContent = CreateInstance("Frame", {
                    Name = "DropdownContent",
                    Parent = DropdownFrame,
                    BackgroundColor3 = CurrentTheme.TERTIARY_COLOR,
                    Position = UDim2.new(0, 0, 0, 60),
                    Size = UDim2.new(1, 0, 0, 0),
                    Visible = false,
                    BorderSizePixel = 0,
                    ZIndex = 5
                })
                
                local UICornerContent = CreateInstance("UICorner", {
                    Parent = DropdownContent,
                    CornerRadius = UDim.new(0, 4)
                })
                
                local ContentLayout = CreateInstance("UIListLayout", {
                    Parent = DropdownContent,
                    SortOrder = Enum.SortOrder.LayoutOrder
                })
                
                -- Dropdown functionality
                local Open = false
                local Selected = defaultOption or options[1] or "Select..."
                
                local function UpdateDropdown()
                    DropdownButton.Text = "  " .. Selected
                    
                    if Open then
                        DropdownFrame.Size = UDim2.new(1, 0, 0, 60 + DropdownContent.Size.Y.Offset)
                        DropdownContent.Visible = true
                        Tween(DropdownIcon, {Rotation = 180}, 0.2)
                    else
                        DropdownFrame.Size = UDim2.new(1, 0, 0, 60)
                        DropdownContent.Visible = false
                        Tween(DropdownIcon, {Rotation = 0}, 0.2)
                    end
                end
                
                -- Create option buttons
                for i, option in ipairs(options) do
                    local OptionButton = CreateInstance("TextButton", {
                        Name = option .. "Option",
                        Parent = DropdownContent,
                        BackgroundTransparency = 1,
                        Size = UDim2.new(1, 0, 0, 25),
                        Font = Enum.Font.Gotham,
                        Text = "  " .. option,
                        TextColor3 = CurrentTheme.TEXT_COLOR,
                        TextSize = 14,
                        TextXAlignment = Enum.TextXAlignment.Left,
                        ZIndex = 6
                    })
                    
                    OptionButton.MouseButton1Click:Connect(function()
                        Selected = option
                        Open = false
                        UpdateDropdown()
                        
                        if callback then
                            callback(option)
                        end
                    end)
                end
                
                -- Update dropdown content size
                DropdownContent.Size = UDim2.new(1, 0, 0, ContentLayout.AbsoluteContentSize.Y)
                
                -- Toggle dropdown
                DropdownButton.MouseButton1Click:Connect(function()
                    Open = not Open
                    UpdateDropdown()
                end)
                
                -- Initial update
                UpdateDropdown()
                
                -- Dropdown object
                local Dropdown = {}
                
                function Dropdown:Select(option)
                    if table.find(options, option) then
                        Selected = option
                        UpdateDropdown()
                        
                        if callback then
                            callback(option)
                        end
                    end
                end
                
                function Dropdown:GetSelected()
                    return Selected
                end
                
                return Dropdown
            end
            
            return Section
        end
        
        -- Add tab to window
        table.insert(Window.Tabs, Tab)
        table.insert(Window.UIElements.Tabs, Tab)
        
        -- Select the first tab by default
        if #Window.Tabs == 1 then
            Tab:Select()
        end
        
        return Tab
    end
    
    return Window
end

return CLANKLib
