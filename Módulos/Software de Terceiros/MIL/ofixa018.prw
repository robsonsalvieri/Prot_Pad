#INCLUDE "protheus.ch"
#INCLUDE "DbTree.ch"
#INCLUDE "FWMBROWSE.CH"
#INCLUDE "FWBROWSE.CH"
#INCLUDE "OFIXA018.CH"
#INCLUDE "FWFILTER.CH"
#INCLUDE "FWMVCDEF.CH"

/*
===============================================================================
###############################################################################
##+----------+------------+-------+-----------------------+------+----------+##
##|Funcao    | OFIXA018   | Autor |  Luis Delorme         | Data | 18/07/13 |##
##+----------+------------+-------+-----------------------+------+----------+##
##|Descricao | Painel do OrÁamento                                          |##
##+----------+--------------------------------------------------------------+##
##|Uso       | Oficina                                                      |##
##+----------+--------------------------------------------------------------+##
###############################################################################
===============================================================================
*/
Function OFIXA018()

// Objeto de Tamanho de Tela
Local oSize

// Objetos da Tela
Local oMenuTree
Local nCntFor
Local aSizeAut		:= MsAdvSize(.t.)
Local aCamposPed 	:= ""
Local cIdiom        := FwRetIdiom()
Local cCpoIndice    := IIf(cIdiom=="es","DESCSPA",IIf(cIdiom=="en","DESCENG","DESCRICAO")) // SIX
Local cTitPed       := "LCst"
Local cTitOrc       := "LCst"
Local cAux
//
Private oLayer
Private cAliasAtu
Private oDlgPanOfi

Private aCBoxBrw := {}
Private Browse_W01	// MBrowse do Pedido
Private Browse_W02	// MBrowse do OrÁamento
Private aQuery 			:= Array(2)
Private cRetFilVS1 		:= ""
Private cRFilVS1Ped 	:= ""
Private cRFilVS1Orc 	:= ""
Private lMostraVenc 	:= .f.
Private lMostraFatu 	:= .f.
Private lMostraCanc 	:= .f.
Private lMostraEntr 	:= .f.
Private nOpcEntFut      := 4 // Default: 4 = Todos OrÁamentos de Entrega Futura (com ou sem Remito)
Private lXA018CancPed   := .f.
Private lPedPend        := .f.
Private nOpcPend        := 0

Private aRotina := MenuDef()

Private oFnt3 := TFont():New( "Arial", , 14,.t. )

Private cAuxFilter1 := ""
Private cAuxFilter2 := ""

Private aCores		:= {}
Private cCadastro	:= ""
Private cMotivo		:= "000004"

Private lLibPV    := .f.
Private cTpPesq := space(10)

Private cFilFase18 := ""
Private cFilVend18 := ""

Private of10Verd   := LoadBitmap( GetResources(), "f10_verd" )
Private oBRVERDE   := LoadBitmap( GetResources(), "BR_VERDE" )
Private oBRPINK   := LoadBitmap( GetResources(), "BR_PINK" )
Private oBRBRANCO   := LoadBitmap( GetResources(), "BR_BRANCO" )
Private oBRAZUL   := LoadBitmap( GetResources(), "BR_AZUL" )
Private oBRAZCLARO  := LoadBitmap( GetResources(), "BR_AZUL_CLARO" )
Private oBRMARROM   := LoadBitmap( GetResources(), "BR_MARROM" )
Private oBRCINZA   := LoadBitmap( GetResources(), "BR_CINZA" )
Private oBRAMARELO   := LoadBitmap( GetResources(), "BR_AMARELO" )
Private oBRLARANJA   := LoadBitmap( GetResources(), "BR_LARANJA" )
Private of5amar   := LoadBitmap( GetResources(), "f5_amar" )
Private of12azul   := LoadBitmap( GetResources(), "f12_azul" )
Private of14cinz   := LoadBitmap( GetResources(), "f14_cinz" )
Private of7verm   := LoadBitmap( GetResources(), "f7_verm" )
Private oBRVERMELHO   := LoadBitmap( GetResources(), "BR_VERMELHO" )
Private oBRPRETO   := LoadBitmap( GetResources(), "BR_PRETO" )
Private oBRPRCruz  := LoadBitmap( GetResources(), 'lbok_ocean' )
Private oBRVERDEESC:= LoadBitmap( GetResources(), "BR_VERDE_ESCURO" )
Private nPosStatus
Private nPosTipOrc
Private nPosGerFin
Private nPosPedSta

Private lExistPerg := OXA018ExistPerg()
Private lJaPergXA018 := .f.
Private cFilterSpec := ""
Private nFilQtdDia := 0
Private dFilDatIni := CtoD(" ")
Private dFilDatFim := CtoD(" ")

Private aVS1_TPATEN := X3CBOXAVET( 'VS1_TPATEN' ,"0")
Private aVS1_TIPORC := X3CBOXAVET( 'VS1_TIPORC' ,"0")
Private aVS1_PEDSTA := X3CBOXAVET( 'VS1_PEDSTA' ,"0")
Private aVS1_STARES := X3CBOXAVET( 'VS1_STARES' ,"0")
Private aVS1_TPFATR := X3CBOXAVET( 'VS1_TPFATR' ,"1") // CAMPO DA ARGENTINA

// Private oXA018Faseorc := Mil_FasesOrcamento():New() // Variavel utilizada na funcao OA18DORCS (X3_INIBRW) // Alex - Tornar Classe Obsoleta

Private aStruVS1 := VS1->( DBStruct() )
Private aPed_Cpo_DBtoArray := {}
Private aOrc_Cpo_DBtoArray := {}

Private cXA018FaseConfer := Alltrim(GetNewPar("MV_MIL0095","4")) // Fase de Conferencia e Separacao


Private lPed_AtuStatus := .t.
Private lOrc_AtuStatus := .t.

Private aVS1_SX3 := {}
Private aVS1_EncS := {}
Private aVS1_Cpos := {}
Private aVS1_FechaCpos := {}

Private aVS1_P_SX3 := {}
Private aVS1_P_EncS := {}
Private aVS1_P_Cpos := {}
Private aVS1_P_FechaCpos := {}



//Chamada para validar se a Rotina utiliza a nova reserva
If FindFunction("OA4820295_ValidaAtivacaoReservaRastreavel")
	If !OA4820295_ValidaAtivacaoReservaRastreavel()
		Return .f.
	EndIf
EndIf

VAI->(DbSetOrder(4))
VAI->(MsSeek( xFilial("VAI") + __CUSERID ))

If VAI->VAI_TIPTEC == "4"
	cFilVend18 := " AND VS1_CODVEN = '" + VAI->VAI_CODVEN + "'"
EndIf
If Alltrim(VAI->VAI_FASORC) != ""
	cFilFase18 := " AND VS1_STATUS IN ("
	For nCntFor := 1 to Len(AllTrim(VAI->VAI_FASORC))
		cFilFase18 += "'" + SubStr(AllTrim(VAI->VAI_FASORC),nCntFor,1) + "',"
	Next nCntFor
	cFilFase18 := Left(cFilFase18,Len(cFilFase18)-1) + ")"
EndIf

MaFisFound("NF")

SetStartMod(.t.) // Variavel interna para funcionamento correto dos campos MEMOS na Visualizacao por outras Rotinas

oSize := FwDefSize():New(.f.)

cAliasAtu := ""

DEFINE MSDIALOG oDlgPanOfi TITLE STR0001 PIXEL ;
FROM oSize:aWindSize[1], oSize:aWindSize[2] TO oSize:aWindSize[3], oSize:aWindSize[4] // "Painel de Oficina"

nColTree := INT(aSizeAut[3] * 0.25)
nColResto := INT(aSizeAut[3] * 0.75)

aPosTreeE :={3, 3, aSizeAut[4], nColTree - 3 }
aPosTreeD :={3, nColTree + 3, aSizeAut[4], aSizeAut[3] - 3 }
oMenuTree := Xtree():New(aPosTreeE[1], aPosTreeE[2], aPosTreeE[3], aPosTreeE[4], oDlgPanOfi)    // T L H W

cChavePed := SPACE(100)
cChaveOrc := SPACE(100)
nNormAvaP := 1
nNormAvaO := 1
cIndPedN := " "
cIndOrcN := " "
cIndPedA := " "
cIndOrcA := " "
//
DBSelectArea("SIX")
DBSetOrder(1)
DBSeek("VS1")
aIndex1 := {}
aChave := {}
aIndexTxt1 := {}
cCamposIdx := ""
while !SIX->(eof()) .and. SIX->INDICE == "VS1"
	aAdd(aIndex1, Subs(SIX->CHAVE,12))
	aAdd(aIndexTxt1, &("SIX->"+cCpoIndice))
	cChaveTmp := Alltrim(Subs(SIX->CHAVE,12))
	nPosMais := AT("+",cChaveTmp)
	//	aChaveTmp := {}
	while nPosMais > 0
		//		aAdd(aChaveTmp ,Left(cChaveTmp,nPosMais - 1))
		cCamposIdx +="."+Alltrim(Left(cChaveTmp,nPosMais - 1))
		cChaveTmp := Subs(cChaveTmp,nPosMais + 1)
		nPosMais := AT("+",cChaveTmp)
	enddo
	//	aAdd(aChaveTmp,cChaveTmp)
	cCamposIdx +="." + Alltrim(cChaveTmp)
	//	aAdd(aChave,aChaveTmp)
	SIX->(DBSkip())
enddo
//
If ExistBlock("OX018PBW") // Ponto de Entrada para adicionar campos no Browse de Pedidos
	aCamposPed := ExecBlock("OX018PBW", .f., .f.)
EndIf
//
DBSelectArea("SX3")
DBSetOrder(1)
DBSeek("VS1")
aIndex2 := {}
aIndexTxt2 := {}
while !eof() .and. SX3->X3_ARQUIVO == "VS1"
	if Alltrim(SX3->X3_CAMPO) != "VS1_FILIAL" .and. Alltrim(SX3->X3_CAMPO) $ cCamposIdx .and. SX3->X3_TIPO == "C"
		aAdd(aIndex2,Alltrim(SX3->X3_CAMPO))
		aAdd(aIndexTxt2,Alltrim(SX3->X3_TITULO))
	endif
	DBSkip()
enddo

cNoAvaPed :=    STR0044       
cNoAvaOrc  := STR0044

@ 3, aSizeAut[3] - 3 - 40  - 3 - 30 - 100 - 3 - 100 - 3 - 50 - 3 - 30 - 3  BUTTON oPesq PROMPT STR0041 OF oDlgPanOfi SIZE 30,10 PIXEL ACTION ( OA18FIL(nil,1) )
@ 3, aSizeAut[3] - 3 - 40  - 3 - 30 - 100 - 3 - 100 - 3 - 50 - 3  BUTTON oPesq PROMPT STR0042 OF oDlgPanOfi SIZE 50,10 PIXEL ACTION ( OA18FIL("BROWSE_FILCLEAN",1) )
@ 3, aSizeAut[3] - 3 - 40  - 3 - 30 - 100 - 3 - 100 - 3 COMBOBOX oCbPedN  VAR cIndPedN ITEMS aIndexTxt1 SIZE 100,8 OF oDlgPanOfi  PIXEL
@ 3, aSizeAut[3] - 3 - 40  - 3 - 30 - 100 - 3 - 100 - 3 COMBOBOX oCbPedA  VAR cIndPedA ITEMS aIndexTxt2 SIZE 100,8 OF oDlgPanOfi  PIXEL
@ 3, aSizeAut[3] - 3 - 40  - 3 - 30 - 100 - 3 MSGET oMotivo VAR cChavePed PICTURE "@!" SIZE 100,08 OF oDlgPanOfi PIXEL
@ 3, aSizeAut[3] - 3 - 40  - 3 - 30           BUTTON oSalvar PROMPT STR0043 OF oDlgPanOfi SIZE 30,10 PIXEL ACTION ( FS_PESQPED(0)  )
@ 3, aSizeAut[3] - 3 - 40          COMBOBOX oLimite  VAR cNoAvaPed ITEMS {STR0044,STR0045} VALID (OXA018MCB(0)) SIZE 40,8 OF oDlgPanOfi  PIXEL

oLbPedi := TWBrowse():New(16,nColTree + 3 ,nColResto - 3 ,aPosTreeE[3] /2 - 16,,,,oDlgPanOfi,,,,,{ || .t. },,,,,,,.F.,,.T.,,.F.,,,)

@ aPosTreeE[3] /2 + 3 , aSizeAut[3] - 3 - 40 - 3 - 30 - 100 - 3 - 100 - 3 - 50 - 3 - 30 - 3 BUTTON oPesq PROMPT STR0041 OF oDlgPanOfi SIZE 30,10 PIXEL ACTION ( OA18FIL(nil,2) )
@ aPosTreeE[3] /2 + 3 , aSizeAut[3] - 3 - 40 - 3 - 30 - 100 - 3 - 100 - 3 - 50 - 3  BUTTON oPesq PROMPT STR0042 OF oDlgPanOfi SIZE 50,10 PIXEL ACTION ( OA18FIL("BROWSE_FILCLEAN",2) )
@ aPosTreeE[3] /2 + 3 , aSizeAut[3] - 3 - 40 - 3 - 30 - 100 - 3 - 100 - 3 COMBOBOX oCbOrcN  VAR cIndOrcN ITEMS aIndexTxt1 SIZE 100,8 OF oDlgPanOfi  PIXEL
@ aPosTreeE[3] /2 + 3 , aSizeAut[3] - 3 - 40 - 3 - 30 - 100 - 3 - 100 - 3 COMBOBOX oCbOrcA  VAR cIndOrcA ITEMS aIndexTxt2 SIZE 100,8 OF oDlgPanOfi  PIXEL
@ aPosTreeE[3] /2 + 3 , aSizeAut[3] - 3 - 40 - 3 - 30 - 100 - 3 MSGET oMotivo VAR cChaveOrc PICTURE "@!" SIZE 100,08 OF oDlgPanOfi PIXEL
@ aPosTreeE[3] /2 + 3 , aSizeAut[3] - 3 - 40 - 3 - 30           BUTTON oSalvar PROMPT STR0043 OF oDlgPanOfi SIZE 30,10 PIXEL ACTION ( FS_PESQPED(1) )
@ aPosTreeE[3] /2 + 3 , aSizeAut[3] - 3 - 40 COMBOBOX oLimite  VAR cNoAvaOrc ITEMS {STR0044,STR0045} VALID (OXA018MCB(1)) SIZE 40,8 OF oDlgPanOfi  PIXEL

oCbPedA:lVisible := .f.
oCbOrcA:lVisible := .f.

oLbOrcs := TWBrowse():New(aPosTreeE[3] /2 + 16,nColTree + 3,nColResto - 3 , aPosTreeE[3] /2 - 16,,,,oDlgPanOfi,,,,,{ || .t. },,,,,,,.F.,,.T.,,.F.,,,)
//
nCntFor := 1
aLbPedi := {}
aLbOrcs := {}
aLbTmp := {{}}
aLBCampos :={}
 
oLbPedi:addColumn( TCColumn():New( " ", { || OA18ROBJPD() } ,,,,'LEFT' ,10,.t.))
oLbOrcs:addColumn( TCColumn():New( " ", { || OA18ROBJOR() } ,,,,'LEFT' ,10,.t.))

if existBlock("OX018LPD")
	cAux := execblock("OX018LPD",.F.,.F.,{0})
	if valType(cAux) == "C"
		cTitPed := cAux
	endif
	oLbPedi:addColumn( TCColumn():New( cTitPed, { || execblock("OX018LPD",.F.,.F.,{2}) } ,,,,'LEFT' ,10,.t.))
endif

if existBlock("OX018LOR")
	cAux := execblock("OX018LOR",.F.,.F.,{0})
	if valType(cAux) == "C"
		cTitOrc := cAux
	endif
	oLbOrcs:addColumn( TCColumn():New( cTitOrc, { || execblock("OX018LOR",.F.,.F.,{2}) } ,,,,'LEFT' ,10,.t.))
endif

