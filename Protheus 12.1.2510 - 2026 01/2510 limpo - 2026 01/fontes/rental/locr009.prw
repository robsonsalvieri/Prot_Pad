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

Private OREPORT
Private CTITULO := STR0001 //"QUADRO RESUMO"
Private OBREAK
Private	NTGOCU :=	0
Private	NTGDISP :=	0
Private NTOCU :=	0
Private NTDISP :=	0
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
			OREPORT:PRINTDIALOG()
		ENDIF
	ENDIF       

RETURN         

/*/{Protheus.doc} REPORTDEF
Definição do layout do relatório
@type function
@version  
@author Frank Zwarg Fuga
@since 31/10/2025
/*/
STATIC FUNCTION REPORTDEF()
Local OSECTION
Local OSECTION1
Local OSECTION2

Private CFILBRK := CFILANT

	OREPORT  := TREPORT():NEW("LOCR009",CTITULO,"LOCR009",{|OREPORT| PRINTREPORT()},CTITULO)

	OREPORT:TOTALINLINE(.F.)	// IMPRIME TOTAL EM LINHA OU COLUNA (DEFAULT .T. - LINHA )
	OREPORT:LPARAMPAGE := .F.
	OREPORT:LPRTPARAMPAGE := .F.
	OREPORT:UPARAM := {|| PERGPARAM("LOCR009") }

	IF MV_PAR11 == 1

		/* Frank 31/10/25
		OSECTION := TRSECTION():NEW(OREPORT,STR0019,{"ST9"}) //,"PROJETOS",{"ST9","SHB"}) //"Centro Trab."
		TRCELL():NEW(OSECTION,"CENTRAB"	,"ST9","", , 60		)
		*/
		OSECTION := TRSECTION():NEW(OREPORT,STR0011,{"ST9"}) // "Família"
		TRCELL():NEW(OSECTION,"T9_CODFAMI"	,"ST9","", , 60		)

		OSECTION1 := TRSECTION():NEW(OSECTION,STR0011,{"ST9"}) // ,"PROJETOS",{"ST9","SHB"})
		TRCELL():NEW(OSECTION1,"T9_CODFAMI"	,"ST9",RETTITLE("T9_CODFAMI"), , 30	)
		//TRCELL():NEW(OSECTION1,"T6_NOME"	,"ST9",RETTITLE("T6_NOME"), , 30	)
		TRCELL():NEW(OSECTION1,"QTDBEM"		,"ST9",STR0002		, , 10		) //"QTD. BEM"
		TRCELL():NEW(OSECTION1,"DISP"		,"ST9",STR0003		, , 15		) //"DISPONIVEL"
		TRCELL():NEW(OSECTION1,"CON"		,"ST9",STR0004	, , 15		) //"EM CONTRATO"
		TRCELL():NEW(OSECTION1,"NFRE"		,"ST9",STR0005			, , 15		) //"LOCADO"
		TRCELL():NEW(OSECTION1,"SRT"		,"ST9",STR0006 , , 20		) //"SOLIC.RETIRADA"
		TRCELL():NEW(OSECTION1,"OTR"		,"ST9",STR0007			, , 15		) //"OUTROS"
		TRCELL():NEW(OSECTION1,"OCUP"		,"ST9",STR0008		, , 15		) //"OCUPACAO %"
		OBREAK := TRBREAK():NEW(OSECTION1,OSECTION:CELL("T9_CODFAMI"),STR0009) //"SUB TOTAIS"

		TREPORT():TOTALINLINE(.T.)		// IMPRIME TOTAL EM LINHA OU COLUNA (DEFAULT .T. - LINHA )   
		TRFUNCTION():NEW(OSECTION1:CELL("QTDBEM") ,NIL,"SUM",OBREAK,,,,.F.,.T.) 	
		TRFUNCTION():NEW(OSECTION1:CELL("DISP") ,NIL,"SUM",OBREAK,,,,.F.,.T.) 	
		TRFUNCTION():NEW(OSECTION1:CELL("CON") ,NIL,"SUM",OBREAK,,,,.F.,.T.) 
		TRFUNCTION():NEW(OSECTION1:CELL("NFRE") ,NIL,"SUM",OBREAK,,,,.F.,.T.) 
		TRFUNCTION():NEW(OSECTION1:CELL("SRT") ,NIL,"SUM",OBREAK,,,,.F.,.T.) 
		TRFUNCTION():NEW(OSECTION1:CELL("OTR") ,NIL,"SUM",OBREAK,,,,.F.,.T.) 		
		TRFUNCTION():NEW(OSECTION1:CELL("OCUP"),NIL,"ONPRINT",OBREAK,,,{|| ROUND((NTGOCU/NTGDISP)*100,2) },.F.,.T.) 		

	ELSEIF MV_PAR11 == 2

		OSECTION := TRSECTION():NEW(OREPORT ,STR0011,{"ST9","FQ4"}) //"PROJETOS"
		TRCELL():NEW(OSECTION,"T9_CODFAMI"	,"FQ4",STR0011 , PESQPICT("ST9","T9_CODFAMI"	) , 60 /*SIZE*/ , /*LPIXEL*/, /*{|| BLOCK } */ ) //"FAMILIA"
		OSECTION1 := TRSECTION():NEW(OSECTION,STR0020,{"ST9"}) // ,"PROJETOS",{"ST9","SHB"}) // "Bem"
		TRCELL():NEW(OSECTION1,"T9_CODBEM"	,"FQ4","" , PESQPICT("ST9","T9_CODBEM"	) , 60 /*SIZE*/ , /*LPIXEL*/, /*{|| BLOCK } */ )

		OSECTION2 := TRSECTION():NEW(OSECTION ,STR0013,{"FQ4"}) //"Historico do Bem"
		TRCELL():NEW(OSECTION2,"TMP1"	    ,"FQ4",RETTITLE("T9_CODBEM"), PESQPICT("ST9","T9_CODBEM"	) , 10 , , {|| ZZZTRB->T9_CODBEM }  )
		TRCELL():NEW(OSECTION2,"T9_STATUS"	,"FQ4",RETTITLE("T9_STATUS") , PESQPICT("TQY","TQY_DESTAT"	) , 10 , /*LPIXEL*/, /*{|| BLOCK } */ )
		TRCELL():NEW(OSECTION2,"T9_CODFAMI"	,"FQ4",RETTITLE("T9_CODFAMI") , PESQPICT("ST9","T9_CODFAMI"	) , 10 , /*LPIXEL*/, /*{|| BLOCK } */ )
		TRCELL():NEW(OSECTION2,"T9_TIPMOD"	,"FQ4",RETTITLE("T9_TIPMOD") , PESQPICT("ST9","T9_TIPMOD"	) , /*SIZE*/ , /*LPIXEL*/, /*{|| BLOCK } */ )
		TRCELL():NEW(OSECTION2,"T9_FABRICA"	,"FQ4",RETTITLE("T9_FABRICA") , PESQPICT("ST9","T9_FABRICA"	) , /*SIZE*/ , /*LPIXEL*/, /*{|| BLOCK } */ )
		TRCELL():NEW(OSECTION2,"HB_COD"	    ,"FQ4",RETTITLE("HB_COD") , PESQPICT("SHB","HB_COD"	) , /*SIZE*/ , /*LPIXEL*/, /*{|| BLOCK } */ )
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

