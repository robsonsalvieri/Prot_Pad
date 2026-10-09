#INCLUDE "totvs.ch"
#INCLUDE "FWMVCDef.ch"
#INCLUDE "OFIA010.CH"

Static codVRN := "OFIA010"

/*/{Protheus.doc} OFIA010
	Tela para configuração dos dados básicos do DSM Scania

	@author Andre Luis Almeida
	@since  13/08/2018
/*/
function OFIA010()
local   nI
local   aObjects      := {}
local   aInfo         := {}
local   aPos          := {}
local   aSizeHalf     := MsAdvSize(.t.)
local   nLinhas       := 9999
local   aArea         := getArea()
private aTagsMSMGet   := {}
private aConfMSMGet   := {}
private aColsSM0      := {}
private aColsSBM      := {}
private aColsVS0 	  := {}
private aHeadSM0      := {}
private aHeadSBM      := {}
private aHeadVS0      := {}
private aAllFilSM0    := FWAllFilial( /*[ cCompany ]*/, /*[ cUnitBusiness ]*/, /*[ cGrpCompany ]*/, /*[ lOnlyCode ] := */ .F.)
private lLostSales	  := .f.
private lVPJCodigo 	  := .f.
Private cMotivo 	  := "000004"  //Filtro da consulta do motivo de Cancelamentos (Orcamento)
private cGruFor       := "04" // para filtrar o grupo na consulta padrão VEG (FiltroVEG())

	if FWAliasInDic("VPJ")
		DbSelectArea('VPJ')
		lVPJCodigo := VPJ->(FieldPos("VPJ_CODIGO")) > 0
	endif

	aTagsMSMGet   := OA0100021_Campos("Tags")
	aConfMSMGet   := OA0100021_Campos("Configuracoes")
	aHeadSM0      := OA0100011_aHeader("SM0")
	aHeadSBM      := OA0100011_aHeader("SBM")
	aHeadVS0      := OA0100011_aHeader("VS0")
	aSM0Data      := FWSM0Util():GetSM0Data( cEmpAnt , , { "M0_CODFIL" } )

	for nI := 1 to len(aTagsMSMGet)
		private &("M->"+aTagsMSMGet[nI,2]) := space(aTagsMSMGet[nI,4])
	next
	for nI := 1 to len(aConfMSMGet)
		private &("M->"+aConfMSMGet[nI,2]) := space(aConfMSMGet[nI,4])
	next

	OA010008C_getConfig()

	aInfo := { aSizeHalf[ 1 ], aSizeHalf[ 2 ],aSizeHalf[ 3 ] ,aSizeHalf[ 4 ], 3, 3 }
	aAdd( aObjects, { 0 , 0 , .T. , .T. } )
	aPos := MsObjSize( aInfo, aObjects )

	DEFINE MSDIALOG oOFIA010 FROM aSizeHalf[7],0 TO aSizeHalf[6],aSizeHalf[5] TITLE STR0001 OF oMainWnd PIXEL STYLE DS_MODALFRAME STATUS // DSM Parametros
	oOFIA010:lEscClose := .F.

	if lVPJCodigo
		oFolders := TFolder():New(aPos[1,1],aPos[1,2],{STR0002,STR0003,STR0004,STR0005,STR0055},{}, oOFIA010,,,,.t.,.f.,aPos[1,4],aPos[1,3]-aPos[1,1]) // Filiais / Grupos / TAGs para Envio / Configuracoes /  Lost Sale
	else
		oFolders := TFolder():New(aPos[1,1],aPos[1,2],{STR0002,STR0003,STR0004,STR0005},{}, oOFIA010,,,,.t.,.f.,aPos[1,4],aPos[1,3]-aPos[1,1]) // Filiais / Grupos / TAGs para Envio / Configuracoes
	endif

	oFWLayer1 := FWLayer():New()
	oFWLayer1:Init(oFolders:aDialogs[1],.F.)
	oFWLayer1:AddLine('WIN_TOPO',100,.F.)
	oWIN_TOPO1 := oFWLayer1:GetLinePanel('WIN_TOPO')

	oGDSM0:= MsNewGetDados():New(0,0,100,100,GD_INSERT+GD_UPDATE+GD_DELETE,"OA0100051_LinhaOK('SM0')",,,{'XM0_CODIGO','XM0_WAREID'},,nLinhas,"OA0100041_FieldOK('SM0')",,,oWIN_TOPO1,aHeadSM0,aColsSM0 )
	oGDSM0:oBrowse:bChange := { || FG_MEMVAR(oGDSM0:aHeader,oGDSM0:aCols,oGDSM0:nAt) }
	oGDSM0:oBrowse:Align   := CONTROL_ALIGN_ALLCLIENT
	oGDSM0:oBrowse:bDelete := {|| aCols := oGDSM0:aCols, N := oGDSM0:nAt, M->XM0_CODIGO := aCols[N,FG_POSVAR("XM0_CODIGO","aHeadSM0")], iif( OA0100041_FieldOK("SM0"), oGDSM0:DelLine(), nil ) }

	oFWLayer2 := FWLayer():New()
	oFWLayer2:Init(oFolders:aDialogs[2],.F.)
	oFWLayer2:AddLine('WIN_TOPO',100,.F.)
	oWIN_TOPO2 := oFWLayer2:GetLinePanel('WIN_TOPO')

	oGDSBM:= MsNewGetDados():New(0,0,100,100,GD_INSERT+GD_UPDATE+GD_DELETE,"OA0100051_LinhaOK('SBM')",,,{'XBM_GRUPO'},,nLinhas,"OA0100041_FieldOK('SBM')",,,oWIN_TOPO2,aHeadSBM,aColsSBM )
	oGDSBM:oBrowse:bChange := { || FG_MEMVAR(oGDSBM:aHeader,oGDSBM:aCols,oGDSBM:nAt) }
	oGDSBM:oBrowse:Align   := CONTROL_ALIGN_ALLCLIENT
	oGDSBM:oBrowse:bDelete := {|| aCols := oGDSBM:aCols, N := oGDSBM:nAt, M->XBM_GRUPO := aCols[N,FG_POSVAR("XBM_GRUPO" ,"aHeadSBM")], iif( OA0100041_FieldOK("SBM"), oGDSBM:DelLine(), nil ) }

	oFWLayer3 := FWLayer():New()
	oFWLayer3:Init(oFolders:aDialogs[3],.F.)
	oFWLayer3:AddLine('WIN_TOPO',100,.F.)
	oWIN_TOPO3 := oFWLayer3:GetLinePanel('WIN_TOPO')

	oTagsMSMGet := MsmGet():New(,,4,/*aCRA*/,/*cLetras*/,/*cTexto*/,/*aCpoEnch*/,{000,000,100,100},/*aAlterEnch*/,/*nModelo*/,;
	/*nColMens*/,/*cMensagem*/, /*cTudoOk*/,oWIN_TOPO3,/*lF3*/,/*lMemoria*/,.F./*lColumn*/,/*caTela*/,;
	/*lNoFolder*/,/*lProperty*/,aTagsMSMGet,/*aFolder*/,/*lCreate*/,/*lNoMDIStretch*/)
	oTagsMSMGet:oBox:align := CONTROL_ALIGN_ALLCLIENT

	oFWLayer4 := FWLayer():New()
	oFWLayer4:Init(oFolders:aDialogs[4],.F.)
	oFWLayer4:AddLine('WIN_TOPO',100,.F.)
	oWIN_TOPO3 := oFWLayer4:GetLinePanel('WIN_TOPO')

	oConfMSMGet := MsmGet():New(,,4,/*aCRA*/,/*cLetras*/,/*cTexto*/,/*aCpoEnch*/,{000,000,100,100},/*aAlterEnch*/,/*nModelo*/,;
	/*nColMens*/,/*cMensagem*/, /*cTudoOk*/,oWIN_TOPO3,/*lF3*/,/*lMemoria*/,/*lColumn*/,/*caTela*/,;
	/*lNoFolder*/,/*lProperty*/,aConfMSMGet,/*aFolder*/,/*lCreate*/,/*lNoMDIStretch*/,/*cTela*/)
	oConfMSMGet:oBox:align := CONTROL_ALIGN_ALLCLIENT

	if empty(M->TMP_TIK012)
		M->TMP_TIK012 := '0'
	endif

	if empty(M->TMP_TIK013)
		M->TMP_TIK013 := '0'
	endif

	if lVPJCodigo
		oFWLayer5 := FWLayer():New()
		oFWLayer5:Init(oFolders:aDialogs[5],.F.)
		oFWLayer5:AddLine('WIN_TOPO',100,.F.)
		oWIN_TOPO5 := oFWLayer5:GetLinePanel('WIN_TOPO')

		oGDVS0 := MsNewGetDados():New(0,0,100,100,GD_INSERT+GD_UPDATE+GD_DELETE,"OA0100051_LinhaOK('VS0')",,,{'VS0_XTIPAS','VS0_XCODMO'},,nLinhas,"OA0100041_FieldOK('VS0')",,,oWIN_TOPO5,aHeadVS0,aColsVS0)
		oGDVS0:oBrowse:bChange := {|| FG_MEMVAR(oGDVS0:aHeader, oGDVS0:aCols, oGDVS0:nAt), OA010003F_FixCols(oGDVS0) }
		oGDVS0:oBrowse:Align   := CONTROL_ALIGN_ALLCLIENT
		oGDVS0:oBrowse:bDelete := {|| aCols := oGDVS0:aCols, N := oGDVS0:nAt, M->VS0_XTIPAS := aCols[N,FG_POSVAR("VS0_XTIPAS","aHeadVS0")], iif( OA0100041_FieldOK("VS0"), oGDVS0:DelLine(), nil ) }

		If M->TMP_TIK008 == "1"
    		oGDVS0:Enable()
		Else
		    oGDVS0:Disable()
		EndIf
	endif

	ACTIVATE MSDIALOG oOFIA010 ON INIT EnchoiceBar(oOFIA010,{ || IIf(OA0100061_TudoOK(),oOFIA010:End(),.t.) }, { || oOFIA010:End() },,)

	restArea( aArea )
