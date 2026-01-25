#include 'TOTVS.CH'
#include 'FWLIBVERSION.CH'
#include 'RESTFUL.CH'
#include 'FWADAPTEREAI.CH'
#include 'APWEBSRV.CH'
#include 'TBICONN.CH'
#include 'FILEIO.CH'
#include 'CONSIG005.CH'
#include 'FWMVCDEF.CH'

static __aOfusca	:= iif(FindFunction('ChkOfusca'), ChkOfusca(), { .T., .F. }) //[2]Ofuscamento
static __aFldRel	:= iif( __aOfusca[2], FwProtectedDataUtil():UsrNoAccessFieldsInList( {"RA_NOME"} ), {} )
static __lOfusca	:= len( __aFldRel) > 0
static __lMarker    := .T.

static __oBrwIC	   	:= nil
static __oBrwColab 	:= nil
static __oBrwOk 	:= nil

static __aTableIC   := {}
static __aTableCol  := {}
static __aTableOk   := {}
static __aTableBkp  := {}

static __aStatus   	:= {}
static __oTimer		:= nil
static __tRefresh  	:= loadBitmap(GetResources(),'REFRESH')
static __tOk    	:= loadBitmap(GetResources(),'BR_VERDE')
static __tError  	:= loadBitmap(GetResources(),'BR_VERMELHO')


/*/{Protheus.doc} function CONSIG005
Comunica a rescisão para o Totvs Consignado
@author  Ruann Carlos Rodrigues Lima
@since   23/10/2023
@version 1.0
/*/
main function CONSIG005() as logical
	local aPerg  := finitPerg() as array
	local aRet   := {} as array

	if !GetMv("MV_CONSIG", .F., .F.)
		Help( " ", 1, STR0002,, STR0003, 1 ) // STR0002: "Aviso Integração" - STR0003: "Para utilizar essa rotina é necessário ativar a chave do TOTVS Consignado."
		Return
	endIf

	if paramBox( fMontParam(aPerg), STR0001,aRet,,,,,,,,.F.,.T.) //STR0001: 'Comunicar Rescisão'
		fExec( aRet )
	endIf

return .T.


/*/{Protheus.doc} function CONSIG005
Preenche os parâmetros iniciais da rotina
@author  Ruann Carlos Rodrigues Lima
@since   23/10/2023
@version 1.0
/*/
static function finitPerg() as array
	local aRet  := {} as array
	local dData := date()

	aAdd( aRet, replicate( ' ', tamSx3('RA_FILIAL')[01]) )
	aAdd( aRet, replicate( 'Z', tamSx3('RA_FILIAL')[01]) )
	aAdd( aRet, replicate( ' ', tamSx3('RA_MAT')[01]   ) )
	aAdd( aRet, replicate( 'Z', tamSx3('RA_MAT')[01]   ) )
	aAdd( aRet, dData    )
	aAdd( aRet, dData+30 )
return aRet


/*/{Protheus.doc} function CONSIG005
Defini o array para criação da parambox
@author  Ruann Carlos Rodrigues Lima
@since   23/10/2023
@version 1.0
/*/
static function fMontParam( aPerg as array ) as array
	local aRet := {} as array
	aAdd( aRet, { 1, STR0043 , aPerg[01], '', '.T.', 'SM0', '.T.', 50, .F. } )
	aAdd( aRet, { 1, STR0044 , aPerg[02], '', '.T.', 'SM0', '.T.', 50, .T. } )
	aAdd( aRet, { 1, STR0045 , aPerg[03], '', '.T.', 'SRA', '.T.', 50, .F. } )
	aAdd( aRet, { 1, STR0046 , aPerg[04], '', '.T.', 'SRA', '.T.', 50, .T. } )
	aAdd( aRet, { 1, STR0047 , aPerg[05], '', '.T.', ''	  , '.T.', 50, .T. } )
	aAdd( aRet, { 1, STR0048 , aPerg[06], '', '.T.', ''	  , '.T.', 50, .T. } )
return aRet


/*/{Protheus.doc} function CONSIG005
Responsável pelo o posicionamento dos objetos na tela
@author  Ruann Carlos Rodrigues Lima
@since   23/10/2023
@version 1.0
/*/
static function fExec( aPerg as array ) as logical
	local aCords 	 	:= FWGetDialogSize( oMainWnd ) as array
	local oDlg 			:= nil as object
	local oSize			:= nil as object
	local oSize2		:= nil as object
	local oMaster		:= nil as object
	local oPanel1		:= nil as object
	local oPanel2		:= nil as object
	local cIdMaster		:= 'MASTER' as character
	local cIdGrid1		:= 'GRID1'  as character
	local cIdGrid2		:= 'GRID2'	as character

	private cCadastro	:= STR0001 + ': ' + dToC( aPerg[05] ) + ' até ' + dToC( aPerg[06] )  as character //STR0001: 'Comunicar Rescisão'

	default aPerg 		:= {}

	oDlg := MsDialog():New( aCords[01]		,;
		aCords[02]		,;
		aCords[03]		,;
		aCords[04]		,;
		cCadastro		,;
		,;
		,;
		,;
		nOR( DS_MODALFRAME, WS_POPUP, WS_CAPTION, WS_VISIBLE )	,;
		CLR_BLACK		,;
		CLR_WHITE		,;
		,;
		oMainWnd		,;
		.T.				)

	oDlg:lEscClose  := .F.

	oSize := FwDefSize():New(.T.,,,oDlg)
	oSize:lLateral 	:= .F.
	oSize:lProp 	:= .T.
	oSize:AddObject(cIdMaster, 100, 100, .T., .T.)
	oSize:Process()

	oMaster :=	fCreatePanel( 	oSize:GetDimension(cIdMaster,"LININI")	,;
		oSize:GetDimension(cIdMaster,"COLINI")	,;
		oDlg									,;
		oSize:GetDimension(cIdMaster,"XSIZE")	,;
		oSize:GetDimension(cIdMaster,"YSIZE") 	)

	oSize2 := FwDefSize():New(.T.,,,oMaster)
	oSize2:lLateral := .F.
	oSize2:lProp 	:= .T.
	oSize2:AddObject(cIdGrid1, 100, 40, .T., .T.)
	oSize2:AddObject(cIdGrid2, 100, 60, .T., .T.)
	oSize2:Process()

	oPanel1 :=	fCreatePanel( 	oSize2:GetDimension(cIdGrid1,"LININI")	,;
		oSize2:GetDimension(cIdGrid1,"COLINI")	,;
		oMaster									,;
		oSize2:GetDimension(cIdGrid1,"XSIZE")	,;
		oSize2:GetDimension(cIdGrid1,"YSIZE") 	,;
		.T.										)

	__oBrwIC := fCreateBrw(	oPanel1				,;
		STR0004				,; //'Instituição de Crédito'
	1					,;
		aPerg				,;
		@__aTableIC			,;
		@__oBrwIC			)

	if __oBrwIC == nil
		Help( " ", 1, STR0024,, STR0052, 1 )  //STR0024: 'Atenção' | STR0025: 'Nenhuma Instítuição de Crédito localizado, verifique a tabela S137.'
		return .F.
	endIf

	oPanel2 :=	fCreatePanel( 	oSize2:GetDimension(cIdGrid2,"LININI")		,;
		oSize2:GetDimension(cIdGrid2,"COLINI")		,;
		oMaster										,;
		oSize2:GetDimension(cIdGrid2,"XSIZE")		,;
		oSize2:GetDimension(cIdGrid2,"YSIZE")+50 	,;
		.T.											)

	__oBrwColab := fCreateBrw(	oPanel2				,;
		STR0005				,; //'Funcionários com rescisão calculada'
	2					,;
		aPerg				,;
		@__aTableCol		,;
		@__oBrwColab		)

	if __oBrwColab == nil
		Help( " ", 1, STR0024,, STR0051, 1 )  //STR0024: 'Atenção' | STR0025: 'Não foram encontrados funcionários com rescisão calculada para o período informado.'
		return .F.
	endIf

	oDlg:Activate(,,,.T.,,,EnchoiceBar(oDlg,{ ||  fProc(aPerg)  },{ || oDlg:End() }))

	__oBrwIC	:= nil
	__oBrwColab := nil
	__aStatus   := {}
	__aTableIC  := {}
	__aTableCol := {}
	__aTableOk  := {}
	__aTableBkp := {}
