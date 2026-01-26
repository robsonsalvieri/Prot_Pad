#INCLUDE 'PROTHEUS.CH'
#INCLUDE 'FWMVCDEF.CH'
#INCLUDE "PARMTYPE.CH"

PUBLISH MODEL REST NAME FSMBASE source FSMA005 RESOURCE OBJECT FsmRestModel
Static Function ModelDef()
Local oModel	    := Nil
Local oStruAA3	    := FWFormStruct(1,"AA3")
Local oStruAA4	    := FwFormStruct(1,'AA4')
Local oStruJNH	    := FwFormStruct(1,'JNH')
Local oStruJO9	    := FwFormStruct(1,'JO9')
Local oModelEvent   := FSM005Event():New()	


Local bInit         := {|oMdl,cField,uVal,nLine,uOldValue| FieldInit(oMdl,cField,uVal,nLine,uOldValue)}

oStruAA3:AddField("Nome Fornecedor","Nome Fornecedor","AA3_NOMFOR","C",TamSx3('A2_NOME')[1],0,{|| .T.},{|| .T.},{},.F.,NIL,.F.,.F.,.T.)						
oStruAA3:AddField("Nome Fabricante","Nome Fabricante","AA3_NOMFAB","C",TamSx3('A1_NOME')[1],0,{|| .T.},{|| .T.},{},.F.,NIL,.F.,.F.,.T.)	
oStruAA3:AddField("Documento","Documento","AA3_NUMDOC","C",TamSx3('A1_CGC')[1],0,{|| .T.},{|| .T.},{},.F.,NIL,.F.,.F.,.T.)		
oStruAA3:AddField("Contato"  ,"Contato"  ,"AA3_CONTAT","C",TamSx3('A1_CONTATO')[1],0,{|| .T.},{|| .T.},{},.F.,NIL,.F.,.F.,.T.)		
oStruAA3:AddField("Nome"     ,"Nome"     ,"AA3_NOME","C",TamSx3('A1_NOME')[1],0,{|| .T.},{|| .T.},{},.F.,NIL,.F.,.F.,.T.)	
oStruAA3:AddField("Nome Fantasia" ,"Nome Fantasia" ,"AA3_FANTAS","C",TamSx3('A1_NREDUZ')[1],0,{|| .T.},{|| .T.},{},.F.,NIL,.F.,.F.,.T.)	
oStruAA3:AddField("Cidade"   ,"Cidade"   ,"AA3_CIDADE","C",TamSx3('A1_MUN')[1],0,{|| .T.},{|| .T.},{},.F.,NIL,.F.,.F.,.T.)	
oStruAA3:AddField("Estado"   ,"Estado"   ,"AA3_ESTADO","C",TamSx3('A1_EST')[1],0,{|| .T.},{|| .T.},{},.F.,NIL,.F.,.F.,.T.)	
oStruAA3:AddField("E-mail"   ,"E-mail"   ,"AA3_EMAIL","C",TamSx3('A1_EMAIL')[1],0,{|| .T.},{|| .T.},{},.F.,NIL,.F.,.F.,.T.)	
oStruAA3:AddField("Telefone" ,"Telefone" ,"AA3_TELEFO","C",TamSx3('A1_EMAIL')[1],0,{|| .T.},{|| .T.},{},.F.,NIL,.F.,.F.,.T.)	
oStruAA3:AddField("Cliente Atu.","Cliente Atu.","AA3_CLIATU","C",TamSx3('A1_COD')[1],0,{|| .T.},{|| .T.},{},.F.,NIL,.F.,.F.,.T.)						
oStruAA3:AddField("Loja Atu.","Loja Atu.","AA3_LOJATU","C",TamSx3('A1_LOJA')[1],0,{|| .T.},{|| .T.},{},.F.,NIL,.F.,.F.,.T.)	
oStruAA4:AddField("Nome Fornecedor","Nome Fornecedor","AA4_NOMFOR","C",TamSx3('A2_NOME')[1],0,{|| .T.},{|| .T.},{},.F.,NIL,.F.,.F.,.T.)						
oStruAA4:AddField("Nome Fabricante","Nome Fabricante","AA4_NOMFAB","C",TamSx3('A1_NOME')[1],0,{|| .T.},{|| .T.},{},.F.,NIL,.F.,.F.,.T.)		
oStruJNH:AddField("Descr. Checlist","Descr. Checlist","JNH_DSCCHK","C",TamSx3('JND_TITULO')[1],0,{|| .T.},{|| .T.},{},.F.,NIL,.F.,.F.,.T.)	
oStruJNH:AddField("Cod. Serviço","Cod. Serviço","JNH_CODJN1","C",TamSx3('JN1_CODIGO')[1],0,{|| .T.},{|| .T.},{},.F.,NIL,.F.,.F.,.T.)	
oStruJNH:AddField("Descr. Serviço","Descr. Serviço","JNH_DSCJN1","C",TamSx3('JN1_DESCRI')[1],0,{|| .T.},{|| .T.},{},.F.,bInit,.F.,.F.,.T.)	

