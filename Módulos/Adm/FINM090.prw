#Include "PROTHEUS.CH"

/*/{Protheus.doc} FINM090F7K
    Função para gerar a inclusão, alteração ou exclusão do registro de banco SA6 na tabela F7K
    @type  Function
    @author Bruno Rosa
    @since 17/06/2025
    @param oModel, Object, Modelo de dados 
	@param nOper, Numeric, Operação do modelo
	@param cChave, Character, Chave do banco
/*/
Function FINM090F7K(oModel as Object,nOper as Numeric,cChave as Character)

    Local aAreaF7K  as Array
    Local cCodBanc  as Character
    Local cAgencia  as Character
    Local cNumCont  as Character
    Local cDvAge    as Character
    Local cDvCta    as Character
    Local cConta    as Character
    Local cNome     as Character
    Local nMoeda    as Numeric
    Local oTABSA6	as Object

    Default oModel := Nil
    Default nOper  := 0
    Default cChave := ""

    aAreaF7K    := {}

    If oModel <> Nil
        oTABSA6     := oModel:GetModel("MATA070_SA6")
        cCodFil     := oTABSA6:GetValue("A6_FILIAL")
        cCodBanc    := oTABSA6:GetValue("A6_COD")
        cAgencia    := oTABSA6:GetValue("A6_AGENCIA")
        cNumCont    := oTABSA6:GetValue("A6_NUMCON")
        cDvAge      := oTABSA6:GetValue("A6_DVAGE")
        cDvCta      := oTABSA6:GetValue("A6_DVCTA")
        cConta      := oTABSA6:GetValue("A6_CONTA")
        cNome       := oTABSA6:GetValue("A6_NOME")
        nMoeda      := oTABSA6:GetValue("A6_MOEDA")
    EndIf

    If AliasIndic("F7K")

        aAreaF7K := F7K->(GetArea())
        dbSelectArea("F7K")

        If nOper == 3 .OR. nOper == 4

			F7K->(DbGoTop())
			F7K->(dbSetOrder(1))

            If F7K->(dbSeek(cChave))
                If cDvAge <> F7K->F7K_DVAGE .OR. cDvCta <> F7K->F7K_DVCTA .OR. cNome <> F7K->F7K_NOME .OR. cConta <> F7K->F7K_CONTA .OR. nMoeda <> F7K->F7K_MOEDA
                    RecLock("F7K",.F.)
                    F7K->F7K_DVAGE  := cDvAge
                    F7K->F7K_DVCTA  := cDvCta
                    F7K->F7K_NOME   := cNome
                    F7K->F7K_CONTA  := cConta
                    F7K->F7K_MOEDA  := nMoeda
                    F7K->(MsUnlock())
                EndIf
            Else
                RecLock("F7K",.T.)
                F7K->F7K_FILIAL := xFilial("SA6")
                F7K->F7K_COD    := cCodBanc
                F7K->F7K_AGENCI := cAgencia
                F7K->F7K_NUMCON := cNumCont
                F7K->F7K_DVAGE  := cDvAge
                F7K->F7K_DVCTA  := cDvCta
                F7K->F7K_NOME   := cNome
                F7K->F7K_CONTA  := cConta
                F7K->F7K_MOEDA  := nMoeda
                F7K->(MsUnlock())
            EndIf

        ElseIf nOper == 5

			F7K->(dbSetOrder(1))
            If F7K->(dbSeek(cChave))
                RecLock("F7K",.F.)
                F7K->(DbDelete())
                F7K->(MsUnlock())
            EndIf

        EndIf

        RestArea(aAreaF7K)
        
    EndIf
    FwFreeArray(aAreaF7K)

Return 

/*/{Protheus.doc} m070DelF7K
	Busca registro na F7k para exclusão

	@type  Function
	@author TOTVS
	@since 18/06/2025
	@version 1.0
/*/
Function m090DelF7K()

	Local aArea as Array

	aArea := GetArea()

	If SA6->(FieldPos("A6_INTEGRA")) > 0 .AND. SA6->A6_INTEGRA == '1' .AND. FindFunction("FINM090F7K")
		FINM090F7K(,5,xFilial("SA6") + SA6->A6_COD + SA6->A6_AGENCIA + SA6->A6_NUMCON)
	EndIf	

	RestArea(aArea)
	FwFreeArray(aArea)

Return
