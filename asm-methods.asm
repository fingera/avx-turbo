BITS 64
default rel

%include "nasm-utils-inc.asm"

nasm_util_assert_boilerplate
thunk_boilerplate

; aligns and declares the global label for the bench with the given name
; also potentally checks the ABI compliance (if enabled)
%macro define_func 1
abi_checked_function %1
%endmacro

; define a test func that unrolls the loop by 100
; with the given body instruction
; %1 - function name
; %2 - init instruction (e.g., xor out the variable you'll add to)
; %3 - loop body instruction
%macro test_func 3
define_func %1
%2
.top:
times 100 %3
sub rdi, 100
jnz .top
ret
%endmacro

test_func scalar_iadd, {xor eax, eax}, {add rax, rax}
test_func avx128_iadd,  {vpcmpeqd xmm0, xmm0, xmm0}, {vpaddq xmm0, xmm0, xmm0}
test_func avx256_iadd,  {vpcmpeqd ymm0, ymm0, ymm0}, {vpaddq ymm0, ymm0, ymm0}
test_func avx512_iadd,  {vpcmpeqd ymm0, ymm0, ymm0}, {vpaddq zmm0, zmm0, zmm0}

; define a test func that mostly just does does scalar adds but has one use-defined instruction every 100
; with the given body instruction
; %1 - function name
; %2 - init instruction (e.g., xor out the variable you'll add to)
; %3 - loop body instruction
%macro test_funcB 3
define_func %1
xor ecx, ecx
%2
.top:
%3
times 100 add rcx, rcx
sub rdi, 100
jnz .top
ret
%endmacro

test_funcB avx512_iaddB, {vpcmpeqd ymm0, ymm0, ymm0}, {vpaddq zmm0, zmm0, zmm0}

define_func avx3
xor ecx, ecx
.top:
times 100 vpaddq zmm0, zmm0, zmm0
sub rdi, 100
jnz .top
ret

define_func avx4
xor ecx, ecx
.top:
times 100 vpaddq zmm16, zmm16, zmm16
sub rdi, 100
jnz .top
ret


GLOBAL zeroupper:function
zeroupper:
vzeroupper
ret


