module packethandler


import net
import io
import config
import players


__global connected_players = []players.Player{}


enum ClientPacketType as u8 {
	authentication = 1
	position
	command
	projectile
	click_detection
	player_input
	heartbeat = 18
}



pub fn handle_packet(mut socket net.TcpConn, packet_data []u8) {
	packet_type := ClientPacketType.from(packet_data[0]) or {
		println('[WARNING]: Invalid packet type: ${packet_data[0]}')
		return
	}

	client_addr := socket.peer_addr() or { return }
	data := packet_data[1..]
	
	match packet_type {
		.authentication {
			println('<Client: ${client_addr}>: Attempting authentication.')
			handle_authentication(mut socket, data)
		}
		else {}
	}
}



fn handle_authentication(mut socket net.TcpConn, data []u8) {
	// This packet is simple as it only has two null-terminated strings so you just need to read until the null terminator for each string
	mut token := []u8{}
	mut version := []u8{}

	for i in 0 .. data.len {
		if data[i] == 0 {
			token = data[..i]
			version = data[i+1..]
			break
		}
	}

	// Remove the null terminator from the version
	for i in 0 .. version.len {
		if version[i] == 0 {
			version = version[..i]
			break
		}
	}

	// Print the token and version as strings
	println('[DEBUG]: Token: ${token.bytestr()}')
	println('[DEBUG]: Version: ${version.bytestr()}')

	// Check if the token is valid
	game_info := config.get_config()
	if game_info.local {
		// Check if the token is 'local'
		if token.bytestr() != 'local' {
			println('[WARNING]: Invalid token.')
			socket.close() or { panic(err) }
			return
		}

		// User is authenticated, create a new player and add them to the connected players list
		mut new_net_id := connected_players.len + 1
		mut player := players.Player.new(new_net_id, socket)

		player.username = 'Player${new_net_id}'
		player.user_id = new_net_id
		player.admin = false
		player.position = [0.0, 0.0, 0.0]
		player.rotation = [0.0, 0.0, 0.0]
		player.scale = [1.0, 1.0, 1.0]

		connected_players << player

		println('Successfully verified! (Username: ${player.username} | ID: ${player.user_id} | Admin: ${player.admin})')
	}else{
		// Just kick the client, we haven't implemented the auth system yet
		socket.close() or { panic(err) }
		return
	}
}