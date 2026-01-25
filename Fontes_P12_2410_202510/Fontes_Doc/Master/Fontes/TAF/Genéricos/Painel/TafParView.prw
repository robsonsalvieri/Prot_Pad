#INCLUDE "PROTHEUS.CH"
#INCLUDE "TOTVS.CH"
#INCLUDE "TAFPARVIEW.CH"

#DEFINE LB_VALID 	10
#DEFINE LB_OPC		11
#DEFINE LB_F3		12
#DEFINE LB_TYPE		4

//-------------------------------------------------------------------
/*/{Protheus.doc} TafParView
Interface de edição de parametros por tipo
@author Roberto Souza
@since 24/04/2018
@version 1.0 

@aParam	

@return Nil
/*/
//-------------------------------------------------------------------	
Function TafParView( oFather, oProc , cOwner )

	Local PANEL_CFG 	as array
	Local aSize     	as array
	Local aArea     	as array
	Local aInfo     	as array
	Local aObjects  	as array
	Local aPosObj 		as array
	Local aPos 	    	as array
	Local aCpoH     	as array
	Local aListPar      as array
	Local aCombo    	as array
	Local aPerg     	as array
	Local aParam    	as array
	Local aInd			as array
	Local aCond			as array
	Local aItems		as array
	Local aWindow		as array
	Local aColumn		as array
	Local aCoord		as array
	Local aTamObj		as array

	Local lRet 			as logical
	Local lDock	     	as logical
	Local lProc			as logical
	Local lContinua     as logical
	Local lCallExt		as logical

	Local oDlgList		as object
	Local oDlgPar		as object
	Local oList1		as object
	Local oList2 		as object
	Local oAreaPar	 	as object
	Local oLbx			as object
	Local oFont 		as object
	Local oFont2		as object
	Local oFont3		as object
	Local oButt1		as object
	Local oButt2		as object	
	Local oOk 			as object
	Local oNo 			as object	

	Local nOpcA		  	as numeric
	Local nMaxAlt		as numeric

	Local bOk			as codeblock
	Local bCfg		   	as codeblock
	Local bPsq		   	as codeblock
	Local bDet			as codeblock
	Local bEdit			as codeblock
	Local bLeg			as codeblock	
	
	Local cDescView 	as character
	Local cInd        	as character
	Local bXline		as character
	Local cCond       	as character
	Local cInfo			as character

	Default cOwner		:= "0"
	
	lCallExt	:= Upper( FunName() ) <> "TAFPARVIEW"
	PANEL_CFG 	:= {{ 000,000,620,1100},{"Tahoma","Verdana","Courier New"} }
	lRet 		:= .F.  
	lDock	    := oFather <> nil
	oDlgList	:= Nil
	oDlgPar		:= Nil
	oList1		:= Nil
	oList2 		:= Nil	
	oAreaPar	:= FWLayer():New()
	aCoord		:= PANEL_CFG[01] // {ODLG_HINI,ODLG_WINI,ODLG_HEND,ODLG_WEND}//FWGetDialogSize(oMainWnd)
	aTamObj		:= Array(4)
	lProc		:= oProc <> Nil
	oLbx		:= Nil
	nOpcA		:= 0
	bXline		:= ""
	bOk			:= {|| lRet := .T.,oDlgPar:End() }
	bCfg		:= {|| lRet := .F.,oDlgPar:End() }
	bPsq		:= {|| ProcPsq( aInd, cInd, aCond, cCond, cInfo , oLbx) } 
	bDet		:= {|| TafXEdtPar( 2 ,aListPar[oLbx:nAt],aListPar[oLbx:nAt][02],aListPar[oLbx:nAt][03],,aListPar[oLbx:nAt][09]) }
	bEdit		:= {|| TafXEdtPar( 4 ,aListPar[oLbx:nAt],aListPar[oLbx:nAt][02],aListPar[oLbx:nAt][03],,aListPar[oLbx:nAt][09]), RefreshLbx( oLbx, aListPar, bXline ) }
	bLeg		:= {|| TafLegPar() }
	oFont 		:= TFont():New(PANEL_CFG[02][01],08,12,,.T.,,,,.T.)
	oFont2		:= TFont():New(PANEL_CFG[02][02],08,12,,.T.,,,,.T.)
	oFont3		:= TFont():New(PANEL_CFG[02][03],09,12,,.T.,,,,.T.)
	oButt1		:= Nil	
	oButt2		:= Nil
	aSize     	:= {}
	aArea     	:= GetArea()
	aInfo     	:= {}
	aObjects  	:= {}
	aPosObj 	:= {}
	aPos 	    := {012,005,200,600}
	aCpoH     	:= {}
	cDescView 	:= ""
	aCombo    	:= {}
	aPerg     	:= {}
	aParam    	:= Array(1)
	aInd		:= {STR0001,STR0002}//{"Parâmetro","Descrição"}
	cInd        := Space(60) 
	aCond		:= {STR0003,STR0004}//{"Igual à","Contém"}
	cCond       := Space(60) 
	cInfo		:= Space(60)
	aItems		:= {}
	aWindow		:= {}
	aColumn		:= {}
	nMaxAlt		:= 096
	lProc       := oProc <> Nil
	aListPar    := {}
	oOk 		:= LoadBitmap(GetResources(), LegAccMode( "BR_VERDE" ))
	oNo 		:= LoadBitmap(GetResources(), LegAccMode( "BR_VERMELHO" ))
	lContinua	:= .T.

	//Se foi chamado pela apuração do reinf ou pelo menu "Parametros" e se tem acesso ao botão de configurações.(Privilégio usuário.)
	if FunName() != 'TAFMONREI' .and. MPUserHasAccess('TAFXREINF',1) .And. MPUserHasAccess('TafParView',1)	
		If lProc 
			oProc:IncProc2( "..." )
		Endif

		aParams := {}
		
		cFilParam := " 'MV_TAF' $ SX6->X6_VAR .or. SX6->X6_VAR == 'MV_BACKEND' .or. SX6->X6_VAR == 'MV_GCTPURL'"

		//resoluçao 1280 x 768
		aSize:= {0,0,608.5,270,1217,563,0} 

		aInfo := {aSize[1],aSize[2],aSize[3],aSize[4],3,3}

		AADD(aObjects,{100,30,.T.,.F.})
		AADD(aObjects,{100,100,.T.,.T.})
		aPosObj := MsObjSize(aInfo, aObjects)

		aScreen   := GetScreenRes()
		aScreen[1]:= aScreen[1]-20
		aScreen[2]:= aScreen[2]-20

		aCoord[3] *= 0.95
		aCoord[4] *= 0.9

		If lDock
			oDlgPar := oFather
			aWindow := {017,083}
			aColumn := {090,010}
		Else
			oDlgPar := tDialog():New(aCoord[1],aCoord[2],aCoord[3],aCoord[4],STR0005,,,,DS_MODALFRAME,CLR_BLACK,CLR_WHITE,,,.T.) //"Parâmetros"
			aWindow := {020,080}
			aColumn := {090,010}
		EndIf
			
		oAreaPar:Init(oDlgPar,.F., .F. )
		//Mapeamento da area
		oAreaPar:AddLine("L01",nMaxAlt,.T.)

		//ÚÄÄÄÄÄÄÄÄÄ¿
		//³Colunas  ³
		//ÀÄÄÄÄÄÄÄÄÄÙ
		oAreaPar:AddCollumn("L01C01",aColumn[01],.F.,"L01") //dados
		oAreaPar:AddCollumn("L01C02",aColumn[02],.F.,"L01") //botoes

		//ÚÄÄÄÄÄÄÄÄÄ¿
		//³Paineis  ³
		//ÀÄÄÄÄÄÄÄÄÄÙ
		oAreaPar:AddWindow("L01C01","TEXT",STR0006,aWindow[01],.F.,.F.,/*bAction*/,"L01",/*bGotFocus*/) //"Informações"
		oText	:= oAreaPar:GetWinPanel("L01C01","TEXT","L01")
		
		oAreaPar:AddWindow("L01C01","LIST",STR0007,aWindow[02],.F.,.F.,/*bAction*/,"L01",/*bGotFocus*/) //"Detalhes"
		oListX6	:= oAreaPar:GetWinPanel("L01C01","LIST","L01")

		@ 002,002 SAY STR0008 FONT oFont COLOR CLR_BLUE Pixel Of oText //"Pesquisa por:"
		@ 012,002 COMBOBOX oInd VAR cInd ITEMS aInd SIZE 060,08 PIXEL OF oText 

		@ 002,072 SAY STR0009 FONT oFont COLOR CLR_BLUE Pixel Of oText //"Condição:"
		@ 012,072 COMBOBOX oCond VAR cCond ITEMS aCond SIZE 060,08 PIXEL OF oText 

		@ 002,142 SAY STR0010 FONT oFont COLOR CLR_BLUE Pixel Of oText //"Informação:"
		@ 012,142 MSGET oInfo VAR cInfo SIZE 150,08 PIXEL OF oText 

		oButPsq := tButton():New(012,300,STR0011				,oText,bPsq	,45,11,,/*oFont*/,,.T.,,,,/*bWhen*/) //"Pesquisar"

		If lCallExt
			LoadParams( 1, aParams , @aListPar , cFilParam , cOwner )
		ElseIf FWIsAdmin( __cUserID )
			LoadParams( 2, aParams , @aListPar , cFilParam , cOwner )
		Else		
			lContinua := .F.		
			//"Este usuário não pertence ao grupo de administradores.
			//"Não será possível acessar esta rotina."
			//"Atenção!"		
			MsgAlert(STR0028 + CRLF + CRLF + STR0029, STR0030)		
		EndIf

		If lContinua

			aColsBrw := {}
			
			AADD(aColsBrw,{"",STR0012,STR0001,STR0013,STR0014,STR0002,STR0002+" 1",STR0002+" 2"}) //{"","Filial","Parâmetro","Tipo","Conteúdo","Descrição","Desc 1","Desc 2"}) 
			AADD(aColsBrw,{10,25,40,30,50,100,100,50})
			
			bXline	:=  '{|| {'	
			bXline	+=	'IIf (aListPar[oLbx:nAt][01]=="U",oOk,oNo),'
			bXline	+=	'aListPar[oLbx:nAt][02],'
			bXline	+=	'aListPar[oLbx:nAt][03],'
			bXline	+=	'aListPar[oLbx:nAt][04],'
			bXline	+=	'aListPar[oLbx:nAt][05],'
			bXline	+=	'aListPar[oLbx:nAt][06],'
			bXline	+=	'aListPar[oLbx:nAt][07],'
			bXline	+=	'aListPar[oLbx:nAt][08]'
			bXline	+=	'}}'

			oLbx := TWBrowse():New( 000 , 000, 230,095,,aColsBrw[01],aColsBrw[02],;                              
			oListX6,,,,,{||},,,,,,,.F.,,.T.,,.F.,,, )    

			oLbx:SetArray(aListPar)   
			oLbx:bLine := &( bXline )
		/*
			oLbx:bLine := {|| {	IIf (aListPar[oLbx:nAt][01]=="U",oOk,oNo),;
									aListPar[oLbx:nAt][02],;
									aListPar[oLbx:nAt][03],;
									aListPar[oLbx:nAt][04],;
									aListPar[oLbx:nAt][05],;
									aListPar[oLbx:nAt][06],;
									aListPar[oLbx:nAt][07],;
									aListPar[oLbx:nAt][08]}}	
		*/ 
			oLbx:bLDblClick := bDet
			oLbx:Align    	:= CONTROL_ALIGN_ALLCLIENT

			oAreaPar:AddWindow("L01C02","L01C02P01",STR0016,100,.F.,.F.,/*bAction*/,"L01",/*bGotFocus*/) //"Funções"
			oAreaParBut := oAreaPar:GetWinPanel("L01C02","L01C02P01","L01")

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Painel 03-Botoes            ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			oButt1 := tButton():New(000,000,STR0016	,oAreaParBut,bDet	,oAreaParBut:nClientWidth/2,15,,/*oFont*/,,.T.,,,,/*bWhen*/)//"Visualizar"
			oButt2 := tButton():New(016,000,STR0017	,oAreaParBut,bEdit	,oAreaParBut:nClientWidth/2,15,,/*oFont*/,,.T.,,,,/*bWhen*/)//"Alterar"
			oButt3 := tButton():New(032,000,STR0018	,oAreaParBut,bLeg	,oAreaParBut:nClientWidth/2,15,,/*oFont*/,,.T.,,,,/*bWhen*/)//"Legenda"

			If !lDock
				oButt3 := tButton():New(048,000,STR0019				,oAreaParBut,bOk	,oAreaParBut:nClientWidth/2,15,,/*oFont*/,,.T.,,,,/*bWhen*/) //"Sair"
				oDlgPar:Activate(,,,.T.,/*valid*/,,/*On Init*/)
			EndIf
		EndIf

		RestArea(aArea)
	else
		alert('Esse usuário não possui acesso ao menu "Configurações".')
	endif	

