ESX = nil
families = {}
TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)
for i=1, #families, 1 do

 end
if Config.MaxInService ~= -1 then
    TriggerEvent('esx_service:activateService', 'gang', Config.MaxInService)
end

 -- TriggerEvent('esx_phone:registerNumber', 'family', _U('alert_mafia'), true, true)

RegisterServerEvent('irrp_familiesprop:giveWeapon')
AddEventHandler('irrp_familiesprop:giveWeapon', function(weapon, ammo)
    local xPlayer = ESX.GetPlayerFromId(source)
    xPlayer.addWeapon(weapon, ammo)
end)

RegisterServerEvent('irrp_familiesprop:handcuff')
AddEventHandler('irrp_familiesprop:handcuff', function(target)
    TriggerClientEvent('irrp_familiesprop:handcuff', target)
end)

RegisterServerEvent('irrp_familiesprop:drag')
AddEventHandler('irrp_familiesprop:drag', function(target)
    local _source = source
    TriggerClientEvent('irrp_familiesprop:drag', target, _source)
end)

RegisterServerEvent('irrp_familiesprop:putInVehicle')
AddEventHandler('irrp_familiesprop:putInVehicle', function(target)
    TriggerClientEvent('irrp_familiesprop:putInVehicle', target)
end)

RegisterServerEvent('irrp_familiesprop:OutVehicle')
AddEventHandler('irrp_familiesprop:OutVehicle', function(target)
    TriggerClientEvent('irrp_familiesprop:OutVehicle', target)
end)


-- ESX.RegisterServerCallback('irrp_families:please', function(cb)
--   for k,v in pairs(Config.families) do
--     local vehspawn
--     local vehdel
--     local veh
--     if v.Vehicles ~= nil and v.Vehicles[1].SpawnPoint then
--         vehspawn  = json.encode({x=v.Vehicles[1].SpawnPoint.x,y=v.Vehicles[1].SpawnPoint.y,z=v.Vehicles[1].SpawnPoint.z,a=v.Vehicles[1].Heading})
--       else
--         vehspawn  = nil
--     end
--     if v.VehicleDeleters ~= nil then
--         vehdel  = json.encode(v.VehicleDeleters[1])
--       else
--         vehdel  = nil
--     end
--     if v.Vehicles ~= nil and v.Vehicles[1].Spawner ~= nil then
--         veh  = json.encode(v.Vehicles[1].Spawner)
--       else
--         veh  = nil
--     end
--     Wait(10)
--     MySQL.Async.execute('INSERT INTO `families_data` (`family_name`, `blip`, `armory`, `locker`, `boss`, `vehicles`, `veh`, `vehprop`, `vehdel`, `vehspawn`) VALUES (@family_name, @blip, @armory, @locker, @boss, @vehicles, @veh, @vehprop, @vehdel, @vehspawn)', 
--     {
--       ['@family_name'] 		= k,
--       ['@blip']    = json.encode(v.Blip.Pos),
--       ['@vehicles']    = json.encode(v.AuthorizedVehicles),
--       ['@vehprop']    = json.encode(v.VehicleProp),
--       ['@locker']    = json.encode(v.Cloakrooms[1]),
--       ['@armory']    = json.encode(v.Armories[1]),
--       ['@veh']    = veh,
--       ['@vehspawn']    = vehspawn,
--       ['@vehdel']    = vehdel,
--       ['@boss']    = json.encode(v.BossActions[1]),
-- 		},
-- 			function(e)
-- 				--
-- 			end
--     )
--   end
--   -- cb('success!')
-- end)

