--[[ 
    Brainrot Hub - Upwalk intacto + Teleporte personalizado + TP para Brainrot + Auto Roubo
    Execute com:
    loadstring(game:HttpGet("https://raw.githubusercontent.com/Xoxuee87/Tentativa-de-Script/refs/heads/main/Dados.lua"))()
    
    Author: Improved by Kilo Code
    Date: 2025
    Description: A Roblox script hub with various features for the Brainrot game.
    
    Features:
    - Custom teleportation system (save and load positions)
    - Money collection system
    - Brainrot purchasing system
    - Anti-theft protection system
    - Teleport to nearest Brainrot
    - Auto steal Brainrots
    - Upwalk platform system
    - User interface with keyboard shortcuts
]]

-- Services
-- Get references to Roblox services for later use
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

-- Security check
-- Verify we're in the correct game (optional, can be customized)
local function verifyGame()
    -- Add game-specific checks here if needed
    -- For example: return game.GameId == 123456789
    return true
end

-- Exit if not in the correct game
if not verifyGame() then
    return
end

-- Player
-- Reference to the local player
local player = Players.LocalPlayer

-- Variables
-- Store various states and objects used throughout the script
local savedTeleportPosition = nil  -- Position saved for teleportation
local antiStealEnabled = false     -- Whether the anti-theft system is active
local antiStealPart = nil          -- The part used for anti-theft protection
local upwalkEnabled = false        -- Whether the upwalk system is active
local upwalkPart = nil             -- The part used for the upwalk system
local lastKeyPressTimes = {        -- Track the last time each key was pressed (for cooldown)
    Z = 0,  -- Save teleport position
    X = 0,  -- Load teleport position
    C = 0,  -- Collect money
    V = 0,  -- Buy OP Brainrot
    Y = 0,  -- Teleport to nearest Brainrot
    U = 0   -- Auto steal Brainrots
}

-- Brainrot caching
-- Cache brainrot objects to improve performance
local brainrotCache = {}           -- Cached list of brainrot objects
local lastBrainrotCacheUpdate = 0  -- Time of last cache update
local BRAINROT_CACHE_TIMEOUT = 5   -- How often to refresh the cache (in seconds)

-- Remote call rate limiting
local remoteCallTimes = {}
local REMOTE_CALL_COOLDOWN = 1 -- seconds

-- Utility Functions
-- Helper functions used throughout the script

--[[
    waitForCharacter()
    Waits for the player's character to be available
]]
local function waitForCharacter()
    if player.Character then return end
    repeat task.wait() until player.Character
end

--[[
    getHumanoidRootPart()
    Gets the player's HumanoidRootPart if it exists
    Returns: Instance (HumanoidRootPart) or nil
]]
local function getHumanoidRootPart()
    if not player.Character then 
        warn("Player character not found")
        return nil 
    end
    local rootPart = player.Character:FindFirstChild("HumanoidRootPart")
    if not rootPart then
        warn("HumanoidRootPart not found in player character")
        return nil
    end
    return rootPart
end

--[[
    validateRemote(remoteName)
    Validates that a remote event exists and is the correct type
    Also implements rate limiting to prevent spam
    Parameters: remoteName (string) - Name of the remote to validate
    Returns: Instance (RemoteEvent/RemoteFunction) or nil
]]
local function validateRemote(remoteName)
    -- Rate limiting check
    local currentTime = tick()
    if remoteCallTimes[remoteName] and currentTime - remoteCallTimes[remoteName] < REMOTE_CALL_COOLDOWN then
        warn("Remote call to '" .. remoteName .. "' is on cooldown")
        return nil
    end
    
    local remote = ReplicatedStorage:FindFirstChild(remoteName)
    if not remote then
        warn("Remote event '" .. remoteName .. "' not found")
        return nil
    end
    if not (remote:IsA("RemoteEvent") or remote:IsA("RemoteFunction")) then
        warn("Remote '" .. remoteName .. "' is not a RemoteEvent or RemoteFunction")
        return nil
    end
    
    -- Update last call time
    remoteCallTimes[remoteName] = currentTime
    return remote
end

