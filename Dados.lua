-- Services
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local TeleportService = game:GetService("TeleportService")
local HttpService = game:GetService("HttpService")
local RunService = game:GetService("RunService")

-- Constants
local GUI_CONFIG = {
    MAIN_SIZE = UDim2.new(0, 280, 0, 275),
    MINIMIZED_SIZE = UDim2.new(0, 280, 0, 40),
    TITLE = "🧠 Steal A Brainrot",
    COLORS = {
        BACKGROUND = Color3.fromRGB(25, 25, 35),
        TITLE = Color3.fromRGB(255, 100, 150),
        STEAL = Color3.fromRGB(255, 60, 60),
        DOWN = Color3.fromRGB(60, 150, 255),
        MARK = Color3.fromRGB(60, 255, 60),
        HOP = Color3.fromRGB(255, 165, 0)
    },
    BUTTON_HEIGHT = 45,
    BUTTON_SPACING = 10
}

local function createButton(parent, name, text, position, color)
    local button = Instance.new("TextButton")
    button.Name = name
    button.Size = UDim2.new(1, 0, 0, GUI_CONFIG.BUTTON_HEIGHT)
    button.Position = position
    button.BackgroundColor3 = color
    button.BorderSizePixel = 0
    button.Text = text
    button.TextColor3 = Color3.fromRGB(255, 255, 255)
    button.TextScaled = true
    button.Font = Enum.Font.GothamBold
    button.Parent = parent
    
    -- Add corner
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 8)
    corner.Parent = button
    
    -- Add stroke
    local stroke = Instance.new("UIStroke")
    stroke.Color = color
    stroke.Thickness = 1
    stroke.Transparency = 0.5
    stroke.Parent = button
    
    -- Add hover effect
    local hoverTween = TweenService:Create(button, TweenInfo.new(0.2), {
        BackgroundColor3 = Color3.new(
            math.min(color.R * 1.3, 1),
            math.min(color.G * 1.3, 1),
            math.min(color.B * 1.3, 1)
        )
    })
    
    local normalTween = TweenService:Create(button, TweenInfo.new(0.2), {
        BackgroundColor3 = color
    })
    
    button.MouseEnter:Connect(function()
        hoverTween:Play()
    end)
    
    button.MouseLeave:Connect(function()
        normalTween:Play()
    end)
    
    return button
end

