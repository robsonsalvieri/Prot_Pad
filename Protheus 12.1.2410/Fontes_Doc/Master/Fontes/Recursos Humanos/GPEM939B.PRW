#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "RESTFUL.CH"
#INCLUDE "GPEM939.CH"

Static cFeedzURL
Static cPMURL
Static lTpInt

//-------------------------------------------------------------------
/*/{Protheus.doc} GPEM939B
Exibe os lotes de integração com o P&M (Performance & Metas)/a Feedz
@author  Allyson Luiz Mesashi
@since   06/05/2022
/*/
//-------------------------------------------------------------------
Function GPEM939B()

Local cFilterBRW    := ""
Local lMPP          := AmIOnRestEnv() //Verifica se está com a port MPP habilitada

Private aLogDesp    := {}
Private aLogPeM     := {}
Private aMarkREF	:= {}
Private aTitle      := { OemToAnsi(STR0085), OemToAnsi(STR0262) }//"Status do processamento"##"Registros não consultados por já terem retorno"
Private cFeedzTok	:= SuperGetMv( 'MV_APIFEE2', Nil, "" )
Private cPMToken	:= SuperGetMv( 'MV_APIPEM0', Nil, "" )
Private cPMClient	:= SuperGetMv( 'MV_APIPEM2', Nil, "" )
Private cPMSecret	:= SuperGetMv( 'MV_APIPEM3', Nil, "" )
Private oBrowse

DEFAULT cFeedzURL   := SuperGetMv( 'MV_APIFEE1', Nil, "" )
DEFAULT cPMURL		:= SuperGetMv( 'MV_APIPEM1', Nil, "" ) 
DEFAULT lTpInt      := REF->( ColumnPos( "REF_TPINT" ) ) > 0

If !ChkFile("REF")
	//"Atenção"###"A tabela REF não existe no dicionário. É necessário atualização do ambiente para acesso à rotina"###"Contate o administrador do sistema para efetuar a atualização do ambiente"
	Help( " ", 1, OemToAnsi(STR0001), Nil, OemToAnsi(STR0002), 1, 0, Nil, Nil, Nil, Nil, Nil, { OemToAnsi(STR0003) } )
	Return .F.
EndIf

If Empty(cPMURL) .And. Empty(cFeedzURL)
	//"Atenção"###"A rotina de consulta somente deve ser utilizada quando a integração com o P&M ou com a Feedz estiver ativa."###"Contate o administrador do sistema para efetuar o ajuste na parametrização no módulo Configurador."
	Help( " ", 1, OemToAnsi(STR0001), Nil, OemToAnsi(STR0271), 1, 0, Nil, Nil, Nil, Nil, Nil, { OemToAnsi(STR0265) } )
	Return .F.
EndIf

If Empty(cFeedzURL)
    If Empty(cPMToken) .Or. Empty(cPMClient) .Or. Empty(cPMSecret)
        //"Atenção"###"Os parâmetros MV_APIPEM0, MV_APIPEM2 e/ou MV_APIPEM3 não estão preenchidos."###"Contate o administrador do sistema para revisar a configuração dos parâmetros MV_APIPEM0, MV_APIPEM2 e/ou MV_APIPEM3 no módulo Configurador"
        Help( " ", 1, OemToAnsi(STR0001), Nil, OemToAnsi(STR0013), 1, 0, Nil, Nil, Nil, Nil, Nil, { OemToAnsi(STR0072) } )
        Return .F.
    EndIf
Else
    If Empty(cFeedzTok)
        //"Atenção"###"O parâmetro MV_APIFEE2 não está preenchido."###"Contate o administrador do sistema para revisar a configuração do parâmetro MV_APIFEE2 no módulo Configurador."
        Help( " ", 1, OemToAnsi(STR0001), Nil, OemToAnsi(STR0266), 1, 0, Nil, Nil, Nil, Nil, Nil, { OemToAnsi(STR0267) } )
        Return .F.
    EndIf
