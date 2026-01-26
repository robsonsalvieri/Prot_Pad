#INCLUDE "PROTHEUS.CH"

//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} FISA230A
  
Definição da Estrutura de Classes para a DRCST - Demonstrativo para Apuração Mensal do Ressarcimento, 
da Restituição e da Complementação do ICMS Substituição Tributária, do Estado de Santa Catarina.
O método de apuração é determinado pelo Decreto Nº 1818 DE 28/11/2018 e pela Portaria SEF N° 378/2018.

@author Ulisses P. Oliveira
@since 21/03/2019
@version 1.0
/*/
//--------------------------------------------------------------------------------------------------


//==================================================================================================
/*/{Protheus.doc} Classe FISA230APURACAO

Classe responsável pela apuração de cada movimento da query principal, os quais carregarão dados 
necessários para o cálculo dos registros 2112, 2120, 2110 e 2100. 
 
@author Ulisses P. Oliveira
@since 21/03/2019
@version 1.0
/*/
//==================================================================================================
CLASS FISA230APURACAO FROM LongClassName

Data cIdApur     As Character //---Identificador da Apuração                              ---//
Data cFilApur    As Character //---Código da Filial apurada                               ---//
Data cAnoMes     As Character //---Período da Apuração                                    ---//
Data aDtIniReCo  As Array     //---Data de início: Restituição, Complemento, Ressarcimento---//
Data aDtIniReg   As Array     //---Data de início: Registros 2115, 2133, 2121, 2134       ---//
Data o2112       As Object    //---Objeto que controla o Registro 2112                    ---//
Data o2120       As Object    //---Objeto que controla o Registro 2120                    ---//
Data o2121       As Object    //---Objeto que controla o Registro 2121                    ---//
Data o2110       As Object    //---Objeto que controla o Registro 2110                    ---//
Data o2100       As Object    //---Objeto que controla o Registro 2100                    ---//
Data oMovimento  As Object    //---Objeto que controla o movimento analisado              ---//
Data lReg2115                 //---Indicador de vigência do Registro 2115                 ---//
Data lReg2133                 //---Indicador de vigência do Registro 2133                 ---//
Data lReg2121                 //---Indicador de vigência do Registro 2121                 ---//
Data lReg2134                 //---Indicador de vigência do Registro 2134                 ---//

Method New(cIdApur,cAnoMes,aDtIniReCo,aDtIniReg) CONSTRUCTOR
Method SetaMovim(dDataMov,cTipoMov,cNumSerECF,cTipoDoc,cCodProd,cTipoPart,cPartOptSN,nAliqInt,cCFOP,cCST,nQtdade,cUnid,nFatorC,cFatorCTp,nVlrTotNf,nVlrBICMS,nVlrAICMS,nVlrICMS,nVlrBICMST,nVlrAICMST,nVlrICMSST,cRespRet,lTagRetAnt,cPrdResVSN,nPercRess,aDocOriApu,cCodAju,cCodDA,cNumDare)
Method ApuraMovim(nEntPerAnt)
Method ApuraProd(nQtdEstPrd,nQtdPerAnt,aQtdPerAnt,nEntPerAnt)
Method ApuraPer()
Method ClearProd()
Method DefIniReg()

//---Getters e Setters---//
Method SetAnoMes(cAnoMes)
Method SetReg2115(lReg2115)
Method SetReg2133(lReg2133)
Method SetReg2121(lReg2121)
Method SetReg2134(lReg2134)
Method GetIdApur()
Method GetAnoMes()
Method GetIniReCo()
Method GetIniReg()
Method GetReg2115()
Method GetReg2133()
Method GetReg2121()
Method GetReg2134()

ENDCLASS


//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} New()
  
Método construtor da Classe FISA230APURACAO

@author Ulisses P. Oliveira
@since 21/03/2019
@version 1.0
/*/
//--------------------------------------------------------------------------------------------------
Method New(cIdApur,cAnoMes,aDtIniReCo,aDtIniReg) Class FISA230APURACAO
	Self:cIdApur    := cIdApur
	Self:cFilApur   := ""
	Self:cAnoMes    := cAnoMes
    Self:aDtIniReCo := aDtIniReCo
    Self:aDtIniReg  := aDtIniReg
    Self:o2112      := FISA2302112():New()
    Self:o2120      := FISA2302120():New()
    Self:o2121      := FISA2302121():New()
    Self:o2110      := FISA2302110():New()
    Self:o2100      := FISA2302100():New()
    Self:oMovimento := FISA230MOVIMENTO():New()
    Self:DefIniReg()
Return Self


//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} SetaMovim()
  
Método que carrega no objeto o movimento a ser analisado. 
Deve ser chamado a cada movimento encontrado para o produto em questão.

@author Ulisses P. Oliveira
@since 21/03/2019
@version 1.0
/*/
//--------------------------------------------------------------------------------------------------
Method SetaMovim(dDataMov,cTipoMov,cNumSerECF,cTipoDoc,cCodProd,cTipoPart,cPartOptSN,nAliqInt,cCFOP,cCST,nQtdade,cUnid,nFatorC,cFatorCTp,nVlrTotNf,nVlrBICMS,nVlrAICMS,nVlrICMS,nVlrBICMST,nVlrAICMST,nVlrICMSST,cRespRet,lTagRetAnt,cPrdResVSN,nPercRess,aDocOriApu,cCodAju,cCodDA,cNumDare) Class FISA230APURACAO
    Self:oMovimento:SetDataMov(dDataMov)
    Self:oMovimento:SetTipoMov(cTipoMov)
    Self:oMovimento:SetNSerECF(cNumSerECF)
    Self:oMovimento:SetTipoDoc(cTipoDoc)
    Self:oMovimento:SetCodProd(cCodProd)
    Self:oMovimento:SetTipoPar(cTipoPart)
    Self:oMovimento:SetOptSN(cPartOptSN)
    Self:oMovimento:SetAliqInt(nAliqInt)
    Self:oMovimento:SetCFOP(cCFOP)
    Self:oMovimento:SetCST(cCST)
    Self:oMovimento:SetQtdade(nQtdade)
    Self:oMovimento:SetUnid(cUnid)
    Self:oMovimento:SetFatorC(nFatorC)
    Self:oMovimento:SetFatorTp(cFatorCTp)
    Self:oMovimento:SetTotNf(nVlrTotNf)
    Self:oMovimento:SetBICMS(nVlrBICMS)
    Self:oMovimento:SetAICMS(nVlrAICMS)
    Self:oMovimento:SetVICMS(nVlrICMS)
    Self:oMovimento:SetBICMST(nVlrBICMST)
    Self:oMovimento:SetAICMST(nVlrAICMST)
    Self:oMovimento:SetVICMSST(nVlrICMSST)
    Self:oMovimento:SetRespRet(cRespRet)
    Self:oMovimento:SetTagAnt(lTagRetAnt)
    Self:oMovimento:SetPrResSN(cPrdResVSN)
    Self:oMovimento:SetPerRess(nPercRess)
    Self:oMovimento:SetDocOrig(aDocOriApu)
    Self:oMovimento:SetCodAju(cCodAju)
    Self:oMovimento:SetCodDA(cCodDA)
    Self:oMovimento:SetNumDare(cNumDare)
    Self:oMovimento:SetGrvMov(.F.)
Return


//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} ApuraMovim()
  
Método responsável por avaliar cada movimento.
Entradas:
Saídas..:

@author Ulisses P. Oliveira
@since 21/03/2019
@version 1.0
/*/
//--------------------------------------------------------------------------------------------------
Method ApuraMovim(nEntPerAnt) Class FISA230APURACAO
    Local cAnoMes     := Self:GetAnoMes()
    Local cCodProd    := Self:oMovimento:GetCodProd()
    Local dDataMov    := Self:oMovimento:GetDataMov()
    Local cTipoMov    := Self:oMovimento:GetTipoMov()
    Local cTipoDoc    := Self:oMovimento:GetTipoDoc()
    Local nQtdade     := Self:oMovimento:GetQtdade()
    Local nAliqInt    := Self:oMovimento:GetAliqInt()
    Local nVlrBICMST  := Self:oMovimento:GetBICMST()
    Local nVlrAICMST  := Self:oMovimento:GetAICMST()
    Local nVlrICMSST  := Self:oMovimento:GetVICMSST()
    Local nVlrBICMS   := Self:oMovimento:GetBICMS()
    Local nVlrAICMS   := Self:oMovimento:GetAICMS()
    Local nVlrICMS    := Self:oMovimento:GetVICMS()
    Local cUnid       := Self:oMovimento:GetUnid()
    Local nFatorC     := Self:oMovimento:GetFatorC()
    Local cFatorCTp   := Self:oMovimento:GetFatorTp()
    Local nVlrTotNf   := Self:oMovimento:GetTotNf()
    Local nPercRess   := Self:oMovimento:GetPerRess()
    Local aDocOriApu  := Self:oMovimento:GetDocOrig()
    Local cRespRet    := Self:oMovimento:GetRespRet()
    Local lTagRetAnt  := Self:oMovimento:GetTagAnt()
    Local cPartOptSN  := Self:oMovimento:GetOptSN()
    Local cCodPr2110  := Self:o2110:GetCampo02()
    Local aDtIniReCo  := Self:GetiniReCo()
    Local lReg2121    := Self:GetReg2121()
    Local cTipoOper   := ''
    Local nVlCMVASN   := 0
    Local lGravaMov   := .F.
    Local nVlrBINTST  := 0
    Local nVlrAEFEST  := 0
    Local nVlrCALCST  := 0
    Local nQtdadeC    := 0
    Local oMovEntr    := Nil

    If (cCodProd == cCodPr2110) .Or. Empty(cCodPr2110)
        Self:o2110:SetCampo02(cCodProd)
        Self:o2110:SetCampo09(nAliqInt)

        //---Conversão da quantidade da unidade de medida informada no documento fiscal para a unidade de medida constante no Registro 0200 (Inventário)---//
        nFatorC  := Round(Iif(cFatorCTp == 'M', nFatorC, (1/nFatorC)), 6)
        nQtdadeC := Round(nQtdade * nFatorC, 5)

        If (cTipoMov=='E' .And. cTipoDoc != 'D') .Or. (cTipoMov=='S' .And. cTipoDoc == 'D' .And. Left(DtoS(aDocOriApu[1]),6) == cAnoMes) //---Para Entradas: Alimenta objeto o2120 ---//

            //---Ajusta Base/Aliquota/Valor de ICMS Próprio e ST seguindo regras definidas para Registro 2130---//
            If cTipoDoc != 'D'

                //---ICMS ST---//
                nVlrICMSST := Iif(!lReg2121 .Or. nVlrBICMST > 0,nVlrICMSST,0)
                nVlrAICMST := Iif(cRespRet == '2',nAliqInt,nVlrAICMST)
                nVlrCALCST := Round((nVlrBICMST*nVlrAICMST)/100, 2)                                       //---Valor do ICMS-ST calculado pela multiplicação dos campos nVlrBICMST e nVlrAICMST e dos campos nVlrBINTST e nVlrAEFEST
                nVlrBINTST := Iif(nVlrAICMST <> nAliqInt, Round(nVlrCALCST/(nAliqInt/100),2), nVlrBICMST) //---Base de Calculo Integral
                nVlrAEFEST := Iif(nVlrAICMST <> nAliqInt, nAliqInt                          , nVlrAICMST) //---Alíquota efetiva caso a MERCADORIA seja contemplada com REDUÇÃO DA BASE DE CÁLCULO

                //---ICMS Próprio---//
                If cRespRet == '2' .Or. cPartOptSN == '1'
                    nVlrBICMS  := 0
                    nVlrAICMS  := 0
                    nVlrICMS   := Iif(!lReg2121 .Or. lTagRetAnt, nVlrCALCST-nVlrICMSST, 0)                 //---Valor informado será o resultado da diferença do campo nVlrCALCST deduzido do campo nVlrICMSST
                EndIf

            Else
                nVlrBICMS  := Round((aDocOriApu[4]/aDocOriApu[2])*nQtdadeC,2)
                nVlrAICMS  := aDocOriApu[5]
                nVlrICMS   := Round((aDocOriApu[6]/aDocOriApu[2])*nQtdadeC,2)
                nVlrBICMST := Round((aDocOriApu[7]/aDocOriApu[2])*nQtdadeC,2)
                nVlrAICMST := aDocOriApu[8]
                nVlrICMSST := Round((aDocOriApu[9]/aDocOriApu[2])*nQtdadeC,2)
                nVlrBINTST := Round((aDocOriApu[10]/aDocOriApu[2])*nQtdadeC,2)
                nVlrAEFEST := aDocOriApu[11]
                nVlrCALCST := Round((aDocOriApu[12]/aDocOriApu[2])*nQtdadeC,2)
                cRespRet   := ''
            EndIf

            //---Alimenta objeto o2120---//
            Self:o2120:Inc2120(cTipoDoc,cRespRet,lTagRetAnt,nQtdadeC,nVlrBINTST,nVlrICMS,nVlrICMSST,lReg2121)

            //---Alimenta objeto o2121---//
            Self:o2121:Inc2121(cTipoDoc,cRespRet,lTagRetAnt,nQtdadeC,nVlrBINTST)

            //---Controla a Gravação do Movimento---//
            Self:oMovimento:SetGrvMov(.T.)
            Self:oMovimento:SetOrdMov(Self:oMovimento:GetOrdMov()+1)

        ElseIf (cTipoMov=='S' .And. cTipoDoc != 'D') .Or. (cTipoMov=='E' .And. cTipoDoc == 'D' .And. Left(DtoS(aDocOriApu[1]),6) == cAnoMes) //---Para Saídas: Alimenta objeto o2112 / Alimenta objeto o2110 ---//

            //---Classifica operação de saída---//
            cTipoOper := Self:oMovimento:EnquadMov(aDtIniReCo)

            If !Empty(cTipoOper)

                If cTipoOper == '99' //---99 - Venda à consumidor final emitida por ECF---//

                    If cTipoDoc != 'D' //---Para Devoluções: Não atualiza objetos de cálculo---//

                        lGravaMov := .T.

                        //---Alimenta objeto o2112---//
                        Self:o2112:Inc2112(nQtdade,cUnid,nFatorC,nQtdadeC,nVlrTotNf)

                    EndIf

                Else

                    //---Calcula o valor à ressarcir em casos de saídas para Simples Nacional---//
                    If cTipoOper == '30'
                        If cTipoDoc != 'D'
                            oMovEntr := FISA230MOVIMENTOENTRADA():New()
                            oMovEntr:cTipoRet := '1' //---Ressarcimento em Saída Interna p/ Simples Nacional---//
                            oMovEntr:cCodProd  := cCodProd
                            oMovEntr:nQtdade   := nQtdadeC
                            oMovEntr:dDataMov  := dDataMov
                            oMovEntr:nAliqInt  := nAliqInt
                            oMovEntr:nPercRess := nPercRess
                            oMovEntr:nEntPerAnt:= nEntPerAnt
                            oMovEntr:ProcUltEnt()
                            nVlCMVASN := oMovEntr:nVlrRessSN
                            FreeObj(oMovEntr)
                        Else
                            nVlCMVASN := Round((aDocOriApu[3]/aDocOriApu[2])*nQtdadeC,2)
                        EndIf
                    EndIf

                    If cTipoOper != '30' .Or. nVlCMVASN > 0

                        lGravaMov := .T.

                        //---Alimenta objeto o2110---//
                        Self:o2110:Inc2110(cTipoDoc,cTipoOper,nQtdadeC,nVlrTotNf,nVlCMVASN)

                    EndIf

                EndIf

                //---Controla a Gravação do Movimento---//
                If lGravaMov
                    Self:oMovimento:SetGrvMov(lGravaMov)
                    Self:oMovimento:SetOrdMov(Self:oMovimento:GetOrdMov()+1)
                EndIf

            EndIf

        EndIf

        //---Carrega os valores apurados para o movimento---//
        Self:oMovimento:SetFatorC(nFatorC)
        Self:oMovimento:SetQtdadeC(nQtdadeC)

        If (cTipoMov=='E' .And. cTipoDoc != 'D') .Or. (cTipoMov=='S' .And. cTipoDoc == 'D')

            //---Valores de Tipo de Operação e Valor de Ressarcimento zerados para movimentos de entrada (não serão gravados)---//
            Self:oMovimento:SetTpOper('')
            Self:oMovimento:SetCredSSN(0)

            //---Valores Base/Aliquota/Valor de ICMS Próprio e ST seguindo regras definidas para Registro 2130---//
            Self:oMovimento:SetBICMS(nVlrBICMS) 
            Self:oMovimento:SetAICMS(nVlrAICMS) 
            Self:oMovimento:SetVICMS(nVlrICMS)  
            Self:oMovimento:SetBICMST(nVlrBICMST)
            Self:oMovimento:SetAICMST(nVlrAICMST)
            Self:oMovimento:SetVICMSST(nVlrICMSST)
            Self:oMovimento:SetBINTST(nVlrBINTST)
            Self:oMovimento:SetAEFEST(nVlrAEFEST)
            Self:oMovimento:SetCALCST(nVlrCALCST)
            Self:oMovimento:SetRespRet(cRespRet)  

        ElseIf (cTipoMov=='S' .And. cTipoDoc != 'D') .Or. (cTipoMov=='E' .And. cTipoDoc == 'D')

            //---Valores de Tipo de Operação e Valor de Ressarcimento seguindo regras definidas para Registro 2113---//
            Self:oMovimento:SetTpOper(cTipoOper)
            Self:oMovimento:SetCredSSN(nVlCMVASN)
            
            //---Valores de Base/Alíquota/Valor de ICMS Próprio e ST zerados para movimentos de saída (não serão gravados)---//
            Self:oMovimento:SetBICMS(0)
            Self:oMovimento:SetAICMS(0)
            Self:oMovimento:SetVICMS(0)
            Self:oMovimento:SetBICMST(0)
            Self:oMovimento:SetAICMST(0)
            Self:oMovimento:SetVICMSST(0)
            Self:oMovimento:SetBINTST(0)
            Self:oMovimento:SetAEFEST(0)
            Self:oMovimento:SetCALCST(0)
            Self:oMovimento:SetRespRet('')

        EndIf
        //---FIM Carrega os valores apurados para o movimento---//

    Else
        Self:ClearProd()
    EndIf

