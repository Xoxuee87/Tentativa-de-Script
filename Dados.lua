-- 💜 VIMTO HUB v9.5 | Final Release - FIXED + Correções

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local Lighting = game:GetService("Lighting")
local StarterGui = game:GetService("StarterGui")
local TeleportService = game:GetService("TeleportService")
local player = Players.LocalPlayer

-- Se já existir, destrói GUI anterior
if player.PlayerGui:FindFirstChild("VIMTO_HUB") then
    player.PlayerGui.VIMTO_HUB:Destroy()
end

-- GUI Base
local gui = Instance.new("ScreenGui")
gui.Name = "VIMTO_HUB"
gui.ResetOnSpawn = false
gui.Parent = player.PlayerGui

-- Cores
local accent = Color3.fromRGB(140, 0, 255)
local bg = Color3.fromRGB(20, 20, 20)
local white = Color3.fromRGB(255, 255, 255)

-- Variáveis globais
local espEnabled = false
local noclipEnabled = false
local flyEnabled = false
local fullbrightEnabled = false
local flySpeed = 50
local noclipConnection
local flyConnection
local flyBodyVelocity
local noclipStateMap = {}
local currentTab

-- Loading UI
local loading = Instance.new("Frame")
loading.Size = UDim2.new(0, 300, 0, 150)
loading.Position = UDim2.new(0.5, -150, 0.5, -75)
loading.BackgroundColor3 = bg
loading.BackgroundTransparency = 0.2
loading.BorderSizePixel = 0
Instance.new("UICorner", loading).CornerRadius = UDim.new(0, 12)
loading.Parent = gui

local title = Instance.new("TextLabel", loading)
title.Size = UDim2.new(1, 0, 0.5, 0)
title.Text = "💜 VIMTO HUB"
title.Font = Enum.Font.GothamBold
title.TextSize = 26
title.TextColor3 = white
title.BackgroundTransparency = 1

local subtitle = Instance.new("TextLabel", loading)
subtitle.Size = UDim2.new(1, 0, 0.5, 0)
subtitle.Position = UDim2.new(0, 0, 0.5, 0)
subtitle.Text = "Loading... Please Wait"
subtitle.Font = Enum.Font.Gotham
subtitle.TextSize = 14
subtitle.TextColor3 = Color3.fromRGB(200, 200, 200)
subtitle.BackgroundTransparency = 1

task.wait(2)
TweenService:Create(loading, TweenInfo.new(0.5), {BackgroundTransparency = 1}):Play()
TweenService:Create(title, TweenInfo.new(0.5), {TextTransparency = 1}):Play()
TweenService:Create(subtitle, TweenInfo.new(0.5), {TextTransparency = 1}):Play()
task.wait(0.6)
loading:Destroy()

-- Notificação
pcall(function()
    StarterGui:SetCore("SendNotification", {
        Title = "💜 VIMTO HUB",
        Text = "Enjoy Using VIMTO Hub!",
        Duration = 5
    })
end)

-- Botão de abrir
local openBtn = Instance.new("TextButton")
openBtn.Size = UDim2.new(0, 130, 0, 50)
openBtn.Position = UDim2.new(0, 20, 0.5, -25)
openBtn.BackgroundColor3 = bg
openBtn.Text = "💜 VIMTO HUB"
openBtn.TextColor3 = accent
openBtn.Font = Enum.Font.GothamBold
openBtn.TextSize = 16
Instance.new("UICorner", openBtn).CornerRadius = UDim.new(0, 12)
openBtn.Parent = gui

-- Frame principal
local mainFrame = Instance.new("Frame")
mainFrame.Size = UDim2.new(0, 500, 0, 380)
mainFrame.Position = UDim2.new(0.5, -250, 0.5, -190)
mainFrame.BackgroundColor3 = bg
mainFrame.BackgroundTransparency = 0.2
mainFrame.Visible = false
Instance.new("UICorner", mainFrame).CornerRadius = UDim.new(0, 14)
mainFrame.Parent = gui

