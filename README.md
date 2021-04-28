Key system with pickup so in ITEM, you can lend, give, throw, rename.

In which you will have everything when you throw it !

Trigger for give key to buy veh : TriggerServerEvent("core:GiveCleOfVehicle", GetPlayerServerId(PlayerId()), "1234", "Le.V", 0)

You want to replace this for Cardealer then : TriggerServerEvent("core:GiveCleOfVehicle", GetPlayerServerId(PlayerId()), plate, vehicle(Name), 0)
