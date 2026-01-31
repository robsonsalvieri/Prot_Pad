#INCLUDE 'PROTHEUS.CH'
#INCLUDE 'FWMVCDEF.CH'

PUBLISH MODEL REST NAME FSMLANCDESPESA source FSMA042 RESOURCE OBJECT FsmRestModel

Static Function ModelDef()

    Local oModel   as object
    Local oStruJOF as object
    Local oStruJO0 as object
    Local oCommit  as object

    oModel   := Nil
    oStruJOF := FWFormStruct(1, "JOF")
    oStruJOH := FWFormStruct(1, "JOH")
    oStruJO0 := FWFormStruct(1, "JO0")
    oCommit  := FSM042COMMIT():New()

    oModel := MPFormModel():New('FSMA042', /*bPreValid*/, /*bPosValid*/,, /*bCancel*/)
    oModel:AddFields('JOFMASTER',/*cOwner*/,oStruJOF)
    oModel:AddGrid('JOHDETAIL', 'JOFMASTER', oStruJOH)
    oModel:AddGrid('JO0DETAIL', 'JOFMASTER', oStruJO0)

    oModel:SetRelation('JOHDETAIL', {{'JOH_FILIAL', 'xFilial("JOH")'}, {'JOH_CODJOF', 'JOF_CODIGO' }}, JOH->(IndexKey(1)))
    oModel:SetRelation('JO0DETAIL', {{'JO0_FILIAL', 'xFilial("JO0")'}, {'JO0_CODORI', 'JOF_CODIGO' }}, JO0->(IndexKey(1)))

    oModel:GetModel('JOFMASTER'):SetDescription("Lançamento de despesa")

    oModel:SetDescription("Lançamento de despesa")

    oModel:GetModel("JOHDETAIL"):SetOptional(.T.)   
    oModel:GetModel("JO0DETAIL"):SetOptional(.T.)   

    oModel:InstallEvent("FSM042COMMIT", /*cOwner*/, oCommit)

Return oModel

Class FSM042COMMIT FROM FwModelEvent
	Method New()
	Method BeforeTTS()
End Class

Method New() Class FSM042COMMIT
Return

Method BeforeTTS(oSubModel, cModelId) Class FSM042COMMIT
	ModelCommit(oSubModel:GetModel())
Return

Static Function ModelCommit(oModel)

    Local oModelJO0 as object
    Local oFWriter  as object
    Local cPath     as character
    Local cFileName as character
    Local nX        as numeric

    oModelJO0 := oModel:GetModel( 'JO0DETAIL' )
    oFWriter  := Nil
    cPath     := '\FSM\LANCADESPESA\'
    cFileName := ''
    nX        := 0

    For nX := 1 To oModelJO0:Length()
        oModelJO0:GoLine(nX)

        If oModelJO0:IsInserted(nX)

            If !ExistDir(cPath)
                FwMakeDir(cPath)
            EndIf

            If !Empty(oModelJO0:GetValue('JO0_MIDIA'))
                cFile := Decode64(oModelJO0:GetValue('JO0_MIDIA'))
                cFileName := FWUUID(oModelJO0:GetValue('JO0_CODIGO')) + oModelJO0:GetValue('JO0_EXTARQ')

                oFWriter := FwFileWriter():New(cPath + cFileName, .T.)

                If oFWriter:Create()
                    oFWriter:Write(cFile)
                EndIf	

                lOk := oFWriter:Exists()
                oFWriter:Close()
                FreeObj(oFWriter)

                oModelJO0:ClearField('JO0_MIDIA')
                oModelJO0:LoadValue('JO0_NOMARQ', cFileName)
            EndIf
        
        EndIf

        If oModelJO0:IsDeleted(nX)
            FErase(cPath + oModelJO0:GetValue('JO0_NOMARQ'))
        EndIf
        
    Next

Return
