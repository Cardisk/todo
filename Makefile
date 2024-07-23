.PHONY : build install clean

files = src/*.swift

build: $(files)
	@mkdir -p build
	swiftc -I./src/ -o build/todo $(files) 

install: build
ifeq ($(OS),Windows_NT)
	@echo "Installation for Windows is not implemented yet."
else
	@echo "Build finished, installing into: /usr/local/bin"
	@cp build/todo /usr/local/bin/todo
	@echo "Installation finished."
endif

uninstall:
ifeq ($(OS),Windows_NT)
	@echo "Uninstall command for Windows is not implemented yet."
else
	@echo "Removing /usr/local/bin/todo"
	@rm /usr/local/bin/todo
	@echo "Removal finished."
endif

clean:
	-rm -rf build
