--=====================================================
-- VB HUB | AUTO CAIXAS | JUJUTSU ZERO | DELTA EXECUTOR
--=====================================================

--======================
-- CONFIG
--======================
getgenv().AutoCaixa = false
getgenv().Delay = 0.4

local Players = game:GetService("Players")
local player = Players.LocalPlayer

--======================
-- HRP SEGURO
--======================
local function getHRP()
	local char = player.Character or player.CharacterAdded:Wait()
	return char:WaitForChild("HumanoidRootPart")
end

--======================
-- DETECTAR CAIXAS (JUJUTSU ZERO REAL)
--======================
local function detectarCaixas()
	local caixas = {}
	local hrp = getHRP()

	for _, obj in ipairs(workspace:GetDescendants()) do
		if obj:IsA("ProximityPrompt") then
			local texto = string.lower(obj.ActionText or "")
			if texto:find("caixa") then
				local model = obj.Parent
				if model and model:IsA("Model") then
					local part = model.PrimaryPart
						or model:FindFirstChildWhichIsA("BasePart")

					if part then
						local dist = (hrp.Position - part.Position).Magnitude
						if dist <= 35 then
							table.insert(caixas, {
								part = part,
								prompt = obj
							})
						end
					end
				end
			end
		end
	end

	return caixas
end

--======================
-- PEGAR CAIXA
--======================
local function pegarCaixa(data, hrp)
	if not data or not data.part or not data.prompt then return end

	local part = data.part
	local prompt = data.prompt

	-- Teleportar corretamente
	hrp.CFrame = part.CFrame + Vector3.new(0, 2.5, 0)
	task.wait(0.2)

	-- Garantir distância válida
	if (hrp.Position - part.Position).Magnitude > prompt.MaxActivationDistance then
		return
	end

	-- Forçar ProximityPrompt
	pcall(function()
		prompt.HoldDuration = 0
		fireproximityprompt(prompt)
	end)
end

--======================
-- LOOP PRINCIPAL
--======================
task.spawn(function()
	while task.wait(1) do
		if getgenv().AutoCaixa then
			local hrp = getHRP()
			local caixas = detectarCaixas()

			for _, caixa in ipairs(caixas) do
				if not getgenv().AutoCaixa then break end
				pegarCaixa(caixa, hrp)
				task.wait(getgenv().Delay)
			end
		end
	end
end)

--======================
-- GUI
--======================
local gui = Instance.new("ScreenGui")
gui.Name = "VB_HUB"
gui.ResetOnSpawn = false
gui.Parent = game.CoreGui

local frame = Instance.new("Frame", gui)
frame.Size = UDim2.new(0, 240, 0, 150)
frame.Position = UDim2.new(0.05, 0, 0.35, 0)
frame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
frame.Active = true
frame.Draggable = true

Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 12)

local title = Instance.new("TextLabel", frame)
title.Size = UDim2.new(1, 0, 0, 40)
title.BackgroundTransparency = 1
title.Text = "VB HUB | JUJUTSU ZERO"
title.Font = Enum.Font.GothamBold
title.TextSize = 15
title.TextColor3 = Color3.fromRGB(255, 60, 60)

local toggle = Instance.new("TextButton", frame)
toggle.Size = UDim2.new(0.85, 0, 0, 45)
toggle.Position = UDim2.new(0.075, 0, 0.5, 0)
toggle.Text = "LIGAR AUTO CAIXAS"
toggle.Font = Enum.Font.GothamBold
toggle.TextSize = 14
toggle.TextColor3 = Color3.new(1,1,1)
toggle.BackgroundColor3 = Color3.fromRGB(0, 170, 0)

Instance.new("UICorner", toggle).CornerRadius = UDim.new(0, 8)

toggle.MouseButton1Click:Connect(function()
	getgenv().AutoCaixa = not getgenv().AutoCaixa

	if getgenv().AutoCaixa then
		toggle.Text = "DESLIGAR AUTO CAIXAS"
		toggle.BackgroundColor3 = Color3.fromRGB(170, 0, 0)
	else
		toggle.Text = "LIGAR AUTO CAIXAS"
		toggle.BackgroundColor3 = Color3.fromRGB(0, 170, 0)
	end
end)
