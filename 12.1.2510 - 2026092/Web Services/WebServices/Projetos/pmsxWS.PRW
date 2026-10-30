#INCLUDE "PROTHEUS.CH"
#DEFINE _TaskType                1
#DEFINE _TaskCode                2
#DEFINE _TaskDescription         3
#DEFINE _EstimatedInitialDate	 4
#DEFINE _EstimatedFinalDate		 5
#DEFINE _EstimatedInitialHour	 6
#DEFINE _EstimatedFinalHour		 7
#DEFINE _ExecutionInitialDate	 8
#DEFINE _ExecutionFinalDate		 9
#DEFINE _POC                		10
#DEFINE _CPM                		11
#DEFINE _TimeDuration       	   12
#DEFINE _DbRecord           		13
#DEFINE _Resources          		14
#DEFINE _Level              		15
#DEFINE _ProjectCode            16
#DEFINE _BitMap             		17

#DEFINE _GANTT_ELEMENTS    		17


#DEFINE PMS_TASK	1
#DEFINE PMS_WBS	2
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³WSArrGantt ³ Autor ³ Bruno Sobieski       ³ Data ³ 09-02-2001 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Monta o array contendo os dados do Gantt.                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³Portal PMS                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function WSArrGantt(aGantt,cChave,lViewRec,nTpData,dDataIni,dDataFim,aTaskCPM,aTarefasDep,cUsr,nLevel)

Local aArea		:= GetArea()
Local aAreaAFC	:= AFC->(GetArea())
Local aAreaAF9	:= AF9->(GetArea())
Local cCritica	:= ""
Local nRealEspaco := 0

Local aNodes := {}
Local nNode  := 0

DEFAULT aTarefasDep := {}
DEFAULT nTpData	:= 1
DEFAULT dDataIni	:=	CTOD("01/01/1980")
DEFAULT dDataFim	:=	CTOD("31/12/2040")
DEFAULT lViewRec	:= .T.

Default nLevel := 1

If PmsChkUser(AFC->AFC_PROJET,,AFC->AFC_EDT,AFC->AFC_EDTPAI,1,"ESTRUT",AFC->AFC_REVISA,cUsr)

	//Adiciona EDT
	If !(AFC->AFC_FINISH<dDataIni.Or.AFC->AFC_START>dDataFim) .Or. Empty(AFC->AFC_START)
		AaddEDT(@aGantt, nLevel)
	EndIf
	nLevel++ 
EndIf

	//Adiciona dependencias
	AaddDep(cChave,cUsr,@aNodes,@aTarefasDep)
	
	
	aSort(aNodes, , , {|x, y| x[3]+x[4] < y[3]+y[4]})
	
	For nNode := 1 To Len(aNodes)
		If aNodes[nNode][1] == PMS_TASK
			// Tarefa
			dbSelectArea("AF9")
			AF9->(dbGoto(aNodes[nNode][2]))
			If !(AF9->AF9_FINISH<dDataIni.Or.AF9->AF9_START>dDataFim) .Or. Empty(AF9->AF9_START)
				AaddTask(@aGantt,lViewRec,nLevel)
			Endif
		Else
			// EDT
			dbSelectArea("AFC")
			AFC->(dbGoto(aNodes[nNode][2]))		
			WSArrGantt(aGantt,AFC->AFC_PROJET+AFC->AFC_REVISA+AFC->AFC_EDT,lViewRec,nTpData,dDataIni,dDataFim,aTaskCPM,aTarefasDep,cUsr, nLevel)
		EndIf	
	Next
//EndIf
	
RestArea(aAreaAF9)
RestArea(aAreaAFC)
RestArea(aArea)

Return
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³WSRecGantt ³ Autor ³ Bruno Sobieski       ³ Data ³ 09-02-2001   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Monta o array contendo os dados do Gantt referentes a um recurso³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³Portal PMS                                                      ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function WSRecGantt(aGantt,cRecurso,lViewRec,nTpData,dDataIni,dDataFim,cUsr)

Local aArea		:= GetArea()
Local aAreaAFA	:= AFA->(GetArea())
Local aAreaAF9	:= AF9->(GetArea())
Local nX
Local aRecAF9	:=	{}
DEFAULT nTpData	:= 1
DEFAULT dDataIni	:=	CTOD("01/01/1980")
DEFAULT dDataFim	:=	CTOD("31/12/2040")
DEFAULT lViewRec	:= .T.

PmsRetAloc(cRecurso,dDataIni,"00:00",dDataFim,"24:00",nTpData,,,,@aRecAF9,)

