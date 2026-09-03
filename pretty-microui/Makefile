.DEFAULT_GOAL: all
.PHONY: all
.SILENT: all

all:
	echo "Cloning the pretty microui repository"
	rm -rf original
	cd libusb
	git clone https://github.com/flevin58/Pretty_microUI_for_Odin_with_Raylib_6.git original 2>/dev/null
	echo "Copying the library to Odin shared"
	rm -rf $(ODIN_ROOT)/shared/microui
	cp -rp original/microui $(ODIN_ROOT)/shared
