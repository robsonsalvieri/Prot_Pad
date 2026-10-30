#INCLUDE "OGX010.ch"
#include "protheus.ch"
#include "fwmvcdef.ch"
#include 'parmtype.ch'
#INCLUDE "FWBROWSE.CH"
#INCLUDE "TOTVS.CH"

/////////////////////////////////////////////////////////////////
////															     ////
////  FUNÇÕES GENÉRICAS RELACIONADAS A CONTRATO              ////
////															     ////
/////////////////////////////////////////////////////////////////

#define ACOL_CODCTR 	01
#define ACOL_DESCRI	02
#define ACOL_CODPRO	03
#define ACOL_DATA		04
#define ACOL_TIPO		05
#define ACOL_CODENT	06
#define ACOL_LOJENT	07
#define ACOL_NOMENT	08
#define ACOL_NLJENT	09
#define ACOL_QTDCTR	10
#define ACOL_QSLFCO	11
#define ACOL_SLDFIS	12
#define ACOL_MODAL	13
#define ACOL_CODOPE	14
#define ACOL_VAZIO	15

#define ACOL_QTDREF 16
#define ACOL_QSLREF	17
#define ACOL_ITEM	18
#define ACOL_SEQPRI	19

Static __cTpRoman   := ''
Static __lnewNeg	:= SuperGetMv('MV_AGRO002', , .F.) // Parametro de utilização do novo modelo de negocio

/*/{Protheus.doc} OGX010CT
Rotina para consulta personalizada da tabela de Contratos
@type function
@version P12
@author	Bruna Fagundes Rocio
@since 	08/06/2010
@param cTipo, character, tipo do contrato
@param cCodEnt, character, codigo da entidade
@param cLojEnt, character, codigo da loja da entidade
@param cSafra, character, codigo da safra
@param cCodPro, character, codigo do produto
@param lNotReadVar, logical, se filtra por regra fiscal
@param cFilRom, character, filial do romaneio
@param aItRefs, array, itens do romaneio(NJM) com o contrato com regra fiscal e qtd ja selecionada
/*/
Function OGX010CT( cTipo, cCodEnt, cLojEnt, cSafra, cCodPro, lNotReadVar, lRegArm, cFilRom, aItRefs)
	Local aAreaAtu	:= GetArea()
	Local nOpcX		:= 0
	Local aButtons	:= {}
	Local nTamH 		:= ( GetScreenRes()[1] * 0.7 )
	Local nTamV 		:= ( GetScreenRes()[2] * 0.7 )
	
	Local aCpsBrw := {}
	Local aIndBrw := {}
	Local nx := 0
	Local aRetTMP := {}
	Local aFldfilter := {}
	Local aColunBrw := {}
	Local aAtCtrRom := {}
	Local cNoAlCtrRom := ""

	Private _cAlCtrRom 	:= nil
	Private oDlg		:= Nil
	Private oBrwCtrRom	:= Nil
	Private aItens	:= Array(1, 15)
	Private nSSdo    := 1

	Public __cCodigo	:= Space( TamSX3( "NJR_CODCTR" )[1] )
	Public __cItEtg		:= IIF( ColumnPos("N9A_ITEM")   > 0, Space(TamSX3("N9A_ITEM")  [1]), "" )
	Public __cItRef		:= IIF( ColumnPos("N9A_SEQPRI") > 0, Space(TamSX3("N9A_SEQPRI")[1]), "" )
	Public __cTESRef    := IIF( ColumnPos("N9A_SEQPRI") > 0, Space(TamSX3("N9A_TES")   [1]), "" )
	Public __nSldRef    := 0
	
	Default lRegArm := .F. // .F. - Não considera as regras fiscais para seleção do contrato
	Default cTipo	:= ""
	Default cCodEnt	:= ""
	Default cLojEnt	:= ""
	Default cSafra	:= ""
	Default cCodPro	:= ""
	Default lNotReadVar := .F.
	Default cFilRom	:= ""
	Default aItRefs	:= []

	Pergunte( "OGX010", .F. )	
	nSSdo  := mv_par01

	If lNotReadVar 
		__cCodigo := Space( TamSX3( "NJR_CODCTR" )[1] )
	Else
		__cCodigo := &( ReadVar() )
	EndIf

	oDlg := TDialog():New( 0, 0, nTamV, nTamH, STR0005+" - "+STR0007, , , , , , , , , .t. ) //"Consulta Personalizada" - "Contrato"
	
	oDlg:lEscClose := .f.

	oPnlT := TPanel():New( 1, 1, , oDlg, , , , , , 0, 0, .f., .t. )
	oPnlT:Align := CONTROL_ALIGN_ALLCLIENT

	oPnlB := TPanel():New( 0, 0, , oPnlT, , , , , , 15, 15, .f., .f. )
	oPnlB:Align := CONTROL_ALIGN_ALLCLIENT

	aCpsBrw := {{ "NJR_CODCTR"	, TamSX3( "NJR_CODCTR" )[ 3 ], TamSX3( "NJR_CODCTR" )[ 1 ], TamSX3( "NJR_CODCTR" )[ 2 ] , RetTitle( "NJR_CODCTR" ), PesqPict("NJR","NJR_CODCTR") },;
				{ "NJR_DESCRI"	, TamSX3( "NJR_DESCRI" )[ 3 ], TamSX3( "NJR_DESCRI" )[ 1 ], TamSX3( "NJR_DESCRI" )[ 2 ] , RetTitle( "NJR_DESCRI" ), PesqPict("NJR","NJR_DESCRI") },;
				{ "N9A_ITEM" 	, TamSX3( "N9A_ITEM" )[ 3 ]	 , TamSX3( "N9A_ITEM" )[ 1 ]  , TamSX3( "N9A_ITEM" )[ 2 ] , RetTitle( "N9A_ITEM" ), PesqPict("N9A","N9A_ITEM") },;
				{ "N9A_SEQPRI" 	, TamSX3( "N9A_SEQPRI" )[ 3 ], TamSX3( "N9A_SEQPRI" )[ 1 ], TamSX3( "N9A_SEQPRI" )[ 2 ] , RetTitle( "N9A_SEQPRI" ), PesqPict("N9A","N9A_SEQPRI") },;
				{ "NJR_CODSAF" 	, TamSX3( "NJR_CODSAF" )[ 3 ], TamSX3( "NJR_CODSAF" )[ 1 ], TamSX3( "NJR_CODSAF" )[ 2 ] , RetTitle( "NJR_CODSAF" ), PesqPict("NJR","NJR_CODSAF") },;
				{ "NJR_CODPRO" 	, TamSX3( "NJR_CODPRO" )[ 3 ], TamSX3( "NJR_CODPRO" )[ 1 ], TamSX3( "NJR_CODPRO" )[ 2 ] , RetTitle( "NJR_CODPRO" ), PesqPict("NJR","NJR_CODPRO") },;
				{ "NJR_DATA" 	, TamSX3( "NJR_DATA" )[ 3 ]	 , TamSX3( "NJR_DATA" )[ 1 ]  , TamSX3( "NJR_DATA" )[ 2 ] , RetTitle( "NJR_DATA" ), PesqPict("NJR","NJR_DATA") },;
				{ "NJR_TIPO" 	, TamSX3( "NJR_TIPO" )[ 3 ]	 , TamSX3( "NJR_TIPO" )[ 1 ]  , TamSX3( "NJR_TIPO" )[ 2 ] , RetTitle( "NJR_TIPO" ), PesqPict("NJR","NJR_TIPO") },;
				{ "NJR_CODENT" 	, TamSX3( "NJR_CODENT" )[ 3 ], TamSX3( "NJR_CODENT" )[ 1 ], TamSX3( "NJR_CODENT" )[ 2 ] , RetTitle( "NJR_CODENT" ), PesqPict("NJR","NJR_CODENT") },;
				{ "NJR_LOJENT" 	, TamSX3( "NJR_LOJENT" )[ 3 ], TamSX3( "NJR_LOJENT" )[ 1 ], TamSX3( "NJR_LOJENT" )[ 2 ] , RetTitle( "NJR_LOJENT" ), PesqPict("NJR","NJR_LOJENT") },;
				{ "NJR_NOMENT" 	, TamSX3( "NJR_NOMENT" )[ 3 ], TamSX3( "NJR_NOMENT" )[ 1 ], TamSX3( "NJR_NOMENT" )[ 2 ] , RetTitle( "NJR_NOMENT" ), PesqPict("NJR","NJR_NOMENT") },;
				{ "NJR_NLJENT" 	, TamSX3( "NJR_NLJENT" )[ 3 ], TamSX3( "NJR_NLJENT" )[ 1 ], TamSX3( "NJR_NLJENT" )[ 2 ] , RetTitle( "NJR_NLJENT" ), PesqPict("NJR","NJR_NLJENT") },;
				{ "NJR_QTDCTR" 	, TamSX3( "NJR_QTDCTR" )[ 3 ], TamSX3( "NJR_QTDCTR" )[ 1 ], TamSX3( "NJR_QTDCTR" )[ 2 ] , RetTitle( "NJR_QTDCTR" ), PesqPict("NJR","NJR_QTDCTR") },;
				{ "NJR_QSLFCO" 	, TamSX3( "NJR_QSLFCO" )[ 3 ], TamSX3( "NJR_QSLFCO" )[ 1 ], TamSX3( "NJR_QSLFCO" )[ 2 ] , RetTitle( "NJR_QSLFCO" ), PesqPict("NJR","NJR_QSLFCO") },;
				{ "NJR_SLDFIS" 	, TamSX3( "NJR_SLDFIS" )[ 3 ], TamSX3( "NJR_SLDFIS" )[ 1 ], TamSX3( "NJR_SLDFIS" )[ 2 ] , RetTitle( "NJR_SLDFIS" ), PesqPict("NJR","NJR_SLDFIS") },;
				{ "N9A_TES"    	, TamSX3( "N9A_TES" )[ 3 ]	 , TamSX3( "N9A_TES" )[ 1 ]   , TamSX3( "N9A_TES" )[ 2 ] , RetTitle( "N9A_TES" ), PesqPict("N9A","N9A_TES") },;
				{ "N9A_QUANT"  	, TamSX3( "N9A_QUANT" )[ 3 ] , TamSX3( "N9A_QUANT" )[ 1 ] , TamSX3( "N9A_QUANT" )[ 2 ] , RetTitle( "N9A_QUANT" ), PesqPict("N9A","N9A_QUANT") },;
				{ "N9A_SDONF"  	, TamSX3( "N9A_SDONF" )[ 3 ] , TamSX3( "N9A_SDONF" )[ 1 ] , TamSX3( "N9A_SDONF" )[ 2 ] , RetTitle( "N9A_SDONF" ), PesqPict("N9A","N9A_SDONF") },;
				{ "NJR_MODAL"  	, TamSX3( "NJR_MODAL" )[ 3 ] , (TamSX3( "NJR_MODAL" )[ 1 ]+TamSX3("NNO_DESCRI")[1]), TamSX3( "NJR_MODAL" )[ 2 ] , RetTitle( "NJR_MODAL" ), PesqPict("NJR","NJR_MODAL") },;
				{ "NJR_CODOPE" 	, TamSX3( "NJR_CODOPE" )[ 3 ], (TamSX3( "NJR_CODOPE" )[ 1 ]+TamSX3("NK5_DESMOD")[1]), TamSX3( "NJR_CODOPE" )[ 2 ] , RetTitle( "NJR_CODOPE" ), PesqPict("NJR","NJR_CODOPE") }}

	aIndBrw := { "NJR_CODCTR","NJR_CODENT+NJR_LOJENT+NJR_CODSAF","NJR_CODSAF+NJR_CODPRO","NJR_CODOPE" } // Definição dos índices
	//--- Criação das tabelas temporárias ---//
	aRetTMP 	:= AGRCRIATRB( , aCpsBrw, aIndBrw, FunName(), .T. )
	cNoAlCtrRom := aRetTMP[3] //Nome do arquivo temporário
	_cAlCtrRom  := aRetTMP[4] //Nome do alias do arquivo temporario
	aAtCtrRom 	:= aRetTMP[5] //Matriz com a estrutura do arquivo temporario + label e picutre
	
	aIndBrw	:= AGRINDICONS(aIndBrw, aAtCtrRom )

	aFldfilter := AGRITEMCBRW(aAtCtrRom)

	For nX := 1 To Len(aCpsBrw)
		If !lRegArm .and. aCpsBrw[nX][1] $ "N9A_ITEM|N9A_SEQPRI|N9A_TES|N9A_QUANT|N9A_SDONF"
			LOOP //não inclui na tela se não for armazenagem
		EndIf
		AAdd(aColunBrw,FWBrwColumn():New())
		aColunBrw[Len(aColunBrw)]:SetData(&("{||"+aCpsBrw[nX][1]+"}"))
		aColunBrw[Len(aColunBrw)]:SetType(aCpsBrw[nX][2])
		aColunBrw[Len(aColunBrw)]:SetSize(aCpsBrw[nX][3])
		aColunBrw[Len(aColunBrw)]:SetDecimal(aCpsBrw[nX][4])
		aColunBrw[Len(aColunBrw)]:SetTitle(aCpsBrw[nX][5])			
		aColunBrw[Len(aColunBrw)]:SetPicture(aCpsBrw[nX][6])
		//aColunBrw[Len(aColunBrw)]:SetAlign( "LEFT" )//Define alinhamento
		aColunBrw[Len(aColunBrw)]:SetReadVar(aCpsBrw[nX][1])

	Next nX
	
	f001AItens(cTipo, cCodEnt, cLojEnt, cSafra, cCodPro, lRegArm, cFilRom, aItRefs)

	oBrwCtrRom := FWFormBrowse():New()
	oBrwCtrRom:SetOwner(oPnlT)
	oBrwCtrRom:SetProfileID("OGX010CT")
	oBrwCtrRom:SetDataTable(.T.)
	oBrwCtrRom:SetTemporary(.T.)
	oBrwCtrRom:SetAlias(_cAlCtrRom)
	oBrwCtrRom:DisableDetails()
	oBrwCtrRom:DisableConfig()	
	oBrwCtrRom:DisableReport()	
	oBrwCtrRom:SetColumns(aColunBrw)
	oBrwCtrRom:SetUseFilter(.T.)    
	oBrwCtrRom::SetUseCaseFilter(.T.)
    oBrwCtrRom:SetDBFFilter(.T.)	                   
    oBrwCtrRom:SetFieldFilter(aFldfilter)   
	oBrwCtrRom:SetSeek(,aIndBrw)
    oBrwCtrRom:SetDoubleClick( {||nOpcX := 1, oDlg:End()})
	
	oBrwCtrRom:Activate()	
	
	Aadd(aButtons,{, {|| OGX010PAR(cTipo, cCodEnt, cLojEnt, cSafra, cCodPro)}, "Parâmetros"})

	oDlg:Activate( , , , .t., { || .t. }, , { || EnchoiceBar( oDlg, {|| nOpcX := 1, oDlg:End() },{|| nOpcX := 0, oDlg:End() },, @aButtons,,,.f.,.f.,.f.,.t.,.f. ) } )

	If nOpcX > 0 .And. Len( aItens ) > 0
		__cCodigo := (_cAlCtrRom)->NJR_CODCTR //retorno consulta
		
		If lRegArm		
			__cItEtg  := (_cAlCtrRom)->N9A_ITEM
			__cItRef  := (_cAlCtrRom)->N9A_SEQPRI
			__cTESRef := (_cAlCtrRom)->N9A_TES	
			__nSldRef := (_cAlCtrRom)->N9A_SDONF
		EndIf
	EndIf
	AGRDELETRB(_cAlCtrRom,cNoAlCtrRom)
	
	RestArea( aAreaAtu )
