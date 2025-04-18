local UILibrary = {}

-- Services
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local TextService = game:GetService("TextService")
local CoreGui = game:GetService("CoreGui")

-- Variables
local LocalPlayer = Players.LocalPlayer
local Mouse = LocalPlayer:GetMouse()
local ViewportSize = workspace.CurrentCamera.ViewportSize

-- Constants
local BACKGROUND_COLOR = Color3.fromRGB(20, 20, 20)
local SIDEBAR_COLOR = Color3.fromRGB(15, 15, 15)
local ACCENT_COLOR = Color3.fromRGB(114, 111, 255)
local TEXT_COLOR = Color3.fromRGB(255, 255, 255)
local SECONDARY_TEXT_COLOR = Color3.fromRGB(180, 180, 180)
local TOGGLE_COLOR = Color3.fromRGB(114, 111, 255)
local TOGGLE_OFF_COLOR = Color3.fromRGB(60, 60, 60)
local SLIDER_BACKGROUND = Color3.fromRGB(40, 40, 40)
local SLIDER_FILL = Color3.fromRGB(114, 111, 255)
local DROPDOWN_BACKGROUND = Color3.fromRGB(30, 30, 30)
local BUTTON_COLOR = Color3.fromRGB(40, 40, 40)
local BUTTON_HOVER_COLOR = Color3.fromRGB(50, 50, 50)

-- Utility Functions
local function createInstance(className, properties)
    local instance = Instance.new(className)
    for property, value in pairs(properties) do
        instance[property] = value
    end
    return instance
end

local function createTween(instance, properties, duration, easingStyle, easingDirection)
    local tweenInfo = TweenInfo.new(
        duration or 0.2,
        easingStyle or Enum.EasingStyle.Quad,
        easingDirection or Enum.EasingDirection.Out
    )
    local tween = TweenService:Create(instance, tweenInfo, properties)
    return tween
end

local function createRoundedCorner(parent, radius)
    local corner = createInstance("UICorner", {
        CornerRadius = UDim.new(0, radius or 4),
        Parent = parent
    })
    return corner
end

local function createStroke(parent, color, thickness, transparency)
    local stroke = createInstance("UIStroke", {
        Color = color or Color3.fromRGB(50, 50, 50),
        Thickness = thickness or 1,
        Transparency = transparency or 0,
        Parent = parent
    })
    return stroke
end

