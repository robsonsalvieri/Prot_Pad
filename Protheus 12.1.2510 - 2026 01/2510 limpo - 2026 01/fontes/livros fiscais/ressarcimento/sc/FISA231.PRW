#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "FISA231.CH"

//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} FISA231

Rotina de Apuração da DRCST - Demonstrativo para Apuração Mensal do Ressarcimento,
da Restituição e da Complementação do ICMS Substituição Tributária, do Estado de Santa Catarina.
O método de apuração é determinado pelo Decreto Nº 1818 DE 28/11/2018 e pela Portaria SEF N° 378/2018.

@author Ulisses P. Oliveira
@since 27/03/2019
@version 1.0
/*/
//--------------------------------------------------------------------------------------------------
Function FISA231()
    Local aArea     := GetArea()
    Local cIdApur   := ''
    Local cPerApur  := ''
    Local lProcess  := .T.
    Local nEntPerAnt:= 1 //1 - Todas , 2 - Qtde Necessária. (Default 1- Todas as entradas)

    If Pergunte("FSA231",.T.)
        cPerApur := Right(MV_PAR01,4)+Left(MV_PAR01,2)
        
        if FSA231X1("FSA231","MV_PAR03") //Verifico se existe o parâmetro MV_PAR03 no pergunte
            nEntPerAnt:=MV_PAR03
        endif
        //---Verifica a existência de apuração no período selecionado---//
        cIdApur := CheckApur(cPerApur)

        If !Empty(cIdApur)
		    If (ApMsgNoYes(STR0001 + CHR(10) + CHR(13) + STR0002 ) ) //--Apuração já realizada no período selecionado. Deseja fazer o reprocessamento?---//
                If !(DeletApur(cIdApur,cPerApur))
                    MsgStop(STR0014) //---Apuração não pode ser excluída por esta rotina.---//
                    lProcess := .F.
                EndIf
            Else
                lProcess := .F.
            EndIf
        EndIf

        If lProcess
            FwMsgRun(,{|oSay| FISA231A(oSay,cPerApur,nEntPerAnt)},STR0003,"")   //---Apuração: Ressarcimento, Restituição e Complementação ICMS ST---//
        EndIf

    EndIf

    RestArea(aArea)
Return


//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} FISA231A

Rotina de Processamento da Apuração.

@author Ulisses P. Oliveira
@since 27/03/2019
@version 1.0
/*/
//--------------------------------------------------------------------------------------------------
Function FISA231A(oSay,cPerApur,nEntPerAnt)
    Local cAlias      := GetNextAlias()
    Local cIdApur     := ''
    Local dDataDe     := CtoD('  /  /    ')
    Local dDataAte    := CtoD('  /  /    ')
    Local dDataAtePA  := CtoD('  /  /    ')
    Local dDataDeP1   := CtoD('  /  /    ')
    Local dDataDeP2   := CtoD('  /  /    ')
    Local dDataDeP3   := CtoD('  /  /    ')
    Local dDataDeP4   := CtoD('  /  /    ')
    Local dDataDeP5   := CtoD('  /  /    ')
    Local dDataDeP6   := CtoD('  /  /    ')
    Local dDataDeP7   := CtoD('  /  /    ')
    Local dDataDeP8   := CtoD('  /  /    ')
    Local dDataDeP9   := CtoD('  /  /    ')
    Local dDataDeP10  := CtoD('  /  /    ')
    Local dDataDeP11  := CtoD('  /  /    ')
    Local dDataDeP12  := CtoD('  /  /    ')
    Local cProduto    := ''
    Local nMVICMPAD   := SuperGetMv("MV_ICMPAD",.F.,18)
    Local aAliqEfet   := {}
    Local nAliqInt    := 0
    Local nQtdPerAnt  := 0
    Local aQtdPerAnt  := {{'',0},{'',0},{'',0},{'',0},{'',0},{'',0},{'',0},{'',0},{'',0},{'',0},{'',0},{'',0},CtoD('  /  /    ')}
    Local cRespRet    := ''
    Local lTagRetAnt  := .F.
    Local aDocOriApu  := {}
    Local aVlrCmp     := {}
    Local nVlrBICMST  := 0
    Local nVlrAICMST  := 0
    Local nVlrICMSST  := 0
    Local oApuracao   := Nil
    Local cSGBD       := TCGetDB()
    Local cSubStrBD   := ''
    Local cSubStrBD1  := ''
    Local cSubStrBD2  := ''
    Local cSubStrBD3  := ''
    Local cSubStrBD4  := ''
    Local cSFTStrId0  := ''
    Local cSFTStrId1  := ''
    Local cSFTStrId2  := ''
    Local cSFTStrId3  := ''
    Local cSFTStrId4  := ''
    Local cSFTStrId5  := ''
    Local cSFTStrId6  := ''
    Local cSFTStrId7  := ''
    Local nSFTStrId0  := TamSX3("FT_ENTRADA")[1]
    Local nSFTStrId1  := TamSX3("D1_NUMSEQ")[1]
    Local nSFTStrId2  := TamSX3("FT_FILIAL")[1]
    Local nSFTStrId3  := TamSX3("FT_TIPOMOV")[1]
    Local nSFTStrId4  := TamSX3("FT_SERIE")[1]
    Local nSFTStrId5  := TamSX3("FT_NFISCAL")[1]
    Local nSFTStrId6  := TamSX3("FT_CLIEFOR")[1]
    Local nSFTStrId7  := TamSX3("FT_LOJA")[1]
    Local nSFTStrId8  := TamSX3("FT_ITEM")[1]
    Local nSFTStrId9  := TamSX3("FT_PRODUTO")[1]
    Local lF2Q        := AliasIndic("F2Q") .And. F2Q->(FieldPos("F2Q_RESVSN")) > 0
    Local cF2QCampo   := ''
    Local cF2QRelac   := ''
    Local cAliBLH     := ''
    Local lSPDBlocH	  := FindFunction("SPDBlocH")
    Local nQtdEstPrd  := 0
    Local nPercRess   := (MV_PAR02/100)
    Local cDtIniReCo  := SuperGetMv("MV_SCINIRC",,"05/04/2017,01/01/2019,01/02/2019")
    Local aDtIniReCo  := Iif(Empty(cDtIniReCo) .Or. Len(cDtIniReCo) != 32,{"05/04/2017","01/01/2019","01/02/2019"},StrTokArr(cDtIniReCo,',')) //---Data de início: Restituição, Complemento, Ressarcimento---//
    Local cDtIniReg   := SuperGetMv("MV_DRCIREG",,"16/07/2019,16/07/2019,31/10/2019,31/10/2019")
    Local aDtIniReg   := Iif(Empty(cDtIniReg) .Or. Len(cDtIniReg) != 43,{"16/07/2019","16/07/2019","31/10/2019","31/10/2019"},StrTokArr(cDtIniReg,',')) //---Data de início: Registros 2115, 2133, 2121, 2134 ---//
    Local lReg2115    := .F.
    Local lReg2133    := .F.
    Local cCodAju     := ''
    Local cMvDrcCdAj  := SuperGetMv("MV_DRCCDAJ",.F.,'')
    Local cCodDA      := ''
    Local cNumDare    := ''
    Local aNumDareAp  := {}
    Local aNumDareOp  := {}
    Local nQtdade     := 0
    Local cUnid       := ''
    Local nFatorC     := 0
    Local cFatorCTp   := ''
    Local lFsa231Und  := ExistBlock("FSA231UND")
    Local aFsa231Und  := {}

    Private lAutomato := Iif(IsBlind(),.T.,.F.)

    Default nEntPerAnt:= 1 //1 - Todas , 2 - Qtde Necessária. (Default 1- Todas as entradas)

    If AliasIndic("F1I") .And. AliasIndic("F1J") .And. AliasIndic("F1K") .And. AliasIndic("F1L") .And. AliasIndic("F1M") .And. AliasIndic("F2W") .And. AliasIndic("F3M")
		DbSelectArea ("F1I")
		DbSelectArea ("F1J")
		DbSelectArea ("F1K")
		DbSelectArea ("F1L")
		DbSelectArea ("F1M")
		DbSelectArea ("F2W")
		DbSelectArea ("F3M")

        DbSelectArea ("CDA")
        CDA->(DbSetOrder(1)) // CDA_FILIAL+CDA_TPMOVI+CDA_ESPECI+CDA_FORMUL+CDA_NUMERO+CDA_SERIE+CDA_CLIFOR+CDA_LOJA+CDA_NUMITE+CDA_SEQ+CDA_CODLAN+CDA_CALPRO
        SD1->(DbSetOrder(19))// J D1_FILIAL+D1_NFORI+D1_SERIORI+D1_FORNECE+D1_LOJA 
        SD2->(DbSetOrder(10))// A D2_FILIAL+D2_NFORI+D2_SERIORI 

        //------------------------------------------------------------------------------------------------------------------------------------------------------//
        /* SPDBlocH - Função do SPED Fiscal que gera um alias temporário com o conteúdo do relatório MATR460 - Registro de Invertário Modelo P7

           Sem o retorno dessa função não é possível o processamento da apuração, uma vez que a apuração verifica quantidades em estoque ao final do período apurado,
           pois, segundo o Decreto Nº 1818 DE 28/11/2018, Art. 25-A Inciso II § 4º e § 5º, e na validação do Campo 02 (S_QUANT_C) do Registro 2120, a quantidade de
           entradas deve ser maior ou igual ao somatório da quantidade de saídas e da quantidade em estoque ao final do período apurado. Além disso, o Bloco H, na
           mesma estrutura do SPED Fiscal é exigido no arquivo a ser transmitido.
        */
        //------------------------------------------------------------------------------------------------------------------------------------------------------//
        AtualizaMsg(oSay,STR0012) //---Verificando fechamento de estoque do período...---//

        dDataDe    := StoD(cPerApur+'01')
        dDataAte   := LastDay(dDataDe)
        dDataAtePA := dDataDe-1
        dDataDeP1  := FirstDay(dDataAtePA)
        dDataDeP2  := FirstDay(dDataDeP1 -1)
        dDataDeP3  := FirstDay(dDataDeP2 -1)
        dDataDeP4  := FirstDay(dDataDeP3 -1)
        dDataDeP5  := FirstDay(dDataDeP4 -1)
        dDataDeP6  := FirstDay(dDataDeP5 -1)
        dDataDeP7  := FirstDay(dDataDeP6 -1)
        dDataDeP8  := FirstDay(dDataDeP7 -1)
        dDataDeP9  := FirstDay(dDataDeP8 -1)
        dDataDeP10 := FirstDay(dDataDeP9 -1)
        dDataDeP11 := FirstDay(dDataDeP10-1)
        dDataDeP12 := FirstDay(dDataDeP11-1)

        If lSPDBlocH
            SPDBlocH(@cAliBLH,'',dDataAte)
        EndIf

        If !Empty(cAliBLH) .Or. lAutomato

            AtualizaMsg(oSay,STR0004) //---Iniciando processamento...---//

            cIdApur := FWUUID("F1I")

            //---Classe responsável pela apuração do movimento---//
            oApuracao := FISA230APURACAO():New(cIdApur,cPerApur,aDtIniReCo,aDtIniReg)

            //---Verifica a existência de guia para recolhimento de ICMS Antecipado na Apuração do ICMS---//
            aNumDareAp := FISA231GAP(dDataDe,cMvDrcCdAj)

            AtualizaMsg(oSay,STR0005) //---Verificando movimento no período...---//

            //---Query Principal---//
            If cSGBD = 'ORACLE'
                cSubStrBD  := 'SUBSTR(SFT.FT_CLASFIS,2,2)'
                cSubStrBD1 := 'SUBSTR(SFTS1.FT_CLASFIS,2,2)'
                cSubStrBD2 := 'SUBSTR(SFTS1.FT_ENTRADA,1,6)'
                cSubStrBD3 := 'SUBSTR(SF1S1.F1_DTDIGIT,1,6)'
                cSubStrBD4 := 'SUBSTR(SFT2.FT_CLASFIS,2,2)'
                cSFTStrId0 := 'SUBSTR(SFT_.FT_STRID,'+cValToChar(nSFTStrId0 + nSFTStrId1 + 1)                                                                                           +','+cValToChar(nSFTStrId2)+')'
                cSFTStrId1 := 'SUBSTR(SFT_.FT_STRID,'+cValToChar(nSFTStrId0 + nSFTStrId1 + nSFTStrId2 + 1)                                                                              +','+cValToChar(nSFTStrId3)+')'
                cSFTStrId2 := 'SUBSTR(SFT_.FT_STRID,'+cValToChar(nSFTStrId0 + nSFTStrId1 + nSFTStrId2 + nSFTStrId3 + 1)                                                                 +','+cValToChar(nSFTStrId4)+')'
                cSFTStrId3 := 'SUBSTR(SFT_.FT_STRID,'+cValToChar(nSFTStrId0 + nSFTStrId1 + nSFTStrId2 + nSFTStrId3 + nSFTStrId4 + 1)                                                    +','+cValToChar(nSFTStrId5)+')'
                cSFTStrId4 := 'SUBSTR(SFT_.FT_STRID,'+cValToChar(nSFTStrId0 + nSFTStrId1 + nSFTStrId2 + nSFTStrId3 + nSFTStrId4 + nSFTStrId5 + 1)                                       +','+cValToChar(nSFTStrId6)+')'
                cSFTStrId5 := 'SUBSTR(SFT_.FT_STRID,'+cValToChar(nSFTStrId0 + nSFTStrId1 + nSFTStrId2 + nSFTStrId3 + nSFTStrId4 + nSFTStrId5 + nSFTStrId6 + 1)                          +','+cValToChar(nSFTStrId7)+')'
                cSFTStrId6 := 'SUBSTR(SFT_.FT_STRID,'+cValToChar(nSFTStrId0 + nSFTStrId1 + nSFTStrId2 + nSFTStrId3 + nSFTStrId4 + nSFTStrId5 + nSFTStrId6 + nSFTStrId7 + 1)             +','+cValToChar(nSFTStrId8)+')'
                cSFTStrId7 := 'SUBSTR(SFT_.FT_STRID,'+cValToChar(nSFTStrId0 + nSFTStrId1 + nSFTStrId2 + nSFTStrId3 + nSFTStrId4 + nSFTStrId5 + nSFTStrId6 + nSFTStrId7 + nSFTStrId8 + 1)+','+cValToChar(nSFTStrId9)+')'
            Else
                cSubStrBD  := 'RIGHT(SFT.FT_CLASFIS,2)'
                cSubStrBD1 := 'RIGHT(SFTS1.FT_CLASFIS,2)'
                cSubStrBD2 := 'LEFT(SFTS1.FT_ENTRADA,6)'
                cSubStrBD3 := 'LEFT(SF1S1.F1_DTDIGIT,6)'
                cSubStrBD4 := 'RIGHT(SFT2.FT_CLASFIS,2)'
                cSFTStrId0 := 'SUBSTRING(SFT_.FT_STRID,'+cValToChar(nSFTStrId0 + nSFTStrId1 + 1)                                                                                           +','+cValToChar(nSFTStrId2)+')'
                cSFTStrId1 := 'SUBSTRING(SFT_.FT_STRID,'+cValToChar(nSFTStrId0 + nSFTStrId1 + nSFTStrId2 + 1)                                                                              +','+cValToChar(nSFTStrId3)+')'
                cSFTStrId2 := 'SUBSTRING(SFT_.FT_STRID,'+cValToChar(nSFTStrId0 + nSFTStrId1 + nSFTStrId2 + nSFTStrId3 + 1)                                                                 +','+cValToChar(nSFTStrId4)+')'
                cSFTStrId3 := 'SUBSTRING(SFT_.FT_STRID,'+cValToChar(nSFTStrId0 + nSFTStrId1 + nSFTStrId2 + nSFTStrId3 + nSFTStrId4 + 1)                                                    +','+cValToChar(nSFTStrId5)+')'
                cSFTStrId4 := 'SUBSTRING(SFT_.FT_STRID,'+cValToChar(nSFTStrId0 + nSFTStrId1 + nSFTStrId2 + nSFTStrId3 + nSFTStrId4 + nSFTStrId5 + 1)                                       +','+cValToChar(nSFTStrId6)+')'
                cSFTStrId5 := 'SUBSTRING(SFT_.FT_STRID,'+cValToChar(nSFTStrId0 + nSFTStrId1 + nSFTStrId2 + nSFTStrId3 + nSFTStrId4 + nSFTStrId5 + nSFTStrId6 + 1)                          +','+cValToChar(nSFTStrId7)+')'
                cSFTStrId6 := 'SUBSTRING(SFT_.FT_STRID,'+cValToChar(nSFTStrId0 + nSFTStrId1 + nSFTStrId2 + nSFTStrId3 + nSFTStrId4 + nSFTStrId5 + nSFTStrId6 + nSFTStrId7 + 1)             +','+cValToChar(nSFTStrId8)+')'
                cSFTStrId7 := 'SUBSTRING(SFT_.FT_STRID,'+cValToChar(nSFTStrId0 + nSFTStrId1 + nSFTStrId2 + nSFTStrId3 + nSFTStrId4 + nSFTStrId5 + nSFTStrId6 + nSFTStrId7 + nSFTStrId8 + 1)+','+cValToChar(nSFTStrId9)+')'
            EndIf
            cSubStrBD  := "%" + cSubStrBD  + "%"
            cSubStrBD1 := "%" + cSubStrBD1 + "%"
            cSubStrBD2 := "%" + cSubStrBD2 + "%"
            cSubStrBD3 := "%" + cSubStrBD3 + "%"
            cSubStrBD4 := "%" + cSubStrBD4 + "%"
            cSFTStrId0 := "%" + cSFTStrId0 + "%"
            cSFTStrId1 := "%" + cSFTStrId1 + "%"
            cSFTStrId2 := "%" + cSFTStrId2 + "%"
            cSFTStrId3 := "%" + cSFTStrId3 + "%"
            cSFTStrId4 := "%" + cSFTStrId4 + "%"
            cSFTStrId5 := "%" + cSFTStrId5 + "%"
            cSFTStrId6 := "%" + cSFTStrId6 + "%"
            cSFTStrId7 := "%" + cSFTStrId7 + "%"

            If lF2Q
                cF2QCampo := "ISNULL(F2Q.F2Q_RESVSN,'')"
                cF2QRelac := "LEFT OUTER JOIN "+RetSqlName("F2Q")+" F2Q ON (F2Q.F2Q_FILIAL = '"+xFilial("F2Q")+"' AND F2Q.F2Q_PRODUT = SB1.B1_COD AND F2Q.D_E_L_E_T_ = '')"
            Else
                cF2QCampo := "''"
                cF2QRelac := ""
            EndIf
            cF2QCampo := "%" + cF2QCampo + "%"
            cF2QRelac := "%" + cF2QRelac + "%"

            BeginSql Alias cAlias
                COLUMN FT_EMISSAO AS DATE
                COLUMN FT_ENTRADA AS DATE
                COLUMN FT_DATAMOV AS DATE
                COLUMN UE_PERINI  AS DATE

                SELECT SFT.FT_PRODUTO             FT_PRODUTO,
                       SB1.B1_PICM                B1_PICM,
                       SB1.B1_UM                  B1_UM,
                       SB1.B1_SEGUM               B1_SEGUM,
                       SB1.B1_CONV                B1_CONV,
                       SB1.B1_TIPCONV             B1_TIPCONV,
                       %Exp:cF2QCampo%            F2Q_RESVSN,
                       ISNULL(SFT_.FT_QUANTPA,0)  UE_QTDPA, 
                       ISNULL(SFT_.FT_QUANTP1 ,0) UE_QTDP1, 
                       ISNULL(SFT_.FT_QUANTP2 ,0) UE_QTDP2, 
                       ISNULL(SFT_.FT_QUANTP3 ,0) UE_QTDP3, 
                       ISNULL(SFT_.FT_QUANTP4 ,0) UE_QTDP4, 
                       ISNULL(SFT_.FT_QUANTP5 ,0) UE_QTDP5, 
                       ISNULL(SFT_.FT_QUANTP6 ,0) UE_QTDP6, 
                       ISNULL(SFT_.FT_QUANTP7 ,0) UE_QTDP7, 
                       ISNULL(SFT_.FT_QUANTP8 ,0) UE_QTDP8, 
                       ISNULL(SFT_.FT_QUANTP9 ,0) UE_QTDP9, 
                       ISNULL(SFT_.FT_QUANTP10,0) UE_QTDP10, 
                       ISNULL(SFT_.FT_QUANTP11,0) UE_QTDP11, 
                       ISNULL(SFT_.FT_QUANTP12,0) UE_QTDP12, 
                       ISNULL(SFT_.FT_PERINI,'')  UE_PERINI, 
                       CASE 
                           WHEN %Exp:cSubStrBD4% = '60' AND SFT2.FT_ICMSRET = 0 
                           THEN SFT2.FT_BASNDES
                           ELSE SFT2.FT_BASERET
                       END                        UE_BCST,
                       CASE 
                           WHEN %Exp:cSubStrBD4% = '60' AND SFT2.FT_ICMSRET = 0 
                           THEN SFT2.FT_ALQNDES
                           ELSE SFT2.FT_ALIQSOL
                       END                        UE_ALQST,
                       ISNULL(CD2.CD2_PREDBC,0)   UE_PREDBC, 
                       CASE SFT.FT_TIPOMOV
                           WHEN 'E' THEN      SFT.FT_ENTRADA
                           ELSE               SFT.FT_EMISSAO
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
                       ISNULL(SA1.A1_PESSOA,'')   A1_PESSOA,
                       CASE
                           WHEN ISNULL(SF21.F2_TIPOCLI,'')<>''
                           THEN SF21.F2_TIPOCLI
                           ELSE
                               CASE
                                       WHEN ISNULL(SF22.F2_TIPOCLI,'')<>''
                                       THEN SF22.F2_TIPOCLI
                                       ELSE ISNULL(SA1.A1_TIPO,'')
                               END
                       END                        A1_TIPO,
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
                       SFT.FT_BASERET             FT_BASERET,
                       SFT.FT_ALIQSOL             FT_ALIQSOL,
                       SFT.FT_ICMSRET             FT_ICMSRET,
                       SFT.FT_BASNDES             FT_BASNDES,
                       SFT.FT_ALQNDES             FT_ALQNDES,
                       SFT.FT_ICMNDES             FT_ICMNDES,
                       CASE 
                           WHEN %Exp:cSubStrBD% = '60' AND SFT.FT_ICMSRET = 0 
                           THEN '2'
                           ELSE CASE WHEN SFT.FT_VALANTI > 0 
				                     THEN '3' 
				                     ELSE '1' 
				                END 
                       END                        FT_RESPRET,
                       CASE 
                           WHEN %Exp:cSubStrBD% = '60' AND SFT.FT_ICMSRET = 0
                           THEN CASE 
                                   WHEN SFT.FT_BASNDES > 0 AND SFT.FT_ICMNDES > 0 
                                   THEN 1
                                   ELSE 0
                                END
                           ELSE 0
                       END                        FT_TGRETAN,
                       CASE 
                           WHEN %Exp:cSubStrBD% = '60' AND SFT.FT_ICMSRET = 0 
                           THEN SFT.FT_BASNDES
                           ELSE SFT.FT_BASERET
                       END                        FT_BCST,
                       CASE 
                           WHEN %Exp:cSubStrBD% = '60' AND SFT.FT_ICMSRET = 0 
                           THEN SFT.FT_ALQNDES
                           ELSE SFT.FT_ALIQSOL
                       END                        FT_ALQST,
                       CASE 
                           WHEN %Exp:cSubStrBD% = '60' AND SFT.FT_ICMSRET = 0 
                           THEN SFT.FT_ICMNDES
                           ELSE SFT.FT_ICMSRET
                       END                        FT_VLRST,
                       SFT.FT_VALANTI             FT_VALANTI,
                       SFT.FT_PDV                 FT_PDV,
                       ISNULL(SFI.FI_SERPDV,'')   FI_SERPDV,
                       ISNULL(SFI.FI_COO,'')      FI_COO,
                       SFT.FT_NFORI               FT_NFORI,
                       SFT.FT_SERORI              FT_SERORI,
                       SFT.FT_ITEMORI             FT_ITEMORI,
                       CASE
                           WHEN SFT.FT_TIPO = 'D'
                           THEN
                               CASE
                                   WHEN SFT.FT_TIPOMOV = 'E'
                                   THEN SF22.F2_EMISSAO
                                   ELSE SF1.F1_DTDIGIT
                               END
                           ELSE ''
                       END                        FT_EMISORI,
                       SFT.FT_FORMUL              FT_FORMUL
                FROM  %table:SFT% SFT INNER JOIN      %table:SB1% SB1  ON (SB1.B1_FILIAL  = %xFilial:SB1% AND SB1.B1_COD     = SFT.FT_PRODUTO  AND SB1.%NotDel%)
                                      INNER JOIN      %table:F2W% F2W  ON (F2W.F2W_FILIAL = %xFilial:F2W% AND F2W.F2W_CFOP   = SFT.FT_CFOP     AND F2W.%NotDel%)
                                      INNER JOIN      %table:F3M% F3M  ON (F3M.F3M_FILIAL = %xFilial:F3M% AND F3M.F3M_IDF2W  = F2W.F2W_IDTAB   AND F3M.F3M_CSTICM = %Exp:cSubStrBD% AND F3M.%NotDel%)
                                      LEFT OUTER JOIN %table:SA1% SA1  ON (SA1.A1_FILIAL  = %xFilial:SA1% AND SA1.A1_COD     = SFT.FT_CLIEFOR  AND SA1.A1_LOJA   = SFT.FT_LOJA      AND ((SFT.FT_TIPOMOV='S' AND SFT.FT_TIPO NOT IN ('D','B')) OR (SFT.FT_TIPOMOV='E' AND SFT.FT_TIPO IN ('D','B')))  AND SA1.%NotDel%)
                                      LEFT OUTER JOIN %table:SA2% SA2  ON (SA2.A2_FILIAL  = %xFilial:SA2% AND SA2.A2_COD     = SFT.FT_CLIEFOR  AND SA2.A2_LOJA   = SFT.FT_LOJA      AND ((SFT.FT_TIPOMOV='E' AND SFT.FT_TIPO NOT IN ('D','B')) OR (SFT.FT_TIPOMOV='S' AND SFT.FT_TIPO IN ('D','B')))  AND SA2.%NotDel%)
                                      LEFT OUTER JOIN %table:SF2% SF21 ON (SF21.F2_FILIAL = %xFilial:SF2% AND SF21.F2_DOC    = SFT.FT_NFISCAL  AND SF21.F2_SERIE = SFT.FT_SERIE     AND SF21.F2_CLIENTE = SFT.FT_CLIEFOR AND SF21.F2_LOJA = SFT.FT_LOJA AND (SFT.FT_TIPOMOV='S' AND SFT.FT_TIPO NOT IN ('D','B')) AND SF21.%NotDel%)
                                      LEFT OUTER JOIN %table:SF2% SF22 ON (SF22.F2_FILIAL = %xFilial:SF2% AND SF22.F2_DOC    = SFT.FT_NFORI    AND SF22.F2_SERIE = SFT.FT_SERORI    AND SF22.F2_CLIENTE = SFT.FT_CLIEFOR AND SF22.F2_LOJA = SFT.FT_LOJA AND (SFT.FT_TIPOMOV='E' AND SFT.FT_TIPO='D')              AND SF22.%NotDel%)
                                      LEFT OUTER JOIN %table:SF1% SF1  ON (SF1.F1_FILIAL  = %xFilial:SF1% AND SF1.F1_DOC     = SFT.FT_NFORI    AND SF1.F1_SERIE  = SFT.FT_SERORI    AND SF1.F1_FORNECE  = SFT.FT_CLIEFOR AND SF1.F1_LOJA  = SFT.FT_LOJA AND (SFT.FT_TIPOMOV='S' AND SFT.FT_TIPO='D')              AND  SF1.%NotDel%)
                                      LEFT OUTER JOIN %table:SFI% SFI  ON (SFI.FI_FILIAL  = %xFilial:SFI% AND SFI.FI_DTMOVTO = SFT.FT_EMISSAO  AND SFI.FI_PDV    = SFT.FT_PDV       AND SFI.%NotDel%)
                                      LEFT OUTER JOIN %table:SD1% SD1  ON (SD1.D1_FILIAL  = %xFilial:SD1% AND SD1.D1_DOC     = SFT.FT_NFISCAL  AND SD1.D1_SERIE  = SFT.FT_SERIE     AND SD1.D1_FORNECE  = SFT.FT_CLIEFOR AND SD1.D1_LOJA  = SFT.FT_LOJA AND SD1.D1_COD = SFT.FT_PRODUTO AND SD1.D1_ITEM = SFT.FT_ITEM AND SFT.FT_TIPOMOV = 'E' AND SD1.%NotDel%)
				                      LEFT OUTER JOIN %table:SD2% SD2  ON (SD2.D2_FILIAL  = %xFilial:SD2% AND SD2.D2_DOC     = SFT.FT_NFISCAL  AND SD2.D2_SERIE  = SFT.FT_SERIE     AND SD2.D2_CLIENTE  = SFT.FT_CLIEFOR AND SD2.D2_LOJA  = SFT.FT_LOJA AND SD2.D2_COD = SFT.FT_PRODUTO AND SD2.D2_ITEM = SFT.FT_ITEM AND SFT.FT_TIPOMOV = 'S' AND SD2.%NotDel%)
                                    %Exp:cF2QRelac%
                                      LEFT OUTER JOIN (SELECT SFTS1.FT_FILIAL, 
                                                              SFTS1.FT_PRODUTO, 
                                                              SUM(CASE WHEN SFTS1.FT_ENTRADA <= %Exp:dDataAtePA%
                                                                     THEN CASE SFTS1.FT_TIPO WHEN 'D' THEN SFTS1.FT_QUANT*(-1) ELSE SFTS1.FT_QUANT END 
                                                                     ELSE 0 
                                                                  END) FT_QUANTPA,
                                                              SUM(CASE WHEN SFTS1.FT_ENTRADA BETWEEN %Exp:dDataDeP1% AND %Exp:dDataAtePA%
                                                                       THEN CASE SFTS1.FT_TIPO WHEN 'D' THEN SFTS1.FT_QUANT*(-1) ELSE SFTS1.FT_QUANT END 
                                                                       ELSE 0 
                                                                  END) FT_QUANTP1,
                                                              SUM(CASE WHEN SFTS1.FT_ENTRADA BETWEEN %Exp:dDataDeP2% AND %Exp:dDataAtePA%
                                                                       THEN CASE SFTS1.FT_TIPO WHEN 'D' THEN SFTS1.FT_QUANT*(-1) ELSE SFTS1.FT_QUANT END 
                                                                       ELSE 0 
                                                                  END) FT_QUANTP2,
                                                              SUM(CASE WHEN SFTS1.FT_ENTRADA BETWEEN %Exp:dDataDeP3% AND %Exp:dDataAtePA%
                                                                       THEN CASE SFTS1.FT_TIPO WHEN 'D' THEN SFTS1.FT_QUANT*(-1) ELSE SFTS1.FT_QUANT END 
                                                                       ELSE 0 
                                                                  END) FT_QUANTP3,
                                                              SUM(CASE WHEN SFTS1.FT_ENTRADA BETWEEN %Exp:dDataDeP4% AND %Exp:dDataAtePA%
                                                                       THEN CASE SFTS1.FT_TIPO WHEN 'D' THEN SFTS1.FT_QUANT*(-1) ELSE SFTS1.FT_QUANT END 
                                                                       ELSE 0 
                                                                  END) FT_QUANTP4,
                                                              SUM(CASE WHEN SFTS1.FT_ENTRADA BETWEEN %Exp:dDataDeP5% AND %Exp:dDataAtePA%
                                                                       THEN CASE SFTS1.FT_TIPO WHEN 'D' THEN SFTS1.FT_QUANT*(-1) ELSE SFTS1.FT_QUANT END 
                                                                       ELSE 0 
                                                                  END) FT_QUANTP5,
                                                              SUM(CASE WHEN SFTS1.FT_ENTRADA BETWEEN %Exp:dDataDeP6% AND %Exp:dDataAtePA%
                                                                       THEN CASE SFTS1.FT_TIPO WHEN 'D' THEN SFTS1.FT_QUANT*(-1) ELSE SFTS1.FT_QUANT END 
                                                                       ELSE 0 
                                                                  END) FT_QUANTP6,
                                                              SUM(CASE WHEN SFTS1.FT_ENTRADA BETWEEN %Exp:dDataDeP7% AND %Exp:dDataAtePA%
                                                                       THEN CASE SFTS1.FT_TIPO WHEN 'D' THEN SFTS1.FT_QUANT*(-1) ELSE SFTS1.FT_QUANT END 
                                                                       ELSE 0 
                                                                  END) FT_QUANTP7,
                                                              SUM(CASE WHEN SFTS1.FT_ENTRADA BETWEEN %Exp:dDataDeP8% AND %Exp:dDataAtePA%
                                                                       THEN CASE SFTS1.FT_TIPO WHEN 'D' THEN SFTS1.FT_QUANT*(-1) ELSE SFTS1.FT_QUANT END 
                                                                       ELSE 0 
                                                                  END) FT_QUANTP8,
                                                              SUM(CASE WHEN SFTS1.FT_ENTRADA BETWEEN %Exp:dDataDeP9% AND %Exp:dDataAtePA%
                                                                       THEN CASE SFTS1.FT_TIPO WHEN 'D' THEN SFTS1.FT_QUANT*(-1) ELSE SFTS1.FT_QUANT END 
                                                                       ELSE 0 
                                                                  END) FT_QUANTP9,
                                                              SUM(CASE WHEN SFTS1.FT_ENTRADA BETWEEN %Exp:dDataDeP10% AND %Exp:dDataAtePA%
                                                                       THEN CASE SFTS1.FT_TIPO WHEN 'D' THEN SFTS1.FT_QUANT*(-1) ELSE SFTS1.FT_QUANT END 
                                                                       ELSE 0 
                                                                  END) FT_QUANTP10,
                                                              SUM(CASE WHEN SFTS1.FT_ENTRADA BETWEEN %Exp:dDataDeP11% AND %Exp:dDataAtePA%
                                                                       THEN CASE SFTS1.FT_TIPO WHEN 'D' THEN SFTS1.FT_QUANT*(-1) ELSE SFTS1.FT_QUANT END 
                                                                       ELSE 0 
                                                                  END) FT_QUANTP11,
                                                              SUM(CASE WHEN SFTS1.FT_ENTRADA BETWEEN %Exp:dDataDeP12% AND %Exp:dDataAtePA%
                                                                       THEN CASE SFTS1.FT_TIPO WHEN 'D' THEN SFTS1.FT_QUANT*(-1) ELSE SFTS1.FT_QUANT END 
                                                                       ELSE 0 
                                                                  END) FT_QUANTP12,
                                                              MIN(SFTS1.FT_ENTRADA) FT_PERINI,
                                                              MAX(CASE WHEN SFTS1.FT_TIPOMOV = 'E' AND SFTS1.FT_TIPO NOT IN ('D','B','S','P','I','C') AND SFTS1.FT_NFORI = ' ' AND SFTS1.FT_SERORI = ' ' AND  SFTS1.FT_ITEMORI = ' '
                                                                       THEN SFTS1.FT_ENTRADA || SD1S1.D1_NUMSEQ || SFTS1.FT_FILIAL || SFTS1.FT_TIPOMOV || SFTS1.FT_SERIE || SFTS1.FT_NFISCAL || SFTS1.FT_CLIEFOR || SFTS1.FT_LOJA || SFTS1.FT_ITEM || SFTS1.FT_PRODUTO
                                                                       ELSE ''
                                                              END) FT_STRID
                                                       FROM  %table:SFT% SFTS1      INNER JOIN  %table:F2W% F2WS1 ON (F2WS1.F2W_FILIAL = %xFilial:F2W% AND F2WS1.F2W_CFOP  = SFTS1.FT_CFOP AND F2WS1.%NotDel%) 
                                                                                    INNER JOIN  %table:F3M% F3MS1 ON (F3MS1.F3M_FILIAL = %xFilial:F3M% AND F3MS1.F3M_IDF2W = F2WS1.F2W_IDTAB  AND F3MS1.F3M_CSTICM = %Exp:cSubStrBD1% AND F3MS1.%NotDel%) 
                                                                               LEFT OUTER JOIN  %table:SF1% SF1S1 ON (SF1S1.F1_FILIAL  = %xFilial:SF1% AND SF1S1.F1_DOC    = SFTS1.FT_NFORI   AND SF1S1.F1_SERIE   = SFTS1.FT_SERORI  AND SF1S1.F1_FORNECE = SFTS1.FT_CLIEFOR AND SF1S1.F1_LOJA = SFTS1.FT_LOJA AND (SFTS1.FT_TIPOMOV='S' AND SFTS1.FT_TIPO='D') AND SF1S1.%NotDel%) 
                                                                               LEFT OUTER JOIN  %table:SD1% SD1S1 ON (SD1S1.D1_FILIAL  = %xFilial:SD1% AND SD1S1.D1_DOC    = SFTS1.FT_NFISCAL AND SD1S1.D1_SERIE   = SFTS1.FT_SERIE   AND SD1S1.D1_FORNECE = SFTS1.FT_CLIEFOR AND SD1S1.D1_LOJA = SFTS1.FT_LOJA AND SD1S1.D1_COD = SFTS1.FT_PRODUTO AND SD1S1.D1_ITEM = SFTS1.FT_ITEM AND SFTS1.FT_TIPOMOV = 'E' AND SD1S1.%NotDel%)
                                                       WHERE SFTS1.FT_FILIAL   = %xFilial:SFT%   AND 
                                                           ((SFTS1.FT_TIPOMOV  = 'E' AND SFTS1.FT_TIPO <> 'D') OR (SFTS1.FT_TIPOMOV  = 'S' AND SFTS1.FT_TIPO  = 'D' AND %Exp:cSubStrBD3% = %Exp:cSubStrBD2%)) AND    
                                                             SFTS1.FT_TIPO    <> 'S'             AND   
                                                             SFTS1.FT_ENTRADA <=  %Exp:dDataAte% AND 
                                                             SFTS1.FT_DTCANC   = ''              AND 
                                                             SFTS1.FT_QUANT    > 0               AND 
                                                             SFTS1.%NOTDEL%
                                                       GROUP BY SFTS1.FT_FILIAL, SFTS1.FT_PRODUTO) SFT_ ON (SFT_.FT_FILIAL = SFT.FT_FILIAL AND SFT_.FT_PRODUTO = SFT.FT_PRODUTO)
                                      LEFT OUTER JOIN %table:SFT% SFT2 ON (SFT2.FT_FILIAL = %Exp:cSFTStrId0% AND SFT2.FT_TIPOMOV = %Exp:cSFTStrId1% AND SFT2.FT_SERIE = %Exp:cSFTStrId2% AND SFT2.FT_NFISCAL = %Exp:cSFTStrId3% AND SFT2.FT_CLIEFOR = %Exp:cSFTStrId4% AND SFT2.FT_LOJA = %Exp:cSFTStrId5% AND SFT2.FT_ITEM = %Exp:cSFTStrId6% AND SFT2.FT_PRODUTO = %Exp:cSFTStrId7% AND SFT2.%NOTDEL%)
                                      LEFT OUTER JOIN %table:CD2% CD2  ON (CD2.CD2_FILIAL = %xFilial:CD2% AND CD2.CD2_TPMOV = SFT2.FT_TIPOMOV AND CD2.CD2_SERIE = SFT2.FT_SERIE AND CD2.CD2_DOC = SFT2.FT_NFISCAL AND CD2.CD2_CODCLI = '' AND CD2.CD2_LOJCLI = '' AND CD2.CD2_CODFOR = SFT2.FT_CLIEFOR AND CD2.CD2_LOJFOR = SFT2.FT_LOJA AND CD2.CD2_ITEM = SFT2.FT_ITEM AND CD2.CD2_CODPRO = SFT2.FT_PRODUTO AND CD2.CD2_IMP = 'SOL' AND (SFT2.FT_TIPOMOV='E' AND SFT2.FT_TIPO NOT IN ('D','B')) AND CD2.%NotDel%) 
                WHERE SFT.FT_FILIAL = %xFilial:SFT%      AND
                    SFT.FT_ENTRADA >= %Exp:dDataDe%      AND
                    SFT.FT_ENTRADA <= %Exp:dDataAte%     AND
                    SFT.FT_TIPO NOT IN ('S','P','I','C') AND
                    SFT.FT_DTCANC   = ''                 AND
                    SFT.FT_QUANT    > 0                  AND
                    SFT.%NOTDEL%                         AND
                    SB1.B1_CRICMST  = '1'
                ORDER BY SFT.FT_PRODUTO, FT_DATAMOV, FT_ORDEM, FT_CLIEFOR, FT_LOJA, FT_NFISCAL, FT_ITEM, FT_SERIE
            EndSql

            Begin Transaction

                //---Grava registro cabeçalho da apuração (Tabela F1I)---//
                GravaF1I(oApuracao,1)

                AtualizaMsg(oSay,STR0006) //---Processando movimento...---//

                //---Verifica início de vigência dos registros 2115 e 2133---//
                lReg2115 := oApuracao:GetReg2115()
                lReg2133 := oApuracao:GetReg2133()

                DbSelectArea(cAlias)
                (cAlias)->(DbGoTop())
                While !(cAlias)->(Eof())

                    If cProduto != (cAlias)->FT_PRODUTO

                        If !Empty(cProduto)

                            //---Qtdade em estoque para o produto ao final do perído---//
                            nQtdEstPrd := 0
                            If !lAutomato
                                (cAliBLH)->(DbSetOrder(1)) //---FILIAL+COD_ITEM+IND_PROP+COD_PART---//
                                (cAliBLH)->(DbSeek(xFilial("SB2")+cProduto+'0')) //--- IND_PROP: 0-Item de propriedade do informante e em seu poder / 1-Item de propriedade do informante em posse de terceiros / 2- Item de propriedade de terceiros em posse do informante ---//
                                While !(cAliBLH)->(Eof()) .And. (cAliBLH)->COD_ITEM == cProduto .And. (cAliBLH)->IND_PROP == '0'
                                    nQtdEstPrd += (cAliBLH)->QTD
                                    (cAliBLH)->(DbSkip())
                                EndDo
                            EndIf

                            //---Método ApuraProd: Calcula totais do produto nos objetos o2120 e o2110 e alimenta o objeto o2100---//
                            oApuracao:ApuraProd(nQtdEstPrd,nQtdPerAnt,aQtdPerAnt,nEntPerAnt)

                            //---Grava os totais calculados para o produto (Tabelas F1J / F1K / F1L)---//
                            GravaF1JKL(oApuracao)

                            //---Método ClearProd: Limpa os valores dos objetos o2110 / o2112 / o2120 a cada produto processado---//
                            oApuracao:ClearProd()

                        EndIf

                        //---Define a alíquota interna do ICMS para o produto---//
                        //---A Portaria define que o [Registro 0200 / Campo 12] deve conter a alíquota aplicável ao item nas operações internas OU a alíquota efetiva caso a MERCADORIA seja contemplada com REDUÇÃO DA BASE DE CÁLCULO---//
                        //---Já o registro [2130 (Entradas) / Campo 21 (ALIQ_ST_EF)], deve levar o mesmo valor do [Registro 0200 / Campo 12] (único para cada produto)---//
                        //---Como a relação é de N registros 2130 para um único 0200, entende-se que a alíquota efetiva (quando houver redução de base de cálculo) deverá ser a mesma em todas as operações, e por esse motivo ela será definida com base na última operação de entrada---//
                        //---Caso não seja possível o método acima, ela será definida conforme SPED Fiscal---//
                        aAliqEfet := FISA231ALQ((cAlias)->UE_PREDBC, (cAlias)->UE_BCST, (cAlias)->UE_ALQST) 
                        If Len(aAliqEfet) == 2 .And. aAliqEfet[1] > 0
                            nAliqInt  := aAliqEfet[1]
                        Else
                            nAliqInt := Iif((cAlias)->B1_PICM>0, (cAlias)->B1_PICM, nMVICMPAD)
                        EndIf

                    EndIf

                    //---Define Base de Cálculo, Alíquota e Valor do ICMS-ST, além do responsável pela retenção do ICMS-ST (1 – Remetente Direto / 2 – Remetente Indireto / 3 – Próprio declarante )---//
                    cRespRet   := (cAlias)->FT_RESPRET
                    nVlrBICMST := (cAlias)->FT_BCST
                    nVlrAICMST := (cAlias)->FT_ALQST
                    nVlrICMSST := (cAlias)->FT_VLRST
                    lTagRetAnt := Iif((cAlias)->FT_TGRETAN == 1, .T., .F.)

                    //---Valores apurados para o Documento Fiscal Original, em casos de movimentos de devolução---//
                    aDocOriApu := aSize(aDocOriApu,0)
                    If (cAlias)->FT_TIPO == 'D'
                        aDocOriApu := PesqApur((cAlias)->FT_TIPOMOV, (cAlias)->FT_NFORI, (cAlias)->FT_SERORI, (cAlias)->FT_ITEMORI, (cAlias)->FT_CLIEFOR, (cAlias)->FT_LOJA, (cAlias)->FT_PRODUTO, cPerApur)
                    EndIf

                    //---Entrada da mercadoria em casos onde o responsável pela retenção do ICMS-ST seja 3–Próprio declarante (ICMS Antecipado) é necessário definir:                 ---//
                    //---Código de lançamento de débito na EFD / Código do modelo do documento de arrecadação / Número do DARE - Guia para recolhimento de ICMS Antecipado na operação---//
                    cCodAju    := ''
                    cCodDA     := ''
                    cNumDare   := ''
                    If cRespRet == '3' .And. (cAlias)->FT_TIPOMOV == "E" .And. (cAlias)->FT_TIPO <> "D" .And. !Empty(cMvDrcCdAj)

                        //---Código de lançamento de débito---//
                        cCodAju := FISA231CDA(cAlias,cMvDrcCdAj)

                        If !Empty(cCodAju)

                            //---Verifica a existência de guia para recolhimento de ICMS Antecipado na operação---//
                            aNumDareOp := aSize(aNumDareOp,0)
                            aNumDareOp := FISA231GOP(cAlias, cCodAju)

                            If Len(aNumDareOp) == 2 .And. aNumDareOp[1]
                                cCodDA   := Iif(!Empty(aNumDareOp[2]), '0', '1')
                                cNumDare := aNumDareOp[2]
                            ElseIf Len(aNumDareAp) == 2 .And. aNumDareAp[1]
                                cCodDA   := Iif(!Empty(aNumDareAp[2]), '0', '1')
                                cNumDare := aNumDareAp[2]
                            EndIf

                        EndIf
                    EndIf

                    //---Execução P.E. FSA231UND: Utilização das quantidades e unidades informadas no Documento Fiscal, em casos em que a unidade do Documento Fiscal seja diferente da unidade do Registro 0200---//
                    nQtdade   := (cAlias)->FT_QUANT //---Quantidade presente no movimento na unidade de inventário (0200)---//
                    cUnid     := (cAlias)->B1_UM    //---Unidade de inventário (0200)---//
                    nFatorC   := 1
                    cFatorCTp := 'M'
                    If lFsa231Und
                        aFsa231Und := ExecBlock("FSA231UND", .F., .F., {cAlias})
					    If ValType(aFsa231Und) == "A" .And. Len(aFsa231Und) == 4 .And. ValType(aFsa231Und[1]) == 'C' .And. ValType(aFsa231Und[2]) == 'N' .And. ValType(aFsa231Und[3]) == 'N' .And. ValType(aFsa231Und[4]) == 'C'
                            nQtdade   := aFsa231Und[2]
                            cUnid     := aFsa231Und[1]
                        	nFatorC   := aFsa231Und[3]
                        	cFatorCTp := aFsa231Und[4]
                        Endif
                    EndIf

                    //---Retorna valores de documentos fiscais complementares ao documento posicionado na query principal de movimento---//
                    aVlrCmp := {0, 0, 0, 0, 0, 0, 0, 0, 0, .F. ,{} ,0}
                    If (lReg2115 .And. (cAlias)->FT_TIPOMOV == 'S') .Or. (lReg2133 .And. (cAlias)->FT_TIPOMOV == 'E')
                        aVlrCmp := FISA231CMP((cAlias)->FT_TIPOMOV, (cAlias)->FT_NFISCAL, (cAlias)->FT_SERIE, (cAlias)->FT_ITEM, (cAlias)->FT_CLIEFOR, (cAlias)->FT_LOJA, (cAlias)->FT_PRODUTO, (cAlias)->FT_DATAMOV)
                    EndIf

                    //---Método SetaMovim: Carrega os dados do movimento para que seja feita sua apuração---//
                    oApuracao:SetaMovim((cAlias)->FT_DATAMOV,;                                //---dDataMov   - Data do Movimento
                                        (cAlias)->FT_TIPOMOV,;                                //---cTipoMov   - Tipo do Movimento (E-Entrada / S-Saída)
                                        (cAlias)->FI_SERPDV,;                                 //---cNumSerECF - Número de Série de Fabricação do ECF
                                        (cAlias)->FT_TIPO,;                                   //---cTipoDoc   - Tipo do Documento (Normal / Devolução / Complemento)
                                        (cAlias)->FT_PRODUTO,;                                //---cCodProd   - Código do Produto
                                        (cAlias)->A1_TIPO,;                                   //---cTipoPart  - Tipo do Participante (Cliente Final / Revendedor)
                                        (cAlias)->FT_SIMPNAC,;                                //---cPartOptSN - Participante Optante pelo Simples Nacional (1-Sim / 2-Não)
                                        nAliqInt,;                                            //---nAliqInt   - Alíquota Interna do Produto
                                        (cAlias)->FT_CFOP,;                                   //---cCFOP      - CFOP
                                        Right((cAlias)->FT_CLASFIS,2),;                       //---cCST       - CST ICMS
                                        nQtdade + aVlrCmp[1],;                                //---nQtdade    - Quantidade informada no Documento Fiscal
                                        cUnid,;                                               //---cUnid      - Unidade informada no Documento Fiscal
                                        nFatorC,;                                             //---nFatorC    - Fator de Conversão da Quantidade informada no Documento Fiscal para a Unidade utilizada no Registro 0200
                                        cFatorCTp,;                                           //---cFatorCTp  - Tipo de Conversão: M-Multiplicação / D-Divisão
                                        (cAlias)->FT_VALCONT + aVlrCmp[3],;                   //---nVlrTotNf  - Valor Total da Nota Fiscal
                                        (cAlias)->FT_BASEICM + aVlrCmp[4],;                   //---nVlrBICMS  - Base de Cálculo do ICMS
                                        Iif(aVlrCmp[5]>0, aVlrCmp[5], (cAlias)->FT_ALIQICM),; //---nVlrAICMS  - Alíquota do ICMS
                                        (cAlias)->FT_VALICM + aVlrCmp[6],;                    //---nVlrICMS   - Valor do ICMS
                                        nVlrBICMST + aVlrCmp[7],;                             //---nVlrBICMST - Valor da Base de Cálculo do ICMS-ST
                                        Iif(aVlrCmp[8]>0, aVlrCmp[8], nVlrAICMST),;           //---nVlrAICMST - Alíquota do ICMS-ST
                                        nVlrICMSST + aVlrCmp[9],;                             //---nVlrICMSST - Valor do ICMS-ST
                                        cRespRet,;                                            //---cRespRet   - Responsável pela retenção do ICMS-ST (1 – Remetente Direto / 2 – Remetente Indireto / 3 – Próprio declarante )---//
                                        lTagRetAnt,;                                          //---lTagRetAnt - Indicador de preenchimento das TAGs "vBCSTRet" e "vICMSSTRet" do Grupo Tributação do ICMS = 60---//
                                        (cAlias)->F2Q_RESVSN,;                                //---cPrdResVSN - Indicador de cálculo de Ressarcimento em caso de saída interna para Optante pelo Simples Nacional (1–Sim / 2–Não)---//
                                        nPercRess,;                                           //---nPercRess  - Percentual de redução do MVA utilizado em saídas internas destinadas a empresa optante pelo Simples Nacional---//
                                        aDocOriApu,;                                          //---aDocOriApu - Valores apurados para o Documento Fiscal Original, em casos de movimentos de devolução
                                        cCodAju,;                                             //---cCodAju    - Código do Ajuste de débito informado no Registro C197 da EFD ICMS/IPI
                                        cCodDA,;                                              //---cCodDA     - Código do modelo do documento de arrecadação
                                        cNumDare)                                             //---cNumDare   - Número do DARE - Guia para recolhimento de ICMS Antecipado na operação

                    //---Método ApuraMovim: Para Entradas..: Alimenta objeto o2120                        ---//
                    //---                   Para Saídas....: Alimenta objeto o2112 / Alimenta objeto o2110---//
                    //---                   Carrega os valores apurados no objeto oMovimento              ---//
                    oApuracao:ApuraMovim(nEntPerAnt)

                    //---Grava o movimento apurado (Tabela F1M)---//
                    GravaF1M('1',cAlias,oApuracao,aVlrCmp)

                    cProduto       := (cAlias)->FT_PRODUTO
                    nQtdPerAnt     := (cAlias)->UE_QTDPA
                    aQtdPerAnt[1]  := {dDataDeP1,  (cAlias)->UE_QTDP1}
                    aQtdPerAnt[2]  := {dDataDeP2,  (cAlias)->UE_QTDP2}
                    aQtdPerAnt[3]  := {dDataDeP3,  (cAlias)->UE_QTDP3}
                    aQtdPerAnt[4]  := {dDataDeP4,  (cAlias)->UE_QTDP4}
                    aQtdPerAnt[5]  := {dDataDeP5,  (cAlias)->UE_QTDP5}
                    aQtdPerAnt[6]  := {dDataDeP6,  (cAlias)->UE_QTDP6}
                    aQtdPerAnt[7]  := {dDataDeP7,  (cAlias)->UE_QTDP7}
                    aQtdPerAnt[8]  := {dDataDeP8,  (cAlias)->UE_QTDP8}
                    aQtdPerAnt[9]  := {dDataDeP9,  (cAlias)->UE_QTDP9}
                    aQtdPerAnt[10] := {dDataDeP10, (cAlias)->UE_QTDP10}
                    aQtdPerAnt[11] := {dDataDeP11, (cAlias)->UE_QTDP11}
                    aQtdPerAnt[12] := {dDataDeP12, (cAlias)->UE_QTDP12}
                    aQtdPerAnt[13] := FirstDay((cAlias)->UE_PERINI)

                    (cAlias)->(DbSkip())
                EndDo
                (cAlias)->(DbCloseArea())
                //---FIM Query Principal---//

                AtualizaMsg(oSay,STR0007) //---Movimento processado. Concluindo apuração...---//

                If !Empty(cProduto)

                    //---Qtdade em estoque para o produto ao final do perído---//
                    nQtdEstPrd := 0
                    If !lAutomato
                        (cAliBLH)->(DbSetOrder(1)) //---FILIAL+COD_ITEM+IND_PROP+COD_PART---//
                        (cAliBLH)->(DbSeek(xFilial("SB2")+cProduto+'0')) //--- IND_PROP: 0-Item de propriedade do informante e em seu poder / 1-Item de propriedade do informante em posse de terceiros / 2- Item de propriedade de terceiros em posse do informante ---//
                        While !(cAliBLH)->(Eof()) .And. (cAliBLH)->COD_ITEM == cProduto .And. (cAliBLH)->IND_PROP == '0'
                            nQtdEstPrd += (cAliBLH)->QTD
                            (cAliBLH)->(DbSkip())
                        EndDo
                    EndIf

                    //---Método ApuraProd: Calcula totais do produto nos objetos o2120 e o2110 e alimenta o objeto o2100---//
                    oApuracao:ApuraProd(nQtdEstPrd,nQtdPerAnt,aQtdPerAnt,nEntPerAnt)

                    //---Grava os totais calculados para o produto (Tabelas F1J / F1K / F1L)---//
                    GravaF1JKL(oApuracao)

                    AtualizaMsg(oSay,STR0008) //---Totalizando apuração...---//

                    //---Método ApuraPer: Calcula totais da apuração no objeto o2100.---//
                    oApuracao:ApuraPer()

                EndIf

                //---Atualiza tabela CDA em casos de saídas interestaduais, para gravação do Valor do Crédito de ICMS Próprio---//
                FISA231CRD(cPerApur)

                AtualizaMsg(oSay,STR0009) //---Gravando apuração...---//

                //---Grava totalizadores da apuração (Tabela F1I)---//
                GravaF1I(oApuracao,2)

            End Transaction

            AtualizaMsg(oSay,STR0010) //---Processamento concluído.---//

            If !lAutomato
                (cAliBLH)->(DbCloseArea())
                Ferase(cAliBLH+GetDBExtension())
            EndIf

        Else
            MsgStop(STR0013) //---Fechamento de estoque e execução do Relatório de Registro de Inventário Modelo P7 não encontrados para o período apurado.---//
        EndIf
    EndIf

