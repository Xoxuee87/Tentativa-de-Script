--// VIMTO HUB //--

if game:GetService("CoreGui"):FindFirstChild("VimtoHub") then
    game:GetService("CoreGui").VimtoHub:Destroy()
end

-- Variáveis
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local TeleportService = game:GetService("TeleportService")
local player = Players.LocalPlayer

-- Estados
local flyEnabled, flyConnection, flyBodyVelocity
local flySpeed = 50
local noclipEnabled, noclipConnection
local noclipStateMap = {}
local espPlayersEnabled = false
local espChestsEnabled = false

-- Cores
local bg = Color3.fromRGB(20, 20, 20)
local accent = Color3.fromRGB(255, 100, 150)
local textColor = Color3.new(1, 1, 1)

-- UI principal
local gui = Instance.new("ScreenGui", game:GetService("CoreGui"))
gui.Name = "VimtoHub"
local mainFrame = Instance.new("Frame")
mainFrame.Size = UDim2.new(0, 600, 0, 400)
mainFrame.Position = UDim2.new(0.5, -300, 0.5, -200)
mainFrame.BackgroundColor3 = bg
mainFrame.Active = true
mainFrame.Draggable = true
mainFrame.Parent = gui

Instance.new("UICorner", mainFrame).CornerRadius = UDim.new(0, 12)
Instance.new("UIStroke", mainFrame).Color = accent

local title = Instance.new("TextLabel", mainFrame)
title.Size = UDim2.new(1, 0, 0, 40)
title.BackgroundTransparency = 1
title.Text = "🍹 VIMTO HUB"
title.Font = Enum.Font.GothamBold
title.TextSize = 20
title.TextColor3 = accent

local tabFrame = Instance.new("Frame", mainFrame)
tabFrame.Size = UDim2.new(0, 120, 1, -40)
tabFrame.Position = UDim2.new(0, 0, 0, 40)
tabFrame.BackgroundTransparency = 1

local contentFrame = Instance.new("Frame", mainFrame)
contentFrame.Size = UDim2.new(1, -120, 1, -40)
contentFrame.Position = UDim2.new(0, 120, 0, 40)
contentFrame.BackgroundTransparency = 1

local tabButtons, currentTab = {}, nil

