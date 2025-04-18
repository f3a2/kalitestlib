local UILibrary = {}

-- Services
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local TextService = game:GetService("TextService")
local HttpService = game:GetService("HttpService")
local CoreGui = game:GetService("CoreGui")

-- Variables
local LocalPlayer = Players.LocalPlayer
local Mouse = LocalPlayer:GetMouse()
local ViewportSize = workspace.CurrentCamera.ViewportSize
local IsMobile = UserInputService.TouchEnabled and not UserInputService.KeyboardEnabled

-- Constants
local BACKGROUND_COLOR = Color3.fromRGB(15, 15, 15)
local SIDEBAR_COLOR = Color3.fromRGB(10, 10, 10)
local ACCENT_COLOR = Color3.fromRGB(255, 255, 255)
local TEXT_COLOR = Color3.fromRGB(255, 255, 255)
local SECONDARY_TEXT_COLOR = Color3.fromRGB(180, 180, 180)
local TOGGLE_COLOR = Color3.fromRGB(0, 170, 255)
local TOGGLE_OFF_COLOR = Color3.fromRGB(60, 60, 60)
local SLIDER_BACKGROUND = Color3.fromRGB(40, 40, 40)
local SLIDER_FILL = Color3.fromRGB(255, 255, 255)
local DROPDOWN_BACKGROUND = Color3.fromRGB(30, 30, 30)
local BUTTON_COLOR = Color3.fromRGB(40, 40, 40)
local BUTTON_HOVER_COLOR = Color3.fromRGB(50, 50, 50)
local INPUT_BACKGROUND = Color3.fromRGB(30, 30, 30)

-- Configuration
local ConfigSystem = {
    Folder = "UILibrary",
    Extension = ".config"
}

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

local function makeOnlyTopDraggable(frame, dragArea)
    local isDragging = false
    local dragInput
    local dragStart
    local startPos
    
    dragArea.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            isDragging = true
            dragStart = input.Position
            startPos = frame.Position
            
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    isDragging = false
                end
            end)
        end
    end)
    
    dragArea.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
            dragInput = input
        end
    end)
    
    UserInputService.InputChanged:Connect(function(input)
        if input == dragInput and isDragging then
            local delta = input.Position - dragStart
            frame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)
end

