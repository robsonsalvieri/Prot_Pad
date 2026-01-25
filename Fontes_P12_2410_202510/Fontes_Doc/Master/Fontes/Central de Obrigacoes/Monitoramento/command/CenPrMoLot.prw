#include "TOTVS.CH"

//------------------------------------------------------------------------------------------
/*/{Protheus.doc} CenPrMoLot
    Classe abstrata para execução de comandos
    @type  Class
    @author renan.almeida
    @since 20190320
/*/
//------------------------------------------------------------------------------------------
Class CenPrMoLot

    Data oExecutor

    Data cCodOpe as String
    Data nQtdMaxGui as Integer

    Method New(oExecutor) Constructor

    Method procAddLot()
    Method qtdGuiLote(oAuxCab,oQtdGuias)
    Method procLotGen(oCltAux,cTipRem)
    Method grvProcMon(oAux,nQtdGuias,cTipRem)
    Method grvMovBKW(oAux)
    Method atuEventos(oAux,nQtdGuias,cCodLote,cTipRem)
            
EndClass


//------------------------------------------------------------------------------------------
/*/{Protheus.doc} New 
    Metodo construtor da classe proGuiaAPI
    @type  Class
    @author renan.almeida
    @since 20190320
/*/
//------------------------------------------------------------------------------------------
Method New(oExecutor) Class CenPrMoLot
   
    self:cCodOpe    := ""
    self:nQtdMaxGui := 10000
        
Return self


//------------------------------------------------------------------------------------------
/*/{Protheus.doc} procAddLot
    Processa todos os metodos de adicao de guias, fornecimento direto, outra remuneracao,
    valor pre-estabelecidos pendentes

    @type  Class
    @author renan.almeida
    @since 20190320
/*/
//------------------------------------------------------------------------------------------
Method procAddLot() Class CenPrMoLot

    Local oCltBKR := CenCltBKR():New()
    Local oCltBVQ := CenCltBVQ():New()
    Local oCltBVZ := CenCltBVZ():New()
    Local oCltB9T := CenCltB9T():New()

    //Guias Monitoramento
    self:procLotGen(oCltBKR,"1")
    oCltBKR:destroy()

    //Fornecimento Direto
    self:procLotGen(oCltBVQ,"2")
    oCltBVQ:destroy()
   
    //Outra Remuneracao
    self:procLotGen(oCltBVZ,"3")
    oCltBVZ:destroy()

    //Valor Pre-estabelecido
    self:procLotGen(oCltB9T,"4")
    oCltB9T:destroy()

Return


//------------------------------------------------------------------------------------------
/*/{Protheus.doc} procLotGen
    Adiciona ao lote, eventos de monitoramento pendente

    @type  Class
    @author renan.almeida
    @since 20190320
/*/
//------------------------------------------------------------------------------------------
Method procLotGen(oCltAux,cTipRem) Class CenPrMoLot
    
    Local cAlias    := ""
    Local nQtdGuias := 0
    Local aFields   := {}
    
    Do Case 
        Case cTipRem == "1"
            cAlias := "BKR"
        Case cTipRem == "2"    
            cAlias := "BVQ"
        Case cTipRem == "3"    
            cAlias := "BVZ"
        Case cTipRem == "4"
            cAlias := "B9T"
    EndCase

    aAdd(aFields,{cAlias+"_CDOBRI" ,"requirementCode"})
    aAdd(aFields,{cAlias+"_ANO"    ,"referenceYear"})
    aAdd(aFields,{cAlias+"_CDCOMP" ,"commitmentCode"})
    oCltAux:changeFields(aFields)
    oCltAux:setValue("operatorRecord",self:cCodOpe)
    
    //Verifica se ha guias pendentes para serem adicionadas a algum lote, retorna o e Ano/Mes
    if oCltAux:bscAddLote() 

        while oCltAux:HasNext()
  
            oCompEvent := oCltAux:GetNext()
            
            Do Case 
                Case cTipRem == "1" //Guias Monitoramento
                    oQtdGuias := CenCltBKR():New()
                Case cTipRem == "2" //Fornecimento Direto
                    oQtdGuias := CenCltBVQ():New()
                Case cTipRem == "3" //Outra Remuneracao   
                    oQtdGuias := CenCltBVZ():New()
                Case cTipRem == "4" //Valor Pre-estabelecido
                    oQtdGuias := CenCltB9T():New()
            EndCase

            nQtdGuias := self:qtdGuiLote(oCompEvent,oQtdGuias) //Verifica a quantidade de guias que serao adicionadas
            oQtdGuias:destroy()

            if nQtdGuias > 0
                self:grvProcMon(oCompEvent,nQtdGuias,cTipRem)
            endIf

            oCompEvent:destroy()
        endDo
    endIf
    
Return



