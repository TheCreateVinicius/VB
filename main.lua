-- VB HUB | JUJUTSU ZERO | AUTO OPEN 2_X (SAFE FINAL)

-- ======================
-- CONFIG
-- ======================
local MAP_ID = 2
local MAX_CAIXAS = 30
local BASE_DELAY = 0.8
local FAIL_DELAY = 2
local SAVE_FILE = "vb_caixas_map2_safe.json"

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
    Validas = {},
    Abertas = {}
}

local TotalRecompensas = 0

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
-- CONTADORES
-- ======================
local function contar(tbl)
    local c = 0
    for _ in pairs(tbl) do c += 1 end
    return c
end

-- ======================
-- GUI
-- ======================
local gui = Instance.new("ScreenGui", CoreGui)
gui.Name = "VB_AUTO_SAFE"

local frame = Instance.new("Frame", gui)
frame.Size = UDim2.new(0, 270, 0, 190)
frame.Position = UDim2.new(0.05, 0, 0.35, 0)
frame.BackgroundColor3 = Color3.fromRGB(20,20,20)
frame.Active = true
frame.Draggable = true
Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 10)

local title = Instance.new("TextLabel", frame)
title.Size = UDim2.new(1, -40, 0, 35)
title.Position = UDim2.new(0, 10, 0, 0)
title.Text = "VB HUB | AUTO 2_X SAFE"
title.TextColor3 = Color3.fromRGB(255,0,0)
title.Font = Enum.Font.GothamBold
title.TextSize = 14
title.BackgroundTransparency = 1
title.TextXAlignment = Enum.TextXAlignment.Left

local status = Instance.new("TextLabel", frame)
status.Size = UDim2.new(1, -20, 0, 80)
status.Position = UDim2.new(0, 10, 0, 40)
status.TextColor3 = Color3.new(1,1,1)
status.Font = Enum.Font.Gotham
status.TextSize = 12
status.BackgroundTransparency = 1
status.TextWrapped = true

local toggle = Instance.new("TextButton", frame)
toggle.Size = UDim2.new(0.85, 0, 0, 40)
toggle.Position = UDim2.new(0.075, 0, 0.7, 0)
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
-- AUTO FARM SAFE
-- ======================
task.spawn(function()
    while task.wait(1) do
        if not getgenv().AutoFarm then continue end

        local algoAberto = false

        for i = 1, MAX_CAIXAS do
            if not getgenv().AutoFarm then break end

            local id = MAP_ID .. "_" .. i

            -- já aberta = ignora
            if Data.Abertas[id] then
                continue
            end

            local ok, ret = pcall(function()
                return Remote:InvokeServer(id)
            end)

            -- retorno válido = recompensa real
            if ok and ret then
                Data.Validas[id] = true
                Data.Abertas[id] = true
                TotalRecompensas += 1
                salvar()
                algoAberto = true
                task.wait(BASE_DELAY)
            else
                -- falha = espera mais (anti flag)
                task.wait(FAIL_DELAY)
            end

            status.Text =
                "Caixas válidas: "..contar(Data.Validas)..
                "\nAbertas: "..contar(Data.Abertas)..
                "\nRecompensas: "..TotalRecompensas
        end

        -- nada mais pra abrir → para
        if not algoAberto then
            getgenv().AutoFarm = false
            status.Text ..= "\n\n✔ TODAS AS RECOMPENSAS COLETADAS"
        end
    end
end)