-- Main Library Functions
function UILibrary:CreateWindow(title)
    -- Check if a UI already exists and remove it
    if CoreGui:FindFirstChild("UILibrary") then
        CoreGui:FindFirstChild("UILibrary"):Destroy()
    end
    
    -- Create main GUI
    local UILibraryGui = createInstance("ScreenGui", {
        Name = "UILibrary",
        Parent = CoreGui,
        ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
        ResetOnSpawn = false
    })
    
    -- Create main frame
    local MainFrame = createInstance("Frame", {
        Name = "MainFrame",
        Size = UDim2.new(0, 700, 0, 500),
        Position = UDim2.new(0.5, -350, 0.5, -250),
        BackgroundColor3 = BACKGROUND_COLOR,
        BorderSizePixel = 0,
        Parent = UILibraryGui
    })
    createRoundedCorner(MainFrame, 6)
    
    -- Create shadow
    local Shadow = createInstance("ImageLabel", {
        Name = "Shadow",
        Size = UDim2.new(1, 30, 1, 30),
        Position = UDim2.new(0, -15, 0, -15),
        BackgroundTransparency = 1,
        Image = "rbxassetid://6014261993",
        ImageColor3 = Color3.fromRGB(0, 0, 0),
        ImageTransparency = 0.5,
        ScaleType = Enum.ScaleType.Slice,
        SliceCenter = Rect.new(49, 49, 450, 450),
        Parent = MainFrame,
        ZIndex = 0
    })
    
    -- Create sidebar
    local Sidebar = createInstance("Frame", {
        Name = "Sidebar",
        Size = UDim2.new(0, 150, 1, 0),
        Position = UDim2.new(0, 0, 0, 0),
        BackgroundColor3 = SIDEBAR_COLOR,
        BorderSizePixel = 0,
        Parent = MainFrame
    })
    
    -- Create sidebar corner (only round the right side)
    local SidebarCorner = createInstance("UICorner", {
        CornerRadius = UDim.new(0, 6),
        Parent = Sidebar
    })
    
    -- Create sidebar corner fix (to make only the right side rounded)
    local SidebarCornerFix = createInstance("Frame", {
        Name = "SidebarCornerFix",
        Size = UDim2.new(0, 6, 1, 0),
        Position = UDim2.new(0, 0, 0, 0),
        BackgroundColor3 = SIDEBAR_COLOR,
        BorderSizePixel = 0,
        ZIndex = 2,
        Parent = Sidebar
    })
    
    -- Create sidebar title
    local SidebarTitle = createInstance("TextLabel", {
        Name = "SidebarTitle",
        Size = UDim2.new(1, 0, 0, 50),
        Position = UDim2.new(0, 0, 0, 0),
        BackgroundTransparency = 1,
        Text = title or "UI Library",
        TextColor3 = TEXT_COLOR,
        TextSize = 18,
        Font = Enum.Font.GothamBold,
        Parent = Sidebar
    })
    
    -- Create sidebar container for tabs
    local SidebarContainer = createInstance("ScrollingFrame", {
        Name = "SidebarContainer",
        Size = UDim2.new(1, 0, 1, -50),
        Position = UDim2.new(0, 0, 0, 50),
        BackgroundTransparency = 1,
        ScrollBarThickness = 0,
        ScrollingDirection = Enum.ScrollingDirection.Y,
        AutomaticCanvasSize = Enum.AutomaticSize.Y,
        CanvasSize = UDim2.new(0, 0, 0, 0),
        Parent = Sidebar
    })
    
    local SidebarLayout = createInstance("UIListLayout", {
        Padding = UDim.new(0, 5),
        SortOrder = Enum.SortOrder.LayoutOrder,
        Parent = SidebarContainer
    })
    
    local SidebarPadding = createInstance("UIPadding", {
        PaddingLeft = UDim.new(0, 10),
        PaddingRight = UDim.new(0, 10),
        PaddingTop = UDim.new(0, 5),
        PaddingBottom = UDim.new(0, 5),
        Parent = SidebarContainer
    })
    
    -- Create content area
    local ContentArea = createInstance("Frame", {
        Name = "ContentArea",
        Size = UDim2.new(1, -150, 1, 0),
        Position = UDim2.new(0, 150, 0, 0),
        BackgroundTransparency = 1,
        Parent = MainFrame
    })
    
    -- Create top bar
    local TopBar = createInstance("Frame", {
        Name = "TopBar",
        Size = UDim2.new(1, 0, 0, 40),
        Position = UDim2.new(0, 0, 0, 0),
        BackgroundTransparency = 1,
        Parent = ContentArea
    })
    
    -- Create tab title
    local TabTitle = createInstance("TextLabel", {
        Name = "TabTitle",
        Size = UDim2.new(0, 200, 1, 0),
        Position = UDim2.new(0, 20, 0, 0),
        BackgroundTransparency = 1,
        Text = "Main",
        TextColor3 = TEXT_COLOR,
        TextSize = 16,
        Font = Enum.Font.GothamSemibold,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = TopBar
    })
    
    -- Create search bar
    local SearchFrame = createInstance("Frame", {
        Name = "SearchFrame",
        Size = UDim2.new(0, 150, 0, 30),
        Position = UDim2.new(1, -170, 0.5, -15),
        BackgroundColor3 = SIDEBAR_COLOR,
        BorderSizePixel = 0,
        Parent = TopBar
    })
    createRoundedCorner(SearchFrame, 4)
    
    local SearchLabel = createInstance("TextLabel", {
        Name = "SearchLabel",
        Size = UDim2.new(0, 50, 1, 0),
        Position = UDim2.new(0, 10, 0, 0),
        BackgroundTransparency = 1,
        Text = "Search",
        TextColor3 = SECONDARY_TEXT_COLOR,
        TextSize = 14,
        Font = Enum.Font.Gotham,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = SearchFrame
    })
    
    local SearchIcon = createInstance("ImageLabel", {
        Name = "SearchIcon",
        Size = UDim2.new(0, 16, 0, 16),
        Position = UDim2.new(1, -26, 0.5, -8),
        BackgroundTransparency = 1,
        Image = "rbxassetid://3926305904",
        ImageRectOffset = Vector2.new(964, 324),
        ImageRectSize = Vector2.new(36, 36),
        ImageColor3 = SECONDARY_TEXT_COLOR,
        Parent = SearchFrame
    })
    
    -- Create content container
    local ContentContainer = createInstance("Frame", {
        Name = "ContentContainer",
        Size = UDim2.new(1, 0, 1, -40),
        Position = UDim2.new(0, 0, 0, 40),
        BackgroundTransparency = 1,
        Parent = ContentArea
    })
    
    -- Create bottom bar
    local BottomBar = createInstance("Frame", {
        Name = "BottomBar",
        Size = UDim2.new(1, 0, 0, 30),
        Position = UDim2.new(0, 0, 1, -30),
        BackgroundTransparency = 1,
        Parent = MainFrame
    })
    
    local BottomText = createInstance("TextLabel", {
        Name = "BottomText",
        Size = UDim2.new(1, 0, 1, 0),
        BackgroundTransparency = 1,
        Text = "UI Library v1.0",
        TextColor3 = SECONDARY_TEXT_COLOR,
        TextSize = 14,
        Font = Enum.Font.Gotham,
        Parent = BottomBar
    })
    
    -- Make the UI draggable
    local isDragging = false
    local dragInput
    local dragStart
    local startPos
    
    local function updateDrag(input)
        local delta = input.Position - dragStart
        MainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end
    
    MainFrame.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            isDragging = true
            dragStart = input.Position
            startPos = MainFrame.Position
            
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    isDragging = false
                end
            end)
        end
    end)
    
    MainFrame.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement then
            dragInput = input
        end
    end)
    
    UserInputService.InputChanged:Connect(function(input)
        if input == dragInput and isDragging then
            updateDrag(input)
        end
    end)
    
    -- Tab system
    local Tabs = {}
    local SelectedTab = nil
    
    local Window = {}
    
    function Window:CreateTab(name, icon)
        -- Create tab button in sidebar
        local TabButton = createInstance("Frame", {
            Name = name .. "Tab",
            Size = UDim2.new(1, 0, 0, 30),
            BackgroundTransparency = 1,
            Parent = SidebarContainer
        })
        
        local TabButtonBackground = createInstance("Frame", {
            Name = "Background",
            Size = UDim2.new(1, 0, 1, 0),
            BackgroundColor3 = SIDEBAR_COLOR,
            BackgroundTransparency = 1,
            Parent = TabButton
        })
        createRoundedCorner(TabButtonBackground, 4)
        
        local TabButtonIcon
        if icon then
            TabButtonIcon = createInstance("ImageLabel", {
                Name = "Icon",
                Size = UDim2.new(0, 20, 0, 20),
                Position = UDim2.new(0, 5, 0.5, -10),
                BackgroundTransparency = 1,
                Image = icon,
                ImageColor3 = SECONDARY_TEXT_COLOR,
                Parent = TabButton
            })
        end
        
        local TabButtonText = createInstance("TextLabel", {
            Name = "Text",
            Size = UDim2.new(1, icon and -30 or -10, 1, 0),
            Position = UDim2.new(0, icon and 30 or 5, 0, 0),
            BackgroundTransparency = 1,
            Text = name,
            TextColor3 = SECONDARY_TEXT_COLOR,
            TextSize = 14,
            Font = Enum.Font.Gotham,
            TextXAlignment = Enum.TextXAlignment.Left,
            Parent = TabButton
        })
        
        -- Create tab content
        local TabContent = createInstance("ScrollingFrame", {
            Name = name .. "Content",
            Size = UDim2.new(1, -40, 1, -20),
            Position = UDim2.new(0, 20, 0, 10),
            BackgroundTransparency = 1,
            ScrollBarThickness = 2,
            ScrollBarImageColor3 = SECONDARY_TEXT_COLOR,
            ScrollingDirection = Enum.ScrollingDirection.Y,
            AutomaticCanvasSize = Enum.AutomaticSize.Y,
            CanvasSize = UDim2.new(0, 0, 0, 0),
            Visible = false,
            Parent = ContentContainer
        })
        
        local TabContentLayout = createInstance("UIListLayout", {
            Padding = UDim.new(0, 10),
            SortOrder = Enum.SortOrder.LayoutOrder,
            Parent = TabContent
        })
        
        -- Tab selection logic
        TabButton.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 then
                if SelectedTab then
                    -- Deselect current tab
                    createTween(Tabs[SelectedTab].ButtonBackground, {BackgroundTransparency = 1}):Play()
                    createTween(Tabs[SelectedTab].ButtonText, {TextColor3 = SECONDARY_TEXT_COLOR}):Play()
                    if Tabs[SelectedTab].ButtonIcon then
                        createTween(Tabs[SelectedTab].ButtonIcon, {ImageColor3 = SECONDARY_TEXT_COLOR}):Play()
                    end
                    Tabs[SelectedTab].Content.Visible = false
                end
                
                -- Select new tab
                createTween(TabButtonBackground, {BackgroundTransparency = 0.8}):Play()
                createTween(TabButtonText, {TextColor3 = TEXT_COLOR}):Play()
                if TabButtonIcon then
                    createTween(TabButtonIcon, {ImageColor3 = ACCENT_COLOR}):Play()
                end
                TabContent.Visible = true
                
                SelectedTab = name
                TabTitle.Text = name
            end
        end)
        
        -- Store tab data
        Tabs[name] = {
            Button = TabButton,
            ButtonBackground = TabButtonBackground,
            ButtonText = TabButtonText,
            ButtonIcon = TabButtonIcon,
            Content = TabContent
        }
        
        -- If this is the first tab, select it
        if not SelectedTab then
            createTween(TabButtonBackground, {BackgroundTransparency = 0.8}):Play()
            createTween(TabButtonText, {TextColor3 = TEXT_COLOR}):Play()
            if TabButtonIcon then
                createTween(TabButtonIcon, {ImageColor3 = ACCENT_COLOR}):Play()
            end
            TabContent.Visible = true
            
            SelectedTab = name
            TabTitle.Text = name
        end
        
        -- Tab content creation functions
        local Tab = {}
        
        function Tab:CreateSection(sectionName)
            local Section = createInstance("Frame", {
                Name = sectionName .. "Section",
                Size = UDim2.new(1, 0, 0, 30),
                BackgroundTransparency = 1,
                Parent = TabContent
            })
            
            local SectionTitle = createInstance("TextLabel", {
                Name = "Title",
                Size = UDim2.new(1, 0, 0, 30),
                BackgroundTransparency = 1,
                Text = sectionName,
                TextColor3 = TEXT_COLOR,
                TextSize = 16,
                Font = Enum.Font.GothamSemibold,
                TextXAlignment = Enum.TextXAlignment.Left,
                Parent = Section
            })
            
            local SectionContent = createInstance("Frame", {
                Name = "Content",
                Size = UDim2.new(1, 0, 0, 0),
                Position = UDim2.new(0, 0, 0, 30),
                BackgroundTransparency = 1,
                AutomaticSize = Enum.AutomaticSize.Y,
                Parent = Section
            })
            
            local SectionContentLayout = createInstance("UIListLayout", {
                Padding = UDim.new(0, 8),
                SortOrder = Enum.SortOrder.LayoutOrder,
                Parent = SectionContent
            })
            
            -- Update section size based on content
            SectionContentLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
                Section.Size = UDim2.new(1, 0, 0, 30 + SectionContentLayout.AbsoluteContentSize.Y)
            end)
            
            local SectionObj = {}
            
            function SectionObj:CreateToggle(toggleName, defaultState, callback)
                local Toggle = createInstance("Frame", {
                    Name = toggleName .. "Toggle",
                    Size = UDim2.new(1, 0, 0, 30),
                    BackgroundTransparency = 1,
                    Parent = SectionContent
                })
                
                local ToggleLabel = createInstance("TextLabel", {
                    Name = "Label",
                    Size = UDim2.new(1, -60, 1, 0),
                    BackgroundTransparency = 1,
                    Text = toggleName,
                    TextColor3 = SECONDARY_TEXT_COLOR,
                    TextSize = 14,
                    Font = Enum.Font.Gotham,
                    TextXAlignment = Enum.TextXAlignment.Left,
                    Parent = Toggle
                })
                
                local KeybindLabel = createInstance("TextLabel", {
                    Name = "KeybindLabel",
                    Size = UDim2.new(0, 30, 1, 0),
                    Position = UDim2.new(1, -60, 0, 0),
                    BackgroundTransparency = 1,
                    Text = "[E]",
                    TextColor3 = SECONDARY_TEXT_COLOR,
                    TextSize = 12,
                    Font = Enum.Font.Gotham,
                    TextXAlignment = Enum.TextXAlignment.Right,
                    Parent = Toggle
                })
                
                local ToggleButton = createInstance("Frame", {
                    Name = "Button",
                    Size = UDim2.new(0, 40, 0, 20),
                    Position = UDim2.new(1, -45, 0.5, -10),
                    BackgroundColor3 = defaultState and TOGGLE_COLOR or TOGGLE_OFF_COLOR,
                    Parent = Toggle
                })
                createRoundedCorner(ToggleButton, 10)
                
                local ToggleCircle = createInstance("Frame", {
                    Name = "Circle",
                    Size = UDim2.new(0, 16, 0, 16),
                    Position = UDim2.new(defaultState and 1 or 0, defaultState and -18 or 2, 0.5, -8),
                    BackgroundColor3 = Color3.fromRGB(255, 255, 255),
                    Parent = ToggleButton
                })
                createRoundedCorner(ToggleCircle, 8)
                
                local state = defaultState or false
                
                local function updateToggle()
                    state = not state
                    
                    local toggleTween = createTween(ToggleButton, {BackgroundColor3 = state and TOGGLE_COLOR or TOGGLE_OFF_COLOR})
                    local circleTween = createTween(ToggleCircle, {Position = state and UDim2.new(1, -18, 0.5, -8) or UDim2.new(0, 2, 0.5, -8)})
                    
                    toggleTween:Play()
                    circleTween:Play()
                    
                    if callback then
                        callback(state)
                    end
                end
                
                ToggleButton.InputBegan:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.MouseButton1 then
                        updateToggle()
                    end
                end)
                
                return {
                    Set = function(newState)
                        if state ~= newState then
                            updateToggle()
                        end
                    end,
                    Get = function()
                        return state
                    end
                }
            end
            
            function SectionObj:CreateSlider(sliderName, options, callback)
                options = options or {}
                local min = options.min or 0
                local max = options.max or 100
                local default = options.default or min
                local decimals = options.decimals or 0
                
                local Slider = createInstance("Frame", {
                    Name = sliderName .. "Slider",
                    Size = UDim2.new(1, 0, 0, 50),
                    BackgroundTransparency = 1,
                    Parent = SectionContent
                })
                
                local SliderLabel = createInstance("TextLabel", {
                    Name = "Label",
                    Size = UDim2.new(1, -60, 0, 20),
                    BackgroundTransparency = 1,
                    Text = sliderName,
                    TextColor3 = SECONDARY_TEXT_COLOR,
                    TextSize = 14,
                    Font = Enum.Font.Gotham,
                    TextXAlignment = Enum.TextXAlignment.Left,
                    Parent = Slider
                })
                
                local SliderValue = createInstance("TextLabel", {
                    Name = "Value",
                    Size = UDim2.new(0, 50, 0, 20),
                    Position = UDim2.new(1, -50, 0, 0),
                    BackgroundTransparency = 1,
                    Text = tostring(default),
                    TextColor3 = SECONDARY_TEXT_COLOR,
                    TextSize = 14,
                    Font = Enum.Font.Gotham,
                    TextXAlignment = Enum.TextXAlignment.Right,
                    Parent = Slider
                })
                
                local SliderBackground = createInstance("Frame", {
                    Name = "Background",
                    Size = UDim2.new(1, 0, 0, 8),
                    Position = UDim2.new(0, 0, 0, 30),
                    BackgroundColor3 = SLIDER_BACKGROUND,
                    Parent = Slider
                })
                createRoundedCorner(SliderBackground, 4)
                
                local SliderFill = createInstance("Frame", {
                    Name = "Fill",
                    Size = UDim2.new((default - min) / (max - min), 0, 1, 0),
                    BackgroundColor3 = SLIDER_FILL,
                    Parent = SliderBackground
                })
                createRoundedCorner(SliderFill, 4)
                
                local SliderKnob = createInstance("Frame", {
                    Name = "Knob",
                    Size = UDim2.new(0, 16, 0, 16),
                    Position = UDim2.new((default - min) / (max - min), -8, 0.5, -8),
                    BackgroundColor3 = Color3.fromRGB(255, 255, 255),
                    Parent = SliderBackground
                })
                createRoundedCorner(SliderKnob, 8)
                
                local value = default
                local isDragging = false
                
                local function updateSlider(newValue)
                    value = math.clamp(newValue, min, max)
                    
                    if decimals > 0 then
                        local mult = 10 ^ decimals
                        value = math.floor(value * mult + 0.5) / mult
                    else
                        value = math.floor(value)
                    end
                    
                    SliderValue.Text = tostring(value)
                    
                    local percent = (value - min) / (max - min)
                    SliderFill.Size = UDim2.new(percent, 0, 1, 0)
                    SliderKnob.Position = UDim2.new(percent, -8, 0.5, -8)
                    
                    if callback then
                        callback(value)
                    end
                end
                
                SliderBackground.InputBegan:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.MouseButton1 then
                        isDragging = true
                        
                        local mousePos = input.Position.X
                        local sliderPos = SliderBackground.AbsolutePosition.X
                        local sliderSize = SliderBackground.AbsoluteSize.X
                        
                        local percent = math.clamp((mousePos - sliderPos) / sliderSize, 0, 1)
                        local newValue = min + (max - min) * percent
                        
                        updateSlider(newValue)
                    end
                end)
                
                SliderBackground.InputEnded:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.MouseButton1 then
                        isDragging = false
                    end
                end)
                
                UserInputService.InputChanged:Connect(function(input)
                    if isDragging and input.UserInputType == Enum.UserInputType.MouseMovement then
                        local mousePos = input.Position.X
                        local sliderPos = SliderBackground.AbsolutePosition.X
                        local sliderSize = SliderBackground.AbsoluteSize.X
                        
                        local percent = math.clamp((mousePos - sliderPos) / sliderSize, 0, 1)
                        local newValue = min + (max - min) * percent
                        
                        updateSlider(newValue)
                    end
                end)
                
                return {
                    Set = function(newValue)
                        updateSlider(newValue)
                    end,
                    Get = function()
                        return value
                    end
                }
            end
            
            function SectionObj:CreateDropdown(dropdownName, options, callback)
                local items = options.items or {}
                local default = options.default or items[1] or ""
                
                local Dropdown = createInstance("Frame", {
                    Name = dropdownName .. "Dropdown",
                    Size = UDim2.new(1, 0, 0, 50),
                    BackgroundTransparency = 1,
                    Parent = SectionContent
                })
                
                local DropdownLabel = createInstance("TextLabel", {
                    Name = "Label",
                    Size = UDim2.new(1, 0, 0, 20),
                    BackgroundTransparency = 1,
                    Text = dropdownName,
                    TextColor3 = SECONDARY_TEXT_COLOR,
                    TextSize = 14,
                    Font = Enum.Font.Gotham,
                    TextXAlignment = Enum.TextXAlignment.Left,
                    Parent = Dropdown
                })
                
                local DropdownButton = createInstance("Frame", {
                    Name = "Button",
                    Size = UDim2.new(1, 0, 0, 30),
                    Position = UDim2.new(0, 0, 0, 20),
                    BackgroundColor3 = DROPDOWN_BACKGROUND,
                    Parent = Dropdown
                })
                createRoundedCorner(DropdownButton, 4)
                
                local DropdownText = createInstance("TextLabel", {
                    Name = "Text",
                    Size = UDim2.new(1, -30, 1, 0),
                    Position = UDim2.new(0, 10, 0, 0),
                    BackgroundTransparency = 1,
                    Text = default,
                    TextColor3 = TEXT_COLOR,
                    TextSize = 14,
                    Font = Enum.Font.Gotham,
                    TextXAlignment = Enum.TextXAlignment.Left,
                    Parent = DropdownButton
                })
                
                local DropdownArrow = createInstance("ImageLabel", {
                    Name = "Arrow",
                    Size = UDim2.new(0, 16, 0, 16),
                    Position = UDim2.new(1, -26, 0.5, -8),
                    BackgroundTransparency = 1,
                    Image = "rbxassetid://6031091004",
                    ImageColor3 = SECONDARY_TEXT_COLOR,
                    Parent = DropdownButton
                })
                
                local DropdownMenu = createInstance("Frame", {
                    Name = "Menu",
                    Size = UDim2.new(1, 0, 0, 0),
                    Position = UDim2.new(0, 0, 1, 0),
                    BackgroundColor3 = DROPDOWN_BACKGROUND,
                    ClipsDescendants = true,
                    Visible = false,
                    ZIndex = 5,
                    Parent = DropdownButton
                })
                createRoundedCorner(DropdownMenu, 4)
                
                local DropdownList = createInstance("ScrollingFrame", {
                    Name = "List",
                    Size = UDim2.new(1, 0, 1, 0),
                    BackgroundTransparency = 1,
                    ScrollBarThickness = 2,
                    ScrollBarImageColor3 = SECONDARY_TEXT_COLOR,
                    ZIndex = 5,
                    Parent = DropdownMenu
                })
                
                local DropdownListLayout = createInstance("UIListLayout", {
                    Padding = UDim.new(0, 5),
                    SortOrder = Enum.SortOrder.LayoutOrder,
                    Parent = DropdownList
                })
                
                local DropdownListPadding = createInstance("UIPadding", {
                    PaddingLeft = UDim.new(0, 5),
                    PaddingRight = UDim.new(0, 5),
                    PaddingTop = UDim.new(0, 5),
                    PaddingBottom = UDim.new(0, 5),
                    Parent = DropdownList
                })
                
                local isOpen = false
                local selectedItem = default
                
                local function updateDropdown()
                    isOpen = not isOpen
                    
                    if isOpen then
                        DropdownMenu.Visible = true
                        createTween(DropdownMenu, {Size = UDim2.new(1, 0, 0, math.min(#items * 30, 150))}):Play()
                        createTween(DropdownArrow, {Rotation = 180}):Play()
                    else
                        createTween(DropdownMenu, {Size = UDim2.new(1, 0, 0, 0)}):Play()
                        createTween(DropdownArrow, {Rotation = 0}):Play()
                        
                        delay(0.2, function()
                            if not isOpen then
                                DropdownMenu.Visible = false
                            end
                        end)
                    end
                end
                
                -- Populate dropdown items
                for i, item in ipairs(items) do
                    local ItemButton = createInstance("TextButton", {
                        Name = "Item_" .. i,
                        Size = UDim2.new(1, 0, 0, 25),
                        BackgroundTransparency = 1,
                        Text = item,
                        TextColor3 = item == selectedItem and ACCENT_COLOR or SECONDARY_TEXT_COLOR,
                        TextSize = 14,
                        Font = Enum.Font.Gotham,
                        ZIndex = 5,
                        Parent = DropdownList
                    })
                    
                    ItemButton.MouseEnter:Connect(function()
                        if item ~= selectedItem then
                            createTween(ItemButton, {TextColor3 = TEXT_COLOR}):Play()
                        end
                    end)
                    
                    ItemButton.MouseLeave:Connect(function()
                        if item ~= selectedItem then
                            createTween(ItemButton, {TextColor3 = SECONDARY_TEXT_COLOR}):Play()
                        end
                    end)
                    
                    ItemButton.MouseButton1Click:Connect(function()
                        if selectedItem ~= item then
                            -- Update selected item
                            for _, child in pairs(DropdownList:GetChildren()) do
                                if child:IsA("TextButton") then
                                    createTween(child, {TextColor3 = SECONDARY_TEXT_COLOR}):Play()
                                end
                            end
                            
                            selectedItem = item
                            DropdownText.Text = item
                            createTween(ItemButton, {TextColor3 = ACCENT_COLOR}):Play()
                            
                            if callback then
                                callback(item)
                            end
                        end
                        
                        updateDropdown()
                    end)
                end
                
                DropdownButton.InputBegan:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.MouseButton1 then
                        updateDropdown()
                    end
                end)
                
                -- Close dropdown when clicking elsewhere
                UserInputService.InputBegan:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.MouseButton1 then
                        local mousePos = UserInputService:GetMouseLocation()
                        if isOpen and not (mousePos.X >= DropdownButton.AbsolutePosition.X and
                                mousePos.X <= DropdownButton.AbsolutePosition.X + DropdownButton.AbsoluteSize.X and
                                mousePos.Y >= DropdownButton.AbsolutePosition.Y and
                                mousePos.Y <= DropdownButton.AbsolutePosition.Y + DropdownButton.AbsoluteSize.Y + DropdownMenu.AbsoluteSize.Y) then
                            updateDropdown()
                        end
                    end
                end)
                
                return {
                    Set = function(item)
                        if table.find(items, item) and selectedItem ~= item then
                            selectedItem = item
                            DropdownText.Text = item
                            
                            for _, child in pairs(DropdownList:GetChildren()) do
                                if child:IsA("TextButton") and child.Text == item then
                                    createTween(child, {TextColor3 = ACCENT_COLOR}):Play()
                                elseif child:IsA("TextButton") then
                                    createTween(child, {TextColor3 = SECONDARY_TEXT_COLOR}):Play()
                                end
                            end
                            
                            if callback then
                                callback(item)
                            end
                        end
                    end,
                    Get = function()
                        return selectedItem
                    end,
                    Refresh = function(newItems, keepSelected)
                        items = newItems
                        
                        -- Clear existing items
                        for _, child in pairs(DropdownList:GetChildren()) do
                            if child:IsA("TextButton") then
                                child:Destroy()
                            end
                        end
                        
                        -- Check if we should keep the selected item
                        if not keepSelected or not table.find(items, selectedItem) then
                            selectedItem = items[1] or ""
                            DropdownText.Text = selectedItem
                        end
                        
                        -- Repopulate dropdown items
                        for i, item in ipairs(items) do
                            local ItemButton = createInstance("TextButton", {
                                Name = "Item_" .. i,
                                Size = UDim2.new(1, 0, 0, 25),
                                BackgroundTransparency = 1,
                                Text = item,
                                TextColor3 = item == selectedItem and ACCENT_COLOR or SECONDARY_TEXT_COLOR,
                                TextSize = 14,
                                Font = Enum.Font.Gotham,
                                ZIndex = 5,
                                Parent = DropdownList
                            })
                            
                            ItemButton.MouseEnter:Connect(function()
                                if item ~= selectedItem then
                                    createTween(ItemButton, {TextColor3 = TEXT_COLOR}):Play()
                                end
                            end)
                            
                            ItemButton.MouseLeave:Connect(function()
                                if item ~= selectedItem then
                                    createTween(ItemButton, {TextColor3 = SECONDARY_TEXT_COLOR}):Play()
                                end
                            end)
                            
                            ItemButton.MouseButton1Click:Connect(function()
                                if selectedItem ~= item then
                                    -- Update selected item
                                    for _, child in pairs(DropdownList:GetChildren()) do
                                        if child:IsA("TextButton") then
                                            createTween(child, {TextColor3 = SECONDARY_TEXT_COLOR}):Play()
                                        end
                                    end
                                    
                                    selectedItem = item
                                    DropdownText.Text = item
                                    createTween(ItemButton, {TextColor3 = ACCENT_COLOR}):Play()
                                    
                                    if callback then
                                        callback(item)
                                    end
                                end
                                
                                updateDropdown()
                            end)
                        end
                    end
                }
            end
            
            function SectionObj:CreateTextBox(boxName, defaultText, placeholder, callback)
                local TextBox = createInstance("Frame", {
                    Name = boxName .. "TextBox",
                    Size = UDim2.new(1, 0, 0, 50),
                    BackgroundTransparency = 1,
                    Parent = SectionContent
                })
                
                local TextBoxLabel = createInstance("TextLabel", {
                    Name = "Label",
                    Size = UDim2.new(1, 0, 0, 20),
                    BackgroundTransparency = 1,
                    Text = boxName,
                    TextColor3 = SECONDARY_TEXT_COLOR,
                    TextSize = 14,
                    Font = Enum.Font.Gotham,
                    TextXAlignment = Enum.TextXAlignment.Left,
                    Parent = TextBox
                })
                
                local TextBoxFrame = createInstance("Frame", {
                    Name = "Frame",
                    Size = UDim2.new(1, 0, 0, 30),
                    Position = UDim2.new(0, 0, 0, 20),
                    BackgroundColor3 = DROPDOWN_BACKGROUND,
                    Parent = TextBox
                })
                createRoundedCorner(TextBoxFrame, 4)
                
                local EditIcon = createInstance("ImageLabel", {
                    Name = "EditIcon",
                    Size = UDim2.new(0, 16, 0, 16),
                    Position = UDim2.new(1, -26, 0.5, -8),
                    BackgroundTransparency = 1,
                    Image = "rbxassetid://6764432408",
                    ImageColor3 = SECONDARY_TEXT_COLOR,
                    Parent = TextBoxFrame
                })
                
                local TextBoxInput = createInstance("TextBox", {
                    Name = "Input",
                    Size = UDim2.new(1, -40, 1, 0),
                    Position = UDim2.new(0, 10, 0, 0),
                    BackgroundTransparency = 1,
                    Text = defaultText or "",
                    PlaceholderText = placeholder or "Enter text...",
                    TextColor3 = TEXT_COLOR,
                    PlaceholderColor3 = Color3.fromRGB(120, 120, 120),
                    TextSize = 14,
                    Font = Enum.Font.Gotham,
                    TextXAlignment = Enum.TextXAlignment.Left,
                    ClearTextOnFocus = false,
                    Parent = TextBoxFrame
                })
                
                TextBoxInput.FocusLost:Connect(function(enterPressed)
                    if callback then
                        callback(TextBoxInput.Text, enterPressed)
                    end
                end)
                
                return {
                    Set = function(newText)
                        TextBoxInput.Text = newText
                    end,
                    Get = function()
                        return TextBoxInput.Text
                    end
                }
            end
            
            function SectionObj:CreateColorPicker(pickerName, defaultColor, callback)
                local ColorPicker = createInstance("Frame", {
                    Name = pickerName .. "ColorPicker",
                    Size = UDim2.new(1, 0, 0, 50),
                    BackgroundTransparency = 1,
                    Parent = SectionContent
                })
                
                local ColorPickerLabel = createInstance("TextLabel", {
                    Name = "Label",
                    Size = UDim2.new(1, -60, 0, 20),
                    BackgroundTransparency = 1,
                    Text = pickerName,
                    TextColor3 = SECONDARY_TEXT_COLOR,
                    TextSize = 14,
                    Font = Enum.Font.Gotham,
                    TextXAlignment = Enum.TextXAlignment.Left,
                    Parent = ColorPicker
                })
                
                local ColorDisplay = createInstance("Frame", {
                    Name = "Display",
                    Size = UDim2.new(0, 30, 0, 30),
                    Position = UDim2.new(1, -40, 0, 0),
                    BackgroundColor3 = defaultColor or Color3.fromRGB(255, 0, 0),
                    Parent = ColorPicker
                })
                createRoundedCorner(ColorDisplay, 4)
                
                -- Simple implementation - in a real library you'd want a more sophisticated color picker
                ColorDisplay.InputBegan:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.MouseButton1 then
                        -- For this example, we'll just cycle through some preset colors
                        local colors = {
                            Color3.fromRGB(255, 0, 0),   -- Red
                            Color3.fromRGB(255, 165, 0), -- Orange
                            Color3.fromRGB(255, 255, 0), -- Yellow
                            Color3.fromRGB(0, 255, 0),   -- Green
                            Color3.fromRGB(0, 0, 255),   -- Blue
                            Color3.fromRGB(128, 0, 128), -- Purple
                            Color3.fromRGB(255, 0, 255)  -- Pink
                        }
                        
                        local currentColor = ColorDisplay.BackgroundColor3
                        local currentIndex = 1
                        
                        for i, color in ipairs(colors) do
                            if color == currentColor then
                                currentIndex = i
                                break
                            end
                        end
                        
                        local nextIndex = (currentIndex % #colors) + 1
                        local nextColor = colors[nextIndex]
                        
                        createTween(ColorDisplay, {BackgroundColor3 = nextColor}):Play()
                        
                        if callback then
                            callback(nextColor)
                        end
                    end
                end)
                
                return {
                    Set = function(newColor)
                        createTween(ColorDisplay, {BackgroundColor3 = newColor}):Play()
                        
                        if callback then
                            callback(newColor)
                        end
                    end,
                    Get = function()
                        return ColorDisplay.BackgroundColor3
                    end
                }
            end
            
            function SectionObj:CreateButton(buttonName, callback)
                local Button = createInstance("Frame", {
                    Name = buttonName .. "Button",
                    Size = UDim2.new(1, 0, 0, 30),
                    BackgroundTransparency = 1,
                    Parent = SectionContent
                })
                
                local ButtonFrame = createInstance("Frame", {
                    Name = "Frame",
                    Size = UDim2.new(1, 0, 1, 0),
                    BackgroundColor3 = BUTTON_COLOR,
                    Parent = Button
                })
                createRoundedCorner(ButtonFrame, 4)
                
                local ButtonLabel = createInstance("TextLabel", {
                    Name = "Label",
                    Size = UDim2.new(1, 0, 1, 0),
                    BackgroundTransparency = 1,
                    Text = buttonName,
                    TextColor3 = TEXT_COLOR,
                    TextSize = 14,
                    Font = Enum.Font.GothamSemibold,
                    Parent = ButtonFrame
                })
                
                ButtonFrame.InputBegan:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.MouseButton1 then
                        createTween(ButtonFrame, {BackgroundColor3 = BUTTON_HOVER_COLOR}):Play()
                        
                        if callback then
                            callback()
                        end
                    end
                end)
                
                ButtonFrame.InputEnded:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.MouseButton1 then
                        createTween(ButtonFrame, {BackgroundColor3 = BUTTON_COLOR}):Play()
                    end
                end)
                
                return Button
            end
            
            return SectionObj
        end
        
        return Tab
    end
    
    return Window
end

return UILibrary
