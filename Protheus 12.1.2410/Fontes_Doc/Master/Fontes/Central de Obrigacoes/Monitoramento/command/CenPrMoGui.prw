#include "TOTVS.CH"
#define idTraInc  "1"
#define idTraAlt  "2"
#define idTraExc  "3"

#define idExcGuia "1"
#define idExcTran "2"

#define idCritica "3"

#define _CriMon104 {"M104","Os eventos da movimentacao processada são divergentes de uma transação já comunicada com a ANS.","Solicite o reenvio da movimentações com os itens corretos ou a solicitação de exclusão da transação já processada."}
#define ARQUIVO_LOG	"logs_gerais_monitoramento"

//------------------------------------------------------------------------------------------
/*/{Protheus.doc} CenPrMoGui
    Classe abstrata para execução de comandos
    @type  Class
    @author renan.almeida
    @since 20190320
/*/
//------------------------------------------------------------------------------------------
Class CenPrMoGui From CenProcMon

    Method New() Constructor
    Method proGuiaAPI()
    Method atuProcAPI()
    //Metodos de inclusao
    Method procInclus(oAuxCab)
    Method vldItJaEnv(oColBRB,oColBRG)
    Method verTraPend(oAuxCab)
    Method verTraProc(oAuxCab)
    Method verAjuPag(oAuxCab)
    Method comparCab(oAuxCab,oAuxBRF,aFields)
    Method compAPIHis(oAuxCa)
    //Metodos de commit de dados
    Method grvMovBKR(oAuxCab,oTotaliz)
    Method grvMovBKS(oAuxEve,cTipEve)
    Method grvMovBKT(oAuxEve,cCodTab,cCodPro)
    Method grvMovBN0(oAuxDec)
    Method grvHisBRF(oAuxCab,oTotaliz)
    Method grvHisBRG(oAuxEve,cTipEve)
    Method grvHisBRH(oAuxEve,cCodTab,cCodPro)
    Method grvHisBNY(oAuxDec)
    //Metodos de historico
    Method proRestHis()
    Method verTemHis()
    //Metodos de exclusao
    Method excGuia()
    Method excTransac()
    Method gerTraExc(oObjBKR)
    Method restUltSta(oObjBKR,lRecalcPag,aTransExc)
    //Exclucao Movimentacao
    Method delMovBKR(oObjBKR)
    Method delMovBKS(oObjBKR)
    Method delMovBKT(oObjBKR)
    Method delMovBN0(oObjBKR)
    //Exclusao historico
    Method delMovBRF(oObjBRF)
    Method delMovBRG(oObjBRF)
    Method delMovBRH(oObjBRF)
    Method delMovBNY(oObjBRF)

EndClass


//------------------------------------------------------------------------------------------
/*/{Protheus.doc} New
    Metodo construtor da classe proGuiaAPI
    @type  Class
    @author renan.almeida
    @since 20190320
/*/
//------------------------------------------------------------------------------------------
Method New() Class CenPrMoGui

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
Method proGuiaAPI(oAuxCab) Class CenPrMoGui

    Local oColBRA := nil
    Default oAuxCab := nil

    self:lOkProces := .T.

    If oAuxCab == nil
        oColBRA := CenCltBRA():New()
        oColBRA:SetValue("operatorRecord",self:cCodOpe)
        oColBRA:SetValue("formSequential",self:cSeqGui)
        oColBRA:SetValue("processed","0")
        if oColBRA:bscChaPrim()
            oAuxCab := oColBRA:GetNext() //Carrega cabecalho API
        EndIf
    EndIf

    If oAuxCab != nil
        self:loadChave(oAuxCab)

        //Processa Exclusao
        if oAuxCab:getValue("exclusionId") == idExcGuia //Exclusao de Guia
            self:excGuia()
        elseIf oAuxCab:getValue("exclusionId") == idExcTran //Exclusao de Transacao
            self:excTransac()

            // Inclusao/Alteracao
        else
            //Verifica se tem transacao pendente nao enviada ja gravada
            self:verTraPend(oAuxCab)
            //Verifica se ja tem os itens do historico sao os mesmos enviados
            if self:lOkProces
                self:compAPIHis(oAuxCab)
            endIf
            //Verifica se a transacao ja tem um registro processado
            if self:lOkProces
                self:verTraProc(oAuxCab)
            endIf
            //Verifica se ja tem pagamento realizado
            if self:lOkProces
                self:verAjuPag(oAuxCab)
            endIf
            //Processa uma inclusao
            if self:lOkProces
                self:procInclus(oAuxCab)
            endIf
        endIf
        self:atuProcAPI() //Atualiza registro na BRA como processado

    endIf

    If oColBRA != nil
        oColBRA:destroy()
        FreeObj(oColBRA)
        oColBRA := nil
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
Method verTraPend(oAuxCab) Class CenPrMoGui

    Local oColBKR := CenCltBKR():New()
    Local oObjBKR := nil

    oColBKR:SetValue("operatorRecord"     ,self:cCodOpe)
    oColBKR:SetValue("operatorFormNumber" ,self:cNumGuiOpe)
    oColBKR:SetValue("requirementCode"    ,self:cCodObrig)
    oColBKR:SetValue("referenceYear"      ,self:cAno)
    oColBKR:SetValue("commitmentCode"     ,self:cMes)

    if oColBKR:bscMovPend() //Busca transacoes pendentes com o Status: 1=Pendente Envio;2=Criticado;3=Pronto para o Envio

        while oColBKR:HasNext() //Coloquei um While, mas teoricamente so tera um registro

            oObjBKR := oColBKR:GetNext()
            //Se a data de inclusao do registro ja processado é inferior a que estou processando no momento,
            //excluo o registro existente para criar um novo registro atualizado
            if (oObjBKR:getValue("inclusionDate") <  oAuxCab:getValue("inclusionDate")) .Or. ;
                    (oObjBKR:getValue("inclusionDate") == oAuxCab:getValue("inclusionDate") .And. ;
                    oObjBKR:getValue("inclusionTime") <  oAuxCab:getValue("inclusionTime"))

                self:delMovB3F(oObjBKR,"BKR",BKR->(Recno()))
                self:delMovBKR(oObjBKR)
                self:delMovBKS(oObjBKR)
                self:delMovBKT(oObjBKR)
                self:delMovBN0(oObjBKR)

                //Verifico se preciso restaurar o historico
                self:proRestHis()

                //Se a transacao que estou processando for mais velha que o registro ja criado, ignoro a transacao
            else
                self:lOkProces := .F.
            endIf
            oObjBKR:destroy()
        endDo

    endIf
    oColBKR:destroy()

Return

//------------------------------------------------------------------------------------------
/*/{Protheus.doc} proRestHis
    Processa a restauracao do historico da guia

    @type  Class
    @author renan.almeida
    @since 20190320
/*/
//------------------------------------------------------------------------------------------
Method proRestHis() Class CenPrMoGui

    Local oColExiBKR := CenCltBKR():New()
    Local oColBRF    := nil
    Local oCoLastBKR := nil
    Local lExistBKR  := .F.
    Local aTransExc  := {}
    Local lRecalcPag := .F.

    //Primeiro passo: verifico se tem registro de movimentacao
    oColExiBKR:SetValue("operatorRecord"     ,self:cCodOpe)
    oColExiBKR:SetValue("operatorFormNumber" ,self:cNumGuiOpe)
    lExistBKR := oColExiBKR:buscar()
    oColExiBKR:destroy()
    FreeObj(oColExiBKR)
    oColExiBKR := nil

    //Existe movimentacao
    if lExistBKR
        //Vamos verificar se preciso realizar o ajuste de pagamentos,
        //devo ignorar as transacoes excluidas
        oColExcBKR := CenCltBKR():New()
        oColExcBKR:SetValue("operatorRecord"      ,self:cCodOpe)
        oColExcBKR:SetValue("operatorFormNumber"  ,self:cNumGuiOpe)
        oColExcBKR:SetValue("requirementCode"     ,self:cCodObrig)
        oColExcBKR:SetValue("monitoringRecordType","3")
        if oColExcBKR:buscar()
            while oColExcBKR:HasNext()
                oObjExcBKR := oColExcBKR:GetNext()
                aadd(aTransExc,oObjExcBKR:GetValue("formProcDt"))
                oObjExcBKR:destroy()
                FreeObj(oObjExcBKR)
                oObjExcBKR := nil
            endDo
        endIf
        oColExcBKR:destroy()
        FreeObj(oColExcBKR)
        oColExcBKR := nil

        //Verifico se ha pelo menos duas transacoes com pagamento
        //se houver, preciso refazer o calculo dos valores
        //para gravar o historico
        oColPagBKR := CenCltBKR():New()
        oColPagBKR:SetValue("operatorRecord"     ,self:cCodOpe)
        oColPagBKR:SetValue("operatorFormNumber" ,self:cNumGuiOpe)
        oColPagBKR:SetValue("requirementCode"    ,self:cCodObrig)
        lRecalcPag := oColPagBKR:bscQtdPag(aTransExc)
        oColPagBKR:destroy()
        FreeObj(oColPagBKR)
        oColPagBKR := nil

        //Busco a ultima movimentacao na BKR
        oCoLastBKR := CenCltBKR():New()
        oCoLastBKR:SetValue("operatorRecord"     ,self:cCodOpe)
        oCoLastBKR:SetValue("operatorFormNumber" ,self:cNumGuiOpe)
        oCoLastBKR:SetValue("requirementCode"    ,self:cCodObrig)

        if oCoLastBKR:bscUltMov(aTransExc)
            oAuxBKR := oCoLastBKR:GetNext()
            self:restUltSta(oAuxBKR,lRecalcPag,aTransExc)
            oAuxBKR:destroy()
            FreeObj(oAuxBKR)
            oAuxBKR := nil
        endIf
        oCoLastBKR:destroy()
        FreeObj(oCoLastBKR)
        oCoLastBKR := nil

        //Nao tem registro de movimentacao, devo deletar o historico
    else
        oColBRF := CenCltBRF():New()
        oColBRF:SetValue("operatorRecord"     ,self:cCodOpe)
        oColBRF:SetValue("operatorFormNumber" ,self:cNumGuiOpe)
        if oColBRF:bscChaPrim()
            oObjBRF := oColBRF:GetNext()
            self:delMovBRF(oObjBRF)
            self:delMovBRG(oObjBRF)
            self:delMovBRH(oObjBRF)
            self:delMovBNY(oObjBRF)
            oObjBRF:destroy()
            FreeObj(oObjBRF)
            oObjBRF := nil
        endIf
        oColBRF:destroy()
        FreeObj(oColBRF)
        oColBRF := nil
    endIf

Return


//------------------------------------------------------------------------------------------
/*/{Protheus.doc} verTraProc
    Verifica se tem uma guia ja processada e realiza a alteracao de dados

    @type  Class
    @author renan.almeida
    @since 20190320
/*/
//------------------------------------------------------------------------------------------
Method verTraProc(oAuxCab) Class CenPrMoGui

    Local oColBKR := CenCltBKR():New()
    Local oColBRF := nil
    Local oAux    := nil
    Local lUltExc := .F.

    oColBKR:SetValue("operatorRecord"     ,self:cCodOpe)
    oColBKR:SetValue("operatorFormNumber" ,self:cNumGuiOpe)
    oColBKR:SetValue("requirementCode"    ,self:cCodObrig)
    oColBKR:SetValue("referenceYear"      ,self:cAno)
    oColBKR:SetValue("commitmentCode"     ,self:cMes)
    oColBKR:SetValue("formProcDt"         ,self:dProcGuia)

    if oColBKR:bscMovProc() //Busca transacoes ja processadas com o Status: 4=Em processamento ANS;5=Criticado pela ANS;6=Finalizado

        //Verifica se a ultima movimentacao desta chave e uma exclusao
        oColExcBKR := CenCltBKR():New()
        oColExcBKR:SetValue("operatorRecord"     ,self:cCodOpe)
        oColExcBKR:SetValue("operatorFormNumber" ,self:cNumGuiOpe)
        oColExcBKR:SetValue("requirementCode"    ,self:cCodObrig)
        oColExcBKR:SetValue("formProcDt"         ,self:dProcGuia)

        if oColExcBKR:bscUltChv() .And. oColExcBKR:HasNext()
            oAux    := oColExcBKR:GetNext()
            lUltExc := iif(oAux:getValue("monitoringRecordType") == "3",.T.,.F.)
            oAux:destroy()
            FreeObj(oAux)
            oAux := Nil
        endIf
        oColExcBKR:destroy()
        FreeObj(oColExcBKR)
        oColExcBKR := Nil

        if !lUltExc
            //Monta objeto para comparar dados recebidos com o historico da guia
            oColBRF := CenCltBRF():New()
            oColBRF:SetValue("operatorRecord"     ,self:cCodOpe)    //BRF_CODOPE
            oColBRF:SetValue("operatorFormNumber" ,self:cNumGuiOpe) //BRF_NMGOPE

            if oColBRF:bscChaPrim()
                oAuxBRF := oColBRF:GetNext()
                self:comparCab(oAuxCab,oAuxBRF,oColBRF:oDao:getAFields()) //Compara cabecalhos para verificar se e uma alteracao
                //Ajusta a data de competencia
                if self:cTipRegist == "2"
                    self:comAltExc(oColBKR)
                endIf
                oAuxBRF:destroy()
                FreeObj(oAuxBRF)
                oAuxBRF := Nil
            endIf
            oColBRF:destroy()
            FreeObj(oColBRF)
            oColBRF := nil
        endIf

    endIf
    oColBKR:destroy()
    FreeObj(oColBKR)
    oColBKR := nil

Return