// InserÁ„o do campo VS1_PEDREF na primeira coluna do Browse inferior (OrÁamentos)
DBSelectArea("SX3")
DBSetOrder(2)
If DBSeek("VS1_PEDREF")
	cMacroOrcs :="Transform(aLbOrcs[oLbOrcs:nAt," + Alltrim(str(nCntFor)) + "],'"+IIF(Empty(SX3->X3_PICTURE),"@!",Alltrim(SX3->X3_PICTURE))+"')"
	nTamCol := MAX(Len(Alltrim(RetTitle(SX3->X3_CAMPO))),TamSX3(SX3->X3_CAMPO)[1]) * 4
	oColOrc := &("TCColumn():New( RetTitle(SX3->X3_CAMPO), { || "+ cMacroOrcs +"} ,,,,'LEFT' ,"+Alltrim(STR(nTamCol)) +") ")

	AaDD(aLbTmp[1],"")

	aAdd (aLbCampos, {X3_CAMPO,X3_INIBRW, X3_CONTEXT, X3_TIPO})
	oLbOrcs:addColumn( oColOrc )

endif                                                          
nCntFor+=1

DBSelectArea("SX3")
DBSetOrder(1)
DBSeek("VS1")
//
while !eof() .and. SX3->X3_ARQUIVO == "VS1"
	if X3USO(SX3->X3_USADO) .And. ( SX3->X3_BROWSE == "S" .or. Alltrim(SX3->X3_CAMPO) $ cCamposIdx .or. Alltrim(SX3->X3_CAMPO) $ aCamposPed )
		cMacroPedi :="Transform(aLbPedi[oLbPedi:nAt," + Alltrim(str(nCntFor)) + "],'"+IIF(Empty(SX3->X3_PICTURE),"@!",Alltrim(SX3->X3_PICTURE))+"')"
		cMacroOrcs :="Transform(aLbOrcs[oLbOrcs:nAt," + Alltrim(str(nCntFor)) + "],'"+IIF(Empty(SX3->X3_PICTURE),"@!",Alltrim(SX3->X3_PICTURE))+"')"
		nTamCol := MAX(Len(Alltrim(RetTitle(SX3->X3_CAMPO))),TamSX3(SX3->X3_CAMPO)[1]) * 4

		oColPed := &("TCColumn():New( RetTitle(SX3->X3_CAMPO), { || "+ cMacroPedi +"} ,,,,'LEFT' ,"+Alltrim(STR(nTamCol)) +") ")
		oColOrc := &("TCColumn():New( RetTitle(SX3->X3_CAMPO), { || "+ cMacroOrcs +"} ,,,,'LEFT' ,"+Alltrim(STR(nTamCol)) +") ")


		AaDD(aLbTmp[1],"")
		if  X3_CAMPO != "VS1_NOROUT" .AND. X3_CAMPO != "VS1_STATUS" .AND. X3_CAMPO != "VS1_PEDSTA" .AND.;
			X3_CAMPO != "VS1_ORCACE" .AND. X3_CAMPO != "VS1_STARES" .AND. X3_CAMPO != "VS1_TIPORC" .AND.;
			X3_CAMPO != "VS1_TPATEN"

			// Isso pega os valores que tem uso de orÁamento posicionado
			// e transfere para usar o alias da query
			// foi necess·rio por performance, cliente abriu chamado reclamando
			// mas a estrutura do fonte nao deixa usar posicionamento ou a tela fica inutilizavel de lenta
			cAuxIniBrw := X3_INIBRW
			if 'X3CBOXDESC' $ cAuxIniBrw
				do case
					case 'VS1_TPATEN' $ cAuxIniBrw
						cAuxiniBrw := OXA018AjIniBrw(cAuxIniBrw, 'VS1_TPATEN')
					case 'VS1_TIPORC' $ cAuxIniBrw
						cAuxiniBrw := OXA018AjIniBrw(cAuxIniBrw, 'VS1_TIPORC')
					case 'VS1_PEDSTA' $ cAuxIniBrw
						cAuxiniBrw := OXA018AjIniBrw(cAuxIniBrw, 'VS1_PEDSTA')
					case 'VS1_STARES' $ cAuxIniBrw
						cAuxiniBrw := OXA018AjIniBrw(cAuxIniBrw, 'VS1_STARES')
				end case
				cAuxIniBrw := AllTrim(cAuxIniBrw)
			elseIf Empty(cAuxIniBrw) .and. X3_CAMPO == "VS1_STARES"
				cAuxIniBrw := "X3CBOXDESC('VS1_STARES', (cQryAl001)->VS1_STARES, aVS1_STARES)"
			elseIf Empty(cAuxIniBrw) .and. X3_CAMPO == "VS1_TPFATR"
				cAuxIniBrw := "X3CBOXDESC('VS1_TPFATR', (cQryAl001)->VS1_TPFATR, aVS1_TPFATR)"
			endif

			if (! Empty(cAuxIniBrw) .and. "VS1->" $ X3_INIBRW)
				cAuxIniBrw := strtran(cAuxIniBrw, "VS1->", "(cQryAl001)->")
			endif

			aAdd (aLbCampos, {X3_CAMPO, cAuxIniBrw, X3_CONTEXT, X3_TIPO}) // trocando para query para pegar do cache nao do vs1 posicionado

			if X3_CAMPO == "VS1_DTPSTP" .Or. Alltrim(SX3->X3_CAMPO) $ aCamposPed// sÛ aparece no pedido // PE
				oLbPedi:addColumn( oColPed )
			ElseIf X3_CAMPO $ "VS1_DSSTAT/VS1_TPFATR/VS1_REMITO/VS1_SERREM/" // sÛ aparece no orÁamento
				oLbOrcs:addColumn( oColOrc )
			ElseIf X3_CAMPO == "VS1_PEDREF" // ja foi inserido, n„o insere mais
				DBSkip()
				Loop
			else
				oLbPedi:addColumn( oColPed )
				oLbOrcs:addColumn( oColOrc )
			endif

			nCntFor += 1
		EndIf
		
	endif
	DBSkip()
enddo

aAdd (aLbCampos, {"VS1_STATUS", '', 'R', 'C'})
aAdd (aLbCampos, {"VS1_TIPORC", '', 'R', 'C'})
aAdd (aLbCampos, {"VS1_GERFIN", '', 'R', 'C'})
aAdd (aLbCampos, {"VS1_PEDSTA", '', 'R', 'C'})

//
aLbVaz := {}
aLbVazT := {}
for nCntFor := 1 to Len(aLbCampos)
	if aLbCampos[nCntFor,4] == "C"
		aAdd(aLbVazT,"")
	elseif aLbCampos[nCntFor,4] == "N"
		aAdd(aLbVazT,0)
	elseif aLbCampos[nCntFor,4] == "D"
		aAdd(aLbVazT,ctod("  /  /  "))
	endif
next
aAdd(aLbVaz,aLbVazT)

nPosStatus := aScan( aLBCampos, { |x| x[1] == "VS1_STATUS" } )
nPosTipOrc := aScan( aLBCampos, { |x| x[1] == "VS1_TIPORC" } )
nPosGerFin := aScan( aLBCampos, { |x| x[1] == "VS1_GERFIN" } )
nPosPedSta := aScan( aLBCampos, { |x| x[1] == "VS1_PEDSTA" } )

nPosNumOrc := aScan( aLbCampos , { |x| Alltrim(x[1]) == "VS1_NUMORC" } )
//
aAdd(aLbPedi,aLbTmp)
aAdd(aLbOrcs,aLbTmp)
//
OXA018CMENU(oMenuTree)

OXA018MTPD()
OXA018MTOR()

oDlgPanOfi:Activate()

If ExistFunc("OX001CleanCache")
	OX001CleanCache()
EndIf

Return

/*
===============================================================================
###############################################################################
##+----------+-------------+-------+----------------------+------+----------+##
##|Funcao    | OXA018MTPD  | Autor |  Luis Delorme        | Data | 26/02/13 |##
##+----------+-------------+-------+----------------------+------+----------+##
##|Descricao | Cria Menu do Painel                                          |##
##+----------+--------------------------------------------------------------+##
##|Parametro | oMenuTree -> Objeto do Menu                                  |##
##+----------+--------------------------------------------------------------+##
##|Uso       | Oficina                                                      |##
##+----------+--------------------------------------------------------------+##
###############################################################################
===============================================================================
*/
Function OXA018MTPD(cFilVS1, cOrcVS1)
Local nCntFor
Local nQtdRec
Local aAuxDados
Local cFil_FatCanc := ""
Local cFil_Status := ""

Default cFilVS1 := ""
Default cOrcVS1 := ""

//
cQryAl001 := GetNextAlias()

If ! lMostraFatu .and. ! lMostraCanc
	cFil_Status := "23"
EndIf

If lMostraFatu 
	cFil_FatCanc += "2"
	If ! lMostraCanc
		cFil_Status := "3" // Oculta Cancelados
	EndIf
EndIf

If lMostraCanc
	cFil_FatCanc += "3"
	If ! lMostraFatu
		cFil_Status := "2" // Oculta Faturados
	EndIf
EndIf

If ! Empty(cFil_FatCanc)
	cFil_FatCanc := FormatIn(cFil_FatCanc,,1)
EndIf

If ! Empty(cFil_Status)
	cFil_Status := FormatIn(cFil_Status,,1)
EndIf

cQuery := " FROM "+RetSQLName("VS1")
cQuery += " WHERE VS1_FILIAL ='"+xFilial("VS1")+"'"

// Filtro de Mostra ou Oculta Vencidos 
If lMostraVenc .and. ! Empty(cFilterSpec)
	cQuery += " AND ( VS1_DATVAL >= '" + dtos(ddatabase) + "'"
	cQuery += " OR ( VS1_DATVAL < '" + dtos(ddatabase) + "' " + cFilterSpec + " ) "
	If ! Empty(cFil_FatCanc)
		cQuery += " OR VS1_PEDSTA IN " + cFil_FatCanc
	EndIf
	cQuery += " )"
ElseIf lMostraVenc .and. Empty(cFilterSpec)
	// Nao precisa de filtro
ElseIf ! lMostraVenc
	cQuery += " AND ( VS1_DATVAL >= '" + dtos(ddatabase) + "'"
	If ! Empty(cFil_FatCanc)
		cQuery += " OR VS1_PEDSTA IN " + cFil_FatCanc
	EndIf
	cQuery += " )"
EndIf
// FIM - Filtro de Mostra ou Oculta Vencidos 

// Filtro de Mostra ou Oculta Cancelados / Faturados 
If Empty( cFil_Status ) .and. Empty(cFilterSpec)
	// Nao precisa de filtro
ElseIf ! lMostraCanc .and. ! lMostraFatu
	cQuery += " AND VS1_PEDSTA NOT IN ('2','3') "
ElseIf Empty(cFilterSpec)
	cQuery += " AND VS1_PEDSTA NOT IN " + cFil_Status
ElseIf (lMostraCanc .or. lMostraFatu) .and. ! Empty(cFilterSpec)
	cQuery += " AND ( VS1_PEDSTA NOT IN ('2','3') "
	cQuery += " OR ( VS1_PEDSTA IN " + cFil_FatCanc
	If ! Empty(cFilterSpec)
		cQuery += cFilterSpec
	EndIf
	cQuery += " )) "
EndIf
// FIM - Filtro de Mostra ou Oculta Cancelados / Faturados 

If lPedPend
	cQuery += OX018009D_Qry_PedidosPendentes() // Monta SQL com os Filtros dos Pedidos Pendentes
EndIf

cQuery += " AND VS1_TIPORC = 'P'"
cQuery += " AND D_E_L_E_T_ = ' ' " + cFilVend18 + cFilFase18 + cRFilVS1Ped

For nCntFor := 1 to Len(aLbPedi)
	aSize(aLbPedi[nCntFor],0)
Next nCntFor
aSize(aLbPedi,0)

nQtdRec := FM_SQL("SELECT COUNT(*) " + cQuery)
If nQtdRec == 0
	INCLUI := .F.
	VISUALIZA := .T.
	aLbPedi := aClone(aLbVaz) 
	oLbPedi:SetArray(aLbPedi)
	oLbPedi:Refresh()
	Return
EndIf

dbUseArea( .T., "TOPCONN", TcGenQry( ,, "SELECT * " + cQuery + "  ORDER BY VS1_FILIAL, VS1_NUMORC " ), cQryAl001, .F., .T. )
OXA018TCSetField(cQryAl001)
If Len(aPed_Cpo_DBtoArray) == 0
	OXA018MontaDBtoArrayListbox(cQryAl001, aLbCampos, @aPed_Cpo_DBtoArray)
EndIf

aLbPedi := Array(nQtdRec, Len(aLbPedi))

if !(cQryAl001)->(eof())

	INCLUI := .F.
	VISUALIZA := .T.

	aSize(aLbPedi, nQtdRec )
	//aFill(aLbPedi, aClone(Array(Len(aLBCampos))))
	nQtdRec := 0
	aAuxDados := Array(Len(aLBCampos))
	dbSelectArea(cQryAl001)
	while !(cQryAl001)->(eof())
		nQtdRec++

		for nCntFor := 1 to Len(aLbCampos)
			if aLbCampos[nCntFor,3] != "V"
				aAuxDados[nCntFor] := (cQryAl001)->(FieldGet(aPed_Cpo_DBtoArray[nCntFor]))
			else
				aAuxDados[nCntFor] := (cQryAl001)->&(aLbCampos[nCntFor,2])
			endif
		next
		aLbPedi[nQtdRec] := aClone(aAuxDados)
		(cQryAl001)->(DBSkip())
	enddo
	lPed_AtuStatus := .f.
	oLbPedi:SetArray(aLbPedi)
	if !Empty(cOrcVS1)
		nPos := aScan(aLbPedi, { |x| Alltrim(x[nPosNumOrc]) == Alltrim(cOrcVS1)  } )
		if nPos > 0 
			oLbPedi:nAt := nPos
		endif
	endif
	oLbPedi:Refresh()
	lPed_AtuStatus := .t.
endif

(cQryAl001)->(DBCloseArea())
return

/*
===============================================================================
###############################################################################
##+----------+-------------+-------+----------------------+------+----------+##
##|Funcao    | OXA018MTOR  | Autor |  Luis Delorme        | Data | 26/02/13 |##
##+----------+-------------+-------+----------------------+------+----------+##
##|Descricao | Cria Menu do Painel                                          |##
##+----------+--------------------------------------------------------------+##
##|Parametro | oMenuTree -> Objeto do Menu                                  |##
##+----------+--------------------------------------------------------------+##
##|Uso       | Oficina                                                      |##
##+----------+--------------------------------------------------------------+##
###############################################################################
===============================================================================
*/
Function OXA018MTOR(cFilVS1, cOrcVS1)
Local nCntFor
Local cFiltroX18 := ""
Local nQtdRec
Local aAuxDados
Local cFil_FatCanc := ""
Local cFil_Status := ""

Default cFilVS1 := ""
Default cOrcVS1 := ""

cQryAl001 := GetNextAlias()

If ! lMostraFatu .and. ! lMostraCanc
	cFil_Status := "XC"
EndIf

If lMostraFatu 
	cFil_FatCanc += "X"
	If ! lMostraCanc
		cFil_Status := "C" // Oculta Cancelados
	EndIf
EndIf

If lMostraCanc
	cFil_FatCanc += "C"
	If ! lMostraFatu
		cFil_Status := "X" // Oculta Faturados
	EndIf
EndIf

If ! Empty(cFil_FatCanc)
	cFil_FatCanc := FormatIn(cFil_FatCanc,,1)
EndIf

If ! Empty(cFil_Status)
	cFil_Status := FormatIn(cFil_Status,,1)
EndIf


cQuery := " FROM "+RetSQLName("VS1")
cQuery += " WHERE VS1_FILIAL ='"+xFilial("VS1")+"'"

