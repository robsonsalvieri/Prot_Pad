#include "TOTVS.CH"
#define idTraInc  "1"
#define idTraAlt  "2"
#define idTraExc  "3"
#define idExcGuia "1"

//------------------------------------------------------------------------------------------
/*/{Protheus.doc}CenPrMoPre
    Classe abstrata para execução de comandos
    @type  Class
    @author renan.almeida
    @since 20190320
/*/
//------------------------------------------------------------------------------------------
Class CenPrMoPre From CenProcMon

    Data cCpfCnpj  as String
    Data cCnes     as String
    Data cCodMun   as String 
    Data cAnsOpInt as String
    Data cIdentPre as String
    Data cCompCobr as String

    Method New() Constructor
    Method proRemuAPI()
    Method loadChave(oAuxCab)
    Method atuProcAPI()
    Method verTraPend(oAuxCab)
    //Metodos de inclusao
    Method procInclus(oAuxCab)
    //Metodos de commit de dados
    Method grvMovB9T(oAuxCab)
    //Metodos de exclusao
    Method excTransac()
    Method delMovB9T(oAuxB9T)
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
Method New() Class CenPrMoPre

    _Super:new()
    self:cCpfCnpj  := ""
    self:cCnes     := ""
    self:cCodMun   := ""
    self:cAnsOpInt := ""
    self:cIdentPre := ""
    self:cCompCobr := ""

return self


//------------------------------------------------------------------------------------------
/*/{Protheus.doc} proRemuAPI
    Processa uma guia enviada para a API
    @type  Class
    @author renan.almeida
    @since 20190320
/*/
//------------------------------------------------------------------------------------------
Method proRemuAPI() Class CenPrMoPre

    Local oColB2X := CenCltB2X():New()
    Local oAuxCab  := nil
    
    oColB2X:SetValue("operatorRecord",self:cCodOpe)
    oColB2X:SetValue("formSequential",self:cSeqGui)

    if oColB2X:bscChaPrim()

        oAuxCab := oColB2X:GetNext() //Carrega cabecalho API
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
        self:atuProcAPI() //Atualiza registro na B9T como processado
        
        oAuxCab:destroy()
    endIf
    oColB2X:destroy() 

Return


//------------------------------------------------------------------------------------------
/*/{Protheus.doc} loadChave
    Carrega para o objeto principal, dados que vou utilizar nas chaves primarias

    @type  Class
    @author renan.almeida
    @since 20190320
/*/
//------------------------------------------------------------------------------------------
Method loadChave(oAuxCab) Class CenPrMoPre
    
    Local cAno      := Substr(oAuxCab:getValue("periodCover"),1,4)
    Local cMes      := Strzero(Val(Substr(oAuxCab:getValue("periodCover"),5,2)),3)
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
    self:cCnes     := oAuxCab:getValue("cnes")
    self:cCpfCnpj  := oAuxCab:getValue("providerCpfCnpj")
    self:cCodMun   := oAuxCab:getValue("cityOfProvider")
    self:cAnsOpInt := oAuxCab:getValue("ansRecordNumber")
    self:cIdentPre := oAuxCab:getValue("presetValueIdent")
    self:cCompCobr := oAuxCab:getValue("periodCover")

Return


//------------------------------------------------------------------------------------------
/*/{Protheus.doc} procInclus
    Marca a guia como processada no Alais da API B9T 

    @type  Class
    @author renan.almeida
    @since 20190320
/*/
//------------------------------------------------------------------------------------------
Method procInclus(oAuxCab) Class CenPrMoPre

    self:grvMovB9T(oAuxCab) //Gera movimentacao

Return


