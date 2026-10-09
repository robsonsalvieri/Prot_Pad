#Include 'Totvs.ch'
#Include "FWMBROWSE.CH"
#Include "FWMVCDEF.CH"
#Include "RWMAKE.CH"
#Include "TOPCONN.CH"
#Include "EST330A.ch"
#INCLUDE "FWMBROWSE.CH"

PUBLISH MODEL REST NAME EST330A RESOURCE OBJECT oRestEST330A

Static __aSM0    := {}

Function EST330A()
	Local oBrowse := FWMBrowse():New()
	Local lExecute  := FnVldCMod2()
	Local lAliasD4E := FwAliasInDic("D4E")

	If !lAliasD4E .Or. !lExecute
		Help('',1,'D4E',,STR0001,1,0) //Tabela D4E Não encontrada no dicionário de dados
		Return
	EndIf

	oBrowse:SetAlias("D4E")
	oBrowse:SetDescription(STR0002) //Roteiro do recálculo do custo médio
	oBrowse:SetMenuDef("EST330A")
	oBrowse:SetFilterDefault(" @ D4E_ORDEM = '001' ")
	oBrowse:SetAmbiente(.F.)
	oBrowse:SetWalkThru(.F.)
	//Função do Browser SMARTX 
	If hasSmartX()
		oBrowse:setSmartX()
	Endif 
	oBrowse:Activate()		
Return


Static Function MenuDef()
	Local aRotina := {}

	ADD OPTION aRotina TITLE STR0003 ACTION "VIEWDEF.EST330A" OPERATION 3 ACCESS 0 //Incluir
    ADD OPTION aRotina TITLE STR0004 ACTION "VIEWDEF.EST330A" OPERATION 2 ACCESS 0 //Visualizar
	ADD OPTION aRotina TITLE STR0005 ACTION "VIEWDEF.EST330A" OPERATION 4 ACCESS 0 //Alterar
    ADD OPTION aRotina TITLE STR0006 ACTION "VIEWDEF.EST330A" OPERATION 5 ACCESS 0 //Excluir
Return aRotina

Static Function ModelDef()
	Local bCommit := {|oModel| CommitScript(oModel)}
	Local oModel   := Nil
	Local cCusFil  := SuperGetMv("MV_CUSFIL", .F., "A")
	Local oStrC    := Nil
	Local oStrI    := Nil
	Local aRelacao := {}
	Local aSM0     := {}
	Local cCodEmp  := ''
	Local nI       := 0

	If cCusFil == 'E'
		oStrC := FWFormStruct(1, 'D4E', {|x| ALLTRIM(x) $ 'D4E_CODIGO, D4E_DESC, D4E_NUMEXE, D4E_ORDEM, D4E_ID, D4E_FILEXE, D4E_NUMITE'})

		oStrC:SetProperty('D4E_ORDEM', MODEL_FIELD_INIT, {|| "001"})
		oStrC:SetProperty('D4E_FILEXE', MODEL_FIELD_INIT, {|| FWCompany()})
		oStrC:SetProperty('D4E_ID', MODEL_FIELD_INIT, {|| SubStr(FWUUIDV1(), 1, 20)})
		oStrC:SetProperty('D4E_NUMITE', MODEL_FIELD_INIT, {|| 1})
		
		oModel := MPFormModel():New('EST330A')
		oModel:AddFields('CABEC',, oStrC)
		oModel:GetModel("CABEC"):SetPrimaryKey({"D4E_CODIGO"})
	Else
		oStrC := FWFormStruct(1, 'D4E', {|x| ALLTRIM(x) $ 'D4E_CODIGO, D4E_DESC, D4E_NUMEXE'})
		oStrI := FWFormStruct(1, 'D4E', {|x| ALLTRIM(x) $ 'D4E_ORDEM, D4E_ID, D4E_FILEXE, D4E_NUMITE'})
		aRelacao := { ;
	{'D4E_FILIAL', 'xFilial("D4E")'}, ;
		{'D4E_CODIGO' , 'D4E_CODIGO'} ;
	}
	
		oModel := MPFormModel():New('EST330A',,,bCommit)

	If Empty(__aSM0)
		cCodEmp := FWCompany()
		aSM0    := FWLoadSM0(.T.,,.T.)

		For nI := 1 To Len(aSM0)
			If aSM0[nI, 1] == cEmpAnt .And. aSM0[nI, 10] .And. aSM0[nI, 11]
				AAdd(__aSM0, aSM0[nI])
			EndIf
		Next
	EndIf

	//--------------------------------------
	//		Adiciona campos ao Grid
	//--------------------------------------
	oStrI:AddField('+', "+", 'ARRWUP', 'BT' , 1 , 0, {|| .T.} ,,,, {||"UP3"},, .T., .T.)
  	oStrI:AddField('-', "-",'ARRWDOWN','BT' , 1 , 0, {|| .T.} ,,,, {||"DOWN3"},, .T., .T.)

	//------------------------------------------------------
	//		Adiciona o componente de formulario no model 
	//------------------------------------------------------
	oModel:AddFields('CABEC',, oStrC)
	oModel:AddGrid('ITEM', 'CABEC', oStrI)

	//--------------------------------------
	//		Configura o modelo
	//--------------------------------------
	oModel:GetModel("CABEC"):SetPrimaryKey({"D4E_CODIGO"})
	oModel:SetRelation('ITEM', aRelacao, D4E->(IndexKey(1)))
	EndIf