// Filtro de Mostra ou Oculta Vencidos 
If lMostraVenc .and. ! Empty(cFilterSpec)
	cQuery += " AND ( VS1_DATVAL >= '" + dtos(ddatabase) + "'"
	cQuery += " OR ( VS1_DATVAL < '" + dtos(ddatabase) + "' " + cFilterSpec + " ) "
	If ! Empty(cFil_FatCanc)
		cQuery += " OR VS1_STATUS IN " + cFil_FatCanc
	EndIf
	cQuery += " ) "
	If lMostraEntr
		cQuery += "AND VS1_STATUS = 'X' AND VS1_TPFATR = '4'"
		cQuery += OX0180061_SQL_EntregaFutura() // Monta SQL com os Filtros da Venda Entrega Futura
	EndIf
ElseIf lMostraVenc .and. Empty(cFilterSpec)
	// Nao precisa de filtro
ElseIf ! lMostraVenc
	cQuery += " AND ( VS1_DATVAL >= '" + dtos(ddatabase) + "'"
	If ! Empty(cFil_FatCanc)
		cQuery += " OR VS1_STATUS IN " + cFil_FatCanc
	EndIf
	cQuery += " ) "
	If lMostraEntr
		cQuery += "AND VS1_STATUS = 'X' AND VS1_TPFATR = '4'"
		cQuery += OX0180061_SQL_EntregaFutura() // Monta SQL com os Filtros da Venda Entrega Futura
	EndIf
EndIf
// FIM - Filtro de Mostra ou Oculta Vencidos 

// Filtro de Mostra ou Oculta Cancelados / Faturados 
If Empty( cFil_Status ) .and. Empty(cFilterSpec)
	// Nao precisa de filtro
ElseIf ! lMostraCanc .and. ! lMostraFatu .and. ! lMostraEntr
	cQuery += " AND VS1_STATUS NOT IN ('X','C') "
ElseIf Empty(cFilterSpec)
	cQuery += " AND VS1_STATUS NOT IN " + cFil_Status
ElseIf (lMostraCanc .or. lMostraFatu) .and. ! Empty(cFilterSpec)
	cQuery += " AND ( VS1_STATUS NOT IN ('X','C') "
	cQuery += " OR ( VS1_STATUS IN " + cFil_FatCanc
	If ! Empty(cFilterSpec)
		cQuery += cFilterSpec
	EndIf
	cQuery += " )) "
EndIf
// FIM - Filtro de Mostra ou Oculta Cancelados / Faturados 

If ExistBlock("OX018FBR") // Ponto de Entrada para Filtro dos OrÁamentos no Browse
	cFiltroX18 := ExecBlock("OX018FBR", .f., .f.)
EndIf

If Empty(Alltrim(cFiltroX18))
	cFiltroX18 := " AND VS1_TIPORC IN ('1','2') "
EndIf
cQuery += " AND D_E_L_E_T_ = ' ' " + cFilVend18 + cFilFase18 + cRFilVS1Orc + cFiltroX18

For nCntFor := 1 to Len(aLbOrcs)
	aSize(aLbOrcs[nCntFor],0)
Next nCntFor
aSize(aLbOrcs,0) // Libera memoria 

nQtdRec := FM_SQL("SELECT COUNT(*) " + cQuery)
If nQtdRec == 0
	INCLUI := .F.
	VISUALIZA := .T.
	aLbOrcs := aClone(aLbVaz) 
	oLbOrcs:SetArray(aLbOrcs)
	oLbOrcs:Refresh()
	Return
EndIf

dbUseArea( .T., "TOPCONN", TcGenQry( ,, "SELECT * " + cQuery + " ORDER BY VS1_FILIAL, VS1_NUMORC " ), cQryAl001, .F., .T. )

OXA018TCSetField(cQryAl001)
If Len(aOrc_Cpo_DBtoArray) == 0
	OXA018MontaDBtoArrayListbox(cQryAl001, aLbCampos, @aOrc_Cpo_DBtoArray)
EndIf

aLbOrcs := Array(nQtdRec, Len(aLbCampos) )
if !(cQryAl001)->(eof())
	INCLUI := .F.
	VISUALIZA := .T.

	aSize(aLbOrcs, nQtdRec )
	//aFill(aLbOrcs, Array(Len(aLBCampos)))
	aAuxDados := Array(Len(aLBCampos))
	nQtdRec := 0
	dbSelectArea(cQryAl001)
	while !(cQryAl001)->(eof())
		nQtdRec++

		for nCntFor := 1 to Len(aLbCampos)
			if aLbCampos[nCntFor,3] != "V" .and. aLbCampos[nCntFor][1] != "VS1_TPFATR"
				aAuxDados[nCntFor] := (cQryAl001)->(FieldGet(aOrc_Cpo_DBtoArray[nCntFor]))
			else
				aAuxDados[nCntFor] := (cQryAl001)->&(aLbCampos[nCntFor,2])
			endif
		next
		
		aLbOrcs[nQtdRec] := aClone(aAuxDados)
		
		(cQryAl001)->(DBSkip())
	enddo

	If cPaisLoc == "ARG"
		cNumOrcIN := ""
		For nCntFor := 1 to Len(aLbOrcs)
			cNumOrcIN += If(Empty(cNumOrcIN),"",",") + "'" + aLbOrcs[nCntFor,2] + "'"
		Next
		If !Empty(cNumOrcIN)
			aDevRemSai := OX0180049_DevolucoesRemitoSaida(cNumOrcIN)
			aLbOrcsX := {}
			For nCntFor := 1 to Len(aLbOrcs)
				// Se for DevoluÁ„o Total, atualiza o status para X=Faturado e n„o mostra no browse
				If Ascan(aDevRemSai,{|x| x[1] == aLbOrcs[nCntFor,nPosNumOrc]}) > 0 .and. Ascan(aDevRemSai,{|x| x[1] == aLbOrcs[nCntFor,nPosNumOrc] .and. x[2] == "Total"}) > 0
					VS1->(dbSetOrder(1))
					If VS1->(dbSeek(xFilial("VS1") + aLbOrcs[nCntFor,nPosNumOrc])) // Posiciona no VS1
						If VS1->VS1_STATUS <> "X"
							DbSelectArea("VS1")
							RecLock("VS1",.f.)
							VS1->VS1_STATUS := "X" // X=Faturado
							MsUnLock()
						EndIf
					EndIf
				Else
					AAdd(aLbOrcsX,Aclone(aLbOrcs[nCntFor]))
				EndIf
			Next
			If Len(aLbOrcs) <> Len(aLbOrcsX)
				aLbOrcs := Aclone(aLbOrcsX)
			EndIf
			aLbOrcsX := {}
			If Len(aLbOrcs) == 0
				INCLUI := .F.
				VISUALIZA := .T.
				aLbOrcs := aClone(aLbVaz) 
				oLbOrcs:SetArray(aLbOrcs)
				oLbOrcs:Refresh()
				Return
			EndIf
		EndIf
	EndIf

	lOrc_AtuStatus := .F.
	oLbOrcs:SetArray(aLbOrcs)
	if !Empty(cOrcVS1)
		nPos := aScan(aLbOrcs, { |x| Alltrim(x[nPosNumOrc]) == Alltrim(cOrcVS1)  } )
		if nPos > 0 
			oLbOrcs:nAt := nPos
		endif
	endif
	oLbOrcs:Refresh()
	lOrc_AtuStatus := .T.
endif

(cQryAl001)->(DBCloseArea())
return

/*
===============================================================================
###############################################################################
##+----------+-------------+-------+----------------------+------+----------+##
##|Funcao    | OXA018CMENU | Autor |  Takahashi           | Data | 28/02/13 |##
##+----------+-------------+-------+----------------------+------+----------+##
##|Descricao | Cria Menu do Painel                                          |##
##+----------+--------------------------------------------------------------+##
##|Parametro | oMenuTree -> Objeto do Menu                                  |##
##+----------+--------------------------------------------------------------+##
##|Uso       | Oficina                                                      |##
##+----------+--------------------------------------------------------------+##
###############################################################################
===============================================================================
*/
Static Function OXA018CMENU(oMenuTree)

//Local aAuxAcesso
Local nCont
Local aMenu := {}
// Private oRpm := OFJDRpmConfig():New()
// Private lMostraEstoque := oRpm:MostraEstoqueAoDigitar()

/*
Estrutura da Matriz aMenu
[01] - Nome do Menu
[02] - Nome do Pai
[03] - Descricao (Menu)
[04] - Tabela para Browse
[05] - Funcao para analisar no Acesso no Menu (XNU)
[06] - Funcao executada ao selecionar opcao do menu
[07] - nOpc da Rotina
[08] - Indica se È uma opcao de Inclusao (utilizado so para reposicionar browse)
*/

/*
Caso seja inserida uma opÁ„o no menu que necessite de validacao de usuario, È necessario inseri-lo na funcao FS_CHKUSU
de acordo com a posicao no campo VAI_MNUPNL 
*/

aAuxAcesso := FMX_LEVXNU(nModulo)

// AADD( aMenu , {"","","","","",STR0031,0,.f. } )          // Pesquisa

// Menu do Pedido de Venda  //
AADD( aMenu , { "NODE_PV"   ,""       ,STR0022 ,"VS1P","OFIXA018","",0,.f. } )          // "OrÁamento"
AADD( aMenu , { "NODE_PV_V" ,"NODE_PV",OemtoAnsi(STR0007),"VS1P","OFIXA018","OXA012V",02,.f. } ) // "Visualizar"
AADD( aMenu , { "NODE_PV_I" ,"NODE_PV",OemtoAnsi(STR0008),"VS1P","OFIXA018","OXA012I",03,.t. } ) // "Incluir"
AADD( aMenu , { "NODE_PV_T" ,"NODE_PV",OemtoAnsi(STR0015),"VS1P","OFIXA018","OXA012A",04,.t. } ) // "Alterar"
AADD( aMenu , { "NODE_PV_A" ,"NODE_PV",OemtoAnsi(STR0009),"VS1P","OFIXA018","OXA012CP",05,.f. } ) // "Cancelar Parcial"
AADD( aMenu , { "NODE_PV_C" ,"NODE_PV",OemtoAnsi(STR0010),"VS1P","OFIXA018","OXA012CT",05,.f. } ) // "Cancelar Total"
AADD( aMenu , { "NODE_PV_F" ,"NODE_PV",OemtoAnsi(STR0011),"VS1P","OFIXA018","OXA012FP",06,.f. } ) // "Faturar"      ' 
AADD( aMenu , { "NODE_PV_P" ,"NODE_PV",OemtoAnsi(STR0018),"VS1P","OFIXA018","OXA011CLO",06,.f. } ) // "Clonar"
AADD( aMenu , { "NODE_PV_P" ,"NODE_PV",OemtoAnsi(STR0068),"VS1P","OFIXA018","OXA011LIB",06,.f. } ) // "Liberar Itens com Saldo"
AADD( aMenu , { "NODE_PV_RO","NODE_PV",STR0049,"VS1P","OFIXA018","OXA018RO",01,.f. } ) // Rastreamento Orcamento
AADD( aMenu , { "NODE_PV_L" ,"NODE_PV",OemtoAnsi(STR0012),"VS1P","OFIXA018","OXA012LEG",08,.f. } ) // "Legenda"
AaDD( aMenu , { "NODE_PV_T" ,"NODE_PV",STR0062,   "VS1P","OFINJD28","OXA018DRE", 01, .f. }) // Demanda Retro 01-Pedido

AADD( aMenu , {"","","","","", STR0120,0,.f.} ) // Filtro de PendÍncias do Pedido



// Menu de OrÁamento //
AADD( aMenu , { "NODE_OR"   ,""       ,STR0014    ,"VS1","OFIXA011","",0,.f. } )          //
AADD( aMenu , { "NODE_OF_V" ,"NODE_OR",STR0007   ,"VS1","OFIXA011","OFIXA011",02,.f. } ) //
//AADD( aMenu , { "NODE_OF_I" ,"NODE_OR",STR0008      ,"VS1_2","OFIXA011","OFIXA011",03,.t. } ) //
AADD( aMenu , { "NODE_OF_A" ,"NODE_OR",STR0015      ,"VS1","OFIXA011","OFIXA011",04,.f. } ) //
AADD( aMenu , { "NODE_OF_C" ,"NODE_OR",STR0016     ,"VS1","OFIXA011","OFIXA011",05,.f. } ) //
AADD( aMenu , { "NODE_OF_F" ,"NODE_OR",STR0017      ,"VS1","OFIXA011","OFIXA011",06,.f. } ) //
//if ! lMostraEstoque // se desativado o nivel de atendimento
	AADD( aMenu , { "NODE_OF_C1","NODE_OR",STR0018       ,"VS1","OFIXA011","OFIXA011",07,.f. } ) //
	AADD( aMenu , { "NODE_OF_C2","NODE_OR",STR0019,"VS1","OFIXA011","OXA011COS",00,.f. } ) //
//Endif	
If FindFunction("OFIOC430") //se existir a pesquisa avancada exibe na tela
	AADD( aMenu , { "NODE_OF_P","NODE_OR",STR0020,"VS1","OFIXA011","OFIOC430",10,.f. } ) //
EndIF
If FindFunction("OFIXC001")
	AADD( aMenu , { "NODE_OF_CP","NODE_OR",STR0021,"VS1","OFIXA011","OFIXC001",01,.f. } ) // STR0021
EndIF

AADD( aMenu , { "NODE_OF_RP","NODE_OR",STR0050,"VS1","OFIXA018","OXA018RP",01,.f. } ) // Rastreamento Pedidos
AADD( aMenu , { "NODE_OF_L" ,"NODE_OR",STR0012      ,"VS1","OFIXA011","OFIXA011",10,.f. } ) // Legenda
AADD( aMenu , { "NODE_OF_AO" ,"NODE_OR",STR0094,"VS1","OFIXA011","OXA0110021_AguardarOutroOrcamento",02,.f. } ) // Aguardar outro OrÁamento

AaDD( aMenu , { "NODE_OF_C","NODE_OR",STR0062,   "VS1","OFINJD28","OXA018DRE", 02, .f. }) // Demanda Retro 02-orcamento
AaDD( aMenu , { "NODE_OF_C","NODE_OR",IIf(cPaisLoc=="ARG",STR0097,STR0066),   "VS1","OFIXA021","OFIXA021", 02, .f. }) // Fatura Remitos / Fatu. Agrupado

If cPaisLoc $ "ARG/MEX/PAR"
	AaDD( aMenu , { "NODE_OF_GREF","NODE_OR", STR0098,   "VS1","OFIXA011","OXA0110065_GeraRemitoEntregaFutura", 02, .f. }) // "Gerar Remitos da Entrega Futura"
	AaDD( aMenu , { "NODE_OF_CEF" ,"NODE_OR", STR0099,   "VS1","OFIXA011","OXA0110075_ConsultaItensEntregaFutura", 02, .f. }) // "Consulta Itens da Entrega Futura"
	AaDD( aMenu , { "NODE_OF_GRB" ,"NODE_OR", STR0118,   "VS1","OFIXA011","OXA0110085_Recibo", 02, .f. }) // "Gerar Recibo"
EndIf

If FindFunction("OXAGERFIN")
	AaDD( aMenu , { "NODE_OF_GT","NODE_OR",STR0067,   "VS1","OFIXA011","OFIGERFIN", 02, .f. }) // "Gerar Financeiro
Endif

If FindFunction("OFIC250")
	AaDD( aMenu , { "NODE_OF_250","NODE_OR",STR0076,   "VS1","OFIC250","OFIC250", 02, .f. }) // Tempos por Status do OrÁamento
Endif

If cPaisLoc $ "MEX"
	AADD( aMenu , { "NODE_OF_MEX","NODE_OR", STR0119, "VS1", "LOCXNF", "MATA467N", 02, .f. }) // Carta Porte/NF Manual
EndIf

// PE para incluir opÁıes no Menu (Arvore)
if ExistBlock("OX018ARV")
	aMenu := ExecBlock("OX018ARV",.f.,.f.,{aMenu})
Endif                          


AADD( aMenu , {"","","","","",STR0046,0,.f. } )          // Atualizar
AADD( aMenu , {"","","","","",STR0047,0,.f. } )          // Mostra/Oculta Vencidos
AADD( aMenu , {"","","","","",STR0048,0,.f. } )          // Mostra/Oculta Faturados
AADD( aMenu , {"","","","","",STR0065,0,.f. } )          // Mostra/Oculta Cancelados
If cPaisLoc == "ARG"
	AADD( aMenu , {"","","","","",STR0100,0,.f. } )          // Mostra/Oculta Entrega Futura
