-- 💜 VIMTO HUB v9 | Official Launch Edition | الجزء 1/4

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local StarterGui = game:GetService("StarterGui")
local player = Players.LocalPlayer

-- تنظيف GUI قديم
if player.PlayerGui:FindFirstChild("VIMTO_HUB") then
 player.PlayerGui.VIMTO_HUB:Destroy()
end

-- إنشاء GUI
local gui = Instance.new("ScreenGui", player.PlayerGui)
gui.Name = "VIMTO_HUB"
gui.ResetOnSpawn = false

-- ألوان
local accentColor = Color3.fromRGB(140, 0, 255)
local darkColor = Color3.fromRGB(20, 20, 20)
local textColor = Color3.fromRGB(255, 255, 255)

-- واجهة تحميل
local loading = Instance.new("Frame", gui)
loading.Size = UDim2.new(0, 300, 0, 150)
loading.Position = UDim2.new(0.5, -150, 0.5, -75)
loading.BackgroundColor3 = darkColor
loading.BackgroundTransparency = 0.2
loading.BorderSizePixel = 0
Instance.new("UICorner", loading).CornerRadius = UDim.new(0, 12)

local title = Instance.new("TextLabel", loading)
title.Size = UDim2.new(1, 0, 0.5, 0)
title.Position = UDim2.new(0, 0, 0, 0)
title.BackgroundTransparency = 1
title.Text = "💜 VIMTO HUB"
title.Font = Enum.Font.GothamBold
title.TextSize = 26
title.TextColor3 = textColor

local subtitle = Instance.new("TextLabel", loading)
subtitle.Size = UDim2.new(1, 0, 0.5, 0)
subtitle.Position = UDim2.new(0, 0, 0.5, 0)
subtitle.BackgroundTransparency = 1
subtitle.Text = "Loading... Please Wait"
subtitle.Font = Enum.Font.Gotham
subtitle.TextSize = 14
subtitle.TextColor3 = Color3.fromRGB(200, 200, 200)

-- تحميل وهمي
wait(1.8)
TweenService:Create(loading, TweenInfo.new(0.5), {BackgroundTransparency = 1}):Play()
TweenService:Create(title, TweenInfo.new(0.5), {TextTransparency = 1}):Play()
TweenService:Create(subtitle, TweenInfo.new(0.5), {TextTransparency = 1}):Play()
wait(0.6)
loading:Destroy()

-- إشعار عند التشغيل
pcall(function()
 StarterGui:SetCore("SendNotification", {
  Title = "💜 VIMTO HUB",
  Text = "Enjoy Using VIMTO Hub!",
  Duration = 5
 })
end)

-- زر فتح الواجهة
local openBtn = Instance.new("TextButton", gui)
openBtn.Size = UDim2.new(0, 130, 0, 50)
openBtn.Position = UDim2.new(0, 20, 0.5, -25)
openBtn.BackgroundColor3 = darkColor
openBtn.Text = "💜 VIMTO HUB"
openBtn.TextColor3 = accentColor
openBtn.Font = Enum.Font.GothamBold
openBtn.TextSize = 16
openBtn.Draggable = true
Instance.new("UICorner", openBtn).CornerRadius = UDim.new(0, 12)

-- الواجهة الرئيسية
local mainFrame = Instance.new("Frame", gui)
mainFrame.Size = UDim2.new(0, 500, 0, 380)
mainFrame.Position = UDim2.new(0.5, -250, 0.5, -190)
mainFrame.BackgroundColor3 = darkColor
mainFrame.BackgroundTransparency = 0.3
mainFrame.Visible = false
mainFrame.Active = true
mainFrame.Draggable = true
Instance.new("UICorner", mainFrame).CornerRadius = UDim.new(0, 14)

-- الهيدر
local header = Instance.new("Frame", mainFrame)
header.Size = UDim2.new(1, 0, 0, 50)
header.BackgroundColor3 = accentColor
header.BackgroundTransparency = 0.3
header.Position = UDim2.new(0, 0, 0, 0)
Instance.new("UICorner", header).CornerRadius = UDim.new(0, 14)

