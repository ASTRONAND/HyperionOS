# boot.cfg docs

The /boot/boot.cfg file contains configs for booting

```
initPath<String>
    path that init takes to load the init system (systemd)

allowGloabalOverwrites<bool>
    allow modifying of gloabal env (usually for debug purposes)

enableAdvanacedDebug<bool>
    allow debug into the kernel

maxOpenFiles<num>
    maximum open files for the whole system

maxFilesPerTask<num>
    maximum open files for each task

preempt<bool>
    enable/disable preemptive multitasking

debugSyscalls<bool>
    logs syscalls and thier return values aswell as what task executed them

logTaskExit<bool>
    logs task exits and errors
```