#INCLUDE "PROTHEUS.CH"

//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} FISA302A
  
Definição da Estrutura de Classes para a Apuração do Ressarcimento / Complemento do ICMS ST via SPED Fiscal.
O leiaute dos registros ressarcimento foi instituído Guia Prático da EFD-ICMS/IPI, a partir da versão 3.0.2, 
leiaute 014.

@author Rafael.Soliveira / Ulisses.Oliveira / Anedino.Santos
@since 08/11/2019
@version 1.0
/*/
//--------------------------------------------------------------------------------------------------


//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} Classe FISA302APURACAO

Classe responsável pela apuração de cada movimento da query principal.
  
@author Rafael.Soliveira / Ulisses.Oliveira / Anedino.Santos
@since 08/11/2019
@version 1.0
/*/
//--------------------------------------------------------------------------------------------------
CLASS FISA302APURACAO FROM LongClassName

Data cIdApur     As Character //---Identificador da Apuração                                  ---//
Data cFilApur    As Character //---Código da Filial apurada                                   ---//
Data cAnoMes     As Character //---Período da Apuração                                        ---//
Data aTotApur    As Array     //---Totais da Apuração                                         ---//
Data aRegSemCod  As Array     //---Regras de Apuração sem código da tabela 5.7 correspondente ---//
Data cUF         As Character //---UF apurada                                                 ---//
Data lUF11C185                //---Indicador de Geração dos Campos: C185 11 / C181 17         ---//
Data oSaldoProd  As Object    //---Objeto que controla o saldo físico e finaneceiro do produto---//
Data oMovimento  As Object    //---Objeto que controla o movimento analisado                  ---//
Data oMovimApur  As Object    //---Objeto que controla os valores apurados para o movimento   ---//


Method New(cIdApur,cAnoMes,aRegSemCod,cUF) CONSTRUCTOR
Method SetaSldIni(cCodProd,nQtdade,nVUnitOP,nVlSldTtal,nVUnitBSST,nVlSldTtBS,nVUnitST,nVlSdTotST,nVUnitFCP,nVlSldTtFC)
Method SetaMovim(dDataMov,cTipoMov,cTipoDoc,cCodProd,cTipoPart,nAliqInt,cCFOP,cCST,cFGerNReal,cCFOPRess,nQtdade,nVlrUnit,nVlrTotPrd,nVlrFrete,nVlrSeguro,nVlrDesp,nVlrDesc,nVlrTotNf,nVlrBICMS,nVlrICMS,nVlrBICMST,nVlrICMSST,nVlrBCFec,nAliqFec,nVlrFec,nVlrICMEfe,cRespRet,dDtMovOri,nVlrEfeOri,aDocOriApu,cInscricao,cContrib)
Method ApuraMovim()
Method ValRegCod(cRegra)
Method VlUF11C185()
Method ClearApur()

//---Getters e Setters---//
Method GetIdApur()
Method GetAnoMes()
Method GetRSemCod()
Method GetUF()
Method Get11C185()
Method Set11C185(lUF11C185)

ENDCLASS


//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} New()
  
Método construtor da Classe FISA302APURACAO

@author Rafael.Soliveira
@since 08/11/2019
@version 1.0
/*/
//--------------------------------------------------------------------------------------------------
Method New(cIdApur,cAnoMes,aRegSemCod,cUF) Class FISA302APURACAO
    Self:ClearApur()
	Self:cIdApur    := cIdApur
	Self:cFilApur   := ""
	Self:cAnoMes    := cAnoMes    
    Self:aTotApur   := {{'00',0,0,0,0,0,.F.},;  //---UF000 - Operação não ensejadora de Ressarcimento, Restituição ou Complemento de ICMS-ST
                        {'01',0,0,0,0,0,.F.},;  //---UF100 - Ressarcimento/Restituição - Saída a Consumidor Final com valor de saída inferior ao valor da BC ICMS ST
                        {'02',0,0,0,0,0,.F.},;  //---UF200 - Ressarcimento/Restituição - Relativo ao fato gerador presumido não realizado (perda, roubo, furto ou deterioração)
                        {'03',0,0,0,0,0,.F.},;  //---UF200 - Ressarcimento/Restituição - Saída que promover ou saída subseqüente amparada por isenção ou não-incidência
                        {'04',0,0,0,0,0,.F.},;  //---UF200 - Ressarcimento/Restituição - Saída destinada a outro Estado.
                        {'06',0,0,0,0,0,.F.},;  //---UF300 - Complemento -Saída a Consumidor Final com valor de saída superior ao valor da BC ICMS ST
                        {'08',0,0,0,0,0,.F.},;  //---UF500 - Devolução de saída - Entrada sem estorno de ressarcimento ou complemento
                        {'09',0,0,0,0,0,.F.},;  //---UF600 - Devolução de saída - Entrada com estorno de ressarcimento calculado com base no valor saída inferior a BC ICMS ST
                        {'10',0,0,0,0,0,.F.},;  //---UF800 - Devolução de saída - Entrada com estorno de complemento calculado com base no valor saída superior a BC ICMS ST
                        {'11',0,0,0,0,0,.F.},;  //---UF700 - Devolução de saída - Entrada com estorno de ressarcimento relativo ao fato gerador presumido não realizado (perda, roubo, furto ou deterioração)
                        {'12',0,0,0,0,0,.F.},;  //---UF700 - Devolução de saída - Entrada com estorno de ressarcimento - Saída amparada por isenção ou não-incidência
                        {'13',0,0,0,0,0,.F.}}   //---UF700 - Devolução de saída - Entrada com estorno de ressarcimento - Saída destinada a outro Estado
                      //{'07',0,0,0,0,0,.F.},;  //---UF400 - Devolução de entrada - Saída sem ressarcimento ou complemento |***REGRA RETIRADA DO VETOR POIS PVA NÃO ACEITOU REGISTRO 1255 COM CÓDIGO DE ENQUADRAMENTO UF400, MESMO EXISTINDO C186 COM TAL CÓDIGO***|
    Self:aRegSemCod := aRegSemCod
    Self:cUF        := cUF
    Self:oSaldoProd := FISA302SALDOPRODUTO():New()
    Self:oMovimento := FISA302MOVIMENTO():New(cUF)
    Self:oMovimApur := FISA302MOVIMENTOAPURACAO():New()
    Self:VlUF11C185()
Return Self


//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} SetaSldIni()
  
Método que carrega no objeto o saldo inicial do período para o produto analisado. 
Deve ser chamado a cada produto analisado, antes de sua movimentação.

@author Rafael.Soliveira
@since 08/11/2019
@version 1.0
/*/
//--------------------------------------------------------------------------------------------------
Method SetaSldIni(cCodProd,nQtdade,nVlSldUICM,nVlSldTICM,nVlSldUBST,nVlSldTBST,nVlSldUIST,nVlSldTIST,nVlSldUFCP,nVlSldTFCP) Class FISA302APURACAO
    Self:oSaldoProd:SetCodProd(cCodProd)    
    Self:oSaldoProd:SetQtdade(nQtdade)

    //---ICMS OP---//
    Self:oSaldoProd:SetSldTICM(nVlSldTICM)
    Self:oSaldoProd:SetSldUICM(nVlSldUICM)
    Self:oSaldoProd:SetUSD0ICM(nVlSldUICM)
    Self:oSaldoProd:SetSldHICM(nVlSldUICM)

    //---ICMS ST---//
    Self:oSaldoProd:SetSldTIST(nVlSldTIST)
    Self:oSaldoProd:SetSldUIST(nVlSldUIST)
    Self:oSaldoProd:SetUSD0IST(nVlSldUIST)
    Self:oSaldoProd:SetSldHIST(nVlSldUIST)

    //---BC ICMS ST---//
    Self:oSaldoProd:SetSldTBST(nVlSldTBST)
    Self:oSaldoProd:SetSldUBST(nVlSldUBST)
    Self:oSaldoProd:SetUSD0BST(nVlSldUBST)
    Self:oSaldoProd:SetSldHBST(nVlSldUBST)

    //---FECP---//
    Self:oSaldoProd:SetSldTFCP(nVlSldTFCP)
    Self:oSaldoProd:SetSldUFCP(nVlSldUFCP)
    Self:oSaldoProd:SetUSD0FCP(nVlSldUFCP)
    Self:oSaldoProd:SetSldHFCP(nVlSldUFCP)

    Self:oSaldoProd:SetOrdMov(0)
Return


//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} SetaMovim()
  
Método que carrega no objeto o movimento a ser analisado. 
Deve ser chamado a cada movimento encontrado para o produto em questão.

