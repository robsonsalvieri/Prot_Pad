#Include "loca229j.ch"
#INCLUDE 'TOTVS.CH'
#include 'FWMVCDEF.CH'
#INCLUDE 'FWEditPanel.CH'

/*/{Protheus.doc} MODELDEF
Definicão do modelo de Troca de Bens Quantificaveis no Romaneio de Expedição
@type function
@version 24.10 
@author Alexandre Circenis
@since 2/12/2025
@return variant, Modelo do romaneio
/*/
STATIC FUNCTION MODELDEF()
Local oModel   := MPFormModel():New( 'LOCA229J', /*bPreValidacao*/, /*bPosValidacao*/ , /*bCommit*/, /*bCancel*/ )
Local oStruFQT := FWFormStruct( 1, 'FQU', /*bAvalCampo*/,/*lViewUsado*/ )
Local oStruFQ5 := FWFormStruct( 1, 'FQ5', /*bAvalCampo*/,/*lViewUsado*/ )
Local oStruFH2 := FWFormStruct( 1, 'FH2', /*bAvalCampo*/,/*lViewUsado*/ )

oStruFQ5:AddField( STR0001, ' ', 'B1_DESC', 'C', TamSx3("B1_DESC")[1], 0, , , {}, .F.)   //'Descricao'
oStruFQ5:AddField(STR0002, ' ', 'QTDNEW', 'N',TamSx3("FPA_QUANT")[1],TamSx3("FPA_QUANT")[2], , , {}, .F.)   //'Separada'

oStruFQ5:SetProperty('B1_DESC'   , MODEL_FIELD_INIT,{|| Posicione("SB1",1,xFilial("SB1")+FQ5->FQ5_XPROD,"B1_DESC")} )
oStruFQ5:SetProperty('QTDNEW' , MODEL_FIELD_INIT,{||FQ5->FQ5_XQTD} )

oStruFH2:AddField(STR0003, ' ', 'ITEM', 'C', 3, 0, , , {}, .F.) //"Item"


// Adiciona ao modelo uma estrutura de formulário de edição por campo
oModel:AddFields( 'FQTMASTER', /*cOwner*/, oStruFQT, /*bPreValidacao*/, /*bPosValidacao*/, /*bCarga*/ )

// Adiciona ao modelo uma estrutura de formulário de edição por Grid
oModel:AddGrid( 'FQ5PAT', 'FQTMASTER', oStruFQ5, /*bPreValidacao*/, /*bPosValidacao*/, /*bCarga*/ )
oModel:AddGrid( 'FH2QTD', 'FQ5PAT', oStruFH2, /*bPreValidacao*/, /*bPosValidacao*/, /*bCarga*/ )

oModel:GetModel( 'FQ5PAT' ):SetDescription(STR0004)  //STR0001 //'Itens do Romaneio'
oModel:GetModel( 'FH2QTD' ):SetDescription(STR0005)  //'Itens do Romaneio' //'ID dos Quantificaveis'
//Setando a chave primária da rotina
oModel:SetRelation( 'FQ5PAT', { { 'FQ5_FILIAL', 'xFilial("FQ5")' } ,{"FQ5_XROMAN","FQU_NUM"},{'FQ5_STATUS', "'6'"}}, FQ5->( IndexKey( 22 ) ) )
oModel:SetRelation( 'FH2QTD', { { 'FH2_FILIAL', 'xFilial("FH2")' },{'FH2_AS','FQ5_AS'} }, FH2->( IndexKey( 1 ) ) )

oModel:GetModel( 'FQ5PAT'):SetLoadFilter( , " EXISTS ( SELECT B1_COD FROM "+ RetSqlName("SB1") + " SB1 INNER JOIN "+ RetSqlName("SBM") + " SBM ON BM_FILIAL = '"+xFilial("SBM")+"' and BM_GRUPO = B1_GRUPO and BM_XACESS = '3' and SBM.D_E_L_E_T_ = ' ' WHERE B1_FILIAL = '"+xFilial('SB1')+"' and B1_COD = FQ5_XPROD and SB1.D_E_L_E_T_ = ' ')" )   

oModel:GetModel( 'FQ5PAT' ):SetNoInserLine(.T.)
oModel:GetModel( 'FQ5PAT' ):SetNoDeleteLine(.T.)

