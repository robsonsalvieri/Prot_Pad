#INCLUDE "locr009.ch" 
#INCLUDE "PROTHEUS.CH"
#INCLUDE "TOTVS.CH"     
#INCLUDE "RWMAKE.CH"     
#INCLUDE "TOPCONN.CH"                                                                                        

/*/{PROTHEUS.DOC} LOCR009.PRW
ITUP BUSINESS - TOTVS RENTAL
Relatório quadro resumo
@TYPE FUNCTION
@AUTHOR FRANK ZWARG FUGA
@SINCE 03/12/2020
@VERSION P12
@HISTORY 03/12/2020, FRANK ZWARG FUGA, FONTE PRODUTIZADO.
/*/

FUNCTION LOCR009()
Local lMvLocBac	:= SuperGetMv("MV_LOCBAC",.F.,.F.) //Integração com Módulo de Locações SIGALOC
Local nX

PRIVATE OREPORT
PRIVATE CTITULO := STR0001 //"QUADRO RESUMO"
PRIVATE OBREAK
PRIVATE	NTGOCU	:=	0
PRIVATE	NTGDISP	:=	0
PRIVATE NTOCU	:=	0
PRIVATE NTDISP	:=	0
Private aStatus := {} // status de para ST9 x TQY x FQD
Private	CT61
Private	CTI61

	//  codigo interno, usado na ST9
	aadd(aStatus,{"00",""})
	aadd(aStatus,{"10",""})
	aadd(aStatus,{"20",""})
	aadd(aStatus,{"40",""})
	aadd(aStatus,{"50",""})
	aadd(aStatus,{"60",""})
	aadd(aStatus,{"90",""})

	If lMvLocBac
		FQD->(dbSetOrder(1))
		FQD->(dbGotop())
		While !FQD->(Eof())
			If FQD->FQD_FILIAL == xFilial("FQD") .and. !empty(FQD->FQD_STATQY)
				For nX := 1 to len(aStatus)
					If aStatus[nX,1] == FQD->FQD_STAREN
						aStatus[nX,2] := FQD->FQD_STATQY
					EndIF
				Next
			EndIf
			FQD->(dbSkip())
		EndDo
	else
		TQY->(dbSetOrder(1))
		TQY->(dbGotop())
		While !TQY->(Eof())
			If TQY->TQY_FILIAL == xFilial("TQY") .and. !empty(TQY->TQY_STATUS)
				For nX := 1 to len(aStatus)
					If aStatus[nX,1] == TQY->TQY_STTCTR
						aStatus[nX,2] := TQY->TQY_STATUS
					EndIF
				Next
			EndIf
			TQY->(dbSkip())
		EndDo
	EndIF


	IF TREPINUSE()   
		IF PERGPARAM("LOCR009")
			OREPORT := REPORTDEF()
			IF MV_PAR11 == 2
				OREPORT:SETLANDSCAPE()
			ENDIF
			//OREPORT:SETDEVICE(4)    // MODO DEFAULT DE IMPRESS???O  4 = PLANILHA
			OREPORT:PRINTDIALOG()
		ENDIF
	ENDIF       

RETURN         

/*?????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????
???????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????
???????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????
?????????FUNCAO    ??? REPORTDEF??? AUTOR ??? MIGUEL GONTIJO        ??? DATA ???09/02/2017?????????
???????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????
?????????DESCRICAO ??? DEFINICAO DO LAYOUT DO RELATORIO                           ?????????
???????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????±???
???????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????
?????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????*/ 
STATIC FUNCTION REPORTDEF()
LOCAL OSECTION
LOCAL OSECTION1
LOCAL OSECTION2

PRIVATE CFILBRK := CFILANT

	//??????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????
	//???CRIACAO DO COMPONENTE DE IMPRESSAO                                      ???
	//???                                                                        ???
	//???TREPORT():NEW                                                           ???
	//???EXPC1 : NOME DO RELATORIO                                               ???
	//???EXPC2 : TITULO                                                          ???
	//???EXPC3 : PERGUNTE                                                        ???
	//???EXPB4 : BLOCO DE CODIGO QUE SERA EXECUTADO NA CONFIRMACAO DA IMPRESSAO  ???
	//???EXPC5 : DESCRICAO                                                       ???
	//??????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????
	OREPORT  := TREPORT():NEW("LOCR009",CTITULO,"LOCR009",{|OREPORT| PRINTREPORT()},CTITULO)
	//OREPORT:NFONTBODY    := 10
	//OREPORT:CFONTBODY    := "CALIBRI"
	//OREPORT:LUNDERLINE := .F.
	OREPORT:TOTALINLINE(.F.)	// IMPRIME TOTAL EM LINHA OU COLUNA (DEFAULT .T. - LINHA )
	//SETBORDER(UBORDER,NWEIGHT,NCOLOR,LHEADER)
	OREPORT:LPARAMPAGE := .F.
	OREPORT:LPRTPARAMPAGE := .F.
	OREPORT:UPARAM := {|| PERGPARAM("LOCR009") }

	IF MV_PAR11 == 1

		//OSECTION := TRSECTION():NEW(OREPORT) //,"PROJETOS",{"ST9","SHB"})
		OSECTION := TRSECTION():NEW(OREPORT,STR0019,{"ST9"}) //,"PROJETOS",{"ST9","SHB"}) //"Centro Trab."
		TRCELL():NEW(OSECTION,"CENTRAB"	,"ST9","", , 60		)
		//OREPORT:SKIPLINE()
		//	OREPORT:THINLINE()
		//OSECTION :SETLINESTYLE(.F.)

		//OSECTION1 := TRSECTION():NEW(OREPORT) // ,"PROJETOS",{"ST9","SHB"})
		OSECTION1 := TRSECTION():NEW(OSECTION,STR0011,{"ST9"}) // ,"PROJETOS",{"ST9","SHB"})
		TRCELL():NEW(OSECTION1,"T9_CODFAMI"	,"ST9",RETTITLE("T9_CODFAMI"), , 30	)
		TRCELL():NEW(OSECTION1,"T6_NOME"	,"ST9",RETTITLE("T6_NOME"), , 30	)
		TRCELL():NEW(OSECTION1,"QTDBEM"		,"ST9",STR0002		, , 10		) //"QTD. BEM"
		TRCELL():NEW(OSECTION1,"DISP"		,"ST9",STR0003		, , 15		) //"DISPONIVEL"
		TRCELL():NEW(OSECTION1,"CON"		,"ST9",STR0004	, , 15		) //"EM CONTRATO"
		//TRCELL():NEW(OSECTION1,"MNT"		,"ST9","MANUTENCAO"		, , 15		)
		//TRCELL():NEW(OSECTION1,"NFRR"		,"ST9","INSPECAO"		, , 15		)
		TRCELL():NEW(OSECTION1,"NFRE"		,"ST9",STR0005			, , 15		) //"LOCADO"
		//TRCELL():NEW(OSECTION1,"TRE"		,"ST9","EM TRANSITO"	, , 15		)
		//TRCELL():NEW(OSECTION1,"ENT"		,"ST9","ENTREGUE"		, , 15		)
		TRCELL():NEW(OSECTION1,"SRT"		,"ST9",STR0006 , , 20		) //"SOLIC.RETIRADA"
		//TRCELL():NEW(OSECTION1,"PAR"		,"ST9","EM PARCEIRO"	, , 15		)
		TRCELL():NEW(OSECTION1,"OTR"		,"ST9",STR0007			, , 15		) //"OUTROS"
		TRCELL():NEW(OSECTION1,"OCUP"		,"ST9",STR0008		, , 15		) //"OCUPACAO %"
		/*
		OSECTION1:CELL("QTDBEM"	):SETALIGN("CENTER")	
		OSECTION1:CELL("DISP"	):SETALIGN("CENTER")
		OSECTION1:CELL("CON"	):SETALIGN("CENTER")
		OSECTION1:CELL("NFRE"	):SETALIGN("CENTER")
		OSECTION1:CELL("TRE"	):SETALIGN("CENTER")
		OSECTION1:CELL("NFRR"	):SETALIGN("CENTER")
		OSECTION1:CELL("OCUP"	):SETALIGN("CENTER")
		OSECTION1:CELL("ENT"	):SETALIGN("CENTER")
		OSECTION1:CELL("SRT"	):SETALIGN("CENTER")
		OSECTION1:CELL("PAR"	):SETALIGN("CENTER")
		OSECTION1:CELL("OTR"	):SETALIGN("CENTER")	
		OSECTION1:CELL("MNT"	):SETALIGN("CENTER")
		*/
		OBREAK := TRBREAK():NEW(OSECTION1,OSECTION:CELL("CENTRAB"),STR0009) //"SUB TOTAIS"

		TREPORT():TOTALINLINE(.T.)		// IMPRIME TOTAL EM LINHA OU COLUNA (DEFAULT .T. - LINHA )   
		TRFUNCTION():NEW(OSECTION1:CELL("QTDBEM") ,NIL,"SUM",OBREAK,,,,.F.,.T.) 	
		TRFUNCTION():NEW(OSECTION1:CELL("DISP") ,NIL,"SUM",OBREAK,,,,.F.,.T.) 	
		TRFUNCTION():NEW(OSECTION1:CELL("CON") ,NIL,"SUM",OBREAK,,,,.F.,.T.) 
		//TRFUNCTION():NEW(OSECTION1:CELL("MNT") ,NIL,"SUM",OBREAK,,,,.F.,.T.) 
		//TRFUNCTION():NEW(OSECTION1:CELL("NFRR") ,NIL,"SUM",OBREAK,,,,.F.,.T.) 
		TRFUNCTION():NEW(OSECTION1:CELL("NFRE") ,NIL,"SUM",OBREAK,,,,.F.,.T.) 
		//TRFUNCTION():NEW(OSECTION1:CELL("TRE") ,NIL,"SUM",OBREAK,,,,.F.,.T.) 
		//TRFUNCTION():NEW(OSECTION1:CELL("ENT") ,NIL,"SUM",OBREAK,,,,.F.,.T.) 
		TRFUNCTION():NEW(OSECTION1:CELL("SRT") ,NIL,"SUM",OBREAK,,,,.F.,.T.) 
		//TRFUNCTION():NEW(OSECTION1:CELL("PAR") ,NIL,"SUM",OBREAK,,,,.F.,.T.) 
		TRFUNCTION():NEW(OSECTION1:CELL("OTR") ,NIL,"SUM",OBREAK,,,,.F.,.T.) 		
		TRFUNCTION():NEW(OSECTION1:CELL("OCUP"),NIL,"ONPRINT",OBREAK,,,{|| ROUND((NTGOCU/NTGDISP)*100,2) },.F.,.T.) 		

	ELSEIF MV_PAR11 == 2

		//OSECTION := TRSECTION():NEW(OREPORT ,STR0010,{"FQ4"}) //"PROJETOS"
		//OSECTION := TRSECTION():NEW(OREPORT ,STR0011,{"FQ4"}) //"PROJETOS"
		OSECTION := TRSECTION():NEW(OREPORT ,STR0011,{"ST9","FQ4"}) //"PROJETOS"
		TRCELL():NEW(OSECTION,"T9_CODFAMI"	,"FQ4",STR0011 , PESQPICT("ST9","T9_CODFAMI"	) , 60 /*SIZE*/ , /*LPIXEL*/, /*{|| BLOCK } */ ) //"FAMILIA"
		/*
		TRCELL():NEW(OSECTION,"DISP"		,"ST9",STR0003		, , 15		) //"DISPONIVEL"
		TRCELL():NEW(OSECTION,"CON"		,"ST9",STR0004	, , 15		) //"EM CONTRATO"
		//TRCELL():NEW(OSECTION,"MNT"		,"ST9","MANUTENCAO"		, , 15		)
		//TRCELL():NEW(OSECTION,"NFRR"		,"ST9","INSPECAO"		, , 15		)
		TRCELL():NEW(OSECTION,"NFRE"		,"ST9","LOCADO"			, , 15		)
		//TRCELL():NEW(OSECTION,"TRE"		,"ST9","EM TRANSITO"	, , 15		)
		//TRCELL():NEW(OSECTION,"ENT"		,"ST9","ENTREGUE"		, , 15		)
		TRCELL():NEW(OSECTION,"SRT"		,"ST9",STR0006 , , 20		) //"SOLIC.RETIRADA"
		//TRCELL():NEW(OSECTION,"PAR"		,"ST9","EM PARCEIRO"	, , 15		)
		TRCELL():NEW(OSECTION,"OTR"		,"ST9",STR0007			, , 15		) //"OUTROS"
		TRCELL():NEW(OSECTION,"OCUP"		,"ST9",STR0008		, , 15		) //"OCUPACAO %"
		*/
		//OSECTION1 := TRSECTION():NEW(OREPORT) // ,"PROJETOS",{"ST9","SHB"})
		OSECTION1 := TRSECTION():NEW(OSECTION,STR0020,{"ST9"}) // ,"PROJETOS",{"ST9","SHB"}) // "Bem"
		TRCELL():NEW(OSECTION1,"T9_CODBEM"	,"FQ4","" , PESQPICT("ST9","T9_CODBEM"	) , 60 /*SIZE*/ , /*LPIXEL*/, /*{|| BLOCK } */ )

		//OSECTION2 := TRSECTION():NEW(OREPORT ,STR0010,{"FQ4"}) //"PROJETOS"
		//OSECTION2 := TRSECTION():NEW(OREPORT ,STR0013,{"FQ4"}) //"PROJETOS"
		OSECTION2 := TRSECTION():NEW(OSECTION ,STR0013,{"FQ4"}) //"Historico do Bem"
		TRCELL():NEW(OSECTION2,"T9_STATUS"	,"FQ4",RETTITLE("T9_STATUS") , PESQPICT("TQY","TQY_DESTAT"	) , 10 , /*LPIXEL*/, /*{|| BLOCK } */ )
		TRCELL():NEW(OSECTION2,"T9_CODFAMI"	,"FQ4",RETTITLE("T9_CODFAMI") , PESQPICT("ST9","T9_CODFAMI"	) , 10 , /*LPIXEL*/, /*{|| BLOCK } */ )
		TRCELL():NEW(OSECTION2,"T9_TIPMOD"	,"FQ4",RETTITLE("T9_TIPMOD") , PESQPICT("ST9","T9_TIPMOD"	) , /*SIZE*/ , /*LPIXEL*/, /*{|| BLOCK } */ )
		TRCELL():NEW(OSECTION2,"T9_FABRICA"	,"FQ4",RETTITLE("T9_FABRICA") , PESQPICT("ST9","T9_FABRICA"	) , /*SIZE*/ , /*LPIXEL*/, /*{|| BLOCK } */ )
		//TRCELL():NEW(OSECTION2,"T9_XSUBLOC"	,"FQ4",RETTITLE("T9_XSUBLOC") , PESQPICT("ST9","T9_XSUBLOC"	) , /*SIZE*/ , /*LPIXEL*/, /*{|| BLOCK } */ )
		//TRCELL():NEW(OSECTION1,"FQ4_POSCON"	,"FQ4",RETTITLE("FQ4_POSCON") , PESQPICT("FQ4","FQ4_POSCON"	) , /*SIZE*/ , /*LPIXEL*/, /*{|| BLOCK } */ )
		TRCELL():NEW(OSECTION2,"HB_COD"	,"FQ4",RETTITLE("HB_COD") , PESQPICT("SHB","HB_COD"	) , /*SIZE*/ , /*LPIXEL*/, /*{|| BLOCK } */ )
		TRCELL():NEW(OSECTION2,"HB_NOME"	,"FQ4",RETTITLE("HB_NOME") , PESQPICT("SHB","HB_NOME"	) , /*SIZE*/ , /*LPIXEL*/, /*{|| BLOCK } */ )
		TRCELL():NEW(OSECTION2,"FQ4_OS"		,"FQ4",RETTITLE("FQ4_OS"	) , PESQPICT("FQ4","FQ4_OS"		) , /*SIZE*/ , /*LPIXEL*/, /*{|| BLOCK } */ )
		TRCELL():NEW(OSECTION2,"FQ4_SERVIC"	,"FQ4",RETTITLE("FQ4_SERVIC") , PESQPICT("FQ4","FQ4_SERVIC"	) , /*SIZE*/ , /*LPIXEL*/, /*{|| BLOCK } */ )
		TRCELL():NEW(OSECTION2,"FQ4_PRELIB"	,"FQ4",RETTITLE("FQ4_PRELIB") , PESQPICT("FQ4","FQ4_PRELIB"	) , /*SIZE*/ , /*LPIXEL*/, /*{|| BLOCK } */ )
		TRCELL():NEW(OSECTION2,"FQ4_CODCLI"	,"FQ4",RETTITLE("FQ4_CODCLI") , PESQPICT("FQ4","FQ4_CODCLI"	) , /*SIZE*/ , /*LPIXEL*/, /*{|| BLOCK } */ )
		TRCELL():NEW(OSECTION2,"FQ4_NOMCLI"	,"FQ4",RETTITLE("FQ4_NOMCLI") , PESQPICT("FQ4","FQ4_NOMCLI"	) , /*SIZE*/ , /*LPIXEL*/, /*{|| BLOCK } */ )
		TRCELL():NEW(OSECTION2,"A1_END"		,"FQ4",RETTITLE("A1_END") 	  , PESQPICT("SA1","A1_END"	) 	  , /*SIZE*/ , /*LPIXEL*/, /*{|| BLOCK } */ )
		TRCELL():NEW(OSECTION2,"A1_MUN"		,"FQ4",RETTITLE("A1_MUN") 	  , PESQPICT("SA1","A1_MUN"	) 	  , /*SIZE*/ , /*LPIXEL*/, /*{|| BLOCK } */ )
		TRCELL():NEW(OSECTION2,"A1_EST"		,"FQ4",RETTITLE("A1_EST") 	  , PESQPICT("SA1","A1_EST"	) 	  , /*SIZE*/ , /*LPIXEL*/, /*{|| BLOCK } */ )
		TRCELL():NEW(OSECTION2,"FQ4_DTINI" 	,"FQ4",RETTITLE("FQ4_DTINI" ) , PESQPICT("FQ4","FQ4_DTINI" 	) , /*SIZE*/ , /*LPIXEL*/, /*{|| BLOCK } */ )
		TRCELL():NEW(OSECTION2,"FQ4_DTFIM" 	,"FQ4",RETTITLE("FQ4_DTFIM" ) , PESQPICT("FQ4","FQ4_DTFIM" 	) , /*SIZE*/ , /*LPIXEL*/, /*{|| BLOCK } */ )
		TRCELL():NEW(OSECTION2,"FQ4_PROJET"	,"FQ4",RETTITLE("FQ4_PROJET") , PESQPICT("FQ4","FQ4_PROJET"	) , /*SIZE*/ , /*LPIXEL*/, /*{|| BLOCK } */ )
		TRCELL():NEW(OSECTION2,"FQ4_OBRA" 	,"FQ4",RETTITLE("FQ4_OBRA" 	) , PESQPICT("FQ4","FQ4_OBRA" 	) , /*SIZE*/ , /*LPIXEL*/, /*{|| BLOCK } */ )
		TRCELL():NEW(OSECTION2,"FQ4_AS"		,"FQ4",RETTITLE("FQ4_AS"	) , PESQPICT("FQ4","FQ4_AS"		) , /*SIZE*/ , /*LPIXEL*/, /*{|| BLOCK } */ )
		TRCELL():NEW(OSECTION2,"FQ4_PREDES"	,"FQ4",RETTITLE("FQ4_PREDES") , PESQPICT("FQ4","FQ4_PREDES"	) , /*SIZE*/ , /*LPIXEL*/, /*{|| BLOCK } */ )
		TRCELL():NEW(OSECTION2,"FQ4_LOG"	,"FQ4",RETTITLE("FQ4_LOG"	) , PESQPICT("FQ4","FQ4_LOG"	) , /*SIZE*/ , /*LPIXEL*/, /*{|| BLOCK } */ )
		/*
		OBREAK := TRBREAK():NEW(OSECTION2,OSECTION:CELL("T9_CODFAMI"),STR0009) //"SUB TOTAIS"
		TREPORT():TOTALINLINE(.T.)		// IMPRIME TOTAL EM LINHA OU COLUNA (DEFAULT .T. - LINHA )   
		TRFUNCTION():NEW(OSECTION:CELL("DISP") ,NIL,"SUM",OBREAK,,,,.F.,.T.)
		TRFUNCTION():NEW(OSECTION:CELL("CON") ,NIL,"SUM",OBREAK,,,,.F.,.T.) 
		//TRFUNCTION():NEW(OSECTION:CELL("MNT") ,NIL,"SUM",OBREAK,,,,.F.,.T.) 
		//TRFUNCTION():NEW(OSECTION:CELL("NFRR") ,NIL,"SUM",OBREAK,,,,.F.,.T.) 
		TRFUNCTION():NEW(OSECTION:CELL("NFRE") ,NIL,"SUM",OBREAK,,,,.F.,.T.) 
		//TRFUNCTION():NEW(OSECTION:CELL("TRE") ,NIL,"SUM",OBREAK,,,,.F.,.T.) 
		//TRFUNCTION():NEW(OSECTION:CELL("ENT") ,NIL,"SUM",OBREAK,,,,.F.,.T.) 
		TRFUNCTION():NEW(OSECTION:CELL("SRT") ,NIL,"SUM",OBREAK,,,,.F.,.T.) 
		//TRFUNCTION():NEW(OSECTION:CELL("PAR") ,NIL,"SUM",OBREAK,,,,.F.,.T.) 
		TRFUNCTION():NEW(OSECTION:CELL("OTR") ,NIL,"SUM",OBREAK,,,,.F.,.T.) 		
		TRFUNCTION():NEW(OSECTION:CELL("OCUP"),NIL,"ONPRINT",OBREAK,,,{|| ROUND((NTGOCU/NTGDISP)*100,2) },.F.,.T.) 
		*/
		OSECTION3 := TRSECTION():NEW(OREPORT , STR0021) //"Total geral"
		OSECTION3:NoUserFilter()
		OSECTION3:lReadOnly := .T.
		TRCELL():NEW(OSECTION3,"QUANTIDADE"	,"",	STR0022 	,  ,  	200, /*LPIXEL*/, /*{|| BLOCK } */ ) // "Qtde. Bens"
		TRCELL():NEW(OSECTION3,"DISPONIVEL"	,"",	STR0003 	,  ,  	200, /*LPIXEL*/, /*{|| BLOCK } */ ) //"Disponivel"
		TRCELL():NEW(OSECTION3,"CONTRATO"	,"",	STR0004 	,  ,  	200, /*LPIXEL*/, /*{|| BLOCK } */ ) //"Em contrato"
		TRCELL():NEW(OSECTION3,"LOCADO"		,"",	STR0005		,  ,  	200, /*LPIXEL*/, /*{|| BLOCK } */ ) // "Locado" 
		TRCELL():NEW(OSECTION3,"RETIRADA"	,"", 	STR0006		,  ,  	200, /*LPIXEL*/, /*{|| BLOCK } */ ) // "Solic.Retirada"
		TRCELL():NEW(OSECTION3,"OUTROS"		,"",	STR0007 	,  , 	200, /*LPIXEL*/, /*{|| BLOCK } */ )	// "Outros"
		TRCELL():NEW(OSECTION3,"OCUPACAO"	,"",	STR0008 	,  ,  	200, /*LPIXEL*/, /*{|| BLOCK } */ ) // "Ocupação %"

	ENDIF

