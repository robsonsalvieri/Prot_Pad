#INCLUDE 'PROTHEUS.CH'
#INCLUDE 'FWMVCDEF.CH'
#INCLUDE "PARMTYPE.CH"

PUBLISH MODEL REST NAME FSMPARAMETRO source FSMA023 RESOURCE OBJECT FsmRestModel

//-------------------------------------------------------------------
/*/{Protheus.doc} ModelDef()
Modelo da tabela JNU - Parâmetros SIGAFSM
@author flavio.martins
@since 03/10/2024
@version 1.0
*/
//-------------------------------------------------------------------
Static Function ModelDef()

Local oModel	:= Nil
Local oStrJNU   := FWFormStruct(1,"JNU")
Local oCommit   := FSM023COMMIT():New()	

oStrJNU:AddField("Arquivo","Arquivo","JNU_ARQUIV","M",10,0,{|| .T.},{|| .T.},{},.F.,NIL,.F.,.F.,.T.)		
oStrJNU:AddField("Remover","Remover","JNU_REMARQ","M",10,0,{|| .T.},{|| .T.},{},.F.,NIL,.F.,.F.,.T.)

oModel := MPFormModel():New('FSMA023', /*bPreValid*/, /*bPosValid*/, /*bCommit*/, /*bCancel*/)

oModel:AddFields('JNUMASTER',/*cOwner*/,oStrJNU)

oModel:SetPrimaryKey({"JNU_CODPAR"})

oModel:SetDescription('Parâmetros - SIGAFSM')

oModel:GetModel('JNUMASTER'):SetDescription("Parâmetros - SIGAFSM")

oModel:InstallEvent("FSM023COMMIT", /*cOwner*/, oCommit)

Return oModel

Class FSM023COMMIT FROM FwModelEvent
	Method New()
	Method BeforeTTS()
End Class

Method New() Class FSM023COMMIT

Return

Method BeforeTTS(oSubModel, cModelId) Class FSM023COMMIT
	ModelCommit(oSubModel:GetModel())
Return


Static Function ModelCommit(oModel)
Local cPath     := '\FSM\ASSETS\' 
Local oFWriter
Local cFileName := ""

If !ExistDir(cPath)
    FwMakeDir(cPath)
EndIf 


If oModel:GetOperation() == MODEL_OPERATION_UPDATE .And. ALLTRIM(oModel:GetModel('JNUMASTER'):GetValue('JNU_CODPAR')) == "LOGO"
    If !Empty(oModel:GetModel('JNUMASTER'):GetValue('JNU_REMARQ'))
    
        FErase(cPath + oModel:GetModel('JNUMASTER'):GetValue('JNU_REMARQ'))    

    Else
        cFile := Decode64(oModel:GetModel('JNUMASTER'):GetValue('JNU_ARQUIV'))

        cFileName := oModel:GetModel('JNUMASTER'):GetValue('JNU_CONTEU')

        oFWriter := FwFileWriter():New(cPath + cFileName, .T.)

        If oFWriter:Create()
            oFWriter:Write(cFile)
        EndIf	

        lOk := oFWriter:Exists()
        oFWriter:Close()
        FreeObj(oFWriter)
    EndIf    

Endif

Return