//------------------------------------------------------------------------------------------
/*/{Protheus.doc} qtdGuiLote
    Verifica a quantidade de guias prontas para serem adicionadas no lote

    @type  Class
    @author renan.almeida
    @since 20190320
/*/
//------------------------------------------------------------------------------------------
Method qtdGuiLote(oAuxCab,oQtdGuias) Class CenPrMoLot

    Local nQtdGuias := 0

    oQtdGuias:setValue("operatorRecord" ,self:cCodOpe)
    oQtdGuias:setValue("requirementCode",oAuxCab:getValue("requirementCode"))
    oQtdGuias:setValue("referenceYear"  ,oAuxCab:getValue("referenceYear"))
    oQtdGuias:setValue("commitmentCode" ,oAuxCab:getValue("commitmentCode"))

    nQtdGuias := oQtdGuias:qtdGuiComp()

Return nQtdGuias


//------------------------------------------------------------------------------------------
/*/{Protheus.doc} atuEventos
    Verifica os lotes que serao criados/atualizados 
    Atualiza as guias com o lote correspondente 

    @type  Class
    @author renan.almeida
    @since 20190320
/*/
//------------------------------------------------------------------------------------------
Method atuEventos(oAux,nQtdGuias,cCodLote,cTipRem) Class CenPrMoLot

    Local aAlias  := {}
    Local nX      := 0
    
    Do Case
        Case cTipRem == "1" //Guia Monitoramento
            oGrvBKR := CenCltBKR():New()
            Aadd(aAlias,oGrvBKR)
            oGrvBKS := CenCltBKS():New()
            Aadd(aAlias,oGrvBKS)
            oGrvBKT := CenCltBKT():New()
            Aadd(aAlias,oGrvBKT)
            oGrvBN0 := CenCltBN0():New()
            Aadd(aAlias,oGrvBN0)
        
        Case cTipRem == "2" //Fornecimento Direto 
            oGrvBVQ := CenCltBVQ():New()
            Aadd(aAlias,oGrvBVQ)
            oGrvBVT := CenCltBVT():New()
            Aadd(aAlias,oGrvBVT)

        Case cTipRem == "3" //Outra Remuneracao
            oGrvBVZ := CenCltBVZ():New()
            Aadd(aAlias,oGrvBVZ)

        Case cTipRem == "4" //Valor Pre-Estabelecido
            oGrvB9T := CenCltB9T():New()
            Aadd(aAlias,oGrvB9T)    
    EndCase

    for nX := 1 to len(aAlias)
        aAlias[nX]:setValue("operatorRecord" ,self:cCodOpe)
        aAlias[nX]:setValue("requirementCode",oAux:getValue("requirementCode"))
        aAlias[nX]:setValue("commitmentCode" ,oAux:getValue("commitmentCode"))
        aAlias[nX]:setValue("referenceYear"  ,oAux:getValue("referenceYear"))
        aAlias[nX]:setValue("batchCode"      ,cCodLote)
        aAlias[nX]:atuCodLote(nQtdGuias)
        aAlias[nX]:destroy()
    next

Return


//------------------------------------------------------------------------------------------
/*/{Protheus.doc} grvMovBKW
    Gera um novo registro de lote

    @type  Class
    @author renan.almeida
    @since 20190320
/*/
//------------------------------------------------------------------------------------------
Method grvMovBKW(oAux) Class CenPrMoLot

    Local oColBKW  := CenCltBKW():New()
    Local cCodLote := GetSXENum( "BKW","BKW_CODLOT" )
	
    BRA->(ConfirmSX8())

    //Chave primaria - BKW_FILIAL, BKW_CODOPE, BKW_CODLOT
    oColBKW:SetValue("operatorRecord"  ,self:cCodOpe) //BKW_CODOPE
    oColBKW:SetValue("batchCode"       ,cCodLote)     //BKW_CODLOT

    oColBKW:SetValue("requirementCode" ,oAux:getValue("requirementCode")) //BKW_CDOBRI
    oColBKW:SetValue("commitmentCode"  ,oAux:getValue("commitmentCode")) //BKW_CDCOMP
    oColBKW:SetValue("referenceYear"   ,oAux:getValue("referenceYear")) ///BKW_ANO
    oColBKW:SetValue("status"          ,oAux:getValue("status")) //BKW_STATUS
    oColBKW:SetValue("remunerationType",oAux:getValue("remunerationType")) //BKW_FORREM
    oColBKW:SetValue("file"            ,oAux:getValue("file")) //BKW_ARQUIV
    oColBKW:SetValue("processingDate"  ,oAux:getValue("processingDate")) //BKW_DATPRO
    oColBKW:SetValue("processingTime"  ,oAux:getValue("processingTime")) //BKW_HORPRO
    oColBKW:SetValue("version"         ,oAux:getValue("version")) //BKW_VERSAO

    oColBKW:insert()
    oColBKW:destroy()

 Return cCodLote


