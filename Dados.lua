-- Serviços
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local Camera = workspace.CurrentCamera
local Drawing = Drawing

local espAtivo, teamCheck, mostrarVida = true, true, true
local flying, flySpeed, flyConnection = false, 80, nil
local basePosition = Vector3.new(0, 10, 0)

-- Loading simples
local function criarLoading()
    local gui = Instance.new("ScreenGui", game.CoreGui)
    gui.Name = "BrainrotLoader"
    local frame = Instance.new("Frame", gui)
    frame.Size = UDim2.new(1, 0, 1, 0)
    frame.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
    local label = Instance.new("TextLabel", frame)
    label.Size = UDim2.new(0, 300, 0, 50)
    label.Position = UDim2.new(0.5, -150, 0.5, -25)
    label.Text = "Carregando..."
    label.Font = Enum.Font.SourceSansBold
    label.TextSize = 32
    label.TextColor3 = Color3.new(1, 1, 1)
    label.BackgroundTransparency = 1
    wait(1.5)
    gui:Destroy()
end

-- Funções extras
local function superJump()
    local h = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
    if h then h.JumpPower = 120 end
end
local function speedBoost()
    local h = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
    if h then h.WalkSpeed = 40 end
end
local function teleportBase()
    if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
        LocalPlayer.Character:MoveTo(basePosition)
    end
end
local function ativarFly()
    local char = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
    local hrp = char:WaitForChild("HumanoidRootPart")
    local gyro = Instance.new("BodyGyro", hrp)
    gyro.P, gyro.MaxTorque, gyro.CFrame = 9e4, Vector3.new(9e9,9e9,9e9), hrp.CFrame
    local vel = Instance.new("BodyVelocity", hrp)
    vel.MaxForce = Vector3.new(9e9,9e9,9e9)
    flying = true
    flyConnection = RunService.RenderStepped:Connect(function()
        local cam = workspace.CurrentCamera
        local dir = Vector3.new()
        if UserInputService:IsKeyDown(Enum.KeyCode.W) then dir = dir + cam.CFrame.LookVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.S) then dir = dir - cam.CFrame.LookVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.A) then dir = dir - cam.CFrame.RightVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.D) then dir = dir + cam.CFrame.RightVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.Space) then dir = dir + cam.CFrame.UpVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) then dir = dir - cam.CFrame.UpVector end
        vel.Velocity = dir.Magnitude > 0 and dir.Unit * flySpeed or Vector3.new()
        gyro.CFrame = cam.CFrame
    end)
end
local function desativarFly()
    flying = false
    local char = LocalPlayer.Character
    if char then
        local hrp = char:FindFirstChild("HumanoidRootPart")
        if hrp then
            for _, v in pairs(hrp:GetChildren()) do
                if v:IsA("BodyGyro") or v:IsA("BodyVelocity") then v:Destroy() end
            end
        end
    end
    if flyConnection then flyConnection:Disconnect(); flyConnection = nil end
end
local function alternarFly()
    if flying then desativarFly() else ativarFly() end
end

-- Busca brainrots só quando necessário
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
    local handle = obj:FindFirstChild("Handle") or obj:FindFirstChildWhichIsA("BasePart")
    if handle and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
        firetouchinterest(LocalPlayer.Character.HumanoidRootPart, handle, 0)
        firetouchinterest(LocalPlayer.Character.HumanoidRootPart, handle, 1)
        wait(0.2)
        teleportBase()
        return true
    end
    return false
end

