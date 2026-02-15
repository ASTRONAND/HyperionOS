# HyperionOS

HyperionOS is a modular, hybrid kernel operating system written entirely in Lua. It features a custom task scheduler, virtual filesystem, syscall interface, and separates core functionality from user-space services.

---

## Features

- Functionality is split into kernel modules (`.kmod`)
- Task-based lightweight thread/task preemptive scheduler with process isolation and IPC support
- Virtual filesystem unified interface for disk, RAM, and virtual filesystems
- TTY & Shell

---

## Kernel Modules

Modules are loaded in priority order from `/lib/modules/`.

You can add your own `.kmod` files to extend kernel functionality without modifying the core.

---

## Debugging & Logging

The kernel logs to `/var/log/syslog.log` during runtime.
you can add to it by doing `syscall.log(text, tag, color)`

---

## Contributing

Contributions are welcome, though please follow these guidelines:

1. No AI-generated kernel code, keep the core human written.
2. Modularize, new features should go into kernel modules where possible.
3. Document, update comments and docs when adding/changing functionality.
4. Test, ensure your changes don’t break existing functionality.

Add your name to `contributors.md` when your PR is merged.

---

## License

This project is licensed under the MIT License. See the LICENSE file for details.
