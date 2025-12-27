-- ======================
-- AUTO FARM (LÓGICA FINAL CORRETA)
-- ======================

local MAX_SCAN = 50          -- quantos IDs testar antes de concluir que não existe nenhuma caixa
local RETRY_PER_ID = 3

task.spawn(function()
    while task.wait(0.2) do
        if not getgenv().AutoFarm then
            task.wait(0.5)
            continue
        end

        -- reset ao trocar de server
        if game.JobId ~= CurrentJobId then
            CurrentJobId = game.JobId
            CaixasAbertas = {}
            IndexAtual = 0
            Abertas = 0
        end

        local encontrouAlguma = false
        local scanInicial = IndexAtual

        -- SCAN PRINCIPAL
        while getgenv().AutoFarm and (IndexAtual - scanInicial) < MAX_SCAN do
            local id = MAP_ID .. "_" .. IndexAtual

            if not CaixasAbertas[id] then
                for tentativa = 1, RETRY_PER_ID do
                    if not getgenv().AutoFarm then break end

                    local ok, ret = pcall(function()
                        return Remote:InvokeServer(id)
                    end)

                    if ok and ret then
                        encontrouAlguma = true
                        CaixasValidas[id] = true
                        CaixasAbertas[id] = true
                        Abertas += 1
                        salvar()
                        break
                    end

                    task.wait(DELAY)
                end
            end

            status.Text =
                "ID atual: "..id..
                "\nCaixas válidas: "..contarValidas()..
                "\nAbertas nesta sessão: "..Abertas..
                "\nAutoFarm: ATIVO"

            IndexAtual += 1
            task.wait(DELAY)
        end

        -- ❗ SÓ PARA SE REALMENTE NÃO EXISTIR NENHUMA CAIXA
        if not encontrouAlguma then
            status.Text =
                "Nenhuma caixa encontrada neste servidor.\n"..
                "AutoFarm parado automaticamente."
            getgenv().AutoFarm = false
            toggle.Text = "LIGAR AUTO FARM"
            toggle.BackgroundColor3 = Color3.fromRGB(0,170,0)
        end
    end
end)
