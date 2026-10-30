#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "FISA240A.CH"

//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} FISA240A

Rotina de Apuração da ADRC-ST - ARQUIVO DIGITAL DA RECUPERAÇÃO, DO RESSARCIMENTO E DA COMPLEMENTAÇÃO
DO ICMS ST, do Estado do Paraná.
O método de apuração é determinado pelo Decreto nº 3.886 de 21/01/2020 e pela Norma de Procedimento 
Fiscal nº 003/2020, publicado em 28/01/2020.

@author Ulisses P. Oliveira
@since 24/03/2020
@version 1.0
/*/
//--------------------------------------------------------------------------------------------------
Function FISA240A()
    Local aArea     := GetArea()
    Local cIdApur   := ''
    Local cPerApur  := ''
    Local lProcess  := .T.

    If Pergunte("FSA240A",.T.)
        cPerApur := Right(MV_PAR01,4)+Left(MV_PAR01,2)

        //---Verifica a existência de apuração no período selecionado---//
        cIdApur := CheckApur(cPerApur)

        If !Empty(cIdApur)
		    If (ApMsgNoYes(STR0001 + CHR(10) + CHR(13) + STR0002 ) ) //--Apuração já realizada no período selecionado. Deseja fazer o reprocessamento?---//
                If !(DeletApur(cIdApur,cPerApur))
                    MsgStop(STR0012) //---Apuração não pode ser excluída por esta rotina.---//
                    lProcess := .F.
                EndIf
            Else
                lProcess := .F.
            EndIf
        EndIf

        If lProcess
            FwMsgRun(,{|oSay| FISA240APU(oSay,cPerApur)},STR0003,"")   //---Apuração: Recuperação, Ressarcimento e Complementação ICMS ST---//
        EndIf

    EndIf

    RestArea(aArea)
Return


//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} FISA240APU

Rotina de Processamento da Apuração.

@author Ulisses P. Oliveira
@since 24/03/2020
@version 1.0
/*/
//--------------------------------------------------------------------------------------------------
Function FISA240APU(oSay,cPerApur)
    Local cAlias      := GetNextAlias()
    Local cIdApur     := ''
    Local dDataDe     := CtoD('  /  /    ')
    Local dDataAte    := CtoD('  /  /    ')
    Local dDataAtePA  := CtoD('  /  /    ')
    Local cProduto    := ''
    Local nMVICMPAD   := SuperGetMv("MV_ICMPAD",.F.,18)
    Local aAliqEfet   := {}
    Local nAliqInt    := 0
    Local nAliqFec    := 0
    Local nQtdTotAnt  := 0
    Local nQtdPerAnt  := 0
    Local aDocOriApu  := {}
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
    Local cPerRedMVA  := SuperGetMv("MV_PREDMVA",,"12=50;18=70")
    Local aPerRedMVA  := Iif(Empty(cPerRedMVA),{"12=50;18=70"},StrTokArr(cPerRedMVA,';')) //---Percentual da MVA para o cálculo do Ressarcimento na hipótese de Saídas internas destinadas a contribuintes do Simples Nacional---//
    Local cDtIniReCo  := SuperGetMv("MV_INIRECO",,"20/10/2016,20/10/2016,20/10/2016")
    Local aDtIniReCo  := Iif(Empty(cDtIniReCo) .Or. Len(cDtIniReCo) != 32,{"20/10/2016","20/10/2016","20/10/2016"},StrTokArr(cDtIniReCo,',')) //---Data de início: Ressarcimento (CF), Ressarcimento (Outras Hipóteses), Complemento---//
    Local cVAr01      :=  IIF(Valtype(MV_PAR03)=='N',IIF( MV_PAR03 == 1 , '0','1'),'')
    Local cVAr02      :=  ''
    Local cVAr03      :=  IIF(Valtype(MV_PAR04)=='N',IIF( MV_PAR04 == 1 , '0','1'),'')
    Local cVAr04      :=  IIF(Valtype(MV_PAR02)=='N' ,IIF( MV_PAR02 == 1 , '0', IIF(MV_PAR02 ==  2 ,'1','2')),'')
    
    Private lAutomato := Iif(IsBlind(),.T.,.F.)

    If AliasIndic("F1I") .And. AliasIndic("F1L") .And. AliasIndic("F1M") .And. AliasIndic("F2W") .And. AliasIndic("F3M") .And. AliasIndic("F1Z")
		DbSelectArea ("F1I")
		DbSelectArea ("F1L")
		DbSelectArea ("F1M")
		DbSelectArea ("F2W")
		DbSelectArea ("F3M")
		DbSelectArea ("F1Z")

        dDataDe    := StoD(cPerApur+'01')
        dDataAte   := LastDay(dDataDe)
        dDataAtePA := dDataDe-1

        AtualizaMsg(oSay,STR0004) //---Iniciando processamento...---//

        cIdApur := FWUUID("F1I")

        //---Classe responsável pela apuração do movimento---//
        oApuracao := FISA240APURACAO():New(cIdApur,cPerApur,aDtIniReCo,aPerRedMVA,cVAr01,cVAr02,cVAr03,cVAr04)

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

            SELECT SFT.FT_PRODUTO             FT_PRODUTO,
                   SB1.B1_PICM                B1_PICM,
                   SB1.B1_UM                  B1_UM,
                   %Exp:cF2QCampo%            F2Q_RESVSN,
                   ISNULL(SFT_.FT_QUANTOT,0)  UE_QTDTOT, 
                   ISNULL(SFT_.FT_QUANTPA,0)  UE_QTDPA, 
                   CASE 
                       WHEN %Exp:cSubStrBD4% = '60' AND SFT2.FT_ICMSRET = 0 
                       THEN '2'
                       ELSE CASE WHEN SFT2.FT_VALANTI > 0 
					             THEN '3' 
								 ELSE '1' 
						    END 
                   END                        UE_RESRET,
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
                   CASE 
                       WHEN %Exp:cSubStrBD4% = '60' AND SFT2.FT_ICMSRET = 0 
                       THEN SFT2.FT_ICMNDES
                       ELSE SFT2.FT_ICMSRET
                   END                        UE_VLRST,
                   CASE 
                       WHEN %Exp:cSubStrBD4% = '60' AND SFT2.FT_ICMSRET = 0 
                       THEN SFT2.FT_AFCPANT
                       ELSE SFT2.FT_ALFCPST
                   END                        UE_ALQFEC,
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
                   SFT.FT_PRCUNIT             FT_PRCUNIT,
	               SFT.FT_TOTAL               FT_TOTAL,
	               SFT.FT_FRETE               FT_FRETE,
	               SFT.FT_SEGURO              FT_SEGURO,
	               SFT.FT_DESPESA             FT_DESPESA,
	               SFT.FT_DESCONT             FT_DESCONT,
                   SFT.FT_VALCONT             FT_VALCONT,
                   CASE 
                       WHEN %Exp:cSubStrBD% = '60' AND SFT.FT_ICMSRET = 0 
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
                       WHEN %Exp:cSubStrBD% = '60' AND SFT.FT_ICMSRET = 0 
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
                       THEN SFT.FT_AFCPANT
                       ELSE SFT.FT_ALFCPST
                   END                        FT__ALQFEC,
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
                   SFT.FT_MARGEM              FT_MARGEM
            FROM  %table:SFT% SFT INNER JOIN      %table:SB1% SB1  ON (SB1.B1_FILIAL  = %xFilial:SB1% AND SB1.B1_COD     = SFT.FT_PRODUTO  AND SB1.%NotDel%)
                                  INNER JOIN      %table:F2W% F2W  ON (F2W.F2W_FILIAL = %xFilial:F2W% AND F2W.F2W_CFOP   = SFT.FT_CFOP     AND F2W.%NotDel%)
                                  INNER JOIN      %table:F3M% F3M  ON (F3M.F3M_FILIAL = %xFilial:F3M% AND F3M.F3M_IDF2W  = F2W.F2W_IDTAB   AND F3M.F3M_CSTICM = %Exp:cSubStrBD% AND F3M.%NotDel%)
                                  LEFT OUTER JOIN %table:SA1% SA1  ON (SA1.A1_FILIAL  = %xFilial:SA1% AND SA1.A1_COD     = SFT.FT_CLIEFOR  AND SA1.A1_LOJA   = SFT.FT_LOJA      AND ((SFT.FT_TIPOMOV='S' AND SFT.FT_TIPO NOT IN ('D','B')) OR (SFT.FT_TIPOMOV='E' AND SFT.FT_TIPO IN ('D','B')))  AND SA1.%NotDel%)
                                  LEFT OUTER JOIN %table:SA2% SA2  ON (SA2.A2_FILIAL  = %xFilial:SA2% AND SA2.A2_COD     = SFT.FT_CLIEFOR  AND SA2.A2_LOJA   = SFT.FT_LOJA      AND ((SFT.FT_TIPOMOV='E' AND SFT.FT_TIPO NOT IN ('D','B')) OR (SFT.FT_TIPOMOV='S' AND SFT.FT_TIPO IN ('D','B')))  AND SA2.%NotDel%)
                                  LEFT OUTER JOIN %table:SF2% SF21 ON (SF21.F2_FILIAL = %xFilial:SF2% AND SF21.F2_DOC    = SFT.FT_NFISCAL  AND SF21.F2_SERIE = SFT.FT_SERIE     AND SF21.F2_CLIENTE = SFT.FT_CLIEFOR AND SF21.F2_LOJA = SFT.FT_LOJA AND (SFT.FT_TIPOMOV='S' AND SFT.FT_TIPO NOT IN ('D','B')) AND SF21.%NotDel%)
                                  LEFT OUTER JOIN %table:SF2% SF22 ON (SF22.F2_FILIAL = %xFilial:SF2% AND SF22.F2_DOC    = SFT.FT_NFORI    AND SF22.F2_SERIE = SFT.FT_SERORI    AND SF22.F2_CLIENTE = SFT.FT_CLIEFOR AND SF22.F2_LOJA = SFT.FT_LOJA AND (SFT.FT_TIPOMOV='E' AND SFT.FT_TIPO='D')              AND SF22.%NotDel%)
                                  LEFT OUTER JOIN %table:SF1% SF1  ON (SF1.F1_FILIAL  = %xFilial:SF1% AND SF1.F1_DOC     = SFT.FT_NFORI    AND SF1.F1_SERIE  = SFT.FT_SERORI    AND SF1.F1_FORNECE  = SFT.FT_CLIEFOR AND SF1.F1_LOJA  = SFT.FT_LOJA AND (SFT.FT_TIPOMOV='S' AND SFT.FT_TIPO='D')              AND  SF1.%NotDel%)
                                  LEFT OUTER JOIN %table:SD1% SD1  ON (SD1.D1_FILIAL  = %xFilial:SD1% AND SD1.D1_DOC     = SFT.FT_NFISCAL  AND SD1.D1_SERIE  = SFT.FT_SERIE     AND SD1.D1_FORNECE  = SFT.FT_CLIEFOR AND SD1.D1_LOJA  = SFT.FT_LOJA AND SD1.D1_COD = SFT.FT_PRODUTO AND SD1.D1_ITEM = SFT.FT_ITEM AND SFT.FT_TIPOMOV = 'E' AND SD1.%NotDel%)
			                      LEFT OUTER JOIN %table:SD2% SD2  ON (SD2.D2_FILIAL  = %xFilial:SD2% AND SD2.D2_DOC     = SFT.FT_NFISCAL  AND SD2.D2_SERIE  = SFT.FT_SERIE     AND SD2.D2_CLIENTE  = SFT.FT_CLIEFOR AND SD2.D2_LOJA  = SFT.FT_LOJA AND SD2.D2_COD = SFT.FT_PRODUTO AND SD2.D2_ITEM = SFT.FT_ITEM AND SFT.FT_TIPOMOV = 'S' AND SD2.%NotDel%)
                                %Exp:cF2QRelac%
                                  LEFT OUTER JOIN (SELECT SFTS1.FT_FILIAL, 
                                                          SFTS1.FT_PRODUTO, 
                                                          SUM(CASE WHEN SFTS1.FT_ENTRADA <= %Exp:dDataAtePA%
                                                                 THEN CASE SFTS1.FT_TIPO WHEN 'D' THEN SFTS1.FT_QUANT*(-1) ELSE SFTS1.FT_QUANT END 
                                                                 ELSE 0 
                                 							  END) FT_QUANTPA,
                                                          SUM(CASE WHEN SFTS1.FT_TIPOMOV = 'E' AND SFTS1.FT_TIPO NOT IN ('D','B','S','P','I','C') AND SFTS1.FT_NFORI = ' ' AND SFTS1.FT_SERORI = ' ' AND  SFTS1.FT_ITEMORI  = ' '
                                                                   THEN SFTS1.FT_QUANT
                                                                   ELSE 0
                                                              END) FT_QUANTOT,
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
                                                         SFTS1.FT_DTCANC = ''                AND 
                                                         SFTS1.%NOTDEL%
                                                   GROUP BY SFTS1.FT_FILIAL, SFTS1.FT_PRODUTO) SFT_ ON (SFT_.FT_FILIAL = SFT.FT_FILIAL AND SFT_.FT_PRODUTO = SFT.FT_PRODUTO)
                                  LEFT OUTER JOIN %table:SFT% SFT2 ON (SFT2.FT_FILIAL = %Exp:cSFTStrId0% AND SFT2.FT_TIPOMOV = %Exp:cSFTStrId1% AND SFT2.FT_SERIE = %Exp:cSFTStrId2% AND SFT2.FT_NFISCAL = %Exp:cSFTStrId3% AND SFT2.FT_CLIEFOR = %Exp:cSFTStrId4% AND SFT2.FT_LOJA = %Exp:cSFTStrId5% AND SFT2.FT_ITEM = %Exp:cSFTStrId6% AND SFT2.FT_PRODUTO = %Exp:cSFTStrId7% AND SFT2.%NOTDEL%)
                                  LEFT OUTER JOIN %table:CD2% CD2  ON (CD2.CD2_FILIAL  = %xFilial:CD2% AND CD2.CD2_TPMOV = SFT2.FT_TIPOMOV AND CD2.CD2_SERIE = SFT2.FT_SERIE AND CD2.CD2_DOC = SFT2.FT_NFISCAL AND CD2.CD2_CODCLI = '' AND CD2.CD2_LOJCLI = '' AND CD2.CD2_CODFOR = SFT2.FT_CLIEFOR AND CD2.CD2_LOJFOR = SFT2.FT_LOJA AND CD2.CD2_ITEM = SFT2.FT_ITEM AND CD2.CD2_CODPRO = SFT2.FT_PRODUTO AND CD2.CD2_IMP = 'SOL' AND (SFT2.FT_TIPOMOV='E' AND SFT2.FT_TIPO NOT IN ('D','B')) AND CD2.%NotDel%) 
            WHERE SFT.FT_FILIAL   = %xFilial:SFT%      AND
                  SFT.FT_ENTRADA >= %Exp:dDataDe%      AND
                  SFT.FT_ENTRADA <= %Exp:dDataAte%     AND
        	      SFT.FT_TIPO    <> 'S'                AND
                  SFT.FT_DTCANC   = ''                 AND
                  SFT.%NOTDEL%                         AND
                  SB1.B1_CRICMST  = '1'
            ORDER BY SFT.FT_PRODUTO, FT_DATAMOV, FT_ORDEM, FT_CLIEFOR, FT_LOJA, FT_NFISCAL, FT_ITEM, FT_SERIE
        EndSql

        Begin Transaction

            //---Grava registro cabeçalho da apuração (Tabela F1I)---//
            GravaF1I(oApuracao,1)

            AtualizaMsg(oSay,STR0006) //---Processando movimento...---//

            DbSelectArea(cAlias)
            (cAlias)->(DbGoTop())
            While !(cAlias)->(Eof())

                If cProduto != (cAlias)->FT_PRODUTO

                    If !Empty(cProduto)

                        //---Método ApuraProd: Calcula totais do produto nos objetos o1100, o1200, o1300, o1400, o1500 e alimenta o objeto o9000---//
                        oApuracao:ApuraProd(nQtdTotAnt,nQtdPerAnt)

                        //---Grava os totais calculados para o produto (Tabelas F1J / F1K / F1L)---//
                        GravaF1ZL(oApuracao)

                        //---Método ClearProd: Limpa os valores dos objetos o1100 / o1200 / o1300 / o1400 / o1500 a cada produto processado---//
                        oApuracao:ClearProd()

                    EndIf

                    //---Define a alíquota interna do ICMS para o produto---//
                    //---A Norma define que o [Registro 1000 / Campo B10] deve conter a alíquota da mercadoria prevista para as operações internas, incluído o FECOP. Caso a MERCADORIA seja beneficiada com REDUÇÃO DA BASE DE CÁLCULO, adotar a carga tributária efetiva---//
                    //---Como a Norma cita MERCADORIA com redução da BC, entende-se que a carga tributária efetiva (quando houver essa redução de base de cálculo) deverá ser a mesma em todas as operações, e por esse motivo ela será definida com base na última operação de entrada---//
                    //---Caso não seja possível o método acima, ela será definida conforme SPED Fiscal---//
                    aAliqEfet := FISA240ALQ((cAlias)->UE_PREDBC, (cAlias)->UE_BCST, (cAlias)->UE_ALQST) 
                    If Len(aAliqEfet) == 2 .And. aAliqEfet[1] > 0
                        nAliqInt  := aAliqEfet[1]
                        nAliqFec  := (cAlias)->UE_ALQFEC
                    Else
                        nAliqInt := Iif((cAlias)->B1_PICM>0, (cAlias)->B1_PICM, nMVICMPAD)
                        nAliqFec := 0
                    EndIf

                EndIf

                //---Valores apurados para o Documento Fiscal Original, em casos de movimentos de devolução---//
                aDocOriApu := aSize(aDocOriApu,0)
                If (cAlias)->FT_TIPO == 'D'
                    aDocOriApu := PesqApur((cAlias)->FT_TIPOMOV, (cAlias)->FT_NFORI, (cAlias)->FT_SERORI, (cAlias)->FT_ITEMORI, (cAlias)->FT_CLIEFOR, (cAlias)->FT_LOJA, (cAlias)->FT_PRODUTO, cPerApur)
                EndIf

                //---Método SetaMovim: Carrega os dados do movimento para que seja feita sua apuração---//
                oApuracao:SetaMovim((cAlias)->FT_DATAMOV,;                                //---dDataMov   - Data do Movimento
                                    (cAlias)->FT_TIPOMOV,;                                //---cTipoMov   - Tipo do Movimento (E-Entrada / S-Saída)
                                    (cAlias)->FT_TIPO,;                                   //---cTipoDoc   - Tipo do Documento (Normal / Devolução / Complemento)
                                    (cAlias)->FT_PRODUTO,;                                //---cCodProd   - Código do Produto
                                    (cAlias)->A1_TIPO,;                                   //---cTipoPart  - Tipo do Participante (Cliente Final / Revendedor)
                                    (cAlias)->FT_SIMPNAC,;                                //---cPartOptSN - Participante Optante pelo Simples Nacional (1-Sim / 2-Não)
                                    nAliqInt,;                                            //---nAliqInt   - Alíquota Interna do Produto
                                    nAliqFec,;                                            //---nAliqFec   - Alíquota do FECOP do Produto
                                    (cAlias)->FT_CFOP,;                                   //---cCFOP      - CFOP
                                    Right((cAlias)->FT_CLASFIS,2),;                       //---cCST       - CST ICMS
                                    (cAlias)->FT_QUANT,;                                  //---nQtdade    - Quantidade informada no Documento Fiscal
                                    (cAlias)->FT_PRCUNIT,;                                //---nVlrUnit   - Valor Unitário do Item da Nota Fiscal
                                    (cAlias)->FT_TOTAL,;                                  //---nVlrTotPrd - Valor Total do Produto
                                    (cAlias)->FT_FRETE,;                                  //---nVlrFrete  - Valor do Frete
                                    (cAlias)->FT_SEGURO,;                                 //---nVlrSeguro - Valor do Seguro
                                    (cAlias)->FT_DESPESA,;                                //---nVlrDesp   - Valor das Despesas
                                    (cAlias)->FT_DESCONT,;                                //---nVlrDesc   - Valor do Desconto
                                    (cAlias)->FT_VALCONT,;                                //---nVlrTotNf  - Valor Total da Nota Fiscal
                                    (cAlias)->FT_ALIQICM,;                                //---nVlrAICMS  - Alíquota do ICMS
                                    (cAlias)->FT_VALICM,;                                 //---nVlrICMS   - Valor do ICMS
                                    (cAlias)->FT__BCST,;                                  //---nVlrBICMST - Valor da Base de Cálculo do ICMS-ST
                                    (cAlias)->FT__VLRST,;                                 //---nVlrICMSST - Valor do ICMS-ST
                                    (cAlias)->FT_MARGEM,;                                 //---nVlrMVAOp  - MVA da Operação de Entrada
                                    (cAlias)->FT__RESRET,;                                //---cRespRet   - Responsável pela retenção do ICMS-ST (1 – Remetente Direto / 2 – Remetente Indireto / 3 – Próprio declarante )---//
                                    (cAlias)->F2Q_RESVSN,;                                //---cPrdResVSN - Indicador de cálculo de Ressarcimento em caso de saída interna para Optante pelo Simples Nacional (1–Sim / 2–Não)---//
                                    aDocOriApu)                                           //---aDocOriApu - Valores apurados para o Documento Fiscal Original, em casos de movimentos de devolução

                //---Método ApuraMovim: Para Para Entradas: Define o ICMS Suportado / Alimenta objeto o1100                      ---//
                //---                   Para Saídas.......: Define o ICMS Efetivo   / Alimenta objetos o1200, o1300, o1400, o1500---//
                //---                   Carrega os valores apurados no objeto oMovimento                                         ---//
                oApuracao:ApuraMovim()

                //---Grava o movimento apurado (Tabela F1M)---//
                GravaF1M('1',cAlias,oApuracao)

                cProduto   := (cAlias)->FT_PRODUTO
                nQtdTotAnt := (cAlias)->UE_QTDTOT
                nQtdPerAnt := (cAlias)->UE_QTDPA

                (cAlias)->(DbSkip())
            EndDo
            (cAlias)->(DbCloseArea())
            //---FIM Query Principal---//

            AtualizaMsg(oSay,STR0007) //---Movimento processado. Concluindo apuração...---//

            If !Empty(cProduto)

                //---Método ApuraProd: Calcula totais do produto nos objetos o1100, o1200, o1300, o1400, o1500 e alimenta o objeto o9000---//
                oApuracao:ApuraProd(nQtdTotAnt,nQtdPerAnt)

                //---Grava os totais calculados para o produto (Tabelas F1J / F1K / F1L)---//
                GravaF1ZL(oApuracao)

                AtualizaMsg(oSay,STR0008) //---Totalizando apuração...---//

                //---Método ApuraPer: Calcula totais da apuração no objeto o9000.---//
                oApuracao:ApuraPer()

            EndIf

            AtualizaMsg(oSay,STR0009) //---Gravando apuração...---//

            //---Grava totalizadores da apuração (Tabela F1I)---//
            GravaF1I(oApuracao,2)

        End Transaction

        AtualizaMsg(oSay,STR0010) //---Processamento concluído.---//
        MsgInfo(STR0010)          //---Processamento concluído.---//

    EndIf

