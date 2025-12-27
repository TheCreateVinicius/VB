-- JUJUTSU ZERO | AUTO OPEN ALL CRATES + GUI + CLOSE BUTTON

-- ======================
-- CONFIG
-- ======================
local DELAY = 0.4

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
-- DETECTAR MAPA ATUAL
-- ======================
local function getMapId()
    for _, v in pairs(player:GetAttributes()) do
        if tostring(v):match("^%d+$") then
            return tostring(v)
        end
    end
    return "4" -- fallback seguro
end

local MAP_ID = getMapId()

-- ======================
-- GERAR CAIXAS
-- ======================
local function gerarCaixas()
    local caixas = {}
    local grupos = {"G1", "G2", "G3"}
    local niveis = {1,2,3,4,5}

    for _, grupo in ipairs(grupos) do
        for _, nivel in ipairs(niveis) do
            table.insert(caixas, MAP_ID.."_"..grupo.." Crate "..nivel)
        end
    end

    return caixas
end

local Caixas = gerarCaixas()
local executando = true

-- ======================
-- GUI
-- ======================
local gui = Instance.new("ScreenGui")
gui.Name = "VB_AUTO_CRATES"
gui.Parent = game.CoreGui

local frame = Instance.new("Frame", gui)
frame.Size = UDim2.new(0, 260, 0, 120)
frame.Position = UDim2.new(0.05, 0, 0.35, 0)
frame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
frame.Active = true
frame.Draggable = true

Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 10)

local title = Instance.new("TextLabel", frame)
title.Size = UDim2.new(1, -40, 0, 40)
title.Position = UDim2.new(0, 10, 0, 0)
title.Text = "VB HUB | AUTO CAIXAS"
title.Font = Enum.Font.GothamBold
title.TextSize = 14
title.TextColor3 = Color3.fromRGB(255, 0, 0)
title.BackgroundTransparency = 1
title.TextXAlignment = Enum.TextXAlignment.Left

-- BOTÃO FECHAR
local close = Instance.new("TextButton", frame)
close.Size = UDim2.new(0, 30, 0, 30)
close.Position = UDim2.new(1, -35, 0, 5)
close.Text = "X"
close.Font = Enum.Font.GothamBold
close.TextSize = 18
close.TextColor3 = Color3.new(1, 1, 1)
close.BackgroundColor3 = Color3.fromRGB(170, 0, 0)
Instance.new("UICorner", close).CornerRadius = UDim.new(0, 6)

close.MouseButton1Click:Connect(function()
    gui:Destroy()
end)

local status = Instance.new("TextLabel", frame)
status.Size = UDim2.new(1, -20, 0, 40)
status.Position = UDim2.new(0, 10, 0, 60)
status.Text = "Abrindo caixas do mapa "..MAP_ID
status.Font = Enum.Font.Gotham
status.TextSize = 12
status.TextColor3 = Color3.new(1, 1, 1)
status.BackgroundTransparency = 1
status.TextWrapped = true

-- ======================
-- LOOP PRINCIPAL
-- ======================
task.spawn(function()
    for i, caixa in ipairs(Caixas) do
        if not executando then break end

        status.Text = "Abrindo ("..i.."/"..#Caixas.."):\n"..caixa
        pcall(function()
            OpenCrateRemote:InvokeServer(caixa)
        end)

        task.wait(DELAY)
    end

    status.Text = "Todas as caixas foram tentadas."
end)