return .T.


/*/{Protheus.doc} function CONSIG005
Responsável pela criação dos objetos tPanel
@author  Ruann Carlos Rodrigues Lima
@since   23/10/2023
@version 1.0
/*/
static function fCreatePanel( 	nLin	as numeric 	,;
		nCol	as numeric	,;
		oFather	as object	,;
		nWidth	as numeric	,;
		nHeight	as numeric	,;
		lAlign 	as logical	) as object

	local oPanel 	:= nil as object

	default oFather := nil
	default nLin    := 0
	default nCol    := 0
	default nWidth  := 0
	default nHeight := 0
	default lAlign  := .F.

	oPanel:= tPanel():New(	nLin	,;
		nCol	,;
		,;
		oFather	,;
		,;
		,;
		,;
		,;
		,;
		nWidth	,;
		nHeight	,;
		.F.		,;
		.F.		)

	if lAlign
		oPanel:Align := CONTROL_ALIGN_TOP
	endIf
return oPanel


/*/{Protheus.doc} function CONSIG005
Responsável pela criação do objeto FWFormBrowse
@author  Ruann Carlos Rodrigues Lima
@since  23/10/2023
@version 1.0
/*/
static function fCreateBrw(	oFather	as object		,;
		cTitle	as character	,;
		nType	as numeric 		,;
		aPerg	as array 		,;
		aTable  as array 		,;
		oBrowse as object 		) as object

	local aContent  := fGetStruct( nType )
	local aColsBrw  := fCreateStruct( aContent, nType)
	local bMark 	:= {|| oBrowse:setColPos(1) , iif(aTable[oBrowse:nAt,1], "LBOK", "LBNO") }
	local bMarkOne 	:= {|| fMark(oBrowse, aTable, nType, .F.) , oBrowse:setColPos(1) }
	local bMarkAll 	:= {|| fMark(oBrowse, aTable, nType, .T.) , oBrowse:setColPos(1) }
	local lMark  	:= .T.
	local aLegenda	:= {}
	local nX		:= 0

	do case
	case nType == 1
		msgRun( STR0006, STR0001, {|| aTable := fGetIC() }) //STR0006: "Consultando dados..." - STR0001: "Comunicar Rescisão"

	case nType == 2
		msgRun( STR0006, STR0001, {|| aTable := fGetCol( aPerg ) }) //STR0006: "Consultando dados..." - STR0001: "Comunicar Rescisão"
		__aTableBkp := aClone( aTable )

	case nType == 3
		msgRun( STR0006, STR0001, {|| aTable := fGetOk() }) //STR0006: "Consultando dados..." - STR0001: "Comunicar Rescisão"
		lMark	:= .F.
	end Case

	if len( aTable ) == 0
		return nil
	endIf

	oBrowse := FWFormBrowse():New()
	oBrowse:SetOwner(oFather)
	oBrowse:SetDescription(OemToAnsi( cTitle ))
	oBrowse:SetDataArray()

	if lMark

		oBrowse:AddMarkColumns(bMark,bMarkOne,bMarkAll)

		if nType == 1
			aAdd( aLegenda, { {|| aTable[oBrowse:nAt][05] > 0   }		, "RED" 	, STR0007	}) //STR0007: "Pendente de Envio"
			aAdd( aLegenda, { {|| aTable[oBrowse:nAt][05] == 0  }		, "GREEN"   , STR0008	}) //STR0008: "Finalizado"
		elseif nType == 2
			aAdd( aLegenda, { {||  empty( aTable[oBrowse:nAt][13] ) } 	, "RED" 	, STR0007	}) //STR0007: "Pendente de Envio"
			aAdd( aLegenda, { {|| !empty( aTable[oBrowse:nAt][13] ) } 	, "GREEN"   , STR0008	}) //STR0008: "Finalizado"
		endIf

	endIf

	for nX := 1 To Len(aLegenda)
		oBrowse:AddLegend( aLegenda[nX,1], aLegenda[nX,2] , aLegenda[nX,3] )
	next

	oBrowse:SetColumns( aColsBrw )
	oBrowse:SetArray( aTable )
	oBrowse:SetDBFFilter()
	oBrowse:SetUseFilter()
	oBrowse:DisableReport()
	oBrowse:DisableLocate()
	oBrowse:SetMenuDef('')
	oBrowse:DisableDetails()
	oBrowse:SetFocus()
	oBrowse:ForceQuitButton(.F.)
	oBrowse:SetFixedBrowse(.T.)
	oBrowse:SetDoubleClick( bMarkOne )
	oBrowse:Activate()