Return


//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} GravaF1ZL

Função que grava, nas tabelas F1J / F1K / F1L, os totais apurados para o produto.

@author Ulisses P. Oliveira
@since 31/03/2020
@version 1.0
/*/
//--------------------------------------------------------------------------------------------------
Static Function GravaF1ZL(oApuracao)

Local lcpoPrc := F1L->(FieldPos("F1L_PRCMVA")) > 0
    //---Tabela F1Z - Apur Prd. x Ind. Saida - REGISTRO 1200 - Registro totalizador das saídas internas para consumidor final---//
    RecLock('F1Z',.T.)
    F1Z->F1Z_FILIAL := xFilial("F1Z")
    F1Z->F1Z_IDAPUR := oApuracao:GetIdApur()
    F1Z->F1Z_ANOMES := oApuracao:GetAnoMes()
    F1Z->F1Z_PRODUT := oApuracao:o1000:Get1000B03()
    F1Z->F1Z_INDSAI := '12'
    F1Z->F1Z_QTDSAI := oApuracao:o1200:Get1200F02()
    F1Z->F1Z_VTOSAI := oApuracao:o1200:Get1200F03()
    F1Z->F1Z_VCONFE := oApuracao:o1200:Get1200F04()
    F1Z->F1Z_VMABST := oApuracao:o1200:Get1200F05()
    F1Z->F1Z_VMEBST := oApuracao:o1200:Get1200F06()
    F1Z->F1Z_ALIEFE := oApuracao:o1000:Get1000B10()
    F1Z->F1Z_ALIFEC := oApuracao:o1000:Get1000B11()
    F1Z->F1Z_VLRESS := oApuracao:o1200:Get1200F07()
    F1Z->F1Z_VLCOMP := oApuracao:o1200:Get1200F08()
    F1Z->F1Z_VLFRES := oApuracao:o1200:Get1200F09()
    F1Z->F1Z_VLFCOM := oApuracao:o1200:Get1200F10()
    F1Z->(MsUnlock())

    //---Tabela F1Z - Apur Prd. x Ind. Saida - REGISTRO 1300 - Registro totalizador das saídas para outros estados---//
    RecLock('F1Z',.T.)
    F1Z->F1Z_FILIAL := xFilial("F1Z")
    F1Z->F1Z_IDAPUR := oApuracao:GetIdApur()
    F1Z->F1Z_ANOMES := oApuracao:GetAnoMes()
    F1Z->F1Z_PRODUT := oApuracao:o1000:Get1000B03()
    F1Z->F1Z_INDSAI := '13'
    F1Z->F1Z_QTDSAI := oApuracao:o1300:Get1300H02()
    F1Z->F1Z_VTOSAI := oApuracao:o1300:Get1300H03()
    F1Z->F1Z_VCONFE := oApuracao:o1300:Get1300H04()
    F1Z->F1Z_VMABST := oApuracao:o1300:Get1300H05()
    F1Z->F1Z_ALIEFE := oApuracao:o1000:Get1000B10()
    F1Z->F1Z_ALIFEC := oApuracao:o1000:Get1000B11()
    F1Z->F1Z_VLRESS := oApuracao:o1300:Get1300H06()
    F1Z->F1Z_VLFRES := oApuracao:o1300:Get1300H07()
    F1Z->(MsUnlock())

    //---Tabela F1Z - Apur Prd. x Ind. Saida - REGISTRO 1400 - Registro totalizador das saídas internas que trata o art. 119 do RICMS/17---//
    RecLock('F1Z',.T.)
    F1Z->F1Z_FILIAL := xFilial("F1Z")
    F1Z->F1Z_IDAPUR := oApuracao:GetIdApur()
    F1Z->F1Z_ANOMES := oApuracao:GetAnoMes()
    F1Z->F1Z_PRODUT := oApuracao:o1000:Get1000B03()
    F1Z->F1Z_INDSAI := '14'
    F1Z->F1Z_QTDSAI := oApuracao:o1400:Get1400J02()
    F1Z->F1Z_VTOSAI := oApuracao:o1400:Get1400J03()
    F1Z->F1Z_VCONFE := oApuracao:o1400:Get1400J04()
    F1Z->F1Z_ALIEFE := oApuracao:o1000:Get1000B10()
    F1Z->F1Z_ALIFEC := oApuracao:o1000:Get1000B11()
    F1Z->F1Z_VLRESS := oApuracao:o1400:Get1400J05()
    F1Z->(MsUnlock())

    //---Tabela F1Z - Apur Prd. x Ind. Saida - REGISTRO 1500 - Registro totalizador das saídas internas destinadas a contribuinte do Simples Nacional---//
    RecLock('F1Z',.T.)
    F1Z->F1Z_FILIAL := xFilial("F1Z")
    F1Z->F1Z_IDAPUR := oApuracao:GetIdApur()
    F1Z->F1Z_ANOMES := oApuracao:GetAnoMes()
    F1Z->F1Z_PRODUT := oApuracao:o1000:Get1000B03()
    F1Z->F1Z_INDSAI := '15'
    F1Z->F1Z_QTDSAI := oApuracao:o1500:Get1500L02()
    F1Z->F1Z_VCONFE := oApuracao:o1500:Get1500L03()
    F1Z->F1Z_ALIEFE := oApuracao:o1000:Get1000B10()
    F1Z->F1Z_ALIFEC := oApuracao:o1000:Get1000B11()
    F1Z->F1Z_VLRESS := oApuracao:o1500:Get1500L04()
    
    F1Z->(MsUnlock())

    //---Tabela F1L - Apuração Entradas - REGISTRO 1100 – Totalizador das entradas do produto---//
    RecLock('F1L',.T.)
    F1L->F1L_FILIAL := xFilial("F1L")
    F1L->F1L_IDAPUR := oApuracao:GetIdApur()
    F1L->F1L_ANOMES := oApuracao:GetAnoMes()
    F1L->F1L_PRODUT := oApuracao:o1000:Get1000B03()
    F1L->F1L_QTDENT := oApuracao:o1100:Get1100D02()
    F1L->F1L_TOTBST := oApuracao:o1100:Get1100DSB()
    F1L->F1L_VMUBST := oApuracao:o1100:Get1100D04()
    F1L->F1L_TOTSUP := oApuracao:o1100:Get1100D05()
    F1L->F1L_VMUSUP := oApuracao:o1100:Get1100D06()
    F1L->F1L_VMENUN := oApuracao:o1100:Get1100D03()
    If lcpoPrc 
        F1L->F1L_PRCMVA :=   oApuracao:o1100:Get1100DMV()
    EndIf 
 

    F1L->(MsUnlock())

Return


//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} GravaF1M

Função que insere, na tabela F1M, os dados do movimento apurado.
É chamada em duas situações (parâmetro cTipo):

1-De dentro do laço da query de movimento;
2-No método ApuraProd(), quando for necessária a adição de entradas de períodos anteriores;

@author Ulisses P. Oliveira
@since 31/03/2020
@version 1.0
/*/
//--------------------------------------------------------------------------------------------------
Static Function GravaF1M(cTipo,cAlias,oApuracao)
Local lCpoDesp:= F1M->(FieldPos('F1M_VLDESP')) > 0 .and. F1M->(FieldPos('F1M_VLDESC')) > 0

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
        F1M->F1M_PARTIC := (cAlias)->FT_CLIEFOR
        F1M->F1M_LOJA   := (cAlias)->FT_LOJA
        F1M->F1M_CNPJ   := (cAlias)->FT_CNPJCPF
        F1M->F1M_QTDMOV := oApuracao:oMovimento:GetQtdade()
        F1M->F1M_UNIDAD := (cAlias)->B1_UM
        F1M->F1M_FATCON := 1
        F1M->F1M_QTDCON := oApuracao:oMovimento:GetQtdade()
        F1M->F1M_VLUNIT := (cAlias)->FT_PRCUNIT
        If lCpoDesp
            F1M->F1M_VLDESP := (cAlias)->FT_DESPESA
            F1M->F1M_VLDESC := (cAlias)->FT_DESCONT
        Endif
        F1M->F1M_VLRCON := (cAlias)->FT_VALCONT
        F1M->F1M_VLRICM := oApuracao:oMovimento:GetVICMS()
        F1M->F1M_BASIST := oApuracao:oMovimento:GetBICMST()
        F1M->F1M_VLRIST := oApuracao:oMovimento:GetVICMSST()
        F1M->F1M_CODRES := oApuracao:oMovimento:GetRespRet()

        //---Valores apurados para o movimento---//
        F1M->F1M_VLRSUP := oApuracao:oMovimento:GetICMSSu()
        F1M->F1M_INDSAI := oApuracao:oMovimento:GetTpOper()
        F1M->F1M_VLREFE := oApuracao:oMovimento:GetICMEfe()

        F1M->(MsUnlock())
    EndIf

