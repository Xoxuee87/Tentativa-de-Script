--[[ 
    Brainrot Hub - Script Simplificado, Funcional e Aprimorado
    Execute este script no jogo Steel Brainrot
    
    Author: Kilo Code (Revisado por Assistente de IA)
    Date: 2025
]]

--[[ SERVIÇOS ]]
-- É uma boa prática obter os serviços do Roblox usando GetService para garantir que o script não quebre.
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local CoreGui = game:GetService("CoreGui")

--[[ JOGADOR ]]
-- Variáveis essenciais para controlar o personagem do jogador local.
local player = Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local humanoidRootPart = character:WaitForChild("HumanoidRootPart")

--[[ VARIÁVEIS GLOBAIS ]]
local savedPosition = nil

--[[ 
    FUNÇÕES PRINCIPAIS
]]

-- Função para teleporte.
-- ATENÇÃO: A manipulação direta do CFrame é facilmente detectada por sistemas anti-cheat.
local function simpleTeleport(position)
    if not humanoidRootPart or not position then return false end
    
    -- Teleporta o jogador diretamente para a nova posição.
    humanoidRootPart.CFrame = CFrame.new(position)
    
    -- Adiciona uma pequena espera e verifica se o teleporte funcionou.
    -- Alguns jogos podem "puxar" o jogador de volta (rubber banding). Esta é uma tentativa de contornar isso.
    task.wait(0.1)
    if (humanoidRootPart.Position - position).Magnitude > 5 then
        humanoidRootPart.CFrame = CFrame.new(position)
    end
    
    return true
end

-- Função para encontrar objetos próximos.
-- ATENÇÃO: Usar GetDescendants() no Workspace inteiro pode causar LAG em jogos grandes.
-- É uma abordagem simples, mas não a mais otimizada.
local function findNearbyObjects()
    local objects = {}
    local playerPos = humanoidRootPart.Position
    
    for _, obj in pairs(Workspace:GetDescendants()) do
        if obj:IsA("BasePart") or obj:IsA("Model") then
            local objPos = obj.Position
            -- Se for um modelo, tenta usar a posição de sua PrimaryPart.
            if obj:IsA("Model") and obj.PrimaryPart then
                objPos = obj.PrimaryPart.Position
            end
            
            local distance = (playerPos - objPos).Magnitude
            if distance < 100 then -- Considera objetos dentro de um raio de 100 studs.
                table.insert(objects, {
                    object = obj,
                    distance = distance,
                    position = objPos
                })
            end
        end
    end
    
    -- Ordena a tabela para que os objetos mais próximos apareçam primeiro.
    table.sort(objects, function(a, b) return a.distance < b.distance end)
    return objects
end

-- Função para listar todos os Remotes (Event e Function) no ReplicatedStorage.
local function listAllRemotes()
    print("=== REMOTES DISPONÍVEIS ===")
    local count = 0
    for _, obj in pairs(ReplicatedStorage:GetDescendants()) do
        if obj:IsA("RemoteEvent") or obj:IsA("RemoteFunction") then
            print("- Remote: " .. obj:GetFullName() .. " (" .. obj.ClassName .. ")")
            count = count + 1
        end
    end
    print("Total de remotes encontrados: " .. count)
    print("==========================")
end

-- Função para testar uma lista pré-definida de remotes comuns.
local function testRemotes()
    print("=== TESTANDO REMOTES COMUNS ===")
    local commonRemoteNames = {"Buy", "Collect", "Money", "Shop", "Purchase", "Grab", "Take", "Sell"}
    
    for _, remoteName in pairs(commonRemoteNames) do
        -- MELHORIA: Usamos FindFirstChild(remoteName, true) para buscar em todas as subpastas, não apenas na raiz.
        local remote = ReplicatedStorage:FindFirstChild(remoteName, true) 
        if remote and (remote:IsA("RemoteEvent") or remote:IsA("RemoteFunction")) then
            print("Testando remote encontrado: " .. remote:GetFullName())
            -- pcall é usado para executar a função de forma segura, sem quebrar o script se houver um erro.
            pcall(function() remote:FireServer() end)
            pcall(function() remote:FireServer("test_arg") end)
            pcall(function() remote:FireServer(123) end)
        end
    end
    print("========================")
end

--[[ 
    INTERFACE GRÁFICA (GUI)
]]

-- Garante que não haja outra GUI com o mesmo nome.
if CoreGui:FindFirstChild("BrainrotHub") then
    CoreGui:FindFirstChild("BrainrotHub"):Destroy()
end

local screenGui = Instance.new("ScreenGui")
screenGui.Name = "BrainrotHub"
screenGui.Parent = CoreGui

local frame = Instance.new("Frame")
frame.Size = UDim2.new(0, 300, 0, 450) -- Aumentei a altura para o novo botão
frame.Position = UDim2.new(0.5, -150, 0.5, -225)
frame.BackgroundColor3 = Color3.fromRGB(30, 30, 50)
frame.BorderSizePixel = 0
frame.Active = true
frame.Draggable = true
frame.Parent = screenGui

-- Título
local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, 0, 0, 40)
title.Text = "Brainrot Hub - Debug"
title.TextColor3 = Color3.fromRGB(255, 255, 255)
title.Font = Enum.Font.SourceSansBold
title.TextSize = 18
title.BackgroundColor3 = Color3.fromRGB(40, 40, 60)
title.Parent = frame

