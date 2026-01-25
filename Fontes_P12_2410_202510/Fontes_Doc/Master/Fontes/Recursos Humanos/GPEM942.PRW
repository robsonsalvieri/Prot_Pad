#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "GPEM942.CH"


/*/{Protheus.doc} GPEM942
Migração dos dados de Processos Trabalhistas leiaute S-1.2 para S-1.3
@since	30/09/2024
@autor	raquel.andrade
@version P12
/*/
Function GPEM942()
Local aArea			:= GetArea()
Local aAreaE0E		:= E0E->( GetArea() )
Local aAreaE0F		:= E0F->( GetArea() )
Local aColsMark		:= {}
Local cIdCab
Local cIdGrid
Local cFilAux		:= cFilAnt
Local lMarcar		:= .F.
Local oPanelUp
Local oTela
Local oPanelDown
Local oGroup
LOcal oFont
Local aAdvSize		:= {}
Local aInfoAdvSize	:= {}
Local aObjSize		:= {}
Local aObjCoords	:= {}
Local bMigra		:= .F.
Local bSetMigra		:= {|| fSelME0E(oMark:Mark()), oMark:Refresh(.T.) }
Local aStrE0E1 	:= FWSX3Util():GetFieldStruct( "E0E_FILIAL" ) 
Local aStrE0E2 	:= FWSX3Util():GetFieldStruct( "E0E_PRONUM" ) 
Local aStrRE0 	:= FWSX3Util():GetFieldStruct( "RE0_PROJUD" ) 
Local aStrE0E3 	:= FWSX3Util():GetFieldStruct( "E0E_PERAP" ) 

Private aRotMark   	:= {}
Private aRotMigr   	:= {}
Private cFilE0E		:= Space( aStrE0E1[3] )
Private cProcE0E	:= Space( aStrE0E2[3] )
Private cNrE0E		:= Space( aStrRE0[3] )
Private cPerApE0E	:= Space( aStrE0E3[3] )
Private cAliasMark 	:= "TABAUX"
Private oMark
Private oDlgMark	:= Nil
Private oTmpTable   := Nil

	bMigra := {|| GPM942IniProc() }

	// Valida se dicionário está atualizado
	If !fChkE0H()
		Return
	Else
		fTmpE0E()
	EndIf

	DbSelectArea(cAliasMark)

	SET FILTER TO TAB_PRONUM == ''

	aColsMark:= fMntColsME0E()

	aAdvSize	:= MsAdvSize()
	aInfoAdvSize	:= { aAdvSize[1] , aAdvSize[2] , aAdvSize[3] , aAdvSize[4] , 10 , 5 }
	aAdd( aObjCoords , { 000 , 000 , .T. , .T. } )
	aObjSize	:= MsObjSize( aInfoAdvSize , aObjCoords )

	Define MsDialog oDlgMark FROM aAdvSize[7], 0 To aAdvSize[6], aAdvSize[5] Title STR0003 Pixel  //"Migrador Tributos do Processo Trabalhista para leiaute S-1.3" 

	// Cria o conteiner onde serão colocados os paineis
	oTela     := FWFormContainer():New( oDlgMark )
	cIdCab	  := oTela:CreateHorizontalBox( 13 )
	cIdGrid   := oTela:CreateHorizontalBox( 80 )

	oTela:Activate( oDlgMark, .F. )

	//Cria os paineis onde serao colocados os browses
	oPanelUp  	:= oTela:GeTPanel( cIdCab )
	oPanelDown  := oTela:GeTPanel( cIdGrid )

		@ 3 , 3	GROUP oGroup TO (aObjSize[1,1]*0.5)+18, aObjSize[1,4] LABEL OemToAnsi(STR0004) OF oPanelUp PIXEL	// "Filtro"
		oGroup:oFont:=oFont

		@ aObjSize[1,1]*0.4, aObjSize[1,2]+1 		SAY   OemToAnsi(STR0005) SIZE 068,007 OF oPanelUp PIXEL // "Filial do Processo"
		@ (aObjSize[1,1]*0.4)+6, aObjSize[1,2]+1 	MSGET cFilE0E  PICTURE "@!" SIZE 068,007	OF oPanelUp PIXEL WHEN  F3 'FWSM0' HASBUTTON VALID Gp942VldMark(.T.)

		@ aObjSize[1,1]*0.4, aObjSize[1,2]+80 		SAY   OemToAnsi(STR0006) SIZE 068,007 OF oPanelUp PIXEL // "Código do Processo"
		@ (aObjSize[1,1]*0.4)+6, aObjSize[1,2]+80 	MSGET cProcE0E  PICTURE "@!" SIZE 020,007	OF oPanelUp PIXEL WHEN  F3 "RE0C" HASBUTTON VALID Gp942VldMark()

		@ aObjSize[1,1]*0.4	, aObjSize[1,2]+160 	SAY   OemToAnsi(STR0014) SIZE 068,007 OF oPanelUp PIXEL // "Número do Processo" 
		@ (aObjSize[1,1]*0.4)+6, aObjSize[1,2]+160	MSGET cNrE0E PICTURE "@!" SIZE 098,007	OF oPanelUp PIXEL WHEN  F3 "RE0P" HASBUTTON VALID Gp942VldMark()

		@ aObjSize[1,1]*0.4	, aObjSize[1,2]+270		SAY   OemToAnsi(STR0015) SIZE 068,007 OF oPanelUp PIXEL // "Período de Apuração" 
		@ (aObjSize[1,1]*0.4)+6, aObjSize[1,2]+270	MSGET cPerApE0E  PICTURE "@!" SIZE 020,007	OF oPanelUp PIXEL F3 "E0EP" HASBUTTON VALID Gp942VldMark()

	oMark := FWMarkBrowse():New()

	oMark:SetAlias((cAliasMark))
	oMark:SetFields(aColsMark)

	// Indica o container onde sera criado o browse
	oMark:SetOwner(oPanelDown)

	oMark:bAllMark := { || fStMaE0E(oMark:Mark(),lMarcar := !lMarcar ), oMark:Refresh(.T.)  }

	// Define o campo que sera utilizado para a marcação
	oMark:SetFieldMark( 'TAB_OK')
	oMark:SetValid({||.T.})
	oMark:AddButton(OemToAnsi(STR0007), bMigra,,,, .F., 2 ) 	// 	"Migrar"  	
	oMark:AddButton(OemToAnsi(STR0008), bSetMigra,,,, .F., 2 ) //	"Apenas Aptos a Migrar"
	oMark:SetMenuDef("GPEM942")

	oMark:AddLegend( "Empty(TAB_INTEG)",  "GREEN", OemToAnsi(STR0009) ) // "Apto a migrar"  
	oMark:AddLegend( "!Empty(TAB_INTEG)", "RED" , OemToAnsi(STR0010) ) 	// "Migrado"  

	oMark:Activate()
	Gp942VldMark()

	ACTIVATE MSDIALOG oDlgMark CENTERED

	oTmpTable:Delete()
	oTmpTable := Nil

	// Retorna a filial para a que estava logada antes da execução da rotina
	cFilAnt := cFilAux
	RestArea(aAreaE0E)
	RestArea(aAreaE0F)
	RestArea(aArea)

