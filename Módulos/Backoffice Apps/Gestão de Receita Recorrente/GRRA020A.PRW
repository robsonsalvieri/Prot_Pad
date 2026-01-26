#INCLUDE "TOTVS.CH"
#INCLUDE "FWMVCDEF.CH" 
#INCLUDE "GRRA020A.CH" 

//-------------------------- GRRA020A --------------------------------
// Funções para apresentação das informações de planos x itens na 
// geração do pedido de venda ou contrato para a integração com o GRR.
//-------------------------------------------------------------------

//-------------------------------------------------------------------
/*/{Protheus.doc} GRRA020A
Funcao para gerar pedido de venda

@author Claudio Donetti
@since 08/05/2022
@version 1.0
/*/
//-------------------------------------------------------------------
/*Function GRRA020A()

Local aPerg     := {}
Local aRet		:= {}
Local aCabec	:= {}
Local aItens	:= {}
Local aLinha	:= {}
Local cDoc		:= "" 
Local nSaldo	:= 0
Local lRet		:= .T.
Local lAmountRel := .F.

Private lMsErroAuto		:= .F.
Private lAutoErrNoFile	:= .F.
Private cCadastro		:= ""
Private aRotina := {	{	"Pesquisar","AxPesqui"		,0,1,0 ,.F.},;		//"Pesquisar"
							{ "Visual","A410Visual"	,0,2,0 ,NIL},;		//"Visual"
							{ "Incluir","A410Inclui"	,0,3,0 ,NIL},;		//"Incluir"
							{ "Alterar","A410Altera"	,0,4,20,NIL},;		//"Alterar"
							{ "Excluir",IIf((Type("l410Auto") <> "U" .And. l410Auto),"A410Deleta",Nil),0,5,0,NIL},; // Excluir
							{ "Cod.barra","A410Barra" 		,0,3,0 ,NIL},;		//"Cod.barra"
							{ "Copia","a410PCopia('SC5',SC5->(RecNo()),4)"	,0,6,0 ,NIL},;		//"Copia"
							{ "Dev. Compras","A410Devol('SC5',SC5->(RecNo()),4)"	,0,3,0 ,.F.},;		//"Dev. Compras"
							{ "Prep.Doc.Sa?a","Ma410PvNfs"	,0,2,0 ,NIL},;		//"Prep.Doc.Sa?a"
							{ "Tracker Cont?il","CTBC662", 0, 7, 0, Nil },; 		//"Tracker Cont?il"
							{ "Legenda","A410Legend"	,0,1,0 ,.F.} }		//"Legenda"

//-------------------------------------------
//Verifica se existem itens gravados no plano
//-------------------------------------------
HRE->(dbSetOrder(1)) //HRE_FILIAL+HRE_PLAN+HRE_ITEM+HRE_FILPRD+HRE_PRDCOD
If !(HRE->(dbSeek(FWxFilial("HRE")+HRD->HRD_CODE)))
	MsgAlert("Plano não possui itens. Não é possível gerar Pedido de venda.","Atenção")
	lRet := .F.
EndIf

If lRet
	Pergunte( "MTA410", .F. )
	IF MV_PAR01 == 1
		lAmountRel := .T.
	EndIf

	aAdd(aPerg,{1,"Cliente", Space(6),"","","SA1","",6,.F.})
	aAdd(aPerg,{1,"Loja", Space(2),"","","","",2,.F.})
	aAdd(aPerg,{1,"Cond.Pgto", Space(3),"","","SE4GRR","",3,.F.})
	If ParamBox(aPerg,"Gera pedido de venda",@aRet, {|| .T.},,,,,,, .T., .T.)
		If Empty(aRet[1]) .Or. Empty(aRet[2])
			MsgAlert("Cliente ou loja não informado. Não é possível gerar Pedido de venda.","Atenção")
		Else
			cDoc := GetSxeNum("SC5", "C5_NUM")

			aadd(aCabec, {"C5_NUM",     cDoc,      Nil})
			aadd(aCabec, {"C5_TIPO",    "N",       Nil})
			aadd(aCabec, {"C5_CLIENTE", aRet[1],   Nil})
			aadd(aCabec, {"C5_LOJACLI", aRet[2],   Nil})
			aadd(aCabec, {"C5_LOJAENT", aRet[2],   Nil})
			aadd(aCabec, {"C5_TIPOCLI", "F",       Nil})
			aadd(aCabec, {"C5_CONDPAG", aRet[3], Nil})
			aadd(aCabec, {"C5_PLANGRR", HRD->HRD_CODE, Nil})
			aadd(aCabec, {"C5_ASSGRR", HRD->HRD_NAME, Nil})

			// TODO - EXEMPLO PARA GRAVAR A TABELA INTERMEDIARIA
			// aadd(aCabecHRG, {"HRH_SRCFIL",    xFilial("SC5"),       Nil})
			// aadd(aCabecHRG, {"HRH_ALIAS",     "SC5",      Nil})
			// aadd(aCabecHRG, {"HRH_SOURCE",     "MATA410",      Nil})
			// aadd(aCabecHRG, {"HRH_REQCD",     cDoc,      Nil})
			// aadd(aCabecHRG, {"HRH_PLANCD",     HRD->HRD_CODE,      Nil})


			SB1->(dbSetOrder(1))
			SB2->(DbSetOrder(1))

			HRE->(dbSeek(FWxFilial("HRE")+HRD->HRD_CODE))
			While !HRE->(Eof()) .And. HRE->(HRE_FILIAL+HRE_PLAN) == FWxFilial("HRE")+HRD->HRD_CODE

				If SB1->(dbSeek(FWxFilial("SB1")+HRE->HRE_PRDCOD))
					If Empty(SB1->B1_CODISS)
						If SB2->(DbSeek(FWxFilial('SB2')+SB1->B1_COD+SB1->B1_LOCPAD ))
							nSaldo := SaldoSB2(,.F.)
							If nSaldo >= HRE->HRE_QUANT
								aLinha := {}
								aadd(aLinha,{"C6_ITEM",HRE->HRE_ITEM, Nil})
								aadd(aLinha,{"AUTDELETA","N",Nil})
								aadd(aLinha,{"C6_PRODUTO",HRE->HRE_PRDCOD,Nil})
								aadd(aLinha,{"C6_QTDVEN",HRE->HRE_QUANT,Nil})
								aadd(aLinha,{"C6_PRCVEN",HRE->HRE_VALUE,Nil})
								aadd(aLinha,{"C6_PRUNIT",HRE->HRE_VALUE,Nil})
								aadd(aLinha,{"C6_VALOR",HRE->HRE_TOTAL,Nil})
								aadd(aLinha,{"C6_TES","501",Nil})
								If lAmountRel
									aadd(aLinha,{"C6_QTDLIB", HRE->HRE_QUANT,Nil})
								EndIf
						
								aadd(aItens,aLinha)
							Else
								MsgAlert("Produto: "+Alltrim(SB1->B1_COD)+"-"+Alltrim(SB1->B1_DESC)+" não possui saldo em estoque suficiente:"+CRLF+;
										"Saldo estoque: "+AllTrim(Str(nSaldo))+CRLF+;
										"Quantidade necessitada: "+AllTrim(Str(HRE->HRE_QUANT))+CRLF)
							EndIf
						EndIf
					Else
						aLinha := {}
						aadd(aLinha,{"C6_ITEM",HRE->HRE_ITEM, Nil})
						aadd(aLinha,{"AUTDELETA","N",Nil})
						aadd(aLinha,{"C6_PRODUTO",HRE->HRE_PRDCOD,Nil})
						aadd(aLinha,{"C6_QTDVEN",HRE->HRE_QUANT,Nil})
						aadd(aLinha,{"C6_PRCVEN",HRE->HRE_VALUE,Nil})
						aadd(aLinha,{"C6_PRUNIT",HRE->HRE_VALUE,Nil})
						aadd(aLinha,{"C6_VALOR",HRE->HRE_TOTAL,Nil})
						aadd(aLinha,{"C6_TES","501",Nil})
						If lAmountRel
								aadd(aLinha,{"C6_QTDLIB", HRE->HRE_QUANT,Nil})
						EndIf
						
						aadd(aItens,aLinha)
					EndIf
				EndIf

				HRE->(dbSkip())
			EndDo

			If Len(aItens) > 0
				// MSExecAuto({|a, b, c, d, , , , , , , , , , , , z| MATA410(a, b, c, d, , , , , , , , , , , , z)}, aCabec, aItens, 3, .F.)
				MSExecAuto({|a, b, c, d, , , , , , , , , , , , z| MATA410(a, b, c, d, , , , , , , , , , , , z)}, aCabec, aItens, 3, .F., , , , , , , , , , , , aCabecHRG)

				If !lMsErroAuto
					ConfirmSx8()
					Msginfo("Pedido gerado '"+cDoc+"'","OK")

					SC5->(dbSetOrder(1)) //C5_FILIAL+C5_NUM
					If (SC5->(dbSeek(FWxFilial("SC5")+cDoc)))
						cCadastro := "Pedido de Vendas"
						SC5->(a410Visual("SC5",SC5->(Recno()),2))
					EndIf
				Else
					RollbackSx8()
					MOSTRAERRO()
					MsgAlert("Não foi possível gerar pedido de venda!")
				EndIf
			Else
				RollbackSx8()
				MsgAlert("Não foi possível gerar pedido de venda!")
			EndIf
		EndIf
	Endif
EndIf

Return
*/