return .T.


/*/{Protheus.doc} OA0100011_aHeader
	Inicializacao dos aHeaders na tela

	@author Andre Luis Almeida
	@since  13/08/2018

	Estrutura do aHeader:
		{ || TRIM(X3Titulo()) }	// 01 - Titulo
		{ || SX3->X3_CAMPO }	// 02 - Campo
		{ || SX3->X3_PICTURE }	// 03 - Picture
		{ || SX3->X3_TAMANHO } // 04 - Tamanho
		{ || SX3->X3_DECIMAL } // 05 - Decimal
		{ || SX3->X3_VALID }   // 06 - Valid
		{ || SX3->X3_USADO }   // 07 - Usado
		{ || SX3->X3_TIPO }    // 08 - Tipo
		{ || SX3->X3_F3 }      // 09 - F3
		{ || SX3->X3_CONTEXT } // 10 - Contexto (V=Virtual, R=Real)
		{ || X3CBOX() }        // 11 - Box de seleção (para campos do tipo combo)
		{ || SX3->X3_RELACAO } // 12 - Inicializador padrão.
/*/
static Function OA0100011_aHeader(cAlias)
Local aRet    := {}

	Do Case
		Case cAlias == "SM0"
			aAdd(aRet,{ STR0006, "XM0_CODIGO"  , "@!" , FWSizeFilial()        , 0 , "" , "" , "C" , "SM0"    , ""  , "" , "" } ) // Código Filial
			aAdd(aRet,{ STR0007, "XM0_WAREID"  , "@!" , 3                     , 0 , "" , "" , "C" , ""       , ""  , "" , "" } ) // Warehouse ID

		Case cAlias == "SBM"
			aAdd(aRet,{ STR0008, "XBM_GRUPO"   , "@!" , TamSX3("BM_GRUPO")[1] , 0 , "" , "" , "C" , "SBM"    , ""  , "" , "" } ) // Código Grupo
			aAdd(aRet,{ STR0009, "XBM_DESC"    , "@!" , TamSX3("BM_DESC")[1]  , 0 , "" , "" , "C" , ""       , "V" , "" , "" } ) // Descricao

		Case cAlias == "VS0"
			aAdd(aRet,{ STR0056, "VS0_XTIPAS","@!", TamSX3("VS0_TIPASS")[1] , 0 , "" , "" , "C" ,'OA010010_consultaCustomizada()', ""  , "" , "000004" } ) // Tipo do assunto (F3=VM)
			aAdd(aRet,{ STR0057, "VS0_XCODMO","@!", TamSX3("VS0_CODMOT")[1] , 0 , "" , "" , "C" , "VS0"    , ""  , "" , "" } ) // Código do motivo (VS0 - verificar)
			aAdd(aRet,{ STR0058, "VS0_XDESMO","@!", TamSX3("VS0_DESMOT")[1]  , 0 , "" , "" , "C" , ""       , "V" , "" , "" } ) // Descrição do motivo

	EndCase
