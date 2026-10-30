#INCLUDE "TOTVS.CH"
#INCLUDE "Mata180.ch"
#INCLUDE "TOPCONN.CH"
#INCLUDE "FWMVCDEF.CH"
#include "TbIconn.ch"

Static _lMrpInSMQ := FWAliasInDic("SMQ", .F.) .And. Findfunction("mrpInSMQ")

/*/{Protheus.doc} MATA180API
Eventos padrões do cadastro de roteiros
@author Douglas Heydt
@since 03/03/2021
@version P12.1.30
/*/
CLASS MATA180API FROM FWModelEvent

	DATA lIntegraMRP    AS LOGIC
	DATA lIntegraOnline AS LOGIC
	DATA lPossuiHZ8     AS LOGIC
	DATA lLMTran        AS LOGIC

	METHOD New() CONSTRUCTOR
	METHOD AfterTTS(oModel, cModelId)
	METHOD InTTS()
	METHOD ModelPosVld(oModel, cModelId)

ENDCLASS

METHOD New() CLASS  MATA180API

	::lIntegraMRP    := .F.
	::lIntegraOnline := .F.
	::lPossuiHZ8     := FWAliasInDic("HZ8")
	::lLMTran        := GetSx3Cache("HZ8_LMTRAN", "X3_TAMANHO") > 0
	If AliasInDic("SMI", .F.)
		::lIntegraMRP := IntNewMRP("MRPPRODUCT", @::lIntegraOnline)
	EndIf

Return Self

/*/{Protheus.doc} INTTS
Método que é chamado pelo MVC quando ocorrer as ações do commit Após as gravações
porém antes do final da transação.

@author douglas.heydt
@since 01/10/2024
@version P12
@param oModel  , Object  , Modelo principal
@param cModelId, Caracter, Id do submodelo
@return Nil
/*/
METHOD InTTS(oModel, cID) CLASS MATA180API

	Local aAreaSB5	:= {}
	Local nOpc      := oModel:GetOperation()

	If ::lPossuiHZ8 .And. cID == "MATA180" .And. nOpc == MODEL_OPERATION_UPDATE .And. oModel:getModel("FLD_MRPME"):isModified()
		aAreaSB5 := SB5->(GetArea())

		SB5->(DbSetOrder(1))
		If SB5->(DbSeek(xFilial("SB5")+oModel:GetValue("SB5MASTER","B5_COD"))) .And. SB5->B5_LEADTR <> 0
			Reclock("SB5", .F.)
				SB5->B5_LEADTR := 0
			SB5->(MsUnlock())
		EndIf

		SB5->(RestArea(aAreaSB5))
		aSize(aAreaSB5, 0)
	EndIf

Return