-- Header
local header = Instance.new("Frame", mainFrame)
header.Size = UDim2.new(1, 0, 0, 50)
header.BackgroundColor3 = accent
header.BackgroundTransparency = 0.3
Instance.new("UICorner", header).CornerRadius = UDim.new(0, 14)

local headerLabel = Instance.new("TextLabel", header)
headerLabel.Size = UDim2.new(1, -60, 1, 0)
headerLabel.Position = UDim2.new(0, 10, 0, 0)
headerLabel.Text = "💜 VIMTO HUB"
headerLabel.TextColor3 = white
headerLabel.Font = Enum.Font.GothamBold
headerLabel.TextSize = 20
headerLabel.BackgroundTransparency = 1

local closeBtn = Instance.new("TextButton", header)
closeBtn.Size = UDim2.new(0, 40, 0, 40)
closeBtn.Position = UDim2.new(1, -50, 0.5, -20)
closeBtn.Text = "×"
closeBtn.Font = Enum.Font.GothamBold
closeBtn.TextSize = 18
closeBtn.TextColor3 = white
closeBtn.BackgroundColor3 = Color3.fromRGB(60, 0, 100)
Instance.new("UICorner", closeBtn).CornerRadius = UDim.new(1, 0)

closeBtn.MouseButton1Click:Connect(function()
    mainFrame.Visible = false
end)

-- Tabs
local tabFrame = Instance.new("Frame", mainFrame)
tabFrame.Size = UDim2.new(0, 100, 1, -60)
tabFrame.Position = UDim2.new(0, 5, 0, 55)
tabFrame.BackgroundTransparency = 1

local tabLayout = Instance.new("UIListLayout", tabFrame)
tabLayout.SortOrder = Enum.SortOrder.LayoutOrder
tabLayout.Padding = UDim.new(0, 5)

local contentFrame = Instance.new("ScrollingFrame", mainFrame)
contentFrame.Size = UDim2.new(1, -115, 1, -70)
contentFrame.Position = UDim2.new(0, 110, 0, 60)
contentFrame.BackgroundTransparency = 1
contentFrame.ScrollBarThickness = 4
contentFrame.ScrollBarImageColor3 = accent
contentFrame.AutomaticCanvasSize = Enum.AutomaticSize.Y
Instance.new("UIListLayout", contentFrame).Padding = UDim.new(0, 10)

-- Função criar tab
local function createTab(name, icon, callback)
    local tab = Instance.new("TextButton", tabFrame)
    tab.Size = UDim2.new(1, 0, 0, 35)
    tab.Text = icon .. " " .. name
    tab.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    tab.TextColor3 = white
    tab.Font = Enum.Font.GothamBold
    tab.TextSize = 12
    Instance.new("UICorner", tab).CornerRadius = UDim.new(0, 10)

    tab.MouseButton1Click:Connect(function()
        if currentTab then currentTab.BackgroundColor3 = Color3.fromRGB(30, 30, 30) end
        currentTab = tab
        tab.BackgroundColor3 = accent

        for _, child in pairs(contentFrame:GetChildren()) do
            if not child:IsA("UIListLayout") then child:Destroy() end
        end

        if callback then callback() end
    end)
    return tab
end

