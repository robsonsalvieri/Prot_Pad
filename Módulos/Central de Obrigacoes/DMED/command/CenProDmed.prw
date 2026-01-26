#include "TOTVS.CH"
#define idTraInc  "1"
#define idPendente "1"

//------------------------------------------------------------------------------------------
/*/{Protheus.doc} CenProDmed
    Classe abstrata para execução de comandos
    @type  Class
    @author jose.paulo
    @since 06/10/2020
/*/
//------------------------------------------------------------------------------------------
Class CenProDmed

    Data oExecutor

    Data cCodOpe       as String
    Data cCodObrig     as String
    Data cCdComp       as String
    Data cAno          as String
    Data cMes          as String
    Data cMatTit       as String
    Data cCpfTit       as String
    Data cCpfBen       as String
    Data cCompet       as String
    Data cTipRegist    as String
    Data lOkProces     as Boolean
    Data cStatus       as String
    Data cNomBen       as String
    Data cNomTit       as String
    Data cMatDep       as String
    Data cDatAni       as String
    Data cRelDep       as String
    Data cChvDes       as String
    Data cVlrDes       as String
    Data cValRee       as String
    Data cValRaa       as String
    Data cCpfCgc       as String
    Data cMatBen       as String
    Data cCpfPre       as String
    Data cNomPre       as String
    Data cVlrAne       as String
    Data processed     as String
    Data roboId        as String
    Data inclusionTime as String
    Data exclusionId   as String
    Data cIdeReg       as String
    Data cExclId       as String

    Method New(oExecutor) Constructor
    Method setOper(cCodOpe)
    Method setObrig(cCodObrig)
    Method setAno(cAno)
    Method setComp(cMes)
    Method delMovB3F(oAuxExc,cAlias,nRecno)

EndClass


//------------------------------------------------------------------------------------------
/*/{Protheus.doc} New
    Metodo construtor da classe proGuiaAPI
    @type  Class
    @author jose.paulo
    @since 06/10/2020
/*/
//------------------------------------------------------------------------------------------
Method New(oExecutor) Class CenProDmed

    self:cCodOpe       := ""
    self:cCodObrig     := ""
    self:cCdComp       := ""
    self:cAno          := ""
    self:cMes          := ""
    self:cMatTit       := ""
    self:cCpfTit       := ""
    self:cCpfBen       := ""
    self:cCompet       := ""
    self:cTipRegist    := idTraInc
    self:lOkProces     := .T.
    self:cStatus       := idPendente
    self:cNomBen       := ""
    self:cNomTit       := ""
    self:cMatDep       := ""
    self:cDatAni       := ""
    self:cRelDep       := ""
    self:cChvDes       := ""
    self:cVlrDes       := ""
    self:cValRee       := ""
    self:cValRaa       := ""
    self:cCpfCgc       := ""
    self:cMatBen       := ""
    self:cCpfPre       := ""
    self:cNomPre       := ""
    self:cVlrAne       := ""
    self:processed     := ""
    self:roboId        := ""
    self:inclusionTime := ""
    self:exclusionId   := ""
    self:cIdeReg       := ""
    self:cExclId       := ""

Return self

Method setOper(cCodOpe) Class CenProDmed
    self:cCodOpe := cCodOpe
Return

Method setObrig(cCodObrig) Class CenProDmed
    self:cCodObrig := cCodObrig
Return

Method setAno(cAno) Class CenProDmed
    self:cAno := cAno
Return

Method setComp(cMes) Class CenProDmed
    self:cMes := cMes
Return

//------------------------------------------------------------------------------------------
/*/{Protheus.doc} delMovB3F
    Deleta os eventos B3F (criticas) de uma movimentacao pendente

    @type  Class
    @author jose.paulo
    @since 06/10/2020
/*/
//------------------------------------------------------------------------------------------
Method delMovB3F(oAuxExc,cAlias,nRecno) Class CenProDmed

    Local oCltB3F := CenCltCrit():New()

    oCltB3F:SetValue("healthInsurerCode"  ,self:cCodOpe) //B3F_CODOPE
    oCltB3F:SetValue("requirementCode"    ,self:cCodObrig) //B3F_CDOBRI
    oCltB3F:SetValue("referenceYear"      ,oAuxExc:getValue("commitmentYear")) //B3F_ANO
    oCltB3F:SetValue("commitmentCode"     ,oAuxExc:getValue("commitmentCode")) //B3F_CDCOMP
    oCltB3F:SetValue("reviewOrigin"       ,cAlias) //B3F_ORICRI
    oCltB3F:SetValue("originRegAcknowlegm",nRecno) //B3F_CHVORI

    if oCltB3F:buscar()
        while oCltB3F:HasNext()

            oAux := oCltB3F:GetNext()
            //Chave Primaria - B3F_FILIAL, B3F_CODOPE, B3F_CDOBRI, B3F_ANO, B3F_CDCOMP, B3F_ORICRI, B3F_CHVORI, B3F_CODCRI, B3F_TIPO, B3F_IDEORI, B3F_DESORI
            oObjDel := CenCltCrit():New()
            oObjDel:SetValue("healthInsurerCode"  ,self:cCodOpe) //B3F_CODOPE
            oObjDel:SetValue("requirementCode"    ,oAux:getValue("requirementCode")) //B3F_CDOBRI
            oObjDel:SetValue("referenceYear"      ,oAux:getValue("commitReferenceYear")) //B3F_ANO
            oObjDel:SetValue("commitmentCode"     ,oAux:getValue("commitmentCode")) //B3F_CDCOMP
            oObjDel:SetValue("reviewOrigin"       ,oAux:getValue("reviewOrigin")) //B3F_ORICRI
            oObjDel:SetValue("originRegAcknowlegm",oAux:getValue("originRegAcknowlegm")) //B3F_CHVORI
            oObjDel:SetValue("reviewCode"         ,oAux:getValue("reviewCode")) //B3F_CODCRI
            oObjDel:SetValue("type"               ,oAux:getValue("type")) //B3F_TIPO
            oObjDel:SetValue("originIdentKey"     ,oAux:getValue("originIdentKey")) //B3F_IDEORI
            oObjDel:SetValue("originDescription"  ,oAux:getValue("originDescription")) //B3F_DESORI

            oObjDel:delete()
            oObjDel:destroy()
            oAux:destroy()
        endDo
    endIf

Return