#include "TOTVS.CH"
#define idTraInc  "1"
#define idTraAlt  "2"
#define idTraExc  "3"
#define idExcGuia "1"
#define idCritica "3"
#define _CriMon104 {"M104","Os eventos da movimentacao processada são divergentes de uma transação já comunicada com a ANS.","Solicite o reenvio da movimentações com os itens corretos ou a solicitação de exclusão da transação já processada."}

//------------------------------------------------------------------------------------------
/*/{Protheus.doc}CenPrMoFor
    Classe abstrata para execução de comandos
    @type  Class
    @author renan.almeida
    @since 20190320
/*/
//------------------------------------------------------------------------------------------
Class CenPrMoFor From CenProcMon

    Method New() Constructor
    Method proGuiaAPI()
    Method atuProcAPI()
    //Metodos de inclusao
    Method procInclus(oAuxCab)
    Method verTraPend(oAuxCab)
    //Metodos de commit de dados
    Method grvMovBVT(oAuxEve)
    Method grvMovBVQ(oAuxCab,oTotaliz)
    //Exclucao Movimentacao
    Method delMovBVQ(oObjBVQ)
    Method delMovBVT(oObjBVQ)
    //Metodos de exclusao
    Method excTransac()
    Method gerTraExc(oObjBVQ)
    //Metodos de alteracao
    Method verAlter(oAuxCab)
    Method comparEve(oAuxCab)

EndClass


//------------------------------------------------------------------------------------------
/*/{Protheus.doc} New
    Metodo construtor da classe proGuiaAPI
    @type  Class
    @author renan.almeida
    @since 20190320
/*/
//------------------------------------------------------------------------------------------
Method New() Class CenPrMoFor

    _Super:new()

return self


//------------------------------------------------------------------------------------------
/*/{Protheus.doc} proGuiaAPI
    Processa uma guia enviada para a API
    @type  Class
    @author renan.almeida
    @since 20190320
/*/
//------------------------------------------------------------------------------------------
Method proGuiaAPI(oAuxCab) Class CenPrMoFor

    Local oColBW8   := Nil
    Default oAuxCab   := Nil

    If oAuxCab == Nil
        oColBW8 := CenCltBW8():New()
        oColBW8:SetValue("operatorRecord",self:cCodOpe)
        oColBW8:SetValue("formSequential",self:cSeqGui)
        oColBW8:SetValue("processed","0")
        if oColBW8:bscChaPrim()
            oAuxCab := oColBW8:GetNext() //Carrega cabecalho API
        EndIf
    EndIf

    If oAuxCab != nil
        self:loadChave(oAuxCab)

        //Processa Exclusao
        if oAuxCab:getValue("exclusionId") == idExcGuia //Exclusao de Guia
            self:excTransac()
            // Inclusao/Alteracao
        else
            //Verifica se tem transacao pendente nao enviada ja gravada
            self:verTraPend(oAuxCab)
            //Verifica se a transacao ja tem um registro processado
            if self:lOkProces
                self:verAlter(oAuxCab)
            endIf
            //Processa uma inclusao
            if self:lOkProces
                self:procInclus(oAuxCab)
            endIf
        endIf
        self:atuProcAPI() //Atualiza registro na BW8 como processado

        // oAuxCab:destroy()
        // FreeObj(oAuxCab)
        // oAuxCab := nil

    endIf

    If oColBW8 != nil
        oColBW8:destroy()
        FreeObj(oColBW8)
        oColBW8 := nil
    EndIf

Return


