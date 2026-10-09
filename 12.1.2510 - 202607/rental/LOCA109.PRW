#Include "loca109.ch"
#INCLUDE "TOTVS.CH"
#Include "FWMVCDEF.CH"

/*/{Protheus.doc} LOCA109
Rotina de Cadastro de Solicitações de Trocas de Produtos
@type function
@version  25.10 
@author Alexandre Circenis
@since 23/04/2026
/*/
Function LOCA109()

LOCAL oBrowse:= FWmBrowse():New()

    oBrowse:SetDescription( STR0001) //"Solicitações de Troca de Produtos"
    oBrowse:SetMenuDef( 'LOCA109' )
    oBrowse:SetAlias( 'FH4' )
	oBrowse:SetAmbiente(.F.)
	oBrowse:SetWalkthru(.F.)
    oBrowse:OptionReport(.F.)

    oBrowse:AddLegend( "FH4->FH4_STATUS = '1'"             , "GREEN" , STR0002 )     //"Pendente"
	oBrowse:AddLegend( "FH4->FH4_STATUS = '2'"             , "RED"   , STR0003  )   //"Aprovada"
    oBrowse:AddLegend( "FH4->FH4_STATUS = '3'"             , "BLACK" , STR0004)    //"Reprovada"
  
	oBrowse:Activate()

Return NIL

/*/{Protheus.doc} MENUDEF
Menu Principal da Gestão de Demandas
@type function
@version 24.10 
@author Alexandre Circenis
@since 2/12/2025
@return variant, Array com as opçoes do menu
/*/
STATIC FUNCTION MENUDEF()
Local aRotina := {}

	ADD OPTION aRotina TITLE STR0005 ACTION 'VIEWDEF.LOCA109' OPERATION 2 ACCESS 0 //'Visualizar' //STR0005 //"Visualizar"
	ADD OPTION aRotina TITLE STR0006    ACTION 'VIEWDEF.LOCA109' OPERATION 3 ACCESS 0 //'Incluir' //STR0006 //"Incluir"
	ADD OPTION aRotina TITLE STR0007    ACTION 'VIEWDEF.LOCA109' OPERATION 4 ACCESS 0 //'Alterar' //STR0007 //"Alterar"
	ADD OPTION aRotina TITLE STR0008    ACTION 'VIEWDEF.LOCA109' OPERATION 5 ACCESS 0 //'Alterar' //"Alterar" //"Excluir"

Return aRotina

/*/{Protheus.doc} MODELDEF
Definicão do modelo de Local de Devolução 
@type function
@version 24.10 
@author Alexandre Circenis
@since 2/12/2025
@return variant, Modelo de Cabeçalho de Demanda
/*/
STATIC FUNCTION MODELDEF()
LOCAl oStruFH4 := FWFormStruct( 1, 'FH4', /*bAvalCampo*/,/*lViewUsado*/ )
Local oStruFH5 := FWFormStruct( 1, 'FH5', /*bAvalCampo*/,/*lViewUsado*/ )
Local oModel

	oModel := MPFormModel():New( 'LOCA109', /*bPreValidacao*/, /*bPosValidacao*/ , /*bCommit*/, /*bCancel*/ )

	oStruFH4:AddTrigger( "FH4_AS"   , "FH4_AS"	, {|| .T. }  , {|| LOCA109GPR() } )
	oStruFH4:SetProperty("FH4_AS"   , MODEL_FIELD_VALID, FWBuildFeature(STRUCT_FEATURE_VALID,"LOCA109VAS()" ))

	oStruFH5:SetProperty("FH5_ORIGEM"   , MODEL_FIELD_INIT,{|| FwFldGet("FH4_PRODUT")} )
	oStruFH5:SetProperty("FH5_DESORI"   , MODEL_FIELD_INIT,{|| Posicione("SB1", 1, xFilial("SB1")+ FwFldGet("FH4_PRODUT"), "B1_DESC")} )
	oStruFH4:AddTrigger( "FH5_ORIGEM"   , "FH5_QTDORI"	, {|| .T. }  , {|| FwFldGet("FH4_QUANT") } )
	oStruFH5:SetProperty("FH5_NUM"      , MODEL_FIELD_INIT,{|| FwFldGet("FH4_NUM")} )

	//Atribuindo formulários para o modelo
	oModel:AddFields('FH4MASTER', , oStruFH4 )
	oModel:AddGrid( 'FH5GRID', 'FH4MASTER', oStruFH5 )

	oModel:AddCalc( 'RODAPE', 'FH4MASTER', 'FH5GRID', 'FH5_QTDORI', 'QTDORI', 'SUM', ,, STR0009,,10,2 )  //"Qtd Origem"
	oModel:AddCalc( 'RODAPE', 'FH4MASTER', 'FH5GRID', 'FH5_QTDDES', 'QTDDES', 'SUM', ,, STR0010,,10,2 )  //"Qtd Destino"

	//oStruFH5:SetProperty("FH5_QTDORI"   , MODEL_FIELD_INIT,{|| FwFldGet("FH4_QUANT")} )

	oModel:SetRelation( 'FH5GRID', { { 'FH5_FILIAL', 'xFilial("FH5")' },{'FH5_NUM','FH4_NUM'}}, FH5->( IndexKey( 1 ) ) )

	// Adiciona a descricao do Modelo de Dados
	oModel:SetDescription( "Solicitação de Troca" ) 


	// Adiciona a descricao do Componente do Modelo de Dados

	oModel:GetModel( 'FH4MASTER' ):SetDescription(STR0011)  //"Solicitação de Troca de Produtos"
	oModel:GetModel( 'FH5GRID' ):SetDescription(STR0012)  //"Itens da Solicitação de Troca"

	// Liga a validação da ativacao do Modelo de Dados
	oModel:SetVldActive( { | oModel | Loca109Act( oModel ) })

