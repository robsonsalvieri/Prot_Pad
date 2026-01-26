#INCLUDE "PROTHEUS.CH"
#INCLUDE "OFAGCA11.CH"

Static nQtdBloco := 500 // Quantidade de SB1 por Bloco de Execução do While
Static PulaLinha := chr(13)+chr(10)

/*/{Protheus.doc} OFAGCA11
	VMI - Carga Inicial V2

	@author Andre Luis Almeida
	@since 10/01/2023
/*/
Function OFAGCA11()
Local nOpcAviso   := 0
Local nQtdTotal   := 0
Local nQtdAtual   := 0
Local cRecAtual   := "0"
Local cQuery      := ""
Local cMsg        := PulaLinha+STR0001+" ( DMS2 / DMS1 / DMS3 / DMS4 )"+PulaLinha+PulaLinha+PulaLinha // Carga Inicial
Local cInterfac   := ""
Local aArquiv     := {}
Private oArHlp    := DMS_ArrayHelper():New()
Private oSqlHlp   := DMS_SqlHelper():New()
Private oUtil     := DMS_Util():New()
Private oVMI      := OFAGVmi():New()
Private oVMIPars  := OFAGVmiParametros():New()
Private dData36At := dDataBase
Private cGrupos   := oVMIPars:todosGrupos() // Retorna TODOS os Grupos (Originais e Paralelos) para serem utilizados nas Querys
//
dData36At := oUtil:RemoveMeses(dData36At, 12) // -12 meses
dData36At := oUtil:RemoveMeses(dData36At, 12) // -24 meses
dData36At := oUtil:RemoveMeses(dData36At, 12) // -36 meses
//
If oVMIPars:FilialValida(cFilAnt)  // só executa para filiais AGCO configuradas
	//
	aAdd(aArquiv,{ oSqlHlp:NoLock("SB1")     , xFilial("SB1") }) // 01 = SB1
	aAdd(aArquiv,{ oSqlHlp:NoLock("SB2")     , xFilial("SB2") }) // 02 = SB2
	If NNR->(FieldPos("NNR_VDADMS")) > 0
		aAdd(aArquiv,{ oSqlHlp:NoLock("NNR") , xFilial("NNR") }) // 03 = NNR
	Else
		aAdd(aArquiv,{ ""                    , ""             }) // 03 = NNR
	EndIf
	aAdd(aArquiv,{ oSqlHlp:NoLock("SF4")     , xFilial("SF4") }) // 04 = SF4
	aAdd(aArquiv,{ oSqlHlp:NoLock("SD1")     , xFilial("SD1") }) // 05 = SD1
	aAdd(aArquiv,{ oSqlHlp:NoLock("VS1")     , xFilial("VS1") }) // 06 = VS1
	aAdd(aArquiv,{ oSqlHlp:NoLock("VS3")     , xFilial("VS3") }) // 07 = VS3
	aAdd(aArquiv,{ oSqlHlp:NoLock("VO1")     , xFilial("VO1") }) // 08 = VO1
	aAdd(aArquiv,{ oSqlHlp:NoLock("VO2")     , xFilial("VO2") }) // 09 = VO2
	aAdd(aArquiv,{ oSqlHlp:NoLock("VO3")     , xFilial("VO3") }) // 10 = VO3
	aAdd(aArquiv,{ oSqlHlp:NoLock("SD2")     , xFilial("SD2") }) // 11 = SD2
	aAdd(aArquiv,{ oSqlHlp:NoLock("SD3")     , xFilial("SD3") }) // 12 = SD3
	//
	oConfig := OFAGCA11Config():New()
	cInterfac := oConfig:GetValue( "INTERFACE" , "" ) // Ultima Interface do arquivo de controle
	cRecAtual := Alltrim(oConfig:GetValue( "NUMERO_ATUAL" , "" )) // Registro atual (RECNO)
	//
	cRecAtual := IIf(cInterfac=="DMS_OK".or.Empty(cRecAtual).or.cRecAtual=="-1","0",cRecAtual)
	cInterfac := IIf(cInterfac=="DMS_OK".or.Empty(cInterfac),"DMS2",cInterfac)
	//
	cQuery := "SELECT COUNT(B1_COD) AS QTD "
	cQuery += "  FROM "+aArquiv[01,1]
	cQuery += " WHERE B1_FILIAL = '"+aArquiv[01,2]+"'"
	cQuery += "   AND B1_GRUPO IN ("+cGrupos+")"
	cQuery += "   AND D_E_L_E_T_ = ' ' "
	nQtdTotal := FM_SQL(cQuery)
	If cInterfac == "DMS2" .and. cRecAtual == "0"
		cMsg += STR0003+": " // Iniciar
		cMsg += Alltrim(Transform(nQtdTotal,"@E 999,999,999,999"))+" "+STR0007 // produtos
		nOpcAviso := Aviso(STR0002+": "+cFilAnt, cMsg , {STR0003 , STR0005 },3) // Filial / Iniciar / Cancelar
		If nOpcAviso == 2
			Return
		EndIf
	Else
		cMsg += "- "+STR0006+" ( DMS2 / DMS1 / DMS3 / DMS4 ): " // Reniciar
		cMsg += Alltrim(Transform(nQtdTotal,"@E 999,999,999,999"))+" "+STR0007+PulaLinha+PulaLinha+PulaLinha // produtos
		cMsg += "- "+STR0008+" ( "+cInterfac+" ): " // Continuar do ponto que parou
		If cInterfac == "DMS1" .or. cInterfac == "DMS2"
			nQtdAtual := FM_SQL(cQuery+" AND R_E_C_N_O_ <= "+cRecAtual)
			cMsg += PulaLinha+"  "+Alltrim(Transform(nQtdAtual+1,"@E 999,999,999,999"))+" "+"de"+" "+Alltrim(Transform(nQtdTotal,"@E 999,999,999,999"))+" "+STR0007 // produtos
		Else
			cMsg += cRecAtual
		EndIf
		nOpcAviso := Aviso(STR0002+": "+cFilAnt, cMsg , { STR0006 , STR0004 , STR0005 },3) // Filial / Reiniciar / Continuar / Cancelar
		If nOpcAviso == 3
			Return
		ElseIf nOpcAviso == 1
			cInterfac := "DMS2"
			cRecAtual := "0"
			nQtdAtual := 0
		EndIf
	EndIf
	oProcExec := MsNewProcess():New({ |lEnd| OFGA11011_Processa( cInterfac , cRecAtual , nQtdTotal , nQtdAtual , aArquiv ) },STR0001,"",.f.) // Carga Inicial
	oProcExec:Activate()