RETURN OREPORT
/*???????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????
?????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????
?????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????
?????????FUNCAO    ??? PRINTREPORT??? AUTOR ??? MIGUEL GONTIJO        ??? DATA ???09/02/2017?????????
?????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????
?????????DESCRICAO ??? IMPRIME RELATORIO                                            ?????????
?????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????±???
?????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????
???????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????*/
STATIC FUNCTION PRINTREPORT()
//LOCAL OSECTION1 := OREPORT:SECTION(1)
//LOCAL OSECTION2 := OREPORT:SECTION(2)
//LOCAL OSECTION3 := OREPORT:SECTION(3)
LOCAL CAUX 		:=	""
LOCAL CAUX2		:=	""
Local cFamiAux	:=  ""
Local cFiltroAux:=  ""
LOCAL NINC 		:=	1
Local nX		:= 	0
Local nSoma		:= 	0
Local nDisp		:= 	0
Local nCon		:= 	0
Local nNfRe		:= 	0
Local nOcup		:= 	0
Local nStr		:= 	0
Local nOtr		:= 	0
Local lPula 	:= .F.

	//Monta as Seções de acordo com o Pergunte
	If MV_PAR11 == 1
		oSection1 := oReport:Section(1)
		oSection2 := oSection1:Section(1)
	ElseIf MV_PAR11 == 2
		oSection1 := oReport:Section(1)
		oSection2 := oSection1:Section(1)
		oSection3 := oSection1:Section(2)
		oSection4 := oReport:Section(2)
	EndIf

	IF SELDADOS()
		IF MV_PAR11 == 1

			//NOCUPACAO	:=	ST9TRB->TNFRE/ST9TRB->QTDBEMCTR
			OREPORT:SETMETER( ST9TRB->( RECCOUNT()) )
			CAUX := ST9TRB->T9_CENTRAB

			//posiciona para respeitar o filtro do TReport - Seção Centro de Trab.
			ST9->(DbSetOrder(10)) //T9_FILIAL+T9_CENTRAB

			WHILE ST9TRB->(! EOF())

				IF OREPORT:CANCEL()
					EXIT
				ENDIF

				//se existir filtro de usuario
				If Len(oSection1:aUserFilter) > 0
					lPula 		:= .F.
					cFiltroAux	:= ""
					If !Empty(oSection1:aUserFilter[1][2])
						If At("ST9",oSection1:aUserFilter[1][1]) > 0
							//posiciona para respeitar o filtro do TReport - Seção Centro de Trab.
							If ST9->(DbSeek(xFilial("ST9") + ST9TRB->T9_CENTRAB))
								//Verifica os filtros de usuários e pula caso não esteja na regra
								For nX := 1 To Len(oSection1:aUserFilter)
									//só consegue considerar centro de trabalho e família, pois é aglutinado por Centro de Trabalho, depois família
									If At("T9_CENTRAB",oSection1:aUserFilter[nX][2]) > 0 .Or. At("T9_CODFAMI",oSection1:aUserFilter[nX][2]) > 0 
										cFiltroAux	:= StrTran(oSection1:aUserFilter[nX][2]	, "T9_", "ST9TRB->T9_")
										//cFiltroAux	:= StrTran(oSection1:aUserFilter[nX][2]	, "T9_", "ST9->T9_") 
										//cFiltroAux	:= StrTran(cFiltroAux					, "ST9->T9_CENTRAB", "ST9TRB->T9_CENTRAB") 
										//cFiltroAux	:= StrTran(cFiltroAux					, "ST9->T9_CODFAMI", "ST9TRB->T9_T9_CODFAMI") 
										If !(&(cFiltroAux))
											lPula := .T.
											Exit
										EndIf
									EndIf
								Next nX
							Else							
								lPula := .T.							
							EndIf
						EndIf								

						//Pula para o próximo registro
						If lPula
							ST9TRB->( DBSKIP() )
							Loop
						EndIf
					EndIf
				EndIf

				IF CAUX <> ST9TRB->T9_CENTRAB .OR. NINC == 1
					
					IF NINC > 1 
						OSECTION2:FINISH()
					ENDIF
					OSECTION1:INIT()
					OSECTION1:CELL("CENTRAB"):SETBLOCK( { || ("FILIAL - " + ST9TRB->T9_CENTRAB + " - " + ALLTRIM( STR( ST9TRB->QTDBEMCTR ) ) + STR0012)  }) //" BENS NA FILIAL."
					OSECTION1:PRINTLINE()
					OSECTION1:FINISH()
					OSECTION2:INIT()
					NTGOCU	:=	0
					NTGDISP	:=	0	
					
				ENDIF

				//se existir filtro de usuario
				//O trecho abaixo está comentado, pois no TReport atual está deixando colocar filtros apenas na estrutura pai da Seção
				/*
				If Len(oSection2:aUserFilter) > 0

					lPula 	:= .F.

					//posiciona para respeitar o filtro do TReport - Seção Família
					ST9->(DbSetOrder(4)) //T9_FILIAL+T9_CODFAMI+T9_CODBEM
					If ST9->(DbSeek(xFilial("ST9") + ST9TRB->T9_CODFAMI))
						//Verifica os filtros de usuários e pula caso não esteja na regra
						For nX := 1 To Len(oSection2:aUserFilter)
							cFiltroAux	:= StrTran(oSection1:aUserFilter[nX][2], "T9_", "ST9->T9_") 
							If !(&(cFiltroAux))
								lPula := .T.
								Exit
							EndIf
						Next nX
					Else							
						lPula := .T.							
					EndIf

					//Pula para o próximo registro
					If lPula
						ST9TRB->( DBSKIP() )
						Loop
					EndIf
				EndIf
				*/
				
				NTGOCU	+=	ST9TRB->NFRE
				NTGDISP	+=	ST9TRB->QTDBEM	
				
				NTOCU	+=	ST9TRB->NFRE
				NTDISP	+=	ST9TRB->QTDBEM	
				
				OSECTION2:CELL("T9_CODFAMI"	):SETBLOCK( { || ST9TRB->T9_CODFAMI	})
				OSECTION2:CELL("T6_NOME"	):SETBLOCK( { || ST9TRB->T6_NOME	})
				OSECTION2:CELL("QTDBEM"		):SETBLOCK( { || ST9TRB->QTDBEM		})
				OSECTION2:CELL("DISP"		):SETBLOCK( { || ST9TRB->DISP		})
				OSECTION2:CELL("CON" 		):SETBLOCK( { || ST9TRB->CON		})
				//OSECTION2:CELL("MNT"		):SETBLOCK( { || ST9TRB->MNT		})
				OSECTION2:CELL("NFRE"		):SETBLOCK( { || ST9TRB->NFRE		})
				//OSECTION2:CELL("TRE" 		):SETBLOCK( { || ST9TRB->TRE		})
				//OSECTION2:CELL("NFRR"		):SETBLOCK( { || ST9TRB->NFRR		})
				OSECTION2:CELL("OCUP" 		):SETBLOCK( { || TRANSFORM("999%",CVALTOCHAR(ROUND((ST9TRB->NFRE / ST9TRB->QTDBEM)* 100,2)))  + "%"})
				//OSECTION2:CELL("ENT" 		):SETBLOCK( { || ST9TRB->ENT		})
				OSECTION2:CELL("SRT" 		):SETBLOCK( { || ST9TRB->SRT		})
				//OSECTION2:CELL("PAR" 		):SETBLOCK( { || ST9TRB->PAR		})
				OSECTION2:CELL("OTR" 		):SETBLOCK( { || ST9TRB->OTR		})
				OSECTION2:PRINTLINE()

				CAUX := ST9TRB->T9_CENTRAB
				ST9TRB->( DBSKIP() )
				OREPORT:INCMETER(NINC++)  
			ENDDO
			
			OSECTION2:FINISH()
			NTGOCU	:=	NTOCU
			NTGDISP	:=	NTDISP
			ST9TRB->(DBCLOSEAREA())

		ELSEIF MV_PAR11 == 2

			OREPORT:SETMETER( ZZZTRB->( RECCOUNT()) )
			CAUX := ZZZTRB->T9_CODBEM
			CAUX2:=	ZZZTRB->T9_CODFAMI
			WHILE ZZZTRB->(! EOF())

				// 11/10/2022 - Jose Eulalio - SIGALOC94-528 - Filtro por Cliente (trazer apenas o Status mais recente de cada bem)
				/*If lFiltraCli 
					If IIF(EMPTY(ZZZTRB->FQ4_CODCLI),POSICIONE("SM0",1,CEMPANT+SUBSTR(ZZZTRB->HB_COD,1,4),"M0_CODFIL"),ZZZTRB->FQ4_CODCLI) <> MV_PAR12
						CAUX := ZZZTRB->T9_CODBEM
						CAUX2 := ZZZTRB->T9_CODFAMI
						ZZZTRB->( DBSKIP() )
						Loop
					EndIf
				EndIf*/

				//se existir filtro de usuario
				If Len(oSection1:aUserFilter) > 0	
					//Verifica os filtros de usuários e pula caso não esteja na regra
					For nX := 1 To Len(oSection1:aUserFilter)
						lPula 		:= .F.		
						cFiltroAux	:= ""	
						If !Empty(oSection1:aUserFilter[nX][2])
							//posiciona para respeitar o filtro do TReport - Seção Centro de Trab.
							If At("FQ4",oSection1:aUserFilter[nX][1]) > 0
								//vai para próximo filtro se não tiver FQ4 
								If ZZZTRB->RECNOFQ4 > 0
									FQ4->(DbGoTo(ZZZTRB->RECNOFQ4))
									cFiltroAux	:= StrTran(oSection1:aUserFilter[nX][2], "FQ4_", "FQ4->FQ4_") 
									If !(&(cFiltroAux))
										lPula := .T.
										Exit
									EndIf
								Else
									lPula := .T.
									ZZZTRB->( DBSKIP() )

									Loop
								EndIf
							ElseIf At("ST9",oSection1:aUserFilter[nX][1]) > 0
								ST9->(DbGoTo(ZZZTRB->RECNOST9))
								cFiltroAux	:= StrTran(oSection1:aUserFilter[nX][2], "T9_", "ST9->T9_") 
								If !(&(cFiltroAux))
									lPula := .T.
									Exit
								EndIf
							EndIf
						EndIf
					Next nX

					//Pula para o próximo registro
					If lPula
						ZZZTRB->( DBSKIP() )
						Loop
					EndIf
				EndIf

				IF OREPORT:CANCEL()
					EXIT
				ENDIF
				IF CAUX2 != ZZZTRB->T9_CODFAMI .OR. NINC == 1
					IF NINC > 1
							OSECTION3:FINISH()
							OSECTION2:FINISH()
					ENDIF

					If cFamiAux	<> ZZZTRB->T9_CODFAMI

						cFamiAux := ZZZTRB->T9_CODFAMI
					
						OSECTION1:INIT()
						OSECTION1:CELL("T9_CODFAMI"	):SETBLOCK( { || ALLTRIM(ZZZTRB->T9_CODFAMI) + " - " + ALLTRIM(POSICIONE("ST6",1,XFILIAL("ST6")+ZZZTRB->T9_CODFAMI,"T6_NOME")) })
						
						/*
						OSECTION1:CELL("DISP"		):SETBLOCK( { || ZZZTRB->DISP })
						OSECTION1:CELL("CON" 		):SETBLOCK( { || ZZZTRB->CON		})
						//OSECTION1:CELL("MNT"		):SETBLOCK( { || ZZZTRB->MNT		})
						OSECTION1:CELL("NFRE"		):SETBLOCK( { || ZZZTRB->NFRE		})
						//OSECTION1:CELL("TRE" 		):SETBLOCK( { || ZZZTRB->TRE		})
						//OSECTION1:CELL("NFRR"		):SETBLOCK( { || ZZZTRB->NFRR		})
						OSECTION1:CELL("OCUP" 		):SETBLOCK( { || TRANSFORM("999%",CVALTOCHAR(ROUND((ZZZTRB->NFRE / (ZZZTRB->(DISP+CON+MNT+NFRE+TRE+NFRR+ENT+SRT+PAR+OTR)))* 100,2)))  + "%"})
						//OSECTION1:CELL("ENT" 		):SETBLOCK( { || ZZZTRB->ENT		})
						OSECTION1:CELL("SRT" 		):SETBLOCK( { || ZZZTRB->SRT		})
						//OSECTION1:CELL("PAR" 		):SETBLOCK( { || ZZZTRB->PAR		})
						OSECTION1:CELL("OTR" 		):SETBLOCK( { || ZZZTRB->OTR		})
						*/

						OSECTION1:PRINTLINE()
						OSECTION1:FINISH()

					EndIf

					IF CAUX <> ZZZTRB->T9_CODBEM .OR. NINC == 1
						IF NINC > 1
							OSECTION3:FINISH()
						ENDIF/*
						OSECTION2:INIT()
						OSECTION2:CELL("T9_CODBEM"	):SETBLOCK( { || "HISTORICO DO BEM " + ALLTRIM(ZZZTRB->T9_CODBEM) + " - " + ALLTRIM(ZZZTRB->T9_NOME) })
						OSECTION2:PRINTLINE()
						OSECTION2:FINISH()
						OSECTION3:INIT()*/
					ENDIF
				ENDIF
				OREPORT:INCMETER(NINC++)  

				/*
				NTGOCU	+=	ZZZTRB->NFRE
				NTGDISP	+=	ZZZTRB->(DISP+CON+MNT+NFRE+TRE+NFRR+ENT+SRT+PAR+OTR)
				
				NTOCU	+=	ZZZTRB->NFRE
				NTDISP	+=	ZZZTRB->(DISP+CON+MNT+NFRE+TRE+NFRR+ENT+SRT+PAR+OTR)	
				*/

				nSoma++
				If ZZZTRB->T9_STATUS == ITST9STAT("00") //"00"
					nDisp++
				ElseIf ZZZTRB->T9_STATUS == ITST9STAT("10") // "10"
					nCon++
					nOcup++
				ElseIf ZZZTRB->T9_STATUS == ITST9STAT("20") //"20"
					nNfRe++
					nOcup++
				ElseIf ZZZTRB->T9_STATUS == ITST9STAT("50") //"50"
					nStr++
					nOcup++
				Else
					nOtr++
				EndIf

				//Posiciona na FQ4 para atender a personaliza??o padr?o do TReport
				FQ4->(DbSeek(xFilial("FQ4") + ZZZTRB->T9_CODBEM))

				OSECTION2:INIT()
				OSECTION2:CELL("T9_CODBEM"	):SETBLOCK( { || STR0013 + ALLTRIM(ZZZTRB->T9_CODBEM) + " - " + ALLTRIM(ZZZTRB->T9_NOME) }) //"HISTORICO DO BEM "
				OSECTION2:PRINTLINE()
				OSECTION2:FINISH()
				OSECTION3:INIT()
				OSECTION3:CELL("T9_STATUS"	):SETBLOCK( { || POSICIONE("TQY",1,XFILIAL("TQY")+ZZZTRB->T9_STATUS,"TQY_DESTAT")	})
				OSECTION3:CELL("T9_CODFAMI"	):SETBLOCK( { || ZZZTRB->T9_CODFAMI	})
				OSECTION3:CELL("T9_TIPMOD"	):SETBLOCK( { || ZZZTRB->T9_TIPMOD	})
				OSECTION3:CELL("T9_FABRICA"	):SETBLOCK( { || ZZZTRB->T9_FABRICA	})
				//OSECTION3:CELL("T9_XSUBLOC"	):SETBLOCK( { || IIF(ZZZTRB->T9_XSUBLOC='1',"NAO","SIM")	})
				//OSECTION2:CELL("FQ4_POSCON"	):SETBLOCK( { || ZZZTRB->FQ4_POSCON	})
				OSECTION3:CELL("HB_COD"		):SETBLOCK( { || ZZZTRB->HB_COD	})
				OSECTION3:CELL("HB_NOME"	):SETBLOCK( { || ZZZTRB->HB_NOME	})
				OSECTION3:CELL("FQ4_OS"		):SETBLOCK( { || ZZZTRB->FQ4_OS		})
				OSECTION3:CELL("FQ4_SERVIC"	):SETBLOCK( { || ZZZTRB->FQ4_SERVIC	})
				OSECTION3:CELL("FQ4_PRELIB"	):SETBLOCK( { || STOD(ZZZTRB->FQ4_PRELIB)	})

				cVar01 := ""
				cVar02 := ""
				cVar03 := ""
				cVar04 := ""
				cVar05 := ""
				
				If !empty(ZZZTRB->FQ4_CODCLI)
					SA1->(dbSetOrder(1))
					If SA1->(dbSeek(xFilial("SA1")+ZZZTRB->FQ4_CODCLI+ZZZTRB->FQ4_LOJCLI))
						cVar01 := ZZZTRB->FQ4_CODCLI
						cVar02 := ZZZTRB->FQ4_NOMCLI
						cVar03 := SA1->A1_END
						cVar04 := SA1->A1_MUN
						cVar05 := SA1->A1_EST
					Else
						ST9->(dbSetOrder(1))
						If ST9->(dbSeek(xFilial("ST9")+ZZZTRB->T9_CODBEM))
							If !empty(ST9->T9_CENTRAB)
								SHB->(dbSetOrder(1))
								If SHB->(dbSeek(xFilial("SHB")+ST9->T9_CENTRAB))
									SM0->(dbSetOrder(1))
									If SM0->(dbSeek(cEmpAnt+SUBSTR(ZZZTRB->HB_COD,1,4)))
										cVar01 := SM0->M0_CODFIL
										cVar02 := SM0->M0_NOME
										cVar03 := SM0->M0_ENDCOB
										cVar04 := SM0->M0_CIDCOB
										cVar05 := SM0->M0_ESTCOB
									EndIF
								EndIF
							EndIF
						EndIF
					EndIF
				EndIf

				OSECTION3:CELL("FQ4_CODCLI"	):SETBLOCK( { || cVar01	})
				OSECTION3:CELL("FQ4_NOMCLI"	):SETBLOCK( { || cVar02	})
				OSECTION3:CELL("A1_END"		):SETBLOCK( { || cVar03  })
				OSECTION3:CELL("A1_MUN" 	):SETBLOCK( { || cVar04	})
				OSECTION3:CELL("A1_EST"		):SETBLOCK( { || cVar05	})
				OSECTION3:CELL("FQ4_DTINI" 	):SETBLOCK( { || STOD(ZZZTRB->FQ4_DTINI)	})
				OSECTION3:CELL("FQ4_DTFIM" 	):SETBLOCK( { || STOD(ZZZTRB->FQ4_DTFIM)	})
				OSECTION3:CELL("FQ4_PROJET"	):SETBLOCK( { || ZZZTRB->FQ4_PROJET	})
				OSECTION3:CELL("FQ4_OBRA" 	):SETBLOCK( { || ZZZTRB->FQ4_OBRA	})
				OSECTION3:CELL("FQ4_AS"		):SETBLOCK( { || ZZZTRB->FQ4_AS		})
				OSECTION3:CELL("FQ4_PREDES"	):SETBLOCK( { || ZZZTRB->FQ4_PREDES	})
				//OREPORT:INCROW(1)
				OSECTION3:CELL("FQ4_LOG"	):SETBLOCK( { || ZZZTRB->FQ4_LOG	})
				OSECTION3:PRINTLINE()
				CAUX := ZZZTRB->T9_CODBEM
				CAUX2 := ZZZTRB->T9_CODFAMI
				ZZZTRB->( DBSKIP() )
				IF CAUX == ZZZTRB->T9_CODBEM
					OREPORT:THINLINE()
				ENDIF
				IF CAUX2 == ZZZTRB->T9_CODFAMI
					OREPORT:THINLINE()
				ENDIF
			ENDDO

			OSECTION3:FINISH()
			NTGOCU	:=	NTOCU
			NTGDISP	:=	NTDISP
			ZZZTRB->(DBCLOSEAREA())

			OREPORT:ThinLine()
			OREPORT:FatLine()
			oSection4 :SetLineStyle(.T.)
			oSection4:INIT()
			oSection4:CELL("QUANTIDADE"	):SETBLOCK( { || cValToChar(nSoma)	})
			oSection4:CELL("DISPONIVEL"	):SETBLOCK( { || cValToChar(nDisp)	})
			oSection4:CELL("CONTRATO"	):SETBLOCK( { || cValToChar(nCon)	})
			oSection4:CELL("LOCADO"		):SETBLOCK( { || cValToChar(nNfRe)	})
			oSection4:CELL("RETIRADA"	):SETBLOCK( { || cValToChar(nStr)	})
			oSection4:CELL("OUTROS"		):SETBLOCK( { || cValToChar(nOtr)	})
			oSection4:CELL("OCUPACAO"	):SETBLOCK( { || cValToChar( Round( ( ( nNfRe / nSoma ) * 100) , 2 ) ) + " %"	})
			oSection4:PRINTLINE()
			oSection4:FINISH()

		ENDIF

		If MV_PAR11 == 1
			&('TCSQLEXEC("DROP TABLE "+CT61)')
			&('TCSQLEXEC("DROP TABLE "+CTI61)')
		EndIF

	ELSE

		AVISO(CTITULO,STR0014,{"OK"},1) //"NAO EXISTEM DADOS A SEREM EXIBIDOS"

	ENDIF

