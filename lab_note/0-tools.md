# Tools准备
先安装VirtualBox与Ubuntu,我使用的版本是VirtualBox6.1.40 与 Ubuntu22.04。

## 验证编译器工具链
```
% objdump -i
% gcc -m32 -print-libgcc-file-name
```

## 安装QEMU
```language
git clone https://github.com/mit-pdos/6.828-qemu.git qemu
//安装网页上需要的包。
./configure --disable-kvm --disable-werror --target-list="i386-softmmu x86_64-softmmu"
sudo make
sudo make install
```

### 安装工具报错时参考的博客
[MIT6.828 实验环境配置](https://blog.csdn.net/qq_43012789/article/details/106343268)
[ubuntu22.04包依赖关系](https://blog.csdn.net/lishuaigell/article/details/124740342)

一定不要听某些博客的将python卸载了，如果没备份的话，你会很难受！！

这是调试程序相关的课程ppt
[lab ppt GDB教学](https://pdos.csail.mit.edu/6.828/2018/lec/gdb_slides.pdf)


做完lab会发现： JOS是微内核。