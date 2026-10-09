#Include "loca007.ch"
#INCLUDE "loca007.ch" 
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "TOPCONN.CH"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "font.ch"
#INCLUDE "colors.ch"
#INCLUDE "inkey.ch"

/*/{Protheus.doc} LOCA007
Rotina para registro do custo extra
@type function
@version 1.0
@author Frank Zwarg Fuga
@since 02/12/2025 Frank - revitalização do fonte
/*/
Function LOCA007()
Local cPerg := "LOCP005"
Local cFiltro := ""
Local aArea := GetArea()
Local oBrowse

Private aRotina := {}
Private nDespesas 
Private cCadastro := STR0079 //"Custos Extras / Indenização"
Private cString := "FPG"
Private nSeq := 0

	if existblock("LCZC1FIL")			// PONTO DE ENTRADA PARA INCLUSAO DE FILTRO CUSTOMIZADO
		cfiltro := EXECBLOCK("LCZC1FIL",.T.,.T.)
	else
		If ! pergunte(CPERG,.T.)
			return NIL
		endif
		nDespesas := MV_PAR01 				// 1=COBRAR,2=NAO COBRAR,3=SEM CLASSIFICAR,4=TODAS
		do case
		case nDespesas == 1  				// 1=COBRAR,2=NAO COBRAR,3=SEM CLASSIFICAR,4=TODAS
			cFiltro := "FPG_COBRA='S'"
		case nDespesas == 2  				// 1=COBRAR,2=NAO COBRAR,3=SEM CLASSIFICAR,4=TODAS
			cFiltro := "FPG_COBRA='N'"
		case nDespesas == 3  				// 1=COBRAR,2=NAO COBRAR,3=SEM CLASSIFICAR,4=TODAS
			cFiltro := "FPG_COBRA=' '"
		endcase
	EndIf
	
	// Ponto de entrada para filtrar o browse
	// Frank Zwarg Fuga - 16/06/2021
	IF ExistBlock("LC007FIL")
		cFiltro += ExecBlock("LC007FIL" , .T. , .T. , {cFiltro}) 
	ENDIF

	dbSelectArea(cString) 
	dbSetOrder(1) 

	aRotina := MenuDef()  
	oBrowse := FWMBrowse():New()
	oBrowse:SetAlias('FPG')
	oBrowse:SetDescription(STR0080) //"Cadastro de Custo Extra"

	If FPG->(FIELDPOS("FPG_APROV")) == 0
		oBrowse:AddLegend("!EMPTY(FPG_PVNUM) .AND. FPG_STATUS == '2' .AND. FPG_COBRA == 'S'", 'BR_PINK')  
		oBrowse:AddLegend("EMPTY(FPG_PVNUM) .AND. FPG_STATUS == '1' .AND. FPG_COBRA == 'S'", 'BR_VERDE')  
		oBrowse:AddLegend("EMPTY(FPG_PVNUM) .AND. FPG_STATUS == '1' .AND. FPG_COBRA == 'N'", 'BR_AZUL')  
		oBrowse:AddLegend("EMPTY(FPG_PVNUM) .AND. FPG_STATUS == '1' .AND. !FPG_COBRA $ 'SNPR'", 'BR_VERMELHO')  
		oBrowse:AddLegend("EMPTY(FPG_PVNUM) .AND. FPG_STATUS == '1' .AND. FPG_COBRA == 'P'", 'BR_AMARELO')  
		oBrowse:AddLegend("EMPTY(FPG_PVNUM) .AND. FPG_STATUS == '1' .AND. FPG_COBRA == 'R'", 'BR_CINZA')  
	Else
		oBrowse:AddLegend("!EMPTY(FPG_PVNUM) .AND. FPG_STATUS == '2' .AND. FPG_COBRA == 'S'", 'BR_PINK')  
		oBrowse:AddLegend("EMPTY(FPG_PVNUM) .AND. FPG_STATUS == '1' .AND. FPG_COBRA == 'S'", 'BR_VERDE')  
		oBrowse:AddLegend("EMPTY(FPG_PVNUM) .AND. FPG_STATUS == '1' .AND. FPG_COBRA == 'N'", 'BR_AZUL')  
		oBrowse:AddLegend("EMPTY(FPG_PVNUM) .AND. FPG_STATUS == '1' .AND. !FPG_COBRA $ 'SNPR'", 'BR_VERMELHO')  
		oBrowse:AddLegend("EMPTY(FPG_PVNUM) .AND. FPG_STATUS == '1' .AND. FPG_COBRA == 'P'", 'BR_AMARELO')  
		oBrowse:AddLegend("EMPTY(FPG_PVNUM) .AND. FPG_STATUS == '1' .AND. FPG_COBRA == 'R'", 'BR_CINZA')  
	EndIF

	oBrowse:SetSeeAll(.T.) 
	oBrowse:SetChgAll(.F.)

	if !Empty(cFiltro)
		oBrowse:SetFilterDefault( cFiltro )
	endif

	oBrowse:DisableDetails()

	oBrowse:Activate()

    RestArea(aArea)

Return NIL

/*/{Protheus.doc} MenuDef
Declaração do menu
@type function
@version 1.0
@author Frank Zwarg Fuga
@since 02/12/2025
/*/
Static Function MenuDef()
Local aRotina := {}

	ADD OPTION aRotina TITLE STR0003 ACTION 'VIEWDEF.LOCA007' OPERATION 2 ACCESS 0 // 'Visualizar'
	ADD OPTION aRotina TITLE STR0005 ACTION 'VIEWDEF.LOCA007' OPERATION 3 ACCESS 0 //'Incluir'
	ADD OPTION aRotina TITLE STR0006 ACTION 'VIEWDEF.LOCA007' OPERATION 4 ACCESS 0 //'Alterar'
	ADD OPTION aRotina TITLE STR0007 ACTION 'VIEWDEF.LOCA007' OPERATION 5 ACCESS 0 //'Excluir'
	ADD OPTION aRotina TITLE STR0011 ACTION 'LOCA00701()' OPERATION 6 ACCESS 0 //'Legenda'
	ADD OPTION aRotina TITLE STR0004 ACTION 'LOCA00715()' OPERATION 4 ACCESS 0 //'Copiar'
	ADD OPTION aRotina TITLE STR0008 ACTION 'LOCA00702()' OPERATION 4 ACCESS 0 //'Manut.Custos'
	ADD OPTION aRotina TITLE STR0009 ACTION 'LOCA00707()' OPERATION 4 ACCESS 0 //'Vincula AS'
	ADD OPTION aRotina TITLE STR0010 ACTION 'LOCA00711()' OPERATION 4 ACCESS 0 //'Desvincula AS'
	ADD OPTION aRotina TITLE STR0081 ACTION 'LC007DOC()' OPERATION 4 ACCESS 0 //'Conhecimento'

	If ExistBlock("LCZC1ROT")
		aRotina := ExecBlock("LCZC1ROT",.T.,.T.,{AROTINA})
	ENDIF

Return aRotina

/*/{Protheus.doc} ModelDef
Declaração do modelo do MVC
@type function
@version 1.0
@author Frank Zwarg Fuga
@since 02/12/2025
/*/
Static Function ModelDef()
Local oModel	:= nil
Local oStruFPG 	:= FWFormStruct( 1, "FPG" )
Local bTudoOk  := {|| .T.}
Local bCommit  := {|oModel| LOC007GRV(oModel)}

	If ExistBlock("LCZC1TOK")
		bTudoOk := EXECBLOCK("LCZC1TOK",.T.,.T.,{ oModel })
	EndIf

	oModel := MPFormModel():New("LOCA007", , bTudoOk , bCommit, )
	oModel:SetVldActivate({ |oModel| LOC007PRE(oModel)})

	oModel:AddFields( "FPGMASTER", /*cOwner*/, oStruFPG)

	oModel:SetDescription( STR0001 ) //"Custo Extra"
	oModel:GetModel( "FPGMASTER"):SetDescription( STR0001) //"Custo Extra"

Return oModel

/*/{Protheus.doc} ViewDef
Declaração da visualização do modelo MVC
@type function
@version 1.0
@author Frank Zwarg Fuga
@since 02/12/2025
/*/
Static Function ViewDef()
Local oView		:= nil
Local oModel   	:= FWLoadModel("LOCA007")
Local oStruZZ7 	:= FWFormStruct( 2, "FPG" )

	oView := FWFormView():New()
	oView:SetModel( oModel )

	oView:AddField( "VIEW_FPG", oStruZZ7, "FPGMASTER" )
	oView:CreateHorizontalBox("TELA",100)
	oView:EnableTitleView("VIEW_FPG", STR0001) //"Custo Extra"

	oView:SetOwnerView("VIEW_FPG","TELA")

	oView:SetCloseOnOk({||.T.})

Return oView

/*/{Protheus.doc} LOCA00701
Legenda da rotina
@type function
@version 1.0
@author Frank Zwarg Fuga
@since 02/12/2025
/*/
Function LOCA00701() 		
Private cCadastro := "Status "+STR0001 //"Custo Extra"
Private	 aCores1
Private	 aCores2

	If FPG->(FIELDPOS("FPG_APROV")) == 0
		aCores1 := 	{ { "BR_PINK", STR0012 },; //"Faturado"
        	   	      { "BR_VERDE", STR0013 },; //"Cobrar"
        		      { "BR_AZUL", STR0014 },; //"Não cobrar"
        	    	  { "BR_VERMELHO", STR0015 }} //"Falta classificar"
	Else
		aCores1 := 	{ { "BR_PINK", STR0012 },; //"Faturado"
        	   	      { "BR_VERDE", STR0013 },; //"Cobrar"
        		      { "BR_AZUL", STR0014 },; //"Não cobrar"
        	    	  { "BR_VERMELHO", STR0015 },; //"Falta classificar"
					  { "BR_AMARELO", STR0097 },; //"Liberação Pendente"
					  { "BR_CINZA", STR0098 }  } //"Liberação Reprovada"
	EndIF

	If FPG->(FIELDPOS("FPG_APROV")) == 0
		aCores2 := 	{ { "BR_VERDE", STR0013 },; //"Cobrar"
        		      { "BR_AZUL", STR0014 },; //"Não cobrar"
        		      { "BR_VERMELHO", STR0015 }} //"Falta classificar"
	Else
		aCores2 := 	{ { "BR_VERDE", STR0013 },; //"Cobrar"
        		      { "BR_AZUL", STR0014 },; //"Não cobrar"
        		      { "BR_VERMELHO", STR0015 },; //"Falta classificar"
					  { "BR_AMARELO", STR0097 },; //"Liberação Pendente"
					  { "BR_CINZA", STR0098 }  } //"Liberação Reprovada"

	EndIf


	BrwLegenda( cCadastro, STR0011, aCores1 ) //"Legenda"
	
