--[[
    Script ESP + HUB Brainrot (Roblox)
    - Painel dinâmico
    - ESP aprimorado
    - Botões de funções extras
    - Roubo inteligente de brainrots detectados
    - Visual melhorado e feedback
    - Loading refinado
    - Pronto para Potassium/Deploit
--]]

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
local Drawing = Drawing

local basePosition = Vector3.new(0, 10, 0) -- ajuste para seu mapa!

-- Loading refinado
local function criarLoading()
    local LoadingGui = Instance.new("ScreenGui", game.CoreGui)
    LoadingGui.Name = "BrainrotLoader"

    local Background = Instance.new("Frame", LoadingGui)
    Background.Size = UDim2.new(1, 0, 1, 0)
    Background.BackgroundColor3 = Color3.fromRGB(15, 15, 15)

    local LoadingText = Instance.new("TextLabel", Background)
    LoadingText.Size = UDim2.new(0, 300, 0, 50)
    LoadingText.Position = UDim2.new(0.5, -150, 0.5, -25)
    LoadingText.Text = "Carregando..."
    LoadingText.Font = Enum.Font.SourceSansBold
    LoadingText.TextSize = 32
    LoadingText.TextColor3 = Color3.new(1, 1, 1)
    LoadingText.BackgroundTransparency = 1
    local loadingAtivo = true

    coroutine.wrap(function()
        while loadingAtivo do
            for i = 0, 3 do
                LoadingText.Text = "Carregando" .. string.rep(".", i)
                wait(0.4)
            end
        end
    end)()

    wait(2.5)
    loadingAtivo = false
    local tween = TweenService:Create(Background, TweenInfo.new(1), {BackgroundTransparency = 1})
    tween:Play()
    tween.Completed:Wait()
    LoadingGui:Destroy()
end

-- Funções extras
local function superJump()
    local humanoid = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
    if humanoid then
        humanoid.JumpPower = 120
        print("Super Jump ativado")
    end
end

local function speedBoost()
    local humanoid = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
    if humanoid then
        humanoid.WalkSpeed = 40
        print("Speed Boost ativado")
    end
end

local function teleportBase()
    if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
        LocalPlayer.Character:MoveTo(basePosition)
        print("Teleportado para base")
    end
end

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
        if UserInputService:IsKeyDown(Enum.KeyCode.W) then moveDirection = moveDirection + camera.CFrame.LookVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.S) then moveDirection = moveDirection - camera.CFrame.LookVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.A) then moveDirection = moveDirection - camera.CFrame.RightVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.D) then moveDirection = moveDirection + camera.CFrame.RightVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.Space) then moveDirection = moveDirection + camera.CFrame.UpVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) then moveDirection = moveDirection - camera.CFrame.UpVector end
        bodyVelocity.Velocity = moveDirection.Magnitude > 0 and moveDirection.Unit * flySpeed or Vector3.new()
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
                if v:IsA("BodyGyro") or v:IsA("BodyVelocity") then v:Destroy() end
            end
        end
    end
    if flyConnection then flyConnection:Disconnect(); flyConnection = nil end
end

local function alternarFly()
    if flying then desativarFly() print("Fly desativado")
    else ativarFly() print("Fly ativado") end
end

-- Função para buscar brainrots pelo nome (dinâmico)
local function listarBrainrots()
    local encontrados = {}
    for _, obj in ipairs(workspace:GetDescendants()) do
        if (obj:IsA("Tool") or obj:IsA("Model")) and string.find(obj.Name:lower(), "brainrot") then
            table.insert(encontrados, obj)
        end
    end
    return encontrados
end

local function roubarBrainrot(obj)
    local handle = obj:FindFirstChild("Handle") or obj:FindFirstChildWhichIsA("BasePart")
    if handle and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
        firetouchinterest(LocalPlayer.Character.HumanoidRootPart, handle, 0)
        firetouchinterest(LocalPlayer.Character.HumanoidRootPart, handle, 1)
        print("Coletado:", obj.Name)
        wait(0.5)
        teleportBase()
        return true
    end
    return false
