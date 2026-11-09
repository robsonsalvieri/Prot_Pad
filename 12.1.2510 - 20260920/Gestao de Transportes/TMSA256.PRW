#INCLUDE "TMSA256.ch"
#INCLUDE "Protheus.ch"

#DEFINE LT_MARCA  1
#DEFINE LT_CODOPE 2
#DEFINE LT_DESOPE 3
#DEFINE LT_CIOT   4
#DEFINE LT_CODVEI 5
#DEFINE LT_PLAVEI 6
#DEFINE LT_DATINI 7
#DEFINE LT_DATFIM 8
#DEFINE LT_STATUS 9
#DEFINE LT_FILORI 10
#DEFINE LT_VIAGEM 11
#DEFINE LT_STVIA  12

#DEFINE LT_SIZE   12 //-- Tamanho da linha no array

/*{Protheus.doc} TMSA256
Encerramento do CIOT
@author Daniel Carlos Leme
@since  03/10/2016
*/
Function TMSA256( aParam )
	Local aSize, aObjects, aPosObj, aInfo
	Local aListBox := {}
	Local cPerg := 'TMSA256'
	Local oDlg, oBtn

	Private oListBox
	Private lAllMark := .F.
	
	DEFAULT aParam := {}

	If ValType(aParam) == "A" .And. Len(aParam) > 1
		RpcSetType(3)
		RpcSetEnv(aParam[1],aParam[2],,,"TMS","TMSA256")    
		nModulo := 43
		
		Pergunte( cPerg, .F. )
		MV_PAR01 := CtoD('')
		MV_PAR02 := dDataBase + 30 
		MV_PAR03 := ""
		MV_PAR04 := ""
			
		LoadList( @aListBox, .T. )
		
		TmsLogMsg(,">> TMSA256 "+STR0001+  " - "+Dtoc(Date())+" "+Time() + STR0002)//-- "Encerramento de CIOT por período"##" Preparando ambiente..."

		BatchProcess(STR0001, STR0003, "TMSA256", { || TMSA256Prc( @aListBox, 2, .T. ) } , { || .F. } )	//-- 'Verificando...'

		TmsLogMsg(,"<< TMSA256 "+STR0001+ " - "+Dtoc(Date())+" "+Time() + STR0001) //-- "Encerramento de CIOT por período"##" Finalizando ambiente..."
		RPCClearEnv()
	Else
				
		If Pergunte( cPerg, .T. )
			CursorWait()
			LoadList( @aListBox )
			CursorArrow()
		EndIf

		If Len( aListBox ) > 0
		
			aSize    := MsAdvSize(.F. )
			aObjects := {}
			AAdd( aObjects, { 100, 020, .T., .F., .T.  } )
			AAdd( aObjects, { 100, 100, .T., .T. } )
			AAdd( aObjects, { 100, 020, .F., .F. } )
			aInfo := { aSize[ 1 ], aSize[ 2 ], aSize[ 3 ], aSize[ 4 ], 3, 3, .T.  }
			aPosObj := MsObjSize( aInfo, aObjects, .T. )

			DEFINE MSDIALOG oDlg TITLE STR0001 From aSize[7],0 to aSize[6],aSize[5] OF oMainWnd PIXEL //-- "Encerramento/Fechamento de CIOT ANTT ou IPFE por período."
		
				oPanel := TPanel():New( aPosObj[1,1], aPosObj[1,2], "", oDlg,,,,,CLR_WHITE,(aPosObj[1,3]), (aPosObj[1,4]), .T.,.T.)
		
				@ 005,005 CHECKBOX oAllMark VAR lAllMark PROMPT STR0005 SIZE 168, 08 ; //-- "Marca/Desmarca Todos"  
				ON CLICK TMSA256All(aListBox) OF oPanel PIXEL 
		
				@ aPosObj[2,1],aPosObj[2,2] LISTBOX oListBox Fields HEADER " ",;
					RetTitle( "DTR_CODOPE"),;
					RetTitle( "DEG_NOMOPE"),;
					RetTitle( "DJL_CIOT")," ",;
					RetTitle( "DJL_STATUS"),;
					RetTitle( "DJL_CODVEI"),;
					RetTitle( "DA3_PLACA"),;
					RetTitle( "DTR_FILORI"),;
					RetTitle( "DTR_VIAGEM"),;
					RetTitle( "DTQ_STATUS"),;
					RetTitle( "DJL_DATINI"),;
					RetTitle( "DJL_DATFIM");
					SIZE aPosObj[2,4]-aPosObj[2,2],aPosObj[2,3]-aPosObj[2,1] PIXEL 
				oListBox:bLDblClick := { || TMSA256Mrk(aListBox) }
				AtuPar( "NO", @aListBox, @oListBox, @oDlg )

				@ aPosObj[3,1],aPosObj[3,4]-100 BUTTON oBtn PROMPT STR0006 ACTION MsgRun( STR0009, STR0010, {|| TMSA256Prc(@aListBox,1), AtuPar( , @aListBox, @oListBox, @oDlg ) } ) OF oDlg PIXEL SIZE 045,011 //-- "Fechar CIOT" ## 'Realizando comunicacao com a Operadora...' ## "Aguarde"
				@ aPosObj[3,1],aPosObj[3,4]-040 BUTTON oBtn PROMPT STR0007 ACTION MsgRun( STR0009, STR0010, {|| TMSA256Prc(@aListBox,2), AtuPar( , @aListBox, @oListBox, @oDlg ) } ) OF oDlg PIXEL SIZE 045,011 //-- "Encerrar CIOT" ## 'Realizando comunicacao com a Operadora...' ## "Aguarde"
				@ aPosObj[3,1],aPosObj[3,4]+020 BUTTON oBtn PROMPT STR0011 ACTION JobCont( @aListBox, @oListBox, @oDlg ) OF oDlg PIXEL SIZE 045,011 //-- "Contingência"
				@ aPosObj[3,1],aPosObj[3,4]+080 BUTTON oBtn PROMPT STR0012 ACTION AtuPar( cPerg, @aListBox, @oListBox, @oDlg ) OF oDlg PIXEL SIZE 045,011 //-- "Atualizar"
				@ aPosObj[3,1],aPosObj[3,4]+140 BUTTON oBtn PROMPT STR0008 ACTION oDlg:End() OF oDlg PIXEL SIZE 045,011 //-- "Sair"
		
			ACTIVATE MSDIALOG oDlg
		EndIf
	EndIf

