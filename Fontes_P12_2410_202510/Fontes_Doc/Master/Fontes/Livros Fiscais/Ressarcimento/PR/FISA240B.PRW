#INCLUDE "PROTHEUS.CH"

//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} FISA240B
  
Definição da Estrutura de Classes para a ADRC-ST - ARQUIVO DIGITAL DA RECUPERAÇÃO, DO RESSARCIMENTO 
E DA COMPLEMENTAÇÃO DO ICMS ST, do Estado do Paraná.
O método de apuração é determinado pelo Decreto nº 3.886 de 21/01/2020 e pela Norma de Procedimento 
Fiscal nº 003/2020, publicado em 28/01/2020.

@author Ulisses P. Oliveira
@since 26/03/2020
@version 1.0
/*/
//--------------------------------------------------------------------------------------------------


//==================================================================================================
/*/{Protheus.doc} Classe FISA240APURACAO

Classe responsável pela apuração de cada movimento da query principal, os quais carregarão dados 
necessários para o cálculo dos registros 1100, 1200, 1300, 1400, 1500 e 9000. 
 
@author Ulisses P. Oliveira
@since 26/03/2020
@version 1.0
/*/
//==================================================================================================
CLASS FISA240APURACAO FROM LongNameClass

Data cIdApur     As Character //---Identificador da Apuração                                                                                                      ---//
Data cFilApur    As Character //---Código da Filial apurada                                                                                                       ---//
Data cAnoMes     As Character //---Período da Apuração                                                                                                            ---//
Data aDtIniReCo  As Array     //---Data de início: Ressarcimento (CF), Ressarcimento (Outras Hipóteses), Complemento                                              ---//
Data aPerRedMVA  As Array     //---Percentual da MVA para o cálculo do Ressarcimento na hipótese de Saídas internas destinadas a contribuintes do Simples Nacional---//
Data o1000       As Object    //---Objeto que controla o Registro 1000                                                                                            ---//
Data o1100       As Object    //---Objeto que controla o Registro 1100                                                                                            ---//
Data o1200       As Object    //---Objeto que controla o Registro 1200                                                                                            ---//
Data o1300       As Object    //---Objeto que controla o Registro 1300                                                                                            ---//
Data o1400       As Object    //---Objeto que controla o Registro 1400                                                                                            ---//
Data o1500       As Object    //---Objeto que controla o Registro 1500                                                                                            ---//
Data o9000       As Object    //---Objeto que controla o Registro 9000                                                                                            ---//
Data oMovimento  As Object    //---Objeto que controla o movimento analisado                                                                                      ---//
Data cVAr01      As Numeric // Parametro  01
Data cVAr02      As Numeric // Parametro  02
Data cVAr03      As Numeric // Parametro  03
Data cVAr04      As Numeric // Parametro  04


Method New(cIdApur,cAnoMes,aDtIniReCo,aPerRedMVA,cVAr01,cVAr02,cVAr03,cVAr04) CONSTRUCTOR
Method SetaMovim(dDataMov,cTipoMov,cTipoDoc,cCodProd,cTipoPart,cPartOptSN,nAliqInt,nAliqFec,cCFOP,cCST,nQtdade,nVlrUnit,nVlrTotPrd,nVlrFrete,nVlrSeguro,nVlrDesp,nVlrDesc,nVlrTotNf,nVlrAICMS,nVlrICMS,nVlrBICMST,nVlrICMSST,nVlrMVAOp,cRespRet,cPrdResVSN,aDocOriApu)
Method ApuraMovim()
Method ApuraProd(nQtdTotAnt,nQtdPerAnt)
Method ApuraPer()
Method ClearProd()

//---Getters e Setters---//
Method SetAnoMes(cAnoMes)
Method GetIdApur()
Method GetAnoMes()
Method GetIniReCo()

ENDCLASS


//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} New()
  
Método construtor da Classe FISA240APURACAO

@author Ulisses P. Oliveira
@since 26/03/2020
@version 1.0
/*/
//--------------------------------------------------------------------------------------------------
Method New(cIdApur,cAnoMes,aDtIniReCo,aPerRedMVA,cVAr01,cVAr02,cVAr03,cVAr04) Class FISA240APURACAO
	Self:cIdApur    := cIdApur
	Self:cFilApur   := ""
	Self:cAnoMes    := cAnoMes
    Self:aDtIniReCo := aDtIniReCo
    Self:aPerRedMVA := aPerRedMVA
    Self:cVAr01     := cVAr01
    Self:cVAr02     := cVAr02
    Self:cVAr03     := cVAr03
    Self:cVAr04     :=  cVAr04
    Self:o1000      := FISA2401000():New()
    Self:o1100      := FISA2401100():New()
    Self:o1200      := FISA2401200():New()
    Self:o1300      := FISA2401300():New()
    Self:o1400      := FISA2401400():New()
    Self:o1500      := FISA2401500():New()
    Self:o9000      := FISA2409000():New()
    Self:oMovimento := FISA240MOVIMENTO():New()
Return Self


//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} SetaMovim()
  
Método que carrega no objeto o movimento a ser analisado. 
Deve ser chamado a cada movimento encontrado para o produto em questão.

@author Ulisses P. Oliveira
@since 26/03/2020
@version 1.0
/*/
//--------------------------------------------------------------------------------------------------
Method SetaMovim(dDataMov,cTipoMov,cTipoDoc,cCodProd,cTipoPart,cPartOptSN,nAliqInt,nAliqFec,cCFOP,cCST,nQtdade,nVlrUnit,nVlrTotPrd,nVlrFrete,nVlrSeguro,nVlrDesp,nVlrDesc,nVlrTotNf,nVlrAICMS,nVlrICMS,nVlrBICMST,nVlrICMSST,nVlrMVAOp,cRespRet,cPrdResVSN,aDocOriApu) Class FISA240APURACAO
    Self:oMovimento:SetDataMov(dDataMov)
    Self:oMovimento:SetTipoMov(cTipoMov)
    Self:oMovimento:SetTipoDoc(cTipoDoc)
    Self:oMovimento:SetCodProd(cCodProd)
    Self:oMovimento:SetTipoPar(cTipoPart)
    Self:oMovimento:SetOptSN(cPartOptSN)
    Self:oMovimento:SetAliqInt(nAliqInt)
    Self:oMovimento:SetAliqFec(nAliqFec)
    Self:oMovimento:SetCFOP(cCFOP)
    Self:oMovimento:SetCST(cCST)
    Self:oMovimento:SetQtdade(nQtdade)
    Self:oMovimento:SetVUnit(nVlrUnit)
    Self:oMovimento:SetTotPrd(nVlrTotPrd)
    Self:oMovimento:CalcTotPrd(nQtdade,nVlrUnit)
    Self:oMovimento:SetFrete(nVlrFrete)
    Self:oMovimento:SetSeguro(nVlrSeguro)
    Self:oMovimento:SetDespesa(nVlrDesp)
    Self:oMovimento:SetDescont(nVlrDesc)
    Self:oMovimento:SetTotNf(nVlrTotNf)
    Self:oMovimento:SetAICMS(nVlrAICMS)
    Self:oMovimento:SetVICMS(nVlrICMS)
    Self:oMovimento:SetBICMST(nVlrBICMST)
    Self:oMovimento:SetVICMSST(nVlrICMSST)
    Self:oMovimento:SetVMVAOp(nVlrMVAOp)
    Self:oMovimento:SetRespRet(cRespRet)
    Self:oMovimento:SetPrResSN(cPrdResVSN)
    Self:oMovimento:SetDocOrig(aDocOriApu)
    Self:oMovimento:SetGrvMov(.F.)
Return


//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} ApuraMovim()
  
Método responsável por avaliar cada movimento.

@author Ulisses P. Oliveira
@since 26/03/2020
@version 1.0
/*/
//--------------------------------------------------------------------------------------------------
Method ApuraMovim() Class FISA240APURACAO
    Local cAnoMes     := Self:GetAnoMes()
    Local cCodProd    := Self:oMovimento:GetCodProd()
    Local cTipoMov    := Self:oMovimento:GetTipoMov()
    Local cTipoDoc    := Self:oMovimento:GetTipoDoc()
    Local nQtdade     := Self:oMovimento:GetQtdade()
    Local nAliqInt    := Self:oMovimento:GetAliqInt()
    Local nAliqFec    := Self:oMovimento:GetAliqFec()
    Local nVlrBICMST  := Self:oMovimento:GetBICMST()
    Local nVlrICMSST  := Self:oMovimento:GetVICMSST()
    Local nVlrMVAOp   := Self:oMovimento:GetVMVAOp()
    Local nVlrAICMS   := Self:oMovimento:GetAICMS()
    Local nVlrICMS    := Self:oMovimento:GetVICMS()
    Local nVlrUnit    := Self:oMovimento:GetVUnit()
    Local nVlrTotPrd  := Self:oMovimento:GetTotPrd()
    Local aDocOriApu  := Self:oMovimento:GetDocOrig()
    Local cRespRet    := Self:oMovimento:GetRespRet()
    Local nVlrBICMS   := Self:oMovimento:DefBaseICM()
    Local cCodPr1000  := Self:o1000:Get1000B03()
    Local aDtIniReCo  := Self:GetiniReCo()
    Local nVlrICMSSu  := 0
    Local nVlrICMEfe  := 0
    Local cTipoOper   := ''


    If (cCodProd == cCodPr1000) .Or. Empty(cCodPr1000)
        Self:o1000:Set1000B03(cCodProd)
        Self:o1000:Set1000B10(nAliqInt) //---Corresponde à alíquota da mercadoria prevista para as operações internas, incluído o FECOP---//
        Self:o1000:Set1000B11(nAliqFec)

        If (cTipoMov=='E' .And. cTipoDoc != 'D') .Or. (cTipoMov=='S' .And. cTipoDoc == 'D' .And. Left(DtoS(aDocOriApu[1]),6) == cAnoMes) //---Para Entradas: Define o ICMS Suportado / Alimenta objeto o1100 ---//

            //---Define Total de ICMS Suportado---//
            If cTipoDoc != 'D'

                //------------------------------------------------------------------------------------------------------------------------------------------------------//
                /* Norma de Procedimento Fiscal nº 003/2020 publicado em 28/01/2020:
                   SEÇÃO I 
                   Subseção II
                   Art. 9.º
                   § 5.º Para o cálculo do imposto suportado pelo contribuinte substituído na entrada será utilizado o valor unitário médio, que abrange o imposto incidente na 
                         operação própria do substituto e o retido por ST, incluída a parcela do Fecop, se houver.

                   § 6.º Caso a mercadoria tenha sido adquirida de outro contribuinte substituído e o documento fiscal relativo à entrada não contenha o valor do imposto próprio 
                         ou do retido, o somatório destes valores poderá ser obtido pela aplicação da alíquota interna da mercadoria sobre a base de cálculo de retenção constante 
                         do documento fiscal de aquisição, campo “vBCSTRet”, ID N26 da NFe, do Grupo de Tributação do ICMS = 60 ou 500.

                   § 7.º Na ausência de informação da base de cálculo para a retenção no documento fiscal relativo à entrada da mercadoria poderá ser utilizado o valor resultante 
                         da aplicação da alíquota vigente para as operações internas sobre o valor de aquisição da mercadoria, e na hipótese de operação beneficiada com redução da 
                         base de cálculo, sobre a base de cálculo reduzida. 
                */
                //------------------------------------------------------------------------------------------------------------------------------------------------------//

                If cRespRet == '2'
                    nVlrICMSSu := Round(((Iif(nVlrBICMST>0,nVlrBICMST,nVlrTotPrd)*nAliqInt)/100),2)
                Else
                    nVlrICMSSu := nVlrICMS + nVlrICMSST
                EndIf

            Else
                nVlrICMSSu := (aDocOriApu[4]/aDocOriApu[2])*nQtdade
                cRespRet   := ''
            EndIf

            //---Alimenta objeto o1100---//
            Self:o1100:Inc1100(cTipoDoc,nQtdade,nVlrBICMST,nVlrICMSSu,nVlrUnit,nVlrAICMS,nVlrMVAOp)

            //---Controla a Gravação do Movimento---//
            Self:oMovimento:SetGrvMov(.T.)
            Self:oMovimento:SetOrdMov(Self:oMovimento:GetOrdMov()+1)

        ElseIf (cTipoMov=='S' .And. cTipoDoc != 'D') .Or. (cTipoMov=='E' .And. cTipoDoc == 'D' .And. Left(DtoS(aDocOriApu[1]),6) == cAnoMes) //---Para Saídas: Define o ICMS Efetivo / Alimenta objetos o1200, o1300, o1400, o1500---//

            //---Classifica operação de saída---//
            cTipoOper := Self:oMovimento:EnquadMov(aDtIniReCo)

            If !Empty(cTipoOper)

                If cTipoOper == '12' //---12 – Saídas internas destinadas a consumidor final---//

                    //---Define o ICMS Efetivo---//
                    If cTipoDoc != 'D'
                        nVlrICMEfe := Round(((nVlrBICMS*nAliqInt)/100),2)
                    Else
                        nVlrICMEfe := (aDocOriApu[5]/aDocOriApu[2])*nQtdade
                    EndIf

                    //---Alimenta objeto o1200---//
                    Self:o1200:Inc1200(cTipoDoc,nQtdade,nVlrICMEfe)

                ElseIf cTipoOper == '13' //---13 – Saídas interestaduais---//

                    //---Define o ICMS Efetivo---//
                    If cTipoDoc != 'D'
                        nVlrICMEfe := nVlrICMS
                    Else
                        nVlrICMEfe := (aDocOriApu[5]/aDocOriApu[2])*nQtdade
                    EndIf

                    //---Alimenta objeto o1300---//
                    Self:o1300:Inc1300(cTipoDoc,nQtdade,nVlrICMEfe)

                ElseIf cTipoOper == '14' //---14 – Saídas internas Art. 119---//

                    //---Define o ICMS Efetivo---//
                    If cTipoDoc != 'D'
                        nVlrICMEfe := Round(((nVlrBICMS*nAliqInt)/100),2)
                    Else
                        nVlrICMEfe := (aDocOriApu[5]/aDocOriApu[2])*nQtdade
                    EndIf

                    //---Alimenta objeto o1400---//
                    Self:o1400:Inc1400(cTipoDoc,nQtdade,nVlrICMEfe)

                ElseIf cTipoOper == '15' //---15 – Saídas internas destinadas a contribuintes do Simples Nacional---//

                    //---Alimenta objeto o1500---//
                    Self:o1500:Inc1500(cTipoDoc,nQtdade)

                EndIf

                //---Controla a Gravação do Movimento---//
                Self:oMovimento:SetGrvMov(.T.)
                Self:oMovimento:SetOrdMov(Self:oMovimento:GetOrdMov()+1)

            EndIf

        EndIf

        //---Carrega os valores apurados para o movimento---//
        If (cTipoMov=='E' .And. cTipoDoc != 'D') .Or. (cTipoMov=='S' .And. cTipoDoc == 'D')

            Self:oMovimento:SetTpOper('')
            Self:oMovimento:SetICMEfe(0)
            Self:oMovimento:SetICMSSu(nVlrICMSSu)
            Self:oMovimento:SetRespRet(cRespRet)

        ElseIf (cTipoMov=='S' .And. cTipoDoc != 'D') .Or. (cTipoMov=='E' .And. cTipoDoc == 'D')

            Self:oMovimento:SetTpOper(cTipoOper)
            Self:oMovimento:SetICMEfe(nVlrICMEfe)
            Self:oMovimento:SetICMSSu(0)
            Self:oMovimento:SetRespRet('')

        EndIf
        //---FIM Carrega os valores apurados para o movimento---//

    Else
        Self:ClearProd()
    EndIf

