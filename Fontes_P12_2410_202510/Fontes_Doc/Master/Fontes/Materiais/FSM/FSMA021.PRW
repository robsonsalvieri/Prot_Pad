#INCLUDE 'PROTHEUS.CH'
#INCLUDE 'FWMVCDEF.CH'
#INCLUDE "PARMTYPE.CH"

PUBLISH MODEL REST NAME FSMFORMULARIO source FSMA021 RESOURCE OBJECT FsmRestModel

Static Function ModelDef()
Local oModel	:= Nil
Local oStrJNN   := FWFormStruct(1,"JNN")
Local oStrJNO   := FWFormStruct(1,"JNO")
Local oStrJNP	:= FWFormStruct(1,"JNP")
Local oStrJNQ	:= FWFormStruct(1,"JNQ")
Local oStrJNX	:= FWFormStruct(1,"JNX")
Local bInit     := {|oMdl,cField,uVal,nLine,uOldValue| FieldInit(oMdl,cField,uVal,nLine,uOldValue)}
Local bCommit   := { || FSMA021Cmt(oModel) }

oModel := MPFormModel():New('FSMA021', /*bPreValid*/, /*bPosValid*/, bCommit, /*bCancel*/)

oStrJNN:AddField("Título Check.","Título Check.","JNN_TITULO","C",TamSx3('JND_TITULO')[1],0,{|| .T.},{|| .T.},{},.F.,bInit,.F.,.F.,.T.)						
oStrJNN:AddField("Tipo Serv.","Tipo Serv.","JNN_TPSERV","C",TamSx3('JND_TPSERV')[1],0,{|| .T.},{|| .T.},{},.F.,/*bInit*/,.F.,.F.,.T.)						
oStrJNN:AddField("Descricao","Descricao","JNN_DESCRI","M",TamSx3('JND_DESCRI')[1],0,{|| .T.},{|| .T.},{},.F.,/*bInit*/,.F.,.F.,.T.)						
oStrJNO:AddField("Descr.Passo","Descr Passo","JNO_DESCRI","M",TamSx3('JNE_DESCRI')[1],0,{|| .T.},{|| .T.},{},.F.,/*bInit*/,.F.,.F.,.T.)						
oStrJNP:AddField("Tipo Item","Tipo Item","JNP_TPITEM","C",TamSx3('JNF_TPITEM')[1],0,{|| .T.},{|| .T.},{},.F.,/*bInit*/,.F.,.F.,.T.)						
oStrJNP:AddField("Pergunta","Pergunta","JNP_PERGUN","C",TamSx3('JNF_PERGUN')[1],0,{|| .T.},{|| .T.},{},.F.,/*bInit*/,.F.,.F.,.T.)						
oStrJNP:AddField("Frase","Frase","JNP_FRASE","C",TamSx3('JNF_FRASE')[1],0,{|| .T.},{|| .T.},{},.F.,/*bInit*/,.F.,.F.,.T.)						
oStrJNP:AddField("Obrigatorio","Obrigatorio","JNP_OBRIGA","C",TamSx3('JNF_OBRIGA')[1],0,{|| .T.},{|| .T.},{},.F.,/*bInit*/,.F.,.F.,.T.)						
oStrJNP:AddField("Perm. Observ.","Perm. Observ.","JNP_PEROBS","C",TamSx3('JNF_PEROBS')[1],0,{|| .T.},{|| .T.},{},.F.,/*bInit*/,.F.,.F.,.T.)						
oStrJNP:AddField("Perm. Eviden.","Perm. Eviden.","JNP_PEREVD","C",TamSx3('JNF_PEREVD')[1],0,{|| .T.},{|| .T.},{},.F.,/*bInit*/,.F.,.F.,.T.)						
oStrJNP:AddField("Desvio Pos.","Desvio Pos.","JNP_DESVPO","C",TamSx3('JNF_DESVPO')[1],0,{|| .T.},{|| .T.},{},.F.,/*bInit*/,.F.,.F.,.T.)						
oStrJNP:AddField("Critic. Pos.","Critic. Pos.","JNP_CRITPO","C",TamSx3('JNF_CRITPO')[1],0,{|| .T.},{|| .T.},{},.F.,/*bInit*/,.F.,.F.,.T.)						
oStrJNP:AddField("Desvio Neg.","Desvio Neg.","JNP_DESVNE","C",TamSx3('JNF_DESVNE')[1],0,{|| .T.},{|| .T.},{},.F.,/*bInit*/,.F.,.F.,.T.)						
oStrJNP:AddField("Critic. Neg.","Critic. Neg.","JNP_CRITNE","C",TamSx3('JNF_CRITNE')[1],0,{|| .T.},{|| .T.},{},.F.,/*bInit*/,.F.,.F.,.T.)						
oStrJNP:AddField("Minimo Midia","Minimo Midia","JNP_MIDMIN","C",TamSx3('JNF_CRITNE')[1],0,{|| .T.},{|| .T.},{},.F.,/*bInit*/,.F.,.F.,.T.)						
oStrJNP:AddField("Máximo Midia","Máximo Midia","JNP_MAXMID","C",TamSx3('JNF_MAXMID')[1],0,{|| .T.},{|| .T.},{},.F.,/*bInit*/,.F.,.F.,.T.)						
oStrJNQ:AddField("Opção Resp.","Opção Resp.","JNQ_OPCRES","C",TamSx3('JNG_OPCRES')[1],0,{|| .T.},{|| .T.},{},.F.,/*bInit*/,.F.,.F.,.T.)						
oStrJNQ:AddField("Criticidade","Criticidade","JNQ_CRITIC","C",TamSx3('JNG_CRITIC')[1],0,{|| .T.},{|| .T.},{},.F.,/*bInit*/,.F.,.F.,.T.)						
oStrJNQ:AddField("Desvio","Desvio","JNQ_DESVIO","C",TamSx3('JNG_DESVIO')[1],0,{|| .T.},{|| .T.},{},.F.,/*bInit*/,.F.,.F.,.T.)						

