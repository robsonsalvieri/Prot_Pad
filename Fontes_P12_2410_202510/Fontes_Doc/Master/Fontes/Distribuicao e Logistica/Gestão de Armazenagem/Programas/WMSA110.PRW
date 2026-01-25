#INCLUDE "PROTHEUS.CH"
#INCLUDE "WMSA110.CH"
#INCLUDE "FWMVCDEF.CH"

#DEFINE WMSA11001 "WMSA11001"
#DEFINE WMSA11002 "WMSA11002"
#DEFINE WMSA11003 "WMSA11003"
#DEFINE WMSA11004 "WMSA11004"
#DEFINE WMSA11005 "WMSA11005"
#DEFINE WMSA11006 "WMSA11006"
#DEFINE WMSA11007 "WMSA11007"
Static __lMarkAll := .F.
Static oEtiqUnit := Nil
//-------------------------------------
/*/{Protheus.doc} WMSA110
Cadastro de Etiqueta de Unitizador
@author felipe.m
@since 26/06/2017
@version 1.0
/*/
//-------------------------------------
Function WMSA110()
Static oMarkBrw := Nil

	// Permite efetuar validações, apresentar mensagem e abortar o programa quando desejado
	If !WMSChkPrg(FunName(),"1")
		Return Nil
	EndIf

	If !Pergunte("WMSA110",.T.)
		Return Nil
	EndIf
	oMarkBrw:= FWMarkBrowse():New()
	oMarkBrw:SetDescription(STR0001) // "Etiquetas de Unitizador"
	oMarkBrw:SetMenuDef("WMSA110")
	oMarkBrw:SetAlias("D0Y")
	oMarkBrw:SetFieldMark("D0Y_OK")
	oMarkBrw:SetFilterDefault("@"+Filtro())
	oMarkBrw:SetAllMark({|| AllMark() })
	oMarkBrw:SetWalkThru(.F.)
	oMarkBrw:SetAmbiente(.F.)
	oMarkBrw:SetFixedBrowse(.T.)
	oMarkBrw:AddLegend("D0Y_IMPRES=='1'","BLUE",STR0006)     // "Impresso"
	oMarkBrw:AddLegend("D0Y_IMPRES=='2'","GREEN",STR0007) // "Não Impresso"
	oMarkBrw:SetParam({|| UpdSelecao()})
	oMarkBrw:Activate()
Return Nil
/*/-----------------------------------------------------------------------------
 MenuDef
-----------------------------------------------------------------------------/*/
Static Function MenuDef()
Local aRotina := {}

	ADD OPTION aRotina TITLE STR0004 ACTION "AxPesqui"        OPERATION 1 ACCESS 0 // "Pesquisar"
	ADD OPTION aRotina TITLE STR0005 ACTION "VIEWDEF.WMSA110" OPERATION 2 ACCESS 0 // "Visualizar"
	ADD OPTION aRotina TITLE STR0011 ACTION "WMSA110GER()" OPERATION 3 ACCESS 0 // "Gerar"
	ADD OPTION aRotina TITLE STR0008 ACTION "WMSA110IMP()" OPERATION 2 ACCESS 0 // "Imprimir"
	ADD OPTION aRotina TITLE STR0017 ACTION "WMSA110REU()" OPERATION 8 ACCESS 0 // "Reutilizar Etiqueta"

Return aRotina

/*/-----------------------------------------------------------------------------
 ModelDef
-----------------------------------------------------------------------------/*/
Static Function ModelDef()
Local oModel := Nil
Local oStrD0Y := FWFormStruct(1,"D0Y")

	oModel := MPFormModel():New('WMSA110',,/*ValidModel*/,/*CommitModel*/)
	oModel:AddFields('D0Y_FIELDS',,oStrD0Y)
	oModel:SetDescription(STR0001) // "Etiquetas de Unitizador"
