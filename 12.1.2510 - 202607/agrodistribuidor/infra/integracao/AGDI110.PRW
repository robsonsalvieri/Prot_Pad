#INCLUDE "TOTVS.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "AGDI110.CH"

#DEFINE NAMESPACEAGRO totvs.protheus.agrobusiness.agd

/*/{Protheus.doc} AGDI110SM
Função chamada no menuDef do cadastro de tabela de preço
@type function
@version P12
@author claudineia.reinert
@since 17/03/2026
@param paRotina, array, array de rotinas do menu
@return array, array de rotinas do menu atualizado
/*/
Function AGDI110SM(paRotina)
	Local aRotina := aClone(paRotina)

    If SUPERGETMV("MV_SIGAAGD", .F., .F.) .AND. FindFunction("AGDI110")
        aAdd(aRotina, {OemToAnsi(STR0001),"AGDI110()" ,0, 0, 0 ,NIL} ) //"Agrodistribuidor"
    Endif

Return aRotina

/*/{Protheus.doc} AGDI110
Função para chamada da tela de complemento da tabela de preço AGRO (NE8)
@type function
@version 12
@author claudineia.reinert
@since 17/03/2026
/*/
Function AGDI110()
	Local aAreaAtu   := GetArea()
	Local aAreaDA0  := DA0->(GetArea())
	Local oModel    := nil
	Local oModelNE8 := nil
	Local aEnableButtons := {{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.T.,Nil},{.T.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil}}
    Local nOperation := 0
	Local oServTabPrecoExtensao := nil
	
	If !FwAliasInDic("NE8")
		MsgNextRel() //É necessário a atualização do sistema para a expedição mais recente
		Return
	EndIf
	
	If SUPERGETMV("MV_SIGAAGD", .F., .F.)

		DBSelectArea("NE8")
		NE8->(DBSetOrder(1))
		If NE8->(DbSeek( DA0->DA0_FILIAL + DA0->DA0_CODTAB)) 
			nOperation := MODEL_OPERATION_UPDATE
		Else
			//validação tabela de preço
			oServTabPrecoExtensao := NAMESPACEAGRO.TablePriceExtensionService():New()
			If !Empty(DA0->DA0_CODTAB) .AND. !oServTabPrecoExtensao:validateTablePrice(DA0->DA0_FILIAL, DA0->DA0_CODTAB)
				AGDHELP( STR0002 ,oServTabPrecoExtensao:getMessageError(), oServTabPrecoExtensao:getSolutionError() ) //"Ajuda"
				FreeObj(oServTabPrecoExtensao)
				Return .F.
			EndIf			
			nOperation := MODEL_OPERATION_INSERT			
		EndIf
		
		oModel := FwLoadModel('AGDP110')
		oModelNE8 := oModel:GetModel("AGDP110_NE8")
		oModel:SetOperation(nOperation)
		If oModel:Activate()
			IF nOperation == MODEL_OPERATION_INSERT
				oModelNE8:LoadValue('NE8_FILIAL', DA0->DA0_FILIAL)
				oModelNE8:LoadValue('NE8_CODTAB', DA0->DA0_CODTAB)				
			EndIf

			FWExecView(oModel:GetDescription(), "AGDP110", nOperation, , , , 80, aEnableButtons, , , , oModel)

		Endif
		oModel:DeActivate()
		oModel:Destroy()
		oModel := NIL
		FreeObj(oModel)
		
		RestArea(aAreaAtu)
		RestArea(aAreaDA0)
	Endif
	
Return .T.

/*/{Protheus.doc} AGDI110TOK
Ponto de chamada na função OMS010TudOk da rotina de tabela de preço
Função de validação após alteração do modelo de dados da tabela de preço com vinculo com o agro distribuidor(NE8)
@type function
@version P12  
@author claudineia.reinert
@since 27/03/2026
@param oModelTPrc, object, objeto de modelo de dados da rotina de tabela de preço(DA0/DA1), OMSA010
@return logical, resultado da validação .T. para sucesso ou .F. para falha
/*/
Function AGDI110TOK(oModelTPrc) as logical
	Local lRet := .T.
	Local oServTabPrecoExtensao := nil

	If ( FwAliasInDic("NE8") .and. ValType(oModelTPrc) == "O" .and. oModelTPrc:GetOperation() == MODEL_OPERATION_UPDATE )
		oServTabPrecoExtensao := NAMESPACEAGRO.TablePriceExtensionService():New()
		lRet := oServTabPrecoExtensao:canUpdateModelTablePrice(oModelTPrc)
		If !lRet
			AGDHELP( STR0002 ,oServTabPrecoExtensao:getMessageError(), oServTabPrecoExtensao:getSolutionError() ) //"Ajuda"
		EndIf
		FreeObj(oServTabPrecoExtensao)
	EndIf


Return lRet


