--[[
    🧠💀 STEAL A BRAINROT HUB v4.0 - COMPLETO 💀🧠
    Hub definitivo para [💀] Steal a Brainrot por BRAZILIAN SPYDER
    Game ID: 109983668079237
    
    🎯 FUNCIONALIDADES COMPLETAS:
    ✅ Auto-Steal com 4 estratégias diferentes
    ✅ ESP completo (Players, Brainrots, Items, Areas)
    ✅ Sistema de movimento avançado (Speed, Fly, Noclip)
    ✅ Proteção anti-kick e reconexão automática
    ✅ Auto-rebirth e progressão inteligente
    ✅ Sistema de notificações e alerts
    ✅ Interface moderna com 8 abas
    ✅ Sistema de estatísticas completo
    ✅ Backup de configurações
    ✅ Server hopping inteligente
    ✅ Sistema de hotkeys
    ✅ Modo stealth avançado
    
    📌 HOTKEYS:
    INSERT - Abrir/Fechar Hub
    F1 - Toggle Auto-Steal
    F2 - Toggle Speed Boost
    F3 - Toggle Fly
    F4 - Toggle Player ESP
    F5 - Toggle Brainrot ESP
    F6 - Emergency Stop (Para tudo)
    F7 - Server Hop
    F8 - Scan Game
--]]

-- Verificação de compatibilidade
if game.PlaceId ~= 109983668079237 then
    warn("🚫 Este hub foi desenvolvido especificamente para 'Steal a Brainrot'")
    warn("🎮 Game ID atual: " .. game.PlaceId)
    warn("🎯 Game ID esperado: 109983668079237")
    
    game:GetService("StarterGui"):SetCore("SendNotification", {
        Title = "⚠️ Jogo Incorreto",
        Text = "Hub desenvolvido para 'Steal a Brainrot'",
        Duration = 8
    })
end

-- Inicia sistema
local StealBrainrotHub = loadstring(game:HttpGet("https://raw.githubusercontent.com/YourRepo/StealBrainrotHub/main/StealBrainrotHub.lua"))()

-- Inicialização principal
function StealBrainrotHub:initialize()
    Logger:add("🧠💀 Iniciando Steal a Brainrot Hub v4.0", "INIT", "SUCCESS")
    
    -- Verifica se está no jogo correto
    if game.PlaceId == 109983668079237 then
        Logger:add("✅ Jogo correto detectado: Steal a Brainrot", "INIT", "SUCCESS")
        NotificationSystem:send("Hub Carregado", "Bem-vindo ao Steal a Brainrot Hub!", 5, "success")
    else
        Logger:add("⚠️ Jogo diferente detectado, algumas funcionalidades podem não funcionar", "INIT", "WARNING")
        NotificationSystem:send("Aviso", "Jogo diferente do esperado", 5, "warning")
    end
    
    -- Inicializa componentes
    self:setupHotkeys()
    self:startBackgroundTasks()
    
    -- Cria interface
    GUI:create()
    
    -- Ativa proteções básicas
    Protection:enableAntiKick()
    Protection:enableAntiAfk()
    Protection:enableAutoRejoin()
    
    -- Scan inicial
    spawn(function()
        wait(3)
        GameDetector:scanGame()
        GUI:updateGameInfo()
    end)
    
    -- Carrega configurações salvas
    self:loadSavedSettings()
    
    Logger:add("🎉 Hub totalmente carregado e operacional!", "INIT", "SUCCESS")
    
    -- Tutorial para novos usuários
    spawn(function()
        wait(5)
        self:showWelcomeTutorial()
    end)
end

function StealBrainrotHub:setupHotkeys()
    UserInputService.InputBegan:Connect(function(input, gameProcessed)
        if gameProcessed then return end
        
        if input.KeyCode == Enum.KeyCode.Insert then
            GUI:toggle()
        elseif input.KeyCode == Enum.KeyCode.F1 then
            GUI:toggleAutoSteal()
        elseif input.KeyCode == Enum.KeyCode.F2 then
            GUI:toggleSpeed()
        elseif input.KeyCode == Enum.KeyCode.F3 then
            Movement.flyEnabled = not Movement.flyEnabled
            if Movement.flyEnabled then
                Movement:enableFly(50)
            else
                Movement:disableFly()
            end
        elseif input.KeyCode == Enum.KeyCode.F4 then
            HubConfig.Settings.ESP.Players.Enabled = not HubConfig.Settings.ESP.Players.Enabled
            GUI:updateAllESP()
        elseif input.KeyCode == Enum.KeyCode.F5 then
            HubConfig.Settings.ESP.Brainrots.Enabled = not HubConfig.Settings.ESP.Brainrots.Enabled
            GUI:updateAllESP()
        elseif input.KeyCode == Enum.KeyCode.F6 then
            -- Emergency stop
            self:emergencyStop()
        elseif input.KeyCode == Enum.KeyCode.F7 then
            -- Server hop
            self:serverHop()
        elseif input.KeyCode == Enum.KeyCode.F8 then
            GameDetector:scanGame()
        end
    end)
    
    Logger:add("⌨️ Hotkeys configurados", "INIT", "INFO")
