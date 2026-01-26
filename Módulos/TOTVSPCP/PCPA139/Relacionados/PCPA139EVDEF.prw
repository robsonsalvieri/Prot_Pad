#INCLUDE "TOTVS.CH"
#INCLUDE "PCPA139.CH"
#INCLUDE "TOPCONN.CH"
#INCLUDE "FWMVCDEF.CH"
#include "TbIconn.ch"

Static _lSmq := FWAliasInDic("SMQ",.F.) .And. FindFunction("P106FmtFil")

/*/{Protheus.doc} PCPA139EVDEF
Eventos padrões do cadastro de roteiros
@author Douglas Heydt
@since 25/04/2018
@version P12.1.17
/*/
CLASS PCPA139EVDEF FROM FWModelEvent

	DATA aQryCompl AS Array
	DATA oAPIsAlt  AS Object

	METHOD New() CONSTRUCTOR
	METHOD GridLinePreVld(oSubModel, cModelID)
	METHOD InTTS(oModel, cModelId)
	METHOD ModelPosVld(oModel, cModelId)
	METHOD Before(oModel, cModelId)
	METHOD Activate(oModel, lCopy)

ENDCLASS

METHOD New() CLASS  PCPA139EVDEF
	::aQryCompl := {}
	::oAPIsAlt  := JsonObject():New()
Return

/*/{Protheus.doc} GridLinePreVld
Pré-validação dos modelos
@author Douglas Heydt
@since 19/05/2019
@version 1.0

@param oSubModel	- Modelo de dados
@param cModelId		- ID do modelo de dados
@param nLine		- Linha do grid
@param cAction		- Ação que está sendo realizada no grid, podendo ser: ADDLINE, UNDELETE, DELETE, SETVALUE, CANSETVALUE, ISENABLE
@param cId			- Nome do campo
@param xValue		- Novo valor do campo
@param xCurrentValue- Valor atual do campo
@return lRet		- Indica se a linha está válida
/*/
METHOD GridLinePreVld(oSubModel, cModelID, nLine, cAction, cId, xValue, xCurrentValue) CLASS PCPA139EVDEF
	Local aDadosSM0 := {}
	Local cApi      := ""
	Local cFil      := ""
	Local cMsgHelp  := ""
	Local lCentda   := .F.
	Local lCentdora := .F.
	Local lRet      := .T.

    If cModelID == "T4PDETAIL"
        If cAction == "CANSETVALUE" .And. cId == "T4P_ATIVO"
            lRet := .F.

        ElseIf cAction == "SETVALUE" .And. cId == "T4P_TPEXEC"
			cApi := AllTrim(oSubModel:GetValue("T4P_API", nLine))
			If cApi $ "|MRPPURCHASEORDER|MRPPURCHASEREQUEST|MRPSTOCKBALANCE|MRPALLOCATIONS|MRPWAREHOUSE|" .And. xValue == "1"
	            Help(' ',1,"Help" ,,STR0014 + cApi + STR0015,; //"A API 'X' não pode ser configurada como online."
			         2,0,,,,,, {STR0016}) //"Utilize a configuração schedule."
            	lRet := .F.
			ElseIf cApi $ "|MRPBILLOFMATERIAL|MRPCALENDAR|" .And. xValue == "2"
				Help(' ',1,"Help" ,,STR0014 + cApi + STR0022,; //"A API 'X' não pode ser configurada como schedule."
			         2,0,,,,,, {STR0023}) //"Utilize a configuração online."
            	lRet := .F.
			ElseIf Empty(xValue)
            	Help(' ',1,"Help" ,,STR0017,; //"Tipo de execução inválido!"
			         2,0,,,,,, {STR0018}) //"Selecione um tipo de execução válido: online ou schedule."
            	lRet := .F.
			EndIf

			If lRet .And. xCurrentValue <> xValue
				If !::oAPIsAlt:HasProperty(cApi)
					::oAPIsAlt[cApi] := (xCurrentValue <> "1")

					If ::oAPIsAlt[cApi] .And. cApi == "MRPPRODUCT"
						::oAPIsAlt["MRPPRODUCTINDICATOR"] := .T.
					EndIf
				EndIf
			EndIf
        EndIf
    ElseIf cModelId == "SMQDETAIL"
		
		If cAction == "SETVALUE" .And. cId == "MQ_CODFIL" .And. xValue != xCurrentValue
			cFil := AllTrim(xValue)
			aDadosSM0 := FWSM0Util():GetSM0Data(cEmpAnt, cFil, {"M0_CODFIL"})

			If Empty(aDadosSM0)
				Help(' ',1,"Help" ,, STR0043 + cFil + STR0044,; // "A filial " + cFil + " não existe!"
						2,0,,,,,, {STR0045}) // "Cadastre uma filial válida."
				lRet := .F.
			EndIf

			/*
			* Não usar a validação de linha duplicada do MVC pois ela é feita após a linha ser inserida no modelo.
			* Então caso a linha seja correspondente a uma filial centralizada/centralizadora não irá deixar deletar e nem alterar.
			*/
			If lRet
				If oSubModel:SeekLine({{"MQ_CODFIL", cFil}}, .F., .F.)
					Help(' ',1,"Help" ,,STR0046,; // "Filial já cadastrada!"
					2,0,,,,,, {STR0047}) // "Cadastre outra filial."
					lRet := .F.
				EndIf
			EndIf

			FwFreeArray(aDadosSM0)
		ElseIf cAction == "DELETE"
			cFil := oSubModel:GetValue("MQ_CODFIL", nLine)
			
			If !Empty(cFil)
				P139Centra(cFil, @lCentdora, @lCentda)

				If lCentDora .Or. lCentda
					cMsgHelp := STR0048 // "Esta filial esta cadastrada como "
					
					If lCentDora
						cMsgHelp += STR0049 // "filial centralizadora"
					Else
						cMsgHelp += STR0050 // "filial centralizada"
					EndIf

					cMsgHelp += STR0051 // " e não pode ser excluida."
					
					Help(' ',1,"Help" ,,cMsgHelp,;
							2,0,,,,,, {STR0052}) // "Remova a filial do cadastro de empresa centralizadora (PCPA106) e tente novamente!"
					lRet := .F.
				EndIf
			EndIf
		EndIf

	EndIf

