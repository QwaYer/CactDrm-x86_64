/*
 * Linker script for the CactOS shared libdrm core (libdrm.so).
 *
 * Fixed base 0x23000000 — the loader's library slab; the whole address map, and
 * why a base is needed at all, is in CactLibc ldso/ldso.h.  CactOS maps every
 * image at its link-time address (bias 0), so this base only has to be disjoint
 * from every other image and below the kernel mmap window (0x80000000).
 *
 * The `.rela.*` names are the x86-64 ones; the `.rel.*` pair is kept so a
 * relocatable built by an older toolchain lands in a named section rather than
 * an orphan one.
 */

SECTIONS {
    . = 0x23000000;

    .dynamic   : { *(.dynamic) }
    .hash      : { *(.hash) }
    .gnu.hash  : { *(.gnu.hash) }
    .dynsym    : { *(.dynsym) }
    .dynstr    : { *(.dynstr) }
    .rela.dyn  : { *(.rela.dyn) }
    .rela.plt  : { *(.rela.plt) }
    .rel.dyn   : { *(.rel.dyn) }
    .rel.plt   : { *(.rel.plt) }

    .init      : { *(.init) }
    .plt       : { *(.plt) }
    .text      : { *(.text .text.*) }
    .fini      : { *(.fini) }

    .rodata    : { *(.rodata .rodata.*) }
    .eh_frame  : { *(.eh_frame) }

    . = ALIGN(0x1000);
    .data.rel.ro : { *(.data.rel.ro .data.rel.ro.*) }
    .data      : { *(.data .data.*) }
    .got       : { *(.got) }
    .got.plt   : { *(.got.plt) }
    .bss       : { *(.bss .bss.*) *(COMMON) }
}