//------------------------------------------------------------------------------------------
/*/{Protheus.doc} comparCab
    Compara o cabecalho a movimentacao com o historico

    @type  Class
    @author renan.almeida
    @since 20190320
/*/
//------------------------------------------------------------------------------------------
Method comparCab(oAuxCab,oAuxBRF,aFields) Class CenPrMoGui

    Local nX         := 0
    Local cExcFields := ""
    Local lAltera    := .F.
    Local oCenlogger := CenLogger():New()

    cExcFields += "BRF_TPRGMN,BRF_VLTINF,BRF_VLTPRO,BRF_VLTPGP,BRF_VLTDIA,BRF_VLTTAX,BRF_VLTMAT,"
    cExcFields += "BRF_VLTOPM,BRF_VLTMED,BRF_VLTGLO,BRF_VLTGUI,BRF_VLTFOR,BRF_VLTTBP,BRF_VLTCOP,"
    cExcFields += "BRF_DTPROT"

    for nX := 1 to len(aFields)
        if !aFields[nX,1] $ cExcFields
            lAltera := oAuxCab:getValue(aFields[nX,2]) <> oAuxBRF:getValue(aFields[nX,2])
        endif
        if lAltera
            oCenlogger:SetFileName(ARQUIVO_LOG)
            oCenlogger:addLine("mensagem", "Compara o cabecalho a movimentacao com o historico")
            oCenlogger:addLine("observacao", aFields[nX,1])
            oCenlogger:addLog()
            exit
        endIf
    next

    iif(lAltera, self:cTipRegist:=idTraAlt, self:lOkProces:=.F.)

    oCenlogger:destroy()
    FreeObj(oCenlogger)
    oCenlogger := nil

Return


//------------------------------------------------------------------------------------------
/*/{Protheus.doc} verAjuPag
    Verifica se e um ajuste de pagamento

    @type  Class
    @author renan.almeida
    @since 20190320
/*/
//------------------------------------------------------------------------------------------
Method verAjuPag(oAuxCab) Class CenPrMoGui

    Local oColBRF := CenCltBRF():New()
    Local nVlrPag := 0
    Local nVlrGlo := 0
    Local nQtdPag := 0

    oColBRF:SetValue("operatorRecord"     ,self:cCodOpe)    //BRF_CODOPE
    oColBRF:SetValue("operatorFormNumber" ,self:cNumGuiOpe) //BRF_NMGOPE

    if oColBRF:bscChaPrim()

        oAuxBRF := oColBRF:GetNext()

        if !Empty(oAuxBRF:getValue("paymentDt")) .And. !Empty(oAuxCab:getValue("paymentDt"))

            //Verifica se ja tem uma movimentacao com a mesma data de
            //processamento. So posso realizar o ajuste de pagamento
            //se for uma data diferente
            oColBKR := CenCltBKR():New()
            oColBKR:SetValue("operatorRecord"     ,self:cCodOpe)
            oColBKR:SetValue("operatorFormNumber" ,self:cNumGuiOpe)
            oColBKR:SetValue("formProcDt"         ,self:dProcGuia)

            oColBRB := CenCltBRB():New()
            oColBRB:SetValue("operatorRecord",self:cCodOpe)
            oColBRB:SetValue("formSequential",self:cSeqGui)

            oColBRG := CenCltBRG():New()
            oColBRG:SetValue("operatorRecord"     ,self:cCodOpe) //BRG_CODOPE
            oColBRG:SetValue("operatorFormNumber" ,self:cNumGuiOpe) //BRG_NMGOPE

            //---------------------------------------------------------
            //              Gravacao de Eventos
            //---------------------------------------------------------
            if !oColBKR:buscar() .And. oColBRB:aglutEvent() .And. oColBRG:bscEveHist()

                oCalTotMov := CenMoTotGu():New() //Objeto para totalizadores do cabecalho de movimentacao
                oCalTotHis := CenMoTotGu():New() //Objeto para totalizadores do cabecalho de historico

                while oColBRB:HasNext() .And. oColBRG:HasNext()

                    nVlrPag := 0
                    nVlrGlo := 0
                    nQtdPag := 0
                    oAuxBRB := oColBRB:GetNext()
                    oAuxBRG := oColBRG:GetNext()

                    if oAuxBRB:getValue("tableCode") == oAuxBRG:getValue("tableCode") .And. ;
                            oAuxBRB:getValue("procedureCode") == oAuxBRG:getValue("procedureCode") .And. ;
                            oAuxBRB:getValue("procedureGroup") == oAuxBRG:getValue("procedureGroup") .And. ;
                            oAuxBRB:getValue("toothCode") == oAuxBRG:getValue("toothCode") .And. ;
                            oAuxBRB:getValue("toothFaceCode") == oAuxBRG:getValue("toothFaceCode") .And. ;
                            oAuxBRB:getValue("regionCode") == oAuxBRG:getValue("regionCode")

                        cTipEve   := oAuxBRG:getValue("eventType")
                        cIdPacote := oAuxBRG:getValue("package")
                        cCodTab   := oAuxBRG:getValue("tableCode")
                        cCodPro   := oAuxBRG:getValue("procedureCode")
                        cSequen   := oAuxBRB:getValue("sequence")
                        //Realiza a comparacao dos valores dos eventos
                        if oAuxBRB:getValue("procedureValuePaid") <> oAuxBRG:getValue("procedureValuePaid")
                            nVlrPag := oAuxBRB:getValue("procedureValuePaid") - oAuxBRG:getValue("procedureValuePaid")
                            nQtdPag := oAuxBRB:getValue("quantityPaid") - oAuxBRG:getValue("quantityPaid")
                        endIf

                        //Calcula cabecalho Historico
                        oCalTotHis:calGuiMon(oAuxBRB,cTipEve)
                        //Grava historico
                        self:grvHisBRG(oAuxBRB,cTipEve)

                        oAuxBRB:setValue("procedureValuePaid",nVlrPag)
                        if nQtdPag <> 0
                            oAuxBRB:setValue("quantityPaid",nQtdPag)
                        endIf

                        //Calcula cabecalho Movimentacao
                        oCalTotMov:calGuiMon(oAuxBRB,cTipEve)

                        //Grava movimentacao
                        if nVlrPag <> 0
                            self:grvMovBKS(oAuxBRB,cTipEve)
                        endIf

                        //---------------------------------------------------------
                        //              Gravacao de Pacotes
                        //---------------------------------------------------------
                        if cIdPacote == "1"

                            oColBRC := CenCltBRC():New() //Objeto de Apoio
                            oColBRC:SetValue("operatorRecord",self:cCodOpe)
                            oColBRC:SetValue("formSequential",self:cSeqgui)
                            oColBRC:SetValue("sequentialItem",cSequen)

                            if oColBRC:buscar()
                                while oColBRC:HasNext() //Carrega eventos BRB
                                    oAuxPac := oColBRC:GetNext()
                                    if nVlrPag <> 0
                                        self:grvMovBKT(oAuxPac,cCodTab,cCodPro) //Grava movimentacao - pacotes
                                    endif
                                    self:grvHisBRH(oAuxPac,cCodTab,cCodPro) //Grava historico - pacotes
                                    oAuxPac:destroy()
                                endDo
                            endIf
                            oColBRC:destroy()
                        endIf

                    endIf
                    oAuxBRB:destroy()
                    oAuxBRG:destroy()
                endDo

                //---------------------------------------------------------
                //              Gravacao de Cabecalhos
                //---------------------------------------------------------
                self:grvMovBKR(oAuxCab,oCalTotMov)
                oCalTotMov:destroy()

                self:grvHisBRF(oAuxCab,oCalTotHis)
                oCalTotHis:destroy()

                //---------------------------------------------------------
                //              Gravacao de Declaracoes
                //---------------------------------------------------------
                oColBNW  := CenCltBNW():New()
                oColBNW:setValue("operatorRecord",self:cCodOpe)
                oColBNW:setValue("formSequential",self:cSeqGui)

                if oColBNW:buscar()
                    while oColBNW:HasNext()
                        oAuxDec  := oColBNW:GetNext()
                        self:grvMovBN0(oAuxDec) //Grava movimentacao - declaracoes nascido/obito
                        self:grvHisBNY(oAuxDec) //Grava historico - declaracoes nascido/obito
                        oAuxDec:destroy()
                    endDo
                endIf
                oColBNW:destroy()
                self:lOkProces := .F. //Indico que nao preciso processar mais, ja gravei tudo

            endIf

            oColBRG:destroy()
            oColBRB:destroy()
            oColBKR:destroy()
            FreeObj(oColBRG)
            FreeObj(oColBRB)
            FreeObj(oColBKR)
            oColBRG := nil
            oColBRB := nil
            oColBKR := nil

        endIf
        oAuxBRF:destroy()
        FreeObj(oAuxBRF)
        oAuxBRF := nil

    endIf

    oColBRF:destroy()
    FreeObj(oColBRF)
    oColBRF := nil

Return

//------------------------------------------------------------------------------------------
/*/{Protheus.doc} compAPIHis
    Compara se o itens enviados na API sao os mesmos do historico

    @type  Class
    @author renan.almeida
    @since 20190320
/*/
//------------------------------------------------------------------------------------------
Method compAPIHis(oAuxCab) Class CenPrMoGui

    Local lExisHis := .F.
    Local oColBRF  := nil
    Local oColBRG  := nil
    //---------------------------------------------------------
    //              Verifica se tem historico da guia
    //---------------------------------------------------------
    if self:cTipRegist == idTraInc

        //Verifica se tem o registro nas tabelas de historico
        oColBRF  := CenCltBRF():New()
        oColBRF:SetValue("operatorRecord"     ,self:cCodOpe)    //BKS_CODOPE
        oColBRF:SetValue("operatorFormNumber" ,self:cNumGuiOpe) //BKS_NMGOPE
        if oColBRF:bscChaPrim()
            oColBRG := CenCltBRG():New()
            oColBRG:SetValue("operatorRecord"     ,self:cCodOpe)    //BKS_CODOPE
            oColBRG:SetValue("operatorFormNumber" ,self:cNumGuiOpe) //BKS_NMGOPE
            if oColBRG:bscEveHist()
                lExisHis := self:verTemHis()
            endIf
        endIf

        oColBRF:destroy()
        FreeObj(oColBRF)
        oColBRF := nil

        //Verifica se os itens sao os mesmos do historico
        if lExisHis

            //Busca Eventos
            oColBRB := CenCltBRB():New()
            oColBRB:SetValue("operatorRecord",self:cCodOpe)
            oColBRB:SetValue("formSequential",self:cSeqGui)

            //Verifica se os itens estao divergentes, caso estejam, gero aqui a guia criticada
            if oColBRB:aglutEvent() .And. !self:vldItJaEnv(oColBRB,oColBRG)

                //Restaura ponteiros
                oColBRB:goTop()

                self:lOkProces := .F. //Vou gravar por aqui a guia
                self:cStatus   := idCritica //Indicador de criticas

                oCalTotMov := CenMoTotGu():New() //Objeto para totalizadores do cabecalho movimentacao

                while oColBRB:HasNext()

                    lGrvEve   := .T. //Padrao e gravar o item
                    oAuxEve   := oColBRB:GetNext()

                    cCodTab   := oAuxEve:GetValue("tableCode")
                    cCodPro   := oAuxEve:GetValue("procedureCode")
                    cCodGru   := oAuxEve:GetValue("procedureGroup")
                    cCodDen   := oAuxEve:GetValue("toothCode")
                    cCodFac   := oAuxEve:GetValue("toothFaceCode")
                    cCodReg   := oAuxEve:GetValue("regionCode")

                    cTipEve   := self:getEveInfo(cCodTab,cCodPro,cCodGru)
                    cIdPacote := oAuxEve:GetValue("package")
                    cSequen   := oAuxEve:GetValue("sequence")

                    //Grava evento
                    self:grvMovBKS(oAuxEve,cTipEve)           //Grava movimentacao - eventos
                    oCalTotMov:calGuiMon(oAuxEve,cTipEve)     //Calcula totalizadores movimentacao

                    oAuxEve:destroy()
                    FreeObj(oAuxEve)
                    oAuxEve := nil
                    //---------------------------------------------------------
                    //              Gravacao de Pacotes
                    //---------------------------------------------------------
                    if cIdPacote == "1"
                        oColBRC := CenCltBRC():New() //Objeto de Apoio
                        oColBRC:SetValue("operatorRecord",self:cCodOpe)
                        oColBRC:SetValue("formSequential",self:cSeqgui)
                        oColBRC:SetValue("sequentialItem",cSequen)

                        if oColBRC:buscar()
                            while oColBRC:HasNext() //Carrega eventos BRB
                                oAuxPac := oColBRC:GetNext()
                                self:grvMovBKT(oAuxPac,cCodTab,cCodPro) //Grava movimentacao - pacotes
                                oAuxPac:destroy()
                            endDo
                        endIf
                        oColBRC:destroy()
                        FreeObj(oColBRC)
                        oColBRC := nil
                    endIf
                endDo

                //---------------------------------------------------------
                //              Gravacao de Cabecalho
                //---------------------------------------------------------
                self:grvMovBKR(oAuxCab,oCalTotMov) //Grava movimentacao - cabecalho

                //Grava critica de itens divergentes
                oColCriBKR := CenCltBKR():New()
                oColCriBKR:SetValue("operatorRecord"     ,self:cCodOpe)    //BKR_CODOPE
                oColCriBKR:SetValue("operatorFormNumber" ,self:cNumGuiOpe) //BKR_NMGOPE
                oColCriBKR:SetValue("requirementCode"    ,self:cCodObrig)  //BKR_CDOBRI
                oColCriBKR:SetValue("referenceYear"      ,self:cAno)       //BKR_ANO
                oColCriBKR:SetValue("commitmentCode"     ,self:cMes)       //BKR_CDCOMP
                oColCriBKR:SetValue("batchCode"          ,self:cLote)      //BKR_LOTE
                oColCriBKR:SetValue("formProcDt"         ,self:dProcGuia)  //BKR_DTPRGU
                if oColCriBKR:bscChaPrim()
                    oAuxDelCri := oColCriBKR:GetNext() //Carrega cabecalho API
                    self:grvCritica("BKR",;
                        cValtoChar(BKR->(Recno())),;
                        _CriMon104[1],;
                        _CriMon104[2],;
                        _CriMon104[3])
                    oAuxDelCri:destroy()
                    FreeObj(oAuxDelCri)
                    oAuxDelCri := nil
                endIf
                oColCriBKR:destroy()
                // Retirando devido a problemática de enviar 2 guias para processamento.
                // oAuxCab:destroy()
                //FreeObj(oAuxCab)
                //oAuxCab := nil

                //---------------------------------------------------------
                //              Gravacao de Declaracoes
                //---------------------------------------------------------
                oColBNW  := CenCltBNW():New()
                oColBNW:setValue("operatorRecord",self:cCodOpe)
                oColBNW:setValue("formSequential",self:cSeqGui)
                if oColBNW:buscar()
                    while oColBNW:HasNext()
                        oAuxDec  := oColBNW:GetNext()
                        self:grvMovBN0(oAuxDec) //Grava movimentacao - declaracoes nascido/obito
                        self:grvHisBNY(oAuxDec) //Grava historico - declaracoes nascido/obito
                        oAuxDec:destroy()
                        FreeObj(oAuxDec)
                        oAuxDec := nil
                    endDo
                endIf
                oColBNW:destroy()
                oCalTotMov:destroy()
                FreeObj(oColBNW)
                FreeObj(oCalTotMov)
                oColBNW := nil
                oCalTotMov := nil
            endIf
            oColBRB:destroy()
            FreeObj(oColBRB)
            oColBRB := nil
        endIf
    endIf

    if oColBRG != nil
        oColBRG:destroy()
        FreeObj(oColBRG)
        oColBRG := nil
    EndIf

