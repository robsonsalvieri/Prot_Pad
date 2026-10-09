#INCLUDE "PROTHEUS.CH"  
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "WMSC040.CH"

//---------------------------------------------------------------
/*/{Protheus.doc} WMSC040
Consulta dos itens dos volumes
@author felipe.m
@since 22/03/2016
@version 1.0
@example
(examples)
@see (links_or_references)
/*/
//---------------------------------------------------------------
Function WMSC040()
Static oBrw := Nil

Local aSx3   := {}
Local aField := {}

	// Permite efetuar validações, apresentar mensagem e abortar o programa quando desejado
	If !WMSChkPrg(FunName(),"1")
		Return Nil
	EndIf
	
	//[n][01] Título da coluna
	//[n][02] Code-Block de carga dos dados
	//[n][03] Tipo de dados
	//[n][04] Máscara
	//[n][05] Alinhamento (0=Centralizado, 1=Esquerda ou 2=Direita)
	//[n][06] Tamanho
	//[n][07] Decimal
	//[n][08] Indica se permite a edição
	//[n][09] Code-Block de validação da coluna após a edição
	//[n][10] Indica se exibe imagem
	//[n][11] Code-Block de execução do duplo clique
	//[n][12] Variável a ser utilizada na edição (ReadVar)
	//[n][13] Code-Block de execução do clique no header
	//[n][14] Indica se a coluna está deletada
	//[n][15] Indica se a coluna será exibida nos detalhes do Browse
	//[n][16] Opções de carga dos dados (Ex: 1=Sim, 2=Não)
	aSx3 := TamSx3("DCV_CODVOL")
	aAdd(aField,{GetSx3Cache("DCV_CODVOL","X3_TITULO"),{|| DCV->DCV_CODVOL},aSx3[3],GetSx3Cache("DCV_CODVOL","X3_PICTURE"),1,aSx3[1],aSx3[2],.F.,Nil,Nil,Nil,Nil,Nil,.F.,.T.,2}) // Código do volume
	aSx3 := TamSx3("DCU_ROMEMB")
	aAdd(aField,{GetSx3Cache("DCU_ROMEMB","X3_TITULO"),{|| GetCodRom()    },aSx3[3],GetSx3Cache("DCU_ROMEMB","X3_PICTURE"),1,aSx3[1],aSx3[2],.F.,Nil,Nil,Nil,Nil,Nil,.F.,.T.,2}) // Código do volume
	
	oBrw := FWMBrowse():New()
	oBrw:SetAlias("DCV")
	oBrw:SetDescription(STR0001) // "Itens do Volume"
	oBrw:SetMenudef("WMSC040")
	oBrw:SetFilterDefault("@ "+FiltroDCV())
	oBrw:SetParam({|| SelFiltro() })
	oBrw:SetFields(aField)
	oBrw:AddLegend("DCV->DCV_STATUS=='1'", "YELLOW", STR0002) // "Não Liberado"
	oBrw:AddLegend("DCV->DCV_STATUS=='2'", "BLUE"  , STR0003) // "Liberado"
	oBrw:AddLegend("DCV->DCV_STATUS=='3'", "RED"   , STR0006) // "Separação Em Andamento"
	oBrw:DisableDetails()
	oBrw:Activate()
Return Nil
//---------------------------------------------------------------
/*/{Protheus.doc} MenuDef
MenuDef
@author felipe.m
@since 22/03/2016
@version 1.0
@example
(examples)
@see (links_or_references)
/*/
//---------------------------------------------------------------
Static Function MenuDef()
Local aRotina := {}
	
	ADD OPTION aRotina TITLE STR0004 ACTION 'AxPesqui'        OPERATION 1 ACCESS 0 DISABLE MENU // "Pesquisar"
	ADD OPTION aRotina TITLE STR0005 ACTION 'VIEWDEF.WMSC040' OPERATION 2 ACCESS 0 DISABLE MENU // "Visualizar"
Return aRotina
//---------------------------------------------------------------
/*/{Protheus.doc} ModelDef
ModelDef
@author felipe.m
@since 22/03/2016
@version 1.0
@example
(examples)
@see (links_or_references)
/*/
//---------------------------------------------------------------
Static Function ModelDef()
Local oModel  := MPFormModel():New("WMSC040")
Local oStrDCV := FwFormStruct(1,"DCV")

	oModel:AddFields("C040DCV",,oStrDCV)
Return oModel
//---------------------------------------------------------------
/*/{Protheus.doc} ViewDef
ViewDef
@author felipe.m
@since 22/03/2016
@version 1.0
@example
(examples)
@see (links_or_references)
/*/
//---------------------------------------------------------------
Static Function ViewDef()
Local oModel  := FwLoadModel("WMSC040")
Local oView   := FWFormView():New()
Local oStrDCV := FwFormStruct(2,"DCV")

	oView := FWFormView():New()
	oView:SetModel(oModel)
	oView:AddField('C040DCV',oStrDCV)