Return

/*/{Protheus.doc} 

Acessar a fun??o GravaF1M para ser utilizada no FISA240B evitando uso de staticcall
@author Bruce Mello
@since 20/03/2023
@version 1.0
/*/
//--------------------------------------------------------------------------------------------------
Function AcessF1M (cTipo,cAlias,oApuracao)
return   GravaF1M(cTipo,cAlias,oApuracao)

//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} GravaF1I

Função que grava, na tabelas F1I, os totalizadores da apuração.

@author Ulisses P. Oliveira
@since 31/03/2020
@version 1.0
/*/
//--------------------------------------------------------------------------------------------------
Static Function GravaF1I(oApuracao,cTipoGrv)
Local lCposReav := F1I->(FieldPOs("F1I_REVOP1")) .and.F1I->(FieldPOs("F1I_REVOP2")) .and. F1I->(FieldPOs("F1I_REVOP3")) .and. F1I->(FieldPOs("F1I_REVOP4"))  

    If cTipoGrv = 1     //--- Parâmetro cTipoGrv = 1 -> Chamada no início do processamento. Insere registro na tabala F1I ---//
        RecLock('F1I',.T.)
        F1I->F1I_FILIAL := xFilial("F1I")
        F1I->F1I_IDAPUR := oApuracao:GetIdApur()
        F1I->F1I_ANOMES := oApuracao:GetAnoMes()
        F1I->F1I_ORIGEM := 'FISA240'
        F1I->(MsUnlock())
    ElseIf cTipoGrv = 2 //--- Parâmetro cTipoGrv = 2 -> Chamada ao fim do processamento. Atualiza totais da tabela F1I ---//
        F1I->(DbSetOrder(2))
        If F1I->(DbSeek(xFilial("F1I")+oApuracao:GetIdApur()))
            RecLock('F1I',.F.)
            F1I->F1I_VLREST := oApuracao:o9000:Get1200F07()
            F1I->F1I_VLCOMP := oApuracao:o9000:Get1200F08()
            F1I->F1I_SDREST := oApuracao:o9000:Get9000X02()
            F1I->F1I_SDCOMP := oApuracao:o9000:Get9000X03()

            F1I->F1I_SDRES1 := oApuracao:o9000:Get9000X04()
            F1I->F1I_SDRES2 := oApuracao:o9000:Get9000X05()
            F1I->F1I_SDRES3 := oApuracao:o9000:Get9000X06()

            F1I->F1I_SDRESS := oApuracao:o9000:Get9000X04() + oApuracao:o9000:Get9000X05() + oApuracao:o9000:Get9000X06()
            F1I->F1I_VLACRE := oApuracao:o9000:GetApCrICM()
            F1I->F1I_VLACOM := oApuracao:o9000:GetApICMCp()

            F1I->F1I_FECRES := oApuracao:o9000:Get9000X07()
            F1I->F1I_FECCMP := oApuracao:o9000:Get9000X08()
            If lCposReav
                F1I->F1I_REVOP1 := oApuracao:cVAr01
                F1I->F1I_REVOP2 := ''
                F1I->F1I_REVOP3 := oApuracao:cVAr03
                F1I->F1I_REVOP4 := oApuracao:cVAr04
            EndIf
            MsUnLock()
        EndIf
    EndIf

Return


//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} CheckApur

Função que verifica a existência de apuração no período selecionado.

@author Ulisses P. Oliveira
@since 31/03/2020
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

Acessar a fun??o CheckApur para ser utilizada no FISA241 evitando uso de staticcall
@author Bruce Mello
@since 20/03/2023
@version 1.0.
/*/
//--------------------------------------------------------------------------------------------------
Function ConfApur (cPerApur)
return   CheckApur(cPerApur)

