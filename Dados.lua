-- Cria um painel na tela mostrando dinamicamente os nomes dos itens encontrados e a distância até o jogador

-- Configurações de estilo
local FRAME_SIZE = UDim2.new(0, 300, 0, 400)
local FRAME_POS = UDim2.new(0, 20, 0, 60)
local BG_COLOR = Color3.fromRGB(25, 25, 25)
local TEXT_COLOR = Color3.fromRGB(255, 255, 255)

-- Serviços
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local Workspace = game:GetService("Workspace")

-- Pasta dos itens (se existir)
local pastaItens = Workspace:FindFirstChild("Items") or Workspace

-- Criação da GUI principal
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "ItensPainel"
screenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")

local frame = Instance.new("Frame")
frame.Size = FRAME_SIZE
frame.Position = FRAME_POS
frame.BackgroundColor3 = BG_COLOR
frame.BorderSizePixel = 0
frame.Parent = screenGui

local titulo = Instance.new("TextLabel")
titulo.Size = UDim2.new(1, 0, 0, 40)
titulo.BackgroundTransparency = 1
titulo.Text = "Itens encontrados:"
titulo.TextColor3 = TEXT_COLOR
titulo.Font = Enum.Font.SourceSansBold
titulo.TextSize = 22
titulo.Parent = frame

-- Scroll para lista
local scrollFrame = Instance.new("ScrollingFrame")
scrollFrame.Size = UDim2.new(1, -10, 1, -50)
scrollFrame.Position = UDim2.new(0, 5, 0, 45)
scrollFrame.CanvasSize = UDim2.new(0, 0, 0, 0) -- ajustado dinamicamente
scrollFrame.ScrollBarThickness = 6
scrollFrame.BackgroundTransparency = 1
scrollFrame.Parent = frame

local layout = Instance.new("UIListLayout")
layout.Parent = scrollFrame
layout.SortOrder = Enum.SortOrder.LayoutOrder
layout.Padding = UDim.new(0, 5)

-- Função para calcular distância
local function getDistancia(itemPos, playerChar)
    local hrp = playerChar and playerChar:FindFirstChild("HumanoidRootPart")
    if hrp then
        return math.floor((itemPos - hrp.Position).Magnitude)
    end
    return nil
end

-- Função para atualizar a lista de itens
local function atualizarPainel()
    scrollFrame:ClearAllChildren()
    layout.Parent = scrollFrame -- recoloca o layout (ele some ao limpar)

    local character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()

    for _, item in ipairs(pastaItens:GetChildren()) do
        if item:IsA("BasePart") or item:IsA("Model") then
            local pos
            if item:IsA("BasePart") then
                pos = item.Position
            elseif item:IsA("Model") and item.PrimaryPart then
                pos = item.PrimaryPart.Position
            end

            if pos then
                local distancia = getDistancia(pos, character)
                local label = Instance.new("TextLabel")
                label.Size = UDim2.new(1, -5, 0, 20)
                label.BackgroundTransparency = 1
                label.Text = item.Name .. (distancia and (" (" .. distancia .. " studs)") or "")
                label.TextColor3 = TEXT_COLOR
                label.Font = Enum.Font.SourceSans
                label.TextSize = 18
                label.TextXAlignment = Enum.TextXAlignment.Left
                label.Parent = scrollFrame
            end
        end
    end

    -- Ajusta tamanho do scroll
    scrollFrame.CanvasSize = UDim2.new(0, 0, 0, layout.AbsoluteContentSize.Y)
end

-- Atualiza sempre que mudar a lista de itens
pastaItens.ChildAdded:Connect(atualizarPainel)
pastaItens.ChildRemoved:Connect(atualizarPainel)

-- Atualiza constantemente as distâncias
game:GetService("RunService").RenderStepped:Connect(atualizarPainel)

-- Primeira atualização
atualizarPainel()