Return


//------------------------------------------------------------------------------------------
/*/{Protheus.doc} procInclus
    Grava registros de movimentacao

    @type  Class
    @author renan.almeida
    @since 20190320
/*/
//------------------------------------------------------------------------------------------
Method procInclus(oAuxCab) Class CenPrMoGui

    Local oColBRB    := nil
    Local oColBRC    := nil
    Local oColBNW    := nil
    Local oColBRF    := nil
    Local lExisHis   := .F.
    Local lGrvEve    := .F.
    Local lUmItemGrv := .F.
    Local cCodTab    := ""
    Local cCodPro    := ""
    Local cCodGru    := ""
    Local cTipEve    := ""
    Local cSequen    := ""
    Local cIdPacote  := "0"

    //---------------------------------------------------------
    //              Verifica se tem historico da guia
    //---------------------------------------------------------
    if self:cTipRegist == idTraInc
        //Verifica se tem o registro nas tabelas de historico
        oColBRF  := CenCltBRF():New()
        oColBRF:SetValue("operatorRecord"     ,self:cCodOpe)    //BKS_CODOPE
        oColBRF:SetValue("operatorFormNumber" ,self:cNumGuiOpe) //BKS_NMGOPE
        if oColBRF:bscChaPrim()
            oColBRG   := CenCltBRG():New()
            oColBRG:SetValue("operatorRecord"     ,self:cCodOpe)    //BKS_CODOPE
            oColBRG:SetValue("operatorFormNumber" ,self:cNumGuiOpe) //BKS_NMGOPE
            if oColBRG:bscEveHist()
                lExisHis := self:verTemHis()
            endIf
            oColBRG:getDao():fechaQuery()
        endIf
        oColBRF:destroy()
        FreeObj(oColBRF)
        oColBRF := nil

    endif
    //---------------------------------------------------------
    //              Gravacao de Eventos
    //---------------------------------------------------------
    oColBRB := CenCltBRB():New()
    oColBRB:SetValue("operatorRecord",self:cCodOpe)
    oColBRB:SetValue("formSequential",self:cSeqGui)

    //Aglutina eventos e realiza a gravacao deles
    if oColBRB:aglutEvent()

        oCalTotMov := CenMoTotGu():New() //Objeto para totalizadores do cabecalho movimentacao
        oCalTotHis := CenMoTotGu():New() //Objeto para totalizadores do cabecalho historico

        while oColBRB:HasNext()

            lGrvEve   := .T. //Padrao e gravar o item
            oAuxEve   := oColBRB:GetNext()

            cCodTab   := oAuxEve:GetValue("tableCode")
            cCodPro   := oAuxEve:GetValue("procedureCode")
            cCodGru   := oAuxEve:GetValue("procedureGroup")
            cCodDen   := oAuxEve:GetValue("toothCode")
            cCodFac   := oAuxEve:GetValue("toothFaceCode")
            cCodReg   := oAuxEve:GetValue("regionCode")

            cTipEve   := self:getEveInfo(cCodTab,cCodPro,cCodGru)
            cIdPacote := oAuxEve:GetValue("package")
            cSequen   := oAuxEve:GetValue("sequence")

            //Se tiver historico, monto objeto para verificar se houve alteracao
            //nos valores de pagamento ou glosa
            if lExisHis .And. oColBRG:HasNext()

                oAuxEveHis := oColBRG:GetNext()
                cCodTabHis := oAuxEveHis:GetValue("tableCode")
                cCodProHis := oAuxEveHis:GetValue("procedureCode")
                cCodGruHis := oAuxEveHis:GetValue("procedureGroup")
                cCodDenHis := oAuxEveHis:GetValue("toothCode")
                cCodFacHis := oAuxEveHis:GetValue("toothFaceCode")
                cCodRegHis := oAuxEveHis:GetValue("regionCode")

                if cCodTab == cCodTabHis .And. cCodPro == cCodProHis .And. cCodGru == cCodGruHis .And. ;
                        cCodDen == cCodDenHis .And. cCodFac == cCodFacHis .And. cCodReg == cCodRegHis

                    lGrvEve := .F. //Tenho item no historico, vou setar .F.

                    if oAuxEve:GetValue("procedureValuePaid")  <> oAuxEveHis:GetValue("procedureValuePaid") .Or. ;
                            oAuxEve:GetValue("coPaymentValue")    <> oAuxEveHis:GetValue("coPaymentValue")     .Or. ;
                            oAuxEve:GetValue("disallVl")          <> oAuxEveHis:GetValue("disallVl")           .Or. ;
                            oAuxEve:GetValue("valueEntered")      <> oAuxEveHis:GetValue("valueEntered")       .Or. ;
                            oAuxEve:GetValue("valuePaidSupplier") <> oAuxEveHis:GetValue("valuePaidSupplier")

                        lGrvEve := .T. //Tem valores diferenciados, gravo o registro
                    endIf

                endIf
                oAuxEveHis:destroy()
                FreeObj(oAuxEveHis)
                oAuxEveHis := nil
            endIf


            oCalTotHis:calGuiMon(oAuxEve,cTipEve) //Calcula totalizadores historico
            self:grvHisBRG(oAuxEve,cTipEve) //Grava historico - eventos

            //Grava evento
            if lGrvEve
                self:grvMovBKS(oAuxEve,cTipEve)           //Grava movimentacao - eventos
                oCalTotMov:calGuiMon(oAuxEve,cTipEve)     //Calcula totalizadores movimentacao
                lUmItemGrv := .T.
            else
                oCalTotMov:calGuiMon(oAuxEve,cTipEve,.F.) //Calcula totalizadores movimentacao
            endif

            oAuxEve:destroy()
            FreeObj(oAuxEve)
            oAuxEve := nil

            //---------------------------------------------------------
            //              Gravacao de Pacotes
            //---------------------------------------------------------
            if cIdPacote == "1"
                oColBRC := CenCltBRC():New() //Objeto de Apoio
                oColBRC:SetValue("operatorRecord",self:cCodOpe)
                oColBRC:SetValue("formSequential",self:cSeqgui)
                oColBRC:SetValue("sequentialItem",cSequen)

                if oColBRC:buscar()
                    while oColBRC:HasNext() //Carrega eventos BRB
                        oAuxPac := oColBRC:GetNext()
                        if lGrvEve
                            self:grvMovBKT(oAuxPac,cCodTab,cCodPro) //Grava movimentacao - pacotes
                        endIf
                        self:grvHisBRH(oAuxPac,cCodTab,cCodPro) //Grava historico - pacotes
                        oAuxPac:destroy()
                        FreeObj(oAuxPac)
                        oAuxPac := nil
                    endDo
                endIf
                oColBRC:destroy()
                FreeObj(oColBRC)
                oColBRC := nil
            endIf
        endDo

        // Se tem pelo menos um evento gravado, gero o Cabecalho e Declaracoes
        if lUmItemGrv
            //---------------------------------------------------------
            //              Gravacao de Cabecalho
            //---------------------------------------------------------
            self:grvMovBKR(oAuxCab,oCalTotMov) //Grava movimentacao - cabecalho
            self:grvHisBRF(oAuxCab,oCalTotHis) //Grava historico - cabecalho

            //---------------------------------------------------------
            //              Gravacao de Declaracoes
            //---------------------------------------------------------
            oColBNW  := CenCltBNW():New()
            oColBNW:setValue("operatorRecord",self:cCodOpe)
            oColBNW:setValue("formSequential",self:cSeqGui)

            if oColBNW:buscar()
                while oColBNW:HasNext()
                    oAuxDec  := oColBNW:GetNext()
                    self:grvMovBN0(oAuxDec) //Grava movimentacao - declaracoes nascido/obito
                    self:grvHisBNY(oAuxDec) //Grava historico - declaracoes nascido/obito
                    oAuxDec:destroy()
                    FreeObj(oAuxDec)
                    oAuxDec := nil
                endDo
            endIf
            oColBNW:destroy()
            FreeObj(oColBNW)
            oColBNW := nil
        endIf

        // Retirando devido a problemática de enviar 2 guias para processamento.
        // oAuxCab:destroy()
        oCalTotMov:destroy()
        oCalTotHis:destroy()
        //FreeObj(oAuxCab)
        FreeObj(oCalTotMov)
        FreeObj(oCalTotHis)
        //oAuxCab := nil
        oCalTotMov := nil
        oCalTotHis := nil

    endIf

    oColBRB:destroy()
    FreeObj(oColBRB)
    oColBRB := nil

Return


//------------------------------------------------------------------------------------------
/*/{Protheus.doc} verTemHis
    Verifica nas movimentacoes se ha historico valido para a guia
    no historico

    @type  Class
    @author renan.almeida
    @since 20190320
/*/
//------------------------------------------------------------------------------------------
Method verTemHis() Class CenPrMoGui

    Local oColBKR  := CenCltBKR():New()
    Local lExisHis := .T.
    Local aAuxExc  := {}
    Local aAuxMov  := {}
    Local nX       := 0

    //Verifica se os registros de movimentacao estao excluidos
    oColBKR:SetValue("operatorRecord"     ,self:cCodOpe)    //BKS_CODOPE
    oColBKR:SetValue("operatorFormNumber" ,self:cNumGuiOpe) //BKS_NMGOPE

    if oColBKR:buscar()
        while oColBKR:HasNext()
            oAux := oColBKR:GetNext()

            if oAux:getValue("monitoringRecordType") == "3"
                aadd(aAuxExc,{oAux:getValue("formProcDt"),oAux:getValue("processingDate"),oAux:getValue("processingTime")})
            else
                aadd(aAuxMov,{oAux:getValue("formProcDt"),oAux:getValue("processingDate"),oAux:getValue("processingTime")})
            endIf
            oAux:destroy()
        endDo
    endIf
    oColBKR:destroy()

    //Se tem exclusao, preciso rodar pra ver se todas as transacoes estao excluidas
    if len(aAuxExc) > 0
        lExisHis := .F.
        for nX := 1 to len(aAuxMov)
            if (nPos := Ascan(aAuxExc,{|x| x[1] == aAuxMov[nX,1]}) ) > 0
                if aAuxMov[nX,2] > aAuxExc[nPos,2] .Or. ;
                        (aAuxMov[nX,2] == aAuxExc[nPos,2] .And. aAuxMov[nX,3] > aAuxExc[nPos,3])
                    lExisHis := .T. //A data da inclusao/alteracao e superior a data da exclusao (tem historico valido)
                    exit
                endIf
            else
                lExisHis := .T. //Nao tem exclusao, entao pelo menos tenho uma transacao valida (tem historico valido)
                exit
            endIf
        next
    endIf

Return lExisHis



//------------------------------------------------------------------------------------------
/*/{Protheus.doc} vldItJaEnv
    Verifica se os itens recebidos sao os mesmo ja enviados gravados
    no historico

    @type  Class
    @author renan.almeida
    @since 20190320
/*/
//------------------------------------------------------------------------------------------
Method vldItJaEnv(oColBRB,oColBRG) Class CenPrMoGui

    Local lRet    := .T.
    Local lTemBRB := .F.
    Local lTemBRG := .F.

    lTemBRB := oColBRB:HasNext()
    lTemBRG := oColBRG:HasNext()

    while lTemBRB .And. lTemBRG

        oAuxEve   := oColBRB:GetNext()
        cCodTab   := oAuxEve:GetValue("tableCode")
        cCodPro   := oAuxEve:GetValue("procedureCode")
        cCodGru   := oAuxEve:GetValue("procedureGroup")
        cCodDen   := oAuxEve:GetValue("toothCode")
        cCodFac   := oAuxEve:GetValue("toothFaceCode")
        cCodReg   := oAuxEve:GetValue("regionCode")

        oAuxEveHis := oColBRG:GetNext()
        cCodTabHis := oAuxEveHis:GetValue("tableCode")
        cCodProHis := oAuxEveHis:GetValue("procedureCode")
        cCodGruHis := oAuxEveHis:GetValue("procedureGroup")
        cCodDenHis := oAuxEveHis:GetValue("toothCode")
        cCodFacHis := oAuxEveHis:GetValue("toothFaceCode")
        cCodRegHis := oAuxEveHis:GetValue("regionCode")

        if !(cCodTab == cCodTabHis .And. cCodPro == cCodProHis .And. cCodGru == cCodGruHis .And. ;
                cCodDen == cCodDenHis .And. cCodFac == cCodFacHis .And. cCodReg == cCodRegHis)

            lRet    := .F.
            lTemBRB := .F.
            lTemBRG := .F.
        endIf

        if lRet
            lTemBRB := oColBRB:HasNext()
            lTemBRG := oColBRG:HasNext()
        endIf

        oAuxEve:destroy()
        oAuxEveHis:destroy()

    endDo

    //Se algum Alias tiver itens a mais, critico
    if (lTemBRB .And. !lTemBRG) .Or. (!lTemBRB .And. lTemBRG)
        lRet := .F.
    endIf