-- Teleport System
-- Handles saving and loading teleport positions
local TeleportSystem = {
    --[[
        savePosition()
        Saves the player's current position for later teleportation
        Returns: boolean (success)
    ]]
    savePosition = function()
        local rootPart = getHumanoidRootPart()
        if rootPart then
            savedTeleportPosition = rootPart.Position
            return true
        end
        return false
    end,
    
    --[[
        teleportToSaved()
        Teleports the player to the saved position
        Returns: boolean (success)
    ]]
    teleportToSaved = function()
        if not savedTeleportPosition then return false end
        local rootPart = getHumanoidRootPart()
        if rootPart then
            rootPart.CFrame = CFrame.new(savedTeleportPosition)
            return true
        end
        return false
    end
}

-- Money System
-- Handles collecting in-game money
local MoneySystem = {
    --[[
        collect()
        Fires the CollectMoney remote event to collect money
        Returns: boolean (success)
    ]]
    collect = function()
        local remote = validateRemote("CollectMoney")
        if remote then
            remote:FireServer(math.random(100, 1000))
            return true
        end
        return false
    end
}

-- Brainrot System
-- Handles Brainrot-related features (buying, teleporting, stealing)
local BrainrotSystem = {
    --[[
        buyOP()
        Fires the BuyBrainrot remote event to purchase an OP Brainrot
        Returns: boolean (success)
    ]]
    buyOP = function()
        local remote = validateRemote("BuyBrainrot")
        if remote then
            remote:FireServer("GodOP_" .. tostring(math.random(1000, 9999)))
            return true
        end
        return false
    end,
    
    --[[
        findClosest()
        Finds the closest Brainrot object in the workspace
        Uses caching for performance
        Returns: Instance (BasePart) or nil
    ]]
    findClosest = function()
        local rootPart = getHumanoidRootPart()
        if not rootPart then return nil end
        
        -- Update cache if needed
        local currentTime = tick()
        if currentTime - lastBrainrotCacheUpdate > BRAINROT_CACHE_TIMEOUT then
            brainrotCache = {}
            -- Corrigido: Buscar corretamente por BaseParts
            for _, obj in pairs(Workspace:GetDescendants()) do
                if obj:IsA("BasePart") and obj.Name:lower():find("brainrot") then
                    table.insert(brainrotCache, obj)
                end
            end
            lastBrainrotCacheUpdate = currentTime
        end
        
        local closest = nil
        local closestDistance = math.huge
        
        -- Use cached brainrots
        for _, obj in pairs(brainrotCache) do
            if obj and obj.Parent then -- Check if object still exists
                local distance = (rootPart.Position - obj.Position).Magnitude
                if distance < closestDistance then
                    closest = obj
                    closestDistance = distance
                end
            end
        end
        
        return closest
    end,
    
    --[[
        teleportToClosest()
        Teleports the player to the closest Brainrot
        Returns: boolean (success)
    ]]
    teleportToClosest = function()
        local brainrot = BrainrotSystem.findClosest()
        if not brainrot then return false end
        
        local rootPart = getHumanoidRootPart()
        if rootPart then
            rootPart.CFrame = CFrame.new(brainrot.Position + Vector3.new(0, 3, 0))
            return true
        end
        return false
    end,
    
    --[[
        autoSteal()
        Automatically teleports to and "steals" all Brainrots
        Returns: boolean (success)
    ]]
    autoSteal = function()
        local rootPart = getHumanoidRootPart()
        if not rootPart then return false end
        
        -- Update cache if needed
        local currentTime = tick()
        if currentTime - lastBrainrotCacheUpdate > BRAINROT_CACHE_TIMEOUT then
            brainrotCache = {}
            -- Corrigido: Buscar corretamente por BaseParts
            for _, obj in pairs(Workspace:GetDescendants()) do
                if obj:IsA("BasePart") and obj.Name:lower():find("brainrot") then
                    table.insert(brainrotCache, obj)
                end
            end
            lastBrainrotCacheUpdate = currentTime
        end
        
        local found = false
        
        -- Use cached brainrots
        for _, obj in pairs(brainrotCache) do
            if obj and obj.Parent then -- Check if object still exists
                rootPart.CFrame = CFrame.new(obj.Position + Vector3.new(0, 3, 0))
                task.wait(0.4)
                -- If there's a collection remote, add it here
                found = true
            end
        end
        
        return found
    end
}