/*/{Protheus.doc} AfterTTS
Método que é chamado pelo MVC quando ocorrer as ações do  após a transação.
Esse evento ocorre uma vez no contexto do modelo principal.

@author Douglas Heydt
@since 03/03/2021
@version P12.1.30
@param oModel  , Object  , Modelo principal
@param cModelId, Caracter, Id do submodelo
@return Nil
/*/
METHOD AfterTTS(oModel, cModelId) CLASS MATA180API
	Local aDadosInc  := {}
	Local cAliasQry  := GetNextAlias()
	Local cBanco     := AllTrim(Upper(TcGetDb()))
	Local cQuery     := ""
	Local oMdlSB5    := oModel:GetModel("SB5MASTER")

	//Só executa a integração se estiver parametrizado como Online
	If ::lIntegraMRP == .F. .Or. ::lIntegraOnline == .F.
		Return
	EndIf

	If _lMrpInSMQ .and. !mrpInSMQ(xFilial("SB5"))
		Return nil
	EndIf

	cQuery +=  " SELECT SB1.B1_FILIAL,  "
	cQuery +=         " SB1.B1_COD,     "
	cQuery +=         " SB1.B1_LOCPAD,  "
	cQuery +=         " SB1.B1_TIPO,    "
	cQuery +=         " SB1.B1_GRUPO,   "
	cQuery +=         " SB1.B1_QE,      "
	cQuery +=         " SB1.B1_EMIN,    "
	cQuery +=         " SB1.B1_ESTSEG,  "
	cQuery +=         " SB1.B1_PE,      "
	cQuery +=         " SB1.B1_TIPE,    "
	cQuery +=         " SB1.B1_LE,      "
	cQuery +=         " SB1.B1_LM,      "
	cQuery +=         " SB1.B1_TOLER,   "
	cQuery +=         " SB1.B1_TIPODEC, "
	cQuery +=         " SB1.B1_RASTRO,  "
	cQuery +=         " SB1.B1_MRP,     "
	cQuery +=         " SB1.B1_REVATU,  "
	cQuery +=         " SB1.B1_EMAX,    "
	cQuery +=         " SB1.B1_PRODSBP, "
	cQuery +=         " SB1.B1_LOTESBP, "
	cQuery +=         " SB1.B1_ESTRORI, "
	cQuery +=         " SB1.B1_APROPRI, "
	cQuery +=         " SB1.B1_CPOTENC, "
	cQuery +=         " SB1.B1_MSBLQL,  "
	cQuery +=         " SB1.B1_CONTRAT, "
	cQuery +=         " SB1.B1_OPERPAD, "
	cQuery +=         " SB1.B1_CCCUSTO, "
	cQuery +=         " SB1.B1_DESC,    "
	cQuery +=         " SB1.B1_GRUPCOM, "
	cQuery +=         " SB1.B1_QB,      "
	cQuery +=         " SB1.B1_UM,      "
	cQuery +=         " SB1.B1_OPC,     "
	cQuery +=         " CASE "
	cQuery +=             " WHEN SB1.B1_MOPC IS NULL THEN ' ' "
	cQuery +=             " ELSE '1' "
	cQuery +=         " END TEMOPC, "
	cQuery +=         " SB1.R_E_C_N_O_, "
	cQuery +=         " SVK.VK_HORFIX,  "
	cQuery +=         " SVK.VK_TPHOFIX, "
	cQuery +=         " SB5.B5_FILIAL,  "
	If ::lPossuiHZ8
		cQuery +=     " HZ8.HZ8_LEADTR, "
		cQuery +=     " HZ8.HZ8_TRANSF, "
		cQuery +=     " HZ8.HZ8_FILCOM, "

		If ::lLMTran
			cQuery += " HZ8.HZ8_LMTRAN, "
		EndIf
	EndIf
	cQuery +=         " SB5.B5_LEADTR, "
	cQuery +=         " SB5.B5_COD, "
	cQuery +=         " CASE "
	cQuery +=             " WHEN SB5.B5_AGLUMRP IN ('1', '6') THEN NULL "
	cQuery +=             " ELSE SB5.B5_AGLUMRP "
	cQuery +=         " END B5_AGLUMRP, "
	cQuery +=         " SAJ.AJ_DESC     "
	cQuery +=  " FROM " + RetSqlName("SB1") + " SB1 "
	cQuery +=  " LEFT OUTER JOIN " + RetSqlName("SVK") + " SVK"
	cQuery +=    " ON SB1.B1_FILIAL  = '" + xFilial("SB1") + "'"
	cQuery +=   " AND SVK.VK_FILIAL  = '" + xFilial("SVK") + "'"
	cQuery +=   " AND SVK.VK_COD     = SB1.B1_COD"
	cQuery +=   " AND SVK.D_E_L_E_T_ = ' '"
	cQuery +=  " LEFT OUTER JOIN " + RetSqlName("SB5") + " SB5"
	cQuery +=    " ON SB5.B5_COD  = SB1.B1_COD  "
	cQuery +=   " AND SB5.D_E_L_E_T_ = ' ' "
	cQuery +=  " LEFT OUTER JOIN " + RetSqlName("SAJ") + " SAJ"
	cQuery +=    " ON SAJ.R_E_C_N_O_ = (SELECT MAX(SAJLST.R_E_C_N_O_) "
	cQuery +=                           " FROM " + RetSqlName("SAJ") + " SAJLST"
	cQuery +=                          " WHERE SAJLST.AJ_FILIAL = '" + xFilial("SAJ") + "' "
	cQuery +=                            " AND SAJLST.AJ_GRCOM  = SB1.B1_GRUPCOM "
	cQuery +=                            " AND SAJLST.D_E_L_E_T_ = ' ') "
	If ::lPossuiHZ8
		cQuery += " LEFT JOIN " + RetSqlName("HZ8") + " HZ8 "
		cQuery +=   " ON HZ8.HZ8_FILIAL = SB5.B5_FILIAL "
		cQuery +=  " AND HZ8.HZ8_PROD   = SB1.B1_COD "
		cQuery +=  " AND HZ8.D_E_L_E_T_ = ' ' "
	EndIf
	cQuery +=   " WHERE SB1.B1_COD = '" + oMdlSB5:GetValue("B5_COD") + "' "
	cQuery +=   " AND SB1.D_E_L_E_T_ = ' ' "
	cQuery +=	" AND SB1.B1_FILIAL  = '" + xFilial("SB1") + "' "
	cQuery +=	" AND SB1.B1_MSBLQL <> '1' "

	If _lMrpInSMQ
		cQuery += " AND (SB5.B5_FILIAL IS NULL "
		cQuery += " 	OR EXISTS (SELECT 1 FROM "+ RetSqlName("SMQ") + " SMQ"
		If "MSSQL" $ cBanco
			cQuery += " WHERE SMQ.MQ_CODFIL LIKE RTRIM(SB5.B5_FILIAL) + '%'"
		Else
			cQuery += " WHERE SMQ.MQ_CODFIL LIKE RTRIM(SB5.B5_FILIAL) || '%'"
		EndIf
		cQuery += " AND SMQ.D_E_L_E_T_ = ' ' )) "
	EndIf

	dbUseArea(.T.,"TOPCONN",TCGENQRY(,,cQuery),cAliasQry,.T.,.T.)

	If (cAliasQry)->(!Eof())

		//Adiciona nova linha no array de inclusão/atualização
		aAdd(aDadosInc, Array(A010APICnt("ARRAY_PROD_SIZE")))

		//Adiciona as informações no array de inclusão/atualização
		aDadosInc[1][A010APICnt("ARRAY_PROD_POS_FILIAL"   )] := (cAliasQry)->B1_FILIAL
		aDadosInc[1][A010APICnt("ARRAY_PROD_POS_PROD"     )] := (cAliasQry)->B1_COD
		aDadosInc[1][A010APICnt("ARRAY_PROD_POS_LOCPAD"   )] := (cAliasQry)->B1_LOCPAD
		aDadosInc[1][A010APICnt("ARRAY_PROD_POS_TIPO"     )] := (cAliasQry)->B1_TIPO
		aDadosInc[1][A010APICnt("ARRAY_PROD_POS_GRUPO"    )] := (cAliasQry)->B1_GRUPO
		aDadosInc[1][A010APICnt("ARRAY_PROD_POS_QE"       )] := (cAliasQry)->B1_QE
		aDadosInc[1][A010APICnt("ARRAY_PROD_POS_EMIN"     )] := (cAliasQry)->B1_EMIN
		aDadosInc[1][A010APICnt("ARRAY_PROD_POS_ESTSEG"   )] := (cAliasQry)->B1_ESTSEG
		aDadosInc[1][A010APICnt("ARRAY_PROD_POS_PE"       )] := (cAliasQry)->B1_PE
		aDadosInc[1][A010APICnt("ARRAY_PROD_POS_TIPE"     )] := M010CnvFld("B1_TIPE"   , (cAliasQry)->B1_TIPE)
		aDadosInc[1][A010APICnt("ARRAY_PROD_POS_LE"       )] := (cAliasQry)->B1_LE
		aDadosInc[1][A010APICnt("ARRAY_PROD_POS_LM"       )] := (cAliasQry)->B1_LM
		aDadosInc[1][A010APICnt("ARRAY_PROD_POS_TOLER"    )] := (cAliasQry)->B1_TOLER
		aDadosInc[1][A010APICnt("ARRAY_PROD_POS_TIPDEC"   )] := M010CnvFld("B1_TIPODEC", (cAliasQry)->B1_TIPODEC)
		aDadosInc[1][A010APICnt("ARRAY_PROD_POS_RASTRO"   )] := M010CnvFld("B1_RASTRO" , (cAliasQry)->B1_RASTRO)
		aDadosInc[1][A010APICnt("ARRAY_PROD_POS_MRP"      )] := M010CnvFld("B1_MRP"    , (cAliasQry)->B1_MRP)
		aDadosInc[1][A010APICnt("ARRAY_PROD_POS_REVATU"   )] := (cAliasQry)->B1_REVATU
		aDadosInc[1][A010APICnt("ARRAY_PROD_POS_EMAX"     )] := (cAliasQry)->B1_EMAX
		aDadosInc[1][A010APICnt("ARRAY_PROD_POS_PROSBP"   )] := M010CnvFld("B1_PRODSBP", (cAliasQry)->B1_PRODSBP)
		aDadosInc[1][A010APICnt("ARRAY_PROD_POS_LOTSBP"   )] := (cAliasQry)->B1_LOTESBP
		aDadosInc[1][A010APICnt("ARRAY_PROD_POS_ESTORI"   )] := (cAliasQry)->B1_ESTRORI
		aDadosInc[1][A010APICnt("ARRAY_PROD_POS_APROPR"   )] := M010CnvFld("B1_APROPRI", (cAliasQry)->B1_APROPRI)
		aDadosInc[1][A010APICnt("ARRAY_PROD_POS_CPOTEN"   )] := (cAliasQry)->B1_CPOTENC
		aDadosInc[1][A010APICnt("ARRAY_PROD_POS_HORFIX"   )] := (cAliasQry)->VK_HORFIX
		aDadosInc[1][A010APICnt("ARRAY_PROD_POS_TPHFIX"   )] := (cAliasQry)->VK_TPHOFIX
		aDadosInc[1][A010APICnt("ARRAY_PROD_POS_NUMDEC"   )] := "0" //Protheus não utiliza esse campo, passar 0 fixo
		aDadosInc[1][A010APICnt("ARRAY_PROD_POS_IDREG"    )] := (cAliasQry)->B1_FILIAL+(cAliasQry)->B1_COD
		aDadosInc[1][A010APICnt("ARRAY_PROD_POS_BLOQUEADO")] := (cAliasQry)->B1_MSBLQL
		aDadosInc[1][A010APICnt("ARRAY_PROD_POS_CONTRATO" )] := M010CnvFld("B1_CONTRAT", (cAliasQry)->B1_CONTRAT)
		aDadosInc[1][A010APICnt("ARRAY_PROD_POS_ROTEIRO"  )] := (cAliasQry)->B1_OPERPAD
		aDadosInc[1][A010APICnt("ARRAY_PROD_POS_CCUSTO"   )] := (cAliasQry)->B1_CCCUSTO
		aDadosInc[1][A010APICnt("ARRAY_PROD_POS_DESC"     )] := (cAliasQry)->B1_DESC
		aDadosInc[1][A010APICnt("ARRAY_PROD_POS_DESCTP"   )] := M010CnvFld("B1_DESCTP", (cAliasQry)->B1_TIPO)
		aDadosInc[1][A010APICnt("ARRAY_PROD_POS_GRPCOM"   )] := (cAliasQry)->B1_GRUPCOM
		aDadosInc[1][A010APICnt("ARRAY_PROD_POS_GCDESC"   )] := M010CnvFld("B1_GCDESC", (cAliasQry)->B1_GRUPCOM)
		aDadosInc[1][A010APICnt("ARRAY_IND_PROD_POS_QTDB" )] := (cAliasQry)->B1_QB
		aDadosInc[1][A010APICnt("ARRAY_PROD_POS_UM"       )] := (cAliasQry)->B1_UM
		aDadosInc[1][A010APICnt("ARRAY_PROD_POS_GCDESC"   )] := (cAliasQry)->AJ_DESC

		If Trim((cAliasQry)->TEMOPC) == "1"
			SB1->(DbGoTo((cAliasQry)->R_E_C_N_O_))
			aDadosInc[1][A010APICnt("ARRAY_PROD_POS_OPC")] := SB1->B1_MOPC
		EndIf
		aDadosInc[1][A010APICnt("ARRAY_PROD_POS_STR_OPC")] := (cAliasQry)->B1_OPC

		aDadosInc[1][A010APICnt("ARRAY_PROD_POS_LDTRANSF" )] := {}
		While (cAliasQry)->(!Eof())
			If !Empty((cAliasQry)->(B5_COD))
				aAdd(aDadosInc[1][A010APICnt("ARRAY_PROD_POS_LDTRANSF" )], Array(A010APICnt("ARRAY_TRANSF_POS_SIZE")))
				nPos := Len(aDadosInc[1][A010APICnt("ARRAY_PROD_POS_LDTRANSF" )])

				aDadosInc[1][A010APICnt("ARRAY_PROD_POS_LDTRANSF" )][nPos][A010APICnt("ARRAY_TRANSF_POS_FILIAL"  )] := (cAliasQry)->B5_FILIAL
				aDadosInc[1][A010APICnt("ARRAY_PROD_POS_LDTRANSF" )][nPos][A010APICnt("ARRAY_TRANSF_POS_LEADTIME")] := (cAliasQry)->B5_LEADTR
				aDadosInc[1][A010APICnt("ARRAY_PROD_POS_LDTRANSF" )][nPos][A010APICnt("ARRAY_TRANSF_POS_AGLUTMRP")] := (cAliasQry)->B5_AGLUMRP

				If ::lPossuiHZ8
					If !Empty((cAliasQry)->HZ8_LEADTR)
						aDadosInc[1][A010APICnt("ARRAY_PROD_POS_LDTRANSF")][nPos][A010APICnt("ARRAY_TRANSF_POS_LEADTIME")] := (cAliasQry)->HZ8_LEADTR
					EndIf

					aDadosInc[1][A010APICnt("ARRAY_PROD_POS_LDTRANSF")][nPos][A010APICnt("ARRAY_TRANSF_POS_TRANSF")] := (cAliasQry)->HZ8_TRANSF
					aDadosInc[1][A010APICnt("ARRAY_PROD_POS_LDTRANSF")][nPos][A010APICnt("ARRAY_TRANSF_POS_FILCOM")] := (cAliasQry)->HZ8_FILCOM

					If ::lLMTran
						aDadosInc[1][A010APICnt("ARRAY_PROD_POS_LDTRANSF")][nPos][A010APICnt("ARRAY_TRANSF_POS_LMTRAN")] := (cAliasQry)->HZ8_LMTRAN
					EndIf
				EndIf
			EndIf
			(cAliasQry)->(dbSkip())
		EndDo

		If (cAliasQry)->(Eof())
			//Chama a função do MATA010API para integrar os registros
			MATA010INT("INSERT", aDadosInc, Nil, Nil, .F. /*OnlyDel*/, /*cUUID*/, .F. /*Mantêm Registros*/)

			//Reseta as variaveis
			aSize(aDadosInc, 0)
		EndIf
	EndIf
	(cAliasQry)->(dbCloseArea())