Return aClone(aRet)


/*/{Protheus.doc} OA0100021_Campos
	Campos a serem utilizados na Enchoice da aba Tags (aTagsMSMGet) , Configuracoes (aConfMSMGet) e  Lost Sale (aLostSaleMSM)

	@author Andre Luis Almeida
	@since  13/08/2018
/*/
static Function OA0100021_Campos(cQual)
Local aRet := {}
/* -- deixei aqui pois não encontra-se fácil esta documentação --
	""			// 01 - Titulo
	""			// 02 - Campo
	""			// 03 - Tipo
	0			// 04 - Tamanho
	0			// 05 - Decimal
	""			// 06 - Picture
	{|| .T. }	// 07 - Valid
	.F.			// 08 - Obrigat
	1			// 09 - Nivel
	""			// 10 - Inicializador Padrão
	""			// 11 - F3
	{|| }		// 12 - When
	.F.			// 13 - Visual
	.F.			// 14 - Chave
	""			// 15 - Box - Opção do combo
	0			// 16 - Folder
	.F.			// 17 - Não Alterável
	""			// 18 - PictVar
	"N"			// 19 - Gatilho
*/

	Do Case
		Case cQual == "Tags"
			Aadd(aRet,{ STR0010     ,"TMP_TIK001","C",  	    	      1,  0,"@!",&('{ || OA0100041_FieldOK("DMS") }'),.T.,  1,"" ,"","",.F.,.F.,STR0035,Val(""),.F.,"","N"}) // PartForSaleIntroduction
			Aadd(aRet,{ STR0011     ,"TMP_TIK002","C",      		      1,  0,"@!",&('{ || OA0100041_FieldOK("DMS") }'),.T.,  1,"" ,"","",.F.,.F.,STR0035,Val(""),.F.,"","N"}) // PartPriceUpdate
			Aadd(aRet,{ STR0012     ,"TMP_TIK003","C",     	     		  1,  0,"@!",&('{ || OA0100041_FieldOK("DMS") }'),.T.,  1,"" ,"","",.F.,.F.,STR0035,Val(""),.F.,"","N"}) // PartReception
			Aadd(aRet,{ STR0013     ,"TMP_TIK004","C",                    1,  0,"@!",&('{ || OA0100041_FieldOK("DMS") }'),.T.,  1,"" ,"","",.F.,.F.,STR0035,Val(""),.F.,"","N"}) // PartOrder
			Aadd(aRet,{ STR0014     ,"TMP_TIK005","C",                    1,  0,"@!",&('{ || OA0100041_FieldOK("DMS") }'),.T.,  1,"" ,"","",.F.,.F.,STR0035,Val(""),.F.,"","N"}) // PartDelivery
			Aadd(aRet,{ STR0015		,"TMP_TIK006","C",                    1,  0,"@!",&('{ || OA0100041_FieldOK("DMS") }'),.T.,  1,"0","","",.T.,.F.,STR0035,Val(""),.F.,"","N"}) // PartOrderDelivery (Não implementado)
			Aadd(aRet,{ STR0016     ,"TMP_TIK007","C",                    1,  0,"@!",&('{ || OA0100041_FieldOK("DMS") }'),.T.,  1,"" ,"","",.F.,.F.,STR0035,Val(""),.F.,"","N"}) // StockAdjustment
			if lVPJCodigo
				Aadd(aRet,{ STR0017     ,"TMP_TIK008","C",                    1,  0,"@!",&('{ || OA0100041_FieldOK("DMS") }'),.T.,  1,"" ,"","",.F.,.F.,STR0035,Val(""),.F.,"","N"}) // LostSale
			endif
			Aadd(aRet,{ STR0018		,"TMP_TIK009","C",                    1,  0,"@!",&('{ || OA0100041_FieldOK("DMS") }'),.T.,  1,"0","","",.T.,.F.,STR0035,Val(""),.F.,"","N"}) // RemovePartInStock (Não implementado)
			Aadd(aRet,{ STR0019     ,"TMP_TIK010","C",                    1,  0,"@!",&('{ || OA0100041_FieldOK("DMS") }'),.T.,  1,"" ,"","",.F.,.F.,STR0035,Val(""),.F.,"","N"}) // PartCorrection
			Aadd(aRet,{ STR0020     ,"TMP_TIK011","C",                    1,  0,"@!",&('{ || OA0100041_FieldOK("DMS") }'),.T.,  1,"" ,"","",.F.,.F.,STR0035,Val(""),.F.,"","N"}) // SetStockBalance
			Aadd(aRet,{ STR0062     ,"TMP_TIK012","C",                    1,  0,"@!",&('{ || OA0100041_FieldOK("DMS") }'),.T.,  1,"" ,"","",.F.,.F.,STR0035,Val(""),.F.,"","N"}) // Envia atualização de preço?
			Aadd(aRet,{ STR0063     ,"TMP_TIK013","C",                    1,  0,"@!",&('{ || OA0100041_FieldOK("DMS") }'),.T.,  1,"" ,"","",.F.,.F.,STR0035,Val(""),.F.,"","N"}) // Envia atualização Glass

		Case cQual == "Configuracoes"
			Aadd(aRet,{ STR0021     ,"TMP_TOK001","C",                    4,  0,""  ,&('{ || OA0100041_FieldOK("DMS") }'),.T.,  1,"","",""	  	,.F.,.F.,""		,Val(""),.F.,"","N"}) // Operator ID
			Aadd(aRet,{ STR0022     ,"TMP_TOK002","C",                    4,  0,""  ,&('{ || OA0100041_FieldOK("DMS") }'),.T.,  1,"","",""	  	,.F.,.F.,""		,Val(""),.F.,"","N"}) // Owner ID
			Aadd(aRet,{ STR0024     ,"TMP_TOK003","C",                    3,  0,"@!",&('{ || OA0100041_FieldOK("DMS") }'),.T.,  1,"","SY",""  	,.F.,.F.,""		,Val(""),.F.,"","N"}) // Codigo Moeda
			Aadd(aRet,{ STR0025     ,"TMP_TOK004","C",TamSX3("BM_GRUPO")[1],  0,"@!",&('{ || OA0100041_FieldOK("DMS") }'),.T.,  1,"","SBM","" 	,.F.,.F.,""		,Val(""),.F.,"","N"}) // Grupo Principal
			Aadd(aRet,{ STR0026     ,"TMP_TOK005","C",                  100,  0,""  ,&('{ || OA0100041_FieldOK("DMS") }'),.T.,  1,"","",""	  	,.F.,.F.,""		,Val(""),.F.,"","N"}) // URL WebService
			Aadd(aRet,{ STR0027     ,"TMP_TOK006","C",                   40,  0,""  ,&('{ || OA0100041_FieldOK("DMS") }'),.T.,  1,"","",""	  	,.F.,.F.,""		,Val(""),.F.,"","N"}) // Usuário WebService
			Aadd(aRet,{ STR0028     ,"TMP_TOK007","C",                   40,  0,""  ,&('{ || OA0100041_FieldOK("DMS") }'),.T.,  1,"","",""	  	,.F.,.F.,""		,Val(""),.F.,"","N"}) // Senha WebService
			Aadd(aRet,{ STR0029     ,"TMP_AGREBL","C",                    1,  0,"@!",&('{ || OA0100041_FieldOK("DMS") }'),.T.,  1,"","",""	  	,.F.,.F.,STR0035,Val(""),.F.,"","N"}) // Agrega Qtde.Reservada/Bloqueada
			Aadd(aRet,{ STR0030     ,"TMP_AGESTR","C",                    1,  0,"@!",&('{ || OA0100041_FieldOK("DMS") }'),.T.,  1,"","",""	  	,.F.,.F.,STR0035,Val(""),.F.,"","N"}) // Agrega Qtde.Estoque em Transito
			Aadd(aRet,{ STR0032     ,"TMP_TOK008","C",                   90,  0,"@!",&('{ || OA0100041_FieldOK("DMS") }'),.T.,  1,"","DIRFIS","",.F.,.F.,""		,Val(""),.F.,"","N"}) // "Pasta no protheus_data"
			Aadd(aRet,{ STR0033     ,"TMP_TOK009","C",                   06,  0,"@!",&('{ || OA0100041_FieldOK("DMS") }'),.T.,  1,"","VEG"	 ,"",.F.,.F.,""		,Val(""),.F.,"","N"}) // "Campo Preço de Venda"
			Aadd(aRet,{ STR0034     ,"TMP_TOK010","C",                   06,  0,"@!",&('{ || OA0100041_FieldOK("DMS") }'),.T.,  1,"","VEG"	 ,"",.F.,.F.,""		,Val(""),.F.,"","N"}) // "Campo Preço Reposição"

	EndCase
