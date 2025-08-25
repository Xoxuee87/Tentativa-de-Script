--[[
Melhorias para o script "Steal A Brainrot"
- Movimentação mais suave e segura (usa RenderStepped, sem wait dentro de Heartbeat)
- Marca visual com limpeza adequada
- Server hop com tratamento de erros
- UI refinada: hover seguro, minimizar, arrastar melhor
- Atalhos de teclado (M = marcar, G = STEAL, H = server hop)
- Tratamento de respawn / ausência do personagem
- Comentários em português para facilitar customizações
]]

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local TeleportService = game:GetService("TeleportService")
local HttpService = game:GetService("HttpService")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer

-- Guardas básicas (caso o script seja executado muito cedo)
if not LocalPlayer then
    warn("Script precisa rodar como LocalScript dentro do Player.")
    return
end

local playerGui = LocalPlayer:WaitForChild("PlayerGui")
local character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
local rootPart = character:FindFirstChild("HumanoidRootPart")

-- Reatribuir quando respawnar
LocalPlayer.CharacterAdded:Connect(function(newChar)
    character = newChar
    rootPart = character:WaitForChild("HumanoidRootPart")
end)

-- Estado
local markPosition = nil
local isStealActive = false
local isMinimized = false
local markPart = nil

-- Util: clamp color ao criar hover
local function brightenColor(color3, factor)
    local r = math.clamp(color3.R * factor, 0, 1)
    local g = math.clamp(color3.G * factor, 0, 1)
    local b = math.clamp(color3.B * factor, 0, 1)
    return Color3.new(r, g, b)
end

-- Cria GUI
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "StealBrainRotGui"
screenGui.ResetOnSpawn = false
screenGui.Parent = playerGui
screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

local mainFrame = Instance.new("Frame")
mainFrame.Name = "MainFrame"
mainFrame.Size = UDim2.new(0, 280, 0, 275)
mainFrame.Position = UDim2.new(0.5, -140, 0.5, -137.5)
mainFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
mainFrame.BorderSizePixel = 0
mainFrame.Parent = screenGui

local mainCorner = Instance.new("UICorner")
mainCorner.CornerRadius = UDim.new(0, 12)
mainCorner.Parent = mainFrame

local gradient = Instance.new("UIGradient")
gradient.Color = ColorSequence.new{
    ColorSequenceKeypoint.new(0, Color3.fromRGB(40, 40, 60)),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(20, 20, 30))
}
gradient.Rotation = 45
gradient.Parent = mainFrame

local titleFrame = Instance.new("Frame")
titleFrame.Name = "TitleFrame"
titleFrame.Size = UDim2.new(1, 0, 0, 40)
titleFrame.Position = UDim2.new(0, 0, 0, 0)
titleFrame.BackgroundTransparency = 1
titleFrame.Parent = mainFrame
titleFrame.Active = true -- para Input events

local titleLabel = Instance.new("TextLabel")
titleLabel.Name = "TitleLabel"
titleLabel.Size = UDim2.new(1, -40, 1, 0)
titleLabel.Position = UDim2.new(0, 0, 0, 0)
titleLabel.BackgroundTransparency = 1
titleLabel.Text = "🧠 Steal A Brainrot"
titleLabel.TextColor3 = Color3.fromRGB(255, 100, 150)
titleLabel.TextScaled = true
titleLabel.Font = Enum.Font.GothamBold
titleLabel.Parent = titleFrame

local titleGlow = Instance.new("UIStroke")
titleGlow.Color = Color3.fromRGB(255, 100, 150)
titleGlow.Thickness = 1
titleGlow.Transparency = 0.3
titleGlow.Parent = titleLabel

local minimizeButton = Instance.new("TextButton")
minimizeButton.Name = "MinimizeButton"
minimizeButton.Size = UDim2.new(0, 30, 0, 30)
minimizeButton.Position = UDim2.new(1, -35, 0, 5)
minimizeButton.BackgroundColor3 = Color3.fromRGB(255, 60, 60)
minimizeButton.BorderSizePixel = 0
minimizeButton.Text = "−"
minimizeButton.TextColor3 = Color3.fromRGB(255, 255, 255)
minimizeButton.TextScaled = true
minimizeButton.Font = Enum.Font.GothamBold
minimizeButton.Parent = titleFrame

local minCorner = Instance.new("UICorner")
minCorner.CornerRadius = UDim.new(0, 15)
minCorner.Parent = minimizeButton

local buttonContainer = Instance.new("Frame")
buttonContainer.Name = "ButtonContainer"
buttonContainer.Size = UDim2.new(1, -20, 1, -60)
buttonContainer.Position = UDim2.new(0, 10, 0, 50)
buttonContainer.BackgroundTransparency = 1
buttonContainer.Parent = mainFrame

