.model flat

.data
__imp__EncodePointer@4 dd __EncodeDecodePointer__
__imp__DecodePointer@4 dd __EncodeDecodePointer__
EXTERNDEF __imp__EncodePointer@4 : DWORD
EXTERNDEF __imp__DecodePointer@4 : DWORD

.code
__EncodeDecodePointer__ proc
mov eax, [esp+4]
not eax
ret 4
__EncodeDecodePointer__ endp

end