Return 

/*/{Protheus.doc} LOCA00715
Rotina para copiar o registro
@type function
@version 1.0
@author Frank Zwarg Fuga
@since 02/12/2025
/*/
Function LOCA00715()
Local aNovo := {}

	If !MsgYesNo(STR0070,STR0066) //"Confirma a cópia do registro?"###"Atenção!"
		Return
	EndIF

	AADD( aNovo, {"FPG_FILIAL", XFILIAL("FPG")} )
	AADD( aNovo, {"FPG_PROJET", FPG->FPG_PROJET} )
	AADD( aNovo, {"FPG_OBRA", FPG->FPG_OBRA} )
	AADD( aNovo, {"FPG_TIPO", FPG->FPG_TIPO} )
	AADD( aNovo, {"FPG_CUSTO", FPG->FPG_CUSTO} )
	AADD( aNovo, {"FPG_CODDES", FPG->FPG_CODDES} )
	AADD( aNovo, {"FPG_DESPES", FPG->FPG_DESPES} )
	AADD( aNovo, {"FPG_PRODUT", FPG->FPG_PRODUT} )
	AADD( aNovo, {"FPG_DESCRI", FPG->FPG_DESCRI} )
	AADD( aNovo, {"FPG_QUANT", FPG->FPG_QUANT} )
	AADD( aNovo, {"FPG_VLUNIT", FPG->FPG_VLUNIT} )
	AADD( aNovo, {"FPG_VALTOT", FPG->FPG_VALTOT} )
	AADD( aNovo, {"FPG_NRAS", FPG->FPG_NRAS} )
	AADD( aNovo, {"FPG_PVNUM", ""} )
	AADD( aNovo, {"FPG_PVITEM", ""} )
	AADD( aNovo, {"FPG_COBRA", ""} )
	AADD( aNovo, {"FPG_JUNTO", ""} )
	AADD( aNovo, {"FPG_DTENT", DDATABASE} )
	AADD( aNovo, {"FPG_STATUS", "1"} )
	// ISSUE: DSERLOCA-11425 - Nao copiar campos de aprovacao do pedido origem - DENNIS CALABREZ - 23/03/2026
	AADD( aNovo, {"FPG_APROV" , ""} )
	AADD( aNovo, {"FPG_DTAP"  , ctod("")} )
	AADD( aNovo, {"FPG_HAP"   , ""} )
	AADD( aNovo, {"FPG_NAP"   , ""} )
	AADD( aNovo, {"FPG_OBSCUS", ""} )
	_cSeq := GetSx8Num("FPG","FPG_SEQ")
	ConfirmSx8()
	AADD( aNovo, {"FPG_SEQ"  , _cSeq} )
		
	IF EXISTBLOCK("ZC1NOCOP") // --> PONTO DE ENTRADA PARA ALTERAÇÃO DOS CAMPOS QUE NÃO SERÃO COPIADOS.
		aNovo := EXECBLOCK("ZC1NOCOP",.T.,.T.,{aNovo})
	ENDIF

	// REPLICA A LINHA POSICIONADA
	LOCA065("FPG" , aNovo) 

Return NIL

/*/{Protheus.doc} LOC007GRV
Gravação do formulário
@type function
@version 1.0
@author Frank Zwarg Fuga
@since 02/12/2025
/*/
Static Function LOC007GRV(oModel)
Local nOperacao	:= oModel:GetOperation()
Local oMaster   := oModel:GetModel('FPGMASTER')
Local lOk		:= .T.
Local _cSeq

	If nOperacao = MODEL_OPERATION_INSERT
 	   If empty(oMaster:GetValue("FPG_SEQ"))
		    _cSeq := GetSx8Num("FPG","FPG_SEQ")
		    ConfirmSx8()
		    oMaster:LoadValue("FPG_SEQ", _cSeq)
 	   EndIf
	endif

	//Gravação do Modelo de Dados.
	FWFormCommit( oModel )

	if existblock("LOCA007D")
		nRet := 1 // Confirmou
		execblock("LOCA007D" , .T. , .T. , {nRet  , nOperacao }) 
	EndIf

Return lOk

/*/{Protheus.doc} LOC007PRE
Manutenção dos custos
@type function
@version 1.0
@author Frank Zwarg Fuga
@since 12/1/2025
/*/
Function LOC007PRE(oModel)
Local nOperacao	:= oModel:GetOperation()
Local lOk := .T.
Local CQUERY := ""
Local lMvLocBac := SuperGetMv("MV_LOCBAC",.F.,.F.) //Integração com Módulo de Locações SIGALOC
Local lLC0718VLD := ExistBlock("LC0718VL") // Ponto de entrada para entrar alteração
Local aButtons := {}
Local nX
Local cprojet := FPG->FPG_PROJET

	If nOperacao = MODEL_OPERATION_VIEW
		If ExistBlock("LOCA007C")
			aButtons := ExecBlock("LOCA007C" , .T. , .T. , {aButtons}) 
		EndIf
	ElseIf nOperacao = MODEL_OPERATION_INSERT
		If ExistBlock("LOCA007A")
			aButtons := ExecBlock("LOCA007A" , .T. , .T. , {aButtons}) 
		EndIf
	ElseIf nOperacao = MODEL_OPERATION_UPDATE
		If ExistBlock("LOCA007B")
			aButtons := execblock("LOCA007B" , .T. , .T. , {aButtons}) 
		EndIf
	ElseIf nOperacao = MODEL_OPERATION_DELETE
	EndIf

	For nX := 1 to Len(aButtons)
		oView:addUserButton(aButtons[nX, 3], aButtons[nX, 1], aButtons[nX, 2 ], aButtons[nX, 4])
	Next

	if nOperacao = MODEL_OPERATION_UPDATE
	
 		IF !Empty(FPG->FPG_PVNUM)
			Help(	Nil,Nil,"LOCA007_02",Nil,STR0073,1,0,Nil,Nil,Nil,Nil,Nil,{STR0072}) //"Exclua o pedido de venda para alterar o Custo Extra" //"O Custo Extra tem pedido gerado e não poderá ser alterado."
			lOk := .F.
		Else
			If lLC0718VLD // Ponto de Entrada antes da Alteração
				If !ExecBlock("LC0718VL", .F., .F.)
					lOk := .F.
				EndIf
			EndIf     
		EndIf

	EndIf  

	if nOperacao = MODEL_OPERATION_DELETE
		IF FPG->FPG_STATUS == "2"
			If !lMvLocBac
				cQuery := " SELECT C6_XAS , C6_PRODUTO , C6_VALOR , C6_TES "
			Else
				cQuery := " SELECT FPZ_AS , C6_PRODUTO , C6_VALOR , C6_TES "
			EndIF
			cQuery += " FROM " + RETSQLNAME("SC6") + " SC6 "
			If lMvLocBac
				cQuery += "JOIN " + RETSQLNAME("SC5") + " SC5 ON "
				cQuery += "C5_FILIAL = '"+xFilial("SC5")+"' AND  "
				cQuery += "C5_NUM = C6_NUM AND " 
				cQuery += "SC5.D_E_L_E_T_ = ' ' "
				cQuery += "JOIN " + RETSQLNAME("FPZ") + " FPZ ON "
				cQuery += "FPZ_FILIAL = '"+xFilial("FPZ")+"' AND  "
				cQuery += "FPZ_PEDVEN = C6_NUM AND "
				cQuery += "FPZ_PROJET = '"
				&('cQuery +=CPROJET')
				cQuery +="' AND "
				cQuery += "FPZ_ITEM = C6_ITEM AND "
				cQuery += "FPZ_EXTRA = 'S' AND "
				cQuery += "FPZ_AS = '"
				&('cQuery +=FPG->FPG_NRAS')
				cQuery +="' AND "
				cQuery += "FPZ.D_E_L_E_T_ = ' ' "	
				cQuery += " JOIN "+RETSQLNAME("FPY")+ " FPY ON "
				cQuery += " FPY_FILIAL = '"+xFilial("SC5")+"' AND " 
				cQuery += " FPY_PEDVEN = C5_NUM AND " 
				cQuery += " FPY_STATUS <> '2' AND "
				cQuery += " FPY_PROJET = '"
				&('cQuery +=CPROJET')
				cQuery +="' AND "
				cQuery += " FPY.D_E_L_E_T_ = ' ' "
			EndIF

			cQuery += " WHERE  C6_FILIAL  = '" + XFILIAL("SC6") + "' "
			cQuery += " AND C6_NUM = '" 
			&('cQuery += FPG->FPG_PVNUM') 
			cQuery += "' "
			cQuery += " AND C6_PRODUTO = '" 
			&('cQuery += FPG->FPG_PRODUT') 
			cQuery += "' "
			If !lMvLocBac
				cQuery += " AND  C6_XEXTRA = 'S' "
				cQuery += " AND  C6_XAS = '" 
				&('cQuery += FPG->FPG_NRAS')
				cQuery += "' "
			EndIF
			cQuery += " AND SC6.D_E_L_E_T_ = ' ' "
			cQuery := changequery(cQuery) 

			IF SELECT("TRBSC6") > 0
				TRBSC6->(DBCLOSEAREA())
			ENDIF
			TCQUERY CQUERY NEW ALIAS "TRBSC6"
		
			IF TRBSC6->(!EOF())
				Help(	Nil,Nil,"LOCA007_02",Nil,STR0073,1,0,Nil,Nil,Nil,Nil,Nil,{STR0072 + "  " + STR0099+FPG->FPG_PVNUM}) //"O CUSTO EXTRA NÃO PODE SER EXCLUÍDO, POIS JÁ FOI FATURADO!" //"O Custo Extra tem pedido gerado e não poderá ser alterado." //"Pedido de Venda referente a esse Custo Extra = "
				lOk := .F.
			ENDIF
		
			TRBSC6->(DBCLOSEAREA())
		
		elseif !Empty(FPG->FPG_PVNUM)
			Help(	Nil,Nil,"LOCA007_03",Nil,STR0074,1,0,Nil,Nil,Nil,Nil,Nil,{STR0075}) //"O Custo Extra tem pedido gerado e não poderá ser excluido" //"Exclua o pedido de venda para excluir o Custo Extra"
			lOk := .F.
		ENDIF
	EndIf

