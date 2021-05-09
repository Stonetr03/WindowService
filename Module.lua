-- Stonetr03 Studios

local Module = {Version = 1}
local Windows = {}
local RunService = game:GetService("RunService")

local TweenService = game:GetService("TweenService")
local TweenData = TweenInfo.new(0.2,Enum.EasingStyle.Linear,Enum.EasingDirection.InOut,0,false,0)

local function ListLayout(Window)
	for i = 1,#Windows[Window].TopBtns,1 do
		Windows[Window].TopBtns[i].Position = UDim2.new(1,i * -20,0,0)
	end
	return
end

local function WinConfig(Window,Config)
	local Win = Windows[Window].Window
	local WinBG = Win.Background
	local WinConfig = Windows[Window].Config
	if typeof(Config.Position) == "UDim2" then
		Win.Position = Config.Position
		WinConfig.Position = Config.Position
	end
	if typeof(Config.Size) == "UDim2" then
		Win.Size = UDim2.new(Config.Size.X.Scale,Config.Size.X.Offset,0,20)
		WinBG.Size = UDim2.new(1,0,Config.Size.Y.Scale,Config.Size.Y.Offset)
		WinConfig.Size = Config.Size
	end
	if typeof(Config.Closeable) == "boolean" then
		WinConfig.Closeable = Config.Closeable
	end
	if typeof(Config.Minimizeable) == "boolean" then
		WinConfig.Minimizeable = Config.Minimizeable
	end
	if typeof(Config.Draggable) == "boolean" then
		WinConfig.Draggable = Config.Draggable
	end
	if typeof(Config.Title) == "string" then
		WinConfig.Title = Config.Title
		Win.Bar.Title.Text = Config.Title
	end
	if typeof(Config.Theme) == "string" then
		if string.lower(Config.Theme) == "light" then
			WinBG.BackgroundColor3 = Color3.fromRGB(255,255,255)
			Win.Bar.BackgroundColor3 = Color3.fromRGB(255,255,255)
			Win.Bar.Title.TextColor3 = Color3.fromRGB(0,0,0)
			
			for i = 1,#Windows[Window].TopBtns,1 do
				Windows[Window].TopBtns[i].TextColor3 = Color3.fromRGB(0,0,0)
				Windows[Window].TopBtns[i].BackgroundColor3 = Color3.fromRGB(239, 239, 239)
			end
			WinConfig.Theme = "light"
		elseif string.lower(Config.Theme) == "dark" then
			WinBG.BackgroundColor3 = Color3.fromRGB(0,0,0)
			Win.Bar.BackgroundColor3 = Color3.fromRGB(0,0,0)
			Win.Bar.Title.TextColor3 = Color3.fromRGB(255,255,255)

			for i = 1,#Windows[Window].TopBtns,1 do
				Windows[Window].TopBtns[i].TextColor3 = Color3.fromRGB(255,255,255)
				Windows[Window].TopBtns[i].BackgroundColor3 = Color3.fromRGB(49, 49, 49)
			end
			WinConfig.Theme = "dark"
		end
	end
	if typeof(Config.Icon) == "string" then
		WinConfig.Icon = Config.Icon
		Win.Bar.Icon.Image = Config.Icon
	end
	if Config.TitleXalignment == Enum.TextXAlignment.Center then
		Win.Bar.Title.TextXAlignment = Config.TitleXalignment
		WinConfig.TitleXalignment = Config.TitleXalignment
	elseif Config.TitleXalignment == Enum.TextXAlignment.Left then
		Win.Bar.Title.TextXAlignment = Config.TitleXalignment
		WinConfig.TitleXalignment = Config.TitleXalignment
	elseif Config.TitleXalignment == Enum.TextXAlignment.Right then
		Win.Bar.Title.TextXAlignment = Config.TitleXalignment
		WinConfig.TitleXalignment = Config.TitleXalignment
	end
end

