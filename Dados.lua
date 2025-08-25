-- Serviços
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local Camera = workspace.CurrentCamera

-- Variáveis gerais
local espAtivo = true
local teamCheck = true
local mostrarVida = true
local flying = false
local flySpeed = 80
local flyConnection

-- Posição base para teleportar (altere conforme o mapa)
local basePosition = Vector3.new(0, 10, 0)

-- Criar GUI principal
local function criarInterface()
    -- Checar se já existe e destruir
    local oldGui = game.CoreGui:FindFirstChild("BrainrotGUI")
    if oldGui then oldGui:Destroy() end

    local ScreenGui = Instance.new("ScreenGui", game.CoreGui)
    ScreenGui.Name = "BrainrotGUI"

    -- Background principal
    local MainFrame = Instance.new("Frame", ScreenGui)
    MainFrame.Size = UDim2.new(0, 370, 0, 320)
    MainFrame.Position = UDim2.new(0, 20, 0, 80)
    MainFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    MainFrame.BorderSizePixel = 0
    MainFrame.Active = true
    MainFrame.Draggable = true

    -- Título
    local Titulo = Instance.new("TextLabel", MainFrame)
    Titulo.Size = UDim2.new(1, 0, 0, 30)
    Titulo.Position = UDim2.new(0, 0, 0, 0)
    Titulo.BackgroundTransparency = 1
    Titulo.Text = "Painel Brainrot (ESP + Funções)"
    Titulo.TextColor3 = Color3.new(1, 1, 1)
    Titulo.Font = Enum.Font.SourceSansBold
    Titulo.TextSize = 18

    -- Botões lado esquerdo (ESP, TeamCheck, HealthBar)
    local function criarBotao(texto, posY, func)
        local btn = Instance.new("TextButton", MainFrame)
        btn.Size = UDim2.new(0, 150, 0, 35)
        btn.Position = UDim2.new(0, 10, 0, posY)
        btn.Text = texto
        btn.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
        btn.TextColor3 = Color3.new(1,1,1)
        btn.BorderSizePixel = 0
        btn.MouseButton1Click:Connect(func)
        return btn
    end

    local btnESP = criarBotao("ESP ON/OFF", 50, function()
        espAtivo = not espAtivo
        print("ESP Ativo:", espAtivo)
    end)

    local btnTeamCheck = criarBotao("TeamCheck ON/OFF", 95, function()
        teamCheck = not teamCheck
        print("TeamCheck:", teamCheck)
    end)

    local btnVida = criarBotao("HealthBar ON/OFF", 140, function()
        mostrarVida = not mostrarVida
        print("Mostrar Vida:", mostrarVida)
    end)

    -- Funções Extras frame (super jump, speed, fly, roubar)
    local FuncoesFrame = Instance.new("Frame", MainFrame)
    FuncoesFrame.Size = UDim2.new(0, 190, 0, 260)
    FuncoesFrame.Position = UDim2.new(0, 170, 0, 40)
    FuncoesFrame.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
    FuncoesFrame.BorderSizePixel = 0

    local tituloFuncoes = Instance.new("TextLabel", FuncoesFrame)
    tituloFuncoes.Size = UDim2.new(1, 0, 0, 25)
    tituloFuncoes.Position = UDim2.new(0, 0, 0, 0)
    tituloFuncoes.BackgroundTransparency = 1
    tituloFuncoes.Text = "Funções Extras"
    tituloFuncoes.TextColor3 = Color3.new(1, 1, 1)
    tituloFuncoes.Font = Enum.Font.SourceSansBold
    tituloFuncoes.TextSize = 16

    local function criarBotaoFuncoes(texto, y, func)
        local btn = Instance.new("TextButton", FuncoesFrame)
        btn.Size = UDim2.new(0, 170, 0, 30)
        btn.Position = UDim2.new(0, 10, 0, y)
        btn.Text = texto
        btn.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
        btn.TextColor3 = Color3.new(1,1,1)
        btn.BorderSizePixel = 0
        btn.MouseButton1Click:Connect(func)
        return btn
    end

    -- Super Jump
    criarBotaoFuncoes("Super Jump", 40, function()
        local humanoid = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
        if humanoid then
            humanoid.JumpPower = 120
            print("Super Jump ativado")
        end
    end)

    -- Speed Boost
    criarBotaoFuncoes("Speed Boost", 80, function()
        local humanoid = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
        if humanoid then
            humanoid.WalkSpeed = 40
            print("Speed Boost ativado")
        end
    end)

    -- Fly Toggle
    local function ativarFly()
        local Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
        local HumanoidRootPart = Character:WaitForChild("HumanoidRootPart")

        local bodyGyro = Instance.new("BodyGyro")
        bodyGyro.P = 9e4
        bodyGyro.MaxTorque = Vector3.new(9e9, 9e9, 9e9)
        bodyGyro.CFrame = HumanoidRootPart.CFrame
        bodyGyro.Parent = HumanoidRootPart

        local bodyVelocity = Instance.new("BodyVelocity")
        bodyVelocity.Velocity = Vector3.new(0, 0, 0)
        bodyVelocity.MaxForce = Vector3.new(9e9, 9e9, 9e9)
        bodyVelocity.Parent = HumanoidRootPart

        flying = true

        flyConnection = RunService.RenderStepped:Connect(function()
            local camera = workspace.CurrentCamera
            local moveDirection = Vector3.new()

            if UserInputService:IsKeyDown(Enum.KeyCode.W) then
                moveDirection = moveDirection + camera.CFrame.LookVector
            end
            if UserInputService:IsKeyDown(Enum.KeyCode.S) then
                moveDirection = moveDirection - camera.CFrame.LookVector
            end
            if UserInputService:IsKeyDown(Enum.KeyCode.A) then
                moveDirection = moveDirection - camera.CFrame.RightVector
            end
            if UserInputService:IsKeyDown(Enum.KeyCode.D) then
                moveDirection = moveDirection + camera.CFrame.RightVector
            end
            if UserInputService:IsKeyDown(Enum.KeyCode.Space) then
                moveDirection = moveDirection + camera.CFrame.UpVector
            end
            if UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) then
                moveDirection = moveDirection - camera.CFrame.UpVector
            end

            if moveDirection.Magnitude > 0 then
                bodyVelocity.Velocity = moveDirection.Unit * flySpeed
            else
                bodyVelocity.Velocity = Vector3.new(0,0,0)
            end
            bodyGyro.CFrame = camera.CFrame
        end)
    end

    local function desativarFly()
        flying = false
        local Character = LocalPlayer.Character
        if Character then
            local root = Character:FindFirstChild("HumanoidRootPart")
            if root then
                for _, v in pairs(root:GetChildren()) do
                    if v:IsA("BodyGyro") or v:IsA("BodyVelocity") then
                        v:Destroy()
                    end
                end
            end
        end
        if flyConnection then
            flyConnection:Disconnect()
            flyConnection = nil
        end
    end

    local function alternarFly()
        if flying then
            desativarFly()
            print("Fly desativado")
        else
            ativarFly()
            print("Fly ativado")
        end
    end

    criarBotaoFuncoes("Fly ON/OFF", 120, alternarFly)

    -- Função roubar Brainrot pelo nome
    local function roubarBrainrotPorNome(nome)
        for _, obj in ipairs(workspace:GetDescendants()) do
            if (obj:IsA("Tool") or obj:IsA("Model")) and string.lower(obj.Name) == string.lower(nome) then
                local handle = obj:FindFirstChild("Handle") or obj:FindFirstChildWhichIsA("BasePart")
                if handle then
                    firetouchinterest(LocalPlayer.Character.HumanoidRootPart, handle, 0)
                    firetouchinterest(LocalPlayer.Character.HumanoidRootPart, handle, 1)
                    print("Coletado:", obj.Name)
                    wait(0.5)
                    LocalPlayer.Character:MoveTo(basePosition)
                    print("Teleportado para base")
                    return
                end
            end
        end
        print("Não encontrado:", nome)
    end

    -- Criar botões para roubar Brainrots
    local brainrots = {
        {nome = "Comum Brainrot", pos = 160},
        {nome = "Raro Brainrot", pos = 190},
        {nome = "Secreto Brainrot", pos = 220},
        {nome = "Mítico Brainrot", pos = 250},
        {nome = "Deus Brainrot", pos = 280},
    }

    for _, brainrot in pairs(brainrots) do
        criarBotaoFuncoes("Roubar "..brainrot.nome, brainrot.pos, function()
            roubarBrainrotPorNome(brainrot.nome)
        end)
    end

    -- Função para ESP (usando Drawing API)
    local Drawing = Drawing
    if not Drawing then
        warn("API Drawing não encontrada! ESP não funcionará.")
        return
    end

    local boxes = {}

    local function criarESP(player)
        local box = Drawing.new("Square")
        box.Color = Color3.fromRGB(255, 0, 0)
        box.Thickness = 1
        box.Filled = false
        box.Visible = false

        boxes[player] = box
    end

    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer then
            criarESP(player)
        end
    end

    Players.PlayerAdded:Connect(function(player)
        player.CharacterAdded:Connect(function()
            wait(1)
            criarESP(player)
        end)
    end)

    RunService.RenderStepped:Connect(function()
        for player, box in pairs(boxes) do
            pcall(function()
                if not espAtivo or not player.Character or not player.Character:FindFirstChild("HumanoidRootPart") then
                    box.Visible = false
                    return
                end

                local hrp = player.Character.HumanoidRootPart
                local pos, onScreen = Camera:WorldToViewportPoint(hrp.Position)

                if onScreen then
                    if teamCheck and player.Team == LocalPlayer.Team then
                        box.Visible = false
                    else
                        box.Size = Vector2.new(60, 100)
                        box.Position = Vector2.new(pos.X - 30, pos.Y - 50)
                        box.Color = player.Team == LocalPlayer.Team and Color3.fromRGB(0,255,0) or Color3.fromRGB(255,0,0)
                        box.Visible = true
                    end
                else
                    box.Visible = false
                end
            end)
        end
    end)