Return lOk

/*/{Protheus.doc} LOCA00702
Manutenção dos custos
@type function
@version  1.0 
@author Frank Zwarg Fuga
@since 12/2/2025
/*/
Function LOCA00702()
Local ODLG , OBROWSE , ACOLS0 , AHEADER , BHEADER , AESTRU 
Local ACOLS := {}
Local BMARK := { |OBROWSE| IIF(LOCA00704(OBROWSE), 'LBOK', 'LBNO') }
Local BLDBLCLICK := { |OBROWSE| LOCA00703(OBROWSE) }
Local BHEADERCLI := { |OBROWSE| LOCA00705(OBROWSE) }
Local ACLIENTE := FTRAZCLI(FPG->FPG_PROJET)
Local CNOMANT := ACLIENTE[3] 		// 1=A1_COD,2=A1_LOJA,3=A1_NOME
Local NLINDLG := 600-100
Local NCOLDLG := 800
Local NLINPAN := 230-50
Local NCOLPAN := 390
Local NLINBOT := 280-50
Local NPOS := 0 
Local bCancel := {|| oDlg:End()}
Local bUpdate := {||	Iif( FGRAVA(OBROWSE),oDlg:End() ,oDlg:End()) }

Private CPROJETX   := FPG->FPG_PROJET
Private CMARCA     := GETMARK()
Private CMARCA2    := GETMARK()
Private NPOSMAR,NPOSMAR2,NPOSTIP,NPOSCOB,NPOSCOB2,NPOSCUS,NPOSDOC,NPOSNRA,NPOSCOD,NPOSDES,NPOSQUA,NPOSVAL,NPOSDAT,NPOSREC,NPOSREO,NPOSCDE,NPOSDDE,NPOSTXV,NPOSTXP,NPOSVAT

	oFont1     := TFont():New( "MS Sans Serif",0,18,,.T.,0,,700,.F.,.F.,,,,,, )

	FMONTAZC1("QRYFPG" , CPROJETX) 			// MONTA A QUERY

	WHILE QRYFPG->(!EOF())
		AESTRU := {} 
		IF QRYFPG->FPG_COBRA $ "SN" 	// COBRAR CLIENTE (S/N)
			QRYFPG->(AADD(AESTRU,{CMARCA    ,""          ,""          ,"" ,""             ,0,00,0,"","",""}))
		ELSE
			QRYFPG->(AADD(AESTRU,{SPACE(01) ,""          ,""          ,"" ,""             ,0,00,0,"","",""}))
		ENDIF

		NPOSMAR := LEN(AESTRU)

		QRYFPG->(AADD(AESTRU,{FPG_COBRA ,"FPG_COBRA" ,STR0016,"C","@X",1,LEN(FPG->FPG_COBRA ),,,,}));NPOSCOB:=LEN(AESTRU) //"COBRAR?"
		QRYFPG->(AADD(AESTRU,{FPG_JUNTO ,"FPG_JUNTO" ,STR0017,"C","@X",1,LEN(FPG->FPG_JUNTO ),,,,}));NPOSCOB2:=LEN(AESTRU) //"JUNTO?"
		QRYFPG->(AADD(AESTRU,{FPG_NRAS  ,"FPG_NRAS"  ,STR0018,"C","@X",1,LEN(FPG->FPG_NRAS  ),0,,,"","",""}));NPOSNRA:=LEN(AESTRU) //"NRO.AS"
		QRYFPG->(AADD(AESTRU,{FPG_DESCRI,"FPG_DESCRI",STR0019,"C","@X",1,LEN(FPG->FPG_DESCRI),0,,,"","",""}));NPOSDES:=LEN(AESTRU) //"DESCRICAO"
		QRYFPG->(AADD(AESTRU,{FPG_QUANT ,"FPG_QUANT" ,STR0020,"C","@E 999,999,999.99",2,12,0,"","",""}));NPOSQUA:=LEN(AESTRU) //"QUANTIDADE"
		QRYFPG->(AADD(AESTRU,{FPG_VALOR ,"FPG_VALOR" ,STR0021,"C","@E 999,999,999.99",2,12,0,"","",""}));NPOSVAL:=LEN(AESTRU) //"VALOR"
		QRYFPG->(AADD(AESTRU,{FPG_CUSTO ,"FPG_CUSTO" ,STR0071,"C","@X",1,LEN(FPG->FPG_CUSTO ),0,"","",""}));NPOSCUS:=LEN(AESTRU) //"Centro Custo"
		QRYFPG->(AADD(AESTRU,{FPG_DOCORI,"FPG_DOCORI",STR0022,"C","@X",1,LEN(FPG->FPG_DOCORI),0,"","",""}));NPOSDOC:=LEN(AESTRU) //"DOC.ORIGEM"
		QRYFPG->(AADD(AESTRU,{FPG_PRODUT,"FPG_PRODUT",STR0023,"C","@X",1,LEN(FPG->FPG_PRODUT),0,"","",""}));NPOSCOD:=LEN(AESTRU) //"PRODUTO"
		QRYFPG->(AADD(AESTRU,{FPG_DTENT ,"FPG_DTENT" ,STR0024,"D","@E",1,08,0,"","",""}));NPOSDAT:=LEN(AESTRU) //"DATA"
		QRYFPG->(AADD(AESTRU,{FPG_RECNO ,"FPG_RECNO" ,STR0025,"N","@E 99999999",1,08,0,"","",""}));NPOSREC:=LEN(AESTRU) //"RECNO"
		QRYFPG->(AADD(AESTRU,{FPG_RECORI,"FPG_RECORI",STR0026,"C","@R 99999999",1,08,0,"","",""}));NPOSREO:=LEN(AESTRU) //"RECNO ORIGEM"
		QRYFPG->(AADD(AESTRU,{FPG_CODDES,"FPG_CODDES",STR0027,"C","@X",1,LEN(FPG->FPG_CODDES),0,"","",""}));NPOSCDE:=LEN(AESTRU) //"COD.DESPESA"
		QRYFPG->(AADD(AESTRU,{FPG_DESPES,"FPG_DESPES",STR0028,"C","@X",1,LEN(FPG->FPG_DESPES),0,"","",""}));NPOSDDE:=LEN(AESTRU) //"DESC.DESPESA"
		QRYFPG->(AADD(AESTRU,{FPG_TAXAV ,"FPG_TAXAV" ,STR0029,"N","@E 999,999,999.99",1,LEN(FPG->FPG_DESPES),0,"","",""}));NPOSTXV:=LEN(AESTRU) //"TAXA VALOR"
		QRYFPG->(AADD(AESTRU,{FPG_TAXAP ,"FPG_TAXAP" ,STR0030,"N","@E 99.99",1,LEN(FPG->FPG_DESPES),0,"","",""}));NPOSTXP:=LEN(AESTRU) //"TAXA PERCENT"
		QRYFPG->(AADD(AESTRU,{FPG_VALTOT,"FPG_VALTOT",STR0031,"N","@E 999,999,999.99",1,LEN(FPG->FPG_DESPES),0,"","",""}));NPOSVAT:=LEN(AESTRU) //"VALOR+TAXA"
		
		ACOLS0 := {}
		FOR NPOS := 1 TO LEN(AESTRU)
			AADD(ACOLS0,AESTRU[NPOS,1])
		NEXT NPOS 
		AADD(ACOLS,ACOLS0)

		QRYFPG->(DBSKIP())
	ENDDO 

	IF LEN(ACOLS) == 0
		MSGALERT(STR0032 , STR0033)  //"NÃO EXISTEM CUSTOS EXTRAS PARA O PROJETO SELECIONADO."###"GPO - CADZC1.PRW"
		Return NIL
	ENDIF

	AHEADER := {}
	FOR NPOS := 2 TO LEN(AESTRU)
		BHEADER:="{||ACOLS[OBROWSE:AT(),"+STRZERO(NPOS,2)+"]}"
		AADD(AHEADER,{AESTRU[NPOS,3],&BHEADER,AESTRU[NPOS,4],AESTRU[NPOS,5],AESTRU[NPOS,6],AESTRU[NPOS,7],AESTRU[NPOS,8]/*,AESTRU[NPOS,9],AESTRU[NPOS,10],"",AESTRU[NPOS,11]*/})
	NEXT NPOS 

	AOBJECTS:={}
	AADD(AOBJECTS,{100,012,.T., .T. } )	// ENCHOICE
	AADD(AOBJECTS,{100,088,.T., .T. } )	// MSGETDADOS
	
	ASIZEAUT := MSADVSIZE()
	AINFO    := {ASIZEAUT[1],ASIZEAUT[2],ASIZEAUT[3],ASIZEAUT[4],3,3}
	APOSOBJ  := MSOBJSIZE( AINFO, AOBJECTS, .T. , .F. )
	APOSGET  := MSOBJGETPOS((ASIZEAUT[3]-ASIZEAUT[1]),315,{{004,024,240,270}} )

	DEFINE MSDIALOG ODLG FROM ASIZEAUT[7],0 TO ASIZEAUT[6],ASIZEAUT[5] TITLE OEMTOANSI("MANUT.CUSTOS") OF OMAINWND PIXEL
	@ APOSOBJ[1,1],APOSOBJ[1,2] MSPANEL OPANEL1 PROMPT "" SIZE 10,40 OF ODLG
	@ APOSOBJ[2,1],APOSOBJ[2,2] MSPANEL OPANEL2 PROMPT "" SIZE 10,10 OF ODLG
	OPANEL1:ALIGN:=CONTROL_ALIGN_TOP
	OPANEL2:ALIGN:=CONTROL_ALIGN_ALLCLIENT
	
	oSay1	:= TSay():New( 010,010,{||"PROJETO : "+CPROJETX},OPANEL1,,oFont1,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,200,008) 
	oSay2	:= TSay():New( 030,010,{||"CLIENTE : "+CNOMANT},OPANEL1,,oFont1,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,200,008) 

	OBROWSE := FWBROWSE():NEW() 
	OBROWSE:SETDATAARRAY()
	OBROWSE:SETARRAY(ACOLS)
	OBROWSE:ADDMARKCOLUMNS(BMARK,BLDBLCLICK,BHEADERCLI)
	OBROWSE:SETDOUBLECLICK ({ || ATUJUNTO(OBROWSE) })
	OBROWSE:SETCOLUMNS(AHEADER)
	OBROWSE:SETOWNER(OPANEL2)
	OBROWSE:DISABLEREPORT()
	OBROWSE:DISABLECONFIG()
	OBROWSE:ACTIVATE()
	
	ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar(oDlg,bUpdate,bCancel,,) CENTERED

