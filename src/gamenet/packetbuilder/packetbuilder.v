module packetbuilder


import compress.zlib
import net
import io
import gamenet.uintv


enum PacketEnums as u8 {
	authentication = 1
	send_players = 3
	figure = 4
	remove_player = 5
	chat = 6
	player_modification = 7
	kill = 8
	brick = 9
	team = 10
	tool = 11
	bot = 12
	clear_map = 14
	destroy_bot = 15
	delete_brick = 16
}

pub struct PacketBuilder {
pub mut:
	// The packet type
	packet_type PacketEnums

	// The (optional) id string
	id_string string

	// The packet data
	data []u8

	// Do we compress or not
	compress bool
}


pub fn PacketBuilder.new(packet_type string, compress bool) ?PacketBuilder {
	// Convert the packet type to a PacketEnums value
	packet_type_enum := PacketEnums.from_string(packet_type) or {
		error('[ERROR]: Invalid packet type: ${packet_type} when creating packet builder.')
		return none
	}

	return PacketBuilder{
		packet_type: packet_type_enum
		compress: compress
	}
}

// Write data to the packet builder, we can choose between string, bool, float, uint8, int32 and uint32
// ALL NUMBERS (float, int32, uint32) ARE LITTLE ENDIAN
// idk if V does shit in big or little doe
pub fn (mut pb PacketBuilder) write_string(data string) {
	// Unwrap string into a []u8

	buf := data.bytes()
	pb.data << buf
	pb.data << u8(0)
}

pub fn (mut pb PacketBuilder) write_bool(value bool) {
	if value {
		pb.data << u8(1)
	} else {
		pb.data << u8(0)
	}
}

pub fn (mut pb PacketBuilder) write_float(value f32) {
	// Convert f32 into a []u8

	buf := []u8{len: 4}
	unsafe {
		*(&f32(buf.data)) = value
	}
	pb.data << buf
}

pub fn (mut pb PacketBuilder) write_u8(value u8) {
	pb.data << value
}

pub fn (mut pb PacketBuilder) write_int32(value i32) {
	// Convert i32 into a []u8

	buf := []u8{len: 4}
	unsafe {
		*(&i32(buf.data)) = value
	}
	pb.data << buf
}

pub fn (mut pb PacketBuilder) write_uint32(value u32) {
	// Convert u32 into a []u8

	buf := []u8{len: 4}
	unsafe {
		*(&u32(buf.data)) = value
	}
	pb.data << buf
}

pub fn (pb PacketBuilder) prepare_data_for_sending() []u8 {
	// First we create a data buffer
	mut packet := []u8

	// Then we write the packet ID
	packet << u8(pb.packet_type)

	// If there is an ID string, write it as a null-terminated string
	if pb.id_string != '' {
		packet << pb.id_string.bytes()
		packet << u8(0)
	}

	// Then we write the data
	packet << pb.data

	// Then we compress the data if needed
	if pb.compress {
		packet = zlib.compress(packet) or { packet }
	}

	// Then we write the UIntV 
	packet = uintv.write_uint_v(packet)

	// Then we return the packet
	return packet
}