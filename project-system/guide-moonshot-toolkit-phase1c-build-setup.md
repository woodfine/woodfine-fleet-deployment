# moonshot-toolkit Phase 1C Build Setup

This guide covers installing the AArch64 cross-compile environment on the workspace
VM and using the `moonshot-toolkit build` subcommand to produce a bootable
seL4 system image for the QEMU AArch64 target. It reflects the Phase 1C complete
milestone (moonshot-toolkit v0.3.0).

## Prerequisites

### Rust Toolchain

Rust stable is required. Verify with:

```
rustup show
```

The workspace VM has Rust installed at `/home/mathew/.cargo/`. The `moonshot-toolkit`
crate requires `rust-version = "1.74"` or later per `Cargo.toml`.

### AArch64 Cross-Compile Toolchain

Install via apt on Ubuntu 22.04 or 24.04:

```
sudo apt-get install -y \
  gcc-aarch64-linux-gnu \
  binutils-aarch64-linux-gnu \
  qemu-system-aarch64 \
  device-tree-compiler \
  libxml2-utils
```

Verify the cross-compiler:

```
aarch64-linux-gnu-gcc --version
# Expected: aarch64-linux-gnu-gcc (Ubuntu ...) 13.3.0
```

Verify QEMU:

```
qemu-system-aarch64 --version
# Expected: QEMU emulator version 8.2.x
```

### Python Dependencies (for seL4 Kernel Build Only)

The seL4 kernel CMake build uses Python scripts. These are not required for
`moonshot-toolkit build` itself, but are needed if rebuilding the seL4 kernel from
source (Phase 1C.b):

```
pip install --break-system-packages pyfdt tempita
```

### Vendor Prerequisites

The `moonshot-toolkit build` command requires three vendor trees to be present
relative to the project root:

| Path | Contents |
|---|---|
| `vendor-sel4-tools/elfloader-tool/` | seL4 elfloader C/ASM source |
| `vendor-sel4-kernel/build/aarch64-qemu/` | Built seL4 kernel (`kernel.elf`, `kernel.dtb`) |
| `vendor-sel4-project/build-support/qemu-arm-virt/` | libcpio, gen_config headers, linker script |
| `vendor-sel4-project/projects/hello-rootserver/` | Rootserver ELF (`hello-rootserver`) |

On the workspace VM, these are present in the `clones/project-system/` archive.
Build command validates each path at startup and reports which prerequisites are missing.

## Using moonshot-toolkit

All commands are run from the **project root** of the `clones/project-system/` archive:

```
cd ~/Foundry/clones/project-system
```

The `build` subcommand resolves vendor paths relative to the working directory. Running
from a subdirectory will cause prerequisite checks to fail.

### Validate a System Specification

The `validate` subcommand parses a `system-spec.toml` and checks all invariants.
It exits 0 on success and prints a one-line summary:

```
cargo run -p moonshot-toolkit -- validate moonshot-toolkit/examples/hello-world.toml
```

Expected output:

```
✓ moonshot-toolkit/examples/hello-world.toml — 1 protection_domain(s), 0 channel(s), 0 memory_region(s), 0 irq_delivery
```

### Generate a BuildPlan

The `plan` subcommand parses the spec and generates a deterministic `BuildPlan` in
JSON. The `plan_hash` field is the SHA-256 of the canonical JSON of `(spec_hash, steps)`:

```
cargo run -p moonshot-toolkit -- plan moonshot-toolkit/examples/hello-world.toml --format pretty-json
```

The same spec always produces the same `plan_hash`. This hash is the value that a
customer-apex cosignature attaches to per the Reproducible-Verification-On-Customer-Metal convention.

### Build a Protection Domain and System Image (Phase 1C Complete)

The `build` subcommand parses the spec, generates the BuildPlan, and executes each
step: cross-compiling the protection domain and then assembling the bootable system image.

```
cargo run -p moonshot-toolkit -- build moonshot-toolkit/examples/hello-world.toml
```

Expected output (Phase 1C complete, moonshot-toolkit v0.3.0):

```
Building plan (plan_hash = 3280a9dc2943ac63…)
[1/2] compile-pd-hello
  ✓ build/hello.elf
[2/2] assemble-image
  ✓ build/system-image.bin
```

The `build/system-image.bin` file is a bootable elfloader ELF image with entry
point `0x40400000`. It contains the seL4 kernel, its device tree, and the
rootserver, packed into a CPIO archive and linked with the seL4 elfloader.

### Verify the Compiled Protection Domain

Confirm the protection-domain ELF is a valid bare-metal AArch64 binary:

```
file build/hello.elf
```

Expected output:

```
build/hello.elf: ELF 64-bit LSB executable, ARM aarch64, version 1 (SYSV), statically linked, not stripped
```

For a more detailed header inspection:

```
aarch64-linux-gnu-readelf -h build/hello.elf | grep -E "Type|Machine|Entry"
```

Expected:

```
  Type:                              EXEC (Executable file)
  Machine:                           AArch64
  Entry point address:               0x40010c
```

### Verify the System Image

Confirm the assembled elfloader image entry point:

```
aarch64-linux-gnu-readelf -h build/system-image.bin | grep "Entry point"
```

Expected:

```
  Entry point address:               0x40400000
```

## Booting in QEMU

After a successful build, boot the system image with:

```
qemu-system-aarch64 \
  -machine virt,secure=off \
  -cpu cortex-a53 \
  -m 1G \
  -nographic \
  -kernel build/system-image.bin
```

The `-m 1G` flag is required. The QEMU `virt` machine device tree describes physical
memory from `0x40000000` to `0x80000000` (1 GiB). Launching with less memory causes
the elfloader memory map to conflict with QEMU's initialised regions.

Expected serial output (first lines):

```
ELF-loader started on CPU: ARM Ltd. Cortex-A53 r0p4
  paddr=[40400000..40423fff]
Bootstrapping kernel
…
Booting all finished, dropped to user space
```

The rootserver runs after "dropped to user space". The hello-rootserver in the
`vendor-sel4-project/projects/hello-rootserver/` source currently loops indefinitely.
Adding `seL4_DebugPutChar` output is a planned next step.

Terminate QEMU with `Ctrl-A X`.

## Running the Test Suite

```
cargo test -p moonshot-toolkit --all-targets
```

Expected: 35 tests pass (26 lib tests + 9 bin tests). Tests include:
- CPIO archive format verification (4 tests in `src/cpio.rs`)
- `assemble_image_errors_when_elfloader_missing` — verifies prerequisite checking
- `build_command_errors_without_source_file` — verifies compile error propagation

## See Also

- `topic-moonshot-toolkit-build-orchestrator.md` — architectural background on
  what moonshot-toolkit is and how the BuildPlan model works
- `topic-sel4-aarch64-qemu-substrate-target.md` — the seL4 AArch64 QEMU target
  that the built images run on