local function CreateTopBarBtn(Name,Text,Window,Func,Pos)
	local Btn = Instance.new("TextButton",Windows[Window].Window.Bar)
	Btn.Name = Name
	Btn.AutoButtonColor = false
	Btn.BackgroundTransparency = 1
	Btn.BorderSizePixel = 0
	Btn.Position = UDim2.new(1,-20,0,0)
	Btn.Size = UDim2.new(0,20,0,20)
	Btn.Font = Enum.Font.SourceSans
	Btn.TextSize = 20
	Btn.Text = Text
	
	if Windows[Window].Config.Theme == "light" then
		Btn.TextColor3 = Color3.fromRGB(0,0,0)
		Btn.BackgroundColor3 = Color3.fromRGB(239, 239, 239)
	else
		Btn.TextColor3 = Color3.fromRGB(255,255,255)
		Btn.BackgroundColor3 = Color3.fromRGB(49, 49, 49 )
	end
	
	if Pos == nil or Pos < 1 or Pos > #Windows[Window].TopBtns then
		if #Windows[Window].TopBtns == 0 then
			table.insert(Windows[Window].TopBtns,1,Btn)
		else
			table.insert(Windows[Window].TopBtns,#Windows[Window].TopBtns + 1,Btn)
		end
	else
		table.insert(Windows[Window].TopBtns,Pos,Btn)
	end
	
	Btn.MouseButton1Up:Connect(Func)
	
	local OpeningTween = TweenService:Create(Btn,TweenData,{BackgroundTransparency = 0})
	local CloseingTween = TweenService:Create(Btn,TweenData,{BackgroundTransparency = 1})
	
	Btn.MouseEnter:Connect(function()
		CloseingTween:Cancel()
		OpeningTween:Play()
	end)
	Btn.MouseLeave:Connect(function()
		OpeningTween:Cancel()
		CloseingTween:Play()
	end)
	
	ListLayout(Window)
	local Tab = {
		Destroy = function()
			for i = 1,#Windows[Window].TopBtns,1 do
				if Windows[Window].TopBtns[i] == Btn then
					table.remove(Windows[Window].TopBtns,i)
					Btn:Destroy()
					return
				end
			end
		end,
	}
	return Tab 
end

-- require(game.ReplicatedStorage.WindowService):Create("TestGui1",UDim2.new(0,500,0,300),Instance.new("Frame"))
function Module:Create(WinName,WinUi,Config,Container)
	if RunService:IsClient() == true then
		if typeof(WinName) == "string" and typeof(WinUi) == "Instance" then
			local p = game.Players.LocalPlayer
			local Ui = p.PlayerGui:FindFirstChild("__WindowService_UI")
			if not Ui then
				Ui = Instance.new("ScreenGui",p.PlayerGui)
				Ui.Name = "__WindowService_UI"
				Ui.IgnoreGuiInset = true
				Ui.Enabled = true
				Ui.ResetOnSpawn = false
				local Con = Instance.new("Folder",Ui)
				Con.Name = "Container"
			end
			if typeof(Container) ~= "string" then
				Container = "Container"
			end
			local WinCon = Ui:FindFirstChild(Container) -- Windows Container
			if not WinCon then
				WinCon = Instance.new("Folder",Ui)
				WinCon.Name = Container
			end
			local WinCheck = WinCon:FindFirstChild(WinName)
			if WinCheck then
				warn("Window Already Created")
				return false
			else
				if Config == nil then Config = {} end
				-- Create Window
				Windows[WinName .. "-" .. Container] = {
					Name = WinName,
					Container = Container,
					TopBtns = {},
					Config = {
						Closeable = true,
						Minimizeable = true,
						Draggable = true,
						Title = WinName,
						Theme = "light",
						Icon = "rbxassetid://0",
						TitleXalignment = Enum.TextXAlignment.Left,
						Position = UDim2.new(0,0,0,0),
						Size = UDim2.new(0,0,0,0),
					},
				}
				
				local Win = Instance.new("Frame",WinCon)
				Win.Name = WinName
				Win.BackgroundTransparency = 1
				Win.Parent = WinCon
				Windows[WinName .. "-" .. Container].Window = Win
				
				local WinBG = Instance.new("Frame",Win)
				WinBG.Position = UDim2.new(0,0,0,21)
				WinBG.BorderSizePixel = 0
				WinBG.BackgroundColor3 = Color3.fromRGB(255,255,255)
				WinBG.Name = "Background"
				
				local WinBar = Instance.new("Frame",Win)
				WinBar.Name = "Bar"
				WinBar.BorderSizePixel = 0
				WinBar.BackgroundColor3 = Color3.fromRGB(255,255,255)
				WinBar.Size = UDim2.new(1,0,1,0)
				
				local Icon = Instance.new("ImageLabel",WinBar)
				Icon.Name = "Icon"
				Icon.BackgroundTransparency = 1
				Icon.Position = UDim2.new(0,2,0,2)
				Icon.Size = UDim2.new(0,16,0,16)
				Icon.ScaleType = Enum.ScaleType.Fit
				Icon.Image = "rbxassetid://6064221669"
				
				local Title = Instance.new("TextLabel",WinBar)
				Title.Name = "Title"
				Title.BackgroundTransparency = 1
				Title.Position = UDim2.new(0,25,0,0)
				Title.Size = UDim2.new(1,-25,1,0)
				Title.Font = Enum.Font.SourceSans
				Title.Text = WinName
				Title.TextColor3 = Color3.fromRGB(0,0,0)
				Title.TextSize = 14
				Title.TextXAlignment = Enum.TextXAlignment.Left
				
				local CloseBtn = CreateTopBarBtn("CloseBTN","X",WinName .. "-" .. Container,function()
					if Windows[WinName .. "-" .. Container].Config.Closeable == true then
						Win.Visible = false
					end
				end,1)
				local MinimizeBtn = CreateTopBarBtn("MinimizeBTN","-",WinName .. "-" .. Container,function()
					if Windows[WinName .. "-" .. Container].Config.Minimizeable == true then
						WinBG.Visible = not WinBG.Visible
					end
				end,2)
				
				Win.Position = UDim2.new(0,100,0,100)
				Win.Size = UDim2.new(0,350,0,20)
				WinBG.Size = UDim2.new(1,0,0,200)
				
				WinUi.Parent = WinBG
				
				WinConfig(WinName .. "-" .. Container,Config)
				
				-- Drag

				local UserInputService = game:GetService("UserInputService")
				
				local gui = Win
				
				local dragging
				local dragInput
				local dragStart
				local startPos

				local function update(input)
					if Windows[WinName .. "-" .. Container].Config.Draggable == true and Win.Visible == true then
						local delta = input.Position - dragStart
						gui.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
					end
				end
				
				gui.InputBegan:Connect(function(input)
					if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
						if Windows[WinName .. "-" .. Container].Config.Draggable == true and Win.Visible == true then
							dragging = true
							dragStart = input.Position
							startPos = gui.Position

							input.Changed:Connect(function()
								if input.UserInputState == Enum.UserInputState.End then
									dragging = false
								end
							end)
						end
					end
				end)

				gui.InputChanged:Connect(function(input)
					if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
						dragInput = input
					end
				end)

				UserInputService.InputChanged:Connect(function(input)
					if input == dragInput and dragging then
						update(input)
					end
				end)
				
				local ReturnTab = {}	
				function ReturnTab:Config(C)
					WinConfig(WinName .. "-" .. Container,C)
				end
				function ReturnTab:AddTopBarButton(N,T,F,P)
					return CreateTopBarBtn(N,T,WinName .. "-" .. Container,F,P)
				end
				function ReturnTab:Destroy()
					Windows[WinName .. "-" .. Container] = nil
					Win:Destroy()
				end
				function ReturnTab:GetVisiblity()
					return Win.Visible
				end
				function ReturnTab:Hide()
					Win.Visible = false
				end
				function ReturnTab:Show()
					Win.Visible = true
				end
				return ReturnTab
			end
		else
			return false
		end
	else
		warn("Windows Service can only be called from the client")
		return false
	end
end

function Module:RemoveContainer(Container)
	if RunService:IsClient() == true then
		local p = game.Players.LocalPlayer
		local Ui = p.PlayerGui:FindFirstChild("__WindowService_UI")
		if not Ui then
			return true
		end
		if typeof(Container) ~= "string" then
			return false
		end
		local WinCon = Ui:FindFirstChild(Container) -- Windows Container
		if not WinCon then
			return true
		else
			for _,i in pairs(WinCon:GetChildren()) do
				if i:IsA("Frame") then
					Windows[i.Name .. "-" .. Container] = nil
				end
			end
			WinCon:Destroy()
		end
	end
end

return Module