local headerLabel = Instance.new("TextLabel", header)
headerLabel.Size = UDim2.new(1, -60, 1, 0)
headerLabel.Position = UDim2.new(0, 10, 0, 0)
headerLabel.Text = "💜 VIMTO HUB v9"
headerLabel.TextColor3 = textColor
headerLabel.Font = Enum.Font.GothamBold
headerLabel.TextSize = 20
headerLabel.TextXAlignment = Enum.TextXAlignment.Left
headerLabel.BackgroundTransparency = 1

-- زر الإغلاق
local closeBtn = Instance.new("TextButton", header)
closeBtn.Size = UDim2.new(0, 40, 0, 40)
closeBtn.Position = UDim2.new(1, -50, 0.5, -20)
closeBtn.Text = "✕"
closeBtn.Font = Enum.Font.GothamBold
closeBtn.TextSize = 18
closeBtn.TextColor3 = textColor
closeBtn.BackgroundColor3 = Color3.fromRGB(60, 0, 100)
Instance.new("UICorner", closeBtn).CornerRadius = UDim.new(1, 0)

closeBtn.MouseButton1Click:Connect(function()
 mainFrame.Visible = false
end)

-- Fix the open button connection
local function toggleHub()
 mainFrame.Visible = not mainFrame.Visible
 if mainFrame.Visible and not currentTab then
  wait(0.1)
  playerTab.MouseButton1Click()
 end
end

openBtn.MouseButton1Click:Connect(toggleHub)

-- تبويبات
local tabFrame = Instance.new("Frame", mainFrame)
tabFrame.Size = UDim2.new(0, 100, 1, -60)
tabFrame.Position = UDim2.new(0, 5, 0, 55)
tabFrame.BackgroundTransparency = 1

-- إضافة UIListLayout للتبويبات
local tabLayout = Instance.new("UIListLayout", tabFrame)
tabLayout.SortOrder = Enum.SortOrder.LayoutOrder
tabLayout.Padding = UDim.new(0, 5)
tabLayout.FillDirection = Enum.FillDirection.Vertical

-- محتوى التبويب
local contentFrame = Instance.new("ScrollingFrame", mainFrame)
contentFrame.Size = UDim2.new(1, -115, 1, -70)
contentFrame.Position = UDim2.new(0, 110, 0, 60)
contentFrame.BackgroundTransparency = 1
contentFrame.ScrollBarThickness = 4
contentFrame.ScrollBarImageColor3 = accentColor
contentFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
contentFrame.AutomaticCanvasSize = Enum.AutomaticSize.Y

local listLayout = Instance.new("UIListLayout", contentFrame)
listLayout.SortOrder = Enum.SortOrder.LayoutOrder
listLayout.Padding = UDim.new(0, 10)

-- إنشاء التبويبات
local currentTab = nil
local function createTab(name, icon, onClick)
 local tab = Instance.new("TextButton", tabFrame)
 tab.Size = UDim2.new(1, 0, 0, 35)
 tab.Text = icon .. " " .. name
 tab.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
 tab.TextColor3 = textColor
 tab.Font = Enum.Font.GothamBold
 tab.TextSize = 12
 tab.BorderSizePixel = 0
 tab.TextWrapped = true
 Instance.new("UICorner", tab).CornerRadius = UDim.new(0, 10)

 tab.MouseButton1Click:Connect(function()
  if currentTab then
   currentTab.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
  end
  currentTab = tab
  tab.BackgroundColor3 = accentColor

  -- مسح المحتوى القديم
  for _, child in pairs(contentFrame:GetChildren()) do
   if not child:IsA("UIListLayout") then
    child:Destroy()
   end
  end

  if onClick then onClick() end
 end)

 return tab
end

