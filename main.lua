-- VB HUB | AUTO CAIXAS | DELTA EXECUTOR

-- ======================
-- CONFIG GLOBAL
-- ======================
getgenv().AutoCaixa = false
getgenv().CaixaDelay = 0.25

local Players = game:GetService("Players")
local player = Players.LocalPlayer

-- ======================
-- CHARACTER SEGURO
-- ======================
local function getHRP()
	local char = player.Character or player.CharacterAdded:Wait()
	return char:WaitForChild("HumanoidRootPart")
end

-- ======================
-- DETECTAR CAIXAS AUTOMATICAMENTE
-- ======================
local function detectarCaixas()
	local caixas = {}
	local added = {} -- Para evitar duplicatas

	for _, obj in ipairs(workspace:GetDescendants()) do
		-- Detecta por nome
		if obj:IsA("BasePart") then
			local nome = string.lower(obj.Name)

			if (nome:find("caixa") or nome:find("crate") or nome:find("box")) and not added[obj] then
				table.insert(caixas, obj)
				added[obj] = true
			end
		end

		-- Detecta ProximityPrompt
		if obj:IsA("ProximityPrompt") then
			local part = obj.Parent
			if part and part:IsA("BasePart") and not added[part] then
				table.insert(caixas, part)
				added[part] = true
			end
		end
	end

	return caixas
end

-- ======================
-- PEGAR CAIXA
-- ======================
local function pegarCaixa(caixa, hrp)
	if not caixa or not caixa:IsA("BasePart") then return end

	hrp.CFrame = caixa.CFrame + Vector3.new(0, 2, 0)
	task.wait(0.1)

	-- Touch (Delta)
	pcall(function()
		firetouchinterest(hrp, caixa, 0)
		firetouchinterest(hrp, caixa, 1)
	end)

	-- ProximityPrompt (se existir)
	local prompt = caixa:FindFirstChildOfClass("ProximityPrompt")
	if prompt then
		pcall(function()
			fireproximityprompt(prompt)
		end)
	end
end

-- ======================
-- LOOP PRINCIPAL
-- ======================
task.spawn(function()
	while true do
		if getgenv().AutoCaixa then
			local hrp = getHRP()
			local caixas = detectarCaixas()

			for _, caixa in ipairs(caixas) do
				if not getgenv().AutoCaixa then break end
				pegarCaixa(caixa, hrp)
				task.wait(getgenv().CaixaDelay)
			end
		end
		task.wait(1)
	end
end)

-- ======================
-- HUB (GUI)
-- ======================
local gui = Instance.new("ScreenGui")
gui.Name = "VBHUB"
gui.ResetOnSpawn = false
gui.Parent = game.CoreGui

local frame = Instance.new("Frame", gui)
frame.Size = UDim2.new(0, 220, 0, 140)
frame.Position = UDim2.new(0.05, 0, 0.35, 0)
frame.BackgroundColor3 = Color3.fromRGB(25,25,25)
frame.Active = true
frame.Draggable = true

local corner = Instance.new("UICorner", frame)
corner.CornerRadius = UDim.new(0, 10)

local title = Instance.new("TextLabel", frame)
title.Size = UDim2.new(1, 0, 0, 35)
title.BackgroundTransparency = 1
title.Text = "ZENITH HUB"
title.TextColor3 = Color3.fromRGB(0,170,255)
title.Font = Enum.Font.GothamBold
title.TextSize = 16

local toggle = Instance.new("TextButton", frame)
toggle.Size = UDim2.new(0.85, 0, 0, 40)
toggle.Position = UDim2.new(0.075, 0, 0.45, 0)
toggle.Text = "LIGAR AUTO CAIXAS"
toggle.Font = Enum.Font.GothamBold
toggle.TextSize = 14
toggle.TextColor3 = Color3.new(1,1,1)
toggle.BackgroundColor3 = Color3.fromRGB(0,170,0)

local corner2 = Instance.new("UICorner", toggle)
corner2.CornerRadius = UDim.new(0, 8)

toggle.MouseButton1Click:Connect(function()
	getgenv().AutoCaixa = not getgenv().AutoCaixa

	if getgenv().AutoCaixa then
		toggle.Text = "DESLIGAR AUTO CAIXAS"
		toggle.BackgroundColor3 = Color3.fromRGB(0,170,0) -- verde para ligado
	else
		toggle.Text = "LIGAR AUTO CAIXAS"
		toggle.BackgroundColor3 = Color3.fromRGB(170,0,0) -- vermelho para desligado
	end
end)
