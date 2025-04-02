module packethandler


import net
import io


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
		println('Invalid packet type: ${packet_data[0]}')
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
	println('Token: ${token.bytestr()}')
	println('Version: ${version.bytestr()}')
}