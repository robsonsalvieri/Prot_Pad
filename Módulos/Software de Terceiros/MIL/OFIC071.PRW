#INCLUDE "PROTHEUS.CH"
#INCLUDE 'TOPCONN.CH'
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "OFIC071.CH"
/*/{Protheus.doc} OFIC071()
Consulta Itens das NF Entrada - com Endereço DMS (LOCALI2)

@author Andre Luis Almeida
@since 09/05/2024
@version 1.0
@return NIL
/*/
Function OFIC071()
Private cCadastro := STR0001 // Consulta Itens das NF Entrada - Endereço DMS
Private aRotina   := {} // Necessario deixar em branco para poder chamar a Consulta de outras rotinas

// Browse NFs Entrada
oBrwNFs := FWmBrowse():New()
oBrwNFs:SetAlias("SF1")
oBrwNFs:SetDescription(cCadastro)
oBrwNFs:AddButton(STR0002,{ || OC0710021_Visualizar( 1 , STR0002 ) } ) // Visualizar Todos os Itens
oBrwNFs:AddButton(STR0003,{ || OC0710021_Visualizar( 2 , STR0003 ) } ) // Visualizar Itens com Endereço DMS
oBrwNFs:AddButton(STR0004,{ || OC0710021_Visualizar( 3 , STR0004 ) } ) // Visualizar Itens sem Endereço DMS
oBrwNFs:SetUseFilter()
oBrwNFs:SetMenuDef("")
oBrwNFs:SetWalkThru(.F.)
oBrwNFs:SetAmbiente(.F.)
oBrwNFs:DisableDetails()
oBrwNFs:ForceQuitButton()
oBrwNFs:Activate()

Return

/*/{Protheus.doc} OC0710021_Visualizar
Lista Itens da NF Entrada selecionada

@author Andre Luis Almeida
@since 09/05/2024
@version 1.0
@return NIL
/*/
Static Function OC0710021_Visualizar( nTp , cTitulo )
Local cQuery  := ""
Local cAlias  := "SQLSD1"
Local cLocPad := ""
Local cLocal2 := ""
Local aIntCab := {}
Local aIntIte := {}
Local lOk     := .f.
//
aAdd(aIntCab,{RetTitle("B1_GRUPO")  ,"C", 25,"@!"}) // Grupo
aAdd(aIntCab,{RetTitle("B1_CODITE") ,"C", 55,"@!"}) // Codigo do Item
aAdd(aIntCab,{RetTitle("B1_DESC")   ,"C",200,"@!"}) // Descrição
aAdd(aIntCab,{RetTitle("B1_LOCPAD") ,"C", 55,"@!"}) // Local Padrão
aAdd(aIntCab,{RetTitle("B5_LOCALI2"),"C", 55,"@!"}) // Endereço DMS
//
cQuery := "SELECT SB1.R_E_C_N_O_ AS RECSB1"
cQuery += "  FROM " + RetSqlName("SD1") + " SD1 "
cQuery += "  JOIN " + RetSqlName("SB1") + " SB1 ON SB1.B1_FILIAL='"+xFilial("SB1")+"' AND SB1.B1_COD=SD1.D1_COD AND SB1.D_E_L_E_T_=' ' "
cQuery += " WHERE SD1.D1_FILIAL  = '" + SF1->F1_FILIAL  + "'"
cQuery += "   AND SD1.D1_DOC     = '" + SF1->F1_DOC     + "'"
cQuery += "   AND SD1.D1_SERIE   = '" + SF1->F1_SERIE   + "'"
cQuery += "   AND SD1.D1_FORNECE = '" + SF1->F1_FORNECE + "'"
cQuery += "   AND SD1.D1_LOJA    = '" + SF1->F1_LOJA + "'"
cQuery += "   AND SD1.D_E_L_E_T_ = ' ' "
cQuery += " ORDER BY SB1.B1_GRUPO , SB1.B1_CODITE "
dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery ), cAlias, .F., .T. )
while !(cAlias)->(eof())
	SB1->(DbGoto( (cAlias)->(RECSB1) ))
	SB5->(DbSetOrder(1))
	SB5->(DbSeek( xFilial("SB5")+SB1->B1_COD))
	cLocPad := FM_PRODSBZ(SB1->B1_COD,"SB1->B1_LOCPAD")
	cLocal2 := FM_PRODSBZ(SB1->B1_COD,"SB5->B5_LOCALI2")
	lOk     :=  (nTp == 1) // Todos os Itens
	If nTp == 2 .and. !Empty(cLocal2) // Com Endereço
		lOk := .t.
	ElseIf nTp == 3 .and. Empty(cLocal2) // Sem Endereço
		lOk := .t.
	EndIf
	If lOk
		aAdd(aIntIte,{	SB1->B1_GRUPO ,;
						SB1->B1_CODITE ,; 
						SB1->B1_DESC ,;
						cLocPad ,;
						cLocal2 })
	EndIf
	(cAlias)->(DBSkip())
enddo
//
(cAlias)->(DBCloseArea())
DbSelectArea("SD1")
//
If len(aIntIte) == 0
	FMX_HELP("OFIC071",STR0005+CHR(13)+CHR(10)+CHR(13)+CHR(10)+cTitulo) // Não existem dados para esta Consulta.
Else
	FGX_VISINT( cTitulo , Alltrim(SF1->F1_DOC)+" - "+SF1->F1_SERIE , aIntCab , aIntIte , .f. )
EndIf
//
Return