end

-- Tela de Loading
local function criarLoading()
    local LoadingGui = Instance.new("ScreenGui", game.CoreGui)
    LoadingGui.Name = "BrainrotLoader"

    local Background = Instance.new("Frame", LoadingGui)
    Background.Size = UDim2.new(1, 0, 1, 0)
    Background.BackgroundColor3 = Color3.fromRGB(15, 15, 15)

    local LoadingText = Instance.new("TextLabel", Background)
    LoadingText.Size = UDim2.new(0, 300, 0, 50)
    LoadingText.Position = UDim2.new(0.5, -150, 0.5, -25)
    LoadingText.Text = "Carregando"
    LoadingText.Font = Enum.Font.SourceSansBold
    LoadingText.TextSize = 32
    LoadingText.TextColor3 = Color3.new(1, 1, 1)
    LoadingText.BackgroundTransparency = 1

    -- Controlador do loop de loading
    local loadingAtivo = true

    coroutine.wrap(function()
        while loadingAtivo do
            for i = 0, 3 do
                LoadingText.Text = "Carregando" .. string.rep(".", i)
                wait(0.4)
            end
        end
    end)()

    wait(3) -- tempo de loading

    loadingAtivo = false

    local tween = TweenService:Create(Background, TweenInfo.new(1), {BackgroundTransparency = 1})
    tween:Play()
    tween.Completed:Wait()

    LoadingGui:Destroy()
end

-- Executar
criarLoading()
criarInterface()