Return


//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} ApuraProd()
  
Método responsável por calcular totais do produto nos objetos o1100, o1200, o1300, o1400, o1500 e 
alimentar o objeto o9000.

@author Ulisses P. Oliveira
@since 30/03/2020
@version 1.0
/*/
//--------------------------------------------------------------------------------------------------
Method ApuraProd(nQtdTotAnt,nQtdPerAnt) Class FISA240APURACAO
    Local cAnoMes    := Self:GetAnoMes()

    Local cCodItem   := Self:o1000:Get1000B03()
    Local nAliqInt   := Self:o1000:Get1000B10()
    Local nAliqFec   := Self:o1000:Get1000B11()

    Local nSQtde1100 := Self:o1100:Get1100D02()
    Local nSBICMST   := Self:o1100:Get1100DSB()
    Local nSVlICMSSu := Self:o1100:Get1100D05()
    Local nVlrMenUni := Self:o1100:Get1100D03()
    Local nVlUEAICMS := Self:o1100:Get1100DAL()
    Local nVlUEMVAOp := Self:o1100:Get1100DMV()

    Local nSQtde1200 := Self:o1200:Get1200F02()
    Local nSEfet1200 := Self:o1200:Get1200F03()

    Local nSQtde1300 := Self:o1300:Get1300H02()
    Local nSEfet1300 := Self:o1300:Get1300H03()

    Local nSQtde1400 := Self:o1400:Get1400J02()
    Local nSEfet1400 := Self:o1400:Get1400J03()

    Local nSQtde1500 := Self:o1500:Get1500L02()
    Local nSQtdM1500 := Self:o1500:Get1500LSM()

    //---Objeto o1100---//
    Local nVlrMUnBST := 0
    Local nVlrMUnSup := 0

    //---Objeto o1200---//
    Local nVlrCo1200 := 0
    Local nVlDRe1200 := 0
    Local nVlDCo1200 := 0
    Local nVIRes1200 := 0
    Local nVICmp1200 := 0
    Local nVFRes1200 := 0
    Local nVFCmp1200 := 0

    //---Objeto o1300---//
    Local nVlrCo1300 := 0
    Local nVlDRe1300 := 0
    Local nVIRes1300 := 0
    Local nVFRes1300 := 0

    //---Objeto o1400---//
    Local nVlrCo1400 := 0
    Local nVIRes1400 := 0

    //---Objeto o1500---//
    Local nVlrICMSUn := 0
    Local nVIRes1500 := 0
    Local nVlrAICMS  := 0
    Local nPerRedMVA := 0
    Local nVlrRessSN := 0
    Local nCount     := 0
    Local nPos       := 0

    Local oMovEntr   := Nil
    Local aSBCICMSST := {}
    

    //------------------------------------------------------------------------------------------------------------------------------------------------------//
    /* Verificação de Quantidade de Entradas X Quantidades de Saída
    
       Norma de Procedimento Fiscal nº 003/2020 publicado em 28/01/2020:
       SEÇÃO I 
       Subseção II
       Art. 9.º
       § 4.º Sempre que a quantidade das entradas de cada item de mercadoria for menor que o somatório das saídas, será obrigatória a adição das entradas 
             ocorridas no período de referência anterior ou anteriores, suficientes para comportar a quantidade que saiu da mesma mercadoria.  

    */
    //------------------------------------------------------------------------------------------------------------------------------------------------------//
    If nSQtde1100 < (nSQtde1200 + nSQtde1300 + nSQtde1400 + nSQtde1500)

        If nQtdPerAnt >= (nSQtde1200 + nSQtde1300 + nSQtde1400 + nSQtde1500) - nSQtde1100

            oMovEntr := FISA240MOVIMENTOENTRADA():New()
            oMovEntr:cTipoRet   := '2' //---Base de Cálculo ICMS-ST / Valor ICMS Suportado / Valor Menor Unitário / Quantidade (Somatórios para cálculo de média)---//
            oMovEntr:cCodProd   := cCodItem
            oMovEntr:nQtdade    := (nSQtde1200 + nSQtde1300 + nSQtde1400 + nSQtde1500) - nSQtde1100
            oMovEntr:nQtdadeAnt := nQtdPerAnt
            oMovEntr:dDataMov   := StoD(cAnoMes+'01')-1
            oMovEntr:nAliqInt   := nAliqInt
            oMovEntr:cIdApur    := Self:GetIdApur()
            oMovEntr:cAnoMes    := cAnoMes
            oMovEntr:nOrdMovAtu := Self:oMovimento:GetOrdMov()
            oMovEntr:ProcUltEnt()
            aSBCICMSST := oMovEntr:aSBCICMSST
            FreeObj(oMovEntr)

            nSBICMST   += aSBCICMSST[1]                                                                                             //---Base de Cálculo ICMS-ST---//
            nSVlICMSSu += aSBCICMSST[2]                                                                                             //---Valor ICMS Suportado---//
            nVlrMenUni := Iif(nVlrMenUni == 0 .Or. (nVlrMenUni > aSBCICMSST[3] .And. aSBCICMSST[3] > 0), aSBCICMSST[3], nVlrMenUni) //---Valor Menor Unitário---//
            nSQtde1100 += aSBCICMSST[4]                                                                                             //---Quantidade---//
            nVlUEAICMS := Iif(nVlUEAICMS > 0 .And. nVlUEMVAOp > 0, nVlUEAICMS, aSBCICMSST[5])                                       //---Alíquota ICMS Próprio Última Entrada---//
            nVlUEMVAOp := Iif(nVlUEAICMS > 0 .And. nVlUEMVAOp > 0, nVlUEMVAOp, aSBCICMSST[6])                                       //---MVA Última Entrada ---//

            Self:o1100:Set1100D02(nSQtde1100)
            Self:o1100:Set1100DSB(nSBICMST)
            Self:o1100:Set1100D05(nSVlICMSSu)
            Self:o1100:Set1100D03(nVlrMenUni)
            Self:o1100:Set1100DMV(nVlUEMVAOp)

        EndIf

    EndIf

    //---Calcula campos do objeto o1100---//
    nVlrMUnBST := Round((nSBICMST / nSQtde1100),2)                         //---[D04] Resultado da somatória dos campos E16, menos a somatória dos campos E15d, dividido pelo campo D02---//
    nVlrMUnSup := Round((nSVlICMSSu / nSQtde1100),2)                       //---[D06] Resultado da divisão do campo D05 pelo campo D02 ---//
    Self:o1100:Set1100D04(nVlrMUnBST)
    Self:o1100:Set1100D06(nVlrMUnSup)

    //---Calcula campos do objeto o1200---//
    nVlrCo1200 := Round((nSQtde1200 * nVlrMUnSup),2)                       //---[F04] Equação representada pelos campos: F04 = F02 * D06---//

    If nVlrCo1200 > nSEfet1200
        nVlDRe1200 := nVlrCo1200 - nSEfet1200                              //---[F05] Obtido pela equação F05 = F04 - F03, quando o resultado for positivo. Quando o resultado for negativo deve ser preenchido com zero---//
    ElseIf nVlrCo1200 > 0
        nVlDCo1200 := nSEfet1200 - nVlrCo1200                              //---[F06] Obtido pela equação F05 = F04 - F03, quando o resultado for negativo. Quando o resultado for positivo deve ser preenchido com zero---//
    EndIf

    nVIRes1200 := Round(nVlDRe1200 * ((nAliqInt - nAliqFec) / nAliqInt),2) //---[F07] Equação representada pelos campos: F07 = F05 * ((B10 - B11)/B10)---//
    nVICmp1200 := Round(nVlDCo1200 * ((nAliqInt - nAliqFec) / nAliqInt),2) //---[F08] Equação representada pelos campos: F08 = F06 * ((B10 - B11)/B10)---//
    nVFRes1200 := Round(nVlDRe1200 * (nAliqFec / nAliqInt),2)              //---[F09] Equação representada pelos campos: F09 = F05 * (B11/B10)---//
    nVFCmp1200 := Round(nVlDCo1200 * (nAliqFec / nAliqInt),2)              //---[F10] Equação representada pelos campos: F10 = F6 * (B11/B10)---//

    Self:o1200:Set1200F04(nVlrCo1200)
    Self:o1200:Set1200F05(nVlDRe1200)
    Self:o1200:Set1200F06(nVlDCo1200)
    Self:o1200:Set1200F07(nVIRes1200)
    Self:o1200:Set1200F08(nVICmp1200)
    Self:o1200:Set1200F09(nVFRes1200)
    Self:o1200:Set1200F10(nVFCmp1200)

    //---Calcula campos do objeto o1300---//
    nVlrCo1300 := Round((nSQtde1300 * nVlrMUnSup),2)                       //---[H04] Equação representada pelos campos: H04 = H02 * D06---//
    If Self:cVAr01  == '0'
       nVlDRe1300 := nVlrCo1300  
    ElseIf nVlrCo1300 > nSEfet1300
        nVlDRe1300 := nVlrCo1300 - nSEfet1300                             //---[H05] Equação representada pela diferença positiva da equação: H05 = H04 – H03---//
    EndIf

    nVFRes1300 := Round(((nVlrMUnBST * nAliqFec)/100) * nSQtde1300,2)      //---[H07] Equação representada pelos campos: H07 = (D04 * B11) * H02---//
    nVIRes1300 := nVlDRe1300 - nVFRes1300                                  //---[H06] Equação representada pelos campos: H06 = H05 - H07---//
    Self:o1300:Set1300H04(nVlrCo1300)
    Self:o1300:Set1300H05(nVlDRe1300)
    Self:o1300:Set1300H06(nVIRes1300)
    Self:o1300:Set1300H07(nVFRes1300)

    //---Calcula campos do objeto o1400---//
    nVlrCo1400 := Round((nSQtde1400 * nVlrMUnSup),2)                       //---[J04] Equação representada pelos campos: J04 = J02 * D06---//

    If nVlrCo1400 > nSEfet1400
        nVIRes1400 := nVlrCo1400 - nSEfet1400                              //---[J05] Equação representada pela diferença positiva da equação: J05 = J04 – J03---//
    EndIf
    Self:o1400:Set1400J04(nVlrCo1400)
    Self:o1400:Set1400J05(nVIRes1400)

    //---Calcula campos do objeto o1500---//
    If nSQtdM1500 > 0 .And. nVlUEAICMS > 0 .And. nVlUEMVAOp > 0

        //------------------------------------------------------------------------------------------------------------------------------------------------------//
        /*  Art. 15 do Anexo IX do RCIMS/17
           
            O contribuinte substituído que promover saída, em operação interna destinada a contribuinte optante pelo regime do Simples Nacional, de mercadorias a 
            que se referem as Seções VI, VII, XVIII e XXII, recebidas com o imposto retido calculado com a aplicação do percentual da MVA previsto na legislação, 
            poderá, observado o disposto nos artigos  6º e 7º deste Anexo, recuperar em conta gráfica, mediante utilização do código de ajuste da apuração PR020222 
            na EFD ou ressarcir-se junto a qualquer estabelecimento de fornecedor que seja eleito substituto tributário, do valor obtido a partir do seguinte cálculo:

            I -  exclusão da parcela correspondente à MVA utilizada para cálculo do imposto retido, da base de cálculo utilizada para determinação do imposto devido 
                 por Substituição Tributária - ST;
            II - aplicação, sobre o valor remanescente após a exclusão da parcela correspondente à MVA utilizada para cálculo do imposto retido, de acordo com o inciso I 
                 do "caput", dos coeficientes correspondentes a:
                 a) 70% (setenta por cento) do percentual da MVA utilizado pelo substituto, para as operações tributadas à alíquota igual ou superior a 18% (dezoito por cento);
                 b) 50% (cinquenta por cento) do percentual da MVA utilizado pelo substituto, nos demais casos.
            III - aplicação, sobre o valor obtido de acordo com as alíneas "a" e "b" do inciso II do "caput", da alíquota interna incidente sobre a mercadoria.
            § 1.º Sempre que houver benefício fiscal na operação interna deverá ser aplicado o percentual de redução de que trata a alínea "b" do inciso II do "caput".
            § 2.º Para efeitos do disposto neste artigo deverá ser considerada a situação cadastral do contribuinte na data da realização da operação pelo substituto.

            MANUAL DO ARQUIVO DIGITAL DA ST / Registro 1500 / Campo L03:

            Valor obtido a partir do seguinte cálculo:
            (D04 /(1+MVA)) x (MVA/Coeficiente) x (B10)

            Onde:
            -D04 é o campo VL_BC_ICMSST_UNIT_MED;
            -MVA é a MVA utilizada para retenção do ICMS ST;
            -Coeficiente é o percentual de redução a ser aplicado sobre a MVA (70% se alíquota de 18%, 50% se alíquota de 12%);
            -B10 é campo ALIQ_INTERNA

        */
        //------------------------------------------------------------------------------------------------------------------------------------------------------//

        //---Verifica percentual de redução da MVA da operação de acordo com a alíquota aplicada---//
        If Len(Self:aPerRedMVA) > 0
            For nCount := 1 To Len(Self:aPerRedMVA)
                nPos := At('=',Self:aPerRedMVA[nCount])
                If nPos > 0
                    nVlrAICMS := Val(SubStr(Self:aPerRedMVA[nCount], 1, nPos-1))
                    If nVlrAICMS == nVlUEAICMS
                        nPerRedMVA := Val(SubStr(Self:aPerRedMVA[nCount], nPos+1, Len(Self:aPerRedMVA[nCount])))
                    EndIf
                EndIf
            Next nCount
        EndIf

        //---Calcular o Valor de Ressarcimento---//
        //---                   (D04        / (1 +  MVA              )) x  (MVA             * Coeficiente       ) x (B10           )
        If nPerRedMVA > 0
            nVlrRessSN := Round((nVlrMUnBST / (1 + (nVlUEMVAOp / 100))) * ((nVlUEMVAOp/100) * (nPerRedMVA / 100)) * (nAliqInt / 100),2)
        EndIf

        nVlrICMSUn := nVlrRessSN                                           //---[L03] Valor obtido a partir do seguinte cálculo: (D04 /(1+MVA)) x (MVA/Coeficiente) x (B10) -> Deverá observar a forma de cálculo prevista no art. 15 do Anexo IX do RCIMS/17---//
    EndIf

    nVIRes1500 := Round(nSQtde1500 * nVlrICMSUn,2)                         //---[L04] Equação representada pelos campos: L04 = L02 * L03---//
    Self:o1500:Set1500L03(nVlrICMSUn)
    Self:o1500:Set1500L04(nVIRes1500)
    //---Alimenta objeto o9000---//
    Self:o9000:Inc9000(Self:o1200,Self:o1300,Self:o1400,Self:o1500)