return oBrowse


/*/{Protheus.doc} function CONSIG005
Definição dos campos para construção da tabela temporária
@author  Ruann Carlos Rodrigues Lima
@since   23/10/2023
@version 1.0
/*/
static function fGetStruct( nType as numeric ) as array

	local aStruct := {} as array

	default nType := 0

	do Case
	case nType == 1

		aAdd(aStruct, { 'IC_COD'  , STR0009 , 'C'								   ,  05					, 00					, '@!' 						 }) //STR0009: 'Cod. Operadora'
		aAdd(aStruct, { 'IC_IC'   , STR0010 , 'C'								   ,  100					, 00					, '@!' 						 }) //STR0010: 'Instituição de Crédito'
		aAdd(aStruct, { 'IC_QENV' , STR0011 , FWSX3Util():GetFieldType('RC_VALOR') ,  tamSX3('RC_VALOR')[01], tamSX3('RC_VALOR')[02], pesqPict('SRC','RC_VALOR') }) //STR0011: 'Qtd Enviada'
		aAdd(aStruct, { 'IC_QPEND', STR0012 , FWSX3Util():GetFieldType('RC_VALOR') ,  tamSX3('RC_VALOR')[01], tamSX3('RC_VALOR')[02], pesqPict('SRC','RC_VALOR') }) //STR0012: 'Qtd Pendente'

	case nType == 2 .or. nType == 3

		aAdd(aStruct, { 'FUN_IC' 	, STR0013 					, 'C'									,  05						, 00						, '@!'						 	}) //STR0013: "Cod. IC's"
		aAdd(aStruct, { 'FUN_FIL' 	, FwX3Titulo( 'RA_FILIAL')	, FWSX3Util():GetFieldType('RA_FILIAL')	,  tamSX3('RA_FILIAL')[01]	, tamSX3('RA_FILIAL')[02]	, pesqPict('SRA','RA_FILIAL') 	})
		aAdd(aStruct, { 'FUN_CNPJ' 	, FwX3Titulo( 'R2_CGC'  )	, FWSX3Util():GetFieldType('R2_CGC')	,  tamSX3('R2_CGC')[01]		, tamSX3('R2_CGC')[02]		, pesqPict('SR2','R2_CGC') 		})
		aAdd(aStruct, { 'FUN_CPF' 	, FwX3Titulo( 'RA_CIC'  )	, FWSX3Util():GetFieldType('RA_CIC')	,  tamSX3('RA_CIC')[01]		, tamSX3('RA_CIC')[02]		, pesqPict('SRA','RA_CIC') 		})
		aAdd(aStruct, { 'FUN_MAT' 	, FwX3Titulo( 'RA_MAT'  ) 	, FWSX3Util():GetFieldType('RA_MAT' ) 	,  tamSX3('RA_MAT')[01]		, tamSX3('RA_MAT')[02]		, pesqPict('SRA','RA_MAT') 		})
		aAdd(aStruct, { 'FUN_NOME' 	, FwX3Titulo( 'RA_NOME' )	, FWSX3Util():GetFieldType('RA_NOME')	,  tamSX3('RA_NOME')[01]	, tamSX3('RA_NOME')[02]		, pesqPict('SRA','RA_NOME') 	})
		aAdd(aStruct, { 'FUN_DTRES' , STR0014 					, FWSX3Util():GetFieldType('RA_ADMISSA'),  tamSX3('RA_ADMISSA')[01]	, tamSX3('RA_ADMISSA')[02]	, pesqPict('SRA','RA_ADMISSA') 	}) //STR0014: 'Dt Rescisão'
		aAdd(aStruct, { 'FUN_VLRLIQ', STR0015 			 		, FWSX3Util():GetFieldType('RC_VALOR')	,  tamSX3('RC_VALOR')[01]	, tamSX3('RC_VALOR')[02]	, pesqPict('SRC','RC_VALOR') 	}) //STR0015: 'Vlr Liq. Rescisão'
		aAdd(aStruct, { 'FUN_DMES' 	, STR0016 					, FWSX3Util():GetFieldType('RC_VALOR')	,  tamSX3('RC_VALOR')[01]	, tamSX3('RC_VALOR')[02]	, pesqPict('SRC','RC_VALOR') 	}) //STR0016: 'Descontado no Mês'
		aAdd(aStruct, { 'FUN_DRES' 	, STR0017 					, FWSX3Util():GetFieldType('RC_VALOR')	,  tamSX3('RC_VALOR')[01]	, tamSX3('RC_VALOR')[02]	, pesqPict('SRC','RC_VALOR') 	}) //STR0017: 'Descontado na Rescisão'
		aAdd(aStruct, { 'FUN_ESPEIC', STR0018 		 			, FWSX3Util():GetFieldType('RC_VALOR')	,  tamSX3('RC_VALOR')[01]	, tamSX3('RC_VALOR')[02]	, pesqPict('SRC','RC_VALOR') 	}) //STR0018: "Esperado IC's"
		aAdd(aStruct, { 'FUN_DTCOM' , STR0019 					, FWSX3Util():GetFieldType('RA_ADMISSA'),  tamSX3('RA_ADMISSA')[01]	, tamSX3('RA_ADMISSA')[02]	, pesqPict('SRA','RA_ADMISSA') 	}) //STR0019: 'Data Comunicação'
	endCase
return aStruct