Return


//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} GravaF1JKL

Função que grava, nas tabelas F1J / F1K / F1L, os totais apurados para o produto.

@author Ulisses P. Oliveira
@since 06/04/2019
@version 1.0
/*/
//--------------------------------------------------------------------------------------------------
Static Function GravaF1JKL(oApuracao)
    Local lShow2120  := oApuracao:o2120:GetShw2120()
    Local lShow2121  := oApuracao:o2121:GetShw2121()
    Local aQtdUnidNf := oApuracao:o2112:GetQtdUnNf()
    Local nCount     := 0
    Local lF1L2121   := F1L->(FieldPos("F1L_QTDVLM")) > 0 .And. F1L->(FieldPos("F1L_CODREG")) > 0

    //---Tabela F1J - Apuração Produto - REGISTRO 2110---//
    RecLock('F1J',.T.)
    F1J->F1J_FILIAL := xFilial("F1J")
    F1J->F1J_IDAPUR := oApuracao:GetIdApur()
    F1J->F1J_ANOMES := oApuracao:GetAnoMes()
    F1J->F1J_PRODUT := oApuracao:o2110:GetCampo02()
    F1J->F1J_QTDVCF := oApuracao:o2110:GetCampo03()
    F1J->F1J_VLRVCF := oApuracao:o2110:GetCampo04()
    F1J->F1J_VMUVCF := oApuracao:o2110:GetCampo05()
    F1J->F1J_VBSTCF := oApuracao:o2110:GetCampo06()
    F1J->F1J_VMABST := oApuracao:o2110:GetCampo07()
    F1J->F1J_VMEBST := oApuracao:o2110:GetCampo08()
    F1J->F1J_ALIQEF := oApuracao:o2110:GetCampo09()
    F1J->F1J_VLREST := oApuracao:o2110:GetCampo10()
    F1J->F1J_VLCOMP := oApuracao:o2110:GetCampo11()
    F1J->F1J_QTDSOE := oApuracao:o2110:GetCampo12()
    F1J->F1J_VICMOE := oApuracao:o2110:GetCampo13()
    F1J->F1J_VISTOE := oApuracao:o2110:GetCampo14()
    F1J->F1J_QTDSSN := oApuracao:o2110:GetCampo15()
    F1J->F1J_VCRDSN := oApuracao:o2110:GetCampo16()
    F1J->(MsUnlock())

    //---Tabela F1K - Apuração Venda ECF - REGISTRO 2112---//
    For nCount := 1 To Len(aQtdUnidNf)
        RecLock('F1K',.T.)
        F1K->F1K_FILIAL := xFilial("F1K")
        F1K->F1K_IDAPUR := oApuracao:GetIdApur()
        F1K->F1K_ANOMES := oApuracao:GetAnoMes()
        F1K->F1K_PRODUT := oApuracao:o2110:GetCampo02()
        F1K->F1K_QTDVCF := aQtdUnidNf[nCount][01]
        F1K->F1K_UNID   := aQtdUnidNf[nCount][02]
        F1K->F1K_FATCON := aQtdUnidNf[nCount][03]
        F1K->F1K_QTVCFC := aQtdUnidNf[nCount][04]
        F1K->F1K_VLRVCF := aQtdUnidNf[nCount][05]
        F1K->(MsUnlock())
    Next nCount

    //---Tabela F1L - Apuração Entradas - REGISTRO 2120---//
    If lShow2120
        RecLock('F1L',.T.)
        F1L->F1L_FILIAL := xFilial("F1L")
        F1L->F1L_IDAPUR := oApuracao:GetIdApur()
        F1L->F1L_ANOMES := oApuracao:GetAnoMes()
        F1L->F1L_PRODUT := oApuracao:o2110:GetCampo02()
        F1L->F1L_QTDENT := oApuracao:o2120:GetCampo02()
        F1L->F1L_TOTBST := oApuracao:o2120:GetCampo03()
        F1L->F1L_VMUBST := oApuracao:o2120:GetCampo04()
        F1L->F1L_TOTICM := oApuracao:o2120:GetCampo05()
        F1L->F1L_VMUICM := oApuracao:o2120:GetCampo06()
        F1L->F1L_TOTIST := oApuracao:o2120:GetCampo07()
        F1L->F1L_VMUIST := oApuracao:o2120:GetCampo08()
        If lF1L2121
            F1L->F1L_CODREG  := '2120'
        EndIf
        F1L->(MsUnlock())
    EndIf

    If lShow2121 .And. lF1L2121
        RecLock('F1L',.T.)
        F1L->F1L_FILIAL := xFilial("F1L")
        F1L->F1L_IDAPUR := oApuracao:GetIdApur()
        F1L->F1L_ANOMES := oApuracao:GetAnoMes()
        F1L->F1L_PRODUT := oApuracao:o2110:GetCampo02()
        F1L->F1L_QTDENT := oApuracao:o2121:GetCampo02()
        F1L->F1L_TOTBST := oApuracao:o2121:GetCampo04()
        F1L->F1L_VMUBST := oApuracao:o2121:GetCampo05()
        F1L->F1L_QTDVLM := oApuracao:o2121:GetCampo03()
        F1L->F1L_CODREG := '2121'
        F1L->(MsUnlock())
    EndIf

Return


//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} GravaF1M

Função que insere, na tabela F1M, os dados do movimento apurado.
É chamada em duas situações (parâmetro cTipo):

1-De dentro do laço da query de movimento (informando o parâmetro oApuracao)
2-No método ApuraProd(), quando for necessária a adição de entradas de períodos anteriores (informando o parâmetro aMovEntr)

@author Ulisses P. Oliveira
@since 03/04/2019
@version 1.0
/*/
//--------------------------------------------------------------------------------------------------
Static Function GravaF1M(cTipo,cAlias,oApuracao,aVlrCmp)
    Local lF1MTagRet := F1M->(FieldPos("F1M_TAGRET")) > 0
    Local lF1MNfComp := F1M->(FieldPos("F1M_NFCOMP")) > 0
    Local lF1MVlrTot := F1M->(FieldPos("F1M_VLRTOT")) > 0

    If oApuracao:oMovimento:GetGrvMov()
        RecLock('F1M',.T.)
        F1M->F1M_FILIAL := xFilial("F1M")
        F1M->F1M_IDAPUR := oApuracao:GetIdApur()
        F1M->F1M_ANOMES := oApuracao:GetAnoMes()

        //---Dados do Movimento---//
        F1M->F1M_PRODUT := (cAlias)->FT_PRODUTO
        F1M->F1M_ORDEM  := StrZero(oApuracao:oMovimento:GetOrdMov(),9)
        F1M->F1M_DTMOV  := (cAlias)->FT_DATAMOV
        F1M->F1M_TPMOV  := (cAlias)->FT_TIPOMOV
        F1M->F1M_INDOP  := Iif((cAlias)->FT_TIPO == 'D','1','0')
        F1M->F1M_NFISCA := (cAlias)->FT_NFISCAL
        F1M->F1M_SERIE  := (cAlias)->FT_SERIE
        F1M->F1M_ITEM   := (cAlias)->FT_ITEM
        F1M->F1M_CFOP   := (cAlias)->FT_CFOP
        F1M->F1M_ESPECI := (cAlias)->FT_ESPECIE
        F1M->F1M_CHVDOC := (cAlias)->FT_CHVNFE
        F1M->F1M_NUMPDV :=  Iif(cTipo = '1', (cAlias)->FT_PDV, '')
        F1M->F1M_SERECF :=  Iif(cTipo = '1', (cAlias)->FI_SERPDV, '')
        F1M->F1M_COO    :=  ''
        F1M->F1M_PARTIC := (cAlias)->FT_CLIEFOR
        F1M->F1M_LOJA   := (cAlias)->FT_LOJA
        F1M->F1M_CNPJ   := (cAlias)->FT_CNPJCPF
        F1M->F1M_QTDMOV := oApuracao:oMovimento:GetQtdade()
        F1M->F1M_UNIDAD := oApuracao:oMovimento:GetUnid()
        F1M->F1M_FATCON := oApuracao:oMovimento:GetFatorC()
        F1M->F1M_QTDCON := oApuracao:oMovimento:GetQtdadeC()
        F1M->F1M_VLRCON := Iif(((cAlias)->FT_TIPOMOV == 'S' .And. (cAlias)->FT_TIPO != 'D') .Or. ((cAlias)->FT_TIPOMOV == 'E' .And. (cAlias)->FT_TIPO == 'D'), (cAlias)->FT_VALCONT + aVlrCmp[3], (cAlias)->(FT_TOTAL+FT_FRETE+FT_SEGURO+FT_DESPESA) + aVlrCmp[2])
        If lF1MVlrTot
            F1M->F1M_VLRTOT := (cAlias)->FT_TOTAL + aVlrCmp[12]
        EndIf    
        F1M->F1M_BASICM := oApuracao:oMovimento:GetBICMS()
        F1M->F1M_ALQICM := oApuracao:oMovimento:GetAICMS()
        F1M->F1M_VLRICM := oApuracao:oMovimento:GetVICMS()
        F1M->F1M_BASIST := oApuracao:oMovimento:GetBICMST()
        F1M->F1M_ALQIST := oApuracao:oMovimento:GetAICMST()
        F1M->F1M_VLRIST := oApuracao:oMovimento:GetVICMSST()
        F1M->F1M_BCEFST	:= oApuracao:oMovimento:GetBINTST()
        F1M->F1M_ALQEST := oApuracao:oMovimento:GetAEFEST()
        F1M->F1M_CALCST := oApuracao:oMovimento:GetCALCST()
        F1M->F1M_CODAJU := oApuracao:oMovimento:GetCodAju()
        F1M->F1M_CODDA  := oApuracao:oMovimento:GetCodDA()
        F1M->F1M_NMDARE := oApuracao:oMovimento:GetNumDare()
        F1M->F1M_CODRES := oApuracao:oMovimento:GetRespRet()
        If lF1MTagRet
            If oApuracao:GetReg2134() .And. oApuracao:oMovimento:GetTagAnt()
                F1M->F1M_TAGRET := 'S'
            ElseIf oApuracao:GetReg2134() .And. !oApuracao:oMovimento:GetTagAnt() .And. oApuracao:oMovimento:GetRespRet() == '2'
                F1M->F1M_TAGRET := 'N'
            Else
                F1M->F1M_TAGRET := ''
            EndIf
        EndIf
        If lF1MNfComp .And. aVlrCmp[10]
            F1M->F1M_NFCOMP := 'S'
        EndIf

        //---Valores apurados para o movimento---//
        F1M->F1M_INDSAI := oApuracao:oMovimento:GetTpOper()
        F1M->F1M_VCRDSN := oApuracao:oMovimento:GetCredSSN()

        F1M->(MsUnlock())
    EndIf

