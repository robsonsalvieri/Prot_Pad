#include "TOTVS.CH"
#define idTraInc  "1"
#define idTraAlt  "2"
#define idTraExc  "3"
#define idExcGuia "1"

//------------------------------------------------------------------------------------------
/*/{Protheus.doc}CenPrMoRem
    Classe abstrata para execução de comandos
    @type  Class
    @author renan.almeida
    @since 20190320
/*/
//------------------------------------------------------------------------------------------
Class CenPrMoRem From CenProcMon

    Data cCpfCnpj as String

    Method New() Constructor
    Method proRemuAPI()
    Method loadChave(oAuxCab)
    Method atuProcAPI()
    Method verTraPend(oAuxCab)
    //Metodos de inclusao
    Method procInclus(oAuxCab)
    //Metodos de commit de dados
    Method grvMovBVZ(oAuxCab)
    //Metodos de exclusao
    Method excTransac()
    Method delMovBVZ(oAuxBVZ)
    //Metodos de alteracao
    Method verAlter(oAuxCab)
    
EndClass


//------------------------------------------------------------------------------------------
/*/{Protheus.doc} New 
    Metodo construtor da classe proGuiaAPI
    @type  Class
    @author renan.almeida
    @since 20190320
/*/
//------------------------------------------------------------------------------------------
Method New() Class CenPrMoRem

    _Super:new()
    self:cCpfCnpj := ""

return self



//------------------------------------------------------------------------------------------
/*/{Protheus.doc} proRemuAPI
    Processa uma guia enviada para a API
    @type  Class
    @author renan.almeida
    @since 20190320
/*/
//------------------------------------------------------------------------------------------
Method proRemuAPI(oAuxCab) Class CenPrMoRem

    Local oColB2V   := CenCltB2V():New()
    Default oAuxCab   := Nil
    
    oColB2V:SetValue("operatorRecord",self:cCodOpe)
    oColB2V:SetValue("formSequential",self:cSeqGui)

    If oColB2V:bscChaPrim()

        oAuxCab := oColB2V:GetNext() //Carrega cabecalho API
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
        self:atuProcAPI() //Atualiza registro na BVZ como processado
        
        oAuxCab:destroy()
    endIf
    oColB2V:destroy()
    
Return

//------------------------------------------------------------------------------------------
/*/{Protheus.doc} loadChave
    Carrega para o objeto principal, dados que vou utilizar nas chaves primarias

    @type  Class
    @author vinicius.nicolau
    @since 20200817
/*/
//------------------------------------------------------------------------------------------
Method loadChave(oAuxCab) Class CenPrMoRem
    
    Local cAno      := Substr(oAuxCab:getValue("formProcDt"),1,4)
    Local cMes      := Strzero(Val(Substr(oAuxCab:getValue("formProcDt"),5,2)),3)
    Local oColB3A   := CenCltObri():New() 
    Local oAux      := nil
    Local cCodObrig := ""
  
    oColB3A:SetValue("obligationType","5")
    oColB3A:SetValue("activeInactive","1")
    oColB3A:SetValue("operatorRecord",oAuxCab:getValue("operatorRecord"))

    if oColB3A:buscar() .And. oColB3A:HasNext()
        oAux      := oColB3A:GetNext()
        cCodObrig := oAux:GetValue("requirementCode")
    endIf 

    self:cCodObrig := cCodObrig
    self:cAno      := cAno
    self:cMes      := cMes
    self:cCpfCnpj  := oAuxCab:getValue("providerCpfCnpj")
    self:dProcGuia := oAuxCab:getValue("formProcDt")

    oColB3A:destroy()
    FreeObj(oColB3A)
    oColB3A := nil

Return

//------------------------------------------------------------------------------------------
/*/{Protheus.doc} procInclus
    Marca a guia como processada no Alais da API BVZ 

    @type  Class
    @author renan.almeida
    @since 20190320
/*/
//------------------------------------------------------------------------------------------
Method procInclus(oAuxCab) Class CenPrMoRem

    self:grvMovBVZ(oAuxCab) //Gera movimentacao

Return

