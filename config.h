/* SPDX-License-Identifier: GPL-3.0-or-later */
/* Copyright (C) 2026 CactOS Project */

#ifndef CACT_LIBDRM_CONFIG_H
#define CACT_LIBDRM_CONFIG_H

/*
 * libdrm's build probes the platform; CactOS is a known target, so the answers
 * are written down instead of probed.  The values are what upstream's
 * meson.build concludes for x86_64 + CactLibc with every driver backend and
 * udev off — CactOS reaches the kernel through one /dev/dri node, so the
 * per-driver libraries are not built.
 *
 * This header is force-included (-include), exactly as upstream does with the
 * config.h it generates.
 */

#define _GNU_SOURCE 1

/* __sync_* builtins (what upstream's intel-atomics test links) exist on x86_64. */
#define HAVE_LIBDRM_ATOMIC_PRIMITIVES 1
#define HAVE_LIB_ATOMIC_OPS 0

/* No libudev, no libpciaccess backend. */
#define UDEV 0

/* CactLibc has open_memstream(); it has no secure_getenv(). */
#define HAVE_OPEN_MEMSTREAM 1
#define HAVE_SECURE_GETENV 0

/* major()/minor()/makedev() come from CactLibc's <sys/sysmacros.h>. */
#define MAJOR_IN_SYSMACROS 1

/* <sys/sysctl.h> is a BSD header and is absent. */
#define HAVE_SYS_SYSCTL_H 0

/* clang supports visibility("hidden"). */
#define HAVE_VISIBILITY 1

#endif /* CACT_LIBDRM_CONFIG_H */
