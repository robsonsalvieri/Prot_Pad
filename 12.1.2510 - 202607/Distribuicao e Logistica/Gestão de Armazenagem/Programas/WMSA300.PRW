#Include "PROTHEUS.CH" 
#include "WMSA300.CH"  
#include "FWMVCDEF.CH"

#Define WMSA30001 "WMSA30001"
#Define WMSA30002 "WMSA30002"
#Define WMSA30003 "WMSA30003"

//-------------------------------------
/*/{Protheus.doc} WMSA300
Manutencao do Registro de Ocorrencias
@author SGUAD WMS Protheus
@since 08/26/2002
@version 2.0                   
/*/
//-------------------------------------
Static oBrowse    := Nil
Function WMSA300()
Local nTime := SuperGetMV('MV_WMSREFS',.F.,10) // Tempo em segundos para refresh da tela (Default = 10 segundos)
	// Somente autorizado para OMS e WMS
	If AMiIn(39,42)
		If !(ValType(SuperGetMV('MV_WM300EN',.F., '1')) == "C")
			WmsMessage(STR0023,WMSA30002,1) // "Tipo do parâmetro MV_WM300EN inválido, deve ser alterado para 'C'."
		Else	
			If Pergunte('WMSA300',.T.)
				DCN->(DbSetOrder(1))
				oBrowse := FWMBrowse():New()
				oBrowse:SetAlias("DCN")
				oBrowse:SetMenuDef("WMSA300")
				oBrowse:SetDescription(STR0008) // Registro de Ocorrências
				oBrowse:DisableDetails()
				oBrowse:SetAmbiente(.F.)
				oBrowse:SetWalkThru(.F.)
				oBrowse:SetFixedBrowse(.T.)
				oBrowse:SetFilterDefault("@"+Filtro())
				oBrowse:SetParam({|| SelFiltro() })
				oBrowse:SetTimer({|| RefreshBrw() }, Iif(nTime<=0, 3600, nTime) * 1000)
				oBrowse:SetIniWindow({||oBrowse:oTimer:lActive := (MV_PAR10 < 4)})
				oBrowse:AddLegend("DCN->DCN_STATUS=='1'","GREEN" ,STR0020) // Ocorrencia Registrada
				oBrowse:AddLegend("DCN->DCN_STATUS=='2'","YELLOW",STR0021) // Ocorrencia Em Aguardo
				oBrowse:AddLegend("DCN->DCN_STATUS=='3'","RED"   ,STR0022)  // Ocorrencia Encerrada
				oBrowse:SetProfileID('DCN')
				oBrowse:Activate()
			EndIf
		EndIf
	EndIf
Return (Nil)
//--------------------------------------------------
/*/{Protheus.doc} MenuDef
Função MenuDef
@author  Guilherme A. Metzger
@since   03/04/2017
@version 1.0
/*/
//--------------------------------------------------
Static Function MenuDef()
Local aRotina := {}

	ADD OPTION aRotina TITLE STR0001 ACTION 'AxPesqui'        OPERATION 1 ACCESS 0 //Pesquisar
	ADD OPTION aRotina TITLE STR0002 ACTION 'VIEWDEF.WMSA300' OPERATION 2 ACCESS 0 //Visualizar
	ADD OPTION aRotina TITLE STR0003 ACTION 'VIEWDEF.WMSA300' OPERATION 3 ACCESS 0 //Incluir
	ADD OPTION aRotina TITLE STR0004 ACTION 'WMSA300MEN(4)'   OPERATION 4 ACCESS 0 //Alterar
	ADD OPTION aRotina TITLE STR0005 ACTION 'WMSA300MEN(5)'   OPERATION 4 ACCESS 0 //Encerrar
	ADD OPTION aRotina TITLE STR0006 ACTION 'WMSA300MEN(6)'   OPERATION 5 ACCESS 0 //Excluir
	//Ponto de entrada utilizado para inserir novas opções no array aRotina
	If ExistBlock("DLG300MNU")
		ExecBlock("DLG300MNU",.F.,.F.)
	EndIf
Return aRotina
//----------------------------------------------------------
// Função ModelDef
//----------------------------------------------------------
Static Function ModelDef()
Local oModel    := MPFormModel():New('WMSA300')
Local oStruDCN  := FWFormStruct(1, 'DCN')
Local oWmsEvent := WMSModelEventWMSA300():New() // Evento de validação e commit customizados
	oModel:AddFields('DCNMASTER', /*cOwner*/, oStruDCN)
	oModel:InstallEvent("WMSW300", /*cOwner*/, oWmsEvent)
