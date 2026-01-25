#INCLUDE "FISA802.CH"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "REPORT.CH"
#INCLUDE "TOPCONN.CH"
#INCLUDE "APWIZARD.CH"
#INCLUDE "FILEIO.CH"



Function FISA802()
Private aSize	:= MsAdvSize(.T.)
Private aRotina := MenuDef()
Private cpMarca	:= GetMark()
Private cTpBco:=Upper(Alltrim(TcGetDB()))          
Private cCadastro := Capital(Trim(FwSX2Util():GetX2Name('F0O')))  //DMICAS - Capital(OemToAnsi(STR0001)) 
   Pergunte("FISA802",.F.)         
	dbSelectArea('F0O')
	F0O->(dbSetOrder(1))	
	mBrowse( 6,1,22,75,"F0O",,,,,,/*Fa040Legenda("SE1")*/)
Return


Function F103Gera()
	Local clPerg	:= "FISA802"
	Local clQryTl	:= ""
	Local cSerie	:= ""
	Local cCliFor	:= ""
	Local cLoja		:= ""
	Local cEspecie	:= ""
	Local cConcept	:= ""
	Local cChave    := ""
	Local cIndice   := ""
	Local cTes    	:= ""
	Local cEmissao	:= ""
	Local cDtDigit	:= ""
	Local cDesri	:=""
	Local alCertRet	:= {}
	Local cVar      := Nil
	Local oDlg      := Nil
	Local cTitulo   := STR0002
	Local oOk       := LoadBitmap( GetResources(), "LBOK" )
	Local oNo       := LoadBitmap( GetResources(), "LBNO" )
	Local oChk      := Nil
	local aNfs := {}
	local x   := 0
	Local clQryNCC  := ""
	Local clQryNF   := ""
	Local i := 0
	Local j := 0
	Local clQryTes := ""
	Local Aliq0 := 0
	Local Aliq5 := 0
	Local Aliq10 := 0
	Local aTes := {}
	Local aNF := {}
	Local aNCC := {}
	Local aOrdPg := {}
	Local clQryRetem := ""
	Local clQryParc := ""
	Local clQryNota := ""
	lOCAL TESTE := ""
	Local AliqNF10 := 0
	Local AliqNCC10 := 0
	Local AliqNF0 := 0
	Local AliqNCC0 := 0
	Local AliqNF5 := 0
	Local AliqNCC5 := 0
	Local TotAliq0 := 0
	Local TotAliq5 := 0
	Local TotAliq10 := 0
	Local OrdPagto := ""
	Local nLinha:=0
	Local nX :=0
	Local cItem :=""
	Local cNum :=""

    Local lAuto := IsBlind()
	Local lProc := .F.

	Private dDtIni  := Ctod("//")
	Private dDtFim  := Ctod("//")
	Private cCodIni	:= ""
	Private cLojIni	:= ""
	Private cCodFim	:= ""
	Private cLojFim	:= ""
	Private cDocIni	:= ""
	Private cDocFim	:= ""
	Private cTipTxt   := ""
	Private lChk     := .F.
	Private oLbx := Nil

	lProc :=  Pergunte(clPerg, !lAuto)
	