//------------------------------------------------------------------------------------------
/*/{Protheus.doc} grvProcMon
    Realiza o processamento/gravacao dos eventos do monitoramento

    @type  Class
    @author renan.almeida
    @since 20190320
/*/
//------------------------------------------------------------------------------------------
Method grvProcMon(oAux,nQtdGuias,cTipRem) Class CenPrMoLot

    Local oCltBKW    := CenCltBKW():New()
    Local nQtdGuiLot := 0
    Local cCodLote   := ""

    oCltBKW:setValue("operatorRecord",self:cCodOpe)
    oCltBKW:setValue("requirementCode",oAux:getValue("requirementCode"))
    oCltBKW:setValue("referenceYear"  ,oAux:getValue("referenceYear"))
    oCltBKW:setValue("commitmentCode" ,oAux:getValue("commitmentCode"))
    oCltBKW:setValue("remunerationType",cTipRem)

    //Verifica se tem lote ja cadastrado para a competencia
    cCodLote := oCltBKW:bscUltLote()

    //Cria um novo lote
    if empty(cCodLote)
        oNovLotBKW := CenCltBKW():New()
        oNovLotBKW:setValue("operatorRecord"  ,self:cCodOpe)
        oNovLotBKW:setValue("requirementCode" ,oAux:getValue("requirementCode"))
        oNovLotBKW:setValue("commitmentCode"  ,oAux:getValue("commitmentCode"))
        oNovLotBKW:setValue("referenceYear"   ,oAux:getValue("referenceYear"))
        oNovLotBKW:setValue("remunerationType",cTipRem)
        oNovLotBKW:setValue("status","1")
        cCodLote := self:grvMovBKW(oNovLotBKW)
        oNovLotBKW:destroy()

    //Verifica a quantidade de guias que ja estao no lote atingiram o limite de 10k
    else    
		Do Case
			Case cTipRem == "1"
       	 		oQtdGui := CenCltBKR():New() //Guia Monitoramento
			Case cTipRem == "2"
				oQtdGui := CenCltBVQ():New() //Fornecimento Direto
			Case cTipRem == "3"
       	 		oQtdGui := CenCltBVZ():New() //Outra Remuneracao
			Case cTipRem == "4"
       	 		oQtdGui := CenCltB9T():New() //Valor Pre-Estabelecido
		EndCase	
        oQtdGui:setValue("operatorRecord" ,self:cCodOpe)
        oQtdGui:setValue("requirementCode",oAux:getValue("requirementCode"))
        oQtdGui:setValue("commitmentCode" ,oAux:getValue("commitmentCode"))
        oQtdGui:setValue("referenceYear"  ,oAux:getValue("referenceYear"))
        oQtdGui:setValue("batchCode"      ,cCodLote)     
        nQtdGuiLot := oQtdGui:qtdGuiComp()
        oQtdGui:destroy()
    endIf

    //Quantidade de guias e inferior a 10k, adiciono no lote
    if nQtdGuiLot + nQtdGuias < self:nQtdMaxGui 
        self:atuEventos(oAux,nQtdGuias,cCodLote,cTipRem)
    //Quantidade superior, devo criar um novo lote
    else
        //Vejo a quantidade de guias que ainda cabem no lote e adiciono
        nQtdPrimLot := self:nQtdMaxGui - nQtdGuiLot
        self:atuEventos(oAux,nQtdPrimLot,cCodLote,cTipRem)

        //Verifico a quantidade de guias restantes
        nQtdResGui := nQtdGuias - nQtdPrimLot

        //Vou rodar este trecho ate nao tiver mais guias para adicionar    
        while nQtdResGui > 0

            //Gero um novo lote
            oNovLotBKW := CenCltBKW():New()
            oNovLotBKW:setValue("operatorRecord"  ,self:cCodOpe)
            oNovLotBKW:setValue("requirementCode" ,oAux:getValue("requirementCode"))
            oNovLotBKW:setValue("commitmentCode"  ,oAux:getValue("commitmentCode"))
            oNovLotBKW:setValue("referenceYear"   ,oAux:getValue("referenceYear"))
            oNovLotBKW:setValue("remunerationType",cTipRem)
            oNovLotBKW:setValue("status","1")
            cCodLote := self:grvMovBKW(oNovLotBKW)

            if nQtdResGui <= self:nQtdMaxGui
                self:atuEventos(oAux,nQtdResGui,cCodLote,cTipRem)
                nQtdResGui := 0
            else
                self:atuEventos(oAux,self:nQtdMaxGui,cCodLote,cTipRem)
                nQtdResGui := nQtdResGui - self:nQtdMaxGui
            endIf
            oNovLotBKW:destroy()

        endDo

    endIf
       
    oCltBKW:destroy()

Return