-- VB HUB | JUJUTSU ZERO | AUTO OPEN 2_X (FIX FINAL)

-- ======================
-- CONFIG
-- ======================
local MAP_ID = 2
local DELAY = 1
local RETRY_PER_ID = 3
local MAX_SCAN_SEM_SUCESSO = 50
local SAVE_FILE = "vb_caixas_validas_2.json"

-- ======================
-- SERVICES
-- ======================
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local HttpService = game:GetService("HttpService")
local CoreGui = game:GetService("CoreGui")

-- ======================
-- REMOTE
-- ======================
local Remote =
    ReplicatedStorage
        :WaitForChild("NetworkComm")
        :WaitForChild("MapService")
        :WaitForChild("OpenExplorationCrate_Method")

-- ======================
-- VARIÁVEIS
-- ======================
getgenv().AutoFarm = false

local CaixasValidas = {}
local CaixasAbertas = {}
local IndexAtual = 0
local Abertas = 0
local CurrentJobId = game.JobId

-- ======================
-- LOAD / SAVE
-- ======================
local function salvar()
    if writefile then
        writefile(SAVE_FILE, HttpService:JSONEncode(CaixasValidas))
    end
end

local function carregar()
    if readfile and isfile and isfile(SAVE_FILE) then
        CaixasValidas = HttpService:JSONDecode(readfile(SAVE_FILE))
    end
end

carregar()

local function contarValidas()
    local c = 0
    for _ in pairs(CaixasValidas) do c += 1 end
    return c
end

-- ======================
-- FUNÇÃO CRÍTICA (RETORNO REAL)
-- ======================
local function abriuCaixa(ok, ret)
    if not ok then return false end
    if ret == nil then return false end
    return true
end

-- ======================
-- GUI (mesma estrutura)
-- ======================
local gui = Instance.new("ScreenGui", CoreGui)
gui.Name = "VB_AUTO_2X"

local frame = Instance.new("Frame", gui)
frame.Size = UDim2.new(0, 260, 0, 190)
frame.Position = UDim2.new(0.05, 0, 0.35, 0)
frame.BackgroundColor3 = Color3.fromRGB(20,20,20)
frame.Active = true
frame.Draggable = true
Instance.new("UICorner", frame)

local title = Instance.new("TextLabel", frame)
title.Size = UDim2.new(1, -40, 0, 35)
title.Position = UDim2.new(0, 10, 0, 0)
title.Text = "VB HUB | AUTO 2_X"
title.TextColor3 = Color3.fromRGB(255,0,0)
title.Font = Enum.Font.GothamBold
title.TextSize = 14
title.BackgroundTransparency = 1
title.TextXAlignment = Enum.TextXAlignment.Left

local close = Instance.new("TextButton", frame)
close.Size = UDim2.new(0, 30, 0, 30)
close.Position = UDim2.new(1, -35, 0, 5)
close.Text = "X"
close.Font = Enum.Font.GothamBold
close.TextSize = 18
close.TextColor3 = Color3.new(1,1,1)
close.BackgroundColor3 = Color3.fromRGB(170,0,0)
Instance.new("UICorner", close)

close.MouseButton1Click:Connect(function()
    getgenv().AutoFarm = false
    gui:Destroy()
end)

local status = Instance.new("TextLabel", frame)
status.Size = UDim2.new(1, -20, 0, 70)
status.Position = UDim2.new(0, 10, 0, 40)
status.TextColor3 = Color3.new(1,1,1)
status.Font = Enum.Font.Gotham
status.TextSize = 12
status.BackgroundTransparency = 1
status.TextWrapped = true

local toggle = Instance.new("TextButton", frame)
toggle.Size = UDim2.new(0.85, 0, 0, 40)
toggle.Position = UDim2.new(0.075, 0, 0.65, 0)
toggle.Text = "LIGAR AUTO FARM"
toggle.Font = Enum.Font.GothamBold
toggle.TextSize = 14
toggle.TextColor3 = Color3.new(1,1,1)
toggle.BackgroundColor3 = Color3.fromRGB(0,170,0)
Instance.new("UICorner", toggle)

toggle.MouseButton1Click:Connect(function()
    getgenv().AutoFarm = not getgenv().AutoFarm
    toggle.Text = getgenv().AutoFarm and "DESLIGAR AUTO FARM" or "LIGAR AUTO FARM"
    toggle.BackgroundColor3 = getgenv().AutoFarm and Color3.fromRGB(170,0,0) or Color3.fromRGB(0,170,0)
end)

-- ======================
-- AUTO FARM (FIX)
-- ======================
task.spawn(function()
    while task.wait(0.2) do
        if not getgenv().AutoFarm then
            task.wait(0.5)
            continue
        end

        -- reset ao trocar server
        if game.JobId ~= CurrentJobId then
            CurrentJobId = game.JobId
            CaixasAbertas = {}
            IndexAtual = 0
            Abertas = 0
        end

        local encontrouAlguma = false
        local scanInicio = IndexAtual

        while getgenv().AutoFarm and (IndexAtual - scanInicio) < MAX_SCAN_SEM_SUCESSO do
            local id = MAP_ID .. "_" .. IndexAtual

            if not CaixasAbertas[id] then
                for _ = 1, RETRY_PER_ID do
                    if not getgenv().AutoFarm then break end

                    task.wait(DELAY)
                    local ok, ret = pcall(function()
                        return Remote:InvokeServer(id)
                    end)
                    task.wait(DELAY)

                    if abriuCaixa(ok, ret) then
                        encontrouAlguma = true
                        CaixasValidas[id] = true
                        CaixasAbertas[id] = true
                        Abertas += 1
                        salvar()
                        break
                    end
                end
            end

            status.Text =
                "ID atual: "..id..
                "\nVálidas: "..contarValidas()..
                "\nAbertas: "..Abertas..
                "\nAutoFarm: ATIVO"

            IndexAtual += 1
        end

        -- só para automaticamente se REALMENTE não existir nenhuma
        if not encontrouAlguma then
            status.Text = "Nenhuma caixa neste servidor.\nAutoFarm parado."
            getgenv().AutoFarm = false
            toggle.Text = "LIGAR AUTO FARM"
            toggle.BackgroundColor3 = Color3.fromRGB(0,170,0)
        end
    end
end)