-- Helper para criar botões com hover seguro
local function createButton(name, text, yOffset, color)
    local button = Instance.new("TextButton")
    button.Name = name
    button.Size = UDim2.new(1, 0, 0, 45)
    button.Position = UDim2.new(0, 0, 0, yOffset)
    button.BackgroundColor3 = color
    button.BorderSizePixel = 0
    button.Text = text
    button.TextColor3 = Color3.fromRGB(255, 255, 255)
    button.TextScaled = true
    button.Font = Enum.Font.GothamBold
    button.Parent = buttonContainer

    local buttonCorner = Instance.new("UICorner")
    buttonCorner.CornerRadius = UDim.new(0, 8)
    buttonCorner.Parent = button

    local buttonStroke = Instance.new("UIStroke")
    buttonStroke.Color = color
    buttonStroke.Thickness = 1
    buttonStroke.Transparency = 0.5
    buttonStroke.Parent = button

    local hoverTween = TweenService:Create(button, TweenInfo.new(0.18, Enum.EasingStyle.Quad), {
        BackgroundColor3 = brightenColor(color, 1.18)
    })
    local normalTween = TweenService:Create(button, TweenInfo.new(0.18, Enum.EasingStyle.Quad), {
        BackgroundColor3 = color
    })

    button.MouseEnter:Connect(function()
        pcall(function() hoverTween:Play() end)
    end)
    button.MouseLeave:Connect(function()
        pcall(function() normalTween:Play() end)
    end)

    return button
end

local stealButton = createButton("StealButton", "🔥 STEAL", 0, Color3.fromRGB(255, 60, 60))
local goDownButton = createButton("GoDownButton", "⬇️ GO DOWN", 55, Color3.fromRGB(60, 150, 255))
local markButton = createButton("MarkButton", "📍 MARK (M)", 110, Color3.fromRGB(60, 255, 60))
local serverHopButton = createButton("ServerHopButton", "🔄 SERVER HOP (H)", 165, Color3.fromRGB(255, 165, 0))

-- Função para criar/remover marca no workspace (visível para todos, nomeado por player)
local function createMarkAt(position)
    -- limpa marca anterior se existir (própria do player)
    if markPart and markPart.Parent then
        markPart:Destroy()
        markPart = nil
    end

    local part = Instance.new("Part")
    part.Name = "PlayerMark_" .. tostring(LocalPlayer.UserId)
    part.Size = Vector3.new(4, 1, 4)
    part.Anchored = true
    part.CanCollide = false
    part.Material = Enum.Material.Neon
    part.BrickColor = BrickColor.new("Bright green")
    part.Transparency = 0
    -- Cylinder Y axis up (altura = Y). Rotar para ficar "plano" se quiser
    part.CFrame = CFrame.new(position) * CFrame.Angles(math.rad(90), 0, 0) -- faz o cilindro ficar "deitado"
    part.Shape = Enum.PartType.Cylinder
    part.Parent = workspace

    -- Pulsar (transparência alternada)
    local tweenInfo = TweenInfo.new(1, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut, -1, true)
    local pulse = TweenService:Create(part, tweenInfo, {Transparency = 0.5})
    pulse:Play()

    markPart = part
    markPosition = position
end

-- Marcar posição atual
local function mark()
    if not rootPart then
        rootPart = character and character:FindFirstChild("HumanoidRootPart")
        if not rootPart then return end
    end

    local pos = rootPart.Position
    createMarkAt(pos)
end

-- Movimento suave para marca
local function steal()
    if isStealActive then return end
    if not markPosition then
        stealButton.Text = "❗ NO MARK"
        task.delay(1.2, function() if stealButton then stealButton.Text = "🔥 STEAL" end end)
        return
    end

    if not rootPart or not rootPart.Parent then
        stealButton.Text = "❗ NO ROOT"
        task.delay(1.2, function() if stealButton then stealButton.Text = "🔥 STEAL" end end)
        return
    end

    isStealActive = true
    stealButton.Text = "🔥 STEALING..."

    local moveSpeed = 80 -- studs por segundo (ajustável)
    local finished = false
    local disconnected = false

    -- Conexão para mover cada frame
    local conn
    conn = RunService.RenderStepped:Connect(function(dt)
        if not rootPart or not rootPart.Parent then
            disconnected = true
            return
        end

        local currentPos = rootPart.Position
        local targetPos = markPosition
        local direction = (targetPos - currentPos)
        local distance = direction.Magnitude

        if distance <= 3 then
            finished = true
            return
        end

        local moveStep = math.min(moveSpeed * dt, distance)
        local newPos = currentPos + direction.Unit * moveStep

        -- Preserva rotação aproximada (face para direção)
        if direction.Magnitude > 0.1 then
            local lookCFrame = CFrame.new(newPos, newPos + Vector3.new(direction.X, 0, direction.Z))
            rootPart.CFrame = lookCFrame
        else
            rootPart.CFrame = CFrame.new(newPos)
        end
    end)

    -- Espera até terminar ou erro
    local timeout = 12 -- segundos max
    local timer = 0
    while not finished and not disconnected and timer < timeout do
        timer = timer + RunService.RenderStepped:Wait()
    end

    if conn and conn.Connected then
        conn:Disconnect()
    end

    -- Ao finalizar, sobe para evitar prender no chão (comportamento do script original)
    if not disconnected then
        if rootPart and rootPart.Parent then
            rootPart.CFrame = CFrame.new(markPosition + Vector3.new(0, 200, 0))
        end
        stealButton.Text = "🔥 STEAL"
    else
        stealButton.Text = "❗ FAILED"
        task.delay(1.2, function() if stealButton then stealButton.Text = "🔥 STEAL" end end)
    end

    isStealActive = false
