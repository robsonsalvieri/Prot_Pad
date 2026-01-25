#include "TOTVS.CH"
#define idTraInc  "1"
#define idTraAlt  "2"
#define idTraExc  "3"

#define idExcGuia "1"
#define idExcTran "2"

#define idPendente "1"
#define idCritica  "3"

//------------------------------------------------------------------------------------------
/*/{Protheus.doc} CenProcMon
    Classe abstrata para execução de comandos
    @type  Class
    @author renan.almeida
    @since 20190320
/*/
//------------------------------------------------------------------------------------------
Class CenProcMon

    Data oExecutor

    Data cCodOpe    as String
    Data cSeqGui    as String
    Data cCodObrig  as String
    Data cAno       as String
    Data cMes       as String
    Data cLote      as String
    Data cNumGuiOpe as String
    Data cNumGuiPre as String
    Data dProcGuia  as Date
    Data cTipRegist as String
    Data lOkProces  as Boolean
    Data cStatus    as String

    Method New(oExecutor) Constructor
    Method loadChave(oAuxCab)
    Method setOper(cCodOpe)
    Method setObrig(cCodObrig)
    Method setAno(cAno)
    Method setComp(cMes)
    Method grvCritica(cAlias,cRecno,cCodCri,cDesc,cSolucao)
    Method getEveInfo(cCodTab,cCodPro,cCodGru)
    Method comAltExc(oAux)
    Method delMovB3F(oAuxExc,cAlias,nRecno)

EndClass


//------------------------------------------------------------------------------------------
/*/{Protheus.doc} New 
    Metodo construtor da classe proGuiaAPI
    @type  Class
    @author renan.almeida
    @since 20190320
/*/
//------------------------------------------------------------------------------------------
Method New(oExecutor) Class CenProcMon
   
    self:cCodOpe    := ""
    self:cSeqGui    := ""
    self:cCodObrig  := ""
    self:cAno       := ""   
    self:cMes       := ""
    self:cLote      := ""
    self:cNumGuiOpe := ""
    self:cNumGuiPre := ""
    self:dProcGuia  := Stod("")
    self:cTipRegist := idTraInc
    self:lOkProces  := .T.
    self:cStatus    := idPendente
        
Return self

Method setOper(cCodOpe) Class CenProcMon
    self:cCodOpe := cCodOpe
Return

Method setObrig(cCodObrig) Class CenProcMon
    self:cCodObrig := cCodObrig
Return

Method setAno(cAno) Class CenProcMon
    self:cAno := cAno
Return

Method setComp(cMes) Class CenProcMon
    self:cMes := cMes
Return

//------------------------------------------------------------------------------------------
/*/{Protheus.doc} loadChave
    Carrega para o objeto principal, dados que vou utilizar nas chaves primarias

    @type  Class
    @author renan.almeida
    @since 20190320
/*/
//------------------------------------------------------------------------------------------
Method loadChave(oAuxCab) Class CenProcMon
    
    Local cAno      := Substr(oAuxCab:getValue("formProcDt"),1,4)
    Local cMes      := Strzero(Val(Substr(oAuxCab:getValue("formProcDt"),5,2)),3)
    Local oColB3A   := CenCltObri():New() 
    Local oAux      := nil
    Local cCodObrig := ""

    //Colocar os compromissos num array e só buscar no banco de novo se o compromisso não existir no array (melhora MUITO a performance)
    oColB3A:SetValue("obligationType","5")
    oColB3A:SetValue("activeInactive","1")
    oColB3A:SetValue("operatorRecord",oAuxCab:getValue("operatorRecord"))

    if oColB3A:buscar() .And. oColB3A:HasNext()
        oAux      := oColB3A:GetNext()
        cCodObrig := oAux:GetValue("requirementCode")
    endIf 

    self:cCodObrig  := cCodObrig
    self:cAno       := cAno
    self:cMes       := cMes
    self:cNumGuiOpe := oAuxCab:getValue("operatorFormNumber")
    self:cNumGuiPre := oAuxCab:getValue("providerFormNumber")
    self:dProcGuia  := oAuxCab:getValue("formProcDt")

    if oAux != Nil
        oAux:destroy()
        FreeObj(oAux)
        oAux := nil
    endIf
    
    oColB3A:destroy()
    FreeObj(oColB3A)
    oColB3A := nil

Return


//------------------------------------------------------------------------------------------
/*/{Protheus.doc} grvCritica
    Grava uma critica na tabela B3F

    @type  Class
    @author renan.almeida
    @since 20190320
/*/
//------------------------------------------------------------------------------------------
Method grvCritica(cAlias,cRecno,cCodCri,cDesc,cSolucao) Class CenProcMon

    Local cChaveOri := self:cCodOpe+self:cNumGuiOpe+self:cCodObrig+self:cAno+self:cMes+self:cLote+self:dProcGuia
            
    PlObInCrit(self:cCodOpe,;
        self:cCodObrig,;
        self:cAno,;
        self:cMes,;
        cAlias,;
        cRecno,;
        cCodCri,;
        cDesc,;
        cSolucao,;
        "",;    //cCampos
        nil,;   //cTipoVld
        "",;    //cCriANS
        cChaveOri,;
        "",;   //cDescOri
        "1")

    self:cStatus := idCritica