EndIf
If lExistPerg
	AADD( aMenu , {"","","","","",STR0069,0,.f. } )          // Parametros de Filtro Especial
EndIf
AADD( aMenu , {"","","","","",STR0024,0,.f. } )          // Sair
//
For nCont := 1 to Len(aMenu)
	If Empty(aMenu[nCont,2])
		OXA018ADDM(aMenu[nCont],aMenu,oMenuTree)
	EndIf
Next nCont

Return

/*/{Protheus.doc} OXA018DRE

	@author       Vinicius Gati
	@since        20/08/2015
	@description  Chama tela para alteracao da demanda de orÁamentos
	@param        cAlias, Alias da tabela 
	
/*/
Function OXA018DRE(nOpc)
	local cOrc := ""
	//
	If nOpc == 1
		//pedido
		cOrc := aLbPedi[oLbPedi:nAt, nPosNumOrc]
	else
		cOrc := aLbOrcs[oLbOrcs:nAt, nPosNumOrc]
	EndIf
	//
	if Empty(cOrc)
		Alert(STR0063 + IIF(nOpc == 1, STR0005, STR0014)) //Pedido de venda / OrÁamento // "Selecione um "
	else
		OFINJD28(cOrc)
	Endif
Return .T.

/*
===============================================================================
###############################################################################
##+----------+-------------+-------+----------------------+------+----------+##
##|Funcao    | OXA018ADDM  | Autor |  Takahashi           | Data | 28/02/13 |##
##+----------+-------------+-------+----------------------+------+----------+##
##|Descricao | Adiciona Item no Menu                                        |##
##+----------+--------------------------------------------------------------+##
##|Parametro | aParMenu  -> Linha da aMenu a ser Adicionada                 |##
##|          | aMenu     -> Matriz com opcoes do menu                       |##
##| 
         | oMenuTree -> Objeto do Menu                                  |##
##+----------+--------------------------------------------------------------+##
##|Uso       | Oficina                                                      |##
##+----------+--------------------------------------------------------------+##
###############################################################################
===============================================================================
*/
Static Function OXA018ADDM(aParMenu,aMenu,oMenuTree)

Local nPosAcesso
Local nCont

If !Empty(aParMenu[6])
	If aParMenu[6] == STR0031
		oMenuTree:AddTreeItem( STR0031 , "LOCALIZA" , "PESQ" , , , &("{ || OA018PESQ() }") ) // Filtro
	ElseIf aParMenu[6] == STR0024
		oMenuTree:AddTreeItem( STR0023 , STR0026 , STR0024 , , , &("{ || OA018SAIR() }") ) // Sair	
	ElseIf aParMenu[6] == STR0046
		oMenuTree:AddTreeItem( STR0046 , STR0046 , STR0046 , , , &("{ || OA018ATUAL() }") ) // Atualizar
	ElseIf aParMenu[6] == STR0047
		oMenuTree:AddTreeItem( OA018VencPrompt() , "" , "VENCIDOS" , , , &("{ || OA018MVENC(oMenuTree) }") ) // Mostra/Oculta Vencidos
	ElseIf aParMenu[6] == STR0048
		oMenuTree:AddTreeItem( OA018FatPrompt() , "" , "FATURADOS" , , , &("{ || OA018MFATU(oMenuTree) }") ) // Mostra/Oculta Faturados
	ElseIf aParMenu[6] == STR0065
		oMenuTree:AddTreeItem( OA018CancPrompt() , "" , "CANCELADOS" , , , &("{ || OA018MCANC(oMenuTree) }") ) // "Mostra/Oculta Cancelados"
	ElseIf aParMenu[6] == STR0069
		oMenuTree:AddTreeItem( STR0069 , "" , "PARAM_ESP" , , , &("{ || OXA018PergFilterSpec(.t.) }") ) // "Par‚metros de Filtro EspecÌfico"
	ElseIf cPaisLoc == "ARG" .and. aParMenu[6] == STR0100
		oMenuTree:AddTreeItem( OX0180035_EntFutPrompt() , "" , "ENTREGA" , , , &("{ || OX0180025_MostraEntregaFutura(oMenuTree) }") ) // "Mostra/Oculta Entrega Futura"
	Elseif cPaisLoc == "MEX" .and. aParMenu[6] == "MATA467N"
		oMenuTree:AddTreeItem( STR0119 , "PMSTASK4" , "NODE_OR" , , , &("{ || MATA467N() }") ) // "Carta Porte/NF Manual"
	Elseif aParMenu[6] == STR0120 //"Filtro de PendÍncias do Pedido"
		oMenuTree:AddTreeItem(OX018008D_PedPendPrompt(), "", STR0121,,, &("{ || OX018007D_FiltraPedidosPendentes(oMenuTree) }")) // "PENDENCIAS"
	Else
		nPosAcesso := aScan( aAuxAcesso , { |x| x[1] == aParMenu[5] } )
		If nPosAcesso > 0 .and. SubStr(aAuxAcesso[nPosAcesso,2],aParMenu[7],1) == "x"
			oMenuTree:AddTreeItem ( aParMenu[3] , "PMSTASK4", aParMenu[1] , ;
				&("{ || OXA018EXEC('" + aParMenu[4] + "','" + aParMenu[6] + "'," + Str(aParMenu[7],2) + "," + IIf(aParMenu[8],".t.",".f.") + ", '" + aParMenu[2] + "') }"), /*bRClick*/ ,;
				&("{ || OXA018EXEC('" + aParMenu[4] + "','" + aParMenu[6] + "'," + Str(aParMenu[7],2) + "," + IIf(aParMenu[8],".t.",".f.") + ", '" + aParMenu[2] + "') }") )
		Else
			oMenuTree:AddTreeItem ( aParMenu[3] , "PMSTASK1", aParMenu[1] , &("{ || Help(,1,'SEMPERM',,'"+aParMenu[5]+"',4,1) }") )
		EndIf
	EndIf
Else
	//oMenuTree:AddTree ( aParMenu[3], "folder5", "FOLDER6", aParMenu[1], &("{ || OXA018CBROWSE('" + aParMenu[4] + "','" + aParMenu[5] + "' ) }") , /*bRClick*/, /* */ )
	oMenuTree:AddTree ( aParMenu[3], "folder5", "FOLDER6", aParMenu[1],  , /*bRClick*/, /* */ )
	For nCont := 1 to Len(aMenu)
		If aMenu[nCont,2] == aParMenu[1]
			OXA018ADDM(aMenu[nCont],aMenu,oMenuTree)
		EndIf
	Next nCont
	oMenuTree:EndTree()
EndIf

Return
/*
===============================================================================
###############################################################################
##+----------+------------+-------+-----------------------+------+----------+##
##|Funcao    | OA018SAIR  | Autor |  Luis Delorme         | Data | 18/07/13 |##
##+----------+------------+-------+-----------------------+------+----------+##
##|Descricao | Item SAIR do Painel do OrÁamento                             |##
##+----------+--------------------------------------------------------------+##
##|Uso       | Oficina                                                      |##
##+----------+--------------------------------------------------------------+##
###############################################################################
===============================================================================
*/
Function OA018SAIR()

SetFunName("OFIXA018")
oDlgPanOfi:SetFocus()
DBSelectArea("VS1")

oDlgPanOfi:End()

return

/*
===============================================================================
###############################################################################
##+----------+----------------+-------+-------------------+------+----------+##
##|Funcao    | OXA018EXEC     | Autor |  Takahashi        | Data | 28/02/13 |##
##+----------+----------------+-------+-------------------+------+----------+##
##|Descricao | Func. auxiliar para criacao do objeto de Browse              |##
##+----------+--------------------------------------------------------------+##
##|Parametro | cAuxAlias  -> Alias do Browse                                |##
##|          | cAuxRotina -> Rotina a ser executada                         |##
##|          | nAuxOpc    -> nOpc da rotina                                 |##
##|          | lInclusao  -> Indica se È inclusao (Para reposicionar browse)|##
##+----------+--------------------------------------------------------------+##
##|Uso       | Oficina                                                      |##
##+----------+--------------------------------------------------------------+##
###############################################################################
===============================================================================
*/
Function OXA018EXEC(cAlias, cAuxRotina, nAuxOpc, lInclusao, cOrigChamada)
Local cBkpFunName := FunName()
Local lRefresh1   := .f.
Local lRefresh2   := .f.
Local nRecVS1Ori  := 0

Local cAuxOrc
Local cAuxPed

Local lFim    := .f.

Local lVAIMNUPNL := VAI->(FieldPos("VAI_MNUPNL")) > 0

Local lOX0010115_BloqueiaOrcamento := ExistFunc("OX0010115_BloqueiaOrcamento")
Local aDevRemSai := {}
Local oRpm := OFJDRpmConfig():New()

PESQUISA  := ( nAuxOpc == 1 )
VISUALIZA := ( nAuxOpc == 2 )
INCLUI    := ( nAuxOpc == 3 )
ALTERA    := ( nAuxOpc == 4 )
EXCLUI    := ( nAuxOpc == 5 )

nPosNumOrc := aScan( aLBCampos, { |x| x[1] == "VS1_NUMORC" } )

cNumPed := aLbPedi[oLbPedi:nAt, nPosNumOrc]
cNumOrc := aLbOrcs[oLbOrcs:nAt, nPosNumOrc]
if ! PESQUISA .and. !nAuxOpc == 10
	If ! INCLUI
		If cOrigChamada == "NODE_PV" .AND. Empty(cNumPed)
			FMX_HELP("OXA018ERR001",STR0095) // "Selecione um pedido de venda."
			Return
		EndIf
		If cOrigChamada == "NODE_OR" .AND. Empty(cNumOrc)
			FMX_HELP("OXA018ERR002",STR0096) // "Selecione um orÁamento."
			Return
		EndIf
	EndIf

// --------------- //
// Pedido de Venda //
// --------------- //
	If cAlias == "VS1P"
		cQuery := "SELECT R_E_C_N_O_ RECVS1 FROM " + RetSQLName("VS1") + " "
		cQuery += "WHERE VS1_FILIAL = '" + xFilial("VS1") + "' AND VS1_NUMORC = '" + cNumPed + "' AND D_E_L_E_T_ = ' '"
		nRegPedAtu := FM_SQL(cQuery)
		If ! INCLUI .and. nRegPedAtu == 0
			HELP(" ",1,"REGNOIS",,AllTrim(RetTitle("VS1_NUMORC")) + ": " + cNumPed,4,1)
			Return
		EndIf
		If nRegPedAtu <> 0
			VS1->(DBGoTo(nRegPedAtu))
		EndIf

	// --------- //
	// OrÁamento //
	// --------- //
	Else
		cQuery := "SELECT R_E_C_N_O_ RECVS1 FROM " + RetSQLName("VS1") + " "
		cQuery += "WHERE VS1_FILIAL = '" + xFilial("VS1") + "' AND VS1_NUMORC = '" + cNumOrc + "' AND D_E_L_E_T_ = ' '"
		nRegOrcAtu := FM_SQL(cQuery)
		If ! INCLUI .and. nRegOrcAtu == 0
			HELP(" ",1,"REGNOIS",,AllTrim(RetTitle("VS1_NUMORC")) + ": " + cNumOrc,4,1)
			Return
		EndIf

		If cPaisLoc == "ARG"
			aDevRemSai := OX0180049_DevolucoesRemitoSaida(cNumOrc)
			If Len(aDevRemSai) > 0
				If aDevRemSai[1,2] == "Parcial"
					MsgAlert(STR0103) // "Remito com DevoluÁ„o Parcial!"
				EndIf
			EndIf
		EndIf

		If nRegOrcAtu <> 0
			VS1->(DBGoTo(nRegOrcAtu))
		EndIf
	EndIf
Endif

cAliasAtu := cAlias

If lVAIMNUPNL
	If !FS_CHKUSU(cAuxRotina, nAuxOpc)
		MsgInfo(STR0061) // Usu·rio sem Permiss„o! Verificar campo Perm.Painel (Pasta PeÁas) no cadastro de Equipe TÈcnica.
		Return
	EndIf
EndIf