@author Rafael.Soliveira
@since 08/11/2019
@version 1.0
/*/
//--------------------------------------------------------------------------------------------------
Method SetaMovim(dDataMov,cTipoMov,cTipoDoc,cCodProd,cTipoPart,nAliqInt,cCFOP,cCST,cFGerNReal,cCFOPRess,nQtdade,nVlrUnit,nVlrTotPrd,nVlrFrete,nVlrSeguro,nVlrDesp,nVlrDesc,nVlrTotNf,nVlrBICMS,nVlrICMS,nVlrBICMST,nVlrICMSST,nVlrBCFec,nAliqFec,nVlrFec,nVlrICMEfe,cRespRet,dDtMovOri,nVlrEfeOri,aDocOriApu,cInscricao,cContrib) Class FISA302APURACAO
    Self:oMovimento:ClearMov()
    Self:oMovimento:SetDataMov(dDataMov)
    Self:oMovimento:SetTipoMov(cTipoMov)
    Self:oMovimento:SetTipoDoc(cTipoDoc)
    Self:oMovimento:SetCodProd(cCodProd)
    Self:oMovimento:SetTipoPar(cTipoPart)
    Self:oMovimento:SetAliqInt(nAliqInt)
    Self:oMovimento:SetCFOP(cCFOP)
    Self:oMovimento:SetCST(cCST)
    Self:oMovimento:SetFGerNR(cFGerNReal)
    Self:oMovimento:SetCFOPRes(cCFOPRess)
    Self:oMovimento:SetQtdade(nQtdade)
    Self:oMovimento:SetVUnit(nVlrUnit)
    Self:oMovimento:SetTotPrd(nVlrTotPrd)
    Self:oMovimento:SetFrete(nVlrFrete)
    Self:oMovimento:SetSeguro(nVlrSeguro)
    Self:oMovimento:SetDespesa(nVlrDesp)
    Self:oMovimento:SetDescont(nVlrDesc)
    Self:oMovimento:SetTotNf(nVlrTotNf)
    Self:oMovimento:SetBICMS(nVlrBICMS)
    Self:oMovimento:SetVICMS(nVlrICMS)
    Self:oMovimento:SetBICMST(nVlrBICMST)
    Self:oMovimento:SetVICMSST(nVlrICMSST)
    Self:oMovimento:SetBFec(nVlrBCFec)
    Self:oMovimento:SetAliqFec(nAliqFec)
    Self:oMovimento:SetVFec(nVlrFec)
    Self:oMovimento:SetICMSEfe(nVlrICMEfe)
    Self:oMovimento:SetRespRet(cRespRet)
    Self:oMovimento:SetDtMvOri(dDtMovOri)
    Self:oMovimento:SetVEfeOri(nVlrEfeOri)
    Self:oMovimento:SetDocOrig(aDocOriApu)
    Self:oMovimento:SetInscric(cInscricao)
    Self:oMovimento:SetContrib(cContrib)
    Self:oMovimento:EhContrib()

Return


//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} ApuraMovim()
  
Método responsável por 

@author Rafael.Soliveira
@since 08/11/2019
@version 1.0
/*/
//--------------------------------------------------------------------------------------------------
Method ApuraMovim() Class FISA302APURACAO
    Local cTipoMov    := Self:oMovimento:GetTipoMov()
    Local cCodProd    := Self:oMovimento:GetCodProd()
    Local nQtdade     := Self:oMovimento:GetQtdade()
    Local cTipoDoc    := Self:oMovimento:GetTipoDoc()
    Local nAliqInt    := Self:oMovimento:GetAliqInt()
    Local cCFOPRess   := Self:oMovimento:GetCFOPRes()

    Local nVlrUnit    := Self:oMovimento:GetVUnit()
    Local nVlrBICMS   := Self:oMovimento:GetBICMS()
    Local nVlrICMS    := Self:oMovimento:GetVICMS()
    Local nVlrBICMST  := Self:oMovimento:GetBICMST()
    Local nVlrICMSST  := Self:oMovimento:GetVICMSST()
    Local nVlrFec     := Self:oMovimento:GetVFec()
    Local nVlrICMEfe  := Self:oMovimento:GetICMSEfe()
    Local aDocOriApu  := Self:oMovimento:GetDocOrig()
    Local cRespRet    := Self:oMovimento:GetRespRet()
    Local dDtMovOri   := Self:oMovimento:GetDtMvOri()
    Local nVlrEfeOri  := Self:oMovimento:GetVEfeOri()
    Local nVlrFrete   := Self:oMovimento:GetFrete()
    Local nVlrSeguro  := Self:oMovimento:GetSeguro()
    Local nVlrDesp    := Self:oMovimento:GetDespesa()
    Local nVlrDesc    := Self:oMovimento:GetDescont()

    Local cInscricao  := Self:oMovimento:GetInscric()
    Local cContrib    := Self:oMovimento:GetContrib()
    Local cTipoPart   := Self:oMovimento:GetTipoPar()
    Local lEhContrib  := Self:oMovimento:GetEhContrib()
   
    Local cUF         := Self:GetUF()
    Local lUF11C185   := Self:Get11C185()

    Local nVlUICMSOp  := 0 //---Valor Unitário do ICMS OP    - Entrada---//
    Local nVlUBICMST  := 0 //---Valor Unitário da BC IMCS ST - Entrada---//
    Local nVlUICMSST  := 0 //---Valor Unitário do ICMS ST    - Entrada---//
    Local nVlUFECP    := 0 //---Valor Unitário do FECP ST    - Entrada---//

    Local nVUICMOpCF  := 0 //---Valor ICMS OP saída à CF                                     - Saída---//
    Local nVUICMOpFG  := 0 //---Valor ICMS OP entrada - Fato Gerador Presumido não realizado - Saída---//
    Local nVlrResIC   := 0 //---Valor de Restituição do ICMS ST                              - Saída---//
    Local nVlrResFC   := 0 //---Valor de Restituição do FECP ST                              - Saída---//
    Local nVlrUResIC  := 0 //---Valor Unitário de Restituição do ICMS ST                     - Saída---//
    Local nVlrUResFC  := 0 //---Valor Unitário de Restituição do FECP ST                     - Saída---//
    Local nVlrComIC   := 0 //---Valor de Complemento do ICMS ST                              - Saída---//
    Local nVlrComFC   := 0 //---Valor de Complemento do FECP ST                              - Saída---//
    Local nVlrUComIC  := 0 //---Valor Unitário de Complemento do ICMS ST                     - Saída---//
    Local nVlrUComFC  := 0 //---Valor Unitário de Complemento do FECP ST                     - Saída---//
    Local nVlrCICOP   := 0 //---Valor Crédito do ICMS OP                                     - Saída---//
    Local cCodEnquad  := ''//---Enquadramento da Operação                                    - Saída---//

    Local nVlMICMSOp  := 0 //---Valor Médio Unitário do ICMS OP do estoque                   - Estoque---//
    Local nVlMBCICST  := 0 //---Valor Médio Unitário da BC ICMS ST do estoque                - Estoque---//
    Local nVlMICMSST  := 0 //---Valor Médio Unitário do ICMS ST do estoque                   - Estoque---//
    Local nVlMFECP    := 0 //---Valor Médio Unitário do FECP ST do estoque                   - Estoque---//

    Local cGeraSPED   := '1'
    Local lDocOriApu  := .T.
    Local lGerrespre  := .T.
    Local nPos        := 0
    Local oMovEntr    := Nil
    Local nDecimal    := 2

    If  cUF == "RS"    // Caso RS considera 6 casas decimais para gravação na tabela CII
        nDecimal := 6
    Endif
    
    If (cTipoMov=='E' .And. cTipoDoc != 'D') .Or. (cTipoMov=='S' .And. cTipoDoc == 'D') //---Entradas / Devoluções de Entradas---//

        If cTipoDoc != 'D' .Or. (cTipoDoc == 'D' .And. Empty(aDocOriApu[1]) .And. nVlrBICMST > 0 .And. cUF != 'RS')

            //------------------------------------------------------------------------------------------------------------------------------------------------------//
            /* Guia Prático EFD-ICMS/IPI – Versão 3.0.6
               REGISTRO C180: INFORMAÇÕES COMPLEMENTARES DAS OPERAÇÕES DE ENTRADA DE MERCADORIAS SUJEITAS À SUBSTITUIÇÃO TRIBUTÁRIA (CÓDIGO 01, 1B, 04 e 55).
                   06 VL_UNIT_ICMS_OP_CONV | Valor unitário do ICMS operação própria que o informante teria direito ao crédito caso a mercadoria estivesse sob o regime comum de tributação, considerando unidade utilizada para informar o campo “QUANT_CONV”.
                   07 VL_UNIT_BC_ICMS_ST   | Valor unitário da base de cálculo do imposto pago ou retido anteriormente por substituição, considerando a unidade utilizada para informar o campo “QUANT_CONV”, aplicando-se redução, se houver.
                   08 VL_UNIT_ICMS_ST_CONV | Valor unitário do imposto pago ou retido anteriormente por substituição, inclusive FCP se devido, considerando a unidade utilizada para informar o campo “QUANT_CONV”.
                   09 VL_UNIT_FCP_ST_CONV  | Valor unitário do FCP_ST agregado ao valor informado no campo “VL_UNIT_ICMS_ST_CONV”

                   Campo 06 (VL_UNIT_ICMS_OP_CONV) – Preenchimento: corresponde ao valor do campo 05 (VL_UNIT_CONV), aplicando-se, se houver, a redução da base de cálculo na tributação de ICMS ST, 
                                                     multiplicado pela alíquota estabelecida na legislação da UF, conforme a operação (interna, interestadual).

                                                    Campo 5 (VL_UNIT_CONV), com redução de base de cálculo, conforme a legislação da UF
                                                    * alíq. interna
                                                    = Campo 06 (VL_UNIT_ICMS_OP_CONV)

                                                    Quando o campo 07 (VL_UNIT_BC_ICMS_ST_CONV) for menor que o campo 05 (VL_UNIT_CONV), o valor unitário da base de cálculo da retenção do ICMS ST 
                                                    deve ser utilizado no lugar do valor unitário da mercadoria:

                                                    Campo 07 (VL_UNIT_BC_ICMS_ST _CONV), com redução de base de cálculo, conforme a legislação da UF
                                                    * alíq. interna
                                                    = Campo 06 (VL_UNIT_ICMS_OP_CONV)

                   Campo 08 (VL_UNIT_ICMS_ST_CONV) - Preenchimento: Informar o valor unitário do ICMS ST pago ou retido limitado à parcela do ICMS ST correspondente ao fato gerador presumido que ainda 
                                                     não se realizou. Corresponde ao campo 07 (VL_UNIT_BC_ICMS_ST _CONV), aplicada a redução de base de cálculo se houver, multiplicada pela alíquota interna
                                                     (com o adicional de FCP), estabelecida pela legislação da UF, subtraída do campo 06 (VL_UNIT_ICMS_OP_CONV).

                                                     Campo 07 (VL_UNIT_BC_ICMS_ST _CONV), com redução, conforme a legislação da UF
                                                     * alíq. interna (incluindo o adicional de FCP)
                                                     - Campo 06 (VL_UNIT_ICMS_OP_CONV)
                                                     = Campo 08 (VL_UNIT_ICMS_ST_CONV) 
            */
            //------------------------------------------------------------------------------------------------------------------------------------------------------//

            //---Define Unitário BC ICMS ST---//
            nVlUBICMST := Round(nVlrBICMST / nQtdade, 6)

            //---Define Unitário ICMS OP---//
            If nVlrICMS == 0 .Or. cRespRet == '2'
                nVlUICMSOp := Round(((Iif(nVlUBICMST < nVlrUnit, nVlUBICMST, nVlrUnit) * nAliqInt) / 100), 6)
                nVlrICMS   := Round(nVlUICMSOp * nQtdade, nDecimal)
            Else
                nVlUICMSOp := Round(nVlrICMS / nQtdade, 6)
            EndIf

            //---Define Unitário ICMS ST---//
            If nVlrICMSST == 0 .Or. cRespRet == '2'
                If nVlUBICMST > 0
                    nVlUICMSST := Round(((nVlUBICMST * nAliqInt)/ 100),6) - nVlUICMSOp
                    nVlrICMSST := Round(nVlUICMSST * nQtdade, nDecimal)
                EndIf
            Else
                nVlUICMSST := Round(nVlrICMSST / nQtdade, 6)
            EndIf

            //---Define Unitário FECP---//
            nVlUFECP := Round(nVlrFec / nQtdade, 6)

        ElseIf !Empty(aDocOriApu[1]) .And. aDocOriApu[15] != '2' //---Apuração do movimento original encontrada (tabela CII)---//

            //------------------------------------------------------------------------------------------------------------------------------------------------------//
            /* Guia Prático EFD-ICMS/IPI – Versão 3.0.6
               REGISTRO C186: INFORMAÇÕES COMPLEMENTARES DAS OPERAÇÕES DE DEVOLUÇÃO DE ENTRADAS DE MERCADORIAS SUJEITAS À SUBSTITUIÇÃO TRIBUTÁRIA (CÓDIGO 01, 1B, 04 e 55).
                   16 VL_UNIT_ICMS_OP_CONV_ENTRADA    | Valor unitário do ICMS correspondente ao valor do campo VL_UNIT_ICMS_OP_CONV, preenchido na ocasião da entrada 
                   17 VL_UNIT_BC_ICMS_ST_CONV_ENTRADA | Valor unitário da base de cálculo do imposto pago ou retido anteriormente por substituição, correspondente ao valor do campo VL_UNIT_BC_ICMS_ST_CONV, preenchido na ocasião da entrada
                   18 VL_UNIT_ICMS_ST_CONV_ENTRADA    | Valor unitário do imposto pago ou retido anteriormente por substituição, inclusive FCP se devido, correspondente ao valor do campo VL_UNIT_ICMS_ST_CONV, preenchido na ocasião da entrada
                   19 VL_UNIT_FCP_ST_CONV_ENTRADA     | Valor unitário do FCP_ST, correspondente ao valor do campo VL_UNIT_FCP_ST_CONV, preenchido na ocasião da entrada

                   Campo 16 (VL_UNIT_ICMS_OP_CONV_ENTRADA) - Preenchimento: A obrigatoriedade de informação deste campo deve seguir a legislação de cada UF.
                   Campo 17 (VL_UNIT_BC_ICMS_ST _CONV_ENTRADA) - Preenchimento: A obrigatoriedade de informação deste campo deve seguir a legislação de cada UF.
                   Campo 18 (VL_UNIT_ICMS_ST_CONV_ENTRADA) - Preenchimento: A obrigatoriedade de informação deste campo deve seguir a legislação da UF de domicílio do contribuinte.
                   Campo 19 (VL_UNIT_FCP_ST_CONV_ENTRADA) - Preenchimento: A obrigatoriedade de informação deste campo deve seguir a legislação de cada UF. 
            */
            //------------------------------------------------------------------------------------------------------------------------------------------------------//

            //---Define Unitário BC ICMS ST---//
            nVlUBICMST := aDocOriApu[13]
            nVlrBICMST := Round(nVlUBICMST * nQtdade, nDecimal)

            //---Define Unitário ICMS OP---//
            nVlUICMSOp := aDocOriApu[11]
            nVlrICMS   := Round(nVlUICMSOp * nQtdade, nDecimal)

            //---Define Unitário ICMS ST---//
            nVlUICMSST := aDocOriApu[12]
            nVlrICMSST := Round(nVlUICMSST * nQtdade, nDecimal)

            //---Define Unitário FECP---//
            nVlUFECP   := aDocOriApu[14]
            nVlrFec    := Round(nVlUFECP * nQtdade, nDecimal)
            
        ElseIf Empty(aDocOriApu[1]) .And. cUF == 'RS' //---Apuração do movimento original não encontrada (tabela CII): [RS] - Utilizará o cálculo disposto na INSTRUÇÃO NORMATIVA DRP Nº 045/98, Subitem 19.3-A.1.4.1 ---//

            //---Define Unitário BC ICMS ST---//
            nVlUBICMST := Self:oSaldoProd:GetSldHBST()
            nVlrBICMST := Round(nVlUBICMST * nQtdade, nDecimal)

            //---Define Unitário ICMS OP---//
            nVlUICMSOp := Self:oSaldoProd:GetSldHICM()
            nVlrICMS   := Round(nVlUICMSOp * nQtdade, nDecimal)

            //---Define Unitário ICMS ST---//
            nVlUICMSST := Self:oSaldoProd:GetSldHIST()
            nVlrICMSST := Round(nVlUICMSST * nQtdade, nDecimal)

            //---Define Unitário FECP---//
            nVlUFECP := Self:oSaldoProd:GetSldHFCP()
            nVlrFec  := Round(nVlUFECP * nQtdade, nDecimal)

            //---Define Unitário---//
            nVlrUnit := nVlUBICMST * (nVlUICMSOp / (nVlUICMSOp + nVlUICMSST))

        Else //---Apuração do movimento original não encontrada (tabela CII)---//
            lDocOriApu := .F.
        EndIf

        //---Enquadra a Operação---//
        If cTipoDoc == 'D'
            cCodEnquad := '07' //--Devolução de Entrada---//
        EndIf

        //---Verifica Enquadramento da Operação (Regra de Apuração)---//
        If !Self:ValRegCod(cCodEnquad) .Or. cCFOPRess == '2' .Or. !lDocOriApu

            //---Desfaz os cálculos realizados para o movimento---//
            nVlUICMSOp  := 0
            nVlUBICMST  := 0
            nVlUICMSST  := 0
            nVlUFECP    := 0

            //---Recompõe valores para atualização de Saldos em Estoque a partir da Média Atual do Estoque (para não alterar médias)---//
            nVlrBICMST := Round(Self:oSaldoProd:GetSldUBST() * nQtdade, nDecimal)
            nVlrICMS   := Round(Self:oSaldoProd:GetSldUICM() * nQtdade, nDecimal)
            nVlrICMSST := Round(Self:oSaldoProd:GetSldUIST() * nQtdade, nDecimal)
            nVlrFec    := Round(Self:oSaldoProd:GetSldUFCP() * nQtdade, nDecimal)

            //---Insere flag no movimento para que o registro C180/C186 não seja escriturado, uma vez que: A regra de apuração não tem código 5.7 correspondente [OU] o CFOP está ajustado para não realizar cálculo de ressasrcimento [OU] para o movimento de devolução a apuração do movimento original não foi encontrada---//
            cGeraSPED := '2'

        EndIf

        //---Atualiza o saldo do produto---//
        Self:oSaldoProd:AtuSaldo(cTipoMov,cCodProd,nQtdade,nVlrICMS,nVlrICMSST,nVlrBICMST,nVlrFec,cCodEnquad)
        //---Recurera o Valor Médio Atual do Estoque---//
        nVlMICMSOp  := Self:oSaldoProd:GetSldUICM()
        nVlMBCICST  := Self:oSaldoProd:GetSldUBST()
        nVlMICMSST  := Self:oSaldoProd:GetSldUIST()
        nVlMFECP    := Self:oSaldoProd:GetSldUFCP()

    Else

        If cTipoMov=='S' .And. cTipoDoc != 'D' //---Saídas---//

            //------------------------------------------------------------------------------------------------------------------------------------------------------//
            /* Guia Prático EFD-ICMS/IPI – Versão 3.0.6
            REGISTRO C185: INFORMAÇÕES COMPLEMENTARES DAS OPERAÇÕES DE SAÍDA DE MERCADORIAS SUJEITAS À SUBSTITUIÇÃO TRIBUTÁRIA (CÓDIGO 01, 1B, 04, 55 e 65).
                10 VL_UNIT_ICMS_NA_OPERACAO_CONV    | Valor unitário para o ICMS na operação, caso não houvesse a ST, considerando unidade utilizada para informar o campo “QUANT_CONV”, considerando redução da base de cálculo do ICMS ST na tributação, se houver
                11 VL_UNIT_ICMS_OP_CONV             | Valor unitário do ICMS OP calculado conforme a legislação de cada UF, considerando a unidade utilizada para informar o campo “QUANT_CONV”, utilizado para cálculo de ressarcimento/restituição de ST, no desfazimento da substituição tributária, quando se utiliza a fórmula descrita nas instruções de preenchimento do campo 15, no item a1).
                12 VL_UNIT_ICMS_OP_ESTOQUE_CONV     | Valor médio unitário do ICMS que o contribuinte teria se creditado referente à operação de entrada das mercadorias em estoque caso estivesse submetida ao regime comum de tributação, calculado conforme a legislação de cada UF, considerando a unidade utilizada para informar o campo “QUANT_CONV” 
                13 VL_UNIT_ICMS_ST_ESTOQUE_CONV     | Valor médio unitário do ICMS ST, incluindo FCP ST, das mercadorias em estoque, considerando a unidade utilizada para informar o campo “QUANT_CONV” 
                14 VL_UNIT_FCP_ICMS_ST_ESTOQUE_CONV | Valor médio unitário do FCP ST agregado ao ICMS das mercadorias em estoque, considerando a unidade utilizada para informar o campo “QUANT_CONV” 
                15 VL_UNIT_ICMS_ST_CONV_REST        | Valor unitário do total do ICMS ST, incluindo FCP ST, a ser restituído/ressarcido, calculado conforme a legislação de cada UF, considerando a unidade utilizada para informar o campo “QUANT_CONV”
                16 VL_UNIT_FCP_ST_CONV_REST         | Valor unitário correspondente à parcela de ICMS FCP ST que compõe o campo “VL_UNIT_ICMS_ST_CONV_REST”, considerando a unidade utilizada para informar o campo “QUANT_CONV”.
                17 VL_UNIT_ICMS_ST_CONV_COMPL       | Valor unitário do complemento do ICMS, incluindo FCP ST, considerando a unidade utilizada para informar o campo “QUANT_CONV”. 
                18 VL_UNIT_FCP_ST_CONV_COMPL        | Valor unitário correspondente à parcela de ICMS FCP ST que compõe o campo “VL_UNIT_ICMS_ST_CONV_COMPL”, considerando unidade utilizada para informar o campo “QUANT_CONV”.

                Campo 10 (VL_UNIT_ICMS_NA_OPERACAO_CONV) – Preenchimento: Valor correspondente à multiplicação da alíquota interna (incluindo FCP) (informado no registro 0200) da mercadoria 
                                                            pelo valor correspondente à operação de saída que seria tributada se não houvesse ST, considerando a unidade utilizada para informar
                                                            o campo “QUANT_CONV”, aplicando-se a mesma redução da base de cálculo do ICMS ST na tributação, se houver.

                Campo 11 (VL_UNIT_ICMS_OP_CONV) – Preenchimento: Nos casos de direito a crédito do imposto pela não ocorrência do fato gerador presumido e desfazimento da ST, corresponde ao 
                                                    valor do ICMS da operação própria do sujeito passivo por substituição do qual a mercadoria tenha sido recebida diretamente ou o valor do ICMS 
                                                    que seria atribuído à operação própria do contribuinte substituído do qual a mercadoria tenha sido recebida, caso estivesse submetida ao regime
                                                    comum de tributação, calculado conforme a legislação de cada UF, considerando unidade utilizada para informar o campo “QUANT_CONV”.
                                                    Para as UFs em que a legislação estabelecer que o valor desse campo corresponderá ao mesmo valor expresso no campo 12 (VL_UNIT_ICMS_OP_ESTOQUE_CONV), 
                                                    seu preenchimento será facultativo. O valor deste campo, quando obrigatório na UF, será utilizado para o cálculo do valor do ressarcimento/restituição
                                                    do Campo 15 (VL_UNIT_ICMS_ST_CONV_REST).
                                                    UFs:
                                                    ***MG - Campo Não deve ser preenchido***

                Campo 12 (VL_UNIT_ICMS_OP_ESTOQUE_CONV): Preenchimento: Informar o valor médio unitário de ICMS OP, das mercadorias em estoque. O período para o cálculo do valor médio deve 
                atender à legislação de cada UF. Ex. diário, mensal etc.

                Campo 13 (VL_UNIT_ICMS_ST_ESTOQUE_CONV): Preenchimento: Informar o valor médio unitário do ICMS ST, incluindo FCP ST, pago ou retido, das mercadorias em estoque. Quando a 
                                                            mercadoria estiver sujeita ao FCP adicionado ao ICMS ST, neste campo deve ser informado o valor médio unitário da parcela do ICMS 
                                                            ST + a parcela do FCP. O período para o cálculo do valor médio deve atender à legislação de cada UF. Ex. diário, mensal etc

                Campo 14 (VL_UNIT_FCP_ICMS_ST_ESTOQUE_CONV) -: Preenchimento: Informar o valor médio unitário da parcela do FCP adicionado ao ICMS que tenha sido informado no campo 
                                                                “VL_UNIT_ICMS_ST_ESTOQUE_CONV”.

                Campo 15 (VL_UNIT_ICMS_ST_CONV_REST) – Validação: O valor a ser ressarcido / restituído é calculado conforme as orientações a seguir:
                                                        a) Nos casos de direito ao crédito do imposto, por não ocorrência do fato gerador presumido:
                                                        a.1) Quando o campo 11 (VL_UNIT_ICMS_OP_CONV) for obrigatório, de acordo com a legislação da UF, correspondente ao seguinte cálculo, 
                                                        considerando a unidade utilizada para informar o campo “QUANT_CONV”:
                                                            Campo 12 (VL_UNIT_ICMS_OP_ESTOQUE_CONV)
                                                        + Campo 13 (VL_UNIT_ICMS_ST_ESTOQUE_CONV)
                                                        - Campo 11 (VL_UNIT_ICMS_OP_CONV)
                                                        = Campo 15 (VL_UNIT_ICMS_ST_CONV_REST)

                                                        a.2) Quando o campo 11(VL_UNIT_ICMS_OP_CONV) não for obrigatório, de acordo com a legislação da UF, corresponde ao valor no campo 
                                                        13 (VL_UNIT_ICMS_ST_ESTOQUE_CONV)

                                                        b) Nos casos de direito ao crédito do imposto, calculada com base no valor de saída da mercadoria inferior ao valor da BC ICMS ST, 
                                                        informar o valor unitário de ICMS correspondente ao seguinte cálculo, considerando a unidade utilizada para informar o campo “QUANT_CONV”:
                                                            Campo 12 (VL_UNIT_ICMS_OP_ESTOQUE_CONV)
                                                        + Campo 13 (VL_UNIT_ICMS_ST_ESTOQUE_CONV)
                                                        - Campo 10 (VL_UNIT_ICMS_NA_OPERACAO_CONV)
                                                        = Campo 15 (VL_UNIT_ICMS_ST_CONV_REST)

                Campo 16 (VL_UNIT_FCP_ST_CONV_REST) – Preenchimento: Informar o valor unitário do Fundo de Combate à Pobreza (FCP) vinculado à substituição tributária que compõe o campo 
                                                        “VL_UNIT_ICMS_ST_CONV_REST”, considerando a unidade utilizada para informar o campo “QUANT_CONV”, conforme previsão das legislações das UF.

                Campo 17 (VL_UNIT_ICMS_ST_CONV_COMPL) – Validação: Nos casos de complemento, informar o valor unitário de ICMS correspondente ao cálculo a seguir. O valor a ser ressarcido / 
                                                        restituído é calculado conforme as orientações a seguir:
                                                            Campo 10 (VL_UNIT_ICMS_NA_OPERACAO_CONV)
                                                        - Campo 12 (VL_UNIT_ICMS_OP_ESTOQUE_CONV)
                                                        - Campo 13 (VL_UNIT_ICMS_ST_ESTOQUE_CONV)
                                                        = Campo 17 (VL_UNIT_ICMS_ST_CONV_COMPL)
    
                Campo 18 (VL_UNIT_FCP_ST_CONV_COMPL) – Preenchimento: Informar o valor unitário do Fundo de Combate à Pobreza (FCP) vinculado à substituição tributária que compõe o campo 17 
                                                        “VL_UNIT_ICMS_ST_CONV_COMPL”, considerando a unidade utilizada para informar o campo “QUANT_CONV”, conforme previsão das legislações das 
                                                        UF.
            */
            //------------------------------------------------------------------------------------------------------------------------------------------------------//

            //---Recurera o Valor Médio Atual do Estoque [C185 Campos 12 13 14]---//
            nVlMICMSOp  := Self:oSaldoProd:GetSldUICM()
            nVlMBCICST  := Self:oSaldoProd:GetSldUBST()
            nVlMICMSST  := Self:oSaldoProd:GetSldUIST()
            nVlMFECP    := Self:oSaldoProd:GetSldUFCP()

            //---Enquadra a Operação de Saída---//
            cCodEnquad := Self:oMovimento:EnquadMov()
            lGerrespre := Self:oMovimento:GetlGerrespre()
            
            If cCodEnquad != '00'
                
                If cCodEnquad == '01' //---Saída a Consumidor Final---//

                    //---Define o Valor ICMS OP saída à CF [C185 Campo 10]---//
                    If nVlrICMEfe > 0
                        nVUICMOpCF := Round(nVlrICMEfe / nQtdade, 6)
                    Else
                        If nVlrBICMS = 0
                            nVlrBICMS := Self:oMovimento:DefBaseICM()
                        EndIf
                        nVUICMOpCF := Round(((nVlrBICMS*nAliqInt)/100) / nQtdade, 6)
                    EndIf

                    //---Define o Valor de Restutuição / Complemento [C185 Campos 15 16 17 18]---//
                    If (nVlMICMSOp + nVlMICMSST) > nVUICMOpCF
                        /*  Campo 12 (VL_UNIT_ICMS_OP_ESTOQUE_CONV)
                        + Campo 13 (VL_UNIT_ICMS_ST_ESTOQUE_CONV)
                        - Campo 10 (VL_UNIT_ICMS_NA_OPERACAO_CONV)
                        = Campo 15 (VL_UNIT_ICMS_ST_CONV_REST)
                        */
                        nVlrUResIC := (nVlMICMSOp + nVlMICMSST) - nVUICMOpCF
                        nVlrUResFC := 0
                        nVlrResIC  := Round(nVlrUResIC * nQtdade, nDecimal)
                        nVlrResFC  := Round(nVlrUResFC * nQtdade, nDecimal)
                    Else 
                        /*  Campo 10 (VL_UNIT_ICMS_NA_OPERACAO_CONV)
                        - Campo 12 (VL_UNIT_ICMS_OP_ESTOQUE_CONV)
                        - Campo 13 (VL_UNIT_ICMS_ST_ESTOQUE_CONV)
                        = Campo 17 (VL_UNIT_ICMS_ST_CONV_COMPL)
                        */
                        nVlrUComIC := nVUICMOpCF - (nVlMICMSOp + nVlMICMSST)
                        nVlrUComFC := 0
                        nVlrComIC  := Round(nVlrUComIC * nQtdade, nDecimal)
                        nVlrComFC  := Round(nVlrUComFC * nQtdade, nDecimal)
                        cCodEnquad := '06' //--Saída a Consumidor Final - Complemento---//
                    EndIf

                Else 
                    
                    nVUICMOpCF := Round(((nVlrBICMS*nAliqInt)/100) / nQtdade, 6)
                    
                    //---Define o Valor de Restutuição [C185 Campos 15 16]---//
                    If lUF11C185
                        /*   Campo 12 (VL_UNIT_ICMS_OP_ESTOQUE_CONV)
                        + Campo 13 (VL_UNIT_ICMS_ST_ESTOQUE_CONV)
                        - Campo 11 (VL_UNIT_ICMS_OP_CONV)
                        = Campo 15 (VL_UNIT_ICMS_ST_CONV_REST)
                        */

                        //---Define o Valor ICMS OP entrada - Fato Gerador Presumido não realizado [C185 Campo 11 - ***ATENÇÃO***: OBSERVAR CRITÉRIO DE CADA UF]---//
                        nVUICMOpFG := Self:oMovimento:DefICMSOP(cUF,cCodEnquad,nVlMICMSOp)

                        nVlrUResIC := (nVlMICMSOp + nVlMICMSST) - nVUICMOpFG
                    
                    //---Define o Valor de Restituição / Complemento para Enquadramento 04 - Saída para outro Estado
                    //O trecho deste ElseIf é extraido da legislação de MG, ou seja, !lUF11C185
                    ElseIf cCodEnquad == '04' .and. nVUICMOpCF > (nVlMICMSOp + nVlMICMSST) .and. !lEhContrib .and. cTipoPart == 'F' .and. lGerrespre 
                    
                    /*  http://www.fazenda.mg.gov.br/empresas/legislacao_tributaria/ricms_2002_seco/anexoxv2002_2.html#parte1art31A
                        (3499) Parágrafo único - A complementação do ICMS ST de que trata o caput também é devida pelo contribuinte 
                        substituído na saída de mercadoria para outra unidade da federação promovida por microempresa ou empresa 
                        de pequeno porte quando destinada a consumidor final não contribuinte.
                    */
                        // Complementação
                        /*  
                          Campo 10 (VL_UNIT_ICMS_NA_OPERACAO_CONV)
                        - Campo 12 (VL_UNIT_ICMS_OP_ESTOQUE_CONV)
                        - Campo 13 (VL_UNIT_ICMS_ST_ESTOQUE_CONV)
                        = Campo 17 (VL_UNIT_ICMS_ST_CONV_COMPL)
                        */
                        nVlrUComIC := nVUICMOpCF - (nVlMICMSOp + nVlMICMSST)
                        nVlrUComFC := 0
                        nVlrComIC  := Round(nVlrUComIC * nQtdade, nDecimal)
                        nVlrComFC  := Round(nVlrUComFC * nQtdade, nDecimal)
                        cCodEnquad := '06' //  Complemento ---//
                    Else 
                        /* Quando o campo 11(VL_UNIT_ICMS_OP_CONV) não for obrigatório, de acordo com a legislação da UF, corresponde ao valor no campo 13 (VL_UNIT_ICMS_ST_ESTOQUE_CONV) */
                        nVlrUResIC := nVlMICMSST
                    EndIf    

                    nVlrUResFC := 0
                    nVlrResIC  := Round(nVlrUResIC * nQtdade, nDecimal)
                    nVlrResFC  := Round(nVlrUResFC * nQtdade, nDecimal)

                EndIf

            EndIf

            //---Compõe valores para atualização de Saldos em Estoque---//
            nVlrICMS   := Round(nVlMICMSOp * nQtdade, nDecimal)
            nVlrICMSST := Round(nVlMICMSST * nQtdade, nDecimal)
            nVlrBICMST := Round(nVlMBCICST * nQtdade, nDecimal)
            nVlrFec    := Round(nVlMFECP   * nQtdade, nDecimal)

            //---Calcula Valor do Crédito do ICMS OP, nas hipóteses em que há direito a esse crédito---//
            If cCodEnquad == '04'
                nVlrCICOP := nVlrICMS
            EndIf

        Else //---Devoluções de Saídas---//

            //------------------------------------------------------------------------------------------------------------------------------------------------------//
            /* Guia Prático EFD-ICMS/IPI – Versão 3.0.6
            REGISTRO C181: INFORMAÇÕES COMPLEMENTARES DAS OPERAÇÕES DE DEVOLUÇÃO DE SAÍDAS DE MERCADORIAS SUJEITAS À SUBSTITUIÇÃO TRIBUTÁRIA (CÓDIGO 01, 1B, 04 e 55).
                13 VL_UNIT_ICMS_OP_ESTOQUE_CONV_SAIDA     | Valor médio unitário do ICMS OP, das mercadorias em estoque, correspondente ao valor do campo VL_UNIT_ICMS_OP_ESTOQUE_CONV, preenchido na ocasião da saída
                14 VL_UNIT_ICMS_ST_ESTOQUE_CONV_SAIDA     | Valor médio unitário do ICMS ST, incluindo FCP ST, das mercadorias em estoque, correspondente ao valor do campo VL_UNIT_ICMS_ST_ESTOQUE_CONV, preenchido na ocasião da saída
                15 VL_UNIT_FCP_ICMS_ST_ESTOQUE_CONV_SAIDA | Valor médio unitário do FCP ST agregado ao ICMS das mercadorias em estoque, correspondente ao valor do campo VL_UNIT_FCP_ICMS_ST_ESTOQUE_CONV, preenchido na ocasião da saída
                16 VL_UNIT_ICMS_NA_OPERACAO_CONV_SAIDA    | Valor unitário para o ICMS na operação, correspondente ao valor do campo VL_UNIT_ICMS_NA_OPERACAO_CONV, preenchido na ocasião da saída 
                17 VL_UNIT_ICMS_OP_CONV_SAIDA             | Valor unitário do ICMS correspondente ao valor do campo VL_UNIT_ICMS_OP_CONV, preenchido na ocasião da saída 
                18 VL_UNIT_ICMS_ST_CONV_REST              | Valor unitário do total do ICMS ST, incluindo FCP ST, a ser restituído/ressarcido, correspondente ao estorno do complemento apurado na operação de saída 
                19 VL_UNIT_FCP_ST_CONV_REST               | Valor unitário correspondente à parcela de ICMS FCP ST que compõe o campo “VL_UNIT_ICMS_ST_CONV_REST”, considerando a unidade utilizada para informar o campo “QUANT_CONV”.
                20 VL_UNIT_ICMS_ST_CONV_COMPL             | Valor unitário do estorno do ressarcimento/restituição, incluindo FCP ST, apurado na operação de saída. 
                21 VL_UNIT_FCP_ST_CONV_COMPL              | Valor unitário correspondente à parcela de ICMS FCP ST que compõe o campo “VL_UNIT_ICMS_ST_CONV_COMPL”, considerando unidade utilizada para informar o campo “QUANT_CONV”.

                Campo 13 (VL_UNIT_ICMS_OP_ESTOQUE_CONV_SAIDA)     - Preenchimento: A obrigatoriedade de informação deste campo deve seguir a legislação de cada UF.
                Campo 14 (VL_UNIT_ICMS_ST_ESTOQUE_CONV_SAIDA)     - Preenchimento: A obrigatoriedade de informação deste campo deve seguir a legislação de cada UF.
                Campo 15 (VL_UNIT_FCP_ICMS_ST_ESTOQUE_CONV_SAIDA) - Preenchimento: A obrigatoriedade de informação deste campo deve seguir a legislação de cada UF.
                
                Campo 16 (VL_UNIT_ICMS_NA_OPERACAO_CONV_SAIDA)    - Preenchimento: A obrigatoriedade de informação deste campo deve seguir a legislação de cada UF. 
                Campo 17 (VL_UNIT_ICMS_OP_CONV_SAIDA)             - Preenchimento: Nos casos de devolução em que houve direito a crédito do imposto pela não ocorrência do fato gerador presumido 
                                                                    e desfazimento da ST, e a legislação da UF do informante adota o preenchimento desse campo, informar o valor preenchido no campo 
                                                                    VL_UNIT_ICMS_OP_CONV da escrituração do documento de saída. Para as UFs em que a legislação estabelecer que o valor desse campo 
                                                                    corresponderá ao mesmo valor expresso no campo 13 (VL_UNIT_ICMS_OP_ESTOQUE_CONV_SAIDA), seu preenchimento será facultativo. 

                Campo 18 (VL_UNIT_ICMS_ST_CONV_REST) – Preenchimento: Valor do estorno do complemento cobrado em saída anterior cuja devolução é escriturada no Registro C181.
                                                        Validação....: Quando o preenchimento dos campos 13, 14, 15 e 16 for obrigatório de acordo com a legislação da UF, o valor do estorno do 
                                                                        complemento é calculado conforme as orientações a seguir: 
                                                                        
                                                                        Campo 16 (VL_UNIT_ICMS_NA_OPERACAO_CONV_SAIDA)
                                                                    - Campo 13 (VL_UNIT_ICMS_OP_ESTOQUE_CONV_SAIDA)
                                                                    - Campo 14 (VL_UNIT_ICMS_ST_ESTOQUE_CONV_SAIDA)
                                                                    = Campo 18 (VL_UNIT_ICMS_ST_CONV_REST)

                Campo 20 (VL_UNIT_ICMS_ST_CONV_COMPL) – Validação: O estorno do valor ressarcido / restituído em operação de saída anterior, cuja devolução é escriturada no Registro C181, é 
                                                                    calculado conforme as orientações a seguir.

                                                                    a) Nos casos em que não houve ocorrência do fato gerador presumido:
                                                                    a.1) Quando o preenchimento dos campos 13, 14, 15 e 17 for obrigatório de acordo com a legislação da UF, correspondente ao seguinte 
                                                                        cálculo, considerando a unidade utilizada para informar o campo “QUANT_CONV”:

                                                                        Campo 13 (VL_UNIT_ICMS_OP_ESTOQUE_CONV_SAIDA)
                                                                        + Campo 14 (VL_UNIT_ICMS_ST_ESTOQUE_CONV_SAIDA)
                                                                        - Campo 17 (VL_UNIT_ICMS_OP_CONV_SAIDA)
                                                                        = Campo 20 (VL_UNIT_ICMS_ST_CONV_COMPL)

                                                                    a.2) Quando o campo 17 (VL_UNIT_ICMS_OP_CONV_SAIDA) não for obrigatório e o preenchimento do campo 14 for obrigatório, de acordo 
                                                                        com a legislação da UF, corresponde ao valor no campo 14 (VL_UNIT_ICMS_ST_ESTOQUE_CONV_SAIDA)

                                                                    b) Nos casos em que houve direito ao crédito do imposto, calculada com base no valor de saída da mercadoria inferior ao valor da BC 
                                                                        ICMS ST, quando o preenchimento dos campos 13, 14, 15 e 16 for obrigatório de acordo com a legislação da UF, informar o valor 
                                                                        unitário de ICMS correspondente ao seguinte cálculo, considerando a unidade utilizada para informar o campo “QUANT_CONV”:

                                                                        Campo 13 (VL_UNIT_ICMS_OP_ESTOQUE_CONV_SAIDA)
                                                                        + Campo 14 (VL_UNIT_ICMS_ST_ESTOQUE_CONV_SAIDA)
                                                                        - Campo 16 (VL_UNIT_ICMS_NA_OPERACAO_CONV_SAIDA)
                                                                        = Campo 20 (VL_UNIT_ICMS_ST_CONV_ COMPL)
            */
            //------------------------------------------------------------------------------------------------------------------------------------------------------//

            If !Empty(aDocOriApu[1]) //---Apuração do movimento original encontrada (tabela CII)---//

                //---Recurera o Valor Médio do Estoque utilizado no movimento original  [C181 Campos 13 14 15]---//
                nVlMICMSOp  := aDocOriApu[4]
                nVlMBCICST  := aDocOriApu[5]
                nVlMICMSST  := aDocOriApu[6]
                nVlMFECP    := aDocOriApu[7]

                //---Enquadra a Operação de Saída---//
                cCodEnquad := aDocOriApu[8]
                If cCodEnquad != '00'

                    If cCodEnquad $ '01|06' //---Saída a Consumidor Final---//

                        //---Define o Valor ICMS OP saída à CF [C181 Campo 16]---//
                        nVUICMOpCF := aDocOriApu[9]

                        //---Define o Valor de Restutuição / Complemento [C181 Campos 18 19 20 21]---//
                        If nVUICMOpCF > (nVlMICMSOp + nVlMICMSST)
                            /*  Campo 16 (VL_UNIT_ICMS_NA_OPERACAO_CONV_SAIDA)
                            - Campo 13 (VL_UNIT_ICMS_OP_ESTOQUE_CONV_SAIDA)
                            - Campo 14 (VL_UNIT_ICMS_ST_ESTOQUE_CONV_SAIDA)
                            = Campo 18 (VL_UNIT_ICMS_ST_CONV_REST)
                            */
                            nVlrUResIC := nVUICMOpCF - (nVlMICMSOp + nVlMICMSST)
                            nVlrUResFC := 0
                            nVlrResIC  := Round(nVlrUResIC * nQtdade, nDecimal)
                            nVlrResFC  := Round(nVlrUResFC * nQtdade, nDecimal)
                        Else 
                            /*  Campo 13 (VL_UNIT_ICMS_OP_ESTOQUE_CONV_SAIDA)
                            + Campo 14 (VL_UNIT_ICMS_ST_ESTOQUE_CONV_SAIDA)
                            - Campo 16 (VL_UNIT_ICMS_NA_OPERACAO_CONV_SAIDA)
                            = Campo 20 (VL_UNIT_ICMS_ST_CONV_COMPL)
                            */
                            nVlrUComIC := (nVlMICMSOp + nVlMICMSST) - nVUICMOpCF
                            nVlrUComFC := 0
                            nVlrComIC  := Round(nVlrUComIC * nQtdade, nDecimal)
                            nVlrComFC  := Round(nVlrUComFC * nQtdade, nDecimal)
                        EndIf

                        If cCodEnquad  == '01'
                            cCodEnquad  := '09' //--Devolução de Saída a Consumidor Final - Estorno de Ressarcimento---//
                        ElseIf cCodEnquad  == '06'
                            cCodEnquad  := '10' //--Devolução de Saída a Consumidor Final - Estorno de Complemento---//
                        EndIf

                    Else 

                        If lUF11C185
                            /*  Campo 13 (VL_UNIT_ICMS_OP_ESTOQUE_CONV_SAIDA)
                            + Campo 14 (VL_UNIT_ICMS_ST_ESTOQUE_CONV_SAIDA)
                            - Campo 17 (VL_UNIT_ICMS_OP_CONV_SAIDA)
                            = Campo 20 (VL_UNIT_ICMS_ST_CONV_COMPL)
                            */

                            //---Define o Valor ICMS OP entrada - Fato Gerador Presumido não realizado [C181 Campo 17 - ***ATENÇÃO***: OBSERVAR CRITÉRIO DE CADA UF]---//
                            nVUICMOpFG := aDocOriApu[10]

                            nVlrUComIC := (nVlMICMSOp + nVlMICMSST) - nVUICMOpFG
                        Else 
                            /* QQuando o campo 17 (VL_UNIT_ICMS_OP_CONV_SAIDA) não for obrigatório e o preenchimento do campo 14 for obrigatório, de acordo com a legislação da UF, corresponde ao valor no campo 14 (VL_UNIT_ICMS_ST_ESTOQUE_CONV_SAIDA) */
                            nVlrUComIC := nVlMICMSST
                        EndIf    
                        nVlrUComFC  := 0
                        nVlrComIC   := Round(nVlrUComIC * nQtdade, nDecimal)
                        nVlrComFC   := Round(nVlrUComFC * nQtdade, nDecimal)

                        If cCodEnquad  == '02'
                            cCodEnquad  := '11' //--Devolução de Saída - Fato Gerador Presumido não Realizado - Estorno de Ressarcimento---//
                        ElseIf cCodEnquad  == '03'
                            cCodEnquad  := '12' //--Devolução de Saída - Saída amparada por isenção ou não-incidência - Estorno de Ressarcimento---//
                        ElseIf cCodEnquad  == '04'
                            cCodEnquad  := '13' //--Devolução de Saída - Saída destinada a outro Estado - Estorno de Ressarcimento---//
                        EndIf

                    EndIf

                Else
                    cCodEnquad  := '08' //--Devolução de Saída Não Ensejadora de Ressarcimento---//
                EndIf

                //---Compõe valores para atualização de Saldos em Estoque---//
                nVlrICMS   := Round(nVlMICMSOp * nQtdade, nDecimal)
                nVlrICMSST := Round(nVlMICMSST * nQtdade, nDecimal)
                nVlrBICMST := Round(nVlMBCICST * nQtdade, nDecimal)
                nVlrFec    := Round(nVlMFECP   * nQtdade, nDecimal)

                //---Calcula Valor do Crédito do ICMS OP, nas hipóteses em que há direito a esse crédito---//
                If cCodEnquad == '13'
                    nVlrCICOP := nVlrICMS
                EndIf

                If aDocOriApu[15] == '2'
                    lDocOriApu := .F.
                EndIf

            ElseIf Empty(aDocOriApu[1]) .And. cUF == 'RS' //---Apuração do movimento original não encontrada (tabela CII): [RS] - Utilizará o cálculo disposto na INSTRUÇÃO NORMATIVA DRP Nº 045/98, Subitem 19.3-A.1.4.1 ---//

                //---Recupera o Valor Médio do Estoque baseand-se no último movimento de entrada realizado antes movimento original  [C181 Campos 13 14 15]---//
                oMovEntr := FISA302MOVIMENTOENTPROTHEUS():New()
                oMovEntr:cTipoRet := 'C'
                oMovEntr:cCodProd := cCodProd
                oMovEntr:nQtdade  := 1
                oMovEntr:dDataMov := dDtMovOri
                oMovEntr:nAliqInt := nAliqInt
                oMovEntr:DefICMSEnt()
                nVlMICMSOp := oMovEntr:nVlrICMSOP
                nVlMBCICST := oMovEntr:nVlrBSST
                nVlMICMSST := oMovEntr:nVlrICMSST
                nVlMFECP   := oMovEntr:nVlrFECP
                FreeObj(oMovEntr)

                //---Enquadra a Operação de Saída---//
                cCodEnquad := Self:oMovimento:EnquadMov()
                If cCodEnquad != '00'

                    If cCodEnquad $ '01|06' //---Saída a Consumidor Final---//

                        //---Define o Valor ICMS OP saída à CF [C181 Campo 16]---//
                        If nVlrEfeOri > 0
                            nVUICMOpCF := Round(nVlrEfeOri, 6)
                        Else
                            If nVlrBICMS = 0
                                nVlrBICMS := Self:oMovimento:DefBaseICM()
                            EndIf
                            nVUICMOpCF := Round(((nVlrBICMS*nAliqInt)/100) / nQtdade, 6)
                        EndIf
    
                        //---Define o Valor de Restutuição / Complemento [C181 Campos 18 19 20 21]---//
                        If nVUICMOpCF > (nVlMICMSOp + nVlMICMSST)
                            /*  Campo 16 (VL_UNIT_ICMS_NA_OPERACAO_CONV_SAIDA)
                            - Campo 13 (VL_UNIT_ICMS_OP_ESTOQUE_CONV_SAIDA)
                            - Campo 14 (VL_UNIT_ICMS_ST_ESTOQUE_CONV_SAIDA)
                            = Campo 18 (VL_UNIT_ICMS_ST_CONV_REST)
                            */
                            nVlrUResIC := nVUICMOpCF - (nVlMICMSOp + nVlMICMSST)
                            nVlrUResFC := 0
                            nVlrResIC  := Round(nVlrUResIC * nQtdade, nDecimal)
                            nVlrResFC  := Round(nVlrUResFC * nQtdade, nDecimal)
                        Else 
                            /*  Campo 13 (VL_UNIT_ICMS_OP_ESTOQUE_CONV_SAIDA)
                            + Campo 14 (VL_UNIT_ICMS_ST_ESTOQUE_CONV_SAIDA)
                            - Campo 16 (VL_UNIT_ICMS_NA_OPERACAO_CONV_SAIDA)
                            = Campo 20 (VL_UNIT_ICMS_ST_CONV_COMPL)
                            */
                            nVlrUComIC := (nVlMICMSOp + nVlMICMSST) - nVUICMOpCF
                            nVlrUComFC := 0
                            nVlrComIC  := Round(nVlrUComIC * nQtdade, nDecimal)
                            nVlrComFC  := Round(nVlrUComFC * nQtdade, nDecimal)
                        EndIf

                        If cCodEnquad  == '01'
                            cCodEnquad  := '09' //--Devolução de Saída a Consumidor Final - Estorno de Ressarcimento---//
                        ElseIf cCodEnquad  == '06'
                            cCodEnquad  := '10' //--Devolução de Saída a Consumidor Final - Estorno de Complemento---//
                        EndIf

                    Else 

                        If lUF11C185
                            /*  Campo 13 (VL_UNIT_ICMS_OP_ESTOQUE_CONV_SAIDA)
                            + Campo 14 (VL_UNIT_ICMS_ST_ESTOQUE_CONV_SAIDA)
                            - Campo 17 (VL_UNIT_ICMS_OP_CONV_SAIDA)
                            = Campo 20 (VL_UNIT_ICMS_ST_CONV_COMPL)
                            */

                            //---Define o Valor ICMS OP entrada - Fato Gerador Presumido não realizado [C181 Campo 17 - ***ATENÇÃO***: OBSERVAR CRITÉRIO DE CADA UF]---//
                            nVUICMOpFG := 0

                            nVlrUComIC := (nVlMICMSOp + nVlMICMSST) - nVUICMOpFG
                        Else 
                            /* QQuando o campo 17 (VL_UNIT_ICMS_OP_CONV_SAIDA) não for obrigatório e o preenchimento do campo 14 for obrigatório, de acordo com a legislação da UF, corresponde ao valor no campo 14 (VL_UNIT_ICMS_ST_ESTOQUE_CONV_SAIDA) */
                            nVlrUComIC := nVlMICMSST
                        EndIf    
                        nVlrUComFC  := 0
                        nVlrComIC   := Round(nVlrUComIC * nQtdade, nDecimal)
                        nVlrComFC   := Round(nVlrUComFC * nQtdade, nDecimal)

                        If cCodEnquad  == '02'
                            cCodEnquad  := '11' //--Devolução de Saída - Fato Gerador Presumido não Realizado - Estorno de Ressarcimento---//
                        ElseIf cCodEnquad  == '03'
                            cCodEnquad  := '12' //--Devolução de Saída - Saída amparada por isenção ou não-incidência - Estorno de Ressarcimento---//
                        ElseIf cCodEnquad  == '04'
                            cCodEnquad  := '13' //--Devolução de Saída - Saída destinada a outro Estado - Estorno de Ressarcimento---//
                        EndIf

                    EndIf

                Else
                    cCodEnquad  := '08' //--Devolução de Saída Não Ensejadora de Ressarcimento---//
                EndIf

                //---Compõe valores para atualização de Saldos em Estoque---//
                nVlrICMS   := Round(nVlMICMSOp * nQtdade, nDecimal)
                nVlrICMSST := Round(nVlMICMSST * nQtdade, nDecimal)
                nVlrBICMST := Round(nVlMBCICST * nQtdade, nDecimal)
                nVlrFec    := Round(nVlMFECP   * nQtdade, nDecimal)

                //---Calcula Valor do Crédito do ICMS OP, nas hipóteses em que há direito a esse crédito---//
                If cCodEnquad == '13'
                    nVlrCICOP := nVlrICMS
                EndIf

            Else //---Apuração do movimento original não encontrada (tabela CII)---//
                lDocOriApu := .F.
            EndIf

        EndIf

        //---Verifica Enquadramento da Operação de Saída (Regra de Apuração)---//
        If !Self:ValRegCod(cCodEnquad) .Or. cCFOPRess == '2' .Or. !lDocOriApu

            //---Desfaz os cálculos realizados para o movimento---//
            nVUICMOpCF  := 0
            nVUICMOpFG  := 0
            nVlrResIC   := 0
            nVlrResFC   := 0
            nVlrUResIC  := 0
            nVlrUResFC  := 0
            nVlrComIC   := 0
            nVlrComFC   := 0
            nVlrUComIC  := 0
            nVlrUComFC  := 0
            nVlrCICOP   := 0

            //---Recurera o Valor Médio Atual do Estoque. Caso o estoque esteja zerado, utilizará a última média diferente de zero---//
            If Self:oSaldoProd:GetSldUICM() = 0 .Or. Self:oSaldoProd:GetSldUIST() = 0 .Or. Self:oSaldoProd:GetSldUBST() = 0
                nVlMICMSOp := Self:oSaldoProd:GetUSD0ICM()
                nVlMICMSST := Self:oSaldoProd:GetUSD0IST()
                nVlMBCICST := Self:oSaldoProd:GetUSD0BST()
                nVlMFECP   := Self:oSaldoProd:GetUSD0FCP()
            Else
                nVlMICMSOp := Self:oSaldoProd:GetSldUICM()
                nVlMICMSST := Self:oSaldoProd:GetSldUIST()
                nVlMBCICST := Self:oSaldoProd:GetSldUBST()
                nVlMFECP   := Self:oSaldoProd:GetSldUFCP()
            EndIf

            //---Recompõe valores para atualização de Saldos em Estoque a partir da Média Atual do Estoque (para não alterar médias)---//
            nVlrICMS   := Round(nVlMICMSOp * nQtdade, nDecimal)
            nVlrICMSST := Round(nVlMICMSST * nQtdade, nDecimal)
            nVlrBICMST := Round(nVlMBCICST * nQtdade, nDecimal)
            nVlrFec    := Round(nVlMFECP   * nQtdade, nDecimal)

            //---Insere flag no movimento para que o registro C185/C181 não seja escriturado, uma vez que: A regra de apuração não tem código 5.7 correspondente [OU] o CFOP está ajustado para não realizar cálculo de ressasrcimento [OU] para o movimento de devolução a apuração do movimento original não foi encontrada---//
            cGeraSPED := '2'

        EndIf

        //---Atualiza o saldo do produto---//
        Self:oSaldoProd:AtuSaldo(cTipoMov,cCodProd,nQtdade,nVlrICMS,nVlrICMSST,nVlrBICMST,nVlrFec,cCodEnquad)

    EndIf

    //---Carrega os valores apurados no atributo oMovimApur---//
    Self:oMovimApur:ClearMovAp()
    Self:oMovimApur:SetQtdade(Self:oSaldoProd:GetQtdade())
    Self:oMovimApur:SetVUnit(nVlrUnit)
    Self:oMovimApur:SetUICMSOp(nVlUICMSOp)
    Self:oMovimApur:SetUBICMST(nVlUBICMST)
    Self:oMovimApur:SetUICMSST(nVlUICMSST)
    Self:oMovimApur:SetUFECP(nVlUFECP)
    Self:oMovimApur:SetEnquad(cCodEnquad)
    Self:oMovimApur:SetICMOpCF(nVUICMOpCF)
    Self:oMovimApur:SetICMOpFG(nVUICMOpFG)
    Self:oMovimApur:SetResIC(nVlrResIC)
    Self:oMovimApur:SetResFC(nVlrResFC)
    Self:oMovimApur:SetUResIC(nVlrUResIC)
    Self:oMovimApur:SetUResFC(nVlrUResFC)
    Self:oMovimApur:SetComIC(nVlrComIC)
    Self:oMovimApur:SetComFC(nVlrComFC)
    Self:oMovimApur:SetUComIC(nVlrUComIC)
    Self:oMovimApur:SetUComFC(nVlrUComFC)
    Self:oMovimApur:SetMICMSOp(nVlMICMSOp)
    Self:oMovimApur:SetMBCICST(nVlMBCICST)
    Self:oMovimApur:SetMICMSST(nVlMICMSST)
    Self:oMovimApur:SetMFECP(nVlMFECP)
    Self:oMovimApur:SetCrICOP(nVlrCICOP)
    Self:oMovimApur:SetGSPED(cGeraSPED)
    Self:oMovimApur:SetFrete(nVlrFrete)
    Self:oMovimApur:SetSeguro(nVlrSeguro)
    Self:oMovimApur:SetDespesa(nVlrDesp)
    Self:oMovimApur:SetDescont(nVlrDesc)

    //---Atualiza o atributo totalizador da apuração---//
    If cGeraSPED == '1'
        nPos := Ascan(Self:aTotApur,{|a|a[1] == cCodEnquad})
        If nPos > 0
            Self:aTotApur[nPos][2] += Self:oMovimApur:GetResIC()
            Self:aTotApur[nPos][3] += Self:oMovimApur:GetComIC()
            Self:aTotApur[nPos][4] += Self:oMovimApur:GetCrICOP()
            Self:aTotApur[nPos][5] += Self:oMovimApur:GetResFC()
            Self:aTotApur[nPos][6] += Self:oMovimApur:GetComFC()
            Self:aTotApur[nPos][7] := .T.
        EndIf
    EndIf
    //---FIM Atualiza o atributo totalizador da apuração---//

    //---FIM Carrega objeto de retorno com valores apurados para o movimento---//