oModel := MPFormModel():New('FSMA005', /*bPreValid*/, /*bPosValid*/, /*bCommit*/, /*bCancel*/)

oModel:AddFields('AA3MASTER',/*cOwner*/,oStruAA3)
oModel:AddGrid('AA4DETAIL','AA3MASTER',oStruAA4, /*bLinePre*/, /*blinePost*/, /*bPre*/, /*bPost*/, /*bLoad*/ )
oModel:AddGrid('JNHDETAIL','AA3MASTER',oStruJNH, /*bLinePre*/, /*blinePost*/, /*bPre*/, /*bPost*/, /*bLoad*/ )
oModel:AddGrid('JO9DETAIL','AA3MASTER',oStruJO9, /*bLinePre*/, /*blinePost*/, /*bPre*/, /*bPost*/, /*bLoad*/ )

oModel:SetRelation('AA4DETAIL', {{'AA4_FILIAL', 'xFilial("AA4")'},;
                                 {'AA4_CODCLI', 'AA3_CODCLI'},;
                                 {'AA4_LOJA', 'AA3_LOJA'},;
                                 {'AA4_CODPRO', 'AA3_CODPRO'},;
                                 {'AA4_NUMSER', 'AA3_NUMSER'}},;
                                 AA4->(IndexKey(1)))

oModel:SetRelation('JNHDETAIL', {{'JNH_FILIAL', 'xFilial("JNH")'},;
                                 {'JNH_CODCLI', 'AA3_CODCLI'},;
                                 {'JNH_LOJCLI', 'AA3_LOJA'},;
                                 {'JNH_CODPRO', 'AA3_CODPRO'},;
                                 {'JNH_NUMSER', 'AA3_NUMSER'}},;
                                 JNH->(IndexKey(1)))

oModel:SetRelation('JO9DETAIL', {{'JO9_FILIAL', 'xFilial("JO9")'},;
                                 {'JO9_CODPRO', 'AA3_CODPRO'},;
                                 {'JO9_NUMSER', 'AA3_NUMSER'}},;
                                 JO9->(IndexKey(1)))

oModel:SetDescription('Base de Atendimento')
oModel:GetModel('AA3MASTER'):SetDescription("Base de Atendimento")

oStruAA3:SetProperty("AA3_OBS",MODEL_FIELD_INIT,FwBuildFeature(STRUCT_FEATURE_INIPAD,''))

oStruAA3:SetProperty("AA3_NOMFAB",MODEL_FIELD_INIT,;
                     FwBuildFeature(STRUCT_FEATURE_INIPAD,'If(!INCLUI,Posicione("SA1",1,xFilial("SA1")+AA3->AA3_CODFAB+AA3->AA3_LOJAFA,"A1_NOME"),"")'))

oStruAA3:SetProperty("AA3_NOMFOR",MODEL_FIELD_INIT,;
                     FwBuildFeature(STRUCT_FEATURE_INIPAD,'If(!INCLUI,Posicione("SA2",1,xFilial("SA2")+AA3->AA3_FORNEC+AA3->AA3_LOJAFO,"A2_NOME"),"")'))

oStruAA3:SetProperty("AA3_NOMFOR",MODEL_FIELD_INIT,;
                     FwBuildFeature(STRUCT_FEATURE_INIPAD,'If(!INCLUI,Posicione("SA2",1,xFilial("SA2")+AA3->AA3_FORNEC+AA3->AA3_LOJAFO,"A2_NOME"),"")'))
oStruAA4:SetProperty("AA4_NOMFOR",MODEL_FIELD_INIT,;
                     FwBuildFeature(STRUCT_FEATURE_INIPAD,'If(!INCLUI,Posicione("SA2",1,xFilial("SA2")+AA4->AA4_FORNEC+AA4->AA4_LOJAFO,"A2_NOME"),"")'))

