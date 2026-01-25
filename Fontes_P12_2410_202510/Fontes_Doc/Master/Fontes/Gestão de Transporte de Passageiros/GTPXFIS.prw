#INCLUDE 'PROTHEUS.ch'

/*/{Protheus.doc} GtpXFis(dDataIni, dDataFim)
//TODO Descrição auto-gerada.
@author GTP
@since 06/10/2021
@version 1.0
@return ${return}, ${return_description}
@type function
/*/
Function GtpXFis(dDataIni, dDataFim)
Local lRet      := .T.
Local cAliasTmp := GetNextAlias()
Local cFilPos   := FwGetCodFilial
Local cTipoDb   := Upper(TcGetDb())
Local cSelect   := ''
Local cQryAux   := ''

Default dDataIni := Ctod("//")
Default dDataFim := Ctod("//")

lRet := ValidaDic()

If lRet

    cSelect := " COUNT(*) AS TOTAL "
    cQryAux := " AND GIC.GIC_CODIGO <> '"+SPACE(TamSx3("GIC_CODIGO")[1])+"' " 

    cSelect := '%' + cSelect + '%'
    cQryAux := '%' + cQryAux + '%'

    BeginSql Alias cAliasTmp

        SELECT %Exp:cSelect%
        FROM %Table:GIC% GIC
        INNER JOIN %Table:SFT% SFT ON SFT.FT_FILIAL = GIC.GIC_FILNF
        AND SFT.FT_NFISCAL = GIC.GIC_NOTA
        AND SFT.FT_SERIE = GIC.GIC_SERINF
        AND SFT.FT_CLIEFOR = GIC.GIC_CLIENT
        AND SFT.FT_LOJA = GIC.GIC_LOJA
        AND SFT.FT_ESPECIE IN ('BPR','BPE')
        AND SFT.%NotDel%
        WHERE GIC.GIC_DTVEND BETWEEN %Exp:dDataIni% AND %Exp:dDataFim%
        AND GIC.%NotDel%
        AND GIC.GIC_FILNF = %Exp:cFilPos%
        AND GIC.GIC_STAPRO = '1'
        %Exp:cQryAux%

    EndSql

    lRet := (cAliasTmp)->TOTAL > 0 //AllTrim(((cAliasTmp)->GIC_CODIGO)) <> ''

    (cAliasTmp)->(dbCloseArea())

Endif

Return lRet

/*/{Protheus.doc} ValidaDic()
//TODO Descrição auto-gerada.
@author GTP
@since 06/10/2021
@version 1.0
@return ${return}, ${return_description}
@type function
/*/
Static Function ValidaDic()
Local lRet          := .T.
Local aFldsGIC      := {'GIC_FILNF','GIC_NOTA','GIC_SERINF','GIC_CLIENT','GIC_LOJA','GIC_CODRMD'}
Local aFldsGZU      := {'GZU_AGENCI','GZU_DOC','GZU_SERIE','GZU_DTMOV'}
Local lVldAlias     := .T.
Local lVldCampos    := .T.

lRet := FindFunction('GtpxVldDic') .And. GTPxVldDic('GIC', aFldsGIC, lVldAlias, lVldCampos) .And.;
        GTPxVldDic('GZU', aFldsGZU, lVldAlias, lVldCampos)

Return lRet