Return 


//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} ValRegCod()
  
Método responsável por verificar se a regra de apuração possui relação com código da tabela 5.7.
Movimentos classificados com tais regras não terão cálculo de ressarcimento/complemento.

@author Ulisses.Oliveira
@since 21/01/2021
@version 1.0
/*/
//--------------------------------------------------------------------------------------------------
Method ValRegCod(cRegra) Class FISA302APURACAO
    Local aRegSemCod := Self:GetRSemCod()
    Local nPos       := 0
    Local lRetorno   := .T.

    If !Empty(cRegra) .And. Len(aRegSemCod) > 0
        nPos := Ascan(aRegSemCod,cRegra)
        If nPos > 0
            lRetorno := .F.
        EndIf
    EndIf

Return lRetorno


//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} VlUF11C185()
  
Método que define se a UF exige o preenchimento dos campos:
Registro C185 Campo 11 VL_UNIT_ICMS_OP_CONV
Registro C181 Campo 17 VL_UNIT_ICMS_OP_CONV_SAIDA

 ***ATENÇÃO***: OBSERVAR CRITÉRIO DE CADA UF

@author Ulisses.Oliveira
@since 11/02/2021
@version 1.0
/*/
//--------------------------------------------------------------------------------------------------
Method VlUF11C185() Class FISA302APURACAO
    Local cUF       := Self:GetUF()
    Local lUF11C185 := .F.
    Local cUF11C185 := 'RS|' //---UFs que exigem o preenchimento do Campo 11-VL_UNIT_ICMS_OP_CONV do Registro C185 / Campo 17-VL_UNIT_ICMS_OP_CONV_SAIDA do Registro C181. Deve ser adotado mesmo critério no SPED Fiscal---//

    If cUF $ cUF11C185
        lUF11C185 := .T.
    EndIf

    Self:Set11C185(lUF11C185) 
