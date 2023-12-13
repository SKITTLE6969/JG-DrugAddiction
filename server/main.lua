local QBCore = exports['qb-core']:GetCoreObject()

-- Callback for getting drug consumption
QBCore.Functions.CreateCallback('JG-DrugAddiction:getdrugconsumption', function(source, cb)
    local Player = QBCore.Functions.GetPlayer(source)
    if Player then
        -- Assuming your database structure is the same, otherwise adjust accordingly
        MySQL.scalar('SELECT drugconsumption FROM players WHERE identifier = ?', {Player.PlayerData.citizenid}, function(drugconsumption)
            cb(drugconsumption)
        end)
    end
end)

-- Callback for adding drug consumption
QBCore.Functions.CreateCallback('JG-DrugAddiction:adddrugconsumption', function(source)
    local Player = QBCore.Functions.GetPlayer(source)
    if Player then
        MySQL.update('UPDATE players SET drugconsumption = drugconsumption + 1 WHERE identifier = ?', {Player.PlayerData.citizenid})
    end
end)

-- Registering usable items from a config (adjust the Config.items accordingly)
for k, v in pairs(Config.items) do 
    QBCore.Functions.CreateUseableItem(k, function(playerId)
        local Player = QBCore.Functions.GetPlayer(playerId)
        TriggerClientEvent('JG-DrugAddiction:incrementdrug', playerId) -- Adjust the event names as per your client script
        TriggerClientEvent('JG-DrugAddiction:reducedesire', playerId)
    end)
end   

-- Using the cure item
QBCore.Functions.CreateUseableItem('cureitem', function(playerId)
    local Player = QBCore.Functions.GetPlayer(playerId)
    if Player then
        TriggerClientEvent('JG-DrugAddiction:Cure', playerId)
        Player.Functions.RemoveItem('cureitem', 1)
        TriggerClientEvent('QBCore:Notify', playerId, 'You are cured', 'success') 
        MySQL.update('UPDATE players SET drugconsumption = 0 WHERE identifier = ?', {Player.PlayerData.citizenid})
    end
end)