Return


//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} ApuraPer()
  
Método responsável por calcular totais da apuração no objeto o9000.

@author Ulisses P. Oliveira
@since 30/03/2020
@version 1.0
/*/
//--------------------------------------------------------------------------------------------------
Method ApuraPer() Class FISA240APURACAO
    Local nS1200CF07 := Self:o9000:Get1200F07()
    Local nS1200CF08 := Self:o9000:Get1200F08()
    Local nS1200CF09 := Self:o9000:Get1200F09()
    Local nS1200CF10 := Self:o9000:Get1200F10()
    Local nS1300CH07 := Self:o9000:Get1300H07()
    Local nS1300IRes := Self:o9000:Get9000X04()
    Local nS1400IRes := Self:o9000:Get9000X05()
    Local nS1500IRes := Self:o9000:Get9000X06()
    Local nS1200IRes := 0
    Local nS1200ICom := 0
    Local nS9000FRes := 0
    Local nS9000FCom := 0
    Local nVlApCrICM := 0
    Local nVlApICMCp := 0

    //---Calcula campos do objeto o9000---//
    If nS1200CF07 > nS1200CF08
        nS1200IRes := (nS1200CF07 - nS1200CF08)              //---[X02] Equação representada pela diferença positiva da equação: X02 = ?[F07] – ?[F08]
    Else
        nS1200ICom := (nS1200CF08 - nS1200CF07)              //---[X03] Equação representada pela diferença negativa da equação: X02 = ?[F07] – ?[F08
    EndIf

    If nS1200CF09 + nS1300CH07 - nS1200CF10 > 0
        nS9000FRes := (nS1200CF09 + nS1300CH07 - nS1200CF10) //---[X07] Equação representada pela diferença positiva da equação: X07 = ?[F09] + ?[H07] – ?[F10]
    Else
        nS9000FCom := (nS1200CF10 - nS1200CF09 + nS1300CH07) //---[X08] Equação representada pela negativa da equação:           X07 = ?[F09] + ?[H07] – ?[F10]
    EndIf

    If (nS1200IRes + nS1300IRes + nS1400IRes + nS1500IRes) > nS1200ICom
        nVlApCrICM := (nS1200IRes + nS1300IRes + nS1400IRes + nS1500IRes) - nS1200ICom //---[XXX] Valor Total de Crédito de ICMS
    Else
        nVlApICMCp := nS1200ICom - (nS1200IRes + nS1300IRes + nS1400IRes + nS1500IRes) //---[XXX]  Valor Total de Complemento de ICMS
    EndIf

    Self:o9000:Set9000X02(nS1200IRes)
    Self:o9000:Set9000X03(nS1200ICom)
    Self:o9000:Set9000X07(nS9000FRes)
    Self:o9000:Set9000X08(nS9000FCom)
    Self:o9000:SetApCrICM(nVlApCrICM)
    Self:o9000:SetApICMCp(nVlApICMCp)
    If nS1200ICom > 0 .And. Self:cVAr04 <> '2'
        Self:cVAr04 := '2'
    EndIf
Return


//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} ClearProd()
  
Método responsável por limpar os valores dos objetos o1100 / o1200 / o1300 / o1400 / o1500 a cada 
produto processado.

@author Ulisses P. Oliveira
@since 30/03/2020
@version 1.0
/*/
//--------------------------------------------------------------------------------------------------
Method ClearProd() Class FISA240APURACAO
    Self:o1000:Clear1000()
    Self:o1100:Clear1100()
    Self:o1200:Clear1200()
    Self:o1300:Clear1300()
    Self:o1400:Clear1400()
    Self:o1500:Clear1500()
    Self:oMovimento:SetOrdMov(0)
Return


//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} Getters e Setters

@author Ulisses P. Oliveira
@since 26/03/2020
@version 1.0
/*/
//--------------------------------------------------------------------------------------------------
Method SetAnoMes(cAnoMes)  Class FISA240APURACAO
    Self:cAnoMes := cAnoMes
Return

Method GetIdApur() Class FISA240APURACAO
Return Self:cIdApur

Method GetAnoMes() Class FISA240APURACAO
Return Self:cAnoMes

Method GetIniReCo() Class FISA240APURACAO
Return Self:aDtIniReCo


//==================================================================================================
/*/{Protheus.doc} Classe FISA2401000

Classe responsável pelo controle do Registro 1000. 
 
@author Ulisses P. Oliveira
@since 30/03/2020
@version 1.0
/*/
//==================================================================================================
CLASS FISA2401000 FROM LongNameClass

Data cCodProd       As Character //--- ---//
Data nAliqInt       As Numeric   //--- ---//
Data nAliqFec       As Numeric   //--- ---//

Method New() CONSTRUCTOR
Method Clear1000()

//---Getters e Setters---//
Method Set1000B03(cCodProd)
Method Set1000B10(nAliqInt)
Method Set1000B11(nAliqFec)

Method Get1000B03()
Method Get1000B10()
Method Get1000B11()

ENDCLASS


//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} New()
  
Método construtor da Classe FISA2401000

@author Ulisses P. Oliveira
@since 30/03/2020
@version 1.0
/*/
//--------------------------------------------------------------------------------------------------
Method New() Class FISA2401000
	Self:Clear1000()
Return Self


//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} Clear1000
  
Método que limpa os valores do objeto.

@author Ulisses P. Oliveira
@since 30/03/2020
@version 1.0
/*/
//--------------------------------------------------------------------------------------------------
Method Clear1000() Class FISA2401000
    Self:cCodProd := ''
	Self:nAliqInt := 0
	Self:nAliqFec := 0
Return


//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} Getters e Setters

@author Ulisses P. Oliveira
@since 30/03/2020
@version 1.0
/*/
//--------------------------------------------------------------------------------------------------
Method Set1000B03(cCodProd) Class FISA2401000
    Self:cCodProd := cCodProd
Return

Method Set1000B10(nAliqInt) Class FISA2401000
    Self:nAliqInt := nAliqInt
Return

Method Set1000B11(nAliqFec) Class FISA2401000
    Self:nAliqFec := nAliqFec
Return

Method Get1000B03() Class FISA2401000
Return Self:cCodProd

Method Get1000B10() Class FISA2401000
Return Self:nAliqInt

Method Get1000B11() Class FISA2401000
Return Self:nAliqFec


//==================================================================================================
/*/{Protheus.doc} Classe FISA2401100

Classe responsável pelo controle do Registro 1100. 
 
@author Ulisses P. Oliveira
@since 27/03/2020
@version 1.0
/*/
//==================================================================================================
CLASS FISA2401100 FROM LongNameClass

Data nSQtde         As Numeric   //--- ---//
Data nVlrMenUni     As Numeric   //--- ---//
Data nSBICMST       As Numeric   //--- ---//
Data nVlrMUnBST     As Numeric   //--- ---//
Data nSVlICMSSu     As Numeric   //--- ---//
Data nVlrMUnSup     As Numeric   //--- ---//
Data nVlUEAICMS     As Numeric   //--- ---//
Data nVlUEMVAOp     As Numeric   //--- ---//

Method New() CONSTRUCTOR
Method Clear1100()
Method Inc1100(cTipoDoc,nQtdade,nVlrBICMST,nVlrICMSSu,nVlrUnit,nVlrAICMS,nVlrMVAOp)

//---Getters e Setters---//
Method Set1100D02(nSQtde)
Method Set1100D03(nVlrMenUni)
Method Set1100DSB(nSBICMST)
Method Set1100D04(nVlrMUnBST)
Method Set1100D05(nSVlICMSSu)
Method Set1100D06(nVlrMUnSup)
Method Set1100DAL(nVlUEAICMS)
Method Set1100DMV(nVlUEMVAOp)

Method Get1100D02()
Method Get1100D03()
Method Get1100DSB()
Method Get1100D04()
Method Get1100D05()
Method Get1100D06()
Method Get1100DAL()
Method Get1100DMV()

ENDCLASS


//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} New()
  
Método construtor da Classe FISA2401100

@author Ulisses P. Oliveira
@since 27/03/2020
@version 1.0
/*/
//--------------------------------------------------------------------------------------------------
Method New() Class FISA2401100
	Self:Clear1100()
Return Self


//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} Clear1100
  
Método que limpa os valores do objeto.

@author Ulisses P. Oliveira
@since 27/03/2020
@version 1.0
/*/
//--------------------------------------------------------------------------------------------------
Method Clear1100() Class FISA2401100
	Self:nSQtde     := 0
	Self:nVlrMenUni := 0
	Self:nSBICMST   := 0
	Self:nVlrMUnBST := 0
    Self:nSVlICMSSu := 0
    Self:nVlrMUnSup := 0
    Self:nVlUEAICMS := 0
    Self:nVlUEMVAOp := 0
Return


//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} Inc1100()
  


@author Ulisses P. Oliveira
@since 27/03/2020
@version 1.0
/*/
//--------------------------------------------------------------------------------------------------
Method Inc1100(cTipoDoc,nQtdade,nVlrBICMST,nVlrICMSSu,nVlrUnit,nVlrAICMS,nVlrMVAOp) Class FISA2401100
    Local nSQtde     := Self:Get1100D02()
    Local nSBICMST   := Self:Get1100DSB()
    Local nSVlICMSSu := Self:Get1100D05()
    Local nVlrMenUni := Self:Get1100D03()
    Local nVlUEAICMS := Self:Get1100DAL()
    Local nVlUEMVAOp := Self:Get1100DMV()

    If cTipoDoc != 'D'
        nSQtde     += nQtdade
        nSBICMST   += nVlrBICMST
        nSVlICMSSu += nVlrICMSSu
        nVlrMenUni := Iif(nVlrMenUni == 0, nVlrUnit, Iif(nVlrMenUni > nVlrUnit, nVlrUnit, nVlrMenUni))
        nVlUEAICMS := Iif(nVlrAICMS > 0 .And. nVlrMVAOp > 0, nVlrAICMS, nVlUEAICMS)
        nVlUEMVAOp := Iif(nVlrAICMS > 0 .And. nVlrMVAOp > 0, nVlrMVAOp, nVlUEMVAOp)
    Else
        nSQtde     -= nQtdade
        nSBICMST   -= nVlrBICMST
        nSVlICMSSu -= nVlrICMSSu
    EndIf

	Self:Set1100D02(nSQtde)
	Self:Set1100DSB(nSBICMST)
	Self:Set1100D05(nSVlICMSSu)
    Self:Set1100D03(nVlrMenUni)
    Self:Set1100DAL(nVlUEAICMS)
    Self:Set1100DMV(nVlUEMVAOp)

Return


//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} Getters e Setters

@author Ulisses P. Oliveira
@since 27/03/2020
@version 1.0
/*/
//--------------------------------------------------------------------------------------------------
Method Set1100D02(nSQtde) Class FISA2401100
    Self:nSQtde := nSQtde
Return

Method Set1100D03(nVlrMenUni) Class FISA2401100
    Self:nVlrMenUni := nVlrMenUni
Return

Method Set1100DSB(nSBICMST) Class FISA2401100
    Self:nSBICMST := nSBICMST
Return

Method Set1100D04(nVlrMUnBST) Class FISA2401100
    Self:nVlrMUnBST := nVlrMUnBST
Return

Method Set1100D05(nSVlICMSSu) Class FISA2401100
    Self:nSVlICMSSu := nSVlICMSSu
Return

Method Set1100D06(nVlrMUnSup) Class FISA2401100
    Self:nVlrMUnSup := nVlrMUnSup
Return

Method Set1100DAL(nVlUEAICMS) Class FISA2401100
    Self:nVlUEAICMS := nVlUEAICMS
Return

Method Set1100DMV(nVlUEMVAOp) Class FISA2401100
    Self:nVlUEMVAOp := nVlUEMVAOp
Return

Method Get1100D02() Class FISA2401100
Return Self:nSQtde

Method Get1100D03() Class FISA2401100
Return Self:nVlrMenUni

Method Get1100DSB() Class FISA2401100
Return Self:nSBICMST

Method Get1100D04() Class FISA2401100
Return Self:nVlrMUnBST

Method Get1100D05() Class FISA2401100
Return Self:nSVlICMSSu

Method Get1100D06() Class FISA2401100
Return Self:nVlrMUnSup

Method Get1100DAL() Class FISA2401100
Return Self:nVlUEAICMS

Method Get1100DMV() Class FISA2401100
Return Self:nVlUEMVAOp


//==================================================================================================
/*/{Protheus.doc} Classe FISA2401200

Classe responsável pelo controle do Registro 1200. 
 
@author Ulisses P. Oliveira
@since 27/03/2020
@version 1.0
/*/
//==================================================================================================
CLASS FISA2401200 FROM LongNameClass

Data nSQtde      As Numeric   //--- ---//
Data nSICMEfet   As Numeric   //--- ---//
Data nVlrICMSCo  As Numeric   //--- ---//
Data nVlDRecRes  As Numeric   //--- ---//
Data nVlDCompl   As Numeric   //--- ---//
Data nVlICMSTRe  As Numeric   //--- ---//
Data nVlICMSTCp  As Numeric   //--- ---//
Data nVlFECOPRe  As Numeric   //--- ---//
Data nVlFECOPCp  As Numeric   //--- ---//


Method New() CONSTRUCTOR
Method Clear1200()
Method Inc1200(cTipoDoc,nQtdade,nVlrICMEfe)

//---Getters e Setters---//
Method Set1200F02(nSQtde)
Method Set1200F03(nSICMEfet)
Method Set1200F04(nVlrICMSCo)
Method Set1200F05(nVlDRecRes)
Method Set1200F06(nVlDCompl)
Method Set1200F07(nVlICMSTRe)
Method Set1200F08(nVlICMSTCp)
Method Set1200F09(nVlFECOPRe)
Method Set1200F10(nVlFECOPCp)
Method Get1200F02()
Method Get1200F03()
Method Get1200F04()
Method Get1200F05()
Method Get1200F06()
Method Get1200F07()
Method Get1200F08()
Method Get1200F09()
Method Get1200F10()

ENDCLASS

//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} New()
  
Método construtor da Classe FISA2401200

@author Ulisses P. Oliveira
@since 27/03/2020
@version 1.0
/*/
//--------------------------------------------------------------------------------------------------
Method New() Class FISA2401200
	Self:Clear1200()
Return Self


//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} Clear1200
  
Método que limpa os valores do objeto.

@author Ulisses P. Oliveira
@since 27/03/2020
@version 1.0
/*/
//--------------------------------------------------------------------------------------------------
Method Clear1200() Class FISA2401200
	Self:nSQtde     := 0
	Self:nSICMEfet  := 0
	Self:nVlrICMSCo := 0
	Self:nVlDRecRes := 0
    Self:nVlDCompl  := 0
    Self:nVlICMSTRe := 0
    Self:nVlICMSTCp := 0
	Self:nVlFECOPRe := 0
	Self:nVlFECOPCp := 0	
