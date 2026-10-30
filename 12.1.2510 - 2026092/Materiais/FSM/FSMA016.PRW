#INCLUDE 'PROTHEUS.CH'
#INCLUDE 'FWMVCDEF.CH'
#INCLUDE "PARMTYPE.CH"

PUBLISH MODEL REST NAME FSMCHECKLIST source FSMA016 RESOURCE OBJECT FsmRestModel

Static Function ModelDef()

Local oModel	 := Nil
Local oStrJND1	 := FWFormStruct(1,"JND")
Local oStrJND2	 := FWFormStruct(1,"JND")
Local oStrJNE	 := FWFormStruct(1,"JNE")
Local oStrJNF	 := FWFormStruct(1,"JNF")
Local oStrJNG	 := FWFormStruct(1,"JNG")
Local bCommit	 := {|oModel| FSM16Commit(oModel)}
Local bLinePost	 := {|oModelGrid| JNFLinePos(oModelGrid) }
Local bFieldTrig := {|oMdl,cField,uVal| FieldTrigger(oMdl,cField,uVal)}

oStrJND1:AddField("Descr. Servico","Descr. Servico","JND_DSCSER","C",TamSx3('JN1_DESCRI')[1],0,{|| .T.},{|| .T.},{},.F.,NIL,.F.,.F.,.T.)						
oStrJND1:AddField("Chave Unica","Chave Unica","JND_PK","C",100,0,{|| .T.},{|| .T.},{},.F.,NIL,.F.,.F.,.T.)						
oStrJND1:AddField("Nome Usuario","Nome Usuario","JND_NOMUSU","C",100,0,{|| .T.},{|| .T.},{},.F.,NIL,.F.,.F.,.T.)						
oStrJND1:AddField("Acao","Acao","JND_ACAO","C",12,0,{|| .T.},{|| .T.},{},.F.,NIL,.F.,.F.,.T.)						
oStrJND2:AddField("Chave Unica","Chave Unica","JND_PK","C",100,0,{|| .T.},{|| .T.},{},.F.,NIL,.F.,.F.,.T.)						
oStrJND2:AddField("Nome Usuario","Nome Usuario","JND_NOMUSU","C",100,0,{|| .T.},{|| .T.},{},.F.,NIL,.F.,.F.,.T.)						

oStrJND1:AddTrigger("JND_ACAO", "JND_ACAO", {||.T.}, bFieldTrig)

oModel := MPFormModel():New('FSMA016', /*bPreValid*/, /*bPosValid*/, /*bCommit*/, /*bCancel*/)

oModel:AddFields('JNDMASTER',/*cOwner*/,oStrJND1)
oModel:AddGrid( 'JNDDETAIL', 'JNDMASTER', oStrJND2)
oModel:AddGrid( 'JNEDETAIL', 'JNDMASTER', oStrJNE)
oModel:AddGrid( 'JNFDETAIL', 'JNEDETAIL', oStrJNF,, bLinePost)
oModel:AddGrid( 'JNGDETAIL', 'JNFDETAIL', oStrJNG,, bLinePost)

oModel:SetPrimaryKey({"JND_CODIGO","JND_VERSAO"})

oModel:SetRelation('JNDDETAIL', {{'JND_FILIAL', 'xFilial("JND")'},;
                                 {'JND_CODIGO', 'JND_CODIGO'}},;
                                 JND->(IndexKey(1)))

oModel:SetRelation('JNEDETAIL', {{'JNE_FILIAL', 'xFilial("JNE")'},;
                                 {'JNE_CODJND', 'JND_CODIGO'},;
                                 {'JNE_VERSAO', 'JND_VERSAO'}},;
                                 JNE->(IndexKey(2)))

oModel:SetRelation('JNFDETAIL', {{'JNF_FILIAL', 'xFilial("JNF")'},;
                                 {'JNF_CODJNE', 'JNE_CODIGO'}},;
                                 JNF->(IndexKey(2)))

oModel:SetRelation('JNGDETAIL', {{'JNG_FILIAL', 'xFilial("JNG")'},;
                                 {'JNG_CODJNF', 'JNF_CODIGO'}},;
                                 JNG->(IndexKey(2)))

oModel:GetModel("JNDDETAIL"):SetLoadFilter(, "JND_STATUS IN ('3')")

oModel:SetDescription('Cadastro de checklist')
oModel:GetModel('JNDMASTER'):SetDescription("Cadastro de checklist")

oStrJND1:SetProperty("JND_DSCSER",MODEL_FIELD_INIT,;
                     FwBuildFeature(STRUCT_FEATURE_INIPAD,'If(!INCLUI,Posicione("JN1",1,xFilial("JN1")+JND->JND_TPSERV,"JN1_DESCRI"),"")'))