/*/{Protheus.doc} PRINTREPORT
Impressão do relatório
@type function
@version  
@author Frank Zwarg Fuga
@since 31/10/2025
/*/
STATIC FUNCTION PRINTREPORT()
Local CAUX := ""
Local CAUX2	:= ""
Local cFamiAux := ""
Local NINC := 1
Local nSoma	:= 0
Local nDisp	:= 0
Local nCon := 0
Local nNfRe	:= 0
Local nOcup	:= 0
Local nStr := 0
Local nOtr := 0

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

			OREPORT:SETMETER( ST9TRB->( RECCOUNT()) )
			CAUX := ST9TRB->T9_CODFAMI

			//posiciona para respeitar o filtro do TReport - Seção T9_CODFAMI.
			ST9->(DbSetOrder(10)) //T9_FILIAL+T9_CENTRAB

			WHILE ST9TRB->(! EOF())

				IF OREPORT:CANCEL()
					EXIT
				ENDIF

				IF CAUX <> ST9TRB->T9_CODFAMI .OR. NINC == 1
					
					IF NINC > 1 
						OSECTION2:FINISH()
					ENDIF
					OSECTION1:INIT()
					OSECTION1:CELL("T9_CODFAMI"):SETBLOCK( { || ("Família - " + alltrim(ST9TRB->T9_CODFAMI) + " - " + ALLTRIM(POSICIONE("ST6",1,XFILIAL("ST6")+ST9TRB->T9_CODFAMI,"T6_NOME")) + " - " + ALLTRIM( STR( ST9TRB->QTDBEMCTR ) ) + STR0012)  }) //" BENS NA FILIAL."
					OSECTION1:PRINTLINE()
					OSECTION1:FINISH()
					OSECTION2:INIT()
					NTGOCU	:=	0
					NTGDISP	:=	0	
					
				ENDIF
				
				NTGOCU	+=	ST9TRB->NFRE
				NTGDISP	+=	ST9TRB->QTDBEM	
				
				NTOCU	+=	ST9TRB->NFRE
				NTDISP	+=	ST9TRB->QTDBEM	
				
				OSECTION2:CELL("T9_CODFAMI"	):SETBLOCK( { || ST9TRB->T9_CODFAMI	})
				//OSECTION2:CELL("T6_NOME"	):SETBLOCK( { || ST9TRB->T6_NOME	})
				OSECTION2:CELL("QTDBEM"		):SETBLOCK( { || ST9TRB->QTDBEM		})
				OSECTION2:CELL("DISP"		):SETBLOCK( { || ST9TRB->DISP		})
				OSECTION2:CELL("CON" 		):SETBLOCK( { || ST9TRB->CON		})
				OSECTION2:CELL("NFRE"		):SETBLOCK( { || ST9TRB->NFRE		})
				OSECTION2:CELL("OCUP" 		):SETBLOCK( { || TRANSFORM("999%",CVALTOCHAR(ROUND((ST9TRB->NFRE / ST9TRB->QTDBEM)* 100,2)))  + "%"})
				OSECTION2:CELL("SRT" 		):SETBLOCK( { || ST9TRB->SRT		})
				OSECTION2:CELL("OTR" 		):SETBLOCK( { || ST9TRB->OTR		})
				OSECTION2:PRINTLINE()

				CAUX := ST9TRB->T9_CODFAMI
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
						
						OSECTION1:PRINTLINE()
						OSECTION1:FINISH()

					EndIf

					IF CAUX <> ZZZTRB->T9_CODBEM .OR. NINC == 1
						IF NINC > 1
							OSECTION3:FINISH()
						ENDIF
					ENDIF
				ENDIF
				OREPORT:INCMETER(NINC++)  

				nSoma++
				If ZZZTRB->T9_STATUS == ITST9STAT("00") //"00"
					nDisp++
				ElseIf ZZZTRB->T9_STATUS == ITST9STAT("10") // "10"
					nCon++
					nOcup++
				ElseIf ZZZTRB->T9_STATUS == ITST9STAT("20") //"20"
					nNfRe++
					nOcup++
				ElseIf ZZZTRB->T9_STATUS == ITST9STAT("60") //"60"
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