Return( lRet )     

//-------------------------------------------------------------------
/*/{Protheus.doc} RefreshLbx
Executa um refresh no listbox
@author Roberto Souza
@since 24/04/2018
@version 1.0 

@aParam	

@return Nil
/*/
//-------------------------------------------------------------------
Static Function RefreshLbx( oLbx, aListPar, bXline )

	Local oOk 	as object
	Local oNo 	as object

	oOk 		:= LoadBitmap(GetResources(), LegAccMode( "BR_VERDE" ))
	oNo 		:= LoadBitmap(GetResources(), LegAccMode( "BR_VERMELHO" ))

	DbSelectArea("SX6")
	DbSetOrder( 1 )
	DbSeek( aListPar[oLbx:nAt][02] + aListPar[oLbx:nAt][03] )

	aListPar[oLbx:nAt][05] := SX6->X6_CONTEUD

	oLbx:SetArray(aListPar)    
	If !Empty( bxLine )
		oLbx:bLine := &( bXline )
	Else

		oLbx:bLine := {|| {	IIf (aListPar[oLbx:nAt][01]=="U",oOk,oNo),;
								aListPar[oLbx:nAt][02],;
								aListPar[oLbx:nAt][03],;
								aListPar[oLbx:nAt][04],;
								aListPar[oLbx:nAt][05],;
								aListPar[oLbx:nAt][06],;
								aListPar[oLbx:nAt][07],;
								aListPar[oLbx:nAt][08]}}
	EndIf
	oLbx:Refresh()

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} ProcPsq
Pesquisa no Grid 
@author Roberto Souza
@since 24/04/2018
@version 1.0 

