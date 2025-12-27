-- VB HUB | JUJUTSU ZERO | AUTO CAIXAS FINAL

-- ======================
-- CONFIG
-- ======================
local DELAY = 0.5
local SAVE_FILE = "vb_jz_caixas.json"

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
    ReplicatedStorage:WaitForChild("NetworkComm")
        :WaitForChild("MapService")
        :WaitForChild("OpenExplorationCrate_Method")

-- ======================
-- VARIÁVEIS
-- ======================
getgenv().AutoFarm = false
local Caixas = {}

-- ======================
-- SAVE / LOAD
-- ======================
local function salvar()
    if writefile then
        writefile(SAVE_FILE, HttpService:JSONEncode(Caixas))
    end
end

local function carregar()
    if readfile and isfile and isfile(SAVE_FILE) then
        Caixas = HttpService:JSONDecode(readfile(SAVE_FILE))
    end
end

carregar()

-- ======================
-- DETECTOR SILENCIOSO
-- ======================
local old
old = hookmetamethod(game, "__namecall", function(self, ...)
    local args = {...}
    local method = getnamecallmethod()

    if self == Remote and method == "InvokeServer" then
        local id = args[1]
        if typeof(id) == "string" and not Caixas[id] then
            Caixas[id] = true
            salvar()
        end
    end

    return old(self, ...)
end)

-- ======================
-- AUTO FARM
-- ======================
task.spawn(function()
    while task.wait(1) do
        if getgenv().AutoFarm then
            for id in pairs(Caixas) do
                if not getgenv().AutoFarm then break end
                pcall(function()
                    Remote:InvokeServer(id)
                end)
                task.wait(DELAY)
            end
        end
    end
end)

-- ======================
-- GUI
-- ======================
local gui = Instance.new("ScreenGui", CoreGui)
gui.Name = "VB_JZ_HUB"

local frame = Instance.new("Frame", gui)
frame.Size = UDim2.new(0, 260, 0, 170)
frame.Position = UDim2.new(0.05, 0, 0.35, 0)
frame.BackgroundColor3 = Color3.fromRGB(20,20,20)
frame.Active = true
frame.Draggable = true
Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 10)

local title = Instance.new("TextLabel", frame)
title.Size = UDim2.new(1, -40, 0, 40)
title.Position = UDim2.new(0, 10, 0, 0)
title.Text = "VB HUB | AUTO CAIXAS"
title.TextColor3 = Color3.fromRGB(255,0,0)
title.Font = Enum.Font.GothamBold
title.TextSize = 14
title.BackgroundTransparency = 1
title.TextXAlignment = Enum.TextXAlignment.Left

-- FECHAR
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

-- STATUS
local status = Instance.new("TextLabel", frame)
status.Size = UDim2.new(1, -20, 0, 40)
status.Position = UDim2.new(0, 10, 0, 45)
status.Text = "Caixas salvas: "..tostring(#(function()
    local t = {}
    for k in pairs(Caixas) do table.insert(t,k) end
    return t
end)())
status.TextColor3 = Color3.new(1,1,1)
status.Font = Enum.Font.Gotham
status.TextSize = 12
status.BackgroundTransparency = 1
status.TextWrapped = true

-- TOGGLE
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

    if getgenv().AutoFarm then
        toggle.Text = "DESLIGAR AUTO FARM"
        toggle.BackgroundColor3 = Color3.fromRGB(170,0,0)
    else
        toggle.Text = "LIGAR AUTO FARM"
        toggle.BackgroundColor3 = Color3.fromRGB(0,170,0)
    end
end)
