# Tools准备
先安装VirtualBox与Ubuntu,本人使用的版本是VirtualBox6.1.40 与 Ubuntu22.04。

## 然后验证编译器工具链
% objdump -i
% gcc -m32 -print-libgcc-file-name

## 安装QEMU
git clone https://github.com/mit-pdos/6.828-qemu.git qemu
安装网页上需要的包
./configure --disable-kvm --disable-werror --target-list="i386-softmmu x86_64-softmmu"
sudo make