Return


//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} Method ClearApur()
  
Método que limpa os valores do objeto de apuração.

@author Ulisses.Oliveira
@since 11/02/2021
@version 1.0
/*/
//--------------------------------------------------------------------------------------------------
Method ClearApur() Class FISA302APURACAO
    Self:cIdApur    := ''
    Self:cFilApur   := ''
    Self:cAnoMes    := ''
    Self:aTotApur   := {}
    Self:aRegSemCod := {}
    Self:cUF        := ''
    Self:lUF11C185  := .F.
    Self:oSaldoProd := Nil
    Self:oMovimento := Nil
    Self:oMovimApur := Nil
Return


//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} Getters e Setters

@author Rafael.Soliveira
@since 12/11/2018
@version 1.0
/*/
//--------------------------------------------------------------------------------------------------
Method GetIdApur() Class FISA302APURACAO
Return Self:cIdApur

Method GetAnoMes() Class FISA302APURACAO
Return Self:cAnoMes

Method GetRSemCod() Class FISA302APURACAO
Return Self:aRegSemCod

Method GetUF() Class FISA302APURACAO
Return Self:cUF

Method Get11C185() Class FISA302APURACAO
Return Self:lUF11C185

Method Set11C185(lUF11C185) Class FISA302APURACAO
    Self:lUF11C185 :=lUF11C185
Return


//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} Classe FISA302SALDOPRODUTO

Classe responsável por controlar saldos físicos e financeiros do produto analisado.
  