// TODO da Junko - Refatorando bloco das funções do Pedido de venda
//-------------------------------------------------------------------
/*/{Protheus.doc} GRRLoadPlan
Função que apresenta em tela itens de um determinado plano e os atribui
à grid do pedido de vendas.

@param cPlanCode, caracter, código do plano
@param lUpdateGrid, lógico, valida se irá atualizar  o grid.

@return boolean, Indica se conseguiu atualizar a grid de itens.
@author Marcia Junko
@since 30/05/2022
/*/
//-------------------------------------------------------------------
Function GRRLoadPlan( cPlanCode, lUpdateGrid )
	Local aSvArea		:= GetArea()
	Local aStructs 		:= {}
	Local aContent      := {}
	Local cAliasTmp 	:= GetNextAlias()
	Local oTempTable	:= Nil
	Local oModel		:= FWModelActive()
    Local oModelCNA	    := NIL
	Local lRet			:= .T.
	Local lCNTA300 		:= FwIsInCallStack( "CN300TPPLA" )

	DEFAULT lUpdateGrid := .T.

	HRD->( dbSetOrder(1) )    //HRD_FILIAL+HRD_CODE
	If !HRD->( dbSeek( FWxFilial( "HRD" ) + cPlanCode ) )
		MsgAlert( STR0001, STR0002 )	//"Plano informado não encontrado!"###"Atenção"
		lRet := .F.
	Else
		aContent      := { { "HRE_ITEM", "ITEM" }, ;
							{ "HRE_PRDCOD", "CODPRD" }, ;
							{ "B1_DESC", "DSCPRD" }, ; 
							{ "B1_UM", "UNIDMED" }, ; 
							{ "HRE_QUANT", "QTDPRD" }, ;
							{ "HRE_BASEVL", "PRCTAB" }, ;
							{ "HRE_VALUE", "PRCVEN" } }

		//-------------------------------------------------------------------
		// Monta as estruturas da tabela temporária e do cabeçalho do browse
		//-------------------------------------------------------------------
		aStructs := MakeStructs( aContent, cAliasTmp )

		//-------------------------------------------------------------------
		// Se for GCT 
		//-------------------------------------------------------------------
		If lCNTA300
			lRet := .F.
			If oModel:Activate()
				oModelCNA	:= oModel:GetModel( 'CNADETAIL' ) //--Planilha  do GCT 

				IF CNL->( MsSeek( xFilial('CNL') + oModelCNA:GETVALUE( 'CNA_TIPPLA' ) ) ) .And. CNL->CNL_MEDEVE = '3'
					lRet := .T.
				else
					//TODO Criar um help para informar que o tipo de medição não pode ser processdado como GRR
					Aviso( "GRRA0S0A", STR0003, {"Ok"} )	//"Integração GRR só é possivel para o tipo de medição recorrente. CNL_MEDEVE = '3'"
				EndIF

			EndIF
		EndIF

		If lRet
			//-------------------------------------------------------------------
			// Cria arquivo temporário
			//-------------------------------------------------------------------
			oTempTable := FWTemporaryTable():New( cAliasTmp )
			oTempTable:SetFields( aStructs[ 1 ] )
			oTempTable:AddIndex( "I1", {"ITEM"} )
			oTempTable:Create()

			Processa( { || lRet := SeekItems( cPlanCode, oTempTable ) }, STR0004 )	//'Buscando itens do plano'
			
			If lRet
				lRet := ItemsScreen( aStructs[ 2 ], cAliasTmp )
			Else
				MsgAlert( STR0005, STR0002 )	//"Plano informado não possuí itens cadastrados!"###"Atenção"  
			EndIf

			//-------------------------------------------------------------------
			// Exclui a tabela temporária
			//-------------------------------------------------------------------
			oTempTable:Delete()
		EndIF
	EndIf

	If lRet .and. lUpdateGrid
		//-------------------------------------------------------------------
		// Atualiza a grid de itens do pedido de venda
		//-------------------------------------------------------------------
		oGetDad:ForceRefresh()
	EndIf

	RestArea( aSvArea )

	FWFreeArray( aSvArea )