//------------------------------------------------------------------------------------------
/*/{Protheus.doc} verTraPend
    Alteração de um registro não enviado para a ANS, devemos excluir a mais antiga

    @type  Class
    @author renan.almeida
    @since 20190320
/*/
//------------------------------------------------------------------------------------------
Method verTraPend(oAuxCab) Class CenPrMoFor

    Local oColBVQ := CenCltBVQ():New()
    Local oObjBVQ := nil

    oColBVQ:SetValue("operatorRecord"    ,self:cCodOpe)
    oColBVQ:SetValue("providerFormNumber",self:cNumGuiPre)
    oColBVQ:SetValue("requirementCode"   ,self:cCodObrig)
    oColBVQ:SetValue("referenceYear"     ,self:cAno)
    oColBVQ:SetValue("commitmentCode"    ,self:cMes)

    if oColBVQ:bscMovPend() //Busca transacoes pendentes com o Status: 1=Pendente Envio;2=Criticado;3=Pronto para o Envio

        while oColBVQ:HasNext() //Coloquei um While, mas teoricamente so tera um registro

            oObjBVQ := oColBVQ:GetNext()
            //Se a data de inclusao do registro ja processado é inferior a que estou processando no momento,
            //excluo o registro existente para criar um novo registro atualizado
            if (oObjBVQ:getValue("inclusionDate") <  oAuxCab:getValue("inclusionDate")) .Or. ;
                    (oObjBVQ:getValue("inclusionDate") == oAuxCab:getValue("inclusionDate") .And. ;
                    oObjBVQ:getValue("inclusionTime") <  oAuxCab:getValue("inclusionTime"))
                self:delMovB3F(oObjBVQ,"BVQ",BVQ->(Recno()))
                self:delMovBVQ(oObjBVQ)
                self:delMovBVT(oObjBVQ)

                //Verifico se preciso restaurar o historico
                //self:proRestHis()

                //Se a transacao que estou processando for mais velha que o registro ja criado, ignoro a transacao
            else
                self:lOkProces := .F.
            endIf

            oObjBVQ:destroy()
            FreeObj(oObjBVQ)
            oObjBVQ := nil

        endDo

    endIf

    oColBVQ:destroy()
    FreeObj(oColBVQ)
    oColBVQ := nil

Return


//------------------------------------------------------------------------------------------
/*/{Protheus.doc} verTraProc
    Verifica se tem uma guia ja processada e realiza a alteracao de dados

    @type  Class
    @author renan.almeida
    @since 20190320
/*/
//------------------------------------------------------------------------------------------
Method verAlter(oAuxCab) Class CenPrMoFor

    Local oColBVQ := CenCltBVQ():New()
    Local oAux    := nil

    oColBVQ:SetValue("operatorRecord"    ,self:cCodOpe)
    oColBVQ:SetValue("providerFormNumber",self:cNumGuiPre)
    oColBVQ:SetValue("requirementCode"   ,self:cCodObrig)
    oColBVQ:SetValue("referenceYear"     ,self:cAno)
    oColBVQ:SetValue("commitmentCode"    ,self:cMes)
    oColBVQ:SetValue("formProcDt"        ,self:dProcGuia)

    if oColBVQ:bscMovProc() //Busca transacoes ja processadas com o Status: 4=Em processamento ANS;5=Criticado pela ANS;6=Finalizado

        //Verifica se a ultima movimentacao desta chave e uma exclusao
        oColExcBVQ := CenCltBVQ():New()
        oColExcBVQ:SetValue("operatorRecord"    ,self:cCodOpe)
        oColExcBVQ:SetValue("providerFormNumber",self:cNumGuiPre)
        oColExcBVQ:SetValue("requirementCode"   ,self:cCodObrig)
        oColExcBVQ:SetValue("formProcDt"        ,self:dProcGuia)

        if oColExcBVQ:bscUltChv() .And. oColExcBVQ:HasNext()
            oAux := oColExcBVQ:GetNext()
            if oAux:getValue("monitoringRecordType") <> idTraExc
                self:comparEve(oAux)
                if self:cTipRegist == "2"
                    //Padrao para exclusao e gerar na proxima competencia
                    self:comAltExc(oAuxCab)
                endIf
            endIf
            oAux:destroy()
            FreeObj(oAux)
            oAux := nil
        endIf
        oColExcBVQ:destroy()
        FreeObj(oColExcBVQ)
        oColExcBVQ := nil
    endIf
    oColBVQ:destroy()
    FreeObj(oColBVQ)
    oColBVQ := nil
