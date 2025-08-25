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
    }
}

local STEAL_CONFIG = {
    STEP_SIZE = 0.85,
    STEP_DELAY = 0.10,
    VERTICAL_OFFSET = 200
}

-- Class definition
local StealBrainrot = {}
StealBrainrot.__index = StealBrainrot

function StealBrainrot.new()
    local self = setmetatable({}, StealBrainrot)
    self.player = Players.LocalPlayer
    self.markPosition = nil
    self.isStealActive = false
    self.isMinimized = false
    
    self:initializeCharacter()
    self:createGui()
    self:setupConnections()
    
    return self
end

function StealBrainrot:initializeCharacter()
    self.character = self.player.Character or self.player.CharacterAdded:Wait()
    self.rootPart = self.character:WaitForChild("HumanoidRootPart")
end

function StealBrainrot:createGui()
    self.gui = {}
    
    -- Create main GUI elements
    self.gui.screenGui = Instance.new("ScreenGui")
    self.gui.screenGui.Name = "StealBrainRotGui"
    self.gui.screenGui.ResetOnSpawn = false
    self.gui.screenGui.Parent = self.player:WaitForChild("PlayerGui")
    
    -- Create main frame with gradient
    self.gui.mainFrame = self:createMainFrame()
    self.gui.titleFrame = self:createTitleFrame()
    self.gui.buttonContainer = self:createButtonContainer()
    
    -- Create buttons
    self:createActionButtons()
end

function StealBrainrot:createMainFrame()
    local frame = Instance.new("Frame")
    frame.Name = "MainFrame"
    frame.Size = GUI_CONFIG.MAIN_SIZE
    frame.Position = UDim2.new(0.5, -140, 0.5, -137.5)
    frame.BackgroundColor3 = GUI_CONFIG.COLORS.BACKGROUND
    frame.BorderSizePixel = 0
    frame.Parent = self.gui.screenGui
    
    -- Add corner and gradient
    Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 12)
    
    local gradient = Instance.new("UIGradient")
    gradient.Color = ColorSequence.new{
        ColorSequenceKeypoint.new(0, Color3.fromRGB(40, 40, 60)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(20, 20, 30))
    }
    gradient.Rotation = 45
    gradient.Parent = frame
    
    return frame
end

function StealBrainrot:steal()
    if not self.markPosition or self.isStealActive then return end
    
    self.isStealActive = true
    self.gui.buttons.steal.Text = "🔥 STEALING..."
    
    local currentPos = self.rootPart.Position
    local targetPos = self.markPosition
    local distance = (targetPos - currentPos).Magnitude
    local steps = math.ceil(distance / STEAL_CONFIG.STEP_SIZE)
    local stepSize = (targetPos - currentPos) / steps
    
    -- Create a new thread for the stealing process
    coroutine.wrap(function()
        for i = 1, steps do
            if not self.isStealActive then break end
            
            local nextPos = currentPos + (stepSize * i)
            self.rootPart.CFrame = CFrame.new(nextPos)
            task.wait(STEAL_CONFIG.STEP_DELAY)
        end
        
        if self.isStealActive then
            task.wait(0.1)
            self.rootPart.CFrame = CFrame.new(self.markPosition + Vector3.new(0, STEAL_CONFIG.VERTICAL_OFFSET, 0))
        end
        
        self.gui.buttons.steal.Text = "🔥 STEAL"
        self.isStealActive = false
    end)()
end

function StealBrainrot:mark()
    self.markPosition = self.rootPart.Position
    
    -- Remove existing mark if present
    local existingMark = workspace:FindFirstChild("PlayerMark")
    if existingMark then existingMark:Destroy() end
    
    -- Create new mark
    local markPart = Instance.new("Part")
    markPart.Name = "PlayerMark"
    markPart.Size = Vector3.new(4, 1, 4)
    markPart.Position = self.markPosition
    markPart.Material = Enum.Material.Neon
    markPart.BrickColor = BrickColor.new("Bright green")
    markPart.CanCollide = false
    markPart.Anchored = true
    markPart.Shape = Enum.PartType.Cylinder
    markPart.Parent = workspace
    
    -- Add pulsing effect
    TweenService:Create(
        markPart,
        TweenInfo.new(1, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut, -1, true),
        {Transparency = 0.5}
    ):Play()
end

function StealBrainrot:serverHop()
    self.gui.buttons.hop.Text = "🔄 HOPPING..."
    
    local function teleport()
        local placeId = game.PlaceId
        local servers = HttpService:JSONDecode(
            game:HttpGet(string.format(
                "https://games.roblox.com/v1/games/%d/servers/Public?sortOrder=Asc&limit=100",
                placeId
            ))
        )
        
        if servers and servers.data and #servers.data > 0 then
            for _, server in ipairs(servers.data) do
                if server.id ~= game.JobId and server.playing < server.maxPlayers then
                    return TeleportService:TeleportToPlaceInstance(placeId, server.id, self.player)
                end
            end
        end
        
        return TeleportService:Teleport(placeId, self.player)
    end
    
    local success = pcall(teleport)
    if not success then
        pcall(function()
            TeleportService:Teleport(game.PlaceId, self.player)
        end)
    end
    
    -- Reset button text after delay
    task.delay(5, function()
        if self.gui.buttons.hop then
            self.gui.buttons.hop.Text = "🔄 SERVER HOP"
        end
    end)
end

function StealBrainrot:setupConnections()
    -- Character respawn handling
    self.player.CharacterAdded:Connect(function(newCharacter)
        self.character = newCharacter
        self.rootPart = newCharacter:WaitForChild("HumanoidRootPart")
    end)
    
    -- GUI dragging functionality
    local dragging, dragStart, startPos
    
    local function updateDrag(input)
        if dragging then
            local delta = input.Position - dragStart
            self.gui.mainFrame.Position = UDim2.new(
                startPos.X.Scale,
                startPos.X.Offset + delta.X,
                startPos.Y.Scale,
                startPos.Y.Offset + delta.Y
            )
        end
    end
    
    self.gui.titleFrame.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or
           input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = self.gui.mainFrame.Position
        end
    end)
    
    self.gui.titleFrame.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or
           input.UserInputType == Enum.UserInputType.Touch then
            dragging = false
        end
    end)
    
    self.gui.titleFrame.InputChanged:Connect(updateDrag)
end

-- Initialize the script
local brainrot = StealBrainrot.new()
