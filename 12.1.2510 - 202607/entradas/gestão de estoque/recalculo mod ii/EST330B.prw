#Include 'Totvs.ch'
#Include "FWMBROWSE.CH"
#Include "FWMVCDEF.CH"
#Include "RWMAKE.CH"
#Include "TOPCONN.CH"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "APWIZARD.CH"
#INCLUDE "FWADAPTEREAI.CH"
#INCLUDE 'FWLIBVERSION.CH'
#Include "EST330B.ch"
#INCLUDE "FWMBROWSE.CH"
PUBLISH MODEL REST NAME EST330B RESOURCE OBJECT oRestEST330B

Function EST330B()
	Local oBrowse := FWMBrowse():New()
    Local nTamPar := TamSX3('D4F_CODPAR')[1]
    Local cParte1 := StrZero(99, nTamPar)
	Local lExecute  := FnVldCMod2()
	Local lAliasD4F := FwAliasInDic("D4F")

    If !lAliasD4F .Or. !lExecute
        Help('',1,'D4F',,STR0001,1,0) //Tabela D4F Não encontrada no dicionário de dados
        Return
    EndIf

    oBrowse:SetAlias("D4F")
    oBrowse:SetDescription(STR0002) //Cadastro de partes do custo
    oBrowse:SetMenuDef("EST330B")
    oBrowse:SetFilterDefault("@ D4F_CODPAR = '"+cParte1+"'")
    oBrowse:SetAmbiente(.F.)
    oBrowse:SetWalkThru(.F.)

    oBrowse:AddLegend("D4F->D4F_STATUS == '0' ","GRAY" ,STR0010) //Rascunho
    oBrowse:AddLegend("D4F->D4F_STATUS == '1' ","GREEN",STR0011) //Vigente
    oBrowse:AddLegend("D4F->D4F_STATUS == '2' ","RED"  ,STR0012) //Não vigente

	//Função do Browser SMARTX 
	If hasSmartX()
		oBrowse:setSmartX()
	Endif

	oBrowse:Activate()   
Return
Static Function MenuDef()
	Local aRotina := {}

	ADD OPTION aRotina TITLE STR0003 ACTION "VIEWDEF.EST330B" OPERATION 3 ACCESS 0 //Incluir
	ADD OPTION aRotina TITLE STR0004 ACTION "VIEWDEF.EST330B" OPERATION 2 ACCESS 0 //Visualizar
	ADD OPTION aRotina TITLE STR0005 ACTION "VIEWDEF.EST330B" OPERATION 4 ACCESS 0 //Alterar
    ADD OPTION aRotina TITLE STR0006 ACTION "VIEWDEF.EST330B" OPERATION 9 ACCESS 0 //Copia
    ADD OPTION aRotina TITLE STR0048 ACTION "E330BREVIS"      OPERATION 4 ACCESS 0 //Ativa/Desativa Revisão

Return aRotina

Static Function ModelDef()
	Local bCommit := {|oModel| CommitPart(oModel)}
	Local bPreVld := {|oModel| PreVld(oModel)}
	Local oModel  := MPFormModel():New('EST330B',,,bCommit)
	Local oStrC   := FWFormStruct(1, 'D4F', {|x| ALLTRIM(x) $ 'D4F_REVIS, D4F_DESCRI, D4F_STATUS'})
	Local oStrI  := FWFormStruct(1, 'D4F', {|x| ALLTRIM(x) $ 'D4F_CODPAR, D4F_TITULO, D4F_TIPO, D4F_ITEMC, D4F_CLVLR, D4F_STATUS'})
	Local aRelacao := { ;
	{'D4F_FILIAL', 'xFilial("D4F")'}, ;
	{'D4F_REVIS' , 'D4F_REVIS'} ;
	} 
	//------------------------------------------------------
	//		Adiciona o componente de formulario no model 
	//------------------------------------------------------
	oModel:AddFields('CABEC',, oStrC)
	oModel:AddGrid('ITEM', 'CABEC', oStrI)

	//--------------------------------------
	//		Configura o modelo
	//--------------------------------------
	oModel:GetModel("CABEC"):SetPrimaryKey({"D4F_REVIS"})
	oModel:GetModel("CABEC"):SetFldNoCopy({"D4F_STATUS"})
	oModel:SetRelation('ITEM', aRelacao, D4F->(IndexKey(1)))
	oModel:GetModel('ITEM'):SetUniqueLine({"D4F_CODPAR"})
	oModel:SetVldActivate(bPreVld)
	oModel:setActivate({ |oModel| onActivate(oModel)})
