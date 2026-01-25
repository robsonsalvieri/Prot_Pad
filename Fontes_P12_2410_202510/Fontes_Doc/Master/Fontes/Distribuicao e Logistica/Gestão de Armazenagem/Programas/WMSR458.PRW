#INCLUDE "WMSR458.CH"
#INCLUDE "PROTHEUS.CH" 

//------------------------------------------------------------
/*/{Protheus.doc} WMSR458
Relatorio de Embarques
@author Roselaine Adriano
@since 14/08/2020
@version 1.0
/*/
//------------------------------------------------------------
Function WMSR458()
Local oReport
Local aArea := GetArea()

If TRepInUse()
	//-- Interface de impressao
	oReport := ReportDef()
	oReport:PrintDialog()
EndIf

RestArea( aArea )

Return

Static Function ReportDef()                                                                      	
	Local oReport, oSection
	Local aOrdem    := {} 

	oReport:= TReport():New("WMSR458",STR0001,"WMSR458", {|oReport| ReportPrint(oReport)},".")  //"Relatório de Embarques"

	oReport:HideParamPage()   // Desabilita a impressao da pagina de parametros.
	oReport:SetTotalInLine(.F.)
	Aadd( aOrdem, STR0001 ) //"Relatório de Embarque"
	oReport:SetLandscape()
	oReport:lParamPage := .F. 
	Pergunte(oReport:uParam,.T.)
	
	oSection := TRSection():New(oReport,"Campos",{"D0X","D0Z","SC9","DCV","DCD","SA1","SB1" }) // Volumes
	oSection:SetTotalInLine(.F.)

	TRCell():New(oSection,"C9_ROMEMB","SC9",STR0002,PesqPict("SC9","C9_ROMEMB"),TamSx3("C9_ROMEMB")[1],/*lPixel*/,/*{|| code-block de impressao }*/,,,,,,.F.) //Romaneio
	TRCell():New(oSection,"D0Z_CARGA" ,"D0Z",RetTitle("D0Z_CARGA" ),PesqPict("D0Z","D0Z_CARGA" ),TamSx3("D0Z_CARGA" )[1],/*lPixel*/,/*{|| code-block de impressao }*/,,,,,,.F.)
	TRCell():New(oSection,"C9_NFISCAL","SC9",RetTitle("C9_NFISCAL"),PesqPict("SC9","C9_NFISCAL"),TamSx3("C9_NFISCAL")[1],/*lPixel*/,/*{|| code-block de impressao }*/,,,,,,.F.)
	TRCell():New(oSection,"D0Z_PEDIDO","D0Z",RetTitle("D0Z_PEDIDO"),PesqPict("D0Z","D0Z_PEDIDO"),TamSx3("D0Z_PEDIDO")[1],/*lPixel*/,/*{|| code-block de impressao }*/,,,,,,.F.)
	TRCell():New(oSection,"D0Z_PRODUT","D0Z",RetTitle("D0Z_PRODUT"),PesqPict("D0Z","D0Z_PRODUT"),TamSx3("D0Z_PRODUT")[1],/*lPixel*/,/*{|| code-block de impressao }*/,,,,,,.F.)
	TRCell():New(oSection,"B1_DESC","SB1",RetTitle("B1_DESC"),PesqPict("SB1","B1_DESC"),TamSx3("B1_DESC")[1],/*lPixel*/,/*{|| code-block de impressao }*/,,,,,,.F.)
	TRCell():New(oSection,"D0Z_LOTECT","D0Z",RetTitle("D0Z_LOTECT"),PesqPict("D0Z","D0Z_LOTECT"),TamSx3("D0Z_LOTECT")[1],/*lPixel*/,/*{|| code-block de impressao }*/,,,,,,.F.)
	TRCell():New(oSection,"D0Z_QTDEMB","D0Z",RetTitle("D0Z_QTDEMB"),PesqPict("D0Z","D0Z_QTDEMB"),TamSx3("D0Z_QTDEMB")[1],/*lPixel*/,/*{|| code-block de impressao }*/,,,,,,.F.)
	TRCell():New(oSection,"DCV_CODVOL","DCV",RetTitle("DCV_CODVOL"),PesqPict("DCV","DCV_CODVOL"),TamSx3("DCV_CODVOL")[1],/*lPixel*/,/*{|| code-block de impressao }*/,,,,,,.F.)
	TRCell():New(oSection,"PESO","SB1",STR0003,PesqPict("SB1","B1_PESO"),TamSx3("B1_PESO")[1],/*lPixel*/,/*{|| (cAliasQRY)->PESO }*/,,,,,,.F.) //Peso
	TRCell():New(oSection,"A1_NOME","SA1",STR0004,PesqPict("SA1","A1_NOME"),TamSx3("A1_NOME")[1],/*lPixel*/,/*{|| code-block de impressao }*/,,,,,,.F.)//"Cliente"
	TRCell():New(oSection,"QTDPRD","SB1",STR0005,PesqPict("SB1","B1_PESO"),TamSx3("B1_PESO")[1],/*lPixel*/,/*{|| (cAliasQRY)->PESO }*/,,,,,,.F.) //"Qtd Prod Vol."
	TRCell():New(oSection,"DCV_QUANT","DCV",STR0006,PesqPict("DCV","DCV_QUANT"),TamSx3("DCV_QUANT")[1],/*lPixel*/,/*{|| code-block de impressao }*/,,,,,,.F.) //"Qtd Total Prod."