Return oModel


/*/{Protheus.doc} ViewDef
Define a View dos Locais de Devolução
@type function
@version 24.10 
@author Alexandre Circenis
@since 2/12/2025
@return variant, Retorna a view da demanda
/*///-------------------------------------------------------------------
Static Function ViewDef()
// Instancia a Estrutura

Local oModel   := FWLoadModel( 'LOCA109' )
Local oStruFH4 := FWFormStruct( 2, 'FH4', /*bAvalCampo*/,/*lViewUsado*/ )
Local oStruFH5 := FWFormStruct( 2, 'FH5', /*bAvalCampo*/,/*lViewUsado*/ )
Local oView
Local oCalc1  	:= FWCalcStruct(oModel:GetModel('RODAPE'))

	oStruFH4:RemoveField("FH4_STATUS")
	oStruFH5:RemoveField("FH5_NUM")
	oStruFH5:RemoveField("FH5_FILIAL")

	// Cria o objeto de View
	oView := FWFormView():New()

	// Define qual o Modelo de dados será utilizado
	oView:SetModel( oModel )

	// Estrutura visual dos campos
	oView:AddField('VIEW_CAB', oStruFH4, 'FH4MASTER')
		
	// Estrutura visual das grids
	oView:AddGrid('VIEW_FH5', oStruFH5, 'FH5GRID')

	oView:AddField( 'VIEW_CALC', oCalc1, 'RODAPE' )

	//Criando um container com nome tela com 100%
	oView:CreateHorizontalBox( 'CABEC', 40)
	oView:CreateHorizontalBox( 'GRID', 40 )
	oView:CreateHorizontalBox( 'CALC', 20 )
		
	oView:SetOwnerView('VIEW_CAB' , 'CABEC' )
	oView:SetOwnerView('VIEW_FH5', 'GRID')
	oView:SetOwnerView('VIEW_CALC', 'CALC')

	oView:addIncrementField("VIEW_FH5","FH5_ITEM")

Return oView
/*/{Protheus.doc} LOCA109GPR
Quando se informa a A.S. a grid com as opções de troca pe apagada e criada uma nova linha contendo o produto de origem 
da nova A.S. informada
@type function
@version 25.10
@author Alexandre Circenis
@since 17/06/2026
@return variant,Retorna o codigo da A.S.
/*/
Function LOCA109GPR()
Local oModel    := FWModelActive()
Local oModelFH5 := oModel:GetModel("FH5GRID")
Local oRodape   := oModel:GETModel("RODAPE")
Local aArea := GetArea()
Local aAreaFPA := FPA->(GetArea())

	FPA->(dbSetOrder(3))
	FPA->(dbSeek(xFilial("FPA")+M->FH4_AS))

	oModelFH5:CLearData(.T.,.T.)
	oRodape:SetValue("QTDORI", 0)
	oRodape:SetValue("QTDDES", 0)

	oModelFH5:LoadValue("FH5_FILIAL", xFilial("FH5"))
	oModelFH5:LoadValue("FH5_NUM", M->FH4_NUM)
	oModelFH5:LoadValue("FH5_ORIGEM", FPA->FPA_PRODUT)
	oModelFH5:LoadValue("FH5_DESORI", Posicione("SB1", 1, xFilial("SB1")+FPA->FPA_PRODUT, "B1_DESC"))

	oModelFH5:LoadValue("FH5_QTDORI", FPA->FPA_QUANT)

	RestArea(aAreaFPA)
	RestArea(aArea)