Return(oModel)
Static Function ViewDef()
	Local oView := FWFormView():New()
	Local oStrC := FWFormStruct(2, 'D4F', {|x| ALLTRIM(x) $ 'D4F_REVIS, D4F_DESCRI, D4F_STATUS'})
	Local oStrI := FWFormStruct(2, 'D4F', {|x| ALLTRIM(x) $ 'D4F_CODPAR, D4F_TITULO, D4F_TIPO, D4F_ITEMC, D4F_CLVLR'})
	Local oModel := ModelDef()

	//--------------------------------------
	//		Associa o View ao Model
	//--------------------------------------
	oView:SetModel(oModel)
	oView:SetCloseOnOk({|| .T.})

	//--------------------------------------
	//		Adiciona campos ao Grid
	//--------------------------------------
	
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
	oView:AddIncrementField('VIEW_INF', 'D4F_CODPAR' )

	//Defina apenas para visualizao qunado chamado pela funcao ativa/desativa revisao 
	If FWIsInCallStack("E330BREVIS")
		oView:SetOnlyView("VIEW_SUP", .T.)
		oView:SetOnlyView("VIEW_INF", .T.)
	EndIf

	//--------------------------------------
	//		Seta propriedade na View
	//--------------------------------------
	oView:SetViewProperty('VIEW_SUP', 'SETCOLUMNSEPARATOR', {10})
Return(oView)

/*/{Protheus.doc} PreVld
	Pré validação do modelo
	@type  Static Function
	@author g.moreira
	@since 15/08/2024
/*/
Static Function PreVld(oModel)
	Local lRet := .T.
	Local nOpc := oModel:GetOperation()

	If !FWIsInCallStack("E330BREVIS") .And.nOpc == MODEL_OPERATION_UPDATE
		If D4F->D4F_STATUS <> "0" //Rascunho
			lRet := .F.
			Help('',1,'PreVld',,STR0007,1,0) //Apenas revisões do custo em partes em rascunho podem ser alteradas.
		EndIf
	EndIf
Return lRet

/*/{Protheus.doc} CommitPart
	Na inclusão, cria a parte 99-outros automaticamente
	@type  Static Function
	@author g.moreira
	@since 30/07/2024
/*/
Static Function CommitPart(oModel)
	Local oModelGrid := oModel:GetModel('ITEM')
	Local oModelCab  := oModel:GetModel('CABEC')
	Local nOperation := oModel:GetOperation()
	Local cOutros    := Replicate("9", Len(D4F->D4F_CODPAR))
	Local nI

	If nOperation == MODEL_OPERATION_INSERT .AND. !oModel:IsCopy()
		oModelCab:LoadValue("D4F_REVIS", oModelCab:GetValue("D4F_REVIS"))
		oModelGrid:AddLine()
		oModelGrid:LoadValue("D4F_CODPAR", cOutros)
		oModelGrid:LoadValue("D4F_TITULO", "Outros")
	EndIf

	If FWIsInCallStack("E330BREVIS") .And. Type("cStatusNew") != "U"
		For nI := 1 To oModelGrid:Length()
			oModelGrid:GoLine(nI)
			oModelGrid:LoadValue("D4F_STATUS", cStatusNew)
		Next nI		
	EndIf

	FWFormCommit(oModel)
Return .T.

/*/{Protheus.doc} onActivate
	Inicializador do campo. Necessário para não gerar o erro
	erro no parâmetro FWFormModel: A estrutura principal obrigatoriamente não pode ser uma estrutura que não sofre modificações
	@type  Static Function
	@author g.moreira
	@since 30/07/2024
/*/
Static Function onActivate(oModel)
	//Só efetua a alteração do campo para inserção
	If oModel:GetOperation() == MODEL_OPERATION_INSERT .Or. oModel:IsCopy()
		FwFldPut("D4F_REVIS", E330IniSxe("D4F", "D4F_REVIS") , /*nLinha*/, oModel)
	ElseIf oModel:GetOperation() == MODEL_OPERATION_UPDATE .And. FWIsInCallStack("E330BREVIS") 
		FwFldPut("D4F_STATUS", cStatusNew , /*nLinha*/, oModel, .T., .T.)
	EndIf
