--[[
Steel A Brainrot - Versão corrigida e mais segura
O que foi feito:
- Substituí o teleporte fixo de +200 studs por movimento com PathfindingService quando possível,
  com fallback seguro usando raycast para encontrar o chão próximo à marca.
- Evitei teleports que jogavam o jogador para fora do mapa.
- goDown agora usa raycast para pousar no chão abaixo do jogador (fallback pequeno se não achar).
- Tratamento robusto para ausência de Humanoid/HumanoidRootPart e respawn.
- Timeouts, validações e limpeza correta da marca.
- Mantive a UI e animações do script anterior.
- Adicionei atalhos de teclado (M, G, H) e proteção contra múltiplas execuções simultâneas.

Uso:
- M: marcar posição
- G: iniciar "steal" (tenta usar Pathfinding; se falhar, faz fallback seguro)
- H: server hop
]]

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local TeleportService = game:GetService("TeleportService")
local HttpService = game:GetService("HttpService")
local RunService = game:GetService("RunService")
local PathfindingService = game:GetService("PathfindingService")

local LocalPlayer = Players.LocalPlayer
if not LocalPlayer then
    warn("Script deve rodar como LocalScript no cliente.")
    return
end

local playerGui = LocalPlayer:WaitForChild("PlayerGui")
local character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
local rootPart = character:FindFirstChild("HumanoidRootPart")
local humanoid = character:FindFirstChildOfClass("Humanoid")

-- Reatribuir quando respawnar
LocalPlayer.CharacterAdded:Connect(function(newChar)
    character = newChar
    rootPart = character:WaitForChild("HumanoidRootPart")
    humanoid = character:WaitForChild("Humanoid")
end)

-- Estado
local markPosition = nil
local isStealActive = false
local isMinimized = false
local markPart = nil

local function brightenColor(color3, factor)
    local r = math.clamp(color3.R * factor, 0, 1)
    local g = math.clamp(color3.G * factor, 0, 1)
    local b = math.clamp(color3.B * factor, 0, 1)
    return Color3.new(r, g, b)
end

-- UI (mantive parecido com a versão anterior)
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
titleFrame.Active = true

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

local function createMarkAt(position)
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
    part.CFrame = CFrame.new(position) * CFrame.Angles(math.rad(90), 0, 0)
    part.Shape = Enum.PartType.Cylinder
    part.Parent = workspace

    local tweenInfo = TweenInfo.new(1, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut, -1, true)
    local pulse = TweenService:Create(part, tweenInfo, {Transparency = 0.5})
    pulse:Play()

    markPart = part
    markPosition = position
end

-- Retorna uma posição segura próxima ao alvo (procura chão por raycast)
local function getSafePosition(position)
    local upOrigin = position + Vector3.new(0, 60, 0)
    local params = RaycastParams.new()
    params.FilterDescendantsInstances = {character}
    params.FilterType = Enum.RaycastFilterType.Blacklist
    local ray = workspace:Raycast(upOrigin, Vector3.new(0, -300, 0), params)
    if ray and ray.Position then
        return ray.Position + Vector3.new(0, 3, 0)
    end
    -- fallback mais conservador
    return position + Vector3.new(0, 3, 0)
end