Return oModel
/*/-----------------------------------------------------------------------------
 ViewDef
-----------------------------------------------------------------------------/*/
Static Function ViewDef()
Local oModel  := ModelDef()
Local oStrD0Y := FWFormStruct(2,"D0Y")

	oView := FWFormView():New()
	oView:SetModel(oModel)
	oView:AddField("D0Y_FORM",oStrD0Y,'D0Y_FIELDS')
Return oView
/*/-----------------------------------------------------------------------------
 Filtro do Markbrowse
-----------------------------------------------------------------------------/*/
Static Function Filtro()
Local cFiltro := ""
	cFiltro :=     " D0Y_IDUNIT >= '"+MV_PAR01+"' AND D0Y_IDUNIT <= '"+MV_PAR02+"'"
	cFiltro += " AND D0Y_DATGER >= '"+DTOS(MV_PAR03)+"' AND D0Y_DATGER <= '"+DTOS(MV_PAR04)+"'"
	If !Empty(MV_PAR05)
		cFiltro += " AND D0Y_USUARI = '"+MV_PAR05+"'"
	EndIf
	If !Empty(MV_PAR06)
		cFiltro += " AND EXISTS (SELECT DISTINCT D14.D14_FILIAL"
		cFiltro +=               " FROM "+RetSqlName("D14")+" D14"
		cFiltro +=              " WHERE D14.D14_FILIAL = '"+xFilial("D14")+"'"
		cFiltro +=                " AND D14.D14_IDUNIT = D0Y_IDUNIT"
		cFiltro +=                " AND D14.D14_ENDER = '"+MV_PAR06+"'"
		cFiltro +=                " AND D14.D_E_L_E_T_ = ' ')"
	EndIf
Return cFiltro
/*/-----------------------------------------------------------------------------
 Permite o usuário selecionar novamente com a tecla F12
-----------------------------------------------------------------------------/*/
Static Function UpdSelecao()
Local lRet := .T.
	If (lRet := Pergunte("WMSA110",.T.))
		__lMarkAll := .T.
		AllMark() // Força desmarcar todos antes de atualizar o filtro
		
		// Selecionar servicos conforme a parametrizacao do usuario.
		oMarkBrw:SetFilterDefault("@"+Filtro())
		oMarkBrw:Refresh()
	EndIf
Return lRet
/*/-----------------------------------------------------------------------------
 Marca/Desmarca todos
-----------------------------------------------------------------------------/*/
Static Function AllMark()
Local aAreaD0Y  := D0Y->(GetArea())
Local cMarca := ""
Local cQuery := ""

	__lMarkAll := !__lMarkAll
	
	cMarca := Iif(__lMarkAll,oMarkBrw:cMark,Space(TamSx3("D0Y_OK")[1]))

	cQuery := "UPDATE " + RetSqlName('D0Y')
	cQuery += " SET D0Y_OK = '" + cMarca + "'"
	cQuery += " WHERE D_E_L_E_T_ = ' '"
	cQuery += " AND " + Filtro()

	If TcSqlExec(cQuery) < 0
		FwAlertError(TcSqlError())
	EndIf

	RestArea(aAreaD0Y)
	oMarkBrw:Refresh()