Return

/*{Protheus.doc} LoadList
Carrega array para processamento e listbox
@author Daniel Carlos Leme
@since  03/10/2016
*/
Static Function LoadList( aListBox, lJob )
	Local aArea := GetArea()
	Local cQuery := ''
	Local nPosVei := 0
	Local aCbxSta := RetSx3Box(Posicione('SX3',2,'DJL_STATUS','X3CBox()'),,,1)
	Local oQry

	Default lJob := .F.

	If MV_PAR04 != '04'
		cQuery := "SELECT DJL_CIOT, DJL_CODVEI, DJL_DATINI, DJL_DATFIM, DJL_STATUS,"
		cQuery += "DTR_CODOPE, DTR_FILORI, DTR_VIAGEM,"
		cQuery += "DTQ_STATUS "
		cQuery += "FROM " + RetSqlName('DJL') + " DJL "
		cQuery += "INNER JOIN " + RetSqlName('DTR') + " DTR "
		cQuery +=    "ON DTR_FILIAL = ? "
		cQuery +=   "AND DTR_CIOT = DJL_CIOT "
		cQuery +=   "AND DTR.D_E_L_E_T_ = ' ' "
		cQuery += "INNER JOIN " + RetSqlName('DTQ') + " DTQ "
		cQuery +=    "ON DTQ_FILIAL = ? "
		cQuery +=   "AND DTQ_FILORI = DTR_FILORI "
		cQuery +=   "AND DTQ_VIAGEM = DTR_VIAGEM "
		cQuery +=   "AND DTQ.D_E_L_E_T_ = ' ' "
		cQuery += "WHERE DJL.DJL_FILIAL = ? "
		cQuery +=   "AND DJL.DJL_STATUS IN ('1','2') " //-- 1-Em aberto/2-Fechado
		cQuery +=   "AND DJL.DJL_DATFIM BETWEEN ? AND ? "
		If !Empty(MV_PAR03)
			cQuery += "AND DJL.DJL_CODVEI = ? "
		EndIf
		If !Empty(MV_PAR04)
			cQuery += "AND DTR.DTR_CODOPE = ? "
		EndIf
		cQuery += "AND DJL.D_E_L_E_T_ = ' '"

		cQuery := ChangeQuery( cQuery )
		oQry := FwExecStatement():New( cQuery )
		oQry:SetString( 1, FWxFilial("DTR") )
		oQry:SetString( 2, FWxFilial("DTQ") )
		oQry:SetString( 3, FWxFilial("DJL") )
		oQry:SetDate( 4, MV_PAR01 )
		oQry:SetDate( 5, MV_PAR02 )
		If !Empty(MV_PAR03)
			oQry:SetString( 6, MV_PAR03 )
			If !Empty(MV_PAR04)
				oQry:SetString( 7, MV_PAR04 )
			EndIf
		ElseIf !Empty(MV_PAR04)
			oQry:SetString( 6, MV_PAR04 )
		EndIf
		oQry:SetFields( { {"DJL_DATINI","D",8,0}, {"DJL_DATFIM","D",8,0} } )
		cAliasQry := oQry:OpenAlias()

		While (cAliasQry)->(!Eof())
			Aadd(aListBox,Array(LT_SIZE))
			nPosVei := Len(aListBox)
			aListBox[nPosVei,LT_MARCA ] := Iif( lJob, '1', '2' )
			aListBox[nPosVei,LT_CODOPE] := (cAliasQry)->DTR_CODOPE
			aListBox[nPosVei,LT_DESOPE] := TMSValField(cAliasQry+"->DTR_CODOPE",.F.,,,.F.)
			aListBox[nPosVei,LT_CIOT  ] := (cAliasQry)->DJL_CIOT
			aListBox[nPosVei,LT_STATUS] := AllTrim( aCbxSta[ Ascan( aCbxSta, { |x| x[ 2 ] == (cAliasQry)->DJL_STATUS } ), 3 ])
			aListBox[nPosVei,LT_CODVEI] := (cAliasQry)->DJL_CODVEI
			aListBox[nPosVei,LT_PLAVEI] := Posicione( 'DA3', 1, xFilial('DA3')+(cAliasQry)->DJL_CODVEI, 'DA3_PLACA' )
			aListBox[nPosVei,LT_FILORI] := (cAliasQry)->DTR_FILORI
			aListBox[nPosVei,LT_VIAGEM] := (cAliasQry)->DTR_VIAGEM
			aListBox[nPosVei,LT_DATINI] := DtoC( (cAliasQry)->DJL_DATINI )
			aListBox[nPosVei,LT_DATFIM] := DtoC( (cAliasQry)->DJL_DATFIM )
			aListBox[nPosVei,LT_STVIA ] := (cAliasQry)->DTQ_STATUS
			(cAliasQry)->(DbSkip())
			If !(cAliasQry)->(Eof()) .And. (cAliasQry)->DJL_CIOT == aListBox[nPosVei,LT_CIOT]
				Do While !(cAliasQry)->(Eof()) .And. (cAliasQry)->DJL_CIOT == aListBox[nPosVei,LT_CIOT]
					(cAliasQry)->(DbSkip())
				EndDo
				aListBox[nPosVei,LT_FILORI] := " "
				aListBox[nPosVei,LT_VIAGEM] := STR0015 //-- "Várias"
				aListBox[nPosVei,LT_STVIA ] := " "
			EndIf
		EndDo
		(cAliasQry)->(dbCloseArea())
	EndIf

	If !lJob .And. ( Empty( MV_PAR04 ) .Or. MV_PAR04 == '04' )
		cQuery := "SELECT "
		cQuery += "DTQ.DTQ_FILORI, DTQ.DTQ_VIAGEM, DTQ.DTQ_STATUS, DTQ.DTQ_DATGER,"
		cQuery += "DTR.DTR_CIOT, DTR_CODVEI "
		cQuery += "FROM " + RetSQLName("DTQ") + " DTQ "
		cQuery += "INNER JOIN " + RetSQLName("DTR") + " DTR "
		cQuery +=    "ON DTR.DTR_FILIAL = ? "
		cQuery +=   "AND DTR.DTR_FILORI = DTQ.DTQ_FILORI "
		cQuery +=   "AND DTR.DTR_VIAGEM = DTQ.DTQ_VIAGEM "
		cQuery +=   "AND DTR.DTR_CODOPE IN ( ' ', '04' ) "
		cQuery +=   "AND DTR.DTR_CIOT <> ' ' "
		cQuery +=   "AND DTR.DTR_DTFMCI = ' ' "
		cQuery +=   "AND DTR.D_E_L_E_T_ = ' ' "
		cQuery += "WHERE "
		cQuery +=   "DTQ.DTQ_FILIAL = ? "
		cQuery +=   "AND DTQ.DTQ_DATGER BETWEEN ? AND ? "
		If !Empty(MV_PAR03)
			cQuery += "AND DTR.DTR_CODVEI = ? "
		EndIf
		cQuery +=   "AND DTQ.D_E_L_E_T_ = ' ' "

		cQuery := ChangeQuery( cQuery )
		oQry := FwExecStatement():New( cQuery )
		oQry:SetString( 1, FWxFilial("DTR") )
		oQry:SetString( 2, FWxFilial("DTQ") )
		oQry:SetDate( 3, MV_PAR01 )
		oQry:SetDate( 4, MV_PAR02 )
		If !Empty(MV_PAR03)
			oQry:SetString( 5, MV_PAR03 )
		EndIf
		oQry:SetFields( { {"DTQ_DATGER","D",8,0} } )
		cAliasQry := oQry:OpenAlias()

		While (cAliasQry)->(!Eof())
			Aadd(aListBox,Array(LT_SIZE))
			nPosVei := Len(aListBox)
			aListBox[nPosVei,LT_MARCA ] := Iif( lJob, '1', '2' )
			aListBox[nPosVei,LT_CODOPE] := "04"
			aListBox[nPosVei,LT_DESOPE] := "ANTT"
			aListBox[nPosVei,LT_CIOT  ] := (cAliasQry)->DTR_CIOT
			aListBox[nPosVei,LT_STATUS] := "Aberto"
			aListBox[nPosVei,LT_CODVEI] := (cAliasQry)->DTR_CODVEI
			aListBox[nPosVei,LT_PLAVEI] := Posicione( 'DA3', 1, xFilial('DA3')+(cAliasQry)->DTR_CODVEI, 'DA3_PLACA' )
			aListBox[nPosVei,LT_FILORI] := (cAliasQry)->DTQ_FILORI
			aListBox[nPosVei,LT_VIAGEM] := (cAliasQry)->DTQ_VIAGEM
			aListBox[nPosVei,LT_DATINI] := DtoC( (cAliasQry)->DTQ_DATGER )
			aListBox[nPosVei,LT_DATFIM] := "  /  /  "
			aListBox[nPosVei,LT_STVIA ] := (cAliasQry)->DTQ_STATUS
			(cAliasQry)->(DbSkip())
		EndDo
	EndIf

	If Len( aListBox ) == 0
		Help("",1,"REGNOIS")
	EndIf

	RestArea(aArea)

