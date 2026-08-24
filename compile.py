#!/usr/bin/env python3

import hashlib
import json
import shutil, io
import tarfile, gzip
from pathlib import Path

ROOT = Path(__file__).resolve().parent
SOURCE = ROOT / "Src"
PACKAGE_ROOT = ROOT / "packages"
PACKAGE_DIR = PACKAGE_ROOT / "raw"

# main repo
API_ROOT = "https://git.astronand.dev/Hyperion/HyperionOS/raw/branch/main"

# local repo
#API_ROOT = "http://localhost:8000"

DEFAULT_VERSION = "0.0.0"
DEFAULT_DESCRIPTION = "No description provided"
DEFAULT_AUTHORS = []
DEFAULT_DEPENDENCIES = []


def debug(message):
    print(f"[COMPILE] {message}", flush=True)


def sha256(path):
    hasher = hashlib.md5()

    with open(path, "rb") as file:
        while chunk := file.read(1024 * 1024):
            hasher.update(chunk)

    return hasher.hexdigest()


def exclude(info):
    blocked = (".git", "__pycache__", ".pyc")

    if any(item in info.name.split("/") for item in blocked):
        return None

    return info


def read_file(folder, names, default):
    for name in names:
        file = folder / name

        if file.exists():
            return file.read_text(encoding="utf-8").strip()

    return default


def read_authors(folder):
    authors_file = folder / "authors.txt"

    if not authors_file.exists():
        return DEFAULT_AUTHORS

    authors = []

    for line in authors_file.read_text(encoding="utf-8").splitlines():
        line = line.strip()

        if line:
            authors.append(line)

    return authors if authors else DEFAULT_AUTHORS


def read_dependencies(folder):
    dependencies_file = folder / "dependencies.txt"

    if not dependencies_file.exists():
        return DEFAULT_DEPENDENCIES

    dependencies = []

    for line in dependencies_file.read_text(encoding="utf-8").splitlines():
        line = line.strip()

        if line:
            dependencies.append(line)

    return dependencies if dependencies else DEFAULT_DEPENDENCIES

def reproducible_filter(info):
    info.mtime = 0
    info.uid = 0
    info.gid = 0
    info.uname = ""
    info.gname = ""

    return info


def create_package(folder):
    name = folder.name

    tarball = PACKAGE_DIR / f"{name}.tar.gz"
    pkg_file = PACKAGE_ROOT / f"{name}.pkg"

    if tarball.exists():
        debug(f"Replacing {tarball.name}")
        tarball.unlink()

    debug(f"Packing {name}")

    # Create deterministic TAR
    tar_data = io.BytesIO()

    with tarfile.open(fileobj=tar_data, mode="w") as archive:
        archive.add(
            folder,
            arcname=name,
            filter=reproducible_filter,
        )

    # Create deterministic gzip
    compressed = gzip.compress(
        tar_data.getvalue(),
        compresslevel=9,
        mtime=0,
    )

    with open(tarball, "wb") as file:
        file.write(compressed)

    package_hash = sha256(tarball)

    metadata = {
        "id": name,
        "description": read_file(
            folder,
            ["description.md", "description.txt"],
            DEFAULT_DESCRIPTION,
        ),
        "authors": read_authors(folder),
        "dependencies": read_dependencies(folder),
        "version": read_file(
            folder,
            ["version.txt"],
            DEFAULT_VERSION,
        ),
        "hash": package_hash,
        "tarball": f"{API_ROOT}/packages/raw/{name}.tar.gz",
    }

    with open(pkg_file, "w", encoding="utf-8") as file:
        json.dump(metadata, file, indent=4)
        file.write("\n")

    debug(f"Generated {pkg_file.name}")
    debug(f"{name}: {package_hash}")

    return tarball

def load_spm():
    spm_file = ROOT / "spm.json"

    if not spm_file.exists():
        return {
            "refs": {},
            "maintainers": [],
            "packages": {}
        }

    with open(spm_file, "r", encoding="utf-8") as file:
        data = json.load(file)

    data.setdefault("refs", {})
    data.setdefault("maintainers", [])
    data.setdefault("packages", {})

    return data


def update_spm():
    spm = load_spm()

    packages = {}

    for pkg in sorted(PACKAGE_ROOT.glob("*.pkg")):
        with open(pkg, "r", encoding="utf-8") as file:
            metadata = json.load(file)

        packages[metadata["id"]] = f"{API_ROOT}/packages/{pkg.name}"

    spm["packages"] = packages
    spm["self"] = f"{API_ROOT}/spm.json"

    with open(ROOT / "spm.json", "w", encoding="utf-8") as file:
        json.dump(spm, file, indent=4)
        file.write("\n")

    debug("Generated spm.json")

def main():
    if not SOURCE.exists():
        debug("Src directory missing")
        return 1

    if PACKAGE_ROOT.exists():
        shutil.rmtree(PACKAGE_ROOT)

    PACKAGE_DIR.mkdir(parents=True, exist_ok=True)

    for folder in sorted(SOURCE.iterdir()):
        if folder.is_dir():
            create_package(folder)

    update_spm()
    debug("Complete")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