EndIf
Return

/*/{Protheus.doc} OFAGCA11
	VMI - Carga Inicial V2

	@author Andre Luis Almeida
	@since 10/01/2023
/*/
Static Function OFGA11011_Processa( cInterfac , cRecAtual , nQtdTotal , nQtdAtual , aArquiv )
Local cQuery1   := ""
Local cQuery2   := ""
Local cQueryI   := ""
Local cQueryF   := ""
Local cQAux     := ""
Local cQRcNo1   := ""
Local cQRcNo2   := ""
Local cGroup1   := ""
Local cGroup2   := ""
Local cQOrdem   := ""
Local cRecAt1   := ""
Local cRecAt2   := ""
Local cQAlias   := "SQLINI"
Local cQAlAux   := "SQLAUX"
Local aResults  := {}
Local aCods     := {}
Local aRecs     := {}
Local nCntFor   := 0
Local nQtdVezes := 0
Local nRecAtual := 0
Local nRecAt1   := 0
Local nRecAt2   := 0
Local oFilHlp   := DMS_FilialHelper():New()
Local oDMSHlp   := DMS_ArrayHelper():New()
Local cD1_NUMSEQ := ""
Local cD2_NUMSEQ := ""
Local cD3_NUMSEQ := ""
//
SA1->(DbGoTo( oFilHlp:GetCliente(cFilAnt) ))
//
//
oProcExec:SetRegua1(0)
//
cQuery1 := "SELECT B1_COD , R_E_C_N_O_ AS RECSB1 "
cQuery1 += "  FROM "+aArquiv[01,1]
cQuery1 += " WHERE B1_FILIAL = '"+aArquiv[01,2]+"'"
cQuery1 += "   AND B1_GRUPO IN ("+cGrupos+")"
cQuery1 += "   AND D_E_L_E_T_ = ' ' "
cQuery1 += "   AND R_E_C_N_O_ > "
cQOrdem := " ORDER BY R_E_C_N_O_ "
//
oProcExec:IncRegua1(STR0001+" - DMS2" ) // Carga Inicial
If cInterfac == "DMS2"
	AGCA1101_GravaSequencia( "DMS2" , cRecAtual )
	nQtdVezes := int( ( nQtdTotal - nQtdAtual ) / nQtdBloco ) + 1
	oProcExec:SetRegua2(nQtdVezes)
	For nCntFor := 1 to nQtdVezes
		oProcExec:IncRegua2(Transform((nCntFor/nQtdVezes)*100,"@E 999999.99")+" %")
		cQAux := oSqlHlp:TopFunc( cQuery1+cRecAtual+cQOrdem , nQtdBloco )
		aResults := oSqlHlp:GetSelectArray(cQAux,2)
		aCods := oDMSHlp:Map(aResults, { |d| Alltrim(d[1]) })
		aRecs := oDMSHlp:Map(aResults, { |d| d[2] })
		oVMI:Trigger({;
					{'INICIALIZACAO', .T.                           },;
					{'EVENTO'       , oVMI:oVMIMovimentos:DadosPeca },;
					{'ORIGEM'       , "OFAGCA11_IniDMS2"            },;
					{'PECAS'        , aCods                         },;
					{'ARQUIVOS'     , aArquiv                       };
					})
		nRecAtual := aRecs[len(aRecs)]
		cRecAtual := Alltrim(str(nRecAtual))
		AGCA1101_GravaSequencia( "DMS2" , cRecAtual )
	Next
	cInterfac := "DMS1"
	cRecAtual := "0"
	nQtdAtual := 0
	AGCA1101_GravaSequencia( "DMS1" , cRecAtual )
