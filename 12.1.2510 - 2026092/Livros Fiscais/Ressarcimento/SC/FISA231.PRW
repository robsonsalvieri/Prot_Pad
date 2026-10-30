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

    Local cAlias      := ''
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
    Local aFilData    := {}
    Local oTmpPer     := Nil
    Local oPrep1      := Nil
    Local oPrep2      := Nil    
    Local oExec       := Nil
    Local nOrder      := 0
    Local nTmFil      := FWSX3Util():GetFieldStruct('FT_FILIAL' )[3]
    Local nTmTpMov    := FWSX3Util():GetFieldStruct('FT_TIPOMOV')[3]
    Local nTmSerie    := FWSX3Util():GetFieldStruct('FT_SERIE'  )[3]
    Local nTmNFisc    := FWSX3Util():GetFieldStruct('FT_NFISCAL')[3]
    Local nTmCliFo    := FWSX3Util():GetFieldStruct('FT_CLIEFOR')[3]
    Local nTmLoja     := FWSX3Util():GetFieldStruct('FT_LOJA'   )[3]
    Local nTmItem     := FWSX3Util():GetFieldStruct('FT_ITEM'   )[3]
    Local nTmProd     := FWSX3Util():GetFieldStruct('FT_PRODUTO')[3]
    Local nTmNfOri    := FWSX3Util():GetFieldStruct('FT_NFORI'  )[3]
    Local nTmSerOr    := FWSX3Util():GetFieldStruct('FT_SERORI' )[3]
    Local nTmItOri    := FWSX3Util():GetFieldStruct('FT_ITEMORI')[3]
    Local nTmDtCan    := FWSX3Util():GetFieldStruct('FT_DTCANC' )[3]
    Local nTmCodCli   := FWSX3Util():GetFieldStruct('CD2_CODCLI')[3]
    Local nTmLojCli   := FWSX3Util():GetFieldStruct('CD2_LOJCLI')[3]
	Local oCacheSX6   := Nil
    Private lAutomato := Iif(IsBlind(),.T.,.F.)

    Default nEntPerAnt:= 1 //1 - Todas , 2 - Qtde Necessária. (Default 1- Todas as entradas)

    If AliasIndic("F1I") .And. AliasIndic("F1J") .And. AliasIndic("F1K") .And. AliasIndic("F1L") .And. AliasIndic("F1M") .And. AliasIndic("F2W") .And. AliasIndic("F3M") .And. AliasIndic("F2Q")
		DbSelectArea ("F1I")
		DbSelectArea ("F1J")
		DbSelectArea ("F1K")
		DbSelectArea ("F1L")
		DbSelectArea ("F1M")
		DbSelectArea ("F2W")
		DbSelectArea ("F3M")
		DbSelectArea ("F2Q")
        DbSelectArea ("CDA")
        CDA->(DbSetOrder(1))  //CDA_FILIAL+CDA_TPMOVI+CDA_ESPECI+CDA_FORMUL+CDA_NUMERO+CDA_SERIE+CDA_CLIFOR+CDA_LOJA+CDA_NUMITE+CDA_SEQ+CDA_CODLAN+CDA_CALPRO
        SD1->(DbSetOrder(19)) //J D1_FILIAL+D1_NFORI+D1_SERIORI+D1_FORNECE+D1_LOJA 
        SD2->(DbSetOrder(10)) //A D2_FILIAL+D2_NFORI+D2_SERIORI

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

            aadd(aFilData,{dDataDe,dDataAte,dDataAtePA,dDataDeP1,dDataDeP2,dDataDeP3,dDataDeP4,dDataDeP5,dDataDeP6,dDataDeP7,dDataDeP8,dDataDeP9,dDataDeP10,dDataDeP11,dDataDeP12})

            CreateTmps( @oTmpPer, aFilData )

            //---Classe responsável pela apuração do movimento---//
            oApuracao := FISA230APURACAO():New(cIdApur,cPerApur,aDtIniReCo,aDtIniReg)

            //---Verifica a existência de guia para recolhimento de ICMS Antecipado na Apuração do ICMS---//
            aNumDareAp := FISA231GAP(dDataDe,cMvDrcCdAj)

            AtualizaMsg(oSay,STR0005) //---Verificando movimento no período...---//

            cQry := "SELECT TMP.FT_PRODUTO,B1_PICM,B1_UM,B1_SEGUM,B1_CONV,B1_TIPCONV,ISNULL(F2Q_RESVSN,'') F2Q_RESVSN,"
            cQry += "ISNULL(SFT_.FT_QTDPA,0) UE_QTDPA,ISNULL(SFT_.FT_QTDP1,0) UE_QTDP1,ISNULL(SFT_.FT_QTDP2,0) UE_QTDP2,ISNULL(SFT_.FT_QTDP3,0) UE_QTDP3,"
            cQry += "ISNULL(SFT_.FT_QTDP4,0) UE_QTDP4,ISNULL(SFT_.FT_QTDP5,0) UE_QTDP5,ISNULL(SFT_.FT_QTDP6,0) UE_QTDP6,ISNULL(SFT_.FT_QTDP7,0) UE_QTDP7,"
            cQry += "ISNULL(SFT_.FT_QTDP8,0) UE_QTDP8,ISNULL(SFT_.FT_QTDP9,0) UE_QTDP9,ISNULL(SFT_.FT_QTDP10,0) UE_QTDP10,ISNULL(SFT_.FT_QTDP11,0) UE_QTDP11,"
            cQry += "ISNULL(SFT_.FT_QTDP12,0) UE_QTDP12,ISNULL(SFT_.FT_PERINI,'') UE_PERINI,"
            cQry += "CASE WHEN SUBSTRING(SFT2.FT_CLASFIS,2,2) = '60' AND SFT2.FT_ICMSRET = 0 THEN SFT2.FT_BASNDES ELSE SFT2.FT_BASERET END UE_BCST,"
            cQry += "CASE WHEN SUBSTRING(SFT2.FT_CLASFIS,2,2) = '60' AND SFT2.FT_ICMSRET = 0 THEN SFT2.FT_ALQNDES ELSE SFT2.FT_ALIQSOL END UE_ALQST,ISNULL(CD2.CD2_PREDBC,0) UE_PREDBC,"
            cQry += "TMP.FT_DATAMOV,TMP.FT_TIPOMOV,TMP.FT_TIPO,TMP.FT_ORDEM,TMP.FT_NFISCAL,TMP.FT_SERIE,TMP.FT_ITEM,TMP.FT_ESPECIE,TMP.FT_CHVNFE,TMP.FT_CLIEFOR,TMP.FT_LOJA,TMP.FT_CNPJCPF,"
            cQry += "ISNULL(A1_PESSOA,'') A1_PESSOA,"
            cQry += "CASE WHEN ISNULL(SF21.F2_TIPOCLI,'') <> '' THEN SF21.F2_TIPOCLI ELSE CASE WHEN ISNULL(SF22.F2_TIPOCLI,'') <> '' THEN SF22.F2_TIPOCLI ELSE ISNULL(TMP.A1_TIPO,'') END END A1_TIPO,"
            cQry += "TMP.FT_SIMPNAC,TMP.FT_CFOP,TMP.FT_CLASFIS,TMP.FT_QUANT,TMP.FT_TOTAL,TMP.FT_FRETE,TMP.FT_SEGURO,TMP.FT_DESPESA,TMP.FT_VALCONT,"
            cQry += "TMP.FT_BASEICM,TMP.FT_ALIQICM,TMP.FT_VALICM,TMP.FT_BASERET,TMP.FT_ALIQSOL,TMP.FT_ICMSRET,TMP.FT_BASNDES,TMP.FT_ALQNDES,TMP.FT_ICMNDES,"
            cQry += "TMP.FT_RESPRET,TMP.FT_TGRETAN,TMP.FT_BCST,TMP.FT_ALQST,TMP.FT_VLRST,TMP.FT_VALANTI,TMP.FT_PDV,"
            cQry += "ISNULL(SFI.FI_SERPDV,'') FI_SERPDV,ISNULL(SFI.FI_COO,'') FI_COO, TMP.FT_NFORI,TMP.FT_SERORI,TMP.FT_ITEMORI,"            
            cQry += "CASE WHEN TMP.FT_TIPO = 'D' THEN CASE WHEN TMP.FT_TIPOMOV = 'E' THEN SF22.F2_EMISSAO ELSE TMP.F1_DTDIGIT END ELSE ' ' END FT_EMISORI,TMP.FT_FORMUL "

            cQry += "FROM " + oTmpPer:GetRealName() + " TMP " //oTmp Filtrada SFT/SB1/F2W/F3M/SA1/SA2/SF1/SD1/SD2

            cQry += "LEFT JOIN " + RetSqlName("SF2") + " SF21 ON ( SF21.F2_FILIAL = ? AND SF21.F2_DOC = TMP.FT_NFISCAL AND SF21.F2_SERIE = TMP.FT_SERIE "
            cQry += "AND SF21.F2_CLIENTE = TMP.FT_CLIEFOR AND SF21.F2_LOJA = TMP.FT_LOJA AND (TMP.FT_TIPOMOV = ? AND TMP.FT_TIPO IN (?)) AND SF21.D_E_L_E_T_ = ? ) "

            cQry += "LEFT JOIN " + RetSqlName("SF2") + " SF22 ON ( SF22.F2_FILIAL = ? AND SF22.F2_DOC = TMP.FT_NFORI AND SF22.F2_SERIE = TMP.FT_SERORI "
            cQry += "AND SF22.F2_CLIENTE = TMP.FT_CLIEFOR AND SF22.F2_LOJA = TMP.FT_LOJA AND (TMP.FT_TIPOMOV = ? AND TMP.FT_TIPO = ? ) AND SF22.D_E_L_E_T_ = ? ) "

            cQry += "LEFT JOIN " + RetSqlName("SFI") + " SFI ON ( SFI.FI_FILIAL = ? AND SFI.FI_DTMOVTO = TMP.FT_EMISSAO AND SFI.FI_PDV = TMP.FT_PDV AND SFI.D_E_L_E_T_ = ? ) "
            cQry += "LEFT JOIN " + RetSqlName("F2Q") + " F2Q ON ( F2Q.F2Q_FILIAL = ? AND F2Q.F2Q_PRODUT = TMP.B1_COD AND F2Q.D_E_L_E_T_ = ? ) "

            cQry += "LEFT JOIN ( SELECT SFTS1.FT_FILIAL,SFTS1.FT_PRODUTO,"
            cQry += "SUM(CASE WHEN SFTS1.FT_ENTRADA <= ? THEN CASE SFTS1.FT_TIPO WHEN ? THEN SFTS1.FT_QUANT*(-1) ELSE SFTS1.FT_QUANT END ELSE 0 END) FT_QTDPA,"
            cQry += "SUM(CASE WHEN SFTS1.FT_ENTRADA BETWEEN ? AND ? THEN CASE SFTS1.FT_TIPO WHEN ? THEN SFTS1.FT_QUANT*(-1) ELSE SFTS1.FT_QUANT END ELSE 0 END) FT_QTDP1,"
            cQry += "SUM(CASE WHEN SFTS1.FT_ENTRADA BETWEEN ? AND ? THEN CASE SFTS1.FT_TIPO WHEN ? THEN SFTS1.FT_QUANT*(-1) ELSE SFTS1.FT_QUANT END ELSE 0 END) FT_QTDP2,"
            cQry += "SUM(CASE WHEN SFTS1.FT_ENTRADA BETWEEN ? AND ? THEN CASE SFTS1.FT_TIPO WHEN ? THEN SFTS1.FT_QUANT*(-1) ELSE SFTS1.FT_QUANT END ELSE 0 END) FT_QTDP3,"
            cQry += "SUM(CASE WHEN SFTS1.FT_ENTRADA BETWEEN ? AND ? THEN CASE SFTS1.FT_TIPO WHEN ? THEN SFTS1.FT_QUANT*(-1) ELSE SFTS1.FT_QUANT END ELSE 0 END) FT_QTDP4,"
            cQry += "SUM(CASE WHEN SFTS1.FT_ENTRADA BETWEEN ? AND ? THEN CASE SFTS1.FT_TIPO WHEN ? THEN SFTS1.FT_QUANT*(-1) ELSE SFTS1.FT_QUANT END ELSE 0 END) FT_QTDP5,"
            cQry += "SUM(CASE WHEN SFTS1.FT_ENTRADA BETWEEN ? AND ? THEN CASE SFTS1.FT_TIPO WHEN ? THEN SFTS1.FT_QUANT*(-1) ELSE SFTS1.FT_QUANT END ELSE 0 END) FT_QTDP6,"
            cQry += "SUM(CASE WHEN SFTS1.FT_ENTRADA BETWEEN ? AND ? THEN CASE SFTS1.FT_TIPO WHEN ? THEN SFTS1.FT_QUANT*(-1) ELSE SFTS1.FT_QUANT END ELSE 0 END) FT_QTDP7,"
            cQry += "SUM(CASE WHEN SFTS1.FT_ENTRADA BETWEEN ? AND ? THEN CASE SFTS1.FT_TIPO WHEN ? THEN SFTS1.FT_QUANT*(-1) ELSE SFTS1.FT_QUANT END ELSE 0 END) FT_QTDP8,"
            cQry += "SUM(CASE WHEN SFTS1.FT_ENTRADA BETWEEN ? AND ? THEN CASE SFTS1.FT_TIPO WHEN ? THEN SFTS1.FT_QUANT*(-1) ELSE SFTS1.FT_QUANT END ELSE 0 END) FT_QTDP9,"
            cQry += "SUM(CASE WHEN SFTS1.FT_ENTRADA BETWEEN ? AND ? THEN CASE SFTS1.FT_TIPO WHEN ? THEN SFTS1.FT_QUANT*(-1) ELSE SFTS1.FT_QUANT END ELSE 0 END) FT_QTDP10,"
            cQry += "SUM(CASE WHEN SFTS1.FT_ENTRADA BETWEEN ? AND ? THEN CASE SFTS1.FT_TIPO WHEN ? THEN SFTS1.FT_QUANT*(-1) ELSE SFTS1.FT_QUANT END ELSE 0 END) FT_QTDP11,"
            cQry += "SUM(CASE WHEN SFTS1.FT_ENTRADA BETWEEN ? AND ? THEN CASE SFTS1.FT_TIPO WHEN ? THEN SFTS1.FT_QUANT*(-1) ELSE SFTS1.FT_QUANT END ELSE 0 END) FT_QTDP12,"
            cQry += "MIN(SFTS1.FT_ENTRADA) FT_PERINI,"
            cQry += "MAX(CASE WHEN SFTS1.FT_TIPOMOV = ? AND SFTS1.FT_TIPO IN (?) AND SFTS1.FT_NFORI = ? AND SFTS1.FT_SERORI = ? AND SFTS1.FT_ITEMORI = ? THEN SFTS1.FT_FILIAL ELSE ? END) MX_FILIAL,"
            cQry += "MAX(CASE WHEN SFTS1.FT_TIPOMOV = ? AND SFTS1.FT_TIPO IN (?) AND SFTS1.FT_NFORI = ? AND SFTS1.FT_SERORI = ? AND SFTS1.FT_ITEMORI = ? THEN SFTS1.FT_TIPOMOV ELSE ? END) MX_TIPOMOV,"
            cQry += "MAX(CASE WHEN SFTS1.FT_TIPOMOV = ? AND SFTS1.FT_TIPO IN (?) AND SFTS1.FT_NFORI = ? AND SFTS1.FT_SERORI = ? AND SFTS1.FT_ITEMORI = ? THEN SFTS1.FT_SERIE ELSE ? END) MX_SERIE,"
            cQry += "MAX(CASE WHEN SFTS1.FT_TIPOMOV = ? AND SFTS1.FT_TIPO IN (?) AND SFTS1.FT_NFORI = ? AND SFTS1.FT_SERORI = ? AND SFTS1.FT_ITEMORI = ? THEN SFTS1.FT_NFISCAL ELSE ? END) MX_NFISCAL,"
            cQry += "MAX(CASE WHEN SFTS1.FT_TIPOMOV = ? AND SFTS1.FT_TIPO IN (?) AND SFTS1.FT_NFORI = ? AND SFTS1.FT_SERORI = ? AND SFTS1.FT_ITEMORI = ? THEN SFTS1.FT_CLIEFOR ELSE ? END) MX_CLIEFOR,"
            cQry += "MAX(CASE WHEN SFTS1.FT_TIPOMOV = ? AND SFTS1.FT_TIPO IN (?) AND SFTS1.FT_NFORI = ? AND SFTS1.FT_SERORI = ? AND SFTS1.FT_ITEMORI = ? THEN SFTS1.FT_LOJA ELSE ? END) MX_LOJA,"
            cQry += "MAX(CASE WHEN SFTS1.FT_TIPOMOV = ? AND SFTS1.FT_TIPO IN (?) AND SFTS1.FT_NFORI = ? AND SFTS1.FT_SERORI = ? AND SFTS1.FT_ITEMORI = ? THEN SFTS1.FT_ITEM ELSE ? END) MX_ITEM,"
            cQry += "MAX(CASE WHEN SFTS1.FT_TIPOMOV = ? AND SFTS1.FT_TIPO IN (?) AND SFTS1.FT_NFORI = ? AND SFTS1.FT_SERORI = ? AND SFTS1.FT_ITEMORI = ? THEN SFTS1.FT_PRODUTO ELSE ? END) MX_PRODUTO "
            cQry += "FROM " + RetSqlName("SFTS1") + " SFTS1 "
            cQry += "INNER JOIN " + RetSqlName("F2W") + " F2WS1 ON (F2WS1.F2W_FILIAL = ? AND F2WS1.F2W_CFOP = SFTS1.FT_CFOP AND F2WS1.D_E_L_E_T_ = ? ) "
            cQry += "INNER JOIN " + RetSqlName("F3M") + " F3MS1 ON (F3MS1.F3M_FILIAL = ? AND F3MS1.F3M_IDF2W = F2WS1.F2W_IDTAB AND F3MS1.F3M_CSTICM = SUBSTRING(SFTS1.FT_CLASFIS,2,2) AND F3MS1.D_E_L_E_T_ = ? ) "
            cQry += "LEFT JOIN " + RetSqlName("SF1") + " SF1S1 ON (SF1S1.F1_FILIAL = ? AND SF1S1.F1_DOC = SFTS1.FT_NFORI AND SF1S1.F1_SERIE = SFTS1.FT_SERORI AND SF1S1.F1_FORNECE = SFTS1.FT_CLIEFOR AND SF1S1.F1_LOJA = SFTS1.FT_LOJA AND (SFTS1.FT_TIPOMOV = ? AND SFTS1.FT_TIPO = ?) AND SF1S1.D_E_L_E_T_ = ? ) "
            cQry += "LEFT JOIN " + RetSqlName("SD1") + " SD1S1 ON (SD1S1.D1_FILIAL = ? AND SD1S1.D1_DOC = SFTS1.FT_NFISCAL AND SD1S1.D1_SERIE = SFTS1.FT_SERIE AND SD1S1.D1_FORNECE = SFTS1.FT_CLIEFOR AND SD1S1.D1_LOJA = SFTS1.FT_LOJA AND SD1S1.D1_COD = SFTS1.FT_PRODUTO AND SD1S1.D1_ITEM = SFTS1.FT_ITEM AND SFTS1.FT_TIPOMOV = ? AND SD1S1.D_E_L_E_T_ = ? ) "
            cQry += "WHERE SFTS1.FT_FILIAL = ? AND ((SFTS1.FT_TIPOMOV = ? AND SFTS1.FT_TIPO <> ?) OR "
            cQry += "(SFTS1.FT_TIPOMOV = ? AND SFTS1.FT_TIPO = ? AND SUBSTRING(SF1S1.F1_DTDIGIT,1,6) = SUBSTRING(SFTS1.FT_ENTRADA,1,6) )) AND "
            cQry += "SFTS1.FT_TIPO <> ? AND SFTS1.FT_ENTRADA <= ? AND SFTS1.FT_DTCANC = ? AND SFTS1.FT_QUANT > ? AND SFTS1.D_E_L_E_T_ = ? "
            cQry += "GROUP BY SFTS1.FT_FILIAL, SFTS1.FT_PRODUTO ) SFT_ ON (SFT_.FT_FILIAL = TMP.FT_FILIAL AND SFT_.FT_PRODUTO = TMP.FT_PRODUTO) "

            cQry += "LEFT JOIN " + RetSqlName("SFT") + " SFT2 ON " //FT_FILIAL, FT_TIPOMOV, FT_SERIE, FT_NFISCAL, FT_CLIEFOR, FT_LOJA, FT_ITEM, FT_PRODUTO
            cQry += "(SFT2.FT_FILIAL = MX_FILIAL AND SFT2.FT_TIPOMOV = MX_TIPOMOV AND SFT2.FT_SERIE = MX_SERIE AND SFT2.FT_NFISCAL = MX_NFISCAL AND SFT2.FT_CLIEFOR = MX_CLIEFOR AND SFT2.FT_LOJA = MX_LOJA AND "
            cQry += "SFT2.FT_ITEM = MX_ITEM AND SFT2.FT_PRODUTO = MX_PRODUTO AND SFT2.D_E_L_E_T_ = ? ) "

            cQry += "LEFT JOIN " + RetSqlName("CD2") + " CD2 ON " //CD2_FILIAL, CD2_TPMOV, CD2_SERIE, CD2_DOC, CD2_CODCLI, CD2_LOJCLI, CD2_CODFOR, CD2_LOJFOR, CD2_ITEM, CD2_CODPRO, CD2_IMP
            cQry += "(CD2.CD2_FILIAL = ? AND CD2.CD2_TPMOV = SFT2.FT_TIPOMOV AND CD2.CD2_SERIE = SFT2.FT_SERIE AND CD2.CD2_DOC = SFT2.FT_NFISCAL AND "
            cQry += "CD2.CD2_CODCLI = ? AND CD2.CD2_LOJCLI = ? AND CD2.CD2_CODFOR = SFT2.FT_CLIEFOR AND CD2.CD2_LOJFOR = SFT2.FT_LOJA AND CD2.CD2_ITEM = SFT2.FT_ITEM AND "
            cQry += "CD2.CD2_CODPRO = SFT2.FT_PRODUTO AND CD2.CD2_IMP = ? AND (SFT2.FT_TIPOMOV = ? AND SFT2.FT_TIPO IN (?) ) AND CD2.D_E_L_E_T_ = ?) "

            cQry += "WHERE TMP.FT_FILIAL = ? AND TMP.FT_ENTRADA >= ? AND TMP.FT_ENTRADA <= ? AND TMP.FT_TIPO IN (?) AND TMP.FT_DTCANC = ? AND TMP.FT_QUANT > ? AND TMP.D_E_L_E_T_ = ? AND TMP.B1_CRICMST = ? "

            cQry += "ORDER BY TMP.FT_FILIAL, TMP.FT_PRODUTO, TMP.FT_DATAMOV, TMP.FT_ORDEM, TMP.FT_CLIEFOR, TMP.FT_LOJA, TMP.FT_NFISCAL, TMP.FT_ITEM, TMP.FT_SERIE "

            cQry := ChangeQuery(cQry)

            oExec := FwExecStatement():New(cQry)
            nOrder := 0
            oExec:SetString( ++nOrder, xFilial("SF2") )                     //001 SF21
            oExec:SetString( ++nOrder, 'S' )                                //002 FT_TIPOMOV
            oExec:SetIn(     ++nOrder, {' ','C','I','N','P','S'} )			//003 FT_TIPO
            oExec:SetString( ++nOrder, space(1) )                           //004 SF21.D_E_L_E_T_            
            oExec:SetString( ++nOrder, xFilial("SF2") )                     //005 SF22
            oExec:SetString( ++nOrder, 'E' )                                //006 FT_TIPOMOV
            oExec:SetString( ++nOrder, 'D' )                                //007 FT_TIPO
            oExec:SetString( ++nOrder, space(1) )                           //008 SF22.D_E_L_E_T_
            oExec:SetString( ++nOrder, xFilial("SFI") )                     //009 SFI
            oExec:SetString( ++nOrder, space(1) )                           //010 D_E_L_E_T_
            oExec:SetString( ++nOrder, xFilial("F2Q") )                     //011 F2Q
            oExec:SetString( ++nOrder, space(1) )                           //012 D_E_L_E_T_
            oExec:SetString( ++nOrder, Dtos(dDataAtePA) )                   //013 FT_QTDPA
            
            oExec:SetString( ++nOrder, 'D' )                                //014 
            oExec:SetString( ++nOrder, Dtos(dDataDeP1) )                    //015 FT_QTDP1
            oExec:SetString( ++nOrder, Dtos(dDataAtePA) )                   //016
            oExec:SetString( ++nOrder, 'D' )                                //017
            oExec:SetString( ++nOrder, Dtos(dDataDeP2) )                    //018 FT_QTDP2
            oExec:SetString( ++nOrder, Dtos(dDataAtePA) )                   //019 
            oExec:SetString( ++nOrder, 'D' )                                //020
            oExec:SetString( ++nOrder, Dtos(dDataDeP3) )                    //021 FT_QTDP3
            oExec:SetString( ++nOrder, Dtos(dDataAtePA) )                   //022 
            oExec:SetString( ++nOrder, 'D' )                                //023             
            oExec:SetString( ++nOrder, Dtos(dDataDeP4) )                    //024 FT_QTDP4
            oExec:SetString( ++nOrder, Dtos(dDataAtePA) )                   //025 
            oExec:SetString( ++nOrder, 'D' )                                //026 
            oExec:SetString( ++nOrder, Dtos(dDataDeP5) )                    //027 FT_QTDP5
            oExec:SetString( ++nOrder, Dtos(dDataAtePA) )                   //028 
            oExec:SetString( ++nOrder, 'D' )                                //029            
            oExec:SetString( ++nOrder, Dtos(dDataDeP6) )                    //030 FT_QTDP6
            oExec:SetString( ++nOrder, Dtos(dDataAtePA) )                   //031 
            oExec:SetString( ++nOrder, 'D' )                                //032             
            oExec:SetString( ++nOrder, Dtos(dDataDeP7) )                    //033 FT_QTDP7
            oExec:SetString( ++nOrder, Dtos(dDataAtePA) )                   //034 
            oExec:SetString( ++nOrder, 'D' )                                //035             
            oExec:SetString( ++nOrder, Dtos(dDataDeP8) )                    //036 FT_QTDP8
            oExec:SetString( ++nOrder, Dtos(dDataAtePA) )                   //037 
            oExec:SetString( ++nOrder, 'D' )                                //038            
            oExec:SetString( ++nOrder, Dtos(dDataDeP9) )                    //039 FT_QTDP9
            oExec:SetString( ++nOrder, Dtos(dDataAtePA) )                   //040 
            oExec:SetString( ++nOrder, 'D' )                                //041            
            oExec:SetString( ++nOrder, Dtos(dDataDeP10) )                   //042 FT_QTDP10
            oExec:SetString( ++nOrder, Dtos(dDataAtePA) )                   //043 
            oExec:SetString( ++nOrder, 'D' )                                //044            
            oExec:SetString( ++nOrder, Dtos(dDataDeP11) )                   //045 FT_QTDP11
            oExec:SetString( ++nOrder, Dtos(dDataAtePA) )                   //046 
            oExec:SetString( ++nOrder, 'D' )                                //047            
            oExec:SetString( ++nOrder, Dtos(dDataDeP12) )                   //048 FT_QTDP12
            oExec:SetString( ++nOrder, Dtos(dDataAtePA) )                   //049
            oExec:SetString( ++nOrder, 'D' )                                //050

            oExec:SetString( ++nOrder, 'E' )                                //051 SFTS1.FT_TIPOMOV ( MX_FILIAL )
            oExec:SetIn(     ++nOrder, {' ','N'} )							//052 SFTS1.FT_TIPO NOT IN ('D','B','S','P','I','C')
            oExec:SetString( ++nOrder, space(nTmNfOri) )                    //053 SFTS1.FT_NFORI
            oExec:SetString( ++nOrder, space(nTmSerOr) )                    //054 SFTS1.FT_SERORI
            oExec:SetString( ++nOrder, space(nTmItOri) )                    //055 SFTS1.FT_ITEMORI
            oExec:SetString( ++nOrder, space(nTmFil) )                      //056 SFTS1.FT_FILIAL ( MX_FILIAL )

            oExec:SetString( ++nOrder, 'E' )                                //057 SFTS1.FT_TIPOMOV ( MX_TIPOMOV )
            oExec:SetIn(     ++nOrder, {' ','N'} )							//058 SFTS1.FT_TIPO NOT IN ('D','B','S','P','I','C')
            oExec:SetString( ++nOrder, space(nTmNfOri) )                    //059 SFTS1.FT_NFORI
            oExec:SetString( ++nOrder, space(nTmSerOr) )                    //060 SFTS1.FT_SERORI
            oExec:SetString( ++nOrder, space(nTmItOri) )                    //061 SFTS1.FT_ITEMORI
            oExec:SetString( ++nOrder, space(nTmTpMov) )                    //062 SFTS1.FT_TIPOMOV ( MX_TIPOMOV )

            oExec:SetString( ++nOrder, 'E' )                                //063 SFTS1.FT_TIPOMOV ( MX_SERIE )
            oExec:SetIn(     ++nOrder, {' ','N'} )							//064 SFTS1.FT_TIPO NOT IN ('D','B','S','P','I','C')
            oExec:SetString( ++nOrder, space(nTmNfOri) )                    //065 SFTS1.FT_NFORI
            oExec:SetString( ++nOrder, space(nTmSerOr) )                    //066 SFTS1.FT_SERORI
            oExec:SetString( ++nOrder, space(nTmItOri) )                    //067 SFTS1.FT_ITEMORI
            oExec:SetString( ++nOrder, space(nTmSerie) )                    //068 SFTS1.FT_SERIE ( MX_SERIE )

            oExec:SetString( ++nOrder, 'E' )                                //069 SFTS1.FT_TIPOMOV ( MX_NFISCAL )
            oExec:SetIn(     ++nOrder, {' ','N'} )							//070 SFTS1.FT_TIPO NOT IN ('D','B','S','P','I','C')
            oExec:SetString( ++nOrder, space(nTmNfOri) )                    //071 SFTS1.FT_NFORI
            oExec:SetString( ++nOrder, space(nTmSerOr) )                    //072 SFTS1.FT_SERORI
            oExec:SetString( ++nOrder, space(nTmItOri) )                    //073 SFTS1.FT_ITEMORI
            oExec:SetString( ++nOrder, space(nTmNFisc) )                    //074 SFTS1.FT_NFISCAL ( MX_NFISCAL )

            oExec:SetString( ++nOrder, 'E' )                                //075 SFTS1.FT_TIPOMOV ( MX_CLIEFOR )
            oExec:SetIn(     ++nOrder, {' ','N'} )							//076 SFTS1.FT_TIPO NOT IN ('D','B','S','P','I','C')
            oExec:SetString( ++nOrder, space(nTmNfOri) )                    //077 SFTS1.FT_NFORI
            oExec:SetString( ++nOrder, space(nTmSerOr) )                    //078 SFTS1.FT_SERORI
            oExec:SetString( ++nOrder, space(nTmItOri) )                    //079 SFTS1.FT_ITEMORI
            oExec:SetString( ++nOrder, space(nTmCliFo) )                    //080 SFTS1.FT_CLIEFOR (MX_CLIEFOR)

            oExec:SetString( ++nOrder, 'E' )                                //081 SFTS1.FT_TIPOMOV ( MX_LOJA )
            oExec:SetIn(     ++nOrder, {' ','N'} )							//082 SFTS1.FT_TIPO NOT IN ('D','B','S','P','I','C')
            oExec:SetString( ++nOrder, space(nTmNfOri) )                    //083 SFTS1.FT_NFORI
            oExec:SetString( ++nOrder, space(nTmSerOr) )                    //084 SFTS1.FT_SERORI
            oExec:SetString( ++nOrder, space(nTmItOri) )                    //085 SFTS1.FT_ITEMORI
            oExec:SetString( ++nOrder, space(nTmLoja) )                     //086 SFTS1.FT_LOJA ( MX_LOJA )

            oExec:SetString( ++nOrder, 'E' )                                //087 SFTS1.FT_TIPOMOV ( MX_ITEM )
            oExec:SetIn(     ++nOrder, {' ','N'} )							//088 SFTS1.FT_TIPO NOT IN ('D','B','S','P','I','C')
            oExec:SetString( ++nOrder, space(nTmNfOri) )                    //089 SFTS1.FT_NFORI
            oExec:SetString( ++nOrder, space(nTmSerOr) )                    //090 SFTS1.FT_SERORI
            oExec:SetString( ++nOrder, space(nTmItOri) )                    //091 SFTS1.FT_ITEMORI
            oExec:SetString( ++nOrder, space(nTmItem) )                     //092 SFTS1.FT_ITEM ( MX_ITEM )

            oExec:SetString( ++nOrder, 'E' )                                //093 SFTS1.FT_TIPOMOV ( MX_PRODUTO )
            oExec:SetIn(     ++nOrder, {' ','N'} )							//094 SFTS1.FT_TIPO NOT IN ('D','B','S','P','I','C')
            oExec:SetString( ++nOrder, space(nTmNfOri) )                    //095 SFTS1.FT_NFORI
            oExec:SetString( ++nOrder, space(nTmSerOr) )                    //096 SFTS1.FT_SERORI
            oExec:SetString( ++nOrder, space(nTmItOri) )                    //097 SFTS1.FT_ITEMORI
            oExec:SetString( ++nOrder, space(nTmProd) )                     //098 SFTS1.FT_PRODUTO ( MX_PRODUTO )

            oExec:SetString( ++nOrder, xFilial("F2W") )                     //099 F2WS1.F2W_FILIAL
            oExec:SetString( ++nOrder, space(1) )                           //100 F2WS1.D_E_L_E_T_

            oExec:SetString( ++nOrder, xFilial("F3M") )                     //101 F3MS1.F3M_FILIAL
            oExec:SetString( ++nOrder, space(1) )                           //102 F3MS1.D_E_L_E_T_

            oExec:SetString( ++nOrder, xFilial("SF1") )                     //103 SF1S1.F1_FILIAL
            oExec:SetString( ++nOrder, 'S' )                                //104 SFTS1.FT_TIPOMOV
            oExec:SetString( ++nOrder, 'D' )                                //105 SFTS1.FT_TIPO
            oExec:SetString( ++nOrder, space(1) )                           //106 SF1S1.D_E_L_E_T_

            oExec:SetString( ++nOrder, xFilial("SD1") )                     //107 SD1S1.D1_FILIAL
            oExec:SetString( ++nOrder, 'E' )                                //108 SFTS1.FT_TIPOMOV
            oExec:SetString( ++nOrder, space(1) )                           //109 SD1S1.D_E_L_E_T_

            oExec:SetString( ++nOrder, xFilial("SFT") )                     //110 WHERE SFTS1.FT_FILIAL
            oExec:SetString( ++nOrder, 'E' )                                //111 SFTS1.FT_TIPOMOV
            oExec:SetString( ++nOrder, 'D' )                                //112 SFTS1.FT_TIPO
            oExec:SetString( ++nOrder, 'S' )                                //113 SFTS1.FT_TIPOMOV
            oExec:SetString( ++nOrder, 'D' )                                //114 SFTS1.FT_TIPO
            oExec:SetString( ++nOrder, 'S' )                                //115 SFTS1.FT_TIPO
            oExec:SetString( ++nOrder, Dtos(dDataAte) )                     //116 SFTS1.FT_ENTRADA
            oExec:SetString( ++nOrder, space(nTmDtCan) )                    //117 SFTS1.FT_DTCANC
            oExec:SetNumeric(++nOrder, 0   )                                //118 SFTS1.FT_QUANT
            oExec:SetString( ++nOrder, space(1) )                           //119 SFTS1.D_E_L_E_T_

            oExec:SetString( ++nOrder, space(1) )                           //120 SFT2.D_E_L_E_T_

            oExec:SetString( ++nOrder, xFilial("CD2") )                     //121 CD2_FILIAL
            oExec:SetString( ++nOrder, space(nTmCodCli) )                   //122 CD2_CODCLI
            oExec:SetString( ++nOrder, space(nTmLojCli) )                   //123 CD2_LOJCLI
            oExec:SetString( ++nOrder, 'SOL' )                              //124 CD2_IMP
            oExec:SetString( ++nOrder, 'E' )                                //125 FT_TIPOMOV
            oExec:SetIn(     ++nOrder, {' ','C','I','N','P','S'} )          //126 FT_TIPO NOT IN ('D','B')
            oExec:SetString( ++nOrder, space(1) )                           //127 CD2.D_E_L_E_T_

            oExec:SetString( ++nOrder, xFilial("SFT") )                     //128 TMP.FT_FILIAL
            oExec:SetString( ++nOrder, Dtos(dDataDe) )                      //129 TMP.FT_ENTRADA >=
            oExec:SetString( ++nOrder, Dtos(dDataAte) )                     //130 TMP.FT_ENTRADA <=
            oExec:SetIn(     ++nOrder, {' ','B','D','N'} )                  //131 TMP.FT_TIPO //NOT IN ('S','P','I','C')
            oExec:SetString( ++nOrder, space(nTmDtCan) )                    //132 TMP.FT_DTCANC
            oExec:SetNumeric(++nOrder, 0   )                                //133 TMP.FT_QUANT
            oExec:SetString( ++nOrder, space(1) )                           //134 TMP.D_E_L_E_T_ = ' '
            oExec:SetString( ++nOrder, '1' )                                //135 TMP.B1_CRICMST

            cAlias := oExec:OpenAlias( GetNextAlias() ) //oExec:GetFixQuery()

	        TcSetField(cAlias,"FT_EMISSAO","D",8,0)
            TcSetField(cAlias,"FT_ENTRADA","D",8,0)
            TcSetField(cAlias,"FT_DATAMOV","D",8,0)
            TcSetField(cAlias,"FT_EMISORI","D",8,0)
            TcSetField(cAlias,"UE_PERINI" ,"D",8,0)
            TcSetField(cAlias,"F1_DTDIGIT","D",8,0)

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
                            oApuracao:ApuraProd(nQtdEstPrd,nQtdPerAnt,aQtdPerAnt,nEntPerAnt,@oPrep1,@oPrep2,@oCacheSX6)

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
                    aVlrCmp := { 0, 0, 0, 0, 0, 0, 0, 0, 0, .F. ,{} ,0 }
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
                    oApuracao:ApuraMovim(nEntPerAnt,@oPrep1,@oPrep2,@oCacheSX6)

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

                If oExec != NIL
                    oExec:Destroy()
                    oExec := NIL
                EndIf

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
                    oApuracao:ApuraProd(nQtdEstPrd,nQtdPerAnt,aQtdPerAnt,nEntPerAnt,@oPrep1,@oPrep2,@oCacheSX6)

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

    if valtype(oTmpPer) == "O"
        oTmpPer:delete()
        FreeObj(oTmpPer)
    endif

    If oPrep1 != NIL
        oPrep1:Destroy()
        oPrep1 := NIL
    EndIf

    If oPrep2 != NIL
        oPrep2:Destroy()
        oPrep2 := NIL
    EndIf

	If oCacheSX6 != Nil
        FreeObj( oCacheSX6 )
    Endif
