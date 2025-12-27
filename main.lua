-- VB HUB | JUJUTSU ZERO | AUTO CAIXAS (REMOTE BASED)

-- ======================
-- CONFIG
-- ======================
getgenv().AutoFarm = false
getgenv().Delay = 0.4

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
    ReplicatedStorage.NetworkComm.MapService.OpenExplorationCrate_Method

-- ======================
-- GERAR CAIXAS AUTOMÁTICAS
-- ======================
local function gerarCaixas()
    local lista = {}

    -- padrões conhecidos do Jujutsu Zero
    local mapas = {1,2,3,4,5}
    local grupos = {"G1","G2","G3"}
    local niveis = {1,2,3,4,5}

    for _, mapa in ipairs(mapas) do
        for _, grupo in ipairs(grupos) do
            for _, nivel in ipairs(niveis) do
                table.insert(lista, mapa.."_"..grupo.." Crate "..nivel)
            end
        end
    end

    return lista
end

local TodasCaixas = gerarCaixas()

-- ======================
-- ABRIR CAIXA
-- ======================
local function abrirCaixa(nome)
    pcall(function()
        OpenCrateRemote:InvokeServer(nome)
    end)
end

-- ======================
-- AUTO FARM
-- ======================
task.spawn(function()
    while task.wait(1) do
        if getgenv().AutoFarm then
            for _, caixa in ipairs(TodasCaixas) do
                if not getgenv().AutoFarm then break end
                abrirCaixa(caixa)
                task.wait(getgenv().Delay)
            end
        end
    end
end)

-- ======================
-- HUB GUI
-- ======================
local gui = Instance.new("ScreenGui", game.CoreGui)
gui.Name = "VB_HUB"

local frame = Instance.new("Frame", gui)
frame.Size = UDim2.new(0,260,0,200)
frame.Position = UDim2.new(0.05,0,0.35,0)
frame.BackgroundColor3 = Color3.fromRGB(20,20,20)
frame.Active = true
frame.Draggable = true

Instance.new("UICorner", frame).CornerRadius = UDim.new(0,10)

local title = Instance.new("TextLabel", frame)
title.Size = UDim2.new(1,0,0,40)
title.Text = "VB HUB | JUJUTSU ZERO"
title.TextColor3 = Color3.fromRGB(255,0,0)
title.Font = Enum.Font.GothamBold
title.TextSize = 16
title.BackgroundTransparency = 1

-- BOTÃO TOGGLE
local toggle = Instance.new("TextButton", frame)
toggle.Size = UDim2.new(0.85,0,0,45)
toggle.Position = UDim2.new(0.075,0,0.35,0)
toggle.Text = "LIGAR AUTO CAIXAS"
toggle.Font = Enum.Font.GothamBold
toggle.TextSize = 14
toggle.TextColor3 = Color3.new(1,1,1)
toggle.BackgroundColor3 = Color3.fromRGB(0,170,0)
Instance.new("UICorner", toggle).CornerRadius = UDim.new(0,8)

toggle.MouseButton1Click:Connect(function()
    getgenv().AutoFarm = not getgenv().AutoFarm

    if getgenv().AutoFarm then
        toggle.Text = "DESLIGAR AUTO CAIXAS"
        toggle.BackgroundColor3 = Color3.fromRGB(170,0,0)
    else
        toggle.Text = "LIGAR AUTO CAIXAS"
        toggle.BackgroundColor3 = Color3.fromRGB(0,170,0)
    end
end)

-- BOTÃO TESTE MANUAL
local test = Instance.new("TextButton", frame)
test.Size = UDim2.new(0.85,0,0,40)
test.Position = UDim2.new(0.075,0,0.65,0)
test.Text = "ABRIR CAIXA TESTE"
test.Font = Enum.Font.GothamBold
test.TextSize = 14
test.TextColor3 = Color3.new(1,1,1)
test.BackgroundColor3 = Color3.fromRGB(0,100,255)
Instance.new("UICorner", test).CornerRadius = UDim.new(0,8)

test.MouseButton1Click:Connect(function()
    abrirCaixa("4_G1 Crate 3")
end)


