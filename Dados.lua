--[[ 
    Brainrot Hub - Script Simplificado e Funcional
    Execute este script no jogo Steel Brainrot
    
    Author: Kilo Code
    Date: 2025
]]

-- Services
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

-- Player
local player = Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local humanoidRootPart = character:WaitForChild("HumanoidRootPart")

-- Variáveis
local savedPosition = nil
local isTeleporting = false

-- Função para teleporte simples e direto
local function simpleTeleport(position)
    if not humanoidRootPart or not position then return false end
    
    isTeleporting = true
    
    -- Teleporte direto
    humanoidRootPart.CFrame = CFrame.new(position)
    
    -- Verificar se funcionou
    task.wait(0.1)
    if humanoidRootPart.Position:Distance(position) > 5 then
        -- Se não funcionou, tentar novamente
        humanoidRootPart.CFrame = CFrame.new(position)
    end
    
    isTeleporting = false
    return true
end

-- Função para encontrar objetos próximos
local function findNearbyObjects()
    local objects = {}
    local playerPos = humanoidRootPart.Position
    
    for _, obj in pairs(Workspace:GetDescendants()) do
        if obj:IsA("BasePart") or obj:IsA("Model") then
            local objPos = obj.Position
            if obj:IsA("Model") and obj.PrimaryPart then
                objPos = obj.PrimaryPart.Position
            end
            
            local distance = (playerPos - objPos).Magnitude
            if distance < 100 then -- Objetos dentro de 100 studs
                table.insert(objects, {
                    object = obj,
                    distance = distance,
                    position = objPos
                })
            end
        end
    end
    
    -- Ordenar por distância
    table.sort(objects, function(a, b) return a.distance < b.distance end)
    return objects
end

-- Função para listar todos os remotes
local function listAllRemotes()
    print("=== REMOTES DISPONÍVEIS ===")
    local count = 0
    for _, obj in pairs(ReplicatedStorage:GetDescendants()) do
        if obj:IsA("RemoteEvent") or obj:IsA("RemoteFunction") then
            print("Remote: " .. obj.Name .. " (" .. obj.ClassName .. ")")
            count = count + 1
        end
    end
    print("Total de remotes: " .. count)
    print("==========================")
end

-- Função para testar remotes
local function testRemotes()
    print("=== TESTANDO REMOTES ===")
    local remotes = {"Buy", "Collect", "Money", "Shop", "Purchase", "Grab", "Take"}
    
    for _, remoteName in pairs(remotes) do
        local remote = ReplicatedStorage:FindFirstChild(remoteName)
        if remote and (remote:IsA("RemoteEvent") or remote:IsA("RemoteFunction")) then
            print("Testando remote: " .. remoteName)
            -- Tentar diferentes formatos
            pcall(function() remote:FireServer() end)
            pcall(function() remote:FireServer("test") end)
            pcall(function() remote:FireServer(1) end)
        end
    end
    print("========================")
end

-- Interface simples
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "BrainrotHub"
screenGui.Parent = game.CoreGui

local frame = Instance.new("Frame")
frame.Size = UDim2.new(0, 300, 0, 400)
frame.Position = UDim2.new(0.5, -150, 0.5, -200)
frame.BackgroundColor3 = Color3.fromRGB(30, 30, 50)
frame.BorderSizePixel = 0
frame.Active = true
frame.Draggable = true
frame.Parent = screenGui

-- Título
local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, 0, 0, 40)
title.Position = UDim2.new(0, 0, 0, 0)
title.Text = "Brainrot Hub - Debug"
title.TextColor3 = Color3.fromRGB(255, 255, 255)
title.Font = Enum.Font.SourceSansBold
title.TextSize = 18
title.BackgroundTransparency = 1
title.Parent = frame

-- Botões
local buttonY = 50
local buttonHeight = 35
local buttonSpacing = 45

-- Botão Debug
local btnDebug = Instance.new("TextButton")
btnDebug.Size = UDim2.new(0.8, 0, 0, buttonHeight)
btnDebug.Position = UDim2.new(0.1, 0, 0, buttonY)
btnDebug.Text = "🔍 Debug - Listar Remotes"
btnDebug.BackgroundColor3 = Color3.fromRGB(60, 60, 100)
btnDebug.TextColor3 = Color3.fromRGB(255, 255, 255)
btnDebug.Font = Enum.Font.SourceSans
btnDebug.TextSize = 14
btnDebug.Parent = frame

btnDebug.MouseButton1Click:Connect(function()
    listAllRemotes()
    testRemotes()
end)

-- Botão Salvar Posição
local btnSave = Instance.new("TextButton")
btnSave.Size = UDim2.new(0.8, 0, 0, buttonHeight)
btnSave.Position = UDim2.new(0.1, 0, 0, buttonY + buttonSpacing)
btnSave.Text = "💾 Salvar Posição (Z)"
btnSave.BackgroundColor3 = Color3.fromRGB(60, 100, 60)
btnSave.TextColor3 = Color3.fromRGB(255, 255, 255)
btnSave.Font = Enum.Font.SourceSans
btnSave.TextSize = 14
btnSave.Parent = frame

