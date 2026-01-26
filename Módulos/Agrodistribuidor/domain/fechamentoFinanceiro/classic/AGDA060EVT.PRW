#INCLUDE "AGDA060.ch"
#INCLUDE "TOTVS.ch"
#INCLUDE "FWMVCDEF.CH"

#DEFINE TITULO_FINANCEIRO_REPOSITORY agd.tituloFinanceiroRepository.agdTituloFinanceiroRepository
/*/{Protheus.doc} AGDA060EVT
Classe de eventos do modelo do AGDA010
@type class
@version 12
@author jean.schulze
@since 02/09/2025
/*/
Class AGDA060EVT From FWModelEvent
	public Data cHistorico As string 

	Method New() Public Constructor
	Method ModelPosVld(oModel, cModelId)
	Method InTTS(oModel, cModelId)
	Method VldActivate(oModel, cModelId) 
	

End Class

/*/{Protheus.doc} New
Constructor
@type method
@version 12
@author jean.schulze
@since 02/09/2025
@return variant, self
/*/
Method New() Class AGDA060EVT
Return Nil

/*/{Protheus.doc} ModelPosVld
Validação do Modelo de Dados
@type method
@version 12
@author jean.schulze
@since 02/09/2025
@param oModel, object, modelo
@param cModelId, character, modelo id
@return variant, true/false
/*/
Method ModelPosVld(oModel, cModelId) Class AGDA060EVT
	Local lRet    		:= .T.
	Local nOperation    := oModel:GetOperation()
	Local oNEJ			:= oModel:GetModel("AGDA060_NEJ")
	Local oGridNEKCP	:= oModel:GetModel("COMPR_NEK")
	Local oGridNEKVD	:= oModel:GetModel("VENDA_NEK")
	Local nX
	Local oTituloRepos := TITULO_FINANCEIRO_REPOSITORY():New()

	/*Garante a atualizacao dos valores*/
	AGDA060CAL(oModel)

	If nOperation == MODEL_OPERATION_UPDATE

		if oNEJ:GetValue("NEJ_STATUS") == '2' //confirmado
			Help( , , STR0012, ,STR0015, 1, 0, .F., , ,,,{STR0016}) //"Fechamento financeiro está com conferência confirmada." //"Verificar possibilidade de exclusão do fechamento financeiro."
			lRet := .F.
		endif

	elseIf nOperation == MODEL_OPERATION_DELETE
		
		if oTituloRepos:existsByTituloBaixadoFechamentoFinanceiro(xFilial('NEJ')+oNEJ:GetValue("NEJ_CODIGO"))
			Help( , , STR0012, ,STR0017 , 1, 0, .F., , ,,,{STR0018})//"Fechamento financeiro contém títulos baixados, não poderá ser excluído." //"Verificar com departamento financeiro se poderá ser revertido a baixa."
			lRet := .F.
		endif
		
	Endif

	If !nOperation == MODEL_OPERATION_DELETE .and. lRet

		If !AGDA060LAT(oGridNEKCP) .And. !AGDA060LAT(oGridNEKVD)
			AGDHELP(STR0019, STR0020, STR0021)
			lRet := .F.

		ElseIf !oModel:GetModel('AGDA060_TOTAL'):getValue('TOTVALVD') > 0 .And. ;
			!oModel:GetModel('AGDA060_TOTAL'):getValue('TOTVALPG') > 0
			AGDHELP(STR0019,STR0020,STR0021) //"Cod. Negoc" // "Negociação não possui documentos disponíveis para realizar o fechamento financeiro, por favor verifique!" //"Selecione algum documento disponivel."
			lRet := .F.
		Else
			
			//Validacao dos titulos
			For nX := 1 To oGridNEKCP:Length()
				oGridNEKCP:GoLine(nX)


				If !oGridNEKCP:GetValue('CHECK')
					oGridNEKCP:DeleteLine()
				else					
					If !oGridNEKCP:GetValue('VALID') .and. lRet
						//validar se as linhas informadas são do negocio correspondente			
						if !oTituloRepos:existByBarterTituloFinanceiroAPagar(oGridNEKCP:GetValue("NEK_FILTIT"), ;
																			oGridNEKCP:GetValue("NEK_PREFIX"), ;
																			oGridNEKCP:GetValue("NEK_CODTIT"), ;
																			oGridNEKCP:GetValue("NEK_PARCEL"), ;
																			oGridNEKCP:GetValue("NEK_TIPO")  , ;
																			oGridNEKCP:GetValue("NEK_CODFOR"), ;
																			oGridNEKCP:GetValue("NEK_LOJA"), ;
																			oNEJ:GetValue("NEJ_CODBRT"))
							cIdTItulo :=  AllTrim(oGridNEKCP:GetValue("NEK_PREFIX")) + '|' + AllTrim(oGridNEKCP:GetValue("NEK_CODTIT")) + '|'+  AllTrim(oGridNEKCP:GetValue("NEK_PARCEL")) + '|' + AllTrim(oGridNEKCP:GetValue("NEK_TIPO")) 												
							AGDHELP("Título À Pagar",'O Título À Pagar '+cIdTItulo+' não está relacionado ao negócio barter:' + oNEJ:GetValue("NEJ_CODBRT"),"Remova o título do fechamento financeiro") 
							lRet := .F.
						endif	
					endif	
				Endif

			Next

			For nX := 1 To oGridNEKVD:Length()
				oGridNEKVD:GoLine(nX)

				If !oGridNEKVD:GetValue('CHECK')
					oGridNEKVD:DeleteLine()
				else
					If !oGridNEKVD:GetValue('VALID') .and. lRet
						//validar se as linhas informadas são do negocio correspondente
						if !oTituloRepos:existByBarterTituloFinanceiroAReceber(oGridNEKVD:GetValue('NEK_FILTIT'), ;
																			oGridNEKVD:GetValue('NEK_PREFIX'), ;
																			oGridNEKVD:GetValue('NEK_CODTIT'), ;
																			oGridNEKVD:GetValue('NEK_PARCEL'), ;
																			oGridNEKVD:GetValue('NEK_TIPO'), ;
																			oNEJ:GetValue("NEJ_CODBRT"))
							cIdTItulo :=  AllTrim(oGridNEKVD:GetValue("NEK_PREFIX")) + '|' + AllTrim(oGridNEKVD:GetValue("NEK_CODTIT")) + '|'+  AllTrim(oGridNEKVD:GetValue("NEK_PARCEL")) + '|' + AllTrim(oGridNEKVD:GetValue("NEK_TIPO")) 												
							AGDHELP("Título À Receber",'O Título À Receber '+cIdTItulo+' não está relacionado ao negócio barter:' + oNEJ:GetValue("NEJ_CODBRT"),"Remova o título do fechamento financeiro") 
							lRet := .F.
						endif	
					endif
				Endif
			Next
		
		EndIf
	Endif

	FreeObj(oTituloRepos)
