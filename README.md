# HyperionOS

**HyperionOS** is a modular, Unix-like (almost) operating system environment written entirely in Lua. It features a microkernel-inspired architecture with a robust system call (syscall) interface, a virtual file system (VFS), and a custom hypervisor for managing isolated tasks.



## Key Features

* **Modular Kernel:** Functionality is distributed across discrete kernel modules (`.kmod`), including IO, VFS, IPC, and TTY, allowing for a highly extensible system.

* **Hypervisor & Task Management:** A custom hypervisor manages threads in a task-based architecture.

---

## Build requirements
* **Source:** None it builds directly in vs-code, altough it is the biggest build method it gives the most readability 

## Contributing
