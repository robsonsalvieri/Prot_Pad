#INCLUDE "PROTHEUS.CH"
#INCLUDE "LOCXGEN.CH"
#INCLUDE "TOPCONN.CH"

#Define ScTitulo    1
#Define ScCampo     2
#Define ScPicture   3
#Define SnTamanho   4
#Define SnDecimal   5
#Define ScValid     6
#Define ScUsado     7
#Define ScTipo      8
#Define ScArquivo   9
#Define ScContexto 10
#Define ScConteudo 11
#Define SnOrdem    12
#Define SlObrigat  13                             
#Define ScObjPai   14
#Define ScChange   15
#Define ScF3       16
#Define ScWhen     17
#Define SnTop      18
#Define SnLeft     19
#Define SlCombo    20
#Define SaItens    21
#Define SbRetCpo   22
#Define SbInitPad  23

#Define nMaxPar    23


STATIC aCacheSX3
Static oJImpTES := JsonObject():New()
Static lChkLxProp := FindFunction("ChkLxProp")
/*
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o	  ³ LocxMod  ³ Autor ³ Guilherme C. Leal    ³ Data ³ 20010711 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o  ³ Cria Tela de acordo com os parametros passados.			  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso		  ³ Generico										   		  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³         ATUALIZACOES SOFRIDAS DESDE A CONSTRU€AO INICIAL.             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Programador ³Data    ³ BOPS     ³ Motivo da Alteracao                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Alf. Medrano³24/07/15³PCREQ-4256³ Se elimina  de la función Bin25Str se³±±
±±³            ³        ³          ³ cambia por X3Uso() se comenta func.  ³±±
±±³            ³        ³          ³ PutIndex() adecuacion nuevas         ³±±
±±³            ³        ³          ³ estructuras SX para Version 12.      ³±±
±±³Alf. Medrano³19/11/15³PCREQ-4263³ se realiza merge 12.1.8              ³±±
±±³Jonathan glz³29/11/16³SERINN001-³ Se realiza adecuacion de SX, se eli- ³±±
±±³            ³        ³       428³ mina funcion PutIndex() que no se usa³±±
±±³Raúl Ortiz M³22/12/17³DMICNS-652³ Creacion campos F2_VALCOT,F2_ACOPLA, ³±±
±±³            ³        ³          ³ F2_VEHICL y modificacion campo       ³±±
±±³            ³        ³          ³ DUT_CATVEI - (Arg)                   ³±±
±±³Raúl Ortiz M³01/02/18³DMICNS-   ³ Se consideran los descuentos en la   ³±±
±±³            ³        ³1581      ³ función AutCalTES -  Argentina       ³±±
±±³Marco A Glez³29/04/19³DMINA-6288³ Se agrega validacion para cuando se  ³±±
±±³            ³        ³          ³ selecciona un documento no transmiti-³±±
±±³            ³        ³          ³ do en las NCC para Colombia.         ³±±
±±³LuisEnríquez³16/07/19³DMINA-6842³ Se agrega función LocxVldTp9 para va-³±±
±±³            ³        ³          ³ dacion de cond. de pago tipo 9 (EUA) ³±±
±±³Oscar G.    ³12/09/19³DMINA-7302³ En la fun. LocxMOd() se reubica la   ³±±
±±³            ³        ³          ³ inicialización de variables y elimna ³±±
±±³            ³        ³          ³ localización por país en valida. PER ³±±
±±³Verónica F. ³30/09/19³DMINA-7558³ En la fun. LocxMOd() se bifurca la   ³±±
±±³            ³        ³          ³ inicialización de variables con la   ³±±
±±³            ³        ³          ³ localización por país en valida. PER ³±±
±±³LuisEnríquez³06/11/19³DMINA-7702³ Activación del PE M465DORIFE. (COL)  ³±±
±±³Oscar G.    ³06/10/20³DMINA-9842³ Se ajusta funcion PictNIT() para uso ³±±
±±³            ³        ³          ³ desde Currículos (RSPA). COL         ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
 */              //   1         2       3        4        5       6      7       8    9   10    11     12      13     14     15        16        17      18     19      20     21         22       23      24      25       26       27    28     29
FUNCTION LocxMod(aParHead,aCposCab,aParRod,aCposRod,aParGrid,aCpos,cTitulo,aCordW,lGD,aCGD,aCSbx,nOpcx,cFldOK,cLineOk,cAllOk,__cFunOk,__cFunCanc,cIniLin,aGetsGD,nMax,lDelGetD,__aBotoes,__aTeclas,aObjs,__cDelOk,cOnInit,lEnchBar,lEndWnd,aOrditem)

// DEFINES REFERENTES AOS PARAMETROS QUE SERAO PASSADOS PARA A LOCXHEAD
#Define SHcAlias    1
#Define SHlMark     2
#Define SHaCpos     3
#Define SHaCposNo   4
#Define SHaCposExt  5
#Define SHaPEHeader 6
#Define SHlConsUso  7

#Define SHnMax      7

// DEFINES REFERENTES AOS PARAMETROS QUE SERAO PASSADOS PARA A LOCXGRID
#Define SCcAlias    1
#Define SCcWhile    2
#Define SCc_CondIf  3
#Define SClMark     4
#Define SCcCMarca   5
#Define SCcSeek     6
#Define SCnInd      7
#Define SCaCpos     8
#Define SCaCposNo   9
#Define SCaCposExt  10
#Define SCaPECols   11
#Define SCaPEHeader 12
#Define SClConsUso  13

#Define SCnMax      13

Local aArea     := { Alias() , IndexOrd() , RecNo() }
Local nOpca     := 0,nIaHead,nPosAt, i, c_Campo, nX, nY, cCaption, cPict, cValid, cF3, cWhen, nLargSay, nLargGet, uConteudo, oSay, oGet
Local nCOunt,cBlkGet,	cBlkWhen,cBlkVld, oSaveGetdad := Nil, aSvRot := Nil
Local aRetGrid  := {}
Local bGotFocus := ""
Local nIaCbo
Local aCposObrig:= {}
Local aCposTela := {}
Local __lOk     := .F.
Local lCabec    := .F.
Local lRodape   := .F.
Local lA465CANC := ExistBlock("A465CANC")
Local cVar		:= ""
Local aCache	:= {}
Local lAutoOk	:= .T.
Local aGetsAuto	:= {}
Local nMaxPE    := 0
Local xTitulo	:= ""
Local oSize := FwDefSize():New()
Local nYCab  := 100
Local nYGrid := 100
Local nYFoot := 100
Local nCols	:= 0
Local nPosEsp := 0
Local cFunOrig := ""
Local cArquivo := ""

Private aResTES := {}
Private Inclui  := ( nOpcx == 3 )
Private _l_AllOk:= .F.
Private aCoord	:= {}
Private __aoGets    := {}
Private __aCpTela   := {}
Private __aObjs     := {}
// Variáveis declaradas para compatibilizacao com outras rotinas do SIGA
Private Altera:=.t.,lRefresh:=.t.,aTELA:=Array(0,0),aGets:=Array(0),bCampo:={|nCPO|Field(nCPO)},nPosAnt:=9999,nColAnt:=9999
Private cSavScrVT,cSavScrVP,cSavScrHT,cSavScrHP,CurLen,nPosAtu:=0
Private __cFldOk
Private oDlgDocFis := Nil
Private oGetDados
Private aRecnos	:=	{}

Iif(Empty(__cFunOk),__cFunOk:=NIL,)
Iif(Empty(__cFunCanc),__cFunCanc:=NIL,)
Iif(Empty(cOnInit),cOnInit:=NIL,)

Default aCordW    := {oSize:aWindSize[1],oSize:aWindSize[2],oSize:aWindSize[3],oSize:aWindSize[4]}
Default cTitulo   := FunDesc()
Default lGD		  := aParGrid != NIL .Or.(Type("aCols")!="U" .And. Type("aHeader")!="U" .And. aCols!=NIL .And. aHeader!=NIL)
lRodape   := aCposRod!=NIL .Or. aParRod!=NIL  // Não tem Default mesmo, é proposital.

//Arruma proporção da Tela de Acordo com Cabeçalho, Grid e Rodape
If aCposCab != NIL
	nYGrid -= 30
	nYFoot -= 30
EndIf

If lGD
	nYCab 	-= 50
	nYFoot	-= 50
EndIf	

If lRodape
	nYCab 	-= 20
	nYGrid	-= 20
EndIf

If(aCposCab != NIL,oSize:AddObject('HEADER',100, nYCab ,.T.,.T.),oSize:AddObject('HEADER',0,0,.T.,.T.))
If(lGD            ,oSize:AddObject('GRID'  ,100, nYGrid,.T.,.T.),oSize:AddObject('GRID'  ,0,0,.T.,.T.))
If(lRodape        ,oSize:AddObject('FOOTER',100, nYFoot,.T.,.T.),oSize:AddObject('FOOTER',0,0,.T.,.T.))

oSize:lProp 		:= .T. // Proporcional             
oSize:aMargins 	:= { 3, 3, 3, 3 } // Espaco ao lado dos objetos 0, entre eles 3 
oSize:Process()

aCSbx	  := {oSize:GetDimension("HEADER","LININI"),oSize:GetDimension("HEADER","COLINI"),oSize:GetDimension("HEADER","YSIZE"), oSize:GetDimension("HEADER","XSIZE")}
aCGD	  := {oSize:GetDimension("GRID","LININI"),oSize:GetDimension("GRID","COLINI"),oSize:GetDimension("GRID","LINEND"), oSize:GetDimension("GRID","COLEND")}

Default nOpcx	  := 3
Default cFldOK    := ".T."
Default cLineOk   := "AlwaysTrue()"
Default cAllOk	  := "AlwaysTrue()"
Default nCount	  := 0
Default lDelGetD  := .T.
Default cIniLin   := NIL
Default nMax      := 99
Default __aTeclas := {}
Default __cFunOk  := "AlwaysTrue()"
Default __cFunCanc:= "__ModxGenCancel()"
Default __cDelOk  := "AlwaysTrue()"
Default cOnInit   := ".T."
Default lEnchBar  := .T.
Default lEndWnd   := .T.

If Type("lLocxAuto") == "U"
	lLocxAuto := .F.
EndIf

xTitulo	:= cTitulo + " - " + (	IIf( nOpcx == 2, Upper(STR0020),; 
								IIf( nOpcx == 3, Upper(STR0019),;
								IIf( nOpcx == 4, Upper(STR0023),; 
								IIf( nOpcx == 5, IIf( !IsInCallStack("LocXAnula"), Upper(STR0021), Upper(STR0022) ),;
													"" ) ) ) ) )

bFunOk    :=&("{||" + __cFunOk   + "}")
bFunCancel:=&("{||" + __cFunCanc + "}")
bOnInit   :=&("{||" + cOnInit    + "}")

__cFldOk  := cFldOK
__cLineOk := cLineOK
__nOpcx	  := nOpcx
cFunDelOk := __cDelOk
If Type("aRotina") == "A"
	aSvRot := aClone(aRotina)
	For nX := Len(aSvRot) to 9
		AADD(aRotina,{"","",0,nOpcx})
	Next
Else
	aRotina := {}
	For nX := 1 to 10
		AADD(aRotina,{"","",0,nOpcx})
	Next
EndIf

If Len(__aTeclas) > 0
	AEval(__aTeclas,{|x| SetKey(x[1],x[2])})
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Ponto de Entrada para alterar o numero maximo de itens da GetDados ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If ExistBlock('LOCXITEM')
	nMaxPE:=ExecBlock("LOCXITEM",.F.,.F.,{nMax,FunName()})
	If Valtype(nMaxPE)=="N"
		nMax := nMaxPE
	EndIf
Endif	
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Tratamento da Rotina Automatica                 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If isblind()
	lLocxAuto := .T.
Endif 
If (!lLocxAuto )

	DEFINE MSDIALOG oDlgDocFis TITLE OemToAnsi(xTitulo) FROM aCordW[1],aCordW[2] TO aCordW[3],aCordW[4] PIXEL OF oMainWnd VBX
	
	AAdd(__aObjs, oDlgDocFis)
	i:=0
	If aObjs!=NIL
		For i:=1 to Len(aObjs)
			If Len(aObjs[i]) < 3 .Or. aObjs[i][3] <> 2
				oObj:=&(aObjs[i,2])
				&(aObjs[i,1]):=oObj
				AAdd(__aObjs,oObj)
		    Endif
		Next i
	EndIf
	
	If aParHead!=NIL
		ASize(aParHead,SHnMax)
		//Se forem informados Alias + aCpos, passa aCposCab como campos externos para serem adicionados
		If aParHead[SHaCposExt]==NIL .And. aCposCab!=NIL .And. Len(aCposCab)>0
			aParHead[SHaCposExt]:=AClone(aCposCab)
		Endif
		aCposCab:=LocxHead(aParHead[SHcAlias],aParHead[SHlMark],aParHead[SHaCpos],aParHead[SHaCposNo],aParHead[SHaCposExt],aParHead[SHaPEHeader],aParHead[SHlConsUso])[1]
	Endif
	
	If !Empty(aCposCab) .And. aCGD[1] >= 40 // verifica se existem campos a serem criados, e se a GetDados não vai sobrepo-los.
		AEval(aCposCab,{|x| If(Len(x) < ScObjPai .Or. Empty(x[ScObjPai]),lCabec:=.T.,)})
		If lCabec 
			oSbx:= TScrollBox():New(oDlgDocFis, aCSbx[1],aCSbx[2],aCSbx[3],aCSbx[4],.T.,.T.,.T.)
			AAdd(__aObjs,oSbx)
		EndIf
		cPai := ""
		For i:=1 to Len(aCposCab)
			&("M->" + aCposCab[i][ScCampo]):=NIL
			_aGet:=LocxGet(aCposCab[i],"oSBx",nOpcx)
			If ValType(_aGet[1])=="O"
				AAdd(__aoGets,_aGet[1]) 
			Endif
			If ValType(_aGet[2])=="A"
				AAdd(aCposObrig,_aGet[2])
			Endif
		Next
		If Len(__aoGets) > 0 
			__aoGets[1]:SetFocus()
		EndIf
	EndIf

	If lGD
		If aParGrid !=NIL
			aSize(aParGrid,SCnMax)
			aRetGrid:=LocxGrid(aParGrid[SCcAlias],aParGrid[SCcWhile],aParGrid[SCc_CondIf],aParGrid[SClMark],;
			aParGrid[SCcCMarca],aParGrid[SCcSeek],aParGrid[SCnInd],aParGrid[SCaCpos],;
			aParGrid[SCaCposNo],aParGrid[SCaCposExt],aParGrid[SCaPECols],aParGrid[SCaPEHeader],aParGrid[SClConsUso],,aOrdItem)
			
			If !Empty(aRetGrid) .And. ValType(aRetGrid)=="A" .And. Len(aRetGrid)>0
				aCols  :=aRetGrid[5]
				aHeader:=aRetGrid[1]
				aRecnos:=aRetGrid[6]
			EndIf
			If !Empty(cIniLin)
				For nIaHead := 1 to Len(aHeader)
					nPosAt:=At(UPPER(AllTrim(aHeader[nIaHead][2])),cIniLin)
					If nPosAt>0
						If Substr(cIniLin,nPosAt-1,1)=="+"
							AEval(aCols,{|x| x[nIaHead]:=IIf(aHeader[nIaHead][8]=="C",Soma1(x[nIaHead]),x[nIaHead]++)})
						Endif
					Endif
				Next
			Endif
		Endif
		If Type("aCols")!="U" .And. Type("aHeader")!="U"
			oGetDados:=MSGetDados():New(aCGD[1],aCGD[2],aCGD[3]-20,aCGD[4],nOpcX,"__ModLinOK()","AlwaysTrue()",cIniLin,lDelGetD,aGetsGD,,,nMax,"__ModFldOk()",,,Iif(lDelGetD,"__ModDelOk()",Nil),)
			AAdd(__aObjs,oGetDados)			
		   	If IsInCallStack("MATA120") .And. Type('lPasMCV')!="U" .And. ValType(lPasMCV)=="L" .And. lPasMCV
					N := 1
			Endif
		EndIf
	Endif
	If aParRod!=NIL
		ASize(aParRod,SHnMax)
		//Se forem informados Alias + aCpos, passa aCposRod como campos externos para serem adicionados
		If aParRod[SHaCposExt]==NIL .And. aCposCab!=NIL .And. Len(aCposCab)>0
			aParRod[SHaCposExt]:=AClone(aCposCab)
		Endif
		aCposRod:=LocxHead(aParRod[SHcAlias],aParRod[SHlMark],aParRod[SHaCpos],aParRod[SHaCposNo],aParRod[SHaCposExt],aParRod[SHaPEHeader],aParRod[SHlConsUso])[1]
	Endif
	i:=1
	If aCposRod!=NIL
		lSbx:=.F.
		AEval(aCposRod,{|x| If(Len(x) < ScObjPai .Or. Empty(x[ScObjPai]),lSbx:=.T.,)})
		If lSbx
			oSbxRod:= TScrollBox():New(oDlgDocFis,aCGD[3]+2,aCSbx[2],aCSbx[3],aCSbx[4],.T.,.F.,.T.)
			AAdd(__aObjs,oSbxRod)
		EndIf
		aCoord:={}
		For i:=1 to Len(aCposRod)
			&("M->" + aCposRod[i][ScCampo]):=NIL
			_aGet:=LocxGet(aClone(aCposRod[i]),"oSBxRod",nOpcx)
			If ValType(_aGet[1])=="O"
				AAdd(__aoGets,_aGet[1])
			Endif
			If ValType(_aGet[2])=="A"
				AAdd(aCposObrig,_aGet[2])
			Endif
		Next
	EndIf
	
	ModxAtuObj()
	If lEnchBar
		If aScan(oDlgDocFis:ACONTROLS,{|x| x:CREADVAR == "M->F2_CLIENTE"}) > 0
			oDlgDocFis:ACONTROLS[aScan(oDlgDocFis:ACONTROLS,{|x| x:CREADVAR == "M->F2_CLIENTE"})]:SetFocus()
		ElseIf aScan(oDlgDocFis:ACONTROLS,{|x| x:CREADVAR == "M->F1_FORNECE"}) > 0
			oDlgDocFis:ACONTROLS[aScan(oDlgDocFis:ACONTROLS,{|x| x:CREADVAR == "M->F1_FORNECE"})]:SetFocus()
		EndIf
		ACTIVATE MSDIALOG oDlgDocFis ON INIT (EnchoiceBar(oDlgDocFis,{|| __lOk:=Iif ( ValidQtd(),(__ModxOk(bFunOk,cAllOk,aCposObrig,lEndWnd,,aRetGrid)),.F.) },{|| Eval(bFunCancel),oDlgDocFis:End() },,__aBotoes,,,,.F.),Eval(bOnInit),ModxAtuObj()) CENTERED
	Else
		ACTIVATE MSDIALOG oDlgDocFis ON INIT (Eval(bOnInit),ModxAtuObj()) CENTERED
	EndIf

	If Len(__aTeclas) > 0
		AEval(__aTeclas,{|x| SetKey(x[1],NIL)})
	EndIf
	
	If IsInCallStack("MATA465N") .And. !__lOk .And. lA465CANC
		lA465CANC:= ExecBlock("A465CANC",.F.,.F.,aCfgnf[8])
	EndIf	