Return( .t. )

/** {Protheus.doc} OGX010TRCT
Rotina para consulta padrao da tabela de Contratos para Transferência

@param cTipo, character, Tipo do contrato
@return logical, .T.
@author	Bruna Fagundes Rocio
@since 	08/06/2010
@Uso: 		SIGAAGR - Gestão Agrícola
@type function
*/
Function OGX010TRCT( cTipo, cCodEnt, cLojEnt, cSafra, cCultra )
	Local aAreaAtu	:= GetArea()
	Local nOpcX		:= 0
	Local nOpcao		:= 0
	Local aButtons	:= {}
	Local nTamH 		:= ( GetScreenRes()[1] - 400 )
	Local nTamV 		:= ( GetScreenRes()[2] - 400 )

	Private oDlg		:= Nil
	Private oBrowse	:= Nil
	Private aItens	:= Array(1, 15)

	Public __cCodigo	:= &( ReadVar() )

	oDlg := TDialog():New( 0, 0, nTamV, nTamH, STR0005+" - "+STR0007, , , , , CLR_BLACK, CLR_WHITE, , , .t. ) //"Consulta Personalizada" - "Contrato"
	oDlg:lEscClose := .f.

	oPnlT := TPanel():New( 1, 1, , oDlg, , , , , , 0, 0, .f., .t. )
	oPnlT:Align := CONTROL_ALIGN_ALLCLIENT

	oPnlB := TPanel():New( 0, 0, , oPnlT, , , , , RGB(67,70,87), 15, 15, .f., .f. )
	oPnlB:Align := CONTROL_ALIGN_LEFT

	oBrowse := TCBrowse():New( 1, 1, 260, 156, , , , oPnlT, , , , {|| nOpcao := oBrowse:nAt }, {|| nOpcao := oBrowse:nAt, nOpcX := 1, oDlg:End() }, , , , , , , .f., ,.t., ,.f., , , )
	oBrowse:Align := CONTROL_ALIGN_ALLCLIENT

	oBrowse:AddColumn( TCColumn():New( RetTitle("NJR_CODCTR"), 	{ || aItens[oBrowse:nAt,ACOL_CODCTR] }, , , , "LEFT" ,35 , .f., .t., , , ,.f., ) )
	oBrowse:AddColumn( TCColumn():New( RetTitle("NJR_DESCRI"), 	{ || aItens[oBrowse:nAt,ACOL_DESCRI] }, , , , "LEFT" ,80 , .f., .t., , , ,.f., ) )
	oBrowse:AddColumn( TCColumn():New( RetTitle("NJR_CODPRO"), 	{ || aItens[oBrowse:nAt,ACOL_CODPRO] }, , , , "LEFT" ,80 , .f., .t., , , ,.f., ) )
	oBrowse:AddColumn( TCColumn():New( RetTitle("NJR_DATA"), 	{ || aItens[oBrowse:nAt,ACOL_DATA] }  , , , , "LEFT" ,40 , .f., .t., , , ,.f., ) )
	oBrowse:AddColumn( TCColumn():New( RetTitle("NJR_TIPO"), 	{ || aItens[oBrowse:nAt,ACOL_TIPO] }  , , , , "LEFT" ,20 , .f., .t., , , ,.f., ) )
	oBrowse:AddColumn( TCColumn():New( RetTitle("NJR_CODENT"), 	{ || aItens[oBrowse:nAt,ACOL_CODENT] }, , , , "LEFT" ,40 , .f., .t., , , ,.f., ) )
	oBrowse:AddColumn( TCColumn():New( RetTitle("NJR_LOJENT"), 	{ || aItens[oBrowse:nAt,ACOL_LOJENT] }, , , , "LEFT" ,20 , .f., .t., , , ,.f., ) )
	oBrowse:AddColumn( TCColumn():New( RetTitle("NJR_NOMENT"), 	{ || aItens[oBrowse:nAt,ACOL_NOMENT] }, , , , "LEFT" ,80 , .f., .t., , , ,.f., ) )
	oBrowse:AddColumn( TCColumn():New( RetTitle("NJR_NLJENT"), 	{ || aItens[oBrowse:nAt,ACOL_NLJENT] }, , , , "LEFT" ,80 , .f., .t., , , ,.f., ) )
	oBrowse:AddColumn( TCColumn():New( RetTitle("NJR_QTDCTR"), 	{ || aItens[oBrowse:nAt,ACOL_QTDCTR] }, , , , "RIGHT",50 , .f., .t., , , ,.f., ) )
	oBrowse:AddColumn( TCColumn():New( RetTitle("NJR_QSLFCO"), 	{ || aItens[oBrowse:nAt,ACOL_QSLFCO] }, , , , "RIGHT",50 , .f., .t., , , ,.f., ) )
	oBrowse:AddColumn( TCColumn():New( RetTitle("NJR_SLDFIS"), 	{ || aItens[oBrowse:nAt,ACOL_SLDFIS] }, , , , "RIGHT",50 , .f., .t., , , ,.f., ) )
	oBrowse:AddColumn( TCColumn():New( RetTitle("NJR_MODAL"), 	{ || aItens[oBrowse:nAt,ACOL_MODAL] } , , , , "LEFT" ,80 , .f., .t., , , ,.f., ) )
	oBrowse:AddColumn( TCColumn():New( RetTitle("NJR_CODOPE"), 	{ || aItens[oBrowse:nAt,ACOL_CODOPE] }, , , , "LEFT" ,90 , .f., .t., , , ,.f., ) )
	oBrowse:AddColumn( TCColumn():New( "", 						{ || aItens[oBrowse:nAt,ACOL_VAZIO] } , , , , "LEFT" , , .f., .t., , , ,.f., ) )

	f002AItens( cTipo, cCodEnt, cLojEnt, cSafra, cCultra )

	oDlg:Activate( , , , .t., { || .t. }, , { || EnchoiceBar( oDlg, {|| nOpcX := 1, oDlg:End() },{|| nOpcX := 0, oDlg:End() },, @aButtons ) } )

	If nOpcX > 0 .And. Len( aItens ) > 0
		__cCodigo := aItens[ nOpcao, 1 ]
	EndIf

	RestArea( aAreaAtu )