Return


//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} Inc1200()
  


@author Ulisses P. Oliveira
@since 27/03/2020
@version 1.0
/*/
//--------------------------------------------------------------------------------------------------
Method Inc1200(cTipoDoc,nQtdade,nVlrICMEfe) Class FISA2401200
    Local nSQtde     := Self:Get1200F02()
    Local nSICMEfet  := Self:Get1200F03()

    If cTipoDoc != 'D'
        nSQtde    += nQtdade
        nSICMEfet += nVlrICMEfe
    Else
        nSQtde    -= nQtdade
        nSICMEfet -= nVlrICMEfe
    EndIf

    Self:Set1200F02(nSQtde)
    Self:Set1200F03(nSICMEfet)

Return


//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} Getters e Setters

@author Ulisses P. Oliveira
@since 27/03/2020
@version 1.0
/*/
//--------------------------------------------------------------------------------------------------
Method Set1200F02(nSQtde) Class FISA2401200
    Self:nSQtde := nSQtde
Return

Method Set1200F03(nSICMEfet) Class FISA2401200
    Self:nSICMEfet := nSICMEfet
Return

Method Set1200F04(nVlrICMSCo) Class FISA2401200
    Self:nVlrICMSCo := nVlrICMSCo
Return

Method Set1200F05(nVlDRecRes) Class FISA2401200
    Self:nVlDRecRes := nVlDRecRes
Return

Method Set1200F06(nVlDCompl) Class FISA2401200
    Self:nVlDCompl := nVlDCompl
Return

Method Set1200F07(nVlICMSTRe) Class FISA2401200
    Self:nVlICMSTRe := nVlICMSTRe
Return

Method Set1200F08(nVlICMSTCp) Class FISA2401200
    Self:nVlICMSTCp := nVlICMSTCp
Return

Method Set1200F09(nVlFECOPRe) Class FISA2401200
    Self:nVlFECOPRe := nVlFECOPRe
Return

Method Set1200F10(nVlFECOPCp) Class FISA2401200
    Self:nVlFECOPCp := nVlFECOPCp
Return

Method Get1200F02() Class FISA2401200
Return Self:nSQtde

Method Get1200F03() Class FISA2401200
Return Self:nSICMEfet

Method Get1200F04() Class FISA2401200
Return Self:nVlrICMSCo

Method Get1200F05() Class FISA2401200
Return Self:nVlDRecRes

Method Get1200F06() Class FISA2401200
Return Self:nVlDCompl

Method Get1200F07() Class FISA2401200
Return Self:nVlICMSTRe

Method Get1200F08() Class FISA2401200
Return Self:nVlICMSTCp

Method Get1200F09() Class FISA2401200
Return Self:nVlFECOPRe

Method Get1200F10() Class FISA2401200
Return Self:nVlFECOPCp


//==================================================================================================
/*/{Protheus.doc} Classe FISA2401300

Classe responsável pelo controle do Registro 1300.
 
@author Ulisses P. Oliveira
@since 27/03/2020
@version 1.0
/*/
//==================================================================================================
CLASS FISA2401300 FROM LongNameClass

Data nSQtde      As Numeric   //--- ---//
Data nSICMEfet   As Numeric   //--- ---//
Data nVlrICMSCo  As Numeric   //--- ---//
Data nVlDRecRes  As Numeric   //--- ---//
Data nVlICMSTRe  As Numeric   //--- ---//
Data nVlFECOPRe  As Numeric   //--- ---//

Method New() CONSTRUCTOR
Method Clear1300()
Method Inc1300(cTipoDoc,nQtdade,nVlrICMEfe)

//---Getters e Setters---//
Method Set1300H02(nSQtde)
Method Set1300H03(nSICMEfet)
Method Set1300H04(nVlrICMSCo)
Method Set1300H05(nVlDRecRes)
Method Set1300H06(nVlICMSTRe)
Method Set1300H07(nVlFECOPRe)
Method Get1300H02()
Method Get1300H03()
Method Get1300H04()
Method Get1300H05()
Method Get1300H06()
Method Get1300H07()

ENDCLASS

//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} New()
  
Método construtor da Classe FISA2401300

@author Ulisses P. Oliveira
@since 27/03/2020
@version 1.0
/*/
//--------------------------------------------------------------------------------------------------
Method New() Class FISA2401300
	Self:Clear1300()
Return Self


//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} Clear1300
  
Método que limpa os valores do objeto.

@author Ulisses P. Oliveira
@since 27/03/2020
@version 1.0
/*/
//--------------------------------------------------------------------------------------------------
Method Clear1300() Class FISA2401300
	Self:nSQtde     := 0
	Self:nSICMEfet  := 0
	Self:nVlrICMSCo := 0
	Self:nVlDRecRes := 0
    Self:nVlICMSTRe := 0
    Self:nVlFECOPRe := 0
Return


//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} Inc1300()
  


@author Ulisses P. Oliveira
@since 27/03/2020
@version 1.0
/*/
//--------------------------------------------------------------------------------------------------
Method Inc1300(cTipoDoc,nQtdade,nVlrICMEfe) Class FISA2401300
    Local nSQtde     := Self:Get1300H02()
    Local nSICMEfet  := Self:Get1300H03()

    If cTipoDoc != 'D'
        nSQtde    += nQtdade
        nSICMEfet += nVlrICMEfe
    Else
        nSQtde    -= nQtdade
        nSICMEfet -= nVlrICMEfe
    EndIf

    Self:Set1300H02(nSQtde)
    Self:Set1300H03(nSICMEfet)

Return


//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} Getters e Setters

@author Ulisses P. Oliveira
@since 27/03/2020
@version 1.0
/*/
//--------------------------------------------------------------------------------------------------
Method Set1300H02(nSQtde) Class FISA2401300
    Self:nSQtde := nSQtde
Return

Method Set1300H03(nSICMEfet) Class FISA2401300
    Self:nSICMEfet := nSICMEfet
Return

Method Set1300H04(nVlrICMSCo) Class FISA2401300
    Self:nVlrICMSCo := nVlrICMSCo
Return

Method Set1300H05(nVlDRecRes) Class FISA2401300
    Self:nVlDRecRes := nVlDRecRes
Return

Method Set1300H06(nVlICMSTRe) Class FISA2401300
    Self:nVlICMSTRe := nVlICMSTRe
Return

Method Set1300H07(nVlFECOPRe) Class FISA2401300
    Self:nVlFECOPRe := nVlFECOPRe
Return

Method Get1300H02() Class FISA2401300
Return Self:nSQtde

Method Get1300H03() Class FISA2401300
Return Self:nSICMEfet

Method Get1300H04() Class FISA2401300
Return Self:nVlrICMSCo

Method Get1300H05() Class FISA2401300
Return Self:nVlDRecRes

Method Get1300H06() Class FISA2401300
Return Self:nVlICMSTRe

Method Get1300H07() Class FISA2401300
Return Self:nVlFECOPRe


//==================================================================================================
/*/{Protheus.doc} Classe FISA2401400

Classe responsável pelo controle do Registro 1400.
 
@author Ulisses P. Oliveira
@since 27/03/2020
@version 1.0
/*/
//==================================================================================================
CLASS FISA2401400 FROM LongNameClass

Data nSQtde      As Numeric   //--- ---//
Data nSICMEfet   As Numeric   //--- ---//
Data nVlrICMSCo  As Numeric   //--- ---//
Data nVlICMSTRe  As Numeric   //--- ---//

Method New() CONSTRUCTOR
Method Clear1400()
Method Inc1400(cTipoDoc,nQtdade,nVlrICMEfe)

//---Getters e Setters---//
Method Set1400J02(nSQtde)
Method Set1400J03(nSICMEfet)
Method Set1400J04(nVlrICMSCo)
Method Set1400J05(nVlICMSTRe)
Method Get1400J02()
Method Get1400J03()
Method Get1400J04()
Method Get1400J05()

ENDCLASS

//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} New()
  
Método construtor da Classe FISA2401400

@author Ulisses P. Oliveira
@since 27/03/2020
@version 1.0
/*/
//--------------------------------------------------------------------------------------------------
Method New() Class FISA2401400
	Self:Clear1400()
Return Self


//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} Clear1400
  
Método que limpa os valores do objeto.

@author Ulisses P. Oliveira
@since 27/03/2020
@version 1.0
/*/
//--------------------------------------------------------------------------------------------------
Method Clear1400() Class FISA2401400
	Self:nSQtde     := 0
	Self:nSICMEfet  := 0
	Self:nVlrICMSCo := 0
    Self:nVlICMSTRe := 0
Return


//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} Inc1400()
  


@author Ulisses P. Oliveira
@since 27/03/2020
@version 1.0
/*/
//--------------------------------------------------------------------------------------------------
Method Inc1400(cTipoDoc,nQtdade,nVlrICMEfe) Class FISA2401400
    Local nSQtde     := Self:Get1400J02()
    Local nSICMEfet  := Self:Get1400J03()

    If cTipoDoc != 'D'
        nSQtde    += nQtdade
        nSICMEfet += nVlrICMEfe
    Else
        nSQtde    -= nQtdade
        nSICMEfet -= nVlrICMEfe
    EndIf

    Self:Set1400J02(nSQtde)
    Self:Set1400J03(nSICMEfet)

Return


//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} Getters e Setters

@author Ulisses P. Oliveira
@since 27/03/2020
@version 1.0
/*/
//--------------------------------------------------------------------------------------------------
Method Set1400J02(nSQtde) Class FISA2401400
    Self:nSQtde := nSQtde
Return

Method Set1400J03(nSICMEfet) Class FISA2401400
    Self:nSICMEfet := nSICMEfet
Return

Method Set1400J04(nVlrICMSCo) Class FISA2401400
    Self:nVlrICMSCo := nVlrICMSCo
Return

Method Set1400J05(nVlICMSTRe) Class FISA2401400
    Self:nVlICMSTRe := nVlICMSTRe
Return

Method Get1400J02() Class FISA2401400
Return Self:nSQtde

Method Get1400J03() Class FISA2401400
Return Self:nSICMEfet

Method Get1400J04() Class FISA2401400
Return Self:nVlrICMSCo

Method Get1400J05() Class FISA2401400
Return Self:nVlICMSTRe


//==================================================================================================
/*/{Protheus.doc} Classe FISA2401500

Classe responsável pelo controle do Registro 1500.
 
@author Ulisses P. Oliveira
@since 27/03/2020
@version 1.0
/*/
//==================================================================================================
CLASS FISA2401500 FROM LongNameClass

Data nSQtde      As Numeric   //--- ---//
Data nVlrICMSUn  As Numeric   //--- ---//
Data nVlICMSTRe  As Numeric   //--- ---//
Data nSQtdeMov   As Numeric   //--- ---//


Method New() CONSTRUCTOR
Method Clear1500()
Method Inc1500(cTipoDoc,nQtdade)

//---Getters e Setters---//
Method Set1500L02(nSQtde)
Method Set1500L03(nVlrICMSUn)
Method Set1500L04(nVlICMSTRe)
Method Set1500LSM(nSQtdeMov)
Method Get1500L02()
Method Get1500L03()
Method Get1500L04()
Method Get1500LSM()

ENDCLASS

//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} New()
  
Método construtor da Classe FISA2401500

@author Ulisses P. Oliveira
@since 27/03/2020
@version 1.0
/*/
//--------------------------------------------------------------------------------------------------
Method New() Class FISA2401500
	Self:Clear1500()
Return Self


//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} Clear1500
  
Método que limpa os valores do objeto.

@author Ulisses P. Oliveira
@since 27/03/2020
@version 1.0
/*/
//--------------------------------------------------------------------------------------------------
Method Clear1500() Class FISA2401500
	Self:nSQtde     := 0
	Self:nVlrICMSUn := 0
	Self:nVlICMSTRe := 0
    Self:nSQtdeMov  := 0
Return


//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} Inc1500()
  


@author Ulisses P. Oliveira
@since 27/03/2020
@version 1.0
/*/
//--------------------------------------------------------------------------------------------------
Method Inc1500(cTipoDoc,nQtdade) Class FISA2401500
    Local nSQtde     := Self:Get1500L02()
    Local nSQtdeMov  := Self:Get1500LSM()

    If cTipoDoc != 'D'
        nSQtde    += nQtdade
    Else
        nSQtde    -= nQtdade
    EndIf
    nSQtdeMov += nQtdade

    Self:Set1500L02(nSQtde)
    Self:Set1500LSM(nSQtdeMov)

Return


//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} Getters e Setters

@author Ulisses P. Oliveira
@since 27/03/2020
@version 1.0
/*/
//--------------------------------------------------------------------------------------------------
Method Set1500L02(nSQtde) Class FISA2401500
    Self:nSQtde := nSQtde
Return

Method Set1500L03(nVlrICMSUn) Class FISA2401500
    Self:nVlrICMSUn := nVlrICMSUn
Return

Method Set1500L04(nVlICMSTRe) Class FISA2401500
    Self:nVlICMSTRe := nVlICMSTRe
Return

Method Set1500LSM(nSQtdeMov) Class FISA2401500
    Self:nSQtdeMov := nSQtdeMov
Return

Method Get1500L02() Class FISA2401500
Return Self:nSQtde

Method Get1500L03() Class FISA2401500
Return Self:nVlrICMSUn

Method Get1500L04() Class FISA2401500
Return Self:nVlICMSTRe

Method Get1500LSM() Class FISA2401500
Return Self:nSQtdeMov


//==================================================================================================
/*/{Protheus.doc} Classe FISA2409000

Classe responsável pelo controle do Registro 9000.
 
@author Ulisses P. Oliveira
@since 30/03/2020
@version 1.0
/*/
//==================================================================================================
CLASS FISA2409000 FROM LongNameClass

Data nS1200CF07  As Numeric   //--- ---//
Data nS1200CF08  As Numeric   //--- ---//
Data nS1200CF09  As Numeric   //--- ---//
Data nS1200CF10  As Numeric   //--- ---//
Data nS1300CH07  As Numeric   //--- ---//
Data nS1200IRes  As Numeric   //--- ---//
Data nS1200ICom  As Numeric   //--- ---//
Data nS1300IRes  As Numeric   //--- ---//
Data nS1400IRes  As Numeric   //--- ---//
Data nS1500IRes  As Numeric   //--- ---//
Data nS9000FRes  As Numeric   //--- ---//
Data nS9000FCom  As Numeric   //--- ---//
Data nVlApCrICM  As Numeric   //--- ---//
Data nVlApICMCp  As Numeric   //--- ---//

Method New() CONSTRUCTOR
Method Clear9000()
Method Inc9000(o1200,o1300,o1400,o1500)