/*/{Protheus.doc} PERGPARAM
Pergunte do relatório
@type function
@version  
@author Frank Zwarg Fuga
@since 31/10/2025
/*/
STATIC FUNCTION PERGPARAM(CPERG)
Local APERGS  := {}
Local ARET    := {}
Local LRET    := .F.
Local ACOMBO  := {STR0015,STR0016} //"1-SINTETICO"###"2-ANALITICO"
Local NX

Local CCENTRABI := IIF(FIELDPOS("T9_CENTRAB"	)>0,	SPACE(		GETSX3CACHE("T9_CENTRAB","X3_TAMANHO")),SPACE(TamSx3("T9_CENTRAB")[1]))
Local CCENTRABF := IIF(FIELDPOS("T9_CENTRAB"	)>0,REPLICATE("Z",	GETSX3CACHE("T9_CENTRAB","X3_TAMANHO")),REPLICATE("Z",TamSx3("T9_CENTRAB")[1] ))
Local CCODBEMI  := IIF(FIELDPOS("T9_CODBEM"		)>0,	SPACE(		GETSX3CACHE("T9_CODBEM"	,"X3_TAMANHO")),SPACE(TamSx3("T9_CODBEM")[1]))
Local CCODBEMF  := IIF(FIELDPOS("T9_CODBEM"		)>0,REPLICATE("Z",	GETSX3CACHE("T9_CODBEM"	,"X3_TAMANHO")),REPLICATE("Z",TamSx3("T9_CODBEM")[1]))
Local CCODFAMI  := IIF(FIELDPOS("T9_CODFAMI"	)>0,	SPACE(		GETSX3CACHE("T9_CODFAMI","X3_TAMANHO")),SPACE(TamSx3("T9_CODFAMI")[1]))
Local CCODFAMF  := IIF(FIELDPOS("T9_CODFAMI"	)>0,REPLICATE("Z",	GETSX3CACHE("T9_CODFAMI","X3_TAMANHO")),REPLICATE("Z",TamSx3("T9_CODFAMI")[1]))
Local CTIPMODI  := IIF(FIELDPOS("T9_TIPMOD"		)>0,	SPACE(		GETSX3CACHE("T9_TIPMOD"	,"X3_TAMANHO")),SPACE(TamSx3("T9_TIPMOD")[1]))
Local CTIPMODF  := IIF(FIELDPOS("T9_TIPMOD"		)>0,REPLICATE("Z",	GETSX3CACHE("T9_TIPMOD"	,"X3_TAMANHO")),REPLICATE("Z",TamSx3("T9_TIPMOD")[1]))
Local CSTATUSI  := IIF(FIELDPOS("T9_STATUS"		)>0,	SPACE(		GETSX3CACHE("T9_STATUS"	,"X3_TAMANHO")),SPACE(TamSx3("T9_STATUS")[1]))
Local CSTATUSF  := IIF(FIELDPOS("T9_STATUS"		)>0,REPLICATE("Z",	GETSX3CACHE("T9_STATUS"	,"X3_TAMANHO")),REPLICATE("Z",TamSx3("T9_STATUS")[1]))
Local cCliFp0  	:= IIF(FIELDPOS("FP0_CLI"		)>0,REPLICATE("Z",	GETSX3CACHE("FP0_CLI"	,"X3_TAMANHO")),REPLICATE(" ",TamSx3("FP0_CLI")[1]))
Local cLOjaFp0  := IIF(FIELDPOS("FP0_LOJA"		)>0,REPLICATE("Z",	GETSX3CACHE("FP0_LOJA"	,"X3_TAMANHO")),REPLICATE(" ",TamSx3("FP0_LOJA")[1]))

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
	AADD( APERGS ,{2,STR0017 , 1 ,ACOMBO, 70 , '.T.' , .T. }) // COMBO //"TIPO RELATORIO: "
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

