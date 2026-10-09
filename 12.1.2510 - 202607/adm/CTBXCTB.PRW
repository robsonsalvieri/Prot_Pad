#INCLUDE "FileIO.CH"
#INCLUDE "PROTHEUS.CH"                                              
#INCLUDE "fwschedule.ch"
#INCLUDE "CTBXCTB.CH"

#DEFINE D_PRELAN		"9"

STATIC __CtbSayApro := {}
STATIC aCtbIni 	 	:= {}
STATIC __CtbPosic 	:= JsonObject():new()
STATIC __lIsCtbJob 	:= Nil
Static lAprova
Static lX3Aprova := Nil
                

STATIC lFWCodFil := FindFunction("FWCodFil")
STATIC _lSomaOld
STATIC nQtdEntid 				//Quantidade de entidades 

//Variaveis de controle da apuracao
STATIC __dDataLP
STATIC __lCW0LP

Static __aRealTempTable
Static __lConoutR	:= FindFunction("CONOUTR")

Static __aCtbPer_ := {}
Static __CtbPeridos := NIL
Static __lCVAInDic  := NIL
Static __cQryPeriodos 

Static _lCTBCTASU    := ExistBlock("CTBCTASU")
Static _lCTBDIGCT    := ExistBlock("CTBDIGCT")
Static _lCTBCCSUP    := ExistBlock("CTBCCSUP")
Static _lCTBITSUP    := ExistBlock("CTBITSUP")
Static _lCTBCVSUP    := ExistBlock("CTBCVSUP")
Static _oFilCTB      := nil
Static oJsonCVA      := JsonObject():New()
Static __lLoadTph    As Logical
/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³CtbCtaSup ³ Autor ³ Pilar S. Albaladejo   ³ Data ³ 08.11.99 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Gera Codigo da Conta Superior                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³CtbCtaSup(cCodigo)                                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³cCod                                                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Generico                                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpC1 = Codigo da Conta                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function CtbCtaSup(cCodigo)

Local aAmbSave := GetArea()
Local aAmbCT1  := CT1->( GetArea() )
Local cCod
Local nCont

cCodigo			:= AllTrim( cCodigo )

dbSelectArea("CT1")
CT1->( dbSetOrder( 1 ) )

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ PONTO DE ENTRADA CTBCTASU                            ³
//³ Criado para gerar conta superior caso nao            ³
//³ siga a regra padrao do Sistema.                      ³
//³ Recebe em PARAMIXB a Conta Cont bil atual.           ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If _lCTBCTASU
	cCod := ExecBlock("CTBCTASU",.F.,.F.,cCodigo)
Else
	For nCont := 1 to Len(cCodigo)
		cCod  := padr(Substr(cCodigo,1,Len(cCodigo)-nCont),20)
		If MsSeek(xFilial()+cCod,.f.)
			If CT1->CT1_CLASSE == "1"  //  Somente se for uma conta sintética
				cCod := CT1->CT1_CONTA
				Exit
			EndIf
		EndIf
	Next
EndIf

RestArea( aAmbCT1 )
RestArea( aAmbSave )

Return cCod

/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³CtbDigCont³ Autor ³ Pilar S. Albaladejo   ³ Data ³ 08.11.99 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Gera digito de Controle                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³CtbDigCont(cCodigo)                                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³cDig                                                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Generico                                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpC1 = Conta                                              ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function CtbDigCont(cCodigo)

Local nSoma		:= 0 
Local nResult	:= 0
Local nTam		:= 0
Local nFator	:= 0
Local nDig 		:= 0  
Local nCont := 0

Local cDig		:= ""

nTam := Len(Alltrim(cCodigo))

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ PONTO DE ENTRADA CTBDIGCT                            ³
//³ Criado para criar permitir gera‡„o diferenciada de   ³
//³ d¡gito verificador para Conta Cont bil.              ³
//³ Recebe em PARAMIXB a Conta Cont bil.                 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If _lCTBDIGCT
	nDig := ExecBlock("CTBDIGCT",.F.,.F.,cCodigo)
	cDig := STR(nDig,1)
Else
	nFator := 1
	For nCont:=nTam To 1 Step -1
		if nFator == 3
			nFator := 7
		ElseIf nFator == 7
			nFator := 1
		ElseIf nFator == 1
			nFator := 3
		EndIf
		nSoma:=Val(Substr(cCodigo,nCont,1))*nFator
		nResult+=nSoma
		nTam--
	Next
	nDig := MOD(nResult,10)
	cDig := If( nDig == 0, "0" , STR((10-nDig),1) )
EndIf
Return cDig

/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³CtbOk      ³ Autor ³ Pilar S Albaladejo    ³ Data ³ 15.12.99 		     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Mensagem no botao Ok                                        			 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³CtbOk()                                                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³Mensagem                                                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Generico                                                  			 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ Nwnhum                                    	                 		 ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function CtbOk()

Return MsgYesNo(OemToAnsi(STR0001),OemToAnsi(STR0002))  //"Confirma configuração dos parâmetros?"###"Atenção!!"

/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o	 ³ReadCtbIni³ Autor ³ Pilar S. Albaladejo   ³ Data ³ 27/11/00 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Leitura do arquivo SIGACTB.INI para carregar array aCTBINI  ³±±
±±³			 ³c/ configuracao da apropriacao de custos					  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe	 ³ ReadCTBIni												  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno	 ³ Array aCtbIni											  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso		 ³ Generico 												  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ Nenhum   												  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function ReadIniCtb(lCarrega)

Local cTitCC
Local cTitItem
Local cTitClasse
Local cTamCC
Local cTamItem
Local cTamClVl
Local nHdlCusto := 0
Local nBytes:=0
Local nTamArq
Local xBuffer

DEFAULT lCarrega := .F.

If Len(aCtbIni) # 0 .And. ! lCarrega
	Return aCtbIni
Endif
aCtbIni := {}

IF !file("SIGACTB.INI")
	nHdlCusto := MSFCreate("SIGACTB.INI",0)
	IF nHdlCusto == -1
		HELP(" ",1,"CTB_ERROR")
		Final("Error F_"+str(ferror(),2)+" em SIGACTB.INI")
	Endif
	cTitCC		:= RetTitle("CTT_CUSTO",10)
	cTitItem		:= RetTitle("CTD_ITEM",10)
	cTitClasse	:= RetTitle("CTH_CLVL",10)
	cTamCC 		:= StrZero(Len(CriaVar("CTT_CUSTO")),2)
	cTamItem		:= StrZero(Len(CriaVar("CTD_ITEM")),2)
	cTamClVL		:= StrZero(Len(CriaVar("CTH_CLVL")),2)

	fWrite(nHdlCusto,"01"+cTitCC+cTamCC+"1CTT"+chr(13)+chr(10))
	fWrite(nHdlCusto,"02"+cTitItem+cTamItem+"2CTD"+chr(13)+chr(10))
	fWrite(nHdlCusto,"03"+cTitCLasse+cTamCLVL+"2CTH"+chr(13)+chr(10))
	fClose(nHdlCusto)
Endif

nHdlCusto := FOPEN("SIGACTB.INI",64)

If nHdlCusto <0
	HELP(" ",1,"CTB_ERROR")
	Final("SIGACTB.INI")
EndIf
nTamArq:=FSEEK(nHdlCusto,0,2)		// VerIfica tamanho do arquivo
FSEEK(nHdlCusto,0,0)					// Volta para inicio do arquivo

While nBytes<nTamArq
	
	xBuffer:=Space(20)
	FREAD(nHdlCusto,@xBuffer,20)
	
	AADD(	aCtbIni,SubStr(xBuffer,1,02)+" "+SubStr(xBuffer,03,10)+" "+;
			SubStr(xBuffer,13,02) + " " + SubStr(xBuffer,15,01) +" "+;
			Substr(xBuffer,16,03) )
	nBytes+=20
End

Fclose(nHdlCusto)

Return aCtbIni

/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o	 ³CtbSayApro ³ Autor ³ Pilar S. Albaladejo  ³ Data ³ 27/11/00 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Retorna a descricao do centro de custo, item ou classe de   ³±±
±±³			 ³valor configurada no SIGACTB.INI          				  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe	 ³CtbSayApro(cAlias))										  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno	 ³cTexto.         											  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso		 ³ Generico 												  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpC1 = Alias do arquivo a ser verificado				  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function CtbSayApro(cAlias, cIdEntid)

Local aArea      
Local cTexto     := ""
Local nPos
Local aCtbIni    := ReadIniCtb()

DEFAULT cIdEntid := ""

If Len(__CtbSayApro) > 0 .And. ( nPos := aScan(__CtbSayApro, {|x| x[1] == cAlias .And. ;
																	x[2] == cIdEntid .And. ;
																	x[3] == cEmpAnt .And. ;
																	x[4] == cFilAnt } ) ) > 0
	cTexto := __CtbSayApro[nPos, 5]
Else
	
	aArea      := GetArea()
	aCtbIni    := ReadIniCtb()

	If ! CtbInUse()		// Compatibilizacao com o SigaCon
		Return If(cAlias = "CTH", "", If(cAlias = "CTT", STR0003, STR0004)) //"Centro custo"###"Item Contabil"
	Endif

	If !Empty(cAlias) .And. cAlias $ "CTT/CTD/CTH"
		nPos := Ascan(aCtbIni, {|x| Substr(x,20,03) = Upper(cAlias) })
		If nPos > 0
			cTexto := Substr(aCtbIni[nPos],04,10)
		Endif
	Else
		dbSelectArea("CT0")
		dbSetOrder(1)
		//procura pelo alias na CT0
		If !Empty(cAlias)
			dbSeek(xFilial("CT0"))
			While CT0->( ! Eof()) .And. CT0_FILIAL == xFilial("CT0" )
				If CT0->CT0_ALIAS == cAlias
					cTexto := CT0->CT0_DSCRES
					Exit
				EndIf
				CT0->(dbSkip())
			EndDo
		EndIf
		
	 	If !Empty(cIdEntid)
			dbSelectArea("CT0")
			dbSetOrder(1)
			If dbSeek(xFilial("CT0")+cIdEntid)
				cTexto := CT0->CT0_DSCRES
			EndIf
		EndIf	
	
	EndIf
	
	nPos := Ascan(aCtbIni, {|x| Substr(x,20,03) = Upper(cAlias) })
	If nPos > 0
		cTexto := Substr(aCtbIni[nPos],04,10)
	Endif

	RestArea(aArea)
	
	//adiciona no array __CtbSayApro cAlias, cIdEntid, cTexto - performance
	aAdd(__CtbSayApro, { cAlias, cIdEntid, cEmpAnt, cFilAnt, cTexto } )
	
Endif

Return cTexto

//-------------------------------------------------------------------
/*{Protheus.doc} CtbPeriodos

Retorna os periodos para a moeda.

@author Alvaro Camillo Neto

@param cMoeda  Moeda                            				 			
@param dDtIni  Data Inicial													 
@param dDtFim  Data Final  													 
@param lExercicio  Indica se a verificacao do periodo deve ser por exercicio    
@param lZeradas  Indica se a existirem calendarios fora da data solicita .Retornara matriz com informacoes em branco  

   
@version P12
@since   20/02/2014
@return  Nil
@obs	 
*/
//-------------------------------------------------------------------
FUNCTION CtbPeriodos( cMoeda, dDtIni, dDtFim, lExercicio, lZeradas, cCalend, cCriter )

LOCAL aRet		:= {}
Local aAreaPer	
Local lAchouFim	:= .F.
Local cQuery
Local nPos := 0
Local aParCalend := {}
Local nI         := 0
Local cDataI     :=" "
Local cDataF     :=" "
Local TMPCTG     := CTG->(GetNextAlias())
Local aBind      := {}
Local cAliasCTO  := CTO->(GetNextAlias())

DEFAULT lExercicio := .F.
DEFAULT lZeradas   := .T.
DEFAULT cCalend    := ""
DEFAULT cCriter    := ""

If cCriter $ "2/8"					// Média Mensal
	dDtIni := FirstDay(dDtIni)
	dDtFim := Iif(Empty(dDtFim),LastDay(dDtIni),dDtFim)
Else
	dDtFim := Iif(Empty(dDtFim),dDtIni,dDtFim)
EndIf

If Len(__aCtbPer_) > 0  .And. ( nPos := aScan(__aCtbPer_,{|x|  	x[1] == cMoeda .And. ;
																x[2] == dDtIni .And. ;
																x[3] == dDtFim .And. ;
																x[4] == lExercicio .And. ;
																x[5] == lZeradas .And. ;
																x[6] == cCalend .And. ;
																x[7] == cCriter  } ) ) > 0
	aRet := aClone( __aCtbPer_[nPos, 8] )
	
Else
	aAreaPer	:= GetArea()
	// Se nao informou o calendario, exige amarracao entre Moeda e Calendario
	If Empty( cCalend )
		// Localiza a moeda
		If __cQryPeriodos == nil 
			__cQryPeriodos := "SELECT CTG_FILIAL, CTG_CALEND, CTG_EXERC, CTG_PERIOD, "
			__cQryPeriodos += " CTG_DTINI, CTG_DTFIM,  CTG_STATUS FROM "
			__cQryPeriodos += RetSqlName('CTO')+ " CTO "
			__cQryPeriodos += " INNER JOIN "+RetSqlName('CTE')+ " CTE "
			__cQryPeriodos += " ON CTE_FILIAL = ? "
			__cQryPeriodos += " AND CTE_MOEDA = CTO_MOEDA "
			__cQryPeriodos += " AND CTE.D_E_L_E_T_ = ? "
			__cQryPeriodos += " INNER JOIN "+RetSqlName("CTG")+" CTG "
			__cQryPeriodos += " ON CTG_FILIAL = ? "
			__cQryPeriodos += " AND CTG_CALEND = CTE_CALEND"
			__cQryPeriodos += " AND CTG.D_E_L_E_T_ = ? "
			__cQryPeriodos += " WHERE CTO_FILIAL = ? "
			__cQryPeriodos += " AND CTO_MOEDA = ? "
			__cQryPeriodos += " AND CTO.D_E_L_E_T_ = ? "
			__cQryPeriodos += " ORDER BY CTG_FILIAL, CTG_CALEND, CTG_EXERC, CTG_PERIOD"
			__cQryPeriodos := ChangeQuery(__cQryPeriodos)
		EndIf 
		aadd(aBind,xFilial('CTE'))
		aadd(aBind,Space(1))
		aadd(aBind,xFilial('CTG'))
		aadd(aBind,Space(1))
		aadd(aBind,xFilial("CTO"))
		aadd(aBind,cMoeda)
		aadd(aBind,Space(1))
		dbUseArea(.T.,"TOPCONN",TcGenQry2(,,__cQryPeriodos,aBind),cAliasCTO)

		TCSetField( cAliasCTO, 'CTG_DTINI', 'D', 8, 0)
		TCSetField( cAliasCTO, 'CTG_DTFIM', 'D', 8, 0)

		If (cAliasCTO)->(!Eof())
			While (cAliasCTO)->(!Eof())
				// Se estiver dentro do periodo solicitado
				If 	If(lExercicio,  Year((cAliasCTO)->CTG_DTFIM) <= Year(dDtFim) .And.;
						Year((cAliasCTO)->CTG_DTINI) >= Year(dDtIni),;
						(cAliasCTO)->CTG_DTINI <= dDtIni .AND.;
						(cAliasCTO)->CTG_DTFIM >= dDtFim)
					// Adiciona os periodos na matriz de retorno
					Aadd( aRet, { 	(cAliasCTO)->CTG_DTINI, (cAliasCTO)->CTG_DTFIM,;
						(cAliasCTO)->CTG_EXERC, (cAliasCTO)->CTG_STATUS } )
					lAchouFim := .T.
					
					// Se o Periodo do Calendario estiver dentro do intervalo solicitado. Para atender, por exemplo, calendario com periodos diarios
				ElseIf !lExercicio .And. (cAliasCTO)->CTG_DTINI >= dDtIni .AND. (cAliasCTO)->CTG_DTINI <= dDtFim
					
					Aadd( aRet, { (cAliasCTO)->CTG_DTINI, (cAliasCTO)->CTG_DTFIM, (cAliasCTO)->CTG_EXERC, (cAliasCTO)->CTG_STATUS } )
					// Verificando se encontrou a data final do intervalo no calendario
					If ! lAchouFim
						lAchouFim := ( (cAliasCTO)->CTG_DTFIM >= dDtFim )
					EndIf
					
				ElseIf lZeradas
					Aadd( aRet, {	CTOD("  /  /  "), CTOD("  /  /  "), Space(4), " " })
				Endif
				(cAliasCTO)->(dbSkip())
			EndDo 
			//- Se não exist um Retorno ou 
			//	Se nao encontrou no calendario a data final do intervalo, nao permitir continuar
			If Len(aRet) = 0 .or. !lAchouFim		
				aRet := {}
				Aadd( aRet, {	CTOD("  /  /  "), CTOD("  /  /  "), Space(4), " " })
			Endif
		Else
			Aadd( aRet, {	CTOD("  /  /  "), CTOD("  /  /  "), Space(4), " " })
		EndIf
		(cAliasCTO)->(dbCloseArea())
	Else
		//	Se informou o calendario, NAO exige amarracao entre Moeda e Calendario. Utilizado para agrupar os
		//	valores de varias formas (Ex.: mensal, trimestral, semestral, anual, etc.) sem ter que alterar o
		//	calendario que possui a amarracao com as moedas.
		
		/* parâmetros a ser passados para a changequery em cache */
		If lExercicio
			cDataI := Substr(DTOS(dDtIni),1,4)
			cDataF := Substr(DTOS(dDtFim),1,4)
		Else
			cDataI := DTOS(dDtIni)
			cDataF := DTOS(dDtFim)
		Endif

		aParCalend:={ RetSqlName("CTG"), xFilial("CTG"), cCalend, cDataI, cDataF }
		If __CtbPeridos == NIL
			cQuery := " SELECT "
			cQuery += " CTG_FILIAL, "
			cQuery += " CTG_DTINI, "
			cQuery += " CTG_DTFIM, "
			cQuery += " CTG_CALEND, "
			cQuery += " CTG_EXERC, "
			cQuery += " CTG_STATUS, "
			cQuery += " CTG_PERIOD  "
			cQuery += " FROM ? CTG "
			cQuery += " WHERE CTG.CTG_FILIAL = ?
			cQuery += " AND CTG_CALEND = ? "
			If lExercicio
				cQuery += " AND SUBSTRING(CTG_DTINI,1,4) between  ?  AND  ? "
			Else
				cQuery += " AND CTG_DTINI <= ?  "
				cQuery += " AND CTG_DTFIM >= ?  "
			EndIf		
			cQuery += " AND CTG.D_E_L_E_T_ = ' ' "
			//RETIRADO PARA PERFORMANCE - ANSI NAO HA NECESSIDADE DE PASSAR PELA CHANGEQUERY	
			//		If lExercicio .OR. ! ( Alltrim(Upper(TCGetDB())) $ "MSSQL|MSSQL7|ORACLE" )
			cQuery := ChangeQuery(cQuery)
			//		EndIf
			//		dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),"TMPCTG",.T.,.F.)
			__CtbPeridos := FWPreparedStatement():New(cQuery)
		Endif

		For nI := 1 to Len(aParCalend)
			If nI == 1
				__CtbPeridos:SetNumeric(nI,aParCalend[nI]) // manda string sem aspas
			Else
				__CtbPeridos:SetString(nI,aParCalend[nI])  // manda com aspas string de data pro banco
			EndIf
		Next nI
		TMPCTG := MPSYSOpenQuery(__CtbPeridos:GetFixQuery(),TMPCTG )

		If (TMPCTG)->(!Eof())
			While (TMPCTG)->(!Eof())
				Aadd( aRet, { STOD((TMPCTG)->CTG_DTINI), STOD((TMPCTG)->CTG_DTFIM),;
					(TMPCTG)->CTG_EXERC, (TMPCTG)->CTG_STATUS } )
				If lExercicio
					lAchouFim := .T.
				Else
					lAchouFim := ( STOD((TMPCTG)->CTG_DTFIM) >= dDtFim )
				EndIf
				(TMPCTG)->(dbSkip())
			EndDo
			If lZeradas
				Aadd( aRet, {	CTOD("  /  /  "), CTOD("  /  /  "), Space(4), " " })
			Endif
			If !lAchouFim		//	Se nao encontrou no calendario a data final do intervalo, nao permitir continuar
				aRet := {}
				Aadd( aRet, {	CTOD("  /  /  "), CTOD("  /  /  "), Space(4), " " })
			Endif
		Else
			Aadd( aRet, {	CTOD("  /  /  "), CTOD("  /  /  "), Space(4), " " })
		EndIf
		
		dbSelectArea(TMPCTG)
		dbCloseArea()
	EndIf
	
	RestArea(aAreaPer)
	aSize(aAreaPer,0)
	aAreaPer := nil 
	
	aAdd( __aCtbPer_, { cMoeda, dDtIni, dDtFim, lExercicio, lZeradas, cCalend, cCriter, aClone(aRet) } )

EndIf

aSize(aParCalend,0)
aParCalend := nil 
aSize(aBind,0)
aBind := nil 

RETURN aRet

//-------------------------------------------------------------------
/*{Protheus.doc} CtbPerClear()

@author Totvs
@since   14/06/2019
@version 1.0
@project 
@return  

@obsENG  Function Used to clear cache used in function CtbPeriodos
@obsPOR  Limpa cache da funcao CtbPeriodos
@obsSPA  Funci?n Se usa para limpar cache funcion CtbPeriodos
*/
//-------------------------------------------------------------------

Function CtbPerClear()

__aCtbPer_ := {}

Return

/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o	 ³CtbOQMudou ³ Autor ³ Pilar S. Albaladejo 			   ³ Data ³ 27/11/00 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Verifica o que foi alterado                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe	 ³CtbOQMudou(lAltDeb,lAltCrd,lAltValor,lAltTpSald,lAltMoeda,;		 	 ³±±
±±³			 ³		cTipo,cTipoAnt,nValor,nValorAnt,cTpSald,cTpSaldAnt,cMoeda,		 ³±±
±±³			 ³		cMoedaAnt,cOperacao)											 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno	 ³Nenhum                                                      			 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso		 ³ Generico 												 			 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpL1 = Indica se foi feito alguma alteracao a debito				 ³±±
±±³			 ³ ExpL2 = Indica se foi feito alguma alteracao a credito				 ³±±
±±³			 ³ ExpL3 = Indica se foi feito alguma alteracao no valor				 ³±±
±±³			 ³ ExpL4 = Indica se foi feito alguma alteracao no tipo de saldo		 ³±±
±±³			 ³ ExpL5 = Indica se foi feito alguma alteracao na moeda				 ³±±
±±³			 ³ ExpC1 = Tipo do lancamento 											 ³±±
±±³			 ³ ExpC2 = Tipo do lancamento anterior									 ³±±
±±³			 ³ ExpN1 = Valor               											 ³±±
±±³			 ³ ExpN2 = Valor anterior         										 ³±±
±±³			 ³ ExpC3 = Tipo de Saldo           									 	 ³±±
±±³			 ³ ExpC4 = Tipo de Saldo anterior  									 	 ³±±
±±³			 ³ ExpC5 = Moeda                   										 ³±±
±±³			 ³ ExpC6 = Moeda anterior          										 ³±±
±±³			 ³ ExpC7 = Alteracao efetuada no tipo do lancamento						 ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function CtbOQMudou(lAltDeb,lAltCrd,lAltValor,lAltTpSald,lAltMoeda,;
					cTipo,cTipoAnt,nValor,nValorAnt,cTpSald,cTpSaldAnt,cMoeda,cMoedaAnt,;
					cOperacao)

// Verifica o que ira descalcular
// Anterior = Debito / Atual = Credito				-> Descalcula Debito
//																-> Recalcula Credito
If cTipoAnt == "1" .And. cTipo == "2"
	If cOperacao == "D"			// Desgrava
		lAltDeb := .T.
	Else
		lAltCrd := .T.				// Regrava
	EndIf				
EndIf
// Anterior = Debito / Atual = Partida Dobrada	-> Descalcula Debito
//																-> Recalcula Credito e Debito
If cTipoAnt == "1" .And. cTipo == "3"
	If cOperacao == "D"			// Desgrava
		lAltDeb := .T.	
	Else	 							// Regrava
		lAltDeb := .T.
		lAltCrd := .T.
	EndIf			
EndIf
// Anterior = Credito / Atual = Debito 			-> Descalcula Credito
//																-> Recalcula Debito
If cTipoAnt == "2" .And. cTipo == "1"
	If cOperacao == "D"			// Desgrava
		lAltCrd := .T.
	Else
		lAltDeb := .T.				// Regrava
	EndIf		
EndIf
// Anterior = Credito / Atual = Partida Dobrada -> Descalcula Credito
//																-> Recalcula Debito / Credito
If cTipoAnt == "2" .And. cTipo == "3"
	If cOperacao == "D"
		lAltCrd := .T.
	Else      
		lAltDeb := .T.
		lAltCrd := .T.
	EndIf	
EndIf
// Anterior = Partida Dobrada / Atual = Debito	-> Descalcula os dois
//															   -> Recalcula Debito
If cTipoAnt == "3" .And. cTipo == "1"
	If cOperacao == "D"
		lAltCrd := .T.
		lAltDeb := .T.
	Else
		lAltDeb := .T.
	EndIf		
EndIf
// Anterior = Partida Dobrada / Atual = Credito -> Descalcula os dois
//																-> Recalcula Credito
If cTipoAnt == "3" .And. cTipo == "2"
	If cOperacao == "D"
		lAltDeb := .T.
		lAltCrd := .T.
	Else
		lAltCrd := .T.
	EndIf	
EndIf
If nValorAnt != nValor
	lAltValor := .T.
EndIf
If cTpSaldAnt != cTpSald
	lAltTpSald:= .T.
EndIf
If cMoedaAnt != cMoeda
	lAltMoeda := .T.
EndIf

Return


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Program   ³CTBCBOX   ³ Autor ³ Pilar S. Albaladejo   ³ Data ³ 22.04.01 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Monta Combo Box para exibir na tela                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³CtbCbox(cCampo)                                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ Array com combo box                                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Generico                                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpC1 = Campo que tera o Combo Box anexado                 ³±±
±±³          ³ ExpC2 = String contendo item a nao ser apresentado "56"    ³±±
±±³          ³ ExpN1 = Tamanho a ser verificado a cada item da string     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function CtbCbox(cCampo,cForaCombo,nLenGrava)

Local aArray1	:= {}
Local aArray2	:= {}
Local aSaveArea	:= GetArea()

Local cVar

Local nCont		:= 0

DEFAULT cForaCombo := ""
DEFAULT nLenGrava  := 1

dbSelectArea("SX3")
dbSetOrder(2)
MsSeek(cCampo)

cVar 	:= X3CBox()

If Empty(cVar)
	Return aArray2
Endif

aArray1	:= RetSx3Box(cVar,,,1)    

For nCont := 1 To Len(aArray1)
	If cForaCombo <> "" .And. Left(aArray1[nCont][1], nLenGrava) $ cForaCombo
		Loop
	Endif
	AADD(aArray2,aArray1[nCont][1])
Next nCont	

RestArea(aSaveArea)

Return aArray2


/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³CtbPosic   ³ Autor ³ Pilar S. Albaladejo   ³ Data ³ 04.07.01³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Posiciona nos registros de cadastros                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³CtbPosic(Cta,cc,Item,Clvlr)                        		  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³.T./.F.                                   				  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Generico                                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpC1 = Conta                                              ³±±
±±³          ³ ExpC2 = Centro de Custo                                    ³±±
±±³          ³ ExpC3 = Item                                               ³±±
±±³          ³ ExpC4 = Classe de Valor                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function CtbPosic(cConta,cCusto,cItem,cCLVL)
Local cPesqCT1 
Local cPesqCTT 
Local cPesqCTD 
Local cPesqCTH 
Local nPos := 0
Local cFilCTB 
//Local lCache := CtbCache(4)
// Plano de Contas

//- controle de cache da filial
If _oFilCTB == nil 
	_oFilCTB      := JsonObject():New()
EndIf 
If !Empty(cConta)
	//- valida a existência do cache
	If (cFilCTB := _oFilCTB[cEmpAnt+cFilAnt+'CT1']) == nil 
		cFilCTB := FWxFilial('CT1')
		_oFilCTB[cEmpAnt+cFilAnt+'CT1'] := cFilCTB
	EndIf 

	cPesqCT1 := "CT1"+cFilCTB+cConta

	If (nPos := __CtbPosic[cPesqCT1]) == nil 
		CT1->(dbSetOrder(1))
		If CT1->(MsSeek(SubStr(cPesqCT1,4)))
			__CtbPosic[cPesqCT1] := CT1->(Recno())
		Else
			__CtbPosic[cPesqCT1] := 0
		EndIf   
	ElseIf nPos > 0
		CT1->(MsGoto(nPos))
	EndIf
Endif

// Centro de Custo
If !Empty(cCusto)
	
	//- valida a existência do cache
	If (cFilCTB := _oFilCTB[cEmpAnt+cFilAnt+'CTT']) == nil 
		cFilCTB := FWxFilial('CTT')
		_oFilCTB[cEmpAnt+cFilAnt+'CTT'] := cFilCTB
	EndIf 

	cPesqCTT := "CTT"+cFilCTB+cCusto
	
	If (nPos := __CtbPosic[cPesqCTT]) == nil 
		CTT->(dbSetOrder(1))
		If CTT->(MsSeek(SubStr(cPesqCTT,4)))
			__CtbPosic[cPesqCTT] := CTT->(Recno())
		Else
			__CtbPosic[cPesqCTT] := 0
		EndIf   
	ElseIf nPos > 0
		CTT->(MsGoto(nPos))
	EndIf
Endif	

// Item Contabil
If !Empty(cItem)

	//- valida a existência do cache
	If (cFilCTB := _oFilCTB[cEmpAnt+cFilAnt+'CTD']) == nil 
		cFilCTB := FWxFilial('CTD')
		_oFilCTB[cEmpAnt+cFilAnt+'CTD'] := cFilCTB
	EndIf 

	cPesqCTD := "CTD"+cFilCTB+cItem 

	If (nPos := __CtbPosic[cPesqCTD]) == nil
		CTD->(dbSetOrder(1))
		If CTD->(MsSeek(SubStr(cPesqCTD,4)))
			__CtbPosic[cPesqCTD] := CTD->(Recno())
		Else
			__CtbPosic[cPesqCTD] := 0
		EndIf   
	ElseIf nPos > 0
		CTD->(MsGoto(nPos))
	EndIf
Endif

// Classe de Valor
If !Empty(cClVl)
	
	//- valida a existência do cache
	If (cFilCTB := _oFilCTB[cEmpAnt+cFilAnt+'CTH']) == nil 
		cFilCTB := FWxFilial('CTH')
		_oFilCTB[cEmpAnt+cFilAnt+'CTH'] := cFilCTB
	EndIf 

	cPesqCTH := "CTH"+cFilCTB+cCLVL 
	
	If (nPos := __CtbPosic[cPesqCTH]) == nil
		CTH->(dbSetOrder(1))
		If CTH->(MsSeek(SubStr(cPesqCTH,4)))
			__CtbPosic[cPesqCTH] := CTH->(Recno())
		Else
			__CtbPosic[cPesqCTH] := 0
		EndIf   
	Elseif nPos > 0
		CTH->(MsGoto(nPos))
	EndIf
Endif

Return

/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ CtbCtsM      ³ Autor ³ Wagner Mobile Costa	³ Data ³ 25/10/01 ³±± 
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Funcao para uso em consulta SXB para  apresentar registros  do ³±± 
±±³          ³ plano gerencial atual                                          ³±± 
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Ctba160                                                        ³±± 
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

Function CtbCtsM(lFilial)

DEFAULT lFilial := .T.

Return If(lFilial, xFilial("CTS"), "") + cCts_CodPla


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºFuncao    ³GrafSavBmp  ºAutor³Claudio D. de Souza º Data ³  30/08/01   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Salvar o grafico em BMP                                    º±±
±±º          ³ Parametro: oGrafic -> Objeto grafico                       º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Administrativo                                             º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function GrafSavBmp( oGraphic )

Local cBmpName, cTmp
Local cWhereToSave := "\" // Somente gravar abaixo do rootpath do servidor
Local cRaizServer // Onde sera criado o arquivo da imagem

cBmpName := cGetFile(STR0005 + FunName() + ".BMP", STR0006 ) //"Arquivos BMP | "###"Selecione arquivo .BMP"

If Empty(cBmpName)
	Return
Endif