Return Nil
/*/-----------------------------------------------------------------------------
Monta array de etiquetas para impressão
-----------------------------------------------------------------------------/*/
Function WMSA110IMP()
Local lRet      := .T.
Local lReimp    := .F.
Local cAliasD0Y := GetNextAlias()
Local cQuery    := ""
Local aItens    := {}
	
	cQuery := " SELECT D0Y.D0Y_IDUNIT,"
	cQuery +=        " D0Y.D0Y_IMPRES" 
	cQuery +=   " FROM "+RetSqlName("D0Y")+" D0Y"
	cQuery +=  " WHERE D0Y.D0Y_FILIAL = '"+xFilial("D0Y")+"'"
	cQuery +=    " AND D0Y.D0Y_OK = '"+oMarkBrw:cMark+"'"
	cQuery +=    " AND D0Y.D_E_L_E_T_ = ' '"
	dbUseArea(.T.,'TOPCONN',TcGenQry(,,cQuery),cAliasD0Y,.F.,.T.)
	While (cAliasD0Y)->(!EoF())
		//Verifica se etiqueta já foi impressa
		If !lReimp .And. (cAliasD0Y)->D0Y_IMPRES == '1'
			lReimp := .T.
		EndIf
		aAdd(aItens,{(cAliasD0Y)->D0Y_IDUNIT})
		(cAliasD0Y)->(DbSkip())
	EndDo
	(cAliasD0Y)->(DbCloseArea())
	If lReimp .And. !WmsQuestion(STR0009,WMSA11002) //Na marcação realizada existem etiquetas já impressas. Confirma reimpressão?
		lRet := .F.
	EndIf
	If lRet 
		If Len(aItens) > 0
			If ExistBlock("WMSA110E")
				lRet := ExecBlock("WMSA110E",.F.,.F.,{aItens, Len(aItens)})
			Else
				lRet := WMSR130ETI(aItens)
			EndIf
		Else
			WmsMessage(STR0010,WMSA11001,1) //Não há etiquetas marcadas para impressão.
		EndIf
	EndIf
	If lRet
		__lMarkAll := .T.
		AllMark() // Força desmarcar todos
	EndIf
	oMarkBrw:Refresh()	
Return lRet
/*/-----------------------------------------------------------------------------
Solicita informações para a geração das etiquetas
-----------------------------------------------------------------------------/*/
Function WMSA110GER()
Local lRet      := .T.
Local oDlg      := Nil 
Local oBtn      := Nil
Local cQtdEti   := "   "
	DEFINE MSDIALOG oDlg FROM 0, 0 TO 100, 200 TITLE STR0015 PIXEL //Gerar Etiquetas
	@ 10, 10 SAY   STR0014 OF oDlg PIXEL //Quantidade Etiquetas:
	@ 08, 70 MSGET cQtdEti VALID !Empty(cQtdEti) .And. Val(cQtdEti) > 0 OF oDlg PIXEL PICTURE '999'
	@ 30, 51 BUTTON oBtn PROMPT STR0011 SIZE 040,012 OF oDlg PIXEL; // Gerar
	ACTION (GeraEtiq(Val(cQtdEti)),oDlg:End())
	ACTIVATE MSDIALOG oDlg CENTERED
Return lRet
/*/-----------------------------------------------------------------------------
Efetiva geração de etiquetas
-----------------------------------------------------------------------------/*/
Static Function GeraEtiq(nQtdEti)
Local lRet   := .T.
Local nCont  := 1
Local aItens := {}
	For nCont := 1 To nQtdEti
		If Empty(cIdUnitiz := WmsGerUnit(.F.,.T.))
			lRet := .F.
			Exit
		EndIf
		aAdd(aItens,{cIdUnitiz})
	Next nCont
	If lRet
		If WmsQuestion(STR0012,WMSA11003)//Deseja imprimir as etiquetas geradas?
			If ExistBlock("WMSA110E")
				ExecBlock("WMSA110E",.F.,.F.,{aItens, Len(aItens)})
			Else
				WMSR130ETI(aItens)
			EndIf
		EndIf
	Else
		WmsMessage(WmsFmtMsg(STR0016,{{"[VAR01]",cValToChar(Len(aItens))}}),WMSA11004,1) //[VAR01] etiquetas geradas. Revise o parâmetro MV_WMSIDUN.
	EndIf
	oMarkBrw:Refresh()
