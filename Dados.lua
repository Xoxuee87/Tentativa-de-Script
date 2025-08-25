```lua name=listar_itens_com_painel.lua
-- Cria um painel na tela mostrando os nomes dos itens encontrados

local itens = {}

-- Tenta encontrar uma pasta chamada "Items", senão busca direto em workspace
local pastaItens = game.Workspace:FindFirstChild("Items")
if pastaItens then
    for _, item in pairs(pastaItens:GetChildren()) do
        table.insert(itens, item.Name)
    end
else
    for _, item in pairs(game.Workspace:GetChildren()) do
        if item:IsA("BasePart") or item:IsA("Model") then
            table.insert(itens, item.Name)
        end
    end
end

-- Cria o painel na tela
local player = game.Players.LocalPlayer
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "ItensPainel"
screenGui.Parent = player:WaitForChild("PlayerGui")

local frame = Instance.new("Frame")
frame.Size = UDim2.new(0, 300, 0, 400)
frame.Position = UDim2.new(0, 20, 0, 60)
frame.BackgroundColor3 = Color3.new(0.1, 0.1, 0.1)
frame.BorderSizePixel = 0
frame.Parent = screenGui

local titulo = Instance.new("TextLabel")
titulo.Size = UDim2.new(1, 0, 0, 40)
titulo.Position = UDim2.new(0, 0, 0, 0)
titulo.BackgroundTransparency = 1
titulo.Text = "Itens encontrados:"
titulo.TextColor3 = Color3.new(1, 1, 1)
titulo.Font = Enum.Font.SourceSansBold
titulo.TextSize = 22
titulo.Parent = frame

-- Adiciona cada item como um TextLabel no painel
for i, nome in ipairs(itens) do
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, -10, 0, 22)
    label.Position = UDim2.new(0, 5, 0, 40 + (i-1)*22)
    label.BackgroundTransparency = 1
    label.Text = nome
    label.TextColor3 = Color3.new(1, 1, 1)
    label.Font = Enum.Font.SourceSans
    label.TextSize = 18
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = frame
end

-- Se quiser fechar o painel, basta remover o ScreenGui:
-- screenGui:Destroy()
```