/*/{Protheus.doc} SELDADOS
Seleção das informações
@type function
@version  
@author Frank Zwarg Fuga
@since 31/10/2025
/*/
STATIC FUNCTION SELDADOS()
Local CQUERY 		:= ""
Local cListaBens	:= ""
Local LRET 			:= .F.
Local lFiltraCli	:= !Empty(MV_PAR12) .And. At("*",MV_PAR12) == 0
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
					If aResultado[nX,2] == ST9->T9_CODFAMI
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

					//                                                  total de itens               ,disponivel                   ,contrato                     ,remessa                               ,transito ,entregue                     ,sol.retira                    ,retirada   , Manutencao,Parceiros,                                  outros, 
					aadd(aResultado,{ST9->T9_CENTRAB,ST9->T9_CODFAMI,"",LOCR009B(1,MV_PAR12,MV_PAR13),LOCR009B(2,MV_PAR12,MV_PAR13),LOCR009B(3,MV_PAR12,MV_PAR13),LOCR009B(4,MV_PAR12,MV_PAR13)         ,0        ,LOCR009B(5,MV_PAR12,MV_PAR13), LOCR009B(6,MV_PAR12,MV_PAR13), 0         , 0         ,LOCR009B(7)     ,0,0,0,0,0,0,0,0,0,0,0,0})
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
				ST9TRB->OTR			:= aResultado[nX,13]  //14
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
				ST9TRB->TOTR		:= aResultado[nX,13] //aResultado[nX,25] // 14
				ST9TRB->(MsUnlock())

			NExt

		else

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
					If aResultado[nX,2] == ST9->T9_CODFAMI
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

					//                                                  quantidade ,disponivel ,contrato   ,remessa    , transito ,entregue, sol.retira , retirada   , Manutencao, Parceiros, outros, 
					aadd(aResultado,{ST9->T9_CENTRAB,ST9->T9_CODFAMI,"",LOCR009B(1),LOCR009B(2),LOCR009B(3),LOCR009B(4),0       , LOCR009B(5), LOCR009B(6), 0         , 0        , LOCR009B(7)     ,0,0,0,0,0,0,0,0,0,0,0,0})
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
				ST9TRB->OTR			:= aResultado[nX,13] //14
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
				ST9TRB->TOTR		:= aResultado[nX,13] //aResultado[nX,25] //14
				ST9TRB->(MsUnlock())

			NExt

		EndIF

		ST9TRB->(DBGOTOP())

		IIF( ST9TRB->(EOF()) , LRET := .F. , LRET := .T. )

	ELSEIF MV_PAR11 == 2

		IF lFiltraCli

			CQUERY += " SELECT	"  
			CQUERY += "	ZZZ.R_E_C_N_O_ RECNOFQ4,		"  
			CQUERY += "	ST9.R_E_C_N_O_ RECNOST9,		"  
			CQUERY += "	ST9.T9_CODBEM,		"  
			CQUERY += "	ST9.T9_CODIMOB,		"  
			CQUERY += " ST9.T9_TIPMOD,		"  
			CQUERY += "	ST9.T9_CODFAMI,		"  
			CQUERY += "	ST9.T9_FABRICA,		"  
			CQUERY += "	ST9.T9_NOME,		"  
			CQUERY += "	ST9.T9_STATUS,		"  
			CQUERY += "	SHB.HB_COD,		"  
			CQUERY += "	SHB.HB_NOME,		"  
			CQUERY += "	SHB.HB_CC,		"  
			CQUERY += "	COALESCE(ZZZ.FQ4_DOCUME,'') FQ4_DOCUME,		"  
			CQUERY += "	COALESCE(ZZZ.FQ4_SERIE,'') FQ4_SERIE,		"  
			CQUERY += "	COALESCE(ZZZ.FQ4_OS,'') FQ4_OS,		"  
			CQUERY += "	COALESCE(ZZZ.FQ4_SERVIC,'') FQ4_SERVIC,		"  
			CQUERY += "	COALESCE(ZZZ.FQ4_PRELIB,'') FQ4_PRELIB,		"  
			CQUERY += "	COALESCE(ZZZ.FQ4_PROJET,'') FQ4_PROJET,		"  
			CQUERY += "	COALESCE(ZZZ.FQ4_OBRA,'') FQ4_OBRA,		"  
			CQUERY += "	COALESCE(ZZZ.FQ4_AS,'') FQ4_AS,		"  
			CQUERY += "	COALESCE(ZZZ.FQ4_CODCLI,'') FQ4_CODCLI,		"  
			CQUERY += "	COALESCE(ZZZ.FQ4_LOJCLI,'') FQ4_LOJCLI,		"  
			CQUERY += "	COALESCE(ZZZ.FQ4_NOMCLI,'') FQ4_NOMCLI,		"  
			CQUERY += "	COALESCE(ZZZ.FQ4_NFREM,'') FQ4_NFREM,		"  
			CQUERY += "	COALESCE(ZZZ.FQ4_SERREM,'') FQ4_SERREM,		"  
			CQUERY += "	COALESCE(ZZZ.FQ4_DTINI,'') FQ4_DTINI,		"  
			CQUERY += "	COALESCE(ZZZ.FQ4_DTFIM,'') FQ4_DTFIM,		"  
			CQUERY += "	COALESCE(ZZZ.FQ4_LOG,'') FQ4_LOG,		"  
			CQUERY += "	COALESCE(ZZZ.FQ4_PREDES,'') FQ4_PREDES		"  
			CQUERY += " FROM "+RETSQLNAME("ST9")+" ST9 "  

			CQUERY += " INNER JOIN "+RETSQLNAME("FQ4")+" ZZZ     "  
			CQUERY += " ON ZZZ.FQ4_CODBEM = ST9.T9_CODBEM		"         
			CQUERY += "	AND ZZZ.D_E_L_E_T_=' ' "  
			CQUERY += "	AND ZZZ.R_E_C_N_O_ = (SELECT MAX(ZZZ1.R_E_C_N_O_) FROM "+RETSQLNAME("FQ4")+" ZZZ1 WHERE ZZZ1.FQ4_CODBEM = ST9.T9_CODBEM AND ZZZ1.D_E_L_E_T_ = ' ' AND ZZZ1.FQ4_CODCLI = ? AND ZZZ1.FQ4_LOJCLI = ?)	"  

			CQUERY += " LEFT JOIN "+RETSQLNAME("SHB")+" SHB     "  
			CQUERY += " ON SHB.HB_COD = ST9.T9_CENTRAB    	"  
			CQUERY += " AND	SHB.D_E_L_E_T_=' ' "  
			
			CQUERY += " LEFT JOIN "+RETSQLNAME("ST6")+" ST6 "  
			CQUERY += " ON ST9.T9_CODFAMI	=	ST6.T6_CODFAMI "  
			CQUERY += " AND ST9.D_E_L_E_T_	=	' ' "  

			CQUERY += " WHERE                   "  
			CQUERY += "  ST9.T9_CENTRAB BETWEEN ? AND ? "  
			// 11/10/2022 - Jose Eulalio - SIGALOC94-528 - Filtro por Cliente (trazer apenas o Status mais recente de cada bem)
			CQUERY += " AND ST9.T9_CODBEM  BETWEEN ? AND ? "  
			CQUERY += " AND ST9.T9_CODFAMI BETWEEN ? AND ? "  
			CQUERY += " AND ST9.T9_TIPMOD  BETWEEN ? AND ? "  
			CQUERY += " AND ST9.T9_STATUS  BETWEEN ? AND ? "  
			CQUERY += " AND ST9.T9_SITBEM	=	'A'				"  
			cQuery += " AND ST9.T9_STATUS <> '' "

			CQUERY += " ORDER BY "  
			CQUERY += " ST9.T9_CODFAMI,	"  
			CQUERY += " ST9.T9_TIPMOD	"

			IF SELECT("ZZZTRB") > 0
				ZZZTRB->(DBCLOSEAREA())
			ENDIF

			CQUERY := CHANGEQUERY(CQUERY) 
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

			CQUERY += " SELECT "  
			CQUERY += "	ZZZ.R_E_C_N_O_ RECNOFQ4, "  
			CQUERY += "	ST9.R_E_C_N_O_ RECNOST9, "  
			CQUERY += "	ST9.T9_CODBEM, "  
			CQUERY += "	ST9.T9_CODIMOB, "  
			CQUERY += " ST9.T9_TIPMOD, "  
			CQUERY += "	ST9.T9_CODFAMI, "  
			CQUERY += "	ST9.T9_FABRICA, "  
			CQUERY += "	ST9.T9_NOME, "  
			CQUERY += "	ST9.T9_STATUS, "  
			CQUERY += "	SHB.HB_COD, "  
			CQUERY += "	SHB.HB_NOME, "  
			CQUERY += "	SHB.HB_CC, "  
			CQUERY += "	COALESCE(ZZZ.FQ4_DOCUME,'') FQ4_DOCUME, "  
			CQUERY += "	COALESCE(ZZZ.FQ4_SERIE,'') FQ4_SERIE, "  
			CQUERY += "	COALESCE(ZZZ.FQ4_OS,'') FQ4_OS, "  
			CQUERY += "	COALESCE(ZZZ.FQ4_SERVIC,'') FQ4_SERVIC, "  
			CQUERY += "	COALESCE(ZZZ.FQ4_PRELIB,'') FQ4_PRELIB, "  
			CQUERY += "	COALESCE(ZZZ.FQ4_PROJET,'') FQ4_PROJET, "  
			CQUERY += "	COALESCE(ZZZ.FQ4_OBRA,'') FQ4_OBRA, "  
			CQUERY += "	COALESCE(ZZZ.FQ4_AS,'') FQ4_AS, "  
			CQUERY += "	COALESCE(ZZZ.FQ4_CODCLI,'') FQ4_CODCLI, "  
			CQUERY += "	COALESCE(ZZZ.FQ4_LOJCLI,'') FQ4_LOJCLI, "  
			CQUERY += "	COALESCE(ZZZ.FQ4_NOMCLI,'') FQ4_NOMCLI, "  
			CQUERY += "	COALESCE(ZZZ.FQ4_NFREM,'') FQ4_NFREM, "  
			CQUERY += "	COALESCE(ZZZ.FQ4_SERREM,'') FQ4_SERREM, "  
			CQUERY += "	COALESCE(ZZZ.FQ4_DTINI,'') FQ4_DTINI, "  
			CQUERY += "	COALESCE(ZZZ.FQ4_DTFIM,'') FQ4_DTFIM, "  
			CQUERY += "	COALESCE(ZZZ.FQ4_LOG,'') FQ4_LOG, "  
			CQUERY += "	COALESCE(ZZZ.FQ4_PREDES,'') FQ4_PREDES "  
			CQUERY += " FROM "+RETSQLNAME("ST9")+" ST9 "  
			cQuery += " LEFT JOIN "+RETSQLNAME("FQ4")+" ZZZ ON ZZZ.FQ4_CODBEM = ST9.T9_CODBEM AND ZZZ.D_E_L_E_T_='' AND ZZZ.R_E_C_N_O_ = (SELECT MAX(ZZZ1.R_E_C_N_O_) FROM "+RETSQLNAME("FQ4")+" ZZZ1 WHERE ZZZ1.FQ4_CODBEM = ST9.T9_CODBEM AND ZZZ1.D_E_L_E_T_ = ' ')

			CQUERY += " LEFT JOIN "+RETSQLNAME("SHB")+" SHB "  
			CQUERY += " ON SHB.HB_COD = ST9.T9_CENTRAB "  
			CQUERY += " AND	SHB.D_E_L_E_T_=' ' "  

			CQUERY += " LEFT JOIN "+RETSQLNAME("ST6")+" ST6 "  
			CQUERY += " ON ST9.T9_CODFAMI =	ST6.T6_CODFAMI "  
			CQUERY += " AND ST9.D_E_L_E_T_ = ' ' "  
			

			CQUERY += " WHERE "  
			CQUERY += " ST9.T9_CENTRAB BETWEEN ? AND ? "  
			// 11/10/2022 - Jose Eulalio - SIGALOC94-528 - Filtro por Cliente (trazer apenas o Status mais recente de cada bem)
			CQUERY += " AND ST9.T9_CODBEM BETWEEN ? AND ? "  
			CQUERY += " AND ST9.T9_CODFAMI BETWEEN ? AND ? "  
			CQUERY += " AND ST9.T9_TIPMOD BETWEEN ? AND ? "  
			CQUERY += " AND ST9.T9_STATUS BETWEEN ? AND ? "  
			CQUERY += " AND ST9.T9_SITBEM =	'A' "  
			cQuery += " AND ST9.D_E_L_E_T_ = ' ' "
			cQuery += " AND ST9.T9_STATUS <> ' ' "

			CQUERY += " ORDER BY "  
			CQUERY += " ST9.T9_CODFAMI,	"  
			CQUERY += " ST9.T9_TIPMOD "

			IF SELECT("ZZZTRB") > 0
				ZZZTRB->(DBCLOSEAREA())
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
			MPSysOpenQuery(cQuery,"ZZZTRB",,,aBindParam)

		EndIF
		ZZZTRB->(DBGOTOP())
		

		IIF( ZZZTRB->(EOF()) , LRET := .F. , LRET := .T. )

	ENDIF