Else
	i:=0
	If aObjs!=NIL
		For i:=1 to Len(aObjs)
			If Len(aObjs[i]) < 3 .Or. aObjs[i][3] <> 1
				oObj:=&(aObjs[i,2])
				&(aObjs[i,1]):=oObj
			Endif	
		Next i
	EndIf

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Acerta o tamanho da aCposCab³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If aCposCab!=NIL
		Aeval(aCposCab,{|x| ASize(x,nMaxPar)})
	Endif
	If aParHead!=NIL
		ASize(aParHead,SHnMax)
		//Se forem informados Alias + aCpos, passa aCposCab como campos externos para serem adicionados
		If aParHead[SHaCposExt]==NIL .And. aCposCab!=NIL .And. Len(aCposCab)>0
			aParHead[SHaCposExt]:=AClone(aCposCab)
		Endif
		aCposCab:=LocxHead(aParHead[SHcAlias],aParHead[SHlMark],aParHead[SHaCpos],aParHead[SHaCposNo],aParHead[SHaCposExt],aParHead[SHaPEHeader],aParHead[SHlConsUso])[1]
	Endif

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Monta, Valida e Executa Gatilhos dos Campos do Cabecalho³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If !Empty(aCposCab) // verifica se existem campos a serem criados
		For i:=1 to Len(aCposCab)
		// Popular a variavel cArquivo
			If !Empty(aCposCab[i][ScArquivo])
				cArquivo:=aCposCab[i][ScArquivo]
			Else
				cArquivo:=GetSx3Cache(aCposCab[i][ScCampo], "X3_ARQUIVO")
			EndIf

			// Verifica a existencia do campo
			if empty(cArquivo)
				&("M->" + aCposCab[i][ScCampo]):= NIL
			elseif !Empty(GetSx3Cache(aCposCab[i][ScCampo], "X3_CAMPO"))
				&("M->" + aCposCab[i][ScCampo]):= Criavar( aCposCab[i][ScCampo])
    		endif
	
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Executa Incializacao Padrao                      ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If Type("aCposCab[i,"+Alltrim(Str(SbInitPad))+"]")=="B"
				&("M->" + aCposCab[i][ScCampo]):= EVAL(aCposCab[i,SbInitPad],aCposCab[i][ScCampo] )			
			Endif
			cVar := Upper(AllTrim(aCposCab[i,ScCampo]))
			__READVAR := "M->"+cVar

			LocxGet(aCposCab[i],,nOpcx,,.T.)			
		Next i
		
		For i:=1 to Len(aCposCab)
			If (nPosAuto	:=	Ascan(aAutoCab,{|x| alltrim(x[1]) == Alltrim(aCposCab[i,ScCampo]) })) > 0
				cVar := Upper(AllTrim(aCposCab[i,ScCampo]))
				aDadSX3	:= LocxGetSX3(aCposCab[i,ScCampo])
				__READVAR := "M->"+cVar

				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³Valida o campo se nao for exclusao               ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				If nOpcx <> 5 
					aDadSX3	:= LocxGetSX3(aCposCab[i,ScCampo])
					If aCposCab[i,ScWhen] <> NIL 
                    	cWhen	:=	aCposCab[i,ScWhen]
                    Else
						cWhen	:=	aDadSX3[4]
					Endif
					//
					// Campos FORNECE,LOJA,DOCUMENTO E SERIE estao so' para visualizacao
					// por isso nao entra no IF pela validacao de cWhen e nao grava os valores de 
					// aAutoCab em aGetsAuto, mesmo aAutoCab possuindo os valores
					//
					If Empty(cWhen).Or. &(cWhen) .Or. ;
					( lLocxAuto .And. cVar $ ("F1_FORNECE/F1_LOJA/F1_DOC/F1_SERIE") )
						&(__READVAR) := aAutoCab[nPosAuto,2]
						cValid	:=	".T."
						If aCposCab[i,ScValid] == NIL
							If !Empty(aDadSX3[1]+aDadSX3[2])
								If Empty(aDadSX3[1])
									cValid	:=	aDadSX3[2]
								ElseIf Empty(aDadSX3[2])	
									cValid	:=	aDadSX3[1]
								Else	
									cValid	:=	aDadSX3[1]+".And."+aDadSX3[2]
								Endif
							Endif
							If aDadSX3[3] == "S" .And. lAutoOk
								RunTrigger(1,,,,Padr(cVar,10))
							Endif							
						Else
							cValid := If(Empty(aCposCab[i,ScValid]),".T.",aCposCab[i,ScValid])
						EndIf
						
						If !(lRet := &(cValid))
							//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
							//³Grava Log - Cabecalho          ³
							//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
							MsLogLocxM(aAutoCab,cVar,.T.)
							lAutoOk	:=	.F.
							Exit
						EndIf
					EndIf
					
				Else
					&(__READVAR) := aAutoCab[nPosAuto,2]
				Endif	
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³Executa gatilhos se nao for exclusao             ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				AADD(aGetsAuto, cVar) 
			Endif
		Next
	EndIf

	If lGD .And. lAutoOk
		If aParGrid !=NIL
			aSize(aParGrid,SCnMax)
			aRetGrid:=LocxGrid(aParGrid[SCcAlias],aParGrid[SCcWhile],aParGrid[SCc_CondIf],aParGrid[SClMark],;
			aParGrid[SCcCMarca],aParGrid[SCcSeek],aParGrid[SCnInd],aParGrid[SCaCpos],;
			aParGrid[SCaCposNo],aParGrid[SCaCposExt],aParGrid[SCaPECols],aParGrid[SCaPEHeader],aParGrid[SClConsUso],,aOrdItem)
			
			If !Empty(aRetGrid) .And. ValType(aRetGrid)=="A" .And. Len(aRetGrid)>0
				aCols  :=aRetGrid[5]
				aHeader:=aRetGrid[1]
				aRecnos:=aRetGrid[6]
			EndIf
			If !Empty(cIniLin)
				For nIaHead := 1 to Len(aHeader)
					nPosAt:=At(UPPER(AllTrim(aHeader[nIaHead][2])),cIniLin)
					If nPosAt>0
						If Substr(cIniLin,nPosAt-1,1)=="+"
							AEval(aCols,{|x| x[nIaHead]:=IIf(aHeader[nIaHead][8]=="C",Soma1(x[nIaHead]),x[nIaHead]++)})
						Endif
					Endif
				Next
			Endif
		Endif
		If Type("aCols")!="U" .And. Type("aHeader")!="U" .And. !lFacImport
			if Type("cFunName") <> "U"
				cFunOrig := cFunName
			endif

			If Type("aAutoCab") <> "U" .And. Len(aAutoCab) > 0
				If Subs(aAutoCab[1,1], 1, 2) == "F2"
					nPosEsp := Ascan(aAutoCab,{|x| x[1] == alltrim("F2_ESPECIE")})
				Else
					nPosEsp := Ascan(aAutoCab,{|x| x[1] == alltrim("F1_ESPECIE")})
				Endif
			Endif

			If !MsGetDAuto(aAutoItens,"__ModLinOK()",{|| AlwaysTrue()},aAutoCab,nOpcx)
				lAutoOk	:=	.F.
			EndIf

			if Type("aAutoCab") <> "U" .And. Len(aAutoCab) > 0 .And. nPosEsp > 0 .And. AllTrim(aAutoCab[nPosEsp][2]) $ "NF|NDC|NCC|NDE|NCE" .And. LxFuncUser()
				cFunName := cFunOrig
			endif

			//Ajuste por problema en aCols al realizar devolución en LOCXNF
			If cPaisLoc == "EUA" .And. FunName() == 'MATA475' .And. ;
				aScan(aHeader,{|x| AllTrim(x[2]) == "D1_NFORI"	} ) > 0 .And.;
				aScan(aHeader,{|x| AllTrim(x[2]) == "D1_SERIORI"	}) > 0  .And. ;
				aScan(aHeader,{|x| AllTrim(x[2]) == "D1_ITEMORI"	} ) > 0
				
				For nCols := 1 to Len(aCols)
					aCols[nCols,aScan(aHeader,{|x| AllTrim(x[2]) == "D1_NFORI"	} )] 		:= aAutoItens[nCols,6,2]
					aCols[nCols,aScan(aHeader,{|x| AllTrim(x[2]) == "D1_SERIORI"	} )] 	:= aAutoItens[nCols,7,2]
					aCols[nCols,aScan(aHeader,{|x| AllTrim(x[2]) == "D1_ITEMORI"	} )] 	:= aAutoItens[nCols,8,2]
				Next nCols
			EndIf

			If !lAutoOk
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³Grava Log - Cabecalho/Itens    ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				MsLogLocxM(aAutoCab,cVar,.F.)
			Endif
		EndIf
	Endif
	If lAutoOk
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Acerta o tamanho da aCposRod³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If aCposRod!=NIL
			Aeval(aCposRod,{|x| ASize(x,nMaxPar)})
 		Endif
		If aParRod!=NIL
			ASize(aParRod,SHnMax)
			//Se forem informados Alias + aCpos, passa aCposRod como campos externos para serem adicionados
			If aParRod[SHaCposExt]==NIL .And. aCposCab!=NIL .And. Len(aCposCab)>0
				aParRod[SHaCposExt]:=AClone(aCposCab)
			Endif
			aCposRod:=LocxHead(aParRod[SHcAlias],aParRod[SHlMark],aParRod[SHaCpos],aParRod[SHaCposNo],aParRod[SHaCposExt],aParRod[SHaPEHeader],aParRod[SHlConsUso])[1]
		Endif

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Monta, Valida e Executa Gatilhos dos Campos do Rodape
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		i:=1
		If aCposRod!=NIL .And.!Empty(aCposRod)		
			For i:=1 to Len(aCposRod)
				If !Empty(GetSX3Cache(aCposRod[i][ScCampo], "X3_CAMPO"))	
					&("M->" + aCposRod[i][ScCampo]):= Criavar( aCposRod[i][ScCampo])
    			Else
					&("M->" + aCposRod[i][ScCampo]):=NIL
				Endif
	
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³Executa Incializacao Padrao                      ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				If Type("aCposRod[i,"+Alltrim(Str(SbInitPad))+"]")=="B"
					&("M->" + aCposRod[i][ScCampo]):= EVAL(aCposRod[i,SbInitPad],aCposRod[i][ScCampo] )			
				Endif

				cVar := Upper(AllTrim(aCposRod[i,ScCampo]))
				__READVAR := "M->"+cVar
				LocxGet(aCposRod[i],,nOpcx,,.T.)							
			Next                     
			
			For i:=1 to Len(aCposRod)
				If !(cPaisLoc $ "COL|MEX|CHI|PER|PAR|ARG|URU|EQU|EUA")
					cValid := ""
				EndIf
				If (nPosAuto	:=	Ascan(aAutoCab,{|x| Alltrim(Upper(x[1])) == Alltrim(Upper(aCposRod[i,ScCampo])) })) > 0
					cVar := Upper(AllTrim(aCposRod[i,ScCampo]))
					__READVAR := "M->"+cVar
					LocxGet(aCposRod[i],,nOpcx,,.T.)
					&(__READVAR) := aAutoCab[nPosAuto,2]
					
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³valida o campo se nao for exclusao               ³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					If nOpcx <> 5 
						cValid	:=	".T."
						If aCposRod[i,ScValid] == NIL 
							aDadSX3	:= LocxGetSX3(aCposRod[i,ScCampo])
							If aCposRod[i,ScWhen] <> NIL .AND.  IIf(!(cPaisLoc $ "COL|MEX|CHI|PER|PAR|ARG|URU|EQU|EUA"), aCposRod[i,ScWhen] <> ".F.", .T.)
		                    	cWhen	:=	aCposRod[i,ScWhen]
		                    Else
								cWhen	:=	aDadSX3[4]
							Endif
							If Empty(cWhen).Or. &(cWhen)
								&(__READVAR) := aAutoCab[nPosAuto,2]
								If !Empty(aDadSX3[1]+aDadSX3[2])
									If Empty(aDadSX3[1])
										cValid	:=	aDadSX3[2]
									ElseIf Empty(aDadSX3[2])	
										cValid	:=	aDadSX3[1]
									Else	
										cValid	:=	aDadSX3[1]+".And."+aDadSX3[2]
									Endif
								Endif	
								If aDadSX3[2] == "S" .And. lAutoOk
									RunTrigger(1,,,,Padr(cVar,10))
								Endif								
							Endif
						Else
							cValid := If(Empty(aCposRod[i,ScValid]),".T.",aCposRod[i,ScValid])
						EndIf
						
						If !(lRet := &(cValid))
							//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
							//³Grava Log - Rodape             ³
							//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
							MsLogLocxM(aAutoCab,cVar,.T.)
							lAutoOk	:=	.F.
							Exit
						EndIf
					Else
						&(__READVAR) := aAutoCab[nPosAuto,2]					
					EndIf
					
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³Executa gatilhos se nao for exclusao             ³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					AADD(aGetsAuto, cVar)
				Endif
			Next
		EndIf
	Endif	

		IF cPaisLoc=="COL".and. (Type("cFunName") <> "U") .and. LxFuncUser() .and. (cFunOrig!=cFunName) 
			cFunName:=cFunOrig//cFunOrig mantiene el origen del fuente
		EndiF

	AEval(aGetsAuto,{|x| AAdd(__aCpTela,{x,&("M->"+x) })})

	Eval(bOnInit)
	If lAutoOk .And. !Eval({|| __lOk:=__ModxOk(bFunOk,cAllOk,aCposObrig,.F.,.F.) })
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Grava Log - TudOK              ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		MsLogLocxM(aAutoCab,cVar,.T.)
		lAutoOk	:= .F.
	Endif    	
Endif
If aSvRot != Nil
	aRotina := aClone(aSvRot)
Endif
dbSelectArea(aArea[1])
dbSetOrder(aArea[2])
dbGoto(aArea[3])

Return (__lOk)

Static Function __ModxOk(bFunOk,cAllOk,aCposObrig,lEndWnd,lLineOk)
Local lOk := .T.
Local aArea := {}

lOk:=__ModAllOk(cAllOk,aCposObrig,lLineOk)

aAreaAt := GetArea()
DbSelectArea('SA4')
SA4->(DbSetOrder(1))
If cPaisLoc == "ARG" .And. SF2->(ColumnPos("F2_VEHICL")) > 0 .And. FunName() == "MATA462N"
	If !Empty(SF2->F2_VEHICL) .and. Empty(SF2->F2_TRANSP)
		Alert(STR0024) //"Debe asignarse una Transportadora"
		lOk := .F.
	ElseIf DbSeek(xFilial("SA4") + SF2->F2_TRANSP) .And. Empty(SF2->F2_VEHICL)
		If SA4->A4_CGC == SM0->M0_CGC
			Alert(STR0025) //"Debe agregarse un Vehículo"
			lOk := .F.		
		EndIf		
	EndIf
EndIf 
RestArea(aAreaAt)

If lOk
	Eval(bFunOk)
	If lEndWnd
		oDlgDocFis:End()
	EndIf
EndIf

Return lOk

//------------------------------------------------------------------------------------------------------------------------------------------------------------------------
Function __ModLinOK()
Local lRet:=.t. , ni

If Alltrim(Str(__nOpcx,1,0))$"346" .And. !Empty(__cLineOK)
	lRet := &(__cLineOK)
	ModxAtuObj()
EndIf
Return lRet

//------------------------------------------------------------------------------------------------------------------------------------------------------------------------
Static Function __ModAllOk(cAllOk,aCposObrig,lLineOk)
Local lRet:=.T.
Local nI :=0

DEFAULT lLineOk	:=	.T.

Private aCpos:=aCposObrig

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³O parametro lLineOk foi criado, porque na rotina automatica e preciso ³
//³validar os obrigatorios e o TudoOk                                    ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If lLineOk
	lRet := __ModLinOK()
Endif
	
If lRet .And. Len(aCposObrig)>0
	For nI:=1 to Len(aCposObrig)
		If Len(aCposObrig[nI])>0 .And. Eval(aCposObrig[nI][2]) .And. Empty(&(aCposObrig[nI][1])) .And. __nOpcx <> 5 
			lRet:=.F.
         Aviso(STR0014,STR0015 + AllTrim(aCposObrig[nI][3]) + STR0016,{STR0013}) //"OK"###"AO"###"O Campo "###" deve ser preenchido."###"OK"
			Exit
		EndIF
	Next nI
Endif
If lRet .And. !Empty(cAllOk)
	lRet := &cAllOk
EndIf
Return lRet

//----------------------------------------------------------------------------------------------------------------------------------------------------------------
Function __ModFldOk()
Local ni
Local lRet:=.T.
Local cFieldEdit	:= SubStr(ReadVar(),4,Len(ReadVar()))

If lRet := &__cFldOk
	For ni:= 1 to Len(__aoGets)
		__aoGets[ni]:Refresh()
	Next
EndIf

If lRet
	For ni:= 1 to Len(__aoGets)
		__aoGets[ni]:Refresh()
	Next
EndIf

Return lRet

//--------------------------------------------------------------------------------------------------------------------------------------------------------------
Function __ModDelOk()
Local ni
Local lRet:=.T.

lRet := &(cFunDelOk)
For ni:= 1 to Len(__aoGets)
	__aoGets[ni]:Refresh()
Next
Return lRet

//---------------------------------------------------------------------------------------------------------------------------------------------------------------
Function LocxTrigger(cCpoTrigger)
Iif(ExistTrigger(cCpoTrigger),RunTrigger(1),)
ModxAtuObj()
Return .T.

//---------------------------------------------------------------------------------------------------------------------------------------------------------------
Function LocX3VALID(cCampo)
Local __cVld := ""
Local cX3_VALID := ""
Local cX3_VLDUSER := ""

// Não se pode retirar esta linha devido a maioria das chamadas a LOCX3VALID não passar o campo no parametro
// e considerar que o registro esta posicionado quando da revisão da LOCXNF esta situação deve ser corrigida.
Default cCampo := SX3->X3_CAMPO

If cCampo != NIL
	cX3_VALID := GetSx3Cache(cCampo, "X3_VALID")
	cX3_VLDUSER := GetSx3Cache(cCampo, "X3_VLDUSER")

	__cVld:=IIf(!Empty(cX3_VALID),Alltrim(cX3_VALID),"")
	__cVld+=IIf(!Empty(__cVld),Iif(!Empty(cX3_VLDUSER)," .And. ",""),"")+ Alltrim(cX3_VLDUSER)
endif

Return __cVld

//------------------------------------------------------------------------------------------------------------------------------------------------------------------
Function ModxAtuObj(lAtuGetd)
Local lAutomato := IsBlind()

DEFAULT lAtuGetd	:=	.T.

__aCpTela:={}
If Type("oGetDados")!= "U" .And. ValType(oGetDados)=="O" .And. lAtuGetd .And. !lAutomato
	oGetDados:oBrowse:Refresh()
Endif
If Type("__aoGets")!= "U" .And. ValType(__aoGets)=="A" 
	AEval(__aoGets,{|x| x:Refresh(),AAdd(__aCpTela,{IIf(Left(x:cReadVar,3)=="M->",Substr(x:cReadVar,4),x:cReadVar),IIf(ValType(x:Cargo)=="B",EVAL(x:Cargo,x),&(x:cReadVar))})})
EndIf
Return .T.