Return lRet


//-------------------------------------------------------------------
/*/{Protheus.doc} MakeStructs
Função que cria as estruturas para a tabela temporária e ao browse, 
de acordo com uma lista de campos.

@param aContent, array, Vetor com as informações que devem compor 
	a estrutura, onde: 
		[1] - nome do campo original
		[2] - nome do campo na tabela temporária
@param cAliasTmp, caracter, Alias da tabela temporário da grid de itens do plano

@return array, Vetor com as estruturas de trabalho, onde:
	[1] - Struct da tabela temporária
	[2] - Cabeçalho do browse
@author Marcia Junko
@since 30/05/2022
/*/
//-------------------------------------------------------------------
Static Function MakeStructs( aContent, cAliasTmp )
	Local aStruct := {}
	Local aHeader := {}
	Local aSizeDef := {}
	Local nI := 0
	Local cType := ''
	Local cField := ''
	
	//-------------------------------------------------------------------
	// Cria estrutura para o arquivo de trabalho 
	//-------------------------------------------------------------------
	aAdd( aStruct, { "MARK", "C",  002, 0 } )

	For nI := 1 to len( aContent )
		cField := aContent[ nI ][1] 
		cType := FWSX3Util():GetFieldType( cField )
		aSizeDef := TamSX3( cField )

		aAdd( aStruct, { aContent[ nI ] [ 2 ], cType,  aSizeDef[1], aSizeDef[2] } )

		//-------------------------------------------------------------------
		// Cria estrutura para o browse
		//-------------------------------------------------------------------
		aAdd( aHeader, FWBrwColumn():New())

		aTail( aHeader ):SetData( &("{|| (cAliasTmp)->"+aContent[ nI ] [2 ]+"}") )
		aTail( aHeader ):SetTitle( FwX3Titulo( cField ) )
		aTail( aHeader ):SetSize( aSizeDef[1] ) 
		aTail( aHeader ):SetDecimal( aSizeDef[2] )
		aTail( aHeader ):SetPicture( GRRPesqPict( cField ) ) 

		//-------------------------------------------------------------------
		// Ajusta o tamanho das colunas da grid
		//-------------------------------------------------------------------
		If cType == "N"
			aTail( aHeader ):nSize := 8
		Else
			aTail( aHeader ):nSize := aSizeDef[1] - 1
		EndIf
	Next
