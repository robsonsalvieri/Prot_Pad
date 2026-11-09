#INCLUDE "PROTHEUS.CH"

//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} FISA203A
  
Definição da Estrutura de Classes para a Apuração do Ressarcimento ou Complemento do ICMS Retido por 
Substituição Tributária.
Para o Estado de Minas Gerais, o método de apuração é determinado pelo decreto 47.547/2018.

@author Eduardo Vicente da Silva
@since 22/02/2019
@version 1.0
/*/
//--------------------------------------------------------------------------------------------------

//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} Classe FISA203APURACAO

Classe responsável pela apuração de cada movimento da query principal, controlando: 
Atualização de Restituição ou Complementar 
  
@author Eduardo Vicente da Silva
@since 22/02/2019
@version 1.0
/*/
//--------------------------------------------------------------------------------------------------
CLASS FISA203APURACAO FROM LongClassName

Data cFilApur    As Character //---Código da Filial apurada                                   ---//
Data cPerApur    As Character //---Período da Apuração                                        ---//
Data nTotCom     As Numeric   //---Valor total a complementar no período                      ---//
Data nTotRes     As Numeric   //---Valor total a restituir no período                         ---//  
Data oMovimento  As Object    //---Objeto que controla o movimento analisado                  ---//
Data oMovimApur  As Object    //---Objeto que controla os valores apurados para o movimento   ---//

Method New(cPerApur) CONSTRUCTOR
Method SetaMovim(dDataMov,cTipoMov,cNumDoc,cItemDoc,cSerieDoc,cTipoDoc,cCodProd,cCodPart,cLojaPart,nAliqInt,cCFOP,cCST,nQtdade,nVlrTotPrd,nVlrFrete,nVlrSeguro,nVlrDesp,nVlrDesc,nVlrPauta,nVstAnt,nVicEfet,cNumLote,cLoteCtl,aDocOriApu)
Method ApuraMovim()

//---Getters e Setters---//
Method GetPerApur()

ENDCLASS

//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} New()
  
Método construtor da Classe FISA203APURACAO

@author Eduardo Vicente da Silva
@since 22/02/2019
@version 1.0
/*/
//--------------------------------------------------------------------------------------------------
Method New(cPerApur) Class FISA203APURACAO
Self:cFilApur   := ""
Self:cPerApur   := cPerApur
Self:nTotCom    := 0
Self:nTotRes    := 0
Self:oMovimento := FISA203MOVIMENTO():New()
Self:oMovimApur := FISA203MOVIMENTOAPURACAO():New()
Return Self

//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} SetaMovim()
  
Método que carrega no objeto o movimento a ser analisado. 
Deve ser chamado a cada movimento encontrado para o produto em questão.

@author Eduardo Vicente da Silva
@since 22/02/2019
@version 1.0
/*/
//--------------------------------------------------------------------------------------------------
Method SetaMovim(dDataMov,cTipoMov,cNumDoc,cItemDoc,cSerieDoc,cTipoDoc,cCodProd,cCodPart,cLojaPart,nAliqInt,nQtdade,nVlrTotPrd,nVlrFrete,nVlrSeguro,nVlrDesp,nVlrDesc,nVlrPauta,nVstAnt,nVicEfet,cNumLote,cLoteCtl,aDocOriApu) Class FISA203APURACAO
    Self:oMovimento:ClearMov()
    Self:oMovimento:SetDataMov(dDataMov)
    Self:oMovimento:SetTipoMov(cTipoMov)
    Self:oMovimento:SetNumDoc(cNumDoc)
    Self:oMovimento:SetItemDoc(cItemDoc)
    Self:oMovimento:SetSerDoc(cSerieDoc)
    Self:oMovimento:SetTipoDoc(cTipoDoc)
    Self:oMovimento:SetCodProd(cCodProd)
    Self:oMovimento:SetCodPart(cCodPart)
    Self:oMovimento:SetLojaPart(cLojaPart)
    Self:oMovimento:SetAliqInt(nAliqInt)
    Self:oMovimento:SetQuant(nQtdade)
    Self:oMovimento:SetVstAnt(nVstAnt)
    Self:oMovimento:SetVicEfet(nVicEfet)
    Self:oMovimento:SetTotPrd(nVlrTotPrd)
    Self:oMovimento:SetFrete(nVlrFrete)
    Self:oMovimento:SetSeguro(nVlrSeguro)
    Self:oMovimento:SetDespesa(nVlrDesp)
    Self:oMovimento:SetDescont(nVlrDesc)    
    Self:oMovimento:SetVlrPauta(nVlrPauta)
    Self:oMovimento:SetNumLote(cNumLote)
    Self:oMovimento:SetLoteCtl(cLoteCtl)
    Self:oMovimento:SetDocOrig(aDocOriApu)