Return Nil


/*/{Protheus.doc} GPM942IniProc
Inicia a migração.
@author raquel.andrade
@since 30/09/2024
@version 1.0
/*/
Static Function GPM942IniProc()
Local bProcesso		:= {|oSelf| GPM942Processa(oSelf)}
Local cCadastro 	:= OemToAnsi( STR0003 ) // "Migrador Tributos do Processo Trabalhista para leiaute S-1.3"
Local cDescricao	:= OemToAnsi( STR0023 ) // "Este programa efetuará a migração dos Processos previamente marcados." 
Local cMarca 		:= oMark:Mark()
Local lMigrado		:= .F.
Local lProcessa		:= .F.
Local nM			:= 0

Private aTitle 		:= {}
Private aLog   		:= {}
Private aLogError	:= {}
Private cErroMsg	:= ""
Private cProcessId	:= ""
Private cPerApurPg	:= ""
Private cCpfTrab	:= ""
Private	cIdSqPrOld	:= cValToChar(-1)

	(cAliasMark)->(DbSelectArea(cAliasMark))
	(cAliasMark)->(DbGoTop())

	While (cAliasMark)->(!Eof())
		If oMark:IsMark(cMarca)
			If Empty((cAliasMark)->TAB_INTEG)  // Vazio-Apto a Migrar, 1-Migrado
				aAdd(aRotMark,{cEmpAnt, (cAliasMark)->TAB_FIL, (cAliasMark)->TAB_PRONUM,(cAliasMark)->TAB_PROJUD,(cAliasMark)->TAB_PERAP,(cAliasMark)->TAB_CPF})
			Else
				aAdd(aRotMigr,{cEmpAnt, (cAliasMark)->TAB_FIL, (cAliasMark)->TAB_PRONUM,(cAliasMark)->TAB_PROJUD,(cAliasMark)->TAB_PERAP,(cAliasMark)->TAB_CPF})				
				lMigrado 	:= .T.	
			EndIf
		EndIf
		(cAliasMark)->(DbSkip())
	EndDo
	(cAliasMark)->(DbGoTop())

	If Empty(aRotMark) .And. Empty(aRotMigr)
		Help( ,, OemToAnsi(STR0002),, OemToAnsi(STR0024), 1, 0) // "Atenção"###"Nenhum Processo selecionado."
		oMark:Refresh() 
		Gp942VldMark()
	ElseIf lMigrado 
		// "Atenção"###"Foram marcados Processos que já foram migrados, tem certeza que deseja migrar novamente e sobrepor os registros?"
		If !MsgYesNo( OemToAnsi( STR0030 ), OemToAnsi( STR0002 ) )			
			oMark:Refresh() 
			Gp942VldMark()
		Else
			For nM := 1 to Len(aRotMigr)
				aAdd(aRotMark,aRotMigr[Nm])
			Next nM
			lProcessa := .T.
		EndIf
	Else
		lProcessa := .T.
	EndIf

	If lProcessa 	
		tNewProcess():New( "GPEM942" , cCadastro , bProcesso , cDescricao , "",,,,,.T.)				
	EndIf	

Return Nil

/*/{Protheus.doc} GPM942Processa
Migra os Processos Marcados.
@author raquel.andrade
@since 30/09/2024
@version 1.0
/*/
Static Function GPM942Processa(oSelf)
Local lIntOk		:= .T.
Local lLog			:= .F.
Local nPos1			:= 0 
Local nPos2			:= 0 
Local cMsgLog		:= ""

	oSelf:SetRegua1(Len(aRotMark))
	oSelf:SaveLog( STR0003 + " - " + STR0031) //"Migrador Tributos do Processo Trabalhista para Leiaute S-1.3"##"Inicio do processamento"

	For nPos1 := 1 to Len(aRotMark)
		
		oSelf:IncRegua1(aRotMark[nPos1,1] + "/" + aRotMark[nPos1,2] + "/" + aRotMark[nPos1,3] + " - " + aRotMark[nPos1,4]  + " - " + aRotMark[nPos1,5])

		cProcessId	:= aRotMark[nPos1,4]
		cPerApurPg	:= aRotMark[nPos1,5]
		cCpfTrab	:= aRotMark[nPos1,6]
		cErroMsg	:= ""	
		
		lIntOk := fMigra2501(aRotMark[nPos1,2], @cErroMsg )			

		If !lIntOk 
			lLog	:= .T.
			aAdd( aLogError, {} )
			If !Empty(cErroMsg)
				cMsgLog	:=  aRotMark[nPos1,1] + "/" + aRotMark[nPos1,2] + " - " + aRotMark[nPos1,3]  + " - " + aRotMark[nPos1,5] + " - " + cErroMsg
			Else
				cMsgLog	:=  aRotMark[nPos1,1] + "/" + aRotMark[nPos1,2] + " - " + aRotMark[nPos1,3]  + " - " + aRotMark[nPos1,5]
			EndIf
			aAdd( aLogError[Len(aLogError)],  cMsgLog )
			Loop
		Else
			fUpdTab(aRotMark[nPos1,2],aRotMark[nPos1,3],aRotMark[nPos1,4],aRotMark[nPos1,5])
		EndIf	

	Next nPos1

	oSelf:SaveLog( STR0026 + " - " + STR0027) // "Migração dos Tributos do Processo para o Leiaute S-1.3"##"Fim do processamento"

	// Apresenta com Log de Ocorrências
	If lLog	
		aAdd( aTitle, STR0026 )	// "Log de Ocorrências"
		aAdd( aLog, {} )
		aAdd( aLog[Len(aLog)],  OemToAnsi(STR0029)) // "Falha na Migração - Verifique o(s) item(s) abaixo:"
		For nPos2 := 1 to Len(aLogError)
			aAdd( aLog, aLogError[nPos2] )
		Next nPos2
		aAdd( aLog, aLogError )
		fMakeLog(aLog,aTitle,,,"GPEM942",STR0028,"M","P",,.F.)  // "Log de Ocorrências"
	Else		
		MsgInfo(OemToAnsi(STR0025), OemToAnsi(STR0001))  // "Migração realizada com sucesso!"###"Aviso"
	EndIf

	aRotMark 	:= {}
	aRotMigr	:= {}
	aTitle 		:= {}	
	aLog   		:= {}	
	oMark:Refresh() 
	Gp942VldMark()

Return Nil

/*/{Protheus.doc} fTmpE0E
Cria tabela temporaria para uso no FWMarkBrowse.
@author raquel.andrade
@since 30/09/2024
@version 1.0
/*/
Static Function fTmpE0E()
Local aColumns	 	:= {}
Local aStrE0E1 		:= {}
Local aStrE0E2 		:= {}
Local aStrE0E3 		:= {} 
Local aStrRE01 		:= {}
Local aStrRE02 		:= {}
Local aStrRD0 		:= {}
Local cQuery	 	:= ''
Local cKeyAux	 	:= ''
Local cAliasE0E	 	:= 'QE0E'
Local cAcessaE0E 	:=  &( " { || " + IF( Empty( cAcessaE0E := ChkRH( "GPEM942" , "E0E" , "2" ) ) , ".T." , cAcessaE0E ) + " } " )
Local lRet			:= .F.

