RegisterServerEvent("dice:rollDice")
AddEventHandler("dice:rollDice", function(num, sides, coords)
    local src = source

    local function rollDice(num, sides)
        local results, sum = {}, 0
        for i = 1, num do
            local roll = math.random(1, sides)
            table.insert(results, roll)
            sum = sum + roll
        end
        return results, sum
    end

    local name = GetPlayerName(src) or ("Player %s"):format(src)
    local rolls, total = rollDice(num, sides)
    local resultText = ("%dd%d = [%s] → %d"):format(num, sides, table.concat(rolls, ", "), total)

    for _, playerId in ipairs(GetPlayers()) do
        TriggerClientEvent("dice:playRollAnim", playerId, src)
        TriggerClientEvent("dice:showResult", playerId, src, name, resultText, coords)
    end
end)
