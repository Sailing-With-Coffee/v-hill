module players


import net


pub struct Player {
	net_id int
	socket net.TcpConn
pub mut:
	admin bool
	avatar_loaded bool
	alive bool
	assets []int
	authenticated bool
	blocked_users []int
	camera_distance int = 5
	camera_fov int = 60
	camera_object int
	camera_position []f64
	camera_rotation []f64
	camera_type int
	chat_color string
	colors []string = ["#d9bc00", "#d9bc00", "#d9bc00", "#d9bc00", "#d9bc00", "#d9bc00"]
	destroyed bool
	health int = 100
	inventory []int
	jump_power int = 5
	load_avatar bool = true
	load_tool bool = true
	max_health int = 100
	membership_type int
	muted bool
	position []f64
	rotation []f64
	scale []f64
	score int
	speech string
	speed int = 4
	user_id int
	username string
}


pub fn Player.new(net_id int, socket net.TcpConn) Player {
	return Player{
		socket: socket
		net_id: net_id		
	}
}

pub fn (p Player) get_net_id() int {
	return p.net_id
}