Return


//------------------------------------------------------------------------------------------
/*/{Protheus.doc} comparEve
    Verifica se tem uma guia ja processada e realiza a alteracao de dados

    @type  Class
    @author renan.almeida
    @since 20190320
/*/
//------------------------------------------------------------------------------------------
Method comparEve(oAuxCab) Class CenPrMoFor

    Local oColBWL    := CenCltBWL():New()
    Local oColBVT    := CenCltBVT():New()
    Local lAltera    := .F.
    Local lItensOk   := .T.
    Local lTemBWL    := .F.
    Local lTemBVT    := .F.

    oColBWL:SetValue("operatorRecord",self:cCodOpe)
    oColBWL:SetValue("formSequential",self:cSeqGui)

    oColBVT:SetValue("operatorRecord"    ,oAuxCab:getValue("operatorRecord"))     //BVT_CODOPE
    oColBVT:SetValue("providerFormNumber",oAuxCab:getValue("providerFormNumber")) //BVT_NMGPRE
    oColBVT:SetValue("requirementCode"   ,oAuxCab:getValue("requirementCode"))    //BVT_CDOBRI
    oColBVT:SetValue("referenceYear"     ,oAuxCab:getValue("referenceYear"))      //BVT_ANO
    oColBVT:SetValue("commitmentCode"    ,oAuxCab:getValue("commitmentCode"))     //BKR_CDCOMP
    oColBVT:SetValue("batchCode"         ,oAuxCab:getValue("batchCode"))          //BVT_LOTE
    oColBVT:SetValue("formProcDt"        ,oAuxCab:getValue("formProcDt"))         //BVT_DTPRGU

    //Aglutina eventos e realiza a gravacao deles
    if oColBWL:aglutEvent() .And. oColBVT:bscUltEve()

        lTemBWL := oColBWL:HasNext()
        lTemBVT := oColBVT:HasNext()

        while  lTemBWL .And. lTemBVT
            oObjBWL := oColBWL:getNext()
            oObjBVT := oColBVT:getNext()

            //Verifica se recebeu os mesmo itens
            if oObjBWL:getValue("procedureGroup") == oObjBVT:getValue("procedureGroup") .And. ;
                    oObjBWL:getValue("procedureCode")  == oObjBVT:getValue("procedureCode") .And. ;
                    oObjBWL:getValue("tableCode")      ==  oObjBVT:getValue("tableCode")

                if oObjBWL:getValue("enteredQuantity")    <> oObjBVT:getValue("enteredQuantity") .Or. ;
                        oObjBWL:getValue("procedureValuePaid") <> oObjBVT:getValue("procedureValuePaid") .Or. ;
                        oObjBWL:getValue("coPaymentValue")     <> oObjBVT:getValue("coPaymentValue")

                    lAltera := .T.
                endIf
                //Os itens sao diferentes, devo criticar
            else
                lItensOk := .F.
                lTemBWL  := .F.
                lTemBVT  := .F.
            endIf

            if lItensOk
                lTemBWL := oColBWL:HasNext()
                lTemBVT := oColBVT:HasNext()
            endIf
            oObjBWL:destroy()
            oObjBVT:destroy()
            FreeObj(oObjBWL)
            FreeObj(oObjBVT)
            oObjBWL := nil
            oObjBVT := nil
        endDo
    endIf

    oColBWL:destroy()
    oColBVT:destroy()
    FreeObj(oColBWL)
    FreeObj(oColBVT)
    oColBWL := nil
    oColBVT := nil

    //Se algum Alias tiver itens a mais, critico
    if (lTemBWL .And. !lTemBVT) .Or. (!lTemBWL .And. lTemBVT)
        lItensOk := .F.
    endIf

    //Se erro de itens divergentes, gero a guia por aqui com critica
    if !lItensOk
        self:cTipRegist := "2"   //Indico id de Alteracao
        self:cStatus    := idCritica   //Indico erro
        self:lOkProces  := .F.   //Nao preciso continuar o processamento
        self:comAltExc(oAuxCab)  //Ajusta competencias
        self:procInclus(oAuxCab) //Gera movimentacao
        self:grvCritica("BVQ",;  //Adiciona critica
            cValtoChar(BVQ->(Recno())),;
            _CriMon104[1],;
            _CriMon104[2],;
            _CriMon104[3])
        //Alteracao
    elseIf lAltera
        self:cTipRegist := "2"
        //Nao teve registro alterado, aborto a inclusao
    else
        self:lOkProces := .F.
    endIf