/*/{Protheus.doc} function CONSIG005
Definição das colunas a serem utilizadas pelo FWFormBrowse
@author  Ruann Carlos Rodrigues Lima
@since   23/10/2023
@version 1.0
/*/
static function fCreateStruct( 	aContent	as array		,;
		nType		as numeric 		) as array

	local nI 		:= 0  as character
	local aHeader  	:= {} as array

	default aContent := {}
	default nType	 := 1

	for nI := 1 to len( aContent )
		aAdd( aHeader, FWBrwColumn():New())
		aTail( aHeader ):setTitle( aContent[nI][2] )
		aTail( aHeader ):setSize( aContent[nI][4] )
		aTail( aHeader ):setDecimal( aContent[nI][5] )
		aTail( aHeader ):setPicture( aContent[nI][6] )
		aTail( aHeader ):setEdit(.F.)
		aTail( aHeader ):setType( aContent[nI][3] )
		aTail( aHeader ):setAlign('LEFT')

		if aContent[nI][3] == "N"
			aTail( aHeader ):nSize := 8
		else
			aTail( aHeader ):nSize :=  aContent[nI][4] - 1
		endIf

		do case
		case nType == 1
			aTail( aHeader ):setData( &( "{ ||  __aTableIC[__oBrwIC:At()]["+ alltrim( cvalTochar(nI+1) ) + "]  }" ) )

		case nType == 2
			aTail( aHeader ):setData( &( "{ ||  __aTableCol[__oBrwColab:At()]["+ alltrim( cvalTochar(nI+1) ) + "]  }" ) )

		case nType == 3
			aTail( aHeader ):setData( &( "{ ||  __aTableOk[__oBrwOk:At()]["+ alltrim( cvalTochar(nI) ) + "]  }" ) )

		end Case
	next
return aHeader


/*/{Protheus.doc} function CONSIG005
Funcionalidade de marcação e desmarcação dos grids
@author  Ruann Carlos Rodrigues Lima
@since   23/10/2023
@version 1.0
/*/
static function fMark(oBrowse, aColsBrw, nType, lAll ) as logical
	local nI := 0
	local nX := 0

	if lAll
		if nType == 2
			for nI := 1 to len(aColsBrw)
				if empty( aColsBrw[nI][13] )
					aColsBrw[nI][01] := __lMarker
				endIf
			next
		else
			for nI := 1 to len(aColsBrw)
				aColsBrw[nI,1] := __lMarker
			next
		endIf

		oBrowse:Refresh()

		__lMarker := !__lMarker
	else
		if nType == 2
			if empty( aColsBrw[oBrowse:nAt][13] )
				aColsBrw[oBrowse:nAt][01] := !aColsBrw[oBrowse:nAt][01]
			else
				msgInfo( STR0020 ) //STR0020: 'O registro já foi comunicado a rescisão.'
			endIf
		else
			aColsBrw[oBrowse:nAt][01] := !aColsBrw[oBrowse:nAt][01]
		endIf
	endIf

	if nType == 1
		__aTableCol := {}

		for nX := 1 to len( __aTableIC )
			if aColsBrw[nX][01]
				for nI := 1 to len( __aTableBkp )
					if aColsBrw[nX][2] == __aTableBkp[nI][2]
						aAdd( __aTableCol , __aTableBkp[nI] )
					endIf
				next nI
			else
				for nI := 1 to len( __aTableBkp )
					if aColsBrw[nX][2] == __aTableBkp[nI][2]
						__aTableBkp[nI][1] := .F.
					endIf
				next nI
			endIf
		next nX

		aSort(__aTableCol,,,{|x,y| x[7]+x[2] < y[7]+y[2] })

		__oBrwColab:SetArray( __aTableCol )
		__oBrwColab:Refresh(.T.)
	endIf
	oBrowse:setColPos(1)
return .T.


/*/{Protheus.doc} function CONSIG005
Criação do array das instituições de crédito
@author  Ruann Carlos Rodrigues Lima
@since   23/10/2023
@version 1.0
/*/
static function fGetIC() as array
	local aArrayBrw := fGet137()
	local aTable 	:= {}
	local nI 		:= 0

	for nI := 1 to len( aArrayBrw )
		aAdd( aTable, { .T., aArrayBrw[nI][03], aArrayBrw[nI][04], aArrayBrw[nI][05], aArrayBrw[nI][06] } )
	next nI

	aSort( aTable,,,{|x,y| x[2] < y[2] })
return aTable


