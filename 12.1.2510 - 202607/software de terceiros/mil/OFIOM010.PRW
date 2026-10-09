#Include "Ofiom010.ch"
#Include "Protheus.ch"
#INCLUDE "FWMVCDEF.CH"


Static cMVMIL0006 := GetNewPar("MV_MIL0006","")
Static cMVGARJD_T := .f.
STATIC lMultMoeda := FGX_MULTMOEDA() 
Static lAltInconv := findFunction("OX001066K_AlteraDescricaoInconveniente")
Static checkIni := .f. 
#Define EVT_OS_ABERTA_SEM_ORCAMENTO         "32"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ OFIOM010 ³ Autor ³  Emilton              ³ Data ³ 19/08/99 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Abertura de Ordens de Servico Manual                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Oficina                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function OFIOM010(cNumOsv,nOpcOp,cNroOrc,lImp,lNoMBrowse)
Local cFilUser	:=	""
Local aCores    := {{ 'VO1->VO1_STATUS == "A"', 'BR_VERDE'     } ,;   // Aberta
					{ 'VO1->VO1_STATUS == "D"', 'BR_AZUL'     } ,;  // Liberada
					{ 'VO1->VO1_STATUS == "F"', 'BR_VERMELHO' } ,;  // Fechado
					{ 'VO1->VO1_STATUS == "C"', 'BR_PRETO'    } }   // Cancelado

Default lNoMBrowse := .f.

Private aArea     	:= GetArea() // Claudia
Private aIndVO1   	:= {} // Claudia
Private cCondicao 	:= "" // Claudia
PRIVATE aMemos  	:= {{"VO1_OBSMEM","VO1_OBSERV"}}
PRIVATE aCpoEnchoice := {}
//PRIVATE aCamposCamTec := {}
PRIVATE aRotina := OM010002C_menudef()
PRIVATE nLimCre := val(&(GetMV("MV_LIMCRE"))) , nIndVO1 := 0
Private lAuto := .f.
Private lImpOsv := .t.
Private cPerg := "OFM010"
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Define o cabecalho da tela de atualizacoes                   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
PRIVATE cCadastro := OemToAnsi(STR0004) //"Abertura de OS - Manual"
Private cGetDados := "oGD010"
Private lA1_IBGE := If(SA1->(FieldPos("A1_IBGE"))>0,.t.,.f.)
// Especifico para integração com Garantia
Private aRetWS := {}
//
Private lGarMut := (VO1->(FieldPos("VO1_GARMUT")) <> 0 )
Private nValGarMut := 0
//

if ! checkIni .and. ! IsBlind() .and. ExistFunc("FG_CHKINI")
	FG_CHKINI()
	checkIni := .t.
endif

VO1->(dbClearFilter())
Pergunte(cPerg,.f.)
// Antes de mostrar o browse de O.S.
If ExistBlock("MNBROM010")
	ExecBlock("MNBROM010",.f.,.f.,{})
EndIf

dbSelectArea("VO1")

// Valida se a empresa tem autorizacao para utiliza o modulo de oficina.
If AMIIn(11,14,41)

	If cMVGARJD_T
		MsgInfo(STR0135) // Simulacao de Garantia John Deere
	EndIf

	If lNoMBrowse
		dbSelectArea("VO1")
		If ( nOpc <> 0 ) .And. !Deleted()
			bBlock := &( "{ |a,b,c,d,e| " + aRotina[ nOpc,2 ] + "(a,b,c,d,e) }" )
			Eval( bBlock, Alias(), (Alias())->(Recno()),nOpc)
		EndIf
	Else

		DbSelectArea("VO1")

		dbSelectArea("VAI")
		dbSetOrder(4)
		dbSeek(xFilial("VAI")+__cUserID)
		cAnd := ""
		if MV_PAR01 == 1
			cCondicao := "VO1->VO1_STATUS == 'A'"
			cAnd := ".AND."
		elseif MV_PAR01 == 2
			cCondicao := "VO1->VO1_STATUS == 'L'"
			cAnd := ".AND."
		elseif  MV_PAR01 == 3
			cCondicao := "VO1->VO1_STATUS == 'F'"
			cAnd := ".AND."
		else
			cCondicao := ".t. "
			cAnd := ".AND."
		endif

		if MV_PAR02 > 0
			cCondicao := cCondicao + cAnd + "VO1->VO1_DATABE > DDATABASE - "+str(MV_PAR02)
			cAnd := ".AND."
		endif

		DbSelectArea("VO1")
		if 	VAI->VAI_TIPTEC == "4"
			dbSetOrder(1)
			cCondicao := cCondicao + cAnd + "VO1->VO1_FUNABE == VAI->VAI_CODTEC"
		Endif

		If 	ExistBlock("OFI010FBRW") // Ponto de Entrada para Filtro no Browse
			cFilUser := ExecBlock("OFI010FBRW",.F.,.F.,cCondicao)
			if	!Empty(cFilUser) .and. ValType(cFilUser) == "C"
				cCondicao += iif( !Empty(cCondicao) , " .and. " , "" ) + cFilUser
			Endif
		Endif

		if 	!Empty(cCondicao)
			bFiltraBrw := { || FilBrowse("VO1",@aIndVO1,@cCondicao) }
			Eval(bFiltraBrw)
		endif

		mBrowse(06,01,22,75,"VO1",,,,,,aCores)

		VO1->(dbClearFilter())


	EndIf
EndIf

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³OM010I_I  ºAutor  ³Thiago				 º Data ³  26/11/13   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Incluir ordem de servico                                    º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Oficina                                                    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function OM010I_I(cAlias,nReg,nOpc)
	nOpc := 3
	OM010I(cAlias,nReg,nOpc)
Return(.t.)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³OM010I_A  ºAutor  ³Thiago			     º Data ³  26/11/13   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Alterar ordem de servico                                    º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Oficina                                                    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function OM010I_A(cAlias,nReg,nOpc)
	nOpc := 4
	OM010I(cAlias,nReg,nOpc)
Return(.t.)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³OM010I    ºAutor  ³Fabio / Emilton     º Data ³  08/31/00   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Incluir ordem de servico                                    º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Oficina                                                    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function OM010I(cAlias,nReg,nOpc,lAbrirOSAgendamento)