Return


//------------------------------------------------------------------------------------------
/*/{Protheus.doc} procInclus
    Grava registros de movimentacao

    @type  Class
    @author renan.almeida
    @since 20190320
/*/
//------------------------------------------------------------------------------------------
Method procInclus(oAuxCab) Class CenPrMoFor

    Local oColBWL    := nil
    Local lGrvEve    := .T.
    Local cCodTab    := ""
    Local cCodPro    := ""
    Local cCodGru    := ""
    Local lUmItemGrv := .F.
    //---------------------------------------------------------
    //              Gravacao de Eventos
    //---------------------------------------------------------
    oColBWL := CenCltBWL():New()
    oColBWL:SetValue("operatorRecord",self:cCodOpe)
    oColBWL:SetValue("formSequential",self:cSeqGui)

    //Aglutina eventos e realiza a gravacao deles
    if oColBWL:aglutEvent()

        oCalTotMov := CenMoTotGu():New() //Objeto para totalizadores do cabecalho movimentacao

        while oColBWL:HasNext()
            oAuxEve := oColBWL:GetNext()

            cCodTab := oAuxEve:GetValue("tableCode")
            cCodPro := oAuxEve:GetValue("procedureCode")
            cCodGru := oAuxEve:GetValue("procedureGroup")
            cTipEve   := self:getEveInfo(cCodTab,cCodPro,cCodGru)
            //Grava evento
            if lGrvEve
                self:grvMovBVT(oAuxEve)           //Grava movimentacao - eventos
                oCalTotMov:calForDir(oAuxEve)     //Calcula totalizadores movimentacao
                lUmItemGrv := .T.
            else
                oCalTotMov:calForDir(oAuxEve,.F.) //Calcula totalizadores movimentacao
            endif
            oAuxEve:destroy()
            FreeObj(oAuxEve)
            oAuxEve := nil
        endDo

        //---------------------------------------------------------
        //              Gravacao de Cabecalho
        //---------------------------------------------------------
        if lUmItemGrv
            self:grvMovBVQ(oAuxCab,oCalTotMov) //Grava movimentacao - cabecalho
        endIf
        oCalTotMov:destroy()
        FreeObj(oCalTotMov)
        oCalTotMov := nil
    endif
    oColBWL:destroy()
    FreeObj(oColBWL)
    oColBWL := nil
Return