/*/{Protheus.doc} function CONSIG005
Responsável pela construção da consulta das rescições do período
@author  Ruann Carlos Rodrigues Lima
@since   23/10/2023
@version 1.0
/*/
static function fGetCol( aPerg ) as array
	local nOrdem 	:= 1
	local aIC 		:= fGet137()
	local nI		:= 0
	local cVerbaMes	:= ''
	local cVerbaRes := ''
	local aVerbaLiq := fGetLiq()
	local cQuery	:= ''
	local aTable 	:= {}
	local cRotFol   := fGetCalcRot('1')
	local cRotRes   := fGetCalcRot('4')

	for nI := 1 to len( aIC )
		cVerbaMes += aIC[nI][02] + iif( nI == len(aIC), '' , ';' )
		cVerbaRes += aIC[nI][02] + iif( nI == len(aIC), '' , ';' )
	next nI

	cQuery := "	SELECT 							"
	cQuery += "			SRG.RG_FILIAL			"
	cQuery += "		,	SRG.RG_MAT				"
	cQuery += "		,	SRA.RA_NOME				"
	cQuery += "		,	SRA.RA_CIC				"
	cQuery += "		,	SRG.RG_DATADEM			"
	cQuery += "		,	SRG.RG_DTGERAR			"
	cQuery += "		,	SRR.RR_VALOR CONSG		"
	cQuery += "		,	ISNULL( ( SELECT RR_VALOR  FROM " + retSqlName("SRR") + " LSRR WHERE LSRR.D_E_L_E_T_ = '' AND LSRR.RR_FILIAL  = ? AND LSRR.RR_MAT = SRG.RG_MAT AND LSRR.RR_PD = ? ) , 0  ) LIQ 	"
	cQuery += "		,	ISNULL( ( SELECT RC_VALOR  FROM " + retSqlName("SRC") + " SRC  WHERE  SRC.D_E_L_E_T_ = '' AND  SRC.RC_FILIAL  = ? AND  SRC.RC_MAT = SRG.RG_MAT AND  SRC.RC_PD IN (?) AND RC_ROTEIR = '?'  AND RC_DATA BETWEEN ? AND ? ) , 0 ) DESCMES	"
	cQuery += "		,	0 ESPIC					"
	cQuery += "		,	SRR.RR_PD 				"
	cQuery += "		,	RG_TIPORES				"
	cQuery += "	FROM 							"
	cQuery += "		" + retSqlName("SRG") + " SRG	"
	cQuery += "		INNER JOIN " + retSqlName("SRA") + " SRA ON SRA.D_E_L_E_T_ = '' AND SRA.RA_FILIAL = ? AND SRA.RA_MAT = SRG.RG_MAT		"
	cQuery += "		INNER JOIN " + retSqlName("SRR") + " SRR ON SRR.D_E_L_E_T_ = '' AND SRR.RR_FILIAL = ? AND SRR.RR_MAT = SRG.RG_MAT AND SRR.RR_TIPO3 = 'R' AND SRR.RR_ROTEIR = '?'	"
	cQuery += "	WHERE 								"
	cQuery += "			SRG.D_E_L_E_T_ = '' 		"
	cQuery += "		AND SRG.RG_FILIAL 	BETWEEN ? AND ?			"
	cQuery += "		AND SRG.RG_MAT 		BETWEEN ? AND ?			"
	cQuery += "		AND SRG.RG_DTGERAR  BETWEEN ? AND ?			"
	cQuery += "		AND SRG.RG_ROTEIR  = '?'		"
	cQuery += "		AND SRG.RG_EFETIVA = 'S'				 	"
	cQuery += "		AND SRR.RR_PD IN (?)"
	cQuery += "	ORDER BY 				"
	cQuery += "		RG_FILIAL,  RA_NOME "

	cQuery := changeQuery( cQuery )

	oQry := FwExecStatement():New(cQuery)

	oQry:setString(	nOrdem++ , FWxFilial("SRR")	 )
	oQry:setString(	nOrdem++ , aVerbaLiq[01][01] )
	oQry:setString(	nOrdem++ , FWxFilial("SRC")	 )
	oQry:setString(	nOrdem++ , cVerbaMes	 	 )
	oQry:setString(	nOrdem++ , cRotFol	 		 )
	oQry:setDate(	nOrdem++ , aPerg[05]		 )
	oQry:setDate(	nOrdem++ , aPerg[06]		 )
	oQry:setString(	nOrdem++ , FWxFilial("SRA")	 )
	oQry:setString(	nOrdem++ , FWxFilial("SRR")	 )
	oQry:setString(	nOrdem++ , cRotRes	 		 )
	oQry:setString(	nOrdem++ , aPerg[01]		 )
	oQry:setString(	nOrdem++ , aPerg[02]		 )
	oQry:setString(	nOrdem++ , aPerg[03]		 )
	oQry:setString(	nOrdem++ , aPerg[04]		 )
	oQry:setDate(	nOrdem++ , aPerg[05]		 )
	oQry:setDate(	nOrdem++ , aPerg[06]		 )
	oQry:setString(	nOrdem++ , cRotRes	 		 )
	oQry:setString(	nOrdem++ , cVerbaRes	 	 )

	cTmp := oQry:OpenAlias()

	while (cTmp)->( !eof() )
		nPos := aScan( aIC , {|x| x[02] == (cTmp)->RR_PD } )

		cIC     := alltrim ( aIC[nPos][03] )
		cCNPJ   := alltrim( fwSM0Util():getSM0Data(, (cTmp)->RG_FILIAL, {"M0_CGC"})[1,2])
		dDtCom  := fGetDtCom( (cTmp)->RG_FILIAL, cCNPJ, (cTmp)->RA_CIC , (cTmp)->RG_MAT, cIC  )
		nVlrEsp := fDebitBalanceEmployee( (cTmp)->RG_FILIAL, (cTmp)->RA_CIC, cCNPJ, sToD((cTmp)->RG_DATADEM), (cTmp)->RG_MAT, (cTmp)->RA_NOME, cIC )

		aAdd( aTable	, { 	.F.													,;
			cIC													,;
			(cTmp)->RG_FILIAL									,;
			cCNPJ												,;
			(cTmp)->RA_CIC										,;
			(cTmp)->RG_MAT										,;
			if(__lOfusca, Replicate('*',30), (cTmp)->RA_NOME )	,;
				sToD( (cTmp)->RG_DATADEM ) 							,;
				(cTmp)->LIQ											,;
				(cTmp)->DESCMES										,;
				(cTmp)->CONSG										,;
				nVlrEsp												,;
				dDtCom												;
				} )

			nPos 	:= aScan( __aTableIC , {|x| x[02] == cIC } )
			nPosTot := iif( empty(dDtCom) , 5, 4 )

			if nPos > 0
				__aTableIC[nPos][nPosTot]++
			endIf

			(cTmp)->( dbSkip() )
		endDo

		__aTableBkp := aClone( __aTableIC )
		__aTableIC  := {}

		for nI := 1 to len( __aTableBkp )
			if  __aTableBkp[nI][04] > 0 .or.;
					__aTableBkp[nI][05] > 0

				aAdd(  __aTableIC , __aTableBkp[nI] )
			endIf
		next nI

		__oBrwIC:setArray( __aTableIC )
		__oBrwIC:refresh(.T.)

		(cTmp)->( dbCloseArea() )

		aSort(aTable,,,{|x,y| x[7]+x[2] < y[7]+y[2] })

		return aTable


/*/{Protheus.doc} function CONSIG005
Responsável por construir o array que será apresentando antes do processamento
@author  Ruann Carlos Rodrigues Lima
@since   23/10/2023
@version 1.0
/*/
static function fGetOk() as array
	local aTable 	:= {}
	local nI 		:= 0
	local nX 		:= 0
	local aData		:= {}
	local cEmail 	:= ''
	local cPhone 	:= ''
	local cMotivo 	:= ''

	dbSelectArea('SRA')
	SRA->( dbSetOrder(1) )

	dbSelectArea('SRG')
	SRG->( dbSetOrder(3) )

	for nI := 1 to len( __aTableCol )
		if __aTableCol[nI][01]
			aData  	:= {}
			cEmail 	:= ''
			cPhone 	:= ''
			cMotivo := ''

			//retiro o campo de marcação
			for nX := 2 to len( __aTableCol[nI] )
				aAdd( aData , __aTableCol[nI][nX] )
			next nX

			if SRA->( dbSeek( xFilial('SRA') + __aTableCol[nI][06] ) )
				cEmail := alltrim( iif( empty( SRA->RA_EMAIL ), SRA->RA_EMAIL2 , SRA->RA_EMAIL ) )
				cPhone := alltrim( SRA->RA_TELEFON )
			endIf

			if SRG->( dbSeek( xFilial('SRG') + __aTableCol[nI][06] + dToS( __aTableCol[nI][08] ) ) )
				cMotivo := alltrim( fDescRCC( 'S043', SRG->RG_TIPORES, 1, 2, 3, 30 ) )
			endIf

			aAdd( aData , cEmail  )
			aAdd( aData , cPhone  )
			aAdd( aData , cMotivo )
			aAdd( aTable, aData  )
		endIf
	next nI

	SRA->( dbCloseArea() )
	SRG->( dbCloseArea() )
