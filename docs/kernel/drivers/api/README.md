# Drivers
---

Hyperion OS supports many driver types to allow it to run on any hardware
```
Driver types
    tty            - Supports basic teletype devices
    gpio           - Supports things like redstone
    runner         - Kernel level programs (no api)
    timer          - Timers and time related
    periph         - Basic peripheral info
    gfx            - PixelScreens
    modem          - networking
```
Hyperion also has a base driver api
```
Driver API
    name           - Name of driver
    type           - Type of driver
    load           - loading code
    unload         - unloading code
    main           - Ran as a process and has normal behavior (used for checking network like things)
    arch           - architecture difined in bootloader (EX: cct, oc, ac, cc, ccpc, or all)
    description    - discription
    author         - author of driver
```