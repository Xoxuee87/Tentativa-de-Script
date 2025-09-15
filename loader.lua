--[[
    🧠 Brainrot Robber Loader v1.0
    Sistema de carregamento inteligente com verificações
--]]

local Loader = {}

-- Informações do script
local SCRIPT_INFO = {
    name = "Brainrot Robber",
    version = "3.0",
    author = "BrainrotDev",
    game = "Roube um Brainrot"
}

-- URLs para carregamento
local URLS = {
    main = "https://raw.githubusercontent.com/YourRepo/BrainrotRobber/main/BrainrotRobber.lua",
    backup = "https://pastebin.com/raw/YourPastebinID"
}

-- Função para criar notificação
local function createNotification(title, text, duration)
    game:GetService("StarterGui"):SetCore("SendNotification", {
        Title = title,
        Text = text,
        Duration = duration or 5
    })
end

-- Função para verificar compatibilidade
local function checkCompatibility()
    local checks = {
        httpEnabled = false,
        executor = "Unknown",
        gameCorrect = false,
        robloxVersion = true
    }
    
    -- Verifica HTTP
    local success = pcall(function()
        game:HttpGet("https://httpbin.org/get", true)
    end)
    checks.httpEnabled = success
    
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
    
    -- Verifica se está no jogo correto
    local gameName = game:GetService("MarketplaceService"):GetProductInfo(game.PlaceId).Name
    if string.find(gameName:lower(), "brainrot") or string.find(gameName:lower(), "roube") then
        checks.gameCorrect = true
    end
    
    return checks
end

-- Função para download com retry e backup
local function downloadScript(maxRetries)
    maxRetries = maxRetries or 3
    
    -- Tenta URL principal
    for i = 1, maxRetries do
        local success, result = pcall(function()
            return game:HttpGet(URLS.main, true)
        end)
        
        if success and result and string.len(result) > 100 then
            return true, result
        end
        
        if i < maxRetries then
            wait(1)
        end
    end
    
    -- Tenta URL backup
    for i = 1, maxRetries do
        local success, result = pcall(function()
            return game:HttpGet(URLS.backup, true)
        end)
        
        if success and result and string.len(result) > 100 then
            return true, result
        end
        
        if i < maxRetries then
            wait(1)
        end
    end
    
    return false, "Falha ao baixar script após múltiplas tentativas"
end

-- Função principal de carregamento
function Loader.load()
    -- Cabeçalho
    print(string.rep("=", 50))
    print("🧠 " .. SCRIPT_INFO.name .. " v" .. SCRIPT_INFO.version)
    print("📝 Desenvolvido por: " .. SCRIPT_INFO.author)
    print("🎮 Jogo: " .. SCRIPT_INFO.game)
    print(string.rep("=", 50))
    
    createNotification(
        "🧠 Brainrot Robber",
        "Iniciando carregamento...",
        3
    )
    
    -- Verificações de compatibilidade
    print("🔍 Verificando compatibilidade...")
    local compatibility = checkCompatibility()
    
    -- Relata compatibilidade
    print("📊 Relatório de Compatibilidade:")
    print("   HTTP Habilitado: " .. (compatibility.httpEnabled and "✅" or "❌"))
    print("   Executor: " .. compatibility.executor)
    print("   Jogo Correto: " .. (compatibility.gameCorrect and "✅" or "⚠️"))
    
    -- Verifica requisitos críticos
    if not compatibility.httpEnabled then
        local errorMsg = "❌ HTTP não está habilitado! Habilite HTTP requests no seu executor."
        print(errorMsg)
        createNotification("❌ Erro Crítico", "HTTP não habilitado!", 10)
        return false
    end
    
    if not compatibility.gameCorrect then
        local warningMsg = "⚠️ Aviso: Pode não estar no jogo correto. O script pode não funcionar perfeitamente."
        print(warningMsg)
        createNotification("⚠️ Aviso", "Jogo pode estar incorreto!", 5)
    end
    
    print("✅ Verificações básicas aprovadas!")
    
    -- Download do script
    print("📥 Baixando script principal...")
    createNotification("📥 Download", "Baixando script...", 3)
    
    local success, scriptContent = downloadScript(3)
    
    if not success then
        local errorMsg = "❌ Falha ao baixar script: " .. scriptContent
        print(errorMsg)
        createNotification("❌ Erro de Download", "Falha ao baixar!", 10)
        return false
    end
    
    print("✅ Script baixado com sucesso! (" .. string.len(scriptContent) .. " bytes)")
    
    -- Validação básica do script
    if not string.find(scriptContent, "BrainrotRobber") then
        print("❌ Script baixado parece estar corrompido!")
        createNotification("❌ Erro", "Script corrompido!", 10)
        return false
    end
    
    -- Execução do script
    print("🚀 Executando Brainrot Robber...")
    createNotification("🚀 Carregando", "Iniciando script...", 3)
    
    local executeSuccess, executeResult = pcall(function()
        return loadstring(scriptContent)()
    end)
    
    if not executeSuccess then
        local errorMsg = "❌ Erro ao executar script: " .. tostring(executeResult)
        print(errorMsg)
        createNotification("❌ Erro de Execução", "Falha ao executar!", 10)
        return false
    end
    
    -- Sucesso
    print("🎉 Brainrot Robber carregado com sucesso!")
    print("🔧 Controles:")
    print("   INSERT - Abrir/Fechar GUI")
    print("   F1 - Toggle Velocidade")
    print("   F2 - Toggle Invisibilidade")
    print("   F3 - Toggle Player ESP")
    print("   F4 - Toggle Brainrot ESP")
    print(string.rep("=", 50))
    
    createNotification(
        "🎉 Sucesso!",
        "Brainrot Robber carregado! Pressione INSERT para abrir.",
        7
    )
    
    return true
end

-- Função para atualização automática
function Loader.checkUpdate()
    print("🔄 Verificando atualizações...")
    
    local success, versionData = pcall(function()
        return game:HttpGet("https://raw.githubusercontent.com/YourRepo/BrainrotRobber/main/version.json", true)
    end)
    
    if success then
        local data = game:GetService("HttpService"):JSONDecode(versionData)
        if data.version ~= SCRIPT_INFO.version then
            print("🆕 Nova versão disponível: " .. data.version)
            createNotification("🆕 Atualização", "Nova versão: " .. data.version, 5)
            return true, data
        end
    end
    
    return false, nil
end

-- Função de carregamento com verificação de atualização
function Loader.loadWithUpdate()
    -- Verifica atualizações primeiro
    local hasUpdate, updateData = Loader.checkUpdate()
    
    if hasUpdate then
        print("📦 Baixando versão atualizada...")
        -- Atualiza URLs se necessário
        if updateData.downloadUrl then
            URLS.main = updateData.downloadUrl
        end
    end
    
    -- Carrega o script
    return Loader.load()
end

-- Auto-execução
spawn(function()
    wait(0.5) -- Pequeno delay para garantir que tudo carregou
    
    local success = Loader.loadWithUpdate()
    
    if success then
        print("🧠 Sistema pronto para roubar brainrots! 🚀")
    else
        print("💥 Falha no carregamento. Verifique os requisitos.")
    end
end)

return Loader