Return aClone(aRet)


/*/{Protheus.doc} OA0100041_FieldOK
	Field OK das aCols

	@author Andre Luis Almeida
	@since  13/08/2018
/*/
function OA0100041_FieldOK(cAlias)
local lRet     := .T.
local nI
local cVar     := readvar()
local nPosGrp  := FG_POSVAR("XBM_GRUPO" ,"aHeadSBM")
local nPosSM0  := FG_POSVAR("XM0_CODIGO","aHeadSM0")
local nPosTipas  := FG_POSVAR("VS0_XTIPAS","aHeadVS0")
local nPosCodMo  := FG_POSVAR("VS0_XCODMO","aHeadVS0")
local cAux     := ""
local cTexto := ''			
local cSolucao := ''			
private cVS0XTIPAS := ''
Private cVS0CODMOT := ''

	If cAlias == "SBM"
		If ! empty(M->XBM_GRUPO)
			dbSelectArea("SBM")
			dbSetOrder(1)
			lRet := dbSeek( xFilial("SBM") + M->XBM_GRUPO )
			cAux := iif( lRet .and. ! empty( M->XBM_GRUPO ), SBM->BM_DESC, "" )
		EndIf
		M->XBM_DESC := &('oGD'+cAlias+':aCols[oGD'+cAlias+':nAt,FG_POSVAR("XBM_DESC","aHeadSBM")]') := cAux

		if lRet
			for nI := 1 to len( aCols )
				if nI != N .and. ! aTail( aCols[nI] )
					if aCols[nI, nPosGrp] == M->XBM_GRUPO
						lRet := .F.
						exit
					endif
				endif
			next
			if ! lRet
				FMX_Help( "EXISTGRP", STR0036, STR0037)	// "Já existe este Grupo em outra linha" # "Verifique as demais linhas"
			endif
		else
			FMX_Help( "NAOEXIST", STR0038, STR0039)	// "Grupo não encontrado" # "Verifique o código do grupo"
		endif
	endif

	if cAlias == "SM0"
		if !Empty( M->XM0_CODIGO ) 
			lRet := aScan( aAllFilSM0, {|it| alltrim(it) == M->XM0_CODIGO} ) > 0
		endif

		if lRet
			for nI := 1 to len( aCols )
				if nI != N .and. ! aTail( aCols[nI] )
					if aCols[nI, nPosSM0] == M->XM0_CODIGO
						lRet := .F.
						exit
					endif
				endif
			next
			if ! lRet
				FMX_Help( "EXISTFIL", STR0040, STR0037)	// "Já existe esta Filial em outra linha" # "Verifique as demais linhas"
			endif
		else
			FMX_Help( "NAOEXIST", STR0041, STR0042)	// "Filial não encontrada" # "Verifique o código da filial"
		endif
	endif

	if cAlias == "DMS"
		If cVar == "M->TMP_TOK003"
			lRet := ExistCpo("SX5","SY"+M->TMP_TOK003)
		Endif
		if cVar == "M->TMP_TOK008" .and. !Empty( M->TMP_TOK008 )
			If !ExistDir( Alltrim( M->TMP_TOK008 ) )
				FMX_Help( "PASTAINV", STR0045, STR0044)	// "O caminho da pasta não encontrado" # "Favor informar uma pasta existente"
				lRet := .F.
			endif
		endif

		if cVar == "M->TMP_TOK009"
			lRet := empty( M->TMP_TOK009 ) .or. (existCpo("VEG",M->TMP_TOK009) .and. VEG->VEG_GRUFOR == cGruFor)
		endif

		if cVar == "M->TMP_TOK010"
			lRet := empty( M->TMP_TOK010 ) .or. (existCpo("VEG",M->TMP_TOK010) .and. VEG->VEG_GRUFOR == cGruFor)
		endif	

		if lVPJCodigo .and. cVar == "M->TMP_TIK008"
			If M->TMP_TIK008 == "1"
    			oGDVS0:Enable()
			Else
			    oGDVS0:Disable()
			EndIf
		    oGDVS0:Refresh()
		endif			
	endif

	If lVPJCodigo .and. cAlias == "VS0"		//cMotivo tem q atualizar aqui
	    If cVar == "M->VS0_XTIPAS" 
	        cVS0XTIPAS := M->VS0_XTIPAS  // Campo sendo digitado
	        cVS0CODMOT := oGDVS0:aCols[oGDVS0:nAt, nPosCodMo]  // Do aCols
			OA010011_atualizaMotivo()
	    ElseIf cVar == "M->VS0_XCODMO"
	        cVS0XTIPAS := oGDVS0:aCols[oGDVS0:nAt, nPosTipas]  // Do aCols
	        cVS0CODMOT := M->VS0_XCODMO  // Campo sendo digitado
	    EndIf

		If empty(cVS0XTIPAS) .or. empty(cVS0CODMOT) 
			cAux := ' ' // limpando campo virtual
			M->VS0_XDESMO := &('oGD'+cAlias+':aCols[oGD'+cAlias+':nAt,FG_POSVAR("VS0_XDESMO","aHeadVS0")]') := cAux
			&('oGD'+cAlias+':Refresh()')
		endif
		
		If !empty(cVS0XTIPAS) .and. empty(cVS0CODMOT) 
			cAux := ' ' // limpando campo virtual
			M->VS0_XDESMO := &('oGD'+cAlias+':aCols[oGD'+cAlias+':nAt,FG_POSVAR("VS0_XDESMO","aHeadVS0")]') := cAux
			&('oGD'+cAlias+':Refresh()')

			lRet := FG_STRZERO("cVS0XTIPAS",6) .and. FG_Seek("SX5","'VM'+cVS0XTIPAS",1,.f.)	
			if !lRet	
				cTexto := STR0059+' VM' //Registro nao encontrado na tabela
				cSolucao := STR0060 //Favor informar um registro existente. 
				FMX_Help( "NAOEXIST", cTexto, cSolucao + ': ' +STR0056 )//Tipo do Assunto
			endif
		endif

		if !empty(cVS0XTIPAS) .and. !empty(cVS0CODMOT) 
			lRet := ExistCpo("VS0",cVS0XTIPAS+cVS0CODMOT)
			if lRet
				cAux := alltrim(Posicione("VS0",1,xFilial("VS0")+cVS0XTIPAS+cVS0CODMOT,"VS0_DESMOT"))				
				M->VS0_XDESMO := &('oGD'+cAlias+':aCols[oGD'+cAlias+':nAt,FG_POSVAR("VS0_XDESMO","aHeadVS0")]') := cAux
				&('oGD'+cAlias+':Refresh()')
			endif
		EndIf
		
		if lRet
			for nI := 1 to len( aCols )
				if nI != N .and. ! aTail( aCols[nI] )
					if (aCols[nI, nPosTipas] == cVS0XTIPAS) .and. (aCols[nI, nPosCodMo] == cVS0CODMOT)
						lRet := .F.
						exit
					endif
				endif
			next
			if !lRet
				FMX_Help( "EXISTGRP", STR0061, STR0037)	// "Já existe este Motivo de Cancelamento em outra linha" # "Verifique as demais linhas"
			endif		
		endif
	endif
