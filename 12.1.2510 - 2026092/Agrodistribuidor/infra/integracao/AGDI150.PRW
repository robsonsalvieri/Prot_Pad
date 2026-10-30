#Include "totvs.ch"
#Include "FWMVCDEF.ch"
#Include "AGDI150.ch"


/*/{Protheus.doc} AGDI150
Função para adicionar validações de produto de acordo com NCR.
@type  Function
@author user
@since 24/07/2026
@version version
@param param_name, param_type, param_descr
@return return_var, return_type, return_description
@example
(examples)
@see (links_or_references)
/*/
Function AGDI150(oModel, cModelId)
    Local lRet := .T.

	If cModelId == "FORMNCR"
		If NCR->(FieldPos("NCR_FABCOD")) > 0 .AND. !Empty(oModel:GetValue("NCR_FABCOD")) .AND. Empty(oModel:GetValue("NCR_FABLOJ"))
			lRet := .F.
			AGDHELP(STR0001, STR0008, STR0009) //Atenção. Campo obrigatório Loja Fabric. Informe o campo Loja Fabric. nos dados de Produtos Agronegócio          
		EndIf
		If lRet
			lRet := AGDI01VFAB(oModel)			
			If lRet 
				lRet := AGDI150GRP(oModel)
			EndIf
		EndIf
	Endif

Return lRet


/*/{Protheus.doc} AGDI01VFAB
Validação de campo NCR_FABCOD e NCR_FABLOJ na SX3.
@type function
@version  P12
@author claudineia.reinert
@since 30/06/2026
/*/
Function AGDI01VFAB(oModel)
	Local lRet := .T.
	Local cCodFab := oModel:GetValue("NCR_FABCOD")
	Local cLojaFab := oModel:GetValue("NCR_FABLOJ")
	Local aAreaSA2 := SA2->(GetArea())

	If !Empty(cCodFab)
		DBSelectArea("SA2")
		SA2->(DBSetOrder(1))
		If !SA2->(DBSeek(xFilial("SA2")+cCodFab+cLojaFab))
			lRet := .F. 
			AGDHELP(STR0001, STR0002,  STR0003 ) // Atenção. Fabricante não encontrado. Função para adicionar validações de produto de acordo com NCR.
		Else
			If !Empty(cLojaFab) .AND. !(SA2->A2_FABRICA $ ("1|3")) //Informada Loja mas não é fabricante
				lRet := .F.
				AGDHELP(STR0001, STR0004, STR0005 ) //Atenção A loja informada não é Fabricante. Verifique o preenchimento do campo Loja Fabric. (NCR_FABLOJ).
			Else
				lRet := .F.
				//valida apenas o codigo se é fabricante, pois pode existir mais de uma loja para o mesmo código
				While SA2->(!Eof()) .and. SA2->A2_COD == cCodFab
					If SA2->A2_FABRICA $ ("1|3")
						lRet := .T.
						exit
					EndIf
				EndDo
			EndIf
		EndIf
	EndIf

	RestArea(aAreaSA2)
Return lRet

/*/{Protheus.doc} AGDI150GRP
Validação do campo NCR_SUBGRP.
@type  Function
@author ronery.filho
@since 24/07/2026
@version 1.0
/*/
Function AGDI150GRP(oModel)
	Local lRet := .T.
	Local cCodSubGrp := oModel:GetValue("NCR_SUBGRP")
	Local aAreaNF8 := Nil
	
	If FWAliasInDic("NF8")
		aAreaNF8 := NF8->(GetArea())
		If M->B1_GRUPO != Nil .AND. !Empty(cCodSubGrp)
			lRet := POSICIONE("NF8",1,xFilial("NF8")+cCodSubGrp,"NF8_GRPPRD") == M->B1_GRUPO
		Endif
		If !lRet
			AGDHELP(STR0001, STR0006, STR0007) // Atenção. Sub-Grupo não pertence ao grupo Grupo informado no produto. Verifique o preenchimento do campo Grupo (B1_GRUPO).
		Endif

		RestArea(aAreaNF8)
	Endif
Return lRet
