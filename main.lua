-- ======================
-- VB HUB | JUJUTSU ZERO | AUTO OPEN FINAL (VERSÃO ROBUSTA)
-- ======================

-- ======================
-- CONFIG
-- ======================
local START_MAP = 2
local END_MAP = 4
local DELAY = 2
local SAVE_FILE = "vb_caixas_validas.json"

-- ======================
-- SERVICES
-- ======================
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local HttpService = game:GetService("HttpService")
local CoreGui = game:GetService("CoreGui")

-- ======================
-- REMOTE
-- ======================
local Remote = ReplicatedStorage:WaitForChild("NetworkComm")
    :WaitForChild("MapService")
    :WaitForChild("OpenExplorationCrate_Method")

-- ======================
-- VARIÁVEIS
-- ======================
getgenv().AutoFarm = false
local CaixasValidas = {}
local Abertas = 0
local ServerId = game.JobId

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
if CaixasValidas.__server ~= ServerId then
    CaixasValidas = { __server = ServerId }
    salvar()
end

local function contarValidas()
    local c = 0
    for k in pairs(CaixasValidas) do
        if k ~= "__server" then
            c += 1
        end
    end
    return c
end

-- ======================
-- GUI
-- ======================
local parentGui = gethui and gethui() or CoreGui
local gui = Instance.new("ScreenGui", parentGui)
gui.Name = "VB_AUTO_FINAL"
gui.ResetOnSpawn = false

local frame = Instance.new("Frame", gui)
frame.Size = UDim2.new(0, 300, 0, 320)
frame.Position = UDim2.new(0.05, 0, 0.3, 0)
frame.BackgroundColor3 = Color3.fromRGB(20,20,20)
frame.Active = true
frame.Draggable = true
Instance.new("UICorner", frame)

local title = Instance.new("TextLabel", frame)
title.Size = UDim2.new(1, -40, 0, 35)
title.Position = UDim2.new(0, 10, 0, 0)
title.Text = "VB HUB"
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
status.Size = UDim2.new(1, -20, 0, 50)
status.Position = UDim2.new(0, 10, 0, 40)
status.Font = Enum.Font.Gotham
status.TextSize = 12
status.TextColor3 = Color3.new(1,1,1)
status.BackgroundTransparency = 1
status.TextWrapped = true

local toggle = Instance.new("TextButton", frame)
toggle.Size = UDim2.new(0.85, 0, 0, 40)
toggle.Position = UDim2.new(0.075, 0, 0, 95)
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

local list = Instance.new("ScrollingFrame", frame)
list.Size = UDim2.new(1, -20, 0, 130)
list.Position = UDim2.new(0, 10, 0, 150)
list.BackgroundColor3 = Color3.fromRGB(15,15,15)
list.ScrollBarImageTransparency = 0.2
Instance.new("UICorner", list)

local layout = Instance.new("UIListLayout", list)
layout.Padding = UDim.new(0,4)

local function adicionarLista(id)
    local label = Instance.new("TextLabel", list)
    label.Size = UDim2.new(1, -5, 0, 18)
    label.Text = id
    label.Font = Enum.Font.Gotham
    label.TextSize = 11
    label.TextColor3 = Color3.fromRGB(200,200,200)
    label.BackgroundTransparency = 1
    label.TextXAlignment = Enum.TextXAlignment.Left
    task.wait()
    list.CanvasSize = UDim2.new(0,0,0,layout.AbsoluteContentSize.Y + 5)
end

-- ======================
-- FUNÇÃO RETRY AUTOMÁTICO
-- ======================
local function tryOpen(id, retries)
    retries = retries or 3
    for i = 1, retries do
        local ok, ret = pcall(function()
            return Remote:InvokeServer(id)
        end)
        if ok and ret ~= nil then
            return true
        end
        task.wait(0.5)
    end
    return false
end

-- ======================
-- AUTO FARM ROBUSTO
-- ======================
task.spawn(function()
    local semCaixa = 0
    local index = 0

    while getgenv().AutoFarm do
        local encontrou = false

        for map = START_MAP, END_MAP do
            local id = map.."_"..index
            if not CaixasValidas[id] then
                status.Text = "Testando: "..id..
                    "\nVálidas: "..contarValidas()..
                    " | Abertas: "..Abertas
                if tryOpen(id) then
                    CaixasValidas[id] = true
                    salvar()
                    adicionarLista(id)
                    Abertas += 1
                    encontrou = true
                end
            end
        end

        index += 1

        if not encontrou then
            semCaixa += 1
            if semCaixa >= 2 then
                getgenv().AutoFarm = false
                status.Text = "Nenhuma caixa restante neste servidor."
                break
            end
        else
            semCaixa = 0
        end

        task.wait(DELAY)
    end
end)