EndIf
//
oProcExec:IncRegua1(STR0001+" - DMS1" ) // Carga Inicial
If cInterfac == "DMS1"
	AGCA1101_GravaSequencia( "DMS1" , cRecAtual )
	nQtdVezes := int( ( nQtdTotal - nQtdAtual ) / nQtdBloco ) + 1
	oProcExec:SetRegua2(nQtdVezes)
	For nCntFor := 1 to nQtdVezes
		oProcExec:IncRegua2(Transform((nCntFor/nQtdVezes)*100,"@E 999999.99")+" %")
		cQAux := oSqlHlp:TopFunc( cQuery1+cRecAtual+cQOrdem , nQtdBloco )
		aResults := oSqlHlp:GetSelectArray(cQAux,2)
		aCods := oDMSHlp:Map(aResults, { |d| Alltrim(d[1]) })
		aRecs := oDMSHlp:Map(aResults, { |d| d[2] })
		oVMI:Trigger({;
					{'INICIALIZACAO', .T.                            },;
					{'EVENTO'       , oVMI:oVMIMovimentos:Inventario },;
					{'ORIGEM'       , "OFAGCA11_IniDMS1"             },;
					{'PECAS'        , aCods                          },;
					{'ARQUIVOS'     , aArquiv                        };
					})
		nRecAtual := aRecs[len(aRecs)]
		cRecAtual := Alltrim(str(nRecAtual))
		AGCA1101_GravaSequencia( "DMS1" , cRecAtual )
	Next
	cInterfac := "DMS3"
	cRecAtual := "0"
	nQtdAtual := 0
	AGCA1101_GravaSequencia( "DMS3" , cRecAtual )