Return Nil

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

//-------------------------------------------------------------------
/*/{Protheus.doc} CreateTmps
@Autor Denis Souza

Cria temporária na SFT com dados tratados para evitar substrs posteriores na SFT 
do período, isso influencia em ganho de perfomance pois não ocorre comparação nos 
filtros e utiliza índice (no On dos joins, Where e Ordenação).

A temporária da SFT já é filtrada por período com mais 8 tabelas 
(SB1\F2W\F3M\SA1\SA2\SF1\SD1\SD2) e não realiza substr nos joins.

Como o cliente possui problema de lentidão e timeout no banco de dados.
Separa a carga do programa em 2 etapas (temporárias), assim o programa
retorna para o server e evita timeout além de reaproveitar a temporária.

@since 02/03/2026
@version 12.1.2510
/*/
//-------------------------------------------------------------------
Static Function CreateTmps( oTmpPer, aFilData )

    Local aStru1  := {}
    Local oTmpSFT := Nil

    Default oTmpPer := Nil
    Default aFilData := {}

    NewTmpSFT( @aStru1, @oTmpSFT )
    IncNewSFT( oTmpSFT, aFilData )

    NewTmpPer(aStru1, @oTmpPer )
    IncTmpPer( oTmpSFT, oTmpPer )

    aSize(aStru1,0)

    if valtype(oTmpSFT) == "O"
        oTmpSFT:delete()
        FreeObj(oTmpSFT)
    endif

Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} NewTmpSFT
@Autor Denis Souza