Return

//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} ApuraMovim()
  
Método responsável por controlar, para cada movimento verificar o Valor a Ressarcir ou Complementar 

@author Eduardo Vicente da Silva
@since 22/02/2019
@version 1.0
/*/
//--------------------------------------------------------------------------------------------------
Method ApuraMovim() Class FISA203APURACAO
Local cTipoMov      := Self:oMovimento:GetTipoMov()
Local cCodProd      := Self:oMovimento:GetCodProd()
Local nQtdade       := Self:oMovimento:GetQuant()
Local cTipoDoc      := Self:oMovimento:GetTipoDoc()
Local nAliqInt      := Self:oMovimento:GetAliqInt()
Local aDocOriApu    := Self:oMovimento:GetDocOrig()
Local nVstAnt       := Self:oMovimento:GetVstAnt() 
Local nVicEfet      := Self:oMovimento:GetVicEfet()
Local cNumLote      := Self:oMovimento:GetNumLote()
Local cLoteCtl      := Self:oMovimento:GetLoteCtl()
Local dDataMov      := Self:oMovimento:GetDataMov()
Local nDifOper      := 0
Local nVlrCompl     := 0
Local nVlrRest      := 0
Local oMovEntrada   := Nil
Local nPos          := 0
Local aDadosEnt     := {}

//Define o valor a Restituir ou Complementar
If cTipoMov=='S'  

    //Caso o novo campo de ICMS Efetivo esteja igual a zero ou não exista será calculada a base do ICMS Efetivo do movimento.
    nVicEfet := Iif(nVicEfet > 0, nVicEfet, (Self:oMovimento:DefBICMS()* nAliqInt) / 100 )

    //Caso o novo campo de ICMS ST Anterior esteja igual a zero ou não exista será calculado com base nas ultimas entradas.
    If nVstAnt == 0
        oMovEntrada   := FISA197MOVIMENTO():New()
        oMovEntrada:cCodProd    := cCodProd
        oMovEntrada:nQtdade     := nQtdade
        oMovEntrada:dDataMov    := dDataMov
        oMovEntrada:cNumLote    := cNumLote
        oMovEntrada:cLoteCli    := cLoteCtl

        cTipoProc:= "M"
        oMovEntrada:cTipoProc := cTipoProc
        oMovEntrada:ICMSUnitEnt()
        aDadosEnt := oMovEntrada:aSldVlrDet

        For nPos:=1 to Len(aDadosEnt)
            nVstAnt += aDadosEnt[nPos,9]
        Next 
        
    EndIf

    nDifOper := nVicEfet - nVstAnt 

    //Valor do complemento
    If nDifOper > 0
        nVlrCompl := nDifOper
    //Valor da Restituição
    Else
        nVlrRest  := Abs(nDifOper)
    EndIf
//Tratamento das devoluções de Saída
ElseIf cTipoMov == 'E' .And. cTipoDoc == 'D'
    If aDocOriApu[2] > 0
        nVlrRest := (aDocOriApu[2] / aDocOriApu[1]) * nQtdade
    Else
        nVlrCompl := (aDocOriApu[3] / aDocOriApu[1]) * nQtdade
    EndIf
EndIf

//---Carrega os valores apurados no atributo oMovimApur---//
Self:nTotRes += nVlrRest
Self:nTotCom += nVlrCompl
Self:oMovimApur:ClearMovAp()
Self:oMovimApur:SetVlrPre(nVstAnt)
Self:oMovimApur:SetVlrCompl(nVlrCompl)
Self:oMovimApur:SetVlrRest(nVlrRest)

Self:oMovimento:SetVlrUni(nVicEfet/nQtdade)
Self:oMovimento:SetVlrTot(nVicEfet)
    
Return

//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} Getters e Setters

@author Eduardo Vicente da Silva
@since 22/02/2019
@version 1.0
/*/
//--------------------------------------------------------------------------------------------------