@aParam	

@return Nil
/*/
//-------------------------------------------------------------------
Static Function ProcPsq( aInd, cInd, aCond, cCond, cInfo , oLbx )

	Local lRet 		as logical
	Local aSeek 	as array
	Local nCol  	as numeric
	Local nCond		as numeric
	Local nPosIni   as numeric
	Local nModo 	as numeric

	lRet 		:= .T.
	aSeek 		:= oLbx:AARRAY
	nCol  		:= aScan( aInd,	{|x| Alltrim(x) == AllTrim(cInd) } ) + 2
	nCond		:= aScan( aCond,{|x| Alltrim(x) == AllTrim(cCond) } )
	nPosIni 	:= oLbx:NAT
	nModo 		:= 2    

	If nCond == 1
		nSeek := aScan( aSeek, {|x| Upper(Alltrim(cInfo)) == Upper(AllTrim(x[nCol])) })	                 
	ElseIf nCond == 2
		nSeek := aScan( aSeek, {|x| Upper(Alltrim(cInfo)) $  Upper(AllTrim(x[nCol])) })	                 
	EndIf	                    
    
	If nSeek == 0
		nSeek := 1
	EndIf
                     
	oLbx:NAT := nSeek
	oLbx:Refresh()

Return( lRet )       

//-------------------------------------------------------------------
/*/{Protheus.doc} TafXEdtPar
Interface de edição
@author Roberto Souza
@since 24/04/2018
@version 1.0 

@aParam	

