#INCLUDE "PROTHEUS.CH"
#INCLUDE "TBICONN.CH"
#INCLUDE 'FWMBROWSE.CH'
#INCLUDE 'FWMVCDEF.CH'

//-----------------------------------------------------------------
/*/{Protheus.doc} ModelDef
 Definicao da Model PLCARAUB72 (utilizacao na integracao 
 Auditoria x Carol )
 
@author renan.almeida
@since 12/02/2019
@version 1.0
/*/
//-----------------------------------------------------------------
Static Function ModelDef()

    Local oStrB72 := FWFormStruct(1,'B72')

    oModel 	:= MPFormModel():New("PLCARAUB72") //oModel 	:= MPFormModel():New("PLCARAUB72",,,{|oModel| PLGRPARA(oModel)})
    oModel:Addfields('B72DETAIL',NIL,oStrB72)
    oModel:SetPKIndexOrder(3)
    oModel:SetPrimaryKey({'B72_ALIMOV', 'B72_RECMOV', 'B72_SEQPRO', 'B72_CODGLO', 'B72_CODPAD', 'B72_CODPRO'})
    oModel:SetDescription( "Auditoria Carol" ) //'Parecer Auditoria'
    oModel:GetModel( 'B72DETAIL' ):SetDescription( "Parecer" ) //"Parecer"

    oModel:SetActivate({|oModel| VldCpo(@oModel)})

Return oModel