/*---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³LocxHead  ºAutor  ³Guilherme C. Leal   º Data ³  05/27/01   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Monta Cabecalho                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Generico                                                   º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function LocxHead(cAlias,lMark,aCposYes,aCposNo,aCposExt,aPEHeader,lConsUso,lNewGetDados)

#Define ScFimAHeader 1
#Define SnPEHeader 1  // Numero de Pontos de Entrada da Funcao


//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Parametros Recebidos pela funcao                      ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ 1. cAlias 	- Arquivo onde buscar as informacoes.                  										³
//³ 2. lMark 	- Se usa Marca (somente para ListBox).                 										³
//³ 3. aCposYes 	- Campos utilizados (somente os validos).              										|
//³ 4. aCposNo 	- Campos que NAO devem aparecer.		              										|
//³ 5. aCposExt - Array contendo configuracoes de campos Externos ou Formulas								³
//³				     [n,1]  = Titulo do campo													            ³
//³                  [n,2]  = Nome do Campo												    	            ³
//³				     [n,3]  = Picture															            ³
//³				     [n,4]  = Tamanho															            ³
//³				     [n,5]  = Nao utilizado. Criado apenas para conpatibilizacao com o aHeader              ³
//³				     [n,6]  = Nao utilizado. Criado apenas para conpatibilizacao com o aHeader              ³
//³                  [n,7]  = Nao utilizado. Criado apenas para conpatibilizacao com o aHeader              ³
//³				     [n,8]  = Tipo do campo													                ³
//³			         [n,9]  = Nao utilizado. Criado apenas para conpatibilizacao com o aHeader              ³
//³                  [n,10] = Nao utilizado. Criado apenas para conpatibilizacao com o aHeader	            ³
//³                  [n,11] = Formula para o conteudo do campo									            ³
//³                  [n,12] = Coluna em que o campo sera visualizado							            ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Parametros Devolvidos pela funcao                     ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³1. aRet	-	Array contendo 6 arrays como descrito abaixo:												³
//³				[1] = Array com o aHeader                                                                   ³
//³				[2] = Array contendo somente campos validos dos que foram passados                          ³
//³				[3] = Array contendo Titulo dos campos validos                                              ³
//³				[4] = Array contendo Tamanho dos campos validos												³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Declaracao de variaveis³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Local aSavAHeader := IIf(Type("aHeader")=="A",aClone(aHeader),{})
Local aRet:= Array(4)		//Retorno da funcao
Local aTam:= {}			//Tamanho dos campos
Local aCab:= {}			//Titulo dos campos
Local aSeq:= {}			//Somente os campos validos
Local aCposAll:={}		//Campos padrao mais os campos enviados pelo párametro aCposExt
Local nS:=1			//auxiliar
Local nA:=1			//auxiliar
Local nX:=0			//auxliar
Local nG:=0
Local nI:=0

Local aSX3      := {}
Local _i        := 0
Local cX3_CAMPO
Local cX3_TAMANHO
Local cX3_PICTURE
Local cX3_TIPO
Local cX3_USADO
Local cX3_NIVEL
Local cX3_TITULO

If Empty(cAlias)
	//	Aviso(FunDesc(),"O Alias do arquivo deve ser informado",{"OK"})
	Return .F.
EndIf

Private nSel	:=0			//Conteudo do campo "Marca"
Private aHeader := {}

Default aPEHeader    := {}
Default lMark        := .F.
Default aCposYes     := {}
Default aCposNo      := {}
Default aCposExt     := {}
Default lConsUso     := .T.
Default lNewGetDados := .F.
ASize(aPEHeader,SnPEHeader)
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Verifica se foram passados campos especificos ou se deve montar de acordo com SX3³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If Len(aCposYes)==0
	aCposYes:={}
	If lMark
		//Adiciona campo de marca
		Aadd(aHeader, {"","nSel","",0,0,"","","","","","",})
		Aadd(aCposYes  ,"nSel")
		AAdd(aSeq	,"nSel")
		AADD(aCab	,"")
		AADD(aTam	,5)
	Endif
	//Buscando configuracoes do SX3
	aSX3 := FWSX3Util():GetAllFields(cAlias , .T.)
	for _i := 1 to len(aSX3)
		If (!lConsUso .Or. (x3uso(GetSx3Cache(aSX3[_i], "X3_USADO")) .And.;
		   cNivel >= GetSx3Cache(aSX3[_i], "X3_NIVEL"))) .And. ;
		   AScan(aCposNo,{ |x| Alltrim(x)==AllTrim(aSX3[_i])})==0
			AAdd(aCposYes,aSX3[_i])
		Endif
	next _i 
Else
	If lMark
		//Adiciona campo de marca
		Aadd(aHeader, {"","nSel","",0,0,"","","","","","",})
		Aadd(aCposYes  ,"")
		AAdd(aSeq	,"")
		AADD(aCab	,"")
		AADD(aTam	,0)
		//Montando campo de acordo com parametros enviados
		For nX:= Len(aCposYes) To 2 Step -1
			aCposYes[nX]:= aCposYes[nX-1]
		Next nX       
		aCposYes[1]:= "nSel"	
		aSeq[1]	:= "nSel"
		aCab[1]	:= ""
		aTam[1]	:= 5
	Endif
Endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Verifica parametro aCposExt para criacao de novos campos e junta estes campos com os campos ³
//³padrao dentro de um array so (aCposAll)  												   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
AEval(aCposYes,{|x|AAdd(aCposAll,{"",x,"",0,0,"","","","","","",})})
If aCposExt!=NIL .And. Len(aCposExt) > 0
	AEval(aCposExt,{|x,y|aSize(x,nMaxPar),If(x[ScPicture]==NIL,aCposExt[y][ScPicture]:="",)})
	nI := 0
	For nI:=1 to Len(aCposExt)
		If AScan(aCposAll,{|x| Alltrim(Upper(x[2]))==Alltrim(Upper(aCposExt[ni][2]))}) == 0
			If Empty(aCposExt[nI][12]) .Or. aCposExt[nI][12]>Len(aCposAll)
				AAdd(aCposAll,aCposExt[nI])
			Else
				aSize(aCposAll,Len(aCposAll)+1)
				AIns(aCposAll,aCposExt[nI][12])
				aCposAll[aCposExt[nI][12]] := aClone(aCposExt[nI])
			EndIf
		EndIf
	Next nI
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Montando aHeader (aHeader) e suas configuracoes de acordo com os campos do array aCposAll³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

//No caso de usar marca no list, o primeiro campo não deve ser consistido.
If lMark
	nS:=2
Else
	nS:=1
Endif
For nX:=nS to Len(aCposAll)
	//Verifica se o campo ja existe ou e um campo externo passado por parametro
	ASize(aCposAll[nX],nMaxPar)

	If !Empty(GetSx3Cache(aCposAll[nX][2], "X3_CAMPO"))
		cX3_USADO := GetSX3Cache(aCposAll[nX][2], "X3_USADO")
		cX3_NIVEL := GetSX3Cache(aCposAll[nX][2], "X3_NIVEL")
		cX3_CAMPO := GetSX3Cache(aCposAll[nX][2], "X3_CAMPO")
		cX3_TAMANHO := GetSX3Cache(aCposAll[nX][2], "X3_TAMANHO")
		cX3_PICTURE := GetSX3Cache(aCposAll[nX][2], "X3_PICTURE")
		cX3_TIPO := GetSX3Cache(aCposAll[nX][2], "X3_TIPO")
		If  !lConsUso .Or. (x3uso(cx3_usado) .And. cNivel >= cX3_NIVEL) .Or. AScan(aCposExt,{ |x| x[2] == aCposAll[nX][2] } ) > 0
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Se o campo foi encontrado no X3 e esta disponivel, adiciona no aHeader    ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			cX3_TITULO:=TRIM(FWX3TITULO(cX3_CAMPO))
			
			AAdd(aHeader,{cX3_TITULO,;
						cX3_CAMPO,;
						cX3_PICTURE,;
						cX3_TAMANHO,;
						GetSX3Cache(aCposAll[nX][2], "X3_DECIMAL"),; 
						GetSX3Cache(aCposAll[nX][2], "X3_VALID"),;
						cX3_USADO,;
						cX3_TIPO,;
						IIF(lNewGetDados, GetSX3Cache(aCposAll[nX][2], "X3_F3"), GetSX3Cache(aCposAll[nX][2], "X3_ARQUIVO")),;
						GetSX3Cache(aCposAll[nX][2], "X3_CONTEXT"),;
						aCposAll[nX][11]})
			
			ASize(aHeader[Len(aHeader)],nMaxPar)

			For nG:=1	To Min(Len(aCposAll[nX]),Len(aHeader[Len(aHeader)]))
				If !Empty(aCposAll[nX][nG])
					aHeader[Len(aHeader)][nG]	:=	aCposAll[nX][nG]
				Endif
			Next	
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Armazena em um array separado as sequencias do aCpos que realmente serao utilizadas,³
			//³para depois poder se referenciar aos campos.                                        ³
			//³Nao foi utilizado diretamente o aHeader pois esta rotina monta aHeader              ³
			//³e Cabecalho do ListBox, e seriam posicoes distintas do Array.                       ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			AAdd(aCab,cX3_TITULO)
			AAdd(aTam,CalcFieldSize(cX3_TIPO,Max(len(cX3_TITULO),cX3_TAMANHO),,cX3_PICTURE))
			AAdd(aSeq,cX3_CAMPO)
		Endif
	Else
		//Para a inclusao de um campo EXTERNO, consiste os campos de configuracao que sao obrigatorios
		If 	aCposAll[nX][1] != NIL .And. 	aCposAll[nX][1] != ""  .And. aCposAll[nX][4] != 0  .And.;
			aCposAll[nX][2] != NIL .And. aCposAll[nX][2] != "" .And.;
			aCposAll[nX][8] != NIL .And. aCposAll[nX][8] != "" .And.;
			aCposAll[nX][11]!= NIL .And. aCposAll[nX][11]!= ""
			AAdd(aHeader,aCposAll[nx])
			AAdd(aCab,aCposAll[nX][1])
			AAdd(aTam,Max(aCposAll[nX][4],Len(aCposAll[nX][1]))*4.1)
			AAdd(aSeq,aCposAll[nX][2])
		EndIf
	EndIf
Next nX

// Ponto de entrada a ser executado apos a criacao do aHeader.
If !Empty(aPEHeader[ScFimAHeader]) .And. ExistBlock(aPEHeader[ScFimAHeader])
	ExecBlock(aPEHeader[ScFimAHeader],.f.,.f.)
EndIf

aRet[1]:=aClone(aHeader)		// aHeader
aRet[2]:=aClone(aSeq)		// Array contendo somente campos validos dos que foram passados.
aRet[3]:=aClone(aCab)		// Array contendo Titulo dos campos validos.
aRet[4]:=aClone(aTam)		// Array contendo Tamanho dos campos validos.

aHeader := aClone(aSavAHeader)

Return(aRet)


/*--------------------------------------------------------------------------------------------------------------------------------------------------------------------------
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³LocxGrid  ºAutor  ³Guilherme C. Leal   º Data ³  05/27/01   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Monta Cabecalho e linhas dos Grids                         º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Generico                                                   º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function LocxGrid(cAlias,cWhile,c_CondIf,lMark,cCMarca,cSeek,nInd,aCpos,aCposNo,aCposExt,aPECols,aPEHeader,lConsUso,lSetM,aOrditem,lNewGetDados,lSdParc)

#Define ScLinACols 1
#Define ScFimACols 2

#Define SnPECols 2

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Parametros Recebidos pela funcao                      ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ 1. cAlias 	- Arquivo onde buscar as informacoes.                  										³
//³ 2. cWhile 	- Condicao inicial para o While.                       										³
//³ 3. c_CondIf	- Se .T. o registro sera inserido no aC.               										³
//³ 4. lMark 	- Se usa Marca (somente para ListBox).                 										³
//³ 5. cCMarca   - Se .T. o registro vem marcado.                      										³
//³ 6. cSeek 	- Registro inicial do while (performance).             										³
//³ 7. nInd     - Indice da Busca.                                     										³
//³ 8. aCpos 	- Campos utilizados (somente os validos).              										|
//³ 9. aCposNo 	- Campos que NAO devem aparecer.		              										|
//³10. aCposExt - Array contendo configuracoes de campos Externos ou Formulas								³
//³				     [n,1]  = Titulo do campo													            ³
//³                  [n,2]  = Nome do Campo												    	            ³
//³				     [n,3]  = Picture															            ³
//³				     [n,4]  = Tamanho															            ³
//³				     [n,5]  = Nao utilizado. Criado apenas para conpatibilizacao com o aHeader              ³
//³				     [n,6]  = Nao utilizado. Criado apenas para conpatibilizacao com o aHeader              ³
//³                  [n,7]  = Nao utilizado. Criado apenas para conpatibilizacao com o aHeader              ³
//³				     [n,8]  = Tipo do campo													                ³
//³			         [n,9]  = Nao utilizado. Criado apenas para conpatibilizacao com o aHeader              ³
//³                  [n,10] = Nao utilizado. Criado apenas para conpatibilizacao com o aHeader	            ³
//³                  [n,11] = Formula para o conteudo do campo									            ³
//³                  [n,12] = Coluna em que o campo sera visualizado							            ³
//³ 14. lSetM   	- Indica se deve inicializar as variaveis "M->"										    |
//³ 15. aOrdItem   	- array para ordenacao do aCols, a gosto do cliente										|
//³ 16. lNewGetDados- 																					    |
//³ 17. lSdParc   	- Indica se considera aCols salvo p/ abater saldo da qtde. dos itens de remitos         |
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Parametros Devolvidos pela funcao                     ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³1. aRet	-	Array contendo 6 arrays como descrito abaixo:												³
//³				[1] = Array com o aHeader                                                                   ³
//³				[2] = Array contendo somente campos validos dos que foram passados                          ³
//³				[3] = Array contendo Titulo dos campos validos                                              ³
//³				[4] = Array contendo Tamanho dos campos validos												³
//³				[5] = Array co o conteudo das linhas (aCols)                                                ³
//³				[6] = Array contendo os Recnos referentes a cada linha                                      ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Declaracao de variaveis³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Local aSavACols  := IIf(Type("aCols")=="A",AClone(aCols),{})
Local aSavAHeader:= IIf(Type("aHeader")=="A",AClone(aHeader),{})
Local aRet:= Array(6)		//Retorno da funcao
Local aTam:= {}			//Tamanho dos campos
Local aCab:= {}			//Titulo dos campos
Local aSeq:= {}			//Somente os campos validos
Local aRetHead:= {}		//Array de retornos da LocxHead
Local lAchou	:=.F.		//Indica se foram encontrados registros para o Array de dados (aC)
Local lContinua	:=.T.
Local aRecno	:={}		//Numero dos registros referentes as linhas
Local nS		:=1			//auxiliar
Local nA		:=1			//auxiliar
Local nX		:=0			//auxliar
Local cSeekSD1  := ""
Local nPosItem	:= 0		
Local cItemX 	:= ""
Local cItemY 	:= ""
Local bSorte	:= ""
Local nOrd		:= 0
Local nSdRemSv	:= 0
Local nQuantSv	:= Ascan(aSavAHeader,{|X| Alltrim(X[2]) ==  "D1_QUANT"  } )
Local nRemitoSv	:= Ascan(aSavAHeader,{|X| Alltrim(X[2]) ==  "D1_REMITO"  } )
Local nSeriRemSv:= Ascan(aSavAHeader,{|X| Alltrim(X[2]) ==  "D1_SERIREM"  } )
Local nItemRemSv:= Ascan(aSavAHeader,{|X| Alltrim(X[2]) ==  "D1_ITEMREM"  } )
Local nTipo		:= If(Type("aCfgNF")=="A",aCfgNF[1],0)
Local lConfFis		:= SuperGetMV("MV_CONFFIS",.F.,"N") == "S"
Local lRemDiv		:= SuperGetMV("MV_REMDIV",.F.,.F.)
Local lLinACols := .F.
Local lFimACols := .F.

If Empty(cAlias)
	//	Aviso(Fundesc(),"O Alias do arquivo deve ser informado",{"OK"})
	Return .F.
EndIf

Iif(Empty(cWhile)  ,cWhile   := NIL,)
Iif(Empty(c_CondIf),c_CondIf := NIL,)
Iif(Empty(cCMarca) ,cCMarca  := NIL,)
Iif(Empty(cSeek)   ,cSeek    := NIL,)

Default cWhile       := "!EOF()"
Default c_CondIf     := "AlwaysTrue()"
Default lMark        := .F.
Default cCMarca      := ".F."
Default cSeek        := "'|||'"
Default nInd         := 1
Default aPECols      := {}
Default lSetM	     :=	.T.
Default lNewGetDados := .F.
Default lSdParc	 	 :=	.F.

Private nSel  := 0     //Conteudo do campo "Marca"
Private aCols := {}
Private aHeader := {}

ASize(aPECols,SnPECols)

lLinACols := !Empty(aPECols[ScLinACols]) .And. ExistBlock(aPECols[ScLinACols])
lFimACols := !Empty(aPECols[ScFimACols]) .And. ExistBlock(aPECols[ScFimACols])

aRetHead:=LocxHead(cAlias,lMark,aCpos,aCposNo,aCposExt,aPEHeader,lConsUso,lNewGetDados)

aHeader:=aClone(aRetHead[1])
aSeq   :=aClone(aRetHead[2])
aCpos  :=aClone(aRetHead[2])
aCab   :=aClone(aRetHead[3])
aTam   :=aClone(aRetHead[4])

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Montando array com o conteudo das linhas aC (aCols)³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
DbSelectArea(cAlias)
If ValType(nInd) == "C" 
	DbOrderNickName(nInd)
Else
DbSetOrder(nInd)
EndIf
DbGotop()

//Verifica se existe chave de pesquisa para posicionar o arquivo em um certo registro inicial
If !Empty(cSeek)
	cSeekSD1 := &(cSeek)
	DbSeek(cSeekSD1,.F.)
EndIf
//Efetua varredura(loop) no arquivo de acordo com a condicao passado por parametro (cWhile)
While &(cWhile)
	//Verifica condicao para inclusao do registro nas linhas (c_CondIf)
	If &(c_CondIf) //.And. MsRLock(&(cAlias)->(Recno()))
		lContinua := .T.
		nSdRemSv  := 0
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Considera qtdes. de remitos parcialmente ja' selecionados no proprio aCols (origem) ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		
		If cAlias == "SD1" .And. IsInCallStack("SCMToNF") 
			SF1->(dbSetOrder(1))
			If (lConfFis .And. SF1->(dbSeek(xFilial("SF1")+SD1->D1_DOC+SD1->D1_SERIE+SD1->D1_FORNECE+SD1->D1_LOJA)) .And. !((SF1->F1_STATCON $ (Iif(lRemDiv,"1*2","1"))) .OR. EMPTY(SF1->F1_STATCON)))
				lContinua := .F.
			EndIf
		EndIf
		
		If lSdParc .And. nTipo == 10 .And. cAlias == "SD1" .And. nRemitoSv * nSeriRemSv * nItemRemSv > 0
			For nA:=1 to Len(aSavACols)
				If  aSavACols[nA,nRemitoSv]  == SD1->D1_DOC .And.;
					aSavACols[nA,nSeriRemSv] == SD1->D1_SERIE .And.;
					aSavACols[nA,nItemRemSv] == SD1->D1_ITEM .And.;
					!ATail( aSavACols[ nA ] )
                   nSdRemSv += aSavACols[nA,nQuantSv] 
				EndIf
			Next
			// Nao ha' saldo no item do remito a utilizar
			If (SD1->D1_QTDACLA - nSdRemSv) <= 0
				lContinua := .F.
			EndIf			
		EndIf
		If lContinua
			//Verifica condicao para que o registro venha marcado (cMarca)
			If lMark .And. Eval(&("{|| " + cCMarca + "}"))
				nSel:= 1
			Else
				nSel:= -1
			Endif
			lAchou:=.T.
			//Grava o registro nas linhas (aCols)
			AAdd(aCols,Array(Len(aHeader)+1))
			For nA:=1 to Len(aHeader)
				If !Empty(aHeader[nA][11])
					aCols[Len(aCols)][nA] := Eval(&("{||" + aHeader[nA][11]+ "}"))
				Else
					If !(aHeader[nA][10]=="V".or. (aHeader[nA][8]=="M" .and. !(cPaisLoc $ "COL|MEX|PER|DOM|EQU|EUA|ARG|BOL|CHI|PAR|URU")))
						aCols[Len(aCols)][nA] := Eval(&("{||" + aHeader[nA][2] + "}"))
					ElseIf cPaisLoc == "RUS" .And. aHeader[nA][2] == "F1_F5QDESC"
						aCols[Len(aCols)][nA] := Posicione("F5Q",1,XFILIAL("F5Q")+SF1->F1_F5QUID,"F5Q_DESCR")
					ElseIf cPaisLoc == "RUS" .And. aHeader[nA][2] == "F2_F5QDESC"
						aCols[Len(aCols)][nA] := Posicione("F5Q",1,XFILIAL("F5Q")+SF2->F2_F5QUID,"F5Q_DESCR")
					Else
						aCols[Len(aCols)][nA] := CriaVar(aHeader[nA][2])
					Endif
				EndIf
				If lSdParc .And. nTipo == 10 .And. cAlias == "SD1" .And. AllTrim(aHeader[nA][2]) == "D1_QTDACLA" .And. nSdRemSv > 0
					aCols[Len(aCols)][nA] -= nSdRemSv
				EndIf
				If lSetM
					&("M->"+aHeader[nA][2]) := aCols[Len(aCols)][nA]
				Endif
			Next
			aCols[Len(aCols)][nA]:=.F.
			//Guarda numero do registro refente a linha
			AAdd(aRecno,Recno())
			// Ponto de entrada a ser executado apos a criacao de cada linha do aCols.
			If lLinACols
				ExecBlock(aPECols[ScLinACols],.f.,.f.)
			EndIf
		Endif
	Endif
	DbSelectArea(cAlias)
	DbSkip()
Enddo

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Se nao encontrar nenhum registro, cria linha (aCols) em branco.³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If !lAchou
	aCols := Array(1,Len(aCpos)+1)
	If lMark
		aCols[1][1] := 0
		nS:=2
	Else
		nS:=1
	Endif
	For nA:=nS to Len(aHeader)
		If aHeader[nA][11] != NIL .And. aHeader[nA][11] != ""
			aCols[Len(aCols)][nA]   := Eval(&("{||" + aHeader[nA][11] + "}"))
		Else
			aCols[Len(aCols)][nA]   := CriaVar(aHeader[nA][2])
		EndIf
	Next
	aCols[Len(aCols)][nA]:=.F.
	
	// Ponto de entrada a ser executado apos a criacao de cada linha do aCols.
	If lLinACols
		ExecBlock(aPECols[ScLinACols],.f.,.f.)
	EndIf
	
Endif

// Ponto de entrada a ser executado apos a criacao do aCols.
If lFimACols
	ExecBlock(aPECols[ScFimACols],.f.,.f.)
EndIf

/*Opcao para ordenacao do aCols, a gosto do cliente*/
If ValType(aOrditem) != "U" .And. Len(aOrditem) > 0
	For nOrd := 1 To Len(aOrdItem)
		If (nPosItem := aScan(aHeader,{|x| Alltrim(x[2]) == aOrdItem[nOrd]})) > 0
			Do Case
				Case aHeader[nPosItem,8] == "D"
					cItemX += "dToS(x["+Alltrim(STR(nPosItem))+"])"
					cItemY += "dToS(y["+Alltrim(STR(nPosItem))+"])"
				Case aHeader[nPosItem,8] == "N"
					cItemX += "Str(x["+Alltrim(STR(nPosItem))+"],"+Alltrim(Str(aHeader[nPosItem,4]))+ "," + Alltrim(Str(aHeader[nPosItem,5]))+")"
					cItemY += "Str(y["+Alltrim(STR(nPosItem))+"],"+Alltrim(Str(aHeader[nPosItem,4]))+ "," + Alltrim(Str(aHeader[nPosItem,5]))+")"
				Case aHeader[nPosItem,8] == "C"
					cItemX += "x["+Alltrim(STR(nPosItem))+"]"
					cItemY += "y["+Alltrim(STR(nPosItem))+"]"
			EndCase

			If nOrd <> Len(aOrditem)
				cItemX += "+"
				cItemY += "+"
			EndIf
		Endif	
	Next    
	bSorte	:=  &("{ |x,y| " + cItemX + " < " + cItemY + "}")
	aSort(aCols,,,bSorte)
EndIf	
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Gravando variavel de retorno da funcao³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
aRet[1]:= aClone(aHeader)		// aHeader
aRet[2]:= aClone(aSeq)		// Array contendo somente campos validos dos que foram passados.
aRet[3]:= aClone(aCab)		// Array contendo Titulo dos campos validos.
aRet[4]:= aClone(aTam)		// Array contendo Tamanho dos campos validos.
aRet[5]:= aClone(aCols)		// Array com o conteudo das linhas (aCols)
aRet[6]:= aClone(aRecno)	// Array contendo o Recno referente a cada linha

aCols:=AClone(aSavACols)
aHeader:=AClone(aSavAHeader)

Return(aRet)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³LocxF4    ºAutor  |Leandro C.G.        º Data ³ 17/08/2001  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Monta tela de consulta com selecao de registros            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Generico                                                   º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Function LocxF4(cAOrig,nIndex,cWhile,cSeek,aCpos,aCposNo,cTitulo,cCondicao,lMarca,xMarcaOk,aCposExt,aButtons,cDblClick,lConsUso,lMultSel,lSdParc,lPurchInv)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Parametros Recebidos pela Funcao³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ 1.cAOrig    - Alias do arquivo que sera consultado                      							    			³
//³ 2.nIndex    - Indice do arquivo que sera consultado           										    			³
//³ 3.cWhile    - Condicao(Loop) sobre o arquivo consultado para dimensionar os registros que serao         ³
//³				  visualizados (passado para LOCXGRID)                                                      	³
//³ 4.cSeek     - Posiciona o arquivo no registro inicial do while (performance) (passado para LOCXGRID)    ³
//³ 5.aCpos     - Array apenas com os campos que devem ser visualizados (passado para LOCXGRID)			    	³
//³ 6.aCposNo   - Array apenas com os campos que NAO devem ser visualizados (passado para LOCXGRID)         ³
//³ 7.cTitulo   - Titulo da tela de consulta															    						³
//³ 8.cCondicao - Condicao feita dentro do while. Se .T. o registro sera mostrado (passado para LOCXGRID)   ³
//³ 9.lMarca    - Indica se havera marca para selecao de registros (passado para LOCXGRID)                  ³
//³10.xMarcaOk  - Condicao para que o regsitro ja venha marcado. Pode ser Boolean ou um texto condicional   ³
//³11.aCposExt  - Array contendo configuracoes de campos Externos 														³
//³				  [n,1]  = Titulo do campo													                					³
//³               [n,2]  = Nome do Campo													                					³
//³				  [n,3]  = Picture															                					³
//³				  [n,4]  = Tamanho															                					³
//³				  [n,5]  = Nao utilizado. Criado apenas para conpatibilizacao com o aHeader                 	³
//³				  [n,6]  = Nao utilizado. Criado apenas para conpatibilizacao com o aHeader                 	³
//³               [n,7]  = Nao utilizado. Criado apenas para conpatibilizacao com o aHeader                 ³
//³				  [n,8]  = Tipo do campo													                					³
//³			      [n,9]  = Nao utilizado. Criado apenas para conpatibilizacao com o aHeader                 ³
//³               [n,10] = Nao utilizado. Criado apenas para conpatibilizacao com o aHeader	               ³
//³               [n,11] = Formula para o conteudo do campo									                			³
//³               [n,12] = Coluna em que o campo sera visualizado							           				   ³
//³																																			³
//³12.aButtons  - Array contendo configuracoes de botoes que devem ser criados										³
//³				  [n,1]  = Titulo (Hint) do botao																				³
//³               [n,2]  = Nome do Bitmap do botao																				³
//³               [n,3]  = Funcao que sera executada pelo botao															³
//³14.lConsUso  - Indica se deve ser considerado o uso dos campos.                                          ³
//³16.lSdParc   - Usada na LocxGrid: Indica se considera aCols salvo p/ abater saldo de itens / remitos     ³
// 17.lPurchInv	- Prefix header table which will be created (.T. - F1, .F. - F2)(only for Russia)
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Parametros Devolvidos pela Funcao³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³NOTA:  Somente existe retorno quando a opcao de marca estiver acionada (lMarca = .T.), senao, retorna NIL³
//³																																			³
//³aRet	-	Array que retorna outros 3 arrays conforme descrito abaixo.													³
//³			[1] = array com o nome dos campos visualizados na mesma sequencia em que aparecem na tela       ³
//³			[2] = array com o conteudo de todos os registros selecionados de acordo com a sequencia da tela ³
//³			[3] = array contendo o Recno dos regsitros selecionados.                                        ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Declaracao de variaveis ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Local aRet      := array(3) 	//variavel devolvida pela funcao
Local nOpcao    := 1			//Indica se a hopuve confirmacao ou cancelamento
Local cMarcaOk  := ""       	//Espelho do parametro xMarcaOk so que em formato texto
Local aLinSel   := {}       	//apenas conteudo das linhas selecionadas
Local aRecnoSel := {}       	//apenas os recnos das linhas selecionadas
Local nLinhaSel := 0
Local aHeader   := {}       	//apenas o aHeader devolvido pela funcao LOCXGRID
Local aBut		 := {}
Local nI		:= 0
Local nX		:= 0
Local nCntPos as Numeric
Local nCurPos	 as Numeric
Local nConuniPos as Numeric
Local aHeadBro	:= {}
Local aPesq		:= {}
Local BMARK		:= {||}
Local BLDBLCLICK:= {||}
Local BHEADERCLI:= {||}
Local cHeadClic	:= ""
Local nAtSave	:= 0
Private aGrid   := {}  		//retorno da funcao LocxGRID que monta todos os dados para o list box
Private aTam    := {}       	//apenas o tamanho dos campos que aparecerao no list box
Private aLinha  := {}      	//conteudo dos campos de todas as linhas do list box
Private aCabec  := {}      	//apenas os titulos do cabecalho do list box
Private aCpVd   := {}      	//apenas os campos validos para o arquivo selecionado (considera parametros aCpos e aCposNo)
Private aRecno  := {}      	//guarda o numero dos registros referentes a todas as linhas do grid
Private aObtn   := {}
Private oOk     := LoadBitMap(GetResources(), "LBOK")        	// Bitmap utilizado no Lisbox  (Marcado)
Private oNo     := LoadBitMap(GetResources(), "LBNO")			// Bitmap utilizado no Lisbox  (Desmarcado)
Private oNever  := LoadBitMap(GetResources(), "DISABLE")		// Bitmap utilizado no Lisbox  (Desabilitado)


//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Consiste parametros e atribui padroes ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Default cSeek     := ""
Default cWhile    := "!Eof()"
Default lMarca    := .T.
Default xMarcaOk  := .F.
Default cCondicao := "AlwaysTrue()"
Default cMarcaOk  := ".F."
Default aCposExt  := {}
Default cTitulo   := FunDesc()
Default lMultSel  := .T.
Default lSdParc	  := .F.
DEFAULT lPurchInv := .F.