end

function StealBrainrotHub:startBackgroundTasks()
    -- Atualização periódica do jogo
    spawn(function()
        while true do
            wait(30) -- A cada 30 segundos
            if AutoSteal.enabled or HubConfig.Settings.ESP.Brainrots.Enabled then
                GameDetector:scanGame()
                if HubConfig.Settings.ESP.Brainrots.Enabled then
                    GUI:updateAllESP()
                end
            end
            
            -- Atualiza estatísticas
            Stats.session.timeActive = tick() - Stats.session.startTime
            if GUI.updateStatsPreview then
                GUI:updateStatsPreview()
            end
            if GUI.updateGameInfo then
                GUI:updateGameInfo()
            end
        end
    end)
    
    -- Auto-save configurações
    spawn(function()
        while true do
            wait(300) -- A cada 5 minutos
            self:saveSettings()
        end
    end)
    
    -- Monitor de performance
    spawn(function()
        while true do
            wait(60) -- A cada minuto
            self:monitorPerformance()
        end
    end)
    
    Logger:add("🔄 Tarefas em background iniciadas", "INIT", "INFO")
end

function StealBrainrotHub:emergencyStop()
    -- Para todas as funcionalidades imediatamente
    AutoSteal:stop()
    ESPSystem:disable()
    Movement:restoreDefaults()
    
    NotificationSystem:send("Emergency Stop", "Todas as funcionalidades foram paradas!", 5, "warning")
    Logger:add("🛑 EMERGENCY STOP ativado", "EMERGENCY", "WARNING")
end

function StealBrainrotHub:serverHop()
    NotificationSystem:send("Server Hop", "Mudando para novo servidor...", 3, "info")
    Logger:add("🌐 Mudando de servidor", "SERVER", "INFO")
    
    TeleportService:Teleport(game.PlaceId)
end

function StealBrainrotHub:saveSettings()
    local settings = {
        version = HubConfig.Version,
        timestamp = tick(),
        settings = HubConfig.Settings,
        stats = Stats.total
    }
    
    local success, encoded = pcall(function()
        return HttpService:JSONEncode(settings)
    end)
    
    if success then
        writefile("StealBrainrotHub_Settings.json", encoded)
        Logger:add("💾 Configurações salvas automaticamente", "SAVE", "INFO")
    else
        Logger:add("❌ Erro ao salvar configurações", "SAVE", "ERROR")
    end
end

function StealBrainrotHub:loadSavedSettings()
    if isfile("StealBrainrotHub_Settings.json") then
        local success, content = pcall(function()
            return readfile("StealBrainrotHub_Settings.json")
        end)
        
        if success then
            local decoded = HttpService:JSONDecode(content)
            if decoded and decoded.settings then
                HubConfig.Settings = decoded.settings
                if decoded.stats then
                    Stats.total = decoded.stats
                end
                Logger:add("📂 Configurações carregadas do arquivo salvo", "LOAD", "SUCCESS")
            end
        end
    else
        Logger:add("📁 Nenhuma configuração salva encontrada, usando padrões", "LOAD", "INFO")
    end
end

function StealBrainrotHub:monitorPerformance()
    local memoryUsage = collectgarbage("count")
    local fps = workspace:GetRealPhysicsFPS()
    
    if memoryUsage > 500000 then -- 500MB
        Logger:add("⚠️ Alto uso de memória detectado: " .. math.floor(memoryUsage/1024) .. "MB", "PERFORMANCE", "WARNING")
        collectgarbage("collect")
    end
    
    if fps < 30 then
        Logger:add("⚠️ FPS baixo detectado: " .. fps, "PERFORMANCE", "WARNING")
        -- Reduz configurações automaticamente
        HubConfig.Settings.Performance.OptimizeESP = true
        HubConfig.Settings.Performance.MaxESPObjects = 25
    end
end