Cria temporária na SFT com dados tratados para evitar substrs posteriores na SFT do período,
isso influencia em ganho de perfomance pois não ocorre comparação nos filtros e utiliza índice 
(no On dos joins, Where e Ordenação).

@since 02/03/2026
@version 12.1.2510
/*/
//-------------------------------------------------------------------
Static Function NewTmpSFT( aStru1, oTmpSFT )
    
    Default aStru1 := {}
    Default oTmpSFT := Nil

    aStru1 := { ;
    {'FT_FILIAL'  , FWSX3Util():GetFieldStruct("FT_FILIAL")[2] , FWSX3Util():GetFieldStruct("FT_FILIAL")[3] , FWSX3Util():GetFieldStruct("FT_FILIAL")[4]  },;
    {'FT_PRODUTO' , FWSX3Util():GetFieldStruct("FT_PRODUTO")[2], FWSX3Util():GetFieldStruct("FT_PRODUTO")[3], FWSX3Util():GetFieldStruct("FT_PRODUTO")[4] },;
    {'FT_ENTRADA' , FWSX3Util():GetFieldStruct("FT_ENTRADA")[2], FWSX3Util():GetFieldStruct("FT_ENTRADA")[3], FWSX3Util():GetFieldStruct("FT_ENTRADA")[4] },;
    {'FT_ENTRAM'  , "C", 6, 0 },;
    {'FT_QUANT'   , FWSX3Util():GetFieldStruct("FT_QUANT")[2]  , FWSX3Util():GetFieldStruct("FT_QUANT")[3]  , FWSX3Util():GetFieldStruct("FT_QUANT")[4]   },;
    {'FT_TIPO'    , FWSX3Util():GetFieldStruct("FT_TIPO")[2]   , FWSX3Util():GetFieldStruct("FT_TIPO")[3]   , FWSX3Util():GetFieldStruct("FT_TIPO")[4]    },;
    {'FT_TIPOMOV' , FWSX3Util():GetFieldStruct("FT_TIPOMOV")[2], FWSX3Util():GetFieldStruct("FT_TIPOMOV")[3], FWSX3Util():GetFieldStruct("FT_TIPOMOV")[4] },;
    {'FT_CFOP'    , FWSX3Util():GetFieldStruct("FT_CFOP")[2]   , FWSX3Util():GetFieldStruct("FT_CFOP")[3]   , FWSX3Util():GetFieldStruct("FT_CFOP")[4]    },;
    {'FT_CSTICM'  , "C", 2, 0 },;
    {'FT_NFISCAL' , FWSX3Util():GetFieldStruct("FT_NFISCAL")[2], FWSX3Util():GetFieldStruct("FT_NFISCAL")[3], FWSX3Util():GetFieldStruct("FT_NFISCAL")[4] },;
    {'FT_SERIE'   , FWSX3Util():GetFieldStruct("FT_SERIE")[2]  , FWSX3Util():GetFieldStruct("FT_SERIE")[3]  , FWSX3Util():GetFieldStruct("FT_SERIE")[4]   },;
    {'FT_ITEM'    , FWSX3Util():GetFieldStruct("FT_ITEM")[2]   , FWSX3Util():GetFieldStruct("FT_ITEM")[3]   , FWSX3Util():GetFieldStruct("FT_ITEM")[4]    },;
    {'FT_NFORI'   , FWSX3Util():GetFieldStruct("FT_NFORI")[2]  , FWSX3Util():GetFieldStruct("FT_NFORI")[3]  , FWSX3Util():GetFieldStruct("FT_NFORI")[4]   },;
    {'FT_SERORI'  , FWSX3Util():GetFieldStruct("FT_SERORI")[2] , FWSX3Util():GetFieldStruct("FT_SERORI")[3] , FWSX3Util():GetFieldStruct("FT_SERORI")[4]  },;
    {'FT_ITEMORI' , FWSX3Util():GetFieldStruct("FT_ITEMORI")[2], FWSX3Util():GetFieldStruct("FT_ITEMORI")[3], FWSX3Util():GetFieldStruct("FT_ITEMORI")[4] },;
    {'FT_CLIEFOR' , FWSX3Util():GetFieldStruct("FT_CLIEFOR")[2], FWSX3Util():GetFieldStruct("FT_CLIEFOR")[3], FWSX3Util():GetFieldStruct("FT_CLIEFOR")[4] },;
    {'FT_LOJA'    , FWSX3Util():GetFieldStruct("FT_LOJA")[2]   , FWSX3Util():GetFieldStruct("FT_LOJA")[3]   , FWSX3Util():GetFieldStruct("FT_LOJA")[4]    },;
    {'FT_EMISSAO' , FWSX3Util():GetFieldStruct("FT_EMISSAO")[2], FWSX3Util():GetFieldStruct("FT_EMISSAO")[3], FWSX3Util():GetFieldStruct("FT_EMISSAO")[4] },;
    {'FT_PDV'     , FWSX3Util():GetFieldStruct("FT_PDV")[2]    , FWSX3Util():GetFieldStruct("FT_PDV")[3]    , FWSX3Util():GetFieldStruct("FT_PDV")[4]     },;
    {'FT_CLASFIS' , FWSX3Util():GetFieldStruct("FT_CLASFIS")[2], FWSX3Util():GetFieldStruct("FT_CLASFIS")[3], FWSX3Util():GetFieldStruct("FT_CLASFIS")[4] },;
    {'FT_ESPECIE' , FWSX3Util():GetFieldStruct("FT_ESPECIE")[2], FWSX3Util():GetFieldStruct("FT_ESPECIE")[3], FWSX3Util():GetFieldStruct("FT_ESPECIE")[4] },;
    {'FT_CHVNFE'  , FWSX3Util():GetFieldStruct("FT_CHVNFE")[2] , FWSX3Util():GetFieldStruct("FT_CHVNFE")[3] , FWSX3Util():GetFieldStruct("FT_CHVNFE")[4]  },;
    {'FT_VALANTI' , FWSX3Util():GetFieldStruct("FT_VALANTI")[2], FWSX3Util():GetFieldStruct("FT_VALANTI")[3], FWSX3Util():GetFieldStruct("FT_VALANTI")[4] },;
    {'FT_TOTAL'   , FWSX3Util():GetFieldStruct("FT_TOTAL")[2]  , FWSX3Util():GetFieldStruct("FT_TOTAL")[3]  , FWSX3Util():GetFieldStruct("FT_TOTAL")[4]   },;
    {'FT_FRETE'   , FWSX3Util():GetFieldStruct("FT_FRETE")[2]  , FWSX3Util():GetFieldStruct("FT_FRETE")[3]  , FWSX3Util():GetFieldStruct("FT_FRETE")[4]   },;
    {'FT_SEGURO'  , FWSX3Util():GetFieldStruct("FT_SEGURO")[2] , FWSX3Util():GetFieldStruct("FT_SEGURO")[3] , FWSX3Util():GetFieldStruct("FT_SEGURO")[4]  },;
    {'FT_DESPESA' , FWSX3Util():GetFieldStruct("FT_DESPESA")[2], FWSX3Util():GetFieldStruct("FT_DESPESA")[3], FWSX3Util():GetFieldStruct("FT_DESPESA")[4] },;
    {'FT_VALCONT' , FWSX3Util():GetFieldStruct("FT_VALCONT")[2], FWSX3Util():GetFieldStruct("FT_VALCONT")[3], FWSX3Util():GetFieldStruct("FT_VALCONT")[4] },;
    {'FT_BASEICM' , FWSX3Util():GetFieldStruct("FT_BASEICM")[2], FWSX3Util():GetFieldStruct("FT_BASEICM")[3], FWSX3Util():GetFieldStruct("FT_BASEICM")[4] },;
    {'FT_OUTRICM' , FWSX3Util():GetFieldStruct("FT_OUTRICM")[2], FWSX3Util():GetFieldStruct("FT_OUTRICM")[3], FWSX3Util():GetFieldStruct("FT_OUTRICM")[4] },;
    {'FT_ALIQICM' , FWSX3Util():GetFieldStruct("FT_ALIQICM")[2], FWSX3Util():GetFieldStruct("FT_ALIQICM")[3], FWSX3Util():GetFieldStruct("FT_ALIQICM")[4] },;
    {'FT_VALICM'  , FWSX3Util():GetFieldStruct("FT_VALICM")[2] , FWSX3Util():GetFieldStruct("FT_VALICM")[3] , FWSX3Util():GetFieldStruct("FT_VALICM")[4]  },;
    {'FT_BASERET' , FWSX3Util():GetFieldStruct("FT_BASERET")[2], FWSX3Util():GetFieldStruct("FT_BASERET")[3], FWSX3Util():GetFieldStruct("FT_BASERET")[4] },;
    {'FT_ALIQSOL' , FWSX3Util():GetFieldStruct("FT_ALIQSOL")[2], FWSX3Util():GetFieldStruct("FT_ALIQSOL")[3], FWSX3Util():GetFieldStruct("FT_ALIQSOL")[4] },;
    {'FT_ICMSRET' , FWSX3Util():GetFieldStruct("FT_ICMSRET")[2], FWSX3Util():GetFieldStruct("FT_ICMSRET")[3], FWSX3Util():GetFieldStruct("FT_ICMSRET")[4] },;
    {'FT_BASNDES' , FWSX3Util():GetFieldStruct("FT_BASNDES")[2], FWSX3Util():GetFieldStruct("FT_BASNDES")[3], FWSX3Util():GetFieldStruct("FT_BASNDES")[4] },;
    {'FT_ALQNDES' , FWSX3Util():GetFieldStruct("FT_ALQNDES")[2], FWSX3Util():GetFieldStruct("FT_ALQNDES")[3], FWSX3Util():GetFieldStruct("FT_ALQNDES")[4] },;
    {'FT_ICMNDES' , FWSX3Util():GetFieldStruct("FT_ICMNDES")[2], FWSX3Util():GetFieldStruct("FT_ICMNDES")[3], FWSX3Util():GetFieldStruct("FT_ICMNDES")[4] },;
    {'FT_FORMUL'  , FWSX3Util():GetFieldStruct("FT_FORMUL")[2] , FWSX3Util():GetFieldStruct("FT_FORMUL")[3] , FWSX3Util():GetFieldStruct("FT_FORMUL")[4]  },;
    {'FT_MARGEM'  , FWSX3Util():GetFieldStruct("FT_MARGEM")[2] , FWSX3Util():GetFieldStruct("FT_MARGEM")[3] , FWSX3Util():GetFieldStruct("FT_MARGEM")[4]  },;
    {'FT_DATAMOV' , FWSX3Util():GetFieldStruct("FT_ENTRADA")[2], FWSX3Util():GetFieldStruct("FT_ENTRADA")[3], FWSX3Util():GetFieldStruct("FT_ENTRADA")[4] },;
    {'FT_DTCANC'  , FWSX3Util():GetFieldStruct("FT_DTCANC")[2] , FWSX3Util():GetFieldStruct("FT_DTCANC")[3] , FWSX3Util():GetFieldStruct("FT_DTCANC")[4]  },;
    {'FT_ORDEM'   , "C", 1, 0 } }

    oTmpSFT := FWTemporaryTable():New(,aStru1)
    oTmpSFT:AddIndex("IDX1",{"FT_FILIAL","FT_PRODUTO","FT_ENTRADA"})
    oTmpSFT:AddIndex("IDX2",{"FT_CFOP","FT_CSTICM"})
    oTmpSFT:AddIndex("IDX3",{"FT_FILIAL","FT_NFISCAL","FT_SERIE","FT_ITEM","FT_TIPOMOV","FT_CLIEFOR","FT_LOJA"})
    oTmpSFT:AddIndex("IDX4",{"FT_NFISCAL","FT_SERIE","FT_ITEM","FT_TIPOMOV","FT_CLIEFOR","FT_LOJA"})
    oTmpSFT:Create()

Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} IncNewSFT
@Autor Denis Souza

Inclui registros na temporária somente da SFT

@since 02/03/2026
@version 12.1.2510
/*/
//-------------------------------------------------------------------
Static Function IncNewSFT( oTmpSFT, aFilData )

    Local cInto    := ''
    Local cQry     := ''
    Local oExecSFT := Nil
    Local nOrder   := 0

    Default oTmpSFT := Nil
    Default aFilData := {}

    cInto := "INSERT INTO " + oTmpSFT:GetRealName() + " ("
    cInto += "FT_FILIAL,FT_PRODUTO,FT_ENTRADA,FT_ENTRAM,FT_QUANT,FT_TIPO,FT_TIPOMOV,FT_CFOP,FT_CSTICM,FT_NFISCAL,FT_SERIE,FT_ITEM,"
    cInto += "FT_NFORI,FT_SERORI,FT_ITEMORI,FT_CLIEFOR,FT_LOJA,FT_EMISSAO,FT_PDV,FT_CLASFIS,FT_ESPECIE,"
    cInto += "FT_CHVNFE,FT_VALANTI,FT_TOTAL,FT_FRETE,FT_SEGURO,FT_DESPESA,FT_VALCONT,FT_BASEICM,FT_OUTRICM,"
    cInto += "FT_ALIQICM,FT_VALICM,FT_BASERET,FT_ALIQSOL,FT_ICMSRET,FT_BASNDES,FT_ALQNDES,FT_ICMNDES,FT_FORMUL,FT_MARGEM,FT_DATAMOV,FT_DTCANC,FT_ORDEM ) "

    cQry := "SELECT SFT.FT_FILIAL,SFT.FT_PRODUTO,SFT.FT_ENTRADA, SUBSTRING(SFT.FT_ENTRADA,1,6) FT_ENTRAM,"
    cQry += "SFT.FT_QUANT, SFT.FT_TIPO, SFT.FT_TIPOMOV,SFT.FT_CFOP, SUBSTRING(SFT.FT_CLASFIS,2,2) FT_CSTICM,"
    cQry += "SFT.FT_NFISCAL,SFT.FT_SERIE,SFT.FT_ITEM,SFT.FT_NFORI,SFT.FT_SERORI,SFT.FT_ITEMORI,SFT.FT_CLIEFOR,SFT.FT_LOJA,SFT.FT_EMISSAO,SFT.FT_PDV,SFT.FT_CLASFIS,"
    cQry += "SFT.FT_ESPECIE,SFT.FT_CHVNFE,SFT.FT_VALANTI,SFT.FT_TOTAL,SFT.FT_FRETE,SFT.FT_SEGURO,SFT.FT_DESPESA,SFT.FT_VALCONT,SFT.FT_BASEICM,SFT.FT_OUTRICM,"
    cQry += "SFT.FT_ALIQICM,SFT.FT_VALICM,SFT.FT_BASERET,SFT.FT_ALIQSOL,SFT.FT_ICMSRET,SFT.FT_BASNDES,SFT.FT_ALQNDES,SFT.FT_ICMNDES,SFT.FT_FORMUL,SFT.FT_MARGEM,"
    cQry += "CASE SFT.FT_TIPOMOV WHEN 'E' THEN SFT.FT_ENTRADA ELSE SFT.FT_EMISSAO END FT_DATAMOV,FT_DTCANC,"
    cQry += "CASE SFT.FT_TIPOMOV WHEN 'E' THEN CASE SFT.FT_TIPO WHEN 'D' THEN '4' ELSE '1' END ELSE CASE SFT.FT_TIPO WHEN 'D' THEN '2' ELSE '3' END END FT_ORDEM "

    cQry += "FROM " + RetSqlName("SFT") + " SFT WHERE SFT.FT_FILIAL = ? AND SFT.FT_ENTRADA BETWEEN ? AND ? AND "
    cQry += "SFT.FT_QUANT > ? AND SFT.FT_DTCANC = ? AND SFT.D_E_L_E_T_ = ? "

    cQry := ChangeQuery(cQry)
    oExecSFT := FwExecStatement():New((cInto + cQry))
    oExecSFT:SetString( ++nOrder, xFilial("SFT") )
    oExecSFT:SetString( ++nOrder, DtoS(aFilData[1][1]) ) //dDataDe
    oExecSFT:SetString( ++nOrder, DtoS(aFilData[1][2]) ) //dDataAte
    oExecSFT:SetNumeric(++nOrder, 0 )        //FT_QUANT
    oExecSFT:SetString( ++nOrder, space(1) ) //FT_DTCANC
    oExecSFT:SetString( ++nOrder, space(1) ) //SFT.D_E_L_E_T_

    TcSQLExec( oExecSFT:GetFixQuery() )

    If oExecSFT != Nil
        oExecSFT:Destroy()
        FreeObj(oExecSFT)
    EndIf

Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} NewTmpPer
@Autor Denis Souza