Local aCpoAltera := IIF( nOpc # 3 , {} , NIL )
Local nRecnoVO1 := 0, nCntFor := 0, nOpca:=0
Local aObjects := {} , aPosObj := {} , aInfo := {} , aSizeAut := MsAdvSize(.t.) // Variaveis para posicionamento de Tela
local oControlTower := Nil 

Local aTitFolder := {}

Local aStruct 	:= {}
Local nX		:= 0
Local cWhen		:= ""
Local aStructVO1 := {}
Local cCampo	:= ""

Local aStructVST := {}
Local cRelacao

Private aCpoEnchoice  :={}
Private nOpcE := 0 , nOpcG := 0 , aFicha := {} , aHeader:={} , cChaIntF := "" , cChaIntA := ""
Private oLbaFicha , lImportAge := .f.
Private cObsOS := "", nTamObs := 0, aCfgCpo := {}, cMostraAgr := "", cMostraSeq := ""
Private nLenaCols:=0
PRIVATE aRotina := { {  ,"", , 3},;
{  ,"", , 3},;
{  ,"", , 3},;
{  ,"", , 4}}
Private aBotoes  := { {"PESQUISA",{|| FG_OSONLINE() },STR0011} }
Private oFnt3 := TFont():New( "Arial", , 14,.t. )
Private lInconveniente := 	(GetNewPar("MV_INCORC","N") == "S") 
Private aTarefas     := {}        
Private aHeaderTar   := {}
Private aColsTar     := {}
Private oGetTarefas
Private cDescTarefa  := ""
Default lAbrirOSAgendamento := .f.

lVO1DATATE := .F.
lVO1HORTRI := ( VO1->(FieldPos("VO1_HORTRI")) <> 0 )

If lInconveniente
	aTitFolder := { STR0012,STR0013, STR0150 } // "Tarefas / Reclamações / Solicitações"
Else
	aTitFolder := { STR0012,STR0013 }
EndIf

If lGarMut
	AADD( aBotoes , { "LJPRECO" , { || OM010GMUT() } , STR0128 } ) // "Garantia mutua"
EndIf

If cMVMIL0006 == "JD" .AND. FindFunction("OFICJD01")
	AADD( aBotoes , {"GET", { || OM010WS(2) } , STR0131 }) // "Consulta Inf. Garantia"
	AADD( aBotoes , {"GET", { || OM010WS(3) } , STR0132 }) // "Consulta Plano Revisão/PMP"
EndIf

If cMVMIL0006 == "SCA" .AND. FindFunction("OFICSC01")
	AADD( aBotoes , {"GLOBO", { || OM010WS(2) } , STR0097 }) // "Claw"
EndIf

If FindFunction("OIA410011_Tipos_de_Negocios_do_Cliente")
	AADD(aBotoes, {"CLIENTE", {|| OIA410011_Tipos_de_Negocios_do_Cliente( M->VO1_PROVEI , M->VO1_LOJPRO ) } , STR0139 }) // Tipos de Negócios do Cliente Proprietário do Veiculo
	AADD(aBotoes, {"CLIENTE", {|| OIA410011_Tipos_de_Negocios_do_Cliente( M->VO1_FATPAR , M->VO1_LOJA ) } , STR0140 }) // Tipos de Negócios do Cliente Faturar para
EndIf

If ExistBlock("INCBOT010")
	aBotoes := ExecBlock("INCBOT010",.f.,.f.,{aBotoes})
EndIf

If Type("lAuto") == "U"
	lAuto := .f.
EndIf

If nOpc == 4 .And. VO1->VO1_STATUS # "A"
	If VO1->VO1_STATUS <> "F" .and. VO1->VO1_STATUS <> "C"
		// Recupera estrutura do alias VO1
		aStruct := FWSX3Util():GetListFieldsStruct("VO1", .T.)

		For nX := 1 To Len(aStruct)

			// Campo VO1_FATPAR
			If aStruct[nX][1] == "VO1_FATPAR"

				cWhen := AllTrim(GetSX3Cache("VO1_FATPAR", "X3_WHEN"))

				If !Empty(cWhen)

					// Executa WHEN com contexto seguro
					If &(cWhen) == .F.
						Help("  ", 1, "OSNABERTA")
						Return
					EndIf

				EndIf

				Exit
			EndIf

		Next nX
	EndIf
EndIf

// Tira o filtro
nRecnoVO1 := VO1->(Recno())

dbSelectArea("VO1")       // CLAUDIA
RetIndex("VO1")           // CLAUDIA
dbClearFilter()           // CLAUDIA
VO1->(DbGoTo(nRecnoVO1))

If nOpc == 3
	nOpcE  := 3
	nOpcG  := 3
	Inclui := .t.
	Altera := .f.
Else
	nOpc  := 4
	nOpcE := 4
	nOpcG := 4
	Inclui := .f.
	Altera := .t.
EndIf


aCpoEnchoice := {}

// Recupera estrutura da VO1 via cache
aStructVO1 := FWSX3Util():GetListFieldsStruct("VO1", .T.)

For nX := 1 To Len(aStructVO1)

	cCampo := AllTrim(aStructVO1[nX][1])

	If X3USO(GetSX3Cache(cCampo, "X3_USADO")) .And. ;
	   ( cNivel >= GetSX3Cache(cCampo, "X3_NIVEL") .Or. ;
	     X3OBRIGAT(cCampo) ) .And. ;
	   ( ;
	     !( cCampo $ ;
	        "VO1_NUMOSV/VO1_DATSAI/VO1_HORSAI/VO1_STATUS/VO1_TEMGAR/" + ;
	        "VO1_TEMLIB/VO1_MECREQ/VO1_TIPSOL/VO1_SITGAR/VO1_OBSMEM/" + ;
	        "VO1_CODMAR/VO1_EXPGAR/VO1_MOTIVO/VO1_DESMOT/" + ;
	        "VO1_TEMFEC/VO1_TEMCAN/VO1_OBSLAU" ) .Or. ;
	     ( nOpcE # 3 .And. cCampo == "VO1_NUMOSV" ) ;
	   ) .and. ;
	   !( cCampo == "VO1_GETKEY" .and. lAbrirOSAgendamento )

		AAdd(aCpoEnchoice, cCampo)

	EndIf

	&( "M->" + cCampo ) := CriaVar(cCampo)

	If nOpcE # 3 .And. GetSX3Cache(cCampo, "X3_PROPRI") == "U"
		AAdd(aCpoAltera, cCampo)
	EndIf

	If cCampo == "VO1_OBSERV"
		nTamObs := GetSX3Cache(cCampo, "X3_TAMANHO")
	EndIf

Next nX

If lInconveniente


	// Campos não editáveis
	cVSTnEdit := "VST_FILIAL,VST_SEQINC,VST_GRUINC,VST_CODINC,"

	// Campos não exibidos
	cVSTnMostra := ;
		"VST_FILIAL,VST_GRUINC,VST_CODINC,VST_TIPO,VST_CODIGO," + ;
		"VST_EXPPEC,VST_EXPSRV,VST_CODMAR,VST_CHASSI,"

	nUsadoI  := 0
	aHeaderI := {}
	aAlterI  := {}

	// Recupera estrutura da VST via SX3 cache
	aStructVST := FWSX3Util():GetListFieldsStruct("VST", .T.)

	For nX := 1 To Len(aStructVST)

		cCampo := AllTrim(aStructVST[nX][1])

		



		
		If X3USO(GetSX3Cache(cCampo, "X3_USADO")) .And. ;
		   cNivel >= GetSX3Cache(cCampo, "X3_NIVEL") .And. ;
		   !(cCampo + "," $ cVSTnMostra)

			nUsadoI++

			AAdd(aHeaderI, { ;
				iif( lAltInconv, OX001066K_AlteraDescricaoInconveniente(cCampo), retTitle(cCampo) ), ; // 1
				cCampo,                                   ; // 2
				AllTrim(GetSX3Cache(cCampo, "X3_PICTURE")),; // 3
				aStructVST[nX][3],                        ; // 4 TAMANHO
				aStructVST[nX][4],                        ; // 5 DECIMAL
				AllTrim(GetSX3Cache(cCampo, "X3_VALID")), ; // 6
				AllTrim(GetSX3Cache(cCampo, "X3_USADO")), ; // 7
				GetSX3Cache(cCampo, "X3_TIPO"),            ; // 8
				GetSX3Cache(cCampo, "X3_F3"),              ; // 9
				AllTrim(GetSX3Cache(cCampo, "X3_CONTEXT")),;// 10
				X3CBOX(cCampo),                            ; // 11
				AllTrim(GetSX3Cache(cCampo, "X3_RELACAO")), ; // 12
				".T."                                     ; // 13  <<< flag de exibição / edição MsNewGetDados
			})

			// Campos alteráveis
			If GetSX3Cache(cCampo, "X3_USADO") <> "V" .And. ;
			   (INCLUI .Or. ALTERA) .And. ;
			   !(cCampo + "," $ cVSTnEdit)

				AAdd(aAlterI, cCampo)

			EndIf

		EndIf

	Next nX

	If INCLUI

		// Linha em branco
		aColsI := { Array(nUsadoI + 1) }
		aColsI[1, nUsadoI + 1] := .F.

		For nCntFor := 1 To nUsadoI
			aColsI[1, nCntFor] := CriaVar(aHeaderI[nCntFor, 2])
		Next

	Else

		// Carga dos registros existentes da VST
		aColsI := {}

		DbSelectArea("VST")
		DbSetOrder(1)
		DbSeek(xFilial("VST") + "2" + VO1->VO1_NUMOSV)

		While !Eof() .And. ;
		      VST->VST_FILIAL == xFilial("VST") .And. ;
		      VST->VST_TIPO   == "2" .And. ;
		      VST->VST_CODIGO == VO1->VO1_NUMOSV

			AAdd(aColsI, Array(nUsadoI + 1))

			For nCntFor := 1 To nUsadoI

				// Campo virtual (X3_TIPO = "V")
				If aHeaderI[nCntFor, 8] == "V"

					cRelacao := aHeaderI[nCntFor, 12]

					If !Empty(cRelacao)
						aColsI[Len(aColsI), nCntFor] := &(cRelacao)
					Else
						aColsI[Len(aColsI), nCntFor] := Nil
					EndIf

				Else
					aColsI[Len(aColsI), nCntFor] := FieldGet(FieldPos(aHeaderI[nCntFor, 2]))
				EndIf

			Next

			// Flag de exclusão
			aColsI[Len(aColsI), nUsadoI + 1] := .F.

			DbSkip()

		EndDo

	EndIf

EndIf


lVO1DATATE := ( aScan(aCpoEnchoice, "VO1_DATATE" ) > 0 )

If nOpcE # 3

	DbSelectArea("VO1")
	For nCntFor := 1 TO FCount()
		M->&(FieldName(nCntFor)) := FieldGet(nCntFor)
	Next

	If Empty(VO1->VO1_NUMBOX)
		Aadd( aCpoAltera , "VO1_NUMBOX" )
	EndIf
	Aadd( aCpoAltera , "VO1_KILOME" )
	If VO1->(FieldPos("VO1_HORTRI")) > 0
		Aadd( aCpoAltera , "VO1_HORTRI" )
	EndIf
	Aadd( aCpoAltera , "VO1_OBSMEM" )
	Aadd( aCpoAltera , "VO1_OBSERV" )
	Aadd( aCpoAltera , "VO1_HORABE" )
	Aadd( aCpoAltera , "VO1_FUNABE" )
	// Seguradora
	Aadd( aCpoAltera , "VO1_NUMLIB" )
	Aadd( aCpoAltera , "VO1_FORPAG" )
	Aadd( aCpoAltera , "VO1_CODBCO" )
	Aadd( aCpoAltera , "VO1_APOLIC" )
	Aadd( aCpoAltera , "VO1_SINIST" )
	Aadd( aCpoAltera , "VO1_NROAPR" )
	Aadd( aCpoAltera , "VO1_FATPAR" )
	Aadd( aCpoAltera , "VO1_LOJA" )
	Aadd( aCpoAltera , "VO1_DATENT" )
	Aadd( aCpoAltera , "VO1_HORENT" )
	If VO1->(FieldPos("VO1_TPATEN")) <> 0
		Aadd( aCpoAltera , "VO1_TPATEN" )
	Endif
	If Empty(VO1->VO1_FRANQU)
		Aadd( aCpoAltera , "VO1_FRANQU" )
	EndIf
	If VO1->(FieldPos("VO1_FRANQP")) > 0 .AND. Empty(VO1->VO1_FRANQP)
		Aadd( aCpoAltera , "VO1_FRANQP" )
	EndIf
		// Se houver uma requisicao de servico com apontamento, nao sera possivel alterar a data de atendimento da OS
	// Não é possivel alterar, pois quando informada a data de atendimento, a validacao do apontamento sera feita de acordo com seu conteudo...
	cSQL := "SELECT COUNT(*)"
	cSQL +=  " FROM " + RetSQLName("VO4") + " VO4 "
	cSQL += " WHERE VO4.VO4_FILIAL = '" + xFilial("VO4") + "'"
	cSQL +=   " AND VO4.VO4_NUMOSV = '" + VO1->VO1_NUMOSV + "'"
	cSQL +=   " AND VO4.VO4_DATINI <> '        '"
	cSQL +=   " AND VO4.D_E_L_E_T_ = ' '"
	If FM_SQL(cSQL) == 0
		Aadd( aCpoAltera , "VO1_DATATE" )
		Aadd( aCpoAltera , "VO1_HORATE" )
	EndIf

	//	Campos que podem ser alterados somente quando nao existe Requisicoes de Pecas e/ou Apontamentos de Servicos //
	If FS_PECSRV()
		Aadd( aCpoAltera , "VO1_GETKEY" ) // Chave de Pesquisa do Veiculo (Chassi/Chaint/Placa/...)
	EndIf

	// Garantia Mutua
	If VO1->(FieldPos("VO1_GARMUT")) <> 0
		VDF->(dbSetOrder(2))
		If !VDF->(dbSeek(xFilial("VDF") + VO1->VO1_NUMOSV))
			Aadd( aCpoAltera , "VO1_GARMUT" )
		EndIf
	EndIf
	//
	If VO1->(FieldPos("VO1_FALHA")) <> 0
		Aadd( aCpoAltera , "VO1_FALHA" )
	Endif
	If VO1->(FieldPos("VO1_CAUSA")) <> 0
		Aadd( aCpoAltera , "VO1_CAUSA" )
	Endif
	If VO1->(FieldPos("VO1_SOLUCA")) <> 0
		Aadd( aCpoAltera , "VO1_SOLUCA" )
	Endif
	//
	Aadd( aCpoAltera , "VO1_OROSJD" )
	If cPaisLoc == "ARG"
		If VO1->(FieldPos("VO1_OBSAPO")) <> 0
			Aadd( aCpoAltera , "VO1_OBSAPO" )
		Endif
	EndIf
//
EndIf

If nOpc == 4 .AND. VO1->VO1_STATUS # "C"
	If  GetNewPar("MV_MIL0023","N") <> "S"  //Não permite alterar Chassi OS com Requisição antes da Liberação? (S ou N)
		If VO1->VO1_STATUS # "A"
			aCpoAltera := {}
			Aadd( aCpoAltera , "VO1_FATPAR" )
			Aadd( aCpoAltera , "VO1_LOJA" )
		Endif
	Else
		If VO1->VO1_STATUS $ "DF"
			aCpoAltera := {}
			Aadd( aCpoAltera , "VO1_FATPAR" )
			Aadd( aCpoAltera , "VO1_LOJA" )
		Endif
	Endif

ElseIf nOpc == 4 .AND. VO1->VO1_STATUS $ "C"
	//CI 010853 passou a permitir alteração do horimetro de OS cancelada
	aCpoAltera := {}
	Aadd( aCpoAltera , "VO1_HORTRI" )
	Aadd( aCpoAltera , "VO1_KILOME" )
EndIf


If nOpc == 4
	/* mostrar os dados do veiculo, proprietario etc na alteracao */
	FG_SEEK("VV1","vo1->vo1_chassi",2,.f.)
	if FG_SEEK("VO5","VV1->VV1_CHAINT",1,.f.)
		FG_SEEK("VV2","VV1->VV1_CODMAR+VV1->VV1_MODVEI",1,.f.)
		FG_SEEK("VVC","VV1->VV1_CODMAR+VV1->VV1_CORVEI",1,.f.)
		FG_SEEK("SA1","VV1->VV1_PROATU+VV1->VV1_LJPATU",1,.f.)
		If lA1_IBGE
			FG_Seek("VAM","SA1->A1_IBGE",1,.f.) // CIDADE
		EndIf

		DbSelectArea("VE1")
		DbSetOrder(1)
		DbSeek(xFilial("VE1") + VV1->VV1_CODMAR)

		M->VO1_DESMAR := VE1->VE1_DESMAR
		M->VO1_DESMOD := VV2->VV2_DESMOD
		M->VO1_GETKEY := VV1->VV1_CHASSI
		M->VO1_CODFRO := VV1->VV1_CODFRO
		M->VO1_PLAVEI := VV1->VV1_PLAVEI
		M->VO1_FABMOD := VV1->VV1_FABMOD
		M->VO1_DESCOR := VVC->VVC_DESCRI
		M->VO1_PROVEI := SA1->A1_COD
		M->VO1_LOJPRO := VV1->VV1_LJPATU
		M->VO1_NOMPRO := SA1->A1_NOME
		M->VO1_NOMFAT := SA1->A1_NOME
		M->VO1_ENDPRO := SA1->A1_END
		M->VO1_CIDPRO := FS_VLCIDEST()[1]
		M->VO1_ESTPRO := FS_VLCIDEST()[2]
		M->VO1_FONPRO := SA1->A1_TEL
		M->VO1_CODMAR := VE1->VE1_CODMAR
	EndIF

EndIF

// Salva o conteudo da observacao para tratamento.
If Altera .and. VE4->VE4_TRAOSV == "1"

	cObsOS := M->VO1_OBSERV
	If !Empty(M->VO1_OBSERV) .And. Substr( M->VO1_OBSERV , (Len(M->VO1_OBSERV)-50) , 48 ) # Repl("_",48)
		M->VO1_OBSERV += Chr(13)+Chr(10)+Repl("_",nTamObs)+Chr(13)+Chr(10)
		cObsOS := M->VO1_OBSERV
	EndIf

EndIf

aObjects := {}
AAdd( aObjects, { 100, 100, .T., .T. } )
aInfo := {aSizeAut[1] , aSizeAut[2] , aSizeAut[3] , aSizeAut[4] , 1 , 1 }
aPosObj := MsObjSize (aInfo, aObjects, .t.)

DEFINE MSDIALOG oDlg TITLE STR0004 From aSizeAut[7],000 TO aSizeAut[6],aSizeAut[5] of oMainWnd PIXEL


oFldOm010 := TFolder():New(aPosObj[1,1], aPosObj[1,2], aTitFolder, , oDlg, , , , .t. , , aPosObj[1,4], aPosObj[1,3]-aPosObj[1,1] )


oFldOm010:bChange := {|| FS_FICHA() }
oFldOm010:bSetOption := {|| FS_OM010LOK() }

// Primeira Aba                                   //191 - 220
//EnChoice("VO1",nReg,nOpcE,,,,aCpoEnchoice,{000,000,aPosObj[1,3]-27,aPosObj[1,4]-2},aCpoAltera,3,,,,oFldOm010:aDialogs[1],,.F.)
oEnc010VO1 := MsMGET():New("VO1",nReg, nOpcE ,;
	/* aCRA */, /* cLetra*/, /* cTexto */, aCpoEnchoice, ;
	{000,000,aPosObj[1,3]-27,aPosObj[1,4]-2}, ;
	aCpoAltera, 3 /* nModelo */ ,;
	/* nColMens */, /* cMensagem */, "AllwaysTrue()", oFldOm010:aDialogs[1] , .f. /* lF3 */ , .f. /* lMemoria */ , .F. /* lColumn */ ,;
	/* caTela */ ,  /* lNoFolder */, .f. /* lProperty */ )
oEnc010VO1:oBox:Align := CONTROL_ALIGN_ALLCLIENT

// Segunda Aba
@ 001,.1 LISTBOX oLbaFicha FIELDS HEADER;
		OemToAnsi(STR0015);
		SIZE 100,100 OF oFldOm010:aDialogs[2] PIXEL
//oLbaFicha:oFont := oFont
oLbaFicha:Align := CONTROL_ALIGN_ALLCLIENT

Aadd( aFicha , {""} )

oLbaFicha:SetArray(aFicha)
oLbaFicha:bLine := { || { aFicha[oLbaFicha:nAt,1] } }

if lInconveniente
	// Funcoes de controle de eventos das getdados de pecas e servicos
	// Verifica a linha inteira da aCols (chamada na troca entre as linhas)
	cLinOkI		:= "AllwaysTrue()"
	// Verifica cada um dos campos da aCols (chamada na troca de foco entre os campos)
	cFieldOkI   := "AllwaysTrue()"
	// verifica toda a acols
	cTudoOkI	:= "AllwaysTrue()"
	// Validacao das aCols
	cDelIncOk	:= "AllwaysTrue()"
	//
	cDesInc := space(TamSX3("VST_DESINC")[1])
	

	/*
		ATENÇÃO HOJE E POSSIVEL INCLUIR TAREFAS/RECLAMAÇÕES/SOLICITAÇÕES INDEPENDETE DO STATUS DA O.S.
		ENTRETANTO, FUTURAMENTE PODE SER QUE SEJA NECESSÁRIO RESTRIÇÃO.
		SE ISSO ACONTECER, DESCOMENTAR A LINHA ABAIXO E COLOCAR A MESMA CONDIÇÃO NA INCLUSÃO DE INCONVENIENTES		
		WHEN ((INCLUI .OR. ALTERA) .AND.  VO1->VO1_STATUS == "A" .AND. !Empty(M->VO1_CHASSI))
	*/

	oSay01 := TSay():New(04, 05, {|| STR0151 },oFldOm010:aDialogs[3],,oFnt3,,,,.t.,,,40,8) // "Reclamação:"
	@ 03,50 MSGET oDesInc VAR cDesInc VALID .t. PICTURE "@!" SIZE 250,8 PIXEL OF oFldOm010:aDialogs[3] WHEN ((INCLUI .OR. ALTERA) .AND. !Empty(M->VO1_CHASSI))
	nPosObj := 310

	@ 03,nPosObj BUTTON oBotOk PROMPT "OK" OF oFldOm010:aDialogs[3] SIZE 30,10 PIXEL ACTION OM010INCON(nOpc,cDesInc,"D"/*,lFlxPac*/) WHEN ((INCLUI .OR. ALTERA) .AND. !Empty(M->VO1_CHASSI))
	//
	cDesInc := space(TamSX3("VST_DESINC")[1])
	//
	oGetInconv := MsNewGetDados():New(16, 00, aPosObj[1,3]-aPosObj[1,1]-20,aPosObj[1,4]-aPosObj[1,2]-2,0,;
	cLinOKI,cTudoOkI,,aAlterI,0,999,cFieldOkI,,cDelIncOk,oFldOm010:aDialogs[3],aHeaderI,aColsI )
	oGetInconv:oBrowse:bDelete       := {||OM010DELI() }
	//
endif

if nOpc == 3 .and. lAbrirOSAgendamento
	OM0100122_AbrirOSPeloAgendamento()
endif

ACTIVATE MSDIALOG oDlg ON INIT ( EnchoiceBar(oDlg,{|| if(FS_OM010LOK().and. obrigatorio(oEnc010VO1:aGets,oEnc010VO1:aTela).And.FS_OM010GRA(nOpc, lAbrirOSAgendamento),(nOpca:=1,oDlg:End()),.f.) },{|| (nOpca:=2,oDlg:End()) },,aBotoes) )

cNumAgenda := ""

nValGarMut := 0

DbSelectArea("VO1")

// Volta Filtro
if VAI->VAI_TIPTEC == "4"
	If Type("bFiltraBrw") # "U"
		bFiltraBrw := {|| FilBrowse("VO1",@aIndVO1,@cCondicao) }
		Eval(bFiltraBrw)
		///	VO1->(DbGoTo(nRecnoVO1))
	EndIf
Endif


// Disparo Control Tower (Nova Rotina)
//Evento: OS Aberta / Sem Orçamento (32)
If FindClass("OFSEventoControlTower") .and. GetNewPar("MV_MIL0006","") == "SCA" .And. !Empty(VO1->VO1_NUMOSV) 
	oControlTower := OFSEventoControlTower():New()
	oControlTower:ExecutarEvento(EVT_OS_ABERTA_SEM_ORCAMENTO, VV1->VV1_CHASSI, VO1->VO1_NUMOSV, "", "")
	FreeObj(oControlTower)
EndIf 

Return( (nOpca == 1) )
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³FS_OM010GRA Autor ³  Emilton              ³ Data ³ 19/08/99 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Gravacao da Ordens de Servico                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Oficina                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function FS_OM010GRA(nOpc, lAbrirOSAgendamento)
Local lOk       := .T.
Local aParambox := {}
Local aRet      := {}
local lDiarioOficina := FindFunction("OA5480062_RegistraEventoDiarioOficina")

default lAbrirOSAgendamento := .f.

PRIVATE aMemos  := {{"VO1_OBSMEM","VO1_OBSERV"}}

If Empty(M->VO1_NUMAGE)
	dbSelectArea("VSO")
	dbSetOrder(3)
	if dbSeek(xFilial("VSO")+M->VO1_GETKEY)
		While !Eof() .and. xFilial("VSO") == VSO->VSO_FILIAL .and. M->VO1_GETKEY == VSO->VSO_GETKEY
			if VSO->VSO_DATAGE > dDataBase
				if !MsgYesNo( STR0086 + dtoc(VSO->VSO_DATAGE) + STR0087 + transform(val(VSO->VSO_HORAGE),"@E 99:99")+ STR0088 ) // Veiculo encontra-se agendado no dia
					Return(.f.)
				Else
					Exit
				Endif
			Endif
			dbSelectArea("VSO")
			dbSkip()
		Enddo
	Endif
Endif

// Verifica se o cliente esta bloqueado
DbSelectArea("SA1")
DbSetOrder(1)
If !Empty(M->VO1_FATPAR)
	DbSeek(xFilial("SA1")+M->VO1_FATPAR+M->VO1_LOJA)
Else
	DbSeek(xFilial("SA1")+M->VO1_PROVEI+M->VO1_LOJPRO)
EndIf
If SA1->A1_MSBLQL == "1"
	MsgStop(STR0083+CHR(13)+CHR(10)+CHR(13)+CHR(10)+Alltrim(RetTitle(IIf(!Empty(M->VO1_FATPAR),"VO1_FATPAR","VO1_PROVEI")))+": "+SA1->A1_COD+"-"+SA1->A1_LOJA+" "+SA1->A1_NOME,STR0029) // Cliente bloqueado! / Atenção!
	DbSelectArea("VO1")
	Return(.f.)
EndIf

// Validação Tipo de Atendimento por Tipo de Tempo (Peça e Serviços)
If !OM010TPATEN(M->VO1_TPATEN, M->VO1_NUMOSV, .t.)
	Return .f.
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ So exibe Parambox se existe o campo VO1_FRANQP (Update de OS de Seguradora) ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
if (M->VO1_FRANQU > 0 .and. VO1->(FieldPos("VO1_FRANQP")) > 0 ) .or. (VO1->(FieldPos("VO1_FRANQP")) > 0 .AND. M->VO1_FRANQP > 0)

	cTTSegPeca := cTTSegSrvc := Space(TamSX3("VOI_TIPTEM")[1])
	aParamBox := {}
	aAdd(aParamBox,{1,STR0084 ,cTTSegPeca,"@!","!Empty(MV_Par01)","VOI","",0,.t.}) // "TT Seguradora - Peca"
	aAdd(aParamBox,{1,STR0085 ,cTTSegSrvc,"@!","!Empty(MV_PAR02)","VOI","",0,.t.}) // "TT Seguradora - Serv."
	While .t.
		If ParamBox(aParamBox,STR0091,@aRet,,,,,,,,.T.)//"TT de Seguradora"
			cTTSegPeca := aRet[1]
			cTTSegSrvc := aRet[2]
			exit
		Endif
	Enddo

endif

Begin Transaction

DbSelectArea("VO1")
RecLock("VO1",If(nOpc == 3,.t.,.f.))
FG_GRAVAR("VO1")
If nOpc == 3
//	If cMVGARJD_T .AND. M->VO1_CODMAR == FMX_RETMAR("JD") .and. MsgNoYes(STR0136) // Deseja informar o número manualmente?
//		VO1->VO1_NUMOSV := FMX_INPUTBOX(STR0137, Space(TamSX3("VO1_NUMOSV")[1])) // "Número da O.S"
//	Else
		VO1->VO1_NUMOSV := GetSXENum("VO1","VO1_NUMOSV")
		ConfirmSx8()
//	EndIf
EndIf

dbSelectArea("VA8")
dbSetOrder(1)
if dbSeek(xFilial("VA8")+space(Len(VO1->VO1_NUMOSV))+VO1->VO1_PLAVEI)
	dbSelectArea("VA8")
	Reclock("VA8",.f.)
	VA8->VA8_NUMOSV := VO1->VO1_NUMOSV
	MsUnlock()
Endif
If VSR->(FieldPos("VSR_PLAVEI")) # 0
	dbSelectArea("VSR")
	dbSetOrder(2)
	if dbSeek(xFilial("VSR")+space(Len(VO1->VO1_NUMOSV))+VO1->VO1_PLAVEI)
		dbSelectArea("VSR")
		Reclock("VSR",.f.)
		VSR->VSR_NUMOSV := VO1->VO1_NUMOSV
		MsUnlock()
	Endif
Endif
MSMM(VO1->VO1_OBSMEM,TamSx3("VO1_OBSERV")[1],,&(aMemos[1][2]),1,,,"VO1","VO1_OBSMEM")

MsUnlock()
cNumOsv := VO1->VO1_NUMOSV

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Ajusta Status do Box para analise.³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
FG_MARCABOX(VO1->VO1_NUMBOX,VO1->VO1_CODCOR,VO1->VO1_PRISMA,VO1->VO1_NUMOSV)

// tratamento de controle de status de veiculos soh se estiver abrindo OS para um veiculo que esta no estoque
VV1->(DbsetOrder(1))
VV1->(Dbseek(xFilial("VV1")+M->VO1_CHAINT))
If FG_STATUS(,"X") .and. VV1->VV1_SITVEI $ "0 "
	FG_STATUS(M->VO1_CHAINT,"O")
Endif

If lInconveniente
	//Grava Inconveniente
	OM420GRAVA( @oGetInconv:aCols , aHeaderI , "2" , VO1->VO1_NUMOSV , VV1->VV1_CODMAR , VV1->VV1_CHASSI )
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Gera Requisicao de Franquia    P E C A S     ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
if VO1->(FieldPos("VO1_FRANQP")) > 0 .AND. VO1->VO1_FRANQP > 0
	if !REQFRA020(VO1->VO1_NUMOSV,cTTSegPeca)
		DisarmTransaction()
		lOk := .f.
	endif
endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Gera Requisicao de Franquia    S E R V I C O ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
if lOk .and. VO1->VO1_FRANQU > 0 .and. VO1->(FieldPos("VO1_FRANQP")) > 0 // So deve requisitar se tiver rodado o UPDATE de OS de Seguradora
	if !REQFRA030(VO1->VO1_NUMOSV,cTTSegSrvc)
		DisarmTransaction()
		lOk := .f.
	endif
endif

// Importa Garantia ...
If lOk .and. !OM010IMPGAR()
	DisarmTransaction()
	RollbackSx8()
	lOk := .f.
EndIf
//

// Se for GARANTIA MUTUA e informado o valor estimado, gera a solicitacao de garantia mutua
If lOk .and. lGarMut .and. VO1->VO1_GARMUT == "1" .and. nValGarMut <> 0
	OA550INC(VO1->VO1_NUMOSV, "", nValGarMut)
EndIf
//

If lOk .and. cMVMIL0006 == "SCA" .AND. FindFunction("OFINSC01")
	OFSC01(.f.,.t.,VO1->VO1_NUMOSV,Space(TamSX3("VOI_TIPTEM")[1]),Space(TamSX3("VOO_LIBVOO")[1]))//lEnd, lAuto, cTipTem, cLibVOO	
EndIf

// Atualiza tabela VFB
If lOk .and. nOpc == 4
	//ajustado por Fernando Radu Muscalu em 08/03/2024 - CI 2136-013001
	OM010ALTVFB(VO1->VO1_PROVEI,VO1->VO1_LOJPRO,VO1->VO1_CHAINT,cNumOsv,VO1->VO1_KILOME)
Endif

if FWAliasInDic("VO0")
	OM010VO0()
EndIf

//Após demais gravações, se for o caso, vincula o agendamento com a OS
if nOpc == 3 .or. nOpc == 4
	if lDiarioOficina .and. !empty(cNumOsv)
		OA5480062_RegistraEventoDiarioOficina(cNumOsv, '009') // 009 – ABERTURA DA ORDEM DE SERVICO
	endif
endif

End Transaction

// Zera variavel de garantia mutua
nValGarMut := 0
//
If nOpc == 3

	If Type("GrvNoOS_") # "U"
		GrvNoOS_ := cNumOSv
	EndIf

	DEFINE MSDIALOG oDlgOSv TITLE OemtoAnsi(STR0009) FROM  02,04 TO 09,41 OF oMainWnd  //Dados da Ordem de Servico

	@ 002,004 TO 35,145 LABEL STR0010 OF oDlgOSv PIXEL  //Nro. da Ordem de Servico:
	@ 010, 035 Say cNumOSv  OF oDlgOSv PIXEL Font TFont():New( "System", 015, 048 ) SIZE 105,20

	DEFINE SBUTTON oFecha   FROM 038,110 TYPE 1 ACTION oDlgOSv:End() ENABLE OF oDlgOSv

	ACTIVATE MSDIALOG oDlgOSv CENTER

	// Imprime
	If lImpOsv
		FG_PEDORD(VO1->VO1_NUMOSV,"N","S")
	EndIf

EndIf

If ExistBlock("OM010DPGR")
	ExecBlock("OM010DPGR",.f.,.f.,{nOpc})
EndIf

If (nOpc == 4 .OR. nOpc == 3) .AND. !empty(M->VO1_NUMAGE)

	OM350STATUS(M->VO1_NUMAGE,"1","2")

	if VSO->VSO_STATUS == '5'
		OM0100102_VincularOSDoAgendamentoComOrcamento(M->VO1_NUMAGE, VO1->VO1_NUMOSV)
	endif
endif

Return(.t.)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³FS_FICHA  ºAutor  ³Fabio               º Data ³  09/19/01   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Verifica historico de passagens                             º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ oficina                                                    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function FS_FICHA()

if oFldOm010:nOption == 2
	FS_IMPFICHA()
Endif

Return(.t.)


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³FS_OM010LO Autor  ³Fabio               º Data ³  09/20/01   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Valida linha da getdados                                    º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Oficina                                                    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function FS_OM010LOK()

Local cFatPar := "", cLojPar := ""
Local cProVei := "", cLojVei := ""
Local lVO1SEGMTO := VO1->(FieldPos("VO1_SEGMTO")) > 0 
local oRpm := OFJDRpmConfig():New()

If ExistBlock("OM010BLOQ")
   If !ExecBlock("OM010BLOQ",.f.,.f.)
      return (.f.)
   Endif
EndIf



If !FS_VKILHOR( M->VO1_KILOME , IIF( lVO1HORTRI , M->VO1_HORTRI , 0 ) )
	Return .f.
EndIf

If cMVMIL0006 == "JD" .and. Altera .and. M->VO1_KILOME != VO1->VO1_KILOME
   FS_ATUKMJD()//Funcao atualiza km no cabecalho da garantia JD (VMB)
EndIf

If Type("M->VO1_FATPAR") # "U"
	cFatPar := M->VO1_FATPAR
	cLojPar := M->VO1_LOJA
	cProVei := M->VO1_PROVEI
	cLojVei := M->VO1_LOJPRO
ElseIf Type("M->VS1_CLIFAT") # "U"
	cFatPar := M->VS1_CLIFAT
	cLojPar := M->VS1_LOJA
	cProVei := VV1->VV1_PROATU
	cLojVei := VV1->VV1_LJPATU
EndIf

If  oRpm:lNovaConfiguracao .and. cMVMIL0006 == "JD" .and. lVO1SEGMTO .and. Empty(M->VO1_SEGMTO) 
	Help(" ",1,"OBRIGAT2",,RetTitle("VO1_SEGMTO"),4,1)
	Return .f.
endif

// Valida limite de credito
If !Empty(cFatPar) .And. !Empty(cLojPar)
	//   FG_Seek("SA1","M->VO1_FATPAR+M->VO1_LOJA",1,.f.)
	SA1->(DbSetOrder(1))
	SA1->(DbSeek( xFilial("SA1") + cFatPar + cLojPar ))
	If !FS_LIMCRE(cFatPar,cLojPar,iif(lMultMoeda,M->VO1_MOEDA,0))
		Return(.f.)
	EndIf
Else
	//   FG_Seek("SA1","M->VO1_PROVEI+M->VO1_LOJPRO",1,.f.)
	SA1->(DbSetOrder(1))
	SA1->(DbSeek( xFilial("SA1") + cProVei + cLojVei ))
	If !FS_LIMCRE( cProVei, cLojVei,iif(lMultMoeda,M->VO1_MOEDA,0))
		Return(.f.)
	EndIf
EndIf

// Valida Observacao
If !FS_VALOBS()
	Return(.f.)
EndIf

Return(.t.)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡Æo    ³ FS_GetKey³ Autor ³  Emilton              ³ Data ³ 19/07/99 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡Æo ³ Apresenta Dados de Veiculos para Orcamento                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Generico                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function FS_GETKEY()
Local lReturn   := .f. , cSelect := Alias() 
Local oVeiculos := DMS_Veiculo():New()
local oConfSC 	:= Nil

Local aCampoVO5 := {}
Local aStructVO5 := {}
Local nX
Local cCampo

Private cPesqVV1 := M->VO1_GETKEY

If Empty(M->VO1_GETKEY)
	Return(.t.)
EndIf

lReturn := FG_POSVEI("cPesqVV1",)

if !lReturn
	return(lReturn)
endif

DBSelectArea("VV1")

// Chassi Bloqueado
If oVeiculos:Bloqueado(VV1->VV1_CHAINT)
	Return .f. 
EndIf

If ExistFunc("OA5410012J_CarregaConfigVRNDeAcordoComAmbienteEIntegracao")
	oConfSC := OA5410012J_CarregaConfigVRNDeAcordoComAmbienteEIntegracao('OFIA541', 'SCOB', totvs.framework.environment.type.envAppGet(.T.))
	if OA5410013J_VerificaExibicaTelaComplementoCadastroVeiculo(oConfSC, 'OFIOM010')
		VV1->(DbSetOrder(1))
		VV1->(DbSeek(xFilial("VV1")+ VV1->VV1_CHAINT))
		if !FGX_ValidRequiredFieds(VV1->(Recno()), "VV1")
			VA0700113_AlteracaoChassi()
		endif
	endif
	freeObj(oConfSC)
Endif

M->VO1_GETKEY := VV1->VV1_CHASSI

If FindFunction("FGX_ALTVEI")
	FGX_ALTVEI("A") 
Else
	FS_ALINVEI("A")
EndIf

If Empty(VV1->VV1_PROATU) .or. Empty(VV1->VV1_LJPATU)
	Help(" ",1,"OM010OBR")
	Return .f.
EndIf

If !Empty(M->VO1_PROVEI+M->VO1_LOJPRO)
	If VV1->VV1_PROATU+VV1->VV1_LJPATU != M->VO1_PROVEI+M->VO1_LOJPRO
		If !MsgYesNo(STR0133,STR0116) // O Proprietário deste novo Chassi está diferente do Proprietário do Chassi informado inicialmente nesta OS? Continuar? / Atenção
			Return .f.
		Endif
	Endif
Endif

If FindFunction("OFA1100016_PesquisaCampanha") .And. VOU->(FieldPos("VOU_SERINT")) > 0
	OFA1100016_PesquisaCampanha(VV1->VV1_CHASSI)
EndIf

M->VO1_CHASSI := VV1->VV1_CHASSI
M->VO1_CHAINT := VV1->VV1_CHAINT
M->VO1_PLAVEI := VV1->VV1_PLAVEI
M->VO1_CODFRO := VV1->VV1_CODFRO

VXA010GVO5(VV1->VV1_CHAINT,3)
If ExistBlock("VA010DPGR")
	ExecBlock("VA010DPGR",.f.,.f.,{VV1->VV1_CHAINT,nOpcE,VO5->(RecNo())})
EndIf

if !FG_SEEK("VO5","VV1->VV1_CHAINT",1,.f.)

	aStructVO5 := FWSX3Util():GetListFieldsStruct("VO5", .T.)

	For nX := 1 To Len(aStructVO5)

		cCampo := AllTrim(aStructVO5[nX][1])

		If X3USO(GetSX3Cache(cCampo, "X3_USADO")) .And. ;
		   cNivel >= GetSX3Cache(cCampo, "X3_NIVEL")

			AAdd(aCampoVO5, cCampo)

		EndIf

	Next nX



	cCadastro := OemToAnsi(STR0004) //"Abertura de OS - Manual"

	dbSelectArea("VO5")
	If AxInclui("VO5",0,3,aCampoVO5) != 1

		dbSelectArea("VO1")
		cCadastro := OemToAnsi(STR0004) //"Abertura de OS - Manual"

		Return(.f.)

	EndIf

	cCadastro := OemToAnsi(STR0004) //"Abertura de OS - Manual"

endif

dbSelectArea("VO1")

if FG_SEEK("VO5","VV1->VV1_CHAINT",1,.f.)

	//FG_SEEK("VE1","VV1->VV1_CODMAR",1,.f.)
	FG_SEEK("VV2","VV1->VV1_CODMAR+VV1->VV1_MODVEI",1,.f.)
	FG_SEEK("VVC","VV1->VV1_CODMAR+VV1->VV1_CORVEI",1,.f.)
	FG_SEEK("SA1","VV1->VV1_PROATU+VV1->VV1_LJPATU",1,.f.)
	If lA1_IBGE
		FG_Seek("VAM","SA1->A1_IBGE",1,.f.) // CIDADE
	EndIf

	DbSelectArea("VE1")
	DbSetOrder(1)
	DbSeek(xFilial("VE1") + VV1->VV1_CODMAR)

	M->VO1_DESMAR := VE1->VE1_DESMAR
	M->VO1_DESMOD := VV2->VV2_DESMOD
	M->VO1_CHASSI := VV1->VV1_CHASSI
	M->VO1_CODFRO := VV1->VV1_CODFRO
	M->VO1_PLAVEI := VV1->VV1_PLAVEI
	M->VO1_FABMOD := VV1->VV1_FABMOD
	M->VO1_DESCOR := VVC->VVC_DESCRI
	M->VO1_PROVEI := SA1->A1_COD
	M->VO1_LOJPRO := SA1->A1_LOJA
	M->VO1_NOMPRO := SA1->A1_NOME
	M->VO1_NOMFAT := SA1->A1_NOME
	M->VO1_ENDPRO := SA1->A1_END
	M->VO1_CIDPRO := FS_VLCIDEST()[1]
	M->VO1_ESTPRO := FS_VLCIDEST()[2]
	M->VO1_FONPRO := SA1->A1_TEL
	M->VO1_CODMAR := VE1->VE1_CODMAR

else
	M->VO1_DESMAR := ""
	M->VO1_DESMOD := ""
	M->VO1_CHASSI := ""
	M->VO1_CODFRO := ""
	M->VO1_PLAVEI := ""
	M->VO1_FABMOD := ""
	M->VO1_DESCOR := ""
	M->VO1_PROVEI := ""
	M->VO1_NOMPRO := ""
	M->VO1_ENDPRO := ""
	M->VO1_CIDPRO := ""
	M->VO1_ESTPRO := ""
	M->VO1_FONPRO := ""
	M->VO1_LOJPRO := ""

	return(.f.)

endif

OM0100044_BuscaSegmento() // Segmento de Venda em relacao ao Modelo ou Grupo do Modelo do Veiculo/Maquina

If Empty(cSelect)
	cSelect := "VO1"
EndIf
dbSelectArea(cSelect)

M->VO1_GETKEY := VV1->VV1_CHASSI
M->VO1_NUMAGE := OM0100062_buscaAgendamentos(M->VO1_CHASSI, M->VO1_DATABE, M->VO1_HORABE)

Return(.T.)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡Æo    ³ FS_LimCre³ Autor ³  Emilton              ³ Data ³ 26/08/99 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡Æo ³ Pesquisa Limite de Credito do Cliente                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ OFIM010.PRW                                                ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function FS_LIMCRE(cCodCli,cCodLoj,nMoeda)
local lRet := .t.

if !FindFunction('FGX_ChkCredCond') .or. FGX_ChkCredCond(M->VO1_FORPAG)
	//if FG_LIMCRE(cCodCli,cCodLoj) < 1
	If "A" $ GetMv("MV_CHKCRE")

		if !FGX_AVALCRED(cCodCli,cCodLoj,nLimCre,.t.,,,IIF(lMultMoeda,Max(nMoeda,1),nil))

			Help("  ",1,"LIMITECRED",,OemToAnsi(STR0018+" "+cCodCli+"-"+cCodLoj),4,1)

			lRet := .f.			

		endif

	EndIf
Endif

return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡Æo    ³ FS_UltKil³ Autor ³  Emilton              ³ Data ³ 20/09/99 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡Æo ³ Pesquisa Ultima Kilometragem e Ve Plano de Revisao         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ OFIM010.PRW                                                ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function FS_ULTKIL(cChaInt)
Return FS_VKILHOR( M->VO1_KILOME , NIL )


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡Æo    ³ FS_UltHor³ Autor ³  Luis Delorme         ³ Data ³ 10/09/12 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡Æo ³ Pesquisa Ultima Hora de Trilha do Veículo/Equipamento      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ OFIM010.PRW                                                ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function FS_ULTHOR(cChaInt)
Return FS_VKILHOR(M->VO1_KILOME , M->VO1_HORTRI)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ FS_VKILHOR ºAutor  ³ Rubens Takahashi   º Data ³ 21/08/15  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Validacao de KM/Hora                                      º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function FS_VKILHOR(nKilome, nHorTri)
local lVO1DATATE := ( VO1->(FieldPos("VO1_DATATE")) <> 0 )

If lVO1DATATE .and. !Empty(M->VO1_DATATE) .and. M->VO1_HORATE == 0
	MsgStop(STR0134) // "Informar a hora de execução"
	Return .f.
EndIf

If !FG_VKILHOR( M->VO1_CHAINT ,;
				IIf( lVO1DATATE .and. !Empty(M->VO1_DATATE) , M->VO1_DATATE , M->VO1_DATABE ),;
				IIf( lVO1DATATE .and. !Empty(M->VO1_HORATE) , M->VO1_HORATE , M->VO1_HORABE ),;
				nKilome ,;
				nHorTri ,;
				"ABE",;
				IIf( INCLUI , NIL , M->VO1_NUMOSV ))
	Return .f.
EndIf

Return .t.

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡Æo    ³ FS_SitCli³ Autor ³  Emilton              ³ Data ³ 30/08/99 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡Æo ³ Pesquisa Situacao e Idade do Cliente                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ OFIM010.PRW                                                ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
FUNCTION FS_SITCLI()

if SA1->A1_RISCO $ "E"
	MSGSTOP(STR0006)  //"Venda NAO autorizada ! Consulte o Depto Financeiro !"
	return .f.
endif

if dDataBase > SA1->A1_VENCLC
	MSGSTOP(STR0007)  //"Data de Validade do Limite de Credito Vencida ! Consulte o Depto Financeiro !"
	return .f.
endif

*** Bloqueia Venda para Menores de 21 Anos ***********************************

If !empty(SA1->A1_DTNASC)

	If SA1->A1_PESSOA == "F"

		Do Case
			Case year(dDataBase) - year(SA1->A1_DTNASC) == 21

				If month(dDataBase) < month(SA1->A1_DTNASC)

					MSGSTOP(STR0008)  // "Impossivel emitir NF p/ cliente com idade inferior a 21 anos !"
					return(.f.)

				Endif

				If month(dDataBase) < month(SA1->A1_DTNASC)

					If day(dDataBase) < day(SA1->A1_DTNASC)
						MSGSTOP(STR0008)  //"Impossivel emitir NF p/ cliente com idade inferior a 21 anos !"
						return(.f.)
					Endif

				Endif

			Case year(dDataBase) - year(SA1->A1_DTNASC) < 21

				MSGSTOP(STR0008)  //"Impossivel emitir NF p/ cliente com idade inferior a 21 anos !"
				return(.f.)

		Endcase

	Endif

Endif

Return(.t.)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡Æo    ³ FS_OFI010³ Autor ³  Emilton              ³ Data ³ 20/09/99 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡Æo ³ Verifica utilização do box e retorna mensagem de box em uso³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ OFIM010.PRW                                                ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function FS_OFI010()

Local lRet := .t.

If FG_SEEK("VOF","M->VO1_NUMBOX",1,.f.) ==.t.
	If VOF->VOF_SITBOX # "D"
		MsgInfo(STR0030,STR0029) // A box já está a ser utilizada... / Atenção!
		lRet := .f.
	Endif
Endif

Return(lRet)


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³FS_CHAMRSRºAutor  ³Fabio               º Data ³  09/05/03   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Chama requisicao de servico                                 º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP5                                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function FS_CHAMRSRV()

Local aRotOld := aClone(aRotina)
Local nOpcBkp := nOpc
////
//Private cTpTpoPEVM := space(4) // Tipo de Tempo Pecas
//Private cProdPEVM  := space(6) // Tipo de Tempo Servico
////
//aRotina := { { STR0002 ,"axPesqui", 0 , 1},;   // Pesquisar
//{ STR0004 ,"OM030"    , 0 , 3},;   // Requisitar
//{ STR0005 ,"OM030A"    , 0 , 3}}    // Alterar
//
//DbSelectArea("VO1")
//OM030(Alias(),Recno(),3)

SetFunName("OFIOM030")
nOpc := 2
dbSelectArea("VO1")
OFIOM030(,.t.)
SetFunName("OFIOM010")
nOpc := nOpcBkp

aRotina := aClone(aRotOld)

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³FS_ALINVEIº Autor ³ Andre Luis Almeida º Data ³  23/03/04   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Na abertura de OS. ALTERA / INCLUI veiculos                º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ MIL                                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function FS_ALINVEI(cTipo)

Local aStructVV1 := {}
Local nX
Local cCampo
Local wVar


Private cCadastro := OemToAnsi(STR0050+" - "+If(cTipo=="I",STR0052,If(cTipo=="A",STR0003,""))) //Cadastro de Veiculos # Incluir # Alterar
Private aMemos:={{"VV1_OBSMEM","VV1_OBSERV"}}
Private aCampos := {}
Private aRotina := {{ STR0001     , 0 , 1},;                // Pesquisar
{ STR0051    , "Vei010V" , 0 , 2 },;   // Visualizar
{ STR0052    , "Vei010I" , 0 , 3 },;   // Incluir
{ STR0003    , "Vei010A" , 0 , 4 }}	// Alterar
Private aCampoVV1 := {}

aCampoVV1 := {}

// Recupera estrutura da VV1 via cache
aStructVV1 := FWSX3Util():GetListFieldsStruct("VV1", .T.)

For nX := 1 To Len(aStructVV1)

	cCampo := AllTrim(aStructVV1[nX][1])

	// Aplica regras originais
	If X3USO(GetSX3Cache(cCampo, "X3_USADO")) .And. ;
	   cNivel >= GetSX3Cache(cCampo, "X3_NIVEL") .And. ;
	   !( cCampo $ "VV1_NUMTRA/VV1_TRACPA" )

		AAdd(aCampoVV1, cCampo)

		// Criação das variáveis de memória (M->)
		wVar := "M->" + cCampo

		If cCampo <> "VV1_CHAINT"
			&(wVar) := CriaVar(cCampo)
		Else
			&(wVar) := Space( GetSX3Cache("VV1_CHAINT", "X3_TAMANHO") )
		EndIf

	EndIf

Next nX


If cTipo == "I"
	If MsgYesNo(STR0053,STR0029) //Veiculo nao encontrado! Deseja cadastrar o veiculo? # Atenção!
		AxInclui("VV1",0,3,aCampoVV1,,,)
	EndIf
ElseIf cTipo == "A"
	If MsgYesNo(STR0054,STR0029) // Deseja alterar o registo do veículo? / Atenção!
		AxAltera("VV1",VV1->(RecNo()),4,aCampoVV1,,,,)
	EndIf
EndIf
If FindFunction("FM_VEIGAR")
	FM_VEIGAR() // Verifica se o Veiculo esta em garantia - 04/05/2009 - Andre Luis Almeida
EndIf
Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³FS_VALOBS ºAutor  ³Fabio               º Data ³  04/04/05   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Valida observacao da OS                                     º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function FS_VALOBS()

If VE4->VE4_TRAOSV == "1"

	If Substr( cObsOS , 1, Len(cObsOS) ) # Substr( M->VO1_OBSERV , 1, Len(cObsOS) )

		MsgStop(STR0031)

		Return(.f.)

	EndIf

	If !Empty(M->VO1_OBSERV) .And. Substr( M->VO1_OBSERV , (Len(M->VO1_OBSERV)-50) , 48 ) # Repl("_",48)
		M->VO1_OBSERV += Chr(13)+Chr(10)+Repl("_",nTamObs)+Chr(13)+Chr(10)
	EndIf

EndIf

Return(.t.)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³FS_CONSOS ºAutor  ³Fabio               º Data ³  04/04/05   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Chamada da consulta da OS                                   º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function FS_CONSOS()

DbSelectArea("VO1")
RetIndex()
Set Filter To

//	OFIOC060()
OC060("VO1",VO1->(RECNO()),2)

DbSelectArea("VO1")


Return .t.
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³FS_VLCIDE ºAutor  ³Fabio               º Data ³  04/04/05   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Analisa uso do VAM para adicionar no verot aRet             º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function FS_VLCIDEST()

Local lVAMCid  := If(SA1->(FieldPos("A1_IBGE"))>0,.t.,.f.)
Local aRet := {}

if lVAMCid
	FG_SEEK("VAM","SA1->A1_IBGE",1,.f.)
	aadd(aRet,VAM->VAM_DESCID)
	aadd(aRet,VAM->VAM_ESTADO)
Else
	aadd(aRet,SA1->A1_MUN)
	aadd(aRet,SA1->A1_EST)
Endif

Return(aRet)

/*
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³OM010LEG   ³ Autor ³ Fabio                ³ Data ³ 16/02/06 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Cria uma janela contendo a legenda da mBrowse              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ofiom010                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function OM010LEG()

Local aLegenda  := {{ 'BR_VERDE'   , STR0079   } ,;  // Aberta
					{ 'BR_AZUL'    , STR0092   } ,;  // Liberada
					{ 'BR_VERMELHO', STR0093   } ,;  // Fechado
					{ 'BR_PRETO'   , STR0094 } }     // Cancelado

BrwLegenda(cCadastro,STR0055 ,aLegenda)  //Legenda

Return .T.


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ MenuDef  ³ Autor ³  Emilton              ³ Data ³ 19/08/99 ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function MenuDef()






















Return OM010002C_menudef()


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³FS_SELEAGEºAutor  ³Fabio               º Data ³  10/03/07   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Seleciona agendamento                                       º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function FS_SELEAGE(cChassi,cCodFro,cPlaVei,cChaInt)

// Rubens 08/05/2013
// Mantive a funcao pois é chamada de outros fontes ...

Return



/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³FS_PECSRV    Autor  ³Fabio             º Data ³  09/20/01   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Verifica se existe Requisicoes de Pecas e/ou Apontamentos deº±±
±±º          ³Servicos.						                              º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Oficina                                                    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function FS_PECSRV() // Verifica se existe Requisicoes de Pecas e/ou Apontamentos de Servicos //
Local lRet    := .t.
Local cAliasVO3 := "SQLVO3"
Local cAliasVO4 := "SQLVO4"
Local cAliasVMB := "SQLVMB"
Local cAliasVG8 := "SQLVG8"
Local cAliasVGA := "SQLVGA"

DbSelectArea("VO2")
DbSetOrder(1)
If DbSeek(xFilial("VO2")+VO1->VO1_NUMOSV)
	lRet := .t. // Possui requisicoes de Pecas e/ou Apontamento de Servicos
EndIf

If GetNewPar("MV_MIL0023","N") == "S" //Permite alterar Chassi OS com Requisição antes da Liberação? (S ou N)

	lRet := .t.

	cQuery := "SELECT VO3.VO3_NUMOSV "
	cQuery += "FROM "
	cQuery += RetSqlName( "VO3" ) + " VO3 "
	cQuery += "WHERE VO3.VO3_FILIAL='"+ xFilial("VO3")+ "' AND VO3.VO3_NUMOSV = '"+VO1->VO1_NUMOSV+"' AND (VO3.VO3_DATFEC <> ' ' OR VO3.VO3_DATDIS <> ' ') AND "
	cQuery += "VO3.D_E_L_E_T_=' '"

	dbUseArea( .T., "TOPCONN", TcGenQry(,,cQuery), cAliasVO3, .T., .T. )

	if !( cAliasVO3 )->( Eof() )

	   lRet := .f.

	Else

		cQuery := "SELECT VO4.VO4_NUMOSV "
		cQuery += "FROM "
		cQuery += RetSqlName( "VO4" ) + " VO4 "
		cQuery += "WHERE VO4.VO4_FILIAL='"+ xFilial("VO4")+ "' AND VO4.VO4_NUMOSV = '"+VO1->VO1_NUMOSV+"' AND (VO4.VO4_DATFEC <> ' ' OR VO4.VO4_DATDIS <> ' ') AND "
		cQuery += "VO4.D_E_L_E_T_=' '"

		dbUseArea( .T., "TOPCONN", TcGenQry(,,cQuery), cAliasVO4, .T., .T. )

		if !( cAliasVO4 )->( Eof() )

		   lRet := .f.

		Else

			Do Case

				Case cMVMIL0006 == "JD"

					cQuery := "SELECT VMB.VMB_NUMOSV "
					cQuery += "FROM "
					cQuery += RetSqlName( "VMB" ) + " VMB "
					cQuery += "WHERE VMB.VMB_FILIAL='"+ xFilial("VMB")+ "' AND VMB.VMB_NUMOSV = '"+VO1->VO1_NUMOSV+"' " // Nao deve verificar se o registro esta deletado

					dbUseArea( .T., "TOPCONN", TcGenQry(,,cQuery), cAliasVMB, .T., .T. )

					if !( cAliasVMB )->( Eof() )

						lRet := .f.

					Endif

					(cAliasVMB)->(dbCloseArea())

				Case cMVMIL0006 == "SCA"

					cQuery := "SELECT VG8.VG8_NUMOSV "
					cQuery += "FROM "
					cQuery += RetSqlName( "VG8" ) + " VG8 "
					cQuery += "WHERE VG8.VG8_FILIAL='"+ xFilial("VG8")+ "' AND VG8.VG8_NUMOSV = '"+VO1->VO1_NUMOSV+"' "
					cQuery += " AND VG8.D_E_L_E_T_=' ' "

					dbUseArea( .T., "TOPCONN", TcGenQry(,,cQuery), cAliasVG8, .T., .T. )

					if !( cAliasVG8 )->( Eof() )

						lRet := .f.

					Endif

					(cAliasVG8)->(dbCloseArea())


				Case cMVMIL0006 == "VW" .or. cMVMIL0006 == "MAN"

					cQuery := "SELECT VGA.VGA_NUMOSV "
					cQuery += "FROM "
					cQuery += RetSqlName( "VGA" ) + " VGA "
					cQuery += "WHERE VGA.VGA_FILIAL='"+ xFilial("VGA")+ "' AND VGA.VGA_NUMOSV = '"+VO1->VO1_NUMOSV+"' "
					cQuery += " AND VGA.D_E_L_E_T_=' ' "

					dbUseArea( .T., "TOPCONN", TcGenQry(,,cQuery), cAliasVGA, .T., .T. )

					if !( cAliasVGA )->( Eof() )

						lRet := .f.

					Endif

					(cAliasVGA)->(dbCloseArea())

			End Case

		Endif

		(cAliasVO4)->(dbCloseArea())

	Endif

	(cAliasVO3)->(dbCloseArea())

Endif

DbSelectArea("VO1")
Return(lRet)
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³FS_IMPFIC ºAutor  ³Fabio               º Data ³  09/21/07   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Imprime ficha                                              º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Function FS_IMPFICHA()

OFIOC330(M->VO1_CHAINT)

oFldOm010:nOption := 1

Return


/*
===============================================================================
###############################################################################
##+----------+------------+-------+-----------------------+------+----------+##
##|Fun‡„o    | OM010V     | Autor |  Thiago		          | Data | 05/01/12 |##
##+----------+------------+-------+-----------------------+------+----------+##
##|Descri‡„o | Pesquisa Avancada                                            |##
##+----------+--------------------------------------------------------------+##
###############################################################################
===============================================================================
*/
Function OM010V()
nOpc := 1
OFIOC450()
Return(.t.)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³OM010L	   Autor  ³Fabio             º Data ³  09/20/01   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Laudo na OS.												  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Oficina                                                    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function OM010L()
Local cObserv := space(300)
Local cAliasVO3 := "SQLVO3"
Local cAliasVO4 := "SQLVO4"
Local lAchou    := .f.
Local nOpca := 0

cQuery := "SELECT VO3.VO3_NUMOSV "
cQuery += "FROM "
cQuery += RetSqlName( "VO3" ) + " VO3 "
cQuery += " INNER JOIN "+RetSqlName("VOI")+" VOI ON VOI.VOI_FILIAL = '" + xFilial("VOI") + "' AND VOI.VOI_TIPTEM = VO3.VO3_TIPTEM AND VOI.D_E_L_E_T_ = ' ' "
cQuery += "WHERE "
cQuery += "VO3.VO3_FILIAL='"+ xFilial("VO3")+ "' AND VO3.VO3_NUMOSV = '"+VO1->VO1_NUMOSV+"' AND VOI.VOI_SITTPO = '2' AND "
cQuery += "VO3.D_E_L_E_T_=' '"

dbUseArea( .T., "TOPCONN", TcGenQry(,,cQuery), cAliasVO3, .T., .T. )

if !( cAliasVO3 )->( Eof() )
   lAchou := .t.
Endif
(cAliasVO3)->(dbCloseArea())

If !lAchou
	cQuery := "SELECT VO4.VO4_NUMOSV "
	cQuery += "FROM "
	cQuery += RetSqlName( "VO4" ) + " VO4 "
	cQuery += " INNER JOIN "+RetSqlName("VOI")+" VOI ON VOI.VOI_FILIAL = '" + xFilial("VOI") + "' AND VOI.VOI_TIPTEM = VO4.VO4_TIPTEM AND VOI.D_E_L_E_T_ = ' ' "
	cQuery += "WHERE "
	cQuery += "VO4.VO4_FILIAL='"+ xFilial("VO4")+ "' AND VO4.VO4_NUMOSV = '"+VO1->VO1_NUMOSV+"' AND VOI.VOI_SITTPO = '2' AND "
	cQuery += "VO4.D_E_L_E_T_=' '"

	dbUseArea( .T., "TOPCONN", TcGenQry(,,cQuery), cAliasVO4, .T., .T. )

	if !( cAliasVO4 )->( Eof() )
	   lAchou := .t.
	Endif
	(cAliasVO4)->(dbCloseArea())
EndIf
dbSelectArea("VO1")
if lAchou
	if Aviso(STR0116,STR0117,{STR0118,STR0119}) == 1 // Atenção / O que deseja fazer com o laudo / Digitar / Imprimir

		cObserv := MSMM(VO1->VO1_LAUMEM,TamSX3("VO1_OBSLAU")[1])
		cAuxObserv := cObserv

		DEFINE MSDIALOG oLaudo TITLE STR0120 From 7,08 to 26,88      of oMainWnd  // Laudo na O.S.
		@ 008,010 GET oMsg2 VAR cObserv OF oLaudo MEMO SIZE 300,110 PIXEL
		DEFINE SBUTTON FROM 125,250 TYPE 1 ACTION ( IIf( OM010VLDM(cObserv,cAuxObserv) , ( nOpca := 1, oLaudo:End() ) , ) ) ENABLE OF oLaudo
		DEFINE SBUTTON FROM 125,280 TYPE 2 ACTION ( nOpca := 2, oLaudo:End() ) ENABLE OF oLaudo
		ACTIVATE MSDIALOG oLaudo CENTER
		if nOpca == 1
 			cObserv += Chr(13)+Chr(10)+Chr(13)+Chr(10)+"*** "+left(Alltrim(UsrRetName(__CUSERID)),15)+" "+DtoC(dDataBase)+"-"+Transform(time(),"@R 99:99")+"h"+" ***"
			cObserv += Chr(13)+Chr(10)+Repl("_",74)+Chr(13)+Chr(10)
			MSMM(VO1->VO1_LAUMEM,TamSx3("VO1_OBSLAU")[1],,cObserv,1,,,"VO1","VO1_LAUMEM")
		Endif
	Else
	   FS_IMPRESSAO()
	Endif
Else
   MsgStop(STR0121) // Opção somente disponível para ordem de serviço com tipo de tempo de garantia
   Return(.f.)
Endif
Return(.t.)

/*
===============================================================================
###############################################################################
##+----------+------------+-------+-----------------------+------+----------+##
##|Funcao    | OM010VLDM  | Autor |  Rubens	 	          | Data | 01/03/13 |##
##+----------+------------+-------+-----------------------+------+----------+##
##|Descricao | Validacao do memo do laudo de os                             |##
##+----------+--------------------------------------------------------------+##
###############################################################################
===============================================================================
*/
Static Function OM010VLDM(cObserv,cAuxObserv)

If !Empty(cAuxObserv) .and. SubStr(cObserv,1,Len(cAuxObserv)) <> cAuxObserv
	MsgStop(STR0125)	// "Não é possível alterar o laudo anterior"
	Return .f.
EndIf

Return .t.

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³FS_IMPRESSAO  Autor  ³Thiago           º Data ³  05/02/13   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Impressao do Laudo na OS.									  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Oficina                                                    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function FS_IMPRESSAO()
Local cDesc1		:= STR0120 // Laudo na O.S.
Local cDesc2 		:= ""
Local cDesc3 		:= ""
Local cAlias		:= "VO1"

Private nLin := 1
Private aPag := 1
Private nIte := 1
Private aReturn := { STR0122, 1,STR0123, 2, 2, 2, "",1 }  //Zebrado ## Administracao
Private cTamanho:= "P"           	// P/M/G
Private Limite  := 80           	// 80/132/220
Private aOrdem  := {}           	// Ordem do Relatorio
Private cTitulo := STR0124      	// Impressão do laudo na O.S.
Private cNomProg:= "LAUDOOS"
Private cNomeRel:= "LAUDOOS"
Private nLastKey:= 0
cPergBlk := cPerg
cPerg := ""
cNomeRel := SetPrint(cAlias,cNomeRel,nil,@cTitulo,cDesc1,cDesc2,cDesc3,.f.,,.t.,cTamanho)

If nLastKey == 27
	Return
EndIf

SetDefault(aReturn,cAlias)

RptStatus( { |lEnd| FS_IMPREL(/*@lEnd,cNomeRel,cAlias*/) } , cTitulo )

If aReturn[5] == 1
	OurSpool( cNomeRel )
EndIf
cPerg := cPergBlk

Return(.t.)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³FS_IMPREL		Autor  ³Thiago           º Data ³  05/02/13   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Impressao do Laudo na OS.									  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Oficina                                                    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function FS_IMPREL()

cabec1 := ""
cabec2 := ""
nLin := 1
nCaracter:=15
M_PAG := 1
nLin := cabec(ctitulo,cabec1,cabec2,cNomProg,cTamanho,nCaracter) + 1
dbSelectArea("SYP")
dbSetOrder(1)
dbSeek(xFilial("SYP")+VO1->VO1_LAUMEM)
While !Eof() .and. xFilial("SYP") == SYP->YP_FILIAL .and. VO1->VO1_LAUMEM == SYP->YP_CHAVE

	nPos := AT("\13\10",SYP->YP_TEXTO)
	if nPos > 0
		nPos -= 1
	Else
		nPos := Len(SYP->YP_TEXTO)
	Endif

	cObs := alltrim(Substr(SYP->YP_TEXTO,1,nPos))
	If !Empty(cObs)
		@ nLin , 03 psay "- " + cObs
		nlin++
	EndIf
	SYP->(DbSkip())
Enddo
Return(.t.)


/*
===============================================================================
###############################################################################
##+----------+------------+-------+-----------------------+------+----------+##
##|Funcao    | OM010GMUT  | Autor |  Rubens	 	          | Data | 28/05/13 |##
##+----------+------------+-------+-----------------------+------+----------+##
##|Descricao | Parambox de valor estimado de garantia mutua                 |##
##+----------+--------------------------------------------------------------+##
###############################################################################
===============================================================================
*/
Function OM010GMUT()

Local aParamBox := {}
Local aRet      := {}

If M->VO1_GARMUT <> "1"
	MsgInfo(STR0126,STR0029) // "Informar que a OS é de garantia mutua" / Atenção!
	Return
EndIf


If Altera
	// Verifica se a OS ja possui registro de solicitação de garantia
	VDF->(dbSetOrder(2))
	If VDF->(dbSeek(xFilial("VDF") + M->VO1_NUMOSV))
		MsgInfo(STR0127,STR0029) // "OS já possui solicitação de garantia mutua" / Atenção!
		nValGarMut := 0
		Return
	EndIf
EndIf

aAdd(aParamBox,{1,RetTitle("VDF_VLREST"),nValGarMut,PesqPict("VDF","VDF_VLREST"),"Positivo()","","",0,.f.}) // Valor Estimado
If ParamBox(aParamBox,STR0128,@aRet,,,,,,,,.F.,.F.) // "Garantia Mutua"
	nValGarMut := aRet[1]
EndIf

Return


/*
===============================================================================
###############################################################################
##+----------+------------+-------+-----------------------+------+----------+##
##|Funcao    | OM010WS    | Autor |  Rubens	 	          | Data | 08/07/13 |##
##+----------+------------+-------+-----------------------+------+----------+##
##|Descricao | Consulta Web Service de Montadora                            |##
##+----------+--------------------------------------------------------------+##
###############################################################################
===============================================================================
*/
Static Function OM010WS(nAuxOpc,cMarca)

Local nAuxRecno
Local cAuxAlias := Alias()

If Empty(M->VO1_CHASSI)
	MsgInfo(STR0129) // "Favor informar um Chassi"
	Return
EndIf

Do Case
Case cMVMIL0006 == "JD"
	If M->VO1_CODMAR <> FMX_RETMAR("JD") .and. M->VO1_CODMAR <> FMX_RETMAR("GRS") .and. M->VO1_CODMAR <> FMX_RETMAR("PLA") .and. M->VO1_CODMAR <> FMX_RETMAR("JDC") .and. M->VO1_CODMAR <> FMX_RETMAR("HCM")
		MsgInfo(STR0130,STR0029) // "Número de série não é da John Deere" / Atenção!
		Return
	EndIf

	nAuxRecno := VV1->(Recno())
	aRetWS := {}

	VV1->(DbSetOrder(2))
	VV1->(dbSeek( xFilial("VV1") + M->VO1_CHASSI ))
	dbSelectArea("VO1")
	OFICJD01(.t.,nAuxOpc,@aRetWS)

Case cMVMIL0006 == "SCA"

	If M->VO1_CODMAR <> FMX_RETMAR("SCA")
		MsgInfo(STR0096,STR0029) // "Chassi não é da marca Scania." / Atenção!
		Return
	EndIf

	nAuxRecno := VV1->(Recno())
	VV1->(DbSetOrder(2))
	VV1->(dbSeek( xFilial("VV1") + M->VO1_CHASSI ))
	dbSelectArea("VO1")
	OFICSC01(.t.,nAuxOpc,,.f.)
End
If Empty(cAuxAlias)
	cAuxAlias := "VO1"
Endif
dbSelectArea(cAuxAlias)

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ OM010IMPGAR ºAutor  ³ Rubens Takahashiº Data ³  08/07/2013 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Importa para garantia                                       º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³Oficina                                                     º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function OM010IMPGAR()

Local cFunExp := ""
Local ix1
Local nAuxRecno := OM010VE4RECNO(VO1->VO1_CODMAR)

If nAuxRecno == 0
	Return .t.
EndIf
VE4->(dbGoTo(nAuxRecno))

If FG_SEEK("VEG","VE4->VE4_FOREXP",1,.f.)
	//
	cFunExp := Alltrim(VEG->VEG_FORMUL)
	//

	ix1 := At("(",cFunExp)
	If ix1 <> 0
		cFunExp := Left(cFunExp,ix1) + "'A','','','',aRetWS)"
	EndIf
	// Funcao de Importacao para Garantia
	lMsHelpAuto := .f.
	If !FG_VERFORGAR(cFunExp)
		lMsHelpAuto := .t.
		Return .f.
	EndIf
	//
EndIf

Return .t.

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³OM010FEC  ºAutor  ³Thiago              º Data ³  18/11/13   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Chamada do fechamemto.             	                      º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function OM010FEC()
Private nOpc := 2
Private cGetVersao := GetVersao(.f.) // "P10" ou "11"

If cGetVersao == "P10"
	OFIOM160(.f.)
Else
	OFIXA100(.T.)
Endif
Return(.t.)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ATUKMJD   ºAutor  ³Carla               º Data ³  09/04/14   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Chamada na Alteracao da O.S.       	                      º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function FS_ATUKMJD()

Local cSql      := ""
Local nRecnoVMB := 0

If TCCanOpen( RetSqlName( "VMB" ) )//Cabecalho Garantia JD.

   cSql := " SELECT VMB.R_E_C_N_O_ "
   cSql += " FROM " + RetSqlName("VMB") + " VMB "
   cSql += " WHERE VMB_FILIAL = '" + xFilial("VMB") + "' AND "
   cSql += "       VMB_NUMOSV = '" + VO1->VO1_NUMOSV + "' AND "
   cSql += "       VMB_STATUS IN ( '  ', '01' ) AND " // Nao enviada
   cSql += "       D_E_L_E_T_ = ' ' "

   nRecnoVMB := FM_SQL( cSql )

   If ( nRecnoVMB ) > 0

	  VMB->( DbGoto( nRecnoVMB ) )
	  Reclock("VMB")
	  VMB->VMB_QTDUTI := M->VO1_KILOME
	  MsUnlock()

   Endif

EndIf

Return .t.

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³OM010BCO  ºAutor  ³ Andre Luis Almeida º Data ³  02/10/15   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Banco de Conhecimento da OS       	                      º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function OM010BCO()
If !Empty(VO1->VO1_NUMOSV)
	cAlias := "VO1"
	nOpc := aScan( aRotina , { |x| x[2] == "OM010BCO" } )
	nReg := VO1->(RecNo())
	FGX_MSDOC(cAlias,nReg,nOpc)
EndIf
Return()


/*/{Protheus.doc} OM010TPATEN
Validação da associação de Tipo de Atendimento ao Tipo de Tempo
@author Fernando V. Cavani
@since 26/01/2018
@version undefined
@type function
/*/
Function OM010TPATEN(cTipAte,cNumOSv,lMsg)
Local aTipTem 	 := {}
Local oSqlHelper := Dms_SqlHelper():New()
Local oArrHlp 	 := DMS_ArrayHelper():New()
Local lConsidera := .f.

Default cTipAte := ""
Default cNumOSv := ""
Default lMsg 	:= .t.

If VOI->(FieldPos("VOI_CONVCP")) > 0 .And. !Empty(cNumOSv)
	// Peças e Serviços
	cQuery := "SELECT VO3.VO3_TIPTEM "
	cQuery += "FROM " + RetSQLName("VO3") + " VO3 "
	cQuery += " JOIN " + RetSQLName("VOI") + " VOI ON VOI.VOI_FILIAL = '" + xFilial("VOI") + "' AND VOI.VOI_TIPTEM = VO3.VO3_TIPTEM AND VOI.VOI_CONVCP = '1' AND VOI.D_E_L_E_T_ = ' ' "
	cQuery += "WHERE VO3.VO3_FILIAL = '" + xFilial("VO3") + "' "
	cQuery +=   "AND VO3.VO3_DATCAN = ' ' "
	cQuery +=   "AND VO3.VO3_NUMOSV = '" + cNumOSv + "' "
	cQuery +=   "AND VO3.D_E_L_E_T_ = ' ' "
	cQuery += " UNION "
	cQuery += "SELECT VO4.VO4_TIPTEM "
	cQuery += "FROM " + RetSQLName("VO4") + " VO4 "
	cQuery += " JOIN " + RetSQLName("VOI") + " VOI ON VOI.VOI_FILIAL = '" + xFilial("VOI") + "' AND VOI.VOI_TIPTEM = VO4.VO4_TIPTEM AND VOI.VOI_CONVCP = '1' AND VOI.D_E_L_E_T_ = ' ' "
	cQuery += "WHERE VO4.VO4_FILIAL = '" + xFilial("VO4") + "' "
	cQuery +=   "AND VO4.VO4_DATCAN = ' ' "
	cQuery +=   "AND VO4.VO4_NUMOSV = '" + cNumOSv + "' "
	cQuery +=   "AND VO4.D_E_L_E_T_ = ' ' "

	aTipTem := oSqlHelper:GetSelectArray(cQuery)

	If !Empty(aTipTem)
		lConsidera := .t.
	EndIf
EndIf

If !lConsidera
	Return(.t.)
EndIf

cQuery := "SELECT COUNT(VCP.R_E_C_N_O_) "
cQuery += "FROM " + RetSqlName("VCP") + " VCP "
cQuery += "WHERE VCP.VCP_FILIAL = '" + xFilial("VCP") + "' "
cQuery +=   "AND VCP.VCP_TPATEN = '" + cTipAte + "' "
cQuery +=   "AND VCP.VCP_TIPTEM IN ('" + oArrHlp:Join(aTipTem, "','") + "') "
cQuery +=   "AND VCP.D_E_L_E_T_ = ' ' "

nRecVCP := FM_SQL(cQuery)

If nRecVCP == 0
	If lMsg
		Help(1,"  ","TPTEMATE",,STR0142,1,0,,,,,, {STR0143})	// Tipo de tempo incompatível com o atendimento			# Selecione outro tipo de atendimento/tempo
	EndIf

	Return(.f.)
EndIf
Return(.t.)


/*/{Protheus.doc} OM010VE4RECNO
Retorna o RECNO do Registro da Tabela VE4 que deverá ser utilizado na importacao da Garantia 
@author Rubens
@since 16/08/2018
@version 1.0
@return nAuxRecno, RECNO da VE4
@param cPesqCodMar, characters, descricao
@type function
/*/
Static Function OM010VE4RECNO(cPesqCodMar)

	Local cSQL
	Local nAuxRecno

	If cMVMIL0006 == "JD"
		cSQL := ;
			"SELECT VE4.R_E_C_N_O_" +;
			" FROM (" +;
					"SELECT VE1_1.VE1_CODMAR, '0' ORDEM " +;
					 " FROM " + RetSQLName("VE1") + " VE1_1 " +;
					" WHERE VE1_1.VE1_FILIAL = '" + xFilial("VE1") + "' " +;
					  " AND VE1_1.VE1_CODMAR = '" + cPesqCodMar + "' " +;
					  " AND VE1_1.VE1_MARFAB IN ('JD ','GRS','PLA','JDC','HCM') " +;
					  " AND VE1_1.D_E_L_E_T_ =  ' '  " +;
					" UNION " +;
					"SELECT VE1_2.VE1_CODMAR, '1' ORDEM " +;
					 " FROM " + RetSQLName("VE1") + " VE1_2 " +;
					" WHERE VE1_2.VE1_FILIAL = '" + xFilial("VE1") + "' " +;
					  " AND VE1_2.VE1_MARFAB IN ('JD ','GRS','PLA','JDC','HCM') " +;
					  " AND VE1_2.D_E_L_E_T_ =  ' '  " +;
					") " +;
			" TMPFILTRO JOIN " + RetSQLName("VE4") + " VE4 ON VE4.VE4_FILIAL = '" + xFilial("VE4") + "' " +;
																	  " AND VE4.VE4_PREFAB = TMPFILTRO.VE1_CODMAR " +;
																	  " AND VE4.VE4_QDOIMP = '3'" +;
																	  " AND VE4.VE4_FOREXP <> ' '" +;
																	  " AND VE4.D_E_L_E_T_ = ' '" +;
			" ORDER BY TMPFILTRO.ORDEM , VE4.R_E_C_N_O_"
	Else
		cSQL := ;
			"SELECT R_E_C_N_O_ " + ;
			 " FROM " + RetSQLName("VE4") + " VE4 " +;
			" WHERE VE4.VE4_FILIAL = '" + xFilial("VE4") + "'" +;
			  " AND VE4.VE4_PREFAB = '" + cPesqCodMar + "'" +;
			  " AND VE4.VE4_QDOIMP = '3'" +;
			  " AND VE4.D_E_L_E_T_ = ' '"
	EndIf

	nAuxRecno := FM_SQL(cSQL)

Return nAuxRecno



Function OM010VLDENC()
Local oSqlHlp := DMS_SqlHelper():New()
Local cQuery  := ''
Local lRet    := .t.

If ReadVar() == "M->VO1_HORABE"

	cQuery := "SELECT VO1_HORABE, VO1_CHASSI, VO1_DATABE, R_E_C_N_O_ FROM " + RetSQLName("VO1")
	cQuery += " WHERE "
	cQuery += " VO1_FILIAL = '" + xFilial("VO1") + "' AND"
	cQuery += " VO1_CHASSI = '"+M->VO1_CHASSI+"'  AND"
	cQuery += " VO1_DATABE = '"+Dtos(M->VO1_DATABE)+"' AND"
	cQuery += " D_E_L_E_T_ = ' '"
	cQuery += " ORDER BY VO1_DATABE, VO1_HORABE, R_E_C_N_O_ DESC"
	cQuery := oSqlHlp:TOPFunc(cQuery, 1)
	nRetHor := FM_SQL(cQuery)
	If M->VO1_HORABE == nRetHor
		Help("  ",1,"HORAINVALIDA",,CRLF+STR0138,4,1) // "Já existe Ordem de Serviço para esse Chassi com mesma Data e Hora de Abertura! Impossivel continuar!"
		lRet := .f.
	Endif

Endif

return lRet


Function OM010VO0()

	local oVO0_VEIA073
	local aFldVW0
	local aFldVO0
	local lRetMVCAuto
	local lFoundVO0
	local nRecVO1 := VO1->(Recno())
	local cMVVKILHOR := GetNewPar("MV_VKILHOR","NN")

	if cMVVKILHOR $ "NS/NN/SN"
		return .t.
	endIf                                  

	VO0->(dbSetOrder(2))
	lFoundVO0 := VO0->(dbSeek( xFilial("VO0") + VO1->VO1_FILIAL + VO1->VO1_NUMOSV))
	if lFoundVO0
		return .t.
	endif

	dbselectarea("VO0")
	
	aFldVW0 := {;
		{"VW0_CHASSI" , VO1->VO1_CHASSI , NIL },;
		{"VW0_ROTINA" , "OFIOM010" , NIL };
	}

	aFldVO0 := {;
		{"VO0_KILOME" , VO1->VO1_KILOME , NIL },;
		{"VO0_HORTRI" , VO1->VO1_HORTRI , NIL },;
		{"VO0_ORIGEM" , "2" , NIL },;
		{"VO0_FILOSV" , VO1->VO1_FILIAL , NIL },;
		{"VO0_NUMOSV" , VO1->VO1_NUMOSV , NIL },;
		{"VO0_DATA" , IIf( !Empty(M->VO1_DATATE) , VO1->VO1_DATATE , VO1->VO1_DATABE ) , nil },;
		{"VO0_HORA" , IIf( !Empty(M->VO1_HORATE) , VO1->VO1_HORATE , VO1->VO1_HORABE ) , nil } ;
	}

	// Cria um registro na tabela de LOG's de alteração de KM
	oVO0_VEIA073 := FWLoadModel("VEIA073")
	lRetMVCAuto := FwMvcRotAuto(oVO0_VEIA073,"VO0", iif( lFoundVO0 , 4 , 3 ) ,{ {"MODEL_VW0",aFldVW0}, {"MODEL_VO0",aFldVO0} },/*lSeek*/ .f. ,.f.)
	if ! lRetMVCAuto
		MostraErro()
	endif
	dbselectarea("VO0")
	VO0->(dbSetOrder(2))
	VO0->(dbSeek( xFilial("VO0") + VO1->VO1_FILIAL + VO1->VO1_NUMOSV))
	oVO0_VEIA073:DeActivate()
	//

	dbselectarea("VO1")
	VO1->(dbGoto(nRecVO1))

Return lRetMVCAuto

Function OM010INCON( nOpc , _cDescricao , _cEdit /*, lFlxPac*/ )

	Local nAuxPos, cSeqInc
	//Local aParamBox     := {}
	//
	_cDescricao := FwNoAccent(_cDescricao)

	If Empty(_cDescricao)
		Return .t.
	EndIf
	//
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Verifica se ja existe o inconveniente ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	if OM010IDUPL( 0, _cDescricao )
		FMX_HELP("OFIOM010",STR0154) // "Já existe esta Tarefa / Reclamação na OS"
		Return .f.
	endif

	cDesInc := space(TamSX3("VST_DESINC")[1])
	cSeqInc := Space(TamSX3("VST_SEQINC")[1])

	If !Empty(_cDescricao)
		cSeqInc := OX001SEQINC(_cDescricao)
	EndIf


	// Verifica se é a primeira linha da aCols
	lPrimeiraLinha := .f.
	nAuxPos := FG_POSVAR("VST_DESINC","aHeaderI")
	if Len(oGetInconv:aCols) == 1
		if empty(oGetInconv:aCols[1,nAuxPos])
			lPrimeiraLinha := .t.
		endif
	endif
	nAuxPos := 0
	If !Empty(_cDescricao)
		nAuxPos := aScan(oGetInconv:aCols, {|x| Alltrim(x[FG_POSVAR("VST_DESINC","aHeaderI")]) == Alltrim(_cDescricao) }) // Procurar se ja existe Inconveniente por Descricao
	EndIf
	If nAuxPos <= 0
		if !lPrimeiraLinha
			AADD(oGetInconv:aCols,Array(nUsadoI+1))
		endif
		nAuxPos := Len(oGetInconv:aCols)
		oGetInconv:aCols[nAuxPos,FG_POSVAR("VST_SEQINC","aHeaderI")] := M->VST_SEQINC := cSeqInc
		oGetInconv:aCols[nAuxPos,FG_POSVAR("VST_DESINC","aHeaderI")] := M->VST_DESINC := _cDescricao
	Else
		M->VST_SEQINC := cSeqInc     := oGetInconv:aCols[nAuxPos,FG_POSVAR("VST_SEQINC","aHeaderI")]
		M->VST_DESINC := _cDescricao := oGetInconv:aCols[nAuxPos,FG_POSVAR("VST_DESINC","aHeaderI")]
	EndIf

	oGetInconv:nAt := nAuxPos
	oGetInconv:aCols[nAuxPos,nUsadoI+1] := .f.
	oGetInconv:oBrowse:Refresh()

	oGetInconv:oBrowse:Refresh()
	oDesInc:SetFocus()

return .t.


/* =====================================================================
   Programa....: OFIOM010
   Função......: OM010DELI
   Descrição...: Realiza a exclusão lógica de Tarefas / Reclamações /
                 Solicitações do Cliente vinculadas à Ordem de Serviço.

   Regra de Negócio:
      - Permite restaurar tarefas excluídas, desde que não gere
        duplicidade.
      - Bloqueia a exclusão de tarefas já utilizadas em:
          * Requisição de Peças (VO3)
          * Requisição de Serviços (VO4)
          * Peças em espera para aplicação (VSJ)

   Observação..:
      A exclusão é realizada apenas em memória (grid). A persistência
      ocorre no momento da gravação da OS.

   ===================================================================== */
Function OM010DELI()


	//³Se tiver excluido, restaura registro³

	if oGetInconv:aCols[oGetInconv:nAt,Len(oGetInconv:aCols[oGetInconv:nAt])]

		//³Verifica se o inconveniente nao ficara duplicado³

		if OM010IDUPL(oGetInconv:nAt,;
			oGetInconv:aCols[oGetInconv:nAt,FG_POSVAR("VST_DESINC","aHeaderI")],;
			oGetInconv:aCols[oGetInconv:nAt,FG_POSVAR("VST_SEQINC","aHeaderI")])

			FMX_HELP("OFIOM010",STR0154) // "Já existe esta Tarefa / Reclamação informada na OS"
			Return .f.

		EndIf

		oGetInconv:aCols[oGetInconv:nAt,Len(oGetInconv:aCols[oGetInconv:nAt])] := .f.
		oGetInconv:Refresh()
		return .t.
	endif

	If OM0100025_RequisicaoTarefa(oGetInconv:aCols[oGetInconv:nAt,FG_POSVAR("VST_SEQINC","aHeaderI")])
		FMX_HELP("OFIOM010",STR0155) // "Há requisições efetuadas nesta Tarefa / Reclamação e assim impede a sua deleção!"
	Else
		oGetInconv:aCols[oGetInconv:nAt,Len(oGetInconv:aCols[oGetInconv:nAt])] := .t.
	EndIf
	oGetInconv:Refresh()

Return
/* =====================================================================
   Programa....: OFIOM010
   Função......: OM010IDUPL
   Descrição...: Valida a existência de duplicidade de Tarefas /
                 Reclamações / Solicitações no grid da Ordem de Serviço.

   Parâmetros..:
      nAuxLinha  -> Linha atual do grid
      cIDesInc   -> Descrição da tarefa / reclamação
      cISeqInc   -> Sequencial da tarefa (opcional)

   Retorno.....:
      .T. -> Existe duplicidade
      .F. -> Não existe duplicidade

   ===================================================================== */

Function OM010IDUPL(nAuxLinha, cIDesInc, cISeqInc)

Local nCntFor, lPesqSeq := .t.

if Type("cISeqInc") == "U"
	lPesqSeq := .f.
EndIf

for nCntFor := 1 to Len(oGetInconv:aCols)
	if !(oGetInconv:aCols[nCntFor,len(oGetInconv:aCols[nCntFor])]) .and. nCntFor <> nAuxLinha

		if oGetInconv:aCols[nCntFor,fg_posvar("VST_DESINC","aHeaderI")] == cIDesInc .and. ;
			( !lPesqSeq .or. ( lPesqSeq .and. oGetInconv:aCols[nCntFor,fg_posvar("VST_SEQINC","aHeaderI")] == cISeqInc ))

			Return .t.

		endif
	endif
next

Return .f.

/* =====================================================================
   Programa....: OFIOM010
   Função......: OM0100025_RequisicaoTarefa
   Descrição...: Verifica se a Tarefa / Reclamação / Solicitação vinculada
                 à Ordem de Serviço possui vínculo com outras rotinas
                 do sistema.

   Regra de Negócio:
      - Bloquear a exclusão de tarefas que já tenham sido utilizadas em:
          * Requisição de Peças (VO3)
          * Requisição de Serviços (VO4)
          * Peças em espera para aplicação (VSJ)

   Parâmetros..:
      cSequenInc -> Sequencial da tarefa (VST_SEQINC)

   Retorno.....:
      .T. -> Existem vínculos (exclusão bloqueada)
      .F. -> Não existem vínculos (exclusão permitida)
   ===================================================================== */
Function OM0100025_RequisicaoTarefa(cSequenInc)

	Local nContReg := 0

	cQuery := "SELECT COUNT(*) "
	cQuery += " FROM " + RetSqlName("VO3") + " VO3 "
	cQuery += " WHERE VO3.VO3_FILIAL = '" + xFilial("VO3") + "' "
	cQuery += 	" AND VO3.VO3_SEQINC = '" + cSequenInc + "' "
	cQuery += 	" AND VO3.VO3_NUMOSV = '" + VO1->VO1_NUMOSV + "' "
	cQuery += 	" AND VO3.D_E_L_E_T_ = ' '"
	
	nContReg += FM_SQL(cQuery)
	
	cQuery := "SELECT COUNT(*) "
	cQuery += " FROM " + RetSqlName("VO4") + " VO4 "
	cQuery += " WHERE VO4.VO4_FILIAL = '" + xFilial("VO4") + "' "
	cQuery += 	" AND VO4.VO4_SEQINC = '" + cSequenInc + "' "
	cQuery += 	" AND VO4.VO4_NUMOSV = '" + VO1->VO1_NUMOSV + "' "
	cQuery += 	" AND VO4.D_E_L_E_T_ = ' '"

	nContReg += FM_SQL(cQuery)

	cQuery := "SELECT COUNT(*) "
	cQuery += " FROM " + RetSqlName("VSJ") + " VSJ "
	cQuery += " WHERE VSJ.VSJ_FILIAL = '" + xFilial("VSJ") + "' "
	cQuery += 	" AND VSJ.VSJ_SEQINC = '" + cSequenInc + "' "
	cQuery += 	" AND VSJ.VSJ_NUMOSV = '" + VO1->VO1_NUMOSV + "' "
	cQuery += 	" AND VSJ.D_E_L_E_T_ = ' '"

	nContReg += FM_SQL(cQuery)

	If nContReg > 0
		Return .t.
	EndIf

Return .f.

/*/{Protheus.doc} OM010ALTVFB
Atualiza dados da VFB na alteração da Ordem de Serviço
@author Jose Silveira
@since 09/11/2021
@version 1.0
@param cCodCli, cCodLoj, cChaInt, cNumOsv, nKilome
@type function
/*/
Static Function OM010ALTVFB(cCodCli,cCodLoj,cChaInt,cNumOsv,nKilome)

Local cAliasVFB := "SQLVFB"

If !Empty(cNumOSv)
	cQuery := "SELECT VFB.R_E_C_N_O_ AS RECVFB "
	cQuery += "FROM "
	cQuery += RetSqlName( "VFB" ) + " VFB "
	cQuery += "WHERE "
	cQuery += "VFB.VFB_FILIAL='"+ xFilial("VFB")+ "' AND VFB.VFB_NUMOSV = '"+cNumOsv+"' AND "
	cQuery += "VFB.D_E_L_E_T_=' '"

	dbUseArea( .T., "TOPCONN", TcGenQry(,,cQuery), cAliasVFB, .T., .T. )

	Do While !( cAliasVFB )->( Eof() )

		dbSelectArea("VFB")
		VFB->(dbGoTo(( cAliasVFB )->RECVFB))

		RecLock("VFB",.F.)
		
		VFB->VFB_CHAINT := cChaInt
		VFB->VFB_CODCLI := cCodCli
		VFB->VFB_LOJA   := cCodLoj
		VFB->VFB_KILOME := nKilome

		VFB->(MsUnlock())

		( cAliasVFB )->(DbSkip())

	EndDo
	( cAliasVFB )->(dbCloseArea())
Endif

Return .t.

/*/{Protheus.doc} OM0100015_RetornaStatusOS
Atualiza dados da VFB na alteração da Ordem de Serviço
@author Jose Silveira
@since 09/11/2021
@version 1.0
@param cCodCli, cCodLoj, cChaInt, cNumOsv, nKilome
@type function
/*/

Function OM0100015_RetornaStatusOS(cNroOsv)

	Local cQuery := " "
	Local cStatus := " "
	
	Default cNroOsv := ""

	cQuery := " SELECT VO1.VO1_STATUS "
	cQuery += " FROM "
	cQuery += " 	" + retSqlName("VO1") + " VO1 "
	cQuery += " WHERE "
	cQuery += " 	VO1.VO1_FILIAL = '" + xFilial("VO1") + "' "
	cQuery += " 	AND VO1.VO1_NUMOSV = '" + cNroOsv + "' "
	cQuery += " 	AND VO1.D_E_L_E_T_ = ' ' "

	cStatus := FM_SQL(cQuery)

Return Alltrim(cStatus)

/*/{Protheus.doc} OM010002C_menudef
Rotina que retorna array aRotina do menudef
@type function
@version 1.0
@author cristiamRossi
@since 2/15/2024
@return array, aRotina
/*/
function OM010002C_menudef()
Local aRecebe := {}
Local aRotina := {	{ STR0001 ,"AxPesqui"			 , 0 , 1},;			// Pesquisar
					{ STR0002 ,"OM010I_I" 			 , 0 , 3},;			// Abrir OS
					{ STR0003 ,"OM010I_A" 			 , 0 , 4},;			// Alterar
					{ STR0073 ,"FS_CONSOS" 			 , 0 , 2},;			// Cons.OS
					{ STR0095 ,"Pergunte(cPerg,.t.)" , 0 , 3},;			// Cons.OS
					{ STR0055 ,"OM010LEG" 			 , 0 , 2,0,.f.},;	// Legenda
					{ STR0100 ,"OM010V"				 , 0 , 1},;
					{ STR0115 ,"OM010L"				 , 0 , 6} } 		// Laudo na O.S.

	aadd(aRotina,{STR0098,"OM010BCO",0,4}) // Banco de Conhecimento
	aadd(aRotina,{STR0141,"OM0100055_CheckList",0,4}) // Checklist

	If ExistBlock("OM010CODE") // Ponto de entrada para chamada da rotina controle de deslocamento.
		aadd(aRotina,{STR0114,"U_OM010CODE",0,4}) // Controle de Deslocamento
	Endif

	If cMVMIL0006 == "SCA" .AND. FindFunction("GM060PSW")
		aadd(aRotina,{ STR0036,"GM060PSW",0,2}) // "Alt. Senha - Claw"
	EndIf

	If ExistBlock("OM010AROT")
		aRecebe := ExecBlock("OM010AROT",.f.,.f.,{aRotina} )
		If ( ValType(aRecebe) == "A" )
			aRotina := aClone(aRecebe)
		EndIf
	Endif

return aRotina



/*/{Protheus.doc} OM010003D_Nome_PropVeiculo
Função para retornar o A1_NOME do Proprietário do veículo
Necessário que esteja posicionado na tabela VO1
@type function
@version 1.0
@author Francisco Carvalho
@since 05/06/2024
@return array, aRotina
/*/
Function OM010003D_Nome_PropVeiculo()
Local cRet := ""

SA1->(DbSetOrder(1))
If SA1->(DbSeek(xFilial("SA1")+VO1->VO1_PROVEI+VO1->VO1_LOJPRO ))
	cRet := SA1->A1_NOME
Endif

return cRet

/*/{Protheus.doc} OM0100044_BuscaSegmento
Carrega o Segmento de Venda em relacao ao Modelo ou Grupo do Modelo do Veiculo/Maquina

@type function
@version 1.0
@author Andre Luis Almeida
@since 06/06/2025
/*/
Function OM0100044_BuscaSegmento()
Local lCpoSegmto := ( VV2->(FieldPos("VV2_SEGMTO")) > 0 .and. VVR->(FieldPos("VVR_SEGMTO")) > 0 )
If !Empty(M->VO1_CHAINT) .and. lCpoSegmto
	VV1->(DbSetOrder(1))
	VV1->(msSeek(xFilial("VV1")+M->VO1_CHAINT))
	VV2->(DbSetOrder(1))
	VV2->(msSeek(xFilial("VV2")+VV1->VV1_CODMAR+VV1->VV1_MODVEI))
	If !Empty(VV2->VV2_SEGMTO)
		M->VO1_SEGMTO := VV2->VV2_SEGMTO
	Else
		VVR->(DbSetOrder(2))
		VVR->(msSeek(xFilial("VVR")+VV1->VV1_CODMAR+VV2->VV2_GRUMOD))
		If !Empty(VVR->VVR_SEGMTO)
			M->VO1_SEGMTO := VVR->VVR_SEGMTO
		EndIf
	EndIf
EndIf
return .t.


/*/{Protheus.doc} OM0100055_CheckList

@type function
@version 1.0
@author Renato Vinicius
@since 09/01/2024
@return array, aRotina
/*/
Function OM0100055_CheckList()

	VA37000012_OpenResponseChecklist(VO1->VO1_FILIAL+VO1->VO1_NUMOSV,'0002')

Return

/*/{Protheus.doc} OM0100062_buscaAgendamentos
Busca os agendamentos filtrados para tela de seleção

@type function
@version 1.0
@author Bruno Forcato
@since 18/02/2026
/*/
Function OM0100062_buscaAgendamentos(cChassi, cDataAberturaOS, nHoraAberturaOS, lAbreDialog)
	Local cQuery    := ""
	local cFixQuery := ""
	local oStatement := FWPreparedStatement():new()
	local cAliasVSO := GetNextAlias()
	Local aVSO     := {}
	local oOfScanicaConfig := OfScaniaConfig():New("DIAOFI", "OFIA551")
	local oConfig := oOfScanicaConfig:getConfigWithNoEnviroment()
	local lTemJson := (ValType(oConfig) == "J")
	local lIntervalo := (oConfig['OS_VALIDINTERAGE'] == '1')
	local nIntervaloHoras := oConfig['OS_INTERMIN']
	local nValidaAntes := oConfig['OS_VALIDANTAGEHORA']
	local nValidaApos := oConfig['OS_VALIDDEPAGEHORA']
	local nTsAge, nTsReg, nTsAbe, nDifAbe
	local cHoraAgendada, cHoraRegistrada, cHoraAberturaOS
	Local cNumAgeVincOS := ""

	Default lAbreDialog	:= .F.

	cHoraAberturaOS := StrZero(nHoraAberturaOS, 4)

	cQuery += " SELECT VSO.VSO_FILIAL, VSO.VSO_NUMIDE, VSO.VSO_DATAGE, VSO.VSO_DATREG, "
	cQuery += " 	VSO.VSO_GETKEY, VSO.VSO_NOMPRO, VSO.VSO_HORAGE, VSO.VSO_HORREG "
	cQuery += " FROM " + RetSQLName("VSO") + " VSO "
	cQuery += " WHERE VSO.VSO_FILIAL = ? "
	cQuery += " 	AND VSO.VSO_STATUS IN (1, 5) "
	cQuery += " 	AND VSO.VSO_GETKEY = ? "
	cQuery += "		AND VSO.VSO_AGCONF IN (1, 2) "
	cQuery += " 	AND VSO.D_E_L_E_T_ = ' ' "
	cQuery += "	ORDER BY VSO.VSO_NUMIDE "

	oStatement:setQuery(cQuery)
	oStatement:setString(1, FWxFilial("VSO"))
	oStatement:setString(2, cChassi)

	cFixQuery := oStatement:getFixQuery()
	dbUseArea(.T., "TOPCONN", TcGenQry(,, cFixQuery), cAliasVSO, .F., .T.)
	Do While !( cAliasVSO )->( Eof())
		cHoraAgendada := StrZero(Val(( cAliasVSO )->( VSO_HORAGE )), 4)
		cHoraRegistrada := StrZero(( cAliasVSO )->( VSO_HORREG ), 4)

		nTsAge := Val(FWTimeStamp(4, Stod(( cAliasVSO )->( VSO_DATAGE )), Transform(cHoraAgendada, "@R 99:99:00")))
		nTsReg := Val(FWTimeStamp(4, Stod(( cAliasVSO )->( VSO_DATREG )), Transform(cHoraRegistrada,"@R 99:99:00")))
		nTsAbe := Val(FWTimeStamp(4, (cDataAberturaOS), Transform(cHoraAberturaOS,"@R 99:99:00")))
		nDifAbe := (nTsAge - nTsAbe) / 3600

		if lTemJson .or. oConfig:HasProperty('OS_VINCABERTOS')

			if oConfig['OS_VINCABERTOS'] == '2'
				(cAliasVSO)->(dbCloseArea())
				return ""
			endif
		
			//Diferença entre a data (VSO_DATREG/VSO_HORREG) e a data (VSO_DATAGE/VSO_HORAGE) deve ser maior ou igual ao parâmetro "Intervalo mínimo permitido (em horas)"
			if lIntervalo .and. (Abs(nTsReg - nTsAge) / 3600) < nIntervaloHoras
				( cAliasVSO )->( DbSkip() )
				loop
			endif

			//Diferença entre a data (VSO_DATAGE/VSO_HORAGE) para a data da abertura da OS for menor ou igual a diferença de horas definida no nValidaAntes
			if nValidaAntes > 0 .and. nDifAbe < 0 .and. Abs(nDifAbe) > nValidaAntes
				( cAliasVSO )->( DbSkip() )
				loop
			endif

			//Diferença entre a data (VSO_DATAGE/VSO_HORAGE) para a data da abertura da OS for menor ou igual a diferença de horas definida no nValidaApos
			if nValidaApos > 0 .and. nDifAbe > 0 .and. nDifAbe > nValidaApos
				( cAliasVSO )->( DbSkip() )
				loop
			endif
		endif

		Aadd(aVSO,{	( cAliasVSO )->( VSO_NUMIDE ),;
		FWTimeStamp(2, Stod(( cAliasVSO )->( VSO_DATAGE )), Transform(( cAliasVSO )->( VSO_HORAGE ),"@R 99:99:00")),;
		( cAliasVSO )->( VSO_GETKEY ),;
		( cAliasVSO )->( VSO_NOMPRO )});

		( cAliasVSO )->( DbSkip() )
	EndDo
	(cAliasVSO)->(dbCloseArea())

	if len(aVSO) > 0
		If lAbreDialog
			cNumAgeVincOS := OM0100072_CriaDialogAgendamentos(aVSO)
		Else
			cNumAgeVincOS := aVSO[1][1] // Vincular o primeiro agendamento enquadrado nas regras para vinculo AUTOMÁTICO
		EndIf
	endif
return cNumAgeVincOS

/*/{Protheus.doc} OM0100072_CriaDialogAgendamentos
Cria a tela de seleção de agendamento

@type function
@version 1.0
@author Bruno Forcato
@since 18/02/2026
/*/
Function OM0100072_CriaDialogAgendamentos(aVSO)
    Local oDlg, oPan, oPanGrid
    Local lOk  := .F.
    Local nSel := 0
	Local cNumAgeSelec := ""
    Private aVSOBrw := AClone(aVSO)
    Private oBrw

    If Len(aVSOBrw) == 0
        Return ""
    EndIf

    oDlg := FWDialogModal():New()
    oDlg:SetTitle(STR0156) // "Agendamentos válidos para o veículo"
    oDlg:SetSize(300, 500)
    oDlg:SetCloseButton(.T.)
    oDlg:SetEscClose(.T.)
    oDlg:EnableFormBar(.T.)
    oDlg:CreateDialog()
    oDlg:CreateFormBar()

    oPan := oDlg:GetPanelMain()
	oPanGrid := TPanel():New( 0, 1, "", oPan, , , , , , 498, 250 )

    oBrw := FWBrowse():New()
	oBrw:DisableReport()
    oBrw:SetOwner(oPanGrid)
    oBrw:SetDataArray()
    oBrw:SetArray(aVSOBrw)
    oBrw:SetColumns(OM0100082_CriaArrayDeColunas())

    oBrw:SetDoubleClick({|| nSel := oBrw:nAt, lOk := .T., oDlg:DeActivate() })

    oDlg:AddButton(STR0157, {|| nSel := oBrw:nAt, lOk := .T., oDlg:DeActivate() }, STR0157) // "Confirmar"
    oDlg:AddButton(STR0158 , {|| oDlg:DeActivate() }, STR0158) // "Cancelar"
	oDlg:AddButton(STR0159 , {|| nSel := oBrw:nAt, OM0100112_VisualizarAgendamento(aVSOBrw[nSel,1]) }, STR0159) // "Visualizar Agendamento"

    oBrw:Activate()
    oDlg:Activate()
    oBrw:DeActivate()

    If lOk .and. nSel > 0
        cNumAgeSelec := aVSOBrw[nSel,1]
    EndIf

Return cNumAgeSelec

/*/{Protheus.doc} OM0100082_CriaArrayDeColunas
Cria o array de colunas do Browser

@type function
@version 1.0
@author Bruno Forcato
@since 18/02/2026
/*/
Static Function OM0100082_CriaArrayDeColunas()
    Local aCols := {}

	AAdd(aCols, OM0100092_CriaColuna(STR0161, 1, 15)) // "Número do agendamento"
    AAdd(aCols, OM0100092_CriaColuna(STR0162, 2, 15)) // "Data/Hora agendada"
    AAdd(aCols, OM0100092_CriaColuna(STR0163, 3, 15)) // "Placa/Chassi"
    AAdd(aCols, OM0100092_CriaColuna(STR0164, 4, 15)) // "Proprietário do veículo"
Return aCols

/*/{Protheus.doc} OM0100092_CriaColuna
Cria as colunas que serão mostradas

@type function
@version 1.0
@author Bruno Forcato
@since 18/02/2026
/*/
Static Function OM0100092_CriaColuna(cTitulo, nIdx, nTamanho)
    Local oCol := FWBrwColumn():New()

    oCol:SetTitle(cTitulo)
    oCol:SetType("C")
    oCol:SetSize(nTamanho)
    oCol:SetData(&("{|| aVSOBrw[oBrw:nAt," + AllTrim(Str(nIdx)) + "] }"))
Return oCol

/*/{Protheus.doc} OM0100102_VincularOSDoAgendamentoComOrcamento
Vincula a ordem de serviço com o orçamento do agendamento

@type function
@version 1.0
@author Bruno Forcato
@since 18/02/2026
/*/
Static Function OM0100102_VincularOSDoAgendamentoComOrcamento(cNumAge, cNumOS)
	Local cQuery    := ""
	local cFixQuery := ""
	local oStatement := FWPreparedStatement():new()
	local cAliasVS1 := GetNextAlias()

	dbselectarea("VSO")
	VSO->(dbSetOrder(1))
	VSO->(dbSeek( xFilial("VSO") +cNumAge))
	cQuery := "SELECT VS1.VS1_NUMAGE, VS1.VS1_NUMORC FROM "+RetSqlName("VS1")+" VS1 WHERE "
	cQuery += "VS1.VS1_FILIAL = ? AND VS1.VS1_NUMAGE = ? AND VS1.D_E_L_E_T_ = ' ' "

	oStatement:setQuery(cQuery)
	oStatement:setString(1, FWxFilial("VS1"))
	oStatement:setString(2, cNumAge)

	cFixQuery := oStatement:getFixQuery()
	dbUseArea( .T., "TOPCONN", TcGenQry( ,, cFixQuery ),cAliasVS1, .F., .T. )
	While !( cAliasVS1 )->( Eof() )
		DbSelectArea("VS1")
		VS1->(dbSetOrder(1))
		VS1->(dbSeek( xFilial("VS1") +(cAliasVS1)->( VS1_NUMORC )))

		RecLock("VS1",.f.)
		VS1->VS1_NUMOSV := cNumOS 
		MsUnLock()
		( cAliasVS1 )->( DbSkip() )
	EndDo

	( cAliasVS1 )->( dbCloseArea() )
Return

/*/{Protheus.doc} OM0100112_VisualizarAgendamento
Abre o agendamento para a visualização

@type function
@version 1.0
@author Bruno Forcato
@since 18/02/2026
/*/
Static Function OM0100112_VisualizarAgendamento(cNumAge)
	DbSelectArea("VSO")
	DbSetOrder(1)
	If dbSeek( xFilial("VSO") +cNumAge)
		OA602014M_EXECUTA("VSO", VSO->(RecNo()), 2, .F.) // Visualizar agendamento
	Endif
return

/*/{Protheus.doc} OM0100122_AbrirOSPeloAgendamento
Começa o processo de abertura de OS com base no agendamento

@type function
@version 1.0
@author Bruno Forcato
@since 20/02/2026
/*/
Function OM0100122_AbrirOSPeloAgendamento()
	VV1->(DbSelectArea("VV1"))
	VV1->(DbSetOrder(2))
	VV1->(DbSeek(xFilial("VV1")+VSO->VSO_GETKEY))

	VE1->(DbSelectArea("VE1"))
	VE1->(DbSetOrder(1))
	VE1->(DbSeek(xFilial("VE1")+VV1->VV1_CODMAR))

	VV2->(DbSelectArea("VV2"))
	VV2->(DbSetOrder(1))
	VV2->(DbSeek(xFilial("VV2")+VV1->VV1_CODMAR+VV1->VV1_MODVEI))

	SA1->(DbSelectArea("SA1"))
	SA1->(DbSetOrder(1))
	SA1->(DbSeek(xFilial("SA1")+VV1->VV1_PROATU+VV1->VV1_LJPATU))

	VO5->(DbSelectArea("VO5"))
	VO5->(DbSetOrder(1))
	VO5->(DbSeek(xFilial("VO5")+VV1->VV1_CHAINT))

	VVC->(DbSelectArea("VVC"))
	VVC->(DbSetOrder(1))
	VVC->(DbSeek(xFilial("VVC")+VV1->VV1_CODMAR+VV1->VV1_CORVEI))

	M->VO1_CHASSI := VV1->VV1_CHASSI 
	M->VO1_GETKEY := VV1->VV1_CHASSI 
	M->VO1_PLAVEI := VV1->VV1_PLAVEI 
	M->VO1_CHAINT := VV1->VV1_CHAINT 
	M->VO1_CORVEI := VV1->VV1_CORVEI 
	M->VO1_FABMOD := VV1->VV1_FABMOD 
	M->VO1_DESMAR := VE1->VE1_DESMAR 
	M->VO1_DESMOD := VV2->VV2_DESMOD 
	M->VO1_PROVEI := SA1->A1_COD 		 
	M->VO1_LOJPRO := SA1->A1_LOJA 	 

	M->VO1_CODFRO := VV1->VV1_CODFRO 
	M->VO1_DESCOR := VVC->VVC_DESCRI 
	M->VO1_NOMPRO := SA1->A1_NOME		 
	M->VO1_ENDPRO := SA1->A1_END		 
	M->VO1_CIDPRO := SA1->A1_MUN		 
	M->VO1_ESTPRO := SA1->A1_EST		 
	M->VO1_FONPRO := SA1->A1_TEL		 
	M->VO1_CODMAR := VE1->VE1_CODMAR 
	M->VO1_NUMAGE := VSO->VSO_NUMIDE
	M->VO1_OBSERV :=  MSMM( VSO->VSO_OBSMEM, TamSX3("VO1_OBSERV")[1], , , 3, , , "VSO", "VSO_OBSMEM" )
	M->VO1_TPATEN  := VSO->VSO_TPATEN
	M->VO1_NUMBOX   := VSO->VSO_NUMBOX

	if lInconveniente
		OM0100132_VincularIncovenientesDoAgendamento()
	endif
Return

/*/{Protheus.doc} OM0100132_VincularIncovenientesDoAgendamento
Vincula os incovenientes do agendamento a OS

@type function
@version 1.0
@author Bruno Forcato
@since 23/02/2026
/*/
Static Function OM0100132_VincularIncovenientesDoAgendamento()
	Local cQuery    := ""
	local cFixQuery := ""
	local oStatement := FWPreparedStatement():new()
	local cAliasVST := GetNextAlias()

	Local nPosDes := 0
	Local nPosSeq := 0
	Local nPosCodMar := 0
	Local nPosGruInc := 0
	Local nPosCodInc := 0
	Local nAuxPos := 0
	Local lPrimeiraLinha := .F.

	Local cDesc := ""
	Local cSeq  := ""
	Local cMar  := ""
	Local cGru  := ""
	Local cCod  := ""

	cQuery := "SELECT VST.VST_DESINC, VST.VST_CODMAR, "
	cQuery += "	VST.VST_SEQINC, VST.VST_GRUINC, VST.VST_CODINC "
	cQuery += "FROM "+RetSqlName("VST")+" VST WHERE "
	cQuery += "	VST.VST_FILIAL = ? AND VST.VST_CODIGO = ? "
	cQuery += "	AND VST.VST_TIPO = 3 AND VST.D_E_L_E_T_ = ' '"

	oStatement:setQuery(cQuery)
	oStatement:setString(1, FWxFilial("VST"))
	oStatement:setString(2, VSO->VSO_NUMIDE)

	cFixQuery := oStatement:getFixQuery()
	dbUseArea( .T., "TOPCONN", TcGenQry( ,, cFixQuery ),cAliasVST, .F., .T. )

	nPosDes    := FG_POSVAR("VST_DESINC", "aHeaderI")
	nPosSeq    := FG_POSVAR("VST_SEQINC", "aHeaderI")
	nPosCodMar := FG_POSVAR("VST_CODMAR", "aHeaderI")
	nPosGruInc := FG_POSVAR("VST_GRUINC", "aHeaderI")
	nPosCodInc := FG_POSVAR("VST_CODINC", "aHeaderI")

	While !( cAliasVST )->( Eof() )
		cDesc := AllTrim((cAliasVST)->VST_DESINC)
		cSeq  := (cAliasVST)->VST_SEQINC
		cMar  := (cAliasVST)->VST_CODMAR
		cGru  := (cAliasVST)->VST_GRUINC
		cCod  := (cAliasVST)->VST_CODINC

		If Empty(cDesc)
			(cAliasVST)->(DbSkip())
			Loop
		EndIf

		lPrimeiraLinha := .F.
		If Len(oGetInconv:aCols) == 1 .and. nPosDes > 0
			If Empty(oGetInconv:aCols[1, nPosDes])
				lPrimeiraLinha := .T.
			EndIf
		EndIf

		nAuxPos := 0
		If nPosSeq > 0 .and. !Empty(cSeq)
			nAuxPos := aScan(oGetInconv:aCols, {|x| AllTrim(x[nPosSeq]) == AllTrim(cSeq) })
		EndIf

		If nAuxPos <= 0 .and. nPosDes > 0
			nAuxPos := aScan(oGetInconv:aCols, {|x| AllTrim(x[nPosDes]) == cDesc })
		EndIf

		If nAuxPos <= 0
			If !lPrimeiraLinha
				AAdd(oGetInconv:aCols, Array(nUsadoI+1))
			EndIf
			nAuxPos := Len(oGetInconv:aCols)
		EndIf

		If nPosSeq > 0
			oGetInconv:aCols[nAuxPos, nPosSeq] := cSeq
			M->VST_SEQINC := cSeq
		EndIf

		If nPosDes > 0
			oGetInconv:aCols[nAuxPos, nPosDes] := cDesc
			M->VST_DESINC := cDesc
		EndIf

		If nPosCodMar > 0
			oGetInconv:aCols[nAuxPos, nPosCodMar] := cMar
			M->VST_CODMAR := cMar
		EndIf

		If nPosGruInc > 0
			oGetInconv:aCols[nAuxPos, nPosGruInc] := cGru
			M->VST_GRUINC := cGru
		EndIf

		If nPosCodInc > 0
			oGetInconv:aCols[nAuxPos, nPosCodInc] := cCod
			M->VST_CODINC := cCod
		EndIf

		oGetInconv:aCols[nAuxPos, nUsadoI+1] := .F.
		(cAliasVST)->(DbSkip())
	EndDo

	If nAuxPos > 0
		oGetInconv:nAt := nAuxPos
	EndIf

	oGetInconv:oBrowse:Refresh()
	(cAliasVST)->(DbCloseArea())
Return