RETURN
/*?????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????
???????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????
????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????»??????
?????????PROGRAMA  ??? PERGPARAM???AUTOR  ??? MIGUEL GONTIJO     ??? DATA ???  09/02/2017 ?????????
???????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????
?????????DESC.     ??? PERGUNTA DO RELAT???RIO.                                     ?????????
?????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????±???
?????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????
???????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????*/
STATIC FUNCTION PERGPARAM(CPERG)
LOCAL APERGS  := {}
LOCAL ARET    := {}
LOCAL LRET    := .F.
LOCAL ACOMBO  := {STR0015,STR0016} //"1-SINTETICO"###"2-ANALITICO"
LOCAL NX

LOCAL CCENTRABI := IIF(FIELDPOS("T9_CENTRAB"	)>0,	SPACE(		GETSX3CACHE("T9_CENTRAB","X3_TAMANHO")),SPACE(TamSx3("T9_CENTRAB")[1]))
LOCAL CCENTRABF := IIF(FIELDPOS("T9_CENTRAB"	)>0,REPLICATE("Z",	GETSX3CACHE("T9_CENTRAB","X3_TAMANHO")),REPLICATE("Z",TamSx3("T9_CENTRAB")[1] ))
LOCAL CCODBEMI  := IIF(FIELDPOS("T9_CODBEM"		)>0,	SPACE(		GETSX3CACHE("T9_CODBEM"	,"X3_TAMANHO")),SPACE(TamSx3("T9_CODBEM")[1]))
LOCAL CCODBEMF  := IIF(FIELDPOS("T9_CODBEM"		)>0,REPLICATE("Z",	GETSX3CACHE("T9_CODBEM"	,"X3_TAMANHO")),REPLICATE("Z",TamSx3("T9_CODBEM")[1]))
LOCAL CCODFAMI  := IIF(FIELDPOS("T9_CODFAMI"	)>0,	SPACE(		GETSX3CACHE("T9_CODFAMI","X3_TAMANHO")),SPACE(TamSx3("T9_CODFAMI")[1]))
LOCAL CCODFAMF  := IIF(FIELDPOS("T9_CODFAMI"	)>0,REPLICATE("Z",	GETSX3CACHE("T9_CODFAMI","X3_TAMANHO")),REPLICATE("Z",TamSx3("T9_CODFAMI")[1]))
LOCAL CTIPMODI  := IIF(FIELDPOS("T9_TIPMOD"		)>0,	SPACE(		GETSX3CACHE("T9_TIPMOD"	,"X3_TAMANHO")),SPACE(TamSx3("T9_TIPMOD")[1]))
LOCAL CTIPMODF  := IIF(FIELDPOS("T9_TIPMOD"		)>0,REPLICATE("Z",	GETSX3CACHE("T9_TIPMOD"	,"X3_TAMANHO")),REPLICATE("Z",TamSx3("T9_TIPMOD")[1]))
LOCAL CSTATUSI  := IIF(FIELDPOS("T9_STATUS"		)>0,	SPACE(		GETSX3CACHE("T9_STATUS"	,"X3_TAMANHO")),SPACE(TamSx3("T9_STATUS")[1]))
LOCAL CSTATUSF  := IIF(FIELDPOS("T9_STATUS"		)>0,REPLICATE("Z",	GETSX3CACHE("T9_STATUS"	,"X3_TAMANHO")),REPLICATE("Z",TamSx3("T9_STATUS")[1]))
//LOCAL CCOD_MUNI := IIF(FIELDPOS("HB_COD_MUN"	)>0,	SPACE(		GETSX3CACHE("HB_COD_MUN","X3_TAMANHO")),SPACE(10))
//LOCAL CCOD_MUNF := IIF(FIELDPOS("HB_COD_MUN"	)>0,REPLICATE("Z",	GETSX3CACHE("HB_COD_MUN","X3_TAMANHO")),REPLICATE("Z",10))
// 11/10/2022 - Jose Eulalio - SIGALOC94-528 - Filtro por Cliente (trazer apenas o Status mais recente de cada bem)
LOCAL cCliFp0  	:= IIF(FIELDPOS("FP0_CLI"		)>0,REPLICATE("Z",	GETSX3CACHE("FP0_CLI"	,"X3_TAMANHO")),REPLICATE(" ",TamSx3("FP0_CLI")[1]))
LOCAL cLOjaFp0  := IIF(FIELDPOS("FP0_LOJA"		)>0,REPLICATE("Z",	GETSX3CACHE("FP0_LOJA"	,"X3_TAMANHO")),REPLICATE(" ",TamSx3("FP0_LOJA")[1]))

	AADD( APERGS ,{1,RETTITLE("T9_CENTRAB"	),CCENTRABI,PESQPICT("ST9","T9_CENTRAB"	),'.T.',"SHB",'.T.', 50 ,.F.})
	AADD( APERGS ,{1,RETTITLE("T9_CENTRAB"	),CCENTRABF,PESQPICT("ST9","T9_CENTRAB"	),'.T.',"SHB",'.T.', 50 ,.T.})
	AADD( APERGS ,{1,RETTITLE("T9_CODBEM"	),CCODBEMI,	PESQPICT("ST9","T9_CODBEM"	),'.T.',"ST9",'.T.', 50 ,.F.})
	AADD( APERGS ,{1,RETTITLE("T9_CODBEM"	),CCODBEMF,	PESQPICT("ST9","T9_CODBEM"	),'.T.',"ST9",'.T.', 50 ,.T.})
	AADD( APERGS ,{1,RETTITLE("T9_CODFAMI"	),CCODFAMI,	PESQPICT("ST9","T9_CODFAMI"	),'.T.',"ST6",'.T.', 50 ,.F.})
	AADD( APERGS ,{1,RETTITLE("T9_CODFAMI"	),CCODFAMF,	PESQPICT("ST9","T9_CODFAMI"	),'.T.',"ST6",'.T.', 50 ,.T.})
	AADD( APERGS ,{1,RETTITLE("T9_TIPMOD"	),CTIPMODI,	PESQPICT("ST9","T9_TIPMOD"	),'.T.',"TQR",'.T.', 50 ,.F.})
	AADD( APERGS ,{1,RETTITLE("T9_TIPMOD"	),CTIPMODF,	PESQPICT("ST9","T9_TIPMOD"	),'.T.',"TQR",'.T.', 50 ,.T.})
	AADD( APERGS ,{1,RETTITLE("T9_STATUS"	),CSTATUSI,	PESQPICT("ST9","T9_STATUS"	),'.T.',"TQY",'.T.', 50 ,.F.})
	AADD( APERGS ,{1,RETTITLE("T9_STATUS"	),CSTATUSF,	PESQPICT("ST9","T9_STATUS"	),'.T.',"TQY",'.T.', 50 ,.T.})
	//AADD( APERGS ,{1,"Munic.Ini"			 ,CCOD_MUNI,"@!"						 ,'.T.',"CC2",'.T.', 50 ,.F.})
	//AADD( APERGS ,{1,"Munic.Fim"			 ,CCOD_MUNF,"@!"						 ,'.T.',"CC2",'.T.', 50 ,.T.})
	AADD( APERGS ,{2,STR0017 , 1 ,ACOMBO, 70 , '.T.' , .T. }) // COMBO //"TIPO RELATORIO: "
	// 11/10/2022 - Jose Eulalio - SIGALOC94-528 - Filtro por Cliente (trazer apenas o Status mais recente de cada bem)
	AADD( APERGS ,{1,RETTITLE("FP0_CLI"		),cCliFp0,	PESQPICT("FP0","FP0_CLI"	),'.T.',"SA1",'.T.', 40 ,.F.})
	AADD( APERGS ,{1,RETTITLE("FP0_LOJA"	),cLOjaFp0,	PESQPICT("FP0","FP0_LOJA"	),'.T.',""	 ,'.T.', 20 ,.F.})

	IF PARAMBOX(APERGS ,STR0018,ARET, /*< BOK >*/, /*< ABUTTONS >*/, .T. , /*7 < NPOSX >*/, /*8 < NPOSY >*/, /*9 < ODLGWIZARD >*/, /*10 < CLOAD > */, .T. , .T. ) //"PARAMETROS "

		FOR NX := 1 TO LEN(ARET)
			&("MV_PAR"+STRZERO(NX,2)) := ARET[NX]
		NEXT
		LRET := .T.

		IF VALTYPE( MV_PAR11 ) == "C"
			IF "1" $  ALLTRIM(MV_PAR11) 
				MV_PAR11 := 1
			ELSEIF "2" $ ALLTRIM(MV_PAR11) 
				MV_PAR11 := 2
			ENDIF
		END	
	ENDIF