Return lRet


//------------------------------------------------------------------------------------------
/*/{Protheus.doc} grvMovBKS
    Grava a movimentacao da BKS

    @type  Class
    @author renan.almeida
    @since 20190320
/*/
//------------------------------------------------------------------------------------------
Method grvMovBKS(oAuxEve,cTipEve) Class CenPrMoGui

    Local oColBKS := CenCltBKS():New()

    //Chave Primaria: BKS_FILIAL, BKS_CODOPE, BKS_NMGOPE, BKS_CDOBRI, BKS_ANO, BKS_CDCOMP, BKS_LOTE, BKS_DTPRGU, BKS_CODGRU, BKS_CODTAB, BKS_CODPRO, BKS_CDDENT, BKS_CDREGI, BKS_CDFACE
    oColBKS:SetValue("operatorRecord"        ,self:cCodOpe)    //BKS_CODOPE
    oColBKS:SetValue("operatorFormNumber"    ,self:cNumGuiOpe) //BKS_NMGOPE
    oColBKS:SetValue("requirementCode"       ,self:cCodObrig)  //BKS_CDOBRI
    oColBKS:SetValue("referenceYear"         ,self:cAno)       //BKS_ANO
    oColBKS:SetValue("commitmentCode"        ,self:cMes)       //BKR_CDCOMP
    oColBKS:SetValue("batchCode"             ,self:cLote)      //BKS_LOTE
    oColBKS:SetValue("formProcDt"            ,self:dProcGuia)  //BKS_DTPRGU
    oColBKS:SetValue("procedureGroup"        ,oAuxEve:GetValue("procedureGroup"))  //BKS_CODGRU
    oColBKS:SetValue("tableCode"             ,oAuxEve:GetValue("tableCode"))      //BKS_CODTAB
    oColBKS:SetValue("procedureCode"         ,oAuxEve:GetValue("procedureCode"))  //BKS_CODPRO
    oColBKS:SetValue("toothCode"             ,oAuxEve:GetValue("toothCode"))      //BKS_CDDENT
    oColBKS:SetValue("regionCode"            ,oAuxEve:GetValue("regionCode"))     //BKS_CDREGI
    oColBKS:SetValue("toothFaceCode"         ,oAuxEve:GetValue("toothFaceCode"))  //BKS_CDFACE
    oColBKS:SetValue("status"                ,self:cStatus)  //BKR_STATUS
    oColBKS:SetValue("supplierCnpj"          ,oAuxEve:GetValue("supplierCnpj"))       //BKS_CNPJFR
    oColBKS:SetValue("enteredQuantity"       ,oAuxEve:GetValue("enteredQuantity"))    //BKS_QTDINF
    oColBKS:SetValue("quantityPaid"          ,oAuxEve:GetValue("quantityPaid"))       //BKS_QTDPAG
    oColBKS:SetValue("procedureValuePaid"    ,oAuxEve:GetValue("procedureValuePaid")) //BKS_VLPGPR
    oColBKS:SetValue("coPaymentValue"        ,oAuxEve:GetValue("coPaymentValue"))     //BKS_VLRCOP
    oColBKS:SetValue("disallVl"              ,oAuxEve:GetValue("disallVl"))           //BKS_VLRGLO
    oColBKS:SetValue("valueEntered"          ,oAuxEve:GetValue("valueEntered"))       //BKS_VLRINF
    oColBKS:SetValue("valuePaidSupplier"     ,oAuxEve:GetValue("valuePaidSupplier"))  //BKS_VLRPGF
    oColBKS:SetValue("eventType"             ,cTipEve)                                //BKS_TIPEVE
    oColBKS:SetValue("package"               ,oAuxEve:GetValue("package"))            //BKS_PACOTE

    //Commit dos itens
    oColBKS:insert()
    oColBKS:destroy()

Return

//------------------------------------------------------------------------------------------
/*/{Protheus.doc} grvHisBRG
    Grava a movimentacao da BRG

    @type  Class
    @author renan.almeida
    @since 20190320Ç
/*/
//------------------------------------------------------------------------------------------
Method grvHisBRG(oAuxEve,cTipEve) Class CenPrMoGui

    Local oColBRG    := CenCltBRG():New() //Objeto para gravacao
    Local oColHisBRG := CenCltBRG():New() //Objeto para busca de registro ja gravado

    //Chave Primaria: BRG_FILIAL, BRG_CODOPE, BRG_NMGOPE, BRG_CODGRU, BRG_CODTAB, BRG_CODPRO, BRG_CDDENT, BRG_CDREGI, BRG_CDFACE
    oColBRG:SetValue("operatorRecord"        ,self:cCodOpe)    //BRG_CODOPE
    oColBRG:SetValue("operatorFormNumber"    ,self:cNumGuiOpe) //BRG_NMGOPE
    oColBRG:SetValue("procedureGroup"        ,oAuxEve:GetValue("procedureGroup"))  //BRG_CODGRU
    oColBRG:SetValue("tableCode"             ,oAuxEve:GetValue("tableCode"))       //BRG_CODTAB
    oColBRG:SetValue("procedureCode"         ,oAuxEve:GetValue("procedureCode"))   //BRG_CODPRO
    oColBRG:SetValue("toothCode"             ,oAuxEve:GetValue("toothCode"))       //BRG_CDDENT
    oColBRG:SetValue("regionCode"            ,oAuxEve:GetValue("regionCode"))      //BRG_CDREGI
    oColBRG:SetValue("toothFaceCode"         ,oAuxEve:GetValue("toothFaceCode"))   //BRG_CDFACE

    oColBRG:SetValue("supplierCnpj"          ,oAuxEve:GetValue("supplierCnpj"))       //BRG_CNPJFR
    oColBRG:SetValue("enteredQuantity"       ,oAuxEve:GetValue("enteredQuantity"))    //BRG_QTDINF
    oColBRG:SetValue("quantityPaid"          ,oAuxEve:GetValue("quantityPaid"))       //BRG_QTDPAG
    oColBRG:SetValue("procedureValuePaid"    ,oAuxEve:GetValue("procedureValuePaid")) //BRG_VLPGPR
    oColBRG:SetValue("coPaymentValue"        ,oAuxEve:GetValue("coPaymentValue"))     //BRG_VLRCOP
    oColBRG:SetValue("disallVl"              ,oAuxEve:GetValue("disallVl"))           //BRG_VLRGLO
    oColBRG:SetValue("valueEntered"          ,oAuxEve:GetValue("valueEntered"))       //BRG_VLRINF
    oColBRG:SetValue("valuePaidSupplier"     ,oAuxEve:GetValue("valuePaidSupplier"))  //BRG_VLRPGF
    oColBRG:SetValue("eventType"             ,cTipEve)                                //BRG_TIPEVE
    oColBRG:SetValue("package"               ,oAuxEve:GetValue("package"))            //BRG_PACOTE

    //Verifico se e uma alteracao ou novo registro
    oColHisBRG:setValue("operatorRecord",    self:cCodOpe)
    oColHisBRG:setValue("operatorFormNumber",self:cNumGuiOpe)
    oColHisBRG:setValue("procedureGroup",    oAuxEve:GetValue("procedureGroup"))
    oColHisBRG:setValue("tableCode",         oAuxEve:GetValue("tableCode"))
    oColHisBRG:setValue("procedureCode",     oAuxEve:GetValue("procedureCode"))
    oColHisBRG:setValue("toothCode",         oAuxEve:GetValue("toothCode"))
    oColHisBRG:setValue("regionCode",        oAuxEve:GetValue("regionCode"))
    oColHisBRG:setValue("toothFaceCode",     oAuxEve:GetValue("toothFaceCode"))

    //Commit dos itens
    iif(oColHisBRG:bscChaPrim(),oColBRG:oDao:commit(),oColBRG:insert())

    oColBRG:destroy()
    oColHisBRG:destroy()

Return


//------------------------------------------------------------------------------------------
/*/{Protheus.doc} grvMovBKT
    Grava a movimentacao da BKT

    @type  Class
    @author renan.almeida
    @since 20190320
/*/
//------------------------------------------------------------------------------------------
Method grvMovBKT(oAuxEve,cCodTab,cCodPro) Class CenPrMoGui

    Local oColBKT := CenCltBKT():New()

    //Chave Primaria: BKT_FILIAL, BKT_CODOPE, BKT_NMGOPE, BKT_CDOBRI, BKT_ANO, BKT_CDCOMP, BKT_LOTE, BKT_DTPRGU, BKT_CODTAB, BKT_CODPRO, BKT_CDTBIT, BKT_CDPRIT
    oColBKT:SetValue("operatorRecord"     ,self:cCodOpe)     //BKT_CODOPE
    oColBKT:SetValue("operatorFormNumber" ,self:cNumGuiOpe)  //BKT_NMGOPE
    oColBKT:SetValue("requirementCode"    ,self:cCodObrig)   //BKT_CDOBRI
    oColBKT:SetValue("referenceYear"      ,self:cAno)        //BKT_ANO
    oColBKT:SetValue("commitmentCode"     ,self:cMes)        //BKT_CDCOMP
    oColBKT:SetValue("batchCode"          ,self:cLote)       //BKT_LOTE
    oColBKT:SetValue("formProcDt"         ,self:dProcGuia)   //BKT_DTPRGU
    oColBKT:SetValue("tableCode"          ,cCodTab)          //BKT_CODTAB
    oColBKT:SetValue("procedureCode"      ,cCodPro)          //BKT_CODPRO
    oColBKT:SetValue("itemTableCode"      ,oAuxEve:GetValue("itemTableCode"))     //BKT_CDTBIT
    oColBKT:SetValue("itemProCode"        ,oAuxEve:GetValue("itemProCode"))       //BKT_CDPRIT
    oColBKT:SetValue("packageQuantity"    ,oAuxEve:GetValue("packageQuantity"))   //BKT_QTPRPC

    //Commmit dos Pacotes
    oColBKT:insert()
    oColBKT:destroy()

Return


//------------------------------------------------------------------------------------------
/*/{Protheus.doc} grvHisBRH
    Grava o historico de pacotes BRH

    @type  Class
    @author renan.almeida
    @since 20190320
/*/
//------------------------------------------------------------------------------------------
Method grvHisBRH(oAuxEve,cCodTab,cCodPro) Class CenPrMoGui

    Local oColBRH := CenCltBRH():New()
    Local oColHisBRH := CenCltBRH():New()

    //Chave Primaria: BRH_FILIAL, BRH_CODOPE, BRH_NMGOPE, BRH_CODTAB, BRH_CODPRO, BRH_CDTBIT, BRH_CDPRIT
    oColBRH:SetValue("operatorRecord"     ,self:cCodOpe)    //BRH_CODOPE
    oColBRH:SetValue("operatorFormNumber" ,self:cNumGuiOpe) //BRH_NMGOPE
    oColBRH:SetValue("tableCode"          ,cCodTab)         //BRH_CODTAB
    oColBRH:SetValue("procedureCode"      ,cCodPro)         //BRH_CODPRO
    oColBRH:SetValue("itemTableCode"      ,oAuxEve:GetValue("itemTableCode"))     //BKT_CDTBIT
    oColBRH:SetValue("itemProCode"        ,oAuxEve:GetValue("itemProCode"))       //BKT_CDPRIT
    oColBRH:SetValue("packageQuantity"    ,oAuxEve:GetValue("packageQuantity"))   //BKT_QTPRPC

    //Verifico se e uma alteracao ou novo registro
    oColHisBRH:SetValue("operatorRecord"     ,self:cCodOpe)    //BRH_CODOPE
    oColHisBRH:SetValue("operatorFormNumber" ,self:cNumGuiOpe) //BRH_NMGOPE
    oColHisBRH:SetValue("tableCode"          ,cCodTab)         //BRH_CODTAB
    oColHisBRH:SetValue("procedureCode"      ,cCodPro)         //BRH_CODPRO
    oColHisBRH:SetValue("itemTableCode"      ,oAuxEve:GetValue("itemTableCode"))     //BKT_CDTBIT
    oColHisBRH:SetValue("itemProCode"        ,oAuxEve:GetValue("itemProCode"))       //BKT_CDPRIT
    oColHisBRH:SetValue("packageQuantity"    ,oAuxEve:GetValue("packageQuantity"))   //BKT_QTPRPC

    //Commmit dos Pacotes
    iif(oColHisBRH:bscChaPrim(),oColBRH:oDao:commit(),oColBRH:insert())

    oColBRH:destroy()
    oColHisBRH:destroy()
    FreeObj(oColBRH)
    FreeObj(oColHisBRH)
    oColBRH := nil
    oColHisBRH := nil

Return