Return M->FH4_AS

/*/{Protheus.doc} LOCA109VAS
Valida a AS de origem da troca
- A.S. eve existir no sistema
- A A.S. deve estar contida na demanda posicionada
- A A.S. não pode estar aceita ou separada
- A A.S. não pode estar contida em um Romaneio
- O produto da A.S. não pode exigir bem
- A A.S. não pode estar vinculada a outra solicitação de troca
@type function
@version 25.10
@author Alexandre Circenis
@since 17/06/2026
@return variant, Retorna se a A.S. é elegivel para ser trocada
/*/
Function LOCA109VAS()
Local lRet := .T.
Local aArea := GetArea()
Local aAreaFQ5 := FQ5->(GetArea())
Local aAreaFH4 := FH4->(GetArea())
Local oModel    := FWModelActive()
Local cTipo
Local cGrupo

	FQ5->(dbSetOrder(9))
	if !FQ5->(dbSeek( xFilial("FQ5")+ M->FH4_AS))
		lRet := .F.
		oModel:SetErrorMessage("","","","","LOCA109_02",STR0014,STR0013) //"Informe uma A.S. valida" //"A A.S. não cadastrada no sistema!"
	elseif FQ5->FQ5_DEMAND <> FQT->FQT_DEMAND
		lRet := .F.
		oModel:SetErrorMessage("","","","","LOCA109_03",STR0015,STR0013)  //"Informe uma A.S. valida" //"A A.S. não está na demanda "
	elseif FQ5->FQ5_STATUS = '6'
		lRet := .F.
		oModel:SetErrorMessage("","","","","LOCA109_04",STR0017,STR0016) //"Antes de trocar realize o estorno da separação." //"A A.S. já foi separada não podera ser troca!"
	elseif !Empty(FQ5->FQ5_XROMAN)
		lRet := .F.
		oModel:SetErrorMessage("","","","","LOCA109_05",STR0019,STR0018) //"Antes de trocar retire a A.S. do romaneio." //"A A.S. já foi está em um romaneio não pode ser trocada!"
	endif

	if lRet  
		cGrupo    := Posicione("SB1",1, xFilial("SB1")+FQ5->FQ5_XPROD, "B1_GRUPO")
		cTipo     := Posicione( "SBM",1, xFilial("SBM")+cGrupo, "BM_XACESS")

		if !(cTipo$'1#3') // Produto não é informado em quantidade
		lRet := .F.
		oModel:SetErrorMessage("","","","","LOCA109_06",STR0020,STR0021) //"A A.S. está relacionada a um produto de grupo que exige Bem!" //"Somente produtos quantificaveis podem ser trocados nessa rotina."
		endif  
	endif     
	FH4->(dbSetOrder(2))

	if FH4->(dbSeek(xFilial("FH4")+M->FH4_AS))
		while !FH4->(EOF()) .and. FH4->(FH4_FILIAL + FH4_AS) = xFilial("FH4")+M->FH4_AS
			if FH4->FH4_NUM <> M->FH4_NUM .and. FH4->FH4_STATUS = '1' // Troca em aberto não pode trocar
				lRet := .F.
				oModel:SetErrorMessage("","","","","LOCA109_07",STR0022,) //"A A.S. já está vinculada em outra Solicitação de troca. Não será possivel continuar!"
				Exit
			endif

			FH4->(dbSkip())
		enddo
	endif


	RestArea(aAreaFQ5)
	RestArea(aAreaFH4)
	RestArea(aArea)

Return lRet

/*/{Protheus.doc} LOCA109XQ5
Funçao que monta uma pesquisa customizada relacionado FQ5 com SB1 e SBM 
@type function
@version 25.10 
@author Alexandre Circenis
@since 4/9/2025
@return variant, retorna se a operação foi bem sucedida
/*/
Function LOCA109XQ5()