RETURN (LRET)
/*?????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????
???????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????
????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????»??????
?????????PROGRAMA  ??? PERGPARAM???AUTOR  ??? MIGUEL GONTIJO     ??? DATA ???  09/02/2017 ?????????
???????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????
?????????DESC.     ??? PERGUNTA DO RELAT???RIO.                                     ?????????
?????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????±???
?????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????
???????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????*/
STATIC FUNCTION SELDADOS()
LOCAL CQUERY 		:= ""
Local cListaBens	:= ""
LOCAL LRET 			:= .F.
LOCAL lFiltraCli	:= !Empty(MV_PAR12) .And. At("*",MV_PAR12) == 0
Local aTam
Local xStru
Local aResultado
Local lAchou
Local nX

	// 11/10/2022 - Jose Eulalio - SIGALOC94-528 - Filtro por Cliente (trazer apenas o Status mais recente de cada bem)
	IF lFiltraCli
		cListaBens := ListaBens()
	EndIf

	IF MV_PAR11 == 1

		IF lFiltraCli

			/*
			+ cListaBens +
			+ cListaBens +
			+ cListaBens +
			+ cListaBens +
			+ cListaBens +
			+ cListaBens +
			+ cListaBens +
			+ cListaBens +
			+ cListaBens +
			+ cListaBens +
			+ cListaBens +
			+ cListaBens +
			+ cListaBens +
			+ cListaBens +
			+ cListaBens +
			+ cListaBens +
			+ cListaBens +
			+ cListaBens +
			+ cListaBens +
			+ cListaBens +
			+ cListaBens +
			+MV_PAR01+
			+MV_PAR02+
			+ cListaBens +
			+MV_PAR03+
			+MV_PAR04+  
			+MV_PAR05+
			+MV_PAR06+
			+MV_PAR07+
			+MV_PAR08+
			+MV_PAR09+
			+MV_PAR10+
			*/

			/*CQUERY += " SELECT  " 
			CQUERY += " ST9.T9_CENTRAB,  " 
			CQUERY += " ST9.T9_CODFAMI,  " 
			CQUERY += " ST6.T6_NOME, " 
			CQUERY += " COUNT(ST9.T9_CODBEM) QTDBEM,  " 

			// 11/10/2022 - Jose Eulalio - SIGALOC94-528 - Filtro por Cliente (trazer apenas o Status mais recente de cada bem)
			If !lMvLocBac			
				CQUERY += "	COALESCE((SELECT COUNT(ST91.T9_CODFAMI) QTDFAMI FROM "+RETSQLNAME("ST9")+" ST91 WHERE ST91.D_E_L_E_T_='' AND ST91.T9_STATUS = '"+ITST9STAT("00")+"' AND ST91.T9_CENTRAB = ST9.T9_CENTRAB AND ST91.T9_CODFAMI = ST9.T9_CODFAMI AND ST91.T9_SITBEM	=	'A'	 " 
			else
				CQUERY += "	COALESCE((SELECT COUNT(ST91.T9_CODFAMI) QTDFAMI FROM "+RETSQLNAME("ST9")+" ST91 WHERE ST91.D_E_L_E_T_='' AND ST91.T9_STATUS = '"+ITST9STAT("00")+"' AND ST91.T9_CENTRAB = ST9.T9_CENTRAB AND ST91.T9_CODFAMI = ST9.T9_CODFAMI AND ST91.T9_SITBEM	=	'A'	 " 
			endif
			CQUERY += " GROUP BY ST91.T9_CODFAMI),0)  DISP, "   
			If !lMvLocBac			
				CQUERY += "	COALESCE((SELECT COUNT(ST91.T9_CODFAMI) QTDFAMI FROM "+RETSQLNAME("ST9")+" ST91 WHERE ST91.D_E_L_E_T_='' AND ST91.T9_STATUS = '"+ITST9STAT("10")+"' AND D_E_L_E_T_ = '')) AND ST91.T9_CENTRAB = ST9.T9_CENTRAB AND ST91.T9_CODFAMI = ST9.T9_CODFAMI AND ST91.T9_SITBEM	=	'A'	 " 
			else
				CQUERY += "	COALESCE((SELECT COUNT(ST91.T9_CODFAMI) QTDFAMI FROM "+RETSQLNAME("ST9")+" ST91 WHERE ST91.D_E_L_E_T_='' AND ST91.T9_STATUS = '"+ITST9STAT("10")+"' AND ST91.T9_CENTRAB = ST9.T9_CENTRAB AND ST91.T9_CODFAMI = ST9.T9_CODFAMI AND ST91.T9_SITBEM	=	'A'	 "  
			endif
			CQUERY += " GROUP BY ST91.T9_CODFAMI),0)  CON, "  
			If !lMvLocBac
				CQUERY += "	COALESCE((SELECT COUNT(ST91.T9_CODFAMI) QTDFAMI FROM "+RETSQLNAME("ST9")+" ST91 WHERE ST91.D_E_L_E_T_='' AND ST91.T9_STATUS = '"+ITST9STAT("20")+"' AND ST91.T9_CENTRAB = ST9.T9_CENTRAB AND ST91.T9_CODFAMI = ST9.T9_CODFAMI AND ST91.T9_SITBEM	=	'A'	 "   
			else
				CQUERY += "	COALESCE((SELECT COUNT(ST91.T9_CODFAMI) QTDFAMI FROM "+RETSQLNAME("ST9")+" ST91 WHERE ST91.D_E_L_E_T_='' AND ST91.T9_STATUS = '"+ITST9STAT("20")+"' AND ST91.T9_CENTRAB = ST9.T9_CENTRAB AND ST91.T9_CODFAMI = ST9.T9_CODFAMI AND ST91.T9_SITBEM	=	'A'	 " 
			endif
			CQUERY += " GROUP BY ST91.T9_CODFAMI),0)  NFRE,"  
			If !lMvLocBac
				CQUERY += "	COALESCE((SELECT COUNT(ST91.T9_CODFAMI) QTDFAMI FROM "+RETSQLNAME("ST9")+" ST91 WHERE ST91.D_E_L_E_T_='' AND ST91.T9_STATUS = '"+ITST9STAT("30")+"' AND ST91.T9_CENTRAB = ST9.T9_CENTRAB AND ST91.T9_CODFAMI = ST9.T9_CODFAMI AND ST91.T9_SITBEM	=	'A'	 "   
			else
				CQUERY += "	COALESCE((SELECT COUNT(ST91.T9_CODFAMI) QTDFAMI FROM "+RETSQLNAME("ST9")+" ST91 WHERE ST91.D_E_L_E_T_='' AND ST91.T9_STATUS = '"+ITST9STAT("30")+"' AND ST91.T9_CENTRAB = ST9.T9_CENTRAB AND ST91.T9_CODFAMI = ST9.T9_CODFAMI AND ST91.T9_SITBEM	=	'A'	 " 
			endif
			CQUERY += " GROUP BY ST91.T9_CODFAMI),0)  TRE, "  
			If !lMvLocBac
				CQUERY += "	COALESCE((SELECT COUNT(ST91.T9_CODFAMI) QTDFAMI FROM "+RETSQLNAME("ST9")+" ST91 WHERE ST91.D_E_L_E_T_='' AND ST91.T9_STATUS = '"+ITST9STAT("40")+"' AND ST91.T9_CENTRAB = ST9.T9_CENTRAB AND ST91.T9_CODFAMI = ST9.T9_CODFAMI AND ST91.T9_SITBEM	=	'A'	 "   
			else
				CQUERY += "	COALESCE((SELECT COUNT(ST91.T9_CODFAMI) QTDFAMI FROM "+RETSQLNAME("ST9")+" ST91 WHERE ST91.D_E_L_E_T_='' AND ST91.T9_STATUS = '"+ITST9STAT("40")+"' AND ST91.T9_CENTRAB = ST9.T9_CENTRAB AND ST91.T9_CODFAMI = ST9.T9_CODFAMI AND ST91.T9_SITBEM	=	'A'	 " 
			endif
			CQUERY += " GROUP BY ST91.T9_CODFAMI),0)  ENT, "  
			If !lMvLocBac
				CQUERY += "	COALESCE((SELECT COUNT(ST91.T9_CODFAMI) QTDFAMI FROM "+RETSQLNAME("ST9")+" ST91 WHERE ST91.D_E_L_E_T_='' AND ST91.T9_STATUS = '"+ITST9STAT("50")+"' AND ST91.T9_CENTRAB = ST9.T9_CENTRAB AND ST91.T9_CODFAMI = ST9.T9_CODFAMI AND ST91.T9_SITBEM	=	'A'	 "   
			else
				CQUERY += "	COALESCE((SELECT COUNT(ST91.T9_CODFAMI) QTDFAMI FROM "+RETSQLNAME("ST9")+" ST91 WHERE ST91.D_E_L_E_T_='' AND ST91.T9_STATUS = '"+ITST9STAT("50")+"' AND ST91.T9_CENTRAB = ST9.T9_CENTRAB AND ST91.T9_CODFAMI = ST9.T9_CODFAMI AND ST91.T9_SITBEM	=	'A'	 " 
			endif
			CQUERY += " GROUP BY ST91.T9_CODFAMI),0)  SRT, "  
			If !lMvLocBac
				CQUERY += "	COALESCE((SELECT COUNT(ST91.T9_CODFAMI) QTDFAMI FROM "+RETSQLNAME("ST9")+" ST91 WHERE ST91.D_E_L_E_T_='' AND ST91.T9_STATUS = '"+ITST9STAT("60")+"' AND ST91.T9_CENTRAB = ST9.T9_CENTRAB AND ST91.T9_CODFAMI = ST9.T9_CODFAMI AND ST91.T9_SITBEM	=	'A'	 "   
			else
				CQUERY += "	COALESCE((SELECT COUNT(ST91.T9_CODFAMI) QTDFAMI FROM "+RETSQLNAME("ST9")+" ST91 WHERE ST91.D_E_L_E_T_='' AND ST91.T9_STATUS = '"+ITST9STAT("60")+"' AND ST91.T9_CENTRAB = ST9.T9_CENTRAB AND ST91.T9_CODFAMI = ST9.T9_CODFAMI AND ST91.T9_SITBEM	=	'A'	 " 
			endif
			CQUERY += " GROUP BY ST91.T9_CODFAMI),0)  NFRR,"  
			If !lMvLocBac
				CQUERY += "	COALESCE((SELECT COUNT(ST91.T9_CODFAMI) QTDFAMI FROM "+RETSQLNAME("ST9")+" ST91 WHERE ST91.D_E_L_E_T_='' AND ST91.T9_STATUS = '"+ITST9STAT("70")+"' AND ST91.T9_CENTRAB = ST9.T9_CENTRAB AND ST91.T9_CODFAMI = ST9.T9_CODFAMI AND ST91.T9_SITBEM	=	'A'	 "   
			else
				CQUERY += "	COALESCE((SELECT COUNT(ST91.T9_CODFAMI) QTDFAMI FROM "+RETSQLNAME("ST9")+" ST91 WHERE ST91.D_E_L_E_T_='' AND ST91.T9_STATUS = '"+ITST9STAT("70")+"' AND ST91.T9_CENTRAB = ST9.T9_CENTRAB AND ST91.T9_CODFAMI = ST9.T9_CODFAMI AND ST91.T9_SITBEM	=	'A'	 " 
			endif
			CQUERY += " GROUP BY ST91.T9_CODFAMI),0)  MNT,	"  
			If !lMvLocBac
				CQUERY += "	COALESCE((SELECT COUNT(ST91.T9_CODFAMI) QTDFAMI FROM "+RETSQLNAME("ST9")+" ST91 WHERE ST91.D_E_L_E_T_='' AND ST91.T9_STATUS = '"+ITST9STAT("80")+"' AND ST91.T9_CENTRAB = ST9.T9_CENTRAB AND ST91.T9_CODFAMI = ST9.T9_CODFAMI AND ST91.T9_SITBEM	=	'A'	 "   
			else
				CQUERY += "	COALESCE((SELECT COUNT(ST91.T9_CODFAMI) QTDFAMI FROM "+RETSQLNAME("ST9")+" ST91 WHERE ST91.D_E_L_E_T_='' AND ST91.T9_STATUS = '"+ITST9STAT("80")+"' AND ST91.T9_CENTRAB = ST9.T9_CENTRAB AND ST91.T9_CODFAMI = ST9.T9_CODFAMI AND ST91.T9_SITBEM	=	'A'	 " 
			endif
			CQUERY += " GROUP BY ST91.T9_CODFAMI),0)  PAR, "  
			CQUERY += " COALESCE((SELECT COUNT(ST91.T9_CODFAMI) QTDFAMI FROM "+RETSQLNAME("ST9")+" ST91 WHERE ST91.D_E_L_E_T_='' AND ST91.T9_STATUS NOT IN ('"+ITST9STAT("00")+"','"+ITST9STAT("10")+"','"+ITST9STAT("20")+"','"+ITST9STAT("30")+"','"+ITST9STAT("40")+"','"+ITST9STAT("50")+"','"+ITST9STAT("60")+"','"+ITST9STAT("70")+"','"+ITST9STAT("80")+"') AND ST91.T9_CENTRAB = ST9.T9_CENTRAB AND ST91.T9_CODFAMI = ST9.T9_CODFAMI AND ST91.T9_SITBEM	=	'A'	 "   
			CQUERY += " GROUP BY ST91.T9_CODFAMI),0)  OTR, "  
			CQUERY += " (SELECT COUNT(ST91.T9_CODBEM) QTDBEMTRB FROM "+RETSQLNAME("ST9")+" ST91 WHERE ST91.D_E_L_E_T_='' AND ST91.T9_CENTRAB = ST9.T9_CENTRAB "   
			CQUERY += " GROUP BY ST91.T9_CENTRAB)  QTDBEMCTR,	"                                            
			If !lMvLocBac
				CQUERY += " (SELECT COUNT(ST91.T9_CODBEM) QTDBEMTRB FROM "+RETSQLNAME("ST9")+" ST91 WHERE ST91.D_E_L_E_T_='' AND ST91.T9_CENTRAB = ST9.T9_CENTRAB AND ST91.T9_STATUS IN ((SELECT TQY_STATUS FROM "+RETSQLNAME("TQY")+" WHERE TQY_STTCTR = '00'))  AND ST91.T9_SITBEM	=	'A'	 "   
			else
				CQUERY += " (SELECT COUNT(ST91.T9_CODBEM) QTDBEMTRB FROM "+RETSQLNAME("ST9")+" ST91 WHERE ST91.D_E_L_E_T_='' AND ST91.T9_CENTRAB = ST9.T9_CENTRAB AND ST91.T9_STATUS IN ((SELECT FQD_STAREN FROM "+RETSQLNAME("FQD")+" WHERE FQD_STAREN = '00'))  AND ST91.T9_SITBEM	=	'A'	 "   
			endif
			CQUERY += " GROUP BY ST91.T9_CENTRAB)  TDISP,	"                                                  
			If !lMvLocBac
				CQUERY += " (SELECT COUNT(ST91.T9_CODBEM) QTDBEMTRB FROM "+RETSQLNAME("ST9")+" ST91 WHERE ST91.D_E_L_E_T_='' AND ST91.T9_CENTRAB = ST9.T9_CENTRAB AND ST91.T9_STATUS IN ((SELECT TQY_STATUS FROM "+RETSQLNAME("TQY")+" WHERE TQY_STTCTR = '10'))  AND ST91.T9_SITBEM	=	'A'	 "   
			Else
				CQUERY += " (SELECT COUNT(ST91.T9_CODBEM) QTDBEMTRB FROM "+RETSQLNAME("ST9")+" ST91 WHERE ST91.D_E_L_E_T_='' AND ST91.T9_CENTRAB = ST9.T9_CENTRAB AND ST91.T9_STATUS IN ((SELECT FQD_STAREN FROM "+RETSQLNAME("FQD")+" WHERE FQD_STAREN = '10'))  AND ST91.T9_SITBEM	=	'A'	 "   
			EndIF
			CQUERY += " GROUP BY ST91.T9_CENTRAB)  TCON,	"                                                
			If !lMvLocBac
				CQUERY += " (SELECT COUNT(ST91.T9_CODBEM) QTDBEMTRB FROM "+RETSQLNAME("ST9")+" ST91 WHERE ST91.D_E_L_E_T_='' AND ST91.T9_CENTRAB = ST9.T9_CENTRAB AND ST91.T9_STATUS IN ((SELECT TQY_STATUS FROM "+RETSQLNAME("TQY")+" WHERE TQY_STTCTR = '20'))  AND ST91.T9_SITBEM	=	'A'	 "   
			else
				CQUERY += " (SELECT COUNT(ST91.T9_CODBEM) QTDBEMTRB FROM "+RETSQLNAME("ST9")+" ST91 WHERE ST91.D_E_L_E_T_='' AND ST91.T9_CENTRAB = ST9.T9_CENTRAB AND ST91.T9_STATUS IN ((SELECT FQD_STAREN FROM "+RETSQLNAME("FQD")+" WHERE FQD_STAREN = '20'))  AND ST91.T9_SITBEM	=	'A'	 "   
			endif
			CQUERY += " GROUP BY ST91.T9_CENTRAB)  TNFRE,	"                                                  
			If !lMvLocBac
				CQUERY += " (SELECT COUNT(ST91.T9_CODBEM) QTDBEMTRB FROM "+RETSQLNAME("ST9")+" ST91 WHERE ST91.D_E_L_E_T_='' AND ST91.T9_CENTRAB = ST9.T9_CENTRAB AND ST91.T9_STATUS IN ((SELECT TQY_STATUS FROM "+RETSQLNAME("TQY")+" WHERE TQY_STTCTR = '30'))  AND ST91.T9_SITBEM	=	'A'	 "   
			else
				CQUERY += " (SELECT COUNT(ST91.T9_CODBEM) QTDBEMTRB FROM "+RETSQLNAME("ST9")+" ST91 WHERE ST91.D_E_L_E_T_='' AND ST91.T9_CENTRAB = ST9.T9_CENTRAB AND ST91.T9_STATUS IN ((SELECT FQD_STAREN FROM "+RETSQLNAME("FQD")+" WHERE FQD_STAREN = '30'))  AND ST91.T9_SITBEM	=	'A'	 "   			
			endif
			CQUERY += " GROUP BY ST91.T9_CENTRAB)  TTRE,	"                                                 
			If !lMvLocBac
				CQUERY += " (SELECT COUNT(ST91.T9_CODBEM) QTDBEMTRB FROM "+RETSQLNAME("ST9")+" ST91 WHERE ST91.D_E_L_E_T_='' AND ST91.T9_CENTRAB = ST9.T9_CENTRAB AND ST91.T9_STATUS IN ((SELECT TQY_STATUS FROM "+RETSQLNAME("TQY")+" WHERE TQY_STTCTR = '40'))  AND ST91.T9_SITBEM	=	'A'	 "   
			else
				CQUERY += " (SELECT COUNT(ST91.T9_CODBEM) QTDBEMTRB FROM "+RETSQLNAME("ST9")+" ST91 WHERE ST91.D_E_L_E_T_='' AND ST91.T9_CENTRAB = ST9.T9_CENTRAB AND ST91.T9_STATUS IN ((SELECT FQD_STAREN FROM "+RETSQLNAME("FQD")+" WHERE FQD_STAREN = '40'))  AND ST91.T9_SITBEM	=	'A'	 "   			
			endif
			CQUERY += " GROUP BY ST91.T9_CENTRAB)  TENT,	"                                                
			If !lMvLocBac
				CQUERY += " (SELECT COUNT(ST91.T9_CODBEM) QTDBEMTRB FROM "+RETSQLNAME("ST9")+" ST91 WHERE ST91.D_E_L_E_T_='' AND ST91.T9_CENTRAB = ST9.T9_CENTRAB AND ST91.T9_STATUS IN ((SELECT TQY_STATUS FROM "+RETSQLNAME("TQY")+" WHERE TQY_STTCTR = '50'))  AND ST91.T9_SITBEM	=	'A'	 "   
			else
				CQUERY += " (SELECT COUNT(ST91.T9_CODBEM) QTDBEMTRB FROM "+RETSQLNAME("ST9")+" ST91 WHERE ST91.D_E_L_E_T_='' AND ST91.T9_CENTRAB = ST9.T9_CENTRAB AND ST91.T9_STATUS IN ((SELECT FQD_STAREN FROM "+RETSQLNAME("FQD")+" WHERE FQD_STAREN = '50'))  AND ST91.T9_SITBEM	=	'A'	 "   			
			endif
			CQUERY += " 			  GROUP BY ST91.T9_CENTRAB)  TSRT,	"                                               
			If !lMvLocBac
				CQUERY += " (SELECT COUNT(ST91.T9_CODBEM) QTDBEMTRB FROM "+RETSQLNAME("ST9")+" ST91 WHERE ST91.D_E_L_E_T_='' AND ST91.T9_CENTRAB = ST9.T9_CENTRAB AND ST91.T9_STATUS IN ((SELECT TQY_STATUS FROM "+RETSQLNAME("TQY")+" WHERE TQY_STTCTR = '60'))  AND ST91.T9_SITBEM	=	'A'	 "   
			else
				CQUERY += " (SELECT COUNT(ST91.T9_CODBEM) QTDBEMTRB FROM "+RETSQLNAME("ST9")+" ST91 WHERE ST91.D_E_L_E_T_='' AND ST91.T9_CENTRAB = ST9.T9_CENTRAB AND ST91.T9_STATUS IN ((SELECT FQD_STAREN FROM "+RETSQLNAME("FQD")+" WHERE FQD_STAREN = '60'))  AND ST91.T9_SITBEM	=	'A'	 "   			
			ENDIF
			CQUERY += " 			  GROUP BY ST91.T9_CENTRAB)  TNFRR,	"                                              
			If !lMvLocBac
				CQUERY += " (SELECT COUNT(ST91.T9_CODBEM) QTDBEMTRB FROM "+RETSQLNAME("ST9")+" ST91 WHERE ST91.D_E_L_E_T_='' AND ST91.T9_CENTRAB = ST9.T9_CENTRAB AND ST91.T9_STATUS IN ((SELECT TQY_STATUS FROM "+RETSQLNAME("TQY")+" WHERE TQY_STTCTR = '70'))  AND ST91.T9_SITBEM	=	'A'	 "   
			else
				CQUERY += " (SELECT COUNT(ST91.T9_CODBEM) QTDBEMTRB FROM "+RETSQLNAME("ST9")+" ST91 WHERE ST91.D_E_L_E_T_='' AND ST91.T9_CENTRAB = ST9.T9_CENTRAB AND ST91.T9_STATUS IN ((SELECT FQD_STAREN FROM "+RETSQLNAME("FQD")+" WHERE FQD_STAREN = '70'))  AND ST91.T9_SITBEM	=	'A'	 "   			
			endif
			CQUERY += " 			  GROUP BY ST91.T9_CENTRAB)  TMNT,	"                                             
			If !lMvLocBac
				CQUERY += " (SELECT COUNT(ST91.T9_CODBEM) QTDBEMTRB FROM "+RETSQLNAME("ST9")+" ST91 WHERE ST91.D_E_L_E_T_='' AND ST91.T9_CENTRAB = ST9.T9_CENTRAB AND ST91.T9_STATUS IN ((SELECT TQY_STATUS FROM "+RETSQLNAME("TQY")+" WHERE TQY_STTCTR = '80'))  AND ST91.T9_SITBEM	=	'A'	 "   
			else
				CQUERY += " (SELECT COUNT(ST91.T9_CODBEM) QTDBEMTRB FROM "+RETSQLNAME("ST9")+" ST91 WHERE ST91.D_E_L_E_T_='' AND ST91.T9_CENTRAB = ST9.T9_CENTRAB AND ST91.T9_STATUS IN ((SELECT FQD_STAREN FROM "+RETSQLNAME("FQD")+" WHERE FQD_STAREN = '80'))  AND ST91.T9_SITBEM	=	'A'	 "   			
			endif
			CQUERY += " 			  GROUP BY ST91.T9_CENTRAB)  TPAR,	"                                                  
			CQUERY += "            (SELECT COUNT(ST91.T9_CODBEM) QTDBEMTRB FROM "+RETSQLNAME("ST9")+" ST91 WHERE ST91.D_E_L_E_T_='' AND ST91.T9_CENTRAB = ST9.T9_CENTRAB AND ST91.T9_STATUS NOT IN ('"+ITST9STAT("00")+"','"+ITST9STAT("10")+"','"+ITST9STAT("20")+"','"+ITST9STAT("30")+"','"+ITST9STAT("40")+"','"+ITST9STAT("50")+"','"+ITST9STAT("60")+"','"+ITST9STAT("70")+"','"+ITST9STAT("80")+"')  AND ST91.T9_SITBEM	=	'A'	 "   
			CQUERY += " 			  GROUP BY ST91.T9_CENTRAB)  TOTR	"                                             
			// 11/10/2022 - Jose Eulalio - SIGALOC94-528 - Filtro por Cliente (trazer apenas o Status mais recente de cada bem)
			
			CQUERY += "  FROM		"+RETSQLNAME("ST9")+" ST9     "      

			// Filtro por cliente Frank no sintético
			CQUERY += " INNER JOIN "+RETSQLNAME("FQ4")+" ZZZ     "  
			CQUERY += " ON	ZZZ.FQ4_CODBEM = ST9.T9_CODBEM		"         
			CQUERY += "	AND ZZZ.D_E_L_E_T_=''		"  
			CQUERY += "	AND ZZZ.R_E_C_N_O_ = (SELECT MAX(ZZZ1.R_E_C_N_O_) FROM "+RETSQLNAME("FQ4")+" ZZZ1 WHERE ZZZ1.FQ4_CODBEM = ST9.T9_CODBEM AND ZZZ1.D_E_L_E_T_ = '' AND ZZZ1.FQ4_CODCLI = '"+MV_PAR12+"' AND ZZZ1.FQ4_LOJCLI = '"+MV_PAR13+"' ) "  
   

			CQUERY += "  LEFT JOIN	"+RETSQLNAME("SHB")+" SHB       "  
			CQUERY += " 			ON	SHB.HB_COD = ST9.T9_CENTRAB     "         
			CQUERY += " 			AND SHB.D_E_L_E_T_=''        "               

			CQUERY += " LEFT JOIN	"+RETSQLNAME("ST6")+" ST6 "  
			CQUERY += " 			ON	ST9.T9_CODFAMI	=	ST6.T6_CODFAMI "  
			CQUERY += " 			AND ST9.D_E_L_E_T_	=	'' "  

			CQUERY += " WHERE		ST9.D_E_L_E_T_	=	''        "             
			CQUERY += " 		AND ST9.T9_CENTRAB BETWEEN ? AND ? "  
			// 11/10/2022 - Jose Eulalio - SIGALOC94-528 - Filtro por Cliente (trazer apenas o Status mais recente de cada bem)
			CQUERY += " 		AND ST9.T9_CODBEM  BETWEEN ? AND ? "  
			CQUERY += " 		AND ST9.T9_CODFAMI BETWEEN ? AND ? "  
			CQUERY += " 		AND ST9.T9_TIPMOD  BETWEEN ? AND ? "  
			CQUERY += " 		AND ST9.T9_STATUS  BETWEEN ? AND ? "  
			CQUERY += " 		AND ST9.T9_SITBEM	=	'A' "  
			cQuery += "         AND ST9.T9_STATUS <> '' "

			CQUERY += " GROUP BY	ST9.T9_CENTRAB,  "  
			CQUERY += " 			ST9.T9_CODFAMI, "  
			CQUERY += " 			ST6.T6_NOME "  

			CQUERY += " ORDER BY	ST9.T9_CENTRAB, "  
			CQUERY += " 			ST9.T9_CODFAMI "  
			IF SELECT("ST9TRB") > 0
				ST9TRB->(DBCLOSEAREA())
			ENDIF

			CQUERY := CHANGEQUERY(CQUERY) 
			aBindParam := {	MV_PAR01,;
							MV_PAR02,;
							MV_PAR03,;
							MV_PAR04,;
							MV_PAR05,;
							MV_PAR06,;
							MV_PAR07,;
							MV_PAR08,;
							MV_PAR09,;
							MV_PAR10}
			MPSysOpenQuery(cQuery,"ST9TRB",,,aBindParam)
			//TCQUERY CQUERY NEW ALIAS "ST9TRB"*/

			XSTRU := {}
			ATAM:=TAMSX3("T9_CENTRAB")
			AADD(XSTRU, {"T9_CENTRAB"	,ATAM[3],ATAM[1],ATAM[2] } )
			ATAM:=TAMSX3("T9_CODFAMI")
			AADD(XSTRU, {"T9_CODFAMI" 	,ATAM[3],ATAM[1],ATAM[2] } )
			ATAM:=TAMSX3("T6_NOME")
			AADD(XSTRU, {"T6_NOME" 		,ATAM[3],ATAM[1],ATAM[2] } )
			AADD(XSTRU, {"QTDBEM" 		,"N", 12,0 } )
			AADD(XSTRU, {"DISP"  		,"N", 12,0 } )
			AADD(XSTRU, {"CON"   		,"N", 12,0 } )
			AADD(XSTRU, {"NFRE"  		,"N", 12,0 } )
			AADD(XSTRU, {"TRE"   		,"N", 12,0 } )
			AADD(XSTRU, {"ENT"   		,"N", 12,0 } )
			AADD(XSTRU, {"SRT"   		,"N", 12,0 } )
			AADD(XSTRU, {"NFRR"  		,"N", 12,0 } )
			AADD(XSTRU, {"MNT"   		,"N", 12,0 } )
			AADD(XSTRU, {"PAR"   		,"N", 12,0 } )
			AADD(XSTRU, {"OTR"   		,"N", 12,0 } )
			AADD(XSTRU, {"QTDBEMCTR"   	,"N", 12,0 } )
			AADD(XSTRU, {"TDISP"   		,"N", 12,0 } )
			AADD(XSTRU, {"TCON"   		,"N", 12,0 } )
			AADD(XSTRU, {"TNFRE"   		,"N", 12,0 } )
			AADD(XSTRU, {"TTRE"   		,"N", 12,0 } )
			AADD(XSTRU, {"TENT"   		,"N", 12,0 } )
			AADD(XSTRU, {"TSRT"   		,"N", 12,0 } )
			AADD(XSTRU, {"TNFRR"   		,"N", 12,0 } )
			AADD(XSTRU, {"TMNT"   		,"N", 12,0 } )
			AADD(XSTRU, {"TPAR"   		,"N", 12,0 } )
			AADD(XSTRU, {"TOTR"   		,"N", 12,0 } )
			
			CT61  := "T61"+SUBSTR(TIME(),1,2)+SUBSTR(TIME(),4,2)+SUBSTR(TIME(),7,2)
			CTI61 := "TI61"+SUBSTR(TIME(),1,2)+SUBSTR(TIME(),4,2)+SUBSTR(TIME(),7,2)
			IF TCCANOPEN(CT61)
				TCDELFILE(CT61)
			ENDIF
			DBCREATE(CT61, XSTRU, "TOPCONN")
			DBUSEAREA(.T., "TOPCONN", CT61, ("ST9TRB"), .F., .F.)
			DBCREATEINDEX(CTI61, "T9_CENTRAB+T9_CODFAMI", {|| T9_CENTRAB+T9_CODFAMI  })
			ST9TRB->( DBCLEARINDEX() ) //FORÇA O FECHAMENTO DOS INDICES ABERTOS
			DBSETINDEX(CTI61) //ACRESCENTA A ORDEM DE INDICE PARA A ÁREA ABERTA

			aResultado := {}
			ST9->(dbSetOrder(1))
			ST9->(dbSeek(xFilial("ST9")))
			While !ST9->(Eof()) .and. ST9->T9_FILIAL == xFilial("ST9")
				
				If ST9->T9_CENTRAB < MV_PAR01 .or. ST9->T9_CENTRAB > MV_PAR02
					ST9->(dbSkip())
					Loop
				EndIF

				If ST9->T9_CODBEM < MV_PAR03 .or. ST9->T9_CODBEM > MV_PAR04
					ST9->(dbSkip())
					Loop
				EndIF

				If ST9->T9_CODFAMI < MV_PAR05 .or. ST9->T9_CODFAMI > MV_PAR06
					ST9->(dbSkip())
					Loop
				EndIF

				If ST9->T9_TIPMOD < MV_PAR07 .or. ST9->T9_TIPMOD > MV_PAR08
					ST9->(dbSkip())
					Loop
				EndIF

				If ST9->T9_STATUS < MV_PAR09 .or. ST9->T9_STATUS > MV_PAR10
					ST9->(dbSkip())
					Loop
				EndIF

				If ST9->T9_SITBEM <> 'A' .or. ST9->T9_STATUS == ""
					ST9->(dbSkip())
					Loop
				EndIF

				lAchou := .F.
				For nX := 1 to len(aResultado)
					If aResultado[nX,1] == ST9->T9_CENTRAB
						lAchou := .T.
						Exit
					EndIF
				Next

				If !lAchou

					// Localizar a quantidade de bens LOCR009B(1)
					// Localizar os disponiveis LOCR009B(2)
					// Localizar os em contrato LOCR009B(3)
					// Localizar os em nota fiscal de remessa LOCR009B(4)
					// Localizar com solicitação de retirada LOCR009B(5)
					// Localizar com nota fiscal de retorno LOCR009B(6)
					// Localizar outros LOCR009B(7)

					//                                     total de itens,              disponivel                   ,contrato                     ,remessa                      , transito ,entregue, sol.retira                   , retirada   , Manutencao, Parceiros, outros, 
					aadd(aResultado,{ST9->T9_CENTRAB,"","",LOCR009B(1,MV_PAR12,MV_PAR13),LOCR009B(2,MV_PAR12,MV_PAR13),LOCR009B(3,MV_PAR12,MV_PAR13),LOCR009B(4,MV_PAR12,MV_PAR13)         ,0       , LOCR009B(5,MV_PAR12,MV_PAR13), LOCR009B(6,MV_PAR12,MV_PAR13), 0         , 0        , LOCR009B(7,MV_PAR12,MV_PAR13)     ,0,0,0,0,0,0,0,0,0,0,0,0})
				EndIF
				
				ST9->(dbSkip())
			EndDo

			For nX := 1 to len(aResultado)			

				ST9TRB->(Reclock("ST9TRB",.T.))
				ST9TRB->T9_CENTRAB	:= aResultado[nX,01]
				ST9TRB->T9_CODFAMI	:= aResultado[nX,02]
				ST9TRB->T6_NOME		:= aResultado[nX,03]
				ST9TRB->QTDBEM		:= aResultado[nX,04]
				ST9TRB->DISP		:= aResultado[nX,05] 
				ST9TRB->CON			:= aResultado[nX,06] 
				ST9TRB->NFRE		:= aResultado[nX,07] 
				ST9TRB->TRE			:= aResultado[nX,08] 
				ST9TRB->ENT			:= aResultado[nX,09] 
				ST9TRB->SRT			:= aResultado[nX,10] 
				ST9TRB->NFRR		:= aResultado[nX,11] 
				ST9TRB->MNT			:= aResultado[nX,12] 
				ST9TRB->PAR			:= aResultado[nX,13] 
				ST9TRB->OTR			:= aResultado[nX,14] 
				ST9TRB->QTDBEMCTR	:= aResultado[nX,04] //aResultado[nX,15] 
				ST9TRB->TDISP		:= aResultado[nX,05] //aResultado[nX,16] 
				ST9TRB->TCON		:= aResultado[nX,06] //aResultado[nX,17] 
				ST9TRB->TNFRE		:= aResultado[nX,07] //aResultado[nX,18] 
				ST9TRB->TTRE		:= aResultado[nX,08] //aResultado[nX,19] 
				ST9TRB->TENT		:= aResultado[nX,09] //aResultado[nX,20] 
				ST9TRB->TSRT		:= aResultado[nX,10] //aResultado[nX,21] 
				ST9TRB->TNFRR		:= aResultado[nX,11] //aResultado[nX,22] 
				ST9TRB->TMNT		:= aResultado[nX,12] //aResultado[nX,23] 
				ST9TRB->TPAR		:= aResultado[nX,13] //aResultado[nX,24] 
				ST9TRB->TOTR		:= aResultado[nX,14] //aResultado[nX,25]
				ST9TRB->(MsUnlock())

			NExt

		else

			/*
			+MV_PAR01+
			+MV_PAR02+
			+MV_PAR03+
			+MV_PAR04+
			+MV_PAR05+
			+MV_PAR06+
			+MV_PAR07+
			+MV_PAR08+
			+MV_PAR09+
			+MV_PAR10+
			*/
			XSTRU := {}
			ATAM:=TAMSX3("T9_CENTRAB")
			AADD(XSTRU, {"T9_CENTRAB"	,ATAM[3],ATAM[1],ATAM[2] } )
			ATAM:=TAMSX3("T9_CODFAMI")
			AADD(XSTRU, {"T9_CODFAMI" 	,ATAM[3],ATAM[1],ATAM[2] } )
			ATAM:=TAMSX3("T6_NOME")
			AADD(XSTRU, {"T6_NOME" 		,ATAM[3],ATAM[1],ATAM[2] } )
			AADD(XSTRU, {"QTDBEM" 		,"N", 12,0 } )
			AADD(XSTRU, {"DISP"  		,"N", 12,0 } )
			AADD(XSTRU, {"CON"   		,"N", 12,0 } )
			AADD(XSTRU, {"NFRE"  		,"N", 12,0 } )
			AADD(XSTRU, {"TRE"   		,"N", 12,0 } )
			AADD(XSTRU, {"ENT"   		,"N", 12,0 } )
			AADD(XSTRU, {"SRT"   		,"N", 12,0 } )
			AADD(XSTRU, {"NFRR"  		,"N", 12,0 } )
			AADD(XSTRU, {"MNT"   		,"N", 12,0 } )
			AADD(XSTRU, {"PAR"   		,"N", 12,0 } )
			AADD(XSTRU, {"OTR"   		,"N", 12,0 } )
			AADD(XSTRU, {"QTDBEMCTR"   	,"N", 12,0 } )
			AADD(XSTRU, {"TDISP"   		,"N", 12,0 } )
			AADD(XSTRU, {"TCON"   		,"N", 12,0 } )
			AADD(XSTRU, {"TNFRE"   		,"N", 12,0 } )
			AADD(XSTRU, {"TTRE"   		,"N", 12,0 } )
			AADD(XSTRU, {"TENT"   		,"N", 12,0 } )
			AADD(XSTRU, {"TSRT"   		,"N", 12,0 } )
			AADD(XSTRU, {"TNFRR"   		,"N", 12,0 } )
			AADD(XSTRU, {"TMNT"   		,"N", 12,0 } )
			AADD(XSTRU, {"TPAR"   		,"N", 12,0 } )
			AADD(XSTRU, {"TOTR"   		,"N", 12,0 } )
			
			CT61  := "T61"+SUBSTR(TIME(),1,2)+SUBSTR(TIME(),4,2)+SUBSTR(TIME(),7,2)
			CTI61 := "TI61"+SUBSTR(TIME(),1,2)+SUBSTR(TIME(),4,2)+SUBSTR(TIME(),7,2)
			IF TCCANOPEN(CT61)
				TCDELFILE(CT61)
			ENDIF
			DBCREATE(CT61, XSTRU, "TOPCONN")
			DBUSEAREA(.T., "TOPCONN", CT61, ("ST9TRB"), .F., .F.)
			DBCREATEINDEX(CTI61, "T9_CENTRAB+T9_CODFAMI", {|| T9_CENTRAB+T9_CODFAMI  })
			ST9TRB->( DBCLEARINDEX() ) //FORÇA O FECHAMENTO DOS INDICES ABERTOS
			DBSETINDEX(CTI61) //ACRESCENTA A ORDEM DE INDICE PARA A ÁREA ABERTA

			aResultado := {}
			ST9->(dbSetOrder(1))
			ST9->(dbSeek(xFilial("ST9")))
			While !ST9->(Eof()) .and. ST9->T9_FILIAL == xFilial("ST9")
				
				If ST9->T9_CENTRAB < MV_PAR01 .or. ST9->T9_CENTRAB > MV_PAR02
					ST9->(dbSkip())
					Loop
				EndIF

				If ST9->T9_CODBEM < MV_PAR03 .or. ST9->T9_CODBEM > MV_PAR04
					ST9->(dbSkip())
					Loop
				EndIF

				If ST9->T9_CODFAMI < MV_PAR05 .or. ST9->T9_CODFAMI > MV_PAR06
					ST9->(dbSkip())
					Loop
				EndIF

				If ST9->T9_TIPMOD < MV_PAR07 .or. ST9->T9_TIPMOD > MV_PAR08
					ST9->(dbSkip())
					Loop
				EndIF

				If ST9->T9_STATUS < MV_PAR09 .or. ST9->T9_STATUS > MV_PAR10
					ST9->(dbSkip())
					Loop
				EndIF

				If ST9->T9_SITBEM <> 'A' .or. ST9->T9_STATUS == ""
					ST9->(dbSkip())
					Loop
				EndIF

				lAchou := .F.
				For nX := 1 to len(aResultado)
					If aResultado[nX,1] == ST9->T9_CENTRAB
						lAchou := .T.
						Exit
					EndIF
				Next

				If !lAchou

					// Localizar a quantidade de bens LOCR009B(1)
					// Localizar os disponiveis LOCR009B(2)
					// Localizar os em contrato LOCR009B(3)
					// Localizar os em nota fiscal de remessa LOCR009B(4)
					// Localizar com solicitação de retirada LOCR009B(5)
					// Localizar com nota fiscal de retorno LOCR009B(6)
					// Localizar outros LOCR009B(7)

					//                                     quantidade ,disponivel ,contrato   ,remessa    , transito ,entregue, sol.retira , retirada   , Manutencao, Parceiros, outros, 
					aadd(aResultado,{ST9->T9_CENTRAB,"","",LOCR009B(1),LOCR009B(2),LOCR009B(3),LOCR009B(4),0       , LOCR009B(5), LOCR009B(6), 0         , 0        , LOCR009B(7)     ,0,0,0,0,0,0,0,0,0,0,0,0})
				EndIF
				
				ST9->(dbSkip())
			EndDo

			For nX := 1 to len(aResultado)			

				ST9TRB->(Reclock("ST9TRB",.T.))
				ST9TRB->T9_CENTRAB	:= aResultado[nX,01]
				ST9TRB->T9_CODFAMI	:= aResultado[nX,02]
				ST9TRB->T6_NOME		:= aResultado[nX,03]
				ST9TRB->QTDBEM		:= aResultado[nX,04]
				ST9TRB->DISP		:= aResultado[nX,05] 
				ST9TRB->CON			:= aResultado[nX,06] 
				ST9TRB->NFRE		:= aResultado[nX,07] 
				ST9TRB->TRE			:= aResultado[nX,08] 
				ST9TRB->ENT			:= aResultado[nX,09] 
				ST9TRB->SRT			:= aResultado[nX,10] 
				ST9TRB->NFRR		:= aResultado[nX,11] 
				ST9TRB->MNT			:= aResultado[nX,12] 
				ST9TRB->PAR			:= aResultado[nX,13] 
				ST9TRB->OTR			:= aResultado[nX,14] 
				ST9TRB->QTDBEMCTR	:= aResultado[nX,04] //aResultado[nX,15] 
				ST9TRB->TDISP		:= aResultado[nX,05] //aResultado[nX,16] 
				ST9TRB->TCON		:= aResultado[nX,06] //aResultado[nX,17] 
				ST9TRB->TNFRE		:= aResultado[nX,07] //aResultado[nX,18] 
				ST9TRB->TTRE		:= aResultado[nX,08] //aResultado[nX,19] 
				ST9TRB->TENT		:= aResultado[nX,09] //aResultado[nX,20] 
				ST9TRB->TSRT		:= aResultado[nX,10] //aResultado[nX,21] 
				ST9TRB->TNFRR		:= aResultado[nX,11] //aResultado[nX,22] 
				ST9TRB->TMNT		:= aResultado[nX,12] //aResultado[nX,23] 
				ST9TRB->TPAR		:= aResultado[nX,13] //aResultado[nX,24] 
				ST9TRB->TOTR		:= aResultado[nX,14] //aResultado[nX,25]
				ST9TRB->(MsUnlock())

			NExt
						
			
			/*
			CQUERY += " (SELECT COUNT(ST91.T9_CODBEM) QTDBEMTRB FROM "+RETSQLNAME("ST9")+" ST91 WHERE ST91.D_E_L_E_T_='' AND ST91.T9_CENTRAB = ST9.T9_CENTRAB AND ST91.T9_STATUS IN ((SELECT TQY_STATUS FROM "+RETSQLNAME("TQY")+" WHERE TQY_STTCTR = '00')) AND ST91.T9_SITBEM	= 'A' "   
			CQUERY += " GROUP BY ST91.T9_CENTRAB) TDISP, "                                                  
			CQUERY += " (SELECT COUNT(ST91.T9_CODBEM) QTDBEMTRB FROM "+RETSQLNAME("ST9")+" ST91 WHERE ST91.D_E_L_E_T_='' AND ST91.T9_CENTRAB = ST9.T9_CENTRAB AND ST91.T9_STATUS IN ((SELECT TQY_STATUS FROM "+RETSQLNAME("TQY")+" WHERE TQY_STTCTR = '10'))  AND ST91.T9_SITBEM = 'A' "   
			CQUERY += " GROUP BY ST91.T9_CENTRAB) TCON, "                                                
			CQUERY += " (SELECT COUNT(ST91.T9_CODBEM) QTDBEMTRB FROM "+RETSQLNAME("ST9")+" ST91 WHERE ST91.D_E_L_E_T_='' AND ST91.T9_CENTRAB = ST9.T9_CENTRAB AND ST91.T9_STATUS IN ((SELECT TQY_STATUS FROM "+RETSQLNAME("TQY")+" WHERE TQY_STTCTR = '20'))  AND ST91.T9_SITBEM = 'A' "   
			CQUERY += " GROUP BY ST91.T9_CENTRAB) TNFRE, "                                                  
			CQUERY += " (SELECT COUNT(ST91.T9_CODBEM) QTDBEMTRB FROM "+RETSQLNAME("ST9")+" ST91 WHERE ST91.D_E_L_E_T_='' AND ST91.T9_CENTRAB = ST9.T9_CENTRAB AND ST91.T9_STATUS IN ((SELECT TQY_STATUS FROM "+RETSQLNAME("TQY")+" WHERE TQY_STTCTR = '30'))  AND ST91.T9_SITBEM = 'A' "   
			CQUERY += " GROUP BY ST91.T9_CENTRAB) TTRE, "                                                 
			CQUERY += " (SELECT COUNT(ST91.T9_CODBEM) QTDBEMTRB FROM "+RETSQLNAME("ST9")+" ST91 WHERE ST91.D_E_L_E_T_='' AND ST91.T9_CENTRAB = ST9.T9_CENTRAB AND ST91.T9_STATUS IN ((SELECT TQY_STATUS FROM "+RETSQLNAME("TQY")+" WHERE TQY_STTCTR = '40'))  AND ST91.T9_SITBEM = 'A' "   
			CQUERY += " GROUP BY ST91.T9_CENTRAB) TENT, "                                                
			CQUERY += " (SELECT COUNT(ST91.T9_CODBEM) QTDBEMTRB FROM "+RETSQLNAME("ST9")+" ST91 WHERE ST91.D_E_L_E_T_='' AND ST91.T9_CENTRAB = ST9.T9_CENTRAB AND ST91.T9_STATUS IN ((SELECT TQY_STATUS FROM "+RETSQLNAME("TQY")+" WHERE TQY_STTCTR = '50'))  AND ST91.T9_SITBEM = 'A' "   
			CQUERY += " GROUP BY ST91.T9_CENTRAB) TSRT, "                                               
			CQUERY += " (SELECT COUNT(ST91.T9_CODBEM) QTDBEMTRB FROM "+RETSQLNAME("ST9")+" ST91 WHERE ST91.D_E_L_E_T_='' AND ST91.T9_CENTRAB = ST9.T9_CENTRAB AND ST91.T9_STATUS IN ((SELECT TQY_STATUS FROM "+RETSQLNAME("TQY")+" WHERE TQY_STTCTR = '60'))  AND ST91.T9_SITBEM = 'A' "   
			CQUERY += " GROUP BY ST91.T9_CENTRAB) TNFRR, "                                              
			CQUERY += " (SELECT COUNT(ST91.T9_CODBEM) QTDBEMTRB FROM "+RETSQLNAME("ST9")+" ST91 WHERE ST91.D_E_L_E_T_='' AND ST91.T9_CENTRAB = ST9.T9_CENTRAB AND ST91.T9_STATUS IN ((SELECT TQY_STATUS FROM "+RETSQLNAME("TQY")+" WHERE TQY_STTCTR = '70'))  AND ST91.T9_SITBEM = 'A' "   
			CQUERY += " GROUP BY ST91.T9_CENTRAB) TMNT,	"                                             
			CQUERY += " (SELECT COUNT(ST91.T9_CODBEM) QTDBEMTRB FROM "+RETSQLNAME("ST9")+" ST91 WHERE ST91.D_E_L_E_T_='' AND ST91.T9_CENTRAB = ST9.T9_CENTRAB AND ST91.T9_STATUS IN ((SELECT TQY_STATUS FROM "+RETSQLNAME("TQY")+" WHERE TQY_STTCTR = '80'))  AND ST91.T9_SITBEM = 'A' "   
			CQUERY += " GROUP BY ST91.T9_CENTRAB) TPAR,	"                                                  
			CQUERY += " (SELECT COUNT(ST91.T9_CODBEM) QTDBEMTRB FROM "+RETSQLNAME("ST9")+" ST91 WHERE ST91.D_E_L_E_T_='' AND ST91.T9_CENTRAB = ST9.T9_CENTRAB AND ST91.T9_STATUS NOT IN ('"+ITST9STAT("00")+"','"+ITST9STAT("10")+"','"+ITST9STAT("20")+"','"+ITST9STAT("30")+"','"+ITST9STAT("40")+"','"+ITST9STAT("50")+"','"+ITST9STAT("60")+"','"+ITST9STAT("70")+"','"+ITST9STAT("80")+"') AND ST91.T9_SITBEM = 'A' "   
			CQUERY += " GROUP BY ST91.T9_CENTRAB) TOTR "                                             
			CQUERY += " FROM "+RETSQLNAME("ST9")+" ST9 "         
			CQUERY += " INNER JOIN "+RETSQLNAME("SHB")+" SHB "  
			CQUERY += " ON SHB.HB_COD = ST9.T9_CENTRAB "         
			CQUERY += " AND SHB.D_E_L_E_T_='' "               
			CQUERY += " INNER JOIN	"+RETSQLNAME("ST6")+" ST6 "  
			CQUERY += " ON ST9.T9_CODFAMI =	ST6.T6_CODFAMI "  
			CQUERY += " AND ST9.D_E_L_E_T_ = '' "  
			CQUERY += " WHERE ST9.D_E_L_E_T_ = '' "             
			CQUERY += " AND ST9.T9_CENTRAB BETWEEN ? AND ? "  
			CQUERY += " AND ST9.T9_CODBEM BETWEEN ? AND ? "  
			CQUERY += " AND ST9.T9_CODFAMI BETWEEN ? AND ? "  
			CQUERY += " AND ST9.T9_TIPMOD BETWEEN ? AND ? "  
			CQUERY += " AND ST9.T9_STATUS BETWEEN ? AND ? "  
			CQUERY += " AND ST9.T9_SITBEM =	'A' "  
			cQuery += " AND ST9.T9_STATUS <> '' "
			CQUERY += " GROUP BY ST9.T9_CENTRAB,  "  
			CQUERY += " ST9.T9_CODFAMI, "  
			CQUERY += " ST6.T6_NOME "  
			CQUERY += " ORDER BY ST9.T9_CENTRAB, "  
			CQUERY += " ST9.T9_CODFAMI "  

			IF SELECT("ST9TRB") > 0
				ST9TRB->(DBCLOSEAREA())
			ENDIF

			CQUERY := CHANGEQUERY(CQUERY) 
			aBindParam := {	MV_PAR01,;
							MV_PAR02,;
							MV_PAR03,;
							MV_PAR04,;
							MV_PAR05,;
							MV_PAR06,;
							MV_PAR07,;
							MV_PAR08,;
							MV_PAR09,;
							MV_PAR10}
			MPSysOpenQuery(cQuery,"ST9TRB",,,aBindParam)
			//TCQUERY CQUERY NEW ALIAS "ST9TRB"*/

		EndIF

		ST9TRB->(DBGOTOP())

		IIF( ST9TRB->(EOF()) , LRET := .F. , LRET := .T. )

	ELSEIF MV_PAR11 == 2

		IF lFiltraCli

			/*
			+ cListaBens +
			+ cListaBens +
			+ cListaBens +
			+ cListaBens +
			+ cListaBens +
			+ cListaBens +
			+ cListaBens +
			+ cListaBens +
			+ cListaBens +
			+ cListaBens +
			+MV_PAR01+
			+MV_PAR02+
			+cListaBens +
			+MV_PAR03+
			+MV_PAR04+
			+MV_PAR05+
			+MV_PAR06+
			+MV_PAR07+
			+MV_PAR08+
			+MV_PAR09+
			+MV_PAR10+
			*/

			CQUERY += " SELECT	"  
			CQUERY += "		ZZZ.R_E_C_N_O_ RECNOFQ4,		"  
			CQUERY += "		ST9.R_E_C_N_O_ RECNOST9,		"  
			CQUERY += "		ST9.T9_CODBEM,		"  
			CQUERY += "		ST9.T9_CODIMOB,		"  
			CQUERY += " 	ST9.T9_TIPMOD,		"  
			CQUERY += "		ST9.T9_CODFAMI,		"  
			CQUERY += "		ST9.T9_FABRICA,		"  
			CQUERY += "		ST9.T9_NOME,		"  
			CQUERY += "		ST9.T9_STATUS,		"  
			CQUERY += "		SHB.HB_COD,		"  
			CQUERY += "		SHB.HB_NOME,		"  
			CQUERY += "		SHB.HB_CC,		"  
			CQUERY += "		COALESCE(ZZZ.FQ4_DOCUME,'') FQ4_DOCUME,		"  
			CQUERY += "		COALESCE(ZZZ.FQ4_SERIE,'') FQ4_SERIE,		"  
			CQUERY += "		COALESCE(ZZZ.FQ4_OS,'') FQ4_OS,		"  
			CQUERY += "		COALESCE(ZZZ.FQ4_SERVIC,'') FQ4_SERVIC,		"  
			CQUERY += "		COALESCE(ZZZ.FQ4_PRELIB,'') FQ4_PRELIB,		"  
			CQUERY += "		COALESCE(ZZZ.FQ4_PROJET,'') FQ4_PROJET,		"  
			CQUERY += "		COALESCE(ZZZ.FQ4_OBRA,'') FQ4_OBRA,		"  
			CQUERY += "		COALESCE(ZZZ.FQ4_AS,'') FQ4_AS,		"  
			CQUERY += "		COALESCE(ZZZ.FQ4_CODCLI,'') FQ4_CODCLI,		"  
			CQUERY += "		COALESCE(ZZZ.FQ4_LOJCLI,'') FQ4_LOJCLI,		"  
			CQUERY += "		COALESCE(ZZZ.FQ4_NOMCLI,'') FQ4_NOMCLI,		"  
			CQUERY += "		COALESCE(ZZZ.FQ4_NFREM,'') FQ4_NFREM,		"  
			CQUERY += "		COALESCE(ZZZ.FQ4_SERREM,'') FQ4_SERREM,		"  
			CQUERY += "		COALESCE(ZZZ.FQ4_DTINI,'') FQ4_DTINI,		"  
			CQUERY += "		COALESCE(ZZZ.FQ4_DTFIM,'') FQ4_DTFIM,		"  
			CQUERY += "		COALESCE(ZZZ.FQ4_LOG,'') FQ4_LOG,		"  
			CQUERY += "		COALESCE(ZZZ.FQ4_PREDES,'') FQ4_PREDES		"  
			//CQUERY += "		COALESCE(SA1.A1_END,'') A1_END,		"  
			//CQUERY += "		COALESCE(SA1.A1_MUN,'') A1_MUN,		"  
			//CQUERY += "		COALESCE(SA1.A1_EST,'') A1_EST,		"  
			// 11/10/2022 - Jose Eulalio - SIGALOC94-528 - Filtro por Cliente (trazer apenas o Status mais recente de cada bem)
