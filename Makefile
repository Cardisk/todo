.PHONY : build run clean

files = src/*.swift

build: $(files)
	@mkdir -p build
	swiftc -I./src/ -o build/todo $(files) 

run: build
	@build/todo

clean:
	-rm -rf build