@return Nil
/*/
//-------------------------------------------------------------------
Function TafXEdtPar( nOpc, oList, cFilPar , cPar, cDesc , cDescHelp )

	Local PANEL_CFG 	as array
	Local lRet 			as logical
	Local oDlgEdit		as object
	Local oList1		as object
	Local oList2 		as object
	Local oArea		   	as object
	Local aCoord		as array
	Local aTamObj		as array
	Local nOpcA		  	as numeric
	Local bOk			as codeblock
	Local bCfg		   	as codeblock
	Local bGrvPar		as codeblock
	Local bPsq		   	as codeblock
	Local oFont 		as object
	Local oFont2		as object
	Local oFont3		as object
	Local oButt1		as object
	Local oButt2		as object
	Local aSize     	as array
	Local aArea     	as array
	Local aInfo     	as array
	Local aObjects  	as array
	Local aPosObj 		as array
	Local aPos 	    	as array
	Local aCpoH     	as array
	Local cDescView 	as character
	Local aCombo    	as array
	Local aPerg     	as array
	Local aParam    	as array
	Local ALTERA		as logical
	Local VISUAL		as logical
	Local cInfo    		as character
	Local Nx	   		as numeric
	Local nLin 			as numeric
	Local aInd			as array
	Local cInd          as character
	Local aCond			as array
	Local cCond         as character	
	Local nAltF			as numeric
	Local nMaxAlt		as numeric
	Local aLin 			as array
	Local aCpo 			as array
	Local nAltL  		as numeric
	Local nCpo   		as numeric
	Local nSalto 		as numeric

	PANEL_CFG 	:= {{ 000,000,620,1100},{"Tahoma","Verdana","Courier New"} }	
	lRet 		:= .F.
	oDlgEdit	:= Nil 
	oList1		:= Nil
	oList2 		:= Nil
	oArea		:= FWLayer():New()
	aCoord		:= PANEL_CFG[01] // {ODLG_HINI,ODLG_WINI,ODLG_HEND,ODLG_WEND}//FWGetDialogSize(oMainWnd)
	aTamObj		:= Array(4)
	nOpcA		:= 0
	bOk			:= {|| lRet := .T.,oDlgEdit:End() }
	bCfg		:= {|| lRet := .F.,oDlgEdit:End() }
	bGrvPar		:= {|| xGrvParam( SX6->X6_FIL, SX6->X6_VAR, xConteud , SX6->X6_TIPO, Len( oList[LB_OPC]) > 0 ),oDlgEdit:End()  }
	bPsq		:= {|| ProcPsq( aInd, cInd, aCond, cCond, cInfo , oLbx) }
	oFont 		:= TFont():New(PANEL_CFG[02][01],08,12,,.T.,,,,.T.)
	oFont2		:= TFont():New(PANEL_CFG[02][02],08,12,,.T.,,,,.T.)
	oFont3		:= TFont():New(PANEL_CFG[02][03],09,12,,.T.,,,,.T.)
	oButt1		:= Nil
	oButt2		:= Nil
	aSize     	:= {}
	aArea     	:= GetArea()
	aInfo     	:= {}
	aObjects  	:= {}
	aPosObj 	:= {}
	aPos 	    := {012,005,200,600}
	aCpoH     	:= {}
	cDescView 	:= ""
	aCombo    	:= {}
	aPerg     	:= {}
	aParam    	:= Array(1)
	ALTERA		:= nOpc == 4
	VISUAL		:= nOpc == 2
	cInfo    	:= ""  
	Nx	   		:= 0        
	nLin 		:= 0
	aInd		:= {"Tabela","Descrição"}
	cInd        := Space(60) 
	aCond		:= {"Igual à","Contém"}
	cCond       := Space(60) 
	cInfo		:= Space(60) 
	nAltF		:= 08
	nMaxAlt		:= 096
	aLin 		:= {} 
	aCpo 		:= {} 
	nAltL  		:= 00	
	nCpo   		:= 07
	nSalto 		:= 21

	For nLin := 1 To 10
		AADD(aLin,nAltL)
		AADD(aCpo,nAltL + nCpo )
		nAltL += nSalto
	Next

	//resoluçao 1280 x 768
	aSize:= {0,0,608.5,270,1217,563,0}

	aInfo := {aSize[1],aSize[2],aSize[3],aSize[4],3,3}

	AADD(aObjects,{100,30,.T.,.F.})
	AADD(aObjects,{100,100,.T.,.T.})
	aPosObj := MsObjSize(aInfo, aObjects)

	aScreen   := GetScreenRes()
	aScreen[1]:= aScreen[1]-20
	aScreen[2]:= aScreen[2]-20

	aCoord[3] *= 0.75
	aCoord[4] *= 0.75
	
	If ALTERA
		aCoord[3] := aCoord[3] * 0.65	
	EndIf

	oDlgEdit := tDialog():New(aCoord[1],aCoord[2],aCoord[3],aCoord[4],cPar,,,,DS_MODALFRAME,CLR_BLACK,CLR_WHITE,,,.T.)
	oArea:Init(oDlgEdit,.F., .F. )
	//Mapeamento da area
	oArea:AddLine("L01",nMaxAlt-3,.T.)

	//ÚÄÄÄÄÄÄÄÄÄ¿
	//³Colunas  ³
	//ÀÄÄÄÄÄÄÄÄÄÙ
	oArea:AddCollumn("L01C00",85,.F.,"L01") //Detalhe
	oArea:AddCollumn("L01C02",15,.F.,"L01") //botoes

	//ÚÄÄÄÄÄÄÄÄÄ¿
	//³Detalhe  ³
	//ÀÄÄÄÄÄÄÄÄÄÙ
 	oArea:AddWindow("L01C00","DETAIL",STR0007,100,.F.,.F.,/*bAction*/,"L01",/*bGotFocus*/)//"DetalheS"
	oDetail	:= oArea:GetWinPanel("L01C00","DETAIL","L01")

	DbSelectArea("SX6")
	DbSetOrder(1)
	SX6->(DbSeek(cFilPar+cPar))

	cDescP := AllTrim(SX6->X6_DESCRIC)+" "+AllTrim(SX6->X6_DESC1)  +" "+AllTrim(SX6->X6_DESC2)
	cDescE := AllTrim(SX6->X6_DSCSPA) +" "+AllTrim(SX6->X6_DSCSPA1)+" "+AllTrim(SX6->X6_DSCSPA2)
	cDescI := AllTrim(SX6->X6_DSCENG) +" "+AllTrim(SX6->X6_DSCENG1)+" "+AllTrim(SX6->X6_DSCENG2)

	If ALTERA

		@ aLin[01], 000 SAY OemToAnsi(STR0012)	 				OF oDetail PIXEL COLOR CLR_BLUE FONT oFont // "Filial"
		@ aLin[01], 040 SAY OemToAnsi(STR0001)					OF oDetail PIXEL COLOR CLR_BLUE FONT oFont // "Parametro"
		@ aLin[01], 100 SAY OemToAnsi(STR0013)					OF oDetail PIXEL COLOR CLR_BLUE FONT oFont // "Tipo:"

		@ aCpo[01], 000 MSGET oTitulo 	VAR cFilPar	  			SIZE 020,nAltF Of oDetail PIXEL PICTURE "" READONLY
		@ aCpo[01], 040 MSGET oCampo 	VAR cPar  				SIZE 050,nAltF Of oDetail PIXEL PICTURE "" READONLY
		@ aCpo[01], 100 MSGET oTipo  	VAR oList[LB_TYPE] 			SIZE 030,nAltF Of oDetail PIXEL PICTURE "@!" READONLY 

		@ aLin[02], 000 SAY OemToAnsi(STR0002) 					OF oDetail PIXEL COLOR CLR_BLUE FONT oFont // "Descrição:"
		@ aCpo[02], 000 MSGET oDescric	VAR cDescP				SIZE 330,nAltF OF oDetail PIXEL	READONLY		
		
		@ aLin[03], 000 SAY OemToAnsi(STR0014) 					OF oDetail PIXEL COLOR CLR_BLUE FONT oFont // "Conteúdo:"
	
		If !Empty( oList[LB_VALID] )
			bValid := &('{|| '+oList[LB_VALID]+'}')
		Else
			bValid := &('{|| .T. }')

		EndIf
		If Len( oList[LB_OPC]) > 0
			nPosOpc := aScan( oList[LB_OPC], {|x| Left(x,1)== AllTrim(SX6->X6_CONTEUD) } )
			If nPosOpc > 0
				xConteud := nPosOpc
			Else
				xConteud := Len( oList[LB_OPC])
			EndIf
			
			@ aCpo[03], 000 COMBOBOX oConteud VAR xConteud ITEMS oList[LB_OPC]		SIZE 330,nAltF OF oDetail PIXEL	VALID eVal(bValid)			
		ElseIf !Empty(oList[LB_F3])
			xConteud := SX6->X6_CONTEUD	
			cF3 := 	oList[LB_F3]	
			@ aCpo[03], 000 MSGET oDescric	VAR xConteud F3 cF3	SIZE 330,nAltF OF oDetail PIXEL	VALID eVal(bValid)		//	&oList[LB_VALID]		
			
		Else	
			xConteud := SX6->X6_CONTEUD			
			@ aCpo[03], 000 MSGET oDescric	VAR xConteud	SIZE 330,nAltF OF oDetail PIXEL	VALID eVal(bValid)			//&oList[LB_VALID]		
		EndIf	

		@ aLin[04], 000 SAY OemToAnsi("Informações"	)		OF oDetail PIXEL COLOR CLR_BLUE FONT oFont // "Validacão do Usuário:"
		@ aCpo[04], 000 GET oDescHelp		VAR cDescHelp	MEMO	SIZE 330,(nAltF*5.5) OF oDetail PIXEL READONLY

	
	ElseIf VISUAL

		@ aLin[01], 000 SAY OemToAnsi(STR0012)	 				OF oDetail PIXEL COLOR CLR_BLUE FONT oFont // "Filial"
		@ aLin[01], 040 SAY OemToAnsi(STR0001)					OF oDetail PIXEL COLOR CLR_BLUE FONT oFont // "Parametro"
		@ aLin[01], 100 SAY OemToAnsi(STR0013)					OF oDetail PIXEL COLOR CLR_BLUE FONT oFont // "Tipo:"


		@ aCpo[01], 000 MSGET oTitulo 	VAR cFilPar  						SIZE 020,nAltF Of oDetail PIXEL PICTURE "" READONLY
		@ aCpo[01], 040 MSGET oCampo 	VAR cPar  							SIZE 050,nAltF Of oDetail PIXEL PICTURE "" READONLY
		@ aCpo[01], 100 MSGET oTipo  	VAR oList[LB_TYPE]  						SIZE 030,nAltF Of oDetail PIXEL PICTURE "@!" READONLY

		@ aLin[02], 000 SAY OemToAnsi(STR0002) 					OF oDetail PIXEL COLOR CLR_BLUE FONT oFont // "Descrição:"
		@ aCpo[02], 000 MSGET oDescric	VAR cDescP					SIZE 330,nAltF OF oDetail PIXEL	READONLY
		
		@ aLin[03], 000 SAY OemToAnsi(STR0002+" "+STR0020)		OF oDetail PIXEL COLOR CLR_BLUE FONT oFont // ""Descrição Espanhol""
		@ aCpo[03], 000 MSGET oDescE		VAR cDescE			 		SIZE 330,nAltF OF oDetail PIXEL READONLY
		
		@ aLin[04], 000 SAY OemToAnsi(STR0002+" "+STR0021)		OF oDetail PIXEL COLOR CLR_BLUE FONT oFont // "Descrição Inglês"
		@ aCpo[04], 000 MSGET oDescI		VAR cDescI	 				SIZE 330,nAltF OF oDetail PIXEL READONLY

		@ aLin[05], 000 SAY OemToAnsi(STR0014) 					OF oDetail PIXEL COLOR CLR_BLUE FONT oFont // "Conteúdo:"
		@ aCpo[05], 000 MSGET oDescric	VAR GetMV(cPar)		SIZE 330,nAltF OF oDetail PIXEL	READONLY
		
		@ aLin[08], 000 SAY OemToAnsi(STR0006)		OF oDetail PIXEL COLOR CLR_BLUE FONT oFont // "Validacão do Usuário:"
		@ aCpo[08], 000 GET oDescHelp		VAR cDescHelp	MEMO	SIZE 330,(nAltF*5.5) OF oDetail PIXEL READONLY

	EndIf

	//ÚÄÄÄÄÄÄÄÄÄ¿
	//³Paineis  ³
	//ÀÄÄÄÄÄÄÄÄÄÙ

	oArea:AddWindow("L01C02","L01C02P01",STR0015,100,.F.,.F.,/*bAction*/,"L01",/*bGotFocus*/) //"Funções"
	oAreaBut := oArea:GetWinPanel("L01C02","L01C02P01","L01")

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Painel 03-Botoes            ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If ALTERA
		oButt1 := tButton():New(000,000,STR0022		,oAreaBut,bGrvPar	,oAreaBut:nClientWidth/2,15,,/*oFont*/,,.T.,,,,/*bWhen*/)//Confirmar
		oButt2 := tButton():New(016,000,STR0019				,oAreaBut,bOk		,oAreaBut:nClientWidth/2,15,,/*oFont*/,,.T.,,,,/*bWhen*/) //"&Sair"
	Else
		oButt2 := tButton():New(000,000,STR0019				,oAreaBut,bOk	,oAreaBut:nClientWidth/2,15,,/*oFont*/,,.T.,,,,/*bWhen*/)//"&Sair"
	EndIf

	oDlgEdit:Activate(,,,.T.,/*valid*/,,/*On Init*/)
		
	RestArea(aArea)

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} xGrvParam
Grava o conteudo editado.
@author Roberto Souza
@since 24/04/2018
@version 1.0 

