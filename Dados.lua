-- 💜 VIMTO HUB v3 | by NOTVIMTO | Delta Ready & Optimized

local player = game.Players.LocalPlayer
local UIS = game:GetService("UserInputService")

-- تنظيف
if player.PlayerGui:FindFirstChild("VIMTO_HUB") then
    player.PlayerGui.VIMTO_HUB:Destroy()
end

-- شاشة
local gui = Instance.new("ScreenGui", player.PlayerGui)
gui.Name = "VIMTO_HUB"
gui.ResetOnSpawn = false

-- ألوان
local violet = Color3.fromRGB(140, 0, 255)
local dark = Color3.fromRGB(35, 35, 35)
local white = Color3.new(1, 1, 1)

-- زر الإظهار/الإخفاء
local toggleButton = Instance.new("TextButton", gui)
toggleButton.Size = UDim2.new(0, 60, 0, 60)
toggleButton.Position = UDim2.new(0, 10, 0.5, -30)
toggleButton.BackgroundColor3 = violet
toggleButton.Text = "💜"
toggleButton.TextColor3 = white
toggleButton.TextSize = 22
toggleButton.Font = Enum.Font.GothamBold
toggleButton.Draggable = true
toggleButton.Active = true
Instance.new("UICorner", toggleButton).CornerRadius = UDim.new(1, 0)

-- القائمة الرئيسية
local frame = Instance.new("Frame", gui)
frame.Size = UDim2.new(0, 500, 0, 340)
frame.Position = UDim2.new(0.5, -250, 0.5, -170)
frame.BackgroundColor3 = dark
frame.Visible = false
frame.Active = true
frame.Draggable = true
Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 10)

-- العنوان
local title = Instance.new("TextLabel", frame)
title.Size = UDim2.new(1, 0, 0, 40)
title.Text = "💜 VIMTO HUB v3"
title.BackgroundColor3 = violet
title.TextColor3 = white
title.Font = Enum.Font.GothamBold
title.TextSize = 20
Instance.new("UICorner", title).CornerRadius = UDim.new(0, 10)

-- أقسام القوائم
local mainFrame = Instance.new("Frame", frame)
mainFrame.Position = UDim2.new(0, 10, 0, 50)
mainFrame.Size = UDim2.new(0.5, -15, 1, -60)
mainFrame.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
Instance.new("UICorner", mainFrame).CornerRadius = UDim.new(0, 6)

local espFrame = Instance.new("Frame", frame)
espFrame.Position = UDim2.new(0.5, 5, 0, 50)
espFrame.Size = UDim2.new(0.5, -15, 1, -60)
espFrame.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
Instance.new("UICorner", espFrame).CornerRadius = UDim.new(0, 6)

-- زر الإظهار/الإخفاء
toggleButton.MouseButton1Click:Connect(function()
 frame.Visible = not frame.Visible
end)

-- صانع أزرار
local function createButton(parent, text, callback)
 local btn = Instance.new("TextButton", parent)
 btn.Size = UDim2.new(1, -20, 0, 30)
 btn.Position = UDim2.new(0, 10, 0, #parent:GetChildren() * 35)
 btn.BackgroundColor3 = violet
 btn.TextColor3 = white
 btn.TextSize = 14
 btn.Font = Enum.Font.Gotham
 btn.Text = text
 btn.AutoButtonColor = true
 btn.MouseButton1Click:Connect(callback)
 Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 4)
end

-- حالة الأزرار
local infJump = false
local speedBoost = false
local jumpBoost = false

-- MAIN BUTTONS 💥

createButton(mainFrame, "☁️ TP to Sky", function()
 local hrp = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
 if hrp then
  hrp.CFrame = hrp.CFrame + Vector3.new(0, 220, 0)
 end
end)

createButton(mainFrame, "⬇️ Fall Down", function()
 local hrp = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
 if hrp then
  hrp.CFrame = hrp.CFrame - Vector3.new(0, 150, 0)
 end
end)

createButton(mainFrame, "🕴️ Infinite Jump [Toggle]", function()
 infJump = not infJump
 if infJump then
  game:GetService("UserInputService").JumpRequest:Connect(function()
   if infJump and player.Character then
    local hum = player.Character:FindFirstChildOfClass("Humanoid")
    if hum then hum:ChangeState(Enum.HumanoidStateType.Jumping) end
   end
  end)
 end
end)

createButton(mainFrame, "⚡ Speed Boost [Toggle]", function()
 speedBoost = not speedBoost
 local hum = player.Character and player.Character:FindFirstChildOfClass("Humanoid")
 if hum then hum.WalkSpeed = speedBoost and 60 or 16 end
end)

createButton(mainFrame, "🦘 Jump Boost [Toggle]", function()
 jumpBoost = not jumpBoost
 local hum = player.Character and player.Character:FindFirstChildOfClass("Humanoid")
 if hum then hum.JumpPower = jumpBoost and 120 or 50 end
end)

-- ESP BUTTONS 👁️
createButton(espFrame, "👁️ ESP Players", function()
 for _, plr in pairs(game.Players:GetPlayers()) do
  if plr ~= player and plr.Character and not plr.Character:FindFirstChild("PlayerESP") then
   local hl = Instance.new("Highlight", plr.Character)
   hl.Name = "PlayerESP"
   hl.FillColor = Color3.fromRGB(255, 255, 0)
   hl.OutlineColor = Color3.new(0, 0, 0)
  end
 end
end)

createButton(espFrame, "🧠 ESP Secret Brainrots", function()
 for _, model in ipairs(workspace:GetDescendants()) do
  if model:IsA("Model") and model:FindFirstChild("Head") then
   local name = model.Name:lower()
   if name:find("secret") or name:find("saturn") then
    if not model:FindFirstChild("SecretESP") then
     local hl = Instance.new("Highlight", model)
     hl.Name = "SecretESP"
     hl.FillColor = Color3.fromRGB(255, 0, 255)
     hl.OutlineColor = Color3.new(0, 0, 0)
    end
   end
  end
 end
end)

createButton(espFrame, "🔒 ESP Lock Timer", function()
 for _, obj in ipairs(workspace:GetDescendants()) do
  if obj:IsA("TextLabel") and obj.Text:find("مقفل:") then
   local parent = obj.Parent
   if parent:IsA("Model") or parent:IsA("Part") then
    local hl = Instance.new("Highlight", parent)
    hl.Name = "LockESP"
    hl.FillColor = Color3.fromRGB(0, 255, 255)
    hl.OutlineColor = Color3.new(0, 0, 0)

    -- مراقبة التايمر
    task.spawn(function()
     while task.wait(1) do
      if obj and obj.Text and not obj.Text:find("%ds") then
       obj.Text = "Unlocked ✅"
       break
      end
     end
    end)
   end
  end
 end
end)
