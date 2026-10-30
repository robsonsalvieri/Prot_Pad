#Include "WMSMODELEVENTWMSA300.CH"
#Include "PROTHEUS.CH"
#Include "FWMVCDEF.CH"


//-------------------------------------------------------------------
Static __nAcao := 0
Function WMSA300OPC(nAcao)
	If ValType(nAcao) == "N"
		__nAcao := nAcao
	EndIf
Return __nAcao

CLASS WMSModelEventWMSA300 FROM FWModelEvent
	METHOD New() CONSTRUCTOR
	METHOD Destroy()
	METHOD Activate(oModel, lCopy)
	METHOD BeforeTTS(oModel, cModelId)
	METHOD After(oModel, cModelId, cAlias, lNewRecord)
	METHOD InTTS(oModel, cModelId)
	METHOD AfterTTS(oModel, cModelId)

	METHOD ModelPreVld(oModel, cModelId)
	METHOD ModelPosVld(oModel, cModelId)
ENDCLASS

METHOD New() CLASS WMSModelEventWMSA300
Return
 
METHOD Destroy()  Class WMSModelEventWMSA300
Return

METHOD Activate(oModel, lCopy) Class WMSModelEventWMSA300
	If oModel:GetOperation() == MODEL_OPERATION_INSERT
		// O modelo precisa sofrer alteração
		oModel:LoadValue('DCNMASTER','DCN_STATUS','1')
		oModel:LoadValue('DCNMASTER','DCN_NUMSEQ',ProxNum())
		oModel:LoadValue('DCNMASTER','DCN_ACAO',SuperGetMV('MV_WM300EN',.F., '1'))
	ElseIf oModel:GetOperation() == MODEL_OPERATION_UPDATE
		If WMSA300OPC() == 4
			oModel:LoadValue('DCNMASTER','DCN_STATUS','2')
		ElseIf WMSA300OPC() == 5
			oModel:LoadValue('DCNMASTER','DCN_STATUS','3')
			oModel:LoadValue('DCNMASTER','DCN_DTFIM',IIf(Empty(oModel:GetValue('DCNMASTER','DCN_DTFIM')),DDataBase,oModel:GetValue('DCNMASTER','DCN_DTFIM')))
			oModel:LoadValue('DCNMASTER','DCN_HRFIM',IIf(Empty(oModel:GetValue('DCNMASTER','DCN_HRFIM')),SubStr(Time(),1,TamSX3("DCN_HRFIM")[1]),oModel:GetValue('DCNMASTER','DCN_HRFIM')))
		EndIf
	EndIf
Return
//-------------------------------------------------------------------
// Método que é chamado pelo MVC quando ocorrer as ações do commit antes da transação.
//-------------------------------------------------------------------
METHOD BeforeTTS(oModel, cModelId) CLASS WMSModelEventWMSA300
Return

//-------------------------------------------------------------------
// Método que é chamado pelo MVC quando ocorrer as ações do commit
// depois da gravação de cada submodelo (field ou cada linha de uma grid)
//-------------------------------------------------------------------
METHOD After(oModel, cModelId, cAlias, lNewRecord) CLASS WMSModelEventWMSA300
Local lRet      := .T.
Return lRet