Local lRet	  := .T.
Local nOpcA   := 0
Local cVar	  := ReadVar()
Local nTam	  := Len(&cVar)
Local oDlgCons
Local oGetCons   
Local aTabRecDes := {}

Local cCpoAnt   := &cVar
Local cCodTab   := ""
Local cRadical  := ""

	aTabRecDes := LOCA109XQ1(M->FH4_DEMAND)
	
	if len(aTabRecDes) > 0

		Define MsDialog oDlgCons Title STR0023 From 000, 000 To 450, 800 PIXEL   //"A.S. Disponiveis para troca de produto"

		Define Font oFont Name 'Courier New' Size 0, -12		
		oGetCons := TCBrowse():New( 000, 000, 545, 200,, { STR0024, STR0026, "Descrição", STR0025},,;     //"A.S." //"Quantidade" //"Produto"
									oDlgCons,,,,,{||},,oFont,,,,,.T./*lUpdate*/,,.T.,,.T./*lDesign*/,,, )  	
		oGetCons:Align   := CONTROL_ALIGN_TOP
		oGetCons:SetArray(aTabRecDes)
		oGetCons:bLine := {||{	aTabRecDes[oGetCons:nAt,1],aTabRecDes[oGetCons:nAt,2], aTabRecDes[oGetCons:nAt,3],;
		aTabRecDes[oGetCons:nAt,4] } }	                            
		oGetCons:blDblClick := {||nOpcA := 1, nAt := oGetCons:nAt, oDlgCons:End()}

		@208,310 BUTTON STR0027 SIZE 40,12 OF oDlgCons PIXEL ACTION (nOpcA := 1, nAt := oGetCons:nAt, oDlgCons:End())	 //"Ok"
		@208,360 BUTTON STR0028 SIZE 40,12 OF oDlgCons PIXEL ACTION (nOpcA := 0, oDlgCons:End())	 //"Cancelar"

		Activate MsDialog oDlgCons Centered

		If nOpcA == 1 
			&cVar := aTabRecDes[nAt,1]
			FQ5->( dbGoto(Atail(aTabRecDes[nAt])))
		Else
			//recupera o que estava anteriormente
			&cVar := cCpoAnt
			lRet := .F.
		EndIf
	Else
		Help(Nil,	Nil,"LOCA109XQ5",; 
				Nil, STR0029,1,0,Nil,Nil,Nil,Nil,Nil, ) //'Não há A.S. na demanda que atendam os criterios para serem aptas a troca de produtos.'
		&cVar := cCpoAnt
		lRet := .F.
	EndIf

Return lRet


//-------------------------------------------------------------------
/*/{Protheus.doc} LOCA109XQ1
Retorna um array com codigo/descricao de AS e Conjunto transportador
@type function 
@author TOTVS
@since 26/11/2020
@version P12
/*/
//-------------------------------------------------------------------
Static Function LOCA109XQ1(cDemanda)
Local aArea      := GetArea()
Local cQuery     := ""
Local aRetorno   := {}
Local cAliasTmp  := GetNextAlias()
Local aBindParam := {}
LOcal aTamQTD    := TamSX3("FQ5_XQTD")

	cQuery += " SELECT FQ5_AS, B1_COD, B1_DESC, FQ5_XQTD, FQ5.R_E_C_N_O_ RECFQ5"
	cQuery += " FROM " + RetSqlName("FQ5")+ " FQ5 
	cquery += " INNER JOIN " + RetSqlName("SB1")+ " SB1 "
	cQuery += " ON SB1.B1_FILIAL = '"+xFilial("SB1")+"' " 
	cQuery += "  AND SB1.B1_COD = FQ5.FQ5_XPROD"
	cQuery += "  AND SB1.D_E_L_E_T_ = ' '"
    cquery += " INNER JOIN " + RetSqlName("SBM")+ " SBM "
	cQuery += " ON SBM.BM_FILIAL = '"+xFilial("SBM")+"' " 
	cQuery += "  AND SBM.BM_GRUPO = SB1.B1_GRUPO"
    cQUery += "  AND SBM.BM_XACESS IN ('1','3')"
	cQuery += "  AND SBM.D_E_L_E_T_ = ' '"
	cQuery += " WHERE FQ5_FILIAL = '"+xFilial("FQ5")+"' " 
	cQuery += "   AND FQ5_DEMAND = ? " 
	aadd(aBindParam, cDemanda)
    cQuery += "   AND FQ5_STATUS = '1'"
	cQuery += "   AND FQ5_XROMAN = ' '"
	cQuery += "   AND FQ5.D_E_L_E_T_ = ' ' "
	cQuery += " ORDER BY FQ5_AS"

	cQuery := ChangeQuery( cQuery )
	MPSysOpenQuery( cQuery ,cAliasTmp,,,aBindParam)

	While (cAliasTmp)->( ! Eof() )
		aAdd( aRetorno, { (cAliasTmp)->FQ5_AS,(cAliasTmp)->B1_COD, (cAliasTmp)->B1_DESC,;
		Str((cAliasTmp)->FQ5_XQTD, aTamQtd[1], aTamQtd[2]), (cAliasTmp)->RECFQ5} )
		(cAliasTmp)->( dbSkip() )
	EndDo

	(cAliasTmp)->( DBCloseArea() )

	RestArea(aArea)