//---Getters e Setters---//
Method Set1200F07(nS1200CF07)
Method Set1200F08(nS1200CF08)
Method Set1200F09(nS1200CF09)
Method Set1200F10(nS1200CF10)
Method Set1300H07(nS1300CH07)
Method Set9000X02(nS1200IRes)
Method Set9000X03(nS1200ICom)
Method Set9000X04(nS1300IRes)
Method Set9000X05(nS1400IRes)
Method Set9000X06(nS1500IRes)
Method Set9000X07(nS9000FRes)
Method Set9000X08(nS9000FCom)
Method SetApCrICM(nVlApCrICM)
Method SetApICMCp(nVlApICMCp)
Method Get1200F07()
Method Get1200F08()
Method Get1200F09()
Method Get1200F10()
Method Get1300H07()
Method Get9000X02()
Method Get9000X03()
Method Get9000X04()
Method Get9000X05()
Method Get9000X06()
Method Get9000X07()
Method Get9000X08()
Method GetApCrICM()
Method GetApICMCp()


ENDCLASS

//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} New()
  
Método construtor da Classe FISA2409000

@author Ulisses P. Oliveira
@since 30/03/2020
@version 1.0
/*/
//--------------------------------------------------------------------------------------------------
Method New() Class FISA2409000
	Self:Clear9000()
Return Self


//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} Clear9000
  
Método que limpa os valores do objeto.

@author Ulisses P. Oliveira
@since 30/03/2020
@version 1.0
/*/
//--------------------------------------------------------------------------------------------------
Method Clear9000() Class FISA2409000
	Self:nS1200CF07	:= 0
	Self:nS1200CF08	:= 0
	Self:nS1200CF09	:= 0
	Self:nS1200CF10	:= 0
	Self:nS1300CH07	:= 0
	Self:nS1200IRes	:= 0
	Self:nS1200ICom	:= 0
	Self:nS1300IRes	:= 0
	Self:nS1400IRes	:= 0
	Self:nS1500IRes	:= 0
	Self:nS9000FRes	:= 0
	Self:nS9000FCom	:= 0
    Self:nVlApCrICM := 0
    Self:nVlApICMCp := 0
Return


//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} Inc9000()
  


@author Ulisses P. Oliveira
@since 30/03/2020
@version 1.0
/*/
//--------------------------------------------------------------------------------------------------
Method Inc9000(o1200,o1300,o1400,o1500) Class FISA2409000
    Self:Set1200F07(Self:Get1200F07() + o1200:Get1200F07())
    Self:Set1200F08(Self:Get1200F08() + o1200:Get1200F08())
    Self:Set1200F09(Self:Get1200F09() + o1200:Get1200F09())
    Self:Set1200F10(Self:Get1200F10() + o1200:Get1200F10())
    Self:Set1300H07(Self:Get1300H07() + o1300:Get1300H07())
    Self:Set9000X04(Self:Get9000X04() + o1300:Get1300H06())
    Self:Set9000X05(Self:Get9000X05() + o1400:Get1400J05())
    Self:Set9000X06(Self:Get9000X06() + o1500:Get1500L04())
Return


//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} Getters e Setters

@author Ulisses P. Oliveira
@since 30/03/2020
@version 1.0
/*/
//--------------------------------------------------------------------------------------------------
Method Set1200F07(nS1200CF07) Class FISA2409000
    Self:nS1200CF07 := nS1200CF07
Return

Method Set1200F08(nS1200CF08) Class FISA2409000
    Self:nS1200CF08 := nS1200CF08
Return

Method Set1200F09(nS1200CF09) Class FISA2409000
    Self:nS1200CF09 := nS1200CF09
Return

Method Set1200F10(nS1200CF10) Class FISA2409000
    Self:nS1200CF10 := nS1200CF10
Return

Method Set1300H07(nS1300CH07) Class FISA2409000
    Self:nS1300CH07 := nS1300CH07
Return

Method Set9000X02(nS1200IRes) Class FISA2409000
    Self:nS1200IRes := nS1200IRes
Return

Method Set9000X03(nS1200ICom) Class FISA2409000
    Self:nS1200ICom := nS1200ICom
Return

Method Set9000X04(nS1300IRes) Class FISA2409000
    Self:nS1300IRes := nS1300IRes
Return

Method Set9000X05(nS1400IRes) Class FISA2409000
    Self:nS1400IRes := nS1400IRes
Return

Method Set9000X06(nS1500IRes) Class FISA2409000
    Self:nS1500IRes := nS1500IRes
Return

Method Set9000X07(nS9000FRes) Class FISA2409000
    Self:nS9000FRes := nS9000FRes
Return

Method Set9000X08(nS9000FCom) Class FISA2409000
    Self:nS9000FCom := nS9000FCom
Return

Method SetApCrICM(nVlApCrICM) Class FISA2409000
    Self:nVlApCrICM := nVlApCrICM
Return

Method SetApICMCp(nVlApICMCp) Class FISA2409000
    Self:nVlApICMCp := nVlApICMCp
Return

Method Get1200F07() Class FISA2409000
Return Self:nS1200CF07

Method Get1200F08() Class FISA2409000
Return Self:nS1200CF08

Method Get1200F09() Class FISA2409000
Return Self:nS1200CF09

Method Get1200F10() Class FISA2409000
Return Self:nS1200CF10

Method Get1300H07() Class FISA2409000
Return Self:nS1300CH07

Method Get9000X02() Class FISA2409000
Return Self:nS1200IRes

Method Get9000X03() Class FISA2409000
Return Self:nS1200ICom

Method Get9000X04() Class FISA2409000
Return Self:nS1300IRes

Method Get9000X05() Class FISA2409000
Return Self:nS1400IRes

Method Get9000X06() Class FISA2409000
Return Self:nS1500IRes

Method Get9000X07() Class FISA2409000
Return Self:nS9000FRes

Method Get9000X08() Class FISA2409000
Return Self:nS9000FCom

Method GetApCrICM() Class FISA2409000
Return Self:nVlApCrICM

Method GetApICMCp() Class FISA2409000
Return Self:nVlApICMCp


//==================================================================================================
/*/{Protheus.doc} Classe FISA240MOVIMENTO

  
@author Ulisses P. Oliveira
@since 26/03/2020
@version 1.0
/*/
//==================================================================================================
CLASS FISA240MOVIMENTO FROM LongNameClass

//---Valores setados para o movimento durante a rotina de processamento da apuração. Serão usados para o cálculo---//
Data dDataMov   As Date      //---Data do Movimento
Data cTipoMov   As Character //---Tipo do Movimento (E-Entrada / S-Saída)
Data cTipoDoc   As Character //---Tipo do Documento (Normal / Devolução / Complemento)
Data cCodProd   As Character //---Código do Produto
Data cTipoPart  As Character //---Tipo do Participante (Cliente Final / Revendedor)
Data cPartOptSN As Character //---Participante Optante pelo Simples Nacional (1-Sim / 2-Não)
Data nAliqInt   As Numeric   //---Alíquota Interna do Produto
Data nAliqFec   As Numeric   //---Alíquota do FECOP do Produto---//
Data cCFOP      As Character //---CFOP
Data cCST       As Character //---CST ICMS
Data nQtdade    As Numeric   //---Quantidade informada no Documento Fiscal
Data nVlrUnit   As Numeric   //---Valor Unitário do Item da Nota Fiscal
Data nVlrTotPrd As Numeric   //---Valor Total do Produto
Data nVlrFrete  As Numeric   //---Valor do Frete
Data nVlrSeguro As Numeric   //---Valor do Seguro
Data nVlrDesp   As Numeric   //---Valor das Despesas
Data nVlrDesc   As Numeric   //---Valor do Desconto
Data nVlrTotNf  As Numeric   //---Valor Total da Nota Fiscal
Data nVlrAICMS  As Numeric   //---Alíquota do ICMS
Data nVlrICMS   As Numeric   //---Valor do ICMS
Data nVlrBICMST As Numeric   //---Valor da Base de Cálculo do ICMS-ST
Data nVlrICMSST As Numeric   //---Valor do ICMS-ST
Data nVlrMVAOp  As Numeric   //---MVA da Operação de Entrada
Data cRespRet   As Character //---Responsável pela retenção do ICMS-ST (1–Remetente Direto / 2-Remetente Indireto / 3–Próprio declarante )
Data cPrdResVSN As Character //---Indicador de cálculo de Ressarcimento em caso de saída interna para Optante pelo Simples Nacional (1–Sim / 2–Não)
Data aDocOriApu As Array     //---Valores apurados para o Documento Fiscal Original, em casos de movimentos de devolução

//---Valores calculados para o movimento---//
Data cTipoOper  As Character //---Tipo de Operação de Saída: 12 – Saídas internas destinadas a consumidor final / 13 – Saídas interestaduais / 14 – Saídas internas Art. 119 / 15 – Saídas internas destinadas a contribuintes do Simples Nacional
Data nVlrICMSSu As Numeric   //---Valor do ICMS Suportado na Entrada
Data nVlrICMEfe As Numeric   //---Valor do ICMS Efetivo na Saida 

//---Valores de controle do movimento---//
Data lGravaMov                //---Indicador de Gravação do Movimento
Data nOrdMovAtu  As Numeric   //---Ordenação do Movimento Atual do Produto

Method New() CONSTRUCTOR
Method EnquadMov(aDtIniReCo)
Method ClearMov()
Method DefBaseICM()
Method CalcTotPrd(nQtdade, nVlrUnit)

//---Getters e Setters---//
Method SetDataMov(dDataMov)
Method SetTipoMov(cTipoMov)
Method SetTipoDoc(cTipoDoc)
Method SetCodProd(cCodProd)
Method SetTipoPar(cTipoPart)
Method SetOptSN(cPartOptSN)
Method SetAliqInt(nAliqInt)
Method SetAliqFec(nAliqFec)
Method SetCFOP(cCFOP)
Method SetCST(cCST)
Method SetQtdade(nQtdade)
Method SetVUnit(nVlrUnit)
Method SetTotPrd(nVlrTotPrd)
Method SetFrete(nVlrFrete)
Method SetSeguro(nVlrSeguro)
Method SetDespesa(nVlrDesp)
Method SetDescont(nVlrDesc)
Method SetTotNf(nVlrTotNf)
Method SetAICMS(nVlrAICMS)
Method SetVICMS(nVlrICMS)
Method SetBICMST(nVlrBICMST)
Method SetVICMSST(nVlrICMSST)
Method SetVMVAOp(nVlrMVAOp)
Method SetRespRet(cRespRet)
Method SetPrResSN(cPrdResVSN)
Method SetDocOrig(aDocOriApu)
Method SetTpOper(cTipoOper)
Method SetICMSSu(nVlrICMSSu)
Method SetICMEfe(nVlrICMEfe)
Method SetGrvMov(lGravaMov)
Method SetOrdMov(nOrdMovAtu)
Method GetDataMov()
Method GetTipoMov()
Method GetTipoDoc()
Method GetCodProd()
Method GetTipoPar()
Method GetOptSN()
Method GetAliqInt()
Method GetAliqFec()
Method GetCFOP()
Method GetCST()
Method GetQtdade()
Method GetVUnit()
Method GetTotPrd()
Method GetFrete()
Method GetSeguro()
Method GetDespesa()
Method GetDescont()
Method GetTotNf()
Method GetAICMS()
Method GetVICMS()
Method GetBICMST()
Method GetVICMSST()
Method GetVMVAOp()
Method GetRespRet()
Method GetPrResSN()
Method GetPerRess()
Method GetDocOrig()
Method GetTpOper()
Method GetICMSSu()
Method GetICMEfe()
Method GetGrvMov()
Method GetOrdMov()

ENDCLASS


//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} New()
  
Método construtor da Classe FISA240MOVIMENTO

@author Ulisses P. Oliveira
@since 26/03/2020
@version 1.0
/*/
//--------------------------------------------------------------------------------------------------
Method New() Class FISA240MOVIMENTO
    Self:ClearMov()
Return Self


//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} EnquadMov()
  
Método que define o tipo da operção de saída, retornando:
12 – Saídas internas destinadas a consumidor final
13 – Saídas interestaduais
14 – Saídas internas Art. 119
15 – Saídas internas destinadas a contribuintes do Simples Nacional

@author Ulisses P. Oliveira
@since 26/03/2020
@version 1.0
/*/
//--------------------------------------------------------------------------------------------------
Method EnquadMov(aDtIniReCo) Class FISA240MOVIMENTO
    Local dDataMov   := Self:GetDataMov()
    Local cCFOP      := Self:GetCFOP()
    Local cTipoPart  := Self:GetTipoPar()
    Local cTipoMov   := Self:GetTipoMov()
    Local cPartOptSN := Self:GetOptSN()
    Local cPrdResVSN := Self:GetPrResSN()
    Local lDtIniRest := .F.
    Local lDtIniComp := .F.
    Local lDtIniRess := .F.
    Local cRetorno   := ''

    If Len(aDtIniReCo) == 3
        lDtIniRest := Iif(dDataMov >= CtoD(aDtIniReCo[1]),.T.,.F.) //---Norma de Procedimento Fiscal 003/2020 SEÇÃO I Art. 3.º---//
        lDtIniComp := Iif(dDataMov >= CtoD(aDtIniReCo[3]),.T.,.F.) //---Norma de Procedimento Fiscal 003/2020 SEÇÃO I Art. 3.º---//
        lDtIniRess := Iif(dDataMov >= CtoD(aDtIniReCo[2]),.T.,.F.) 
    EndIf

    If (cTipoMov == 'S' .And. Left(cCFOP,1) == '6') .Or. (cTipoMov == 'E' .And. Left(cCFOP,1) == '2') .And. lDtIniRess
        cRetorno := '13' //--- 13 – Saídas interestaduais ---//
    ElseIf cPartOptSN == '1' .And. cPrdResVSN = '1' .And. lDtIniRess
        cRetorno := '15' //--- 15 – Saídas internas destinadas a contribuintes do Simples Nacional ---//
    ElseIf cTipoPart $ 'F|L' .And. (lDtIniRest .Or. lDtIniComp)
        cRetorno := '12' //--- 12 – Saídas internas destinadas a consumidor final ---//
    EndIf

Return cRetorno


//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} ClearMov
  
Método que limpa os valores do movimento.

@author Ulisses P. Oliveira
@since 26/03/2020
@version 1.0
/*/
//--------------------------------------------------------------------------------------------------
Method ClearMov() Class FISA240MOVIMENTO
    Self:dDataMov   := CToD("  /  /    ")
    Self:cTipoMov   := ''
    Self:cTipoDoc   := ''
    Self:cCodProd   := ''
    Self:cTipoPart  := ''
    Self:cPartOptSN := ''
    Self:nAliqInt   := 0
    Self:nAliqFec   := 0
    Self:cCFOP      := ''
    Self:cCST       := ''
    Self:nQtdade    := 0
    Self:nVlrUnit   := 0
    Self:nVlrTotPrd := 0
    Self:nVlrFrete  := 0
    Self:nVlrSeguro := 0
    Self:nVlrDesp   := 0
    Self:nVlrDesc   := 0
    Self:nVlrTotNf  := 0
    Self:nVlrAICMS  := 0
    Self:nVlrICMS   := 0
    Self:nVlrBICMST := 0
    Self:nVlrICMSST := 0
    Self:nVlrMVAOp  := 0
    Self:cRespRet   := ''
    Self:cPrdResVSN := ''
    Self:aDocOriApu := {}
    Self:cTipoOper  := ''
    Self:nVlrICMSSu := 0
    Self:nVlrICMEfe := 0
    Self:lGravaMov  :=.F.
    Self:nOrdMovAtu := 0
Return


//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} DefBaseICM()
  
Método que define a correspondente Base de ICMS da operação, caso esta fosse tributada.

@author Ulisses P. Oliveira
@since 27/03/2020
@version 1.0
/*/
//--------------------------------------------------------------------------------------------------
Method DefBaseICM() Class FISA240MOVIMENTO
    Local nRetorno   := 0
    Local nVlrTotPrd := Self:GetTotPrd()
    Local nVlrDesp   := Self:GetDespesa()
    Local nVlrDesc   := Self:GetDescont()

    nRetorno := nVlrTotPrd + nVlrDesp - nVlrDesc