Return { aStruct, aHeader }

//-------------------------------------------------------------------
/*/{Protheus.doc} ItemsScreen
Função que monta a tela de "seleção" dos itens do plano

@param aHeader, array, Vetor com as informações do cabeçalho do browse
@param cAliasTmp, caracter, Alias da tabela temporário da grid de itens do plano

@return boolean, Indica se os itens foram atribuídos ao grid do pedido de venda
@author Marcia Junko
@since 30/05/2022
/*/
//-------------------------------------------------------------------
Static Function ItemsScreen( aHeader, cAliasTmp )
	Local nGetLine := 0
	Local nCol := 0
	Local nBottom := 390
	Local lRet := .F.
	Local lCNTA300 := FwIsInCallStack( "CN300TPPLA" )
	Local lItemCust := SuperGetMV( "MV_GRRICST", .F. , .F. ) //Verifica se pode customizar os valores e quantidades dos itens das subscrições GRR.
	Local oDlg
	Local oPanelPar
	Local oPanelLin
	Local oPanPar
	Local oPanelTbl
	Local oMBrwTabs

	Define MsDialog oDlg Title STR0006 From 00,00 TO nBottom, 1170 Pixel	//"Itens do Plano"

		oLayer := FWLayer():New()
		oLayer:Init( oDlg, .F. )

			oLayer:AddLine( "BOX_PARAMETRO", 15 ) 
			oPanelPar := oLayer:getLinePanel( "BOX_PARAMETRO" )

				nGetLine := oPanelPar:NCLIENTHEIGHT * 0.17
				nCol := oPanelPar:NCLIENTWIDTH

				@ 03, nCol * 0.01 SAY STR0007 OF oPanelPar PIXEL 	//"Plano"
				@ nGetLine, nCol  * 0.01 MSGET HRD->HRD_CODE SIZE 35, 12 OF oPanelPar PIXEL WHEN .F. 

				@ 03, nCol * 0.07 SAY STR0008 OF oPanelPar PIXEL	//"Versão" 
				@ nGetLine, nCol  * 0.07 MSGET HRD->HRD_VERSIO SIZE 20, 12 OF oPanelPar PIXEL WHEN .F. 

				@ 03, nCol * 0.12 SAY STR0009 OF oPanelPar PIXEL 	//"Nome"
				@ nGetLine, nCol  * 0.12 MSGET HRD->HRD_NAME SIZE 145, 12 OF oPanelPar PIXEL WHEN .F. 

				@ 03, nCol * 0.30 SAY STR0010 OF oPanelPar PIXEL 	//"Início Vigência"
				@ nGetLine, nCol  * 0.30 MSGET HRD->HRD_INTERM SIZE 55, 12 OF oPanelPar PIXEL WHEN .F. 

				@ 03, nCol * 0.38 SAY STR0011 OF oPanelPar PIXEL 	//"Término Vigência"
				@ nGetLine, nCol  * 0.38 MSGET HRD->HRD_FITERM SIZE 55, 12 OF oPanelPar PIXEL WHEN .F. 

	
			oLayer:AddLine( "BOX_LINHA", 000.5 )
			oPanelLin := oLayer:getLinePanel( "BOX_LINHA" )

				oPanPar  := TPanel():New( 00, 00, "", oPanelLin,, .F., .F.,, CLR_BLUE, 005, 005, .F., .F. )
				oPanPar:Align := CONTROL_ALIGN_ALLCLIENT

			oLayer:AddLine( "BOX_TABELAS", 70 )
			oPanelTbl := oLayer:getLinePanel( "BOX_TABELAS" )

				oPGerTb := TPanel():New( 00, 00, "", oPanelTbl, , .F., .F., , , 10, oPanelTbl:NCLIENTHEIGHT * 0.39, .F., .F. ) 
				oPGerTb:Align = CONTROL_ALIGN_ALLCLIENT
				
					oMBrwTabs := FWMarkBrowse():New()
					oMBrwTabs:SetAlias( cAliasTmp )
					oMBrwTabs:SetColumns( aHeader )
					oMBrwTabs:SetMenuDef( "" )
					oMBrwTabs:SetFieldMark("MARK")
					oMBrwTabs:SetDescription( STR0012 )	//"Itens do Plano"
					oMBrwTabs:DisableDetails()
					oMBrwTabs:DisableConfig()
					oMBrwTabs:SetIgnoreARotina( .T. )
					oMBrwTabs:SetUseFilter( .F. )
					oMBrwTabs:SetTemporary( .T. )
					oMBrwTabs:DisableLocate()
					oMBrwTabs:DisableReport()
					oMBrwTabs:SetAllMark( { || oMBrwTabs:AllMark() } )
					oMBrwTabs:Activate( oPGerTb )
	
					//-------------------------------------------------------------------
					// Validação para liberar a escolha dos  itens do plano. 
					//-------------------------------------------------------------------
					IIF( lItemCust, "", oMBrwTabs:Disable() )
					
					MarkItems( oMBrwTabs )
					
					//-------------------------------------------------------------------
					// Força o posicionamento do primeiro registro
					//-------------------------------------------------------------------
					oMBrwTabs:GoTop( .T. )

	Activate MsDialog oDlg Centered ;
		On Init ( EnchoiceBar( oDlg, {|| lRet := IF( !lCNTA300, SetItens2Grid( cAliasTmp, oMBrwTabs:Mark() ), SetItensCNB( cAliasTmp, oMBrwTabs:Mark() ) ), ;
			oDlg:End() }, {|| lRet := .F., oDlg:End() },,,,, .F., .F., .F., .T., .F.), ChangeCaptions( @oDlg ) )

	FreeObj( oDlg )
	FreeObj( oLayer )
	FreeObj( oPanelPar )
	FreeObj( oPanelLin )
	FreeObj( oPanPar ) 
	FreeObj( oPanelTbl )
	FreeObj( oMBrwTabs )
Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} SeekItems
Função que buca os itens de um determinado plano e alimenta em uma 
tabela temporária.