oStruAA4:SetProperty("AA4_NOMFAB",MODEL_FIELD_INIT,;
                     FwBuildFeature(STRUCT_FEATURE_INIPAD,'If(!INCLUI,Posicione("SA1",1,xFilial("SA1")+AA4->AA4_CODFAB+AA4->AA4_LOJAFA,"A1_NOME"),"")'))

oStruAA3:SetProperty("AA3_NUMDOC",MODEL_FIELD_INIT,;
                     FwBuildFeature(STRUCT_FEATURE_INIPAD,'If(!INCLUI,Posicione("SA1",1,xFilial("SA1")+AA3->AA3_CODCLI+AA3->AA3_LOJA,"A1_CGC"),"")'))
                     
oStruAA3:SetProperty("AA3_CONTAT",MODEL_FIELD_INIT,;
                     FwBuildFeature(STRUCT_FEATURE_INIPAD,'If(!INCLUI,Posicione("SA1",1,xFilial("SA1")+AA3->AA3_CODCLI+AA3->AA3_LOJA,"A1_CONTATO"),"")'))

oStruAA3:SetProperty("AA3_NOME",MODEL_FIELD_INIT,;
                     FwBuildFeature(STRUCT_FEATURE_INIPAD,'If(!INCLUI,Posicione("SA1",1,xFilial("SA1")+AA3->AA3_CODCLI+AA3->AA3_LOJA,"A1_NOME"),"")'))
                     
oStruAA3:SetProperty("AA3_FANTAS",MODEL_FIELD_INIT,;
                     FwBuildFeature(STRUCT_FEATURE_INIPAD,'If(!INCLUI,Posicione("SA1",1,xFilial("SA1")+AA3->AA3_CODCLI+AA3->AA3_LOJA,"A1_NREDUZ"),"")'))

oStruAA3:SetProperty("AA3_CIDADE",MODEL_FIELD_INIT,;
                     FwBuildFeature(STRUCT_FEATURE_INIPAD,'If(!INCLUI,Posicione("SA1",1,xFilial("SA1")+AA3->AA3_CODCLI+AA3->AA3_LOJA,"A1_COD_MUN"),"")'))
                     
oStruAA3:SetProperty("AA3_ESTADO",MODEL_FIELD_INIT,;
                     FwBuildFeature(STRUCT_FEATURE_INIPAD,'If(!INCLUI,Posicione("SA1",1,xFilial("SA1")+AA3->AA3_CODCLI+AA3->AA3_LOJA,"A1_EST"),"")'))

oStruAA3:SetProperty("AA3_EMAIL",MODEL_FIELD_INIT,;
                     FwBuildFeature(STRUCT_FEATURE_INIPAD,'If(!INCLUI,Posicione("SA1",1,xFilial("SA1")+AA3->AA3_CODCLI+AA3->AA3_LOJA,"A1_EMAIL"),"")'))
                     
oStruAA3:SetProperty("AA3_TELEFO",MODEL_FIELD_INIT,;
                     FwBuildFeature(STRUCT_FEATURE_INIPAD,'If(!INCLUI,Posicione("SA1",1,xFilial("SA1")+AA3->AA3_CODCLI+AA3->AA3_LOJA,"A1_TEL"),"")'))
                    
oStruAA4:SetProperty("AA4_DESCPR",MODEL_FIELD_INIT,FwBuildFeature(STRUCT_FEATURE_INIPAD,'If(!INCLUI,Posicione("SB1",1,xFilial("SB1")+AA4->AA4_PRODAC,"B1_DESC"),"")'))

oStruAA4:SetProperty("AA4_FORNEC",MODEL_FIELD_VALID,FwBuildFeature(STRUCT_FEATURE_VALID,''))
oStruAA4:SetProperty("AA4_LOJAFO",MODEL_FIELD_VALID,FwBuildFeature(STRUCT_FEATURE_VALID,''))
oStruAA4:SetProperty("AA4_CODFAB",MODEL_FIELD_VALID,FwBuildFeature(STRUCT_FEATURE_VALID,''))
oStruAA4:SetProperty("AA4_LOJAFA",MODEL_FIELD_VALID,FwBuildFeature(STRUCT_FEATURE_VALID,''))
oStruAA4:SetProperty("AA4_NSERAC",MODEL_FIELD_VALID,FwBuildFeature(STRUCT_FEATURE_VALID,''))