Return NIL

/*/{Protheus.doc} ATUJUNTO
Ação no duplo clique
@type function
@version 1.0
@author Frank Zwarg Fuga
@since 02/12/2025
/*/
Static Function ATUJUNTO(OBROWSE)
	DO CASE
		CASE EMPTY( OBROWSE:DATA():AARRAY[OBROWSE:AT(),NPOSCOB2] )
			OBROWSE:DATA():AARRAY[OBROWSE:AT(),NPOSCOB2] := "S"
		CASE OBROWSE:DATA():AARRAY[OBROWSE:AT(),NPOSCOB2] == "S"
			OBROWSE:DATA():AARRAY[OBROWSE:AT(),NPOSCOB2] := "N"
		OTHERWISE
			OBROWSE:DATA():AARRAY[OBROWSE:AT(),NPOSCOB2] := SPACE(01)
	ENDCASE
Return NIL

/*/{Protheus.doc} FMONTAZC1
Montagem da query da rotina
@type function
@version 1.0
@author Frank Zwarg Fuga
@since 02/12/2025
/*/
Static Function FMONTAZC1(CALIASQRY,CPROJET)  
Local AESTRU 
Local CQRY 
Local NPOS   := 0 
Local _cCampos := ""

	IF SELECT(CALIASQRY) > 0
		(CALIASQRY)->( DBCLOSEAREA() )
	ENDIF

	_cCampos := "FPG_PROJET,FPG_OBRA,FPG_COBRA,FPG_JUNTO,FPG_NRAS,FPG_TIPO,FPG_CUSTO,FPG_CODDES,FPG_DESPES,FPG_OK,FPG_PRODUT,"
	_cCampos += "FPG_DESCRI,FPG_QUANT,FPG_VALOR,FPG_DTENT,FPG_DOCORI,FPG_RECORI,FPG_TAXAV,FPG_TAXAP,FPG_VALTOT,FPG_FILIAL,FPG_RECNO"

	CQRY := " SELECT FPG_PROJET, FPG_OBRA, FPG_COBRA, FPG_JUNTO, FPG_NRAS, FPG_TIPO, FPG_CUSTO, " 
	CQRY += " FPG_CODDES, FPG_DESPES, FPG_OK, FPG_PRODUT, FPG_DESCRI, FPG_QUANT, FPG_VALOR, " 
	CQRY += " FPG_DTENT, FPG_DOCORI, FPG_RECORI, FPG_TAXAV, FPG_TAXAP, FPG_VALTOT, FPG_FILIAL, " 
	CQRY += " R_E_C_N_O_  FPG_RECNO " 
	CQRY += " FROM " + RETSQLNAME("FPG") + " ZC1" 
	CQRY += " WHERE FPG_FILIAL    = '" + XFILIAL("FPG") + "'" 
	CQRY += " AND FPG_PROJET    = ? " 
	CQRY += " AND FPG_PVNUM    = ' ' " 
	CQRY += " AND ZC1.D_E_L_E_T_= ' ' " 
	CQRY += " ORDER BY FPG_PROJET, FPG_TIPO, FPG_DOCORI, FPG_PRODUT " 
	CQRY := CHANGEQUERY( CQRY )
	aBindParam := {CPROJET}
	MPSysOpenQuery(CQRY,CALIASQRY,,,aBindParam)

	AESTRU := FPG->(DBSTRUCT())

	FOR NPOS := 1 TO LEN(AESTRU)
		IF AESTRU[NPOS,2] <> "C" .AND. AESTRU[NPOS,2] <> "M"
			If alltrim(AESTRU[NPOS,1]) $ _cCampos
				TCSETFIELD(CALIASQRY,AESTRU[NPOS,1],AESTRU[NPOS,2],AESTRU[NPOS,3],AESTRU[NPOS,4])
			ENDIF
		ENDIF
	NEXT

Return NIL

/*/{Protheus.doc} FGRAVA
Rotina de gravação dos custo extras
@type function
@version 1.0
@author Frank Zwarg Fuga
@since 02/12/2025
/*/
Static Function FGRAVA(OBROWSE)
Local NPOS
Local ATABAUX  := OBROWSE:DATA():AARRAY
Local AAREAZC1 := FPG->(GETAREA())

	FOR NPOS := 1 TO LEN(ATABAUX)
		FPG->(DBGOTO(ATABAUX[NPOS,NPOSREC]))  //POSICIONA NO ZC1

		If empty(FPG->FPG_SEQ)
			_cSeq := GetSx8Num("FPG","FPG_SEQ")
			ConfirmSx8()
			If FPG->(RecLock("FPG",.F.))
				FPG->FPG_SEQ := _cSeq
				FPG->(MsUnlock())
			EndIF
		EndIf

		IF ATABAUX[NPOS,NPOSMAR] == CMARCA
			IF FPG->(RECLOCK("FPG",.F.))
				FPG->FPG_COBRA := ATABAUX[NPOS,NPOSCOB]
				FPG->(MSUNLOCK())
			ENDIF
		ELSE
			IF FPG->FPG_COBRA == "N"
				IF FPG->(RECLOCK("FPG",.F.))
					FPG->FPG_COBRA:=ATABAUX[NPOS,NPOSCOB]
					FPG->(MSUNLOCK())
				ENDIF
			ELSE
				IF FPG->(RECLOCK("FPG",.F.))
					FPG->FPG_COBRA:=ATABAUX[NPOS,NPOSCOB]
					FPG->(MSUNLOCK())
				ENDIF
			ENDIF
		ENDIF

		IF FPG->(RECLOCK("FPG",.F.))
			FPG->FPG_JUNTO := ATABAUX[NPOS,NPOSCOB2] 
			FPG->(MSUNLOCK())
		ENDIF
	NEXT

	OBROWSE:REFRESH(.T.)
	OBROWSE:SETFOCUS()

	FPG->(RESTAREA(AAREAZC1))

Return .T.

/*/{Protheus.doc} LOCA00703
Validação no duplo clique da rotina
@type function
@version 1.0
@author Frank Zwarg Fuga
@since 02/12/2025
/*/
Function LOCA00703(OBROWSE)
Local LRET
Local CPROJET := CPROJETX
Local CNUMAS  := OBROWSE:DATA():AARRAY[OBROWSE:AT(),NPOSNRA]

	IF ! FVERZLFSIT(CPROJET,CNUMAS)  //VERIFICA SITUAÇÃO DA MEDIÇÃO
		Return .F.
	ENDIF

	DO CASE
		CASE EMPTY(OBROWSE:DATA():AARRAY[OBROWSE:AT(),NPOSMAR]) .AND. EMPTY(OBROWSE:DATA():AARRAY[OBROWSE:AT(),NPOSCOB])
			OBROWSE:DATA():AARRAY[OBROWSE:AT(),NPOSMAR]:=CMARCA
			OBROWSE:DATA():AARRAY[OBROWSE:AT(),NPOSCOB]:="S"
		CASE !EMPTY(OBROWSE:DATA():AARRAY[OBROWSE:AT(),NPOSMAR]) .AND. OBROWSE:DATA():AARRAY[OBROWSE:AT(),NPOSCOB]=="S"
			OBROWSE:DATA():AARRAY[OBROWSE:AT(),NPOSMAR]:=CMARCA
			OBROWSE:DATA():AARRAY[OBROWSE:AT(),NPOSCOB]:="N"
		OTHERWISE
			OBROWSE:DATA():AARRAY[OBROWSE:AT(),NPOSMAR]:=SPACE(01)
			OBROWSE:DATA():AARRAY[OBROWSE:AT(),NPOSCOB]:=SPACE(01)
	ENDCASE

	LRET := LOCA00704(OBROWSE)

Return LRET


/*/{Protheus.doc} LOCA00704
Validação no preenchimento do custo extra
@type function
@version 1.0
@author Frank Zwarg Fuga
@since 02/12/2025
/*/
Function LOCA00704(OBROWSE)
Local LRET
	LRET := (!EMPTY(OBROWSE:DATA():AARRAY[OBROWSE:AT(),NPOSMAR]))
Return LRET

/*/{Protheus.doc} LOCA00705
Refresh da tela
@type function
@version 1.0
@author Frank Zwarg Fuga
@since 02/12/2025
/*/
Function LOCA00705(OBROWSE)
Local NPOS
Local nAtOld := OBROWSE:AT()
	
	FOR NPOS:=1 TO LEN(OBROWSE:DATA():AARRAY)
		OBROWSE:Goto(NPOS)
		LOCA00703(OBROWSE)
	NEXT
	
	OBROWSE:Goto(nAtOld)
	OBROWSE:REFRESH(.T.)
	OBROWSE:SETFOCUS()
