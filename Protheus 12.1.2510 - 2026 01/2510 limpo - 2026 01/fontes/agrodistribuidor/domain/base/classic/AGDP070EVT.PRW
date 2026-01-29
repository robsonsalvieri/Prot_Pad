#INCLUDE "TOTVS.ch"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "AGDP070.CH"


#DEFINE CODIGO_CLIENTE 1
#DEFINE LOJA_CLIENTE 2
#DEFINE CODIGO_GRUPO 3


/*/{Protheus.doc} AGDP070EVT
Classe de eventos do modelo do AGDP070
@author carlos.augusto
@since 10/10/2025
/*/
Class AGDP070EVT From FWModelEvent
	Method New() Public Constructor
	Method ModelPosVld(oModel, cModelId)
	Method Activate(oModel, lCopy) Public
End Class

/*/{Protheus.doc} New
Constructor
@author carlos.augusto
@since 10/10/2025
@return variant, self
/*/
Method New() Class AGDP070EVT
Return Nil

/*/{Protheus.doc} ModelPosVld
Validação POS do Modelo de Dados
@author carlos.augusto
@since 10/10/2025
@param oModel, object, modelo
@param cModelId, character, modelo id
@return variant, true/false
/*/
Method ModelPosVld(oModel, cModelId) Class AGDP070EVT
	Local aArea      := FWGetArea()
	Local oMldNEV 	 := oModel:GetModel('MdFieldNEV')
	Local oMldNEX 	 := oModel:GetModel('MdFieldNEX')
	Local nLinha     := 0
	Local nPrincipal := 0   //Itens marcados como principal
	Local lRet       := .T. //Nao usar Return .F., restaurar area
	Local aCliAtual  := {}
	Local aCliPBanco := {}
	Local aCliSBanco := {}
	Local cMensagem  := ""
	Local aRetorno   := {}

	if oModel:getOperation() != MODEL_OPERATION_DELETE

		//Cliente(s) cadastrado(s) em tela e contador de clientes marcados como principais
		For nLinha := 1 To oMldNEX:Length()
			oMldNEX:GoLine(nLinha)
			If !oMldNEX:IsDeleted(nLinha)
				aAdd(aCliAtual,{ oMldNEX:GetValue("NEX_CODCLI"), oMldNEX:GetValue("NEX_LOJCLI") })
				If oMldNEX:GetValue("NEX_PRINCI") == "1"
					nPrincipal++
				EndIf
			EndIf
		Next

		If lRet

			//Cliente(s) ja cadastrado(s) em outro grupo como principal
			aEval(aCliAtual, {|cliente|  aRetorno := AGDP70VldCad(cliente, oMldNEV:GetValue("NEV_CODIGO"), "1"), IIf(!Empty(aRetorno), aAdd(aCliPBanco, aRetorno),) })
			If !Empty(aCliPBanco)
				lRet := .F.
				aEval(aCliPBanco, {|cliente| cMensagem += STR0006 + cliente[CODIGO_CLIENTE] + STR0007 + cliente[LOJA_CLIENTE] + STR0008 + cliente[CODIGO_GRUPO] + STR0009})//"O cliente "" loja "" já pertence ao grupo familiar "" como principal. "
				AGDHELP(STR0010, cMensagem, STR0011) //"Atenção""Verifique os clientes informados no cadastro de Grupo Familiar e tente novamente."
			EndIf

			//Mais de um cliente como principal
			If lRet .And. nPrincipal > 1
				lRet := .F.
				AGDHELP(STR0010, STR0012, STR0013) //"Atenção""O grupo familiar está sendo cadastrado com mais de um cliente principal.""Selecione apenas um dos clientes como principal para o grupo familiar."
			EndIf

			//Nenhum cliente como principal
			If lRet .And. nPrincipal == 0
				lRet := .F.
				AGDHELP(STR0010,STR0014, STR0015) //"Atenção""Não foi informado nenhum cliente como principal.""Para prosseguir é necessário que esteja definido o registro principal do grupo familiar."
			EndIf

			If lRet
				//Cliente(s) ja cadastrado(s) em outro grupo. ESTA DEVE SER A ULTIMA VALIDACAO, POIS AO RESPONDER SIM, FAZ COMMIT DE ALTERACAO EM OUTRO MODELO
				aEval(aCliAtual, {|cliente|  aRetorno := AGDP70VldCad(cliente, oMldNEV:GetValue("NEV_CODIGO"), "2"), IIf(!Empty(aRetorno), aAdd(aCliSBanco, aRetorno),) })
				If !Empty(aCliSBanco)
					cMensagem := ""
					aEval(aCliSBanco, {|cliente| cMensagem += STR0006 + cliente[CODIGO_CLIENTE] + STR0007 + cliente[LOJA_CLIENTE] + STR0008 + cliente[CODIGO_GRUPO]+". "})//"O cliente "" loja "" já pertence ao grupo familiar "
					cMensagem += STR0016 //"Deseja realizar a exclusão do(s) cliente(s) no(s) grupo(s) familiar(es) e cadastrar no grupo familiar atual?"

					If IsBlind() .Or. FWAlertYesNo(cMensagem, "")
						For nLinha := 1 To Len(aCliSBanco)
							AGDP70DelCli(aCliSBanco[nLinha])
						Next
					Else
						lRet := .F.
						AGDHELP(STR0010, STR0011) //"Atenção""Verifique os clientes informados no cadastro de Grupo Familiar e tente novamente."
					EndIf
				EndIf
			EndIf
		EndIf
	EndIf
	
	FWRestArea(aArea)
