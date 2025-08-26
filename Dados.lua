--// VIMTO HUB //--

-- Garante que qualquer instância anterior seja destruída para evitar duplicação
if game:GetService("CoreGui"):FindFirstChild("VimtoHub") then
    game:GetService("CoreGui").VimtoHub:Destroy()
end

-- Variáveis de Serviços (melhor prática para acessá-los)
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local TeleportService = game:GetService("TeleportService")
local UserInputService = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer

-- Verificação crítica: Garante que o jogador local existe
if not LocalPlayer then
    warn("VimtoHub: LocalPlayer not found. Exiting.")
    return
end

-- Estados e Configurações
local Config = {
    FlyEnabled = false,
    FlySpeed = 50,
    NoclipEnabled = false,
    ESPPplayersEnabled = false,
    ESPChestsEnabled = false,
    UIHidden = false, -- Novo estado para esconder/mostrar a UI
}

-- Conexões de eventos para limpeza
local Connections = {}

-- Fly
local Fly = {
    Connection = nil,
    BodyVelocity = nil,
    AlignOrientation = nil,
    OriginalWalkSpeed = nil,
}

-- Noclip
local Noclip = {
    Connection = nil,
    OriginalCollisionStates = {} -- Para restaurar o CanCollide
}

-- UI Cores e Propriedades
local Colors = {
    Background = Color3.fromRGB(20, 20, 20),
    Accent = Color3.fromRGB(255, 100, 150),
    Text = Color3.new(1, 1, 1),
    Stroke = Color3.fromRGB(50, 50, 50), -- Um stroke um pouco mais claro para contraste
    Hover = Color3.fromRGB(35, 35, 35), -- Cor para hover de botões
    Click = Color3.fromRGB(60, 60, 60), -- Cor para click de botões
}

local UI = {
    MainFrame = nil,
    TabFrame = nil,
    ContentFrame = nil,
    TabButtons = {},
    CurrentTab = nil,
    ESPContainer = Instance.new("Folder", game:GetService("CoreGui")), -- Container para ESPs
}
UI.ESPContainer.Name = "VimtoHub_ESP_Container"


-- Funções Utilitárias de UI

-- Cria um canto arredondado
local function createCorner(parent, radius)
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, radius or 12)
    corner.Parent = parent
    return corner
end

-- Cria um stroke
local function createStroke(parent, color, thickness)
    local stroke = Instance.new("UIStroke")
    stroke.Color = color or Colors.Accent
    stroke.Thickness = thickness or 1
    stroke.Parent = parent
    return stroke
end

-- Cria um botão genérico com efeitos de hover/click
local function createButton(parent, text, callback, positionOffset)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, -20, 0, 35)
    btn.Position = UDim2.new(0, 10, 0, positionOffset or 0)
    btn.BackgroundColor3 = Colors.Background
    btn.Text = text
    btn.Font = Enum.Font.Gotham
    btn.TextSize = 14
    btn.TextColor3 = Colors.Text
    btn.Parent = parent

    createCorner(btn, 8)
    local btnStroke = createStroke(btn, Colors.Stroke)

    -- Efeitos de Hover e Click
    btn.MouseEnter:Connect(function()
        btn:TweenBackgroundColor3(Colors.Hover, "Out", "Quad", 0.1, true)
    end)
    btn.MouseLeave:Connect(function()
        if btn.BackgroundColor3 ~= Colors.Accent then -- Não muda se for a tab selecionada
            btn:TweenBackgroundColor3(Colors.Background, "Out", "Quad", 0.1, true)
        end
    end)
    btn.MouseButton1Down:Connect(function()
        btn:TweenBackgroundColor3(Colors.Click, "Out", "Quad", 0.1, true)
    end)
    btn.MouseButton1Up:Connect(function()
        if btn.BackgroundColor3 ~= Colors.Accent then
            btn:TweenBackgroundColor3(Colors.Hover, "Out", "Quad", 0.1, true)
        end
    end)

    btn.MouseButton1Click:Connect(callback)
    return btn
end