Return nRetorno


//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} Getters e Setters

@author Ulisses P. Oliveira
@since 26/03/2020
@version 1.0
/*/
//--------------------------------------------------------------------------------------------------
Method SetDataMov(dDataMov) Class FISA240MOVIMENTO
    Self:dDataMov := dDataMov
Return

Method SetTipoMov(cTipoMov) Class FISA240MOVIMENTO
    Self:cTipoMov := cTipoMov
Return

Method SetTipoDoc(cTipoDoc) Class FISA240MOVIMENTO
    Self:cTipoDoc := cTipoDoc
Return

Method SetCodProd(cCodProd) Class FISA240MOVIMENTO
    Self:cCodProd := cCodProd
Return

Method SetTipoPar(cTipoPart) Class FISA240MOVIMENTO
    Self:cTipoPart := cTipoPart
Return

Method SetOptSN(cPartOptSN) Class FISA240MOVIMENTO
    Self:cPartOptSN := cPartOptSN
Return

Method SetAliqInt(nAliqInt) Class FISA240MOVIMENTO
    Self:nAliqInt := nAliqInt
Return

Method SetAliqFec(nAliqFec) Class FISA240MOVIMENTO
    Self:nAliqFec := nAliqFec
Return

Method SetCFOP(cCFOP) Class FISA240MOVIMENTO
    Self:cCFOP := cCFOP
Return

Method SetCST(cCST) Class FISA240MOVIMENTO
    Self:cCST := cCST
Return

Method SetQtdade(nQtdade) Class FISA240MOVIMENTO
    Self:nQtdade := Round(nQtdade,5)
Return

Method SetVUnit(nVlrUnit) Class FISA240MOVIMENTO
    Self:nVlrUnit := nVlrUnit
Return

Method SetTotPrd(nVlrTotPrd) Class FISA240MOVIMENTO
    Self:nVlrTotPrd := nVlrTotPrd
Return

// DSERFIS1-28753 - Método abaixo implementado para recalcular nVlrTotPrd (Valor Total do Produto)
// devido a alteração na quantidade de casas decimais do Valor Unitário, fazendo com que os valores
// da apuração fiquem divergentes do Documento Fiscal quando quantidade de casas superior a 2 decimais
Method CalcTotPrd(nQtdade, nVlrUnit) Class FISA240MOVIMENTO
    Self:nVlrTotPrd := nQtdade * nVlrUnit
Return

Method SetFrete(nVlrFrete) Class FISA240MOVIMENTO
    Self:nVlrFrete := nVlrFrete
Return

Method SetSeguro(nVlrSeguro) Class FISA240MOVIMENTO
    Self:nVlrSeguro := nVlrSeguro
Return

Method SetDespesa(nVlrDesp) Class FISA240MOVIMENTO
    Self:nVlrDesp := nVlrDesp
Return

Method SetDescont(nVlrDesc) Class FISA240MOVIMENTO
    Self:nVlrDesc := nVlrDesc
Return

Method SetTotNf(nVlrTotNf) Class FISA240MOVIMENTO
    Self:nVlrTotNf := nVlrTotNf
Return

Method SetAICMS(nVlrAICMS) Class FISA240MOVIMENTO
    Self:nVlrAICMS := nVlrAICMS
Return

Method SetVICMS(nVlrICMS) Class FISA240MOVIMENTO
    Self:nVlrICMS := nVlrICMS
Return

Method SetBICMST(nVlrBICMST) Class FISA240MOVIMENTO
    Self:nVlrBICMST := nVlrBICMST
Return

Method SetVICMSST(nVlrICMSST) Class FISA240MOVIMENTO
    Self:nVlrICMSST := nVlrICMSST
Return

Method SetVMVAOp(nVlrMVAOp) Class FISA240MOVIMENTO
    Self:nVlrMVAOp := nVlrMVAOp
Return

Method SetRespRet(cRespRet) Class FISA240MOVIMENTO
    Self:cRespRet := cRespRet
Return

Method SetPrResSN(cPrdResVSN) Class FISA240MOVIMENTO
    Self:cPrdResVSN := cPrdResVSN
Return

Method SetDocOrig(aDocOriApu) Class FISA240MOVIMENTO
    Self:aDocOriApu := aDocOriApu
Return

Method SetTpOper(cTipoOper) Class FISA240MOVIMENTO
    Self:cTipoOper := cTipoOper
Return

Method SetICMSSu(nVlrICMSSu) Class FISA240MOVIMENTO
    Self:nVlrICMSSu := nVlrICMSSu
Return

Method SetICMEfe(nVlrICMEfe) Class FISA240MOVIMENTO
    Self:nVlrICMEfe := nVlrICMEfe
Return

Method SetGrvMov(lGravaMov) Class FISA240MOVIMENTO
    Self:lGravaMov := lGravaMov
Return

Method SetOrdMov(nOrdMovAtu) Class FISA240MOVIMENTO
    Self:nOrdMovAtu := nOrdMovAtu
Return

Method GetDataMov() Class FISA240MOVIMENTO
Return Self:dDataMov

Method GetTipoMov() Class FISA240MOVIMENTO
Return Self:cTipoMov

Method GetTipoDoc() Class FISA240MOVIMENTO
Return Self:cTipoDoc

Method GetCodProd() Class FISA240MOVIMENTO
Return Self:cCodProd

Method GetTipoPar() Class FISA240MOVIMENTO
Return Self:cTipoPart

Method GetOptSN() Class FISA240MOVIMENTO
Return Self:cPartOptSN

Method GetAliqInt() Class FISA240MOVIMENTO
Return Self:nAliqInt

Method GetAliqFec() Class FISA240MOVIMENTO
Return Self:nAliqFec

Method GetCFOP() Class FISA240MOVIMENTO
Return Self:cCFOP

Method GetCST() Class FISA240MOVIMENTO
Return Self:cCST

Method GetQtdade() Class FISA240MOVIMENTO
Return Self:nQtdade

Method GetVUnit() Class FISA240MOVIMENTO
Return Self:nVlrUnit

Method GetTotPrd() Class FISA240MOVIMENTO
Return Self:nVlrTotPrd

Method GetFrete() Class FISA240MOVIMENTO
Return Self:nVlrFrete

Method GetSeguro() Class FISA240MOVIMENTO
Return Self:nVlrSeguro

Method GetDespesa() Class FISA240MOVIMENTO
Return Self:nVlrDesp

Method GetDescont() Class FISA240MOVIMENTO
Return Self:nVlrDesc

Method GetTotNf() Class FISA240MOVIMENTO
Return Self:nVlrTotNf

Method GetAICMS() Class FISA240MOVIMENTO
Return Self:nVlrAICMS

Method GetVICMS() Class FISA240MOVIMENTO
Return Self:nVlrICMS

Method GetBICMST() Class FISA240MOVIMENTO
Return Self:nVlrBICMST

Method GetVICMSST() Class FISA240MOVIMENTO
Return Self:nVlrICMSST

Method GetVMVAOp() Class FISA240MOVIMENTO
Return Self:nVlrMVAOp

Method GetRespRet() Class FISA240MOVIMENTO
Return Self:cRespRet

Method GetPrResSN() Class FISA240MOVIMENTO
Return Self:cPrdResVSN

Method GetDocOrig() Class FISA240MOVIMENTO
Return Self:aDocOriApu

Method GetTpOper() Class FISA240MOVIMENTO
Return Self:cTipoOper

Method GetICMSSu() Class FISA240MOVIMENTO
Return Self:nVlrICMSSu

Method GetICMEfe() Class FISA240MOVIMENTO
Return Self:nVlrICMEfe

Method GetGrvMov() Class FISA240MOVIMENTO
Return Self:lGravaMov

Method GetOrdMov() Class FISA240MOVIMENTO
Return Self:nOrdMovAtu


//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} Classe FISA240MOVIMENTOENTRADA
  
@author Ulisses P. Oliveira
@since 31/03/2020
@version 1.0
/*/
//--------------------------------------------------------------------------------------------------
CLASS FISA240MOVIMENTOENTRADA FROM LongNameClass

Data cTipoRet   As Character //--- 1-Ressarcimento Registro 1500 (Simples Nacional) | 2-Base de Cálculo ICMS-ST / Valor ICMS Suportado / Valor Menor Unitário / Quantidade (Somatórios para cálculo de média) | 3-Alíquota Interna Efetiva / Alíquota FECOP---//
Data cCodProd   As Character //------//
Data nQtdade    As Numeric   //------//
Data nQtdadeAnt As Numeric   //------//
Data dDataMov   As Date      //------//
Data nAliqInt   As Numeric   //------//
Data aPerRedMVA As Array     //------//
Data nVlrMUnBST As Arrya     //------//
Data cIdApur    As Character //------//
Data cAnoMes    As Character //------//
Data nOrdMovAtu As Numeric   //------//
Data nVlrRessSN As Numeric   //------//
Data aSBCICMSST As Array     //------//
Data aAliqEfFec As Array     //------//


Method New() CONSTRUCTOR
Method ProcUltEnt()
Method AliqEfet(nPercEfet,nBaseRed,nAliqCheia)

//---Getters e Setters---//

ENDCLASS


//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} New()
  
Método construtor da Classe FISA240MOVIMENTOENTRADA

