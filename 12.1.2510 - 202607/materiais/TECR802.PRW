#INCLUDE "TOTVS.CH"  
#INCLUDE "TECR802.CH"
#INCLUDE "TOPCONN.CH"
Static cAutoPerg := "TECR802"
//--------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} TECR802()

Equipamentos x Locais

@sample 	TECR802()
@param 
@since		17/05/2015
@version	P12
/*/
//--------------------------------------------------------------------------------------------------------------------

Function TECR802()
	Local oReport

	#IFDEF TOP
		oReport := ReportDef()
		oReport:PrintDialog()
	#ELSE
		Help( ,, 'Help',, STR0014, 1, 0 )
	#ENDIF

Return

//--------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} ReportDef()

Processamento do relatorio de Equipamentos x Locais e Locais x Equipamentos

@sample 	ReportDef()
@param 
@since		17/05/2015
@version	P12
/*/
//--------------------------------------------------------------------------------------------------------------------
Static Function ReportDef()
	Local oReport  := Nil
	Local oSection1:= Nil
	Local oSection2:= Nil

	oReport:= TReport():New("TECR802",STR0001,"TECR802", {|oReport| ReportPrint(oReport)},STR0002 + " " + STR0003)	// "Equipamentos x Locais"###"Emissão do relatório que irá listar as movimentações de equipamentos"###"por postos."
	oReport:SetPortrait(.T.) 
	oReport:SetTotalInLine(.F.)

	oSection1 := TRSection():New(oReport, "STR0004", {"TRB"},{STR0005,STR0006} , .F., .F.) // "Resumo"###"Equipamento"###"Local"
	oSection1:SetTotalInLine(.F.)

	oSection2 := TRSection():New(oReport,STR0004,{"TRB"},,/*Campos do SX3*/,/*Campos do SIX*/)	
	oSection2:SetTotalInLine(.F.)

	Pergunte(oReport:uParam,.F.)

Return(oReport)

//--------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} ReportPrint(oReport)

Regra de impressao e geracao do relatorio

