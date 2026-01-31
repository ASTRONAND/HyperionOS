# HyperionOS

**HyperionOS** is a modular operating system environment written entirely in Lua. It features a microkernel-inspired architecture with a robust system call (syscall) interface, and a virtual file system (VFS).

## Key Features
* **Modular Kernel:** Functionality is distributed across discrete kernel modules (`.kmod`), including IO, VFS, IPC, and TTY, allowing for a highly extensible system.

* **Hypervisor & Task Management:** A custom hypervisor manages threads in a task-based architecture.

---

## Build requirements
* **Source:** None it builds directly in vs-code, altough it is the biggest build method it gives the most readability

* **Minifyed:** You need node.js and luamin

---

## Contributing
* **Credit:** if you contributed feel free to add your name to contributors.md

---

## Rules/guidelines
* **AI:** AI **stays out of the kernel** you may use AI to create tests and for debugging. if it is not important you may use AI.