Return oView
//---------------------------------------------------------------
/*/{Protheus.doc} SelFiltro
Seleciona o filtro do browse por meio do F12
@author felipe.m
@since 22/03/2016
@version 1.0
@example
(examples)
@see (links_or_references)
/*/
//---------------------------------------------------------------
Static Function SelFiltro()
	oBrw:SetFilterDefault("@ "+FiltroDCV())
	oBrw:Refresh()
Return .T.
//---------------------------------------------------------------
/*/{Protheus.doc} FiltroDCV
Filtro que será aplicado na DCV
@author felipe.m
@since 22/03/2016
@version 1.0
@example
(examples)
@see (links_or_references)
/*/
//---------------------------------------------------------------
Static Function FiltroDCV(lShowPerg)
Local cFiltro := ""

Default lShowPerg := .T.

	Pergunte("WMSC040",lShowPerg)
	
	cFiltro +=     " DCV_CODVOL >= '"+MV_PAR03+"' AND DCV_CODVOL <= '"+MV_PAR04+"'"
	cFiltro += " AND DCV_CARGA >= '"+MV_PAR05+"' AND DCV_CARGA <= '"+MV_PAR06+"'"
	cFiltro += " AND DCV_PEDIDO >= '"+MV_PAR07+"' AND DCV_PEDIDO <= '"+MV_PAR08+"'"
	cFiltro += " AND DCV_CODPRO >= '"+MV_PAR09+"' AND DCV_CODPRO <= '"+MV_PAR10+"'"
	cFiltro += " AND DCV_LOTE >= '"+MV_PAR11+"' AND DCV_LOTE <= '"+MV_PAR12+"'"
	cFiltro += " AND DCV_SUBLOT >= '"+MV_PAR13+"' AND DCV_SUBLOT <= '"+MV_PAR14+"'"
	If MV_PAR15 != 3 // Todos
		cFiltro += " AND DCV_STATUS = "+cValtoChar(MV_PAR15)
	EndIf
	If !Empty(MV_PAR16)
		cFiltro += " AND DCV_DATINI >= '"+DtoS(MV_PAR16)+"'"
	EndIf
	If !Empty(MV_PAR17)
		cFiltro += " AND DCV_DATINI <= '"+DtoS(MV_PAR17)+"'"
	EndIf
	cFiltro += " AND EXISTS ( SELECT 1"
	cFiltro +=                " FROM "+RetSqlName("DCU")+" DCU"
	cFiltro +=               " WHERE DCU.DCU_FILIAL = '"+xFilial("DCU")+"'"
	cFiltro +=                 " AND DCU.DCU_FILIAL = DCV_FILIAL"
	cFiltro +=                 " AND DCU.DCU_CODVOL = DCV_CODVOL"
	cFiltro +=                 " AND DCU.DCU_CARGA  >= '"+MV_PAR05+"' AND DCU.DCU_CARGA <= '"+MV_PAR06+"'"
	cFiltro +=                 " AND DCU.DCU_PEDIDO >= '"+MV_PAR07+"' AND DCU.DCU_PEDIDO <= '"+MV_PAR08+"'"
	cFiltro +=                 " AND DCU.DCU_ROMEMB >= '"+MV_PAR01+"' AND DCU.DCU_ROMEMB <= '"+MV_PAR02+"'"
	cFiltro +=                 " AND DCU.D_E_L_E_T_ = ' ' )"
Return cFiltro
//---------------------------------------------------------------
/*/{Protheus.doc} FiltroDCV
Filtro que será aplicado na DCV
@author felipe.m
@since 22/03/2016
@version 1.0
@example
(examples)
@see (links_or_references)
/*/
//---------------------------------------------------------------
Static Function GetCodRom()
Local aAreaAnt := GetArea()
Local cQuery := ""
Local cAliasQry := ""
Local cRomEmb := ""
	
	cQuery := " SELECT DCU.DCU_ROMEMB"
	cQuery +=   " FROM "+RetSqlName("DCU")+" DCU"
	cQuery +=  " WHERE DCU.DCU_FILIAL = '"+xFilial("DCU")+"'"
	cQuery +=    " AND DCU.DCU_CODVOL = '"+DCV->DCV_CODVOL+"'"
	cQuery +=    " AND DCU.D_E_L_E_T_ = ' '"
	cQuery := ChangeQuery(cQuery)
	cAliasQry := GetNextAlias()
	dbUseArea(.T.,'TOPCONN',TcGenQry(,,cQuery),cAliasQry,.F.,.T.)
	If (cAliasQry)->(!Eof())
		cRomEmb := (cAliasQry)->DCU_ROMEMB
	EndIf
	(cAliasQry)->(dbCloseArea())
	
RestArea(aAreaAnt)
Return cRomEmb
