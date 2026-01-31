#Include "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "FWBROWSE.CH"
#Include "OFIC171.CH"

/*/{Protheus.doc} OFIC171
Consulta Status dos Pedidos em Aberto
@author João Carlos da Silva
@since 11/08/2025
@version 1.0
@type function
/*/
Function OFIC171( cFilVS1 , cNroVS1 )

	Private oBrwOC171
	Private cFilDefault := ""
	Private cFilterSpec := ""
	Private lExistPerg  := OF1710059_ExistPergOFIXA018() // Existe o pergunte OFIXA018

	cFilDefault := "SELECT TMPVS3.VS3_NUMORC"
	cFilDefault += " FROM " + RetSqlName("VS3") + " TMPVS3"
	cFilDefault += " WHERE TMPVS3.D_E_L_E_T_ = ' '
	cFilDefault += " AND TMPVS3.VS3_FILIAL = VS1_FILIAL"
	cFilDefault += " AND TMPVS3.VS3_NUMORC = VS1_NUMORC"
	cFilDefault += " AND VS1_TIPORC='P'"
	cFilDefault += " AND VS1_STATUS='0'"
	cFilDefault += " AND VS1_PEDSTA='0'"

	cFilterSpec := OF1710039_MostraVencidos() // Mostra os orçamentos vencidos

	DbSelectArea("VS1")
	oBrwOC171 := FWMBrowse():New()
	oBrwOC171:SetAlias("VS1")
	oBrwOC171:DisableLocate()
	oBrwOC171:DisableDetails()
	oBrwOC171:SetAmbiente(.F.)
	oBrwOC171:SetWalkthru(.F.)
	oBrwOC171:SetDescription(STR0001) // Consulta Status dos Pedidos em Aberto
	oBrwOC171:SetMenuDef("OFIC171") // Mostra os botões da rotina
	oBrwOC171:SetFilterDefault( "@ EXISTS (" + cFilDefault + If(!Empty(cFilterSpec), cFilterSpec, "") + ")" )
	oBrwOC171:AddLegend( " OF1710019_AddLegend()=='1' " , "BR_VERDE"   , STR0003 ) // Sem Pendência
	oBrwOC171:AddLegend( " OF1710019_AddLegend()=='2' " , "BR_LARANJA" , STR0004 ) // Pendente por Compra
	oBrwOC171:AddLegend( " OF1710019_AddLegend()=='3' " , "BR_AZUL"    , STR0005 ) // Pendente por Transferência
	oBrwOC171:SetInsert(.f.)
	oBrwOC171:SetUseFilter(.t.)
	oBrwOC171:lOptionReport := .f.
	oBrwOC171:Activate()

Return NIL

/*/{Protheus.doc} MenuDef()
Função para criação do menu 
@author João Carlos da Silva
@since 11/08/2025
@version 1.0
@type function
/*/
Static Function MenuDef()
Local aRotina := {}

ADD OPTION aRotina TITLE STR0006 ACTION 'OF1710029_VisualizaOrcamento' OPERATION 2 ACCESS 0 // Visualiza Orçamento
ADD OPTION aRotina TITLE STR0007 ACTION 'OF1710039_MostraVencidos'     OPERATION 2 ACCESS 0 // Mostra Vencidos
ADD OPTION aRotina TITLE STR0008 ACTION 'OF1710049_Legenda'            OPERATION 2 ACCESS 0 // Legenda

Return aRotina

/*/{Protheus.doc} OF1710019_AddLegend
Retorna se o registro pertence à legenda do tipo solicitado
@author João Carlos da Silva
@since 11/08/2025
@version 1.0
@type function
/*/
Function OF1710019_AddLegend(cTipo, cFilOrc, cNumOrc, cTipOrc, cStatus)
Local aArea   := GetArea()
Local cQuery  := ""
Local cRet    := ""

Local lAberto := .f.
Local lCompra := .f.
Local lTransf := .f.

cQuery += "SELECT VS3_QTDAGU, VS3_QTDTRA"
cQuery += " FROM " + RetSqlName("VS3") + " VS3"
cQuery += " JOIN " + RetSqlName("VS1") + " VS1"
cQuery += " ON VS1_FILIAL = VS3_FILIAL"
cQuery += " AND VS1_NUMORC = VS3_NUMORC"
cQuery += " AND VS1.D_E_L_E_T_ = ' '"
cQuery += " AND VS1_TIPORC='P'"
cQuery += " AND VS1_STATUS='0'"
cQuery += " AND VS1_PEDSTA='0'"
cQuery += " WHERE VS3_FILIAL = '" + VS1->VS1_FILIAL + "'"
cQuery += " AND VS3_NUMORC = '" + VS1->VS1_NUMORC + "'"
cQuery += " AND VS3.D_E_L_E_T_ = ' '"

