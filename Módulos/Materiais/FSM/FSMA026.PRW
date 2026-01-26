#INCLUDE 'PROTHEUS.CH'
#INCLUDE 'FWMVCDEF.CH'
#INCLUDE "PARMTYPE.CH"

PUBLISH MODEL REST NAME FSMMIDIA source FSMA026 RESOURCE OBJECT FsmRestModel

//-------------------------------------------------------------------
/*/{Protheus.doc} ModelDef()
Modelo da tabela JO0 - Midias SIGAFSM
@author flavio.martins
@since 10/01/2025
@version 1.0
*/
//-------------------------------------------------------------------
Static Function ModelDef()

Local oModel	:= Nil
Local oStrJO0   := FWFormStruct(1,"JO0")
Local bCommit   := { || FSMA026Cmt(oModel) }

oModel := MPFormModel():New('FSMA026', /*bPreValid*/, /*bPosValid*/, bCommit, /*bCancel*/)

oModel:AddFields('JO0MASTER',/*cOwner*/,oStrJO0)

oModel:SetPrimaryKey({"JO0_CODIGO"})

oModel:SetDescription('Midias - SIGAFSM')
oModel:GetModel('JO0MASTER'):SetDescription("Midias - SIGAFSM")

Return oModel

Function FSMA026Cmt(oModel)
Local lRet      := .T.
Local cFile     := ''
Local cPath     := '\FSM\IMAGES\ATENDIMENTO\' 
Local oFWriter
Local cFileName := ""

If !ExistDir(cPath)
    FwMakeDir(cPath)
EndIf 

    If oModel:GetOperation() == MODEL_OPERATION_INSERT

        If !Empty(oModel:GetModel('JO0MASTER'):GetValue('JO0_MIDIA'))
            cFile := Decode64(oModel:GetModel('JO0MASTER'):GetValue('JO0_MIDIA'))

            cFileName := FWUUID(oModel:GetModel('JO0MASTER'):GetValue('JO0_CODIGO')) + oModel:GetModel('JO0MASTER'):GetValue('JO0_EXTARQ')

            oFWriter := FwFileWriter():New(cPath + cFileName, .T.)

            If oFWriter:Create()
                oFWriter:Write(cFile)
            EndIf	

            lOk := oFWriter:Exists()
            oFWriter:Close()
            FreeObj(oFWriter)

            oModel:GetModel('JO0MASTER'):ClearField('JO0_MIDIA')
            oModel:GetModel('JO0MASTER'):LoadValue('JO0_NOMARQ', cFileName)

        Endif

    Endif    

    lRet := FWFormCommit( oModel )
    

Return lRet
