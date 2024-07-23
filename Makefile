.PHONY : build install clean

files = src/*.swift
uname := $(shell uname)

build: $(files)
	@mkdir -p build
	swiftc -I./src/ -o build/todo $(files) 

install: build
ifeq ($(OS),Windows_NT)
	@echo "Installation for Windows is not implemented yet."
endif

ifeq ($(uname),Darwin)
	@echo "Build finished, installing into: /usr/local/bin"
	@cp build/todo /usr/local/bin/todo
	@echo "Installation finished."
endif

ifeq ($(uname),Linux)
	@echo "Installation for Linux is not implemented yet."
endif

uninstall:
ifeq ($(OS),Windows_NT)
	@echo "Uninstall command for Windows is not implemented yet."
endif

ifeq ($(uname),Darwin)
	@echo "Removing /usr/local/bin/todo"
	@rm /usr/local/bin/todo
	@echo "Removal finished."
endif

ifeq ($(uname),Linux)
	@echo "Uninstall command for Linux is not implemented yet."
endif

clean:
	-rm -rf build
