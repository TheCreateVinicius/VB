-- VB HUB | JUJUTSU ZERO | AUTO OPEN (ULTRA SAFE)

-- ======================
-- CONFIG
-- ======================
local BASE_DELAY = 0.9
local FAIL_DELAY = 2
local MAX_FAILS = 8 -- quantas falhas seguidas até parar
local SAVE_FILE = "vb_auto_maps_data.json"

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

local Data = {
    Maps = {}, -- dados por mapa
    Historico = {} -- histórico geral
}

local CurrentMap = nil

-- ======================
-- SAVE / LOAD
-- ======================
local function salvar()
    if writefile then
        writefile(SAVE_FILE, HttpService:JSONEncode(Data))
    end
end

local function carregar()
    if readfile and isfile and isfile(SAVE_FILE) then
        Data = HttpService:JSONDecode(readfile(SAVE_FILE))
    end
end

carregar()

-- ======================
-- MAP DETECTION
-- ======================
local function detectarMapa()
    local ok, map = pcall(function()
        return ReplicatedStorage:WaitForChild("MapId").Value
    end)
    return ok and tostring(map) or "0"
end

-- ======================
-- GUI
-- ======================
local gui = Instance.new("ScreenGui", CoreGui)
gui.Name = "VB_AUTO_ULTRA"

local frame = Instance.new("Frame", gui)
frame.Size = UDim2.new(0, 300, 0, 210)
frame.Position = UDim2.new(0.05, 0, 0.35, 0)
frame.BackgroundColor3 = Color3.fromRGB(20,20,20)
frame.Active = true
frame.Draggable = true
Instance.new("UICorner", frame)

local title = Instance.new("TextLabel", frame)
title.Size = UDim2.new(1, -20, 0, 30)
title.Position = UDim2.new(0, 10, 0, 5)
title.Text = "VB HUB | AUTO MAP SAFE"
title.Font = Enum.Font.GothamBold
title.TextSize = 14
title.TextColor3 = Color3.fromRGB(255,0,0)
title.BackgroundTransparency = 1
title.TextXAlignment = Enum.TextXAlignment.Left

local status = Instance.new("TextLabel", frame)
status.Size = UDim2.new(1, -20, 0, 120)
status.Position = UDim2.new(0, 10, 0, 40)
status.Font = Enum.Font.Gotham
status.TextSize = 12
status.TextColor3 = Color3.new(1,1,1)
status.BackgroundTransparency = 1
status.TextWrapped = true
status.TextYAlignment = Enum.TextYAlignment.Top

local toggle = Instance.new("TextButton", frame)
toggle.Size = UDim2.new(0.9, 0, 0, 35)
toggle.Position = UDim2.new(0.05, 0, 0.78, 0)
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
-- AUTO FARM INTELIGENTE
-- ======================
task.spawn(function()
    while task.wait(1) do
        if not getgenv().AutoFarm then continue end

        local mapId = detectarMapa()

        -- mudou de mapa
        if mapId ~= CurrentMap then
            CurrentMap = mapId
            Data.Maps[mapId] = Data.Maps[mapId] or {
                Abertas = {},
                Loot = {}
            }
            salvar()
        end

        local mapData = Data.Maps[mapId]
        local index = 0
        local fails = 0

        while getgenv().AutoFarm and fails < MAX_FAILS do
            local id = mapId .. "_" .. index

            if not mapData.Abertas[id] then
                local ok, ret = pcall(function()
                    return Remote:InvokeServer(id)
                end)

                if ok and ret then
                    mapData.Abertas[id] = true
                    mapData.Loot[#mapData.Loot + 1] = {
                        caixa = id,
                        recompensa = ret,
                        tempo = os.time()
                    }
                    Data.Historico[#Data.Historico + 1] = id
                    salvar()
                    fails = 0
                    task.wait(BASE_DELAY)
                else
                    fails += 1
                    task.wait(FAIL_DELAY)
                end
            end

            status.Text =
                "Mapa atual: "..mapId..
                "\nCaixas abertas: "..#mapData.Loot..
                "\nTestando ID: "..id..
                "\nFalhas seguidas: "..fails

            index += 1
        end

        -- acabou tudo nesse mapa
        getgenv().AutoFarm = false
        status.Text ..= "\n\n✔ TODAS AS CAIXAS DESTE MAPA FORAM COLETADAS"
    end
end)