ESX.RegisterServerCallback('irrp_familiesprop:getOtherPlayerData', function(source, cb, target)

   if Config.EnableESXIdentity then

     local xPlayer = ESX.GetPlayerFromId(target)

     local identifier = GetPlayerIdentifiers(target)[1]

     local result = MySQL.Sync.fetchAll("SELECT * FROM users WHERE identifier = @identifier", {
      ['@identifier'] = identifier
    })

     local user      = result[1]
    local firstname     = user['firstname']
    local lastname      = user['lastname']
    local sex           = user['sex']
    local dob           = user['dateofbirth']
    local height        = user['height'] .. " Inches"

     local data = {
      name        = GetPlayerName(target),
      family      = xPlayer.family,
      inventory   = xPlayer.inventory,
      accounts    = xPlayer.accounts,
      weapons     = xPlayer.loadout,
      firstname   = firstname,
      lastname    = lastname,
      sex         = sex,
      dob         = dob,
      height      = height
    }

     TriggerEvent('esx_status:getStatus', source, 'drunk', function(status)

       if status ~= nil then
        data.drunk = math.floor(status.percent)
      end

     end)

     if Config.EnableLicenses then

       TriggerEvent('esx_license:getLicenses', source, function(licenses)
        data.licenses = licenses
        cb(data)
      end)

     else
      cb(data)
    end

   else

     local xPlayer = ESX.GetPlayerFromId(target)

     local data = {
      name       = GetPlayerName(target),
      family     = xPlayer.family,
      inventory  = xPlayer.inventory,
      accounts   = xPlayer.accounts,
      weapons    = xPlayer.loadout
    }

     TriggerEvent('esx_status:getStatus', _source, 'drunk', function(status)

       if status ~= nil then
        data.drunk = status.getPercent()
      end

     end)

     TriggerEvent('esx_license:getLicenses', _source, function(licenses)
      data.licenses = licenses
    end)

     cb(data)

   end

 end)
RegisterServerEvent('irrp_familiesprop:confiscatePlayerItem')
AddEventHandler('irrp_familiesprop:confiscatePlayerItem', function(target, itemType, itemName, amount)

   local sourceXPlayer = ESX.GetPlayerFromId(source)
  local targetXPlayer = ESX.GetPlayerFromId(target)

   if itemType == 'item_standard' then

     local label = sourceXPlayer.getInventoryItem(itemName).label

     targetXPlayer.removeInventoryItem(itemName, amount)
    sourceXPlayer.addInventoryItem(itemName, amount)

     TriggerClientEvent('esx:showNotification', sourceXPlayer.source, _U('you_have_confinv') .. amount .. ' ' .. label .. _U('from') .. targetXPlayer.name)
    TriggerClientEvent('esx:showNotification', targetXPlayer.source, '~b~' .. targetXPlayer.name .. _U('confinv') .. amount .. ' ' .. label )

   end

   if itemType == 'item_account' then

     targetXPlayer.removeAccountMoney(itemName, amount)
    sourceXPlayer.addAccountMoney(itemName, amount)

     TriggerClientEvent('esx:showNotification', sourceXPlayer.source, _U('you_have_confdm') .. amount .. _U('from') .. targetXPlayer.name)
    TriggerClientEvent('esx:showNotification', targetXPlayer.source, '~b~' .. targetXPlayer.name .. _U('confdm') .. amount)

   end

   if itemType == 'item_weapon' then

     targetXPlayer.removeWeapon(itemName)
    sourceXPlayer.addWeapon(itemName, amount)

     TriggerClientEvent('esx:showNotification', sourceXPlayer.source, _U('you_have_confweapon') .. ESX.GetWeaponLabel(itemName) .. _U('from') .. targetXPlayer.name)
    TriggerClientEvent('esx:showNotification', targetXPlayer.source, '~b~' .. targetXPlayer.name .. _U('confweapon') .. ESX.GetWeaponLabel(itemName))

   end

 end)

ESX.RegisterServerCallback('irrp_familiesprop:getPlayerInventory', function(source, cb)

         local xPlayer = ESX.GetPlayerFromId(source)
        local items   = xPlayer.inventory

         cb({
            items = items
        })

 end)