Return Nil

/*/{Protheus.doc} MATA180PCP
Função para verificar se o fonte existe dentro do MATA180 e substituir o FindClass, que não pode ser utilizado em binários anteriores.

@author ricardo.prandi
@since 24/05/2021
@version 12.1.33
@return .T.
/*/
Function MATA180PCP()
	Local lRet := .T.
Return lRet

/*/{Protheus.doc} A180MDLPCP
Inclui o modelo da tabela HZ8 no modelo principal
@author douglas.heydt
@since 26/09/2024
@version 1.0
@param oModel - Definição do modelo principal
@return Nil
/*/
Function A180MDLPCP(oModel)
	Local oStruHZ8

	If FWAliasInDic("HZ8")
		oStruHZ8 := FWFormStruct(1,"HZ8")
		If GetSx3Cache("HZ8_LMTRAN", "X3_TAMANHO") > 0
			oStruHZ8:SetProperty("HZ8_LMTRAN", MODEL_FIELD_VALID, FWBuildFeature(STRUCT_FEATURE_VALID, "Positivo()"))
		EndIf
		oModel:AddFields("FLD_MRPME", "SB5MASTER", oStruHZ8)
		oModel:GetModel("FLD_MRPME"):SetDescription(STR0033) //"Multi-empresa"
		oModel:GetModel("FLD_MRPME"):SetOptional(.T.)
		oModel:SetRelation("FLD_MRPME", {{"HZ8_FILIAL","xFilial('HZ8')"},{"HZ8_PROD","B5_COD"}}, HZ8->(IndexKey(1)))
	EndIf