@author Rafael.Soliveira
@since 08/11/2019
@version 1.0
/*/
//--------------------------------------------------------------------------------------------------
CLASS FISA302SALDOPRODUTO FROM LongClassName

Data cCodProd    As Character //---Código do Produto                                                ---//
Data nQtdade     As Numeric   //---Saldo Físico do Produto                                          ---//
Data nVlSldTICM  As Numeric   //---Valor Total    do Saldo - ICMS OP                                ---//
Data nVlSldUICM  As Numeric   //---Valor Unitário do Saldo - ICMS OP                                ---//
Data nUltSD0ICM  As Numeric   //---Valor do Último Unitário do Saldo Diferente de Zero - ICMS OP    ---//
Data nVlSldHICM  As Numeric   //---Valor Unitário do Saldo Inicial - H030 - ICMS OP                 ---//
Data nVlSldTIST  As Numeric   //---Valor Total    do Saldo - ICMS ST                                ---//
Data nVlSldUIST  As Numeric   //---Valor Unitário do Saldo - ICMS ST                                ---//
Data nUltSD0IST  As Numeric   //---Valor do Último Unitário do Saldo Diferente de Zero - ICMS ST    ---//
Data nVlSldHIST  As Numeric   //---Valor Unitário do Saldo Inicial - H030 - ICMS ST                 ---//
Data nVlSldTBST  As Numeric   //---Valor Total    do Saldo - BC ICMS ST                             ---//
Data nVlSldUBST  As Numeric   //---Valor Unitário do Saldo - BC ICMS ST                             ---//
Data nUltSD0BST  As Numeric   //---Valor do Último Unitário do Saldo Diferente de Zero - BC ICMS ST ---//
Data nVlSldHBST  As Numeric   //---Valor Unitário do Saldo Inicial - H030 - BC ICMS ST              ---//
Data nVlSldTFCP  As Numeric   //---Valor Total    do Saldo - FECP                                   ---//
Data nVlSldUFCP  As Numeric   //---Valor Unitário do Saldo - FECP                                   ---//
Data nUltSD0FCP  As Numeric   //---Valor do Último Unitário do Saldo Diferente de Zero - FECP       ---//
Data nVlSldHFCP  As Numeric   //---Valor Unitário do Saldo Inicial - H030 - FECP                    ---//
Data nOrdMovAtu  As Numeric   //---Ordenação do Movimento Atual do Produto                          ---//

Method New() CONSTRUCTOR
Method AtuSaldo(cTipoMov,cCodProd,nQtdade,nVlrICMOP,nVlrICMST,nVlrBCST,nVlrFCP,cCodEnquad)

//---Getters e Setters Gerais---//
Method SetCodProd(cCodProd)
Method SetQtdade(nQtdade)
Method SetOrdMov(nOrdMovAtu)
Method GetCodProd()
Method GetQtdade()
Method GetOrdMov()

//---Getters e Setters ICMS OP---//
Method SetSldTICM(nVlSldTICM)
Method SetSldUICM(nVlSldUICM)
Method SetUSD0ICM(nUltSD0ICM)
Method SetSldHICM(nVlSldHICM)
Method GetSldTICM()
Method GetSldUICM()
Method GetUSD0ICM()
Method GetSldHICM()

//---Getters e Setters ICMS ST---//
Method SetSldTIST(nVlSldTIST)
Method SetSldUIST(nVlSldUIST)
Method SetUSD0IST(nUltSD0IST)
Method SetSldHIST(nVlSldHIST)
Method GetSldTIST()
Method GetSldUIST()
Method GetUSD0IST()
Method GetSldHIST()

//---Getters e Setters BC ICMS ST---//
Method SetSldTBST(nVlSldTBST)
Method SetSldUBST(nVlSldUBST)
Method SetUSD0BST(nUltSD0BST)
Method SetSldHBST(nVlSldHBST)
Method GetSldTBST()
Method GetSldUBST()
Method GetUSD0BST()
Method GetSldHBST()

//---Getters e Setters FECP---//
Method SetSldTFCP(nVlSldTFCP)
Method SetSldUFCP(nVlSldUFCP)
Method SetUSD0FCP(nUltSD0FCP)
Method SetSldHFCP(nVlSldHFCP)
Method GetSldTFCP()
Method GetSldUFCP()
Method GetUSD0FCP()
Method GetSldHFCP()

ENDCLASS


//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} New()
  
Método construtor da Classe FISA302SALDOPRODUTO

@author Rafael.Soliveira
@since 08/11/2019
@version 1.0
/*/
//--------------------------------------------------------------------------------------------------
Method New() Class FISA302SALDOPRODUTO
    Self:cCodProd    := ""
	Self:nQtdade     := 0
	Self:nVlSldTICM  := 0
    Self:nVlSldUICM  := 0
    Self:nUltSD0ICM  := 0
    Self:nVlSldTIST  := 0
    Self:nVlSldUIST  := 0
    Self:nUltSD0IST  := 0
    Self:nVlSldTBST  := 0
    Self:nVlSldUBST  := 0
    Self:nUltSD0BST  := 0
    Self:nVlSldTFCP  := 0
    Self:nVlSldUFCP  := 0
    Self:nUltSD0FCP  := 0
    Self:nOrdMovAtu  := 0
Return Self


//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} AtuSaldo()
  
Método que atualiza o saldo atual do produto analisado. É disparado a cada movimento analisado.

@author Rafael.Soliveira
@since 08/11/2019
@version 1.0
/*/
//--------------------------------------------------------------------------------------------------
Method AtuSaldo(cTipoMov,cCodProd,nQtdade,nVlrICMOP,nVlrICMST,nVlrBCST,nVlrFCP,cCodEnquad) Class FISA302SALDOPRODUTO
    Local cProdAtual    := Self:GetCodProd()
    Local nQtdAtual     := Self:GetQtdade()
    Local nTtAtualIC    := Self:GetSldTICM() //---Valor Total do Saldo - ICMS OP
    Local nTtAtualST    := Self:GetSldTIST() //---Valor Total do Saldo - ICMS ST
    Local nTtAtualBC    := Self:GetSldTBST() //---Valor Total do Saldo - BC ICMS ST
    Local nTtAtualFC    := Self:GetSldTFCP() //---Valor Total do Saldo - FECP
    Local nUniAtuIC     := 0                 //---Valor Médio Unitário Atual - ICMS OP em estoque
    Local nUniAtuST  	:= 0                 //---Valor Médio Unitário Atual - ICMS ST em estoque
    Local nUniAtuBC  	:= 0                 //---Valor Médio Unitário Atual - BC ICMS ST
    Local nUniAtuFC  	:= 0                 //---Valor Médio Unitário Atual - FECP em estoque   

    If cCodProd == cProdAtual
        If cTipoMov=='E'
            nQtdAtual   += nQtdade
            nTtAtualIC  += nVlrICMOP
            nTtAtualST  += nVlrICMST
            nTtAtualBC  += nVlrBCST
            nTtAtualFC  += nVlrFCP
        Else
            nQtdAtual   -= nQtdade
            nTtAtualIC  -= nVlrICMOP
            nTtAtualST  -= nVlrICMST
            nTtAtualBC  -= nVlrBCST
            nTtAtualFC  -= nVlrFCP
        EndIf
        If nQtdAtual > 0
            If  cTipoMov=="E"
                nUniAtuIC   := Round(nTtAtualIC/nQtdAtual,6)
                nUniAtuST   := Round(nTtAtualST/nQtdAtual,6)
                nUniAtuBC   := Round(nTtAtualBC/nQtdAtual,6)
                nUniAtuFC   := Round(nTtAtualFC/nQtdAtual,6)

            ElseIf cTipoMov=="S" .and. cCodEnquad == '07'        // Movimento de Saída - reprocessa devolução para obter média unitária
                nUniAtuIC   := Round(nTtAtualIC/nQtdAtual,6)
                nUniAtuST   := Round(nTtAtualST/nQtdAtual,6)
                nUniAtuBC   := Round(nTtAtualBC/nQtdAtual,6)
                nUniAtuFC   := Round(nTtAtualFC/nQtdAtual,6)

            Else
                nUniAtuIC   := Round(nVlrICMOP /nQtdade  ,6)
                nUniAtuST   := Round(nVlrICMST /nQtdade  ,6)
                nUniAtuBC   := Round(nVlrBCST  /nQtdade  ,6)
                nUniAtuFC   := Round(nVlrFCP   /nQtdade  ,6)
            Endif
        Else
            nUniAtuIC   := 0
            nUniAtuST   := 0
            nUniAtuBC   := 0
            nUniAtuFC   := 0
            nTtAtualIC  := 0
            nTtAtualST  := 0
            nTtAtualBC  := 0
            nTtAtualFC  := 0
        EndIf

        If nUniAtuIC>0
            Self:SetUSD0ICM(nUniAtuIC)
        EndIf
        If nUniAtuST>0
            Self:SetUSD0IST(nUniAtuST)
        EndIf
        If nUniAtuBC>0
            Self:SetUSD0BST(nUniAtuBC)
        EndIf
        If nUniAtuFC>0
            Self:SetUSD0FCP(nUniAtuFC)
        EndIf

        Self:SetQtdade(nQtdAtual)
        Self:SetOrdMov(Self:GetOrdMov()+1)

        //---ICMS OP---//
        Self:SetSldTICM(nTtAtualIC) 
        Self:SetSldUICM(nUniAtuIC)

        //--ICMS ST---//
        Self:SetSldTIST(nTtAtualST)
        Self:SetSldUIST(nUniAtuST)

        //---BC ICMS ST---//
        Self:SetSldTBST(nTtAtualBC)
        Self:SetSldUBST(nUniAtuBC)

        //---FECP---//
        Self:SetSldTFCP(nTtAtualFC)
        Self:SetSldUFCP(nUniAtuFC)
    EndIf
Return


//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} Getters e Setters

@author Rafael.Soliveira
@since 08/11/2019
@version 1.0
/*/
//--------------------------------------------------------------------------------------------------
Method SetCodProd(cCodProd) Class FISA302SALDOPRODUTO
    Self:cCodProd := cCodProd
Return

Method SetQtdade(nQtdade) Class FISA302SALDOPRODUTO
    Self:nQtdade := nQtdade
Return

Method SetOrdMov(nOrdMovAtu) Class FISA302SALDOPRODUTO
    Self:nOrdMovAtu := nOrdMovAtu
Return

Method GetCodProd() Class FISA302SALDOPRODUTO
Return Self:cCodProd

Method GetQtdade() Class FISA302SALDOPRODUTO
Return Self:nQtdade

Method GetOrdMov() Class FISA302SALDOPRODUTO
Return Self:nOrdMovAtu

//---Getters e Setters ICMS OP---//
Method SetSldTICM(nVlSldTICM) Class FISA302SALDOPRODUTO
    Self:nVlSldTICM := nVlSldTICM
Return

Method SetSldUICM(nVlSldUICM) Class FISA302SALDOPRODUTO
    Self:nVlSldUICM := nVlSldUICM
Return

Method SetUSD0ICM(nUltSD0ICM) Class FISA302SALDOPRODUTO
    Self:nUltSD0ICM := nUltSD0ICM
Return

Method SetSldHICM(nVlSldHICM) Class FISA302SALDOPRODUTO
    Self:nVlSldHICM := nVlSldHICM
Return

Method GetSldTICM() Class FISA302SALDOPRODUTO
Return Self:nVlSldTICM

Method GetSldUICM() Class FISA302SALDOPRODUTO
Return Self:nVlSldUICM

Method GetUSD0ICM() Class FISA302SALDOPRODUTO
Return Self:nUltSD0ICM

Method GetSldHICM() Class FISA302SALDOPRODUTO
Return Self:nVlSldHICM

//---Getters e Setters ICMS ST---//
Method SetSldTIST(nVlSldTIST) Class FISA302SALDOPRODUTO
    Self:nVlSldTIST := nVlSldTIST
Return

Method SetSldUIST(nVlSldUIST) Class FISA302SALDOPRODUTO
    Self:nVlSldUIST := nVlSldUIST
Return

Method SetUSD0IST(nUltSD0IST) Class FISA302SALDOPRODUTO
    Self:nUltSD0IST := nUltSD0IST
Return

Method SetSldHIST(nVlSldHIST) Class FISA302SALDOPRODUTO
    Self:nVlSldHIST := nVlSldHIST
Return

Method GetSldTIST() Class FISA302SALDOPRODUTO
Return Self:nVlSldTIST

Method GetSldUIST() Class FISA302SALDOPRODUTO
Return Self:nVlSldUIST

Method GetUSD0IST() Class FISA302SALDOPRODUTO
Return Self:nUltSD0IST

Method GetSldHIST() Class FISA302SALDOPRODUTO
Return Self:nVlSldHIST

//---Getters e Setters BC ICMS ST---//
Method SetSldTBST(nVlSldTBST) Class FISA302SALDOPRODUTO
    Self:nVlSldTBST := nVlSldTBST
Return

Method SetSldUBST(nVlSldUBST) Class FISA302SALDOPRODUTO
    Self:nVlSldUBST := nVlSldUBST
Return

Method SetUSD0BST(nUltSD0BST) Class FISA302SALDOPRODUTO
    Self:nUltSD0BST := nUltSD0BST
Return

Method SetSldHBST(nVlSldHBST) Class FISA302SALDOPRODUTO
    Self:nVlSldHBST := nVlSldHBST
Return

Method GetSldTBST() Class FISA302SALDOPRODUTO
Return Self:nVlSldTBST

Method GetSldUBST() Class FISA302SALDOPRODUTO
Return Self:nVlSldUBST

Method GetUSD0BST() Class FISA302SALDOPRODUTO
Return Self:nUltSD0BST

Method GetSldHBST() Class FISA302SALDOPRODUTO
Return Self:nVlSldHBST

//---Getters e Setters FECP---//
Method SetSldTFCP(nVlSldTFCP) Class FISA302SALDOPRODUTO
    Self:nVlSldTFCP := nVlSldTFCP
Return

Method SetSldUFCP(nVlSldUFCP) Class FISA302SALDOPRODUTO
    Self:nVlSldUFCP := nVlSldUFCP
Return

Method SetUSD0FCP(nUltSD0FCP) Class FISA302SALDOPRODUTO
    Self:nUltSD0FCP := nUltSD0FCP
Return

Method SetSldHFCP(nVlSldHFCP) Class FISA302SALDOPRODUTO
    Self:nVlSldHFCP := nVlSldHFCP
Return

Method GetSldTFCP() Class FISA302SALDOPRODUTO
Return Self:nVlSldTFCP

Method GetSldUFCP() Class FISA302SALDOPRODUTO
Return Self:nVlSldUFCP

Method GetUSD0FCP() Class FISA302SALDOPRODUTO
Return Self:nUltSD0FCP

Method GetSldHFCP() Class FISA302SALDOPRODUTO
Return Self:nVlSldHFCP


//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} Classe FISA302MOVIMENTO

Classe responsável por controlar todas as colunas da Ficha 3, além de definir: 
Enquadramento Legal / Valor de Confronto / Valor a Ressarcir ou Complementar 
  
@author Rafael.Soliveira
@since 23/10/2018
@version 1.0
/*/
//--------------------------------------------------------------------------------------------------
CLASS FISA302MOVIMENTO FROM LongClassName

Data dDataMov     As Date      //---Data do Movimento
Data cTipoMov     As Character //---Tipo do Movimento (E-Entrada / S-Saída)
Data cTipoDoc     As Character //---Tipo do Documento (Normal / Devolução / Complemento)
Data cCodProd     As Character //---Código do Produto
Data cTipoPart    As Character //---Tipo do Participante (Cliente Final / Revendedor)
Data nAliqInt     As Numeric   //---Alíquota Interna do Produto
Data cCFOP        As Character //---CFOP
Data cCST         As Character //---CST ICMS
Data cFGerNReal   As Character //---Indica se a operação (CFOP) deve ser enquadrada como 2-Fato Gerador não realizado
Data cCFOPRess    As Character //---Indica se a operação (CFOP) deve ser considerada para cálculo de Ressarcimento
Data nQtdade      As Numeric   //---Quantidade
Data nVlrUnit     As Numeric   //---Valor Unitário do Item da Nota Fiscal
Data nVlrTotPrd   As Numeric   //---Valor Total do Produto
Data nVlrFrete    As Numeric   //---Valor do Frete
Data nVlrSeguro   As Numeric   //---Valor do Seguro
Data nVlrDesp     As Numeric   //---Valor das Despesas
Data nVlrDesc     As Numeric   //---Valor do Desconto
Data nVlrTotNf    As Numeric   //---Valor Total da Nota Fiscal
Data nVlrBICMS    As Numeric   //---Base de Cálculo do ICMS
Data nVlrICMS     As Numeric   //---Valor do ICMS
Data nVlrBICMST   As Numeric   //---Valor da Base de Cálculo do ICMS-ST
Data nVlrICMSST   As Numeric   //---Valor do ICMS-ST
Data nVlrBCFec    As Numeric   //---Base do FECP ST
Data nAliqFec     As Numeric   //---Alíquota do FECP ST
Data nVlrFec      As Numeric   //---Alíquota do FECP ST
Data nVlrICMEfe   As Numeric   //---Valor do ICMS Efetivo na Saída
Data cRespRet     As Character //---Responsável pela retenção do ICMS-ST (1 – Remetente Direto / 2 – Remetente Indireto / 3 – Próprio declarante )---//
Data dDtMovOri    As Date      //---Data do Movimento Original, em casos de movimentos de devolução
Data nVlrEfeOri   As Numeric   //---Valor do ICMS Efetivo na Saída Original, em casos de movimentos de devolução
Data aDocOriApu   As Array     //---Valores apurados para o Documento Fiscal Original, em casos de movimentos de devolução
Data cInscricao   As Character //---Incrição estadual do Participante 
Data cContrib     As Character //---Contribuinte do ICMS (1 - Sim / 2 - Não)
Data lEhContrib   As Logical   //---Contribuinte do ICMS (.T. - Sim / .F. - Não)
Data cUF          As Character //---Uf do MV_ESTADO para o Enquadramento Legal da operção de saída
Data lGerrespre   As Logical   //---Restituição sempre que houver um fato presumido não realizado em qualquer operação, seja interna ou interestadual

Method New(cUF) CONSTRUCTOR
Method EnquadMov()
Method DefBaseICM()
Method ClearMov()
Method DefICMSOP(cUF,cCodEnquad,nVlMICMSOp)
Method EhContrib()

//---Getters e Setters---//
Method SetDataMov(dDataMov)
Method SetTipoMov(cTipoMov)
Method SetTipoDoc(cTipoDoc)
Method SetCodProd(cCodProd)
Method SetTipoPar(cTipoPart)
Method SetAliqInt(nAliqInt)
Method SetCFOP(cCFOP)
Method SetCST(cCST)
Method SetFGerNR(cFGerNReal)
Method SetCFOPRes(cCFOPRess)
Method SetQtdade(nQtdade)
Method SetVUnit(nVlrUnit)
Method SetTotPrd(nVlrTotPrd)
Method SetFrete(nVlrFrete)
Method SetSeguro(nVlrSeguro)
Method SetDespesa(nVlrDesp)
Method SetDescont(nVlrDesc)
Method SetTotNf(nVlrTotNf)
Method SetBICMS(nVlrBICMS)
Method SetVICMS(nVlrICMS)
Method SetBICMST(nVlrBICMST)
Method SetVICMSST(nVlrICMSST)
Method SetBFec(nVlrBCFec)
Method SetAliqFec(nAliqFec)
Method SetVFec(nVlrFec)
Method SetICMSEfe(nVlrICMEfe)
Method SetRespRet(cRespRet)
Method SetDtMvOri(dDtMovOri)
Method SetVEfeOri(nVlrEfeOri)
Method SetDocOrig(aDocOriApu)
Method SetInscric(cInscricao)
Method SetContrib(cContrib)
Method SetEhContrib(lEhContrib)
Method GetDataMov()
Method GetTipoMov()
Method GetTipoDoc()
Method GetCodProd()
Method GetTipoPar()
Method GetAliqInt()
Method GetCFOP()
Method GetCST()
Method GetFGerNR()
Method GetCFOPRes()
Method GetQtdade()
Method GetVUnit()
Method GetTotPrd()
Method GetFrete()
Method GetSeguro()
Method GetDespesa()
Method GetDescont()
Method GetTotNf()
Method GetBICMS()
Method GetVICMS()
Method GetBICMST()
Method GetVICMSST()
Method GetBFec()
Method GetAliqFec()
Method GetVFec()
Method GetICMSEfe()
Method GetRespRet()
Method GetDtMvOri()
Method GetVEfeOri()
Method GetDocOrig()
Method GetInscric()
Method GetContrib()
Method GetEhContrib()
Method GetlGerrespre()

ENDCLASS


//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} New()
  
Método construtor da Classe FISA302MOVIMENTO

@author Rafael.Soliveira
@since 23/10/2018
@version 1.0
/*/
//--------------------------------------------------------------------------------------------------
Method New(cUF) Class FISA302MOVIMENTO
    Self:ClearMov()
    Self:cUF := cUF
    Self:lGerrespre :=.T.
