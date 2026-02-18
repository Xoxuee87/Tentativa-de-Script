--[[
    🧠💀 STEAL A BRAINROT HUB - LOADER OFICIAL 💀🧠
    Carregador oficial para o hub mais completo do Roblox
    Desenvolvido especificamente para [💀] Steal a Brainrot
    
    🚀 INSTRUÇÕES DE USO:
    1. Copie este código no seu executor
    2. Execute e aguarde o carregamento
    3. Pressione INSERT para abrir o hub
    4. Divirta-se roubando brainrots! 🧠
--]]

-- Informações do Hub
local HUB_INFO = {
    name = "Steal a Brainrot Hub",
    version = "4.0",
    gameId = 109983668079237,
    gameName = "[💀] Steal a Brainrot",
    author = "Xoxuee87",
    discord = "discord.gg/stealbrainrothub"
}

-- URLs de carregamento ATUALIZADAS para seu repo
local URLS = {
    main = "https://raw.githubusercontent.com/Xoxuee87/Tentativa-de-Script/Xoxuee87-patch-1/StealBrainrotHubComplete.lua",
    backup1 = "https://raw.githubusercontent.com/Xoxuee87/Tentativa-de-Script/main/StealBrainrotHubComplete.lua",
    backup2 = "https://github.com/Xoxuee87/Tentativa-de-Script/releases/latest/download/StealBrainrotHubComplete.lua"
}

local Loader = {}

-- 🎨 Interface de carregamento
function Loader:createLoadingGUI()
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "StealBrainrotLoader"
    screenGui.Parent = game:GetService("Players").LocalPlayer.PlayerGui
    screenGui.ResetOnSpawn = false
    
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(0, 400, 0, 250)
    frame.Position = UDim2.new(0.5, -200, 0.5, -125)
    frame.BackgroundColor3 = Color3.fromRGB(20, 20, 30)
    frame.BorderSizePixel = 0
    frame.Parent = screenGui
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 15)
    corner.Parent = frame
    
    local stroke = Instance.new("UIStroke")
    stroke.Color = Color3.fromRGB(80, 140, 255)
    stroke.Thickness = 3
    stroke.Parent = frame
    
    -- Título
    local title = Instance.new("TextLabel")
    title.Size = UDim2.new(1, 0, 0, 40)
    title.BackgroundTransparency = 1
    title.Text = "🧠💀 " .. HUB_INFO.name .. " v" .. HUB_INFO.version
    title.TextColor3 = Color3.fromRGB(255, 255, 255)
    title.TextSize = 18
    title.Font = Enum.Font.GothamBold
    title.Parent = frame
    
    -- Logo/Ícone
    local icon = Instance.new("TextLabel")
    icon.Size = UDim2.new(0, 60, 0, 60)
    icon.Position = UDim2.new(0.5, -30, 0, 50)
    icon.BackgroundTransparency = 1
    icon.Text = "🧠"
    icon.TextColor3 = Color3.fromRGB(80, 140, 255)
    icon.TextSize = 40
    icon.Font = Enum.Font.GothamBold
    icon.Parent = frame
    
    -- Status
    local status = Instance.new("TextLabel")
    status.Size = UDim2.new(1, -20, 0, 20)
    status.Position = UDim2.new(0, 10, 0, 120)
    status.BackgroundTransparency = 1
    status.Text = "Inicializando..."
    status.TextColor3 = Color3.fromRGB(200, 200, 200)
    status.TextSize = 12
    status.Font = Enum.Font.Gotham
    status.Parent = frame
    
    -- Barra de progresso
    local progressBack = Instance.new("Frame")
    progressBack.Size = UDim2.new(1, -40, 0, 6)
    progressBack.Position = UDim2.new(0, 20, 0, 150)
    progressBack.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
    progressBack.BorderSizePixel = 0
    progressBack.Parent = frame
    
    local progressCorner = Instance.new("UICorner")
    progressCorner.CornerRadius = UDim.new(0, 3)
    progressCorner.Parent = progressBack
    
    local progress = Instance.new("Frame")
    progress.Size = UDim2.new(0, 0, 1, 0)
    progress.BackgroundColor3 = Color3.fromRGB(80, 140, 255)
    progress.BorderSizePixel = 0
    progress.Parent = progressBack
    
    local progressCorner2 = Instance.new("UICorner")
    progressCorner2.CornerRadius = UDim.new(0, 3)
    progressCorner2.Parent = progress
    
    -- Info do jogo
    local gameInfo = Instance.new("TextLabel")
    gameInfo.Size = UDim2.new(1, -20, 0, 40)
    gameInfo.Position = UDim2.new(0, 10, 0, 170)
    gameInfo.BackgroundTransparency = 1
    gameInfo.Text = "🎮 Jogo: " .. HUB_INFO.gameName .. "\n🆔 ID: " .. HUB_INFO.gameId
    gameInfo.TextColor3 = Color3.fromRGB(150, 150, 150)
    gameInfo.TextSize = 10
    gameInfo.Font = Enum.Font.Gotham
    gameInfo.Parent = frame
    
    -- Footer
    local footer = Instance.new("TextLabel")
    footer.Size = UDim2.new(1, 0, 0, 20)
    footer.Position = UDim2.new(0, 0, 1, -25)
    footer.BackgroundTransparency = 1
    footer.Text = "👨‍💻 " .. HUB_INFO.author .. " | 💬 " .. HUB_INFO.discord
    footer.TextColor3 = Color3.fromRGB(100, 100, 100)
    footer.TextSize = 9
    footer.Font = Enum.Font.Gotham
    footer.Parent = frame
    
    return {
        gui = screenGui,
        status = status,
        progress = progress,
        frame = frame
    }