return aTable


/*/{Protheus.doc} function CONSIG005
Criação do objeto wizard no momento da confirmação
@author  Ruann Carlos Rodrigues Lima
@since   23/10/2023
@version 1.0
/*/
static function fProc(aPerg) as logical
	local oWizard 	 := nil as object
	local oStep01 	 := nil as object
	local oStep02 	 := nil as object
	local oStatus 	 := nil as object
	local oModal	 := nil as object
	local oContainer := nil as object

	__aTableOk := fGetOk()

	if len( __aTableOk ) == 0
		Help( " ", 1, STR0024,, STR0025, 1 )  //STR0024: 'Atenção' | STR0025: 'Nenhum registro selecionado.'
		return .F.
	endIf

	oModal := FWDialogModal():New()
	oModal:setEscClose(.F.)
	oModal:setBackGround(.T.)
	oModal:setFreeArea( 500 , 300 )
	oModal:enableFormBar(.F.)
	oModal:createDialog()

	oContainer := tPanel():New( ,,, oModal:getPanelMain() )
	oContainer:Align := CONTROL_ALIGN_ALLCLIENT

	oWizard := FWWizardControl():New( oContainer )
	oWizard:ActiveUISteps()

	// Pagina 1
	oStep01 := oWizard:AddStep('STEP1')
	oStep01:SetStepDescription( STR0001 ) //STR0001: 'Comunicar Rescisão'
	oStep01:SetConstruction({|oPanel| fMakePg01(oPanel, aPerg) })
	oStep01:SetNextAction({|| fValidPg01()  })
	oStep01:SetCancelAction({|| .T. , oModal:DeActivate()  })

	// Pagina 2
	oStep02 := oWizard:AddStep('STEP2')
	oStep02:SetStepDescription( STR0021 )	 //STR0021: Processamento
	oStep02:SetConstruction({|oPanel| fMakePg02(oPanel,@oStatus, oWizard, aPerg) })
	oStep02:SetNextAction(	{|| .T. , oModal:DeActivate() } )
	oStep02:SetPrevWhen( 	{|| .F. } )
	oStep02:SetCancelWhen( 	{|| .F. } )
	oStep02:SetNextTitle( STR0022 )  //STR0022: Fechar

	oWizard:Activate()
	oModal:Activate()

	oWizard:Destroy()
return .T.


/*/{Protheus.doc} function CONSIG005
Criação para primeira página do Wizard
@author  Ruann Carlos Rodrigues Lima
@since   23/10/2023
@version 1.0
/*/
static function fMakePg01(oDlg, aPerg ) as logical

	__oBrwOk := fCreateBrw(	oDlg		,;
		STR0023		,; //STR0023: 'Funcionários selecionados para a comunicação'
	3			,;
		aPerg		,;
		@__aTableOk	,;
		@__oBrwOk	)
return .T.


/*/{Protheus.doc} function CONSIG005
Validação da primeira página do Wizard
@author  Ruann Carlos Rodrigues Lima
@since   23/10/2023
@version 1.0
/*/
static function fValidPg01() as logical
	if !msgYesNo( STR0027 ) //STR0027: 'Deseja comunicar a rescisão? Esse processo é irreversível'
		return .F.
	endIf
return .T.


/*/{Protheus.doc} function CONSIG005
Criação da segunda página do Wizard
@author  Ruann Carlos Rodrigues Lima
@since   23/10/2023
@version 1.0
/*/
static function fMakePg02(oDlg,  oStatus, oWizard, aPerg) as logical
	local oBrw	 		 := nil as object
	local oTitulo		 := nil as object
	local oDesc			 := nil as object
	local oFont13B 		 := tFont():New("Arial", , -13, , .T.) as object
	local oFont11  		 := tFont():New("Arial", , -11, , .F.) as object

	__aStatus := {}

	oDlg:oWnd:lEscClose := .F.

	oWizard:oUiStepWizard:SetPrevVisibility(.F.)
	oWizard:oUiStepWizard:SetNextVisibility(.F.)

	oTitulo    := TSay():New(05,  10, {|| STR0028 }, oDlg, , oFont13B, , , , .T., , , 290, 20) //STR0028: "Executando... aguarde."
	oDesc      := TSay():New(15,  10, {|| ""      }, oDlg, , oFont11 , , , , .T., , , 290, 20)

	aAdd(__aStatus, {__tRefresh, STR0049 + ':' + ' 0%', STR0050 } ) //"Sincronização dos Dados" # "Pendente"

	oBrw := TSBrowse():New(30, 10, 480, 140, oDlg, , 16, , 1)

	oBrw:AddColumn( TCColumn():New(''     	,,,{|| },{|| },,020 , .T.) )
	oBrw:AddColumn( TCColumn():New( STR0029	,,,{|| },{|| },,280	, .F.) ) //STR0029: 'Processo'
	oBrw:AddColumn( TCColumn():New( STR0030	,,,{|| },{|| },,100 , .F.) ) //STR0030: 'Status'
	oBrw:SetArray(__aStatus)

	__oTimer := TTimer():New( 500, {|| fUpdStatus( @oBrw, oTitulo, oDesc, oStatus, oWizard, aPerg ) }, oDlg:oWnd )
	__oTimer:Activate()
return .T.


