ESX                      = {}
ESX.Players              = {}
ESX.UsableItemsCallbacks = {}
ESX.Items                = {}
ESX.ServerCallbacks      = {}
ESX.TimeoutCount         = -1
ESX.CancelledTimeouts    = {}
ESX.LastPlayerData       = {}
ESX.Pickups              = {}
ESX.PickupId             = 0
ESX.Jobs                 = {}
ESX.Families             = {}

AddEventHandler('esx:getSharedObject', function(cb)
	cb(ESX)
end)

function getSharedObject()
	return ESX
end

MySQL.ready(function()
	MySQL.Async.fetchAll('SELECT * FROM items', {}, function(result)
		for i=1, #result, 1 do
			ESX.Items[result[i].name] = {
				label     = result[i].label,
				limit     = result[i].limit,
				rare      = (result[i].rare       == 1 and true or false),
				canRemove = (result[i].can_remove == 1 and true or false),
			}
		end
	end)

	local result = MySQL.Sync.fetchAll('SELECT * FROM jobs', {})

	for i=1, #result do
		ESX.Jobs[result[i].name] = result[i]
		ESX.Jobs[result[i].name].grades = {}
	end

	local result2 = MySQL.Sync.fetchAll('SELECT * FROM job_grades', {})

	for i=1, #result2 do
		if ESX.Jobs[result2[i].job_name] then
			ESX.Jobs[result2[i].job_name].grades[tostring(result2[i].grade)] = result2[i]
		else
			print(('es_extended: invalid job "%s" from table job_grades ignored!'):format(result2[i].job_name))
		end
	end

	for k,v in pairs(ESX.Jobs) do
		if next(v.grades) == nil then
			ESX.Jobs[v.name] = nil
			print(('es_extended: ignoring job "%s" due to missing job grades!'):format(v.name))
		end
	end

	local family = MySQL.Sync.fetchAll('SELECT * FROM families', {})

	for i=1, #family do
		ESX.Families[family[i].name] = family[i]
		ESX.Families[family[i].name].grades = {}
	end

	local family2 = MySQL.Sync.fetchAll('SELECT * FROM family_grades', {})

	for i=1, #family2 do
		if ESX.Families[family2[i].family_name] then
			ESX.Families[family2[i].family_name].grades[tostring(family2[i].grade)] = family2[i]
		else
			print(('es_extended: invalid family "%s" from table family_grades ignored!'):format(family2[i].family_name))
		end
	end

	for k,v in pairs(ESX.Families) do
		if next(v.grades) == nil then
			ESX.Families[v.name] = nil
			print(('es_extended: ignoring family "%s" due to missing family grades!'):format(v.name))
		end
	end
end)

AddEventHandler('esx:playerLoaded', function(source)
	local xPlayer         = ESX.GetPlayerFromId(source)
	local accounts        = {}
	local items           = {}
	local xPlayerAccounts = xPlayer.getAccounts()
	local xPlayerItems    = xPlayer.getInventory()

	for i=1, #xPlayerAccounts, 1 do
		accounts[xPlayerAccounts[i].name] = xPlayerAccounts[i].money
	end

	for i=1, #xPlayerItems, 1 do
		items[xPlayerItems[i].name] = xPlayerItems[i].count
	end

	ESX.LastPlayerData[source] = {
		accounts = accounts,
		items    = items
	}
end)

RegisterServerEvent('esx:clientLog')
AddEventHandler('esx:clientLog', function(msg)
	RconPrint(msg .. "\n")
end)

RegisterServerEvent('esx:triggerServerCallback')
AddEventHandler('esx:triggerServerCallback', function(name, requestId, ...)
	local _source = source

	ESX.TriggerServerCallback(name, requestID, _source, function(...)
		TriggerClientEvent('esx:serverCallback', _source, requestId, ...)
	end, ...)
end)

RegisterServerEvent('es_extended:addFamily')
AddEventHandler('es_extended:addFamily', function(name,ranks)
	ESX.Families[name] = {name = name,label = 'family'}
	ESX.Families[name].grades = {}
	for i=1, #ranks, 1 do
		ESX.Families[name].grades[tostring(i)] = {family_name = name, grade = i, name = 'Rank'..i, label = 'Rank'..i, salary = 100*i, skin_male = '{}', skin_female = '{}'}
	end
end)