/*			If !lMvLocBac
				//CQUERY += "	COALESCE((SELECT COUNT(ST91.T9_CODFAMI) QTDFAMI FROM "+RETSQLNAME("ST9")+" ST91 WHERE ST91.D_E_L_E_T_='' AND ST91.T9_STATUS = '"+ITST9STAT("00")+"' AND ST91.T9_CENTRAB = ST9.T9_CENTRAB AND ST91.T9_CODFAMI = ST9.T9_CODFAMI AND ST91.T9_SITBEM	=	'A'	 "   
				CQUERY += "	COALESCE((SELECT COUNT(ST91.T9_CODFAMI) QTDFAMI FROM "+RETSQLNAME("ST9")+" ST91 WHERE ST91.D_E_L_E_T_='' AND ST91.T9_STATUS = ? AND ST91.T9_CENTRAB = ST9.T9_CENTRAB AND ST91.T9_CODFAMI = ST9.T9_CODFAMI AND ST91.T9_SITBEM	=	'A'	 "   
			else
				//CQUERY += "	COALESCE((SELECT COUNT(ST91.T9_CODFAMI) QTDFAMI FROM "+RETSQLNAME("ST9")+" ST91 WHERE ST91.D_E_L_E_T_='' AND ST91.T9_STATUS = '"+ITST9STAT("00")+"' AND ST91.T9_CENTRAB = ST9.T9_CENTRAB AND ST91.T9_CODFAMI = ST9.T9_CODFAMI AND ST91.T9_SITBEM	=	'A'	 "   
				CQUERY += "	COALESCE((SELECT COUNT(ST91.T9_CODFAMI) QTDFAMI FROM "+RETSQLNAME("ST9")+" ST91 WHERE ST91.D_E_L_E_T_='' AND ST91.T9_STATUS = ? AND ST91.T9_CENTRAB = ST9.T9_CENTRAB AND ST91.T9_CODFAMI = ST9.T9_CODFAMI AND ST91.T9_SITBEM	=	'A'	 "   
			endif
			CQUERY += " 			  GROUP BY ST91.T9_CODFAMI),0)  DISP, "   
			If !lMvLocBac
				//CQUERY += " COALESCE((SELECT COUNT(ST91.T9_CODFAMI) QTDFAMI FROM "+RETSQLNAME("ST9")+" ST91 WHERE ST91.D_E_L_E_T_='' AND ST91.T9_STATUS = '"+ITST9STAT("10")+"' AND ST91.T9_CENTRAB = ST9.T9_CENTRAB AND ST91.T9_CODFAMI = ST9.T9_CODFAMI AND ST91.T9_SITBEM	=	'A'	 "   
				CQUERY += " COALESCE((SELECT COUNT(ST91.T9_CODFAMI) QTDFAMI FROM "+RETSQLNAME("ST9")+" ST91 WHERE ST91.D_E_L_E_T_='' AND ST91.T9_STATUS = ? AND ST91.T9_CENTRAB = ST9.T9_CENTRAB AND ST91.T9_CODFAMI = ST9.T9_CODFAMI AND ST91.T9_SITBEM	=	'A'	 "   
			else
				//CQUERY += "	COALESCE((SELECT COUNT(ST91.T9_CODFAMI) QTDFAMI FROM "+RETSQLNAME("ST9")+" ST91 WHERE ST91.D_E_L_E_T_='' AND ST91.T9_STATUS = '"+ITST9STAT("10")+"' AND ST91.T9_CENTRAB = ST9.T9_CENTRAB AND ST91.T9_CODFAMI = ST9.T9_CODFAMI AND ST91.T9_SITBEM	=	'A'	 "   
				CQUERY += "	COALESCE((SELECT COUNT(ST91.T9_CODFAMI) QTDFAMI FROM "+RETSQLNAME("ST9")+" ST91 WHERE ST91.D_E_L_E_T_='' AND ST91.T9_STATUS = ? AND ST91.T9_CENTRAB = ST9.T9_CENTRAB AND ST91.T9_CODFAMI = ST9.T9_CODFAMI AND ST91.T9_SITBEM	=	'A'	 "   
			endif
			CQUERY += " 			  GROUP BY ST91.T9_CODFAMI),0)  CON, "  
			If !lMvLocBac
				//CQUERY += "	COALESCE((SELECT COUNT(ST91.T9_CODFAMI) QTDFAMI FROM "+RETSQLNAME("ST9")+" ST91 WHERE ST91.D_E_L_E_T_='' AND ST91.T9_STATUS = '"+ITST9STAT("20")+"' AND ST91.T9_CENTRAB = ST9.T9_CENTRAB AND ST91.T9_CODFAMI = ST9.T9_CODFAMI AND ST91.T9_SITBEM	=	'A'	 "   
				CQUERY += "	COALESCE((SELECT COUNT(ST91.T9_CODFAMI) QTDFAMI FROM "+RETSQLNAME("ST9")+" ST91 WHERE ST91.D_E_L_E_T_='' AND ST91.T9_STATUS = ? AND ST91.T9_CENTRAB = ST9.T9_CENTRAB AND ST91.T9_CODFAMI = ST9.T9_CODFAMI AND ST91.T9_SITBEM	=	'A'	 "   
			else
				//CQUERY += "	COALESCE((SELECT COUNT(ST91.T9_CODFAMI) QTDFAMI FROM "+RETSQLNAME("ST9")+" ST91 WHERE ST91.D_E_L_E_T_='' AND ST91.T9_STATUS = '"+ITST9STAT("20")+"' AND ST91.T9_CENTRAB = ST9.T9_CENTRAB AND ST91.T9_CODFAMI = ST9.T9_CODFAMI AND ST91.T9_SITBEM	=	'A'	 "   
				CQUERY += "	COALESCE((SELECT COUNT(ST91.T9_CODFAMI) QTDFAMI FROM "+RETSQLNAME("ST9")+" ST91 WHERE ST91.D_E_L_E_T_='' AND ST91.T9_STATUS = ? AND ST91.T9_CENTRAB = ST9.T9_CENTRAB AND ST91.T9_CODFAMI = ST9.T9_CODFAMI AND ST91.T9_SITBEM	=	'A'	 "   
			endif
			CQUERY += " 			  GROUP BY ST91.T9_CODFAMI),0)  NFRE,"  
			If !lMvLocBac
				//CQUERY += " COALESCE((SELECT COUNT(ST91.T9_CODFAMI) QTDFAMI FROM "+RETSQLNAME("ST9")+" ST91 WHERE ST91.D_E_L_E_T_='' AND ST91.T9_STATUS = '"+ITST9STAT("30")+"' AND ST91.T9_CENTRAB = ST9.T9_CENTRAB AND ST91.T9_CODFAMI = ST9.T9_CODFAMI AND ST91.T9_SITBEM	=	'A'	 "   
				CQUERY += " COALESCE((SELECT COUNT(ST91.T9_CODFAMI) QTDFAMI FROM "+RETSQLNAME("ST9")+" ST91 WHERE ST91.D_E_L_E_T_='' AND ST91.T9_STATUS = ? AND ST91.T9_CENTRAB = ST9.T9_CENTRAB AND ST91.T9_CODFAMI = ST9.T9_CODFAMI AND ST91.T9_SITBEM	=	'A'	 "   
			else
				//CQUERY += "	COALESCE((SELECT COUNT(ST91.T9_CODFAMI) QTDFAMI FROM "+RETSQLNAME("ST9")+" ST91 WHERE ST91.D_E_L_E_T_='' AND ST91.T9_STATUS = '"+ITST9STAT("30")+"' AND ST91.T9_CENTRAB = ST9.T9_CENTRAB AND ST91.T9_CODFAMI = ST9.T9_CODFAMI AND ST91.T9_SITBEM	=	'A'	 "   
				CQUERY += "	COALESCE((SELECT COUNT(ST91.T9_CODFAMI) QTDFAMI FROM "+RETSQLNAME("ST9")+" ST91 WHERE ST91.D_E_L_E_T_='' AND ST91.T9_STATUS = ? AND ST91.T9_CENTRAB = ST9.T9_CENTRAB AND ST91.T9_CODFAMI = ST9.T9_CODFAMI AND ST91.T9_SITBEM	=	'A'	 "   
			endif
			CQUERY += " 			  GROUP BY ST91.T9_CODFAMI),0)  TRE, "  
			If !lMvLocBac
				//CQUERY += "	COALESCE((SELECT COUNT(ST91.T9_CODFAMI) QTDFAMI FROM "+RETSQLNAME("ST9")+" ST91 WHERE ST91.D_E_L_E_T_='' AND ST91.T9_STATUS = '"+ITST9STAT("40")+"' AND ST91.T9_CENTRAB = ST9.T9_CENTRAB AND ST91.T9_CODFAMI = ST9.T9_CODFAMI AND ST91.T9_SITBEM	=	'A'	 "   
				CQUERY += "	COALESCE((SELECT COUNT(ST91.T9_CODFAMI) QTDFAMI FROM "+RETSQLNAME("ST9")+" ST91 WHERE ST91.D_E_L_E_T_='' AND ST91.T9_STATUS = ? AND ST91.T9_CENTRAB = ST9.T9_CENTRAB AND ST91.T9_CODFAMI = ST9.T9_CODFAMI AND ST91.T9_SITBEM	=	'A'	 "   
			Else
				//CQUERY += "	COALESCE((SELECT COUNT(ST91.T9_CODFAMI) QTDFAMI FROM "+RETSQLNAME("ST9")+" ST91 WHERE ST91.D_E_L_E_T_='' AND ST91.T9_STATUS = '"+ITST9STAT("40")+"' AND ST91.T9_CENTRAB = ST9.T9_CENTRAB AND ST91.T9_CODFAMI = ST9.T9_CODFAMI AND ST91.T9_SITBEM	=	'A'	 "   
				CQUERY += "	COALESCE((SELECT COUNT(ST91.T9_CODFAMI) QTDFAMI FROM "+RETSQLNAME("ST9")+" ST91 WHERE ST91.D_E_L_E_T_='' AND ST91.T9_STATUS = ? AND ST91.T9_CENTRAB = ST9.T9_CENTRAB AND ST91.T9_CODFAMI = ST9.T9_CODFAMI AND ST91.T9_SITBEM	=	'A'	 "   
			EndIF
			CQUERY += " 			  GROUP BY ST91.T9_CODFAMI),0)  ENT, "  
			If !lMvLocBac
				//CQUERY += "	COALESCE((SELECT COUNT(ST91.T9_CODFAMI) QTDFAMI FROM "+RETSQLNAME("ST9")+" ST91 WHERE ST91.D_E_L_E_T_='' AND ST91.T9_STATUS = '"+ITST9STAT("50")+"' AND ST91.T9_CENTRAB = ST9.T9_CENTRAB AND ST91.T9_CODFAMI = ST9.T9_CODFAMI AND ST91.T9_SITBEM	=	'A'	 "   
				CQUERY += "	COALESCE((SELECT COUNT(ST91.T9_CODFAMI) QTDFAMI FROM "+RETSQLNAME("ST9")+" ST91 WHERE ST91.D_E_L_E_T_='' AND ST91.T9_STATUS = ? AND ST91.T9_CENTRAB = ST9.T9_CENTRAB AND ST91.T9_CODFAMI = ST9.T9_CODFAMI AND ST91.T9_SITBEM	=	'A'	 "   
			else
				//CQUERY += "	COALESCE((SELECT COUNT(ST91.T9_CODFAMI) QTDFAMI FROM "+RETSQLNAME("ST9")+" ST91 WHERE ST91.D_E_L_E_T_='' AND ST91.T9_STATUS = '"+ITST9STAT("50")+"' AND ST91.T9_CENTRAB = ST9.T9_CENTRAB AND ST91.T9_CODFAMI = ST9.T9_CODFAMI AND ST91.T9_SITBEM	=	'A'	 "   
				CQUERY += "	COALESCE((SELECT COUNT(ST91.T9_CODFAMI) QTDFAMI FROM "+RETSQLNAME("ST9")+" ST91 WHERE ST91.D_E_L_E_T_='' AND ST91.T9_STATUS = ? AND ST91.T9_CENTRAB = ST9.T9_CENTRAB AND ST91.T9_CODFAMI = ST9.T9_CODFAMI AND ST91.T9_SITBEM	=	'A'	 "   
			endif
			CQUERY += " 			  GROUP BY ST91.T9_CODFAMI),0)  SRT, "  
			If !lMvLocBac
				//CQUERY += "	COALESCE((SELECT COUNT(ST91.T9_CODFAMI) QTDFAMI FROM "+RETSQLNAME("ST9")+" ST91 WHERE ST91.D_E_L_E_T_='' AND ST91.T9_STATUS = '"+ITST9STAT("60")+"' AND ST91.T9_CENTRAB = ST9.T9_CENTRAB AND ST91.T9_CODFAMI = ST9.T9_CODFAMI AND ST91.T9_SITBEM	=	'A'	 "   
				CQUERY += "	COALESCE((SELECT COUNT(ST91.T9_CODFAMI) QTDFAMI FROM "+RETSQLNAME("ST9")+" ST91 WHERE ST91.D_E_L_E_T_='' AND ST91.T9_STATUS = ? AND ST91.T9_CENTRAB = ST9.T9_CENTRAB AND ST91.T9_CODFAMI = ST9.T9_CODFAMI AND ST91.T9_SITBEM	=	'A'	 "   
			else
				//CQUERY += "	COALESCE((SELECT COUNT(ST91.T9_CODFAMI) QTDFAMI FROM "+RETSQLNAME("ST9")+" ST91 WHERE ST91.D_E_L_E_T_='' AND ST91.T9_STATUS = '"+ITST9STAT("60")+"' AND ST91.T9_CENTRAB = ST9.T9_CENTRAB AND ST91.T9_CODFAMI = ST9.T9_CODFAMI AND ST91.T9_SITBEM	=	'A'	 "   
				CQUERY += "	COALESCE((SELECT COUNT(ST91.T9_CODFAMI) QTDFAMI FROM "+RETSQLNAME("ST9")+" ST91 WHERE ST91.D_E_L_E_T_='' AND ST91.T9_STATUS = ? AND ST91.T9_CENTRAB = ST9.T9_CENTRAB AND ST91.T9_CODFAMI = ST9.T9_CODFAMI AND ST91.T9_SITBEM	=	'A'	 "   
			endif
			CQUERY += " 			  GROUP BY ST91.T9_CODFAMI),0)  NFRR,"  
			If !lMvLocBac
				//CQUERY += "	COALESCE((SELECT COUNT(ST91.T9_CODFAMI) QTDFAMI FROM "+RETSQLNAME("ST9")+" ST91 WHERE ST91.D_E_L_E_T_='' AND ST91.T9_STATUS = '"+ITST9STAT("70")+"' AND ST91.T9_CENTRAB = ST9.T9_CENTRAB AND ST91.T9_CODFAMI = ST9.T9_CODFAMI AND ST91.T9_SITBEM	=	'A'	 "   
				CQUERY += "	COALESCE((SELECT COUNT(ST91.T9_CODFAMI) QTDFAMI FROM "+RETSQLNAME("ST9")+" ST91 WHERE ST91.D_E_L_E_T_='' AND ST91.T9_STATUS = ? AND ST91.T9_CENTRAB = ST9.T9_CENTRAB AND ST91.T9_CODFAMI = ST9.T9_CODFAMI AND ST91.T9_SITBEM	=	'A'	 "   
			else
				//CQUERY += "	COALESCE((SELECT COUNT(ST91.T9_CODFAMI) QTDFAMI FROM "+RETSQLNAME("ST9")+" ST91 WHERE ST91.D_E_L_E_T_='' AND ST91.T9_STATUS = '"+ITST9STAT("70")+"' AND ST91.T9_CENTRAB = ST9.T9_CENTRAB AND ST91.T9_CODFAMI = ST9.T9_CODFAMI AND ST91.T9_SITBEM	=	'A'	 "   
				CQUERY += "	COALESCE((SELECT COUNT(ST91.T9_CODFAMI) QTDFAMI FROM "+RETSQLNAME("ST9")+" ST91 WHERE ST91.D_E_L_E_T_='' AND ST91.T9_STATUS = ? AND ST91.T9_CENTRAB = ST9.T9_CENTRAB AND ST91.T9_CODFAMI = ST9.T9_CODFAMI AND ST91.T9_SITBEM	=	'A'	 "   
			endif
			CQUERY += " 			  GROUP BY ST91.T9_CODFAMI),0)  MNT,	"  
			If !lMvLocBac
				//CQUERY += "	COALESCE((SELECT COUNT(ST91.T9_CODFAMI) QTDFAMI FROM "+RETSQLNAME("ST9")+" ST91 WHERE ST91.D_E_L_E_T_='' AND ST91.T9_STATUS = '"+ITST9STAT("80")+"' AND ST91.T9_CENTRAB = ST9.T9_CENTRAB AND ST91.T9_CODFAMI = ST9.T9_CODFAMI AND ST91.T9_SITBEM	=	'A'	 "   
				CQUERY += "	COALESCE((SELECT COUNT(ST91.T9_CODFAMI) QTDFAMI FROM "+RETSQLNAME("ST9")+" ST91 WHERE ST91.D_E_L_E_T_='' AND ST91.T9_STATUS = ? AND ST91.T9_CENTRAB = ST9.T9_CENTRAB AND ST91.T9_CODFAMI = ST9.T9_CODFAMI AND ST91.T9_SITBEM	=	'A'	 "   
			else
				//CQUERY += "	COALESCE((SELECT COUNT(ST91.T9_CODFAMI) QTDFAMI FROM "+RETSQLNAME("ST9")+" ST91 WHERE ST91.D_E_L_E_T_='' AND ST91.T9_STATUS = '"+ITST9STAT("80")+"' AND ST91.T9_CENTRAB = ST9.T9_CENTRAB AND ST91.T9_CODFAMI = ST9.T9_CODFAMI AND ST91.T9_SITBEM	=	'A'	 "   
				CQUERY += "	COALESCE((SELECT COUNT(ST91.T9_CODFAMI) QTDFAMI FROM "+RETSQLNAME("ST9")+" ST91 WHERE ST91.D_E_L_E_T_='' AND ST91.T9_STATUS = ? AND ST91.T9_CENTRAB = ST9.T9_CENTRAB AND ST91.T9_CODFAMI = ST9.T9_CODFAMI AND ST91.T9_SITBEM	=	'A'	 "   
			endif
			CQUERY += " 			  GROUP BY ST91.T9_CODFAMI),0)  PAR, "  
			//CQUERY += " 	COALESCE((SELECT COUNT(ST91.T9_CODFAMI) QTDFAMI FROM "+RETSQLNAME("ST9")+" ST91 WHERE ST91.D_E_L_E_T_='' AND ST91.T9_STATUS NOT IN ('"+ITST9STAT("00")+"','"+ITST9STAT("10")+"','"+ITST9STAT("20")+"','"+ITST9STAT("30")+"','"+ITST9STAT("40")+"','"+ITST9STAT("50")+"','"+ITST9STAT("60")+"','"+ITST9STAT("70")+"','"+ITST9STAT("80")+"') AND ST91.T9_CENTRAB = ST9.T9_CENTRAB AND ST91.T9_CODFAMI = ST9.T9_CODFAMI AND ST91.T9_SITBEM	=	'A' "   
			CQUERY += " 	COALESCE((SELECT COUNT(ST91.T9_CODFAMI) QTDFAMI FROM "+RETSQLNAME("ST9")+" ST91 WHERE ST91.D_E_L_E_T_='' AND ST91.T9_STATUS NOT IN (?,?,?,?,?,?,?,?,?) AND ST91.T9_CENTRAB = ST9.T9_CENTRAB AND ST91.T9_CODFAMI = ST9.T9_CODFAMI AND ST91.T9_SITBEM	=	'A' "   
			CQUERY += " 			 GROUP BY ST91.T9_CODFAMI),0)  OTR "  
*/
			CQUERY += " FROM	"+RETSQLNAME("ST9")+"	ST9		"  

			CQUERY += " INNER JOIN "+RETSQLNAME("FQ4")+" ZZZ     "  
			CQUERY += " ON	ZZZ.FQ4_CODBEM = ST9.T9_CODBEM		"         
			CQUERY += "	AND ZZZ.D_E_L_E_T_=''		"  
			//CQUERY += "	AND ZZZ.R_E_C_N_O_ = (SELECT MAX(ZZZ1.R_E_C_N_O_) FROM "+RETSQLNAME("FQ4")+" ZZZ1 WHERE ZZZ1.FQ4_CODBEM = ST9.T9_CODBEM AND ZZZ1.D_E_L_E_T_ = '' AND ZZZ1.FQ4_CODCLI = '"+MV_PAR12+"' AND ZZZ1.FQ4_LOJCLI = '"+MV_PAR13+"')	"  
			CQUERY += "	AND ZZZ.R_E_C_N_O_ = (SELECT MAX(ZZZ1.R_E_C_N_O_) FROM "+RETSQLNAME("FQ4")+" ZZZ1 WHERE ZZZ1.FQ4_CODBEM = ST9.T9_CODBEM AND ZZZ1.D_E_L_E_T_ = '' AND ZZZ1.FQ4_CODCLI = ? AND ZZZ1.FQ4_LOJCLI = ?)	"  

			CQUERY += " LEFT JOIN "+RETSQLNAME("SHB")+" SHB     "  
			CQUERY += " ON		SHB.HB_COD = ST9.T9_CENTRAB    	"  
			CQUERY += " AND 	SHB.D_E_L_E_T_=''      	"  
			
			CQUERY += " LEFT JOIN	"+RETSQLNAME("ST6")+" ST6 "  
			CQUERY += " 			ON	ST9.T9_CODFAMI	=	ST6.T6_CODFAMI "  
			CQUERY += " 			AND ST9.D_E_L_E_T_	=	'' "  

			CQUERY += " WHERE                   "  
			CQUERY += "  ST9.T9_CENTRAB BETWEEN ? AND ? "  
			// 11/10/2022 - Jose Eulalio - SIGALOC94-528 - Filtro por Cliente (trazer apenas o Status mais recente de cada bem)
			CQUERY += " AND ST9.T9_CODBEM  BETWEEN ? AND ? "  
			CQUERY += " AND ST9.T9_CODFAMI BETWEEN ? AND ? "  
			CQUERY += " AND ST9.T9_TIPMOD  BETWEEN ? AND ? "  
			CQUERY += " AND ST9.T9_STATUS  BETWEEN ? AND ? "  
			CQUERY += " AND ST9.T9_SITBEM	=	'A'				"  
			cQuery += " AND ST9.T9_STATUS <> '' "

			CQUERY += "  ORDER BY			"  
			CQUERY += "  				ST9.T9_CODFAMI,	"  
			CQUERY += "  				ST9.T9_TIPMOD	"

			IF SELECT("ZZZTRB") > 0
				ZZZTRB->(DBCLOSEAREA())
			ENDIF

			CQUERY := CHANGEQUERY(CQUERY) 