If !Empty(cFilterSpec)
	cQuery += cFilterSpec // Mostra os orçamentos vencidos
EndIf

dbUseArea( .T. , "TOPCONN" , TcGenQry(,,cQuery) , "TMPVS3" , .T. , .F.)
while TMPVS3->(!Eof())
	lAberto := .t.
	lCompra := TMPVS3->VS3_QTDAGU <> 0
	lTransf := TMPVS3->VS3_QTDTRA <> 0
	TMPVS3->(dbSkip())
End
TMPVS3->(dbCloseArea())
RestArea(aArea)

If lAberto
	lAberto := !lCompra .and. !lTransf
EndIf

cRet := If(lAberto, "1", If(lCompra, "2", If(lTransf, "3", ""))) //1=Sem Pendência, 2=Pendente por Compra, 3=Pendente por Transferência

Return( cRet )

/*/{Protheus.doc} OF1710029_VisualizaOrcamento
Visualiza o orçamento
@author João Carlos da Silva
@since 11/08/2025
@version 1.0
@type function
/*/
Function OF1710029_VisualizaOrcamento()

OFIC170( VS1->VS1_FILIAL, VS1->VS1_NUMORC )

Return

/*/{Protheus.doc} OF1710039_MostraVencidos
Mostra os orçamentos vencidos
@author João Carlos da Silva
@since 11/08/2025
@version 1.0
@type function
/*/
Function OF1710039_MostraVencidos(cAlias,nReg,nOpc)
	Local xMV_PAR01
	Local xMV_PAR02
	Local xMV_PAR03

	Local nFilQtdDia
	Local dFilDatIni
	Local dFilDatFim

	Default cAlias := ""

	If lExistPerg // Existe o pergunte OFIXA018
		xMV_PAR01 := MV_PAR01
		xMV_PAR02 := MV_PAR02
		xMV_PAR03 := MV_PAR03

		If Pergunte("OFIXA018", .t.)
			nFilQtdDia := MV_PAR01
			dFilDatIni := MV_PAR02
			dFilDatFim := MV_PAR03

			cFilterSpec := ""

			If nFilQtdDia > 0
				cFilterSpec += " AND VS1_DATORC BETWEEN '" + DtoS(ddatabase - nFilQtdDia) + "' AND '" + DtoS(dDataBase) + "'"
			EndIf

			If ! Empty( dFilDatIni ) .AND. ! Empty( dFilDatFim )
				cFilterSpec += " AND VS1_DATORC BETWEEN '" + DtoS(dFilDatIni) + "' AND '" + DtoS(dFilDatFim) + "'"
			EndIf

			If !Empty( cAlias )
				oBrwOC171:SetFilterDefault( "@ EXISTS (" + cFilDefault + If(!Empty(cFilterSpec), cFilterSpec, "") + ")" )
				oBrwOC171:Refresh()	
			EndIf
		EndIf

		MV_PAR01 := xMV_PAR01
		MV_PAR02 := xMV_PAR02
		MV_PAR03 := xMV_PAR03
	EndIf

Return( cFilterSpec )

/*/{Protheus.doc} OF1710049_Legenda
Exibe a tela com as legendas
@author João Carlos da Silva
@since 11/08/2025
@version 1.0
@type function
/*/
Function OF1710049_Legenda()
	Local oLegenda as Object
	oLegenda := FWLegend():New()
	oLegenda:Add( "" , "BR_VERDE"   , STR0003 ) // Sem Pendência
	oLegenda:Add( "" , "BR_LARANJA" , STR0004 ) // Pendente por Compra
	oLegenda:Add( "" , "BR_AZUL"    , STR0005 ) // Pendente por Transferência
	oLegenda:Activate()
	oLegenda:View()
	oLegenda:Deactivate()
	FreeObj(oLegenda)
Return

/*/{Protheus.doc} OF1710059_ExistPergOFIXA018
Retorna se existe o pergunte OFIXA018
@author João Carlos da Silva
@since 11/08/2025
@version 1.0
@type function
/*/
Static Function OF1710059_ExistPergOFIXA018()
	Local oObjSX1 := FWSX1Util():New()

	oObjSX1:AddGroup("OFIXA018")
	oObjSX1:SearchGroup()

Return( Len(oObjSX1:GetGroup("OFIXA018")[2]) > 0 )
