-- VB HUB | AUTO MAP SAFE | FINAL FIX

-- ======================
-- CONFIG
-- ======================
local MAP_PREFIX = 2          -- <<< AQUI É O "2_"
local BASE_DELAY = 0.9
local FAIL_DELAY = 1.2
local MAX_FAILS = 10
local RETRY_PER_ID = 3

-- ======================
-- SERVICES
-- ======================
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
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
-- STATE
-- ======================
getgenv().AutoFarm = false
local CurrentJobId = game.JobId

-- ======================
-- GUI
-- ======================
local gui = Instance.new("ScreenGui", CoreGui)
gui.Name = "VB_AUTO_SAFE"

local frame = Instance.new("Frame", gui)
frame.Size = UDim2.new(0, 320, 0, 260)
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
status.TextWrapped = true
status.TextYAlignment = Enum.TextYAlignment.Top
status.BackgroundTransparency = 1
status.Text = "Pronto."

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
-- AUTO FARM (CORRETO)
-- ======================
task.spawn(function()
    while task.wait(0.3) do
        if not getgenv().AutoFarm then continue end

        -- RESET AO TROCAR SERVER
        if game.JobId ~= CurrentJobId then
            CurrentJobId = game.JobId
            status.Text = "🔄 Novo servidor detectado\nResetando..."
            task.wait(1)
        end

        local index = 0
        local fails = 0
        local totalTestados = 0
        local totalValidos = 0

        while getgenv().AutoFarm and fails < MAX_FAILS do
            local crateId = MAP_PREFIX .. "_" .. index
            local success = false

            for attempt = 1, RETRY_PER_ID do
                local ok, ret = pcall(function()
                    return Remote:InvokeServer(crateId)
                end)

                if ok and ret then
                    success = true
                    totalValidos += 1
                    task.wait(BASE_DELAY)
                else
                    task.wait(FAIL_DELAY)
                end
            end

            totalTestados += 1

            if success then
                fails = 0
            else
                fails += 1
            end

            status.Text =
                "Prefixo: "..MAP_PREFIX..
                "\nID atual: "..crateId..
                "\nIDs testados: "..totalTestados..
                "\nIDs válidos: "..totalValidos..
                "\nFalhas seguidas: "..fails

            index += 1
        end

        status.Text ..= "\n\n✔ TODAS AS CAIXAS DO SERVIDOR FORAM COLETADAS"
        getgenv().AutoFarm = false
        toggle.Text = "LIGAR AUTO FARM"
        toggle.BackgroundColor3 = Color3.fromRGB(0,170,0)
    end
end)
