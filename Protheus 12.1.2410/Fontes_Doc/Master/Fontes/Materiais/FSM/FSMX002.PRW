#INCLUDE 'PROTHEUS.CH'
#INCLUDE 'FWMVCDEF.CH'
#INCLUDE 'TOTVS.CH'

//-------------------------------------------------------------------
/*/{Protheus.doc} FSMX002(cCodOrdem, cCodAtend, cMsgRet, aCodRet)
Função que gera o formulário do checklist de acordo com o atendente e O.S.
@author flavio.martins
@since 03/10/2024
@version 1.00
*/
//-------------------------------------------------------------------
Function FSMX002(cCodigo, cCodAtend, cMsgRet, aCodRet)


Local lRet      := .T.
Local cQuery    := ''
Local oQryTmp   := Nil
Local cAliasTmp := GetNextAlias()
Local oMdlJNR    := Nil
Local cCodRet   := ''


cQuery += " SELECT "
cQuery += "   JN6.JN6_CODIGO, "
cQuery += "   JN6.JN6_CODJN3, "
cQuery += "   JN6.JN6_CODAA1, "
cQuery += "   JND.JND_CODIGO, "
cQuery += "   JND.JND_VERSAO "
cQuery += " FROM " + RetSqlName('JN6') + " JN6 "
cQuery += "   INNER JOIN " + RetSqlName('JN3') + " JN3 ON JN3.JN3_FILIAL = ? "
cQuery += "   AND JN3.JN3_CODIGO = JN6.JN6_CODJN3 "
cQuery += "   AND JN3.D_E_L_E_T_ = ' ' "
cQuery += "   INNER JOIN " + RetSqlName('AA3') + " AA3 ON AA3.AA3_FILIAL = ? "
cQuery += "   AND AA3.AA3_CODPRO = JN3.JN3_CODPRO "
cQuery += "   AND AA3.AA3_NUMSER = JN3.JN3_NUMSER "
cQuery += "   AND AA3.D_E_L_E_T_ = ' ' "
cQuery += "   INNER JOIN " + RetSqlName('JNH') + " JNH ON JNH.JNH_FILIAL = ? "
cQuery += "   AND JNH.JNH_CODPRO = AA3.AA3_CODPRO "
cQuery += "   AND JNH.JNH_NUMSER = AA3.AA3_NUMSER "
cQuery += "   AND JNH.D_E_L_E_T_ = ' ' "
cQuery += "   INNER JOIN " + RetSqlName('JND') + " JND ON JND.JND_FILIAL = ? "
cQuery += "   AND JND.JND_CODIGO = JNH.JNH_CODJND "
cQuery += "   AND JND.JND_STATUS = '2' "
cQuery += "   AND JND.D_E_L_E_T_ = ' ' "
cQuery += " WHERE "
cQuery += "   JN6.JN6_FILIAL = ? "
cQuery += "   AND JN6.JN6_CODIGO = ? "
cQuery += "   AND JN6.JN6_RESCHK = 'T' "
cQuery += "   AND JN6.D_E_L_E_T_ = ' ' "

oQryTmp := FwPreparedStatement():New(cQuery)

oQryTmp:SetString(1, xFilial("JN3"))
oQryTmp:SetString(2, xFilial("AA3"))
oQryTmp:SetString(3, xFilial("JNH"))
oQryTmp:SetString(4, xFilial("JND"))
oQryTmp:SetString(5, xFilial("JN6"))
oQryTmp:SetString(6, cCodigo)

cQuery    := oQryTmp:GetFixQuery()
cAliasTmp := MpSysOpenQuery(cQuery)

Begin Transaction 