Return Self


//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} EnquadMov()
  
Método que define o Enquadramento Legal da operção de saída, retornando:
0-Saída para comercialização subsequente e todas demais saídas escrituradas no controle de estoque não elencadas nesta tabela. 
1-Saída a consumidor ou usuário final, conforme artigo 269 inciso I do RICMS/00. 
2-Fato gerador não realizado, conforme artigo 269 inciso II do RICMS/00. 
3-Saída ou saída subsequente amparada com isenção ou não incidência, conforme artigo 269 inciso III do RICMS/00.
4-Saída para outro estado, conforme artigo 269 inciso IV do RICMS/00.

"Nos casos de mercadoria recebida para comercialização vier a perecer, deteriorar-se ou for objeto de roubo, furto ou extravio, deverá emitir 
 nota fiscal de saída para baixa do estoque, sem destaque dos impostos com o CFOP 5.927. Deverá utilizar o código de enquadramento 2. 
 Preferencialmente deverá emitir uma única nota fiscal por período de referência, com todas as baixas ocorridas no período.""

@author Rafael.Soliveira
@since 23/10/2018
@version 1.0
/*/
//--------------------------------------------------------------------------------------------------
Method EnquadMov() Class FISA302MOVIMENTO
    Local cCFOP      := Self:GetCFOP()
    Local cCST       := Self:GetCST()
    Local cFGerNReal := Self:GetFGerNR()
    Local cTipoPart  := Self:GetTipoPar()
    Local cTipoMov   := Self:GetTipoMov()
    Local cUF        := Self:cUF
    Local cRetorno   := '00'
   

    If (cTipoMov == 'S' .And. Left(cCFOP,1) == '6') .Or. (cTipoMov == 'E' .And. Left(cCFOP,1) == '2')
        If (cCST $ '30/40/41') 
            cRetorno := '03'      //--- 3-Saída ou saída subsequente com isenção ou não incidência ---//
        Else
            cRetorno := '04'      //--- 4-Saída para outro Estado ---//
            If (cUF == "MG" .And. cCST == "00" .And. cTipoPart == "F")
               Self:lGerrespre :=.F.
            EndIf
        EndIf
    Else
        If cFGerNReal == '1'
            cRetorno := '02'      //--- 2-Fato Gerador não realizado ---//
        ElseIf cTipoPart == 'F'
            cRetorno := '01'      //--- 1-Consumidor ou Usuário Final ---//
        ElseIf cCST $ '30/40/41'
            cRetorno := '03'      //--- 3-Saída ou saída subsequente com isenção ou não incidência ---//
        EndIf
    EndIf
    
Return cRetorno


//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} DefBaseICM()
  
Método que define a correspondente Base de ICMS da operação.

@author Rafael.Soliveira
@since 27/11/2018
@version 1.0
/*/
//--------------------------------------------------------------------------------------------------
Method DefBaseICM() Class FISA302MOVIMENTO
    Local nRetorno   := 0
    Local nVlrTotPrd := Self:GetTotPrd()
    Local nVlrFrete  := Self:GetFrete()
    Local nVlrSeguro := Self:GetSeguro()
    Local nVlrDesp   := Self:GetDespesa()
    Local nVlrDesc   := Self:GetDescont()

    nRetorno := nVlrTotPrd + nVlrFrete + nVlrSeguro + nVlrDesp - nVlrDesc

Return nRetorno


//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} ClearMov
  
Método que limpa os valores do movimento.

@author Rafael.Soliveira
@since 12/11/2018
@version 1.0
/*/
//--------------------------------------------------------------------------------------------------
Method ClearMov() Class FISA302MOVIMENTO
    Self:dDataMov   := CToD("  /  /    ")
    Self:cTipoMov   := ""
    Self:cTipoDoc   := ""
    Self:cCodProd   := ""
    Self:cTipoPart  := ""
    Self:nAliqInt   := 0
    Self:cCFOP      := ""
    Self:cCST       := ""
    Self:cFGerNReal := ""
    Self:cCFOPRess  := ""
    Self:nQtdade    := 0
    Self:nVlrUnit   := 0
    Self:nVlrTotPrd := 0
    Self:nVlrFrete  := 0
    Self:nVlrSeguro := 0
    Self:nVlrDesp   := 0
    Self:nVlrDesc   := 0
    Self:nVlrTotNf  := 0
    Self:nVlrBICMS  := 0
    Self:nVlrICMS   := 0
    Self:nVlrBICMST := 0
    Self:nVlrICMSST := 0
    Self:nVlrBCFec  := 0
    Self:nAliqFec   := 0
    Self:nVlrFec    := 0
    Self:nVlrICMEfe := 0
    Self:cRespRet   := ""
    Self:dDtMovOri  := CToD("  /  /    ")
    Self:nVlrEfeOri := 0
    Self:aDocOriApu := {}
    Self:cInscricao := ""
    Self:cContrib   := ""
    Self:lEhContrib := .T.
    Self:lGerrespre := .T.

Return


//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} DefICMSOP()
  
Método que define o Valor ICMS OP entrada - Fato Gerador Presumido não realizado, que alimentará os
campos:
Registro C185 Campo 11 VL_UNIT_ICMS_OP_CONV
Registro C181 Campo 17 VL_UNIT_ICMS_OP_CONV_SAIDA

 ***ATENÇÃO***: OBSERVAR CRITÉRIO DE CADA UF

@author Ulisses.Oliveira
@since 11/02/2021
@version 1.0
/*/
//--------------------------------------------------------------------------------------------------
Method DefICMSOP(cUF,cCodEnquad,nVlMICMSOp) Class FISA302MOVIMENTO
    Local nRetorno := 0

    If cUF == 'RS'
        If cCodEnquad == '02'
            nRetorno := nVlMICMSOp
        Else
            nRetorno := 0
        End
    EndIf

Return nRetorno


//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} Getters e Setters

@author Rafael.Soliveira
@since 23/10/2018
@version 1.0
/*/
//--------------------------------------------------------------------------------------------------
Method SetDataMov(dDataMov) Class FISA302MOVIMENTO
    Self:dDataMov := dDataMov
Return

Method SetTipoMov(cTipoMov) Class FISA302MOVIMENTO
    Self:cTipoMov := cTipoMov
Return

Method SetTipoDoc(cTipoDoc) Class FISA302MOVIMENTO
    Self:cTipoDoc := cTipoDoc
Return

Method SetCodProd(cCodProd) Class FISA302MOVIMENTO
    Self:cCodProd := cCodProd
Return

Method SetTipoPar(cTipoPart) Class FISA302MOVIMENTO
    Self:cTipoPart := cTipoPart
Return

Method SetAliqInt(nAliqInt) Class FISA302MOVIMENTO
    Self:nAliqInt := nAliqInt
Return

Method SetCFOP(cCFOP) Class FISA302MOVIMENTO
    Self:cCFOP := cCFOP
Return

Method SetCST(cCST) Class FISA302MOVIMENTO
    Self:cCST := cCST
Return

Method SetFGerNR(cFGerNReal) Class FISA302MOVIMENTO
    Self:cFGerNReal := cFGerNReal
Return

Method SetCFOPRes(cCFOPRess) Class FISA302MOVIMENTO
    Self:cCFOPRess := cCFOPRess
Return

Method SetQtdade(nQtdade) Class FISA302MOVIMENTO
    Self:nQtdade := nQtdade
Return

Method SetVUnit(nVlrUnit) Class FISA302MOVIMENTO
    Self:nVlrUnit := nVlrUnit
Return

Method SetTotPrd(nVlrTotPrd) Class FISA302MOVIMENTO
    Self:nVlrTotPrd := nVlrTotPrd
Return

Method SetFrete(nVlrFrete) Class FISA302MOVIMENTO
    Self:nVlrFrete := nVlrFrete
Return

Method SetSeguro(nVlrSeguro) Class FISA302MOVIMENTO
    Self:nVlrSeguro := nVlrSeguro
Return

Method SetDespesa(nVlrDesp) Class FISA302MOVIMENTO
    Self:nVlrDesp := nVlrDesp
Return

Method SetDescont(nVlrDesc) Class FISA302MOVIMENTO
    Self:nVlrDesc := nVlrDesc
Return

Method SetTotNf(nVlrTotNf) Class FISA302MOVIMENTO
    Self:nVlrTotNf := nVlrTotNf
Return

Method SetBICMS(nVlrBICMS) Class FISA302MOVIMENTO
    Self:nVlrBICMS := nVlrBICMS
Return

Method SetVICMS(nVlrICMS) Class FISA302MOVIMENTO
    Self:nVlrICMS := nVlrICMS
Return

Method SetBICMST(nVlrBICMST) Class FISA302MOVIMENTO
    Self:nVlrBICMST := nVlrBICMST
Return

Method SetVICMSST(nVlrICMSST) Class FISA302MOVIMENTO
    Self:nVlrICMSST := nVlrICMSST
Return

Method SetBFec(nVlrBCFec) Class FISA302MOVIMENTO
    Self:nVlrBCFec := nVlrBCFec
Return

Method SetAliqFec(nAliqFec) Class FISA302MOVIMENTO
    Self:nAliqFec := nAliqFec
Return

Method SetVFec(nVlrFec) Class FISA302MOVIMENTO
    Self:nVlrFec := nVlrFec
Return

Method SetICMSEfe(nVlrICMEfe) Class FISA302MOVIMENTO
    Self:nVlrICMEfe := nVlrICMEfe
Return

Method SetRespRet(cRespRet) Class FISA302MOVIMENTO
    Self:cRespRet := cRespRet
Return

Method SetDtMvOri(dDtMovOri) Class FISA302MOVIMENTO
    Self:dDtMovOri := dDtMovOri
Return

Method SetVEfeOri(nVlrEfeOri) Class FISA302MOVIMENTO
    Self:nVlrEfeOri := nVlrEfeOri
Return

Method SetDocOrig(aDocOriApu) Class FISA302MOVIMENTO
    Self:aDocOriApu := aDocOriApu
Return

Method SetInscric(cInscricao) Class FISA302MOVIMENTO
    Self:cInscricao := cInscricao
Return

Method SetContrib(cContrib) Class FISA302MOVIMENTO
    Self:cContrib := cContrib
Return

Method SetEhContrib(lEhContrib) Class FISA302MOVIMENTO
    Self:lEhContrib := lEhContrib
Return

Method GetDataMov() Class FISA302MOVIMENTO
Return Self:dDataMov

Method GetTipoMov() Class FISA302MOVIMENTO
Return Self:cTipoMov

Method GetTipoDoc() Class FISA302MOVIMENTO
Return Self:cTipoDoc

Method GetCodProd() Class FISA302MOVIMENTO
Return Self:cCodProd

Method GetTipoPar() Class FISA302MOVIMENTO
Return Self:cTipoPart

Method GetAliqInt() Class FISA302MOVIMENTO
Return Self:nAliqInt

Method GetCFOP() Class FISA302MOVIMENTO
Return Self:cCFOP

Method GetCST() Class FISA302MOVIMENTO
Return Self:cCST

Method GetFGerNR() Class FISA302MOVIMENTO
Return Self:cFGerNReal

Method GetCFOPRes() Class FISA302MOVIMENTO
Return Self:cCFOPRess

Method GetQtdade() Class FISA302MOVIMENTO
Return Self:nQtdade

Method GetVUnit() Class FISA302MOVIMENTO
Return Self:nVlrUnit

Method GetTotPrd() Class FISA302MOVIMENTO
Return Self:nVlrTotPrd

Method GetFrete() Class FISA302MOVIMENTO
Return Self:nVlrFrete

Method GetSeguro() Class FISA302MOVIMENTO
Return Self:nVlrSeguro

Method GetDespesa() Class FISA302MOVIMENTO
Return Self:nVlrDesp

Method GetDescont() Class FISA302MOVIMENTO
Return Self:nVlrDesc

Method GetTotNf() Class FISA302MOVIMENTO
Return Self:nVlrTotNf

Method GetBICMS() Class FISA302MOVIMENTO
Return Self:nVlrBICMS

Method GetVICMS() Class FISA302MOVIMENTO
Return Self:nVlrICMS

Method GetBICMST() Class FISA302MOVIMENTO
Return Self:nVlrBICMST

Method GetVICMSST() Class FISA302MOVIMENTO
Return Self:nVlrICMSST

Method GetBFec() Class FISA302MOVIMENTO
Return Self:nVlrBCFec

Method GetAliqFec() Class FISA302MOVIMENTO
Return Self:nAliqFec

Method GetVFec() Class FISA302MOVIMENTO
Return Self:nVlrFec

Method GetICMSEfe() Class FISA302MOVIMENTO
Return Self:nVlrICMEfe

Method GetRespRet() Class FISA302MOVIMENTO
Return Self:cRespRet

Method GetDtMvOri() Class FISA302MOVIMENTO
Return Self:dDtMovOri

Method GetVEfeOri() Class FISA302MOVIMENTO
Return  Self:nVlrEfeOri

Method GetDocOrig() Class FISA302MOVIMENTO
Return Self:aDocOriApu

Method GetInscric() Class FISA302MOVIMENTO
Return Self:cInscricao 

Method GetContrib() Class FISA302MOVIMENTO
Return Self:cContrib

Method GetEhContrib() Class FISA302MOVIMENTO
Return Self:lEhContrib

Method GetlGerrespre() Class FISA302MOVIMENTO
Return Self:lGerrespre


//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} Classe FISA302MOVIMENTOAPURACAO

Classe reponsável por controlar os valores já apurados para o movimento.
  
@author Rafael.Soliveira
@since 24/10/2018
@version 1.0
/*/
//--------------------------------------------------------------------------------------------------
CLASS FISA302MOVIMENTOAPURACAO FROM LongClassName

Data nQtdade     As Numeric 
Data nVlrUnit    As Numeric 
Data nVlUICMSOp  As Numeric    //---Valor Unitário do ICMS OP                                    - Entrada---//
Data nVlUBICMST  As Numeric    //---Valor Unitário da BC IMCS ST                                 - Entrada---//
Data nVlUICMSST  As Numeric    //---Valor Unitário do ICMS ST                                    - Entrada---//
Data nVlUFECP    As Numeric    //---Valor Unitário do FECP ST                                    - Entrada---//
Data cCodEnquad  As Character  //---Enquadramento da Operação                                    - Saída  ---//
Data nVUICMOpCF  As Numeric    //---Valor ICMS OP saída à CF                                     - Saída  ---//
Data nVUICMOpFG  As Numeric    //---Valor ICMS OP entrada - Fato Gerador Presumido não realizado - Saída  ---//
Data nVlrResIC   As Numeric    //---Valor de Restituição do ICMS ST                              - Saída  ---//
Data nVlrResFC   As Numeric    //---Valor de Restituição do FECP ST                              - Saída  ---//
Data nVlrUResIC  As Numeric    //---Valor Unitário de Restituição do ICMS ST                     - Saída  ---//
Data nVlrUResFC  As Numeric    //---Valor Unitário de Restituição do FECP ST                     - Saída  ---//
Data nVlrComIC   As Numeric    //---Valor de Complemento do ICMS ST                              - Saída  ---//
Data nVlrComFC   As Numeric    //---Valor de Complemento do FECP ST                              - Saída  ---//
Data nVlrUComIC  As Numeric    //---Valor Unitário de Complemento do ICMS ST                     - Saída  ---//
Data nVlrUComFC  As Numeric    //---Valor Unitário de Complemento do FECP ST                     - Saída  ---//
Data nVlrCICOP   As Numeric    //---Valor Crédito do ICMS OP                                     - Saída  ---//
Data nVlMICMSOp  As Numeric    //---Valor Médio Unitário do ICMS OP do estoque                   - Estoque---//
Data nVlMBCICST  As Numeric    //---Valor Médio Unitário da BC ICMS ST do estoque                - Estoque---//
Data nVlMICMSST  As Numeric    //---Valor Médio Unitário do ICMS ST do estoque                   - Estoque---//
Data nVlMFECP    As Numeric    //---Valor Médio Unitário do FECP ST do estoque                   - Estoque---//
Data cGeraSPED   As Character  //---Define se gera registro no SPED Fiscal 1-Gera 2-Não Gera     - Controle---//
Data nVlrFrete   As Numeric    //---Valor do Frete
Data nVlrSeguro  As Numeric    //---Valor do Seguro
Data nVlrDesp    As Numeric    //---Valor da Despesa
Data nVlrDesc    As Numeric    //---Valor do Desconto

Method New() CONSTRUCTOR
Method ClearMovAp()

//---Getters e Setters---//
Method SetQtdade(nQtdade)
Method SetVUnit(nVlrUnit)
Method SetUICMSOp(nVlUICMSOp)
Method SetUBICMST(nVlUBICMST)
Method SetUICMSST(nVlUICMSST)
Method SetUFECP(nVlUFECP)
Method SetEnquad(cCodEnquad)
Method SetICMOpCF(nVUICMOpCF)
Method SetICMOpFG(nVUICMOpFG)
Method SetMICMSOp(nVlMICMSOp)
Method SetMBCICST(nVlMBCICST)
Method SetMICMSST(nVlMICMSST)
Method SetMFECP(nVlMFECP)
Method SetResIC(nVlrResIC)
Method SetResFC(nVlrResFC)
Method SetUResIC(nVlrUResIC)
Method SetUResFC(nVlrUResFC)
Method SetComIC(nVlrComIC)
Method SetComFC(nVlrComFC)
Method SetUComIC(nVlrUComIC)
Method SetUComFC(nVlrUComFC)
Method SetCrICOP(nVlrCICOP)
Method SetGSPED(cGeraSPED)
Method SetFrete(nVlrFrete)
Method SetSeguro(nVlrSeguro)
Method SetDespesa(nVlrDesp)
Method SetDescont(nVlrDesc)
Method GetQtdade()
Method GetVUnit()
Method GetUICMSOp()
Method GetUBICMST()
Method GetUICMSST()
Method GetUFECP()
Method GetEnquad()
Method GetICMOpCF()
Method GetICMOpFG()
Method GetMICMSOp()
Method GetMBCICST()
Method GetMICMSST()
Method GetMFECP()
Method GetResIC()
Method GetResFC()
Method GetUResIC()
Method GetUResFC()
Method GetComIC()
Method GetComFC()
Method GetUComIC()
Method GetUComFC()
Method GetCrICOP()
Method GetGSPED()
Method GetFrete()
Method GetSeguro()
Method GetDespesa()
Method GetDescont()

