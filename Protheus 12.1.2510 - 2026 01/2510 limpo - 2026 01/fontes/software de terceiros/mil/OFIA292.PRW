#INCLUDE "Totvs.ch"
#INCLUDE "TopConn.ch"

/*/{Protheus.doc} OFIA292
Funcoes DMS - Chamadas pelo faturamento backoffice

@author Luiz Pereira da Silva Junior
@since 31/10/2025
@version 1.0
@return NIL
/*/

Function OFIA292()
Return NIL

/*/{Protheus.doc} OA292001G_DMS461GeraSD2
	Chamada do MATA461, especificamente da função MaPvl2Sd2. É a gravação da SD2 (item da nota fiscal de saída).
	Logo após MaFisIniLoad.

	@author Luiz Pereira da Silva Junior
	@since 31/10/2025
/*/
Function OA292001G_DMS461GeraSD2(nItem)

	Local cSql := ""
    Local aArea := GetArea()

	If !cPaisLoc == "BRA" .Or. !IsInCallStack("VEIXX002") //Somente para Brasil e Atendimento Modelo 2
        RestArea(aArea)
        Return()
    EndIf

    If FWAliasInDic("VVA", .F.)
        If VVA->(FieldPos("VVA_DEDCOM")) > 0 
            
            cSql := "SELECT VVA.VVA_DEDCOM, VVA.VVA_VALSUG "
            cSql += "FROM " + RetSqlName("VVA") + " VVA "
            cSql += "WHERE VVA.D_E_L_E_T_ = ' ' AND VVA.VVA_FILIAL = '" + xFilial("VVA") + "' AND "
            cSql += "   VVA.VVA_NUMSC6 = '" + SC6->C6_NUM + "' AND VVA.VVA_ITESC6 = '" + SC6->C6_ITEM + "' "

            TcQuery cSql New Alias "TMPVVA"

            If !TMPVVA->(Eof()) //Não deverá ter mais de um item
                If TMPVVA->VVA_DEDCOM > 0 //Valor da Dedução por Comissão
                    Mafisload("IT_COMISVEI", TMPVVA->VVA_DEDCOM, nItem)
                EndIf

                If TMPVVA->VVA_VALSUG > 0 //Valor sugerido para base de cálculo
                    Mafisload("IT_PRCSUGE", TMPVVA->VVA_VALSUG, nItem)
                EndIf
            EndIf

            TMPVVA->(DbCloseArea())

        EndIf
    EndIf

    RestArea(aArea)

Return()


/*/{Protheus.doc} OA292002G_DMSItem410Impos
	
	Utilizado somente para visualização da planilha financeira do pedido de vendas. 
	Chamada do MATN410B, especificamente da função Ma410Impos. Posicionada na montagem de dados para o 
	motor de cálculo fiscal, logo após MafisIniLoad.

	Passei como variáveis do fonte MATN410B nX - Item do aCols e nItem - Item do motor de calculo fiscal. Eles costumam
	ser iguais, mas como o fonte diferencia, passei os 2 por segurança.

	@author Luiz Pereira da Silva Junior
	@since 31/10/2025
/*/
Function OA292002G_DMSItem410Impos(nLinCols, nItem/*Item Fiscal*/)

    Local cSql := ""
    Local aArea := GetArea()

    Local nPItem    := aScan(aHeader,{|x| AllTrim(x[2])=="C6_ITEM"})

    If !cPaisLoc == "BRA"
        RestArea(aArea)
        Return()
    EndIf

    If FWAliasInDic("VVA", .F.)

        If VVA->(FieldPos("VVA_DEDCOM")) > 0
            
            cSql := "SELECT VVA.VVA_DEDCOM, VVA.VVA_VALSUG "
            cSql += "FROM " + RetSqlName("VVA") + " VVA "
            cSql += "WHERE VVA.D_E_L_E_T_ = ' ' AND VVA.VVA_FILIAL = '" + xFilial("VVA") + "' AND "
            cSql += "   VVA.VVA_NUMSC6 = '" + M->C5_NUM + "' AND VVA.VVA_ITESC6 = '" + aCols[nLinCols][nPItem] + "' "

            TcQuery cSql New Alias "TMPVVA"

            If !TMPVVA->(Eof()) //Não deverá ter mais de um item
                If TMPVVA->VVA_DEDCOM > 0 //Valor da Dedução por Comissão
                    MafisLoad("IT_COMISVEI", TMPVVA->VVA_DEDCOM, nItem)
                EndIf

                If TMPVVA->VVA_VALSUG > 0 //Valor sugerido para base de cálculo
                    MafisLoad("IT_PRCSUGE", TMPVVA->VVA_VALSUG, nItem)
                EndIf
            EndIf

            TMPVVA->(DbCloseArea())

        EndIf
    EndIf

    RestArea(aArea)
Return()