Return NIL

/*/{Protheus.doc} FTRAZCLI
Busca os dados do cliente
@type function
@version 1.0
@author Frank Zwarg Fuga
@since 02/12/2025
/*/
Static Function FTRAZCLI(CPROJET)  
Local AAREA := GETAREA()
Local CCLI  := ""
Local CLOJ  := ""
Local CNOM  := ""

	FP0->( DBSETORDER(1) )
	IF FP0->( DBSEEK( XFILIAL("FP0") + CPROJET ) )
		CCLI := FP0->FP0_CLI
		CLOJ := FP0->FP0_LOJA
		CNOM := FP0->FP0_CLINOM
	ENDIF

	RESTAREA( AAREA )

Return { CCLI, CLOJ, CNOM }

/*/{Protheus.doc} LOCA00707
Rotina para o vínculo da AS
@type function
@version 1.0
@author Frank Zwarg Fuga
@since 02/12/2025
/*/
Function LOCA00707()
Local ODLG,OBROWSE,ACOLS,ACOLS0,AHEADER,BHEADER,AESTRU
Local BMARK      := { || IF(LOCA00709(OBROWSE),'LBOK','LBNO') }
Local BLDBLCLICK := { |OBROWSE| LOCA00708(OBROWSE) }
Local BHEADERCLI := { |OBROWSE| LOCA00710(OBROWSE) }
Local ACLIENTE,CNOMANT
Local NLINDLG  := 600-100
Local NCOLDLG  := 800
Local NLINPAN  := 230-50
Local NCOLPAN  := 390
Local NLINBOT  := 280-50
Local NPOS     := 0 
Local bCancel	:= {|| oDlg:End()}
Local bUpdate	:= {||	Iif( FVINCULA(OBROWSE),oDlg:End() ,oDlg:End()) }

Private CPROJETX := FPG->FPG_PROJET
Private CNRAS    := FPG->FPG_NRAS
Private CMARCA   := GETMARK()
Private NPOSMAR,NPOSTIP,NPOSCOB,NPOSCUS,NPOSDOC,NPOSNRA,NPOSCOD,NPOSDES,NPOSQUA,NPOSVAL,NPOSDAT,NPOSREC,NPOSREO,NPOSCDE,NPOSDDE
	
	oFont1     := TFont():New( "MS Sans Serif",0,18,,.T.,0,,700,.F.,.F.,,,,,, )

	M->FPG_PROJET := ""
	M->FPG_OBRA   := ""

	ACLIENTE := FTRAZCLI(CPROJETX) 		// TRAZ O CLIENTE DO PROJETO INFORMADO
	CNOMANT  := ACLIENTE[3] 			// 1=A1_COD,2=A1_LOJA,3=A1_NOME

	FMONTAZC1("QRYFPG",CPROJETX) 		// MONTA A QUERY

	ACOLS := {} 

	QRYFPG->(DBGOTOP())
	WHILE QRYFPG->(!EOF())

		AESTRU := {} 
		QRYFPG->(AADD(AESTRU,{SPACE(01) ,""          ,""            ,"" ,""           ,0,00,0}));NPOSMAR:=LEN(AESTRU)
		QRYFPG->(AADD(AESTRU,{FPG_COBRA ,"FPG_COBRA" ,STR0016 ,"C","@X"               ,1,LEN(FPG->FPG_COBRA ),0}));NPOSCOB:=LEN(AESTRU) //"COBRAR?"
		QRYFPG->(AADD(AESTRU,{FPG_NRAS  ,"FPG_NRAS"  ,STR0018 ,"C","@X"               ,1,LEN(FPG->FPG_NRAS  ),0}));NPOSNRA:=LEN(AESTRU) //"NRO.AS"
		QRYFPG->(AADD(AESTRU,{FPG_CUSTO ,"FPG_CUSTO" ,STR0071 ,"C","@X"               ,1,LEN(FPG->FPG_CUSTO ),0}));NPOSCUS:=LEN(AESTRU) //"Centro Custo"
		QRYFPG->(AADD(AESTRU,{FPG_DOCORI,"FPG_DOCORI",STR0022 ,"C","@X"               ,1,LEN(FPG->FPG_DOCORI),0}));NPOSDOC:=LEN(AESTRU) //"DOC.ORIGEM"
		QRYFPG->(AADD(AESTRU,{FPG_PRODUT,"FPG_PRODUT",STR0023 ,"C","@X"               ,1,LEN(FPG->FPG_PRODUT),0}));NPOSCOD:=LEN(AESTRU) //"PRODUTO"
		QRYFPG->(AADD(AESTRU,{FPG_DESCRI,"FPG_DESCRI",STR0019 ,"C","@X"               ,1,LEN(FPG->FPG_DESCRI),0}));NPOSDES:=LEN(AESTRU) //"DESCRICAO"
		QRYFPG->(AADD(AESTRU,{FPG_QUANT ,"FPG_QUANT" ,STR0020 ,"C","@E 999,999,999.99",2,12,0}));NPOSQUA:=LEN(AESTRU) //"QUANTIDADE"
		QRYFPG->(AADD(AESTRU,{FPG_VALOR ,"FPG_VALOR" ,STR0021 ,"C","@E 999,999,999.99",2,12,0}));NPOSVAL:=LEN(AESTRU) //"VALOR"
		QRYFPG->(AADD(AESTRU,{FPG_DTENT ,"FPG_DTENT" ,STR0024 ,"D","@E"               ,1,08,0}));NPOSDAT:=LEN(AESTRU) //"DATA"
		QRYFPG->(AADD(AESTRU,{FPG_RECNO ,"FPG_RECNO" ,STR0025 ,"N","@E 99999999"      ,1,08,0}));NPOSREC:=LEN(AESTRU) //"RECNO"
		QRYFPG->(AADD(AESTRU,{FPG_RECORI,"FPG_RECORI",STR0026 ,"C","@R 99999999"      ,1,08,0}));NPOSREO:=LEN(AESTRU) //"RECNO ORIGEM"
		QRYFPG->(AADD(AESTRU,{FPG_CODDES,"FPG_CODDES",STR0027 ,"C","@X"               ,1,LEN(FPG->FPG_CODDES),0}));NPOSCDE:=LEN(AESTRU) //"COD.DESPESA"
		QRYFPG->(AADD(AESTRU,{FPG_DESPES,"FPG_DESPES",STR0028 ,"C","@X"               ,1,LEN(FPG->FPG_DESPES),0}));NPOSDDE:=LEN(AESTRU) //"DESC.DESPESA"

		ACOLS0 := {} 
		FOR NPOS:=1 TO LEN(AESTRU)
			AADD(ACOLS0,AESTRU[NPOS,1])
		NEXT NPOS 
		AADD(ACOLS,ACOLS0)

		QRYFPG->(DBSKIP())
	ENDDO 

	IF LEN(ACOLS) == 0
		MSGALERT(STR0032 , STR0033) //"NÃO EXISTEM CUSTOS EXTRAS PARA O PROJETO SELECIONADO."###"GPO - CADZC1.PRW"
		Return NIL
	ENDIF

	AHEADER:={}
	FOR NPOS:=2 TO LEN(AESTRU)
		BHEADER:="{||ACOLS[OBROWSE:AT(),"+STRZERO(NPOS,2)+"]}"
		AADD(AHEADER,{AESTRU[NPOS,3],&BHEADER,AESTRU[NPOS,4],AESTRU[NPOS,5],AESTRU[NPOS,6],AESTRU[NPOS,7],AESTRU[NPOS,8]})
	NEXT

	AOBJECTS:={}
	AADD(AOBJECTS,{100,012,.T., .T. } )	// ENCHOICE
	AADD(AOBJECTS,{100,088,.T., .T. } )	// MSGETDADOS
	
	ASIZEAUT := MSADVSIZE()
	AINFO    := {ASIZEAUT[1],ASIZEAUT[2],ASIZEAUT[3],ASIZEAUT[4],3,3}
	APOSOBJ  := MSOBJSIZE( AINFO, AOBJECTS, .T. , .F. )
	APOSGET  := MSOBJGETPOS((ASIZEAUT[3]-ASIZEAUT[1]),315,{{004,024,240,270}} )

	DEFINE MSDIALOG ODLG FROM ASIZEAUT[7],0 TO ASIZEAUT[6],ASIZEAUT[5] TITLE OEMTOANSI("VINCULA AS") OF OMAINWND PIXEL
	@ APOSOBJ[1,1],APOSOBJ[1,2] MSPANEL OPANEL1 PROMPT "" SIZE 10,40 OF ODLG
	@ APOSOBJ[2,1],APOSOBJ[2,2] MSPANEL OPANEL2 PROMPT "" SIZE 10,10 OF ODLG
	OPANEL1:ALIGN:=CONTROL_ALIGN_TOP
	OPANEL2:ALIGN:=CONTROL_ALIGN_ALLCLIENT
	
	oSay1	:= TSay():New( 010,010,{|| STR0094+CPROJETX},OPANEL1,,oFont1,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,200,008) //"PROJETO : "
	oSay2	:= TSay():New( 010,100,{|| STR0095+CNOMANT},OPANEL1,,oFont1,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,200,008) //"CLIENTE : "
	oSay3	:= TSay():New( 025,010,{|| STR0096},OPANEL1,,oFont1,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,200,008)  //"NRO.AS   : "

	oGet1	:= TGet():New( 024,050,{|u| If(PCount()>0,CNRAS:=u,CNRAS)	},OPANEL1,200,010,'@!', {|| ASVALIDA() }		,CLR_BLACK,CLR_WHITE ,oFont1,,,.T.,"",,,.F.,.F.,,.F.,.F.,"FPG2"	,"CNRAS",,)

	//@ 005,005 SAY  OSAYPROJ PROMPT OEMTOANSI("PROJETO" )  SIZE 050, 8 OF OPANEL1 PIXEL  
	//@ 005,040 SAY  OSAYNPROJ PROMPT OEMTOANSI(CPROJETX )  PICTURE "@!"   SIZE  50, 8 OF OPANEL1 PIXEL 

	OBROWSE := FWBROWSE():NEW() 
	OBROWSE:SETDATAARRAY()
	OBROWSE:SETARRAY(ACOLS)
	OBROWSE:ADDMARKCOLUMNS(BMARK,BLDBLCLICK,BHEADERCLI)

	OBROWSE:SETCOLUMNS(AHEADER)
	OBROWSE:SETOWNER(OPANEL2)
	OBROWSE:DISABLEREPORT()
	OBROWSE:DISABLECONFIG()
	OBROWSE:ACTIVATE()
	
	ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar(oDlg,bUpdate,bCancel,,) CENTERED