@author Ulisses P. Oliveira
@since 31/03/2020
@version 1.0
/*/
//--------------------------------------------------------------------------------------------------
Method New() Class FISA240MOVIMENTOENTRADA
    Self:cTipoRet   := ""
    Self:cCodProd   := ""
    Self:nQtdade    := 0
    Self:nQtdadeAnt := 0
    Self:dDataMov   := CToD("  /  /    ")
    Self:nAliqInt   := 0
    Self:aPerRedMVA := {}
    Self:nVlrMUnBST := 0
    Self:cIdApur    := ''
    Self:cAnoMes    := ''
    Self:nOrdMovAtu := 0
    Self:nVlrRessSN := 0
    Self:aSBCICMSST := {0,0,0,0,0,0}
    Self:aAliqEfFec := {0,0}
Return Self


//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} ProcUltEnt()
  
Método que analisa as últimas entradas até a composição da quantidade setada em nQtdade, podendo calcular,
dependendo do valor setado em cTipoRet:
1-Ressarcimento Registro 1500 (Simples Nacional)
2-Base de Cálculo ICMS-ST / Valor ICMS Suportado / Valor Menor Unitário / Quantidade (Somatórios para cálculo de média)
3-Alíquota Interna Efetiva / Alíquota FECOP

@author Ulisses P. Oliveira
@since 31/03/2020
@version 1.0
/*/
//--------------------------------------------------------------------------------------------------
Method ProcUltEnt() Class FISA240MOVIMENTOENTRADA
    Local cTipoRet    := Self:cTipoRet
    Local cCodProd    := Self:cCodProd
    Local nQtdade     := Self:nQtdade
    Local nQtdadeAnt  := Self:nQtdadeAnt
    Local dDataMov    := Self:dDataMov
    Local nAliqInt    := Self:nAliqInt
    Local cIdApur     := Self:cIdApur
    Local cAnoMes     := Self:cAnoMes
    Local nOrdMovAtu  := Self:nOrdMovAtu
    Local aArea  	  := GetArea()
    Local cAlias 	  := GetNextAlias()
    Local cAliasSFT   := ''
    Local dDataDe     := FirstDay(dDataMov)
    Local dDataAte    := dDataMov
    Local lAchouFT	  := .F.
    Local nQtdadeAcm  := 0
    Local aAliqEfet   := {}

    Local nVlrMUnBST  := Self:nVlrMUnBST
    Local aPerRedMVA  := Self:aPerRedMVA
    Local nPerRedMVA  := 0
    Local nVlrMVAOp   := 0
    Local nVlrAICMS   := 0
    Local nVlrRessSN  := 0
    Local nCount      := 0
    Local nPos        := 0

    Local oApurEntAn  := Nil
    Local aDocOriApu  := {}
    Local aSBCICMSST  := {0,0,0,0,0,0} //---Base de Cálculo ICMS-ST / Valor ICMS Suportado / Valor Menor Unitário / Quantidade (Somatórios para cálculo de média) / Alíquota ICMS Próprio Última Entrada / MVA Última Entrada ---//

    Local nAliqEfet   := 0
    Local nAliqFec    := 0

    Local cSGBD       := TCGetDB()
    Local cSubStrBD1  := ''
    Local cSubStrBD2  := ''
    Local cSubStrBD3  := ''
    Local cSubStrBD4  := ''
    Local cSubStrBD5  := ''
    Local cSelecTpRt  := ''
    Local cWhereTpRt  := ''
    Local cOrderTpRt  := ''

    //---Ajustes na Query devido à diferenças entre Bancos de Dados---//
    If cSGBD = 'ORACLE'
        cSubStrBD1 := 'SUBSTR(SFT.FT_CLASFIS,2,2)'
        cSubStrBD2 := 'SUBSTR(SFT.FT_ENTRADA,1,6)'
        cSubStrBD3 := 'SUBSTR(SF1.F1_DTDIGIT,1,6)'
        cSubStrBD4 := 'SUBSTR(SFT.FT_ENTRADA,1,6)'
    Else
        cSubStrBD1 := 'RIGHT(SFT.FT_CLASFIS,2)'
        cSubStrBD2 := 'LEFT(SFT.FT_ENTRADA,6)'
        cSubStrBD3 := 'LEFT(SF1.F1_DTDIGIT,6)'
        cSubStrBD4 := 'LEFT(SFT.FT_ENTRADA,6)'
    EndIf
    cSubStrBD5 := Iif(AllTrim(cSGBD) == 'INFORMIX', '1', cSubStrBD4)
    cSubStrBD1 := "%" + cSubStrBD1 + "%"
    cSubStrBD4 := "%" + cSubStrBD4 + "%"
    cSubStrBD5 := "%" + cSubStrBD5 + "%"

    //---Ajustes na cláusula WHERE dependendo do tipo de retorno informado em cTipoRet---//
    If cTipoRet == '1' .Or. cTipoRet == '3'
        cSelecTpRt += " SUM(SFT.FT_QUANT) "
        cWhereTpRt += " SFT.FT_TIPO NOT IN ('D','B','S','P','I','C')    AND "
        cWhereTpRt += " SFT.FT_TIPOMOV  = 'E'                           AND "
        cWhereTpRt += " SFT.FT_NFORI    = ' '                           AND "
        cWhereTpRt += " SFT.FT_SERORI   = ' '                           AND "
        cWhereTpRt += " SFT.FT_ITEMORI  = ' '                           AND "
        cWhereTpRt += Iif(cTipoRet == '1',"ISNULL(CD2.CD2_DOC,'') <> '' AND ","")   
        cOrderTpRt += " SFT.FT_ENTRADA DESC, SD1.D1_NUMSEQ DESC "
    ElseIf cTipoRet == '2'
        cSelecTpRt += " SUM(CASE SFT.FT_TIPO WHEN 'D' THEN SFT.FT_QUANT*(-1) ELSE SFT.FT_QUANT END) "
        cWhereTpRt += " ((SFT.FT_TIPOMOV  = 'E' AND SFT.FT_TIPO <> 'D')                                        OR "
        cWhereTpRt += "  (SFT.FT_TIPOMOV  = 'S' AND SFT.FT_TIPO  = 'D' AND "+cSubStrBD3+" = "+cSubStrBD2+"))  AND "
        cWhereTpRt += "   SFT.FT_TIPO    <> 'S'                                                               AND "
        cOrderTpRt += " FT_DATAMOV, FT_ORDEM "
    End
    cSelecTpRt := "%" + cSelecTpRt + "%"
    cWhereTpRt := "%" + cWhereTpRt + "%"
    cOrderTpRt := "%" + cOrderTpRt + "%"

    //---Verifica se existe quantidade suficiente na movimentação de entrada para compor valores para o produto---//
    If nQtdadeAnt > 0
        If nQtdadeAnt >= nQtdade
       	    lAchouFT := .T.
        EndIf
    Else

        BeginSql Alias cAlias
            SELECT %EXP:cSelecTpRt% QUANT
            FROM %TABLE:SFT% SFT      INNER JOIN %TABLE:F2W% F2W ON (F2W.F2W_FILIAL = %XFILIAL:F2W% AND F2W.F2W_CFOP  = SFT.FT_CFOP    AND F2W.%NOTDEL%)
                                      INNER JOIN %TABLE:F3M% F3M ON (F3M.F3M_FILIAL = %XFILIAL:F3M% AND F3M.F3M_IDF2W = F2W.F2W_IDTAB  AND F3M.F3M_CSTICM = %Exp:cSubStrBD1% AND F3M.%NOTDEL%)
                                 LEFT OUTER JOIN %table:SF1% SF1 ON (SF1.F1_FILIAL  = %xFilial:SF1% AND SF1.F1_DOC    = SFT.FT_NFORI   AND SF1.F1_SERIE   = SFT.FT_SERORI   AND SF1.F1_FORNECE = SFT.FT_CLIEFOR AND SF1.F1_LOJA = SFT.FT_LOJA AND (SFT.FT_TIPOMOV='S' AND SFT.FT_TIPO='D') AND SF1.%NotDel%) 
                                 LEFT OUTER JOIN %table:CD2% CD2 ON (CD2.CD2_FILIAL = %xFilial:CD2% AND CD2.CD2_TPMOV = SFT.FT_TIPOMOV AND CD2.CD2_SERIE  = SFT.FT_SERIE AND CD2.CD2_DOC       = SFT.FT_NFISCAL AND CD2.CD2_CODCLI = '' AND CD2.CD2_LOJCLI = '' AND CD2.CD2_CODFOR = SFT.FT_CLIEFOR AND CD2.CD2_LOJFOR = SFT.FT_LOJA AND CD2.CD2_ITEM = SFT.FT_ITEM AND CD2.CD2_CODPRO = SFT.FT_PRODUTO AND CD2.CD2_IMP = 'SOL' AND (SFT.FT_TIPOMOV='E' AND SFT.FT_TIPO NOT IN ('D','B')) AND CD2.%NotDel%) 
            WHERE  SFT.FT_FILIAL=%XFILIAL:SFT%        AND
                   SFT.FT_PRODUTO = %EXP:cCodProd%    AND
                   %EXP:cWhereTpRt%
                   SFT.FT_ENTRADA  <=  %EXP:dDataAte% AND
                   SFT.FT_DTCANC   = ''               AND
                   SFT.%NOTDEL%	
        EndSql

        DbSelectArea(cAlias)
        (cAlias)->(DbGoTop())
        If (cAlias)->QUANT >= nQtdade
        	lAchouFT := .T.	
        EndIf
        (cAlias)->(DbCloseArea()) 

    EndIf

    //---Caso exista quantidade suficiente na movimentação de entrada para o produto, executa a query abaixo para estabelecer o período inicial para compor a quantidade informada em nQtdade (para que não seja necessária a execução mês a mês até a composição da quantidade nQtdade)---//
    If lAchouFT

        BeginSql Alias cAlias
            SELECT %EXP:cSubStrBD4% ANOMES, %EXP:cSelecTpRt% QUANT
            FROM %TABLE:SFT% SFT      INNER JOIN %TABLE:F2W% F2W ON (F2W.F2W_FILIAL = %XFILIAL:F2W% AND F2W.F2W_CFOP  = SFT.FT_CFOP    AND F2W.%NOTDEL%)
                                      INNER JOIN %TABLE:F3M% F3M ON (F3M.F3M_FILIAL = %XFILIAL:F3M% AND F3M.F3M_IDF2W = F2W.F2W_IDTAB  AND F3M.F3M_CSTICM = %Exp:cSubStrBD1% AND F3M.%NOTDEL%)
                                 LEFT OUTER JOIN %table:SF1% SF1 ON (SF1.F1_FILIAL  = %xFilial:SF1% AND SF1.F1_DOC    = SFT.FT_NFORI   AND SF1.F1_SERIE   = SFT.FT_SERORI   AND SF1.F1_FORNECE = SFT.FT_CLIEFOR AND SF1.F1_LOJA = SFT.FT_LOJA AND (SFT.FT_TIPOMOV='S' AND SFT.FT_TIPO='D') AND SF1.%NotDel%) 
                                 LEFT OUTER JOIN %table:CD2% CD2 ON (CD2.CD2_FILIAL = %xFilial:CD2% AND CD2.CD2_TPMOV = SFT.FT_TIPOMOV AND CD2.CD2_SERIE  = SFT.FT_SERIE AND CD2.CD2_DOC       = SFT.FT_NFISCAL AND CD2.CD2_CODCLI = '' AND CD2.CD2_LOJCLI = '' AND CD2.CD2_CODFOR = SFT.FT_CLIEFOR AND CD2.CD2_LOJFOR = SFT.FT_LOJA AND CD2.CD2_ITEM = SFT.FT_ITEM AND CD2.CD2_CODPRO = SFT.FT_PRODUTO AND CD2.CD2_IMP = 'SOL' AND (SFT.FT_TIPOMOV='E' AND SFT.FT_TIPO NOT IN ('D','B')) AND CD2.%NotDel%) 
            WHERE  SFT.FT_FILIAL=%XFILIAL:SFT%        AND
                   SFT.FT_PRODUTO = %EXP:cCodProd%    AND
                   %EXP:cWhereTpRt%
                   SFT.FT_ENTRADA  <=  %EXP:dDataAte% AND
                   SFT.FT_DTCANC   = ''               AND
                   SFT.%NOTDEL%	
            GROUP BY %EXP:cSubStrBD5%
            ORDER BY ANOMES DESC
        EndSql

        DbSelectArea(cAlias)
        (cAlias)->(DbGoTop())
        While !(cAlias)->(Eof()) .And. (nQtdadeAcm < nQtdade )
            nQtdadeAcm += (cAlias)->QUANT
            dDatade    := StoD((cAlias)->ANOMES+'01')
            (cAlias)->(DbSkip())
        EndDo
        (cAlias)->(DbCloseArea()) 

        //---Classe responsável pela apuração do movimento de entrada---//
        If cTipoRet == '2'
            oApurEntAn := FISA240APURACAO():New(cIdApur,cAnoMes,{})
            oApurEntAn:oMovimento:SetOrdMov(nOrdMovAtu)
        EndIf

    	//---Execução da Query de maneira detalhada---//
        While nQtdade > 0
            cAliasSFT := GetNextAlias()

            BeginSql Alias cAliasSFT
                COLUMN FT_EMISSAO AS DATE
                COLUMN FT_ENTRADA AS DATE
                COLUMN FT_DATAMOV AS DATE

                SELECT SFT.FT_PRODUTO             FT_PRODUTO,
                       SB1.B1_UM                  B1_UM,
                       CASE SFT.FT_TIPOMOV
                           WHEN 'E' THEN          FT_ENTRADA
                           ELSE                   FT_EMISSAO
                       END                        FT_DATAMOV,
                       SFT.FT_TIPOMOV             FT_TIPOMOV,
                       SFT.FT_TIPO                FT_TIPO,
                       CASE SFT.FT_TIPOMOV
                           WHEN 'E' THEN
                               CASE SFT.FT_TIPO
                                   WHEN 'D' THEN '4'
                                   ELSE          '1'
                               END
                           ELSE
                               CASE SFT.FT_TIPO
                                   WHEN 'D' THEN '2'
                                   ELSE          '3'
                               END
                       END                        FT_ORDEM,
                       SFT.FT_NFISCAL             FT_NFISCAL,
                       SFT.FT_SERIE               FT_SERIE,
                       SFT.FT_ITEM                FT_ITEM,
                       SFT.FT_ESPECIE             FT_ESPECIE,
                       SFT.FT_CHVNFE              FT_CHVNFE,
                       SFT.FT_CLIEFOR             FT_CLIEFOR,
                       SFT.FT_LOJA                FT_LOJA,
                       CASE
                           WHEN ((SFT.FT_TIPOMOV='S' AND SFT.FT_TIPO NOT IN ('D','B')) OR (SFT.FT_TIPOMOV='E' AND SFT.FT_TIPO IN ('D','B')))
                           THEN SA1.A1_CGC
                           ELSE SA2.A2_CGC
                       END                        FT_CNPJCPF,
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
                       CASE 
                           WHEN %Exp:cSubStrBD1% = '60' AND SFT.FT_ICMSRET = 0 
                           THEN 0
                           ELSE CASE
                                    WHEN SFT.FT_BASEICM = 0 AND SFT.FT_OUTRICM > 0
                                    THEN CASE SFT.FT_TIPOMOV
				                             WHEN 'E' THEN SD1.D1_PICM
				        			                  ELSE SD2.D2_PICM
				        		         END
                                    ELSE SFT.FT_ALIQICM
                                END
                       END                        FT_ALIQICM,
                       CASE 
                           WHEN %Exp:cSubStrBD1% = '60' AND SFT.FT_ICMSRET = 0 
                           THEN 0
                           ELSE CASE
                                    WHEN SFT.FT_BASEICM = 0 AND SFT.FT_OUTRICM > 0
                                    THEN CASE SFT.FT_TIPOMOV
				                             WHEN 'E' THEN SD1.D1_VALICM
				        			                  ELSE SD2.D2_VALICM
				        		         END
                                    ELSE SFT.FT_VALICM
                                END
                       END                        FT_VALICM,
                       CASE 
                           WHEN  %Exp:cSubStrBD1% = '60' AND SFT.FT_ICMSRET = 0 
                           THEN '2'
                           ELSE CASE WHEN SFT.FT_VALANTI > 0 
                                     THEN '3' 
                                     ELSE '1' 
					    	    END 
                       END                        FT__RESRET,
                       CASE 
                           WHEN %Exp:cSubStrBD1% = '60' AND SFT.FT_ICMSRET = 0 
                           THEN SFT.FT_BASNDES
                           ELSE SFT.FT_BASERET
                       END                        FT__BCST,
                       CASE 
                           WHEN  %Exp:cSubStrBD1% = '60' AND SFT.FT_ICMSRET = 0 
                           THEN SFT.FT_ALQNDES
                           ELSE SFT.FT_ALIQSOL
                       END                        FT__ALQST,
                       CASE 
                           WHEN  %Exp:cSubStrBD1% = '60' AND SFT.FT_ICMSRET = 0 
                           THEN SFT.FT_ICMNDES
                           ELSE SFT.FT_ICMSRET
                       END                        FT__VLRST,
                       CASE 
                           WHEN  %Exp:cSubStrBD1% = '60' AND SFT.FT_ICMSRET = 0 
                           THEN SFT.FT_AFCPANT
                           ELSE SFT.FT_ALFCPST
                       END                        FT__ALQFEC,
                       SFT.FT_NFORI               FT_NFORI,
                       SFT.FT_SERORI              FT_SERORI,
                       SFT.FT_ITEMORI             FT_ITEMORI,
                       CASE 
                           WHEN SFT.FT_TIPO = 'D'
                           THEN SF1.F1_DTDIGIT
                           ELSE ''
                       END                        FT_EMISORI,
                       ISNULL(CD2.CD2_PREDBC,0)   CD2_PREDBC,
                       SFT.FT_MARGEM              FT_MARGEM
                FROM  %TABLE:SFT% SFT INNER JOIN      %table:SB1% SB1 ON (SB1.B1_FILIAL  = %xFilial:SB1% AND SB1.B1_COD    = SFT.FT_PRODUTO AND SB1.%NotDel%)
                                      INNER JOIN      %table:F2W% F2W ON (F2W.F2W_FILIAL = %XFILIAL:F2W% AND F2W.F2W_CFOP  = SFT.FT_CFOP    AND F2W.%NOTDEL%)
                                      INNER JOIN      %table:F3M% F3M ON (F3M.F3M_FILIAL = %XFILIAL:F3M% AND F3M.F3M_IDF2W = F2W.F2W_IDTAB  AND F3M.F3M_CSTICM = %Exp:cSubStrBD1% AND F3M.%NOTDEL%)
                                      LEFT OUTER JOIN %table:SA1% SA1 ON (SA1.A1_FILIAL  = %xFilial:SA1% AND SA1.A1_COD    = SFT.FT_CLIEFOR AND SA1.A1_LOJA    = SFT.FT_LOJA     AND ((SFT.FT_TIPOMOV='S' AND SFT.FT_TIPO NOT IN ('D','B')) OR (SFT.FT_TIPOMOV='E' AND SFT.FT_TIPO IN ('D','B')))  AND SA1.%NotDel%)
                                      LEFT OUTER JOIN %table:SA2% SA2 ON (SA2.A2_FILIAL  = %xFilial:SA2% AND SA2.A2_COD    = SFT.FT_CLIEFOR AND SA2.A2_LOJA    = SFT.FT_LOJA     AND ((SFT.FT_TIPOMOV='E' AND SFT.FT_TIPO NOT IN ('D','B')) OR (SFT.FT_TIPOMOV='S' AND SFT.FT_TIPO IN ('D','B')))  AND SA2.%NotDel%) 
                                      LEFT OUTER JOIN %table:SF1% SF1 ON (SF1.F1_FILIAL  = %xFilial:SF1% AND SF1.F1_DOC    = SFT.FT_NFORI   AND SF1.F1_SERIE   = SFT.FT_SERORI   AND SF1.F1_FORNECE = SFT.FT_CLIEFOR AND SF1.F1_LOJA = SFT.FT_LOJA AND (SFT.FT_TIPOMOV='S' AND SFT.FT_TIPO='D')    AND SF1.%NotDel%) 
                                      LEFT OUTER JOIN %table:SD1% SD1 ON (SD1.D1_FILIAL  = %xFilial:SD1% AND SD1.D1_DOC    = SFT.FT_NFISCAL AND SD1.D1_SERIE   = SFT.FT_SERIE AND SD1.D1_FORNECE = SFT.FT_CLIEFOR AND SD1.D1_LOJA = SFT.FT_LOJA AND SD1.D1_COD = SFT.FT_PRODUTO AND SD1.D1_ITEM = SFT.FT_ITEM AND SFT.FT_TIPOMOV = 'E' AND SD1.%NotDel%)
                                      LEFT OUTER JOIN %table:SD2% SD2 ON (SD2.D2_FILIAL  = %xFilial:SD2% AND SD2.D2_DOC    = SFT.FT_NFISCAL AND SD2.D2_SERIE   = SFT.FT_SERIE AND SD2.D2_CLIENTE = SFT.FT_CLIEFOR AND SD2.D2_LOJA = SFT.FT_LOJA AND SD2.D2_COD = SFT.FT_PRODUTO AND SD2.D2_ITEM = SFT.FT_ITEM AND SFT.FT_TIPOMOV = 'S' AND SD2.%NotDel%) 
                                      LEFT OUTER JOIN %table:CD2% CD2 ON (CD2.CD2_FILIAL = %xFilial:CD2% AND CD2.CD2_TPMOV = SFT.FT_TIPOMOV AND CD2.CD2_SERIE  = SFT.FT_SERIE AND CD2.CD2_DOC    = SFT.FT_NFISCAL AND CD2.CD2_CODCLI = '' AND CD2.CD2_LOJCLI = '' AND CD2.CD2_CODFOR = SFT.FT_CLIEFOR AND CD2.CD2_LOJFOR = SFT.FT_LOJA AND CD2.CD2_ITEM = SFT.FT_ITEM AND CD2.CD2_CODPRO = SFT.FT_PRODUTO AND CD2.CD2_IMP = 'SOL' AND (SFT.FT_TIPOMOV='E' AND SFT.FT_TIPO NOT IN ('D','B')) AND CD2.%NotDel%) 
                WHERE  SFT.FT_FILIAL   = %XFILIAL:SFT%                   AND
                       SFT.FT_PRODUTO  = %EXP:cCodProd%                  AND
                       %EXP:cWhereTpRt% 
                       SFT.FT_ENTRADA >=  %EXP:dDataDe%                  AND
                       SFT.FT_ENTRADA <=  %EXP:dDataAte%                 AND
                       SFT.FT_DTCANC   = ''		                         AND
                       SFT.%NOTDEL%
                ORDER BY %EXP:cOrderTpRt%
            EndSql 

            DbSelectArea(cAliasSFT)
            (cAliasSFT)->(DbGoTop())
            While !(cAliasSFT)->(Eof()) .And. (cTipoRet == '2' .Or. nQtdade > 0)

                aAliqEfet := Self:AliqEfet((cAliasSFT)->CD2_PREDBC,(cAliasSFT)->FT__BCST,(cAliasSFT)->FT__ALQST)

                If cTipoRet == '1' //--- 1-Ressarcimento Registro 1500 (Simples Nacional) ---//

                    //------------------------------------------------------------------------------------------------------------------------------------------------------//
                    /*  Art. 15 do Anexo IX do RCIMS/17
                       
                        O contribuinte substituído que promover saída, em operação interna destinada a contribuinte optante pelo regime do Simples Nacional, de mercadorias a 
                        que se referem as Seções VI, VII, XVIII e XXII, recebidas com o imposto retido calculado com a aplicação do percentual da MVA previsto na legislação, 
                        poderá, observado o disposto nos artigos  6º e 7º deste Anexo, recuperar em conta gráfica, mediante utilização do código de ajuste da apuração PR020222 
                        na EFD ou ressarcir-se junto a qualquer estabelecimento de fornecedor que seja eleito substituto tributário, do valor obtido a partir do seguinte cálculo:

                        I -  exclusão da parcela correspondente à MVA utilizada para cálculo do imposto retido, da base de cálculo utilizada para determinação do imposto devido 
                             por Substituição Tributária - ST;
                        II - aplicação, sobre o valor remanescente após a exclusão da parcela correspondente à MVA utilizada para cálculo do imposto retido, de acordo com o inciso I 
                             do "caput", dos coeficientes correspondentes a:
                             a) 70% (setenta por cento) do percentual da MVA utilizado pelo substituto, para as operações tributadas à alíquota igual ou superior a 18% (dezoito por cento);
                             b) 50% (cinquenta por cento) do percentual da MVA utilizado pelo substituto, nos demais casos.
                        III - aplicação, sobre o valor obtido de acordo com as alíneas "a" e "b" do inciso II do "caput", da alíquota interna incidente sobre a mercadoria.
                        § 1.º Sempre que houver benefício fiscal na operação interna deverá ser aplicado o percentual de redução de que trata a alínea "b" do inciso II do "caput".
                        § 2.º Para efeitos do disposto neste artigo deverá ser considerada a situação cadastral do contribuinte na data da realização da operação pelo substituto.

                        MANUAL DO ARQUIVO DIGITAL DA ST / Registro 1500 / Campo L03:

                        Valor obtido a partir do seguinte cálculo:
                        (D04 /(1+MVA)) x (MVA/Coeficiente) x (B10)

                        Onde:
                        -D04 é o campo VL_BC_ICMSST_UNIT_MED;
                        -MVA é a MVA utilizada para retenção do ICMS ST;
                        -Coeficiente é o percentual de redução a ser aplicado sobre a MVA (70% se alíquota de 18%, 50% se alíquota de 12%);
                        -B10 é campo ALIQ_INTERNA

                    */
                    //------------------------------------------------------------------------------------------------------------------------------------------------------//

                    nVlrMVAOp := (cAliasSFT)->FT_MARGEM

                    If nVlrMVAOp > 0

                        //---Verifica percentual de reduçã da MVA da operação de acordo com a alíquota aplicada---//
                        If Len(aPerRedMVA) > 0
                            For nCount := 1 To Len(aPerRedMVA)
                                nPos := At('=',aPerRedMVA[nCount])
                                If nPos > 0
                                    nVlrAICMS := Val(SubStr(aPerRedMVA[nCount], 1, nPos-1))
                                    If nVlrAICMS == (cAliasSFT)->FT_ALIQICM
                                        nPerRedMVA := Val(SubStr(aPerRedMVA[nCount], nPos+1, Len(aPerRedMVA[nCount])))
                                    EndIf
                                EndIf
                            Next nCount
                        EndIf

                        //---Calcular o Valor de Ressarcimento---//
                        //---                   (D04        / (1 +  MVA             )) x (MVA             * Coeficiente       ) x (B10           )
                        If nPerRedMVA > 0
                            nVlrRessSN := Round((nVlrMUnBST / (1 + (nVlrMVAOp / 100))) * ((nVlrMVAOp/100) * (nPerRedMVA / 100)) * (nAliqInt / 100),2)
                        EndIf

                    EndIf

                    nQtdade := 0

                ElseIf cTipoRet == '2' //--- 2-Base de Cálculo ICMS-ST / Valor ICMS Suportado / Valor Menor Unitário / Quantidade (Somatórios para cálculo de média) ---//

                    If (cAliasSFT)->FT_TIPO != 'D'
                        nQtdade    -= (cAliasSFT)->FT_QUANT
                    Else
                        nQtdade    += (cAliasSFT)->FT_QUANT

                        //---Valores apurados para o Documento Fiscal Original, em casos de movimentos de devolução---//
                        aDocOriApu := aSize(aDocOriApu,0)
                        aDocOriApu := FsaB240Ap((cAliasSFT)->FT_TIPOMOV, (cAliasSFT)->FT_NFORI, (cAliasSFT)->FT_SERORI, (cAliasSFT)->FT_ITEMORI, (cAliasSFT)->FT_CLIEFOR, (cAliasSFT)->FT_LOJA, (cAliasSFT)->FT_PRODUTO, cAnoMes)
                    EndIf

                    //---Método SetaMovim: Carrega os dados do movimento para que seja feita sua apuração---//
                    oApurEntAn:SetaMovim((cAliasSFT)->FT_DATAMOV,;                             //---dDataMov   - Data do Movimento
                                         (cAliasSFT)->FT_TIPOMOV,;                             //---cTipoMov   - Tipo do Movimento (E-Entrada / S-Saída)
                                         (cAliasSFT)->FT_TIPO,;                                //---cTipoDoc   - Tipo do Documento (Normal / Devolução / Complemento)
                                         (cAliasSFT)->FT_PRODUTO,;                             //---cCodProd   - Código do Produto
                                         '',;                                                  //---cTipoPart  - Tipo do Participante (Cliente Final / Revendedor)
                                         '',;                                                  //---cPartOptSN - Participante Optante pelo Simples Nacional (1-Sim / 2-Não)
                                         nAliqInt,;                                            //---nAliqInt   - Alíquota Interna do Produto
                                         0,;                                                   //---nAliqFec   - Alíquota do FECOP do Produto
                                         (cAliasSFT)->FT_CFOP,;                                //---cCFOP      - CFOP
                                         Right((cAliasSFT)->FT_CLASFIS,2),;                    //---cCST       - CST ICMS
                                         (cAliasSFT)->FT_QUANT,;                               //---nQtdade    - Quantidade informada no Documento Fiscal
                                         (cAliasSFT)->FT_PRCUNIT,;                             //---nVlrUnit   - Valor Unitário do Item da Nota Fiscal
                                         (cAliasSFT)->FT_TOTAL,;                               //---nVlrTotPrd - Valor Total do Produto
                                         (cAliasSFT)->FT_FRETE,;                               //---nVlrFrete  - Valor do Frete
                                         (cAliasSFT)->FT_SEGURO,;                              //---nVlrSeguro - Valor do Seguro
                                         (cAliasSFT)->FT_DESPESA,;                             //---nVlrDesp   - Valor das Despesas
                                         (cAliasSFT)->FT_DESCONT,;                             //---nVlrDesc   - Valor do Desconto
                                         (cAliasSFT)->FT_VALCONT,;                             //---nVlrTotNf  - Valor Total da Nota Fiscal
                                         (cAliasSFT)->FT_ALIQICM,;                             //---nVlrAICMS  - Alíquota do ICMS
                                         (cAliasSFT)->FT_VALICM,;                              //---nVlrICMS   - Valor do ICMS
                                         (cAliasSFT)->FT__BCST,;                               //---nVlrBICMST - Valor da Base de Cálculo do ICMS-ST
                                         (cAliasSFT)->FT__VLRST,;                              //---nVlrICMSST - Valor do ICMS-ST
                                         (cAliasSFT)->FT_MARGEM,;                              //---nVlrMVAOp  - MVA da Operação de Entrada
                                         (cAliasSFT)->FT__RESRET,;                             //---cRespRet   - Responsável pela retenção do ICMS-ST (1 – Remetente Direto / 2 – Remetente Indireto / 3 – Próprio declarante )---//
                                         '',;                                                  //---cPrdResVSN - Indicador de cálculo de Ressarcimento em caso de saída interna para Optante pelo Simples Nacional (1–Sim / 2–Não)---//
                                         aDocOriApu)                                           //---aDocOriApu - Valores apurados para o Documento Fiscal Original, em casos de movimentos de devolução

                    //---Seto atributo cAnoMes para o mesmo período do movimento analisado, que é anterior ao da apuração, para que seja possível a apuração de devoluções---//
                    oApurEntAn:SetAnoMes(Left(DtoS((cAliasSFT)->FT_DATAMOV),6))

                    //---Método ApuraMovim: Para Para Entradas: Define o ICMS Suportado / Alimenta objeto o1100                      ---//
                    //---                   Para Saídas.......: Define o ICMS Efetivo   / Alimenta objetos o1200, o1300, o1400, o1500---//
                    //---                   Carrega os valores apurados no objeto oMovimento                                         ---//
                    oApurEntAn:ApuraMovim()

                    //---Seto atributo cAnoMes para o período apurado, para correta gravação---//
                    oApurEntAn:SetAnoMes(cAnoMes)

                    AcessF1M('2',cAliasSFT,oApurEntAn)

                ElseIf cTipoRet == '3' //--- 3-Alíquota Interna Efetiva ---//
                    nAliqEfet := aAliqEfet[1]
                    nAliqFec  := (cAliasSFT)->FT__ALQFEC
                    nQtdade   := 0
                EndIf

                (cAliasSFT)->(DbSkip())
            EndDo
            (cAliasSFT)->(DbCloseArea()) 

            //---Período Anterior---//
            dDataDe	 := FirstDay(dDataDe-1)
            dDataAte := LastDay(dDataDe)
    	EndDo

        If cTipoRet == '1'
            Self:nVlrRessSN := nVlrRessSN
        ElseIf cTipoRet == '2'
            aSBCICMSST[1] := oApurEntAn:o1100:Get1100DSB() //---Base de Cálculo ICMS-ST---//
            aSBCICMSST[2] := oApurEntAn:o1100:Get1100D05() //---Valor ICMS Suportado---//
            aSBCICMSST[3] := oApurEntAn:o1100:Get1100D03() //---Valor Menor Unitário---//
            aSBCICMSST[4] := oApurEntAn:o1100:Get1100D02() //---Quantidade---//
            aSBCICMSST[5] := oApurEntAn:o1100:Get1100DAL() //---Alíquota ICMS Próprio Última Entrada---//
            aSBCICMSST[6] := oApurEntAn:o1100:Get1100DMV() //---MVA Última Entrada ---//
            Self:aSBCICMSST := aSBCICMSST
        ElseIf cTipoRet == '3'
            Self:aAliqEfFec := {nAliqEfet,nAliqFec}
        EndIf
    
    EndIf

    RestArea(aArea)

Return


//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} AliqEfet

Função que retorna alíquota efetiva e base de cálculo integral em casos de redução de base de cálculo.

@author Ulisses P. Oliveira
@since 31/03/2020
@version 12.1.17
/*/
//--------------------------------------------------------------------------------------------------
Method AliqEfet(nPercEfet,nBaseRed,nAliqCheia) Class FISA240MOVIMENTOENTRADA
Local nValCalST := 0
Local aRetorno  := {0,0}

If nPercEfet > 0
    nValCalST   := Round(nBaseRed * (nAliqCheia / 100), 2)   //---Valor do ICMS-ST calculado pela multiplicação dos campos nBaseRed e nAliqCheia---//
    aRetorno[1] := Round(nAliqCheia * (nPercEfet / 100), 2)  //---Alíquota Efetiva---//
    aRetorno[2] := Round(nValCalST / (aRetorno[1] / 100), 2) //---Base de Cálculo Integral---//
Else
    aRetorno[1] := nAliqCheia                                //---Alíquota Efetiva---//
    aRetorno[2] := nBaseRed                                  //---Base de Cálculo Integral---//
EndIf

Return aRetorno
