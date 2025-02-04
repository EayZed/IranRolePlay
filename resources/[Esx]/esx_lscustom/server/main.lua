ESX = nil
TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)
local Vehicles = nil
-- function dump(o)
-- 	if type(o) == 'table' then
-- 	   local s = '{ '
-- 	   for k,v in pairs(o) do
-- 		  if type(k) ~= 'number' then k = '"'..k..'"' end
-- 		  s = s .. '['..k..'] = ' .. dump(v) .. ','
-- 	   end
-- 	   return s .. '} '
-- 	else
-- 	   return tostring(o)
-- 	end
--  end

function getIdentOfOwner(plate)
	local Plate = plate
	local result = MySQL.Sync.fetchAll('SELECT * FROM `owned_vehicles` WHERE `plate` = "'.. Plate ..'"', {})
	local owner
	if result[1] then
		owner = result[1].owner
	else
		return nil
	end
	local xPlayers = ESX.GetPlayers()
	local player = nil
	if xPlayers then
		for i=1, #xPlayers, 1 do
			player = xPlayers[i]
			local tmpIdent = GetPlayerIdentifiers(player)[1]
			if owner == tmpIdent then
				return player
			end
		end
	end
	return nil
end

--  TriggerEvent('es:addCommand', 'wplate', function(source, args, user)
-- 	local plate = table.concat(args," ",1,2)
-- 	local test = getIdentOfOwner(plate)
-- 	local xPlayers = ESX.GetPlayers()
-- 	local player

-- 	for i=1, #xPlayers, 1 do
-- 		player = xPlayers[i]

-- 		local tmpIdent = GetPlayerIdentifiers(player)[1]

-- 		if test == tmpIdent then
-- 			VehOwner = ESX.GetPlayerFromId(player)
-- 			break
-- 		end
-- 	end
-- end)


RegisterServerEvent('esx_lscustommeca:buyMod')
AddEventHandler('esx_lscustommeca:buyMod', function(price, plate)
	local formattedMoney = _U('locale_currency', ESX.Math.GroupDigits(price))
	local buyer = getIdentOfOwner(plate)
	local buyerId = ESX.GetPlayerFromId(buyer)
	local _source = source
	local osaMechanic = ESX.GetPlayerFromId(_source)
	local societyAccount = nil
	TriggerEvent('esx_addonaccount:getSharedAccount', 'society_mecano', function(account)
		societyAccount = account
	end)
	if buyer then
		if price < buyerId.getMoney() then
			TriggerClientEvent('esx_lscustommeca:installMod', _source)
			buyerId.removeMoney(price)
			TriggerClientEvent('esx:showNotification', buyer, _U('purchasedBuyer', formattedMoney))
			if buyer ~= _source then
				TriggerClientEvent('esx:showNotification', _source, _U('purchasedMechanic', formattedMoney))
			end
			societyAccount.addMoney(price)
		else
			TriggerClientEvent('esx_lscustommeca:cancelInstallMod', _source)
			TriggerClientEvent('esx:showNotification', buyer, _U('not_enough_money_buyer', formattedMoney))
			if buyer ~= _source then
				TriggerClientEvent('esx:showNotification', _source, _U('not_enough_money_mechanic'))
			end
		end
	elseif osaMechanic.job.name == 'admin' then
		TriggerClientEvent('esx_lscustommeca:installMod', _source)
	else
		TriggerClientEvent('esx_lscustommeca:cancelInstallMod', _source)
		TriggerClientEvent('esx:showNotification', _source, _U('stolencar'))
	end
end)

RegisterServerEvent('esx_lscustommeca:refreshOwnedVehicle')
AddEventHandler('esx_lscustommeca:refreshOwnedVehicle', function(myCar)

	MySQL.Async.execute(
		'UPDATE `owned_vehicles` SET `vehicle` = @vehicle WHERE `vehicle` LIKE "%' .. myCar['plate'] .. '%"',
		{
			['@vehicle'] = json.encode(myCar)
		}
	)
end)

ESX.RegisterServerCallback('esx_lscustommeca:getVehiclesPrices', function(source, cb)

	if Vehicles == nil then
		MySQL.Async.fetchAll(
			'SELECT * FROM vehicles',
			{},
			function(result)
				local vehicles = {}
				for i=1, #result, 1 do
					table.insert(vehicles,{
						model = result[i].model,
						price = result[i].price
					})
				end
				Vehicles = vehicles
				cb(Vehicles)
			end
		)		
	else
		cb(Vehicles)
	end
end)