local function createMainFrame()
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "StealBrainRotGui"
    screenGui.ResetOnSpawn = false
    screenGui.Parent = game:GetService("Players").LocalPlayer:WaitForChild("PlayerGui")

    local mainFrame = Instance.new("Frame")
    mainFrame.Name = "MainFrame"
    mainFrame.Size = GUI_CONFIG.MAIN_SIZE
    mainFrame.Position = UDim2.new(0.5, -140, 0.5, -137.5)
    mainFrame.BackgroundColor3 = GUI_CONFIG.COLORS.BACKGROUND
    mainFrame.BorderSizePixel = 0
    mainFrame.Parent = screenGui
    
    -- Add corner
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 12)
    corner.Parent = mainFrame
    
    -- Add gradient
    local gradient = Instance.new("UIGradient")
    gradient.Color = ColorSequence.new{
        ColorSequenceKeypoint.new(0, Color3.fromRGB(40, 40, 60)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(20, 20, 30))
    }
    gradient.Rotation = 45
    gradient.Parent = mainFrame
    
    -- Create title frame
    local titleFrame = Instance.new("Frame")
    titleFrame.Name = "TitleFrame"
    titleFrame.Size = UDim2.new(1, 0, 0, 40)
    titleFrame.BackgroundTransparency = 1
    titleFrame.Parent = mainFrame
    
    -- Create title label
    local titleLabel = Instance.new("TextLabel")
    titleLabel.Name = "TitleLabel"
    titleLabel.Size = UDim2.new(1, -40, 1, 0)
    titleLabel.BackgroundTransparency = 1
    titleLabel.Text = GUI_CONFIG.TITLE
    titleLabel.TextColor3 = GUI_CONFIG.COLORS.TITLE
    titleLabel.TextScaled = true
    titleLabel.Font = Enum.Font.GothamBold
    titleLabel.Parent = titleFrame
    
    -- Add title glow
    local titleGlow = Instance.new("UIStroke")
    titleGlow.Color = GUI_CONFIG.COLORS.TITLE
    titleGlow.Thickness = 1
    titleGlow.Transparency = 0.3
    titleGlow.Parent = titleLabel
    
    -- Create minimize button
    local minimizeButton = Instance.new("TextButton")
    minimizeButton.Name = "MinimizeButton"
    minimizeButton.Size = UDim2.new(0, 30, 0, 30)
    minimizeButton.Position = UDim2.new(1, -35, 0, 5)
    minimizeButton.BackgroundColor3 = GUI_CONFIG.COLORS.STEAL
    minimizeButton.BorderSizePixel = 0
    minimizeButton.Text = "−"
    minimizeButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    minimizeButton.TextScaled = true
    minimizeButton.Font = Enum.Font.GothamBold
    minimizeButton.Parent = titleFrame
    
    local minCorner = Instance.new("UICorner")
    minCorner.CornerRadius = UDim.new(0, 15)
    minCorner.Parent = minimizeButton
    
    -- Create button container
    local buttonContainer = Instance.new("Frame")
    buttonContainer.Name = "ButtonContainer"
    buttonContainer.Size = UDim2.new(1, -20, 1, -60)
    buttonContainer.Position = UDim2.new(0, 10, 0, 50)
    buttonContainer.BackgroundTransparency = 1
    buttonContainer.Parent = mainFrame
    
    -- Create buttons
    local stealButton = createButton(buttonContainer, "StealButton", "🔥 STEAL", 
        UDim2.new(0, 0, 0, 0), GUI_CONFIG.COLORS.STEAL)
    
    local goDownButton = createButton(buttonContainer, "GoDownButton", "⬇️ GO DOWN",
        UDim2.new(0, 0, 0, 55), GUI_CONFIG.COLORS.DOWN)
    
    local markButton = createButton(buttonContainer, "MarkButton", "📍 MARK",
        UDim2.new(0, 0, 0, 110), GUI_CONFIG.COLORS.MARK)
    
    local serverHopButton = createButton(buttonContainer, "ServerHopButton", "🔄 SERVER HOP",
        UDim2.new(0, 0, 0, 165), GUI_CONFIG.COLORS.HOP)
    
    -- Animation for appearing
    mainFrame.Size = UDim2.new(0, 0, 0, 0)
    local appearTween = TweenService:Create(mainFrame, TweenInfo.new(0.4, Enum.EasingStyle.Back), {
        Size = GUI_CONFIG.MAIN_SIZE
    })
    appearTween:Play()
    
    return {
        screenGui = screenGui,
        mainFrame = mainFrame,
        titleFrame = titleFrame,
        buttonContainer = buttonContainer,
        buttons = {
            minimize = minimizeButton,
            steal = stealButton,
            goDown = goDownButton,
            mark = markButton,
            hop = serverHopButton
        }
    }
end

-- Create the GUI
local gui = createMainFrame()

-- Setup functionality
local player = Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local rootPart = character:WaitForChild("HumanoidRootPart")
local markPosition = nil
local isStealActive = false
local isMinimized = false

-- Function implementations (steal, mark, etc.) go here...
-- (Keep the original functionality from your previous script)

-- Setup minimize functionality
gui.buttons.minimize.MouseButton1Click:Connect(function()
    isMinimized = not isMinimized
    local targetSize = isMinimized and GUI_CONFIG.MINIMIZED_SIZE or GUI_CONFIG.MAIN_SIZE
    local targetText = isMinimized and "+" or "−"
    
    TweenService:Create(gui.mainFrame, TweenInfo.new(0.3, Enum.EasingStyle.Quad), {
        Size = targetSize
    }):Play()
    
    gui.buttons.minimize.Text = targetText
    gui.buttonContainer.Visible = not isMinimized
end)

-- Setup dragging
local dragging = false
local dragStart = nil
local startPos = nil

gui.titleFrame.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or
       input.UserInputType == Enum.UserInputType.Touch then
        dragging = true
        dragStart = input.Position
        startPos = gui.mainFrame.Position
    end
end)

gui.titleFrame.InputChanged:Connect(function(input)
    if dragging and 
       (input.UserInputType == Enum.UserInputType.MouseMovement or
        input.UserInputType == Enum.UserInputType.Touch) then
        local delta = input.Position - dragStart
        gui.mainFrame.Position = UDim2.new(
            startPos.X.Scale,
            startPos.X.Offset + delta.X,
            startPos.Y.Scale,
            startPos.Y.Offset + delta.Y
        )
    end
end)

UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or
       input.UserInputType == Enum.UserInputType.Touch then
        dragging = false
    end
end)