dbSelectArea("AF9")
For nX := 1 To Len(aRecAF9)
	MsGoto(aRecAF9[nX])	
	If PmsChkUser(AF9->AF9_PROJET,,AF9->AF9_TAREFA,AF9->AF9_EDTPAI,1,"ITENS",AF9->AF9_REVISA,cUsr)
		AaddTask(aGantt,lViewRec)
	EndIf
Next			
	
RestArea(aAreaAF9)
RestArea(aAreaAFA)
RestArea(aArea)

Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³WSTeamGantt³ Autor ³ Bruno Sobieski       ³ Data ³ 09-02-2001   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Monta o array contendo os dados do Gantt referentes a uma equipe³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³Portal PMS                                                      ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function WSTeamGantt(aGantt,cEquipe,lViewRec,nTpData,dDataIni,dDataFim,cUsr)

Local aArea		:= GetArea()
Local aAreaAFA	:= AFA->(GetArea())
Local aAreaAF9	:= AF9->(GetArea())
Local nX
Local aRecAF9	:=	{}
DEFAULT nTpData	:= 1
DEFAULT dDataIni	:=	CTOD("01/01/1980")
DEFAULT dDataFim	:=	CTOD("31/12/2040")
DEFAULT lViewRec	:= .T.

PmsEqpAloc(cEquipe,dDataIni,"00:00",dDataFim,"24:00",nTpData,        ,       ,    ,@aRecAF9,)

dbSelectArea("AF9")
For nX := 1 To Len(aRecAF9)
	MsGoto(aRecAF9[nX])	
	If PmsChkUser(AF9->AF9_PROJET,,AF9->AF9_TAREFA,AF9->AF9_EDTPAI,1,"ITENS",AF9->AF9_REVISA,cUsr)
		AaddTask(aGantt,lViewRec)
	EndIf
Next			
	
RestArea(aAreaAF9)
RestArea(aAreaAFA)
RestArea(aArea)

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³PmsRtResWbºAutor  ³Cristiano Denardi   º Data ³  09.08.05   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Similar a PmsRetRes, somente com tratamento para a Web     º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Portal PMS                                                 º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function PmsRtResWb( cAlias )

/*
	.: Valores de cCodImg :.
	------------------------
	AFC - EDT
		E1 - vermelho
		E2 - amarelo
		E3 - verde
		E4 - cinza
	AF9 - Tarefa
		J1 - vermelho
		J2 - amarelo
		J3 - verde
		J4 - cinza
*/
Local cCodImg 		:= ""
Local aArea			:= GetArea()
Default cAlias		:= ""
 
If AllTrim(cAlias)==""
 Return( cCodImg )
EndIf
 
If cAlias == "AFC"

	Do Case
		/////////////
		// Finalizado
		Case	!Empty(AFC->AFC_DTATUF)
			cCodImg := "E4"
		////////////////////////////
		//Inicio Atrasado (Vermelho)
		Case	dDataBase > AFC->AFC_START .And. Empty(AFC->AFC_DTATUI) .Or.;
			  	(dDataBase == AFC->AFC_START .And. Time() > AFC->AFC_HORAI) 
			cCodImg := "E1"
		//////////////
		//Fim atrasado  
		Case	dDataBase > AFC->AFC_FINISH .And. Empty(AFC->AFC_DTATUF) .Or.;
				(dDataBase == AFC->AFC_FINISH .And. Time() > AFC->AFC_HORAF) 
			cCodImg := "E1"
		
		Case	!Empty(AFC->AFC_DTATUI)
			cCodImg := "E2"

		Case	dDataBase > AFC->AFC_START .Or.;
			 	(dDataBase == AFC->AFC_START .And. Time() > AFC->AFC_HORAI)  
			cCodImg := "E1"

		OtherWise
			cCodImg := "E3"

	EndCase
 
ElseIf cAlias == "AF9"

	Do Case
		////////////////////
		//Finalizado (Cinza)
		Case	!Empty(AF9->AF9_DTATUF)
			cCodImg := "J4"
		
		////////////////////////////
		//Inicio Atrasado (Vermelho)
		Case	dDataBase > AF9->AF9_START .And. Empty(AF9->AF9_DTATUI) .Or.;
				(dDataBase == AF9->AF9_START .And. Time() > AF9->AF9_HORAI) 
			cCodImg := "J1"
			
		//////////////
		//Fim atrasado
		Case	dDataBase > AF9->AF9_FINISH .And. Empty(AF9->AF9_DTATUF) .Or.;
				(dDataBase == AF9->AF9_FINISH .And. Time() > AF9->AF9_HORAF) 
			cCodImg := "J1"
			
		/////////////////////////////////////////////////////////////////
		//Iniciado e nao finalizado, mais ainda dentro do prazo (Amarelo)
		Case	!Empty(AF9->AF9_DTATUI) .And. Empty(AF9->AF9_DTATUF)
			cCodImg := "J2"
			
		OtherWise
			cCodImg := "J3"

	EndCase     