Return(aRetorno)

/*/{Protheus.doc} LOCA109XB1
Funçao que monta uma pesquisa customizada relacionado FQ5 com SB1 e SBM 
@type function
@version 25.10 
@author Alexandre Circenis
@since 4/9/2025
@return variant, retorna se a operação foi bem sucedida
/*/
Function LOCA109XB1()

Local lRet	  := .T.
Local nOpcA   := 0
Local cVar	  := ReadVar()
Local nTam	  := Len(&cVar)
Local oDlgCons
Local oGetCons   
Local aTabRecDes := {}

Local cCpoAnt   := &cVar
Local cCodTab   := ""
Local cRadical  := ""
Local cGrupo    := Posicione("SB1",1, xFilial("SB1")+FWFldGet("FH5_ORIGEM"), "B1_GRUPO")
LOcal cTipo     := Posicione( "SBM",1, xFilial("SBM")+cGrupo, "BM_XACESS")

	aTabRecDes := LOCA109XB2(cTipo, FWFldGet("FH5_ORIGEM"))
	
	if len(aTabRecDes) > 0

		Define MsDialog oDlgCons Title STR0030 From 000, 000 To 450, 800 PIXEL   //"Produtos para troca"

		Define Font oFont Name 'Courier New' Size 0, -12		
		oGetCons := TCBrowse():New( 000, 000, 545, 200,, { STR0026, STR0031},,;     //"Produto" //"Descrição"
									oDlgCons,,,,,{||},,oFont,,,,,.T./*lUpdate*/,,.T.,,.T./*lDesign*/,,, )  	
		oGetCons:Align   := CONTROL_ALIGN_TOP
		oGetCons:SetArray(aTabRecDes)
		oGetCons:bLine := {||{	aTabRecDes[oGetCons:nAt,1],aTabRecDes[oGetCons:nAt,2] } }	                            
		oGetCons:blDblClick := {||nOpcA := 1, nAt := oGetCons:nAt, oDlgCons:End()}

		@208,310 BUTTON STR0027 SIZE 40,12 OF oDlgCons PIXEL ACTION (nOpcA := 1, nAt := oGetCons:nAt, oDlgCons:End())	 //"Ok"
		@208,360 BUTTON STR0028 SIZE 40,12 OF oDlgCons PIXEL ACTION (nOpcA := 0, oDlgCons:End())	 //"Cancelar"

		Activate MsDialog oDlgCons Centered

		If nOpcA == 1 
			&cVar := aTabRecDes[nAt,1]
			FQ5->( dbGoto(Atail(aTabRecDes[nAt])))
		Else
			//recupera o que estava anteriormente
			&cVar := cCpoAnt
			lRet := .F.
		EndIf
	Else
		Help(Nil,	Nil,"LOCA109B15",; 
				Nil, STR0032,1,0,Nil,Nil,Nil,Nil,Nil, ) //'Não há produtos do mesmo tipo que o produto origem.'
		&cVar := cCpoAnt
		lRet := .F.
	EndIf

Return lRet