Return( .t. )

/*/{Protheus.doc} f001AItens
Gera os dados para a consulta personalizada de seleção de contratos
@type function
@version P12
@author Bruna Fagundes Rocio
@since 08/06/2010
@param cTipo, character, tipo do contrato
@param cCodEnt, character, codigo da entidade
@param cLojEnt, character, codigo da loja da entidade
@param cSafra, character, codigo da safra
@param cCodPro, character, codigo do produto
@param lRegArm, logical, se filtra por regra fiscal
@param cFilRom, character, filial do romaneio
@param aItRefs, array, itens do romaneio(NJM) com o contrato com regra fiscal e qtd ja selecionada
/*/
Static Function f001AItens(cTipo, cCodEnt, cLojEnt, cSafra, cCodPro, lRegArm, cFilRom, aItRefs)
	Local aAreaAtu	:= GetArea()
	Local nX			:= 1
	Local lCtrOK		:=.t.
	Local cFiltroDet	:= ""
	Local cCmpsN9A		:= ""
	Local cInJoinN9A	:= "" 
	Local cFiltroN9A	:= ""
	Local nPos			:= 0
	Local nPesoCons		:= 0
	Local cQryNJR		:= GetNextAlias()

	If Select( _cAlCtrRom ) > 0 
		(_cAlCtrRom)->(dbGoTop())
        If !InTransact()
			DbSelectArea( _cAlCtrRom )
			Zap
		Else //OGA250C
			While (_cAlCtrRom)->(!Eof())
				(_cAlCtrRom)->(DbDelete())
				(_cAlCtrRom)->(DbSkip())
			EndDo
		EndIf
    Endif

	cFiltroDet  += " NJR.NJR_TIPO   = '" + cTipo + "' AND"

	If !Empty( AllTrim( cCodEnt ) )
		cFiltroDet  += " NJR.NJR_CODENT  = '" + cCodEnt + "' AND"
	Endif

	If !Empty( AllTrim( cLojEnt ) )
		cFiltroDet  += " NJR.NJR_LOJENT  = '" + cLojEnt + "' AND"
	Endif

	If !Empty( AllTrim( cSafra ) )
		cFiltroDet  += " NJR.NJR_CODSAF  = '" + cSafra + "' AND"
	Endif

	If !Empty( AllTrim( cCodPro ) )
		cFiltroDet  += " NJR.NJR_CODPRO  = '" + cCodPro + "' AND"
	Endif

	If !empty(nSSdo) .And. nSSdo = 2 //Nao exibir contratos sem saldo
		cFiltroDet  += " (NJR.NJR_QSLFCO <> 0 OR NJR.NJR_SLDFIS <> 0) AND "
	EndIf

	cFiltroDet := "%" + cFiltroDet + "%" 
	
	If lRegArm
		cCmpsN9A   := ", N9A_ITEM, N9A_SEQPRI, N9A_QUANT, N9A_SDONF, N9A_TES "
				
		cInJoinN9A := " INNER JOIN "+ RetSqlName("N9A") + " N9A ON N9A.D_E_L_E_T_ = ' ' AND N9A.N9A_FILIAL = NJR.NJR_FILIAL AND "
		cInJoinN9A += " N9A.N9A_CODCTR = NJR.NJR_CODCTR "
		
		cFiltroN9A := " AND (N9A.N9A_FILORG = '" + cFilRom + "' OR N9A.N9A_FILORG = '') AND N9A.N9A_SDONF > 0 "			
	EndIf
	
	cCmpsN9A   := "%" + cCmpsN9A + "%"
	cInJoinN9A := "%" + cInJoinN9A + "%"
	cFiltroN9A := "%" + cFiltroN9A + "%"
	
	BeginSql Alias cQryNJR
	column NJR_DATA as Date

	Select
	NJR_CODCTR,
	NJR_DESCRI,
	NJR_DATA,
	NJR_TIPO,
	NJR_CODENT,
	NJR_LOJENT,
	NJR_QTDCTR,
	NJR_QSLFCO,
	NJR_QTEFCO,
	NJR_QTEFIS,
	NJR_QTSFCO,
	NJR_QTSFIS,
	NJR_SLDFIS,
	NJR_QTEFCO,
	NJR_QTSFCO,
	NJR_QTEFIS,
	NJR_QTSFIS,
	NJR_MODAL,
	NJR_CODOPE,
	NJR_CODSAF,
	NJR_CODPRO,
	NNO_DESCRI
	%exp:cCmpsN9A% // Campos da N9A
	FROM %table:NJR% NJR
	LEFT JOIN %table:NK5% NK5
	ON NK5.%NotDel% And 
	NK5.NK5_FILIAL = %xFilial:NK5% And 
	NK5.NK5_CODIGO = NJR.NJR_MODAL 
	LEFT JOIN %table:NNO% NNO
	ON NNO.%NotDel% And 
	NNO.NNO_FILIAL = %xFilial:NNO% And 
	NNO.NNO_CODIGO = NJR.NJR_CODOPE
	%exp:cInJoinN9A%  // Inner Join com a N9A
	WHERE NJR.%NotDel% And
	NJR.NJR_FILIAL = %xFilial:NJR% And
	%exp:cFiltroDet%
	NJR.NJR_STATUS in ( 'P', 'A', 'I' )
	%exp:cFiltroN9A% // Filtro (Apenas mostrar regras fiscais com saldo)
	ORDER BY NJR_CODCTR
	EndSql

	While (cQryNJR)->(!Eof())

		lCtrOk := .t.
		// Para Romaneios de devolução somente mostra os q possuem saldo
		IF __cTpRoman $ "6|7"  // Se for romaneio de devoluções ( 6 = (S)Depositio ou 7 = (E)Remessa ) 
			IF ! (cQryNJR)->( NJR_QSLFCO ) > 0 .Or.  ! (cQryNJR)->( NJR_SLDFIS ) > 0 // Verifica o Saldo
				lCtrOk := .f.
			EndIF
		Else

			// Para Romaneios de devolução compra
			IF __cTpRoman $ "8"  // Se for romaneio de devoções de compra ou venda, pode devolver o que entregou
				IF ! ((cQryNJR)->( NJR_QTEFCO ) - (cQryNJR)->( NJR_QTSFCO )) > 0 .Or.  ! ((cQryNJR)->( NJR_QTEFIS ) - (cQryNJR)->( NJR_QTSFIS )) > 0 // Verifica o Saldo
					lCtrOk := .f.
				EndIF
			Else

				// Para Romaneios de devolução venda
				IF __cTpRoman $ "9"  // Se for romaneio de devoções de compra ou venda, pode devolver o que entregou
					IF ! ((cQryNJR)->( NJR_QTSFCO ) - (cQryNJR)->( NJR_QTEFCO )) > 0 .Or.  ! ((cQryNJR)->( NJR_QTSFIS ) - (cQryNJR)->(NJR_QTEFIS )) > 0 // Verifica o Saldo
						lCtrOk := .f.
					EndIF
				EndIF
			EndIF
		EndIF 

		If  lCtrOK	
		
			If lRegArm
				nPos := aScan(aItRefs, {|x| AllTrim(x[1]) == AllTrim((cQryNJR)->(NJR_CODCTR)+(cQryNJR)->(N9A_ITEM)+(cQryNJR)->(N9A_SEQPRI))})
							
				nPesoCons := 0
				
				If nPos > 0
					nPesoCons := aItRefs[nPos][2]
				EndIf
				
				If nPesoCons >= (cQryNJR)->(N9A_SDONF)
					dbSkip()
					LOOP					
				EndIf	
			EndIf

			DbSelectArea( _cAlCtrRom )
			RecLock((_cAlCtrRom),.T.)
			(_cAlCtrRom)->NJR_CODCTR   	:= (cQryNJR)->( NJR_CODCTR )
			(_cAlCtrRom)->NJR_DESCRI   	:= (cQryNJR)->( NJR_DESCRI )
			(_cAlCtrRom)->N9A_ITEM   	:= IIF(lRegArm,(cQryNJR)->(N9A_ITEM) , "")
			(_cAlCtrRom)->N9A_SEQPRI   	:= IIF(lRegArm,(cQryNJR)->(N9A_SEQPRI) , "")
			(_cAlCtrRom)->NJR_CODSAF   	:= (cQryNJR)->( NJR_CODSAF )
			(_cAlCtrRom)->NJR_CODPRO   	:= (cQryNJR)->( NJR_CODPRO )
			(_cAlCtrRom)->NJR_DATA   	:= (cQryNJR)->( NJR_DATA )
			(_cAlCtrRom)->NJR_TIPO   	:= (cQryNJR)->( NJR_TIPO )
			(_cAlCtrRom)->NJR_CODENT   	:= (cQryNJR)->( NJR_CODENT )
			(_cAlCtrRom)->NJR_LOJENT   	:= (cQryNJR)->( NJR_LOJENT )
			(_cAlCtrRom)->NJR_NOMENT   	:= POSICIONE('NJ0',1,XFILIAL('NJ0')+(cQryNJR)->NJR_CODENT+(cQryNJR)->NJR_LOJENT,'NJ0_NOME')
			(_cAlCtrRom)->NJR_NLJENT   	:= POSICIONE('NJ0',1,XFILIAL('NJ0')+(cQryNJR)->NJR_CODENT+(cQryNJR)->NJR_LOJENT,'NJ0_NOMLOJ') 
			(_cAlCtrRom)->NJR_QTDCTR   	:= (cQryNJR)->( NJR_QTDCTR )
			(_cAlCtrRom)->NJR_QSLFCO   	:= (cQryNJR)->( NJR_QSLFCO )
			(_cAlCtrRom)->NJR_SLDFIS   	:= (cQryNJR)->( NJR_SLDFIS )
			(_cAlCtrRom)->N9A_QUANT   	:= IIF(lRegArm,(cQryNJR)->(N9A_QUANT) , 0)
			(_cAlCtrRom)->N9A_SDONF   	:= IIF(lRegArm,((cQryNJR)->(N9A_SDONF) - nPesoCons) , 0)
			(_cAlCtrRom)->N9A_TES   	:= IIF(lRegArm,(cQryNJR)->(N9A_TES) , "")
			(_cAlCtrRom)->NJR_MODAL   	:= (cQryNJR)->( NJR_MODAL ) + " " + POSICIONE('NK5',1,XFILIAL('NK5')+(cQryNJR)->( NJR_MODAL ) ,'NK5_DESMOD')
			(_cAlCtrRom)->NJR_CODOPE   	:= (cQryNJR)->( NJR_CODOPE ) + " " + (cQryNJR)->( NNO_DESCRI )							
			(_cAlCtrRom)->(MsUnLock())
														
			nX++
		EndIf

		(cQryNJR)->(dbSkip())
	EndDo
	(cQryNJR)->( dbCloseArea() )

	If Type("oBrwCtrRom") <> "U"
        oBrwCtrRom:Refresh(.T.)
    EndIf

	RestArea( aAreaAtu )
