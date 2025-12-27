-- VB HUB | JUJUTSU ZERO | AUTO OPEN CRATES (REMOTE FIXED)

-- ======================
-- CONFIG
-- ======================
local DELAY = 0.5
local MAX_CAIXAS = 10 -- quantidade máxima de caixas por mapa

-- ======================
-- SERVICES
-- ======================
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local player = Players.LocalPlayer

-- ======================
-- REMOTE
-- ======================
local OpenCrateRemote =
    ReplicatedStorage:WaitForChild("NetworkComm")
        :WaitForChild("MapService")
        :WaitForChild("OpenExplorationCrate_Method")

-- ======================
-- DETECTAR MAPA
-- ======================
local function detectarMapa()
    for _, v in pairs(player:GetAttributes()) do
        if typeof(v) == "number" then
            return tostring(v)
        end
    end
    return "2" -- fallback seguro
end

local MAP_ID = detectarMapa()

-- ======================
-- GERAR CAIXAS (FORMATO REAL)
-- ======================
local function gerarCaixas()
    local lista = {}
    for i = 1, MAX_CAIXAS do
        table.insert(lista, MAP_ID .. "_" .. i)
    end
    return lista
end

local Caixas = gerarCaixas()
local rodando = true

-- ======================
-- GUI
-- ======================
local gui = Instance.new("ScreenGui", game.CoreGui)
gui.Name = "VB_JZ_AUTOCRATE"

local frame = Instance.new("Frame", gui)
frame.Size = UDim2.new(0, 260, 0, 130)
frame.Position = UDim2.new(0.05, 0, 0.35, 0)
frame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
frame.Active = true
frame.Draggable = true
Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 10)

local title = Instance.new("TextLabel", frame)
title.Size = UDim2.new(1, -40, 0, 40)
title.Position = UDim2.new(0, 10, 0, 0)
title.Text = "VB HUB | AUTO CAIXAS"
title.TextColor3 = Color3.fromRGB(255, 0, 0)
title.Font = Enum.Font.GothamBold
title.TextSize = 14
title.BackgroundTransparency = 1
title.TextXAlignment = Enum.TextXAlignment.Left

-- BOTÃO FECHAR
local close = Instance.new("TextButton", frame)
close.Size = UDim2.new(0, 30, 0, 30)
close.Position = UDim2.new(1, -35, 0, 5)
close.Text = "X"
close.Font = Enum.Font.GothamBold
close.TextSize = 18
close.TextColor3 = Color3.new(1,1,1)
close.BackgroundColor3 = Color3.fromRGB(170,0,0)
Instance.new("UICorner", close).CornerRadius = UDim.new(0,6)

close.MouseButton1Click:Connect(function()
    gui:Destroy()
end)

local status = Instance.new("TextLabel", frame)
status.Size = UDim2.new(1, -20, 0, 60)
status.Position = UDim2.new(0, 10, 0, 50)
status.Text = "Mapa: "..MAP_ID.."\nIniciando..."
status.Font = Enum.Font.Gotham
status.TextSize = 12
status.TextColor3 = Color3.new(1,1,1)
status.BackgroundTransparency = 1
status.TextWrapped = true

-- ======================
-- LOOP PRINCIPAL
-- ======================
task.spawn(function()
    for i, caixa in ipairs(Caixas) do
        if not rodando then break end

        status.Text = "Abrindo caixa:\n"..caixa
        pcall(function()
            OpenCrateRemote:InvokeServer(caixa)
        end)

        task.wait(DELAY)
    end

    status.Text = "Todas as caixas testadas."
end)