If cDblClick == Nil //Alexandre alterado para validacao dos locks em registros.
	cDblClick	:=	" aLinha[oLBCli:nAt,1] := LockClick(cAOrig,Agrid[6,oLBCli:nAt],aLinha,oLbCli,lMultSel) "
	cHeadClic	:=  " nAtSave:= oLBCli:nAt, AEval(aLinha,{|x,y| oLBCli:nAt := y, x[1] := LockClick(cAOrig,Agrid[6,oLBCli:nAt],aLinha,oLbCli,lMultSel)}), oLBCli:nAt:= nAtSave, oLBCli:Refresh()"
Else
	If cPaisLoc != "RUS" .or. lMarca
		cHeadClic	:=	"nAtSave:= oLBCli:nAt, AEval(aLinha,{|x,y| oLBCli:nAt := y, Iif("+cDblClick+", x[1] := LockClick(cAOrig,Agrid[6,oLBCli:nAt],aLinha,oLbCli,lMultSel),)}), oLBCli:nAt:= nAtSave, oLBCli:Refresh()"
		cDblClick	:=	"Iif("+cDblClick+",aLinha[oLBCli:nAt,1] := LockClick(cAOrig,Agrid[6,oLBCli:nAt],aLinha,oLbCli,lMultSel),)"
	EndIf
Endif
	
If aButtons <> NIL
	nI := 0
	For nI := 1 to Len(aButtons)
		If aButtons[nI,2] == NIL .Or. aButtons[nI,3] == NIL
			aButtons[nI] := NIL
		Else
			AADD(aOBtn,{})
		EndIf
	Next nI
EndIf
Default aButtons := {}
If Empty(cAOrig)
	Aviso(FunDesc(),OemToAnsi(STR0001) + "cAOrig)",{"OK"})
	Return()
EndIf
If nIndex == NIl
	Aviso(FunDesc(),OemToAnsi(STR0001) + "nIndex)",{"OK"})
	Return()
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³  Se forem passados os parametros aCpos e aCposNo simultaneamente ³
//³considera apenas o aCpos                                          ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If aCpos <> NIL .And. aCposNo <> NIL
	aCposNo := {}
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Atribui valor a variavel cMarcaOk segundo conteudo do parametro xMarcaOk.³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If ValType(xMarcaOk) == "L" .And. xMarcaOK
	cMarcaOk := "AlwaysTrue()"
ElseIf ValType(xMarcaOk) == "C" .And. !Empty(xMarcaOK)
	cMarcaOk := xMarcaOK
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Seleciona arquivo³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
DBSelectArea(cAOrig)
DBSetorder(nIndex)
DBGoTop()

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Verifica campos para estruturacao do cabecalho do list box³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
aGrid   := LocxGrid(cAOrig,cWhile,cCondicao,lMarca,cMarcaOk,cSeek,nIndex,aCpos,aCposNo,aCposExt,,,lConsUso,.F.,,,lSdParc)
aHeader := aClone(aGrid[1])
aCpVd   := aClone(aGrid[2])
aCabec  := aClone(aGrid[3])
aTam    := aClone(aGrid[4])
aLinha  := aClone(aGrid[5])
aRecno  := aClone(aGrid[6])

If len(aRecno)==0
	Help(" ",1,"A103F4")
	Return
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Definicao da tela                 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	oTlocxf4 := FwDialogModal():New()

    oTlocxf4:SetTitle(cTitulo)
    oTlocxf4:SetEscClose(.F.)
    oTlocxf4:enableAllClient()
    oTlocxf4:CreateDialog()

    oTlocxf4:EnableFormBar(.T.)
    oTlocxf4:CreateFormBar()

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Criacao dos Botoes³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If Len(aButtons) > 0
	nI := 0
	For nI := 1 to Len(aButtons)
		If Len(aButtons[nI]) == 3 .And. aButtons[nI][1] <> NIL .And. aButtons[nI][1] <> "" .And.;
			aButtons[nI][2] <> NIL .And. aButtons[nI][2] <> "" .And.;
			aButtons[nI][3] <> NIL .And. aButtons[nI][3] <> ""
		 	//Formata o Array a aBut para uso na enchoice
			Aadd(aBut,{"", aButtons[nI][1], IIf(SubStr(aButtons[nI][3],1,2)=="{|",&(aButtons[nI][3]),&("{||("+aButtons[nI][3]+")}")), , , .F., .T.})			
//			aOBtn[nI] := TBtnBmp():NewBar(aButtons[nI][2],,,,,&("{||("+aButtons[nI][3]+")}"),,oBar,,,aButtons[nI][1],,,,,,,,,)
		EndIf
	Next nI
EndIf

For nI := 2 To Len(aHeader)
	aAdd(aHeadBro, {;
		aHeader[nI][1],;                     							// [n][01] Título da coluna
		&( "{ |oBrw| aLinha[oBrw:At()," + AllTrim(STR(nI)) + "] }" ),; 	// [n][02] Code-Block de carga dos dados
		aHeader[nI][8],;                  								// [n][03] Tipo de dados
		aHeader[nI][3],;                    							// [n][04] Máscara
		2,;                              								// [n][05] Alinhamento (0=Centralizado, 1=Esquerda ou 2=Direita)
		aHeader[nI][4],;                     							// [n][06] Tamanho
		aHeader[nI][5],;                     							// [n][07] Decimal
		.F.,;                            								// [n][08] Indica se permite a edição
		{|| },;                          								// [n][09] Code-Block de validação da coluna após a edição
		.F.,;                            								// [n][10] Indica se exibe imagem
		Nil,;                            								// [n][11] Code-Block de execução do duplo clique
		"__ReadVar",;                    								// [n][12] Variável a ser utilizada na edição (ReadVar)
		{|| AlwaysTrue()},;             								// [n][13] Code-Block de execução do clique no header
		.F.,;                            								// [n][14] Indica se a coluna está deletada
		.T.,;                            								// [n][15] Indica se a coluna será exibida nos detalhes do Browse
		{},;                             								// [n][16] Opções de carga dos dados (Ex: 1=Sim, 2=Não)
		aHeader[nI][2]})          										// [n][17] Id da coluna

	If aHeader[nI][8] == "C"
		Aadd( aPesq , {	aHeader[nI][1], { { aHeader[nI][2]   , aHeader[nI][8], aHeader[nI][4] , aHeader[nI][5], aHeader[nI][1], aHeader[nI][3]}}, Len(aPesq) + 1})
	EndIf
Next nI

//Definicoes do list box
If (cPaisLoc == "RUS") .or. lMarca == .T.
	BLDBLCLICK := &("{|| "+cDblClick+"}")
	//Verifica se permite multiselección
	If lMultSel
		BHEADERCLI	:= &("{|| "+cHeadClic+"}")
	EndIf
EndIf

//Verifica se deve possuir campo de selecao de registros
BMARK		:= { |oBrw| Iif(aLinha[oBrw:At(),1] > 0,'LBOK',Iif(aLinha[oBrw:At(),1] < 0,'LBNO','DISABLE'))}

oLBCli := FWBROWSE():NEW(oTlocxf4:GetPanelMain())
oLBCli:SETDATAARRAY()
oLBCli:SETARRAY(aLinha)
If lMarca
	oLBCli:ADDMARKCOLUMNS(BMARK,BLDBLCLICK,BHEADERCLI)
EndIf
oLBCli:SetSeek( , aPesq )
oLBCli:SETCOLUMNS(aHeadBro)
oLBCli:SETOWNER(oTlocxf4:GetPanelMain())
oLBCli:DISABLEREPORT()
oLBCli:DISABLECONFIG()
oLBCli:ACTIVATE()

oTlocxf4:AddOkButton({||nOpcao:=1, oTlocxf4:DeActivate()}, STR0032) //"Grabar"
oTlocxf4:AddCloseButton({||nOpcao:=2, oTlocxf4:DeActivate()}, STR0022) //"Anular"

If Len(aBut) > 0
	oTlocxf4:AddButtons(aBut)
EndIf

oTlocxf4:Activate()

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Verifica se deve retornar parametro (lMarca=.T.) e verifica se as selecoes foram confirmadas (nOpcao=2)³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If (lMarca == .T.) .And. (nOpcao == 1)
	//Guarda nome dos campos desconsiderando primeiro que e indicador de selecao {lMarca}
	If lMarca
		nI := 0
		For nI := 1 to Len(aCpVd)
			If nI <> Len(aCpVd)
				aCpVd[nI] := aCpVd[nI+1]
			Else
				aCpVd[nI]   := NIL
			EndIf
		Next nI
		ASIZE(aCpVd,Len(aCpVd)-1)
	EndIf
	//Guarda conteudo das linhas selecionadas (desconsiderando primeiro campo que e indicador de selecao {lMarca})
	nI := 0
	For nI := 1 to Len(aLinha)
		If aLinha[nI,1] > 0 //se a posicao "1" de cada linha for maior do que 0 significa que o registro esta selecionado
			AADD(aLinSel,aLinha[nI])
			AADD(aRecnoSel,aRecno[nI])
		EndIf
	Next nI
	
	//Retirando dos registros selecionados o campo que indica selecao e delecao de registro
	nI := 0
	For nI := 1 to Len(aLinSel) //varre os registros selecionados
		nX := 0
		//varre todos os campos de cada registro selecionado
		For nX := 1 to Len(aLinSel[nI])
			//Verifica se a linha esta na ultima posicao
			If nX != Len(aLinsel[nI])
				aLinSel[nI,nX] := aLinSel[nI,nX+1]
			Else
				aLinSel[nI,nX] := NIL
			EndIf
		Next nX
		ASIZE(aLinSel[nI],Len(aLinSel[nI])-2)
	Next nI
	//Carregando variavel de retorno
	aRet[1] := aCpVd
	aRet[2] := aLinSel
	aRet[3] := aRecnoSel
	If cPaisLoc == "RUS" .And. ValType(aCpVd) == "A" .And. ValType(aLinSel) == "A"
		If !Empty(aCpVd) .And. !Empty(aLinSel)
			nCntPos		:= Ascan(aCpVd, Iif(cAOrig == "SF1","F1_CNTID","F2_CNTID"))
			nCurPos		:= Ascan(aCpVd, Iif(cAOrig == "SF1","F1_MOEDA","F2_MOEDA"))
			nConuniPos	:= Ascan(aCpVd, Iif(cAOrig == "SF1","F1_CONUNI","F2_CONUNI"))
			If nCntPos > 0
				Asort(aLinSel,,,{|x,y| x[nCntPos] > y[nCntPos]})
				If (aLinSel[1][nCntPos] <> aLinSel[Len(aLinSel)][nCntPos]) .Or. (aLinSel[1][nCntPos] <> Iif(lPurchInv,M->F1_CNTID,M->F2_CNTID) .And. aLinSel[Len(aLinSel)][nCntPos] <> Iif(lPurchInv,M->F1_CNTID,M->F2_CNTID) .And. !RUXXTS05())
					Help("",1,"LocxF4Contract1",,STR0026,1,0)
					aRet := NIL
				EndIf  
			EndIf
			If aRet <> Nil
				If nCurPos > 0	//(25/02/19): Checking currency 
					Asort(aLinSel,,,{|x,y| x[nCurPos] > y[nCurPos]})
					If (aLinSel[1][nCurPos] <> aLinSel[Len(aLinSel)][nCurPos]) .Or. (aLinSel[1][nCurPos] <> Iif(lPurchInv,M->F1_MOEDA,M->F2_MOEDA) .And. aLinSel[Len(aLinSel)][nCurPos] <> Iif(lPurchInv,M->F1_MOEDA,M->F2_MOEDA) .And. !RUXXTS05())
						Help("",1,"LocxF4Currency",,STR0027,1,0)	//"It is impossible to select documents belonging in different currencies."
						aRet := NIL
					EndIf
				EndIf
			EndIf
			If aRet <> Nil
				If nConuniPos > 0	//(26/02/19): Checking convencial unit 
					Asort(aLinSel,,,{|x,y| x[nConuniPos] > y[nConuniPos]})
					If (aLinSel[1][nConuniPos] <> aLinSel[Len(aLinSel)][nConuniPos]) .Or. (aLinSel[1][nConuniPos] <> Iif(lPurchInv,M->F1_CONUNI,M->F2_CONUNI) .And. aLinSel[Len(aLinSel)][nConuniPos] <> Iif(lPurchInv,M->F1_CONUNI,M->F2_CONUNI) .And. !RUXXTS05())
						Help("",1,"LocxF4Conuni",,STR0028,1,0)	//"It is impossible to select documents with different values in Convensial Units field."
						aRet := NIL
					EndIf
				EndIf
			EndIf
		Else
			aRet := Nil
		EndIf
	EndIf
Else
	If (cPaisLoc == "RUS") .AND. nOpcao == 01 .AND. nLinhaSel > 0
		aRet := {aCpVd, aLinha[nLinhaSel], aRecno[nLinhaSel]}
	Else
		aRet := Nil
	Endif
EndIf

// Libera os Registros da SF2, reservados pela LockClick()
If !InTransact()
	For nX := 1 To Len(aRecno)
		MsRUnlock(&(cAOrig)->(aRecno[nX]))
	Next nx
EndIf

Return aRet

//--------------------------------------------------------------------------------------------------------------------------------------------------------------------

Function LocxGet(aPropGet,cPai,nOpcx,lRight,lAuto)
Local oGet
Local nOpca:=0,nIaHead,nPosAt, i,_l_AllOk, c_Campo, nX, nY, cCaption, cPict, cValid, cF3, cWhen, nLargSay, nLargGet, uConteudo, oSay
Local nCOunt,cBlkGet,	cBlkWhen,cBlkVld, oSaveGetdad := Nil, aSvRot := Nil
Local aObrig:={}
Local nInitCBox:=1
Local lReadOnly := .F.
Local nIaCbo := 0
Local cArquivo	:=	""
Local lExistCpo := .F.
Local cX3_Titulo := ""
Local cX3_F3 := ""
Local cX3_USADO := ""
Local cX3_VISUAL := ""
Local cX3_WHEN := ""
Local cX3_TIPO := ""
Local cX3_TAMANHO := 0

Default lRight := .T.
Default lAuto	:=	.F.
Default cPai := ""
aSize(aPropGet,nMaxPar)

// Popular a variavel cArquivo
If !Empty(aPropGet[ScArquivo])
	cArquivo:=aPropGet[ScArquivo]
Else
	cArquivo:=GetSx3Cache(aPropGet[ScCampo], "X3_ARQUIVO")
EndIf

// Verifica a existencia do campo
If !Empty(GetSx3Cache(aPropGet[ScCampo], "X3_CAMPO"))
    lExistCpo := .T.
Endif

If Empty(aPropGet[ScConteudo])
	If nOpcx==3
		If lExistCpo
			&("M->"+aPropGet[ScCampo]):=Criavar(aPropGet[ScCampo])
		Else
			&("M->"+aPropGet[ScCampo]):=LocxMemVar(aPropGet,aPropGet[SbInitPad])
		Endif
	Else
		If lExistCpo
			If GetSx3Cache(aPropGet[ScCampo], "X3_CONTEXT") == "V"
				&("M->"+aPropGet[ScCampo]):=Criavar(aPropGet[ScCampo])
			Else
				&("M->"+aPropGet[ScCampo]):=&(cArquivo + "->" + aPropGet[ScCampo])
			EndIf
		Endif
	Endif
	cBlkGet :=	"{ | u | If( PCount() == 0, "+"M->"+aPropGet[ScCampo]+","+ "M->"+ aPropGet[ScCampo]+":= u ) }"
Else

	&("M->"+aPropGet[ScCampo]):=LocxMemVar(aPropGet,aPropGet[SbInitPad])
//	cBlkGet :=	"{ | u | M->"+aPropGet[ScCampo]+" := "+aPropGet[ScConteudo]+"}"
//	cBlkGet :=	"{ | u | If( PCount() == 0, "+"M->"+aPropGet[ScCampo]+","+ aPropGet[ScConteudo] + ":= u ) }"
	If cPai == "oSBx" .and. lExistCpo
		cBlkGet :=	"{ | u | If( PCount() == 0, "+"M->"+aPropGet[ScCampo]+","+ "M->"+ aPropGet[ScCampo]+":= u ) }"
	Else
		cBlkGet :=	"{ | u | If( PCount() == 0, "+aPropGet[ScConteudo] +","+ "M->"+ aPropGet[ScCampo]+":= u ) }"
	EndIf 

EndIf

If !lAuto .AND. !(aPropGet[ScCampo] $ "F1_F5QUID|F2_F5QUID") 
	If lExistCpo .Or. (!lExistCpo .And. !Empty(aPropGet[ScCampo]).And. !Empty(aPropGet[SnTamanho]).And. !Empty(aPropGet[ScTipo]) ;
		.And. aPropGet[ScCampo]!=NIL ;
		.And. aPropGet[SnTamanho]!=NIL ;
		.And. aPropGet[ScTipo]!=NIL)
		
		cObjPai	:= Iif(aPropGet[ScObjPai]==NIL .Or. Empty(aPropGet[ScObjPai]),cPai,aPropGet[ScObjPai])
		nWidth	:= IIf(aPropGet[SnTamanho]==NIL .And. lExistCpo,GetSx3Cache(aPropGet[ScCampo], "X3_TAMANHO"),aPropGet[SnTamanho])
		
		c_Campo	:=	aPropGet[ScCampo]
		// Recuperar variaveis da SX3 
		cX3_Titulo := FwX3Titulo(c_Campo)
		cX3_USADO := GetSx3Cache(aPropGet[ScCampo], "X3_USADO")
		cX3_VISUAL := GetSx3Cache(aPropGet[ScCampo], "X3_VISUAL")
		cX3_WHEN := GetSx3Cache(aPropGet[ScCampo], "X3_WHEN")
		cX3_TIPO := GetSx3Cache(aPropGet[ScCampo], "X3_TIPO")
		cX3_TAMANHO := GetSx3Cache(aPropGet[ScCampo], "X3_TAMANHO")
		cX3_F3 := GetSx3Cache(aPropGet[ScCampo], "X3_F3")

		cCaption:=	IIf(aPropGet[ScTitulo]==NIL .And. lExistCpo,cX3_Titulo,Iif(Empty(aPropGet[ScTitulo])," ",aPropGet[ScTitulo]))
		cCaption:=	Left(AllTrim(cCaption)+Space(12),12)
	    
		If aPropGet[ScPicture]==NIL .And. lExistCpo
			cPict	:=	PesqPict(cArquivo,c_Campo)
		Else
			cPict	:=	Iif(aPropGet[ScPicture]==NIL .OR. Empty(aPropGet[ScPicture])," ",aPropGet[ScPicture])
		Endif
	
		If "S" $ cPict
			nWidth := CalcFieldSize(aPropGet[ScTipo],nWidth,,aPropGet[ScPicture])
		Else
			If aPropGet[ScTipo] == "D" .Or. (Empty(aPropGet[ScTipo]) .And. GetSx3Cache(aPropGet[ScCampo], "X3_TIPO") == "D")
				nWidth  := nWidth*6.7
			Else
				nWidth	:= nWidth*5
			EndIf
		EndIf
	
		If ( aPropGet[ScTipo] == "M" .And. lExistCpo )
			nHeight := 30
			nWidth	:= 150
		Else
			nHeight := 10
		Endif
		If aPropGet[ScF3]==NIL .And. lExistCpo
			cF3	:=	IIf(!Empty(cX3_F3),cX3_F3,NIL)
		Else
			cF3	:= IIf(aPropGet[ScF3]==NIL .Or. Empty(aPropGet[ScF3]),NIL,aPropGet[ScF3])
		Endif
	
		AAdd(aCoord,ChkCoord(aPropGet[SnTop],aPropGet[SnLeft],nHeight,nWidth+Len(cX3_Titulo)+2,aCoord,cObjPai,(&(cObjPai+":nWidth")/2)-5,lRight))
		nX		:= aCoord[Len(aCoord)][1]
		nY		:= aCoord[Len(aCoord)][2]
		
		If Empty(aPropGet[ScValid])
			If lExistCpo
				cValid:=LocX3VALID(c_Campo)
				cValid+=IIf(!Empty(cValid)," .And. ","")+"LocxTrigger('"+c_Campo+"') .And. ModxAtuObj()"
			Else
				cValid:="AlwaysTrue()"
			Endif
		Else
			cValid := AllTrim(aPropGet[ScValid]) + " .And. LocxTrigger('"+c_Campo+"') .And. ModxAtuObj()"
		Endif
		If lExistCpo .And. (AllTrim(Str(nOpcx))$"1|2|5" .Or. (cX3_VISUAL=="V") .Or. (nOpcx == 4 .And. (X3Chave(cX3_USADO) .Or. X3Alteravel(cX3_USADO))))
			lReadOnly := .T.
	    Endif
	
		If !Empty(aPropGet[ScWhen])
			cWhen := aPropGet[ScWhen]
		ElseIf lExistCpo .And. !Empty(cX3_WHEN)
			cWhen := Alltrim(cX3_WHEN)
		Else
			cWhen := ".T."
		EndIf
		If !Empty(cF3)
			nWidth += 10
		EndIf
	
		cBlKSay :=	"{|| OemToAnsi('"+cCaption+"')}"
		nLargSay:=	(Len(cCaption))*3
		oSay		:=	TSay():New( nX-1, nY-nLargSay, &cBlkSay,&(cObjPai),,, .F., .F., .F., .T.,,,,, .F., .F., .F., .F., .F. )
		cCaption	:=	oSay:cCaption
		cBlKVld 	:=	"{|| " + cValid + "}"
		cBlKWhen	:=	"{|| " + cWhen  + "}"
	
		aPropGet[SlObrigat]:=IIf(aPropGet[SlObrigat]==NIL,.F.,aPropGet[SlObrigat])
		If aPropGet[SlObrigat] .Or. (lExistCpo .And. X3Obrigat(c_Campo))
			oSay:NClrText:=16711680
			aObrig:={c_Campo,&(cBlKWhen),cCaption}
		Endif
		cChange	:= IIf(aPropGet[ScChange]==NIL,"",aPropGet[ScChange])
		cChange	:= "{|| "+cChange+"}"
		lCombo	:= (aPropGet[SlCombo]!=NIL .And. aPropGet[SlCombo] .And.aPropGet[SaItens]!=NIL .And. Len(aPropGet[SaItens])>0 .and. __MVCOMBOBOX).OR.;
		(lExistCpo .And. cF3==NIL .And. !Empty(fGetX3CBox(c_Campo)) .and. cX3_TIPO == "C" .and. __MVCOMBOBOX)
		
		If nOpcx != 3 .And. nOpcx != 4
			cBlkVld := "{|| .T. }"
		EndIf
		If lExistCpo .And. lCombo
			aCombo:={}
			nWidth:=0
			If aPropGet[SaItens]==NIL .Or. Len(aPropGet[SaItens])==0
				aCbo:= RetSx3Box(fGetX3CBox(c_Campo),@nInitCBox,,cX3_TAMANHO)
				nWidth:=0
				For nIaCbo:= 1 To Len(aCbo)
					Aadd(aCombo,aCbo[nIaCbo][1])
					nWidth:=Max(Len(aCbo[nIaCbo][1]),nWidth)
				Next nIaCbo
			Else
				aCombo:= aClone(aPropGet[SaItens])
				nIaCbo:= 0
				For nIaCbo:= 1 To Len(aCombo)
					nWidth:=Max(Len(aCombo[nIaCbo]),nWidth)
				Next nIaCbo
			Endif
			nWidth:=nWidth*5
	
			If aPropGet[ScTipo] == "N" .Or. (lExistCpo .And. cX3_TIPO == "N")
				cBlkGet :=	"{ | u | If( PCount() == 0, " + "Str(M->"+aPropGet[ScCampo]+"),"+ "M->"+ aPropGet[ScCampo]+":= Val(u) ) }"
			EndIf
	
			oGet:= TComboBox():New( nX-1,nY, &cBlKGet,aCombo, nWidth, 10, &(cObjPai),,&(cChange), &(cBlkVld),,,.T.,,, .F., &(cBlkWhen))
		ElseIf lCombo .And. !lExistCpo
			aCombo:= aClone(aPropGet[SaItens])
			nIaCbo:= 1
			nWidth:=0
			For nIaCbo:= 1 To Len(aCombo)
				nWidth:=Max(Len(aCombo[nIaCbo]),nWidth)
			Next nIaCbo
			nWidth:=nWidth*5
			If aPropGet[ScTipo] == "N" .Or. (lExistCpo .And. cX3_TIPO == "N")
				cBlkGet :=	"{ | u | If( PCount() == 0, " + "Str(M->"+aPropGet[ScCampo]+"),"+ "M->"+ aPropGet[ScCampo]+":= Val(u) ) }"
			EndIf
	
			oGet:= TComboBox():New( nX-1,nY, &cBlKGet,aCombo, nWidth, 10, &(cObjPai),,&(cChange), &(cBlkVld),,,.T.,,, .F., &(cBlkWhen))
		ElseIf ( aPropGet[ScTipo] == "M" .And. lExistCpo )
			oGet := TMultiGet():New(nX-1,nY,&cBlKGet,&(cObjPai),nWidth,nHeight, ,.F.,Nil,Nil,Nil,.T.,Nil,.T.,&(cBlkWhen),.F.,.F.,Nil,&(cBlkVld),&(cChange),.F.,Nil,.T. )
		Else
			oGet := TGet():New( nX-1,nY          ,&cBlKGet,&(cObjPai),nWidth ,,cPict, &(cBlkVld),,,,.F.,, .T.,, .F.,&(cBlkWhen), .F., .F.,&(cChange),, .F. ,cF3,("M->"+c_Campo),,,,.T.)
		Endif
		
		oGet:lReadOnly	:= lReadOnly
		oGet:bWhen     := &(cBlkWhen)
		oGet:Cargo   	:= aPropGet[SbRetCpo]
		oGet:cReadVar	:= "M->" + c_Campo
	EndIf