return

/*/{Protheus.doc} E330CdPt
	Válida o código da parte.
	@type  Function
	@author g.moreira
	@since 15/08/2024
	/*/
Function E330CdPt()
	Local cCod    := ''
	Local lRet    := .T.
	Local cOutros := Replicate("9", Len(D4F->D4F_CODPAR))
	Local cStr    := ""

	FwFldPut('D4F_CODPAR', StrZero(Abs(Val(FWFldGet('D4F_CODPAR'))), 2))
	cCod := FWFldGet('D4F_CODPAR')

	If cCod == cOutros
		cStr := OemToAnsi(I18N(STR0008,{cOutros})) //O código #1[99]# é reservado para a parte "Outros". Informe outro código.
		lRet := .F.
		Help('',1,'CODPARTE',,cStr,1,0)
	EndIf

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} oRestEST330B
Instância do FwRestModel 
@type  Class
@author Squad Entradas
@since 31/07/2024
/*/
//-------------------------------------------------------------------
Class oRestEST330B From FwRestModel	
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
Method Activate() Class oRestEST330B
    dbSelectArea("D4F")   
	dbSetOrder(1)
Return _Super:Activate()

//-------------------------------------------------------------------
/*/{Protheus.doc} DeActivate
Desativa o modelo
@author Squad Entradas
@since 31/07/2024
/*/
//-------------------------------------------------------------------
Method DeActivate() Class oRestEST330B
    D4F->(dbCloseArea())  
  
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
Method Seek(cPK) Class oRestEST330B
	Local lRet := .F.

	If Empty(cPK)
		D4F->(DbGotop())
		lRet := !D4F->(Eof())
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
Method Skip(nSkip) Class oRestEST330B
	Local lRet := .F.

    D4F->(DbSkip(nSkip))
    lRet := !D4F->(Eof()) 

Return lRet




/*/
Funções GRID MATA010
/*/

/*/{Protheus.doc} E330BMdl010
	Monta o submodelo da D4G na tela do cadastro de produtos
	@type  Function
	@author g.moreira
	@since 20/08/2024
	/*/
Function E330BMdl010(oModel As Object, nOpc As Integer, lEST330B As Logical)
	Local oStruD4G  := Nil As Object
	Local nPos      := 0   As Integer
	Local aRelation := {}  As Array
	Local lExecute  := FnVldCMod2() As Logical

	If lEST330B .And. lExecute
		nPos := aScan(oModel:aAllSubModels, {|x| x:CID == "D4GDETAIL" })
		if nPos == 0
			aRelation := {{'D4G_FILIAL', 'FWXFilial("D4G")'},;
			              {'D4G_PRODUT', 'B1_COD'}}

			//Revisão custo em partes
			oStruD4G := FWFormStruct(1,"D4G", {|x| !(AllTrim(Upper(x)) $ "---") })

			oStruD4G:AddField(' ', " ", 'D4G_LEG', 'BT' , 1 , 0, {|| .T.} ,,,, {|| D4GIcon()},, .F., .T.)

			oStruD4G:AddTrigger("D4G_CODPAR", "D4G_LEG", , {|| D4GIcon(.T.)})
			oStruD4G:AddTrigger("D4G_REVIS",  "D4G_LEG", , {|| D4GIcon(.T.)})

			oModel:AddGrid("D4GDETAIL", "SB1MASTER", oStruD4G,;
			 {|oModel, nLine, cAction, cIDField, xValue, xCurrentValue| PreVldLine(oModel, nLine, cAction, cIDField, xValue, xCurrentValue)},;
			 {|oModel, nLine| PosVldLine(oModel, nLine)};
			  )
			oModel:SetRelation('D4GDETAIL', aRelation, D4G->(IndexKey(1)) )
			oModel:GetModel('D4GDETAIL'):SetOptional(.T.)

			oModel:GetModel("D4GDETAIL"):SetUniqueLine({"D4G_REVIS","D4G_CODPAR"})

			oModel:AddRules('D4GDETAIL', 'D4G_CODPAR', 'D4GDETAIL', 'D4G_REVIS', 3)
		EndIf
	EndIf
	
Return

/*/{Protheus.doc} E330Vw010
	Monta o submodelo da D4G na tela do cadastro de produtos
	@type  Function
	@author g.moreira
	@since 20/08/2024
	/*/
Function E330Vw010(oView As Object)
	Local oStruD4G
	Local nPos 		 := aScan(oView:aViews, {|x| x[VIEWS_VIEW_ID] == "FORMD4G" })
	Local oModD4G    := oView:GetModel():GetModel("D4GDETAIL")
	Local lExecute  := FnVldCMod2() As Logical
 
	If oModD4G <> NIL .and. nPos == 0 .And. lExecute
		oStruD4G := FWFormStruct(2,"D4G", {|x| !(AllTrim(Upper(x)) $ "D4G_PRODUT") })

		oStruD4G:AddField("D4G_LEG", '00', " ", " ", {}, 'BT' ,'@BMP',,,.F.,,,,,, .T. )

		oView:CreateHorizontalBox( 'BOXFORMD4G', 10)
		oView:AddGrid('FORMD4G' , oStruD4G,'D4GDETAIL')
		oView:SetOwnerView('FORMD4G','BOXFORMD4G')
		oView:EnableTitleView("FORMD4G", FwX2Nome("D4G"))
		oView:SetViewProperty('FORMD4G', 'GRIDDOUBLECLICK', {{|oView, cField, nLineGrid, nLineModel| D4GLegen(cField)}})
	EndIf
	
Return

/*/{Protheus.doc} D4GIcon
	Retorna o ícone da legenda, de acordo com os valores preenchidos na linha
	@type  Static Function
	@author g.moreira
	@since 27/08/2024