Method GetPerApur() Class FISA203APURACAO
Return Self:cPerApur

//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} Classe FISA203MOVIMENTO

Classe responsável por controlar todas os campos do movimento
  
@author Eduardo Vicente da Silva
@since 22/02/2019
@version 1.0
/*/
//--------------------------------------------------------------------------------------------------
CLASS FISA203MOVIMENTO FROM LongClassName

Data dDataMov     As Date      //---Data do Movimento
Data cTipoMov     As Character //---Tipo do Movimento (E-Entrada / S-Saída)
Data cNumDoc      As Character //---Número do Documento Fiscal
Data cItemDoc     As Character //---Item do Documento Fiscal
Data cSerieDoc    As Character //---Série do Documento Fiscal
Data cTipoDoc     As Character //---Tipo do documento
Data cCodProd     As Character //---Código do Produto
Data cCodPart     As Character //---Código do Participante
Data cLojaPart    As Character //---Loja do Participante
Data nAliqInt     As Numeric   //---Alíquota Interna do Produto
Data nQuant       As Numeric   //---Quantidade
Data nVlrUni      As Numeric   //---Valor Unitário
Data nVlrTot      As Numeric   //---Valor Total
Data nVlrTotPrd   As Numeric   //---Valor Total do Produto
Data nVlrFrete    As Numeric   //---Valor do Frete
Data nVlrSeguro   As Numeric   //---Valor do Seguro
Data nVlrDesp     As Numeric   //---Valor das Despesas
Data nVlrDesc     As Numeric   //---Valor do Desconto
Data nVstAnt      As Numeric   //---Valor do ICMS ST Recolhido Anteriormente
Data nVicEfet     As Numeric   //---Valor do ICMS Efetivo
Data nVlrPauta    As Numeric   //---Valor da pauta informado no cadastro do produto no campo B1_VLR_ICM
Data cNumLote     As Character //---Numero do SubLote
Data cLoteCtl     As Character //---Número do Lote
Data aDocOriApu   As Array     //---Valores apurados para o Documento Fiscal Original, em casos de movimentos de devolução

Method New() CONSTRUCTOR
Method ClearMov()
Method DefBICMS()

//---Getters e Setters---//
Method SetDataMov(dDataMov)
Method SetTipoMov(cTipoMov)
Method SetNumDoc(cNumDoc)
Method SetItemDoc(cItemDoc)
Method SetSerDoc(cSerieDoc)
Method SetTipoDoc(cTipoDoc)
Method SetCodProd(cCodProd)
Method SetCodPart(cCodPart)
Method SetLojaPart(cLojaPart)
Method SetAliqInt(nAliqInt)
Method SetQuant(nQuant)
Method SetVlrUni(nVlrUni)
Method SetVlrTot(nVlrTot)
Method SetTotPrd(nVlrTotPrd)
Method SetFrete(nVlrFrete)
Method SetSeguro(nVlrSeguro)
Method SetDespesa(nVlrDesp)
Method SetDescont(nVlrDesc)
Method SetVicEfet(nVicEfet)
Method SetVstAnt(nVstAnt)
Method SetVlrPauta(nVlrPauta)
Method SetNumLote(cNumLote)
Method SetLoteCtl(cLoteCtl)
Method SetDocOrig(aDocOriApu)
Method GetDataMov()
Method GetTipoMov()
Method GetNumDoc()
Method GetItemDoc()
Method GetSerDoc()
Method GetTipoDoc()
Method GetCodProd()
Method GetCodPart()
Method GetLojaPart()
Method GetAliqInt()
Method GetQuant()
Method GetVlrUni()
Method GetVlrTot()
Method GetTotPrd()
Method GetFrete()
Method GetSeguro()
Method GetDespesa()
Method GetDescont()
Method GetBICMS()
Method GetVlrPauta()
Method GetVstAnt()
Method GetVicEfet() 
Method GetNumLote()
Method GetLoteCtl()
Method GetDocOrig()

ENDCLASS


//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} New()
  
Método construtor da Classe FISA203MOVIMENTO

@author Eduardo Vicente da Silva
@since 22/02/2019
@version 1.0
/*/
//--------------------------------------------------------------------------------------------------
Method New() Class FISA203MOVIMENTO
    Self:ClearMov()
