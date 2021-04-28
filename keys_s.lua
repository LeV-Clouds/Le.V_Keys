ESX = nil

TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)

ESXS = {}
ESXS.Pickups = {}
ESXS.PickupId = 0

ESXS.CreatePickup = function(name, label, playerId, plaque, nom, type) -- Fonction Pickup
	local pickupId = (ESXS.PickupId == 65635 and 0 or ESXS.PickupId + 1)

    ESXS.Pickups[pickupId] = {
        name  = name,
        label = label,
        plaque = plaque,
        nom = nom,
        type = type,
    } 
    TriggerClientEvent('core:CreationPickup', -1, pickupId, label, playerId, plaque, nom, type)  
    ESXS.PickupId = pickupId
end

ESX.RegisterServerCallback("core:GetCle", function(source, CallBack) -- Get clé dnas le menu
    local xPlayer = ESX.GetPlayerFromId(source)
    MySQL.Async.fetchAll("SELECT * FROM cle WHERE license = '" .. xPlayer.identifier .. "';", {}, function(GetInfos)
        CallBack(GetInfos)
    end)
end)

ESX.RegisterServerCallback("core:GetPlateOfKey", function(source, CallBack, Plaque) -- Get les clés liée à la plaque !
    local xPlayer = ESX.GetPlayerFromId(source)
    MySQL.Async.fetchAll("SELECT * FROM cle WHERE plate = '" .. Plaque .. "';", {}, function(GetInfos)
        if GetInfos[1] ~= nil then
            CallBack(false)
        else 
            CallBack(true)
        end
    end)
end)

RegisterServerEvent("core:ActionCle") -- Action sur mes clés
AddEventHandler("core:ActionCle", function(Joueur, Plaque, Nom, Option, ID, type)
    local xPlayer = ESX.GetPlayerFromId(source)
    local xTarget = ESX.GetPlayerFromId(Joueur)

    if Option == "Donner" then
        MySQL.Async.execute("UPDATE cle SET license = '" .. xTarget.identifier .. "' WHERE id = '" .. ID .."';", {}, function()
            TriggerClientEvent("core:PopUp", Joueur, {message = "- ~r~Action Clé~s~\n- Type : ~y~Donnation~s~\n- Plaque : ~g~" .. Plaque})
            TriggerClientEvent("core:PopUp", xPlayer.source, {message = "- ~r~Action Clé~s~\n- Type : ~y~Donnation~s~\n- Nouveau : ~b~" .. Plaque})
        end)
    elseif Option == "Prêter" then 
        MySQL.Async.execute("INSERT INTO cle (license, plate, nom, type) VALUES ('" .. xTarget.identifier .. "','" .. Plaque .. "','" .. Nom .. "', '" .. tonumber(1) .. "')", {}, function()
            TriggerClientEvent("core:PopUp", Joueur, {message = "- ~r~Action Clé~s~\n- Type : ~y~Prêter~s~\n- Plaque : ~g~" .. Plaque})
            TriggerClientEvent("core:PopUp", xPlayer.source, {message = "- ~r~Action Clé~s~\n- Type : ~y~Prêter~s~\n- Nouveau : ~b~" .. Plaque})
        end)
    elseif Option == "Renommer" then 
        MySQL.Async.execute("UPDATE cle SET nom = '" .. Nom .. "' WHERE id = '" .. ID .."';", {}, function()
            TriggerClientEvent("core:PopUp", xPlayer.source, {message = "- ~r~Action Clé~s~\n- Type : ~y~Renom~s~\n- Nouveau : ~g~" .. Nom})
        end)
    elseif Option == "Jeter" then 
        MySQL.Async.execute("DELETE FROM cle WHERE id = '" .. ID .. "' ", {},function()
        end)
        ESXS.CreatePickup("Clé de voiture", "Clé - [~y~".. Plaque .. "~s~] - " .. Nom .. "\n~s~Appuyez sur [~g~E~s~] pour ramasser", xPlayer.source, Plaque, Nom, type)
    end
end)

RegisterServerEvent("core:GiveCleOfVehicle") -- Give des clés au concess
AddEventHandler("core:GiveCleOfVehicle", function(Joueur, Plaque, Nom, type)
    local xPlayer = ESX.GetPlayerFromId(source)
    local xTarget = ESX.GetPlayerFromId(Joueur)
    MySQL.Async.execute("INSERT INTO cle (license, plate, nom, type) VALUES ('" .. xTarget.identifier .. "','" .. Plaque .. "','" .. Nom .. "', '" .. tonumber(type) .. "')", {}, function()
        TriggerClientEvent("core:PopUp", Joueur, {message = "- ~r~Action Clé~s~\n- Type : ~y~Donnation~s~\n- Plaque : ~g~" .. Plaque})
        TriggerClientEvent("core:PopUp", xPlayer.source, {message = "- ~r~Action Clé~s~\n- Type : ~y~Donnation~s~\n- Nouveau : ~b~" .. Plaque})
    end)
end)

RegisterServerEvent("core:OnPickupCle") -- Prendre la clé à terre
AddEventHandler("core:OnPickupCle", function(Joueur, Plaque, Nom, type, PickupId)
    local pickup, xPlayer, CCarrer = ESXS.Pickups[PickupId]
    local xPlayer = ESX.GetPlayerFromId(Joueur)
	if pickup then
		CCarrer = true
		if CCarrer then
				TriggerClientEvent('core:RemovePickup', -1, PickupId)
                print(type)
                MySQL.Async.execute("INSERT INTO cle (license, plate, nom, type) VALUES ('" .. xPlayer.identifier .. "','" .. Plaque .. "','" .. Nom .. "', '" .. tonumber(type) .. "')", {}, function()
                    TriggerClientEvent("core:PopUp", xPlayer.source, {message = "- ~r~Action Clé~s~\n- Type : ~y~Ramasser~s~\n- Nouvelle : ~b~" .. Plaque})
                end)
				print("^0[^9Clé system^0] Pickup N° [^1" .. PickupId .. "^0] pris par : ^1" .. xPlayer.identifier .. "^0 (^1" .. "Clé" .. "^0 ^3" .. Plaque .. "^0 - Type : Clé)")
			CCarrer = false
		end
	end
end)