Endif

RestArea( aArea )
Return( cCodImg )

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³UsrPrtErp ºAutor  ³Cristiano Denardi   º Data ³  09.08.05   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Busca usuario do Sistema atraves do User do Portal     	  º±±
±±º          ³ Amarracao no Cadastro de user do Portal.               	  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Portal PMS                                                 º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function UsrPrtErp( cUsrPrt )

Local aArUsr		:= GetArea()
Local cUsrErp 		:= ""
Default cUsrPrt	:= ""
dbSelectArea("AI3")
dbSetOrder(1) // AI3_FILIAL+AI3_CODUSU
If MsSeek( xFilial("AI3")+cUsrPrt )
	cUsrErp := AI3->AI3_USRSIS
Endif
RestArea( aArUsr )
Return( cUsrErp )

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³AaddEDT    ³ Autor ³ Bruno Sobieski       ³ Data ³ 21-02-2006 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Adiciona uma EDT ao Array                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³Portal PMS                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Static Function AaddEDT(aGantt, nLevel)
Local nPos

Default nLevel := 1

aadd(aGantt,Array(_GANTT_ELEMENTS))
nPos	:=	Len(aGantt)
aGantt[nPos,_ProjectCode           	]	:=	AFC->AFC_PROJET
aGantt[nPos,_TaskType					]	:=	2
aGantt[nPos,_TaskCode            	]	:=	AFC->AFC_EDT	 
aGantt[nPos,_TaskDescription     	]	:=	Alltrim(AFC->AFC_DESCRI)
aGantt[nPos,_TimeDuration				]	:=	AFC->AFC_HDURAC
aGantt[nPos,_EstimatedInitialDate	]	:=	AFC->AFC_START
aGantt[nPos,_EstimatedFinalDate		]	:= AFC->AFC_FINISH
aGantt[nPos,_EstimatedInitialHour	]	:=	AFC->AFC_HORAI
aGantt[nPos,_EstimatedFinalHour		]	:=	AFC->AFC_HORAF
aGantt[nPos,_ExecutionInitialDate	]	:=	AFC->AFC_DTATUI
aGantt[nPos,_ExecutionFinalDate		]	:= AFC->AFC_DTATUF
aGantt[nPos,_POC                		]	:=	PmsPOCAFC(AFC->AFC_PROJET,AFC->AFC_REVISA,AFC->AFC_EDT		,CTOD("01/12/2020"),1					)
aGantt[nPos,_CPM           			]	:= 0
aGantt[nPos,_Resources     			]	:= {}
aGantt[nPos,_Level     					]	:= StrZero(nLevel, Len(AFC->AFC_NIVEL)) //AFC->AFC_NIVEL
aGantt[nPos,_BitMap           		]	:= PmsRetRes('AFC',AFC->(RecNo()),.T.)
aGantt[nPos,_DbRecord           		]	:= AFC->(RecNo())

Return
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³AaddDep    ³ Autor ³ Bruno Sobieski       ³ Data ³ 21-02-2006 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Adiciona as dependencias ao array de dependencias ao aNodes   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³Portal PMS                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function AaddDep(cChave,cUsr,aNodes,aTarefasDep)
Local nPos	:=	0