oModel:GetModel('FQ5PAT'):SetOptional(.T.)
oModel:GetModel('FH2QTD'):SetOptional(.T.)
// Liga a validação da ativacao do Modelo de Dados
oModel:SetVldActivate({|oModel| Loca229jVm(oModel)})

oModel:SetOnlyQuery('FQ5PAT', .T.)
oModel:SetOnlyQuery('FH2QTD', .T.)
oModel:SetOnlyQuery('FQTMASTER', .T.)
oModel:GetModel('FQTMASTER'):SetOnlyView()
oModel:GetModel('FQ5PAT'):SetLPost({|| LOCA229JQ5()})
oModel:GetModel("FH2QTD"):SetLPre({|oGrid,nLinha,cAcao| Loca259LPV(oGrid,nLinha,cAcao)})

Return oModel


/*/{Protheus.doc} ViewDef
Define a View  de Troca de Bens Quantificaveis
@type function
@version 24.10 
@author Alexandre Circenis
@since 2/12/2025
@return variant, Retorna a view da demanda
/*///-------------------------------------------------------------------
Static Function ViewDef()
// Cria um objeto de Modelo de Dados baseado no ModelDef do fonte informado
Local oModel   := FWLoadModel( 'LOCA229J' )
Local oStruFQT := FWFormStruct( 2, 'FQU', {|cCampo| cCampo $ "FQU_NUM    FQU_PROJET FQU_OBRA   FQU_DESC   "},/*lViewUsado*/ )
Local oStruFQ5 := FWFormStruct( 2, 'FQ5', {|cCampo| cCampo $ "FQ5_AS     FQ5_XPROD  FQ5_XQTD    "},/*lViewUsado*/ )
Local oStruFH2 := FWFormStruct( 2, 'FH2', {|cCampo| cCampo $ "FH2_CODBEM FH2_NOMBEM "}/*bAvalCampo*/,/*lViewUsado*/ )
Local oView
Local cPictQtd  := X3Picture("FQ5_XQTD")

oStruFQ5:AddField("B1_DESC"   , '003 ', STR0001, STR0006, {}, "G", "@!" ,/*bPictVar*/,/*cLookUp*/,.F./*lCanChange*/,"1"/*cFolder*/)   //'Descricao'
oStruFQ5:AddField("QTDNEW"    , '005 ', STR0002, STR0007, {}, "G", cPictQtd ,/*bPictVar*/,/*cLookUp*/,.F./*lCanChange*/,"1"/*cFolder*/)   //'Separada'

oStruFQ5:SetProperty("FQ5_AS"    , MVC_VIEW_CANCHANGE, .F.)
oStruFQ5:SetProperty("FQ5_XPROD" , MVC_VIEW_CANCHANGE, .F.)
oStruFQ5:SetProperty("FQ5_XQTD"  , MVC_VIEW_CANCHANGE, .F.)
oStruFQ5:SetProperty("FQ5_AS"     , MVC_VIEW_ORDEM, '001')
oStruFQ5:SetProperty("FQ5_XPROD"  , MVC_VIEW_ORDEM, '002')
oStruFQ5:SetProperty("FQ5_XQTD"   , MVC_VIEW_ORDEM, '004')

oStruFQT:SetProperty("FQU_NUM", MVC_VIEW_GROUP_NUMBER, " " )
oStruFQT:SetProperty("FQU_PROJET", MVC_VIEW_GROUP_NUMBER, " ")
//oStruFQT:SetProperty("FQU_DESC", MVC_VIEW_GROUP_NUMBER, " ")
oStruFQT:SetProperty("FQU_OBRA", MVC_VIEW_GROUP_NUMBER, " ")

// Cria o objeto de View
oView := FWFormView():New()

// Define qual o Modelo de dados será utilizado
oView:SetModel( oModel )

oStruFH2:AddField("ITEM", '01 ', STR0008, STR0008, {}, "G", "@!" ,/*bPictVar*/,/*cLookUp*/, .F./*lCanChange*/,"1"/*cFolder*/) //'Item'

//Adiciona no nosso View um controle do tipo FormFields(antiga enchoice)
oView:AddField( 'VIEW_FQT', oStruFQT, 'FQTMASTER' )
oView:AddGrid( 'VIEW_FQ5', oStruFQ5, 'FQ5PAT' )
oView:AddGrid( 'VIEW_FH2', oStruFH2, 'FH2QTD' )