end

-- 🔍 Verificações de compatibilidade
function Loader:checkCompatibility()
    local checks = {
        httpEnabled = false,
        gameCorrect = false,
        executor = "Unknown",
        environment = false
    }
    
    -- Verifica HTTP
    local success = pcall(function()
        game:HttpGet("https://httpbin.org/get", true)
    end)
    checks.httpEnabled = success
    
    -- Verifica jogo
    checks.gameCorrect = game.PlaceId == HUB_INFO.gameId
    
    -- Detecta executor
    if syn and syn.request then
        checks.executor = "Synapse X"
    elseif getgenv and getgenv().ScriptWare then
        checks.executor = "Script-Ware"
    elseif KRNL_LOADED then
        checks.executor = "KRNL"
    elseif fluxus then
        checks.executor = "Fluxus"
    elseif getgenv and getgenv().Oxygen then
        checks.executor = "Oxygen U"
    else
        checks.executor = "Desconhecido"
    end
    
    -- Verifica ambiente
    checks.environment = game:GetService("RunService"):IsClient()
    
    return checks
end

-- 📥 Download com sistema de backup
function Loader:downloadHub(ui, maxRetries)
    maxRetries = maxRetries or 3
    
    local urls = {URLS.main, URLS.backup1, URLS.backup2}
    
    for urlIndex, url in ipairs(urls) do
        ui.status.Text = "Tentando URL " .. urlIndex .. "/" .. #urls .. "..."
        
        for attempt = 1, maxRetries do
            ui.status.Text = "Baixando... (Tentativa " .. attempt .. "/" .. maxRetries .. ")"
            ui.progress.Size = UDim2.new((urlIndex - 1 + attempt/maxRetries) / #urls, 0, 1, 0)
            
            local success, result = pcall(function()
                return game:HttpGet(url, true)
            end)
            
            if success and result and string.len(result) > 1000 then
                ui.status.Text = "Download concluído!"
                ui.progress.Size = UDim2.new(1, 0, 1, 0)
                return true, result
            end
            
            if attempt < maxRetries then
                wait(1)
            end
        end
        
        if urlIndex < #urls then
            ui.status.Text = "URL " .. urlIndex .. " falhou, tentando próxima..."
            wait(1)
        end
    end
    
    return false, "Falha em todas as URLs"
end

-- 🚀 Função principal de carregamento
function Loader:load()
    local ui = self:createLoadingGUI()
    
    -- Cabeçalho no console
    print(string.rep("=", 60))
    print("🧠💀 " .. HUB_INFO.name .. " v" .. HUB_INFO.version)
    print("🎮 " .. HUB_INFO.gameName)
    print("👨‍💻 " .. HUB_INFO.author)
    print("💬 " .. HUB_INFO.discord)
    print(string.rep("=", 60))
    
    -- Verificações
    ui.status.Text = "Verificando compatibilidade..."
    ui.progress.Size = UDim2.new(0.1, 0, 1, 0)
    
    local compatibility = self:checkCompatibility()
    
    print("📊 Relatório de Compatibilidade:")
    print("   HTTP: " .. (compatibility.httpEnabled and "✅" or "❌"))
    print("   Jogo: " .. (compatibility.gameCorrect and "✅" or "⚠️"))
    print("   Executor: " .. compatibility.executor)
    print("   Ambiente: " .. (compatibility.environment and "✅" or "❌"))
    
    -- Verificações críticas
    if not compatibility.httpEnabled then
        ui.status.Text = "❌ HTTP não habilitado!"
        ui.status.TextColor3 = Color3.fromRGB(255, 100, 100)
        
        game:GetService("StarterGui"):SetCore("SendNotification", {
            Title = "❌ Erro Crítico",
            Text = "HTTP requests não habilitado!",
            Duration = 10
        })
        
        wait(5)
        ui.gui:Destroy()
        return false
    end
    
    if not compatibility.environment then
        ui.status.Text = "❌ Ambiente não suportado!"
        ui.status.TextColor3 = Color3.fromRGB(255, 100, 100)
        wait(5)
        ui.gui:Destroy()
        return false
    end
    
    if not compatibility.gameCorrect then
        ui.status.Text = "⚠️ Jogo diferente detectado"
        ui.status.TextColor3 = Color3.fromRGB(255, 200, 100)
        
        game:GetService("StarterGui"):SetCore("SendNotification", {
            Title = "⚠️ Aviso",
            Text = "Hub otimizado para Steal a Brainrot",
            Duration = 8
        })
        
        wait(2)
    end
    
    -- Download
    ui.status.Text = "Baixando hub..."
    ui.progress.Size = UDim2.new(0.3, 0, 1, 0)
    
    local success, hubContent = self:downloadHub(ui, 3)
    
    if not success then
        ui.status.Text = "❌ Falha no download!"
        ui.status.TextColor3 = Color3.fromRGB(255, 100, 100)
        
        game:GetService("StarterGui"):SetCore("SendNotification", {
            Title = "❌ Erro de Download",
            Text = hubContent,
            Duration = 10
        })
        
        wait(5)
        ui.gui:Destroy()
        return false
    end
    
    -- Validação
    ui.status.Text = "Validando código..."
    ui.progress.Size = UDim2.new(0.7, 0, 1, 0)
    
    if not string.find(hubContent, "StealBrainrotHub") then
        ui.status.Text = "❌ Código inválido!"
        ui.status.TextColor3 = Color3.fromRGB(255, 100, 100)
        wait(5)
        ui.gui:Destroy()
        return false
    end
    
    -- Execução
    ui.status.Text = "Executando hub..."
    ui.progress.Size = UDim2.new(0.9, 0, 1, 0)
    
    local executeSuccess, executeError = pcall(function()
        loadstring(hubContent)()
    end)
    
    if not executeSuccess then
        ui.status.Text = "❌ Erro de execução!"
        ui.status.TextColor3 = Color3.fromRGB(255, 100, 100)
        warn("Erro ao executar hub: " .. tostring(executeError))
        wait(5)
        ui.gui:Destroy()
        return false
    end
    
    -- Sucesso
    ui.status.Text = "✅ Hub carregado com sucesso!"
    ui.status.TextColor3 = Color3.fromRGB(100, 255, 100)
    ui.progress.Size = UDim2.new(1, 0, 1, 0)
    
    print("🎉 Hub carregado com sucesso!")
    print("⌨️ Pressione INSERT para abrir")
    print("🔧 Hotkeys disponíveis:")
    print("   F1 - Auto-Steal")
    print("   F2 - Speed Boost") 
    print("   F3 - Fly")
    print("   F4 - Player ESP")
    print("   F5 - Brainrot ESP")
    print("   F6 - Emergency Stop")
    print("   F7 - Server Hop")
    print("   F8 - Scan Game")
    print(string.rep("=", 60))
    
    game:GetService("StarterGui"):SetCore("SendNotification", {
        Title = "🎉 Sucesso!",
        Text = "Hub carregado! Pressione INSERT para abrir",
        Duration = 8
    })
    
    -- Remove interface de carregamento após 3 segundos
    wait(3)
    if ui.gui then
        ui.gui:Destroy()
    end
    
    return true
end

-- ⚡ Carregamento rápido para usuários experientes
function Loader:quickLoad()
    print("⚡ Carregamento rápido ativado...")
    
    local success, content = pcall(function()
        return game:HttpGet(URLS.main, true)
    end)
    
    if success and content and string.len(content) > 1000 then
        loadstring(content)()
        print("✅ Hub carregado rapidamente!")
        
        game:GetService("StarterGui"):SetCore("SendNotification", {
            Title = "⚡ Quick Load",
            Text = "Hub carregado rapidamente!",
            Duration = 3
        })
        
        return true
    end
    
    print("❌ Quick load falhou, usando carregamento normal...")
    return self:load()
end

-- 🎯 Auto-execução com detecção inteligente
spawn(function()
    wait(0.5) -- Aguarda inicialização
    
    -- Detecta se usuário quer carregamento rápido
    local quickLoad = false
    
    -- Verifica se já executou antes (arquivo existe)
    if isfile and isfile("StealBrainrotHub_Settings.json") then
        quickLoad = true
    end
    
    -- Verifica executor avançado
    if syn or getgenv().ScriptWare then
        quickLoad = true
    end
    
    local success
    if quickLoad then
        success = Loader:quickLoad()
    else
        success = Loader:load()
    end
    
    if success then
        print("🧠💀 Steal a Brainrot Hub operacional! 💀🧠")
    else
        warn("💥 Falha no carregamento do hub")
    end
end)

return Loader