Return lRet


/*/{Protheus.doc} OA0100051_LinhaOK
	Linha OK das aCols

	@author Andre Luis Almeida
	@since  13/08/2018
/*/
Function OA0100051_LinhaOK(cAlias)
Local lRet := .t.
Return lRet


/*/{Protheus.doc} OA0100061_TudoOK
	Tudo OK da rotina

	@author Andre Luis Almeida
	@since  13/08/2018
/*/
Function OA0100061_TudoOK()
Local ni := 0
Local lRet := .t.

	For ni := 1 to len(oGDSM0:aCols)
		If !oGDSM0:aCols[ni,len(oGDSM0:aCols[ni])] 
			If Empty(oGDSM0:aCols[ni,FG_POSVAR("XM0_CODIGO","aHeadSM0")])
				FMX_Help( "OBRIG", STR0050, STR0051)	// "Filial em branco" # "Favor preencher os campos obrigatórios"
				return .F.
			EndIf
			If Empty(oGDSM0:aCols[ni,FG_POSVAR("XM0_WAREID","aHeadSM0")])
				FMX_Help( "OBRIG", STR0052, STR0051)	// "Warehouse ID em branco" # "Favor preencher os campos obrigatórios"
				return .F.
			EndIf
		EndIf
	Next
	For ni := 1 to len(oGDSBM:aCols)
		If !oGDSBM:aCols[ni,len(oGDSBM:aCols[ni])] 
			If Empty(oGDSBM:aCols[ni,FG_POSVAR("XBM_GRUPO","aHeadSBM")])
				FMX_Help( "OBRIG", STR0053, STR0051)	// "Grupo em branco" # "Favor preencher os campos obrigatórios"
				return .F.
			EndIf
		EndIf
	Next

	For ni := 1 to len(aTagsMSMGet)
		If Empty(&("M->"+aTagsMSMGet[ni,2]))
			FMX_Help( "OBRIG", aTagsMSMGet[ni,1] + STR0054, STR0051)	// "? em branco" # "Favor preencher os campos obrigatórios"
			return .F.
		EndIf
	Next
	For ni := 1 to len(aConfMSMGet)
		If Empty(&("M->"+aConfMSMGet[ni,2]))
			FMX_Help( "OBRIG", aConfMSMGet[ni,1] + STR0054, STR0051)	// "? em branco" # "Favor preencher os campos obrigatórios"
			return .F.
		EndIf
	Next	

	If lRet
		OA010009C_saveConfig()
	EndIf