//------------------------------------------------------------------------------------------
/*/{Protheus.doc} grvMovBVQ
    Grava o cabecalho da movimentacao na BVQ

    @type  Class
    @author renan.almeida
    @since 20190320
/*/
//------------------------------------------------------------------------------------------
Method grvMovBVQ(oAuxCab,oTotaliz) Class CenPrMoFor

    Local oColBVQ   := CenCltBVQ():New()
    Local cProcTime := Substr(Time(),1,2)+Substr(Time(),4,2)+Substr(Time(),7,2)
    //Chave primaria - BVQ_FILIAL, BVQ_CODOPE, BVQ_NMGPRE, BVQ_CDOBRI, BVQ_ANO, BVQ_CDCOMP, BVQ_LOTE, BVQ_DTPRGU
    oColBVQ:SetValue("operatorRecord"      ,self:cCodOpe)    //BVQ_CODOPE
    oColBVQ:SetValue("providerFormNumber"  ,self:cNumGuiPre) //BVQ_NMGPRE
    oColBVQ:SetValue("requirementCode"     ,self:cCodObrig)  //BVQ_CDOBRI
    oColBVQ:SetValue("referenceYear"       ,self:cAno)       //BVQ_ANO
    oColBVQ:SetValue("commitmentCode"      ,self:cMes)       //BVQ_CDCOMP
    oColBVQ:SetValue("batchCode"           ,self:cLote)      //BVQ_LOTE
    oColBVQ:SetValue("formProcDt"          ,self:dProcGuia)  //BVQ_DTPRGU

    oColBVQ:SetValue("status"              ,self:cStatus)     //BVQ_STATUS
    oColBVQ:SetValue("monitoringRecordType",self:cTipRegist ) //BVQ_TPRGMN
    oColBVQ:SetValue("processingTime"      ,cProcTime)        //BKR_HORPRO
    oColBVQ:SetValue("processingDate"      ,Dtos(dDataBase))  //BKR_DATPRO
    oColBVQ:SetValue("registration"        ,oAuxCab:GetValue("registration"))
    oColBVQ:SetValue("inclusionDate"       ,oAuxCab:GetValue("inclusionDate"))
    oColBVQ:SetValue("inclusionTime"       ,oAuxCab:GetValue("inclusionTime"))
    //Totalizadores
    oColBVQ:SetValue("coPaymentTotalValue" ,oTotaliz:GetValue("nVLTCOP"))
    oColBVQ:SetValue("valuePaidForm"       ,oTotaliz:GetValue("nVLTGUI"))
    oColBVQ:SetValue("ownTableTotalValue"  ,oTotaliz:GetValue("nVLTTBP"))

    oColBVQ:insert()
    oColBVQ:destroy()
    FreeObj(oColBVQ)
    oColBVQ := nil

Return


//------------------------------------------------------------------------------------------
/*/{Protheus.doc} grvMovBVT
    Grava a movimentacao da BVT

    @type  Class
    @author renan.almeida
    @since 20190320
/*/
//------------------------------------------------------------------------------------------
Method grvMovBVT(oAuxEve) Class CenPrMoFor

    Local oColBVT := CenCltBVT():New()

    //Chave Primaria: BVT_FILIAL, BVT_CODOPE, BVT_NMGPRE, BVT_CDOBRI, BVT_ANO, BVT_CDCOMP, BVT_LOTE, BVT_DTPRGU, BVT_CODTAB, BVT_CODGRU, BVT_CODPRO
    oColBVT:SetValue("operatorRecord"    ,self:cCodOpe)    //BVT_CODOPE
    oColBVT:SetValue("providerFormNumber",self:cNumGuiPre) //BVT_NMGPRE
    oColBVT:SetValue("requirementCode"   ,self:cCodObrig)  //BVT_CDOBRI
    oColBVT:SetValue("referenceYear"     ,self:cAno)       //BVT_ANO
    oColBVT:SetValue("commitmentCode"    ,self:cMes)       //BKR_CDCOMP
    oColBVT:SetValue("batchCode"         ,self:cLote)      //BVT_LOTE
    oColBVT:SetValue("formProcDt"        ,self:dProcGuia)  //BVT_DTPRGU
    oColBVT:SetValue("procedureGroup"    ,oAuxEve:GetValue("procedureGroup")) //BVT_CODGRU
    oColBVT:SetValue("tableCode"         ,oAuxEve:GetValue("tableCode"))      //BVT_CODTAB
    oColBVT:SetValue("procedureCode"     ,oAuxEve:GetValue("procedureCode"))  //BVT_CODPRO
    oColBVT:SetValue("status"            ,self:cStatus)

    oColBVT:SetValue("enteredQuantity"   ,oAuxEve:GetValue("enteredQuantity"))    //BVT_QTDINF
    oColBVT:SetValue("procedureValuePaid",oAuxEve:GetValue("procedureValuePaid")) //BVT_VLPGPR
    oColBVT:SetValue("coPaymentValue"    ,oAuxEve:GetValue("coPaymentValue"))     //BVT_VLRCOP

    //Commit dos itens
    oColBVT:insert()
    oColBVT:destroy()
    FreeObj(oColBVT)
    oColBVT := nil