oStrJNO:SetProperty("JNO_DESCRI",MODEL_FIELD_INIT,;
                     FwBuildFeature(STRUCT_FEATURE_INIPAD,'If(!INCLUI,Posicione("JNE",1,xFilial("JNE")+JNO->JNO_CODJNE,"JNE_DESCRI"),"")'))
oStrJNP:SetProperty("JNP_TPITEM",MODEL_FIELD_INIT,;
                     FwBuildFeature(STRUCT_FEATURE_INIPAD,'If(!INCLUI,Posicione("JNF",1,xFilial("JNF")+JNP->JNP_CODJNF,"JNF_TPITEM"),"")'))
oStrJNP:SetProperty("JNP_PERGUN",MODEL_FIELD_INIT,;
                     FwBuildFeature(STRUCT_FEATURE_INIPAD,'If(!INCLUI,Posicione("JNF",1,xFilial("JNF")+JNP->JNP_CODJNF,"JNF_PERGUN"),"")'))
oStrJNP:SetProperty("JNP_FRASE",MODEL_FIELD_INIT,;
                     FwBuildFeature(STRUCT_FEATURE_INIPAD,'If(!INCLUI,Posicione("JNF",1,xFilial("JNF")+JNP->JNP_CODJNF,"JNF_FRASE"),"")'))
oStrJNP:SetProperty("JNP_OBRIGA",MODEL_FIELD_INIT,;
                     FwBuildFeature(STRUCT_FEATURE_INIPAD,'If(!INCLUI,Posicione("JNF",1,xFilial("JNF")+JNP->JNP_CODJNF,"JNF_OBRIGA"),"")'))
oStrJNP:SetProperty("JNP_PEROBS",MODEL_FIELD_INIT,;
                     FwBuildFeature(STRUCT_FEATURE_INIPAD,'If(!INCLUI,Posicione("JNF",1,xFilial("JNF")+JNP->JNP_CODJNF,"JNF_PEROBS"),"")'))