Return Self

//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} ClearMov
  
Método que limpa os valores do movimento.

@author Eduardo Vicente da Silva
@since 22/02/2019
@version 1.0
/*/
//--------------------------------------------------------------------------------------------------
Method ClearMov() Class FISA203MOVIMENTO
    Self:dDataMov   := CToD("  /  /    ")
    Self:cTipoMov   := ""
    Self:cNumDoc    := ""
    Self:cItemDoc   := ""
    Self:cSerieDoc  := ""
    Self:cCodProd   := ""
    Self:cCodPart   := ""
    Self:cLojaPart  := ""
    Self:nAliqInt   := 0
    Self:nQuant     := 0
    Self:nVlrUni    := 0
    Self:nVlrTot    := 0
    Self:nVlrTotPrd := 0
    Self:nVlrFrete  := 0
    Self:nVlrSeguro := 0
    Self:nVlrDesp   := 0
    Self:nVlrDesc   := 0
    Self:nVlrPauta  := 0
    Self:nVicEfet   := 0
    Self:nVstAnt    := 0
    Self:cNumLote   := ""
    Self:cLoteCtl   := ""
Return

//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} Getters e Setters

@author Eduardo Vicente da Silva
@since 22/02/2019
@version 1.0
/*/
//--------------------------------------------------------------------------------------------------
Method SetDataMov(dDataMov) Class FISA203MOVIMENTO
    Self:dDataMov := dDataMov
Return

Method SetTipoMov(cTipoMov) Class FISA203MOVIMENTO
    Self:cTipoMov := cTipoMov
Return

Method SetNumDoc(cNumDoc) Class FISA203MOVIMENTO
    Self:cNumDoc := cNumDoc
Return

Method SetItemDoc(cItemDoc) Class FISA203MOVIMENTO
    Self:cItemDoc := cItemDoc
Return

Method SetSerDoc(cSerieDoc) Class FISA203MOVIMENTO
    Self:cSerieDoc := cSerieDoc
Return

Method SetTipoDoc(cTipoDoc) Class FISA203MOVIMENTO
    Self:cTipoDoc := cTipoDoc
Return

Method SetCodProd(cCodProd) Class FISA203MOVIMENTO
    Self:cCodProd := cCodProd
Return

Method SetCodPart(cCodPart) Class FISA203MOVIMENTO
    Self:cCodPart := cCodPart
Return

Method SetLojaPart(cLojaPart) Class FISA203MOVIMENTO
    Self:cLojaPart := cLojaPart
Return

Method SetAliqInt(nAliqInt) Class FISA203MOVIMENTO
    Self:nAliqInt := nAliqInt