Return( )

/** {Protheus.doc} f002AItens
Rotina auxiliar para seleção de contratos

@param cTipo, character, Tipo do contrato
@return logical, .T.
@author	Bruna Fagundes Rocio
@since 	13/03/2015
@Uso: 		SIGAAGR - Gestão Agrícola
@type function
*/
Static Function f002AItens( cTipo, cCodEnt, cLojEnt, cSafra, cCultra )
	Local aAreaAtu  := GetArea()
	Local aTempo	  := Array( 0 )
	Local nX		  := 1

	BeginSql Alias 'QryNJR'
	column NJR_DATA as Date

	Select
	NJR_CODCTR,
	NJR_DESCRI,
	NJR_DATA,
	NJR_TIPO,
	NJR_CODENT,
	NJR_LOJENT,
	NJR_QTDCTR,
	NJR_QSLFCO,
	NJR_SLDFIS,
	NJR_MODAL,
	NJR_CODOPE,
	NJR_CODPRO,
	NNO_DESCRI
	FROM %table:NJR% NJR
	RIGHT JOIN %table:SB5% SB5
	ON SB5.B5_CULTRA = %exp:cCultra% And
	SB5.B5_COD    = NJR.NJR_CODPRO      
	LEFT JOIN %table:NK5% NK5
	ON NK5.%NotDel% And 
	NK5.NK5_CODIGO = NJR.NJR_MODAL 
	LEFT JOIN %table:NNO% NNO
	ON NNO.%NotDel% And 
	NNO.NNO_CODIGO = NJR.NJR_CODOPE 
	WHERE NJR.%NotDel% And
	NJR.NJR_TIPO   = %exp:cTipo% And
	NJR.NJR_CODENT = %exp:cCodEnt% And
	NJR.NJR_LOJENT = %exp:cLojEnt% And
	NJR.NJR_CODSAF  = %exp:cSafra% And
	NJR.NJR_STATUS in ( 'P', 'A', 'I' )
	ORDER BY NJR_CODCTR
	EndSql
	While .Not. Eof()


		aAdd( aTempo, {} )
		aAdd( aTempo[nX], QryNJR->( NJR_CODCTR ) ) 														// ACOL_CODCTR	01
		aAdd( aTempo[nX], QryNJR->( NJR_DESCRI ) ) 														// ACOL_DESCRI	02
		aAdd( aTempo[nX], QryNJR->( NJR_CODPRO ) ) 														// ACOL_DESCRI	02
		aAdd( aTempo[nX], DToC( QryNJR->( NJR_DATA ) ) ) 												// ACOL_DATA		03
		aAdd( aTempo[nX], QryNJR->( NJR_TIPO ) ) 															// ACOL_TIPO		04
		aAdd( aTempo[nX], QryNJR->( NJR_CODENT ) ) 															// ACOL_CODENT		
		aAdd( aTempo[nX], QryNJR->( NJR_LOJENT ) ) 															// ACOL_LOJENT		
		aAdd( aTempo[nX], POSICIONE('NJ0',1,XFILIAL('NJ0')+QryNJR->NJR_CODENT+QryNJR->NJR_LOJENT,'NJ0_NOME')     ) 	// ACOL_NOMENT		
		aAdd( aTempo[nX], POSICIONE('NJ0',1,XFILIAL('NJ0')+QryNJR->NJR_CODENT+QryNJR->NJR_LOJENT,'NJ0_NOMLOJ')   ) // ACOL_NLJENT		
		aAdd( aTempo[nX], Transform( QryNJR->( NJR_QTDCTR ), PesqPict( "NJR", "NJR_QTDCTR" ) ) )	// ACOL_QTDCTR	05
		aAdd( aTempo[nX], Transform( QryNJR->( NJR_QSLFCO ), PesqPict( "NJR", "NJR_QSLFCO" ) ) )	// ACOL_QSLFCO	06
		aAdd( aTempo[nX], Transform( QryNJR->( NJR_SLDFIS ), PesqPict( "NJR", "NJR_SLDFIS" ) ) )	// ACOL_SLDFIS	07
		aAdd( aTempo[nX], QryNJR->( NJR_MODAL ) + " " + POSICIONE('NK5',1,XFILIAL('NK5')+QryNJR->( NJR_MODAL ) ,'NK5_DESMOD'))// ACOL_MODAL		08
		aAdd( aTempo[nX], QryNJR->( NJR_CODOPE ) + " " + QryNJR->( NNO_DESCRI ) ) 					// ACOL_CODOPE	09
		aAdd( aTempo[nX], "" ) 																				// ACOL_VAZIO		10

		nX++


		dbSkip()
	EndDo
	QryNJR->( dbCloseArea() )

	aItens := aClone( aTempo )
	oBrowse:SetArray( aItens )

	RestArea( aAreaAtu )
Return( )


/** {Protheus.doc} OGX010TC
Retona tipo do contrato  

@param cTipo, character, Tipo do contrato
@return logical, .T.
@author	Bruna Fagundes Rocio
@since 	08/06/2010
@Uso: 		SIGAAGR - Gestão Agrícola
*/
Function OGX010TC(cTipo)
	Local cTpCtr	:= ""
    Default cTipo   := ""

	__cTpRoman := cTipo
    
	If cTipo $ "5|8"
		cTpCtr := "1"
	EndIf
	If cTipo $ "4|9"
		cTpCtr := "2"
	EndIf
	If cTipo $ "3|6"
		cTpCtr := "3"
	EndIf
	If cTipo $ "2|7"
		cTpCtr := "4"
	EndIf
	
Return( cTpCtr )

/** {Protheus.doc} OGX010BC
Rotina auxiliar para seleção de contratos
@param cTipo, character, Tipo do contrato
@return logical, .T.
@param 	cTipo   , character, - Tipo do Contrato
@param 	cCodEnt ,character, - Entidade do Contrato
@param 	cLojEnt ,character, - Loja da Entidade do Contrato
@param 	cSafra  ,character, - Safra do Contrato
@param 	cFilRom ,character, - Filial do Romaneio
@param	lRegArm ,logical , - .T. - Apresenta as regras fiscais para seleção (Remessa Formação de Lote)
return	aContr , objeto , Objeto com as posições: 
			[1] = Contrato, 
			[2] = Item Prev. Entrega, 
			[3] = Item Regra Fiscal, 
			[4] = TES da Regra Fiscal e 
			[5] = Saldo da Regra Fiscal 
@author 	Bruna Fagundes Rocio
@since 	08/06/2010
@Uso 		SIGAAGR - Gestão Agrícola
*/
Function OGX010BC(cTipo, cCodEnt, cLojEnt, cSafra, cCodPro, lRegArm, cFilRom, aItRefs)
	Local aAreaAtu  := GetArea()
	Local cCodigo	  := ""
	Local aContr	:= {}
	Local cQry 	    := ""
	Local cAliasQry := ""
	Local nQtdN9A	:= 0
	Local nPesoCons	:= 0
	Local nPos		:= 0
	
	Default lRegArm := .F.
	Default cFilRom := ""
	Default aItRefs := []

	BeginSql Alias 'QryNJR'
	Select
	Count( * ) As Total 
	From
	%table:NJR% NJR
	Where
	NJR.NJR_FILIAL = %xFilial:NJR% And
	NJR.NJR_TIPO   = %exp:cTipo% And
	NJR.NJR_CODENT = %exp:cCodEnt% And
	NJR.NJR_LOJENT = %exp:cLojEnt% And
	NJR.NJR_CODSAF  = %exp:cSafra% And
	NJR.NJR_CODPRO  = %exp:cCodPro% And
	NJR.NJR_STATUS in ( 'P', 'A', 'I' ) And
	NJR.%NotDel%
	EndSql

	If .Not. QryNJR->( Eof() )
		if QryNJR->( Total ) = 1
			BeginSql Alias 'QryNJR2'
			Select
			NJR_CODCTR 
			From
			%table:NJR% NJR
			Where
			NJR.NJR_FILIAL = %xFilial:NJR% And
			NJR.NJR_TIPO   = %exp:cTipo% And
			NJR.NJR_CODENT = %exp:cCodEnt% And
			NJR.NJR_LOJENT = %exp:cLojEnt% And
			NJR.NJR_CODSAF  = %exp:cSafra% And
			NJR.NJR_CODPRO  = %exp:cCodPro% And
			NJR.NJR_STATUS in ( 'P', 'A', 'I' ) And
			NJR.%NotDel%
			EndSql

			cCodigo := QryNJR2->( NJR_CODCTR )
			QryNJR2->( dbCloseArea( ) )
		ELSE
			if QryNJR->( Total ) = 0
				If cTipo = "3"  //Contrato de Armazenagem em 3
					dbSelectArea( "NJX" )
					dbSetOrder( 2 )
					If dbSeek( FWxFilial( "NJX" ) + cSafra + cCodPro + cTipo )			
						dbSelectArea( "NJY" )
						dbSetOrder( 2 ) //NJY_FILIAL+NJY_CODENT+NJY_LOJENT+NJY_CODSAF+NJY_CODPRO+NJY_TIPO
						If .Not. dbSeek( FWxFilial("NJY") + cCodEnt + cLojEnt + NJX->NJX_CODSAF + NJX->NJX_CODPRO + NJX->NJX_TIPO )	
							RecLock( "NJY", .t. )
							NJY_FILIAL	:= NJX->NJX_FILIAL
							NJY_CODMOD	:= NJX->NJX_CODMOD
							NJY_TIPO	:= NJX->NJX_TIPO
							NJY_CODENT	:= cCodEnt
							NJY_LOJENT	:= cLojEnt
							NJY_CODSAF	:= NJX->NJX_CODSAF
							NJY_CODPRO	:= NJX->NJX_CODPRO
							MsUnLock()
						EndIf
					EndIf
				Endif
				dbSelectArea( "NJY" )
				dbSetorder( 2 )                                                                            
				If dbSeek( FWxFilial( "NJY" ) + cCodEnt + cLojEnt + cSafra + cCodPro + cTipo )
					dbSelectArea( "NJX" )
					dbSetOrder( 1 )
					If dbSeek( FWxFilial( "NJX" ) + NJY->( NJY_CODMOD ) )
						MsgRun( STR0006, STR0007 , {|| cCodigo := GeraNJR( ) } ) //"Gerando contrato dinâmico para a Entidade..."###"Contrato"
					EndIf
				EndIf
			EndIf
		EndIf
	EndIf

	QryNJR->( dbCloseArea( ) )
	
	aContr := {cCodigo, "", "", "", 0}
		
	// Caso seja utilizado o novo processo para criação do contrato (registro de negócio) e achou apenas um contrato
	// e seja enviado a filial do romaneio (apenas na atualização do romaneio)
	If lRegArm .AND. !Empty(aContr[1]) .AND. !Empty(cFilRom)
		nQtdN9A := 0
	
		cAliasQry := GetNextAlias()
		cQry := " SELECT COUNT(*) AS QTDN9A "
		cQry += " FROM " + RetSqlName("N9A") + " N9A "									
		cQry += " WHERE N9A.N9A_FILIAL = '" + xFilial("N9A") + "' "
		cQry += "   AND N9A.N9A_CODCTR = '" + aContr[1] + "' "
		cQry += "   AND (N9A.N9A_FILORG = '" + cFilRom + "' OR N9A.N9A_FILORG = '') "
		cQry += "   AND N9A.D_E_L_E_T_ = ' ' "	
		cQry := ChangeQuery(cQry)	
		dbUseArea( .T., "TOPCONN", TcGenQry( , , cQry ), cAliasQry, .F., .T.)
	
		dbSelectArea(cAliasQry)
		(cAliasQry)->(DbGoTop())
			
		If (cAliasQry)->(!Eof())
			nQtdN9A := (cAliasQry)->QTDN9A
		EndIf
		(cAliasQry)->(DbCloseArea())
		
		If nQtdN9A == 1			
			DbSelectArea("N9A")
			N9A->(DbSetOrder(1)) //N9A_FILIAL+N9A_CODCTR+N9A_ITEM+N9A_SEQPRI
			If N9A->(DbSeek(xFilial("N9A")+cCodigo))
				While !N9A->(Eof()) .AND. N9A->(N9A_FILIAL+N9A_CODCTR) == xFilial("N9A")+cCodigo
					If (N9A->N9A_FILORG == cFilRom .OR. Empty(N9A->N9A_FILORG)) .AND. N9A->N9A_SDONF > 0
					
						nPos := aScan(aItRefs, {|x| AllTrim(x[1]) == AllTrim(N9A->(N9A_CODCTR+N9A_ITEM+N9A_SEQPRI))})
						
						nPesoCons := 0
						
						If nPos > 0
							nPesoCons := aItRefs[nPos][2]
						EndIf
						
						If nPesoCons < N9A->N9A_SDONF					
							aContr[2] := N9A->N9A_ITEM
							aContr[3] := N9A->N9A_SEQPRI
							aContr[4] := N9A->N9A_TES
							aContr[5] := N9A->N9A_SDONF - nPesoCons
							
							EXIT
						EndIf											
					EndIf
											
					N9A->(DbSkip())
				EndDo
			EndIf
		EndIf
	EndIf

	RestArea(aAreaAtu)