oView:addIncrementField("VIEW_FH2","ITEM")

oView:EnableTitleView('VIEW_FQ5',  STR0009) //"A.S. Devolvidas"
oView:EnableTitleView('VIEW_FH2',  STR0010) //"I.D. Retornados"

oView:AddOtherObject('LeituraDEL', {|oPanel,oView| LOCA229JCD(oPanel, 'FQ5PAT', 'FH2QTD')})
oView:AddOtherObject('LeituraINS', {|oPanel,oView| LOCA229JCI(oPanel, 'FQ5PAT', 'FH2QTD')})
oView:EnableTitleView('LeituraDEL',  "Remover")
oView:EnableTitleView('LeituraINS',  "Adicionar") 

oView:SetViewProperty('FQ5PAT', 'GRIDSEEK'  , {.T.})
oView:SetViewProperty('FQ5PAT', 'GRIDFILTER', {.T.})
oView:SetViewProperty('FH2QTD', 'GRIDSEEK'  , {.T.})
oView:SetViewProperty('FH2QTD', 'GRIDFILTER', {.T.})
// Altura das Linhas
oView:SetViewProperty("*", "GRIDROWHEIGHT", {20})

// Criar um 'box' horizontal para receber algum elemento da view
oView:CreateHorizontalBox( 'CABEC' , 20 )
oView:CreateHorizontalBox( 'ITENS' , 80 )
oView:CreateVerticalBox('FQ5IT',60,'ITENS')
oView:CreateVerticalBox('IDS',40,'ITENS')
oView:CreateHorizontalBox( 'FH2IT' , 80 , 'IDS')

oView:CreateHorizontalBox( 'CODBAR' , 20 , 'IDS')
oView:CreateVerticalBox('ID_DEL',50,'CODBAR')
oView:CreateVerticalBox('ID_INS',50,'CODBAR')

// Relaciona o ID da View com o 'box' para exibicao
oView:SetOwnerView( 'VIEW_FQT', 'CABEC' )
oView:SetOwnerView( 'VIEW_FQ5', "FQ5IT" )
oView:SetOwnerView( 'VIEW_FH2', 'FH2IT' )
oView:SetOwnerView( 'LeituraDEL', 'ID_DEL' )
oView:SetOwnerView( 'LeituraINS', 'ID_INS' )

oView:SetViewAction("BUTTONOK", { |oView| LOCA229JPR( oView ) } )
//Definindo que não irá usar o "Salvar e Criar Novo"
oView:SetCloseOnOk({|| .T.})
oView:EnableControlBar(.T.)
oView:SetProgressBar(.T.)
oView:setUpdateMessage(STR0012,STR0011)  //"Processo finalizado com sucesso"

Return oView


/*/{Protheus.doc} LOCA229JCD
Leitura do Codigo do Bem para excluir bens na lista
*** Atenção Função usada tembem no LOCA259J ***
@type function
@version 25.10  
@author Alexandre Circenis
@since 4/1/2025
@param oPanel, object, Panel da Grid
@param cGrid, character, Nome da Grid que vai ser marcada/desmarcada
/*/
Function LOCA229JCD(oPanel, cGrid, cDest)
Local oSayCodBar		:= Nil													//objeto say codigo de barras
Local oGetCodBar		:= Nil													//objeto get codigo de barras
Local cGetCodBar		:= Space(Max(TamSx3("T9_CODBEM")[1], TamSx3("T9_BARCODE")[1]))

	//Say Codigo de Barras
	oSayCodBar := tSay():New( 17, 5, {|| STR0013}, oPanel,/*pict*/,/*fonte*/,,,, .T., CLR_BLUE,, 50, 10)  //"Código de Barras:"
	//Get Codigo de Barras
	oGetCodBar := TGet():New( 15, 60, {|u| If(PCount() > 0, cGetCodBar := u, cGetCodBar)}, oPanel,;								
									80, 10, "@!", { || .T. } ,,,,,,.T.,,, {|| },,,, .F.,,,)				

	//Perda de foco do campo Codigo de Barras
	oGetCodBar:bLostFocus := {|| IIF(LOCA229JPC(@cGetCodBar, oGetCodBar, cGrid, cDest, .T.), .T.,.F.)}
	
Return()


