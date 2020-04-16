ESX = nil
local GUI                     = {}
GUI.Time                      = 0
local HasAlreadyEnteredMarker = false
local LastZone                = nil
local CurrentAction           = nil
local CurrentActionMsg        = ''
local CurrentActionData       = {}


-- ====================================================================================================================
-- IT= Funzioni  / EN= Functions / FR= Fonctions
-- ====================================================================================================================
function setCurrentAction(action, msg, data)
  CurrentAction     = action
  CurrentActionMsg  = msg
  CurrentActionData = data
end


-- ====================================================================================================================
-- Citizen thread
-- ====================================================================================================================
Citizen.CreateThread(function()
  while ESX == nil do
    TriggerEvent('esx:getShsmackaredObjsmackect', function(obj) ESX = obj end)
    Citizen.Wait(0)
  end
end)

-- ====================================================================================================================
-- IT= Creo i marker  / EN= I create the markers / FR= Je crée les marqueurs
-- ====================================================================================================================
Citizen.CreateThread(function()
  while true do
    Wait(0)
    local coords = GetEntityCoords(GetPlayerPed(-1))

    for k,v in pairs(Config.Shops) do
      if GetDistanceBetweenCoords(coords, v.x, v.y, v.z, true) < Config.DrawDistance then
        DrawMarker(
          Config.MarkerType, 
          v.x, 
          v.y, 
          v.z, 
          0.0, 
          0.0, 
          0.0, 
          0, 
          0.0, 
          0.0,
          Config.MarkerSize.x, 
          Config.MarkerSize.y, 
          Config.MarkerSize.z, 
          Config.MarkerColor.r, 
          Config.MarkerColor.g, 
          Config.MarkerColor.b, 
          100, 
          false, 
          true, 
          2, 
          false, 
          false, 
          false, 
          false
        )
      end
    end
  end
end)

-- ==========================================================================================================================================
-- IT= Creo evento entrata / uscita marker / EN= I create marker entry / exit event / FR= Je crée un événement d'entrée / sortie de marqueur
-- ==========================================================================================================================================
Citizen.CreateThread(function()
  while true do
    Wait(0)
    local coords      = GetEntityCoords(GetPlayerPed(-1))
    local isInMarker  = false
    local currentZone = nil

    for k,v in pairs(Config.Shops) do
      if GetDistanceBetweenCoords(coords, v.x, v.y, v.z, true) < Config.MarkerSize.x then
        isInMarker  = true
        currentZone = k
      end
    end

    if (isInMarker and not HasAlreadyEnteredMarker) or (isInMarker and LastZone ~= currentZone) then
      HasAlreadyEnteredMarker = true
      LastZone                = currentZone
      TriggerEvent('esx_hijack_vehicle:hasEnteredMarker', currentZone)
    end

    if not isInMarker and HasAlreadyEnteredMarker then
      HasAlreadyEnteredMarker = false
      TriggerEvent('esx_hijack_vehicle:hasExitedMarker', LastZone)
    end

  end
end)

-- ====================================================================================================================
-- IT= Settaggio Tasti / EN= Keys setting / FR= Réglage des touches
-- ====================================================================================================================
Citizen.CreateThread(function()
  while true do
    Citizen.Wait(0)
    if CurrentAction ~= nil then
      SetTextComponentFormat('STRING')
      AddTextComponentString(CurrentActionMsg)
      DisplayHelpTextFromStringLabel(0, 0, 1, -1)
      if IsControlPressed(0, 38) and (GetGameTimer() - GUI.Time) > 300 then
        if CurrentAction == 'mecano_shop' then
          OpenShopMenu()
        end
        CurrentAction = nil
        GUI.Time      = GetGameTimer()
      end
    end
  end
end)

-- ====================================================================================================================
-- IT= Eventi / EN= Events / FR= événements
-- ====================================================================================================================
AddEventHandler('esx_hijack_vehicle:hasEnteredMarker', function(zone)
  CurrentAction     = 'mecano_shop'
  CurrentActionMsg  = _U('press_menu')
  CurrentActionData = {}
end)

AddEventHandler('esx_hijack_vehicle:hasExitedMarker', function(zone)
  ESX.UI.Menu.CloseAll()
  CurrentAction = nil
end)

RegisterNetEvent('esx_hijack_vehicle:useKit')
AddEventHandler('esx_hijack_vehicle:useKit', function(itemName, hp_regen)
	local playerPed = PlayerPedId()
	PedPosition		= GetEntityCoords(playerPed)
	local vehicle   = ESX.Game.GetVehicleInDirection()
	local IsBusy                  = false
	local PlayerCoords = { x = PedPosition.x, y = PedPosition.y, z = PedPosition.z }
	if IsPedSittingInAnyVehicle(playerPed) then
		ESX.ShowNotification(_U('exit_vehicle'))
		return
	end

	if DoesEntityExist(vehicle) then
		IsBusy = true
		TriggerServerEvent('esx_addons_gcphone:startCall', 'police', _U('car_entry'), PlayerCoords, {PlayerCoords = { x = PedPosition.x, y = PedPosition.y, z = PedPosition.z },})
		ESX.ShowNotification(_U('alert'))
		exports['progressBars']:startUI(15000, _U('car_entry'))
		TaskStartScenarioInPlace(playerPed, "WORLD_HUMAN_WELDING", 0, true)
		Citizen.CreateThread(function()
			Citizen.Wait(15000)

			SetVehicleDoorsLocked(vehicle, 1)
			SetVehicleDoorsLockedForAllPlayers(vehicle, false)
			ClearPedTasksImmediately(playerPed)
			ESX.ShowNotification(_U('complete'))
			IsBusy = false
		end)
	else
		ESX.ShowNotification(_U('no_vehicle'))
	end
	TriggerServerEvent('esx_hijack_vehicle:removeItem')
end)

-- ====================================================================================================================
-- Funzione apertura menu / Menu opening function / Fonction d'ouverture du menu
-- ====================================================================================================================
function OpenShopMenu()
  ESX.UI.Menu.CloseAll()

  local elements = {
    { 
      label = _U('blowtorch') .. ' Prezzo: [' .. Config.Price['blowtorch'] .. '$]',
      value = { name = 'blowtorch',    price = Config.Price['blowtorch'] } 
    }
  }

  ESX.UI.Menu.Open('default', GetCurrentResourceName(), 'shop', {
      title    = _U('drugstore'),
      align    = 'top-left',
      elements = elements
    }, function(data, menu)
      local element = data.current.value

      ESX.UI.Menu.Open('default', GetCurrentResourceName(), 'shop_confirm', {
          title = _U('valid_this_purchase'),
          align = 'top-left',
          elements = {
            { label = _U('yes'), value = 'yes' },
            { label = _U('no'),  value = 'no'  }
          }
        }, function(data2, menu2)
          if data2.current.value == 'yes' then
            TriggerServerEvent('esx_hijack_vehicle:buyItem', element.name, element.price)
          end
          
          menu2.close()
          setCurrentAction('mecano_shop', _U('press_menu'), {})
        end, function(data2, menu2)
          menu2.close()
        end
      )

    end, function(data, menu)
      menu.close()
    end
  )

end