If lProc .or. lAuto
	dDtIni  	:= MV_PAR01//Data Inicial
	dDtFim  	:= MV_PAR02//Data Final
	cCodIni	:= MV_PAR03//Cli/For Inicial|Fornecedor Inicial
	cLojIni	:= MV_PAR04//Loja Inicial
	cCodFim	:= MV_PAR05//Cli/For Final|Fornecedor Final
	cLojFim	:= MV_PAR06//Loja Final
	cDocIni	:= MV_PAR07//Ordem de Pagamento Inicial
	cDocFim	:= MV_PAR08//OP Final
	
	
	clQryTl    := ""
     
   //+--------------------------------------------+
   //| Seleciona as NFs que podem ser processadas |
   //+--------------------------------------------+
	If cTpBco =="ORACLE"	
		clQryTl := "SELECT DISTINCT ' ' as OK, FE_ORDPAGO, FE_EMISSAO  " 
	ElseIf cTpBco =="POSTGRES"	
		clQryTl := "SELECT DISTINCT ' ' as CHECK, FE_ORDPAGO, FE_EMISSAO  " 
	Else
		clQryTl := "SELECT DISTINCT '' as 'OK', FE_ORDPAGO, FE_EMISSAO  "
	EndIf
	clQryTl += "  FROM " + RetSqlName("SFE") + " SFE "
	clQryTl += " Where 1=1 AND SFE.FE_EMISSAO BETWEEN '" + dtos(dDtIni) + "' AND '" + dtos(dDtFim)+ "'"
	clQryTl += "   AND FE_FILIAL = '"       + xFilial("SFE") + "'"
	clQryTl += "   AND FE_FORNECE BETWEEN '"+cCodIni+"' AND '"+cCodFim+"'"
	clQryTl += "   AND FE_LOJA    BETWEEN '"+cLojIni+"' AND '"+cLojFim+"'"
	clQryTl += "   AND FE_ORDPAGO BETWEEN '"+cDocIni+"' AND '"+cDocFim+"'"
	clQryTl += "   AND SFE.FE_RETENC > 0  "
	clQryTl += "   AND SFE.D_E_L_E_T_ = ' '  "
	clQryTl += "   AND (SFE.FE_TIPO = 'I' OR SFE.FE_TIPO = 'E' OR SFE.FE_TIPO = 'R') "
	If cTpBco $ "ORACLE|POSTGRES"
		clQryTl += "   AND LENGTH(LTRIM(RTRIM(SFE.FE_ORDPAGO)))>0   "
	Else
		clQryTl += "   AND LEN(LTRIM(RTRIM(SFE.FE_ORDPAGO))) > 0 "
	EndIf
	If cTpBco $ "ORACLE|POSTGRES"
		clQryTl += "   AND SFE.FE_ORDPAGO || SFE.FE_SERIE || SFE.FE_NFISCAL || SFE.FE_FORNECE || SFE.FE_LOJA "
	Else
		clQryTl += "   AND SFE.FE_ORDPAGO +SFE.FE_SERIE+SFE.FE_NFISCAL +SFE.FE_FORNECE+SFE.FE_LOJA "      
	EndIf
	If cTpBco $ "ORACLE|POSTGRES"                                       
		clQryTl += "   NOT IN (SELECT F0O_ORDPAG || F0O_SERIER || F0O_NUMNF || F0O_FORNEC  ||  F0O_LOJA FROM " + RetSqlName("F0O") + " ) AND D_E_L_E_T_ <> '*' "
	Else
		clQryTl += "   NOT IN (SELECT F0O_ORDPAG+F0O_SERIER+F0O_NUMNF+F0O_FORNEC + F0O_LOJA FROM " + RetSqlName("F0O") + " WHERE D_E_L_E_T_ <> '*' )"
    EndIf
    //+----------------------------------------+
   //| Carrega o vetor com o retorno do array |
   //+----------------------------------------+
	aOrdPg := QryArray(clQryTl)
	for x:=1 to Len(aOrdPg)
		aOrdPg[x][1] := lAuto // Se for automatizado todas as retenÁıes recuperadas devem ser selecionadas, caso seja manual deixa falso para que o usuario escolha
	Next

    If !lAuto
	//+-----------------------------------------------+
	//| Monta a tela para usuario visualizar consulta |
	//+-----------------------------------------------+
		If Len( aOrdPg ) == 0
			Aviso( cTitulo, STR0003, {"Ok"} )
			Return
		Endif

		DEFINE MSDIALOG oDlg TITLE cTitulo FROM 0,0 TO 240,500 PIXEL
		@ 10,10 LISTBOX oLbx VAR cVar FIELDS HEADER ;
			" ", STR0004, STR0005,STR0006,STR0007,;
			SIZE 230,095 OF oDlg PIXEL ON dblClick(aOrdPg[oLbx:nAt,1] := !aOrdPg[oLbx:nAt,1],oLbx:Refresh())
	
		oLbx:SetArray( aOrdPg )
		oLbx:bLine := {|| {Iif(aOrdPg[oLbx:nAt,1],oOk,oNo),;
			aOrdPg[oLbx:nAt,2],;
			aOrdPg[oLbx:nAt,3],;
			}}

		@ 110,10 CHECKBOX oChk VAR lChk PROMPT STR0008 SIZE 60,007 PIXEL OF oDlg ;
			ON CLICK(aEval(aOrdPg,{|x| x[1]:=lChk}),oLbx:Refresh())

		DEFINE SBUTTON FROM 107,213 TYPE 1 ACTION oDlg:End() ENABLE OF oDlg
		ACTIVATE MSDIALOG oDlg CENTER
    EndIf
   //+-------------------------------------+
   //| Verifica se foram encontradas NFs   |
   //+-------------------------------------+   
	If Len(aOrdPg) > 0
		for i := 1 to (Len(aOrdPg))
			If aOrdPg[i][1] == .T.                         
				If cTpBco =="ORACLE"
					clQryNota := "SELECT DISTINCT '' as OK, FE_NFISCAL, FE_SERIE, FE_ORDPAGO , FE_FORNECE, FE_LOJA, FE_TIPO, "
				ElseIf cTpBco =="POSTGRES"
					clQryNota := "SELECT DISTINCT '' as CHECK, FE_NFISCAL, FE_SERIE, FE_ORDPAGO , FE_FORNECE, FE_LOJA, FE_TIPO, "
				Else
					clQryNota := "SELECT DISTINCT '' as 'OK', FE_NFISCAL, FE_SERIE, FE_ORDPAGO , FE_FORNECE, FE_LOJA, FE_TIPO, "
				EndIf
				clQryNota += "     FE_EMISSAO,SF1.F1_TIPO,FE_NROCERT, D1_ITEM, D1_COD "
				clQryNota += "  FROM " + RetSqlName("SFE") + " SFE "
				clQryNota += "          INNER JOIN " + RetSqlName("SF1") + " SF1 ON (SFE.FE_FORNECE = SF1.F1_FORNECE "
				clQryNota += "               AND SFE.FE_LOJA = SF1.F1_LOJA "
				clQryNota += "            AND SFE.FE_SERIE= SF1.F1_SERIE  "
				clQryNota += "            AND SFE.FE_NFISCAL= SF1.F1_DOC  "
				clQryNota += "            "+fRetFil("SF1","SFE")+" ) "				
				clQryNota += "          INNER JOIN " + RetSqlName("SD1") + " SD1 "
				clQryNota += "         ON ( SD1.D1_DOC = SFE.FE_NFISCAL "
				clQryNota += "         AND SD1.D1_SERIE = SFE.FE_SERIE "
				clQryNota += "         AND SD1.D1_FORNECE = SFE.FE_FORNECE "
				clQryNota += "         AND SD1.D1_LOJA = SFE.FE_LOJA		"	
				clQryNota += "         "+fRetFil("SD1","SFE")+" ) "
				clQryNota += "  Where 1=1 AND FE_ORDPAGO = '" + AllTrim(aOrdPg[i][2]) +"'"
				clQryNota += " AND  SFE.D_E_L_E_T_ = ' ' AND SF1.D_E_L_E_T_ = ' ' "
				clQryNota += " GROUP BY FE_NFISCAL, FE_SERIE, FE_ORDPAGO, FE_FORNECE, FE_LOJA, FE_TIPO, FE_EMISSAO, "
				clQryNota += "    SF1.F1_TIPO, FE_NROCERT, D1_ITEM, D1_COD  "
				clQryNota := ChangeQuery(clQryNota)
				aNfs := QryArray(clQryNota)
               
                If cTpBco=="ORACLE"                                   
			   		clQryNota := "SELECT DISTINCT '' as OK, FE_NFISCAL, FE_SERIE, FE_ORDPAGO , FE_FORNECE, FE_LOJA, FE_TIPO, "
				ElseIf cTpBco == "POSTGRES"                                   
			   		clQryNota := "SELECT DISTINCT '' as CHECK, FE_NFISCAL, FE_SERIE, FE_ORDPAGO , FE_FORNECE, FE_LOJA, FE_TIPO, "
				Else
					clQryNota := "SELECT DISTINCT '' as 'OK', FE_NFISCAL, FE_SERIE, FE_ORDPAGO , FE_FORNECE, FE_LOJA, FE_TIPO, "
			    EndIf
			    
				clQryNota += "    FE_EMISSAO, SD2.D2_NFORI, SD2.D2_SERIORI, SD2.D2_ITEMORI, SD2.D2_QUANT, SD2.D2_TES  "
				clQryNota += "  FROM " + RetSqlName("SFE") + " SFE "
				clQryNota += "          INNER JOIN " + RetSqlName("SF2") +  " SF2 ON (SFE.FE_FORNECE = SF2.F2_CLIENTE "
				clQryNota += "               AND SFE.FE_LOJA = SF2.F2_LOJA  "
				clQryNota += "            AND SFE.FE_SERIE= SF2.F2_SERIE    "
				clQryNota += "            AND SFE.FE_NFISCAL= SF2.F2_DOC    "
				clQryNota += "            "+fRetFil("SFE","SF2")+" ) "
				clQryNota += "           AND  SF2.F2_ESPECIE = 'NCP'        "
				clQryNota += "          INNER JOIN " + RetSqlName("SD2") +  " SD2 ON (SF2.F2_CLIENTE = SD2.D2_CLIENTE "
				clQryNota += "          AND SF2.F2_LOJA = SD2.D2_LOJA       "
				clQryNota += "          AND SF2.F2_SERIE = SD2.D2_SERIE     "
				clQryNota += "          AND SF2.F2_DOC = SD2.D2_DOC         "
				clQryNota += "          AND SF2.F2_FILIAL = SD2.D2_FILIAL)  "   
				
			 	If cTpBco $ "ORACLE|POSTGRES"
					clQryNota += "   AND LENGTH(RTRIM(LTRIM(SD2.D2_NFORI)))>0   "
				Else
					clQryNota += "  AND LEN(RTRIM(LTRIM(SD2.D2_NFORI))) > 0 "
				EndIf
				clQryNota += "  Where 1=1 AND FE_ORDPAGO = '" + AllTrim(aOrdPg[i][2]) +"'"
				clQryNota += " AND  SFE.D_E_L_E_T_ = ' ' AND SF2.D_E_L_E_T_ <> '*' "
              //colocar a especie
       
				clQryNota := ChangeQuery(clQryNota)
				aNcps := QryArray(clQryNota)
      
				//+--------------------------------------+
				//| Processa somente as NFs selecionadas |
				//+--------------------------------------+
				If Len(aNfs) > 0
					DbSelectArea("SD1")
					SD1->(DbSetOrder(1))
					For x:=1 to Len(aNfs)
						cItem := cNum := "" //DMICAS-134
						SD1->(MsSeek(xFilial("SD1")+(aNfs[x][2])+(aNfs[x][3])+(aNfs[x][5])+(aNfs[x][6])))
						While !(SD1->(Eof())) .AND. (SD1->(D1_FILIAL+D1_DOC+D1_SERIE+D1_FORNECE+D1_LOJA) == xFilial("SD1")+aNfs[x][2]+aNfs[x][3]+aNfs[x][5]+aNfs[x][6])
							if SD1->D1_ITEM == aNfs[x][11]
								cTes := SD1->D1_TES
								clQryTes := "SELECT SFB.FB_CPOLVRO FROM " + RetSqlName("SFC")+ " SFC INNER JOIN " + RetSqlName("SFB")+ " SFB "
								clQryTes += "    ON SFC.FC_IMPOSTO = SFB.FB_CODIGO    "
								clQryTes += " WHERE FC_TES = '" + cValToChar(cTes) + "'"
								clQryTes += "   AND SFC.D_E_L_E_T_ = ' ' AND SFB.D_E_L_E_T_ = ' ' "
								clQryTes := ChangeQuery(clQryTes)
								aTES := QryArray(clQryTes)

								cImpostos := ""
								for j := 1 to (Len(aTES))
									/*clQryNCC := "SELECT D2_ALQIMP" + (aTes[j][1]) + " ALIQ, (D2_VALIMP" + (aTes[j][1]) + " + D2_BASIMP" + (aTes[j][1]) + "), "
									clQryNCC += "((SUM(D2_VALIMP" + (aTes[j][1]) + ") * 100) / SUM(D2_TOTAL)) Total_Porc "
									clQryNCC += " FROM " + RetSqlName("SD2")
									clQryNCC += " where D2_DOC = '" + AllTrim(aNfs[x][2]) + "' AND D_E_L_E_T_ <> '*' AND D2_ESPECIE = 'NCP' "
									clQryNCC += " AND D2_CLIENTE = '" + AllTrim(aNfs[x][5]) + "'"
									clQryNCC += " AND D2_SERIE = '"   + AllTrim(aNfs[x][3]) + "'"
									clQryNCC += " AND D2_FILIAL = '"  + xFilial("SD2") + "'"
									clQryNCC += " AND D2_LOJA = '"    + AllTrim(aNfs[x][6]) + "'"
									clQryNCC += " AND D2_ALQIMP" + (aTes[j][1])  +" >0"
									clQryNCC += " GROUP BY D2_ALQIMP" + (aTes[j][1]) + ", D2_VALIMP" + (aTes[j][1]) + ", D2_BASIMP" + (aTes[j][1])
									clQryNCC := ChangeQuery(clQryNCC)
									aNCC     := QryArray(clQryNCC)
							*/
									clQryNF := " SELECT D1_ITEM,D1_ALQIMP" + (aTes[j][1]) + ","
									clQryNF += " D1_BASIMP"+ (aTes[j][1]) +" ,D1_COD,D1_NUMSEQ"
									clQryNF += " FROM " + RetSqlName("SD1") +" SD1"
									clQryNF += " WHERE D1_FILIAL = '"  + xFilial("SD1") + "'"
									clQryNF += " AND D1_DOC = '" + AllTrim(aNfs[x][2]) + "'"
									clQryNF += " AND D1_SERIE = '"   + AllTrim(aNfs[x][3]) + "'"
									clQryNF += " AND D1_FORNECE = '" + AllTrim(aNfs[x][5]) + "'"
									clQryNF += " AND D1_LOJA = '"    + AllTrim(aNfs[x][6]) + "'"
									clQryNF += " AND D1_ITEM ='"  + AllTrim(SD1->D1_ITEM) + "'"
									clQryNF += " AND D1_ALQIMP" + (aTes[j][1])  +" >0"
									clQryNF += " AND D_E_L_E_T_ ='' " //FALTAVA ASPAS FINAL
									clQryNF += " GROUP BY D1_ITEM, D1_ALQIMP" + (aTes[j][1])+ ",D1_BASIMP" + (aTes[j][1])+",D1_COD,D1_NUMSEQ "
									clQryNF := ChangeQuery(clQryNF)
									aNF     := QryArray(clQryNF)
									AliqNF0:=0
									AliqNF5:=0
									AliqNF10:=0
									TotAliq0:=0
									TotAliq5:=0
									TotAliq10:=0
									For nX:=1 to (Len(aNF))
										If Len(aNF)>0
											cItem:=aNF[nx][1]
											cNum :=cItem + aNF[nx][5]
											If aNF[nX][2] == 5
												AliqNF5 :=  aNF[nx][2]
												TotAliq5 := aNF[nx][3]
											ElseIf aNF[nX][2] == 10
												AliqNF10 :=  aNF[nx][2]
												TotAliq10 := aNF[nx][3]
											EndIf
										EndIf
									Next 
									/*
									If Len(aNCC) > 0
										If aNCC[1][1] == 0
											AliqNCC0 += aNCC[1][2]
										ElseIf aNCC[1][1] == 5
											AliqNCC5 += aNCC[1][2]
										ElseIf aNCC[1][1] == 10
											AliqNCC10 += aNCC[1][2]
										EndIf
									EndIf
						*/
								Next
								
								DbSelectArea("F0O")
								F0O->(DbSetOrder(1))
								If !(F0O->(MsSeek(xFilial("F0O")+aNfs[x][4]+aNfs[x][3]+aNfs[x][2]+aNfs[x][5]+aNfs[x][6]+aNfs[x][10]+aNfs[x][7])))    //F0O_FILIAL+F0O_ORDPAG+F0O_SERIER+F0O_NUMNF+F0O_FORNEC+F0O_LOJA+F0O_CERTIF+F0O_TPIMPO	              
									nLinha:=0
									RecLock("F0O",.T.)
									F0O->F0O_FILIAL := xFilial("F0O")
									F0O->F0O_FORNEC := AllTrim(aNfs[x][5])
									F0O->F0O_LOJA   := AllTrim(aNfs[x][6])
									F0O->F0O_SERIER := AllTrim(aNfs[x][3])
									F0O->F0O_NUMNF  := AllTrim(aNfs[x][2])
									F0O->F0O_DTGERA := Date()
									F0O->F0O_HRGERA := Time()
									F0O->F0O_NFISCA := AllTrim(aNfs[x][2])
									F0O->F0O_SERIE  := AllTrim(aNfs[x][3])
									F0O->F0O_DTTRAN := nil
									F0O->F0O_HRTRAN := nil
									F0O->F0O_PROT   := nil
									F0O->F0O_SITNOT := nil
									F0O->F0O_SITU   := nil
									F0O->F0O_DTRESG := AllTrim(aNfs[x][8])
									F0O->F0O_MDDOC  := nil
									F0O->F0O_ORDPAG := AllTrim(aNfs[x][4])
									F0O->F0O_CERTIF := AllTrim(aNfs[x][10])
									F0O->F0O_TPIMPO := AllTrim(aNfs[x][7])	                      
									MsUnLock()
								EndIf

								//DMICAS-134
								If Empty(cItem)
									cItem := SD1->D1_ITEM
									cNum  := SD1->D1_ITEM + SD1->D1_NUMSEQ
								Endif	
								cItem := PadR(cItem, TamSX3("F0P_LINHA")[1], " ") 
								//DMICAS-134

								DbSelectArea("F0P")
								F0P->(DbSetOrder(1)) //F0P_FILIAL, F0P_ORDPAG, F0P_SERIER, F0P_NUMNF, F0P_FORNEC, F0P_LOJA, F0P_LINHA, F0P_IMP
								If !(F0P->(MsSeek(xFilial("F0P") + aNfs[x][4] +aNfs[x][3]+ aNfs[x][2] + aNfs[x][5] +aNfs[x][6] + cItem +aNfs[x][7] ) ))
									RecLock("F0P",.T.)
									nLinha:=  nLinha+1
									F0P->F0P_FILIAL  := xFilial("F0P")
									F0P->F0P_SERIER  := AllTrim(aNfs[x][3])
									F0P->F0P_NUMNF   := AllTrim(aNfs[x][2]) //Numero da Nota -- N√O TIRAR MEXE NO ÕNDICE.
									F0P->F0P_ESPECI  := "NF"
									F0P->F0P_SERIE   := AllTrim(aNfs[x][3])
									F0P->F0P_NUM     := cNum
									F0P->F0P_FORNEC  := AllTrim(aNfs[x][5])
									F0P->F0P_LOJA    := AllTrim(aNfs[x][6])
									F0P->F0P_IMP     := AllTrim(aNfs[x][7])
									F0P->F0P_DTEMDC  := AllTrim(aNfs[x][8])
									F0P->F0P_CODDGI  := nil
									F0P->F0P_TXDOC   := nil
									F0P->F0P_DESCRI  := STR0034 //Producto Alicuota
									F0P->F0P_QUANT   := 1
									F0P->F0P_VALUNI  := SD1->D1_VUNIT      
									If(aNfs[x][7] $ "I" )    
									
										F0P->F0P_TAXA0   := AliqNF0
										F0P->F0P_TAXA5   := AliqNF5
										F0P->F0P_TAXA10  := AliqNF10
										F0P->F0P_ALIQ0   := AliqNF0
										F0P->F0P_ALIQ5   := AliqNF5
										F0P->F0P_ALIQ10  := AliqNF10
										F0P->F0P_BSIMP0  := TotAliq0
										F0P->F0P_BSIMP5  := TotAliq5
										F0P->F0P_BSIMP1  := TotAliq10
									Elseif aNfs[x][7] $ "R"
										aArea := GetArea()
										DbSelectArea("SFE")
										SFE->(DbSetOrder(2))
										SFE->(MsSeek(xFilial("F0P")+ AllTrim(aNfs[x][4]) + aNfs[x][7]))
										F0P->F0P_ALIQIR  := SFE->FE_ALIQ
										SFE->(DbCloseArea())
										RestArea(aArea)
									Else
										F0P->F0P_ALIQIR := 0
									EndIf
									F0P->F0P_ORDPAG  := AllTrim(aNfs[x][4])
									F0P->F0P_LINHA   := cItem								 
									MsUnLock()
								EndIf
							EndIf
							SD1->(DbSkip())
						EndDo
					Next
              
				EndIF //verifica se tem notas na retenÁ„o selecionada
       
       //Nota de credito
      
				If Len(aNcps) > 0
	         
					For x:=1 to Len(aNcps)

						DbSelectArea("F0P")
						F0P->(DbSetOrder(1))
						If (F0P->(MsSeek(xFilial("F0P")+aNcps[x][4]+aNcps[x][10]+aNcps[x][9]+aNcps[x][5]+aNcps[x][6]+aNcps[x][11]))) //F0P_FILIAL+F0P_ORDPAG+F0P_SERIER+F0P_NUMNF+F0P_FORNEC+F0P_LOJA+F0P_LINHA
							                    
							clQryTes := "SELECT SFB.FB_CPOLVRO FROM " + RetSqlName("SFC")+ " SFC INNER JOIN " + RetSqlName("SFB")+ " SFB "
							clQryTes += "    ON SFC.FC_IMPOSTO = SFB.FB_CODIGO    "
							clQryTes += " WHERE FC_TES = '" + cValToChar(cTes) + "'"
							clQryTes += "   AND SFC.D_E_L_E_T_ <> '*' AND SFB.D_E_L_E_T_ <> '*' "
							clQryTes := ChangeQuery(clQryTes)
							aTES := QryArray(clQryTes)
                            
						   DbSelectArea("SD2")
						   SD2->(DbSetOrder(3)) //D2_FILIAL+D2_DOC+D2_SERIE+D2_CLIENTE+D2_LOJA+D2_COD+D2_ITEM
						   RecLock("F0P",.F.)	                            
							For j := 1 to (Len(aTES))
								If SD2->(FieldPos('D2_ALQIMP' + (aTes[j][1])) > 0) .And. &("SD2->D2_ALQIMP" + aTes[j][1]) == 0
									F0P->F0P_BSIMP0  := F0P->F0P_BSIMP0  - &("SD2->D2_BASIMP" + (aTes[j][1]))
								ElseIf SD2->(FieldPos("D2_ALQIMP" + (aTes[j][1])) > 0) .And. &("SD2->D2_ALQIMP" + aTes[j][1]) == 5
									F0P->F0P_BSIMP5  := F0P->F0P_BSIMP5  - &("SD2->D2_BASIMP" + (aTes[j][1]))
								ElseIf SD2->(FieldPos("D2_ALQIMP" + (aTes[j][1])) > 0) .And. &("SD2->D2_ALQIMP" + aTes[j][1]) == 10
									F0P->F0P_BSIMP1  := F0P->F0P_BSIMP1  - &("SD2->D2_BASIMP" + (aTes[j][1]))
								EndIf
							Next
                           
							//F0P->F0P_VALUNI  := F0P->F0P_VALUNI  -  nTotalIt  // ((TabPorc)->(D1_VUNIT))									
							MsUnLock()
	            
						EndIf
						SD2->(DbSkip())
								
						//	EndDo
					Next

          
				EndIF //verifica se tem notas na retenÁ„o selecionada
			EndIf //sÛ processa notas que foram selecionadas
		Next //Enquanto n„o for fim da retenÁ„o
	EndIf  //Se tiver retenÁıes, faÁa...
	EndIf   //if do Pergunte
Return


//-------------------------------------------------------------------------------------
/*/{Protheus.doc} MenuDef
Retorna as opcoes disponiveis para utilizacao na mBrowse

@author  MICROSIGA
@version P10
@since 	 07/01/2014
@return Nil
/*/
//-------------------------------------------------------------------------------------
Static Function MenuDef()                     
Local aRet	:= {	{ STR0009  , "AxPesqui" 	, 0 , 1,,.F. } ,; 		// "Pesquisa"
					{ STR0010  , "F103VISUA" 	, 0 , 2},; 				// "Incluir"
				 	{ STR0011  , "F103Gera" 	, 0 , 3},; 				// "Incluir"				 	
				 	{ STR0012  , "Fi802Tra" 	, 0 , 6},;           // "Transmitir"
				 	{ STR0013  , "Fi802AcN" 	, 0 , 6},;           // "Transmitir"
				 	{ STR0014  , "FI802ANU" 	, 0 , 6}} 				       // "Anular" 							