//------------------------------------------------------------------------------------------
/*/{Protheus.doc} verTraPend
    Alteração de um registro não enviado para a ANS, devemos excluir a mais antiga
   
    @type  Class
    @author renan.almeida
    @since 20190320
/*/
//------------------------------------------------------------------------------------------
Method verTraPend(oAuxCab) Class CenPrMoPre

    Local oColB9T := CenCltB9T():New()
    Local oObjB9T := nil

    oColB9T:SetValue("operatorRecord"  ,self:cCodOpe)    //B9T_CODOPE
    oColB9T:SetValue("cnes"            ,self:cCnes)      //B9T_CNES
    oColB9T:SetValue("providerCpfCnpj" ,self:cCpfCnpj)   //B9T_CPFCNP
    oColB9T:SetValue("cityOfProvider"  ,self:cCodMun)    //B9T_CDMNPR
    oColB9T:SetValue("ansRecordNumber" ,self:cAnsOpInt)  //B9T_RGOPIN
    oColB9T:SetValue("presetValueIdent",self:cIdentPre)  //B9T_IDVLRP
    oColB9T:SetValue("requirementCode" ,self:cCodObrig)  //B9T_CDOBRI
    oColB9T:SetValue("referenceYear"   ,self:cAno)       //B9T_ANO
    oColB9T:SetValue("commitmentCode"  ,self:cMes)       //B9T_CDCOMP
    oColB9T:SetValue("periodCover"     ,self:cCompCobr)  //B9T_COMCOB
    
    if oColB9T:bscMovPend() //Busca transacoes pendentes com o Status: 1=Pendente Envio;2=Criticado;3=Pronto para o Envio
        
        while oColB9T:HasNext() //Coloquei um While, mas teoricamente so tera um registro

            oObjB9T := oColB9T:GetNext()
            //Se a data de inclusao do registro ja processado é inferior a que estou processando no momento,
            //excluo o registro existente para criar um novo registro atualizado 
            if (oObjB9T:getValue("inclusionDate") <  oAuxCab:getValue("inclusionDate")) .Or. ;
               (oObjB9T:getValue("inclusionDate") == oAuxCab:getValue("inclusionDate") .And. ;
                oObjB9T:getValue("inclusionTime") <  oAuxCab:getValue("inclusionTime"))
                self:delMovB3F(oObjB9T,"B9T",B9T->(Recno()))
                self:delMovB9T(oObjB9T)
              
            //Se a transacao que estou processando for mais velha que o registro ja criado, ignoro a transacao            
            else
                self:lOkProces := .F.
            endIf
            oObjB9T:destroy()
        endDo

    endIf
    oColB9T:destroy()
   
Return


//------------------------------------------------------------------------------------------
/*/{Protheus.doc} excTransac
    Processa a exclusao de uma transacao

    @type  Class
    @author renan.almeida
    @since 20190320
/*/
//------------------------------------------------------------------------------------------
Method excTransac() Class CenPrMoPre

    Local oColB9T := CenCltB9T():New()
    Local oObjB9T := nil

    oColB9T:SetValue("operatorRecord"  ,self:cCodOpe)    //B9T_CODOPE
    oColB9T:SetValue("cnes"            ,self:cCnes)      //B9T_CNES
    oColB9T:SetValue("providerCpfCnpj" ,self:cCpfCnpj)   //B9T_CPFCNP
    oColB9T:SetValue("cityOfProvider"  ,self:cCodMun)    //B9T_CDMNPR
    oColB9T:SetValue("ansRecordNumber" ,self:cAnsOpInt)  //B9T_RGOPIN
    oColB9T:SetValue("presetValueIdent",self:cIdentPre)  //B9T_IDVLRP
    oColB9T:SetValue("requirementCode" ,self:cCodObrig)  //B9T_CDOBRI
    oColB9T:SetValue("batchCode"       ,self:cLote)      //B9T_LOTE
    oColB9T:SetValue("periodCover"     ,self:cCompCobr)  //B9T_COMCOB

    if oColB9T:bscMovExcl()
        
        oObjB9T := oColB9T:GetNext()

        //So processarei se a ultima transacao nao for uma Exclusao
        if oObjB9T:getValue("monitoringRecordType") <> idTraExc
            
            //Verifico o status, se nao foi enviada para a ANS, excluo a transacao
            if oObjB9T:getValue("status") $ "1/2/3/7" //1=Pendente Envio;2=Criticado;3=Pronto para o Envio;4=Em processamento ANS;5=Criticado pela ANS;6=Finalizado
                self:delMovB9T(oObjB9T)
            //Ja foi enviado para ANS, devo gerar uma transacao de exclusao
            elseIf oObjB9T:getValue("status") $ "4/6/8"
                self:lOkProces := .F. //Vou gravar a guia por aqui
                self:comAltExc(oObjB9T) //Padrao para exclusao e gerar na proxima competencia
                self:cTipRegist := idTraExc
                self:grvMovB9T(oObjB9T) //Grava movimentacao - cabecalho
            endif

        endIf    
        oObjB9T:destroy()

    endIf
    oColB9T:destroy()

