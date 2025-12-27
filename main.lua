-- VB HUB | JUJUTSU ZERO | AUTO CAIXAS (FINAL COMPLETO)

-- ======================
-- CONFIG GLOBAL
-- ======================
getgenv().AutoFarm = false
getgenv().Delay = 0.5
getgenv().CaixasDetectadas = {}

-- ======================
-- SERVICES
-- ======================
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local CoreGui = game:GetService("CoreGui")

-- ======================
-- REMOTE
-- ======================
local OpenCrateRemote =
    ReplicatedStorage:WaitForChild("NetworkComm")
        :WaitForChild("MapService")
        :WaitForChild("OpenExplorationCrate_Method")

-- ======================
-- SALVAMENTO EM ARQUIVO
-- ======================
local FILE_NAME = "VB_JujutsuZero_Caixas.txt"

local function suporteArquivo()
    return writefile and readfile and isfile
end

local function salvarCaixas()
    if not suporteArquivo() then return end
    writefile(FILE_NAME, table.concat(getgenv().CaixasDetectadas, "\n"))
end

local function carregarCaixas()
    if not suporteArquivo() then return end
    if not isfile(FILE_NAME) then return end

    local data = readfile(FILE_NAME)
    for linha in string.gmatch(data, "[^\r\n]+") do
        if not table.find(getgenv().CaixasDetectadas, linha) then
            table.insert(getgenv().CaixasDetectadas, linha)
        end
    end
end

carregarCaixas()

-- ======================
-- UTIL
-- ======================
local function jaExiste(nome)
    return table.find(getgenv().CaixasDetectadas, nome) ~= nil
end

local function abrirCaixa(nome)
    pcall(function()
        OpenCrateRemote:InvokeServer(nome)
    end)
end

-- ======================
-- AUTO-DETECÇÃO REAL (HOOK REMOTE)
-- ======================
local oldInvoke
oldInvoke = hookfunction(OpenCrateRemote.InvokeServer, function(self, ...)
    local args = {...}
    local nome = tostring(args[1])

    if nome and nome:find("Crate") then
        if not jaExiste(nome) then
            table.insert(getgenv().CaixasDetectadas, nome)
            salvarCaixas()
            print("[VB HUB] Caixa detectada:", nome)
        end
    end

    return oldInvoke(self, ...)
end)

-- ======================
-- AUTO FARM
-- ======================
task.spawn(function()
    while task.wait(1) do
        if getgenv().AutoFarm then
            for _, caixa in ipairs(getgenv().CaixasDetectadas) do
                if not getgenv().AutoFarm then break end
                abrirCaixa(caixa)
                task.wait(getgenv().Delay)
            end
        end
    end
end)

-- ======================
-- GUI
-- ======================
local gui = Instance.new("ScreenGui", CoreGui)
gui.Name = "VB_HUB"
gui.ResetOnSpawn = false

local frame = Instance.new("Frame", gui)
frame.Size = UDim2.new(0,280,0,250)
frame.Position = UDim2.new(0.05,0,0.35,0)
frame.BackgroundColor3 = Color3.fromRGB(18,18,18)
frame.Active = true
frame.Draggable = true
Instance.new("UICorner", frame).CornerRadius = UDim.new(0,10)

local title = Instance.new("TextLabel", frame)
title.Size = UDim2.new(1,0,0,40)
title.Text = "VB HUB | JUJUTSU ZERO"
title.Font = Enum.Font.GothamBold
title.TextSize = 16
title.TextColor3 = Color3.fromRGB(255,0,0)
title.BackgroundTransparency = 1

-- STATUS
local status = Instance.new("TextLabel", frame)
status.Size = UDim2.new(0.9,0,0,30)
status.Position = UDim2.new(0.05,0,0.22,0)
status.Font = Enum.Font.Gotham
status.TextSize = 12
status.TextColor3 = Color3.new(1,1,1)
status.BackgroundTransparency = 1

task.spawn(function()
    while task.wait(1) do
        status.Text = "Caixas detectadas: " .. #getgenv().CaixasDetectadas
    end
end)

-- TOGGLE AUTO FARM
local toggle = Instance.new("TextButton", frame)
toggle.Size = UDim2.new(0.85,0,0,45)
toggle.Position = UDim2.new(0.075,0,0.4,0)
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

-- BOTÃO TESTE
local test = Instance.new("TextButton", frame)
test.Size = UDim2.new(0.85,0,0,40)
test.Position = UDim2.new(0.075,0,0.65,0)
test.Text = "ABRIR PRIMEIRA CAIXA"
test.Font = Enum.Font.GothamBold
test.TextSize = 14
test.TextColor3 = Color3.new(1,1,1)
test.BackgroundColor3 = Color3.fromRGB(0,100,255)
Instance.new("UICorner", test).CornerRadius = UDim.new(0,8)

test.MouseButton1Click:Connect(function()
    if #getgenv().CaixasDetectadas > 0 then
        abrirCaixa(getgenv().CaixasDetectadas[1])
    end
end)

-- BOTÃO LIMPAR CAIXAS
local clear = Instance.new("TextButton", frame)
clear.Size = UDim2.new(0.85,0,0,35)
clear.Position = UDim2.new(0.075,0,0.83,0)
clear.Text = "LIMPAR CAIXAS SALVAS"
clear.Font = Enum.Font.GothamBold
clear.TextSize = 12
clear.TextColor3 = Color3.new(1,1,1)
clear.BackgroundColor3 = Color3.fromRGB(120,120,120)
Instance.new("UICorner", clear).CornerRadius = UDim.new(0,8)

clear.MouseButton1Click:Connect(function()
    table.clear(getgenv().CaixasDetectadas)
    if suporteArquivo() and isfile(FILE_NAME) then
        writefile(FILE_NAME, "")
    end
end)