Return NIL

/*/{Protheus.doc} ASVALIDA
Validação da AS informada
@type function
@version 1.0
@author Frank Zwarg Fuga
@since 02/12/2025
/*/
Static Function ASVALIDA()

	FQ5->( DBSETORDER(9) )
	IF ! FQ5->( DBSEEK( XFILIAL("FQ5") + CNRAS, .T. ) )
		MSGALERT(STR0051 , STR0033) //"VINCULAR AS: AS NAO ENCONTRADA!"###"GPO - CADZC1.PRW"
		Return .F.
	ENDIF

Return .T.

/*/{Protheus.doc} FVINCULA
Botão vincula
@type function
@version 1.0
@author Frank Zwarg Fuga
@since 02/12/2025
/*/
Static Function FVINCULA(OBROWSE)
Local NPOS , ATABAUX
Local AAREAZC1 := FPG->(GETAREA()) 

	IF ! MSGYESNO(STR0052 , STR0033)  //"CONFIRMA O VINCULO ??"###"GPO - CADZC1.PRW"
		Return .F.
	ENDIF

	ATABAUX := OBROWSE:DATA():AARRAY

	FOR NPOS:=1 TO LEN(ATABAUX)
		IF ATABAUX[NPOS,NPOSMAR]==CMARCA
			FQ5->( DBSETORDER(9) )
			IF FQ5->( DBSEEK( XFILIAL("FQ5") + ATABAUX[NPOS,NPOSNRA], .T. ) )
				FPG->(DBGOTO(ATABAUX[NPOS,NPOSREC]))  //POSICIONA NO ZC1

				If empty(FPG->FPG_SEQ)
					_cSeq := GetSx8Num("FPG","FPG_SEQ")
					ConfirmSx8()
					If FPG->(RecLock("FPG",.F.))
						FPG->FPG_SEQ := _cSeq
						FPG->(MsUnlock())
					EndIF
				EndIf

				IF FPG->(RECLOCK("FPG",.F.))
					FPG->FPG_NRAS   := ATABAUX[NPOS,NPOSNRA]
					FPG->FPG_PROJET := FQ5->FQ5_SOT
					FPG->FPG_OBRA   := FQ5->FQ5_OBRA
					FPG->(MSUNLOCK())
				ENDIF
			ENDIF
		ENDIF
	NEXT

	OBROWSE:REFRESH(.T.) 
	OBROWSE:SETFOCUS() 

	FPG->(RESTAREA(AAREAZC1)) 

Return .T. 

/*/{Protheus.doc} LOCA00708
Vinculo da AS
@type function
@version 1.0
@author Frank Zwarg Fuga
@since 02/12/2025
/*/
Function LOCA00708(OBROWSE)
Local LRET
Local CNUMAS  := OBROWSE:DATA():AARRAY[OBROWSE:AT(),NPOSNRA]
Local CPROJET := CPROJETX

	IF ! FVERZLFSIT(CPROJET,CNUMAS)  //VERIFICA SITUAÇÃO DA MEDIÇÃO
		Return .F.
	ENDIF

	DO CASE
	CASE EMPTY(CNRAS)
		MSGALERT(STR0053 , STR0033) //"PRIMEIRO SELECIONE UMA AS PARA VINCULAR !!"##"Rental"
	CASE EMPTY(OBROWSE:DATA():AARRAY[OBROWSE:AT(),NPOSMAR]) .AND. !EMPTY(OBROWSE:DATA():AARRAY[OBROWSE:AT(),NPOSNRA])
		MSGALERT(STR0054 ,  STR0033) //"ESTA DESPESA JÁ ESTÁ COM UMA AS VINCULADA !!"###"GPO - CADZC1.PRW"
	CASE EMPTY(OBROWSE:DATA():AARRAY[OBROWSE:AT(),NPOSMAR])
		OBROWSE:DATA():AARRAY[OBROWSE:AT(),NPOSMAR]:=CMARCA
		OBROWSE:DATA():AARRAY[OBROWSE:AT(),NPOSNRA]:=CNRAS
	OTHERWISE
		OBROWSE:DATA():AARRAY[OBROWSE:AT(),NPOSMAR]:=SPACE(01)
		OBROWSE:DATA():AARRAY[OBROWSE:AT(),NPOSNRA]:=SPACE(01)
	ENDCASE

	LRET := LOCA00709(OBROWSE)

Return LRET

/*/{Protheus.doc} LOCA00709
Tratamento no vínculo da AS
@type function
@version 1.0 
@author Frank Zwarg Fuga
@since 02/12/2025
/*/
Function LOCA00709(OBROWSE)
Local LRET
	
	IF OBROWSE:AT() == 0
		Return .F.
	ENDIF
	LRET := ! EMPTY(OBROWSE:DATA():AARRAY[OBROWSE:AT(),NPOSMAR])

Return LRET

/*/{Protheus.doc} LOCA00710
Tratamento de refresh na tela
@type function
@version 1.0 
@author Frank Zwarg Fuga
@since 02/12/2025
/*/
Function LOCA00710(OBROWSE)
	OBROWSE:REFRESH(.T.)
	OBROWSE:SETFOCUS()
Return NIL

/*/{Protheus.doc} LOCA00711
Tratamento no desvinculo da AS
@type function
@version 1.0 
@author Frank Zwarg Fuga
@since 02/12/2025
/*/
Function LOCA00711()
Local ODLG,OBROWSE,ACOLS,ACOLS0,AHEADER,BHEADER,AESTRU
Local BMARK      := { || IF(LOCA00713(OBROWSE),'LBOK','LBNO') }
Local BLDBLCLICK := { |OBROWSE| LOCA00712(OBROWSE) }
Local BHEADERCLI := { |OBROWSE| LOCA00714(OBROWSE) }
Local ACLIENTE , CNOMANT
Local NLINDLG := 600-100
Local NCOLDLG := 800
Local NLINPAN := 230-50
Local NCOLPAN := 390
Local NLINBOT := 280-50
Local NPOS    := 0 
Local bCancel	:= {|| oDlg:End()}
Local bUpdate	:= {||	Iif( FDESVINC(OBROWSE),oDlg:End() ,oDlg:End()) }