Return(oReport)

Static Function ReportPrint(oReport)
	Local oSection  := oReport:Section(1)
	Local lPrintPg := .F.
	Local cCGC  	:= ""
	Local cNome 	:= ""
	Local cEmb 		:=  ""  
	Local aVol 		:= {}
	Local aPed 		:= {}
	Local lVolOk 	:= .T.
	Local lPedOk 	:= .T.
	Local nPos 		:= 0
	Local cAliasQRY := ""
	Local nTotPrd  	:= 0 
	Local cAliasD0x := Nil

	//oReport:SetMeter (D0X->(LastRec()))
	If MV_PAR09 == 1
		oSection:Cell("B1_DESC"):Disable()
		oSection:Cell("D0Z_LOTECT"):Disable()
		oSection:Cell("D0Z_PRODUT"):Disable()
		oSection:Cell("D0Z_QTDEMB"):Disable()
		
	ElseIf MV_PAR09 == 2
		oSection:Cell("DCV_CODVOL"):Disable()
		oSection:Cell("PESO"):Disable()
		oSection:Cell("A1_NOME"):Disable()
		oSection:Cell("QTDPRD"):Disable()
		oSection:Cell("DCV_QUANT"):Disable()
	EndIf

    //Busca dados para impressão
	DBSelectArea("D0X")
	cAliasD0X := GetNextAlias()
	BeginSql Alias cAliasD0X
		SELECT D0X_EMBARQ,
				D0X_DATGER,
				D0X_HORGER,
				D0X_CODUSU,
				D0X_TRANSP,
				R_E_C_N_O_ AS D0X_RECNO
		FROM %table:D0X% D0X
		WHERE D0X.D0X_FILIAL =  %xFilial:D0X%
		And D0X_EMBARQ >= %Exp:MV_PAR01% 
		And D0X_EMBARQ <= %Exp:MV_PAR02%
		And D0X_DATGER >= %Exp:DTOS(MV_PAR03)% 
		And D0X_DATGER <= %Exp:DTOS(MV_PAR04)%
		And D0X_TRANSP >= %Exp:MV_PAR05%
		And D0X_TRANSP <= %Exp:MV_PAR06%
		And D0X_CODUSU >= %Exp:MV_PAR07% 
		And D0X_CODUSU <= %Exp:MV_PAR08%
		AND D0X.%NotDel% 
	EndSql 
	Do While (cAliasd0X)->(!Eof())
	    D0X->(DbGoto((cAliasd0X)->D0X_RECNO))
		cCGC 	 := ""
		cNome 	 := ""
		cEmb 	 := (cAliasd0X)->D0X_EMBARQ
		dDataEmb := Stod((cAliasd0X)->D0X_DATGER)
		CHoraEmb := (cAliasd0X)->D0X_HORGER
		cConf 	 := ""
		aVol	 := {}
		aPed 	 := {}
		lVolOk   := .T.
		lPedOk   := .T.
		nTotPrd  := 0

		oReport:IncMeter() 

		DCD->(dbsetorder(1))
		If DCD->(dbseek(xFilial("DCD") + (cAliasd0X)->D0X_CODUSU) )
			cConf := DCD->DCD_NOMFUN
		EndIf 

		If !Empty((cAliasd0X)->D0X_TRANSP)
			SA4->(dbsetorder(1))
			If SA4->(dbseek(xFilial("SA4") + (cAliasd0X)->D0X_TRANSP) )
				cCGC  := SA4->A4_CGC
				cNome := SA4->A4_NOME
			EndIf
		EndIf
			
		D0Z->(dbsetorder(1))
		If D0Z->(dbseek(xFilial("D0Z") + (cAliasd0X)->D0X_EMBARQ) )
			While !D0Z->(Eof()) .And. D0Z->D0Z_FILIAL == FWxFilial("D0Z") .And. D0Z->D0Z_EMBARQ == (cAliasd0X)->D0X_EMBARQ
				SB1->(dbsetorder(1))
				SB1->(dbseek(xFilial("SB1")+D0Z->D0Z_PRDORI) )
				SC9->(dbsetorder(1))
				If SC9->(dbseek(xFilial("SC9") + D0Z->D0Z_PEDIDO + D0Z->D0Z_ITEM + D0Z->D0Z_SEQUEN) )
					While !SC9->(Eof()) .And. SC9->C9_FILIAL == xFilial("SC9");
						.And. SC9->C9_PEDIDO = D0Z->D0Z_PEDIDO;
						.And. SC9->C9_ITEM = D0Z->D0Z_ITEM;
						.And. SC9->C9_SEQUEN = D0Z->D0Z_SEQUEN
					
						SA1->(dbsetorder(1))
						SA1->(dbseek(xFilial("SA1")+SC9->C9_CLIENTE + SC9->C9_LOJA) )

						If MV_PAR09 == 1
							DCV->(dbsetorder(5))
							If DCV->(dbseek(xFilial("DCV") + SC9->C9_PEDIDO + SC9->C9_ITEM + SC9->C9_SEQUEN) )
								Do While !DCV->(Eof()) .And. DCV->DCV_FILIAL == xFilial("DCV");
									.And. DCV->DCV_PEDIDO =  D0Z->D0Z_PEDIDO;
									.And. DCV->DCV_ITEM = D0Z->D0Z_ITEM;
									.And. DCV->DCV_SEQUEN = D0Z->D0Z_SEQUEN;
									.And. DCV->DCV_PRDORI = D0Z->D0Z_PRDORI
											
									If !lPrintPg
										oReport:StartPage()
										oSection:Init()
										oReport:SkipLine(1)
										oReport:PrintText(STR0007 + cCGC + "      " + STR0008 + cNome + "      " + STR0009 + cEmb + "  " + STR0010 +  cValToChar(dDataEmb) + " " + STR0011 + CHoraEmb) //("Transportador: " + cCGC + "      Nome: " + cNome + "      Embarque: " + cEmb + "  Data geração: " +  cValToChar(dDataEmb) + "  Hora: " + CHoraEmb)
										oReport:SkipLine(1)
									EndIf

									lVolOk := .F.
									If !Empty(DCV->DCV_CODVOL) .And. !Empty(aVol)
										if (nPos := ASCAN(aVol, { |x| x == DCV->DCV_CODVOL })) > 0
											//Ja encontrou volume
											lVolOk := .T.
											//exit
										EndIf
									EndIf
									
									lPedOk := .F.
									If !Empty(D0Z->D0Z_PEDIDO) .And. !Empty(aPed)
										If (nPos := ASCAN(aPed, { |x| x == D0Z->D0Z_PEDIDO })) > 0
											//Ja encontrou Pedido
											lPedOk := .T.
										EndIf
									EndIf
									If (!lPedOk .And. !Empty(D0Z->D0Z_PEDIDO))
										AAdd(aPed,D0Z->D0Z_PEDIDO)
									EndIf

									If (!lVolOk .And. !Empty(DCV->DCV_CODVOL)) .OR. (!lPedOk .AND. lVolOk .AND. !Empty(DCV->DCV_CODVOL ))
										AAdd(aVol,DCV->DCV_CODVOL)
									EndIf
									
									cAliasQRY := GetNextAlias()
									BeginSql Alias cAliasQRY
										SELECT SUM(DCV.DCV_QUANT) AS QUANT,
												SUM(SB1.B1_PESO*DCV.DCV_QUANT) as PESOVOL,
												COUNT(DISTINCT DCV.DCV_PRDORI)  AS QTDPRD
										FROM %Table:DCV% DCV
										INNER JOIN %Table:SB1%  SB1
										ON SB1.B1_FILIAL =  %xFilial:SB1%
										AND SB1.B1_COD = DCV_PRDORI
										WHERE DCV.DCV_FILIAL =  %xFilial:DCV% 
										AND DCV.DCV_CODVOL = %Exp:DCV->DCV_CODVOL% 
										AND DCV.DCV_PEDIDO  = %Exp:DCV->DCV_PEDIDO% 
										AND DCV.%NotDel% 
									EndSql 
									If (cAliasQRY)->(!Eof())
										oSection:Cell("PESO" ):SetValue( (cAliasQRY)->PESOVOL )
										oSection:Cell("QTDPRD" ):SetValue( (cAliasQRY)->QTDPRD )
										oSection:Cell("DCV_QUANT" ):SetValue( (cAliasQRY)->QUANT )
									EndIf
									(cAliasQRY)->(dbCloseArea())
									lPrintPg := .T.
									oSection:PrintLine()
									DCV->(dbSkip())
								EndDo
							EndIf
						Else 
							If !lPrintPg
								oReport:StartPage()
								oSection:Init()
								oReport:SkipLine(1)
								oReport:PrintText(STR0007 + cCGC + "      " + STR0008 + cNome + "      " + STR0009 + cEmb + "  " + STR0010 +  cValToChar(dDataEmb) + "  " + STR0011 + CHoraEmb)//("Transportador: " + cCGC + "      Nome: " + cNome + "      Embarque: " + cEmb + "  Data geração: " +  cValToChar(dDataEmb) + "  Hora: " + CHoraEmb)
								oReport:SkipLine(1)
							EndIf
							nPeso := SB1->B1_PESO * SC9->C9_QTDLIB
							nTotPrd += D0Z->D0Z_QTDEMB
							oSection:Cell(STR0003 ):SetValue( nPeso ) //"Peso"
							lPrintPg := .T.
							oSection:PrintLine()
						EndIf 
						SC9->(dbSkip())
					EndDo
				EndIf 
				D0Z->(dbSkip())
			EndDo		
		EndIf
		(cAliasD0X)->(dbSkip())
		If lPrintPg
			lPrintPg := .F.
			PrintRdp(@oReport,@oSection,aVol,cNome,cConf,aPed,nTotPrd)
			oSection:Finish()
			oReport:EndPage()
		EndIf
	EndDo
	(cAliasD0X)->(dbCloseArea())