@aParam	

@return Nil
/*/
//-------------------------------------------------------------------
Static Function xGrvParam( cFilParam, cParam, xConteud , cTipoPar, lCombo )
		
	Local cFilBkp	:= cFilAnt

	xConteud := AllToChar( xConteud )
	
	If lCombo
		xConteud := Left( lTrim( xConteud ), 1 )
	EndIf

	uContAnt := AllToChar( SuperGetMv( cParam ,.F.,,cFilParam ) )

	If Alltrim( cParam ) == "MV_TAFSURL" .And. FindFunction( "TAFCTSpd")
		uContAnt := IIf( FindFunction( "TafGetUrlTSS" ), TafGetUrlTSS(), AllToChar( SuperGetMv( cParam ,.F.,,cFilParam )) ) // Utiliza funçao padronizada com compertilhamento de empresa
		TAFCTSpd(xConteud,1,.T.,"",.T.)
	Else
		// --> Verifica se deve atualizar o cache de parâmetros
		If MsgYesNo( "Deseja que o novo conteúdo do parâmetro já esteja válido para as rotinas que estão em execução no momento?" )
			PutMvPar( cParam , xConteud, cFilParam)
		Else
			cFilAnt := cFilParam
			PutMV( cParam, xConteud )
			cFilAnt	:= cFilBkp
		EndIf
	EndIf


	Aviso(cParam,STR0023+CRLF+ ; //"Parametro alterado com sucesso:"
			STR0024 + uContAnt+CRLF+; //"Conteúdo anterior :"
			STR0025 + xConteud,; //"Conteúdo novo :"
			{"Ok"},2)

	/*
	DbSelectArea('SX6')
	SX6->( dbSetOrder( 1 ) )
	
	If SX6->( DbSeek( cFilParam + cParam ) ) 
		uContAnt := AllToChar( SX6->X6_CONTEUD )
		Reclock( 'SX6' , .F. )
		SX6->X6_CONTEUD := xConteud
		SX6->X6_CONTSPA := xConteud
		SX6->X6_CONTENG := xConteud
		SX6->( MsUnlock() )
		Aviso(cParam,STR0023+CRLF+ ; //"Parametro alterado com sucesso:"
			STR0024 + uContAnt+CRLF+; //"Conteúdo anterior :"
			STR0025 + xConteud,; //"Conteúdo novo :"
			{"Ok"},2)
	Endif
	*/