Static __oSt1
Static __cEmpAux

	aStrE0E1 	:= FWSX3Util():GetFieldStruct( "E0E_FILIAL" ) 
	aStrE0E2 	:= FWSX3Util():GetFieldStruct( "E0E_PRONUM" ) 
	aStrE0E3 	:= FWSX3Util():GetFieldStruct( "E0E_PERAP" ) 
	aStrRE01 	:= FWSX3Util():GetFieldStruct( "RE0_DESCR" ) 
	aStrRE02 	:= FWSX3Util():GetFieldStruct( "RE0_PROJUD" ) 
	aStrRD0 	:= FWSX3Util():GetFieldStruct( "RD0_CIC" ) 

	aAdd( aColumns, { "TAB_OK"			,"C",02,00 })
	aAdd( aColumns, { "TAB_FIL"			,"C",aStrE0E1[3], aStrE0E1[4]})
	aAdd( aColumns, { "TAB_PRONUM"		,"C",aStrE0E2[3], aStrE0E2[4]})
	aAdd( aColumns, { "TAB_DESCR"		,"C",aStrRE01[3], aStrRE01[4]})
	aAdd( aColumns, { "TAB_PROJUD"		,"C",aStrRE02[3], aStrRE02[4]})
	aAdd( aColumns, { "TAB_PERAP"		,"C",aStrE0E3[3], aStrE0E3[4]})
	aAdd( aColumns, { "TAB_INTEG"		,"C",01,00})
	aAdd( aColumns, { "TAB_CPF"			,"C",aStrRD0[3], aStrRD0[4]})

	oTmpTable := FWTemporaryTable():New(cAliasMark)
	oTmpTable:SetFields( aColumns )
	oTmpTable:AddIndex( "IND", { "TAB_FIL", "TAB_PRONUM","TAB_PROJUD","TAB_PERAP"} )
	oTmpTable:Create()

	If __oSt1 == Nil .or. ( __cEmpAux == Nil .or. __cEmpAux <> cEmpAnt )

		__cEmpAux := cEmpAnt

		__oSt1 := FWPreparedStatement():New()

		cQuery := "SELECT DISTINCT E0E.E0E_FILIAL, E0E.E0E_PRONUM, E0E.E0E_RECLAM, E0E.E0E_PERAP, RE0.RE0_NUM, "
		cQuery += " RE0.RE0_PROJUD, RE0.RE0_DESCR, E0H.E0H_PRONUM , RD0.RD0_CIC"
		cQuery += "FROM " + RetSqlName('E0E')  + " E0E "
		cQuery += "INNER JOIN " + RetSqlName('RE0') + " RE0 ON " + FwJoinFilial("E0E","RE0") + " AND E0E.E0E_PRONUM = RE0.RE0_NUM "
		cQuery += "LEFT JOIN " + RetSqlName('RD0') + " RD0 ON " + FwJoinFilial("E0E","RD0") + " AND E0E.E0E_RECLAM = RD0.RD0_CODIGO "
		cQuery += "LEFT JOIN " + RetSqlName('E0H') + " E0H ON " + FwJoinFilial("E0E","E0H") + " AND E0E.E0E_PRONUM = E0H.E0H_PRONUM AND E0E.E0E_PERAP = E0H.E0H_PERAP"
		cQuery += "WHERE RE0.D_E_L_E_T_ = ? AND "
		cQuery += "RD0.D_E_L_E_T_ = ?  "
		cQuery += "AND (E0H.D_E_L_E_T_ = ? OR E0H.D_E_L_E_T_ IS NULL)"
		cQuery := ChangeQuery(cQuery)

		__oSt1:SetQuery(cQuery)

	EndIf

	__oSt1:SetString(1,' ')
	__oSt1:SetString(2,' ')	
	__oSt1:SetString(3,' ')
	
	cQuery := __oSt1:getFixQuery()

	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasE0E)

	DbSelectArea(cAliasE0E) 	// QE0E
	DbSelectArea(cAliasMark) 	// TABAUX

	While (cAliasE0E)->(!Eof())
		If cKeyAux <> (cAliasE0E)->(E0E_FILIAL+E0E_PRONUM+E0E_RECLAM+E0E_PERAP)

			cKeyAux := (cAliasE0E)->(E0E_FILIAL+E0E_PRONUM+E0E_RECLAM+E0E_PERAP)
			E0E->(dbSeek(cKeyAux))
			If ( !(Empty((cAliasE0E)->E0E_FILIAL)) .And. !(AllTrim((cAliasE0E)->E0E_FILIAL) $ fValidFil()) ) .Or. !Eval( cAcessaE0E )
				(cAliasE0E)->(DbSkip())
				Loop
			EndIf

			lRet := .T.

			RecLock(cAliasMark,.T.)

			(cAliasMark)->TAB_FIL 		:= (cAliasE0E)->E0E_FILIAL
			(cAliasMark)->TAB_PRONUM 	:= (cAliasE0E)->E0E_PRONUM
			(cAliasMark)->TAB_DESCR 	:= (cAliasE0E)->RE0_DESCR
			(cAliasMark)->TAB_PROJUD	:= (cAliasE0E)->RE0_PROJUD
			(cAliasMark)->TAB_PERAP		:= (cAliasE0E)->E0E_PERAP
			(cAliasMark)->TAB_INTEG		:= If (!Empty((cAliasE0E)->E0H_PRONUM), "1","") // Vazio-Apto a Migrar, 1-Migrado
			(cAliasMark)->TAB_CPF		:= (cAliasE0E)->RD0_CIC

			MsUnLock()
		EndIf

		(cAliasE0E)->(DbSkip())

	EndDo

	( cAliasE0E )->( dbCloseArea() )

Return lRet


/*/{Protheus.doc} fMntColsME0E
Monta dados dos campos da tabela temporaria.
@since	30/09/2024
@autor	raquel.andrade
@version P12
/*/
Static Function fMntColsME0E()
Local aArea		:= GetArea()
Local aColsAux 	:= {}
Local aColsSX3	:= {}
Local aStruct	:= {}
Local aCampos  	:= {"E0E_FILIAL","E0E_PRONUM","RE0_DESCR","RE0_PROJUD","E0E_PERAP"}
Local aDados	:= {{||(cAliasMark)->TAB_FIL},{||(cAliasMark)->TAB_PRONUM},{||(cAliasMark)->TAB_DESCR},{||(cAliasMark)->TAB_PROJUD},{||(cAliasMark)->TAB_PERAP}}
Local nX		:= 0
Local cTitulo	:= ""

DbSelectArea("SX3")
DbSetOrder(2)