Return lRet

/*/{Protheus.doc} InTTS
Método que é chamado pelo MVC quando ocorrer as ações do commit Após as gravações porém
antes do final da transação.
Esse evento ocorre uma vez no contexto do modelo principal.

@author brunno.costa
@since 08/08/2019
@version 1.0

@param oModel	- Modelo principal
@param cModelId	- Id do submodelo
@return Nil
/*/
METHOD InTTS(oModel, cModelId) CLASS PCPA139EVDEF
	Local aNames  := ::oAPIsAlt:GetNames()
	Local nIndex  := 0
	Local nTotal  := 0
	Local oMdlSmq := Nil

	nTotal := Len(aNames)
	For nIndex := 1 to nTotal
		If ::oAPIsAlt[aNames[nIndex]]
			aAdd(::aQryCompl, "UPDATE " + RetSqlName("T4P") + " SET T4P_ALTER = '1' WHERE D_E_L_E_T_ = ' ' AND T4P_API = '" + aNames[nIndex] + "'")
		EndIf
	Next
	FreeObj(::oAPIsAlt)

	//Executa comandos complementares oriundos da validação MRPVldTrig
	nTotal := Len(::aQryCompl)
	For nIndex := 1 to nTotal
		TcSqlExec(::aQryCompl[nIndex])
	Next
	aSize(::aQryCompl, 0)

	//Atualiza flag de controle da necessidade de sincronização de API's
	If IntNewMRP("MRPDEMANDS")
		TcSqlExec("UPDATE " + RetSqlName("T4P") + " SET T4P_ALTER = '1' WHERE D_E_L_E_T_ = ' ' AND T4P_ALTER = ' '")
	Else
		TcSqlExec("UPDATE " + RetSqlName("T4P") + " SET T4P_ALTER = ' ' WHERE D_E_L_E_T_ = ' ' ")
	EndIf

	If _lSmq
		oMdlSmq   := oModel:GetModel("SMQDETAIL")

		If oMdlSmq:isModified()
			nTotal := oMdlSmq:length()

			For nIndex := 1 to nTotal
				If oMdlSmq:isInserted(nIndex) .Or. oMdlSmq:IsFieldUpdated("MQ_CODFIL", nIndex)
					TcSqlExec("UPDATE " + RetSqlName("T4P") + " SET T4P_ALTER = '1' WHERE D_E_L_E_T_ = ' ' ")
					Exit
				EndIf
			Next
		EndIf
	EndIf
