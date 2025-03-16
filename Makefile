# Gathering Kernel source files
kernel_source_files := $(shell find src/impl/kernel -name "*.c")
kernel_object_files := $(patsubst src/impl/kernel/%.c, build/kernel/%.o, $(kernel_source_files))

# Gathering x86_64 C source files
x86_64_c_source_files := $(shell find src/impl/x86_64 -name "*.c")
x86_64_c_object_files := $(patsubst src/impl/x86_64/%.c, build/x86_64/%.o, $(x86_64_c_source_files))

# Gathering x86_64 Assembly source files
x86_64_asm_source_files := $(shell find src/impl/x86_64 -name "*.asm")
x86_64_asm_object_files := $(patsubst src/impl/x86_64/%.asm, build/x86_64/%.o, $(x86_64_asm_source_files))

# All x86_64 object files
x86_64_object_files := $(x86_64_c_object_files) $(x86_64_asm_object_files)

# Marking build-x86_64 as a phony target
.PHONY: build-x86_64

# Rule to compile each C source file in x86_64
build/x86_64/%.o: src/impl/x86_64/%.c
	@mkdir -p $(dir $@)
	x86_64-elf-gcc -c -I src/intf -ffreestanding $< -o $@

# Rule to compile each Kernel source file
build/kernel/%.o: src/impl/kernel/%.c
	@mkdir -p $(dir $@)
	x86_64-elf-gcc -c -I src/intf -ffreestanding $< -o $@

# Rule to assemble each assembly source file
build/x86_64/%.o: src/impl/x86_64/%.asm
	@mkdir -p $(dir $@)
	nasm -f elf64 $< -o $@

# Rule to build the x86_64 kernel
build-x86_64: $(kernel_object_files) $(x86_64_object_files)
	@echo "Building kernel..."
	mkdir -p dist/x86_64
	x86_64-elf-ld -n -o dist/x86_64/kernel.bin -T targets/x86_64/linked.ld $(kernel_object_files) $(x86_64_object_files)
	cp dist/x86_64/kernel.bin targets/x86_64/iso/boot/kernel.bin
	grub-mkrescue -o dist/x86_64/kernel.iso targets/x86_64/iso
