module main

import net


/*

rn this is just to test shit, havent started really making this a usable codebase as im learning

*/


fn main() {
	mut server := net.listen_tcp(.ip, '0.0.0.0:42480')!
	addr := server.addr()!
	println('Listening on ${addr}')
	for {
		mut socket := server.accept()!
		println('New client')
	}
}