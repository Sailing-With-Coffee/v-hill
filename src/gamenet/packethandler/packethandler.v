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
	
	println('Packet type: ${packet_type}')
}