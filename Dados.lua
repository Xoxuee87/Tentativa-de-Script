--[[ 
    Brainrot Ultimate Hub - Todas funções em um só lugar!
    Baseado no projeto: NabaruBrainrot/Tempat-Penyimpanan-Roblox-Brainrot-
    Funções: Anti Steal, Upwalk, Automação Brainrot (teleport, dinheiro, brainrot OP), Hub UI
    Atenção: Para Roblox executores com suporte a GUI e scripts locais.
]]

local Players = game:GetService("Players")
local player = Players.LocalPlayer
local UIS = game:GetService("UserInputService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")
local TweenService = game:GetService("TweenService")

-- =========================
-- Anti Steal (Proteção Base)
-- =========================
local antiStealEnabled = false
local antiStealPart = nil
function getBase()
    local bases = Workspace:FindFirstChild("Bases") or Workspace:FindFirstChild("Base")
    if bases and bases:FindFirstChild(player.Name) then
        return bases[player.Name]
    end
    -- Alternativa: procura por Model com TextLabel do nome
    for _, v in pairs(Workspace:GetChildren()) do
        if v:IsA("Model") then
            for _, p in pairs(v:GetDescendants()) do
                if p:IsA("TextLabel") and (p.Text == player.Name or p.Text == player.DisplayName) then
                    return v
                end
            end
        end
    end
    return nil
end

function activateAntiSteal()
    if antiStealEnabled then return end
    antiStealEnabled = true
    local base = getBase()
    if base then
        antiStealPart = Instance.new("Part", Workspace)
        antiStealPart.Anchored = true
        antiStealPart.Size = Vector3.new(18, 2, 18)
        antiStealPart.Position = base.Position + Vector3.new(0,4,0)
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
-- Upwalk (Elevador)
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

-- =====================
-- Automação Brainrot
-- =====================
local workspaceBases = Workspace:FindFirstChild("Bases")
local lastUse = {Z=0, X=0, C=0}
function teleportToBase()
    local base = getBase()
    if player.Character and player.Character:FindFirstChild("HumanoidRootPart") and base then
        player.Character.HumanoidRootPart.CFrame = CFrame.new(base.Position)
    end
end

function collectMoney()
    local remote = ReplicatedStorage:FindFirstChild("CollectMoney")
    if remote then
        remote:FireServer(math.random())
    end
end

function buyOPBrainrot()
    local remote = ReplicatedStorage:FindFirstChild("BuyBrainrot")
    if remote then
        remote:FireServer("GodOP_"..tostring(math.random(1000,9999)))
    end
end

-- =====================
-- Hub UI
-- =====================
local ScreenGui = Instance.new("ScreenGui", game.CoreGui)
ScreenGui.Name = "BrainrotUltimateHub"
local Frame = Instance.new("Frame", ScreenGui)
Frame.Size = UDim2.new(0, 260, 0, 330)
Frame.Position = UDim2.new(0.03, 0, 0.18, 0)
Frame.BackgroundColor3 = Color3.fromRGB(22,22,33)
Frame.BorderSizePixel = 0
Frame.Active = true
Frame.Draggable = true

local title = Instance.new("TextLabel", Frame)
title.Size = UDim2.new(1, 0, 0, 36)
title.Position = UDim2.new(0, 0, 0, 0)
title.Text = "Brainrot Ultimate Hub"
title.TextColor3 = Color3.fromRGB(255,255,255)
title.Font = Enum.Font.SourceSansBold
title.TextSize = 20
title.BackgroundTransparency = 1

local btn1 = Instance.new("TextButton", Frame)
btn1.Size = UDim2.new(1, -28, 0, 38)
btn1.Position = UDim2.new(0, 14, 0, 54)
btn1.Text = "Teleportar para Base"
btn1.BackgroundColor3 = Color3.fromRGB(44,70,44)
btn1.TextColor3 = Color3.new(1,1,1)
btn1.Font = Enum.Font.SourceSans
btn1.TextSize = 17
btn1.MouseButton1Click:Connect(teleportToBase)