@sample 	ReportPrint()
@param 		oReport = Objeto TREPORT do relatorio
@since		17/05/2015
@version	P12
/*/
//--------------------------------------------------------------------------------------------------------------------
Static Function ReportPrint(oReport)
	Local cExpOrder := ""
	Local cExpFiltro:= ""
	Local cKeyFiltro:= ""
	Local cQuery    := ""
	Local oExec     := Nil

	If oReport:Section(1):GetOrder() == 1
		cExpOrder := "TFI_PRODUT, TEW_BAATD, TFI_PERINI"
		cExpFiltro:= "TFI_PRODUT+TEW_BAATD"
	Else
		cExpOrder := "TFI_LOCAL, TFI_PERINI"
		cExpFiltro:= "TFI_LOCAL"
	EndIf

	//Definicao das colunas conforme ordem
	If oReport:Section(1):GetOrder() == 1 //Por Equipamento
		TRCell():New(oReport:Section(1),"CCODPROD" 		,/*Tabela*/,FwNoAccent(STR0011)								,/*Picture*/	 			 ,TamSx3("TFI_PRODUT"  )[1],/*lPixel*/,{|| TRB->TFI_PRODUT	    })	
		TRCell():New(oReport:Section(1),"CDESCPRD" 		,/*Tabela*/,FwNoAccent(STR0012)								,/*Picture*/	 			 ,TamSx3("B1_DESC"     )[1],/*lPixel*/,{|| TRB->B1_DESC		    })
		TRCell():New(oReport:Section(1),"CNRSERIE" 		,/*Tabela*/,FwNoAccent(STR0013)								,/*Picture*/	 			 ,TamSx3("TEW_BAATD"   )[1],/*lPixel*/,{|| TRB->TEW_BAATD      })	

		TRCell():New(oReport:Section(2),"CCODPOSTO" 	,/*Tabela*/,FwNoAccent(STR0007)								,/*Picture*/	 			 ,TamSx3("TFI_LOCAL"   )[1],/*lPixel*/,{|| TRB->TFI_LOCAL   	})	
		TRCell():New(oReport:Section(2),"CNOMEPOSTO" 	,/*Tabela*/,FwNoAccent(STR0008)								,/*Picture*/	 			 ,TamSx3("ABS_DESCRI"  )[1],/*lPixel*/,{|| TRB->ABS_DESCRI		})	
		TRCell():New(oReport:Section(2),"DDTINICIO" 	,/*Tabela*/,FwNoAccent(STR0009)								,/*Picture*/	 			 ,TamSx3("TFI_PERINI"  )[1],/*lPixel*/,{|| TRB->TFI_PERINI	    })	
		TRCell():New(oReport:Section(2),"DDTFIM" 	    ,/*Tabela*/,FwNoAccent(STR0010)								,/*Picture*/	 			 ,TamSx3("TFI_PERFIM"  )[1],/*lPixel*/,{|| TRB->TFI_PERFIM      })	

	Else //Por Posto
		TRCell():New(oReport:Section(1),"CCODPOSTO" 	,/*Tabela*/,FwNoAccent(STR0007)								,/*Picture*/	 			 ,TamSx3("TFI_LOCAL"   )[1],/*lPixel*/,{|| TRB->TFI_LOCAL	   })	
		TRCell():New(oReport:Section(1),"CNOMEPOSTO" 	,/*Tabela*/,FwNoAccent(STR0008)								,/*Picture*/	 			 ,TamSx3("ABS_DESCRI"  )[1],/*lPixel*/,{|| TRB->ABS_DESCRI     })	

		TRCell():New(oReport:Section(2),"CCODPROD" 		,/*Tabela*/,FwNoAccent(STR0011)								,/*Picture*/	 			 ,TamSx3("TFI_PRODUT"  )[1],/*lPixel*/,{|| TRB->TFI_PRODUT	   })	
		TRCell():New(oReport:Section(2),"CDESCPRD" 		,/*Tabela*/,FwNoAccent(STR0012)								,/*Picture*/	 			 ,TamSx3("B1_DESC"     )[1],/*lPixel*/,{|| TRB->B1_DESC		   })	
		TRCell():New(oReport:Section(2),"CNRSERIE" 		,/*Tabela*/,FwNoAccent(STR0013)								,/*Picture*/	 			 ,TamSx3("TEW_BAATD"   )[1],/*lPixel*/,{|| TRB->TEW_BAATD      })	
		TRCell():New(oReport:Section(2),"DDTINICIO" 	,/*Tabela*/,FwNoAccent(STR0009)								,/*Picture*/	 			 ,TamSx3("TFI_PERINI"  )[1],/*lPixel*/,{|| TRB->TFI_PERINI     })	
		TRCell():New(oReport:Section(2),"DDTFIM" 	    ,/*Tabela*/,FwNoAccent(STR0010)								,/*Picture*/	 			 ,TamSx3("TFI_PERFIM"  )[1],/*lPixel*/,{|| TRB->TFI_PERFIM     })	
	EndIf

	cQuery := " SELECT DISTINCT TFI_LOCAL, ABS_DESCRI, TFI_PRODUT, B1_DESC, TEW_BAATD, TFI_PERINI, TFI_PERFIM "
	cQuery += " FROM ? TEW "
	cQuery += " INNER JOIN ? TFI ON "
	cQuery += "       TFI.TFI_FILIAL = ? AND TFI.TFI_COD = TEW.TEW_CODEQU AND TFI.D_E_L_E_T_ = ' ' "
	cQuery += " INNER JOIN ? SB1 ON "
	cQuery += "	      SB1.B1_FILIAL  = ? AND SB1.B1_COD = TFI.TFI_PRODUT AND SB1.D_E_L_E_T_ = ' ' "
	cQuery += " INNER JOIN ? ABS ON "
	cQuery += "	      ABS.ABS_FILIAL = ? AND ABS.ABS_LOCAL = TFI.TFI_LOCAL AND ABS.D_E_L_E_T_ = ' ' "
	cQuery += "	WHERE TEW_FILIAL = ? AND TEW.D_E_L_E_T_ = ' ' AND "
	cQuery +=       " (( TFI.TFI_PERINI BETWEEN ? AND ? ) OR "
	cQuery +=       "  ( TFI.TFI_PERFIM BETWEEN ? AND ? ) OR "
	cQuery +=       "  ( TFI.TFI_PERINI <= ? AND TFI.TFI_PERFIM >= ? )) AND "
	cQuery +=       " TFI.TFI_PRODUT >= ? AND TFI.TFI_PRODUT <= ? AND "
	cQuery +=       " TEW.TEW_BAATD  >= ? AND TEW.TEW_BAATD  <= ? AND "
	cQuery +=       " TFI.TFI_LOCAL  >= ? AND TFI.TFI_LOCAL  <= ? "
	cQuery += " ORDER BY ? "

	cQuery := ChangeQuery(cQuery)
	oExec := FwExecStatement():New(cQuery)

	oExec:SetUnsafe( 1, RetSqlName("TEW") )
	oExec:SetUnsafe( 2, RetSqlName("TFI") )
	oExec:SetString( 3, xFilial("TFI") )
	oExec:SetUnsafe( 4, RetSqlName("SB1") )
	oExec:SetString( 5, xFilial("SB1") )
	oExec:SetUnsafe( 6, RetSqlName("ABS") )
	oExec:SetString( 7, xFilial("ABS") )
	oExec:SetString( 8, xFilial("TEW") )
	oExec:SetDate(  9, mv_par01 )
	oExec:SetDate( 10, mv_par02 )
	oExec:SetDate( 11, mv_par01 )
	oExec:SetDate( 12, mv_par02 )
	oExec:SetDate( 13, mv_par01 )
	oExec:SetDate( 14, mv_par02 )
	oExec:SetString( 15, mv_par03 )
	oExec:SetString( 16, mv_par04 )
	oExec:SetString( 17, mv_par05 )
	oExec:SetString( 18, mv_par06 )
	oExec:SetString( 19, mv_par07 )
	oExec:SetString( 20, mv_par08 )
	oExec:SetUnsafe( 21, cExpOrder )

	oExec:OpenAlias("TRB")
	dbSelectArea("TRB")

	oReport:SetMeter(RecCount())

	While TRB->(!Eof())
		If oReport:Cancel()
			Exit
		EndIf
		
		oReport:Section(1):Init()

		If oReport:Section(1):GetOrder() == 1
			oReport:Section(1):Cell("CCODPROD"):SetValue(TRB->TFI_PRODUT)
			oReport:Section(1):Cell("CDESCPRD"):SetValue(TRB->B1_DESC)
		Else
			oReport:Section(1):Cell("CCODPOSTO"):SetValue(TRB->TFI_LOCAL)
			oReport:Section(1):Cell("CNOMEPOSTO"):SetValue(TRB->ABS_DESCRI)
		EndIf

		If !isBlind()
			oReport:Section(1):PrintLine()
		EndIF

		//Secao 2 - dados analiticos
		cKeyFiltro := TRB->&(cExpFiltro)
		oReport:Section(2):Init()
		While TRB->(!Eof()) .And. TRB->&(cExpFiltro) == cKeyFiltro
			oReport:IncMeter()
			If oReport:Section(1):GetOrder() == 1
				oReport:Section(2):Cell("CCODPOSTO"):SetValue(TRB->TFI_LOCAL)
				oReport:Section(2):Cell("CNOMEPOSTO"):SetValue(TRB->ABS_DESCRI)	
				oReport:Section(2):Cell("DDTINICIO"):SetValue(DToC(SToD(TRB->TFI_PERINI)))
				oReport:Section(2):Cell("DDTFIM"):SetValue(DToC(SToD(TRB->TFI_PERFIM)))
			Else
				oReport:Section(2):Cell("CCODPROD"):SetValue(TRB->TFI_PRODUT)
				oReport:Section(2):Cell("CDESCPRD"):SetValue(TRB->B1_DESC)
				oReport:Section(2):Cell("CNRSERIE"):SetValue(TRB->TEW_BAATD)
				oReport:Section(2):Cell("DDTINICIO"):SetValue(DToC(SToD(TRB->TFI_PERINI)))
				oReport:Section(2):Cell("DDTFIM"):SetValue(DToC(SToD(TRB->TFI_PERFIM)))
			EndIf
			If !isBlind()
				oReport:Section(2):PrintLine()
			EndIf
			TRB->(dbSkip())
		EndDo
		
		oReport:Section(2):Finish()
		oReport:Section(1):Finish()
	EndDo

	TRB->(DbCloseArea())
	oExec:Destroy()
	FwFreeObj(oExec)
Return

//-------------------------------------------------------------------------------------
/*/{Protheus.doc} PrintReport
Chama a função ReportPrint
Chamada utilizada na automação de código.

@author Mateus Boiani
@since 31/10/2018
@return objeto Report
/*/
//-------------------------------------------------------------------------------------
Static Function PrintReport ( oReport )

Return ReportPrint( oReport )

//-------------------------------------------------------------------------------------
/*/{Protheus.doc} GetPergTRp
Retorna o nome do Pergunte utilizado no relatório
Função utilizada na automação
@author Mateus Boiani
@since 31/10/2018
@return cAutoPerg, string, nome do pergunte
/*/
//-------------------------------------------------------------------------------------
Static Function GetPergTRp()

Return cAutoPerg