Return

/*/{Protheus.doc} ModelPosVld
Método que é chamado pelo MVC quando ocorrer as ações de pós-validação do Model
Esse evento ocorre uma vez no contexto do modelo principal

@author brunno.costa
@since 13/08/2019
@version P12
@param oModel  , object    , modelo principal
@param cModelId, characters, ID do submodelo de dados
@return Nil
/*/
METHOD ModelPosVld(oModel, cModelId) CLASS PCPA139EVDEF

	Local lRet       := .T.
	Local lAtivo     := .F.
	Local oMdlHWL    := oModel:GetModel("HWLMASTER")
	Local oMdlT4P    := oModel:GetModel("T4PDETAIL")

	If oMdlHWL != Nil
		lAtivo := oMdlHWL:GetValue("HWL_ATIVO") == "1"
	ElseIf oMdlT4P != Nil
		lAtivo := oMdlT4P:GetValue("T4P_ATIVO", 1) == "1"
	EndIf

	If lAtivo
		lRet := VldTblComp()
		If !lRet
			Return lRet
		EndIf
	EndIf

	::aQryCompl := IIf(::aQryCompl == Nil, {}, ::aQryCompl)

	If !MRPVldTrig(.T.,, .T., oModel, .F., @::aQryCompl)
		lRet := .F.
		MRPVldTrig(.F.,, .T., Nil, .F.)
	EndIf

Return lRet

/*/{Protheus.doc} Before
Método que é chamado pelo MVC quando ocorrer as ações do commit
antes da gravação de cada submodelo (field ou cada linha de uma grid)

@author renan.roeder
@since 13/03/2020
@version P12
@param oModel  , object    , Sub modelo
@param cModelId, characters, Id do submodelo
@return Nil
/*/
METHOD Before(oModel, cModelId) CLASS PCPA139EVDEF
	Local cTpExe   := "1"
	Local cAtivo   := "1"
	Local lRet     := .T.
	Local nIndex   := 0
	Local nOk      := 0
	Local oMdlGrid := oModel

	If cModelID == "T4PDETAIL"
		For nIndex := 1 to oMdlGrid:Length(.F.)
			//Atualiza MRPPRODUCTINDICATOR conforme MRPPRODUCT
			If AllTrim(oMdlGrid:GetValue("T4P_API", nIndex)) == "MRPPRODUCT"
				cTpExe := oMdlGrid:GetValue("T4P_TPEXEC", nIndex)
				cAtivo := oMdlGrid:GetValue("T4P_ATIVO" , nIndex)
				TcSqlExec("UPDATE " + RetSqlName("T4P") + " SET T4P_TPEXEC = '" + cTpExe + "', T4P_ATIVO = '" + cAtivo + "' WHERE T4P_API = 'MRPPRODUCTINDICATOR' ")
				nOk++
			EndIf

			//Atualiza MRPBOMROUTING conforme MRPBILLOFMATERIAL
			If AllTrim(oMdlGrid:GetValue("T4P_API", nIndex)) == "MRPBILLOFMATERIAL"
				cTpExe := oMdlGrid:GetValue("T4P_TPEXEC", nIndex)
				cAtivo := oMdlGrid:GetValue("T4P_ATIVO" , nIndex)
				TcSqlExec("UPDATE " + RetSqlName("T4P") + " SET T4P_TPEXEC = '" + cTpExe + "', T4P_ATIVO = '" + cAtivo + "' WHERE T4P_API = 'MRPBOMROUTING' ")
				nOk++
			EndIf

			//Atualiza MRPREJECTEDINVENTORY conforme MRPSTOCKBALANCE
			If AllTrim(oMdlGrid:GetValue("T4P_API", nIndex)) == "MRPSTOCKBALANCE"
				cTpExe := oMdlGrid:GetValue("T4P_TPEXEC", nIndex)
				cAtivo := oMdlGrid:GetValue("T4P_ATIVO" , nIndex)
				TcSqlExec("UPDATE " + RetSqlName("T4P") + " SET T4P_TPEXEC = '" + cTpExe + "', T4P_ATIVO = '" + cAtivo + "' WHERE T4P_API = 'MRPREJECTEDINVENTORY' ")
				nOk++
			EndIf

			If nOk == 3
				Exit
			Endif
		Next
	EndIf

Return lRet

