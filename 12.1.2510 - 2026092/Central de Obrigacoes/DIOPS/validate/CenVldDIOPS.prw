#INCLUDE "PROTHEUS.CH"
#INCLUDE "TOTVS.CH"

Class CenVldDIOPS from CenValidator

    Method New() Constructor
    Method validate(oEntity)
    Method podeImpDiops(oEntity)

EndClass

Method New() Class CenVldDIOPS
    _Super:New()
Return self

Method validate(oEntity) Class CenVldDIOPS
    Local lOk       := .T.

    If Empty( oEntity:getValue( "obligationCode" ) ) 
		lOk := .F.
		self:cMsg := "Codigo da obrigação não informado"
	ElseIf Empty( oEntity:getValue( "commitmentCode" ) ) 
		lOk := .F.
		self:cMsg := "Codigo do Compromisso não informado"
	ElseIf Empty( oEntity:getValue( "commitmentYear" ) ) 
		lOk := .F.
		self:cMsg := "Ano do Compromisso não informado"
	ElseIf Empty( oEntity:getValue( "providerRegister" ) ) 
        lOk := .F.
        self:cMsg := "Código da operadora não informado"
	ElseIf lOk 
        lOk := self:podeImpDiops(oEntity) 
    EndIf
Return lOk

Method podeImpDiops(oEntity) Class CenVldDIOPS
    Local oCltComp := CenCltComp():New()
    Local lOk := .T.
    oCltComp:setValue("obligationCode",oEntity:getValue("obligationCode"))
    oCltComp:setValue("commitmentCode",oEntity:getValue("commitmentCode"))
    oCltComp:setValue("providerSystem",oEntity:getValue("operatorRecord"))
    oCltComp:setValue("referenceYear",oEntity:getValue("commitmentYear"))
    lOk := oCltComp:podeImpDiops()

    oCltComp:destroy()
    FreeObj(oCltComp)
    oCltComp := nil
Return lOk
