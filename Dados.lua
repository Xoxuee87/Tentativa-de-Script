-- Serviços
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

-- Variáveis
local menuAberto = false
local flying = false
local flySpeed = 80
local flyConnection
local spawnPos = nil
local invisivel = false

-- Criar GUI
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "BrainrotGui"
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = game.CoreGui

-- Menu Frame
local menuFrame = Instance.new("Frame", ScreenGui)
menuFrame.Size = UDim2.new(0, 260, 0, 420)
menuFrame.Position = UDim2.new(0, 60, 0, 100)
menuFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
menuFrame.BorderSizePixel = 0
menuFrame.Visible = false
menuFrame.AnchorPoint = Vector2.new(0,0)

-- Título
local titulo = Instance.new("TextLabel", menuFrame)
titulo.Size = UDim2.new(1, 0, 0, 50)
titulo.BackgroundTransparency = 1
titulo.TextColor3 = Color3.new(1, 1, 1)
titulo.Font = Enum.Font.GothamBold
titulo.TextSize = 26
titulo.Text = "Brainrot GUI"
titulo.TextStrokeTransparency = 0.7

-- Função para criar botão estilizado
local function criarBotao(texto, posY, parent, callback)
    local btn = Instance.new("TextButton", parent)
    btn.Size = UDim2.new(0, 220, 0, 40)
    btn.Position = UDim2.new(0, 20, 0, posY)
    btn.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    btn.BorderSizePixel = 0
    btn.TextColor3 = Color3.fromRGB(20, 20, 20)
    btn.Font = Enum.Font.GothamSemibold
    btn.TextSize = 20
    btn.Text = texto
    btn.AutoButtonColor = false
    btn.ClipsDescendants = true

    btn.MouseEnter:Connect(function()
        TweenService:Create(btn, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(200, 200, 200)}):Play()
    end)
    btn.MouseLeave:Connect(function()
        TweenService:Create(btn, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(255, 255, 255)}):Play()
    end)

    btn.MouseButton1Click:Connect(callback)
    return btn
end

-- Funções gameplay

local function ativarSuperJump()
    local humanoid = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
    if humanoid then
        humanoid.JumpPower = 120
        print("[BrainrotGUI] Super Jump ativado")
    end
end

local function ativarSpeed()
    local humanoid = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
    if humanoid then
        humanoid.WalkSpeed = 40
        print("[BrainrotGUI] Speed Boost ativado")
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

    print("[BrainrotGUI] Fly ativado")
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
    print("[BrainrotGUI] Fly desativado")
end

local function toggleFly()
    if flying then
        desativarFly()
    else
        ativarFly()
    end
end

local function roubarBrainrot()
    if not LocalPlayer.Character or not LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
        print("[BrainrotGUI] Personagem não encontrado.")
        return
    end
    if not spawnPos then
        print("[BrainrotGUI] Posição do spawn não salva ainda.")
        return
    end

    local coletado = false
    for _, obj in ipairs(workspace:GetDescendants()) do
        if obj:IsA("Tool") or obj:IsA("Model") then
            if string.find(string.lower(obj.Name), "brainrot") then
                local handle = obj:FindFirstChild("Handle") or obj:FindFirstChildWhichIsA("BasePart")
                if handle then
                    firetouchinterest(LocalPlayer.Character.HumanoidRootPart, handle, 0)
                    firetouchinterest(LocalPlayer.Character.HumanoidRootPart, handle, 1)
                    print("[BrainrotGUI] Brainrot coletado: "..obj.Name)
                    wait(0.5)
                    LocalPlayer.Character:MoveTo(spawnPos)
                    print("[BrainrotGUI] Teleportado para spawn salvo")
                    coletado = true
                    break
                end
            end
        end
    end

    if not coletado then
        print("[BrainrotGUI] Nenhum Brainrot encontrado.")
    end
end

local function salvarSpawn()
    if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
        spawnPos = LocalPlayer.Character.HumanoidRootPart.Position
        print("[BrainrotGUI] Posição do spawn salva:", spawnPos)
    else
        print("[BrainrotGUI] Não foi possível salvar posição do spawn.")
    end
end

local function toggleInvisibilidade()
    local character = LocalPlayer.Character
    if not character then return end

    invisivel = not invisivel

    for _, part in pairs(character:GetChildren()) do
        if part:IsA("BasePart") then
            if invisivel then
                part.Transparency = 1
                for _, decal in pairs(part:GetChildren()) do
                    if decal:IsA("Decal") then
                        decal.Transparency = 1
                    end
                end
            else
                part.Transparency = 0
                for _, decal in pairs(part:GetChildren()) do
                    if decal:IsA("Decal") then
                        decal.Transparency = 0
                    end
                end
            end
        end
    end
    print("[BrainrotGUI] Invisibilidade:", invisivel and "Ativada" or "Desativada")
end

-- Criar botões
criarBotao("Salvar Spawn Atual", 70, menuFrame, salvarSpawn)
criarBotao("Super Jump", 120, menuFrame, ativarSuperJump)
criarBotao("Speed Boost", 170, menuFrame, ativarSpeed)
criarBotao("Fly Toggle", 220, menuFrame, toggleFly)
criarBotao("Roubar Brainrot", 270, menuFrame, roubarBrainrot)
criarBotao("Invisível ON/OFF", 320, menuFrame, toggleInvisibilidade)
criarBotao("Desativar Fly", 370, menuFrame, desativarFly)

-- Botão fechar menu (canto superior direito)
local fecharBtn = Instance.new("TextButton", menuFrame)
fecharBtn.Size = UDim2.new(0, 30, 0, 30)
fecharBtn.Position = UDim2.new(1, -35, 0, 5)
fecharBtn.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
fecharBtn.TextColor3 = Color3.new(1,1,1)
fecharBtn.Text = "X"
fecharBtn.Font = Enum.Font.GothamBold
fecharBtn.TextSize = 22
fecharBtn.BorderSizePixel = 0
fecharBtn.MouseButton1Click:Connect(function()
    menuFrame.Visible = false
    menuAberto = false
end)

-- Ícone para abrir menu no mobile
local iconBtn = Instance.new("ImageButton", ScreenGui)
iconBtn.Size = UDim2.new(0, 50, 0, 50)
iconBtn.Position = UDim2.new(0, 10, 0, 10)
iconBtn.BackgroundTransparency = 1
iconBtn.Image = "rbxassetid://6031094673" -- Ícone de menu
iconBtn.ZIndex = 1000
iconBtn.MouseButton1Click:Connect(function()
    menuAberto = not menuAberto
    menuFrame.Visible = menuAberto
end)

-- Toggle menu com tecla M
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if not gameProcessed and input.KeyCode == Enum.KeyCode.M then
        menuAberto = not menuAberto
        menuFrame.Visible = menuAberto
    end
end)