//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} DeletApur

Função de exclusão da apuração.

@author Ulisses P. Oliveira
@since 31/03/2020
@version 1.0
/*/
//--------------------------------------------------------------------------------------------------
Static Function DeletApur(cIdApur,cPerApur)
    Local cQuery  := ''
    Local lExclui := .T.

    //---Tabela F1I [Apuração]---//
    F1I->(DbSetOrder(2))
    If F1I->(DbSeek(xFilial("F1I")+cIdApur))
        If AllTrim(F1I->F1I_ORIGEM) == 'FISA240'
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
        cQuery := "DELETE FROM " +  RetSqlName('F1Z')  + " WHERE F1Z_FILIAL = " + ValToSql(xFilial('F1Z')) + " AND F1Z_IDAPUR = " + ValToSql(cIdApur)
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
[3] - Valor da Base de Cálculo do ICMS ST do movimento original
[4] - Valor do ICMS Suportado (Entrada) do movimento original
[5] - Valor do ICMS Efetivo (Saída) do movimento original
[6] - Chave do movimento original
[7] - Número do documento fiscal do movimento original
[8] - Item do documento fiscal do movimento original

@author Ulisses P. Oliveira
@since 31/03/2020
@version 1.0
/*/
//--------------------------------------------------------------------------------------------------
Static Function PesqApur(cTipoMov, cDocOri, cSerOri, cItemOri, cCliOri, cLojaOri, cProdOri, cPerApur)
    Local aArea    := GetArea()
    Local cAlias   := GetNextAlias()
    Local aRetorno := {CtoD('  /  /    '),0,0,0,0,'','',''}

    cTipoMov := Iif(cTipoMov == 'E','S','E')

    //--Localiza saída original apurada na tabela F1M, para utilizar os valores informados anteriormente---//
    BeginSql Alias cAlias
        COLUMN F1M_DTMOV AS DATE

        SELECT F1M_DTMOV, F1M_QTDCON, F1M_BASIST, F1M_VLRSUP, F1M_VLREFE, F1M_CHVDOC, F1M_NFISCA, F1M_ITEM
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
        aRetorno := {(cAlias)->F1M_DTMOV, (cAlias)->F1M_QTDCON, (cAlias)->F1M_BASIST, (cAlias)->F1M_VLRSUP, (cAlias)->F1M_VLREFE, (cAlias)->F1M_CHVDOC, (cAlias)->F1M_NFISCA, (cAlias)->F1M_ITEM}
    EndIf
    (cAlias)->(DbCloseArea())

    RestArea(aArea)