oStrJNP:SetProperty("JNP_PEREVD",MODEL_FIELD_INIT,;
                     FwBuildFeature(STRUCT_FEATURE_INIPAD,'If(!INCLUI,Posicione("JNF",1,xFilial("JNF")+JNP->JNP_CODJNF,"JNF_PEREVD"),"")'))
oStrJNP:SetProperty("JNP_DESVPO",MODEL_FIELD_INIT,;
                     FwBuildFeature(STRUCT_FEATURE_INIPAD, 'If(!INCLUI,Posicione("JNF",1,xFilial("JNF")+JNP->JNP_CODJNF,"JNF_DESVPO"),"")'))
oStrJNP:SetProperty("JNP_CRITPO",MODEL_FIELD_INIT,;
                     FwBuildFeature(STRUCT_FEATURE_INIPAD, 'If(!INCLUI,Posicione("JNF",1,xFilial("JNF")+JNP->JNP_CODJNF,"JNF_CRITPO"),"")'))
oStrJNP:SetProperty("JNP_DESVNE",MODEL_FIELD_INIT,;
                     FwBuildFeature(STRUCT_FEATURE_INIPAD, 'If(!INCLUI,Posicione("JNF",1,xFilial("JNF")+JNP->JNP_CODJNF,"JNF_DESVNE"),"")'))
oStrJNP:SetProperty("JNP_CRITNE",MODEL_FIELD_INIT,;
                     FwBuildFeature(STRUCT_FEATURE_INIPAD, 'If(!INCLUI,Posicione("JNF",1,xFilial("JNF")+JNP->JNP_CODJNF,"JNF_CRITNE"),"")'))
oStrJNP:SetProperty("JNP_MIDMIN",MODEL_FIELD_INIT,;
                     FwBuildFeature(STRUCT_FEATURE_INIPAD, 'If(!INCLUI,Posicione("JNF",1,xFilial("JNF")+JNP->JNP_CODJNF,"JNF_MIDMIN"),"")'))
oStrJNP:SetProperty("JNP_MAXMID",MODEL_FIELD_INIT,;
                     FwBuildFeature(STRUCT_FEATURE_INIPAD, 'If(!INCLUI,Posicione("JNF",1,xFilial("JNF")+JNP->JNP_CODJNF,"JNF_MAXMID"),"")'))
oStrJNQ:SetProperty("JNQ_OPCRES",MODEL_FIELD_INIT,;
                     FwBuildFeature(STRUCT_FEATURE_INIPAD, 'If(!INCLUI,Posicione("JNG",1,xFilial("JNG")+JNQ->JNQ_CODJNG,"JNG_OPCRES"),"")'))
oStrJNQ:SetProperty("JNQ_CRITIC",MODEL_FIELD_INIT,;
                     FwBuildFeature(STRUCT_FEATURE_INIPAD, 'If(!INCLUI,Posicione("JNG",1,xFilial("JNG")+JNQ->JNQ_CODJNG,"JNG_CRITIC"),"")'))
oStrJNQ:SetProperty("JNQ_DESVIO",MODEL_FIELD_INIT,;
                     FwBuildFeature(STRUCT_FEATURE_INIPAD, 'If(!INCLUI,Posicione("JNG",1,xFilial("JNG")+JNQ->JNQ_CODJNG,"JNG_DESVIO"),"")'))

oModel:AddFields('JNNMASTER',/*cOwner*/,oStrJNN)
oModel:AddGrid('JNODETAIL', 'JNNMASTER', oStrJNO)
oModel:AddGrid('JNPDETAIL', 'JNODETAIL', oStrJNP)
oModel:AddGrid('JNQDETAIL', 'JNPDETAIL', oStrJNQ)
oModel:AddGrid('JNXDETAIL', 'JNPDETAIL', oStrJNX)

oModel:SetRelation('JNODETAIL', {{'JNO_FILIAL', 'xFilial("JNO")'},;
                                 {'JNO_CODJNN', 'JNN_CODIGO'}},;
                                 JNO->(IndexKey(2)))

