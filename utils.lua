RegisterCommand("GiveKey", function()
   TriggerServerEvent("core:GiveCleOfVehicle", GetPlayerServerId(PlayerId()), "1234", "Le.V", 0)
end)

KeyboardInput = function(TextEntry, ExampleText, MaxStringLength)
    AddTextEntry('FMMC_KEY_TIP1', TextEntry .. '')
    DisplayOnscreenKeyboard(1, "FMMC_KEY_TIP1", "", ExampleText, "", "", "", MaxStringLength)
    blockinput = true
    while UpdateOnscreenKeyboard() ~= 1 and UpdateOnscreenKeyboard() ~= 2 do
        Citizen.Wait(0)
    end
    if UpdateOnscreenKeyboard() ~= 2 then
        local result = GetOnscreenKeyboardResult()
        Citizen.Wait(500)
        blockinput = false
        return result
    else
        Citizen.Wait(500)
        blockinput = false
        return nil
    end
end

vFw = {}
vFw.Game = {}
vFw.Streaming  = {}
vFw.Game.Utils = {}

vFw.Streaming.RequestModel = function(modelHash, cb)
	modelHash = (type(modelHash) == 'number' and modelHash or GetHashKey(modelHash))

	if not HasModelLoaded(modelHash) and IsModelInCdimage(modelHash) then
		RequestModel(modelHash)

		while not HasModelLoaded(modelHash) do
			Citizen.Wait(1)
		end
	end

	if cb ~= nil then
		cb()
	end
end

vFw.Game.SpawnLocalObject = function(model, coords, cb)
	local model = (type(model) == 'number' and model or GetHashKey(model))

	Citizen.CreateThread(function()
		vFw.Streaming.RequestModel(model)

		local obj = CreateObject(model, coords.x, coords.y, coords.z, false, false, true)

		if cb then
			cb(obj)
		end
	end)
end


vFw.Game.Utils.DrawText3D = function(coords, text, size, font)
	coords = vector3(coords.x, coords.y, coords.z)

	local camCoords = GetGameplayCamCoords()
	local distance = #(coords - camCoords)

	if not size then size = 1 end
	if not font then font = 0 end

	local scale = (size / distance) * 2
	local fov = (1 / GetGameplayCamFov()) * 100
	scale = scale * fov

	SetTextScale(0.0 * scale, 0.55 * scale)
	SetTextFont(4)
	SetTextColour(255, 255, 255, 255)
	SetTextOutline()
	SetTextCentre(true)

	SetDrawOrigin(coords, 0)
	BeginTextCommandDisplayText('STRING')
	AddTextComponentSubstringPlayerName(text)
	EndTextCommandDisplayText(0.0, 0.0)
	ClearDrawOrigin()
end

vFw.Streaming.RequestAnimDict = function(animDict, cb)
	if not HasAnimDictLoaded(animDict) then
		RequestAnimDict(animDict)

		while not HasAnimDictLoaded(animDict) do
			Citizen.Wait(1)
		end
	end

	if cb ~= nil then
		cb()
	end
end

local pickups = {}
local OnPickup 

vFw.Game.DeleteObject = function(object)
	SetEntityAsMissionEntity(object, false, true)
	DeleteObject(object)
end


RegisterNetEvent('core:CreationPickup') -- Pickup (Argent, Items, Armes)
AddEventHandler('core:CreationPickup', function(pickupId, label, playerId, plaque, nom, type)

    local playerPed = GetPlayerPed(GetPlayerFromServerId(playerId))
    local entityCoords, forward, pickupObject = GetEntityCoords(playerPed), GetEntityForwardVector(playerPed)
    local objectCoords = (entityCoords + forward * 0.6)
    local DistandSleep = true 
    
        vFw.Game.SpawnLocalObject('prop_cuff_keys_01', objectCoords, function(obj)
            pickupObject = obj
        end)

	while not pickupObject do
		Citizen.Wait(10)
	end

	SetEntityAsMissionEntity(pickupObject, true, false)
	PlaceObjectOnGroundProperly(pickupObject)
	FreezeEntityPosition(pickupObject, true)

	pickups[pickupId] = {id = pickupId, pickupObject = pickupObject, label = label, inRange = false, coords = objectCoords, plaque = plaque, nom = nom , type = type }

	Citizen.CreateThread(function()
		while true do
			Wait(0)
			for k,v in pairs(pickups) do
				local distance = #(entityCoords - v.coords)

				if distance < 4 then
					local dist = Vdist2(GetEntityCoords(GetPlayerPed(-1)), v.coords)
					if dist < 2 then
						DistandSleep = false 
						if IsControlJustReleased(0, 38) then
							DisableControlAction(0, 51, true)
							if IsPedOnFoot(playerPed) and not v.inRange then
								v.inRange = true
								local dict, anim = "pickup_object"
								vFw.Streaming.RequestAnimDict(dict)
								TaskPlayAnim(GetPlayerPed(-1), dict, "pickup_low", 8.0, 8.0, -1, 0, 1, false, false, false)
								Citizen.Wait(1000)
							    TriggerServerEvent("core:OnPickupCle", GetPlayerServerId(PlayerId()), v.plaque, v.nom, v.type, pickupId)
								DisableControlAction(0, 51, false)
							end
						end
						vFw.Game.Utils.DrawText3D({
							x = v.coords.x,
							y = v.coords.y,
							z = v.coords.z - 0.63
						}, v.label, 0.6, 1)
					end
				elseif v.inRange then
					v.inRange = false
				end
			end
			if DistandSleep then
				Citizen.Wait(500)
			end
		end 
	end)
end)

RegisterNetEvent('core:RemovePickup')
AddEventHandler('core:RemovePickup', function(pickupId)
	vFw.Game.DeleteObject(pickups[pickupId].pickupObject)
	pickups[pickupId] = nil
end)
