# Find all assembly source files in src/impl/x86_64 directory
x86_64_asm_source_files := $(shell find src/impl/x86_64 -name "*.asm")

# Convert source file paths (src/impl/x86_64/file.asm) into object file paths (build/x86_64/file.o)
x86_64_asm_object_files := $(patsubst src/impl/x86_64/%.asm, build/x86_64/%.o, $(x86_64_asm_source_files))

# Rule to compile each assembly source file into an object file
$(x86_64_asm_object_files): build/x86_64/%.o : src/impl/x86_64/%.asm
	# Create the output directory if it doesn't exist
	mkdir -p $(dir $@)
	# Assemble the .asm file into an ELF64 object file
	nasm -f elf64 $< -o $@

# Declare "build-x86_64" as a phony target (not an actual file)
.PHONY: build-x86_64

# Rule to build the x86_64 kernel
build-x86_64: $(x86_64_asm_object_files)
	# Ensure the dist directory exists
	mkdir -p dist/x86_64
	# Link all compiled object files into a kernel binary
	x86_64-elf-ld -n -o dist/x86_64/kernel.bin -T targets/x86_64/linked.ld $(x86_64_asm_object_files)
	# Copy the compiled kernel binary to the GRUB bootable ISO directory
	cp dist/x86_64/kernel.bin targets/x86_64/iso/boot/kernel.bin
	# Create a bootable ISO using GRUB2
	grub-mkrescue -o dist/x86_64/kernel.iso targets/x86_64/iso