/*			aBindParam := {	ITST9STAT("00"),;
							ITST9STAT("10"),;
							ITST9STAT("20"),;
							ITST9STAT("30"),;
							ITST9STAT("40"),;
							ITST9STAT("50"),;
							ITST9STAT("60"),;
							ITST9STAT("70"),;
							ITST9STAT("80"),;
							ITST9STAT("00"),;
							ITST9STAT("10"),;
							ITST9STAT("20"),;
							ITST9STAT("30"),;
							ITST9STAT("40"),;
							ITST9STAT("50"),;
							ITST9STAT("60"),;
							ITST9STAT("70"),;
							ITST9STAT("80"),;
							MV_PAR12,;
							MV_PAR13,;
							MV_PAR01,;
							MV_PAR02,;
							MV_PAR03,;
							MV_PAR04,;
							MV_PAR05,;
							MV_PAR06,;
							MV_PAR07,;
							MV_PAR08,;
							MV_PAR09,;
							MV_PAR10}
			MPSysOpenQuery(cQuery,"ZZZTRB",,,aBindParam)
*/
			aBindParam := {	MV_PAR12,;
							MV_PAR13,;
							MV_PAR01,;
							MV_PAR02,;
							MV_PAR03,;
							MV_PAR04,;
							MV_PAR05,;
							MV_PAR06,;
							MV_PAR07,;
							MV_PAR08,;
							MV_PAR09,;
							MV_PAR10}
			MPSysOpenQuery(cQuery,"ZZZTRB",,,aBindParam)

		else

			/*
			+MV_PAR01+
			+MV_PAR02+
			+MV_PAR03+
			+MV_PAR04+
			+MV_PAR05+
			+MV_PAR06+
			+MV_PAR07+
			+MV_PAR08+
			+MV_PAR09+
			+MV_PAR10+
			*/

			CQUERY += " SELECT	"  
			CQUERY += "		ZZZ.R_E_C_N_O_ RECNOFQ4,		"  
			CQUERY += "		ST9.R_E_C_N_O_ RECNOST9,		"  
			CQUERY += "		ST9.T9_CODBEM,		"  
			CQUERY += "		ST9.T9_CODIMOB,		"  
			CQUERY += " 	ST9.T9_TIPMOD,		"  
			CQUERY += "		ST9.T9_CODFAMI,		"  
			CQUERY += "		ST9.T9_FABRICA,		"  
			CQUERY += "		ST9.T9_NOME,		"  
			CQUERY += "		ST9.T9_STATUS,		"  
			CQUERY += "		SHB.HB_COD,		"  
			CQUERY += "		SHB.HB_NOME,		"  
			CQUERY += "		SHB.HB_CC,		"  
			CQUERY += "		COALESCE(ZZZ.FQ4_DOCUME,'') FQ4_DOCUME,		"  
			CQUERY += "		COALESCE(ZZZ.FQ4_SERIE,'') FQ4_SERIE,		"  
			CQUERY += "		COALESCE(ZZZ.FQ4_OS,'') FQ4_OS,		"  
			CQUERY += "		COALESCE(ZZZ.FQ4_SERVIC,'') FQ4_SERVIC,		"  
			CQUERY += "		COALESCE(ZZZ.FQ4_PRELIB,'') FQ4_PRELIB,		"  
			CQUERY += "		COALESCE(ZZZ.FQ4_PROJET,'') FQ4_PROJET,		"  
			CQUERY += "		COALESCE(ZZZ.FQ4_OBRA,'') FQ4_OBRA,		"  
			CQUERY += "		COALESCE(ZZZ.FQ4_AS,'') FQ4_AS,		"  
			CQUERY += "		COALESCE(ZZZ.FQ4_CODCLI,'') FQ4_CODCLI,		"  
			CQUERY += "		COALESCE(ZZZ.FQ4_LOJCLI,'') FQ4_LOJCLI,		"  
			CQUERY += "		COALESCE(ZZZ.FQ4_NOMCLI,'') FQ4_NOMCLI,		"  
			CQUERY += "		COALESCE(ZZZ.FQ4_NFREM,'') FQ4_NFREM,		"  
			CQUERY += "		COALESCE(ZZZ.FQ4_SERREM,'') FQ4_SERREM,		"  
			CQUERY += "		COALESCE(ZZZ.FQ4_DTINI,'') FQ4_DTINI,		"  
			CQUERY += "		COALESCE(ZZZ.FQ4_DTFIM,'') FQ4_DTFIM,		"  
			CQUERY += "		COALESCE(ZZZ.FQ4_LOG,'') FQ4_LOG,		"  
			CQUERY += "		COALESCE(ZZZ.FQ4_PREDES,'') FQ4_PREDES		"  
			//CQUERY += "		COALESCE(SA1.A1_END,'') A1_END,		"  
			//CQUERY += "		COALESCE(SA1.A1_MUN,'') A1_MUN,		"  
			//CQUERY += "		COALESCE(SA1.A1_EST,'') A1_EST,		"  
			// 11/10/2022 - Jose Eulalio - SIGALOC94-528 - Filtro por Cliente (trazer apenas o Status mais recente de cada bem)
