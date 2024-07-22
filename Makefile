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
	@echo "Installation for MacOS is not implemented yet."
endif

ifeq ($(uname),Linux)
	@echo "Installation for Linux is not implemented yet."
endif

clean:
	-rm -rf build