Return


//------------------------------------------------------------------------------------------
/*/{Protheus.doc} procExclus
    Processa a exclusao de uma transacao

    @type  Class
    @author renan.almeida
    @since 20190320
/*/
//------------------------------------------------------------------------------------------
Method excTransac() Class CenPrMoFor

    Local oColBVQ := CenCltBVQ():New()
    Local oObjBVQ := nil

    oColBVQ:SetValue("operatorRecord"    ,self:cCodOpe)
    oColBVQ:SetValue("providerFormNumber",self:cNumGuiPre)
    oColBVQ:SetValue("requirementCode"   ,self:cCodObrig)
    oColBVQ:SetValue("formProcDt"        ,self:dProcGuia)

    if oColBVQ:bscMovExcl()

        //while oColBVQ:HasNext()
        oObjBVQ := oColBVQ:GetNext()

        //So processarei se a ultima transacao nao for uma Exclusao
        if oObjBVQ:getValue("monitoringRecordType") <> idTraExc

            //Verifico o status, se nao foi enviada para a ANS, excluo a transacao
            if oObjBVQ:getValue("status") $ "1/2/3/7" //1=Pendente Envio;2=Criticado;3=Pronto para o Envio;4=Em processamento ANS;5=Criticado pela ANS;6=Finalizado

                self:delMovBVQ(oObjBVQ)
                self:delMovBVT(oObjBVQ)

                //Ja foi enviado para ANS, devo gerar uma transacao de exclusao
            elseIf oObjBVQ:getValue("status") $ "4/6/8"
                self:gerTraExc(oObjBVQ) //Gera a transacao de exclusao
            endif
            //Refaz o historico da guia
            //self:proRestHis()

        endIf
        oObjBVQ:destroy()
        FreeObj(oObjBVQ)
        oObjBVQ := nil
        //endDo
    endIf
    oColBVQ:destroy()
    FreeObj(oObjBVQ)
    oObjBVQ := nil

Return


//------------------------------------------------------------------------------------------
/*/{Protheus.doc} gerTraExc
    Gera uma transacao de exclusao

    @type  Class
    @author renan.almeida
    @since 20190320
/*/
//------------------------------------------------------------------------------------------
Method gerTraExc(oAuxBVQ) Class CenPrMoFor

    Local oColBVT   := nil
    Local oAux      := nil

    //Padrao para exclusao e gerar na proxima competencia
    self:comAltExc(oAuxBVQ)
    //---------------------------------------------------------
    //              Gravacao de Cabecalho
    //---------------------------------------------------------
    self:cTipRegist := idTraExc
    oCalTot := CenMoTotGu():New() //Objeto para totalizadores do cabecalho
    oCalTot:carForDir(oAuxBVQ)

    self:grvMovBVQ(oAuxBVQ,oCalTot) //Grava movimentacao - cabecalho
    oCalTot:destroy()
    FreeObj(oCalTot)
    oCalTot := nil

    //---------------------------------------------------------
    //              Gravacao de Eventos
    //---------------------------------------------------------
    oColBVT := CenCltBVT():New()
    oColBVT:SetValue("operatorRecord"    ,oAuxBVQ:getValue("operatorRecord"))
    oColBVT:SetValue("providerFormNumber",oAuxBVQ:getValue("providerFormNumber"))
    oColBVT:SetValue("requirementCode"   ,oAuxBVQ:getValue("requirementCode"))
    oColBVT:SetValue("referenceYear"     ,oAuxBVQ:getValue("referenceYear"))
    oColBVT:SetValue("commitmentCode"    ,oAuxBVQ:getValue("commitmentCode"))
    oColBVT:SetValue("batchCode"         ,oAuxBVQ:getValue("batchCode"))
    oColBVT:SetValue("formProcDt"        ,oAuxBVQ:getValue("formProcDt"))

    if oColBVT:buscar()
        while oColBVT:HasNext()
            oAux := oColBVT:GetNext()
            self:grvMovBVT(oAux) //Grava movimentacao - eventos
            oAux:destroy()
        endDo
        oAux:destroy()
        FreeObj(oAux)
        oAux := nil
    endIf
    oColBVT:destroy()
    FreeObj(oColBVT)
    oColBVT := nil