Return


//------------------------------------------------------------------------------------------
/*/{Protheus.doc} grvMovB9T
    Grava a movimentacao da B9T

    @type  Class
    @author renan.almeida
    @since 20190320
/*/
//------------------------------------------------------------------------------------------
Method grvMovB9T(oAuxCab) Class CenPrMoPre
   
    Local oColB9T   := CenCltB9T():New()
    Local cProcTime := Substr(Time(),1,2)+Substr(Time(),4,2)+Substr(Time(),7,2)

    //Chave primaria - B9T_FILIAL, B9T_CODOPE, B9T_CNES, B9T_CPFCNP, B9T_CDMNPR, B9T_RGOPIN, B9T_IDVLRP, B9T_CDOBRI, B9T_ANO, B9T_CDCOMP, B9T_LOTE
    oColB9T:SetValue("operatorRecord"  ,self:cCodOpe)    //B9T_CODOPE
    oColB9T:SetValue("cnes"            ,self:cCnes)      //B9T_CNES
    oColB9T:SetValue("providerCpfCnpj" ,self:cCpfCnpj)   //B9T_CPFCNP
    oColB9T:SetValue("cityOfProvider"  ,self:cCodMun)    //B9T_CDMNPR
    oColB9T:SetValue("ansRecordNumber" ,self:cAnsOpInt)  //B9T_RGOPIN
    oColB9T:SetValue("presetValueIdent",self:cIdentPre)  //B9T_IDVLRP
    oColB9T:SetValue("requirementCode" ,self:cCodObrig)  //B9T_CDOBRI
    oColB9T:SetValue("referenceYear"   ,self:cAno)       //B9T_ANO
    oColB9T:SetValue("commitmentCode"  ,self:cMes)       //B9T_CDCOMP
    oColB9T:SetValue("batchCode"       ,self:cLote)      //B9T_LOTE
    oColB9T:SetValue("periodCover"     ,self:cCompCobr)  //B9T_COMCOB

    oColB9T:SetValue("status"              ,self:cStatus)
    oColB9T:SetValue("monitoringRecordType",self:cTipRegist)
    oColB9T:SetValue("processingDate"      ,Dtos(dDataBase))
    oColB9T:SetValue("processingTime"      ,cProcTime)
    oColB9T:SetValue("presetValue"         ,oAuxCab:getValue("presetValue"))
    oColB9T:SetValue("providerIdentifier"  ,oAuxCab:getValue("providerIdentifier"))
    oColB9T:SetValue("inclusionDate"       ,oAuxCab:getValue("inclusionDate"))
    oColB9T:SetValue("inclusionTime"       ,oAuxCab:getValue("inclusionTime"))

    //Commit dos itens
    oColB9T:insert()
    oColB9T:destroy()

Return