EndIf
//
oProcExec:IncRegua1(STR0001+" - DMS3" ) // Carga Inicial
If cInterfac == "DMS3"
	AGCA1101_GravaSequencia( "DMS3" , cRecAtual )
	//
	cQuery1 := "SELECT SD1.D1_DOC , SD1.D1_SERIE , SD1.D1_FORNECE , SD1.D1_LOJA , MAX(SD1.R_E_C_N_O_) AS RECSD1 "
	cQuery1 += "  FROM " + aArquiv[05,1] // SD1
	cQuery1 += "  JOIN " + aArquiv[01,1] + " ON SB1.B1_FILIAL = '"+aArquiv[01,2]+"' AND SB1.B1_COD = SD1.D1_COD AND SB1.D_E_L_E_T_ = ' ' "
	cQuery1 += "  JOIN " + aArquiv[04,1] + " ON SF4.F4_FILIAL = '"+aArquiv[04,2]+"' AND SF4.F4_CODIGO = SD1.D1_TES AND SF4.F4_OPEMOV = '01' AND SF4.D_E_L_E_T_ =' ' "
	cQuery1 += " WHERE SD1.D1_FILIAL   = '"+aArquiv[05,2]+"' "
	cQuery1 += "   AND SD1.D1_DTDIGIT >= '"+DTOS( dDataBase - 180 )+"' AND SD1.D1_DTDIGIT <= '"+DTOS( dDataBase )+"' "
	cQuery1 += "   AND SD1.D_E_L_E_T_  = ' ' "
	cQuery1 += "   AND SB1.B1_GRUPO IN ("+cGrupos+")"
	cQRcNo1 := "   AND SD1.R_E_C_N_O_ > "
	cGroup1 := " GROUP BY SD1.D1_DOC , SD1.D1_SERIE , SD1.D1_FORNECE , SD1.D1_LOJA "
	cQOrdem := " ORDER BY RECSD1 "
	//
	nQtdTotal := FM_SQL(" SELECT COUNT(*) FROM ("+cQuery1+cGroup1+") TMPCOUNT ")
	nQtdAtual := FM_SQL(" SELECT COUNT(*) FROM ("+cQuery1+cQRcNo1+cRecAtual+cGroup1+") TMPCOUNT ")
	nQtdVezes := int( ( nQtdTotal - nQtdAtual ) / nQtdBloco ) + 1
	//
	oProcExec:SetRegua2(nQtdVezes)
	For nCntFor := 1 to nQtdVezes
		oProcExec:IncRegua2(Transform((nCntFor/nQtdVezes)*100,"@E 999999.99")+" %")
		cQAux := oSqlHlp:TopFunc( cQuery1+cQRcNo1+cRecAtual+cGroup1+cQOrdem , nQtdBloco )
		dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQAux ), cQAlias, .F., .T. )
		Do While !(cQAlias)->(eof())
			oVMI:Trigger({;
						{'INICIALIZACAO', .T.                        },;
						{'EVENTO'       , oVMI:oVMIMovimentos:Pedido },;
						{'ORIGEM'       , "OFAGCA11_IniDMS3"         },;
						{'CODIGO'       , (cQAlias)->D1_DOC + (cQAlias)->D1_SERIE + (cQAlias)->D1_FORNECE + (cQAlias)->D1_LOJA },; // DOC + SERIE + FORNECEDOR + LOJA
						{'ARQUIVOS'     , aArquiv                    };
						})
			nRecAtual := (cQAlias)->RECSD1
			(cQAlias)->(DBSkip())
		EndDo
		(cQAlias)->(dbCloseArea())
		cRecAtual := Alltrim(str(nRecAtual))
		AGCA1101_GravaSequencia( "DMS3" , cRecAtual )
	Next
	cInterfac := "DMS4"
	cRecAtual := "0"
	nQtdAtual := 0
	AGCA1101_GravaSequencia( "DMS4" , cRecAtual )