local btn2 = Instance.new("TextButton", Frame)
btn2.Size = UDim2.new(1, -28, 0, 38)
btn2.Position = UDim2.new(0, 14, 0, 102)
btn2.Text = "Coletar Dinheiro"
btn2.BackgroundColor3 = Color3.fromRGB(44,44,70)
btn2.TextColor3 = Color3.new(1,1,1)
btn2.Font = Enum.Font.SourceSans
btn2.TextSize = 17
btn2.MouseButton1Click:Connect(collectMoney)

local btn3 = Instance.new("TextButton", Frame)
btn3.Size = UDim2.new(1, -28, 0, 38)
btn3.Position = UDim2.new(0, 14, 0, 150)
btn3.Text = "Comprar Brainrot OP"
btn3.BackgroundColor3 = Color3.fromRGB(70,44,44)
btn3.TextColor3 = Color3.new(1,1,1)
btn3.Font = Enum.Font.SourceSans
btn3.TextSize = 17
btn3.MouseButton1Click:Connect(buyOPBrainrot)

local btn4 = Instance.new("TextButton", Frame)
btn4.Size = UDim2.new(1, -28, 0, 38)
btn4.Position = UDim2.new(0, 14, 0, 198)
btn4.Text = "Anti Steal: OFF"
btn4.BackgroundColor3 = Color3.fromRGB(80,20,20)
btn4.TextColor3 = Color3.new(1,1,1)
btn4.Font = Enum.Font.SourceSansBold
btn4.TextSize = 17
btn4.MouseButton1Click:Connect(function()
    if not antiStealEnabled then
        activateAntiSteal()
        btn4.Text = "Anti Steal: ON"
        btn4.BackgroundColor3 = Color3.fromRGB(20,80,20)
    else
        deactivateAntiSteal()
        btn4.Text = "Anti Steal: OFF"
        btn4.BackgroundColor3 = Color3.fromRGB(80,20,20)
    end
end)

local btn5 = Instance.new("TextButton", Frame)
btn5.Size = UDim2.new(1, -28, 0, 38)
btn5.Position = UDim2.new(0, 14, 0, 246)
btn5.Text = "Upwalk: OFF"
btn5.BackgroundColor3 = Color3.fromRGB(40,40,80)
btn5.TextColor3 = Color3.new(1,1,1)
btn5.Font = Enum.Font.SourceSansBold
btn5.TextSize = 17
btn5.MouseButton1Click:Connect(function()
    if not upwalkEnabled then
        enableUpwalk()
        btn5.Text = "Upwalk: ON"
        btn5.BackgroundColor3 = Color3.fromRGB(20,80,80)
    else
        disableUpwalk()
        btn5.Text = "Upwalk: OFF"
        btn5.BackgroundColor3 = Color3.fromRGB(40,40,80)
    end
end)

local info = Instance.new("TextLabel", Frame)
info.Size = UDim2.new(1, -20, 0, 30)
info.Position = UDim2.new(0, 10, 0, 294)
info.Text = "Atalhos: Z=Teleport | X=Dinheiro | C=Brainrot"
info.TextColor3 = Color3.fromRGB(200,200,200)
info.Font = Enum.Font.SourceSans
info.TextSize = 16
info.BackgroundTransparency = 1

-- =====================
-- Atalhos
-- =====================
UIS.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    local now = tick()
    if input.KeyCode == Enum.KeyCode.Z and now - lastUse.Z > 2 then
        lastUse.Z = now
        teleportToBase()
    elseif input.KeyCode == Enum.KeyCode.X and now - lastUse.X > 2 then
        lastUse.X = now
        collectMoney()
    elseif input.KeyCode == Enum.KeyCode.C and now - lastUse.C > 3 then
        lastUse.C = now
        buyOPBrainrot()
    end
end)

-- =====================
-- Fim do Hub
-- =====================