Return

/*/{Protheus.doc} 

Acessar a função GravaF1M para ser utilizada no FISA230A evitando uso de staticcall
@author Bruce Mello
@since 20/03/2023
@version 1.0
/*/
//--------------------------------------------------------------------------------------------------
Function AcessoF1M (cTipo,cAlias,oApuracao,aVlrCmp)
return   GravaF1M(cTipo,cAlias,oApuracao,aVlrCmp)


/*/{Protheus.doc} GravaF1I

Função que grava, na tabelas F1I , os totalizadores da apuração.

@author Ulisses P. Oliveira
@since 27/03/2019
@version 1.0
/*/
//--------------------------------------------------------------------------------------------------
Static Function GravaF1I(oApuracao,cTipoGrv)
    Local lF1I_ORIG := F1I->(FieldPos("F1I_ORIGEM")) > 0

    If cTipoGrv = 1     //--- Parâmetro cTipoGrv = 1 -> Chamada no início do processamento. Insere registro na tabala F1I ---//
        RecLock('F1I',.T.)
        F1I->F1I_FILIAL := xFilial("F1I")
        F1I->F1I_IDAPUR := oApuracao:GetIdApur()
        F1I->F1I_ANOMES := oApuracao:GetAnoMes()
        If lF1I_ORIG
            F1I->F1I_ORIGEM := 'FISA230'
        EndIf
        F1I->(MsUnlock())
    ElseIf cTipoGrv = 2 //--- Parâmetro cTipoGrv = 2 -> Chamada ao fim do processamento. Atualiza totais da tabela F1I ---//
        F1I->(DbSetOrder(2))
        If F1I->(DbSeek(xFilial("F1I")+oApuracao:GetIdApur()))
            RecLock('F1I',.F.)
            F1I->F1I_VLREST := oApuracao:o2100:GetCampo02()
            F1I->F1I_VLCOMP := oApuracao:o2100:GetCampo03()
            F1I->F1I_SDREST := oApuracao:o2100:GetCampo04()
            F1I->F1I_SDRESS := oApuracao:o2100:GetCampo05()
            F1I->F1I_SDCOMP := oApuracao:o2100:GetCampo06()
            F1I->F1I_SDICOP := oApuracao:o2100:GetCampo07()
            F1I->F1I_VLACRE := oApuracao:o2100:GetCampo08()
            F1I->F1I_VLACOM := oApuracao:o2100:GetCampo09()
            MsUnLock()
        EndIf
    EndIf