Return

/*/{Protheus.doc} A180VIWPCP
Inclui o botão Multi-empresa nas ações da rotina
@author douglas.heydt
@since 26/09/2024
@version 1.0
@param oView - view principal
@return Nil
/*/
Function A180VIWPCP(oView)

	If FWAliasInDic("HZ8")
		oView:addUserButton(STR0033, "", { |oView| A180PARME(oView)}, /*[ cToolTip ]*/, /*[ nShortCut ]*/, {MODEL_OPERATION_INSERT,MODEL_OPERATION_UPDATE}, /*[lShowBar]*/) //"Multi-empresa"
	EndIf

Return

/*/{Protheus.doc} A180PARME
Cria a modal de parâmetros Multi-empresa
@author douglas.heydt
@since 26/09/2024
@version 1.0
@param oViewPai	- view principal
@return Nil
/*/
Static Function A180PARME(oViewPai)
	Local aAreaSB5  := {}
	Local oModel    := oViewPai:GetModel()
	Local oMdlHZ8   := oModel:GetModel("FLD_MRPME")
	Local oStruHZ8  := FWFormStruct(2, "HZ8", {|cCampo| "|" + AllTrim(cCampo) + "|" $ "|HZ8_LEADTR|HZ8_TRANSF|HZ8_FILCOM|HZ8_LMTRAN|"})
	Local oView     := Nil
	Local oViewExec := Nil

	If oModel:GetOperation() == MODEL_OPERATION_UPDATE .And. Empty(oMdlHZ8:GetDataID()) .And. !oMdlHZ8:IsModified()
		aAreaSB5 := SB5->(GetArea())
		SB5->(dbSetOrder(1))
		SB5->(dbSeek(xFilial("SB5") + oModel:getValue("SB5MASTER","B5_COD")))
		If !Empty(SB5->B5_LEADTR)
			oMdlHZ8:SetValue("HZ8_LEADTR", SB5->B5_LEADTR)
		EndIf

		oMdlHZ8:clearField("HZ8_TRANSF")
		oMdlHZ8:SetValue("HZ8_TRANSF", "1")

		SB5->(RestArea(aAreaSB5))
		aSize(aAreaSB5, 0)
	EndIf

	//Monta a tela de Lista de Componentes
	oView := FWFormView():New(oViewPai)
	oView:SetModel(oModel)
	oView:SetOperation(oViewPai:GetOperation())

	oView:AddField("FIELDS_HZ8", oStruHZ8, "FLD_MRPME")

	//Proteção para execução com View ativa
	If oModel != Nil .And. oModel:isActive()
		oViewExec := FWViewExec():New()
		oViewExec:SetModel(oModel)
		oViewExec:SetView(oView)
		oViewExec:SetTitle(STR0033) //"Multi-empresa"
		oViewExec:SetOperation(oViewPai:GetOperation())
		oViewExec:SetReduction(70)
		oViewExec:SetButtons({{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.T.,STR0008},{.F.,""},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil}}) //"Confirma"
		oViewExec:SetCloseOnOk({|oModel| l180PermTr(oModel)})
		oViewExec:SetModal(.T.)
		oViewExec:OpenView(.F.)
	EndIf

Return

