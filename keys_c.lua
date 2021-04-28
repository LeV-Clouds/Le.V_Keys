ESX = nil 

Citizen.CreateThread(function()
    while ESX == nil do
        TriggerEvent('esx:getSharedObject', function(obj)
            ESX = obj
        end)
        Citizen.Wait(0)
    end
    ESX.PlayerData = ESX.GetPlayerData()
end)

local Option = ""
local PlayerLoaded  = false
local IsOpen = false
local CleListeCall

local MenuCle = RageUI.CreateMenu("Gestion de clé", "Liste")
      MenuCle:SetRectangleBanner(15, 15, 15, 200)
local ItemListe = {"Donner", "Prêter", "Renommer", "Jeter"}
local Action = {Cle = 1, Input = ""}

RegisterNetEvent("esx:playerLoaded")
AddEventHandler("esx:playerLoaded", function(xPlayer)
    PlayerLoaded = true
end)

MenuOption = function()
    if IsOpen then
        RageUI.CloseAll()
        IsOpen = false
        return
    else
        IsOpen = true 
        RageUI.Visible(MenuCle, true)
        Citizen.CreateThread(function()
            while IsOpen do
                RageUI.IsVisible(MenuCle, function()
                    if CleListeCall then
                        for k,v in pairs(CleListeCall) do 
                            if v.type == 0 then
                                Option  = "~g~Propriétaire"
                            else 
                                Option  = "~r~Double de clé"
                            end
                            RageUI.List("Clé - ~y~" .. v.plate .. "~s~ | ~b~" .. v.nom, ItemListe, Action.Cle, " Type : " .. Option, {}, true, {
                                onListChange = function(Index, Item)
                                    Action.Cle = Index;
                                end,
                                onSelected = function(Index)
                                    if Index == 1 then -- Donner
                                        local player, distance = ESX.Game.GetClosestPlayer()
                                        if distance ~= -1 and distance <= 3 then
                                            TriggerServerEvent("core:ActionCle", GetPlayerServerId(player), v.plate, v.nom, "Donner", v.id, v.type)  
                                            RefreshListeKeys()  
                                        else 
                                            Visual.Popup({message = "Aucun ~b~individus~s~ à proximiter."})  
                                        end
                                    elseif Index == 2 then -- Prêter
                                        local player, distance = ESX.Game.GetClosestPlayer()
                                        if distance ~= -1 and distance <= 3 then
                                            TriggerServerEvent("core:ActionCle", GetPlayerServerId(player), v.plate, v.nom, "Prêter", v.id, v.type) 
                                            RefreshListeKeys()  
                                        else 
                                           Visual.Popup({message = "Aucun ~b~individus~s~ à proximiter."})  
                                        end 
                                    elseif Index == 3 then -- Renommer
                                        Action.Input = KeyboardInput("Nouveau Surnom : ", "", 15)
                                        TriggerServerEvent("core:ActionCle", GetPlayerServerId(PlayerId()), "", Action.Input, "Renommer", v.id, v.type)  
                                        RefreshListeKeys()
                                    elseif Index == 4 then -- Jeter
                                        TriggerServerEvent("core:ActionCle", GetPlayerServerId(PlayerId()), v.plate, v.nom, "Jeter", v.id, v.type)  
                                        RefreshListeKeys()
                                    end
                                end
                            })
                        end
                    end
                end)
                Wait(1)
            end
        end)
    end
end



Keys.Register("E", "E", "Menu Option", function() -- Ouvrir le menu
    RageUI.CloseAll()
    MenuOption()
    RefreshListeKeys()
end)

Keys.Register("U", "U", "Intéraction Veh", function() -- Touche pour action sur Veh
    if not IsPedSittingInAnyVehicle(PlayerPedId()) then
        OuvrirVeh()
    else 
        Visual.Popup({message = "- ~r~Erreur~s~\n- ~g~Action impossible~s~."})  
    end
end)

RegisterCommand("GiveKey", function()
    TriggerServerEvent("core:GiveCleOfVehicle", GetPlayerServerId(PlayerId()), "1234", "Le.V", 0)
 end)

OuvrirVeh = function()
    local playerPed = PlayerPedId()
	local coords    = GetEntityCoords(playerPed, true)

	local vehicle = nil

	if IsPedInAnyVehicle(playerPed,  false) then
		vehicle = GetVehiclePedIsIn(playerPed, false)
	else
		vehicle = GetClosestVehicle(coords.x, coords.y, coords.z, 7.0, 0, 71)
	end

   ESX.TriggerServerCallback("core:GetPlateOfKey", function(NValide)
        if NValide then
            Visual.Popup({message = "- ~r~Erreur~s~\n- ~g~Non - reconnus~s~."})  
        else 
            local dict = "anim@mp_player_intmenu@key_fob@"

        RequestAnimDict(dict)

        while not HasAnimDictLoaded(dict) do
            Citizen.Wait(0)
        end	

        CleVeh = CreateObject(GetHashKey("prop_cuff_keys_01"), 0, 0, 0, true, true, true)
        AttachEntityToEntity(vehicleKeys, PlayerPedId(), GetPedBoneIndex(PlayerPedId(), 57005), 0.11, 0.03, -0.03, 90.0, 0.0, 0.0, true, true, false, true, 1, true) 
        TaskPlayAnim(PlayerPedId(), dict, "fob_click_fp", 8.0, 8.0, -1, 48, 1, false, false, false)
        local Fermeture = GetVehicleDoorLockStatus(vehicle)
        if Fermeture == 1 or Fermeture == 0 then -- Si Ouvert
            SetVehicleDoorsLocked(vehicle, 2)
            PlayVehicleDoorCloseSound(vehicle, 1)
                Visual.Popup({message = "- ~y~Véhicule~s~\n- ~r~Fermé~s~."})  
        elseif Fermeture == 2 then -- Si Fermer 
            SetVehicleDoorsLocked(vehicle, 1)
            PlayVehicleDoorOpenSound(vehicle, 0)
            Visual.Popup({message = "- ~y~Véhicule~s~\n- ~g~Ouvert~s~."})  
        end
        StopAnimTask = true

        Wait(1000)

        DeleteEntity(CleVeh)
        end
   end, GetVehicleNumberPlateText(vehicle))
end 

RefreshListeKeys = function()
    ESX.TriggerServerCallback("core:GetCle", function(CleListe)
        CleListeCall = CleListe
    end)
end