Return


//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} CheckApur

Função que verifica a existência de apuração no período selecionado.

@author Ulisses P. Oliveira
@since 27/03/2019
@version 1.0
/*/
//--------------------------------------------------------------------------------------------------
Static Function CheckApur(cPerApur)
    Local cIdApur := ''

    F1I->(DbSetOrder(1))
    If F1I->(DbSeek(xFilial("F1I")+cPerApur))
        cIdApur := F1I->F1I_IDAPUR
    EndIf

Return cIdApur

/*/{Protheus.doc} 

Acessar a função CheckApur para ser utilizada no FISA234 evitando uso de staticcall
@author Bruce Mello
@since 20/03/2023
@version 1.0.
/*/
//--------------------------------------------------------------------------------------------------
Function ConfeApur (cPerApur)
return   CheckApur(cPerApur)



/*/{Protheus.doc} DeletApur

Função de exclusão da apuração.

@author Ulisses P. Oliveira
@since 27/03/2019
@version 1.0
/*/
//--------------------------------------------------------------------------------------------------
Static Function DeletApur(cIdApur,cPerApur)
    Local cQuery    := ''
    Local lF1Z      := AliasIndic("F1Z")
    Local lF1I_ORIG := F1I->(FieldPos("F1I_ORIGEM")) > 0
    Local lExclui := .T.

    //---Tabela F1I [Apuração]---//
    F1I->(DbSetOrder(2))
    If F1I->(DbSeek(xFilial("F1I")+cIdApur))
        If !lF1I_ORIG .Or. (lF1I_ORIG .And. (AllTrim(F1I->F1I_ORIGEM) == 'FISA230' .Or. Empty(F1I->F1I_ORIGEM)))
            RecLock('F1I',.F.)
                F1I->(DbDelete())
            MsUnLock()
        Else
            lExclui := .F.
        EndIf
    EndIf

    If lExclui

        //---Tabela F1J [Apuração Produto]---//
        cQuery := "DELETE FROM " +  RetSqlName('F1J')  + " WHERE F1J_FILIAL = " + ValToSql(xFilial('F1J')) + " AND F1J_IDAPUR = " + ValToSql(cIdApur)
        If !Empty(AllTrim(cQuery))
            TcSqlExec(cQuery)
        EndIf

        //---Tabela F1Z [Apur Prd. x Ind. Saida]---//
        If lF1Z
            cQuery := "DELETE FROM " +  RetSqlName('F1Z')  + " WHERE F1Z_FILIAL = " + ValToSql(xFilial('F1Z')) + " AND F1Z_IDAPUR = " + ValToSql(cIdApur)
            If !Empty(AllTrim(cQuery))
                TcSqlExec(cQuery)
            EndIf
        EndIf

        //---Tabela F1K [Apuração Venda ECF]---//
        cQuery := "DELETE FROM " +  RetSqlName('F1K')  + " WHERE F1K_FILIAL = " + ValToSql(xFilial('F1K')) + " AND F1K_IDAPUR = " + ValToSql(cIdApur)
        If !Empty(AllTrim(cQuery))
            TcSqlExec(cQuery)
        EndIf

        //---Tabela F1L [Apuração Entradas]---//
        cQuery := "DELETE FROM " +  RetSqlName('F1L')  + " WHERE F1L_FILIAL = " + ValToSql(xFilial('F1L')) + " AND F1L_IDAPUR = " + ValToSql(cIdApur)
        If !Empty(AllTrim(cQuery))
            TcSqlExec(cQuery)
        EndIf

        //---Tabela F1M [Apuração Detalhada]---//
        cQuery := "DELETE FROM " +  RetSqlName('F1M')  + " WHERE F1M_FILIAL = " + ValToSql(xFilial('F1M')) + " AND F1M_IDAPUR = " + ValToSql(cIdApur)
        If !Empty(AllTrim(cQuery))
            TcSqlExec(cQuery)
        EndIf

    EndIf

Return lExclui


//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} PesqApur

Função que pesquisa, no movimento já apurado (tabela F1M), o movimento original, em casos de devoluções.
Retorna um vetor contendo os seguintes valores:

[1] - Data do movimento original
[2] - Quantidade do movimento original
[3] - Valor de Crédito Valor pela saída a optante pelo Simples Nacional calculado no movimento original
[4] - Valor da Base de Cálculo do ICMS Próprio do movimento original
[5] - Valor da Alíquota do ICMS Próprio do movimento original
[6] - Valor do ICMS Próprio do movimento original
[7] - Valor da Base de Cálculo do ICMS ST do movimento original
[8] - Valor Alíquota do ICMS ST do movimento original
[9] - Valor do ICMS ST do movimento original
[10]- Valor integral da Base de Cálculo do ICMS-ST quando se utilizar a alíquota efetiva aplicável na apuração do imposto devido
[11]- Alíquota do ICMS efetiva (percentual de carga tributária efetiva) da ST, aplicável à Base de Cálculo integral
[12]- Valor do ICMS-ST calculado pela multiplicação dos campos F1M_BASIST e F1M_ALQIST e dos campos F1M_BCEFST e F1M_ALQEST
[13]- CNPJ do movimento original
[14]- Chave do movimento original
[15]- Número do caixa atribuído ao ECF do movimento original
[16]- Número do documento fiscal do movimento original

@author Ulisses P. Oliveira
@since 17/04/2019
@version 1.0
/*/
//--------------------------------------------------------------------------------------------------
Static Function PesqApur(cTipoMov, cDocOri, cSerOri, cItemOri, cCliOri, cLojaOri, cProdOri, cPerApur)
    Local aArea    := GetArea()
    Local cAlias   := GetNextAlias()
    Local aRetorno := {CtoD('  /  /    '),0,0,0,0,0,0,0,0,0,0,0,'','','',''}

    cTipoMov := Iif(cTipoMov == 'E','S','E')

    //--Localiza saída original apurada na tabela F1M, para utilizar os valores informados anteriormente---//
    BeginSql Alias cAlias
        COLUMN F1M_DTMOV AS DATE

        SELECT F1M_DTMOV, F1M_QTDCON, F1M_VCRDSN, F1M_BASICM, F1M_ALQICM, F1M_VLRICM, F1M_BASIST, F1M_ALQIST, F1M_VLRIST, F1M_BCEFST, F1M_ALQEST, F1M_CALCST, F1M_CNPJ, F1M_CHVDOC, F1M_NUMPDV, F1M_NFISCA
        FROM %TABLE:F1M% F1M
        WHERE F1M_FILIAL = %XFILIAL:F1M%  AND
        	  F1M_TPMOV  = %EXP:cTipoMov% AND
        	  F1M_SERIE  = %EXP:cSerOri%  AND
        	  F1M_NFISCA = %EXP:cDocOri%  AND
        	  F1M_PARTIC = %EXP:cCliOri%  AND
        	  F1M_LOJA   = %EXP:cLojaOri% AND
        	  F1M_ITEM   = %EXP:cItemOri% AND
        	  F1M_PRODUT = %EXP:cProdOri% AND
              F1M_ANOMES = %EXP:cPerApur% AND
        	  F1M.%NOTDEL%
    EndSql

    DbSelectArea(cAlias)
    (cAlias)->(DbGoTop())
    If !(cAlias)->(Eof())
        aRetorno := {(cAlias)->F1M_DTMOV, (cAlias)->F1M_QTDCON, (cAlias)->F1M_VCRDSN, (cAlias)->F1M_BASICM, (cAlias)->F1M_ALQICM, (cAlias)->F1M_VLRICM, (cAlias)->F1M_BASIST, (cAlias)->F1M_ALQIST, (cAlias)->F1M_VLRIST, (cAlias)->F1M_BCEFST, (cAlias)->F1M_ALQEST, (cAlias)->F1M_CALCST, (cAlias)->F1M_CNPJ, (cAlias)->F1M_CHVDOC, (cAlias)->F1M_NUMPDV, (cAlias)->F1M_NFISCA}
    EndIf
    (cAlias)->(DbCloseArea())

    RestArea(aArea)
