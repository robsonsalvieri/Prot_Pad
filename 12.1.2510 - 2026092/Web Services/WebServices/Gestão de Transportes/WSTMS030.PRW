#INCLUDE "WSTMS030.ch"
#INCLUDE "APWEBSRV.CH"
#INCLUDE "PROTHEUS.CH"
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³WSTMS030  ³ Autor ³Gustavo Almeida        ³ Data ³28.02.2011  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Web Service das funcionalidades de Tracking do Portal TMS -  ³±±
±±³          ³ Gestão de Transportes.                                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³                                                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³                                                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Portal TMS                                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß 
/*/
WSSTRUCT TrackingView
	WSDATA TvDate      AS Date    //-- Data
	WSDATA TvTime      AS String  //-- Hora
	WSDATA TvOperOccur AS String  //-- Operações/Ocorrências
	WSDATA TvBranch    AS String  //-- Filial
	WSDATA TvTrip      AS String  //-- Viagem
	WSDATA TvTransServ AS String  //-- Serviço de Transporte
ENDWSSTRUCT

WSSTRUCT TrackingDoc
	WSDATA TdDate      AS Date   Optional  //-- Data de Emissão do Documento/Nota
	WSDATA TdTime      AS String Optional  //-- Hora da Emissão do Documento/Nota
	WSDATA TdDocNumber AS String           //-- Numero do Documento/Nota          
	WSDATA TdDocSeries AS String           //-- Serie do Documento/Nota
	WSDATA TdBranch    AS String           //-- Filial do Documento/Nota
	WSDATA TdStatus    AS String Optional  //-- Status do Documento/Nota
ENDWSSTRUCT

WSSERVICE TMSTRACKING DESCRIPTION STR0001 //"Serviço de Tracking"

	WSDATA UserCode        AS String
	WSDATA DocType         AS String
	WSDATA DocNumber       AS String Optional
	WSDATA DateFrom        AS String Optional
	WSDATA DateTo          AS String Optional
	WSDATA Tracking        AS Array Of TrackingView 
	WSDATA DocBrowser      AS Array Of TrackingDoc
	WSDATA DocInformation  AS TrackingDoc
	
	WSMETHOD GetTrackingView
	WSMETHOD GetBrwTracking 
	
ENDWSSERVICE

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Método    ³ GetTrackingView ³ Autor ³Gustavo Almeida  ³ Data ³28.03.2011 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Método que retorna os valores de tracking de uma viagem.     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³                                                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³                                                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Portal TMS                                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß 
*/  
WSMETHOD GetTrackingView WSRECEIVE UserCode,DocType,DocInformation WSSEND Tracking WSSERVICE TMSTRACKING 

Local aArea   := GetArea()

Local aItens    := {}
Local nI        := 0 
Local cFilDoc   := ""
Local cDoc      := ""
Local cSerieDoc := ""
Local cCliRem   := ""
Local cLojRem   := ""
Local cNumNfc   := ""
Local cSerNfc   := ""
Local lR5       := GetRpoRelease() >= "R5" // Indica se o release e 11.5
Local nVersao   := VAL(GetVersao(.F.))     // Indica a versao do Protheus  
Local lRet      := .T.

//--Compatibilidade com o fonte TMSA500
Private aSetKey := {}
//-- Mudança para do nModulo para o SIGATMS (43)
Private nModulo := 43  //-- Modulo do TMS

If nVersao < 11 .OR. (nVersao == 11 .And. !lR5)
	lRet:= .F.
EndIf

If lRet
	If ::DocType == "1" //-- Nota Fiscal
		DUE->(dbSetOrder(4))
		If DUE->(dbSeek(xFilial('DUE')+::UserCode))
			cCliRem := DUE->DUE_CODCLI
			cLojRem := DUE->DUE_LOJCLI
			cNumNfc := ::DocInformation:TdDocNumber
			cSerNfc := ::DocInformation:TdDocSeries
			DTC->(dbSetOrder(5))
			If DTC->(dbSeek(xFilial('DTC')+cCliRem+cLojRem+cNumNfc+cSerNfc))
				cFilDoc   := DTC->DTC_FILDOC
				cDoc      := DTC->DTC_DOC
				cSerieDoc := DTC->DTC_SERIE 	
			EndIf
		EndIf
	Else
		cFilDoc   := ::DocInformation:TdBranch
		cDoc      := ::DocInformation:TdDocNumber
		cSerieDoc := ::DocInformation:TdDocSeries
	EndIf	
	
	DT6->(dbSetOrder(1))      
	If DT6->(dbSeek(xFilial("DT6")+cFilDoc+cDoc+cSerieDoc))
		
		aItens := aClone(Tmsa500Tr3(.T.))
		For nI := 1 To Len(aItens)
			aAdd(::Tracking,WSClassNew("TrackingView"))
			::Tracking[nI]:TvDate      := aItens[nI][1] //-- Data
			::Tracking[nI]:TvTime      := aItens[nI][2] //-- Hora
			::Tracking[nI]:TvOperOccur := aItens[nI][3] //-- Operações/Ocorrências
			::Tracking[nI]:TvBranch    := aItens[nI][4] //-- Filial
			::Tracking[nI]:TvTrip      := aItens[nI][5] //-- Viagem
			::Tracking[nI]:TvTransServ := aItens[nI][6] //-- Serviço de Transporte
		Next nI
	EndIf
	
	RestArea(aArea)