//------------------------------------------------------------------------------------------
/*/{Protheus.doc} grvMovBKR
    Grava o cabecalho da movimentacao na BKR

    @type  Class
    @author renan.almeida
    @since 20190320
/*/
//------------------------------------------------------------------------------------------
Method grvMovBKR(oAuxCab,oTotaliz) Class CenPrMoGui

    Local oColBKR := CenCltBKR():New()

    //Chave primaria - BKR_FILIAL+BKR_CODOPE+BKR_NMGOPE+BKR_CDOBRI+BKR_ANO+BKR_CDCOMP+BKR_LOTE+BKR_DTPRGU
    oColBKR:SetValue("operatorRecord"        ,self:cCodOpe)    //BKR_CODOPE
    oColBKR:SetValue("operatorFormNumber"    ,self:cNumGuiOpe) //BKR_NMGOPE
    oColBKR:SetValue("requirementCode"       ,self:cCodObrig)  //BKR_CDOBRI
    oColBKR:SetValue("referenceYear"         ,self:cAno)       //BKR_ANO
    oColBKR:SetValue("commitmentCode"        ,self:cMes)       //BKR_CDCOMP
    oColBKR:SetValue("batchCode"             ,self:cLote)      //BKR_LOTE
    oColBKR:SetValue("formProcDt"            ,self:dProcGuia)  //BKR_DTPRGU

    oColBKR:SetValue("status"                ,self:cStatus)  //BKR_STATUS
    oColBKR:SetValue("monitoringRecordType"  ,self:cTipRegist ) //BKR_TPRGMN
    oColBKR:SetValue("processingTime"        ,Substr(Time(),1,2)+Substr(Time(),4,2)+Substr(Time(),7,2))   //BKR_HORPRO
    oColBKR:SetValue("processingDate"        ,Dtos(dDataBase))   //BKR_DATPRO
    oColBKR:SetValue("registration"          ,oAuxCab:GetValue("registration"))
    oColBKR:SetValue("outflowType"           ,oAuxCab:GetValue("outflowType"))
    oColBKR:SetValue("collectionProtocolDate",oAuxCab:GetValue("collectionProtocolDate"))
    oColBKR:SetValue("submissionMethod"      ,oAuxCab:GetValue("submissionMethod"))
    oColBKR:SetValue("executerId"            ,oAuxCab:GetValue("executerId"))
    oColBKR:SetValue("refundId"              ,oAuxCab:GetValue("refundId"))
    oColBKR:SetValue("presetValueIdent"      ,oAuxCab:GetValue("presetValueIdent"))
    oColBKR:SetValue("newborn"               ,oAuxCab:GetValue("newborn"))
    oColBKR:SetValue("indicAccident"         ,oAuxCab:GetValue("indicAccident"))
    oColBKR:SetValue("providerFormNumber"    ,oAuxCab:GetValue("providerFormNumber"))
    oColBKR:SetValue("mainFormNumb"          ,oAuxCab:GetValue("mainFormNumb"))
    oColBKR:SetValue("aEventType"            ,oAuxCab:GetValue("aEventType"))
    oColBKR:SetValue("eventOrigin"           ,oAuxCab:GetValue("eventOrigin"))
    oColBKR:SetValue("hospRegime"            ,oAuxCab:GetValue("hospRegime"))
    oColBKR:SetValue("ansRecordNumber"       ,oAuxCab:GetValue("ansRecordNumber"))
    oColBKR:SetValue("hospitalizationRequest",oAuxCab:GetValue("hospitalizationRequest"))
    oColBKR:SetValue("admissionType"         ,oAuxCab:GetValue("admissionType"))
    oColBKR:SetValue("serviceType"           ,oAuxCab:GetValue("serviceType"))
    oColBKR:SetValue("appointmentType"       ,oAuxCab:GetValue("appointmentType"))
    oColBKR:SetValue("invoicingTp"           ,oAuxCab:GetValue("invoicingTp"))
    oColBKR:SetValue("hospTp"                ,oAuxCab:GetValue("hospTp"))
    oColBKR:SetValue("providerCpfCnpj"       ,oAuxCab:GetValue("providerCpfCnpj"))
    oColBKR:SetValue("authorizationDate"     ,oAuxCab:GetValue("authorizationDate"))
    oColBKR:SetValue("executionDate"         ,oAuxCab:GetValue("executionDate"))
    oColBKR:SetValue("requestDate"           ,oAuxCab:GetValue("requestDate"))
    oColBKR:SetValue("escortDailyRates"      ,oAuxCab:GetValue("escortDailyRates"))
    oColBKR:SetValue("icuDailyRates"         ,oAuxCab:GetValue("icuDailyRates"))
    oColBKR:SetValue("invoicingEndDate"      ,oAuxCab:GetValue("invoicingEndDate"))
    oColBKR:SetValue("invoicingStartDate"    ,oAuxCab:GetValue("invoicingStartDate"))
    oColBKR:SetValue("paymentDt"             ,oAuxCab:GetValue("paymentDt"))
    oColBKR:SetValue("cnes"                  ,oAuxCab:GetValue("cnes"))
    oColBKR:SetValue("executingCityCode"     ,oAuxCab:GetValue("executingCityCode"))
    oColBKR:SetValue("cboSCode"              ,oAuxCab:GetValue("cboSCode"))
    oColBKR:SetValue("icdDiagnosis1"         ,oAuxCab:GetValue("icdDiagnosis1"))
    oColBKR:SetValue("icdDiagnosis2"         ,oAuxCab:GetValue("icdDiagnosis2"))
    oColBKR:SetValue("icdDiagnosis3"         ,oAuxCab:GetValue("icdDiagnosis3"))
    oColBKR:SetValue("icdDiagnosis4"         ,oAuxCab:GetValue("icdDiagnosis4"))
    oColBKR:SetValue("tissProviderVersion"   ,oAuxCab:GetValue("tissProviderVersion"))
    oColBKR:SetValue("inclusionDate"         ,oAuxCab:GetValue("inclusionDate"))
    oColBKR:SetValue("inclusionTime"         ,oAuxCab:GetValue("inclusionTime"))
    //Totalizadores
    oColBKR:setValue("totalValueEntered"     ,oTotaliz:getValue("nVLTINF"))
    oColBKR:SetValue("valueProcessed"        ,oTotaliz:getValue("nVLTPRO"))
    oColBKR:SetValue("procedureTotalValuePai",oTotaliz:getValue("nVLTPGP"))
    oColBKR:SetValue("dailyRatesTotalValue"  ,oTotaliz:getValue("nVLTDIA"))
    oColBKR:SetValue("feesTotalValue"        ,oTotaliz:getValue("nVLTTAX"))
    oColBKR:SetValue("materialsTotalValue"   ,oTotaliz:getValue("nVLTMAT"))
    oColBKR:SetValue("totalOpmeValue"        ,oTotaliz:getValue("nVLTOPM"))
    oColBKR:SetValue("medicationTotalValue"  ,oTotaliz:getValue("nVLTMED"))
    oColBKR:SetValue("formDisallowanceValue" ,oTotaliz:getValue("nVLTGLO"))
    oColBKR:SetValue("valuePaidForm"         ,oTotaliz:getValue("nVLTGUI"))
    oColBKR:SetValue("valuePaidSuppliers"    ,oTotaliz:getValue("nVLTFOR"))
    oColBKR:SetValue("ownTableTotalValue"    ,oTotaliz:getValue("nVLTTBP"))
    oColBKR:SetValue("coPaymentTotalValue"   ,oTotaliz:getValue("nVLTCOP"))

    oColBKR:insert()
    oColBKR:destroy()

Return


//------------------------------------------------------------------------------------------
/*/{Protheus.doc} grvHisBRF
    Grava o cabecalho da movimentacao na BRF

    @type  Class
    @author renan.almeida
    @since 20190320
/*/
//------------------------------------------------------------------------------------------
Method grvHisBRF(oAuxCab,oTotaliz) Class CenPrMoGui

    Local oColBRF    := CenCltBRF():New()
    Local oColHisBRF := CenCltBRF():New()

    //Chave primaria - BRF_FILIAL, BRF_CODOPE, BRF_NMGOPE
    oColBRF:SetValue("operatorRecord"        ,self:cCodOpe)
    oColBRF:SetValue("operatorFormNumber"    ,self:cNumGuiOpe)

    oColBRF:SetValue("registration"          ,oAuxCab:GetValue("registration"))
    oColBRF:SetValue("outflowType"           ,oAuxCab:GetValue("outflowType"))
    oColBRF:SetValue("collectionProtocolDate",oAuxCab:GetValue("collectionProtocolDate"))
    oColBRF:SetValue("submissionMethod"      ,oAuxCab:GetValue("submissionMethod"))
    oColBRF:SetValue("executerId"            ,oAuxCab:GetValue("executerId"))
    oColBRF:SetValue("refundId"              ,oAuxCab:GetValue("refundId"))
    oColBRF:SetValue("presetValueIdent"      ,oAuxCab:GetValue("presetValueIdent"))
    oColBRF:SetValue("newborn"               ,oAuxCab:GetValue("newborn"))
    oColBRF:SetValue("indicAccident"         ,oAuxCab:GetValue("indicAccident"))
    oColBRF:SetValue("providerFormNumber"    ,oAuxCab:GetValue("providerFormNumber"))
    oColBRF:SetValue("mainFormNumb"          ,oAuxCab:GetValue("mainFormNumb"))
    oColBRF:SetValue("aEventType"            ,oAuxCab:GetValue("aEventType"))
    oColBRF:SetValue("eventOrigin"           ,oAuxCab:GetValue("eventOrigin"))
    oColBRF:SetValue("hospRegime"            ,oAuxCab:GetValue("hospRegime"))
    oColBRF:SetValue("ansRecordNumber"       ,oAuxCab:GetValue("ansRecordNumber"))
    oColBRF:SetValue("hospitalizationRequest",oAuxCab:GetValue("hospitalizationRequest"))
    oColBRF:SetValue("admissionType"         ,oAuxCab:GetValue("admissionType"))
    oColBRF:SetValue("serviceType"           ,oAuxCab:GetValue("serviceType"))
    oColBRF:SetValue("appointmentType"       ,oAuxCab:GetValue("appointmentType"))
    oColBRF:SetValue("invoicingTp"           ,oAuxCab:GetValue("invoicingTp"))
    oColBRF:SetValue("hospTp"                ,oAuxCab:GetValue("hospTp"))
    oColBRF:SetValue("providerCpfCnpj"       ,oAuxCab:GetValue("providerCpfCnpj"))
    oColBRF:SetValue("authorizationDate"     ,oAuxCab:GetValue("authorizationDate"))
    oColBRF:SetValue("executionDate"         ,oAuxCab:GetValue("executionDate"))
    oColBRF:SetValue("requestDate"           ,oAuxCab:GetValue("requestDate"))
    oColBRF:SetValue("escortDailyRates"      ,oAuxCab:GetValue("escortDailyRates"))
    oColBRF:SetValue("icuDailyRates"         ,oAuxCab:GetValue("icuDailyRates"))
    oColBRF:SetValue("invoicingEndDate"      ,oAuxCab:GetValue("invoicingEndDate"))
    oColBRF:SetValue("invoicingStartDate"    ,oAuxCab:GetValue("invoicingStartDate"))
    oColBRF:SetValue("paymentDt"             ,oAuxCab:GetValue("paymentDt"))
    oColBRF:SetValue("cnes"                  ,oAuxCab:GetValue("cnes"))
    oColBRF:SetValue("executingCityCode"     ,oAuxCab:GetValue("executingCityCode"))
    oColBRF:SetValue("cboSCode"              ,oAuxCab:GetValue("cboSCode"))
    oColBRF:SetValue("icdDiagnosis1"         ,oAuxCab:GetValue("icdDiagnosis1"))
    oColBRF:SetValue("icdDiagnosis2"         ,oAuxCab:GetValue("icdDiagnosis2"))
    oColBRF:SetValue("icdDiagnosis3"         ,oAuxCab:GetValue("icdDiagnosis3"))
    oColBRF:SetValue("icdDiagnosis4"         ,oAuxCab:GetValue("icdDiagnosis4"))
    oColBRF:SetValue("tissProviderVersion"   ,oAuxCab:GetValue("tissProviderVersion"))
    oColBRF:SetValue("inclusionDate"         ,oAuxCab:GetValue("inclusionDate"))
    oColBRF:SetValue("inclusionTime"         ,oAuxCab:GetValue("inclusionTime"))
    //Totalizadores
    oColBRF:setValue("totalValueEntered"     ,oTotaliz:getValue("nVLTINF"))
    oColBRF:SetValue("valueProcessed"        ,oTotaliz:getValue("nVLTPRO"))
    oColBRF:SetValue("procedureTotalValuePai",oTotaliz:getValue("nVLTPGP"))
    oColBRF:SetValue("dailyRatesTotalValue"  ,oTotaliz:getValue("nVLTDIA"))
    oColBRF:SetValue("feesTotalValue"        ,oTotaliz:getValue("nVLTTAX"))
    oColBRF:SetValue("materialsTotalValue"   ,oTotaliz:getValue("nVLTMAT"))
    oColBRF:SetValue("totalOpmeValue"        ,oTotaliz:getValue("nVLTOPM"))
    oColBRF:SetValue("medicationTotalValue"  ,oTotaliz:getValue("nVLTMED"))
    oColBRF:SetValue("formDisallowanceValue" ,oTotaliz:getValue("nVLTGLO"))
    oColBRF:SetValue("valuePaidForm"         ,oTotaliz:getValue("nVLTGUI"))
    oColBRF:SetValue("valuePaidSuppliers"    ,oTotaliz:getValue("nVLTFOR"))
    oColBRF:SetValue("ownTableTotalValue"    ,oTotaliz:getValue("nVLTTBP"))
    oColBRF:SetValue("coPaymentTotalValue"   ,oTotaliz:getValue("nVLTCOP"))

    //Verifico se e uma alteracao ou novo registro
    oColHisBRF:setValue("operatorRecord"    ,self:cCodOpe)
    oColHisBRF:setValue("operatorFormNumber",self:cNumGuiOpe)

    iif(oColHisBRF:bscChaPrim(),oColBRF:oDao:commit(),oColBRF:insert())

    oColBRF:destroy()
    oColHisBRF:destroy()
    FreeObj(oColBRF)
    FreeObj(oColHisBRF)
    oColBRF := nil
    oColHisBRF := nil

Return