Return lRet


/*/{Protheus.doc} OA010008C_getConfig
Pega a configuracao em formato de data container
@type function
@author Cristiam Rossi
@since 05/11/2025
/*/
function OA010008C_getConfig( lExterno )
local   oConfig   := JsonObject():New()
local   lVRN      := FWAliasInDic("VRN")
local   lExistCfg := .F.
local   aAux
local   nI
local   nJ
local   cJson
default lExterno  := .F.

	If lVRN
		VRN->(dbSetOrder(1))
		lExistCfg := VRN->(dbSeek(xFilial("VRN") + codVRN ))
		if lExistCfg
			oConfig:FromJson(VRN->VRN_CONFIG)
		endif
	endif

	if ! lVRN .or. ! lExistCfg
		oConfig["FILIAIS_DSM"]          := {}
		oConfig["WAREHOUSE_ID"]         := {}
		oConfig["GRUPOS"]               := {}
		oConfig["TIPOS_ASSUNTO"] 		:= {}
		oConfig["CODIGOS_MOTIVO"] 		:= {}
		oConfig["OPERATOR_ID"]          := space(4)
		oConfig["OWNER_ID"]             := space(4)
		oConfig["CODIGO_MOEDA"]         := space(3)
		oConfig["GRUPO_PRINCIPAL"]      := space( tamSX3("BM_GRUPO")[1] )
		oConfig["URL_XML"]              := space(100)
		oConfig["USER_WEBSERVICE"]      := space(40)
		oConfig["PASS_WEBSERVICE"]      := space(40)
		oConfig["TAG_TIK01"]            := space(1)
		oConfig["TAG_TIK02"]            := space(1)
		oConfig["TAG_TIK03"]            := space(1)
		oConfig["TAG_TIK04"]            := space(1)
		oConfig["TAG_TIK05"]            := space(1)
		oConfig["TAG_TIK06"]            := "0"
		oConfig["TAG_TIK07"]            := space(1)
		oConfig["TAG_TIK08"]            := "0"
		oConfig["TAG_TIK09"]            := "0"
		oConfig["TAG_TIK10"]            := space(1)
		oConfig["TAG_TIK11"]            := space(1)
		oConfig["PASTA"]                := space(90)
		oConfig["PRC_VENDA"]            := space(06)
		oConfig["PRC_REPOSICAO"]        := space(06)
		oConfig["AGREGA_QTDE_RESBLQ"]   := space(1)
		oConfig["AGREGA_QTDE_TRANSITO"] := space(1)

		if lVRN
			cJson := FGX_JSONform( oConfig:toJson(), .T., nil, .F. )
			reclock("VRN", .T.)
			VRN->VRN_FILIAL := xFilial("VRN")
			VRN->VRN_CODIGO := codVRN
			VRN->VRN_CONFIG := cJson
			VRN->(MsUnlock())
		endif
	endif

	if ! lExterno
		aAux := oConfig["FILIAIS_DSM"]
		For nI := 1 to len(aAux)
			aAdd(aColsSM0,Array(len(aHeadSM0)+1))
			aColsSM0[len(aColsSM0),1] := aAux[nI]
			aColsSM0[len(aColsSM0),2] := space(3) // WAREHOUSE_ID
			aColsSM0[len(aColsSM0),len(aHeadSM0)+1] := .F.
		Next

		aAux := oConfig["WAREHOUSE_ID"]
		For nI := 1 to len(aAux)
			aColsSM0[nI,2] := padr(aAux[nI],3)
		Next

		aAux := oConfig["GRUPOS"]
		For nI := 1 to len(aAux)
			If ! empty(aAux[nI])
				DbSelectArea("SBM")
				DbSetOrder(1)
				DbSeek(xFilial("SBM")+aAux[nI])
				aAdd(aColsSBM,Array(len(aHeadSBM)+1))
				For nJ := 1 to len(aHeadSBM)
					aColsSBM[len(aColsSBM),FG_POSVAR(aHeadSBM[nJ,2],"aHeadSBM")] := &("SBM->"+substr(aHeadSBM[nJ,2],2))
				Next
				aColsSBM[len(aColsSBM),len(aHeadSBM)+1] := .F.
			EndIf
		Next

		aAux := oConfig["TIPOS_ASSUNTO"]
		For nI := 1 to len(aAux)
		    aAdd(aColsVS0, Array(len(aHeadVS0)+1))
		    aColsVS0[len(aColsVS0), FG_POSVAR("VS0_XTIPAS","aHeadVS0")] := padr(aAux[nI], TamSX3("VS0_TIPASS")[1])
		    aColsVS0[len(aColsVS0), len(aHeadVS0)+1] := .F.
		Next

		aAux := oConfig["CODIGOS_MOTIVO"]
		For nI := 1 to len(aAux)
		    If nI <= len(aColsVS0)
		        aColsVS0[nI, FG_POSVAR("VS0_XCODMO","aHeadVS0")] := padr(aAux[nI], TamSX3("VS0_CODMOT")[1])
		    EndIf
		Next

		if len(aColsVS0) > 0
			For nI := 1 to len(aColsVS0)
			    cTipoAss := AllTrim(aColsVS0[nI, FG_POSVAR("VS0_XTIPAS","aHeadVS0")])
			    cCodMot  := AllTrim(aColsVS0[nI, FG_POSVAR("VS0_XCODMO","aHeadVS0")])
				cDescricao := AllTrim(Posicione("VS0", 1, xFilial("VS0") + cTipoAss + cCodMot, "VS0_DESMOT"))
			    aColsVS0[nI, FG_POSVAR("VS0_XDESMO","aHeadVS0")] := alltrim(padr(cDescricao, TamSX3("VS0_DESMOT")[1]))
			Next nI
		endif

		M->TMP_TOK001 := padR(oConfig["OPERATOR_ID"],4)								// OPERATOR_ID
		M->TMP_TOK002 := padR(oConfig["OWNER_ID"],4)								// OWNER_ID
		M->TMP_TOK003 := padR(oConfig["CODIGO_MOEDA"],3)							// CODIGO_MOEDA
		M->TMP_TOK004 := padR(oConfig["GRUPO_PRINCIPAL"],tamSX3("BM_GRUPO")[1])		// GRUPO_PRINCIPAL
		M->TMP_TOK005 := padR(oConfig["URL_XML"],100)								// URL_XML
		M->TMP_TOK006 := padR(oConfig["USER_WEBSERVICE"],40)						// USER_WEBSERVICE
		M->TMP_TOK007 := padR(oConfig["PASS_WEBSERVICE"],40)						// PASS_WEBSERVICE
		M->TMP_TOK008 := padR(oConfig["PASTA"],90)									// Pasta pra salvar XML
		M->TMP_TOK009 := padR(oConfig["PRC_VENDA"],06)								// Campo Prc Venda
		M->TMP_TOK010 := padR(oConfig["PRC_REPOSICAO"],06)							// Campo Prc Reposicao

		M->TMP_TIK001 := padR(oConfig["TAG_TIK01"],1)								// TAG_TIK01 - PartForSaleIntroduction
		M->TMP_TIK002 := padR(oConfig["TAG_TIK02"],1)								// TAG_TIK02 - PartPriceUpdate
		M->TMP_TIK003 := padR(oConfig["TAG_TIK03"],1)								// TAG_TIK03 - PartReception
		M->TMP_TIK004 := padR(oConfig["TAG_TIK04"],1)								// TAG_TIK04 - PartOrder
		M->TMP_TIK005 := padR(oConfig["TAG_TIK05"],1)								// TAG_TIK05 - PartDelivery
		M->TMP_TIK006 := padR(oConfig["TAG_TIK06"],1)								// TAG_TIK06 - PartOrderDelivery (nao usar)
		M->TMP_TIK007 := padR(oConfig["TAG_TIK07"],1)								// TAG_TIK07 - StockAdjustment
		if lVPJCodigo
			M->TMP_TIK008 := padR(oConfig["TAG_TIK08"],1)								// TAG_TIK08 - LostSale (nao usar)
		endif
		M->TMP_TIK009 := padR(oConfig["TAG_TIK09"],1)								// TAG_TIK09 - RemovePartInStock
		M->TMP_TIK010 := padR(oConfig["TAG_TIK10"],1)								// TAG_TIK10 - PartCorrection
		M->TMP_TIK011 := padR(oConfig["TAG_TIK11"],1)								// TAG_TIK11 - SetStockBalance
		M->TMP_TIK012 := padR(oConfig["TAG_TIK12"],1)								// TAG_TIK12 - Envia atualização de preço? 
		M->TMP_TIK013 := padR(oConfig["TAG_TIK13"],1)								// TAG_TIK13 - Envia atualização Glass
		M->TMP_AGREBL := padR(oConfig["AGREGA_QTDE_RESBLQ"],1)						// AGREGA_QTDE_RESBLQ
		M->TMP_AGESTR := padR(oConfig["AGREGA_QTDE_TRANSITO"],1)					// AGREGA_QTDE_TRANSITO

	endif