Return


//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} ApuraProd()
  
Método responsável por calcular totais do produto nos objetos o2120 e o2110 e alimentar o objeto o2100.

@author Ulisses P. Oliveira
@since 27/03/2019
@version 1.0
/*/
//--------------------------------------------------------------------------------------------------
Method ApuraProd(nQtdEstPrd,nQtdPerAnt,aQtdPerAnt,nEntPerAnt) Class FISA230APURACAO
    Local cAnoMes    := Self:GetAnoMes()
    Local aDtIniReCo := Self:GetIniReCo()
    Local lReg2121   := Self:GetReg2121()

    Local nSQtdeC    := Self:o2120:GetCampo02()
    Local nSBICMSTIn := Self:o2120:GetCampo03()
    Local nSVlrICMS  := Self:o2120:GetCampo05()
    Local nSVlrICMST := Self:o2120:GetCampo07()
    Local lShow2120  := Self:o2120:GetShw2120()

    Local nSQtdeCT   := Self:o2121:GetCampo02()
    Local nSQtdeCVlM := Self:o2121:GetCampo03()
    Local nSBICMSTVM := Self:o2121:GetCampo04()
    Local lShow2121  := Self:o2121:GetShw2121()

    Local nQtdeVCfC  := Self:o2112:GetCampo05()
    Local nVlVCf     := Self:o2112:GetCampo06()

    Local cCodItem   := Self:o2110:GetCampo02()
    Local nQtdeTVCF  := Self:o2110:GetCampo03()
    Local nVlTVCF    := Self:o2110:GetCampo04()
    Local nAliqEf    := Self:o2110:GetCampo09()
    Local nQtdeTSOE  := Self:o2110:GetCampo12()
    Local nQtdeTSSN  := Self:o2110:GetCampo15()
    Local nVlTCMVASN := Self:o2110:GetCampo16()

    //---Objeto o2120---//
    Local nVlrMUnBST := 0
    Local nVlrMUnICM := 0
    Local nVlrMUnIST := 0

    //---Objeto o2121---//
    Local nVlrMUBSTG := 0

    //---Objeto o2110---//
    Local nVlMUniVCF := 0
    Local nVlTBSTVCF := 0
    Local nVlDMaiBST := 0
    Local nVlDMenBST := 0
    Local nVlICMSTRt := 0
    Local nVlICMSTCp := 0
    Local nVlICMSOE  := 0
    Local nVlICMSTOE := 0
    Local nVlrMUBSTU := 0

    //---Objeto o2100---//
    Local nSVlICSTRt := 0
    Local nSVlICSTCp := 0
    Local nSdICMSTRe := 0
    Local nSdICMSOp  := 0
    Local lDtIniComp := .F.
    Local cDtIniComp := ''

    Local oMovEntr   := Nil
    Local aSBCICMSST := {}
    Local nSQtdeCVld := 0

    //------------------------------------------------------------------------------------------------------------------------------------------------------//
    /* Verificação de Quantidade de Entradas X Quantidades de Saída e Quantidades em Estoque
    
       Segundo o Decreto Nº 1818 DE 28/11/2018, Art. 25-A Inciso II § 4º e § 5º, e na validação dos Campos: S_QUANT_C (2120) e S_QUANT_C_T (2121), a quantidade de 
       entradas deve ser maior ou igual ao somatório da quantidade de saídas e à quantidade em estoque ao final do período apurado. Sempre que a quantidade 
       das entradas de cada produto for menor que o somatório das saídas e dos respectivos estoques no período, será obrigatório, para fins do 
       cálculo da média, a adição das entradas ocorridas no período de referência anterior ou anteriores, até que se satisfaça essa condição.

       -Antes do início de vigência da Portaria 343/2019, o campo S_QUANT_C, do registro 2120, é o único a ser usado como base para a validação da condição acima.
       
       -Após a vigência da Portaria 343/2019, que instituiu o Registro 2121, caso este seja apresentado, o campo S_QUANT_C_T desse registro será usado como base 
       para a validação da condição imposta. Caso contrário, será utilizado o campo S_QUANT_C, do registro 2120.
    */
    //------------------------------------------------------------------------------------------------------------------------------------------------------//
    nSQtdeCVld := Iif(lReg2121, nSQtdeCT, nSQtdeC)

    If nSQtdeCVld < (nQtdeTVCF + nQtdeVCfC + nQtdeTSOE + nQtdeTSSN + nQtdEstPrd)

        If nQtdPerAnt >= (nQtdeTVCF + nQtdeVCfC + nQtdeTSOE + nQtdeTSSN + nQtdEstPrd) - nSQtdeCVld

            oMovEntr := FISA230MOVIMENTOENTRADA():New()
            oMovEntr:cTipoRet   := '2' //---Base de Cálculo ICMS-ST / Valor ICMS-ST / Valor ICMS / Quantidade (Somatórios para cálculo de média)---//
            oMovEntr:cCodProd   := cCodItem
            oMovEntr:nQtdade    := (nQtdeTVCF + nQtdeVCfC + nQtdeTSOE + nQtdeTSSN + nQtdEstPrd) - nSQtdeCVld
            oMovEntr:nQtdadeAnt := nQtdPerAnt
            oMovEntr:aQtdadeAnt := aQtdPerAnt
            oMovEntr:dDataMov   := StoD(cAnoMes+'01')-1
            oMovEntr:nAliqInt   := nAliqEf
            oMovEntr:cIdApur    := Self:GetIdApur()
            oMovEntr:cAnoMes    := cAnoMes
            oMovEntr:nOrdMovAtu := Self:oMovimento:GetOrdMov()
            oMovEntr:nEntPerAnt := nEntPerAnt
            oMovEntr:ProcUltEnt()
            aSBCICMSST := oMovEntr:aSBCICMSST
            FreeObj(oMovEntr)

            nSBICMSTIn += aSBCICMSST[1]
            nSVlrICMST += aSBCICMSST[2]
            nSVlrICMS  += aSBCICMSST[3]
            nSQtdeC    += aSBCICMSST[4]
            lShow2121  := Iif(!lShow2121, aSBCICMSST[5], lShow2121)
            nSBICMSTVM += aSBCICMSST[6]
            nSQtdeCT   += aSBCICMSST[7]
            nSQtdeCVlM += aSBCICMSST[8]

            Self:o2120:SetCampo02(nSQtdeC)
            Self:o2120:SetCampo03(nSBICMSTIn)
            Self:o2120:SetCampo05(nSVlrICMS)
            Self:o2120:SetCampo07(nSVlrICMST) 
            Self:o2121:SetShw2121(lShow2121)
            Self:o2121:SetCampo04(nSBICMSTVM)
            Self:o2121:SetCampo02(nSQtdeCT)
            Self:o2121:SetCampo03(nSQtdeCVlM)

        EndIf

    EndIf

    //---Calcula campos do objeto o2120---//
    nVlrMUnBST := Round((nSBICMSTIn / nSQtdeC),3)       //---[04] Valor médio unitário da base de cálculo da substituição tributária resultado da divisão do campo 03 pelo campo 02 deste registro---//
    nVlrMUnICM := Round((nSVlrICMS  / nSQtdeC),3)       //---[06] Valor médio unitário do valor do ICMS sobre operações próprias resultado da divisão do campo 05 pelo campo 02 deste registro---//
    nVlrMUnIST := Round((nSVlrICMST / nSQtdeC),3)       //---[08] Valor médio unitário do valor do ICMS_ST resultado da divisão do campo 07 pelo campo 02 deste registro ---//
    Self:o2120:SetCampo04(nVlrMUnBST)
    Self:o2120:SetCampo06(nVlrMUnICM)
    Self:o2120:SetCampo08(nVlrMUnIST)

    //---Calcula campos do objeto o2121---//
    nVlrMUBSTG := Round((nSBICMSTVM / nSQtdeCVlM),3)    //---[05] Valor médio unitário da base de cálculo da substituição tributária resultante da divisão do campo 04 pelo campo 03 deste registro---//
    Self:o2121:SetCampo05(nVlrMUBSTG)

    //---Calcula campos do objeto o2110---//
    nQtdeTVCF  += nQtdeVCfC                             //---[03] Preencher com a soma dos campos 05 do Registro 2112 e 13 do Registro 2113, do IND_S de código 10, deduzidas das devoluções---//
    nVlTVCF    += nVlVCf                                //---[04] Preencher com a soma dos campos 06 do Registro 2112 e 14 do Registro 2113, do IND_S de código 10, deduzidas das devoluções---//
    nVlMUniVCF := Round((nVlTVCF / nQtdeTVCF),3)        //---[05] Preencher com o resultado da divisão do campo 04 pelo campo 03 deste registro---//

    //---Define Média Base ST utilizada: 2120 ou 2121---//
    nVlrMUBSTU := nVlrMUnBST
    If lReg2121
        If nVlMUniVCF < nVlrMUnBST .And. nVlMUniVCF < nVlrMUBSTG
            nVlrMUBSTU := nVlrMUnBST                    //---Restituição...: 2120---//
        ElseIf nVlMUniVCF > nVlrMUnBST .And. nVlMUniVCF > nVlrMUBSTG
            nVlrMUBSTU := nVlrMUBSTG                    //---Complementação: 2121---//
        Else
            If nVlrMUnBST < nVlrMUBSTG                  //---A Portaria 343/2019 não é clara na situação onde, dependendo da média (2120 ou 2121), poderia ser apurada Restituição ou Complementação. Neste caso, tomamos a menor média (Complemento -> pró fisco)---//
                nVlrMUBSTU := nVlrMUnBST
            Else
                nVlrMUBSTU := nVlrMUBSTG
            Endif
        EndIf
    EndIf   
    nVlTBSTVCF := Round((nQtdeTVCF * nVlrMUBSTU),2)     //---[06] Sempre que apurar complementação de imposto preencher com o produto do campo 03 deste registro pelo campo 05 do Registro 2121, ou quando apurada restituição preencher com o produto do campo 03 deste registro pelo campo 04 do Registro 2120.---//

    If nVlTBSTVCF > nVlTVCF
        nVlDMaiBST := nVlTBSTVCF - nVlTVCF              //---[07] Preencher com o valor positivo da diferença entre o campo 06 e o campo 04 deste registro---//
    Else
        nVlDMenBST := nVlTVCF - nVlTBSTVCF              //---[08] Preencher com o valor positivo da diferença entre o campo 04 e o campo 06 deste registro---//
    EndIf

    nVlICMSTRt := Round(((nVlDMaiBST * nAliqEf)/100),2) //---[10] Preencher com o produto do campo 07 pelo campo 09 deste registro---//
    nVlICMSTCp := Round(((nVlDMenBST * nAliqEf)/100),2) //---[11] Preencher com o produto do campo 08 pelo campo 09 deste registro---//
    nVlICMSOE  := Round((nVlrMUnICM  * nQtdeTSOE),2)    //---[13] Preencher com o resultado da multiplicação do campo 06 do Registro 2120 pelo campo 12 deste registro---//
    nVlICMSTOE := Round((nVlrMUnIST  * nQtdeTSOE),2)    //---[14] Preencher com o resultado da multiplicação do campo 08 do Registro 2120 pelo campo 12 deste registro---//

    //---Proporcionaliza valores de Restituição e Ressarcimento (Interestadual)---//
    If lReg2121 .And. (nVlICMSTRt > 0 .Or. (nVlICMSOE + nVlICMSTOE) > 0)
        If nVlICMSTRt > 0 .And. (nVlICMSOE + nVlICMSTOE) == 0 .And. nSQtdeC < nQtdeTVCF
            nVlICMSTRt := Round(((nVlDMaiBST * nAliqEf)/100) * (nSQtdeC/nQtdeTVCF),2)
        ElseIf nVlICMSTRt == 0 .And. (nVlICMSOE + nVlICMSTOE) > 0 .And. nSQtdeC < nQtdeTSOE
            nVlICMSOE  := Round((nVlrMUnICM  * nQtdeTSOE) * (nSQtdeC/nQtdeTSOE),2)
            nVlICMSTOE := Round((nVlrMUnIST  * nQtdeTSOE) * (nSQtdeC/nQtdeTSOE),2)
        ElseIf nVlICMSTRt > 0 .And. (nVlICMSOE + nVlICMSTOE) > 0 .And. nSQtdeC < (nQtdeTVCF + nQtdeTSOE)
            nVlICMSTRt := Round(((nVlDMaiBST * nAliqEf)/100) * (nSQtdeC/(nQtdeTVCF + nQtdeTSOE)),2)
            nVlICMSOE  := Round((nVlrMUnICM  * nQtdeTSOE) * (nSQtdeC/(nQtdeTVCF + nQtdeTSOE)),2)
            nVlICMSTOE := Round((nVlrMUnIST  * nQtdeTSOE) * (nSQtdeC/(nQtdeTVCF + nQtdeTSOE)),2)
        EndIf
    EndIf

    //---Define Apresentação dos Registros 2120 e 2121---//
    If lReg2121
        If lShow2121
            If (nVlICMSTRt > 0 .Or. (nVlICMSOE + nVlICMSTOE) > 0)
                lShow2120 := .T.    
            EndIf
        Else
            lShow2120 := .T.
        EndIf
    Else
        lShow2120 := .T.
        lShow2121 := .F.
    EndIf
    Self:o2120:SetShw2120(lShow2120)
    Self:o2121:SetShw2121(lShow2121)

    Self:o2110:SetCampo03(nQtdeTVCF)
    Self:o2110:SetCampo04(nVlTVCF)
    Self:o2110:SetCampo05(nVlMUniVCF)
    Self:o2110:SetCampo06(nVlTBSTVCF)
    Self:o2110:SetCampo07(nVlDMaiBST)
    Self:o2110:SetCampo08(nVlDMenBST)
    Self:o2110:SetCampo10(nVlICMSTRt)
    Self:o2110:SetCampo11(nVlICMSTCp)
    Self:o2110:SetCampo13(nVlICMSOE)
    Self:o2110:SetCampo14(nVlICMSTOE)

    //---Alimenta objeto o2100---//
    If Len(aDtIniReCo) == 3
        cDtIniComp := Left(DtoS(CtoD(aDtIniReCo[2])),6)
        lDtIniComp := Iif(cAnoMes >= cDtIniComp,.T.,.F.) //---Art. 25-C. Decreto Nº 86 DE 05/04/2019---//
    EndIf

    nSVlICSTRt += nVlICMSTRt                      //---[02] S_VL_ICMS_ST_REST   -> Soma dos campos [10] VL_ICMS_ST_REST do Registro 2110.
    nSVlICSTCp += Iif(lDtIniComp,nVlICMSTCp,0)    //---[03] S_VL_ICMS_ST_COMPL  -> O transporte da soma dos campos [11] VL_ICMS_ST_COMPL do Registro 2110,quando informado, torna-se obrigatório a partir do período de referência março de 2018. |***Alterado para janeiro de 2019, através do Decreto Nº 86 DE 05/04/2019***|
    nSdICMSTRe += nVlICMSTOE + nVlTCMVASN         //---[05] SD_ICMS_ST_RESS     -> Preencher com o valor da soma dos campos [14] VL_ICMS_ST_IND_S_OE e [16] VL_T_CREDITO_MVA_SN do Registro 2110.
    nSdICMSOp  += nVlICMSOE                       //---[07] SD_ICMS_OP          -> Soma dos campos [13] VL_ICMS_IND_S_OE do Registro 2110. 
    Self:o2100:Inc2100(nSVlICSTRt,nSVlICSTCp,nSdICMSTRe,nSdICMSOp)