RETURN LRET

/*/{Protheus.doc} ListaBens
Retorna lista de bens para filtro da query
@type  Static Function
@author Jose Eulalio
@since 16/10/2022
/*/
Static Function ListaBens()
Local cListaBens:= "''"
Local cQuery	:= ""
Local cAliasQry	:= GetNextAlias()

	cQuery += " SELECT DISTINCT FPA_GRUA  "  
	cQuery += " FROM " + RetSqlName("FP0") + " FP0 "  
	cQuery += " INNER JOIN " + RetSqlName("FPA") + " FPA ON "  
	cQuery += " FPA_FILIAL = FP0_FILIAL "  
	cQuery += " AND FPA_PROJET = FP0_PROJET "  
	cQuery += " AND FPA_GRUA <> '' "  
	cQuery += " AND FPA.D_E_L_E_T_ = ' ' "  
	cQuery += " INNER JOIN " + RetSqlName("FQ4") + " FQ4 ON "  
	cQuery += " FQ4_FILIAL = ? "  
	cQuery += " AND FQ4_PROJET = FP0_PROJET "  
	cQuery += " AND FPA_GRUA = FQ4_CODBEM "  
	cQuery += " AND FQ4.D_E_L_E_T_ = ' ' "  
	cQuery += " WHERE FP0_FILIAL = ? "  
	cQuery += " AND FP0.D_E_L_E_T_ = ' ' "  
	cQuery += " AND FP0_CLI = ? "  

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