Private CPROJETX:=FPG->FPG_PROJET 		// VARIÁVEL PRIVATE !!
Private CMARCA:=GETMARK()
Private NPOSMAR,NPOSTIP,NPOSCOB,NPOSCUS,NPOSDOC,NPOSNRA,NPOSCOD,NPOSDES,NPOSQUA,NPOSVAL,NPOSDAT,NPOSREC,NPOSREO,NPOSCDE,NPOSDDE

	oFont1     := TFont():New( "MS Sans Serif",0,18,,.T.,0,,700,.F.,.F.,,,,,, )

	ACLIENTE := FTRAZCLI(CPROJETX) 	// TRAZ O CLIENTE DO PROJETO INFORMADO
	CNOMANT  := ACLIENTE[3] 		// 1=A1_COD,2=A1_LOJA,3=A1_NOME

	FMONTAZC1("QRYFPG",CPROJETX) 	// MONTA A QUERY

	ACOLS := {}

	QRYFPG->(DBGOTOP())
	WHILE QRYFPG->(!EOF())
		AESTRU := {} 
		QRYFPG->(AADD(AESTRU,{SPACE(01) ,"","","","",0,00,0}));NPOSMAR:=LEN(AESTRU)
		QRYFPG->(AADD(AESTRU,{FPG_COBRA ,"FPG_COBRA" ,STR0016,"C","@X",1,LEN(FPG->FPG_COBRA ),0}));NPOSCOB:=LEN(AESTRU) //"COBRAR?"
		QRYFPG->(AADD(AESTRU,{FPG_NRAS  ,"FPG_NRAS"  ,STR0018,"C","@X",1,LEN(FPG->FPG_NRAS  ),0}));NPOSNRA:=LEN(AESTRU) //"NRO.AS"

		QRYFPG->(AADD(AESTRU,{FPG_CUSTO ,"FPG_CUSTO" ,STR0071,"C","@X",1,LEN(FPG->FPG_CUSTO ),0}));NPOSCUS:=LEN(AESTRU) //"Centro Custo"
		QRYFPG->(AADD(AESTRU,{FPG_DOCORI,"FPG_DOCORI",STR0022,"C","@X",1,LEN(FPG->FPG_DOCORI),0}));NPOSDOC:=LEN(AESTRU) //"DOC.ORIGEM"

		QRYFPG->(AADD(AESTRU,{FPG_PRODUT,"FPG_PRODUT",STR0023,"C","@X",1,LEN(FPG->FPG_PRODUT),0}));NPOSCOD:=LEN(AESTRU) //"PRODUTO"
		QRYFPG->(AADD(AESTRU,{FPG_DESCRI,"FPG_DESCRI",STR0019,"C","@X",1,LEN(FPG->FPG_DESCRI),0}));NPOSDES:=LEN(AESTRU) //"DESCRICAO"
		QRYFPG->(AADD(AESTRU,{FPG_QUANT ,"FPG_QUANT" ,STR0020,"C","@E 999,999,999.99",2,12,0}));NPOSQUA:=LEN(AESTRU) //"QUANTIDADE"
		QRYFPG->(AADD(AESTRU,{FPG_VALOR ,"FPG_VALOR" ,STR0021,"C","@E 999,999,999.99",2,12,0}));NPOSVAL:=LEN(AESTRU) //"VALOR"
		QRYFPG->(AADD(AESTRU,{FPG_DTENT ,"FPG_DTENT" ,STR0024,"D","@E",1,08,0}));NPOSDAT:=LEN(AESTRU) //"DATA"
		QRYFPG->(AADD(AESTRU,{FPG_RECNO ,"FPG_RECNO" ,STR0025,"N","@E 99999999",1,08,0}));NPOSREC:=LEN(AESTRU) //"RECNO"
		QRYFPG->(AADD(AESTRU,{FPG_RECORI,"FPG_RECORI",STR0026,"C","@R 99999999",1,08,0}));NPOSREO:=LEN(AESTRU) //"RECNO ORIGEM"
		QRYFPG->(AADD(AESTRU,{FPG_CODDES,"FPG_CODDES",STR0027,"C","@X",1,LEN(FPG->FPG_CODDES),0}));NPOSCDE:=LEN(AESTRU) //"COD.DESPESA"
		QRYFPG->(AADD(AESTRU,{FPG_DESPES,"FPG_DESPES",STR0028,"C","@X",1,LEN(FPG->FPG_DESPES),0}));NPOSDDE:=LEN(AESTRU) //"DESC.DESPESA"
		
		ACOLS0:={}
		FOR NPOS:=1 TO LEN(AESTRU)
			AADD(ACOLS0,AESTRU[NPOS,1])
		NEXT NPOS 
		AADD(ACOLS,ACOLS0)

		QRYFPG->(DBSKIP())
	ENDDO 

	IF LEN(ACOLS) == 0
		MSGALERT(STR0032 , STR0033) //"NÃO EXISTEM CUSTOS EXTRAS PARA O PROJETO SELECIONADO."###"GPO - CADZC1.PRW"
		Return NIL
	ENDIF

	AHEADER:={}
	FOR NPOS:=2 TO LEN(AESTRU)
		BHEADER:="{||ACOLS[OBROWSE:AT(),"+STRZERO(NPOS,2)+"]}"
		AADD(AHEADER,{AESTRU[NPOS,3],&BHEADER,AESTRU[NPOS,4],AESTRU[NPOS,5],AESTRU[NPOS,6],AESTRU[NPOS,7],AESTRU[NPOS,8]})
	NEXT NPOS 

	AOBJECTS:={}
	AADD(AOBJECTS,{100,012,.T., .T. } )	// ENCHOICE
	AADD(AOBJECTS,{100,088,.T., .T. } )	// MSGETDADOS
	
	ASIZEAUT := MSADVSIZE()
	AINFO    := {ASIZEAUT[1],ASIZEAUT[2],ASIZEAUT[3],ASIZEAUT[4],3,3}
	APOSOBJ  := MSOBJSIZE( AINFO, AOBJECTS, .T. , .F. )
	APOSGET  := MSOBJGETPOS((ASIZEAUT[3]-ASIZEAUT[1]),315,{{004,024,240,270}} )

	DEFINE MSDIALOG ODLG FROM ASIZEAUT[7],0 TO ASIZEAUT[6],ASIZEAUT[5] TITLE OEMTOANSI("DESVINCULA AS") OF OMAINWND PIXEL
	@ APOSOBJ[1,1],APOSOBJ[1,2] MSPANEL OPANEL1 PROMPT "" SIZE 10,40 OF ODLG
	@ APOSOBJ[2,1],APOSOBJ[2,2] MSPANEL OPANEL2 PROMPT "" SIZE 10,10 OF ODLG
	OPANEL1:ALIGN:=CONTROL_ALIGN_TOP
	OPANEL2:ALIGN:=CONTROL_ALIGN_ALLCLIENT
	
	oSay1	:= TSay():New( 010,010,{||"PROJETO : "+CPROJETX},OPANEL1,,oFont1,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,200,008) 
	oSay2	:= TSay():New( 030,010,{||"CLIENTE : "+CNOMANT},OPANEL1,,oFont1,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,200,008) 

	OBROWSE := FWBROWSE():NEW() 
	OBROWSE:SETDATAARRAY()
	OBROWSE:SETARRAY(ACOLS)
	OBROWSE:ADDMARKCOLUMNS(BMARK,BLDBLCLICK,BHEADERCLI)

	OBROWSE:SETCOLUMNS(AHEADER)
	OBROWSE:SETOWNER(OPANEL2)
	OBROWSE:DISABLEREPORT()
	OBROWSE:DISABLECONFIG()
	OBROWSE:ACTIVATE()
	
	ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar(oDlg,bUpdate,bCancel,,) CENTERED

Return NIL

/*/{Protheus.doc} FDESVINC
Rotina do desvinculo da AS
@type function
@version 1.0 
@author Frank Zwarg Fuga
@since 02/12/2025
/*/
Static Function FDESVINC(OBROWSE)
Local NPOS , ATABAUX
Local AAREAZC1 := FPG->(GETAREA()) 

	IF ! MSGYESNO(STR0056 , STR0033)  //"CONFIRMA O DESVINCULO ??"###"GPO - CADZC1.PRW"
		Return(.F.)
	ENDIF

	ATABAUX := OBROWSE:DATA():AARRAY

	FOR NPOS:=1 TO LEN(ATABAUX)
		IF ATABAUX[NPOS,NPOSMAR]==CMARCA
			FPG->(DBGOTO(ATABAUX[NPOS,NPOSREC]))  //POSICIONA NO ZC1

			If empty(FPG->FPG_SEQ)
				_cSeq := GetSx8Num("FPG","FPG_SEQ")
				ConfirmSx8()
				If FPG->(RecLock("FPG",.F.))
					FPG->FPG_SEQ := _cSeq
					FPG->(MsUnlock())
				EndIF
			EndIf

			IF FPG->(RECLOCK("FPG",.F.))
				FPG->FPG_NRAS   := "" 
				FPG->FPG_OBRA   := "" 
				FPG->(MSUNLOCK())
			ENDIF
		ENDIF
	NEXT

	OBROWSE:REFRESH(.T.)
	OBROWSE:SETFOCUS()

	FPG->(RESTAREA(AAREAZC1))

Return .T.

/*/{Protheus.doc} LOCA00712
Tratamento no desvinculo da AS
@type function
@version 1.0 
@author Frank Zwarg Fuga
@since 02/12/2025
/*/
Function LOCA00712(OBROWSE)
Local NPOS
Local LRET 
Local CNUMAS  := OBROWSE:DATA():AARRAY[OBROWSE:AT(),NPOSNRA]
Local CPROJET := CPROJETX

	IF ! FVERZLFSIT(CPROJET,CNUMAS) 		// VERIFICA SITUAÇÃO DA MEDIÇÃO
		Return .F.
	ENDIF

	NPOS := OBROWSE:AT()

	DO CASE
	CASE EMPTY(OBROWSE:DATA():AARRAY[NPOS,NPOSMAR]) .AND. EMPTY(OBROWSE:DATA():AARRAY[NPOS,NPOSNRA])
		MSGALERT(STR0057 , STR0033) //"ESTA DESPESA NÃO TEM AS VINCULADA !!"###"GPO - CADZC1.PRW"
	CASE OBROWSE:DATA():AARRAY[NPOS,NPOSMAR]==CMARCA
		OBROWSE:DATA():AARRAY[NPOS,NPOSMAR]:=SPACE(01)
	OTHERWISE
		OBROWSE:DATA():AARRAY[NPOS,NPOSMAR]:=CMARCA
	ENDCASE

	LRET := LOCA00709(OBROWSE)

Return LRET

/*/{Protheus.doc} LOCA00713
Tratamento no desvinculo da AS
@type function
@version 1.0 
@author Frank Zwarg Fuga
@since 02/12/2025
/*/
Function LOCA00713(OBROWSE)
Local LRET
	LRET := !EMPTY(OBROWSE:DATA():AARRAY[OBROWSE:AT(),NPOSMAR])
Return LRET

/*/{Protheus.doc} LOCA00714
Tratamento na seleção do registro
@type function
@version 1.0 
@author Frank Zwarg Fuga
@since 02/12/2025
/*/
Function LOCA00714(OBROWSE)
Local NPOS
	FOR NPOS:=1 TO LEN(OBROWSE:DATA():AARRAY)
		DO CASE
		CASE EMPTY(OBROWSE:DATA():AARRAY[NPOS,NPOSMAR]) .AND. EMPTY(OBROWSE:DATA():AARRAY[NPOS,NPOSNRA])
		CASE OBROWSE:DATA():AARRAY[NPOS,NPOSMAR]==CMARCA
			OBROWSE:DATA():AARRAY[NPOS,NPOSMAR]:=SPACE(01)
		OTHERWISE
			OBROWSE:DATA():AARRAY[NPOS,NPOSMAR]:=CMARCA
		ENDCASE
	NEXT
	OBROWSE:REFRESH(.T.)
	OBROWSE:SETFOCUS()
Return NIL

/*/{Protheus.doc} FVERZLFSIT
Verifica a situação da medição
@type function
@version 1.0 
@author Frank Zwarg Fuga
@since 02/12/2025
/*/
Static Function FVERZLFSIT(CPROJET,CNUMAS)  
Local LRET := .T.
	FPN->(DBSETORDER(2)) 				// FPN_FILIAL+FPN_AS+FPN_PROJET+FPN_OBRA+FPN_VIAGEM
	FPN->(DBSEEK(XFILIAL("FPN")+CNUMAS+CPROJET))  //POSICIONA NA MEDIÇÃO
	DO CASE
		CASE FPN->FPN_SITUAC == "2" 		// 1=DIGITADO,2=CONFIRMADO,3=CANCELADA,4=FATURADA,5=EM ABERTO,6=CANCELADA,7=ANALISE CLIENTE
			MSGALERT(STR0058 , STR0033) //"DESPESA COM MEDIÇÃO CONFIRMADA NÃO PODE SER ALTERADA !!"###"GPO - CADZC1.PRW"
			LRET := .F.
		CASE FPN->FPN_SITUAC == "7" 		// 1=DIGITADO,2=CONFIRMADO,3=CANCELADA,4=FATURADA,5=EM ABERTO,6=CANCELADA,7=ANALISE CLIENTE
			MSGALERT(STR0059 , STR0033) //"DESPESA COM MEDIÇÃO EM ANÁLISE PELO CLIENTE NÃO PODE SER ALTERADA !!"###"GPO - CADZC1.PRW"
			LRET := .F.
	ENDCASE