Return(aContr)


/** {Protheus.doc} OGX010BT
Rotina auxiliar para seleção de contratos para transferência

@param 	cTipo ,character,  - Tipo do Contrato
@param 	cCodEnt ,character, - Entidade do Contrato
@param 	cLojEnt ,character, - Loja da Entidade do Contrato
@param 	cSafra ,character,  - Safra do Contrato
@param 	cCultra ,character, - Cultura do Contrato
@return character, cCodigo - Codigo do Contrato
@author Bruna Fagundes Rocio
@since 	08/06/2010
@Uso: 		SIGAAGR - Gestão Agrícola
*/
Function OGX010BT( cTipo, cCodEnt, cLojEnt, cSafra, cCultra )
	Local aAreaAtu  := GetArea()
	Local cCodigo	  := ""
	Local cCodPro   := ""

	BeginSql Alias 'QryNJR'
	Select NJR_CODENT,
	NJR_LOJENT,
	NJR_CODCTR,
	NJR_CODPRO,
	Count( * ) As Total 
	From
	%table:NJR% NJR
	RIGHT Join %Table:SB5% SB5 ON SB5.%notDel%
	AND B5_CULTRA  = %exp:cCultra%
	AND SB5.B5_COD = NJR.NJR_CODPRO	
	Where
	NJR.NJR_TIPO   = %exp:cTipo%   And
	NJR.NJR_CODENT = %exp:cCodEnt% And
	NJR.NJR_LOJENT = %exp:cLojEnt% And
	NJR.NJR_CODSAF = %exp:cSafra%  And
	NJR.NJR_STATUS in ( 'P', 'A', 'I' ) And
	NJR.%NotDel%	
	GROUP BY NJR_CODENT,
	NJR_LOJENT,
	NJR_CODCTR,
	NJR_CODPRO
	EndSql

	If .Not. QryNJR->( Eof() )

		cCodPro := QryNJR->( NJR_CODPRO)
		if QryNJR->( Total ) = 1
			BeginSql Alias 'QryNJR2'
			Select
			NJR_CODCTR
			From
			%table:NJR% NJR
			RIGHT Join %Table:SB5% SB5 ON SB5.%notDel%
			AND B5_CULTRA  = %exp:cCultra%		
			AND SB5.B5_COD = NJR.NJR_CODPRO
			Where
			NJR.NJR_TIPO   = %exp:cTipo% And
			NJR.NJR_CODENT = %exp:cCodEnt% And
			NJR.NJR_LOJENT = %exp:cLojEnt% And
			NJR.NJR_CODSAF = %exp:cSafra% And
			NJR.NJR_STATUS IN ( 'P', 'A', 'I' ) And
			NJR.%NotDel%	
			EndSql

			cCodigo := QryNJR2->( NJR_CODCTR )

			QryNJR2->( dbCloseArea( ) )
		ELSE
			if QryNJR->( Total ) = 0
				If cTipo = "3"  //Contrato de Armazenagem em 3
					dbSelectArea( "NJX" )
					dbSetOrder( 2 )
					If dbSeek( FWxFilial( "NJX" ) + cSafra + cCodPro + cTipo )			
						dbSelectArea( "NJY" )
						dbSetOrder( 2 ) //NJY_FILIAL+NJY_CODENT+NJY_LOJENT+NJY_CODSAF+NJY_CODPRO+NJY_TIPO
						If .Not. dbSeek( FWxFilial("NJY") + cCodEnt + cLojEnt + NJX->NJX_CODSAF + NJX->NJX_CODPRO + NJX->NJX_TIPO )	
							RecLock( "NJY", .t. )
							NJY_FILIAL	:= NJX->NJX_FILIAL
							NJY_CODMOD	:= NJX->NJX_CODMOD
							NJY_TIPO	:= NJX->NJX_TIPO
							NJY_CODENT	:= cCodEnt
							NJY_LOJENT	:= cLojEnt
							NJY_CODSAF	:= NJX->NJX_CODSAF
							NJY_CODPRO	:= NJX->NJX_CODPRO
							MsUnLock()
						EndIf
					EndIf
				Endif
				dbSelectArea( "NJY" )
				dbSetorder( 2 )                                                                            
				If dbSeek( FWxFilial( "NJY" ) + cCodEnt + cLojEnt + cSafra + cCodPro + cTipo )
					dbSelectArea( "NJX" )
					dbSetOrder( 1 )
					If dbSeek( FWxFilial( "NJX" ) + NJY->( NJY_CODMOD ) )
						MsgRun( STR0006, STR0007 , {|| cCodigo := GeraNJR( ) } ) //"Gerando contrato dinâmico para a Entidade..."###"Contrato"
					EndIf
				EndIf
			EndIf
		EndIf
	EndIf

	QryNJR->( dbCloseArea( ) )

	RestArea( aAreaAtu )
Return( cCodigo )

/** {Protheus.doc} OGX010BD
Rotina auxiliar para seleção e geração de contratos automaticos mesmos tendo um contrado não automático em aberto.

@param 	cTipo, character,  - Tipo do Contrato
@param 	cCodEnt , character, - Entidade do Contrato
@param 	cLojEnt , character, - Loja da Entidade do Contrato
@param 	cSafra , character, - Safra do Contrato
@return  character, 	cCodigo - Codigo do Contrato
@author Bruna Fagundes Rocio
@since 	08/06/2010
@Uso: 		SIGAAGR - Gestão Agrícola
*/
Function OGX010BD( cTipo, cCodEnt, cLojEnt, cSafra, cCodPro )
	Local aAreaAtu	:= GetArea()
	Local cCodigo	:= ""

	BeginSql Alias 'QryNJR'
	Select
	Count( * ) As Total 
	From
	%table:NJR% NJR
	Where
	NJR.NJR_FILIAL = %xFilial:NJR% And
	NJR.NJR_TIPO   = %exp:cTipo% And
	NJR.NJR_MODELO = '3' And
	NJR.NJR_CODENT = %exp:cCodEnt% And
	NJR.NJR_LOJENT = %exp:cLojEnt% And
	NJR.NJR_CODSAF = %exp:cSafra% And
	NJR.NJR_CODPRO = %exp:cCodPro% And
	NJR.NJR_STATUS in ( 'P', 'A', 'I' ) And
	NJR.%NotDel%
	EndSql

	If .Not. QryNJR->( Eof() )
		if QryNJR->( Total ) = 1
			BeginSql Alias 'QryNJR2'
			Select
			NJR_CODCTR 
			From
			%table:NJR% NJR
			Where
			NJR.NJR_FILIAL = %xFilial:NJR% And
			NJR.NJR_TIPO   = %exp:cTipo% And
			NJR.NJR_MODELO = '3' And
			NJR.NJR_CODENT = %exp:cCodEnt% And
			NJR.NJR_LOJENT = %exp:cLojEnt% And
			NJR.NJR_CODSAF  = %exp:cSafra% And
			NJR.NJR_CODPRO  = %exp:cCodPro% And
			NJR.NJR_STATUS in ( 'P', 'A', 'I' ) And
			NJR.%NotDel%
			EndSql

			cCodigo := QryNJR2->( NJR_CODCTR )
			QryNJR2->( dbCloseArea( ) )
		ELSE
			if QryNJR->( Total ) = 0
				If cTipo = "3" 
					dbSelectArea( "NJX" )
					dbSetOrder( 2 )
					If dbSeek( FWxFilial( "NJX" ) + cSafra + cCodPro + cTipo )			
						dbSelectArea( "NJY" )
						dbSetOrder( 2 ) //NJY_FILIAL+NJY_CODENT+NJY_LOJENT+NJY_CODSAF+NJY_CODPRO+NJY_TIPO
						If .Not. dbSeek( FWxFilial("NJY") + cCodEnt + cLojEnt + NJX->NJX_CODSAF + NJX->NJX_CODPRO + NJX->NJX_TIPO )	
							RecLock( "NJY", .t. )
							NJY_FILIAL	:= NJX->NJX_FILIAL
							NJY_CODMOD	:= NJX->NJX_CODMOD
							NJY_TIPO	:= NJX->NJX_TIPO
							NJY_CODENT	:= cCodEnt
							NJY_LOJENT	:= cLojEnt
							NJY_CODSAF	:= NJX->NJX_CODSAF
							NJY_CODPRO	:= NJX->NJX_CODPRO
							MsUnLock()
						EndIf
					EndIf
				Endif
				dbSelectArea( "NJY" )
				dbSetorder( 2 )                                                                            
				If dbSeek( FWxFilial( "NJY" ) + cCodEnt + cLojEnt + cSafra + cCodPro + cTipo )
					dbSelectArea( "NJX" )
					dbSetOrder( 1 )
					If dbSeek( FWxFilial( "NJX" ) + NJY->( NJY_CODMOD ) )
						If .NOT.  IsBlind()
							MsgRun( STR0006, STR0007 , {|| cCodigo := GeraNJR( ) } ) //"Gerando contrato dinâmico para a Entidade..."###"Contrato"
						Else

							cCodigo := GeraNJR( )
						EndIf
					EndIf
				EndIf
			EndIf
		EndIf
	EndIf

	QryNJR->( dbCloseArea( ) )

	RestArea( aAreaAtu )