If Rat("\", cBmpName) > 0
	cWhereToSave 	:= Subs(cBmpName, 1, Rat("\", cBmpName))
	cBmpName	    := Subs(cBmpName, Rat("\", cBmpName) + 1)
Endif

If At(":", cWhereToSave) > 0
	cTmp := CriaTrab(, .F.) + ".BMP"
	cRaizServer := If(issrvunix(), "/", "\")
	If oGraphic:SaveToBMP( cTmp , cRaizServer )
		__CopyFile(cRaizServer + cTmp, cWhereToSave + cBmpName)
		Ferase(cRaizServer + cTmp)
		Help(" ",1,"CT5CRIA3",,STR0007+cBmpName+STR0008,1,0) //"Arquivo: "###" gerado com sucesso"
	Else
		Help(" ",1,"CT5CRIA2",,STR0009,1,0)//"Nao foi possivel gerar o arquivo bitmap do grafico"
	Endif
Else
	If oGraphic:SaveToBMP( cBmpName , cWhereToSave )
		Help(" ",1,"CT5CRIA4",,STR0007+cBmpName+STR0008,1,0)//"Arquivo: "###" gerado com sucesso"
	Else
		Help(" ",1,"CT5CRIA5",,STR0009,1,0)//"Nao foi possivel gerar o arquivo bitmap do grafico"
	Endif
Endif

Return Nil

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Program   ³ ConsDadGraf ³ Autor ³ Wagner Mobile Costa   ³ Data ³ 10.11.01 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Monta Browse de consulta sobre array utilizado para graficos  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function ConsDadGraf(aDados)
Local aTit := {}, aLenCol := {}, nLenTot := 0
Local oView, oDlg, aView := {}, nView        
Local nX	:= 0

If Len(aDados) > 1
	For nx := 1 to Len(aDados[1])
		Aadd(aTit, aDados[1][nX])
		If Len(aDados[1][nX]) > Len(aDados[2][nX])
			Aadd(aLenCol, GetTextWidth(0,Replicate("B", Len(aDados[2][nX]))))
		Else
			Aadd(aLenCol, GetTextWidth(0,Replicate("B", Len(aDados[1][nX]))))
		Endif		
		nLenTot += aLenCol[Len(aLenCol)]
	Next

	nLenTot := (370*nLenTot)/130

	DEFINE MSDIALOG oDlg FROM 0,0 TO 285,Min(nLenTot,oMainWnd:nRight-oMainWnd:nLeft - 10)  PIXEL TITLE STR0010 //"Consulta dados do grafico"

	oView	:= TWBrowse():New( 1,1,	((oDlg:nRight - oDlg:nLeft) / 2) - 5,;
												(oDlg:nBottom / 2) - 15,,;
				aTit,aLenCol,oDlg,,,,,,,,,,,,.F.,,.T.,,.F.,,,)

	For nView := 2 To Len(aDados)
		Aadd(aView, aDados[nView])
	Next

	oView:SetArray(aView)
	oView:bLine := { || aView[oView:nAT]}

	ACTIVATE MSDIALOG oDlg CENTER
Else
	Aviso(STR0002,STR0059,{STR0060})
EndIf
Return

/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³CtQualSaldo³ Autor ³ Wagner Mobile Costa   ³ Data ³ 19.03.2002		³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Checa qual registro deve ser considerado como saldo atual  			³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ CtQualSaldo(lImpAntLP, lNaoAchei, cAlias)                     	    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ SigaCtb                                                   			³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpL1 = Imprime posicao anterior L/P                      		    ³±±
±±³          ³ ExpL2 = Variavel que indica se a data encontrada nao for exata	    ³±±
±±³          ³ ExpB1 = Bloco de codigo de checagem se foi encontrado     		    ³±±
±±³          ³ ExpC1 = Alias para checagem                               		    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

Function CtQualSaldo(lImpAntLP, lNaoAchei, bCondicao, cAlias)

DEFAULT cAlias := Alias()

// Procuro sempre o primeiro registro, caso encontro um registro de zeramento
// e quero a posicao anterior de lucros e perdas, volto 	

If Eval(bCondicao) .And. &(cAlias + "_LP") = "S" .And. ! lImpAntLP
	DbSkip()
	If !Eval(bCondicao) .Or. ! &(cAlias + "_LP") = "Z"
		DbSkip(-1)
	Endif
ElseIf Eval(bCondicao) .And. &(cAlias + "_LP") = "Z" .And. lImpAntLP
	DbSkip(-1)
ElseIf (! Eval(bCondicao) .Or. Eof())
	DbSkip(-1)
	If lImpAntLP .And. &(cAlias + "_LP") = "Z"
		DbSkip(-1)
	Endif
	lNaoAchei := .T.
Endif
	
Return .T.

/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³CtbTitSaldo ³ Autor ³ Wagner Mobile Costa  ³ Data ³ 10.07.2002		³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Funcao de retorno do tipo de saldo para apresentacao nos balancetes	³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ CtbTitSaldo(cTpSald)                                         	  	³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ SigaCtb                                                   			³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ cTpSald = Tipo de saldo selecionado                            		³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

Function CtbTitSaldo(cTpSald)

Local cTitulo := ""
Default cTpSald := ""

If cTpSald == "0" .Or. cTpSald > "1"			
	cTitulo += " (" + Tabela("SL", cTpSald, .F.) + ")"
Endif

Return cTitulo

/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao    ³ CtbImpReg    ³ Autor ³ Wagner Mobile Costa	³ Data ³ 12/03/02 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Importa registros gerados para base do dicionario              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³CtbImpReg( cAlias, aRegistros )                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³Nenhum                                                      	  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso		 ³ CtbaUpd                                                    	  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpC1 = Alias para importacao da matriz                    	  ³±±
±±³          ³ ExpA1 = Array na mesma ordem dos campos (gerado p/Delimitador) ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function CtbImpReg(cAlias, aRegistros)

Local aEstrutura, nRegs, nCpos
Local lAppend
Local lRet	:= .T.

DbSelectArea(cAlias)

If cAlias = "SIX"
	aEstrutura := { "INDICE", "ORDEM", "CHAVE", "DESCRICAO", "DESCSPA", "DESCENG",;
					"PROPRI","F3", "NICKNAME" }
ElseIf cAlias = "SX3"
	aEstrutura := {  "X3_ARQUIVO", "X3_ORDEM", "X3_CAMPO", "X3_TIPO", "X3_TAMANHO",;
	  				 "X3_DECIMAL", "X3_TITULO", "X3_TITSPA", "X3_TITENG", "X3_DESCRIC",;
	  				 "X3_DESCSPA", "X3_DESCENG", "X3_PICTURE", "X3_VALID", "X3_USADO",;
	  				 "X3_RELACAO", "X3_F3", "X3_NIVEL", "X3_RESERV", "X3_CHECK",;
	  				 "X3_TRIGGER", "X3_PROPRI", "X3_BROWSE", "X3_VISUAL", "X3_CONTEXT",;
	  				 "X3_OBRIGAT", "X3_VLDUSER", "X3_CBOX", "X3_CBOXSPA", "X3_CBOXENG",;
	  				 "X3_PICTVAR", "X3_WHEN", "X3_INIBRW", "X3_GRPSXG", "X3_FOLDER" }
	DbSetOrder(2)		// Ordem por campo
Else
	lRet := .F.
	Help(" ",1,"CtbImpReg",,STR0058,1,0) //"Tabela de dicionário de dados não suportada pela função."
Endif

If lRet
	For nRegs := 1 To Len(aRegistros)
		lAppend := .T.
		If cAlias = "SIX"
			lAppend := ! DbSeek(aRegistros[nRegs][1] + aRegistros[nRegs][2])
			If lAppend .And. Select(aRegistros[nRegs][1]) > 0
				(aRegistros[nRegs][1])->(DbCloseArea())
			Endif
		ElseIf 	cAlias = "SX3"
			lAppend := ! DbSeek(aRegistros[nRegs][3])
		Endif
	
		If lAppend
			DbAppend()
			For nCpos := 1 To Len(aEstrutura)
				Replace &(aEstrutura[nCpos]) With aRegistros[nRegs][nCpos]
			Next
		Endif
	Next
EndIf

Return lRet


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³ Fun‡ao    ³Ctbr380Val³ Autor ³ Wagner Mobile Costa   ³ Data ³ 08/05/02 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Descri‡…o ³ Calcula o valor da variacao monetaria da data-base (CT2)   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso       ³ CTBR380                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

Function Ctbr380Val(lPlGer, aContas)

Local lDebito 	:= .F., cCriter, nTaxa := 0, nSal1C, aAnaCta := {}, nAnaCta := 1

DEFAULT lPlGer 	:= .F.
DEFAULT aContas	:= { cArqTmp->CONTA }

// Se for plano gerencial, devera eleger somente contas que tenham variacao monetaria

If ! lPlGer .And. Empty(CT1->CT1_CTAVM) .And. cArqTmp->TIPOCONTA = "2"
	DbDelete()
ElseIf cArqTmp->TIPOCONTA = "2"
	If mv_par20 = 1
		If ValType(aContas[1]) = "A"
			For nAnaCta := 1 To Len(aContas)
				CT1->(DbSeek(xFilial() + aContas[nAnaCta][1]))
				While 	CT1->CT1_FILIAL = xFilial() .And.;
						CT1->CT1_CONTA <= aContas[nAnaCta][2] .And. ! CT1->(Eof())
					If CT1->CT1_CLASSE = "2"
						Aadd(aAnaCta, CT1->CT1_CONTA)
					Endif
					CT1->(DbSkip())
				EndDo
			Next
		Else
			aAnaCta := Aclone(aContas)
		Endif
		For nAnaCta := 1 To Len(aAnaCta)
			CT2->(DbSetOrder(2))
			If CT2->(DbSeek(xFilial() + aAnaCta[nAnaCta] + Dtos(mv_par01)))
				While 	CT2->CT2_DEBITO = aAnaCta[nAnaCta] 	.And.;
						CT2->CT2_DATA = mv_par01 			.And. ! CT2->(Eof())
					If CT2->CT2_MOEDLC = mv_par07 .And. CT2->CT2_ROTINA = "CTBA380"
						Replace COLUNA_1 With CT2->CT2_VALOR * -1
						lDebito := .T.
					Endif
					CT2->(DbSkip())
				EndDo
			Endif
			CT2->(DbSetOrder(3))
			If ! lDebito .And. CT2->(DbSeek(xFilial() + aAnaCta[nAnaCta] + Dtos(mv_par01)))
				While 	CT2->CT2_CREDIT = aAnaCta[nAnaCta] 	.And.;
						CT2->CT2_DATA = mv_par01 			.And. ! CT2->(Eof())
					If CT2->CT2_MOEDLC = mv_par07 .And. CT2->CT2_ROTINA = "CTBA380"
						Replace COLUNA_1 With CT2->CT2_VALOR
						lDebito := .T.
					Endif
					CT2->(DbSkip())
				EndDo
			Endif
		Next
		CT2->(DbSetOrder(1))
	Else
		If mv_par21 = 2
			If cArqTmp->NORMAL = "1"
				cCriter := &("CT1->CT1_CVD" + mv_par07)
			Else
				cCriter := &("CT1->CT1_CVC" + mv_par07)
			Endif
			If cCriter = "1" .And. CTP->(DbSeek(xFilial()+DTOS(mv_par01)+mv_par07))
				nTaxa := CTP->CTP_TAXA
			ElseIf cCriter = "2"
				nTaxa := aMedias[Val(mv_par07)]
			ElseIf cCriter = "3" .And. CTP->(DbSeek(xFilial()+DTOS(LastDay(mv_par01))+mv_par07))
				nTaxa := CTP->CTP_TAXA
			Endif
		Else
			If CTO->CTO_MOEDA # mv_par07	// Garanto que a moeda esteja posicionada
				CTO->(DbSeek(xFilial() + mv_par07))
			Endif
			cCriter := CTO->CTO_CRITER
			If cCriter = "1" .And. CTP->(DbSeek(xFilial()+DTOS(mv_par01)+mv_par07))
				nTaxa := CTP->CTP_TAXA
			ElseIf cCriter = "2"
				nTaxa := aMedias[Val(mv_par07)]
			ElseIf cCriter = "3" .And. CTP->(DbSeek(xFilial()+DTOS(LastDay(mv_par01))+mv_par07))
				nTaxa := CTP->CTP_TAXA
			ElseIf cCriter = "4"
				nTaxa := CTO->CTO_TXINF
			Endif
		Endif
	
		nSal1C := NoRound(MOVIMENTO1 / nTaxa, 2)
		If 	nTaxa > 0 .And. nSal1C <> 0 .And. nSal1C <> MOVIMENTO2
			Replace COLUNA_1 With MOVIMENTO2 - nSal1C
		Endif		
	Endif
	
	If COLUNA_1 = 0 .And. mv_par06 = 2
		DbDelete()
	Else
		Replace COLUNA_2 	With MOVIMENTO2
		Replace MOVIMENTO2  With MOVIMENTO2 - COLUNA_1
		Replace VARIACAO 	With Round(NoRound((Abs(COLUNA_1) / Abs(MOVIMENTO2)) * 100, 2), 2)
	Endif
ElseIf cArqTmp->TIPOCONTA = "1"
	Replace VARIACAO 	With Round(NoRound((Abs(COLUNA_1) / Abs(MOVIMENTO2)) * 100, 2), 2)
Endif

Return

/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³CtbCCSup  ³ Autor ³ Simone Mie Sato       ³ Data ³ 02.10.03 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Gera Codigo do Centro de Custo Superior                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³CtbCCSup(cCodigo)                                           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³cCod                                                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Generico                                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpC1 = Codigo do Centro de Custo                          ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function CtbCCSup(cCodigo)

Local aAmbSave 	:= { Alias(), Indexord(), Recno() }
Local nTamCC	:= Len(CriaVar("CTT_CUSTO"))
Local aAmbCTT  := { CTT->(IndexOrd()) , CTT->(Recno()) }
Local cCod , nCont

cCodigo			:= Alltrim(cCodigo)

dbSelectArea("CTT") ; dbSetOrder(1)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ PONTO DE ENTRADA CTBCCSUP                            ³
//³ Criado para gerar c.c.  superior caso nao            ³
//³ siga a regra padrao do Sistema.                      ³
//³ Recebe em PARAMIXB o centro de custo atual.          ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If _lCTBCCSUP
	cCod := ExecBlock("CTBCCSUP",.F.,.F.,cCodigo)
Else
	For nCont := 1 to Len(cCodigo)
		cCod  := padr(Substr(cCodigo,1,Len(cCodigo)-nCont),nTamCC)
		If MsSeek(xFilial()+cCod,.f.)
			cCod := CTT->CTT_CUSTO
			Exit
		EndIf
	Next
EndIf

CTT->(DbSetOrder(aAmbCTT[1])) ; CTT->(DbGoto(aAmbCTT[2]))
DbSelectArea(aAmbSave[1]) ; DbSetOrder(aAmbSave[2]) ; DbGoto(aAmbSave[3])

Return cCod

/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³CtbItemSup³ Autor ³ Simone Mie Sato       ³ Data ³ 03.10.03 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Gera Codigo do Item Contabil Superior                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³CtbItemSup(cCodigo)                                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³cCod                                                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Generico                                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpC1 = Codigo do Item Contabil                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function CtbItemSup(cCodigo)

Local aAmbSave 	:= { Alias(), Indexord(), Recno() }
Local nTamItem	:= Len(CriaVar("CTD_ITEM"))
Local aAmbCTD	:= { CTD->(IndexOrd()) , CTD->(Recno()) }
Local cCod , nCont

cCodigo			:= Alltrim(cCodigo)

dbSelectArea("CTD") ; dbSetOrder(1)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ PONTO DE ENTRADA CTBITSUP                            ³
//³ Criado para gerar item  superior caso nao            ³
//³ siga a regra padrao do Sistema.                      ³
//³ Recebe em PARAMIXB o item contabil  atual.           ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If _lCTBITSUP
	cCod := ExecBlock("CTBITSUP",.F.,.F.,cCodigo)
Else
	For nCont := 1 to Len(cCodigo)
		cCod  := padr(Substr(cCodigo,1,Len(cCodigo)-nCont),nTamItem)
		If MsSeek(xFilial()+cCod,.f.)
			cCod := CTD->CTD_ITEM 
			Exit
		EndIf
	Next
EndIf

CTD->(DbSetOrder(aAmbCTD[1])) ; CTD->(DbGoto(aAmbCTD[2]))
DbSelectArea(aAmbSave[1]) ; DbSetOrder(aAmbSave[2]) ; DbGoto(aAmbSave[3])

Return cCod


/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³CtbClVlSup³ Autor ³ Simone Mie Sato       ³ Data ³ 03.10.03 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Gera Codigo da Cl.Valor Superior                           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³CtbClVlSup(cCodigo)                                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³cCod                                                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Generico                                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpC1 = Codigo da Classe de Valor                          ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function CtbClVlSup(cCodigo)

Local aAmbSave 	:= { Alias(), Indexord(), Recno() }
Local nTamClVl	:= Len(CriaVar("CTH_CLVL"))
Local aAmbCTH	:= { CTH->(IndexOrd()) , CTH->(Recno()) }
Local cCod , nCont

cCodigo			:= Alltrim(cCodigo)

dbSelectArea("CTH") ; dbSetOrder(1)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ PONTO DE ENTRADA CTBCVSUP                            ³
//³ Criado para gerar Cl.Vlr. superior caso nao          ³
//³ siga a regra padrao do Sistema.                      ³
//³ Recebe em PARAMIXB a cl.Valor Atual.                 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If _lCTBCVSUP
	cCod := ExecBlock("CTBCVSUP",.F.,.F.,cCodigo)
Else
	For nCont := 1 to Len(cCodigo)
		cCod  := padr(Substr(cCodigo,1,Len(cCodigo)-nCont),nTamClVl)
		If MsSeek(xFilial()+cCod,.f.)
			cCod := CTH->CTH_CLVL 
			Exit
		EndIf
	Next
EndIf

CTH->(DbSetOrder(aAmbCTH[1])) ; CTH->(DbGoto(aAmbCTH[2]))
DbSelectArea(aAmbSave[1]) ; DbSetOrder(aAmbSave[2]) ; DbGoto(aAmbSave[3])

Return cCod

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³CtbRelDig ºAutor  ³Simone Mie Sato     º Data ³  30/01/04   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Retorna ate qual digito da entidade contabil sera impresso  º±±
±±º          ³no Relatorio.                                               º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºParametro1³ cSegAte   = Ate qual segm.da masc. contab.sera considerado.º±±
±±º         2³ cMascara	 = Qual a mascara a ser considerada.          	  º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function CtbRelDig(cSegAte,cMascara) 

Local aSaveArea	:= GetArea()
Local nSegAte	:= 0
Local nCont		:= 0
Local nDigitAte	:= 0

nSegAte	:= Val(cSegAte) *2
For nCont := 1 to nSegAte STEP 2
	nDigitAte += Val(Subs(cMascara,nCont,2))
Next nCont                                      


RestArea(aSaveARea)

Return(nDigitAte)

/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³CtbNivCta   ³ Autor ³ Simone Mie Sato      ³ Data ³ 24.03.2005		³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Retorna o nivel da conta                                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ CtbNivCta()                                                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ SigaCtb                                                   			³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ cConta 	   = Codigo da conta                            		   	³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function CtbNivCta(cConta)

Local aSaveArea	:= GetArea()

Local nNivel	:= 1 
Local nRecno	:= CT1->(Recno())                   

dbSelectArea("CT1")       
dbSetOrder(1)
If MsSeek(xFilial()+cConta)	
	While !Eof() .And. CT1->CT1_FILIAL == xFilial() .And. !Empty(CT1->CT1_CTASUP)
		If MsSeek(xFilial()+CT1->CT1_CTASUP)
	    	nNivel++
 		Else
 			dbSkip()
		EndIf	
	End
EndIf

dbSelectArea("CT1")
dbGoto(nRecno)

RestArea(aSaveArea)
aSize(aSaveArea,0)
aSaveArea := nil 

Return(nNivel)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³RETRECNOLPºAutor  ³Marcos S. Lobo      º Data ³  01/12/06   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Retorna os recno do registro de origem de acordo com o lanç.º±±
±±º          ³padrao.                                                     º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function RetRecnoLP(cPadrao,cTabOrigem,cAliasPos)

Local nRecOrigem := 0
Local nPosORISE2 := 0 		/// POSICAO ORIGINAL DO SE2 NO CASO DE LP DE RATEIO FIN
Local nPosORISE5 := 0		///POSICAO ORIGINAL DO SE2 NO CASO DE LP DE RATEIO FIN

DEFAULT cTabOrigem := ""
DEFAULT cAliasPos  := ""

If cTabOrigem <> Nil
	cTabOrigem := UPPER(ALLTRIM(cTabOrigem))
EndIf

If Empty(cPadrao) .or. ValType(cPadrao) <> "C"
	UserException("Invalid parameter 1 - RetRecnoLP()")
	Return(0)
EndIf

If ValType(cTabOrigem) <> "C"
	UserException("Invalid parameter 2 - RetRecnoLP("+cPadrao+",)")
	Return(0)
EndIf

DO CASE
CASE 	 cPadrao == "500";	///	Inclusão de Contas a Receber				FIN	FINA040/FINA370	SE1	E1_LA
	.or. cPadrao == "501";	///	Inclusão de Recebimento Antecipado (RA)		FIN	FINA040/FINA370	SE1	E1_LA
	.or. cPadrao == "502";	///	Exclusão de Recebimento Antecipado			FIN	FINA040	SE1	E1_LA
	.or. cPadrao == "503";	///	Substituição de Provisórios					FIN	FINA040	SE1	E1_LA
	.or. cPadrao == "504";	///	Geração de Título Receber por Desdobramento	FIN	FINA040/FINA370	SE1	E1_LA
	.or. cPadrao == "505";	///	Exclusão de Contas a Receber				FIN	FINA040	SE1	E1_LA
	.or. cPadrao == "529"	///	Exclusão de título gerado via desdobramento	FIN	FINA040	SE1	E1_LA

	If Empty(cTabOrigem)	/// SE A TABELA DE ORIGEM FOR INDICADA EM BRANCO 
		cTabOrigem := "SE1"	/// ASSUME A TABELA PADRAO ASSOCIADA AOS LANÇAMENTOS
	EndIf

	If (cTabOrigem)->(Eof()) .and. SEV->(!Eof())	/// VERIFICA SE É RATEIO MULT.NATUREZA SEM RAT.CC (CONTAB PELO 510)
		cTabOrigem := "SEV"
	EndIf

CASE 	 cPadrao == "506";	///	Rateio Centro de Custo Múltipla Natureza Contas a Receber				FIN	FINA040	SE1	E1_LA
	.or. cPadrao == "507";	///	Cancelamento Rateio Centro de Custo Múltipla Natureza Conntas a Receber	FIN	FINA040	SE1	E1_LA
	.or. cPadrao == "536";	// Rateio por C.Custo de MultiNat C.Receber na Baixa
	.or. cPadrao == "539"	// Estorno do rateio C.Custo de MultiMat CR na Baixa

	If Empty(cTabOrigem)	/// SE A TABELA DE ORIGEM FOR INDICADA EM BRANCO 
		If SEV->EV_RATEICC == "1"	/// SE FOR MULTIPLA NATUREZA POR C.CUSTO
			cTabOrigem := "SEZ"	/// MULT.NATUREZA - FLAGS SEV ( função CTBApLAMN() ao apagar )
		Else						/// SE FOR MULTIPLA NATUREZA 
			cTabOrigem := "SEV"	/// MULT.NATUREZA SE BASEIA NO TÍTULO - FLAGS SEZ ( função CTBApLAMN() ao apagar )		
		EndIf
	EndIf

CASE cPadrao == "508";	///	Rateio Centro de Custo Múltipla Natureza Contas a Pagar						FIN	FINA050	SE2	E2_LA
	.or. cPadrao == "509";	///	Cancelamento Rateio Centro de Custo Múltipla Natureza Contas a Pagar	FIN	FINA050	SE2	E2_LA
	.or. cPadrao == "537";	// Rateio por C.Custo de MultiNat C.Pagar na Baixa
	.or. cPadrao == "538"	// Estorno do rateio C.Custo de MultiMat CP na Baixa
                          
	If Empty(cTabOrigem)	/// SE A TABELA DE ORIGEM FOR INDICADA EM BRANCO 
		If SEV->EV_RATEICC == "1"	/// SE FOR MULTIPLA NATUREZA POR C.CUSTO
			cTabOrigem := "SEZ"	/// MULT.NATUREZA - FLAGS SEV ( função CTBApLAMN() ao apagar )
		Else						/// SE FOR MULTIPLA NATUREZA 
			cTabOrigem := "SEV"	/// MULT.NATUREZA SE BASEIA NO TÍTULO - FLAGS SEZ ( função CTBApLAMN() ao apagar )		
		EndIf
	EndIf

CASE 	 cPadrao == "510";	///	Inclusão de Contas a Pagar						FIN	FINA050/FINA370	SE2	E2_LA
	.or. cPadrao == "515";	///	Exclusão de Contas a Pagar						FIN	FINA050	SE2	E2_LA
	.or. cPadrao == "577";	///	Geração de Título a Pagar via desdobramento		FIN	FINA050/FINA370		
	.or. cPadrao == "578";	///	Exclusão de Tít. a Pg gerado via desdobramento	FIN	FINA050		
	.or. cPadrao == "513";	///	Inclusão de Pagamento Antecipado (PA)			FIN	FINA050/FINA370	SE2	E2_LA
	.or. cPadrao == "514";	///	Exclusão de Pagamento Antecipado (PA)			FIN	FINA050	SE2	E2_LA
	.or. cPadrao == "533";	///	Substituição de Provisórios						FIN	FINA050		
	.or. cPadrao == "587";	///	Faturas a Pagar									FIN	FINA290		
 	.or. cPadrao == "593"	///	Cancelamento Faturas a Pagar					FIN	FINA290		
	
	If Empty(cTabOrigem)	/// SE A TABELA DE ORIGEM FOR INDICADA EM BRANCO 

		//--------------------------------------------------------------
		// Define se a Contabilização do LP513 ocorrerá pelo Título(SE2)
		// ou Mov.Bancario(SE5) do Pagamento Antecipado
		//--------------------------------------------------------------
		If cPadrao == "513" .And. SuperGetMv("MV_CTMOVPA",.T.,"1") == "2"
			cTabOrigem := "SE5"	/// ASSUME A TABELA PADRAO ASSOCIADA AOS LANÇAMENTOS
		Else
			cTabOrigem := "SE2"	/// ASSUME A TABELA PADRAO ASSOCIADA AOS LANÇAMENTOS
		EndIf

	EndIf
	
	If (cTabOrigem)->(Eof()) .and. SEV->(!Eof())	/// VERIFICA SE É RATEIO MULT.NATUREZA SEM RAT.CC (CONTAB PELO 510)
		cTabOrigem := "SEV"
	EndIf

CASE 	cPadrao == "511";	///	Inclusão de Contas a Pagar com Rateio Simples	FIN	FINA050/FINA370	SE2	E2_LA
	.or. cPadrao == "512";	///	Exclusão de Contas a Pagar com Rateio Simples	FIN	FINA050	SE2	E2_LA

	If Empty(cTabOrigem)	/// SE A TABELA DE ORIGEM FOR INDICADA EM BRANCO 
		cTabOrigem := "SE2"	/// ASSUME A TABELA PADRAO ASSOCIADA AOS LANÇAMENTOS
	EndIf
	
	If SE2->(Eof()) .and. ValType(STRLCTPAD) == "N"
		nPosORISE2 := SE2->(Recno())
		SE2->(MsGoTo(STRLCTPAD))				/// POSICIONA PARA O RASTREAMENTO CASO ESTEJA EM EOF.
	EndIf

CASE 	 cPadrao == "516";	///	Inclusão Movimento Bancário Pagar com Rateio				FIN	FINA100/FINA370	SE5	E5_LA
	.or. cPadrao == "517";	///	Inclusão Movimento Bancário Receber com Rateio				FIN	FINA100/FINA370	SE5	E5_LA
	.or. cPadrao == "557";	///	Cancelamento de Movimento Bancário Pagar com Rateio			FIN	FINA100		
	.or. cPadrao == "558"	///	Cancelamento de Movimento Bancário Receber com Rateio		FIN	FINA100		

	If Empty(cTabOrigem)	/// SE A TABELA DE ORIGEM FOR INDICADA EM BRANCO 
		cTabOrigem := "SE5"	/// ASSUME A TABELA PADRAO ASSOCIADA AOS LANÇAMENTOS
	EndIf

	If SE5->(Eof()) .and. ValType(STRLCTPAD) == "N"
		nPosORISE5 := SE5->(Recno())
		SE5->(MsGoTo(STRLCTPAD))				/// POSICIONA PARA O RASTREAMENTO CASO ESTEJA EM EOF.
	EndIf

CASE 	 cPadrao == "560";	///	Transferência Financeira/Bancária - Saída do Banco Origem	FIN	FINA100/FINA370		
	.or. cPadrao == "561";	///	Transferência Financeira/Bancária - Entrada Banco Destino	FIN	FINA100/FINA370		
	.or. cPadrao == "562";	///	Movimento Bancário Pagar									FIN	FINA100/FINA370		
	.or. cPadrao == "563";	///	Movimento Bancário Receber									FIN	FINA100/FINA370		
	.or. cPadrao == "564";	///	Cancelamento Movimento Bancário Pagar						FIN	FINA100		
	.or. cPadrao == "565"	///	Cancelamento Movimento Bancário Receber	FIN	FINA100		

	If Empty(cTabOrigem)	/// SE A TABELA DE ORIGEM FOR INDICADA EM BRANCO 
		cTabOrigem := "SE5"	/// ASSUME A TABELA PADRAO ASSOCIADA AOS LANÇAMENTOS
	EndIf

CASE 	 cPadrao == "518";	///	Baixa por Vendor					FIN	FINA080	SE2	E2_LA
	.or. cPadrao == "519"	///	Cancelamento de Baixa por Vendor	FIN	FINA080	SE2	E2_LA

	If Empty(cTabOrigem)	/// SE A TABELA DE ORIGEM FOR INDICADA EM BRANCO 
		cTabOrigem := "SE5"	/// ASSUME A TABELA PADRAO ASSOCIADA AOS LANÇAMENTOS
	EndIf

	If (cTabOrigem)->(Eof()) .and. SEV->(!Eof())	/// VERIFICA SE É RATEIO MULT.NATUREZA SEM RAT.CC (CONTAB PELO 510)
		cTabOrigem := "SEV"
	EndIf

CASE 	 cPadrao == "520";	///	Baixas a Receber Carteira						FIN	FINA060/FINA370	SE5	E5_LA
	.or. cPadrao == "521";	///	Baixas a Receber Cobrança Simples				FIN	FINA060/FINA370	SE5	E5_LA
	.or. cPadrao == "522";	///	Baixas a Receber Cobrança Descontada			FIN	FINA060/FINA370	SE5	E5_LA
	.or. cPadrao == "523";	///	Baixas a Receber Cobrança Caucionada			FIN	FINA060/FINA370	SE5	E5_LA
	.or. cPadrao == "524";	///	Baixas a Receber Cobrança Vinculada				FIN	FINA060/FINA370	SE5	E5_LA
	.or. cPadrao == "525";	///	Baixas a Receber Cobrança Advogado				FIN	FINA060/FINA370	SE5	E5_LA
	.or. cPadrao == "526";	///	Baixas a Receber Cobrança Judicial				FIN	FINA060/FINA370	SE5	E5_LA
	.or. cPadrao == "527";	///	Cancelamento de Baixas a Receber				FIN	FINA060/FINA370	SE5	E5_LA
	.or. cPadrao == "528"	///	Baixas a Receber Cobrança Caucionada Descontada	FIN	FINA060/FINA370	SE5	E5_LA

	If Empty(cTabOrigem)	/// SE A TABELA DE ORIGEM FOR INDICADA EM BRANCO 
		cTabOrigem := "SE5"	/// ASSUME A TABELA PADRAO ASSOCIADA AOS LANÇAMENTOS
	EndIf

	If (cTabOrigem)->(Eof()) .and. SEV->(!Eof())	/// VERIFICA SE É RATEIO MULT.NATUREZA SEM RAT.CC (CONTAB PELO 510)
		cTabOrigem := "SEV"
	EndIf

CASE 	 cPadrao == "530";	///	Baixa Manual Contas a Pagar / Retorno Comunicação Bancária Pagar	FIN	FINA080/FINA370	SE5	E5_LA
	.or. cPadrao == "531";	///	Cancelamento Baixas a Pagar	FIN	FINA080/FINA370	SE5	E5_LA
	.or. cPadrao == "532"	///	Baixas por Borderô de Pagamento	FIN	FINA090/FINA370		

	If Empty(cTabOrigem)	/// SE A TABELA DE ORIGEM FOR INDICADA EM BRANCO 
		cTabOrigem := "SE5"	/// ASSUME A TABELA PADRAO ASSOCIADA AOS LANÇAMENTOS
	EndIf
	
	If (cTabOrigem)->(Eof()) .and. SEV->(!Eof())	/// VERIFICA SE É RATEIO MULT.NATUREZA SEM RAT.CC (CONTAB PELO 510)
		cTabOrigem := "SEV"
	EndIf

CASE 	 cPadrao == "540";	///	Transferência para Carteira	FIN	FINA060/FINA370
	
	If Empty(cTabOrigem)	/// SE A TABELA DE ORIGEM FOR INDICADA EM BRANCO 
		cTabOrigem := "SE1"	/// ASSUME A TABELA PADRAO ASSOCIADA AOS LANÇAMENTOS
	EndIf

CASE 	 cPadrao == "541";	///	Transferência para Cobrança Simples		FIN	FIN
	.or. cPadrao == "541";	///	Transferência para Cobrança Simples	FIN	FINA110		
	.or. cPadrao == "542";	///	Transferência para Cobrança Descontada	FIN	FINA110		
	.or. cPadrao == "543";	///	Transferência para Cobrança Caucionada	FIN	FINA110		
	.or. cPadrao == "544";	///	Transferência para Cobrança Vinculada	FIN	FINA110		
	.or. cPadrao == "545";	///	Transferência para Cobrança Advogado	FIN	FINA110		
	.or. cPadrao == "546";	///	Transferência para Cobrança Judicial	FIN	FINA110		

	If Empty(cTabOrigem)	/// SE A TABELA DE ORIGEM FOR INDICADA EM BRANCO 
		cTabOrigem := "SE5"	/// ASSUME A TABELA PADRAO ASSOCIADA AOS LANÇAMENTOS
	EndIf

CASE 	 cPadrao == "54G";	///	Transferência para Carteira	PIX	FINA891/FINA150
	.or. cPadrao == "54H";	///	Transferência para Cobrança Simples	PIX	FINA891/FINA150

	If Empty(cTabOrigem)	/// SE A TABELA DE ORIGEM FOR INDICADA EM BRANCO 
		cTabOrigem := "F71"	/// ASSUME A TABELA PADRAO ASSOCIADA AOS LANÇAMENTOS
	EndIf

CASE 	 cPadrao == "547";	///	Borderô para Carteira						FIN	FINA110		
	.or. cPadrao == "548";	///	Borderô para Cobrança Simples				FIN	FINA110		
	.or. cPadrao == "549";	///	Borderô para Cobrança Descontada			FIN	FINA110		
	.or. cPadrao == "550";	///	Borderô para Cobrança Caucionada			FIN	FINA110		
	.or. cPadrao == "551";	///	Borderô para Cobrança Vinculada				FIN	FINA110		
	.or. cPadrao == "552";	///	Borderô para Cobrança Advogado				FIN	FINA110		
	.or. cPadrao == "553";	///	Borderô para Cobrança Judicial				FIN	FINA110		
	.or. cPadrao == "554";	///	Cancelamento de Borderô						FIN	FINA110		
	.or. cPadrao == "555";	///	Transferência para Cob.Caucionada DescontadaFIN	FINA110	
	.or. cPadrao == "556"	///	Borderô para Cobrança Caucionada Descontada	FIN	FINA110		

	If Empty(cTabOrigem)	/// SE A TABELA DE ORIGEM FOR INDICADA EM BRANCO 
		cTabOrigem := "SEA"	/// ASSUME A TABELA PADRAO ASSOCIADA AOS LANÇAMENTOS
	EndIf
	
CASE 	 cPadrao == "566";	///	Geração de Cheques sobre Títulos	FIN	FINA390/FINA370		
	.or. cPadrao == "567";	///	Geração de Cheques Avulsos		FIN	FINA390/FINA370		
	.or. cPadrao == "568";	///	Cancelamento de Cheque Avulso	FIN	FINA390		
	.or. cPadrao == "571"	///	Cancelamento de Cheques sobre Títulos	FIN	FINA390		
		
	If Empty(cTabOrigem)	/// SE A TABELA DE ORIGEM FOR INDICADA EM BRANCO 
		cTabOrigem := "SEF"	/// ASSUME A TABELA PADRAO ASSOCIADA AOS LANÇAMENTOS
	EndIf

CASE 	 cPadrao == "569"	///	Redepósito de Cheque sobre Títulos		FIN	FINA390		

	If Empty(cTabOrigem)	/// SE A TABELA DE ORIGEM FOR INDICADA EM BRANCO 
		cTabOrigem := "SE5"	/// ASSUME A TABELA PADRAO ASSOCIADA AOS LANÇAMENTOS
	EndIf

CASE 	 cPadrao == "572";	///	Movimentos do Caixinha										FIN	FINA550		
	.or. cPadrao == "573"	///	Movimentos de Reposição - Banco/Caixinha - Caixinha/Banco	FIN	FINA550/FINA370		

	If Empty(cTabOrigem)	/// SE A TABELA DE ORIGEM FOR INDICADA EM BRANCO 
		cTabOrigem := "SEU"	/// ASSUME A TABELA PADRAO ASSOCIADA AOS LANÇAMENTOS
	EndIf

CASE	 cPadrao == "580";	///	Aplicação Financeira			FIN	FINA171/FINA370		
	.or. cPadrao == "581";	///	Exclusão Aplicação Financeira	FIN	FINA171/FINA370		
	.or. cPadrao == "582";	///	Apropriação / Resgate de Empréstimo	FIN	FINA171/FINA370		
	.or. cPadrao == "584";	///	Estorno Apropriação Aplicação Financeira	FIN	FINA171/FINA370		
	.or. cPadrao == "585";	///	Resgate Aplicação Financeira	FIN	FINA171/FINA370		
	.or. cPadrao == "586"	///	Estorno Empréstimo / Estorno do Resgate de Aplicação Financeira	FIN	FINA171/FINA370		

	If Empty(cTabOrigem)	/// SE A TABELA DE ORIGEM FOR INDICADA EM BRANCO 
		cTabOrigem := "SE5"	/// ASSUME A TABELA PADRAO ASSOCIADA AOS LANÇAMENTOS
	EndIf

CASE 	 cPadrao == "588";	///	Cancelamento Compensação de Contas a Receber	FIN	FINA330		
	.or. cPadrao == "596"	///	Compensação Contas a Receber					FIN	FINA330/FINA370		
	
	If Empty(cTabOrigem)	/// SE A TABELA DE ORIGEM FOR INDICADA EM BRANCO 
		cTabOrigem := "SE5"	/// ASSUME A TABELA PADRAO ASSOCIADA AOS LANÇAMENTOS
	EndIf	
	
CASE 	 cPadrao == "589";	///	Cancelamento Compensação de Contas a Pagar		FIN	FINA340		
	.or. cPadrao == "597"	///	Compensação Contas a Pagar						FIN	FINA340/FINA370		
     
	If Empty(cTabOrigem)	/// SE A TABELA DE ORIGEM FOR INDICADA EM BRANCO 
		cTabOrigem := "SE5"	/// ASSUME A TABELA PADRAO ASSOCIADA AOS LANÇAMENTOS.
	EndIf	

CASE 	 cPadrao == "590";	///	Geração de Cheques		FIN	FINA190/FINA370		
	.or. cPadrao == "591"	///	Cancelamento de Cheques	FIN	FINA190		
	   
	If Empty(cTabOrigem)	/// SE A TABELA DE ORIGEM FOR INDICADA EM BRANCO 
		cTabOrigem := "SEF"	/// ASSUME A TABELA PADRAO ASSOCIADA AOS LANÇAMENTOS.
	EndIf	

CASE 	 cPadrao == "592";	///	Cancelamento Faturas a Receber	FIN	FINA280		
	.or. cPadrao == "595"	///	Faturas a Receber				FIN	FINA280		

	If Empty(cTabOrigem)	/// SE A TABELA DE ORIGEM FOR INDICADA EM BRANCO 
		cTabOrigem := "SE1"	/// ASSUME A TABELA PADRAO ASSOCIADA AOS LANÇAMENTOS.
	EndIf	

CASE 	 cPadrao == "594"	///	Compensação entre Carteiras	FIN	FINA450		
   
	If Empty(cTabOrigem)	/// SE A TABELA DE ORIGEM FOR INDICADA EM BRANCO 
		cTabOrigem := "SE5"	/// ASSUME A TABELA PADRAO ASSOCIADA AOS LANÇAMENTOS.
	EndIf	

CASE 	 cPadrao == "598"	///	Variação Monetária - Contas a Receber	FIN	FINA350		

	If Empty(cTabOrigem)	/// SE A TABELA DE ORIGEM FOR INDICADA EM BRANCO 
		cTabOrigem := "SE1"	/// ASSUME A TABELA PADRAO ASSOCIADA AOS LANÇAMENTOS.
	EndIf	

CASE 	 cPadrao == "5C8";	///	Movimento Bancário - Troco		
	.or. cPadrao == "5C9"	///	Movimento Bancário - Estorno de Troco
	
	If Empty(cTabOrigem)
		cTabOrigem := "FK5"
	EndIf	

CASE 	 cPadrao == "599"	///	Variação Monetária - Contas a Pagar	FIN	FINA350		

	If Empty(cTabOrigem)	/// SE A TABELA DE ORIGEM FOR INDICADA EM BRANCO 
		cTabOrigem := "SE2"	/// ASSUME A TABELA PADRAO ASSOCIADA AOS LANÇAMENTOS.
	EndIf	

CASE 	 cPadrao == "605";	///	Apuração de PIS. Este lançamento somente é executado quando há geração de contas a pagar. (A tabela de títulos a pagar está posicionada).	FIS	MATA996		
	.or. cPadrao == "606";	///	Apuração de COFINS. Este lançamento somente é executado quando há geração de contas a pagar. (A tabela de títulos a pagar está posicionada).	FIS	MATA996		
	.or. cPadrao == "611";	///	Estorno da Apuração de PIS. Este lançamento somente é executado quando há geração de contas a pagar. (A tabela de titulos a pagar está posicionada).	FIS	MATA996/MATA997		
	.or. cPadrao == "608";	///	Estorno da Apuração de CONFIS. Este lançamento somente é executado quando há geração de contas a pagar. (A tabela de titulos a pagar está posicionada).	FIS	MATA996		
	.or. cPadrao == "765";	///	Inclusao CPRB. Este lançamento somente é executado quando há geração de contas a pagar. (A tabela de titulos a pagar está posicionada).	FIS	MATA996		
	.or. cPadrao == "766";	///	Estorno CPRB. Este lançamento somente é executado quando há geração de contas a pagar. (A tabela de titulos a pagar está posicionada).	FIS	MATA996		
	.or. cPadrao == "767";	///	Inclusao Apuração Tributos Genéricos. Este lançamento somente é executado quando há geração de contas a pagar. (A tabela de titulos a pagar está posicionada).	FIS	FISA173	
	.or. cPadrao == "768"	///	Estorno Apuração Tributos Genéricos.. Este lançamento somente é executado quando há geração de contas a pagar. (A tabela de titulos a pagar está posicionada).	FIS	FISA173

	If Empty(cTabOrigem)	/// SE A TABELA DE ORIGEM FOR INDICADA EM BRANCO 
		cTabOrigem := "SE2"	/// ASSUME A TABELA PADRAO ASSOCIADA AOS LANÇAMENTOS.
	EndIf	

CASE 	 cPadrao == "770";	///	Inclusão manual do Bem no CIAP. Este lançamento somente é executado quando há a inclusão de um novo Bem em Manutenção CIAP	FIS	MATA905
	.or. cPadrao == "771"	///	Exclusão manual do Bem no CIAP. Este lançamento somente é executado quando há a inclusão de um novo Bem em Manutenção CIAP	FIS	MATA905

	If Empty(cTabOrigem)	/// SE A TABELA DE ORIGEM FOR INDICADA EM BRANCO 
		cTabOrigem := "SF9"	/// ASSUME A TABELA PADRAO ASSOCIADA AOS LANÇAMENTOS.
	EndIf

CASE 	 cPadrao == "772";	///	Apuração do Simples Nacional. Este lançamento somente é executado quando há apuração do Simples Nacional FIS FISA153
	.or. cPadrao == "773"	///	Estorno Apuração do Simples Nacional. Este lançamento somente é executado quando há estorno de apluração do Simples Nacional FIS FISA153

	If Empty(cTabOrigem)	/// SE A TABELA DE ORIGEM FOR INDICADA EM BRANCO 
		cTabOrigem := "F1A"	/// ASSUME A TABELA PADRAO ASSOCIADA AOS LANÇAMENTOS.
	EndIf	

CASE 	 cPadrao == "610";		///	Contabilização dos itens do documento de saída -  Estão disponíveis as tabelas de Tipo de Entrada e saída, produto, documento de saída e Cliente ou Fornecedor conforme o tipo do documento.	FAT	CTBANFS
	.or. cPadrao == "617";		//	Contabilização dos itens do documento de saída do Tipo Débito/Crédito
	.or. cPadrao == "6B7"		/// Contabilização dos itens do documento de saída manual (MATA920).

	If GetNewPar("MV_OPTNFS",.F.) .and. ALLTRIM(UPPER(FunName())) == "CTBANFS"
		If Empty(cTabOrigem)	/// SE A TABELA DE ORIGEM FOR INDICADA EM BRANCO 
			cTabOrigem := "CTBANFS"	/// ASSUME A TABELA PADRAO ASSOCIADA AOS LANÇAMENTOS.
		EndIf	
		
		If cTabOrigem == "CTBANFS"
			nRecOrigem := CTBANFS->(SD2RECNO)
		Else
			nRecOrigem := (cTabOrigem)->(Recno())
		EndIf		
	Else
		If Empty(cTabOrigem)	/// SE A TABELA DE ORIGEM FOR INDICADA EM BRANCO 
			cTabOrigem := "SD2"	/// ASSUME A TABELA PADRAO ASSOCIADA AOS LANÇAMENTOS.
		EndIf	
	
		nRecOrigem := (cTabOrigem)->(Recno())
	EndIf

	cTabOrigem := "SD2"		/// INDEPENDENTE DE QUERY RETORNA A TABELA PADRAO PARA O RASTREAMENTO

CASE 	 cPadrao == "620";		///	Contabilização do documento de saída - Disponível a tabelas de Cliente ou Fornecedor conforme o tipo do documento.	FAT	CTBANFS				
	.or. cPadrao == "616"		//	Contabilização do Total do documento de saída do Tipo Débito/Crédito 

	If GetNewPar("MV_OPTNFS",.F.) .and. ALLTRIM(UPPER(FunName())) == "CTBANFS"
		If Empty(cTabOrigem)	/// SE A TABELA DE ORIGEM FOR INDICADA EM BRANCO 
			cTabOrigem := "CTBANFS"	/// ASSUME A TABELA PADRAO ASSOCIADA AOS LANÇAMENTOS.
		EndIf	
		
		If cTabOrigem == "CTBANFS"
			nRecOrigem := CTBANFS->(SF2RECNO)
		Else
			nRecOrigem := (cTabOrigem)->(Recno())
		EndIf		
	Else
		If Empty(cTabOrigem)	/// SE A TABELA DE ORIGEM FOR INDICADA EM BRANCO 
			cTabOrigem := "SF2"	/// ASSUME A TABELA PADRAO ASSOCIADA AOS LANÇAMENTOS.
		EndIf	
	
		nRecOrigem := (cTabOrigem)->(Recno())
	EndIf

	cTabOrigem := "SF2"		/// INDEPENDENTE DE QUERY RETORNA A TABELA PADRAO PARA O RASTREAMENTO

CASE 	 cPadrao == "612";	///	Contabilização dos itens do pedido de venda
	.or. cPadrao == "621"	///	Contabilização do cabeçalho do pedido de venda

	If GetNewPar("MV_OPTNFS",.F.) .and. ALLTRIM(UPPER(FunName())) == "CTBANFS"
		If Empty(cTabOrigem)	/// SE A TABELA DE ORIGEM FOR INDICADA EM BRANCO 
			cTabOrigem := "CTBANFS"	/// ASSUME A TABELA PADRAO ASSOCIADA AOS LANÇAMENTOS.
		EndIf	
		
		If cTabOrigem == "CTBANFS"
			nRecOrigem := CTBANFS->(SC5RECNO)
		Else
			nRecOrigem := (cTabOrigem)->(Recno())
		EndIf		
	Else
		If Empty(cTabOrigem)	/// SE A TABELA DE ORIGEM FOR INDICADA EM BRANCO 
			cTabOrigem := "SC5"	/// ASSUME A TABELA PADRAO ASSOCIADA AOS LANÇAMENTOS.
		EndIf	
	
		nRecOrigem := (cTabOrigem)->(Recno())
	EndIf

	cTabOrigem := "SC5"		/// INDEPENDENTE DE QUERY RETORNA A TABELA PADRAO PARA O RASTREAMENTO

CASE	 cPadrao == "630";		///	Contabilização da exclusão dos itens do documento de saída - Estão disponíveis as tabelas de Tipo de Entrada e saída, produto, documento de saída e Cliente ou Fornecedor conforme o tipo do documento.	FAT	CTBANFS
	.or. cPadrao == "619";		/// Contabilização da exclusão dos itens do documento de saída do tipo Débito/Crédito
	.or. cPadrao == "6B8"		/// Contabilização da exclusão dos itens do documento de saída manual (MATA920).

	If Empty(cTabOrigem)	/// SE A TABELA DE ORIGEM FOR INDICADA EM BRANCO 
		cTabOrigem := "SD2"	/// ASSUME A TABELA PADRAO ASSOCIADA AOS LANÇAMENTOS.
	EndIf	

CASE	 cPadrao == "635";		///	Contabilização da exclusão do documento de saída - Disponível a tabelas de Cliente ou Fornecedor conforme o tipo do documento.	FAT						
	.or. cPadrao == "618"		/// Contabilização da exclusão do Total do documento de saída do tipo Débito/Crédito
	
	If Empty(cTabOrigem)	/// SE A TABELA DE ORIGEM FOR INDICADA EM BRANCO 
		cTabOrigem := "SF2"	/// ASSUME A TABELA PADRAO ASSOCIADA AOS LANÇAMENTOS.
	EndIf

CASE 	 cPadrao == "641";	///	Contabilização do rateio dos itens do documento de entrada para Clientes - Estão disponíveis as tabelas de Tipo de Entrada e saída, produto, rateio de itens,  item do documento de entrada e Cliente conforme o tipo do documento. Este lançamento não impede a execução do lançamento 650.	COM						
	.or. cPadrao == "646";  /// Contabilização dos itens do documento de entrad do tipo Debito/Credito - - Estão disponíveis as tabelas de Tipo de Entrada e saída, produto, documento de entrada e Cliente ou Fornecedor conforme o tipo do documento.	COM
	.or. cPadrao == "650";	///	Contabilização dos itens do documento de entrada - Estão disponíveis as tabelas de Tipo de Entrada e saída, produto, documento de entrada e Cliente ou Fornecedor conforme o tipo do documento.	COM			
	.or. cPadrao == "640";	///	Contabilização dos itens do documento de entrada. Estão disponíveis as tabelas de Tipo de entrada e saída, cliente, produto e documento de entrada. Este lançamento somente deve ser utilizado para empresas que apropriam o custo de forma on-line.	COM			
	.or. cPadrao == "651";	///	Contabilização do rateio dos itens do documento de entrada para Fornecedor - Estão disponíveis as tabelas de Tipo de Entrada e saída, produto, rateio de itens,  item do documento de entrada e Fornecedor conforme o tipo do documento. Este lançamento não impede a execução do lançamento 650.	COM			
	.or. cPadrao ==	"950";	///	Contabilização dos itens do documento de entrada especifico para documentos de provenientes do Ambiente de Importação - Estão disponíveis as tabelas de Tipo de Entrada e saída e Cliente ou Fornecedor conforme o tipo do documento. Este lançamento é executado junto com o lançamento 650.	COM
	.or. cPadrao == "6A7"   /// Contabilização dos itens do documento de entrada manual (MATA910). 			

	If GetNewPar("MV_OPTNFE",.F.) .and. ALLTRIM(UPPER(FunName())) == "CTBANFE"
		If Empty(cTabOrigem)	/// SE A TABELA DE ORIGEM FOR INDICADA EM BRANCO 
			cTabOrigem := "CTBANFE"	/// ASSUME A TABELA PADRAO ASSOCIADA AOS LANÇAMENTOS.
		EndIf	
		
		If cTabOrigem == "CTBANFE"
			nRecOrigem := CTBANFE->(SD1RECNO)
		Else
			nRecOrigem := (cTabOrigem)->(Recno())
		EndIf		
	Else
		If Empty(cTabOrigem)	/// SE A TABELA DE ORIGEM FOR INDICADA EM BRANCO 
			cTabOrigem := "SD1"	/// ASSUME A TABELA PADRAO ASSOCIADA AOS LANÇAMENTOS.
		EndIf	
	
		nRecOrigem := (cTabOrigem)->(Recno())
	EndIf

	cTabOrigem := "SD1"		/// INDEPENDENTE DE QUERY RETORNA A TABELA PADRAO PARA O RASTREAMENTO

CASE 	 cPadrao == "642";	///	Contabilização da Devolução de Vendas do Documento de Entrada pelo Total. Estão disponíveis as tabelas de cliente e documento de entrada.	COM						
	.or. cPadrao == "645";  /// Contabilização do documento de entrada do Tipo Debito/Credito - Disponível a tabelas de Cliente ou Fornecedor conforme o tipo do documento.	COM
	.or. cPadrao == "660";	///	Contabilização do documento de entrada - Disponível a tabelas de Cliente ou Fornecedor conforme o tipo do documento.	COM			
	.or. cPadrao == "661"	///	Reservado para Localizações	COM						

	If GetNewPar("MV_OPTNFE",.F.) .and. ALLTRIM(UPPER(FunName())) == "CTBANFE"
		If Empty(cTabOrigem)	/// SE A TABELA DE ORIGEM FOR INDICADA EM BRANCO 
			cTabOrigem := "CTBANFE"	/// ASSUME A TABELA PADRAO ASSOCIADA AOS LANÇAMENTOS.
		EndIf	
		
		If cTabOrigem == "CTBANFE"
			nRecOrigem := CTBANFE->(SF1RECNO)
		Else
			nRecOrigem := (cTabOrigem)->(Recno())
		EndIf		
	Else
		If Empty(cTabOrigem)	/// SE A TABELA DE ORIGEM FOR INDICADA EM BRANCO 
			cTabOrigem := "SF1"	/// ASSUME A TABELA PADRAO ASSOCIADA AOS LANÇAMENTOS.
		EndIf	
	
		nRecOrigem := (cTabOrigem)->(Recno())
	EndIf

	cTabOrigem := "SF1"		/// INDEPENDENTE DE QUERY RETORNA A TABELA PADRAO PARA O RASTREAMENTO

CASE     cPadrao == "648";  ///	Contabilização do exclusão dos itens do documento de entrada do Tipo Debito/Credito - Estão disponíveis as tabelas de Tipo de Entrada e saída, produto, documento de entrada e Cliente ou Fornecedor conforme o tipo do documento.	COM	
    .or. cPadrao == "655";	///	Contabilização do exclusão dos itens do documento de entrada - Estão disponíveis as tabelas de Tipo de Entrada e saída, produto, documento de entrada e Cliente ou Fornecedor conforme o tipo do documento.	COM						
	.or. cPadrao == "656";	///	Contabilização da exclusão do rateio dos itens do documento de entrada - Estão disponíveis as tabelas de Tipo de Entrada e saída, produto, documento de entrada, rateio de itens, item do documento de entrada e Cliente ou Fornecedor conforme o tipo do documento. Este lançamento não impede a execução do lançamento 651.	COM			
	.or. cPadrao == "955";	///	Contabilização da exclusão dos itens do documento de entrada especifico para documentos de provenientes do Ambiente de Importação - Estão disponíveis as tabelas de Tipo de Entrada e saída e Cliente ou Fornecedor conforme o tipo do documento. Este lançamento é executado junto com o lançamento 655.	COM
	.or. cPadrao == "6A8"   /// Contabilização da exclusão dos itens do documento de entrada manual (MATA910).  			

	If Empty(cTabOrigem)	/// SE A TABELA DE ORIGEM FOR INDICADA EM BRANCO 
		cTabOrigem := "SD1"	/// ASSUME A TABELA PADRAO ASSOCIADA AOS LANÇAMENTOS.
	EndIf	

CASE     cPadrao == "665";	///	Contabilização da exclusão do documento de entrada - Disponível a tabelas de Cliente ou Fornecedor conforme o tipo do documento.	COM						
	.or. cPadrao == "647"	///	Contabilização da exclusão do documento de entrada do Tipo Debito/Credito - Disponível a tabelas de Cliente ou Fornecedor conforme o tipo do documento.	COM
	
	If Empty(cTabOrigem)	/// SE A TABELA DE ORIGEM FOR INDICADA EM BRANCO 
		cTabOrigem := "SF1"	/// ASSUME A TABELA PADRAO ASSOCIADA AOS LANÇAMENTOS.
	EndIf

CASE 	 cPadrao == "652";	///	Contabiliza a implantação dos itens do Pedido de Compras.	COM			
	.or. cPadrao == "657"	///	Contabiliza a exclusão dos itens do Pedido de Compras.	COM			

	If GetNewPar("MV_OPTNFE",.F.) .and. ALLTRIM(UPPER(FunName())) == "CTBANFE"
		If Empty(cTabOrigem)	/// SE A TABELA DE ORIGEM FOR INDICADA EM BRANCO 
			cTabOrigem := "CTBANFE"	/// ASSUME A TABELA PADRAO ASSOCIADA AOS LANÇAMENTOS.
		EndIf	
		
		If cTabOrigem == "CTBANFE"
			nRecOrigem := CTBANFE->(SC7RECNO)
		Else
			nRecOrigem := (cTabOrigem)->(Recno())
		EndIf		
	Else
		If Empty(cTabOrigem)	/// SE A TABELA DE ORIGEM FOR INDICADA EM BRANCO 
			If ALLTRIM(UPPER(FunName())) == "CTBANFE"
				cTabOrigem := "SC7_QRY"	/// ASSUME A TABELA PADRAO ASSOCIADA AOS LANÇAMENTOS.
			Else
				cTabOrigem := "SC7"	/// ASSUME A TABELA PADRAO ASSOCIADA AOS LANÇAMENTOS.
			EndIf
		EndIf	

		If cTabOrigem == "SC7_QRY"	/// ASSUME A TABELA PADRAO ASSOCIADA AOS LANÇAMENTOS.	
			nRecOrigem := (cTabOrigem)->(SC7RECNO)
		Else
			nRecOrigem := (cTabOrigem)->(Recno())		
		EndIf
	EndIf

	cTabOrigem := "SC7"		/// INDEPENDENTE DE QUERY RETORNA A TABELA PADRAO PARA O RASTREAMENTO
	
CASE 	 cPadrao == "666";	///	Saída de saldo em estoque (requisição) para materiais com apropriação direta.	EST			
	.or. cPadrao == "667";	///	Antes de atualizar o custo - Saída de saldo em estoque (requisição) para materiais com apropriação direta).	EST			
	.or. cPadrao == "668";	///	Entrada de saldo em estoque (devolução / produção) para materiais com apropriação direta).	EST			
	.or. cPadrao == "669";	///	Antes de atualizar o custo - Entrada de saldo em estoque (devolução/produção) para materiais com apropriação direta).	EST			
	.or. cPadrao == "670";	///	Saída de saldo em estoque (requisição) - movimento origem	EST			
	.or. cPadrao == "672";	///	Entrada de saldo em estoque (devolução) - movimento destino	EST			
	.or. cPadrao == "674";	///	Saída de saldo em estoque (requisição) no inventário On-Line.	EST			
	.or. cPadrao == "676";	///	Entrada de saldo em estoque (Devolução/Produção) no inventário On-Line.	EST	
	.or. cPadrao == "679";	///	Entrada de saldo em estoque (devolução / produção) para materiais com apropriação indireta).	EST			
	.or. cPadrao == "680";	///	Saída de saldo em estoque (requisição) para materiais com apropriação indireta.	EST	
	.or. cPadrao == "67A";	///	Rateio da Solicitacao ao Armazem na Saída de saldo em estoque (requisição)
	.or. cPadrao == "67B"	///	Rateio da Solicitacao ao Armazem na Entrada de saldo em estoque (devolução)

	If Empty(cTabOrigem)	/// SE A TABELA DE ORIGEM FOR INDICADA EM BRANCO 
		cTabOrigem := "SD3"	/// ASSUME A TABELA PADRAO ASSOCIADA AOS LANÇAMENTOS.
	EndIf	
	
CASE     cPadrao == "678"	///	Venda de mercadoria (item do Documento de Saída)	EST		
	
	If Empty(cTabOrigem)	/// SE A TABELA DE ORIGEM FOR INDICADA EM BRANCO 
		cTabOrigem := "SD2"	/// ASSUME A TABELA PADRAO ASSOCIADA AOS LANÇAMENTOS.
	EndIf	

CASE	 cPadrao == "681";	///	Compra / Remessa de terceiros (item Documento Entrada)	EST			
	.or. cPadrao == "682"	///	Retorno poder de terceiros (item Documento Entrada)	EST			

	If Empty(cTabOrigem)	/// SE A TABELA DE ORIGEM FOR INDICADA EM BRANCO 
		cTabOrigem := "SD1"	/// ASSUME A TABELA PADRAO ASSOCIADA AOS LANÇAMENTOS.
	EndIf	

CASE 	 cPadrao == "710";	///	Apuração de ICMS. Este lançamento somente é executado quando há geração de contas a pagar (parâmetro MV_LPADICM - A tabela de títulos a pagar esta posicionada).	FIS			
	.or. cPadrao == "711";	///	Estorno da Apuração de ICMS. Este lançamento somente é executado quando há geração de contas a pagar (parâmetro MV_LPADICM - A tabela de títulos a pagar esta posicionada).	FIS			
	.or. cPadrao == "720";	///	Apuração de IPI. Este lançamento somente é executado quando há geração de contas a pagar (parâmetro MV_LPADIPI - A tabela de títulos a pagar esta posicionada).	FIS			
	.or. cPadrao == "721"	///	Estorno da Apuração de IPI. Este lançamento somente é executado quando há geração de contas a pagar (parâmetro MV_LPADIPI - A tabela de títulos a pagar esta posicionada	FIS			

	If Empty(cTabOrigem)	/// SE A TABELA DE ORIGEM FOR INDICADA EM BRANCO 
		cTabOrigem := "SE2"	/// ASSUME A TABELA PADRAO ASSOCIADA AOS LANÇAMENTOS.
	EndIf	
    
CASE cPadrao == "730"	///	Reservado para Localizações	FIS		

	If Empty(cTabOrigem)	/// SE A TABELA DE ORIGEM FOR INDICADA EM BRANCO 
		cTabOrigem := "SCN"	/// ASSUME A TABELA PADRAO ASSOCIADA AOS LANÇAMENTOS.
	EndIf	

CASE 	 cPadrao == "750";	///	Apuração de ISS			FIS			
	.or. cPadrao == "751"	///	Estorno Apuração ISS	FIS			

	If Empty(cTabOrigem)	/// SE A TABELA DE ORIGEM FOR INDICADA EM BRANCO 
		// cTabOrigem := "SCM"	/// ASSUME A TABELA PADRAO ASSOCIADA AOS LANÇAMENTOS.
	EndIf	
	
CASE 	 cPadrao == "801";	///	Aquisição de Bem	ATF			
	.or. cPadrao == "802";	///	Aquisição - Reavaliação	ATF			
	.or. cPadrao == "803";	///	Aquisição - Adiantamento	ATF			
	.or. cPadrao == "804";	///	Aquisição - Lei 8.200	ATF			
	.or. cPadrao == "805";	///	Exclusão Aquisição do Bem	ATF			
	.or. cPadrao == "806";	///	Exclusão - Reavaliação	ATF			
	.or. cPadrao == "807";	///	Exclusão - Adiantamento	ATF			
	.or. cPadrao == "808";	///	Exclusão - Lei 8.200	ATF			
	.or. cPadrao == "845";	///	Aquisição - Lei 8.200 (Tipo do Ativo - 06)	ATF			
	.or. cPadrao == "846"	///	Exclusão - Lei 8.200 (Tipo do Ativo - 06 )				
	
	If Empty(cTabOrigem)	/// SE A TABELA DE ORIGEM FOR INDICADA EM BRANCO 
		If cPadrao == "801"
			cTabOrigem := "SN4"
		Else
			cTabOrigem := "SN3"	/// ASSUME A TABELA PADRAO ASSOCIADA AOS LANÇAMENTOS.
		Endif
	EndIf	

CASE  	 cPadrao == "810";	///	Baixa Aquisição	ATF			
	.or. cPadrao == "811";	///	Baixa Reavaliação	ATF			
	.or. cPadrao == "812";	///	Baixa - Adiantamentos	ATF			
	.or. cPadrao == "812";	///	Baixa Adiantamento	ATF			
	.or. cPadrao == "813";	///	Baixa Lei 8.200	ATF			
	.or. cPadrao == "814";	///	Cancelamento Baixa Aquisição	ATF			
	.or. cPadrao == "815";	///	Cancelamento Baixa Reavaliação	ATF			
	.or. cPadrao == "816";	///	Cancelamento Baixa Adiantamento	ATF			
	.or. cPadrao == "817";	///	Cancelamento Baixa Lei 8.200	ATF
	.or. cPadrao == "80A";	///	Aquisição de outros tipos de ativo	ATF	
	.or. cPadrao == "80B";	///	Exclusão de outros tipos de ativo	ATF		
	.or. cPadrao == "81A";	///	Baixa de outros tipos de ativo	ATF			
	.or. cPadrao == "81B";	///	Cancelamento da baixa de outros tipos de ativo	ATF	
	.or. cPadrao == "847";	///	Baixa Lei 8.200 (Tipo do Ativo -  06)	ATF			
	.or. cPadrao == "848";	///	Cancelamento da Baixa (Tipo do Ativo - 06)	ATF			
	.or. cPadrao == "820";	///	Cálculo da Depreciação	ATF			
	.or. cPadrao == "821";	///	Ampliação	ATF			
	.or. cPadrao == "822";	///	Cancelamento de Ampliação	ATF			
	.or. cPadrao == "825";	///	Descálculo	ATF			
	.or. cPadrao == "827";	///	Ajuste Inventário	ATF
	.or. cPadrao == "831";	///	Transferencia  ATF (origem)
	.or. cPadrao == "832";	///	Transferencia  ATF (destino)
	.or. cPadrao == "894";	///	Impairment
	.or. cPadrao == "895";	///	Estorno Impairment
	.or. cPadrao == "829"

	If Empty(cTabOrigem)	/// SE A TABELA DE ORIGEM FOR INDICADA EM BRANCO 
		If cPadrao == "810" .OR. cPadrao == "820" .OR. cPadrao == "81A" .Or. cPadrao == "80A"
			cTabOrigem := "SN4"
		ElseIf cPadrao == "894" .OR. cPadrao == "895" 
			cTabOrigem := "SNI"
		Else
			cTabOrigem := "SN3"	/// ASSUME A TABELA PADRAO ASSOCIADA AOS LANÇAMENTOS.
		EndIf
	EndIf	
	
CASE cPaisLoc == "RUS" ;
	.AND. (cPadrao == "80G";	// Modernization
	.OR. cPadrao == "80H";	// Storno of Modernization
	.OR. cPadrao == "80E";	// Revaluation
	.OR. cPadrao == "80F";	// Storno of Revaluation
	.OR. cPadrao == "8A2";	// Putting Into Operation
	.OR. cPadrao == "8A3";	// Storno of Putting Into Operation
	.OR. cPadrao == "8A6";	//	Conservation
	.OR. cPadrao == "8A7";	//	Desconservation				
	.OR. cPadrao == "8A8";	//	Storno of Conservation
	.OR. cPadrao == "8A9")	//	Storno of Desconservation

	If Empty(cTabOrigem)
		cTabOrigem := "SN4"	// ASSUME THE STANDARD TABLE ASSOCIATED WITH LAUNCHES.
	EndIf
	nRecOrigem := SN4->(Recno())	// ASSUME THE STANDARD TABLE ASSOCIATED WITH LAUNCHES.	
CASE 	 cPadrao == "8A2";	///	Putting Into Operation
	.or. cPadrao == "8A3"	///	Storno of Putting Into Operation				
	
	If Empty(cTabOrigem)	/// SE A TABELA DE ORIGEM FOR INDICADA EM BRANCO 
		cTabOrigem := "F4R"	/// ASSUME A TABELA PADRAO ASSOCIADA AOS LANÇAMENTOS.
	EndIf
	
	nRecOrigem := F4R->(Recno())

CASE 	 cPadrao == "8A6";	///	Conservation
	.or. cPadrao == "8A7";	///	Storno of Conservation				
	.or. cPadrao == "8A8";	///	Storno of Conservation
	.or. cPadrao == "8A9"	///	Storno of Conservation
	
	If Empty(cTabOrigem)	/// SE A TABELA DE ORIGEM FOR INDICADA EM BRANCO 
		cTabOrigem := "F44"	/// ASSUME A TABELA PADRAO ASSOCIADA AOS LANÇAMENTOS.
	EndIf
	
	nRecOrigem := F44->(Recno())

CASE	cPaisLoc == "RUS" .And. cPadrao == "5BS"	
	If Empty(cTabOrigem)	
		cTabOrigem := "SEL"	
	EndIf
	
	nRecOrigem := SEL->(Recno())

CASE 	 cPadrao >= "A01" .and. cPadrao <= "C06"
	/*
	"A01"	///	Salários a Pagar		GPE		SRZ	
	"A02"	///	Férias					GPE		SRZ	
	"A03"	///	Salário Família			GPE		SRZ	
	"A04"	///	Salário Maternidade		GPE		SRZ	
	"A05"	///	Pró-Labore				GPE		SRZ	
	"B01"	///	INSS Empregados			GPE		SRZ	
	"B02"	///	IRRF					GPE		SRZ	
	"B03"	///	Assistência Médica		GPE		SRZ	
	"B04"	///	Contribuição Sindical	GPE		SRZ	
	"B05"	///	Faltas					GPE		SRZ	
	"B06"	///	Aviso Prévio (Desconto)	GPE		SRZ	
	"B07"	///	Outros Descontos		GPE		SRZ	
	"B08"	///	Pensão Alimentícia		GPE		SRZ	
	"B09"	///	Vale-Transporte			GPE		SRZ	
	"B10"	///	Desc. Insufic. de Saldo	GPE		SRZ	
	"C01"	///	INSS Empresa			GPE		SRZ	
	"C02"	///	FGTS					GPE		SRZ	
	"C03"	///	Provisão de Férias		GPE		SRZ	
	"C04"	///	Encargos Prov.de Férias	GPE		SRZ	
	"C05"	///	Provisão de 13° Salário	GPE		SRZ	
	"C06"	///	Encargos de Prov.13°Sal.GPE		SRZ	
	*/
	If Empty(cTabOrigem)	/// SE A TABELA DE ORIGEM FOR INDICADA EM BRANCO 
		cTabOrigem := "SRZ"	/// ASSUME A TABELA PADRAO ASSOCIADA AOS LANÇAMENTOS.
	EndIf	
Case cPadrao $ '69K|69L|69M|69N|69O'
	If Empty(cTabOrigem)	/// SE A TABELA DE ORIGEM FOR INDICADA EM BRANCO 
		cTabOrigem := "CN9"	/// ASSUME A TABELA PADRAO ASSOCIADA AOS LANÇAMENTOS.
	EndIf

Case	cPadrao == "575"
	If Empty(cTabOrigem)	///	SE A TABELA DE ORIGEM FOR INDICADA EM BRANCO  
		cTabOrigem := "SEL"	/// ASSUME A TABELA REFERENTE A RECIBOS
	EndIf

Case     cPadrao == "940" ; //940 - "PFS - Emissão de WO de Despesa"
	.Or. cPadrao == "941" ; //941 - "PFS - Cancelamento de WO de Despesa"
	.Or. cPadrao == "942" ; //942 - "PFS - Lançamento"
	.Or. cPadrao == "943" ; //943 - "PFS - Desdobramento"
	.Or. cPadrao == "944" ; //944 - "PFS - Desdobramento pós pagamento"
	.Or. cPadrao == "945" ; //945 - "PFS - Emissão de Fatura"
	.Or. cPadrao == "946" ; //946 - "PFS - Cancelamento de Fatura"
	.Or. cPadrao == "947" ; //947 - "PFS - Inclusão Desdobramento"
	.Or. cPadrao == "948" ; //948 - "PFS - Estorno de Inclusão Desdobramento"
	.Or. cPadrao == "949" ; //949 - "PFS - Estorno de Desdobramento Pós Pagamento"
	.Or. cPadrao == "956" ; //956 - "PFS - Estorno de Lançamento"
	.Or. cPadrao == "957"   //957 - "PFS - Estorno de Desdobramento Baixa"

	If Empty(cTabOrigem) .And. FindFunction("J265LpTab")
		cTabOrigem := J265LpTab(cPadrao)
	EndIf

//SIGAGTP
Case cPadrao $ "G01|G02"
	If Empty(cTabOrigem)	/// SE A TABELA DE ORIGEM FOR INDICADA EM BRANCO 
		cTabOrigem := "GIC"	/// ASSUME A TABELA PADRAO ASSOCIADA AOS LANÇAMENTOS.
	EndIf

ENDCASE

If Empty(cTabOrigem) .and. !Empty(cAliasPos)	/// SE A TABELA DE ORIGEM FOR INDICADA EM BRANCO 
	cTabOrigem := cAliasPos 					/// ASSUME A TABELA ABERTA AO CHAMAR A DETPROVA
EndIf

If nRecOrigem <= 0 .and. !Empty(cTabOrigem)
	nRecOrigem := (cTabOrigem)->(Recno())
Endif

If nPosORISE2 > 0
	SE2->(MsGoTo(nPosORISE2))
EndIf

If nPosORISE5 > 0
	SE5->(MsGoTo(nPosORISE5))
EndIf

Return(nRecOrigem)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³dbNickOrdeºAutor  ³Marcos S. Lobo      º Data ³  01/26/06   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Localiza indice pelo NickName e seta ordem se existir.	  º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function dbNickOrder(cAlias,cNick)

Local aAreaPos 
Local nRet	   := 0
Static _oNickOrder

If Empty(cAlias) .or. ValType(cAlias) <> "C"
	Return 0
EndIf
If Empty(cNick) .or. ValType(cNick) <> "C"
	Return 0
EndIf

//- verifica a existência do cache para melhor retorno
If _oNickOrder == nil 
	_oNickOrder := JsonObject():New()
EndIf 
if (nRet := _oNickOrder[cFilAnt+cAlias+cNick]) == nil 
	nRet     := 0 
	aAreaPos := GetArea()

	cNick := ALLTRIM(UPPER(cNick))
		
	dbSelectArea("SIX")
	SIX->(dbSetOrder(1))
	If SIX->(dbSeek(cAlias,.F.))
		While SIX->(!Eof()) .and. SIX->INDICE == cAlias	
			If ALLTRIM(UPPER(SIX->NICKNAME)) == cNick
				dbSelectArea(cAlias)		/// SELECIONA O ALIAS INDICADO
				(cAlias)->(DBOrderNickName(cNick))		/// SETA O INDICE PELO NICK
				nRet := (cAlias)->(IndexOrd())			/// RETORNA O NUMERO DO INDICE
				Exit
			EndIf
			SIX->(dbSkip())
		EndDo
	EndIf
	/// RESTAURA AREA APENAS SE NÃO ENCONTROU O ÍNDICE
	RestArea(aAreaPos)
	aSize(aAreaPos,0)
	aAreaPos := nil 
	_oNickOrder[cFilAnt+cAlias+cNick] := cValToChar(nRet)
Else 
	nRet := Val(nRet)
EndIf 

Return nRet


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³CtbCfgLancºAutor  ³Edson Maricate      º Data ³  24/02/06   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³Cria uma tela de configuração on line de lançamentos        º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Contabilidade Gerencial - Lançamentos Automaticos          º±±
±±º          ³ Atencao! Esta fucao e chamada pela DetProva e utilizada    º±±
±±º          ³ em todo o sistema!                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function CtbCfgLanc(cPadrao,lPosiciona)

Local aArea			
Local aAreaCT5		
Local oDlg
Local oTree
Local oTree2
Local aHeadCT5		:= {}
Local aColsCT5		:= {}
Local aRecCT5		:= {}
Local nLenCT5 		:= 0
Local nLinCT5 		:= 0
Local aSize //:= MsAdvSize(,.F.,400)
Local aHeadCTK		:= {}
Local aColsCTK		:= {}
Local nLenCTK 		:= 0
Local nLinCTK		:= 0  
Local nPosAtivo
Local cX			:= "" 
Local cVar		:= SPACE(100)
Local oBold
Local oPanel, oFolder, oPanel3, oPanel4, oPanel5, oPanel6, oPanel21, oPanel22
Local nColAux
Local cKeyCVA 
Local lExecuteCVA
Private cCWKCFor:= "" 

If __lCVAInDic == NIL
	__lCVAInDic := Iif(AliasInDic("CVA"), .T., .F.)
Endif

If __lCVAInDic
	aArea	:= GetArea()
	cKeyCVA := xFilial('CVA')+cPadrao
	dbSelectArea("CVA")
	dbSetOrder(1)
	//- cache de performance para evitar 
	If (lExecuteCVA := oJsonCVA[cKeyCVA]) == nil 
		lExecuteCVA := MsSeek(cKeyCVA) .And. ( CVA->CVA_CFGLAN == "1" .Or. (__cUserID == "000000" .And. CVA->CVA_CFGLAN == "3") ) 
		oJsonCVA[cKeyCVA] := lExecuteCVA
		RestArea(aArea)
	EndIf 
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Possibilita a utilização da tela para qualquer login CVA_CFGLAN = "1"    ³
	//³ou apenas para o usuário Administrador CVA_CFGLAN = "3"                  ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If lExecuteCVA
		CVA->(MsSeek(cKeyCVA))//- garante o posicionamento vindo do Json

		aSize := MsAdvSize(,.F.,400) //RETIRADO DA DECLARACAO VARIAVEL LOCAL ASIZE POR MOTIVO DE PERFORMANCE
		PRIVATE M->CT5_LANPAD	:= cPadrao
		PRIVATE cTable				:= "   "
		Private oGdCTK
		Private oGdCT5
		
	
		aAreaCT5		:= CT5->(GetArea())
	
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Montagem do aHeader do CT5                                             ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		aHeadCT5 := GetaHeader("CT5",,{"CT5_LANPAD"},{})
		nLenCT5  := Len(aHeadCT5) + 1
		nPosAtivo:= AScan(aHeadCT5,{|x| Upper(AllTrim(x[2])) == "CT5_STATUS" })
		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Montagem do aCols do CT5                                               ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		aColsCT5 := {}
		DbSelectArea("CT5")
		DbSetOrder(1)
		DbSeek(xFilial()+cPadrao)
		While  !Eof() .And. xFilial('CT5')+cPadrao==CT5->CT5_FILIAL+CT5->CT5_LANPAD
			AAdd(aColsCT5,Array( nLenCT5 ))
			nLinCT5++
			// Varre o aHeader para preencher o acols
			AEval(aHeadCT5, {|x,y| aColsCT5[nLinCT5][y] := IIf(x[10] == "V", CriaVar(AllTrim(x[2])), FieldGet(FieldPos(x[2])) ) })
		
			// Deleted
			aColsCT5[nLinCT5][nLenCT5] := .F.
			
			// Adiciona o Recno no aRec
			AAdd( aRecCT5, CT5->( Recno() ) )
			
			CT5->(DbSkip())
		EndDo
		
		// Verifica se não foi criada nenhuma linha para o aCols
		If Len(aColsCT5) = 0
			AAdd(aColsCT5,Array( nLenCT5 ))
			nLinCT5++
		
			// Varre o aHeader para preencher o acols
			AEval(aHeadCT5, {|x,y| aColsCT5[nLinCT5][y] := IIf(Upper(AllTrim(x[2])) == "CT5_SEQUEN", StrZero(1,Len(CT5->CT5_SEQUEN)),CriaVar(AllTrim(x[2])) ) })
			
			// Deleted
			aColsCT5[nLinCT5][nLenCT5] := .F.
		EndIf
		
		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Montagem do aHeader do CTK                                             ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		dbSelectArea("CTK")
		
		aHeadCTK := GetaHeader("CTK",,{"CTK_SEQUEN"},{})
		nLenCTK  := Len(aHeadCTK) + 1
		
		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Montagem do aCols do CTK                                               ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		
		aColsCTK := {}
		AAdd(aColsCTK,Array( nLenCTK ))
		nLinCTK++
		// Varre o aHeader para preencher o acols
		AEval(aHeadCTK, {|x,y| aColsCTK[nLinCTK][y] := IIf(x[10] == "V", CriaVar(AllTrim(x[2])), FieldGet(FieldPos(x[2])) ) })
		
		// Deleted
		aColsCTK[nLinCTK][nLenCTK] := .F.
		
		// Verifica se não foi criada nenhuma linha para o aCols
		If Len(aColsCTK) = 0
			AAdd(aColsCTK,Array( nLenCTK ))
			nLinCTK++
			// Varre o aHeader para preencher o acols
			AEval(aHeadCTK, {|x,y| aColsCTK[nLinCTK][y] := IIf(Upper(AllTrim(x[2])) == "CTK_SEQUEN", StrZero(1,Len(CTK->CTK_SEQUEN)),CriaVar(AllTrim(x[2])) ) })
			
			// Deleted
			aColsCTK[nLinCTK][nLenCTK] := .F.
		EndIf
		
		dbSelectArea("CVA")
		dbSetOrder(1)
		dbSeek(xFilial()+cPadrao)
		
		DbSelectArea("CT5")
		
		DEFINE FONT oBold NAME "Arial" SIZE 0, -11 BOLD
		DEFINE MSDIALOG oDlg TITLE STR0013+cPadrao FROM aSize[7],0 to aSize[6],aSize[5] PIXEL  //"Configuração On-Line de Lancamentos - "
		
			oPanel := TPanel():New(0,0,'',oDlg, oDlg:oFont, .T., .T.,, ,150,150,.T.,.T. )
			oPanel:Align := CONTROL_ALIGN_LEFT
		
			oFolder := TFolder():New(121,2,{STR0014,STR0015},{},oPanel,,,, .T., .T.,390,110)  //"Campos"#"Variaveis"
			oFolder:Align := CONTROL_ALIGN_ALLCLIENT
		
			oPanel3 := TPanel():New(0,0,'',oFolder:aDialogs[1], , .T., .T.,, ,30,30,.T.,.T. )
			oPanel3:Align := CONTROL_ALIGN_TOP
		
			oPanel4 := TPanel():New(0,0,'',oFolder:aDialogs[1], , .T., .T.,, ,50,50,.T.,.T. )
			oPanel4:Align := CONTROL_ALIGN_ALLCLIENT
		
			@ 1110,1110 MSGET oX VAR cX SIZE 1,1 
		
			TSay():New( 3, 3, MontaBlock("{|| '"+STR0016+"' }"), oPanel3 , ,oBold,,,,.T.)//'Tabela'
		
			@ 10,3 MSGET oTable VAR cTable SIZE 30,10 PIXEL Of oPanel3 F3 "SX21" PICTURE '@!' VALID ExistCpo("SX2") .And. Processa({|| CfgLoadTree(cTable,oTree,.T.)}) HASBUTTON	
		
			@ 10,40 BUTTON oIns Prompt ">>" SIZE 10 ,7  FONT oDlg:oFont ACTION {|| AddliqLan(oTree,aHeadCT5)} OF oPanel3 PIXEL When Substr(oTree:GetCargo(),1,3)=="FLD"
			TSay():New( 10, 52, MontaBlock("{|| '"+STR0017+"' }"), oPanel3 , ,oBold,,,,.T.,,,50,20)  //"Clique aqui para inserir o campo"
		
			oTree := DbTree():New(1,1,10,10, oPanel4,,,.T.)
			oTree:Align := CONTROL_ALIGN_ALLCLIENT	
			
			
			oPanel5 := TPanel():New(0,0,'',oFolder:aDialogs[2], , .T., .T.,, ,30,30,.T.,.T. )
			oPanel5:Align := CONTROL_ALIGN_TOP
		
			oPanel6 := TPanel():New(0,0,'',oFolder:aDialogs[2], , .T., .T.,, ,30,30,.T.,.T. )
			oPanel6:Align := CONTROL_ALIGN_ALLCLIENT
		
		
			TSay():New( 3, 3, MontaBlock("{|| '"+STR0018+"' }"), oPanel5 , ,oBold,,,,.T.)  // "Variavel"
			@ 10,3 MSGET oVar VAR cVar SIZE 60,10 PIXEL Of oPanel5 VALID CfgLoadVar(cVar,oTree2) 
		
			oTree2 := DbTree():New(1,1,10,10, oPanel6,,,.T.)
			oTree2:Align := CONTROL_ALIGN_ALLCLIENT	
		
			oTree2:AddItem( Padr(STR0015,100),Padr("0",80),,,,,0)	 
		
		
			oPanel2 := TPanel():New(0,0,'',oDlg, oDlg:oFont, .T., .T.,, ,90,90,.T.,.T. )
			oPanel2:Align := CONTROL_ALIGN_ALLCLIENT
		
			oPanel21 := TPanel():New(0,0,'',oPanel2, oDlg:oFont, .T., .T.,, ,15,15,.T.,.T. )
			oPanel21:Align := CONTROL_ALIGN_TOP
		
			TSay():New( 3, 4, MontaBlock("{|| '"+STR0019+" - "+cPadrao+" - "+AllTrim(CVA->CVA_DESCRI)+"' }"), oPanel21 , ,oBold,,,,.T.)  //"Configuração dos Lancamentos Padrões"
		
			oGdCT5:= MsNewGetDados():New(0,0,70,70,GD_INSERT+GD_UPDATE+GD_DELETE,,,,,,9999,,,,oPanel2,aHeadCT5,aColsCT5)
			oGdCT5:oBrowse:Align := CONTROL_ALIGN_TOP
			oGdCT5:CARGO := AClone(aRecCT5)

			For nColAux := 1 TO Len(oGdCT5:aHeader)
				//verifica se valid esta preenchido e coloca funcao para inicializar variaveis M->
				If ! Empty(oGdCT5:aHeader[nColAux, 6])
					oGdCT5:aHeader[nColAux, 6] := "CtbVarMem(oGdCT5) .And. "+Alltrim(oGdCT5:aHeader[nColAux, 6])
				EndIf
			Next //nColAux
		
			oPanel22 := TPanel():New(0,0,'',oPanel2, oDlg:oFont, .T., .T.,, ,15,15,.T.,.T. )
			oPanel22:Align := CONTROL_ALIGN_TOP
		
			TSay():New( 3, 4, MontaBlock("{|| '"+STR0020+"' }"), oPanel22 , ,oBold,,,,.T.)  //"Pré-Visualização dos Lancamentos"
			@1,250 BTNBMP oBmp1 RESOURCE "RELOAD"   SIZE 25,25 ACTION CtbAtuGrid(@oGDCT5,@oGDCTK, 1,lPosiciona,cPadrao) Of oPanel22
		
			oGdCTK:= MsNewGetDados():New(0,0,100,100,0,,,,,,9999,,,,oPanel2,aHeadCTK,aColsCTK)
			oGdCTK:oBrowse:Align := CONTROL_ALIGN_ALLCLIENT
		
			CtbAtuGrid(oGDCT5,oGDCTK, 1,lPosiciona,cPadrao)
		
		If SetMDIChild()
			ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar(oDlg,{|| If(Aviso(STR0002,STR0021,{STR0022,STR0023},2)==1.And.CtbLctoOk(oGdCT5,cPadrao),oDlg:End(),Nil) },{|| oDlg:End() })  //"Atenção!"#"Confirma gravaçao da configuração dos lançamentos padrões de acordo com as modificações efetuadas ?"#"Sim"#"Não"
		Else
			ACTIVATE MSDIALOG oDlg CENTERED ON INIT EnchoiceBar(oDlg,{|| If(Aviso(STR0002,STR0021,{STR0022,STR0023},2)==1.And.CtbLctoOk(oGdCT5,cPadrao),oDlg:End(),Nil) },{|| oDlg:End() }) //"Atenção!"#"Confirma gravaçao da configuração dos lançamentos padrões de acordo com as modificações efetuadas ?"#"Sim"#"Não"
		EndIf
	
		RestArea(aAreaCT5)
		RestArea(aArea)
	EndIf
EndIf
	
Return 

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³CtbVarMem ºAutor  ³Microsiga           º Data ³  12/01/10   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Coloca as colunas do acols em variaveis memoria M->campo    º±±
±±º          ³(exceto a coluna posicionada)                               º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function CtbVarMem(oGdCT5)
Local nLin := oGdCT5:nAt
Local nX
For nX := 1 TO Len(oGdCT5:aCols[nLin])-1
	If nX != oGdCT5:oBrowse:ColPos
		_SetOwnerPrvt(Trim(oGdCT5:aHeader[nX,2]), oGdCT5:aCols[nLin, nX])  //		&("M->"+oGdCT5:aHeader[nX,2]) := oGdCT5:aCols[nLin, nX]
	EndIf
Next
Return(.T.) //tem que retornar .T. 


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºFunção    ³ CtbAtuGridºAutor  ³ Microsiga		 º Data ³  00/00/00   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Função que atualiza o grid com os valores do lançamento	  º±±
±±º          ³ padrão logo após o processo do sistema seja finalizado e   º±±
±±º          ³ necessite efetuar uma contabilização online				  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Lançamento Padrão										  º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function CtbAtuGrid(oGDCT5,oGDCTK, nOpcCfg,lPosiciona,cPadrao)
Local nValor		:= 0
Local nz
Local nx
Local bBlock		:= ErrorBlock()
Local aColsOri 	:= aClone(oGDCTK:aCols)
Local aVlrCT5 		:= Array(__nQuantas)
Local cValor     := ""
Local cHistorico := ""
Local cHAglut	 := ""
Local nPosCtk
Local lRedStorn	:= cPaisLoc == "RUS" .And. SuperGetMV("MV_REDSTOR",.F.,.F.)

ErrorBlock( {|e| ChecErro(e)})

If __nQuantas == 0
	__nQuantas := CtbMoedas()
EndIf	

Begin Sequence

	oGDCTK:aCols := {}
	
	For nx := 1 to Len(oGDCT5:aCols)
	
		If oGDCT5:aCols[nx][Len(oGDCT5:aCols[nx])] // Deletado 
			Loop
		EndIf
		
		If oGDCT5:aCols[nx][aScan(oGDCT5:aHeader,{|x| Alltrim(x[2]) == "CT5_DC" })] == "4" // Continuação historico
			Loop
		EndIf

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Indica que o lancamento padrao esta inativo                  ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		nPosStatus := aScan(oGDCT5:aHeader,{|x| Alltrim(x[2]) == "CT5_STATUS" })
		If nPosStatus > 0
			If oGDCT5:aCols[nx][nPosStatus] == "2"
				Loop
			EndIf
		EndIf

		aVlrCT5   := AFill(aVlrCT5,0)
		nContador := 0


		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Verifica se existem valores a serem contabilizados.          ³
		//³                                                              ³
		//³ Como os valores podem ser expressoes complexas estes sao     ³
		//³ armazenados na variavel aVlrCt5 para que nao haja necessidade³
		//³ de serem executados novamente.                               ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		For nZ := 1 To __nQuantas
			nValor    := 0
			cCampoCT5 := "CT5_VLR"+StrZero(nZ,2)
			nPosCT5 := aScan(oGDCT5:aHeader,{|x| Alltrim(x[2]) == cCampoCT5 })
			If nPosCT5 > 0
				cValor := AllTrim(oGDCT5:aCols[nx][nPosCT5])
				nValor := &(cValor)
				If Empty(nValor) .Or. nValor == 0
					nContador++
				Else
					aVlrCT5[nZ] := nValor
				EndIf
			EndIf
		Next nZ
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Se houver valores para contabilizar                          ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If nContador <> __nQuantas

			AAdd(oGDCTK:aCols,Array( Len(oGDCTK:aHeader)+1 ))
			nLinCTK := Len(oGDCTK:aCols)
			// Varre o aHeader para preencher o acols
			AEval(oGDCTK:aHeader, {|x,y| oGDCTK:aCols[nLinCTK][y] := CriaVar(AllTrim(x[2])) } )
			
			// Deleted
			oGDCTK:aCols[nLinCTK][Len(oGDCTK:aHeader)+1] := .F.
			
		
			For nPosCtk := 1 To Len(oGDCTK:aHeader)
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Obtem o nome do campo de destino na tabela CTK               ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				cCampoCTK := AllTrim(oGDCTK:aHeader[nPosCtk][2])
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Obtem o nome do campo de origem na tabela CT5                ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				cCampoCT5 := "CT5_" + SubStr(cCampoCTK,5)
									
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Transfere os valores do campo                                ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				nPosCT5 := aScan(oGDCT5:aHeader,{|x| Alltrim(x[2]) == cCampoCT5 })
				If nPosCT5 > 0
					Do Case
					Case SubStr(cCampoCT5,1,7)=="CT5_VLR"
						nValor := Val(SubStr(cCampoCT5,8,2))
						If nValor <= Len(aVlrCT5)
							If aVlrCT5[nValor] > 0 .Or. (lRedStorn .And. aVlrCT5[nValor] < 0)
								oGDCTK:aCols[nLinCTK][nPosCtk] := aVlrCT5[nValor]
							EndIf
						EndIf
					Case oGDCTK:aHeader[nPosCtk][8] == "N"
						cValor	:= AllTrim(oGDCT5:aCols[nx][nPosCT5])
						If !Empty(cValor)
							nValor := &(cValor)
							oGDCTK:aCols[nLinCTK][nPosCtk] := nValor
						Else
							oGDCTK:aCols[nLinCTK][nPosCtk] := 0
						EndIf
					Case oGDCTK:aHeader[nPosCtk][8] == "C"
						If !(cCampoCT5 $ "CT5_USERGI/CT5_USERGA/CT5_TABORI/CT5_RECORI")
							If cCampoCT5 == "CT5_SBLOTE"
								cValor := AllTrim(oGDCT5:aCols[nx][nPosCT5])
							ElseIf cCampoCT5 == "CT5_FILIAL"
								cValor := xFilial("CTK")
							ElseIf cCampoCT5 == "CT5_TPSALD"
								cValor := AllTrim(oGDCT5:aCols[nx][nPosCT5])
							Else
								cValor := AllTrim(TransLcta(AllTrim(oGDCT5:aCols[nx][nPosCT5]),240))
								If cCampoCT5 == "CT5_HIST"
									cHistorico := cValor
								ElseIf cCampoCT5 == "CT5_HAGLUT"
									If Empty(cValor)			/// SE HAGLUT ESTIVER EM BRANCO ASSUME HISTORICO.
										cValor := cHistorico
									EndIf
									cHAglut := cValor
								EndIf
							EndIf
							oGDCTK:aCols[nLinCTK][nPosCtk] := cValor
						EndIf
					Case oGDCTK:aHeader[nPosCtk][8] == "D"
						cValor := Ctod(AllTrim(TranslDta(AllTrim(oGDCT5:aCols[nx][nPosCT5]) )))
						cValor := IIf(Empty(cValor),Ctod(""),cValor)		
						oGDCTK:aCols[nLinCTK][nPosCtk] := cValor
					EndCase
				EndIf
			Next nPosCTK
		EndIf
	Next nx
	
	oGDCTK:oBrowse:Refresh()
	ErrorBlock(bBlock)
	
Recover
                 
oGDCTK:aCols := aClone(aColsOri)
oGDCTK:oBrowse:Refresh()

ErrorBlock(bBlock)

End Sequence

Return .T.

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ AddliqLan  ºAutor  ³Edson Maricate      º Data ³ 10/10/05 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Atualiza a coluna da aCols com o campo selecioando no     º±±
±±º          ³ painel lateral com a estrutura da tabela.                 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºParametros³ oTree    : Objeto tree com a estrutura da tabela          º±±
±±º          ³ aHeadTmp : aHeader com o cabecalho do aCols posicionado   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ SIGACTB                                                   º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function AddliqLan(oTree,aHeadTmp)
                         
local oGDTmp
local cColuna := ""
local cCampo  := ""
     
// Cria um objeto de GetDados temporario a partir da GetDados de origem: lancamento ou bloqueio
oGDTmp  := oGDCT5

// Guarda o conteudo da coluna da aCols e o nome do campo da tabela selecionada no painel lateral
cColuna := Alltrim(oGDTmp:aCols[oGDTmp:nAt][oGdTmp:oBrowse:nColPos])
cCampo  := Alltrim(Substr(oTree:GetCargo(),4,Len(oTree:GetCargo())))

// Soma o campo selecionado no conteudo do campo no aCols posicionado       
oGDTmp:aCols[oGDTmp:nAt][oGdTmp:oBrowse:nColPos] := PadR( cColuna + cTable + "->" + cCampo, TamSX3(aHeadTmp[oGdTmp:oBrowse:nColPos][2])[1] )

// Restaura o objeto da GetDados utilizado a partir das alteracoes realizadas no objeto temporario
oGDCT5 := oGDTmp

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºFunção    ³ CtbLctoOkºAutor  ³ Microsiga	  		 º Data ³  00/00/00   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Função que valida as informações do grid com os valores do º±±
±±º          ³ lançamento padrão logo após o processo do sistema seja 	  º±±
±±º          ³ finalizado enecessite efetuar uma contabilização online	  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Lançamento Padrão										  º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Static Function CtbLctoOk(oGd As Object, cPadrao As Character) As Logical

Local nI 	  as Numeric
Local cKeyCVA as Character

nI 		:= 0
cKeyCVA := ""

If !LanctoVld(oGd)
	Return .F.
EndIf

// Grava as configuracoes dos Lancamento
For nI := 1 To Len(oGd:aCols)
	If nI <= Len(oGd:Cargo) .And. oGd:Cargo[nI] > 0
		CT5->(DbGoto(oGd:Cargo[nI]))
		Reclock("CT5",.F.)
	Else
		If oGd:aCols[nI][Len(oGd:aCols[nI])] // Verifica se a linha esta deletada
			Loop
		Else
			Reclock("CT5",.T.)
		EndIf
	EndIf

	If oGd:aCols[nI][Len(oGd:aCols[nI])] // Verifica se a linha esta deletada
		CT5->(DbDelete())
	Else
		// Varre o aHeader e grava com base no acols
		AEval(oGd:aHeader,{|x,y| FieldPut( FieldPos(x[2]) , oGd:aCols[nI][y] ) })
		Replace CT5_FILIAL With xFilial("CT5")
		Replace CT5_LANPAD With cPadrao
	EndIf

	MsUnlock()
Next nI   

If Aviso(STR0024,STR0025+cPadrao+" ) ",{STR0022,STR0023},2) == 1 //"Desativar Modo On-Line ?"#"Deseja desativar a configuração On-Line dos lançamentos neste momento ? ( "
	dbSelectArea("CVA")
	dbSetOrder(1)
	cKeyCVA := xFilial('CVA')+cPadrao
	dbSeek(cKeyCVA)
	RecLock("CVA",.F.)
	CVA->CVA_CFGLAN := "2"
	If oJsonCVA != Nil .And. oJsonCVA[cKeyCVA] == .T.
		oJsonCVA[cKeyCVA] := .F.
	EndIf
	MsUnlock()
EndIf

Return .T.

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºFunção    ³ LanctoVldºAutor  ³ Microsiga		 º Data ³  00/00/00   	  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Função que valida das colunas do grid com os valores do 	  º±±
±±º          ³ lançamento padrão logo após o processo do sistema seja 	  º±±
±±º          ³ finalizado enecessite efetuar uma contabilização online	  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Lançamento Padrão										  º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function LanctoVld(oGd)
Local nI
Local nPosField

For nI := 1 To Len(oGd:aCols)
	// Busca por campos obrigatorios que nao estjam preenchidos
	nPosField := AScanx(oGd:aHeader,{|x,y| x[17] .And. Empty(oGd:aCols[nI][y]) })
	If nPosField > 0
		HELP("  ",1,"OBRIGAT2",,AllTrim(FWX2Nome("CT5"))+CHR(10)+CHR(13)+STR0026 + AllTrim(oGd:aHeader[nPosField][1]) + STR0027+Str(nI,3,0),3,1)  //"Campo:" # "Linha : "
		Return .F.
	EndIf
Next nI

Return .T.


/*
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ-ÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ ImpTerm2()³ Autor ³ Daniel Tadashi Batori ³ Data ³ 29/06/06 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄ-ÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Imprime Termo de Abertura/Encerramento de Livro             ³±±
±±³			 ³ Criado apartir da ImpTerm()							            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ-ÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ ImpTerm(cArquivo,aVariavel,cImpCtrl)                        ³±±
±±³          ³ Parametros:                                                 ³±±
±±³          ³ cArquivo=Nome do Arquivo que contem script a ser impresso   ³±±
±±³          ³          XXXXXXXX.XXX                                       ³±±
±±³          ³ aVariavel=Array com                                         ³±±
±±³          ³           {{Variavel no script,Conteudo a Substituir},...}  ³±±
±±³          ³ cImpCtrl=Caracter de Controle de Impressao                  ³±±
±±³          ³ oReport=objeto do TReport               						   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ-´±±
±±³ Uso      ³ Generico                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ-Ù±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function ImpTerm2(cArquivo,aVariavel,cImpCtrl,lGraph,aGraph, oReport)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Define variaveis                                 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

Local 	cTermo      :=""
Local   aTermo      :={""}
Local   i           :=1
Local   j           :=1
Local   nTamArq     :=0
Local   nLinTermo   :=0
Local   nColTermo   :=0
Local	cAux		:=	""
Local   cAux2		:=	""
Local	nY

If cArquivo <> Nil .And. ".DOC" $ Upper(cArquivo) .And. File(cArquivo)
	TermoViaWord(cArquivo)	// Retorno falso pois nao eh impresso pelo sistema e sim pelo WORD
	Return .F.				// utilizando .TRM apos saida da funcao eh dado EJECT que nao deve
Endif						// ser feito
					

If ValType(lGraph) <> "L"
	lGraph := .F.
Else
	If ValType(aGraph) <> "A"
		Return .F.
	Endif	
	oPrt := aGraph[1]
Endif
					
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Verifica se arquivo existe                       ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

If  Empty(cArquivo) .or. !File(cArquivo)
	Return .f.
Endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Carrega arquivo                                  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

nTerHdl :=FOPEN(cArquivo,2+64)
nTamArq :=FSEEK(nTerHdl,0,2)
xBuffer :=Space(nTamArq)
FSEEK(nTerHdl,0,0)
FREAD(nTerHdl,@xBuffer,nTamArq)
FCLOSE(nTerHdl)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Ao desmontar o arquivo para impressao, transfor- ³
//³ ma os Chr(141) para Chr(13) atraves da HardCr()  ³
//³ e elimina os codigos Chr(10) de quebra de linha  ³
//³ para que o contole da quebra seja feito apenas   ³
//³ pelo chr(13) na montagem do Vetor de Impressao   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

cTermo  := strtran(xBuffer , chr(10) , "")

While !empty(cTermo)
	i := at( chr(13), cTermo )
	If i > 0
		AADD(aTermo,Left(cTermo,i-1))
		cTermo := Substr(cTermo,i+1)
	Else
		aadd(aTermo,cTermo)
		cTermo:=""
	Endif
EndDo

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Substitui variaveis                              ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

nTamTerm:=Len(aTermo)

nNumPar:=0
aEval(aVariavel,{ |x| IIf(!Empty(x[1]),nNumPar:=nNumPar+1,)})

For i:=1 to nTamTerm
	For j:=1 to nNumPar
		cTipo:=Valtype(aVariavel[j,2])
		Do Case
		Case cTipo=="N"
			cValor:=LTrim(Str(aVariavel[j,2]))
		Case cTipo=="D"
			cValor:=DtoC(aVariavel[j,2])
		Case cTipo=="L"
			cValor:=IIF(aVariavel[j,2],STR0022,STR0023) // "SIM"  ### "NAO"
		Case cTipo=="C"
			cValor:=aVariavel[j,2]
		EndCase	
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Tratamento para substituir exatamente o campo requerido, pois estava     ³
		//³   ocorrendo de existir um campo _CPF e _CPFRES na mesma tabela e        ³
		//³   quando ele iria procurar o _CPF para substituir, alterava onde estava ³
		//³   o _CPFRES.                                                            ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If At(aVariavel[j,1], aTermo[i])>0
			cAux	:=	SubStr(aTermo[i],At(aVariavel[j,1], aTermo[i]))
			cAux2	:=	""
			For nY := 1 To Len(cAux)
				If IsAlpha(SubStr(cAux,nY,1)) .Or. SubStr(cAux,nY,1)$"_1234567890"
					cAux2 += SubStr(cAux,nY,1)
				Else
					Exit
				EndIf
			Next nY

			//Somente quando for o mesmo campo entre a tabela e o exigido no layout do termo.
			If cAux2==aVariavel[j,1]
				aTermo[i]:=StrTran(aTermo[i],aVariavel[j,1],cValor)
			EndIf
		EndIf
	Next
Next

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Imprime termo                                    ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

nLinTermo:=0
nColTermo:=0

If !lGraph
//	@ nLinTermo, nColTermo PSAY cImpCtrl // Caracter de Controle de Impressao

	For i:=1 to nTamTerm
		If ValType(oReport) == "O"
			oReport:PrintText(aTermo[i])
		Else	
			@ nLinTermo++, nColTermo PSAY aTermo[i]
		Endif	
	Next
Else
	nLinTermo := aGraph[3]
	oPrt:Say(nLinTermo+=1,00,cImpCtrl)	// Caracter de Controle de Impressao  
	For i:=1 to nTamTerm
		oPrt:Say(nLinTermo+=15,00,aTermo[i],aGraph[2])
	Next
Endif

Return .t.


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³CTBXFUN   ºAutor  ³Marcos S. Lobo      º Data ³  11/14/06   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Recalcula os totais no rodape da tela de lancamento Mod.2   º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP(ctba102 e ctba105)                                     º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function CtRecRdPe()

Local nRecTmp := TMP->(Recno())

aTotRdpe := {{0,0,0,0},{0,0,0,0}}

TMP->(DbGoTop())
While !TMP->(Eof())		
	If !TMP->CT2_FLAG
		CTB102Exibe(TMP->CT2_VALOR,0,TMP->CT2_DC,"")
	Endif
	TMP->(DbSkip())		
EndDo

TMP->(DbGoTo(nRecTmp))

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ CTBXFUN_V ³ Autor ³ Marcos V. Ferreira   ³ Data ³ 25/04/06 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Funcao utilizada para verificar a ultima versao do fonte   ³±±
±±³			 ³ CTBXFUN aplicado no rpo do cliente, verificando assim a    ³±±
±±³			 ³ necessidade de uma atualizacao neste fonte.		    	  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ EST/PCP/FAT/COM	                                          ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function CTBXFUN_V
Local nRet := 20060425 // 25 de abril de 2006
Return nRet


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ IfDefTopCTB ³ Autor ³ Eduardo Nunes Cirqueira ³ Data ³ 19/10/07 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Identifica se e TOP ou nao. Utilizada nos onde nao pode-se usar ³±±
±±³          ³ a diretiva #IFDEFTOP (por exemplo, manad.ini, norma086.ini, etc)³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ IfDefTopCTB()                                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ Logico                                                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Generico                                                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³                                                                 ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function IfDefTopCTB()

Return(.T.)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ CtbTpSald   ³ Autor ³ Totvs                   ³ Data ³ 02/09/08 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Permite a multipla selecao dos tipos de saldos                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Generico                                                        ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function CtbTpSld( cPreSel, cSepara, lVisual )
	Local aReturn		:= {} 
	Local nInc			:= 0

	Private nTam		:= 0
	Private aCat		:= {}
	Private MvRet		:= cPreSel
	Private MvPar		:= ""
	Private cTitulo		:= ""
	Private MvParDef	:= ""
	
	Default cPreSel		:= ""
	Default cSepara		:= "/"
	Default lVisual		:= .T.

	#IFDEF WINDOWS
		oWnd := GetWndDefault()
	#ENDIF
	
	//Tratamento para carregar variaveis da lista de opcoes
	nTam	:= 1
	cTitulo := "Saldos Contabeis"
	SX5->( DbSetOrder( 1 ) )
	SX5->( DbSeek( xFilial( "SX5" ) + "SL" ) )
	While SX5->( !Eof() ) .And. AllTrim( SX5->X5_TABELA ) == "SL"
		MvParDef += AllTrim( SX5->X5_CHAVE )

aAdd( aCat, AllTrim( SX5->X5_CHAVE ) + " - " + AllTrim( X5DESCRI() ) )                      	                                              

		SX5->( DbSkip() )
	End
	MvPar := PadR( AllTrim( StrTran( MvRet, cSepara, "" ) ), Len( aCat ) )

	//Executa funcao que monta tela de opcoes
	AdmOpcoes( @MvPar, cTitulo, aCat, MvParDef, 12, 49, .F., nTam, Len( aCat ),,,,,,,, lVisual )
	
	//Tratamento para separar retorno com barra "/"
	For nInc := 1 to Len( MvPar )
		If !( SubStr( MvPar, nInc, 1 ) $ " |*" )
			aAdd( aReturn, SubStr( MvPar, nInc, 1 ) )
		EndIf
	Next	
	
Return aReturn

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Program   ³CTBJobsStart ³ Autor ³ Totvs              ³ Data ³ 03.12.08 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Verifica se podera usar o JOB do CTB                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ CTBJobsStart()                                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Generico                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function CTBJobsStart()

If LockByName( "JOB_CTB_SALDO2_" + cEmpAnt )
	UnlockByName( "JOB_CTB_SALDO2_" + cEmpAnt)
	StartJob( "CTBSLDJOB2", Upper(GetEnvServer()), .F., { cEmpAnt, cFilAnt, cUserName, .F. } )
Endif

UnlockByName( "JOB_CTB_SALDO2_" + cEmpAnt)

Return

//-------------------------------------------------------------------
/*{Protheus.doc} IsCtbJob
Verifica se podera usar o JOB do CTB 
A função já possui cache de execução.

@author Alvaro Camillo Neto
   
@version P12
@since   20/02/2014
@return  Nil
@obs	 
*/
//-------------------------------------------------------------------
Function IsCtbJob()
Return IIf(__lIsCtbJob==Nil,__lIsCtbJob:=SuperGetMV("MV_CTBJOB",.F.,2)==1,__lIsCtbJob)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Função    ³CTBNomeVis ³ Autor ³ Marcelo Akama           ³ Data ³ 10/08/09 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Funcao para retornar o nome da visao gerencial                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Generico                                                      ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function CTBNomeVis( cCodigo )
Local aArea		:= GetArea()
Local aAreaCVE  := CVE->(GetArea())
Local cRet		:= ""

If !Empty(cCodigo)
	DbSelectArea( "CVE" )
	CVE->( DbSetOrder( 1 ) )

	If CVE->( DbSeek( xFilial( "CVE" ) + cCodigo ) )
		cRet := AllTrim(CVE->CVE_DESCRI)
	EndIf
EndIf

RestArea(aAreaCVE)
RestArea(aArea)
    
Return cRet

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Program   ³CtbExibe  ³ Autor ³ Pilar S. Albaladejo   ³ Data ³ 24.07.00 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Exibe descricao da Conta no Lcto Contabil                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³CtbExibe(cConta,cTipo,oDescDeb,oDescCrd,lRet)               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ .T. 		                                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Generico 	                                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpC1 = Conta contabil                                     ³±±
±±³          ³ ExpC2 = Tipo do Lancamento                                 ³±±
±±³          ³ ExpO1 = Objeto Descricao Conta Debito                      ³±±
±±³          ³ ExpO2 = Objeto Descricao Conta Credito                     ³±±
±±³          ³ ExpL1 = .T. -> Descricao da Conta / .F.-> Space(nTamConta) ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function CTBExibe(cConta,cTipo,oDescDeb,oDescCrd,lRet)

If cTipo == "1"
	CTB_Exibe(cConta,cTipo,"CT1"/*cAliasEnt*/,"CT1_DESC01"/*cCampo*/,{||CT1->CT1_DESC01}/*bCampo*/,oDescDeb/*oObjDesc*/,lRet)
ElseIf cTipo == "2"
	CTB_Exibe(cConta,cTipo,"CT1"/*cAliasEnt*/,"CT1_DESC01"/*cCampo*/,{||CT1->CT1_DESC01}/*bCampo*/,oDescCrd/*oObjDesc*/,lRet)
EndIf

Return .T.

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Program   ³CtbExibeCC³ Autor ³ Simone Mie Sato       ³ Data ³ 31.01.01 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Exibe descricao do Centro de Custo     		              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ CtbExibeCC(cCusto,cTipo,oDescCCD,oDescCCC,lRet)            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ .T. 		                                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Generico                                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpC1 = Centro de Custo                                    ³±±
±±³          ³ ExpC2 = Tipo do Lancamento                                 ³±±
±±³          ³ ExpO1 = Objeto Descricao CC Debito 	                      ³±±
±±³          ³ ExpO2 = Objeto Descricao CC Credito    		              ³±±
±±³          ³ ExpL1 = .T. -> Descricao do CC    / .F.-> Space(nTamConta) ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function CTBExibeCC(cCusto,cTipo,oDescCCD,oDescCCC,lRet)
If cTipo == "1"
	CTB_Exibe(cCusto,cTipo,"CTT"/*cAliasEnt*/,"CTT_DESC01"/*cCampo*/,{||CTT->CTT_DESC01}/*bCampo*/,oDescCCD/*oObjDesc*/,lRet)
ElseIf cTipo == "2"
	CTB_Exibe(cCusto,cTipo,"CTT"/*cAliasEnt*/,"CTT_DESC01"/*cCampo*/,{||CTT->CTT_DESC01}/*bCampo*/,oDescCCC/*oObjDesc*/,lRet)
EndIf

Return .T.
          
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³CtbExibeIt³ Autor ³ Simone Mie Sato       ³ Data ³ 31.01.01 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Exibe descricao do Item Contabil       		              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³CTBExibeIt(cItem,cTipo,odescItd,oDescItC,lRet)	          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ .T. 		                                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Generico 	                                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpC1 = Item Contabil                                      ³±±
±±³          ³ ExpC2 = Tipo do Lancamento                                 ³±±
±±³          ³ ExpO1 = Objeto Descricao Item Debito                       ³±±
±±³          ³ ExpO2 = Objeto Descricao Item Credito  		              ³±±
±±³          ³ ExpL1 = .T. -> Descricao do Item  / .F.-> Space(nTamConta) ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function CTBExibeIt(cItem,cTipo,oDescItD,oDescItC,lRet)

If cTipo == "1"
	CTB_Exibe(cItem,cTipo,"CTD"/*cAliasEnt*/,"CTD_DESC01"/*cCampo*/,{||CTD->CTD_DESC01}/*bCampo*/,oDescItD/*oObjDesc*/,lRet)
ElseIf cTipo == "2"
	CTB_Exibe(cItem,cTipo,"CTD"/*cAliasEnt*/,"CTD_DESC01"/*cCampo*/,{||CTD->CTD_DESC01}/*bCampo*/,oDescItC/*oObjDesc*/,lRet)
EndIf

Return .T.

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³CtbExibeCV³ Autor ³ Simone Mie Sato       ³ Data ³ 31.01.01 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Exibe descricao da Clase de Valores    		              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³CtbExibeCv(cClVl,Ctipo,oDescCvd,oDescCVC,lRet )             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ .T. 		                                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Generico                                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpC1 = Codigo da Classe de Valor                          ³±±
±±³          ³ ExpC2 = Tipo do Lancamento                                 ³±±
±±³          ³ ExpO1 = Objeto Descricao Classe de Valor Debito            ³±±
±±³          ³ ExpO2 = Objeto Descricao Classe de Valor Credito           ³±±
±±³          ³ ExpL1 = .T. -> Descricao da CV    / .F.-> Space(nTamConta) ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function CTBExibeCV(cClVl,cTipo,oDescCVD,oDescCVC,lRet)

If cTipo == "1"
	CTB_Exibe(cClVl,cTipo,"CTH"/*cAliasEnt*/,"CTH_DESC01"/*cCampo*/,{||CTH->CTH_DESC01}/*bCampo*/,oDescCVD/*oObjDesc*/,lRet)
ElseIf cTipo == "2"
	CTB_Exibe(cClVl,cTipo,"CTH"/*cAliasEnt*/,"CTH_DESC01"/*cCampo*/,{||CTH->CTH_DESC01}/*bCampo*/,oDescCVC/*oObjDesc*/,lRet)
EndIf

Return .T.

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³CTB_Exibe ³ Autor ³ Paulo Carnelossi          ³ Data ³ 01/09/09 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Exibe descricao das entidades        		                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ CTB_Exibe(cCodEnt,cTipo,cAliasEnt,cCampo,bCampo,oObjDesc,lRet) ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ .T. 		                                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Generico  (conversao das diversas CTBExibe()                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpC1 = Codigo da Entidade                                     ³±±
±±³          ³ ExpC2 = Tipo do Lancamento                                     ³±±
±±³          ³ ExpC3 = cAliasEnt-Alias da Entidade                            ³±±
±±³          ³ ExpC4 = Campo                                                  ³±±
±±³          ³ ExpB1 = Bloco de codigo para o campo                           ³±±
±±³          ³ ExpO1 = Objeto Descricao                                       ³±±
±±³          ³ ExpL1 = .T. -> Descricao     / .F.-> Space(nTam)               ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function CTB_Exibe(cCodEnt, cTipo, cAliasEnt, cCampo, bCampo, oObjDesc, lRet)
Local cDesc := CriaVar(cCampo)
Local nTam	:= Len(cDesc)

If !Empty(cCodEnt) .And. lRet
	cDesc := Eval(bCampo)
Else
	cDesc := Space(nTam)
EndIf

oObjDesc:SetText(OemToAnsi(cDesc))

Return .T.
	
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Program   ³CtbSoma1Li ³ Autor ³ Simone Mie Sato      ³ Data ³ 05.12.03 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Converte o conteudo do param. MV_NUMMAN com Soma1.          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³CtbSoma1Li()                                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ .T.					                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³Generico				                                      ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function CtbSoma1Li()

Local aSaveArea	:= GetArea()
Local nDif		:= 0
Local nNumMan	:= SuperGetMv("MV_NUMMAN")
Local nTamParam	:= 0
Local nDifParam	:= 0
Local cNumLin	:= ""
Local nCont		:= 0

nDif  := nNumMan - 999 

If nNumMan	> 999
	If nDif > 0
		cNumLin := "999"
		For nCont := 1 To nDif
			cNumLin := Soma1(cNumLin)
		Next
	Endif
Else
	cNumLin	:= Alltrim(Str(nNumMan))
	nTamParam	:= Len(cNumLin)
	nDifParam	:= 3 - nTamParam
	If nDifParam > 0
		cNumLin	:= ""
		For nCont	:= 1 to nDifParam
			cNumLin	+= "0"		
    	Next              
	    cNumLin	+= Alltrim(Str(nNumMan))
	EndIf    
EndIf

RestArea(aSaveArea)

Return(cNumLin)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³CTBA105   ºAutor  ³Microsiga           º Data ³  08/04/09   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³                                                            º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Function CtbLinMax(nMv_NumLin)
Local nRet := 0

If nMv_NumLin >= 35658  //limite estabelecido em razao do tamanho campo CT2_LINHA  = 3 e utilizar a funcao Soma1() para incremento
	nRet := 35657
Else
	nRet := nMv_NumLin
EndIf

Return(nRet)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³CTBRetaSLDºAutor  ³Marcos S. Lobo      º Data ³  09/12/06   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Retorna array com os tipos de saldo utilizados no SIGACTB.  º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP - Reprocessamento CTB                                   º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function CtbRetaSLD()
Local aTpSaldos := {}
Local aAreaOri	:= GetArea()
Local aAreaSX5	:= {}
Local cFilialX5

dbSelectArea( "SX5" )
cFilialX5 := xFilial( "SX5" )

aAreaSX5 := GetArea()
dbSetOrder( 1 )

If SX5->( MsSeek( cFilialX5 + "SL" , .F. ))

	While SX5->X5_FILIAL == cFilialX5 .And. SX5->X5_TABELA = "SL"
		Aadd( aTpSaldos, Left( SX5->X5_CHAVE, 1 ))

		SX5->( DbSkip() )
	EndDo

Else
	aTpSaldos := { "1", "2", "3", "4" }
Endif

RestArea( aAreaSX5 )
RestArea( aAreaOri )

Return aTpSaldos


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³CTBShowLisºAutor  ³Marcos S. Lobo      º Data ³  10/25/06   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³                                                            º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function CtbShowLst(cTitle,aItens)
Local oDlgList
Local oList1
Local oSBtn2
DEFAULT cTitle  := ""

oDlgList := MSDIALOG():Create()
oDlgList:cName := "oDlgList"
oDlgList:cCaption := cTitle
oDlgList:nLeft := 0
oDlgList:nTop := 0
oDlgList:nWidth := 365
oDlgList:nHeight := 352
oDlgList:lShowHint := .F.
oDlgList:lCentered := .T.

oList1 := TLISTBOX():Create(oDlgList)
oList1:cName := "oList1"
oList1:cCaption := ""
oList1:nLeft := 11
oList1:nTop := 12
oList1:nWidth := 338
oList1:nHeight := 273
oList1:lShowHint := .F.
oList1:lReadOnly := .F.
oList1:Align := 0
oList1:lVisibleControl := .T.
oList1:nAt := 0
oList1:aItems := aItens

oSBtn2 := SBUTTON():Create(oDlgList)
oSBtn2:cName := "oSBtn2"
oSBtn2:cCaption := "Ok"
oSBtn2:nLeft := 296
oSBtn2:nTop := 294
oSBtn2:nWidth := 52
oSBtn2:nHeight := 22
oSBtn2:lShowHint := .F.
oSBtn2:lReadOnly := .F.
oSBtn2:Align := 0
oSBtn2:lVisibleControl := .T.
oSBtn2:nType := 1
oSBTn2:bAction:= {|| oDlgList:End() }

oDlgList:Activate()

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ CtbDescEnt    º Autor ³ Gustavo Henrique º Data ³ 30/10/06 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Retorna a descricao do codigo de uma entidade contabil na  º±±
±±º          ³ moeda passada como parametro.                              º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºParametros³ cCodEnt   - Codigo para procura na entidade contabil       º±±
±±º          ³ cMoeda    - Moeda para identificar a descricao da entidade º±±
±±º          ³ cAliasEnt - Alias da entidade para pesquisa da descricao   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºRetorno   ³ cRet - Descricao do codigo da entidade contabil passado    º±±
±±º          ³        no parametro cCodEnt.                               º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Contabilidade Gerencial                                    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function CtbDescEnt( cCodEnt, cAliasEnt, cMoeda )
          
Local aArea 	:= GetArea()
Local aAreaEnt	:= (cAliasEnt)->(GetArea())
Local cCpoDesc	:= ""                    
Local cRet		:= ""

DEFAULT cCodEnt		:= ""
DEFAULT cMoeda		:= "01"
DEFAULT cAliasEnt	:= "CT1"

If cAliasEnt $ "CT1/CTT/CTD/CTH"

	If ValType(cCodEnt) == "N"
		cCodEnt := ALLTRIM(STR(cCodEnt)) 
	EndIf
	
	If ValType(cMoeda) == "N"
		cCodEnt := ALLTRIM(STR(cMoeda,2))
	EndIf
	                     
	(cAliasEnt)->( dbSetOrder(1) )
	If (cAliasEnt)->( MsSeek( xFilial(cAliasEnt) + cCodEnt, .F. ) )
		cCpoDesc := cAliasEnt + "_DESC" + cMoeda
		cRet := (cAliasEnt)->(CtbDescMoeda(cCpoDesc))
	EndIf

EnDif
		                      
RestArea( aAreaEnt )                     
RestArea( aArea )

Return( cRet )

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³GetRngFil ºAutor  ³Renato F. Campos    º Data ³  08/25/08   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Retorna a expressão correta                                º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function GetRngFil( xSelFil, cAlias as character, lTmpFil as logical, cTmpFil as character, nLimTmp as numeric, lFilOrg as logical, cRealTmp as character )
Local cRetorno   as character
Local aArea      as character
Local nX         as numeric
Local aStruct    as array
Local nTamFil    as numeric
Local lGestao    as logical
Local aModoComp  as array
Local lExclusivo as logical
Local cFilCpy    as character
Local cAtualxFil as character
Local nAt        as numeric
Local cNameTbl   as character
Local oBulk      as object

Default lTmpFil  := .F.
Default nLimTmp  := 50
Default lFilOrg  := .F.
Default cRealTmp := ""


cRetorno   := ""
aArea      := GetArea()
nX         := 0
aStruct    := {}
nTamFil    := CtbTamSXG("033",2) //grupo ; tamanho padrao
lGestao    := Iif(IsInCallStack("CTBR140"),Iif( lFWCodFil, ( "E" $ FWSM0Layout() .And. ("U" $ FWSM0Layout() .OR. "F" $ FWSM0Layout()) ), .F. ),;
			  Iif( lFWCodFil, ( LEN(CT2->CT2_FILIAL) > 2 ), .F. )) // Indica se usa Gestao Corporativa
aModoComp  := {}
lExclusivo := .F.
cFilCpy    := ""
cAtualxFil := ""
nAt        := 0
cNameTbl   := "" //Nome da tabela temporária

aAdd(aModoComp, FWModeAccess(cAlias,1) )
aAdd(aModoComp, FWModeAccess(cAlias,2) )
aAdd(aModoComp, FWModeAccess(cAlias,3) )

//ponto apenas para CTBS440.
If FWIsInCallStack("CTBS440") .or. Funname() == "CTBS440"
	cRetorno :=" = '" + IIF( lFilOrg, cFilAnt, FWxFilial(cAlias,cFilAnt,aModoComp[1],aModoComp[2],aModoComp[3]) ) + "' "
	Return cRetorno
EndIf
				
If lFWCodFil .And. lGestao
	lExclusivo := Ascan(aModoComp, 'E') > 0
Else
	dbSelectArea(cAlias)
	lExclusivo := !Empty(xFilial(cAlias))
EndIf

If Valtype(xSelFil) == "A"
	If lExclusivo .Or.; //cAlias em modo exclusivo
	   lFilOrg // Tratamento para FILIAL DE ORIGEM
		If lTmpFil .And. Len(xSelFil) > nLimTmp //50 //SOMENTE ACIMA DE 50 FILIAIS CRIA ARQUIVO TEMPORARIO NO BANCO

			If __aRealTempTable == Nil
				__aRealTempTable := {}
			EndIf

			If cTmpFil == NIL .or. Empty(cTmpFil)
				cTmpFil:= GetNextAlias() // Substituicao do CriaTrab para FWTemporaryTable	
			Endif

			If Select(cTmpFil) > 0
				dbSelectArea(cTmpFil)
				dbCloseArea()
			EndIf

			Aadd( __aRealTempTable, { cTmpFil, FWTemporaryTable():New( cTmpFil ) } )
			nAt := Len( __aRealTempTable )

			aStruct:= {}
			//--------------------------
			//Monta os campos da tabela
			//--------------------------
			AADD(aStruct,{ "TMPFIL", "C", nTamFil, 0 } )
				
			__aRealTempTable[nAT][2]:SetFields( aStruct )
			__aRealTempTable[nAT][2]:AddIndex("1", {"TMPFIL"} )
			
			//------------------
			//Criação da tabela
			//------------------
			__aRealTempTable[nAT][2]:Create()
			cNameTbl := __aRealTempTable[nAT][2]:GetRealName()
			//- AJUSTA NOME DA TABELA 
			If 'MSSQL' $ TcGetDb()
				cNameTbl := __aRealTempTable[nAT][2]:cTableName
			EndIf 
			// Objeto Bulk para inclusão em blocos
			oBulk := FwBulk():New(cNameTbl)
			oBulk:SetFields(aStruct)
			
			If lFWCodFil .And. lGestao
				cFilCpy := cFilAnt
				//laco para percorrer todas as filiais selecionadas
				For nX := 1 to Len(xSelFil)
					cFilAnt := xSelFil[nX]
					dbSelectArea(cAlias)
					cAtualxFil := IIF( lFilOrg, cFilAnt, FWxFilial(cAlias) )
					dbSelectArea(cTmpFil)
					//popula arquivo temporario no banco
					If !Empty(cAtualxFil) //.And. !MsSeek(cAtualxFil)
						oBulk:AddData({cAtualxFil})
					EndIf
				Next nX                      
				//restaura empresa/filial posicionada antes do laco
				cFilAnt := cFilCpy
			Else
				//popula arquivo temporario no banco
				For nX := 1 to Len(xSelFil)
					oBulk:AddData({SubStr(xSelFil[nX],1,nTamFil)})
				Next nX                      
			EndIf

			oBulk:Close()
			oBulk:Destroy()
			FreeObj(oBulk)
			oBulk := nil			
			//Banco de dados MSSQL retirar a extensão dbo.
			If Upper(TcGetDb()) $ "MSSQL7"
				cNameTbl := StrTran (__aRealTempTable[nAT][2]:GetRealName(),'dbo.') 
			Else
				cNameTbl := __aRealTempTable[nAT][2]:GetRealName()
			EndIf

			cRealTmp := cNameTbl

			cRetorno := "IN ( SELECT TMPFIL FROM " + cNameTbl + " GROUP BY TMPFIL) "

		ElseIf Len(xSelFil) > 1
			If lFWCodFil .And. lGestao
				cFilCpy := cFilAnt
				For nX := 1 to Len(xSelFil)
					cFilAnt := xSelFil[nX]
					dbSelectArea(cAlias)
					cAtualxFil := IIF( lFilOrg, cFilAnt, xFilial(cAlias) )
					cRetorno += cAtualxFil + "\" 	
				Next nX                      
				cRetorno := Left(cRetorno, Len(cRetorno) - 1 )
				cRetorno := "IN " + FormatIn(cRetorno,"\") + " "
				cFilAnt := cFilCpy
			Else
				For nX := 1 to Len(xSelFil)
					cRetorno += xSelFil[nX] + "\" 	
				Next nX                      
				cRetorno := Left(cRetorno, Len(cRetorno) - 1 )
				cRetorno := "IN " + FormatIn(cRetorno,"\") + " "
			EndIf
		Else
			If lFWCodFil .And. lGestao
				cFilCpy := cFilAnt
				If Len(xSelFil) > 0
					cFilAnt := xSelFil[1]
				EndIf
				dbSelectArea(cAlias)

				cAtualxFil := IIF( lFilOrg, cFilAnt, xFilial(cAlias) ) 

				cRetorno := " = '" + cAtualxFil + "' " 				
				cFilAnt := cFilCpy
			Else
				If Len(xSelFil) > 0 
					cRetorno := " = '" + xSelFil[1] + "' " 	
				Else
					cRetorno := " = '" + xFilial(cAlias) + "' " 	
				EndIf
			EndIf
		EndIf
	Else
		//cAlias em modo compartilhado	
		dbSelectArea(cAlias)
		cRetorno := " = '" + xFilial(cAlias) + "' " 	
	EndIf
	
Else
	cRetorno := " = '" + xFilial(cAlias,xSelFil) + "' "
EndIf          

RestArea(aArea)
aSize(aArea,0)
aArea := nil 
Return cRetorno

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³CtbTmpErase  ºAutor  ³Microsiga       º Data ³  02/06/11   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Deletar tabela temporaria do banco que contem as filiais   º±±
±±º          ³ utilizadas nas querys criado na funcao GetRngFil           º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function CtbTmpErase(cTmpFil)
Local aArea := GetArea()
Local nAT

If ValType(__aRealTempTable)=="A" .And. (nAt := Ascan(__aRealTempTable, {|x| x[1]==cTmpFil })) > 0

	__aRealTempTable[nAT][2]:Delete()
	__aRealTempTable[nAT][2] := Nil

	ADel(__aRealTempTable, nAT)
	ASize(__aRealTempTable,Len(__aRealTempTable)-1)

Else

	If cTmpFil <> NIL .And. Valtype(cTmpFil) == "C" .And. !Empty(cTmpFil) .AND. Select(cTmpFil) > 0
		dbSelectArea(cTmpFil)
		dbCloseArea()
		MsErase(cTmpFil)
		Sleep(100)
	EndIf

EndIf

RestArea(aArea)

Return
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³CW0Chav   ºAutor  ³Alvaro Camillo Neto º Data ³  19/11/09   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Retorna a primeira chave da tabela que contem a descrição  º±±
±±º          ³ passada.                                                   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function CW0Chav( cTabela,cDesc,cMoeda,cDefault )
Local cChave	:= ""
Local aArea		:= GetArea()
Local cCpoDesc := "CW0_DESC"
Default cMoeda	:= "01"
Default cDefault	:= ""

cCpoDesc+= Alltrim( cMoeda )

dbSelectArea("CW0")
CW0->( dbSetOrder( 1 ) ) // CW0_FILIAL + CW0_TABELA + CW0_CHAVE
CW0->( MsSeek( xFilial( "CW0" ) + cTabela ) )

While CW0->( CW0_FILIAL + CW0_TABELA ) == xFilial( "CW0" ) + cTabela .And. CW0->( !EOF() ) 
	If CW0->(&(cCpoDesc)) $ cDesc .Or. cDesc $ CW0->(&(cCpoDesc))  
		cChave := CW0->CW0_CHAVE
		Exit 
	EndIf 
	CW0->( dbSkip() )
EndDo 	

cChave := IIF( !Empty(cChave),cChave,cDefault  )

RestArea(aArea)
Return cChave

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³CW0Desc   ºAutor  ³Alvaro Camillo Neto º Data ³  19/11/09   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Retorna o conteudo relacionado a chave passada da tabela   º±±
±±º          ³ auxiliar                                                   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function CW0Desc( cTabela,cChave,cMoeda )
Local cDesc	:= ""
Local aArea		:= GetArea()
Local cCpoDesc := "CW0_DESC"
Default cMoeda	:= "01"

cCpoDesc+= Alltrim( cMoeda )


dbSelectArea("CW0")
CW0->( dbSetOrder( 1 ) ) // CW0_FILIAL + CW0_TABELA + CW0_CHAVE
If CW0->( MsSeek( xFilial( "CW0" ) + cTabela + cChave ) )
	cDesc := CW0->(&(cCpoDesc))
EndIf	 


RestArea(aArea)
Return cDesc


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³CW0Desc   ºAutor  ³Alvaro Camillo Neto º Data ³  19/11/09   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Retorna o nome da tabela                                   º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function CW0Tab( cTabela, cMoeda )
Local cDesc	:= ""
Local aArea		:= GetArea()
Local cCpoDesc := "CW0_DESC"
Default cMoeda	:= "01"

cCpoDesc+= Alltrim( cMoeda )

dbSelectArea("CW0")
CW0->( dbSetOrder( 1 ) ) // CW0_FILIAL + CW0_TABELA + CW0_CHAVE
If CW0->( MsSeek( xFilial( "CW0" ) + "00" + cTabela ) )
	cDesc := CW0->(&(cCpoDesc))
EndIf	 


RestArea(aArea)
Return cDesc

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³CW0CONS   ºAutor  ³Microsiga           ºFecha ³  02/26/10   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³                                                            º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function CW0CONS(cTabela,cMoeda)
	Local cQuery	:= ""
	Local cAliasCW0	:= ""
	Local cDescCW0	:= ""
	Local cFilCW0	:= ""
	Local cCpoCW0	:= ""
	Local cDesc		:= ""
	Local nItem		:= 0
	Local xRet
	Local aArea		:= {}
	Local aAreaCW0	:= {}
	Local aItens	:= {}
	Local aScrRes	:= {}
	Local oDlgCW0
	Local oBrwCW0
	//Paineis
	Local oPnlTopo
	Local oPnlEsq
	Local oPnlDir
	Local oPnlBase
	Local oPnlCons
	Local oPnlCons1
	Local oPnlBot
	Local oSep0
	Local oSep1
	Local oSep2
	Local oSep3
	Local oSep4
	Local oSep5
	//Botoes	
	Local oBtnSair
	Local oBtnOk
	Local oBtnPesq
	//variaveis
	Local oDesc
	Local oSayDesc
	
	Default cMoeda	:= "01"
	
	aArea := GetArea()
	cFilCW0 := xFilial("CW0")
	If CW0->(DbSeek(cFilCW0 + "00" + PadR(cTabela,TamSX3("CW0_CHAVE")[1])))
		cCpoCW0 := "CW0_DESC" + cMoeda
		cDescCW0 := CW0->(&cCPOCW0) 
		cQuery := "select R_E_C_N_O_,CW0_CHAVE," + cCpoCW0 + " W0DESC from " + RetSqlName("CW0")
		cQuery += " where CW0_FILIAL = '" + xFilial("CW0") + "'"
		cQuery += " and CW0_TABELA = '" + PadR(cTabela,TamSX3("CW0_TABELA")[1]) + "'"
		cQuery += " and D_E_L_E_T_=''"
		cAliasCW0 := GetNextAlias()
		cQuery := ChangeQuery(cQuery)
		dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasCW0,.T.,.T.)
		dbSelectArea(cAliasCW0)
		(cAliasCW0)->(DbGoTop())
		While !((cAliasCW0)->(Eof()))
			Aadd(aItens,{(cAliasCW0)->CW0_CHAVE,(cAliasCW0)->W0DESC,(cAliasCW0)->R_E_C_N_O_})
			(cAliasCW0)->(DbSkip())
		Enddo
		dbSelectArea(cAliasCW0)
		DbCloseArea()
		If !Empty(aItens)
			cDesc := Space(CW0->(TamSX3(cCpoCW0)[1]))
			aScrRes := MsAdvSize(.F.,.F.,300)
			oDlgCW0 := TDialog():New(aScrRes[7],0,aScrRes[6]-250,aScrRes[5]-450,AllTrim(cDescCW0),,,,,,,,,.T.,,,,,)
				oPnlEsq := TPanel():New(01,01,,oDlgCW0,,,,,,5,5,.F.,.F.)
					oPnlEsq:Align := CONTROL_ALIGN_LEFT
					oPnlEsq:nWidth := 10
				oPnlDir := TPanel():New(01,01,,oDlgCW0,,,,,,5,5,.F.,.F.)
					oPnlDir:Align := CONTROL_ALIGN_RIGHT
					oPnlDir:nWidth := 10
				oPnlBase := TPanel():New(01,01,,oDlgCW0,,,,,,5,30,.F.,.F.)
					oPnlBase:Align := CONTROL_ALIGN_BOTTOM
					oPnlBase:nHeight := 10
				oPnlTopo := TPanel():New(01,01,,oDlgCW0,,,,,,5,30,.F.,.F.)
					oPnlTopo:Align := CONTROL_ALIGN_TOP
					oPnlTopo:nHeight := 10
				oPnlCons := TPanel():New(01,01,,oDlgCW0,,,,,,5,30,.F.,.F.)
					oPnlCons:Align := CONTROL_ALIGN_TOP
					oPnlCons:nHeight := 40
					oPnlCons1 := TPanel():New(01,01,,oPnlCons,,,,,,5,30,.F.,.F.)
						oPnlCons1:Align := CONTROL_ALIGN_ALLCLIENT
						@00,00 MSGET oDesc VAR cDesc SIZE 5,100 PIXEL OF oPnlCons1
							oDesc:Align := CONTROL_ALIGN_BOTTOM
							oDesc:nHeight := 20
						oSayDesc := TSay():New(0,0,{|| CW0->(RetTitle(cCpoCW0))},oPnlCons1,,,,,,.T.,,,10,10)
							oSayDesc:Align := CONTROL_ALIGN_TOP
							oSayDesc:nHeight := 20
					oSep4 := TPanel():New(01,01,,oPnlCons,,,,,,5,30,.F.,.F.)
						oSep4:Align := CONTROL_ALIGN_RIGHT
						oSep4:nWidth := 10
					oSep5 := TPanel():New(01,01,,oPnlCons,,,,,,5,30,.F.,.F.)
						oSep5:Align := CONTROL_ALIGN_LEFT
						oSep5:nWidth := 10
					oPnlBot := TPanel():New(01,01,,oPnlCons,,,,,,5,30,.F.,.F.)
						oPnlBot:Align := CONTROL_ALIGN_RIGHT
						oPnlBot:nWidth := 100
					oPnlBot1 := TPanel():New(01,01,,oPnlBot,,,,,,5,30,.F.,.F.)
						oPnlBot1:Align := CONTROL_ALIGN_BOTTOM
						oPnlBot1:nHeight := 20
						oBtnPesq := TButton():New(0,0,"Pesquisar",oPnlBot1,{|| },30,10,,,,.T.,,"",,,,)
							oBtnPesq:Align := CONTROL_ALIGN_RIGHT
							oBtnPesq:nWidth := 80
				oSep3 := TPanel():New(01,01,,oDlgCW0,,,,,,5,30,.F.,.F.)
					oSep3:Align := CONTROL_ALIGN_TOP
					oSep3:nHeight := 10
				oPnlBotoes := TPanel():New(01,01,,oDlgCW0,,,,,,5,30,.F.,.F.)
					oPnlBotoes:Align := CONTROL_ALIGN_BOTTOM
					oPnlBotoes:nHeight := 20
					oSep0 := TPanel():New(01,01,,oPnlBotoes,,,,,,5,30,.F.,.F.)
						oSep0:Align := CONTROL_ALIGN_TOP
						oSep0:nHeight := 5
					oSep1 := TPanel():New(01,01,,oPnlBotoes,,,,,,5,30,.F.,.F.)
						oSep1:Align := CONTROL_ALIGN_RIGHT
					oBtnSair := TButton():New(0,0,"Cancelar",oPnlBotoes,{|| nItem := 0,oDlgCW0:End()},30,10,,,,.T.,,"",,,,)
						oBtnSair:Align := CONTROL_ALIGN_RIGHT
					oSep2 := TPanel():New(01,01,,oPnlBotoes,,,,,,5,30,.F.,.F.)
						oSep2:Align := CONTROL_ALIGN_RIGHT
					oBtnOk := TButton():New(0,0,"Selecionar",oPnlBotoes,{|| nItem := oBrwCW0:nAt,oDlgCW0:End()},30,10,,,,.T.,,"",,,,)
						oBtnOk:Align := CONTROL_ALIGN_RIGHT
				oBrwCW0 := TCBrowse():New(0,0,100,100,,,,oBrwCW0,,,,,,,,,,,,.T.,"",.T.,{|| .T.},,,,)
				oBrwCW0:AddColumn(TCColumn():New(CW0->(RetTitle("CW0_CHAVE")),{|| aItens[oBrwCW0:nAt,1]},,,,"LEFT",15,.F.,.F.,,,,,))
				oBrwCW0:AddColumn(TCColumn():New(CW0->(RetTitle(cCpoCW0)),{|| aItens[oBrwCW0:nAt,2]},,,,"LEFT",150,.F.,.F.,,,,,))
				oBrwCW0:Align     := CONTROL_ALIGN_ALLCLIENT
				oBrwCW0:lAutoEdit := .F.
				oBrwCW0:lReadOnly := .F.
				oBrwCW0:SetArray(aItens)
				oDlgCW0:lCentered := .T.
			oDlgCW0:Activate(,,,,)
		Else
			Help(" ",1,"CT5PLGER1",,STR0031+" "+cTabela,1,0)//"Não foram encontrados itens para a tabela "
		Endif
	Else
		Help(" ",1,"CT5PLGER2",,STR0032 +" " + cTabela +" " + STR0033,1,0)//"Tabela "##" não encontrada na lista de tabelas auxiliares"
	Endif
	RestArea(aArea)
	If nItem > 0
		CW0->(DbGoTo(aItens[nItem,3]))
		xRet := .T. //aItens[nItem,1]
	Endif
Return(xRet)
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³DecodSoma1ºAutor  ³Microsiga           º Data ³  16/07/10   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Decodifica Soma1() com parametro MV_SOMAOLD = .F.           º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Function DecodSoma1(cCodigo)
Local nTam := Len(cCodigo)
Local nX
Local nStep
Local cMaxCod
Local nDecCod := 0
Local cCodB10
Local cCodB36
Local nB36Cod

If _lSomaOld == NIL
	_lSomaOld := SuperGetMv("MV_SOMAOLD",,.F.)
EndIf

If nTam >= 1

	cMaxCod := Repl("9", nTam)
	
	If cCodigo <= cMaxCod
		nDecCod := Val(cCodigo)
	Else
	
		If _lSomaOld
		
			nDecCod := DecSoma1Old(cCodigo)   //somente com ate 6 digitos
		
		Else
	
			nStep := 0	
			FOR nX := nTam TO 1 STEP -1
				
				nStep++
				cMaxCod := Repl("9", nX - 1)+Repl("Z", nStep)
				
				If cCodigo <= cMaxCod
					
					cCodB10 := Left(cCodigo, nX - 1)
					cCodB36 := Right(cCodigo, nStep)
					
					nDecCod := Val(cCodB10) * (10 ^ nStep)
					
					nB36Cod := DecoBase36(cCodB36)
					
					nDecCod += nB36Cod - S1AjustB36(Len(cCodB36))				
					Exit
					
				EndIf
				
		    Next //nX
	    
	    EndIf
	    
	EndIf

EndIf

Return(nDecCod)


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³DecoBase36ºAutor  ³Microsiga           º Data ³  16/07/10   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Usado para decodificar Soma1() com parametro                º±±
±±º          ³MV_SOMAOLD = .F.  --> decodifica em base 36                 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Function DecoBase36(cCodB36)
Local nRet := 0
Local nTam
Local nX
Local cBase36 := "0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZ"

nTam := Len(cCodB36)

nExpoente := 0

FOR nX := nTam TO 1 STEP -1

	cString := Substr(cCodB36, nX, 1)
	
	nPosStr := At(cString, cBase36)
	
	nRet += nPosStr*(36^nExpoente)
	
	nExpoente++

NEXT	

Return(nRet)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³S1AjustB36ºAutor  ³Microsiga           º Data ³  16/07/10   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Usado para decodificar Soma1() com parametro                º±±
±±º          ³MV_SOMAOLD = .F.  --> decodifica em base 36                 º±±
±±º          ³Fator de Ajuste para decodificar                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Function S1AjustB36(nTam)
Local nRet := 0

If nTam == 1
	nRet := DecoBase36("A")-(10^nTam)
Else
	nRet := DecoBase36(Repl("9",nTam-1)+"A")-(10^nTam)
EndIf

Return(nRet)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³DecSoma1Old ºAutor ³Microsiga          º Data ³  16/07/10   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Usado para decodificar Soma1() com parametro                º±±
±±º          ³MV_SOMAOLD = .T. (antiga forma soma1  --> decodifica em     º±±
±±º          ³base 36 com ajuste                                          º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Function DecSoma1Old(cCodigo)
Local nTam 		:= Len(cCodigo)
Local nRet  	:= 0
Local aTipos   := {}
Local aDifer   := {}
Local nX
Local cDigito
Local nPosNumero
Local nDigB36
Local nFator

If cCodigo <= Repl("9", nTam)
	nRet := Val(cCodigo)
Else 
	If nTam == 1
		nRet := DecoBase36(cCodigo)-1
	Else
		For nX := 1	 To nTam 
			cDigito := Substr(cCodigo, nX, 1)
			nDigB36 := DecoBase36(cDigito)
			If nDigB36 > 10
				aAdd(aTipos, "C") //caracter
				aAdd(aDifer, DecoBase36(cDigito)-DecoBase36("A") )
			Else
				aAdd(aTipos, "N") //numeros
				aAdd(aDifer, Val(cDigito) )
			EndIf
		Next

		nPosNumero := Ascan(aTipos, "N")

		If nPosNumero == 0 //soh tem letras
			nFator := 0	
			For nX := 1 TO nTam - 1
				nFator += Soma1Fator((nTam-nX)+1, aDifer[nX]) 
			Next
			nFator += DecoBase36(Right(cCodigo,1))
			nRet := nFator
			nRet-- 
		Else
			nFator := 0	
			For nX := 1 TO nPosNumero-1
				nFator += Soma1Fator((nTam-nX)+1, aDifer[nX])
			Next
			nFator += Val(Substr(cCodigo,nPosNumero))
			nRet := nFator
	    EndIf
	EndIf
	
EndIf
	
Return(nRet)	

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³Soma1Fator  ºAutor ³Microsiga          º Data ³  16/07/10   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Usado para decodificar Soma1() com parametro                º±±
±±º          ³MV_SOMAOLD = .T. (antiga forma soma1  --> decodifica em     º±±
±±º          ³base 36 com ajuste                                          º±±
±±º          ³obs: codigos somente com ate 6 digitos                      º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Function Soma1Fator(nTam, nElem)
Local nRet := 0
Local nDecAux := 0

If nTam > 1  //somente utilizado para tamanho 2 em diante

	nRet += nElem * (26^(nTam-2))
	nRet *= 36

	//parte decimal
	nDecAux := (10^(nTam))   //parte fixa
	
	If 		nTam-1 == 1
			nDecAux += 0
	ElseIf 	nTam-1 == 2
			nDecAux += nElem*100     		// 10 x 10
	ElseIf nTam-1 == 3
			nDecAux += nElem*3600    		// 36*10 * 10
	ElseIf nTam-1 == 4
			nDecAux += nElem*103600  		// 
	ElseIf nTam-1 == 5
			nDecAux += nElem*18003600      	// 
	EndIf
	
	nRet += nDecAux
	
EndIf

Return( nRet) 

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³CTBXFUNA  ºAutor  ³Microsiga           º Data ³  02/02/15   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Wizard                                                     º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Function CtbWizard(aWizMain, aWizPanel, aPanel, lCenter, bValid, bInit, bWhen)
Local oWizard
Local nX
Local cTitle
Local bNext
Local bBack
Local lPanel
Local lNoFirst
Local bFinish
Local bExecute

Default aWizMain 	:= {}
Default aWizPanel 	:= {}
Default aPanel 		:= {}
Default lCenter 	:= .T.
Default bValid 		:= {||.T.}
Default bInit 		:= {||.T.}
DeFault bWhen 		:= {||.T.}

If Len(aWizMain) > 0
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Array aWizMain - Estrutura:                         ³
	//³ Posicao 1 - Titulo                                  ³
	//³         2 - Mensagem Explicativa                    ³
	//³         3 - bNext                                   ³
	//³         4 - bFinish                                 ³
	//³         5 - lPanel                                  ³
	//³         6 - lNoFist                                 ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Painel 1 - Tela inicial do Wizard 		            ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	cTitle 		:= If(Len(aWizMain) > 0 .And. aWizMain[1]==NIL, ""		,aWizMain[1])
	cMessage 	:= If(Len(aWizMain) > 1 .And. aWizMain[2]==NIL, ""		,aWizMain[2])
	bNext 		:= If(Len(aWizMain) > 2 .And. aWizMain[3]==NIL, {||.T.}	,aWizMain[3])
	bFinish 	:= If(Len(aWizMain) > 3 .And. aWizMain[4]==NIL, {||.T.}	,aWizMain[4])
	lPanel 		:= If(Len(aWizMain) > 4 .And. aWizMain[5]==NIL, .T.		,aWizMain[5])
	lNoFirst 	:= If(Len(aWizMain) > 5 .And. aWizMain[6]==NIL, .F.		,aWizMain[6])
	
	oWizard := APWizard():New( cTitle/*<chTitle>*/,; 
								""/*<chMsg>*/,;
								""/*<cTitle>*/, ; 
								cMessage, ; 
								bNext,;
								bFinish,;
								lPanel,;
								,;
								,;
								lNoFirst)
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Paineis                                             ³
	//³ Array aWizPanel - Estrutura:
	//³ Para cada linha dete array multidimensional         ³
	//³ Posicao 1 - Titulo do painel                        ³
	//³         2 - Mensagem Explicativa                    ³
	//³         3 - bNext                                   ³
	//³         4 - bFinish                                 ³
	//³         5 - lPanel                                  ³
	//³         6 - bBack                                   ³
	//³         7 - bExecute                                ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	For nX := 1 To Len(aWizPanel)
		cTitle 		:= If(Len(aWizPanel[nx]) > 0 .And. aWizPanel[nx][1]==NIL, ""		,aWizPanel[nx][1])
		cMessage 	:= If(Len(aWizPanel[nx]) > 1 .And. aWizPanel[nx][2]==NIL, ""		,aWizPanel[nx][2])
		bNext 		:= If(Len(aWizPanel[nx]) > 2 .And. aWizPanel[nx][3]==NIL, {||.T.},aWizPanel[nx][3])
		bFinish 	:= If(Len(aWizPanel[nx]) > 3 .And. aWizPanel[nx][4]==NIL, {||.T.},aWizPanel[nx][4])
		lPanel 		:= If(Len(aWizPanel[nx]) > 4 .And. aWizPanel[nx][5]==NIL, .T.	,aWizPanel[nx][5])
		bBack	 	:= If(Len(aWizPanel[nx]) > 6 .And. aWizPanel[nx][6]==NIL, {||.T.},aWizPanel[nx][6])
		bExecute 	:= If(Len(aWizPanel[nx]) > 7 .And. aWizPanel[nx][7]==NIL, {||.T.},aWizPanel[nx][7])
	
		oWizard:NewPanel(	cTitle/*<chTitle>*/,; 
							cMessage/*<chMsg>*/,; 
							bBack,;
							bNext,;
							bFinish,;
							lPanel,;
							bExecute)
							
		aAdd(aPanel, oWizard:oMPanel[nX+1] )
		
	Next
	
	oWizard:Activate( 	lCenter,;
						bValid,;
						bInit,;
						bWhen)
EndIf

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³CtbQtdEntdºAutor  ³Paulo Carnelossi    º Data ³  21/06/10   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Retorna quantidade de entidades cadastradas na tabela CT0  º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function CtbQtdEntd()
Local nQtdEntid := 4
Local aArea 	:= GetArea()
Local aAreaCT0  := CT0->(GetArea())
Local cAliasEnt	:= "CT0"

If Type("lCTB240Ori")=='L'
	If lCTB240Ori
		cAliasEnt := "CTBCT0"
	EndIf
EndIf

nQtdEntid := 0
dbSelectArea(cAliasEnt)
dbSetOrder(1)
	
dbSeek(xFilial("CT0"))
	
While (cAliasEnt)->(! Eof() .And. CT0_FILIAL == xFilial("CT0") )
	nQtdEntid++
	(cAliasEnt)->(dbSkip())
EndDo
	
If nQtdEntid<4 // Caso a CT0 exista, mas não existam pelo menos as 4 entidades, carrega as configuracoes do CTB
	CTBCarga() // Carrega configuracoes do módulo CTB
		
	nQtdEntid := 0
	dbSelectArea(cAliasEnt)
	dbSetOrder(1)
	
	dbSeek(xFilial("CT0"))
	
	Do While (cAliasEnt)->(! Eof() .And. CT0_FILIAL == xFilial("CT0") )
		nQtdEntid++
		(cAliasEnt)->(dbSkip())
	EndDo
EndIf
	
If nQtdEntid<4 // Se ainda nao existem pelo menos as 4 entidades, retorna 4
	nQtdEntid := 4
EndIf

RestArea(aAreaCT0)
RestArea(aArea)

Return(nQtdEntid)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³CtbUseAmarºAutor  ³Paulo Carnelossi    º Data ³  21/06/10   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Retorna parametrizacao referente amarracao de entidades    º±±
±±º          ³ 0 - nao tem amarracao                                      º±±
±±º          ³ 1 - Regra de níveis                                        º±±
±±º          ³ 2 - Regra de Amarração tabela CTA                          º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function CtbUseAmar()
Local cAmarracao := SuperGetMv('MV_CTBAMAR',.F.,"0")
Return(cAmarracao)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³CtbIsCube ºAutor  ³Paulo Carnelossi    º Data ³  21/06/10   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Retorna se trabalha com cubos gerenciais utilizando a      º±±
±±º          ³ tabela CT0 como cadastro de cubos sendo que a estrutura    º±±
±±º          ³ do cubo sera todos os registros ate o ID do cubo           º±±
±±º          ³ Parametro MV_CTBCUB   (CARACTER)                           º±±
±±º          ³ 0 - Nao trabalha com cubo                                  º±±
±±º          ³ 1 - Trabalha com Cubo                                      º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function CtbIsCube()
Local lRet := .F.
Local aArea := GetArea() 

lRet := SuperGetMv('MV_CTBCUBE',.F.,"0")=="1"

If lRet  //se trabalha com os cubos deve provocar abertura dos alias CVX/CVY/CVZ
	dbSelectArea("CVX")
	dbSelectArea("CVY")
	dbSelectArea("CVZ")
Endif 

RestArea(aArea)

Return(lRet) 


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³CtbEntArrºAutor  ³Alvaro Camillo Neto º Data ³  04/11/12   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Retorna um array com os ID das novas entidades contábeis   º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function CtbEntArr(lTodasEnt)
Local aRet     := {}
Local aArea    := GetArea()
Local aAreaCT0 := {}

Default lTodasEnt := .F.

If AliasInDic("CT0")
	aAreaCT0 := CT0->(GetArea())
	CT0->(dbSetOrder(1)) //CT0_FILIAL+CT0_ID
	If CT0->(MsSeek(xFilial("CT0")))
		While CT0->(!EOF()) .And. CT0->CT0_FILIAL == xFilial("CT0")
			If lTodasEnt
				aAdd(aRet,CT0->CT0_ID )
			Else
				If CT0->CT0_ID > "04"
					aAdd(aRet,CT0->CT0_ID )
				EndIf
			EndIf
			
			CT0->(dbSkip())
		EndDo
	EndIf
	RestArea(aAreaCT0)
EndIf

RestArea(aArea)
Return aRet
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³CtbVerSX2 ºAutor  ³Paulo Carnelossi    º Data ³  21/06/10   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ CtbVerSX2(cAlias, lHelp) - Retorna .T. se existe a tabela  º±±
±±º          ³ especificada no alias no dicionario SX2, ou .F. se nao     º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function CtbVerSX2()

//---------------------------------------------------------------------
// As rotinas que utilizam essa funcao avaliam somente a CT0 nao sendo
// mais necessaria essa avaliacao devido o release incremental
//---------------------------------------------------------------------

Return(.T.)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³CTBVldNEntºAutor  ³Totvs               ºFecha ³ 03/12/2010  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Valida as novas entidades contabeis.                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function CTBVldNEnt( lHelp As Logical, cEnt5 As Character, cEnt6 As Character, cEnt7 As Character, cEnt8 As Character, cEnt9 As Character, cEntidade As Character,cDc As Character ) As Logical
Local lRet  		As Logical
Local aArea 		As Array
Local lAtuDescEnt 	As Logical

Default cDc := ""
Default lHelp := .F.
Default cEnt5 := ""
Default cEnt6 := ""
Default cEnt7 := ""
Default cEnt8 := ""
Default cEnt9 := ""
Default cEntidade := ""
Default cDc := ""


lRet 		:= .T.   
aArea 		:= getArea()
lAtuDescEnt := .F.

If lRet .AND. CT1->( FieldPos( "CT1_05OBRG" ) ) > 0
	If CT1->CT1_05OBRG == "1" .And. Empty(cEnt5)
		cEntidade := cEntidade + Iif(!Empty(cEntidade),CRLF,"") + "05 " + cDc 
		If lHelp
			Help(" ",1,"ENTIDOBRIG",,cEntidade,3,1)
		EndIf
		lRet := .F.
	ElseIf !Empty(cEnt5) 
		If !CTB105EntC(,cEnt5,.F.,'05',lAtuDescEnt)
			If lHelp
				Help("  ", 1, "NOENTIDA",,"Ent. 05 " + cDc +" : "+Alltrim(cEnt5),3,1)
			EndIf
			lRet := .F.
		EndIf
	EndIf
EndIf

If lRet .AND. CT1->( FieldPos( "CT1_06OBRG" ) ) > 0
	If CT1->CT1_06OBRG == "1" .And. Empty(cEnt6)
		cEntidade := cEntidade + Iif(!Empty(cEntidade),CRLF,"") + "06 " +  cDc  
		If lHelp
			Help(" ",1,"ENTIDOBRIG",,cEntidade,3,1)
		EndIf
		lRet := .F.
	ElseIf !Empty(cEnt6) 
		If !CTB105EntC(,cEnt6,.F.,'06',lAtuDescEnt)
			If lHelp
				Help("  ", 1, "NOENTIDA",,"Ent. 06 " + cDc +" : "+Alltrim(cEnt6),3,1)
			EndIf
			lRet := .F.
		EndIf
	EndIf
EndIf

If lRet .AND. CT1->( FieldPos( "CT1_07OBRG" ) ) > 0
	If CT1->CT1_07OBRG == "1" .And. Empty(cEnt7) 
		cEntidade := cEntidade + Iif(!Empty(cEntidade),CRLF,"") + "07 " +  cDc  
		If lHelp
			Help(" ",1,"ENTIDOBRIG",,cEntidade,3,1)
		EndIf
		lRet := .F.
	ElseIf !Empty(cEnt7) 
		If !CTB105EntC(,cEnt7,.F.,'07',lAtuDescEnt)
			If lHelp
				Help("  ", 1, "NOENTIDA",,"Ent. 07 " + cDc +" : "+Alltrim(cEnt7),3,1)
			EndIf
			lRet := .F.
		EndIf
	EndIf
EndIf

If lRet .AND. CT1->( FieldPos( "CT1_08OBRG" ) ) > 0
	If CT1->CT1_08OBRG == "1" .And. Empty(cEnt8)
		cEntidade := cEntidade + Iif(!Empty(cEntidade),CRLF,"") + "08 " +  cDc   	
		If lHelp
			Help(" ",1,"ENTIDOBRIG",,cEntidade,3,1)
		EndIf
		lRet := .F.
	ElseIf !Empty(cEnt8) 
		If !CTB105EntC(,cEnt8,.F.,'08',lAtuDescEnt)
			If lHelp
				Help("  ", 1, "NOENTIDA",,"Ent. 08 " + cDc +" : "+Alltrim(cEnt8),3,1)
			EndIf
			lRet := .F.
		EndIf
	EndIf
EndIf

If lRet .AND. CT1->( FieldPos( "CT1_09OBRG" ) ) > 0
	If CT1->CT1_09OBRG == "1" .And. Empty(cEnt9)
		cEntidade := cEntidade + Iif(!Empty(cEntidade),CRLF,"") + "09 " +  cDc   
		If lHelp
			Help(" ",1,"ENTIDOBRIG",,cEntidade,3,1)
		EndIf
		lRet := .F.
	ElseIf !Empty(cEnt9) 
		If !CTB105EntC(,cEnt9,.F.,'09',lAtuDescEnt)
			If lHelp
				Help("  ", 1, "NOENTIDA",,"Ent. 09 " + cDc +" : "+Alltrim(cEnt9),3,1)
			EndIf
			lRet := .F.
		EndIf
	EndIf
EndIf

RestArea(aArea)
Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o	 ³TamSXG ³ Autor ³ Alvaro Camillo Neto  	³ Data ³ 14/01/10 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Função que retorna tamanho do campo                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Geral                                                      ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function CtbTamSXG(cGrupo,nTamPad)
Local nSize := 0

DbSelectArea("SXG")
DbSetOrder(1)

IF DbSeek(cGrupo)
	nSize := SXG->XG_SIZE
Else
	nSize := nTamPad
Endif

Return nSize

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³CtUpdLPCW0ºAutor  ³Totvs               ºFecha ³ 03/12/2010  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Atualiza o CW0 LP indicando se eh zeram. c/cta ponte ou nao.   º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function CtUpdLPCW0()
Local aSaveArea	:= GetArea()

Local cQuery	:= ""
Local cChar		:= ""
Local cAliasTRB := GetNextAlias()

Local dDataLP	:= CTOD("  /  /  ")

Local cLote		:= ""
Local cSubLote	:= ""
Local cDoc		:= ""
Local cTpSald	:= ""
Local cEmpOri	:= ""
Local cFilOri	:= ""
Local cMoeda	:= ""
Local lProcessado := .F.
Local cCampo :=  "CW0->CW0_DESC01"
Local aLstCW0 := {}

If CtLPCW0Tab()	
	dbSelectArea("CW0")
	dbSelectArea("CTZ")
	CW0->(dbSetOrder(1)) //CW0_FILIAL+CW0_TABELA+CW0_CHAVE
	CTZ->(dbSetOrder(1)) //CTZ_FILIAL+CTZ_DATA+CTZ_LOTE+CTZ_SBLOTE+CTZ_DOC+CTZ_TPSALD+CTZ_EMPORI+CTZ_FILORI+CTZ_MOEDLC+CTZ_LINHA+CTZ_SEQLIN

	If CW0->(MsSeek(xFilial("CW0")+"LP"))
		cChar	:= Subs(&(cCampo),12,1)
		If cChar $ "P/Z"
			Return
		EndIf
	EndIf
	
	//DATAS DE APURACAO COM CONTA PONTE	
	cQuery := "SELECT DISTINCT CT2_FILIAL, CT2_DTLP, CT2_LOTE, CT2_SBLOTE, CT2_DOC, CT2_TPSALD, "
	cQuery += " CT2_EMPORI, CT2_FILORI, CT2_MOEDLC "
	cQuery += " FROM "+RetSqlName("CT2")
	cQuery += " WHERE D_E_L_E_T_ = ' ' "
	cQuery += " AND CT2_FILIAL = '"+xFilial("CT2")+"' "
	cQuery += " AND CT2_DTLP <> ' ' "
	cQuery += " ORDER BY CT2_FILIAL, CT2_DTLP, CT2_LOTE, CT2_SBLOTE, CT2_DOC, CT2_TPSALD, CT2_EMPORI, CT2_FILORI, CT2_MOEDLC "
	cQuery := ChangeQuery(cQuery)
		
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasTRB,.T.,.F.)
		
	TCSetField(cAliasTRB,"CT2_DTLP", "D",8,0)
		
	dbSelectArea(cAliasTRB)
	While (cAliasTRB)->(!Eof())
		dDataLp	:= (cAliasTRB)->CT2_DTLP
		cLote	:= (cAliasTRB)->CT2_LOTE
		cSubLote:= (cAliasTRB)->CT2_SBLOTE
		cDoc	:= (cAliasTRB)->CT2_DOC
		cTpSald	:= (cAliasTRB)->CT2_TPSALD
		cEmpOri	:= (cAliasTRB)->CT2_EMPORI
		cFilOri	:= (cAliasTRB)->CT2_FILORI
		cMoeda	:= (cAliasTRB)->CT2_MOEDLC
			
		If CTZ->(MsSeek(xFilial()+DTOS(dDataLP)+cLote+cSubLote+cDoc+cTpSald+cEmpOri+cFilOri+cMoeda))
			cChar	:= "P"	//Indica que eh apuracao com conta ponte
		Else
			cChar	:= "Z"	//Indica que eh apuracao com zeramento de receita/despesa
		EndIf
            
		//Armazena no array todas os registros da empresa / filial que esta sendo apurada - - protecao para nao causar error log chv unica
		aLstCW0 := {}
		If CW0->(MsSeek(xFilial("CW0")+"LP"+cEmpAnt+cFilAnt))	//FILIAL+TABELA+CHAVE
			While CW0->(!Eof()) .And. CW0->CW0_FILIAL == xFilial("CW0") .And.  AllTrim(CW0->CW0_TABELA) == "LP" .And. Subs(CW0->CW0_CHAVE,1,2) == cEmpAnt ;
				.And. Alltrim(Subs(CW0->CW0_CHAVE,3,Len(CW0->CW0_CHAVE))) == Alltrim(cFilAnt)
				aAdd(aLstCW0, { CW0->CW0_FILIAL, CW0->CW0_TABELA, CW0->CW0_CHAVE, CW0->CW0_DESC01 } )
				CW0->(dbSkip())
			End
		EndIf
			
		BEGIN TRANSACTION
		If CW0->(MsSeek(xFilial("CW0")+"LP"+cEmpAnt+cFilAnt))	//FILIAL+TABELA+CHAVE
			While CW0->(!Eof()) .And. CW0->CW0_FILIAL == xFilial("CW0") .And.  AllTrim(CW0->CW0_TABELA) == "LP" .And. Subs(CW0->CW0_CHAVE,1,2) == cEmpAnt ;
				.And. Alltrim(Subs(CW0->CW0_CHAVE,3,Len(CW0->CW0_CHAVE))) == Alltrim(cFilAnt)
				If Subs(&(cCampo),1,8) == DTOS(dDataLP) .And. Subs(&(cCampo),9,2) == cMoeda .And. ;
					Subs(&(cCampo),11,1) == cTpSald
					If Subs(&(cCampo),12,1) == " "
						RecLock("CW0",.F.)
						&(cCampo)	:= DTOS(dDataLP)+cMoeda+cTpSald+cChar
						MsUnlock()
					ElseIf Subs(&(cCampo),12,1) <> "" .And. Subs(&(cCampo),12,1) <> cChar
						//somente appenda o registro se nao encontrado na tabela CW0 - protecao para nao causar error log chv unica
						If aScan(aLstCW0,{|x| x[1]==xFilial("CW0") .And. x[2] == "LP" .And. x[3] == PadR(cEmpAnt+cFilAnt,Len(CW0->CW0_CHAVE)) .And. Alltrim(x[4]) == DTOS(dDataLP)+cMoeda+cTpSald+cChar } ) == 0
							RecLock("CW0",.T.)
							CW0->CW0_FILIAL 	:= xFilial("CW0")
							CW0->CW0_TABELA	:= 'LP'
							CW0->CW0_CHAVE	:= cEmpAnt+cFilAnt
							&(cCampo)		:= DTOS(dDataLP)+cMoeda+cTpSald+cChar
							MsUnlock()
						EndIf
					EndIf
				Endif
				CW0->(dbSkip())
			End
		EndIf
		END TRANSACTION
	(cAliasTRB)->(dbSkip())
	End
	(cAliasTRB)->(dbCloseArea())

EndIf

Restarea(aSaveArea)

Return lProcessado


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³CtLPCW0VdtºAutor  ³Alvaro Camillo Neto º Data ³  30/11/10   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Valida a data de apuração de resultado                     º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function CtLPCW0Vdt(dDataLP,lJaExec,lPergOk,cMoeda,cTpSaldo,lMoedaEsp,lAlertMsg)
Local cCampo :=  "CW0->CW0_DESC01"
Local lOk	 := .T.  
Local aArea  := GetArea()

Default dDataLP 	:= cToD("")
Default lJaExec		:= .T.
Default lPergOk		:= .T.
Default cMoeda		:= ""
Default cTpSaldo	:= ""
Default lMoedaEsp	:= .T.
Default lAlertMsg 	:= .T. 

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ ANTES DE INICIAR O PROCESSAMENTO, VERIFICO OS PARAMETROS.	 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
//Data de Apuracao nao preenchida.
If CtLPCW0Tab()	
	dbSelectArea("CW0")
	CW0->(dbSetOrder(1)) //CW0_FILIAL+CW0_TABELA+CW0_CHAVE

	If Empty(dDataLP)                              
		Help(" ",1,"NOCTBDTLP")
	
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Atualiza o log de processamento com o erro  ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		ProcLogAtu("ERRO","NOCTBDTLP",Ap5GetHelp("NOCTBDTLP"))
	
		lOk := .F.
	Else //Se a data estiver preenchida, verifica se ja foi rodado nessa data.
		If lAlertMsg
			If CW0->(MsSeek(xFilial("CW0")+"LP"+cEmpAnt+cFilAnt))
				While CW0->(!Eof()) .and. CW0->CW0_TABELA == "LP" .And. CW0->CW0_FILIAL == xFilial("CW0")   
					If Subs(&(cCampo),1,8) == Dtos(dDataLP) .And. AllTrim(CW0->CW0_CHAVE) == AllTrim(cEmpAnt+cFilAnt)
						If (!lMoedaEsp .Or. (lMoedaEsp .And. Subs(&(cCampo),9,2) == cMoeda)) .And.;
								Subs(&(cCampo),11,1) == cTpSaldo 
							If ! MsgYesNo(STR0002,OemToAnsi(STR0035))//"Rotina ja executada nessa data. Executa novamente ?"##"ATENCAO"
								lOk := .F.
							Else
								lJaExec := .T.
								Exit
							Endif
						EndIf
					Endif
					CW0->(dbSkip()) 
				End			
			EndIf
		EndIf
		//Verificar se o calendario da data solicitada esta encerrado
		lPergOk	:= CtbValiDt(1,dDataLP,,cTpSaldo)
	Endif
Else
	lRet := .F.
EndIf 

RestArea(aArea)                           
Return lOk


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³CtAtLPCW0 ºAutor  ³Microsiga           º Data ³  11/30/10   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Atualizo a tabela LP da CW0                                 º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function CtAtLPCW0(dDataLP,lMoedaEsp,cMoeda,nInicio,nFinal,cTpSaldo,lPontes)
Local aSaveArea	:= GetArea()
Local cChave	:= cEmpAnt+cFilant
Local lExiste	:= .F.
Local nContad
Local cChar		:= "" 
Local cCampo	:= "CW0->CW0_DESC01"
Local aLstCW0   := {}

If CtLPCW0Tab()

	If lPontes
		cChar	:= "P"
	Else
		cChar	:= "Z"
	EndIf
	
	dbSelectArea("CW0")
	CW0->(dbSetOrder(1)) //CW0_FILIAL+CW0_TABELA+CW0_CHAVE
	If CW0->(MsSeek(xFilial("CW0")+'LP'+cChave))
		//Armazena no array todas os registros da empresa / filial que esta sendo apurada - - protecao para nao causar error log chv unica
		aLstCW0 := {}
		If CW0->(MsSeek(xFilial("CW0")+"LP"+cEmpAnt+cFilAnt))	//FILIAL+TABELA+CHAVE
			While CW0->(!Eof()) .And. CW0->CW0_FILIAL == xFilial("CW0") .And.  AllTrim(CW0->CW0_TABELA) == "LP" .And. Subs(CW0->CW0_CHAVE,1,2) == cEmpAnt ;
				.And. Alltrim(Subs(CW0->CW0_CHAVE,3,Len(CW0->CW0_CHAVE))) == Alltrim(cFilAnt)
				aAdd(aLstCW0, { CW0->CW0_FILIAL, CW0->CW0_TABELA, CW0->CW0_CHAVE, CW0->CW0_DESC01 } )
				CW0->(dbSkip())
			End
		EndIf
	EndIf

	For nContad	:= nInicio to nFinal
		
		If CW0->(!MsSeek(xFilial("CW0")+'LP'+cChave))
			Reclock("CW0",.T.)
			CW0->CW0_FILIAL := xFilial("CW0")
			CW0->CW0_TABELA	:= 'LP'
			CW0->CW0_CHAVE	:= cChave
			&(cCampo)		:= Dtos(dDataLP)+StrZero(nContad,2)+cTpSaldo+cChar
			MsUnlock()
		Else
			While CW0->(!Eof()) .And. CW0->CW0_FILIAL == xFilial("CW0") .And. CW0->CW0_TABELA = 'LP' .And. ;
				Alltrim(Subs(CW0->CW0_CHAVE,1,Len(CW0->CW0_CHAVE))) == Alltrim(cChave)
				
		  	  	If Empty(StoD(CW0->CW0_DESC01,1,8))  
					Reclock("CW0")
					CW0->(dbDelete())	
					MsUnlock()	
					CW0->(dbSkip())			
				Endif    

				If Subs(&(cCampo),1,8) == Dtos(dDataLP)
					If lMoedaEsp .And. (Subs(&(cCampo),9,2) == cMoeda) .And. Subs(&(cCampo),11,1) = cTpSaldo .And. Subs(&(cCampo),12,1) == cChar
						lExiste	:= .T.
					ElseIf !lMoedaEsp .And. (Subs(&(cCampo),9,2) == StrZero(nContad,2)).And. Subs(&(cCampo),11,1) = cTpSaldo  .And. Subs(&(cCampo),12,1) == cChar
						lExiste	:= .T.
					EndIf
				EndIf
				
				If !lExiste
					//somente appenda o registro se nao encontrado na tabela CW0 - protecao para nao causar error log chv unica
					If aScan(aLstCW0,{|x| x[1]==xFilial("CW0") .And. x[2] == "LP" .And. x[3] == PadR(cChave,Len(CW0->CW0_CHAVE)) .And. Alltrim(x[4]) == If(lMoedaEsp,Dtos(dDataLP)+cMoeda+cTpSaldo+cChar,Dtos(dDataLP)+StrZero(nContad,2)+cTpSaldo+cChar) } ) == 0
						Reclock("CW0",.T.)
						CW0->CW0_FILIAL := xFilial("CW0")
						CW0->CW0_TABELA	:= 'LP'
						CW0->CW0_CHAVE	:= cChave
						If lMoedaEsp
							&(cCampo)	:= Dtos(dDataLP)+cMoeda+cTpSaldo+cChar
						Else
							&(cCampo)	:= Dtos(dDataLP)+StrZero(nContad,2)+cTpSaldo+cChar
						EndIf
						MsUnlock()
					EndIf
				EndIf
				CW0->(dbSkip())
			End
		EndIf
	Next
EndIf

RestArea(aSaveArea)
Return


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³CtMaxLPCW0  ³Alvaro Camillo Neto º Data ³  30/11/10   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Retorna qual eh a ultima data de zeramento SEM conta ponte. º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function CtMaxLPCW0()
Local aSaveArea	:= GetArea()
Local dMaxData	:= CTOD("  /  /  ")                                      
Local cCampo	:= "CW0->CW0_DESC01"

If CtLPCW0Tab()
	dbSelectArea("CW0")
	CW0->(dbSetOrder(1)) //CW0_FILIAL+CW0_TABELA+CW0_CHAVE
	If CW0->(MsSeek(xFilial("CW0")+"LP"+cEmpAnt+cFilAnt,.F.))
		While CW0->(!Eof()) .And. CW0->CW0_FILIAL == xFilial() .And. Subs(CW0->CW0_CHAVE,1,2) == cEmpAnt .And. ;
			Alltrim(Subs(CW0->CW0_CHAVE,3,Len(CW0->CW0_CHAVE))) == Alltrim(cFilAnt) 
			
			If Subs(&(cCampo),12,1) == "Z"
				dMaxData	:= STOD(Subs(&(cCampo),1,8))
			EndIf
					
			CW0->(dbSkip())
		End
	EndIf
	RestArea(aSaveArea)
	aSize(aSaveArea,0)
	asaveArea := nil 
EndIf
	
Return(dMaxData)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³CtMosLPCW0  ³Alvaro Camillo Neto º Data ³  30/11/10   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Valida se a tabela existe e mostra a consulta da tabela    º±±
±±º          ³ CTZ                                                        º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function CtMosLPCW0()
Local a
Local b
Local c
Local aAreaOri := GetArea()
Local aAreaCW0  := CW0->(GetArea())

// Caso a tabela LP exista na tabela CW0 o processo será feito por ela e nao pela SX5
If CtLPCW0Tab()
	dbSelectArea("CW0")
	CW0->(dbSetOrder(1)) //CW0_FILIAL+CW0_TABELA+CW0_CHAVE
	If CW0->(!MsSeek(xFilial("SX5")+"LP",.F.))
		MsgInfo("Não existem apurações registradas.","Tabela LP - Apurações de resultado")//"Não existem apurações registradas."//"Tabela LP - Apurações de resultado"
	Else
		ConPad1(a,b,c,"CTZ",,,.F.)
	EndIf 
EndIf

RestArea(aAreaCW0)
RestArea(aAreaOri)

Return  


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³CtExcLPCW0  ³Alvaro Camillo Neto º Data ³  30/11/10   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Atualizo a tabela LP do CW0                                  º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function CtExcLPCW0(dDataLP,lMoedaEsp,cMoeda,nInicio,nFinal,cTpSald,lEApCtPon)
Local aSaveArea := GetArea()
Local cChave    := cEmpAnt + cFilant
Local cFilProc  := ""

Default lEApCtPon := .F. 

If CtLPCW0Tab()
	dbSelectArea("CW0")
	CW0->(dbSetOrder(1)) //CW0_FILIAL+CW0_TABELA+CW0_CHAVE

	If CW0->(MsSeek(xFilial("CW0")+'LP'+cChave))
   		cFilProc := Subs(CW0->CW0_CHAVE,3,Len(CW0->CW0_CHAVE))

		While CW0->(!Eof()) .And.	CW0->CW0_FILIAL == xFilial("CW0") .And.;
			Subs(CW0->CW0_TABELA,1,2) == "LP" .And.  ;
			Subs(CW0->CW0_CHAVE,1,2) == cEmpAnt .And. ;
			AllTrim(xFilial("CT2",cFilProc)) == AllTrim(xFilial("CT2",cFilAnt)) .And. ;
			AllTrim( Subs(CW0->CW0_CHAVE,3,Len(CW0->CW0_CHAVE)) ) == AllTrim( cFilAnt )

			If Subs(CW0->CW0_DESC01,1,8) <> Dtos(dDataLP)
				CW0->(dbSkip())
				Loop
			Endif

			If Subs(CW0->CW0_DESC01,11,1) <> cTpSald 
				CW0->(dbSkip())
				Loop
			EndIf	
			
			If Subs(CW0->CW0_DESC01,12,1) == 'P' .And. !lEApCtPon 
				CW0->(dbSkip())
				Loop
			EndIf		

			If 	(lMoedaEsp .And. (Subs(CW0->CW0_DESC01,9,2) <> StrZero(nInicio,2))) .Or. ;		
				(!lMoedaEsp .And. (Subs(CW0->CW0_DESC01,9,2) < StrZero(nInicio,2) .Or. ;		
				Subs(CW0->CW0_DESC01,9,2) > StrZero(nFinal,2))) 
				CW0->(dbSkip())
				Loop
			EndIf

			Reclock("CW0",.F.,.T.)
			CW0->( dbDelete() )
			CW0->( MsUnlock() )
			CW0->(dbSkip())
		EndDo
	EndIf
EndIf

RestArea(aSaveArea)
aSize(aSaveArea,0)
asaveArea := nil 
Return Nil

/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³CtDtExcLPCW0ºAutor  ³Alvaro Camillo Neto º Data ³  30/11/10   º±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Verifica se a data solicitada eh ref. o ult. zeramento      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³				                                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³                                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function CtDtExcLPCW0(dDataLp,cTpSald,lMoedaEsp,cMoeda,lExisZ)

Local aSaveArea	:= GetArea()
Local lRet		:= .T.
Local cDataLP	:= DTOS(dDataLp)
Local lSaiW		:= .F.
Local cEmpFil	:= cEmpAnt+cFilAnt
Local cFilCW0	:= ""
Default lExisZ := .F.

If CtLPCW0Tab()

	dbSelectArea("CW0")

	CW0->(dbSetOrder(1)) //CW0_FILIAL+CW0_TABELA+CW0_CHAVE        
	cFilCW0	:= xFilial("CW0")
	
	CW0->(dbSeek(xFilial("CW0")+"LP"+cEmpAnt+Soma1(cFilAnt),.T.))
	CW0->(dbSkip(-1))

	While !lSaiW .AND. CW0->CW0_FILIAL == cFilCW0 .and. ALLTRIM(CW0->CW0_TABELA) == "LP" .and. ALLTRIM(CW0->CW0_CHAVE) == ALLTRIM(cEmpFil)
	
		If lExisZ

			lRet:= .F.		
			If SubStr(CW0->CW0_DESC01,12,1) == "Z"  
				lRet:= .T. 
				Exit
			EndIf 

		ElseIf cTpSald == SubStr(CW0->CW0_DESC01,11,1)	/// TIPO DE SALDO DEVE SER VERIFICADO INDEPENDENTE DA MOEDA
			
			lMoedaChk := .T.
			/// SE FOR APURACAO DE MOEDA ESPECIFICA
			If lMoedaEsp .and. cMoeda <> SubStr(CW0->CW0_DESC01,9,2)
				lMoedaChk := .F.
			Endif
		
			If lMoedaChk	/// SE FOR A MESMA MOEDA / OU PROCESSAMENTO DE TODAS AS MOEDAS
				lSaiW := .T.
				Exit		/// FORÇA SAIDA PRA NAO DESPOSICIONAR O CW0 (VAI PEGAR A DATA)
			EndIf

		EndIf

		CW0->(dbSkip(-1))

	EndDo
	
	If lSaiW .AND. CW0->CW0_FILIAL == cFilCW0 .and. ALLTRIM(CW0->CW0_TABELA) == "LP" .and. ALLTRIM(CW0->CW0_CHAVE) == ALLTRIM(cEmpFil) .And. !lExisZ
	
		If cDataLP < Substr(CW0->CW0_DESC01,1,8)
			/// SE NÃO FOR A ÚLTIMA DATA DE APURAÇÃO NA EMPRESA E FILIAL
			lRet	:= .F.
			MsgInfo("Verifique se a data solicitada refere-se ao ultimo zeramento efetuado...","Data: "+DTOC(dDataLP)+" Moeda: "+If(lMoedaEsp,cMoeda,SUBSTR(CW0->CW0_DESC01,9,2))+" Tp.Saldo: "+cTPSald)
		EndIf

	EndIf	
	
EndIf                                                                                                                   

RestArea(aSaveArea)/// ATENÇÃO ! MANTER SX5 POSICIONADO NO RETORNO Ct215LPAnt( OBTEM DATA ANTERIOR E IRA DESPOSICIONAR )

Return(lRet)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³CtLPAntCW0ºAutor  ³Alvaro Camillo Neto º Data ³  30/11/10   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Retorna a ultima data de apuração de resultado antes da    º±±
±±º          ³ indicada                                                   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function CtLPAntCW0(dDataLp,cTpSald,lMoedaEsp,cMoeda)
Local dDTLPAnt := CTOD('  /  /  ')
Local cEmpFil	:= cEmpAnt+cFilAnt
Local cDataLP  := DTOS(dDataLp)
Local cFilCW0  := ""
Local lMoedaChk:= .T.

If CtLPCW0Tab()
	dbSelectArea("CW0") 
	cFilCW0 := xFilial("CW0")
	
	If !Eof() .AND. CW0->CW0_FILIAL == cFilCW0 .and. ALLTRIM(CW0->CW0_TABELA) == "LP" .and.;
		ALLTRIM(CW0->CW0_CHAVE) == ALLTRIM(cEmpFil) .and. cDataLP == Substr(CW0->CW0_DESC01,1,8)
		/// SE JA ESTIVER POSICIONADO NA ÚLTIMA DATA NAO PRECISA PESQUISAR	
	Else
		/// SE NÃO ESTIVER POSICIONADO LOCALIZA A ÚLTIMA DATA PARA USAR A MESMA LOGICA
		dbSelectArea("CW0")
		dbSetOrder(1)
		dbSeek(cFilCW0+"LP"+cEmpAnt+Soma1(cFilAnt),.T.)
		dbSkip(-1)
		dDataLP := STOD(Substr(CW0->CW0_DESC01,1,8))
	EndIf
	
	CW0->(dbSkip(-1))
	While CW0->CW0_FILIAL == cFilCW0 .and. ALLTRIM(CW0->CW0_TABELA) == "LP" .and. ALLTRIM(CW0->CW0_CHAVE) == ALLTRIM(cEmpFil)
		If cTpSald == SubStr(CW0->CW0_DESC01,11,1)	/// TIPO DE SALDO DEVE SER VERIFICADO INDEPENDENTE DA MOEDA
			lMoedaChk := .T.
			/// SE FOR APURACAO DE MOEDA ESPECIFICA
			If lMoedaEsp .and. cMoeda <> SubStr(CW0->CW0_DESC01,9,2)
				lMoedaChk := .F.	
			Endif
			If lMoedaChk	/// SE FOR A MESMA MOEDA / OU PROCESSAMENTO DE TODAS AS MOEDAS
				If Substr(CW0->CW0_DESC01,1,8) < cDataLP
					/// SE A DATA DE APURACAO FOR MENOR QUE A DATA FINAL DE APURACAO
					/// OBTEM A DATA DA APURACAO ANTERIOR
					dDTLPAnt := STOD(Substr(CW0->CW0_DESC01,1,8))
					Exit
				EndIf	
			EndIf
		EndIf
		CW0->(dbSkip(-1))
	EndDo
EndIf

Return(dDTLPAnt)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³CtLPCW0TabºAutor  ³Alvaro Camillo Neto º Data ³  30/11/10   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Valida a existencia da tabela CW0 LP no ambiente           º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function CtLPCW0Tab()
Local aArea := {}

If __lCW0LP == Nil
	aArea 	 := GetArea()

	dbSelectArea("CW0")
	CW0->(dbSetOrder(1)) //CW0_FILIAL+CW0_TABELA+CW0_CHAVE
	If CW0->(MsSeek(xFilial("CW0") + "00" + "LP" )) .And. TamSx3("CW0_CHAVE")[1] >= 15
		__lCW0LP := .T.
	EndIf

	RestArea(aArea)

EndIf          

Return __lCW0LP


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³CW0LPLoad ºAutor  ³Alvaro Camillo Neto º Data ³  30/11/10   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Faz a carga das informações da tabela LP da CW0 a partir   º±±
±±º          ³ da tabela LP da SX5                                        º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function CW0LPLoad()
Local aArea := GetArea()

dbSelectArea("CW0")
CW0->(dbSetOrder(1)) //CW0_FILIAL+CW0_TABELA+CW0_CHAVE
dbSelectArea("SX5") 
SX5->(dbSetOrder(1)) //X5_FILIAL+X5_TABELA+X5_CHAVE

If CW0->(!MsSeek(xFilial("CW0") + "LP" ))
	If SX5->(MsSeek(xFilial("SX5") + "LP"))
		While SX5->(!EOF()) .And. Alltrim(SX5->(X5_FILIAL+X5_TABELA)) == Alltrim(xFilial("SX5") + "LP")
			If CW0->(!MsSeek(xFilial("CW0") + "LP" + SX5->X5_CHAVE )) 
				Reclock("CW0",.T.)
				CW0->CW0_FILIAL := xFilial("CW0")
				CW0->CW0_TABELA	:= 'LP'
				CW0->CW0_CHAVE	:= SX5->X5_CHAVE
				CW0->CW0_DESC01 := SX5->X5_DESCRI
				MsUnlock()
			EndIf 			
			SX5->(dbSkip())
		EndDo
	EndIf
EndIf    
 
RestArea(aArea)
Return

/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³CW0SXBDtLP³ Autor ³ Alvaro Camillo Neto   ³ Data ³ 16.08.11 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Retorna a data formatada para o SX3 =>da Tabela LP do CW0   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³CtbSXBDtLP()                                                ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function CW0SxbDtLP()

Return(DTOC(STOD(Subs(CW0->CW0_DESC01,1,8))))
/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³CW0SXBMoed³ Autor ³ Alvaro Camillo Neto   ³ Data ³ 16.08.11 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Retorna a moeda 											  |±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³CtbSXBMoed()                                                ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function CW0SxbMoed()

Return((Subs(CW0->CW0_DESC01,9,2)))

/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³CtbSXBTpSl³ Autor ³ Alvaro Camillo Neto   ³ Data ³ 16.08.11 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Retorna a moeda 											  |±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³CtbSXBTpSl()                                                ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function CW0SxbTpSl()

Return((Subs(CW0->CW0_DESC01,11,1)))

/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³CtbRetSZ ³ Autor ³ Alvaro Camillo Neto   ³ Data ³ 16.08.11 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Retorna a data  											  |±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³CtbRetSZ()                                                  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function CW0RetSZ()

Return(STOD(Subs(CW0->CW0_DESC01,1,8)))


/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³CtbFltSZ³ Autor ³ Alvaro Camillo Neto   ³ Data ³ 16.08.11 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Retorna a data  											  |±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³CtbRetSZ()                                                  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function CW0FltSZ()
Local cFiltro	:= ""
Local nTamCW0   := TamSX3("CW0_CHAVE")[1]
Local cEmpLP	:= Subs(CW0->CW0_CHAVE,1,2)
Local cFilLP	:= SUBS(CW0->CW0_CHAVE,3, nTamCW0)

cFiltro	:= Alltrim(CW0->CW0_TABELA) == 'LP' .And. cEmpLP = cEmpAnt .And. Alltrim(xFilial("CT2",cFilLP)) == Alltrim(xFilial("CT2",cFilAnt))

Return(cFiltro)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³CW0LPSXB ºAutor  ³ Alvaro Camillo Netoº Data ³  16/08/11   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Consulta padrao de LP                                      º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function CW0LPSXB()

Local lRet		:= .T.
Local cSXB		:= ""

__dDataLP := STOD("")

If CtLPCW0Tab()
	cSXB := "CW0LP"
Else
	cSXB := "SX5LP" 
EndIf

lRet	:= ConPad1( , , ,cSXB, /*cCampoRet*/,/*lGet*/,.F./*lOnlyView*/,/*cVar*/,/*oGet*/, /*uContent*/)

If CtLPCW0Tab()
	__dDataLP := CW0RETSZ() 
Else
	__dDataLP := CTBRETSZ() 
EndIf


Return lRet


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³CW0RETLP  ºAutor  ³Alvaro Camillo Neto º Data ³  16/08/11   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Retorna a data do LP                                        º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function CW0RETLP()  
Return __dDataLP 


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³CtbxSPNvl ºAutor  ³Alvaro Camillo Neto º Data ³  01/02/12   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Retorna o conteudo do campo da conta síntética de primeiro º±±
±±º          ³nível ( Exemplo 1: Ativo)                                   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function CtbxSPNvl(cConta,cCampo,xDefault)
Local aArea 	:= GetArea()
Local aAreaCT1  := GetArea()
Local cConteud
Local cContaPNvl := ""

Default xDefault := ""

cConteud := xDefault

CT1->(dbSetOrder(1)) //CT1_FILIAL+CT1_CONTA

cContaPNvl := GetCT1SPNn(cConta)

If CT1->(MsSeek(xFilial("CT1") + cContaPNvl)) .And. CT1->(FieldPos(cCampo)) > 0
	cConteud:= CT1->(&(cCampo)) 
EndIf

RestArea(aAreaCT1)
RestArea(aArea)
Return cConteud


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³GetCT1SPNnºAutor  ³Alvaro Camillo Neto º Data ³  01/02/12   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Retorna a conta sintética de primeiro nível                 º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ CtbxSPNvl                                                  º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function GetCT1SPNn(cConta)
Local cContaPNvl := cConta

CT1->(dbSetOrder(1)) //CT1_FILIAL+CT1_CONTA

If CT1->(MsSeek(xFilial("CT1") + cConta))
	If Empty(CT1->CT1_CTASUP)
   		cContaPNvl := cConta
	Else // Faz recursividade até encontrar a conta que não possui superiora.
		cContaPNvl := GetCT1SPNn(CT1->CT1_CTASUP) 
	EndIf
EndIf

Return cContaPNvl  

/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ CtbLegenda ³ Autor ³ Wagner Mobile Costa ³ Data ³ 13.03.02 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Funcao utilizada para criacao de Legenda SigaCtb           ³±±
±±³          ³ Retorna a legenda para o Browse/Cria caixa da legenda      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ SigaCtb                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function CtbLegenda(cAlias, nReg)
                        
Local aLegenda 	:= {}
Local uRetorno 	:= .T.
Local lX3STATSL	:= CV2->(FieldPos("CV2_STATSL") > 0)
LOcal cDescri := ""

if Type("lX3Aprova") == "U"
	lX3Aprova := If(GetNewPar("MV_ORCAPRV","S") == "S",.T.,.F.)
Endif  

If nReg = Nil	// Chamada direta da funcao onde nao passa, via menu Recno eh passado
	uRetorno := {}
	If cAlias = "CT2"
		If CTBLCUso()
			Aadd(uRetorno, { "Substr(CT2->CT2_ROTINA,1,9) = '__CTBLC__'","f7_amar", STR0036} )    //"Lançamento complementar"
		Endif

		SX5->(DbSeek(xFilial("SX5") + "SL"))
		While SX5->X5_TABELA = "SL" .And. ! SX5->(Eof())
			If Left(SX5->X5_CHAVE, 1) = D_PRELAN 
				cDescri := X5Descri()
			else
				cDescri := STR0037 + X5Descri()  //"Lancamento "
			endif
			Aadd(uRetorno, { 'CT2_TPSALD = "' + Left(SX5->X5_CHAVE, 1) + '"',;
							  CtbLegRes(Left(SX5->X5_CHAVE, 1)),;		  
							   cDescri} ) 

			SX5->(DbSkip())
		EndDo
	ElseIf cAlias = "CV1"
		Aadd(uRetorno, { 'CV1_STATUS = "3"', "f5_cinz" })
		If lAprova = Nil						
			lAprova := 		(SX3->(DbSetOrder(2)), SX3->(DbSeek("CV1_APROVA")),;
		 					 SX3->(DbSetOrder(1)), X3Uso(SX3->X3_USADO))
		Endif
		If lAprova
			Aadd(uRetorno, { 'CV1_APROVA = " "', "f5_verm" })
			Aadd(uRetorno, { 'Ctb390Leg("1")', "f5_amar" })
		Else
			Aadd(uRetorno, { 'Ctb390Leg("2")', "f5_verm" })
		Endif
		Aadd(uRetorno, { 'Ctb390Leg("3")', "f5_azul" })
		Aadd(uRetorno, { 'Ctb390Leg("4")', "f5_verd" })
	ElseIf cAlias == "CV2"
		If lX3Aprova
			If lX3STATSL
				Aadd(uRetorno, { 'CV2->CV2_APROVA = " " .AND. CV2->CV2_STATUS = "1" .AND. CV2->CV2_STATSL <> "1"' 	, "f5_verm", STR0065 })	/// NÃO APROVADO E S/ SALDO
				Aadd(uRetorno, { 'CV2->CV2_APROVA <> " " .AND. CV2->CV2_STATUS = "1" .AND. CV2->CV2_STATSL <> "1"'	, "f5_amar", STR0066 })	/// APROVA  E S/ SALDO
			Else
				Aadd(uRetorno, { 'CV2->CV2_APROVA = " " .AND. CV2->CV2_STATUS = "1"'	, "f5_verm", STR0065 })	/// NÃO APROVADO E S/ SALDO
				Aadd(uRetorno, { 'CV2->CV2_APROVA <> " " .AND. CV2->CV2_STATUS = "1"'	, "f5_amar", STR0066 })	/// APROVA  E S/ SALDO
			EndIf
		Else
			If lX3STATSL
				Aadd(uRetorno, { 'CV2->CV2_STATUS = "1" .AND. CV2->CV2_STATSL <> "1"'	, "f5_verm", STR0067 })	/// S/ SALDO (não há aprovação)
			Else
				Aadd(uRetorno, { 'CV2->CV2_STATUS = "1" ', "f5_verm", STR0067 })	/// S/ SALDO (não há aprovação)			
			EndIf
		Endif
		Aadd(uRetorno, { 'CV2->CV2_STATUS = "3"'								, "f5_cinz", STR0068 })		/// ORCAMENTO REVISADO
		Aadd(uRetorno, { 'CV2->CV2_STATUS = "2"'								, "f5_verd", STR0069 })		/// APROVADO GER.SALDO TOTAL
		If lX3STATSL
			Aadd(uRetorno, { 'CV2->CV2_STATUS = "1" .AND. CV2->CV2_STATSL = "1"', "f5_azul", STR0070 })		/// APROVADO GER.SALDO PARCIAL			
		Else
			Aadd(uRetorno, { 'Ctb390Lg2("2")'									, "f5_azul", STR0070 })		/// APROVADO GER.SALDO PARCIAL
		EndIf
	ElseIf cAlias = "CTC"
		SX5->(DbSeek(xFilial("SX5") + "SL"))
		While SX5->X5_TABELA = "SL" .And. ! SX5->(Eof())
			If Left(SX5->X5_CHAVE, 1) = D_PRELAN 
				cDescri := X5Descri()
			else
				cDescri := STR0037 + X5Descri()     //"Lancamento "
			endif
			Aadd(uRetorno, { 'CTC_TPSALD = "' + Left(SX5->X5_CHAVE, 1) + '"',;
							  CtbLegRes(Left(SX5->X5_CHAVE, 1)) , cDescri } ) 
			SX5->(DbSkip())
		EndDo
	Endif							// Inclui outros tratamento aqui
Else
	If cAlias = "CT2"
		SX5->(DbSeek(xFilial("SX5") + "SL"))
		While SX5->X5_TABELA = "SL" .And. ! SX5->(Eof())
			If Left(SX5->X5_CHAVE, 1) = D_PRELAN
				Aadd(aLegenda, { CtbLegRes(Left(SX5->X5_CHAVE, 1)), X5Descri() })
			Else
				Aadd(aLegenda, { CtbLegRes(Left(SX5->X5_CHAVE, 1)), STR0037 +  X5Descri() }) //"Lancamento "
			Endif
			SX5->(DbSkip())
		EndDo
		If CTBLCUso()
			Aadd(aLegenda, {"f7_amar",STR0036} ) //"Lançamento complementar"
		Endif
	ElseIf cAlias = "CV1"
		If lAprova
			aLegenda := { 	{ "f5_verm", "Orcamento nao aprovado" },;
							{ "f5_amar", "Orcamento aprovado sem saldo contabil" } }
		Else
			aLegenda := { 	{ "f5_verm", "Orcamento em aberto" } }
		Endif
		Aadd(aLegenda, { "f5_azul", "Saldo Contabil gerado parcialmente" })
		Aadd(aLegenda, { "f5_verd", "Saldo Contabil gerado total" })
		Aadd(aLegenda, { "f5_cinz", "Orcamento revisado" })
	ElseIf cAlias = "CV2"
		aLegenda := {}
		If lX3Aprova
			Aadd(aLegenda, { "f5_verm", "Orcamento nao aprovado" })
			Aadd(aLegenda, { "f5_amar" , "Orcamento aprovado sem saldo contabil" })
		Else
			Aadd(aLegenda, { "f5_verm", "Orcamento sem saldo gerado" })
		Endif
		Aadd(aLegenda, { "f5_azul"	  , "Saldo Contabil gerado parcialmente" })
		Aadd(aLegenda, { "f5_verd"   , "Saldo Contabil gerado total" })
		Aadd(aLegenda, { "f5_cinz"   , "Orcamento revisado" })
		///Aadd(aLegenda, { "BR_PRETO"   , " " })
	ElseIf cAlias = "CTC"
		SX5->(DbSeek(xFilial("SX5") + "SL"))
		While SX5->X5_TABELA = "SL" .And. ! SX5->(Eof())
			If Left(SX5->X5_CHAVE, 1) = D_PRELAN
				Aadd(aLegenda, { CtbLegRes(Left(SX5->X5_CHAVE, 1)), X5Descri() })
			Else
				Aadd(aLegenda, { CtbLegRes(Left(SX5->X5_CHAVE, 1)), STR0037 +  X5Descri() }) //"Lancamento "
			Endif
			SX5->(DbSkip())
		EndDo
	Endif				           			// Inclui outros tratamento aqui
	
	BrwLegenda(cCadastro, STR0038, aLegenda) //"Legenda"
Endif

Return uRetorno

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Program   ³ CtbLegRes  ³ Autor ³ Wagner Mobile Costa ³ Data ³ 13.02.02 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Retorna o resource a ser utilizado na legenda              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³CtbLegRes()                                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ lPar1 = Indica se eh ou nao um saldo interno               ³±±
±±³          ³ lPar2 = Indica se apresenta ou nao mensagem                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³SigaCtb                                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpC1 = Codigo do saldo sendo verificado                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function CtbLegRes(cSaldo)

Local cResource := ""
Local aArea 	:= GetArea()
Local aAreaSx5 	:= SX5->(GetArea())
Local aLegenda 	:= { "f5_null", "f5_verd", "f5_amar", "f5_azul", "f5_marr", "f5_verm", "f7_null" }

If SX5->(DbSeek(xFilial() + "SM" + cSaldo))
	cResource := AllTrim(SX5->X5_DESCRI)
Endif

If Empty(cResource) .And. Ctb130SldInt(cSaldo, .F.)
	If cSaldo < "5"
		cResource := aLegenda[Val(cSaldo) + 1]
	ElseIf cSaldo = D_PRELAN
		cResource := aLegenda[Len(aLegenda)]
	Endif
Endif

SX5->(RestArea(aAreaSx5))
RestArea(aArea)

Return cResource

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³Ctb390Leg ³ Autor ³ Wagner Mobile Costa   ³ Data ³ 06.11.02 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Rotina de retorno para amentaria                           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Ctba390                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function Ctb390Leg(cTpLegenda)

Local nRecno, nIndex := CV1->(IndexOrd())
Local nAprvSSld := nAberto := nTotal := nLidos := 0, lRet := .F.

Static cSeqMostra

If cSeqMostra = Nil
	cSeqMostra := StrZero(1,TamSx3("CV1_SEQUEN")[1])
Endif

M->CV1_ORCMTO	:= CV1->CV1_ORCMTO
M->CV1_CALEND	:= CV1->CV1_CALEND
M->CV1_MOEDA	:= CV1->CV1_MOEDA
M->CV1_REVISA	:= CV1->CV1_REVISA
nRecno := CV1->(Recno())
CV1->(DbSetOrder(1))
CV1->(DbGoto(nRecno))

While CV1->CV1_FILIAL+CV1->CV1_ORCMTO+CV1->CV1_CALEND+CV1->CV1_MOEDA+CV1->CV1_REVISA=;
	  xFilial("CV1")+M->CV1_ORCMTO+M->CV1_CALEND+M->CV1_MOEDA+M->CV1_REVISA .And.;
	  ! CV1->(Eof())
	If lAprova .And. ! Empty(CV1->CV1_APROVA) .And. CV1->CV1_STATUS = "1"
		nAprvSSld ++
	ElseIf CV1->CV1_STATUS = "1"
		nAberto ++
	ElseIf CV1->CV1_STATUS = "2"
		nTotal ++
	Endif
	nLidos ++
	CV1->(DbSkip())
EndDo

CV1->(DbSetOrder(nIndex))
CV1->(DbGoto(nRecno))

If cTpLegenda = "1" .And. nAprvSSld = nLidos
	lRet := .T.
ElseIf cTpLegenda = "2" .And. nAberto = nLidos
	lRet := .T.
ElseIf cTpLegenda = "3" .And. nAberto > 0 .And. nTotal > 0
	lRet := .T.
ElseIf cTpLegenda = "4" .And. nTotal = nLidos
	lRet := .T.
Endif

Return lRet

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³Ctb390Lg2 ³ Autor ³ Marcos S. Lobo        ³ Data ³ 16.07.03 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Rotina de retorno para legenda da rotina de orçamentos CTB ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Ctba390                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function Ctb390Lg2(cTpLegenda)
       
Local lRet	  := .F.
Local nIndCV1 := CV1->(IndexOrd())
Local nRecCV1 := CV1->(Recno())
Local nLidos  := nGerados := 0
Local cFilCV2 := xFilial("CV2")

DEFAULT cTPLegenda	:= "1" ///Testar Condição 1= Saldo Totalmente Gerado / 2= Saldo Parcialmente Gerado

Public M->CV2_FILIAL	:= CV2->CV2_FILIAL
Public M->CV2_ORCMTO	:= CV2->CV2_ORCMTO
Public M->CV2_CALEND	:= CV2->CV2_CALEND
Public M->CV2_MOEDA		:= CV2->CV2_MOEDA
Public M->CV2_REVISA	:= CV2->CV2_REVISA
 
dbSelectArea("CV1")
dbSetOrder(1)
If MsSeek(cFilCV2+CV2->(CV2_ORCMTO+CV2_CALEND+CV2_MOEDA+CV2_REVISA))
	While !CV1->(Eof()) .and. cFilCV2+CV2->(CV2_ORCMTO+CV2_CALEND+CV2_MOEDA+CV2_REVISA) == CV1->(CV1_FILIAL+CV1_ORCMTO+CV1_CALEND+CV1_MOEDA+CV1_REVISA)
		nLidos += 1
		If CV1->CV1_STATUS == "2"
			nGerados += 1
		Endif
		CV1->(dbSkip())
	Enddo
Endif

if Type("lX3Aprova") == "U"
	lX3Aprova := If(GetNewPar("MV_ORCAPRV","S") == "S",.T.,.F.)
Endif  

CV1->(dbSetOrder(nIndCV1))
CV1->(dbGoTo(nRecCV1))

DO CASE
CASE cTpLegenda = "1"	/// CONDIÇÃO PARA SALDO CONTABIL GERADO TOTAL
	If Iif(lX3Aprova,!Empty(CV2->CV2_APROVA),.T.) .and. nLidos == nGerados 
		lRet := .T.		/// SE ESTIVER APROVADO E A QUANTIDADE DE REGISTROS (DETALHE) LIDOS = A QUANTIDADE DE GERADOS
	Endif
CASE cTpLegenda = "2" /// CONDIÇÃO PARA SALDO CONTABIL GERADO PARCIALMENTE
	If Iif(lX3Aprova,!Empty(CV2->CV2_APROVA),.T.) .and. nLidos <> nGerados 
		lRet := .T.	/// SE ESTIVER APROVADO E A QUANTIDADE DE REGISTROS (DETALHE) LIDOS <> A QUANTIDADE DE GERADOS
	Endif
OTHERWISE
	lRet := .T.
ENDCASE
      
Return lRet

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³CTBINTRAN ³ Autor ³ Totvs                 ³ Data ³ 23.10.08 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Indica se a contabilizacao pode ser executada dentro de    ³±±
±±³          ³ uma transacao                                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Ctbxmix                                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpN1 = 0 para testar se pode ou nao executar em uma       ³±±
±±³          ³         transacao sem mensagens;                           ³±±
±±³          ³       = 1 para verificar retornando as razoes pelas quais a³±±
±±³          ³         contabilizacao nao pode ser executada na transacao ³±±
±±³          ³ ExpL1 = se ira ira mostrar o lancamento                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function CtbInTran( nModo, lMostraLCTO )
	Local lRet		:= .T.
	Local cMensagem	:= ""
	
	DEFAULT lMostraLCTO := .T.
	
	If lMostraLCTO
	      lRet		:= .F.
	      cMensagem += IIf( nModo == 1, STR0039, "" ) + CRLF    //"Opção Mostra Lctos. Contáb. habilitada"
	EndIf
	
	If cPaisLoc <> "RUS" .And. SuperGetMV( "MV_ALTLCTO" ) == "S"
	      lRet 		:= .F.     
	      cMensagem += IIf(nModo == 1, STR0040, "" ) + CRLF  //"Parâmetro MV_ALTLCTO habilitado"
	EndIf
	
	If cPaisLoc <> "RUS" .Or. !FWIsInCallStack('AF012EXCLT')

		If SuperGetMV( "MV_PRELAN", .F., "N" ) == "N"
			lRet 		:= .F.                                                                                        
			cMensagem += IIf(nModo == 1, STR0041, "" ) + CRLF  //"Parãmetro MV_PRELAN desabilitado"
	    EndIf
	Endif
	
	If SuperGetMV( "MV_CT105MS", .F., "S" ) == "S"
	      lRet 		:= .F.
	      cMensagem += IIf(nModo == 1, STR0042, "" ) + CRLF  //"Parâmetro MV_CT105MS habilitado"
	EndIf
	
	If !lRet .AND. nModo == 1
	      Help( " ", 1, "HELP",, STR0043 + CRLF + cMensagem, 1, 0 )  //"A contabilização não pode ser executada "
	EndIf
Return lRet
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³CTBXFUNA  ºAutor  ³Marcos S. Lobo      º Data ³  04/20/07   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Efetua verificação e retorna se a integridade referencial   º±±
±±º          ³esta em uso                                                 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP-Rotinas com chamada de Stored Procedures                º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function FkInUse(cEmpAtu)
Local aArea
Local lFKemuso 		:= .F.
Local cEmpDefault 	:= IIF(FindFunction("FWGRPCompany"), FWGRPCompany(),SM0->M0_CODIGO)  

DEFAULT cEmpAtu 	:= cEmpDefault     
aArea	:= GetArea()
		
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Verifica se a integridade referencial está ativa                          ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
cQuery := "SELECT count(PARAM_NAME) TOTAL FROM TOP_PARAM WHERE PARAM_NAME = 'FKINUSE" + cEmpAtu + "'"
		
If Select("INTEGR") > 0
	dbSelectArea("INTEGR")
	dbCloseArea()
EndIf
		
dbUseArea(.T., "TOPCONN", TCGenQry(,,cQuery), 'INTEGR', .F., .T.)
dbSelectArea("INTEGR")
lFKemuso := If( INTEGR->TOTAL > 0, .T., .F.)
dbCloseArea()
RestArea(aArea)		

Return(lFKemuso)

/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³CTBExpCSV ³ Autor ³ Marcelo Akama         ³ Data ³ 12/08/09 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Exportacao de tabelas para arquivo .CSV                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³CTBExpCSV(lEnd, oProcess, cArq, aTables)                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³Nenhum                                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³GENERICO                                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpL1 = lEnd do MsNewProcess                               ³±±
±±³          ³ ExpO1 = Objeto MsNewProcess                                ³±±
±±³          ³ ExpC1 = Nome do arquivo a ser gerado                       ³±±
±±³          ³ ExpA1 = Array com os alias das tabelas a serem exportadas  ³±±
±±³          ³         Ex.: {"CT1", "CVD"}                                ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

Function CTBExpCSV(lEnd, oProcess, cArq, aTables)
Local aStruct	:=	{}
Local cLin		:=	""
Local aArea		:= GetArea()
Local aAreaAux
Local nX,nY
Local nRec,nTot
Local cID

SAVEINTER()

If At('.',cArq) == 0
	cArq	:=	AllTrim(cArq)+'.CSV'
EndIf	
 	If (nHandle := FCreate(cArq))== -1
	Alert(STR0044) //"Erro na criacao do arquivo!"
	Return
EndIf

// Lista de tabelas
cLin:="0"
For nY := 1 to len(aTables)
	cLin += ';'+aTables[nY,1]
Next
cLin += CRLF
FWrite(nHandle,cLin,Len(cLin))

oProcess:SetRegua1(len(aTables)*2)

For nY := 1 to len(aTables)
	oProcess:IncRegua1(STR0045+' '+aTables[nY,1]) //"Lendo estrutura da tabela"
	cId		:= Alltrim(str(nY))
	cLin	:= cId
	aStruct	:=(aTables[nY,1])->(DbStruct())
	For nX:=1 To Len(aStruct)
		cLin	+=	';'+aStruct[nX,1]
	Next	
	cLin += CRLF
	FWrite(nHandle,cLin,Len(cLin))
	
	aAreaAux := (aTables[nY,1])->(GetArea())
	DbSelectArea(aTables[nY,1])
	DbSetOrder(aTables[nY,2])
	DbGoTop()
	nTot := 0
	nRec := 0
	dbEval( {|x| nTot++ },,{|| !Eof()} )
	
	oProcess:IncRegua1(STR0046+' '+aTables[nY,1]) //"Exportando tabela"
	oProcess:SetRegua2(nTot)
	DbGoTop()
	Do While !Eof()
		cLin :=cId
		For nX := 1 To Len(aStruct)
			Do Case
				Case aStruct[nX,2] == "C"
					cLin += ';'+FieldGet(FieldPos(aStruct[nX,1]))
				Case aStruct[nX,2] == "L"
					cLin += ';'+IIf(FieldGet(FieldPos(aStruct[nX,1])),"T","F")
				Case aStruct[nX,2] == "D"
					cLin += ';'+Dtos(FieldGet(FieldPos(aStruct[nX,1])))
				Case aStruct[nX,2] == "N"
					cLin += ';'+Str(FieldGet(FieldPos(aStruct[nX,1])))
				Otherwise
					cLin += ';'
			EndCase					
		Next
		cLin += CRLF
		FWrite(nHandle,cLin,Len(cLin))                          	
		DbSkip()
		nRec++
		oProcess:IncRegua2(Alltrim(Str(nRec))+'/'+Alltrim(Str(nTot)))
	EndDo
	RestArea(aAreaAux)
Next

FClose(nHandle)

Aviso(STR0047,STR0048,{STR0049}) //"Finalizado"###"Exportacao gerada com sucesso" //"Ok"

RestInter()

RestArea(aArea)

Return .T.


/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³CTBImpCSV ³ Autor ³ Marcelo Akama         ³ Data ³ 12/08/09 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Importacao de tabelas de arquivo .CSV                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³CTBImpCSV(lEnd, oProcess, cArq, aCfg)                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³Nenhum                                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³GENERICO                                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpL1 = lEnd do MsNewProcess                               ³±±
±±³          ³ ExpO1 = Objeto MsNewProcess                                ³±±
±±³          ³ ExpC1 = Nome do arquivo a ser importado                    ³±±
±±³          ³ ExpA1 = Array com configuracoes de importacao no formato:  ³±±
±±³          ³                 {cAlias [ , [cCampos] [,bBloco] ] }        ³±±
±±³          ³         Onde:                                              ³±±
±±³          ³            cAlias  = Alias da tabela                       ³±±
±±³          ³            cCampos = Campos para importar (default: Todos) ³±±
±±³          ³            bBloco  = Bloco de codigo para inclusao custom. ³±±
±±³          ³         Ex.: { {"CT1","CT1_CONTA,CT1_CLASSE",{|| } }       ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

Function CTBImpCSV(lEnd, oProcess, cArq, aCfg , lProc)
Local aTables	:= {}
Local lOk		:= .F.
Local aArea		:= GetArea()
Local aPos
Local cLinha
Local nAt
Local cToken
Local nX
Local cID
Local nTable
Local nTot
Local nPos
Local nPosCpo
Local nPosNil
Local xAutoCab
Local aTxt
Local bAppend
Local cIdCV8	:= ""
Local nY
Local cDetalhe := ""
Local aLog :={}
Local cProcesso := FunName()+".IMP"
Default lProc := .T.

Private lMsErroAuto		:= .F.
Private lMsHelpAuto		:= .T.
Private lAutoErrNoFile	:= .T.

SaveInter()

If (nHandle := FT_FUse(AllTrim(cArq)))== -1
	Help(" ",1,"NOFILEIMPOR")
	RestInter()
	Return .F.
EndIf

nTot:=FT_FLASTREC()
oProcess:SetRegua1(nTot)

FT_FGOTOP()

cLinha 	:= FT_FREADLN()
FT_FSKIP()
oProcess:IncRegua1(STR0050) //"Lendo arquivo..."

If Left( cLinha, 2 ) <> "0;"
	Aviso(STR0051,STR0052,{STR0053}) //"Estrutura incorreta."###"Cabecalho nao encontrado"###"Abandona"
	RestInter()
	Return .F.
EndIf

cLinha := Right( cLinha, Len( cLinha ) -2 )
nAt		:=	1
Do While nAt > 0
	nAt	:=	AT(";",cLinha)
	If nAt == 0
		cToken := cLinha
	Else	
		cToken	:=	Substr(cLinha,1,nAt-1)
	EndIf
	
	cToken := Alltrim(cToken)
	
	If !Empty(cToken)
		AADD( aTables, cToken )
	EndIf
	cLinha	:=	Substr(cLinha,nAt+1)
EndDo

If valtype(aCfg)<>"A"
	aCfg := {}
	For nX := 1 to len(aTables)
		AADD(aCfg, {aTables[nX],,})
	Next
Else
	For nX := 1 to len(aCfg)
		If aScan( aTables, aCfg[nX,1] ) == 0
			Aviso(STR0051,STR0032+" "+aCfg[nX,1]+" "+STR0034,{STR0053}) //"Estrutura incorreta."###"Tabela ### nao encontrada."###"Abandona"
			FT_FUSE()
			RestInter()
			Return .F.
		EndIf
	Next
EndIf

If lProc
	ProcLogIni( {},cProcesso ,,@cIdCV8 )
	ProcLogAtu( "INICIO" , STR0054 ,,,.T. ) //"Importação"
EndIf


nTable	:= 0
cID		:= '0'
Do While !FT_FEOF()
	cLinha	:= FT_FREADLN()
	FT_FSKIP()
	oProcess:IncRegua1(STR0050)  //"Lendo arquivo..."
	
	nAt		:= AT(";",cLinha)
	cToken	:= Substr(cLinha,1,nAt-1)
	cLinha	:= Right( cLinha, Len( cLinha ) - nAt )
	If !Empty(cLinha)
		If cToken<>cID
			nTable++
			cID	:= Alltrim(Str(nTable))
			
			If cToken<>cID
				Aviso(STR0051,STR0032+" "+aTables[nTable]+" "+STR0034,{STR0053}) //"Estrutura incorreta."###"Tabela ### nao encontrada."###"Abandona"
				FT_FUSE()
				RestInter()
				Return .F.
			Else
				nPos := aScan( aCfg, { |x| x[1] == aTables[nTable] } )
				lOk	 := nPos>0
				If lOk
					If valtype(aCfg[nPos,2])=="A"
						aCampos := aCfg[nPos,2]
					Else
						aCampos := (aTables[nTable])->( DbStruct() )
					EndIf
					
					If valtype(aCfg[nPos,3])=="B"
						bAppend := aCfg[nPos,3]
					Else
						bAppend := nil
					EndIf
					
					aPos := Array( Len( aCampos ) )
					
					nPos	:=	0
					nAt		:=	1
					Do While nAt > 0
						nPos++
						nAt	:=	AT(";",cLinha)
						If nAt == 0
							cToken := cLinha
						Else
							cToken := Substr(cLinha,1,nAt-1)
						EndIf
						
						If ASCAN(aCampos,{|aCpo| Alltrim(aCpo[1]) == Alltrim(cToken)}) <= 0
							cLinha	:=	Substr(cLinha,nAt+1)
							Loop
						EndIf
						
						nPosCpo	:=	aScan( aCampos, { |x| x[1] == cToken } )
						If nPosCpo > 0
							aPos[nPosCpo]:= nPos
						EndIf
						cLinha	:=	Substr(cLinha,nAt+1)
					EndDo
					While ( nPosNil := aScan( aPos, Nil ) ) > 0
						aPos[nPosNil]:= ++nPos
					End
					If (nPosNil:= Ascan(aPos,Nil)) > 0
						Aviso(STR0051,STR0055+" "+aCampos[nPosNil][1]+" "+STR0056,{STR0053}) //"Estrutura incorreta."###"O campo "###" nao foi achado na estrutura, por favor verificar."###"Abandona"
						FT_FUSE()
						RestInter()
						Return .F.
					EndIf
				EndIf
			EndIf
		Else
			If lOk
				nPos := 0
				aTxt := {}
				Do While At(";",cLinha)>0
					aAdd(aTxt,Substr(cLinha,1,At(";",cLinha)-1))
					nPos ++
					cLinha := StrTran(Substr(cLinha,At(";",cLinha)+1,Len(cLinha)-At(";",cLinha)),'"','')
				EndDo
				If Len(AllTrim(cLinha)) > 0
					aAdd(aTxt,StrTran(Substr(cLinha,1,Len(cLinha)),'"','') )
				Else
					aAdd(aTxt,"")
				EndIf
				
				While aPos[Len(aPos)] > Len( aTxt )
					aAdd( aTxt, "" )
				End
				xAutoCab := {} 
				For nX:=1 To Len(aCampos)
					
					If Len(alltrim(aTxt[aPos[nX]]))>0
						Do Case
						Case Right(aCampos[nX][1], 7) == "_FILIAL"

							If IsInCallStack("CTBA020")
								AADD(xAutoCab,{aCampos[nX][1] , xFilial() , Nil})
							EndIf
							//Não adiciona campo da filial, para outras rotinas(continua como antes).
							/* A protecao acima so foi feita no CTBA020 por conta 
							do compartilhamento da CT1 e amarração com a CVD para correta visualização.
							*/
						Case aCampos[nX][2] == "C"
							AADD(xAutoCab,{aCampos[nX][1] , aTxt[aPos[nX]] , Nil})
							
						Case aCampos[nX][2] == "L"
							AADD(xAutoCab,{aCampos[nX][1] , aTxt[aPos[nX]]=="T" , Nil})
							
						Case aCampos[nX][2] == "D"
							AADD(xAutoCab,{aCampos[nX][1] , STOD( aTxt[aPos[nX] ] ) , Nil})
							
						Case aCampos[nX][2] == "N"
							AADD(xAutoCab,{aCampos[nX][1] , Val( aTxt[aPos[nX]] ) , Nil})
							
						EndCase
					EndIf
					
				Next
				
				If valtype(bAppend) == "B"
					Eval(bAppend)
					MsUnLockAll()
					FreeUsedCode(.T.)
					If lMsErroAuto
						aLog := GETAUTOGRLOG()
						lMsErroAuto := .F.
						lRet := .F.
						cDetalhe := ""
						
						For nY := 1 to Len(aLog)
							cDetalhe += aLog[nY]+CHR(10)
						Next nY
						If lProc
							ProcLogAtu( "ERRO", STR0057 ,cDetalhe,,.T.)//"Erro na Inclusão"
						EndIf
					Endif
				Else
					RecLock(aTables[nTable],.T.)
					For nX:=1 To Len(xAutoCab)
						FieldPut(FieldPos(xAutoCab[nX,1]), xAutoCab[nX,2])
					Next
					MsUnLock()
				EndIF
			EndIf
		EndIf
	EndIf
EndDo

FT_FUSE()

If lProc
	ProcLogAtu( "FIM",,,,.T. )
	ProcLogView(cFilAnt,'CTBImpCSV',,cIdCV8 )
EndIf

RestInter()

RestArea(aArea)

Return .T.

//-------------------------------------------------------------------
/*{Protheus.doc} CtbFilVers()
Filtro 

@author Simone Mie Sato Kakinoana

@version P12
@since   27/03/2015
@return  Nil
@obs
*/
//-------------------------------------------------------------------
Function CtbFilVers()
Local lRet	:= .T.

lRet := CVN->CVN_CODPLA == cPlanoRef .And. CVN->CVN_VERSAO == cVersao 

Return(lRet)

//-------------------------------------------------------------------
/*{Protheus.doc} IsRedStor()

@author Eduardo.Flima
@since   05/06/2018
@version 1.0
@project MA3 - Russia
@return  lRet

@obsENG  Function Used to check if the Red Storn Concept used in russia is active in the system
@obsPOR  Fun??o Usada para verificar se o Conceito Red Storn utilizado na R?ssia est? ativo no sistema
@obsSPA  Funci?n Se usa para verificar si el concepto de Red Storn utilizado en Rusia est? activo en el sistema
*/
//-------------------------------------------------------------------
Function IsRedStor()
	Local lRet	:= .F.
	lRet := cPaisLoc == "RUS" .And. SuperGetMV("MV_REDSTOR",.F.,.F.)
Return(lRet)

//-------------------------------------------------------------------
/*{Protheus.doc} CTPROTDADO()

@author gustavo.campos
@since   30/01/2020
@version 1.0
@project padrao - Brasil
@return  lRet
*/
//-------------------------------------------------------------------
function CTPROTDADO()
	Local lRet := Versenha(192)

	If !lRet
		//Dados Protegidos - Função para tratativa de dados pessoais quando usuario nao tem acesso, desabilita o F3 para não visualizar os dados na tabela de usuarios do sistema
		Help("",1,STR0061,, STR0062, 1, 0 ) //Usuario sem acesso a dados pessoais
	Endif

Return lRet

//-------------------------------------------------------------------
/*{Protheus.doc} CTPROTLGDP()

@author totvs
@since   31/07/2020
@version 1.0
@project padrao - Brasil
@return  lRet
*/
//-------------------------------------------------------------------
function CTPROTLGDP()

Return CTPROTDADO()


/*/{Protheus.doc}VldEntPCO
Função de validação para entidades que contém lançamentos no PCO
Nao sera possivel excluí-las.
cAlias -> Tabela trabalhada
cEntidade -> Codigo da respectiva entidade
aEntidade -> Codigo das Entidades adicionais
@author Gustavo Campos.
@since  22/10/2020
@version  P12.
/*/
Function VldEntPCO(cAlias,cEntidade,cEntAdic)

	Local lRet 			:= .T.
	Local aSaveArea 	:= Getarea()
	Local cQuery		:= ""
	Local cAliasTRB  	:= GetNextAlias()
	Local cCampoAKD		:= ""
	Local cAKD			:= 'AKD'
	Local lUsePCO		:= SuperGetMV("MV_PCOINTE",.T.,"2") == '1'

	Default cAlias 		:= aSaveArea[1]
	Default cEntidade 	:= ""
	Default cEntAdic 	:= ""
	

	If lUsePCO// validação se tem integração do PCO

		//deriva de onde vem os dados das entidades
		If cAlias == "CTT" //CTT_CUSTO
			cCampoAKD := "AKD_CC"
		ElseIf cAlias == "CTD" //"CTD_ITEM"
			cCampoAKD := "AKD_ITCTB"
		elseIf cAlias == "CTH" //CTH_CLVL
			cCampoAKD := "AKD_CLVLR"
		Else	//CV0_CODIGO
			Do Case
				Case cEntAdic = "05"
					cCampoAKD := "AKD_ENT05"
				Case cEntAdic = "06"
					cCampoAKD := "AKD_ENT06"
				Case cEntAdic = "07"
					cCampoAKD := "AKD_ENT07"
				Case cEntAdic = "08"
					cCampoAKD := "AKD_ENT08"
				Case cEntAdic = "09"
					cCampoAKD := "AKD_ENT09"
			EndCase

		Endif
		

		DBSelectArea(cAlias)
		cQuery := "SELECT COUNT(" + cCampoAKD + ") QTDENTIDADE "
		cQuery += "FROM " + RetSqlName(cAKD)
		cQuery += " WHERE "
		cQuery += cAKD + "_FILIAL = '" + XFilial(cAKD)  + "' "
		cQuery += "AND " + cCampoAKD  + " = '" + cEntidade + "' "
		cQuery += "AND " + "D_E_L_E_T_ = '' "

		cQuery := ChangeQuery(cQuery)

		dbUseArea( .T., "TOPCONN", TcGenQry(,, cQuery), cAliasTRB, .T., .T. )

		If (cAliasTRB)->(!Eof() .and. QTDENTIDADE > 0)
			lRet := .F.
		EndIf

		(cAliasTRB)->(dbCloseArea())

		If !lRet 
			Help("",1,STR0063,, STR0064, 1, 0 ) //"Entidade em uso"##"Entidade contém vinculo com lançamentos no PCO, favor verificar."
		Endif
		
		RestArea(aSaveArea)
Endif

Return lRet
/*/{Protheus.doc} CTBNivVis
Lê a Visão Gerencial e retorna o nível da conta de forma estruturada 
@author TOTVS
@since  19/01/2021
@version  P12
@return  aNivEstrut -> array contendo o nível de cada conta da visão

@cCodVis -> Código da visão gerencial 
/*/
Function CTBNiVis(cCodVis)
Local cQuery    := ""
Local cAliasCTS := GetNextAlias()
Local aRet 		:= {}

DEFAULT cCodVis := "" 

If !Empty(cCodVIs)
	cQuery:= " SELECT DISTINCT CTS_CONTAG CONTA , CTS_CTASUP CTASUP "+;
			 " FROM "+RetSQLName("CTS")+;
			 " WHERE CTS_FILIAL = '"+xFilial("CTS")+"' AND "+;
			 " CTS_CODPLA = '"+cCodVIs+"' AND "+;
			 " D_E_L_E_T_ = ' ' "+;
			 " ORDER BY CTS_CTASUP, CTS_CONTAG "

	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasCTS,.T.,.F.)

	aRet := CtbRetNiv(cAliasCTS)

	(cAliasCTS)->(dbCloseArea())
EndIf	

Return aRet
/*/{Protheus.doc} CTBNivTmp
Lê o arquivo temporário da CTGerPlan e retorna o nível da conta de forma estruturada 
@author TOTVS
@since  19/01/2021
@version  P12
@return  aRet -> array contendo o nível de cada conta da visão

@cCTBArqTmp -> Arquivo temporário da CTGerPlan
/*/
Function CTBNivTmp(cNomeArq,cCpoCta,cCpoSup,cArqTmp)
Local cQuery    := ""
Local cAliasAux := GetNextAlias()
Local aRet 		:= {}

DEFAULT cNomeArq := "" 
DEFAULT cCpoCta  := ""
DEFAULT cCpoSup  := ""

If Select(cArqTmp) > 0 .And.;
   !Empty(cNomeArq) .And. !Empty(cCpoCta) .And. !Empty(cCpoSup)
	cQuery:= " SELECT DISTINCT "+cCpoCta+" CONTA , "+cCpoSup+" CTASUP , R_E_C_N_O_ RECNO "+;			 
			 " FROM "+cNomeArq+;			 
			 " ORDER BY "+cCpoSup+","+cCpoCta

	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasAux,.T.,.F.)

	aRet := CtbRetNiv(cAliasAux,.T.,cArqTmp)

	(cAliasAux)->(dbCloseArea())
EndIf	

Return aRet
/*/{Protheus.doc} CtbRetNiv
Faz o cálculo do nível com a estrutura dos arquivos JSON do Banco Central
@author TOTVS
@since  19/01/2021
@version  P12
@return  aNivEstrut -> array contendo o nível de cada conta da visão

@cCodVis -> Código da visão gerencial 
/*/
Function CtbRetNiv(cAliasAux,lCtbGrvTmp,cArqTmp)
Local aRet		:= {}
Local nNivel	:= 0
Local cNivel 	:= ""
Local cCtaSup	:= ""
Local cConta	:= ""
Local oHMCtaSup := tHashMap():New()

DEFAULT cAliasAux  := GetNextAlias()
DEFAULT lCtbGrvTmp := .F.

If Select(cAliasAux) > 0
	While !(cAliasAux)->(Eof())

		If (cAliasAux)->CONTA <> cConta			
			cNivel  := ""
			nNivel++		
			
			If (cAliasAux)->CTASUP <> cCtaSup 
				nNivel := 1
			EndIf

			If Empty((cAliasAux)->CTASUP)	
				cNivel := cValToChar(nNivel)
			ElseIf oHMCtaSup:Get((cAliasAux)->CTASUP,@cNivel)				
				cNivel+= "."+cValToChar(nNivel)
			Else
				cNivel+=cValToChar(nNivel)				
			EndIf

			oHMCtaSup:Set((cAliasAux)->CONTA,cNivel)
			If lCtbGrvTmp
				cArqTmp->(dbGoTo((cAliasAux)->RECNO))
				cArqTmp->(RecLock("cArqTmp",.F.))
					cArqTmp->NIVJSON := cNivel
				cArqTmp->(MsUnLock())
			EndIf
		EndIf

		cCtaSup := (cAliasAux)->CTASUP
		cConta := (cAliasAux)->CONTA

		(cAliasAux)->(dbSkip())
	EndDo
	
	If HMList(oHMCtaSup, @aRet)
		aSort(aRet,,,{|x,y| x[1] < y[1]})
	EndIf
	
	oHMCtaSup:Clean()
	oHMCtaSup := Nil
EndIf

Return aRet
//-------------------------------------------------------------------
/*{Protheus.doc} CTB_IsJSON
Leitura parametro MV_CTBJSON para verificar se gera arquivos json de demonstrativos contabeis

@author Totvs
   
@version P12
@since   19/01/2021
@return  Nil
@obs     
*/
//-------------------------------------------------------------------
Function CTB_IsJSON()
Local lRet := .F.

//PARAMETRO TIPO CARACTER '0' = CTBJSON DESABILITADO ; '1' - CTBJSON HABILITADO
//OPTAMOS POR SER CARACTER PQ FUTURO PODE TER ALGUMAS VARIACOES
lRet := ( GetNewPar( "MV_CTBJSON", "0") == "1" ) //POR PADRAO SAI DESABILITADO

Return(lRet)

//-------------------------------------------------------------------
/*{Protheus.doc} CTBDEMJSON
Pergunte para gerar arquivos json de demonstrativos contabeis

@author Totvs
   
@version P12
@since   19/01/2021
@return  Nil
@obs	 
*/
//-------------------------------------------------------------------
Function CTBDEMJSON()
Local aRet		 := {}
Local lAutomato  := IsBlind()

If CTB_IsJSON()
	//salva todas variaveis MV_PAR
	SaveInter()	

	If lAutomato
		aRet := Array(6)
		If Type("aRetAuto")=="U"
			aRetAuto := Array(6)
		EndIf
			
		aRet[1] := aRetAuto[1]
		aRet[2] := aRetAuto[2]
		aRet[3] := aRetAuto[3]
		aRet[4] := aRetAuto[4]
		aRet[5] := aRetAuto[5]
		aRet[6] := aRetAuto[6]		
		
	ElseIf Pergunte("CTBJSON")
		aRet := Array(6)		
		/*
			Pergunta/Campo	Obs.
			Elemento 1 -> Gerar ? 	0=Relatório; 1=JSON; 2=Ambos (Default deve ser 0=Relatório)
									Se for escolhido Relatório: Gerar somente o relatório TReport;
									Se for escolhido JSON: Gerar somente o arquivo JSON;
									Se for escolhido Ambos: Gerar o arquivo JSON após a impressão do relatório.
			Elemento 2 -> Mês Ano Referencia ? 	MMAAAA
			Elemento 3 -> Documento ? 	Código do documento de acordo com o manual do BC (9011, 9311...etc)
			Elemento 4 -> Diretório ? 	Deve permitir salvar na máquina local
			Elemento 5 -> Tipo Demonstração ?	0=Individual;1=Consolidada
			Elemento 6 -> Bloco ?	Código do bloco a ser impresso CW0 tabela JS
		*/
		aRet[1] := MV_PAR01
		aRet[2] := MV_PAR02
		aRet[3] := MV_PAR03
		aRet[4] := MV_PAR04
		aRet[5] := MV_PAR05				
		aRet[6] := MV_PAR06
	EndIf

	//restaura as variaveis MV_PAR
	RestInter()
EndIf

Return(aRet)
//-------------------------------------------------------------------
/*{Protheus.doc} CtVlMesAno
Valida Mes/Ano para gerar arquivos json de demonstrativos contabeis

@author Totvs
   
@version P12
@since   19/01/2021
@return  Nil
@obs	 
*/
//-------------------------------------------------------------------
Function CtVlMesAno(cMesAno)
Local cMes := Left(cMesAno,2) 
Local cAno := Right(cMesAno,4)    
Local lRet := .F.

If Val(cMes) >= 1 .And. Val(cMes) <= 12
	lRet := .T.
EndIf

If lRet 
	If Val(cAno) >= 1980 .And. Val(cAno) <= 2043
		lRet := .T.
	Else
		lRet := .F.
	EndIf
EndIf

Return(lRet)

//-------------------------------------------------------------------
/*{Protheus.doc} CtVlDocJson
Valida codigo documento para gerar arquivos json de demonstrativos contabeis

@author Totvs
   
@version P12
@since   19/01/2021
@return  Nil
@obs	 
*/
//-------------------------------------------------------------------
Function CtVlDocJson(cCodDoc) 
/*
1.	9011 – Demonstrações financeiras individuais/consolidadas - Legislação societária ou CVM*;
2.	9311 – Demonstrações financeiras individuais intermediárias/consolidadas intermediárias - Legislação societária ou CVM*;
3.	9031 – Demonstrações financeiras consolidadas em IFRS;
4.	9331 – Demonstrações financeiras consolidadas semestrais e intermediárias em IFRS;
5.	9061 – Demonstrações financeiras consolidadas do Conglomerado Prudencial.
*CVM – Comissão de Valores Mobiliários
*/
Return( cCodDoc $ "9011;9311;9031;9331;9061" )                                     


//-------------------------------------------------------------------
/*{Protheus.doc} CtJsonPath
Informa o arquivo a ser gerado - json de demonstrativos contabeis

@author Totvs
   
@version P12
@since   19/01/2021
@return  Nil
@obs	 
*/
//-------------------------------------------------------------------

Function CtJsonPath(cJsonArq)

Local cType			:= "*.*"

If Empty(cJsonArq)
	cJsonArq	:= cGetFile(cType, ("Selecione arquivo "+Subs(cType,1,7) ),,,,GETF_NETWORKDRIVE+GETF_LOCALHARD+GETF_LOCALFLOPPY ) // "Selecione arquivo "
EndIf

Return !Empty(cJsonArq)


//-------------------------------------------------------------------
/*{Protheus.doc} CtLstPerg
Retorna string json com conteudo do pergunte

@author Totvs
   
@version P12
@since   19/01/2021
@return  Nil
@obs	 
*/
//------------------------------------------------------------------

Function CtLstPerg(cPerg, aResp)
Local oObjPerg
Local aPergunte
Local nX
Local oObjAux 
Local cStrJson := ""
Local xConteudo := ""

Default aResp := {}

oObjPerg := FWSX1Util():New()
oObjPerg:AddGroup(cPerg)

oObjPerg:SearchGroup()
aPergunte := oObjPerg:GetGroup(cPerg)

For nX := 1 TO Len(aPergunte[2])

	oObjAux := aPergunte[2][nX]

	cStrJson += '{'

	cStrJson += '"X1_ORDEM":"'+oObjAux:CX1_ORDEM+'", '
	cStrJson += '"X1_PERGUNT":"'+NoAcento( oObjAux:CX1_PERGUNT )+'", '
	cStrJson += '"X1_TIPO":"'+oObjAux:CX1_TIPO+'", '
	cStrJson += '"XCONTEUDO":'
	
	If Empty(aResp)
		xConteudo := &("MV_PAR"+STRZERO(nX,2))
	Else
		xConteudo := aResp[nX]
	EndIf

	If Valtype(xConteudo)=="C" .And. ( "\" $ xConteudo .OR. "/" $ xConteudo .OR. ":" $ xConteudo )
		xConteudo := StrTran(xConteudo, "/","//") //quando for caminho de arquivo deve substituir / por //
		xConteudo := StrTran(xConteudo, "\","\\") //quando for caminho de arquivo deve substituir / por //
	EndIf

	If oObjAux:CX1_TIPO == "C"
		cStrJson += '"'+xConteudo + '" '
	ElseIf oObjAux:CX1_TIPO == "D"
		cStrJson += '"'+DtoC(xConteudo) + '" '
	ElseIf oObjAux:CX1_TIPO == "N"
		cStrJson += Alltrim(Str(xConteudo)) + ' '
	EndIf

	If nX == Len(aPergunte[2])
		cStrJson += '}'+CRLF
	Else
		cStrJson += '},'+CRLF
	EndIf

Next

Return( cStrJson )


//-------------------------------------------------------------------
/*{Protheus.doc} CTNmDemon
Retorna string json da demonstração

@author Totvs
   
@version P12
@since   04/02/2021
@return  cRet -> Nome da demonstração
@obs	 
*/
//------------------------------------------------------------------

Function CTNmDemon(nCodigo,nConsolid)
Local cRet 			:= ""
Local lConsolid 	:= .F.

DEFAULT nCodigo 	:= 0
DEFAULT nConsolid 	:= 0

lConsolid := (nConsolid == 2)

Do Case
	Case nCodigo == 1
		cRet := ""		
	Case nCodigo == 2
		cRet := "DemonstracaoDoResultadoAbrangente"
		If lConsolid
			cRet += "Consolidada"	
		EndIf
	Case nCodigo == 3
		cRet := "DemonstracaoDosRecursosDeConsorcioConsolidada"
	Case nCodigo == 4
		cRet := "DemonstracaoDeVariacoesNasDisponibilidadesDeGruposConsolidada"
End Case
	
//Não converter para STR pois se trata de legislação e não deverá ser traduzido. 	
Return( cRet )

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜßßßßßßßßßßßßßß
Protheus.doc} CTBVLTRIB
Retorna o valor do Tributo conforme o IDTRIB  

@author Vinicius Nascimento
@version P12
@since   28/04/2025
@return  nValor -> Valor do Tributo
@parameters cIdTrib -> IDTRIB (SD1/SD2)
			cTrib	-> Nome do Tributo desejado conforme o CFGTRIB
			lOperacao -> Operação 0-Sem ação, 1-Soma, 2-Subtrai
			lDesDocEnt -> Retorna valor Desmembrado da Nota de Entrada quando está para
			              Desmembrar Ativo = Sim, .T. = Sim e .F. = Não (Padrão)
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function CTBVLTRIB(cIdTrib as character, cTrib as character, lOperacao as logical, lDesDocEnt as logical) as numeric

Local cQuery        as character
Local oStateQry		as object
Local nValor		as numeric
Local nSeq			as numeric

cQuery   			:= ""
oStateQry			:= Nil
nValor				:= 0
nSeq				:= 1

Default cIdTrib		:= ""
Default cTrib		:= ""
Default lOperacao 	:= .F.
Default lDesDocEnt  := .F.

If lOperacao
	If findFunction("backoffice.stock.calculationcost.HasRulesCust",.T.)
		lOperacao := backoffice.stock.calculationcost.HasRulesCust() // Verifica se as regras de custo estao habilitadas	 
	EndIf 
EndIf

IF !Empty(cIdTrib)
	cQuery := "SELECT " + CRLF

	If lOperacao		
		cQuery += " CASE " + CRLF
        cQuery += "     WHEN COALESCE(F2B.F2B_RCUSTO, ' ') = ' ' THEN F2D.F2D_VALOR " + CRLF
        cQuery += "     WHEN D4H.D4H_OPERA = '1' THEN F2D.F2D_VALOR " + CRLF
        cQuery += "     WHEN D4H.D4H_OPERA = '2' THEN -F2D.F2D_VALOR " + CRLF
        cQuery += "     WHEN D4H.D4H_OPERA = '0' OR COALESCE(D4H.D4H_OPERA, ' ') = ' ' THEN 0 " + CRLF
        cQuery += "     ELSE F2D.F2D_VALOR " + CRLF // fallback
    	cQuery += " END AS F2D_VALOR " + CRLF
	Else
		cQuery += " F2D.F2D_VALOR AS F2D_VALOR " + CRLF
	EndIf

	cQuery += " FROM " +RetSQLName("F2D") + " F2D " + CRLF
	cQuery += " INNER JOIN " +RetSQLName("F2B") + " F2B ON " + CRLF
	cQuery += "     F2D.F2D_IDCAD  = F2B.F2B_ID " + CRLF

	If lOperacao
		cQuery += " LEFT JOIN " +RetSQLName("D4H") + " D4H ON " + CRLF
		cQuery += "     D4H.D4H_FILIAL = '"+ xFilial('D4H') + "' AND " + CRLF
		cQuery += "     F2B.F2B_RCUSTO = D4H.D4H_REGRA " + CRLF
		cQuery += "     AND D4H.D_E_L_E_T_ = ? " + CRLF
	EndIf

	cQuery += " WHERE " + CRLF
	cQuery += "     F2D.F2D_IDREL  = ? AND " + CRLF
	cQuery += "     F2B.F2B_TRIB   = ? AND " + CRLF
	cQuery += "     F2D.D_E_L_E_T_ = ? AND " + CRLF
	cQuery += "     F2B.D_E_L_E_T_ = ? " + CRLF

	// Criação do ExecStatement
	oStateQry := FwExecStatement():New(cQuery)

	// Define os parâmetros da query
	If lOperacao
		oStateQry:SetString(nSeq++, ' ')     // D4H.D_E_L_E_T_ 
	EndIf 

	oStateQry:SetString(nSeq++, cIdTrib) 	// F2D_IDREL
	oStateQry:SetString(nSeq++, cTrib) 		// F2B_TRIB
	oStateQry:SetString(nSeq++, ' ')		// F2D.D_E_L_E_T_
	oStateQry:SetString(nSeq++, ' ')		// F2B.D_E_L_E_T_

	nValor := oStateQry:ExecScalar("F2D_VALOR")

	If lDesDocEnt
		DbSelectArea("SD1")
		SD1->(DBSetOrder(23))
		If dbSeek(XFilial("SD1") + cIdTrib) .AND. AllTrim(POSICIONE("SF4", 1, xFilial("SF4")+SD1->D1_TES,"F4_BENSATF")) == '1'
			nValor := nValor / SD1->D1_QUANT
		EndIf
	EndIf	

	oStateQry:Destroy()
	FreeObj(oStateQry)

EndIf 

Return nValor

//-----------------------------------------------------------------------------------
/*{Protheus.doc} JobVldEnt
Valida as entidades contábeis da rotina CTBA290, mesmo que de outro grupo de empresas

DEVE SER CHAMADO AQUI, POIS DENTRO DA PRÓPRIA ROTINA NÃO FUNCIONA, DEVIDO ALGUMAS 
VARIÁVEIS ESTATICAS SEREM CHAMADAS PELO STARTJOB SEM AMBIENTE ATIVO NA SEGUNDA THREAD

@author pierre.nascimento
@version P12
@since   28/07/2025
@return  cMensagem -> Mensagem a ser apresentada na tela
*/
//------------------------------------------------------------------------------------
Function JobVldEnt(cAlias As Character, cEnt As Character, cConteud As Character, nOpcx As Numeric, lFim As Logical, cTpEnt As Character,aXFilial,;
					cEntAdc As Character, lEntIgual As Logical, cCampoCV5 As Character, cEmpVld As Character, cFilVld As Character) As Character
Local cMensagem As Character

cMensagem := ""

RpcSetType(3)
RpcSetEnv( cEmpVld, cFilVld )
	cMensagem := Ct290Vld(cAlias,cEnt,cConteud,nOpcx,lFim,cTpEnt,@aXFilial,cEntAdc,lEntIgual,cCampoCV5)
RpcClearEnv()

Return cMensagem

//-----------------------------------------------------------------------------------
/*{Protheus.doc} CTBInstPRC
Faz a verificação do processo no SPMANAGE e, caso necessário, instala ou atualiza

@author TOTVS
@version P12
@since   27/08/2025
@param   cProcess -> Código do processo que será verificado
@return  lRet -> Processo instalado/atualizado com sucesso
*/
//------------------------------------------------------------------------------------
Function CTBInstPRC(cProcess)	
	Local oMyProcess := Nil
	Local oRPOProcess:= Nil
	Local oInstall   := Nil
	Local lRet 		 := .F.
	Local cError 	 := ""

	Default cProcess := ""

	 If FindFunction("SPSMigrated")      
        If SPSMigrated() // verifica se o ambiente está migrado  
          	oMyProcess := EngSPSStatus(cProcess) // código da empresa não é obrigatório - Default = cEmpAnt  
            //2 = DEF_SPS_NOT_INSTALLED 
			If oMyProcess["status"] == "2" // se não está instalado, possibilita a instalação com o que está no RPO ou TPH                                              
				//1 = DEF_SPS_FROM_RPO 
				oRPOProcess := EngSPSGetProcess("1",cProcess) 
				If oRPOProcess["status"] <> "FALSE"  
					oInstall := EngSPSInstall(oMyProcess["process"])
					cError := oInstall["error"]
					If Empty(cError)
						lRet := .T.
					Else
						Help(nil,nil,"NOINSTPROC",nil,cError,1,0)	
					EndIf
				EndIf
			Else 
				lRet := .T.
				EngSPSUpdate(cProcess)
			EndIf			
		EndIf
	EndIf                                
                        
Return lRet

/*{Protheus.doc} VldEaiPrF
Governança centralizada de EAI: Validação por Lista Fixa de Clientes e Licença do PROPHIX

@param   cXML	    Variável com xml de envio/recebimento
@param   cXMLRet    Variável passada por referência que receberá a mensagem de erro/retorno quando houver bloqueio.
@author  Ronaldo Tapia
@since   19/05/26
@return  lRet - Valida se o cliente pode ou não usar a integração EAI
	Se retornar .F., `cXMLRet` conterá a mensagem de bloqueio a ser retornada ao caller.
*/
Function VldEaiPrF(cXml As Character, cXMLRet As Character) As Logical
    Local lRet        As Logical
    Local lOk         As Logical
    Local nIsIntPro   As Numeric
    Local oAuthComp   As Json
    Local cCodCli     As String
    Local cMarca      As String
    Local cErroXml    As String
    Local cWarnXml    As String
    Local cError      As String
    Local oXmli020    As Object
    
	//Parâmetros de entrada.
	Default cXml    := ""
	Default cXMLRet := ""
	
	//Inicializações padrão
    lRet        := .T.
    lOk         := .F.
    nIsIntPro   := 0
    oAuthComp   := Nil
    cCodCli     := ""
    cMarca      := ""
    cErroXml    := ""
    cWarnXml    := ""
    cError      := ""
    oXmli020    := Nil
    
	If __lLoadTph == Nil
		__lLoadTph := FindFunction("totvs.protheus.software.engineering.expedition.tphupdinteg.LoadTphUpdValue")
	EndIf
	
	If __lLoadTph .And. !Empty(AllTrim(cXml)) .And. !Empty(cCodCli := totvs.framework.ls.GetTCode())		
		//Lista fixa de Códigos de Clientes autorizados (Retornada pela Engenharia Protheus)
		oAuthComp := totvs.protheus.software.engineering.expedition.tphupdinteg.LoadTphUpdValue("PROPHIX_LIST", @cError)
		
		//Garante que o retorno é realmente um objeto antes de prosseguir
		If oAuthComp != Nil
			lOk := ValType(oAuthComp) == "J" .And. ValType(oAuthComp["codt"]) == "A" .And. AScan(oAuthComp["codt"], {|x| x == cCodCli}) > 0		
			
			If lOk .And. (lOk := (oXmli020 := XmlParser(cXml, "_", @cErroXML, @cWarnXML)) != Nil)
				lOk := AttIsMemberOf(oXmli020, "_TOTVSMESSAGE") .And. AttIsMemberOf(oXmli020:_TOTVSMESSAGE, "_MESSAGEINFORMATION")
			EndIf
			
			If lOk .And. ValType(oXmli020:_TOTVSMessage:_MessageInformation:_Product:_name:Text) != "U"
				cMarca := AllTrim(oXmli020:_totvsmessage:_messageinformation:_product:_name:text)
				
				If cMarca != "RM" .And. cMarca != "DATASUL" .And. (nIsIntPro := FWLSGetTotal(3167)) == 0
					lRet := .F.
					cXMLRet := STR0071 // "BLOQUEIO DE SEGURANCA: Licenca de integração não ativa para este produto, favor consultar seu Gerente de Atendimento e Relacionamento." 
				EndIf
			EndIf
			
			If oXmli020 != Nil .And. ValType(oXmli020) == "O" 
				FreeObj(oXmli020)
			EndIf
			
			oAuthComp := Nil
		EndIf
	EndIf
Return lRet