Return aRetorno

/*/{Protheus.doc} PesqApur

Acessar a função PesqApur para ser utilizada no FISA230A evitando uso de staticcall
@author Bruce Mello
@since 20/03/2023
@version 1.0
/*/
//--------------------------------------------------------------------------------------------------
Function Fisa231Ap (cTipoMov, cDocOri, cSerOri, cItemOri, cCliOri, cLojaOri, cProdOri, cPerApur)
return   PesqApur(cTipoMov, cDocOri, cSerOri, cItemOri, cCliOri, cLojaOri, cProdOri, cPerApur)
 

//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} AtualizaMsg

Função que será chamada para atualizar descrição da barra de status

@author Ulisses P. Oliveira
@since 27/03/2019
@version 12.1.17
/*/
//--------------------------------------------------------------------------------------------------
Static Function AtualizaMsg(oSay,cMsg)
    If !lAutomato
        oSay:cCaption := (cMsg)
        ProcessMessages()
    EndIf
Return


//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} FISA231EXC
Função de exclusão da apuração selecionada, a partir da rotina FISA193.

@author Ulisses P. Oliveira
@since 27/03/2019
@version 1.0

/*/
//--------------------------------------------------------------------------------------------------
Function FISA231EXC()
    FWExecView(STR0011,"FISA232",MODEL_OPERATION_DELETE,,{|| DeletApur(F1I->F1I_IDAPUR,F1I->F1I_ANOMES) },,,) //---Excluir---//