EndIf
		 
Return .T.


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Método    ³ GetBrwTracking  ³ Autor ³Gustavo Almeida  ³ Data ³28.03.2011 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Método que retorna os valores de tracking em listagem para   ³±±
±±³Descri‡…o ³ seleção.                                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³                                                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³                                                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Portal TMS                                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß 
*/  
WSMETHOD GetBrwTracking WSRECEIVE UserCode,DocType,DocNumber,DateFrom,DateTo WSSEND DocBrowser WSSERVICE TMSTRACKING 

Local aArea     := GetArea()
Local nX        := 0 
Local cAliasQry := GetNextAlias()
Local cQuery    := "" 
Local cUserDDD  := ""
Local cUserTel  := ""
Local cCodCli   := ""
Local cLojCli   := ""
Local lR5       := GetRpoRelease() >= "R5" // Indica se o release e 11.5
Local nVersao   := VAL(GetVersao(.F.))     // Indica a versao do Protheus  
Local lRet      := .T.
Local cCodSol   := ""

If nVersao < 11 .OR. (nVersao == 11 .And. !lR5)
	lRet:= .F.
EndIf

If lRet
	If ::DocType == '1' //-- Nota Fiscal  
		DUE->(dbSetOrder(4))
		If DUE->(dbSeek(xFiliaL('DUE')+::UserCode)) .And. !Empty(DUE->DUE_CODCLI)
			cCodCli := DUE->DUE_CODCLI
			cLojCli := DUE->DUE_LOJCLI
			cQuery  := "SELECT DTC_FILORI, DTC_NUMNFC, DTC_SERNFC, DTC_DATENT, DTC_HORENT, DT6_STATUS"
			cQuery  += "  FROM "
			cQuery  += RetSqlName("DTC")+" DTC "
			cQuery  += "  LEFT JOIN "
			cQuery  += RetSqlName("DT6")+" DT6 "
			cQuery  += "    ON DT6_FILIAL = '"+xFilial('DT6')+"'"
			cQuery  += "   AND DT6_FILDOC = DTC_FILDOC"
			cQuery  += "   AND DT6_DOC    = DTC_DOC   "
			cQuery  += "   AND DT6_SERIE  = DTC_SERIE "
			cQuery  += " WHERE DTC.DTC_FILIAL = '"+xFilial("DTC")+"'"
			cQuery  += "   AND DTC.DTC_CLIREM = '"+cCodCli+"'" 
			cQuery  += "   AND DTC.DTC_LOJREM = '"+cLojCli+"'" 
			If !Empty(::DocNumber)
				cQuery += " AND DTC.DTC_NUMNFC = '"+::DocNumber+"'"
			ElseIf !Empty(::DateFrom) .And. !Empty(::DateTo)
				cQuery += " AND DTC.DTC_DATENT BETWEEN '" + ::DateFrom + "' AND '" + ::DateTo + "' "
			EndIf
			cQuery   += "  AND DTC.D_E_L_E_T_ = ' '"
			cQuery   += "  AND DT6.D_E_L_E_T_ = ' '"
			cQuery += "ORDER BY DTC_DATENT, DTC_HORENT DESC"
			cQuery := ChangeQuery(cQuery)
			dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasQry,.T.,.T.)
			
			While (cAliasQry)->(!Eof())
			
				aAdd(::DocBrowser,WSClassNew("TrackingDoc"))
				nX++
			
				::DocBrowser[nX]:TdDate      := Stod((cAliasQry)->DTC_DATENT)
				::DocBrowser[nX]:TdTime      := (cAliasQry)->DTC_HORENT
				::DocBrowser[nX]:TdBranch    := (cAliasQry)->DTC_FILORI
				::DocBrowser[nX]:TdDocNumber := (cAliasQry)->DTC_NUMNFC
				::DocBrowser[nX]:TdDocSeries := (cAliasQry)->DTC_SERNFC
				::DocBrowser[nX]:TdStatus    := Iif(!Empty((cAliasQry)->DT6_STATUS),(cAliasQry)->DT6_STATUS,"0")				
			  
				(cAliasQry)->(dbSkip())
					
			EndDo
			(cAliasQry)->(dbCloseArea())
		EndIf	
			
	Else  //-- Docto. Transporte   
	     
		DUE->(dbSetOrder(4))
		If DUE->(dbSeek(xFiliaL('DUE')+::UserCode))
			cUserDDD := DUE->DUE_DDD
			cUserTel := DUE->DUE_TEL
			cCodCli  := DUE->DUE_CODCLI
			cLojCli  := DUE->DUE_LOJCLI
			cCodSol  := DUE->DUE_CODSOL
			
			cQuery   := ""
			cQuery   += "SELECT DT6_FILDOC, DT6_DOC, DT6_SERIE, DT6_DATEMI, DT6_HOREMI, DT6_STATUS "
			cQuery   += " FROM  "
			cQuery   += RetSqlName("DT5")+" DT5, "
			cQuery   += RetSqlName("DT6")+" DT6  "
			cQuery   += " WHERE DT5.DT5_FILIAL = '"+xFilial("DT5")+"'"
			cQuery   += "   AND DT5.DT5_CODSOL = '"+cCodSol+"'" 
			If !Empty(::DocNumber)
				cQuery += "  AND DT5.DT5_DOC    = '"+::DocNumber+"'"
			ElseIf !Empty(::DateFrom) .And. !Empty(::DateTo)
				cQuery += "  AND DT5.DT5_DATSOL BETWEEN '" + ::DateFrom + "' AND '" + ::DateTo + "' "
			EndIf
			cQuery   += "   AND DT5.D_E_L_E_T_ = ' '"
			cQuery   += "   AND DT6.DT6_FILDOC = DT5_FILDOC"
			cQuery   += "   AND DT6.DT6_DOC    = DT5_DOC   "
			cQuery   += "   AND DT6.DT6_SERIE  = DT5_SERIE "
			cQuery   += "   AND DT6.D_E_L_E_T_ = ' '"
			If !Empty(cCodCli)
				cQuery += " UNION ALL "
				cQuery += "SELECT DT6_FILDOC, DT6_DOC, DT6_SERIE, DT6_DATEMI, DT6_HOREMI, DT6_STATUS "
				cQuery += " FROM  "
				cQuery += RetSqlName("DT6")+" DT6"
				cQuery += " WHERE DT6.DT6_FILIAL = '"+xFilial("DT5")+"'"
				cQuery += "   AND DT6.DT6_CLIREM = '"+cCodCli+"'" 
				cQuery += "   AND DT6.DT6_LOJREM = '"+cLojCli+"'" 
				If ::DocNumber <> ""
					cQuery += "  AND DT6.DT6_DOC = '"+::DocNumber+"'"
				ElseIf !Empty(::DateFrom) .And. !Empty(::DateTo)
					cQuery += "  AND DT6.DT6_DATEMI BETWEEN '" + ::DateFrom + "' AND '" + ::DateTo + "' "
				EndIf
				cQuery += "   AND DT6.DT6_DOCTMS <> '1'"
				cQuery += "   AND DT6.D_E_L_E_T_  = ' '"
			EndIf		
			cQuery += "ORDER BY DT6_DATEMI, DT6_HOREMI DESC"
			cQuery := ChangeQuery(cQuery)
			dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasQry,.T.,.T.)
			
			While (cAliasQry)->(!Eof())
			
				aAdd(::DocBrowser,WSClassNew("TrackingDoc"))
				nX++
			
				::DocBrowser[nX]:TdDate      := Stod((cAliasQry)->DT6_DATEMI)
				::DocBrowser[nX]:TdTime      := (cAliasQry)->DT6_HOREMI
				::DocBrowser[nX]:TdBranch    := (cAliasQry)->DT6_FILDOC
				::DocBrowser[nX]:TdDocNumber := (cAliasQry)->DT6_DOC
				::DocBrowser[nX]:TdDocSeries := (cAliasQry)->DT6_SERIE
				::DocBrowser[nX]:TdStatus    := Iif(!Empty((cAliasQry)->DT6_STATUS),(cAliasQry)->DT6_STATUS,"0")
					
				(cAliasQry)->(dbSkip())
					
			EndDo
			(cAliasQry)->(dbCloseArea())
		EndIf		
	EndIf
	
	RestArea(aArea)
EndIf
		 
Return .T.