end

-- Descer (utilitário)
local function goDown()
    if not rootPart or not rootPart.Parent then return end
    rootPart.CFrame = rootPart.CFrame - Vector3.new(0, 200, 0)
end

-- Server hop (busca servers públicos e tenta teleportar)
local function serverHop()
    serverHopButton.Text = "🔄 HOPPING..."
    serverHopButton.AutoButtonColor = false

    local placeId = game.PlaceId
    local success, servers = pcall(function()
        -- Tenta obter lista de servidores; pode falhar dependendo das permissões
        local url = ("https://games.roblox.com/v1/games/%d/servers/Public?sortOrder=Asc&limit=100"):format(placeId)
        local raw = game:HttpGet(url)
        return HttpService:JSONDecode(raw)
    end)

    if success and servers and servers.data and #servers.data > 0 then
        local hopped = false
        for _, s in ipairs(servers.data) do
            if s.id and s.id ~= game.JobId and (not s.maxPlayers or (s.playing < s.maxPlayers)) then
                -- Tenta teleportar para a instância encontrada
                local ok, err = pcall(function()
                    TeleportService:TeleportToPlaceInstance(placeId, s.id, LocalPlayer)
                end)
                if ok then
                    hopped = true
                    break
                else
                    -- continua procurando
                    warn("Teleport falhou:", err)
                end
            end
        end

        if not hopped then
            -- fallback: teleport normal para o lugar (pode levar ao mesmo servidor)
            pcall(function()
                TeleportService:Teleport(placeId, LocalPlayer)
            end)
        end
    else
        -- fallback simples caso não consiga obter servidores
        pcall(function()
            TeleportService:Teleport(placeId, LocalPlayer)
        end)
    end

    task.delay(5, function()
        if serverHopButton then
            serverHopButton.Text = "🔄 SERVER HOP (H)"
            serverHopButton.AutoButtonColor = true
        end
    end)
end

-- Minimize toggle
local function toggleMinimize()
    if isMinimized then
        local expandTween = TweenService:Create(mainFrame, TweenInfo.new(0.28, Enum.EasingStyle.Quad), {
            Size = UDim2.new(0, 280, 0, 275)
        })
        expandTween:Play()
        minimizeButton.Text = "−"
        buttonContainer.Visible = true
        isMinimized = false
    else
        local minimizeTween = TweenService:Create(mainFrame, TweenInfo.new(0.28, Enum.EasingStyle.Quad), {
            Size = UDim2.new(0, 280, 0, 40)
        })
        minimizeTween:Play()
        minimizeButton.Text = "+"
        buttonContainer.Visible = false
        isMinimized = true
    end
end

-- Conexões dos botões
stealButton.MouseButton1Click:Connect(steal)
goDownButton.MouseButton1Click:Connect(goDown)
markButton.MouseButton1Click:Connect(mark)
serverHopButton.MouseButton1Click:Connect(serverHop)
minimizeButton.MouseButton1Click:Connect(toggleMinimize)

-- Arrastar a janela
local dragging = false
local dragStart = Vector2.new(0, 0)
local startPos = UDim2.new(0, 0, 0, 0)

titleFrame.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = true
        dragStart = input.Position
        startPos = mainFrame.Position

        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then
                dragging = false
            end
        end)
    end
end)

titleFrame.InputChanged:Connect(function(input)
    if (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) and dragging then
        local delta = input.Position - dragStart
        local newPos = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        mainFrame.Position = newPos
    end
end)

-- Animação de aparecimento
mainFrame.Size = UDim2.new(0, 0, 0, 0)
local appearTween = TweenService:Create(mainFrame, TweenInfo.new(0.4, Enum.EasingStyle.Back), {
    Size = UDim2.new(0, 280, 0, 275)
})
appearTween:Play()

-- Atalhos de teclado (M = mark, G = steal, H = server hop)
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    if input.UserInputType ~= Enum.UserInputType.Keyboard then return end

    local key = input.KeyCode
    if key == Enum.KeyCode.M then
        mark()
    elseif key == Enum.KeyCode.G then
        steal()
    elseif key == Enum.KeyCode.H then
        serverHop()
    end
end)

-- Clean up mark ao sair do jogo localmente
LocalPlayer.AncestryChanged:Connect(function()
    if not LocalPlayer:IsDescendantOf(game) and markPart and markPart.Parent then
        markPart:Destroy()
    end
end)

-- Exposição opcional: permita outras partes do jogo chamarem as funções (se desejado)
-- _G.StealA = {Mark = mark, Steal = steal, ServerHop = serverHop, GoDown = goDown}

-- Fim do script.
