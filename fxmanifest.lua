fx_version 'cerulean'
games { 'gta5' };

name 'RageUI';
description 'Script'

client_scripts { -- Lib RageUI
    "Rui/RMenu.lua",
    "Rui/menu/RageUI.lua",
    "Rui/menu/Menu.lua",
    "Rui/menu/MenuController.lua",
    "Rui/components/*.lua",
    "Rui/menu/elements/*.lua",
    "Rui/menu/items/*.lua",
    "Rui/menu/panels/*.lua",
    "Rui/menu/windows/*.lua",
}

client_scripts {
    'utils.lua',
    'keys_c.lua',
}

server_scripts {
    "@mysql-async/lib/MySQL.lua",
    'keys_s.lua',
}