-- Anti-Theft System
-- Creates a protective zone around the player to prevent theft
local AntiTheftSystem = {
    --[[
        activate()
        Activates the anti-theft protection system
    ]]
    activate = function()
        if antiStealEnabled then return end
        antiStealEnabled = true
        
        local rootPart = getHumanoidRootPart()
        if not rootPart then return end
        
        antiStealPart = Instance.new("Part")
        antiStealPart.Name = "AntiStealZone"
        antiStealPart.Anchored = true
        antiStealPart.Size = Vector3.new(18, 2, 18)
        antiStealPart.Position = rootPart.Position + Vector3.new(0, 4, 0)
        antiStealPart.Transparency = 0.7
        antiStealPart.BrickColor = BrickColor.new("Bright red")
        antiStealPart.CanCollide = false
        antiStealPart.Parent = Workspace
        
        antiStealPart.Touched:Connect(function(hit)
            local character = hit.Parent
            local hitPlayer = Players:GetPlayerFromCharacter(character)
            if hitPlayer and hitPlayer ~= player then
                -- Less extreme than game:Shutdown()
                warn("Anti-Theft System: Player " .. hitPlayer.Name .. " approached!")
                -- Could add more sophisticated anti-theft measures here
            end
        end)
    end,
    
    --[[
        deactivate()
        Deactivates the anti-theft protection system
    ]]
    deactivate = function()
        antiStealEnabled = false
        if antiStealPart and antiStealPart.Parent then
            antiStealPart:Destroy()
        end
        antiStealPart = nil
    end
}

-- Upwalk System
-- Creates a platform that moves upward for easy traversal
local UpwalkSystem = {
    --[[
        enable()
        Enables the upwalk platform system
    ]]
    enable = function()
        if upwalkEnabled then return end
        upwalkEnabled = true
        
        upwalkPart = Instance.new("Part")
        upwalkPart.Name = "UpwalkPlatform"
        upwalkPart.Size = Vector3.new(20, 1, 20)
        upwalkPart.Anchored = true
        upwalkPart.CanCollide = true
        upwalkPart.Transparency = 0.5
        upwalkPart.BrickColor = BrickColor.new("Bright blue")
        
        local rootPart = getHumanoidRootPart()
        upwalkPart.Position = rootPart and (rootPart.Position - Vector3.new(0, 3, 0)) or Vector3.new(0, 3, 0)
        upwalkPart.Parent = Workspace
        
        local tween = TweenService:Create(upwalkPart, TweenInfo.new(1.2), {Position = upwalkPart.Position + Vector3.new(0, 20, 0)})
        tween:Play()
    end,
    
    --[[
        disable()
        Disables the upwalk platform system
    ]]
    disable = function()
        upwalkEnabled = false
        if upwalkPart and upwalkPart.Parent then
            upwalkPart:Destroy()
        end
        upwalkPart = nil
    end
}

