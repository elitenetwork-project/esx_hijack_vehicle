ESX              = nil
local ItemLabels = {}


-- ====================================================================================================================
-- IT= Evento Base  / EN= Base event / FR= Événement de base
-- ====================================================================================================================
TriggerEvent('esx:getShsmackaredObjsmackect', function(obj) ESX = obj end)


RegisterServerEvent('esx_hijack_vehicle:buyItem')
AddEventHandler('esx_hijack_vehicle:buyItem', function(itemName, price)

  local _source = source
  local xPlayer = ESX.GetPlayerFromId(_source)

  if xPlayer.get('money') >= price then
    xPlayer.removeMoney(price)
    xPlayer.addInventoryItem(itemName, 1)

    TriggerEvent('esx_addonaccount:getSharedAccount', 'society_mechanic', function(account)
      account.addMoney(price)
    end)

    TriggerClientEvent('esx:showNotification', _source, _U('bought') .. ItemLabels[itemName])
  else
    TriggerClientEvent('esx:showNotification', _source, _U('not_enough_money'))
  end

end)

-- ====================================================================================================================
-- IT= Rimuovo Item  / EN= Remove Item / FR= Je supprime l'article
-- ====================================================================================================================
RegisterServerEvent('esx_hijack_vehicle:removeItem')
AddEventHandler('esx_hijack_vehicle:removeItem', function(itemName)
  local _source = source
  local xPlayer = ESX.GetPlayerFromId(_source)

  xPlayer.removeInventoryItem('blowtorch', 1)
end)


-- ====================================================================================================================
-- IT= Settaggio item usabili  / EN= Usable item setting / FR= Paramètre d'élément utilisable
-- ====================================================================================================================

ESX.RegisterUsableItem('blowtorch', function(source)
  local xPlayers     = ESX.GetPlayers()
  local hasAmbulance = false

  for i = 1, #xPlayers, 1 do
    local xPlayer = ESX.GetPlayerFromId(xPlayers[i])
    if xPlayer.job.name == 'ambulance' then
      hasAmbulance = true
      break
    end
  end
  TriggerClientEvent('esx_hijack_vehicle:useKit', source, 'blowtorch', 1)

end)