Return( cCodigo )

/** {Protheus.doc} GeraNJR
Gerar contrato
@author 	Bruna Fagundes Rocio
@since 	08/06/2010
@Uso: 		SIGAAGR - Gestão Agrícola
*/
Static Function GeraNJR( )
	Local cRetorno	:= ""
	Local lErro		:= .f.
	Local oMdlNJR		:= Nil
	Local oNJR			:= Nil
	Local nX			:= 0

	oMdlNJR := FWLoadModel( "OGA330" )
	oMdlNJR:SetOperation( MODEL_OPERATION_INSERT )
	oMdlNJR:Activate()

	oNJR := oMdlNJR:GetModel( "NJRUNICO" )

	cRetorno	:= oNJR:GetValue( "NJR_CODCTR" )

	oNJR:SetValue( "NJR_CODENT"	, NJY->( NJY_CODENT ) )
	oNJR:SetValue( "NJR_LOJENT"	, NJY->( NJY_LOJENT ) )
	oNJR:SetValue( "NJR_MODBAS"	, NJY->( NJY_CODMOD ) )
	oNJR:SetValue( "NJR_TIPFIX"	, "2" )
	oNJR:SetValue( "NJR_STATUS"	, "A" )
	For nX := 1 to NJX->(FCount())

		cCpoDe		:=	NJX->( FieldName( nX ) ) // Somente queremos campos da tabela NJX ( MODELO DE CONTRATOS)
		cCpoPara	:=	"NJR_" + Substr( cCpoDe, 5, Len( cCpoDe ) - 4 )

		If .Not. AllTrim( cCpoDe ) $ "NJX_CODMOD|NJX_TABELA" //tratamos o campo de tabela de outra forma
			oNJR:SetValue( cCpoPara, &( "NJX->(" + cCpoDe + ")" ) )
		EndIf

	Next nX
	
	if !AGRTPALGOD( NJX->(NJX_CODPRO)) //não é algodão copiamos o campo da tabela
		oNJR:SetValue( "NJR_TABELA", NJX->(NJX_TABELA) ) 
	endif

	oNJR:SetValue( "NJR_NOMENT"	, Posicione( "NJ0", 1, xFilial( "NJ0" ) + NJY->( NJY_CODENT ) + NJY->( NJY_LOJENT ), "NJ0_NOME" ) )
	oNJR:SetValue( "NJR_NLJENT"	, Posicione( "NJ0", 1, xFilial( "NJ0" ) + NJY->( NJY_CODENT ) + NJY->( NJY_LOJENT ), "NJ0_NOMLOJ" ) )

	IF AllTrim(NJX->( NJX_UMPRC )) = "" //Validação por causa do legado
		oNJR:SetValue( "NJR_UMPRC", AgrUmPrc ( NJX->( NJX_CODPRO )) )
	Endif

	If oMdlNJR:VldData()
		lErro := .Not. oMdlNJR:CommitData()
	Else
		lErro := .t.
	EndIf

	If lErro; OGX007E( oMdlNJR ); EndIf

	oMdlNJR:DeActivate()

Return( cRetorno )


/** {Protheus.doc} OGX010AD
Gerar
@param 	cTipo, character, - Tipo do Contrato
@param 	cCodEnt, character,  - Entidade do Contrato
@param 	cLojEnt, character,  - Loja da Entidade do Contrato
@param 	cSafra, character,  - Safra do Contrato
@return	 character,  cCodigo - Codigo do Contrato
@author 	Bruna Fagundes Rocio
@since 	08/06/2010
@Uso: 		SIGAAGR - Gestão Agrícola
*/

Function OGX010AD( cCodCtr, nQtdAdd, dDtaAdd )
	Local aAreaAtu	:= GetArea()
	Local aAreaNJR	:= NJR->( GetArea() )
	Local aAreaNNY	:= NNY->( GetArea() )

	dbSelectArea( "NJR" )
	dbSetOrder( 1 )
	If dbSeek( FWxFilial( "NJR" ) + cCodCtr )

		If RecLock( "NJR", .f. )

			If NJR->( NJR_MODELO ) = "3"

				NJR->( NJR_STATUS ) := "I"
				NJR->( NJR_QTDINI ) += nQtdAdd 
				NJR->( NJR_QTDCTR ) += nQtdAdd 
				NJR->( NJR_AUTENT ) += nQtdAdd
				NJR->( NJR_AUTSAI ) += nQtdAdd

				dbSelectArea( "NNY" )
				dbSetOrder( 1 )
				If dbSeek( FWxFilial( "NNY" ) + NJR->( NJR_CODCTR ) )

					If RecLock( "NNY" )
						If NNY->( NNY_DATFIM ) < dDtaAdd
							NNY->( NNY_DATFIM ) := dDtaAdd
						EndIf
						NNY->( NNY_QTDINT ) += nQtdAdd
						NNY->( MsUnLock() )
					EndIf

				Else

					If RecLock( "NNY", .t. )
						NNY->( NNY_FILIAL ) := FWxFilial( "NNY" )
						NNY->( NNY_CODCTR ) := NJR->( NJR_CODCTR )
						NNY->( NNY_ITEM   ) := Soma1( StrZero( 0, TamSX3( "NNY_ITEM" )[1] ) )
						NNY->( NNY_DATINI ) := dDtaAdd
						NNY->( NNY_DATFIM ) := dDtaAdd
						NNY->( NNY_QTDINT ) := nQtdAdd
						NNY->( NNY_ENTREG ) := "N"
						NNY->( MsUnLock() )
					EndIf

				EndIf

			EndIf

			NJR->( MsUnLock() )
		EndIf

	EndIf

	RestArea( aAreaNNY )
	RestArea( aAreaNJR )
	RestArea( aAreaAtu )
Return( Nil )


/** {Protheus.doc} OGX010QCtr
Retorna as quantidades de um contrato.

@param pcCodCtr, character,	Código do contrato (NJR_CODCTR).
@return  character, 	Retorna um array contendo as quantidades referentes ao contrato
[1]  NJR_QTDCTR
[2]  NJR_QTEFCO
[3]  NJR_QTEFIS
[4]  NJR_QTSFCO
[5]  NJR_QTSFIS
[6]  NJR_QSLFCO
[7]  NJR_SLDFIS
[8]  NJR_SLDTOT
[9]  SUM(NN8_QTDFIX)
[10] SUM(NN8_QTDENT)
@author 	Marlon Richard Trettin
@since 	21/10/2014
@Uso 		SIGAAGR
*/
Function OGX010QCtr( pcCodCtr )

	Local aSaveArea := GetArea()
	Local cAliasQry := GetNextAlias()
	Local aRet := {0,0,0,0,0,0,0,0,0,0}

	//--- Query para trazer os Contratos ---//
	BeginSql Alias cAliasQry
	SELECT MAX(NJR_QTDCTR) as NJR_QTDCTR
	,MAX(NJR_QTEFCO) as NJR_QTEFCO
	,MAX(NJR_QTEFIS) as NJR_QTEFIS
	,MAX(NJR_QTSFCO) as NJR_QTSFCO
	,MAX(NJR_QTSFIS) as NJR_QTSFIS
	,MAX(NJR_QSLFCO) as NJR_QSLFCO
	,MAX(NJR_SLDFIS) as NJR_SLDFIS
	,MAX(NJR_SLDTOT) as NJR_SLDTOT
	,SUM(NN8_QTDFIX) as NN8_QTDFIX
	,SUM(NN8_QTDENT) as NN8_QTDENT
	FROM %Table:NJR% NJR
	LEFT JOIN %Table:NN8% NN8  ON NN8.%notDel%
	AND NN8_FILIAL = %XFilial:NN8% 
	AND NN8_CODCTR = NJR_CODCTR
	AND NN8_TIPOFX = '1'
	WHERE NJR.%notDel%
	AND NJR_FILIAL = %XFilial:NJR% 
	AND NJR_CODCTR = %exp:pcCodCtr%         
	EndSQL

	DbselectArea( cAliasQry )
	DbGoTop()
	If ( cAliasQry )->( !Eof() )

		aRet := { 	( cAliasQry )->NJR_QTDCTR,;	// 1
		( cAliasQry )->NJR_QTEFCO,;	// 2
		( cAliasQry )->NJR_QTEFIS,;	// 3
		( cAliasQry )->NJR_QTSFCO,;	// 4
		( cAliasQry )->NJR_QTSFIS,;	// 5
		( cAliasQry )->NJR_QSLFCO,;	// 6
		( cAliasQry )->NJR_SLDFIS,;	// 7
		( cAliasQry )->NJR_SLDTOT,;	// 8
		( cAliasQry )->NN8_QTDFIX,;	// 9
		( cAliasQry )->NN8_QTDENT  }	// 10

	EndIf
	( cAliasQry )->( DbCloseArea() )

	RestArea( aSaveArea )
Return( aRet )


/** {Protheus.doc} OGX010Moed
Função para vaidação da moeda informada

@param 	pnMoeda , character, 		Número da moeda.
@return character, 	NIL
@author	Marlon Richard Trettin
@since  11/11/2014
@Uso    SIGAAGR
*/
Function OGX010Moed( pnMoeda )

	Local cAliasB	:= Alias()
	Local nOrder	:= IndexOrd()
	Local lRet		:= .T.
	Local nRec
	Local cMoeda 	:= Alltrim( Str( pnMoeda ) )

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Verifica se a moeda existe no SX3    ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	dbSelectArea("SX3")
	nRec := Recno()
	dbSetOrder(2)
	If !dbSeek("M2_MOEDA"+cMoeda)
		Help ( " ", 1, "SEMMOEDA" )
		lRet := .F.
	EndIf

	dbGoto(nRec)
	If !Empty(cAliasB)
		dbSelectArea(cAliasB)
		dbSetOrder(nOrder)
	EndIf