Return lRet


/*/{Protheus.doc} Activate
Ativação do Modelo de Dados
@author carlos.augusto
@since 10/10/2025
@param oModel, object, modelo de dados
@param lCopy, logical, copia de dados
@return variant, nil
/*/
Method Activate(oModel, lCopy) Class AGDP070EVT
	Local aArea		:= GetArea()
	Local oMldNEX 	:= oModel:GetModel('MdFieldNEX')
	Local oMldNEV 	:= oModel:GetModel('MdFieldNEV')

	If oModel:GetOperation() == MODEL_OPERATION_INSERT 
		oMldNEV:SetValue("NEV_CODIGO", GetSXENum( "NEV", "NEV_CODIGO" ) )

		//Quando acessado via Dados Agronegocio no CRMA980, gatilhar o cliente na tela como principal
		If FWIsInCallStack("AGDP070CRM")
			oMldNEX:GoLine(1)
			oMldNEX:LoadValue("NEX_FILIAL", FwxFilial("NEX"))
			oMldNEX:SetValue("NEX_PRINCI", "1")
			oMldNEX:SetValue("NEX_CODCLI", SA1->A1_COD)
			oMldNEX:SetValue("NEX_LOJCLI", SA1->A1_LOJA)
		EndIf
	EndIf
	RestArea(aArea)
return nil


/*/{Protheus.doc} AGDP70DelCli
Deleta cliente de outro grupo familiar
@author carlos.augusto
@since 10/10/2025
@param oModel, object, modelo de dados
@param lCopy, logical, copia de dados
@return variant, nil
/*/
Function AGDP70DelCli(cliente)
	Local aAreaNEX   := NEX->(FWGetArea())
	Local aAreaNEV   := NEV->(FWGetArea())
	Local lExiste := Nil
	Local oModelTmp := Nil

	NEV->(DbSetOrder(1))
	If NEV->(DbSeek(FwxFilial("NEV")+ cliente[CODIGO_GRUPO]))

		oModelTmp := FwLoadModel("AGDP070")
		oModelTmp:SetOperation(MODEL_OPERATION_UPDATE)
		If oModelTmp:Activate()
			lExiste := oModelTmp:GetModel("MdFieldNEX"):SeekLine({{"NEX_CODCLI",  cliente[CODIGO_CLIENTE]}, {"NEX_LOJCLI",  cliente[LOJA_CLIENTE]}}, .T., .T.)

			If lExiste
				oModelTmp:GetModel("MdFieldNEX"):DeleteLine()
				
				If oModelTmp:VldData()
					oModelTmp:CommitData()
				EndIf
			EndIf
			oModelTmp:DeActivate()
		EndIf
		FreeObj(oModelTmp)
	EndIf

	FWRestArea(aAreaNEX)
	FWRestArea(aAreaNEV)
Return


/*/{Protheus.doc} AGDP70VldCad
Valida se cliente faz parte de outro grupo
@author carlos.augusto
@since 10/10/2025
@param oModel, object, modelo de dados
@param lCopy, logical, copia de dados
@return variant, nil
/*/
Function AGDP70VldCad(cliente, cGrupo, cTipo)
	Local aAreaNEX  := NEX->(FWGetArea())
	Local aAreaNEV  := NEV->(FWGetArea())

	Local aGrpEncont := {}

	NEX->(DbSetOrder(2))
	If NEX->(DbSeek(FwxFilial("NEX")+ cliente[CODIGO_CLIENTE] + cliente[LOJA_CLIENTE] + cTipo))
		If cGrupo != NEX->NEX_CODGRP
			aGrpEncont := {NEX->NEX_CODCLI, NEX->NEX_LOJCLI, NEX->NEX_CODGRP}
		EndIf
	EndIf

	FWRestArea(aAreaNEX)
	FWRestArea(aAreaNEV)

Return aGrpEncont