EndIf

If lMPP
    FwCallApp("gpem939b") //Abre o app da Consulta em POUI - App versão 19
    Return
EndIf

REF->( dbSetOrder(2) )
oBrowse := FWMarkBrowse():New()

If !FWIsAdmin()
    cFilterBRW := "REF_USER == '" + RetCodUsr() + "'"
EndIf

If Empty(cFeedzURL) .And. lTpInt
    Iif( Empty(cFilterBRW), cFilterBRW := "REF_TPINT $ (' /1')", cFilterBRW += " .And. REF_TPINT $ (' /1')"  )
ElseIf !Empty(cFeedzURL)
    Iif( Empty(cFilterBRW), cFilterBRW := "REF_TPINT = '2'", cFilterBRW += " .And. REF_TPINT = '2'"  )
EndIf

oBrowse:SetAlias( "REF" )
oBrowse:SetFieldMark( "REF_OK" )
oBrowse:SetDescription( STR0136 )//"Lote de integração"
oBrowse:SetMenuDef( "GPEM939B" )
oBrowse:SetAfterMark( { || fMark() } )
oBrowse:SetAllMark( { || fMarkAll() } )
If !Empty(cFilterBRW)
    oBrowse:SetFilterDefault( cFilterBRW )
EndIf

//Legendas
oBrowse:AddLegend( "REF->REF_STATUS == '0'", "BLUE", STR0125 )//"Não iniciado"
oBrowse:AddLegend( "REF->REF_STATUS == '1'", "YELLOW", STR0126 )//"Executando"
oBrowse:AddLegend( "REF->REF_STATUS == '2'", "GREEN", STR0127 )//"Concluído"
oBrowse:AddLegend( "REF->REF_STATUS == '3'", "RED", STR0128 )//"Houve erro de validação"
oBrowse:AddLegend( "REF->REF_STATUS == 'X'", "BLACK", STR0137 )//"Não encontrado"

oBrowse:Activate()

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} ModelDef
Função com a regra do Model
@author  Allyson Luiz Mesashi
@since   06/05/2022
/*/
//-------------------------------------------------------------------
Static Function ModelDef()

Local oStructREF    := FWFormStruct( 1, "REF" )
Local oModel        := MpFormModel():New( "GPEM939B", /*Pre-Validacao*/, /*Pos-Validacao*/, /*Commit*/, /*Cancel*/ )

oModel:AddFields( "REFMASTER", /*cOwner*/, oStructREF, /*Pre-Validacao*/, /*Pos-Validacao*/, /*Carga*/ )
oModel:SetPrimaryKey( {} )

Return oModel