Cria temporária do Período

@since 02/03/2026
@version 12.1.2510
/*/
//-------------------------------------------------------------------
Static Function NewTmpPer( aStru1, oTmpPer )

    Local aStru2 := {}

    aStru2 := aClone(aStru1)
    aadd(aStru2, {'FT_CNPJCPF' , FWSX3Util():GetFieldStruct("A1_CGC")[2]    , FWSX3Util():GetFieldStruct("A1_CGC")[3]    , FWSX3Util():GetFieldStruct("A1_CGC")[4]      } )
    aadd(aStru2, {'FT_SIMPNAC' , FWSX3Util():GetFieldStruct("A1_SIMPNAC")[2], FWSX3Util():GetFieldStruct("A1_SIMPNAC")[3], FWSX3Util():GetFieldStruct("A1_SIMPNAC")[4]  } )
    aadd(aStru2, {'FT_EMISORI' , FWSX3Util():GetFieldStruct("F1_DTDIGIT")[2], FWSX3Util():GetFieldStruct("F1_DTDIGIT")[3], FWSX3Util():GetFieldStruct("F1_DTDIGIT")[4]  } )
    aadd(aStru2, {'FT_RESPRET' , "C", 1, 0 })
    aadd(aStru2, {'FT_TGRETAN' , "N", 1, 0 })
    aadd(aStru2, {'FT_BCST'    , FWSX3Util():GetFieldStruct("FT_BASNDES")[2], FWSX3Util():GetFieldStruct("FT_BASNDES")[3], FWSX3Util():GetFieldStruct("FT_BASNDES")[4]  } )
    aadd(aStru2, {'FT_ALQST'   , FWSX3Util():GetFieldStruct("FT_ALQNDES")[2], FWSX3Util():GetFieldStruct("FT_ALQNDES")[3], FWSX3Util():GetFieldStruct("FT_ALQNDES")[4]  } )
    aadd(aStru2, {'FT_VLRST'   , FWSX3Util():GetFieldStruct("FT_ICMNDES")[2], FWSX3Util():GetFieldStruct("FT_ICMNDES")[3], FWSX3Util():GetFieldStruct("FT_ICMNDES")[4]  } )
    aadd(aStru2, {'B1_PICM'    , FWSX3Util():GetFieldStruct("B1_PICM")[2]   , FWSX3Util():GetFieldStruct("B1_PICM")[3]   , FWSX3Util():GetFieldStruct("B1_PICM")[4]     } )
    aadd(aStru2, {'B1_UM'      , FWSX3Util():GetFieldStruct("B1_UM")[2]     , FWSX3Util():GetFieldStruct("B1_UM")[3]     , FWSX3Util():GetFieldStruct("B1_UM")[4]       } )
    aadd(aStru2, {'B1_SEGUM'   , FWSX3Util():GetFieldStruct("B1_SEGUM")[2]  , FWSX3Util():GetFieldStruct("B1_SEGUM")[3]  , FWSX3Util():GetFieldStruct("B1_SEGUM")[4]    } )
    aadd(aStru2, {'B1_CONV'    , FWSX3Util():GetFieldStruct("B1_CONV")[2]   , FWSX3Util():GetFieldStruct("B1_CONV")[3]   , FWSX3Util():GetFieldStruct("B1_CONV")[4]     } )
    aadd(aStru2, {'B1_TIPCONV' , FWSX3Util():GetFieldStruct("B1_TIPCONV")[2], FWSX3Util():GetFieldStruct("B1_TIPCONV")[3], FWSX3Util():GetFieldStruct("B1_TIPCONV")[4]  } )
    aadd(aStru2, {'B1_CRICMST' , FWSX3Util():GetFieldStruct("B1_CRICMST")[2], FWSX3Util():GetFieldStruct("B1_CRICMST")[3], FWSX3Util():GetFieldStruct("B1_CRICMST")[4]  } )
    aadd(aStru2, {'B1_COD'     , FWSX3Util():GetFieldStruct("B1_COD")[2]    , FWSX3Util():GetFieldStruct("B1_COD")[3]    , FWSX3Util():GetFieldStruct("B1_COD")[4]      } )
    aadd(aStru2, {'A1_CGC'     , FWSX3Util():GetFieldStruct("A1_CGC")[2]    , FWSX3Util():GetFieldStruct("A1_CGC")[3]    , FWSX3Util():GetFieldStruct("A1_CGC")[4]      } )
    aadd(aStru2, {'A1_PESSOA'  , FWSX3Util():GetFieldStruct("A1_PESSOA")[2] , FWSX3Util():GetFieldStruct("A1_PESSOA")[3] , FWSX3Util():GetFieldStruct("A1_PESSOA")[4]   } )
    aadd(aStru2, {'A1_TIPO'    , FWSX3Util():GetFieldStruct("A1_TIPO")[2]   , FWSX3Util():GetFieldStruct("A1_TIPO")[3]   , FWSX3Util():GetFieldStruct("A1_TIPO")[4]     } )
    aadd(aStru2, {'A1_SIMPNAC' , FWSX3Util():GetFieldStruct("A1_SIMPNAC")[2], FWSX3Util():GetFieldStruct("A1_SIMPNAC")[3], FWSX3Util():GetFieldStruct("A1_SIMPNAC")[4]  } )
    aadd(aStru2, {'A2_CGC'     , FWSX3Util():GetFieldStruct("A2_CGC")[2]    , FWSX3Util():GetFieldStruct("A2_CGC")[3]    , FWSX3Util():GetFieldStruct("A2_CGC")[4]      } )
    aadd(aStru2, {'A2_SIMPNAC' , FWSX3Util():GetFieldStruct("A2_SIMPNAC")[2], FWSX3Util():GetFieldStruct("A2_SIMPNAC")[3], FWSX3Util():GetFieldStruct("A2_SIMPNAC")[4]  } )
    aadd(aStru2, {'D1_BASEICM' , FWSX3Util():GetFieldStruct("D1_BASEICM")[2], FWSX3Util():GetFieldStruct("D1_BASEICM")[3], FWSX3Util():GetFieldStruct("D1_BASEICM")[4]  } )
    aadd(aStru2, {'D1_PICM'    , FWSX3Util():GetFieldStruct("D1_PICM")[2]   , FWSX3Util():GetFieldStruct("D1_PICM")[3]   , FWSX3Util():GetFieldStruct("D1_PICM")[4]     } )
    aadd(aStru2, {'D1_VALICM'  , FWSX3Util():GetFieldStruct("D1_VALICM")[2] , FWSX3Util():GetFieldStruct("D1_VALICM")[3] , FWSX3Util():GetFieldStruct("D1_VALICM")[4]   } )
    aadd(aStru2, {'D1_NUMSEQ'  , FWSX3Util():GetFieldStruct("D1_NUMSEQ")[2] , FWSX3Util():GetFieldStruct("D1_NUMSEQ")[3] , FWSX3Util():GetFieldStruct("D1_NUMSEQ")[4]   } )
    aadd(aStru2, {'D2_BASEICM' , FWSX3Util():GetFieldStruct("D2_BASEICM")[2], FWSX3Util():GetFieldStruct("D2_BASEICM")[3], FWSX3Util():GetFieldStruct("D2_BASEICM")[4]  } )
    aadd(aStru2, {'D2_PICM'    , FWSX3Util():GetFieldStruct("D2_PICM")[2]   , FWSX3Util():GetFieldStruct("D2_PICM")[3]   , FWSX3Util():GetFieldStruct("D2_PICM")[4]     } )
    aadd(aStru2, {'D2_VALICM'  , FWSX3Util():GetFieldStruct("D2_VALICM")[2] , FWSX3Util():GetFieldStruct("D2_VALICM")[3] , FWSX3Util():GetFieldStruct("D2_VALICM")[4]   } )
    aadd(aStru2, {'F1_DTDIGIT' , FWSX3Util():GetFieldStruct("F1_DTDIGIT")[2], FWSX3Util():GetFieldStruct("F1_DTDIGIT")[3], FWSX3Util():GetFieldStruct("F1_DTDIGIT")[4]  } )
    aadd(aStru2, {'F1_ENTRAM'  , "C", 6, 0 } )

    oTmpPer := FWTemporaryTable():New(/**/,aStru2)
    oTmpPer:AddIndex("IDX1", {"FT_FILIAL","FT_PRODUTO","FT_ENTRADA","FT_TIPO","FT_TIPOMOV","FT_NFORI","FT_SERORI","FT_ITEMORI"})
    oTmpPer:AddIndex("IDX2", {"FT_FILIAL","FT_NFISCAL","FT_SERIE","FT_TIPOMOV","FT_CLIEFOR","FT_LOJA","FT_ITEM","FT_PRODUTO"})
    oTmpPer:AddIndex("IDX3", {"FT_FILIAL","FT_ENTRADA","D1_NUMSEQ"})
    oTmpPer:AddIndex("IDX4", {"FT_FILIAL","FT_DATAMOV","FT_ORDEM" })
    oTmpPer:AddIndex("IDX5", {"FT_FILIAL","FT_PRODUTO","FT_DATAMOV","FT_ORDEM","FT_CLIEFOR","FT_LOJA","FT_NFISCAL","FT_ITEM","FT_SERIE"})
    oTmpPer:AddIndex("IDX6", {"FT_FILIAL","FT_TIPO","B1_CRICMST"})
    oTmpPer:AddIndex("IDX7", {"FT_FILIAL","FT_PRODUTO","FT_ENTRADA","FT_DATAMOV","FT_ORDEM"})
    oTmpPer:Create()

    aSize(aStru2,0)

Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} IncTmpPer
@Autor Denis Souza