/*/{Protheus.doc} LOCA229JCI
Leitura do Codigo do Bem para incluir bens na lista
*** Atenção Função usada tembem no LOCA259J ***
@type function
@version 25.10  
@author Alexandre Circenis
@since 4/1/2025
@param oPanel, object, Panel da Grid
@param cGrid, character, Nome da Grid que vai ser marcada/desmarcada
/*/
Function LOCA229JCI(oPanel, cGrid, cDest)
Local oSayCodBar		:= Nil													//objeto say codigo de barras
Local oGetCodBar		:= Nil													//objeto get codigo de barras
Local cGetCodBar		:= Space(Max(TamSx3("T9_CODBEM")[1], TamSx3("T9_BARCODE")[1]))

	//Say Codigo de Barras
	oSayCodBar := tSay():New( 17, 5, {|| STR0013}, oPanel,/*pict*/,/*fonte*/,,,, .T., CLR_BLUE,, 50, 10)  //"Código de Barras:"
	//Get Codigo de Barras
	oGetCodBar := TGet():New( 15, 60, {|u| If(PCount() > 0, cGetCodBar := u, cGetCodBar)}, oPanel,;								
									80, 10, "@!", { || .T. } ,,,,,,.T.,,, {|| },,,, .F.,,,)				

	//Perda de foco do campo Codigo de Barras
	oGetCodBar:bLostFocus := {|| IIF(LOCA229JPC(@cGetCodBar, oGetCodBar, cGrid, cDest, .F.), .T.,.F.)}

Return()

/*/{Protheus.doc} LOCA229JPC
Busca o codigo informado no campo Codigo de Barra
Primeiro busca pelo codigo do Bem na grid
Se não encontrar busca pelo Codigo de Barra cadastrado no Campo B1_CODBAR
*** Atenção Função usada tembem no LOCA259J ***
@type function
@version 25.10
@author Alexandre Circenis
@since 13/11/2025
@param cCodSearch, character, Codigo Contido na campo Codigo de BArra
@param oGetCodBar, object, Objeto do Get do codigo de barra usado para retornar o foco e permitir informar novos codigo
@param cGrid, character, Nome do Grid base da busca
@param cDest, character, Nome do Grid de preenchimento
/*/
Function LOCA229JPC(cCodSearch, oGetCodBar, cGrid, cDest, lExcluir)
Local oModel := FWModelActive()
Local oGrid  := oModel:GetModel(cGrid)
Local oDest  := oModel:GetModel(cDest)
Local oView := FWViewActive() 
Local aSaveLines := FWSaveRows()
Local lContinua  := .T.

    if Empty(cCodSearch)
        Return
    endif

	ST9->(dbSetOrder(1))
	if !ST9->(dbSeek(xFilial("ST9")+AllTrim(cCodSearch))) // Bem 
		cCodSearch := Padr(Alltrim(cCodSearch), TamSx3("T9_BARCODE")[1])
		ST9->(dbSetOrder(18))
		if !ST9->(dbSeek(cCodSearch+xFilial("ST9"))) // Codigo de barras da ST9
			lContinua := .F.
			Help(" ",1,"LOCA229J_01",, STR0021, 1, 0)    //"Código não encontrato na tabelas de Bens."
		endif
		ST9->(dbSetOrder(1))
	endif

	if lContinua

		cCodSearch := ST9->T9_CODBEM
	
		if lExcluir

			if !oDest:SeekLine({{"FH2_CODBEM",cCodSearch}})
				Help(" ",1,"LOCA229_11",,STR0022,1,0)   //"Bem não encontrado para ser removido"
				oGetCodBar:SetFocus()
				Return
			endif

		else
			if Empty(cCodSearch := Loca259EVC(cCodSearch, cGrid, cDest))
				oGetCodBar:SetFocus()
				Return
			endif
		endif

		if lExcluir

			if oDest:SeekLine({{"FH2_CODBEM",cCodSearch}},,.T.)
				oDest:DeleteLine()
			endif
			
			//Atualiza objetos de tela
			cCodSearch :=Space(Max(TamSx3("T9_CODBEM")[1], TamSx3("T9_BARCODE")[1]))
			oGetCodBar:Refresh()
			oGetCodBar:SetFocus()
			
		else

			oDest:SetNoInsertLine(.F.)
			if !Empty(oDest:GetValue("FH2_PROD",1))
				oDest:AddLine()
				oDest:GoLine(oDest:Length())
			endif

			oDest:LoadValue("FH2_FILIAL", xFilial("FH2"))
			oDest:LoadValue("FH2_AS", oGrid:GetValue("FQ5_AS"))
			oDest:LoadValue("FH2_PROD", oGrid:GetValue("FQ5_XPROD"))
			oDest:LoadValue("FH2_CODBEM", cCodSearch)
			oDest:LoadValue("FH2_NOMBEM", Posicione("ST9",1,xFilial("ST9")+cCodSearch, "T9_NOME"))
			oDest:LoadValue("FH2_CONTRA", oGrid:GetValue("FQ5_SOT"))
			oDest:LoadValue("FH2_OBRA", oGrid:GetValue("FQ5_OBRA"))
			oDest:LoadValue("FH2_DESPRO", Posicione("SB1",1,xFilial("SB1")+oGrid:GetValue("FQ5_XPROD"),"B1_DESC"))
			oDest:SetNoInsertLine(.T.)

			oGrid:SetValue("QTDNEW", oGrid:GetValue("QTDNEW")+1 )

			//Atualiza objetos de tela
			cCodSearch := Space(Max(TamSx3("T9_CODBEM")[1], TamSx3("T9_BARCODE")[1]))	
			oGetCodBar:Refresh()
			oGetCodBar:SetFocus()
		EndIf
		FwRestRows(aSaveLines)
		oView:Refresh()
	EndIf

