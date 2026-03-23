--// Jamaha Scripts (Clean Base) //--

local UIS = game:GetService("UserInputService")

local ScreenGui = Instance.new("ScreenGui", game.CoreGui)

local Main = Instance.new("Frame", ScreenGui)
Main.Size = UDim2.new(0, 500, 0, 300)
Main.Position = UDim2.new(0.5, -250, 0.5, -150)
Main.BackgroundColor3 = Color3.fromRGB(15,15,15)

local Top = Instance.new("Frame", Main)
Top.Size = UDim2.new(1,0,0,35)
Top.BackgroundColor3 = Color3.fromRGB(25,0,0)

local Title = Instance.new("TextLabel", Top)
Title.Size = UDim2.new(1, -80, 1, 0)
Title.Position = UDim2.new(0,10,0,0)
Title.BackgroundTransparency = 1
Title.Text = "Jamaha Scripts"
Title.TextColor3 = Color3.fromRGB(255,50,50)

local Close = Instance.new("TextButton", Top)
Close.Size = UDim2.new(0,30,1,0)
Close.Position = UDim2.new(1,-30,0,0)
Close.Text = "X"

local Min = Instance.new("TextButton", Top)
Min.Size = UDim2.new(0,30,1,0)
Min.Position = UDim2.new(1,-60,0,0)
Min.Text = "-"

local Content = Instance.new("Frame", Main)
Content.Size = UDim2.new(1,0,1,-35)
Content.Position = UDim2.new(0,0,0,35)
Content.Visible = false

local Login = Instance.new("Frame", Main)
Login.Size = Content.Size
Login.Position = Content.Position

local Box = Instance.new("TextBox", Login)
Box.Size = UDim2.new(0.6,0,0,40)
Box.Position = UDim2.new(0.2,0,0.4,0)
Box.PlaceholderText = "Enter Key..."

local Submit = Instance.new("TextButton", Login)
Submit.Size = UDim2.new(0.3,0,0,35)
Submit.Position = UDim2.new(0.35,0,0.6,0)
Submit.Text = "Unlock"

Submit.MouseButton1Click:Connect(function()
	if Box.Text == "Jamaha123" then
		Login.Visible = false
		Content.Visible = true
	end
end)

Close.MouseButton1Click:Connect(function()
	Main.Visible = false
end)

Min.MouseButton1Click:Connect(function()
	Content.Visible = not Content.Visible
end)

UIS.InputBegan:Connect(function(input)
	if input.KeyCode == Enum.KeyCode.LeftControl then
		Main.Visible = not Main.Visible
	end
end)

-- =========================
-- AUTO COLLECT SYSTEM
-- =========================

local CardRemote = game:GetService("ReplicatedStorage").Remotes.Card

local AutoCollect = false

-- BUTTON
local AutoCollectBtn = Instance.new("TextButton", Content)
AutoCollectBtn.Size = UDim2.new(0,200,0,40)
AutoCollectBtn.Position = UDim2.new(0.1,0,0.1,0)
AutoCollectBtn.Text = "Auto Collect: OFF"
AutoCollectBtn.BackgroundColor3 = Color3.fromRGB(120,0,0)
AutoCollectBtn.TextColor3 = Color3.new(1,1,1)

AutoCollectBtn.MouseButton1Click:Connect(function()
	AutoCollect = not AutoCollect
	AutoCollectBtn.Text = "Auto Collect: " .. (AutoCollect and "ON" or "OFF")
end)

-- LOOP
spawn(function()
	while task.wait(0.2) do
		if AutoCollect then
			pcall(function()
				for _,plot in pairs(workspace.Plots:GetChildren()) do
					for _,display in pairs(plot.Map.Display:GetChildren()) do
						if display:IsA("Model") and (display.Name == "Left" or display.Name == "Right") then
							for _,card in pairs(display:GetChildren()) do
								CardRemote:FireServer("Collect", card)
							end
						end
					end
				end
			end)
		end
	end
end)