@param cPlanCode, caracter, código do plano
@param oTempTable, objeto, componente de tabela temporária

@return boolean, Indica se tem itens atrelados ao plano.
@author Marcia Junko
@since 30/05/2022
/*/
//-------------------------------------------------------------------
Static Function SeekItems( cPlanCode, oTempTable )
	Local aSvArea	:= GetArea()
	Local aStruct := {}
	Local lCanUseBulk := .F.
	Local lRet  := .F.
	Local cTmpItems := GetNextAlias()
	Local cTableName := ''
	Local cTableAlias := ''
	Local oBulk

    cTableAlias := oTempTable:GetAlias()
    cTableName := UPPER( oTempTable:GetRealName() ) 
    If AllTrim( Upper( TcGetDb() ) ) $ 'MSSQL'
        cTableName := oTempTable:cTableName
    EndIf

    oBulk := FwBulk():New( cTableName )
    lCanUseBulk := FwBulk():CanBulk() 
    if lCanUseBulk
        aStruct := ( cTableAlias )->( DBStruct() ) 
        oBulk:SetFields( aStruct )
    endif

    cQuery := "SELECT HRE_ITEM, HRE_PRDCOD, HRE_QUANT, HRE_BASEVL, HRE_VALUE, B1_DESC, B1_UM " + ;
        " FROM " + RetSqlName( "HRE" ) + " HRE " + ;
        " INNER JOIN " + RetSqlName( "SB1" ) + " SB1 " + ;
            " ON B1_FILIAL = HRE_FILPRD " + ;
            " AND B1_COD = HRE_PRDCOD " + ;
            " AND SB1.D_E_L_E_T_ = ' ' " + ;
        " WHERE HRE_FILIAL = '" + xFilial( "HRE" ) + "' " + ;
            " AND HRE_PLAN = '" + cPlanCode + "' " + ;
            " AND HRE.D_E_L_E_T_ = ' ' " + ;
        " ORDER BY HRE_PLAN, HRE_ITEM"
    cQuery := ChangeQuery( cQuery )
    MPSysOpenQuery( cQuery, cTmpItems )

    While ( cTmpItems )->( !Eof() )
        If lCanUseBulk
            oBulk:AddData( { "  ", ( cTmpItems )->HRE_ITEM, ( cTmpItems )->HRE_PRDCOD, ( cTmpItems )->B1_DESC, ( cTmpItems )->B1_UM,;
                    ( cTmpItems )->HRE_QUANT, ( cTmpItems )->HRE_BASEVL, ( cTmpItems )->HRE_VALUE } )
            lRet := .T.
        EndIf

         ( cTmpItems )->( DbSkip() )
    END
    ( cTmpItems )->( DbCloseArea() )

    if lCanUseBulk
        oBulk:Close()
        oBulk:Destroy()
        oBulk := nil
    endif

    RestArea( aSvArea )

	FWFreeArray( aSvArea )
	FWFreeArray( aStruct )
	FREEOBJ( oBulk )
Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} MarkItems
Função que marca como selecionado os registro da tabela temporária

@param oMBrwTabs, object, componente da Markbrowse

@author Claudio Donetti
@since 13/05/2022
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function MarkItems( oMBrwTabs )
	Local aSvArea     := GetArea()
	Local cAlias    := oMBrwTabs:Alias()
	Local cMark     := oMBrwTabs:Mark()
	Local nRecno    := ( cAlias )->( Recno() )

	( cAlias )->( dbGoTop() )
	While ( cAlias )->( !Eof() )
		RecLock( cAlias, .F. )
			( cAlias )->MARK := cMark
		( cAlias )->( MsUnlock() )

		( cAlias )->( dbSkip() )
	EndDo

	( cAlias )->( dbGoTo( nRecno ) )

	oMBrwTabs:Refresh()

	RestArea( aSvArea )
Return


//-------------------------------------------------------------------------------------
/*/{Protheus.doc} ChangeCaptions
Função que ajusta o nome de alguns componentes apresentados em tela