-- Move usando PathfindingService. Retorna true se alcançou, false caso falhe/timeout.
local function moveToWithPathfinding(destination, totalTimeout)
    if not character or not rootPart then return false end
    humanoid = humanoid or character:FindFirstChildOfClass("Humanoid")
    if not humanoid then return false end

    -- Não tentar pathfinding se distância for muito grande (opcional) ou se ambiente for inválido
    local startPos = rootPart.Position
    local distance = (destination - startPos).Magnitude
    -- Se muito próximo, apenas MoveTo direto
    if distance <= 4 then
        humanoid:MoveTo(destination)
        local ok = humanoid.MoveToFinished:Wait()
        -- checar proximidade
        return (rootPart.Position - destination).Magnitude <= 5
    end

    local path = PathfindingService:CreatePath({
        AgentRadius = 2,
        AgentHeight = 5,
        AgentCanJump = true,
        AgentJumpHeight = 6,
        AgentMaxSlope = 45
    })

    local ok, err = pcall(function()
        path:ComputeAsync(startPos, destination)
    end)
    if not ok then
        warn("Path compute pcall failed:", err)
        return false
    end

    if path.Status ~= Enum.PathStatus.Success then
        -- pode ser NoPath ou nada
        return false
    end

    local waypoints = path:GetWaypoints()
    local startTime = tick()
    for i, wp in ipairs(waypoints) do
        if not humanoid or not humanoid.Parent then return false end
        -- wp.Position é o local a ir
        if wp.Action == Enum.PathWaypointAction.Jump then
            humanoid.Jump = true
        end

        local requiredPos = wp.Position
        humanoid:MoveTo(requiredPos)

        -- esperar até chegar ou até timeout
        local reached = false
        local conn
        local reachedSignal = Instance.new("BindableEvent")
        conn = humanoid.MoveToFinished:Connect(function(reachedArg)
            -- MoveToFinished historically não passa argumento consistentemente; então avaliamos pela distância também
            local dist = (rootPart.Position - requiredPos).Magnitude
            if dist <= 6 then
                reachedSignal:Fire(true)
            else
                reachedSignal:Fire(reachedArg == true)
            end
        end)

        -- aguardar, com timeout por waypoint
        local waypointTimeout = 8 -- segundos por waypoint
        local waited = 0
        while waited < waypointTimeout do
            local fired = reachedSignal.Event:Wait()
            if fired then
                reached = true
                break
            end
            waited = waited + 0.1
            task.wait(0.1)
        end

        conn:Disconnect()
        reachedSignal:Destroy()

        if not reached then
            -- falhou em um waypoint
            return false
        end

        if tick() - startTime > (totalTimeout or 25) then
            return false
        end
    end

    -- chegou em todos os waypoints
    return true
end

-- Marcar posição atual
local function mark()
    if not rootPart or not rootPart.Parent then
        rootPart = character and character:FindFirstChild("HumanoidRootPart")
        if not rootPart then return end
    end
    createMarkAt(rootPart.Position)
end

-- Steal: tenta caminhar até a marca usando pathfinding, se falhar faz fallback seguro (teleport para posição do chão próximo)
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

    -- Primeiro: tentar pathfinding com timeout total razoável
    local pathSucceeded = false
    local ok, err = pcall(function()
        pathSucceeded = moveToWithPathfinding(markPosition, 30) -- 30s timeout total
    end)

    if not ok then
        warn("Erro durante pathfinding:", err)
        pathSucceeded = false
    end

    if pathSucceeded then
        -- ao chegar ao destino pelo pathfinding, garantir que está sobre um chão seguro
        local safe = getSafePosition(markPosition)
        if rootPart and rootPart.Parent then
            -- use MoveTo para posicionar bem em cima do safePos (evita teleports bruscos)
            if humanoid and humanoid.Parent then
                humanoid:MoveTo(safe)
                local reached = humanoid.MoveToFinished:Wait()
                -- Se não alcançou via MoveTo, apenas forçar CFrame com cuidado
                if (rootPart.Position - safe).Magnitude > 6 then
                    rootPart.CFrame = CFrame.new(safe)
                end
            else
                rootPart.CFrame = CFrame.new(safe)
            end
        end
    else
        -- fallback: lugar seguro calculado via raycast, teleporta-se de forma conservadora (pequeno offset)
        local safePos = getSafePosition(markPosition)
        if rootPart and rootPart.Parent then
            -- posicionar suavemente (primeiro desligar humanoid state)
            if humanoid and humanoid.Parent then
                -- garantir estado para evitar conflito
                humanoid.Sit = true
                task.wait(0.05)
                rootPart.CFrame = CFrame.new(safePos)
                humanoid.Sit = false
            else
                rootPart.CFrame = CFrame.new(safePos)
            end
        end
    end

    isStealActive = false
    stealButton.Text = "🔥 STEAL"
end