Return


//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} ApuraPer()
  
Método responsável por calcular totais da apuração no objeto o2100.

@author Ulisses P. Oliveira
@since 07/04/2019
@version 1.0
/*/
//--------------------------------------------------------------------------------------------------
Method ApuraPer() Class FISA230APURACAO
    Local nSVlICSTRt := Self:o2100:GetCampo02()
    Local nSVlICSTCp := Self:o2100:GetCampo03()
    Local nSdICMSTRe := Self:o2100:GetCampo05()
    Local nSdICMSTRt := 0
    Local nSdICMSTCp := 0
    Local nVlApCrICM := 0
    Local nVlApICMCp := 0

    //---Calcula campos do objeto o2100---//
    If nSVlICSTRt > nSVlICSTCp
        nSdICMSTRt := (nSVlICSTRt - nSVlICSTCp)              //---[04] SD_ICMS_ST_REST    -> Preencher com o valor positivo da diferença entre os campos [02] e [03] deste Registro.
    Else
        nSdICMSTCp := (nSVlICSTCp - nSVlICSTRt)              //---[06] SD_ICMS_ST_COMPL   -> Preencher com o valor positivo da diferença entre os campos [03] e [02] deste Registro.
    EndIf

    If (nSdICMSTRt + nSdICMSTRe) > nSdICMSTCp
        nVlApCrICM := (nSdICMSTRt + nSdICMSTRe) - nSdICMSTCp //---[08] V_APUR_CRED_ICMS   -> Preencher com o valor positivo da diferença entre a soma dos campos [04] e [05] deduzido do campo [06] deste Registro.
    Else
        nVlApICMCp := nSdICMSTCp - (nSdICMSTRt + nSdICMSTRe) //---[09] V_APUR_ICMS_COMP   -> Preencher com o valor positivo da diferença entre o campo [06] deduzido da soma dos campos [04] e [05] deste Registro.
    EndIf

    Self:o2100:SetCampo04(nSdICMSTRt)
    Self:o2100:SetCampo06(nSdICMSTCp)
    Self:o2100:SetCampo08(nVlApCrICM)
    Self:o2100:SetCampo09(nVlApICMCp)

Return


//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} ClearProd()
  
Método responsável por limpar os valores dos objetos o2110 / o2112 / o2120 a cada produto processado.

@author Ulisses P. Oliveira
@since 27/03/2019
@version 1.0
/*/
//--------------------------------------------------------------------------------------------------
Method ClearProd() Class FISA230APURACAO
    Self:o2110:Clear2110()
    Self:o2112:Clear2112()
    Self:o2120:Clear2120()
    Self:o2121:Clear2121()
    Self:oMovimento:SetOrdMov(0)
Return

//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} DefIniReg()
  


@author Ulisses P. Oliveira
@since 24/01/2020
@version 1.0
/*/
//--------------------------------------------------------------------------------------------------
Method DefIniReg() Class FISA230APURACAO
    Local cAnoMes    := Self:GetAnoMes()
    Local aDtIniReg  := Self:GetIniReg()
    Local cDtIniReg  := ''
    Local lReg2115   := .F.
    Local lReg2133   := .F.
    Local lReg2121   := .F.
    Local lReg2134   := .F.

    If Len(aDtIniReg) == 4
        cDtIniReg  := Left(DtoS(CtoD(aDtIniReg[1])),6)
        lReg2115   := Iif(cAnoMes >= cDtIniReg,.T.,.F.)

        cDtIniReg  := Left(DtoS(CtoD(aDtIniReg[2])),6)
        lReg2133   := Iif(cAnoMes >= cDtIniReg,.T.,.F.)

        cDtIniReg  := Left(DtoS(CtoD(aDtIniReg[3])),6)
        lReg2121   := Iif(cAnoMes >= cDtIniReg,.T.,.F.)

        cDtIniReg  := Left(DtoS(CtoD(aDtIniReg[4])),6)
        lReg2134   := Iif(cAnoMes >= cDtIniReg,.T.,.F.)
    EndIf

    Self:SetReg2115(lReg2115)
    Self:SetReg2133(lReg2133)
    Self:SetReg2121(lReg2121)
    Self:SetReg2134(lReg2134)
Return


//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} Getters e Setters

@author Ulisses P. Oliveira
@since 21/03/2019
@version 1.0
/*/
//--------------------------------------------------------------------------------------------------
Method SetAnoMes(cAnoMes)  Class FISA230APURACAO
    Self:cAnoMes := cAnoMes
Return

Method SetReg2115(lReg2115) Class FISA230APURACAO
    Self:lReg2115 := lReg2115
Return

Method SetReg2133(lReg2133) Class FISA230APURACAO
    Self:lReg2133 := lReg2133
Return

Method SetReg2121(lReg2121) Class FISA230APURACAO
    Self:lReg2121 := lReg2121
Return

Method SetReg2134(lReg2134) Class FISA230APURACAO
    Self:lReg2134 := lReg2134
Return

Method GetIdApur() Class FISA230APURACAO
Return Self:cIdApur

Method GetAnoMes() Class FISA230APURACAO
Return Self:cAnoMes

Method GetIniReCo() Class FISA230APURACAO
Return Self:aDtIniReCo

Method GetIniReg() Class FISA230APURACAO
Return Self:aDtIniReg

Method GetReg2115() Class FISA230APURACAO
Return Self:lReg2115

Method GetReg2133() Class FISA230APURACAO
Return Self:lReg2133

Method GetReg2121() Class FISA230APURACAO
Return Self:lReg2121

Method GetReg2134() Class FISA230APURACAO
Return Self:lReg2134


//==================================================================================================
/*/{Protheus.doc} Classe FISA2302120

Classe responsável pelo controle do Registro 2120. 
 
@author Ulisses P. Oliveira
@since 21/03/2019
@version 1.0
/*/
//==================================================================================================
CLASS FISA2302120 FROM LongClassName

Data nSQtdeC        As Numeric   //--- ---//
Data nSBICMSTIn     As Numeric   //--- ---//
Data nVlrMUnBST     As Numeric   //--- ---//
Data nSVlrICMS      As Numeric   //--- ---//
Data nVlrMUnICM     As Numeric   //--- ---//
Data nSVlrICMST     As Numeric   //--- ---//
Data nVlrMUnIST     As Numeric   //--- ---//
Data lShow2120                   //--- ---//

Method New() CONSTRUCTOR
Method Clear2120()
Method Inc2120(cTipoDoc,cRespRet,lTagRetAnt,nQtdade,nVlrBICMST,nVlrICMS,nVlrICMSST,lReg2121)

//---Getters e Setters---//
Method SetCampo02(nSQtdeC)
Method SetCampo03(nSBICMSTIn)
Method SetCampo04(nVlrMUnBST)
Method SetCampo05(nSVlrICMS)
Method SetCampo06(nVlrMUnICM)
Method SetCampo07(nSVlrICMST)
Method SetCampo08(nVlrMUnIST)
Method SetShw2120(lShow2120)
Method GetCampo02()
Method GetCampo03()
Method GetCampo04()
Method GetCampo05()
Method GetCampo06()
Method GetCampo07()
Method GetCampo08()
Method GetShw2120()

ENDCLASS

//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} New()
  
Método construtor da Classe FISA2302120

@author Ulisses P. Oliveira
@since 21/03/2019
@version 1.0
/*/
//--------------------------------------------------------------------------------------------------
Method New() Class FISA2302120
	Self:Clear2120()
Return Self


//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} Clear2120
  
Método que limpa os valores do objeto.

@author Ulisses P. Oliveira
@since 21/03/2019
@version 1.0
/*/
//--------------------------------------------------------------------------------------------------
Method Clear2120() Class FISA2302120
	Self:nSQtdeC    := 0
	Self:nSBICMSTIn := 0
	Self:nVlrMUnBST := 0
	Self:nSVlrICMS  := 0
    Self:nVlrMUnICM := 0
    Self:nSVlrICMST := 0
    Self:nVlrMUnIST := 0
    Self:lShow2120  := .F.
Return


//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} Inc2120()
  


@author Ulisses P. Oliveira
@since 21/03/2019
@version 1.0
/*/
//--------------------------------------------------------------------------------------------------
Method Inc2120(cTipoDoc,cRespRet,lTagRetAnt,nQtdade,nVlrBICMST,nVlrICMS,nVlrICMSST,lReg2121) Class FISA2302120
    Local nSQtdeC    := Self:GetCampo02()
    Local nSBICMSTIn := Self:GetCampo03()
    Local nSVlrICMS  := Self:GetCampo05()
    Local nSVlrICMST := Self:GetCampo07()

    If !lReg2121 .Or. ((cRespRet $ '1|3') .Or. lTagRetAnt)
        If cTipoDoc != 'D'
            nSQtdeC    += nQtdade
            nSBICMSTIn += nVlrBICMST
            nSVlrICMS  += nVlrICMS
            nSVlrICMST += nVlrICMSST
        Else
            nSQtdeC    -= nQtdade
            nSBICMSTIn -= nVlrBICMST
            nSVlrICMS  -= nVlrICMS
            nSVlrICMST -= nVlrICMSST
        EndIf
    EndIf

	Self:SetCampo02(nSQtdeC)
	Self:SetCampo03(nSBICMSTIn)
	Self:SetCampo05(nSVlrICMS)
    Self:SetCampo07(nSVlrICMST)
Return


//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} Getters e Setters

@author Ulisses P. Oliveira
@since 21/03/2019
@version 1.0
/*/
//--------------------------------------------------------------------------------------------------
Method SetCampo02(nSQtdeC) Class FISA2302120
    Self:nSQtdeC := nSQtdeC
Return

Method SetCampo03(nSBICMSTIn) Class FISA2302120
    Self:nSBICMSTIn := nSBICMSTIn
Return

Method SetCampo04(nVlrMUnBST) Class FISA2302120
    Self:nVlrMUnBST := nVlrMUnBST
Return

Method SetCampo05(nSVlrICMS) Class FISA2302120
    Self:nSVlrICMS := nSVlrICMS
Return

Method SetCampo06(nVlrMUnICM) Class FISA2302120
    Self:nVlrMUnICM := nVlrMUnICM
Return

Method SetCampo07(nSVlrICMST) Class FISA2302120
    Self:nSVlrICMST := nSVlrICMST
Return

Method SetCampo08(nVlrMUnIST) Class FISA2302120
    Self:nVlrMUnIST := nVlrMUnIST
Return

Method SetShw2120(lShow2120) Class FISA2302120
    Self:lShow2120 := lShow2120
Return

Method GetCampo02() Class FISA2302120
Return Self:nSQtdeC

Method GetCampo03() Class FISA2302120
Return Self:nSBICMSTIn

Method GetCampo04() Class FISA2302120
Return Self:nVlrMUnBST

Method GetCampo05() Class FISA2302120
Return Self:nSVlrICMS

Method GetCampo06() Class FISA2302120
Return Self:nVlrMUnICM

Method GetCampo07() Class FISA2302120
Return Self:nSVlrICMST

Method GetCampo08() Class FISA2302120
Return Self:nVlrMUnIST

Method GetShw2120() Class FISA2302120
Return Self:lShow2120


//==================================================================================================
/*/{Protheus.doc} Classe FISA2302121

Classe responsável pelo controle do Registro 2121. 
 
@author Ulisses P. Oliveira
@since 22/01/2020
@version 1.0
/*/
//==================================================================================================
CLASS FISA2302121 FROM LongClassName

Data nSQtdeCT       As Numeric   //--- ---//
Data nSQtdeCVlM     As Numeric   //--- ---//
Data nSBICMSTVM     As Numeric   //--- ---//
Data nVlrMUBSTG     As Numeric   //--- ---//
Data lShow2121                   //--- ---//

Method New() CONSTRUCTOR
Method Clear2121()
Method Inc2121(cTipoDoc,cRespRet,lTagRetAnt,nQtdade,nVlrBICMST)

//---Getters e Setters---//
Method SetCampo02(nSQtdeCT)
Method SetCampo03(nSQtdeCVlM)
Method SetCampo04(nSBICMSTVM)
Method SetCampo05(nVlrMUBSTG)
Method SetShw2121(lShow2121)
Method GetCampo02()
Method GetCampo03()
Method GetCampo04()
Method GetCampo05()
Method GetShw2121()

