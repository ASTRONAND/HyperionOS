## Building

### Linux / `make`-compatible systems

Run:

```bash
make build
```

Optional variables:

* **`ARCH=`**

  * `cct` Build using the cct bootloader
  * `oc` Build using the oc bootloader

* **`DEV=1`**

  * Builds in development mode
  * Bootloader does not start automatically on system startup

If `DEV` is not specified:

* Default is release mode
* Bootloader starts automatically on system startup

**Examples**

```bash
make build ARCH=cct
make build ARCH=oc DEV=1
```

---

### Windows / Any system with Python 3.7+

Run:

```bash
python build.py build
```

Optional arguments:

* **`--arch {cct|oc}`**
  Select bootloader

  * `cct` Use the cct bootloader
  * `oc` Use the oc bootloader

* **`--dev`**

  * Development mode
  * Bootloader does not start automatically

* **`--release`** (default)

  * Release mode
  * Bootloader starts automatically

**Examples**

```bash
python build.py build --arch cct
python build.py build --arch oc --dev
```