-- Descer até o chão abaixo do player (usa raycast)
local function goDown()
    if not rootPart or not rootPart.Parent then return end
    local origin = rootPart.Position + Vector3.new(0, 2, 0)
    local params = RaycastParams.new()
    params.FilterDescendantsInstances = {character}
    params.FilterType = Enum.RaycastFilterType.Blacklist
    local result = workspace:Raycast(origin, Vector3.new(0, -600, 0), params)
    if result and result.Position then
        -- slight offset above ground
        local target = result.Position + Vector3.new(0, 3, 0)
        if humanoid and humanoid.Parent then
            humanoid:MoveTo(target)
            local ok = humanoid.MoveToFinished:Wait()
            if (rootPart.Position - target).Magnitude > 6 then
                rootPart.CFrame = CFrame.new(target)
            end
        else
            rootPart.CFrame = CFrame.new(target)
        end
    else
        -- fallback conservador
        if humanoid and humanoid.Parent then
            humanoid:MoveTo(rootPart.Position - Vector3.new(0, 30, 0))
            local ok = humanoid.MoveToFinished:Wait()
            if (rootPart.Position - (rootPart.Position - Vector3.new(0, 30, 0))).Magnitude > 6 then
                rootPart.CFrame = rootPart.CFrame - Vector3.new(0, 30, 0)
            end
        else
            rootPart.CFrame = rootPart.CFrame - Vector3.new(0, 30, 0)
        end
    end
end

-- Server hop (sem alteração significativa)
local function serverHop()
    serverHopButton.Text = "🔄 HOPPING..."
    serverHopButton.AutoButtonColor = false

    local placeId = game.PlaceId
    local success, servers = pcall(function()
        local url = ("https://games.roblox.com/v1/games/%d/servers/Public?sortOrder=Asc&limit=100"):format(placeId)
        local raw = game:HttpGet(url)
        return HttpService:JSONDecode(raw)
    end)

    if success and servers and servers.data and #servers.data > 0 then
        local hopped = false
        for _, s in ipairs(servers.data) do
            if s.id and s.id ~= game.JobId and (not s.maxPlayers or (s.playing < s.maxPlayers)) then
                local ok, err = pcall(function()
                    TeleportService:TeleportToPlaceInstance(placeId, s.id, LocalPlayer)
                end)
                if ok then
                    hopped = true
                    break
                else
                    warn("Teleport falhou:", err)
                end
            end
        end

        if not hopped then
            pcall(function()
                TeleportService:Teleport(placeId, LocalPlayer)
            end)
        end
    else
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

-- Toggle minimize
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

-- Conexões UI
stealButton.MouseButton1Click:Connect(steal)
goDownButton.MouseButton1Click:Connect(goDown)
markButton.MouseButton1Click:Connect(mark)
serverHopButton.MouseButton1Click:Connect(serverHop)
minimizeButton.MouseButton1Click:Connect(toggleMinimize)

-- Dragging window
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

-- Aparecer animado
mainFrame.Size = UDim2.new(0, 0, 0, 0)
local appearTween = TweenService:Create(mainFrame, TweenInfo.new(0.4, Enum.EasingStyle.Back), {
    Size = UDim2.new(0, 280, 0, 275)
})
appearTween:Play()

-- Atalhos teclado
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

-- Limpeza da marca ao sair
LocalPlayer.AncestryChanged:Connect(function()
    if not LocalPlayer:IsDescendantOf(game) and markPart and markPart.Parent then
        markPart:Destroy()
    end
end)

-- Ganchos finais para garantir referências atualizadas
RunService.Heartbeat:Connect(function()
    if character and (not humanoid or not humanoid.Parent) then
        humanoid = character:FindFirstChildOfClass("Humanoid")
    end
    if character and (not rootPart or not rootPart.Parent) then
        rootPart = character:FindFirstChild("HumanoidRootPart")
    end
end)

-- Exposição opcional (descomente se desejar chamar por outros scripts)
-- _G.StealA = {Mark = mark, Steal = steal, ServerHop = serverHop, GoDown = goDown}

-- Fim do script