dbSelectArea("AF9")
dbSetOrder(2)
MsSeek(xFilial()+cChave)
While !Eof() .And. AF9->AF9_FILIAL+AF9->AF9_PROJET+AF9->AF9_REVISA+;
					AF9->AF9_EDTPAI==xFilial("AF9")+cChave
	If PmsChkUser(AF9->AF9_PROJET,AF9->AF9_TAREFA,,AF9->AF9_EDTPAI,1,"ESTRUT",AF9->AF9_REVISA,cUsr)

		aAdd(aNodes, {PMS_TASK,;
		              AF9->(Recno()),;
		              If(Empty(AF9->AF9_ORDEM), "000", AF9->AF9_ORDEM),;
		              AF9->AF9_TAREFA})
			              
		dbSelectArea("AFD")
		dbSetOrder(1)
			
		If MsSeek(xFilial("AFD")+AF9->AF9_PROJET+AF9->AF9_REVISA+AF9->AF9_TAREFA)
			While !AFD->(EOF()) .And.  xFilial("AFD")+AF9->AF9_PROJET+AF9->AF9_REVISA+AF9->AF9_TAREFA== AFD->AFD_FILIAL+AFD->AFD_PROJET+AFD->AFD_REVISA+AFD->AFD_TAREFA
				nPos := aScan( aTarefasDep ,{|aTarefa| aTarefa[1] == AFD->AFD_TAREFA})
				If nPos > 0
					aadd( aTarefasDep[nPos][2],{ AFD->AFD_PREDEC ,AFD->AFD_TIPO } )
				Else	                               
					aadd( aTarefasDep ,{ AFD->AFD_TAREFA ,{ {AFD->AFD_PREDEC ,AFD->AFD_TIPO} }} )
				Endif		
				AFD->(dbSkip())
			EndDo
		EndIf
	EndIf
	dbSelectArea("AF9")	
	dbSkip()
EndDo

dbSelectArea("AFC")
dbSetOrder(2)
MsSeek(xFilial()+cChave)
While !Eof() .And. AFC->AFC_FILIAL+AFC->AFC_PROJET+AFC->AFC_REVISA+;
					AFC->AFC_EDTPAI==xFilial("AFC")+cChave
	aAdd(aNodes, {PMS_WBS,;
	              AFC->(Recno()),;
	              If(Empty(AFC->AFC_ORDEM), "000", AFC->AFC_ORDEM),;
	              AFC->AFC_EDT})
	dbSkip()
EndDo

Return
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³AaddTask   ³ Autor ³ Bruno Sobieski       ³ Data ³ 21-02-2006 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Adiciona as tarefas ao array do gantt                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³Portal PMS                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function AaddTask(aGantt,lViewRec, nLevel)
Local nPos	:=	0
Default nLevel := 1
Aadd(aGantt,Array(_GANTT_ELEMENTS))
nPos	:=	Len(aGantt)
aGantt[nPos,_ProjectCode           	]:=	AF9->AF9_PROJET
aGantt[nPos,_TaskType					]:=	1
aGantt[nPos,_TaskCode              	]:=	AF9->AF9_TAREFA
aGantt[nPos,_TaskDescription       	]:=	Alltrim(AF9->AF9_DESCRI)
aGantt[nPos,_TimeDuration				]:=	AF9->AF9_HDURAC
aGantt[nPos,_EstimatedInitialDate	]:=	AF9->AF9_START
aGantt[nPos,_EstimatedFinalDate		]:= 	AF9->AF9_FINISH
aGantt[nPos,_EstimatedInitialHour	]:=	AF9->AF9_HORAI
aGantt[nPos,_EstimatedFinalHour		]:=	AF9->AF9_HORAF
aGantt[nPos,_ExecutionInitialDate	]:=	AF9->AF9_DTATUI
aGantt[nPos,_ExecutionFinalDate		]:= 	AF9->AF9_DTATUF
aGantt[nPos,_POC                		]:=	PmsPOCAF9(AF9->AF9_PROJET,AF9->AF9_REVISA,AF9->AF9_TAREFA	,CTOD("01/12/2020"),1					)
aGantt[nPos,_CPM           			]:= 	0
aGantt[nPos,_Resources     			]:= 	{}
aGantt[nPos,_Level     					]:= 	StrZero(nLevel, Len(AF9->AF9_NIVEL))//AF9->AF9_NIVEL
aGantt[nPos,_BitMap           		]:= 	PmsRetRes('AF9',AF9->(RecNo()),.T.)
aGantt[nPos,_DbRecord           		]:= 	AF9->(RecNo())
If lViewRec
	dbSelectArea("AFA")
	dbSetOrder(1)
	MsSeek(xFilial()+AF9->AF9_PROJET+AF9->AF9_REVISA+AF9->AF9_TAREFA)
	While !Eof() .And. AFA->AFA_FILIAL+AFA->AFA_PROJET+AFA_REVISA+AFA->AFA_TAREFA==xFilial("AFA")+AF9->AF9_PROJET+AF9->AF9_REVISA+AF9->AF9_TAREFA
		If !Empty(AFA->AFA_RECURS)
			AE8->(MsSeek(xFilial()+AFA->AFA_RECURS))
			AAdd(aGantt[nPos,_Resources],"["+Alltrim(AFA->AFA_RECURS)+"]"+Alltrim(AE8->AE8_DESCRI))
		Endif	                                                                         
		DbSkip()
	Enddo
	DbSelectArea('AF9')	
Endif
Return