/*			If !lMvLocBac
				//CQUERY += "	COALESCE((SELECT COUNT(ST91.T9_CODFAMI) QTDFAMI FROM "+RETSQLNAME("ST9")+" ST91 WHERE ST91.D_E_L_E_T_='' AND ST91.T9_STATUS = '"+ITST9STAT("00")+"' AND ST91.T9_CENTRAB = ST9.T9_CENTRAB AND ST91.T9_CODFAMI = ST9.T9_CODFAMI AND ST91.T9_SITBEM	=	'A'	 "   
				CQUERY += "	COALESCE((SELECT COUNT(ST91.T9_CODFAMI) QTDFAMI FROM "+RETSQLNAME("ST9")+" ST91 WHERE ST91.D_E_L_E_T_='' AND ST91.T9_STATUS = ? AND ST91.T9_CENTRAB = ST9.T9_CENTRAB AND ST91.T9_CODFAMI = ST9.T9_CODFAMI AND ST91.T9_SITBEM	=	'A'	 "   
			Else
				//CQUERY += "	COALESCE((SELECT COUNT(ST91.T9_CODFAMI) QTDFAMI FROM "+RETSQLNAME("ST9")+" ST91 WHERE ST91.D_E_L_E_T_='' AND ST91.T9_STATUS = '"+ITST9STAT("00")+"' AND ST91.T9_CENTRAB = ST9.T9_CENTRAB AND ST91.T9_CODFAMI = ST9.T9_CODFAMI AND ST91.T9_SITBEM	=	'A'	 "   
				CQUERY += "	COALESCE((SELECT COUNT(ST91.T9_CODFAMI) QTDFAMI FROM "+RETSQLNAME("ST9")+" ST91 WHERE ST91.D_E_L_E_T_='' AND ST91.T9_STATUS = ? AND ST91.T9_CENTRAB = ST9.T9_CENTRAB AND ST91.T9_CODFAMI = ST9.T9_CODFAMI AND ST91.T9_SITBEM	=	'A'	 "   
			endif
			CQUERY += " GROUP BY ST91.T9_CODFAMI),0)  DISP, "   
			If !lMvLocBac
				//CQUERY += "	COALESCE((SELECT COUNT(ST91.T9_CODFAMI) QTDFAMI FROM "+RETSQLNAME("ST9")+" ST91 WHERE ST91.D_E_L_E_T_='' AND ST91.T9_STATUS = '"+ITST9STAT("10")+"' AND ST91.T9_CENTRAB = ST9.T9_CENTRAB AND ST91.T9_CODFAMI = ST9.T9_CODFAMI AND ST91.T9_SITBEM	=	'A'	 "   
				CQUERY += "	COALESCE((SELECT COUNT(ST91.T9_CODFAMI) QTDFAMI FROM "+RETSQLNAME("ST9")+" ST91 WHERE ST91.D_E_L_E_T_='' AND ST91.T9_STATUS = ? AND ST91.T9_CENTRAB = ST9.T9_CENTRAB AND ST91.T9_CODFAMI = ST9.T9_CODFAMI AND ST91.T9_SITBEM	=	'A'	 "   
			else
				//CQUERY += "	COALESCE((SELECT COUNT(ST91.T9_CODFAMI) QTDFAMI FROM "+RETSQLNAME("ST9")+" ST91 WHERE ST91.D_E_L_E_T_='' AND ST91.T9_STATUS = '"+ITST9STAT("10")+"' AND ST91.T9_CENTRAB = ST9.T9_CENTRAB AND ST91.T9_CODFAMI = ST9.T9_CODFAMI AND ST91.T9_SITBEM	=	'A'	 "   
				CQUERY += "	COALESCE((SELECT COUNT(ST91.T9_CODFAMI) QTDFAMI FROM "+RETSQLNAME("ST9")+" ST91 WHERE ST91.D_E_L_E_T_='' AND ST91.T9_STATUS = ? AND ST91.T9_CENTRAB = ST9.T9_CENTRAB AND ST91.T9_CODFAMI = ST9.T9_CODFAMI AND ST91.T9_SITBEM	=	'A'	 "   
			endif
			CQUERY += " GROUP BY ST91.T9_CODFAMI),0)  CON, "  
			If !lMvLocBac
				//CQUERY += "	COALESCE((SELECT COUNT(ST91.T9_CODFAMI) QTDFAMI FROM "+RETSQLNAME("ST9")+" ST91 WHERE ST91.D_E_L_E_T_='' AND ST91.T9_STATUS = '"+ITST9STAT("20")+"' AND ST91.T9_CENTRAB = ST9.T9_CENTRAB AND ST91.T9_CODFAMI = ST9.T9_CODFAMI AND ST91.T9_SITBEM	=	'A'	 "   
				CQUERY += "	COALESCE((SELECT COUNT(ST91.T9_CODFAMI) QTDFAMI FROM "+RETSQLNAME("ST9")+" ST91 WHERE ST91.D_E_L_E_T_='' AND ST91.T9_STATUS = ? AND ST91.T9_CENTRAB = ST9.T9_CENTRAB AND ST91.T9_CODFAMI = ST9.T9_CODFAMI AND ST91.T9_SITBEM	=	'A'	 "   
			else
				//CQUERY += "	COALESCE((SELECT COUNT(ST91.T9_CODFAMI) QTDFAMI FROM "+RETSQLNAME("ST9")+" ST91 WHERE ST91.D_E_L_E_T_='' AND ST91.T9_STATUS = '"+ITST9STAT("20")+"' AND ST91.T9_CENTRAB = ST9.T9_CENTRAB AND ST91.T9_CODFAMI = ST9.T9_CODFAMI AND ST91.T9_SITBEM	=	'A'	 "   
				CQUERY += "	COALESCE((SELECT COUNT(ST91.T9_CODFAMI) QTDFAMI FROM "+RETSQLNAME("ST9")+" ST91 WHERE ST91.D_E_L_E_T_='' AND ST91.T9_STATUS = ? AND ST91.T9_CENTRAB = ST9.T9_CENTRAB AND ST91.T9_CODFAMI = ST9.T9_CODFAMI AND ST91.T9_SITBEM	=	'A'	 "   
			endif
			CQUERY += " GROUP BY ST91.T9_CODFAMI),0)  NFRE,"  
			If !lMvLocBac
				//CQUERY += "	COALESCE((SELECT COUNT(ST91.T9_CODFAMI) QTDFAMI FROM "+RETSQLNAME("ST9")+" ST91 WHERE ST91.D_E_L_E_T_='' AND ST91.T9_STATUS = '"+ITST9STAT("30")+"' AND ST91.T9_CENTRAB = ST9.T9_CENTRAB AND ST91.T9_CODFAMI = ST9.T9_CODFAMI AND ST91.T9_SITBEM	=	'A'	 "   
				CQUERY += "	COALESCE((SELECT COUNT(ST91.T9_CODFAMI) QTDFAMI FROM "+RETSQLNAME("ST9")+" ST91 WHERE ST91.D_E_L_E_T_='' AND ST91.T9_STATUS = ? AND ST91.T9_CENTRAB = ST9.T9_CENTRAB AND ST91.T9_CODFAMI = ST9.T9_CODFAMI AND ST91.T9_SITBEM	=	'A'	 "   
			else
				//CQUERY += "	COALESCE((SELECT COUNT(ST91.T9_CODFAMI) QTDFAMI FROM "+RETSQLNAME("ST9")+" ST91 WHERE ST91.D_E_L_E_T_='' AND ST91.T9_STATUS = '"+ITST9STAT("30")+"' AND ST91.T9_CENTRAB = ST9.T9_CENTRAB AND ST91.T9_CODFAMI = ST9.T9_CODFAMI AND ST91.T9_SITBEM	=	'A'	 "   				
				CQUERY += "	COALESCE((SELECT COUNT(ST91.T9_CODFAMI) QTDFAMI FROM "+RETSQLNAME("ST9")+" ST91 WHERE ST91.D_E_L_E_T_='' AND ST91.T9_STATUS = ? AND ST91.T9_CENTRAB = ST9.T9_CENTRAB AND ST91.T9_CODFAMI = ST9.T9_CODFAMI AND ST91.T9_SITBEM	=	'A'	 "   				
			endif
			CQUERY += " GROUP BY ST91.T9_CODFAMI),0)  TRE, "  
			If !lMvLocBac
				//CQUERY += "	COALESCE((SELECT COUNT(ST91.T9_CODFAMI) QTDFAMI FROM "+RETSQLNAME("ST9")+" ST91 WHERE ST91.D_E_L_E_T_='' AND ST91.T9_STATUS = '"+ITST9STAT("40")+"' AND ST91.T9_CENTRAB = ST9.T9_CENTRAB AND ST91.T9_CODFAMI = ST9.T9_CODFAMI AND ST91.T9_SITBEM	=	'A'	 "   
				CQUERY += "	COALESCE((SELECT COUNT(ST91.T9_CODFAMI) QTDFAMI FROM "+RETSQLNAME("ST9")+" ST91 WHERE ST91.D_E_L_E_T_='' AND ST91.T9_STATUS = ? AND ST91.T9_CENTRAB = ST9.T9_CENTRAB AND ST91.T9_CODFAMI = ST9.T9_CODFAMI AND ST91.T9_SITBEM	=	'A'	 "   
			else
				//CQUERY += "	COALESCE((SELECT COUNT(ST91.T9_CODFAMI) QTDFAMI FROM "+RETSQLNAME("ST9")+" ST91 WHERE ST91.D_E_L_E_T_='' AND ST91.T9_STATUS = '"+ITST9STAT("40")+"' AND ST91.T9_CENTRAB = ST9.T9_CENTRAB AND ST91.T9_CODFAMI = ST9.T9_CODFAMI AND ST91.T9_SITBEM	=	'A'	 "   				
				CQUERY += "	COALESCE((SELECT COUNT(ST91.T9_CODFAMI) QTDFAMI FROM "+RETSQLNAME("ST9")+" ST91 WHERE ST91.D_E_L_E_T_='' AND ST91.T9_STATUS = ? AND ST91.T9_CENTRAB = ST9.T9_CENTRAB AND ST91.T9_CODFAMI = ST9.T9_CODFAMI AND ST91.T9_SITBEM	=	'A'	 "   				
			endif
			CQUERY += " GROUP BY ST91.T9_CODFAMI),0)  ENT, "  
			If !lMvLocBac
				//CQUERY += " COALESCE((SELECT COUNT(ST91.T9_CODFAMI) QTDFAMI FROM "+RETSQLNAME("ST9")+" ST91 WHERE ST91.D_E_L_E_T_='' AND ST91.T9_STATUS = '"+ITST9STAT("50")+"' AND ST91.T9_CENTRAB = ST9.T9_CENTRAB AND ST91.T9_CODFAMI = ST9.T9_CODFAMI AND ST91.T9_SITBEM	=	'A'	 "   
				CQUERY += " COALESCE((SELECT COUNT(ST91.T9_CODFAMI) QTDFAMI FROM "+RETSQLNAME("ST9")+" ST91 WHERE ST91.D_E_L_E_T_='' AND ST91.T9_STATUS = ? AND ST91.T9_CENTRAB = ST9.T9_CENTRAB AND ST91.T9_CODFAMI = ST9.T9_CODFAMI AND ST91.T9_SITBEM	=	'A'	 "   
			else
				//CQUERY += "	COALESCE((SELECT COUNT(ST91.T9_CODFAMI) QTDFAMI FROM "+RETSQLNAME("ST9")+" ST91 WHERE ST91.D_E_L_E_T_='' AND ST91.T9_STATUS = '"+ITST9STAT("50")+"' AND ST91.T9_CENTRAB = ST9.T9_CENTRAB AND ST91.T9_CODFAMI = ST9.T9_CODFAMI AND ST91.T9_SITBEM	=	'A'	 "   				
				CQUERY += "	COALESCE((SELECT COUNT(ST91.T9_CODFAMI) QTDFAMI FROM "+RETSQLNAME("ST9")+" ST91 WHERE ST91.D_E_L_E_T_='' AND ST91.T9_STATUS = ? AND ST91.T9_CENTRAB = ST9.T9_CENTRAB AND ST91.T9_CODFAMI = ST9.T9_CODFAMI AND ST91.T9_SITBEM	=	'A'	 "   				
			endif
			CQUERY += " GROUP BY ST91.T9_CODFAMI),0)  SRT, "  
			If !lMvLocBac
				//CQUERY += "	COALESCE((SELECT COUNT(ST91.T9_CODFAMI) QTDFAMI FROM "+RETSQLNAME("ST9")+" ST91 WHERE ST91.D_E_L_E_T_='' AND ST91.T9_STATUS = '"+ITST9STAT("60")+"' AND ST91.T9_CENTRAB = ST9.T9_CENTRAB AND ST91.T9_CODFAMI = ST9.T9_CODFAMI AND ST91.T9_SITBEM	=	'A'	 "   
				CQUERY += "	COALESCE((SELECT COUNT(ST91.T9_CODFAMI) QTDFAMI FROM "+RETSQLNAME("ST9")+" ST91 WHERE ST91.D_E_L_E_T_='' AND ST91.T9_STATUS = ? AND ST91.T9_CENTRAB = ST9.T9_CENTRAB AND ST91.T9_CODFAMI = ST9.T9_CODFAMI AND ST91.T9_SITBEM	=	'A'	 "   
			else
				//CQUERY += "	COALESCE((SELECT COUNT(ST91.T9_CODFAMI) QTDFAMI FROM "+RETSQLNAME("ST9")+" ST91 WHERE ST91.D_E_L_E_T_='' AND ST91.T9_STATUS = '"+ITST9STAT("60")+"' AND ST91.T9_CENTRAB = ST9.T9_CENTRAB AND ST91.T9_CODFAMI = ST9.T9_CODFAMI AND ST91.T9_SITBEM	=	'A'	 "   				
				CQUERY += "	COALESCE((SELECT COUNT(ST91.T9_CODFAMI) QTDFAMI FROM "+RETSQLNAME("ST9")+" ST91 WHERE ST91.D_E_L_E_T_='' AND ST91.T9_STATUS = ? AND ST91.T9_CENTRAB = ST9.T9_CENTRAB AND ST91.T9_CODFAMI = ST9.T9_CODFAMI AND ST91.T9_SITBEM	=	'A'	 "   				
			endif
			CQUERY += " GROUP BY ST91.T9_CODFAMI),0)  NFRR,"  
			If !lMvLocBac
				//CQUERY += "	COALESCE((SELECT COUNT(ST91.T9_CODFAMI) QTDFAMI FROM "+RETSQLNAME("ST9")+" ST91 WHERE ST91.D_E_L_E_T_='' AND ST91.T9_STATUS = '"+ITST9STAT("70")+"' AND ST91.T9_CENTRAB = ST9.T9_CENTRAB AND ST91.T9_CODFAMI = ST9.T9_CODFAMI AND ST91.T9_SITBEM	=	'A'	 "   
				CQUERY += "	COALESCE((SELECT COUNT(ST91.T9_CODFAMI) QTDFAMI FROM "+RETSQLNAME("ST9")+" ST91 WHERE ST91.D_E_L_E_T_='' AND ST91.T9_STATUS = ? AND ST91.T9_CENTRAB = ST9.T9_CENTRAB AND ST91.T9_CODFAMI = ST9.T9_CODFAMI AND ST91.T9_SITBEM	=	'A'	 "   
			else
				//CQUERY += "	COALESCE((SELECT COUNT(ST91.T9_CODFAMI) QTDFAMI FROM "+RETSQLNAME("ST9")+" ST91 WHERE ST91.D_E_L_E_T_='' AND ST91.T9_STATUS = '"+ITST9STAT("70")+"' AND ST91.T9_CENTRAB = ST9.T9_CENTRAB AND ST91.T9_CODFAMI = ST9.T9_CODFAMI AND ST91.T9_SITBEM	=	'A'	 "   				
				CQUERY += "	COALESCE((SELECT COUNT(ST91.T9_CODFAMI) QTDFAMI FROM "+RETSQLNAME("ST9")+" ST91 WHERE ST91.D_E_L_E_T_='' AND ST91.T9_STATUS = ? AND ST91.T9_CENTRAB = ST9.T9_CENTRAB AND ST91.T9_CODFAMI = ST9.T9_CODFAMI AND ST91.T9_SITBEM	=	'A'	 "   				
			endif
			CQUERY += " GROUP BY ST91.T9_CODFAMI),0)  MNT,	"  
			If !lMvLocBac
				//CQUERY += "	COALESCE((SELECT COUNT(ST91.T9_CODFAMI) QTDFAMI FROM "+RETSQLNAME("ST9")+" ST91 WHERE ST91.D_E_L_E_T_='' AND ST91.T9_STATUS = '"+ITST9STAT("80")+"' AND ST91.T9_CENTRAB = ST9.T9_CENTRAB AND ST91.T9_CODFAMI = ST9.T9_CODFAMI AND ST91.T9_SITBEM	=	'A'	 "   
				CQUERY += "	COALESCE((SELECT COUNT(ST91.T9_CODFAMI) QTDFAMI FROM "+RETSQLNAME("ST9")+" ST91 WHERE ST91.D_E_L_E_T_='' AND ST91.T9_STATUS = ? AND ST91.T9_CENTRAB = ST9.T9_CENTRAB AND ST91.T9_CODFAMI = ST9.T9_CODFAMI AND ST91.T9_SITBEM	=	'A'	 "   
			else
				//CQUERY += "	COALESCE((SELECT COUNT(ST91.T9_CODFAMI) QTDFAMI FROM "+RETSQLNAME("ST9")+" ST91 WHERE ST91.D_E_L_E_T_='' AND ST91.T9_STATUS = '"+ITST9STAT("80")+"' AND ST91.T9_CENTRAB = ST9.T9_CENTRAB AND ST91.T9_CODFAMI = ST9.T9_CODFAMI AND ST91.T9_SITBEM	=	'A'	 "   				
				CQUERY += "	COALESCE((SELECT COUNT(ST91.T9_CODFAMI) QTDFAMI FROM "+RETSQLNAME("ST9")+" ST91 WHERE ST91.D_E_L_E_T_='' AND ST91.T9_STATUS = ? AND ST91.T9_CENTRAB = ST9.T9_CENTRAB AND ST91.T9_CODFAMI = ST9.T9_CODFAMI AND ST91.T9_SITBEM	=	'A'	 "   				
			endif
			CQUERY += " GROUP BY ST91.T9_CODFAMI),0)  PAR, "  
			
			//CQUERY += "	COALESCE((SELECT COUNT(ST91.T9_CODFAMI) QTDFAMI FROM "+RETSQLNAME("ST9")+" ST91 WHERE ST91.D_E_L_E_T_='' AND ST91.T9_STATUS NOT IN ('"+ITST9STAT("00")+"','"+ITST9STAT("10")+"','"+ITST9STAT("20")+"','"+ITST9STAT("30")+"','"+ITST9STAT("40")+"','"+ITST9STAT("50")+"','"+ITST9STAT("60")+"','"+ITST9STAT("70")+"','"+ITST9STAT("80")+"') AND ST91.T9_CENTRAB = ST9.T9_CENTRAB AND ST91.T9_CODFAMI = ST9.T9_CODFAMI AND ST91.T9_SITBEM	=	'A' "   
			CQUERY += "	COALESCE((SELECT COUNT(ST91.T9_CODFAMI) QTDFAMI FROM "+RETSQLNAME("ST9")+" ST91 WHERE ST91.D_E_L_E_T_='' AND ST91.T9_STATUS NOT IN (?,?,?,?,?,?,?,?,?) AND ST91.T9_CENTRAB = ST9.T9_CENTRAB AND ST91.T9_CODFAMI = ST9.T9_CODFAMI AND ST91.T9_SITBEM	=	'A' "   
			CQUERY += " GROUP BY ST91.T9_CODFAMI),0)  OTR "  
*/
			CQUERY += " FROM	"+RETSQLNAME("ST9")+"	ST9		"  
			cQuery += " LEFT JOIN "+RETSQLNAME("FQ4")+" ZZZ ON ZZZ.FQ4_CODBEM = ST9.T9_CODBEM AND ZZZ.D_E_L_E_T_='' AND ZZZ.R_E_C_N_O_ = (SELECT MAX(ZZZ1.R_E_C_N_O_) FROM "+RETSQLNAME("FQ4")+" ZZZ1 WHERE ZZZ1.FQ4_CODBEM = ST9.T9_CODBEM AND ZZZ1.D_E_L_E_T_ = '')

			CQUERY += " LEFT JOIN "+RETSQLNAME("SHB")+" SHB     "  
			CQUERY += " ON		SHB.HB_COD = ST9.T9_CENTRAB    	"  
			CQUERY += " AND 	SHB.D_E_L_E_T_=''      	"  

			CQUERY += " LEFT JOIN	"+RETSQLNAME("ST6")+" ST6 "  
			CQUERY += " 			ON	ST9.T9_CODFAMI	=	ST6.T6_CODFAMI "  
			CQUERY += " 			AND ST9.D_E_L_E_T_	=	'' "  
			
			//CQUERY += " LEFT JOIN "+RETSQLNAME("SA1")+" SA1     "  
			//CQUERY += " ON		SA1.A1_COD = ZZZ.FQ4_CODCLI    	"  
			//CQUERY += " AND SA1.A1_LOJA = ZZZ.FQ4_LOJCLI      	"  
			//CQUERY += " AND SA1.D_E_L_E_T_ = ''           		"  

			CQUERY += " WHERE                   "  
			CQUERY += "  ST9.T9_CENTRAB BETWEEN ? AND ? "  
			// 11/10/2022 - Jose Eulalio - SIGALOC94-528 - Filtro por Cliente (trazer apenas o Status mais recente de cada bem)
			CQUERY += " AND ST9.T9_CODBEM  BETWEEN ? AND ? "  
			CQUERY += " AND ST9.T9_CODFAMI BETWEEN ? AND ? "  
			CQUERY += " AND ST9.T9_TIPMOD  BETWEEN ? AND ? "  
			CQUERY += " AND ST9.T9_STATUS  BETWEEN ? AND ? "  
			CQUERY += " AND ST9.T9_SITBEM	=	'A'				"  
			cQuery += " AND ST9.D_E_L_E_T_ = '' "
			cQuery += " AND ST9.T9_STATUS <> '' "

			CQUERY += "  ORDER BY			"  
			CQUERY += "  				ST9.T9_CODFAMI,	"  
			CQUERY += "  				ST9.T9_TIPMOD	"

			IF SELECT("ZZZTRB") > 0
				ZZZTRB->(DBCLOSEAREA())
			ENDIF

			//MEMOWRITE(GETTEMPPATH()+"LOCR009_ANALITICO.SQL",CQUERY)
			CQUERY := CHANGEQUERY(CQUERY) 
