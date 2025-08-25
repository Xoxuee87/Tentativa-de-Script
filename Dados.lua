local player = game:GetService("Players").LocalPlayer
local gui = Instance.new("ScreenGui", player.PlayerGui)
local frame = Instance.new("Frame", gui)
frame.Size = UDim2.new(0, 350, 0, 450)
frame.Position = UDim2.new(0, 10, 0, 10)
frame.BackgroundColor3 = Color3.new(0.15,0.15,0.15)

local scroll = Instance.new("ScrollingFrame", frame)
scroll.Size = UDim2.new(1, -10, 1, -10)
scroll.Position = UDim2.new(0, 5, 0, 5)
scroll.CanvasSize = UDim2.new(0, 0, 0, 0)
scroll.ScrollBarThickness = 8
scroll.BackgroundTransparency = 1

local layout = Instance.new("UIListLayout", scroll)
layout.SortOrder = Enum.SortOrder.LayoutOrder

for _, obj in pairs(game.Workspace:GetChildren()) do
    local label = Instance.new("TextLabel", scroll)
    label.Size = UDim2.new(1, -10, 0, 20)
    label.Text = obj.Name .. " (".. obj.ClassName ..")"
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.BackgroundTransparency = 1
    label.TextColor3 = Color3.new(1,1,1)
    label.Font = Enum.Font.SourceSans
    label.TextSize = 16
    -- Lista filhos também
    for _, subobj in pairs(obj:GetChildren()) do
        local sublabel = Instance.new("TextLabel", scroll)
        sublabel.Size = UDim2.new(1, -25, 0, 18)
        sublabel.Text = "  - " .. subobj.Name .. " ("..subobj.ClassName..")"
        sublabel.TextXAlignment = Enum.TextXAlignment.Left
        sublabel.BackgroundTransparency = 1
        sublabel.TextColor3 = Color3.new(0.8,0.8,0.8)
        sublabel.Font = Enum.Font.SourceSans
        sublabel.TextSize = 14
    end
end
scroll.CanvasSize = UDim2.new(0, 0, 0, layout.AbsoluteContentSize.Y)