return oConfig


/*/{Protheus.doc} OA010009C_saveConfig
Salva a configuracao no lugar da atual
@type function
@author Cristiam Rossi
@since 03/02/2025
/*/
function OA010009C_saveConfig()
local oConfig := JsonObject():New()
local nI
local cJson
local nPosCOD := FG_POSVAR("XM0_CODIGO","aHeadSM0")
local nPosWID := FG_POSVAR("XM0_WAREID","aHeadSM0")
local nPosSBM := FG_POSVAR("XBM_GRUPO" ,"aHeadSBM")
local nPosVS0TIP := FG_POSVAR("VS0_XTIPAS","aHeadVS0")
local nPosVS0MOT := FG_POSVAR("VS0_XCODMO","aHeadVS0")

	oConfig["FILIAIS_DSM"]          := {}
	oConfig["WAREHOUSE_ID"]         := {}
	oConfig["GRUPOS"]               := {}
	oConfig["TIPOS_ASSUNTO"] 		:= {}
	oConfig["CODIGOS_MOTIVO"] 		:= {}
	oConfig["OPERATOR_ID"]          := M->TMP_TOK001
	oConfig["OWNER_ID"]             := M->TMP_TOK002
	oConfig["CODIGO_MOEDA"]         := M->TMP_TOK003
	oConfig["GRUPO_PRINCIPAL"]      := M->TMP_TOK004
	oConfig["URL_XML"]              := Alltrim(M->TMP_TOK005)
	oConfig["USER_WEBSERVICE"]      := Alltrim(M->TMP_TOK006)
	oConfig["PASS_WEBSERVICE"]      := Alltrim(M->TMP_TOK007)
	oConfig["PASTA"]            	:= M->TMP_TOK008
	oConfig["PRC_VENDA"]            := M->TMP_TOK009
	oConfig["PRC_REPOSICAO"]        := M->TMP_TOK010

	oConfig["TAG_TIK01"]            := M->TMP_TIK001
	oConfig["TAG_TIK02"]            := M->TMP_TIK002
	oConfig["TAG_TIK03"]            := M->TMP_TIK003
	oConfig["TAG_TIK04"]            := M->TMP_TIK004
	oConfig["TAG_TIK05"]            := M->TMP_TIK005
	oConfig["TAG_TIK06"]            := M->TMP_TIK006
	oConfig["TAG_TIK07"]            := M->TMP_TIK007
	if lVPJCodigo
		oConfig["TAG_TIK08"]            := M->TMP_TIK008
	endif
	oConfig["TAG_TIK09"]            := M->TMP_TIK009
	oConfig["TAG_TIK10"]            := M->TMP_TIK010
	oConfig["TAG_TIK11"]            := M->TMP_TIK011
	oConfig["TAG_TIK12"]            := M->TMP_TIK012
	oConfig["TAG_TIK13"]            := M->TMP_TIK013
	oConfig["AGREGA_QTDE_RESBLQ"]   := M->TMP_AGREBL
	oConfig["AGREGA_QTDE_TRANSITO"] := M->TMP_AGESTR

	for nI := 1 to len( oGDSM0:aCols )
		if ! aTail( oGDSM0:aCols[nI] )
			aAdd( oConfig["FILIAIS_DSM"] , oGDSM0:aCols[nI,nPosCOD] )
			aAdd( oConfig["WAREHOUSE_ID"], oGDSM0:aCols[nI,nPosWID] )
		endif
	next

	for nI := 1 to len( oGDSBM:aCols )
		if ! aTail( oGDSBM:aCols[nI] )
			aAdd( oConfig["GRUPOS"] , oGDSBM:aCols[nI,nPosSBM])
		endif
	next

	if lVPJCodigo
		for nI := 1 to len( oGDVS0:aCols )
    		if ! aTail( oGDVS0:aCols[nI] )
    		    aAdd( oConfig["TIPOS_ASSUNTO"] , oGDVS0:aCols[nI, nPosVS0TIP] )
    		    aAdd( oConfig["CODIGOS_MOTIVO"], oGDVS0:aCols[nI, nPosVS0MOT] )
    		endif
		next
	endif
	cJson := oConfig:toJson()

	VRN->(dbSetOrder(1))
	if VRN->(dbSeek(xFilial("VRN") + codVRN))
		reclock("VRN", .F.)
		VRN->VRN_CONFIG := FGX_JSONform( cJson, .T., nil, .F. )
		VRN->(MsUnlock())
	endif
