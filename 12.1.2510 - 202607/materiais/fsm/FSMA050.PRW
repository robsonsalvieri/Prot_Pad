#INCLUDE 'PROTHEUS.CH'
#INCLUDE 'FWMVCDEF.CH'

PUBLISH MODEL REST NAME FSMTECNICOESTOQUE source FSMA050 RESOURCE OBJECT FsmRestModel

Static Function ModelDef()

    Local oModel   as object
    Local oStruJOI as object
    Local oModelEvent   := FSMA050Event():New()	

    oStruJOI := FWFormStruct(1, "JOI")

    oStruJOI:AddField("Armazem de Origem"  ,"Armazem de Origem"  ,"JOI_ARMORI","C",TamSx3('D3_LOCAL')[1],0,{|| .T.},{|| .T.},{},.F.,NIL,.F.,.F.,.T.)						
    oStruJOI:AddField("Armazem de Destino" ,"Armazem de Destino" ,"JOI_ARMDES","C",TamSx3('D3_LOCAL')[1],0,{|| .T.},{|| .T.},{},.F.,NIL,.F.,.F.,.T.)						
    oStruJOI:AddField("Endereço de Origem" ,"Endereço de Origem" ,"JOI_ENDORI","C",TamSx3('D3_LOCALIZ')[1],0,{|| .T.},{|| .T.},{},.F.,NIL,.F.,.F.,.T.)						
    oStruJOI:AddField("Endereço de Destino","Endereço de Destino","JOI_ENDDES","C",TamSx3('D3_LOCALIZ')[1],0,{|| .T.},{|| .T.},{},.F.,NIL,.F.,.F.,.T.)						
    oStruJOI:AddField("Codigo JO4"         ,"Codigo JO4"         ,"JOI_CODJO4","C",TamSx3('JO4_CODIGO')[1],0,{|| .T.},{|| .T.},{},.F.,NIL,.F.,.F.,.T.)							


    oModel := MPFormModel():New('FSMA050', /*bPreValid*/, /*bPosValid*/,, /*bCancel*/)
    
    oModel:AddFields('JOIMASTER',/*cOwner*/,oStruJOI)

    oModel:GetModel('JOIMASTER'):SetDescription("Estoque do técnico")

    oModel:SetDescription("Estoque do técnico")

    oModel:SetPrimaryKey( { "JOI_FILIAL", "JOI_CODIGO" } )

    oModel:InstallEvent("FSMA050Event", /*cOwner*/, oModelEvent)

Return oModel

//-------------------------------------------------------------------
/*/{Protheus.doc} 
@author Vitor kwon
@since 24/11/2025
@version 1.0
/*/
//-------------------------------------------------------------------

Class FSMA050Event FROM FwModelEvent
	Method New()
    Method ModelPosVld()
End Class

//-------------------------------------------------------------------
/*/{Protheus.doc} 
@author Vitor kwon
@since 24/11/2025
@version 1.0
/*/
//-------------------------------------------------------------------
Method New() Class FSMA050Event
Return

//-------------------------------------------------------------------
/*/{Protheus.doc} pos valid
@author Vitor kwon
@since 24/11/2025
@version 1.0
/*/
//-------------------------------------------------------------------
Method ModelPosVld(oModel, cModelId) Class FSMA050Event
Local lRet      := .T.
Local cMsgErro  := ''

        lRet := GeraTransf(oModel, @cMsgErro)

        If !(lRet)
           	oModel:SetErrorMessage('JOIMASTER', ,'JOIMASTER',, "GERATRANSF", cMsgErro, '') 
        Endif

Return lRet



//-------------------------------------------------------------------
/*/{Protheus.doc} grvtDtkits
@author Vitor kwon
@since 19/09/2025
@version 1.0
status 01 = Atribuido
status 02 = Entregue
status 03 = Devolvido
/*/
//-------------------------------------------------------------------

Static Function GeraTransf(oModel, cMsgErro)

Local lRet      := .T.
local oEst     := FSM_ESTO():New()

Private lMsErroAuto := .F.

    if oModel:getOperation() == MODEL_OPERATION_INSERT

        Begin Transaction 

                aItensNew:={}

                cDocumento := nextnumero("SD3",2,"D3_DOC",.t.)

                aadd (aItensNew,{ cDocumento, ddatabase})
  
                cProduto  := oModel:GetValue("JOIMASTER","JOI_CODPRO")
                cCodJO4   := oModel:GetValue("JOIMASTER","JOI_CODJO4")
                
                aItemMov := oEst:FSMTransfer( ;
                cProduto, ;  
                oModel:GetValue('JOIMASTER','JOI_ARMORI'), ;   // armazem de origem
                oModel:GetValue('JOIMASTER','JOI_ARMDES'), ;    // armazem de destino
                oModel:GetValue('JOIMASTER','JOI_ENDORI'), ;   // endereco de origem
                oModel:GetValue('JOIMASTER','JOI_ENDDES'), ;   // endereco  de destino 
                oModel:GetValue('JOIMASTER','JOI_QTDPRO'), ;        
                )
                aAdd(aItensNew, aClone(aItemMov))

                MSExecAuto({|x, y| MATA261(x,y)},aItensNew,3) // Geração da Movimentacao interna

                If lMsErroAuto
                    lRet := .F.
                    DisarmTransaction() // Desarma a treansação
                Else
                    oModel:SetValue('JOIMASTER','JOI_CODSD3', cDocumento)
                    oModel:SetValue('JOIMASTER','JOI_ARMORI',  oModel:GetValue('JOIMASTER','JOI_ARMORI'))
                    oModel:SetValue('JOIMASTER','JOI_ENDORI',  oModel:GetValue('JOIMASTER','JOI_ENDORI'))
                    oModel:SetValue('JOIMASTER','JOI_ARMDES',  oModel:GetValue('JOIMASTER','JOI_ARMDES'))
                    oModel:SetValue('JOIMASTER','JOI_ENDDES',   oModel:GetValue('JOIMASTER','JOI_ENDDES'))
                                    
                    DbselectArea('JO4')

                    JO4->(DbSetOrder(1))   

                    IF JO4->(MsSeek(xFilial("JO4")+cCodJO4))
                        JO4->(Reclock("JO4",.f.))
                           JO4->JO4_TRANSF := '1'
                        JO4->(msUnLock()) 
                    Endif

                Endif

        End Transaction

    Endif

Return lRet