Return


/*/{Protheus.doc}  LOCA229JPR
Realiza o processamento do Model trocando os bens na FH2
*** Atenção Função usada tembem no LOCA259J ***
@type function
@version 25.10 
@author Alexandre Circenis
@since 4/1/2025
@param oView, object, Modelo dados processado
@return variant, Indica se a troca foi realizada com sucesso (.T.)
/*/
Function LOCA229JPR(oView)
Local oGridPAT := oView:GetModel("FQ5PAT")
Local oGridFH2 := oView:GetModel("FH2QTD")
Local aAlteradas := {}
Local nX
Local aArea := GetArea()
Local nY
Local lOk := .T.

PRIVATE nTpAce	:= 0
PRIVATE cServ   := 'L' // Private usada no aceite da A.S.
//PRIVATE NTOTMIN := 0						// PARA RETORNAR O NUMERO DE MINUTAS CRIADAS
private lImplemento := LOCA059B1("FQG_FILIAL", "FQG") .and. GETMV("MV_NG1LOC",,.F.)
Private cLocErro    := ""
Private lLocAuto    := .T.


	BEGIN TRANSACTION

	// Trocar e/ou separar o Grid de Maquinas Patrimonial
	aAlteradas := oGridPat:GetLinesChanged(MODEL_GRID_LINECHANGED_ALL)

	For nX := 1 to Len(aAlteradas)

		oGridPat:Goline(aAlteradas[ nX])
		FQ5->(dbGoTo(oGridPat:GetDataID()))

		if !Empty(oGridPat:GetValue('QTDNEW')) // Marcado realizar a separação "ACEITE"

			FPA->(dbSetOrder(3))
			FPA->(dbSeek(xFilial("FPA")+oGridPat:GetValue("FQ5_AS")))
			// Preparar a gravação de status do bem 
			For nY := 1 to oGridFH2:Length()
			
				oGridFH2:Goline( nY) // Vai para a linha do bem a ser processado

				if oGridFH2:IsDeleted() // Linha Deletada realizar o estorno do bem 

					if !Empty(oGridFH2:GetDataID(nY)) // Se Estava Gravada deletar e estornar a movientação

						LOCA229JES( oGridFH2:GetValue("FH2_CODBEM"), FPA->FPA_AS ) // Estornar a ultima movimentação
						FH2->( dbGoto( oGridFH2:GetDataID(nY) ) ) // Buscar o Item 
						RecLock("FH2", .F.) 
						dbDelete()
						FH2->(msUnlock())

					endif
					
				elseif oGridFH2:IsInserted() // Linha Inserida

					ST9->(dbSetOrder(1))
					ST9->(dbSeek(xFilial("ST9")+oGridFH2:GetValue("FH2_CODBEM")))
					FQD->(dbSetOrder(1))
					if FQD->(DBSEEK(XFILIAL("FQD")+ST9->T9_STATUS))
						if FQD->FQD_STAREN == "00"
							FQD->(DBSEEK(XFILIAL("FQD")))
							while !FQD->(EOF())  .AND. FQD->FQD_FILIAL = xFilial("FQD") .and.  FQD->FQD_STAREN <> "10" 				// STATUS DE GERAR CONTRATO
								FQD->(DBSKIP())
							enddo
							if FQD->FQD_STAREN == "10"
								LOCXITU21(ST9->T9_STATUS, FQD->FQD_STATQY, FPA->FPA_PROJET, "", "", ,'10')
								RecLock("ST9",.F.)
								ST9->T9_STATUS := FQD->FQD_STATQY
								ST9->(MSUNLOCK())
							endif
						endif
					endif

					//Gravar FH2
					FH2->(RecLock("FH2",.T.))
					FH2->FH2_FILIAL := oGridFH2:GetValue("FH2_FILIAL")
					FH2->FH2_AS     := oGridFH2:GetValue("FH2_AS")
					FH2->FH2_CONTRA := oGridFH2:GetValue("FH2_CONTRA")
					FH2->FH2_OBRA   := oGridFH2:GetValue("FH2_OBRA")
					FH2->FH2_PROD   := oGridFH2:GetValue("FH2_PROD")
					FH2->FH2_CODBEM := oGridFH2:GetValue("FH2_CODBEM")
					FH2->FH2_ROMREM := FQ5->FQ5_XROMAN
					FH2->(MsUnLock())

				endif
			next nY

		endif

	next

	END TRANSACTION

	RestArea(aArea)