ENDCLASS


//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} New()
  
Método construtor da Classe FISA302MOVIMENTOAPURACAO

@author Rafael.Soliveira
@since 24/10/2018
@version 1.0
/*/
//--------------------------------------------------------------------------------------------------
Method New() Class FISA302MOVIMENTOAPURACAO
    Self:ClearMovAp()
Return Self


//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} Method ClearMovAp()
  
Método que limpa os valores apurados do movimento.

@author Rafael.Soliveira
@since 12/11/2018
@version 1.0
/*/
//--------------------------------------------------------------------------------------------------
Method ClearMovAp() Class FISA302MOVIMENTOAPURACAO
    Self:nQtdade    := 0
    Self:nVlrUnit   := 0
    Self:nVlUICMSOp := 0
    Self:nVlUBICMST := 0
    Self:nVlUICMSST := 0
    Self:nVlUFECP   := 0
    Self:cCodEnquad := ''
    Self:nVUICMOpCF := 0
    Self:nVUICMOpFG := 0
    Self:nVlrResIC  := 0
    Self:nVlrResFC  := 0
    Self:nVlrUResIC := 0
    Self:nVlrUResFC := 0
    Self:nVlrComIC  := 0
    Self:nVlrComFC  := 0
    Self:nVlrUComIC := 0
    Self:nVlrUComFC := 0
    Self:nVlMICMSOp := 0
    Self:nVlMBCICST := 0
    Self:nVlMICMSST := 0
    Self:nVlMFECP   := 0
    Self:nVlrCICOP  := 0
    Self:cGeraSPED  := 0
    Self:nVlrFrete  := 0
    Self:nVlrSeguro := 0
    Self:nVlrDesp   := 0
    Self:nVlrDesc   := 0
Return


//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} Getters e Setters

@author Rafael.Soliveira
@since 24/10/2018
@version 1.0
/*/
//--------------------------------------------------------------------------------------------------
Method SetQtdade(nQtdade) Class FISA302MOVIMENTOAPURACAO
    Self:nQtdade := nQtdade
Return

Method SetVUnit(nVlrUnit) Class FISA302MOVIMENTOAPURACAO
    Self:nVlrUnit := nVlrUnit
Return

Method SetUICMSOp(nVlUICMSOp) Class FISA302MOVIMENTOAPURACAO
    Self:nVlUICMSOp := nVlUICMSOp
Return

Method SetUBICMST(nVlUBICMST) Class FISA302MOVIMENTOAPURACAO
    Self:nVlUBICMST := nVlUBICMST
Return

Method SetUICMSST(nVlUICMSST) Class FISA302MOVIMENTOAPURACAO
    Self:nVlUICMSST := nVlUICMSST
Return

Method SetUFECP(nVlUFECP) Class FISA302MOVIMENTOAPURACAO
    Self:nVlUFECP := nVlUFECP
Return

Method SetEnquad(cCodEnquad) Class FISA302MOVIMENTOAPURACAO
    Self:cCodEnquad := cCodEnquad
Return

Method SetICMOpCF(nVUICMOpCF) Class FISA302MOVIMENTOAPURACAO
    Self:nVUICMOpCF := nVUICMOpCF
Return

Method SetICMOpFG(nVUICMOpFG) Class FISA302MOVIMENTOAPURACAO
    Self:nVUICMOpFG := nVUICMOpFG
Return

Method SetMICMSOp(nVlMICMSOp) Class FISA302MOVIMENTOAPURACAO
    Self:nVlMICMSOp := nVlMICMSOp
Return

Method SetMBCICST(nVlMBCICST) Class FISA302MOVIMENTOAPURACAO
    Self:nVlMBCICST := nVlMBCICST
Return

Method SetMICMSST(nVlMICMSST) Class FISA302MOVIMENTOAPURACAO
    Self:nVlMICMSST := nVlMICMSST
Return

Method SetMFECP(nVlMFECP) Class FISA302MOVIMENTOAPURACAO
    Self:nVlMFECP := nVlMFECP
Return

Method SetResIC(nVlrResIC) Class FISA302MOVIMENTOAPURACAO
    Self:nVlrResIC := nVlrResIC
Return

Method SetResFC(nVlrResFC) Class FISA302MOVIMENTOAPURACAO
    Self:nVlrResFC := nVlrResFC
Return

Method SetUResIC(nVlrUResIC) Class FISA302MOVIMENTOAPURACAO
    Self:nVlrUResIC := nVlrUResIC
Return

Method SetUResFC(nVlrUResFC) Class FISA302MOVIMENTOAPURACAO
    Self:nVlrUResFC := nVlrUResFC
Return

Method SetComIC(nVlrComIC) Class FISA302MOVIMENTOAPURACAO
    Self:nVlrComIC := nVlrComIC
Return

Method SetComFC(nVlrComFC) Class FISA302MOVIMENTOAPURACAO
    Self:nVlrComFC := nVlrComFC
Return

Method SetUComIC(nVlrUComIC) Class FISA302MOVIMENTOAPURACAO
    Self:nVlrUComIC := nVlrUComIC
Return

Method SetUComFC(nVlrUComFC) Class FISA302MOVIMENTOAPURACAO
    Self:nVlrUComFC := nVlrUComFC
Return

Method SetCrICOP(nVlrCICOP) Class FISA302MOVIMENTOAPURACAO
    Self:nVlrCICOP := nVlrCICOP
Return

Method SetGSPED(cGeraSPED) Class FISA302MOVIMENTOAPURACAO
    Self:cGeraSPED := cGeraSPED
Return

Method SetFrete(nVlrFrete) Class FISA302MOVIMENTOAPURACAO
    Self:nVlrFrete := nVlrFrete
Return

Method SetSeguro(nVlrSeguro) Class FISA302MOVIMENTOAPURACAO
    Self:nVlrSeguro := nVlrSeguro
Return

Method SetDespesa(nVlrDesp) Class FISA302MOVIMENTOAPURACAO
    Self:nVlrDesp := nVlrDesp
Return

Method SetDescont(nVlrDesc) Class FISA302MOVIMENTOAPURACAO
    Self:nVlrDesc := nVlrDesc
Return

Method GetQtdade() Class FISA302MOVIMENTOAPURACAO
Return Self:nQtdade

Method GetVUnit() Class FISA302MOVIMENTOAPURACAO
Return Self:nVlrUnit

Method GetUICMSOp() Class FISA302MOVIMENTOAPURACAO
Return Self:nVlUICMSOp

Method GetUBICMST() Class FISA302MOVIMENTOAPURACAO
Return Self:nVlUBICMST

Method GetUICMSST() Class FISA302MOVIMENTOAPURACAO
Return Self:nVlUICMSST

Method GetUFECP() Class FISA302MOVIMENTOAPURACAO
Return Self:nVlUFECP

Method GetEnquad() Class FISA302MOVIMENTOAPURACAO
Return Self:cCodEnquad

Method GetICMOpCF() Class FISA302MOVIMENTOAPURACAO
Return Self:nVUICMOpCF

Method GetICMOpFG() Class FISA302MOVIMENTOAPURACAO
Return Self:nVUICMOpFG

Method GetMICMSOp() Class FISA302MOVIMENTOAPURACAO
Return Self:nVlMICMSOp

Method GetMBCICST() Class FISA302MOVIMENTOAPURACAO
Return Self:nVlMBCICST

Method GetMICMSST() Class FISA302MOVIMENTOAPURACAO
Return Self:nVlMICMSST

Method GetMFECP() Class FISA302MOVIMENTOAPURACAO
Return Self:nVlMFECP

Method GetResIC() Class FISA302MOVIMENTOAPURACAO
Return Self:nVlrResIC

Method GetResFC() Class FISA302MOVIMENTOAPURACAO
Return Self:nVlrResFC

Method GetUResIC() Class FISA302MOVIMENTOAPURACAO
Return Self:nVlrUResIC

Method GetUResFC() Class FISA302MOVIMENTOAPURACAO
Return Self:nVlrUResFC

Method GetComIC() Class FISA302MOVIMENTOAPURACAO
Return Self:nVlrComIC

Method GetComFC() Class FISA302MOVIMENTOAPURACAO
Return Self:nVlrComFC

Method GetUComIC() Class FISA302MOVIMENTOAPURACAO
Return Self:nVlrUComIC

Method GetUComFC() Class FISA302MOVIMENTOAPURACAO
Return Self:nVlrUComFC

Method GetCrICOP() Class FISA302MOVIMENTOAPURACAO
Return Self:nVlrCICOP

Method GetGSPED() Class FISA302MOVIMENTOAPURACAO
Return Self:cGeraSPED

Method GetFrete() Class FISA302MOVIMENTOAPURACAO
Return Self:nVlrFrete

Method GetSeguro() Class FISA302MOVIMENTOAPURACAO
Return Self:nVlrSeguro

Method GetDespesa() Class FISA302MOVIMENTOAPURACAO
Return Self:nVlrDesp

Method GetDescont() Class FISA302MOVIMENTOAPURACAO
Return Self:nVlrDesc

//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} Classe FISA302MOVIMENTOENTPROTHEUS
  
@author Rafael.Soliveira
@since 30/10/2018
@version 1.0
/*/
//--------------------------------------------------------------------------------------------------
CLASS FISA302MOVIMENTOENTPROTHEUS FROM LongClassName

Data cTipoRet   As Character //---C: Carga Inicial | V: Valor de Confronto---//
Data cCodProd   As Character //------//
Data nQtdade    As Numeric   //------//
Data dDataMov   As Date      //------//
Data nAliqInt   As Numeric   //------//
Data aSldVlrDet As Array     //---Array com dados da nota de entrada ---//
Data nVlrBSST   As Numeric   //---Valor da base de calculo do ICMS ST---//
Data nVlrICMSST As Numeric   //---Valor do ICMS ST                   ---//
Data nVlrFECP   As Numeric   //---Valor do FECP                      ---//
Data nVlrICMSOP As Numeric   //---Valor do ICMS Operação Própria     ---//
Data cUF        As Character //---UF de Processamento

Method New() CONSTRUCTOR
Method DefICMSEnt()

//---Getters e Setters---//

ENDCLASS


//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} New()
  
Método construtor da Classe FISA302MOVIMENTOENTPROTHEUS

