#INCLUDE "PROTHEUS.CH"
#INCLUDE "TBICONN.CH"
#INCLUDE 'FWMBROWSE.CH'
#INCLUDE 'FWMVCDEF.CH'

//-----------------------------------------------------------------
/*/{Protheus.doc} ModelDef
 Definicao da Model PLCARAUB71 (utilizacao na integracao 
 Auditoria x Carol )
 
@author renan.almeida
@since 12/02/2019
@version 1.0
/*/
//-----------------------------------------------------------------
Static Function ModelDef()

    Local oStrB71 := FWFormStruct(1,'B71')

    oModel 	:= MPFormModel():New("PLCARAUB71")
    oModel:Addfields('PLSENCAMMD',NIL,oStrB71)
    oModel:SetPKIndexOrder(1)
    oModel:SetPrimaryKey({'B71_ALIMOV','B71_RECMOV','B71_SEQUEN'})
    oModel:SetDescription( "Encaminhamento Carol" )
    oModel:GetModel( 'PLSENCAMMD' ):SetDescription( "Parecer" )

    oModel:SetActivate() //oModel:SetActivate({|oModel| VldCpo(@oModel)})

Return oModel