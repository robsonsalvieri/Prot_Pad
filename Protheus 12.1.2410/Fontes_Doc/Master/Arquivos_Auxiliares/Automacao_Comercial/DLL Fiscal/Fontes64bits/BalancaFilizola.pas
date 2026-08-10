unit BalancaFilizola;

interface

Uses
  Dialogs, BalancaMain, Windows, SysUtils, classes, LojxFun, Forms, CommInt,
  syncobjs, Messages, Sndkey32;

Type
  TBalancaOptico = class(TCustomComm)
  protected
//      procedure Comm1RxChar(Sender: TObject; Count: Integer);
  public
      constructor Create(AOwner: TComponent); override;
      destructor Destroy; override;
  end;

  TBalanca_Filizola = class(TBalanca)
  public
    function Abrir( sPorta:AnsiString ):AnsiString; override;
    function Fechar( sPorta:AnsiString ):AnsiString; override;
    function PegaPeso( ):AnsiString; override;
  end;

  TBalanca_FilizolaBP15 = class(TBalanca_Filizola)
  public
    function Abrir( sPorta:AnsiString ):AnsiString; override;
    function PegaPeso( ):AnsiString; override;
  end;

  TBalanca_FilizolaCS15 = class( TBalanca_FilizolaBP15 )
  public
    function PegaPeso( ):AnsiString; override;
  end;


//----------------------------------------------------------------------------
implementation

//----------------------------------------------------------------------------
var
  Comm1 : TBalancaOptico;
  Codigos : TStringList;
  Foco : Boolean = True;
  bCtrlFoco: Boolean = True;

//------------------------------------------------------------------------------
constructor TBalancaOptico.Create;
begin
  inherited;
end;

//------------------------------------------------------------------------------
destructor TBalancaOptico.Destroy;
begin
  inherited;
end;

//------------------------------------------------------------------------------
function TBalanca_Filizola.Abrir( sPorta:AnsiString ):AnsiString;
begin
   Comm1 := TBalancaOptico.Create(Application);

   Comm1.BaudRate := br9600;
   Comm1.Databits := da8;
   Comm1.Parity   := paNone;
   Comm1.StopBits := sb10;
   Comm1.DeviceName := sPorta;
   try
     //Abre a porta serial
     Comm1.Open;
     Codigos := TStringList.Create;
     result := '0';
   except
     result := '1';
   end;
end;

//---------------------------------------------------------------------------
function TBalanca_Filizola.Fechar( sPorta:AnsiString ) : AnsiString;
begin
  //Fecha porta serial
  Comm1.Close;
  Comm1.Free;
  result := '0|';
end;

//----------------------------------------------------------------------------
function TBalanca_Filizola.PegaPeso( ):AnsiString;
var
  Buffer1    : array[0..1] of AnsiChar;
  Buffer2    : array[0..8] of AnsiChar;
  iX         : shortint;
  sPeso,sRet : AnsiString;
  bRet       : boolean;