//	if !lOk
//		oModel:lUpdateMsg := .F. /// Se tiver erro não apresentar mensagem de sucesso 
//	endif

RETURN lOk

/*/{Protheus.doc} LOCA229JQ5
Valida a linha da FQ5
*** Atenção Função usada tembem no LOCA259J ***
@type function
@version 25.10
@author Alexandre Circenis
@since 16/01/2026
@return variant,.T. se a linha está valida
/*/
Function LOCA229JQ5()
Local lRet := .T.
Local oModel   := FWModelActive()

	if FwFldGet("FQ5_XQTD") <> FwFldGet("QTDNEW")
		oModel:SetErrorMessage("","","","","LOCA229J_01",STR0015+Alltrim(Str(FwFldGet("FQ5_XQTD") - FwFldGet("QTDNEW"),9,0)+ STR0014)) 
		lRet := .F.
	endif

Return lRet


/*/{Protheus.doc} LOCA229JVM
Valida se o Model de troca de itens poderá ser ativado
@type function
@version 25.10
@author Alexandre Circenis
@since 19/01/2026
@param oModel, object, Model de troca de itens
@return variant, Retorna .T. se o model puder ser ativado
/*/
Function LOCA229JVM(oModel)
Local lRet := .T.

	if FQU->FQU_STATUS = '1'
		oModel:SetErrorMessage("","","","","LOCA229J_02",STR0018)  //"Romaneio está vazio, não há itens para alterar"
		lRet := .F.
	endif

	if lRet .and. FQU->FQU_STATUS = "6"
		oModel:SetErrorMessage("","","","","LOCA229J_04",STR0020)    //"O romaneio já possui NF ou Pedido emitidos, portanto não é possível realizar alterações nos itens."
		lRet := .F.
	endif

	// Embarque já fechado não proseguir
	if lRet .and. FQU->FQU_FCHEMB = "1" 
		oModel:SetErrorMessage("","","","","LOCA229J_03",STR0019)   //"Romaneio já teve o embarque fechado não será possivel alterar os itens!"
		lRet := .F.
	endif

	if lRet
		aFH2 := LOCA229JH2(FQU->FQU_NUM)
		if aFH2[1] = 0 // Não há registros na FH2 
			oModel:SetErrorMessage("","","","","LOCA229J_04",STR0023) //"Não há Bens Quantificaveis aptos para realizar a atualização de ID."
			lRet := .F.  
		endif
	endif

RETURN lRet