-- أدوات تحكم
local function createToggle(name, callback)
 local container = Instance.new("Frame", contentFrame)
 container.Size = UDim2.new(1, 0, 0, 45)
 container.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
 container.BorderSizePixel = 0
 Instance.new("UICorner", container).CornerRadius = UDim.new(0, 8)

 local label = Instance.new("TextLabel", container)
 label.Size = UDim2.new(1, -80, 1, 0)
 label.Position = UDim2.new(0, 10, 0, 0)
 label.BackgroundTransparency = 1
 label.Text = name
 label.Font = Enum.Font.Gotham
 label.TextSize = 14
 label.TextColor3 = textColor
 label.TextXAlignment = Enum.TextXAlignment.Left

 local toggle = Instance.new("TextButton", container)
 toggle.Size = UDim2.new(0, 55, 0, 25)
 toggle.Position = UDim2.new(1, -65, 0.5, -12)
 toggle.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
 toggle.Text = "OFF"
 toggle.TextColor3 = textColor
 toggle.Font = Enum.Font.GothamBold
 toggle.TextSize = 12
 Instance.new("UICorner", toggle).CornerRadius = UDim.new(1, 0)

 local state = false
 toggle.MouseButton1Click:Connect(function()
  state = not state
  toggle.Text = state and "ON" or "OFF"
  toggle.BackgroundColor3 = state and accentColor or Color3.fromRGB(60, 60, 60)
  if callback then callback(state) end
 end)
end

local function createButton(name, callback)
 local button = Instance.new("TextButton", contentFrame)
 button.Size = UDim2.new(1, 0, 0, 40)
 button.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
 button.Text = name
 button.TextColor3 = textColor
 button.Font = Enum.Font.Gotham
 button.TextSize = 14
 button.BorderSizePixel = 0
 Instance.new("UICorner", button).CornerRadius = UDim.new(0, 8)

 button.MouseButton1Click:Connect(callback)
end

-- الوظائف حسب التبويب
local noClipConn
local speedBoost, jumpBoost

-- PLAYER TAB
local function loadPlayerTab()
 createToggle("Speed Boost", function(state)
  speedBoost = state
  local hum = player.Character and player.Character:FindFirstChildOfClass("Humanoid")
  if hum then hum.WalkSpeed = state and 250 or 16 end
 end)

 createToggle("Jump Boost", function(state)
  jumpBoost = state
  local hum = player.Character and player.Character:FindFirstChildOfClass("Humanoid")
  if hum then hum.JumpPower = state and 150 or 50 end
 end)

 createToggle("NoClip", function(state)
  if state then
   noClipConn = RunService.Stepped:Connect(function()
    local char = player.Character
    if char then
     for _, part in pairs(char:GetDescendants()) do
      if part:IsA("BasePart") then part.CanCollide = false end
     end
    end
   end)
  else
   if noClipConn then noClipConn:Disconnect() end
  end
 end)

 createButton("🔄 Reset Character", function()
  local char = player.Character
  if char and char:FindFirstChild("Humanoid") then
   char.Humanoid.Health = 0
  end
 end)
end

-- VISUAL TAB
local function loadVisualTab()
 createToggle("👁️ Player ESP", function(state)
  for _, plr in pairs(Players:GetPlayers()) do
   if plr ~= player and plr.Character then
    local esp = plr.Character:FindFirstChild("PlayerESP")
    if state and not esp then
     local h = Instance.new("Highlight", plr.Character)
     h.Name = "PlayerESP"
     h.FillColor = accentColor
     h.OutlineColor = Color3.new(1,1,1)
    elseif not state and esp then
     esp:Destroy()
    end
   end
  end
 end)

 createToggle("💡 Full Bright", function(state)
  local l = game:GetService("Lighting")
  if state then
   l.Brightness = 2
   l.ClockTime = 14
   l.FogEnd = 100000
   l.GlobalShadows = false
  else
   l.Brightness = 1
   l.ClockTime = 12
   l.FogEnd = 100
   l.GlobalShadows = true
  end
 end)
end

-- TELEPORT TAB
local function loadTeleportTab()
 createButton("🚀 Teleport To Sky", function()
  local root = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
  if root then
   root.CFrame = root.CFrame + Vector3.new(0, 200, 0)
  end
 end)

 createButton("⬇️ Fall Down", function()
  local root = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
  if root then
   root.CFrame = root.CFrame - Vector3.new(0, 50, 0)
  end
 end)

 createButton("🏠 Teleport To Spawn", function()
  local root = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
  if root then
   root.CFrame = CFrame.new(0, 10, 0)
  end
 end)