begin
  Fillchar(Buffer1, Sizeof(Buffer1), 0);
  Buffer1[0] := #5;
  bRet       := True;

  while True do
  begin

      while True do
      begin
         Comm1.Write( Buffer1, Sizeof(Buffer1) );
         Sleep(400); //Sleep se faz necessário, pois o buffer de retorno demora um pouco
         Fillchar(Buffer2, Sizeof(Buffer2), 0);
         Comm1.Read(Buffer2, Sizeof(Buffer2));
         iX := 0;
         bRet := True;

         while iX <= SizeOf( Buffer2 ) do
            Begin
               if Buffer2[iX] = 'N' then
                   begin
                       ShowMessage('Existe alivio no prato.');
                       bRet := False;
                       break;
                   end
               else if Buffer2[iX] = 'S' then
                   begin
                       ShowMessage('Existe excesso de peso no prato.');
                       bRet := False;
                       break;
                   end
               else if Buffer2[iX] = '-' then
                   begin
                       ShowMessage('Peso está negativo.');
                       bRet := False;
                       break;
                   end
               else if Buffer2[iX] = 'I' then
                   begin
                       sleep(2000);
                       Break;
                   end
               ;

               iX := iX + 1;
             end;

         if not bRet then
            break
         else if not (Buffer2[iX] = 'I') and not (Buffer2[iX] = 'N') and not (Buffer2[iX] = 'S') and not (Buffer2[iX] = '-') then
            break;

      end;

      if bRet then
          begin
              iX := 1;
              sPeso := '';
              While (iX <= SizeOf( Buffer2 )) and (Buffer2[iX] <> #3) do
                  begin
                      sPeso := sPeso + Buffer2[iX];
                      iX := iX + 1;
                  end
              ;
              if sPeso <> sRet then
                  sRet := sPeso
              else
                  break
          end
      else
          begin
              Result := '1|';
              break;
          end;
      end
  ;

  if bRet then
      Result := '0|' + sRet
  else
      Result := '1|';

End;

//------------------------------------------------------------------------------
function TBalanca_FilizolaBP15.Abrir( sPorta:AnsiString ):AnsiString;
begin
 Comm1 := TBalancaOptico.Create(Application);
 Comm1.BaudRate := br2400;
 Comm1.Databits := da8;
 Comm1.Parity   := paNone;
 Comm1.StopBits := sb10;
 Comm1.DeviceName := sPorta;
 try
   //Abre a porta serial
   Comm1.Open;
   Codigos := TStringList.Create;
   Result := '0';
 except
   Result := '1';
 end;
end;

//----------------------------------------------------------------------------
function TBalanca_FilizolaBP15.PegaPeso( ):AnsiString;
var
  Buffer1    : array[0..1] of AnsiChar;
  Buffer2    : array[0..8] of AnsiChar;
  iX         : shortint;
  sPeso,sRet : AnsiString;
  bRet       : boolean;
begin
Fillchar(Buffer1, Sizeof(Buffer1), 0);
Buffer1[0] := #5;
bRet       := True;

while True do
begin

    while True do
    begin
        Comm1.Write( Buffer1, Sizeof(Buffer1) );
        Sleep(400); //Sleep se faz necessário, pois o buffer de retorno demora um pouco
        Fillchar(Buffer2, Sizeof(Buffer2), 0);
        Comm1.Read(Buffer2, Sizeof(Buffer2));
        iX := 0;
        bRet := True;

        while iX <= SizeOf( Buffer2 ) do
        Begin
            if Buffer2[iX] = 'N' then
            begin
                ShowMessage('Existe alivio no prato.');
                bRet := False;
                break;
            end
            else if Buffer2[iX] = 'S' then
            begin
                ShowMessage('Existe excesso de peso no prato.');
                bRet := False;
                break;
            end
            else if Buffer2[iX] = '-' then
            begin
                ShowMessage('Peso está negativo.');
                bRet := False;
                break;
            end
            else if Buffer2[iX] = 'I' then
            begin
                sleep(2000);
                Break;
            end;

            iX := iX + 1;
        end;

        if not bRet then
            break
        else if not (Buffer2[iX] = 'I') and not (Buffer2[iX] = 'N') and not (Buffer2[iX] = 'S') and not (Buffer2[iX] = '-') then
            break;
    end;

    if bRet then
    begin
        iX := 1;
        sPeso := '';
        While (iX <= SizeOf( Buffer2 )) and (Buffer2[iX] <> #3) do
        begin
            sPeso := sPeso + Buffer2[iX];
            iX := iX + 1;
        end;
        sPeso := Copy(sPeso,1,Length(sPeso)-3)+'.'+Copy(sPeso,Length(sPeso)-2,Length(sPeso));
        if sPeso <> sRet then
            sRet := sPeso
        else
            break;
    end
    else
    begin
        Result := '1|';
        break;
    end;
end;

if bRet then
    Result := '0|' + sRet
else
    Result := '1|';

End;

//----------------------------------------------------------------------------
function TBalanca_FilizolaCS15.PegaPeso( ):AnsiString;
var
  Buffer1    : array[0..1] of AnsiChar;
  Buffer2    : array[0..21] of AnsiChar;
  iX         : shortint;
  sPeso,sRet : AnsiString;
  bRet       : boolean;
begin
Fillchar(Buffer1, Sizeof(Buffer1), 0);
Buffer1[0] := #5;
bRet       := True;
    while True do
    begin
        Comm1.Write( Buffer1, Sizeof(Buffer1) );
        Sleep(600); //Sleep se faz necessário, pois o buffer de retorno demora um pouco
        Fillchar(Buffer2, Sizeof(Buffer2), 0);
        Comm1.Read(Buffer2, Sizeof(Buffer2));
        iX := 0;
        bRet := True;
        If Buffer2[0] = #2 Then
        Begin
          sPeso := Copy( StrPas( Buffer2 ), 3, 2 ) + '.' + Copy( StrPas( Buffer2 ), 5, 3 );
          break;
        End;
    End;

if bRet then
    Result := '0|' + sPeso
else
    Result := '1|';

End;


//----------------------------------------------------------------------------
initialization
  RegistraBalanca( 'Filizola MF-C', TBalanca_Filizola, 'BRA' );
  RegistraBalanca( 'Filizola BP15', TBalanca_FilizolaBP15, 'BRA' );
  RegistraBalanca( 'Filizola CS15', TBalanca_FilizolaCS15, 'BRA' );
//----------------------------------------------------------------------------
end.