Return lRet


/** {Protheus.doc} OGX010QAut
Função para gravação dos campos de quantidades autorizadas do contrato, no momento em que o mesmo é confirmado.

@param  cAcao, character, tipo de ação esperada I - Incluir, A - alterar, 
@return	character, NIL
@author Marlon Richard Trettin
@since 	14/12/2014
@Uso	SIGAAGR
*/
Function OGX010QAut(cAcao)

	Local cAliasQry := ""
	Local cQuery 	:= ""
	Default	cAcao	:= ""

	If RecLock( "NJR", .f. )
		// Se não controla logística, o contrato já fica autorizado
		If NJR->( NJR_CTRLLG ) = "2" //2=Nao
			NJR->( NJR_AUTENT ) := NJR->( NJR_QTDCTR )
			NJR->( NJR_AUTSAI ) := NJR->( NJR_QTDCTR )
		Else
			// Se controla logística, verifica onde deve controlar: 0=Nenhum;1=Carga;2=Descarga;3=Carga/Desgarga

			If NJR->( NJR_CTRLCD ) == "0" //0=Nenhum : deixa tudo autorizado
				NJR->( NJR_AUTENT ) := NJR->( NJR_QTDCTR )
				NJR->( NJR_AUTSAI ) := NJR->( NJR_QTDCTR )
			ElseIf NJR->( NJR_CTRLCD ) == "1" //1=Carga (saída): então deixa autorizado a entrada
				NJR->( NJR_AUTENT ) := NJR->( NJR_QTDCTR )
				NJR->( NJR_AUTSAI ) := 0
			ElseIf NJR->( NJR_CTRLCD ) == "2" //2=Descarga (entrada): então deixa autorizado a saída
				NJR->( NJR_AUTSAI ) := NJR->( NJR_QTDCTR )
				NJR->( NJR_AUTENT ) := 0
			ElseIf NJR->( NJR_CTRLCD ) == "3" //3=Carga/Descarga  //--<< Garante q quando altera um ctrato c. ctrole logista Nao para Sim , os Campos Autsai,AutEnt fiquem inidicalizados com 0
				NJR->( NJR_AUTSAI ) := 0
				NJR->( NJR_AUTENT ) := 0
			EndIf
		EndIf

		cAliasQry := GetNextAlias()
		cQuery := " SELECT SUM(ENTSAI1.QTD_AUTENT) 	as QTD_AUTENT, "
		cQuery += " SUM(ENTSAI1.QTD_AUTSAI) 	as QTD_AUTSAI "
		cQuery += " FROM ( SELECT SUM(NJP1.NJP_QTDAUT + NJP1.NJP_QTDEXC) as QTD_AUTENT, "
		cQuery += " 0 as QTD_AUTSAI "
		cQuery += " FROM  " + RetSqlName("NJP") + " NJP1 "
		cQuery += " WHERE NJP1.D_E_L_E_T_ = ' ' "
		cQuery += " AND NJP1.NJP_FILIAL LIKE '%" + Alltrim(NJR->( NJR_FILIAL)) + "%' "
		cQuery += " AND NJP1.NJP_CODCTR = '" + NJR->( NJR_CODCTR ) + "' "
		cQuery += " AND NJP1.NJP_TIPO   = 'E' "
		cQuery += " UNION "
		cQuery += " SELECT 0 as QTD_AUTENT, "
		cQuery += " SUM(NJP1.NJP_QTDAUT + NJP1.NJP_QTDEXC) as QTD_AUTSAI "
		cQuery += " FROM  " + RetSqlName("NJP") + " NJP1 "
		cQuery += " WHERE NJP1.D_E_L_E_T_ = ' ' "
		cQuery += " AND NJP1.NJP_FILIAL LIKE '%" + Alltrim(NJR->( NJR_FILIAL)) + "%' "
		cQuery += " AND NJP1.NJP_CODCTR = '" + NJR->( NJR_CODCTR ) + "' " 
		cQuery += " AND NJP1.NJP_TIPO   = 'S' ) ENTSAI1 "
		cQuery := ChangeQuery(cQuery)		
		dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),(cAliasQry),.F.,.T.)

		(cAliasQry)->( dbGoTop() )
		If .Not. (cAliasQry)->( Eof() )

			If NJR->( NJR_CTRLLG ) = "1" //1=Sim
				If NJR->( NJR_CTRLCD ) == "1" //1=Carga (saída): então deixa autorizado a entrada
					NJR->( NJR_AUTSAI ) := (cAliasQry)->( QTD_AUTSAI )
				ElseIf NJR->( NJR_CTRLCD ) == "2" //2=Descarga (entrada): então deixa autorizado a saída
					NJR->( NJR_AUTENT ) := (cAliasQry)->( QTD_AUTENT )
				ElseIf NJR->( NJR_CTRLCD ) == "3" //3=Carga/Descarga  //--<< Garante q quando altera um ctrato c. ctrole logista Nao para Sim , os Campos Autsai,AutEnt fiquem inidicalizados com 0
					NJR->( NJR_AUTENT ) := (cAliasQry)->( QTD_AUTENT )
					NJR->( NJR_AUTSAI ) := (cAliasQry)->( QTD_AUTSAI )
				EndIf
			EndIf
		EndIf
		(cAliasQry)->( dbCloseArea() )

		If cAcao $ "I|A" .or. cAcao = ""
			If NJR->( NJR_QTSFIS + NJR_QTEFCO + NJR_QTSFCO + NJR_QTEFIS  ) > 0
				// Se tiver alguma movimentação no contrato, então o contrato está Iniciado
				NJR->( NJR_STATUS ) := "I"
			ElseIf !Empty(cAcao)
				// Se não tiver movimentação no contrato, então o contrato está Aberto
				NJR->( NJR_STATUS ) := "A"
			EndIf
		ElseIf cAcao = "E" // Cancelado
			NJR->( NJR_STATUS ) := "E"
		ElseIf cAcao $ "P|F" //Previsto/Finalizado
			// Caso contrato ja tenha sido finalizado, o titulo é excluido, então deve voltar a ser previsto.
			NJR->( NJR_STATUS ) := "P"	
		EndIf

		NJR->( MsUnLock() )		
	EndIf

Return NIL


/** {Protheus.doc} OGX010QTDS
Atualiza quantidades no contrato

@param  cAcao, character,  Indicar a acao que está sendo executada no momento
@return character, 	Nil
@author	Vitor Alexandre de Barba
@since	13/10/2014
@Uso		OG
*/
Function OGX010QTDS( cAcao )

	Local cItemNNY	:= ''

	Default	cAcao	= ""

	If RecLock( "NJR", .f. )

		If cAcao $ "I|A" .or. cAcao = ""
			If NJR->( NJR_QTSFIS + NJR_QTEFCO + NJR_QTSFCO + NJR_QTEFIS  ) > 0
				// Se tiver alguma movimentação no contrato, então o contrato está Iniciado
				NJR->( NJR_STATUS ) := "I"
			ElseIf !Empty(cAcao)
				// Se não tiver movimentação no contrato, então o contrato está Aberto
				NJR->( NJR_STATUS ) := "A"
			EndIf
		ElseIf cAcao = "E" // Cancelado
			NJR->( NJR_STATUS ) := "E"
		ElseIf cAcao $ "P|F" //Previsto/Finalizado
			// Caso contrato ja tenha sido finalizado, o titulo é excluido, então deve voltar a ser previsto.
			NJR->( NJR_STATUS ) := "P"	
		EndIf


		//----------------------------------------------------------------------------------------------------------------------
		// Tratamento Para contrato Automatico, (Não Mover daqui, os Contratos automaticos devem ser a 1o. coisa a Ser Tratada)
		//----------------------------------------------------------------------------------------------------------------------
		IF NJR->( NJR_MODELO ) = "3"   // Tratamento para modelo de contrato Automatico
			// Ajustando a Qtidade Inicial do Contrato
			Do Case
				Case NJR->NJR_TIPO $ "1|3"		//Contrato de compras e Contrato de Deposito DE 3o.
				If NJR->( NJR_QTEFIS ) < NJR->( NJR_QTEFCO )
					NJR->( NJR_QTDINI ) := NJR->( NJR_QTEFCO )
				Else
					NJR->( NJR_QTDINI ) := NJR->( NJR_QTEFIS )
				EndIf
				Case NJR->NJR_TIPO $ "2|4"		//Contrato de Vendas e Contrato de Deposito EM 3o.
				If NJR->( NJR_QTSFIS ) < NJR->( NJR_QTSFCO )
					NJR->( NJR_QTDINI ) := NJR->( NJR_QTSFCO )
				Else
					NJR->( NJR_QTDINI ) := NJR->( NJR_QTSFIS )
				EndIf
			EndCase

			//Atualizando a Qtd do contrato 
			Do Case
				Case NJR->NJR_TIPO == '1'	// Contrato de Compra Automatico
				NJR->NJR_QTDCTR := NJR->( NJR_QTEFCO - NJR_QTSFCO)
				Case NJR->NJR_TIPO == '2'	// Contrato de Vendas Automatico
				NJR->NJR_QTDCTR := NJR->( NJR_QTSFCO  -  NJR_QTEFCO )
				Case NJR->NJR_TIPO == '3'	// Contrato de Deposito DE Terceiros Automatico
				NJR->NJR_QTDCTR := NJR->NJR_QTEFCO
				Case NJR->NJR_TIPO == '4'	// Contrato de Depoiso 	EM terceiros Automatico
				NJR->NJR_QTDCTR := NJR->NJR_QTSFCO
			EndCase

			//  Atalizando a Qtd. Autorizada de Entrada e Saida do Contrato   
			NJR->NJR_AUTENT := NJR->NJR_QTDCTR //NJR->NJR_QTEFCO
			NJR->NJR_AUTSAI := NJR->NJR_QTDCTR ///NJR->NJR_QTSFCO

		EndIf

		//----------------------------------------------------------------------------------------------------------------------
		// Tratando o Saldos dos Contratos
		//----------------------------------------------------------------------------------------------------------------------
		If NJR->( NJR_TIPO ) = "1"			// *** ENTRA MERCADORIA - SE TIPO CONTRATO COMPRA
			NJR->( NJR_SLDFIS ) := NJR->( NJR_QTDCTR ) - NJR->( NJR_QTEFIS ) + NJR->( NJR_QTSFIS )
			NJR->( NJR_QSLFCO ) := NJR->( NJR_QTDCTR ) - NJR->( NJR_QTEFCO ) + NJR->( NJR_QTSFCO )

		ElseIF NJR->( NJR_TIPO ) = "2"		// *** SAI MERCADORIA - SE TIPO FOR VENDAS
			NJR->( NJR_SLDFIS ) := NJR->( NJR_QTDCTR ) - NJR->( NJR_QTSFIS ) + NJR->( NJR_QTEFIS )
			NJR->( NJR_QSLFCO ) := NJR->( NJR_QTDCTR ) - NJR->( NJR_QTSFCO ) + NJR->( NJR_QTEFCO )

		ElseIF NJR->( NJR_TIPO ) = "3"		// *** SE TIPO FOR DE 3o
			NJR->( NJR_SLDFIS ) := NJR->( NJR_QTEFIS ) - NJR->( NJR_QTSFIS )
			NJR->( NJR_SLDTOT ) := NJR->( NJR_VLEFIS ) - NJR->( NJR_VLSFIS )
			NJR->( NJR_QSLFCO ) := NJR->( NJR_QTEFCO ) - NJR->( NJR_QTSFCO )

		ElseIf NJR->( NJR_TIPO ) = "4"		// *** SE TIPO FOR EM 3o
			NJR->( NJR_SLDFIS ) := NJR->( NJR_QTSFIS ) - NJR->( NJR_QTEFIS )
			NJR->( NJR_SLDTOT ) := NJR->( NJR_VLSFIS ) - NJR->( NJR_VLEFIS )
			NJR->( NJR_QSLFCO ) := NJR->( NJR_QTSFCO ) - NJR->( NJR_QTEFCO )
		EndIf
		//----------------------------------------------------------------------------------------------------------------------
		// Fim Tratando o Saldos dos Contratos
		//----------------------------------------------------------------------------------------------------------------------

		NJR->( msUnLock() )

	EndIF

	//----------------------------------------------------------------------------------------------------------------------
	// *** Cria / Altera a Cadencia Para Contratos Automaticos  que são de Compra ou Venda
	//----------------------------------------------------------------------------------------------------------------------
	If NJR->( NJR_TIPO ) $ "1|2" .and. NJR->NJR_MODELO == '3'			// NJR_TIPO ('1' Compra '2' Venda), NJR_MODELO ( '3' Automatico )
		// *** Criando / Atualizando a Cadencia Unica do Contrato Automatico
		cItemNNY := CriaVar('NNY_ITEM', .f.)
		cItemNNY :=   Soma1( cItemNNY	)
		DbSelectArea('NNY')
		NNY->( DbSetOrder(1) )
		IF  NNY->( DbSeek( fWXfilial('NNY') + NJR->NJR_CODCTR + cItemNNy ) )
			RecLock("NNY", .f. )
			If NNY->NNY_DATFIM < NJJ->NJJ_DATA
				NNY->NNY_DATFIM := NJJ->NJJ_DATA
			EndIf
			NNY->NNY_QTDINT := NJR->NJR_QTDCTR
			NNY->( MsUnlock() )
		Else
			RecLock("NNY", .t. )
			NNY->NNY_FILIAL	:= FWxFILIAL('NNY')
			NNY->NNY_CODCTR := NJR->NJR_CODCTR 
			NNY->NNY_ITEM	:= cItemNNY
			NNY->NNY_DATINI := dDataBase
			NNY->NNY_DATFIM := dDataBAse
			NNY->NNY_QTDINT := NJR->NJR_QTDCTR
			NNY->NNY_ENTREG := 'S'
			NNY->NNY_ENTORI := NJR->NJR_CODENT
			NNY->NNY_LOJORI := NJR->NJR_LOJENT
			NNY->NNY_ENTDES := NJR->NJR_CODENT
			NNY->NNY_LOJDES := NJR->NJR_LOJENT
			NNY->NNY_TIPENT := '0'
			NNY->( MsUnlock() )
		EndIF
	EndIF