//-------------------------------------------------------------------
// Método que é chamado pelo MVC quando ocorrer as ações do commit
// Após as gravações porém antes do final da transação
//-------------------------------------------------------------------
METHOD InTTS(oModel, cModelId) CLASS WMSModelEventWMSA300
Local lRet      := .T.
Local cFunExe   := ""
Local cQuery    := ""
Local cAliasQry := Nil
Local oEstEnder := Nil
	If oModel:GetOperation() == MODEL_OPERATION_UPDATE
		If oModel:GetValue('DCNMASTER','DCN_STATUS') == '3'
			// Efetua a execução da função
			DCM->(dbSetOrder(1))
			If DCM->(dbSeek(xFilial('DCM')+oModel:GetValue('DCNMASTER','DCN_OCORR'), .F.)) .And. !Empty(cFunExe:=AllTrim(DCM->DCM_FUNEXE))
				cFunExe  += If(!('('$cFunExe),'()','')
				cFunExe  := StrTran(cFunExe,'"',"'")
				lRet := &(cFunExe)
				lRet := If(!(lRet==NIL).And.ValType(lRet)=='L', lRet, .T.)
			EndIf
			// Atualiza o status do endereço se não houverem ocorrencias em aberto
			If lRet
				cQuery := " SELECT 1"
				cQuery +=   " FROM "+RetSqlName("DCN")+" DCN"
				cQuery +=  " WHERE DCN.DCN_FILIAL = '"+xFilial("DCN")+"'"
				cQuery +=    " AND DCN.DCN_STATUS <> '3'"
				cQuery +=    " AND DCN.DCN_NUMSEQ <> '"+oModel:GetValue('DCNMASTER','DCN_NUMSEQ')+"'"
				cQuery +=    " AND DCN.DCN_LOCAL = '"+oModel:GetValue('DCNMASTER','DCN_LOCAL')+"'"
				cQuery +=    " AND DCN.DCN_ENDER = '"+oModel:GetValue('DCNMASTER','DCN_ENDER')+"'"
				cQuery +=    " AND DCN.D_E_L_E_T_ = ' '" 
				cQuery := ChangeQuery(cQuery)
				cAliasQry := GetNextAlias()
				DbUseArea(.T.,'TOPCONN',TCGENQRY(,,cQuery),cAliasQry,.F.,.T.)
				If (cAliasQry)->(Eof())
					oEstEnder := WMSDTCEstoqueEndereco():New()
					oEstEnder:oEndereco:SetArmazem(oModel:GetValue('DCNMASTER','DCN_LOCAL'))
					oEstEnder:oEndereco:SetEnder(oModel:GetValue('DCNMASTER','DCN_ENDER'))
					// Atualiza o status do endereço
					oEstEnder:UpdEnder(.T.)
					oEstEnder:Destroy()
				EndIf
				(cAliasQry)->(dbCloseArea())
			EndIf
		EndIf
	EndIf
Return lRet

//-------------------------------------------------------------------
// Método que é chamado pelo MVC quando ocorrer as ações do  após a transação.
//-------------------------------------------------------------------
METHOD AfterTTS(oModel, cModelId) CLASS WMSModelEventWMSA300
Return

//-------------------------------------------------------------------
// Método que é chamado pelo MVC quando ocorrer as ações de pre validação do Model
//-------------------------------------------------------------------
METHOD ModelPreVld(oModel, cModelId) CLASS WMSModelEventWMSA300
Local lRet := .T.

Return lRet

//-------------------------------------------------------------------
// Método que é chamado pelo MVC quando ocorrer as ações de pos validação do Model
//-------------------------------------------------------------------
METHOD ModelPosVld(oModel, cModelId) CLASS WMSModelEventWMSA300
Local lRet    := .T.
Local cHorFim := StrTran(oModel:GetValue('DCNMASTER','DCN_HRFIM'),":"," ")
	If oModel:GetOperation() == MODEL_OPERATION_UPDATE
		If oModel:GetValue('DCNMASTER','DCN_STATUS') == '3' 
			If Empty(oModel:GetValue('DCNMASTER','DCN_ACAO'))
				WmsHelp(STR0001,STR0002,"ModelPosVld") //Ação não informada! // Informe a ação para permitir o encerramento
				lRet := .F.
			EndIf
			// Ajusta data e hora
			If Empty(oModel:GetValue('DCNMASTER','DCN_DTFIM'))
				WmsHelp(STR0003,STR0004,"ModelPosVld") // Data Final não informada! // Informe a data final para permitir o encerramento
				lRet := .F.
			EndIf
			
			If Empty(cHorFim)
				WmsHelp(STR0005,STR0006,"ModelPosVld") // Hora final não informada! // Informe a hora final para permitir o encerramento
				lRet := .F.
			EndIf
		EndIf
	EndIf
Return lRet