-- Função para criar Tabs
local function createTab(name, icon, loadFunc)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, -10, 0, 40)
    btn.Position = UDim2.new(0, 5, 0, (#UI.TabButtons * 45))
    btn.BackgroundColor3 = Colors.Background
    btn.Text = icon.." "..name
    btn.Font = Enum.Font.Gotham
    btn.TextSize = 14
    btn.TextColor3 = Colors.Text
    btn.Parent = UI.TabFrame

    createCorner(btn, 8)
    createStroke(btn, Colors.Accent)

    btn.MouseButton1Click:Connect(function()
        if UI.CurrentTab then
            UI.CurrentTab.BackgroundColor3 = Colors.Background
            UI.CurrentTab.TextColor3 = Colors.Text
        end
        UI.CurrentTab = btn
        btn.BackgroundColor3 = Colors.Accent
        btn.TextColor3 = Colors.Text -- Garante que o texto fique branco na tab ativa

        for _, c in pairs(UI.ContentFrame:GetChildren()) do
            if c.Name ~= "UIPadding" then -- Não destruir o UIPadding
                c:Destroy()
            end
        end

        -- Adiciona padding ao contentFrame para melhor espaçamento
        local padding = Instance.new("UIPadding")
        padding.PaddingLeft = UDim.new(0, 10)
        padding.PaddingRight = UDim.new(0, 10)
        padding.PaddingTop = UDim.new(0, 10)
        padding.PaddingBottom = UDim.new(0, 10)
        padding.Parent = UI.ContentFrame

        -- Usa UIListLayout para organizar os botões no ContentFrame
        local listLayout = Instance.new("UIListLayout")
        listLayout.FillDirection = Enum.FillDirection.Vertical
        listLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
        listLayout.VerticalAlignment = Enum.VerticalAlignment.Top
        listLayout.Padding = UDim.new(0, 5) -- Espaçamento entre os botões
        listLayout.Parent = UI.ContentFrame

        loadFunc(UI.ContentFrame) -- Passa o frame para a função de carregamento da aba
    end)

    table.insert(UI.TabButtons, btn)
    return btn
end

-- Funções Core de Gameplay

-- Gerencia a parte de Fly
local function toggleFly(state)
    Config.FlyEnabled = state

    -- Limpa conexões e objetos anteriores
    if Fly.Connection then Connections[Fly.Connection] = nil; Fly.Connection:Disconnect() end
    if Fly.BodyVelocity then Fly.BodyVelocity:Destroy() end
    if Fly.AlignOrientation then Fly.AlignOrientation:Destroy() end
    Fly.Connection, Fly.BodyVelocity, Fly.AlignOrientation = nil, nil, nil

    local character = LocalPlayer.Character
    local humanoid = character and character:FindFirstChildOfClass("Humanoid")
    local hrp = character and character:FindFirstChild("HumanoidRootPart")

    if not character or not humanoid or not hrp then return end

    if state then
        Fly.OriginalWalkSpeed = humanoid.WalkSpeed -- Guarda a velocidade original

        -- Desliga a gravidade temporariamente para um "vôo" mais suave
        humanoid.PlatformStand = true

        Fly.BodyVelocity = Instance.new("AlignPosition")
        Fly.BodyVelocity.MaxForce = 9e9
        Fly.BodyVelocity.Responsiveness = 20
        Fly.BodyVelocity.Position = hrp.Position
        Fly.BodyVelocity.Mode = Enum.PositionMode.OneAttachment
        Fly.BodyVelocity.Attachment0 = Instance.new("Attachment", hrp)
        Fly.BodyVelocity.Parent = hrp

        Fly.AlignOrientation = Instance.new("AlignOrientation")
        Fly.AlignOrientation.MaxTorque = 9e9
        Fly.AlignOrientation.Responsiveness = 20
        Fly.AlignOrientation.Mode = Enum.OrientationMode.OneAttachment
        Fly.AlignOrientation.Attachment0 = Instance.new("Attachment", hrp)
        Fly.AlignOrientation.Parent = hrp

        Fly.Connection = RunService.Heartbeat:Connect(function()
            if not LocalPlayer.Character or not LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then return end

            local camera = workspace.CurrentCamera
            local moveVector = UserInputService:GetMoveVector()

            local x, y, z = moveVector.X, moveVector.Y, moveVector.Z

            local direction = Vector3.new(0, 0, 0)

            -- Direção baseada na câmera
            local camCF = camera.CFrame
            if z > 0 then direction = direction + camCF.LookVector end
            if z < 0 then direction = direction - camCF.LookVector end
            if x > 0 then direction = direction + camCF.RightVector end
            if x < 0 then direction = direction - camCF.RightVector end

            -- Subir/Descer (pode ser mapeado para teclas ou feito automaticamente)
            if UserInputService:IsKeyDown(Enum.KeyCode.Space) then -- Subir
                direction = direction + Vector3.new(0, 1, 0)
            end
            if UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) or UserInputService:IsKeyDown(Enum.KeyCode.C) then -- Descer
                direction = direction - Vector3.new(0, 1, 0)
            end

            -- Normaliza e aplica velocidade
            if direction.Magnitude > 0 then
                direction = direction.Unit * Config.FlySpeed
            end

            Fly.BodyVelocity.Position = hrp.Position + direction
            Fly.AlignOrientation.CFrame = camera.CFrame

            humanoid.PlatformStand = true -- Mantém o jogador em 'platform stand'
        end)
        Connections[Fly.Connection] = true
    else
        humanoid.PlatformStand = false -- Volta ao estado normal
        if Fly.OriginalWalkSpeed then
            humanoid.WalkSpeed = Fly.OriginalWalkSpeed
            Fly.OriginalWalkSpeed = nil
        end
    end
end

-- Gerencia a parte de Noclip
local function toggleNoclip(state)
    Config.NoclipEnabled = state

    if Noclip.Connection then Connections[Noclip.Connection] = nil; Noclip.Connection:Disconnect() end
    Noclip.Connection = nil

    local character = LocalPlayer.Character
    if not character then return end

    if state then
        -- Salva o estado original de CanCollide
        for _, part in pairs(character:GetDescendants()) do
            if part:IsA("BasePart") then
                Noclip.OriginalCollisionStates[part] = part.CanCollide
                part.CanCollide = false
            end
        end

        local humanoid = character:FindFirstChildOfClass("Humanoid")
        if humanoid then
            humanoid:ChangeState(Enum.HumanoidStateType.Physics) -- Ajuda a ignorar colisões
        end

        Noclip.Connection = RunService.Stepped:Connect(function()
            -- Reitera para novas partes ou reset
            if not LocalPlayer.Character then return end
            for _, part in pairs(LocalPlayer.Character:GetDescendants()) do
                if part:IsA("BasePart") and part.CanCollide then
                    Noclip.OriginalCollisionStates[part] = part.CanCollide -- Salva antes de mudar
                    part.CanCollide = false
                end
            end
        end)
        Connections[Noclip.Connection] = true
    else
        -- Restaura o estado original de CanCollide
        for part, originalState in pairs(Noclip.OriginalCollisionStates) do
            if part and part.Parent then -- Garante que a parte ainda existe
                part.CanCollide = originalState
            end
        end
        Noclip.OriginalCollisionStates = {}
        local humanoid = character:FindFirstChildOfClass("Humanoid")
        if humanoid then
            humanoid:ChangeState(Enum.HumanoidStateType.Running) -- Retorna ao estado normal
        end
    end
end

-- Define a velocidade de caminhada
local function setWalkSpeed(val)
    local humanoid = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
    if humanoid then
        humanoid.WalkSpeed = val
    end
end

-- Define a força do pulo
local function setJumpPower(val)
    local humanoid = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
    if humanoid then
        humanoid.UseJumpPower = true -- Garante que JumpPower seja usado
        humanoid.JumpPower = val
    end
end

-- Teleporta para outro jogador
local function teleportToPlayer(targetPlayer)
    local character = LocalPlayer.Character
    local hrp = character and character:FindFirstChild("HumanoidRootPart")
    local targetChar = targetPlayer.Character
    local targetHrp = targetChar and targetChar:FindFirstChild("HumanoidRootPart")

    if hrp and targetHrp then
        -- Move o jogador um pouco acima do alvo para evitar cair no chão
        hrp.CFrame = targetHrp.CFrame + Vector3.new(0, 5, 0)
    else
        warn("VimtoHub: Não foi possível teleportar para " .. targetPlayer.Name .. ". Caracteres não encontrados.")
    end
end

-- Funções ESP (Visual)

local ESPs = {} -- Tabela para armazenar os ESPs criados

local function createPlayerESP(playerTarget)
    if ESPs[playerTarget] then return end -- Já existe

    local billboard = Instance.new("BillboardGui")
    billboard.AlwaysOnTop = true
    billboard.Size = UDim2.new(0, 100, 0, 50)
    billboard.ExtentsOffset = Vector3.new(0, 3, 0) -- Aparece um pouco acima da cabeça
    billboard.PointOffset = Vector3.new(0, 1.5, 0)
    billboard.StudsOffset = Vector3.new(0, 2, 0)
    billboard.Parent = UI.ESPContainer

    local nameText = Instance.new("TextLabel")
    nameText.Size = UDim2.new(1, 0, 0.5, 0)
    nameText.BackgroundTransparency = 1
    nameText.Text = playerTarget.Name
    nameText.Font = Enum.Font.GothamBold
    nameText.TextSize = 16
    nameText.TextColor3 = Colors.Accent
    nameText.Parent = billboard

    local distanceText = Instance.new("TextLabel")
    distanceText.Size = UDim2.new(1, 0, 0.5, 0)
    distanceText.Position = UDim2.new(0, 0, 0.5, 0)
    distanceText.BackgroundTransparency = 1
    distanceText.Text = "Dist: N/A"
    distanceText.Font = Enum.Font.Gotham
    distanceText.TextSize = 14
    distanceText.TextColor3 = Colors.Text
    distanceText.Parent = billboard

    ESPs[playerTarget] = {Billboard = billboard, NameText = nameText, DistanceText = distanceText}

    local connection = RunService.Heartbeat:Connect(function()
        if not playerTarget.Character or not playerTarget.Character:FindFirstChild("HumanoidRootPart") or not LocalPlayer.Character or not LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
            billboard.Enabled = false -- Esconde se o personagem não estiver visível
            return
        end
        billboard.Enabled = true
        billboard.Adornee = playerTarget.Character:FindFirstChild("HumanoidRootPart")

        local distance = (LocalPlayer.Character.HumanoidRootPart.Position - playerTarget.Character.HumanoidRootPart.Position).Magnitude
        distanceText.Text = string.format("Dist: %.1fm", distance)
    end)
    Connections[connection] = true
end

local function removePlayerESP(playerTarget)
    if ESPs[playerTarget] then
        ESPs[playerTarget].Billboard:Destroy()
        ESPs[playerTarget] = nil
    end
end

local function togglePlayersESP(state)
    Config.ESPPplayersEnabled = state
    if state then
        for _, plr in pairs(Players:GetPlayers()) do
            if plr ~= LocalPlayer then
                createPlayerESP(plr)
            end
        end
        -- Monitora novos jogadores
        Connections.PlayerAdded = Players.PlayerAdded:Connect(function(newPlr)
            if newPlr ~= LocalPlayer then
                createPlayerESP(newPlr)
            end
        end)
        Connections.PlayerRemoving = Players.PlayerRemoving:Connect(function(oldPlr)
            removePlayerESP(oldPlr)
        end)
    else
        for plr, espData in pairs(ESPs) do
            removePlayerESP(plr)
        end
        if Connections.PlayerAdded then Connections.PlayerAdded:Disconnect(); Connections.PlayerAdded = nil end
        if Connections.PlayerRemoving then Connections.PlayerRemoving:Disconnect(); Connections.PlayerRemoving = nil end
    end
end

-- A função toggleChestsESP precisaria de uma lógica para encontrar baús no workspace
-- e criar Billboards para eles, de forma similar ao ESP de jogadores.
-- Isso é altamente dependente do jogo, pois os baús não têm um padrão de nomenclatura.
local function toggleChestsESP(state)
    Config.ESPChestsEnabled = state
    -- Implementação de ESP de baús aqui
    -- Exemplo BÁSICO (altamente dependente do nome/estrutura do baú no jogo):
    if state then
        for _, v in pairs(workspace:GetDescendants()) do
            if v:IsA("BasePart") and (string.find(v.Name:lower(), "chest") or string.find(v.Name:lower(), "crate")) then
                -- Criar BillboardGui similar ao de jogadores para o baú
                if not ESPs[v] then -- Verifica se já existe um ESP para este baú
                    local billboard = Instance.new("BillboardGui")
                    billboard.AlwaysOnTop = true
                    billboard.Size = UDim2.new(0, 100, 0, 30)
                    billboard.StudsOffset = Vector3.new(0, 2, 0)
                    billboard.Adornee = v
                    billboard.Parent = UI.ESPContainer

                    local text = Instance.new("TextLabel")
                    text.Size = UDim2.new(1, 0, 1, 0)
                    text.BackgroundTransparency = 1
                    text.Text = "CHEST"
                    text.Font = Enum.Font.GothamBold
                    text.TextSize = 16
                    text.TextColor3 = Color3.fromRGB(255, 255, 0) -- Amarelo para baús
                    text.Parent = billboard
                    ESPs[v] = {Billboard = billboard}
                end
            end
        end
    else
        for obj, espData in pairs(ESPs) do
            -- Destroi apenas os ESPs de baús (filtrar por tipo ou nome aqui seria ideal)
            if obj:IsA("BasePart") and (string.find(obj.Name:lower(), "chest") or string.find(obj.Name:lower(), "crate")) then
                espData.Billboard:Destroy()
                ESPs[obj] = nil
            end
        end
    end
end


-- Abas (Tabs)

local function loadPlayerTab(frame)
    local layout = frame:FindFirstChildOfClass("UIListLayout")
    local currentYOffset = 0 -- Usaremos o layout para posicionamento automático

    createButton(frame, "WalkSpeed +5", function() setWalkSpeed(LocalPlayer.Character.Humanoid.WalkSpeed + 5) end)
    createButton(frame, "WalkSpeed -5", function() setWalkSpeed(math.max(16, LocalPlayer.Character.Humanoid.WalkSpeed - 5)) end)
    createButton(frame, "JumpPower +10", function() setJumpPower(LocalPlayer.Character.Humanoid.JumpPower + 10) end)
    createButton(frame, "JumpPower -10", function() setJumpPower(math.max(10, LocalPlayer.Character.Humanoid.JumpPower - 10)) end)

    createButton(frame, (Config.FlyEnabled and "Disable Fly" or "Enable Fly"), function(btn)
        toggleFly(not Config.FlyEnabled)
        btn.Text = (Config.FlyEnabled and "Disable Fly" or "Enable Fly")
    end)
    createButton(frame, (Config.NoclipEnabled and "Disable Noclip" or "Enable Noclip"), function(btn)
        toggleNoclip(not Config.NoclipEnabled)
        btn.Text = (Config.NoclipEnabled and "Disable Noclip" or "Enable Noclip")
    end)
end

local function loadVisualTab(frame)
    createButton(frame, (Config.ESPPplayersEnabled and "Disable ESP Players" or "Enable ESP Players"), function(btn)
        togglePlayersESP(not Config.ESPPplayersEnabled)
        btn.Text = (Config.ESPPplayersEnabled and "Disable ESP Players" or "Enable ESP Players")
    end)
    createButton(frame, (Config.ESPChestsEnabled and "Disable ESP Chests" or "Enable ESP Chests"), function(btn)
        toggleChestsESP(not Config.ESPChestsEnabled)
        btn.Text = (Config.ESPChestsEnabled and "Disable ESP Chests" or "Enable ESP Chests")
    end)
end

local function loadTeleportTab(frame)
    local playersTable = {}
    for _, plr in pairs(Players:GetPlayers()) do
        if plr ~= LocalPlayer then
            table.insert(playersTable, plr)
        end
    end

    -- Ordena a lista de jogadores por nome
    table.sort(playersTable, function(a, b)
        return a.Name < b.Name
    end)

    for _, plr in pairs(playersTable) do
        createButton(frame, "TP to "..plr.Name, function()
            teleportToPlayer(plr)
        end)
    end
end

local function loadMiscTab(frame)
    createButton(frame, "Rejoin", function()
        TeleportService:Teleport(game.PlaceId, LocalPlayer)
    end)
    createButton(frame, "Copy PlaceId", function()
        if setclipboard then
            setclipboard(tostring(game.PlaceId))
        else
            warn("VimtoHub: setclipboard não disponível.")
            -- Em alguns executores, setclipboard pode não existir.
            -- Você pode tentar um Prompt para o usuário copiar manualmente, se aplicável.
        end
    end)
    createButton(frame, "Hide UI (Toggle H)", function()
        UI.MainFrame.Visible = not UI.MainFrame.Visible
        Config.UIHidden = not Config.UIHidden
    end)
end

-- Inicialização da UI

local function initializeUI()
    local gui = Instance.new("ScreenGui", game:GetService("CoreGui"))
    gui.Name = "VimtoHub"

    UI.MainFrame = Instance.new("Frame")
    UI.MainFrame.Size = UDim2.new(0, 600, 0, 400)
    UI.MainFrame.Position = UDim2.new(0.5, -300, 0.5, -200)
    UI.MainFrame.BackgroundColor3 = Colors.Background
    UI.MainFrame.Active = true
    UI.MainFrame.Draggable = true
    UI.MainFrame.Parent = gui

    createCorner(UI.MainFrame, 12)
    createStroke(UI.MainFrame, Colors.Accent)

    local title = Instance.new("TextLabel", UI.MainFrame)
    title.Size = UDim2.new(1, 0, 0, 40)
    title.BackgroundTransparency = 1
    title.Text = "🍹 VIMTO HUB"
    title.Font = Enum.Font.GothamBold
    title.TextSize = 20
    title.TextColor3 = Colors.Accent
    title.TextWrapped = true

    UI.TabFrame = Instance.new("Frame", UI.MainFrame)
    UI.TabFrame.Size = UDim2.new(0, 120, 1, -40)
    UI.TabFrame.Position = UDim2.new(0, 0, 0, 40)
    UI.TabFrame.BackgroundTransparency = 1

    UI.ContentFrame = Instance.new("Frame", UI.MainFrame)
    UI.ContentFrame.Size = UDim2.new(1, -120, 1, -40)
    UI.ContentFrame.Position = UDim2.new(0, 120, 0, 40)
    UI.ContentFrame.BackgroundTransparency = 1

    -- Criar abas
    local playerTabBtn = createTab("Player","👤",loadPlayerTab)
    createTab("Visual","👁",loadVisualTab)
    createTab("Teleport","📍",loadTeleportTab)
    createTab("Misc","⚙️",loadMiscTab)

    -- Selecionar Player como inicial
    playerTabBtn.MouseButton1Click:Fire() -- Simula um clique para carregar a aba inicial
end

initializeUI()

-- Limpeza ao respawn do personagem
LocalPlayer.CharacterRemoving:Connect(function()
    toggleFly(false) -- Desliga o fly
    toggleNoclip(false) -- Desliga o noclip
    -- Garante que ESPs de jogadores não sejam perdidos, mas hides os billbords
    for _, espData in pairs(ESPs) do
        if espData.Billboard then
            espData.Billboard.Enabled = false
        end
    end
end)

LocalPlayer.CharacterAdded:Connect(function(character)
    -- Quando o personagem é adicionado, os ESPs precisam se re-adornar
    if Config.ESPPplayersEnabled then
        for _, plr in pairs(Players:GetPlayers()) do
            if plr ~= LocalPlayer and ESPs[plr] and ESPs[plr].Billboard then
                ESPs[plr].Billboard.Enabled = true
            end
        end
    end
    -- O Fly e Noclip devem ser reativados manualmente pela UI, se o usuário quiser
end)

-- Tecla de atalho para esconder/mostrar a UI (pode ser configurado)
UserInputService.InputBegan:Connect(function(input, gameProcessedEvent)
    if gameProcessedEvent then return end
    if input.KeyCode == Enum.KeyCode.H then
        UI.MainFrame.Visible = not UI.MainFrame.Visible
        Config.UIHidden = not Config.UIHidden
    end
end)

warn("VimtoHub Loaded!")
