-- VB HUB | JUJUTSU ZERO | AUTO OPEN (ULTRA SAFE FINAL FIXED)

-- ======================
-- CONFIG
-- ======================
local BASE_DELAY = 0.9
local FAIL_DELAY = 1.3
local MAX_FAILS = 10
local RETRY_PER_ID = 3
local SAVE_FILE = "vb_auto_maps_data.json"

-- ======================
-- SERVICES
-- ======================
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local HttpService = game:GetService("HttpService")
local CoreGui = game:GetService("CoreGui")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

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

local CurrentMap = tostring(game.PlaceId)
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
-- MAP DETECTION (FIXED)
-- ======================
local function detectarMapa()
    return tostring(game.PlaceId)
end

-- ======================
-- GUI
-- ======================
local gui = Instance.new("ScreenGui")
gui.Name = "VB_AUTO_ULTRA"
gui.Parent = CoreGui

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
status.Text = "Pronto para iniciar."

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
-- AUTO FARM FINAL FUNCIONAL
-- ======================
task.spawn(function()
    while task.wait(0.35) do
        if not getgenv().AutoFarm then continue end

        -- AUTO RESET SERVER
        if game.JobId ~= CurrentJobId then
            CurrentJobId = game.JobId
            CurrentMap = detectarMapa()
            status.Text = "🔄 Novo servidor detectado\nResetando varredura..."
            task.wait(1.5)
        end

        local mapId = detectarMapa()

        Data.Maps[mapId] = Data.Maps[mapId] or {
            Loot = {},
            ValidIDs = {}
        }

        local mapData = Data.Maps[mapId]
        local index = 0
        local fails = 0
        local totalTestados = 0

        while getgenv().AutoFarm and fails < MAX_FAILS do
            local id = mapId .. "_" .. index
            local success = false
            local ganhos = 0

            for attempt = 1, RETRY_PER_ID do
                if not getgenv().AutoFarm then break end

                local ok, ret = pcall(function()
                    return Remote:InvokeServer(id)
                end)

                if ok and ret then
                    success = true
                    ganhos += 1

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
                mapData.ValidIDs[id] = (mapData.ValidIDs[id] or 0) + ganhos
                salvar()
            else
                fails += 1
            end

            status.Text =
                "Mapa: "..mapId..
                "\nID atual: "..id..
                "\nIDs testados: "..totalTestados..
                "\nIDs válidos: "..table.getn(mapData.ValidIDs)..
                "\nCaixas coletadas: "..#mapData.Loot..
                "\nFalhas seguidas: "..fails

            index += 1
        end

        status.Text ..= "\n\n✔ TODAS AS CAIXAS COM RECOMPENSA FORAM COLETADAS"
        getgenv().AutoFarm = false
        toggle.Text = "LIGAR AUTO FARM"
        toggle.BackgroundColor3 = Color3.fromRGB(0,170,0)
    end
end)