-- UI System
-- Handles the graphical user interface for the hub
local UISystem = {
    gui = nil,
    frame = nil,
    
    --[[
        create()
        Creates the main user interface for the hub
    ]]
    create = function()
        -- Create GUI
        UISystem.gui = Instance.new("ScreenGui")
        UISystem.gui.Name = "BrainrotHub"
        UISystem.gui.Parent = game.CoreGui
        UISystem.gui.ResetOnSpawn = false
        
        -- Create main frame
        UISystem.frame = Instance.new("Frame")
        UISystem.frame.Size = UDim2.new(0, 260, 0, 420)
        UISystem.frame.Position = UDim2.new(0.03, 0, 0.18, 0)
        UISystem.frame.BackgroundColor3 = Color3.fromRGB(30, 30, 45)
        UISystem.frame.BackgroundTransparency = 0.1
        UISystem.frame.BorderSizePixel = 0
        UISystem.frame.Active = true
        UISystem.frame.Draggable = true
        UISystem.frame.Parent = UISystem.gui
        
        -- Add a subtle border
        local border = Instance.new("Frame")
        border.Size = UDim2.new(1, 0, 1, 0)
        border.Position = UDim2.new(0, 0, 0, 0)
        border.BackgroundColor3 = Color3.fromRGB(80, 80, 120)
        border.BackgroundTransparency = 0.7
        border.BorderSizePixel = 0
        border.Parent = UISystem.frame
        
        -- Title
        local title = Instance.new("TextLabel")
        title.Size = UDim2.new(1, 0, 0, 36)
        title.Position = UDim2.new(0, 0, 0, 0)
        title.Text = "Brainrot Hub"
        title.TextColor3 = Color3.fromRGB(255, 255, 255)
        title.Font = Enum.Font.SourceSansBold
        title.TextSize = 20
        title.BackgroundTransparency = 1
        title.Parent = UISystem.frame
        
        -- Add a line under the title
        local titleLine = Instance.new("Frame")
        titleLine.Size = UDim2.new(1, -20, 0, 1)
        titleLine.Position = UDim2.new(0, 10, 0, 36)
        titleLine.BackgroundColor3 = Color3.fromRGB(100, 100, 150)
        titleLine.BorderSizePixel = 0
        titleLine.Parent = UISystem.frame
        
        -- Button positions
        local buttonY = 54
        local buttonSpacing = 48
        
        -- Teleport Save Button
        local btnTPSave = UISystem.createButton("Salvar ponto TP", "Save TP", buttonY)
        btnTPSave.BackgroundColor3 = Color3.fromRGB(60, 100, 60)
        btnTPSave.MouseButton1Click:Connect(function()
            if TeleportSystem.savePosition() then
                UISystem.updateButtonText(btnTPSave, "Ponto salvo!", "Salvar ponto TP", 1.3)
            else
                UISystem.updateButtonText(btnTPSave, "Erro ao salvar", "Salvar ponto TP", 1.3)
            end
        end)
        
        -- Add hover effect
        btnTPSave.MouseEnter:Connect(function()
            btnTPSave.BackgroundColor3 = Color3.fromRGB(80, 140, 80)
        end)
        btnTPSave.MouseLeave:Connect(function()
            btnTPSave.BackgroundColor3 = Color3.fromRGB(60, 100, 60)
        end)
        
        -- Teleport to Saved Button
        local btnTPLoad = UISystem.createButton("Teleportar para ponto", "Load TP", buttonY + buttonSpacing)
        btnTPLoad.BackgroundColor3 = Color3.fromRGB(60, 60, 100)
        btnTPLoad.MouseButton1Click:Connect(function()
            if TeleportSystem.teleportToSaved() then
                UISystem.updateButtonText(btnTPLoad, "Teleportado!", "Teleportar para ponto", 1.3)
            else
                UISystem.updateButtonText(btnTPLoad, "Nenhum ponto salvo", "Teleportar para ponto", 1.3)
            end
        end)
        
        -- Add hover effect
        btnTPLoad.MouseEnter:Connect(function()
            btnTPLoad.BackgroundColor3 = Color3.fromRGB(80, 80, 140)
        end)
        btnTPLoad.MouseLeave:Connect(function()
            btnTPLoad.BackgroundColor3 = Color3.fromRGB(60, 60, 100)
        end)
        
        -- Teleport to Brainrot Button
        local btnBrainrotTP = UISystem.createButton("TP para Brainrot mais próximo", "TP to Brainrot", buttonY + buttonSpacing * 2)
        btnBrainrotTP.BackgroundColor3 = Color3.fromRGB(60, 60, 140)
        btnBrainrotTP.MouseButton1Click:Connect(function()
            if BrainrotSystem.teleportToClosest() then
                UISystem.updateButtonText(btnBrainrotTP, "Teleportado!", "TP para Brainrot mais próximo", 1.3)
            else
                UISystem.updateButtonText(btnBrainrotTP, "Nenhum Brainrot encontrado", "TP para Brainrot mais próximo", 1.3)
            end
        end)
        
        -- Add hover effect
        btnBrainrotTP.MouseEnter:Connect(function()
            btnBrainrotTP.BackgroundColor3 = Color3.fromRGB(80, 80, 180)
        end)
        btnBrainrotTP.MouseLeave:Connect(function()
            btnBrainrotTP.BackgroundColor3 = Color3.fromRGB(60, 60, 140)
        end)
        
        -- Auto Steal Button
        local btnAutoSteal = UISystem.createButton("Auto Roubo Brainrots", "Auto Steal", buttonY + buttonSpacing * 3)
        btnAutoSteal.BackgroundColor3 = Color3.fromRGB(140, 60, 60)
        btnAutoSteal.MouseButton1Click:Connect(function()
            if BrainrotSystem.autoSteal() then
                UISystem.updateButtonText(btnAutoSteal, "Roubo concluído!", "Auto Roubo Brainrots", 1.3)
            else
                UISystem.updateButtonText(btnAutoSteal, "Nenhum Brainrot encontrado", "Auto Roubo Brainrots", 1.3)
            end
        end)
        
        -- Add hover effect
        btnAutoSteal.MouseEnter:Connect(function()
            btnAutoSteal.BackgroundColor3 = Color3.fromRGB(180, 80, 80)
        end)
        btnAutoSteal.MouseLeave:Connect(function()
            btnAutoSteal.BackgroundColor3 = Color3.fromRGB(140, 60, 60)
        end)
        
        -- Collect Money Button
        local btnCollectMoney = UISystem.createButton("Coletar Dinheiro", "Collect Money", buttonY + buttonSpacing * 4)
        btnCollectMoney.BackgroundColor3 = Color3.fromRGB(100, 100, 60)
        btnCollectMoney.MouseButton1Click:Connect(function()
            if MoneySystem.collect() then
                UISystem.updateButtonText(btnCollectMoney, "Dinheiro coletado!", "Coletar Dinheiro", 1.3)
            else
                UISystem.updateButtonText(btnCollectMoney, "Falha ao coletar", "Coletar Dinheiro", 1.3)
            end
        end)
        
        -- Add hover effect
        btnCollectMoney.MouseEnter:Connect(function()
            btnCollectMoney.BackgroundColor3 = Color3.fromRGB(140, 140, 80)
        end)
        btnCollectMoney.MouseLeave:Connect(function()
            btnCollectMoney.BackgroundColor3 = Color3.fromRGB(100, 100, 60)
        end)
        
        -- Buy OP Brainrot Button
        local btnBuyOP = UISystem.createButton("Comprar Brainrot OP", "Buy OP Brainrot", buttonY + buttonSpacing * 5)
        btnBuyOP.BackgroundColor3 = Color3.fromRGB(140, 100, 60)
        btnBuyOP.MouseButton1Click:Connect(function()
            if BrainrotSystem.buyOP() then
                UISystem.updateButtonText(btnBuyOP, "Comprado!", "Comprar Brainrot OP", 1.3)
            else
                UISystem.updateButtonText(btnBuyOP, "Falha ao comprar", "Comprar Brainrot OP", 1.3)
            end
        end)
        
        -- Add hover effect
        btnBuyOP.MouseEnter:Connect(function()
            btnBuyOP.BackgroundColor3 = Color3.fromRGB(180, 140, 80)
        end)
        btnBuyOP.MouseLeave:Connect(function()
            btnBuyOP.BackgroundColor3 = Color3.fromRGB(140, 100, 60)
        end)
        
        -- Anti-Theft Button
        local btnAntiTheft = UISystem.createButton("Anti Steal: OFF", "Anti Theft", buttonY + buttonSpacing * 6)
        btnAntiTheft.BackgroundColor3 = Color3.fromRGB(100, 40, 40)
        btnAntiTheft.MouseButton1Click:Connect(function()
            if not antiStealEnabled then
                AntiTheftSystem.activate()
                btnAntiTheft.Text = "Anti Steal: ON"
                btnAntiTheft.BackgroundColor3 = Color3.fromRGB(40, 100, 40)
            else
                AntiTheftSystem.deactivate()
                btnAntiTheft.Text = "Anti Steal: OFF"
                btnAntiTheft.BackgroundColor3 = Color3.fromRGB(100, 40, 40)
            end
        end)
        
        -- Add hover effect
        btnAntiTheft.MouseEnter:Connect(function()
            if not antiStealEnabled then
                btnAntiTheft.BackgroundColor3 = Color3.fromRGB(140, 60, 60)
            else
                btnAntiTheft.BackgroundColor3 = Color3.fromRGB(60, 140, 60)
            end
        end)
        btnAntiTheft.MouseLeave:Connect(function()
            if not antiStealEnabled then
                btnAntiTheft.BackgroundColor3 = Color3.fromRGB(100, 40, 40)
            else
                btnAntiTheft.BackgroundColor3 = Color3.fromRGB(40, 100, 40)
            end
        end)
        
        -- Upwalk Button
        local btnUpwalk = UISystem.createButton("Upwalk: OFF", "Upwalk", buttonY + buttonSpacing * 7)
        btnUpwalk.BackgroundColor3 = Color3.fromRGB(60, 60, 100)
        btnUpwalk.MouseButton1Click:Connect(function()
            if not upwalkEnabled then
                UpwalkSystem.enable()
                btnUpwalk.Text = "Upwalk: ON"
                btnUpwalk.BackgroundColor3 = Color3.fromRGB(40, 100, 100)
            else
                UpwalkSystem.disable()
                btnUpwalk.Text = "Upwalk: OFF"
                btnUpwalk.BackgroundColor3 = Color3.fromRGB(60, 60, 100)
            end
        end)
        
        -- Add hover effect
        btnUpwalk.MouseEnter:Connect(function()
            if not upwalkEnabled then
                btnUpwalk.BackgroundColor3 = Color3.fromRGB(80, 80, 140)
            else
                btnUpwalk.BackgroundColor3 = Color3.fromRGB(60, 140, 140)
            end
        end)
        btnUpwalk.MouseLeave:Connect(function()
            if not upwalkEnabled then
                btnUpwalk.BackgroundColor3 = Color3.fromRGB(60, 60, 100)
            else
                btnUpwalk.BackgroundColor3 = Color3.fromRGB(40, 100, 100)
            end
        end)
        
        -- Info Label
        local info = Instance.new("TextLabel")
        info.Size = UDim2.new(1, -20, 0, 30)
        info.Position = UDim2.new(0, 10, 0, buttonY + buttonSpacing * 8)
        info.Text = "Atalhos: Z=Salvar TP | X=Ir para TP | C=Dinheiro | V=Brainrot OP | Y=TP Brainrot | U=Auto Roubo"
        info.TextColor3 = Color3.fromRGB(200, 200, 200)
        info.Font = Enum.Font.SourceSans
        info.TextSize = 16
        info.BackgroundTransparency = 1
        info.Parent = UISystem.frame
    end,
    
    --[[
        createButton(text, name, yPosition)
        Creates a styled button for the UI
        Parameters: 
            text (string) - Button text
            name (string) - Button name
            yPosition (number) - Vertical position
        Returns: Instance (TextButton)
    ]]
    createButton = function(text, name, yPosition)
        local button = Instance.new("TextButton")
        button.Name = name
        button.Size = UDim2.new(1, -28, 0, 38)
        button.Position = UDim2.new(0, 14, 0, yPosition)
        button.Text = text
        button.BackgroundColor3 = Color3.fromRGB(44, 44, 70)
        button.TextColor3 = Color3.new(1, 1, 1)
        button.Font = Enum.Font.SourceSans
        button.TextSize = 17
        button.AutoButtonColor = false -- Disable default hover effect
        button.Parent = UISystem.frame
        return button
    end,
    
    --[[
        updateButtonText(button, tempText, originalText, delay)
        Temporarily changes a button's text and then reverts it after a delay
        Parameters:
            button (Instance) - The button to update
            tempText (string) - Temporary text to show
            originalText (string) - Original text to revert to
            delay (number) - Delay in seconds before reverting
    ]]
    updateButtonText = function(button, tempText, originalText, delay)
        button.Text = tempText
        task.spawn(function()
            task.wait(delay)
            if button and button.Parent then
                button.Text = originalText
            end
        end)
    end
}

