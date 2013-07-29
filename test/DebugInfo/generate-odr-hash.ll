; REQUIRES: object-emission

; RUN: llc %s -o %t -filetype=obj -O0 -generate-odr-hash
; RUN: llvm-dwarfdump -debug-dump=info %t | FileCheck %s
;
; Generated from:
;
; struct bar {};
; struct bar b;
; void foo(void) {
;   struct baz {};
;   baz b;
; }
; namespace echidna {
; namespace capybara {
; namespace mongoose {
; class fluffy {
;   int a;
;   int b;
; };
; fluffy animal;
; }
; }
; }
; namespace {
; struct walrus {};
; }
; walrus w;
; struct wombat {
;   struct {
;     int  a;
;     int  b;
;   } a_b;
; };
; wombat wom;

; Check that we generate a hash for bar and the value.
; CHECK: DW_TAG_structure_type
; CHECK-NEXT: debug_str{{.*}}"bar"
; CHECK: DW_AT_GNU_odr_signature [DW_FORM_data8] (0x200520c0d5b90eff)
; CHECK: DW_TAG_namespace
; CHECK-NEXT: debug_str{{.*}}"echidna"
; CHECK: DW_TAG_namespace
; CHECK-NEXT: debug_str{{.*}}"capybara"
; CHECK: DW_TAG_namespace
; CHECK-NEXT: debug_str{{.*}}"mongoose"
; CHECK: DW_TAG_class_type
; CHECK-NEXT: debug_str{{.*}}"fluffy"
; CHECK: DW_AT_GNU_odr_signature [DW_FORM_data8]   (0x9a0124d5a0c21c52)

; Check that we generate a hash for wombat and the value, but not for the
; anonymous type contained within.
; CHECK: DW_TAG_structure_type
; CHECK-NEXT: debug_str{{.*}}wombat
; CHECK: DW_AT_GNU_odr_signature [DW_FORM_data8] (0x685bcc220141e9d7)
; CHECK: DW_TAG_structure_type
; CHECK-NEXT: DW_AT_byte_size
; CHECK-NEXT: DW_AT_decl_file
; CHECK-NEXT: DW_AT_decl_line
; CHECK: DW_TAG_member
; CHECK-NEXT: debug_str{{.*}}"a"

; Check that we don't generate a hash for baz.
; CHECK: DW_TAG_structure_type
; CHECK-NEXT: debug_str{{.*}}"baz"
; CHECK-NOT: DW_AT_GNU_odr_signature

; FIXME: PR16740 we may want to generate debug info for walrus, but still no hash since
; the type is contained in an anonymous namespace and not visible externally even if
; the variable is...
; CHECK-NOT: debug_str{{.*}}"walrus"

%struct.bar = type { i8 }
%"class.echidna::capybara::mongoose::fluffy" = type { i32, i32 }
%struct.wombat = type { %struct.anon }
%struct.anon = type { i32, i32 }
%struct.baz = type { i8 }

@b = global %struct.bar zeroinitializer, align 1
@_ZN7echidna8capybara8mongoose6animalE = global %"class.echidna::capybara::mongoose::fluffy" zeroinitializer, align 4
@wom = global %struct.wombat zeroinitializer, align 4

; Function Attrs: nounwind uwtable
define void @_Z3foov() #0 {
entry:
  %b = alloca %struct.baz, align 1
  call void @llvm.dbg.declare(metadata !{%struct.baz* %b}, metadata !50), !dbg !58
  ret void, !dbg !59
}

; Function Attrs: nounwind readnone
declare void @llvm.dbg.declare(metadata, metadata) #1

attributes #0 = { nounwind uwtable "less-precise-fpmad"="false" "no-frame-pointer-elim"="true" "no-frame-pointer-elim-non-leaf"="true" "no-infs-fp-math"="false" "no-nans-fp-math"="false" "stack-protector-buffer-size"="8" "unsafe-fp-math"="false" "use-soft-float"="false" }
attributes #1 = { nounwind readnone }

