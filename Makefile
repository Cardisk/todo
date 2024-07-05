.PHONY : build run clean

files = src/main.swift

build: $(files)
	@mkdir -p build
	swiftc -o build/todo src/main.swift

run: build
	@build/todo

clean:
	-rm -rf build