/*/
Static Function D4GIcon(lTrigger)
	Local cLegenda := ""                    as Character
	Local cStatus                           as Character
	Local cRevis                            as Character
	Local oModel   := FWModelActive()       as Object
	Local nOpc     := oModel:GetOperation() as Integer

	Default lTrigger := .F.

	//D4F_FILIAL+D4F_REVIS+D4F_CODPAR
	If lTrigger
		cRevis  := FWFldGet('D4G_REVIS')
	Else
		If nOpc != MODEL_OPERATION_INSERT
			cRevis  := D4G->D4G_REVIS
		EndIf
	EndIf

	If !Empty(cRevis)
		cStatus := Posicione("D4F", 1, FWXFilial('D4F')+cRevis, 'D4F_STATUS') 

		If cStatus == "0"
			cLegenda := "BR_CINZA"
		ElseIf cStatus == "1"
			cLegenda := "BR_VERDE"
		ElseIf cStatus == "2"
			cLegenda := "BR_VERMELHO"
		EndIf
	EndIf

Return cLegenda


/*/{Protheus.doc} D4GLegen()
	Mostra a legenda do GRID de produtos x parte custo
	@type  Static Function
	@author g.moreira
	@since 27/08/2024
/*/
Static Function D4GLegen(cField)
	Local aLegenda	 := {}

	If cField != 'D4G_LEG'
		Return .T.
	EndIf

	aAdd(aLegenda,{"BR_CINZA" ,  STR0010}) //"Rascunho"
	aAdd(aLegenda,{"BR_VERDE" ,  STR0011}) //"Vigente"
	aAdd(aLegenda,{"BR_VERMELHO",STR0012}) //"Não Vigente"

	BrwLegenda(STR0009, STR0009, aLegenda) //"Legenda"
Return


/*/{Protheus.doc} D4GIniPad
	Inicializador padrão dos campos virtuais da rotina, e gatilho
	@type  Static Function
	@author g.moreira
	@since 27/08/2024