-- Criar Toggle
local function createToggle(name, callback, initialState)
    local container = Instance.new("Frame", contentFrame)
    container.Size = UDim2.new(1, 0, 0, 45)
    container.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
    Instance.new("UICorner", container).CornerRadius = UDim.new(0, 8)

    local label = Instance.new("TextLabel", container)
    label.Size = UDim2.new(1, -80, 1, 0)
    label.Position = UDim2.new(0, 10, 0, 0)
    label.BackgroundTransparency = 1
    label.Text = name
    label.Font = Enum.Font.Gotham
    label.TextSize = 14
    label.TextColor3 = white
    label.TextXAlignment = Enum.TextXAlignment.Left

    local toggle = Instance.new("TextButton", container)
    toggle.Size = UDim2.new(0, 55, 0, 25)
    toggle.Position = UDim2.new(1, -65, 0.5, -12)
    toggle.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
    toggle.Text = "OFF"
    toggle.TextColor3 = white
    toggle.Font = Enum.Font.GothamBold
    toggle.TextSize = 12
    Instance.new("UICorner", toggle).CornerRadius = UDim.new(1, 0)

    local isOn = initialState or false
    if isOn then
        toggle.Text = "ON"
        toggle.BackgroundColor3 = accent
    end

    toggle.MouseButton1Click:Connect(function()
        isOn = not isOn
        toggle.Text = isOn and "ON" or "OFF"
        toggle.BackgroundColor3 = isOn and accent or Color3.fromRGB(60, 60, 60)
        if callback then callback(isOn) end
    end)
end

-- Criar botão
local function createButton(name, callback)
    local button = Instance.new("TextButton", contentFrame)
    button.Size = UDim2.new(1, 0, 0, 40)
    button.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
    button.Text = name
    button.TextColor3 = white
    button.Font = Enum.Font.Gotham
    button.TextSize = 14
    Instance.new("UICorner", button).CornerRadius = UDim.new(0, 8)
    button.MouseButton1Click:Connect(callback)
end