Return


//------------------------------------------------------------------------------------------
/*/{Protheus.doc} delMovBVQ
    Deleta os eventos BVQ de uma movimentacao pendente

    @type  Class
    @author renan.almeida
    @since 20190320
/*/
//------------------------------------------------------------------------------------------
Method delMovBVQ(oAuxBVQ) Class CenPrMoFor

    Local oCltBVQ := CenCltBVQ():New()
    Local oObjDel := nil
    Local oAux    := nil

    oCltBVQ:SetValue("operatorRecord"    ,oAuxBVQ:getValue("operatorRecord"))     //BVQ_CODOPE
    oCltBVQ:SetValue("providerFormNumber",oAuxBVQ:getValue("providerFormNumber")) //BVQ_NMGPRE
    oCltBVQ:SetValue("requirementCode"   ,oAuxBVQ:getValue("requirementCode"))    //BVQ_CDOBRI
    oCltBVQ:SetValue("referenceYear"     ,oAuxBVQ:getValue("referenceYear"))      //BVQ_ANO
    oCltBVQ:SetValue("commitmentCode"    ,oAuxBVQ:getValue("commitmentCode"))     //BVQ_CDCOMP
    oCltBVQ:SetValue("batchCode"         ,oAuxBVQ:getValue("batchCode"))          //BVQ_LOTE
    oCltBVQ:SetValue("formProcDt"        ,oAuxBVQ:getValue("formProcDt"))         //BVQ_DTPRGU

    if oCltBVQ:buscar()

        while oCltBVQ:HasNext()

            oAux := oCltBVQ:GetNext()
            //Chave primaria - BVQ_FILIAL, BVQ_CODOPE, BVQ_NMGPRE, BVQ_CDOBRI, BVQ_ANO, BVQ_CDCOMP, BVQ_LOTE, BVQ_DTPRGU
            oObjDel := CenCltBVQ():New()
            oObjDel:SetValue("operatorRecord"    ,oAux:getValue("operatorRecord"))     //BVQ_CODOPE
            oObjDel:SetValue("providerFormNumber",oAux:getValue("providerFormNumber")) //BVQ_NMGPRE
            oObjDel:SetValue("requirementCode"   ,oAux:getValue("requirementCode"))    //BVQ_CDOBRI
            oObjDel:SetValue("referenceYear"     ,oAux:getValue("referenceYear"))      //BVQ_ANO
            oObjDel:SetValue("commitmentCode"    ,oAux:getValue("commitmentCode"))     //BVQ_CDCOMP
            oObjDel:SetValue("batchCode"         ,oAux:getValue("batchCode"))          //BVQ_LOTE
            oObjDel:SetValue("formProcDt"        ,oAux:getValue("formProcDt"))         //BVQ_DTPRGU

            oObjDel:delete()
            oObjDel:destroy()
            oAux:destroy()
            FreeObj(oObjDel)
            FreeObj(oAux)
            oObjDel := nil
            oAux := nil

        endDo

    endIf
    oCltBVQ:destroy()
    FreeObj(oCltBVQ)
    oCltBVQ := nil

Return