/*/
Function D4GIniPad(lTrigger As Logical, cCampo As character)
	Local cRevis   As Character
	Local cCodPar  As Character
	Local oModel := FWModelActive() As Object
	Local nOpc   := oModel:GetOperation() As Integer
	Local cRet   := "" As Character

	Default lTrigger := .F.

	//D4F_FILIAL+D4F_REVIS+D4F_CODPAR
	If lTrigger
		cRevis  := FWFldGet('D4G_REVIS')
		cCodPar := FWFldGet('D4G_CODPAR')
	Else
		If nOpc != MODEL_OPERATION_INSERT
			cRevis  := D4G->D4G_REVIS
			cCodPar := D4G->D4G_CODPAR
		EndIf
	EndIf

	If !Empty(cRevis) .And. !Empty(cCodPar)
		cRet := Posicione("D4F", 1, FWXFilial('D4F')+cRevis+cCodPar, cCampo) 
	EndIf

Return cRet

/*/{Protheus.doc} PreVldLine
	Verifica se a linha pode ser excluída ou alterada
	@type  Static Function
	@author g.moreira
	@since 30/08/2024
/*/
Static Function PreVldLine(oMdlGrd As Object, nLine As Integer, cAction As Character, cIDField As Character, xValue, xCurrentValue)
	Local lRet := .T. as Logical
	Local cRevis      as Character
	Local cCodPar     as Character
	Local cStatus     as Character
	Local cMsg        as Character
	Local cSol        as Character
	Local cRevD4F     as Character
	Local cPartD4F    as Character
	Local aDataD4F    as Array
	Local aCposD4F    as Array
	Local nI

	cProduto   := FWFldGet("B1_COD")
	cCCusto    := FWFldGet("B1_CCCUSTO")
	cRevis     := FWFldGet( 'D4G_REVIS' )
	cCodPar    := FWFldGet( 'D4G_CODPAR' )
	cProduto   := FWFldGet("B1_COD")

	If !Empty(cRevis)
		aCposD4F := {"D4F_REVIS","D4F_STATUS"}
		aDataD4F := GetAdvFval("D4F", aCposD4F , FWXFilial( 'D4F' ) + cRevis, 1, {"",""})

		cRevD4F  := aDataD4F[1]
		cStatus  := aDataD4F[2]
		cPartD4F := GetAdvFval("D4F", "D4F_CODPAR" , FWXFilial( 'D4F' ) + cRevis + cCodPar, 1, "")
	

		If cAction == "SETVALUE"
			If !Empty(cRevD4F)
				If cStatus == "2" //Revisão encerrada
					lRet := .F.
					cMsg := STR0030 //"Não é possível inserir revisão encerrada."
					cSol := STR0031 //"Só é permitido realizar o vínculo de uma revisão em rascunho ou vigente."
					Help('',1,STR0043,,cMsg,1,0,,,,,,{cSol}) //REVIS
				ElseIf !Empty(cCodPar) .And. Empty(cPartD4F)
					lRet := .F.
					cMsg := STR0032 //"O código da parte não existe."
					cSol := STR0033 //"Digite um parte válida para a revisão selecionada."
					Help('',1,STR0043,,cMsg,1,0,,,,,,{cSol}) //REVIS
				EndIf
			Else
				lRet := .F.
				cMsg := STR0034 //"Revisão não encontrada."
				cSol := STR0035 //"Informe uma revisão válida."
				Help('',1,STR0043,,cMsg,1,0,,,,,,{cSol}) //REVIS
			EndIf
		EndIf
		
		If cAction == "DELETE" .Or. cAction == "CANSETVALUE"
			If cStatus == "2" //Revisão histórica
				lRet := .F.
				cMsg := STR0036 //"A Revisão está encerrada e o vínculo dos produtos nela são mantidos por histórico para consultas em períodos anteriores."
				cSol := STR0037 //"Só é permitido excluir o vínculo de uma revisão em rascunho ou vigente, desde que não hajam fechamentos de custo em partes para este produto na revisão."
				Help('',1,STR0043,,cMsg,1,0,,,,,,{cSol}) //REVIS
			EndIf
		
			If lRet
				DbSelectArea("D4I")
				D4I->(DbSetOrder(1))
				D4I->(DbSeek(FWxFilial("D4I") + cProduto))
				while !D4I->(Eof()) .And. D4I->D4I_COD == cProduto
					If D4I->D4I_REVISA == cRevis
						lRet := .F.
						cMsg := STR0044 //"Não é possível exluir/alterar a revisão."
						cSol := STR0045 //"Há fechamento de custo em partes para este produto na revisão"
						Help('',1,STR0043,,cMsg,1,0,,,,,,{cSol}) //REVIS
						Exit
					EndIf
				endDo
				D4I->(DbCloseArea())
			EndIf
		EndIf
	Else
		//antes de adicionar ao grid
		If cAction == "SETVALUE" .And. Empty(cRevis) .And. !Empty(xValue)
			If lRet .And. SubStr(cProduto, 1, 3) != "MOD" .And. Empty(cCCusto)
				For nI := 1 To oMdlGrd:Length()
					If oMdlGrd:GetValue("D4G_REVIS", nI) == xValue .And. !oMdlGrd:IsDeleted(nI)
						lRet := .F.
						cMsg := OemToAnsi(I18N(STR0046,{oMdlGrd:GetValue("D4G_REVIS", nI)})) //"Revisão " + oMdlGrd:GetValue("D4G_REVIS", nI) + " já adicionada."
						cSol :=  STR0047 //"Não é possível informar revisão duplicada para o tipo da parte 1-Insumos."
						Help('',1,STR0043,,cMsg,1,0,,,,,,{cSol}) //REVIS
						Exit
					EndIf
				Next nI
			EndIf		
		EndIf
	EndIf
			
Return lRet

/*/{Protheus.doc} PosVldLine
	Validação da linha do vínculo do produto com a parte do custo
	Caso seja um produto normal, permite somente a associação de uma parte por revisão do tipo insumo
	Caso seja um produto MOD, permite uma ou mais
	@type Function
	@author g.moreira
	@since 30/08/2024