btnSave.MouseButton1Click:Connect(function()
    if humanoidRootPart then
        savedPosition = humanoidRootPart.Position
        print("Posição salva: " .. tostring(savedPosition))
        btnSave.Text = "✅ Posição Salva!"
        task.wait(2)
        btnSave.Text = "💾 Salvar Posição (Z)"
    end
end)

-- Botão Teleporte
local btnTP = Instance.new("TextButton")
btnTP.Size = UDim2.new(0.8, 0, 0, buttonHeight)
btnTP.Position = UDim2.new(0.1, 0, 0, buttonY + buttonSpacing * 2)
btnTP.Text = "🚀 Teleporte (X)"
btnTP.BackgroundColor3 = Color3.fromRGB(100, 60, 60)
btnTP.TextColor3 = Color3.fromRGB(255, 255, 255)
btnTP.Font = Enum.Font.SourceSans
btnTP.TextSize = 14
btnTP.Parent = frame

btnTP.MouseButton1Click:Connect(function()
    if savedPosition then
        simpleTeleport(savedPosition)
        print("Teleportado para posição salva")
    else
        print("Nenhuma posição salva!")
    end
end)

-- Botão Encontrar Objetos
local btnFind = Instance.new("TextButton")
btnFind.Size = UDim2.new(0.8, 0, 0, buttonHeight)
btnFind.Position = UDim2.new(0.1, 0, 0, buttonY + buttonSpacing * 3)
btnFind.Text = "🔍 Encontrar Objetos Próximos"
btnFind.BackgroundColor3 = Color3.fromRGB(100, 100, 60)
btnFind.TextColor3 = Color3.fromRGB(255, 255, 255)
btnFind.Font = Enum.Font.SourceSans
btnFind.TextSize = 14
btnFind.Parent = frame

btnFind.MouseButton1Click:Connect(function()
    local objects = findNearbyObjects()
    print("=== OBJETOS PRÓXIMOS ===")
    for i = 1, math.min(10, #objects) do
        local obj = objects[i]
        print(i .. ". " .. obj.object.Name .. " - Distância: " .. math.floor(obj.distance))
    end
    print("========================")
end)

-- Botão Testar Remotes
local btnTest = Instance.new("TextButton")
btnTest.Size = UDim2.new(0.8, 0, 0, buttonHeight)
btnTest.Position = UDim2.new(0.1, 0, 0, buttonY + buttonSpacing * 4)
btnTest.Text = "🧪 Testar Remotes"
btnTest.BackgroundColor3 = Color3.fromRGB(100, 60, 100)
btnTest.TextColor3 = Color3.fromRGB(255, 255, 255)
btnTest.Font = Enum.Font.SourceSans
btnTest.TextSize = 14
btnTest.Parent = frame

btnTest.MouseButton1Click:Connect(function()
    testRemotes()
end)

-- Botão Teleporte para Objeto
local btnTPObj = Instance.new("TextButton")
btnTPObj.Size = UDim2.new(0.8, 0, 0, buttonHeight)
btnTPObj.Position = UDim2.new(0.1, 0, 0, buttonY + buttonSpacing * 5)
btnTPObj.Text = "🎯 TP para Objeto Mais Próximo"
btnTPObj.BackgroundColor3 = Color3.fromRGB(60, 100, 100)
btnTPObj.TextColor3 = Color3.fromRGB(255, 255, 255)
btnTPObj.Font = Enum.Font.SourceSans
btnTPObj.TextSize = 14
btnTPObj.Parent = frame

btnTPObj.MouseButton1Click:Connect(function()
    local objects = findNearbyObjects()
    if #objects > 0 then
        local closest = objects[1]
        local targetPos = closest.position + Vector3.new(0, 5, 0)
        simpleTeleport(targetPos)
        print("Teleportado para: " .. closest.object.Name)
    else
        print("Nenhum objeto encontrado!")
    end
end)

-- Atalhos de teclado
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    
    if input.KeyCode == Enum.KeyCode.Z then
        if humanoidRootPart then
            savedPosition = humanoidRootPart.Position
            print("Posição salva: " .. tostring(savedPosition))
        end
    elseif input.KeyCode == Enum.KeyCode.X then
        if savedPosition then
            simpleTeleport(savedPosition)
        else
            print("Nenhuma posição salva!")
        end
    end
end)

-- Atualizar personagem quando respawnar
player.CharacterAdded:Connect(function(newCharacter)
    character = newCharacter
    humanoidRootPart = character:WaitForChild("HumanoidRootPart")
end)

-- Debug automático após 5 segundos
task.spawn(function()
    task.wait(5)
    print("=== BRAINROT HUB CARREGADO ===")
    print("Use Z para salvar posição, X para teleportar")
    print("Clique nos botões para debug e testes")
    listAllRemotes()
end)