/*/{Protheus.doc} A180MEVIS
Cria a modal Multi-empresa para a operação de visualização
@author douglas.heydt
@since 26/09/2024
@version 1.0
@param oViewPai	- view principal
@return Nil
/*/
Function A180MEVIS()
	Local oStruHZ8  := FWFormStruct(2, "HZ8", {|cCampo| "|" + AllTrim(cCampo) + "|" $ "|HZ8_LEADTR|HZ8_TRANSF|HZ8_FILCOM|HZ8_LMTRAN|"})
	Local oView     := Nil
	Local oViewExec := Nil
	Local oModel    := FWLoadModel("MATA180")
	Local oMdlHZ8   := oModel:getModel("FLD_MRPME")

	oModel:SetOperation(MODEL_OPERATION_VIEW)
	oModel:Activate()

	If Empty(oMdlHZ8:GetDataID())
		oMdlHZ8:LoadValue("HZ8_LEADTR", SB5->B5_LEADTR)
		oMdlHZ8:LoadValue("HZ8_TRANSF", "1")
	EndIf

	oView := FWFormView():New()
	oView:SetModel(oModel)
	oView:SetOperation(MODEL_OPERATION_VIEW)

	oView:AddField("FIELDS_HZ8", oStruHZ8, "FLD_MRPME")

	//Proteção para execução com View ativa
	If oModel != Nil .And. oModel:isActive()
		oViewExec := FWViewExec():New()
		oViewExec:SetModel(oModel)
		oViewExec:SetView(oView)
		oViewExec:SetTitle(STR0033) //"Multi-empresa"
		oViewExec:SetOperation(MODEL_OPERATION_VIEW)
		oViewExec:SetReduction(70)
		oViewExec:SetButtons({{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,STR0008},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil}}) //"Confirma"
		oViewExec:SetCloseOnOk({| | .T.})
		oViewExec:SetModal(.T.)
		oViewExec:OpenView(.F.)
	EndIf

Return

/*/{Protheus.doc} ModelPosVld
Método de pós validação do modelo de dados
@author douglas.heydt
@since 23/01/2020
@version 1.0

@param oModel	- Modelo de dados que será validado
@param cModelId	- ID do modelo de dados que está sendo validado.

@return lReturn	- Indica se o modelo foi validado com sucesso.
/*/
METHOD ModelPosVld(oModel, cModelId) CLASS MATA180API

	Local aAreaSB5	:= {}
	Local lRet      := .T.
	Local nOpc      := oModel:GetOperation()
	Local oModelHZ8 := oModel:GetModel("FLD_MRPME")

	If ::lPossuiHZ8                   .And.;
		cModelId == "MATA180"          .And.;
		nOpc == MODEL_OPERATION_UPDATE .And.;
		!oModelHZ8:IsModified()        .And.;
		Empty(oModelHZ8:GetDataID())

		//Atualização, sem registro na HZ8, sem alterar em tela a HZ8 e com leadtime na SB5. Copia valor para a HZ8.
		aAreaSB5 := SB5->(GetArea())

		SB5->(DbSetOrder(1))
		If SB5->(DbSeek(xFilial("SB5")+oModel:getValue("SB5MASTER","B5_COD"))) .And. SB5->B5_LEADTR > 0
			oModelHZ8:clearField("HZ8_TRANSF")

			oModelHZ8:SetValue("HZ8_LEADTR", SB5->B5_LEADTR)
			oModelHZ8:SetValue("HZ8_TRANSF", "1")
		EndIf

		SB5->(RestArea(aAreaSB5))
		aSize(aAreaSB5, 0)
	EndIf

	If ::lPossuiHZ8                    .And.;
		cModelId == "MATA180"          .And.;
		oModelHZ8:IsModified()         .And.;
		(nOpc == MODEL_OPERATION_INSERT .Or. nOpc == MODEL_OPERATION_UPDATE)
		lRet := l180PermTr(oModel)
	EndIf

	If  lRet					.And.;
		::lPossuiHZ8            .And.;
		cModelId == "MATA180"   .And.;
		!Empty(oModelHZ8:GetValue("HZ8_FILCOM")) .And.;
		cFilAnt <> oModelHZ8:GetValue("HZ8_FILCOM") .And.;
		(nOpc == MODEL_OPERATION_INSERT .Or. nOpc == MODEL_OPERATION_UPDATE)

		lRet := vlFilComp(oModel, oModel:getValue("SB5MASTER","B5_COD"), oModelHZ8:GetValue("HZ8_FILCOM"))
	EndIf

Return lRet

/*/{Protheus.doc} l180PermTr
Função que avalia a possibilidade de registrar filiais como transferidoras
@author douglas.heydt
@since 22/10/2024
@version 1.0
@param oModel	- Modelo de dados que será validado
@return lRet	- Indica se a validação falhou ou teve sucesso
/*/
Function l180PermTr(oModel)
	Local cAliasQry  := GetNextAlias()
	Local cProd      := ""
	Local cQuery     := ""
	Local lRet       := .T.
	Local cFilCompra := ""
	Local oModelHZ8  := oModel:GetModel("FLD_MRPME")

	cFilCompra := oModelHZ8:GetValue('HZ8_FILCOM')
	If !Empty(cFilCompra) .And. cFilCompra != cFilAnt // se a filial for igual não há necessidade de verificação
		lRet := lRelac(cFilCompra)
	EndIf

	If lRet
		cProd := oModel:getValue("SB5MASTER","B5_COD")

		If oModelHZ8:GetValue('HZ8_TRANSF') == '2'
			cQuery := " SELECT HZ8_FILIAL, HZ8_PROD, HZ8_TRANSF, HZ8_FILCOM  FROM " + RetSqlName("HZ8")
			cQuery += " WHERE HZ8_FILCOM = '"+cFilAnt+"' AND HZ8_PROD = '"+cProd+"'  AND D_E_L_E_T_ = ' ' "

			dbUseArea(.T.,"TOPCONN",TCGENQRY(,,cQuery),cAliasQry,.T.,.T.)
			If (cAliasQry)->(!Eof())
				lRet := .F.
				Help( ,  , "MATA180API", , I18N(STR0039, {cFilAnt,(cAliasQry)->HZ8_FILIAL }) , 1, 0, , , , , , {STR0036})  //"A Filial #1[FILIALB5]# não pode ser definida como 'não transfere' pois já é filial de compra da filial #2[FILIALCOMP]#" //"Altere a permissão de transferência para 'Sim'."
			EndIF
			(cAliasQry)->(dbCloseArea())
		EndiF

		If !Empty(cFilCOmpra) .And. cFilCompra != cFilAnt .And. lRet
			cQuery := " SELECT HZ8_FILIAL, HZ8_PROD, HZ8_TRANSF, HZ8_FILCOM  FROM " + RetSqlName("HZ8")
			cQuery += " WHERE HZ8_FILIAL = '"+xFilial('HZ8', cFilCompra)+"' AND HZ8_PROD = '"+cProd+"'  AND D_E_L_E_T_ = ' ' "

			dbUseArea(.T.,"TOPCONN",TCGENQRY(,,cQuery),cAliasQry,.T.,.T.)
			If (cAliasQry)->(!Eof())
				If (cAliasQry)->HZ8_TRANSF == '2'
					lRet := .F.
					Help( ,  , "MATA180API", , I18N(STR0035, {cFilCompra}) , 1, 0, , , , , , {STR0036}) //"A filial #1[FILCOMPRA]# não permite transferência." //"Altere a permissão de transferência para o produto na filial desejada."
				EndIf
			EndIF
			(cAliasQry)->(dbCloseArea())
		EndIf
	Else
		Help( ,  , "MATA180API", , STR0037, 1, 0, , , , , , {STR0038}) // "Não foi encontrado relacionamento entre a filial de compra informada e a filial de produto" //"Utilize o cadastro de empresas centralizadoras (PCPA106) para definir o relacionamento"
	EndIf