//------------------------------------------------------------------------------------------
/*/{Protheus.doc} delMovBVT
    Deleta os eventos BVT de uma movimentacao pendente

    @type  Class
    @author renan.almeida
    @since 20190320
/*/
//------------------------------------------------------------------------------------------
Method delMovBVT(oAuxBVQ) Class CenPrMoFor

    Local oCltBVT := CenCltBVT():New()
    Local oObjDel := nil
    Local oAux    := nil

    oCltBVT:SetValue("operatorRecord"    ,oAuxBVQ:getValue("operatorRecord"))     //BVT_CODOPE
    oCltBVT:SetValue("providerFormNumber",oAuxBVQ:getValue("providerFormNumber")) //BVT_NMGPRE
    oCltBVT:SetValue("requirementCode"   ,oAuxBVQ:getValue("requirementCode"))    //BVT_CDOBRI
    oCltBVT:SetValue("referenceYear"     ,oAuxBVQ:getValue("referenceYear"))      //BVT_ANO
    oCltBVT:SetValue("commitmentCode"    ,oAuxBVQ:getValue("commitmentCode"))     //BVT_CDCOMP
    oCltBVT:SetValue("batchCode"         ,oAuxBVQ:getValue("batchCode"))          //BVT_LOTE
    oCltBVT:SetValue("formProcDt"        ,oAuxBVQ:getValue("formProcDt"))         //BVT_DTPRGU

    if oCltBVT:buscar()

        while oCltBVT:HasNext()

            oAux := oCltBVT:GetNext()
            //Chave primaria - BVT_FILIAL, BVT_CODOPE, BVT_NMGPRE, BVT_CDOBRI, BVT_ANO, BVT_CDCOMP, BVT_LOTE, BVT_DTPRGU, BVT_CODTAB, BVT_CODGRU, BVT_CODPRO
            oObjDel := CenCltBVT():New()
            oObjDel:SetValue("operatorRecord"    ,oAux:getValue("operatorRecord"))     //BVT_CODOPE
            oObjDel:SetValue("providerFormNumber",oAux:getValue("providerFormNumber")) //BVT_NMGPRE
            oObjDel:SetValue("requirementCode"   ,oAux:getValue("requirementCode"))    //BVT_CDOBRI
            oObjDel:SetValue("referenceYear"     ,oAux:getValue("referenceYear"))      //BVT_ANO
            oObjDel:SetValue("commitmentCode"    ,oAux:getValue("commitmentCode"))     //BVT_CDCOMP
            oObjDel:SetValue("batchCode"         ,oAux:getValue("batchCode"))          //BVT_LOTE
            oObjDel:SetValue("formProcDt"        ,oAux:getValue("formProcDt"))         //BVT_DTPRGU
            oObjDel:SetValue("procedureGroup"    ,oAux:getValue("procedureGroup"))     //BVT_CODGRU
            oObjDel:SetValue("tableCode"         ,oAux:getValue("tableCode"))          //BVT_CODTAB
            oObjDel:SetValue("procedureCode"     ,oAux:getValue("procedureCode"))      //BVT_CODPRO

            oObjDel:delete()
            oObjDel:destroy()
            oAux:destroy()
            FreeObj(oObjDel)
            FreeObj(oAux)
            oObjDel := nil
            oAux := nil

        endDo

    endIf
    oCltBVT:destroy()
    FreeObj(oCltBVT)
    oCltBVT := nil

Return



//------------------------------------------------------------------------------------------
/*/{Protheus.doc} atuProcAPI
    Marca a guia como processada no Alais da API BW8

    @type  Class
    @author renan.almeida
    @since 20190320
/*/
//------------------------------------------------------------------------------------------
Method atuProcAPI() Class CenPrMoFor

    Local oCltBW8 := CenCltBW8():New()

    oCltBW8:SetValue("operatorRecord",self:cCodOpe)
    oCltBW8:SetValue("formSequential",self:cSeqGui)

    if oCltBW8:bscChaPrim()
        oCltBW8:mapFromDao()
        oCltBW8:SetValue("processed","1")
        oCltBW8:update()
    endIf
    oCltBW8:destroy()
    FreeObj(oCltBW8)
    oCltBW8 := nil
Return