Endif
Return {oGet,aObrig}
//------------------------------------------------------------------------------------------------------------------------------------------------------------------
Function CposToHead(aCpos)
Local aCposHead:={}, nI:=0
Default aCpos:={}

For nI:=1 to Len(aCpos)	
	If !Empty(GetSx3Cache(aCpos[nI], "X3_CAMPO"))
		AAdd(aCposHead,{TRIM(FWX3TITULO(aCpos[nI])),;
		                GetSX3Cache(aCpos[ni], "X3_CAMPO"),;
						GetSX3Cache(aCpos[ni], "X3_PICTURE"),;
						GetSX3Cache(aCpos[ni], "X3_TAMANHO"),;
						GetSX3Cache(aCpos[ni], "X3_DECIMAL"),; 
						GetSX3Cache(aCpos[ni], "X3_VALID"),;
						GetSX3Cache(aCpos[ni], "X3_USADO"),;
						GetSX3Cache(aCpos[ni], "X3_TIPO"),;
						GetSX3Cache(aCpos[ni], "X3_ARQUIVO"),;	
						GetSX3Cache(aCpos[ni], "X3_CONTEXT")})
	EndIf
Next nI
Return aCposHead

//---------------------------------------------------------------------------------------------------------------------------------------------------------
Function LocxBLin(cNomeObj,aCfgCpos,lMark)
Local bLine  := {|| Nil }
Local cBline := ""
Local nI     := 0
Local nS     := 0

Default lMark    := .F.

If lMark = .T.
	cBLine  := "{If(" + cNomeObj + ":aArray[" + cNomeObj + ":nAt,1]>0,oOk,If(" + cNomeObj + ":aArray[" + cNomeObj + ":nAt,1]<0,oNo,oNever))"
	nS      := 2
Else
	cBLine  := ""
	nS      := 1
EndIf

For nI:=nS to Len(aCfgCpos)
	If !Empty(aCfgCpos[nI,3])
		cBLine  += IIf(Empty(cBLine),"{",", ") + " Transform(" + cNomeObj + ":aArray[" + cNomeObj + ":nAT][" + alltrim(Str(nI))+ "], '" + aCfgCpos[nI,3] + "')"
	Else
		cBLine  += IIf(Empty(cBLine),"{",", ") + cNomeObj + ":aArray[" + cNomeObj + ":nAT][" + alltrim(Str(nI))+ "]"
	EndIf
Next nI

bLine:= &("{ ||" + cBLine + "} }")

Return bLine
//---------------------------------------------------------------------------------------------------------------------------------------------------
Function LocxMemVar(aCfgCpo,bInitPad)
Local xVar:= NIL

If bInitPad == Nil
	If aCfgCpo[8] == "C"
		xVar := Space( aCfgCpo[4] )
	ElseIf aCfgCpo[8] == "N"
		xVar :=	0
	ElseIf aCfgCpo[8] == "D"
		xVar := CtoD("  /  /    ")
	ElseIf aCfgCpo[8] == "L"
		xVar := .F.
	ElseIf aCfgCpo[8] == "M"
		xVar := ""
	End
Else
	xVar := Eval(bInitPad)
Endif
If !Empty(aCfgCpo[11])
	xVar:= &(aCfgCpo[11])
EndIf

Return xVar

//-----------------------------------------------------------------------------------------------------------------------------------
Static Function ChkCoord(nTopA,nLeftA,nHeightA,nWidthA,aCoords,cObjPai,nWidthPai,lRight)

Local aCoordA:={}
Local nPosConflict := 0
Local nPosConflAnt := 0

Default lRight := .T.

If Len(aCoords) > 0 .And. cObjPai == aCoords[Len(aCoords)][5]
	Default nTopA :=aCoords[Len(aCoords)][1]
	Default nLeftA:=aCoords[Len(aCoords)][2]
Else
	Default nTopA :=003
	Default nLeftA:=040
EndIf

//Monta array contendo todas as coordenadas do campo a ser comparado

aCoordA :={{nTopA,nLeftA},{nTopA+nHeightA,nLeftA+nWidthA}}

nPosConflict := AScan(aCoords,{|x| cObjPai==x[5] .And. Compare(aCoordA,{{x[1],x[2]},{x[1]+x[3],x[2]+x[4]}})  })

Do While nPosConflict > 0
	
	If ( nPosConflict = 1 )
		nPosConflAnt := 1
	Else
		nPosConflAnt := nPosConflict - 1
	Endif
	If !lRight .Or. nLeftA+nWidthA >= Round(nWidthPai/2,0) .Or. aCoords[nPosConflict][2]+aCoords[nPosConflict][4]+3 >= Round(nWidthPai/2,0)
		nLeftA:= 040
		If aCoords[nPosConflict][1]==aCoords[nPosConflAnt][1]
			nTopA := aCoords[nPosConflict][1]  +  Max(aCoords[nPosConflict][3],aCoords[nPosConflAnt][3]) + 3
		Else
			nTopA := aCoords[nPosConflict][1]  +  aCoords[nPosConflict][3] + 3
		Endif
	Else
		nLeftA:=Round(nWidthPai/2,0)+49
	Endif

	aCoordA :={{nTopA,nLeftA},{nTopA+nHeightA,nLeftA+nWidthA}}
	nPosConflict := AScan(aCoords,{|x| cObjPai==x[5] .And. Compare(aCoordA,{{x[1],x[2]},{x[1]+x[3],x[2]+x[4]}})  },nPosConflict)
EndDo

aXY:={nTopA,nLeftA,nHeight,nWidth,cObjPai}

Return(aXY)

//-----------------------------------------------------------------------------------------------------------------------------
Static Function Compare(aSqr1,aSqr2)
Local lRet	:=	.F.
//Estrutura dos retangulos a serem comparados

//aSrqX := {{x1,y1},{x2,y2}} Onde:

// {x1,y1}
//  ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//  ³               ³
//  ³               ³
//  ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
// 				{x2,y2}

If	(	Entre(aSqr2[1][1],aSqr2[2][1],aSqr1[1][1]) .Or. Entre(aSqr2[1][1],aSqr2[2][1],aSqr1[2][1]) .Or.; 		//Compara X1 $ X2
		Entre(aSqr1[1][1],aSqr1[2][1],aSqr2[1][1]) .Or. Entre(aSqr1[1][1],aSqr1[2][1],aSqr2[2][1])	) .And. ; 	//Compara X2 $ X1
	(	Entre(aSqr2[1][2],aSqr2[2][2],aSqr1[1][2]) .Or. Entre(aSqr2[1][2],aSqr2[2][2],aSqr1[2][2]) .Or.; 		//Compara Y1 $ Y2
		Entre(aSqr1[1][2],aSqr1[2][2],aSqr2[1][2]) .Or. Entre(aSqr1[1][2],aSqr1[2][2],aSqr2[2][2])	)      		//Compara Y2 $ Y1
	lRet	:=	.T.
Endif	
Return lRet

//-------------------------------------------------------------------------------------------------------------------------------
Static Function Entre(n1,n2,nValor)
Local nTmp	:=	n1
If n1 > n2
	n1 :=	n2
	n2	:=	nTmp
Endif
Return (nValor>=n1 .And. nValor <=n2)

//-----------------------------------------------------------------------------------------------------------------------------
Function LockClick(cAlias,nReg,aLinha,oLbCli,lMultSel)//Alexandre Silva
Local nMarca := -1 
Local bClick := {|x| If(x[1]==1 .And. !Empty(x[Len(x)]),MsRUnlock(&(cAlias)->(x[Len(x)])),),;
				If(x[1]==1,x[1]:=-1,);
				 }
Local cFunName	:= FunName()
Local cProvFE   := SuperGetMV("MV_PROVFE",,"")
Local cTipoFE   := SuperGetMV("MV_TIPOFE",,"")
Local lCFDUso   := SuperGetMv("MV_CFDUSO",.T.,"1") <> "0"
Local lM485PE   := .T.	
Local nTpDocS 	    := IIf(Type("aCfgNF")=="A", aCfgNF[1], 0) 

DEFAULT lMultSel := .T.

If !lMultSel
	AEval(aLinha,{|x,y| If(x[1]==1,EVAL(bClick,x),) })
	AEval(oLBCli:oData:aArray,{|x,y| If(x[1]==1,x[1]:=-1,) })
	oLBCli:Refresh()
EndIf

(cAlias)->(MsGoTo(nReg))

If ExistBlock("M465DORIFE")
	lM485PE := ExecBlock("M465DORIFE",.F.,.F.,{SF2->F2_FILIAL, SF2->F2_DOC, SF2->F2_SERIE, SF2->F2_CLIENTE, SF2->F2_LOJA})
EndIf

If cPaisLoc == "COL" .AND. ((cFunName $ "MATA466N") .Or. (lChkLxProp .and. ChkLxProp("VerificaTransmisionCOL"))) .AND.  !Empty(cProvFE) .AND. (nTpDocS == 22 .OR. nTpDocS == 23) //Nota Ajuste NCP y NDC
	nMarca := lxChckLock(cAlias,nReg,aLinha,oLbCli, cTipoFE, nMarca)
ElseIf cPaisLoc == "COL" .And. cFunName $ "MATA465N" .And. !Empty(cProvFE) .And. AllTrim(SF2->F2_ESPECIE) == "NF" .And. (cAlias $ "SF2|SD2") .And. lM485PE
	If !Empty(SF2->F2_UUID) .And. (SF2->F2_FLFTEX == "1" .Or. (cTipoFE == "1" .And. SF2->F2_FLFTEX == "6"))
		If aLinha[oLBCli:nAT,1] == 1 //Retira Lock
			MsRUnlock(&(cAlias)->(nReg))
		Else
			If MsRLock(&(cAlias)->(nReg))
				nMarca := 1
			Else
				Help(" ", 1, "USUNAUTO")
			EndIf
		EndIf
	Else		
		If aLinha[oLBCli:nAT,1] == 1 //Retira lock
			MsRUnlock(&(cAlias)->(nReg))
		EndIf
		MsgAlert(STR0029) //"El documento seleccionado no ha sido transmitido. Realice la transmisión e intente nuevamente."
	EndIf
Else
	If aLinha[oLBCli:nAT,1] == 1 //Retirar o Lock
		If !InTransact()
			MsRUnlock(&(cAlias)->(nReg))
		EndIf	
	Else
		If MsRLock(&(cAlias)->(nReg))
			nMarca := 1
		Else
			Help(" ",1,"USUNAUTO")
		EndIf
	EndIf
EndIf

Return nMarca

//----------------------------------------------------------------------------------------------------------------------
Function ContTeclas(aSaveTeclas) //Alexandre Silva

If aSaveTeclas == Nil
	aSaveTeclas	:= {}
	aAdd(aSaveTeclas,{VK_F4 ,	SetKey(VK_F4	)})
	aAdd(aSaveTeclas,{VK_F5 ,	SetKey(VK_F5	)})
	aAdd(aSaveTeclas,{VK_F6 ,	SetKey(VK_F6	)})
	aAdd(aSaveTeclas,{VK_F7 ,	SetKey(VK_F7	)})
	aAdd(aSaveTeclas,{VK_F8 ,	SetKey(VK_F8	)})
	aAdd(aSaveTeclas,{VK_F9 ,	SetKey(VK_F9	)})
	aAdd(aSaveTeclas,{VK_F10,	SetKey(VK_F10	)})
	aAdd(aSaveTeclas,{VK_F11,	SetKey(VK_F11	)})
	aAdd(aSaveTeclas,{VK_F12,	SetKey(VK_F12	)})
	SetKey(VK_F4	,{|| Nil })
	SetKey(VK_F5	,{|| Nil })
	SetKey(VK_F6	,{|| Nil })
	SetKey(VK_F7	,{|| Nil })
	SetKey(VK_F8	,{|| Nil })
	SetKey(VK_F9	,{|| Nil })
	SetKey(VK_F10	,{|| Nil })
	SetKey(VK_F11	,{|| Nil })
	SetKey(VK_F12	,{|| Nil })
Else
	AEval(aSaveTeclas,{|x| SetKey(x[1],x[2])})
EndIf

Return aSaveTeclas

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ChangeMarkºAutor  ³Microsiga           º Data ³  06/21/02   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Executa bloco para possivel gravacao e altera estado da    º±±
±±º          ³ marca no ListBox.                                          º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ TPLPUTOZ6                                                  º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function ChgMarkLb(oLbx,aLin,bGrav,lMult)
Default lMult := .T.

If !lMult
	AEval(aLin, {|x,y| x[1] := -1} )
	AEval(oLbx:aArray, {|x,y| x[1] := -1} )
	oLbx:Refresh()
EndIf
If Eval(bGrav)
	aLin[oLbx:nAt,1] := aLin[oLbx:nAT,1] * -1
EndIf
Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³LocxGetSX3ºAutor  ³Bruno               º Data ³  20/02/03   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Inclui as validacoes do SX3                                 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³LocxGen()                                                   º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function LocxGetSX3(cCampo)
Local nPosCpo	:=	0
Local aRet		:=	{"","",""}
Local aArea		:=	{}
Local aAreaSX3	:=	{}

If aCacheSX3	==	Nil
	aCacheSX3	:=	{}
Endif
                     
If (nPosCpo	:=	Ascan(aCacheSX3,{|x| Alltrim(x[1]) == Alltrim(cCampo) })) > 0
	aRet	:=	aClone(aCacheSX3[nPosCpo][2])
Else
	aArea		:=	GetArea()
	If !Empty(GetSx3Cache(cCampo, "X3_CAMPO"))
		Aadd(aCacheSX3,{cCampo,{Alltrim(GetSX3Cache(cCampo, "X3_VALID")),;
		                        Alltrim(GetSX3Cache(cCampo, "X3_VLDUSER")),;
								GetSX3Cache(cCampo, "X3_TRIGGER"),;
								GetSX3Cache(cCampo, "X3_WHEN")}})
		aRet	:=	aClone(aCacheSX3[Len(aCacheSX3)][2])
	Endif                     
	RestArea(aArea)
Endif

Return aRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³MsLogLocxMºAutor  ³Bruno               º Data ³  20/02/03   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Gera Error Log                                             º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ LocxGen()                                                  º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function MsLogLocxM(aAutoCab,cVar,lCabec)
Local nX	:=	0
If lCabec
	AutoGRLog(Dtoc(MsDate())+' '+Time())
Endif

AutoGRLog(OemToAnsi(STR0017))                          	
For nX:= 1 To Len(aAutoCab)		
	AutoGRLog(Padr(aAutoCab[nX][1],15)+": "+GetValCpo(aAutoCab[nX][2]) + Iif(Upper(aAutoCab[nX][1])==cVar,OemToAnsi(STR0018),""))	// <-- Invalido
Next                                          
Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³GetValCpo ºAutor  ³Bruno               º Data ³  20/02/03   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Retorna o conteudo conforme seu tipo                        º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³LocxGen()                                                   º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function GetValCpo(uVar)

If 	 (ValType(uVar) == "C")
	cConteudo := uVar
ElseIf (ValType(uVar) == "N")
	cConteudo := Str(uVar)
ElseIf (ValType(uVar) == "D")
	cConteudo := DtoC(uVar)
ElseIf (ValType(uVar) == "L")
	cConteudo := If(uVar,"True","False")
ElseIf (ValType(uVar) == "M")
	cConteudo := "Memo"
ElseIf (ValType(uVar) == "U")
	cConteudo := "Nil"
EndIf

Return cConteudo

Function __ModxGenCancel()
	If __lSX8
		RollbackSX8()
	EndIf
Return .T.

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³LocxVldGetºAutor  ³Adilson             º Data ³  16/12/04   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Executa a Validacao do campo na tela                        º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºParametros³cCampo - Campo da Tela					                  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºRetorno   ³.T.=Valido;.F. Invalido                                     º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³LocxNF                                                      º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function LocxVldGet(cCampo)
Local lRet	:=	.T.
Local nPosCpo	:=	0
Local cTmp

nPosCpo	:=	Ascan(__aoGets, {|x|  Alltrim(Substr(x:cReadVar,4)) == cCampo })
If nPosCpo > 0
	cTmp	:=	__ReadVar
	__ReadVar	:=	cCampo
	lRet	:=	Eval(__aoGets[nPosCpo]:bValid)
	__ReadVar	:=	cTmp	
Endif      

Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³VALIDQTD  ºAutor  ³CLOVIS MAGENTA      º Data ³  27/08/08   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³FUNCAO PARA VALIDACAO DAS QUANTIDADES INFORMADAS NA SD2 E   º±±
±±º          ³AFS, NAO PERMITINDO QUE VALOR NA AFS SEJA MAIOR QUE NA SD2  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ LOCXGEN                                                    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function ValidQtd()

Local lOk := .T.
Local nX
Local nY
Local nRatAFS := 0
Local aRatAFS2:= {}
Local nItAcols:= 0
Local nPosQtd:=Ascan(aHeader,{|x| Alltrim(x[2])=="D2_QUANT" })

aRatAFS2 := If(Type('aRatAFS') = 'U', Nil, aRatAFS)
aRatAFS := aClone(aRatAFS2)
If intepms()       // verifica integracao com PMS MV_INTPMS
	If Len(aRatAFS2)>0 
	    For nY:=1 to Len(aRatAFS)
	    	nRatAFS:=0
		    For nX:=1 to Len(aRatAFS2[nY][2])
		    	If aRatAFS2[nY][2][nX][6] == .F.
		    		If ValType(aRatAFS2[nY][2][nX][5]) == 'N'
			    		nRatAFS+= aRatAFS2[nY][2][nX][5]
			    	EndIf
				EndIf
		    Next nX
		    nItAcols := Val(aRatAFS[nY][1])
			IF (aCols[nItAcols][nPosQtd] < nRatAFS) // Verifica se qtde da nota é maior que qtde informada na amarracao com projeto/tarefa
				Help("   ",1,"PMSQTNF")
				lOk:=.F.
			ELSE
				lOk:= .T.
			EndIf
		Next nY
	Endif
EndIf

Return lOk

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o	 ³PictNIT   | Autor ³ Marco Aurelio - Mano	³ Data ³08/11/2012³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Retorna a picture do NIT(Campo CGC)                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe	 ³PictNIT(ExpC1)                                          	  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ExpC1 = Tipo de cliente ou fornecedor                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso		 ³Colombia - Chamada a partir do X3_PICTVAR dos campos        ³±±
±±³ 		 ³           A1_CGC/A2_CGC                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/ 
Function PictNIT(cTipo)
Local cPictRet := ""	// Mascara a ser retorna para edicao do campo

Default cTipo = ""

If cTipo <> "6"
	cPictRet := "@R 9.999.999.999-9"
EndIf

cPictRet := cPictRet + IIf(FunName() == "RSPA010" .And. Empty(cTipo), "", "%C")

