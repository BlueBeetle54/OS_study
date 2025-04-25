/* 출처 : https://github.com/HIPERCUBE/64bit-Multicore-OS/blob/master/MINT64/01.Kernel32/elf_i386.x */
/* Default linker script, for normal executables */
/*OUTPUT_FORMAT("elf32-i386", "elf32-i386", "elf32-i386")*/
OUTPUT_FORMAT("binary")/* 실행 정보 미포함 옵션*/
OUTPUT_ARCH(i386)
ENTRY(_start)
SEARCH_DIR("/usr/cross/x86_64-pc-linux/lib");
SECTIONS
{
  /* Read-only sections, merged into text segment: */
  PROVIDE (__executable_start = 0x08048000); . = 0x08048000 + SIZEOF_HEADERS;
/*********************************************************************************/
/*  섹션 재배치로 인해 앞으로 이동된 부분 */
  .text 0x10200          :
  {
    *(.text .stub .text.* .gnu.linkonce.t.*)
    /* .gnu.warning sections are handled specially by elf32.em.  */
    *(.gnu.warning)
  } =0x90909090

  .rodata         : { *(.rodata .rodata.* .gnu.linkonce.r.*) }
  .rodata1        : { *(.rodata1) }

  /* 데이터 영역의 시작을 섹터 단위로 맞춤 */
  . = ALIGN (512);

  .data           :
  {
    *(.data .data.* .gnu.linkonce.d.*)
    SORT(CONSTRUCTORS)
  }
  .data1          : { *(.data1) }

  __bss_start = .;
  .bss            :
  {
   *(.dynbss)
   *(.bss .bss.* .gnu.linkonce.b.*)
   *(COMMON)
   /* Align here to ensure that the .bss section occupies space up to
      _end.  Align after .bss to ensure correct alignment even if the
      .bss section disappears because there are no input sections.
      FIXME: Why do we need it? When there is no .bss section, we don't
      pad the .data section.  */
   . = ALIGN(. != 0 ? 32 / 8 : 1);
  }
  . = ALIGN(32 / 8);
  . = ALIGN(32 / 8);
  _end = .; PROVIDE (end = .);
/****************************미사용 섹션 비활성화*************************************/

  /DISCARD/   : { *(.interp) }
  /DISCARD/   : { *(.note.gnu.build-id) }
  /DISCARD/   : { *(.hash) }
  /DISCARD/   : { *(.gnu.hash) }
  /DISCARD/   : { *(.dynsym) }
  /DISCARD/   : { *(.dynstr) }
  /DISCARD/   : { *(.gnu.version) }
  /DISCARD/   : { *(.gnu.version_d) }
  /DISCARD/   : { *(.gnu.version_r) }
  /DISCARD/   : { *(.rel.init) }
  /DISCARD/   : { *(.rela.init) }
  /DISCARD/   : { *(.rel.text .rel.text.* .rel.gnu.linkonce.t.*) }
  /DISCARD/   : { *(.rela.text .rela.text.* .rela.gnu.linkonce.t.*) }
  /DISCARD/   : { *(.rel.fini) }
  /DISCARD/   : { *(.rela.fini) }
  /DISCARD/   : { *(.rel.rodata .rel.rodata.* .rel.gnu.linkonce.r.*) }
  /DISCARD/   : { *(.rela.rodata .rela.rodata.* .rela.gnu.linkonce.r.*) }
  /DISCARD/   : { *(.rel.data.rel.ro* .rel.gnu.linkonce.d.rel.ro.*) }
  /DISCARD/   : { *(.rela.data.rel.ro* .rela.gnu.linkonce.d.rel.ro.*) }
  /DISCARD/   : { *(.rel.data .rel.data.* .rel.gnu.linkonce.d.*) }
  /DISCARD/   : { *(.rela.data .rela.data.* .rela.gnu.linkonce.d.*) }
  /DISCARD/   : { *(.rel.tdata .rel.tdata.* .rel.gnu.linkonce.td.*) }
  /DISCARD/   : { *(.rela.tdata .rela.tdata.* .rela.gnu.linkonce.td.*) }
  /DISCARD/   : { *(.rel.tbss .rel.tbss.* .rel.gnu.linkonce.tb.*) }
  /DISCARD/   : { *(.rela.tbss .rela.tbss.* .rela.gnu.linkonce.tb.*) }
  /DISCARD/   : { *(.rel.ctors) }
  /DISCARD/   : { *(.rela.ctors) }
  /DISCARD/   : { *(.rel.dtors) }
  /DISCARD/   : { *(.rela.dtors) }
  /DISCARD/   : { *(.rel.got) }
  /DISCARD/   : { *(.rela.got) }
  /DISCARD/   : { *(.rel.bss .rel.bss.* .rel.gnu.linkonce.b.*) }
  /DISCARD/   : { *(.rela.bss .rela.bss.* .rela.gnu.linkonce.b.*) }
  /DISCARD/   : { *(.rel.plt) }
  /DISCARD/   : { *(.rela.plt) }
  /DISCARD/   :
  {
    KEEP (*(.init))
  } =0x90909090
  /DISCARD/   : { *(.plt) }
  /DISCARD/   :
  {
    KEEP (*(.fini))
  } =0x90909090
  PROVIDE (__etext = .);
  PROVIDE (_etext = .);
  PROVIDE (etext = .);

  /DISCARD/   :
  {
    PROVIDE_HIDDEN (__preinit_array_start = .);
    KEEP (*(.preinit_array))
    PROVIDE_HIDDEN (__preinit_array_end = .);
  }
  /DISCARD/   :
  {
     PROVIDE_HIDDEN (__init_array_start = .);
     KEEP (*(SORT(.init_array.*)))
     KEEP (*(.init_array))
     PROVIDE_HIDDEN (__init_array_end = .);
  }
  /DISCARD/   :
  {
    PROVIDE_HIDDEN (__fini_array_start = .);
    KEEP (*(.fini_array))
    KEEP (*(SORT(.fini_array.*)))
    PROVIDE_HIDDEN (__fini_array_end = .);
  }

/*********************************************************************************/
/* 섹션 재배치로 인해 이동된 부분 */
  _edata = .; PROVIDE (edata = .);

  /* Thread Local Storage sections  */
  /DISCARD/   : { *(.tdata .tdata.* .gnu.linkonce.td.*) }
  /DISCARD/   : { *(.tbss .tbss.* .gnu.linkonce.tb.*) *(.tcommon) }
/*********************************************************************************/
  /DISCARD/   :
  {
    /* gcc uses crtbegin.o to find the start of
       the constructors, so we make sure it is
       first.  Because this is a wildcard, it
       doesn't matter if the user does not
       actually link against crtbegin.o; the
       linker won't look for a file to match a
       wildcard.  The wildcard also means that it
       doesn't matter which directory crtbegin.o
       is in.  */
    KEEP (*crtbegin.o(.ctors))
    KEEP (*crtbegin?.o(.ctors))
    /* We don't want to include the .ctor section from
       the crtend.o file until after the sorted ctors.
       The .ctor section from the crtend file contains the
       end of ctors marker and it must be last */
    KEEP (*(EXCLUDE_FILE (*crtend.o *crtend?.o ) .ctors))
    KEEP (*(SORT(.ctors.*)))
    KEEP (*(.ctors))
  }
  /DISCARD/   :
  {
    KEEP (*crtbegin.o(.dtors))
    KEEP (*crtbegin?.o(.dtors))
    KEEP (*(EXCLUDE_FILE (*crtend.o *crtend?.o ) .dtors))
    KEEP (*(SORT(.dtors.*)))
    KEEP (*(.dtors))
  }
  /DISCARD/   : { KEEP (*(.jcr)) }
  /DISCARD/   : { *(.data.rel.ro.local* .gnu.linkonce.d.rel.ro.local.*) *(.data.rel.ro* .gnu.linkonce.d.rel.ro.*) }
  /DISCARD/   : { *(.dynamic) }
  /DISCARD/   : { *(.got) }

  /DISCARD/   : { *(.got.plt) }
  /DISCARD/   : { *(.eh_frame_hdr) }
  /DISCARD/   : ONLY_IF_RO { KEEP (*(.eh_frame)) }
  /* Exception handling  */
  /DISCARD/   : ONLY_IF_RO { *(.gcc_except_table .gcc_except_table.*) }
  /DISCARD/   : ONLY_IF_RW { KEEP (*(.eh_frame)) }
  /DISCARD/   : ONLY_IF_RW { *(.gcc_except_table .gcc_except_table.*) }

  /* Stabs debugging sections.  */
  /DISCARD/   : { *(.stab) }
  /DISCARD/   : { *(.stabstr) }
  /DISCARD/   : { *(.stab.excl) }
  /DISCARD/   : { *(.stab.exclstr) }
  /DISCARD/   : { *(.stab.index) }
  /DISCARD/   : { *(.stab.indexstr) }
  /DISCARD/   : { *(.comment) }
  /* DWARF debug sections.
     Symbols in the DWARF debugging sections are relative to the beginning
     of the section so we begin them at 0.  */
  /* DWARF 1 */
  /DISCARD/   : { *(.debug) }
  /DISCARD/   : { *(.line) }
  /* GNU DWARF 1 extensions */
  /DISCARD/   : { *(.debug_srcinfo) }
  /DISCARD/   : { *(.debug_sfnames) }
  /* DWARF 1.1 and DWARF 2 */
  /DISCARD/   : { *(.debug_aranges) }
  /DISCARD/   : { *(.debug_pubnames) }
  /* DWARF 2 */
  /DISCARD/   : { *(.debug_info .gnu.linkonce.wi.*) }
  /DISCARD/   : { *(.debug_abbrev) }
  /DISCARD/   : { *(.debug_line) }
  /DISCARD/   : { *(.debug_frame) }
  /DISCARD/   : { *(.debug_str) }
  /DISCARD/   : { *(.debug_loc) }
  /DISCARD/   : { *(.debug_macinfo) }
  /* SGI/MIPS DWARF 2 extensions */
  /DISCARD/   : { *(.debug_weaknames) }
  /DISCARD/   : { *(.debug_funcnames) }
  /DISCARD/   : { *(.debug_typenames) }
  /DISCARD/   : { *(.debug_varnames) }
  /* DWARF 3 */
  /DISCARD/   : { *(.debug_pubtypes) }
  /DISCARD/   : { *(.debug_ranges) }
  /DISCARD/   : { KEEP (*(.gnu.attributes)) }
  /DISCARD/ : { *(.note.GNU-stack) *(.gnu_debuglink) }
}