Return lRet
/*/--------------------------------------------------------------------------------------------
{Protheus.doc} WMSA110REU()
Permite ao cliente reativar uma etiqueta ja utilizada.
@type  Static Function..
@author Time WMS
@since 19/09/2022
@version 1.0
---------------------------------------------------------------------------------------------/*/
Function WMSA110REU()
Local lRet := .F.
Local cQuery := ""
Local cAliasD0Y := GetNextAlias()
Local cIDunit  	:= ""
Local cTipUnit	:= ""

	cQuery := " SELECT D0Y.D0Y_IDUNIT,"
	cQuery +=        " D0Y.D0Y_USADO,"
	cQuery +=        " D0Y.D0Y_TIPUNI"
	cQuery +=   " FROM "+RetSqlName("D0Y")+" D0Y"
	cQuery +=  " WHERE D0Y.D0Y_FILIAL = '"+xFilial("D0Y")+"'"
	cQuery +=    " AND D0Y.D0Y_OK = '"+oMarkBrw:cMark+"'"
	cQuery +=    " AND D0Y.D_E_L_E_T_ = ' '"
	dbUseArea(.T.,'TOPCONN',TcGenQry(,,cQuery),cAliasD0Y,.F.,.T.)
	
	While (cAliasD0Y)->(!EoF())
		//Verifica se etiqueta já usada e se pode ser reutilizada.
		If (cAliasD0Y)->D0Y_USADO == '1' .And. !Empty((cAliasD0Y)->D0Y_TIPUNI) 
			cIDunit := (cAliasD0Y)->D0Y_IDUNIT
			cTipUnit := (cAliasD0Y)->D0Y_TIPUNI
			If lRet := WMSUNID14(cIDunit,cTipUnit)
				WmsMessage(STR0018,WMSA11005) //Etiqueta liberada para utilização.	
			Else
				WmsMessage(STR0019,WMSA11006) //"Etiqueta não pode ser reutilizada, o produto possui saldo vinculado a etiqueta."
			EndIf	
		Else
			WmsMessage(STR0020,WMSA11007) //""Status da etiqueta invalido! Não é possível reutilizar uma Etiqueta não utilizada."
		EndIf
		(cAliasD0Y)->(DbSkip())
	EndDo
	(cAliasD0Y)->(DbCloseArea())
	__lMarkAll := .T.
		AllMark() // Força desmarcar todos antes de atualizar o filtro
Return lRet

/*/--------------------------------------------------------------------------------------------
{Protheus.doc} WMSUNID14()
Verificar se existe saldo na tabela D14 com qualquer produto utilizando a etiqueta do unitizador, caso o saldo esteja zerado, será
possivel reutilizar a etiqueta selecionada no processo de reutilização.
@type  Static Function..
@author Time WMS
@since 19/09/2022
@version 1.0
---------------------------------------------------------------------------------------------/*/
Static Function WMSUNID14(cIDunit,cTipUnit)
Local lRet := .T.
Local cQuery := ""
Local cAliasD14 := GetNextAlias()
Local nSaldo := 0

	cQuery := "  SELECT SUM (D14_QTDEST "
	CQuery += " + D14_QTDEPR "
	cQuery += " - D14_QTDSPR "
	cQuery += " - D14_QTDEMP "
	cQuery += " - D14_QTDBLQ "
	cQuery += ") D14_QTDSLD "
	cQuery +=   " FROM "+RetSqlName("D14")+" D14"
	cQuery +=  " WHERE D14.D14_FILIAL = '"+xFilial("D14")+"'"
	cQuery +=    " AND D14.D14_IDUNIT = '"+cIDunit+"'"
	cQuery +=    " AND D14.D14_CODUNI = '"+cTipUnit+"'"
	cQuery +=    " AND D14.D_E_L_E_T_ = ' '"
	dbUseArea(.T.,'TOPCONN',TcGenQry(,,cQuery),cAliasD14,.F.,.T.)

	nSaldo := (cAliasD14)->D14_QTDSLD
	If nSaldo == 0
		oEtiqUnit := WMSDTCEtiquetaUnitizador():New()
		oEtiqUnit:SetIdUnit(cIDunit)
		oEtiqUnit:SetTipUni(cTipUnit)
		If oEtiqUnit:LoadData()
			If oEtiqUnit:GetIsUsed()
				oEtiqUnit:SetTipUni()
				oEtiqUnit:SetUsado("2")
				oEtiqUnit:UpdateD0Y()
			EndIf
		EndIf
	else
		lRet := .F.	//Encontrado saldo de um produto usando a etiqueta selecionada.
	EndIf
	(cAliasD14)->(DbCloseArea())

Return lRet