Return cPictRet   
 /*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o	 | PesAfip  | Autor ³ Marivaldo				³ Data ³15/07/2013³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Retorna a picture do (Campo CGC)                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe	 ³PictNIT(ExpC1)                                          	  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ExpC1 = Tipo de cliente ou fornecedor                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso		 ³Argentina - Chamada a partir do X3_PICTVAR dos campos       ³±±
±±³ 		 ³           A1_CGC/A2_CGC                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/ 
Function PesAfip(cAfip)
Local cPictRet := ""	// Mascara a ser retorna para edicao do campo
Default cAfip:=""

If STR(VAL(cAfip),2)$"80|86| 1"
	cPictRet := "@R 99-99999999-9"
Else
	cPictRet := "@R 99.999.999.999"	
EndIf

Return cPictRet +"%C"

/*
Función: AutCalTES
Autor: Juan Roberto González Rivas
Fecha: 09/02/2017
Descripción: Cuando se ejecuta a través de una MSExecAuto la creación de una NCC, realizar el cálculo correspondiente de percepciones según la TES.
Parámetros:
	aCols - ítem de la factura.
	aHeader - cabecera de campo de ítems
*/
Function AutCalTES(aCalc, aHeader)
Local nX          := 0
Local nC          := 0
Local nY          := 0
Local nA          := 0
Local nQuant      := 0
Local nPrcVen     := 0
Local nValorItem  := 0
Local nTotBaseImp := 0
Local nPosCols    := 0
LocaL nPosRow     := 0
Local cProduto    := CriaVar("D1_COD")
Local cTES        := CriaVar("D1_TES")
Local cCampo
Local nDescProp   := 0    //Descuento proporconal al ítme para el recalculo de los impuestos variables.
Local aUltImp     := {}
Local nCod        := Ascan(aHeader, {|X| Alltrim(X[2]) ==  "D1_COD"		})
Local nTes        := Ascan(aHeader, {|X| Alltrim(X[2]) ==  "D1_TES"		})
Local nCf         := Ascan(aHeader, {|X| Alltrim(X[2]) ==  "D1_CF"		})
Local nQtd        := Ascan(aHeader, {|X| Alltrim(X[2]) ==  "D1_QUANT"	})
LocaL nVunit      := Ascan(aHeader, {|X| Alltrim(X[2]) ==  "D1_VUNIT"	})
Local nTotal      := Ascan(aHeader, {|X| Alltrim(X[2]) ==  "D1_TOTAL"	})
Local nDesc		  := Ascan(aHeader, {|X| Alltrim(X[2]) ==  "D1_VALDESC"	})
Local aColsBack   := aClone(aCols)
Local nArredIt    := TAMSX3("D1_VUNIT")[2]
Local lItem       := (nArredIt > TAMSX3("D1_TOTAL")[2])
Local nDecs
Local nArredImp
Local nAcrProp    := 0
Local nValTot     := 0
Local cModTmp     := cModulo
Local aRes        := {}
Local aResFin     := {}
Local nDescont	  := 0
Local lF1Seguro  := !(Type("M->F1_SEGURO") == "U")
Local lF1Despesa := !(Type("M->F1_DESPESA") == "U")
Local lF1Frete   := !(Type("M->F1_FRETE") == "U")

	cModulo := "FAT"

	If Type("nDecimais") == "U"
		nDecimais := 2
	EndIf

	If Type("aImpVarSD1") == "U"
		aImpVarSD1 := {0,0,0,0,0,{}}
	EndIf

	nDecs := If(lItem, nArredIt, nDecimais)
	nArredImp := nDecs
	aImps := {}
	aImpVarSF1 := {}

	//Si son usados más dicimales en el valor unitario que en total, debe de calcular los impuestos por el valor unitario
	//pues si no la cantidad estaría perdiendo decimales.
	If lItem
		For	nX:= 1 To Len(aCols)
			aCols[nX][nTotal]	:=	aCols[nX,nVunit] * aCols[nX,nQtd]
		Next nX
	Endif

	AEval(aCols,{|x,y| nValTot += If(!aCols[y][Len(aCols[y])],aCols[y][nTotal],0)})
	nMaxArray := Len(aCols)
	//Zera o Valor da Base de Calculo  o Valor do Imposto e a Aliquota antes de Recalcular os Impostos.
	For nX := 1 To nMaxArray
		//Carga el array aUltImp para identificar el último ítem del aCols que contenga un calculo por total.
		If !aCols[nX][Len(aCols[nX])]
			If (SFC->(DbSeek(xFilial("SFC") + aCols[nX][nTes])))
				While SFC->FC_TES == aCols[nX][nTes] .And. !SFC->(EOF())
					If SFC->FC_CALCULO == "T"
						SFB->(DbSeek(xFilial("SFB")+SFC->FC_IMPOSTO))
						nAliquota := IIf(SFC->FC_BASE == 0, SFB->FB_ALIQ, SFB->FB_ALIQ * (SFC->FC_BASE / 100))
						nPos := Ascan(aUltImp,{|x| x[1] == SFC->FC_IMPOSTO .And. x[4] == nAliquota})
						If nPos == 0
							aadd(aUltImp, {SFC->FC_IMPOSTO, nX,aCols[nX][nTotal], nAliquota})
						Else
							aUltImp[nPos][2] := nX //última posición del impuesto
							aUltImp[nPos][3] += aCols[nX][nTotal] //Base de Calculo
						Endif
					Endif
					SFC->(DbSkip())
				EndDo
			EndIf
		Endif
	Next nX

	nValTotIV  := 0
	nValBaseIV := 0
	aImpCusto  := {}
	aImpVarDup := {}

	//Obter o valor do Desconto para cada Item qdo impostos variaveis.
	aDescontos := Lj010DescIV()
	For nx := 1 to Len(aCols)
		If aCols[nx][Len(aCols[nx])]
			AAdd(aImps,{0,0,0,0,0,{}})
			Loop
		Else
			If nCod > 0
			   cProduto := aCols[nx][nCod]
			   If ValType(cProduto) # "C"
			      cProduto := Space(TamSX3("B1_COD")[1])
			   EndIf
			Endif

			If nTes > 0
				cTes := aCols[nx][nTes]
				SF4->( DbSeek(xFilial("SF4")+cTes))
			Endif

			If nCf > 0
				cCF := aCols[nx][nCf]
			Endif

			If nQtd > 0
				nQuant := aCols[nx][nQtd]
			Endif

			If nVunit > 0
				nPrcVen := aCols[nx][nVunit]
			Endif

			If nTotal > 0
				nValorItem := aCols[nx][nTotal]
				nTotBaseImp += aCols[nx][nTotal]
			Endif
			
			If nDesc>0
				nDescont += aCols[nX][nDesc]
			EndIf

			aImpVarSD1[1] := nQuant
			aImpVarSD1[2] := Round(nPrcVen + (nAcrProp / nQuant), nDecs)
			aImpVarSD1[3] := Round(nValorItem + nAcrProp, nDecs)
			IF ( lF1Frete .AND. lF1Seguro .AND. lF1Despesa )
				If M->F1_FRETE > 0 .Or. M->F1_SEGURO > 0 .Or. M->F1_DESPESA > 0
					aImpVarSD1[4] := LjRatFrete(Iif(nX == 1, .T., .F.), nX)
				Else
					aImpVarSD1[4] := 0.00
				EndIf
			Else
				aImpVarSD1[4] := 0.00
			EndIf
			aImpVarSD1[5] := 0.00
			aImpVarSD1[6] := {}
			//O cadastro de Produtos deve estar posicionado...
			SB1->(DbSeek(xFilial("SB1") + cProduto))
			//Posicionar o SF4 (Obrigat¢rio)...
			SF4->(DbSeek(xFilial("SF4") + cTes))
			If SF4->(Found()) .And. nValorItem != 0
				nPosRow := nX
				//Disparar rotina para executar o RdMake do c lculo dos Impostos
				CalcTesxIp("E", nTotBaseImp, nValorItem, cProduto, nposCols, nPosRow, "NORMAL", aCols[nX][nDesc], nDescont, , aUltImp)
				AAdd(aImps, aClone(aImpVarSD1))
			Else
				AAdd(aImps, {0,0,0,0,0,{}})
			Endif
		EndIf
	Next nX
	//Restaura o aCols
	aCols	:=	aClone(aColsBack)
	For nX := 1 To Len(aCols)
		For nY := 1 to Len(aHeader)
			cCampo := AllTrim(aHeader[ny, 2])
			If Substr(cCampo, 4, 6) == "VALIMP" .Or. Substr(cCampo,4,6) == "BASIMP" .Or. Substr(cCampo,4,6) == "ALQIMP"
				aCols[nX][nY] := 0 //Zerar aCols para atualizacao dos valores
			EndIf
		Next nY
		//Grava Base de calculo e Vlr do impostos obtidos atraves do Roteiro da Amarracao TesXImpostos no array aCols...
		For nC := 1 To Len( aImps[nX, 6])
			If aImps[nX, 6, nC, 3] != 0.00 .And. !Empty(aImps[nX, 6, nC, 6])
				If (nE := aScan(aImpVarSF1, {|x| x[1] == aImps[nX, 6, nC, 8]})) == 0
					AAdd(aImpVarSF1, {aImps[nX, 6, nC, 8], 0.00, aImps[nX, 6, nC, 2]})
					nE := Len(aImpVarSF1)
				EndIf

				aImpVarSF1[nE, 2] += aImps[nX, 6, nC, 4]
				If (nE := aScan(aImpVarSF1, {|x| x[1] == aImps[nX, 6, nC, 9]})) == 0
					AAdd(aImpVarSF1, {aImps[nX, 6, nC, 9], 0.00, aImps[nX, 6, nC, 2]})
					nE := Len( aImpVarSF1 )
				EndIf

				aImpVarSF1[nE, 2] += aImps[nX, 6, nC, 3]
				//Acumula em "aImpVarDup" os Impostos que Incidem no Valor Total Base da Duplicata.
				If SubStr(aImps[nX, 6, nC, 5], 1, 1) == "1"
					AAdd(aImpVarDup, {aImps[nX, 6, nC, 1], aImps[nX, 6, nC, 4]})
				EndIf

				//Valor Base do Imposto...
				nColuna := Ascan(aHeader,{|X| Trim(X[2]) == aImps[nX, 6, nC, 7]})
				If nColuna > 0
				   aCols[nx][nColuna] := aImps[nX, 6, nC, 3]
				EndIf

				//Valor do Imposto calculado...
				nColuna := Ascan(aHeader, {|X| Trim(X[2]) == aImps[nX, 6, nC, 6]})
				If nColuna > 0
				   aCols[nx][nColuna] := aImps[nX, 6, nC, 4]
				EndIf

				//Gravar Aliquotas dos Impostos...
				nColuna := Ascan(aHeader,{|X| Trim(X[2]) == "D1_ALQ" + Subs(aImps[nX, 6, nC, 7], 7, 4)})
				If nColuna > 0
					aCols[nx][nColuna] := aImps[nX, 6, nC, 2]
				EndIf
			EndIf
		Next nC
	Next nX

	//Acertar arredondamentos se calculou algum imposto
	If Len(aImpVarSF1) > 0
		aRedo := {}
		For nX	:=	1 To Len(aImps)
			For nY	:=	1 To Len(aImps[nX][6])
				If aImps[nX][6][nY][4] != 0
					nPosImp := AScan(aRedo, {|x| x[1] == aImps[nX][6][nY][8] .And. x[2] == aImps[nX][6][nY][9] })
					aImps[nX][6][nY][4] := Round(NoRound(aImps[nX][6][nY][4], nDecs + 1), nDecs)
					aImps[nX][6][nY][3] := Round(NoRound(aImps[nX][6][nY][3], nDecs + 1), nDecs)
					If nPosImp == 0
						AAdd(aRedo, {aImps[nX][6][nY][8], aImps[nX][6][nY][9], aImps[nX][6][nY][4], aImps[nX][6][nY][3]})
					Else
						aRedo[nPosImp][3] += aImps[nX][6][nY][4]
						aRedo[nPosImp][4] += aImps[nX][6][nY][3]
					Endif
				Endif
			Next nY
		Next nX

		For nX	:=	1 To Len(aRedo)
			//Acertar el redondeo en la base del impuesto
			nPosImp := Ascan(aImpVarSF1, {|x| x[1] == aRedo[nX][1]})
			aImpVarSF1[nPosImp][2] := Round(NoRound(aImpVarSF1[nPosImp][2], nDecs + 1), nDecs)
			nDif := aImpVarSF1[nPosImp][2] - aRedo[nX][3]
			lAchou := .F.
			While !lAchou
				For nY	:=	1 To Len(aImps)
					nPosIt	:=	Ascan(aImps[nY][6], {|X| x[8] == aRedo[nX][1]})
					If nPosIt > 0
						aImps[nY][6][nPosIt][4] += nDif
						lAchou := .T.
						nY := Len(aImps) + 1
					Endif
				Next nY
			EndDo

			//Acertar el redondeo en el valor del impuesto
			nPosImp := Ascan(aImpVarSF1, {|x| x[1] == aRedo[nX][2]})
			aImpVarSF1[nPosImp][2] := Round(NoRound(aImpVarSF1[nPosImp][2], nDecs + 1),nDecs)
			nDif := aImpVarSF1[nPosImp][2] - aRedo[nX][4]
			lAchou	:=	.F.
			While !lAchou
				For nY	:= 1 To Len(aImps)
					nPosIt := Ascan(aImps[nY][6], {|X| x[9] == aRedo[nX][2]})
					If nPosIt > 0
						aImps[nY][6][nPosIt][3]	+=	nDif
						lAchou := .T.
						nY := Len(aImps) + 1
					Endif
				Next nY
			EndDo
		Next nX
	EndIf

	nValTotIV	:=	0
	nValBaseIV	:=	0
	For nX	:= 1 To Len(aImps)
		aPropImp := TesImpInf(aCols[nX][nTes])
		For nY := 1 To Len(aImps[nX][6])
			If aPropImp[nY][3] == "1"
				nValTotIV += aImps[nX][6][nY][4]
			ElseIf (aPropImp[nY][3] == "2")
				nValTotIV -= aImps[nX][6][nY][4]
			Endif
		Next nY
	Next nX

	nValTotIV := Round(NoRound(nValTotIV, nArredImp + 1), nArredImp)
	nValBaseIV := Round(NoRound(nValTotIV, nArredImp + 1), nArredImp)
	For nX := 1 To Len(aCols)
		aAdd(aRes, {nX, aImps[nX][6]})
	Next nX

	aAdd(aResFin, {nValTotIV, nValBaseIV, aRes, aImpVarSF1})
	cModulo := cModTmp
Return aResFin

//----------------------------------------------------------------------
/*/{Protheus.doc} CPOIMPARG()
Verifica Campos dos impostos para gravação
@author Danilo Santos
@since 18/04/2018
@version 1.0
@return ACPOIMP
/*/
//----------------------------------------------------------------------

//Mapeamento da memoria da existencia dos campos
Function CPOIMPARG(calias1,cAlias2)

Local ACPOIMP:={}

Default cAlias1 := ""
Default cAlias2 := ""

If (cAlias1) <> "" .And. (cAlias2) <> "" 
	AADD(ACPOIMP,Iif(cPaisLoc == 'ARG', CCO->(FieldPos("CCO_TIPO"))>0, ''))
	AADD(ACPOIMP,SFH->(FieldPos("FH_DTINI"))>0) 
	AADD(ACPOIMP,SFH->(FieldPos("FH_DTFIM"))>0)
	AADD(ACPOIMP,SFH->(FieldPos("FH_INIVIGE"))>0)
	AADD(ACPOIMP,SFH->(FieldPos("FH_FIMVIGE"))>0)
	AADD(ACPOIMP,SA2->(FieldPos("A2_RG820"))>0)
	AADD(ACPOIMP,SFH->(FieldPos("FH_TIPO"))>0)
	AADD(ACPOIMP,SFB->(FieldPos("FB_DESGR"))>0)
	AADD(ACPOIMP,SFB->(FieldPos("FB_DESGR"))>0)
	AADD(ACPOIMP,SFF->(FieldPos("FF_LIMITE"))>0)
	AADD(ACPOIMP,SFF->(FieldPos("FF_MINUNIT"))>0)
	AADD(ACPOIMP,SFF->(FieldPos("FF_FORMAPG"))>0) 
	AADD(ACPOIMP,SFF->(FieldPos("FF_FORMAPG"))> 0)
	AADD(ACPOIMP,SFF->(FieldPos("FF_INCIMP")>0))
	AADD(ACPOIMP,(cAlias1)->(FieldPos("C7_BASIMP1"))>0 .And. (cAlias2)->(FieldPos("C8_BASIMP1"))>0)//15
	AADD(ACPOIMP,(cAlias1)->(FieldPos("C7_ALQIMP1"))>0 .and. (cAlias2)->(FieldPos("C8_ALQIMP1"))>0)//16
	AADD(ACPOIMP,(cAlias1)->(FieldPos("C7_VALIMP1"))>0 .and. (cAlias2)->(FieldPos("C8_VALIMP1"))>0)//17
	AADD(ACPOIMP,(cAlias1)->(FieldPos("C7_BASIMP2"))>0 .And. (cAlias2)->(FieldPos("C8_BASIMP2"))>0)//18
	AADD(ACPOIMP,(cAlias1)->(FieldPos("C7_ALQIMP2"))>0 .and. (cAlias2)->(FieldPos("C8_ALQIMP2"))>0)//19
	AADD(ACPOIMP,(cAlias1)->(FieldPos("C7_VALIMP2"))>0 .and. (cAlias2)->(FieldPos("C8_VALIMP2"))>0)//20
	AADD(ACPOIMP,(cAlias1)->(FieldPos("C7_BASIMP3"))>0 .And. (cAlias2)->(FieldPos("C8_BASIMP3"))>0)//21
	AADD(ACPOIMP,(cAlias1)->(FieldPos("C7_ALQIMP3"))>0 .and. (cAlias2)->(FieldPos("C8_ALQIMP3"))>0)//22
	AADD(ACPOIMP,(cAlias1)->(FieldPos("C7_VALIMP3"))>0 .and. (cAlias2)->(FieldPos("C8_VALIMP3"))>0)//23
	AADD(ACPOIMP,(cAlias1)->(FieldPos("C7_BASIMP4"))>0 .And. (cAlias2)->(FieldPos("C8_BASIMP4"))>0)//24
	AADD(ACPOIMP,(cAlias1)->(FieldPos("C7_ALQIMP4"))>0 .and. (cAlias2)->(FieldPos("C8_ALQIMP4"))>0)//25
	AADD(ACPOIMP,(cAlias1)->(FieldPos("C7_VALIMP4"))>0 .and. (cAlias2)->(FieldPos("C8_VALIMP4"))>0)//26
	AADD(ACPOIMP,(cAlias1)->(FieldPos("C7_BASIMP5"))>0 .And. (cAlias2)->(FieldPos("C8_BASIMP5"))>0)//27
	AADD(ACPOIMP,(cAlias1)->(FieldPos("C7_ALQIMP5"))>0 .and. (cAlias2)->(FieldPos("C8_ALQIMP5"))>0)//28
	AADD(ACPOIMP,(cAlias1)->(FieldPos("C7_VALIMP5"))>0 .and. (cAlias2)->(FieldPos("C8_VALIMP5"))>0)//29
	AADD(ACPOIMP,(cAlias1)->(FieldPos("C7_BASIMP6"))>0 .And. (cAlias2)->(FieldPos("C8_BASIMP6"))>0)//30
	AADD(ACPOIMP,(cAlias1)->(FieldPos("C7_ALQIMP6"))>0 .and. (cAlias2)->(FieldPos("C8_ALQIMP6"))>0)//31
	AADD(ACPOIMP,(cAlias1)->(FieldPos("C7_VALIMP6"))>0 .and. (cAlias2)->(FieldPos("C8_VALIMP6"))>0)//32
	AADD(ACPOIMP,(cAlias1)->(FieldPos("C7_BASIMP7"))>0 .And. (cAlias2)->(FieldPos("C8_BASIMP7"))>0)//33
	AADD(ACPOIMP,(cAlias1)->(FieldPos("C7_ALQIMP7"))>0 .and. (cAlias2)->(FieldPos("C8_ALQIMP7"))>0)//34
	AADD(ACPOIMP,(cAlias1)->(FieldPos("C7_VALIMP7"))>0 .and. (cAlias2)->(FieldPos("C8_VALIMP7"))>0)//35
	AADD(ACPOIMP,(cAlias1)->(FieldPos("C7_BASIMP8"))>0 .And. (cAlias2)->(FieldPos("C8_BASIMP8"))>0)//36
	AADD(ACPOIMP,(cAlias1)->(FieldPos("C7_ALQIMP8"))>0 .and. (cAlias2)->(FieldPos("C8_ALQIMP8"))>0)//37
	AADD(ACPOIMP,(cAlias1)->(FieldPos("C7_VALIMP8"))>0 .and. (cAlias2)->(FieldPos("C8_VALIMP8"))>0)//38
	AADD(ACPOIMP,(cAlias1)->(FieldPos("C7_BASIMP9"))>0 .and. (cAlias2)->(FieldPos("C8_BASIMP9"))>0)//39
	AADD(ACPOIMP,(cAlias1)->(FieldPos("C7_ALQIMP9"))>0 .and. (cAlias2)->(FieldPos("C8_ALQIMP9"))>0)//40
	AADD(ACPOIMP,(cAlias1)->(FieldPos("C7_VALIMP9"))>0 .and. (cAlias2)->(FieldPos("C8_VALIMP9"))>0)//41
	AADD(ACPOIMP,(cAlias1)->(FieldPos("C7_BASIMPA"))>0 .And. (cAlias2)->(FieldPos("C8_BASIMPA"))>0)//42
	AADD(ACPOIMP,(cAlias1)->(FieldPos("C7_BASIMPB"))>0 .And. (cAlias2)->(FieldPos("C8_BASIMPB"))>0)//43
	AADD(ACPOIMP,(cAlias1)->(FieldPos("C7_BASIMPC"))>0 .And. (cAlias2)->(FieldPos("C8_BASIMPC"))>0)//44
	AADD(ACPOIMP,(cAlias1)->(FieldPos("C7_BASIMPD"))>0 .And. (cAlias2)->(FieldPos("C8_BASIMPD"))>0)//45
	AADD(ACPOIMP,(cAlias1)->(FieldPos("C7_BASIMPE"))>0 .And. (cAlias2)->(FieldPos("C8_BASIMPE"))>0)//46
	AADD(ACPOIMP,(cAlias1)->(FieldPos("C7_BASIMPF"))>0 .And. (cAlias2)->(FieldPos("C8_BASIMPF"))>0)//47
	AADD(ACPOIMP,(cAlias1)->(FieldPos("C7_BASIMPG"))>0 .And. (cAlias2)->(FieldPos("C8_BASIMPG"))>0)//48
	AADD(ACPOIMP,(cAlias1)->(FieldPos("C7_BASIMPH"))>0 .And. (cAlias2)->(FieldPos("C8_BASIMPH"))>0)//49
	AADD(ACPOIMP,(cAlias1)->(FieldPos("C7_BASIMPI"))>0 .and. (cAlias2)->(FieldPos("C8_BASIMPI"))>0)//50
	AADD(ACPOIMP,(cAlias1)->(FieldPos("C7_BASIMPJ"))>0 .and. (cAlias2)->(FieldPos("C8_BASIMPJ"))>0)//51
	AADD(ACPOIMP,(cAlias1)->(FieldPos("C7_BASIMPK"))>0 .and. (cAlias2)->(FieldPos("C8_BASIMPK"))>0)//52
	AADD(ACPOIMP,(cAlias1)->(FieldPos("C7_BASIMPL"))>0 .and. (cAlias2)->(FieldPos("C8_BASIMPL"))>0)//53
	AADD(ACPOIMP,(cAlias1)->(FieldPos("C7_BASIMPM"))>0 .and. (cAlias2)->(FieldPos("C8_BASIMPM"))>0)//54
	AADD(ACPOIMP,(cAlias1)->(FieldPos("C7_BASIMPN"))>0 .and. (cAlias2)->(FieldPos("C8_BASIMPN"))>0)//55
	AADD(ACPOIMP,(cAlias1)->(FieldPos("C7_BASIMPO"))>0 .and. (cAlias2)->(FieldPos("C8_BASIMPO"))>0)//56
	AADD(ACPOIMP,(cAlias1)->(FieldPos("C7_BASIMPP"))>0 .and. (cAlias2)->(FieldPos("C8_BASIMPP"))>0)//57
	AADD(ACPOIMP,(cAlias1)->(FieldPos("C7_BASIMPQ"))>0 .and. (cAlias2)->(FieldPos("C8_BASIMPQ"))>0)//58
	AADD(ACPOIMP,(cAlias1)->(FieldPos("C7_BASIMPR"))>0 .and. (cAlias2)->(FieldPos("C8_BASIMPR"))>0)//59
	AADD(ACPOIMP,(cAlias1)->(FieldPos("C7_BASIMPS"))>0 .and. (cAlias2)->(FieldPos("C8_BASIMPS"))>0)//60
	AADD(ACPOIMP,(cAlias1)->(FieldPos("C7_BASIMPT"))>0 .and. (cAlias2)->(FieldPos("C8_BASIMPT"))>0)//61
	AADD(ACPOIMP,(cAlias1)->(FieldPos("C7_BASIMPU"))>0 .and. (cAlias2)->(FieldPos("C8_BASIMPU"))>0)//62
	AADD(ACPOIMP,(cAlias1)->(FieldPos("C7_BASIMPV"))>0 .and. (cAlias2)->(FieldPos("C8_BASIMPV"))>0)//63
	AADD(ACPOIMP,(cAlias1)->(FieldPos("C7_BASIMPW"))>0 .and. (cAlias2)->(FieldPos("C8_BASIMPW"))>0)//64
	AADD(ACPOIMP,(cAlias1)->(FieldPos("C7_BASIMPX"))>0 .and. (cAlias2)->(FieldPos("C8_BASIMPX"))>0)//65
	AADD(ACPOIMP,(cAlias1)->(FieldPos("C7_BASIMPY"))>0 .and. (cAlias2)->(FieldPos("C8_BASIMPY"))>0)//66
	AADD(ACPOIMP,(cAlias1)->(FieldPos("C7_BASIMPZ"))>0 .and. (cAlias2)->(FieldPos("C8_BASIMPZ"))>0)//67
	