//-------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
Função com a regra da View
@author  Allyson Luiz Mesashi
@since   06/05/2022
/*/
//-------------------------------------------------------------------
Static Function ViewDef()

Local oModel        := FwLoadModel( "GPEM939B" )
Local oStructREF    := FWFormStruct( 2, "REF" )
Local oView         := FWFormView():New()

DEFAULT cFeedzURL   := SuperGetMv( 'MV_APIFEE1', Nil, "" )
DEFAULT lTpInt      := REF->( ColumnPos( "REF_TPINT" ) ) > 0

oView:SetDescription( STR0136 )//"Lote de integração"

oStructREF:RemoveField( "REF_OK" )
If lTpInt
    oStructREF:RemoveField( "REF_TPINT" )
EndIf

oView:SetModel( oModel )
oView:AddField( "VIEW_REF", oStructREF, "REFMASTER" )
oView:CreateHorizontalBox( "TELA", 100 )
oView:SetOwnerView( "VIEW_REF", "TELA" )
oView:addUserButton( OemToAnsi(STR0131), "MAGIC_BMP", { || fErrorPeM() }, OemToAnsi(STR0131), Nil, {MODEL_OPERATION_VIEW}, .T. )//"Consultar Inconsistências"
If Empty(cFeedzURL)
    oView:addUserButton( OemToAnsi(STR0146), "MAGIC_BMP", { || ShellExecute( "open", "https://tdn.totvs.com/pages/viewpage.action?pageId=676047532", "", "", 1 ) }, OemToAnsi(STR0146), Nil, {MODEL_OPERATION_VIEW}, .T. )//"TDN Performance e Metas"
EndIf

Return oView

//-------------------------------------------------------------------
/*/{Protheus.doc} MenuDef
Função com as opções de menu
@author  Allyson Luiz Mesashi
@since   06/05/2022
/*/
//-------------------------------------------------------------------
Static Function MenuDef()

Local aRotina :=  {}

ADD OPTION aRotina TITLE OemToAnsi( STR0129 ) ACTION "VIEWDEF.GPEM939B" OPERATION 2 ACCESS 0//"Visualizar"
ADD OPTION aRotina TITLE OemToAnsi( STR0130 ) ACTION "f939BGet()" 	    OPERATION 9 ACCESS 0//"Consultar Status"
ADD OPTION aRotina TITLE OemToAnsi( STR0145 ) ACTION "f939BTDN()" 	    OPERATION 10 ACCESS 0//"TDN Integração"
ADD OPTION aRotina TITLE OemToAnsi( STR0263 ) ACTION "fGp939Leg()" 	    OPERATION 10 ACCESS 0//"Legenda"

Return aRotina

//-------------------------------------------------------------------
/*/{Protheus.doc} fMark
Função para realiza a marcação de um registro no browse
@author  Allyson Luiz Mesashi
@since   06/05/2022
/*/
//-------------------------------------------------------------------
Static Function fMark()

Local nPos      := aScan( aMarkREF, { |x| x == REF->( Recno() ) } )

If oBrowse:IsMark()
    aAdd( aMarkREF, REF->( Recno() ) )
Else
    If nPos > 0
        aDel( aMarkREF, nPos )        
        aSize( aMarkREF, Len( aMarkREF ) - 1 )
    EndIF
EndIf

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} fMarkAll
Função para realiza a marcação de todos os registros do browse
@author  Allyson Luiz Mesashi
@since   06/05/2022
/*/
//-------------------------------------------------------------------
Static Function fMarkAll()

Local nLast

oBrowse:GoBottom(.F.)
nLast := oBrowse:At()
oBrowse:GoTop()

While .T.
    oBrowse:MarkRec()
    If nLast == oBrowse:At()
        oBrowse:GoTop()
        Exit
    EndIf
    oBrowse:GoDown()
EndDo

Return .T.

//-------------------------------------------------------------------
/*/{Protheus.doc} f939BGet()
Função que efetua a consulta do status do processamento dos lotes no P&M/na Feedz
@author  Allyson Luiz Mesashi
@since   06/05/2022
/*/
//-------------------------------------------------------------------
Function f939BGet()