/*/{Protheus.doc} P139Centra
Valida se uma filial esta cadastrada como filial centralizadora ou centralizada.
@type Function
@author Lucas Fagundes
@since 29/09/2022
@version P12
@param 01 cFil     , Caractere, Filial que será verificada.
@param 02 lCentdora, Logico   , Retorna por referência se a filial é uma filial centralizadora.
@param 03 lCentda  , Logico   , Retorna por referência se a filial é uma filial centralizada.
@return lRet, Logico, Retorna .T. se a filial estiver cadastrado como centralizadora/centralizada ou se não encontrar a filial.
/*/
Function P139Centra(cFil, lCentdora, lCentda)
	Local aDadosFil := {}
	Local lRet      := .T.
	Local nTamCdEp  := GetSx3Cache("OO_CDEPCZ", "X3_TAMANHO")
	Local nTamEmp   := GetSx3Cache("OO_EMPRCZ", "X3_TAMANHO")
	Local nTamFil   := GetSx3Cache("OO_CDESCZ", "X3_TAMANHO")
	Local nTamUnid  := GetSx3Cache("OO_UNIDCZ", "X3_TAMANHO")

	lCentdora := .F.
	lCentda   := .F.

	aDadosFil := FWArrFilAtu(cEmpAnt, cFil)

	If !Empty(aDadosFil)
		SOO->(DbSetOrder(2)) // OO_FILIAL+OO_CDEPCZ+OO_EMPRCZ+OO_UNIDCZ+OO_CDESCZ
		lCentdora := SOO->(DbSeek(xFilial('SOO')+PadR(cEmpAnt, nTamCdEp)+PadR(aDadosFil[SM0_EMPRESA], nTamEmp)+PadR(aDadosFil[SM0_UNIDNEG], nTamUnid)+PadR(aDadosFil[SM0_FILIAL], nTamFil)))

		If !lCentdora
			nTamCdEp  := GetSx3Cache("OP_CDEPGR", "X3_TAMANHO")
			nTamEmp   := GetSx3Cache("OP_EMPRGR", "X3_TAMANHO")
			nTamUnid  := GetSx3Cache("OP_UNIDGR", "X3_TAMANHO")
			nTamFil   := GetSx3Cache("OP_CDESGR", "X3_TAMANHO")
			
			SOP->(DbSetOrder(4)) // OP_FILIAL+OP_CDEPGR+OP_EMPRGR+OP_UNIDGR+OP_CDESGR
			lCentda := SOP->(DbSeek(xFilial('SOP')+PadR(cEmpAnt, nTamCdEp)+PadR(aDadosFil[SM0_EMPRESA], nTamEmp)+PadR(aDadosFil[SM0_UNIDNEG], nTamUnid)+PadR(aDadosFil[SM0_FILIAL], nTamFil)))
		EndIf

		lRet := lCentdora .Or. lCentda

		aSize(aDadosFil, 0)
	EndIf

Return lRet

/*/{Protheus.doc} Activate
Método que é chamado pelo MVC quando ocorrer a ativação do Model.
Esse evento ocorre uma vez no contexto do modelo principal.

@author Lucas Fagundes
@since 25/10/2022
@version P12
@param 01 oModel, Objeto, Modelo principal.
@param 02 lCopy , Logico, Indica que é uma operação de cópia.
@return Nil
/*/
METHOD Activate(oModel, lCopy) CLASS PCPA139EVDEF
	Local cCodFil   := ""
	Local cCorLegen := ""
	Local cDescFil  := ""
	Local nLinha    := 0
	Local nTamanho  := 0
	Local oModelSMQ := Nil
	
	If _lSmq
		oModelSMQ := oModel:GetModel("SMQDETAIL")
		nTamanho := oModelSMQ:Length()

		For nLinha := 1 To nTamanho
			cCodFil   := oModelSMQ:getValue("MQ_CODFIL", nLinha)
			cCorLegen := "BR_VERDE"
			cDescFil  := ""

			If !Empty(cCodFil)
				cDescFil := AllTrim(FWFilialName(cEmpAnt, cCodFil, 1))
				
				If P139Centra(cCodFil)
					cCorLegen := "BR_VERMELHO"
				EndIf
			EndIf

			oModelSMQ:goLine(nLinha)
			oModelSMQ:setValue("MQ_DESCFIL", cDescFil)
			oModelSMQ:setValue("CLEGENDA", cCorLegen)
		Next
	EndIf

Return Nil
