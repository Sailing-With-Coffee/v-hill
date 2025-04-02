module uintv


pub fn read_uint_v(buffer []u8) ?(int, int) {
    if buffer.len == 0 {
        error('Buffer is empty')
		return none
    }

    // 1 Byte
    if buffer[0] & 1 != 0 {
        return buffer[0] >> 1, 1
    }
    // 2 Bytes
    else if buffer[0] & 2 != 0 {
        if buffer.len < 2 {
            error('Buffer too small for 2-byte read')
			return none
        }
        msg_size := ((u16(buffer[0]) | (u16(buffer[1]) << 8)) >> 2) + 0x80
        return msg_size, 2
    }
    // 3 Bytes
    else if buffer[0] & 4 != 0 {
        if buffer.len < 3 {
            error('Buffer too small for 3-byte read')
			return none
        }
        msg_size := (int(buffer[2]) << 13) + (int(buffer[1]) << 5) + (int(buffer[0]) >> 3) + 0x4080
        return msg_size, 3
    }
    // 4 Bytes
    else {
        if buffer.len < 4 {
            error('Buffer too small for 4-byte read')
			return none
        }
        msg_size := (int(buffer[0]) | (int(buffer[1]) << 8) | (int(buffer[2]) << 16) | (int(buffer[3]) << 24)) / 8 + 0x204080
        return msg_size, 4
    }
}

pub fn write_uint_v(buffer []u8) []u8 {
	mut buf := []u8
    length := buffer.len
	

    // 1 Byte
    if length < 0x80 {
        mut size := []u8{len: 1}
        size[0] = u8((length << 1) | 1)
        size << buffer

		buf << size
    }
    // 2 Bytes
    else if length < 0x4080 {
        mut size := []u8{len: 2}
        encoded_size := ((length - 0x80) << 2) | 2
        size[0] = u8(encoded_size & 0xFF)
        size[1] = u8((encoded_size >> 8) & 0xFF)
        size << buffer

		buf << size
    }
    // 3 Bytes
    else if length < 0x204080 {
        mut size := []u8{len: 3}
        write_value := ((length - 0x4080) << 3) | 4
        size[0] = u8(write_value & 0xFF)
        size[1] = u8((write_value >> 8) & 0xFF)
        size[2] = u8((write_value >> 16) & 0xFF)
        size << buffer

		buf << size
    }
    // 4 Bytes
    else {
        mut size := []u8{len: 4}
        encoded_size := (length - 0x204080) * 8
        size[0] = u8(encoded_size & 0xFF)
        size[1] = u8((encoded_size >> 8) & 0xFF)
        size[2] = u8((encoded_size >> 16) & 0xFF)
        size[3] = u8((encoded_size >> 24) & 0xFF)
        size << buffer

		buf << size
    }

	return buf
}