OBS: Talvez este mão seja a melhor forma de se fazer isso.

@param oDlgHRE, object, Tela onde a consulta está sendo apresentada

@author  Marcia Junko
@since   25/05/2022
/*/
//-------------------------------------------------------------------------------------
Static Function ChangeCaptions( oDlgHRE )
    Local nLen := Len( oDlgHRE:aControls )
    Local nPos := 0

    If oDlgHRE:aControls[ nLen - 1 ]:ClassName() == "TBROWSEBUTTON" .And. oDlgHRE:aControls[ nLen ]:ClassName() == "TSAY"
        oDlgHRE:aControls[ nLen ]:cCaption := STR0013	//'Consulta aos dados do plano'
    EndIf

    If ( nPos := Ascan( oDlgHRE:aControls, {|x| x:ClassName() == "TBROWSEBUTTON" .And. x:cCaption == "Salvar" } ) ) > 0 
        oDlgHRE:aControls[ nPos ]:cCaption := STR0014	//"Atribuir"
    EndIf
Return

//-------------------------------------------------------------------------------------
/*/{Protheus.doc} SetItens2Grid
Função que atribui os itens do plano ao grid do pedido de vendas

@param cAliasTmp, caracter, Alias da tabela temporário da grid de itens do plano
@param cMark, caracter, Marca que indica que o item está selecionado.