Return


//------------------------------------------------------------------------------------------
/*/{Protheus.doc} getEveInfo
    Busca dados no cadastro do evento

    @type  Class
    @author renan.almeida
    @since 20190320
/*/
//------------------------------------------------------------------------------------------
Method getEveInfo(cCodTab,cCodPro,cCodGru) Class CenProcMon
    
    Local oColB7Z   := CenCltB7Z():New()
    Local oAux      := nil
    Local cTipEve   := ""
    
    //Busca por grupo, retorno o primeiro evento que encontrar 
    if !Empty(cCodGru)
        oColB7Z:SetValue("procedureGroup",cCodGru)
        if oColB7Z:buscar()
            oAux    := oColB7Z:GetNext()
            cTipEve := oAux:GetValue("eventType") 
        endIf    
    //Busca por evento
    else 
        oColB7Z:SetValue("tableCode",cCodTab)     //B7Z_CODTAB
        oColB7Z:SetValue("procedureCode",cCodPro) //B7Z_CODPRO
        if oColB7Z:bscChaPrim()
            oAux    := oColB7Z:GetNext()
            cTipEve := oAux:GetValue("eventType") 
        endIf
    endIf

    FreeObj(oAux)
    oAux := nil

    oColB7Z:destroy()
    FreeObj(oColB7Z)
    oColB7Z := nil    

Return cTipEve


//------------------------------------------------------------------------------------------
/*/{Protheus.doc} comAltExc
    Verifico a compentencia que devo gerar a exclusao/alteracao,
    o padrao e gerar sempre na competencia seguinte a data

    @type  Class
    @author renan.almeida
    @since 20190320
/*/
//------------------------------------------------------------------------------------------
Method comAltExc(oAux) Class CenProcMon

    Local cAno := Substr(Dtos(dDatabase),1,4)
    Local cMes := Strzero(Val(Substr(Dtos(dDatabase),5,2)),3)

    //Se database superior ou igual a transacao, adiciono um mes sob a database
    if cAno > oAux:getValue("referenceYear") .Or. ;
       ( cAno == oAux:getValue("referenceYear") .And. ;
         cMes >= oAux:getValue("commitmentCode") )

        self:cAno := cAno
        self:cMes := cMes
    //Se database inferior, adiciono um mes para a data da transacao
    else
        cMes := oAux:getValue("commitmentCode")
        cAno := oAux:getValue("referenceYear")
        
        if cMes == "12"
            cMes := "001"
            cAno := cValtoChar(Val(cAno) + 1)
        else
            cMes := Strzero(Val(cMes) + 1,3)      
        endIf

        self:cAno := cAno
        self:cMes := cMes
    endIf

Return


//------------------------------------------------------------------------------------------
/*/{Protheus.doc} delMovB3F
    Deleta os eventos B3F (criticas) de uma movimentacao pendente

    @type  Class
    @author renan.almeida
    @since 20190320
/*/
//------------------------------------------------------------------------------------------
Method delMovB3F(oAuxExc,cAlias,nRecno) Class CenProcMon

    Local oCltB3F := CenCltCrit():New()

    oCltB3F:SetValue("operatorRecord"   ,self:cCodOpe) //B3F_CODOPE
    oCltB3F:SetValue("requirementCode"     ,self:cCodObrig) //B3F_CDOBRI
    oCltB3F:SetValue("commitReferenceYear",oAuxExc:getValue("referenceYear")) //B3F_ANO
    oCltB3F:SetValue("commitmentCode"     ,oAuxExc:getValue("commitmentCode")) //B3F_CDCOMP
    oCltB3F:SetValue("reviewOrigin"       ,cAlias) //B3F_ORICRI
    oCltB3F:SetValue("originRegAcknowlegm",nRecno) //B3F_CHVORI

    if oCltB3F:buscar()
        while oCltB3F:HasNext() 

            oAux := oCltB3F:GetNext()
            //Chave Primaria - B3F_FILIAL, B3F_CODOPE, B3F_CDOBRI, B3F_ANO, B3F_CDCOMP, B3F_ORICRI, B3F_CHVORI, B3F_CODCRI, B3F_TIPO, B3F_IDEORI, B3F_DESORI
            oObjDel := CenCltCrit():New()
            oObjDel:SetValue("operatorRecord"   ,oAux:getValue("operatorRecord")) //B3F_CODOPE
            oObjDel:SetValue("requirementCode"     ,oAux:getValue("requirementCode")) //B3F_CDOBRI
            oObjDel:SetValue("commitReferenceYear",oAux:getValue("commitReferenceYear")) //B3F_ANO
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
            FreeObj(oObjDel)
            FreeObj(oAux)
            oObjDel := nil
            oAux := nil
            
        endDo    
    endIf

    oCltB3F:destroy()
    FreeObj(oCltB3F)
    oCltB3F := nil

Return