ENDCLASS

//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} New()
  
Método construtor da Classe FISA2302121

@author Ulisses P. Oliveira
@since 22/01/2020
@version 1.0
/*/
//--------------------------------------------------------------------------------------------------
Method New() Class FISA2302121
	Self:Clear2121()
Return Self


//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} Clear2121
  
Método que limpa os valores do objeto.

@author Ulisses P. Oliveira
@since 22/01/2020
@version 1.0
/*/
//--------------------------------------------------------------------------------------------------
Method Clear2121() Class FISA2302121
	Self:nSQtdeCT   := 0
	Self:nSQtdeCVlM := 0
	Self:nSBICMSTVM := 0
	Self:nVlrMUBSTG := 0
    Self:lShow2121  := .F.
Return


//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} Inc2121()
  


@author Ulisses P. Oliveira
@since 22/01/2020
@version 1.0
/*/
//--------------------------------------------------------------------------------------------------
Method Inc2121(cTipoDoc,cRespRet,lTagRetAnt,nQtdade,nVlrBICMST) Class FISA2302121
    Local nSQtdeCT   := Self:GetCampo02()
    Local nSQtdeCVlM := Self:GetCampo03()
    Local nSBICMSTVM := Self:GetCampo04()
    Local lShow2121  := Self:GetShw2121()

    If cTipoDoc != 'D'
        nSQtdeCT   += nQtdade
        nSQtdeCVlM += Iif(nVlrBICMST > 0, nQtdade   , 0)
        nSBICMSTVM += Iif(nVlrBICMST > 0, nVlrBICMST, 0)
    Else
        nSQtdeCT   -= nQtdade
        nSQtdeCVlM -= Iif(nVlrBICMST > 0, nQtdade   , 0)
        nSBICMSTVM -= Iif(nVlrBICMST > 0, nVlrBICMST, 0)
    EndIf
    lShow2121 := Iif(!lShow2121 .And. cRespRet == '2' .And. !lTagRetAnt, .T., lShow2121)

	Self:SetCampo02(nSQtdeCT)
	Self:SetCampo03(nSQtdeCVlM)
	Self:SetCampo04(nSBICMSTVM)
    Self:SetShw2121(lShow2121)
Return


//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} Getters e Setters

@author Ulisses P. Oliveira
@since 22/01/2020
@version 1.0
/*/
//--------------------------------------------------------------------------------------------------
Method SetCampo02(nSQtdeCT) Class FISA2302121
    Self:nSQtdeCT := nSQtdeCT
Return

Method SetCampo03(nSQtdeCVlM) Class FISA2302121
    Self:nSQtdeCVlM := nSQtdeCVlM
Return

Method SetCampo04(nSBICMSTVM) Class FISA2302121
    Self:nSBICMSTVM := nSBICMSTVM
Return

Method SetCampo05(nVlrMUBSTG) Class FISA2302121
    Self:nVlrMUBSTG := nVlrMUBSTG
Return

Method SetShw2121(lShow2121) Class FISA2302121
    Self:lShow2121 := lShow2121
Return

Method GetCampo02() Class FISA2302121
Return Self:nSQtdeCT

Method GetCampo03() Class FISA2302121
Return Self:nSQtdeCVlM

Method GetCampo04() Class FISA2302121
Return Self:nSBICMSTVM

Method GetCampo05() Class FISA2302121
Return Self:nVlrMUBSTG

Method GetShw2121() Class FISA2302121
Return Self:lShow2121 


//==================================================================================================
/*/{Protheus.doc} Classe FISA2302112

Classe responsável pelo controle do Registro 2112. 
 
@author Ulisses P. Oliveira
@since 25/03/2019
@version 1.0
/*/
//==================================================================================================
CLASS FISA2302112 FROM LongClassName

Data aQtdUnidNf  As Array     //--- {nQtdeVCF,cUnid,nFatConv,nQtdeVCfC,nVlVCf} ---//
Data nQtdeVCfC   As Numeric   //--- ---//
Data nVlVCf      As Numeric   //--- ---//

Method New() CONSTRUCTOR
Method Clear2112()
Method Inc2112(nQtdade,cUnid,nFatorC,nQtdadeC,nVlrTotNf)

//---Getters e Setters---//
Method SetQtdUnNf(aQtdUnidNf)
Method SetCampo05(nQtdeVCfC)
Method SetCampo06(nVlVCf)
Method GetQtdUnNf()
Method GetCampo05()
Method GetCampo06()

ENDCLASS

//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} New()
  
Método construtor da Classe FISA2302112

@author Ulisses P. Oliveira
@since 25/03/2019
@version 1.0
/*/
//--------------------------------------------------------------------------------------------------
Method New() Class FISA2302112
	Self:Clear2112()
Return Self


//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} Clear2112
  
Método que limpa os valores do objeto.

@author Ulisses P. Oliveira
@since 25/03/2019
@version 1.0
/*/
//--------------------------------------------------------------------------------------------------
Method Clear2112() Class FISA2302112
    Self:aQtdUnidNf := {} //aSize(Self:aQtdUnidNf,0)
	Self:nQtdeVCfC  := 0
    Self:nVlVCf     := 0
Return


//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} Inc2112()
  


@author Ulisses P. Oliveira
@since 25/03/2019
@version 1.0
/*/
//--------------------------------------------------------------------------------------------------
Method Inc2112(nQtdade,cUnid,nFatorC,nQtdadeC,nVlrTotNf) Class FISA2302112
    Local aQtdUnidNf := Self:GetQtdUnNf()
    Local nQtdeVCfC  := Self:GetCampo05()
    Local nVlVCf     := Self:GetCampo06()
    Local nPos       := 0

    nPos := Ascan(aQtdUnidNf,{|a|a[2] == cUnid})
    If nPos > 0
        aQtdUnidNf[nPos][1] += nQtdade
        aQtdUnidNf[nPos][4] += nQtdadeC
        aQtdUnidNf[nPos][5] += nVlrTotNf
    Else
        Aadd(aQtdUnidNf, {nQtdade, cUnid, nFatorC, nQtdadeC, nVlrTotNf})
    EndIf

    nQtdeVCfC += nQtdadeC
    nVlVCf    += nVlrTotNf

    Self:SetQtdUnNf(aQtdUnidNf)
    Self:SetCampo05(nQtdeVCfC)
    Self:SetCampo06(nVlVCf)
Return


//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} Getters e Setters

@author Ulisses P. Oliveira
@since 25/03/2019
@version 1.0
/*/
//--------------------------------------------------------------------------------------------------
Method SetQtdUnNf(aQtdUnidNf) Class FISA2302112
    Self:aQtdUnidNf := aQtdUnidNf
Return

Method SetCampo05(nQtdeVCfC) Class FISA2302112
    Self:nQtdeVCfC := nQtdeVCfC
Return

Method SetCampo06(nVlVCf) Class FISA2302112
    Self:nVlVCf := nVlVCf
Return

Method GetQtdUnNf() Class FISA2302112
Return Self:aQtdUnidNf

Method GetCampo05() Class FISA2302112
Return Self:nQtdeVCfC

Method GetCampo06() Class FISA2302112
Return Self:nVlVCf


//==================================================================================================
/*/{Protheus.doc} Classe FISA2302110

Classe responsável pelo controle do Registro 2110. 
 
@author Ulisses P. Oliveira
@since 26/03/2019
@version 1.0
/*/
//==================================================================================================
CLASS FISA2302110 FROM LongClassName

Data cCodItem    As Character //--- ---//
Data nQtdeTVCF   As Numeric   //--- ---//
Data nVlTVCF     As Numeric   //--- ---//
Data nVlMUniVCF  As Numeric   //--- ---//
Data nVlTBSTVCF  As Numeric   //--- ---//
Data nVlDMaiBST  As Numeric   //--- ---//
Data nVlDMenBST  As Numeric   //--- ---//
Data nAliqEf     As Numeric   //--- ---//
Data nVlICMSTRt  As Numeric   //--- ---//
Data nVlICMSTCp  As Numeric   //--- ---//
Data nQtdeTSOE   As Numeric   //--- ---//
Data nVlICMSOE   As Numeric   //--- ---//
Data nVlICMSTOE  As Numeric   //--- ---//
Data nQtdeTSSN   As Numeric   //--- ---//
Data nVlTCMVASN  As Numeric   //--- ---//

Method New() CONSTRUCTOR
Method Clear2110()
Method Inc2110(cTipoDoc,cTipoOper,nQtdade,nVlrTotNf,nVlCMVASN)

//---Getters e Setters---//
Method SetCampo02(cCodItem)
Method SetCampo03(nQtdeTVCF)
Method SetCampo04(nVlTVCF)
Method SetCampo05(nVlMUniVCF)
Method SetCampo06(nVlTBSTVCF)
Method SetCampo07(nVlDMaiBST)
Method SetCampo08(nVlDMenBST)
Method SetCampo09(nAliqEf)
Method SetCampo10(nVlICMSTRt)
Method SetCampo11(nVlICMSTCp)
Method SetCampo12(nQtdeTSOE)
Method SetCampo13(nVlICMSOE)
Method SetCampo14(nVlICMSTOE)
Method SetCampo15(nQtdeTSSN)
Method SetCampo16(nVlTCMVASN)
Method GetCampo02()
Method GetCampo03()
Method GetCampo04()
Method GetCampo05()
Method GetCampo06()
Method GetCampo07()
Method GetCampo08()
Method GetCampo09()
Method GetCampo10()
Method GetCampo11()
Method GetCampo12()
Method GetCampo13()
Method GetCampo14()
Method GetCampo15()
Method GetCampo16()

ENDCLASS

//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} New()
  
Método construtor da Classe FISA2302110

@author Ulisses P. Oliveira
@since 26/03/2019
@version 1.0
/*/
//--------------------------------------------------------------------------------------------------
Method New() Class FISA2302110
	Self:Clear2110()
Return Self


//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} Clear2110
  
Método que limpa os valores do objeto.

@author Ulisses P. Oliveira
@since 26/03/2019
@version 1.0
/*/
//--------------------------------------------------------------------------------------------------
Method Clear2110() Class FISA2302110
	Self:cCodItem   := ''
	Self:nQtdeTVCF  := 0
	Self:nVlTVCF    := 0
	Self:nVlMUniVCF := 0
    Self:nVlTBSTVCF := 0
    Self:nVlDMaiBST := 0
    Self:nVlDMenBST := 0
	Self:nAliqEf    := 0
	Self:nVlICMSTRt := 0
	Self:nVlICMSTCp := 0
	Self:nQtdeTSOE  := 0
    Self:nVlICMSOE  := 0
    Self:nVlICMSTOE := 0
    Self:nQtdeTSSN  := 0
    Self:nVlTCMVASN := 0	
Return


//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} Inc2110()
  


@author Ulisses P. Oliveira
@since 26/03/2019
@version 1.0
/*/
//--------------------------------------------------------------------------------------------------
Method Inc2110(cTipoDoc,cTipoOper,nQtdade,nVlrTotNf,nVlCMVASN) Class FISA2302110
    Local nQtdeTVCF  := Self:GetCampo03()
    Local nVlTVCF    := Self:GetCampo04()
    Local nQtdeTSOE  := Self:GetCampo12()
    Local nQtdeTSSN  := Self:GetCampo15()
    Local nVlTCMVASN := Self:GetCampo16()

    If cTipoOper == '10'      //---10 - Venda à consumidor final---//
        If cTipoDoc != 'D'
            nQtdeTVCF  += nQtdade
            nVlTVCF    += nVlrTotNf
        Else
            nQtdeTVCF  -= nQtdade
            nVlTVCF    -= nVlrTotNf
        EndIf
    ElseIf cTipoOper == '20'  //---20 - Venda para outra unidade da federação---//
        If cTipoDoc != 'D'
            nQtdeTSOE  += nQtdade
        Else
            nQtdeTSOE  -= nQtdade
        EndIf
    ElseIf cTipoOper == '30'  //---30 - Venda para Simples Nacional---//
        If cTipoDoc != 'D'
            nQtdeTSSN  += nQtdade
            nVlTCMVASN += nVlCMVASN
        Else
            nQtdeTSSN  -= nQtdade
            nVlTCMVASN -= nVlCMVASN
        EndIf
    EndIf

    Self:SetCampo03(nQtdeTVCF)
    Self:SetCampo04(nVlTVCF)
    Self:SetCampo12(nQtdeTSOE)
    Self:SetCampo15(nQtdeTSSN)
    Self:SetCampo16(nVlTCMVASN)

Return


//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} Getters e Setters

@author Ulisses P. Oliveira
@since 26/03/2019
@version 1.0
/*/
//--------------------------------------------------------------------------------------------------
Method SetCampo02(cCodItem) Class FISA2302110
    Self:cCodItem := cCodItem
Return

Method SetCampo03(nQtdeTVCF) Class FISA2302110
    Self:nQtdeTVCF := nQtdeTVCF
Return

Method SetCampo04(nVlTVCF) Class FISA2302110
    Self:nVlTVCF := nVlTVCF
Return

Method SetCampo05(nVlMUniVCF) Class FISA2302110
    Self:nVlMUniVCF := nVlMUniVCF
Return

Method SetCampo06(nVlTBSTVCF) Class FISA2302110
    Self:nVlTBSTVCF := nVlTBSTVCF
Return

Method SetCampo07(nVlDMaiBST) Class FISA2302110
    Self:nVlDMaiBST := nVlDMaiBST
Return

Method SetCampo08(nVlDMenBST) Class FISA2302110
    Self:nVlDMenBST := nVlDMenBST
Return

Method SetCampo09(nAliqEf) Class FISA2302110
    Self:nAliqEf := nAliqEf
Return

Method SetCampo10(nVlICMSTRt) Class FISA2302110
    Self:nVlICMSTRt := nVlICMSTRt
Return

Method SetCampo11(nVlICMSTCp) Class FISA2302110
    Self:nVlICMSTCp := nVlICMSTCp
Return

Method SetCampo12(nQtdeTSOE) Class FISA2302110
    Self:nQtdeTSOE := nQtdeTSOE
Return

Method SetCampo13(nVlICMSOE) Class FISA2302110
    Self:nVlICMSOE := nVlICMSOE
Return

Method SetCampo14(nVlICMSTOE) Class FISA2302110
    Self:nVlICMSTOE := nVlICMSTOE
Return

Method SetCampo15(nQtdeTSSN) Class FISA2302110
    Self:nQtdeTSSN := nQtdeTSSN
Return

Method SetCampo16(nVlTCMVASN) Class FISA2302110
    Self:nVlTCMVASN := nVlTCMVASN
Return

Method GetCampo02() Class FISA2302110
Return Self:cCodItem

Method GetCampo03() Class FISA2302110
Return Self:nQtdeTVCF

Method GetCampo04() Class FISA2302110
Return Self:nVlTVCF

Method GetCampo05() Class FISA2302110
Return Self:nVlMUniVCF

Method GetCampo06() Class FISA2302110
Return Self:nVlTBSTVCF

Method GetCampo07() Class FISA2302110
Return Self:nVlDMaiBST

Method GetCampo08() Class FISA2302110
Return Self:nVlDMenBST

Method GetCampo09() Class FISA2302110
Return Self:nAliqEf

