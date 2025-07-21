local showingText = {}

-- Play custom dice roll sound via NUI
local function PlayCustomDiceSound()
    SendNUIMessage({ type = "playDiceRollSound" })
end

-- Show dice result
RegisterNetEvent("dice:showResult", function(sourceId, rollerName, resultString, coords)
    local playerPed = PlayerPedId()
    local myCoords = GetEntityCoords(playerPed)

    if #(coords - myCoords) <= 30.0 then
        -- Play sound via NUI
        PlayCustomDiceSound()

        -- Extract dice info and total
        local diceCount, diceSides = resultString:match("^(%d+)d(%d+)")
        local total = resultString:match("→%s*(%d+)")
        local displayText = string.format("Dice roll: %s (%sd%s)", total or "?", diceCount or "?", diceSides or "?")

        -- Attach text to roller's ped
        local key = tostring(sourceId)
        local player = GetPlayerFromServerId(sourceId)
        if player and player ~= -1 then
            local ped = GetPlayerPed(player)
            if DoesEntityExist(ped) then
                showingText[key] = {
                    ped = ped,
                    text = displayText,
                    timer = GetGameTimer() + 10000
                }
            end
        end
    end
end)

-- Draw 3D text with dark background
function DrawText3D(x, y, z, text)
    local onScreen, _x, _y = World3dToScreen2d(x, y, z)
    if onScreen then
        SetTextScale(0.35, 0.35)
        SetTextFont(4)
        SetTextProportional(1)
        SetTextCentre(true)
        SetTextColour(255, 255, 255, 215)
        SetTextEntry("STRING")
        AddTextComponentString(text)

        local factor = string.len(text) / 370
        DrawRect(_x, _y + 0.0125, 0.015 + factor, 0.03, 0, 0, 0, 120)
        DrawText(_x, _y)
    end
end

-- Display loop
CreateThread(function()
    while true do
        Wait(0)
        local now = GetGameTimer()
        for k, v in pairs(showingText) do
            if now > v.timer then
                showingText[k] = nil
            elseif DoesEntityExist(v.ped) then
                local pos = GetEntityCoords(v.ped)
                DrawText3D(pos.x, pos.y, pos.z + 0, v.text)
            end
        end
    end
end)

-- Play roll animation
RegisterNetEvent("dice:playRollAnim", function(sourceId)
    local player = GetPlayerFromServerId(sourceId)
    if player == -1 then return end

    local ped = GetPlayerPed(player)
    if not DoesEntityExist(ped) then return end

    local animDict = "anim@mp_player_intcelebrationmale@wank"
    local animName = "wank"

    RequestAnimDict(animDict)
    while not HasAnimDictLoaded(animDict) do Wait(0) end

    TaskPlayAnim(ped, animDict, animName, 8.0, -8.0, 1500, 49, 0, false, false, false)
end)

-- Roll command
RegisterCommand("roll", function(_, args)
    if not args[1] then
        print("Usage: /roll d20 or /roll 2d6")
        return
    end

    local input = args[1]:lower()
    local num, sides = input:match("^(%d*)d(%d+)$")
    num = tonumber(num) or 1
    sides = tonumber(sides)

    if not sides then
        print("Invalid roll format")
        return
    end

    local ped = PlayerPedId()
    local coords = GetEntityCoords(ped)
    TriggerServerEvent("dice:rollDice", num, sides, coords)
end, false)