Return(oModel)


Static Function ViewDef()
	Local oView := FWFormView():New()
	Local oStrC := Nil
	Local oStrI := Nil
	Local oModel := ModelDef()
	Local cCusFil  := SuperGetMv("MV_CUSFIL", .F., "A")

	If cCusFil == 'E'
		oStrC := FWFormStruct(2, 'D4E', {|x| ALLTRIM(x) $ 'D4E_CODIGO, D4E_DESC, D4E_NUMEXE, D4E_FILEXE'})

		oStrC:SetProperty('D4E_FILEXE', MVC_VIEW_CANCHANGE, .F.)

		oView:SetModel(oModel)
		oView:SetCloseOnOk({|| .T.})

		oView:AddField('VIEW_SUP', oStrC, 'CABEC')
		oView:CreateHorizontalBox('SUPERIOR', 100)
		oView:SetOwnerView('VIEW_SUP', 'SUPERIOR')
		oView:SetViewProperty('VIEW_SUP', 'SETCOLUMNSEPARATOR', {10})
	Else
		oStrC := FWFormStruct(2, 'D4E', {|x| ALLTRIM(x) $ 'D4E_CODIGO, D4E_DESC, D4E_NUMEXE'})
		oStrI := FWFormStruct(2, 'D4E', {|x| ALLTRIM(x) $ 'D4E_ORDEM,D4E_FILEXE, D4E_NUMITE'})
	//--------------------------------------
	//		Associa o View ao Model
	//--------------------------------------
	oView:SetModel(oModel)
	oView:SetCloseOnOk({|| .T.})

	//--------------------------------------
	//		Adiciona campos ao Grid
	//--------------------------------------
	oStrI:AddField("ARRWUP",  '01',"+","+", {} , 'BT' ,'@BMP',,,.F.,,,,,, .T. )
	oStrI:AddField("ARRWDOWN",'02',"-","-", {} , 'BT' ,'@BMP',,,.F.,,,,,, .T. )
	
	//--------------------------------------
	//		Insere os componentes na view
	//--------------------------------------
	oView:AddField('VIEW_SUP', oStrC, 'CABEC')
	oView:AddGrid('VIEW_INF', oStrI, 'ITEM')
	
	//--------------------------------------
	//		Cria os Box's
	//--------------------------------------
	oView:CreateHorizontalBox('SUPERIOR', 20)
	oView:CreateHorizontalBox('INFERIOR', 80)

	//--------------------------------------
	//		Associa os componentes
	//--------------------------------------
	oView:SetOwnerView('VIEW_SUP', 'SUPERIOR')
	oView:SetOwnerView('VIEW_INF', 'INFERIOR')

	//--------------------------------------
	//		Adiciona o campo com incremental
	//--------------------------------------
	oView:AddIncrementField('VIEW_INF', 'D4E_ORDEM' )

	//--------------------------------------
	//		Seta propriedade na View
	//--------------------------------------
	oView:SetViewProperty('VIEW_SUP', 'SETCOLUMNSEPARATOR', {10})
    oView:SetViewProperty('VIEW_INF', 'GRIDDOUBLECLICK', {{|oView, cField, nLineGrid, nLineModel| ArrowMove(oView, cField, nLineGrid, nLineModel)}})
	EndIf