Return( .T. )

 //-------------------------------------------------------------------
/*/{Protheus.doc} LoadParams
Carrega os parametros para visualização.
@author Roberto Souza
@since 24/04/2018
@version 1.0 

@aParam	

@return Nil
/*/
//-------------------------------------------------------------------
 Static Function LoadParams( xType, aParams, aListPar , cFilParam , cOwner )

	Local aRet		as array
	Local bWhile  	as codeblock
	Local Nx      	as numeric
	Local Ny      	as numeric
	Local Nw      	as numeric
	Local aFils   	as array
	Local lSeek		as logical
	
	aRet		:= {}
	bWhile  	:= {||}
	Nx      	:= 0
	Ny      	:= 0
	Nw      	:= 0
	aFils   	:= { cFilAnt , PadR( FWCodEmp(), Len(cFilAnt) ), Space( Len(cFilAnt) )}
	lSeek		:= .F.

	Default xType := 2
	Default cFilParam := ".T."
	
	DbSelectArea("SX6") 
	SX6->(DbSetOrder(1))
	
	If xType == 1 // Carrega somente parametros favoritos
	
		aParSX6 := TafxparLd( cOwner )
		//aParams
        If !Empty( aParSX6 )

            For Nx := 1 To Len( aParSX6 )
                lSeek := .F.
                For Ny := 1 To Len( aFils )

                    If SX6->( DbSeek(aFils[Ny] + aParSX6[Nx][03] ) ) .And. !lSeek			
                        lSeek := .T.
						cValid 	:= ".T."
                        aOpc	:= {}
                        
                        If !Empty( aParSX6[Nx][07] )
                            cValid := aParSX6[Nx][07]
                        EndIf
                        
                        If !Empty( aParSX6[Nx][09] )
                            For Nw := 1 To Len( aParSX6[Nx][09] )
                                AADD(aOpc, aParSX6[Nx][09][Nw] )
                            Next Nw
                            // Adiciona uma posição em branco para poder invalidar o parametro
							If aParSX6[Nx][3] != "MV_TAFAMBR"
                            	AADD(aOpc, " ")
							EndIf
                        EndIf
                        If !Empty( aParSX6[Nx][10] )
                            cF3 := aParSX6[Nx][10]
                        Else
                            cF3 := ""
                        EndIf	
                        
                        AADD(aListPar,{	SX6->X6_PROPRI			,;
                                            SX6->X6_FIL			,;
                                            SX6->X6_VAR			,; 
                                            SX6->X6_TIPO		,;
                                            AllTrim(SX6->X6_CONTEUD)		,; 
                                            SX6->X6_DESCRIC		,; 
                                            SX6->X6_DESC1		,;
                                            SX6->X6_DESC2 		,;
                                            aParSX6[Nx][08],;
                                            cValid,;
                                            aOpc,;
                                            cF3} )

                    EndIf
                    
                Next Ny		
            Next Nx	
        EndIf 

	ElseIf xType == 2

		SX6->(DbGoTop())
		While SX6->(!Eof())		
			If &(cFilParam)
				AADD(aListPar,{	SX6->X6_PROPRI		,;
									SX6->X6_FIL		,;
									SX6->X6_VAR		,; 
									SX6->X6_TIPO	,;
									SX6->X6_CONTEUD	,; 
									SX6->X6_DESCRIC	,; 
									SX6->X6_DESC1	,;
									SX6->X6_DESC2 	,;
									"",;
									"",;
                                    {},;
                                    ""} )
			EndIf		
			SX6->(DbSkip())		
		EndDo	

	EndIf
	