Do Case
	Case cAuxRotina == "OXA012V"
		SetFunName("OFIXA018")
		dbSelectArea("VS1")
		lRet = OXA012V()

		lRefresh1 := .f.
		lRefresh2 := .f.
		
	Case cAuxRotina == "OXA012I"
		SetFunName("OFIXA018")
		dbSelectArea("VS1")
		lRet = OXA012I()

		lRefresh1 := .t.
		cAuxPed := ""
		OXA018MTPD(VS1->VS1_FILIAL, VS1->VS1_NUMORC)

	Case cAuxRotina == "OXA012A"
		If Alltrim(VS1->VS1_PEDSTA) $ "2.3"
			return
		EndIf

		SetFunName("OFIXA018")
		dbSelectArea("VS1")
		lRet = OXA012A()

		lRefresh1 := .t.
		cAuxPed := ""

	Case cAuxRotina == "OXA012CP"
		If Alltrim(VS1->VS1_PEDSTA) $ "2.3"
			return
		EndIf

		SetFunName("OFIXA018")
		dbSelectArea("VS1")
		lRet = OXA012CP()

		lRefresh1 := .t.
		cAuxPed := ""
		OXA018MTPD()
		OXA018MTOR()
	
	Case cAuxRotina == "OXA012FP"
		cQuery := "SELECT SUM(COALESCE(VS3_QTDAGU,0) + COALESCE(VS3_QTDTRA,0))"
		cQuery += "  FROM " + RetSQLName("VS3")
		cQuery += " WHERE VS3_FILIAL = '" + xFilial("VS3") + "'"
		cQuery += "   AND VS3_NUMORC = '" + VS1->VS1_NUMORC + "'"
		cQuery += "   AND D_E_L_E_T_ = ' '"
		If FM_SQL(cQuery) > 0
			MSGINFO(STR0064) // "N„o È possÌvel liberar um Pedido que esteja aguardando peÁas para suprir o mesmo."
			return .F.
		EndIf

		If Alltrim(VS1->VS1_PEDSTA) $ "2.3"
			return
		EndIf

		// ... mostrar tela de transferencias automaticas
		if oRpm:lNovaConfiguracao .and. OX0180054_PrecisaDeSaldo(VS1->VS1_NUMORC)
			if MsgYesNo(STR0105,STR0104) //"Gostaria de transferÍncias para o orÁamento?" "AtenÁ„o"
				OFIA509(VS1->VS1_NUMORC)
			endif
		endif

		lFim := Eof()
		SetFunName("OFIXA018")
		dbSelectArea("VS1")
		cFilVS1P := VS1->VS1_FILIAL
		cOrcVS1P := VS1->VS1_NUMORC
		lRet = OXA012FP()
		cFilVS1O := VS1->VS1_FILIAL
		cOrcVS1O := VS1->VS1_NUMORC
		
		lRefresh1 := .t.
		lRefresh2 := .t.

		If lFim
			cAuxPed := ""
		EndIf

		cAuxOrc := ""
		OXA018MTPD(cFilVS1P, cOrcVS1P)
		OXA018MTOR(cFilVS1O, cOrcVS1O)
		oLbOrcs:Refresh()

	Case cAuxRotina == "OXA012CT"
		If Alltrim(VS1->VS1_PEDSTA) $ "2.3"
			return
		EndIf

		If lOX0010115_BloqueiaOrcamento .and. OX0010115_BloqueiaOrcamento(VS1->VS1_NUMORC)
			Return
		EndIf

		lXA018CancPed := .t.
		Exclui := .t.
		SetFunName("OFIXA018")
		dbSelectArea("VS1")
		lRet = OXA012CT()

		lRefresh1 := .t.
		cAuxPed := ""
		OXA018MTPD()
		lXA018CancPed := .f.

		If lOX0010115_BloqueiaOrcamento
			UnlockByName( 'OFIXX001_' + VS1->VS1_NUMORC, .T., .F. )
		EndIf

	Case cAuxRotina == "OXA012LEG"
		SetFunName("OFIXA018")
		dbSelectArea("VS1")
		lRet = OXA012Leg(1)

		lRefresh1 := .f.

	Case cAuxRotina == "OXA011CLO"

		lPediVenda := .t.
		SetFunName("OFIXA011")
		nOpc := nAuxOpc
		dbSelectArea("VS1")
		OXA011CLO("VS1", 0, 6, lPediVenda)

		lRefresh1 := .t.
		lRefresh2 := .t.
		cAuxOrc := ""
		OXA018MTPD(VS1->VS1_FILIAL, VS1->VS1_NUMORC)

	Case cAuxRotina == "OXA011LIB"

		// dbSelectArea("VS1")
		// cQuery := "SELECT SUM(COALESCE(VS3_QTDAGU,0))"
		// cQuery += "  FROM " + RetSQLName("VS3")
		// cQuery += " WHERE VS3_FILIAL = '" + xFilial("VS3") + "'"
		// cQuery += "   AND VS3_NUMORC = '" + VS1->VS1_NUMORC + "'"
		// cQuery += "   AND D_E_L_E_T_ = ' '"
		// If FM_SQL(cQuery) > 0
		// 	MSGINFO(STR0064) // "N„o È possÌvel liberar um Pedido que esteja aguardando peÁas para suprir o mesmo."
		// 	return .F.
		// EndIf

		If lOX0010115_BloqueiaOrcamento .and. OX0010115_BloqueiaOrcamento(VS1->VS1_NUMORC)
			Return
		EndIf

		// ... mostrar tela de transferencias automaticas
		if oRpm:lNovaConfiguracao .and. OX0180054_PrecisaDeSaldo(VS1->VS1_NUMORC)
			if OX0180054_PrecisaDeSaldo(VS1->VS1_NUMORC)
				if MsgYesNo(STR0105,STR0104) //"Gostaria de transferÍncias para o orÁamento?" "AtenÁ„o"
					OFIA509(VS1->VS1_NUMORC)
				endif
			endif
		endif

		lPediVenda := .t.
		lLibPV     := .t.
		SetFunName("OFIXA011")
		nOpc := nAuxOpc
		dbSelectArea("VS1")
		nRecVS1Ori := recno()

		If OXA011CLO("VS1", 0, 6, lPediVenda, lLibPv)
			// Atualiza valores Totais e Fiscais
			SetFunName("OFIXA018")
			dbSelectArea("VS1")
			lRet = OXA012AX()

			If lRet
				dbSelectArea("VS1")
				DbGoto(nRecVS1Ori)
				lRet = OXA012AX()
			EndIf

			If lRet
				MsgInfo(STR0029) // OperaÁ„o realizada com sucesso.
			Else
				MsgInfo(STR0030) // Erro na liberaÁ„o do OrÁamento.
			EndIf
		Else
			MsgInfo(STR0030) // Erro na liberaÁ„o do OrÁamento.
		EndIf

		lLibPV    := .f.
		lRefresh1 := .t.
		lRefresh2 := .t.
		cAuxOrc := ""
		OXA018MTPD(VS1->VS1_FILIAL, VS1->VS1_NUMORC)
		OXA018MTOR(VS1->VS1_FILIAL, VS1->VS1_NUMORC)

		If lOX0010115_BloqueiaOrcamento
			UnlockByName( 'OFIXX001_' + VS1->VS1_NUMORC, .T., .F. )
		EndIf

	Case cAuxRotina == "OFIXA011"
		SetFunName("OFIXA011")
		nOpc := nAuxOpc
		dbSelectArea("VS1")
		OFIXA011(,.T.)
		lRefresh1 := .t.
		lRefresh2 := .t.
		cAuxOrc := ""
		OXA018MTOR(VS1->VS1_FILIAL, VS1->VS1_NUMORC)

    Case cAuxRotina == "OFIOC430"
		SetFunName("OFIXA018")
		nOpc := nAuxOpc
		dbSelectArea("VS1")
		OFIOC430(,,, .t.)

	Case cAuxRotina == "OFIXC001"
		SetFunName("OFIXA011")
		nOpc := nAuxOpc
		aBkpRotina := aClone(aRotina)
		dbSelectArea("VS1")
		aRotina := OXA011004C_menudef()
		SetFunName("OFIXA018")
		nOpc := 2
		OFIXC001()
		aRotina := aClone(aBkpRotina)

	Case cAuxRotina == "OXA018RO"
		OXA018RO()

	Case cAuxRotina == "OXA018RP"
		OXA018RP()

	Case cAuxRotina == 'OXA018DRE'
		OXA018DRE(nAuxOpc)

	Case cAuxRotina == STR0024 // SAIR
		oDlgPanOfi:End()

	Case cAuxRotina == 'OFIXA021'
		SetFunName("OFIXA021")
		OFIXA021()
		SetFunName("OFIXA018")

	Case cAuxRotina == 'OFIGERFIN'
		SetFunName("OFIXA011")
		OXAGERFIN(VS1->VS1_NUMORC, VS1->VS1_NUMNFI, VS1->VS1_SERNFI)
		SetFunName("OFIXA018")

	Case cAuxRotina == 'OFIC250'
		OFIC250(VS1->VS1_NUMORC) // Tempos por Status do OrÁamento

	Otherwise
		If FindFunction(cAuxRotina)
			DbSelectArea("VS1")
			nOpc := nAuxOpc
			&(cAuxRotina + "()")
		EndIf
End Case

SetFunName(cBkpFunName)

Return


/*
===============================================================================
###############################################################################
##+----------+----------------+-------+-------------------+------+----------+##
##|Funcao    | MenuDef        | Autor |  Takahashi        | Data | 28/02/13 |##
##+----------+----------------+-------+-------------------+------+----------+##
##|Descricao | Menu da Rotina                                               |##
##+----------+--------------------------------------------------------------+##
##|Uso       | Oficina                                                      |##
##+----------+--------------------------------------------------------------+##
###############################################################################
===============================================================================
*/
Static Function MenuDef()
//Return {{STR0001, "OFIXA018", 0, 2}}
Local aRotina := {;
{ OemtoAnsi(STR0006),"AxPesqui" 		, 0 , 1},;
{ OemtoAnsi(STR0007),"OXA012V"    		, 0 , 2},;
{ OemtoAnsi(STR0008),"OXA012I"    		, 0 , 3},;
{ OemtoAnsi(STR0015),"OXA012A"    		, 0 , 4},;
{ OemtoAnsi(STR0009),"OXA012CP"    		, 0 , 5},;
{ OemtoAnsi(STR0010),"OXA012CT"    		, 0 , 5},;
{ OemtoAnsi(STR0011),"OXA012FP"    		, 0 , 6},;
{ OemtoAnsi(STR0018),"OXA011CLO"  		, 0 , 6},;
{ OemtoAnsi(STR0012),"OXA012Leg"		, 0 , 8} }
Return aRotina


/*
===============================================================================
###############################################################################
##+----------+----------------+-------+-------------------+------+----------+##
##|Funcao    | FS_PESQPED     | Autor | Luis Delorme      | Data | 27/05/14 |##
##+----------+----------------+-------+-------------------+------+----------+##
##|Descricao | Menu da Rotina                                               |##
##+----------+--------------------------------------------------------------+##
##|Uso       | Oficina                                                      |##
##+----------+--------------------------------------------------------------+##
###############################################################################
===============================================================================
*/
Static Function FS_PESQPED(nPedOrc)

Local nCntFor := 0

if nPedOrc == 0
	oLbPedi:nAt := 1
	OXA018MTPD() // Filtrar novamente
	if nNormAvaP == 1
		cString := cIndPedN
		nPosSt := aScan( aIndexTxt1 , cString  )
		cString := aIndex1[nPosSt]
	else 
		cString := cIndPedA
		nPosSt := aScan( aIndexTxt2 , cString  )
		cString := aIndex2[nPosSt]
	endif
else
	oLbOrcs:nAt := 1
	OXA018MTOR() // Filtrar novamente
	if nNormAvaO == 1
		cString := cIndOrcN
		nPosSt := aScan( aIndexTxt1 , cString  )
		cString := aIndex1[nPosSt]
	else 
		cString := cIndOrcA
		nPosSt := aScan( aIndexTxt2 , cString  )
		cString := aIndex2[nPosSt]
	endif
endif
		
aIdxVet := {}
nTamCpo := 0
for nCntFor := 1 to Len(aLBCampos)
	nPosSt := AT(Alltrim(aLBCampos[nCntFor,1]),cString)
	if nPosSt > 0
		cString := STUFF(cString,nPosSt,Len(Alltrim(aLBCampos[nCntFor,1])),"x["+Alltrim(STR(nCntFor))+"]")
		aAdd(aIdxVet,nCntFor)
		if (nPedOrc == 0 .and. nNormAvaP == 2) .or. (nPedOrc != 0 .and. nNormAvaO == 2)
			if  Alltrim(aLBCampos[nCntFor,1])$ "VS1_NUMORC.VS1_CLIFAT.VS1_CHAINT.VS1_NUMOSV.VS1_NUMNFI"
				nTamCpo := TamSX3(aLBCampos[nCntFor,1])[1]
				exit
			endif
		endif
	endif
next

cStringX := cString
cStringY := cString
cStringF := cString

nPosX := AT("x",cStringY)
while nPosX > 0
	cStringY := STUFF(cStringY,nPosX,1,"y")
	nPosX := AT("x",cStringY)
enddo

nPosF := AT("x[",cStringF)
while nPosF > 0
	if nPedOrc = 0 //pedido
		cStringF := STUFF(cStringF,nPosF,2,"aLBPedi[nPosV,")
	else //orcamento
		cStringF := STUFF(cStringF,nPosF,2,"aLBOrcs[nPosV,")
	endif
	nPosF := AT("x[",cStringF)
enddo

if nPedOrc = 0 //pedido
	&("aSort(aLBPedi,,,{|x,y|"+ cStringX +" < " + cStringY + "})")
else
	&("aSort(aLBOrcs,,,{|x,y|"+ cStringX +" < " + cStringY + "})")
endif

nPosV := 0

if nPedOrc = 0 //pedido
	If left(Alltrim(cChavePed),1) == "%" // Se existir % na primeira posicao da STRING, procurar como se fosse LIKE
		aAux := {}
		For nCntFor := 1 to Len(aLbPedi)
			nPosV := nCntFor
			&("cStrComp := " + cStringF)
			if RTrim(substr(cChavePed,2)) $ cStrComp 
				aAdd(aAux,aClone(aLbPedi[nCntFor]))
			endif
		next
		aLbPedi := aClone(aAux)
		nPosV := nCntFor := 1
	ElseIf right(Alltrim(cChavePed),1) == "%" // Se existir % na ultima posicao da STRING, procurar como se fosse LIKE
		aAux := {}
		For nCntFor := 1 to Len(aLbPedi)
			nPosV := nCntFor
			&("cStrComp := " + cStringF)
			if left(Alltrim(cChavePed),len(Alltrim(cChavePed))-1) $ cStrComp 
				aAdd(aAux,aClone(aLbPedi[nCntFor]))
			endif
		next
		aLbPedi := aClone(aAux)
		nPosV := nCntFor := 1
	Else	
		For nCntFor := 1 to Len(aLbPedi)
			nPosV := nCntFor
			&("cStrComp := " + cStringF)
			if  cStrComp >= RTrim(cChavePed)
				exit
			endif
		next
	EndIf
	oLbPedi:SetArray(aLbPedi)
	oLbPedi:nAt := nCntFor
	oLbPedi:Refresh()
else
	If left(Alltrim(cChaveOrc),1) == "%" // Se existir % na primeira posicao da STRING, procurar como se fosse LIKE
		aAux := {}
		For nCntFor := 1 to Len(aLbOrcs)
			nPosV := nCntFor
			&("cStrComp := " + cStringF)
			if RTrim(substr(cChaveOrc,2)) $ cStrComp
				aAdd(aAux,aClone(aLbOrcs[nCntFor]))
			endif
		next
		aLbOrcs := aClone(aAux)
		nPosV := nCntFor := 1
	ElseIf right(Alltrim(cChaveOrc),1) == "%" // Se existir % na ultima posicao da STRING, procurar como se fosse LIKE
		aAux := {}
		For nCntFor := 1 to Len(aLbOrcs)
			nPosV := nCntFor
			&("cStrComp := " + cStringF)
			if left(Alltrim(cChaveOrc),len(Alltrim(cChaveOrc))-1) $ cStrComp
				aAdd(aAux,aClone(aLbOrcs[nCntFor]))
			endif
		next
		aLbOrcs := aClone(aAux)
		nPosV := nCntFor := 1
	Else
		For nCntFor := 1 to Len(aLbOrcs)
			nPosV := nCntFor
			&("cStrComp := " + cStringF)
			if  cStrComp >= RTrim(cChaveOrc)
				exit
			endif
		next
	EndIf
	oLbOrcs:SetArray(aLbOrcs)
	oLbOrcs:nAt := nCntFor
	oLbOrcs:Refresh()
endif

return
/*
===============================================================================
###############################################################################
##+----------+------------+-------+-----------------------+------+----------+##
##|Funcao    | OA18ROBJOR | Autor |  Luis Delorme         | Data | 18/07/13 |##
##+----------+------------+-------+-----------------------+------+----------+##
##|Descricao | Legenda dos OrÁamentos                                       |##
##+----------+--------------------------------------------------------------+##
##|Uso       | Oficina                                                      |##
##+----------+--------------------------------------------------------------+##
###############################################################################
===============================================================================
*/
Function OA18ROBJOR()
Local cGerFin     := ""
Local cStatus
Local cTipOrc
If oLbOrcs:nAt <= Len(aLbOrcs)
	If lOrc_AtuStatus
		VS1->(DbSetOrder(1))
		If VS1->(DbSeek( xFilial("VS1") + aLbOrcs[oLbOrcs:nAt, nPosNumOrc] ))
			aLbOrcs[oLbOrcs:nAt, nPosStatus] := VS1->VS1_STATUS
		EndIf
	EndIf
	cStatus := aLbOrcs[oLbOrcs:nAt, nPosStatus]
	cTipOrc := aLbOrcs[oLbOrcs:nAt, nPosTipOrc]
	cGerFin := aLbOrcs[oLbOrcs:nAt, nPosGerFin]
	Do Case
		Case cStatus == "0" .AND. cTipOrc == "2"
			return of10verd
		Case cStatus == "0" .AND. cTipOrc == "1"
			return oBRVERDE
		Case cStatus == "2" .AND. cTipOrc == "1"
			return oBRPINK
		Case cStatus == "3"
			return oBRBRANCO
		Case cStatus == cXA018FaseConfer
			return oBRAZUL
		Case cStatus == "5"
			return oBRMARROM
		Case cStatus $ "RT"
			return oBRCINZA
		Case cStatus == "G"
			return oBRAZCLARO
		Case cStatus == "F" .AND. cTipOrc == "1"
			if cPaisLoc == "ARG"
				VS1->(DbSetOrder(1))
				VS1->(DbSeek( xFilial("VS1") + aLbOrcs[oLbOrcs:nAt, nPosNumOrc] ))
				if VS1->VS1_TPFATR == "2" .and. !Empty(VS1->VS1_REMITO)
					return oBRLARANJA
				else
					return oBRAMARELO
				endif
			else
				return oBRAMARELO
			endif
		Case cStatus == "F" .AND. cTipOrc == "2"
			return of5amar
		Case cStatus == "P" .OR. (cStatus == "2" .AND. cTipOrc == "2")
			return of12azul
		Case cStatus == "L"
			return of5amar
		Case cStatus == "I"
			return of14cinz
		Case cStatus == "C" .AND. cTipOrc == "2"
			return of7verm
		Case cStatus == "C" .AND. cTipOrc == "1"
			return oBRVERMELHO
		Case cStatus == "X"
			if cPaisLoc == "ARG"
				VS1->(DbSetOrder(1))
				VS1->(DbSeek( xFilial("VS1") + aLbOrcs[oLbOrcs:nAt, nPosNumOrc] ))
				If cTipOrc == "1" .and. cGerFin =="0"
					Return oBRPRCruz
				ElseIf VS1->VS1_TPFATR == "4"
					Return oBRVERDEESC
				Else
					return oBRPRETO
				Endif
			Else
				If cTipOrc == "1" .and. cGerFin =="0"
					Return oBRPRCruz
				Else
					return oBRPRETO
				Endif
			EndIf
		Case ExistBlock("OX018COR")
			return ExecBlock("OX018COR",.f.,.f.,{"O",cStatus,cTipOrc,cGerFin})
	EndCase