While !(cAliasTmp)->(Eof())

    lRet := GeraForm((cAliasTmp)->JND_CODIGO, (cAliasTmp)->JND_VERSAO, @cCodRet) 

    If lRet 

        oMdlJNR := FwLoadModel('FSMA022')
        oMdlJNR:SetOperation(MODEL_OPERATION_INSERT)
        oMdlJNR:Activate()

        oMdlJNR:GetModel('JNRMASTER'):SetValue('JNR_CODJN3', (cAliasTmp)->JN6_CODJN3)
        oMdlJNR:GetModel('JNRMASTER'):SetValue('JNR_CODAA1', (cAliasTmp)->JN6_CODAA1)
        oMdlJNR:GetModel('JNRMASTER'):SetValue('JNR_CODJND', (cAliasTmp)->JND_CODIGO)
        oMdlJNR:GetModel('JNRMASTER'):SetValue('JNR_VERSAO', (cAliasTmp)->JND_VERSAO)
        oMdlJNR:GetModel('JNRMASTER'):SetValue('JNR_CODJN6', (cAliasTmp)->JN6_CODIGO)
        oMdlJNR:GetModel('JNRMASTER'):SetValue('JNR_CODJNN', cCodRet)

        If oMdlJNR:VldData()
            oMdlJNR:CommitData()
            Aadd(aCodRet, cCodRet)
        Endif 
      
    Endif

    (cAliasTmp)->(dbSkip())

EndDo

End Transaction

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} GeraForm(cCodigo, cVersao, cCodRet)
Função que gera o formulário do checklist
@author flavio.martins
@since 03/10/2024
@version 1.0
*/
//-------------------------------------------------------------------
Static Function GeraForm(cCodigo, cVersao, cCodRet)

Local lRet := .T.
Local oMdlChk  := FwLoadModel('FSMA016')
Local oMdlForm := FwLoadModel('FSMA021')
Local oMdlJNE  := Nil
Local oMdlJNF  := Nil
Local oMdlJNG  := Nil
Local oMdlJNO  := Nil
Local oMdlJNP  := Nil
Local oMdlJNQ  := Nil
Local nPasso   := 0
Local nPerg    := 0
Local nOpcao   := 0

JND->(dbSetOrder(1))

If JND->(dbSeek(xFilial('JND')+cCodigo+cVersao))

    oMdlChk:SetOperation(MODEL_OPERATION_VIEW)
    oMdlChk:Activate()

    oMdlForm:SetOperation(MODEL_OPERATION_INSERT)
    oMdlForm:Activate()

    oMdlForm:GetModel('JNNMASTER'):SetValue('JNN_CODJND', oMdlChk:GetValue('JNDMASTER', 'JND_CODIGO'))
    oMdlForm:GetModel('JNNMASTER'):SetValue('JNN_VERSAO', oMdlChk:GetValue('JNDMASTER', 'JND_VERSAO'))

    oMdlJNE := oMdlChk:GetModel('JNEDETAIL')
    oMdlJNO := oMdlForm:GetModel('JNODETAIL')

    For nPasso := 1 To oMdlJNE:Length()

        oMdlJNE:GoLine(nPasso)

        If !(oMdlJNO:IsEmpty())
            oMdlJNO:AddLine()
        Endif

        oMdlJNO:SetValue('JNO_CODJNE', oMdlJNE:GetValue('JNE_CODIGO'))
        oMdlJNO:SetValue('JNO_ITEM', oMdlJNE:GetValue('JNE_ITEM'))

        oMdlJNF := oMdlChk:GetModel('JNFDETAIL')
        oMdlJNP := oMdlForm:GetModel('JNPDETAIL')

        For nPerg := 1 To oMdlJNF:Length()

            oMdlJNF:GoLine(nPerg)


            If !(oMdlJNP:IsEmpty())
                oMdlJNP:AddLine()
            Endif

            oMdlJNP:SetValue('JNP_CODJNF', oMdlJNF:GetValue('JNF_CODIGO'))
            oMdlJNP:SetValue('JNP_ITEM', oMdlJNF:GetValue('JNF_ITEM'))

            oMdlJNG := oMdlChk:GetModel('JNGDETAIL')
            oMdlJNQ := oMdlForm:GetModel('JNQDETAIL')

            For nOpcao := 1 to oMdlJNG:Length()

                If !(oMdlJNQ:IsEmpty())
                    oMdlJNQ:AddLine()
                Endif

                oMdlJNQ:SetValue('JNQ_CODJNG', oMdlJNG:GetValue('JNG_CODIGO', nOpcao))

            Next

        Next

    Next

    If oMdlForm:VldData()
        oMdlForm:CommitData()
        cCodRet := oMdlForm:GetValue('JNNMASTER', 'JNN_CODIGO')
    Else 
        lRet := .F.
    Endif

Endif


Return lRet