Return LRET

/*/{Protheus.doc} LOCA00721
Rotina para acerto da numeração do FPG
@type function
@version 1.0 
@author Frank Zwarg Fuga
@since 02/12/2025
/*/
Function LOCA00721(_cAlias)
Local _cSeq

	If empty(_cAlias) .or. (_cAlias <> "FPG" .and. _cAlias <> "FQ4" .and. _cAlias <> "FQ8" .and. _cAlias <> "FQA")
		MsgAlert(STR0065,STR0066) //"Faltou preencher o Alias, ou informado o incorreto."###"Atenção!"
		Return
	EndIf

	If _cAlias == "FPG"
		FPG->(dbSetOrder(1))
		FPG->(dbGotop())
		While !FPG->(Eof())
			If empty(FPG->FPG_SEQ)
				_cSeq := GetSx8Num("FPG","FPG_SEQ")
				ConfirmSx8()
				FPG->(RecLock("FPG",.F.))
				FPG->FPG_SEQ := _cSeq
				FPG->(MsUnlock())
			EndIf
			FPG->(dbSkip())
		EndDo
	EndIF

	If _cAlias == "FQ4"
		FQ4->(dbSetOrder(1))
		FQ4->(dbGotop())
		While !FQ4->(Eof())
			If empty(FQ4->FQ4_SEQ)
				_cSeq := GetSx8Num("FQ4","FQ4_SEQ")
				ConfirmSx8()
				FQ4->(RecLock("FQ4",.F.))
				FQ4->FQ4_SEQ := _cSeq
				FQ4->(MsUnlock())
			EndIf
			FQ4->(dbSkip())
		EndDo
	EndIF

	MsgAlert(STR0067,STR0066) //"Acertos realizados com sucesso."###"Atenção!"
Return 


/*/{Protheus.doc} GERANFPG
Função para geracao do sequencial da FPG
@type function
@version 1.0 
@author Frank Zwarg Fuga
@since 02/12/2025
/*/
Function GERANFPG
Local _cSeq
	If empty(M->FPG_SEQ)
		_cSeq := GetSx8Num("FPG","FPG_SEQ")
		ConfirmSx8()
		M->FPG_SEQ := _cSeq
	EndIf
Return .T.

/*/ LC007DOC
description	Chama MsDocument
author José Eulálio
version	1.00
since 16/11/2021
/*/			
Function LC007DOC()
	ItupDocs("FPG", FPG->(Recno()))
Return

/*/ ItupDocs
description	Chama MsDocument
author José Eulálio
version 1.00
since 06/12/2019
/*/			
Function ItupDocs(cEntidade, nRecEnt)
Local aAreaAC9	:= AC9->(GetArea())

	MpDocument(cEntidade,nRecEnt, 2)  
	RestArea(aAreaAC9)

Return

/*/LC007BCOPV
description	Copia o Banco de Conhecimento do Custo Extra para o Pedido de Venda
author José Eulálio
version	1.00
since 17/11/2021
/*/			
Function LC007BCOPV(cPvFil , cPvNum)
Local nX		:= 0
Local cChave	:= ""
Local aAreaAC9	:= AC9->(GetArea())
Local aCodObj	:= {}

	//Localiza Documentos
	AC9->(DBSETORDER(2)) 		// AC9_FILIAL+AC9_ENTIDA+AC9_FILENT+AC9_CODENT+AC9_CODOBJ 
	If AC9->(DBSEEK(XFILIAL("AC9") + "FPG" + FPG->FPG_FILIAL + FPG->FPG_PROJET + FPG->FPG_NRAS + FPG->FPG_SEQ))
		cChave	:= AC9->(AC9_FILIAL+AC9_ENTIDA+AC9_FILENT+AC9_CODENT)
		While !AC9->(EoF()) .And. cChave == AC9->(AC9_FILIAL+AC9_ENTIDA+AC9_FILENT+AC9_CODENT)
			Aadd(aCodObj, AC9->AC9_CODOBJ)
			AC9->(DbSkip())
		EndDo
	EndIf

	//Grava Conhecimento no Pedido
	For nX := 1 To Len(aCodObj)
		RecLock("AC9", .T.)
			AC9->AC9_FILIAL := xFilial("AC9")
			AC9->AC9_FILENT := cPvFil
			AC9->AC9_ENTIDA := "SC5" 
			AC9->AC9_CODENT := cPvNum
			AC9->AC9_CODOBJ := aCodObj[nX]
		AC9->(MsUnlock())
	Next nX

	RestArea(aAreaAC9)

Return


/*/{Protheus.doc} LOCA00722
Visualizacao do custo extra
@type function
@version 1.0 
@author Frank Zwarg Fuga
@since 02/12/2025
/*/
Function LOCA00722
Local _AAREAOLD := GETAREA()
Local aButtons 	:= {}
Local aAcho 	:= {}
Private CCADASTRO := STR0068 //"visualização de custo extra"

	if existblock("LOCA007C")
		aButtons := execblock("LOCA007C" , .T. , .T. , {aButtons}) 
	endif

	&("SX3->(dbSetOrder(1))")
	&("SX3->(dbSeek('FPG'))")
	While !&("SX3->(Eof())") .and. &("SX3->X3_ARQUIVO") == "FPG"
		If &("X3USO(SX3->X3_USADO)") .and. alltrim(&("SX3->X3_CAMPO")) <> "FPG_RECORI" .and. alltrim(&("SX3->X3_CAMPO")) <> "FPG_OK"
			aadd(aAcho,&("SX3->X3_CAMPO"))
		EndIF
		&("SX3->(dbSkip())")
	EndDo

	INCLUI := .F.
	ALTERA := .F.
	DBSELECTAREA("FPG")
	FPG->(DBSETORDER(1))
	NOPC := AXVISUAL("FPG"  ,FPG->(RECNO()),2,aAcho,,,            , aButtons )
	RESTAREA ( _AAREAOLD )

Return

/*/LOCA00723
description	Nome do Cliente na Consulta Padraão FPG2
author José Eulálio
version	1.00
since 28/04/2022
/*/			
Function LOCA00723()
Local cRet		:= FQ5_NOMCLI
Local cNumAS	:= FQ5_AS
Local nX		:= 0
Local aArea		:= GetArea()
Local aAreaFPA	:= FPA->(GetArea())
Local aAreaFP1	:= FP1->(GetArea())

	For nX:=1 to 20
		If upper(alltrim(ProcName(nX))) $ "LOCA00717|LOCA00718"
			If M->FPG_PROJET == FQ5_SOT
				//Seleciona Cliente de acordo MULTPLUS FATURAMENTO NO CONTRATO - SIGALOC94-282
				FPA->(DbSetOrder(3)) //FPA_FILIAL+FPA_AS+FPA_VIAGEM
				If FPA->(DbSeek(xFilial("FPA") + cNumAS))
					If FPA->(ColumnPos("FPA_CLIFAT")) > 0 .And. !Empty(FPA->FPA_CLIFAT)
						cRet := FPA->FPA_NOMFAT
					Else
						FP1->(DbSetOrder(1)) //FP1_FILIAL+FP1_PROJET+FP1_OBRA
						If FP1->(DbSeek(xFilial("FP1") + FPA->(FPA_PROJET + FPA_OBRA)))				
							If !Empty(FP1->FP1_CLIDES)
								cRet := FP1->FP1_NOMDES
							EndIf
						EndIf
					EndIf
				EndIf
				RestArea(aAreaFPA)
				RestArea(aAreaFP1)
				RestArea(aArea)
			EndIf
		EndIf
	Next nX

Return cRet

/*/{Protheus.doc} LOCA00713
Valida o Campo FPG_COBRA
@type function
@version 1.0 
@author aleci
@since 6/28/2024
/*/
Function LOCA00720()
Local lRet := .T.
Local cCobra := &(ReadVar())
Local cOS
Local aArea := GetArea()
Local aAreaSTJ := STJ->(GetArea())

	// Só se poderá colocar o campo para COBRAR = Sim se a OS de origem estaiver fechada
	if cCobra = "S"
		// FPG_TIPO = 4 veio de uma OS
		if M->FPG_TIPO = "4"
			// Verificar se a OS está finalizada
			cOS := SubStr(M->FPG_DOCORI,1, Tamsx3("TJ_ORDEM")[1])
			STJ->(DBSETORDER(1))
			IF STJ->(DBSEEK(XFILIAL("STJ")+cOS))
				if STJ->TJ_TERMINO <> "S" // OS Fechada
					Help(	Nil,Nil,"LOCA007_01",Nil,STR0078+cOS+STR0076,1,0,Nil,Nil,Nil,Nil,Nil,{STR0077}) //" não está finalizada ! O Custo Extra não pode ser faturado." //"Finalize a OS antes de colocar o custo extra para ser faturado" //"A OS "
					lRet := .F.
				endif
			endif
		endif
	endif

	RestArea(aAreaSTJ)
	RestArea(aArea)

return lRet

/*/{Protheus.doc} LOCA00724
Gatilha a Descrição do Produto
@type function
@version 1.0 
@author Dennis Calabrez
@since 14/11/2025
/*/
Function LOCA00724()
Local oModel := FWModelActive()
Local cDesc  := oModel:GetValue('FPGMASTER','FPG_PRODUT')
Local cProd := ""

	cProd := Posicione("SB1",1,xFilial("SB1")+cDesc,"B1_DESC")

Return cProd