@author Rafael.Soliveira
@since 30/10/2018
@version 1.0
/*/
//--------------------------------------------------------------------------------------------------
Method New() Class FISA302MOVIMENTOENTPROTHEUS
    Self:cTipoRet   := ""
    Self:cUF        := ""       
    Self:cCodProd   := ""
    Self:nQtdade    := 0
    Self:dDataMov   := CToD("  /  /    ")
    Self:nAliqInt   := 0
    Self:aSldVlrDet := {}
    Self:nVlrBSST   := 0
    Self:nVlrICMSST := 0
    Self:nVlrFECP   := 0
    Self:nVlrICMSOP := 0
Return Self


//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} DefICMSEnt()
  
Método que define o Valor de Confronto à partir das Entradas. É também acionado para compor a Carga 
Inicial de Saldos.

@author Rafael.Soliveira
@since 30/10/2018
@version 1.0
/*/
//--------------------------------------------------------------------------------------------------
Method DefICMSEnt() Class FISA302MOVIMENTOENTPROTHEUS
    Local cTipoRet    := Self:cTipoRet
    Local cUF         := Self:cUF    
    Local cCodProd    := Self:cCodProd
    Local nQtdade     := Self:nQtdade
    Local dDataMov    := Self:dDataMov
    Local nAliqInt    := Self:nAliqInt
    Local aArea  	  := GetArea()
    Local cAlias 	  := GetNextAlias()
    Local cAliasSFT   := ''
    Local dDataDe     := FirstDay(dDataMov)
    Local dDataAte    := dDataMov
    Local dDataDeP1   := FirstDay(dDataMov)
    Local dDataDeP2   := FirstDay(dDataDeP1 -1)
    Local dDataDeP3   := FirstDay(dDataDeP2 -1)
    Local dDataDeP4   := FirstDay(dDataDeP3 -1)
    Local dDataDeP5   := FirstDay(dDataDeP4 -1)
    Local dDataDeP6   := FirstDay(dDataDeP5 -1)
    Local dDataDeP7   := FirstDay(dDataDeP6 -1)
    Local dDataDeP8   := FirstDay(dDataDeP7 -1)
    Local dDataDeP9   := FirstDay(dDataDeP8 -1)
    Local dDataDeP10  := FirstDay(dDataDeP9 -1)
    Local dDataDeP11  := FirstDay(dDataDeP10-1)
    Local dDataDeP12  := FirstDay(dDataDeP11-1)
    Local lAchouFT	  := .F.
    Local aSldVlrDet  := {}
    Local aQtdadeAnt  := {{'',0},{'',0},{'',0},{'',0},{'',0},{'',0},{'',0},{'',0},{'',0},{'',0},{'',0},{'',0},CtoD('  /  /    ')}
    Local aDocOriApu  := {CtoD('  /  /    '),0,0,0,0,0,0,'',0,0,0,0,0,0,''}
    Local nCount      := 1
    Local oApurEntAn  := Nil

    Local nVlrICMS    := 0
    Local nVlrBICMST  := 0
    Local nVlrICMSST  := 0
    Local nVlrFec     := 0

    Local nMovQtdade  := 0
    Local nMovVICMOP  := 0
    Local nMovVBCST   := 0
    Local nMovVICMST  := 0
    Local nMovVFECST  := 0

    Local nRetQtdade  := 0
    Local nRetVICMOP  := 0
    Local nRetVBCST   := 0
    Local nRetVICMST  := 0
    Local nRetVFECST  := 0

    Local cSGBD       := TCGetDB()
    Local cSubStrBD   := ''
    Local lCIJRessar  := CIJ->(FieldPos("CIJ_RESSAR")) > 0
    Local cCIJRessar  := ''

    Local nDecimal    := 2

    If  cUF == "RS"   // Para UF  RS considera 6 casas decimais para gravação na tabela CII para correta validação na GIA
        nDecimal := 6
    Endif

    //---Verifica se existe quantidade suficiente na movimentação de entrada para compor valores para o produto---//
    If cSGBD = 'ORACLE'
        cSubStrBD := 'SUBSTR(SFT.FT_CLASFIS,2,2)'
    Else
        cSubStrBD := 'RIGHT(SFT.FT_CLASFIS,2)'
    EndIf
    cSubStrBD := "%" + cSubStrBD + "%"

    If lCIJRessar
        cCIJRessar := "CIJ.CIJ_RESSAR"
    Else
        cCIJRessar := "''"
    EndIf
    cCIJRessar := "%" + cCIJRessar + "%"

    BeginSql Alias cAlias
        SELECT SUM(SFT.FT_QUANT) QUANT,
        SUM(CASE WHEN FT_ENTRADA BETWEEN %EXP:dDataDeP1%  AND %EXP:dDataAte% THEN SFT.FT_QUANT ELSE 0 END) QUANT_1,
        SUM(CASE WHEN FT_ENTRADA BETWEEN %EXP:dDataDeP2%  AND %EXP:dDataAte% THEN SFT.FT_QUANT ELSE 0 END) QUANT_2,
        SUM(CASE WHEN FT_ENTRADA BETWEEN %EXP:dDataDeP3%  AND %EXP:dDataAte% THEN SFT.FT_QUANT ELSE 0 END) QUANT_3,
        SUM(CASE WHEN FT_ENTRADA BETWEEN %EXP:dDataDeP4%  AND %EXP:dDataAte% THEN SFT.FT_QUANT ELSE 0 END) QUANT_4,
        SUM(CASE WHEN FT_ENTRADA BETWEEN %EXP:dDataDeP5%  AND %EXP:dDataAte% THEN SFT.FT_QUANT ELSE 0 END) QUANT_5,
        SUM(CASE WHEN FT_ENTRADA BETWEEN %EXP:dDataDeP6%  AND %EXP:dDataAte% THEN SFT.FT_QUANT ELSE 0 END) QUANT_6,
        SUM(CASE WHEN FT_ENTRADA BETWEEN %EXP:dDataDeP7%  AND %EXP:dDataAte% THEN SFT.FT_QUANT ELSE 0 END) QUANT_7,
        SUM(CASE WHEN FT_ENTRADA BETWEEN %EXP:dDataDeP8%  AND %EXP:dDataAte% THEN SFT.FT_QUANT ELSE 0 END) QUANT_8,
        SUM(CASE WHEN FT_ENTRADA BETWEEN %EXP:dDataDeP9%  AND %EXP:dDataAte% THEN SFT.FT_QUANT ELSE 0 END) QUANT_9,
        SUM(CASE WHEN FT_ENTRADA BETWEEN %EXP:dDataDeP10% AND %EXP:dDataAte% THEN SFT.FT_QUANT ELSE 0 END) QUANT_10,
        SUM(CASE WHEN FT_ENTRADA BETWEEN %EXP:dDataDeP11% AND %EXP:dDataAte% THEN SFT.FT_QUANT ELSE 0 END) QUANT_11,
        SUM(CASE WHEN FT_ENTRADA BETWEEN %EXP:dDataDeP12% AND %EXP:dDataAte% THEN SFT.FT_QUANT ELSE 0 END) QUANT_12,
        MIN(FT_ENTRADA) FT_PERINI
        FROM %TABLE:SFT% SFT
        INNER JOIN %TABLE:CIJ% CIJ ON (CIJ.CIJ_FILIAL = %XFILIAL:CIJ% AND CIJ.CIJ_CFOP  = SFT.FT_CFOP    AND CIJ.%NOTDEL%)
        INNER JOIN %TABLE:CIK% CIK ON (CIK.CIK_FILIAL = %XFILIAL:CIK% AND CIK.CIK_IDTAB = CIJ.CIJ_IDTAB  AND CIK.CIK_CSTICM = %Exp:cSubStrBD% AND CIK.%NOTDEL%)
        WHERE  SFT.FT_FILIAL=%XFILIAL:SFT%                  AND
               SFT.FT_PRODUTO = %EXP:cCodProd%              AND
               SFT.FT_TIPO NOT IN ('D','B','S','P','I','C') AND
               SFT.FT_TIPOMOV  = 'E'                        AND
               SFT.FT_DTCANC   = ''                         AND
               SFT.FT_ENTRADA  <=  %EXP:dDataAte%           AND
               SFT.FT_NFORI    = ' '                        AND
               SFT.FT_SERORI   = ' '                        AND
               SFT.FT_ITEMORI  = ' '                        AND
               SFT.%NOTDEL%	
    EndSql

    DbSelectArea(cAlias)
    If (cAlias)->QUANT >= nQtdade
    	lAchouFT := .T.	

        aQtdadeAnt[1]  := {dDataDeP1,  (cAlias)->QUANT_1}
        aQtdadeAnt[2]  := {dDataDeP2,  (cAlias)->QUANT_2}
        aQtdadeAnt[3]  := {dDataDeP3,  (cAlias)->QUANT_3}
        aQtdadeAnt[4]  := {dDataDeP4,  (cAlias)->QUANT_4}
        aQtdadeAnt[5]  := {dDataDeP5,  (cAlias)->QUANT_5}
        aQtdadeAnt[6]  := {dDataDeP6,  (cAlias)->QUANT_6}
        aQtdadeAnt[7]  := {dDataDeP7,  (cAlias)->QUANT_7}
        aQtdadeAnt[8]  := {dDataDeP8,  (cAlias)->QUANT_8}
        aQtdadeAnt[9]  := {dDataDeP9,  (cAlias)->QUANT_9}
        aQtdadeAnt[10] := {dDataDeP10, (cAlias)->QUANT_10}
        aQtdadeAnt[11] := {dDataDeP11, (cAlias)->QUANT_11}
        aQtdadeAnt[12] := {dDataDeP12, (cAlias)->QUANT_12}
        aQtdadeAnt[13] := FirstDay(StoD((cAlias)->FT_PERINI))
    EndIf
    (cAlias)->(DbCloseArea()) 

    If lAchouFT

        //---Definição do período necessário para compor a quantidade informada em nQtdade---//
        dDataDe := CtoD('  /  /    ')
        While nCount <= 12 .And. Empty(dDataDe)
            If aQtdadeAnt[nCount][2] >= nQtdade
                dDataDe := aQtdadeAnt[nCount][1]
            EndIf
            nCount++
        EndDo
        dDataDe := Iif(Empty(dDataDe), aQtdadeAnt[13], dDataDe)

        //---Classe responsável pela apuração do movimento---//
        oApurEntAn := FISA302APURACAO():New('','',{},'')
        oApurEntAn:cUF := cUF

        cAliasSFT := GetNextAlias()

        BeginSql Alias cAliasSFT
            COLUMN FT_DATAMOV AS DATE

            SELECT SFT.FT_PRODUTO             FT_PRODUTO,
	               CASE SFT.FT_TIPOMOV
                       WHEN 'E' THEN          FT_ENTRADA
		               ELSE                   FT_EMISSAO
                   END                        FT_DATAMOV,
	               SFT.FT_TIPOMOV             FT_TIPOMOV,
	               SFT.FT_TIPO                FT_TIPO,
                   SFT.FT_NFISCAL             FT_NFISCAL,
                   SFT.FT_SERIE               FT_SERIE,
                   SFT.FT_ITEM                FT_ITEM,
                   SFT.FT_CLIEFOR             FT_CLIEFOR,
                   SFT.FT_LOJA                FT_LOJA,
	               SFT.FT_CFOP                FT_CFOP,
                   SFT.FT_CLASFIS             FT_CLASFIS,
	               SFT.FT_QUANT               FT_QUANT,
                   SFT.FT_PRCUNIT             FT_PRCUNIT,
	               SFT.FT_TOTAL               FT_TOTAL,
	               SFT.FT_FRETE               FT_FRETE,
	               SFT.FT_SEGURO              FT_SEGURO,
	               SFT.FT_DESPESA             FT_DESPESA,
	               SFT.FT_DESCONT             FT_DESCONT,
                   SFT.FT_VALCONT             FT_VALCONT,
	               SFT.FT_BASEICM             FT_BASEICM,
                   SFT.FT_VICEFET             FT_VICEFET,
                   CASE 
                       WHEN %Exp:cSubStrBD% = '60' AND SFT.FT_ICMSRET = 0 
                       THEN 0
                       ELSE CASE
                                WHEN SFT.FT_BASEICM = 0 AND SFT.FT_OUTRICM > 0
                                THEN SD1.D1_VALICM
                                ELSE SFT.FT_VALICM
                            END
                   END                        FT_VALICM,
                   CASE 
                       WHEN  %Exp:cSubStrBD% = '60' AND SFT.FT_ICMSRET = 0 
                       THEN '2'
                       ELSE CASE WHEN SFT.FT_VALANTI > 0 
                                THEN '3' 
                   			 ELSE '1' 
                   	    END 
                   END                        FT__RESRET,
                   CASE 
                       WHEN %Exp:cSubStrBD% = '60' AND SFT.FT_ICMSRET = 0 
                       THEN SFT.FT_BASNDES
                       ELSE SFT.FT_BASERET
                   END                        FT__BCST,
                   CASE 
                       WHEN  %Exp:cSubStrBD% = '60' AND SFT.FT_ICMSRET = 0 
                       THEN SFT.FT_ALQNDES
                       ELSE SFT.FT_ALIQSOL
                   END                        FT__ALQST,
                   CASE 
                       WHEN  %Exp:cSubStrBD% = '60' AND SFT.FT_ICMSRET = 0 
                       THEN SFT.FT_ICMNDES
                       ELSE SFT.FT_ICMSRET
                   END                        FT__VLRST,
                   CASE 
                       WHEN  %Exp:cSubStrBD% = '60' AND SFT.FT_ICMSRET = 0 
                       THEN SFT.FT_BFCPANT
                       ELSE SFT.FT_BSFCPST
                   END                        FT__BASFEC,
                   CASE 
                       WHEN  %Exp:cSubStrBD% = '60' AND SFT.FT_ICMSRET = 0 
                       THEN SFT.FT_AFCPANT
                       ELSE SFT.FT_ALFCPST
                   END                        FT__ALQFEC,
                   CASE 
                       WHEN  %Exp:cSubStrBD% = '60' AND SFT.FT_ICMSRET = 0 
                       THEN SFT.FT_VFCPANT
                       ELSE SFT.FT_VFECPST
                   END                        FT__VALFEC,
                   %Exp:cCIJRessar%           CIJ_RESSAR                     
            FROM  %TABLE:SFT% SFT INNER JOIN %TABLE:SD1% SD1 ON (SD1.D1_FILIAL  = %XFILIAL:SD1% AND SD1.D1_DOC    = SFT.FT_NFISCAL AND SD1.D1_SERIE = SFT.FT_SERIE AND SD1.D1_FORNECE = SFT.FT_CLIEFOR AND SD1.D1_LOJA = SFT.FT_LOJA AND SD1.D1_COD = SFT.FT_PRODUTO AND SD1.D1_ITEM = SFT.FT_ITEM AND SD1.%NOTDEL%)
                                  INNER JOIN %TABLE:CIJ% CIJ ON (CIJ.CIJ_FILIAL = %XFILIAL:CIJ% AND CIJ.CIJ_CFOP  = SFT.FT_CFOP    AND CIJ.%NOTDEL%)
                                  INNER JOIN %TABLE:CIK% CIK ON (CIK.CIK_FILIAL = %XFILIAL:CIK% AND CIK.CIK_IDTAB = CIJ.CIJ_IDTAB  AND CIK.CIK_CSTICM = %Exp:cSubStrBD% AND CIK.%NOTDEL%)
            WHERE  SFT.FT_FILIAL=%XFILIAL:SFT%                       AND
                   SFT.FT_PRODUTO = %EXP:cCodProd%                   AND
                   SFT.FT_TIPO NOT IN ('D','B','S','P','I','C')      AND
                   SFT.FT_TIPOMOV  = 'E'                             AND
                   SFT.FT_DTCANC   = ''		                         AND
                   SFT.FT_ENTRADA >=  %EXP:dDataDe%                  AND
                   SFT.FT_ENTRADA <=  %EXP:dDataAte%                 AND
                   SFT.FT_NFORI    = ' '                             AND
                   SFT.FT_SERORI   = ' '                             AND
                   SFT.FT_ITEMORI  = ' '                             AND
                   SFT.%NOTDEL%
            ORDER BY SFT.FT_ENTRADA DESC, SD1.D1_NUMSEQ DESC
        EndSql 

        DbSelectArea(cAliasSFT)
        While !(cAliasSFT)->(Eof()) .And. nQtdade > 0

            If cTipoRet == 'C'

                //---Método SetaMovim: Carrega os dados do movimento para que seja feita sua apuração---//
                oApurEntAn:SetaMovim((cAliasSFT)->FT_DATAMOV,;           //---dDataMov   - Data do Movimento
                                     (cAliasSFT)->FT_TIPOMOV,;           //---cTipoMov   - Tipo do Movimento (E-Entrada / S-Saída)
                                     (cAliasSFT)->FT_TIPO,;              //---cTipoDoc   - Tipo do Documento (Normal / Devolução / Complemento)
                                     (cAliasSFT)->FT_PRODUTO,;           //---cCodProd   - Código do Produto
                                     '',;                                //---cTipoPart  - Tipo do Participante (Cliente Final / Revendedor)
                                     nAliqInt,;                          //---nAliqInt   - Alíquota Interna do Produto
                                     (cAliasSFT)->FT_CFOP,;              //---cCFOP      - CFOP
                                     Right((cAliasSFT)->FT_CLASFIS,2),;  //---cCST       - CST ICMS
                                     '',;                                //---cFGerNReal - Indica se a operação (CFOP) deve ser enquadrada como 2-Fato Gerador não realizado
                                     (cAliasSFT)->CIJ_RESSAR,;           //---cCFOPRess  - Indica se a operação (CFOP) deve ser considerada para cálculo de Ressarcimento
                                     (cAliasSFT)->FT_QUANT,;             //---nQtdade    - Quantidade
                                     (cAliasSFT)->FT_PRCUNIT,;           //---nVlrUnit   - Valor Unitário do Item da Nota Fiscal
                                     (cAliasSFT)->FT_TOTAL,;             //---nVlrTotPrd - Valor Total do Produto
                                     (cAliasSFT)->FT_FRETE,;             //---nVlrFrete  - Valor do Frete
                                     (cAliasSFT)->FT_SEGURO,;            //---nVlrSeguro - Valor do Seguro
                                     (cAliasSFT)->FT_DESPESA,;           //---nVlrDesp   - Valor das Despesas
                                     (cAliasSFT)->FT_DESCONT,;           //---nVlrDesc   - Valor do Desconto
                                     (cAliasSFT)->FT_VALCONT,;           //---nVlrTotNf  - Valor Total da Nota Fiscal
                                     (cAliasSFT)->FT_BASEICM,;           //---nVlrBICMS  - Base de Cálculo do ICMS
                                     (cAliasSFT)->FT_VALICM,;            //---nVlrICMS   - Valor do ICMS
                                     (cAliasSFT)->FT__BCST,;             //---nVlrBICMST - Valor da Base de Cálculo do ICMS-ST
                                     (cAliasSFT)->FT__VLRST,;            //---nVlrICMSST - Valor do ICMS-ST
                                     (cAliasSFT)->FT__BASFEC,;           //---nVlrBCFec  - Base do FECP ST
                                     (cAliasSFT)->FT__ALQFEC,;           //---nAliqFec   - Alíquota do FECP ST
                                     (cAliasSFT)->FT__VALFEC,;           //---nVlrFec    - Alíquota do FECP ST
                                     (cAliasSFT)->FT_VICEFET,;           //---nVlrICMEfe - Valor do ICMS Efetivo na Saída
                                     (cAliasSFT)->FT__RESRET,;           //---cRespRet   - Responsável pela retenção do ICMS-ST (1 – Remetente Direto / 2 – Remetente Indireto / 3 – Próprio declarante )---//
                                     CtoD('  /  /    '),;                //---dDtMovOri  - Data do Movimento Original, em casos de movimentos de devolução
                                     0,;                                 //---nVlrEfeOri - Valor do ICMS Efetivo na Saída Original, em casos de movimentos de devolução
                                     aDocOriApu,;                        //---aDocOriApu - Valores apurados para o Documento Fiscal Original, em casos de movimentos de devolução
                                    '',;                                 //---cInscricao - Incrição estadual do Participante
                                    '')                                  //---cContrib   - Contribuinte do ICMS (1 - Sim / 2 - Não)


                //---Método ApuraMovim: Apura os valores de Entradas que serão recuperados através do objeto oMovimApur---//
                oApurEntAn:ApuraMovim()
                nVlrICMS   := Round(oApurEntAn:oMovimApur:GetUICMSOp() * (cAliasSFT)->FT_QUANT, nDecimal)
                nVlrBICMST := Round(oApurEntAn:oMovimApur:GetUBICMST() * (cAliasSFT)->FT_QUANT, nDecimal)
                nVlrICMSST := Round(oApurEntAn:oMovimApur:GetUICMSST() * (cAliasSFT)->FT_QUANT, nDecimal)
                nVlrFec    := Round(oApurEntAn:oMovimApur:GetUFECP()   * (cAliasSFT)->FT_QUANT, nDecimal)

            EndIf

            If (cAliasSFT)->FT_QUANT <= nQtdade
                nMovVICMOP  := nVlrICMS
                nMovVBCST   := nVlrBICMST
                nMovVICMST  := nVlrICMSST
                nMovVFECST  := nVlrFec
                nMovQtdade  := (cAliasSFT)->FT_QUANT
            Else
                nMovVICMOP  := Round((nVlrICMS   / (cAliasSFT)->FT_QUANT) * nQtdade, nDecimal)
                nMovVBCST   := Round((nVlrBICMST / (cAliasSFT)->FT_QUANT) * nQtdade, nDecimal)
                nMovVICMST  := Round((nVlrICMSST / (cAliasSFT)->FT_QUANT) * nQtdade, nDecimal)
                nMovVFECST  := Round((nVlrFec    / (cAliasSFT)->FT_QUANT) * nQtdade, nDecimal)
                nMovQtdade  := nQtdade
            EndIf

            nRetVICMOP += nMovVICMOP
            nRetVBCST  += nMovVBCST 
            nRetVICMST += nMovVICMST
            nRetVFECST += nMovVFECST
            nRetQtdade += nMovQtdade
            nQtdade    -= nMovQtdade

            If cTipoRet == 'C'
                aAdd(aSldVlrDet,{(cAliasSFT)->FT_NFISCAL,;
                                 (cAliasSFT)->FT_SERIE,;
                                 (cAliasSFT)->FT_CLIEFOR,;
                                 (cAliasSFT)->FT_LOJA,;
                                 (cAliasSFT)->FT_ITEM,;
                                 (cAliasSFT)->FT_PRODUTO,;
                                 (cAliasSFT)->FT_CFOP,;
                                 (cAliasSFT)->FT_CLASFIS,;
                                 nMovQtdade,;
                                 (cAliasSFT)->FT_PRCUNIT,;
                                 Round(nMovVICMOP / nMovQtdade, nDecimal),;
                                 Round(nMovVBCST  / nMovQtdade, nDecimal),;
                                 Round(nMovVICMST / nMovQtdade, nDecimal),;
                                 Round(nMovVFECST / nMovQtdade, nDecimal),;
                                 nRetQtdade,;
                                 Round(nRetVICMOP / nRetQtdade, nDecimal),;
                                 Round(nRetVBCST  / nRetQtdade, nDecimal),;
                                 Round(nRetVICMST / nRetQtdade, nDecimal),;
                                 Round(nRetVFECST / nRetQtdade, nDecimal),;
                                 (cAliasSFT)->FT__RESRET,;
                                 (cAliasSFT)->FT_TIPOMOV,;
                                 (cAliasSFT)->FT_TIPO})
            EndIf

            (cAliasSFT)->(DbSkip())
        EndDo
        (cAliasSFT)->(DbCloseArea()) 

        //---Se a quantidade requisitada não for completamente processada, as médias retornadas serão zero, pois entende-se que não há movimentação de entrada suficiente para suportar nQtdade---//
        If nQtdade > 0
            nRetVBCST  := 0
            nRetVICMST := 0
            nRetVFECST := 0
            nRetVICMOP := 0
            aSldVlrDet := aSize(aSldVlrDet,0)
        EndIf

        If cTipoRet == 'C'
            Self:nVlrBSST   := nRetVBCST
            Self:nVlrICMSST := nRetVICMST
            Self:nVlrFECP   := nRetVFECST
            Self:nVlrICMSOP := nRetVICMOP
            Self:aSldVlrDet := aSldVlrDet
        EndIf
    
    EndIf

    RestArea(aArea)

Return


//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} EhContrib()
  
Método construtor da Classe FISA302MOVIMENTO

@author matheus.massarotto
@since 13/01/2022
@version 1.0
/*/
//--------------------------------------------------------------------------------------------------
Method EhContrib() Class FISA302MOVIMENTO
    
    Local cInscricao  := Self:GetInscric()
    Local cContrib    := Self:GetContrib()
    
    Self:SetEhContrib(.T.)

    if Empty(cInscricao) .Or. "ISENT" $ cInscricao .Or. "RG" $ cInscricao .Or. cContrib == "2"
        Self:SetEhContrib(.F.)
    endif

    /*
        Não fiz o tratamento para verificar o contribuinte quando for produtor rural, pois o objetivo da Issue DSERFIS1-30701, foi tratar consumidor final para atender o artigo 31.A do anexo XV http://www.fazenda.mg.gov.br/empresas/legislacao_tributaria/ricms_2002_seco/anexoxv2002_2.html#parte1art31A

        Caso necessário futuramente, existe este trecho baseado no FISA132

        If SA1->A1_CONTRIB == "1" .and. SA1->A1_TPJ == "3" .and. ( Empty( SA1->A1_INSCR ) .or. "ISENT" $ SA1->A1_INSCR )
			lInscrito := .F.
		EndIf

		//Tratamento para considerar como contribuinte do ICMS Produtor Rural com inscrição Rural
		If (!Empty(SA1->A1_INSCRUR) .And. "L" $ SA1->A1_TIPO .And. ( lA1Contrib .And. SA1->A1_CONTRIB <> "2"))
			lInscrito := .F.
		EndIf
    */

Return Self