//------------------------------------------------------------------------------------------
/*/{Protheus.doc} grvMovBN0
    Grava movimentacao de declaracoes de Obito/Nascido

    @type  Class
    @author renan.almeida
    @since 20190320
/*/
//------------------------------------------------------------------------------------------
Method grvMovBN0(oAuxDec) Class CenPrMoGui

    Local oColBN0  := CenCltBN0():New()

    oColBN0:setValue("operatorRecord"     ,self:cCodOpe)    //BN0_CODOPE
    oColBN0:setValue("operatorFormNumber" ,self:cNumGuiOpe) //BN0_NMGOPE
    oColBN0:setValue("requirementCode"    ,self:cCodObrig)  //BN0_CDOBRI
    oColBN0:setValue("referenceYear"      ,self:cAno)       //BN0_ANO
    oColBN0:setValue("commitmentCode"     ,self:cMes)       //BN0_CDCOMP
    oColBN0:setValue("batchCode"          ,self:cLote)      //BN0_LOTE
    oColBN0:setValue("formProcDt"         ,self:dProcGuia)  //BN0_DTPRGU
    oColBN0:setValue("certificateType"    ,oAuxDec:getValue("certificateType"))   //BN0_TIPO
    oColBN0:setValue("certificateNumber"  ,oAuxDec:getValue("certificateNumber")) //BN0_DECNUM

    //Commit dos certificados
    oColBN0:insert()

    oColBN0:destroy()

Return


//------------------------------------------------------------------------------------------
/*/{Protheus.doc} grvHisBNY
    Grava movimentacao de declaracoes de Obito/Nascido

    @type  Class
    @author renan.almeida
    @since 20190320
/*/
//------------------------------------------------------------------------------------------
Method grvHisBNY(oAuxDec) Class CenPrMoGui

    Local oColBNY    := CenCltBNY():New()
    Local oColHisBNY := CenCltBNY():New()

    oColBNY:setValue("operatorRecord"     ,self:cCodOpe)    //BNY_CODOPE
    oColBNY:setValue("operatorFormNumber" ,self:cNumGuiOpe) //BNY_NMGOPE
    oColBNY:setValue("certificateType"    ,oAuxDec:getValue("certificateType"))   //BNY_TIPO
    oColBNY:setValue("certificateNumber"  ,oAuxDec:getValue("certificateNumber")) //BNY_DECNUM

    //Verifico se e uma alteracao ou novo registro
    oColHisBNY:setValue("operatorRecord",    self:cCodOpe)
    oColHisBNY:setValue("operatorFormNumber",self:cNumGuiOpe)
    oColHisBNY:setValue("certificateNumber", oAuxDec:getValue("certificateNumber"))
    oColHisBNY:setValue("certificateType",   oAuxDec:getValue("certificateType"))

    //Commit das declaracoes
    iif(oColHisBNY:bscChaPrim(),oColBNY:oDao:commit(),oColBNY:insert())

    oColBNY:destroy()
    oColHisBNY:destroy()

Return


//------------------------------------------------------------------------------------------
/*/{Protheus.doc} procExclus
    Processa a exclusao de uma transacao

    @type  Class
    @author renan.almeida
    @since 20190320
/*/
//------------------------------------------------------------------------------------------
Method excTransac() Class CenPrMoGui

    Local oColBKR := CenCltBKR():New()
    Local oObjBKR := nil

    oColBKR:SetValue("operatorRecord"     ,self:cCodOpe)
    oColBKR:SetValue("operatorFormNumber" ,self:cNumGuiOpe)
    oColBKR:SetValue("requirementCode"    ,self:cCodObrig)
    oColBKR:SetValue("formProcDt"         ,self:dProcGuia)

    if oColBKR:bscMovExcl()

        //while oColBKR:HasNext()
        oObjBKR := oColBKR:GetNext()

        //So processarei se a ultima transacao nao for uma Exclusao
        if oObjBKR:getValue("monitoringRecordType") <> idTraExc

            //Verifico o status, se nao foi enviada para a ANS, excluo a transacao
            if oObjBKR:getValue("status") $ "1/2/3/7" //1=Pendente Envio;2=Criticado;3=Pronto para o Envio;4=Em processamento ANS;5=Criticado pela ANS;6=Finalizado;7=Pendente Envio;8=Arquivo Gerado

                self:delMovBKR(oObjBKR)
                self:delMovBKS(oObjBKR)
                self:delMovBKT(oObjBKR)
                self:delMovBN0(oObjBKR)
                self:delMovB3F(oObjBKR,"BKR",BKR->(Recno()))

                //Ja foi enviado para ANS, devo gerar uma transacao de exclusao
            elseIf oObjBKR:getValue("status") $ "4/6/8"
                self:gerTraExc(oObjBKR) //Gera a transacao de exclusao
            endif
            //Refaz o historico da guia
            self:proRestHis()

        endIf
        oObjBKR:destroy()
        //endDo
    endIf
    oColBKR:destroy()

Return


//------------------------------------------------------------------------------------------
/*/{Protheus.doc} excGuia
    Processa a exclusao de uma guia

    @type  Class
    @author renan.almeida

    @since 20190320
/*/
//------------------------------------------------------------------------------------------
Method excGuia() Class CenPrMoGui

    Local oColBKR    := CenCltBKR():New()
    Local oColExcBKR := nil
    Local oObjBKR    := nil

    oColBKR:SetValue("operatorRecord"     ,self:cCodOpe)
    oColBKR:SetValue("operatorFormNumber" ,self:cNumGuiOpe)
    oColBKR:SetValue("requirementCode"    ,self:cCodObrig)

    if oColBKR:bscMovExcl()

        while oColBKR:HasNext()

            oObjBKR := oColBKR:GetNext()
            //Vou rodar somente as Inclusoes
            if oObjBKR:getValue("monitoringRecordType") == "1"

                //Verifico o status, se nao foi enviada para a ANS, excluo a transacao
                if oObjBKR:getValue("status") $ "1/2/3/7" //1=Pendente Envio;2=Criticado;3=Pronto para o Envio;4=Em processamento ANS;5=Criticado pela ANS;6=Finalizado

                    self:delMovBKR(oObjBKR)
                    self:delMovBKS(oObjBKR)
                    self:delMovBKT(oObjBKR)
                    self:delMovBN0(oObjBKR)
                    self:delMovB3F(oObjBKR,"BKR",BKR->(Recno()))

                    //Ja foi enviado para ANS, devo gerar uma transacao de exclusao
                elseIf oObjBKR:getValue("status") $ "4/6/8"

                    oColExcBKR := CenCltBKR():New()
                    oColExcBKR:SetValue("operatorRecord"      ,oObjBKR:getValue("operatorRecord"))
                    oColExcBKR:SetValue("operatorFormNumber"  ,oObjBKR:getValue("operatorFormNumber"))
                    oColExcBKR:SetValue("requirementCode"     ,oObjBKR:getValue("requirementCode"))
                    oColExcBKR:SetValue("referenceYear"       ,oObjBKR:getValue("referenceYear"))
                    oColExcBKR:SetValue("commitmentCode"      ,oObjBKR:getValue("commitmentCode"))
                    oColExcBKR:SetValue("batchCode"           ,oObjBKR:getValue("batchCode"))
                    oColExcBKR:SetValue("formProcDt"          ,oObjBKR:getValue("formProcDt"))
                    oColExcBKR:SetValue("monitoringRecordType",idTraExc)
                    //oColExcBKR:SetValue("status"              ,"6")

                    // Verifico se a transacao ja esta excluida, caso negativo,
                    // gero uma exclusao para a guia
                    if !oColExcBKR:buscar()
                        self:dProcGuia  := oObjBKR:getValue("formProcDt")
                        self:gerTraExc(oObjBKR) //Gera a transacao de exclusao
                    endIf
                    oColExcBKR:destroy()

                endif
            endIf
            oObjBKR:destroy()
        endDo
    endIf
    oColBKR:destroy()

Return


//------------------------------------------------------------------------------------------
/*/{Protheus.doc} gerTraExc
    Gera uma transacao de exclusao

    @type  Class
    @author renan.almeida
    @since 20190320
/*/
//------------------------------------------------------------------------------------------
Method gerTraExc(oAuxBKR) Class CenPrMoGui

    Local oColBKS   := nil
    Local oAux      := nil
    Local cTipEve   := ""
    Local cIdPacote := ""

    //Padrao para exclusao e gerar na proxima competencia
    self:comAltExc(oAuxBKR)
    //---------------------------------------------------------
    //              Gravacao de Cabecalho
    //---------------------------------------------------------
    self:cTipRegist := idTraExc
    oCalTot := CenMoTotGu():New() //Objeto para totalizadores do cabecalho
    oCalTot:carGuiMon(oAuxBKR)

    self:grvMovBKR(oAuxBKR,oCalTot) //Grava movimentacao - cabecalho
    oCalTot:destroy()

    //---------------------------------------------------------
    //              Gravacao de Eventos
    //---------------------------------------------------------
    oColBKS := CenCltBKS():New()
    oColBKS:SetValue("operatorRecord"     ,oAuxBKR:getValue("operatorRecord"))
    oColBKS:SetValue("operatorFormNumber" ,oAuxBKR:getValue("operatorFormNumber"))
    oColBKS:SetValue("requirementCode"    ,oAuxBKR:getValue("requirementCode"))
    oColBKS:SetValue("referenceYear"      ,oAuxBKR:getValue("referenceYear"))
    oColBKS:SetValue("commitmentCode"     ,oAuxBKR:getValue("commitmentCode"))
    oColBKS:SetValue("batchCode"          ,oAuxBKR:getValue("batchCode"))
    oColBKS:SetValue("formProcDt"         ,oAuxBKR:getValue("formProcDt"))

    if oColBKS:buscar()
        while oColBKS:HasNext()
            oAux      := oColBKS:GetNext()
            cTipEve   := oAux:getValue("eventType")
            cIdPacote := oAux:getValue("package")

            self:grvMovBKS(oAux,cTipEve) //Grava movimentacao - eventos
            oAux:destroy()
        endDo
    endIf
    oColBKS:destroy()

    //---------------------------------------------------------
    //              Gravacao de Pacotes
    //---------------------------------------------------------
    oColBKT := CenCltBKT():New()
    oColBKT:SetValue("operatorRecord"     ,oAuxBKR:getValue("operatorRecord"))
    oColBKT:SetValue("operatorFormNumber" ,oAuxBKR:getValue("operatorFormNumber"))
    oColBKT:SetValue("requirementCode"    ,oAuxBKR:getValue("requirementCode"))
    oColBKT:SetValue("referenceYear"      ,oAuxBKR:getValue("referenceYear"))
    oColBKT:SetValue("commitmentCode"     ,oAuxBKR:getValue("commitmentCode"))
    oColBKT:SetValue("batchCode"          ,oAuxBKR:getValue("batchCode"))
    oColBKT:SetValue("formProcDt"         ,oAuxBKR:getValue("formProcDt"))

    if oColBKT:buscar()
        while oColBKT:HasNext()
            oAux       := oColBKT:GetNext()
            cCodTab    := oAux:getValue("tableCode")
            cCodPro    := oAux:getValue("procedureCode")

            self:grvMovBKT(oAux,cCodTab,cCodPro) //Grava movimentacao - pacotes
            oAux:destroy()
        endDo
    endIf
    oColBKT:destroy()
    //---------------------------------------------------------
    //              Gravacao de Declaracoes
    //---------------------------------------------------------
    oColBN0 := CenCltBN0():New()
    oColBN0:SetValue("operatorRecord"     ,oAuxBKR:getValue("operatorRecord"))
    oColBN0:SetValue("operatorFormNumber" ,oAuxBKR:getValue("operatorFormNumber"))
    oColBN0:SetValue("requirementCode"    ,oAuxBKR:getValue("requirementCode"))
    oColBN0:SetValue("referenceYear"      ,oAuxBKR:getValue("referenceYear"))
    oColBN0:SetValue("commitmentCode"     ,oAuxBKR:getValue("commitmentCode"))
    oColBN0:SetValue("batchCode"          ,oAuxBKR:getValue("batchCode"))
    oColBN0:SetValue("formProcDt"         ,oAuxBKR:getValue("formProcDt"))

    if oColBN0:buscar()
        while oColBN0:HasNext()
            oAuxDec  := oColBN0:GetNext()
            self:grvMovBN0(oAuxDec) //Grava movimentacao - declaracoes nascido/obito
            oAuxDec:destroy()
        endDo
    endIf
    oColBN0:destroy()

Return