Return lRet

/*/{Protheus.doc} lRelac
Avalia se duas empresas estão relacionadas no mesmo grupo (cadastro de empresas centralizadoras - PCPA106)
@author douglas.heydt
@since 22/10/2024
@version 1.0
@param cFilComp	- Filial de compra, informa por qual empresa o produto é comprado.
@return lRet	- verdadeiro se a filial corrente e a filial de compra estiverem relacionadas no mesmo grupo de empresas centralizadas
/*/
Static Function lRelac(cFilComp)
	Local aFilComp   := {}
	Local aFilCentr  := {}
	Local aFil		 := {}
	Local cAliasQry  := GetNextAlias()
	Local cQuery     := ""
	Local cGrupo     := cEmpAnt
	Local cEmp       := FWCompany()
	Local cUnid      := FWUnitBusiness()
	Local cFil       := FwFilial()
	Local lRet       := .F.
	Local lRelac     := .T.
	Local nIndex     := 0

	cGrupo := PadR(cGrupo, GetSx3Cache("OO_CDEPCZ", "X3_TAMANHO"))
	cEmp   := PadR(cEmp  , GetSx3Cache("OO_EMPRCZ", "X3_TAMANHO"))
	cUnid  := PadR(cUnid , GetSx3Cache("OO_UNIDCZ", "X3_TAMANHO"))
	cFil   := PadR(cFil  , GetSx3Cache("OO_CDESCZ", "X3_TAMANHO"))

	aFilComp := FWArrFilAtu(cEmpAnt, cFilComp) //array da filial de compra ( escolhida na tela)

	SOO->(dbSetOrder(2))

	cQuery := " SELECT SOP.OP_CDEPCZ "
	cQuery += " FROM " + RetSqlName("SOP") + " SOP"
	cQuery += " WHERE SOP.OP_FILIAL = '" + xFilial("SOP") + "' "
	cQuery += 	" AND SOP.D_E_L_E_T_ = ' ' "

	If SOO->(dbSeek(xFilial("SOO")+cGrupo+cEmp+cUnid+cFil))
		//se a filial atual é centralizadora verifica se a filial de compra é centralizada
		cQuery +=	" AND SOP.OP_CDEPCZ = '" + cGrupo + "' "
		cQuery +=   " AND SOP.OP_EMPRCZ = '" + cEmp + "' "
		cQuery +=   " AND SOP.OP_UNIDCZ = '" + cUnid + "' "
		cQuery +=   " AND SOP.OP_CDESCZ = '" + cFil + "'"

		cQuery +=   " AND SOP.OP_CDEPGR = '" + aFilComp[SM0_GRPEMP]+ "' "
		cQuery +=   " AND SOP.OP_EMPRGR = '" + PadR(aFilComp[SM0_EMPRESA] , GetSx3Cache("OP_EMPRGR", "X3_TAMANHO"))+ "' "
		cQuery +=   " AND SOP.OP_UNIDGR = '" + PadR(aFilComp[SM0_UNIDNEG] , GetSx3Cache("OP_UNIDGR", "X3_TAMANHO")) + "' "
		cQuery +=   " AND SOP.OP_CDESGR = '" + aFilComp[SM0_FILIAL]+ "'"
	Else
		//se a filial atual não é centralizadora verifica se a mesma é centralizada da filial de compra
		cQuery +=	" AND SOP.OP_CDEPCZ = '" + aFilComp[SM0_GRPEMP] + "' "
		cQuery +=   " AND SOP.OP_EMPRCZ = '" + PadR(aFilComp[SM0_EMPRESA] , GetSx3Cache("OP_EMPRCZ", "X3_TAMANHO")) + "' "
		cQuery +=   " AND SOP.OP_UNIDCZ = '" + PadR(aFilComp[SM0_UNIDNEG] , GetSx3Cache("OP_UNIDCZ", "X3_TAMANHO")) + "' "
		cQuery +=   " AND SOP.OP_CDESCZ = '" + aFilComp[SM0_FILIAL] + "' "

		cQuery +=   " AND SOP.OP_CDEPGR = '" + cGrupo +"' "
		cQuery +=   " AND SOP.OP_EMPRGR = '" + cEmp + "' "
		cQuery +=   " AND SOP.OP_UNIDGR = '" + cUnid +"' "
		cQuery +=   " AND SOP.OP_CDESGR = '" + cFil + "'"
	EndIF

	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasQry,.T.,.T.)

	If (cAliasQry)->(!Eof())
		lRet := .T. //empresa centralizada
	EndIf
	(cAliasQry)->(dbCloseArea())

	If !lRet
		aFilComp[SM0_EMPRESA] := PadR(aFilComp[SM0_EMPRESA] , GetSx3Cache("OP_EMPRGR", "X3_TAMANHO"))
		aFilComp[SM0_UNIDNEG] := PadR(aFilComp[SM0_UNIDNEG] , GetSx3Cache("OP_UNIDGR", "X3_TAMANHO"))

		aFil      := a180Centr(aFilComp[SM0_GRPEMP],aFilComp[SM0_EMPRESA],aFilComp[SM0_UNIDNEG],aFilComp[SM0_FILIAL])
		aFilCentr := a180Centr(cGrupo,cEmp,cUnid,cFil)
		If Len(aFil) > 0 .And. Len(aFilCentr) > 0
			For nIndex := 1 To Len(aFil)
				If aFil[nIndex] <> aFilCentr[nIndex]
					lRelac := .F.
					Exit
				EndIf
			Next nIndex
		Else
			lRelac := .F.
		EndIf
	EndIf

	If lRelac //se verdadeiro, ambas tem a mesmsa empresa centralizadora
		lRet := .T.
	EndIf

