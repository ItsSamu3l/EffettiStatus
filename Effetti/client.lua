local effettoAttivo = false
local prossimaSfocatura = 0
local prossimaNotifica = 0
local tempoMessaggio = 0
local messaggioTesto = ""
local messaggioColore = { r = 255, g = 255, b = 255 }
local funzioneApplicata = false

local ESX = exports["es_extended"]:getSharedObject()

CreateThread(function()
    while true do
        Wait(1000)

        TriggerEvent('esx_status:getStatus', 'hunger', function(fame)
            TriggerEvent('esx_status:getStatus', 'thirst', function(sete)
                local fameBassa = fame.val <= 250000
                local seteBassa = sete.val <= 250000

                if fameBassa or seteBassa then
                    if GetGameTimer() > prossimaNotifica then
                        if fameBassa and seteBassa then
                            messaggioTesto = "Hai sia fame che sete!\nFermati e prenditi cura di te."
                            messaggioColore = { r = 220, g = 20, b = 60 }
                        elseif fameBassa then
                            messaggioTesto = "Hai una fame da lupi!\nVai a mangiare qualcosa."
                            messaggioColore = { r = 255, g = 140, b = 0 }
                        elseif seteBassa then
                            messaggioTesto = "Hai la gola secca!\nCerca subito dell’acqua."
                            messaggioColore = { r = 0, g = 191, b = 255 }
                        end

                        tempoMessaggio = GetGameTimer() + 4000
                        prossimaNotifica = GetGameTimer() + 15000
                    end

                    if GetGameTimer() > prossimaSfocatura then
                        StartScreenEffect("DrugsTrevorClownsFightIn", 5000, false)
                        prossimaSfocatura = GetGameTimer() + 15000
                    end

                    if not effettoAttivo then
                        ShakeGameplayCam("DRUNK_SHAKE", 0.5)
                        effettoAttivo = true
                    end

                    if not funzioneApplicata then
                        RequestAnimSet("move_m@injured")
                        while not HasAnimSetLoaded("move_m@injured") do Wait(100) end
                        SetPedMovementClipset(PlayerPedId(), "move_m@injured", 1.0)
                        funzioneApplicata = true
                    end
                else
                    if effettoAttivo then
                        StopScreenEffect("DrugsTrevorClownsFightIn")
                        StopGameplayCamShaking(true)
                        effettoAttivo = false
                    end

                    if funzioneApplicata then
                        ResetPedMovementClipset(PlayerPedId(), 0.0)
                        funzioneApplicata = false
                    end

                    prossimaNotifica = 0
                end
            end)
        end)
    end
end)

CreateThread(function()
    while true do
        Wait(0)
        if GetGameTimer() < tempoMessaggio and messaggioTesto ~= "" then
            SetTextFont(4)
            SetTextScale(0.75, 0.75)
            SetTextCentre(true)
            SetTextDropshadow(2, 2, 2, 2, 255)
            SetTextEdge(2, 0, 0, 0, 150)
            SetTextOutline()
            SetTextColour(messaggioColore.r, messaggioColore.g, messaggioColore.b, 255)
            BeginTextCommandDisplayText("STRING")
            AddTextComponentSubstringPlayerName(messaggioTesto)
            EndTextCommandDisplayText(0.5, 0.35)
        end
    end
end)