Processa( { || fStat939B() }, STR0151)//"Efetuando consulta"

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} fStat939B()
Função que efetua a consulta do status do processamento dos lotes no P&M/na Feedz
@author  Allyson Luiz Mesashi
@since   06/05/2022
/*/
//-------------------------------------------------------------------
Function fStat939B( lJob )

Local aAreaREF  := REF->( GetArea() )
Local aHeader	:= {}
Local cErrToken := ""
Local cPath		:= ""
Local cRetPeM	:= ""
Local cStatJson	:= ""
Local cStatPrc	:= ""
Local cTipoAPI	:= ""
Local cToken	:= ""
Local lErro	    := .F.
Local lTokOk	:= .T.
Local oClient 	:= Nil
Local oJson		:= Nil
Local nMsgPeM   := 0
Local nReg	    := 0
Local nTotMark  := Len(aMarkREF)

DEFAULT lJob        := .F.

DEFAULT cFeedzURL   := SuperGetMv( 'MV_APIFEE1', Nil, "" )
DEFAULT cPMURL		:= SuperGetMv( 'MV_APIPEM1', Nil, "" ) 

cPath		:= Iif( Empty(cFeedzURL), "api/v1/process/", "v1/process/" )
oClient 	:= FwRest():New( Iif( Empty(cFeedzURL), cPMURL, cFeedzURL ) )

If !lJob .And. Empty(aMarkREF)
    Help( " ", 1, OemToAnsi(STR0001), Nil, OemToAnsi(STR0134), 1, 0, Nil, Nil, Nil, Nil, Nil, { OemToAnsi(STR0135) } )//"Atenção"###"Nenhum registro foi selecionado."###"Efetue a seleção de pelo menos um registro."
    Return .F.
EndIf

If Empty(cFeedzURL)
    lTokOk := fTokenPM( @cToken, @cErrToken )
Else
    cToken  := cFeedzTok
    lTokOk  := .T.
EndIf

If !lTokOk
	If !lJob
        Help( " ", 1, OemToAnsi(STR0001), Nil, OemToAnsi(STR0132 + CRLF + STR0080 + CRLF + cErrToken), 1, 0, Nil, Nil, Nil, Nil, Nil, { OemToAnsi(STR0133) } )//"Atenção"###"Houve falha ao tentar obter o token de acesso"###"Obs.: erro completo retornado:"###"Solicite ao administrador uma revisão dos parâmetros MV_APIPEM0, MV_APIPEM2 e/ou MV_APIPEM3"
    Else
        Conout( FwNoAccent(STR0132 + CRLF + STR0080 + CRLF + cErrToken) )//"Houve falha ao tentar obter o token de acesso"###"Obs.: erro completo retornado:"
    EndIf
    Return .F.
EndIf

aAdd( aHeader, "Authorization: Bearer " + cToken )
aAdd( aHeader, "User-Agent: Protheus")

If !lJob
    ProcRegua( nTotMark )
EndIf

For nReg := 1 To nTotMark
    If !lJob
        IncProc( OemToAnsi(STR0152) + cValToChar(nReg) + OemToAnsi(STR0153) + cValToChar(nTotMark) )//"Consultando lote "##" de "
    Else
        Conout( OemToAnsi(STR0152) + cValToChar(nReg) + OemToAnsi(STR0153) + cValToChar(nTotMark) )//"Consultando lote "##" de "
    EndIf

    REF->( dbGoTo(aMarkREF[nReg]) )

    cTipoAPI := Iif( REF->REF_TIPO== "1", STR0015, Iif( REF->REF_TIPO == "2", STR0014, Iif( REF->REF_TIPO == "3", STR0017, Iif( REF->REF_TIPO == "4", STR0016, STR0018 ) ) ) )//"Filiais"##"Grupo de cargos"##"Cargos"##"Departamentos"##"Funcionários"

    If !(REF->REF_STATUS $ "0/1")
        cStatPrc := Iif( REF->REF_STATUS == "2", STR0097, Iif( REF->REF_STATUS == "3", STR0098, STR0137 ) )//"Concluído"##"Houve erro de validação"##"Não encontrado"
        Iif( !lJob, aAdd(aLogDesp, STR0093 + REF->REF_PRCID + " | " + STR0099 + REF->REF_TIPO + " - " + cTipoAPI + " | " + STR0094 + REF->REF_STATUS + " - " + cStatPrc), Conout( FwNoAccent(STR0093 + REF->REF_PRCID + " | " + STR0099 + REF->REF_TIPO + " - " + cTipoAPI + " | " + STR0094 + cStatJson + " - " + cStatPrc) ) )////"ID do Lote: "##"Tipo: "##"Status: "
        Loop
    EndIf
    
    oClient:SetPath( cPath+REF->REF_PRCID )
    
    cStatJson   := "X"
    cRetPeM     := ""

    If oClient:Get(aHeader)
        oJson := JsonObject():New()
        oJson:fromJson( oClient:GetResult() )
        fJsPMSt( @oJson, @cStatJson )
        cRetPeM := oClient:GetResult()
    EndIf    

    If REF->( RecLock("REF", .F.) )
        REF->REF_STATUS := cStatJson
        REF->REF_RETORN := oClient:GetResult()
        REF->( MsUnlock() )
    EndIf

    cStatPrc := Iif( cStatJson == "0", STR0095, Iif( cStatJson == "1", STR0096, Iif( cStatJson == "2", STR0097, Iif( cStatJson == "3", STR0098, STR0137 ) ) ) )//"Status: "##" - "##"Não iniciado"##"Executando"##"Concluído"##"Houve erro de validação"##//"Não encontrado"

    If !lJob
        aAdd(aLogPeM, STR0093 + REF->REF_PRCID + " | " + STR0099 + REF->REF_TIPO + " - " + cTipoAPI + " | " + STR0094 + cStatJson + " - " + cStatPrc)//"ID do Lote: "##"Tipo: "##"Status: "
        If cStatJson == "3"
            lErro := .T.
            aAdd(aLogPeM, STR0100)//"Obs.: mensagem de validação retornada:"
            For nMsgPeM := 1 To Len(oJson["errorMessages"])
                FiltraLog( aLogPeM, STR0105 + Iif(ValType(oJson["errorMessages"][nMsgPeM]["integrationId"]) != "U", oJson["errorMessages"][nMsgPeM]["integrationId"] , "null" ) + " | " + STR0106 + Iif( ValType(oJson["errorMessages"][nMsgPeM]["code"]) != "U", cValToChar( oJson["errorMessages"][nMsgPeM]["code"] ) , "null" ) + " | " + Iif( ValType(oJson["errorMessages"][nMsgPeM]["message"]) != "U", STR0107 + oJson["errorMessages"][nMsgPeM]["message"], "null" ) )//"ID de integração: "##"Código da validação: "##"Mensagem: "
            Next nMsgPeM
        EndIf
    Else
        Conout( FwNoAccent(STR0093 + REF->REF_PRCID + " | " + STR0099 + REF->REF_TIPO + " - " + cTipoAPI + " | " + STR0094 + cStatJson + " - " + cStatPrc) )//"ID do Lote: "##"Tipo: "##"Status: "
        If cStatJson == "3"
            Conout( FwNoAccent(STR0100) )//"Obs.: mensagem de validação retornada:"
            For nMsgPeM := 1 To Len(oJson["errorMessages"])
                Conout( FwNoAccent(STR0105 + Iif(ValType(oJson["errorMessages"][nMsgPeM]["integrationId"]) != "U", oJson["errorMessages"][nMsgPeM]["integrationId"] , "null" ) + " | " + STR0106 + Iif( ValType(oJson["errorMessages"][nMsgPeM]["code"]) != "U", cValToChar( oJson["errorMessages"][nMsgPeM]["code"] ) , "null" ) + " | " + Iif( ValType(oJson["errorMessages"][nMsgPeM]["message"]) != "U", STR0107 + oJson["errorMessages"][nMsgPeM]["message"], "null" )) )//"ID de integração: "##"Código da validação: "##"Mensagem: "
            Next nMsgPeM
        EndIf
    EndIf

Next nReg

If !lJob .And. ( !Empty(aLogPeM) .Or. !Empty(aLogDesp) )
    If lErro .And. Empty(cFeedzURL)
        fMsgErr()
    EndIf
    fMakeLog( { aLogPeM, aLogDesp }, aTitle, Nil, Nil, Nil, OemToAnsi(STR0031), "G", "L", Nil, .F.) //"Log de Ocorrências"
EndIf

RestArea(aAreaREF)

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} fErrorPeM()
Função que mostra os erros de validação do processamento no P&M/na Feedz
@author  Allyson Luiz Mesashi
@since   06/05/2022
/*/
//-------------------------------------------------------------------
Static Function fErrorPeM()