For nX := 1 to Len(aCampos)
	aStruct := FWSX3Util():GetFieldStruct( aCampos[nX] )
	Do Case
		Case ( aCampos[nX] == "E0E_FILIAL" ) 	; ( cTitulo := OemToAnsi(STR0022) )	// "Filial"
		Case ( aCampos[nX] == "E0E_PRONUM" ) 	; ( cTitulo := OemToAnsi(STR0019) )	// "Código"
		Case ( aCampos[nX] == "RE0_DESCR" ) 	; ( cTitulo := OemToAnsi(STR0018) )	//" Descrição"
		Case ( aCampos[nX] == "RE0_PROJUD" ) 	; ( cTitulo := OemToAnsi(STR0020) )	// "Número"
		Case ( aCampos[nX] == "E0E_PERAP" ) 	; ( cTitulo := OemToAnsi(STR0021) )	// "Per.de Apuração"
	End Case
	aColsSX3 := {cTitulo,aDados[nX], aStruct[2] /*Tipo*/, aStruct[5] /*Picture*/,1,aStruct[3] /*Tamanho*/,aStruct[4]/*Decimal*/,.F.,,,,,,,,1}
	aAdd(aColsAux,aColsSX3)
	aColsSX3 := {}
Next nX

RestArea(aArea)

Return aColsAux


/*/{Protheus.doc} fStMaE0E
Marca/desmarca todos os itens.
@since	30/09/2024
@autor	raquel.andrade
@version P12
/*/
Static Function fStMaE0E(cMarca,lMarcar)
Local aAreaMark  := (cAliasMark)->( GetArea() )

Default cMarca	:= ""
Default lMarcar	:= .F.

	dbSelectArea(cAliasMark)
	(cAliasMark)->( dbGoTop() )

	While !(cAliasMark)->( Eof() )
		RecLock( (cAliasMark), .F. )
		(cAliasMark)->TAB_OK := IIf( lMarcar .and. Empty((cAliasMark)->TAB_INTEG), cMarca, '  ' )
		MsUnLock()
		(cAliasMark)->( dbSkip() )
	EndDo

	RestArea( aAreaMark )

Return .T.

/*/{Protheus.doc} fUpdTab
Atualiza dados da tabela temporária.
@since	30/09/2024
@autor	raquel.andrade
@version P12
/*/
Static Function fUpdTab(cFilAux,cProcAux,cProjAux,cPerApAux)
Local aArea		 := GetArea()
Local aAreaMark  := (cAliasMark)->( GetArea() )

Default cFilAux		:= ""
Default cProcAux	:= ""
Default cProjAux	:= ""
Default cPerApAux	:= ""

	dbSelectArea(cAliasMark)
	(cAliasMark)->( dbGoTop() )
	While !(cAliasMark)->( Eof() )
		If (cAliasMark)->TAB_FIL == cFilAux .And. (cAliasMark)->TAB_PRONUM == cProcAux .And. (cAliasMark)->TAB_PROJUD == cProjAux .And. (cAliasMark)->TAB_PERAP == cPerApAux 
			RecLock( (cAliasMark), .F. )
			(cAliasMark)->TAB_INTEG := "1"
			MsUnLock()
		EndIf
		(cAliasMark)->( dbSkip() )
	EndDo

	RestArea( aAreaMark )
	RestArea(aArea)

Return .T.


/*/{Protheus.doc} Gp942VldMark
Valida seleção dos dados de filtro.
@since	30/09/2024
@autor	raquel.andrade
@version P12
/*/
Static Function Gp942VldMark(lAtuFil)
Default lAtuFil := .F.

	If lAtuFil .And. !Empty(cFilE0E)
		cFilE0E := xFilial("E0E",cFilE0E) 
	EndIf

	DbSelectArea(cAliasMark)
	SET FILTER TO

	oMark:Refresh()

	DbSelectArea(cAliasMark)
	
	If Empty(cFilE0E)
		// Todos Preenchidos
		If !Empty(cProcE0E) .And. !Empty(cNrE0E) .and. !Empty(cPerApE0E) 
			SET FILTER TO TAB_PRONUM == cProcE0E .And.  TAB_PROJUD ==  cNrE0E .And. TAB_PERAP == cPerApE0E 		
		// Código Processo em Branco
		ElseIf Empty(cProcE0E) .And. !Empty(cNrE0E) .and. !Empty(cPerApE0E) 
			SET FILTER TO TAB_PROJUD ==  cNrE0E .And. TAB_PERAP == cPerApE0E 		
		// Número do Processo em Branco
		ElseIf !Empty(cProcE0E) .And. Empty(cNrE0E) .And. !Empty(cPerApE0E) 
			SET FILTER TO TAB_PRONUM == cProcE0E .And. TAB_PERAP == cPerApE0E 
		// Período de Apuração em Branco
		ElseIf !Empty(cProcE0E) .And. !Empty(cNrE0E) .And. Empty(cPerApE0E) 
		 	SET FILTER TO TAB_PRONUM == cProcE0E .And.  TAB_PROJUD ==  cNrE0E
		// Código e Número em Branco
		ElseIf Empty(cProcE0E) .And. Empty(cNrE0E) .And. !Empty(cPerApE0E) 
			SET FILTER TO  TAB_PERAP == cPerApE0E		
		// Código e Período de Apuração em Branco
		ElseIf Empty(cProcE0E) .And. !Empty(cNrE0E) .And. Empty(cPerApE0E) 
			SET FILTER TO TAB_PROJUD ==  cNrE0E			
		// Número do Processo e Período de Apuração em Branco
		ElseIf !Empty(cProcE0E) .And. Empty(cNrE0E) .And. Empty(cPerApE0E) 
			SET FILTER TO TAB_PRONUM == cProcE0E 
		// Todos em branco
		ElseIf Empty(cProcE0E) .And. Empty(cNrE0E) .And. Empty(cPerApE0E) 
			SET FILTER TO TAB_PRONUM == ''
		EndIf
	Else
		// Todos Preenchidos
		If !Empty(cProcE0E) .And. !Empty(cNrE0E) .And. !Empty(cPerApE0E)
			SET FILTER TO TAB_FIL == cFilE0E .And. TAB_PRONUM == cProcE0E .And.  TAB_PROJUD ==  cNrE0E .And. TAB_PERAP ==cPerApE0E 
		// Código Processo em Branco
		ElseIf Empty(cProcE0E) .and. !Empty(cNrE0E) .and. !Empty(cPerApE0E)
			SET FILTER TO TAB_FIL == cFilE0E .And. TAB_PROJUD ==  cNrE0E  .And. TAB_PERAP == cPerApE0E 
		// Número de Processo em Branco
		ElseIf !Empty(cProcE0E) .And. Empty(cNrE0E) .And. !Empty(cPerApE0E)
		 	SET FILTER TO TAB_FIL == cFilE0E .And. TAB_PRONUM == cProcE0E .And.  TAB_PERAP ==cPerApE0E
		// Período de Apuração em Branco
		ElseIf !Empty(cProcE0E) .And. !Empty(cNrE0E) .And. Empty(cPerApE0E)
			SET FILTER TO TAB_FIL == cFilE0E .And. TAB_PRONUM == cProcE0E .And.  TAB_PROJUD ==  cNrE0E 
		// Código e Número em Branco
		ElseIf Empty(cProcE0E) .and. Empty(cNrE0E) .and. !Empty(cPerApE0E)
			SET FILTER TO TAB_FIL == cFilE0E .And. TAB_PERAP == cPerApE0E 
		// Código e Período de Apuração em Branco
		ElseIf Empty(cProcE0E) .and. !Empty(cNrE0E) .and. Empty(cPerApE0E)
			SET FILTER TO TAB_FIL == cFilE0E .And. TAB_PROJUD ==  cNrE0E 
		// Número e Período de Apuração em Branco 
		ElseIf !Empty(cProcE0E) .and. Empty(cNrE0E) .and. Empty(cPerApE0E)
			SET FILTER TO TAB_FIL == cFilE0E .And. TAB_PRONUM == cProcE0E 
		// Todos em Braco
		ElseIf Empty(cProcE0E) .and. Empty(cNrE0E) .and. Empty(cPerApE0E)
			SET FILTER TO TAB_FIL == cFilE0E 
		EndIf
	EndIf

	oMark:GoTop(.T.)
	oMark:Refresh()