-- Color Picker Functions
local function createColorPicker(parent, defaultColor, callback)
    local colorOptions = {
        Color3.fromRGB(255, 0, 0),    -- Red
        Color3.fromRGB(255, 165, 0),  -- Orange
        Color3.fromRGB(255, 255, 0),  -- Yellow
        Color3.fromRGB(0, 255, 0),    -- Green
        Color3.fromRGB(0, 255, 255),  -- Cyan
        Color3.fromRGB(0, 0, 255),    -- Blue
        Color3.fromRGB(255, 0, 255),  -- Purple
        Color3.fromRGB(255, 255, 255),-- White
        Color3.fromRGB(0, 0, 0)       -- Black
    }
    
    local currentColorIndex = 1
    -- Find the matching color in our options, or default to the first color
    for i, color in ipairs(colorOptions) do
        if color == defaultColor then
            currentColorIndex = i
            break
        end
    end
    
    -- Create the color display button
    local ColorDisplay = createInstance("TextButton", {
        Name = "ColorDisplay",
        Size = UDim2.new(0, 24, 0, 24),
        BackgroundColor3 = colorOptions[currentColorIndex],
        Text = "",
        AutoButtonColor = false,
        Parent = parent
    })
    createRoundedCorner(ColorDisplay, 4)
    createStroke(ColorDisplay, Color3.fromRGB(50, 50, 50), 1, 0)
    
    -- Cycle through colors on click
    ColorDisplay.MouseButton1Click:Connect(function()
        currentColorIndex = (currentColorIndex % #colorOptions) + 1
        local newColor = colorOptions[currentColorIndex]
        ColorDisplay.BackgroundColor3 = newColor
        
        if callback then
            callback(newColor)
        end
    end)
    
    return {
        GetColor = function()
            return ColorDisplay.BackgroundColor3
        end,
        SetColor = function(color)
            for i, c in ipairs(colorOptions) do
                if c == color then
                    currentColorIndex = i
                    ColorDisplay.BackgroundColor3 = color
                    if callback then
                        callback(color)
                    end
                    return
                end
            end
            -- If color not found in options, use it anyway
            ColorDisplay.BackgroundColor3 = color
            if callback then
                callback(color)
            end
        end
    }
end

-- Configuration System Functions
local function saveConfig(name)
    if not isfolder(ConfigSystem.Folder) then
        makefolder(ConfigSystem.Folder)
    end
    
    local success, encodedData = pcall(function()
        return HttpService:JSONEncode(_G.UILibraryConfig)
    end)
    
    if success then
        writefile(ConfigSystem.Folder .. "/" .. name .. ConfigSystem.Extension, encodedData)
        return true
    else
        warn("Failed to save config: " .. tostring(encodedData))
        return false
    end
end

local function loadConfig(name)
    local path = ConfigSystem.Folder .. "/" .. name .. ConfigSystem.Extension
    
    if isfile(path) then
        local success, decodedData = pcall(function()
            return HttpService:JSONDecode(readfile(path))
        end)
        
        if success then
            return decodedData
        else
            warn("Failed to load config: " .. tostring(decodedData))
            return nil
        end
    else
        return nil
    end
end

local function getConfigList()
    if not isfolder(ConfigSystem.Folder) then
        makefolder(ConfigSystem.Folder)
        return {}
    end
    
    local files = listfiles(ConfigSystem.Folder)
    local configs = {}
    
    for _, file in ipairs(files) do
        local fileName = string.match(file, "[^/\\]+$")
        if string.sub(fileName, -#ConfigSystem.Extension) == ConfigSystem.Extension then
            table.insert(configs, string.sub(fileName, 1, -#ConfigSystem.Extension - 1))
        end
    end
    
    return configs
end

-- Key System Functions
local function fetchKey(url)
    local success, result = pcall(function()
        return game:HttpGet(url)
    end)
    
    if success then
        return string.gsub(result, "%s+", "")
    else
        warn("Failed to fetch key: " .. tostring(result))
        return nil
    end
end

-- ESP Functions
local ESPEnabled = false
local ESPSettings = {
    BoxEnabled = false,
    NameEnabled = false,
    DistanceEnabled = false,
    TracerEnabled = false,
    HealthEnabled = false,
    TeamEnabled = false,
    TeamColor = false,
    VisibleCheck = false,
    BoxColor = Color3.fromRGB(255, 255, 255),
    NameColor = Color3.fromRGB(255, 255, 255),
    DistanceColor = Color3.fromRGB(255, 255, 255),
    TracerColor = Color3.fromRGB(255, 255, 255),
    VisibleColor = Color3.fromRGB(0, 255, 0),
    NotVisibleColor = Color3.fromRGB(255, 0, 0),
    MaxDistance = 1000,
    TextSize = 14,
    BoxThickness = 1,
    TracerThickness = 1,
    TracerOrigin = "Bottom", -- "Bottom", "Top", "Mouse"
}

local ESPObjects = {}

local function createESPObject(player)
    if player == LocalPlayer then return end
    
    local esp = {}
    
    -- Box ESP
    esp.Box = Drawing.new("Square")
    esp.Box.Visible = false
    esp.Box.Color = ESPSettings.BoxColor
    esp.Box.Thickness = ESPSettings.BoxThickness
    esp.Box.Filled = false
    esp.Box.Transparency = 1
    
    -- Box outline for better visibility
    esp.BoxOutline = Drawing.new("Square")
    esp.BoxOutline.Visible = false
    esp.BoxOutline.Color = Color3.fromRGB(0, 0, 0)
    esp.BoxOutline.Thickness = ESPSettings.BoxThickness + 1
    esp.BoxOutline.Filled = false
    esp.BoxOutline.Transparency = 1
    
    -- Name ESP
    esp.Name = Drawing.new("Text")
    esp.Name.Visible = false
    esp.Name.Color = ESPSettings.NameColor
    esp.Name.Size = ESPSettings.TextSize
    esp.Name.Center = true
    esp.Name.Outline = true
    esp.Name.OutlineColor = Color3.fromRGB(0, 0, 0)
    esp.Name.Font = 2 -- Enum.Font.Code
    
    -- Distance ESP
    esp.Distance = Drawing.new("Text")
    esp.Distance.Visible = false
    esp.Distance.Color = ESPSettings.DistanceColor
    esp.Distance.Size = ESPSettings.TextSize
    esp.Distance.Center = true
    esp.Distance.Outline = true
    esp.Distance.OutlineColor = Color3.fromRGB(0, 0, 0)
    esp.Distance.Font = 2 -- Enum.Font.Code
    
    -- Tracer ESP
    esp.Tracer = Drawing.new("Line")
    esp.Tracer.Visible = false
    esp.Tracer.Color = ESPSettings.TracerColor
    esp.Tracer.Thickness = ESPSettings.TracerThickness
    esp.Tracer.Transparency = 1
    
    -- Health Bar Background
    esp.HealthBG = Drawing.new("Line")
    esp.HealthBG.Visible = false
    esp.HealthBG.Color = Color3.fromRGB(0, 0, 0)
    esp.HealthBG.Thickness = 3
    esp.HealthBG.Transparency = 0.5
    
    -- Health Bar
    esp.Health = Drawing.new("Line")
    esp.Health.Visible = false
    esp.Health.Thickness = 1
    esp.Health.Transparency = 1
    
    -- Visible Text
    esp.Visible = Drawing.new("Text")
    esp.Visible.Visible = false
    esp.Visible.Color = ESPSettings.VisibleColor
    esp.Visible.Size = ESPSettings.TextSize
    esp.Visible.Center = true
    esp.Visible.Outline = true
    esp.Visible.OutlineColor = Color3.fromRGB(0, 0, 0)
    esp.Visible.Font = 2 -- Enum.Font.Code
    
    ESPObjects[player] = esp
    
    player.CharacterAdded:Connect(function()
        if not ESPObjects[player] then
            createESPObject(player)
        end
    end)
end

local function removeESPObject(player)
    if ESPObjects[player] then
        for _, obj in pairs(ESPObjects[player]) do
            obj:Remove()
        end
        ESPObjects[player] = nil
    end
end

local function isPlayerVisible(player)
    local character = player.Character
    if not character or not character:FindFirstChild("HumanoidRootPart") then return false end
    
    local hrp = character.HumanoidRootPart
    local ray = Ray.new(workspace.CurrentCamera.CFrame.Position, hrp.Position - workspace.CurrentCamera.CFrame.Position)
    local hit, position = workspace:FindPartOnRayWithIgnoreList(ray, {LocalPlayer.Character, character})
    
    return hit == nil or hit:IsDescendantOf(character)
end

local function updateESP()
    for player, esp in pairs(ESPObjects) do
        if player and player.Character and player.Character:FindFirstChild("HumanoidRootPart") and player.Character:FindFirstChild("Humanoid") then
            local character = player.Character
            local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
            local humanoid = character:FindFirstChild("Humanoid")
            local head = character:FindFirstChild("Head")
            
            if not humanoidRootPart or not humanoid or not head then
                continue
            end
            
            local rootPos = humanoidRootPart.Position
            local headPos = head.Position + Vector3.new(0, 0.5, 0)
            local legPos = rootPos - Vector3.new(0, 3, 0)
            
            local rootVector, rootOnScreen = workspace.CurrentCamera:WorldToViewportPoint(rootPos)
            local headVector, headOnScreen = workspace.CurrentCamera:WorldToViewportPoint(headPos)
            local legVector, legOnScreen = workspace.CurrentCamera:WorldToViewportPoint(legPos)
            
            local distance = (rootPos - workspace.CurrentCamera.CFrame.Position).Magnitude
            
            if rootOnScreen and distance <= ESPSettings.MaxDistance and ESPEnabled then
                -- Calculate box size based on character dimensions
                local boxSize = Vector2.new(
                    math.max(math.abs(headVector.X - legVector.X) * 2, 3),
                    math.abs(headVector.Y - legVector.Y) * 1.2
                )
                local boxPosition = Vector2.new(
                    rootVector.X - boxSize.X / 2,
                    rootVector.Y - boxSize.Y / 2
                )
                
                -- Check if player is visible
                local isVisible = ESPSettings.VisibleCheck and isPlayerVisible(player)
                local visibleText = isVisible and "Visible" or "Not Visible"
                local visibleColor = isVisible and ESPSettings.VisibleColor or ESPSettings.NotVisibleColor
                
                -- Update box
                esp.BoxOutline.Visible = ESPSettings.BoxEnabled
                esp.BoxOutline.Size = boxSize
                esp.BoxOutline.Position = boxPosition
                
                esp.Box.Visible = ESPSettings.BoxEnabled
                esp.Box.Size = boxSize
                esp.Box.Position = boxPosition
                esp.Box.Color = ESPSettings.TeamColor and player.TeamColor.Color or ESPSettings.BoxColor
                esp.Box.Thickness = ESPSettings.BoxThickness
                
                -- Update name
                esp.Name.Visible = ESPSettings.NameEnabled
                esp.Name.Position = Vector2.new(rootVector.X, boxPosition.Y - esp.Name.TextBounds.Y - 2)
                esp.Name.Text = player.Name
                esp.Name.Color = ESPSettings.TeamColor and player.TeamColor.Color or ESPSettings.NameColor
                esp.Name.Size = ESPSettings.TextSize
                
                -- Update distance
                esp.Distance.Visible = ESPSettings.DistanceEnabled
                esp.Distance.Position = Vector2.new(rootVector.X, boxPosition.Y + boxSize.Y + 2)
                esp.Distance.Text = math.floor(distance) .. " studs"
                esp.Distance.Color = ESPSettings.TeamColor and player.TeamColor.Color or ESPSettings.DistanceColor
                esp.Distance.Size = ESPSettings.TextSize
                
                -- Update visible text
                esp.Visible.Visible = ESPSettings.VisibleCheck
                esp.Visible.Position = Vector2.new(
                    rootVector.X, 
                    boxPosition.Y + boxSize.Y + (ESPSettings.DistanceEnabled and esp.Distance.TextBounds.Y + 2 or 0) + 2
                )
                esp.Visible.Text = visibleText
                esp.Visible.Color = visibleColor
                esp.Visible.Size = ESPSettings.TextSize
                
                -- Update tracer
                esp.Tracer.Visible = ESPSettings.TracerEnabled
                
                local tracerStart
                if ESPSettings.TracerOrigin == "Bottom" then
                    tracerStart = Vector2.new(workspace.CurrentCamera.ViewportSize.X / 2, workspace.CurrentCamera.ViewportSize.Y)
                elseif ESPSettings.TracerOrigin == "Top" then
                    tracerStart = Vector2.new(workspace.CurrentCamera.ViewportSize.X / 2, 0)
                elseif ESPSettings.TracerOrigin == "Mouse" then
                    tracerStart = Vector2.new(Mouse.X, Mouse.Y)
                end
                
                esp.Tracer.From = tracerStart
                esp.Tracer.To = Vector2.new(rootVector.X, rootVector.Y)
                esp.Tracer.Color = ESPSettings.TeamColor and player.TeamColor.Color or ESPSettings.TracerColor
                esp.Tracer.Thickness = ESPSettings.TracerThickness
                
                -- Update health bar
                if ESPSettings.HealthEnabled and humanoid then
                    local health = humanoid.Health
                    local maxHealth = humanoid.MaxHealth
                    local healthPercent = math.clamp(health / maxHealth, 0, 1)
                    
                    -- Position health bar to the left of the box
                    local healthBarHeight = boxSize.Y
                    local healthBarPos = Vector2.new(boxPosition.X - 5, boxPosition.Y)
                    
                    esp.HealthBG.Visible = true
                    esp.HealthBG.From = Vector2.new(healthBarPos.X, healthBarPos.Y)
                    esp.HealthBG.To = Vector2.new(healthBarPos.X, healthBarPos.Y + healthBarHeight)
                    
                    esp.Health.Visible = true
                    esp.Health.From = Vector2.new(healthBarPos.X, healthBarPos.Y + healthBarHeight * (1 - healthPercent))
                    esp.Health.To = Vector2.new(healthBarPos.X, healthBarPos.Y + healthBarHeight)
                    
                    -- Health color gradient: red to green
                    esp.Health.Color = Color3.fromRGB(255 * (1 - healthPercent), 255 * healthPercent, 0)
                else
                    esp.HealthBG.Visible = false
                    esp.Health.Visible = false
                end
            else
                -- Hide ESP if player is not on screen or too far
                esp.BoxOutline.Visible = false
                esp.Box.Visible = false
                esp.Name.Visible = false
                esp.Distance.Visible = false
                esp.Tracer.Visible = false
                esp.HealthBG.Visible = false
                esp.Health.Visible = false
                esp.Visible.Visible = false
            end
        else
            -- Hide ESP if player character doesn't exist
            esp.BoxOutline.Visible = false
            esp.Box.Visible = false
            esp.Name.Visible = false
            esp.Distance.Visible = false
            esp.Tracer.Visible = false
            esp.HealthBG.Visible = false
            esp.Health.Visible = false
            esp.Visible.Visible = false
        end
    end
end

-- Main Library Functions
function UILibrary:CreateWindow(title, keySystemOptions)
    -- Initialize global config table
    if not _G.UILibraryConfig then
        _G.UILibraryConfig = {}
    end
    
    -- Key System Check
    if keySystemOptions and keySystemOptions.Enabled then
        -- Create key system UI
        local KeySystemGui = createInstance("ScreenGui", {
            Name = "KeySystem",
            Parent = CoreGui,
            ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
            ResetOnSpawn = false
        })
        
        local KeyFrame = createInstance("Frame", {
            Name = "KeyFrame",
            Size = UDim2.new(0, 300, 0, 200),
            Position = UDim2.new(0.5, -150, 0.5, -100),
            BackgroundColor3 = BACKGROUND_COLOR,
            BorderSizePixel = 0,
            Parent = KeySystemGui
        })
        createRoundedCorner(KeyFrame, 6)
        createStroke(KeyFrame, Color3.fromRGB(50, 50, 50), 1, 0)
        
        local KeyTitle = createInstance("TextLabel", {
            Name = "KeyTitle",
            Size = UDim2.new(1, 0, 0, 40),
            BackgroundTransparency = 1,
            Text = "Key System",
            TextColor3 = TEXT_COLOR,
            TextSize = 18,
            Font = Enum.Font.GothamBold,
            Parent = KeyFrame
        })
        
        local KeyDescription = createInstance("TextLabel", {
            Name = "KeyDescription",
            Size = UDim2.new(1, -40, 0, 40),
            Position = UDim2.new(0, 20, 0, 40),
            BackgroundTransparency = 1,
            Text = keySystemOptions.Note or "Please enter the key to continue",
            TextColor3 = SECONDARY_TEXT_COLOR,
            TextSize = 14,
            TextWrapped = true,
            Font = Enum.Font.Gotham,
            Parent = KeyFrame
        })
        
        local KeyInput = createInstance("TextBox", {
            Name = "KeyInput",
            Size = UDim2.new(1, -40, 0, 40),
            Position = UDim2.new(0, 20, 0, 90),
            BackgroundColor3 = INPUT_BACKGROUND,
            Text = "",
            PlaceholderText = "Enter key here...",
            TextColor3 = TEXT_COLOR,
            PlaceholderColor3 = SECONDARY_TEXT_COLOR,
            TextSize = 14,
            Font = Enum.Font.Gotham,
            ClearTextOnFocus = false,
            Parent = KeyFrame
        })
        createRoundedCorner(KeyInput, 4)
        
        local SubmitButton = createInstance("TextButton", {
            Name = "SubmitButton",
            Size = UDim2.new(1, -40, 0, 40),
            Position = UDim2.new(0, 20, 0, 140),
            BackgroundColor3 = ACCENT_COLOR,
            Text = "Submit",
            TextColor3 = BACKGROUND_COLOR,
            TextSize = 14,
            Font = Enum.Font.GothamSemibold,
            Parent = KeyFrame
        })
        createRoundedCorner(SubmitButton, 4)
        
        local StatusLabel = createInstance("TextLabel", {
            Name = "StatusLabel",
            Size = UDim2.new(1, 0, 0, 20),
            Position = UDim2.new(0, 0, 1, -20),
            BackgroundTransparency = 1,
            Text = "",
            TextColor3 = Color3.fromRGB(255, 100, 100),
            TextSize = 12,
            Font = Enum.Font.Gotham,
            Parent = KeyFrame
        })
        
        -- Make key frame draggable
        makeOnlyTopDraggable(KeyFrame, KeyTitle)
        
        -- Fetch the key from the URL
        local correctKey = nil
        
        if keySystemOptions.KeyURL then
            spawn(function()
                StatusLabel.Text = "Fetching key..."
                correctKey = fetchKey(keySystemOptions.KeyURL)
                if correctKey then
                    StatusLabel.Text = "Key fetched successfully"
                    StatusLabel.TextColor3 = Color3.fromRGB(100, 255, 100)
                else
                    StatusLabel.Text = "Failed to fetch key"
                    StatusLabel.TextColor3 = Color3.fromRGB(255, 100, 100)
                end
                wait(2)
                StatusLabel.Text = ""
            end)
        else
            correctKey = keySystemOptions.Key
        end
        
        -- Key validation
        local keyValidated = false
        
        local function validateKey()
            if not correctKey then
                StatusLabel.Text = "Key not available yet, try again"
                StatusLabel.TextColor3 = Color3.fromRGB(255, 100, 100)
                wait(2)
                StatusLabel.Text = ""
                return
            end
            
            if KeyInput.Text == correctKey then
                keyValidated = true
                StatusLabel.Text = "Key validated successfully!"
                StatusLabel.TextColor3 = Color3.fromRGB(100, 255, 100)
                wait(1)
                KeySystemGui:Destroy()
                return true
            else
                StatusLabel.Text = "Invalid key, please try again"
                StatusLabel.TextColor3 = Color3.fromRGB(255, 100, 100)
                wait(2)
                StatusLabel.Text = ""
                return false
            end
        end
        
        SubmitButton.MouseButton1Click:Connect(function()
            validateKey()
        end)
        
        KeyInput.FocusLost:Connect(function(enterPressed)
            if enterPressed then
                validateKey()
            end
        end)
        
        -- Wait for key validation
        repeat wait() until keyValidated
    end
    
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
        Size = UDim2.new(0, 650, 0, 400),
        Position = UDim2.new(0.5, -325, 0.5, -200),
        BackgroundColor3 = BACKGROUND_COLOR,
        BorderSizePixel = 0,
        Parent = UILibraryGui,
        Visible = true
    })
    createRoundedCorner(MainFrame, 6)
    createStroke(MainFrame, Color3.fromRGB(50, 50, 50), 1, 0)
    
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
        Size = UDim2.new(0, 120, 1, 0),
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
        Size = UDim2.new(1, -120, 1, 0),
        Position = UDim2.new(0, 120, 0, 0),
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
    
    -- Create search bar
    local SearchFrame = createInstance("Frame", {
        Name = "SearchFrame",
        Size = UDim2.new(0, 200, 0, 30),
        Position = UDim2.new(1, -220, 0.5, -15),
        BackgroundColor3 = SIDEBAR_COLOR,
        BorderSizePixel = 0,
        Parent = TopBar
    })
    createRoundedCorner(SearchFrame, 4)
    createStroke(SearchFrame, Color3.fromRGB(50, 50, 50), 1, 0)
    
    local SearchIcon = createInstance("ImageLabel", {
        Name = "SearchIcon",
        Size = UDim2.new(0, 16, 0, 16),
        Position = UDim2.new(0, 10, 0.5, -8),
        BackgroundTransparency = 1,
        Image = "rbxassetid://3926305904",
        ImageRectOffset = Vector2.new(964, 324),
        ImageRectSize = Vector2.new(36, 36),
        ImageColor3 = SECONDARY_TEXT_COLOR,
        Parent = SearchFrame
    })
    
    local SearchInput = createInstance("TextBox", {
        Name = "SearchInput",
        Size = UDim2.new(1, -40, 1, 0),
        Position = UDim2.new(0, 30, 0, 0),
        BackgroundTransparency = 1,
        Text = "",
        PlaceholderText = "Search...",
        TextColor3 = TEXT_COLOR,
        PlaceholderColor3 = SECONDARY_TEXT_COLOR,
        TextSize = 14,
        Font = Enum.Font.Gotham,
        ClearTextOnFocus = false,
        Parent = SearchFrame
    })
    
    -- Create content container
    local ContentContainer = createInstance("ScrollingFrame", {
        Name = "ContentContainer",
        Size = UDim2.new(1, 0, 1, -40),
        Position = UDim2.new(0, 0, 0, 40),
        BackgroundTransparency = 1,
        ScrollBarThickness = 4,
        ScrollBarImageColor3 = Color3.fromRGB(60, 60, 60),
        ScrollingDirection = Enum.ScrollingDirection.Y,
        CanvasSize = UDim2.new(0, 0, 0, 1000), -- Set initial canvas size to allow scrolling
        Parent = ContentArea
    })
    
    -- Create mobile toggle button
    local MobileToggle
    if IsMobile then
        MobileToggle = createInstance("ImageButton", {
            Name = "MobileToggle",
            Size = UDim2.new(0, 40, 0, 40),
            Position = UDim2.new(0, 10, 0, 10),
            BackgroundColor3 = BACKGROUND_COLOR,
            Image = "rbxassetid://6031094670",
            ImageColor3 = ACCENT_COLOR,
            Parent = UILibraryGui
        })
        createRoundedCorner(MobileToggle, 8)
        createStroke(MobileToggle, ACCENT_COLOR, 2, 0)
        
        -- Make mobile toggle draggable
        makeOnlyTopDraggable(MobileToggle, MobileToggle)
        
        MobileToggle.MouseButton1Click:Connect(function()
            MainFrame.Visible = not MainFrame.Visible
        end)
    end
    
    -- Make only the top part of the UI draggable
    makeOnlyTopDraggable(MainFrame, TopBar)
    makeOnlyTopDraggable(MainFrame, SidebarTitle)
    
    -- Tab system
    local Tabs = {}
    local SelectedTab = nil
    local UIElements = {}
    
    local Window = {}
    
    -- Add search functionality
    SearchInput.Changed:Connect(function(prop)
        if prop == "Text" then
            local searchText = string.lower(SearchInput.Text)
            
            -- Search through all UI elements
            for _, tab in pairs(Tabs) do
                local tabContent = tab.Content
                
                for _, section in ipairs(tabContent:GetChildren()) do
                    if section:IsA("Frame") and section.Name:match("Section$") then
                        local sectionContent = section:FindFirstChild("Content")
                        local sectionTitle = section:FindFirstChild("Title")
                        local sectionMatch = false
                        
                        -- Check if section title matches search
                        if sectionTitle and string.find(string.lower(sectionTitle.Text), searchText) then
                            sectionMatch = true
                        end
                        
                        if sectionContent then
                            for _, element in ipairs(sectionContent:GetChildren()) do
                                if element:IsA("Frame") then
                                    local label = element:FindFirstChild("Label")
                                    
                                    if label and label:IsA("TextLabel") then
                                        if searchText == "" or sectionMatch or string.find(string.lower(label.Text), searchText) then
                                            element.Visible = true
                                        else
                                            element.Visible = false
                                        end
                                    end
                                end
                            end
                            
                            -- Show section if search is empty or section title matches
                            if sectionTitle then
                                sectionTitle.Visible = (searchText == "" or sectionMatch)
                            end
                        end
                    end
                end
            end
        end
    end)
    
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
        createStroke(TabButtonBackground, Color3.fromRGB(50, 50, 50), 1, 1)
        
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
        local TabContent = createInstance("Frame", {
            Name = name .. "Content",
            Size = UDim2.new(1, -20, 0, 0),
            Position = UDim2.new(0, 10, 0, 0),
            BackgroundTransparency = 1,
            AutomaticSize = Enum.AutomaticSize.Y,
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
            if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
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
                createStroke(ToggleButton, Color3.fromRGB(50, 50, 50), 1, 0)
                
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
                    
                    -- Update config
                    _G.UILibraryConfig[toggleName] = state
                end
                
                ToggleButton.InputBegan:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                        updateToggle()
                    end
                end)
                
                -- Register UI element for config saving
                local toggleElement = {
                    Type = "Toggle",
                    Name = toggleName,
                    Section = sectionName,
                    Tab = name,
                    Get = function()
                        return state
                    end,
                    Set = function(value)
                        if state ~= value then
                            state = not state -- We need to flip it because updateToggle will flip it again
                            updateToggle()
                        end
                    end
                }
                
                table.insert(UIElements, toggleElement)
                
                return toggleElement
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
                    Size = UDim2.new(1, -50, 0, 20),
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
                    Size = UDim2.new(0, 40, 0, 20),
                    Position = UDim2.new(1, -40, 0, 0),
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
                createStroke(SliderBackground, Color3.fromRGB(50, 50, 50), 1, 0)
                
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
                createStroke(SliderKnob, Color3.fromRGB(50, 50, 50), 1, 0)
                
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
                    
                    -- Update config
                    _G.UILibraryConfig[sliderName] = value
                end
                
                SliderBackground.InputBegan:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
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
                    if (input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch) then
                        isDragging = false
                    end
                end)
                
                UserInputService.InputChanged:Connect(function(input)
                    if isDragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
                        local mousePos = input.Position.X
                        local sliderPos = SliderBackground.AbsolutePosition.X
                        local sliderSize = SliderBackground.AbsoluteSize.X
                        
                        local percent = math.clamp((mousePos - sliderPos) / sliderSize, 0, 1)
                        local newValue = min + (max - min) * percent
                        
                        updateSlider(newValue)
                    end
                end)
                
                -- Register UI element for config saving
                local sliderElement = {
                    Type = "Slider",
                    Name = sliderName,
                    Section = sectionName,
                    Tab = name,
                    Min = min,
                    Max = max,
                    Get = function()
                        return value
                    end,
                    Set = function(newValue)
                        updateSlider(newValue)
                    end
                }
                
                table.insert(UIElements, sliderElement)
                
                return sliderElement
            end
            
            function SectionObj:CreateDropdown(dropdownName, options, callback)
                local items = options.items or {}
                local default = options.default or items[1] or ""
                
                -- Increase the vertical spacing to prevent overlap with textboxes
                local Dropdown = createInstance("Frame", {
                    Name = dropdownName .. "Dropdown",
                    Size = UDim2.new(1, 0, 0, 60), -- Increased height to prevent overlap
                    BackgroundTransparency = 1,
                    Parent = SectionContent,
                    ZIndex = 1
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
                    Parent = Dropdown,
                    ZIndex = 1
                })
                
                local DropdownButton = createInstance("TextButton", {
                    Name = "Button",
                    Size = UDim2.new(1, 0, 0, 30),
                    Position = UDim2.new(0, 0, 0, 20),
                    BackgroundColor3 = DROPDOWN_BACKGROUND,
                    Text = "",
                    AutoButtonColor = false,
                    ZIndex = 2,
                    Parent = Dropdown
                })
                createRoundedCorner(DropdownButton, 4)
                createStroke(DropdownButton, Color3.fromRGB(50, 50, 50), 1, 0)
                
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
                    ZIndex = 2,
                    Parent = DropdownButton
                })
                
                local DropdownArrow = createInstance("ImageLabel", {
                    Name = "Arrow",
                    Size = UDim2.new(0, 16, 0, 16),
                    Position = UDim2.new(1, -26, 0.5, -8),
                    BackgroundTransparency = 1,
                    Image = "rbxassetid://6031091004",
                    ImageColor3 = SECONDARY_TEXT_COLOR,
                    ZIndex = 2,
                    Parent = DropdownButton
                })
                
                -- Create dropdown menu as a separate GUI to ensure it's always on top
                local DropdownMenu = createInstance("Frame", {
                    Name = "Menu",
                    Size = UDim2.new(1, 0, 0, 0),
                    Position = UDim2.new(0, 0, 1, 5),
                    BackgroundColor3 = DROPDOWN_BACKGROUND,
                    ClipsDescendants = true,
                    Visible = false,
                    ZIndex = 9999, -- Extremely high Z-index to ensure it's on top of everything
                    Parent = CoreGui -- Parent directly to CoreGui instead of the dropdown button
                })
                createRoundedCorner(DropdownMenu, 4)
                createStroke(DropdownMenu, Color3.fromRGB(50, 50, 50), 1, 0)

                -- Store reference to the dropdown button for positioning
                local dropdownButtonRef = DropdownButton

                -- Update the dropdown list and its children to have extremely high Z-index
                local DropdownList = createInstance("Frame", {
                    Name = "List",
                    Size = UDim2.new(1, 0, 1, 0),
                    BackgroundTransparency = 1,
                    ZIndex = 9999,
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
                
                -- Update the updateDropdown function to properly position the menu
                local function updateDropdown()
                    isOpen = not isOpen
                    
                    if isOpen then
                        -- Position the menu at the dropdown button's position
                        DropdownMenu.Position = UDim2.new(
                            0, 
                            dropdownButtonRef.AbsolutePosition.X,
                            0, 
                            dropdownButtonRef.AbsolutePosition.Y + dropdownButtonRef.AbsoluteSize.Y + 5
                        )
                        DropdownMenu.Size = UDim2.new(0, dropdownButtonRef.AbsoluteSize.X, 0, 0)
                        DropdownMenu.Visible = true
                        
                        -- Animate the menu opening
                        local menuHeight = math.min(#items * 30, 150)
                        createTween(DropdownMenu, {Size = UDim2.new(0, dropdownButtonRef.AbsoluteSize.X, 0, menuHeight)}):Play()
                        createTween(DropdownArrow, {Rotation = 180}):Play()
                    else
                        -- Animate the menu closing
                        createTween(DropdownMenu, {Size = UDim2.new(0, dropdownButtonRef.AbsoluteSize.X, 0, 0)}):Play()
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
                        Size = UDim2.new(1, -10, 0, 25),
                        BackgroundColor3 = BUTTON_COLOR,
                        Text = item,
                        TextColor3 = item == selectedItem and ACCENT_COLOR or SECONDARY_TEXT_COLOR,
                        TextSize = 14,
                        Font = Enum.Font.Gotham,
                        ZIndex = 10000, -- Even higher Z-index for the buttons
                        Parent = DropdownList
                    })
                    createRoundedCorner(ItemButton, 4)
                    
                    ItemButton.MouseEnter:Connect(function()
                        if item ~= selectedItem then
                            ItemButton.BackgroundColor3 = BUTTON_HOVER_COLOR
                        end
                    end)
                    
                    ItemButton.MouseLeave:Connect(function()
                        if item ~= selectedItem then
                            ItemButton.BackgroundColor3 = BUTTON_COLOR
                        end
                    end)
                    
                    ItemButton.MouseButton1Click:Connect(function()
                        if selectedItem ~= item then
                            -- Update selected item
                            for _, child in pairs(DropdownList:GetChildren()) do
                                if child:IsA("TextButton") then
                                    child.TextColor3 = SECONDARY_TEXT_COLOR
                                    child.BackgroundColor3 = BUTTON_COLOR
                                end
                            end
                            
                            selectedItem = item
                            DropdownText.Text = item
                            ItemButton.TextColor3 = ACCENT_COLOR
                            
                            if callback then
                                callback(item)
                            end
                            
                            -- Update config
                            _G.UILibraryConfig[dropdownName] = item
                        end
                        
                        updateDropdown()
                    end)
                end
                
                DropdownButton.MouseButton1Click:Connect(function()
                    updateDropdown()
                end)
                
                -- Close dropdown when clicking elsewhere
                UserInputService.InputBegan:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                        local mousePos = UserInputService:GetMouseLocation()
                        if isOpen and not (
                            mousePos.X >= DropdownMenu.AbsolutePosition.X and
                            mousePos.X <= DropdownMenu.AbsolutePosition.X + DropdownMenu.AbsoluteSize.X and
                            mousePos.Y >= DropdownMenu.AbsolutePosition.Y and
                            mousePos.Y <= DropdownMenu.AbsolutePosition.Y + DropdownMenu.AbsoluteSize.Y
                        ) and not (
                            mousePos.X >= dropdownButtonRef.AbsolutePosition.X and
                            mousePos.X <= dropdownButtonRef.AbsolutePosition.X + dropdownButtonRef.AbsoluteSize.X and
                            mousePos.Y >= dropdownButtonRef.AbsolutePosition.Y and
                            mousePos.Y <= dropdownButtonRef.AbsolutePosition.Y + dropdownButtonRef.AbsoluteSize.Y
                        ) then
                            updateDropdown()
                        end
                    end
                end)
                
                -- Register UI element for config saving
                local dropdownElement = {
                    Type = "Dropdown",
                    Name = dropdownName,
                    Section = sectionName,
                    Tab = name,
                    Items = items,
                    Get = function()
                        return selectedItem
                    end,
                    Set = function(item)
                        if table.find(items, item) and selectedItem ~= item then
                            selectedItem = item
                            DropdownText.Text = item
                            
                            for _, child in pairs(DropdownList:GetChildren()) do
                                if child:IsA("TextButton") and child.Text == item then
                                    child.TextColor3 = ACCENT_COLOR
                                elseif child:IsA("TextButton") then
                                    child.TextColor3 = SECONDARY_TEXT_COLOR
                                end
                            end
                            
                            if callback then
                                callback(item)
                            end
                        end
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
                                Size = UDim2.new(1, -10, 0, 25),
                                BackgroundColor3 = BUTTON_COLOR,
                                Text = item,
                                TextColor3 = item == selectedItem and ACCENT_COLOR or SECONDARY_TEXT_COLOR,
                                TextSize = 14,
                                Font = Enum.Font.Gotham,
                                ZIndex = 101,
                                Parent = DropdownList
                            })
                            createRoundedCorner(ItemButton, 4)
                            
                            ItemButton.MouseEnter:Connect(function()
                                if item ~= selectedItem then
                                    ItemButton.BackgroundColor3 = BUTTON_HOVER_COLOR
                                end
                            end)
                            
                            ItemButton.MouseLeave:Connect(function()
                                if item ~= selectedItem then
                                    ItemButton.BackgroundColor3 = BUTTON_COLOR
                                end
                            end)
                            
                            ItemButton.MouseButton1Click:Connect(function()
                                if selectedItem ~= item then
                                    -- Update selected item
                                    for _, child in pairs(DropdownList:GetChildren()) do
                                        if child:IsA("TextButton") then
                                            child.TextColor3 = SECONDARY_TEXT_COLOR
                                            child.BackgroundColor3 = BUTTON_COLOR
                                        end
                                    end
                                    
                                    selectedItem = item
                                    DropdownText.Text = item
                                    ItemButton.TextColor3 = ACCENT_COLOR
                                    
                                    if callback then
                                        callback(item)
                                    end
                                end
                                
                                updateDropdown()
                            end)
                        end
                    end
                }
                
                table.insert(UIElements, dropdownElement)
                
                return dropdownElement
            end
            
            function SectionObj:CreateTextBox(boxName, defaultText, placeholder, callback)
                local TextBox = createInstance("Frame", {
                    Name = boxName .. "TextBox",
                    Size = UDim2.new(1, 0, 0, 50),
                    BackgroundTransparency = 1,
                    Parent = SectionContent,
                    ZIndex = 1
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
                    Parent = TextBox,
                    ZIndex = 1
                })
                
                local TextBoxFrame = createInstance("Frame", {
                    Name = "Frame",
                    Size = UDim2.new(1, 0, 0, 30),
                    Position = UDim2.new(0, 0, 0, 20),
                    BackgroundColor3 = DROPDOWN_BACKGROUND,
                    Parent = TextBox,
                    ZIndex = 1
                })
                createRoundedCorner(TextBoxFrame, 4)
                createStroke(TextBoxFrame, Color3.fromRGB(50, 50, 50), 1, 0)
                
                local EditIcon = createInstance("ImageLabel", {
                    Name = "EditIcon",
                    Size = UDim2.new(0, 16, 0, 16),
                    Position = UDim2.new(1, -26, 0.5, -8),
                    BackgroundTransparency = 1,
                    Image = "rbxassetid://6764432408",
                    ImageColor3 = SECONDARY_TEXT_COLOR,
                    Parent = TextBoxFrame,
                    ZIndex = 1
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
                    Parent = TextBoxFrame,
                    ZIndex = 1
                })
                
                TextBoxInput.FocusLost:Connect(function(enterPressed)
                    if callback then
                        callback(TextBoxInput.Text, enterPressed)
                    end
                    
                    -- Update config
                    _G.UILibraryConfig[boxName] = TextBoxInput.Text
                end)
                
                -- Register UI element for config saving
                local textboxElement = {
                    Type = "TextBox",
                    Name = boxName,
                    Section = sectionName,
                    Tab = name,
                    Get = function()
                        return TextBoxInput.Text
                    end,
                    Set = function(text)
                        TextBoxInput.Text = text
                    end
                }
                
                table.insert(UIElements, textboxElement)
                
                return textboxElement
            end
            
            function SectionObj:CreateColorPicker(pickerName, defaultColor, callback)
                local ColorPicker = createInstance("Frame", {
                    Name = pickerName .. "ColorPicker",
                    Size = UDim2.new(1, 0, 0, 30),
                    BackgroundTransparency = 1,
                    Parent = SectionContent
                })
                
                local ColorPickerLabel = createInstance("TextLabel", {
                    Name = "Label",
                    Size = UDim2.new(1, -40, 1, 0),
                    BackgroundTransparency = 1,
                    Text = pickerName,
                    TextColor3 = SECONDARY_TEXT_COLOR,
                    TextSize = 14,
                    Font = Enum.Font.Gotham,
                    TextXAlignment = Enum.TextXAlignment.Left,
                    Parent = ColorPicker
                })
                
                local ColorDisplay = createInstance("TextButton", {
                    Name = "Display",
                    Size = UDim2.new(0, 24, 0, 24),
                    Position = UDim2.new(1, -30, 0.5, -12),
                    BackgroundColor3 = defaultColor or Color3.fromRGB(255, 0, 0),
                    Text = "",
                    AutoButtonColor = false,
                    Parent = ColorPicker
                })
                createRoundedCorner(ColorDisplay, 4)
                createStroke(ColorDisplay, Color3.fromRGB(50, 50, 50), 1, 0)
                
                -- Create the simple color picker
                local colorPickerInstance = createColorPicker(ColorDisplay, defaultColor or Color3.fromRGB(255, 0, 0), function(color)
                    ColorDisplay.BackgroundColor3 = color
                    if callback then
                        callback(color)
                    end
                    
                    -- Update config
                    _G.UILibraryConfig[pickerName] = {
                        R = color.R,
                        G = color.G,
                        B = color.B
                    }
                end)
                
                -- Register UI element for config saving
                local colorPickerElement = {
                    Type = "ColorPicker",
                    Name = pickerName,
                    Section = sectionName,
                    Tab = name,
                    Get = function()
                        return ColorDisplay.BackgroundColor3
                    end,
                    Set = function(color)
                        ColorDisplay.BackgroundColor3 = color
                        colorPickerInstance.SetColor(color)
                        
                        if callback then
                            callback(color)
                        end
                    end
                }
                
                table.insert(UIElements, colorPickerElement)
                
                return colorPickerElement
            end
            
            function SectionObj:CreateButton(buttonName, callback)
                local Button = createInstance("Frame", {
                    Name = buttonName .. "Button",
                    Size = UDim2.new(1, 0, 0, 30),
                    BackgroundTransparency = 1,
                    Parent = SectionContent
                })
                
                local ButtonFrame = createInstance("TextButton", {
                    Name = "Frame",
                    Size = UDim2.new(1, 0, 1, 0),
                    BackgroundColor3 = BUTTON_COLOR,
                    Text = "",
                    AutoButtonColor = false,
                    Parent = Button
                })
                createRoundedCorner(ButtonFrame, 4)
                createStroke(ButtonFrame, Color3.fromRGB(50, 50, 50), 1, 0)
                
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
                
                ButtonFrame.MouseButton1Click:Connect(function()
                    createTween(ButtonFrame, {BackgroundColor3 = BUTTON_HOVER_COLOR}):Play()
                    
                    if callback then
                        callback()
                    end
                    
                    delay(0.2, function()
                        createTween(ButtonFrame, {BackgroundColor3 = BUTTON_COLOR}):Play()
                    end)
                end)
                
                ButtonFrame.MouseEnter:Connect(function()
                    createTween(ButtonFrame, {BackgroundColor3 = BUTTON_HOVER_COLOR}):Play()
                end)
                
                ButtonFrame.MouseLeave:Connect(function()
                    createTween(ButtonFrame, {BackgroundColor3 = BUTTON_COLOR}):Play()
                end)
                
                return Button
            end
            
            return SectionObj
        end
        
        return Tab
    end
    
    -- ESP Functions
    function Window:CreateESP()
        -- Initialize ESP
        for _, player in ipairs(Players:GetPlayers()) do
            if player ~= LocalPlayer then
                createESPObject(player)
            end
        end
        
        Players.PlayerAdded:Connect(function(player)
            createESPObject(player)
        end)
        
        Players.PlayerRemoving:Connect(function(player)
            removeESPObject(player)
        end)
        
        -- Update ESP
        RunService.RenderStepped:Connect(updateESP)
        
        -- Return ESP settings
        return {
            Enabled = function(state)
                ESPEnabled = state
            end,
            BoxEnabled = function(state)
                ESPSettings.BoxEnabled = state
            end,
            NameEnabled = function(state)
                ESPSettings.NameEnabled = state
            end,
            DistanceEnabled = function(state)
                ESPSettings.DistanceEnabled = state
            end,
            TracerEnabled = function(state)
                ESPSettings.TracerEnabled = state
            end,
            HealthEnabled = function(state)
                ESPSettings.HealthEnabled = state
            end,
            TeamEnabled = function(state)
                ESPSettings.TeamEnabled = state
            end,
            TeamColor = function(state)
                ESPSettings.TeamColor = state
            end,
            VisibleCheck = function(state)
                ESPSettings.VisibleCheck = state
            end,
            BoxColor = function(color)
                ESPSettings.BoxColor = color
                for _, esp in pairs(ESPObjects) do
                    if esp.Box then
                        esp.Box.Color = color
                    end
                end
            end,
            NameColor = function(color)
                ESPSettings.NameColor = color
                for _, esp in pairs(ESPObjects) do
                    if esp.Name then
                        esp.Name.Color = color
                    end
                end
            end,
            DistanceColor = function(color)
                ESPSettings.DistanceColor = color
                for _, esp in pairs(ESPObjects) do
                    if esp.Distance then
                        esp.Distance.Color = color
                    end
                end
            end,
            TracerColor = function(color)
                ESPSettings.TracerColor = color
                for _, esp in pairs(ESPObjects) do
                    if esp.Tracer then
                        esp.Tracer.Color = color
                    end
                end
            end,
            VisibleColor = function(color)
                ESPSettings.VisibleColor = color
            end,
            NotVisibleColor = function(color)
                ESPSettings.NotVisibleColor = color
            end,
            MaxDistance = function(distance)
                ESPSettings.MaxDistance = distance
            end,
            TextSize = function(size)
                ESPSettings.TextSize = size
                for _, esp in pairs(ESPObjects) do
                    if esp.Name then esp.Name.Size = size end
                    if esp.Distance then esp.Distance.Size = size end
                    if esp.Visible then esp.Visible.Size = size end
                end
            end,
            BoxThickness = function(thickness)
                ESPSettings.BoxThickness = thickness
                for _, esp in pairs(ESPObjects) do
                    if esp.Box then
                        esp.Box.Thickness = thickness
                        esp.BoxOutline.Thickness = thickness + 1
                    end
                end
            end,
            TracerThickness = function(thickness)
                ESPSettings.TracerThickness = thickness
                for _, esp in pairs(ESPObjects) do
                    if esp.Tracer then
                        esp.Tracer.Thickness = thickness
                    end
                end
            end,
            TracerOrigin = function(origin)
                if origin == "Bottom" or origin == "Top" or origin == "Mouse" then
                    ESPSettings.TracerOrigin = origin
                end
            end
        }
    end
    
    -- Configuration functions
    function Window:SaveConfig(name)
        return saveConfig(name)
    end
    
    function Window:LoadConfig(name)
        local configData = loadConfig(name)
        if not configData then
            return false
        end
        
        _G.UILibraryConfig = configData
        
        for _, element in ipairs(UIElements) do
            local value = configData[element.Name]
            
            if value ~= nil then
                if element.Type == "ColorPicker" and type(value) == "table" then
                    -- Convert table back to Color3
                    element.Set(Color3.new(value.R, value.G, value.B))
                else
                    element.Set(value)
                end
            end
        end
        
        return true
    end
    
    function Window:GetConfigList()
        return getConfigList()
    end
    
    return Window
end

return UILibrary
