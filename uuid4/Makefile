.DEFAULT_GOAL: all
.PHONY: all
.SILENT: all

all:
	echo "Cloning the uuid4 repository"
	rm -rf original
	git clone https://github.com/rxi/uuid4.git original 2>/dev/null
	echo "Creating the target folder"
	rm -rf target
	mkdir target
	echo "Building the library"
	$(CC) -c -o target/uuid4.o original/src/uuid4.c
	$(AR) rcs target/libuuid4.a target/uuid4.o
	rm target/uuid4.o
	echo "Generating bindings"
	$(OBINDGEN) bindgen.sjson
	echo "Copying the library to Odin shared"
	rm -rf $(ODIN_ROOT)/shared/uuid4
	mv target $(ODIN_ROOT)/shared/uuid4