Inclui registros na temporária do período (TmpPer) com a SFT já é filtrada e o
join com mais 8 tabelas ((i)SB1\(i)F2W\(i)F3M\(l)SA1\(l)SA2\(l)SF1\(l)SD1\(l)SD2)

@since 02/03/2026
@version 12.1.2510
/*/
//-------------------------------------------------------------------
Static Function IncTmpPer(oTmpSFT, oTmpPer)

    Local cInto    := ''
    Local cQry     := ''
    Local oExecMov := Nil
    Local nOrder   := 0

    cInto := "INSERT INTO " + oTmpPer:GetRealName() + " ( "
    cInto += "FT_FILIAL,FT_PRODUTO,FT_ENTRADA,FT_ENTRAM,FT_QUANT,FT_TIPO,FT_TIPOMOV,FT_CFOP,FT_CSTICM,FT_NFISCAL,FT_SERIE,FT_ITEM,FT_NFORI,"
    cInto += "FT_SERORI,FT_ITEMORI,FT_CLIEFOR,FT_LOJA,FT_EMISSAO,FT_PDV,FT_CLASFIS,FT_ESPECIE,FT_CHVNFE,FT_VALANTI,FT_TOTAL,FT_FRETE,FT_SEGURO,"
    cInto += "FT_DESPESA,FT_VALCONT,FT_BASEICM,FT_OUTRICM,FT_ALIQICM,FT_VALICM,FT_BASERET,FT_ALIQSOL,FT_ICMSRET,FT_BASNDES,FT_ALQNDES,FT_ICMNDES,"
    cInto += "FT_FORMUL,FT_MARGEM,FT_DATAMOV,FT_DTCANC,FT_ORDEM,FT_CNPJCPF,FT_SIMPNAC,FT_EMISORI,FT_RESPRET,FT_TGRETAN,FT_BCST,FT_ALQST,FT_VLRST,"
    cInto += "B1_PICM,B1_UM,B1_SEGUM,B1_CONV,B1_TIPCONV,B1_CRICMST,B1_COD,A1_CGC,A1_PESSOA,A1_TIPO,A1_SIMPNAC,A2_CGC,A2_SIMPNAC,"
    cInto += "D1_BASEICM,D1_PICM,D1_VALICM,D1_NUMSEQ,D2_BASEICM,D2_PICM,D2_VALICM,F1_DTDIGIT,F1_ENTRAM ) "

    cQry := "SELECT SFT.FT_FILIAL,SFT.FT_PRODUTO,SFT.FT_ENTRADA,SFT.FT_ENTRAM,"
    cQry += "SFT.FT_QUANT,SFT.FT_TIPO,SFT.FT_TIPOMOV,SFT.FT_CFOP,SFT.FT_CSTICM,SFT.FT_NFISCAL,SFT.FT_SERIE,SFT.FT_ITEM,SFT.FT_NFORI,"
    cQry += "SFT.FT_SERORI,SFT.FT_ITEMORI,SFT.FT_CLIEFOR,SFT.FT_LOJA,SFT.FT_EMISSAO,SFT.FT_PDV,SFT.FT_CLASFIS,SFT.FT_ESPECIE,SFT.FT_CHVNFE,"
    cQry += "SFT.FT_VALANTI,SFT.FT_TOTAL,SFT.FT_FRETE,FT_SEGURO,SFT.FT_DESPESA, SFT.FT_VALCONT,"
    cQry += "CASE WHEN SFT.FT_BASEICM = 0 AND SFT.FT_OUTRICM > 0 THEN CASE SFT.FT_TIPOMOV WHEN 'E' THEN SD1.D1_BASEICM ELSE SD2.D2_BASEICM END ELSE SFT.FT_BASEICM END FT_BASEICM,SFT.FT_OUTRICM,"
    cQry += "CASE WHEN SFT.FT_BASEICM = 0 AND SFT.FT_OUTRICM > 0 THEN CASE SFT.FT_TIPOMOV WHEN 'E' THEN SD1.D1_PICM ELSE SD2.D2_PICM END ELSE SFT.FT_ALIQICM END FT_ALIQICM,"
    cQry += "CASE WHEN SFT.FT_BASEICM = 0 AND SFT.FT_OUTRICM > 0 THEN CASE SFT.FT_TIPOMOV WHEN 'E' THEN SD1.D1_VALICM ELSE SD2.D2_VALICM END ELSE SFT.FT_VALICM END FT_VALICM,"
    cQry += "SFT.FT_BASERET,SFT.FT_ALIQSOL,SFT.FT_ICMSRET,SFT.FT_BASNDES,SFT.FT_ALQNDES,SFT.FT_ICMNDES,SFT.FT_FORMUL,SFT.FT_MARGEM,SFT.FT_DATAMOV,SFT.FT_DTCANC,SFT.FT_ORDEM,"

    cQry += "CASE WHEN ((SFT.FT_TIPOMOV = 'S' AND SFT.FT_TIPO IN (' ','C','I','N','P','S')) OR (SFT.FT_TIPOMOV = 'E' AND SFT.FT_TIPO IN ('D','B'))) THEN SA1.A1_CGC ELSE SA2.A2_CGC END FT_CNPJCPF,"
    cQry += "CASE WHEN ((SFT.FT_TIPOMOV = 'S' AND SFT.FT_TIPO IN (' ','C','I','N','P','S')) OR (SFT.FT_TIPOMOV = 'E' AND SFT.FT_TIPO IN ('D','B'))) THEN SA1.A1_SIMPNAC ELSE SA2.A2_SIMPNAC END FT_SIMPNAC,"
    cQry += "CASE WHEN SFT.FT_TIPO = 'D' THEN SF1.F1_DTDIGIT ELSE '' END FT_EMISORI,"
    cQry += "CASE WHEN SFT.FT_CSTICM = '60' AND SFT.FT_ICMSRET = 0 THEN '2' ELSE CASE WHEN SFT.FT_VALANTI > 0 THEN '3' ELSE '1' END END FT_RESPRET,"
    cQry += "CASE WHEN SFT.FT_CSTICM = '60' AND SFT.FT_ICMSRET = 0 THEN CASE WHEN SFT.FT_BASNDES > 0 AND SFT.FT_ICMNDES > 0 THEN 1 ELSE 0 END ELSE 0 END FT_TGRETAN,"
    cQry += "CASE WHEN SFT.FT_CSTICM = '60' AND SFT.FT_ICMSRET = 0 THEN SFT.FT_BASNDES ELSE SFT.FT_BASERET END FT_BCST,"
    cQry += "CASE WHEN SFT.FT_CSTICM = '60' AND SFT.FT_ICMSRET = 0 THEN SFT.FT_ALQNDES ELSE SFT.FT_ALIQSOL END FT_ALQST,"
    cQry += "CASE WHEN SFT.FT_CSTICM = '60' AND SFT.FT_ICMSRET = 0 THEN SFT.FT_ICMNDES ELSE SFT.FT_ICMSRET END FT_VLRST,"
    cQry += "B1_PICM,B1_UM,B1_SEGUM,B1_CONV,B1_TIPCONV,B1_CRICMST,B1_COD,A1_CGC,A1_PESSOA,A1_TIPO,A1_SIMPNAC,A2_CGC,A2_SIMPNAC,"
    cQry += "D1_BASEICM,D1_PICM,D1_VALICM,D1_NUMSEQ,D2_BASEICM,D2_PICM,D2_VALICM,F1_DTDIGIT,SUBSTRING(SF1.F1_DTDIGIT,1,6) F1_ENTRAM "

    cQry += "FROM " + oTmpSFT:GetRealName()  + " SFT "

    cQry += "INNER JOIN " + RetSqlName("SB1") + " SB1 ON SB1.B1_FILIAL = ? AND SB1.B1_COD = SFT.FT_PRODUTO AND SB1.D_E_L_E_T_ = ? "

    cQry += "INNER JOIN " + RetSqlName("F2W") + " F2W ON F2W.F2W_FILIAL = ? AND F2W.F2W_CFOP = SFT.FT_CFOP AND F2W.D_E_L_E_T_ = ? "

    cQry += "INNER JOIN " + RetSqlName("F3M") + " F3M ON F3M.F3M_FILIAL = ? AND F3M.F3M_IDF2W = F2W.F2W_IDTAB AND F3M.F3M_CSTICM = SFT.FT_CSTICM AND F3M.D_E_L_E_T_ = ? "

    cQry += "LEFT JOIN " + RetSqlName("SA1") + " SA1 ON SA1.A1_FILIAL = ? AND SA1.A1_COD = SFT.FT_CLIEFOR "
    cQry += "AND SA1.A1_LOJA = SFT.FT_LOJA AND ( (SFT.FT_TIPOMOV = ? AND SFT.FT_TIPO IN (?)) OR (SFT.FT_TIPOMOV = ? AND SFT.FT_TIPO IN (?)) ) AND SA1.D_E_L_E_T_ = ? "

    cQry += "LEFT JOIN " + RetSqlName("SA2") + " SA2 ON SA2.A2_FILIAL = ? AND SA2.A2_COD = SFT.FT_CLIEFOR "
    cQry += "AND SA2.A2_LOJA = SFT.FT_LOJA AND ( (SFT.FT_TIPOMOV = ? AND SFT.FT_TIPO IN (?)) OR (SFT.FT_TIPOMOV = ? AND SFT.FT_TIPO IN (?)) ) AND SA2.D_E_L_E_T_ = ? "

    cQry += "LEFT JOIN " + RetSqlName("SF1") + " SF1 ON SF1.F1_FILIAL = ? AND SF1.F1_DOC = SFT.FT_NFORI AND SF1.F1_SERIE = SFT.FT_SERORI "
    cQry += "AND SF1.F1_FORNECE = SFT.FT_CLIEFOR AND SF1.F1_LOJA = SFT.FT_LOJA AND (SFT.FT_TIPOMOV = ? AND SFT.FT_TIPO = ?) AND SF1.D_E_L_E_T_ = ? "

    cQry += "LEFT JOIN " + RetSqlName("SD1") + " SD1 ON SD1.D1_FILIAL = ? AND SD1.D1_DOC = SFT.FT_NFISCAL AND SD1.D1_SERIE = SFT.FT_SERIE "
    cQry += "AND SD1.D1_FORNECE = SFT.FT_CLIEFOR AND SD1.D1_LOJA = SFT.FT_LOJA AND SD1.D1_COD = SFT.FT_PRODUTO "
    cQry += "AND SD1.D1_ITEM = SFT.FT_ITEM AND SFT.FT_TIPOMOV = ? AND SD1.D_E_L_E_T_ = ? "

    cQry += "LEFT JOIN " + RetSqlName("SD2") + " SD2 ON SD2.D2_FILIAL = ? AND SD2.D2_DOC = SFT.FT_NFISCAL "
    cQry += "AND SD2.D2_SERIE = SFT.FT_SERIE AND SD2.D2_CLIENTE = SFT.FT_CLIEFOR AND SD2.D2_LOJA = SFT.FT_LOJA AND SD2.D2_COD = SFT.FT_PRODUTO "
    cQry += "AND SD2.D2_ITEM = SFT.FT_ITEM AND SFT.FT_TIPOMOV = ? AND SD2.D_E_L_E_T_ = ? "

    nOrder := 0
    cQry := ChangeQuery(cQry)

    oExecMov := FwExecStatement():New((cInto + cQry))
    oExecMov:SetString( ++nOrder, xFilial("SB1") )
    oExecMov:SetString( ++nOrder, space(1) )
    oExecMov:SetString( ++nOrder, xFilial("F2W") )
    oExecMov:SetString( ++nOrder, space(1) )
    oExecMov:SetString( ++nOrder, xFilial("F3M") )
    oExecMov:SetString( ++nOrder, space(1) )
    oExecMov:SetString( ++nOrder, xFilial("SA1") )
    oExecMov:SetString( ++nOrder, 'S' )                         //SFT.FT_TIPOMOV
    oExecMov:SetIn(     ++nOrder, {' ','C','I','N','P','S'} )   //SFT.FT_TIPO NOT IN ('D','B')
    oExecMov:SetString( ++nOrder, 'E' )                         //SFT.FT_TIPOMOV
    oExecMov:SetIn(     ++nOrder, {'D','B'} )                   //SFT.FT_TIPO IN ('D','B')
    oExecMov:SetString( ++nOrder, space(1) )                    //SA1.D_E_L_E_T_
    oExecMov:SetString( ++nOrder, xFilial("SA2") )              
    oExecMov:SetString( ++nOrder, 'E' )                         //FT_TIPOMOV
    oExecMov:SetIn(     ++nOrder, {' ','C','I','N','P','S'} )   //SFT.FT_TIPO NOT IN ('D','B')
    oExecMov:SetString( ++nOrder, 'S' )                         //SFT.FT_TIPOMOV
    oExecMov:SetIn(     ++nOrder, {'D','B'} )                   //SFT.FT_TIPO IN ('D','B')
    oExecMov:SetString( ++nOrder, space(1) )                    //SA2.D_E_L_E_T_
    
    oExecMov:SetString( ++nOrder, xFilial("SF1") )              
    oExecMov:SetString( ++nOrder, 'S' )                         //SFT.FT_TIPOMOV
    oExecMov:SetString( ++nOrder, 'D' )                         //SFT.FT_TIPO
    oExecMov:SetString( ++nOrder, space(1) )
    oExecMov:SetString( ++nOrder, xFilial("SD1") )
    oExecMov:SetString( ++nOrder, 'E' )                         //SFT.FT_TIPOMOV
    oExecMov:SetString( ++nOrder, space(1) )
    oExecMov:SetString( ++nOrder, xFilial("SD2") )
    oExecMov:SetString( ++nOrder, 'S' )                         //SFT.FT_TIPOMOV
    oExecMov:SetString( ++nOrder, space(1) )

    tcSqlExec( oExecMov:GetFixQuery() ) //oExecMov:GetFixQuery()

    If oExecMov != Nil
        oExecMov:Destroy()
        FreeObj(oExecMov)
    EndIf

Return Nil