/*/{Protheus.doc} ITST9STAT
Rotna de/para para status da ST8
@type function
@version 
@author Frank Zwarg Fuga
@since 31/10/2025
/*/
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

/*/{Protheus.doc} LOCR009B
Localizar os dados do relatório sintético
@type function
@version  
@author Frank Zwarg Fuga
@since 31/10/2025
/*/
Static Function LOCR009B(nOpc,cCliente, cLoja)
Local nResult := 0
Local aAreaST9 := ST9->(GetArea())
Local cTempCli := ""
Local cTempLoj := ""
Local cCodFami := ST9->T9_CODFAMI
Local nX

Default cCliente := ""
Default cLoja := ""

	aTemp := {}


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

		If ST9->T9_CODBEM < MV_PAR03 .or. ST9->T9_CODBEM > MV_PAR04
			ST9->(dbSkip())
			Loop
		EndIF

		If ST9->T9_CODFAMI <> cCodFami //< MV_PAR05 .or. ST9->T9_CODFAMI > MV_PAR06
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

		If ST9->T9_SITBEM <> 'A' .or. empty(ST9->T9_STATUS)
			ST9->(dbSkip())
			Loop
		EndIF

		If nOpc == 1 // quantidade de bens
			nResult ++
			lTem := .F.
			For nX := 1 to len(aTemp)
				If aTemp[nX] == ST9->T9_STATUS
					lTem := .T.
					Exit
				EndIF
			Next
			If !lTem
				aadd(aTemp,ST9->T9_STATUS)
			EndIf
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
			If ST9->T9_STATUS <> ITST9STAT("00") .AND. ST9->T9_STATUS <> ITST9STAT("10") .AND. ST9->T9_STATUS <> ITST9STAT("20") .AND. ST9->T9_STATUS <> ITST9STAT("60")
				nResult ++
			EndIF
		EndIF

		ST9->(dbSkip())

	EndDo
	ST9->(RestArea(aAreaST9))
Return nResult