//------------------------------------------------------------------------------------------
/*/{Protheus.doc} delMovB9T
    Deleta os eventos B9T de uma movimentacao pendente

    @type  Class
    @author renan.almeida
    @since 20190320
/*/
//------------------------------------------------------------------------------------------
Method delMovB9T(oAuxB9T) Class CenPrMoPre

    Local oCltB9T := CenCltB9T():New()
    Local oObjDel := nil
    Local oAux    := nil

    oCltB9T:SetValue("operatorRecord"   ,oAuxB9T:getValue("operatorRecord"))   //B9T_CODOPE
    oCltB9T:SetValue("cnes"             ,oAuxB9T:getValue("cnes"))             //B9T_CNES
    oCltB9T:SetValue("providerCpfCnpj"  ,oAuxB9T:getValue("providerCpfCnpj"))  //B9T_CPFCNP
    oCltB9T:SetValue("cityOfProvider"   ,oAuxB9T:getValue("cityOfProvider"))   //B9T_CDMNPR
    oCltB9T:SetValue("ansRecordNumber"  ,oAuxB9T:getValue("ansRecordNumber"))  //B9T_RGOPIN
    oCltB9T:SetValue("presetValueIdent" ,oAuxB9T:getValue("presetValueIdent")) //B9T_IDVLRP
    oCltB9T:SetValue("requirementCode"  ,oAuxB9T:getValue("requirementCode"))  //B9T_CDOBRI
    oCltB9T:SetValue("referenceYear"    ,oAuxB9T:getValue("referenceYear"))    //B9T_ANO
    oCltB9T:SetValue("commitmentCode"   ,oAuxB9T:getValue("commitmentCode"))   //B9T_CDCOMP
    oCltB9T:SetValue("batchCode"        ,oAuxB9T:getValue("batchCode"))        //B9T_LOTE
    oCltB9T:SetValue("periodCover"      ,oAuxB9T:getValue("periodCover"))      //B9T_COMCOB

    if oCltB9T:buscar()
    
        while oCltB9T:HasNext() 

            oAux := oCltB9T:GetNext()
            //Chave primaria - B9T_FILIAL, B9T_CODOPE, B9T_CPFCNP, B9T_CDOBRI, B9T_ANO, B9T_CDCOMP, B9T_LOTE, B9T_DTPROC
            oObjDel := CenCltB9T():New()
            oObjDel:SetValue("operatorRecord"   ,oAux:getValue("operatorRecord"))   //B9T_CODOPE
            oObjDel:SetValue("cnes"             ,oAux:getValue("cnes"))             //B9T_CNES
            oObjDel:SetValue("providerCpfCnpj"  ,oAux:getValue("providerCpfCnpj"))  //B9T_CPFCNP
            oObjDel:SetValue("cityOfProvider"   ,oAux:getValue("cityOfProvider"))   //B9T_CDMNPR
            oObjDel:SetValue("ansRecordNumber"  ,oAux:getValue("ansRecordNumber"))  //B9T_RGOPIN
            oObjDel:SetValue("presetValueIdent" ,oAux:getValue("presetValueIdent")) //B9T_IDVLRP
            oObjDel:SetValue("requirementCode"  ,oAux:getValue("requirementCode"))  //B9T_CDOBRI
            oObjDel:SetValue("referenceYear"    ,oAux:getValue("referenceYear"))    //B9T_ANO
            oObjDel:SetValue("commitmentCode"   ,oAux:getValue("commitmentCode"))   //B9T_CDCOMP
            oObjDel:SetValue("batchCode"        ,oAux:getValue("batchCode"))        //B9T_LOTE
            oObjDel:SetValue("periodCover"      ,oAux:getValue("periodCover"))      //B9T_COMCOB
           
            oObjDel:delete()
            oObjDel:destroy()
            oAux:destroy()

        endDo

    endIf
    oCltB9T:destroy()

Return