EndIf
//
cD1_NUMSEQ := FM_SQL("SELECT MAX(D1_NUMSEQ) FROM "+aArquiv[05,1]+" WHERE D1_FILIAL='"+aArquiv[05,2]+"' AND D_E_L_E_T_=' '")
//
oProcExec:IncRegua1(STR0001+" - DMS4" ) // Carga Inicial
If cInterfac == "DMS4"
	AGCA1101_GravaSequencia( "DMS4" , cRecAtual )
	//
	cRecAt1 := "0" // ORCAMENTO ( RECNO VS1 )
	cRecAt2 := "0" // OS ( RECNO VO1 )
	//
	cQueryI := "SELECT NUMORC , NUMOSV , DATAUX , RECAUX FROM ( "
	cQuery1 := "SELECT VS1.VS1_NUMORC AS NUMORC , ' ' AS NUMOSV , MAX(VS1.VS1_DATORC) AS DATAUX , MAX(VS1.R_E_C_N_O_) AS RECAUX "
	cQuery1 += "  FROM " + aArquiv[06,1] // VS1
	cQuery1 += "  JOIN " + aArquiv[07,1] + " ON VS3.VS3_FILIAL = '"+aArquiv[07,2]+"' AND VS3.VS3_NUMORC = VS1.VS1_NUMORC AND VS1.D_E_L_E_T_ = ' ' "
	cQuery1 += "  JOIN " + aArquiv[01,1] + " ON SB1.B1_FILIAL  = '"+aArquiv[01,2]+"' AND SB1.B1_CODITE = VS3.VS3_CODITE AND SB1.B1_GRUPO = VS3.VS3_GRUITE AND SB1.B1_GRUPO IN ("+cGrupos+") AND SB1.D_E_L_E_T_ = ' ' "
	cQuery1 += " WHERE VS1.VS1_FILIAL  = '"+aArquiv[06,2]+"' "
	cQuery1 += "   AND VS1.VS1_DATORC >= '"+DTOS(dData36At)+"' AND VS1.VS1_DATORC <= '"+DTOS(dDataBase)+"' "
	cQuery1 += "   AND VS1.VS1_TIPORC IN ('1','3','P') "
	cQuery1 += "   AND VS1.VS1_STATUS  = 'X' "
	cQuery1 += "   AND VS1.D_E_L_E_T_  = ' ' "
	cQRcNo1 := "   AND VS1.R_E_C_N_O_ > "
	cGroup1 := " GROUP BY VS1.VS1_NUMORC "
	cQuery2 := " UNION "
	cQuery2 += "SELECT ' ' AS NUMORC , VO1.VO1_NUMOSV AS NUMOSV , MAX(VO1.VO1_DATABE) AS DATAUX  , MAX(VO1.R_E_C_N_O_) AS RECAUX "
	cQuery2 += "  FROM " + aArquiv[08,1] // VO1
	cQuery2 += "  JOIN " + aArquiv[09,1] + " ON VO2.VO2_FILIAL = '"+aArquiv[09,2]+"' AND VO2.VO2_NUMOSV = VO1.VO1_NUMOSV AND VO2.D_E_L_E_T_ = ' ' "
	cQuery2 += "  JOIN " + aArquiv[10,1] + " ON VO3.VO3_FILIAL = '"+aArquiv[10,2]+"' AND VO3.VO3_NUMOSV = VO2.VO2_NUMOSV AND VO3.VO3_NOSNUM = VO2.VO2_NOSNUM AND VO3.D_E_L_E_T_ = ' ' "
	cQuery2 += "  JOIN " + aArquiv[01,1] + " ON SB1.B1_FILIAL  = '"+aArquiv[01,2]+"' AND SB1.B1_GRUPO = VO3.VO3_GRUITE AND SB1.B1_CODITE = VO3.VO3_CODITE AND SB1.B1_GRUPO IN ("+cGrupos+") AND SB1.D_E_L_E_T_ = ' ' "
	cQuery2 += " WHERE VO1.VO1_FILIAL  = '"+aArquiv[08,2]+"' "
	cQuery2 += "   AND VO1.VO1_DATABE >= '"+DTOS(dData36At)+"' AND VO1.VO1_DATABE <= '"+DTOS(dDataBase)+"' "
	cQuery2 += "   AND VO1.VO1_TEMFEC  = 'S'"
	cQuery2 += "   AND VO1.D_E_L_E_T_  = ' ' "
	cQRcNo2 := "   AND VO1.R_E_C_N_O_ > "
	cGroup2 := " GROUP BY VO1.VO1_NUMOSV "
	cQueryF += ") TEMP ORDER BY DATAUX , RECAUX "
	//
	nQtdTotal := FM_SQL("SELECT COUNT(*) FROM ("+cQuery1+cGroup1+cQuery2+cGroup2+") TMPCOUNT ")
	nQtdAtual := FM_SQL("SELECT COUNT(*) FROM ("+cQuery1+cQRcNo1+cRecAt1+cGroup1+cQuery2+cQRcNo2+cRecAt2+cGroup2+") TMPCOUNT ")
	nQtdVezes := 1
	//
	oProcExec:SetRegua2(nQtdVezes)
	//
	oProcExec:IncRegua2(Transform((nCntFor/nQtdVezes)*100,"@E 999999.99")+" %")
	cQAux := cQueryI+cQuery1+cQRcNo1+cRecAt1+cGroup1+cQuery2+cQRcNo2+cRecAt2+cGroup2+cQueryF
	dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQAux ), cQAlias, .F., .T. )
	Do While !(cQAlias)->(eof())
		If Empty( (cQAlias)->(NUMORC) )
			oVMI:Trigger({;
						{'INICIALIZACAO', .T.                    },;
						{'EVENTO'       , oVMI:oVMIMovimentos:OS },;
						{'ORIGEM'       , "OFAGCA11_IniDMS4"     },;
						{'NUMERO_OS'    , (cQAlias)->NUMOSV      },;
						{'ARQUIVOS'     , aArquiv                };
						})
			nRecAt1 := (cQAlias)->RECAUX
		Else
			//
			aSeqDev := {}
			// DEVOLUCAO do Cliente para disparar o DMS-4 relacionado ao Orcamento Origem
			cQuery := "SELECT SD1.D1_ITEMORI , SD1.D1_QUANT "
			cQuery += "  FROM "+RetSqlName('VS1')+" VS1 "
			cQuery += "  JOIN "+RetSqlName('SD1')+" SD1 ON SD1.D1_FILORI = VS1.VS1_FILIAL AND SD1.D1_NFORI = VS1.VS1_NUMNFI AND SD1.D1_SERIORI = VS1.VS1_SERNFI AND SD1.D_E_L_E_T_ = ' '"
			cQuery += "  JOIN "+RetSqlName('SF1')+" SF1 ON SF1.F1_FILIAL = SD1.D1_FILIAL AND SF1.F1_DOC = SD1.D1_DOC AND SF1.F1_SERIE = SD1.D1_SERIE AND SF1.F1_FORNECE = SD1.D1_FORNECE AND SF1.F1_LOJA = SD1.D1_LOJA AND SF1.F1_TIPO = 'D' AND SF1.D_E_L_E_T_ = ' '"
			cQuery += " WHERE VS1.VS1_FILIAL = '"+xFilial("VS1")+"' "
			cQuery += "   AND VS1.VS1_NUMORC = '"+(cQAlias)->NUMORC+"' "
			cQuery += "   AND VS1.D_E_L_E_T_ = ' '"
			dbUseArea( .T., "TOPCONN", TcGenQry(,,cQuery),cQAlAux, .F., .T. )
			While !(cQAlAux)->(EOF())
				aAdd(aSeqDev, { val((cQAlAux)->( D1_ITEMORI )) , (cQAlAux)->(D1_QUANT ) } )
				(cQAlAux)->(DbSkip())
			EndDo
			(cQAlAux)->(dbCloseArea())
			DbSelectArea("SF1")
			//
			oVMI:Trigger({;
						{'INICIALIZACAO'   , .T.                           },;
						{'EVENTO'          , oVMI:oVMIMovimentos:Orcamento },;
						{'ORIGEM'          , "OFAGCA11_IniDMS4"            },;
						{'NUMERO_ORCAMENTO', (cQAlias)->NUMORC             },;
						{'ARQUIVOS'        , aArquiv                       },;
						{'SEQ_DEVOLUCAO'   , aSeqDev                       } ;
						})
			nRecAt2 := (cQAlias)->RECAUX
		EndIf
		(cQAlias)->(DBSkip())
	EndDo
	(cQAlias)->(dbCloseArea())
	cRecAt1 := Alltrim(str(nRecAt1))
	cRecAt2 := Alltrim(str(nRecAt2))
	AGCA1101_GravaSequencia( "DMS_OK" , "" )