Return( aRet )                   

//-------------------------------------------------------------------
/*/{Protheus.doc} xLoadXml
Carrega um objeto a partir de um xml
@author Roberto Souza
@since 24/04/2018
@version 1.0 

@aParam	

@return Nil
/*/
//-------------------------------------------------------------------
Static Function xLoadXml( cModel )

	Local oRet 		:= Nil
	Local cError	:= ""
	Local cWarning	:= ""
	Local cXml      := ""
	
	If File( cModel+".xml" ) 	
		cXml := MemoRead( cModel+".xml")
	Else

		cXml +='<?xml version = "1.0" encoding = "UTF-8"?>'
		cXml +='<Main>'
		cXml +='<tafpansx6 version="1.00">'
		cXml +='	<paramdef>'
		cXml +='		<par>'
		cXml +='			<X6_PROPRI>S</X6_PROPRI>'
		cXml +='			<X6_FIL></X6_FIL>'
		cXml +='			<X6_VAR>MV_TAFSURL</X6_VAR>'
		cXml +='			<X6_TIPO>C</X6_TIPO>'
		cXml +='			<X6_CONTEUD>http://localhost:8080/</X6_CONTEUD>'
		cXml +='			<X6_DESCRIC>URL do TSS para comunicação do TAF</X6_DESCRIC>'
		cXml +='			<X6_DESC1>URL do TSS para comunicação do TAF</X6_DESC1>'
		cXml +='			<X6_DESC2>URL do TSS para comunicação do TAF</X6_DESC2>'
		cXml +='			<X6_VALID>!Empty(MV_TAFURL)</X6_VALID>'			
		cXml +='			<X6_HELP>Endereço de configuração para uso da comunicação com o governo e transmissão dos eventos</X6_HELP>'			
		cXml +='		</par>'
		cXml +='		<par>'		
		cXml +='			<X6_PROPRI>S</X6_PROPRI>'
		cXml +='			<X6_FIL></X6_FIL>'
		cXml +='			<X6_VAR>MV_TAFAMB</X6_VAR>'
		cXml +='			<X6_TIPO>C</X6_TIPO>'
		cXml +='			<X6_CONTEUD>2</X6_CONTEUD>'
		cXml +='			<X6_DESCRIC>URL do TSS para comunicação do TAF</X6_DESCRIC>'
		cXml +='			<X6_DESC1>URL do TSS para comunicação do TAF</X6_DESC1>'
		cXml +='			<X6_DESC2>URL do TSS para comunicação do TAF</X6_DESC2>'
		cXml +='			<X6_VALID>Vazio() .Or. cValToChar(xConteud) $"123"</X6_VALID>'			
		cXml +='			<X6_HELP>Ambiente de configuração para uso da comunicação com o governo e transmissão dos eventos</X6_HELP>'	
		cXml +='			<X6_OPC>'
		cXml +='				<opc>1-Produção</opc>'
		cXml +='				<opc>2-Pré Produção</opc>'
		cXml +='				<opc>3-Pré Produção</opc>'	
		cXml +='			</X6_OPC>'
		cXml +='		</par>'
		cXml +='		<par>'		
		cXml +='			<X6_PROPRI>S</X6_PROPRI>'
		cXml +='			<X6_FIL></X6_FIL>'
		cXml +='			<X6_VAR>MV_TAFAMBE</X6_VAR>'
		cXml +='			<X6_TIPO>C</X6_TIPO>'
		cXml +='			<X6_CONTEUD>2</X6_CONTEUD>'
		cXml +='			<X6_DESCRIC>URL do TSS para comunicação do TAF</X6_DESCRIC>'
		cXml +='			<X6_DESC1>URL do TSS para comunicação do TAF</X6_DESC1>'
		cXml +='			<X6_DESC2>URL do TSS para comunicação do TAF</X6_DESC2>'			
		cXml +='			<X6_VALID>Vazio() .Or. cValToChar(xConteud) $"123"</X6_VALID>'			
		cXml +='			<X6_HELP>Ambiente de configuração para uso da comunicação com o governo e transmissão dos eventos</X6_HELP>'	
		cXml +='			<X6_OPC>'
		cXml +='				<opc>1-Produção</opc>'
		cXml +='				<opc>2-Pré Produção</opc>'
		cXml +='				<opc>3-Pré Produção</opc>'	
		cXml +='			</X6_OPC>'
		cXml +='		</par>'
		cXml +='		<par>'		
		cXml +='			<X6_PROPRI>S</X6_PROPRI>'
		cXml +='			<X6_FIL></X6_FIL>'
		cXml +='			<X6_VAR>MV_TAFUF</X6_VAR>'
		cXml +='			<X6_TIPO>C</X6_TIPO>'
		cXml +='			<X6_CONTEUD>2</X6_CONTEUD>'
		cXml +='			<X6_DESCRIC></X6_DESCRIC>'
		cXml +='			<X6_DESC1></X6_DESC1>'
		cXml +='			<X6_DESC2></X6_DESC2>'			
		cXml +='			<X6_VALID>Vazio() .Or. Len(xConteud) > 10</X6_VALID>'			
		cXml +='			<X6_HELP>UF de uso do TAF</X6_HELP>'	
		cXml +='			<X6_F3>12</X6_F3>'	
		cXml +='		</par>'
		cXml +='	</paramdef>'
		cXml +='</tafpansx6>'
		cXml +='</Main>'	

	EndIf	

	oRet := XmlParser( cXml, "_", @cError, @cWarning )
	
