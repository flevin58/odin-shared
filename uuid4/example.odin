package main

import "core:fmt"
import "shared:uuid4"

main :: proc() {
	buf: [uuid4.LEN]u8
	uuid4.init()
	uuid4.generate(transmute(cstring)&buf)
	fmt.println("uuid4:", string(buf[:]))
}