@author  Marcia Junko
@since   26/05/2022
/*/
//-------------------------------------------------------------------------------------
Static Function SetItens2Grid( cAliasTmp, cMark )
	Local aSvArea    := GetArea()
	Local aItems  	 := {}
	Local lRet       := .T.
	Local lAmountRel := .F.
	Local cItem      := "01"
	Local cField 	 := ""
	Local nPosIte	 := aScan( aHeader, {|x| AllTrim( x[2] ) == "C6_ITEM" } )
	Local nPosCod	 := aScan( aHeader, {|x| AllTrim( x[2] ) == "C6_PRODUTO" } )
	Local nPosQtd	 := aScan( aHeader, {|x| AllTrim( x[2] ) == "C6_QTDVEN" } )
	Local nPosPrc	 := aScan( aHeader, {|x| AllTrim( x[2] ) == "C6_PRCVEN" } )
	Local nPosQtdRel := aScan( aHeader, {|x| AllTrim( x[2] ) == "C6_QTDLIB" } )
	Local nK         := 0
	Local nJ         := 0

	Pergunte( "MTA410", .F. )
	IF MV_PAR01 == 1
		lAmountRel := .T.
	EndIf

	( cAliasTmp )->( DBGoTop() )
	While ( cAliasTmp )->( !Eof() )
		If ( cAliasTmp )->MARK == cMark
			AADD( aItems,{ ( cAliasTmp )->CODPRD, ( cAliasTmp )->QTDPRD, ( cAliasTmp )->PRCTAB, ( cAliasTmp )->PRCVEN } )
		EndIf

		( cAliasTmp )->( DBSkip() )
	EndDo

	If Len( aItems ) > 0
		aColsAux := aClone( aCols )
		cItem := aTail( aColsAux )[1]

		For nK := 1 To Len( aItems )		
			SB1->( dbSeek( xFilial("SB1") + aItems[ nK ][ 1 ]))
			If !Empty( aTail( aColsAux )[ nPosCod ] )
				Aadd( aColsAux, {} )
				cItem := Soma1( cItem )
			Else
				aTail( aColsAux ) := {}
			EndIf
			
			For nJ := 1 To Len( aHeader )
				cField := aHeader[ nJ ][ 2 ]
				Do Case
					Case nJ == nPosIte
						Aadd( aTail( aColsAux ), cItem )
					Case nJ == nPosCod
						Aadd( aTail( aColsAux ), aItems[ nK ][ 1 ] )
					Case nJ == nPosQtd
						Aadd( aTail( aColsAux ), aItems[ nK ][ 2 ] )
					Case nJ == nPosPrc
						Aadd( aTail( aColsAux ), aItems[ nK ][ 3 ] )
					Case nJ == nPosQtdRel .And. lAmountRel
						Aadd( aTail( aColsAux ), aItems[ nK ][ 2 ] )
					Case AllTrim( cField ) == "C6_ENTREG"
						Aadd( aTail( aColsAux ), CriaVar( "C6_ENTREG", .T. ) )
					Case AllTrim( cField ) == "C6_TPPROD"
						Aadd( aTail( aColsAux ), CriaVar( "C6_TPPROD", .T. ) )
					Otherwise
						If AllTrim( cField ) == "C6_REC_WT"
							Aadd( aTail( aColsAux ), 0 )
						ElseIf AllTrim( cField ) == "C6_ALI_WT"
							Aadd( aTail( aColsAux ), "SC6" )
						Else
							Aadd( aTail( aColsAux ), CriaVar( cField, .F. ) )
						EndIf
				EndCase
			Next nJ
			
			Aadd( aTail( aColsAux ), .F. )
			
			aCols := aClone( aColsAux )
			
			A410Produto(,.T.)

			aTail( aCols )[ nPosPrc ] := aItems[ nK ][ 3 ]

			If ExistTrigger( "C6_PRODUTO" )
				RunTrigger( 2, Len( aCols ) )
			EndIf

			A410MultT( "C6_QTDVEN", aItems[ nK ][ 2 ] )
			A410MultT( "C6_PRCVEN", aItems[ nK ][ 3 ] )

			aColsAux := aClone( aCols )
		Next k
	// Else
	// 	MsgAlert( "É necessário selecionar pelo menos um item do plano informado!", "Atenção" )
	// 	lRet := .F.
	Endif

	RestArea( aSvArea )

	FWFreeArray( aSvArea )
	FWFreeArray( aItems )
Return lRet

//-------------------------------------------------------------------------------------
/*/{Protheus.doc} SetItensCNB
Função que atribui os itens do plano ao grid do Contrato de venda