Return oModel
//----------------------------------------------------------
// Função ViewDef
//----------------------------------------------------------
Static Function ViewDef()
Local oModel   := FWLoadModel('WMSA300')
Local oView    := FWFormView():New()
Local oStruDCN := FWFormStruct(2, 'DCN')
	oView:SetModel(oModel)
	
	oStruDCN:RemoveField("DCN_CODINV")

	If oModel:GetOperation() == MODEL_OPERATION_INSERT
		oStruDCN:SetProperty("DCN_STATUS",MVC_VIEW_CANCHANGE,.F.)
	EndIf
	oStruDCN:SetProperty("DCN_NUMSEQ",MVC_VIEW_CANCHANGE,.F.)

	oView:AddField('VIEWDCN', oStruDCN, 'DCNMASTER')
Return oView
//-------------------------------------------------------------------//
//--------------------Seleção do filtro tecla F12--------------------//
//-------------------------------------------------------------------//
Static Function SelFiltro()
Local nPos := oBrowse:At()
Local lRet := .T.

	If (lRet := Pergunte('WMSA300',.T.))
		oBrowse:oTimer:lActive := (MV_PAR10 < 4)
		oBrowse:SetFilterDefault("@"+Filtro())
		oBrowse:Refresh(.T.)
	EndIf
Return lRet
//-------------------------------------------------------------------//
//------------Refresh do Browse para Recarregar a Tela---------------//
//-------------------------------------------------------------------//
Static Function RefreshBrw()
Local nPos := oBrowse:At()

	Pergunte('WMSA300',.F.) // Força recarregar as perguntas
	oBrowse:SetFilterDefault("@"+Filtro())
	
	If MV_PAR10 == 1
		oBrowse:Refresh(.T.)
	ElseIf MV_PAR10 == 2
		oBrowse:Refresh(.F.)
		oBrowse:GoBottom()
	Else
		oBrowse:Refresh(.F.)
		oBrowse:GoTo(nPos)
	EndIf
	
Return .T.
//--------------------------------------------------
/*/{Protheus.doc} Filtro
Montagem do filtro para o browse principal da rotina
@author  Guilherme A. Metzger
@since   03/04/2017
@version 1.0
/*/
//--------------------------------------------------
Static Function Filtro()
Local cFiltro := ""
	
	cFiltro += " DCN_FILIAL = '"+xFilial('DCN')+"'"
	If MV_PAR01 < 4
		cFiltro += " AND DCN_STATUS = '"+LTrim(Str(MV_PAR01))+"'"
	EndIf
	cFiltro += " AND DCN_LOCAL  >= '"+MV_PAR02+"'"
	cFiltro += " AND DCN_LOCAL  <= '"+MV_PAR03+"'"
	cFiltro += " AND DCN_NUMERO  >= '"+MV_PAR04+"'"
	cFiltro += " AND DCN_NUMERO  <= '"+MV_PAR05+"'"
	cFiltro += " AND DCN_DTINI   >= '"+DtoS(MV_PAR06)+"'"
	cFiltro += " AND DCN_DTINI   <= '"+DtoS(MV_PAR07)+"'"
	cFiltro += " AND DCN_PROD >= '"+MV_PAR08+"'"
	cFiltro += " AND DCN_PROD <= '"+MV_PAR09+"'"
	cFiltro += " AND D_E_L_E_T_ = ' '"
	
Return cFiltro
//-------------------------------------------------------
Function WMSA300MEN(nPos)
//-------------------------------------------------------
Local lRet      := .T.
Local aRotina   := MenuDef()
Local cQuery    := ""
Local cAliasD12 := Nil
	// Permite alterar somente ocorrências não finalizadas
	If (DCN->DCN_STATUS) == '3' 
		WmsMessage(STR0024,WMSA30001) // Ocorrência já encerrada! 
		lRet := .F.
	ElseIf nPos == 6
		// Valida se é permitido excluir a ocorrencia
		cQuery := "SELECT 1"
		cQuery +=  " FROM "+RetSqlName("D12")+ " D12"
		cQuery += " WHERE D12.D12_FILIAL = '"+xFilial("D12")+"'"
		cQuery +=   " AND D12.D12_STATUS <> '0'"
		cQuery +=   " AND D12.D12_OCORRE = '"+DCN->DCN_OCORR+"'"
		cQuery +=   " AND D12.D12_NUMERO = '"+DCN->DCN_NUMERO+"'"
		cQuery +=   " AND D12.D_E_L_E_T_ = ' '"
		cQuery := ChangeQuery(cQuery)
		cAliasD12 := GetNextAlias()
		DbUseArea(.T.,'TOPCONN',TcGenQry(,,cQuery),cAliasD12,.F.,.T.)
		If (cAliasD12)->(!Eof())
			WmsMessage("Ocorrencia relacionada com movimentação WMS, exclusão não permitida!",WMSA30003) // Ocorrencia relacionada com movimentação WMS, exclusão não permitida!
			
			lRet := .F.
		EndIf
		(cAliasD12)->(dbCloseArea())
	EndIf

	If lRet
		WMSA300OPC(nPos)
		FWExecView(aRotina[nPos][1],"WMSA300",aRotina[nPos][4],,{ || .T. },{ || .T. },0,,{ || .T. },,, )
	EndIf
Return Nil