return .T.

/*/{Protheus.doc} OA010003F_FixCols
	Ajuste de Colunas para exibição, conforme tipo

	@author Emanuel F. Bezerra
	@since  18/03/2026
*/
Static Function OA010003F_FixCols(oGD)
Local nPos := 0
Local nAt  := oGD:nAt
Local lRet := .T.

For nPos := 1 To Len(oGD:aHeader)
    If oGD:aHeader[nPos,8] == "C" .And. !Empty(oGD:aHeader[nPos,12])
        oGD:aCols[nAt,nPos] := StrZero(Val(oGD:aCols[nAt,nPos]), oGD:aHeader[nPos,4])
    EndIf
Next
OA010011_atualizaMotivo()
oGD:Refresh()

Return lRet

/*{Protheus.doc} OA010010_consultaCustomizada
	@Consulta customizada para preenchimento do campo Tipo do Assunto, buscando na tabela SX5: "VM" 

	@author Emanuel F. Bezerra
	@since  06/04/2026
*/
Function OA010010_consultaCustomizada()
    Local aArea     := GetArea()
    Local aFiltros  := {"000004", "000031"}
    Local aDados    := {}
    Local aHeadAux  := {}
    Local aColsAux  := {}
    Local cChave    := ""
    Local nX        := 0
	local nPosTipas  := FG_POSVAR("VS0_XTIPAS","aHeadVS0")
    Private oMsNew
    Private oDlgEspe
    Private lRetorn  := .F.
    Private cRetornoTelaFiltro := Space(6)

    // Consulta SX5 tabela VM filtrando pelo array
    DbSelectArea("SX5")
    DbSetOrder(1)
    DbSeek(xFilial("SX5") + "VM")
    While !Eof() .And. SX5->X5_TABELA == "VM"
        cChave := AllTrim(SX5->X5_CHAVE)
        If aScan(aFiltros, cChave) > 0
            aAdd(aDados, {cChave, AllTrim(SX5->X5_DESCRI)})
        EndIf
        DbSkip()
    End

    // Monta aHeader
    aAdd(aHeadAux, {STR0056,"XX_CHAVE",  "@!", 6,  0, ".F.", ".F.", "C", "", ""})
    aAdd(aHeadAux, {STR0009,"XX_DESCRI", "@!", 40, 0, ".F.", ".F.", "C", "", ""})

    // Monta aCols
    For nX := 1 To Len(aDados)
        aAdd(aColsAux, {aDados[nX][1], aDados[nX][2], .F.})
    Next

    // Tela
    DEFINE MSDIALOG oDlgEspe TITLE STR0056 FROM 000, 000 TO 120, 300 COLORS 0, 16777215 PIXEL

        oMsNew := MsNewGetDados():New(005, 003, 095, 294,GD_INSERT+GD_DELETE+GD_UPDATE,"AllwaysTrue()",,"",,, 999,,,,oDlgEspe, aHeadAux, aColsAux)
        oMsNew:lActive := .F.
        oMsNew:oBrowse:blDblClick := {|| cRetornoTelaFiltro := aColsAux[oMsNew:nAt][1], lRetorn := .T., oDlgEspe:End()}

    ACTIVATE MSDIALOG oDlgEspe CENTERED

    RestArea(aArea)

	if !empty(cRetornoTelaFiltro)
        oGDVS0:aCols[oGDVS0:nAt, nPosTipas] := cRetornoTelaFiltro 
	EndIf
Return lRetorn

/* {Protheus.doc} OA010011_atualizaMotivo
	@Atualiza o campo de descrição do motivo de cancelamento na grid, conforme o código do motivo

	@author Emanuel F. Bezerra
	@since  06/04/2026
*/
function OA010011_atualizaMotivo()
local lRet := .T.
local nPosTipas  := FG_POSVAR("VS0_XTIPAS","aHeadVS0")

default oGDVS0 := nil
default cMotivo := ""

if oGDVS0 != nil .and. !empty(oGDVS0:aCols[oGDVS0:nAt, nPosTipas]) 
	cMotivo := AllTrim(oGDVS0:aCols[oGDVS0:nAt, nPosTipas])
endif
return lRet