Else
	oLbOrcs:nAt := Len(aLbOrcs)
EndIf
return oBRVERDE
                    
/*
===============================================================================
###############################################################################
##+----------+------------+-------+-----------------------+------+----------+##
##|Funcao    | OA18ROBJPD | Autor |  Luis Delorme         | Data | 18/07/13 |##
##+----------+------------+-------+-----------------------+------+----------+##
##|Descricao | Legenda do Pedido de Venda                                   |##
##+----------+--------------------------------------------------------------+##
##|Uso       | Oficina                                                      |##
##+----------+--------------------------------------------------------------+##
###############################################################################
===============================================================================
*/
Function OA18ROBJPD()
// usado para sair do metodo porque foi inserido no grid um registro em branco    
if oLbPedi:nAt <= Len(aLbPedi)
	if lPed_AtuStatus
		VS1->(DbSetOrder(1))
		VS1->(DbSeek( xFilial("VS1") + aLbPedi[oLbPedi:nAt, nPosNumOrc] ))
		aLbPedi[oLbPedi:nAt, nPosPedSta] := VS1->VS1_PEDSTA
	endif
	cPedSta := aLbPedi[oLbPedi:nAt, nPosPedSta]
	Do Case
		Case cPedSta == "0"
			return oBRVERDE
		Case cPedSta == "1"
			return oBRAMARELO
		Case cPedSta == "2"
			return oBRPRETO
		Case cPedSta == "3"
			return oBRVERMELHO
		Case ExistBlock("OX018COR")
			return ExecBlock("OX018COR",.f.,.f.,{"P",cPedSta})
	EndCase
Else
	oLbPedi:nAt := Len(aLbPedi)
Endif	
return oBRVERDE

/*
===============================================================================
###############################################################################
##+----------+------------+-------+-----------------------+------+----------+##
##|Funcao    | OA18Fil    | Autor |  Luis Delorme         | Data | 18/07/13 |##
##+----------+------------+-------+-----------------------+------+----------+##
##|Descricao | Tratativa das telas de filtro FWFilter                       |##
##+----------+--------------------------------------------------------------+##
##|Uso       | Oficina                                                      |##
##+----------+--------------------------------------------------------------+##
###############################################################################
===============================================================================
*/
Static Function OA18Fil(cField, nLista)

//Local oMaster     := oModel:GetModel()
//Local oModelDBJ   := oMaster:GetModel("CTMASTER")
Local aFields           := {}
Local nI                := 0
Local oFWFilter
Private  cRetFilVS1 := ""
Default cField := "BROWSE_NEWFILTER"
 
If cField == "BROWSE_FILCLEAN"
      //-------------------------------------------------------------------
      // Realiza a limpeza do filtro
      //-------------------------------------------------------------------
      if nLista == 1
			cChavePed := SPACE(100)
			cRFilVS1Ped := ""
			OXA018MTPD()
	  else
			cChaveOrc := SPACE(100)
			cRFilVS1Orc := ""
			OXA018MTOR()
	  endif
  
ElseIf cField == "BROWSE_NEWFILTER"
      //-------------------------------------------------------------------
      // Apresenta a interface de filtro para configuraÁ„o
      //-------------------------------------------------------------------
      oFWFilter := FWFilter():New()
      oFWFilter:SetButton()
      oFWFilter:SetCanFilterAsk(.f.) 
      oFWFilter:DisableSave(.f.)
	  oFWFilter:SetSqlFilter(.t.)
      oFWFilter:SetExecute( {|| oFWFilter:DeActivate() } )
      //-------------------------------------------------------------------
      // Carrega os campos utilizados para o filtro
      //-------------------------------------------------------------------
      dbSelectArea("VS1")
      aStruct := DbStruct()
      For nI := 1 To Len(aStruct)
            Aadd( aFields, { aStruct[nI,1], aStruct[nI,1], aStruct[nI,2], aStruct[nI,3], aStruct[nI,4], } )
      Next nI
      oFWFilter:SetField(aFields)
      oFWFilter:EditFilter()

      //-------------------------------------------------------------------
      // Atualiza o filtro no campo
      //------------------------------------------------------------------- 

	if Len(oFWFilter:aFilter) > 0 .and. !Empty(Alltrim(oFWFilter:aFilter[1,3]))
		If 'FWMntFilDt' $ oFWFilter:aFilter[1,3] // Possui Filtro com campos do tipo DATA
			cAux := ""
			For nI := 1 to len(oFWFilter:aFilter[1,4]) // Monta Filtro a Filtro
				If 'FWMntFilDt' $ oFWFilter:aFilter[1,4,nI,5] // È a parte do Filtro da DATA
					cAux += oFWFilter:aFilter[1,4,nI,1]
					nI++
					cAux += IIf(oFWFilter:aFilter[1,4,nI,1]=="==","=",oFWFilter:aFilter[1,4,nI,1])
					nI++
					cAux += "'"+dtos(oFWFilter:aFilter[1,4,nI,1])+"'"
					nI++
				Else // NAO È a parte do Filtro com Data
					cAux += oFWFilter:aFilter[1,4,nI,5] // Pega pronto o Filtro
					nI++
					nI++
					nI++
				EndIf
				If nI <= len(oFWFilter:aFilter[1,4])
					cAux += oFWFilter:aFilter[1,4,nI,1] // OPERADOR caso exista mais de um Filtro
				EndIf
			Next
			cRetFilVS1 := cAux
		Else // NAO possui Filtro com campos do tipo DATA
			cRetFilVS1 := oFWFilter:aFilter[1,3] // Pega pronto o Filtro
		EndIf
		if nLista == 1
			cRFilVS1Ped := " AND ( " + cRetFilVS1 + " ) "
			OXA018MTPD()
		else
			cRFilVS1Orc := " AND ( " + cRetFilVS1 + " ) "
			OXA018MTOR()
		endif
	endif
EndIf

Return

/*
===============================================================================
###############################################################################
##+----------+------------+-------+-----------------------+------+----------+##
##|Funcao    | OXA018MCB  | Autor |  Luis Delorme         | Data | 18/07/13 |##
##+----------+------------+-------+-----------------------+------+----------+##
##|Descricao | Rotina para ocultar exibir Combos sobrepostos NORMAL/AVANC   |##
##+----------+--------------------------------------------------------------+##
##|Uso       | Oficina                                                      |##
##+----------+--------------------------------------------------------------+##
###############################################################################
===============================================================================
*/
Function OXA018MCB(nPedOrc)
if nPedOrc == 0
	if cNoAvaPed == STR0044
		nNormAvaP := 1
		oCbPedA:lVisible := .f.
		oCbPedN:lVisible := .t.		
		oCbPedA:Refresh()
		oCbPedN:Refresh()
	else
		nNormAvaP := 2
		oCbPedA:lVisible := .t.
		oCbPedN:lVisible := .f.		
		oCbPedA:Refresh()
		oCbPedN:Refresh()
	endif
else
	if cNoAvaOrc == STR0044
		nNormAvaO := 1
		oCbOrcA:lVisible := .f.
		oCbOrcN:lVisible := .t.		
		oCbOrcA:Refresh()
		oCbOrcN:Refresh()
	else
		nNormAvaO := 2
		oCbOrcA:lVisible := .t.
		oCbOrcN:lVisible := .f.		
		oCbOrcA:Refresh()
		oCbOrcN:Refresh()
	endif
endif

return

/*
===============================================================================
###############################################################################
##+----------+------------+-------+-----------------------+------+----------+##
##|Funcao    | OA018ATUAL | Autor |  Luis Delorme         | Data | 18/07/13 |##
##+----------+------------+-------+-----------------------+------+----------+##
##|Descricao | Refresh da listbox de orÁamentos e pedidos                   |##
##+----------+--------------------------------------------------------------+##
##|Uso       | Oficina                                                      |##
##+----------+--------------------------------------------------------------+##
###############################################################################
===============================================================================
*/
Function OA018ATUAL()
OXA018MTPD()
OXA018MTOR()
return

/*
===============================================================================
###############################################################################
##+----------+------------+-------+-----------------------+------+----------+##
##|Funcao    | OA018MVENC | Autor |  Luis Delorme         | Data | 18/07/13 |##
##+----------+------------+-------+-----------------------+------+----------+##
##|Descricao | Troca status para exibir orÁamentos vencidos n„o vencidos    |##
##+----------+--------------------------------------------------------------+##
##|Uso       | Oficina                                                      |##
##+----------+--------------------------------------------------------------+##
###############################################################################
===============================================================================
*/
Function OA018MVENC(oMenuTree)

	If ! OXA018FilterSpec(! lMostraVenc , lMostraFatu , lMostraCanc , lMostraEntr )
		Return 
	EndIf

	lMostraVenc := ! lMostraVenc

	oMenuTree:ChangePrompt ( OA018VencPrompt(), "VENCIDOS" )

	OXA018MTPD()
	OXA018MTOR()
return

/*
===============================================================================
###############################################################################
##+----------+------------+-------+-----------------------+------+----------+##
##|Funcao    | OA018MFATU | Autor |  Luis Delorme         | Data | 18/07/13 |##
##+----------+------------+-------+-----------------------+------+----------+##
##|Descricao | Troca status para exibir orÁamentos faturados n„o faturados  |##
##+----------+--------------------------------------------------------------+##
##|Uso       | Oficina                                                      |##
##+----------+--------------------------------------------------------------+##
###############################################################################
===============================================================================
*/
Function OA018MFATU(oMenuTree)

	If ! OXA018FilterSpec(lMostraVenc , ! lMostraFatu , lMostraCanc , lMostraEntr )
		Return 
	EndIf

	lMostraFatu := ! lMostraFatu

	oMenuTree:ChangePrompt ( OA018FatPrompt(), "FATURADOS" )

	OXA018MTPD()
	OXA018MTOR()
return

/*
===============================================================================
###############################################################################
##+----------+------------+-------+-----------------------+------+----------+##
##|Funcao    | OA018MCANC | Autor |  Manoel Filho         | Data | 16/12/16 |##
##+----------+------------+-------+-----------------------+------+----------+##
##|Descricao | Troca status para exibir orÁamentos cancelados e n„o cancelad|##
##+----------+--------------------------------------------------------------+##
##|Uso       | Oficina                                                      |##
##+----------+--------------------------------------------------------------+##
###############################################################################
===============================================================================
*/
Function OA018MCANC(oMenuTree)

	If ! OXA018FilterSpec(lMostraVenc , lMostraFatu , ! lMostraCanc , lMostraEntr )
		Return 
	EndIf

	lMostraCanc := ! lMostraCanc

	oMenuTree:ChangePrompt ( OA018CancPrompt(), "CANCELADOS" )

	OXA018MTPD()
	OXA018MTOR()
return

/*
===============================================================================
###############################################################################
##+----------+------------+-------+-----------------------+------+----------+##
##|Funcao    | OA18DORCS  | Autor |  Vinicius Gati        | Data | 30/04/15 |##
##+----------+------------+-------+-----------------------+------+----------+##
##|Descricao | usado no x3 para mostrar no browse a descricao do status     |##
##+----------+--------------------------------------------------------------+##
##|Uso       | Oficina                                                      |##
##+----------+--------------------------------------------------------------+##
###############################################################################
===============================================================================
*/
Function OA18DORCS(cStatus, cTpOrc, cGerfin) //Status do orcamento
	Local cCondicao := " "
	cCondicao := OX018001B_RetornaCondOrcamento(cStatus, cTpOrc, cGerfin)
	/*If Type("oXA018Faseorc") == "U"
		oXA018Faseorc := Mil_FasesOrcamento():New() // Alex - Tornar Classe Obsoleta
		cFunOrig := FunName()
		If FunType() == 3 .and. Left(cFunOrig,2) <> "U_"
			cFunOrig := "U_" + StrTran(cFunOrig,"#","")
		EndIf
		_SetNamedPrvt( "oXA018Faseorc" , oXA018Faseorc , cFunOrig )
	EndIf*/
//Return oXA018Faseorc:Get(cStatus)
Return cCondicao

/*
===============================================================================
###############################################################################
##+----------+------------+-------+-----------------------+------+----------+##
##|Funcao    | OXA018RO   | Autor |  Thiago               | Data | 03/07/15 |##
##+----------+------------+-------+-----------------------+------+----------+##
##|Descricao | Rastreamento Orcamento.                                      |##
##+----------+--------------------------------------------------------------+##
##|Uso       | Oficina                                                      |##
##+----------+--------------------------------------------------------------+##
###############################################################################
===============================================================================
*/
Function OXA018RO()
Local cAliasVS1 := "SQLVS1"
Local nTotal    := 0
Local aOrc      := {}
AADD(aOrc,{STR0058,"","",""})
cQuery := "SELECT VS1.VS1_NUMORC,VS1.VS1_DATORC,VS1.VS1_CLIFAT,VS1.VS1_LOJA,VS1.VS1_VTOTNF,SA1.A1_NOME "
cQuery += "FROM "
cQuery += RetSqlName( "VS1" ) + " VS1 "
cQuery += "LEFT JOIN "+RetSQLName("SA1")+" SA1 ON  SA1.A1_FILIAL = '"+xFilial("SA1")+"' AND SA1.A1_COD = VS1.VS1_CLIFAT AND SA1.A1_LOJA = VS1.VS1_LOJA AND SA1.D_E_L_E_T_ =' ' "
cQuery += "WHERE "
cQuery += "VS1.VS1_FILIAL='"+ xFilial("VS1")+ "' AND VS1.VS1_STATUS <> 'C' AND VS1.VS1_PEDREF = '"+VS1->VS1_NUMORC+"' AND "
cQuery += "VS1.D_E_L_E_T_=' '"
dbUseArea( .T., "TOPCONN", TcGenQry(,,cQuery), cAliasVS1, .T., .T. )
Do While !( cAliasVS1 )->( Eof() )
	AADD(aOrc,{( cAliasVS1 )->VS1_NUMORC,transform(stod(( cAliasVS1 )->VS1_DATORC),"@D"),( cAliasVS1 )->VS1_CLIFAT+" "+( cAliasVS1 )->VS1_LOJA+" - "+( cAliasVS1 )->A1_NOME,transform(( cAliasVS1 )->VS1_VTOTNF,"@E 999,999,999.99") })
	nTotal += ( cAliasVS1 )->VS1_VTOTNF
	dbSelectArea(cAliasVS1)
	( cAliasVS1 )->(dbSkip())
Enddo
( cAliasVS1 )->(dbCloseArea())
aOrc[1,4] := Transform(nTotal,"@E 999,999,999.99")
if Len(aOrc) > 1
	DEFINE MSDIALOG oDlgOrc TITLE STR0051 FROM  01,05 TO 25,89 OF oMainWnd // Rastreamento de OrÁamentos
	
	@ 001,.1 LISTBOX oLbox1 FIELDS HEADER STR0052,STR0053,STR0054,STR0055 COLSIZES 70,40,140,30 SIZE 332,150 OF oDlgOrc PIXEL
	
	oLbox1:SetArray(aOrc)
	oLbox1:bLine := { || { aOrc[oLbox1:nAt,01] ,;
	aOrc[oLbox1:nAt,02] ,;
	aOrc[oLbox1:nAt,03] ,;
	aOrc[oLbox1:nAt,04]	}}
	
	DEFINE SBUTTON FROM 157,280 TYPE 1 ACTION oDlgOrc:End() ENABLE OF oDlgOrc
	
	ACTIVATE MSDIALOG oDlgOrc CENTER
Else
	MsgInfo(STR0059)
Endif

Return(.t.)