-- Funções
local function toggleNoclip(state)
    noclipEnabled = state
    if noclipConnection then
        noclipConnection:Disconnect()
        noclipConnection = nil
    end
    if state then
        noclipStateMap = {}
        noclipConnection = RunService.Stepped:Connect(function()
            local character = player.Character
            if not character then return end
            for _, part in pairs(character:GetDescendants()) do
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
                pcall(function() part.CanCollide = orig end)
            end
        end
        noclipStateMap = {}
    end
end

local function toggleFly(state)
    flyEnabled = state
    if flyConnection then flyConnection:Disconnect() flyConnection = nil end
    if flyBodyVelocity then pcall(function() flyBodyVelocity:Destroy() end) flyBodyVelocity = nil end

    local char = player.Character
    local hum = char and char:FindFirstChildOfClass("Humanoid")
    local hrp = char and char:FindFirstChild("HumanoidRootPart")
    if state and hum and hrp then
        flyBodyVelocity = Instance.new("BodyVelocity")
        flyBodyVelocity.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
        flyBodyVelocity.Velocity = Vector3.new(0, 0, 0)
        flyBodyVelocity.Parent = hrp

        flyConnection = RunService.Heartbeat:Connect(function()
            if not player.Character then return end
            local hum2 = player.Character:FindFirstChildOfClass("Humanoid")
            local hrp2 = player.Character:FindFirstChild("HumanoidRootPart")
            if not (hum2 and hrp2) then return end
            local camera = workspace.CurrentCamera
            local move = hum2.MoveDirection
            local look = camera.CFrame.LookVector
            local right = camera.CFrame.RightVector
            local velocity = Vector3.new(0,0,0)
            if move.Magnitude > 0 then
                velocity = (look * move.Z + right * move.X) * flySpeed
            end
            flyBodyVelocity.Velocity = velocity
        end)
    end
end

-- ESP
local function createESP(plr)
    if plr == player or not plr.Character or not plr.Character:FindFirstChild("Head") then return end
    local head = plr.Character.Head
    if head:FindFirstChild("PlayerESP") then return end
    local tag = Instance.new("BillboardGui", head)
    tag.Name = "PlayerESP"
    tag.Size = UDim2.new(0, 100, 0, 30)
    tag.AlwaysOnTop = true
    tag.StudsOffset = Vector3.new(0, 2, 0)
    local label = Instance.new("TextLabel", tag)
    label.Size = UDim2.new(1, 0, 1, 0)
    label.Text = plr.Name
    label.BackgroundTransparency = 1
    label.TextColor3 = accent
    label.TextStrokeTransparency = 0
    label.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
    label.Font = Enum.Font.GothamBold
    label.TextScaled = true
end

local function removeESP(plr)
    if plr.Character and plr.Character:FindFirstChild("Head") then
        local esp = plr.Character.Head:FindFirstChild("PlayerESP")
        if esp then esp:Destroy() end
    end
end

local function updateAllESP()
    for _, plr in pairs(Players:GetPlayers()) do
        if plr ~= player then
            if espEnabled then createESP(plr) else removeESP(plr) end
        end
    end
end

-- Tabs
local function loadPlayerTab()
    createToggle("🚫 Noclip", toggleNoclip, noclipEnabled)
    createToggle("🕊️ Fly", toggleFly, flyEnabled)
    createButton("🔄 Reset Character", function()
        if player.Character and player.Character:FindFirstChild("Humanoid") then
            player.Character.Humanoid.Health = 0
        end
    end)
end

local function loadVisualTab()
    createToggle("👁 Player ESP", function(state)
        espEnabled = state
        updateAllESP()
    end, espEnabled)
    createToggle("💡 Full Bright", function(state)
        fullbrightEnabled = state
        if state then
            Lighting.ClockTime = 14
            Lighting.Brightness = 2
            Lighting.FogEnd = 100000
            Lighting.GlobalShadows = false
        else
            Lighting.ClockTime = 12
            Lighting.Brightness = 1
            Lighting.FogEnd = 100
            Lighting.GlobalShadows = true
        end
    end, fullbrightEnabled)
end

local function loadTeleportTab()
    createButton("⬆️ Teleport To Sky", function()
        local root = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
        if root then root.CFrame = root.CFrame + Vector3.new(0, 200, 0) end
    end)
    createButton("⬇️ Fall Down", function()
        local root = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
        if root then root.CFrame = root.CFrame - Vector3.new(0, 50, 0) end
    end)
end

local function loadMiscTab()
    createButton("🔄 Rejoin", function()
        TeleportService:Teleport(game.PlaceId, player)
    end)
    createButton("📋 Copy Game Link", function()
        if setclipboard then
            setclipboard("https://www.roblox.com/games/" .. game.PlaceId)
        end
    end)
end

-- Criar Tabs
local playerTab = createTab("Player", "👤", loadPlayerTab)
createTab("Visual", "👁", loadVisualTab)
createTab("Teleport", "📍", loadTeleportTab)
createTab("Misc", "⚙️", loadMiscTab)

-- Selecionar Player como default
playerTab.BackgroundColor3 = accent
currentTab = playerTab
loadPlayerTab()

-- Abrir GUI
openBtn.MouseButton1Click:Connect(function()
    mainFrame.Visible = not mainFrame.Visible
end)

-- ESP para novos players
Players.PlayerAdded:Connect(function(plr)
    plr.CharacterAdded:Connect(function()
        task.wait(1)
        if espEnabled then createESP(plr) end
    end)
end)

Players.PlayerRemoving:Connect(function(plr)
    removeESP(plr)
end)

player.CharacterRemoving:Connect(function()
    if noclipConnection then noclipConnection:Disconnect() noclipConnection = nil end
    if flyConnection then flyConnection:Disconnect() flyConnection = nil end
    if flyBodyVelocity then pcall(function() flyBodyVelocity:Destroy() end) flyBodyVelocity = nil end
    noclipStateMap = {}
end)

player.CharacterAdded:Connect(function()
    task.wait(1)
    if noclipEnabled then toggleNoclip(true) end
    if flyEnabled then toggleFly(true) end
end)

-- Botão TP UP
local tpUpBtn = Instance.new("TextButton")
tpUpBtn.Size = UDim2.new(0, 50, 0, 50)
tpUpBtn.Position = UDim2.new(1, -120, 1, -140)
tpUpBtn.BackgroundColor3 = bg
tpUpBtn.Text = "⬆️"
tpUpBtn.TextColor3 = white
tpUpBtn.Font = Enum.Font.GothamBold
tpUpBtn.TextSize = 20
Instance.new("UICorner", tpUpBtn).Corner