-- Função de tabs
local function createTab(name, icon, loadFunc)
    local btn = Instance.new("TextButton", tabFrame)
    btn.Size = UDim2.new(1, -10, 0, 40)
    btn.Position = UDim2.new(0, 5, 0, (#tabButtons * 45))
    btn.BackgroundColor3 = bg
    btn.Text = icon.." "..name
    btn.Font = Enum.Font.Gotham
    btn.TextSize = 14
    btn.TextColor3 = textColor
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 8)
    Instance.new("UIStroke", btn).Color = accent

    btn.MouseButton1Click:Connect(function()
        if currentTab then
            currentTab.BackgroundColor3 = bg
        end
        currentTab = btn
        btn.BackgroundColor3 = accent

        for _, c in pairs(contentFrame:GetChildren()) do
            c:Destroy()
        end
        loadFunc(contentFrame)
    end)

    table.insert(tabButtons, btn)
    return btn
end

-- Função util para botões
local function createButton(parent, text, callback)
    local btn = Instance.new("TextButton", parent)
    btn.Size = UDim2.new(1, -20, 0, 35)
    btn.Position = UDim2.new(0, 10, 0, #parent:GetChildren() * 40)
    btn.BackgroundColor3 = bg
    btn.Text = text
    btn.Font = Enum.Font.Gotham
    btn.TextSize = 14
    btn.TextColor3 = textColor
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 8)
    Instance.new("UIStroke", btn).Color = accent

    btn.MouseButton1Click:Connect(callback)
end

-- Player functions
local function toggleFly(state)
    flyEnabled = state
    if flyConnection then flyConnection:Disconnect(); flyConnection = nil end
    if flyBodyVelocity then flyBodyVelocity:Destroy(); flyBodyVelocity = nil end

    local character = player.Character
    local humanoid = character and character:FindFirstChildOfClass("Humanoid")
    local rootPart = character and character:FindFirstChild("HumanoidRootPart")
    if state and humanoid and rootPart then
        flyBodyVelocity = Instance.new("BodyVelocity")
        flyBodyVelocity.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
        flyBodyVelocity.Velocity = Vector3.new(0,0,0)
        flyBodyVelocity.Parent = rootPart

        flyConnection = RunService.Heartbeat:Connect(function()
            if not player.Character then return end
            local hrp = player.Character:FindFirstChild("HumanoidRootPart")
            local hum = player.Character:FindFirstChildOfClass("Humanoid")
            if not (hrp and hum) then return end

            local camera = workspace.CurrentCamera
            local move = hum.MoveDirection
            local look, right = camera.CFrame.LookVector, camera.CFrame.RightVector

            local vel = Vector3.new(0,0,0)
            if move.Magnitude > 0 then
                vel = (look * move.Z + right * move.X) * flySpeed
            end
            flyBodyVelocity.Velocity = vel
        end)
    end
end

local function toggleNoclip(state)
    noclipEnabled = state
    if noclipConnection then noclipConnection:Disconnect(); noclipConnection = nil end
    if state then
        noclipStateMap = {}
        noclipConnection = RunService.Stepped:Connect(function()
            for _, part in pairs(player.Character:GetDescendants()) do
                if part:IsA("BasePart") then
                    if noclipStateMap[part] == nil then
                        noclipStateMap[part] = part.CanCollide
                    end
                    part.CanCollide = false
                end
            end
        end)
    else
        for part, orig in pairs(noclipStateMap) do
            if part and part.Parent then
                part.CanCollide = orig
            end
        end
        noclipStateMap = {}
    end
end

-- Tabs
local function loadPlayerTab(frame)
    createButton(frame, "WalkSpeed +", function() player.Character.Humanoid.WalkSpeed += 10 end)
    createButton(frame, "WalkSpeed -", function() player.Character.Humanoid.WalkSpeed = math.max(0, player.Character.Humanoid.WalkSpeed - 10) end)
    createButton(frame, "JumpPower +", function() player.Character.Humanoid.JumpPower += 10 end)
    createButton(frame, "JumpPower -", function() player.Character.Humanoid.JumpPower = math.max(0, player.Character.Humanoid.JumpPower - 10) end)
    createButton(frame, "Toggle Fly", function() toggleFly(not flyEnabled) end)
    createButton(frame, "Toggle Noclip", function() toggleNoclip(not noclipEnabled) end)
end

local function loadVisualTab(frame)
    createButton(frame, "Toggle ESP Players", function() espPlayersEnabled = not espPlayersEnabled end)
    createButton(frame, "Toggle ESP Chests", function() espChestsEnabled = not espChestsEnabled end)
end

local function loadTeleportTab(frame)
    for _, plr in pairs(Players:GetPlayers()) do
        if plr ~= player then
            createButton(frame, "TP to "..plr.Name, function()
                local root = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
                local target = plr.Character and plr.Character:FindFirstChild("HumanoidRootPart")
                if root and target then
                    root.CFrame = target.CFrame + Vector3.new(0,2,0)
                end
            end)
        end
    end
end

local function loadMiscTab(frame)
    createButton(frame, "Rejoin", function() TeleportService:Teleport(game.PlaceId, player) end)
    createButton(frame, "Copy PlaceId", function()
        if setclipboard then setclipboard(tostring(game.PlaceId)) end
    end)
end

-- Criar abas
local playerTab = createTab("Player","👤",loadPlayerTab)
createTab("Visual","👁",loadVisualTab)
createTab("Teleport","📍",loadTeleportTab)
createTab("Misc","⚙️",loadMiscTab)

-- Selecionar Player como inicial
playerTab.BackgroundColor3 = accent
currentTab = playerTab
loadPlayerTab(contentFrame)

-- Limpeza ao respawn
player.CharacterRemoving:Connect(function()
    if flyConnection then flyConnection:Disconnect(); flyConnection=nil end
    if flyBodyVelocity then flyBodyVelocity:Destroy(); flyBodyVelocity=nil end
    if noclipConnection then noclipConnection:Disconnect(); noclipConnection=nil end
    noclipStateMap = {}
end)
