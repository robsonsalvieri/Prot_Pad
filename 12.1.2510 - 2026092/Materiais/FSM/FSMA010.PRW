#INCLUDE 'PROTHEUS.CH'
#INCLUDE 'FWMVCDEF.CH'

PUBLISH MODEL REST NAME FSMATENDENTES source FSMA010 RESOURCE OBJECT FsmRestModel

Static Function ModelDef()

Local oModel	:= Nil
Local oStruAA1	:= FwFormStruct(1, "AA1")
Local oStruJNI	:= FwFormStruct(1, "JNI")
Local oModelEvent   := FSM010Event():New()

oStruAA1:AddField("Descricao da funcao","Grupo","AA1_FUNDES","C",TamSx3('A1_NOME')[1],0,{|| .T.},{|| .T.},{},.F.,NIL,.F.,.F.,.T.)		
oStruJNI:AddField("Nome do atendente"  ,"Nome"  ,"JNI_NOMTEC","C",TamSx3('AA1_NOMTEC')[1],0,{|| .T.},{|| .T.},{},.F.,NIL,.F.,.F.,.T.)
oStruJNI:AddField("Funcao do atendente","Funcao","JNI_FUNCAO","C",TamSx3('AA1_FUNCAO')[1],0,{|| .T.},{|| .T.},{},.F.,NIL,.F.,.F.,.T.)

oModel := MPFormModel():New('FSMA010', /*bPreValid*/, /*bPosValid*/, /*bCommit*/, /*bCancel*/)

oModel:AddFields('AA1MASTER',/*cOwner*/, oStruAA1)
oModel:AddGrid( 'JNIDETAIL', 'AA1MASTER', oStruJNI)

oModel:SetDescription('Atendentes')
oModel:GetModel('AA1MASTER'):SetDescription("Atendentes")

oModel:SetRelation('JNIDETAIL', {{'JNI_FILIAL', 'xFilial("JNI")'},;
                                 {'JNI_CODSUP', 'AA1_CODTEC'}},;
                                 JNI->(IndexKey(1)))

oModel:GetModel("JNIDETAIL"):SetOptional(.T.)

oStruAA1:SetProperty( 'AA1_NOMTEC' , MODEL_FIELD_OBRIGAT, .F.)
oStruAA1:SetProperty( 'AA1_EMINFI' , MODEL_FIELD_OBRIGAT, .F.)
oStruAA1:SetProperty( 'AA1_FUNPRO' , MODEL_FIELD_OBRIGAT, .F.)
oStruAA1:SetProperty( 'AA1_LIBOSV' , MODEL_FIELD_OBRIGAT, .F.)
oStruAA1:SetProperty( 'AA1_REQPEC' , MODEL_FIELD_OBRIGAT, .F.)
oStruAA1:SetProperty( 'AA1_CODVEN' , MODEL_FIELD_OBRIGAT, .F.)
oStruAA1:SetProperty( 'AA1_NOMUSU' , MODEL_FIELD_OBRIGAT, .F.)

oStruAA1:SetProperty("AA1_FUNDES",MODEL_FIELD_INIT,;
                     FwBuildFeature(STRUCT_FEATURE_INIPAD,'Posicione("SRJ",1,xFilial("SRJ")+AA1->AA1_FUNCAO,"RJ_DESC")'))

oStruJNI:SetProperty("JNI_CODIGO",MODEL_FIELD_INIT,;
                     FwBuildFeature(STRUCT_FEATURE_INIPAD, 'GetSxEnum("JNI","JNI_CODIGO")'))

oStruJNI:SetProperty('JNI_CODIGO',MODEL_FIELD_OBRIGAT, .T.)

oStruJNI:SetProperty("JNI_NOMTEC",MODEL_FIELD_INIT,;
                     FwBuildFeature(STRUCT_FEATURE_INIPAD,'getPosicione("AA1_NOMTEC")'))

oStruJNI:SetProperty("JNI_FUNCAO",MODEL_FIELD_INIT,;
                     FwBuildFeature(STRUCT_FEATURE_INIPAD,'getPosicione("AA1_FUNCAO")'))

oModel:InstallEvent("FSM010Event", /*cOwner*/, oModelEvent)                     

Return oModel

Class FSM010Event FROM FwModelEvent
	Method New()
    Method ModelPosVld()
End Class

Method New() Class FSM010Event

Return

Method ModelPosVld(oModel, cModelId) Class FSM010Event
Local oModel    := FwModelActive()
Local nX        := 0
Local oMdJNI    := oModel:GetModel("JNIDETAIL")
Local lRet      := .T.

    Begin Transaction
        If oModel:nOperation = MODEL_OPERATION_UPDATE
            For nX := 1 TO oMdJNI:Length()
                oMdJNI:GoLine(nX)
                If AA1->(MsSeek(xFilial("AA1")+oModel:GetModel("JNIDETAIL"):GetValue("JNI_CODATD"))) .And. !oMdJNI:isDeleted()
                    AA1->(RecLock("AA1",.F.))
                        AA1->AA1_CODSUP := oModel:GetModel("AA1MASTER"):GetValue("AA1_CODTEC")
                    AA1->(MsUnLock())
                Elseif AA1->(MsSeek(xFilial("AA1")+oModel:GetModel("JNIDETAIL"):GetValue("JNI_CODATD")))
                    AA1->(RecLock("AA1",.F.))
                        AA1->AA1_CODSUP := ''
                    AA1->(MsUnLock())
                Endif
            Next nX    
        Endif    
    End Transaction

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} getPosicione

@author	Vitor Kwon
@since	22/07/2024
/*/
//-------------------------------------------------------------------

Function getPosicione(cCampo)

Local cRetorno
Local aAreaAA1  := AA1->( GetArea() )
 
    cRetorno := Posicione("AA1",1,xFilial("AA1")+JNI->JNI_CODATD,cCampo)
 
RestArea(aAreaAA1)


Return cRetorno