Endif
Return(ACPOIMP)

//----------------------------------------------------------------------
/*/{Protheus.doc} GrvSC7Loc(array)
Grava Campos dos impostos no pedido de compra 
@author Danilo Santos
@since 19/04/2018
@version 1.0
@return
/*/
//----------------------------------------------------------------------
Function GrvSC7Loc(ACPOIMP)

#DEFINE _C7_BASIMP1 15
#DEFINE _C7_ALQIMP1 16
#DEFINE _C7_VALIMP1 17
#DEFINE _C7_BASIMP2 18
#DEFINE _C7_ALQIMP2 19
#DEFINE _C7_VALIMP2 20
#DEFINE _C7_BASIMP3 21
#DEFINE _C7_ALQIMP3 22
#DEFINE _C7_VALIMP3 23
#DEFINE _C7_BASIMP4 24
#DEFINE _C7_ALQIMP4 25
#DEFINE _C7_VALIMP4 26
#DEFINE _C7_BASIMP5 27
#DEFINE _C7_ALQIMP5 28
#DEFINE _C7_VALIMP5 29
#DEFINE _C7_BASIMP6 30
#DEFINE _C7_ALQIMP6 31
#DEFINE _C7_VALIMP6 32
#DEFINE _C7_BASIMP7 33
#DEFINE _C7_ALQIMP7 34
#DEFINE _C7_VALIMP7 35
#DEFINE _C7_BASIMP8 36
#DEFINE _C7_ALQIMP8 37
#DEFINE _C7_VALIMP8 38
#DEFINE _C7_BASIMP9 39
#DEFINE _C7_ALQIMP9 40
#DEFINE _C7_VALIMP9 41
#DEFINE _C7_BASIMPA 42
#DEFINE _C7_BASIMPB 43
#DEFINE _C7_BASIMPC 44
#DEFINE _C7_BASIMPD 45
#DEFINE _C7_BASIMPE 46
#DEFINE _C7_BASIMPF 47
#DEFINE _C7_BASIMPG 48
#DEFINE _C7_BASIMPH 49
#DEFINE _C7_BASIMPI 50
#DEFINE _C7_BASIMPJ 51
#DEFINE _C7_BASIMPK 52
#DEFINE _C7_BASIMPL 53
#DEFINE _C7_BASIMPM 54
#DEFINE _C7_BASIMPN 55
#DEFINE _C7_BASIMPO 56
#DEFINE _C7_BASIMPP 57
#DEFINE _C7_BASIMPQ 58
#DEFINE _C7_BASIMPR 59
#DEFINE _C7_BASIMPS 60
#DEFINE _C7_BASIMPT 61
#DEFINE _C7_BASIMPU 62
#DEFINE _C7_BASIMPV 63
#DEFINE _C7_BASIMPW 64
#DEFINE _C7_BASIMPX 65
#DEFINE _C7_BASIMPY 66
#DEFINE _C7_BASIMPZ 67

Default ACPOIMP := {}

If cPaisLoc == "ARG" .And. Len(ACPOIMP) > 0					
	If SC8->C8_BASIMP1 > 0 .And. SC8->C8_VALIMP1 > 0 
		SC7->C7_BASIMP1 := SC8->C8_BASIMP1
		SC7->C7_ALQIMP1 := SC8->C8_ALQIMP1
		SC7->C7_VALIMP1 := SC8->C8_VALIMP1
	Endif
	If SC8->C8_BASIMP2 > 0 .And. SC8->C8_VALIMP2 > 0
		SC7->C7_BASIMP2 := SC8->C8_BASIMP2
		SC7->C7_ALQIMP2 := SC8->C8_ALQIMP2
		SC7->C7_VALIMP2 := SC8->C8_VALIMP2
	Endif
	If SC8->C8_BASIMP3 > 0 .And. SC8->C8_VALIMP3 > 0
		SC7->C7_BASIMP3 := SC8->C8_BASIMP3
		SC7->C7_ALQIMP3 := SC8->C8_ALQIMP3
		SC7->C7_VALIMP3 := SC8->C8_VALIMP3
	Endif
	If SC8->C8_BASIMP4 > 0 .And. SC8->C8_VALIMP4 > 0
		SC7->C7_BASIMP4 := SC8->C8_BASIMP4
		SC7->C7_ALQIMP4 := SC8->C8_ALQIMP4
		SC7->C7_VALIMP4 := SC8->C8_VALIMP4
	Endif
	If SC8->C8_BASIMP5 > 0 .And. SC8->C8_VALIMP5 > 0
		SC7->C7_BASIMP5 := SC8->C8_BASIMP5
		SC7->C7_ALQIMP5 := SC8->C8_ALQIMP5
		SC7->C7_VALIMP5 := SC8->C8_VALIMP5
	Endif
	If SC8->C8_BASIMP6 > 0 .And. SC8->C8_VALIMP6 > 0
		SC7->C7_BASIMP6 := SC8->C8_BASIMP6
		SC7->C7_ALQIMP6 := SC8->C8_ALQIMP6
		SC7->C7_VALIMP6 := SC8->C8_VALIMP6
	Endif
	If SC8->C8_BASIMP7 > 0 .And. SC8->C8_VALIMP7 > 0							
		SC7->C7_BASIMP7 := SC8->C8_BASIMP7
		SC7->C7_ALQIMP7 := SC8->C8_ALQIMP7
		SC7->C7_VALIMP7 := SC8->C8_VALIMP7
	Endif
	If SC8->C8_BASIMP8 > 0 .And. SC8->C8_VALIMP8 > 0
		SC7->C7_BASIMP8 := SC8->C8_BASIMP8
		SC7->C7_ALQIMP8 := SC8->C8_ALQIMP8
		SC7->C7_VALIMP8 := SC8->C8_VALIMP8
	Endif
	If SC8->C8_BASIMP9 > 0 .And. SC8->C8_VALIMP9 > 0
		SC7->C7_BASIMP9 := SC8->C8_BASIMP9
		SC7->C7_ALQIMP9 := SC8->C8_ALQIMP9
		SC7->C7_VALIMP9 := SC8->C8_VALIMP9
	Endif
	If ACPOIMP[_C7_BASIMPA]
		SC7->C7_BASIMPA := SC8->C8_BASIMPA
		SC7->C7_ALQIMPA := SC8->C8_ALQIMPA
		SC7->C7_VALIMPA := SC8->C8_VALIMPA
	Endif
	If ACPOIMP[_C7_BASIMPB]
		SC7->C7_BASIMPB := SC8->C8_BASIMPB
		SC7->C7_ALQIMPB := SC8->C8_ALQIMPB
		SC7->C7_VALIMPB := SC8->C8_VALIMPB
	EndIf
	If ACPOIMP[_C7_BASIMPC]
		SC7->C7_BASIMPC := SC8->C8_BASIMPC
		SC7->C7_ALQIMPC := SC8->C8_ALQIMPC
		SC7->C7_VALIMPC := SC8->C8_VALIMPC
	EndIf
	If ACPOIMP[_C7_BASIMPD]
		SC7->C7_BASIMPD := SC8->C8_BASIMPD
		SC7->C7_ALQIMPD := SC8->C8_ALQIMPD
		SC7->C7_VALIMPD := SC8->C8_VALIMPD
	EndIf
	If ACPOIMP[_C7_BASIMPE]
		SC7->C7_BASIMPE := SC8->C8_BASIMPE
		SC7->C7_ALQIMPE := SC8->C8_ALQIMPE
		SC7->C7_VALIMPE := SC8->C8_VALIMPE
	EndIf
	If ACPOIMP[_C7_BASIMPF]
		SC7->C7_BASIMPF := SC8->C8_BASIMPF
		SC7->C7_ALQIMPF := SC8->C8_ALQIMPF
		SC7->C7_VALIMPF := SC8->C8_VALIMPF
	EndIf
	If ACPOIMP[_C7_BASIMPG]
		SC7->C7_BASIMPG := SC8->C8_BASIMPG
		SC7->C7_ALQIMPG := SC8->C8_ALQIMPG
		SC7->C7_VALIMPG := SC8->C8_VALIMPG
	EndIf
	If ACPOIMP[_C7_BASIMPH]
		SC7->C7_BASIMPH := SC8->C8_BASIMPH
		SC7->C7_ALQIMPH := SC8->C8_ALQIMPH
		SC7->C7_VALIMPH := SC8->C8_VALIMPH
	EndIf
	If ACPOIMP[_C7_BASIMPI]
		SC7->C7_BASIMPI := SC8->C8_BASIMPI
		SC7->C7_ALQIMPI := SC8->C8_ALQIMPI
		SC7->C7_VALIMPI := SC8->C8_VALIMPI
	EndIf
	If ACPOIMP[_C7_BASIMPJ]
		SC7->C7_BASIMPJ := SC8->C8_BASIMPJ
		SC7->C7_ALQIMPJ := SC8->C8_ALQIMPJ
		SC7->C7_VALIMPJ := SC8->C8_VALIMPJ
	EndIf
	If ACPOIMP[_C7_BASIMPK]
		SC7->C7_BASIMPK := SC8->C8_BASIMPK
		SC7->C7_ALQIMPK := SC8->C8_ALQIMPK
		SC7->C7_VALIMPK := SC8->C8_VALIMPK
	EndIf
	If ACPOIMP[_C7_BASIMPL]
		SC7->C7_BASIMPL := SC8->C8_BASIMPL
		SC7->C7_ALQIMPL := SC8->C8_ALQIMPL
		SC7->C7_VALIMPL := SC8->C8_VALIMPL
	EndIf
	If ACPOIMP[_C7_BASIMPM]
		SC7->C7_BASIMPM := SC8->C8_BASIMPM
		SC7->C7_ALQIMPM := SC8->C8_ALQIMPM
		SC7->C7_VALIMPM := SC8->C8_VALIMPM
	EndIf
	If ACPOIMP[_C7_BASIMPN]
		SC7->C7_BASIMPN := SC8->C8_BASIMPN
		SC7->C7_ALQIMPN := SC8->C8_ALQIMPN
		SC7->C7_VALIMPN := SC8->C8_VALIMPN
	EndIf
	If ACPOIMP[_C7_BASIMPO]
		SC7->C7_BASIMPO := SC8->C8_BASIMPO
		SC7->C7_ALQIMPO := SC8->C8_ALQIMPO
		SC7->C7_VALIMPO := SC8->C8_VALIMPO
	EndIf
	If ACPOIMP[_C7_BASIMPP]
		SC7->C7_BASIMPP := SC8->C8_BASIMPP
		SC7->C7_ALQIMPP := SC8->C8_ALQIMPP
		SC7->C7_VALIMPP := SC8->C8_VALIMPP
	EndIf
	If ACPOIMP[_C7_BASIMPQ]
		SC7->C7_BASIMPQ := SC8->C8_BASIMPQ
		SC7->C7_ALQIMPQ := SC8->C8_ALQIMPQ
		SC7->C7_VALIMPQ := SC8->C8_VALIMPQ
	EndIf
	If ACPOIMP[_C7_BASIMPR]
		SC7->C7_BASIMPR := SC8->C8_BASIMPR
		SC7->C7_ALQIMPR := SC8->C8_ALQIMPR
		SC7->C7_VALIMPR := SC8->C8_VALIMPR
	EndIf
	If ACPOIMP[_C7_BASIMPS]
		SC7->C7_BASIMPS := SC8->C8_BASIMPS
		SC7->C7_ALQIMPS := SC8->C8_ALQIMPS
		SC7->C7_VALIMPS := SC8->C8_VALIMPS
	EndIf
	If ACPOIMP[_C7_BASIMPT]
		SC7->C7_BASIMPT := SC8->C8_BASIMPT
		SC7->C7_ALQIMPT := SC8->C8_ALQIMPT
		SC7->C7_VALIMPT := SC8->C8_VALIMPT
	EndIf
	If ACPOIMP[_C7_BASIMPU] .And. SC8->(ColumnPos("C8_ALQIMPU")) > 0
		SC7->C7_BASIMPU := SC8->C8_BASIMPU
		SC7->C7_ALQIMPU := SC8->C8_ALQIMPU
		SC7->C7_VALIMPU := SC8->C8_VALIMPU
	EndIf
	If ACPOIMP[_C7_BASIMPV]
		SC7->C7_BASIMPV := SC8->C8_BASIMPV
		SC7->C7_ALQIMPV := SC8->C8_ALQIMPV
		SC7->C7_VALIMPV := SC8->C8_VALIMPV
	EndIf
	If ACPOIMP[_C7_BASIMPW]
		SC7->C7_BASIMPW := SC8->C8_BASIMPW
		SC7->C7_ALQIMPW := SC8->C8_ALQIMPW
		SC7->C7_VALIMPW := SC8->C8_VALIMPW
	EndIf
	If ACPOIMP[_C7_BASIMPX]
		SC7->C7_BASIMPX := SC8->C8_BASIMPX
		SC7->C7_ALQIMPX := SC8->C8_ALQIMPX
		SC7->C7_VALIMPX := SC8->C8_VALIMPX
	EndIf        
	If ACPOIMP[_C7_BASIMPY]
		SC7->C7_BASIMPY := SC8->C8_BASIMPY
		SC7->C7_ALQIMPY := SC8->C8_ALQIMPY
		SC7->C7_VALIMPY := SC8->C8_VALIMPY
	EndIf
	If ACPOIMP[_C7_BASIMPZ]
		SC7->C7_BASIMPZ := SC8->C8_BASIMPZ
		SC7->C7_ALQIMPZ := SC8->C8_ALQIMPZ
		SC7->C7_VALIMPZ := SC8->C8_VALIMPZ
	EndIf						       
Endif

RETURN

/*/{Protheus.doc} LocxVldTp9()
Validaciones para condicion de pago Tipo 9
@author Luis Eduardo Enríquez Mata
@since 27/06/19
@version 1.0
@return
/*/
Function LocxVldTp9()
Local aArea     := GetArea()
Local aAreaSE4  := SE4->(GetArea())
Local cParcela  := "123456789ABCDEFGHIJKLMNOPQRSTUVWXYZ0"
Local dParc     := Ctod("")
Local nParc     := 0
Local nAux      := 0
Local nTotLib9  := 0
Local nTot9     := 0
Local nTotal    := 0
Local nQtdLib   := 0
Local nQtdVen   := 0
Local nValor    := 0 
Local nY        := 0 
Local nX        := 0       
Local nParcelas := SuperGetMv("MV_NUMPARC")
Local lRet      := .T.
Local lIpi      := (GetMV("MV_IPITP9") == "S")
Local lMt410Parc:= Existblock("MT410PC")
Local lParc     := .T.
Local lGCT      := !Empty(M->C5_MDNUMED)
Local cCpoParc  := ""
Local nContParc := 1
Local cChave 		:= ""
Local cChave1		:= ""
Local aAreaSX3		:= SX3->(GetArea())

If lGCT
   	Return(.T.)
EndIf
If nParcelas > 4
	cChave := "C5_DATA"+Subs(cParcela,nParcelas,1)
	cChave1:= "C5_PARC"+Subs(cParcela,nParcelas,1)
	aAreaSX3 := SX3->(GetArea())
	
	DbSelectArea("SX3")
	DbSetOrder(2)
	If !DbSeek(cChave) .or. !DbSeek(cChave1)
		Help(" ",1,"TMKTIP905") //"A quantidade de parcelas nao esta compativel. Verificar junto ao administrador do sistema relacao entre parametro MV_NUMPARC e dicionario de dados"
		Return(.F.)        
	EndIf
	Restarea(aAreaSX3)
EndIf


If ( ExistBlock("M410TIP9") )
	lRet := ExecBlock("M410TIP9",.F.,.F.)
Else
	
	For nX := 1 to Len(aCols)
		If !aCols[nx][Len(aCols[nx])]
			For ny := 1 to Len(aHeader)
				If Trim(aHeader[ny][2]) == "C6_QTDVEN"
					nQtdVen := aCols[nx][ny]
				ElseIf Trim(aHeader[ny][2]) == "C6_QTDLIB"
					nQtdLib := aCols[nx][ny]
				ElseIf Trim(aHeader[ny][2]) == "C6_VALOR"
					nValor := aCols[nx][ny]
				EndIf
			Next ny
			
			nTotal   +=  nValor
			nTotLib9 +=  nQtdLib
			nTot9    +=  nQtdVen
		EndIf
	Next nX
	
	nTotal := nTotal + M->C5_FRETE + M->C5_DESPESA + M->C5_SEGURO + M->C5_FRETAUT 
	
	// permite que o numero de parcela possa se manipulado por customização, independente do parametro
	If lMt410Parc
		nParcelas := Execblock("MT410PC",.F.,.F.)
	Endif
	
	For nX:=1 to nParcelas
		cCpoParc := ""
		If nX > 36
			cCpoParc := StrZero(nContParc,2)
			nContParc++
		Else
			cCpoParc := Substr(cParcela,nx,1)
		EndIf
		If SC5->(ColumnPos("C5_PARC" + cCpoParc)) > 0
			nParc := &("M->C5_PARC" + cCpoParc)
		EndIf
		If SC5->(ColumnPos("C5_DATA" + cCpoParc)) > 0
			dParc := &("M->C5_DATA" + cCpoParc)
		EndIf
		If nParc > 0 .And. Empty(dParc)
			lParc := .F.
		EndIf
		nAux		+= nParc
	Next nX

	If !lParc
		Help(" ",1,"A410TIPO9")		
		lRet := .F.		
	Else	
		dbSelectArea("SE4")
		dbSetOrder(1)
		If MsSeek(xFilial()+M->C5_CONDPAG)
			If SE4->E4_TIPO =="9"
				If AllTrim(SE4->E4_COND) = "0"
				
					If	( lIpi .And. NoRound(nTotal,2) > NoRound(nAux,2) ) .Or. ;
						( !lIpi .And. NoRound(nTotal,2) <> NoRound(nAux,2) )
						
						Help(" ",1,"A410TIPO9")
						
						If ( ExistBlock("A410VTIP") )
							lRet := ExecBlock("A410VTIP",.F.,.F.,{lRet})
							If ValType(lRet) <> "L"
								lRet := .F.
							EndIf							
						EndIf
						
						If SuperGetMV("MV_TIPO9SP",,.T.) //Tipo 9 Sem Parcela informada
							If lRet
								If ( Type("l410Auto") == "U" .or. ! l410Auto )
									OpcQW:=MsgYesNo(OemToAnsi(STR0030),OemToAnsi(STR0014)) //"Confirma a Inclusao do Pedido ?"###"Aten‡„o"
									If !OpcQW // Abandona
										lRet := .F.
									EndIf
								EndIf
							EndIf  
						Else 
							lRet := .F.
						EndIf
					EndIf
				ElseIf AllTrim(SE4->E4_COND) = "%" .And. nAux # 100
					Help(" ",1,"A410TIPO9P")
					
					If ( ExistBlock("A410VTIP") )
						lRet := ExecBlock("A410VTIP",.F.,.F.,{lRet})
						If ValType(lRet) <> "L"
							lRet := .F.
						EndIf							
					EndIf
					
					If SuperGetMV("MV_TIPO9SP",,.T.) //Tipo 9 Sem Parcela informada
						If lRet
							If ( Type("l410Auto") == "U" .or. ! l410Auto )
								OpcQW:=MsgYesNo(OemToAnsi(STR0030),OemToAnsi(STR0014)) //"Confirma a Inclusao do Pedido ?"###"Aten‡„o"
								If !OpcQW // Abandona
									lRet := .F.
								EndIf
							EndIf
						EndIf					
					Else 
						lRet := .F.
					EndIf
					
				EndIf
			EndIf
		EndIf
	EndIf	
EndIf

RestArea(aAreaSE4)
RestArea(aArea)

Return lRet

/*/{Protheus.doc} LxFGrvSFE
	Graba retención de impuestos.
	La función es llamada en FGrvSFE (LOCXNF2.PRW).
	@type  Function
	@author Arturo Samaniego
	@since 28/09/2022
	@param 	cOpc: Opción a realizar: 3=Inclusión; 5=Borrado
			aGrvSFE: Datos de retención.
	@return lRet: Valor .T.
	/*/
Function LxFGrvSFE(cOpc, aGrvSFE)
Local cImpSFE   := ""
Local cTipImp   := ""
Local cNumCert  := ""
Local cDesCert  := ""
Local cConcSFF  := ""
Local nCont		:=0
Local lRet		:=.T.
Local lNumCert	:=.F.
Local cAuxPaisL := "ANG|ARG|AUS|BOL|BRA|CHI|COL|COS|DOM|EQU|EUA|HAI|MEX|PAD|PAN|PAR|PER|POR|PTG|SAL|URU|VEN"
Local cQuery    := ""
Local nVlrRet   := 0