//-------------------------------------------------------------------
/*/{Protheus.doc} LOCA109XB2
Retorna um array com codigo/descricao do produto para troca
@type function 
@author TOTVS
@since 26/11/2020
@version P12
/*/
//-------------------------------------------------------------------
Static Function LOCA109XB2( cTipo, cOrigem)
Local aArea      := GetArea()
Local cQuery     := ""
Local aRetorno   := {}
Local cAliasTmp  := GetNextAlias()
Local aBindParam := {}

	cQuery += " SELECT  B1_COD, B1_DESC, SB1.R_E_C_N_O_ RECSB1"
	cQuery += " FROM " + RetSqlName("SB1")+ " SB1 "  
    cquery += " INNER JOIN " + RetSqlName("SBM")+ " SBM "
	cQuery += " ON SBM.BM_FILIAL = '"+xFilial("SBM")+"' " 
	cQuery += "  AND SBM.BM_GRUPO = SB1.B1_GRUPO"
    cQUery += "  AND SBM.BM_XACESS = ? "
    Aadd( aBindParam, cTipo)
	cQuery += "  AND SBM.D_E_L_E_T_ = ' '"
	cQuery += " WHERE SB1.B1_FILIAL = '"+xFilial("SB1")+"' " 
	cQuery += "  AND SB1.B1_COD <> ? "
    Aadd( aBindParam, cOrigem)
	cQuery += "  AND SB1.D_E_L_E_T_ = ' '"
	cQuery += " ORDER BY B1_COD"

	cQuery := ChangeQuery( cQuery )
	MPSysOpenQuery( cQuery ,cAliasTmp,,,aBindParam)

	While (cAliasTmp)->( ! Eof() )
		aAdd( aRetorno, { (cAliasTmp)->B1_COD, (cAliasTmp)->B1_DESC, (cAliasTmp)->RECSB1} )
		(cAliasTmp)->( dbSkip() )
	EndDo

	(cAliasTmp)->( DBCloseArea() )

	RestArea(aArea)

Return(aRetorno)

/*/{Protheus.doc} LOCA109VDE
Valida o Produto de Destino da substituição
@type function
@version 25.10
@author Alexandre Circenis
@since 17/06/2026
@return variant, Retorna se produto é valido ou não
/*/
Function LOCA109VDE()
Local lRet := .T.
Local aArea := GetArea()
Local aAreaSB1 := SB1->(GetArea())
Local aAreaFH4 := FH4->(GetArea())
Local oModel    := FWModelActive()
Local cTipoORi
Local cGrupoOri
Local cGrupoDes
LOcal cTipoDes

	SB1->(dbSetOrder(1))
	if !SB1->(dbSeek( xFilial("SB1")+ M->FH5_DESTIN))
		lRet := .F.
		oModel:SetErrorMessage("","","","","LOCA109_11",STR0033,STR0034) //"Produto não encontrato no cadastro!" //"Informe um produto valido."
	endif

	if lRet  

		cGrupoDes    := SB1->B1_GRUPO
		cTipoDes    := Posicione( "SBM",1, xFilial("SBM")+cGrupoDes, "BM_XACESS")

		cGrupoOri := Posicione( "SB1",1, xFilial("SB1")+FwFldGet("FH5_ORIGEM"), "B1_GRUPO")
		cTipoOri  := Posicione( "SBM",1, xFilial("SBM")+cGrupoOri, "BM_XACESS")

		if cTipoDes <> cTipoOri
		lRet := .F.
		oModel:SetErrorMessage("","","","","LOCA109_12",STR0035,STR0036) //"Os grupos dos produtos Original e o de Troca devem ser do mesmo tipo!" //"Informe um produto de troca com o grupo do mesmo tipo."
		endif  

	endif     
	FH4->(dbSetOrder(2))

	RestArea(aAreaSB1)
	RestArea(aAreaFH4)
	RestArea(aArea)

Return lRet

/*/{Protheus.doc} Loca229DAC
Validação para varifica se podemos realizar as operações sobre o model
@type function
@version 25.10 
@author Alexandre Circenis
@since 5/6/2025
@param oModel, object, Model do ITem do Romaneio
@return variant, .T. se a operação puder ser realizada
/*/
Function Loca109ACT( oModel )
Local lRet := .T.
Local nOpc:=oModel:GetOperation()

    if nOpc == MODEL_OPERATION_DELETE .or. nOpc == MODEL_OPERATION_UPDATE
        if FH4->FH4_STATUS <> '1'
            Help(" ",1,"LOCA109_30",, STR0037,1,0)   //"A operação solicitada só pode ser realizada em Solicitações de Troca com o status Pendente"
    	    lRet := .F.
        endif
    endif    

return lRet