Return lRet

/*/{Protheus.doc} a180Centr
Retorna as informações da empresa centralizadora, caso houver
@author douglas.heydt
@since 22/10/2024
@version 1.0
@param cGrupo - character - Grupo de empresas
@param cEmp	  - character - Empresa
@param cUnid  - character - Unidade
@param cFil	  - character - Filial
@return aFilCentr  - array - Array contendo Grupo, empresa, unidade e filial da empresa centralizadora
/*/
Static Function a180Centr(cGrupo,cEmp,cUnid,cFil)
	Local aFilCentr   := {}
	Local cAliasQry := GetNextAlias()
	Local cQuery    := ""

	cQuery := " SELECT SOP.OP_CDEPCZ, SOP.OP_EMPRCZ, SOP.OP_UNIDCZ, SOP.OP_CDESCZ"
	cQuery +=   " FROM " + RetSqlName("SOP") + " SOP"
	cQuery +=  " WHERE SOP.OP_FILIAL = '" + xFilial("SOP") + "' "
	cQuery +=    " AND SOP.D_E_L_E_T_ = ' ' "
	cQuery +=    " AND SOP.OP_CDEPGR = '" + cGrupo+ "' "
	cQuery +=    " AND SOP.OP_EMPRGR = '" + cEmp+ "' "
	cQuery +=    " AND SOP.OP_UNIDGR = '" + cUnid + "' "
	cQuery +=    " AND SOP.OP_CDESGR = '" + cFil+ "'"

	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasQry,.T.,.T.)

	If (cAliasQry)->(!Eof())
		aAdd(aFilCentr, (cAliasQry)->OP_CDEPCZ)
		aAdd(aFilCentr, (cAliasQry)->OP_EMPRCZ)
		aAdd(aFilCentr, (cAliasQry)->OP_UNIDCZ)
		aAdd(aFilCentr, (cAliasQry)->OP_CDESCZ)
	EndIf
	(cAliasQry)->(dbCloseArea())

Return aFilCentr

/*/{Protheus.doc} vlFilComp
Valida se as filiais de compra criam uma dependencia circular entre elas

@type Static Function
@author douglas.heydt
@since 21/11/2024
@version P12
@param oModel	- Modelo de dados que será validado
@param cProd   - character - Produto
@param cFilCom - character - Filial de compra do modelo
@return Nil
/*/
Static Function vlFilComp(oModel, cProd, cFilCom)
	Local aFiliais  := {}
	Local aFilRel   := {}
	Local cAlias    := GetNextAlias()
	Local cFiliais  := ""
	Local cQuery    := ""
	Local lRet      := .T.
	Local nIndex    := 0
	Local nTotFils  := 0
	Local nOpc      := oModel:GetOperation()

	aFiliais := aGrpRel()
	nTotFils := Len(aFiliais)
	If nTotFils > 0
		For nIndex := 1 To nTotFils
			cFiliais += "'"+aFiliais[nIndex][4]+"'"
			If nIndex <> nTotFils
				cFiliais += ","
			EndIf
		Next nIndex

		cQuery := " SELECT HZ8_FILIAL,HZ8_PROD,HZ8_FILCOM "
		cQuery += " FROM "+RetSqlName("HZ8")+" "
		cQuery += " WHERE HZ8_PROD = '"+cProd+"' AND HZ8_FILIAL IN ("+cFiliais+") AND HZ8_FILCOM <> '' AND D_E_L_E_T_ = ' '

		dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAlias,.F.,.F.)
		While (cAlias)->(!Eof())
			If (cAlias)->(HZ8_FILIAL) <> cFilAnt
				aAdd(aFilRel, {(cAlias)->(HZ8_FILIAL), (cAlias)->(HZ8_FILCOM)})
			Else
				aAdd(aFilRel, {cFilAnt, cFilCom})
			EndIf
			(cAlias)->(dbSkip())
		End
		(cAlias)->(dbCloseArea())

		If nOpc == MODEL_OPERATION_INSERT
			aAdd(aFilRel, {cFilAnt, cFilCom})
		EndIf

		lRet := !verifCiclo(aFilRel)

		If !lRet
			Help( ,  , "MATA180API", , STR0040 , 1, 0, , , , , , {STR0041})  //"A filial de compra (multi-empresa) selecionada cria uma dependência circular entre as filiais" //"Alterar a filial de compra."
		EndIf
	EndIF

Return lRet


/*/{Protheus.doc} l180Cent
Retorna se a empresa é centralizadora
@author douglas.heydt
@since 26/11/2024
@version 1.0
@param cGrupo - character - Grupo de empresas
@param cEmp	  - character - Empresa
@param cUnid  - character - Unidade
@param cFil	  - character - Filial
@return aFilCentr  - array - Array contendo Grupo, empresa, unidade e filial da empresa centralizadora
/*/
Static Function l180Centr(cGrupo,cEmp,cUnid,cFil)
	Local cAliasQry := GetNextAlias()
	Local cQuery    := ""
	Local lRet      := .F.

	cQuery := " SELECT SOP.OP_CDEPCZ, SOP.OP_EMPRCZ, SOP.OP_UNIDCZ, SOP.OP_CDESCZ"
	cQuery +=   " FROM " + RetSqlName("SOP") + " SOP"
	cQuery +=  " WHERE SOP.OP_FILIAL = '" + xFilial("SOP") + "' "
	cQuery +=    " AND SOP.D_E_L_E_T_ = ' ' "
	cQuery +=    " AND SOP.OP_CDEPCZ = '" + cGrupo+ "' "
	cQuery +=    " AND SOP.OP_EMPRCZ = '" + cEmp+ "' "
	cQuery +=    " AND SOP.OP_UNIDCZ = '" + cUnid + "' "
	cQuery +=    " AND SOP.OP_CDESCZ = '" + cFil+ "'"

	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasQry,.T.,.T.)

	If (cAliasQry)->(!Eof())
		lRet := .T.
	EndIf
	(cAliasQry)->(dbCloseArea())

