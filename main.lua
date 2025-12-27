-- VB HUB | JUJUTSU ZERO | AUTO OPEN 2_X (FINAL)

-- ======================
-- CONFIG
-- ======================
local MAP_ID = 2
local MAX_CAIXAS = 30
local DELAY = 0.6
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
local Abertas = 0

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

-- ======================
-- CONTADOR
-- ======================
local function contarValidas()
    local c = 0
    for _ in pairs(CaixasValidas) do c += 1 end
    return c
end

-- ======================
-- GUI
-- ======================
local gui = Instance.new("ScreenGui", CoreGui)
gui.Name = "VB_AUTO_2X"

local frame = Instance.new("Frame", gui)
frame.Size = UDim2.new(0, 260, 0, 180)
frame.Position = UDim2.new(0.05, 0, 0.35, 0)
frame.BackgroundColor3 = Color3.fromRGB(20,20,20)
frame.Active = true
frame.Draggable = true
Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 10)

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
    gui:Destroy()
end)

local status = Instance.new("TextLabel", frame)
status.Size = UDim2.new(1, -20, 0, 45)
status.Position = UDim2.new(0, 10, 0, 40)
status.Text = "Caixas válidas: "..contarValidas().."\nAbertas: "..Abertas
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
-- AUTO FARM
-- ======================
task.spawn(function()
    while task.wait(1) do
        if getgenv().AutoFarm then
            for i = 1, MAX_CAIXAS do
                if not getgenv().AutoFarm then break end

                local id = MAP_ID .. "_" .. i

                -- se já é válida, só abre
                if CaixasValidas[id] then
                    pcall(function()
                        Remote:InvokeServer(id)
                        Abertas += 1
                    end)
                else
                    -- testa se é válida
                    local ok, retorno = pcall(function()
                        return Remote:InvokeServer(id)
                    end)

                    if ok and retorno then
                        CaixasValidas[id] = true
                        salvar()
                        Abertas += 1
                    end
                end

                status.Text = "Caixas válidas: "..contarValidas().."\nAbertas: "..Abertas
                task.wait(DELAY)
            end
        end
    end
end)