-- Botão de Fechar (MELHORIA)
local btnClose = Instance.new("TextButton")
btnClose.Size = UDim2.new(0, 30, 0, 30)
btnClose.Position = UDim2.new(1, -35, 0, 5)
btnClose.Text = "X"
btnClose.BackgroundColor3 = Color3.fromRGB(150, 50, 50)
btnClose.TextColor3 = Color3.fromRGB(255, 255, 255)
btnClose.Font = Enum.Font.SourceSansBold
btnClose.TextSize = 16
btnClose.Parent = frame
btnClose.MouseButton1Click:Connect(function()
    screenGui:Destroy()
end)

-- Layout dos botões
local buttonY = 50
local buttonHeight = 35
local buttonSpacing = 45

-- Função para criar botões e evitar repetição de código
local function createButton(text, position, color, onClick)
    local button = Instance.new("TextButton")
    button.Size = UDim2.new(0.8, 0, 0, buttonHeight)
    button.Position = UDim2.new(0.1, 0, 0, position)
    button.Text = text
    button.BackgroundColor3 = color
    button.TextColor3 = Color3.fromRGB(255, 255, 255)
    button.Font = Enum.Font.SourceSans
    button.TextSize = 14
    button.Parent = frame
    button.MouseButton1Click:Connect(onClick)
    return button
end

-- Botão Debug Completo
createButton("🔍 Debug Completo (Listar + Testar)", buttonY, Color3.fromRGB(60, 60, 100), function()
    listAllRemotes()
    testRemotes()
end)

-- Botão Salvar Posição
local btnSave = createButton("💾 Salvar Posição (Z)", buttonY + buttonSpacing, Color3.fromRGB(60, 100, 60), function()
    if humanoidRootPart then
        savedPosition = humanoidRootPart.Position
        print("Posição salva: " .. tostring(savedPosition))
        btnSave.Text = "✅ Posição Salva!"
        task.wait(2)
        btnSave.Text = "💾 Salvar Posição (Z)"
    end
end)

-- Botão Teleporte
createButton("🚀 Teleporte Salvo (X)", buttonY + buttonSpacing * 2, Color3.fromRGB(100, 60, 60), function()
    if savedPosition then
        simpleTeleport(savedPosition)
        print("Teleportado para posição salva.")
    else
        print("Nenhuma posição salva! Pressione Z para salvar.")
    end
end)

-- Botão Encontrar Objetos Próximos
createButton("🗺️ Listar Objetos Próximos", buttonY + buttonSpacing * 3, Color3.fromRGB(100, 100, 60), function()
    local objects = findNearbyObjects()
    print("=== OBJETOS PRÓXIMOS (até 10) ===")
    if #objects > 0 then
        for i = 1, math.min(10, #objects) do
            local objData = objects[i]
            print(i .. ". " .. objData.object.Name .. " - Distância: " .. string.format("%.1f", objData.distance))
        end
    else
        print("Nenhum objeto encontrado no raio de 100 studs.")
    end
    print("===================================")
end)

-- Botão Teleporte para Objeto
createButton("🎯 TP Objeto Mais Próximo", buttonY + buttonSpacing * 4, Color3.fromRGB(60, 100, 100), function()
    local objects = findNearbyObjects()
    if #objects > 0 then
        local closest = objects[1]
        local targetPos = closest.position + Vector3.new(0, 5, 0) -- Teleporta 5 studs acima para não ficar preso
        simpleTeleport(targetPos)
        print("Teleportado para: " .. closest.object.Name)
    else
        print("Nenhum objeto encontrado para teleportar!")
    end
end)

-- Botão Testar Remotes Comuns (Individual)
createButton("🧪 Testar Remotes Comuns", buttonY + buttonSpacing * 5, Color3.fromRGB(100, 60, 100), function()
    testRemotes()
end)


--[[
    INPUT E EVENTOS
]]

-- Atalhos de teclado
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    -- Impede a execução se o jogador estiver, por exemplo, digitando no chat.
    if gameProcessed then return end
    
    if input.KeyCode == Enum.KeyCode.Z then
        btnSave.MouseButton1Click:Fire() -- Dispara o evento do botão para reutilizar o código
    elseif input.KeyCode == Enum.KeyCode.X then
        if savedPosition then
            simpleTeleport(savedPosition)
        else
            print("Nenhuma posição salva!")
        end
    end
end)

-- Atualiza as variáveis do personagem quando ele respawnar. Essencial para que o script continue funcionando.
player.CharacterAdded:Connect(function(newCharacter)
    character = newCharacter
    humanoidRootPart = newCharacter:WaitForChild("HumanoidRootPart")
    print("Brainrot Hub: Novo personagem detectado. Variáveis atualizadas.")
end)

--[[ INICIALIZAÇÃO ]]
-- Mensagem de boas-vindas e instruções no console (Output).
task.spawn(function()
    task.wait(3)
    print("================================")
    print("=== BRAINROT HUB CARREGADO ===")
    print("Use Z para salvar sua posição.")
    print("Use X para teleportar para a posição salva.")
    print("A interface gráfica (GUI) está na sua tela.")
    print("================================")
    listAllRemotes()
end)