Return


//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} FISA231CMP

Função que retorna valores de documentos fiscais complementares dos documentos relacionados na query 
principal de movimento.

@author Ulisses P. Oliveira
@since 27/01/2020
@version 1.0

/*/
//--------------------------------------------------------------------------------------------------
Function FISA231CMP(cTipoMov, cDocOri, cSerOri, cItemOri, cCliOri, cLojaOri, cProdOri, dDtMovOri)
    Local aArea      := GetArea()
    Local cAlias     := GetNextAlias()
    Local nQtdadeMv  := 0
    Local lFsa231Und := ExistBlock("FSA231UND")
    Local aFsa231Und := {}
    Local dDataDe    := FirstDay(dDtMovOri)
    Local dDataAte   := LastDay(dDtMovOri)
    Local nQtdade    := 0
    Local nVlrPrdDes := 0
    Local nVlrCont   := 0
    Local nVlrBICMS  := 0
    Local nVlrAICMS  := 0
    Local nVlrICMS   := 0
    Local nVlrBICMST := 0
    Local nVlrAICMST := 0
    Local nVlrICMSST := 0
    Local lAchouCmp  := .F.
    Local aDocCmp    := {}
    Local nVlrTotal  := 0 
    Local cSGBD      := TCGetDB()
    Local cSubStrBD  := ''
    Local aRetorno   := {}

    //---Verifica se o documento original possui algum complemento. Caso não possua, não executa a query abaixo---//
    If cTipoMov == 'E'
        If SD1->(DbSeek(xFilial('SD1')+cDocOri+cSerOri+cCliOri+cLojaOri)) //---J D1_FILIAL+D1_NFORI+D1_SERIORI+D1_FORNECE+D1_LOJA---//
            lAchouCmp  := .T.
        EndIf
    Else
        If SD2->(DbSeek(xFilial('SD2')+cDocOri+cSerOri)) //---A D2_FILIAL+D2_NFORI+D2_SERIORI---//
            lAchouCmp  := .T.
        EndIf
    EndIf

    If lAchouCmp
        lAchouCmp  := .F.

        If cSGBD = 'ORACLE'
            cSubStrBD := 'SUBSTR(SFT.FT_CLASFIS,2,2)'
        Else
            cSubStrBD := 'RIGHT(SFT.FT_CLASFIS,2)'
        EndIf
        cSubStrBD := "%" + cSubStrBD + "%"

        //--Localiza documementos fiscais de complemento ao documento original passado via parâmetros---//
        BeginSql Alias cAlias
            COLUMN FT_EMISSAO AS DATE
            COLUMN FT_ENTRADA AS DATE
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
                   SFT.FT_NFISCAL             FT_NFISCAL,
                   SFT.FT_SERIE               FT_SERIE,
                   SFT.FT_ITEM                FT_ITEM,
                   SFT.FT_ESPECIE             FT_ESPECIE,
                   SFT.FT_CHVNFE              FT_CHVNFE,
                   SFT.FT_CLIEFOR             FT_CLIEFOR,
                   SFT.FT_LOJA                FT_LOJA,
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
                   SFT.FT_BASERET             FT_BASERET,
                   SFT.FT_ALIQSOL             FT_ALIQSOL,
                   SFT.FT_ICMSRET             FT_ICMSRET,
                   SFT.FT_BASNDES             FT_BASNDES,
                   SFT.FT_ALQNDES             FT_ALQNDES,
                   SFT.FT_ICMNDES             FT_ICMNDES,
                   CASE 
                       WHEN %Exp:cSubStrBD% = '60' AND SFT.FT_ICMSRET = 0 
                       THEN SFT.FT_BASNDES
                       ELSE SFT.FT_BASERET
                   END                        FT_BCST,
                   CASE 
                       WHEN %Exp:cSubStrBD% = '60' AND SFT.FT_ICMSRET = 0 
                       THEN SFT.FT_ALQNDES
                       ELSE SFT.FT_ALIQSOL
                   END                        FT_ALQST,
                   CASE 
                       WHEN %Exp:cSubStrBD% = '60' AND SFT.FT_ICMSRET = 0 
                       THEN SFT.FT_ICMNDES
                       ELSE SFT.FT_ICMSRET
                   END                        FT_VLRST,
                   SFT.FT_VALANTI             FT_VALANTI,
                   SFT.FT_NFORI               FT_NFORI, 
                   SFT.FT_SERORI              FT_SERORI, 
                   SFT.FT_ITEMORI             FT_ITEMORI
            FROM %TABLE:SFT% SFT INNER JOIN      %table:SB1% SB1 ON (SB1.B1_FILIAL  = %xFilial:SB1% AND SB1.B1_COD    = SFT.FT_PRODUTO AND SB1.%NotDel%)
	    			             LEFT OUTER JOIN %table:SD1% SD1 ON (SD1.D1_FILIAL  = %xFilial:SD1% AND SD1.D1_DOC    = SFT.FT_NFISCAL AND SD1.D1_SERIE   = SFT.FT_SERIE AND SD1.D1_FORNECE = SFT.FT_CLIEFOR AND SD1.D1_LOJA = SFT.FT_LOJA AND SD1.D1_COD = SFT.FT_PRODUTO AND SD1.D1_ITEM = SFT.FT_ITEM AND SFT.FT_TIPOMOV = 'E' AND SD1.%NotDel%)
	    			             LEFT OUTER JOIN %table:SD2% SD2 ON (SD2.D2_FILIAL  = %xFilial:SD2% AND SD2.D2_DOC    = SFT.FT_NFISCAL AND SD2.D2_SERIE   = SFT.FT_SERIE AND SD2.D2_CLIENTE = SFT.FT_CLIEFOR AND SD2.D2_LOJA = SFT.FT_LOJA AND SD2.D2_COD = SFT.FT_PRODUTO AND SD2.D2_ITEM = SFT.FT_ITEM AND SFT.FT_TIPOMOV = 'S' AND SD2.%NotDel%) 
            WHERE  SFT.FT_FILIAL  =  %XFILIAL:SFT%   AND
                   SFT.FT_TIPOMOV =  %EXP:cTipoMov%  AND
                   SFT.FT_CLIEFOR =  %EXP:cCliOri%   AND
            	   SFT.FT_LOJA    =  %EXP:cLojaOri%  AND
                   SFT.FT_PRODUTO =  %EXP:cProdOri%  AND
                   SFT.FT_ENTRADA >=  %EXP:dDataDe%  AND
                   SFT.FT_ENTRADA <=  %EXP:dDataAte% AND
                   SFT.FT_TIPO    IN ('P','I','C')   AND 
            	   SFT.FT_NFORI   =  %EXP:cDocOri%	 AND
            	   SFT.FT_SERORI  =  %EXP:cSerOri%	 AND
            	   SFT.FT_ITEMORI =  %EXP:cItemOri%  AND
                   SFT.FT_DTCANC   = ''		         AND
                   SFT.%NotDel%
        EndSql

        DbSelectArea(cAlias)
        (cAlias)->(DbGoTop())
        While !(cAlias)->(Eof())

            //---Execução P.E. FSA231UND: Utilização das quantidades e unidades informadas no Documento Fiscal, em casos em que a unidade do Documento Fiscal seja diferente da unidade do Registro 0200---//
            nQtdadeMv := (cAlias)->FT_QUANT //---Quantidade presente no movimento na unidade de inventário (0200)---//
            If lFsa231Und
                aFsa231Und := ExecBlock("FSA231UND", .F., .F., {cAlias})
	            If ValType(aFsa231Und) == "A" .And. Len(aFsa231Und) == 4 .And. ValType(aFsa231Und[1]) == 'C' .And. ValType(aFsa231Und[2]) == 'N' .And. ValType(aFsa231Und[3]) == 'N' .And. ValType(aFsa231Und[4]) == 'C'
                    nQtdadeMv := aFsa231Und[2]
                Endif
            EndIf

            nQtdade    += nQtdadeMv
            nVlrPrdDes += (cAlias)->(FT_TOTAL+FT_FRETE+FT_SEGURO+FT_DESPESA)
            nVlrCont   += (cAlias)->FT_VALCONT
            nVlrTotal  += (cAlias)->FT_TOTAL
            nVlrBICMS  += (cAlias)->FT_BASEICM
            nVlrAICMS  := Iif(nVlrAICMS==0, (cAlias)->FT_ALIQICM, nVlrAICMS)
            nVlrICMS   += (cAlias)->FT_VALICM 

            nVlrBICMST += (cAlias)->FT_BCST
            nVlrAICMST := Iif(nVlrAICMST==0, (cAlias)->FT_ALQST, nVlrAICMST)
            nVlrICMSST += (cAlias)->FT_VLRST

            lAchouCmp  := .T.
            Aadd(aDocCmp,{(cAlias)->FT_CHVNFE, (cAlias)->FT_ITEM})

            (cAlias)->(DbSkip())
        EndDo
        (cAlias)->(DbCloseArea())

    EndIf

    aRetorno := {nQtdade, nVlrPrdDes, nVlrCont, nVlrBICMS, nVlrAICMS, nVlrICMS, nVlrBICMST, nVlrAICMST, nVlrICMSST, lAchouCmp, aDocCmp, nVlrTotal}

    RestArea(aArea)
Return aRetorno


//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} FISA231CDA

Função que verifica, na tabela CDA:

cTipo = 1
Se para o item em questão (SFT) existe um lançamento que corresponda a algum dos códigos definidos no 
parâmetro MV_DRCCDAJ. Neste caso, o primeiro código que bater com o parametro será o retornado.

O retorno será usado na geração dos campos: 24 (COD_DA) / 25 (NUM_DARE) / 26 (COD_AJ) em entradas onde o 
código do responsável pela retenção do ICMS-ST seja 3–Próprio declarante.

cTipo = 2
Se para o item em questão (F1M) existe um lançamento que corresponda ao código de Crédito definido no
parâmetro MV_CODRESS. Neste caso, grava o valor do Crédito de ICMS Próprio na tabela CDA.

@author Ulisses P. Oliveira
@since 12/02/2020
@version 1.0

/*/
//--------------------------------------------------------------------------------------------------
Function FISA231CDA(cAlias,cMvCodAju,cTipo,nVlrCodAju)
Local cCodAju := ''
Local cChvCDA := xFilial("CDA")       +;
                 (cAlias)->FT_TIPOMOV +;
                 (cAlias)->FT_ESPECIE +;
                 (cAlias)->FT_FORMUL  +;
                 (cAlias)->FT_NFISCAL +;
                 (cAlias)->FT_SERIE   +;
                 (cAlias)->FT_CLIEFOR +;
                 (cAlias)->FT_LOJA    +;
                 (cAlias)->FT_ITEM

