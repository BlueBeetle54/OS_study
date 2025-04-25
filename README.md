# OS_study
OS study project

nasm -o bootLoader.img bootLoader.asm
qemu-system-x86_64 -L . -m 64 -fda bootLoader.img -M pc