end

-- Painel principal
local function criarInterface()
    local oldGui = game.CoreGui:FindFirstChild("BrainrotGUI")
    if oldGui then oldGui:Destroy() end
    local ScreenGui = Instance.new("ScreenGui", game.CoreGui)
    ScreenGui.Name = "BrainrotGUI"

    local MainFrame = Instance.new("Frame", ScreenGui)
    MainFrame.Size = UDim2.new(0, 390, 0, 340)
    MainFrame.Position = UDim2.new(0, 20, 0, 80)
    MainFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    MainFrame.BorderSizePixel = 0
    MainFrame.Active = true
    MainFrame.Draggable = true

    local Titulo = Instance.new("TextLabel", MainFrame)
    Titulo.Size = UDim2.new(1, 0, 0, 36)
    Titulo.BackgroundTransparency = 1
    Titulo.Text = "Brainrot HUB (ESP + Funções)"
    Titulo.TextColor3 = Color3.new(1, 1, 1)
    Titulo.Font = Enum.Font.SourceSansBold
    Titulo.TextSize = 20

    -- Botões lado esquerdo (ESP, TeamCheck, HealthBar)
    local function criarBotao(texto, posY, estado, func)
        local btn = Instance.new("TextButton", MainFrame)
        btn.Size = UDim2.new(0, 155, 0, 36)
        btn.Position = UDim2.new(0, 12, 0, posY)
        btn.Text = texto .. " [" .. (estado and "ON" or "OFF") .. "]"
        btn.BackgroundColor3 = estado and Color3.fromRGB(40, 90, 40) or Color3.fromRGB(70, 30, 30)
        btn.TextColor3 = Color3.new(1,1,1)
        btn.BorderSizePixel = 0
        btn.Font = Enum.Font.SourceSansBold
        btn.TextSize = 16
        btn.MouseButton1Click:Connect(function()
            func()
            btn.Text = texto .. " [" .. (estado and "ON" or "OFF") .. "]"
            btn.BackgroundColor3 = estado and Color3.fromRGB(40, 90, 40) or Color3.fromRGB(70, 30, 30)
        end)
        return btn
    end

    criarBotao("ESP", 50, espAtivo, function() espAtivo = not espAtivo end)
    criarBotao("TeamCheck", 95, teamCheck, function() teamCheck = not teamCheck end)
    criarBotao("HealthBar", 140, mostrarVida, function() mostrarVida = not mostrarVida end)

    -- Funções extras frame
    local FuncoesFrame = Instance.new("Frame", MainFrame)
    FuncoesFrame.Size = UDim2.new(0, 200, 0, 270)
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
        btn.Size = UDim2.new(0, 180, 0, 30)
        btn.Position = UDim2.new(0, 10, 0, y)
        btn.Text = texto
        btn.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
        btn.TextColor3 = Color3.new(1,1,1)
        btn.BorderSizePixel = 0
        btn.Font = Enum.Font.SourceSans
        btn.TextSize = 16
        btn.MouseButton1Click:Connect(func)
        return btn
    end

    criarBotaoFuncoes("Super Jump", 35, superJump)
    criarBotaoFuncoes("Speed Boost", 70, speedBoost)
    criarBotaoFuncoes("Fly ON/OFF", 105, alternarFly)
    criarBotaoFuncoes("Ir para Base", 140, teleportBase)

    -- Botões dinâmicos para brainrots encontrados
    local tituloRoubo = Instance.new("TextLabel", FuncoesFrame)
    tituloRoubo.Size = UDim2.new(1, 0, 0, 25)
    tituloRoubo.Position = UDim2.new(0, 0, 0, 175)
    tituloRoubo.BackgroundTransparency = 1
    tituloRoubo.Text = "Roubar Brainrots encontrados:"
    tituloRoubo.TextColor3 = Color3.new(1, 1, 1)
    tituloRoubo.Font = Enum.Font.SourceSansBold
    tituloRoubo.TextSize = 14

    local function atualizarBotaoRoubo()
        -- Remove antigos
        for _, child in pairs(FuncoesFrame:GetChildren()) do
            if child:IsA("TextButton") and child.Position.Y.Offset > 200 then child:Destroy() end
        end
        local lista = listarBrainrots()
        local yBase = 205
        for i, obj in ipairs(lista) do
            criarBotaoFuncoes("Roubar '"..obj.Name.."'", yBase + (i-1)*32, function()
                if roubarBrainrot(obj) then
                    warn("Roubo realizado em: "..obj.Name)
                else
                    warn("Falha ao roubar: "..obj.Name)
                end
            end)
        end
    end

    atualizarBotaoRoubo()
    workspace.DescendantAdded:Connect(atualizarBotaoRoubo)
    workspace.DescendantRemoving:Connect(atualizarBotaoRoubo)

    -- ESP aprimorado (Drawing API)
    if not Drawing then
        warn("API Drawing não encontrada! ESP não funcionará.")
        return
    end

    local boxes = {}
    local texts = {}
    local healths = {}

    local function criarESP(player)
        if not boxes[player] then
            local box = Drawing.new("Square")
            box.Color = Color3.fromRGB(255, 0, 0)
            box.Thickness = 2
            box.Filled = false
            box.Visible = false
            boxes[player] = box

            local txt = Drawing.new("Text")
            txt.Size = 16
            txt.Center = true
            txt.Outline = true
            txt.Color = Color3.new(1,1,1)
            txt.Visible = false
            texts[player] = txt

            local health = Drawing.new("Text")
            health.Size = 14
            health.Center = true
            health.Outline = true
            health.Color = Color3.fromRGB(0,255,0)
            health.Visible = false
            healths[player] = health
        end
    end

    local function removerESP(player)
        if boxes[player] then boxes[player]:Remove(); boxes[player] = nil end
        if texts[player] then texts[player]:Remove(); texts[player] = nil end
        if healths[player] then healths[player]:Remove(); healths[player] = nil end
    end

    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer then criarESP(player) end
    end
    Players.PlayerAdded:Connect(function(player)
        if player ~= LocalPlayer then
            player.CharacterAdded:Connect(function() wait(1) criarESP(player) end)
        end
    end)
    Players.PlayerRemoving:Connect(removerESP)

    RunService.RenderStepped:Connect(function()
        for player, box in pairs(boxes) do
            pcall(function()
                if not espAtivo or not player.Character or not player.Character:FindFirstChild("HumanoidRootPart") then
                    box.Visible = false
                    texts[player].Visible = false
                    healths[player].Visible = false
                    return
                end

                local hrp = player.Character.HumanoidRootPart
                local pos, onScreen = Camera:WorldToViewportPoint(hrp.Position)
                if onScreen then
                    local corTime = player.Team == LocalPlayer.Team and Color3.fromRGB(0,255,0) or Color3.fromRGB(255,0,0)
                    box.Size = Vector2.new(60, 100)
                    box.Position = Vector2.new(pos.X - 30, pos.Y - 50)
                    box.Color = corTime
                    box.Visible = true

                    texts[player].Position = Vector2.new(pos.X, pos.Y - 60)
                    texts[player].Text = player.DisplayName or player.Name
                    texts[player].Color = corTime
                    texts[player].Visible = true

                    if mostrarVida then
                        local humanoid = player.Character:FindFirstChildOfClass("Humanoid")
                        if humanoid then
                            healths[player].Position = Vector2.new(pos.X, pos.Y + 60)
                            healths[player].Text = "HP: "..math.floor(humanoid.Health)
                            healths[player].Color = Color3.fromRGB(0,255,0)
                            healths[player].Visible = true
                        else
                            healths[player].Visible = false
                        end
                    else
                        healths[player].Visible = false
                    end
                else
                    box.Visible = false
                    texts[player].Visible = false
                    healths[player].Visible = false
                end
            end)
        end
    end)
end

-- EXECUÇÃO
criarLoading()
criarInterface()