Return

Method SetQuant(nQuant) Class FISA203MOVIMENTO
    Self:nQuant := nQuant
Return

Method SetVlrUni(nVlrUni) Class FISA203MOVIMENTO
    Self:nVlrUni := nVlrUni
Return

Method SetVlrTot(nVlrTot) Class FISA203MOVIMENTO
    Self:nVlrTot := nVlrTot
Return

Method SetTotPrd(nVlrTotPrd) Class FISA203MOVIMENTO
    Self:nVlrTotPrd := nVlrTotPrd
Return

Method SetFrete(nVlrFrete) Class FISA203MOVIMENTO
    Self:nVlrFrete := nVlrFrete
Return

Method SetSeguro(nVlrSeguro) Class FISA203MOVIMENTO
    Self:nVlrSeguro := nVlrSeguro
Return

Method SetDespesa(nVlrDesp) Class FISA203MOVIMENTO
    Self:nVlrDesp := nVlrDesp
Return

Method SetDescont(nVlrDesc) Class FISA203MOVIMENTO
    Self:nVlrDesc := nVlrDesc
Return

Method SetVlrPauta(nVlrPauta) Class FISA203MOVIMENTO
    Self:nVlrPauta := nVlrPauta
Return

Method SetVicEfet(nVicEfet) Class FISA203MOVIMENTO
    Self:nVicEfet := nVicEfet
Return

Method SetVstAnt(nVstAnt) Class FISA203MOVIMENTO
    Self:nVstAnt := nVstAnt
Return

Method SetNumLote(cNumLote) Class FISA203MOVIMENTO
    Self:cNumLote := cNumLote
Return

Method SetLoteCtl(cLoteCtl) Class FISA203MOVIMENTO
    Self:cLoteCtl := cLoteCtl
Return

Method SetDocOrig(aDocOriApu) Class FISA203MOVIMENTO
    Self:aDocOriApu := aDocOriApu
Return

Method GetDataMov() Class FISA203MOVIMENTO
Return Self:dDataMov

Method GetTipoMov() Class FISA203MOVIMENTO
Return Self:cTipoMov

Method GetNumDoc()  Class FISA203MOVIMENTO
Return Self:cNumDoc

Method GetItemDoc()  Class FISA203MOVIMENTO
Return Self:cItemDoc

Method GetSerDoc()  Class FISA203MOVIMENTO
Return Self:cSerieDoc

Method GetTipoDoc()  Class FISA203MOVIMENTO
Return Self:cTipoDoc

Method GetCodProd() Class FISA203MOVIMENTO
Return Self:cCodProd

Method GetCodPart() Class FISA203MOVIMENTO
Return Self:cCodPart

Method GetLojaPart() Class FISA203MOVIMENTO
Return Self:cLojaPart

Method GetAliqInt()  Class FISA203MOVIMENTO
Return Self:nAliqInt

Method GetQuant() Class FISA203MOVIMENTO
Return Self:nQuant

Method GetTotPrd() Class FISA203MOVIMENTO
Return Self:nVlrTotPrd

Method GetFrete() Class FISA203MOVIMENTO
Return Self:nVlrFrete

Method GetSeguro() Class FISA203MOVIMENTO
Return Self:nVlrSeguro

Method GetDespesa() Class FISA203MOVIMENTO
Return Self:nVlrDesp

Method GetDescont() Class FISA203MOVIMENTO
Return Self:nVlrDesc

Method GetVlrUni() Class FISA203MOVIMENTO
Return Self:nVlrUni

Method GetVlrTot() Class FISA203MOVIMENTO
Return Self:nVlrTot

Method GetVicEfet() Class FISA203MOVIMENTO
Return Self:nVicEfet

Method GetVstAnt() Class FISA203MOVIMENTO
Return Self:nVstAnt

Method GetNumLote() Class FISA203MOVIMENTO   
Return Self:cNumLote