Return aRetorno

/*/{Protheus.doc} PesqApur

Acessar a função PesqApur para ser utilizada no FISA240A evitando uso de staticcall
@author Bruce Mello
@since 22/03/2023
@version 1.0
/*/
//--------------------------------------------------------------------------------------------------
Function FsaB240Ap (cTipoMov, cDocOri, cSerOri, cItemOri, cCliOri, cLojaOri, cProdOri, cPerApur)
return   PesqApur(cTipoMov, cDocOri, cSerOri, cItemOri, cCliOri, cLojaOri, cProdOri, cPerApur)


//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} AtualizaMsg

Função que será chamada para atualizar descrição da barra de status

@author Ulisses P. Oliveira
@since 31/03/2020
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
/*/{Protheus.doc} FISA240EXC
Função de exclusão da apuração selecionada, a partir da rotina FISA240C.

@author Ulisses P. Oliveira
@since 31/03/2020
@version 1.0

/*/
//--------------------------------------------------------------------------------------------------
Function FISA240EXC()
    FWExecView(STR0011,"FISA240C",MODEL_OPERATION_DELETE,,{|| DeletApur(F1I->F1I_IDAPUR,F1I->F1I_ANOMES) },,,) //---Excluir---//
Return

//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} FISA240BST

Função que define Base de Cálculo, Alíquota e Valor do ICMS-ST para o Documento Fiscal, além do responsável 
pela retenção do ICMS-ST (1 – Remetente Direto / 2 – Remetente Indireto / 3 – Próprio declarante )