EndIf
//
cD2_NUMSEQ := FM_SQL("SELECT MAX(D2_NUMSEQ) FROM "+aArquiv[11,1]+" WHERE D2_FILIAL='"+aArquiv[11,2]+"' AND D_E_L_E_T_=' '")
cD3_NUMSEQ := FM_SQL("SELECT MAX(D3_NUMSEQ) FROM "+aArquiv[12,1]+" WHERE D3_FILIAL='"+aArquiv[12,2]+"' AND D_E_L_E_T_=' '")
//
AGCA0101_GravaNumSeq( cD1_NUMSEQ , cD2_NUMSEQ , cD3_NUMSEQ )
//
MsgInfo(STR0009+PulaLinha+PulaLinha+"( DMS2 / DMS1 / DMS3 / DMS4 )",STR0002+": "+cFilAnt) // Carga Inicial Finalizada! / Filial
//
Return

/*/{Protheus.doc} AGCA1101_GravaSequencia
	Grava o INTERFACE da Carga Inicial

	@author Andre Luis Almeida
	@since 26/06/2025
/*/
Function AGCA1101_GravaSequencia( cInterface , cNroAtual )
Local oConfig := OFAGCA11Config():New()
Local jJson := JsonObject():New()
//
jJson["INTERFACE"]    := cInterface
jJson["NUMERO_ATUAL"] := cNroAtual
//
oConfig:Save(jJson)
return .t.