Return(oView)

/*/{Protheus.doc} ArrowMove
    Ação de clique dos botões cima/baixo
    @type  Static Function
    @author g.moreira
    @since 29/07/2024
/*/
Static Function ArrowMove(oViewGrd, cField, nLineGrid, nLineModel)
    Local oMdlGrd := oViewGrd:GetModel()
    Local nLinAtu := oMdlGrd:GetLine()
    Local nOrdAtu := oMdlGrd:GetValue("D4E_ORDEM", nLinAtu)
	Local nOperation := oMdlGrd:GetOperation()

    If !(cField $ 'ARRWDOWN|ARRWUP')
        Return .T.
    EndIf

	If !(nOperation == MODEL_OPERATION_INSERT .Or. nOperation == MODEL_OPERATION_UPDATE)
		Return .T.
	EndIf

    If cField == 'ARRWUP'
		If nLinAtu > 1
        	oMdlGrd:LoadValue("D4E_ORDEM", oMdlGrd:GetValue("D4E_ORDEM", nLinAtu-1)) // Seta o valor da linha de cima para atual
			oMdlGrd:GoLine(nLinAtu-1) // Move o posicionamento para a linha de cima
			oMdlGrd:LoadValue("D4E_ORDEM", nOrdAtu) // Seta o valor da Ordem no qual foi solicitada a movimentação
			oMdlGrd:LineShift(nLinAtu ,nLinAtu - 1) // Realiza a troca de linhas
			oMdlGrd:GoLine(nLinAtu - 1)
		EndIf
    Else
        If nLinAtu < oMdlGrd:Length()
			oMdlGrd:LoadValue("D4E_ORDEM", oMdlGrd:GetValue("D4E_ORDEM",nLinAtu+1)) // Seta o valor da linha de baixo para atual
			oMdlGrd:GoLine(nLinAtu+1) // Move o posicionamento para a linha de baixo
			oMdlGrd:LoadValue("D4E_ORDEM", nOrdAtu) // Seta o valor da Ordem no qual foi solicitada a movimentação
			oMdlGrd:GoLine(nLinAtu)
			oMdlGrd:LineShift(nLinAtu,nLinAtu + 1) // Realiza a troca de linhas
			oMdlGrd:GoLine(nLinAtu)
		EndIf
    EndIf

    oViewGrd:Refresh() 

Return

/*/{Protheus.doc} CommitScript
	Atualiza o campo ORDEM de acordo com o especificado em tela e pula as linhas excluídas
	@type  Static Function
	@author g.moreira
	@since 30/07/2024
/*/
Static Function CommitScript(oModel)
	Local oModelGrid := oModel:GetModel('ITEM')
	Local nOperation := oModel:GetOperation()
	Local nLine      := 0
	Local nDeleted   := 0
	Local nOrdem     := 0
	Local cOrdem     := ''

	If nOperation == MODEL_OPERATION_INSERT .Or. nOperation == MODEL_OPERATION_UPDATE
		For nLine := 1 To oModelGrid:Length()
			oModelGrid:GoLine(nLine)
			If oModelGrid:IsDeleted()
				nDeleted++
			Else
				nOrdem := Val(oModelGrid:GetValue('D4E_ORDEM'))
				If nOrdem == 0
					nOrdem := nLine
				EndIf
				nOrdem -= nDeleted
				cOrdem := StrZero(nOrdem, 3)
				oModelGrid:LoadValue('D4E_ORDEM', cOrdem)
				If oModelGrid:GetDataID() == 0
					oModelGrid:LoadValue('D4E_ID', SubStr(FWUUIDV1(), 1, 20))
				EndIf
			EndIf
		Next
	EndIf
	FWFormCommit(oModel)
Return .T.