Return

Static Function PrintRdp(oReport,oSection,aVol,cNome,cConf,aPed,nTotPrd)
	Local cLine     := "_______________________________________________________"
	oSection:Finish() 
	If MV_PAR09 == 1
		oReport:SkipLine(2)	
		oReport:ThinLine()
		oReport:SkipLine(1)	
		oReport:PrintText(STR0012 + cValToChar(Len(aVol)) + Space( 12 ) + STR0013 + cValToChar(Len(aPed)) ) //("Total de Volumes: " + cValToChar(Len(aVol)) + Space( 12 ) + "Total de Pedidos: " + cValToChar(Len(aPed)) )
	Else
		oReport:SkipLine(2)	
		oReport:ThinLine()
		oReport:SkipLine(1)	
		oReport:PrintText(STR0014 + cValToChar(nTotPrd)) //("Quantidade Total: " + cValToChar(nTotPrd))
	EndIf
	oReport:SkipLine(2)		
	oReport:PrintText(STR0015) //"Assinaturas"
	oReport:SkipLine(2)
	oReport:PrintText(cLine + Space( 12 ) + cLine)
	oReport:SkipLine(1)
	oReport:PrintText(STR0007 + cNome + Space( 12 ) +  STR0016  + cConf ) //("Transportador: " + cNome + Space( 12 ) +  "Conferente: "  + cConf ) 
Return
