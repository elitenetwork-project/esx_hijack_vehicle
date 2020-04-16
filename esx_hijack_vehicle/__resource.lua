description 'Hijack Vehicle'

server_scripts {
    '@mysql-async/lib/MySQL.lua',
    '@es_extended/locale.lua',
    'server/server.lua',
    'locales/fr.lua',
	'locales/en.lua',
	'locales/it.lua',
    'config.lua'
}

client_scripts {
    '@es_extended/locale.lua',
    'client/client.lua',
    'locales/fr.lua',
	'locales/en.lua',
	'locales/it.lua',
    'config.lua'
}