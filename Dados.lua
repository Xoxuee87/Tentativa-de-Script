--[[ 
    Script "Roube um Brainrot" - Completo, Simples, Funcional e com Hub UI
    Recursos: Proteção anti-ban, delays randômicos, checagem de ambiente, atalhos, e Hub UI.
    Atalhos:
        Z = Teleportar para sua base
        X = Coletar todo o dinheiro
        C = Comprar brainrot OP
]]

local Players = game:GetService("Players")
local player = Players.LocalPlayer
local UIS = game:GetService("UserInputService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")

-- Proteção: Checagem de ambiente seguro
local function isSafeEnvironment()
    local forbidden = {"Syn", "Krnl", "ScriptWare", "Fluxus"}
    for _, v in pairs(forbidden) do
        if getgenv and type(getgenv) == "function" then
            local env = getgenv()
            if env[v] then return false end
        end
        if _G[v] then return false end
    end
    return true
end

-- Proteção: Delay randômico
local function randomDelay(min, max)
    wait(math.random(min*100, max*100)/100)
end

-- Proteção: Checagem de serviços suspeitos
local function checkBanFlags()
    local suspiciousServices = {"BanService", "KickService", "ReportService"}
    for _, v in pairs(suspiciousServices) do
        if game:GetService(v) then
            warn("Serviço suspeito encontrado: " .. v)
            return false
        end
    end
    return true
end

-- Função: Teleportar para base
local function teleportToBase()
    local bases = Workspace:FindFirstChild("Bases")
    if bases and bases:FindFirstChild(player.Name) then
        local basePos = bases[player.Name].Position
        player.Character.HumanoidRootPart.CFrame = CFrame.new(basePos)
        randomDelay(0.4, 1.3)
    end
end

-- Função: Coletar dinheiro
local function collectMoney()
    local remote = ReplicatedStorage:FindFirstChild("CollectMoney")
    if remote then
        remote:FireServer(math.random())
        randomDelay(0.7, 1.9)
    end
end

-- Função: Comprar brainrot OP
local function buyOPBrainrot()
    local remote = ReplicatedStorage:FindFirstChild("BuyBrainrot")
    if remote then
        remote:FireServer("GodOP_"..tostring(math.random(1000,9999)))
        randomDelay(1.0, 2.2)
    end
end

-- Proteção: Loop anti-ban
spawn(function()
    while true do
        if not checkBanFlags() then break end
        if not isSafeEnvironment() then break end
        wait(math.random(8, 16))
    end
end)

-- Atalhos
local lastUse = {Z=0, X=0, C=0}
UIS.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    local now = tick()
    if input.KeyCode == Enum.KeyCode.Z and now - lastUse.Z > math.random(3,6) then
        lastUse.Z = now
        teleportToBase()
    elseif input.KeyCode == Enum.KeyCode.X and now - lastUse.X > math.random(2,5) then
        lastUse.X = now
        collectMoney()
    elseif input.KeyCode == Enum.KeyCode.C and now - lastUse.C > math.random(4,9) then
        lastUse.C = now
        buyOPBrainrot()
    end
end)

-- Hub UI simples
local ScreenGui = Instance.new("ScreenGui", game.CoreGui)
local Frame = Instance.new("Frame", ScreenGui)
Frame.Size = UDim2.new(0, 220, 0, 160)
Frame.Position = UDim2.new(0.02, 0, 0.18, 0)
Frame.BackgroundColor3 = Color3.fromRGB(25,25,25)
Frame.BorderSizePixel = 0
Frame.Active = true
Frame.Draggable = true

local title = Instance.new("TextLabel", Frame)
title.Size = UDim2.new(1, 0, 0, 28)
title.Position = UDim2.new(0, 0, 0, 0)
title.Text = "Brainrot HUB"
title.TextColor3 = Color3.fromRGB(255,255,255)
title.Font = Enum.Font.SourceSansBold
title.TextSize = 19
title.BackgroundTransparency = 1

local btn1 = Instance.new("TextButton", Frame)
btn1.Size = UDim2.new(1, -20, 0, 32)
btn1.Position = UDim2.new(0, 10, 0, 36)
btn1.Text = "Teleportar para base"
btn1.BackgroundColor3 = Color3.fromRGB(44,44,44)
btn1.TextColor3 = Color3.new(1,1,1)
btn1.Font = Enum.Font.SourceSans
btn1.TextSize = 17
btn1.MouseButton1Click:Connect(teleportToBase)

local btn2 = Instance.new("TextButton", Frame)
btn2.Size = UDim2.new(1, -20, 0, 32)
btn2.Position = UDim2.new(0, 10, 0, 76)
btn2.Text = "Coletar dinheiro"
btn2.BackgroundColor3 = Color3.fromRGB(44,44,44)
btn2.TextColor3 = Color3.new(1,1,1)
btn2.Font = Enum.Font.SourceSans
btn2.TextSize = 17
btn2.MouseButton1Click:Connect(collectMoney)

local btn3 = Instance.new("TextButton", Frame)
btn3.Size = UDim2.new(1, -20, 0, 32)
btn3.Position = UDim2.new(0, 10, 0, 116)
btn3.Text = "Comprar brainrot OP"
btn3.BackgroundColor3 = Color3.fromRGB(44,44,44)
btn3.TextColor3 = Color3.new(1,1,1)
btn3.Font = Enum.Font.SourceSans
btn3.TextSize = 17
btn3.MouseButton1Click:Connect(buyOPBrainrot)