Method GetCampo10() Class FISA2302110
Return Self:nVlICMSTRt

Method GetCampo11() Class FISA2302110
Return Self:nVlICMSTCp

Method GetCampo12() Class FISA2302110
Return Self:nQtdeTSOE

Method GetCampo13() Class FISA2302110
Return Self:nVlICMSOE

Method GetCampo14() Class FISA2302110
Return Self:nVlICMSTOE

Method GetCampo15() Class FISA2302110
Return Self:nQtdeTSSN

Method GetCampo16() Class FISA2302110
Return Self:nVlTCMVASN


//==================================================================================================
/*/{Protheus.doc} Classe FISA2302100

Classe responsável pelo controle do Registro 2100.
 
@author Ulisses P. Oliveira
@since 27/03/2019
@version 1.0
/*/
//==================================================================================================
CLASS FISA2302100 FROM LongClassName

Data nSVlICSTRt  As Numeric   //--- ---//
Data nSVlICSTCp  As Numeric   //--- ---//
Data nSdICMSTRt  As Numeric   //--- ---//
Data nSdICMSTRe  As Numeric   //--- ---//
Data nSdICMSTCp  As Numeric   //--- ---//
Data nSdICMSOp   As Numeric   //--- ---//
Data nVlApCrICM  As Numeric   //--- ---//
Data nVlApICMCp  As Numeric   //--- ---//

Method New() CONSTRUCTOR
Method Clear2100()
Method Inc2100(nSVlICSTRt,nSVlICSTCp,nSdICMSTRe,nSdICMSOp)

//---Getters e Setters---//
Method SetCampo02(nSVlICSTRt)
Method SetCampo03(nSVlICSTCp)
Method SetCampo04(nSdICMSTRt)
Method SetCampo05(nSdICMSTRe)
Method SetCampo06(nSdICMSTCp)
Method SetCampo07(nSdICMSOp)
Method SetCampo08(nVlApCrICM)
Method SetCampo09(nVlApICMCp)
Method GetCampo02()
Method GetCampo03()
Method GetCampo04()
Method GetCampo05()
Method GetCampo06()
Method GetCampo07()
Method GetCampo08()
Method GetCampo09()

ENDCLASS

//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} New()
  
Método construtor da Classe FISA2302100

@author Ulisses P. Oliveira
@since 27/03/2019
@version 1.0
/*/
//--------------------------------------------------------------------------------------------------
Method New() Class FISA2302100
	Self:Clear2100()
Return Self


//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} Clear2100
  
Método que limpa os valores do objeto.

@author Ulisses P. Oliveira
@since 27/03/2019
@version 1.0
/*/
//--------------------------------------------------------------------------------------------------
Method Clear2100() Class FISA2302100
    Self:nSVlICSTRt := 0
    Self:nSVlICSTCp := 0
    Self:nSdICMSTRt := 0
    Self:nSdICMSTRe := 0
    Self:nSdICMSTCp := 0
    Self:nSdICMSOp  := 0
    Self:nVlApCrICM := 0
    Self:nVlApICMCp := 0
Return


//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} Inc2100()
  


@author Ulisses P. Oliveira
@since 27/03/2019
@version 1.0
/*/
//--------------------------------------------------------------------------------------------------
Method Inc2100(nSVlICSTRt,nSVlICSTCp,nSdICMSTRe,nSdICMSOp) Class FISA2302100
    Self:SetCampo02(Self:GetCampo02() + nSVlICSTRt)
    Self:SetCampo03(Self:GetCampo03() + nSVlICSTCp)
    Self:SetCampo05(Self:GetCampo05() + nSdICMSTRe)
    Self:SetCampo07(Self:GetCampo07() + nSdICMSOp )
Return


//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} Getters e Setters

@author Ulisses P. Oliveira
@since @since 27/03/2019
@version 1.0
/*/
//--------------------------------------------------------------------------------------------------
Method SetCampo02(nSVlICSTRt) Class FISA2302100
    Self:nSVlICSTRt := nSVlICSTRt
Return

Method SetCampo03(nSVlICSTCp) Class FISA2302100
    Self:nSVlICSTCp := nSVlICSTCp
Return

Method SetCampo04(nSdICMSTRt) Class FISA2302100
    Self:nSdICMSTRt := nSdICMSTRt
Return

Method SetCampo05(nSdICMSTRe) Class FISA2302100
    Self:nSdICMSTRe := nSdICMSTRe
Return

Method SetCampo06(nSdICMSTCp) Class FISA2302100
    Self:nSdICMSTCp := nSdICMSTCp
Return

Method SetCampo07(nSdICMSOp) Class FISA2302100
    Self:nSdICMSOp := nSdICMSOp
Return

Method SetCampo08(nVlApCrICM) Class FISA2302100
    Self:nVlApCrICM := nVlApCrICM
Return

Method SetCampo09(nVlApICMCp) Class FISA2302100
    Self:nVlApICMCp := nVlApICMCp
Return

Method GetCampo02() Class FISA2302100
Return Self:nSVlICSTRt

Method GetCampo03() Class FISA2302100
Return Self:nSVlICSTCp

Method GetCampo04() Class FISA2302100
Return Self:nSdICMSTRt

Method GetCampo05() Class FISA2302100
Return Self:nSdICMSTRe

Method GetCampo06() Class FISA2302100
Return Self:nSdICMSTCp

Method GetCampo07() Class FISA2302100
Return Self:nSdICMSOp

Method GetCampo08() Class FISA2302100
Return Self:nVlApCrICM

Method GetCampo09() Class FISA2302100
Return Self:nVlApICMCp


//==================================================================================================
/*/{Protheus.doc} Classe FISA230MOVIMENTO

  
@author Ulisses P. Oliveira
@since 21/03/2019
@version 1.0
/*/
//==================================================================================================
CLASS FISA230MOVIMENTO FROM LongClassName

//---Valores setados para o movimento durante a rotina de processamento da apuração. Serão usados para o cálculo---//
Data dDataMov   As Date      //---Data do Movimento
Data cTipoMov   As Character //---Tipo do Movimento (E-Entrada / S-Saída)
Data cNumSerECF As Character //---Número de Série de Fabricação do ECF
Data cTipoDoc   As Character //---Tipo do Documento (Normal / Devolução / Complemento)
Data cCodProd   As Character //---Código do Produto
Data cTipoPart  As Character //---Tipo do Participante (Cliente Final / Revendedor)
Data cPartOptSN As Character //---Participante Optante pelo Simples Nacional (1-Sim / 2-Não)
Data nAliqInt   As Numeric   //---Alíquota Interna do Produto
Data cCFOP      As Character //---CFOP
Data cCST       As Character //---CST ICMS
Data nQtdade    As Numeric   //---Quantidade informada no Documento Fiscal
Data cUnid      As Character //---Unidade informada no Documento Fiscal
Data nFatorC    As Numeric   //---Fator de Conversão da Quantidade informada no Documento Fiscal para a Unidade utilizada no Registro 0200
Data cFatorCTp  As Character //---Tipo de Conversão: M-Multiplicação / D-Divisão
Data nQtdadeC   As Numeric   //---Quantidade convertida para a Unidade utilizada no Registro 0200
Data nVlrTotNf  As Numeric   //---Valor Total da Nota Fiscal
Data nVlrBICMS  As Numeric   //---Base de Cálculo do ICMS
Data nVlrAICMS  As Numeric   //---Alíquota do ICMS
Data nVlrICMS   As Numeric   //---Valor do ICMS
Data nVlrBICMST As Numeric   //---Valor da Base de Cálculo do ICMS-ST
Data nVlrAICMST As Numeric   //---Alíquota do ICMS-ST
Data nVlrICMSST As Numeric   //---Valor do ICMS-ST
Data cRespRet   As Character //---Responsável pela retenção do ICMS-ST (1–Remetente Direto / 2-Remetente Indireto / 3–Próprio declarante )
Data lTagRetAnt              //---Indicador de preenchimento das TAGs "vBCSTRet" e "vICMSSTRet" do Grupo Tributação do ICMS = 60
Data cPrdResVSN As Character //---Indicador de cálculo de Ressarcimento em caso de saída interna para Optante pelo Simples Nacional (1–Sim / 2–Não)
Data nPercRess  As Numeric   //---Percentual de redução do MVA utilizado em saídas internas destinadas a empresa optante pelo Simples Nacional
Data aDocOriApu As Array     //---Valores apurados para o Documento Fiscal Original, em casos de movimentos de devolução
Data cCodAju    As String    //---Código do Ajuste de débito informado no Registro C197 da EFD ICMS/IPI
Data cCodDA     As String    //---Código do modelo do documento de arrecadação
Data cNumDare   As String    //---Número do DARE - Guia para recolhimento de ICMS Antecipado na operação

//---Valores calculados para o movimento---//
Data cTipoOper  As Character //---Tipo de Operação de Saída: 10 - Venda à consumidor final / 20 - Venda para outra unidade da federação / 30 - Venda para Simples Nacional 
Data nVlCMVASN  As Numeric   //---Valor do crédito em decorrência da saída destinada a contribuinte optante pelo Simples Nacional de mercadoria cuja substituição tributária da operação anterior foi apurada com MVA de contribuinte normal 
Data nVlrBINTST As Numeric   //---Valor integral da Base de Cálculo do ICMS-ST quando se utilizar a alíquota efetiva aplicável na apuração do imposto devido 
Data nVlrAEFEST As Numeric   //---Alíquota do ICMS efetiva (percentual de carga tributária efetiva) da ST, aplicável à Base de Cálculo integral
Data nVlrCALCST As Numeric   //---Valor do ICMS-ST calculado pela multiplicação dos campos nVlrBICMST e nVlrAICMST e dos campos nVlrBINTST e nVlrAEFEST

//---Valores de controle do movimento---//
Data lGravaMov                //---Indicador de Gravação do Movimento
Data nOrdMovAtu  As Numeric   //---Ordenação do Movimento Atual do Produto

Method New() CONSTRUCTOR
Method EnquadMov(aDtIniReCo)
Method ClearMov()

//---Getters e Setters---//
Method SetDataMov(dDataMov)
Method SetTipoMov(cTipoMov)
Method SetNSerECF(cNumSerECF)
Method SetTipoDoc(cTipoDoc)
Method SetCodProd(cCodProd)
Method SetTipoPar(cTipoPart)
Method SetOptSN(cPartOptSN)
Method SetAliqInt(nAliqInt)
Method SetCFOP(cCFOP)
Method SetCST(cCST)
Method SetQtdade(nQtdade)
Method SetUnid(cUnid)
Method SetFatorC(nFatorC)
Method SetFatorTp(cFatorCTp)
Method SetQtdadeC(nQtdadeC)
Method SetTotNf(nVlrTotNf)
Method SetBICMS(nVlrBICMS)
Method SetAICMS(nVlrAICMS)
Method SetVICMS(nVlrICMS)
Method SetBICMST(nVlrBICMST)
Method SetAICMST(nVlrAICMST)
Method SetVICMSST(nVlrICMSST)
Method SetRespRet(cRespRet)
Method SetTagAnt(lTagRetAnt)
Method SetPrResSN(cPrdResVSN)
Method SetPerRess(nPercRess)
Method SetDocOrig(aDocOriApu)
Method SetCodAju(cCodAju)
Method SetCodDA(cCodDA)
Method SetNumDare(cNumDare)
Method SetTpOper(cTipoOper)
Method SetCredSSN(nVlCMVASN)
Method SetBINTST(nVlrBINTST)
Method SetAEFEST(nVlrAEFEST)
Method SetCALCST(nVlrCALCST)
Method SetGrvMov(lGravaMov)
Method SetOrdMov(nOrdMovAtu)
Method GetDataMov()
Method GetTipoMov()
Method GetNSerECF()
Method GetTipoDoc()
Method GetCodProd()
Method GetTipoPar()
Method GetOptSN()
Method GetAliqInt()
Method GetCFOP()
Method GetCST()
Method GetQtdade()
Method GetUnid()
Method GetFatorC()
Method GetFatorTp()
Method GetQtdadeC()
Method GetTotNf()
Method GetBICMS()
Method GetAICMS()
Method GetVICMS()
Method GetBICMST()
Method GetAICMST()
Method GetVICMSST()
Method GetRespRet()
Method GetTagAnt()
Method GetPrResSN()
Method GetPerRess()
Method GetDocOrig()
Method GetCodAju()
Method GetCodDA()
Method GetNumDare()
Method GetTpOper()
Method GetCredSSN()
Method GetBINTST()
Method GetAEFEST()
Method GetCALCST()
Method GetGrvMov()
Method GetOrdMov()

ENDCLASS


//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} New()
  
Método construtor da Classe FISA230MOVIMENTO

@author Ulisses P. Oliveira
@since 21/03/2019
@version 1.0
/*/
//--------------------------------------------------------------------------------------------------
Method New() Class FISA230MOVIMENTO
    Self:ClearMov()
Return Self


//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} EnquadMov()
  
Método que define o tipo da operção de saída, retornando:
10 - Venda à consumidor final;
20 - Venda para outra unidade da federação;
30 - Venda para Simples Nacional
99 - Venda à consumidor final emitida por ECF

@author Ulisses P. Oliveira
@since 21/03/2019
@version 1.0
/*/
//--------------------------------------------------------------------------------------------------
Method EnquadMov(aDtIniReCo) Class FISA230MOVIMENTO
    Local dDataMov   := Self:GetDataMov()
    Local cCFOP      := Self:GetCFOP()
    Local cTipoPart  := Self:GetTipoPar()
    Local cTipoMov   := Self:GetTipoMov()
    Local cNumSerECF := Self:GetNSerECF()
    Local cPartOptSN := Self:GetOptSN()
    Local cPrdResVSN := Self:GetPrResSN()
    Local lDtIniRest := .F.
    Local lDtIniRess := .F.
    Local cRetorno   := ''

    If Len(aDtIniReCo) == 3
        lDtIniRest := Iif(dDataMov >= CtoD(aDtIniReCo[1]),.T.,.F.) //---Art. 25-C. Decreto Nº 1818 DE 28/11/2018---//
        lDtIniRess := Iif(dDataMov >= CtoD(aDtIniReCo[3]),.T.,.F.) //---Art. 25-C. Decreto Nº 1818 DE 28/11/2018---//
    EndIf

    If !Empty(cNumSerECF) .And. cTipoPart == 'F' .And. lDtIniRest
        cRetorno := '99' //--- 99 - Venda à consumidor final emitida por ECF---//
    ElseIf ((cTipoMov == 'S' .And. Left(cCFOP,1) == '6') .Or. (cTipoMov == 'E' .And. Left(cCFOP,1) == '2')) .And. lDtIniRess
        cRetorno := '20' //--- 20 - Venda para outra unidade da federação ---//
    ElseIf cPartOptSN == '1' .And. cPrdResVSN = '1' .And. lDtIniRess
        cRetorno := '30' //--- 30 - Venda para Simples Nacional ---//
    ElseIf cTipoPart $ 'F|L' .And. lDtIniRest
        cRetorno := '10' //--- 10 - Venda à consumidor final ---//
    EndIf

Return cRetorno


//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} ClearMov
  
Método que limpa os valores do movimento.

