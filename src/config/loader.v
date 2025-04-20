module config

import os
import json


pub struct Config {
pub mut:
	// The host key for game authentication
	host_key string

	// The game ID
	game_id int

	// The port the server will listen on
	port int = 42480

	// If the server is local or not
	local bool = true

	// Map directory
	map_dir string = 'maps/'

	// Map name
	map_name string = 'example.brk'
}


// Load the config from a JSON file
pub fn load_config() ?Config {
	mut settings := Config{}
	if os.exists('config.json') {
		config_file := os.read_file('config.json') or { panic(err) }
		settings = json.decode(Config, config_file) or { panic(err) }

		println('Config file loaded successfully.')
	} else {
		println('[WARNING]: No config file found. Using default values.')
	}
	return settings
}