oStrJND1:SetProperty( 'JND_PK' , MODEL_FIELD_INIT,{|| Encode64(JND->JND_FILIAL+JND->JND_CODIGO+JND->JND_VERSAO)   })
oStrJND1:SetProperty( 'JND_NOMUSU' , MODEL_FIELD_INIT,{|| UsrRetName(JND->JND_USUINC)  })
oStrJND2:SetProperty( 'JND_PK' , MODEL_FIELD_INIT,{|| Encode64(JND->JND_FILIAL+JND->JND_CODIGO+JND->JND_VERSAO)   })
oStrJND2:SetProperty( 'JND_NOMUSU' , MODEL_FIELD_INIT,{|| UsrRetName(JND->JND_USUINC)  })

oStrJNE:SetProperty("JNE_CODIGO",MODEL_FIELD_INIT,;
                     FwBuildFeature(STRUCT_FEATURE_INIPAD, 'GetSxEnum("JNE","JNE_CODIGO")'))

oStrJNF:SetProperty("JNF_CODIGO",MODEL_FIELD_INIT,;
                     FwBuildFeature(STRUCT_FEATURE_INIPAD, 'GetSxEnum("JNF","JNF_CODIGO")'))

oStrJNG:SetProperty("JNG_CODIGO",MODEL_FIELD_INIT,;
                     FwBuildFeature(STRUCT_FEATURE_INIPAD, 'GetSxEnum("JNG","JNG_CODIGO")'))

oModel:GetModel("JNDDETAIL"):SetOnlyQuery(.T.)
oModel:GetModel("JNDDETAIL"):SetOptional(.T.)
oModel:GetModel("JNEDETAIL"):SetOptional(.T.)
oModel:GetModel("JNFDETAIL"):SetOptional(.T.)
oModel:GetModel("JNGDETAIL"):SetOptional(.T.)

oModel:SetCommit(bCommit)

Return oModel

Static Function JNFLinePos(oModelGrid)
Local oModel := oModelGrid:GetModel()
Local lRet 	 := .T.

If oModelGrid:cId == 'JNFDETAIL'
    oModelGrid:SetValue('JNF_CODJND', oModel:GetValue('JNDMASTER', 'JND_CODIGO'))
    oModelGrid:SetValue('JNF_VERSAO', oModel:GetValue('JNDMASTER', 'JND_VERSAO'))
Endif

If oModelGrid:cId == 'JNGDETAIL'
    oModelGrid:SetValue('JNG_CODJNE', oModel:GetValue('JNEDETAIL', 'JNE_CODIGO'))
    oModelGrid:SetValue('JNG_VERSAO', oModel:GetValue('JNDMASTER', 'JND_VERSAO'))
    oModelGrid:SetValue('JNG_CODJND', oModel:GetValue('JNDMASTER', 'JND_CODIGO'))
Endif

Return lRet

Static Function FieldTrigger(oMdl,cField,uVal)

If cField == 'JND_ACAO' .And. AllTrim(uVal) == 'NEWVERSION'
    oMdl:SetValue("JND_VERSAO", RetNextVer(oMdl:GetValue('JND_CODIGO')))
Endif

Return uVal

Static Function RetNextVer(cCodigo)
Local cVersao := ''
Local cQuery  := ''
Local oQryTmp := Nil
Local cAliasTmp := Nil

cQuery := "SELECT COALESCE(MAX(JND_VERSAO),'0') AS JND_VERSAO"
cQuery += " FROM " + RetSqlName("JND")
cQuery += " WHERE JND_FILIAL = ?"
cQuery += " AND JND_CODIGO = ?"
cQuery += " AND D_E_L_E_T_ = ' '"

oQryTmp := FwPreparedStatement():New(cQuery)

oQryTmp:SetString(1, xFilial("JND"))
oQryTmp:SetString(2, cCodigo) 

cQuery    := oQryTmp:GetFixQuery()
cAliasTmp := MpSysOpenQuery(cQuery)

cVersao := StrZero((Val((cAliasTmp)->JND_VERSAO) + 1),TamSx3('JND_VERSAO')[1])

(cAliasTmp)->(dbCloseArea())

Return cVersao

Static Function FSM16Commit(oModel)
Local cCodigo := oModel:GetValue('JNDMASTER', 'JND_CODIGO')
Local cVersao := oModel:GetValue('JNDMASTER', 'JND_VERSAO')
Local cAcao   := oModel:GetValue('JNDMASTER', 'JND_ACAO')

Begin Transaction

    If oModel:GetOperation() == MODEL_OPERATION_INSERT .And. AllTrim(cAcao) == 'NEWVERSION'
        AtuStatus(cCodigo, cVersao)
    Endif

    If oModel:VldData()
        FwFormCommit(oModel)
    Endif

End Transaction

Return .T.

Static Function AtuStatus(cCodigo, cVersao)
Local aAreaJND   := JND->(GetArea())
Local cVersaoAnt := StrZero((Val(cVersao)-1), TamSx3('JND_VERSAO')[1])

Default cCodigo := ''
Default cVersao := ''

JND->(dbSetOrder(1))

If JND->(dbSeek(xFilial('JND')+cCodigo+cVersaoAnt))

    Reclock('JND', .F.)
        JND->JND_STATUS := '3'
    JND->(MsUnLock())

Endif
    
RestArea(aAreaJND)


Return