@author Ulisses P. Oliveira
@since 21/03/2019
@version 1.0
/*/
//--------------------------------------------------------------------------------------------------
Method ClearMov() Class FISA230MOVIMENTO
    Self:dDataMov   := CToD("  /  /    ")
    Self:cTipoMov   := ''
    Self:cNumSerECF := ''
    Self:cTipoDoc   := ''
    Self:cCodProd   := ''
    Self:cTipoPart  := ''
    Self:cPartOptSN := ''
    Self:nAliqInt   := 0
    Self:cCFOP      := ''
    Self:cCST       := ''
    Self:nQtdade    := 0
    Self:cUnid      := ''
    Self:nFatorC    := 0
    Self:cFatorCTp  := ''
    Self:nQtdadeC   := 0
    Self:nVlrTotNf  := 0
    Self:nVlrBICMS  := 0
    Self:nVlrAICMS  := 0
    Self:nVlrICMS   := 0
    Self:nVlrBICMST := 0
    Self:nVlrAICMST := 0
    Self:nVlrICMSST := 0
    Self:cRespRet   := ''
    Self:lTagRetAnt := .F.
    Self:cPrdResVSN := ''
    Self:nPercRess  := 0
    Self:aDocOriApu := {}
    Self:cCodAju    := ''
    Self:cCodDA     := ''
    Self:cNumDare   := ''
    Self:cTipoOper  := ''
    Self:nVlCMVASN  := 0
    Self:nVlrBINTST := 0
    Self:nVlrAEFEST := 0
    Self:nVlrCALCST := 0
    Self:lGravaMov  :=.F.
    Self:nOrdMovAtu := 0
Return


//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} Getters e Setters

@author Ulisses P. Oliveira
@since 21/03/2019
@version 1.0
/*/
//--------------------------------------------------------------------------------------------------
Method SetDataMov(dDataMov) Class FISA230MOVIMENTO
    Self:dDataMov := dDataMov
Return

Method SetTipoMov(cTipoMov) Class FISA230MOVIMENTO
    Self:cTipoMov := cTipoMov
Return

Method SetNSerECF(cNumSerECF) Class FISA230MOVIMENTO
    Self:cNumSerECF := cNumSerECF
Return

Method SetTipoDoc(cTipoDoc) Class FISA230MOVIMENTO
    Self:cTipoDoc := cTipoDoc
Return

Method SetCodProd(cCodProd) Class FISA230MOVIMENTO
    Self:cCodProd := cCodProd
Return

Method SetTipoPar(cTipoPart) Class FISA230MOVIMENTO
    Self:cTipoPart := cTipoPart
Return

Method SetOptSN(cPartOptSN) Class FISA230MOVIMENTO
    Self:cPartOptSN := cPartOptSN
Return

Method SetAliqInt(nAliqInt) Class FISA230MOVIMENTO
    Self:nAliqInt := nAliqInt
Return

Method SetCFOP(cCFOP) Class FISA230MOVIMENTO
    Self:cCFOP := cCFOP
Return

Method SetCST(cCST) Class FISA230MOVIMENTO
    Self:cCST := cCST
Return

Method SetQtdade(nQtdade) Class FISA230MOVIMENTO
    Self:nQtdade := Round(nQtdade,5)
Return

Method SetUnid(cUnid) Class FISA230MOVIMENTO
    Self:cUnid := cUnid
Return

Method SetFatorC(nFatorC) Class FISA230MOVIMENTO
    Self:nFatorC := nFatorC
Return

Method SetFatorTp(cFatorCTp) Class FISA230MOVIMENTO
    Self:cFatorCTp := cFatorCTp
Return

Method SetQtdadeC(nQtdadeC) Class FISA230MOVIMENTO
    Self:nQtdadeC := Round(nQtdadeC,5)
Return

Method SetTotNf(nVlrTotNf) Class FISA230MOVIMENTO
    Self:nVlrTotNf := nVlrTotNf
Return

Method SetBICMS(nVlrBICMS) Class FISA230MOVIMENTO
    Self:nVlrBICMS := nVlrBICMS
Return

Method SetAICMS(nVlrAICMS) Class FISA230MOVIMENTO
    Self:nVlrAICMS := nVlrAICMS
Return

Method SetVICMS(nVlrICMS) Class FISA230MOVIMENTO
    Self:nVlrICMS := nVlrICMS
Return

Method SetBICMST(nVlrBICMST) Class FISA230MOVIMENTO
    Self:nVlrBICMST := nVlrBICMST
Return

Method SetAICMST(nVlrAICMST) Class FISA230MOVIMENTO
    Self:nVlrAICMST := nVlrAICMST
Return

Method SetVICMSST(nVlrICMSST) Class FISA230MOVIMENTO
    Self:nVlrICMSST := nVlrICMSST
Return

Method SetRespRet(cRespRet) Class FISA230MOVIMENTO
    Self:cRespRet := cRespRet
Return

Method SetTagAnt(lTagRetAnt) Class FISA230MOVIMENTO
    Self:lTagRetAnt := lTagRetAnt
Return

Method SetPrResSN(cPrdResVSN) Class FISA230MOVIMENTO
    Self:cPrdResVSN := cPrdResVSN
Return

Method SetPerRess(nPercRess) Class FISA230MOVIMENTO
    Self:nPercRess := nPercRess
Return

Method SetDocOrig(aDocOriApu) Class FISA230MOVIMENTO
    Self:aDocOriApu := aDocOriApu
Return

Method SetCodAju(cCodAju) Class FISA230MOVIMENTO
    Self:cCodAju := cCodAju
Return

Method SetCodDA(cCodDA) Class FISA230MOVIMENTO
    Self:cCodDA := cCodDA
Return

Method SetNumDare(cNumDare) Class FISA230MOVIMENTO
    Self:cNumDare := cNumDare
Return

Method SetTpOper(cTipoOper) Class FISA230MOVIMENTO
    Self:cTipoOper := cTipoOper
Return

Method SetCredSSN(nVlCMVASN) Class FISA230MOVIMENTO
    Self:nVlCMVASN := nVlCMVASN
Return

Method SetBINTST(nVlrBINTST) Class FISA230MOVIMENTO
    Self:nVlrBINTST := nVlrBINTST
Return

Method SetAEFEST(nVlrAEFEST) Class FISA230MOVIMENTO
    Self:nVlrAEFEST := nVlrAEFEST
Return

Method SetCALCST(nVlrCALCST) Class FISA230MOVIMENTO
    Self:nVlrCALCST := nVlrCALCST
Return

Method SetGrvMov(lGravaMov) Class FISA230MOVIMENTO
    Self:lGravaMov := lGravaMov
Return

Method SetOrdMov(nOrdMovAtu) Class FISA230MOVIMENTO
    Self:nOrdMovAtu := nOrdMovAtu
Return

Method GetDataMov() Class FISA230MOVIMENTO
Return Self:dDataMov

Method GetTipoMov() Class FISA230MOVIMENTO
Return Self:cTipoMov

Method GetNSerECF() Class FISA230MOVIMENTO
Return Self:cNumSerECF

Method GetTipoDoc() Class FISA230MOVIMENTO
Return Self:cTipoDoc

Method GetCodProd() Class FISA230MOVIMENTO
Return Self:cCodProd

Method GetTipoPar() Class FISA230MOVIMENTO
Return Self:cTipoPart

Method GetOptSN() Class FISA230MOVIMENTO
Return Self:cPartOptSN

Method GetAliqInt() Class FISA230MOVIMENTO
Return Self:nAliqInt

Method GetCFOP() Class FISA230MOVIMENTO
Return Self:cCFOP

Method GetCST() Class FISA230MOVIMENTO
Return Self:cCST

Method GetQtdade() Class FISA230MOVIMENTO
Return Self:nQtdade

Method GetUnid() Class FISA230MOVIMENTO
Return Self:cUnid

Method GetFatorC() Class FISA230MOVIMENTO
Return Self:nFatorC

Method GetFatorTp() Class FISA230MOVIMENTO
Return Self:cFatorCTp

Method GetQtdadeC() Class FISA230MOVIMENTO
Return Self:nQtdadeC

Method GetTotNf() Class FISA230MOVIMENTO
Return Self:nVlrTotNf

Method GetBICMS() Class FISA230MOVIMENTO
Return Self:nVlrBICMS

Method GetAICMS() Class FISA230MOVIMENTO
Return Self:nVlrAICMS

Method GetVICMS() Class FISA230MOVIMENTO
Return Self:nVlrICMS

Method GetBICMST() Class FISA230MOVIMENTO
Return Self:nVlrBICMST

Method GetAICMST() Class FISA230MOVIMENTO
Return Self:nVlrAICMST

Method GetVICMSST() Class FISA230MOVIMENTO
Return Self:nVlrICMSST

Method GetRespRet() Class FISA230MOVIMENTO
Return Self:cRespRet

Method GetTagAnt() Class FISA230MOVIMENTO
Return Self:lTagRetAnt

Method GetPrResSN() Class FISA230MOVIMENTO
Return Self:cPrdResVSN

Method GetPerRess() Class FISA230MOVIMENTO
Return Self:nPercRess

Method GetDocOrig() Class FISA230MOVIMENTO
Return Self:aDocOriApu

Method GetCodAju() Class FISA230MOVIMENTO
Return Self:cCodAju

Method GetCodDA() Class FISA230MOVIMENTO
Return Self:cCodDA

Method GetNumDare() Class FISA230MOVIMENTO
Return Self:cNumDare

Method GetTpOper() Class FISA230MOVIMENTO
Return Self:cTipoOper

Method GetCredSSN() Class FISA230MOVIMENTO
Return Self:nVlCMVASN

Method GetBINTST() Class FISA230MOVIMENTO
Return Self:nVlrBINTST

Method GetAEFEST() Class FISA230MOVIMENTO
Return Self:nVlrAEFEST

Method GetCALCST() Class FISA230MOVIMENTO
Return Self:nVlrCALCST

Method GetGrvMov() Class FISA230MOVIMENTO
Return Self:lGravaMov

Method GetOrdMov() Class FISA230MOVIMENTO
Return Self:nOrdMovAtu


//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} Classe FISA230MOVIMENTOENTRADA
  
@author Ulisses P. Oliveira
@since 08/04/2019
@version 1.0
/*/
//--------------------------------------------------------------------------------------------------
CLASS FISA230MOVIMENTOENTRADA FROM LongClassName

Data cTipoRet   As Character //--- 1-Ressarcimento em Saída Interna p/ Simples Nacional | 2-Base de Cálculo ICMS-ST / Valor ICMS-ST / Valor ICMS / Quantidade (Somatórios para cálculo de média) ---//
Data cCodProd   As Character //------//
Data nQtdade    As Numeric   //------//
Data nQtdadeAnt As Numeric   //------//
Data aQtdadeAnt As Array     //------//
Data dDataMov   As Date      //------//
Data nAliqInt   As Numeric   //------//
Data nPercRess  As Numeric   //------//
Data cIdApur    As Character //------//
Data cAnoMes    As Character //------//
Data nVlrRessSN As Numeric   //------//
Data aSBCICMSST As Array     //------//
Data nAliqEfet  As Numeric   //------//
Data nOrdMovAtu As Numeric   //------//
Data nEntPerAnt As Numeric   //---- 1 - Todas as Entradas | 2- Somente entradas necessárias --//

Method New() CONSTRUCTOR
Method ProcUltEnt()

//---Getters e Setters---//

ENDCLASS


//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} New()
  
Método construtor da Classe FISA230MOVIMENTOENTRADA

@author Ulisses P. Oliveira
@since 08/04/2019
@version 1.0
/*/
//--------------------------------------------------------------------------------------------------
Method New() Class FISA230MOVIMENTOENTRADA
    Self:cTipoRet   := ""
    Self:cCodProd   := ""
    Self:nQtdade    := 0
    Self:nQtdadeAnt := 0
    Self:aQtdadeAnt := {{'',0},{'',0},{'',0},{'',0},{'',0},{'',0},{'',0},{'',0},{'',0},{'',0},{'',0},{'',0},CtoD('  /  /    ')}
    Self:dDataMov   := CToD("  /  /    ")
    Self:nAliqInt   := 0
    Self:nPercRess  := 0
    Self:cIdApur    := ''
    Self:cAnoMes    := ''
    Self:nVlrRessSN := 0
    Self:aSBCICMSST := {0,0,0,0,.F.,0,0,0}
    Self:nAliqEfet  := 0
    Self:nOrdMovAtu := 0
    Self:nEntPerAnt := 1
Return Self


//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} ProcUltEnt()
  
Método que analisa as últimas entradas até a composição da quantidade informada, podendo calcular,
dependendo do valor setado em cTipoRet:
1-Ressarcimento em Saída Interna p/ Simples Nacional
2-Base de Cálculo ICMS-ST / Valor ICMS-ST / Valor ICMS / Quantidade (Somatórios para cálculo de média)

