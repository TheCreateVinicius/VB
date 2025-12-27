-- VB HUB | JUJUTSU ZERO | AUTO OPEN (ULTRA SAFE FINAL)

-- ======================
-- CONFIG
-- ======================
local BASE_DELAY = 0.9
local FAIL_DELAY = 1.4
local MAX_FAILS = 10          -- IDs seguidos sem recompensa até concluir mapa
local RETRY_PER_ID = 3        -- tentativas por ID
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
    Maps = {}
}

local CurrentMap = nil
local CurrentJobId = game.JobId

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
frame.Size = UDim2.new(0, 310, 0, 260)
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
status.Size = UDim2.new(1, -20, 0, 150)
status.Position = UDim2.new(0, 10, 0, 40)
status.Font = Enum.Font.Gotham
status.TextSize = 12
status.TextColor3 = Color3.new(1,1,1)
status.BackgroundTransparency = 1
status.TextWrapped = true
status.TextYAlignment = Enum.TextYAlignment.Top
status.Text = "Aguardando..."

local toggle = Instance.new("TextButton", frame)
toggle.Size = UDim2.new(0.9, 0, 0, 35)
toggle.Position = UDim2.new(0.05, 0, 0.72, 0)
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

local exit = Instance.new("TextButton", frame)
exit.Size = UDim2.new(0.9, 0, 0, 30)
exit.Position = UDim2.new(0.05, 0, 0.88, 0)
exit.Text = "SAIR DO SCRIPT"
exit.Font = Enum.Font.GothamBold
exit.TextSize = 13
exit.TextColor3 = Color3.new(1,1,1)
exit.BackgroundColor3 = Color3.fromRGB(90,90,90)
Instance.new("UICorner", exit)

exit.MouseButton1Click:Connect(function()
    getgenv().AutoFarm = false
    gui:Destroy()
end)

-- ======================
-- AUTO FARM INTELIGENTE FINAL
-- ======================
task.spawn(function()
    while task.wait(0.35) do
        if not getgenv().AutoFarm then continue end

        -- AUTO RESET AO TROCAR DE SERVER
        if game.JobId ~= CurrentJobId then
            CurrentJobId = game.JobId
            CurrentMap = nil
            status.Text = "🔄 Novo servidor detectado\nResetando dados locais..."
            task.wait(2)
        end

        local mapId = detectarMapa()

        if mapId ~= CurrentMap then
            CurrentMap = mapId
            Data.Maps[mapId] = Data.Maps[mapId] or {
                Loot = {},
                ValidIDs = {} -- contador por ID
            }
            salvar()
        end

        local mapData = Data.Maps[mapId]
        local index = 0
        local fails = 0
        local totalTestados = 0
        local idsValidos = 0

        while getgenv().AutoFarm and fails < MAX_FAILS do
            local id = mapId .. "_" .. index
            local success = false
            local ganhosNesteID = 0

            for attempt = 1, RETRY_PER_ID do
                if not getgenv().AutoFarm then break end

                local ok, ret = pcall(function()
                    return Remote:InvokeServer(id)
                end)

                if ok and ret then
                    success = true
                    ganhosNesteID += 1

                    mapData.Loot[#mapData.Loot + 1] = {
                        caixa = id,
                        recompensa = ret,
                        tempo = os.time()
                    }

                    task.wait(BASE_DELAY)
                else
                    task.wait(FAIL_DELAY)
                end
            end

            totalTestados += 1

            if success then
                fails = 0
                mapData.ValidIDs[id] = (mapData.ValidIDs[id] or 0) + ganhosNesteID
                idsValidos = idsValidos + 1
                salvar()
            else
                fails += 1
            end

            status.Text =
                "Mapa: "..mapId..
                "\nID atual: "..id..
                "\nIDs testados: "..totalTestados..
                "\nIDs válidos: "..idsValidos..
                "\nTotal de caixas: "..#mapData.Loot..
                "\nFalhas seguidas: "..fails

            index += 1
        end

        status.Text ..= "\n\n✔ TODAS AS CAIXAS COM RECOMPENSA FORAM COLETADAS"
        getgenv().AutoFarm = false
        toggle.Text = "LIGAR AUTO FARM"
        toggle.BackgroundColor3 = Color3.fromRGB(0,170,0)
    end
end)
