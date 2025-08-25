--[[ 
    Brainrot Hub - Upwalk intacto + Teleporte personalizado + funções revisadas
    - Upwalk: NÃO ALTERADO!
    - Teleporte: Salvar ponto e teleportar para ponto salvo
    - Coletar dinheiro e Comprar Brainrot OP: Revisados
    - AntiSteal: Revisado
    - Interface gráfica simples
    - Atalhos: Z=Salvar TP | X=Ir para TP | C=Coletar dinheiro | V=Comprar Brainrot OP
]]

local Players = game:GetService("Players")
local player = Players.LocalPlayer
local UIS = game:GetService("UserInputService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")
local TweenService = game:GetService("TweenService")

-- ====================
-- Sistema de Teleporte (Salvar ponto e ir para ponto salvo)
-- ====================
local savedTP = nil
local function saveTeleportPoint()
    if player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
        savedTP = player.Character.HumanoidRootPart.Position
        return true
    end
    return false
end

local function teleportToSavedPoint()
    if savedTP and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
        player.Character.HumanoidRootPart.CFrame = CFrame.new(savedTP)
        return true
    end
    return false
end

-- ====================
-- Coletar dinheiro (revisado)
-- ====================
local function collectMoney()
    local remote = ReplicatedStorage:FindFirstChild("CollectMoney")
    if remote then
        remote:FireServer(math.random())
        return true
    end
    return false
end

-- ====================
-- Comprar Brainrot OP (revisado)
-- ====================
local function buyOPBrainrot()
    local remote = ReplicatedStorage:FindFirstChild("BuyBrainrot")
    if remote then
        remote:FireServer("GodOP_"..tostring(math.random(1000,9999)))
        return true
    end
    return false
end

-- ====================
-- AntiSteal (Revisado)
-- ====================
local antiStealEnabled = false
local antiStealPart = nil
function activateAntiSteal()
    if antiStealEnabled then return end
    antiStealEnabled = true
    if player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
        antiStealPart = Instance.new("Part", Workspace)
        antiStealPart.Anchored = true
        antiStealPart.Size = Vector3.new(18, 2, 18)
        antiStealPart.Position = player.Character.HumanoidRootPart.Position + Vector3.new(0,4,0)
        antiStealPart.Transparency = 0.7
        antiStealPart.BrickColor = BrickColor.new("Bright red")
        antiStealPart.CanCollide = false
        antiStealPart.Name = "AntiStealZone"
        antiStealPart.Touched:Connect(function(hit)
            local hPlayer = Players:GetPlayerFromCharacter(hit.Parent)
            if hPlayer and hPlayer ~= player then
                game:Shutdown()
            end
        end)
    end
end

function deactivateAntiSteal()
    antiStealEnabled = false
    if antiStealPart and antiStealPart.Parent then
        antiStealPart:Destroy()
    end
    antiStealPart = nil
end

-- ====================
-- UPWALK (MANTIDO INTACTO)
-- ====================
local upwalkEnabled = false
local upwalkPart = nil
function enableUpwalk()
    if upwalkEnabled then return end
    upwalkEnabled = true
    upwalkPart = Instance.new("Part", Workspace)
    upwalkPart.Name = "UpwalkPlatform"
    upwalkPart.Size = Vector3.new(20, 1, 20)
    upwalkPart.Anchored = true
    upwalkPart.CanCollide = true
    upwalkPart.Transparency = 0.5
    upwalkPart.Position = player.Character and player.Character:FindFirstChild("HumanoidRootPart") and (player.Character.HumanoidRootPart.Position - Vector3.new(0,3,0)) or Vector3.new(0,3,0)
    local tween = TweenService:Create(upwalkPart, TweenInfo.new(1.2), {Position = upwalkPart.Position + Vector3.new(0,20,0)})
    tween:Play()
end

function disableUpwalk()
    upwalkEnabled = false
    if upwalkPart and upwalkPart.Parent then
        upwalkPart:Destroy()
    end
    upwalkPart = nil
end

-- ====================
-- HUB UI
-- ====================
local ScreenGui = Instance.new("ScreenGui", game.CoreGui)
ScreenGui.Name = "BrainrotHub"
local Frame = Instance.new("Frame", ScreenGui)
Frame.Size = UDim2.new(0, 260, 0, 350)
Frame.Position = UDim2.new(0.03, 0, 0.18, 0)
Frame.BackgroundColor3 = Color3.fromRGB(22,22,33)
Frame.BorderSizePixel = 0
Frame.Active = true
Frame.Draggable = true

local title = Instance.new("TextLabel", Frame)
title.Size = UDim2.new(1, 0, 0, 36)
title.Position = UDim2.new(0, 0, 0, 0)
title.Text = "Brainrot Hub"
title.TextColor3 = Color3.fromRGB(255,255,255)
title.Font = Enum.Font.SourceSansBold
title.TextSize = 20
title.BackgroundTransparency = 1

local btnTP1 = Instance.new("TextButton", Frame)
btnTP1.Size = UDim2.new(1, -28, 0, 38)
btnTP1.Position = UDim2.new(0, 14, 0, 54)
btnTP1.Text = "Salvar ponto TP"
btnTP1.BackgroundColor3 = Color3.fromRGB(44,70,44)
btnTP1.TextColor3 = Color3.new(1,1,1)
btnTP1.Font = Enum.Font.SourceSans
btnTP1.TextSize = 17
btnTP1.MouseButton1Click:Connect(function()
    if saveTeleportPoint() then
        btnTP1.Text = "Ponto salvo!"
        wait(1.3)
        btnTP1.Text = "Salvar ponto TP"
    else
        btnTP1.Text = "Erro ao salvar"
        wait(1.3)
        btnTP1.Text = "Salvar ponto TP"
    end
end)