@author Ulisses P. Oliveira
@since 08/04/2019
@version 1.0
/*/
//--------------------------------------------------------------------------------------------------
Method ProcUltEnt() Class FISA230MOVIMENTOENTRADA
    Local cTipoRet    := Self:cTipoRet
    Local cCodProd    := Self:cCodProd
    Local nQtdade     := Self:nQtdade
    Local nQtdadeAnt  := Self:nQtdadeAnt
    Local aQtdadeAnt  := Self:aQtdadeAnt
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
    Local lPerUlt12	  := .F.
    Local nVlrBICMST  := 0
    Local nVlrAICMST  := 0
    Local nVlrICMSST  := 0
    Local nVlrAICMS   := 0
    Local nVlrICMS    := 0
    Local aAliqEfet   := {}
    Local cRespRet    := ''
    Local lTagRetAnt  := .F.
    Local cDtIniReg   := SuperGetMv("MV_DRCIREG",,"16/07/2019,16/07/2019,31/10/2019,31/10/2019")
    Local aDtIniReg   := Iif(Empty(cDtIniReg) .Or. Len(cDtIniReg) != 43,{"16/07/2019","16/07/2019","31/10/2019","31/10/2019"},StrTokArr(cDtIniReg,',')) //---Data de início: Registros 2115, 2133, 2121, 2134 ---//
    Local lReg2115    := .F.
    Local lReg2133    := .F.
    Local aVlrCmp     := {}
    Local nCount      := 1

    Local nVlrRessSN  := 0
    Local nVlrMVAOp   := 0
    Local nVlrMVAOri  := 0
    Local nPercRess   := Self:nPercRess
    Local nTotRessSN  := 0
    Local nQtdadePro  := 0
    Local nValorPro   := 0

    Local oApurEntAn  := Nil
    Local aDocOriApu  := {}
    Local aSBCICMSST  := {0,0,0,0,.F.,0,0,0} //---Base de Cálculo ICMS-ST 2120 / Valor ICMS-ST 2120 / Valor ICMS 2120 / Quantidade 2120 / Indicador Registro 2121 / Base de Cálculo ICMS-ST 2121 / Quantidade 2121 / Quantidade Válida p/ Média 2121 ---//
    Local cCodAju     := ''
    Local cMvDrcCdAj  := SuperGetMv("MV_DRCCDAJ",.F.,'')
    Local cCodDA      := ''
    Local cNumDare    := ''
    Local aNumDareAp  := {}
    Local aNumDareOp  := {}
    Local nQtdadeMv   := 0
    Local cUnid       := ''
    Local nFatorC     := 0
    Local cFatorCTp   := ''
    Local lFsa231Und  := ExistBlock("FSA231UND")
    Local aFsa231Und  := {}
    Local cPerAtu     := StrZero(Month(dDataAte),2)+StrZero(Year(dDataAte),4)

    Local nAliqEfet   := 0

    Local cSGBD       := TCGetDB()
    Local cSubStrBD1  := ''
    Local cSubStrBD2  := ''
    Local cSubStrBD3  := ''
    Local cSelecTpRt  := ''
    Local cWhereTpRt  := ''
    Local cOrderTpRt  := ''

    Local nEntPerAnt  := Self:nEntPerAnt

    //---Ajustes na Query devido à diferenças entre Bancos de Dados---//
    If cSGBD = 'ORACLE'
        cSubStrBD1 := 'SUBSTR(SFT.FT_CLASFIS,2,2)'
        cSubStrBD2 := 'SUBSTR(SFT.FT_ENTRADA,1,6)'
        cSubStrBD3 := 'SUBSTR(SF1.F1_DTDIGIT,1,6)'
    Else
        cSubStrBD1 := 'RIGHT(SFT.FT_CLASFIS,2)'
        cSubStrBD2 := 'LEFT(SFT.FT_ENTRADA,6)'
        cSubStrBD3 := 'LEFT(SF1.F1_DTDIGIT,6)'
    EndIf
    cSubStrBD1 := "%" + cSubStrBD1 + "%"

    //---Ajustes na cláusula WHERE dependendo do tipo de retorno informado em cTipoRet---//
    If cTipoRet == '1' .Or. cTipoRet == '3'
        cSelecTpRt += " SFT.FT_QUANT "
        cWhereTpRt += " SFT.FT_TIPO NOT IN ('D','B','S','P','I','C') AND "
        cWhereTpRt += " SFT.FT_TIPOMOV  = 'E'                        AND "
        cWhereTpRt += " SFT.FT_NFORI    = ' '                        AND "
        cWhereTpRt += " SFT.FT_SERORI   = ' '                        AND "
        cWhereTpRt += " SFT.FT_ITEMORI  = ' '                        AND "
        cOrderTpRt += " SFT.FT_ENTRADA DESC, SD1.D1_NUMSEQ DESC "
    ElseIf cTipoRet == '2'
        cSelecTpRt += " CASE SFT.FT_TIPO WHEN 'D' THEN SFT.FT_QUANT*(-1) ELSE SFT.FT_QUANT END "
        cWhereTpRt += " ((SFT.FT_TIPOMOV  = 'E' AND SFT.FT_TIPO <> 'D')                                        OR "
        cWhereTpRt += "  (SFT.FT_TIPOMOV  = 'S' AND SFT.FT_TIPO  = 'D' AND "+cSubStrBD3+" = "+cSubStrBD2+"))  AND "
        cWhereTpRt += "   SFT.FT_TIPO    <> 'S'                                                               AND "
        cOrderTpRt += " FT_DATAMOV DESC, FT_ORDEM "
    End
    cSelecTpRt := "%" + cSelecTpRt + "%"
    cWhereTpRt := "%" + cWhereTpRt + "%"
    cOrderTpRt := "%" + cOrderTpRt + "%"
    cSubStrBD2 := "%" + cSubStrBD2 + "%"

    //---Verifica se existe quantidade suficiente na movimentação de entrada para compor valores para o produto---//
    If nQtdadeAnt > 0
        If nQtdadeAnt >= nQtdade
       	    lAchouFT := .T.
        EndIf
    Else

        BeginSql Alias cAlias
            SELECT SUM(%EXP:cSelecTpRt%) QUANT, 
                   SUM(CASE WHEN FT_ENTRADA BETWEEN %EXP:dDataDeP1%  AND %EXP:dDataAte% THEN %EXP:cSelecTpRt% ELSE 0 END) QUANT_1,
                   SUM(CASE WHEN FT_ENTRADA BETWEEN %EXP:dDataDeP2%  AND %EXP:dDataAte% THEN %EXP:cSelecTpRt% ELSE 0 END) QUANT_2,
                   SUM(CASE WHEN FT_ENTRADA BETWEEN %EXP:dDataDeP3%  AND %EXP:dDataAte% THEN %EXP:cSelecTpRt% ELSE 0 END) QUANT_3,
                   SUM(CASE WHEN FT_ENTRADA BETWEEN %EXP:dDataDeP4%  AND %EXP:dDataAte% THEN %EXP:cSelecTpRt% ELSE 0 END) QUANT_4,
                   SUM(CASE WHEN FT_ENTRADA BETWEEN %EXP:dDataDeP5%  AND %EXP:dDataAte% THEN %EXP:cSelecTpRt% ELSE 0 END) QUANT_5,
                   SUM(CASE WHEN FT_ENTRADA BETWEEN %EXP:dDataDeP6%  AND %EXP:dDataAte% THEN %EXP:cSelecTpRt% ELSE 0 END) QUANT_6,
                   SUM(CASE WHEN FT_ENTRADA BETWEEN %EXP:dDataDeP7%  AND %EXP:dDataAte% THEN %EXP:cSelecTpRt% ELSE 0 END) QUANT_7,
                   SUM(CASE WHEN FT_ENTRADA BETWEEN %EXP:dDataDeP8%  AND %EXP:dDataAte% THEN %EXP:cSelecTpRt% ELSE 0 END) QUANT_8,
                   SUM(CASE WHEN FT_ENTRADA BETWEEN %EXP:dDataDeP9%  AND %EXP:dDataAte% THEN %EXP:cSelecTpRt% ELSE 0 END) QUANT_9,
                   SUM(CASE WHEN FT_ENTRADA BETWEEN %EXP:dDataDeP10% AND %EXP:dDataAte% THEN %EXP:cSelecTpRt% ELSE 0 END) QUANT_10,
                   SUM(CASE WHEN FT_ENTRADA BETWEEN %EXP:dDataDeP11% AND %EXP:dDataAte% THEN %EXP:cSelecTpRt% ELSE 0 END) QUANT_11,
                   SUM(CASE WHEN FT_ENTRADA BETWEEN %EXP:dDataDeP12% AND %EXP:dDataAte% THEN %EXP:cSelecTpRt% ELSE 0 END) QUANT_12,
                   MIN(FT_ENTRADA) FT_PERINI
            FROM %TABLE:SFT% SFT      INNER JOIN %TABLE:F2W% F2W ON (F2W.F2W_FILIAL = %XFILIAL:F2W% AND F2W.F2W_CFOP  = SFT.FT_CFOP    AND F2W.%NOTDEL%)
                                      INNER JOIN %TABLE:F3M% F3M ON (F3M.F3M_FILIAL = %XFILIAL:F3M% AND F3M.F3M_IDF2W = F2W.F2W_IDTAB  AND F3M.F3M_CSTICM = %Exp:cSubStrBD1% AND F3M.%NOTDEL%)
                                 LEFT OUTER JOIN %table:SF1% SF1 ON (SF1.F1_FILIAL  = %xFilial:SF1% AND SF1.F1_DOC    = SFT.FT_NFORI   AND SF1.F1_SERIE   = SFT.FT_SERORI   AND SF1.F1_FORNECE = SFT.FT_CLIEFOR AND SF1.F1_LOJA = SFT.FT_LOJA AND (SFT.FT_TIPOMOV='S' AND SFT.FT_TIPO='D') AND SF1.%NotDel%) 
            WHERE  SFT.FT_FILIAL=%XFILIAL:SFT%        AND
                   SFT.FT_PRODUTO = %EXP:cCodProd%    AND
                   %EXP:cWhereTpRt%
                   SFT.FT_ENTRADA  <=  %EXP:dDataAte% AND
                   SFT.FT_DTCANC   = ''               AND
                   SFT.FT_QUANT    > 0                AND  
                   SFT.%NOTDEL%	
        EndSql

        DbSelectArea(cAlias)
        (cAlias)->(DbGoTop())
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

    EndIf

    //---Caso exista quantidade suficiente na movimentação de entrada para o produto, executa a query abaixo no período necessário para compor a quantidade informada em nQtdade ---//
    If lAchouFT

        DbSelectArea ("CDA")
        CDA->(DbSetOrder(1)) //---CDA_FILIAL+CDA_TPMOVI+CDA_ESPECI+CDA_FORMUL+CDA_NUMERO+CDA_SERIE+CDA_CLIFOR+CDA_LOJA+CDA_NUMITE+CDA_SEQ+CDA_CODLAN+CDA_CALPRO---//

        //---Definição do período necessário para compor a quantidade informada em nQtdade---//
        dDataDe := CtoD('  /  /    ')
        While nCount <= 12 .And. Empty(dDataDe)
            If aQtdadeAnt[nCount][2] >= nQtdade
                dDataDe   := aQtdadeAnt[nCount][1]
                lPerUlt12 := .T.
            EndIf
            nCount++
        EndDo
        dDataDe := Iif(Empty(dDataDe), aQtdadeAnt[13], dDataDe)

        //---Classe responsável pela apuração do movimento de entrada---//
        If cTipoRet = '2'
            oApurEntAn := FISA230APURACAO():New(cIdApur,cAnoMes,{},aDtIniReg)
            oApurEntAn:oMovimento:SetOrdMov(nOrdMovAtu)

            //---Verifica início de vigência dos registros 2115 e 2133---//
            lReg2115 := oApurEntAn:GetReg2115()
            lReg2133 := oApurEntAn:GetReg2133()
        EndIf

    	While nQtdade > 0
            cAliasSFT := GetNextAlias()

            //---Verifica a existência de guia para recolhimento de ICMS Antecipado na Apuração do ICMS---//
            If cTipoRet = '2'
                aNumDareAp := FISA231GAP(dDataDe,cMvDrcCdAj)
            EndIf

            BeginSql Alias cAliasSFT
                COLUMN FT_DATAMOV AS DATE

                SELECT SFT.FT_PRODUTO             FT_PRODUTO,
                       SB1.B1_UM                  B1_UM,
                       SB1.B1_SEGUM               B1_SEGUM,
                       SB1.B1_CONV                B1_CONV,
                       SB1.B1_TIPCONV             B1_TIPCONV,
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
                       CASE
                           WHEN ((SFT.FT_TIPOMOV='S' AND SFT.FT_TIPO NOT IN ('D','B')) OR (SFT.FT_TIPOMOV='E' AND SFT.FT_TIPO IN ('D','B')))
                           THEN SA1.A1_SIMPNAC
                           ELSE SA2.A2_SIMPNAC
                       END                        FT_SIMPNAC,
                       SFT.FT_CFOP                FT_CFOP,
                       SFT.FT_CLASFIS             FT_CLASFIS,
                       SFT.FT_QUANT               FT_QUANT,
                       SFT.FT_TOTAL               FT_TOTAL,
                       SFT.FT_FRETE               FT_FRETE,
                       SFT.FT_SEGURO              FT_SEGURO,
                       SFT.FT_DESPESA             FT_DESPESA,
                       SFT.FT_VALCONT             FT_VALCONT,
                       CASE 
                           WHEN SFT.FT_BASEICM = 0 AND SFT.FT_OUTRICM > 0
                           THEN CASE SFT.FT_TIPOMOV
				                    WHEN 'E' THEN SD1.D1_BASEICM
				        			         ELSE SD2.D2_BASEICM
				        		END
                           ELSE SFT.FT_BASEICM 
                       END                        FT_BASEICM, 
                       CASE 
                           WHEN SFT.FT_BASEICM = 0 AND SFT.FT_OUTRICM > 0
                           THEN CASE SFT.FT_TIPOMOV
				                    WHEN 'E' THEN SD1.D1_PICM
				        			         ELSE SD2.D2_PICM
				        		END
                           ELSE SFT.FT_ALIQICM 
                       END                        FT_ALIQICM, 
                       CASE 
                           WHEN SFT.FT_BASEICM = 0 AND SFT.FT_OUTRICM > 0
                           THEN CASE SFT.FT_TIPOMOV
				                    WHEN 'E' THEN SD1.D1_VALICM
				        			         ELSE SD2.D2_VALICM
				        		END
                           ELSE SFT.FT_VALICM 
                       END                        FT_VALICM, 
                       ISNULL(CD2.CD2_PREDBC,0)   CD2_PREDBC,
                       SFT.FT_BASERET             FT_BASERET,
                       SFT.FT_ALIQSOL             FT_ALIQSOL,
                       SFT.FT_ICMSRET             FT_ICMSRET,
                       SFT.FT_BASNDES             FT_BASNDES,
                       SFT.FT_ALQNDES             FT_ALQNDES,
                       SFT.FT_ICMNDES             FT_ICMNDES,
                       CASE 
                           WHEN %Exp:cSubStrBD1% = '60' AND SFT.FT_ICMSRET = 0 
                           THEN '2'
                           ELSE CASE WHEN SFT.FT_VALANTI > 0 
                                     THEN '3' 
                                     ELSE '1' 
                                END 
                       END                        FT_RESPRET,
                       CASE 
                           WHEN %Exp:cSubStrBD1% = '60' AND SFT.FT_ICMSRET = 0
                           THEN CASE 
                                   WHEN SFT.FT_BASNDES > 0 AND SFT.FT_ICMNDES > 0 
                                   THEN 1
                                   ELSE 0
                                END
                           ELSE 0
                       END                        FT_TGRETAN,
                       CASE 
                           WHEN %Exp:cSubStrBD1% = '60' AND SFT.FT_ICMSRET = 0 
                           THEN SFT.FT_BASNDES
                           ELSE SFT.FT_BASERET
                       END                        FT_BCST,
                       CASE 
                           WHEN %Exp:cSubStrBD1% = '60' AND SFT.FT_ICMSRET = 0 
                           THEN SFT.FT_ALQNDES
                           ELSE SFT.FT_ALIQSOL
                       END                        FT_ALQST,
                       CASE 
                           WHEN %Exp:cSubStrBD1% = '60' AND SFT.FT_ICMSRET = 0 
                           THEN SFT.FT_ICMNDES
                           ELSE SFT.FT_ICMSRET
                       END                        FT_VLRST,
                       SFT.FT_VALANTI             FT_VALANTI,
                       SFT.FT_NFORI               FT_NFORI, 
                       SFT.FT_SERORI              FT_SERORI, 
                       SFT.FT_ITEMORI             FT_ITEMORI,
                       CASE 
                           WHEN SFT.FT_TIPO = 'D'
                           THEN SF1.F1_DTDIGIT
                           ELSE ''
                       END                        FT_EMISORI,
                       SFT.FT_FORMUL              FT_FORMUL,
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
                       SFT.FT_QUANT    > 0                               AND 
                       SFT.%NOTDEL%
                ORDER BY %EXP:cOrderTpRt%
            EndSql 

            DbSelectArea(cAliasSFT)
            (cAliasSFT)->(DbGoTop())
            While !(cAliasSFT)->(Eof()) .And. ((cTipoRet == '2' .And. nEntPerAnt==1 .And. (lPerUlt12 .Or. (nQtdade > 0 .Or. cPerAtu == StrZero(Month((cAliasSFT)->FT_DATAMOV),2)+StrZero(Year((cAliasSFT)->FT_DATAMOV),4)))) .Or. nQtdade > 0)

                //---Define Base de Cálculo, Alíquota e Valor do ICMS-ST, além do responsável pela retenção do ICMS-ST (1 – Remetente Direto / 2 – Remetente Indireto / 3 – Próprio declarante )---//
                cRespRet   := (cAliasSFT)->FT_RESPRET
                nVlrBICMST := (cAliasSFT)->FT_BCST
                nVlrAICMST := (cAliasSFT)->FT_ALQST
                nVlrICMSST := (cAliasSFT)->FT_VLRST
                lTagRetAnt := Iif((cAliasSFT)->FT_TGRETAN == 1, .T., .F.)

                nVlrBICMS  := (cAliasSFT)->FT_BASEICM
                nVlrAICMS  := (cAliasSFT)->FT_ALIQICM
                nVlrICMS   := (cAliasSFT)->FT_VALICM 
                aAliqEfet  :=  FISA231ALQ((cAliasSFT)->CD2_PREDBC,nVlrBICMST,nVlrAICMST)

                If cTipoRet == '1' //---Ressarcimento em Saída Interna p/ Simples Nacional---//

                    //------------------------------------------------------------------------------------------------------------------------------------------------------//
                    /* Capítulo VI do Título II do ANEXO 3 do RICMS-SC, Seção XXI
                       § 5º O contribuinte substituído que receber mercadoria com imposto retido, calculado mediante utilização de percentual integral da MVA, e promover sua
                            saída com destino a contribuinte estabelecido neste Estado enquadrado no Simples Nacional poderá, na forma da Seção IX do Capítulo II do Título II 
                            deste Anexo, ressarcir-se do valor que resultar da multiplicação dos seguintes fatores:

                        I   – base de cálculo utilizada para apuração do imposto devido por substituição, excluída desta a parcela correspondente à MVA utilizada para o 
                              cálculo do imposto retido;
                        II  – coeficiente correspondente a 70% (setenta por cento) do percentual de MVA original aplicável à operação;
                        III – coeficiente determinado pela equação: (1 - ALQ inter)/ (1 - ALQ intra), em que:
                            a) “ALQ inter” é o coeficiente correspondente à alíquota interestadual aplicável à operação; e
                            b) “ALQ intra” é o coeficiente correspondente:
                                1. à alíquota interna aplicável sobre a operação substituída; ou
                                2. na hipótese de a operação substituída ser contemplada com redução de base de cálculo, ao percentual de carga tributária efetiva; e
                        IV – coeficiente correspondente à alíquota interna incidente sobre a mercadoria.

                        Ou seja, o valor de ressarcimento será dado por: [BC ST - MVA operação] x [70% MVA Orginal] x [(1 - ALQ inter)/ (1 - ALQ intra)] x [Alíqota Interna]
                    */
                    //------------------------------------------------------------------------------------------------------------------------------------------------------//

                    nVlrMVAOp := (cAliasSFT)->FT_MARGEM

                    If nVlrMVAOp > 0

                        //---Retirar MVA da operação da Base de Cálculo do ICMS-ST---//
                        nVlrBICMST := nVlrBICMST / (1 + (nVlrMVAOp / 100))

                        //---Calcular MVA original à partir da MVA da operação, que é ajustada---//
                        nVlrMVAOri := ((((nVlrMVAOp / 100) + 1) * (1 - (aAliqEfet[1] / 100))  ) / (1 - (nVlrAICMS / 100))) -1

                        //---Calcular o Valor de Ressarcimento---//
                        nVlrRessSN := Round(nVlrBICMST * (nVlrMVAOri * nPercRess) * ((1 - (nVlrAICMS / 100)) / (1 - (aAliqEfet[1] / 100))) * (nVlrAICMST / 100),2)

                    EndIf

                    If (cAliasSFT)->FT_QUANT <= nQtdade
                        nValorPro  := nVlrRessSN
                        nQtdadePro := (cAliasSFT)->FT_QUANT
                    Else
                        nValorPro  := Round((nVlrRessSN / (cAliasSFT)->FT_QUANT) * nQtdade,2)
                        nQtdadePro := nQtdade
                    EndIf
                    nTotRessSN += nValorPro
                    nQtdade    -= nQtdadePro

                ElseIf cTipoRet == '2' //---Base de Cálculo ICMS-ST / Valor ICMS-ST / Valor ICMS / Quantidade (Somatórios para cálculo de média)---//

                    If (cAliasSFT)->FT_TIPO != 'D'
                        nQtdade    -= (cAliasSFT)->FT_QUANT

                        //---Entrada da mercadoria em casos onde o responsável pela retenção do ICMS-ST seja 3–Próprio declarante (ICMS Antecipado) é necessário definir:                  ---//
                        //---Código de lançamento de débito na EFD / Código do modelo do documento de arrecadação / Número do DARE - Guia para recolhimento de ICMS Antecipado na operação)---//
                        cCodAju    := ''
                        cCodDA     := ''
                        cNumDare   := ''
                        If cRespRet == '3' .And. !Empty(cMvDrcCdAj)
    
                            //---Código de lançamento de débito---//
                            cCodAju := FISA231CDA(cAliasSFT,cMvDrcCdAj)
    
                            If !Empty(cCodAju)
    
                                //---Verifica a existência de guia para recolhimento de ICMS Antecipado na operação---//
                                aNumDareOp := aSize(aNumDareOp,0)
                                aNumDareOp := FISA231GOP(cAliasSFT, cCodAju)
    
                                If Len(aNumDareOp) == 2 .And. aNumDareOp[1]
                                    cCodDA   := Iif(!Empty(aNumDareOp[2]), '0', '1')
                                    cNumDare := aNumDareOp[2]
                                ElseIf Len(aNumDareAp) == 2 .And. aNumDareAp[1]
                                    cCodDA   := Iif(!Empty(aNumDareAp[2]), '0', '1')
                                    cNumDare := aNumDareAp[2]
                                EndIf
    
                            EndIf
                        EndIf

                    Else
                        nQtdade    += (cAliasSFT)->FT_QUANT

                        //---Valores apurados para o Documento Fiscal Original, em casos de movimentos de devolução---//
                        aDocOriApu := aSize(aDocOriApu,0)
                        aDocOriApu := Fisa231Ap((cAliasSFT)->FT_TIPOMOV, (cAliasSFT)->FT_NFORI, (cAliasSFT)->FT_SERORI, (cAliasSFT)->FT_ITEMORI, (cAliasSFT)->FT_CLIEFOR, (cAliasSFT)->FT_LOJA, (cAliasSFT)->FT_PRODUTO, cAnoMes)
                    EndIf

                    If !(cAliasSFT)->FT_TIPO $ "P|I|C" //---Não apura movimentos de complementos, uma vez que estes serão agragados ao movimento original através da função FISA231CMP---//

                        //---Execução P.E. FSA231UND: Utilização das quantidades e unidades informadas no Documento Fiscal, em casos em que a unidade do Documento Fiscal seja diferente da unidade do Registro 0200---//
                        nQtdadeMv := (cAliasSFT)->FT_QUANT //---Quantidade presente no movimento na unidade de inventário (0200)---//
                        cUnid     := (cAliasSFT)->B1_UM    //---Unidade de inventário (0200)---//
                        nFatorC   := 1
                        cFatorCTp := 'M'
                        If lFsa231Und
                            aFsa231Und := ExecBlock("FSA231UND", .F., .F., {cAliasSFT})
					        If ValType(aFsa231Und) == "A" .And. Len(aFsa231Und) == 4 .And. ValType(aFsa231Und[1]) == 'C' .And. ValType(aFsa231Und[2]) == 'N' .And. ValType(aFsa231Und[3]) == 'N' .And. ValType(aFsa231Und[4]) == 'C'
                                nQtdadeMv := aFsa231Und[2]
                                cUnid     := aFsa231Und[1]
                            	nFatorC   := aFsa231Und[3]
                            	cFatorCTp := aFsa231Und[4]
                            Endif
                        EndIf

                        //---Retorna valores de documentos fiscais complementares ao documento posicionado na query principal de movimento---//
                        aVlrCmp  := aSize(aVlrCmp,0)
                        If (lReg2115 .And. (cAliasSFT)->FT_TIPOMOV == 'S') .Or. (lReg2133 .And. (cAliasSFT)->FT_TIPOMOV == 'E')
                            aVlrCmp := FISA231CMP((cAliasSFT)->FT_TIPOMOV, (cAliasSFT)->FT_NFISCAL, (cAliasSFT)->FT_SERIE, (cAliasSFT)->FT_ITEM, (cAliasSFT)->FT_CLIEFOR, (cAliasSFT)->FT_LOJA, (cAliasSFT)->FT_PRODUTO, (cAliasSFT)->FT_DATAMOV)
                        Else
                            aVlrCmp := {0, 0, 0, 0, 0, 0, 0, 0, 0, .F.}
                        EndIf

                        //---Método SetaMovim: Carrega os dados do movimento para que seja feita sua apuração---//
                        oApurEntAn:SetaMovim((cAliasSFT)->FT_DATAMOV,;                                //---dDataMov   - Data do Movimento
                                             (cAliasSFT)->FT_TIPOMOV,;                                //---cTipoMov   - Tipo do Movimento (E-Entrada / S-Saída)
                                             '',;                                                     //---cNumSerECF - Número de Série de Fabricação do ECF
                                             (cAliasSFT)->FT_TIPO,;                                   //---cTipoDoc   - Tipo do Documento (Normal / Devolução / Complemento)
                                             (cAliasSFT)->FT_PRODUTO,;                                //---cCodProd   - Código do Produto
                                             '',;                                                     //---cTipoPart  - Tipo do Participante (Cliente Final / Revendedor)
                                             (cAliasSFT)->FT_SIMPNAC,;                                //---cPartOptSN - Participante Optante pelo Simples Nacional (1-Sim / 2-Não)
                                             nAliqInt,;                                               //---nAliqInt   - Alíquota Interna do Produto
                                             (cAliasSFT)->FT_CFOP,;                                   //---cCFOP      - CFOP
                                             Right((cAliasSFT)->FT_CLASFIS,2),;                       //---cCST       - CST ICMS
                                             nQtdadeMv + aVlrCmp[1],;                                 //---nQtdade    - Quantidade informada no Documento Fiscal
                                             cUnid,;                                                  //---cUnid      - Unidade informada no Documento Fiscal
                                             nFatorC,;                                                //---nFatorC    - Fator de Conversão da Quantidade informada no Documento Fiscal para a Unidade utilizada no Registro 0200
                                             cFatorCTp,;                                              //---cFatorCTp  - Tipo de Conversão: M-Multiplicação / D-Divisão
                                             (cAliasSFT)->FT_VALCONT + aVlrCmp[3],;                   //---nVlrTotNf  - Valor Total da Nota Fiscal
                                             (cAliasSFT)->FT_BASEICM + aVlrCmp[4],;                   //---nVlrBICMS  - Base de Cálculo do ICMS
                                             Iif(aVlrCmp[5]>0, aVlrCmp[5], (cAliasSFT)->FT_ALIQICM),; //---nVlrAICMS  - Alíquota do ICMS
                                             (cAliasSFT)->FT_VALICM + aVlrCmp[6],;                    //---nVlrICMS   - Valor do ICMS
                                             nVlrBICMST + aVlrCmp[7],;                                //---nVlrBICMST - Valor da Base de Cálculo do ICMS-ST
                                             Iif(aVlrCmp[8]>0, aVlrCmp[8], nVlrAICMST),;              //---nVlrAICMST - Alíquota do ICMS-ST
                                             nVlrICMSST + aVlrCmp[9],;                                //---nVlrICMSST - Valor do ICMS-ST
                                             cRespRet,;                                               //---cRespRet   - Responsável pela retenção do ICMS-ST (1 – Remetente Direto / 2 – Remetente Indireto / 3 – Próprio declarante )---//
                                             lTagRetAnt,;                                             //---lTagRetAnt - Indicador de preenchimento das TAGs "vBCSTRet" e "vICMSSTRet" do Grupo Tributação do ICMS = 60---//
                                             '',;                                                     //---cPrdResVSN - Indicador de cálculo de Ressarcimento em caso de saída interna para Optante pelo Simples Nacional (1–Sim / 2–Não)---//
                                             0,;                                                      //---nPercRess  - Percentual de redução do MVA utilizado em saídas internas destinadas a empresa optante pelo Simples Nacional---//
                                             aDocOriApu,;                                             //---aDocOriApu - Valores apurados para o Documento Fiscal Original, em casos de movimentos de devolução
                                             cCodAju,;                                                //---cCodAju    - Código do Ajuste de débito informado no Registro C197 da EFD ICMS/IPI
                                             cCodDA,;                                                 //---cCodDA     - Código do modelo do documento de arrecadação
                                             cNumDare)                                                //---cNumDare   - Número do DARE - Guia para recolhimento de ICMS Antecipado na operação

                        //---Seto atributo cAnoMes para o mesmo período do movimento analisado, que é anterior ao da apuração, para que seja possível a apuração de devoluções---//
                        oApurEntAn:SetAnoMes(Left(DtoS((cAliasSFT)->FT_DATAMOV),6))

                        //---Método ApuraMovim: Para Entradas..: Alimenta objeto o2120          ---//
                        //---                   Carrega os valores apurados no objeto oMovimento---//
                        oApurEntAn:ApuraMovim(nEntPerAnt)

                        //---Seto atributo cAnoMes para o período apurado, para correta gravação----//
                        oApurEntAn:SetAnoMes(cAnoMes)
                        
                        AcessoF1M('2',cAliasSFT,oApurEntAn,aVlrCmp)
                    EndIf

                ElseIf cTipoRet == '3' //---Alíquota Efetiva quando a mercadoria for contemplada com redução da base de cálculo---//
                    nAliqEfet := aAliqEfet[1]
                    nQtdade   := 0
                EndIf

                cPerAtu := StrZero(Month((cAliasSFT)->FT_DATAMOV),2)+StrZero(Year((cAliasSFT)->FT_DATAMOV),4)

                (cAliasSFT)->(DbSkip())
            EndDo
            (cAliasSFT)->(DbCloseArea()) 

            //---Período Anterior---//
            dDataDe	 := FirstDay(dDataDe-1)
            dDataAte := LastDay(dDataDe)
    	EndDo

        If cTipoRet == '1'
            Self:nVlrRessSN := nTotRessSN
        ElseIf cTipoRet == '2'
            aSBCICMSST[1] := oApurEntAn:o2120:GetCampo03() //---Base de Cálculo ICMS-ST 2120---//
            aSBCICMSST[2] := oApurEntAn:o2120:GetCampo07() //---Valor ICMS-ST 2120---//
            aSBCICMSST[3] := oApurEntAn:o2120:GetCampo05() //---Valor ICMS 2120---//
            aSBCICMSST[4] := oApurEntAn:o2120:GetCampo02() //---Quantidade 2120---//
            aSBCICMSST[5] := oApurEntAn:o2121:GetShw2121() //---Indicador Registro 2121---//
            aSBCICMSST[6] := oApurEntAn:o2121:GetCampo04() //---Base de Cálculo ICMS-ST 2121---//
            aSBCICMSST[7] := oApurEntAn:o2121:GetCampo02() //---Quantidade 2121---//
            aSBCICMSST[8] := oApurEntAn:o2121:GetCampo03() //---Quantidade Válida p/ Média 2121---//
            Self:aSBCICMSST := aSBCICMSST
        ElseIf cTipoRet == '3'
            Self:nAliqEfet := nAliqEfet
        EndIf
    
    EndIf

    RestArea(aArea)

Return