Return lRet



/*/{Protheus.doc} l180Cent
Retorna todas as empresas centralizadas de uma centralizadora
@author douglas.heydt
@since 26/11/2024
@version 1.0
@param cGrupo - character - Grupo de empresas
@param cEmp	  - character - Empresa
@param cUnid  - character - Unidade
@param cFil	  - character - Filial
@return aFilCentr  - array - Array contendo Grupo, empresa, unidade e filial da empresa centralizadora
/*/
Static Function aFilCentr(cGrupo,cEmp,cUnid,cFil)
	Local aFilCentr := {}
	Local aFilAux   := {}
	Local cAliasQry := GetNextAlias()
	Local cQuery    := ""

	cQuery := " SELECT SOP.OP_CDEPGR, SOP.OP_EMPRGR, SOP.OP_UNIDGR, SOP.OP_CDESGR"
	cQuery +=   " FROM " + RetSqlName("SOP") + " SOP"
	cQuery +=  " WHERE SOP.OP_FILIAL = '" + xFilial("SOP") + "' "
	cQuery +=    " AND SOP.D_E_L_E_T_ = ' ' "
	cQuery +=    " AND SOP.OP_CDEPCZ = '" + cGrupo+ "' "
	cQuery +=    " AND SOP.OP_EMPRCZ = '" + cEmp+ "' "
	cQuery +=    " AND SOP.OP_UNIDCZ = '" + cUnid + "' "
	cQuery +=    " AND SOP.OP_CDESCZ = '" + cFil+ "'"

	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasQry,.T.,.T.)

	While (cAliasQry)->(!Eof())
		aAdd(aFilAux, (cAliasQry)->OP_CDEPGR)
		aAdd(aFilAux, (cAliasQry)->OP_EMPRGR)
		aAdd(aFilAux, (cAliasQry)->OP_UNIDGR)
		aAdd(aFilAux, (cAliasQry)->OP_CDESGR)

		aAdd(aFilCentr, aClone(aFilAux))
		aSize(aFilAux, 0)
		(cAliasQry)->(dbSkip())
	End
	(cAliasQry)->(dbCloseArea())

Return aFilCentr


/*/{Protheus.doc} aGrpRel
Retorna todas as filiais relacionadas como centralizadas e a centralizadora
@author douglas.heydt
@since 26/11/2024
@version 1.0
@return aFiliais  - array - Array contendo as empresas centralizadas e centralizadora
/*/
Static Function aGrpRel()

	Local aCentr    := {}
	Local aFiliais  := {}
	Local lIsCentr  := .F.
	Local cGrupo    := PadR(cEmpAnt, GetSx3Cache("OO_CDEPCZ", "X3_TAMANHO"))
	Local cEmp      := PadR(FWCompany()  , GetSx3Cache("OO_EMPRCZ", "X3_TAMANHO"))
	Local cUnid     := PadR(FWUnitBusiness() , GetSx3Cache("OO_UNIDCZ", "X3_TAMANHO"))
	Local cFil      := PadR(FwFilial()  , GetSx3Cache("OO_CDESCZ", "X3_TAMANHO"))

	lIsCentr := l180Centr(cGrupo,cEmp,cUnid,cFil)
	If lIsCentr //é centralizadora ?
		aFiliais := aFilCentr(cGrupo,cEmp,cUnid,cFil)//busca centralizadas
		aAdd(aFiliais, {cGrupo,cEmp,cUnid,cFil})
	Else
		aCentr := a180Centr(cGrupo,cEmp,cUnid,cFil)//busca centralizadora
		If Len(aCentr) > 0
			aFiliais := aFilCentr(aCentr[1],aCentr[2],aCentr[3],aCentr[4])
			aAdd(aFiliais, aCentr)
		EndIf
	EndIf

Return aFiliais

/*/{Protheus.doc} verifCiclo
Faz a chamada da função que verifica se existe ciclo entre filiais, para cada conexão
@author douglas.heydt
@since 26/11/2024
@version 1.0
@param aConexoes  - array - Array com as conexoes entre filiais e filiais de compra
@return lTemCiclo - boolean - indica se encontrou algum ciclo entre filiais
/*/
Static Function verifCiclo(aConexoes)
    Local lTemCiclo := .F.
    Local nIndex    := 0

    // Inicia a busca por ciclos para cada nó
    For nIndex := 1 To Len(aConexoes)
        If temCiclo(aConexoes[nIndex][1], aConexoes[nIndex][1], {}, aConexoes)
            lTemCiclo := .T.
            Exit
        EndIf
    Next nIndex

Return lTemCiclo

/*/{Protheus.doc} temCiclo
função recursiva que avalia se existe ciclo entre as filiais partindo de um nó
@author douglas.heydt
@since 26/11/2024
@version 1.0
@param cOrigem    - caractere - nó origem
@param cAtual     - caractere - nó atual
@param aVisitados - Array com nós que já foram visitados
@param aConexoes  - Array com as conexoes entre filiais e filiais de compra
/*/
Static Function temCiclo(cOrigem, cAtual, aVisitados, aConexoes)
    Local nIndex := 0

    // Se o nó atual já foi visitado e é o nó de origem, tem ciclo
    If cAtual == cOrigem .And. Len(aVisitados) > 0
        Return .T.
    EndIf

    // Se o nó atual já foi visitado, mas não é o nó de origem, não tem ciclo
    If AScan(aVisitados, cAtual) > 0
        Return .F.
    EndIf

    aAdd(aVisitados, cAtual)

    For nIndex := 1 To Len(aConexoes)
		// Ignora loops como {3, 3}
		If aConexoes[nIndex][1] == cAtual .And. aConexoes[nIndex][2] == cAtual
            Loop
        EndIf

        If aConexoes[nIndex][1] == cAtual
            If temCiclo(cOrigem, aConexoes[nIndex][2], aVisitados, aConexoes)
                Return .T.
            EndIf
        EndIf
    Next nIndex

    ADel(aVisitados, Len(aVisitados))

Return .F.
