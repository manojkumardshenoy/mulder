unit CMemMan;

interface

procedure free(p: Pointer); cdecl;
function malloc(Size: Integer): Pointer; cdecl;
function realloc(p: Pointer; Size: Integer): Pointer; cdecl;

implementation

const
  msvcrt = 'msvcrt.dll';

procedure free(p: Pointer); cdecl; external msvcrt;
function malloc(Size: Integer): Pointer; cdecl; external msvcrt;
function realloc(p: Pointer; Size: Integer): Pointer; cdecl; external msvcrt;

function CGetMem(Size: Integer): Pointer;
begin
  Result := malloc(Size);
end;

function CFreeMem(p: Pointer): Integer;
begin
  free(p);
  Result := 0;
end;

function CReallocMem(p: Pointer; Size: Integer): Pointer;
begin
  Result := realloc(p, Size);
end;

const
  CMemoryManager: TMemoryManager = (
    GetMem: CGetMem;
    FreeMem: CFreeMem;
    ReallocMem: CReallocMem;
  );

initialization
  SetMemoryManager(CMemoryManager);

finalization

end.