local btnTP2 = Instance.new("TextButton", Frame)
btnTP2.Size = UDim2.new(1, -28, 0, 38)
btnTP2.Position = UDim2.new(0, 14, 0, 102)
btnTP2.Text = "Teleportar para ponto"
btnTP2.BackgroundColor3 = Color3.fromRGB(44,44,70)
btnTP2.TextColor3 = Color3.new(1,1,1)
btnTP2.Font = Enum.Font.SourceSans
btnTP2.TextSize = 17
btnTP2.MouseButton1Click:Connect(function()
    if teleportToSavedPoint() then
        btnTP2.Text = "Teleportado!"
        wait(1.3)
        btnTP2.Text = "Teleportar para ponto"
    else
        btnTP2.Text = "Nenhum ponto salvo"
        wait(1.3)
        btnTP2.Text = "Teleportar para ponto"
    end
end)

local btn3 = Instance.new("TextButton", Frame)
btn3.Size = UDim2.new(1, -28, 0, 38)
btn3.Position = UDim2.new(0, 14, 0, 150)
btn3.Text = "Coletar Dinheiro"
btn3.BackgroundColor3 = Color3.fromRGB(44,44,44)
btn3.TextColor3 = Color3.new(1,1,1)
btn3.Font = Enum.Font.SourceSans
btn3.TextSize = 17
btn3.MouseButton1Click:Connect(function()
    if collectMoney() then
        btn3.Text = "Dinheiro coletado!"
        wait(1.3)
        btn3.Text = "Coletar Dinheiro"
    else
        btn3.Text = "Falha ao coletar"
        wait(1.3)
        btn3.Text = "Coletar Dinheiro"
    end
end)

local btn4 = Instance.new("TextButton", Frame)
btn4.Size = UDim2.new(1, -28, 0, 38)
btn4.Position = UDim2.new(0, 14, 0, 198)
btn4.Text = "Comprar Brainrot OP"
btn4.BackgroundColor3 = Color3.fromRGB(70,44,44)
btn4.TextColor3 = Color3.new(1,1,1)
btn4.Font = Enum.Font.SourceSans
btn4.TextSize = 17
btn4.MouseButton1Click:Connect(function()
    if buyOPBrainrot() then
        btn4.Text = "Comprado!"
        wait(1.3)
        btn4.Text = "Comprar Brainrot OP"
    else
        btn4.Text = "Falha ao comprar"
        wait(1.3)
        btn4.Text = "Comprar Brainrot OP"
    end
end)

local btn5 = Instance.new("TextButton", Frame)
btn5.Size = UDim2.new(1, -28, 0, 38)
btn5.Position = UDim2.new(0, 14, 0, 246)
btn5.Text = "Anti Steal: OFF"
btn5.BackgroundColor3 = Color3.fromRGB(80,20,20)
btn5.TextColor3 = Color3.new(1,1,1)
btn5.Font = Enum.Font.SourceSansBold
btn5.TextSize = 17
btn5.MouseButton1Click:Connect(function()
    if not antiStealEnabled then
        activateAntiSteal()
        btn5.Text = "Anti Steal: ON"
        btn5.BackgroundColor3 = Color3.fromRGB(20,80,20)
    else
        deactivateAntiSteal()
        btn5.Text = "Anti Steal: OFF"
        btn5.BackgroundColor3 = Color3.fromRGB(80,20,20)
    end
end)

local btn6 = Instance.new("TextButton", Frame)
btn6.Size = UDim2.new(1, -28, 0, 38)
btn6.Position = UDim2.new(0, 14, 0, 294)
btn6.Text = "Upwalk: OFF"
btn6.BackgroundColor3 = Color3.fromRGB(40,40,80)
btn6.TextColor3 = Color3.new(1,1,1)
btn6.Font = Enum.Font.SourceSansBold
btn6.TextSize = 17
btn6.MouseButton1Click:Connect(function()
    if not upwalkEnabled then
        enableUpwalk()
        btn6.Text = "Upwalk: ON"
        btn6.BackgroundColor3 = Color3.fromRGB(20,80,80)
    else
        disableUpwalk()
        btn6.Text = "Upwalk: OFF"
        btn6.BackgroundColor3 = Color3.fromRGB(40,40,80)
    end
end)

local info = Instance.new("TextLabel", Frame)
info.Size = UDim2.new(1, -20, 0, 30)
info.Position = UDim2.new(0, 10, 0, 338)
info.Text = "Atalhos: Z=Salvar TP | X=Ir para TP | C=Dinheiro | V=Brainrot"
info.TextColor3 = Color3.fromRGB(200,200,200)
info.Font = Enum.Font.SourceSans
info.TextSize = 16
info.BackgroundTransparency = 1

-- ====================
-- Atalhos
-- ====================
local lastUse = {Z=0, X=0, C=0, V=0}
UIS.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    local now = tick()
    if input.KeyCode == Enum.KeyCode.Z and now - lastUse.Z > 2 then
        lastUse.Z = now
        saveTeleportPoint()
    elseif input.KeyCode == Enum.KeyCode.X and now - lastUse.X > 2 then
        lastUse.X = now
        teleportToSavedPoint()
    elseif input.KeyCode == Enum.KeyCode.C and now - lastUse.C > 2 then
        lastUse.C = now
        collectMoney()
    elseif input.KeyCode == Enum.KeyCode.V and now - lastUse.V > 2 then
        lastUse.V = now
        buyOPBrainrot()
    end
end)
