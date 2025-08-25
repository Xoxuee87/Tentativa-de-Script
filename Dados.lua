local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

-- Variável para guardar localização customizada
local customPosition = nil

local function setCustomLocation()
    local char = LocalPlayer.Character
    if char and char:FindFirstChild("HumanoidRootPart") then
        customPosition = char.HumanoidRootPart.Position
        print("Localização salva:", customPosition)
    end
end

local function teleportCustom()
    local char = LocalPlayer.Character
    if customPosition and char and char:FindFirstChild("HumanoidRootPart") then
        char.HumanoidRootPart.CFrame = CFrame.new(customPosition)
        print("Teleportado para localização salva!")
    else
        warn("Nenhuma localização foi salva ainda!")
    end
end

local function superJump()
    local char = LocalPlayer.Character
    if char then
        local hum = char:FindFirstChildWhichIsA("Humanoid")
        if hum then
            hum.JumpPower = 120
            hum:ChangeState(Enum.HumanoidStateType.Jumping)
        end
    end
end

local function speedBoost()
    local char = LocalPlayer.Character
    if char then
        local hum = char:FindFirstChildWhichIsA("Humanoid")
        if hum then
            hum.WalkSpeed = 40
        end
    end
end

local function teleportBase()
    local basePosition = Vector3.new(0, 10, 0)
    local char = LocalPlayer.Character
    if char and char:FindFirstChild("HumanoidRootPart") then
        char.HumanoidRootPart.CFrame = CFrame.new(basePosition)
    end
end

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
    local char = LocalPlayer.Character
    local hrp = char and char:FindFirstChild("HumanoidRootPart")
    local handle = obj:FindFirstChild("Handle") or obj:FindFirstChildWhichIsA("BasePart")
    if handle and hrp then
        firetouchinterest(hrp, handle, 0)
        firetouchinterest(hrp, handle, 1)
        wait(0.3)
        teleportBase()
        return true
    end
    return false
end

local function criarInterface()
    local oldGui = game.CoreGui:FindFirstChild("BrainrotGUI")
    if oldGui then oldGui:Destroy() end
    local gui = Instance.new("ScreenGui", game.CoreGui)
    gui.Name = "BrainrotGUI"
    local frame = Instance.new("Frame", gui)
    frame.Size = UDim2.new(0, 340, 0, 360)
    frame.Position = UDim2.new(0, 20, 0, 80)
    frame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    frame.BorderSizePixel = 0
    frame.Active = true
    frame.Draggable = true
    local titulo = Instance.new("TextLabel", frame)
    titulo.Size = UDim2.new(1, 0, 0, 28)
    titulo.BackgroundTransparency = 1
    titulo.Text = "Brainrot HUB + Localização"
    titulo.TextColor3 = Color3.new(1, 1, 1)
    titulo.Font = Enum.Font.SourceSansBold
    titulo.TextSize = 18

    local y = 40
    local function criarBotaoFuncoes(texto, y, func)
        local btn = Instance.new("TextButton", frame)
        btn.Size = UDim2.new(0, 200, 0, 26)
        btn.Position = UDim2.new(0, 15, 0, y)
        btn.Text = texto
        btn.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
        btn.TextColor3 = Color3.new(1,1,1)
        btn.BorderSizePixel = 0
        btn.Font = Enum.Font.SourceSans
        btn.TextSize = 14
        btn.MouseButton1Click:Connect(func)
        return btn
    end

    criarBotaoFuncoes("Super Jump", y, superJump)
    criarBotaoFuncoes("Speed Boost", y+30, speedBoost)
    criarBotaoFuncoes("Tp para Base", y+60, teleportBase)
    criarBotaoFuncoes("Salvar Localização", y+90, setCustomLocation)
    criarBotaoFuncoes("Tp para Localização Salva", y+120, teleportCustom)

    -- Botões de roubo de brainrot dinâmicos
    local yBrain = y+160
    local function atualizarBotaoRoubo()
        for _, child in pairs(frame:GetChildren()) do
            if child:IsA("TextButton") and child.Position.Y.Offset >= yBrain then child:Destroy() end
        end
        local lista = listarBrainrots()
        for i, obj in ipairs(lista) do
            criarBotaoFuncoes("Roubar '"..obj.Name.."'", yBrain + (i-1)*26, function()
                local status = roubarBrainrot(obj)
                if status then
                    print("Roubo realizado em: "..obj.Name)
                else
                    warn("Falha ao roubar: "..obj.Name)
                end
            end)
        end
    end
    atualizarBotaoRoubo()
    workspace.DescendantAdded:Connect(function(obj)
        if string.find(obj.Name:lower(), "brainrot") then atualizarBotaoRoubo() end
    end)
    workspace.DescendantRemoving:Connect(function(obj)
        if string.find(obj.Name:lower(), "brainrot") then atualizarBotaoRoubo() end
    end)
end

criarInterface()