Return aRet
/*
‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±…ÕÕÕÕÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÀÕÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÀÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÕÕÕª±±
±±∫Programa  ≥Fi802Tra  ∫Autor  ≥Fernando Bastos     ∫ Data ≥  08/01/14   ∫±±
±±ÃÕÕÕÕÕÕÕÕÕÕÿÕÕÕÕÕÕÕÕÕÕ ÕÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕ ÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕπ±±
±±∫Desc.     ≥ Faz a remessa dos resguados eletronicos                	  ∫±±
±±∫          ≥                                                            ∫±±
±±ÃÕÕÕÕÕÕÕÕÕÕÿÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕπ±±
±±∫Uso       ≥ Uruguai                                                    ∫±±
±±»ÕÕÕÕÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕº±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
*/
Function Fi802Tra(cAlias)   

Local aArea       := GetArea()
Local nX          := 0
Local nY          := 0
Local nZ          := 0
Local i       := 0
Local aGerar  := {}
Local aDetails := {}
Local aValBase :={}
Local nAliq5 := 0
Local nAliq10 := 0
Local nValbase5 :=0
Local nValbase10 :=0
Local nValItem5 :=0
Local nValItem10 :=0
Local nRet10 :=0
Local nRet5	:=0
Local cProd5:=""
Local cProd10:=""
Local nHdl    := 0
Local cVirg   := .F.
Local clPergR	:= "FISA8021"
Local lAutomato 	:= IsBlind()
Local lProc			:= .F.
Local nTasCam 	:=0
Local aRetSX5 := {}
Local nGenera	:=1
Local oFwSX1Util
Local aPergunte :={}
//DMICAS
Local cFileTxt := ""
Local cMoeda := ""
Local cPais := ""
Local cRUC := ""
Local cAux := ""
Local aSYF := {}
Local aSYA := {}
//DMICAS
Local cDetalhe  := "{ 'cantidad': <Qtde>, 'tasaAplica': '<Tasa>', 'precioUnitario': <Preco>, 'descripcion': '<Descr>' }"
Local cReten    := " 'retencion': {'fecha': '<Dt_Fecha>', 'moneda': '<moeda>', 'tipoCambio': <TpCambio>, 'retencionRenta': <RetRenta>,  " +;
                   " 'conceptoRenta': '<CtRenta>', 'ivaPorcentaje5': <Iva5>, 'ivaPorcentaje10': <IVA10>, 'rentaCabezasBase': <BsRenta>, " +;
                   " 'rentaCabezasCantidad': <QtRenta>, 'rentaToneladasBase': <TnRenta>, 'rentaToneladasCantidad': <QtRentasT>,         " +;
                   " 'rentaPorcentaje': <PorcRenta>, 'retencionIva': <RetIva>, 'conceptoIva': '<CptoIva>' }, "
Local cInform   := " 'informado': { 'situacion': '<TpPessoa>', 'nombre': '<Nome>', 'ruc': '<Ruc>', 'dv': '<DV>', 'domicilio': '<Ender>'," +;
                   " 'tipoIdentificacion': '<TpIdent>', 'identificacion': '<Ident>', 'direccion': '<Direcao>', 'correoElectronico':     " +;
                   " '<Email>', 'pais': '<Pais>', 'telefono': '<Tel>' }, "     
Local cTransac  := " 'transaccion': { 'numeroComprobanteVenta': '<NumComp>', 'condicionCompra': '<TpCompra>', 'cuotas': <Quotas>,       " +;
                   " 'tipoComprobante': <TpComp>, 'fecha': '<DtFecha>', 'numeroTimbrado': '<NumTimbr>' }, "    
Local cAtrib    := " 'atributos': { 'fechaCreacion': '<FechaCr>', 'fechaHoraCreacion': '<HoraCr>' }} "                                      
Local cLin1:=""                   
Local aDatosD1:={}

If lAutomato
		lProc := .T.
Else
		lProc :=  Pergunte(clPergR,.T.)
EndIf

