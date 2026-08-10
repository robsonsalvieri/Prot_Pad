#INCLUDE "TOTVS.CH"

Static _lMrpInSMQ  := FWAliasInDic("SMQ", .F.) .And. Findfunction("mrpInSMQ")

/*/{Protheus.doc} M018IntMrp
Executa a integração com o MRP para os indicadores de produtos cadastrados pelo programa MATA018.
@type  Function
@author Lucas Fagundes
@since 17/10/2022
@version P12
@return Nil
/*/
Function M018IntMrp()
    Local aDados     := {}
    Local cOperation := ""     
    Local lOnline    := .F.
    Local nRecno     := SBZ->(Recno())

    If _lMrpInSMQ .and. !mrpInSMQ(xFilial("SBZ"))
		Return nil	
	EndIf

    IntNewMRP("MRPPRODUCTINDICATOR", @lOnline)

    If lOnline
        buscaDados(nRecno, @aDados, @cOperation)
        
        If Len(aDados) > 0
            MATA019INT(cOperation, aDados)
        EndIf
    EndIf

    FwFreeArray(aDados)
Return Nil

/*/{Protheus.doc} buscaDados
Busca os dados da SBZ para serem integrados.
@type  Static Function
@author Lucas Fagundes
@since 17/10/2022
@version P12
@param 01 nRecno    , Numerico, Recno do registro que irá buscar os dados para integrar.
@param 02 aDados    , Array   , Retorna por referência o array com os dados.
@param 03 cOperation, Caracter, Retorna por referência a operação que será realizada na API.
@return Nil
/*/
Static Function buscaDados(nRecno, aDados, cOperation)
    
    SBZ->(DbGoTo(nRecno))
    If SBZ->(Recno()) == nRecno
        aAdd(aDados, Array(A019APICnt("ARRAY_IND_PROD_POS_SIZE")))
        cOperation := "DELETE"

        aDados[1][A019APICnt("ARRAY_IND_PROD_POS_FILIAL" )] := SBZ->BZ_FILIAL
        aDados[1][A019APICnt("ARRAY_IND_PROD_POS_PROD"   )] := formatB1(SBZ->BZ_COD)
        aDados[1][A019APICnt("ARRAY_IND_PROD_POS_IDREG"  )] := SBZ->BZ_FILIAL + formatB1(SBZ->BZ_COD)

        If SBZ->(!Deleted())
            cOperation := "INSERT"

            aDados[1][A019APICnt("ARRAY_IND_PROD_POS_LOCPAD" )] := SBZ->BZ_LOCPAD
            aDados[1][A019APICnt("ARRAY_IND_PROD_POS_QE"     )] := SBZ->BZ_QE
            aDados[1][A019APICnt("ARRAY_IND_PROD_POS_EMIN"   )] := SBZ->BZ_EMIN
            aDados[1][A019APICnt("ARRAY_IND_PROD_POS_ESTSEG" )] := SBZ->BZ_ESTSEG
            aDados[1][A019APICnt("ARRAY_IND_PROD_POS_PE"     )] := SBZ->BZ_PE
            aDados[1][A019APICnt("ARRAY_IND_PROD_POS_TIPE"   )] := M019CnvFld("BZ_TIPE", SBZ->BZ_TIPE)
            aDados[1][A019APICnt("ARRAY_IND_PROD_POS_LE"     )] := SBZ->BZ_LE
            aDados[1][A019APICnt("ARRAY_IND_PROD_POS_LM"     )] := SBZ->BZ_LM
            aDados[1][A019APICnt("ARRAY_IND_PROD_POS_TOLER"  )] := SBZ->BZ_TOLER
            aDados[1][A019APICnt("ARRAY_IND_PROD_POS_MRP"    )] := M019CnvFld("BZ_MRP", SBZ->BZ_MRP)
            aDados[1][A019APICnt("ARRAY_IND_PROD_POS_REVATU" )] := SBZ->BZ_REVATU
            aDados[1][A019APICnt("ARRAY_IND_PROD_POS_EMAX"   )] := SBZ->BZ_EMAX
            aDados[1][A019APICnt("ARRAY_IND_PROD_POS_HORFIX" )] := SBZ->BZ_HORFIX
            aDados[1][A019APICnt("ARRAY_IND_PROD_POS_TPHFIX" )] := SBZ->BZ_TPHOFIX
            aDados[1][A019APICnt("ARRAY_IND_PROD_POS_OPC"    )] := SBZ->BZ_MOPC
            aDados[1][A019APICnt("ARRAY_IND_PROD_POS_STR_OPC")] := SBZ->BZ_OPC
            aDados[1][A019APICnt("ARRAY_IND_PROD_POS_QTDB"   )] := SBZ->BZ_QB
        EndIf
    EndIf

Return Nil

/*/{Protheus.doc} formatB1
Formata o código do produto com o tamanho do campo B1_COD.
@type  Static Function
@author Lucas Fagundes
@since 18/10/2022
@version P12
@param cCodProd, Caracter, Código do produto para formatar.
@return cCodB1, Caracter, Código do produto formatado com o tamanho do campo B1_COD
/*/
Static Function formatB1(cCodProd)
    
Return PadR(AllTrim(cCodProd), GetSX3Cache("B1_COD", "X3_TAMANHO"))
