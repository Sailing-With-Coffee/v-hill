module main

import io
import compress.zlib
import net
import config
import gamenet.uintv
import gamenet.packethandler
import players


/*

rn this is just to test shit, havent started really making this a usable codebase as im learning

*/


fn main() {
	game_info := config.load_config() or { panic("[ERROR]: Failed to retrieve config") }
	mut bind_addr := '0.0.0.0:${game_info.port}'

	println('Listening on port ${game_info.port}.')

	if game_info.local {
		bind_addr = '127.0.0.1:${game_info.port}'
		println('Running server locally.')
	}


	mut server := net.listen_tcp(.ip, bind_addr)!
	addr := server.addr()!
	
	
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
		packethandler.handle_packet(mut socket, buffer)
	}
}