@author Ulisses P. Oliveira
@since 24/03/2020
@version 1.0

/*/
//--------------------------------------------------------------------------------------------------
Function FISA240BST(cAlias)
Local cRespRet   := ' '
Local nVlrBICMST := 0
Local nVlrAICMST := 0
Local nVlrICMSST := 0
Local nAliqFec   := 0
Local aRetorno   := {}

If ((cAlias)->FT_TIPOMOV == "E" .And. (cAlias)->FT_TIPO <> "D") .Or. ((cAlias)->FT_TIPOMOV == "S" .And. (cAlias)->FT_TIPO == "D")
    If (cAlias)->FT_REMTIND
        cRespRet   := '2'
        nVlrBICMST := (cAlias)->FT_BASNDES
        nVlrAICMST := (cAlias)->FT_ALQNDES
        nVlrICMSST := (cAlias)->FT_ICMNDES
        nAliqFec   := (cAlias)->FT_AFCPANT
    ElseIf (cAlias)->FT_VALANTI > 0
        cRespRet   := '3'
        nVlrBICMST := (cAlias)->FT_BASERET
        nVlrAICMST := (cAlias)->FT_ALIQSOL
        nVlrICMSST := (cAlias)->FT_ICMSRET
        nAliqFec   := (cAlias)->FT_ALFCPST
    Else
        cRespRet   := '1'
        nVlrBICMST := (cAlias)->FT_BASERET
        nVlrAICMST := (cAlias)->FT_ALIQSOL
        nVlrICMSST := (cAlias)->FT_ICMSRET
        nAliqFec   := (cAlias)->FT_ALFCPST
    EndIf
EndIf

aRetorno := {cRespRet, nVlrBICMST, nVlrAICMST, nVlrICMSST, nAliqFec}

Return aRetorno


//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} FISA240ALQ

Função que retorna alíquota efetiva e base de cálculo integral em casos de redução de base de cálculo.

@author Ulisses P. Oliveira
@since 31/03/2020
@version 12.1.17
/*/
//--------------------------------------------------------------------------------------------------
Function FISA240ALQ(nPercEfet,nBaseRed,nAliqCheia)
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