Return

/*{Protheus.doc} TMSA256Mrk
Marca/desmarca elemento do array para processamento
@author Daniel Carlos Leme
@since  03/10/2016
*/
Static Function TMSA256Mrk(aListBox,nItem,lUmItem)
	Default nItem   := oListBox:nAt
	Default lUmItem := .T.
	If lUmItem 
		aListBox[nItem,LT_MARCA] := Iif(aListBox[nItem,LT_MARCA] == '1','2','1')
	Else
		If lAllMark
			aListBox[nItem,LT_MARCA] := '1'
		Else
			aListBox[nItem,LT_MARCA] := '2'
		EndIf
	EndIf
	oListBox:Refresh()
Return

/*{Protheus.doc} TMSA256All
Marca/desmarca todos elementos do array para processamento
@author Daniel Carlos Leme
@since  03/10/2016
*/
Static Function TMSA256All(aListBox)
	Local nI
	CursorWait()
	For nI := 1 To Len(aListBox)
		TMSA256Mrk(aListBox, nI, .F. )
	Next nI
	CursorArrow()
Return

/*{Protheus.doc} TMSA256Prc
Processa o encerramento do CIOT 
@author Daniel Carlos Leme
@since  03/10/2016
*/
Static Function TMSA256Prc(aListBox,nOpc,lJob)
	Local nI      := 0
	Local aMsgErr := {}
	Local cHelp   := ""
	Local nCnt	  := 0
	Local lTM256V := ExistBlock('TM256VldF')
	Local l256VldF:= .T.

	Default nOpc := 2 //-- Encerrar CIOT
	Default lJob := .F.

	If AScan( aListBox, {|x| x[LT_MARCA] == '1' } ) == 0
		If !lJob
			Help("",1,"REGNOIS")
		EndIf
	Else
		For nI := 1 To Len(aListBox)
			
			l256VldF := .T.

			If aListBox[nI][LT_MARCA] == '1'
			
				If nOpc == 2 //--Encerrar CIOT
					If lTM256V .AND. lJob
						l256VldF := ExecBlock( 'TM256VldF', .F., .F., { xFilial("DJL"), aListBox[nI][LT_CIOT], aListBox[nI][LT_CODVEI], aListBox[nI][LT_DATINI], aListBox[nI][LT_DATFIM] } )
					EndIf
					If aListBox[nI][LT_CODOPE] == '03'	//--Pagbem 
						If l256VldF
							PgBEncCIOT(aListBox[nI][LT_CIOT],aListBox[nI][LT_CODVEI], @aMsgErr)
						EndIf
					ElseIf aListBox[nI][LT_CODOPE] == '02' //--Pamcard 
						PamEncCIOT(aListBox[nI][LT_CIOT],aListBox[nI][LT_CODVEI],aListBox[nI][LT_PLAVEI])
					ElseIf aListBox[nI][LT_CODOPE] == '04' //--ANTT
						If aListBox[nI][LT_STVIA] $ "3|9" //Encerradas ou Canceladas
							cHelp := "NOHELP"
							If !totvs.protheus.supply.tms.integration.antt.EncerraCIOT( aListBox[nI][LT_FILORI], aListBox[nI][LT_VIAGEM], @cHelp )
								AAdd( aMsgErr, { aListBox[nI][LT_FILORI]+"/"+aListBox[nI][LT_VIAGEM]+":"+cHelp, '06',  } )
							EndIf
						ElseIf !lJob
							AAdd( aMsgErr, { aListBox[nI][LT_FILORI]+"/"+aListBox[nI][LT_VIAGEM]+STR0013+aListBox[nI][LT_CIOT], '06',  } ) //-- ":Encerre esta Viagem para encerrar o CIOT:"
						EndIf
					EndIf

				ElseIf nOpc == 1 //-- Fechar CIOT
					If aListBox[nI][LT_CODOPE] != '04' //--ANTT
						DJL->(DbSetOrder(1)) //-- DJL_FILIAL+DJL_CIOT+DJL_CODVEI
						If DJL->(DbSeek(xFilial("DJL")+aListBox[nI][LT_CIOT]+aListBox[nI][LT_CODVEI])) .And. DJL->DJL_STATUS == "1"
							RecLock("DJL",.F.)
							DJL->DJL_STATUS := "2" //--Fechado
							DJL->DJL_DATFEC := dDataBase 
							MsUnLock()
						EndIf
					ElseIf !lJob
						AAdd( aMsgErr, { aListBox[nI][LT_FILORI]+"/"+aListBox[nI][LT_VIAGEM]+STR0014, '06',  } ) //--":CIOT ANTT não necessita ser fechado, apenas encerrado com a viagem."
					EndIf
				EndIf
			EndIf
		Next nI

		If !Empty( aMsgErr )
			If lJob
				For nCnt := 1 To Len(aMsgErr)
					AutoGrLog(aMsgErr[nCnt,1])
				Next nCnt
			Else
				TmsMsgErr( aMsgErr )
			EndIf
		EndIf
	Endif