//------------------------------------------------------------------------------------------
/*/{Protheus.doc} atuProcAPI
    Marca a guia como processada no Alais da API B2X 

    @type  Class
    @author renan.almeida
    @since 20190320
/*/
//------------------------------------------------------------------------------------------
Method atuProcAPI() Class CenPrMoPre

   Local oCltB2X := CenCltB2X():New()
    
    oCltB2X:SetValue("operatorRecord",self:cCodOpe)
    oCltB2X:SetValue("formSequential",self:cSeqGui)

    if oCltB2X:bscChaPrim()
        oCltB2X:mapFromDao()
        oCltB2X:SetValue("processed","1")
        oCltB2X:update()
    endIf
    oCltB2X:destroy()

Return


//------------------------------------------------------------------------------------------
/*/{Protheus.doc} verTraProc
    Verifica se tem uma guia ja processada e realiza a alteracao de dados     

    @type  Class
    @author renan.almeida
    @since 20190320
/*/
//------------------------------------------------------------------------------------------
Method verAlter(oAuxCab) Class CenPrMoPre

    Local oColB9T := CenCltB9T():New()
    Local oAux    := nil

    oColB9T:SetValue("operatorRecord"  ,self:cCodOpe)    //B9T_CODOPE
    oColB9T:SetValue("cnes"            ,self:cCnes)      //B9T_CNES
    oColB9T:SetValue("providerCpfCnpj" ,self:cCpfCnpj)   //B9T_CPFCNP
    oColB9T:SetValue("cityOfProvider"  ,self:cCodMun)    //B9T_CDMNPR
    oColB9T:SetValue("ansRecordNumber" ,self:cAnsOpInt)  //B9T_RGOPIN
    oColB9T:SetValue("presetValueIdent",self:cIdentPre)  //B9T_IDVLRP
    oColB9T:SetValue("requirementCode" ,self:cCodObrig)  //B9T_CDOBRI
    oColB9T:SetValue("referenceYear"   ,self:cAno)       //B9T_ANO
    oColB9T:SetValue("commitmentCode"  ,self:cMes)       //B9T_CDCOMP
    oColB9T:SetValue("batchCode"       ,self:cLote)      //B9T_LOTE
    oColB9T:SetValue("periodCover"     ,self:cCompCobr)  //B9T_COMCOB


    if oColB9T:bscMovProc() //Busca transacoes ja processadas com o Status: 4=Em processamento ANS;5=Criticado pela ANS;6=Finalizado
       
        //Verifica se a ultima movimentacao desta chave e uma exclusao
        oColExcB9T := CenCltB9T():New()
        oColExcB9T:SetValue("operatorRecord"  ,self:cCodOpe)    //B9T_CODOPE
        oColExcB9T:SetValue("cnes"            ,self:cCnes)      //B9T_CNES
        oColExcB9T:SetValue("providerCpfCnpj" ,self:cCpfCnpj)   //B9T_CPFCNP
        oColExcB9T:SetValue("cityOfProvider"  ,self:cCodMun)    //B9T_CDMNPR
        oColExcB9T:SetValue("ansRecordNumber" ,self:cAnsOpInt)  //B9T_RGOPIN
        oColExcB9T:SetValue("presetValueIdent",self:cIdentPre)  //B9T_IDVLRP
        oColExcB9T:SetValue("requirementCode" ,self:cCodObrig)  //B9T_CDOBRI
        oColExcB9T:SetValue("batchCode"       ,self:cLote)      //B9T_LOTE
        oColExcB9T:SetValue("periodCover"     ,self:cCompCobr)  //B9T_COMCOB

        if oColExcB9T:bscUltChv() .And. oColExcB9T:HasNext()
            oAux := oColExcB9T:GetNext()
            if oAux:getValue("monitoringRecordType") <> "3"
                
                if oAuxCab:getValue("presetValue") <> oAux:getValue("presetValue")
                    //Padrao para exclusao e gerar na proxima competencia
                    self:comAltExc(oAuxCab)
                    self:cTipRegist := "2"
                else
                    self:lOkProces := .F.
                endIf
            endIf
            oAux:destroy()
        endIf
        oColExcB9T:destroy()
    
    endIf
    oColB9T:destroy()

Return