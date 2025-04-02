module main

import io
import compress.zlib
import net
import gamenet.uintv
import gamenet.packethandler


/*

rn this is just to test shit, havent started really making this a usable codebase as im learning

*/


fn main() {
	mut server := net.listen_tcp(.ip, '0.0.0.0:42480')!
	addr := server.addr()!
	println('Listening on port 42480.')
	println('Running server locally.')
	// TODO: Implement settings
	for {
		mut socket := server.accept()!
		spawn handle_client(mut socket)
	}
}


fn handle_client(mut socket net.TcpConn) {
	defer {
		socket.close() or { panic(err) }
	}

	client_addr := socket.peer_addr() or { return }
	println('<New client: ${client_addr}>')

	mut reader := io.new_buffered_reader(reader: socket)
	defer {
		unsafe {
			reader.free()
		}
	}

	for {
		mut available_data := []u8{len: 4096}
		len := reader.read(mut available_data) or { return }
		received_size, end := uintv.read_uint_v(available_data) or { return }
		available_data = available_data[end..len]

		mut buffer := zlib.decompress(available_data) or { available_data }
		
		println('<${client_addr}>: ${len} bytes')
		println('<${client_addr}>: received_size ${received_size} bytes')
		println('<${client_addr}>: end ${end} bytes')

		println('<${client_addr}>: packet_data: ${buffer}')
		packethandler.handle_packet(mut socket, buffer)
	}
}