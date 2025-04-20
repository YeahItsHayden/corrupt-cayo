fx_version 'adamant'
game 'gta5'
lua54 'yes'
author 'CorruptCode'

shared_scripts {
    '@ox_lib/init.lua',
    'config/sh_*.lua',
}

server_scripts {
    'config/sv_*.lua',
    'server/sv_functions.lua',
    'server/*.lua',
}

client_scripts {
    'config/cl_*.lua',
    'client/cl_functions.lua',
    'client/*.lua',
}