/*			aBindParam := {	ITST9STAT("00"),;
							ITST9STAT("10"),;
							ITST9STAT("20"),;
							ITST9STAT("30"),;
							ITST9STAT("40"),;
							ITST9STAT("50"),;
							ITST9STAT("60"),;
							ITST9STAT("70"),;
							ITST9STAT("80"),;
							ITST9STAT("00"),;
							ITST9STAT("10"),;
							ITST9STAT("20"),;
							ITST9STAT("30"),;
							ITST9STAT("40"),;
							ITST9STAT("50"),;
							ITST9STAT("60"),;
							ITST9STAT("70"),;
							ITST9STAT("80"),;
							MV_PAR01,;
							MV_PAR02,;
							MV_PAR03,;
							MV_PAR04,;
							MV_PAR05,;
							MV_PAR06,;
							MV_PAR07,;
							MV_PAR08,;
							MV_PAR09,;
							MV_PAR10}*/

			aBindParam := {	MV_PAR01,;
							MV_PAR02,;
							MV_PAR03,;
							MV_PAR04,;
							MV_PAR05,;
							MV_PAR06,;
							MV_PAR07,;
							MV_PAR08,;
							MV_PAR09,;
							MV_PAR10}
			MPSysOpenQuery(cQuery,"ZZZTRB",,,aBindParam)

			//TCQUERY CQUERY NEW ALIAS "ZZZTRB"
		EndIF
		ZZZTRB->(DBGOTOP())
		

		IIF( ZZZTRB->(EOF()) , LRET := .F. , LRET := .T. )

	ENDIF

RETURN LRET

//------------------------------------------------------------------------------
/*/{Protheus.doc} ListaBens

Retorna lista de bens para filtro da query
@type  Static Function
@author Jose Eulalio
@since 16/10/2022

/*/
//------------------------------------------------------------------------------
Static Function ListaBens()
Local cListaBens:= "''"
Local cQuery	:= ""
Local cAliasQry	:= GetNextAlias()

	/*
	cQuery += " SELECT DISTINCT FPA_GRUA  "  
	cQuery += " FROM " + RetSqlName("FP0") + " FP0 "  
	cQuery += " INNER JOIN " + RetSqlName("FPA") + " FPA ON "  
	cQuery += " FPA_FILIAL = FP0_FILIAL "  
	cQuery += " AND FPA_PROJET = FP0_PROJET "  
	cQuery += " AND FPA_GRUA <> '' "  
	cQuery += " AND FPA.D_E_L_E_T_ = ' ' "  
	cQuery += " WHERE FP0_FILIAL = '" + xFilial("FP0") + "' "  
	cQuery += " AND FP0.D_E_L_E_T_ = ' ' "  
	cQuery += " AND FP0_CLI = '" + MV_PAR12 + "' "  
	*/

	/*
	+ xFilial("FQ4") +
	+ xFilial("FP0") +
	+ MV_PAR12 +
	If !Empty(MV_PAR13)
		+ MV_PAR13 +
	EndIf	
	*/

	cQuery += " SELECT DISTINCT FPA_GRUA  "  
	cQuery += " FROM " + RetSqlName("FP0") + " FP0 "  
	cQuery += " INNER JOIN " + RetSqlName("FPA") + " FPA ON "  
	cQuery += " 	FPA_FILIAL = FP0_FILIAL "  
	cQuery += " 	AND FPA_PROJET = FP0_PROJET "  
	cQuery += " 	AND FPA_GRUA <> '' "  
	cQuery += " 	AND FPA.D_E_L_E_T_ = ' ' "  
	cQuery += " INNER JOIN " + RetSqlName("FQ4") + " FQ4 ON "  
	cQuery += " 	FQ4_FILIAL = ? "  
	cQuery += " 	AND FQ4_PROJET = FP0_PROJET "  
	cQuery += " 	AND FPA_GRUA = FQ4_CODBEM "  
	cQuery += " 	AND FQ4.D_E_L_E_T_ = ' ' "  
	cQuery += " WHERE FP0_FILIAL = ? "  
	cQuery += " 	AND FP0.D_E_L_E_T_ = ' ' "  
	cQuery += " 	AND FP0_CLI = ? "  

	If !Empty(MV_PAR13)
		cQuery += " AND FP0_LOJA = ? "  
	EndIf	

	cQuery := ChangeQuery(cQuery) 
	If !Empty(MV_PAR13)
		aBindParam := {xFilial("FQ4"), xFilial("FP0"), MV_PAR12, MV_PAR13 }
	else
		aBindParam := {xFilial("FQ4"), xFilial("FP0"), MV_PAR12 }
	EndIF
	cAliasQry := MPSysOpenQuery(cQuery,,,,aBindParam)

	//DbUseArea(.T. , "TOPCONN" , TcGenQry(,,cQuery) , cAliasQry , .F. , .T.) 

	If !((cAliasQry)->(EoF()))
		cListaBens := ""
		While !((cAliasQry)->(EoF()))
			If !(Empty(cListaBens))
				cListaBens += ","
			EndIf
			cListaBens += "'" + (cAliasQry)->FPA_GRUA + "'"
			(cAliasQry)->(DbSkip())
		EndDo
	EndIf

	(cAliasQry)->(DbCloseArea())

Return cListaBens


// Frank Fuga
// 25/10/23 - Rotina de/para para status da ST8
Static Function ITST9STAT(cDe)
Local cAte := "--"
Local nX

	For nX := 1 to len(aStatus)
		If aStatus[nX,1] == cDe
			cAte := aStatus[nX,2]
			exit
		EndIF
	Next

Return cAte


// Localizar os dados do relatório sintético
// Frank em 07/11/23
Static Function LOCR009B(nOpc,cCliente, cLoja)
Local nResult := 0
Local aAreaST9 := ST9->(GetArea())
Local cCentrab := ST9->T9_CENTRAB
Local cTempCli := ""
Local cTempLoj := ""

Default cCliente := ""
Default cLoja := ""

	ST9->(dbSetOrder(1))
	ST9->(dbSeek(xFilial("ST9")))
	While !ST9->(Eof()) .and. ST9->T9_FILIAL == xFilial("ST9")
		
		If !empty(cCliente)
			FQ4->(dbSetOrder(1))
			FQ4->(dbSeek(xFilial("FQ4")+ST9->T9_CODBEM))
			While !FQ4->(Eof()) .and. FQ4->FQ4_CODBEM == ST9->T9_CODBEM
				cTempCli := FQ4->FQ4_CODCLI
				cTempLoj := FQ4->FQ4_LOJCLI
				FQ4->(dbSkip())	
			EndDo
			If cCliente <> cTempCli .or. cLoja <> cTempLoj
				ST9->(dbSkip())
				Loop
			EndIF
		EndIf

		If alltrim(ST9->T9_CENTRAB) <> alltrim(cCentrab)
			//ST9->(dbSkip())
			//Loop
		EndIF

		If ST9->T9_CODBEM < MV_PAR03 .or. ST9->T9_CODBEM > MV_PAR04
			ST9->(dbSkip())
			Loop
		EndIF

		If ST9->T9_CODFAMI < MV_PAR05 .or. ST9->T9_CODFAMI > MV_PAR06
			ST9->(dbSkip())
			Loop
		EndIF

		If ST9->T9_TIPMOD < MV_PAR07 .or. ST9->T9_TIPMOD > MV_PAR08
			ST9->(dbSkip())
			Loop
		EndIF

		If ST9->T9_STATUS < MV_PAR09 .or. ST9->T9_STATUS > MV_PAR10
			ST9->(dbSkip())
			Loop
		EndIF

		If ST9->T9_SITBEM <> 'A' .or. ST9->T9_STATUS == ""
			ST9->(dbSkip())
			Loop
		EndIF

		If nOpc == 1 // quantidade de bens
			nResult ++
		EndIF
		If nOpc == 2 // quantidade de bens disponiveis
			If ST9->T9_STATUS = ITST9STAT("00")
				nResult ++
			EndIF
		EndIF
		If nOpc == 3 // em contrato
			If ST9->T9_STATUS = ITST9STAT("10")
				nResult ++
			EndIF
		EndIF
		If nOpc == 4 // nota fiscal de remessa
			If ST9->T9_STATUS = ITST9STAT("20")
				nResult ++
			EndIF
		EndIF
		If nOpc == 5 // solicitação de retirada
			If ST9->T9_STATUS = ITST9STAT("50")
				nResult ++
			EndIF
		EndIF
		If nOpc == 6 // com nota fiscal de retorno
			If ST9->T9_STATUS = ITST9STAT("60")
				nResult ++
			EndIF
		EndIF
		If nOpc == 7 // outros
			If ST9->T9_STATUS <> ITST9STAT("00") .AND. ST9->T9_STATUS <> ITST9STAT("10") .AND. ST9->T9_STATUS <> ITST9STAT("20") .AND. ST9->T9_STATUS <> ITST9STAT("30") .AND. ST9->T9_STATUS <> ITST9STAT("40") .AND. ST9->T9_STATUS <> ITST9STAT("50") .AND. ST9->T9_STATUS <> ITST9STAT("60") .AND. ST9->T9_STATUS <> ITST9STAT("70") .AND. ST9->T9_STATUS <> ITST9STAT("80")
				nResult ++
			EndIF
		EndIF
		ST9->(dbSkip())
	EndDo
	ST9->(RestArea(aAreaST9))
Return nResult