/*/{Protheus.doc} function CONSIG005
Processamento do envio dos itens selecionados
@author  Ruann Carlos Rodrigues Lima
@since   23/10/2023
@version 1.0
/*/
static function fUpdStatus(oBrw, oTitulo, oDesc, oStatus, oWizard, aPerg)
	local nX 	:= 0  as numeric
	local nPerc := 0  as numeric
	local aRet 	:= {} as array

	for nX := 1 to len( __aTableOk )
		nPerc := ( ( nX * 100 ) / len( __aTableOk ) )

		__aStatus[1][1] := __tRefresh
		__aStatus[1][2] := iif( nPerc == 100 , STR0031, STR0032 ) + STR0033 + cValtoChar( nPerc ) + '%' //STR0031: 'Comunicado' # STR0032: 'Comunicando' # STR0033: ' a Rescisão '
		__aStatus[1][3] := iif( nPerc == 100 , STR0034, STR0035 ) //STR0034: 'Concluído' # STR0035: 'Pendente'

		aRet := fEmployeeTermination( 	__aTableOk[nX][01]	,; //cIC
		__aTableOk[nX][02]	,; //cFilFunc
		__aTableOk[nX][03]	,; //cCNPJ
		__aTableOk[nX][04]	,; //cCPF
		__aTableOk[nX][05]	,; //cMat
		__aTableOk[nX][06]	,; //cNome
		__aTableOk[nX][07]	,; //dDataDem
		__aTableOk[nX][08]	,; //nVlrResc
		__aTableOk[nX][09]	,; //nVlrMes
		__aTableOk[nX][10]	,; //nVlrDRes
		__aTableOk[nX][13]	,; //cEmail
		__aTableOk[nX][14]  ,; //cPhone
		__aTableOk[nX][15]  )  //cMotivo
		if aRet[01]

			fInsertLog( __tOk , nX , aRet[02]	 )

			aRet := fInsertReg(	__aTableOk[nX][01]	,; //cIC
			__aTableOk[nX][02]	,; //cFilIC
			__aTableOk[nX][03]	,; //cCNPJ
			__aTableOk[nX][04]	,; //cCPF
			__aTableOk[nX][05]	)  //cMat

			fInsertLog( __tOk , nX ,  aRet[02]	 )
		else
			fInsertLog( __tError , nX , aRet[02]	 )
		endIf

		oBrw:SetArray(__aStatus)
		oBrw:Refresh()
	next nX

	//reforço o log
	oBrw:SetArray(__aStatus)
	oBrw:Refresh()

	sleep(500)

	oTitulo:SetText( STR0036 )  //STR0036: "Processamento finalizado."
	oDesc:SetText( STR0037 ) //STR0037: "Comunicação da Rescisão concluído com sucesso."

	__oTimer:DeActivate()

	fRefresh( aPerg )

	oWizard:oUiStepWizard:SetNextVisibility(.T.)
return


/*/{Protheus.doc} function CONSIG005
Inclusão no log de processamento
@author  Ruann Carlos Rodrigues Lima
@since   23/10/2022
@version 1.0
/*/
static function fInsertLog( cLegend, nIndice,  cMsg )
	aAdd( __aStatus, { 	cLegend		,;
		__aTableOk[nIndice][01] + ' - ' + __aTableOk[nIndice][02] + ' - ' + __aTableOk[nIndice][06]    	,;
		cMsg		})
return


/*/{Protheus.doc} function CONSIG005
Consulta das informações na tabela S137
@author  Ruann Carlos Rodrigues Lima
@since   23/10/2022
@version 1.0
/*/
static function fGet137() as array
	local aData 	:= {}		as array
	local aTabS137	:= {}		as array
	local nI 		:= 0 		as numeric

	fCarrTab( @aTabS137, "S137", Nil, .T. )

	if len( aTabS137 ) > 0
		for nI := 1 to len( aTabS137 )
			aAdd( aData, {	aTabS137[nI][05]					,;
				aTabS137[nI][06]					,;
				substr( aTabS137[nI][07], 1, 4) 	,;
				alltrim( substr( aTabS137[nI][07], at('-', aTabS137[nI][07])+2 , len(aTabS137[nI][07]) )  ) ,;
				0									,;
				0									})
		next nI
	endIf
return aData


/*/{Protheus.doc} function CONSIG005
Consulta da verba do liquida na rescisão
@author  Ruann Carlos Rodrigues Lima
@since   23/10/2022
@version 1.0
/*/
static function fGetLiq() as array
	local aRet 		:= {}		as array
	local cIdCalc 	:= '0126'	as character
	local cQuery	:= ''		as character
	local nOrdem	:= 1		as numeric

	cQuery := "	SELECT 					"
	cQuery += "			RV_COD			"
	cQuery += "		, 	RV_DESC			"
	cQuery += "		, 	RV_CODFOL 		"
	cQuery += "	FROM 					"
	cQuery += "		" + retSqlName("SRV") + " SRV	"
	cQuery += "	WHERE 								"
	cQuery += "			SRV.D_E_L_E_T_ 	= ''		"
	cQuery += "		AND SRV.RV_FILIAL 	= ? 		"
	cQuery += "		AND SRV.RV_CODFOL 	= ?			"

	cQuery := changeQuery( cQuery )

	oQry := FwExecStatement():New(cQuery)

	oQry:setString(	nOrdem++ , FWxFilial("SRV")	)
	oQry:setString(	nOrdem++ , cIdCalc	)

	cAlias := oQry:OpenAlias()

	while (cAlias)->( !eof() )
		aRet := {{  (cAlias)->RV_COD 	,;
			(cAlias)->RV_DESC 	,;
			(cAlias)->RV_CODFOL	}}

		(cAlias)->( dbSkip() )
	endDo

	(cAlias)->( dbCloseArea() )
return aRet


/*/{Protheus.doc} function CONSIG005
Gravação dos registros na tabela RUD
@author  Ruann Carlos Rodrigues Lima
@since   23/10/2022
@version 1.0
/*/
static function fInsertReg( cIC, cFilIC, cCNPJ, cCPF, cMat ) as array
	local aArea  := getArea() 		as array
	local cAlias := 'RUD' 			as character
	local aRet   := { .F. , '' } 	as array

	dbSelectArea( cAlias )

	(cAlias)->( dbSetOrder(3) ) //RUD_FILIAL+RUD_MAT+RUD_IC

	recLock( cAlias , .T. )
	(cAlias)->RUD_FILIAL := cFilIC
	(cAlias)->RUD_CNPJ   := cCNPJ
	(cAlias)->RUD_CPF    := cCPF
	(cAlias)->RUD_MAT 	 := cMat
	(cAlias)->RUD_DTCOM  := date()
	(cAlias)->RUD_HORA   := time()
	(cAlias)->RUD_IC 	 := cIC
	(cAlias)->( msUnLock() )

	(cAlias)->( dbCloseArea() )

	restArea( aArea )

	aRet := { .T. , STR0039 } //STR0039: 'Registro inserido com sucesso.'