Return( oRet )

//-------------------------------------------------------------------
/*/{Protheus.doc} TafLegPar
Legenda do Grid
@author Roberto Souza
@since 24/04/2018
@version 1.0 

@aParam	

@return Nil
/*/
//-------------------------------------------------------------------
Static Function TafLegPar()

	Local aLegenda as array

	aLegenda := {}

	AADD(aLegenda,{ LegAccMode( "BR_VERDE" ) 	,STR0026 }) //"Parametro de Usuário"
	AADD(aLegenda,{ LegAccMode( "BR_VERMELHO" ) ,STR0027 }) //"Parametro de Sistema"
	
	BrwLegenda(STR0005, STR0018, aLegenda) // Legenda

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} TafxparLd
Carrega os parametros de acordo com o proprietario.
@author Roberto Souza
@since 24/04/2018
@version 1.0 

@aParam	cOwner	0-Todos
				1-Fiscal
				2-eSocial
				3-ECF
				4-Autocontidas
				5-Reinf
@return Nil
/*/
//-------------------------------------------------------------------
Function TafxparLd( cOwner )

	Local aFullPar := {}
	
	Default cOwner := 0
	/*	Posições
		01 - Propriedade - Sistema/Usuario
		02 - Filial Default
		03 - Parametro
		04 - Tipo
		05 - Conteudo Default
		06 - Descrição default
		07 - Validação do preenchimento
		08 - Help adicional
		09 - Combo de opções(Array)
		10 - Consulta F3
		11 - Botão (Teste do Parametro)
	*/	
	If "0" $ cOwner .Or. "5" $ cOwner
		AADD(aFullPar,	{;
			"S"			,;
			""			,;
			"MV_TAFAMBR",;
			"C"			,;
			"2"			,;
			"Identificacao do ambiente do Reinf: 1 - Producao; 2 - Producao Restrita - Dados Reais;",;
			"",;
			"Ambiente de configuração para uso da comunicação com o governo e transmissão dos eventos",;
			{"1-Produção","2-Pré Produção - Dados reais"} ,;
			""} )
		AADD(aFullPar,	{;
			"S"			,;
			""			,;
			"MV_TAFVLRE",;
			"C"			,;
			"2"			,;
			"Versao do Layout Reinf. Utilizado para a criacao do nameSpace dos eventos e validacoes de estrutura no modulo SIGATAF." ,;
			"NaoVazio()",;
			"Layout de transmissão. Ex.: 1_03_02 ",;
			,;
			""} )
		AADD(aFullPar,	{;
			"S"			,;
			""			,;
			"MV_TAFRVLD",;
			"C"			,;
			"S"			,;
			"Informa se a validação do governo para regras de eventos da Reinf bloqueia a apuração. Ex.: S=Sim ; N=Não." ,;
			"NaoVazio()",;
			"Informa a opção por validar/barrar o evento na apuração, impedindo a geração do próprio evento, prevendo a rejeição do governo das inconsistências ",;
			{"S-Sim","N-Não"} ,;
			""} )
		If GetMV("MV_2050TRB", .T.)
			AADD(aFullPar,	{;
				"S"			,;
				""			,;
				"MV_2050TRB",;
				"C"			,;
				" "			,;
				"Informe os tributos que devem ser abatidos do valor contábil." ,;
				" ",;
				"1 - IPI",;
				,;
				""} )
		EndIf
	EndIf		
	
	If "0" $ cOwner .Or. "5" $ cOwner .Or. "2" $ cOwner 
		AADD(aFullPar,	{;
			"S"			,;
			""			,;
			"MV_TAFSURL",;
			"C"			,;
			"http://"			,;
			"URL de comunicacao com o TSS no produto TAF .",;
			"Len(xConteud) > 11",;
			"Ambiente de configuração para uso da comunicação com o governo e transmissão dos eventos",;
			,;
			""} )
	EndIf

	ASORT(aFullPar, , , { | x,y | x[2] > y[2] .And. x[3] > y[3]} )

Return( aFullPar )
