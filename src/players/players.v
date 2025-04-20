module players


import net


struct Player {
	avatar_loaded bool
	admin bool
	alive bool
	assets []int
	authenticated bool
	blocked_users []int
	camera_distance f32
	camera_fov f32
	camera_object &Player
	camera_position []f32
	camera_rotation []f32
	camera_type int
	chat_color string
	client int
	colors []string
	destroyed bool
	health int
	inventory []int
	jump_power int
	load_avatar bool
	load_tool bool
	max_health int
	membership_type int
	muted bool
	net_id int
	position []f32
	rotation []f32
	scale []f32
	score int
	socket net.TcpConn
	speech string
	speed int
	user_id int
	username string
	validation_token string
}