function StealBrainrotHub:showWelcomeTutorial()
    local function showStep(step, title, message, duration)
        NotificationSystem:send("Tutorial " .. step, message, duration or 8)
        wait(duration or 8)
    end
    
    showStep("1/5", "Bem-vindo!", "Pressione INSERT para abrir o hub principal")
    showStep("2/5", "Auto-Steal", "Use F1 para ativar/desativar o roubo automático")
    showStep("3/5", "ESP", "F4 e F5 ativam ESP de jogadores e brainrots")
    showStep("4/5", "Movimento", "F2 para velocidade, F3 para voar")
    showStep("5/5", "Emergência", "F6 para parar tudo, F7 para mudar servidor")
    
    NotificationSystem:send("Tutorial Completo", "Divirta-se usando o hub! 🧠💀", 5)
end

-- 🎮 Sistema de Auto-Rebirth e Progressão
local AutoProgression = {
    enabled = false,
    connections = {},
    currentLevel = 0,
    currentMoney = 0,
    rebirthThreshold = 100
}

function AutoProgression:start()
    if self.enabled then return end
    
    self.enabled = true
    Logger:add("🚀 Auto-progressão iniciada", "PROGRESSION", "SUCCESS")
    
    self.connections.main = RunService.Heartbeat:Connect(function()
        self:checkProgression()
    end)
end

function AutoProgression:stop()
    if not self.enabled then return end
    
    self.enabled = false
    if self.connections.main then
        self.connections.main:Disconnect()
        self.connections.main = nil
    end
    
    Logger:add("⏹️ Auto-progressão parada", "PROGRESSION", "INFO")
end

function AutoProgression:checkProgression()
    -- Verifica level e dinheiro do jogador
    local leaderstats = LocalPlayer:FindFirstChild("leaderstats")
    if not leaderstats then return end
    
    local level = leaderstats:FindFirstChild("Level") or leaderstats:FindFirstChild("level")
    local money = leaderstats:FindFirstChild("Money") or leaderstats:FindFirstChild("Cash") or leaderstats:FindFirstChild("Coins")
    
    if level then
        self.currentLevel = level.Value
    end
    
    if money then
        self.currentMoney = money.Value
    end
    
    -- Auto-rebirth
    if HubConfig.Settings.Auto.Rebirth.Enabled then
        if self.currentLevel >= HubConfig.Settings.Auto.Rebirth.MinLevel then
            self:attemptRebirth()
        end
    end
    
    -- Auto-upgrade
    if HubConfig.Settings.Auto.Upgrade.Enabled then
        if self.currentMoney >= HubConfig.Settings.Auto.Upgrade.KeepMoney * 2 then
            self:attemptUpgrade()
        end
    end
end

function AutoProgression:attemptRebirth()
    -- Procura por botão/GUI de rebirth
    for _, gui in pairs(LocalPlayer.PlayerGui:GetDescendants()) do
        if gui:IsA("TextButton") or gui:IsA("ImageButton") then
            local text = gui.Text and gui.Text:lower() or ""
            if string.find(text, "rebirth") or string.find(text, "prestige") then
                gui:MouseButton1Click()
                Logger:add("🔄 Rebirth executado!", "PROGRESSION", "SUCCESS")
                Stats.session.rebirths = Stats.session.rebirths + 1
                NotificationSystem:send("Rebirth", "Rebirth automático executado!", 4, "success")
                wait(2)
                return
            end
        end
    end
    
    -- Tenta via RemoteEvents
    for _, remote in ipairs(ReplicatedStorage:GetDescendants()) do
        if remote:IsA("RemoteEvent") then
            local name = remote.Name:lower()
            if string.find(name, "rebirth") or string.find(name, "prestige") then
                pcall(function()
                    remote:FireServer()
                end)
            end
        end
    end
end

function AutoProgression:attemptUpgrade()
    -- Implementa lógica de upgrade baseada na prioridade
    local priority = HubConfig.Settings.Auto.Upgrade.Priority
    
    -- Procura por botões de upgrade
    for _, gui in pairs(LocalPlayer.PlayerGui:GetDescendants()) do
        if gui:IsA("TextButton") or gui:IsA("ImageButton") then
            local text = gui.Text and gui.Text:lower() or ""
            
            if priority == "Speed" and (string.find(text, "speed") or string.find(text, "walk")) then
                gui:MouseButton1Click()
                Logger:add("⬆️ Upgrade de velocidade comprado", "PROGRESSION", "SUCCESS")
                wait(1)
                return
            elseif priority == "Capacity" and (string.find(text, "capacity") or string.find(text, "bag")) then
                gui:MouseButton1Click()
                Logger:add("⬆️ Upgrade de capacidade comprado", "PROGRESSION", "SUCCESS")
                wait(1)
                return
            elseif string.find(text, "upgrade") or string.find(text, "buy") then
                gui:MouseButton1Click()
                Logger:add("⬆️ Upgrade genérico comprado", "PROGRESSION", "SUCCESS")
                wait(1)
                return
            end
        end
    end