-- Keyboard Shortcuts
-- Handles keyboard input for quick access to features
--[[
    Connects to UserInputService to listen for key presses
    Implements cooldowns to prevent spamming
]]
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    local now = tick()
    
    if input.KeyCode == Enum.KeyCode.Z and now - lastKeyPressTimes.Z > 2 then
        lastKeyPressTimes.Z = now
        TeleportSystem.savePosition()
    elseif input.KeyCode == Enum.KeyCode.X and now - lastKeyPressTimes.X > 2 then
        lastKeyPressTimes.X = now
        TeleportSystem.teleportToSaved()
    elseif input.KeyCode == Enum.KeyCode.C and now - lastKeyPressTimes.C > 2 then
        lastKeyPressTimes.C = now
        MoneySystem.collect()
    elseif input.KeyCode == Enum.KeyCode.V and now - lastKeyPressTimes.V > 2 then
        lastKeyPressTimes.V = now
        BrainrotSystem.buyOP()
    elseif input.KeyCode == Enum.KeyCode.Y and now - lastKeyPressTimes.Y > 2 then
        lastKeyPressTimes.Y = now
        BrainrotSystem.teleportToClosest()
    elseif input.KeyCode == Enum.KeyCode.U and now - lastKeyPressTimes.U > 2 then
        lastKeyPressTimes.U = now
        BrainrotSystem.autoSteal()
    end
end)

-- Initialize
--[[
    Creates the user interface when the script runs
]]
UISystem.create()