/*/{Protheus.doc} LOCA229JES
Estorna o status da ST9 e deleta a movimentação na FQ4
*** Atenção Função usada tembem no LOCA259J ***
@type function
@version 25.10  
@author Alexandre Circenis
@since 23/03/2026
@param cBem, character, Codigo do Bem para se estornado
@Param cAS, character, Codigo da A.S. que está sendo processada sendo estornado

/*/
Function LOCA229JES( cBem, cAS )
Local aArea := GetArea()
Local cQuery := ""
Local aBind := {}

	ST9->( DBSETORDER(1) )
	IF  ST9->( DBSEEK( XFILIAL("ST9")+ cBem))
	
		cQuery += "SELECT R_E_C_N_O_ REG"
		cQuery += " FROM "+RetSqlName("FQ4")
		cQuery += " WHERE FQ4_FILIAL = '"+xFilial("FQ4")+"'"
		cQuery += "  AND FQ4_CODBEM =  ? "
		Aadd( aBind, { cBem, "S"})
		cQuery += "  AND FQ4_AS = ? "
		Aadd( aBind, { cAS, "S"})
		cQuery += "  AND FQ4_STATUS  = ? "
		Aadd( aBind, { ST9->T9_STATUS, "S"})
		cQuery += "  AND D_E_L_E_T_ =  ' '"

		cQuery := ChangeQuery(cQuery)
		cQuery := LocXGerQry(cQuery, aBind)

		MPSysOpenQuery( cQuery, "TRBFQ4")

		if !TRBFQ4->(Eof())

			FQ4->(dbGoto(TRBFQ4->REG))

			RecLock("ST9", .F.)
			ST9->T9_STATUS :=  FQ4->FQ4_STSOLD
			ST9->(msUnLock())

			RecLock("FQ4",.F.)
			FQ4->(dbDelete())
			FQ4->(msUnLock())

		endif
	endif
	RestArea(aArea)

Return

/*/{Protheus.doc} LOCA259JH2
Avalia as cuantidades de itens do tipo Bem Quantaificavel que passiveis de manutenção dentro da Demanda.
Condições: 
O item da expedição deve estar separado
O item que que ser de um grupo que tenha o campo BM_XACESS = '3' (Bem Quantificavel)
Serão contatos o numero de ITens na FH2 

@type function
@version  25.10
@author Alexandre Circenis
@since 17/04/2026
@param cDemanda, character, Codigo da Demanda
@return variant, Array contendo O numero de registros da FH2 e o numero de registros da FH2 sem pedido gerado
/*/
Function LOCA229JH2(cRomaneio)
Local aRet := {0,0}
Local cQuery
Local aArea := GetArea()
Local aBindParam := {}


 	cQuery := " SELECT Count(*) TOTREG  "
	cQuery += " FROM " + RETSQLNAME("FQ5") + " FQ5 "
	cQuery += " INNER JOIN " + RETSQLNAME("SB1") + " SB1 "
	cQuery += " ON SB1.B1_FILIAL = '"+xFilial("SB1")+"' "
	cQuery += " AND SB1.D_E_L_E_T_ = ' '"
	cQuery += " AND SB1.B1_COD = FQ5.FQ5_XPROD "
	cQuery += " INNER JOIN " + RETSQLNAME("SBM") + " SBM "
	cQuery += " ON SBM.BM_FILIAL = '"+xFilial("SBM")+"' "
	cQuery += " AND SBM.D_E_L_E_T_ = ' ' "
	cQuery += " AND SBM.BM_GRUPO = SB1.B1_GRUPO "
	cQuery += " AND SBM.BM_XACESS = '3'"
	cQuery += " LEFT JOIN " + RETSQLNAME("FH2") + " FH2 "
	cQuery += " ON FH2.FH2_FILIAL = '"+xFilial("FH2")+"' "
	cQuery += " AND FH2.D_E_L_E_T_ = ' ' "
	cQuery += " AND FH2.FH2_AS = FQ5_AS "
    
    cQuery += " WHERE FQ5.FQ5_FILIAL = '"+xFilial("FQ5")+"' "
	cQuery += " AND FQ5.FQ5_STDEMA = '2' "
	cQuery += " AND FQ5.D_E_L_E_T_ = ' ' "
	cquery += " AND FQ5.FQ5_DEMAND > ' '"
	cQuery += " AND FQ5.FQ5_XROMAN = ? "
    Aadd( aBindParam, cRomaneio)
  
    cQuery := CHANGEQUERY(cQuery)
    MPSysOpenQuery(cQuery,"TRBFQ5",,,aBindParam)

	aRet[1] := TRBFQ5->TOTREG

	RestArea(aArea)

Return aRet
