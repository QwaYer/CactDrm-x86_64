# Vendored libdrm — provenance and the Cact additions

This repository is the CactOS port of the libdrm core: upstream sources are
carried in place, but the **build system is CactOS's own** and only the core
library is built (`libdrm.so`, fixed base `0x23000000`, plus `libdrm.a`).  No
per-driver backend (intel/radeon/amdgpu/…), no udev, no tests — CactOS reaches
the kernel through a single `/dev/dri` node.

| | |
|---|---|
| Upstream | <https://gitlab.freedesktop.org/mesa/drm> |
| Ref | tag `libdrm-2.4.134` — commit `e984d448` |
| Branch | `cact` (upstream tag + the Cact commits) |
| Sync tool | `./sync.sh` (`.cactsync` rebase mode, see `sync.conf`) |

## Files CactOS adds / removes

| Path | Role |
|---|---|
| `meson.build` | CactOS build: the five core sources, `config.h`, `libdrm.ld` |
| `meson_options.txt` | `cactlib`, `drmuapi`, `lr_lib`, `cpkg_py` paths |
| `config.h` | The configure answers, pinned instead of probed |
| `libdrm.ld` | Fixed-base linker script (`0x23000000`) |
| `cross/x86_64-cact-clang.ini` | The workspace's standard CactOS cross file |
| `pkg/libdrm/manifest` | `.cpkg` directory-package manifest |
| `sync.conf`, `sync.sh` | cactsync manifest and entry point |
| `PORTING-x86_64.md` | What "building for CactOS" means here |
| `.gitignore` (appended) | `/repo/`, `/pkg/*/payload/` (`/build*` was already there) |

**Removed from upstream:** `meson.build` and `meson_options.txt`.  Upstream's
Meson build probes the *host* through the cross compiler (its link tests would
resolve against the host libc) and hard-codes a versioned soname; this port owns
its build instead, exactly as the `*-for-Cact` driver repos do.  A sync onto a
newer upstream tag will therefore conflict on those two paths — resolve by
keeping CactOS's files.

## Deliberate deviations from upstream

1. **The DRM uapi headers come from the kernel**, not from libdrm's
   `include/drm/`.  `CactKernel-x86_64/Cact/drivers/gpu/drm/uapi` already carries
   `drm.h` / `drm_mode.h` / `drm_fourcc.h` ported to compile standalone
   (`drm_types.h` + `drm_ioctl.h` stand in for `<linux/types.h>` and
   `<asm/ioctl.h>`), and `drm_ioctl.h` is written to encode ioctls exactly as
   libdrm does.  Using one copy means the two sides cannot drift.  libdrm's
   generated fourcc table is built from that same header.
2. **`config.h` is hand-written**, because CactOS is a known target rather than
   a probed one (see the file for what each answer means).
3. **Soname is `libdrm.so`**, not `libdrm.so.2`: ld.so and `dlopen()` resolve a
   `DT_NEEDED` name as a file under `/usr/lib`, and the cctkfs image carries no
   symlinks.
4. **`-w`**: libdrm is vendored third-party code, so its warnings stay out of
   the CactOS build log.

## `st_rdev` and the DRM major

libdrm identifies a device node by `major(st_rdev) == DRM_MAJOR` (226) and picks
card vs render from the minor (128+ = render).  CactOS has no device-number
namespace of its own, so the kernel's DRM nodes report exactly that — the DRM
core already numbers its devices the Linux way — and nothing else reports a
device number.  See `cact_stat_t.rdev` in the kernel's `ioctl_abi.h`.

No upstream source file is edited.