Local aErroPeM  := {}
Local aLogPeM   := {}
Local aTitle    := { "" }
Local nMsgPeM   := 0
Local oJson     := Nil

If REF->REF_STATUS == "3"
    oJson := JsonObject():New()
    oJson:fromJson( REF->REF_RETORN )
    aErroPeM := oJson["errorMessages"]
    If ValType(aErroPeM) == "A"
        For nMsgPeM := 1 To Len(aErroPeM)
            FiltraLog( aLogPeM, STR0105 + Iif(ValType(aErroPeM[nMsgPeM]["integrationId"]) != "U", aErroPeM[nMsgPeM]["integrationId"] , "null" ) + " | " + STR0106 + Iif( ValType(aErroPeM[nMsgPeM]["code"]) != "U", cValToChar( aErroPeM[nMsgPeM]["code"] ) , "null" ) + " | " + Iif( ValType(aErroPeM[nMsgPeM]["message"]) != "U", STR0107 + aErroPeM[nMsgPeM]["message"], "null" ) )//"ID de integração: "##"Código da validação: "##"Mensagem: "
        Next nMsgPeM
    Else
        FiltraLog( aLogPeM, REF->REF_RETORN )
    EndIf

    fMakeLog( { aLogPeM }, aTitle, Nil, Nil, Nil, OemToAnsi(STR0031), "G", "L", Nil, .F.) //"Log de Ocorrências"