//------------------------------------------------------------------------------------------
/*/{Protheus.doc} restUltSta
    Restaura o historico com o ultimo status

    @type  Class
    @author renan.almeida
    @since 20190320
/*/
//------------------------------------------------------------------------------------------
Method restUltSta(oAuxBKR,lRecalcPag,aTransExc) Class CenPrMoGui

    Local oColBKS    := nil
    Local oAux       := nil
    Local cTipEve    := ""
    Local cIdPacote  := ""
    Local aAuxEve    := {}
    Default lRecalcPag := .F.
    Default aTransExc  := {}

    //---------------------------------------------------------
    //              Gravacao de Eventos
    //---------------------------------------------------------
    oColBKS := CenCltBKS():New()
    oColBKS:SetValue("operatorRecord"     ,oAuxBKR:getValue("operatorRecord"))
    oColBKS:SetValue("operatorFormNumber" ,oAuxBKR:getValue("operatorFormNumber"))
    oColBKS:SetValue("requirementCode"    ,oAuxBKR:getValue("requirementCode"))
    oColBKS:SetValue("referenceYear"      ,oAuxBKR:getValue("referenceYear"))
    oColBKS:SetValue("commitmentCode"     ,oAuxBKR:getValue("commitmentCode"))
    oColBKS:SetValue("batchCode"          ,oAuxBKR:getValue("batchCode"))
    oColBKS:SetValue("formProcDt"         ,oAuxBKR:getValue("formProcDt"))

    //Os eventos podem ser gravados de duas maneiras:
    //Recalculando o valor pago qdo temos mais de um pagamento ja realizado
    if lRecalcPag

        oCalTot    := CenMoTotGu():New()
        oColPagBKS := CenCltBKS():New()
        oColPagBKS:SetValue("operatorRecord"     ,self:cCodOpe)
        oColPagBKS:SetValue("operatorFormNumber" ,self:cNumGuiOpe)
        oColPagBKS:SetValue("requirementCode"    ,self:cCodObrig)

        if oColBKS:bscLastEve(aTransExc) .And. oColPagBKS:bscVlrPag(aTransExc)

            aadd(aAuxEve,{"","","","","",""}) //Monto uma posicao vazia para nao quebrar o aScan

            while oColBKS:HasNext()

                oAux := oColBKS:GetNext()

                if aScan(aAuxEve,{|x| x[1] == oAux:getValue("procedureGroup") .And. ;
                        x[2] == oAux:getValue("tableCode")      .And. ;
                        x[3] == oAux:getValue("procedureCode")  .And. ;
                        x[4] == oAux:getValue("toothCode")      .And. ;
                        x[5] == oAux:getValue("regionCode")     .And. ;
                        x[6] == oAux:getValue("toothFaceCode") }) == 0

                    //Marca posicao
                    aadd(aAuxEve,{oAux:getValue("procedureGroup"),;
                        oAux:getValue("tableCode"),;
                        oAux:getValue("procedureCode"),;
                        oAux:getValue("toothCode"),;
                        oAux:getValue("regionCode"),;
                        oAux:getValue("toothFaceCode") })

                    oColPagBKS:HasNext() //Ajusta o ponteiro
                    oAuxPag   := oColPagBKS:GetNext()
                    cTipEve   := oAux:getValue("eventType")
                    cIdPacote := oAux:getValue("package")

                    if oAux:getValue("tableCode")       == oAuxPag:getValue("tableCode")      .And. ;
                            oAux:getValue("procedureCode")  == oAuxPag:getValue("procedureCode")  .And. ;
                            oAux:getValue("procedureGroup") == oAuxPag:getValue("procedureGroup") .And. ;
                            oAux:getValue("toothCode")      == oAuxPag:getValue("toothCode")      .And. ;
                            oAux:getValue("toothFaceCode")  == oAuxPag:getValue("toothFaceCode")  .And. ;
                            oAux:getValue("regionCode")     == oAuxPag:getValue("regionCode")

                        //Adiciono o valor do procedimento ajustado
                        oAux:setValue("procedureValuePaid",oAuxPag:getValue("procedureValuePaid"))
                    endIf

                    //Monta totalizadores
                    oCalTot:calGuiMon(oAux,cTipEve)

                    self:grvHisBRG(oAux,cTipEve) //Grava historico - eventos
                    oAuxPag:destroy()
                    oAux:destroy()
                endIf

            endDo
        endif
        oColPagBKS:destroy()

        //Nao tem dois pagamentos, restauro a ultima transacao enviada
    elseIf oColBKS:bscLastEve(aTransExc)

        aadd(aAuxEve,{"","","","","",""}) //Monto uma posicao vazia para nao quebrar o aScan

        while oColBKS:HasNext()

            oAux := oColBKS:GetNext()

            if aScan(aAuxEve,{|x| x[1] == oAux:getValue("procedureGroup") .And. ;
                    x[2] == oAux:getValue("tableCode")      .And. ;
                    x[3] == oAux:getValue("procedureCode")  .And. ;
                    x[4] == oAux:getValue("toothCode")      .And. ;
                    x[5] == oAux:getValue("regionCode")     .And. ;
                    x[6] == oAux:getValue("toothFaceCode") }) == 0

                //Marca posicao
                aadd(aAuxEve,{oAux:getValue("procedureGroup"),;
                    oAux:getValue("tableCode"),;
                    oAux:getValue("procedureCode"),;
                    oAux:getValue("toothCode"),;
                    oAux:getValue("regionCode"),;
                    oAux:getValue("toothFaceCode") })

                cTipEve   := oAux:getValue("eventType")
                cIdPacote := oAux:getValue("package")

                self:grvHisBRG(oAux,cTipEve) //Grava historico - eventos

            endIf
            oAux:destroy()

        endDo
    endIf

    oColBKS:destroy()

    //---------------------------------------------------------
    //              Gravacao de Pacotes
    //---------------------------------------------------------
    oColBKT := CenCltBKT():New()
    oColBKT:SetValue("operatorRecord"    ,oAuxBKR:getValue("operatorRecord"))
    oColBKT:SetValue("operatorFormNumber",oAuxBKR:getValue("operatorFormNumber"))
    oColBKT:SetValue("requirementCode"   ,oAuxBKR:getValue("requirementCode"))
    oColBKT:SetValue("referenceYear"     ,oAuxBKR:getValue("referenceYear"))
    oColBKT:SetValue("commitmentCode"    ,oAuxBKR:getValue("commitmentCode"))
    oColBKT:SetValue("batchCode"         ,oAuxBKR:getValue("batchCode"))
    oColBKT:SetValue("formProcDt"        ,oAuxBKR:getValue("formProcDt"))

    if oColBKT:buscar()
        while oColBKT:HasNext()
            oAux       := oColBKT:GetNext()
            cCodTab    := oAux:getValue("tableCode")
            cCodPro    := oAux:getValue("procedureCode")

            self:grvHisBRH(oAux,cCodTab,cCodPro) //Grava historico - eventos
            oAux:destroy()
        endDo
    endIf
    oColBKT:destroy()
    //---------------------------------------------------------
    //              Gravacao de Declaracoes
    //---------------------------------------------------------
    oColBN0 := CenCltBN0():New()
    oColBN0:SetValue("operatorRecord"    ,oAuxBKR:getValue("operatorRecord"))
    oColBN0:SetValue("operatorFormNumber",oAuxBKR:getValue("operatorFormNumber"))
    oColBN0:SetValue("requirementCode"   ,oAuxBKR:getValue("requirementCode"))
    oColBN0:SetValue("referenceYear"     ,oAuxBKR:getValue("referenceYear"))
    oColBN0:SetValue("commitmentCode"    ,oAuxBKR:getValue("commitmentCode"))
    oColBN0:SetValue("batchCode"         ,oAuxBKR:getValue("batchCode"))
    oColBN0:SetValue("formProcDt"        ,oAuxBKR:getValue("formProcDt"))

    if oColBN0:buscar()
        while oColBN0:HasNext()
            oAuxDec  := oColBN0:GetNext()
            self:grvHisBNY(oAuxDec) //Grava historico - declaracoes nascido/obito
            oAuxDec:destroy()
        endDo
    endIf
    oColBN0:destroy()

    //---------------------------------------------------------
    //              Gravacao de Cabecalho
    //---------------------------------------------------------
    if !lRecalcPag
        oCalTot := CenMoTotGu():New() //Objeto para totalizadores do cabecalho
        oCalTot:carGuiMon(oAuxBKR)
    endIf

    self:grvHisBRF(oAuxBKR,oCalTot) //Grava historico - cabecalho
    oCalTot:destroy()

Return


//------------------------------------------------------------------------------------------
/*/{Protheus.doc} delMovBKR
    Deleta os eventos BKR de uma movimentacao pendente

    @type  Class
    @author renan.almeida
    @since 20190320
/*/
//------------------------------------------------------------------------------------------
Method delMovBKR(oAuxBKR) Class CenPrMoGui

    Local oCltBKR := CenCltBKR():New()
    Local oObjDel := nil
    Local oAux    := nil

    oCltBKR:SetValue("operatorRecord"    ,oAuxBKR:getValue("operatorRecord"))     //BKR_CODOPE
    oCltBKR:SetValue("operatorFormNumber",oAuxBKR:getValue("operatorFormNumber")) //BKR_NMGOPE
    oCltBKR:SetValue("requirementCode"   ,oAuxBKR:getValue("requirementCode"))    //BKR_CDOBRI
    oCltBKR:SetValue("referenceYear"     ,oAuxBKR:getValue("referenceYear"))      //BKR_ANO
    oCltBKR:SetValue("commitmentCode"    ,oAuxBKR:getValue("commitmentCode"))     //BKR_CDCOMP
    oCltBKR:SetValue("batchCode"         ,oAuxBKR:getValue("batchCode"))          //BKR_LOTE
    oCltBKR:SetValue("formProcDt"        ,oAuxBKR:getValue("formProcDt"))         //BKR_DTPRGU

    if oCltBKR:buscar()

        while oCltBKR:HasNext()
            oAux := oCltBKR:GetNext()
            //Chave primaria - BKR_FILIAL, BKR_CODOPE, BKR_NMGOPE, BKR_CDOBRI, BKR_ANO, BKR_CDCOMP, BKR_LOTE, BKR_DTPRGU
            oObjDel := CenCltBKR():New()
            oObjDel:SetValue("operatorRecord"    ,oAux:getValue("operatorRecord"))     //BKR_CODOPE
            oObjDel:SetValue("operatorFormNumber",oAux:getValue("operatorFormNumber")) //BKR_NMGOPE
            oObjDel:SetValue("requirementCode"   ,oAux:getValue("requirementCode"))    //BKR_CDOBRI
            oObjDel:SetValue("referenceYear"     ,oAux:getValue("referenceYear"))      //BKR_ANO
            oObjDel:SetValue("commitmentCode"    ,oAux:getValue("commitmentCode"))     //BKR_CDCOMP
            oObjDel:SetValue("batchCode"         ,oAux:getValue("batchCode"))          //BKR_LOTE
            oObjDel:SetValue("formProcDt"        ,oAux:getValue("formProcDt"))         //BKR_DTPRGU

            oObjDel:delete()
            oObjDel:destroy()
            FreeObj(oObjDel)
            oObjDel := nil
            oAux:destroy()
            FreeObj(oAux)
            oAux := nil

        endDo

    endIf
    oCltBKR:destroy()

Return


//------------------------------------------------------------------------------------------
/*/{Protheus.doc} delMovBKS
    Deleta os eventos BKS de uma movimentacao pendente

    @type  Class
    @author renan.almeida
    @since 20190320
/*/
//------------------------------------------------------------------------------------------
Method delMovBKS(oAuxBKR) Class CenPrMoGui

    Local oCltBKS := CenCltBKS():New()
    Local oObjDel := nil
    Local oAux    := nil

    oCltBKS:SetValue("operatorRecord"    ,oAuxBKR:getValue("operatorRecord"))     //BKS_CODOPE
    oCltBKS:SetValue("operatorFormNumber",oAuxBKR:getValue("operatorFormNumber")) //BKS_NMGOPE
    oCltBKS:SetValue("requirementCode"   ,oAuxBKR:getValue("requirementCode"))    //BKS_CDOBRI
    oCltBKS:SetValue("referenceYear"     ,oAuxBKR:getValue("referenceYear"))      //BKS_ANO
    oCltBKS:SetValue("commitmentCode"    ,oAuxBKR:getValue("commitmentCode"))     //BKS_CDCOMP
    oCltBKS:SetValue("batchCode"         ,oAuxBKR:getValue("batchCode"))          //BKS_LOTE
    oCltBKS:SetValue("formProcDt"        ,oAuxBKR:getValue("formProcDt"))         //BKS_DTPRGU

    if oCltBKS:buscar()

        while oCltBKS:HasNext()

            oAux := oCltBKS:GetNext()
            self:delMovB3F(oAux,"BKS",BKS->(Recno()))
            //Chave primaria - BKS_FILIAL, BKS_CODOPE, BKS_NMGOPE, BKS_CDOBRI, BKS_ANO, BKS_CDCOMP, BKS_LOTE, BKS_DTPRGU, BKS_CODGRU, BKS_CODTAB, BKS_CODPRO, BKS_CDDENT, BKS_CDREGI, BKS_CDFACE
            oObjDel := CenCltBKS():New()
            oObjDel:SetValue("operatorRecord"    ,oAux:getValue("operatorRecord"))     //BKS_CODOPE
            oObjDel:SetValue("operatorFormNumber",oAux:getValue("operatorFormNumber")) //BKS_NMGOPE
            oObjDel:SetValue("requirementCode"   ,oAux:getValue("requirementCode"))    //BKS_CDOBRI
            oObjDel:SetValue("referenceYear"     ,oAux:getValue("referenceYear"))      //BKS_ANO
            oObjDel:SetValue("commitmentCode"    ,oAux:getValue("commitmentCode"))     //BKS_CDCOMP
            oObjDel:SetValue("batchCode"         ,oAux:getValue("batchCode"))          //BKS_LOTE
            oObjDel:SetValue("formProcDt"        ,oAux:getValue("formProcDt"))         //BKS_DTPRGU
            oObjDel:SetValue("procedureGroup"    ,oAux:getValue("procedureGroup"))     //BKS_CODGRU
            oObjDel:SetValue("tableCode"         ,oAux:getValue("tableCode"))          //BKS_CODTAB
            oObjDel:SetValue("procedureCode"     ,oAux:getValue("procedureCode"))      //BKS_CODPRO
            oObjDel:SetValue("toothCode"         ,oAux:getValue("toothCode"))          //BKS_CDDENT
            oObjDel:SetValue("regionCode"        ,oAux:getValue("regionCode"))         //BKS_CDREGI
            oObjDel:SetValue("toothFaceCode"     ,oAux:getValue("toothFaceCode"))      //BKS_CDFACE

            oObjDel:delete()
            oObjDel:destroy()
            oAux:destroy()

        endDo

    endIf
    oCltBKS:destroy()

Return

