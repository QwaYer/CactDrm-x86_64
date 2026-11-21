# SPDX-License-Identifier: GPL-3.0-or-later
# Copyright (C) 2026 CactOS Project

# ==============================================================================
# CactDrm-x86_64 — the libdrm core for CactOS userspace
# ==============================================================================
#
# Upstream sources are carried in place, but the build system is CactOS's own:
# upstream's meson.build / meson_options.txt are removed (see UPSTREAM.md) and
# only the core library is built — no per-driver backend, no udev, no tests.
# CactOS reaches the kernel through a single /dev/dri node.
#
#   meson setup build-meson --cross-file cross/x86_64-cact-clang.ini
#   ninja -C build-meson            # libdrm.so + libdrm.a
#   ninja -C build-meson stage      # libdrm.so + headers into LocalRepo
#   ninja -C build-meson pkg        # repo/libdrm-<ver>.cpkg
#
# The DRM uapi headers are taken from the kernel's Cact/drivers/gpu/drm/uapi,
# not from libdrm's own include/drm: those copies are already ported to compile
# standalone (drm_types.h + drm_ioctl.h stand in for <linux/types.h> and
# <asm/ioctl.h>) and they are the ABI the kernel actually decodes, so the two
# sides cannot drift.  libdrm's generated fourcc table is built from that same
# header.
# ==============================================================================

project('cact-libdrm', 'c',
  version: '2.4.134',
  meson_version: '>=1.0.0',
  default_options: [
    'c_std=gnu11',
    'warning_level=0',            # libdrm is vendored; -w below
    'buildtype=plain',
    'b_staticpic=false',
  ])

fs = import('fs')
bash = find_program('bash')
ld = find_program('ld')
python3 = find_program('python3')

src_root = meson.project_source_root()
build_root = meson.current_build_dir()

# Path options are relative to this repo's root unless absolute.
_cactlib = get_option('cactlib')
cactlib = _cactlib.startswith('/') ? _cactlib : src_root / _cactlib
_drmuapi = get_option('drmuapi')
drmuapi = _drmuapi.startswith('/') ? _drmuapi : src_root / _drmuapi
_lr_lib = get_option('lr_lib')
lr_lib = _lr_lib.startswith('/') ? _lr_lib : src_root / _lr_lib
_cpkg_py = get_option('cpkg_py')
cpkg_py = _cpkg_py.startswith('/') ? _cpkg_py : src_root / _cpkg_py

cactlib_inc = cactlib / 'include'
if not fs.is_dir(cactlib_inc)
  error('CactLibc headers not found at ' + cactlib_inc +
        '  —  checkout the sibling repo or pass -Dcactlib=<path>')
endif
if not fs.is_file(drmuapi / 'drm.h')
  error('DRM uapi headers not found at ' + drmuapi +
        '  —  build CactKernel first or pass -Ddrmuapi=<path>')
endif

# libdrm is vendored, so its warnings stay out of the CactOS build log.  config.h
# pins the platform probes (see config.h) and is force-included exactly as
# upstream force-includes the file it generates.
libdrm_c_args = [
  '-ffreestanding', '-fno-stack-protector', '-nostdlib', '-nostdlibinc',
  '-include', src_root / 'config.h',
  '-I' + src_root,
  '-I' + drmuapi,
  '-isystem', cactlib_inc,
  '-I' + build_root,
  '-w',
]

libdrm_files = [
  'xf86drm.c', 'xf86drmHash.c', 'xf86drmRandom.c', 'xf86drmSL.c', 'xf86drmMode.c',
]

# xf86drm.c includes "generated_static_table_fourcc.h", produced upstream by
# gen_table_fourcc.py from the uapi drm_fourcc.h.
fourcc_table = custom_target('fourcc-table',
  input: drmuapi / 'drm_fourcc.h',
  output: 'generated_static_table_fourcc.h',
  command: [python3, src_root / 'gen_table_fourcc.py', '@INPUT@', '@OUTPUT@'])

libdrm_a = static_library('drm',
  [files(libdrm_files), fourcc_table],
  c_args: libdrm_c_args,
  pic: true)

libdrm_so = custom_target('libdrm-so',
  input: libdrm_a,
  output: 'libdrm.so',
  command: [ld, '-m', 'elf_x86_64', '-shared', '-nostdlib',
            '--hash-style=both', '-soname=libdrm.so',
            '-T', src_root / 'libdrm.ld', '-o', '@OUTPUT@',
            '--whole-archive', libdrm_a, '--no-whole-archive'],
  depend_files: files('libdrm.ld'),
  build_by_default: true)

# ------------------------------------------------------------------------------
# Stage into the image tree and build the package
# ------------------------------------------------------------------------------

inc_dir = lr_lib / 'include' / 'libdrm'
libdrm_headers = ['xf86drm.h', 'xf86drmMode.h', 'libdrm_lists.h', 'libdrm_macros.h']

_headers = ''
foreach h : libdrm_headers
  _headers += 'cp -f "' + src_root / h + '" "' + inc_dir + '/' + h + '"; '
endforeach

run_target('stage',
  command: [bash, '-c',
            'set -e; mkdir -p "' + lr_lib + '" "' + inc_dir + '"; ' +
            'cp -f "$1" "' + lr_lib + '/libdrm.so"; ' + _headers,
            'bash', libdrm_so])

pkg_src = src_root / 'pkg' / 'libdrm'
pkg_repo = src_root / 'repo'

run_target('pkg',
  command: [bash, '-c',
            'set -e; ' +
            'rm -f "$2"/*.cpkg; rm -rf "$1/payload"; mkdir -p "$1/payload/lib" "$1/payload/include/libdrm" "$2"; ' +
            'cp -f "$3" "$1/payload/lib/libdrm.so"; ' +
            'for h in ' + ' '.join(libdrm_headers) + '; do ' +
            'cp -f "' + src_root + '/$h" "$1/payload/include/libdrm/$h"; done; ' +
            python3.full_path() + ' "$4" build "$1" --repo "$2"; ' +
            python3.full_path() + ' "$4" index "$2"',
            'bash', pkg_src, pkg_repo, libdrm_so, cpkg_py])