/*
===============================================================================
###############################################################################
##+----------+------------+-------+-----------------------+------+----------+##
##|Funcao    | OXA018RP   | Autor |  Thiago               | Data | 03/07/15 |##
##+----------+------------+-------+-----------------------+------+----------+##
##|Descricao | Rastreamento Pedidos.													 |##
##+----------+--------------------------------------------------------------+##
##|Uso       | Oficina                                                      |##
##+----------+--------------------------------------------------------------+##
###############################################################################
===============================================================================
*/
Function OXA018RP()
Local cAliasVS1 := "SQLVS1"
Local aOrc      := {}

cQuery := "SELECT VS1.VS1_NUMORC,VS1.VS1_DATORC,VS1.VS1_CLIFAT,VS1.VS1_LOJA,VS1.VS1_VTOTNF,SA1.A1_NOME "
cQuery += "FROM "
cQuery += RetSqlName( "VS1" ) + " VS1 "
cQuery += "LEFT JOIN "+RetSQLName("SA1")+" SA1 ON  SA1.A1_FILIAL = '"+xFilial("SA1")+"' AND SA1.A1_COD = VS1.VS1_CLIFAT AND SA1.A1_LOJA = VS1.VS1_LOJA AND SA1.D_E_L_E_T_ =' ' "
cQuery += "WHERE "
cQuery += "VS1.VS1_FILIAL='"+ xFilial("VS1")+ "' AND VS1.VS1_STATUS <> 'C' AND VS1.VS1_NUMORC = '"+VS1->VS1_PEDREF+"' AND "
cQuery += "VS1.D_E_L_E_T_=' '"
dbUseArea( .T., "TOPCONN", TcGenQry(,,cQuery), cAliasVS1, .T., .T. )
Do While !( cAliasVS1 )->( Eof() )
	AADD(aOrc,{( cAliasVS1 )->VS1_NUMORC,transform(stod(( cAliasVS1 )->VS1_DATORC),"@D"),( cAliasVS1 )->VS1_CLIFAT+" "+( cAliasVS1 )->VS1_LOJA+" - "+( cAliasVS1 )->A1_NOME,transform(( cAliasVS1 )->VS1_VTOTNF,"@E 999,999,999.99") })
	dbSelectArea(cAliasVS1)
	( cAliasVS1 )->(dbSkip())
Enddo
( cAliasVS1 )->(dbCloseArea())

if Len(aOrc) > 0
	DEFINE MSDIALOG oDlgOrc TITLE STR0056 FROM  01,05 TO 25,89 OF oMainWnd // Rastreamento de Pedidos
	
	@ 001,.1 LISTBOX oLbox1 FIELDS HEADER STR0057,STR0053,STR0054,STR0055 COLSIZES 40,40,140,30 SIZE 332,150 OF oDlgOrc PIXEL
	
	oLbox1:SetArray(aOrc)
	oLbox1:bLine := { || { aOrc[oLbox1:nAt,01] ,;
	aOrc[oLbox1:nAt,02] ,;
	aOrc[oLbox1:nAt,03] ,;
	aOrc[oLbox1:nAt,04]	}}
	
	DEFINE SBUTTON FROM 157,280 TYPE 1 ACTION oDlgOrc:End() ENABLE OF oDlgOrc
	
	ACTIVATE MSDIALOG oDlgOrc CENTER
Else
	MsgInfo(STR0060)
Endif
Return(.t.)


/*
‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±…ÕÕÕÕÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÀÕÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÀÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÕÕÕª±±
±±∫Programa  ≥FS_CHKUSU ∫Autor  ≥Renato Vinicius     ∫ Data ≥  17/07/15   ∫±±
±±ÃÕÕÕÕÕÕÕÕÕÕÿÕÕÕÕÕÕÕÕÕÕ ÕÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕ ÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕπ±±
±±∫Desc.     ≥Funcao de validacao de acesso a opÁ„o selecionada           ∫±±
±±∫          ≥                                                            ∫±±
±±ÃÕÕÕÕÕÕÕÕÕÕÿÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕπ±±
±±∫Uso       ≥ AP                                                        ∫±±
±±»ÕÕÕÕÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕº±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
*/
Static Function FS_CHKUSU(cRotina,nOption)

Local lRet := .t.
Local aOpcMenu := {}
Local aArea := GetArea()

Default cRotina := ""
Default nOption := 0

If nOption <> 0
	if cRotina <> "OFIXA011" // Diferente de Menu Orcamento
		nOption := 0
	EndIf
EndIf

/*
Estrutura da Matriz aOpcMenu
[01] - Nome da Rotina Executada
[02] - Conteudo da vareavel nOpc
*/

//Opcoes Menu Pedidos
aAdd(aOpcMenu,{"OXA012V","0"})//			"Visualizar (1a.posiÁ„o)"
aAdd(aOpcMenu,{"OXA012I","0"})//			"Incluir (2a.posiÁ„o)"
aAdd(aOpcMenu,{"OXA012A","0"})//			"Alterar (3a.posiÁ„o)"
aAdd(aOpcMenu,{"OXA012CP","0"})//			"Cancel. Parcial (4a. posiÁ„o)"
aAdd(aOpcMenu,{"OXA012CT","0"})//			"Cancel. Total (5a.posiÁ„o)"
aAdd(aOpcMenu,{"OXA012FP","0"})//			"Faturamento (6a.posiÁ„o)"
aAdd(aOpcMenu,{"OXA011CLO","0"})//			"Clonar (7a.posiÁ„o)"
aAdd(aOpcMenu,{"OXA011LIB","0"})//			"Liberar (8a.posiÁ„o)"

//Opcoes Menu Orcamento
aAdd(aOpcMenu,{"OFIXA011","2"})//			"Visualizar (9a.posiÁ„o)"
aAdd(aOpcMenu,{"OFIXA011","4"})//			"Alterar (10a.posiÁ„o)"
aAdd(aOpcMenu,{"OFIXA011","5"})//			"Cancelar (11a. posiÁ„o)"
aAdd(aOpcMenu,{"OFIXA011","6"})//			"Faturar (12a.posiÁ„o)"
aAdd(aOpcMenu,{"OFIXA011","7"})//			"Clonar (13a.posiÁ„o)"
aAdd(aOpcMenu,{"OFIXA011","8"})//			"Clonar por OS (14a.posiÁ„o)"
aAdd(aOpcMenu,{"OFIOC430","0"})//			"Pesquisa Avanada (15a.posio)"

If FindFunction("OFIXC001")
	aAdd(aOpcMenu,{"OFIXC001","0"})//			"Consulta de PeÁa (16a.posiÁ„o)"
EndIF


aAdd(aOpcMenu,{"OFINJD28","0"})//           "Demanda Retroativa Pedido"
aAdd(aOpcMenu,{"OFINJD28","0"})//           "Demanda Retroativa"

// adicionar itens sempre abaixo
if cRotina == "OFIXA021" // mesma posicao do faturamento decima segunda posicao, isso È um ajuste para funcionar no padr„o
	nPosRot := 12 // posiÁ„o do faturamento
else
	nPosRot := aScan(aOpcMenu,{|x| x[1]+x[2] == cRotina+cValToChar(nOption)}) //Posicao de Validacao no campo VAI_MNUPNL
end
if nPosRot > 0
	DbSelectArea("VAI")
	Dbsetorder(4)
	If VAI->(DbSeek(xFilial("VAI")+__cUserID))
		If !Empty(VAI->VAI_MNUPNL) .and. Subs(VAI->VAI_MNUPNL,nPosRot,1) <> "1" //Sem Permissao
			lRet := .f.
		EndIf
	EndIf
EndIf

RestArea(aArea)

Return lRet




/*/{Protheus.doc} OXA018AjIniBrw
Ajusta X3_INIBRW para melhoria de performance
@author rubens.takahashi
@since 03/02/2020
@version 1.0
@return ${return}, ${return_description}
@param cAuxIniBrw, characters, description
@param cCpoCombo, characters, description
@type function
/*/
Static Function OXA018AjIniBrw(cAuxIniBrw, cCpoCombo )

	Local nAuxPos

	nAuxPos := At('X3CBOXDESC' , cAuxIniBrw)
	nAuxPos := At('->',cAuxIniBrw,nAuxPos)
	nAuxPos := At(cCpoCombo,cAuxIniBrw,nAuxPos)
	nAuxPos := At(')',cAuxIniBrw,nAuxPos)

Return (Left(cAuxIniBrw,nAuxPos - 1) + ", a" + cCpoCombo + SubStr(cAuxIniBrw, nAuxPos))


/*/{Protheus.doc} OXA018TCSetField
Ajusta campos do tipo numerico, logico e data na Query 
@author rubens.takahashi
@since 03/02/2020
@version 1.0
@return ${return}, ${return_description}
@param cAliasQuery, characters, description
@type function
/*/
Static Function OXA018TCSetField(cAliasQuery)
	Local nT := len( aStruVS1 )
	Local nCntFor
	For nCntFor := 1 to nT
		If ( aStruVS1[nCntFor][2] $ 'DNL' )
			TCSetField( cAliasQuery, aStruVS1[nCntFor, 1], aStruVS1[nCntFor, 2], aStruVS1[nCntFor, 3], aStruVS1[nCntFor,4] )
		Endif
	Next
Return

/*/{Protheus.doc} OXA018MontaDBtoArrayListbox
Cria um array auxiliar com os campos REAIS da query para montagem das listbox
@author rubens.takahashi
@since 03/02/2020
@version 1.0
@return ${return}, ${return_description}
@param cAliasQuery, characters, description
@param aCamposListbox, array, description
@param aArrayAuxiliar, array, description
@type function
/*/
Static Function OXA018MontaDBtoArrayListbox(cAliasQuery, aCamposListbox, aArrayAuxiliar)
	Local nCntFor

	aArrayAuxiliar := Array(Len(aCamposListbox))
	for nCntFor := 1 to Len(aCamposListbox)
		if aCamposListbox[nCntFor,3] != "V"
			aArrayAuxiliar[nCntFor] := (cAliasQuery)->(FieldPos(aCamposListbox[nCntFor,1]))
		endif
	next nCntFor

Return

/*/{Protheus.doc} OXA018ExistPerg
Retorna se existe pergunte da rotina
@author rubens.takahashi
@since 29/06/2020
@version 1.0
@return ${return}, ${return_description}

@type function
/*/
Static Function OXA018ExistPerg()

	Local	oObjSX1 := FWSX1Util():New()

	oObjSX1:AddGroup("OFIXA018")
	oObjSX1:SearchGroup()
	If Len(oObjSX1:GetGroup("OFIXA018")[2]) == 0
		lJaPergXA018 := .t.
		Return .f.
	EndIf

Return .t.

/*/{Protheus.doc} OXA018PergFilterSpec
Exibe pergunte da rotina
@author rubens.takahashi
@since 29/06/2020
@version 1.0
@return ${return}, ${return_description}
@param lAtuBrowse, logical, description
@type function
/*/
Function OXA018PergFilterSpec(lAtuBrowse)

	If ! lExistPerg
		Return .t.
	EndIf

	If ! Pergunte("OFIXA018",.t.)
		Return .f.
	EndIf

	lJaPergXA018 := .t.
	nFilQtdDia := MV_PAR01
	dFilDatIni := MV_PAR02
	dFilDatFim := MV_PAR03


	If lAtuBrowse .and. ( lMostraVenc .or. lMostraFatu .or. lMostraVenc .or. lMostraEntr)	
		OXA018FilterSpec( lMostraVenc , lMostraFatu , lMostraCanc , lMostraEntr)
		OXA018MTPD()
		OXA018MTOR()
	EndIf


Return .t.

/*/{Protheus.doc} OXA018FilterSpec
Ajusta filtro especifico das opcoes mostra vencido, mostra faturados e mostra cancelados
@author rubens.takahashi
@since 29/06/2020
@version 1.0
@return ${return}, ${return_description}
@param lVenc, logical, description
@param lFat, logical, description
@param lCanc, logical, description
@type function
/*/
Function OXA018FilterSpec(lVenc , lFat , lCanc , lEntr)

	If ! lExistPerg
		cFilterSpec := ""
		Return .t.
	EndIf

	// Limpando filtro de Vencidos / Faturados / Cancelados 
	If ! lVenc .and. ! lFat .and. ! lCanc .and. ! lEntr
		cFilterSpec := ""
		Return .t.
	EndIf

	If ! lJaPergXA018
		If ! OXA018PergFilterSpec(.f.)
			Return .f. 
		EndIf
	EndIf

	cFilterSpec := ""
	If nFilQtdDia > 0
		cFilterSpec += " AND VS1_DATORC BETWEEN '" + DtoS(ddatabase - nFilQtdDia) + "' AND '" + DtoS(dDataBase) + "'"
	EndIf

	If ! Empty( dFilDatIni ) .AND. ! Empty( dFilDatFim )
		cFilterSpec += " AND VS1_DATORC BETWEEN '" + DtoS(dFilDatIni) + "' AND '" + DtoS(dFilDatFim) + "'"
	EndIf

Return .t.


/*/{Protheus.doc} OA018VencPrompt
Retorna Label a ser exibido na opcao do Menu Tree
@author rubens.takahashi
@since 29/06/2020
@version 1.0
@return ${return}, ${return_description}

@type function
/*/
Static Function OA018VencPrompt()
	If lMostraVenc
		Return STR0070 // "Oculta Vencidos"
	Else
		Return STR0071 // "Mostra Vencidos"
	EndIf
Return ""

/*/{Protheus.doc} OA018FatPrompt
Retorna Label a ser exibido na opcao do Menu Tree
@author rubens.takahashi
@since 29/06/2020
@version 1.0
@return ${return}, ${return_description}

@type function
/*/
Static Function OA018FatPrompt()
	If lMostraFatu
		Return STR0072 // "Oculta Faturados"
	Else
		Return STR0073 // "Mostra Faturados"
	EndIf
Return ""

/*/{Protheus.doc} OA018CancPrompt
Retorna Label a ser exibido na opcao do Menu Tree
@author rubens.takahashi
@since 29/06/2020
@version 1.0
@return ${return}, ${return_description}

@type function
/*/
Static Function OA018CancPrompt()
	If lMostraCanc
		Return STR0074 // "Oculta Cancelados"
	Else
		Return STR0075 // "Mostra Cancelados"
	EndIf
Return ""

/*/{Protheus.doc} OX018001B_RetornaCondOrcamento
	FunÁ„o que retorna situaÁ„o do OrÁamento. Preenchimento do campo virtual VS1_DSSTAT.
	@author Alecsandre Ferreira
	@since 23/03/2022
	@version 1.0

	@Return character, cCondicao
	@type function
/*/
Function OX018001B_RetornaCondOrcamento(cStatus, cTpOrc, cGerFin)
	Local cCondicao := " "
	Local cFaseConfer := Alltrim(GetNewPar("MV_MIL0095", "4"))
	Default cGerFin := " "

	Do Case
		Case cStatus == "0" .AND. cTpOrc == "2"
			cCondicao := STR0077 // OrÁamento Oficina Digitado
		Case cStatus == "0" .AND. cTpOrc == "1"
			cCondicao := STR0078 // OrÁamento Balc„o Digitado
		Case cStatus == "2" .AND. cTpOrc == "1"
			cCondicao := STR0079 // OrÁamento Balc„o Margem Pendente
		Case cStatus == "3"
			cCondicao := STR0080 // OrÁamento Balc„o AvaliaÁ„o de CrÈdito
		Case cStatus == cFaseConfer
			cCondicao := STR0081 // OrÁamento Balc„o Aguardando SeparaÁ„o
		Case cStatus == "5"
			cCondicao := STR0082 // OrÁamento Balc„o Aguardando Lib.Diverg.
		Case cStatus $ "AT"
			cCondicao := STR0083 // OrÁamento Balc„o Aguardando Reserva
		Case cStatus == "G"
			cCondicao := STR0093 // OrÁamento Balc„o aguardando outro OrÁamento
		Case cStatus == "F" .AND. cTpOrc == "1"
			cCondicao := STR0084 // OrÁamento Balc„o Liberado p/ Faturamento
		Case cStatus == "F" .AND. cTpOrc == "2"
			cCondicao := STR0085 // OrÁamento Oficina Liberado p/ ExportaÁ„o
		Case cStatus == "P" .OR. (cStatus == "2" .AND. cTpOrc == "2")
			cCondicao := STR0086 // OrÁamento Oficina Pendente para O.S.
		Case cStatus == "L"
			cCondicao := STR0087 // OrÁamento Oficina Liberado para O.S.
		Case cStatus == "I"
			cCondicao := STR0088 // OrÁamento Oficina Importado para O.S.
		Case cStatus == "C" .AND. VS1->VS1_TIPORC == "2"
			cCondicao := STR0089 // OrÁamento Oficina Cancelado
		Case cStatus == "C" .AND. VS1->VS1_TIPORC == "1"
			cCondicao := STR0090 // OrÁamento Balc„o Cancelado
		Case cStatus == "X" .AND. cGerFin <> "0"
			cCondicao := STR0091 // OrÁamento Balc„o Faturado
		Case cStatus == "X" .AND. cGerFin == "0"
			cCondicao := STR0092 // OrÁamento Balc„o Faturado S/ Financeiro
	EndCase

	If ExistBlock("OX018ADS")
		cCondicao := ExecBlock("OX018ADS", .F., .F., {cStatus, cTpOrc, cGerFin, cCondicao})
	EndIf
