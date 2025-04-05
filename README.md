# NilOS - A Minimal Operating System

Welcome to **NilOS**, a lightweight operating system built from scratch.

## Project Structure

- `kernel/` - The heart of the OS, with boot code, terminal output, and kernel logic.
- `libc/` - A minimal C library (`libk`) for the kernel, plus a placeholder for a full `libc`.
- `sysroot/` - A temporary root filesystem populated during the build.
- Build scripts (`*.sh`) - Tools to compile, clean, and create a bootable ISO.

## Prerequisites

To build and run NilOS, you’ll need a Unix-like system (Linux is ideal). Windows users can try WSL or Cygwin. Here’s what is needed:

### Software Dependencies
- **GCC Cross-Compiler (i686-elf)** - For compiling the kernel and libraries.
- **GRUB** - Provides `grub-mkrescue` to create the bootable ISO (install `grub-pc-bin` on Debian-based systems).
- **Xorriso** - Used by `grub-mkrescue` to build the ISO image.
- **GNU Make (4.0+)** - Manages the build process for the kernel and libraries.
- **QEMU** - For testing the OS in a virtual machine (e.g., `qemu-system-i386`).

### Installing on Debian/Ubuntu

```sudo apt install git build-essential grub-pc-bin xorriso qemu-system-x86```

## Setting Up the Environment

### Step 1: Clone the Repository
```
git clone https://github.com/nileshgupta1/nilos.git
cd nilos
```

### Step 2: Build the Cross-Compiler
NilOS needs a cross-compiler targeting `i686-elf` to avoid mixing host system libraries. Here’s how to set it up:

1. **Install Prerequisites**:
```sudo apt install gcc g++ make bison flex libgmp3-dev libmpc-dev libmpfr-dev texinfo```
2. **Download Binutils and GCC**:
```
wget https://ftp.gnu.org/gnu/binutils/binutils-2.41.tar.gz
wget https://ftp.gnu.org/gnu/gcc/gcc-13.2.0/gcc-13.2.0.tar.gz
tar -xzf binutils-2.41.tar.gz
tar -xzf gcc-13.2.0.tar.gz
```
3. **Build Binutils**:
```
mkdir build-binutils
cd build-binutils
../binutils-2.41/configure --target=i686-elf --prefix=/usr/local --with-sysroot --disable-nls
make -j$(nproc)
sudo make install
cd ..
```

4. **Build GCC**:
```
mkdir build-gcc
cd build-gcc
../gcc-13.2.0/configure --target=i686-elf --prefix=/usr/local --disable-nls --enable-languages=c --without-headers
make all-gcc -j$(nproc)
make all-target-libgcc -j$(nproc)
sudo make install-gcc
sudo make install-target-libgcc
cd ..
```

5. **Add to PATH**:
Edit your `~/.bashrc` or equivalent:
```export PATH="/usr/local/bin:$PATH"```
Then reload it:
```source ~/.bashrc```


### Step 3: Verify the Cross-Compiler
```
i686-elf-gcc --version
i686-elf-ld --version
```
## Building and Running NilOS

The project uses shell scripts to build and test the OS. Run them in this order:

### 1. Make Scripts Executable
```chmod +x *.sh```

### 2. Install Headers (`headers.sh`)
```./headers.sh```
- Copies kernel and library headers into `sysroot/usr/include/`. Preps the sysroot for compilation without building the whole OS yet.

### 3. Build the OS (`build.sh`)
```./build.sh```
- Compiles the kernel and `libk`, then installs them into `sysroot/`. You’ll see `nilos.kernel` in `sysroot/boot/` and `libk.a` in `sysroot/usr/lib/`.

### 4. Create the ISO (`iso.sh`)
```./iso.sh```
- Builds a bootable ISO image (`nilos.iso`) by copying `nilos.kernel` to `isodir/boot/` and adding a GRUB config. Calls `build.sh` internally, so you could skip step 3 if you’re just making the ISO.

### 5. Test in QEMU (`qemu.sh`)
```./qemu.sh```
- Launches QEMU with `nilos.iso` as a CD-ROM. You’ll see GRUB load, then "Hello, kernel World!" on a black screen. Calls `iso.sh` first, so this is a one-step build-and-run option.

### 6. Clean Up (`clean.sh`)
```./clean.sh```

- Removes all build artifacts (`sysroot/`, `isodir/`, `myos.iso`, object files) to start fresh.

## What to Expect
After running `qemu.sh`, QEMU boots the ISO:
- GRUB shows a simple menu with "nilos".
- The kernel loads at 1 MiB (0x100000), clears the screen, and prints "Hello, kernel World!" in light grey.
- It then halts, leaving the message on-screen.