//------------------------------------------------------------------------------------------
/*/{Protheus.doc} delMovBKT
    Deleta os eventos BKT de uma movimentacao pendente

    @type  Class
    @author renan.almeida
    @since 20190320
/*/
//------------------------------------------------------------------------------------------
Method delMovBKT(oAuxBKR) Class CenPrMoGui

    Local oCltBKT := CenCltBKT():New()
    Local oObjDel := nil
    Local oAux    := nil

    oCltBKT:SetValue("operatorRecord"    ,oAuxBKR:getValue("operatorRecord"))     //BKT_CODOPE
    oCltBKT:SetValue("operatorFormNumber",oAuxBKR:getValue("operatorFormNumber")) //BKT_NMGOPE
    oCltBKT:SetValue("requirementCode"   ,oAuxBKR:getValue("requirementCode"))    //BKT_CDOBRI
    oCltBKT:SetValue("referenceYear"     ,oAuxBKR:getValue("referenceYear"))      //BKT_ANO
    oCltBKT:SetValue("commitmentCode"    ,oAuxBKR:getValue("commitmentCode"))     //BKT_CDCOMP
    oCltBKT:SetValue("batchCode"         ,oAuxBKR:getValue("batchCode"))          //BKT_LOTE
    oCltBKT:SetValue("formProcDt"        ,oAuxBKR:getValue("formProcDt"))         //BKT_DTPRGU

    if oCltBKT:buscar()

        while oCltBKT:HasNext()

            oAux := oCltBKT:GetNext()
            self:delMovB3F(oAux,"BKT",BKT->(Recno()))
            //Chave primaria - BKT_FILIAL, BKT_CODOPE, BKT_NMGOPE, BKT_CDOBRI, BKT_ANO, BKT_CDCOMP, BKT_LOTE, BKT_DTPRGU, BKT_CODTAB, BKT_CODPRO, BKT_CDTBIT, BKT_CDPRIT
            oObjDel := CenCltBKT():New()
            oObjDel:SetValue("operatorRecord"    ,oAux:getValue("operatorRecord"))     //BKT_CODOPE
            oObjDel:SetValue("operatorFormNumber",oAux:getValue("operatorFormNumber")) //BKT_NMGOPE
            oObjDel:SetValue("requirementCode"   ,oAux:getValue("requirementCode"))    //BKT_CDOBRI
            oObjDel:SetValue("referenceYear"     ,oAux:getValue("referenceYear"))      //BKT_ANO
            oObjDel:SetValue("commitmentCode"    ,oAux:getValue("commitmentCode"))     //BKT_CDCOMP
            oObjDel:SetValue("batchCode"         ,oAux:getValue("batchCode"))          //BKT_LOTE
            oObjDel:SetValue("formProcDt"        ,oAux:getValue("formProcDt"))         //BKT_DTPRGU
            oObjDel:SetValue("tableCode"         ,oAux:getValue("tableCode"))          //BKT_CODTAB
            oObjDel:SetValue("procedureCode"     ,oAux:getValue("procedureCode"))      //BKT_CODPRO
            oObjDel:SetValue("itemTableCode"     ,oAux:getValue("itemTableCode"))      //BKT_CDDENT
            oObjDel:SetValue("itemProCode"       ,oAux:getValue("itemProCode"))        //BKT_CDREGI

            oObjDel:delete()
            oObjDel:destroy()
            oAux:destroy()

        endDo

    endIf
    oCltBKT:destroy()

Return


//------------------------------------------------------------------------------------------
/*/{Protheus.doc} delMovBN0
    Deleta os eventos BN0 de uma movimentacao pendente

    @type  Class
    @author renan.almeida
    @since 20190320
/*/
//------------------------------------------------------------------------------------------
Method delMovBN0(oAuxBKR) Class CenPrMoGui

    Local oCltBN0 := CenCltBN0():New()
    Local oObjDel := nil
    Local oAux    := nil

    oCltBN0:SetValue("operatorRecord"    ,oAuxBKR:getValue("operatorRecord"))     //BN0_CODOPE
    oCltBN0:SetValue("operatorFormNumber",oAuxBKR:getValue("operatorFormNumber")) //BN0_NMGOPE
    oCltBN0:SetValue("requirementCode"   ,oAuxBKR:getValue("requirementCode"))    //BN0_CDOBRI
    oCltBN0:SetValue("referenceYear"     ,oAuxBKR:getValue("referenceYear"))      //BN0_ANO
    oCltBN0:SetValue("commitmentCode"    ,oAuxBKR:getValue("commitmentCode"))     //BN0_CDCOMP
    oCltBN0:SetValue("batchCode"         ,oAuxBKR:getValue("batchCode"))          //BN0_LOTE
    oCltBN0:SetValue("formProcDt"        ,oAuxBKR:getValue("formProcDt"))         //BN0_DTPRGU

    if oCltBN0:buscar()

        while oCltBN0:HasNext()

            oAux := oCltBN0:GetNext()
            self:delMovB3F(oAux,"BN0",BN0->(Recno()))
            //Chave primaria - BN0_FILIAL, BN0_CODOPE, BN0_NMGOPE, BN0_CDOBRI, BN0_ANO, BN0_CDCOMP, BN0_LOTE, BN0_DTPRGU, BN0_TIPO, BN0_DECNUM
            oObjDel := CenCltBN0():New()
            oObjDel:SetValue("operatorRecord"    ,oAux:getValue("operatorRecord"))     //BN0_CODOPE
            oObjDel:SetValue("operatorFormNumber",oAux:getValue("operatorFormNumber")) //BN0_NMGOPE
            oObjDel:SetValue("requirementCode"   ,oAux:getValue("requirementCode"))    //BN0_CDOBRI
            oObjDel:SetValue("referenceYear"     ,oAux:getValue("referenceYear"))      //BN0_ANO
            oObjDel:SetValue("commitmentCode"    ,oAux:getValue("commitmentCode"))     //BN0_CDCOMP
            oObjDel:SetValue("batchCode"         ,oAux:getValue("batchCode"))          //BN0_LOTE
            oObjDel:SetValue("formProcDt"        ,oAux:getValue("formProcDt"))         //BN0_DTPRGU
            oObjDel:SetValue("certificateType"   ,oAux:getValue("certificateType"))    //BN0_TIPO
            oObjDel:SetValue("certificateNumber" ,oAux:getValue("certificateNumber"))  //BN0_DECNUM

            oObjDel:delete()
            oObjDel:destroy()
            oAux:destroy()

        endDo

    endIf
    oCltBN0:destroy()

Return


//------------------------------------------------------------------------------------------
/*/{Protheus.doc} delMovBRF
    Deleta os eventos BRF de uma movimentacao pendente

    @type  Class
    @author renan.almeida
    @since 20190320
/*/
//------------------------------------------------------------------------------------------
Method delMovBRF(oAuxBRF) Class CenPrMoGui

    Local oCltBRF := CenCltBRF():New()
    Local oObjDel := nil
    Local oAux    := nil

    oCltBRF:SetValue("operatorRecord"    ,oAuxBRF:getValue("operatorRecord"))     //BRF_CODOPE
    oCltBRF:SetValue("operatorFormNumber",oAuxBRF:getValue("operatorFormNumber")) //BRF_NMGOPE

    if oCltBRF:buscar()

        while oCltBRF:HasNext()

            oAux := oCltBRF:GetNext()
            //Chave primaria - BRF_FILIAL, BRF_CODOPE, BRF_NMGOPE
            oObjDel := CenCltBRF():New()
            oObjDel:SetValue("operatorRecord"    ,oAux:getValue("operatorRecord"))     //BRF_CODOPE
            oObjDel:SetValue("operatorFormNumber",oAux:getValue("operatorFormNumber")) //BRF_NMGOPE

            oObjDel:delete()
            oObjDel:destroy()

        endDo

    endIf
    oCltBRF:destroy()

Return


//------------------------------------------------------------------------------------------
/*/{Protheus.doc} delMovBRG
    Deleta os eventos BRG de uma movimentacao pendente

    @type  Class
    @author renan.almeida
    @since 20190320
/*/
//------------------------------------------------------------------------------------------
Method delMovBRG(oAuxBRF) Class CenPrMoGui

    Local oCltBRG := CenCltBRG():New()
    Local oObjDel := nil
    Local oAux    := nil

    oCltBRG:SetValue("operatorRecord"    ,oAuxBRF:getValue("operatorRecord"))     //BRG_CODOPE
    oCltBRG:SetValue("operatorFormNumber",oAuxBRF:getValue("operatorFormNumber")) //BRG_NMGOPE

    if oCltBRG:buscar()

        while oCltBRG:HasNext()

            oAux := oCltBRG:GetNext()
            //Chave primaria - BRG_FILIAL, BRG_CODOPE, BRG_NMGOPE, BRG_CODGRU, BRG_CODTAB, BRG_CODPRO, BRG_CDDENT, BRG_CDREGI, BRG_CDFACE
            oObjDel := CenCltBRG():New()
            oObjDel:SetValue("operatorRecord"    ,oAux:getValue("operatorRecord"))     //BRG_CODOPE
            oObjDel:SetValue("operatorFormNumber",oAux:getValue("operatorFormNumber")) //BRG_NMGOPE
            oObjDel:SetValue("procedureGroup"    ,oAux:getValue("procedureGroup"))     //BRG_CODGRU
            oObjDel:SetValue("tableCode"         ,oAux:getValue("tableCode"))          //BRG_CODTAB
            oObjDel:SetValue("procedureCode"     ,oAux:getValue("procedureCode"))      //BRG_CODPRO
            oObjDel:SetValue("toothCode"         ,oAux:getValue("toothCode"))          //BRG_CDDENT
            oObjDel:SetValue("regionCode"        ,oAux:getValue("regionCode"))         //BRG_CDREGI
            oObjDel:SetValue("toothFaceCode"     ,oAux:getValue("toothFaceCode"))      //BRG_CDFACE

            oObjDel:delete()
            oObjDel:destroy()

        endDo

    endIf
    oCltBRG:destroy()

Return

//------------------------------------------------------------------------------------------
/*/{Protheus.doc} delMovBRH
    Deleta os eventos BRH de uma movimentacao pendente

    @type  Class
    @author renan.almeida
    @since 20190320
/*/
//------------------------------------------------------------------------------------------
Method delMovBRH(oAuxBRF) Class CenPrMoGui

    Local oCltBRH := CenCltBRH():New()
    Local oObjDel := nil
    Local oAux    := nil

    oCltBRH:SetValue("operatorRecord"    ,oAuxBRF:getValue("operatorRecord"))     //BRH_CODOPE
    oCltBRH:SetValue("operatorFormNumber",oAuxBRF:getValue("operatorFormNumber")) //BRH_NMGOPE

    if oCltBRH:buscar()

        while oCltBRH:HasNext()

            oAux := oCltBRH:GetNext()
            //Chave primaria - BRH_FILIAL, BRH_CODOPE, BRH_NMGOPE, BRH_CODTAB, BRH_CODPRO, BRH_CDTBIT, BRH_CDPRIT
            oObjDel := CenCltBRH():New()
            oObjDel:SetValue("operatorRecord"    ,oAux:getValue("operatorRecord"))     //BRH_CODOPE
            oObjDel:SetValue("operatorFormNumber",oAux:getValue("operatorFormNumber")) //BRH_NMGOPE
            oObjDel:SetValue("tableCode"         ,oAux:getValue("tableCode"))          //BRH_CODTAB
            oObjDel:SetValue("procedureCode"     ,oAux:getValue("procedureCode"))      //BRH_CODPRO
            oObjDel:SetValue("itemTableCode"     ,oAux:getValue("itemTableCode"))      //BRH_CDTBIT
            oObjDel:SetValue("itemProCode"       ,oAux:getValue("itemProCode"))        //BRH_CDPRIT

            oObjDel:delete()
            oObjDel:destroy()

        endDo

    endIf
    oCltBRH:destroy()

Return


//------------------------------------------------------------------------------------------
/*/{Protheus.doc} delMovBNY
    Deleta os eventos BNY de uma movimentacao pendente

    @type  Class
    @author renan.almeida
    @since 20190320
/*/
//------------------------------------------------------------------------------------------
Method delMovBNY(oAuxBRF) Class CenPrMoGui

    Local oCltBNY := CenCltBNY():New()
    Local oObjDel := nil
    Local oAux    := nil

    oCltBNY:SetValue("operatorRecord"    ,oAuxBRF:getValue("operatorRecord"))     //BNY_CODOPE
    oCltBNY:SetValue("operatorFormNumber",oAuxBRF:getValue("operatorFormNumber")) //BNY_NMGOPE

    if oCltBNY:buscar()

        while oCltBNY:HasNext()

            oAux := oCltBNY:GetNext()
            //Chave primaria - BNY_FILIAL, BNY_CODOPE, BNY_NMGOPE, BNY_TIPO, BNY_DECNUM
            oObjDel := CenCltBNY():New()
            oObjDel:SetValue("operatorRecord"    ,oAux:getValue("operatorRecord"))     //BNY_CODOPE
            oObjDel:SetValue("operatorFormNumber",oAux:getValue("operatorFormNumber")) //BNY_NMGOPE
            oObjDel:SetValue("certificateType"   ,oAux:getValue("certificateType"))    //BNY_TIPO
            oObjDel:SetValue("certificateNumber" ,oAux:getValue("certificateNumber"))  //BNY_DECNUM

            oObjDel:delete()
            oObjDel:destroy()

        endDo

    endIf
    oCltBNY:destroy()

Return


//------------------------------------------------------------------------------------------
/*/{Protheus.doc} atuProcAPI
    Marca a guia como processada no Alais da API BRA

    @type  Class
    @author renan.almeida
    @since 20190320
/*/
//------------------------------------------------------------------------------------------
Method atuProcAPI() Class CenPrMoGui

    Local oCltBRA := CenCltBRA():New()

    oCltBRA:SetValue("operatorRecord",self:cCodOpe)
    oCltBRA:SetValue("formSequential",self:cSeqGui)

    if oCltBRA:bscChaPrim()
        oCltBRA:mapFromDao()
        oCltBRA:SetValue("processed","1")
        oCltBRA:update()
    endIf
    oCltBRA:destroy()

Return