Return .T.


/*/{Protheus.doc} MenuDef
Menu Funcional - declarado apenas para validações internas.
@since	30/09/2024
@autor	raquel.andrade
@version P12
/*/
Static Function MenuDef()
Return {}


/*/{Protheus.doc} fSelME0E
Seleciona apenas os Processos Aptos a Migrar.
@since	30/09/2024
@autor	raquel.andrade
@version P12
/*/
Static Function fSelME0E( cMarca )
Local aAreaMark  := (cAliasMark)->( GetArea() )

Default cMarca	:= ""

	dbSelectArea(cAliasMark)
	(cAliasMark)->( dbGoTop() )
	While !(cAliasMark)->( Eof() )
		If RecLock( (cAliasMark), .F. )
			(cAliasMark)->TAB_OK := IIf( Empty((cAliasMark)->TAB_INTEG), cMarca, '  ' )
			MsUnLock()
		EndIf
		(cAliasMark)->( dbSkip() )
	EndDo

	RestArea( aAreaMark )

Return .T.


/*/{Protheus.doc} fChkE0H
Função para exibição de alerta e link para o TDN com orientação sobre as tabelas E0H e E0I e consultas F3.
@author raquel.andrade
@since 30/09/2024
@version 1.0
/*/
Static Function fChkE0H()
Local oButton1
Local oButton2
Local oGroup1
Local oPanel1
Local oSay1
Local oDlg
Local lRet			:= .T.
Local lExistE0H		:= ChkFile("E0H")
Local lExistE0I		:= ChkFile("E0I")
Local lF3New		:= .F.

	// Verifica criação das Consultas Auxiliares
	lF3New	:= fExtF3E0E()

	If !lExistE0H .Or. !lExistE0I .Or. !lF3New

		lRet	:= .F.

		DEFINE MSDIALOG oDlg TITLE OemToAnsi(STR0003) FROM 000, 000  TO 200, 500 COLORS 0, 16777215 PIXEL // "Migrador Tributos do Processo Trabalhista para leiaute S-1.3"

			@ 000, 000 MSPANEL oPanel1 SIZE 300, 150 OF oDlg COLORS 0, 16777215 RAISED
			@ 005, 012 GROUP oGroup1 TO 065, 237 PROMPT  OF oPanel1 COLOR 0, 16777215 PIXEL
			// "Migrador disponível apenas quando as tabela E0H e E0I (Tributos do Processo leiaute S-1.3) e consultas RE0C, RE0P e E0EP estiverem disponíveis na base de dados." 
			// "Veja documentação detalhada em Visualizar."
			@ 020, 017 SAY oSay1 PROMPT OemToAnsi(STR0011) + CRLF + CRLF + OemToAnsi(STR0012)   SIZE 215, 035 OF oPanel1 COLORS 0, 16777215 PIXEL
			@ 070, 160 BUTTON oButton1 PROMPT (STR0013) SIZE 037, 012 OF oPanel1 PIXEL// "Visualizar"
			@ 070, 200 BUTTON oButton2 PROMPT "OK" SIZE 037, 012 OF oPanel1 PIXEL

			oButton1:bLClicked := {|| ShellExecute("open","https://tdn.totvs.com/pages/releaseview.action?pageId=870385758","","",1) }
			oButton2:bLClicked := {|| oDlg:End() }

		ACTIVATE MSDIALOG oDlg CENTERED

	EndIf

Return lRet


/*/{Protheus.doc} function fExtF3E0E
Função verifica a existencia das novas consultas RE0C, RE0P, E0EP.
@author  raquel.andrade
@since   30/09/2024
@version V 1.0
/*/
Static Function fExtF3E0E()
Local aArea		:= GetArea()
Local lConCod	:= .F.
Local lConProc	:= .F.
Local lConPerAp := .F.
Local lRet		:= .F.

	DbSelectArea("SXB")
	If dbSeek("RE0C") // Verifica se existe F3 auxiliar para Código do Processo
		lConCod:= .T.
	EndIf

	DbSelectArea("SXB")
	If dbSeek("RE0P") // Verifica se existe F3 auxiliar para Número de Processo
		lConProc := .T.
	EndIf

	If dbSeek("E0EP") // Verifica se existe F3 auxiliar para Período de Apuração
		lConPerAp := .T.
	EndIf

	If lConCod .And. lConProc .And. lConPerAp
		lRet	:= .T.
	EndIf

	RestArea( aArea )

Return lRet

/*/{Protheus.doc} fConRE0P
Função especifica para retornar o Número do Processo - F3 RE0P.
@author  raquel.andrade
@since   30/09/2024
@version V 1.0
/*/
Function fConRE0P()
Local aStrRE01		As Array
Local aStrRE02		As Array
Local aStrRE03		As Array
Local aStrRE04		As Array
Local lRet          As Logical
Local bOk           As Block
Local bCancel       As Block
Local aSeek         As Array
Local oModalPanel   As Object
Local oPanelGrid    As Object
Local aArrayGrup    As Array
Local cProcPesq     As Character
Local nSzFilPo		As Numeric
Local nSzCdPo		As Numeric
Local nSzDsPo		As Numeric
Local nSzNrPo		As Numeric
Local cFilPesq		As Character
Local cQuery		:= ""
Local cAliasQry		:= ""

Private oBrowse     As Object
Private oModal      As Object