//------------------------------------------------------------------------------------------
/*/{Protheus.doc} verTraPend
    Alteração de um registro não enviado para a ANS, devemos excluir a mais antiga
   
    @type  Class
    @author renan.almeida
    @since 20190320
/*/
//------------------------------------------------------------------------------------------
Method verTraPend(oAuxCab) Class CenPrMoRem

    Local oColBVZ := CenCltBVZ():New()
    Local oObjBVZ := nil

    oColBVZ:SetValue("operatorRecord"  ,self:cCodOpe)
    oColBVZ:SetValue("providerCpfCnpj" ,self:cCpfCnpj)
    oColBVZ:SetValue("requirementCode" ,self:cCodObrig)
    oColBVZ:SetValue("referenceYear"   ,self:cAno)
    oColBVZ:SetValue("commitmentCode"  ,self:cMes)

    if oColBVZ:bscMovPend() //Busca transacoes pendentes com o Status: 1=Pendente Envio;2=Criticado;3=Pronto para o Envio
        
        while oColBVZ:HasNext() //Coloquei um While, mas teoricamente so tera um registro

            oObjBVZ := oColBVZ:GetNext()
            //Se a data de inclusao do registro ja processado é inferior a que estou processando no momento,
            //excluo o registro existente para criar um novo registro atualizado 
            if (oObjBVZ:getValue("inclusionDate") <  oAuxCab:getValue("inclusionDate")) .Or. ;
               (oObjBVZ:getValue("inclusionDate") == oAuxCab:getValue("inclusionDate") .And. ;
                oObjBVZ:getValue("inclusionTime") <  oAuxCab:getValue("inclusionTime"))
                self:delMovB3F(oObjBVZ,"BVZ",BVZ->(Recno()))
                self:delMovBVZ(oObjBVZ)
              
            //Se a transacao que estou processando for mais velha que o registro ja criado, ignoro a transacao            
            else
                self:lOkProces := .F.
            endIf
            oObjBVZ:destroy()
        endDo

    endIf
    oColBVZ:destroy()
   
Return


//------------------------------------------------------------------------------------------
/*/{Protheus.doc} excTransac
    Processa a exclusao de uma transacao

    @type  Class
    @author renan.almeida
    @since 20190320
/*/
//------------------------------------------------------------------------------------------
Method excTransac() Class CenPrMoRem

    Local oColBVZ := CenCltBVZ():New()
    Local oObjBVZ := nil

    oColBVZ:SetValue("operatorRecord"  ,self:cCodOpe)
    oColBVZ:SetValue("providerCpfCnpj" ,self:cCpfCnpj)
    oColBVZ:SetValue("requirementCode" ,self:cCodObrig) 
    oColBVZ:SetValue("formProcDt"      ,self:dProcGuia)

    if oColBVZ:bscMovExcl()
        
        oObjBVZ := oColBVZ:GetNext()

        //So processarei se a ultima transacao nao for uma Exclusao
        if oObjBVZ:getValue("monitoringRecordType") <> idTraExc
            
            //Verifico o status, se nao foi enviada para a ANS, excluo a transacao
            if oObjBVZ:getValue("status") $ "1/2/3/7" //1=Pendente Envio;2=Criticado;3=Pronto para o Envio;4=Em processamento ANS;5=Criticado pela ANS;6=Finalizado
                self:delMovBVZ(oObjBVZ)
            //Ja foi enviado para ANS, devo gerar uma transacao de exclusao
            elseIf oObjBVZ:getValue("status") $ "4/6/8"
                self:lOkProces := .F. //Vou gravar a guia por aqui
                self:comAltExc(oObjBVZ) //Padrao para exclusao e gerar na proxima competencia
                self:cTipRegist := idTraExc
                self:grvMovBVZ(oObjBVZ) //Grava movimentacao - cabecalho
            endif

        endIf    
        oObjBVZ:destroy()

    endIf
    oColBVZ:destroy()

Return


