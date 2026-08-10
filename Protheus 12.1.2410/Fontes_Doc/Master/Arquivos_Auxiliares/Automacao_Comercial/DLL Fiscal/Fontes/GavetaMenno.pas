unit GavetaMenno;

interface

Uses
  Dialogs,
  GavetaMain,
  Windows,
  SysUtils,
  classes,
  LojxFun,
  Forms;

Type
  TGaveta_Menno = class(TGaveta)
  private
    fHandle : THandle;
    fGavetaConfigura : function (pulso,min : integer): integer; stdcall;
    fDriverGaveta : function (p,f : integer) :integer; stdcall;
  public
    function Abrir( sPorta:String ):String; override;
    function Fechar( sPorta:String ):String; override;
    function Acionar( sPorta:String ):String; override;
    function Status( sPorta:String ):String; override;
  end;

//----------------------------------------------------------------------------
implementation
//----------------------------------------------------------------------------
const
{ Funções }
	GAVETA_INICIALIZA	= 1;
	GAVETA_ABRE			= 2;
	GAVETA_ESTADO		= 3;
{ Códigos de retorno }
	GAVETA_OK		= 0;
	GAVETA_FECHADA	= 1;
	GAVETA_ABERTA	= 2;
{ Códigos de retorno com erro }
	GAVETA_NAO_INICIALIZADA	= -1;
	GAVETA_PORTA_INVALIDA	= -2;
	GAVETA_FUNCAO_INVALIDA	= -3;

{ DLL pra funcionar a gaveta}
        sDLLSerial = 'libserial.dll';

//----------------------------------------------------------------------------
function TGaveta_Menno.Abrir(sPorta : String) : String;

  function ValidPointer( aPointer: Pointer; sMSg :String ) : Boolean;
  begin
    if not Assigned(aPointer) Then
    begin
      ShowMessage('A função "'+sMsg+'" não existe na Dll: Ghdl32.dll');
      GravaLog(' Gaveta - A função "'+sMsg+'" não existe na Dll: Ghdl32.dll' +CHR(13)+
                ' tente atualizar a DLL do Fabricante ');
      Result := False;
    end
    else
      Result := True;
  end;

var
  aFunc: Pointer;
  bRet : Boolean;
  iPorta : Integer;
  fHdlSerial : THandle;
begin
  fHandle := 0;
  bRet    := False;

  //Se não tiver a dll libserial não acha a gaveta
  GravaLog('Gaveta - Pesquisa da DLL ' + sDLLSerial);
  fHdlSerial := LoadLibrary( sDLLSerial );
  GravaLog('Gaveta - Handle da DLL ' + sDLLSerial + ' [' + IntToStr(fHdlSerial) + ']');

  If fHdlSerial <> 0 then
  begin
    GravaLog('Gaveta - Pesquisa da DLL Ghdl32.dll');
    fHandle := LoadLibrary( 'Ghdl32.dll' );
    GravaLog('Gaveta - Handle da DLL Ghdl32.dll [' + IntToStr(fHdlSerial) + ']');

    if (fHandle <> 0) Then
    begin
      bRet := True;

      aFunc := GetProcAddress(fHandle,'GavetaConfigura');
      if ValidPointer( aFunc, 'GavetaConfigura' )
      then fGavetaConfigura := aFunc
      else bRet := False;

      aFunc := GetProcAddress(fHandle,'DriverGaveta');
      if ValidPointer( aFunc, 'DriverGaveta' )
      then fDriverGaveta := aFunc
      else bRet := False;

    end
    else
    begin
      ShowMessage('O arquivo Ghdl32.dll não foi encontrado.');
      GravaLog('Gaveta - O arquivo Ghdl32.dll não foi encontrado.');
      bRet := False;
    end;

    if bRet then
    begin
      Result := '0';
      sPorta := Trim(sPorta);

      If UpperCase(sPorta) <> 'USB' then
      begin
        iPorta := StrToInt(copy(sPorta,4,2));
        GravaLog('Gaveta - comando DriverGaveta -> Porta: ' + Trim(sPorta));
        fDriverGaveta ( iPorta, GAVETA_INICIALIZA );    // inicializa a gaveta
        GravaLog('Gaveta - comando DriverGaveta <- Retorno [sem retorno]');
        Sleep(1000);

        GravaLog(' Gaveta - GavetaConfigura -> 150 , 3500');
        fGavetaConfigura ( 150, 3500 );    // configura a gaveta
        GravaLog(' Gaveta - GavetaConfigura <- Retorno [sem retorno]');
      end
      else
      begin
        ShowMessage(' Gaveta - Porta "USB" Inválida para esse equipamento, selecione '+
                'uma porta "COM"');
        GravaLog(' Gaveta - Porta "USB" Inválida para esse equipamento, selecione '+
                'uma porta "COM"');
        Result := '1';
      end;
    end
    else
      result := '1';
  End
  Else
  begin
    ShowMessage(' Atenção! o Arquivo LibSerial.DLL não foi encontrado! ' + CHR(13)+
                'Para Funcionamento da Gaveta é necessário que os arquivo :'+ CHR(13)+
                'Ghdl32.DLL e libserial.dll estejam na pasta do client');

    GravaLog(' Atenção! o Arquivo LibSerial.DLL não foi encontrado! ' + CHR(13)+
                'Para Funcionamento da Gaveta é necessário que os arquivo :'+ CHR(13)+
                'Ghdl32.DLL e libserial.dll estejam na pasta do client');
  End;

