## Building

### Linux / `make`-compatible systems

Run:

```bash
make build
```

**Optional variables:**

* **`ARCH=`** – Select bootloader type:

  * `cct` – Build using the CCT bootloader  
  * `oc`  – Build using the OC bootloader

* **`DEV=1`** – Enable development mode:

  * Bootloader does **not** start automatically on system startup  

**Default behavior (if `DEV` is not specified):**

* Builds in **release mode**  
* Bootloader starts automatically on system startup  

**Examples:**

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

**Optional arguments:**

* **`--arch {cct|oc}`** – Select bootloader:

  * `cct` – Use the CCT bootloader  
  * `oc`  – Use the OC bootloader

* **`--dev`** – Development mode:

  * Bootloader does **not** start automatically  
  * You must run `eeprom` in CraftOS to start Hyperion

* **`--release`** (default) – Release mode:

  * Bootloader starts automatically

* **`--makeuser username password`** – Pre-create user accounts (only works with `--dev` builds):

  ```bash
  --makeuser root rootpass
  --makeuser root rootpass --makeuser alice alicepass
  ```

  * Example: The first command creates the `root` account with the given password on first boot  
  * Example: The second command creates both `root` and `alice` accounts with defined passwords on first boot

**Examples:**

```bash
python build.py build --arch cct
python build.py build --arch oc --dev
```

---

### Build Requirements

* **`build`** – No additional requirements  
* **`build-mini`** – Requires [`luamin`](https://www.npmjs.com/package/luamin)  
* **`build-micro`** – Requires:

  * [`luamin`](https://www.npmjs.com/package/luamin)  
  * [`LZ4 binaries`](https://github.com/lz4/lz4/releases)