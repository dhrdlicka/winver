DEST=winver.exe
OBJS=winver.obj
SYSTEM=windows1

AS=wasm
LINK=wlink

ASFLAGS=
LDFLAGS=

.asm.obj:
    $(AS) $(ASFLAGS) $*.asm -fo=$*.obj

all: winver.exe

$(DEST): $(OBJS)
    %write $@.lnk name      $@
    %write $@.lnk system    $(SYSTEM)
    %write $@.lnk option    map
    %write $@.lnk file      {$(OBJS)}
    $(LINK) $(LDFLAGS) @$@.lnk
    rm $@.lnk

clean: .symbolic
    rm -f *.exe
    rm -f *.obj
    rm -f *.map
    rm -f *.lnk