Default cOpc	:=""
Default aGrvSFE	:={}

	If Len(aGrvSFE)>0
		cImpSFE:=""
		cTipImp:=""
		If cOpc=="3"
			DbSelectArea("SFE")
			For nCont:=1 To Len(aGrvSFE)
				If aGrvSFE[nCont][1]$"IRN|IR2|IRA|IMS|PFR|RI2|PFI|RIV"

					cQuery := " SELECT SUM(FE_VALBASE) VLRBAS,SUM(FE_VALIMP) VLRIMP,SUM(FE_RETENC) VLRRET "
					cQuery += " FROM "+RetSqlName("SFE")+" SFE "
					cQuery += " WHERE SFE.D_E_L_E_T_='' "
					cQuery += " AND FE_TIPIMP = '"+aGrvSFE[nCont][1]+"' "
					If aGrvSFE[nCont][1]$"IRP|IRA|IMS|RI2" .And. cPaisLoc $ cAuxPaisL
						cQuery += " AND FE_GRPTRIB = '"+aGrvSFE[nCont][3]+"' "
					Endif
					cQuery += " AND SUBSTRING(FE_EMISSAO,1,6) = '"+SubStr(Dtos(DDATABASE),1,6)+"' "
					cQuery += " AND FE_FORNECE = '"+aGrvSFE[nCont][10]+"' "
					cQuery += " AND FE_LOJA = '"+aGrvSFE[nCont][11]+"' "

					If Select("VALIMP")>0
						DbSelectArea("VALIMP")
						VALIMP->(DbCloseArea())
					Endif

					cQuery:=ChangeQuery(cQuery)
					TcQuery cQuery New Alias "VALIMP"

					nVlrRet:=0
					cConcSFF:=""
					DbSelectArea("VALIMP")
					If aGrvSFE[nCont][1]$"IRP|IRA|IMS|RI2" .And. VALIMP->(!Eof())
						DbSelectArea("SFF")
						SFF->(DbSetOrder(9))
						SFF->(DbGoTop())
						If MsSeek(xFilial("SFF") + AvKey(aGrvSFE[nCont][1],"FF_IMPOSTO") + AvKey(aGrvSFE[nCont][3],"FF_GRUPO")) .And. (aGrvSFE[nCont][2]>0 .OR.aGrvSFE[nCont][1] == "IRA" .OR. aGrvSFE[nCont][1] == "RI2")
							If Substr(aGrvSFE[nCont][12],1,2) <> "NC" .AND. (aGrvSFE[nCont][1] <> "IRP" .OR. aGrvSFE[nCont][1] == "IRA")
								If (VALIMP->VLRBAS+aGrvSFE[nCont][4]) >= xMoeda(SFF->FF_IMPORTE,SFF->FF_MOEDA,1)
									nVlrRet:=(((VALIMP->VLRBAS+aGrvSFE[nCont][4])+Iif("IMS" <> aGrvSFE[nCont][1],0,-xMoeda(SFF->FF_IMPORTE,SFF->FF_MOEDA,1)))*(aGrvSFE[nCont][2]/100))-VALIMP->VLRRET
								Endif
								iF aGrvSFE[nCont][1]=="RI2"
									nVlrRet := aGrvSFE[nCont][6]
								Endif
							Else
								If VALIMP->VLRBAS - aGrvSFE[nCont][4] >= xMoeda(SFF->FF_IMPORTE,SFF->FF_MOEDA,1)
									nVlrRet:=(((VALIMP->VLRBAS-aGrvSFE[nCont][4])+Iif("IMS" <> aGrvSFE[nCont][1],0,-xMoeda(SFF->FF_IMPORTE,SFF->FF_MOEDA,1))) *(aGrvSFE[nCont][2]/100))-VALIMP->VLRRET
								Else
									nVlrRet:=VALIMP->VLRRET
								EndIf
								If aGrvSFE[nCont][1] == "IRA"
									nVlRet := aGrvSFE[nCont][6]
								Endif
								iF aGrvSFE[nCont][1]=="RI2"
									nVlrRet := aGrvSFE[nCont][6]
								Endif
							EndIf
							cConcSFF:=SFF->FF_CONCIRP
						Endif
					Else
						If aGrvSFE[nCont][9]=="E"
							DbSelectArea("SFF")
							SFF->(DbSetOrder(5))//FF_FILIAL+FF_IMPOSTO+FF_CFO_C
							SFF->(DbGoTop())
							If MsSeek(xFilial("SFF") + AvKey(aGrvSFE[nCont][1],"FF_IMPOSTO") + AvKey(aGrvSFE[nCont][15],"FF_CFO_C"))
								cConcSFF:=SFF->FF_CONCIRP
							Endif
						ElseIf aGrvSFE[nCont][9]=="S"
							DbSelectArea("SFF")
							SFF->(DbSetOrder(6))//FF_FILIAL, FF_IMPOSTO, FF_CFO_V
							SFF->(DbGoTop())
							If MsSeek(xFilial("SFF") + AvKey(aGrvSFE[nCont][1],"FF_IMPOSTO") + AvKey(aGrvSFE[nCont][15],"FF_CFO_V"))
								cConcSFF:=SFF->FF_CONCIRP
							Endif
						Endif
						nVlrRet:=aGrvSFE[nCont][6]
					Endif
				Else
					nVlrRet:=aGrvSFE[nCont][6]
				Endif

				If cImpSFE<>aGrvSFE[nCont][1]
					cImpSFE:=aGrvSFE[nCont][1]
					If Alltrim(aGrvSFE[nCont][1])$"IRP|IRN|IR2|IRA|IMS|PFR"
						cTipImp:="R"
					ElseIf Alltrim(aGrvSFE[nCont][1])$"RI2|PFI|IV8|RIV"
						cTipImp:="I"
					ElseIf Alltrim(aGrvSFE[nCont][1])=="ON"
						cTipImp:="O"
					Endif
					lNumCert:=.F.
				Endif
				If aGrvSFE[nCont][5]>0 .Or. (nVlrRet >= 0 .AND. cPaisLoc == "URU")
					If !lNumCert
						If nVlrRet == 0 .OR. Substr(aGrvSFE[nCont][12],1,2)=="NC"
							cDesCert := "NORET"
							lNumCert := .T.
						Else
							DbSelectArea("SX5")
							SX5->(DbGoTop())
							If MsSeek(xFilial("SX5")+"99"+cImpSFE)
								cDesCert := (X5Descri())
								cDesCert := Alltrim(StrZero(VAL(cDesCert)+1,TamSx3("FE_NROCERT")[1]))
								RecLock("SX5",.F.)
								Replace X5_DESCRI	WITH cDesCert
								Replace X5_DESCSPA	WITH cDesCert
								Replace X5_DESCENG	WITH cDesCert
								SX5->(MsUnLock())
								lNumCert:=.T.
							Else
								lNumCert:=.F.
							Endif
						EndIf
					EndIf
					cNumCert:=cDesCert
					If lNumCert
						Begin Transaction
						DbSelectArea("SFE")
						RecLock("SFE",.T.)
						SFE->FE_TIPO	:= cTipImp	   										//Tipo de Imposto
						SFE->FE_FILIAL  := xFilial("SFE")
						If cPaisLoc $ cAuxPaisL
							SFE->FE_TIPIMP	:= aGrvSFE[nCont][1]							//Tipo de Imposto Detalhado
						Endif
						SFE->FE_ALIQ	:= aGrvSFE[nCont][2]								//Aliquota para o Calculo
						If cPaisLoc $ cAuxPaisL
							SFE->FE_GRPTRIB	:= aGrvSFE[nCont][3]							//Grupo Tributacao
						Endif
						If Alltrim(aGrvSFE[nCont][12])=="NCP" .AND. !aGrvSFE[nCont][1] $ "IRP|IRA|RI2"
							SFE->FE_VALBASE	:= Iif(aGrvSFE[nCont][4]<0,aGrvSFE[nCont][4],-aGrvSFE[nCont][4])//Base de calculo da retenção
							SFE->FE_VALIMP	:= Iif(aGrvSFE[nCont][5]<0,aGrvSFE[nCont][5],-aGrvSFE[nCont][5])//Valor do imposto da retenção
							SFE->FE_RETENC	:= Iif(nVlrRet<0, nVlrRet,-nVlrRet)								//Valor da retenção
						Else
							SFE->FE_VALBASE	:= aGrvSFE[nCont][4]											//Base de calculo da retenção
							SFE->FE_VALIMP	:= aGrvSFE[nCont][5]											//Valor do imposto da retenção
							SFE->FE_RETENC	:= nVlrRet  													//Valor da retenção
						Endif
						SFE->FE_NFISCAL	:= aGrvSFE[nCont][7]								//Numero da fatura
						//SFE->FE_SERIE	:= aGrvSFE[nCont][8]								//Serie da fatura
						SerieNfId("SFE",1,"FE_SERIE",,,,aGrvSFE[nCont][8])//Projeto Chave Unica - Tiago Silva
						If aGrvSFE[nCont][9]=="E" .Or. Alltrim(aGrvSFE[nCont][12])=="NCP"//Tipo da Nota(E-Entrada/S-Saida)
							SFE->FE_FORNECE	:= aGrvSFE[nCont][10]							//Codigo do Fornecedor
							SFE->FE_LOJA   	:= aGrvSFE[nCont][11]							//Loja
						Else
							SFE->FE_CLIENTE	:= aGrvSFE[nCont][10]							//Codigo do Cliente
							SFE->FE_LOJCLI  := aGrvSFE[nCont][11]							//Loja
						Endif
						SFE->FE_ESPECIE	:= aGrvSFE[nCont][12]								//Especie
						SFE->FE_NROCERT	:= cNumCert            								//Numero Certificado
						SFE->FE_EMISSAO	:= Iif(Len(aGrvSFE[nCont])>=16 .And. cPaisLoc == "URU",aGrvSFE[nCont][16],dDataBase) 										//Data Emissao
						SFE->FE_CONCEPT := cConcSFF											//Concepto do SFF
						SFE->(MsUnLock())
						End  Transaction
					Endif
				Endif
			Next
		ElseIf cOpc=="5"
			DbSelectArea("SFE")
			If aGrvSFE[1][9]=="E" .or. (aGrvSFE[1][9]=="S" .And. Alltrim(aGrvSFE[1][12])=="NCP")
				SFE->(DbSetOrder(4))//FE_FILIAL, FE_FORNECE, FE_LOJA, FE_NFISCAL, FE_SERIE, FE_TIPO
				SFE->(DbGoTop())
				If DbSeek(xFilial("SFE")+AvKey(aGrvSFE[1][10],"FE_FORNECE")+AvKey(aGrvSFE[1][11],"FE_LOJA")+AvKey(aGrvSFE[1][7],"FE_NFISCAL")+AvKey(aGrvSFE[1][8],"FE_SERIE") )
					Do While SFE->(!Eof()) .And.  Alltrim(SFE->FE_FORNECE)==Alltrim(aGrvSFE[1][10]) .And. Alltrim(SFE->FE_LOJA)==Alltrim(aGrvSFE[1][11]) .And. ;
						Alltrim(SFE->FE_NFISCAL)==Alltrim(aGrvSFE[1][7]) .And. Alltrim(SFE->FE_SERIE)==Alltrim(aGrvSFE[1][8])
						If 	Alltrim(SFE->FE_ESPECIE)==Alltrim(aGrvSFE[1][12])
							RecLock("SFE",.F.)
							DbDelete()
							SFE->(MsUnlock())
						Endif
						SFE->(DbSkip())
					End
				Endif

			Else
				SFE->(DbSetOrder(8))//FE_FILIAL, FE_CLIENTE, FE_LOJA, FE_NFISCAL, FE_SERIE
				SFE->(DbGoTop())
				If DbSeek(xFilial("SFE")+AvKey(aGrvSFE[1][10],"FE_CLIENTE")+AvKey(aGrvSFE[1][11],"FE_LOJCLI")+AvKey(aGrvSFE[1][7],"FE_NFISCAL")+AvKey(aGrvSFE[1][8],"FE_SERIE") )
					Do While SFE->(!Eof()) .And.  Alltrim(SFE->FE_CLIENTE)==Alltrim(aGrvSFE[1][10]) .And. Alltrim(SFE->FE_LOJCLI)==Alltrim(aGrvSFE[1][11]) .And. ;
					Alltrim(SFE->FE_NFISCAL)==Alltrim(aGrvSFE[1][7]) .And. Alltrim(SFE->FE_SERIE)==Alltrim(aGrvSFE[1][8])
						If 	Alltrim(SFE->FE_ESPECIE)==Alltrim(aGrvSFE[1][12])
							RecLock("SFE",.F.)
							DbDelete()
							SFE->(MsUnlock())
						Endif
						SFE->(dbSkip())
					End
				Endif
			Endif
		Endif
	Endif
Return lRet

/*/{Protheus.doc} VDupCGC()
Validación para Permitir clientes con mismo codigo CGC cuando los parámetros 
MV_VALCNPJ y MV_VALCPF son igual a 1.
@author Diego Abel Rivera Hernández
@since 29/12/2022
@version 1.0
@return
/*/
Function VDupCGC()
Default lRet:=.T.

If !(GetNewPar("MV_VALCNPJ","")=="1" .AND. GetNewPar("MV_VALCPF","")=="1")
	lRet:=ExistChav("SA1",M->A1_CGC,3)
EndIf
Return lRet

/*/{Protheus.doc} fDupCGC()
Cuando los parametros MV_VALCNPJ y MV_VALCPF tienen el valor en 2, realiza 
validacion para verificar si existe registro de proveedor 
@author Cristian Eduardo Franco
@since 31/03/2025
@version 1.0
@return lRet Lógico, Determina si es RUC valido para poder incluir nuevo registro
/*/
Function fDupCGC()
Local lRet	:=.T.
Local lCNPJ	:=SuperGetMV("MV_VALCNPJ",.F.,"")
Local lCPF	:=SuperGetMV("MV_VALCPF",.F.,"")
Local aAreaSA2 := {}
Local cAlias := "SA2"
Local lDuplic := .F.
Local cCGC := M->A2_CGC
Local cCod := M->A2_COD
Local cCodExist := ""


	If lCNPJ=="1" .AND. lCPF=="1"
		
		aAreaSA2 := GetArea()
		dbSelectArea(cAlias)
		SA2->(dbSetOrder(3))
		If SA2->(MsSeek(xFilial("SA2")+cCGC))
			While !SA2->(Eof()) .And.  cCGC == SA2->A2_CGC
				If SA2->A2_COD != cCod
					cCodExist := SA2->A2_COD
					lDuplic := .T.
					Exit
				EndIf
				SA2->(DbSkip())
			EndDo
		EndIf

		If lDuplic
			Help("",1,"RUCNOVLD",,STR0033 + cCodExist,1,0,,,,,,{STR0034})//RUC ya existe en el proveedor, Por favor, ingrese un RUC diferente o actualice el registro existente
			lRet := .F.
		EndIf

		RestArea(aAreaSA2)
	Else
		lRet := ExistChav("SA2", cCGC, 3)
	EndIf

Return lRet

/*/{Protheus.doc} RecCostoMI
	Genera el cálculo del costo de entrada. La función es usada en la MATA190.
	@type  Function
	@author luis.samaniego
	@since 14/10/2023
	@param aCusto - Array - Valores para el cálculo del costo de entrada (PASAR POR REFERENCIA EL VALOR @aCusto).
		nTotItem - Numérico - Valor total del ítem sin impuestos.
		nDesc - Numérico - Valor descuento por ítem.
		nRatFrete - Numérico - Valor flete.
		nRatDesp - Numérico - Valor de gastos.
		nRatSeguro - Numérico - Valor del seguro.
		nValIpi - Numérico - Valor del IPI del Item.
		nValIcm - Numérico - Valor del ICMS del Item.
		nVipiAtac - Numérico - Valor del IPI calculado originalmente pela MatxFis.
	@return
	/*/
Function RecCostoMI(aCusto, nTotItem, nDesc, nRatFrete, nRatDesp, nRatSeguro, nValIpi, nValIcm, nVipiAtac)
Local aRet   := {}
Local nCusto := 0

Default aCusto     := {}
Default nTotItem   := 0
Default nDesc      := 0
Default nRatFrete  := 0
Default nRatDesp   := 0
Default nRatSeguro := 0
Default nValIpi    := 0
Default nValIcm    := 0
Default nVipiAtac  := 0

	aRet := ImpCostoMI("SD1", SD1->D1_TES)

	nMoedaNF := SF1->F1_MOEDA
	nCusto := nTotItem * (1 - nDesc / 100) + nRatFrete + nRatDesp + nRatSeguro

	aAdd(aCusto,{ 	nCusto ,;
					nValIpi 		,;
					nValIcm 		,;
					SF4->F4_CREDIPI ,;
					SF4->F4_CREDICM ,;
					SD1->D1_NFORI	,;
					SD1->D1_SERIORI	,;
					SD1->D1_COD		,;
					SD1->D1_LOCAL	,;
					SD1->D1_QTDEDEV	,;
					nVipiAtac 		,;
					SF4->F4_CREDST  ,;
					0               ,;
					aClone(aRet)    ,;
					SF4->F4_PISCOF  ,;
					SF4->F4_PISCRED ,;
					0})

Return

/*/{Protheus.doc} ImpCostoMI
	Obtiene el valor del impuesto para sumar o restar al valor del costo.
	@type  Function
	@author luis.samaniego
	@since 14/10/2023
	@version version
	@param	cAlias - Caracter - Alias de tabla SD1/AD2.
			cTES - Caracter - Código de TES.
	@return aRet - Array - Valores por impuesto.
	/*/
Function ImpCostoMI(cAlias, cTES)
Local aImpInf   := {}
Local aRet      := {}
Local nImposVar := 0
Local nI        := 0

Default cAlias := "SD1"
Default cTES := ""

	If !oJImpTES:HasProperty(cTES)
		aImpInf := TesImpInf(cTES)
		oJImpTES[cTES] := JsonObject():New()
		oJImpTES[cTES]['Impuestos'] := aImpInf
	EndIf

	If oJImpTES:HasProperty(cTES)
		For nI := 1 To Len(oJImpTES[cTES]['Impuestos'])
			nImposVar := 0
			If oJImpTES[cTES]['Impuestos'][nI][5] = '1' //FC_CREDITA = '1-Suma'
				nImposVar := &(cAlias + "->" + oJImpTES[cTES]['Impuestos'][nI][2])
			ElseIf oJImpTES[cTES]['Impuestos'][nI][5] = '2' //FC_CREDITA = '2-Resta'
				nImposVar := &(cAlias + "->" + oJImpTES[cTES]['Impuestos'][nI][2]) * -1 
			EndIf
			If oJImpTES[cTES]['Impuestos'][nI][5] <> '3' //FC_CREDITA # '3-Indiferente'
				Aadd(aRet, {oJImpTES[cTES]['Impuestos'][nI][1], nImposVar})
			EndIf
		Next
	EndIf

Return aClone(aRet)

/*/{Protheus.doc} fGetX3CBox
	Obtiene valor para campos con lista de opciones.
	@type  Function
	@author luis.samaniego
	@since 13/02/2024
	@version 1.0
	@param cField - Character - Nombre de campo en SX3.
	@return cX3Cbox - Character - Lista de opciones.
	/*/
Function fGetX3CBox(cField As Character) As Character
Local cX3Cbox   As Character
Local cFunction As Character
Local cIdiom    As Character
Local cBoxIdiom As Character

Default cField := ""

	cIdiom := FwRetIdiom()

	If cIdiom == 'en' .Or. cIdiom == 'ru'
		cBoxIdiom := 'X3_CBOXENG'
	ElseIf cIdiom == 'es'
		cBoxIdiom := 'X3_CBOXSPA'
	Else
		cBoxIdiom := 'X3_CBOX'
	EndIf

	cX3Cbox  := AllTrim(GetSX3Cache(cField, cBoxIdiom))

	// verifica se possui chamada de função e se a função existe
	If (Left(cX3Cbox, 01) == '#')
		cFunction := SubStr(cX3Cbox, 02)
		If (FindFunction(cFunction))
			cX3Cbox := &(cFunction)
		Else
			cX3Cbox := ''
		EndIf
	EndIf

Return cX3Cbox


/*/{Protheus.doc} VldSX5MINU
    Llama las funciones para validar si existe documentos en la SF3,SF1
    @type  Function
    @author adrian.perez
    @since 07/04/2025
    @param cNum, carácter, numero de documento
    @param cSerie, carácter, serie del documento
    @param cEspecie, carácter, especie del documento
    @param lMostraHelp, booleano, indica si muestra o no la ventana
    @return lRet, booleano, indica si se encontró algún documento que coincida con serie num especie
    /*/

Function VldSX5MINU(cNum,cSerie,cEspecie,lMostraHelp)

Local lRet := .T.

Default cNum:=""
DEFAULT cSerie := ""
DEFAULT cEspecie:=""
Default lMostraHelp := .T.

If ChkF3MI( cSerie,cNum,cEspecie ) .Or. ;
		ChkF1MI( cSerie,cNum,cEspecie )
	If  lMostraHelp
		HELP("  ",1,"EXISTNF")
	EndIf
	lRet := .F.
EndIf

return lRet

/*/{Protheus.doc} ChkF3MI
    Validar si existe documentos en la SF3 que coincida con serie num especie
    @type  Function
    @author adrian.perez
    @since 07/04/2025
    @param cIniNUM, carácter, numero de documento
    @param cIniSER, carácter, serie del documento
    @param cEspecie, carácter, especie del documento
    @return lBack, booleano, indica si se encontró algún documento que coincida con serie num especie
    /*/
Static Function ChkF3MI( cIniSER,cIniNUM,cEspecie )

Local aArea    := GetArea()
Local aAreaSF3 := SF3->(GetArea())
Local lBack    := .F.
Local lSF3     :=  SuperGetMv("MV_CONTNF",.F.,"")=="M"

DEFAULT cIniSER:=""
DEFAULT cIniNUM:=""
DEFAULT	cEspecie:=""

	cEspecie:=ALLTRIM(cEspecie)
	SF3->(DbSelectArea( "SF3" ))
	SF3->(DbSetOrder(5))
	If SF3->(MsSeek( xFilial("SF3")+cIniSER+cIniNUM ))
		While SF3->(!Eof()) .And. (xFilial("SF3")+cIniSER+cIniNUM) == (SF3->F3_FILIAL+SF3->F3_SERIE+SF3->F3_NFISCAL) .And. !lBack
			If ((ALLTRIM(SF3->F3_ESPECIE)==cEspecie)).And. SF3->F3_TIPOMOV == "V"
				If lSF3 .Or. (SF3->F3_TIPO $ "N ")
					If Empty(SF3->F3_DTCANC)  
						lBack := .T.
						Exit
					Else
						lBack := .F.
					Endif
				Endif
			Endif
		SF3->(dbSkip())
		Enddo
	EndIf

RestArea(aAreaSF3)
RestArea(aArea)
Return( lBack )

/*/{Protheus.doc} ChkF1MI
    Validar si existe documentos en la SF1 que coincida con serie num especie
    @type  Function
    @author adrian.perez
    @since 07/04/2025
    @param cIniNUM, carácter, numero de documento
    @param cIniSER, carácter, serie del documento
    @param cEspecie, carácter, especie del documento
    @return lBack, booleano, indica si se encontró algún documento que coincida con serie num especie
    /*/

Static Function ChkF1MI( cIniSER,cIniNUM,cEspecie )

Local aArea    := GetArea()
Local aAreaSF1 := SF1->(GetArea())
Local lBack    := .F.

DEFAULT cIniSER:=""
DEFAULT cIniNUM:=""
DEFAULT	cEspecie:=""

	cEspecie:=ALLTRIM(cEspecie)
	SF1->(DbSelectArea( "SF1" ))
	SF1->(DbSetOrder( 1 ))
	If SF1->(MsSeek( xFilial("SF1")+cIniNUM+cIniSER ))
		While SF1->(!Eof()) .And. (xFilial("SF1")+cIniNUM+cIniSER) == (SF1->F1_FILIAL+SF1->F1_DOC+SF1->F1_SERIE) .And. !lBack
			If (SF1->F1_FORMUL == "S") .AND.  (cEspecie==ALLTRIM(SF1->F1_ESPECIE))
				lBack := .T.
			EndIf
		SF1->(DbSkip())
		EndDo
	EndIf

RestArea(aAreaSF1)
RestArea(aArea)
Return( lBack )

/*/{Protheus.doc} LxFuncUser
    Validar si es un ExecAuto a partir de una User Function
    @type  Function
    @author pedro.candido
    @since 13/06/2025
    @return lRet, booleano, indica si es un ExecAuto a partir de una User Function
    /*/
Function LxFuncUser()

Local nI		:= 0
Local cCalled	:= ""
Local lCond1	:= .F.
Local lCond2	:= .F.
Local lRet		:= .F.

	While !Empty(ProcName(nI))
		cCalled := ProcName(nI)
		If cCalled == "MSEXECAUTO"
			lCond1 := .T.
		ElseIf cCalled == "EXECBLOCK"
			lCond2 := .T.
		ElseIf Left(cCalled,2) == "U_"
			lCond2 := .T.
		EndIf
		nI++
	EndDo

	If lCond1 .And. lCond2
		lRet := .T.
	EndIf

Return lRet