!llvm.dbg.cu = !{!0}
!llvm.module.flags = !{!49}

!0 = metadata !{i32 786449, metadata !1, i32 4, metadata !"clang version 3.4 (trunk 187387) (llvm/trunk 187385)", i1 false, metadata !"", i32 0, metadata !2, metadata !2, metadata !3, metadata !8, metadata !2, metadata !""} ; [ DW_TAG_compile_unit ] [/usr/local/google/home/echristo/tmp/bar.cpp] [DW_LANG_C_plus_plus]
!1 = metadata !{metadata !"bar.cpp", metadata !"/usr/local/google/home/echristo/tmp"}
!2 = metadata !{i32 0}
!3 = metadata !{metadata !4}
!4 = metadata !{i32 786478, metadata !1, metadata !5, metadata !"foo", metadata !"foo", metadata !"_Z3foov", i32 6, metadata !6, i1 false, i1 true, i32 0, i32 0, null, i32 256, i1 false, void ()* @_Z3foov, null, null, metadata !2, i32 6} ; [ DW_TAG_subprogram ] [line 6] [def] [foo]
!5 = metadata !{i32 786473, metadata !1}          ; [ DW_TAG_file_type ] [/usr/local/google/home/echristo/tmp/bar.cpp]
!6 = metadata !{i32 786453, i32 0, i32 0, metadata !"", i32 0, i64 0, i64 0, i64 0, i32 0, null, metadata !7, i32 0, i32 0} ; [ DW_TAG_subroutine_type ] [line 0, size 0, align 0, offset 0] [from ]
!7 = metadata !{null}
!8 = metadata !{metadata !9, metadata !17, metadata !31}
!9 = metadata !{i32 786484, i32 0, null, metadata !"b", metadata !"b", metadata !"", metadata !5, i32 4, metadata !10, i32 0, i32 1, %struct.bar* @b, null} ; [ DW_TAG_variable ] [b] [line 4] [def]
!10 = metadata !{i32 786451, metadata !1, null, metadata !"bar", i32 1, i64 8, i64 8, i32 0, i32 0, null, metadata !11, i32 0, null, null} ; [ DW_TAG_structure_type ] [bar] [line 1, size 8, align 8, offset 0] [def] [from ]
!11 = metadata !{metadata !12}
!12 = metadata !{i32 786478, metadata !1, metadata !10, metadata !"bar", metadata !"bar", metadata !"", i32 1, metadata !13, i1 false, i1 false, i32 0, i32 0, null, i32 320, i1 false, null, null, i32 0, metadata !16, i32 1} ; [ DW_TAG_subprogram ] [line 1] [bar]
!13 = metadata !{i32 786453, i32 0, i32 0, metadata !"", i32 0, i64 0, i64 0, i64 0, i32 0, null, metadata !14, i32 0, i32 0} ; [ DW_TAG_subroutine_type ] [line 0, size 0, align 0, offset 0] [from ]
!14 = metadata !{null, metadata !15}
!15 = metadata !{i32 786447, i32 0, i32 0, metadata !"", i32 0, i64 64, i64 64, i64 0, i32 1088, metadata !10} ; [ DW_TAG_pointer_type ] [line 0, size 64, align 64, offset 0] [artificial] [from bar]
!16 = metadata !{i32 786468}
!17 = metadata !{i32 786484, i32 0, metadata !18, metadata !"animal", metadata !"animal", metadata !"_ZN7echidna8capybara8mongoose6animalE", metadata !5, i32 20, metadata !21, i32 0, i32 1, %"class.echidna::capybara::mongoose::fluffy"* @_ZN7echidna8capybara8mongoose6animalE, null} ; [ DW_TAG_variable ] [animal] [line 20] [def]
!18 = metadata !{i32 786489, metadata !1, metadata !19, metadata !"mongoose", i32 14} ; [ DW_TAG_namespace ] [mongoose] [line 14]
!19 = metadata !{i32 786489, metadata !1, metadata !20, metadata !"capybara", i32 13} ; [ DW_TAG_namespace ] [capybara] [line 13]
!20 = metadata !{i32 786489, metadata !1, null, metadata !"echidna", i32 12} ; [ DW_TAG_namespace ] [echidna] [line 12]
!21 = metadata !{i32 786434, metadata !1, metadata !18, metadata !"fluffy", i32 15, i64 64, i64 32, i32 0, i32 0, null, metadata !22, i32 0, null, null} ; [ DW_TAG_class_type ] [fluffy] [line 15, size 64, align 32, offset 0] [def] [from ]
!22 = metadata !{metadata !23, metadata !25, metadata !26}
!23 = metadata !{i32 786445, metadata !1, metadata !21, metadata !"a", i32 16, i64 32, i64 32, i64 0, i32 1, metadata !24} ; [ DW_TAG_member ] [a] [line 16, size 32, align 32, offset 0] [private] [from int]
!24 = metadata !{i32 786468, null, null, metadata !"int", i32 0, i64 32, i64 32, i64 0, i32 0, i32 5} ; [ DW_TAG_base_type ] [int] [line 0, size 32, align 32, offset 0, enc DW_ATE_signed]
!25 = metadata !{i32 786445, metadata !1, metadata !21, metadata !"b", i32 17, i64 32, i64 32, i64 32, i32 1, metadata !24} ; [ DW_TAG_member ] [b] [line 17, size 32, align 32, offset 32] [private] [from int]
!26 = metadata !{i32 786478, metadata !1, metadata !21, metadata !"fluffy", metadata !"fluffy", metadata !"", i32 15, metadata !27, i1 false, i1 false, i32 0, i32 0, null, i32 320, i1 false, null, null, i32 0, metadata !30, i32 15} ; [ DW_TAG_subprogram ] [line 15] [fluffy]
!27 = metadata !{i32 786453, i32 0, i32 0, metadata !"", i32 0, i64 0, i64 0, i64 0, i32 0, null, metadata !28, i32 0, i32 0} ; [ DW_TAG_subroutine_type ] [line 0, size 0, align 0, offset 0] [from ]
!28 = metadata !{null, metadata !29}
!29 = metadata !{i32 786447, i32 0, i32 0, metadata !"", i32 0, i64 64, i64 64, i64 0, i32 1088, metadata !21} ; [ DW_TAG_pointer_type ] [line 0, size 64, align 64, offset 0] [artificial] [from fluffy]
!30 = metadata !{i32 786468}
!31 = metadata !{i32 786484, i32 0, null, metadata !"wom", metadata !"wom", metadata !"", metadata !5, i32 39, metadata !32, i32 0, i32 1, %struct.wombat* @wom, null} ; [ DW_TAG_variable ] [wom] [line 39] [def]
!32 = metadata !{i32 786451, metadata !1, null, metadata !"wombat", i32 32, i64 64, i64 32, i32 0, i32 0, null, metadata !33, i32 0, null, null} ; [ DW_TAG_structure_type ] [wombat] [line 32, size 64, align 32, offset 0] [def] [from ]
!33 = metadata !{metadata !34, metadata !44}
!34 = metadata !{i32 786445, metadata !1, metadata !32, metadata !"a_b", i32 36, i64 64, i64 32, i64 0, i32 0, metadata !35} ; [ DW_TAG_member ] [a_b] [line 36, size 64, align 32, offset 0] [from ]
!35 = metadata !{i32 786451, metadata !1, metadata !32, metadata !"", i32 33, i64 64, i64 32, i32 0, i32 0, null, metadata !36, i32 0, null, null} ; [ DW_TAG_structure_type ] [line 33, size 64, align 32, offset 0] [def] [from ]
!36 = metadata !{metadata !37, metadata !38, metadata !39}
!37 = metadata !{i32 786445, metadata !1, metadata !35, metadata !"a", i32 34, i64 32, i64 32, i64 0, i32 0, metadata !24} ; [ DW_TAG_member ] [a] [line 34, size 32, align 32, offset 0] [from int]
!38 = metadata !{i32 786445, metadata !1, metadata !35, metadata !"b", i32 35, i64 32, i64 32, i64 32, i32 0, metadata !24} ; [ DW_TAG_member ] [b] [line 35, size 32, align 32, offset 32] [from int]
!39 = metadata !{i32 786478, metadata !1, metadata !35, metadata !"", metadata !"", metadata !"", i32 33, metadata !40, i1 false, i1 false, i32 0, i32 0, null, i32 320, i1 false, null, null, i32 0, metadata !43, i32 33} ; [ DW_TAG_subprogram ] [line 33]
!40 = metadata !{i32 786453, i32 0, i32 0, metadata !"", i32 0, i64 0, i64 0, i64 0, i32 0, null, metadata !41, i32 0, i32 0} ; [ DW_TAG_subroutine_type ] [line 0, size 0, align 0, offset 0] [from ]
!41 = metadata !{null, metadata !42}
!42 = metadata !{i32 786447, i32 0, i32 0, metadata !"", i32 0, i64 64, i64 64, i64 0, i32 1088, metadata !35} ; [ DW_TAG_pointer_type ] [line 0, size 64, align 64, offset 0] [artificial] [from ]
!43 = metadata !{i32 786468}
!44 = metadata !{i32 786478, metadata !1, metadata !32, metadata !"wombat", metadata !"wombat", metadata !"", i32 32, metadata !45, i1 false, i1 false, i32 0, i32 0, null, i32 320, i1 false, null, null, i32 0, metadata !48, i32 32} ; [ DW_TAG_subprogram ] [line 32] [wombat]
!45 = metadata !{i32 786453, i32 0, i32 0, metadata !"", i32 0, i64 0, i64 0, i64 0, i32 0, null, metadata !46, i32 0, i32 0} ; [ DW_TAG_subroutine_type ] [line 0, size 0, align 0, offset 0] [from ]
!46 = metadata !{null, metadata !47}
!47 = metadata !{i32 786447, i32 0, i32 0, metadata !"", i32 0, i64 64, i64 64, i64 0, i32 1088, metadata !32} ; [ DW_TAG_pointer_type ] [line 0, size 64, align 64, offset 0] [artificial] [from wombat]
!48 = metadata !{i32 786468}
!49 = metadata !{i32 2, metadata !"Dwarf Version", i32 3}
!50 = metadata !{i32 786688, metadata !4, metadata !"b", metadata !5, i32 9, metadata !51, i32 0, i32 0} ; [ DW_TAG_auto_variable ] [b] [line 9]
!51 = metadata !{i32 786451, metadata !1, metadata !4, metadata !"baz", i32 7, i64 8, i64 8, i32 0, i32 0, null, metadata !52, i32 0, null, null} ; [ DW_TAG_structure_type ] [baz] [line 7, size 8, align 8, offset 0] [def] [from ]
!52 = metadata !{metadata !53}
!53 = metadata !{i32 786478, metadata !1, metadata !51, metadata !"baz", metadata !"baz", metadata !"", i32 7, metadata !54, i1 false, i1 false, i32 0, i32 0, null, i32 320, i1 false, null, null, i32 0, metadata !57, i32 7} ; [ DW_TAG_subprogram ] [line 7] [baz]
!54 = metadata !{i32 786453, i32 0, i32 0, metadata !"", i32 0, i64 0, i64 0, i64 0, i32 0, null, metadata !55, i32 0, i32 0} ; [ DW_TAG_subroutine_type ] [line 0, size 0, align 0, offset 0] [from ]
!55 = metadata !{null, metadata !56}
!56 = metadata !{i32 786447, i32 0, i32 0, metadata !"", i32 0, i64 64, i64 64, i64 0, i32 1088, metadata !51} ; [ DW_TAG_pointer_type ] [line 0, size 64, align 64, offset 0] [artificial] [from baz]
!57 = metadata !{i32 786468}
!58 = metadata !{i32 9, i32 0, metadata !4, null}
!59 = metadata !{i32 10, i32 0, metadata !4, null}