oStruJNH:SetProperty("JNH_DSCCHK",MODEL_FIELD_INIT,FwBuildFeature(STRUCT_FEATURE_INIPAD,'If(!INCLUI,Posicione("JND",1,xFilial("JND")+JNH->JNH_CODJND,"JND_TITULO"),"")'))
oStruJNH:SetProperty("JNH_CODJN1",MODEL_FIELD_INIT,FwBuildFeature(STRUCT_FEATURE_INIPAD,'If(!INCLUI,Posicione("JND",1,xFilial("JND")+JNH->JNH_CODJND,"JND_TPSERV"),"")'))

oStruJO9:SetProperty("JO9_CODIGO",MODEL_FIELD_INIT,FwBuildFeature(STRUCT_FEATURE_INIPAD, 'GetSxEnum("JO9","JO9_CODIGO")'))

oModel:SetPrimaryKey({"AA3_CODCLI","AA3_LOJA","AA3_CODPRO","AA3_NUMSER"})

oModel:GetModel("AA4DETAIL"):SetOptional(.T.)
oModel:GetModel("JNHDETAIL"):SetOptional(.T.)
oModel:GetModel("JO9DETAIL"):SetOptional(.T.)

oModel:InstallEvent("FSM005Event", /*cOwner*/, oModelEvent)


Return oModel

Static Function FieldInit(oMdl,cField,uVal,nLine,uOldValue)
Local uRet      := ''

    Do Case
        Case cField == 'JNH_DSCJN1'

        uRet := RetDescSrv(JNH->JNH_CODJND)
        
    EndCase 
    
Return uRet

Class FSM005Event FROM FwModelEvent
	Method New()
    Method ModelPosVld()
    Method BeforeTTS()
End Class

Method New() Class FSM005Event

Return

Method ModelPosVld(oModel, cModelId) Class FSM005Event
Local lRet      := .T.
Local cCliAtu   := oModel:GetValue('AA3MASTER','AA3_CLIATU')
Local cLojaAtu  := oModel:GetValue('AA3MASTER','AA3_LOJATU')
    
    If !Empty(cCliAtu)
        oModel:LoadValue('AA3MASTER','AA3_CODCLI', cCliAtu)
        oModel:LoadValue('AA3MASTER','AA3_LOJA', cLojaAtu)
        
        oModel:LoadValue('JO9DETAIL','JO9_USURES', __cUserId)
        oModel:LoadValue('JO9DETAIL','JO9_DTTRAN', dDataBase)
        oModel:LoadValue('JO9DETAIL','JO9_HRTRAN', SubStr(Time(),1,5))
    Endif 
   
Return lRet

Method BeforeTTS(oModel, cModelId) Class FSM005Event

Return 

Static Function RetDescSrv(cCodigoJND) 
Local cAliasTmp := GetNextAlias()
Local cQuery    := ''
Local oQryTmp   := Nil
Local cDescrSrv := ''

Default cCodigoJND := ''

cQuery += " SELECT JN1.JN1_DESCRI FROM " + RetSqlName('JND') + " JND 
cQuery += "   INNER JOIN " + RetSqlName('JN1') + " JN1 ON JN1.JN1_FILIAL = ? " 
cQuery += "   AND JN1.JN1_CODIGO = JND.JND_TPSERV "
cQuery += "   AND JN1.D_E_L_E_T_ = ' ' "
cQuery += " WHERE "
cQuery += "   JND.JND_FILIAL = ? " 
cQuery += "   AND JND.JND_CODIGO = ? " 
cQuery += "   AND JND.JND_VERSAO = ( "
cQuery += "     SELECT MAX(JND_VERSAO) FROM " + RetSqlName('JND') + " " 
cQuery += "     WHERE "
cQuery += "       JND_FILIAL = ? "
cQuery += "       AND JND_CODIGO = JND.JND_CODIGO "
cQuery += "       AND JND_STATUS IN ('2', '3') "
cQuery += "       AND D_E_L_E_T_ = ' ' "
cQuery += "   ) "
cQuery += "   AND JND.D_E_L_E_T_ = ' ' "

oQryTmp := FwPreparedStatement():New(cQuery)

oQryTmp:SetString(1, xFilial("JN1"))
oQryTmp:SetString(2, xFilial("JND"))
oQryTmp:SetString(3, cCodigoJND)
oQryTmp:SetString(4, xFilial("JND"))

cQuery    := oQryTmp:GetFixQuery()
cAliasTmp := MpSysOpenQuery(cQuery)

cDescrSrv := (cAliasTmp)->JN1_DESCRI

Return cDescrSrv