Method GetLoteCtl() Class FISA203MOVIMENTO    
Return Self:cLoteCtl

Method GetVlrPauta() Class FISA203MOVIMENTO
Return Self:nVlrPauta

Method GetDocOrig() Class FISA203MOVIMENTO
Return Self:aDocOriApu

//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} DefBICMS()
  
Método que define a correspondente Base de ICMS da operação.

@author Eduardo Vicente da Silva
@since 22/02/2019
@version 1.0
/*/
//--------------------------------------------------------------------------------------------------
Method DefBICMS() Class FISA203MOVIMENTO
    Local nRetorno   := 0
    Local nVlrTotPrd := Self:GetTotPrd()
    Local nVlrFrete  := Self:GetFrete()
    Local nVlrSeguro := Self:GetSeguro()
    Local nVlrDesp   := Self:GetDespesa()
    Local nVlrDesc   := Self:GetDescont()
    Local nQtdade    := Self:GetQuant()
    Local nVlrPauta  := Self:GetVlrPauta()

    If nVlrPauta > 0
        nRetorno := (nQtdade * nVlrPauta) + nVlrFrete + nVlrSeguro + nVlrDesp - nVlrDesc
    Else
        nRetorno := nVlrTotPrd + nVlrFrete + nVlrSeguro + nVlrDesp - nVlrDesc
    EndIf

Return nRetorno

//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} Classe FISA203MOVIMENTOAPURACAO

Classe reponsável por controlar os valores já apurados para o movimento.
  
@author Eduardo Vicente da Silva
@since 22/02/2019
@version 1.0
/*/
//--------------------------------------------------------------------------------------------------
CLASS FISA203MOVIMENTOAPURACAO FROM LongClassName

Data nVlrCompl As Numeric    
Data nVlrRest  As Numeric    
Data nVlrPre   As Numeric

Method New() CONSTRUCTOR
Method ClearMovAp()

//---Getters e Setters---//
Method SetVlrCompl(nVlrCompl)
Method SetVlrRest(nVlrRest)
Method SetVlrPre(nVlrPre)

Method GetVlrCompl()
Method GetVlrRest()
Method GetVlrPre()

ENDCLASS


//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} New()
  
Método construtor da Classe FISA203MOVIMENTOAPURACAO

@author Eduardo Vicente da Silva
@since 22/02/2019
@version 1.0
/*/
//--------------------------------------------------------------------------------------------------
Method New() Class FISA203MOVIMENTOAPURACAO
    Self:ClearMovAp()
Return Self


//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} Method ClearMovAp()
  
Método que limpa os valores apurados do movimento.

@author Eduardo Vicente da Silva
@since 22/02/2019
@version 1.0
/*/
//--------------------------------------------------------------------------------------------------
Method ClearMovAp() Class FISA203MOVIMENTOAPURACAO
    Self:nVlrCompl  := 0
    Self:nVlrRest   := 0
    Self:nVlrPre    := 0

Return

//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} Getters e Setters

@author Eduardo Vicente da Silva
@since 22/02/2019
@version 1.0
/*/
//--------------------------------------------------------------------------------------------------
Method SetVlrCompl(nVlrCompl) Class FISA203MOVIMENTOAPURACAO
    Self:nVlrCompl := nVlrCompl
Return

Method SetVlrRest(nVlrRest) Class FISA203MOVIMENTOAPURACAO
    Self:nVlrRest := nVlrRest
Return

Method SetVlrPre(nVlrPre) Class FISA203MOVIMENTOAPURACAO
    Self:nVlrPre := nVlrPre
Return

Method GetVlrCompl() Class FISA203MOVIMENTOAPURACAO
Return Self:nVlrCompl

Method GetVlrRest() Class FISA203MOVIMENTOAPURACAO
Return Self:nVlrRest

Method GetVlrPre() Class FISA203MOVIMENTOAPURACAO
Return Self:nVlrPre