//------------------------------------------------------------------------------------------
/*/{Protheus.doc} grvMovBVZ
    Grava a movimentacao da BVZ

    @type  Class
    @author renan.almeida
    @since 20190320
/*/
//------------------------------------------------------------------------------------------
Method grvMovBVZ(oAuxCab) Class CenPrMoRem
   
    Local oColBVZ   := CenCltBVZ():New()
    Local cProcTime := Substr(Time(),1,2)+Substr(Time(),4,2)+Substr(Time(),7,2)

    //Chave primaria - BVZ_FILIAL, BVZ_CODOPE, BVZ_CPFCNP, BVZ_CDOBRI, BVZ_ANO, BVZ_CDCOMP, BVZ_LOTE, BVZ_DTPROC
    oColBVZ:SetValue("operatorRecord"  ,self:cCodOpe)    //BVZ_CODOPE
    oColBVZ:SetValue("providerCpfCnpj" ,self:cCpfCnpj)   //B2V_CPFCNP
    oColBVZ:SetValue("requirementCode" ,self:cCodObrig)  //BVZ_CDOBRI
    oColBVZ:SetValue("referenceYear"   ,self:cAno)       //BVZ_ANO
    oColBVZ:SetValue("commitmentCode"  ,self:cMes)       //BVZ_CDCOMP
    oColBVZ:SetValue("batchCode"       ,self:cLote)      //BVZ_LOTE
    oColBVZ:SetValue("formProcDt"      ,self:dProcGuia)  //BVZ_DTPROC
   
    oColBVZ:SetValue("status"              ,self:cStatus)
    oColBVZ:SetValue("monitoringRecordType",self:cTipRegist)
    oColBVZ:SetValue("totalDisallowValue"  ,oAuxCab:getValue("totalDisallowValue"))
    oColBVZ:SetValue("totalValueEntered"   ,oAuxCab:getValue("totalValueEntered"))
    oColBVZ:SetValue("totalValuePaid"      ,oAuxCab:getValue("totalValuePaid"))
    oColBVZ:SetValue("inclusionTime"       ,oAuxCab:getValue("inclusionTime"))
    oColBVZ:SetValue("identReceipt"        ,oAuxCab:getValue("identReceipt"))
    oColBVZ:SetValue("inclusionDate"       ,oAuxCab:getValue("inclusionDate"))
    oColBVZ:SetValue("processingDate"      ,Dtos(dDataBase))
    oColBVZ:SetValue("processingTime"      ,cProcTime)

    //Commit dos itens
    oColBVZ:insert()
    oColBVZ:destroy()

Return

//------------------------------------------------------------------------------------------
/*/{Protheus.doc} delMovBVZ
    Deleta os eventos BVZ de uma movimentacao pendente

    @type  Class
    @author renan.almeida
    @since 20190320
/*/
//------------------------------------------------------------------------------------------
Method delMovBVZ(oAuxBVZ) Class CenPrMoRem

    Local oCltBVZ := CenCltBVZ():New()
    Local oObjDel := nil
    Local oAux    := nil

    oCltBVZ:SetValue("operatorRecord"  ,oAuxBVZ:getValue("operatorRecord"))   //BVZ_CODOPE
    oCltBVZ:SetValue("providerCpfCnpj" ,oAuxBVZ:getValue("providerCpfCnpj"))  //BVZ_B2V_CPFCNP
    oCltBVZ:SetValue("requirementCode" ,oAuxBVZ:getValue("requirementCode"))  //BVZ_CDOBRI
    oCltBVZ:SetValue("referenceYear"   ,oAuxBVZ:getValue("referenceYear"))    //BVZ_ANO
    oCltBVZ:SetValue("commitmentCode"  ,oAuxBVZ:getValue("commitmentCode"))   //BVZ_CDCOMP
    oCltBVZ:SetValue("batchCode"       ,oAuxBVZ:getValue("batchCode"))        //BVZ_LOTE
    oCltBVZ:SetValue("formProcDt"      ,oAuxBVZ:getValue("formProcDt"))       //BVZ_DTPRGU

    if oCltBVZ:buscar()
    
        while oCltBVZ:HasNext() 

            oAux := oCltBVZ:GetNext()
            //Chave primaria - BVZ_FILIAL, BVZ_CODOPE, BVZ_CPFCNP, BVZ_CDOBRI, BVZ_ANO, BVZ_CDCOMP, BVZ_LOTE, BVZ_DTPROC
            oObjDel := CenCltBVZ():New()
            oObjDel:SetValue("operatorRecord"  ,oAux:getValue("operatorRecord"))  //BVZ_CODOPE
            oObjDel:SetValue("providerCpfCnpj" ,oAux:getValue("providerCpfCnpj")) //BVZ_NMGPRE
            oObjDel:SetValue("requirementCode" ,oAux:getValue("requirementCode")) //BVZ_CDOBRI
            oObjDel:SetValue("referenceYear"   ,oAux:getValue("referenceYear"))   //BVZ_ANO
            oObjDel:SetValue("commitmentCode"  ,oAux:getValue("commitmentCode"))  //BVZ_CDCOMP
            oObjDel:SetValue("batchCode"       ,oAux:getValue("batchCode"))       //BVZ_LOTE
            oObjDel:SetValue("formProcDt"      ,oAux:getValue("formProcDt"))      //BVZ_DTPRGU
           
            oObjDel:delete()
            oObjDel:destroy()
            oAux:destroy()

        endDo

    endIf
    oCltBVZ:destroy()

