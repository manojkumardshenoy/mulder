.model flat

.data
__imp__DecodePointer@4 dd __EncodeDecodePointerSubstitute
__imp__EncodePointer@4 dd __EncodeDecodePointerSubstitute
EXTERNDEF __imp__DecodePointer@4 : DWORD
EXTERNDEF __imp__EncodePointer@4 : DWORD

.code
__EncodeDecodePointerSubstitute proc
mov eax, 98BADCFEh
xor eax, [esp+4]
ret 4
__EncodeDecodePointerSubstitute endp

end