end

-- 📊 Sistema de Analytics Avançado
local Analytics = {
    sessionData = {},
    performanceMetrics = {},
    playerBehavior = {}
}

function Analytics:trackEvent(eventType, data)
    local event = {
        type = eventType,
        timestamp = tick(),
        data = data or {}
    }
    
    table.insert(self.sessionData, event)
    
    -- Mantém apenas os últimos 1000 eventos
    if #self.sessionData > 1000 then
        table.remove(self.sessionData, 1)
    end
end

function Analytics:generateReport()
    local report = {
        session = {
            duration = tick() - Stats.session.startTime,
            brainrotsStolen = Stats.session.brainrotsStolen,
            efficiency = Stats.session.brainrotsStolen / math.max(1, (tick() - Stats.session.startTime) / 60), -- por minuto
            autoStealUsage = AutoSteal.enabled and (tick() - AutoSteal.stats.startTime) or 0
        },
        performance = {
            averageFPS = workspace:GetRealPhysicsFPS(),
            memoryUsage = math.floor(collectgarbage("count") / 1024), -- MB
            espObjectsActive = #ESPSystem.objects
        },
        features = {
            autoStealEnabled = AutoSteal.enabled,
            espEnabled = ESPSystem.enabled,
            protectionEnabled = true,
            movementModsActive = Movement.flyEnabled or HubConfig.Settings.Movement.Speed.Enabled
        }
    }
    
    return report
end

function Analytics:exportData()
    local data = {
        version = HubConfig.Version,
        timestamp = os.date(),
        gameId = game.PlaceId,
        sessionData = self.sessionData,
        stats = Stats,
        report = self:generateReport()
    }
    
    local encoded = HttpService:JSONEncode(data)
    writefile("StealBrainrotHub_Analytics_" .. os.date("%Y%m%d_%H%M%S") .. ".json", encoded)
    
    Logger:add("📊 Dados de analytics exportados", "ANALYTICS", "SUCCESS")
    NotificationSystem:send("Analytics", "Dados exportados com sucesso!", 3, "success")
end

-- 🌐 Sistema de Server Hopping Inteligente
local ServerHopper = {
    enabled = false,
    serversChecked = 0,
    bestServers = {},
    currentServerScore = 0
}

function ServerHopper:start()
    if self.enabled then return end
    
    self.enabled = true
    Logger:add("🌐 Server hopping inteligente iniciado", "SERVER", "SUCCESS")
    
    spawn(function()
        while self.enabled do
            self:evaluateCurrentServer()
            
            if self.currentServerScore < 5 then -- Score baixo
                self:findBetterServer()
            end
            
            wait(60) -- Avalia a cada minuto
        end
    end)
end

function ServerHopper:evaluateCurrentServer()
    local score = 0
    
    -- Avalia quantidade de brainrots
    score = score + math.min(10, #GameDetector.brainrots)
    
    -- Avalia quantidade de players (menos é melhor para farm)
    local playerCount = #Players:GetPlayers()
    score = score + math.max(0, 10 - playerCount)
    
    -- Avalia brainrots raros
    local rareCount = 0
    for _, brainrot in ipairs(GameDetector.brainrots) do
        if brainrot.rarity ~= "Common" then
            rareCount = rareCount + 1
        end
    end
    score = score + rareCount * 3
    
    self.currentServerScore = score
    Logger:add(string.format("📊 Score do servidor atual: %d/20", score), "SERVER", "INFO")
end

function ServerHopper:findBetterServer()
    Logger:add("🔍 Procurando servidor melhor...", "SERVER", "INFO")
    NotificationSystem:send("Server Hop", "Procurando servidor melhor...", 3, "info")
    
    self.serversChecked = self.serversChecked + 1
    TeleportService:Teleport(game.PlaceId)
end

-- Sistema principal - Inicialização
StealBrainrotHub.AutoProgression = AutoProgression
StealBrainrotHub.Analytics = Analytics
StealBrainrotHub.ServerHopper = ServerHopper

-- Auto-inicialização
spawn(function()
    wait(1) -- Aguarda carregamento completo
    StealBrainrotHub:initialize()
end)

-- Cleanup ao sair
game:BindToClose(function()
    StealBrainrotHub:saveSettings()
    Analytics:exportData()
end)

return StealBrainrotHub