Else
    Help( " ", 1, OemToAnsi(STR0001), Nil, OemToAnsi(STR0144), 1, 0 )//"Atenção"###"O lote não possui erro retornado."
EndIf

Return

/*/{Protheus.doc} FiltraLog
//Função que quebra o texto para gravação no log
@author paulo.inzonha
@since 25/07/2019
@version 1.0
@return NIL
@param aLogCalc, array, Array que deve ser preenchido com a mensagem do log
@param cTexto, characters, Texto que deve ser apresentado no log
@type function
/*/
Static Function FiltraLog(aLogCalc, cTexto)
Local nPos := 0

If Len(Alltrim(cTexto)) >= 210
	nPos := At(" ",cTexto,200)
	If nPos > 0
		aAdd(aLogCalc, substr(cTexto,1,nPos))
		aAdd(aLogCalc, substr(cTexto,nPos))
	Else
		aAdd(aLogCalc, substr(cTexto,1,209))
		aAdd(aLogCalc, substr(cTexto,210))
	EndIf
Else
	aAdd(aLogCalc, cTexto)
EndIf

Return( NIL )

//-------------------------------------------------------------------
/*/{Protheus.doc} f939BTDN()
Função para abrir página de documentação do TDN
@author  Allyson Luiz Mesashi
@since   12/05/2022
/*/
//-------------------------------------------------------------------
Function f939BTDN()

DEFAULT cFeedzURL   := SuperGetMv( 'MV_APIFEE1', Nil, "" )

ShellExecute( "open", Iif( Empty(cFeedzURL), "https://tdn.totvs.com/pages/viewpage.action?pageId=680969647", "https://tdn.totvs.com/pages/viewpage.action?pageId=756450483" ), "", "", 1 )

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} fGp939Leg()
Função para abrir a tela de legenda
@author  Allyson Luiz Mesashi
@since   13/02/2023
/*/
//-------------------------------------------------------------------
Function fGp939Leg()

Local aLegenda := {}

aAdd( aLegenda, { "BR_AZUL", OemToAnsi(STR0125) } )//"Não iniciado"
aAdd( aLegenda, { "BR_AMARELO", OemToAnsi(STR0126) } )//"Executando"
aAdd( aLegenda, { "BR_VERDE", OemToAnsi(STR0127) } )//"Concluído"
aAdd( aLegenda, { "BR_VERMELHO", OemToAnsi(STR0128) } )//"Houve erro de validação"
aAdd( aLegenda, { "BR_PRETO", OemToAnsi(STR0137) } )//"Não encontrado"

BrwLegenda( OemToAnsi(STR0263), OemToAnsi(STR0263), aLegenda )//"Legenda"

Return Nil
