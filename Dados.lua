-- Painel dinâmico para listar todos os objetos com "brainrot" no nome e mostrar a distância até o jogador

-- Configurações do painel
local FRAME_SIZE = UDim2.new(0, 340, 0, 430)
local FRAME_POS = UDim2.new(0, 20, 0, 60)
local BG_COLOR = Color3.fromRGB(25, 25, 25)
local TEXT_COLOR = Color3.fromRGB(255, 255, 255)

-- Serviços
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

-- Função: Pega posição de qualquer objeto relevante
local function getItemPosition(item)
    if item:IsA("BasePart") then
        return item.Position
    elseif item:IsA("Model") and item.PrimaryPart then
        return item.PrimaryPart.Position
    end
    return nil
end

-- Função: Calcula distância até o player
local function getDistancia(itemPos, character)
    local hrp = character and character:FindFirstChild("HumanoidRootPart")
    if hrp then
        return math.floor((itemPos - hrp.Position).Magnitude)
    end
    return nil
end

-- Função: Encontra todos objetos com "brainrot" no nome
local function getBrainrots()
    local encontrados = {}
    for _, obj in ipairs(game:GetDescendants()) do
        if string.find(obj.Name:lower(), "brainrot") then
            table.insert(encontrados, obj)
        end
    end
    return encontrados
end

-- Cria GUI
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "PainelBrainrots"
screenGui.Parent = LocalPlayer:FindFirstChild("PlayerGui") or LocalPlayer.PlayerGui

local frame = Instance.new("Frame")
frame.Size = FRAME_SIZE
frame.Position = FRAME_POS
frame.BackgroundColor3 = BG_COLOR
frame.BorderSizePixel = 0
frame.Parent = screenGui

local titulo = Instance.new("TextLabel")
titulo.Size = UDim2.new(1, 0, 0, 40)
titulo.BackgroundTransparency = 1
titulo.Text = "Brainrots encontrados:"
titulo.TextColor3 = TEXT_COLOR
titulo.Font = Enum.Font.SourceSansBold
titulo.TextSize = 22
titulo.Parent = frame

local scrollFrame = Instance.new("ScrollingFrame")
scrollFrame.Size = UDim2.new(1, -10, 1, -50)
scrollFrame.Position = UDim2.new(0, 5, 0, 45)
scrollFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
scrollFrame.ScrollBarThickness = 6
scrollFrame.BackgroundTransparency = 1
scrollFrame.Parent = frame

local layout = Instance.new("UIListLayout")
layout.Parent = scrollFrame
layout.SortOrder = Enum.SortOrder.LayoutOrder
layout.Padding = UDim.new(0, 5)

-- Labels dinâmicos
local itemLabels = {}

-- Cria painel/lista dos brainrots
local function criarPainel()
    itemLabels = {}
    scrollFrame:ClearAllChildren()
    layout.Parent = scrollFrame

    local brainrots = getBrainrots()

    for _, item in ipairs(brainrots) do
        local pos = getItemPosition(item)
        local label = Instance.new("TextLabel")
        label.Size = UDim2.new(1, -5, 0, 20)
        label.BackgroundTransparency = 1
        label.TextColor3 = TEXT_COLOR
        label.Font = Enum.Font.SourceSans
        label.TextSize = 18
        label.TextXAlignment = Enum.TextXAlignment.Left
        label.Parent = scrollFrame
        itemLabels[item] = label
    end

    scrollFrame.CanvasSize = UDim2.new(0, 0, 0, layout.AbsoluteContentSize.Y)
end

-- Atualiza distâncias (em tempo real)
local function atualizarDistancias()
    local character = LocalPlayer.Character
    for item, label in pairs(itemLabels) do
        local pos = getItemPosition(item)
        if pos then
            local distancia = getDistancia(pos, character)
            label.Text = item.Name .. (distancia and (" (" .. distancia .. " studs)") or "")
        else
            label.Text = item.Name
        end
    end
end

-- Atualiza painel se brainrots forem adicionados/removidos
game.DescendantAdded:Connect(criarPainel)
game.DescendantRemoving:Connect(criarPainel)

-- Atualiza distâncias todo frame
game:GetService("RunService").RenderStepped:Connect(atualizarDistancias)

-- Primeira atualização
criarPainel()