return aRet


/*/{Protheus.doc} function CONSIG005
Consulta da data de comunicação com o Totvs Consignado
@author  Ruann Carlos Rodrigues Lima
@since   23/10/2022
@version 1.0
/*/
static function fGetDtCom( cFilIC, cCNPJ, cCPF, cMat, cIC ) as date
	local aArea  := getArea()	as array
	local cAlias := 'RUD' 		as character
	local dRet	 := cToD('//')	as date

	dbSelectArea( cAlias )

	(cAlias)->( dbSetOrder(3) ) //RUD_FILIAL+RUD_MAT+RUD_IC

	if (cAlias)->( dbSeek( cFilIC + cMat + cIC  ) )
		dRet := (cAlias)->RUD_DTCOM
	endIf

	if empty( dRet )
		(cAlias)->( dbSetOrder(2) ) //RUD_FILIAL+RUD_CNPJ+RUD_CPF+RUD_IC
		(cAlias)->( dbGoTop() )

		if (cAlias)->( dbSeek( cFilIC + cCNPJ + cCPF + cIC  ) )
			dRet := (cAlias)->RUD_DTCOM
		endIf
	endIf

	(cAlias)->( dbCloseArea() )
	restArea( aArea )
return dRet


/*/{Protheus.doc} function CONSIG005
Refresh de toda a rotina
@author  Ruann Carlos Rodrigues Lima
@since   23/10/2022
@version 1.0
/*/
static function fRefresh( aPerg ) as logical
	__aTableIC  := fGetIC()
	__aTableCol := fGetCol( aPerg )
	__aTableBkp := aClone( __aTableCol )
	__aTableOk  := {}

	__oBrwIC:setArray( __aTableIC )
	__oBrwIC:refresh(.T.)

	__oBrwColab:setArray( __aTableCol )
	__oBrwColab:refresh(.T.)
return .T.


/*/{Protheus.doc} function CONSIG005
Consulta do valor esperado para Instituição de crédito
@author  Ruann Carlos Rodrigues Lima
@since   23/10/2022
@version 1.0
/*/
static Function fDebitBalanceEmployee( cFilFunc, cCPF, cCNPJ, dDataDem, cMat, cNome, cIC ) as numeric
	local oInteg	:= nil					as object
	local oJason    := JsonObject():New()	as object
	local oParams	:= JsonObject():New()	as object
	local aHeader   := {}					as array
	local aInfo		:= {}					as array
	local cRacToken := ''					as character
	local cEndPoint := fGetURLCsg()			as character
	local nValor    := 0					as numeric
	local lRetRest  := .T.					as logical

	fInfo(@aInfo, cFilFunc )

	oInteg    := FwRest():New(cEndPoint + "/api/erp/v1/debit-balance-employee")
	cRacToken := fConsTKConsig()

	aAdd(aHeader, "Content-Type: application/json; charset=UTF-8")
	aAdd(aHeader, "Authorization: Bearer " + cRacToken)

	oParams['cpf']  := cCPF
	oParams['cnpj'] := aInfo[8]
	oParams['operadora'] := cIC
	oParams['date'] := FWTimeStamp(6, dDataDem, "00:00:00")

	oInteg:setPath("?cpf=" + oParams['cpf'] + "&cnpj=" + oParams['cnpj'] + "&dateTermination=" + oParams['date']+  "&partnerCode=" + oParams['operadora'])

	if ( lRetRest := oInteg:Get(aHeader) )
		if ( lRetRest := ( oInteg:ORESPONSEH:CSTATUSCODE == "200" .AND. !Empty(oInteg:GetResult()) ) )
			oJason:FromJson(oInteg:GetResult())
			nValor := oJason["totalDebitBalanceAmount"]
		else
			nValor := 0
		endIf
	endIf
return nValor


/*/{Protheus.doc} function CONSIG005
Comunicação com o Totvs Consignado para comunicar a rescisão
@author  Ruann Carlos Rodrigues Lima
@since   23/10/2022
@version 1.0
/*/
static Function fEmployeeTermination( cIC, cFilFunc, cCNPJ, cCPF, cMat, cNome, dDataDem, nVlrResc, nVlrMes, nVlrDRes, cEmail, cPhone, cMotivo ) as array
	local oInteg	:= nil					as object
	local oParams	:= JsonObject():New()	as object
	local aHeader   := {}					as array
	local aInfo		:= {}					as array
	local cRacToken := ''					as character
	local cEndPoint := fGetURLCsg()			as character
	local lRetRest  := .T.					as logical
	local aRet		:= { .F. , ''}			as array

	fInfo(@aInfo, cFilFunc )

	oInteg    := FwRest():New(cEndPoint)
	cRacToken := fConsTKConsig()

	aAdd(aHeader, "Content-Type: application/json; charset=UTF-8")
	aAdd(aHeader, "Authorization: Bearer " + cRacToken)

	oParams['cpf']  						:= cCPF
	oParams['cnpj'] 						:= aInfo[8]
	oParams['dataTermination'] 				:= FWTimeStamp(6, dDataDem, "00:00:00")
	oParams['operadora'] 					:= cIC
	oParams['terminationNetAmount'] 		:= nVlrResc
	oParams['terminationMonthInstallment'] 	:= nVlrDRes
	oParams['phone'] 						:= cPhone
	oParams['email'] 						:= cEmail
	oParams['conciliationInstallment'] 		:= nVlrMes
	oParams['reason'] 						:= cMotivo

	oInteg:setPath('/api/erp/v1/employee-termination')
	oInteg:SetPostParams( oParams:toJson() )
	oInteg:SetChkStatus(.F.)

	if ( lRetRest := oInteg:Post(aHeader) )
		if ( lRetRest := ( !Empty(oInteg:GetResult()) ) )
			if oInteg:GetResult() == 'true'
				aRet := { .T. , STR0040 } //STR0040: 'Transmitido com sucesso'
			else
				aRet := { .F. , STR0041 } //STR0041: 'Erro na transmissão'
			endIf
		else
			aRet := { .F. , STR0041 +': ' + oInteg:getLastError() } //STR0041: 'Erro na transmissão'
		endIf
	endIf
return aRet