Static __oSt2

    lRet        := .T.
    bOk         := {||lRet := .T., oModal:oOwner:End()}
    bCancel     := {||lRet := .F., oModal:oOwner:End()}
    aSeek       := {}
    aArrayGrup  := {}
	aStrRE01	:= FWSX3Util():GetFieldStruct( "RE0_FILIAL" ) 
	aStrRE02	:= FWSX3Util():GetFieldStruct( "RE0_NUM" ) 
	aStrRE03 	:= FWSX3Util():GetFieldStruct( "RE0_DESCR" ) 
	aStrRE04	:= FWSX3Util():GetFieldStruct( "RE0_PROJUD") 
	nSzFilPo	:= aStrRE01[3]
	nSzCdPo		:= aStrRE02[3]
	nSzDsPo		:= aStrRE03[3]
	nSzNrPo		:= aStrRE04[3]	

	cFilPesq	:=  If(!Empty(cFilE0E), FwxFilial("RE0",cFilE0E), "")
	cProcPesq	:=  If(!Empty(cProcE0E), cProcE0E, "")	
	
    oModal := FWDialogModal():New()

    oModal:SetFreeArea(300, 200)
    oModal:createDialog()
    oModal:SetEscClose(.T.)
    oModal:AddButton( OemToAnsi( STR0016 ), bOk, OemToAnsi( STR0016 ), , .T., .F., .T., {|| .T.}) 		// "OK" 
    oModal:AddButton( OemToAnsi( STR0017 ), bCancel, OemToAnsi( STR0017 ), , .T., .F., .T.) 			// "Cancelar" 

    oModalPanel := oModal:GetPanelMain()

    oPanelGrid := TPanel():New(0, 0, "", oModalPanel, ,,,,, 0, 0)

    oPanelGrid:Align := CONTROL_ALIGN_ALLCLIENT

	If __oSt2 == Nil .or. ( __cEmpAux == Nil .or. __cEmpAux <> cEmpAnt )

		__cEmpAux := cEmpAnt

		__oSt2 := FWPreparedStatement():New()

		cQuery := "SELECT DISTINCT E0E.E0E_FILIAL, E0E.E0E_PRONUM, E0E.E0E_RECLAM, RE0.RE0_NUM, RE0.RE0_PROJUD, RE0.RE0_DESCR"
		cQuery += " FROM " + RetSqlName('E0E')  + " E0E "
		cQuery += "INNER JOIN " + RetSqlName('RE0') + " RE0 ON " + FwJoinFilial("E0E","RE0") + " AND E0E.E0E_PRONUM = RE0.RE0_NUM "
		cQuery += "LEFT JOIN " + RetSqlName('RD0') + " RD0 ON " + FwJoinFilial("E0E","RD0") + " AND E0E.E0E_RECLAM = RD0.RD0_CODIGO "
		cQuery += " WHERE E0E.D_E_L_E_T_ = ?  AND  "
		cQuery += " RD0.D_E_L_E_T_ = ?  "
		cQuery := ChangeQuery(cQuery)

		__oSt2:SetQuery(cQuery)

	EndIf

	__oSt2:SetString(1,' ')
	__oSt2:SetString(2,' ')

	cQuery := __oSt2:getFixQuery()

	cAliasQry := GetNextAlias()
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasQry)
	(cAliasQry)->(DbGoTop())

	While (cAliasQry)->(!EOF())

		If (!Empty(cFilPesq) .And. (cAliasQry)->(E0E_FILIAL) == cFilPesq .And. Empty(cProcPesq)) .Or.;
			(Empty(cFilPesq) .And. !Empty(cProcPesq) .And. (cAliasQry)->(E0E_PRONUM) == cProcPesq) .Or.;
		  	(!Empty(cFilPesq) .And. (cAliasQry)->(E0E_FILIAL) == cFilPesq .And. !Empty(cProcPesq) .And.  (cAliasQry)->(E0E_PRONUM) == cProcPesq) .Or.;
			(Empty(cFilPesq) .And. Empty(cProcPesq) )
			aAdd(aArrayGrup, {(cAliasQry)->(E0E_FILIAL),(cAliasQry)->(E0E_PRONUM), (cAliasQry)->(RE0_DESCR), (cAliasQry)->(RE0_PROJUD)  })
		EndIf
		(cAliasQry)->(DbSkip())
	EndDo

	(cAliasQry)->(DbCloseArea())

    oBrowse := FWBrowse():New(oPanelGrid)

    oBrowse:SetDescription(OemToAnsi( STR0014 )) //"Número do Processo" 
    oBrowse:SetDataArray()
    oBrowse:DisableFilter()
    oBrowse:DisableConfig()
	oBrowse:SetColumns(fCrColuna(OemToAnsi( STR0022 ),1,,0,nSzFilPo,"oBrowse"))		// "Filial" 
	oBrowse:SetColumns(fCrColuna(OemToAnsi( STR0006 ),2,,0,nSzCdPo,"oBrowse"))		// "Código do Processo" 
    oBrowse:SetColumns(fCrColuna(OemToAnsi( STR0018 ),3,,0,nSzDsPo,"oBrowse"))	 	// "Descrição"
    oBrowse:SetColumns(fCrColuna(OemToAnsi( STR0014 ),4,,0,nSzNrPo,"oBrowse")) 		// "Número do Processo"
	
	oBrowse:SetArray(aArrayGrup)
    oBrowse:Activate()

    oModal:Activate()

    // Atribuo o valor selecionado ao conteúdo de retorno da consulta específica
    If lRet
        If Len(aArrayGrup) > 0
            cNrE0E := aArrayGrup[oBrowse:nAt][4]
        EndIf
    EndIf

Return lRet


/*/{Protheus.doc} fConE0EP
Função especifica para retornar o Período de Apuração - F3 E0EP.
@author  raquel.andrade
@since   30/09/2024
@version V 1.0
/*/
Function fConE0EP()
Local aStrRE01		As Array
Local aStrRE02		As Array
Local aStrRE03		As Array
Local aStrRE04		As Array
Local aStrE0E		As Array
Local lRet          As Logical
Local bOk           As Block
Local bCancel       As Block
Local aSeek         As Array
Local oModalPanel   As Object
Local oPanelGrid    As Object
Local aArrayGrup    As Array
Local cAliasQry		As Character
Local cProcPesq     As Character
Local nSzFilPo		As Character
Local nSzCdPo		As Numeric
Local nSzDsPo		As Numeric
Local nSzNrPo		As Numeric
Local nSzPerAp		As Numeric
Local cFilPesq		As Character

Private oBrowse     As Object
Private oModal      As Object

