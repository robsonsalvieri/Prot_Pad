unit DisplayFourth;

interface

uses
  Dialogs, DisplayMain, Windows, SysUtils, classes, LojxFun, IniFiles, ComObj, Forms;

Type
  // Teclado Fourth com Display -  modelo FT65
  FourthDisplay = class(TDisplay)
  public
    function Abrir( sPorta:String ):String; override;
    function Fechar( sPorta:String ):String; override;
    function Escrever( Texto:String ): String; override;
  end;

implementation
var
  fHandle : THandle;

  fFuncInicializa       : function ():LongInt; stdcall;
  fFuncLimpaDisplay     : function ():LongInt; stdcall;
  fFuncVisualizaCursor  : function (HD: Longint): Longint; stdcall;
  fFuncCursorEstatico   : function : Longint; stdcall;
  fFuncCursorPiscante   : function : Longint; stdcall;
  fFuncLimpaLinha       : function (Linha: Longint): Longint; stdcall;
  fFuncCursorInicio     : function (): LongInt; StdCall;
  fFuncEscreveNoCentro  : function (Linha: Longint; mstr: PChar): Longint; stdcall;
  fFuncEscreveTexto     : function (Linha:Longint ; Coluna:Longint ; mstr: PChar ):Longint;Stdcall;
  //Essa função foi implementada na DLL do teclado (FTLIB.DLL), mas o firmware do teclado não possui esse recurso.
//  fFuncEcoInterno       : function (HD: Longint): Longint;Stdcall;

//---------------------------------------------------------------------------
function FourthDisplay.Abrir(sPorta : String) : String;
  function ValidPointer( aPointer: Pointer; sMSg :String ) : Boolean;
  begin
    if not Assigned(aPointer) Then
    begin
      ShowMessage('A função "'+sMsg+'" não existe na Dll: FTLIB.DLL');
      Result := False;
    end
    else
      Result := True;
  end;

var
  aFunc: Pointer;
  bRet : Boolean;
  nRet : LongInt;
begin
    fHandle := LoadLibrary( 'FTLIB.DLL' );
    if (fHandle <> 0) Then
    begin
      bRet := True;

      aFunc := GetProcAddress(fHandle,'RESET');
      if ValidPointer( aFunc, 'RESET' ) then
        fFuncInicializa := aFunc
      else
        bRet := False;

      aFunc := GetProcAddress(fHandle,'CLD');
      if ValidPointer( aFunc, 'CLD' ) then
        fFuncLimpaDisplay := aFunc
      else
        bRet := False;

      aFunc := GetProcAddress(fHandle,'C_CURSOR');
      if ValidPointer( aFunc, 'C_CURSOR' ) then
        fFuncVisualizaCursor := aFunc
      else
        bRet := False;

      aFunc := GetProcAddress(fHandle,'CLR_LINE');
      if ValidPointer( aFunc, 'CLR_LINE' ) then
        fFuncLimpaLinha := aFunc
      else
        bRet := False;

      aFunc := GetProcAddress(fHandle,'CURSOR_INICIO');
      if ValidPointer( aFunc, 'CURSOR_INICIO' ) then
        fFuncCursorInicio := aFunc
      else
        bRet := False;

      aFunc := GetProcAddress(fHandle,'CURSOR_ESTATICO');
      if ValidPointer( aFunc, 'CURSOR_ESTATICO' ) then
        fFuncCursorEstatico := aFunc
      else
        bRet := False;

      aFunc := GetProcAddress(fHandle,'CURSOR_PISCANTE');
      if ValidPointer( aFunc, 'CURSOR_PISCANTE' ) then
        fFuncCursorPiscante := aFunc
      else
        bRet := False;

      aFunc := GetProcAddress(fHandle,'DISP_CENTER');
      if ValidPointer( aFunc, 'DISP_CENTER' ) then
        fFuncEscreveNoCentro := aFunc
      else
        bRet := False;

      aFunc := GetProcAddress(fHandle,'DISP');
      if ValidPointer( aFunc, 'DISP' ) then
        fFuncEscreveTexto := aFunc
      else
        bRet := False;

{      aFunc := GetProcAddress(fHandle,'ECO_INTERNO');    //Essa função foi implementada na DLL
      if ValidPointer( aFunc, 'ECO_INTERNO' ) then        //do teclado (FTLIB.DLL), mas o firmware do
        fFuncEcoInterno := aFunc                          //teclado não possui esse recurso.
      else
        bRet := False;}
    end
    else
    begin
      ShowMessage('O arquivo FTLIB.DLL não foi encontrado.');
      bRet := False;
    end;

    if bRet then
    begin
      Result := '0';
      nRet := fFuncEscreveNoCentro ( 1, PChar('Microsiga Software S/A'));
      nRet := fFuncLimpaLinha(2);
      nRet := fFuncCursorEstatico;
      nRet := fFuncVisualizaCursor ( 0 );

      if nRet = 0 then
        result := '1|';
    end
    else
      result := '1|';

end;

//---------------------------------------------------------------------------
function FourthDisplay.Fechar( sPorta:String ) : String;
var nRet: LongInt;
begin
  Result := '0';

  nRet := fFuncEscreveNoCentro ( 1, PChar('Microsiga Software S/A'));
  nRet := fFuncLimpaLinha(2);
  If nRet = 0 then
    Result := '1';
end;

//----------------------------------------------------------------------------
function FourthDisplay.Escrever( Texto:String ): String;
var nRet   : LongInt;
    nLinha : LongInt;
    cLocal : String;
begin
  Result := '0';
  nLinha := StrToInt(Copy(Texto,1,1));
  cLocal := Copy(Texto,2,1);
  Texto  := Trim(Copy(Texto,3,Length(Texto)));

  if cLocal='C' then
    nRet := fFuncEscreveNoCentro ( nLinha, PChar(Texto))
  else if cLocal='E' then
  begin
    nRet := fFuncLimpaLinha(nLinha);
    nRet := fFuncEscreveTexto (nLinha, 1, PChar(Texto));
  end;

  If nRet = 0 then
    Result := '1';
end;

//----------------------------------------------------------------------------
initialization
  RegistraDisplay('FOURTH DISPLAY', FourthDisplay, 'BRA' );
end.
