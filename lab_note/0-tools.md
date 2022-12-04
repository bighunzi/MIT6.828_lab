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
sudo make install

## 安装工具报错时参考的几个网址
https://felord.blog.csdn.net/article/details/104917602
https://blog.csdn.net/qq_43012789/article/details/106343268
https://blog.csdn.net/lishuaigell/article/details/124740342