/*/{Protheus.doc} OFAGCA11Config
	Classe principal para tratar os dados SD1/SD2/SD3
	
	@type class
	@author Andre Luis Almeida
	@since 26/06/2025
/*/
Class OFAGCA11Config
	Public Data cCodigo
	Public Data cFilConf
	Data jConfig

	Public Method New() CONSTRUCTOR
	Public Method GetValue()
	Public Method Save()
EndClass

/*/{Protheus.doc} New
	Construtor Simples

	@type method
	@author Andre Luis Almeida
	@since 26/06/2025
/*/
Method New() Class OFAGCA11Config
	::cCodigo  := "OFAGCA11"
	::cFilConf := Padr(cFilAnt,FWSizeFilial()) // Carrega a Filial Logada
	::jConfig  := JsonObject():New()
	dbselectArea("VRN")
	dbSetOrder( 2 ) // Ordem do VRN
	If dbSeek(xFilial("VRN") + ::cFilConf + ::cCodigo)
		::jConfig:FromJson(VRN->VRN_CONFIG)
	Else
		VRN->(reclock("VRN", .T.))
		VRN->VRN_FILIAL := xFilial("VRN")
		VRN->VRN_CODIGO := ::cCodigo
		VRN->VRN_CONFIG := "{}"
		VRN->VRN_FILCON := ::cFilConf
		VRN->(msUnlock())
	EndIf	
Return SELF

/*/{Protheus.doc} GetValue
	retorna o valor contido no json para o parametro passado

	@type method
	@author Andre Luis Almeida
	@since 26/06/2025
 /*/

Method GetValue(cLabel, xDef) Class OFAGCA11Config
if self:jConfig:hasProperty(cLabel)
	return self:jConfig[cLabel]
endif
Return xDef

/*/{Protheus.doc} Save
	salva json com a configuração

	@type method
	@author Andre Luis Almeida
	@since 26/06/2025
/*/
Method Save(jConfig) Class OFAGCA11Config
	dbselectArea("VRN")
	dbSetOrder(2)
	If dbSeek(xFilial("VRN") + self:cFilConf + self:cCodigo)
		reclock("VRN", .F.)
		VRN->VRN_CONFIG := jConfig:toJSON()
		msUnlock()
	EndIf
	self:jConfig := jConfig
Return .t.