Return

/*{Protheus.doc} Scheddef()
@Função Schedule 
@author Rafael Souza
@since 10/05/2022
*/
Static Function SchedDef()
Local aParam

aParam := {"P",;  			//Tipo R para relatorio P para processo   
		   "TMSA256",;		// Pergunte do relatorio, caso nao use passar ParamDef            
		   "DJL",;  		// Alias            
		   ,;   			//Array de ordens   
		   'Schedule - Encerra CIOT'} //Schedule - Encerra CIOT    

Return aParam

/*{Protheus.doc} AtuPar
Atualiza parâmetros e Tela
@author Carlos Alberto Gomes Junior
@since 30/07/2026
*/
Static Function AtuPar( cPerg, aListBox, oListBox, oDlg )
	Local oOk, oNo, oOn, oOff
	Local aCbxVia := RetSx3Box(Posicione('SX3',2,'DTQ_STATUS','X3CBox()'),,,1)
	DEFAULT cPerg := ""

	If Empty(cPerg) .Or. ( cPerg != "NO" .And. Pergunte( cPerg, .T. ) )
		aListBox := {}
		CursorWait()
		LoadList( @aListBox )
		CursorArrow()
	EndIf

	If Len( aListBox ) > 0
		oOk := LoadBitMap( GetResources(), "LBOK" )
		oNo := LoadBitMap( GetResources(), "LBNO" )
		oOn := LoadBitMap( GetResources(), "frtonline.PNG" )
		oOff := LoadBitMap( GetResources(), "frtoffline.PNG" )
		oListBox:SetArray( aListBox )
		oListBox:bLine := { || { ;
			Iif( aListBox[ oListBox:nAT,LT_MARCA  ] == '1', oOk, oNo ),;
			aListBox[ oListBox:nAT,LT_CODOPE ],;
			aListBox[ oListBox:nAT,LT_DESOPE ],;
			aListBox[ oListBox:nAT,LT_CIOT   ],;
			Iif( Substr(aListBox[ oListBox:nAT,LT_CIOT ],13,4 ) == 'XXXX', oOff, oOn ),;
			aListBox[ oListBox:nAT,LT_STATUS ],;
			aListBox[ oListBox:nAT,LT_CODVEI ],;
			aListBox[ oListBox:nAT,LT_PLAVEI ],;
			aListBox[ oListBox:nAT,LT_FILORI ],;
			aListBox[ oListBox:nAT,LT_VIAGEM ],;
			AllTrim( aCbxVia[ Ascan( aCbxVia, { |x| x[ 2 ] == aListBox[ oListBox:nAT,LT_STVIA ] } ), 3 ]),;
			aListBox[ oListBox:nAT,LT_DATINI ],;
			aListBox[ oListBox:nAT,LT_DATFIM ] } }
		If cPerg != "NO"
			oListBox:Refresh()
		EndIf
	Else
		If cPerg != "NO"
			oDlg:End()
		EndIf
	EndIf
Return

/*{Protheus.doc} JobCont
Executa o Job de Contingência
@author Carlos Alberto Gomes Junior
@since 30/07/2026
*/
Static Function JobCont(aListBox, oListBox, oDlg)
	TMSAC40()
	AtuPar( , @aListBox, @oListBox, @oDlg )
Return