Static __oSt3

    lRet        := .T.
    bOk         := {||lRet := .T., oModal:oOwner:End()}
    bCancel     := {||lRet := .F., oModal:oOwner:End()}
    aSeek       := {}
    aArrayGrup  := {}

	aStrRE01 	:= FWSX3Util():GetFieldStruct( "RE0_FILIAL" ) 
	aStrRE02 	:= FWSX3Util():GetFieldStruct( "RE0_NUM" ) 
	aStrRE03 	:= FWSX3Util():GetFieldStruct( "RE0_DESCR" ) 
	aStrRE04 	:= FWSX3Util():GetFieldStruct( "RE0_PROJUD") 
	aStrE0E 	:= FWSX3Util():GetFieldStruct( "E0E_PERAP") 
	nSzFilPo	:= aStrRE01[3]
	nSzCdPo		:= aStrRE02[3]
	nSzDsPo		:= aStrRE03[3]
	nSzNrPo		:= aStrRE04[3]
	nSzPerAp	:= aStrE0E[3]

	cFilPesq	:=  If(!Empty(cFilE0E), FwxFilial("E0E",cFilE0E), FwxFilial("E0E",cFilAnt))
	cProcPesq	:=  If(!Empty(cProcE0E), cProcE0E, "")	
	
    oModal := FWDialogModal():New()

    oModal:SetFreeArea(300, 200)
    oModal:createDialog()
    oModal:SetEscClose(.T.)
    oModal:AddButton( OemToAnsi( STR0016 ), bOk, OemToAnsi( STR0016 ), , .T., .F., .T., {|| .T.}) 	// "OK" 
    oModal:AddButton( OemToAnsi( STR0017 ), bCancel, OemToAnsi( STR0017 ), , .T., .F., .T.) 		// "Cancelar" 

    oModalPanel := oModal:GetPanelMain()

    oPanelGrid := TPanel():New(0, 0, "", oModalPanel, ,,,,, 0, 0)

    oPanelGrid:Align := CONTROL_ALIGN_ALLCLIENT

	If __oSt3 == Nil .or. ( __cEmpAux == Nil .or. __cEmpAux <> cEmpAnt )

		__cEmpAux := cEmpAnt

		__oSt3 := FWPreparedStatement():New()

		cQuery := "SELECT DISTINCT E0E.E0E_FILIAL, E0E.E0E_PRONUM, E0E.E0E_RECLAM, E0E.E0E_PERAP, RE0.RE0_NUM, RE0.RE0_PROJUD, RE0.RE0_DESCR"
		cQuery += " FROM " + RetSqlName('E0E')  + " E0E "
		cQuery += "INNER JOIN " + RetSqlName('RE0') + " RE0 ON " + FwJoinFilial("E0E","RE0") + " AND E0E.E0E_PRONUM = RE0.RE0_NUM "
		cQuery += "LEFT JOIN " + RetSqlName('RD0') + " RD0 ON " + FwJoinFilial("E0E","RD0") + " AND E0E.E0E_RECLAM = RD0.RD0_CODIGO "
		cQuery += " WHERE E0E.E0E_FILIAL = ? AND "
		cQuery += " E0E.E0E_PRONUM = ? AND "
		cQuery += " E0E.D_E_L_E_T_ = ?  AND  "
		cQuery += " RD0.D_E_L_E_T_ = ?  "
		cQuery := ChangeQuery(cQuery)

		__oSt3:SetQuery(cQuery)

	EndIf

	__oSt3:SetString(1,cFilPesq)
	__oSt3:SetString(2,cProcPesq)
	__oSt3:SetString(3,' ')
	__oSt3:SetString(4,' ')

	cQuery := __oSt3:getFixQuery()

	cAliasQry := GetNextAlias()
		dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasQry)
	(cAliasQry)->(DbGoTop())

	While (cAliasQry)->(!EOF())
		aAdd(aArrayGrup, {(cAliasQry)->(E0E_FILIAL), (cAliasQry)->(E0E_PERAP),(cAliasQry)->(E0E_PRONUM), (cAliasQry)->(RE0_PROJUD), (cAliasQry)->(RE0_DESCR)  })
		(cAliasQry)->(DbSkip())
	EndDo

	(cAliasQry)->(DbCloseArea())

    oBrowse := FWBrowse():New(oPanelGrid)

    oBrowse:SetDescription(OemToAnsi( STR0015 )) // "Período de Apuração" 
    oBrowse:SetDataArray()
    oBrowse:DisableFilter()
    oBrowse:DisableConfig()
	oBrowse:SetColumns(fCrColuna(OemToAnsi( STR0022 ),1,,0,nSzFilPo,"oBrowse"))		// "Filial" 
	oBrowse:SetColumns(fCrColuna(OemToAnsi( STR0021 ),2,,0,nSzPerAp,"oBrowse")) 	// "Per. Apuração"
	oBrowse:SetColumns(fCrColuna(OemToAnsi( STR0019 ),3,,0,nSzCdPo,"oBrowse"))		// "Código"
    oBrowse:SetColumns(fCrColuna(OemToAnsi( STR0020 ),4,,0,nSzNrPo,"oBrowse")) 		// "Número"	
	oBrowse:SetColumns(fCrColuna(OemToAnsi( STR0018 ),5,,0,nSzDsPo,"oBrowse"))	 	// "Descrição"
	
	oBrowse:SetArray(aArrayGrup)
    oBrowse:Activate()

    oModal:Activate()

    // Atribuo o valor selecionado ao conteúdo de retorno da consulta específica
    If lRet
        If Len(aArrayGrup) > 0
            cPerApE0E := aArrayGrup[oBrowse:nAt][2]
        EndIf
    EndIf

Return lRet

/*/{Protheus.doc} fConRE0C
Função especifica para retornar o Código do Processo - F3 RE0C.
@author  raquel.andrade
@since   02/10/2024
@version V 1.0
/*/
Function fConRE0C()
Local aStrRE01		As Array
Local aStrRE02		As Array
Local aStrRE03		As Array
Local lRet          As Logical
Local bOk           As Block
Local bCancel       As Block
Local aSeek         As Array
Local oModalPanel   As Object
Local oPanelGrid    As Object
Local aArrayGrup    As Array
Local nSzFilPo		As Numeric
Local nSzCdPo		As Numeric
Local nSzDsPo		As Numeric
Local cFilPesq		As Character
Local cQuery		:= ""
Local cAliasQry		:= ""

Private oBrowse     As Object
Private oModal      As Object

Static __oSt4

    lRet        := .T.
    bOk         := {||lRet := .T., oModal:oOwner:End()}
    bCancel     := {||lRet := .F., oModal:oOwner:End()}
    aSeek       := {}
    aArrayGrup  := {}
	aStrRE01	:= FWSX3Util():GetFieldStruct( "RE0_FILIAL" )
	aStrRE02	:= FWSX3Util():GetFieldStruct( "RE0_NUM" ) 
	aStrRE03 	:= FWSX3Util():GetFieldStruct( "RE0_DESCR" ) 
	nSzFilPo	:= aStrRE01[3]
	nSzCdPo		:= aStrRE02[3]
	nSzDSPo		:= aStrRE03[3]	

	cFilPesq	:=  If(!Empty(cFilE0E), FwxFilial("RE0",cFilE0E), "")
	
    oModal := FWDialogModal():New()

    oModal:SetFreeArea(300, 200)
    oModal:createDialog()
    oModal:SetEscClose(.T.)
    oModal:AddButton( OemToAnsi( STR0016 ), bOk, OemToAnsi( STR0016 ), , .T., .F., .T., {|| .T.}) 		// "OK" 
    oModal:AddButton( OemToAnsi( STR0017 ), bCancel, OemToAnsi( STR0017 ), , .T., .F., .T.) 			// "Cancelar" 

    oModalPanel := oModal:GetPanelMain()

    oPanelGrid := TPanel():New(0, 0, "", oModalPanel, ,,,,, 0, 0)

    oPanelGrid:Align := CONTROL_ALIGN_ALLCLIENT

	If __oSt4 == Nil .or. ( __cEmpAux == Nil .or. __cEmpAux <> cEmpAnt )

		__cEmpAux := cEmpAnt

		__oSt4 := FWPreparedStatement():New()

		cQuery := "SELECT DISTINCT RE0.RE0_FILIAL, RE0.RE0_NUM, RE0.RE0_DESCR, E0E.E0E_PRONUM"
		cQuery += " FROM " + RetSqlName('RE0')  + " RE0 "
		cQuery += "INNER JOIN " + RetSqlName('E0E') + " E0E ON " + FwJoinFilial("RE0","E0E") + " AND RE0.RE0_NUM = E0E.E0E_PRONUM "
		cQuery += " WHERE RE0.D_E_L_E_T_ = ?  "
		cQuery += " AND E0E.D_E_L_E_T_ = ?  "
		cQuery := ChangeQuery(cQuery)

		__oSt4:SetQuery(cQuery)

	EndIf

	__oSt4:SetString(1,' ')
	__oSt4:SetString(2,' ')

	cQuery := __oSt4:getFixQuery()

	cAliasQry := GetNextAlias()
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasQry)
	(cAliasQry)->(DbGoTop())

	While (cAliasQry)->(!EOF())

		If Empty(cFilPesq) .Or. (!Empty(cFilPesq) .And. (cAliasQry)->(RE0_FILIAL) == cFilPesq) 
			aAdd(aArrayGrup, {(cAliasQry)->(RE0_FILIAL) , (cAliasQry)->(RE0_NUM), (cAliasQry)->(RE0_DESCR) })
		EndIf
		(cAliasQry)->(DbSkip())
	EndDo

	(cAliasQry)->(DbCloseArea())

    oBrowse := FWBrowse():New(oPanelGrid)

    oBrowse:SetDescription(OemToAnsi( STR0006 )) //"Código do Processo"
    oBrowse:SetDataArray()
    oBrowse:DisableFilter()
    oBrowse:DisableConfig()
	oBrowse:SetColumns(fCrColuna(OemToAnsi( STR0022 ),1,,0,nSzFilPo,"oBrowse"))		// "Filial" 
	oBrowse:SetColumns(fCrColuna(OemToAnsi( STR0006 ),2,,0,nSzCdPo,"oBrowse"))		// "Código do Processo" 
    oBrowse:SetColumns(fCrColuna(OemToAnsi( STR0018 ),3,,0,nSzDsPo,"oBrowse"))	 	// "Descrição"
	
	oBrowse:SetArray(aArrayGrup)
    oBrowse:Activate()

    oModal:Activate()

    // Atribuo o valor selecionado ao conteúdo de retorno da consulta específica
    If lRet
        If Len(aArrayGrup) > 0
            cProcE0E := aArrayGrup[oBrowse:nAt][2]
        EndIf
    EndIf