-- Painel principal
local function criarInterface()
    local oldGui = game.CoreGui:FindFirstChild("BrainrotGUI")
    if oldGui then oldGui:Destroy() end
    local ScreenGui = Instance.new("ScreenGui", game.CoreGui)
    ScreenGui.Name = "BrainrotGUI"

    local MainFrame = Instance.new("Frame", ScreenGui)
    MainFrame.Size = UDim2.new(0, 340, 0, 270)
    MainFrame.Position = UDim2.new(0, 20, 0, 80)
    MainFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    MainFrame.BorderSizePixel = 0
    MainFrame.Active = true
    MainFrame.Draggable = true

    local Titulo = Instance.new("TextLabel", MainFrame)
    Titulo.Size = UDim2.new(1, 0, 0, 28)
    Titulo.BackgroundTransparency = 1
    Titulo.Text = "Brainrot HUB (Otimizado)"
    Titulo.TextColor3 = Color3.new(1, 1, 1)
    Titulo.Font = Enum.Font.SourceSansBold
    Titulo.TextSize = 18

    local function criarBotao(texto, posY, estado, func)
        local btn = Instance.new("TextButton", MainFrame)
        btn.Size = UDim2.new(0, 120, 0, 28)
        btn.Position = UDim2.new(0, 10, 0, posY)
        btn.Text = texto .. " [" .. (estado and "ON" or "OFF") .. "]"
        btn.BackgroundColor3 = estado and Color3.fromRGB(40, 90, 40) or Color3.fromRGB(70, 30, 30)
        btn.TextColor3 = Color3.new(1,1,1)
        btn.BorderSizePixel = 0
        btn.Font = Enum.Font.SourceSansBold
        btn.TextSize = 14
        btn.MouseButton1Click:Connect(function()
            func()
            btn.Text = texto .. " [" .. (estado and "ON" or "OFF") .. "]"
            btn.BackgroundColor3 = estado and Color3.fromRGB(40, 90, 40) or Color3.fromRGB(70, 30, 30)
        end)
        return btn
    end

    criarBotao("ESP", 40, espAtivo, function() espAtivo = not espAtivo end)
    criarBotao("TeamCheck", 75, teamCheck, function() teamCheck = not teamCheck end)
    criarBotao("HealthBar", 110, mostrarVida, function() mostrarVida = not mostrarVida end)

    local xFun = 140
    local function criarBotaoFuncoes(texto, y, func)
        local btn = Instance.new("TextButton", MainFrame)
        btn.Size = UDim2.new(0, 120, 0, 24)
        btn.Position = UDim2.new(0, 10, 0, y)
        btn.Text = texto
        btn.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
        btn.TextColor3 = Color3.new(1,1,1)
        btn.BorderSizePixel = 0
        btn.Font = Enum.Font.SourceSans
        btn.TextSize = 13
        btn.MouseButton1Click:Connect(func)
        return btn
    end

    criarBotaoFuncoes("Super Jump", xFun, superJump)
    criarBotaoFuncoes("Speed Boost", xFun+27, speedBoost)
    criarBotaoFuncoes("Fly ON/OFF", xFun+54, alternarFly)
    criarBotaoFuncoes("Ir para Base", xFun+81, teleportBase)

    -- Brainrot Buttons - só atualiza quando realmente muda
    local yBrain = xFun+115
    local function atualizarBotaoRoubo()
        for _, child in pairs(MainFrame:GetChildren()) do
            if child:IsA("TextButton") and child.Position.Y.Offset >= yBrain then child:Destroy() end
        end
        local lista = listarBrainrots()
        for i, obj in ipairs(lista) do
            criarBotaoFuncoes("Roubar '"..obj.Name.."'", yBrain + (i-1)*26, function()
                roubarBrainrot(obj)
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

    -- ESP otimizado: atualiza a cada 0.15s, não todo frame
    if not Drawing then warn("API Drawing não encontrada!"); return end
    local boxes, texts, healths = {}, {}, {}
    local function criarESP(player)
        if not boxes[player] then
            local box = Drawing.new("Square")
            box.Color = Color3.fromRGB(255, 0, 0)
            box.Thickness = 2
            box.Filled = false
            box.Visible = false
            boxes[player] = box
            local txt = Drawing.new("Text")
            txt.Size, txt.Center, txt.Outline, txt.Color = 15, true, true, Color3.new(1,1,1)
            txt.Visible = false
            texts[player] = txt
            local health = Drawing.new("Text")
            health.Size, health.Center, health.Outline, health.Color = 12, true, true, Color3.fromRGB(0,255,0)
            health.Visible = false
            healths[player] = health
        end
    end
    local function removerESP(player)
        if boxes[player] then boxes[player]:Remove(); boxes[player]=nil end
        if texts[player] then texts[player]:Remove(); texts[player]=nil end
        if healths[player] then healths[player]:Remove(); healths[player]=nil end
    end
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer then criarESP(player) end
    end
    Players.PlayerAdded:Connect(function(player)
        if player ~= LocalPlayer then
            player.CharacterAdded:Connect(function() wait(0.5) criarESP(player) end)
        end
    end)
    Players.PlayerRemoving:Connect(removerESP)

    -- Atualização periódica do ESP (em vez de RenderStepped)
    spawn(function()
        while true do
            for player, box in pairs(boxes) do
                pcall(function()
                    if not espAtivo or not player.Character or not player.Character:FindFirstChild("HumanoidRootPart") then
                        box.Visible = false; texts[player].Visible = false; healths[player].Visible = false; return
                    end
                    local hrp = player.Character.HumanoidRootPart
                    local pos, onScreen = Camera:WorldToViewportPoint(hrp.Position)
                    if onScreen then
                        local corTime = player.Team == LocalPlayer.Team and Color3.fromRGB(0,255,0) or Color3.fromRGB(255,0,0)
                        box.Size = Vector2.new(60, 90)
                        box.Position = Vector2.new(pos.X - 30, pos.Y - 45)
                        box.Color = corTime; box.Visible = true
                        texts[player].Position = Vector2.new(pos.X, pos.Y - 55)
                        texts[player].Text = player.DisplayName or player.Name
                        texts[player].Color = corTime; texts[player].Visible = true
                        if mostrarVida then
                            local h = player.Character:FindFirstChildOfClass("Humanoid")
                            if h then
                                healths[player].Position = Vector2.new(pos.X, pos.Y + 55)
                                healths[player].Text = "HP: "..math.floor(h.Health)
                                healths[player].Color = Color3.fromRGB(0,255,0)
                                healths[player].Visible = true
                            else healths[player].Visible = false end
                        else healths[player].Visible = false end
                    else
                        box.Visible = false; texts[player].Visible = false; healths[player].Visible = false
                    end
                end)
            end
            wait(0.15) -- 6x por segundo, já fica fluido
        end
    end)
end

criarLoading()
criarInterface()
