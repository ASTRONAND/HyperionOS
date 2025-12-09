# Drivers
---

Hyperion OS supports many driver types to allow it to run on any hardware
```
Driver types
    tto            - Supports basic text terminal output
    gpio           - Supports things like redstone
    runner         - Kernel level programs (no api)
    timer          - Timers and time related
    periph         - Basic peripheral info
    gfx            - PixelScreens
```
Hyperion also has a base driver api
```
Driver API
    name           - Name of driver+
    type           - Type of driver
    init           - Ran before init
    main           - Ran as a process and has normal behavior (used for checking network like things)
    api            - api difined by type
    arch           - architecture difined in bootloader (EX: cct, oc, ac, cc, ccpc)
    description    - discription
    author         - author of driver
    prior          - priority (low first)
```