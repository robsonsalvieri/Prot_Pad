#INCLUDE "APWEBSRV.CH"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "WSPMS080.CH"
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
#DEFINE _BitMap                 17

#DEFINE _GANTT_ELEMENTS    		17


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³WSPMS010  ³ Autor ³Cristiano Denardi      ³ Data ³03.08.2005  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Web Service responsavel pela manutencao das informacoes      ³±±
±±³          ³de Projetos                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
WSSERVICE PmsGantt               DESCRIPTION STR0001 NAMESPACE ""
	WSDATA UserCode               AS String
	WSDATA ProjectCode            As String
	WSDATA WBSCode                As String
	WSDATA TaskList			   	  As Array Of GanttTaskView
	
	WSMETHOD GetTaskList      			DESCRIPTION STR0002
ENDWSSERVICE

/*/===========================================================/*/
WSMETHOD GetTaskList WSRECEIVE UserCode, ProjectCode, WBSCode WSSEND TaskList WSSERVICE PmsGantt

Local aArea    := GetArea()
Local lRetorno := .T.
Local cRev     := ""
Local nX,nZ       := 0
Local aGantt	:=	{}
If PrtChkUser(::UserCode,"PmsProjects","GetProject")

	cRev := PmsRevAtu( ProjectCode )
	dbSelectArea("AFC")
	dbSetOrder(1) //AFC_FILIAL+AFC_PROJET +REVISA+EDT
	If DbSeek(xFilial()+ProjectCode+cRev+WBSCODE)
		WSArrGantt(aGantt,ProjectCode+cRev+Padr(WBSCODE,TamSX3('AFC_EDT')[1]))
		If Len(aGantt) > 0
			::TaskList	:=	{}
			For nX := 1 To Len(aGantt)
				aadd(::TaskList,WsClassNew("GanttTaskView"))
				::TaskList[nX]:ProjectCode            :=	ProjectCode
				::TaskList[nX]:TaskType               :=	aGantt[nX,_TaskType             ]
				::TaskList[nX]:TaskCode               :=	aGantt[nX,_TaskCode             ]
				::TaskList[nX]:TaskDescription        :=	aGantt[nX,_TaskDescription      ]
				::TaskList[nX]:EstimatedInitialDate	  :=	aGantt[nX,_EstimatedInitialDate ] 
				::TaskList[nX]:EstimatedFinalDate	  :=	aGantt[nX,_EstimatedFinalDate	  ]
				::TaskList[nX]:EstimatedInitialHour	  :=	aGantt[nX,_EstimatedInitialHour ] 
				::TaskList[nX]:EstimatedFinalHour	  :=	aGantt[nX,_EstimatedFinalHour	  ]
				::TaskList[nX]:ExecutionInitialDate	  :=	aGantt[nX,_ExecutionInitialDate ] 
				::TaskList[nX]:ExecutionFinalDate	  :=	aGantt[nX,_ExecutionFinalDate	  ]
				::TaskList[nX]:POC                	  :=	aGantt[nX,_POC                  ] 
				::TaskList[nX]:CPM                	  :=	aGantt[nX,_CPM                  ] 
				::TaskList[nX]:TimeDuration       	  :=	aGantt[nX,_TimeDuration         ] 
				::TaskList[nX]:Level          	  		:=	aGantt[nX,_Level                ] 
				::TaskList[nX]:DbRecord          	  :=	aGantt[nX,_DbRecord             ] 
				::TaskList[nX]:Bitmap            	  :=	aGantt[nX,_BitMap               ] 
				
				::TaskList[nX]:Resources	:= ""

				For nZ:=1 To Len(aGantt[nX,_Resources])
					cRec	:=	StrTran(aGantt[nX,_Resources,nZ],";",",")
					cRec	:=	StrTran(cRec,"#","_")
					::TaskList[nX]:Resources   +=	cRec+";"
				Next
			Next
		Endif
	Else
		lRetorno := .F.
	EnDif
Else
	lRetorno := .F.
EndIf
RestArea(aArea)
Return(lRetorno)       