Return


//------------------------------------------------------------------------------------------
/*/{Protheus.doc} atuProcAPI
    Marca a guia como processada no Alais da API B2V 

    @type  Class
    @author renan.almeida
    @since 20190320
/*/
//------------------------------------------------------------------------------------------
Method atuProcAPI() Class CenPrMoRem

   Local oCltB2V := CenCltB2V():New()
    
    oCltB2V:SetValue("operatorRecord",self:cCodOpe)
    oCltB2V:SetValue("formSequential",self:cSeqGui)

    if oCltB2V:bscChaPrim()
        oCltB2V:mapFromDao()
        oCltB2V:SetValue("processed","1")
        oCltB2V:update()
    endIf
    oCltB2V:destroy()

Return

//------------------------------------------------------------------------------------------
/*/{Protheus.doc} verTraProc
    Verifica se tem uma guia ja processada e realiza a alteracao de dados     

    @type  Class
    @author renan.almeida
    @since 20190320
/*/
//------------------------------------------------------------------------------------------
Method verAlter(oAuxCab) Class CenPrMoRem

    Local oColBVZ := CenCltBVZ():New()
    Local oAux    := nil

    oColBVZ:SetValue("operatorRecord"  ,self:cCodOpe)
    oColBVZ:SetValue("providerCpfCnpj" ,self:cCpfCnpj)
    oColBVZ:SetValue("requirementCode" ,self:cCodObrig)
    oColBVZ:SetValue("referenceYear"   ,self:cAno)
    oColBVZ:SetValue("commitmentCode"  ,self:cMes)
    oColBVZ:SetValue("formProcDt"      ,self:dProcGuia)

    if oColBVZ:bscMovProc() //Busca transacoes ja processadas com o Status: 4=Em processamento ANS;5=Criticado pela ANS;6=Finalizado
       
        //Verifica se a ultima movimentacao desta chave e uma exclusao
        oColExcBVZ := CenCltBVZ():New()
        oColExcBVZ:SetValue("operatorRecord"  ,self:cCodOpe)
        oColExcBVZ:SetValue("providerCpfCnpj" ,self:cCpfCnpj)
        oColExcBVZ:SetValue("requirementCode" ,self:cCodObrig)
        oColExcBVZ:SetValue("formProcDt"      ,self:dProcGuia)

        if oColExcBVZ:bscUltChv() .And. oColExcBVZ:HasNext()
            oAux := oColExcBVZ:GetNext()
            if oAux:getValue("monitoringRecordType") <> "3"
                
                if oAuxCab:getValue("totalDisallowValue") <> oAux:getValue("totalDisallowValue") .Or. ;
                    oAuxCab:getValue("totalValueEntered")  <> oAux:getValue("totalValueEntered") .Or. ;
                    oAuxCab:getValue("totalValuePaid")     <> oAux:getValue("totalValuePaid")
                    //Padrao para exclusao e gerar na proxima competencia
                    self:comAltExc(oAuxCab)
                    self:cTipRegist := "2"
                else
                    self:lOkProces := .F.
                endIf
            endIf
            oAux:destroy()
        endIf
        oColExcBVZ:destroy()
    
    endIf
    oColBVZ:destroy()

Return