If lProc 
  oFwSX1Util:= FwSX1Util():New()
  oFwSX1Util:AddGroup(clPergR)
  oFwSX1Util:SearchGroup()
  aPergunte:= oFwSX1Util:GetGroup(clPergR)
  cTipTxt	:="2" //MV_PAR01//Tipo do Relatorio
  If Len(aPergunte[2]) >= 5
		If Empty(MV_PAR04)
			MV_PAR04 := MV_PAR03
		Endif
		nGenera :=MV_PAR05
  ElseIf (Len(aPergunte[2]) >= 4)
  	nGenera :=MV_PAR04
  Endif		
 
  //DMICAS - Ajuste nome do arquivo
  If Empty(MV_PAR01)
 	  MV_PAR01 := "c:\"
  Endif
  If Empty(MV_PAR02)
	  MV_PAR02 := DTOS(Date())+".txt"
  Endif 
  cFileTxt := StrTran(AllTrim(MV_PAR01)+"\"+AllTrim(MV_PAR02),"\\","\")
  If ! ".TXT"$(Upper(cFileTxt))
	  cFileTxt += ".txt"
  Endif
  nHdl := fCreate(cFileTxt)
  //DMICAS	

  If nHdl <= 0
     ApMsgStop(STR0015)
  Else
  
   	
   	cRetencao  := GetNextAlias()
   	cRetenca   := GetNextAlias()   
	
   	clQryTes   := ""
   	clQryParce := ""
   	clQryRete  := ""
	clQryGera  := "" 


   //+--------------------------------------------+
   //| Seleciona as NFs que podem ser geradas     |
   //+--------------------------------------------+
	clQryGera := "SELECT F0O_ORDPAG, F0O_NUMNF, F0O_SERIER, F0O_FORNEC, "
	If cTpBco $ "ORACLE|POSTGRES" 
			clQryGera += " F0O_LOJA, F0O_DTRESG, F0O_TPIMPO                    "
	else
			clQryGera += " F0O_LOJA, F0O_DTRESG, F0O_TPIMPO,*                    "
	endif

	clQryGera += "  FROM " + RetSqlName("F0O") + " F0O            " 
	If cTpBco $ "ORACLE|POSTGRES"                                       
		clQryGera += " WHERE LENGTH(F0O.F0O_DTTRAN) = 0                  "
		clQryGera += " AND LENGTH(F0O.F0O_HRTRAN) = 0                    "
	Else
		clQryGera += " WHERE LEN(F0O.F0O_DTTRAN) = 0                  "
		clQryGera += " AND LEN(F0O.F0O_HRTRAN) = 0                    "
	EndIf
	If Len(aPergunte[2]) >= 5
   	clQryGera += " AND F0O_ORDPAG >= '"+MV_PAR03+"' AND F0O_ORDPAG <= '"+MV_PAR04+"' "
	ElseIf Len(Trim(MV_PAR03)) > 0
    clQryGera += " AND  F0O_ORDPAG     = '" +MV_PAR03 + "'" 
   Else
    clQryGera += " AND  F0O_ORDPAG     <> '' " 
   EndIf
	clQryGera += " AND F0O.D_E_L_E_T_ <> '*'                      "

	
   //+----------------------------------------+
   //| Carrega o vetor com o retorno do array |
   //+----------------------------------------+
   aGerar := QryArray(clQryGera)

   //+-----------------------------------------------+
   //| Monta a tela para usuario visualizar consulta |
   //+-----------------------------------------------+
	 If !lAutomato
			Aviso(STR0016,cFileTxt,{STR0017},2)
      ENDIF
	 for i := 1 to (Len(aGerar))

       clQryRete := " SELECT SF1.F1_MOEDA, CASE WHEN SF1.F1_MOEDA = 1 THEN 'true'             " 
       clQryRete += "                         ELSE 'false'                                    "
	   If cTpBco == "POSTGRES"
	   		clQryRete += "                        END            AS MOEDA,                       "
	   Else
       		clQryRete += "                        END            AS 'MOEDA',                       " 
	   EndIf
	   If cTpBco == "POSTGRES"
	   		clQryRete += "                      SFE.FE_EMISSAO AS Fecha,                         "
	   Else
       		clQryRete += "                      SFE.FE_EMISSAO AS 'Fecha',                         "
	   EndIf
       clQryRete += "                      CASE                                               "
       clQryRete += "                        WHEN FE_TIPO = 'I' THEN 'true'                   " 
       clQryRete += "                          ELSE 'false'                                   "
	   If cTpBco == "POSTGRES"
	   		clQryRete += "                       END            AS RetemIVA,                     " 
	   Else
       		clQryRete += "                       END            AS 'RetemIVA',                     " 
	   EndIf
       clQryRete += "                     CASE                                                "
       clQryRete += "       WHEN FE_TIPO = 'E' OR FE_TIPO = 'R'  THEN 'true'                   " 
	   If cTpBco == "POSTGRES"
	   		clQryRete += "                        ELSE 'false' END AS RetemIR,                   "
	   Else
       		clQryRete += "                        ELSE 'false' END AS 'RetemIR',                   "
	   EndIf
       clQryRete += "  F1_NUMTIM, F1_TIPNOTA, F1_TXMOEDA,EK_TXMOE02,EK_TXMOE03,EK_TXMOE04,EK_TXMOE05 ,    "
       clQryRete += "  FE_PORCRET, FE_NFISCAL,FE_VALBASE,  F1_EMISSAO,                 " //DMICAS
	   clQryRete += "  A2_CGC, A2_NOME, A2_END, A2_EMAIL, A2_PAIS, A2_TEL, A2_TPDOC,A2_INSCR,          "
       clQryRete += "  A2_CLASIR, A2_CLASIVA,                                                 " 
       clQryRete += "  case When (A2_Tipo = 'A' and A2_EST <> 'EX') then 'contribuyente'      "
       clQryRete += "  When (A2_Tipo = 'N' and A2_EST <> 'EX') then 'no contribuyente'        "
       clQryRete += "  When A2_EST = 'EX' then           " //DMICAS-134
	   If cTpBco == "POSTGRES"
	   		clQryRete += "  'NO_RESIDENTE' end as SITU, F0O_DTGERA, F0O_HRGERA ,FE_PARCELA,    "
	   Else
       		clQryRete += "  'NO_RESIDENTE' end as 'SITU', F0O_DTGERA, F0O_HRGERA ,FE_PARCELA,    "
       EndIf
	   clQryRete += "  F0O_TPIMPO "                
       clQryRete += " FROM " + RetSqlName("SFE")+ " SFE                                       " 
       clQryRete += "  INNER JOIN " + RetSqlName("SF1")+ " SF1                                " 
       clQryRete += "       ON ( SFE.FE_NFISCAL = SF1.F1_DOC AND SFE.FE_SERIE = SF1.F1_SERIE  "          
       clQryRete += "         AND SFE.FE_FORNECE = SF1.F1_FORNECE AND SFE.FE_LOJA=SF1.F1_LOJA)                           "
       clQryRete += "  INNER JOIN " + RetSqlName("SA2")+ " SA2                                "
       clQryRete += "       ON (SFE.FE_FORNECE = SA2.A2_COD AND SFE.FE_LOJA=SA2.A2_LOJA)                                  "
	   clQryRete += "  INNER JOIN " + RetSqlName("SEK")+ " SEK                                "
       clQryRete += "       ON (SFE.FE_NFISCAL = SEK.EK_NUM AND SFE.FE_SERIE = SEK.EK_PREFIXO "   
	   clQryRete += "         AND SFE.FE_FORNECE = SEK.EK_FORNECE AND SFE.FE_LOJA=SEK.EK_LOJA AND EK_CANCEL='F' )                           "    
       clQryRete += "  INNER JOIN " + RetSqlName("F0O")+ " F0O                                " 
       clQryRete += "       ON (F0O.F0O_NFISCA = SFE.FE_NFISCAL AND                           " 
       clQryRete += "           F0O.F0O_SERIE  = SFE.FE_SERIE   AND                           "
       clQryRete += "           F0O.F0O_FORNEC = SFE.FE_FORNECE  AND                           "
       clQryRete += "           F0O.F0O_TPIMPO = SFE.FE_TIPO AND SFE.FE_LOJA=F0O.F0O_LOJA)                                  "
       clQryRete += " WHERE SFE.FE_FILIAL     = '" + xFilial("SFE")         + "'" 
       clQryRete += "   AND SFE.FE_ORDPAGO    = '" + AllTrim(aGerar[i][1])  + "'" 
       clQryRete += "   AND SFE.FE_NFISCAL    = '" + AllTrim(aGerar[i][2])  + "'"   
       clQryRete += "   AND SFE.FE_SERIE      = '" + AllTrim(aGerar[i][3])  + "'" 
       clQryRete += "   AND SFE.FE_FORNECE    = '" + AllTrim(aGerar[i][4])  + "'" 
       clQryRete += "   AND F0O.F0O_TPIMPO    = '" + AllTrim(aGerar[i][7])  + "'"  
       If cTpBco $ "ORACLE|POSTGRES"
       		clQryRete += "   AND LENGTH(F0O.F0O_DTTRAN) = 0 AND  LENGTH(F0O.F0O_HRTRAN) = 0                  "        
	   Else
			clQryRete += "   AND (F0O.F0O_DTTRAN) = 0 AND LEN(F0O.F0O_HRTRAN) = 0 "
       EndIf
       
       clQryRete += "   AND (SFE.FE_TIPO = 'I' OR SFE.FE_TIPO = 'R' OR SFE.fe_tipo = 'E')     "
       clQryRete += "   AND SFE.D_E_L_E_T_ = '' AND SF1.D_E_L_E_T_ = ''                   "
       clQryRete += "   AND SA2.D_E_L_E_T_ = '' AND F0O.D_E_L_E_T_ = ''                   "
       clQryRete += "    AND SFE.FE_LOJA =    '" + AllTrim(aGerar[i][5])  + "'"
	   clQryRete += "GROUP BY SF1.F1_MOEDA,                                                "
       clQryRete += "  SFE.FE_EMISSAO,                                                "
       clQryRete += "  FE_TIPO,                                                "
       clQryRete += "  F1_NUMTIM,                                                "
       clQryRete += "  F1_TIPNOTA,                                                "
       clQryRete += "  F1_TXMOEDA,                                                "
       clQryRete += "  EK_TXMOE02,                                                "
       clQryRete += "  EK_TXMOE03,                                                "
       clQryRete += "  EK_TXMOE04,                                                "
       clQryRete += "  EK_TXMOE05,                                                "
       clQryRete += "  FE_PORCRET,                                                "
	   clQryRete += "  FE_VALBASE,                                                "
       clQryRete += "  FE_NFISCAL,                                                "
       clQryRete += "  F1_EMISSAO,                                                " //DMICAS
       clQryRete += "  A2_CGC,                                                "
       clQryRete += "  A2_NOME,                                                "
	   clQryRete += "  A2_INSCR,                                                "
       clQryRete += "  A2_END,                                                "
       clQryRete += "  A2_EMAIL,                                                "
       clQryRete += "  A2_PAIS,                                                "
       clQryRete += "  A2_TEL,                                                "
       clQryRete += "  A2_TPDOC,                                                "
       clQryRete += "  A2_CLASIR,                                                "
       clQryRete += "  A2_CLASIVA,                                                "
       clQryRete += "  A2_TIPO,                                                "
       clQryRete += "  A2_EST,                                                "
       clQryRete += "  F0O_DTGERA,                                                "
       clQryRete += "  F0O_HRGERA,                                                "
       clQryRete += "  FE_PARCELA,                                                "
       clQryRete += "  F0O_TPIMPO                                                "
       clQryRete := ChangeQuery(clQryRete)       
	 
       dbUseArea(.T.,"TOPCONN",TcGenQry(,,clQryRete),cRetencao)    
	 
       TCSetField(cRetencao,"F1_EMISSAO","D",8,0)
       TCSetField(cRetencao,"FE_VALBASE","N",18,2)
       TCSetField(cRetencao,"F1_MOEDA","N",18,2)  
	   TCSetField(cRetencao,"EK_TXMOE02","N",GetSX3Cache("EK_TXMOE02","X3_TAMANHO"),GetSX3Cache("EK_TXMOE02","X3_DECIMAL"))  
	   TCSetField(cRetencao,"EK_TXMOE03","N",GetSX3Cache("EK_TXMOE03","X3_TAMANHO"),GetSX3Cache("EK_TXMOE03","X3_DECIMAL")) 
	   TCSetField(cRetencao,"EK_TXMOE04","N",GetSX3Cache("EK_TXMOE04","X3_TAMANHO"),GetSX3Cache("EK_TXMOE04","X3_DECIMAL")) 
	   TCSetField(cRetencao,"EK_TXMOE05","N",GetSX3Cache("EK_TXMOE05","X3_TAMANHO"),GetSX3Cache("EK_TXMOE05","X3_DECIMAL")) 

       If cTpBco == "POSTGRES"
	   		clQryPar := "SELECT  COUNT(E2_PARCELA)  AS PARCELA, E2_EMISSAO AS EMISSAO, E2_VENCTO  AS VENCIMENTO   "
	   Else
	   		clQryPar := "SELECT  COUNT(E2_PARCELA)  AS 'PARCELA', E2_EMISSAO AS 'EMISSAO', E2_VENCTO  AS 'VENCIMENTO'   "
       EndIf
	   clQryPar += "  FROM " + RetSqlName("SE2")  
       clQryPar += " WHERE  E2_FILIAL =  '" + xFilial("SFE")         + "'"  
       clQryPar += "    AND E2_NUM =     '" + AllTrim(aGerar[i][2])  + "'"   
       clQryPar += "    AND E2_PREFIXO = '" + AllTrim(aGerar[i][3])  + "'" 
       clQryPar += "    AND E2_FORNECE = '" + AllTrim(aGerar[i][4])  + "'"
       clQryPar += "    AND E2_LOJA =    '" + AllTrim(aGerar[i][5])  + "'"
       clQryPar += "    AND D_E_L_E_T_ <> '*' "                                 
       clQryPar +=" GROUP BY E2_EMISSAO,E2_VENCTO"
       clQryPar := ChangeQuery(clQryPar)
       dbUseArea(.T.,"TOPCONN",TcGenQry(,,clQryPar),cRetenca)                        
       
       cVirg   := .F.              
       If cValToChar(cTipTxt) == '2'
		cTabDeta   := GetNextAlias()   
		clQryDeta  := "SELECT F0P_LINHA,F0P_ALIQIR,F0P_QUANT,F0P_ALIQ0,F0P_VALUNI,F0P_DESCRI,F0P_ALIQ5,F0P_ALIQ10," 
		clQryDeta  += " F0P_BSIMP0,F0P_BSIMP5,F0P_BSIMP1 FROM " + RetSqlName("F0P") //" comentado a aspa sobrando
		clQryDeta  += " WHERE F0P_FILIAL = '" + xFilial("F0P")       + "'"         
		clQryDeta  += " AND F0P_ORDPAG = '" + AllTrim(aGerar[i][1])  + "'"   
		clQryDeta  += " AND F0P_NUMNF = '" + AllTrim(aGerar[i][2])  + "'"          
		clQryDeta  += " AND F0P_SERIER = '" + AllTrim(aGerar[i][3])  + "'" 
		clQryDeta  += " AND F0P_FORNEC = '" + AllTrim(aGerar[i][4])  + "'"
		clQryDeta  += " AND F0P_LOJA   = '" + AllTrim(aGerar[i][5])  + "'"  
		clQryDeta  += " AND F0P_IMP   = '" + AllTrim(aGerar[i][7])  + "'"  
		clQryDeta += "    AND D_E_L_E_T_ = '' "                                 
		clQryDeta  := ChangeQuery(clQryDeta)
		aDetails := QryArray(clQryDeta)
		dbUseArea(.T.,"TOPCONN",TcGenQry(,,clQryDeta),cTabDeta)  

		

		Iif(i<=1, CLin := '[ { "detalle": [ ', CLin := ', { "detalle": [ ')
        lVirg := .F.
        cDetalhe1:=""
         
        cReten := STRTRAN(cReten, "<PorcRenta>", AllTrim(Str((cTabDeta)->(F0P_ALIQIR))) )
		For nY:=1 to (Len(aDetails))   
			If  aDetails[nY][7] == 5
				naliq5 := aDetails[nY][7]
				nValItem5 += aDetails[nY][10]
				cProd5 := Alltrim(aDetails[nY][6]) +STR0035 // 5
			ElseIf aDetails[nY][8] == 10
				naliq10 := aDetails[nY][8]
				nValItem10 += aDetails[nY][11]
				cProd10 := Alltrim(aDetails[nY][6]) +STR0036 //10
			EndIf	
		Next 
		If nGenera == 2
			aValBase:=fValbas(aGerar[i][2],aGerar[i][3],aGerar[i][4],aGerar[i][5])
			For nZ:=1 to (Len(aValBase))
				If aValBase[nZ][1] == 5
					nValbase5  :=aValBase[nZ][3]
				ElseIf aValBase[nZ][1] == 10
					nValbase10 :=aValBase[nZ][3]	
				EndIf
			Next
		EndIf	
		
		cReten := IIf(AllTrim(((cRetencao)->(RetemIR))) == 'false', STRTRAN(cReten, "<PorcRenta>", '0'), STRTRAN(cReten, "<PorcRenta>", AllTrim(Str((cTabDeta)->(F0P_ALIQIR)))))  
        If  naliq5 > 0   .And. AllTrim(((cRetencao)->(RetemIVA))) == 'true'
			cDetalhe  := "{ 'cantidad': <Qtde>, 'tasaAplica': '<Tasa>', 'precioUnitario': <Preco>, 'descripcion': '<Descr>' }"
			cDetalhe := STRTRAN(cDetalhe, "<Qtde>",  cValToChar(((cTabDeta)->(F0P_QUANT))))   
			cDetalhe := STRTRAN(cDetalhe, "<Tasa>",  cValToChar(naliq5))
			If (cRetencao)->(F1_MOEDA) == 2
				cDetalhe := STRTRAN(cDetalhe, "<Preco>", IIf (nGenera ==1,cValToChar(nValItem5),cValToChar(xMoeda(nValbase5,1,(cRetencao)->(F1_MOEDA),,2,1,(cRetencao)->EK_TXMOE02))))
			Else
				cDetalhe := STRTRAN(cDetalhe, "<Preco>", IIf (nGenera ==1,cValToChar(nValItem5),cValToChar(nValbase5)))
			EndIf	
			cDetalhe := STRTRAN(cDetalhe, "<Descr>", cProd5) 
			cDetalhe1:= cDetalhe1+cDetalhe
			lVirg := .T.
		EndIf	 
		If  naliq10  > 0   .And. AllTrim(((cRetencao)->(RetemIVA))) == 'true'
			If lVirg
				cDetalhe1:= cDetalhe1+ ","
			EndIf
			cDetalhe  := "{ 'cantidad': <Qtde>, 'tasaAplica': '<Tasa>', 'precioUnitario': <Preco>, 'descripcion': '<Descr>' }"
			cDetalhe := STRTRAN(cDetalhe, "<Qtde>",  cValToChar(((cTabDeta)->(F0P_QUANT))))   
			cDetalhe := STRTRAN(cDetalhe, "<Tasa>",  cValToChar(naliq10))
			If (cRetencao)->(F1_MOEDA) == 2 
				cDetalhe := STRTRAN(cDetalhe, "<Preco>",IIf (nGenera==1,cValToChar(nValItem10),cValToChar(xMoeda(nValbase10,1,(cRetencao)->(F1_MOEDA),,2,1,(cRetencao)->EK_TXMOE02))))
			Else
				cDetalhe := STRTRAN(cDetalhe, "<Preco>",IIf (nGenera ==1,cValToChar(nValItem10),cValToChar(nValbase10)))
			EndIf
			cDetalhe := STRTRAN(cDetalhe, "<Descr>", cProd10) 
			cDetalhe1:= cDetalhe1+cDetalhe
		EndIf     
	EndIf
       	cDetalhe := STRTRAN(cDetalhe1, "'", '"')
       	cLin     := cLin + cDetalhe + ' ], '       
       	cReten   := STRTRAN(cReten, "<Dt_Fecha>", AllTrim(cValToChar(ARRUMADT(aGerar[i][6])))) 
			
			//DMICAS
			aSYF := SYF->(GetArea())
			cAux := Trim(GetMV("MV_SIMB"+cValToChar(Max(1,((cRetencao)->F1_MOEDA))))) //Error Logo MV_SYMB0 
			SYF->(dbSetOrder(1))
			SYF->(MsSeek(xFilial("SYF")+cAux))
			cMoeda := AllTrim(SYF->YF_COD_GI)
			//Inteligencia alternativa referente ao cadastro na tabela SYF x Parametros MV_SIMB+moeda
			If (Val(cMoeda) > 0 .Or. Len(cMoeda) < 3)
				If Left(cAux,1) == "G" .Or. cAux == '$' .Or. cMoeda == '450'
					cMoeda := "PYG"
				ElseIf Left(cAux,1) == "U" .Or. cMoeda == '220'
					cMoeda := "USD"
				ElseIf Left(cAux,1) == "E" .Or. cMoeda == '978'
					cMoeda := "EUR"
				ElseIf Left(cAux,1) == "R" .Or. cMoeda $('085-790')
					cMoeda := "BRL"
				Endif
			Endif
			RestArea(aSYF)
			cReten := STRTRAN(cReten, "<moeda>", cMoeda)
			//DMICAS
			   
       	If cValToChar(((cRetencao)->(F1_MOEDA))) <> "1" //Moeda principal          
			If cValToChar(((cRetencao)->(F1_MOEDA))) == "2"
				nTasCam:= ROUND((cRetencao)->EK_TXMOE02,0)
				cReten := STRTRAN(cReten, "<TpCambio>", Alltrim(Str(nTasCam)))
			ElseIf cValToChar(((cRetencao)->(F1_MOEDA))) == "3"
				nTasCam:= ROUND((cRetencao)->EK_TXMOE03,0)
				cReten := STRTRAN(cReten, "<TpCambio>", Alltrim(Str(nTasCam)))
			ElseIf cValToChar(((cRetencao)->(F1_MOEDA))) == "4"
				nTasCam:= ROUND((cRetencao)->EK_TXMOE04,0)
				cReten := STRTRAN(cReten, "<TpCambio>", Alltrim(Str(nTasCam)))	
			ElseIf cValToChar(((cRetencao)->(F1_MOEDA))) == "5"
				nTasCam:= ROUND((cRetencao)->EK_TXMOE05,0)
				cReten := STRTRAN(cReten, "<TpCambio>", Alltrim(Str(nTasCam)))	
			EndIf 		
       	Else
         cReten := STRTRAN(cReten, "'tipoCambio': <TpCambio>,", '')
       	Endif        

       	cReten := STRTRAN(cReten, "<RetRenta>", LOWER(AllTrim(((cRetencao)->(RetemIR)))) ) 
       	If (cRetencao)->(F0O_TPIMPO) == 'I'
			cReten := STRTRAN(cReten, "<CtRenta>", "")
	
			For nX := 1 to len(aDetails)
			     aDatosD1:= fItems(AllTrim(aGerar[i][5]) ,AllTrim(aGerar[i][4]) ,AllTrim(aGerar[i][2]),AllTrim(aGerar[i][3]),aDetails[nX][1])
				IF len(aDatosD1)<>0

				 IF aDatosD1[1,1] == 10 
				 	If Empty(aDatosD1[1,6]) 
						nRet10:=aDatosD1[1,2]
					Else
						nRet10:=aDatosD1[1,6]
					EndIf	
				 ElseIF aDatosD1[1,1] ==  5 
					If Empty(aDatosD1[1,6]) 
						nRet5:=aDatosD1[1,2]
					Else
						nRet5:=aDatosD1[1,6]
					EndIf
				 ENdIF

				ENDIF
			Next nX	

			cReten := STRTRAN(cReten, "<Iva5>", cValToChar(nRet5))
			cReten := STRTRAN(cReten, "<IVA10>", cValToChar(nRet10))
			cReten := STRTRAN(cReten, "<BsRenta>", '0')
			cReten := STRTRAN(cReten, "<QtRenta>", '0')
			cReten := STRTRAN(cReten, "<TnRenta>", '0')
			cReten := STRTRAN(cReten, "<QtRentasT>", '0')         
       	Else
			//DMICAS-134 - Code Analysis
			cAux := ""
			If ! Empty((cRetencao)->A2_CLASIR)
				aRetSX5 := FWGetSX5("H6",(cRetencao)->A2_CLASIR,"ES") 
				If Len(aRetSX5) > 0
					cAux := aRetSX5[1][4] //Descricao SX5
				Endif	
         Endif
			cReten := STRTRAN(cReten, "<CtRenta>", AllTrim(cAux))
			//DMICAS-134
			cReten := STRTRAN(cReten, "<Iva5>", '0')
			cReten := STRTRAN(cReten, "<IVA10>", '0')
			cReten := STRTRAN(cReten, "<BsRenta>", '0')
			cReten := STRTRAN(cReten, "<QtRenta>", '0')
			cReten := STRTRAN(cReten, "<TnRenta>", '0')
			cReten := STRTRAN(cReten, "<QtRentasT>", '0')
      EndIf
  
       cReten := STRTRAN(cReten, "<RetIva>", LOWER(AllTrim(((cRetencao)->(RetemIVA)))) )
       If (cRetencao)->(F0O_TPIMPO) == 'I'
       		cReten := STRTRAN(cReten, "<CptoIva>", 'IVA.1')
       Else
       	cReten := STRTRAN(cReten, "<CptoIva>", '')
       EndIf
       cReten := STRTRAN(cReten, "'", '"')
       cLin := cLin + cReten       
       cInform := STRTRAN(cInform, "<TpPessoa>", UPPER(AllTrim(((cRetencao)->(SITU))))) 
       cInform := STRTRAN(cInform, "<Nome>", OemToAnsi(AllTrim(((cRetencao)->(A2_NOME)))))

		//DMICAS-134 
		If "contribuyente" $ (cRetencao)->SITU
			cRUC := AllTrim((cRetencao)->A2_CGC) 
			cAux := SubStr(cRUC, 1, Len(cRUC)-2) 
       	cInform := STRTRAN(cInform, "<Ruc>", cAux)
			cAux := SubStr(cRUC, Len(cRUC), 1)
       	cInform := STRTRAN(cInform, "<DV>", cAux)
		   cInform := STRTRAN(cInform, "<Ender>", OemToAnsi(AllTrim((cRetencao)->A2_END)))	
		Else 
       	cInform := STRTRAN(cInform, "<Ruc>", '')
       	cInform := STRTRAN(cInform, "<DV>", '')	
 			cInform := STRTRAN(cInform, "<Ender>", '')
		Endif	
		If AllTrim((cRetencao)->SITU) != "contribuyente"
			If ! Empty((cRetencao)->A2_TPDOC)
				aRetSX5 := FWGetSX5("TB",(cRetencao)->A2_TPDOC,"ES")
			Else 
				aRetSX5 := {}
			Endif		       
			If Len(aRetSX5) > 0 
				cAux := Alltrim(aRetSX5[1][4]) //Descricao SX5
				cInform := STRTRAN(cInform, "<TpIdent>", cAux) //|RUC|CEDULA DE IDENTIDAD|PASAPORTE|IDENTIFICACION_TRIB|
				cAux := Alltrim(aRetSX5[1][3]) //Chave SX5
				If cAux == '5'
					cInform := STRTRAN(cInform, "<Ident>", '44444402')
				ElseIf cAux == '6'
					cInform := STRTRAN(cInform, "<Ident>", '44444403')
				Else	
					cInform := STRTRAN(cInform, "<Ident>", AllTrim(((cRetencao)->A2_INSCR)))
				Endif	
			Else 
				cInform := STRTRAN(cInform, "<TpIdent>", '')
				cInform := STRTRAN(cInform, "<Ident>", '')			
			EndIf
			cInform := STRTRAN(cInform, "<Direcao>", AllTrim(((cRetencao)->A2_END)))
			cInform := STRTRAN(cInform, "<Email>", AllTrim(((cRetencao)->A2_EMAIL)))				
		Else //contribuyente
			cInform := STRTRAN(cInform, "<TpIdent>", '')
			cInform := STRTRAN(cInform, "<Ident>", '')	
			cInform := STRTRAN(cInform, "<Direcao>", '')
			cInform := STRTRAN(cInform, "<Email>", '')
		Endif	
		If AllTrim((cRetencao)->SITU) == "NO_RESIDENTE"
			aSYA := SYA->(GetArea())
			SYA->(DbSetOrder(1))
			SYA->(MsSeek(xFilial("SYA") + (cRetencao)->A2_PAIS))
			cPais := AllTrim(SYA->YA_SIGLA)
			If Len(cPais) < 2
				cPais := AllTrim(SYA->YA_PAISDUE) //Country Codes ISO-3166 F3 = tabela ELO
			Endif
			RestArea(aSYA)
			cInform := STRTRAN(cInform, "<Tel>", '')
		Else 
			cPais := ""
			cInform := STRTRAN(cInform, "<Tel>", AllTrim(((cRetencao)->A2_TEL)))			
		Endif
		cInform := STRTRAN(cInform, "<Pais>", cPais)
      
      cInform := STRTRAN(cInform, "'", '"')
      cLin := cLin + cInform      
              
      cTransac := STRTRAN(cTransac, "<NumComp>", AllTrim(TransForm(((cRetencao)->FE_NFISCAL),"@R XXX-XXX-XXXXXXX")))       
      cTransac := STRTRAN(cTransac, "<DtFecha>", AllTrim(ArrumaDt(((cRetencao)->(F1_EMISSAO))))) //DMICAS
		 
		cAux := iif((cRetenca)->PARCELA == 1 .And. (cRetenca)->Emissao == (cRetenca)->Vencimento, "CONTADO", "CREDITO")
		cTransac := STRTRAN(cTransac, "<TpCompra>", cAux)
		cTransac := STRTRAN(cTransac, "<Quotas>", cValToChar((cRetenca)->PARCELA))

		cAux := Alltrim((cRetencao)->F1_TIPNOTA)
		If Val(cAux) == 0
			cAux := "1"
		Else 
			cAux := cValToChar(Val(cAux))
		 Endif	
		cTransac := STRTRAN(cTransac, "<TpComp>", cAux)
		 
	 	If AllTrim(((cRetencao)->SITU)) == 'contribuyente'
		 	cAux := TransForm(AllTrim(((cRetencao)->F1_NUMTIM)),"@R XXXXXXXX")
		Else 
		 	cAux := "0"	
		Endif 
      cTransac := STRTRAN(cTransac, "<NumTimbr>", AllTrim(cAux))
      //DMICAS-134   

       cTransac := STRTRAN(cTransac, "'", '"')
       cLin := cLin + cTransac    
 
       cAtrib := STRTRAN(cAtrib, "<FechaCr>", AllTrim(ARRUMADT(((cRetencao)->(F0O_DTGERA)))))
       cAtrib := STRTRAN(cAtrib, "<HoraCr>", ((cRetencao)->(F0O_HRGERA))) 
       cAtrib := STRTRAN(cAtrib, "'", '"')+ iif( i ==  Len(aGerar),']','')  
       cLin := cLin + cAtrib         
       cLin1:= cLin1 + cLin
       
       (cRetencao)->(dbCloseArea())     
       (cRetenca)->(dbCloseArea())     

	cDetalhe  := "{ 'cantidad': <Qtde>, 'tasaAplica': '<Tasa>', 'precioUnitario': <Preco>, 'descripcion': '<Descr>' }"
    cReten    := " 'retencion': {'fecha': '<Dt_Fecha>', 'moneda': '<moeda>', 'tipoCambio': <TpCambio>, 'retencionRenta': <RetRenta>,  " +;
                   " 'conceptoRenta': '<CtRenta>', 'ivaPorcentaje5': <Iva5>, 'ivaPorcentaje10': <IVA10>, 'rentaCabezasBase': <BsRenta>, " +;
                   " 'rentaCabezasCantidad': <QtRenta>, 'rentaToneladasBase': <TnRenta>, 'rentaToneladasCantidad': <QtRentasT>,         " +;
                   " 'rentaPorcentaje': <PorcRenta>, 'retencionIva': <RetIva>, 'conceptoIva': '<CptoIva>' }, "
     cInform   := " 'informado': { 'situacion': '<TpPessoa>', 'nombre': '<Nome>', 'ruc': '<Ruc>', 'dv': '<DV>', 'domicilio': '<Ender>'," +;
                   " 'tipoIdentificacion': '<TpIdent>', 'identificacion': '<Ident>', 'direccion': '<Direcao>', 'correoElectronico':     " +;
                   " '<Email>', 'pais': '<Pais>', 'telefono': '<Tel>' }, "     
    cTransac  := " 'transaccion': { 'numeroComprobanteVenta': '<NumComp>', 'condicionCompra': '<TpCompra>', 'cuotas': <Quotas>,       " +;
                   " 'tipoComprobante': <TpComp>, 'fecha': '<DtFecha>', 'numeroTimbrado': '<NumTimbr>' }, "  

	if i ==  Len(aGerar)  
     	cAtrib    := " 'atributos': { 'fechaCreacion': '<FechaCr>', 'fechaHoraCreacion': '<HoraCr>' }}] "  
	else
		   cAtrib    := " 'atributos': { 'fechaCreacion': '<FechaCr>', 'fechaHoraCreacion': '<HoraCr>' }} "  
	EndIf
	                                     

     Next
	
	fWrite(nHdl, cLin1)
	fClose(nHdl)
	
	If !lAutomato
		//DMICAS
		If Empty(cLin1)
			MsgAlert(STR0003, STR0019) //No existen ”rdenes de pago para consultar
		ElseIf File(cFileTxt)
			MsgInfo(STR0018 + CRLF + cFileTxt, STR0019) //Generado con Èxito
		Else
			MsgStop(STR0015 + CRLF + cFileTxt, STR0019) //OcurriÛ un error al crear el archivo
		Endif
		//DMICAS	
   EndIf
  EndIf
  RestArea(aArea)
EndIf

Return

/*/
+------------+----------+-------+-----------------------+------+----------+
| Funcao     |F103VISUA | Autor |Paulo Augusto          | Data |09/10/2014|
|------------+----------+-------+-----------------------+------+----------+
| Descricao  |Funcao de Tratamento da Visualizacao                        |
+------------+------------------------------------------------------------+
| Sintaxe    |F103VISUA(ExpC1,ExpN2,ExpN3)                              |
+------------+------------------------------------------------------------+
| Parametros | ExpC1: Alias do arquivo                                    |
|            | ExpN2: Registro do Arquivo                                 |
|            | ExpN3: Opcao da MBrowse                                    |
+------------+------------------------------------------------------------+
| Retorno    | Nenhum                                                     |
+------------+------------------------------------------------------------+
| Uso        | FISA802                                                   |
+------------+------------------------------------------------------------+
/*/
Function F103VISUA(cAlias,nReg,nOpcx)
Local aArea     := GetArea()
Local oGetDad
Local oDlg
Local lUso      := .F. //DMICAS
Local nUsado    := 0
Local nCntFor   := 0
Local cCadastro := OemToAnsi(STR0001) //"Processo de Venda"
Local bWhile    := {|| .T. }
Local aObjects  := {}
Local aPosObj   := {}
Local aSizeAut  := MsAdvSize()
Local nX		:= 0
Local aEstruc	:= {}
PRIVATE aHEADER := {}
PRIVATE aCOLS   := {}
PRIVATE aGETS   := {}
PRIVATE aTELA   := {}
dbSelectArea("F0O")
dbSetOrder(1)
For nCntFor := 1 To FCount()
   M->&(FieldName(nCntFor)) := FieldGet(nCntFor)
Next nCntFor

	aEstruc := FWSX3Util():GetListFieldsStruct("F0P", .T.)
	For nX := 1 To Len(aEstruc)
		//DMICAS-85 Campos X3_RESERV vazio, n„o usado e bloqueado para ediÁ„o no configurador.
		If X3USO(GetSx3Cache(aEstruc[nX][1], 'X3_USADO'))
			lUso := .T.
		ElseIf Empty(GetSx3Cache(aEstruc[nX][1], 'X3_RESERV'))
			lUso := GetSx3Cache(aEstruc[nX][1], 'X3_BROWSE') != "N" //DMICAS-134 (Melhoria da DMICAS-85 para lexibilidade de Ajustes)
		Else 
			lUso := .F.
		Endif	
		If lUso .And. cNivel >= GetSx3Cache(aEstruc[nX][1], 'X3_NIVEL')
			Aadd(aHeader,{ Trim(FWX3Titulo(aEstruc[nX][1])),;
			aEstruc[nX][1],;//Campo
			AllTrim(GetSx3Cache(aEstruc[nX][1], 'X3_PICTURE')),;
			aEstruc[nX][3],;//TamaÒo
			aEstruc[nX][4],;//Decimal
			AllTrim(GetSx3Cache(aEstruc[nX][1], 'X3_VALID')),;
			AllTrim(GetSx3Cache(aEstruc[nX][1], 'X3_USADO')),;
			aEstruc[nX][2],;//Tipo
			AllTrim(GetSx3Cache(aEstruc[nX][1], 'X3_ARQUIVO')),;
			AllTrim(GetSx3Cache(aEstruc[nX][1], 'X3_CONTEXT')) } )
			nUsado++
		EndIf
	Next nX	
	
                                                                                                           
dbSelectArea("F0P")
dbSetOrder(1)
F0P->(MsSeek(xFilial("F0P")+F0O->F0O_ORDPAG+F0O->F0O_SERIER+F0O->F0O_NUMNF))  //filial tpresg  serier numreg especie serie  num
      bWhile := {|| xFilial("F0P")  == F0P->F0P_FILIAL .And.; 
      F0O->F0O_ORDPAG+F0O->F0O_SERIER+F0O->F0O_NUMNF== F0P->F0P_ORDPAG+F0P->F0P_SERIER+F0P_NUMNF} 

While ( !Eof() .And. Eval(bWhile) )
	aadd(aCOLS,Array(nUsado+1))
	For nCntFor := 1 To nUsado
		If ( aHeader[nCntFor][10] != "V" )
			aCols[Len(aCols)][nCntFor] := FieldGet(FieldPos(aHeader[nCntFor][2]))
		Else
		aCols[Len(aCols)][nCntFor] := CriaVar(aHeader[nCntFor][2])
	EndIf
	Next nCntFor
	aCOLS[Len(aCols)][Len(aHeader)+1] := .F.

	dbSkip()
EndDo
aObjects := {} 
AAdd( aObjects, { 315,  50, .T., .T. } )
AAdd( aObjects, { 100, 100, .T., .T. } )
aInfo := { aSizeAut[ 1 ], aSizeAut[ 2 ], aSizeAut[ 3 ], aSizeAut[ 4 ], 3, 3 } 
aPosObj := MsObjSize( aInfo, aObjects, .T. ) 
DEFINE MSDIALOG oDlg TITLE cCadastro From aSizeAut[7],00 To aSizeAut[6],aSizeAut[5] STYLE 2 OF oMainWnd PIXEL 
EnChoice( cAlias ,nReg, nOpcx, , , , , aPosObj[1], , 3 )
oGetDad := MSGetDados():New (aPosObj[2,1], aPosObj[2,2], aPosObj[2,3], aPosObj[2,4], nOpcx, "" ,"AllwaysTrue","",.F.)
ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar(oDlg,{||oDlg:End()},{||oDlg:End()})
RestArea(aArea)

Return(.T.)


Function FI802ANU()
nOP:= F0O->F0O_ORDPAG
	If Aviso(STR0020,STR0021+ ' " ' + F0O->F0O_ORDPAG     +  ' " ' + STR0022 ,{STR0028,STR0029}) == 1
			F0P->(DbSetOrder(1)  )
			F0P->(MsSeek(xfilial("F0P")+nOP,.t.) )
			If F0P->(MsSeek(xfilial("F0P")+nOP,.t.) )//+F0O->F0O_SERIER+F0O->F0O_NUMNF+F0O->F0O_FORNEC+F0O->F0O_LOJA,.t.) )   
				While !(F0P->(Eof())) .AND. ( xFilial("F0P") +nOP/*+F0O->F0O_SERIER+F0O->F0O_NUMNF+F0O->F0O_FORNEC+F0O->F0O_LOJA*/==;
				                              F0P->F0P_FILIAL+F0P->F0P_ORDPAG/*+F0P->F0P_SERIE+ F0P->F0P_NUMNF+F0P->F0P_FORNEC+F0P->F0P_LOJA*/)
					RecLock("F0P",.F.)
					F0P->(dbDelete())		
  					MsUnLock()     
  					F0P->(DbSkip())
			    EndDo
			
				F0O->(DbSetOrder(1)  )  
				F0O->(DbGotop())
				F0O->(MsSeek(xfilial("F0O")+nOP))	
				While !(F0O->(Eof())) .AND. ( xFilial("F0O") +nOP ==   F0O->F0O_FILIAL+F0O->F0O_ORDPAG)       
				
				aArea:=GetArea()
				DbSelectArea("SFE")
				DbSetOrder(2)
				If (MsSeek(xFilial("SFE")+F0O->F0O_ORDPAG+F0O->F0O_TPIMPO)   )
					While !EOF() .And. xFilial("SFE")+F0O->F0O_ORDPAG+F0O->F0O_TPIMPO ==;
							SFE->FE_FILIAL+SFE->FE_ORDPAGO+SFE->FE_TIPO
						If F0O->F0O_FORNEC==SFE->FE_FORNECE .AND. F0O->F0O_LOJA==SFE->FE_LOJA ;
								.AND. F0O->F0O_NFISCA==SFE->FE_NFISCAL .AND. F0O->F0O_SERIE== SFE->FE_SERIE
				  				RecLock("SFE",.F.)
				  				SFE->FE_NROTES:=""
								MsUnlock()
						EndIf
						SFE->(dbSkip())
					EndDo
				EndIf
				RestArea(aArea)
				
				
			
					RecLock("F0O",.F.)
					F0O->(dbDelete())		
  					MsUnLock()
  					F0O->(DbSkip())
  				EndDo
				MsgInfo(STR0023)
			EndIf	
	EndIf
Return


//DMICAS GetNextAlias()
Function QryArray(cQry)
	Local aRet := {}
	Local aAux := {}
	Local nAux := 0
	Local cTmp := GetNextAlias()

	cQry := ChangeQuery(cQry)
	TCQUERY cQry NEW ALIAS (cTmp)

	dbSelectArea(cTmp)
	aAux := Array(Fcount())

	While !Eof()
		For nAux :=1 To Len(aAux)
			aAux[nAux] := FieldGet(nAux)
		Next
		Aadd(aRet, aClone(aAux))
		dbSkip()
	Enddo

	(cTmp)->(DbCloseArea())
Return(aRet)
 


Function ArrumaDt(xData)
	Local cRet := ""
	Local cData := iif(ValType(xData)=="D",DTOS(xData),xData) //DMICAS
	cRet := (SubStr(cData, 1, 4) + "-" + SubStr(cData, 5, 2) + "-" + SubStr(cData, 7, 2))
Return(cRet)
 		

Function Fi802AcN()

	Local 	cCod:=Space(13)
	Local	oDlg
	Local 	lMa:=.F.
	Local   cDoc:=F0O->F0O_SERIE + "    /    " + F0O->F0O_NFISCA
	Local	cNomeArqui := Space(60)

	If !Empty(F0O->F0O_NROTES)
		lMa:=.T.
	EndIf

	If lMa
		MsgStop(STR0024,STR0025)
		Return()
	EndIf

	SFP->(DbSetOrder(6))
	lVldExp:=.F.
	cTipo:=""


	DEFINE MSDIALOG oDlg FROM 00,00 TO 130,380 PIXEL TITLE STR0032
	@	007,003 	Say  STR0030 OF oDlg PIXEL
	@	007,080		Say  cDoc OF oDlg PIXEL
	@	020,003 	Say  STR0031  OF oDlg PIXEL
	@	020,080	    MSGET  cCod   SIZE 080,10 OF oDlg PIXEL
	@	033,003 	Say  STR0043  OF oDlg PIXEL
	@	033,080 	MSGET  cNomeArqui  SIZE 080,10 OF oDlg PIXEL

	DEFINE SBUTTON FROM 050,130	TYPE 1  ACTION Fi802AcT(cCod,oDlg, , cNomeArqui ) ENABLE OF oDlg
	DEFINE SBUTTON FROM 050,160	TYPE 2  ACTION (oDlg:End()) ENABLE OF oDlg
	DEFINE SBUTTON FROM 033,160	TYPE 14 ACTION ( cNomeArqui:= fSelArqTxt() ) ENABLE OF oDlg

	ACTIVATE MSDIALOG oDlg CENTERED

Return( )

/*/{Protheus.doc} Fi802AcT
    Controla la importaciÛn y/o vinculaciÛn del Comprobante de RetenciÛn Virtual (TESAKA) a los tÌtulos,
    operando en dos modos mutuamente excluyentes:
    - Cuando se informa el n˙mero del comprobante (cCod), actualiza los campos F0O->F0O_NROTES y SFE->FE_NROTES
      en los registros correspondientes, de acuerdo con las claves y validaciones del flujo.
    - Cuando se informa el archivo de retorno (cNomeArqui), activa el procesamiento del archivo mediante fProcJson,
      con exhibiciÛn de progreso (cuando corresponda) y manejo de mensajes.
    Realiza validaciones de llenado, impide el uso simult·neo de ambas opciones, presenta avisos en caso de
    inconsistencia, admite ejecuciÛn autom·tica (IsBlind) y cierra el di·logo recibido al final.
    @type    Function
    @author  alan.lunardi
    @since   21/08/2025
    @version 1.0
    @param   cCod,        Character,   N˙mero del Comprobante de RetenciÛn Virtual (TESAKA) que se asociar· a los tÌtulos; utilice esta opciÛn o bien cNomeArqui.
    @param   oDlg,        Object,      Di·logo/objeto visual opcional que se cerrar· al tÈrmino del procesamiento.
    @param   lConsWs,     Logical,     Par·metro reservado para futuras integraciones (no utilizado en esta rutina).
    @param   cNomeArqui,  Character,   Ruta completa del archivo de retorno que se importar·; utilice esta opciÛn o bien cCod.
    @return  NIL
/*/                                                                                  
Function Fi802AcT(cCod,oDlg,lConsWs,cNomeArqui)
	Local aArea			:=GetArea()
	Local lProc 		:= .T.
	Local oSay 			:= NIL
	Local lAuto 		:= IsBlind()
	Default oDlg		:= Nil
	Default lConsWs 	:= .F.
	Default cNomeArqui 	:= ''
	Default cCod 		:= ''

	// ValidaÁıes
	if Empty(cCod) .And. Empty(cNomeArqui)
		lProc := .F.
		Help(,, STR0040, ,STR0041, 1, 0) // "Aviso" // "Informe o n˙mero de Comprovante de RetenÁ„o Virtual ou diretÛrio para importaÁ„o do arquivo Retorno"
	elseif !Empty(cCod) .And. !Empty(cNomeArqui)
		lProc := .F.
		Help(,, STR0040, ,STR0042, 1, 0) // "Aviso" // "Utilize somente uma opÁ„o, N˙mero Comprovante de Retencao Virtual ou diretÛrio para importaÁ„o do arquivo Retorno"
	elseif !Empty(cCod)
		lProc := .T.
	elseif !Empty(cNomeArqui)
		lProc := .F.
		if lAuto
			fProcJson(oSay,cNomeArqui,lAuto)
		else
			FwMsgRun(,{|oSay| fProcJson(oSay,cNomeArqui) },STR0048,"")//Processando
		endif
	endif

	if lProc .And.  !Empty(cCod)
		RecLock("F0O",.F.)
		F0O->F0O_NROTES:=cCod
		MsUnlock()

		DbSelectArea("SFE")
		DbSetOrder(2)
		If (MsSeek(xFilial("SFE")+F0O->F0O_ORDPAG+F0O->F0O_TPIMPO)   )
			While !EOF() .And. xFilial("SFE")+F0O->F0O_ORDPAG+F0O->F0O_TPIMPO ==;
					SFE->FE_FILIAL+SFE->FE_ORDPAGO+SFE->FE_TIPO
				If F0O->F0O_FORNEC==SFE->FE_FORNECE .AND. F0O->F0O_LOJA==SFE->FE_LOJA ;
						.AND. F0O->F0O_NFISCA==SFE->FE_NFISCAL .AND. F0O->F0O_SERIE== SFE->FE_SERIE
					RecLock("SFE",.F.)
					SFE->FE_NROTES:=cCod
					mSGaLERT(STR0033," ")
					MsUnlock()
				EndIf
				SFE->(dbSkip())
			EndDo
		EndIf
	endif

	RestArea(aArea)
	freeObj(oSay)
	If oDlg <> Nil
		oDlg:End()
	endif

Return()

/*{Protheus.doc} fItems
(Obtener detalle del item de la SD1)
	@type  Function
	@author Adri·n PÈrez Hern·ndez
	@since 13/06/2024
	@param 
		cLoja   ,Car·cter, CÛdigo de tienda
		cFornec ,Car·cter, CÛdigo Proveedor
		cDoc    ,Car·cter,  N˙mero de documento
		cSerie  ,Car·cter, Serie del documento
		cLinea  ,Car·cter, N˙meo del item de la SD1
	@return aAux ,Arreglo, datos de la SD1*/
Function fItems(cLoja,cFornec,cDoc,cSerie,cLinea)

Local cQuery:=""
Local aAux:={}
Local cImp :=""

DEFAULT cLoja:=""
DEFAULT cFornec:=""
DEFAULT cDoc:=""
DEFAULT cSerie:=""
DEFAULT cLinea:=""

	cImp:= fImpTes(cLoja,cFornec,cDoc,cSerie,cLinea)
	cQuery += "SELECT "
	cQuery += " D1_ALQIMP1,D1_CF,D1_TES,D1_COD,D1_ITEM,D1_VUNIT,FF_ALIQ,FE_ALIQ,FF_RBASCAL"
	cQuery += " FROM " + RetSqlName("SD1") +" SD1"
	cQuery += " LEFT JOIN "+ RetSqlName("SFF")+" SFF ON ("
	cQuery+="	SD1.D1_SERIE=FF_SERIENF"
	cQuery+="	AND SFF.FF_IMPOSTO='"+cImp+"')"
	cQuery+=" LEFT JOIN "+RetSqlName("SFE")+" SFE ON("
	cQuery+="	SFE.FE_NFISCAL = SD1.D1_DOC"
    cQuery+="    AND SFE.FE_SERIE = SD1.D1_SERIE"
    cQuery+="    AND SFE.FE_FORNECE = SD1.D1_FORNECE"
	cQuery+="    AND SFE.FE_CFO = SD1.D1_CF"
	cQuery+=")"
						  
	cQuery += " WHERE SD1.D1_FILIAL = '" + xFilial("SD1") + "'"
	cQuery += " AND SD1.D1_DOC ='"+cDoc+"'"
	cQuery += " AND SD1.D1_SERIE ='"+cSerie+"'"
	cQuery += " AND SD1.D1_FORNECE ='"+cFornec+"'"
	cQuery += " AND SD1.D1_LOJA ='"+cLoja+"'"
	cQuery += " AND SD1.D1_ITEM ='"+ALLTRIM(cLinea)+"'"
	cQuery += " AND SD1.D_E_L_E_T_ =''"
	cQuery += " AND SFF.D_E_L_E_T_ =''"
	cQuery += " AND SFE.D_E_L_E_T_ =''"
	cQuery+= "  	GROUP BY D1_ALQIMP1,D1_CF,D1_TES,D1_COD,D1_ITEM,D1_VUNIT,FF_ALIQ,FE_ALIQ,FF_RBASCAL"
	cQuery := ChangeQuery(cQuery)
	dbUseArea(.T., "TOPCONN", TcGenQry( , , cQuery), "cItems", .T., .T.)

	cItems->(dbGoTop())
	Do While cItems->(!EOF()) 
		AADD(aAux, {cItems->D1_ALQIMP1,cItems->FE_ALIQ,cItems->D1_CF,cItems->D1_TES,cItems->D1_COD,cItems->FF_RBASCAL})
		cItems->(dbSkip())
	EndDo
	
	cItems->(dbCloseArea())

return aAux
/*{Protheus.doc} fValbas
(Obtener Alicuota y RetenciÛn)
	@type  Function
	@author Cristian Franco
	@since 12/09/2024
	@param 
		cDoc    ,Car·cter,  N˙mero de documento
		cSerie  ,Car·cter, Serie del documento
		cFornec ,Car·cter, CÛdigo Proveedor
		cLoja   ,Car·cter, CÛdigo de tienda
	@return aSD1 ,Arreglo, Alicuota y RetenciÛn*/
Function fValbas(cDoc,cSerie,cFornec,cLoja)

Local clQryVal:=""
Local aSD1:={}

DEFAULT cDoc:=""
DEFAULT cSerie:=""
DEFAULT cFornec:=""
DEFAULT cLoja:=""

	clQryVal  := "SELECT DISTINCT D1_ALQIMP1,D1_CF, FE_VALBASE " 
	clQryVal  += " FROM " + RetSqlName("SD1")+" SD1 "
	clQryVal  += " INNER JOIN " + RetSqlName("SFE")+ " SFE  " 
	clQryVal  +="  ON(SFE.FE_NFISCAL = SD1.D1_DOC    AND SFE.FE_SERIE = SD1.D1_SERIE AND SFE.FE_FORNECE = SD1.D1_FORNECE AND SFE.FE_CFO = SD1.D1_CF) "
	clQryVal  += " WHERE SD1.D1_FILIAL = '" + xFilial("SD1")       + "'"         
	clQryVal  += " AND SD1.D1_DOC = '" + AllTrim(cDoc)  + "'"         
	clQryVal  += " AND SD1.D1_SERIE = '" + AllTrim(cSerie)  + "'" 
	clQryVal  += " AND SD1.D1_FORNECE = '" + AllTrim(cFornec)  + "'"
	clQryVal  += " AND SD1.D1_LOJA   = '" + AllTrim(cLoja)  + "'"  
	clQryVal  += "  AND SD1.D_E_L_E_T_ = '' AND SFE.D_E_L_E_T_ = ''"                                 
	clQryVal  := ChangeQuery(clQryVal)
	aSD1 := QryArray(clQryVal)  

return aSD1

/*{Protheus.doc} fImpTes
(Obtener Tes e Impuesto)
	@type  Function
	@author Cristian Franco
	@since 12/09/2024
	@param 
		cLoja   ,Car·cter, CÛdigo de tienda
		cFornec ,Car·cter, CÛdigo Proveedor
		cDoc    ,Car·cter,  N˙mero de documento
		cSerie  ,Car·cter, Serie del documento
		cLinea, Car·cter, Õtem SD1
		
	@return cImposto ,C·racter, Impuesto usado en Ìtem*/
Function fImpTes(cLoja,cFornec,cDoc,cSerie,cLinea)
Local cImposto	:=""
Local cTabTes   := GetNextAlias()
Local cTabImp   := GetNextAlias()

DEFAULT cLoja:=""
DEFAULT cFornec:=""
DEFAULT cDoc:=""
DEFAULT cSerie:=""
DEFAULT cLinea:=""
	
	BeginSql Alias cTabTes
		SELECT 
			D1_TES
		FROM   
			%table:SD1%  SD1				  
		WHERE 
		SD1.D1_FILIAL =%xfilial:SD1%
		AND SD1.D1_DOC = %exp:cDoc%
		AND SD1.D1_SERIE =%exp:cSerie%
		AND SD1.D1_FORNECE =%exp:cFornec%
		AND SD1.D1_LOJA =%exp:cLoja%
		AND SD1.D1_ITEM =%exp:cLinea%
		AND SD1.%notdel%
	EndSql 

	DbSelectArea(cTabTes)
	cTes:= (cTabTes)->(D1_TES)
	(cTabTes)->(dbCloseArea())
	
	
	BeginSql ALIAS cTabImp
   		SELECT 
			FB_CODIGO
	   	FROM
			 %table:SFC% SFC 
	   	INNER JOIN   %table:SFB%  SFB   
	   	ON(SFC.FC_IMPOSTO = SFB.FB_CODIGO)
	   	WHERE SUBSTRING(FB_CODIGO,1,2) ='IV'
	   	AND FB_CLASSE = 'I'	   
		AND (FB_CODIGO=FC_IMPOSTO)
	   	AND FC_TES=%exp:cTes%
		AND SFB.%notdel%	   
		AND SFC.%notdel%
	EndSql
	DbSelectArea(cTabImp)
	cImposto:= (cTabImp)->(FB_CODIGO)
	(cTabImp)->(dbCloseArea())

Return cImposto	


/*{Protheus.doc} fRetFil
	Devuelve el filtro de sucursales seg˙n la relaciÛn y la forma de comparticiÛn de tablas.
	@type  Function
	@author Rafael Parma
	@since 21/03/2025
	@param 
		cTab1, Car·cter, Nombre de la tabla principal
		cTab2, Car·cter, Nombre de la tabla secundaria
	@return 
		cRet, C·racter, Cl·usula SQL de sucursales para uso en la consulta principal.
*/
Static Function fRetFil(cTab1, cTab2)
Local cRet := ""
Local cFilTab1 := ""
Local cFilTab2 := ""
Local cModAcTab1 := ""
Local cModAcTab2 := ""
Local cMsFilTab1 := ""
Local cMsFilTab2 := ""
Local lMsFilTab1 := .F.
Local lMsFilTab2 := .F.
Default cTab1 := "SF1"
Default cTab2 := "SFE"

	cModAcTab1 := FWModeAccess(cTab1)
	cModAcTab2 := FWModeAccess(cTab2)
	cFilTab1 := cTab1+"."+SubSTR(cTab1,2,2)+"_FILIAL"
	cFilTab2 := cTab2+"."+SubSTR(cTab2,2,2)+"_FILIAL"
	cMsFilTab1 := cTab1+"."+SubSTR(cTab1,2,2)+"_MSFIL"
	cMsFilTab2 := cTab2+"."+SubSTR(cTab2,2,2)+"_MSFIL"
	lMsFilTab1 := (cTab1)->(ColumnPos(SubSTR(cTab1,2,2)+"_MSFIL")) > 0
	lMsFilTab2 := (cTab2)->(ColumnPos(SubSTR(cTab2,2,2)+"_MSFIL")) > 0 

	If (cModAcTab1 == "E" .AND. cModAcTab2 == "E") .OR. (cModAcTab1 == "C" .AND. cModAcTab2 == "C")
		cRet := " AND "+cFilTab1+" = "+cFilTab2				
	Else
		If cModAcTab1 == "E" .AND. cModAcTab2 == "C" .AND. lMsFilTab2	
			cRet := " AND "+cFilTab1+" = "+cMsFilTab2
		ElseIf cModAcTab1 == "C" .AND. cModAcTab2 == "E" .AND. lMsFilTab1
			cRet := " AND "+cMsFilTab1+" = "+cFilTab2
		EndIf
	EndIf

Return cRet

/*/{Protheus.doc} fSelArqTxt
    Realiza a seleÁ„o de um arquivo texto (.txt) pelo usu·rio, utilizando a interface nativa tFileDialog, 
	e retorna o caminho completo do arquivo escolhido para posterior processamento.

    @type    Static Function
    @author  alan.lunardi
    @since   24/07/2025
    @version 1.0

    @description
    Exibe uma janela para o usu·rio selecionar um arquivo com extens„o .txt em uma pasta tempor·ria. 
	Retorna o caminho completo do arquivo selecionado ou uma string vazia caso a seleÁ„o seja cancelada.

    @param  -- Esta funÁ„o n„o recebe par‚metros.

    @return cArq, Character, Caminho completo do arquivo selecionado; string vazia se operaÁ„o for cancelada.


/*/

Static Function fSelArqTxt()
	Local cArq    := ""
	Local cTipArq := "(*.txt)"
	Local cTitulo := STR0047 //"SeleÁ„o de Arquivo para Processamento"
	Local lSalvar := .F.
	Local cTmp 	  := getTempPath()

	cArq := tFileDialog(cTipArq, cTitulo, , cTmp,  lSalvar, )

Return cArq

/*/{Protheus.doc} fProcJson
    Processa e importa dados de um arquivo JSON estruturado, 
	extraindo informaÁıes de clientes e atualizando os registros na base 
	conforme a estrutura do JSON fornecido. 
	Exibe mensagens de aviso em caso de estrutura inv·lida, ausÍncia de arquivo ou cliente n„o localizado.
    @type    Static Function
    @author  Alan Lunardi
    @since   25/07/2025
    @version 1.0
    @param   oSay,        Object,      Objeto visual respons·vel por exibir a evoluÁ„o do processamento na interface.
    @param   cArq,        Character,   Caminho completo do arquivo JSON a ser processado.
	@param   lAuto,       Logical,     Define a execuÁ„o em modo autom·tico 
    @return  NIL

/*/
Static Function fProcJson(oSay,cArq, lAuto)
	Local aDadosArq		:= {}
	Local cJson      	:= ""
	Local oJson      	:= Nil
	Local nI	     	:= 0
	Local lOK        	:= .T.
	Local nLenJson   	:= 0
	Local nPosDatos  	:= 0
	Local nPosRecpci 	:= 0
	Local aNames     	:= {}
	Local aNamesDtos 	:= {}
	Local nPosInforD 	:= 0 //"informado"
	Local nPosInforT 	:= 0 //"informante"
	Local nPosTransa 	:= 0 //"transaccion"
	Local oInformado 	:= Nil
	Local oRecepcion 	:= Nil
	Local oInformant 	:= Nil //"informante"
	Local oTransacci	:= Nil //"transaccion"
	Local cRUC		 	:= ''
	Local cNumComp   	:= ''
	Local cFechaProc 	:= ''
	Local cHoraProc  	:= ''
	Local cTimbComp  	:= ''
	Local cNfFiscal     := ''
	Local nJ		 	:= 0
	Local cCod			:= ''
	Local cLoja			:= ''
	Local aSA2			:= {}
	Local aBrowse       := {}
	Local lAtu			:= .T.


	Default oSay := NIL
	Default cArq := ''
	Default lAuto := .F.

	oJson := JsonObject():New()

	If File(cArq)
		cJson := oJson:fromJsonFile(cArq)
		if ValType(cJson) == "U"
			nLenJson := Len(oJson)
			if nLenJson > 0
				if !lAuto
					oSay:cCaption := STR0049
					ProcessMessages()
					endif
				for nI := 1 to nLenJson
					aNames := oJson[nI]:GetNames()
					nPosDatos := aScan(aNames,{|x| AllTrim(x) == "datos"})
					nPosRecpci:= aScan(aNames,{|x| AllTrim(x) == "recepcion"})

					if (nPosDatos >0 .And. nPosRecpci >0)
						aNamesDtos := oJson[nI][aNames[nPosDatos]]:GetNames()
						nPosInforD := aScan(aNamesDtos,{|x| AllTrim(x) == "informado"})
						nPosInforT := aScan(aNamesDtos,{|x| AllTrim(x) == "informante"})
						nPosTransa := aScan(aNamesDtos,{|x| AllTrim(x) == "transaccion"})

						if nPosInforD > 0 .And. nPosInforT >0 .And. nPosTransa > 0
							oInformado := oJson[nI][aNames[nPosDatos]][aNamesDtos[nPosInforD]]
							oRecepcion := oJson[nI][aNames[nPosRecpci]]
							oInformant := oJson[nI][aNames[nPosDatos]][aNamesDtos[nPosInforT]]
							oTransacci := oJson[nI][aNames[nPosDatos]][aNamesDtos[nPosTransa]]

							cRUC := Alltrim(oInformado["ruc"] + '-' + oInformado["dv"])
							cNumComp := StrTran(oRecepcion["numeroComprobante"],"-","")
							cFechaProc := StrTran(Left(oRecepcion["fechaProceso"], 10), "-", "")
							cHoraProc := SubStr(oRecepcion["fechaProceso"], 12, 8)
							cTimbComp := oInformant["timbradoComprobante"]
							cNfFiscal := StrTran(oTransacci["numeroComprobanteVenta"],"-","")

							AAdd(aDadosArq, {cRUC, cNumComp, cFechaProc, cHoraProc, cTimbComp,cNfFiscal})
						else
							lOK := .F.
							Help(,, STR0040, ,STR0045, 1, 0) // "Aviso" //"Estrutura arquivo JSON inv·lida"
						endif

					else
						lOK := .F.
						Help(,, STR0040, ,STR0045, 1, 0) // "Aviso" //"Estrutura arquivo JSON inv·lida"
					endif

				next

			else
				lOK := .F.
				Help(,, STR0040, ,STR0045, 1, 0) // "Aviso" //"Estrutura arquivo JSON inv·lida"
			endif

		else
			lOK := .F.
			Help(,, STR0040, ,STR0045, 1, 0) // "Aviso" //"Estrutura arquivo JSON inv·lida"
		endif
	Else
		lOK := .F.
		Help(,, STR0040, ,STR0046, 1, 0) // "Aviso" //"Arquivo n„o encontrado"
	EndIf

	if lOK .And. len(aDadosArq) > 0
		if !lAuto
			oSay:cCaption := STR0050 //"Atualizando Registros"
			ProcessMessages()
		endif
		for nI := 1 to len(aDadosArq)
			cRUC := aDadosArq[nI][1]
			aSA2 := fBuscaSA2(cRUC)
			if Len(aSA2) >0
				for nJ := 1 to Len(aSA2)
					cCod  := aSA2[nJ][1]
					cLoja := aSA2[nJ][2]
					lAtu := fUpdF0O(cCod, cLoja, aDadosArq[nI])
					if lAtu
						AAdd(aBrowse, { aDadosArq[nI][6], aDadosArq[nI][1], aDadosArq[nI][3], aDadosArq[nI][4],aDadosArq[nI][5],aDadosArq[nI][2] })
					endif

				next
			else
				Help(,, STR0040, ,STR0044 + cRUC , 1, 0) // "Aviso" // N„o localizado o cliente com RUC:
			endif

		next
	endif

	// 5. Exibe os dados
	If lOK .And. !lAuto .And. Len(aBrowse) >0
		fGrBrowse(aBrowse)
	EndIf

	//Limpa Variaveis - Boas praticas
	aSize(aDadosArq, 0 )
	aSize(aNames, 0 )
	aSize(aNamesDtos, 0 )
	aSize(aSA2, 0 )
	aSize(aBrowse, 0 )


	freeObj(oJson)
	freeObj(oInformado)
	freeObj(oRecepcion)
	freeObj(oInformant)
	freeObj(oTransacci)

Return

/*/{Protheus.doc} fBuscaSA2
    Busca todos os cÛdigos e lojas de fornecedores na tabela SA2 para um dado CNPJ/CPF (A2_CGC).

    Esta funÁ„o retorna todos os registros da SA2 que correspondam ao CGC (CNPJ ou CPF) informado, 
    adicionando cada par {A2_COD, A2_LOJA} ao resultado. Utilizada para localizar rapidamente fornecedores 
    pelo CNPJ/CPF, mesmo que possuam m˙ltiplas lojas.

    @type    Static Function
    @author  alan.lunardi
    @since   04/08/2025
    @version 1.0
    @param   cCGC, Character, obrigatÛrio, CNPJ/CPF do fornecedor a ser buscado (campo A2_CGC).
    @return  aResult, Array, Lista de arrays no formato {A2_COD, A2_LOJA}, um para cada loja do fornecedor encontrado.
    @example
        Local aFornec := fBuscaSA2("12345678900012")
        For i := 1 To Len(aFornec)
            ConOut("Fornecedor: " + aFornec[i][1] + ", Loja: " + aFornec[i][2])
        Next

/*/
Static Function fBuscaSA2(cCGC)
	Local aResult 	:= {}
	Local aAreaSA2	:= SA2->(GetArea())
	Default cCGC 	:= ''

	SA2->(dbSetOrder(3)) // ÕNDICE POR A2_CGC
	If SA2->(MsSeek(FWxFilial("SA2") + AllTrim(cCGC)))
		While SA2->(!Eof()) .And. AllTrim(SA2->A2_CGC) == AllTrim(cCGC)
			AAdd(aResult, {SA2->A2_COD, SA2->A2_LOJA})
			SA2->(DbSkip())
		EndDo
	EndIf

	SA2->(RestArea(aAreaSA2))

	//limpa array
	aSize(aAreaSA2, 0 )

Return aResult

/*/{Protheus.doc} fUpdF0O
    Atualiza os campos de Notas Fiscais EletrÙnicas (F0O) para o fornecedor e loja especificados, 
    preenchendo informaÁıes de transmiss„o e n˙mero de nota de terceiros conforme dados fornecidos 
    no array de entrada. Utilizada para garantir a atualizaÁ„o dos dados fiscais na tabela F0O
    a partir de critÈrios especÌficos de seleÁ„o.
    
    @type    Static Function
    @author  alan.lunardi
    @since   01/08/2025
    @version 1.0
    @param   cCod, Character, CÛdigo do fornecedor a ser localizado.
    @param   cLoja, Character, Loja do fornecedor a ser localizada.
    @param   aDadosNf, Array, Array contendo as novas informaÁıes para atualizaÁ„o dos campos F0O_NROTES, F0O_DTTRAN, F0O_HRTRAN, F0O_TIMBRA e F0O_NFISCA (posiÁıes: [2]=NROTES, [3]=DTTRAN, [4]=HRTRAN, [5]=TIMBRA, [6]=NFISCA).
    @return  lOk, Logical, Indica se a atualizaÁ„o ocorreu com sucesso (.T.) ou n„o (.F.).
    @example
        Local cCod     := "000123"
        Local cLoja    := "01"
        Local aDadosNf := {"", "NROTES001", "20250801", "1500", "T123ABC", "123456"}
        Local lAtualizado := fUpdF0O(cCod, cLoja, aDadosNf)
        If lAtualizado
            MsgInfo("AtualizaÁ„o ok!")
        EndIf

/*/
Static Function fUpdF0O(cCod, cLoja, aDadosNf)
	Local lOk 			:= .F.
	Local aAreaF0O		:= F0O->(GetArea())
	Local cQuery 		:= ''
	Local oQryExec 		:= Nil
	Local nParamOrder	:= 1
	Local cNextAlias    := ''

	Default cCod		:= ''
	Default cLoja		:= ''
	Default aDadosNf	:= {}

	if oQryExec == NIL
		cQuery := "SELECT "
		cQuery += "R_E_C_N_O_ RECNOF0O "
		cQuery += "FROM " + RetSqlName("F0O") + " F0O "
		cQuery += "WHERE "
		cQuery += "F0O.F0O_FILIAL = ? "
		cQuery += "AND F0O.F0O_FORNEC = ? "
		cQuery += "AND F0O.F0O_LOJA = ? "
		cQuery += "AND F0O.F0O_NFISCA = ? "
		cQuery += "AND F0O.F0O_NROTES = ? "
		cQuery += "AND F0O.F0O_DTTRAN = ? "
		cQuery += "AND F0O.F0O_HRTRAN = ? "
		cQuery += "AND F0O.D_E_L_E_T_ = ? "

		cQuery := ChangeQuery(cQuery)
		oQryExec := FwExecStatement():New(cQuery)
	endif

	oQryExec:SetString(nParamOrder++,xFilial("F0O"))
	oQryExec:SetString(nParamOrder++,cCod)
	oQryExec:SetString(nParamOrder++,cLoja)
	oQryExec:SetString(nParamOrder++,aDadosNf[6])
	oQryExec:SetString(nParamOrder++,' ')
	oQryExec:SetString(nParamOrder++,' ')
	oQryExec:SetString(nParamOrder++,' ')
	oQryExec:SetString(nParamOrder++,' ')

	cNextAlias := oQryExec:OpenAlias()

	If (cNextAlias)->(!Eof())
		lOk := .T.
		F0O->(dbGoTo((cNextAlias)->RECNOF0O))
		RecLock("F0O", .F.)
		F0O->F0O_NROTES := aDadosNf[2]
		F0O->F0O_DTTRAN := aDadosNf[3]
		F0O->F0O_HRTRAN := aDadosNf[4]
		F0O->F0O_TIMBRA := aDadosNf[5]
		F0O->( MsUnlock() )

		//Atualiza Tabela SFE
		fUpdSFE(F0O->F0O_ORDPAG, F0O->F0O_TPIMPO, F0O->F0O_NROTES, F0O->F0O_FORNEC, F0O->F0O_LOJA, F0O->F0O_NFISCA, F0O->F0O_SERIE)
	EndIf

	If Select(cNextAlias) > 0
		(cNextAlias)->(dbCloseArea())
	EndIf

	oQryExec:Destroy()
	oQryExec := nil
	F0O->(RestArea(aAreaF0O))

	aSize(aAreaF0O, 0 )

Return lOk


/*/{Protheus.doc} fGrBrowse
    Exibe um browse customizado em tela utilizando um array como fonte de dados.
    A funÁ„o cria uma janela de di·logo (`TDialog`) e inicializa um objeto `FWBrowse`, 
    utilizando colunas definidas pela funÁ„o `fRetCol`. Permite ao usu·rio visualizar os dados 
    informados por array, facilitando consultas e an·lises personalizadas diretamente no Protheus.

    @type    Static Function
    @author  alan.lunardi
    @since   01/08/2025
    @version 1.0
    @param   aItems, Array, Array contendo os dados que ser„o apresentados no browse.
    @return  Nil, Nil, N„o retorna valor; apenas exibe a interface para o usu·rio.
    @example
        Local aItems := { {"001", "12345678901234", "01/08/2025", "14:00", "S", "100"} }
        fGrBrowse(aItems)
    @see fRetCol, FWBrowse(), TDialog
/*/
Static Function fGrBrowse(aItems)

	Local oDlg     		:= Nil
	Local oFwBrowse   	:= Nil
	Local aColumns    	:= {}
	Local nX		  	:= 0

	Default aItems 		:= {}


	oDlg = TDialog():New(0, 0, 600, 1300, STR0051,,,,,,,,,.T.) //"Registros Atualizados"
	oDlg:lCentered := .T.

	oFwBrowse := FWBrowse():New(oDlg)
	oFwBrowse:SetDataArrayoBrowse()  //Define utilizaÁ„o de array

	oFwBrowse:SetArray(aItems) //Indica o array utilizado para apresentaÁ„o dos dados no Browse.

	aColumns := fRetCol(aItems)

	//Cria as colunas do array
	For nX := 1 To Len(aColumns )
		oFwBrowse:AddColumn( aColumns[nX] )
	Next

	oFwBrowse:SetOwner(oDlg)
	oFwBrowse:SetDescription(STR0051 ) //"Registros Atualizados"
	oFwBrowse:lOptionReport := .F.
	oFwBrowse:OptionReport(.F.)
	oFwBrowse:DisableReport()
	oFwBrowse:Activate()

	oDlg:Activate()

	FreeObj(oFwBrowse)
	FreeObj(oDlg)
	aSize(aColumns, 0 )

Return

/*/{Protheus.doc} fRetCol
    Retorna a estrutura de colunas para um Array Browse, conforme os campos definidos na rotina. 
    Monta dinamicamente os metadados das colunas, utilizando descriÁıes, tipos, tamanhos e masks, alÈm dos code-blocks de carga para dados.
    
    @type    Static Function
    @author  alan.lunardi
    @since   01/08/2025
    @version 1.0
    @param   aItems, Array, Array com os dados que ser„o utilizados no Browse (as linhas a serem exibidas)
    @return  aColumns, Array, Array contendo as definiÁıes estruturadas das colunas para utilizaÁ„o em Array Browse
    @example
        Local aItems   := { {"001", "12345678901234", "01/08/2025", "14:00", "S", "100"} }
        Local aColumns := fRetCol(aItems)
        // A partir daqui, aColumns pode ser aplicado em um Browse personalizado

/*/
Static Function fRetCol(aItems)

	Local aColumns	:= {}
	Local aFields	:= {}
	Local nI		:= 0
	Local aStruct	:= {}
	Local cTitulo	:= ''
	Local cTipoC	:= ''
	Local nTamanho  := 0
	Local nTamDecim := 0
	Local cPicCampo := ''

	Default aItems 		:= {}

	aAdd( aFields, "F0O_NUMNF" )
	aAdd( aFields, "A2_CGC" )
	aAdd( aFields, "F0O_DTTRAN" )
	aAdd( aFields, "F0O_HRTRAN" )
	aAdd( aFields, "F0O_TIMBRA" )
	aAdd( aFields, "F0O_NROTES" )


	for nI := 1 to Len(aFields)
		aStruct := FWSX3Util():GetFieldStruct( aFields[nI] )
		cTitulo:= FWSX3Util():GetDescription( aStruct[1] )
		cTipoC:= aStruct[2]
		nTamanho:= aStruct[3]
		nTamDecim:= aStruct[4]
		cPicCampo:= aStruct[5]
		aAdd(aColumns, {;
			cTitulo,;                    			// [n][01] TÌtulo da coluna
		&( "{ |oBrw| aItems[oBrw:At()," + Alltrim(str(nI)) + "] }" ),; 	// [n][02] Code-Block de carga dos dados
		cTipoC,;                         			// [n][03] Tipo de dados
		cPicCampo,;                      			// [n][04] M·scara
		0,;                              			// [n][05] Alinhamento (0=Centralizado, 1=Esquerda ou 2=Direita)
		nTamanho,;                       			// [n][06] Tamanho
		nTamDecim,;                      			// [n][07] Decimal
		.F.,;                            			// [n][08] Indica se permite a ediÁ„o
		{|| },;                          			// [n][09] Code-Block de validaÁ„o da coluna apÛs a ediÁ„o
		.F.,;                            			// [n][10] Indica se exibe imagem
		Nil,;                            			// [n][11] Code-Block de execuÁ„o do duplo clique
		"",;                             			// [n][12] Vari·vel a ser utilizada na ediÁ„o (ReadVar)
		{|| AlwaysTrue()},;              			// [n][13] Code-Block de execuÁ„o do clique no header
		.F.,;                            			// [n][14] Indica se a coluna est· deletada
		.F.,;                            			// [n][15] Indica se a coluna ser· exibida nos detalhes do Browse
		{},;                             			// [n][16] OpÁıes de carga dos dados (Ex: 1=Sim, 2=N„o)
		aFields[nI]})
	next

	// limpa array
	aSize(aFields, 0 )
	aSize(aStruct, 0 )

Return aColumns

/*/{Protheus.doc} fUpdSFE
    Atualiza o campo FE_NROTES da tabela (SFE) conforme os par‚metros informados.


    @type    Static Function
    @author  alan.lunardi
    @since   05/08/2025
    @version 1.0
    @param   cOrdPag   , character, Ordem de Pagamento.
    @param   cTpimpo   , character, Tipo de Imposto.
    @param   cCodTes   , character, CÛdigo do TES para atualizar no tÌtulo.
    @param   cFornece  , character, CÛdigo do fornecedor para filtro.
    @param   cLoja     , character, CÛdigo da loja do fornecedor para filtro.
    @param   cNFisca   , character, N˙mero da nota fiscal para filtro.
    @param   cSerie    , character, SÈrie da nota fiscal para filtro.
    @return  NIL       , NIL      , NIL

/*/
Static Function fUpdSFE(cOrdPag, cTpimpo, cCodTes, cFornece, cLoja, cNFisca, cSerie)
	Local aAreaSFE		:= SFE->(GetArea())

	Default cOrdPag := ''
	Default cTpimpo := ''
	Default cCodTes := ''
	Default cFornece := ''
	Default cLoja := ''
	Default cNFisca := ''
	Default cSerie := ''

	SFE->(dbSetOrder(2))

	if SFE->(MsSeek(xFilial("SFE")+cOrdPag+cTpimpo))
		While SFE->(!EOF()) .And. xFilial("SFE")+cOrdPag+cTpimpo == SFE->FE_FILIAL+SFE->FE_ORDPAGO+SFE->FE_TIPO
			if cFornece == SFE->FE_FORNECE .And. cLoja==SFE->FE_LOJA .And. cNFisca==SFE->FE_NFISCAL .And. cSerie==SFE->FE_SERIE
				RecLock("SFE",.F.)
				SFE->FE_NROTES:=cCodTes
				SFE->(MsUnlock())
			endif

			SFE->(dbSkip())
		EndDo
	endif

	SFE->(RestArea(aAreaSFE))

	aSize(aAreaSFE, 0 )

Return