Default cTipo      := '1'
Default nVlrCodAju := 0

If CDA->(MsSeek(cChvCDA))

    While CDA->(!Eof()) .And. CDA->(CDA_FILIAL+CDA_TPMOVI+CDA_ESPECI+CDA_FORMUL+CDA_NUMERO+CDA_SERIE+CDA_CLIFOR+CDA_LOJA+CDA_NUMITE) == cChvCDA .And. (cTipo != '1' .Or. Empty(cCodAju))
         If AllTrim(CDA->CDA_CODLAN) $ cMvCodAju
            cCodAju := CDA->CDA_CODLAN

            If cTipo == '2' //---Chamada da Função FISA231CRD(), que tem por finalidade gravar valor de Crédito do IMCS Próprio---//
		        RecLock('CDA',.F.)
		            CDA->CDA_VALOR := nVlrCodAju
		        CDA->(MsUnLock())
            EndIf

         EndIf
         CDA->(dbSkip())
    EndDo

EndIf

Return cCodAju


//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} FISA231GAP

Função que verifica, nas tabelas CDH e SF6, se, para o período em questão, existem guias geradas para
recolhimento de ICMS Antecipado na Apuração do ICMS, para algum dos códigos definidos no parâmetro 
MV_DRCCDAJ.

O retorno será usado na geração dos campos: 24 (COD_DA) / 25 (NUM_DARE) em entradas onde o código do 
responsável pela retenção do ICMS-ST seja 3–Próprio declarante.

@author Ulisses P. Oliveira
@since 12/02/2020
@version 1.0