Return lRet

/*/{Protheus.doc} fCrColuna
Função especifica para construir as colunas da consulta especifica
@author  raquel.andrade
@since   30/09/2024
@version V 1.0
/*/
Static Function fCrColuna(cTitulo,xArrData,cPicture,nAlign,nSize,cBrowse,cTipo,nDecimal)
Local aColumn   As Array
Local bData     As Block

Default cTitulo		:= ""
Default xArrData	:= {}
Default cPicture	:= ""
Default nAlign 		:= 1
Default nSize 		:= 20
Default cBrowse		:= ""
Default cTipo		:= ""
Default nDecimal 	:= 1

    bData   := {||}
    aColumn := {}

    If !Empty(xArrData)
        If ValType(xArrData) == "N" .AND. xArrData > 0 .AND. !Empty(cBrowse)
            bData := &("{||"+cBrowse+":oData:aArray["+cBrowse+":At(),"+STR(xArrData)+"]}")
        EndIf
    EndIf

    aColumn := {cTitulo,bData,cTipo,cPicture,nAlign,nSize,nDecimal,.F.,{||.T.},.F.,{||oModal:oOwner:End()},NIL,{||.T.},.F.,.F.,{}}

Return {aColumn}

/*/{Protheus.doc} function fMigra2501
Realiza a migraçâo de um evento S-2501 do layout S-1.2 para o layout S-1.3
@author  martins.marcio
@since  30/09/2024
@version 12.1.2410
/*/
Static Function fMigra2501(cBranchId,cErroMsg)
Local lRet			:= .F.
Local oJsonData		:= JsonObject():new()
Local cFilBkp		:= ""

Default cBranchId	:= ""
Default cErroMsg	:= ""

cFilBkp := cFilAnt
cFilAnt	:= cBranchId
cChave	:= cEmpAnt + cBranchId + cProcessId + cPerApurPg

	If !Empty(cChave)
		//Obtem o json do evento S-2501 no layout S-1.2 (Tabelas E0E/E0F)
		If f2501ById2(@oJsonData, "9.2")
			// Prepara o json para o novo layout
			If fPrepJson(@oJsonData)
				// Realiza a gravaçâo do Json no layout S-1.3 (Tabelas E0H/E0I)
				lRet := fGrv2501(4/*nOpc*/, oJsonData["items"][1], @cErroMsg, "9.3")
			EndIf
		EndIf
	EndIf

	FreeObj(oJsonData)

	cFilAnt := cFilBkp

Return lRet


/*/{Protheus.doc} function fPrepJson
Prepara o json para a migração incluindo campos que são específicos do layout S-1.3
@author  martins.marcio
@since  30/09/2024
@version 12.1.2410
/*/
Static Function fPrepJson(oJsonData)
Local oJson
Local oRIsen0561
Local lRet			:= .F.
Local nI			:= 0
Local nZ			:= 0
Local aIdeTrab 		:= {}
Local aInfCRIRRF 	:= {}

Default oJsonData := ""

	If ValType(oJsonData) == "J"
		oJson := oJsonData["items"][1]
		If ! (oJson["ideProc"]:hasProperty("ideSeqProc"))
			oJson["ideProc"]["ideSeqProc"] := -1
		EndIf
		aIdeTrab := oJson['ideTrab']
		For nI := 1 To Len(aIdeTrab)
			aInfCRIRRF := aIdeTrab[nI]['infoCRIRRF']
			For nZ := 1 To Len(aInfCRIRRF)
				If ! (aInfCRIRRF[nZ]:hasProperty("vrCR13"))
					aInfCRIRRF[nZ]["vrCR13"] := -1
				EndIf
				If !(aInfCRIRRF[nZ]["infoIR"]:hasProperty("vrRendMoleGrave13"))
					aInfCRIRRF[nZ]["infoIR"]["vrRendMoleGrave13"] := -1
				EndIf
				If !(aInfCRIRRF[nZ]["infoIR"]:hasProperty("vrRendIsen65Dec"))
					aInfCRIRRF[nZ]["infoIR"]["vrRendIsen65Dec"] := -1
				EndIf
				If !(aInfCRIRRF[nZ]["infoIR"]:hasProperty("vrJurosMora13"))
					aInfCRIRRF[nZ]["infoIR"]["vrJurosMora13"] := -1
				EndIf
				If !(aInfCRIRRF[nZ]["infoIR"]:hasProperty("descIsenNTrib"))
					aInfCRIRRF[nZ]["infoIR"]["descIsenNTrib"] := ""
				EndIf
				If !(aInfCRIRRF[nZ]["infoIR"]:hasProperty("vrPrevOficial13"))
					aInfCRIRRF[nZ]["infoIR"]["vrPrevOficial13"] := -1
				EndIf
				If !(aInfCRIRRF[nZ]["infoIR"]:hasProperty("rendIsen0561"))
					oRIsen0561 := JsonObject():new()
					oRIsen0561["vlrDiarias"]		:= -1
					oRIsen0561["vlrAjudaCusto"]		:= -1
					oRIsen0561["vlrIndResContrato"]	:= -1
					oRIsen0561["vlrAbonoPec"]		:= -1
					oRIsen0561["vlrAuxMoradia"]		:= -1
					aInfCRIRRF[nZ]["infoIR"]["rendIsen0561"] := oRIsen0561
				EndIf
			Next nZ
		Next nI
		lRet := .T.
	EndIf

Return lRet