oModel:SetRelation('JNPDETAIL', {{'JNP_FILIAL', 'xFilial("JNP")'},;
                                 {'JNP_CODJNO', 'JNO_CODIGO'}},;
                                 JNP->(IndexKey(2)))

oModel:SetRelation('JNQDETAIL', {{'JNQ_FILIAL', 'xFilial("JNQ")'},;
                                 {'JNQ_CODJNP', 'JNP_CODIGO'}},;
                                 JNQ->(IndexKey(2)))

oModel:SetRelation('JNXDETAIL', {{'JNX_FILIAL', 'xFilial("JNX")'},;
                                 {'JNX_CODJNP', 'JNP_CODIGO'}},;
                                 JNX->(IndexKey(2)))


oModel:SetPrimaryKey({"JNN_CODIGO"})

oModel:SetDescription('Formulário do Checklist')
oModel:GetModel('JNNMASTER'):SetDescription("Formulário do Checklist")

oModel:GetModel("JNQDETAIL"):SetOptional(.T.)
oModel:GetModel("JNXDETAIL"):SetOptional(.T.)

Return oModel

Static Function FieldInit(oMdl,cField,uVal,nLine,uOldValue)
Local uRet := ''

    Do Case
        Case cField == 'JNN_TITULO'

            JND->(dbSetOrder(1))
            
            If JND->(dbSeek(xFilial('JND')+oMdl:GetValue('JNN_CODJND')+oMdl:GetValue('JNN_VERSAO')))
                uRet := JND->JND_TITULO
                oMdl:LoadValue('JNN_TPSERV', JND->JND_TPSERV)
                oMdl:LoadValue('JNN_DESCRI', JND->JND_DESCRI)
            Endif

    EndCase 

Return uRet

Function FSMA021Cmt(oModel)
Local nX        := 0
Local nY        := 0
Local nZ        := 0
Local lRet      := .T.
Local cFile     := ''
Local cRootpath := GetSrvProfString("ROOTPATH","")
Local cPath     := '\FSM\IMAGES\' //GetSrvProfString("Rootpath","") + '\fsm\images'
Local oFWriter
Local cFileName := ""

If !ExistDir(cPath)
    FwMakeDir(cPath)
EndIf 

    Begin Transaction

        if oModel:GetOperation() == MODEL_OPERATION_UPDATE

            For nX := 1 TO oModel:GetModel('JNODETAIL'):Length()

                oModel:GetModel('JNODETAIL'):GoLine(nX)

                For nY := 1 To oModel:GetModel('JNPDETAIL'):Length()

                    oModel:GetModel('JNPDETAIL'):GoLine(nY)

                    For nZ := 1 To oModel:GetModel('JNXDETAIL'):Length()

                        oModel:GetModel('JNXDETAIL'):GoLine(nZ)

                        If !Empty(oModel:GetModel('JNXDETAIL'):GetValue('JNX_MIDIA'))
                            cFile := Decode64(oModel:GetModel('JNXDETAIL'):GetValue('JNX_MIDIA'))

                            cFileName := FWUUID(oModel:GetModel('JNXDETAIL'):GetValue('JNX_CODIGO')) + oModel:GetModel('JNXDETAIL'):GetValue('JNX_EXTARQ')

                            oFWriter := FwFileWriter():New(cPath + cFileName, .T.)

                            If oFWriter:Create()
                                oFWriter:Write(cFile)
                            EndIf	

                            lOk := oFWriter:Exists()
                            oFWriter:Close()
                            FreeObj(oFWriter)

                            oModel:GetModel('JNXDETAIL'):ClearField('JNX_MIDIA')
                            oModel:GetModel('JNXDETAIL'):LoadValue('JNX_NOMARQ', cFileName)

                        Endif
                    Next nZ

                Next nY
 
             Next nX 


        Endif    

    lRet := FWFormCommit( oModel )

    End Transaction
    


Return lRet