/*/
Static Function PosVldLine(oMdlGrd As Object, nLine As Integer)
	Local lRet := .T. as Logical
	Local cProduto    as Character
	Local cCCusto     as Character
	Local cTipo       as Character
	Local cRevis      as Character
	Local cCodPar     as Character
	Local cMsg        as Character
	Local cSol        as Character

	cProduto := FWFldGet("B1_COD")
	cCCusto  := FWFldGet("B1_CCCUSTO")
	cRevis   := FWFldGet('D4G_REVIS')
	cCodPar  := FWFldGet('D4G_CODPAR')
	cTipo    := Posicione("D4F", 1, FWXFilial('D4F')+cRevis+cCodPar, "D4F_TIPO")

	If Empty(cRevis)
		lRet := .F.
		cMsg := STR0038 //"Revisão não informada."
		cSol := STR0039 //"Informe a revisão antes de vincular uma parte do custo."
		Help('',1,STR0043,,cMsg,1,0,,,,,,{cSol}) //REVIS
	EndIF

	If SubStr(cProduto, 1, 3) == "MOD" .Or. !Empty(cCCusto)
		If cTipo == '1'
			lRet := .F.
			cMsg := STR0040 //"Produtos mão de obra (MOD) só podem ser associados à partes de custo do tipo 2-Despesas."
			cSol := STR0041 //"Informe outra parte de custo."
			Help('',1,STR0043,,cMsg,1,0,,,,,,{cSol}) //REVIS
		EndIf
	Else
		If cTipo == '2'
			lRet := .F.
			cMsg := STR0042 //"Partes de custo do tipo 2-Despesas não podem ser associadas à produtos que não sejam Produtos mão de obra (MOD)."
			cSol := STR0041 //"Informe outra parte de custo."
			Help('',1,STR0043,,cMsg,1,0,,,,,,{cSol}) //REVIS
		EndIf
	EndIf
Return lRet



/*/{Protheus.doc} E330BREVIS
Ativa ou desativa a revisão do custo em partes posicionada
@type function
@author Squad Entradas
@since 4/4/2025
@version 1.0
/*/
Function E330BREVIS()
	Local aArea      := FwGetArea()     as Array
	Local oModel     := NIL             as Object
	Local nOpc       := 4               as Numeric
	Local cStatusAtu := D4F->D4F_STATUS as Character
	Local lContinue  := .F.             as Logical
	
	Private cStatusNew as Character

	If cStatusAtu == "0" .And. VrfRevisAt() 
		cStatusNew := "1"
		lContinue := .T.
	ElseIf cStatusAtu == "1" .And. FWAlertNoYes(STR0017, STR0015)
		cStatusNew := "2"
		lContinue := .T.
	ElseIf cStatusAtu == "2"
		FWAlertWarning(STR0026, STR0023) //"Revisão já finalizada.","Aviso"
	EndIf 

	If lContinue
		oModel := FWLoadModel("EST330B")
		oModel:SetOperation( nOpc )
		oModel:Activate()
		FWExecView(STR0048, "EST330B", nOpc)
	EndIf

	FwRestArea(aArea)
Return


/*/{Protheus.doc} VrfRevisAt
Verifica se há revisão ativa
@type function
@author Squad Entradas
@since 4/4/2025
@version 1.0
@return logical, lRet, se .F. não há revisão ativa, se .T. há revisão ativa
/*/
Static Function VrfRevisAt()
	Local lRevAtiva := .F.            as Logical
	Local lRet      := .F.            as Logical
	Local nRecAtual := D4F->(Recno()) as Numeric
	
	dbSelectArea("D4F")
	D4F->(dbGoTop())
	While !D4F->(Eof())
		If D4F->D4F_STATUS == "1" 
			lRevAtiva := .T.
		EndIf
		D4F->(dbSkip())
	EndDo

	D4F->(DbGoTo(nRecAtual))

	If !lRevAtiva
		lRet := FWAlertNoYes(STR0016, STR0015) //"Deseja realmente iniciar a revisão?", "Deseja continuar?"
	Else
		FWAlertHelp(STR0021, STR0022) //"Existe revisão em vigência.","Finalize a revisão em vigência para iniciar uma nova revisão."
	EndIf		

Return lRet


/*/{Protheus.doc} E330IniSxe
Busca o número da revisão disponível para o cadastro de custo em partes
@type function
@version 1.0 
@author Squad Entradas
@since 4/4/2025
@param cTab, character, recebe alias da tabela
@param cCpo, character, recebe campo da tabela
@return Character, cRet, retorna o número da revisão disponível
/*/
Static Function E330IniSxe(cTab, cCpo)
	Local cRet := GetSxeNum(cTab,cCpo)

	While .T.
		(cTab)->(dbSetOrder(1))
		If (cTab)->(dbSeek( FWxFilial(cTab) + cRet ))
			ConfirmSX8()
			cRet := GetSxeNum(cTab,cCpo)
			Loop
		Else
			Exit
		EndIf
	EndDo
Return cRet


Static __oQryRevAt := Nil

/*/{Protheus.doc} E330RevAti
    Retorna a revisão ativa do custo em partes
    @type  Function
    @author Squad entradas
    @since 03/04/2025
    @return Character, cRev, código da revisão ativa
    @example
    cRev := E330RevAti()
    /*/
Function E330RevAti()
    Local cQuery  := ""
    Local cDBType := ""
    Local cRev    := ""

    If __oQryRevAt == Nil
        cDBType := TCGetDB()
        cQuery := " Select "
        If 'MSSQL' $ cDBType 
            cQuery += " Top 1 "
        EndIf
        cQuery += " D4F_REVIS From "+RetSQLName('D4F')
        cQuery += " Where "
        cQuery += " D4F_FILIAL = ? And "
		cQuery += " D4F_STATUS = ? And "
		cQuery += " D_E_L_E_T_ = ? "
        If 'ORACLE' $ cDBType 
            cQuery += " And ROWNUM = 1 "
        EndIf
        If 'POSTGRES' $ cDBType 
            cQuery += " Limit 1 "
        EndIf

        __oQryRevAt := FWExecStatement():New(cQuery)
    EndIf

    __oQryRevAt:SetString(1, FWXFilial('D4F'))
    __oQryRevAt:SetString(2, '1')	
	__oQryRevAt:SetString(3, ' ')

    cRev := __oQryRevAt:ExecScalar('D4F_REVIS')

Return cRev