end

-- MISC TAB
local function loadMiscTab()
 createToggle("🛡️ Anti Ragdoll", function(state)
  if state then
   local function apply(char)
    local hum = char:FindFirstChildOfClass("Humanoid")
    if hum then
     hum.StateChanged:Connect(function(_, new)
      if new == Enum.HumanoidStateType.FallingDown or new == Enum.HumanoidStateType.PlatformStanding then
       hum:ChangeState(Enum.HumanoidStateType.GettingUp)
      end
     end)
    end
   end

   if player.Character then apply(player.Character) end
   player.CharacterAdded:Connect(apply)
  end
 end)

 createButton("🔄 Rejoin Server", function()
  game:GetService("TeleportService"):Teleport(game.PlaceId, player)
 end)

 createButton("📋 Copy Game ID", function()
  if setclipboard then
   setclipboard("https://www.roblox.com/games/" .. game.PlaceId)
  end
 end)
end

-- ربط التبويبات + تشغيل أول تبويب تلقائياً
local playerTab = createTab("Player", "👤", loadPlayerTab)
local visualTab = createTab("Visual", "👁️", loadVisualTab)
local teleportTab = createTab("Teleport", "📍", loadTeleportTab)
local miscTab = createTab("Misc", "⚙️", loadMiscTab)

-- تفعيل أول تبويب عند الفتح (removed duplicate connection)

-- حفظ الإعدادات بعد الموت
player.CharacterAdded:Connect(function()
 wait(1)
 if speedBoost then
  local h = player.Character:FindFirstChildOfClass("Humanoid")
  if h then h.WalkSpeed = 250 end
 end
 if jumpBoost then
  local h = player.Character:FindFirstChildOfClass("Humanoid")
  if h then h.JumpPower = 150 end
 end
 if noClipConn then
  noClipConn:Disconnect()
  noClipConn = RunService.Stepped:Connect(function()
   local char = player.Character
   if char then
    for _, part in pairs(char:GetDescendants()) do
     if part:IsA("BasePart") then part.CanCollide = false end
    end
   end
  end)
 end
end)

-- تشغيل أول تبويب تلقائياً
wait(0.1)
-- Don't auto-load, let it load when opened

-- زر TP SKY (⬆️)
local tpUpBtn = Instance.new("TextButton", gui)
tpUpBtn.Size = UDim2.new(0, 50, 0, 50)
tpUpBtn.Position = UDim2.new(1, -120, 1, -120)
tpUpBtn.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
tpUpBtn.Text = "⬆️"
tpUpBtn.TextColor3 = textColor
tpUpBtn.Font = Enum.Font.GothamBold
tpUpBtn.TextSize = 20
tpUpBtn.Draggable = true
tpUpBtn.Active = true
Instance.new("UICorner", tpUpBtn).CornerRadius = UDim.new(0, 10)

tpUpBtn.MouseButton1Click:Connect(function()
 local char = player.Character
 if char and char:FindFirstChild("HumanoidRootPart") then
  local pos = char.HumanoidRootPart.Position
  char.HumanoidRootPart.CFrame = CFrame.new(pos.X, pos.Y + 200, pos.Z)
 end
end)

-- زر FALL DOWN (⬇️)
local tpDownBtn = Instance.new("TextButton", gui)
tpDownBtn.Size = UDim2.new(0, 50, 0, 50)
tpDownBtn.Position = UDim2.new(1, -60, 1, -120)
tpDownBtn.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
tpDownBtn.Text = "⬇️"
tpDownBtn.TextColor3 = textColor
tpDownBtn.Font = Enum.Font.GothamBold
tpDownBtn.TextSize = 20
tpDownBtn.Draggable = true
tpDownBtn.Active = true
Instance.new("UICorner", tpDownBtn).CornerRadius = UDim.new(0, 10)

tpDownBtn.MouseButton1Click:Connect(function()
 local char = player.Character
 if char and char:FindFirstChild("HumanoidRootPart") then
  local pos = char.HumanoidRootPart.Position
  char.HumanoidRootPart.CFrame = CFrame.new(pos.X, pos.Y - 50, pos.Z)
 end
end)
