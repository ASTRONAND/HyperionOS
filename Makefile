PYTHON    := python3
ARCH_FLAG := $(if $(ARCH),--arch $(ARCH),)
MODE_FLAG := $(if $(DEV),--dev,--release)

.PHONY: build build-mini build-test build-mini-test clean

build:
	$(PYTHON) build.py build $(ARCH_FLAG) $(MODE_FLAG)

build-mini:
	$(PYTHON) build.py build-mini $(ARCH_FLAG) $(MODE_FLAG)

build-test:
	$(PYTHON) build.py build-test $(ARCH_FLAG) $(MODE_FLAG)

build-mini-test:
	$(PYTHON) build.py build-mini-test $(ARCH_FLAG) $(MODE_FLAG)

clean:
	$(PYTHON) build.py clean