Return cCondicao

/*/{Protheus.doc} OX0180025_MostraEntregaFutura
	
	Troca status para exibir/ocultar orÁamentos Entrega Futura

	@author Renato Vinicius
	@since 16/10/2024
	@version 1.0

	@Return character, cCondicao
	@type function
/*/
Function OX0180025_MostraEntregaFutura(oMenuTree)
	Local nLinha := 5

	If ! OXA018FilterSpec(lMostraVenc , .t. , lMostraCanc , ! lMostraEntr)
		Return 
	EndIf

	lMostraEntr := ! lMostraEntr

	If lMostraEntr
		nOpcEntFut := 0 // Esc ou Cancelar
		DEFINE MSDIALOG oDlgOpcoes TITLE STR0102 From 0,0 TO 180,400 PIXEL // Exibir Entrega Futura
			oDlgOpcoes:lEscClose := .T.
			tButton():New(nLinha,005,STR0110,oDlgOpcoes, { || nOpcEntFut := 4 , oDlgOpcoes:End() } , 193 , 12 ,,,,.T.,,,,{ || .t.  }) // 4 = Todos OrÁamentos de Entrega Futura (com ou sem Remito)
			nLinha += 17
			tButton():New(nLinha,005,STR0107,oDlgOpcoes, { || nOpcEntFut := 1 , oDlgOpcoes:End() } , 193 , 12 ,,,,.T.,,,,{ || .t.  }) // 1 = OrÁamentos que possui Remito com todos Itens Entregues
			nLinha += 17
			tButton():New(nLinha,005,STR0108,oDlgOpcoes, { || nOpcEntFut := 2 , oDlgOpcoes:End() } , 193 , 12 ,,,,.T.,,,,{ || .t.  }) // 2 = OrÁamentos que possui Remito com Itens Entregues parcialmente
			nLinha += 17
			tButton():New(nLinha,005,STR0109,oDlgOpcoes, { || nOpcEntFut := 3 , oDlgOpcoes:End() } , 193 , 12 ,,,,.T.,,,,{ || .t.  }) // 3 = OrÁamentos sem Remito (nenhum Item Entregue)
			nLinha += 17
		DEFINE SBUTTON FROM nLinha,172 TYPE 2 ACTION oDlgOpcoes:End() ENABLE OF oDlgOpcoes
		ACTIVATE MSDIALOG oDlgOpcoes CENTER
		If nOpcEntFut == 0 // Esc ou Cancelar
			nOpcEntFut  := 4 // Volta para o Default: 4 = Todos OrÁamentos de Entrega Futura (com ou sem Remito)
			lMostraEntr := .f.
			Return
		EndIf
	EndIf

	oMenuTree:ChangePrompt ( OX0180035_EntFutPrompt(), "ENTREGA" )

	OXA018MTOR()

return

/*/{Protheus.doc} OX0180035_EntFutPrompt

Retorna Label a ser exibido na opcao do Menu Tree

@author Renato Vinicius
@since 16/10/2024
@version 1.0
@return ${return}, ${return_description}

@type function
/*/
Static Function OX0180035_EntFutPrompt()

	Local cReturn := STR0101 //"Oculta Entrega Futura"

	If !lMostraEntr
		cReturn := STR0102 //"Exibir Entrega Futura"
	EndIf

Return cReturn

/*/{Protheus.doc} OX0180049_DevolucoesRemitoSaida
Retorna as devoluÁıes dos remitos de saÌda dos orÁamentos informados
@type function
@version 1.0
@author Jo„o Carlos da Silva
@since 25/10/2024
@param cTodosOrc, character, N˙mero do orÁamento a ser pesquisado. Informar um orÁamento ou uma lista de orÁamentos no formato IN, sem os parÍnteses.
@return array, N˙mero do orÁamento, tipo da devoluÁ„o: Sem Devolucao, Parcial ou Total e os itens dos orÁamentos com devoluÁ„o
/*/
Function OX0180049_DevolucoesRemitoSaida(cTodosOrc)
Local cAliasSD2  := GetNextAlias()
Local xRet       := {}
Local aRet       := {}
Local cRet       := ""
Local nDevolucao := 0
Local nSaidas    := 0
Local cNumAnt    := ""
Local cQuery     := ""

If Left(cTodosOrc,1) <> "'" .or. Right(cTodosOrc,1) <> "'"
	cTodosOrc := "'" + cTodosOrc + "'"
EndIf

cQuery := "SELECT SD2.R_E_C_N_O_ AS RECSD2 "
cQuery += ", VS1_NUMORC, D2_DOC, D2_SERIE, D2_ITEM, D2_COD, D2_QTDEDEV, D2_QUANT " // Campos para verificar as devoluÁıes
cQuery += "  FROM "+RetSqlName("VS1")+" VS1 "
cQuery += "  JOIN "+RetSqlName("SD2")+" SD2 "
cQuery += "    ON SD2.D2_FILIAL  = '"+xFilial("SD2")+"'"
cQuery += "   AND SD2.D2_DOC     = VS1.VS1_REMITO"
cQuery += "   AND SD2.D2_SERIE   = VS1.VS1_SERREM"
cQuery += "   AND SD2.D2_CLIENTE = VS1.VS1_CLIFAT"
cQuery += "   AND SD2.D2_LOJA    = VS1.VS1_LOJA"
cQuery += "   AND SD2.D_E_L_E_T_ = ' '"
cQuery += " WHERE VS1.VS1_FILIAL = '"+xFilial("VS1")+"'"
cQuery += "   AND VS1.VS1_NUMORC IN ("+cTodosOrc+")"
cQuery += "   AND VS1.D_E_L_E_T_ = ' '"
cQuery += " ORDER BY VS1_NUMORC, D2_DOC, D2_SERIE, D2_ITEM, D2_COD" // Classifica por orÁamento
dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery ), cAliasSD2, .F., .T. )
While ( cAliasSD2 )->(!Eof())
	aRet       := {}
	cRet       := ""
	nDevolucao := 0
	nSaidas    := 0
	cNumAnt    := (cAliasSD2)->VS1_NUMORC
	While ( cAliasSD2 )->(!Eof() .and. VS1_NUMORC == cNumAnt)
		nDevolucao += (cAliasSD2)->D2_QTDEDEV
		nSaidas    += (cAliasSD2)->D2_QUANT
		(cAliasSD2)->(AAdd(aRet,{D2_DOC, D2_SERIE, D2_ITEM, D2_COD, D2_QTDEDEV, D2_QUANT}))
		(cAliasSD2)->(dbSkip())
	End
	If nDevolucao == 0
		cRet := "Sem Devolucao"
	ElseIf nDevolucao >= nSaidas
		cRet := "Total"
	Else
		cRet := "Parcial"
	EndIf
	AAdd(xRet,{cNumAnt,cRet,aRet})
End
(cAliasSD2)->(dbCloseArea())

Return(xRet)

/*/{Protheus.doc} OX0180054_PrecisaDeSaldo
	Verifica se o orÁamento precisa de saldo
	
	@type function
	@version 1.0
	@author Vinicius Gati
	@since 19/12/2024
	@param cVS1NUMORC, character, Numero do orÁamento para verificar saldo
	@return array, N˙mero do orÁamento, tipo da devoluÁ„o: Sem Devolucao, Parcial ou Total e os itens dos orÁamentos com devoluÁ„o
/*/
Function OX0180054_PrecisaDeSaldo(cVS1NUMORC)
	local nX := 1 
	local cQuery := ""
	local aItens
	local oSql := DMS_SqlHelper():New()

	cQuery += " SELECT VS3_CODITE, VS3_GRUITE, VS3_QTDITE, VS3_QTDRES, VS3_LOCAL "
	cQuery += "   FROM " + RetSqlName("VS3") + " VS3 "
	cQuery += "  WHERE VS3_FILIAL = '"+xFilial('VS3')+"' "
	cQuery += "    AND VS3_NUMORC = '"+cVS1NUMORC+"' "
	cQuery += "    AND VS3_MOTPED = ' ' "
	cQuery += "    AND VS3.D_E_L_E_T_ = ' ' "

	Pergunte("MTA260", .F.) // pega config de saldo de terceiros para o MV_PAR03
	aItens := oSql:GetSelectJson({"VS3_CODITE", "VS3_GRUITE", "VS3_QTDITE", "VS3_QTDRES", "VS3_LOCAL"}, cQuery)

	for nX := 1 to len(aItens)
		jItem := aItens[nX]

		DBSelectArea("SB1")
		DBSetOrder(7)
		DBSeek(xFilial("SB1") + jItem["VS3_GRUITE"] + jItem["VS3_CODITE"])
		
		DBSelectArea("SB2")
		DBSetOrder(1)
		if SB2->(dbSeek(xFiliaL("SB2") + SB1->B1_COD + jItem["VS3_LOCAL"]))
			nSaldo := SaldoMov(,,, If(MV_PAR03 == 1, .F., .T.),,,,)
			if nSaldo < (jItem["VS3_QTDITE"] - jItem["VS3_QTDRES"])
				return .T.
			endif
		else
			return .T. // nunca entrou no estoque, precisa
		endif		
	next

return .F.

/*/{Protheus.doc} OX0180061_SQL_EntregaFutura
Retorna o complemento da QUERY para Entrega Futura. Dependendo do Filtro selecionado:
1 = OrÁamentos que possui Remito com todos Itens Entregues
2 = OrÁamentos que possui Remito com Itens Entregues parcialmente
3 = OrÁamentos sem Remito (nenhum Item Entregue)
4 = Todos OrÁamentos de Entrega Futura (com ou sem Remito)

@author Andre Luis Almeida
@since 07/03/2025
@version 1.0
/*/
Static Function OX0180061_SQL_EntregaFutura()
Local cReturn := " AND EXISTS ( "
cReturn += "SELECT SC6.C6_NUM "
cReturn += "  FROM " + RetSqlName("SC6") + " SC6 "
cReturn += " WHERE SC6.C6_FILIAL = '" + xFilial("SC6") + "'"
cReturn += "   AND SC6.C6_NUM = VS1_PEDREM " 
Do Case
	Case nOpcEntFut == 1 // 1 = OrÁamentos que possui Remito com todos Itens Entregues
		cReturn += " AND SC6.C6_QTDEMP = 0"
	Case nOpcEntFut == 2 // 2 = OrÁamentos que possui Remito com Itens Entregues parcialmente
		cReturn += " AND SC6.C6_QTDENT > 0"
		cReturn += " AND SC6.C6_QTDEMP > 0"
	Case nOpcEntFut == 3 // 3 = OrÁamentos sem Remito (nenhum Item Entregue)
		cReturn += " AND SC6.C6_QTDENT = 0"
EndCase
cReturn += "   AND SC6.D_E_L_E_T_ = ' ' "
cReturn += ")"
Return cReturn


/*/{Protheus.doc} OX018007D_FiltraPedidosPendentes
	
	Filtro aplicado aos pedidos com pendÍncia

	@author Francisco Carvalho
	@since 08/09/2025
	@version 1.0

	@Return ${return}, ${return_description}
	@type function
/*/
Function OX018007D_FiltraPedidosPendentes(oMenuTree)
	Local nLinha := 5

	lPedPend := ! lPedPend

	If lPedPend
		nOpcPend := 0 // Esc ou Cancelar
		DEFINE MSDIALOG oDlgPend TITLE STR0120 From 0,0 TO 145,400 PIXEL // Filtro de PendÍncias do Pedido
			oDlgPend:lEscClose := .T.
			tButton():New(nLinha, 005, STR0122, oDlgPend, { || nOpcPend := 1, oDlgPend:End() }, 193, 12,,,, .T.,,,,{ || .t.  }) // 1 = Com PendÍncia - Aguardando Pedido de Compra.
			nLinha += 17
			tButton():New(nLinha, 005, STR0123, oDlgPend, { || nOpcPend := 2, oDlgPend:End() }, 193, 12,,,, .T.,,,,{ || .t.  }) // 2 = Com PendÍncia - Aguardando TransferÍncia.
			nLinha += 17
			tButton():New(nLinha, 005, STR0124, oDlgPend, { || nOpcPend := 3, oDlgPend:End() }, 193, 12,,,, .T.,,,,{ || .t.  }) // 3 = Sem PendÍncia.
			nLinha += 17
		DEFINE SBUTTON FROM nLinha,172 TYPE 2 ACTION oDlgPend:End() ENABLE OF oDlgPend
		ACTIVATE MSDIALOG oDlgPend CENTER
		If nOpcPend == 0 // Esc ou Cancelar
			lPedPend := !lPedPend
			Return
		Endif
	Endif

	oMenuTree:ChangePrompt(OX018008D_PedPendPrompt(), STR0121)

	OXA018MTPD()

Return


/*/{Protheus.doc} OX018008D_PedPendPrompt

Retorna Label a ser exibido na opcao do Menu Tree

@author Francisco Carvalho
@since 08/09/2025
@version 1.0
@return ${return}, ${return_description}

@type function
/*/
Static Function OX018008D_PedPendPrompt()

	Local cReturn := STR0125 //"Ocultar Filtro de PendÍncias do Pedido"

	If !lPedPend
		cReturn := STR0126 //"Filtro de PendÍncias do Pedido"
	Endif

Return cReturn


/*/{Protheus.doc} OX018009D_Qry_PedidosPendentes
Retorna o filtro complementar para o bot„o de Filtro de PendÍncias dos Pedidos
1 = Com PendÍncia - Aguardando Pedido de compra
2 = Com PendÍncia - Aguardando TransferÍncia
3 = Sem PendÍncia†

@author Francisco Carvalho
@since 08/09/2025
@version 1.0
/*/
Static Function OX018009D_Qry_PedidosPendentes()

	Local cReturn := ""
	
	cReturn += " AND VS1_STATUS = '0' "
	cReturn += " AND VS1_PEDSTA = '0' "
	cReturn += " AND EXISTS ( "
	cReturn += "               SELECT VS3.VS3_NUMORC "
	cReturn += "                 FROM " + RetSqlName("VS3") + " VS3 "
	cReturn += "                WHERE VS3.VS3_FILIAL = VS1_FILIAL "
	cReturn += "                  AND VS3.VS3_NUMORC = VS1_NUMORC " 
	Do Case
		Case nOpcPend == 1 // 1 = Com PendÍncia - Aguardando Pedido de compra
			cReturn += " AND VS3_QTDAGU > 0 "
		Case nOpcPend == 2 // 2 = Com PendÍncia - Aguardando TransferÍncia
			cReturn += " AND VS3_QTDTRA > 0 "
		Case nOpcPend == 3 // 3 = Sem PendÍncia†
			cReturn += " AND VS3_QTDAGU = 0 "
			cReturn += " AND VS3_QTDTRA = 0 "
	EndCase
	cReturn += " AND VS3.D_E_L_E_T_ = ' ' "
	cReturn += " ) "

Return cReturn