@param cAliasTmp, caracter, Alias da tabela temporário da grid de itens do plano
@param cMark, caracter, Marca que indica que o item está selecionado.

@author  Rodrigo G. Soares
@since   26/01/2023
/*/
//-------------------------------------------------------------------------------------
Static Function SetItensCNB( cAliasTmp, cMark )
    Local oModel		:= FWModelActive()
    Local oModelCNB	    := NIL
	Local nElem   		:= 0
	Local nI			:= 0
	Local aItems  		:= {}
	Local aArea    		:= GetArea()

	( cAliasTmp )->( DBGoTop() )
	While ( cAliasTmp )->( !Eof() )
		If ( cAliasTmp )->MARK == cMark
			AADD( aItems,{ ( cAliasTmp )->CODPRD, ( cAliasTmp )->DSCPRD, ( cAliasTmp )->UNIDMED,( cAliasTmp )->QTDPRD, ( cAliasTmp )->PRCTAB } )
		EndIf

		( cAliasTmp )->( DBSkip() )
	EndDo

	If oModel:Activate()
        oModelCNB	:= oModel:GetModel( 'CNBDETAIL' ) //--Planilha de itens do GCT 

		For nI := 1 To oModelCNB:Length()
			oModelCNB:GoLine( nI )
			If !oModelCNB:IsDeleted()
				oModelCNB:DeleteLine()
			EndIf		
		Next
		
		If oModelCNB:IsInserted()
			
			For nElem := 1 To Len( aItems )
				oModelCNB:GoLine( nElem )

				If oModelCNB:IsDeleted()
					oModelCNB:UnDeleteLine()
				EndIf
				oModelCNB:SetValue( "CNB_PRODUT", aItems[nElem][1] )
				oModelCNB:SetValue( "CNB_DESCRI", aItems[nElem][2] )
				oModelCNB:SetValue( "CNB_UM", aItems[nElem][3] )
				oModelCNB:SetValue( "CNB_QUANT", aItems[nElem][4] )
				oModelCNB:SetValue( "CNB_VLUNIT", aItems[nElem][5] )
			    
				If (oModelCNB:Length() < Len( aItems ) )
                	oModelCNB:AddLine()
            	EndIf  
        	Next nElem
			oModelCNB:GoLine( 1 )
		EndIF
    EndIf

	RestArea( aArea )

	FWFreeArray( aArea )
	FWFreeArray( aItems )

Return NIL