Return lRet

/*/{Protheus.doc} InTTS
Pós Commit
@type method
@version 12
@author jean.schulze
@since 02/09/2025
@param oModel, object, modelo
@param cModelId, character, modelo id
@return variant, nil
/*/
Method InTTS(oModel, cModelId)  Class AGDA060EVT
	Local aArea      := FWGetArea()
	Local nOperation := oModel:GetOperation()
	Local oNEJ		 := oModel:GetModel("AGDA060_NEJ")

	// Após commit, verificar os itens excluídos da grid NEB
	If nOperation == MODEL_OPERATION_INSERT
		AGDGRAVAHIS("","NEJ",xFilial("NEJ")+oNEJ:Getvalue('NEJ_CODIGO'),STR0003+" "+STR0001,.F.) //"Incluir"
	ElseIf nOperation == MODEL_OPERATION_UPDATE
		AGDGRAVAHIS("","NEJ",xFilial("NEJ")+oNEJ:Getvalue('NEJ_CODIGO'),STR0004+" "+STR0001,.F.) //"Alterar"
	ElseIf nOperation == MODEL_OPERATION_DELETE
		AGDGRAVAHIS("","NEJ",xFilial("NEJ")+oNEJ:Getvalue('NEJ_CODIGO'),STR0005+" "+STR0001,.F., oNEJ:Getvalue('NEJ_CODIGO')) //"Excluir"
	EndIf

	FWRestArea(aArea)
return nil

/*/{Protheus.doc} VldActivate
Validação de Ativação do Módulo
@type method
@version 12
@author jean.schulze
@since 02/09/2025
@param oModel, object, modelo
@param cModelId, character, modelo id
@return variant, true/false
/*/
Method VldActivate(oModel, cModelId) Class AGDA060EVT
	Local aArea := FWGetArea()
    Local nOperation := oModel:GetOperation()	
    Local lRet  := .T.

    If nOperation == MODEL_OPERATION_UPDATE
        If NEJ->NEJ_STATUS == "3" // Cancelado
            AGDHELP(STR0012, STR0022) //"Fechamento cancelado não pode ser alterado."
            lRet := .F.
        EndIf
    EndIf

    FWRestArea(aArea)
Return lRet
