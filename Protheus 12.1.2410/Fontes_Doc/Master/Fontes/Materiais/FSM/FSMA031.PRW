#INCLUDE 'PROTHEUS.CH'
#INCLUDE 'FWMVCDEF.CH'
#INCLUDE "PARMTYPE.CH"

PUBLISH MODEL REST NAME FSMPECAAPONTA source FSMA031 RESOURCE OBJECT FsmRestModel

Static Function ModelDef()

Local oModel        := Nil
Local oStruJO4      := FWFormStruct(1,"JO4")
Local oModelEvent   := FSM031Event():New()	

oStruJO4:AddField("Descr. Produto","Descr. Produto","JO4_DESPRO","C",TamSx3('B1_DESC')[1],0,{|| .T.},{|| .T.},{},.F.,NIL,.F.,.F.,.T.)	
                                                   
oModel := MPFormModel():New('FSMA031', /*bPreValid*/, /*bPosValid*/, /*bCommit*/, /*bCancel*/)

oStruJO4:SetProperty("JO4_DESPRO",MODEL_FIELD_INIT,;
                     FwBuildFeature(STRUCT_FEATURE_INIPAD,'If(!INCLUI,Posicione("SB1",1,xFilial("SB1")+JO4->JO4_CODPRO,"B1_DESC"),"")'))

oModel:AddFields('JO4MASTER',/*cOwner*/, oStruJO4)

oModel:SetPrimaryKey({"JO4_CODIGO"})

oModel:SetDescription('Cadastro de apontamento de peças')
oModel:GetModel('JO4MASTER'):SetDescription("Cadastro de apontamento de peças")

oModel:InstallEvent("FSM031Event", /*cOwner*/, oModelEvent)

Return oModel

Class FSM031Event FROM FwModelEvent
	Method New()
    Method ModelPosVld()
    Method BeforeTTS()
End Class

Method New() Class FSM031Event

Return

Method ModelPosVld(oModel, cModelId) Class FSM031Event
Local lRet      := .T.
Local cMsgErro  := ''
Local cTpAponta := oModel:GetValue('JO4MASTER','JO4_TPAPON')
    
    If (cTpAponta $ '05|06|07|08')
        lRet := InsertBase(oModel, @cMsgErro)

        If !(lRet)
           	oModel:SetErrorMessage('AA3MASTER', ,'AA3MASTER',, "InsertBase", cMsgErro, '') 
        Endif

    Endif

Return lRet

Method BeforeTTS(oModel, cModelId) Class FSM031Event

oModel:SetValue('JO4MASTER','JO4_DTAPON', dDataBase)
oModel:SetValue('JO4MASTER','JO4_HRAPON', Time())

Return 

Static Function InsertBase(oModel, cMsgErro)
Local lRet      := .T.
Local oMdlBase  := FwLoadModel('FSMA005')
Local cCliente  := ''
Local cLoja     := ''
Local cCodAtend := ''
Local cTpAponta := oModel:GetValue('JO4MASTER','JO4_TPAPON')
Local cStatus   := oModel:GetValue('JO4MASTER','JO4_STATUS')
Local cCodBase  := ''
Local cIdUnico  := ''

    Begin Transaction 

        dbSelectArea("JN6")
        JN6->(dbSetOrder(1))

        If JN6->(dbSeek(xFilial('JN6')+oModel:GetValue('JO4MASTER','JO4_CODJN6')))
            cCodAtend := JN6->JN6_CODAA1
            
            If JN3->(dbSeek(xFilial('JN3')+JN6->JN6_CODJN3))
                cCliente := JN3->JN3_CLIENT
                cLoja    := JN3->JN3_LOJA
            Endif

        Endif
        
        If ((cTpAponta $ '05|06') .Or. (cTpAponta $ '07|08' .And. cStatus == '2'))

            oMdlBase:SetOperation(MODEL_OPERATION_INSERT)
            oMdlBase:Activate()

            oMdlBase:SetValue('AA3MASTER','AA3_CODCLI', cCliente)
            oMdlBase:SetValue('AA3MASTER','AA3_LOJA', cLoja)
            oMdlBase:SetValue('AA3MASTER','AA3_CODPRO', oModel:GetValue('JO4MASTER', 'JO4_CODPRO'))
            oMdlBase:SetValue('AA3MASTER','AA3_NUMSER', oModel:GetValue('JO4MASTER', 'JO4_NUMSER'))
            oMdlBase:SetValue('AA3MASTER','AA3_DTINST', oModel:GetValue('JO4MASTER', 'JO4_DTINST'))
            oMdlBase:SetValue('AA3MASTER','AA3_DTGAR', oModel:GetValue('JO4MASTER', 'JO4_DTGARA'))
            oMdlBase:SetValue('AA3MASTER','AA3_CODTEC', cCodAtend)
            oMdlBase:SetValue('AA3MASTER','AA3_STSATD', '1')
            oMdlBase:SetValue('AA3MASTER','AA3_CODJN6', oModel:GetValue('JO4MASTER','JO4_CODJN6'))

        ElseIf (cTpAponta $ '07|08' .And. cStatus == '3')

            oMdlBase:SetOperation(MODEL_OPERATION_UPDATE)
            oMdlBase:Activate()

            cCodBase := oModel:GetValue('JO4MASTER','JO4_CODPRO')
            cIdUnico := oModel:GetValue('JO4MASTER','JO4_NUMSER')

            dbSelectArea("AA3")
            AA3->(dbSetOrder(1))

            If AA3->(dbSeek(xFilial('AA3')+cCliente+cLoja+cCodBase+cIdUnico))

                oMdlBase:SetValue('AA3MASTER','AA3_STSATD', '3')
                oMdlBase:SetValue('AA3MASTER','AA3_CODJN6', oModel:GetValue('JO4MASTER','JO4_CODJN6'))

            Endif

        Endif

        If oMdlBase:VldData() 
            oMdlBase:CommitData()
        Else
            DisarmTransaction()
            lRet := .F.
            cMsgErro := oMdlBase:GetErrorMessage()[6]
        Endif

    oMdlBase:DeActivate();
    
    End Transaction

Return lRet

Function FSM32OPCTA()
Local cCombo := ""
 
cCombo += "00=Sem Apontamento;"
cCombo += "01=Instalar Material;"
cCombo += "02=Instalar Material Avulso;"
cCombo += "03=Substituir Material;"
cCombo += "04=Substituir Material Avulso;"
cCombo += "05=Instalar Equipamento;"
cCombo += "06=Instalar Equipamento Avulso;"
cCombo += "07=Substituir Equipamento;"
cCombo += "08=Substituir Equipamento Avulso;"

Return cCombo