Return( NIL )

/*/{Protheus.doc} OGX010PAR
Tela de pergunte na consulta personalizada de contratos
@type function
@version P12
@author Agroindustria
@since 01/01/2020
@param cTipo, character, tipo do contrato
@param cCodEnt, character, codigo da entidade
@param cLojEnt, character, codigo da loja da entidade
@param cSafra, character, codigo da safra
@param cCodPro, character, codigo do produto
@param lRegArm, logical, se filtra por regra fiscal
@param cFilRom, character, filial do romaneio
@param aItRefs, array, itens do romaneio(NJM) com o contrato com regra fiscal e qtd ja selecionada
/*/
Function OGX010PAR(pTipo, pCodEnt, pLojEnt, pSafra, pCodPro, lRegArm, cFilRom, aItRefs)

	If Pergunte( "OGX010", .T. )	
		nSSdo  := mv_par01
		f001AItens(pTipo, pCodEnt, pLojEnt, pSafra, pCodPro, lRegArm, cFilRom, aItRefs)
	EndIf

Return

/** {Protheus.doc} AGRXFCTR
Finalizar Contrato Automatico
@param  cContrato, character,  Codigo do contrato
@return character, 	Nil
@author	Vanilda Moggio
@since	06/06/2024
@Uso OGA250G */
Function AGRXFCTR(cContrato,lEstorno) 
Local aAreaAtu  := GetArea()
Local cQuery 	:= ""
Local cQryNJM   := GetNextAlias() 
Local lfinalAuto:= .F. 
Local nQTDfinal := SuperGetMv('MV_AGRFAQT', , 0)  //Finaliza automatico contrato com saldo inferior a esta quantidade
Local nQtFixada := 0
lOCAL cTipFix   := Posicione( "NJR", 1, xFilial( "NJR" ) + cContrato, "NJR_TIPFIX" )
Default lEstorno:= .F.

IF __lnewNeg .and. cTipFix == "2" //NC e a Fixar  
	lfinalAuto:= .F. 
Else 
	// Verificar se há romaneio atualizado pendente de confirmação
	cQuery := " SELECT 1 "
	cQuery += " FROM " + RetSqlName('NJM') + " NJM " 
	cQuery += " INNER JOIN " + RetSqlName('NJJ') + " NJJ ON NJJ.D_E_L_E_T_ = ' ' AND NJJ.NJJ_FILIAL = NJM.NJM_FILIAL "
	cQuery += "     AND NJJ.NJJ_CODROM = NJM.NJM_CODROM AND NJJ.NJJ_STATUS = '2' "
	cQuery += " WHERE NJM.D_E_L_E_T_ = ' ' AND NJM.NJM_FILIAL = '"+ FWxFilial("NJM") +"' AND NJM.NJM_CODCTR='"+cContrato+"' " 
	cQuery := ChangeQuery(cQuery)
	dbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery), cQryNJM, .T., .T.)

	IF (cQryNJM)->(Eof()) //Não tem romaneio pendente para o contrato
		dbSelectArea('NJR')
		dbSetOrder(1)
		If dbSeek( xFilial('NJR') + cContrato )
			IF NJR->NJR_TIPO $ "1|2" //Compra ou venda			
				//NJR_STSASS=F-Assinado e NJR_STATUS = 1-Pre-contrato P=Previsto A=Aberto I=INICIADO E=CAncelado F=FInalizado(Voltar Atualizado)  					
				If NJR->( NJR_STATUS ) $ "IA"  .and. !lEstorno
					If NJR->( NJR_STSASS ) = "F" 
						nQtFixada := fQtFixCtr( NJR->NJR_codctr )
						
						IF !(NJR->(NJR_TIPFIX) == "2" .And. nQtFixada < NJR->(NJR_QTDCTR))  //Tem Qtidade à fixar, nao continua 			 			

							If  NJR->NJR_TPEXC  == '2' //Última Carga
								lfinalAuto = (NJR->(NJR_SLDFIS) = 0) //Se nao tem saldo, é a ultima carga, é pra finalizar   	    
							ElseiF NJR->(NJR_SLDFIS) <= nQTDfinal //Se ultrapassou o saldo do MV é a ultima carga, é pra finalizar  
								lfinalAuto = .T.
							EndIF

							If lfinalAuto  
								If RecLock( "NJR", .f. )
									If  NJR->( NJR_STSEST ) = "A" //"Estoque Aberto"	    
										NJR->( NJR_STSEST ) = "F" //"Estoque Fechado"
									EndIF

									If  NJR->( NJR_STSFIS ) = "A" //"Fiscal Aberto"	
										NJR->( NJR_STSFIS ) = "F" //"Fiscal Fechado"
									EndIF

									If  NJR->( NJR_STSFIN ) = "A" //"Financeiro Aberto"	
										NJR->( NJR_STSFIN ) = "F" //"Financeiro Fechado"
									EndIF 
													
									// NJR_STSASS = "F" "F=Finalizado - Assinatura Aberto / Fechado - Status atualizado somente manual"
									If ( NJR->( NJR_STSASS ) = "F" .and. NJR->( NJR_STSEST ) = "F" .and. NJR->( NJR_STSFIS ) = "F" .and. NJR->( NJR_STSFIN ) = "F" .and. NJR->( NJR_STATUS ) $ "I" )												
									
										// status contrato = Finalizado
										NJR->( NJR_STATUS ) := "F"				

										//função atualiza status da IE relacionadas ao contrato
										OGA320STIE(NJR->( NJR_CODCTR ))		

										AGRGRAVAHIS(STR0007,"NJR",NJR->NJR_FILIAL+NJR->NJR_CODCTR,"F",,STR0009,.F.)	//'Finalizar Automático'
																			
										IF NJR->NJR_TIPO $ "1" //Compra 
										    OG280ETF(NJR->NJR_CODCTR,NJR->NJR_CODENT,NJR->NJR_LOJENT)//exclui as previsoes 
										ElseIF NJR->NJR_TIPO $ "2" //venda 
											OG280DTF(NJR->NJR_CODCTR,NJR->NJR_CODENT,NJR->NJR_LOJENT)//exclui as previsões 
										EndIF
									EndIf	
									NJR->( msUnLock() )
								EndIf										
							EndIf							
						EndIf	
					EndIf	

				ElseIF  NJR->( NJR_STATUS ) $ "F" 		
					If RecLock( "NJR", .f. )	
						// Qtds continuam atualizadas no contrato, então o contrato está Iniciado
						NJR->( NJR_STATUS ) := "I"
						
						If  NJR->( NJR_STSEST ) = "F" //"Estoque Fechado"
							NJR->( NJR_STSEST ) = "A" //"Estoque Aberto"		
						EndIF

						If  NJR->( NJR_STSFIS ) = "F" //"Fiscal Fechado"
							NJR->( NJR_STSFIS ) = "A" //"Fiscal Aberto"	
						EndIF

						If  NJR->( NJR_STSFIN ) = "F" //"Financeiro Fechado"
							NJR->( NJR_STSFIN ) = "A" //"Financeiro Aberto"	
						EndIF 
						NJR->( msUnLock() )
					EndIf
				EndIf					
			EndIF
		EndIF
	EndIF
	(cQryNJM)->(DbCloseArea())
	RestArea(aAreaAtu)
EndIf	

Return( lfinalAuto) 
