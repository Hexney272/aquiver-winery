fx_version 'adamant'

game 'gta5'

version "1.0.2"

lua54 "yes"

escrow_ignore {
    "lua/**",
    "bridge/**",
    "inventory/**"
}

files {
    "txd/**",
    "images/**",
    "locales/*.json",
    "lua/client/**.lua",
    "lua/shared/**.lua",
    "html/**"
}

client_scripts {
    "@aquiver_cfx/client/Graphics.lua",
    "@aquiver_cfx/client/GameplayCamera.lua",
    "@aquiver_cfx/client/DrawSpriteMeter.lua",
    "@aquiver_cfx/client/DrawSpriteMeter3D.lua",

    "lua/client/main.lua"
}

server_scripts {
    "lua/server/main.lua",

    "bridge/*.lua"
}

shared_scripts {
    '@ox_lib/init.lua',
}

dependencies {
    "aquiver_cfx",
    "aquiver-winery-props",
    "aquiver-winery-mlo",
    "aquiver-winery-sounds"
}

ui_page 'html/index.html'


--[[
1.0.1:
- Added missing .sql file in the script resource folder
- Fixed the escrow issue in the `inventory` folder.
- Added new localization `fr.json` (Thanks to @680137258564583502)
- Removed unneccesary development commands

1.0.2:
- Removed the unfinished lobby system from the code.
- Wooden Barrel & Barrel was not properly checked the warehouse inventory before inserting, so players could create more than what they had in their storage. Now it checks and removes the quantity from the WarehouseStorage.
- Added some missing locale key(s)
- The quantity of the tool was incorrectly displayed in the building menu

]]

dependency '/assetpacks'