end;

//---------------------------------------------------------------------------
function TGaveta_Menno.Fechar( sPorta:String ) : String;
begin
  if (fHandle <> INVALID_HANDLE_VALUE) then
  begin
    FreeLibrary(fHandle);
    GravaLog(' Gaveta - Fecha Porta ');
    fHandle := 0;
  end;
  Result := '0';
end;

//---------------------------------------------------------------------------
function TGaveta_Menno.Acionar( sPorta:String ):String;
var
  iVezes : integer;
  iRet : integer;
  iPorta : integer;
begin
  sPorta := Trim(sPorta);

  If sPorta <> 'USB' then
  begin
    iPorta := StrToInt(copy(sPorta,4,2));
    result := '1';
    iVezes := 0;
    While (iVezes < 5) and (Result <> '0') do
    begin
      GravaLog(' Gaveta - comando DriverGaveta -> Gaveta Abre');
      iRet := fDriverGaveta ( iPorta, GAVETA_ABRE );  // abre a gaveta
      GravaLog(' Gaveta - comando DriverGaveta <- iRet:' + IntToStr(iRet));

      If iRet = GAVETA_NAO_INICIALIZADA then
      begin
        GravaLog(' Gaveta - comando DriverGaveta -> Gaveta Inicializa');
        fDriverGaveta ( iPorta, GAVETA_INICIALIZA );    // inicializa a gaveta
        GravaLog(' Gaveta - comando DriverGaveta <- [sem retorno]');

        GravaLog(' Gaveta - comando GavetaConfigura -> 150,3500');
        fGavetaConfigura ( 150, 3500 );            //configura a gaveta
        GravaLog(' Gaveta - comando GavetaConfigura <- [sem retorno]');

        Sleep(5000)     //deve haver uma espera antes de acionar a gaveta novamente
      end
      Else If iRet < 0 then
      begin
        GravaLog(' Gaveta - Aguardando para tentar abrir a gaveta - Tentativa ' + IntToStr(iVezes) + ' de 5');      
        Sleep(5000);     // deve haver uma espera antes de acionar a gaveta novamente
      end
      Else
        Result := '0';

      //Adiciona contador  
      Inc(iVezes,1);
    end;
  end
  else
  begin
    ShowMessage(' Gaveta - Porta "USB" Invalida para esse equipamento, selecione'+
                'uma porta "COM"');
    GravaLog(' Gaveta - Porta "USB" Invalida para esse equipamento, selecione'+
                'uma porta "COM"');

    Result := '1';
  end;
end;

//---------------------------------------------------------------------------
function TGaveta_Menno.Status( sPorta:String ):String;
var
 iRet: Integer;
begin
  sPorta := Trim(sPorta);

  If sPorta <> 'USB' then
  Begin
    GravaLog(' Gaveta - comando DriverGaveta -> Porta ' + sPorta);
    iRet := fDriverGaveta( StrToInt(copy(sPorta,4,2)), 3);
    GravaLog(' Gaveta - comando DriverGaveta <- iRet:' + IntToStr(iRet));

    if ( iRet = 2) then
    begin
      // 1 - Aberta
      Result := '1';
      GravaLog(' Gaveta - comando DriverGaveta <- Gaveta Aberta - iRet:' + IntToStr(iRet));
    end
    else
    begin
      // 0 - Fechada
      Result := '0';
      GravaLog(' Gaveta - comando DriverGaveta <- Gaveta Fechada - iRet:' + IntToStr(iRet));
    end;
  End
  Else
  Begin
    ShowMessage(' Gaveta - Porta "USB" Invalida para esse equipamento, selecione'+
                'uma porta "COM"');
    GravaLog(' Gaveta - Porta "USB" Invalida para esse equipamento, selecione'+
                'uma porta "COM"');
  End;
end;

//----------------------------------------------------------------------------
initialization
  RegistraGaveta( 'Gaveta Menno', TGaveta_Menno, 'BRA' );
  RegistraGaveta( 'Gaveta Gerbo QW Printer', TGaveta_Menno, 'BRA' );

//----------------------------------------------------------------------------
end.
