-- VB HUB | JUJUTSU ZERO | AUTO CAIXAS (REMOTE)
-- DELTA EXECUTOR

-- ======================
-- CONFIG
-- ======================
getgenv().AutoCaixa = false
getgenv().Delay = 0.4

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local player = Players.LocalPlayer

local Remote = ReplicatedStorage
    :WaitForChild("NetworkComm")
    :WaitForChild("MapService")
    :WaitForChild("OpenExplorationCrate_Method")

-- ======================
-- DETECTAR CAIXAS (JUJUTSU ZERO)
-- ======================
local function detectarCaixas()
    local caixas = {}

    for _, obj in ipairs(workspace:GetDescendants()) do
        if obj:IsA("Model") then
            if obj.Name:lower():find("crate") then
                table.insert(caixas, obj.Name)
            end
        end
    end

    return caixas
end

-- ======================
-- ABRIR CAIXA (REMOTE)
-- ======================
local function abrirCaixa(nome)
    pcall(function()
        Remote:InvokeServer(nome)
    end)
end

-- ======================
-- LOOP PRINCIPAL
-- ======================
task.spawn(function()
    while task.wait(1) do
        if getgenv().AutoCaixa then
            local caixas = detectarCaixas()

            for _, nome in ipairs(caixas) do
                if not getgenv().AutoCaixa then break end
                abrirCaixa(nome)
                task.wait(getgenv().Delay)
            end
        end
    end
end)

-- ======================
-- GUI (HUB)
-- ======================
local gui = Instance.new("ScreenGui", game.CoreGui)
gui.Name = "VB_HUB"
gui.ResetOnSpawn = false

local frame = Instance.new("Frame", gui)
frame.Size = UDim2.new(0, 240, 0, 140)
frame.Position = UDim2.new(0.05, 0, 0.35, 0)
frame.BackgroundColor3 = Color3.fromRGB(20,20,20)
frame.Active = true
frame.Draggable = true

Instance.new("UICorner", frame).CornerRadius = UDim.new(0,12)

local title = Instance.new("TextLabel", frame)
title.Size = UDim2.new(1,0,0,35)
title.BackgroundTransparency = 1
title.Text = "VB HUB | JUJUTSU ZERO"
title.Font = Enum.Font.GothamBold
title.TextSize = 15
title.TextColor3 = Color3.fromRGB(255,0,0)

local toggle = Instance.new("TextButton", frame)
toggle.Size = UDim2.new(0.85,0,0,45)
toggle.Position = UDim2.new(0.075,0,0.45,0)
toggle.Text = "LIGAR AUTO CAIXAS"
toggle.Font = Enum.Font.GothamBold
toggle.TextSize = 14
toggle.TextColor3 = Color3.new(1,1,1)
toggle.BackgroundColor3 = Color3.fromRGB(0,170,0)

Instance.new("UICorner", toggle).CornerRadius = UDim.new(0,10)

toggle.MouseButton1Click:Connect(function()
    getgenv().AutoCaixa = not getgenv().AutoCaixa

    if getgenv().AutoCaixa then
        toggle.Text = "DESLIGAR AUTO CAIXAS"
        toggle.BackgroundColor3 = Color3.fromRGB(170,0,0)
    else
        toggle.Text = "LIGAR AUTO CAIXAS"
        toggle.BackgroundColor3 = Color3.fromRGB(0,170,0)
    end
end)