/*/
//--------------------------------------------------------------------------------------------------
Function FISA231GAP(dPeriodo,cMvDrcCdAj)
    Local aArea      := GetArea()
    Local cAlias     := GetNextAlias()
    Local lF6DOCAEST := SF6->(FieldPos("F6_DOCAEST")) > 0
    Local cF6DOCAEST := ''
    Local cSeq       := ''
    Local aMvDrcCdAj := {}
    Local nCount     := 0
    Local cNumDareAp := ''
    Local lAchouGuia := .F.

    If !Empty(cMvDrcCdAj)
        aMvDrcCdAj := StrTokArr(cMvDrcCdAj,',')
        If Len(aMvDrcCdAj) > 0

            //--Verifica última Apuração de ICMS realizada para o período---//
            BeginSql Alias cAlias
                SELECT MAX(CDH.CDH_SEQUEN) CDH_SEQUEN
                FROM %TABLE:CDH% CDH
                WHERE CDH.CDH_FILIAL = %XFILIAL:CDH%  AND
                      CDH.CDH_TIPOIP = 'ST'           AND 
                      CDH.CDH_TIPOPR = '3'            AND 
                      CDH.CDH_PERIOD = '1'            AND
                      CDH.CDH_DTINI  = %EXP:dPeriodo% AND
                      CDH.CDH_LIVRO  = '*'            AND
                      CDH.%NOTDEL%
            EndSql

            DbSelectArea(cAlias)
            (cAlias)->(DbGoTop())
            If !(cAlias)->(Eof())
                cSeq := (cAlias)->CDH_SEQUEN
            EndIf
            (cAlias)->(DbCloseArea())

            If !Empty(cSeq)

                cF6DOCAEST := Iif(lF6DOCAEST, 'F6_DOCAEST,', '')
                cF6DOCAEST := "%" + cF6DOCAEST + "%"

                //--Verifica existem guias geradas para recolhimento de ICMS Antecipado na Apuração do ICMS, para algum dos códigos definidos no parâmetro MV_DRCCDAJ---//
                //--Retorna a primeira guia encontrada com o campo F6_DOCAEST preenchido---//
                BeginSql Alias cAlias
                    SELECT F6_EST, F6_NUMERO, %EXP:cF6DOCAEST% F6_VALOR, F6_OBSERV, F6_INF, CDH_GNREF3
                    FROM %TABLE:CDH% CDH LEFT OUTER JOIN %TABLE:SF6% SF6 ON (SF6.F6_FILIAL = CDH.CDH_FILIAL AND SF6.F6_EST = CDH.CDH_ESTGNR AND SF6.F6_NUMERO = CDH.CDH_GNRE AND SF6.%NOTDEL%)
                    WHERE CDH.CDH_FILIAL = %XFILIAL:CDH%   AND
                          CDH.CDH_TIPOIP = 'ST'            AND 
                          CDH.CDH_TIPOPR = '3'             AND 
                          CDH.CDH_PERIOD = '1'             AND
                          CDH.CDH_DTINI  =  %EXP:dPeriodo% AND
                          CDH.CDH_LIVRO  = '*'             AND
                          CDH.CDH_SEQUEN =  %EXP:cSeq%     AND 
                    	  CDH.CDH_LINHA  = 'GNR'           AND
                          CDH.%NOTDEL%
                EndSql

                DbSelectArea(cAlias)
                (cAlias)->(DbGoTop())
                While !(cAlias)->(Eof()) .And. Empty(cNumDareAp)
                    nCount := 1

                    While nCount <= Len(aMvDrcCdAj) .And. Empty(cNumDareAp)
                        If AllTrim(aMvDrcCdAj[nCount]) $ (cAlias)->F6_OBSERV .Or. AllTrim(aMvDrcCdAj[nCount]) $ (cAlias)->F6_INF .Or. AllTrim(aMvDrcCdAj[nCount]) $ (cAlias)->CDH_GNREF3
                            cNumDareAp := Iif(lF6DOCAEST,AllTrim((cAlias)->F6_DOCAEST),'')
                            lAchouGuia := .T.
                        EndIf
                        nCount++
                    EndDo

                    (cAlias)->(DbSkip())
                EndDo
                (cAlias)->(DbCloseArea())

            EndIf

        EndIf
    EndIf

    RestArea(aArea)
Return {lAchouGuia, cNumDareAp}

//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} FISA231GOP

Função que verifica, na tabela SF6, se, para o item em questão (SFT), existem guias geradas para 
recolhimento de ICMS Antecipado na operação, para algum dos códigos definidos no parâmetro MV_DRCCDAJ.

O retorno será usado na geração dos campos: 24 (COD_DA) / 25 (NUM_DARE) em entradas onde o código do 
responsável pela retenção do ICMS-ST seja 3–Próprio declarante.

@author Ulisses P. Oliveira
@since 12/02/2020
@version 1.0

/*/
//--------------------------------------------------------------------------------------------------
Function FISA231GOP(cAlias, cCodAju)
    Local aArea      := GetArea()
    Local cAliasSF6  := GetNextAlias()
    Local lF6DOCAEST := SF6->(FieldPos("F6_DOCAEST")) > 0
    Local cF6DOCAEST := ''
    Local cNumDareOp := ''
    Local lAchouGuia := .F.

    cF6DOCAEST := Iif(lF6DOCAEST, 'F6_DOCAEST,', '')
    cF6DOCAEST := "%" + cF6DOCAEST + "%"

    BeginSql Alias cAliasSF6
        SELECT F6_EST, F6_NUMERO, %EXP:cF6DOCAEST% F6_VALOR, F6_OBSERV, F6_INF
        FROM %TABLE:SF6% SF6
        WHERE SF6.F6_FILIAL  = %XFILIAL:SF6%              AND 
              SF6.F6_OPERNF  = '1'                        AND
        	  SF6.F6_DOC     = %EXP:(cAlias)->FT_NFISCAL% AND
        	  SF6.F6_SERIE   = %EXP:(cAlias)->FT_SERIE%   AND
        	  SF6.F6_CLIFOR  = %EXP:(cAlias)->FT_CLIEFOR% AND
        	  SF6.F6_LOJA    = %EXP:(cAlias)->FT_LOJA%    AND
        	  SF6.%NOTDEL%
    EndSql

    DbSelectArea(cAliasSF6)
    (cAliasSF6)->(DbGoTop())
    While !(cAliasSF6)->(Eof()) .And. Empty(cNumDareOp)

        If AllTrim(cCodAju) $ (cAliasSF6)->F6_OBSERV .Or. AllTrim(cCodAju) $ (cAliasSF6)->F6_INF
            cNumDareOp := Iif(lF6DOCAEST,AllTrim((cAliasSF6)->F6_DOCAEST),'')
            lAchouGuia := .T.
        EndIf

        (cAliasSF6)->(DbSkip())
    EndDo
    (cAliasSF6)->(DbCloseArea())

    RestArea(aArea)
Return {lAchouGuia, cNumDareOp}


//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} FISA231ALQ

Função que retorna alíquota efetiva e base de cálculo integral em casos de redução de base de cálculo.

@author Ulisses P. Oliveira
@since 08/05/2020
@version 12.1.17
/*/
//--------------------------------------------------------------------------------------------------
Function FISA231ALQ(nPercEfet,nBaseRed,nAliqCheia)
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


//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} FISA231CRD

Função que ajusta o valor do Crédito do ICMS Próprio apurado na tabela CDA.

@author Ulisses P. Oliveira
@since 15/05/2020
@version 1.0

/*/
//--------------------------------------------------------------------------------------------------
Function FISA231CRD(cPerApur)
    Local cAliasCrd  := GetNextAlias()
    Local dDataDe    := StoD(cPerApur+'01')
    Local dDataAte   := LastDay(dDataDe)
    Local aCodRes    := Iif(Empty(SuperGetMv("MV_CODRESS",,"")),{"","SC10000036"},&(SuperGetMv("MV_CODRESS",,{"","SC10000036"}))) //---Códigos de Lançamento de Ressarcimento/Crédito de ICMS Próprio---//
    Local cMvCodAju  := Iif(Len(aCodRes)==2,aCodRes[2],'')
    Local nVlrCodAju := 0
    Local lF1LCODREG := F1L->(FieldPos("F1L_CODREG")) > 0
    Local cF1LCODREG := "%" + Iif(lF1LCODREG, "F1L.F1L_CODREG IN ('','2120') AND", "") + "%"

    If !Empty(cMvCodAju)

        //--Verifica notas de saídas interstaduais apuradas no período. Caso encontre, ajusta valor da CDA para o código cMvCodAju---//
        BeginSql Alias cAliasCrd
            SELECT SFT.FT_TIPOMOV, SFT.FT_ESPECIE, 'S' FT_FORMUL, SFT.FT_NFISCAL, SFT.FT_SERIE, SFT.FT_CLIEFOR, SFT.FT_LOJA, SFT.FT_ITEM, F1M.F1M_QTDCON, ISNULL(F1MDEV.F1M_QTDCON,0) F1M_QTDDEV, F1L.F1L_VMUICM
            FROM %TABLE:F1M% F1M INNER JOIN %TABLE:SFT% SFT ON (SFT.FT_FILIAL  = %XFILIAL:SFT% AND SFT.FT_TIPOMOV = F1M.F1M_TPMOV AND SFT.FT_SERIE = F1M.F1M_SERIE AND SFT.FT_NFISCAL = F1M.F1M_NFISCA AND SFT.FT_CLIEFOR = F1M.F1M_PARTIC AND SFT.FT_LOJA = F1M.F1M_LOJA AND SFT.FT_ITEM = F1M.F1M_ITEM AND SFT.FT_PRODUTO = F1M.F1M_PRODUT AND SFT.%NOTDEL%)
                                 INNER JOIN %TABLE:F1L% F1L ON (F1L.F1L_FILIAL = %XFILIAL:F1L% AND F1L.F1L_ANOMES = F1M.F1M_ANOMES AND F1L.F1L_PRODUT = F1M.F1M_PRODUT AND %EXP:cF1LCODREG% F1L.%NOTDEL%)
                            LEFT OUTER JOIN (SELECT SD1.D1_FILIAL, SD1.D1_NFORI, SD1.D1_ITEMORI, SD1.D1_SERIORI, SD1.D1_FORNECE, SD1.D1_LOJA, SD1.D1_COD, SUM(F1MS.F1M_QTDCON) F1M_QTDCON
                                             FROM %TABLE:SD1% SD1 INNER JOIN %TABLE:F1M% F1MS ON (F1MS.F1M_FILIAL = %XFILIAL:F1M% AND F1MS.F1M_TPMOV = 'E' AND F1MS.F1M_SERIE = SD1.D1_SERIE AND F1MS.F1M_NFISCA = SD1.D1_DOC AND F1MS.F1M_PARTIC = SD1.D1_FORNECE AND F1MS.F1M_LOJA = SD1.D1_LOJA AND F1MS.F1M_ITEM = SD1.D1_ITEM AND F1MS.F1M_PRODUT = SD1.D1_COD AND F1MS.F1M_INDOP = '1' AND F1MS.%NOTDEL%)
                                             WHERE SD1.D1_FILIAL   = %XFILIAL:SD1%  AND
                                                   SD1.D1_DTDIGIT >= %EXP:dDataDe%  AND
                            	                   SD1.D1_DTDIGIT <= %EXP:dDataAte% AND
                            	                   SD1.D1_TIPO     = 'D'            AND
                            	                   SD1.%NOTDEL%
                                             GROUP BY SD1.D1_FILIAL, SD1.D1_NFORI, SD1.D1_ITEMORI, SD1.D1_SERIORI, SD1.D1_FORNECE, SD1.D1_LOJA, SD1.D1_COD) F1MDEV ON (F1MDEV.D1_FILIAL = %XFILIAL:SD1% AND F1MDEV.D1_NFORI = F1M.F1M_NFISCA AND F1MDEV.D1_ITEMORI = F1M.F1M_ITEM AND F1MDEV.D1_SERIORI = F1M.F1M_SERIE AND F1MDEV.D1_FORNECE = F1M.F1M_PARTIC AND F1MDEV.D1_LOJA = F1M.F1M_LOJA AND F1MDEV.D1_COD = F1M.F1M_PRODUT)
            WHERE F1M.F1M_FILIAL = %XFILIAL:F1M%  AND 
                  F1M.F1M_ANOMES = %EXP:cPerApur% AND
            	  F1M.F1M_TPMOV	 = 'S'        AND
            	  F1M.F1M_INDOP  = '0'        AND
            	  F1M.F1M_INDSAI = '20'       AND
            	  F1M.%NOTDEL%
        EndSql

        DbSelectArea(cAliasCrd)
        (cAliasCrd)->(DbGoTop())
        While !(cAliasCrd)->(Eof())

            nVlrCodAju := Round((cAliasCrd)->F1L_VMUICM * ((cAliasCrd)->F1M_QTDCON - (cAliasCrd)->F1M_QTDDEV),2)
            FISA231CDA(cAliasCrd,cMvCodAju,'2',nVlrCodAju)

            (cAliasCrd)->(DbSkip())
        EndDo
        (cAliasCrd)->(DbCloseArea())

    EndIf

Return


//-------------------------------------------------------------------
/*/{Protheus.doc} FSA231X1
@Autor Matheus Massarotto

@since 06/10/2020
@version 12.1.27

Verifico se determinado parâmetro do X1(pergunte) existe.
FISA231
/*/
//-------------------------------------------------------------------
Static Function FSA231X1(cPerg,cParam)
Local oFwSX1Util
Local aPergunte	:= {}
Local lRet		:= .T.
Local nPos		:= 1
Local oError    := ErrorBlock({|e| Conout("ERRO na função FISA231: " +e:Description +"- Filial " + FWGETCODFILIAL + " " + Time()+ "ERRORSTACK:"	+ Chr(10)+Chr(13) + e:ErrorStack , lRet:=.F.)})

Default cPerg	:= ""
Default cParam	:= ""

	if GetRPORelease() < "12.1.030"

		Begin Sequence
			//Garanto que estarão sem espaço e maisculo
			cParam	:= alltrim(UPPER(cParam))
			cPerg	:= alltrim(UPPER(cPerg))

			//pego a posição do parametro que se deseja verificar
			nPos:= val(right(cParam,2))

			//Classe que retorna os campos do SX1 (Perguntas) cadastrados para o ID passado
			oFwSX1Util:= FwSX1Util():New()
			oFwSX1Util:AddGroup(cPerg)
			oFwSX1Util:SearchGroup()
			aPergunte:= oFwSX1Util:GetGroup(cPerg)

			//Verifico se o parâmetro existe
			if !(len(aPergunte)>1 .and. len(aPergunte[2])>(nPos-1) .and. Upper(AllTrim(aPergunte[2][nPos]:CX1_VAR01)) == cParam)
				lRet:=.F.
			endif
			
		End Sequence

		//Limpo o array e limpo o objeto
		FwFreeArray(aPergunte)
		oFwSX1Util:= Nil

		//Tratamento para caso de erro apresentar a msg com conout.
		ErrorBlock(oError)

	endif

Return (lRet)