/*/{Protheus.doc} SM0FiltEmp
	Filtra as filiais da empresa logada
	@type  Function
	@author g.moreira
	@since 30/07/2024
	/*/
Function E330FiltEmp(cCodFil)
	Local lShow   := .F.
	Local nSize   := FWSizeFilial()
	Local cCodEmp := FWCompany()

	lShow := AScan(__aSM0, {|x| x[2] == SubStr(cCodFil, 1, nSize) .And. x[3] == cCodEmp}) > 0
	
Return lShow

/*/{Protheus.doc} EST330FVld
	Verifica se a filial informada faz parte da empresa logada
	@type  Function
	@author g.moreira
	@since 31/07/2024
	/*/
Function EST330FVld()
	Local cCodFil := FWFldGet('D4E_FILEXE')
	Local nSize   := FWSizeFilial()
	Local lRet    := .F.
	Local cCodEmp := FWCompany()

	lRet := AScan(__aSM0, {|x| x[2] == SubStr(cCodFil, 1, nSize) .And. x[3] == cCodEmp}) > 0
Return lRet

/*/{Protheus.doc} E330IniCod
	Inicializador padrão
	@type  Function
	@author user
	/*/
Function E330IniCod(cTab, cCpo)
	Local cRet := GetSxeNum(cTab,cCpo)

	While .T.
		(cTab)->(dbSetOrder(1))	// D4E_FILIAL + D4E_CODIGO
		If (cTab)->(dbSeek( xFilial(cTab) + cRet ))
			ConfirmSX8()
			cRet := GetSxeNum(cTab,cCpo)
			Loop
		Else
			Exit
		EndIf
	EndDo
Return cRet

//-------------------------------------------------------------------
/*/{Protheus.doc} oRestEST330A
Instância do FwRestModel 
@type  Class
@author Squad Entradas
@since 31/07/2024
/*/
//-------------------------------------------------------------------
Class oRestEST330A From FwRestModel	
	Method Activate()
	Method DeActivate()
	Method Seek()
	Method Skip()
EndClass

//-------------------------------------------------------------------
/*/{Protheus.doc} Activate
Ativa o modelo
@author Squad Entradas
@since 31/07/2024
/*/
//-------------------------------------------------------------------
Method Activate() Class oRestEST330A
    dbSelectArea("D4E")   
	dbSetOrder(1)
Return _Super:Activate()

//-------------------------------------------------------------------
/*/{Protheus.doc} DeActivate
Desativa o modelo
@author Squad Entradas
@since 31/07/2024
/*/
//-------------------------------------------------------------------
Method DeActivate() Class oRestEST330A
    D4E->(dbCloseArea())  
  
Return _Super:DeActivate()


//-------------------------------------------------------------------
/*/{Protheus.doc} Seek
Método responsável por buscar um registro em específico no alias selecionado.
Se o parâmetro cPK não for informado, indica que deve-se ser posicionado
no primeiro registro da tabela.
@param	cPK	PK do registro.
@return	lRet Indica se foi encontrado algum registro.
@author Squad Entradas
@since 31/07/2024
/*/
//-------------------------------------------------------------------
Method Seek(cPK) Class oRestEST330A
	Local lRet := .F.

	If Empty(cPK)		
		D4E->(DbGotop())
		lRet := !D4E->(Eof())
	Elseif !Empty(cPK)    
		If dbSeek(cPK)
			lRet := .T. 
		EndIf	
	EndIf

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} Skip
Pula registro
@author Squad Entradas
@since 31/07/2024
@param nSkip Indica a quantidade de registro para pular
@return lRet Indica se está no final da tabela
/*/
//-------------------------------------------------------------------
Method Skip(nSkip) Class oRestEST330A
	Local lRet := .F.

    D4E->(DbSkip(nSkip))
    lRet := !D4E->(Eof()) 

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} FnVldCMod2
Função para retornar o contúdo do parâmetro 'MV_FFREC2' Feature Flag
@author Leonardo Kichitaro
@since 17/03/2026
/*/
//-------------------------------------------------------------------
Function FnVldCMod2()
Return SuperGetMv("MV_FFREC2",.F.,.F.)
