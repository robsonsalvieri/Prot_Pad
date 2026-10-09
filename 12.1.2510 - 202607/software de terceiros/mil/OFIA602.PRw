#INCLUDE "PROTHEUS.CH"
#INCLUDE "COLORS.CH"
#INCLUDE "AP5MAIL.CH"
#Include 'FWMVCDef.ch'
#INCLUDE 'FWEDITPANEL.CH'
#Include 'FWBrowse.ch'
#Include "OFIA602.CH"

Static lAltInconv := findFunction("OX001066K_AlteraDescricaoInconveniente")

Function OFIA602(lAutomatic, lNoMBrowse)

	Private aRotOA602      := MenuDef()
	Private cCadastro      := STR0001 // Agendamento Oficina
	Private aMemos         := {{"VSO_OBSMEM","VSO_OBSERV"}}
	Private lDelPosAge     := .f.
	Private oResp
	Private lInconveniente := (GetNewPar("MV_INCORC","N") == "S")
	Private lInconvObr     := (GetNewPar("MV_INCOBR","N") == "S")
	Private cIncDefault    := Alltrim(GetNewPar("MV_MIL0094",""))
	Private dDataAtual     := dDataBase

	Default lAutomatic     := .f.
	Default lNoMBrowse     := .f.

	IF FindFunction("FGX_TimeUF")
		dDataAtual := FGX_TimeUF()[1]
	Endif

	If lNoMBrowse

		dbSelectArea("VSO")
		If ( nOpc <> 0 ) .And. !Deleted()
			bBlock := &( "{ |a,b,c,d,e| " + aRotOA602[ nOpc,2 ] + "(a,b,c,d,e) }" )
			Eval( bBlock, Alias(), (Alias())->(Recno()),nOpc)
		EndIf
	Else
		mBrowse( 6, 1,22,75,"VSO",,,,,,OM350L())
	Endif

Return

/*/{Protheus.doc} OA602010M_VISUALIZA
Visualiza o registro
@type function
@version
@author Jessé Augusto
@since 17/11/2025
@return variant, return_description
/*/
Function OA602010M_VISUALIZA()
	
	OA602014M_EXECUTA("VSO",VSO->(RecNo()),2,.f.)

Return

/*/{Protheus.doc} OA602011M_INCLUI
Acionar a rotina principal em modo inclusão
@type function
@version
@author Jessé Augusto
@since 11/17/2025
@return variant, return_description
/*/
Function OA602011M_INCLUI()
	
	OA602014M_EXECUTA("VSO",0,3,.f.)

Return

/*/{Protheus.doc} OA602012M_ALTERA
Acionar a rotina principal em modo alteração
@type function
@version
@author Jessé Augusto
@since 17/11/2025
@return variant, return_description
/*/
Function OA602012M_ALTERA()
	
	If !VSO->VSO_STATUS $ "1.5"

		FMX_HELP("A6020121", STR0224 + " ( " + Upper(Alltrim(X3CBoxDesc("VSO_STATUS",VSO->VSO_STATUS ))) + " )" , STR0226 ) // "Impossivel ALTERAR Agendamento da Oficina com STATUS // Utilize um Agedamento cujo Orçamento ainda não tenha sido gerado
		
		Return
	EndIf

	OA602014M_EXECUTA("VSO",VSO->(RecNo()),4,.f.)

Return

/*/{Protheus.doc} OA602013M_CANCELA
Acionar a rotina principal a fim de executar a ação de cancelamento
@type function
@version
@author Jessé Augusto
@since 17/11/2025
@return variant, return_description
/*/
Function OA602013M_CANCELA()

	OA602014M_EXECUTA("VSO",VSO->(RecNo()),5,.f.)

Return

/*/{Protheus.doc} OA602014M_EXECUTA
Rotina principal que centraliza as princpais ações a serem realizadas
@type function
@version
@author Jessé Augusto
@since 17/11/2025
@param cAlias, character, param_description
@param nRecVSO, numeric, param_description
@param nOpc, numeric, param_description
@param lClonar, logical, param_description
@return variant, return_description
/*/
Function OA602014M_EXECUTA(cAlias,nRecVSO,nOpc,lClonar)

Local oSizeL      := FwDefSize():New(.T.) // Com enchoicebar - Linhas Tela principal
Local oSizeC      := FwDefSize():New(.T.) // Com enchoicebar - Colunas Filial/Box, Calendario e Totalizadores
Local oSizeCH     := FwDefSize():New(.T.) // Com enchoicebar - Colunas dos Horarios
Local oFont1      := TFont():New(,10,20,,.F.,,,,,,,,,,,)
Local oFont2      := TFont():New(,08,16,,.F.,,,,,,,,,,,)
Local cBkpFilAnt  := cFilAnt
Local aFilAtu     := FWArrFilAtu()

Local lAllBox     := .t.
Local aAux        := {}
Local aCpoVSO     := {}

Local aCpoVSOAlt  := {""}

Local aCpoV00Alt  := {}
Local cLinOkV00   := ""
Local cFldOkV00   := ""
Local cDelOkV00   := ""

Local aCpoVSTAlt  := {}
Local cLinOkVST   := ""
Local cFldOkVST   := ""
Local cDelOkVST   := ""

Local aCpoV02Alt  := {}
Local cLinOkV02   := ""
Local cFldOkV02   := ""
Local cDelOkV02   := ""

Local aCpoV03Alt  := {}
Local cLinOkV03   := ""
Local cFldOkV03   := ""
Local cDelOkV03   := ""

Local nX     	  := 0
Local nCntFor     := 0
Local cHoraAtual  := ""

Private cHoraBox    := ""
Private cHoraBoxCOR := ""
Private aHoraBox    := {}

Private oGetDadV00
Private oEnchoiVSO
Private oGetDadVST
Private oGetDadV02
Private oGetDadV03

Private aCpoObgVSO := {}
Private aColsV00   := {}
Private aHeaderV00 := {}
Private aColsVST   := {}
Private aHeaderVST := {}
Private aColsV02   := {}
Private aHeaderV02 := {}
Private aColsV03   := {}
Private aHeaderV03 := {}
Private aFilSelect := {}
Private cFilSelect := cFilAnt
Private dDtaSelect := dDataAtual
Private aSecSelect := {}
Private cSecSelect := ""
Private aBoxSel    := {} As Array 
Private aBoxes     := {}
Private aTotHrs    := {}
Private oOkTik     := LoadBitmap( GetResources() , "LBTIK")
Private oNoTik     := LoadBitmap( GetResources() , "LBNO" )

Private cTempRetF3 := ""
Private cSeqTar    := space(TamSX3("VST_SEQTAR")[1])
Private aNewBot    := {}
Private aSM0     := FWAllFilial( aFilAtu[3] , aFilAtu[4] , aFilAtu[1] , .f. ) // Filiais Todas

Private cFiltroVX5    := "048"
Private M->VS4_GRUSER := space(TamSX3("VS4_GRUSER")[1]) // Manter a compatibilidade com o SXB V61 - Consulta Tabela de Servicos VO6

Private nOpcInic	:= nOpc
Private lChamPAge   := .t.

Default lClonar 	:= .f.

VISUALIZA := ( nOpc == 2 )
INCLUI    := ( nOpc == 3 )
ALTERA    := ( nOpc == 4 )
EXCLUI    := ( nOpc == 5 )

aNewBot := {}
aadd(aNewBot,{"S4WB007N",{|| OFIOC330( M->VSO_GETKEY ) } , STR0002 })  // Historico do Veículo na Oficina
If ExistFunc("FGX_ALTVEI")
	aadd(aNewBot,{"EDITABLE",{|| OA602069M_ALTVEI(nOpc, M->VSO_GETKEY) } , STR0003 })  // Alterar Dados do Veiculo
Endif

aadd(aNewBot,{"INSTRUME",  {|| OA6020081_Inconvenientes_PlanoRevisao(nOpc) }, iif( lAltInconv, OX001066K_AlteraDescricaoInconveniente('OUTRAS'), STR0004 ) })  // Inconvenientes / Plano de Revisao

aadd(aNewBot,{"INSTRUME",  {|| OA602045M_LEGHR() }, STR0008 })  // Legenda Horário

If ( ExistBlock("OM350ABT") )
	aNewBot := ExecBlock("OM350ABT",.f.,.f.,{aNewBot})
EndIf

If ExistFunc("FM_NEWBOT")
	FM_NEWBOT("POM350AGE","aNewBot") // Ponto de Entrada de Manutencao da aNewBot - Definicao de Novos Botoes na EnchoiceBar
Endif

If nOpc == 5 .and. !VSO->VSO_STATUS $ "1.5"
	
	cSitAtu := Upper( Alltrim( X3CBOXDESC("VSO_STATUS", VSO->VSO_STATUS ) ) ) + " )"
	
	FMX_HELP( "OA6020141", STR0009 + cSitAtu , STR0010 ) //  Impossivel CANCELAR Agendamento da Oficina com STATUS // Utilize um Agendamento apto a CANCELAR

	Return()
EndIf

OA602040M_LIMPAAGENDA()
If nOpc <> 3
	M->VSO_NUMBOX := VSO->VSO_NUMBOX
	M->VSO_DATAGE := VSO->VSO_DATAGE
	M->VSO_HORAGE := VSO->VSO_HORAGE
	M->VSO_DATFIN := VSO->VSO_DATFIN
	M->VSO_HORFIN := VSO->VSO_HORFIN
	M->VSO_TEMPAD := VSO->VSO_TEMPAD
	dDtaSelect := VSO->VSO_DATAGE
EndIf

aFilAtu := {}
For nCntFor := 1 to Len(aSM0)
	cFilAnt := aSM0[nCntFor]
	aFilAtu := FWArrFilAtu()
	aAdd( aFilSelect, cFilAnt+"="+FWFilialName() )
Next
cFilAnt := cBkpFilAnt
OA602018M_LEVBOX(.f.,IIf(nOpc<>3.and.!lClonar,M->VSO_NUMBOX,""))   // Levanta Boxes da Filial
OA602019M_BOXSELECT()   // Variavel que controla Box(es) selecionado(s)
OA602029M_ANALISA_HORAS(0)   // Levanta Horarios da Filial

oSizeL:lLateral := .F. 						   // Cálculo vertical
oSizeL:AddObject("L1"    ,   0,  90, .T., .T.) // Linha 1 restante
oSizeL:AddObject("L2"    ,   0,  80, .T., .F.) // Linha 2 fixa 80pix
oSizeL:AddObject("L3"    ,   0,  25, .T., .F.) // Linha 3 fixa 25pix
oSizeL:Process()

oSizeC:lLateral := .T. // Cálculo vertical
oSizeC:AddObject("C1"    ,   0,   0, .T., .T.) // Coluna 1 50% do restante
If nOpc == 3 .or. nOpc == 4
	oSizeC:AddObject("C2"    , 150,   0, .F., .F.) // Coluna 2 fixa 150pix - Calendario
EndIf
oSizeC:AddObject("C3"    ,   0,   0, .T., .T.) // Coluna 3 50% do restante
oSizeC:Process()

oSizeCH:lLateral := .T. // Cálculo vertical
oSizeCH:AddObject("C1"   ,   0,   0, .T., .T.) // Coluna 1 50% do restante
oSizeCH:AddObject("C2"   , 505,   0, .F., .F.) // Coluna 3 fixa 600pix
oSizeCH:AddObject("C3"   ,   0,   0, .T., .T.) // Coluna 2 50% do restante
oSizeCH:Process()

 
DEFINE MSDIALOG oTELAAGENDA TITLE STR0011 +IIf(lClonar," - " + STR0012,"") FROM oSizeC:aWindSize[1], oSizeC:aWindSize[2] TO oSizeC:aWindSize[3], oSizeC:aWindSize[4] PIXEL // Agendamento // Clonar

////////////////////////////////////////////////////////////////////////////////
// CRIACAO DOS PAINEIS AONDE VAO OS OBJETOS NA TELA                           //
////////////////////////////////////////////////////////////////////////////////

	oTPanel1 := TPanel():New(	oSizeL:GetDimension("L1", "LININI"),;
								oSizeC:GetDimension("C1", "COLINI"),;
								"",oTELAAGENDA,NIL,.T.,.F.,NIL,NIL,;
								oSizeC:GetDimension("C3", "COLEND")-oSizeC:GetDimension("C1", "COLINI"),;
								oSizeL:GetDimension("L1", "LINEND")-oSizeL:GetDimension("L1", "LININI"),;
								.T.,.F.)

	oTPanel2 := TPanel():New(	oSizeL:GetDimension("L2", "LININI"),;
								oSizeC:GetDimension("C1", "COLINI"),;
								"",oTELAAGENDA,NIL,.T.,.F.,NIL,NIL,;
								oSizeC:GetDimension("C1", "COLEND")-oSizeC:GetDimension("C1", "COLINI"),;
								oSizeL:GetDimension("L2", "LINEND")-oSizeL:GetDimension("L2", "LININI"),;
								.T.,.F.)

	If nOpc == 3 .or. nOpc == 4
		oTPanel3 := TPanel():New(	oSizeL:GetDimension("L2", "LININI"),;
								oSizeC:GetDimension("C2", "COLINI"),;
								"",oTELAAGENDA,NIL,.T.,.F.,NIL,NIL,;
								oSizeC:GetDimension("C2", "COLEND")-oSizeC:GetDimension("C2", "COLINI"),;
								oSizeL:GetDimension("L2", "LINEND")-oSizeL:GetDimension("L2", "LININI"),;
								.T.,.F.)
	EndIf

	oTPanel4 := TPanel():New(	oSizeL:GetDimension("L2", "LININI"),;
								oSizeC:GetDimension("C3", "COLINI"),;
								"",oTELAAGENDA,NIL,.T.,.F.,NIL,NIL,;
								oSizeC:GetDimension("C3", "COLEND")-oSizeC:GetDimension("C3", "COLINI"),;
								oSizeL:GetDimension("L2", "LINEND")-oSizeL:GetDimension("L2", "LININI"),;
								.T.,.F.)

	oTPanel5 := TPanel():New(	oSizeL:GetDimension("L3", "LININI"),;
								oSizeCH:GetDimension("C2", "COLINI"),;
								"",oTELAAGENDA,NIL,.T.,.F.,NIL,NIL,;
								oSizeCH:GetDimension("C2", "COLEND")-oSizeCH:GetDimension("C2", "COLINI"),;
								oSizeL:GetDimension("L3", "LINEND")-oSizeL:GetDimension("L3", "LININI"),;
								.T.,.F.)

	////////////////////////////////////////////////////////////////////////////////
	// ABAS TAREFAS/RECLAMACOES / VEICULOS / INCONV / PECAS / SERVICOS - PAINEL 1 //
	////////////////////////////////////////////////////////////////////////////////

	oFoldOA602 := TFolder():New(1,1,{},,oTPanel1,,,,.T.,.F.,100,100)
	oFoldOA602:Align:= CONTROL_ALIGN_ALLCLIENT
	oFoldOA602:AddItem( STR0013 , .t. ) // Tarefas / Reclamações / Solicitações do Cliente
	oFoldOA602:AddItem( STR0014 , .t. ) // Veiculo / Cliente
	oFoldOA602:AddItem( STR0015 , .t. )	// Relacionar Tarefas / Pacotes / Inconvenientes
	oFoldOA602:AddItem( STR0016 , .t. )	// Peças
	oFoldOA602:AddItem( STR0017 , .t. ) // Serviços
	oFoldOA602:bSetOption := { |x| OA602024M_SELFOLDER(oFoldOA602:nOption , x , nOpc )}

	RegToMemory("V00",IIF(VISUALIZA,.f.,.t.))
	aAux := OA602020M_MONTACOLS(  "V00",;
							      "V00_FILIAL,V00_CODIGO,V00_CODAGE,",;
							      "",;
							      2,;
							      VSO->VSO_NUMIDE ,;
							      "V00->V00_FILIAL == xFilial('V00') .and. V00->V00_CODAGE == VSO->VSO_NUMIDE",;
							      )

	aColsV00   := aClone(aAux[1])
	aHeaderV00 := aClone(aAux[2])
	aCpoV00Alt := aClone(aAux[3])
	
	cLinOkV00 := "OA602023M_VLDLINHA('V00',"+AllTrim(Str(nOpc))+")"
	cFldOkV00 := "OA602021M_FLDVLDOK('V00',"+AllTrim(Str(nOpc))+")"
	cDelOkV00 := "OA602022M_VLDDEL('V00',"+AllTrim(Str(nOpc))+","+IIf(lClonar,".t.",".f.")+")"

	oGetDadV00 := MsNewGetDados():New(0,0,100,100,;
		IIF( nOpc == 3 .or. (nOpc == 4 .and. VSO->VSO_STATUS == "1"), GD_DELETE + GD_UPDATE + GD_INSERT, 0) ,;
		cLinOkV00,;
		"AlwaysTrue()",;
		,;
		aCpoV00Alt ,; 	// Campos alteraveis da GetDados
		/* nFreeze */,;	// Campos estaticos da GetDados
		999 ,;
		cFldOkV00,;
		/* cSuperDel */,; 	// Funcao executada quando pressionado <Ctrl>+<Del>
		cDelOkV00,; 		// Funcao executada para validar a exclusao de uma linha
		oFoldOA602:aDialogs[1],;
		aHeaderV00 ,;
		aColsV00)
	oGetDadV00:oBrowse:bChange   := { || FG_MEMVAR( oGetDadV00:aHeader , oGetDadV00:aCols , oGetDadV00:nAt ) }
	oGetDadV00:oBrowse:bGotFocus := { || FG_MEMVAR( oGetDadV00:aHeader , oGetDadV00:aCols , oGetDadV00:nAt ) }
	oGetDadV00:oBrowse:Align := CONTROL_ALIGN_ALLCLIENT

	// Veiculos / Cliente / Dados Agendamento VSO
	cVSONMostra := "VSO_NUMBOX,VSO_DATAGE,VSO_HORAGE,VSO_DATFIN,VSO_HORFIN,VSO_NUMIDE,VSO_TEMPAD,"

	aInfoTab := FWSX3Util():GetAllFields("VSO")

	For nX   := 1 To Len(aInfoTab)

		cCampo   := Alltrim( GetSX3Cache( aInfoTab[nX], "X3_CAMPO"))
		  
		lUsado   := X3USO( GetSX3Cache(cCampo, "X3_USADO") )

		lNivelOk := cNivel >= GetSX3Cache( cCampo , "X3_NIVEL")

		If lUsado .And. lNivelOk .And. !(Alltrim( cCampo )+"," $ cVSONMostra)

			aAdd( aCpoVSO, cCampo)

			If X3Obrigat( cCampo )
				aAdd(aCpoObgVSO, cCampo )
			EndIf

		EndIf
		
	Next nX

	If nOpc == 3 .or. lClonar // Incluir
		
		aCpoVSOAlt := NIL

	ElseIf nOpc == 4 // Alterar
		
		aCpoVSOAlt := {"VSO_OBSERV","VSO_RESPAG","VSO_TPATEN","VSO_TIPAGE","VSO_COMIMP","VSO_GESTOR","VSO_FUNAGE","VSO_TPMANU"}

	Else // Visualizar // Excluir
		
		aCpoVSOAlt := {""}
	EndIf

	RegToMemory("VSO",IIF(nOpc <> 3,.f.,.t.))

	oEnchVSO := MSMGet():New( "VSO" , 0 , nOpc ,;
	/* aCRA */, /* cLetra */, /* cTexto */, aCpoVSO , {0,0,0,0} , aCpoVSOAlt , 3,;
	/* nColMens */, /* cMensagem */, ".t." /*cTudoOk*/, oFoldOA602:aDialogs[2] , .t., .t., .t. /* lColumn */ ,;
	"", .t. /* lNoFoldOA602 */, .f.)
	oEnchVSO:oBox:Align := CONTROL_ALIGN_ALLCLIENT

	// Inconvenientes
	RegToMemory("VST",IIF(VISUALIZA,.f.,.t.))
	
	aAux := OA602020M_MONTACOLS(  "VST",;
								  "VST_FILIAL,VST_TIPO,VST_CODIGO,VST_EXPPEC,VST_EXPSRV,VST_CODMAR,VST_CHASSI,",;
								  "VST_SEQTAR,VST_GRUINC,VST_CODINC,VST_DESINC,",;
								  1,;
								  "3"+VSO->VSO_NUMIDE,;
								  "VST->VST_FILIAL == xFilial('VST') .and. VST->VST_TIPO == '3' .and. VST->VST_CODIGO == VSO->VSO_NUMIDE",;
								  "VST_SEQTAR,")

	aColsVST   := aClone(aAux[1])
	aHeaderVST := aClone(aAux[2])
	aCpoVSTAlt := aClone(aAux[3])

	cLinOkVST := "OA602023M_VLDLINHA('VST',"+AllTrim(Str(nOpc))+")"
	cFldOkVST := "OA602021M_FLDVLDOK('VST',"+AllTrim(Str(nOpc))+")"
	cDelOkVST := "OA602022M_VLDDEL('VST',"+AllTrim(Str(nOpc))+","+IIf(lClonar,".t.",".f.")+")"

	cSeqTar := M->VST_SEQTAR := space(TamSX3("VST_SEQTAR")[1])
	cGruInc := space(TamSX3("VST_GRUINC")[1])
	cCodInc := space(TamSX3("VST_CODINC")[1])
	cDesInc := space(TamSX3("VST_DESINC")[1])
	
	oSay01 := TSay():New(007, 002, {|| STR0019 },oFoldOA602:aDialogs[3],,,,,,.t.,,,60,8)		// Grupo Pct Serviço
	@ 05, 050 MSGET oGruInc VAR cGruInc F3 "VSK" VALID (Vazio() .or. OA602043M_VLDGRUPOMARCA(M->VSO_CODMAR,cGruInc))  PICTURE "@!" SIZE 30,8 PIXEL HASBUTTON OF oFoldOA602:aDialogs[3] WHEN (INCLUI .Or. ALTERA)

	oSay01 := TSay():New(007, 095, {|| STR0020 },oFoldOA602:aDialogs[3],,,,,,.t.,,,50,8)		// Cód. Pct Serviço
	@ 05, 140 MSGET oCodInc VAR cCodInc F3 "VSL" PICTURE "@!" SIZE 50,8 PIXEL HASBUTTON OF oFoldOA602:aDialogs[3] WHEN (INCLUI .Or. ALTERA)

	@ 05,200 BUTTON oBPacote PROMPT STR0022 OF oFoldOA602:aDialogs[3] SIZE 30,10 PIXEL ACTION ( OA602035M_INCONV(nOpc,cGruInc,cCodInc,cDesInc,"C")) WHEN ( INCLUI .OR. ALTERA ) // OK

	oGetDadVST := MsNewGetDados():New(0,0,oSizeL:GetDimension("L1", "LINEND") - oSizeL:GetDimension("L1", "LININI") - 40,100,;
	IIF( nOpc == 3 .or. (nOpc == 4 .and. VSO->VSO_STATUS == "1") , GD_DELETE + GD_UPDATE, 0) ,;
	cLinOkVST,;
	"AlwaysTrue()",;
	,;
	aCpoVSTAlt ,; 	// Campos alteraveis da GetDados
	/* nFreeze */,;	// Campos estaticos da GetDados
	999 ,;
	cFldOkVST,;
	/* cSuperDel */,; 	// Funcao executada quando pressionado <Ctrl>+<Del>
	cDelOkVST,; 		// Funcao executada para validar a exclusao de uma linha
	oFoldOA602:aDialogs[3],;
	aHeaderVST ,;
	aColsVST)
	oGetDadVST:oBrowse:bChange   := { || FG_MEMVAR( oGetDadVST:aHeader , oGetDadVST:aCols , oGetDadVST:nAt ) , cSeqTar := oGetDadVST:aCols[oGetDadVST:nAt ,FG_POSVAR("VST_SEQTAR","aHeaderVST")] }
	oGetDadVST:oBrowse:bGotFocus := { || FG_MEMVAR( oGetDadVST:aHeader , oGetDadVST:aCols , oGetDadVST:nAt ) , cSeqTar := oGetDadVST:aCols[oGetDadVST:nAt ,FG_POSVAR("VST_SEQTAR","aHeaderVST")] }
	oGetDadVST:oBrowse:Align := CONTROL_ALIGN_BOTTOM

	aNovaOrdem := {"V02_SEQINC","V02_GRUINC","V02_CODINC","V02_DESINC","V02_GRUITE","V02_CODITE"}

	// Pecas
	RegToMemory("V02",IIF(VISUALIZA,.f.,.t.))
	aAux := OA602020M_MONTACOLS( "V02",;
								 "V02_FILIAL,V02_CODAGE,",;
								 "V02_GRUINC,V02_CODINC,",;
								 2,;
								 VSO->VSO_NUMIDE,;
								 "V02->V02_FILIAL == xFilial('V02') .and. V02->V02_CODAGE == VSO->VSO_NUMIDE",;
								 ,;
								 aNovaOrdem;
							)

	aColsV02   := aClone(aAux[1])
	aHeaderV02 := aClone(aAux[2])
	aCpoV02Alt := aClone(aAux[3])
	cLinOkV02  := "OA602023M_VLDLINHA('V02',"+AllTrim(Str(nOpc))+")"
	cFldOkV02  := "OA602021M_FLDVLDOK('V02',"+AllTrim(Str(nOpc))+")"
	cDelOkV02  := "OA602022M_VLDDEL('V02',"+AllTrim(Str(nOpc))+","+IIf(lClonar,".t.",".f.")+")"
	
	oGetDadV02 := MsNewGetDados():New(0,0,100,100,;
		IIF( nOpc == 3 .or. (nOpc == 4 .and. VSO->VSO_STATUS == "1") , GD_DELETE + GD_UPDATE + GD_INSERT, 0) ,;
		cLinOkV02,;
		"AlwaysTrue()",;
		,;
		aCpoV02Alt ,; 	// Campos alteraveis da GetDados
		/* nFreeze */,;	// Campos estaticos da GetDados
		999 ,;
		cFldOkV02,;
		/* cSuperDel */,; 	// Funcao executada quando pressionado <Ctrl>+<Del>
		cDelOkV02,; 		// Funcao executada para validar a exclusao de uma linha
		oFoldOA602:aDialogs[4],;
		aHeaderV02 ,;
		aColsV02)

	oGetDadV02:oBrowse:bChange   := { || FG_MEMVAR( oGetDadV02:aHeader , oGetDadV02:aCols , oGetDadV02:nAt ) }
	oGetDadV02:oBrowse:bGotFocus := { || FG_MEMVAR( oGetDadV02:aHeader , oGetDadV02:aCols , oGetDadV02:nAt ) }
	oGetDadV02:oBrowse:Align := CONTROL_ALIGN_ALLCLIENT

	// Servicos
	RegToMemory("V03",IIF(VISUALIZA,.f.,.t.))
	
	aNovaOrdem := {"V03_SEQINC","V03_GRUINC","V03_CODINC","V03_DESINC","V03_GRUSER","V03_CODSER"}

	aAux := OA602020M_MONTACOLS( "V03",;
								 "V03_FILIAL,V03_CODAGE,",;
								 "V03_TEMPAD,V03_GRUINC,V03_CODINC,",;
								 2,;
								 VSO->VSO_NUMIDE,;
								 "V03->V03_FILIAL == xFilial('V03') .and. V03->V03_CODAGE == VSO->VSO_NUMIDE";
								 , ,;
								 aNovaOrdem;
							)

	aColsV03   := aClone(aAux[1])
	aHeaderV03 := aClone(aAux[2])
	aCpoV03Alt := aClone(aAux[3])

	cLinOkV03 := "OA602023M_VLDLINHA('V03',"+AllTrim(Str(nOpc))+")"
	cFldOkV03 := "OA602021M_FLDVLDOK('V03',"+AllTrim(Str(nOpc))+")"
	cDelOkV03 := "OA602022M_VLDDEL('V03',"+AllTrim(Str(nOpc))+","+IIf(lClonar,".t.",".f.")+")"

	oGetDadV03 := MsNewGetDados():New(0,0,100,100,;
		IIF( nOpc == 3 .or. (nOpc == 4 .and. VSO->VSO_STATUS == "1") , GD_DELETE + GD_UPDATE + GD_INSERT, 0) ,;
		cLinOkV03,;
		"AlwaysTrue()",;
		,;
		aCpoV03Alt ,; 	// Campos alteraveis da GetDados
		/* nFreeze */,;	// Campos estaticos da GetDados
		999 ,;
		cFldOkV03,;
		/* cSuperDel */,; 	// Funcao executada quando pressionado <Ctrl>+<Del>
		cDelOkV03,; 		// Funcao executada para validar a exclusao de uma linha
		oFoldOA602:aDialogs[5],;
		aHeaderV03 ,;
		aColsV03)
	
	oGetDadV03:oBrowse:bChange   := { || FG_MEMVAR( oGetDadV03:aHeader , oGetDadV03:aCols , oGetDadV03:nAt ) , M->VS4_GRUSER := M->V03_GRUSER }
	oGetDadV03:oBrowse:bGotFocus := { || FG_MEMVAR( oGetDadV03:aHeader , oGetDadV03:aCols , oGetDadV03:nAt ) , M->VS4_GRUSER := M->V03_GRUSER }
	oGetDadV03:oBrowse:Align := CONTROL_ALIGN_ALLCLIENT

	oGetDadV00:oBrowse:SetFocus()

	////////////////////////////////////////////////////////////////////////////////
	// CRIACAO DA SELECAO DA FILIAL / LISTBOX DOS BOXES - PAINEL 2                //
	////////////////////////////////////////////////////////////////////////////////

	@ 01,02 SAY STR0023 SIZE 40,10 FONT oFont1 OF oTPanel2 PIXEL COLOR CLR_BLACK // Filial
	@ 01,27 MSCOMBOBOX oFilSelect VAR cFilSelect SIZE oSizeC:GetDimension("C1", "COLEND")-oSizeC:GetDimension("C1", "COLINI")-87,10 COLOR CLR_BLACK FONT oFont2 ITEMS aFilSelect OF oTPanel2 PIXEL ON CHANGE ( OA602029M_ANALISA_HORAS(1) , OA602018M_LEVBOX(.t.,"") , OA602040M_LIMPAAGENDA() , OA602019M_BOXSELECT() , OA602030M_CORES() ) WHEN ( nOpc == 3 .or. lClonar )
	
	@ 01,oSizeC:GetDimension("C1", "COLEND")-oSizeC:GetDimension("C1", "COLINI")-60 MSCOMBOBOX oSecSelect VAR cSecSelect SIZE 60,10 COLOR CLR_BLACK ITEMS aSecSelect OF oTPanel2 PIXEL ON CHANGE ( lAllBox := Empty(cSecSelect) , aEval(aBoxes,{|x| x[1] := IIf( alltrim(x[3]) == Alltrim(cSecSelect) .or. Empty(cSecSelect) , .t. , .f. ) }) , oLbBoxes:Refresh() , OA602040M_LIMPAAGENDA() , OA602019M_BOXSELECT() , OA602030M_CORES() ) WHEN ( nOpc == 3 .or. nOpc == 4 )
	
	oLbBoxes := TWBrowse():New( 13,;
								1,;
								oSizeC:GetDimension("C1", "COLEND")-oSizeC:GetDimension("C1", "COLINI")-2,;
								67,;
								,,,oTPanel2,,,,,{ || .t. },,,,,,,.F.,,.T.,,.F.,,,)
	
	oLbBoxes:addColumn( TCColumn():New( "", { || IIf(aBoxes[oLbBoxes:nAt,1],oOkTik,oNoTik) } ,,,,"LEFT" ,05,.T.,.F.,,,,.F.,) ) // Tik
	oLbBoxes:addColumn( TCColumn():New( STR0024 , { || aBoxes[oLbBoxes:nAt,02] } ,,,, "LEFT" ,  35 ,.F.,.F.,,,,.F.,) )		   // Box
	oLbBoxes:addColumn( TCColumn():New( STR0025 , { || aBoxes[oLbBoxes:nAt,03] } ,,,, "LEFT" ,  50 ,.F.,.F.,,,,.F.,) )	   	   // Descrição
	oLbBoxes:nAt := 1
	oLbBoxes:SetArray(aBoxes)
	
	If nOpc == 3 .or. nOpc == 4
		oLbBoxes:bLDblClick   := { || ( aBoxes[oLbBoxes:nAt,1] := !aBoxes[oLbBoxes:nAt,1] , cSecSelect := "" , oSecSelect:Refresh() , OA602040M_LIMPAAGENDA() , OA602019M_BOXSELECT() , OA602030M_CORES() ) }
		oLbBoxes:bHeaderClick := {|oObj,nCol| IIf( nCol==1 , ( lAllBox := !lAllBox , cSecSelect := "" , oSecSelect:Refresh() , aEval(aBoxes,{|x| x[1] := lAllBox }) , oLbBoxes:Refresh() , OA602040M_LIMPAAGENDA() , OA602019M_BOXSELECT() , OA602030M_CORES() ) , .t. ) , }
	EndIf

	////////////////////////////////////////////////////////////////////////////////
	// CRIACAO DO CALENDARIO / DIA SELECIONADO - PAINEL 3                         //
	////////////////////////////////////////////////////////////////////////////////

	If nOpc == 3 .or. nOpc == 4
		oCalAgenda:=MsCalend():New( 01,01,oTPanel3,.f.)
		oCalAgenda:bChange := {|| ( OA602016M_CALENDARIO() , OA602040M_LIMPAAGENDA() , OA602030M_CORES() ) }
		oCalAgenda:Align := CONTROL_ALIGN_ALLCLIENT
		oCalAgenda:dDiaAtu := dDtaSelect
	EndIf

	////////////////////////////////////////////////////////////////////////////////
	// CRIACAO DO LISTBOX TOTALIZADOR DE HORAS - PAINEL 4                         //
	////////////////////////////////////////////////////////////////////////////////

	OA602038M_TOTHORAS(.f.) // Totalizar das Horas Gerais, Produtivos em paralelo e por Produtivo
	oLbTotHrs := TWBrowse():New( 1,;
								1,;
								oSizeC:GetDimension("C3", "COLEND")-oSizeC:GetDimension("C3", "COLINI")-2,;
								79,;
								,,,oTPanel4,,,,,{ || .t. },,,,,,,.F.,,.T.,,.F.,,,)

	oLbTotHrs:addColumn( TCColumn():New( STR0026, { || aTotHrs[oLbTotHrs:nAt,01]+" "+aTotHrs[oLbTotHrs:nAt,03]  } ,,,, "LEFT" ,  180 ,.F.,.F.,,,,.F.,) ) // Horas Agendamento
	oLbTotHrs:addColumn( TCColumn():New( STR0027, { || Transform(aTotHrs[oLbTotHrs:nAt,02],"@R 99:99") } ,,,, "RIGHT" ,  30 ,.F.,.F.,,,,.F.,) )     	 // Qtd.Horas
	oLbTotHrs:nAt := 1
	oLbTotHrs:SetArray(aTotHrs)

	////////////////////////////////////////////////////////////////////////////////
	// CRIACAO DA SELECAO DOS HORARIOS - PAINEL 5                                 //
	////////////////////////////////////////////////////////////////////////////////

	nPosBot  := 0
	For nCntFor := 0 to 23
		@ 02,(21*nPosBot)+2 BUTTON &("o"+strzero(nCntFor,2)+"H") PROMPT (strzero(nCntFor,2)+"H") OF oTPanel5 SIZE 18,10 PIXEL WHEN .f. // Hora
		@ 01,(21*nPosBot)+1 TO 25,(21*nPosBot)+21 LABEL "" OF oTPanel5 PIXEL // Caixa por fora da Hora
		nPosBot++
	Next
	cCor1 := "VERDE"
	cCor2 := "AZUL"
	cCor3 := "VERMELHO"
	nColuna := 4
	nHrs := 0
	nMin := 0
	For nCntFor := 1 to 96
		&("oBM"+strzero(nCntFor,2)+"_1") := TBtnBmp2():New(23,nColuna,07,25,cCor1,,,,&(IIf(nOpc==3.or.nOpc==4,'{|| OA602039M_CLICKHR('+Alltrim(str(nCntFor))+',"'+strzero(nHrs,2)+strzero(nMin,2)+'") }','{|| .t. }')),oTPanel5,strzero(nHrs,2)+":"+strzero(nMin,2),,.T.)
		&("oBM"+strzero(nCntFor,2)+"_2") := TBtnBmp2():New(23,nColuna,07,25,cCor2,,,,&(IIf(nOpc==3.or.nOpc==4,'{|| OA602039M_CLICKHR('+Alltrim(str(nCntFor))+',"'+strzero(nHrs,2)+strzero(nMin,2)+'") }','{|| .t. }')),oTPanel5,strzero(nHrs,2)+":"+strzero(nMin,2),,.T.)
		&("oBM"+strzero(nCntFor,2)+"_3") := TBtnBmp2():New(23,nColuna,07,25,cCor3,,,,&(IIf(nOpc==3.or.nOpc==4,'{|| OA602039M_CLICKHR('+Alltrim(str(nCntFor))+',"'+strzero(nHrs,2)+strzero(nMin,2)+'") }','{|| .t. }')),oTPanel5,strzero(nHrs,2)+":"+strzero(nMin,2),,.T.)
		nColuna += 9
		nMin += 15
		If nMin == 60
			nMin := 0
			nHrs++
			nColuna += 6 // Troca de Hora ( hora cheia separa mais )
		EndIf
	Next

	If lClonar
		nOpc := 3
		M->VSO_NUMBOX := Space(TamSX3("VSO_NUMBOX")[1])
		M->VSO_DATAGE := CToD("")
		M->VSO_HORAGE := Space(TamSX3("VSO_HORAGE")[1])
		M->VSO_DATFIN := CToD("")
		M->VSO_HORFIN := 0
		M->VSO_TEMPAD := 0
		M->VSO_STATUS := "1"
		M->VSO_AGCONF := "0"
		dDtaSelect    := dDataAtual
		M->VSO_DATREG := dDataAtual

		cHoraAtual	:= Time()
		IF FindFunction("FGX_TimeUF")
			cHoraAtual := FGX_TimeUF()[2]
		Endif
		M->VSO_HORREG := Val(Substr(cHoraAtual,1,2)+Substr(cHoraAtual,4,2))
	EndIf

	OA602030M_CORES()

	@ oSizeL:GetDimension("L3", "LININI"),oSizeCH:GetDimension("C1", "COLINI") ;
		BUTTON oDSSelect PROMPT OA602017M_DIASEMANA() OF oTELAAGENDA FONT oFont1 ;
		SIZE 	oSizeCH:GetDimension("C1", "COLEND")-oSizeCH:GetDimension("C1", "COLINI"),;
				oSizeL:GetDimension("L3", "LINEND")-oSizeL:GetDimension("L3", "LININI") PIXEL WHEN .f.

	@ oSizeL:GetDimension("L3", "LININI"),oSizeCH:GetDimension("C3", "COLINI") ;
		BUTTON oDtSelect PROMPT Transform(dDtaSelect,"@D") OF oTELAAGENDA FONT oFont1 ;
		SIZE 	oSizeCH:GetDimension("C3", "COLEND")-oSizeCH:GetDimension("C3", "COLINI"),;
				oSizeL:GetDimension("L3", "LINEND")-oSizeL:GetDimension("L3", "LININI") PIXEL WHEN .f.

	oFoldOA602:SetOption( 1 )

ACTIVATE MSDIALOG oTELAAGENDA ON INIT EnchoiceBar(oTELAAGENDA, {|| IIf(OA602026M_VLDTDOK(nOpc),( OA602025M_GRAVACAO_FINAL(nOpc,lClonar) , oTELAAGENDA:End() ) ,.t.), },{|| oTELAAGENDA:End() },,aNewBot)


Return

/*/{Protheus.doc} OA602016M_CALENDARIO
Chama a tela correspondente ao Calendário
@type function
@version
@author Jessé Augusto
@since 17/11/2025
@return variant, return_description
/*/
Static Function OA602016M_CALENDARIO()

	If oCalAgenda:dDiaAtu < dDataAtual
		oCalAgenda:dDiaAtu := dDataAtual
		
		FWAlertInfo(STR0028 + CHR(13)+CHR(10)+CHR(13)+CHR(10)+Transform(dDataAtual,"@D"),STR0029) // A Data selecionada deve ser igual ou posterior a Data de Hoje5447
	EndIf

	dDtaSelect := oCalAgenda:dDiaAtu
	oDSSelect:cCaption := OA602017M_DIASEMANA()
	oDSSelect:Refresh()
	oDtSelect:cCaption := Transform(dDtaSelect,"@D")
	oDtSelect:Refresh()
Return

/*/{Protheus.doc} OA602017M_DIASEMANA
Determina o dia da semana
@type function
@version
@author Jessé Augusto
@since 11/17/2025
@return variant, return_description
/*/
Static Function OA602017M_DIASEMANA()

	Local cRet := ""

	Do Case
		Case Dow(dDtaSelect) == 1

			cRet := STR0030 // Domingo

		Case Dow(dDtaSelect) == 2

			cRet := STR0031 // 2ªFeira

		Case Dow(dDtaSelect) == 3

			cRet := STR0032 // 3ªFeira"

		Case Dow(dDtaSelect) == 4

			cRet := STR0033 // 4ªFeira

		Case Dow(dDtaSelect) == 5

			cRet := STR0034 // 5ªFeira

		Case Dow(dDtaSelect) == 6

			cRet := STR0035 // 6ªFeira

		Case Dow(dDtaSelect) == 7

			cRet := STR0036 // Sábado

	EndCase

Return cRet

/*/{Protheus.doc} OA602018M_LEVBOX
Atualiza a marcações dos box
@type function
@version
@author Jessé Augusto
@since 17/11/2025
@param lRefresh, logical, param_description
@param cBoxPreSel, character, param_description
@return variant, return_description
/*/
Static Function OA602018M_LEVBOX(lRefresh,cBoxPreSel)

	Local cQuery       := ""
	Local cQAlSQL      := "SQLVON"
	Local cBkpFilAnt   := cFilAnt // Salva cFilAnt
	Local cQuebra      := ""
	Local nCont        := 0
	Local cBoxPer      := ""
	Local cBoxnPer     := ""
	Local nTamBox      := TamSX3("VON_NUMBOX")[1]
	Default lRefresh   := .f.
	Default cBoxPreSel := ""
	
	cFilAnt := cFilSelect // Filial Selecionada
	

	If VAI->(FieldPos("VAI_BOXPER")) > 0 .and. VAI->(FieldPos("VAI_BOXNPE"))
		// Levanta todos os Box permitidos para o Agendamento
		For nCont := 1 to Len(Alltrim(VAI->VAI_BOXPER))/(nTamBox)
				cBoxPer += "'" + Subs(Alltrim(VAI->VAI_BOXPER),(nCont*nTamBox)-2,nTamBox) + "',"
		Next nCont
		cBoxPer := Left(cBoxPer,Len(cBoxPer)-1)
		// Levanta todos os Box não permitidos para o Agendamento
		For nCont := 1 to Len(Alltrim(VAI->VAI_BOXNPE))/(nTamBox)
				cBoxnPer += "'" + Subs(Alltrim(VAI->VAI_BOXNPE),(nCont*nTamBox)-2,nTamBox) + "',"
		Next nCont
		cBoxnPer := Left(cBoxnPer,Len(cBoxnPer)-1)
		
	Endif
	
	aSecSelect := {""}
	aParams    := {}

	cSecSelect := ""
	aBoxes := {}
	cQuery := "SELECT VON.VON_NUMBOX , VOD.VOD_DESSEC "
	cQuery += "  FROM "+RetSqlName("VON")+" VON "
	cQuery += "  JOIN "+RetSqlName("VOD")+" VOD ON ( VOD.VOD_FILIAL= ? AND VOD.VOD_CODSEC=VON.VON_CODSEC AND VOD.D_E_L_E_T_=' ' ) "
	cQuery += " WHERE VON.VON_FILIAL= ? "
	
	aAdd( aParams, xFilial("VOD") )
	aAdd( aParams, xFilial("VON") )

	If !Empty(cBoxPer)
		
		cQuery += "  AND VON.VON_NUMBOX IN ( ? ) "
		
		aAdd( aParams, cBoxPer )
	Endif

	If !Empty(cBoxnPer)
		
		cQuery += " AND VON.VON_NUMBOX NOT IN ( ? ) "

		aAdd( aParams, cBoxnPer )
	Endif
	
	cQuery += "  AND VON.D_E_L_E_T_=' ' "
	cQuery += "ORDER BY VOD.VOD_DESSEC , VON.VON_NUMBOX "

	oExec := FWExecStatement():New()
	oExec:SetQuery(cQuery)
	oExec:SetParams(aParams)

	cQAlSQL := oExec:OpenAlias()

	While !( cQAlSQL )->( Eof() )
		aadd(aBoxes,{ IIf(Empty(cBoxPreSel),.t.,(cBoxPreSel==( cQAlSQL )->( VON_NUMBOX ))) , ( cQAlSQL )->( VON_NUMBOX ) , ( cQAlSQL )->( VOD_DESSEC ) })
		If cQuebra <> ( cQAlSQL )->( VOD_DESSEC )
			cQuebra := ( cQAlSQL )->( VOD_DESSEC )
			aAdd(aSecSelect, ( cQAlSQL )->( VOD_DESSEC ) )
		EndIf
		( cQAlSQL )->( DbSkip() )
	EndDo
	( cQAlSQL )->( DbCloseArea() )
	DbSelectArea("VON")
	
	cFilAnt := cBkpFilAnt // Volta cFilAnt
	
	If len(aBoxes) <= 0
		aAdd(aBoxes,{ .f. , "" , "" })
	EndIf
	If lRefresh
		oLbBoxes:nAt := 1
		oLbBoxes:SetArray(aBoxes)
		oLbBoxes:Refresh()
		If !Empty(aSecSelect)
			oSecSelect:SetItems(aSecSelect)
		EndIf
		oSecSelect:SetFocus()
	EndIf
	
Return

/*/{Protheus.doc} OA602019M_BOXSELECT
Realiza a seleção das boxes
@type function
@version
@author Jessé Augusto
@since 17/11/2025
@return variant, return_description
/*/
Static Function OA602019M_BOXSELECT()

	Local nCntFor := 0
	aBoxSel := {}

	For nCntFor := 1 To Len(aBoxes)
		If aBoxes[nCntFor, 1] .And. !Empty(aBoxes[nCntFor, 2])
			aAdd(aBoxSel, aBoxes[nCntFor,2])
		EndIf
	Next

Return()

/*/{Protheus.doc} OA602020M_MONTACOLS
Realiza o processo de montagem do aCols
@type function
@version
@author Jessé Augusto
@since 17/11/2025
@param cAliasTMP, character, param_description
@param cNaoMostra, character, param_description
@param cNaoEdit, character, param_description
@param nIndPosic, numeric, param_description
@param cPosiciona, character, param_description
@param cChvWhile, character, param_description
@param cCposFixos, character, param_description
@return variant, return_description
/*/
Static Function OA602020M_MONTACOLS(cAliasTMP,cNaoMostra,cNaoEdit,nIndPosic,cPosiciona,cChvWhile,cCposFixos, aNovaOrdem)

	Local aRet         := {{},{},{}} // { aCols , aHeader , Campos Editaveis }
	Local nX      	   := 0
	Local nCntFor      := 0
	Local cTitSX3      := ""
	Default cAliasTMP  := ""
	Default cNaoMostra := ""
	Default cNaoEdit   := ""
	Default nIndPosic  := 1
	Default cPosiciona := ""
	Default cChvWhile  := ".t."
	Default cCposFixos := ""
	Default aNovaOrdem := {}
	
	aAlias := FWSX3Util():GetAllFields( cAliasTMP )
	
	For nX := 1 To Len(aAlias)
		
		cCampo    := Alltrim( GetSX3Cache( aAlias[nX], "X3_CAMPO"))
		
		cParte    := Right( cCampo, 6 )
		
		lUsado    := X3USO( GetSX3Cache(cCampo, "X3_USADO") )
		
		lNivelOk  := cNivel >= GetSX3Cache( cCampo , "X3_NIVEL")

		If ( /* lUsado .And.*/ lNivelOk .And. !( cCampo +"," $ cNaoMostra) )  .Or. cCampo +"," $ cCposFixos
			cTitSX3   := iif( lAltInconv, OX001066K_AlteraDescricaoInconveniente(cCampo), retTitle(cCampo) )

			cPicture  := GetSX3Cache( cCampo , "X3_PICTURE")
			// Validação para montar a coluna Descrição com base no tamanho do campo Descrição da VST, pois o campo V00_DESCRI foi criado com 254 caracters, quando deveria ser 120 conforme o VST_DESINC
			If cCampo == "V00_DESCRI" 
				nTamanho  := GetSX3Cache( "VST_DESINC" , "X3_TAMANHO")
			Else
				nTamanho  := GetSX3Cache( cCampo , "X3_TAMANHO")
			EndIf
			nDecimal  := GetSX3Cache( cCampo , "X3_DECIMAL")
			cValid    := GetSX3Cache( cCampo , "X3_VALID"  )
			cUsado    := GetSX3Cache( cCampo , "X3_USADO"  )
			cTipo     := GetSX3Cache( cCampo , "X3_TIPO"   )
			cContexto := GetSX3Cache( cCampo , "X3_CONTEXT")
			cRelacao  := GetSX3Cache( cCampo , "X3_RELACAO")
			cVisual   := GetSX3Cache( cCampo , "X3_VISUAL" )
			cPriori   := GetSX3Cache( cCampo , "X3_PROPRI" )
		
			cF3       := If( cCampo =="VST_CODINC" , "VSL", GetSX3Cache(cCampo, "X3_F3") )

			aAdd( aRet[2], {  cTitSX3  ,;
							  cCampo   ,;
							  cPicture ,;
							  nTamanho ,;
							  nDecimal ,;
							  cValid   ,;
							  cUsado   ,;
							  cTipo    ,;
							  cF3      ,;
							  cContexto,;
							  X3CBOX() ,;
							  cRelacao })

			If ( cContexto != "V") .or. (cContexto == "V" .and. cVisual == "A")
				If cPriori == "U" .or. !(Alltrim( cCampo )+"," $ cNaoEdit)
					aAdd(aRet[3], cCampo ) // Campos Editaveis
				EndIf
			EndIf
		EndIf
	Next nX
	
	If !Empty( aNovaOrdem )

		aHeader := aClone( aRet[2] )

		aRet[2] := OA602073M_ReordenaItem( aHeader, aNovaOrdem )
	EndIf

	If !INCLUI
		dbSelectArea(cAliasTMP)
		dbSetOrder(nIndPosic)
		dbSeek( xFilial(cAliasTMP) + cPosiciona )
		While !Eof() .And. &(cChvWhile)
			AADD(aRet[1],Array(Len(aRet[2])+1))
			For nCntFor := 1 to Len(aRet[2])
				aRet[1][Len(aRet[1]),nCntFor] := IIf(aRet[2][nCntFor,10] # "V",FieldGet(FieldPos(aRet[2][nCntFor,2])),CriaVar(aRet[2][nCntFor,2]))
			Next
			aRet[1][Len(aRet[1]),Len(aRet[2])+1]:=.F.
			DbSelectArea(cAliasTMP)
			dbSkip()
		EndDo
	EndIf
	If Len( aRet[1] ) == 0
		aRet[1]:={Array(Len(aRet[2])+1)}
		aRet[1][1,Len(aRet[2])+1]:=.F.
		For nCntFor := 1 to Len(aRet[2])
			aRet[1][Len(aRet[1]),nCntFor]:=CriaVar(aRet[2][nCntFor,2],.t.)
		Next
	EndIf

Return aClone(aRet)

/*/{Protheus.doc} OA602021M_FLDVLDOK
Função executada na validação do campo
@type function
@version
@author Jessé Augusto
@since 17/11/2025
@param cAliasSelect, character, param_description
@param nOpc, numeric, param_description
@return variant, return_description
/*/
Function OA602021M_FLDVLDOK(cAliasSelect,nOpc)
	Local lRet       := .t.
	Local nPosV00    := 0
	Local nPosVST    := 0
	Local nCntFor    := 0
	Local nCntFor2   := 0
	Local lLimpaProd := .f.

	Do Case
		Case cAliasSelect == "V00"

			If ReadVar() == "M->V00_DESCRI"
				
				If Empty(M->V00_DESCRI)
					Return .T.
				EndIf

				OA602070M_AtualizaListaTarefas( oGetDadV00, oGetDadVST )
				 
				For nCntFor := 1 to len(oGetDadVST:aCols)
					If oGetDadVST:aCols[nCntFor,FG_POSVAR("VST_SEQTAR","aHeaderVST")] == oGetDadV00:aCols[oGetDadV00:nAt,FG_POSVAR("V00_SEQUEN","aHeaderV00")]
						oGetDadVST:aCols[nCntFor,FG_POSVAR("VST_DESINC","aHeaderVST")] := M->V00_DESCRI
						oGetDadVST:oBrowse:Refresh()
						For nCntFor2 := 1 to len(oGetDadV02:aCols)
							If oGetDadVST:aCols[nCntFor,FG_POSVAR("VST_SEQINC","aHeaderVST")] == oGetDadV02:aCols[nCntFor2,FG_POSVAR("V02_SEQINC","aHeaderV02")]
								oGetDadV02:aCols[nCntFor2,FG_POSVAR("V02_DESINC","aHeaderV02")] := M->V00_DESCRI
							EndIf
						Next
						For nCntFor2 := 1 to len(oGetDadV03:aCols)
							If oGetDadVST:aCols[nCntFor,FG_POSVAR("VST_SEQINC","aHeaderVST")] == oGetDadV03:aCols[nCntFor2,FG_POSVAR("V03_SEQINC","aHeaderV03")]
								oGetDadV03:aCols[nCntFor2,FG_POSVAR("V03_DESINC","aHeaderV03")] := M->V00_DESCRI
							EndIf
						Next
					EndIf
					
				Next
				oGetDadVST:oBrowse:Refresh()
				oGetDadV02:oBrowse:Refresh()
				oGetDadV03:oBrowse:Refresh()

			ElseIf ReadVar() == "M->V00_CODPRO"
				If !Empty(M->V00_CODPRO)
					DbSelectArea("VAI")
					DbSetOrder(1)
					If DbSeek(xFilial("VAI")+M->V00_CODPRO) .and. VAI->VAI_FUNPRO == "1" .and. Empty(VAI->VAI_DATDEM)
						DbSelectArea("VOE")
						DbSetOrder(1)
						If DbSeek(xFilial("VOE")+M->V00_CODPRO)
							oGetDadV00:aCols[oGetDadV00:nAt,FG_POSVAR("V00_CODPRO","aHeaderV00")] := M->V00_CODPRO
							oGetDadV00:aCols[oGetDadV00:nAt,FG_POSVAR("V00_NOMPRO","aHeaderV00")] := M->V00_NOMPRO := VAI->VAI_NOMTEC
						Else
							FMX_HELP( "OA6020211", STR0041, STR0042 ) // Produtivo sem escala! // Utilize um produtivo apto a esta a ação
							
							lRet := .f.
						EndIf
					Else
						FMX_HELP( "OA6020212", STR0043, STR0044 ) // Funcionário não produtivo! // Verifique se o Funcionário está apto a esta ação

						lRet := .f.
					EndIf
					If lRet
						lLimpaProd := .f.
						For nCntFor := 1 to len(oGetDadV03:aCols)
							If oGetDadV03:aCols[nCntFor,FG_POSVAR("V03_SEQTAR","aHeaderV03")] == M->V00_SEQUEN
								If Empty(oGetDadV03:aCols[nCntFor,FG_POSVAR("V03_CODPRO","aHeaderV03")])
									oGetDadV03:aCols[nCntFor,FG_POSVAR("V03_CODPRO","aHeaderV03")] := M->V00_CODPRO
									oGetDadV03:aCols[nCntFor,FG_POSVAR("V03_NOMPRO","aHeaderV03")] := M->V00_NOMPRO
								ElseIf oGetDadV03:aCols[nCntFor,FG_POSVAR("V03_CODPRO","aHeaderV03")] <> M->V00_CODPRO
									lLimpaProd := .t.
								EndIf
							EndIf
						Next
						If lLimpaProd
							
							FWAlertInfo( STR0045, STR0029 )

							oGetDadV00:aCols[oGetDadV00:nAt,FG_POSVAR("V00_CODPRO","aHeaderV00")] := M->V00_CODPRO := space(TamSX3("V00_CODPRO")[1])
							oGetDadV00:aCols[oGetDadV00:nAt,FG_POSVAR("V00_NOMPRO","aHeaderV00")] := M->V00_NOMPRO := ""
						EndIf
					EndIf
					oGetDadV03:oBrowse:Refresh()
				EndIf
			
			ElseIf ReadVar() == "M->V00_TEMINF"
				oGetDadV00:aCols[oGetDadV00:nAt,FG_POSVAR("V00_TEMINF","aHeaderV00")] := M->V00_TEMINF := OA602044M_TPO15(M->V00_TEMINF)
			Endif

		Case cAliasSelect == "V02"

			nVSTSEQINC := FG_POSVAR("VST_SEQINC","aHeaderVST")
			nV02SEQTAR := FG_POSVAR("V02_SEQTAR","aHeaderV02")
			nV02GRUITE := FG_POSVAR("V02_GRUITE","aHeaderV02")
			nV02SEQINC := FG_POSVAR("V02_SEQINC","aHeaderV02")
			nV02CODINC := FG_POSVAR("V02_CODINC","aHeaderV02")
			nV02CODITE := FG_POSVAR("V02_CODITE","aHeaderV02")
			nV02Tam    := Len(oGetDadV02:aHeader) + 1
			nV02LinAt  := oGetDadV02:nAt
				
			If ReadVar() == "M->V02_GRUITE"
				
				M->V02_GRUITE := PadR( M->V02_GRUITE, TamSX3("V02_GRUITE")[1])

				If Empty(oGetDadV02:aCols[oGetDadV02:nAt, nV02CODINC])
					DbSelectArea("SBM")
					DbSetOrder(1)
					If !DbSeek(xFilial("SBM")+M->V02_GRUITE)
						lRet := .f.
					EndIf
				EndIf
				
				cChave := oGetDadV02:aCols[nV02LinAt][nV02SEQINC] + M->V02_GRUITE + oGetDadV02:aCols[nV02LinAt][nV02CODITE]

				bSeek  := {|x| x[nV02SEQINC] + x[nV02GRUITE] + x[nV02CODITE] == cChave .And. !x[nV02Tam] }
				
				nPos := aSCan( oGetDadV02:aCols, bSeek )

				If nPos > 0 .and. (nPos <> oGetDadV02:nAt)
					FMX_HELP("OA6020220", STR0210, STR0211 ) // Os dados do produto estão duplicados // Verifique se os dados do produtos estão se repetindo
					Return .F.
				EndIf
				
				If lRet
					
					cSB1 := PadR(oGetDadV02:aCols[oGetDadV02:nAt, nV02CODITE],TamSX3("B1_CODITE")[1])

					If !Empty( cSB1 )
						
						SB1->(dbSetOrder(7)) // Grupo + Cod Item
						
						lRet := SB1->( MsSeek( xFilial("SB1") + M->V02_GRUITE +  cSB1 ) )

						If !lRet
							FMX_HELP("OA6020221", STR0212, STR0213 ) // O grupo e o produto utilizados não estão vinculado no cadastro de Produto // Verifique se o Grupo / Código do Produto estão devidamente relacionados no cadastro de Produto
						EndIf
						
					EndIf
				EndIf

				oGetDadV02:oBrowse:Refresh()

			ElseIf ReadVar() == "M->V02_CODITE"

				M->V02_CODITE := PadR( M->V02_CODITE, TamSX3("V02_CODITE")[1] )
				
				If Empty(oGetDadV02:aCols[oGetDadV02:nAt,FG_POSVAR("V02_CODINC","aHeaderV02")])
					
					cChave := oGetDadV02:aCols[nV02LinAt][nV02SEQINC] + oGetDadV02:aCols[nV02LinAt][nV02GRUITE] + M->V02_CODITE

					bSeek  := {|x| x[nV02SEQINC] + x[nV02GRUITE] + x[nV02CODITE] == cChave .And. !x[nV02Tam] }

					cGrupo := PadR(oGetDadV02:aCols[oGetDadV02:nAt, nV02GRUITE],TamSX3("V02_GRUITE")[1])

					nPos   := aSCan( oGetDadV02:aCols, bSeek )

					If !FG_POSSB1("M->V02_CODITE","SB1->B1_CODITE", "M->V02_GRUITE")

						FMX_HELP( "OA6020214", STR0048, STR0049 ) // Produto não cadastrado. // Utilize um produto válido

						lRet := .F.
					
					ElseIf ( SB1->B1_GRUPO != cGrupo ) .Or. nPos > 0 .And. nPos != nV02LinAt

						If SB1->B1_GRUPO != cGrupo

							FMX_HELP("OA6020222", STR0212, STR0213 ) // O grupo e o produto utilizados não estão vinculado no cadastro de Produto // Verifique se o Grupo / Código do Produto estão devidamente relacionados no cadastro de Produto
						Else
							FMX_HELP("OA6020223", STR0210, STR0211 ) // Os dados do produto estão duplicados // Verifique se os dados dos produtos estão se repetindo
						EndIf
						
						oGetDadV02:oBrowse:Refresh()

						lRet := .F.
					Else
						oGetDadV02:aCols[oGetDadV02:nAt,FG_POSVAR("V02_GRUITE","aHeaderV02")] := M->V02_GRUITE
						oGetDadV02:aCols[oGetDadV02:nAt,FG_POSVAR("V02_CODITE","aHeaderV02")] := M->V02_CODITE
						oGetDadV02:aCols[oGetDadV02:nAt,FG_POSVAR("V02_DESITE","aHeaderV02")] := M->V02_DESITE := SB1->B1_DESC
					EndIf
				EndIf

				oGetDadV03:oBrowse:Refresh()
				
			ElseIf ReadVar() == "M->V02_QTDITE"
				If Empty(oGetDadV02:aCols[oGetDadV02:nAt,FG_POSVAR("V02_CODINC","aHeaderV02")])
					If M->V02_QTDITE <= 0
						lRet := .f.
					Else
						oGetDadV02:aCols[oGetDadV02:nAt,FG_POSVAR("V02_QTDITE","aHeaderV02")] := M->V02_QTDITE
					EndIf
				EndIf

			ElseIf ReadVar() == "M->V02_SEQINC"
				
				M->V02_SEQINC := cTempRetF3
				
				If !Empty(cTempRetF3)
					cTempRetF3 := ""
				Else
					oGetDadV02:aCols[oGetDadV02:nAt,FG_POSVAR("V02_SEQINC","aHeaderV02")] := Space( TamSX3("V02_SEQINC")[1])
					oGetDadV02:aCols[oGetDadV02:nAt,FG_POSVAR("V02_SEQTAR","aHeaderV02")] := Space( TamSX3("V02_SEQTAR")[1])
					oGetDadV02:aCols[oGetDadV02:nAt,FG_POSVAR("V02_DESINC","aHeaderV02")] := Space( TamSX3("V02_DESINC")[1])
				EndIf
				
				If !Empty(M->V02_SEQINC)
					nPosVST := aScan(oGetDadVST:aCols, {|x| x[FG_POSVAR("VST_SEQINC","aHeaderVST")] == M->V02_SEQINC .and. Empty(x[FG_POSVAR("VST_CODINC","aHeaderVST")]) .and. !x[len(x)] })
					If nPosVST > 0
						oGetDadV02:aCols[oGetDadV02:nAt,FG_POSVAR("V02_SEQTAR","aHeaderV02")] := M->V02_SEQTAR := oGetDadVST:aCols[nPosVST,FG_POSVAR("VST_SEQTAR","aHeaderVST")]
					EndIf
				EndIf
				nPosVST := aScan(oGetDadVST:aCols, {|x| x[FG_POSVAR("VST_SEQTAR","aHeaderVST")] == M->V02_SEQTAR .and. x[FG_POSVAR("VST_SEQINC","aHeaderVST")] == M->V02_SEQINC .and. Empty(x[FG_POSVAR("VST_CODINC","aHeaderVST")]) .and. !x[len(x)] })
				If nPosVST <= 0 // Pesquisa
					
					FMX_HELP( "OA6020217", STR0053, STR0047 )  // Pacote/Inconveniente não encontrado para a Tarefa ou se trata de Pacote/Inconveniente Padrão que já possue Peças e Serviços! // "Utilize uma Tarefa válida
					lRet := .f.
				Else
					oGetDadV02:aCols[oGetDadV02:nAt,FG_POSVAR("V02_SEQINC","aHeaderV02")] := M->V02_SEQINC
					oGetDadV02:aCols[oGetDadV02:nAt,FG_POSVAR("V02_GRUINC","aHeaderV02")] := M->V02_GRUINC := ""
					oGetDadV02:aCols[oGetDadV02:nAt,FG_POSVAR("V02_CODINC","aHeaderV02")] := M->V02_CODINC := ""
					oGetDadV02:aCols[oGetDadV02:nAt,FG_POSVAR("V02_DESINC","aHeaderV02")] := M->V02_DESINC := oGetDadVST:aCols[nPosVST,FG_POSVAR("VST_DESINC","aHeaderVST")]
				EndIf
			EndIf

			If lRet
				If Empty(M->V02_SEQINC)
					OA602033M_INCSEQ("M->V02_SEQINC",.f.)
					oGetDadV02:aCols[oGetDadV02:nAt,FG_POSVAR("V02_SEQINC","aHeaderV02")] := M->V02_SEQINC
					nPosVST := aScan(oGetDadVST:aCols, {|x| x[FG_POSVAR("VST_SEQTAR","aHeaderVST")] == M->V02_SEQTAR .and. x[FG_POSVAR("VST_SEQINC","aHeaderVST")] == M->V02_SEQINC .and. Empty(x[FG_POSVAR("VST_CODINC","aHeaderVST")]) .and. !x[len(x)] })
					If nPosVST > 0
						oGetDadV02:aCols[oGetDadV02:nAt,FG_POSVAR("V02_GRUINC","aHeaderV02")] := M->V02_GRUINC := oGetDadVST:aCols[nPosVST,FG_POSVAR("VST_GRUINC","aHeaderVST")]
						oGetDadV02:aCols[oGetDadV02:nAt,FG_POSVAR("V02_CODINC","aHeaderV02")] := M->V02_CODINC := oGetDadVST:aCols[nPosVST,FG_POSVAR("VST_CODINC","aHeaderVST")]
						oGetDadV02:aCols[oGetDadV02:nAt,FG_POSVAR("V02_DESINC","aHeaderV02")] := M->V02_DESINC := oGetDadVST:aCols[nPosVST,FG_POSVAR("VST_DESINC","aHeaderVST")]
					Else
						oGetDadV02:aCols[oGetDadV02:nAt,FG_POSVAR("V02_GRUINC","aHeaderV02")] := M->V02_GRUINC := ""
						oGetDadV02:aCols[oGetDadV02:nAt,FG_POSVAR("V02_CODINC","aHeaderV02")] := M->V02_CODINC := ""
						oGetDadV02:aCols[oGetDadV02:nAt,FG_POSVAR("V02_DESINC","aHeaderV02")] := M->V02_DESINC := ""
					EndIf
				EndIf
				oGetDadV02:oBrowse:Refresh()
			EndIf

		Case cAliasSelect == "V03"

			If ReadVar() == "M->V03_CODPRO"
				If !Empty(M->V03_CODPRO)
					DbSelectArea("VAI")
					DbSetOrder(1)
					If DbSeek(xFilial("VAI")+M->V03_CODPRO) .and. VAI->VAI_FUNPRO == "1" .and. Empty(VAI->VAI_DATDEM)
						DbSelectArea("VOE")
						DbSetOrder(1)
						If DbSeek(xFilial("VOE")+M->V03_CODPRO)
							oGetDadV03:aCols[oGetDadV03:nAt,FG_POSVAR("V03_CODPRO","aHeaderV03")] := M->V03_CODPRO
							oGetDadV03:aCols[oGetDadV03:nAt,FG_POSVAR("V03_NOMPRO","aHeaderV03")] := M->V03_NOMPRO := VAI->VAI_NOMTEC
							nPosV00 := aScan(oGetDadV00:aCols, {|x| x[1] == oGetDadV03:aCols[oGetDadV03:nAt,FG_POSVAR("V03_SEQTAR","aHeaderV03")] .and. !x[len(x)] })
							If nPosV00 > 0 .and. oGetDadV00:aCols[nPosV00,FG_POSVAR("V00_CODPRO","aHeaderV00")] <> M->V03_CODPRO
								oGetDadV00:aCols[nPosV00,FG_POSVAR("V00_CODPRO","aHeaderV00")] := space(TamSX3("V00_CODPRO")[1])
								oGetDadV00:aCols[nPosV00,FG_POSVAR("V00_NOMPRO","aHeaderV00")] := ""
							EndIf
						Else
							FMX_HELP( "OA6020218", STR0041, STR0042 ) // Produtivo sem escala! // Utilize um produtivo apto a esta a ação
							lRet := .f.
						EndIf
					Else
						FMX_HELP( "OA6020219", STR0043, STR0044 ) // Funcionário não produtivo! // Verifique se o Funcionário está apto a esta ação
						lRet := .f.
					EndIf
				EndIf

			ElseIf ReadVar() == "M->V03_CODSER"
				DbSelectArea("VO6")
				dbSetOrder(3)
				if !VO6->(dbSeek(xFilial("VO6")+FG_MARSRV(M->VSO_CODMAR,M->V03_CODSER)+M->V03_GRUSER+M->V03_CODSER))
					FMX_HELP( "OA60202110", STR0055, STR0056 )  // Serviço não Cadastrado! // Utilize um Serviço válido
					lRet := .f.
				Else
					For nCntFor := 1 to len(oGetDadV03:aCols)
						If nCntFor <> oGetDadV03:nAt .and. !oGetDadV03:aCols[nCntFor,len(oGetDadV03:aCols[nCntFor])]
							If M->V03_CODSER == oGetDadV03:aCols[nCntFor,FG_POSVAR("V03_CODSER","aHeaderV03")]
								FMX_HELP( "OA60202111", STR0057, STR0056 ) // Serviço já existente no Agendamento! // Utilize um Serviço válido
								lRet := .f.
								Exit
							EndIf
						EndIf
					Next
					If lRet
						oGetDadV03:aCols[oGetDadV03:nAt,FG_POSVAR("V03_TEMPAD","aHeaderV03")] := M->V03_TEMPAD := VO6->VO6_TEMFAB
						oGetDadV03:aCols[oGetDadV03:nAt,FG_POSVAR("V03_DESSER","aHeaderV03")] := M->V03_DESSER := VO6->VO6_DESSER
					EndIf
				endif

			ElseIf ReadVar() == "M->V03_SEQINC"
				If !Empty(cTempRetF3)
					M->V03_SEQINC := cTempRetF3
					cTempRetF3 := ""
				EndIf
				If Empty(M->V03_SEQTAR) .and. !Empty(M->V03_SEQINC)
					nPosVST := aScan(oGetDadVST:aCols, {|x| x[FG_POSVAR("VST_SEQINC","aHeaderVST")] == M->V03_SEQINC .and. Empty(x[FG_POSVAR("VST_CODINC","aHeaderVST")]) .and. !x[len(x)] })
					If nPosVST > 0
						oGetDadV03:aCols[oGetDadV03:nAt,FG_POSVAR("V03_SEQTAR","aHeaderV03")] := M->V03_SEQTAR := oGetDadVST:aCols[nPosVST,FG_POSVAR("VST_SEQTAR","aHeaderVST")]
					EndIf
				EndIf
				nPosVST := aScan(oGetDadVST:aCols, {|x| x[FG_POSVAR("VST_SEQTAR","aHeaderVST")] == M->V03_SEQTAR .and. x[FG_POSVAR("VST_SEQINC","aHeaderVST")] == M->V03_SEQINC .and. Empty(x[FG_POSVAR("VST_CODINC","aHeaderVST")]) .and. !x[len(x)] })
				If nPosVST <= 0 // Pesquisa
					
					FMX_HELP( "OA60202114", STR0053, STR0047 )//Pacote/Inconveniente não encontrado para a Tarefa ou se trata de Pacote/Inconveniente Padrão que já possue Peças e Serviços! // "Utilize uma Tarefa válida

					lRet := .f.
				Else
					oGetDadV03:aCols[oGetDadV03:nAt,FG_POSVAR("V03_SEQINC","aHeaderV03")] := M->V03_SEQINC
					oGetDadV03:aCols[oGetDadV03:nAt,FG_POSVAR("V03_GRUINC","aHeaderV03")] := M->V03_GRUINC := ""
					oGetDadV03:aCols[oGetDadV03:nAt,FG_POSVAR("V03_CODINC","aHeaderV03")] := M->V03_CODINC := ""
					oGetDadV03:aCols[oGetDadV03:nAt,FG_POSVAR("V03_DESINC","aHeaderV03")] := M->V03_DESINC := oGetDadVST:aCols[nPosVST,FG_POSVAR("VST_DESINC","aHeaderVST")]
				EndIf
			 
			ElseIf ReadVar() == "M->V03_GRUSER"
				
				VO6->(dbSetOrder(3))
				
				M->V03_GRUSER := PadR( M->V03_GRUSER ,TamSX3("V03_GRUSER")[1] )
				M->VS4_GRUSER := M->V03_GRUSER 									// Manter a compatibilidade com o SXB V61 - Consulta Tabela de Servicos VO6

				cIdServ       := If( Empty(M->V03_CODSER), "", M->V03_CODSER )
				
				lRet 		  := VO6->(dbSeek( xFilial("VO6") + M->(VSO_CODMAR + V03_GRUSER) + cIdServ))

				If !lRet
					FMX_HELP("OA6020225", STR0214, STR0215 ) // Os dados utilizados não foram encontrados na Tabela de Serviços // Utilize dados previamente cadastrados na Tabela de Serviços
				EndIf
			EndIf

			If lRet
				If Empty(M->V03_SEQINC)
					OA602033M_INCSEQ("M->V03_SEQINC",.f.)
					oGetDadV03:aCols[oGetDadV03:nAt,FG_POSVAR("V03_SEQINC","aHeaderV03")] := M->V03_SEQINC
					nPosVST := aScan(oGetDadVST:aCols, {|x| x[FG_POSVAR("VST_SEQTAR","aHeaderVST")] == M->V03_SEQTAR .and. x[FG_POSVAR("VST_SEQINC","aHeaderVST")] == M->V03_SEQINC .and. Empty(x[FG_POSVAR("VST_CODINC","aHeaderVST")]) .and. !x[len(x)] })
					If nPosVST > 0
						oGetDadV03:aCols[oGetDadV03:nAt,FG_POSVAR("V03_GRUINC","aHeaderV03")] := M->V03_GRUINC := oGetDadVST:aCols[nPosVST,FG_POSVAR("VST_GRUINC","aHeaderVST")]
						oGetDadV03:aCols[oGetDadV03:nAt,FG_POSVAR("V03_CODINC","aHeaderV03")] := M->V03_CODINC := oGetDadVST:aCols[nPosVST,FG_POSVAR("VST_CODINC","aHeaderVST")]
						oGetDadV03:aCols[oGetDadV03:nAt,FG_POSVAR("V03_DESINC","aHeaderV03")] := M->V03_DESINC := oGetDadVST:aCols[nPosVST,FG_POSVAR("VST_DESINC","aHeaderVST")]
					Else
						oGetDadV03:aCols[oGetDadV03:nAt,FG_POSVAR("V03_GRUINC","aHeaderV03")] := M->V03_GRUINC := ""
						oGetDadV03:aCols[oGetDadV03:nAt,FG_POSVAR("V03_CODINC","aHeaderV03")] := M->V03_CODINC := ""
						oGetDadV03:aCols[oGetDadV03:nAt,FG_POSVAR("V03_DESINC","aHeaderV03")] := M->V03_DESINC := ""
					EndIf
				EndIf
				oGetDadV03:oBrowse:Refresh()
			EndIf

	EndCase

	OA602038M_TOTHORAS(.t.)

Return lRet

/*/{Protheus.doc} OA602022M_VLDDEL
Função executada para validar a exclusão de uma linha do aCols.
@type function
@version
@author Jessé Augusto
@since 17/11/2025
@param cAliasSelect, character, param_description
@param nOpc, numeric, param_description
@param lClonar, logical, param_description
@return variant, return_description
/*/
Function OA602022M_VLDDEL(cAliasSelect,nOpc,lClonar)

	Local lOk         := .f.
	Local nX 	      := 0
	Local nCntFor     := 0
	Local cAux        := ""
	Local lAux        := .f.
	Local lTudoOk 	  := .T.
	Local nV00SEQUEN  := FG_POSVAR("V00_SEQUEN","aHeaderV00")
	Local nVSTSEQTAR  := FG_POSVAR("VST_SEQTAR","aHeaderVST")
	Local nVSTSEQINC  := FG_POSVAR("VST_SEQINC","aHeaderVST")
	Local nV02SEQTAR  := FG_POSVAR("V02_SEQTAR","aHeaderV02")
	Local nV02SEQINC  := FG_POSVAR("V02_SEQINC","aHeaderV02")
	Local nV02CODINC  := FG_POSVAR("V02_CODINC","aHeaderV02")
	Local nV03SEQTAR  := FG_POSVAR("V03_SEQTAR","aHeaderV03")
	Local nV03GRUSER  := FG_POSVAR("V03_GRUSER","aHeaderV03")
	Local nV03CODSER  := FG_POSVAR("V03_CODSER","aHeaderV03")
	Local nV03SEQINC  := FG_POSVAR("V03_SEQINC","aHeaderV03")
	Local nV03GRUINC  := FG_POSVAR("V03_GRUINC","aHeaderV03")
	Local nV03CODINC  := FG_POSVAR("V03_CODINC","aHeaderV03")

	If M->VSO_STATUS != "1"
		Return .f.
	EndIf
	
	Do Case
		Case cAliasSelect == "V00"
			If oGetDadV00:aCols[oGetDadV00:nAt,len(oGetDadV00:aCols[oGetDadV00:nAt])]
				
				lOk := FWAlertYesNo(STR0058, STR0029) // Deseja REINCLUIR a Tarefa com todos os Pacotes/Inconvenientes, Peças e Serviços relacionados? // Atenção
			Else
				lOk := FWAlertYesNo(STR0059, STR0029) // Deseja EXCLUIR a Tarefa com todos os Pacotes/Inconvenientes, Peças e Serviços relacionados? // Atenção
			EndIf
			If lOk
				cAux := oGetDadV00:aCols[oGetDadV00:nAt,nV00SEQUEN]
				lAux := !oGetDadV00:aCols[oGetDadV00:nAt,len(oGetDadV00:aCols[oGetDadV00:nAt])]
				oGetDadV00:aCols[oGetDadV00:nAt,len(oGetDadV00:aCols[oGetDadV00:nAt])] := lAux
				oGetDadV00:oBrowse:Refresh()

				For nCntFor := 1 to len(oGetDadVST:aCols)
					If oGetDadVST:aCols[nCntFor,nVSTSEQTAR] == cAux
						oGetDadVST:aCols[nCntFor,len(oGetDadVST:aCols[nCntFor])] := lAux
					EndIf
				Next
				oGetDadVST:oBrowse:Refresh()
				For nCntFor := 1 to len(oGetDadV02:aCols)
					If oGetDadV02:aCols[nCntFor,nV02SEQTAR] == cAux
						oGetDadV02:aCols[nCntFor,len(oGetDadV02:aCols[nCntFor])] := lAux
					EndIf
				Next
				oGetDadV02:oBrowse:Refresh()
				For nCntFor := 1 to len(oGetDadV03:aCols)
					If oGetDadV03:aCols[nCntFor,nV03SEQTAR] == cAux
						oGetDadV03:aCols[nCntFor,len(oGetDadV03:aCols[nCntFor])] := lAux
					EndIf
				Next
				oGetDadV03:oBrowse:Refresh()
			EndIf

		Case cAliasSelect == "VST"

			If oGetDadVST:aCols[oGetDadVST:nAt,len(oGetDadVST:aCols[oGetDadVST:nAt])]
				
				nCntFor    := aScan(oGetDadV00:aCols, {|x| x[nV00SEQUEN] == oGetDadVST:aCols[oGetDadVST:nAt,nVSTSEQTAR] })
				nVSTGRUINC := FG_POSVAR("VST_GRUINC","aHeaderVST")
				nVSTCODINC := FG_POSVAR("VST_CODINC","aHeaderVST")
				nTamVST	   := Len(oGetDadVST:aHeader) + 1
				cSeek     := oGetDadVST:aCols[oGetDadVST:nAt,nVSTGRUINC] + oGetDadVST:aCols[oGetDadVST:nAt,nVSTCODINC]
				
				lRestVST   := !Empty( cSeek )
				
				lRestV00   := nCntFor > 0 .and. !oGetDadV00:aCols[nCntFor,Len(oGetDadV00:aCols[nCntFor])]

				If lRestV00 .Or. lRestVST
					
					If lRestVST .And. aSCan(oGetDadVST:aCols,{|x| x[nVSTGRUINC] + x[nVSTCODINC] == cSeek .And. !x[nTamVST] }) > 0
						
						FMX_HELP("OA6020226", STR0216, STR0217 ) // Não é permitida recuperação desta linha pois causaria duplicidade de registro // Utilize uma linha cuja recuperação não ira gerar duplicidade
					Else
						lOk := FWAlertYesNo( STR0062, STR0029 ) // Deseja REINCLUIR o Pacote/Inconveniente com todas as Peças e Serviços relacionados? // Atenção
					EndIf
				Else
					FWAlertWarning( STR0063, STR0029) // Impossível continuar. A Tarefa relacionada ao Pacote/Inconveniente está EXCLUIDA! // Atenção
				EndIf
			Else
					lOk := FWAlertYesNo( STR0064, STR0029 )  // Deseja EXCLUIR o Pacote/Inconveniente com todas as Peças e Serviços relacionados? // Atenção
			EndIf

			If lOk
				cAux := oGetDadVST:aCols[oGetDadVST:nAt,nVSTSEQINC]
				lAux := !oGetDadVST:aCols[oGetDadVST:nAt,len(oGetDadVST:aCols[oGetDadVST:nAt])]
				oGetDadVST:aCols[oGetDadVST:nAt,len(oGetDadVST:aCols[oGetDadVST:nAt])] := lAux

				oGetDadVST:oBrowse:Refresh()
				For nCntFor := 1 to len(oGetDadV02:aCols)
					If oGetDadV02:aCols[nCntFor,nV02SEQINC] == cAux
						oGetDadV02:aCols[nCntFor,len(oGetDadV02:aCols[nCntFor])] := lAux
					EndIf
				Next
				oGetDadV02:oBrowse:Refresh()
				For nCntFor := 1 to len(oGetDadV03:aCols)
					If oGetDadV03:aCols[nCntFor,nV03SEQINC] == cAux
						oGetDadV03:aCols[nCntFor,len(oGetDadV03:aCols[nCntFor])] := lAux
					EndIf
				Next
				oGetDadV03:oBrowse:Refresh()
			EndIf

		Case cAliasSelect == "V02"
			
			nV02SEQINC := FG_POSVAR("V02_SEQINC","aHeaderV02")
	        nV02GRUITE := FG_POSVAR("V02_GRUITE","aHeaderV02")
			nV02CODITE := FG_POSVAR("V02_CODITE","aHeaderV02")
	        nV02QTDITE := FG_POSVAR("V02_QTDITE","aHeaderV02")

			nTamV02    := Len(oGetDadV02:aHeader) + 1
			nTamVST    := Len(oGetDadVST:aHeader) + 1
			nAtV02     := oGetDadV02:nAt
				
			lVazio     := Empty( oGetDadV02:aCols[nAtV02][nV02SEQINC] + oGetDadV02:aCols[nAtV02][nV02GRUITE] + oGetDadV02:aCols[nAtV02][nV02CODITE] )
			
			lDelOk     := oGetDadV02:aCols[nAtV02][nTamV02]

			If lVazio
				Return .F.
			EndIf

			If !Empty(oGetDadV02:aCols[nAtV02,nV02CODINC])
			
				FWAlertWarning( STR0066, STR0029) // Impossível continuar. O Item está relacionado com Pacote/Inconveniente Padrão! // Atenção
			Else
				lDelOk  := oGetDadV02:aCols[nAtV02,nTamV02]
				
				If lDelOk
					
					// Verifica a possibilidade da presença de itens repetidos no ato da recuperação do item na grid
					cSeek := oGetDadV02:aCols[nAtV02][nV02SEQINC] + oGetDadV02:aCols[nAtV02][nV02GRUITE] + oGetDadV02:aCols[nAtV02][nV02CODITE]
					
					For nX := 1 To Len(oGetDadV02:aCols)
				
						cConteudo := oGetDadV02:aCols[nX][nV02SEQINC] + oGetDadV02:aCols[nX][nV02GRUITE] + oGetDadV02:aCols[nX][nV02CODITE]
						
						If nX != nAtV02 .And. !oGetDadV02:aCols[nX][nTamV02] .And. cConteudo == cSeek

							lTudoOk := .F.; Exit
						EndIf

					Next nX
					
					If !lTudoOk
						FWAlertWarning( STR0216, STR0029) // Não é permitida recuperação desta linha pois causaria duplicidade de registro // "Atenção"
					Else
						nCntFor := aSCan(oGetDadVST:aCols, {|x| x[nVSTSEQINC] == oGetDadV02:aCols[nAtV02,nV02SEQINC] })
					
						lOk     := nCntFor > 0 .And. !oGetDadVST:aCols[nCntFor,nTamVST]

						If !lOk
							FWAlertWarning( STR0067, STR0029) // Impossível continuar. O Pacote/Inconveniente relacionado o Item está EXCLUIDO! // Atenção
						EndIf
					EndIf
				Else
					lOk := .T.
				EndIf

				If lOk
					oGetDadV02:aCols[nAtV02, nTamV02] := !oGetDadV02:aCols[nAtV02, nTamV02]
					oGetDadV02:oBrowse:Refresh()
				EndIf
			EndIf

		Case cAliasSelect == "V03"

			If !Empty(oGetDadV03:aCols[oGetDadV03:nAt,nV03CODINC])

				FWAlertWarning( STR0068, STR0029) // Impossível continuar. O Serviço está relacionado com Pacote/Inconveniente Padrão! // Atenção
			Else
				If oGetDadV03:aCols[oGetDadV03:nAt,len(oGetDadV03:aCols[oGetDadV03:nAt])]
					
					nLin  	 := oGetDadV03:nAt
					nTamV03  := Len(oGetDadV03:aHeader) + 1
					nTamVST  := Len(oGetDadVST:aHeader) + 1
					
					cChave   := oGetDadV03:aCols[nLin,nV03SEQINC] + oGetDadV03:aCols[nLin,nV03GRUSER] + oGetDadV03:aCols[nLin,nV03CODSER]
					cGrIdPac := oGetDadV03:aCols[nLin,nV03GRUINC] + oGetDadV03:aCols[nLin,nV03CODINC]
					
					cSeek    := cChave + cGrIdPac

					bBuscar  := {|x| x[nV03SEQINC] + x[nV03GRUSER] + x[nV03CODSER] + x[nV03GRUINC] + x[nV03CODINC] == cSeek .And. !x[nTamV03] }
					
					lRestDel := aSCan(oGetDadV03:aCols, bBuscar ) <= 0
					
					lRestV03 := !Empty(cChave) .And. Empty( cGrIdPac )

					nCntFor  := aScan(oGetDadVST:aCols, {|x| x[nVSTSEQINC] == oGetDadV03:aCols[nLin,nV03SEQINC] })

					lRestVST := nCntFor > 0 .And. !oGetDadVST:aCols[nCntFor,nTamVST]

					// If !lRestVST .Or. ( lRestV03 .And. !lRestDel )

					// 	If !lRestVST
							
					// 		FWAlertWarning( STR0069, STR0029) // Impossível continuar. O Pacote/Inconveniente relacionado ao Serviço está EXCLUIDO! // Atenção
					// 	Else
							
					// 		FWAlertWarning( STR0216, STR0029) // Não é permitida recuperação desta linha pois causaria duplicidade de registro
					// 	EndIf
					// Else
					// 	lOk := .T.
					// EndIf
				Else
					lOk := .t.
				EndIf

				If lOk
					oGetDadV03:aCols[oGetDadV03:nAt,len(oGetDadV03:aCols[oGetDadV03:nAt])] := !oGetDadV03:aCols[oGetDadV03:nAt,len(oGetDadV03:aCols[oGetDadV03:nAt])]
					oGetDadV03:oBrowse:Refresh()
				EndIf
			EndIf
	EndCase

	OA602038M_TOTHORAS(.t.)

Return .f.

/*/{Protheus.doc} OA602023M_VLDLINHA
Função executada para validar o contexto da linha atual do aCols.
@type function
@version
@author Jessé Augusto
@since 17/11/2025
@param cAliasSelect, character, param_description
@param nOpc, numeric, param_description
@return variant, return_description
/*/
Function OA602023M_VLDLINHA(cAliasSelect,nOpc)

	Local lRet    := .T.

	Do Case
	
		Case cAliasSelect == "V00"

		Case cAliasSelect == "VST"

		Case cAliasSelect == "V02"

			nV02SEQINC := FG_POSVAR("V02_SEQINC","aHeaderV02")
	        nV02GRUITE := FG_POSVAR("V02_GRUITE","aHeaderV02")
			nV02CODITE := FG_POSVAR("V02_CODITE","aHeaderV02")
	        nV02QTDITE := FG_POSVAR("V02_QTDITE","aHeaderV02")

			nTamV02    := Len(oGetDadV02:aHeader) + 1
			nTamVST    := Len(oGetDadVST:aHeader) + 1
			nAtV02     := oGetDadV02:nAt
				
			cSEQINC    := oGetDadV02:aCols[nAtV02][nV02SEQINC]
			cGRUITE    := oGetDadV02:aCols[nAtV02][nV02GRUITE]
			cCODITE    := oGetDadV02:aCols[nAtV02][nV02CODITE]
			
			lRet 	   := !Empty( cSEQINC ) .And. !Empty( cGRUITE ) .And. !Empty( cCODITE )
			
			If !lRet
				
				FMX_HELP("OA6020227", STR0218, STR0219 ) // Preencha os campos Sequencial, Grupo Item e Código Item // Certifique-se de que o campos Sequencial, Grupo Item e Código Item foram preenchidos
			EndIf

		Case cAliasSelect == "V03"

	EndCase

Return lRet
/*/{Protheus.doc} OA602024M_SELFOLDER
Define a seleção da folder a ser ativada
@type function
@version
@author Jessé Augusto
@since 17/11/2025
@param nFldOrigem, numeric, param_description
@param nFldDestino, numeric, param_description
@param nOpc, numeric, param_description
@return variant, return_description
/*/
Function OA602024M_SELFOLDER( nFldOrigem , nFldDestino , nOpc )

	Do Case
		Case nFldDestino == 1 // Tarefas / Reclamacoes / Solicitacoes do Cliente
			FG_MEMVAR( oGetDadV00:aHeader , oGetDadV00:aCols , oGetDadV00:nAt )

		Case nFldDestino == 3 // Inconvenientes
			FG_MEMVAR( oGetDadVST:aHeader , oGetDadVST:aCols , oGetDadVST:nAt )

		Case nFldDestino == 4 // Pecas
			FG_MEMVAR( oGetDadV02:aHeader , oGetDadV02:aCols , oGetDadV02:nAt )

		Case nFldDestino == 5 // Servicos
			FG_MEMVAR( oGetDadV03:aHeader , oGetDadV03:aCols , oGetDadV03:nAt )
			M->VS4_GRUSER := M->V03_GRUSER // Manter a compatibilidade com o SXB V61 - Consulta Tabela de Servicos VO6
	EndCase

Return .T.

/*/{Protheus.doc} OA602025M_GRAVACAO_FINAL
Gravação final
@type function
@version
@author Jessé Augusto
@since 17/11/2025
@param nOpc, numeric, param_description
@param lClonar, logical, param_description
@return variant, return_description
/*/
Static Function OA602025M_GRAVACAO_FINAL(nOpc,lClonar)

	Local nCntFor       := 0
	Local aMotCancel    := {}
	Local cBkpFilAnt    := cFilAnt // Salva cFilAnt
	Local lAgeAlterado  := .f.
	Local cFilVSO       := ""
	Local cNumVSO       := ""
	Local cQuery        := ""
	Local nRecV00       := 0
	Local nV00SEQUEN    := FG_POSVAR("V00_SEQUEN","aHeaderV00")
	local lDiarioOficina := FindFunction("OA5480062_RegistraEventoDiarioOficina")
	local lReagendamento := .f.
	Local cDataHoraAnterior := ""

	Default lClonar := .f.

	If lClonar
		nOpc := 3 // Incluir
	EndIf

	If nOpc == 2 // Visualizar
		return
	Endif

	cFilAnt := cFilSelect // Filial Selecionada

	If nOpc == 5 // Cancelar

		aMotCancel := OFA210MOT("000003","3","","",.f.) // Filtro da consulta do motivo
	EndIf

	Begin Transaction

	If nOpc == 3

		// Gravação da VSO - Agendamento
		DbSelectArea("VSO")
		RecLock("VSO",.T.)
		FG_GRAVAR("VSO")
		VSO->VSO_FILIAL := xFilial("VSO")
		VSO->VSO_NUMIDE := GetSXENum("VSO","VSO_NUMIDE")
		ConfirmSX8()
		MSMM(VSO->VSO_OBSMEM,TamSx3("VSO_OBSERV")[1],,&(aMemos[1][2]),1,,,"VSO","VSO_OBSMEM")
		MsUnlock()

		cFilVSO := VSO->VSO_FILIAL
		cNumVSO := VSO->VSO_NUMIDE

		// Gravação da VST
		OM420GRAVA( oGetDadVST:aCols , oGetDadVST:aHeader , "3" , VSO->VSO_NUMIDE , VSO->VSO_CODMAR , VSO->VSO_GETKEY ) // GRAVAR INCONVENIENTE

		// Gravação da V00 - Tarefas / Reclamações
		DbSelectArea("V00")
		For nCntFor := 1 to Len(oGetDadV00:aCols)
			If !oGetDadV00:aCols[nCntFor,Len(aHeaderV00)+1] .and. !Empty(oGetDadV00:aCols[nCntFor, FG_POSVAR("V00_DESCRI", "aHeaderV00")])
				RecLock("V00",.T.)
				FG_GRAVAR("V00",oGetDadV00:aCols,aHeaderV00,nCntFor)
				V00->V00_FILIAL := xFilial("V00")
				V00->V00_CODIGO := GetSxeNum("V00","V00_CODIGO")
				ConfirmSX8()
				V00->V00_CODAGE := VSO->VSO_NUMIDE
				V00->V00_SEQUEN := StrZero(nCntFor,3)
				MsUnLock()
			Endif
		Next

		// Gravação da V02 - Pecas
		DbSelectArea("V02")
		For nCntFor := 1 to Len(oGetDadV02:aCols)
			If !oGetDadV02:aCols[nCntFor,len(aHeaderV02)+1] .and. !Empty(oGetDadV02:aCols[nCntFor,FG_POSVAR("V02_GRUITE","aHeaderV02")])
				RecLock("V02",.T.)
				FG_GRAVAR("V02",oGetDadV02:aCols,aHeaderV02,nCntFor)
				V02->V02_FILIAL := xFilial("V02")
				V02->V02_CODAGE := VSO->VSO_NUMIDE
				MsUnLock()
			Endif
		Next

		// Gravação da V04 - Agendamento x Planejamento
		DbSelectArea("V04")
		RecLock("V04",.T.)
		V04->V04_FILIAL := xFilial("V04")
		V04->V04_CODIGO := GetSXENum("V04","V04_CODIGO")
		V04->V04_CODAGE := VSO->VSO_NUMIDE
		V04->V04_ABOX   := VSO->VSO_NUMBOX
		V04->V04_ADTINI := VSO->VSO_DATAGE
		V04->V04_AHRINI := VSO->VSO_HORAGE
		V04->V04_ADTFIN := VSO->VSO_DATFIN
		V04->V04_AHRFIN := right(strzero(VSO->VSO_HORFIN,5),4)
		V04->V04_PBOX   := VSO->VSO_NUMBOX
		V04->V04_PDTINI := VSO->VSO_DATAGE
		V04->V04_PHRINI := VSO->VSO_HORAGE
		V04->V04_PDTFIN := VSO->VSO_DATFIN
		V04->V04_PHRFIN := right(strzero(VSO->VSO_HORFIN,5),4)
		ConfirmSX8()
		MsUnlock()

		// Gravação da V03 - Servicos do agendamento e V05 - Servicos do Planejamento
		For nCntFor := 1 to Len(oGetDadV03:aCols)
			If !oGetDadV03:aCols[nCntFor,len(aHeaderV03)+1] .and. !Empty(oGetDadV03:aCols[nCntFor,FG_POSVAR("V03_GRUSER","aHeaderV03")])
				DbSelectArea("V03")
				RecLock("V03",.T.)
				FG_GRAVAR("V03",oGetDadV03:aCols,aHeaderV03,nCntFor)
				V03->V03_FILIAL := xFilial("V03")
				V03->V03_CODAGE := VSO->VSO_NUMIDE
				MsUnLock()
				DbSelectArea("V05")
				RecLock("V05",.T.)
				V05->V05_FILIAL := xFilial("V03")
				V05->V05_CODIGO := GetSxeNum("V05","V05_CODIGO")
				ConfirmSX8()
				V05->V05_CODPAI := V04->V04_CODIGO
				V05->V05_GRUSER := V03->V03_GRUSER
				V05->V05_CODSER := V03->V03_CODSER
				V05->V05_TIPSER := V03->V03_TIPSER
				V05->V05_SEQINC := V03->V03_SEQINC
				V05->V05_GRUINC := V03->V03_GRUINC
				V05->V05_CODINC := V03->V03_CODINC
				V05->V05_CODPRO := V03->V03_CODPRO
				V05->V05_TEMPAD := V03->V03_TEMPAD
				MsUnLock()
			Endif
		Next
		if lDiarioOficina
			OA5480062_RegistraEventoDiarioOficina(VSO->VSO_NUMIDE, "001") //001 – INCLUSAO DO AGENDAMENTO
		endif
	ElseIf nOpc == 4 // Alterar

		cFilVSO := VSO->VSO_FILIAL
		cNumVSO := VSO->VSO_NUMIDE

		// Verificar se houve alteração na data/hora do agendamento para possível reprocessamento na Control Tower
		If FindFunction("OM350005N_VerificaReagendamento") .And. FindFunction("OM350004N_ImplementacaoControlTower")

			lAgeAlterado	:= OM350005N_VerificaReagendamento( .T., ;
								VSO->VSO_DATAGE, VSO->VSO_HORAGE, ;
								M->VSO_DATAGE, M->VSO_HORAGE, ;
								@cDataHoraAnterior )
		EndIf 

		if VSO->VSO_DATAGE <> M->VSO_DATAGE .OR. VSO->VSO_HORAGE <> M->VSO_HORAGE
			lReagendamento := .t.

			if lDiarioOficina
				OA5480062_RegistraEventoDiarioOficina(VSO->VSO_NUMIDE, "002") // 002 – ALTERACAO DO AGENDAMENTO
			endif
		endif

		// Gravação da VSO - Agendamento
		DbSelectArea("VSO")
		RecLock("VSO",.F.)
		FG_GRAVAR("VSO")
		If ExistBlock("OA602AGA")
			ExecBlock("OA602AGA",.F.,.F.,{ nOpc , cFilVSO , cNumVSO, M->VSO_DATAGE, M->VSO_HORAGE })
		EndIf
		VSO->VSO_NUMBOX := M->VSO_NUMBOX
		VSO->VSO_DATAGE := M->VSO_DATAGE
		VSO->VSO_HORAGE := M->VSO_HORAGE
		VSO->VSO_DATFIN := M->VSO_DATFIN
		VSO->VSO_HORFIN := M->VSO_HORFIN
		VSO->VSO_TEMPAD := M->VSO_TEMPAD
		MSMM(VSO->VSO_OBSMEM,TamSx3("VSO_OBSERV")[1],,&(aMemos[1][2]),1,,,"VSO","VSO_OBSMEM")
		MsUnLock()

		// Gravação da V00 - Tarefas / Reclamações
		DbSelectArea("V00")
		For nCntFor := 1 to Len(oGetDadV00:aCols)
			cQuery := "SELECT R_E_C_N_O_ AS RECV00 "
			cQuery += "  FROM "+RetSqlName("V00")+" "
			cQuery += " WHERE V00_FILIAL = '"+ xFilial("V00") +"'"
			cQuery += "   AND V00_CODAGE = '"+ VSO->VSO_NUMIDE +"'"
			cQuery += "   AND V00_SEQUEN = '"+ oGetDadV00:aCols[nCntFor,nV00SEQUEN] +"'"
			cQuery += "   AND D_E_L_E_T_ = ' ' "
			nRecV00 := FM_SQL(cQuery)
			
			lV00Inc := !( nRecV00 > 0 )

			If !lV00Inc
				V00->(dbGoTo(nRecV00))
			EndIf
				
			RecLock("V00", lV00Inc)
			FG_GRAVAR("V00",oGetDadV00:aCols,aHeaderV00,nCntFor)

			If lV00Inc
				V00->V00_FILIAL := xFilial("V00")
				V00->V00_CODIGO := GetSxeNum("V00","V00_CODIGO")
				ConfirmSX8()
				V00->V00_CODAGE := VSO->VSO_NUMIDE
			EndIf
			MsUnLock()
		Next

		// Gravação da V04 - Agendamento x Planejamento
		DbSelectArea("V04")
		DbSetOrder(2)
		If DbSeek( xFilial("V04") + VSO->VSO_NUMIDE )
			RecLock("V04",.F.)
			// Altera Campos do Planejamento caso nao hoje alteracao ainda
			If V04->V04_PBOX == V04->V04_ABOX
				V04->V04_PBOX   := VSO->VSO_NUMBOX
			EndIf
			If V04->V04_PDTINI == V04->V04_ADTINI
				V04->V04_PDTINI := VSO->VSO_DATAGE
			EndIf
			If V04->V04_PHRINI == V04->V04_AHRINI
				V04->V04_PHRINI := VSO->VSO_HORAGE
			EndIf
			If V04->V04_PDTFIN == V04->V04_ADTFIN
				V04->V04_PDTFIN := VSO->VSO_DATFIN
			EndIf
			If V04->V04_PHRFIN == V04->V04_AHRFIN
				V04->V04_PHRFIN := right(strzero(VSO->VSO_HORFIN,5),4)
			EndIf
			// Altera Campo do Agendamento
			V04->V04_ABOX   := VSO->VSO_NUMBOX
			V04->V04_ADTINI := VSO->VSO_DATAGE
			V04->V04_AHRINI := VSO->VSO_HORAGE
			V04->V04_ADTFIN := VSO->VSO_DATFIN
			V04->V04_AHRFIN := right(strzero(VSO->VSO_HORFIN,5),4)
			MsUnlock()
		EndIf

		// Gravação da VST
		OM420GRAVA( oGetDadVST:aCols , oGetDadVST:aHeader , "3" , VSO->VSO_NUMIDE , VSO->VSO_CODMAR , VSO->VSO_GETKEY ) // GRAVAR INCONVENIENTE

	ElseIf nOpc == 5 // Cancelar

		cFilVSO := VSO->VSO_FILIAL
		cNumVSO := VSO->VSO_NUMIDE

		If Len(aMotCancel) > 0
			M->VSO_OBSERV += IIf(!Empty(M->VSO_OBSERV),CHR(13)+CHR(10),"")+"Motivo do Cancelamento"+": "+aMotCancel[1]+" - "+aMotCancel[2] // Motivo do Cancelamento
			DbSelectArea("VSO")
			RecLock("VSO",.F.)
			VSO->VSO_STATUS := "4" // Cancelado
			VSO->VSO_AGCONF := "3" // Cancelado
			MSMM(VSO->VSO_OBSMEM,TamSx3("VSO_OBSERV")[1],,&(aMemos[1][2]),1,,,"VSO","VSO_OBSMEM")
			MsUnlock()
			DbSelectArea("V04")
			DbSetOrder(2)
			If DbSeek( xFilial("V04") + VSO->VSO_NUMIDE )
				DbSelectArea("V05")
				DbSetOrder(2) // CODPAI
				If DbSeek( xFilial("V05") + V04->V04_CODIGO )
					While !Eof() .and. V05->V05_FILIAL == xFilial("V05") .and. V05->V05_CODPAI == V04->V04_CODIGO
						RecLock("V05",.f.,.t.)
						V05->(dbDelete())
						MsUnLock()
						V05->(dbSkip())
					EndDo
				EndIf
				DbSelectArea("V04")
				RecLock("V04",.f.,.t.)
				V04->(dbDelete())
				MsUnLock()
			EndIf

			///////////////////////////////////
			// Gravar Motivo de Cancelamento //
			///////////////////////////////////
			OFA210VDT("000003",aMotCancel[1],"3",VSO->VSO_FILIAL,VSO->VSO_NUMIDE,aMotCancel[4])

			if lDiarioOficina
				OA5480062_RegistraEventoDiarioOficina(VSO->VSO_NUMIDE, "005") // 005 – CANCELAMENTO DO AGENDAMENTO
			endif
		EndIf

	EndIf

	End Transaction

	If nOpc == 3 .or. nOpc == 4 .or. ( nOpc == 5 .And. !Empty(aMotCancel) ) // Incluir / Alterar / Excluir

		OA602046M_ENVIA_EMAIL(nOpc)

	
		// ---------------------------------
		// INTEGRACAO CONTROL TOWER - Agendamento / Reagendamento / Cancelamento
		// ---------------------------------	
		Do Case 
			Case nOpc == 3
				OM350004N_ImplementacaoControlTower( nOpc, .F., "" ) // Agendamento

			Case nOpc == 4 .And. lAgeAlterado
				OM350004N_ImplementacaoControlTower( nOpc, .T., cDataHoraAnterior ) // Reagendamento

			Case nOpc == 5 .And. !Empty(aMotCancel)
				OM350004N_ImplementacaoControlTower( nOpc, .F., "" ) // Cancelamento

		EndCase

	EndIf

	cFilAnt := cBkpFilAnt // Volta cFilAnt

Return
/*/{Protheus.doc} OA602026M_VLDTDOK
Validação total
@type function
@version
@author Jessé Augusto
@since 17/11/2025
@param nOpc, numeric, param_description
@return variant, return_description
/*/
Static Function OA602026M_VLDTDOK(nOpc As Numeric) As Logical

	Local nCntFor    := 0 As Numeric
	Local nCntFor2   := 0 As Numeric
	Local lRet       := .T. As Logical
	Local nV02CODITE := FG_POSVAR("V02_CODITE", "aHeaderV02") As Numeric
	Local nV02GRUITE := FG_POSVAR("V02_GRUITE", "aHeaderV02") As Numeric
	Local nV02QTDITE := FG_POSVAR("V02_QTDITE", "aHeaderV02") As Numeric
	Local nV02SEQINC := FG_POSVAR("V02_SEQINC", "aHeaderV02") As Numeric
	Local nV03CODSER := FG_POSVAR("V03_CODSER", "aHeaderV03") As Numeric
	Local nV03SEQINC := FG_POSVAR("V03_SEQINC", "aHeaderV03") As Numeric
	Local nV03GRUSER := FG_POSVAR("V03_GRUSER", "aHeaderV03") As Numeric
	Local nV03TIPSER := FG_POSVAR("V03_TIPSER", "aHeaderV03") As Numeric
	Local nV03DESSER := FG_POSVAR("V03_DESSER", "aHeaderV03") As Numeric
	Local nVSTSEQTAR := FG_POSVAR("VST_SEQTAR" ,"aHeaderVST") As Numeric
	Local nV00TEMCAL := FG_POSVAR("V00_TEMCAL" ,"aHeaderV00") As Numeric
	Local nV00TEMINF := FG_POSVAR("V00_TEMINF" ,"aHeaderV00") As Numeric
	Local nV00SEQUEN := FG_POSVAR("V00_SEQUEN" ,"aHeaderV00") As Numeric
	Local nV00DESCRI := FG_POSVAR("V00_DESCRI" ,"aHeaderV00") As Numeric

	If nOpc == 3 .Or. nOpc == 4
		If Empty(M->VSO_CODMAR) .Or. Empty(M->VSO_PROVEI+M->VSO_LOJPRO) .Or. Empty(M->VSO_GETKEY)
			FMX_HELP("OA6020261", STR0070, STR0071) // Os dados do Cliente/Veiculo! (Cod Marca / Proprietário e Loja) nã foram preenchidos // Favor preencher os Dados do Cliente/Veiculo! (Cod Marca / Proprietário e Loja)
			lRet := .F.
		EndIf

		If Empty(M->VSO_DATAGE) .Or. Empty(M->VSO_HORAGE) .Or. Empty(M->VSO_NUMBOX)
			FMX_HELP("OA6020262", STR0072, STR0073) // O Horário do Agendamento não foi selecionado // Favor selecionar o Horário do Agendamento!
			lRet := .F.
		EndIf

		For nCntFor := 1 To Len(aCpoObgVSO)
			If Empty(&("M->" + aCpoObgVSO[nCntFor]))
				Help(" ", 1, "OBRIGAT2",, RetTitle(aCpoObgVSO[nCntFor]), 4, 1)
				lRet := .F.
			EndIf
		Next

		For nCntFor := 1 To len(oGetDadV02:aCols)
			lV02Del    := oGetDadV02:aCols[nCntFor, Len(oGetDadV02:aCols[nCntFor])]
			lV02QTDITE := oGetDadV02:aCols[nCntFor, nV02QTDITE] > 0
			lV02GruIt  := !Empty(oGetDadV02:aCols[nCntFor, nV02GRUITE])
			lV02CodIt  := !Empty(oGetDadV02:aCols[nCntFor, nV02CODITE])
			lV02SeqInc := !Empty(oGetDadV02:aCols[nCntFor, nV02SEQINC])

			If !lV02Del .And. (lV02CodIt .Or. lV02SeqInc)
				Do Case
				Case lV02SeqInc .And. (!lV02QTDITE .Or. !lV02GruIt .Or. !lV02CodIt)
					FMX_HELP("OA6020229", STR0220, STR0221 ) // O campo Quantidade, Grupo Item ou Código não foi preenchido // Favor verificar se os campos Quantidade, Grupo Item e Código Item foram preenchidos
					lRet := .F.
				Case Empty(oGetDadV02:aCols[nCntFor, nV02SEQINC])
					FMX_HELP("OA6020263", STR0074, STR0075) // A Tarefa/Pacote não foi informada no(s) Item(ns)! // Favor informar a Tarefa/Pacote no(s) Item(ns)!
					lRet := .F.
				EndCase
			EndIf
		Next

		For nCntFor := 1 To len(oGetDadV03:aCols)
			If !oGetDadV03:aCols[nCntFor,len(oGetDadV03:aCols[nCntFor])] .And. (!Empty(oGetDadV03:aCols[nCntFor, nV03CODSER]) .Or. !Empty(oGetDadV03:aCols[nCntFor, nV03SEQINC]))
				Do Case
				Case Empty(oGetDadV03:aCols[nCntFor,nV03SEQINC])
					FMX_HELP("OA6020266", STR0080, STR0081) // A Tarefa/Pacote não foi informada no(s) Serviço(s)! // Favor informar o(s) Tarefa/Pacote no(s) Serviço(s)!
					lRet := .F.
				Case Empty(oGetDadV03:aCols[nCntFor, nV03GRUSER])
					FMX_HELP("OA6020267", STR0082, STR0083) // O Grupo não foi informado no(s) Serviço(s)! // Favor informar o(s) Grupo(s) no(s) Serviço(s)!
					lRet := .F.
				Case Empty(oGetDadV03:aCols[nCntFor,nV03TIPSER])
					FMX_HELP("OA6020268", STR0084, STR0085) // O Tipo não foi informado no(s) Serviço(s)! // Favor informar o(s) Tipo(s) no(s) Serviço(s)!
					lRet := .F.
				Case Empty(oGetDadV03:aCols[nCntFor, nV03CODSER])
					FMX_HELP("OA6020230", STR0222, STR0085) // O Código de Serviço não foi informado! // Favor informar o(s) Código(s) Serviço(s)!
					lRet := .F.
				EndCase

				For nCntFor2 := 1 To Len(oGetDadV03:aCols) // Verifica duplicidade
					If nCntFor <> nCntFor2 .And. !oGetDadV03:aCols[nCntFor2, Len(oGetDadV03:aCols[nCntFor2])]
						If oGetDadV03:aCols[nCntFor, nV03CODSER] == oGetDadV03:aCols[nCntFor2, nV03CODSER]
							FMX_HELP("OA6020269", STR0086 + CRLF + CRLF + AllTrim(oGetDadV03:aCols[nCntFor, nV03CODSER]) + " " + oGetDadV03:aCols[nCntFor, nV03DESSER], STR0087) // Serviço duplicado no Agendamento! // Verifique se há duplicidade e a elimine
							lRet := .F.
						EndIf
					EndIf
				Next
			EndIf
		Next

		For nCntFor := 1 To Len(oGetDadV00:aCols)
			If !oGetDadV00:aCols[nCntFor, Len(oGetDadV00:aCols[nCntFor])] .And. oGetDadV00:aCols[nCntFor, nV00TEMCAL] == 0 .And. AllTrim(oGetDadV00:aCols[nCntFor][2]) <> ""
				If oGetDadV00:aCols[nCntFor, nV00TEMINF] == 0
					FMX_HELP("OA60202610", STR0236, STR0209) // "O Tempo não foi informado para as Tarefas Avulsas que não possuem Serviços relacionados." // "Favor informar o Tempo para todas as Tarefas Avulsas que não possuem Serviços relacionados."
					lRet := .F.
				EndIf
			EndIf
		Next

		For nCntFor := 1 To len(oGetDadV00:aCols)
			If !oGetDadV00:aCols[nCntFor, Len(oGetDadV00:aCols[nCntFor])]
				If aScan(oGetDadVST:aCols, {|x| x[nVSTSEQTAR] == oGetDadV00:aCols[nCntFor, nV00SEQUEN] .And. !x[Len(x)]}) <= 0 // Pesquisa
					OA602037M_SEQINC(oGetDadV00:aCols[nCntFor, nV00DESCRI]) // Cria automaticamente o Inconveniente Avulso com a Descrição da Tarefa
					oGetDadVST:aCols[len(oGetDadVST:aCols), nVSTSEQTAR] := oGetDadV00:aCols[nCntFor, nV00SEQUEN]
				EndIf
			EndIf
		Next
	EndIf

Return(lRet)

/*/{Protheus.doc} OA602028M_REL
Relacao
@type function
@version
@author Jessé Augusto
@since 17/11/2025
@param cCampo, character, param_description
@return variant, return_description
/*/// OA602REL

Function OA602028M_REL(cCampo) // Relacao
	
	Local cRet := ""
	Default cCampo := ""

	If cCampo == "V00_SEQUEN"

		If Type("oGetDadV00:aCols") == "A"
			cRet := StrZero(Len(oGetDadV00:aCols), TamSx3("V00_SEQUEN")[1])
		Else
			cRet := "001"
		EndIf

	EndIf

return cRet

/*/{Protheus.doc} OA602029M_ANALISA_HORAS
Realiza o levantamento das horas
@type function
@version
@author Jesse Augusto
@since 18/11/2025
@param nTp, numeric, param_description
@return variant, return_description
/*/
Static Function OA602029M_ANALISA_HORAS(nTp)

	Local cMV_HRBOXES := ""
	Local nHrs        := 0
	Local nMin        := 0
	Local nCntFor     := 0
	Local nPosIni     := 1
	Local nPosFin     := 1
	Local cBkpFilAnt  := cFilAnt // Salva cFilAnt
	If nTp == 0 // Levantamento Inicial - Montar Vetor com Horas 00:00 as 24:00
		aHoraBox := {}
		For nHrs := 0 to 24 // O correto é ate 23h45, porem vai ate 24 para tratar quando trabalhar 24h
			For nMin := 0 to 45 step 15
				aAdd(aHoraBox,strzero(nHrs,2)+strzero(nMin,2))
				If nHrs == 24
					Exit
				EndIf
			Next
		Next
	EndIf
	cFilAnt := cFilSelect // Filial Selecionada
	cMV_HRBOXES := GETMV("MV_HRBOXES") // Default: "0730-1130;1300-1800"
	/*
	cMV_HRBOXES := "0730-1000;1015-1130;1300-1600;1615-1800"
	cMV_HRBOXES := "0800-1200;1300-1800"
	cMV_HRBOXES := "0000-2400"
	*/
	cHoraBox := ""
	nPosIni := 1
	nPosFin := 1
	While !Empty(cMV_HRBOXES)
		nPosFin := ascan(aHoraBox,substr(cMV_HRBOXES,1,4)) - 1
		For nCntFor := nPosIni to nPosFin
			cHoraBox += " "
		Next
		nPosIni := nPosFin + 1
		nPosFin := ascan(aHoraBox,substr(cMV_HRBOXES,6,4)) - 1
		For nCntFor := nPosIni to nPosFin
			cHoraBox += "X"
		Next
		nPosIni := nPosFin + 1
		cMV_HRBOXES := substr(cMV_HRBOXES,11)
	EndDo

	cHoraBox := left(cHoraBox+space(96),96)
	cFilAnt := cBkpFilAnt // Volta cFilAnt

Return

/*/{Protheus.doc} OA602030M_CORES
Definição de cores
@type function
@version
@author Jessé Augusto
@since 18/11/2025
@return variant, return_description
/*/
Static Function OA602030M_CORES()

	Local cQuery  := ""
	Local cQAlSQL := "SQLVSO"
	Local cBoxAux := "INICIAL"
	Local cHrAux  := ""
	Local aBoxAux := {}
	Local nBoxAux := 0
	Local nPosIni := 0
	Local nPosFin := 0
	Local nCntFor := 0
	Local cCor    := ""
	Local cCorBox := cHoraBox // Horas de Trabalho PADRAO
	Local cBkpFilAnt := cFilAnt // Salva cFilAnt
	//
	cFilAnt := cFilSelect // Filial Selecionada
	//
	cQuery := "SELECT VSO_NUMBOX , VSO_DATAGE , VSO_HORAGE , VSO_DATFIN , VSO_HORFIN "
	cQuery += "FROM " + RetSqlName("VSO") + " "
	cQuery += "WHERE 
	cQuery += "    VSO_FILIAL = ? AND "
	cQuery += "    VSO_NUMBOX IN (?) AND "
	cQuery += "    (VSO_DATAGE = ? OR VSO_DATFIN = ? OR (VSO_DATAGE < ? AND VSO_DATFIN > ?)) AND 
	cQuery += "    VSO_STATUS <> ? AND "
	If ALTERA // Se ALTERA, não considerar o registro
		cQuery += "    R_E_C_N_O_ <> ? AND "
	EndIf
	cQuery += "    D_E_L_E_T_ = ' ' "
	cQuery += "ORDER BY VSO_NUMBOX"
	
	oExec := FWExecStatement():New(cQuery)
	oExec:SetString(1, xFilial("VSO")) // Filial
	oExec:SetIn(2, aBoxSel) // Setar Array de Boxes para o IN do
	oExec:SetString(3, DToS(dDtaSelect))
	oExec:SetString(4, DToS(dDtaSelect))	
	oExec:SetString(5, DToS(dDtaSelect))	
	oExec:SetString(6, DToS(dDtaSelect))
	oExec:SetString(7, '4') // Status diferente de Cancelado
	If ALTERA
		oExec:SetString(8, AllTrim(Str(VSO->(RecNo()))))
	EndIf
	cQAlSQL := oExec:OpenAlias()

	While !(cQAlSQL)->(Eof())
		If cBoxAux <> (cQAlSQL)->VSO_NUMBOX
			cBoxAux := (cQAlSQL)->VSO_NUMBOX
			aAdd(aBoxAux, Array(97))
			nBoxAux := Len(aBoxAux)
			For nCntFor := 1 To 96
				aBoxAux[nBoxAux, nCntFor] := SubStr(cHoraBox, nCntFor, 1)
			Next
	
			aBoxAux[nBoxAux, 97] := cBoxAux // Numero do Box
		EndIf
		
		// Fazer contador das horas/minutos para preencher o agendamento
		If (cQAlSQL)->VSO_DATAGE < DToS(dDtaSelect)
			nPosIni := 1
		Else
			cHrAux  := (cQAlSQL)->VSO_HORAGE
			nPosIni := aScan(aHoraBox, cHrAux)
		EndIf

		If (cQAlSQL)->VSO_DATFIN > DToS(dDtaSelect)
			nPosFin := 96
		Else
			cHrAux  := Right(Left(StrZero((cQAlSQL)->VSO_HORFIN, 5), 3), 2) // Hora
			cHrAux  += Right(StrZero((cQAlSQL)->VSO_HORFIN, 5), 2) // Min
			nPosFin := aScan(aHoraBox, cHrAux) - 1
		EndIf

		For nCntFor := nPosIni To nPosFin
			If aBoxAux[nBoxAux, nCntFor] <> " "
				aBoxAux[nBoxAux, nCntFor] := "3"
			EndIf
		Next

		(cQAlSQL)->(DbSkip())
	EndDo
	(cQAlSQL)->(DbCloseArea())
	
	DbSelectArea("VSO")
	cCor := "3" // Vermelho - Horário Indisponível
	For nCntFor := 1 to len(aBoxes)
		If aBoxes[nCntFor,1] .and. aScan(aBoxAux, {|x| x[97] == aBoxes[nCntFor,2] }) <= 0 // Pesquisa 
			cCor := "1" // Caso exista um BOX selecionado e ainda nao foi nada agendado para ele - Deixar Livre os Horarios
			Exit
		EndIf
	Next

	cFilAnt := cBkpFilAnt // Volta cFilAnt
	// Marcar cenario de todos os Box Selecionados
	For nCntFor := 1 to 96
		If SubStr(cCorBox, nCntFor, 1) == "X"
			If cCor == "3" .and. aScan(aBoxAux, {|x| x[nCntFor] == "X" }) > 0
				cCorBox := Stuff(cCorBox, nCntFor, 1, "1")
			Else
				cCorBox := Stuff(cCorBox, nCntFor, 1, cCor)
			EndIf
		EndIf
	Next
	cHoraBoxCOR := cCorBox

	// Marcar em AZUL a Hora ja Agendada
	If !Empty(M->VSO_DATAGE) .And. !Empty(M->VSO_DATFIN)
		If M->VSO_DATAGE < dDtaSelect
			nPosIni := 1
		Else
			cHrAux  := M->VSO_HORAGE
			nPosIni := aScan(aHoraBox, cHrAux)
		EndIf
		If M->VSO_DATFIN > dDtaSelect
			nPosFin := 96
		Else
			cHrAux  := Right(StrZero(M->VSO_HORFIN, 5), 4)
			nPosFin := aScan(aHoraBox, cHrAux) - 1
		EndIf
		For nCntFor := nPosIni to nPosFin
			If SubStr(cCorBox, nCntFor, 1) <> " "
				cCorBox := Stuff(cCorBox, nCntFor, 1, "2")
			EndIf
		Next
	EndIf
	
	OA602031M_CORES(.T., cCorBox) // Printar Cores

Return()

/*/{Protheus.doc} OA602031M_CORES
Habilita/Desabilita as Cores
@type function
@version
@author Jessé Augusto
@since 18/11/2025
@param lHab, logical, param_description
@param cPosCores, character, param_description
@return variant, return_description
/*/
Static Function OA602031M_CORES(lHab, cPosCores)
	
	Local nCntFor:= 0
	Local nCores := 0
	For nCntFor := 1 to 96
		For nCores := 1 to 3
			&("oBM"+strzero(nCntFor,2)+"_"+strzero(nCores,1)+":lVisible := .f.")
		Next
	Next
	If lHab
		For nCntFor := 1 to 96
			If substr(cPosCores,nCntFor,1) == "X"
				&("oBM"+strzero(nCntFor,2)+"_1:lVisible := .t.")
			ElseIf substr(cPosCores,nCntFor,1) $ "123"
				&("oBM"+strzero(nCntFor,2)+"_"+substr(cPosCores,nCntFor,1)+":lVisible := .t.")
			EndIf
		Next
	EndIf

Return

/*/{Protheus.doc} OA602033M_INCSEQ
Função para trazer tela com Sequencia das Tarefas/Reclamação.
Inicialmente chamada pela Consulta V00INC (SXB)
@type function
@version
@author Jessé Augusto
@since 18/11/2025
@param cVarSeq, character, param_description
@param lTela, logical, param_description
@return variant, return_description
/*/
Function OA602033M_INCSEQ(cVarSeq,lTela)
	Local nCntFor := 0
	Local aIncSeq := {}
	Default cVarSeq := ReadVar()
	Default lTela   := .t.
	For nCntFor := 1 to Len(oGetDadVST:aCols)
		If !oGetDadVST:aCols[nCntFor,Len(aHeaderVST)+1]
			aadd(aIncSeq,{oGetDadVST:aCols[nCntFor,FG_POSVAR("VST_SEQINC","aHeaderVST")],oGetDadVST:aCols[nCntFor,FG_POSVAR("VST_DESINC","aHeaderVST")]})
		Endif
	Next
	If len(aIncSeq) == 0
		aadd(aIncSeq,{ Space(TamSx3("VST_SEQINC")[1]) , "" })
	EndIf
	If lTela
		&(cVarSeq) := Space(TamSx3("VST_SEQINC")[1])
		DEFINE MSDIALOG oTELINCSEQ TITLE STR0092  FROM  00,00 TO 23,55 OF oMainWnd // Selecione o Pacote/Inconveniente
		oLbIncSeq := TWBrowse():New( 05,;
									05,;
									210,;
									150,;
									,,,oTELINCSEQ,,,,,,,,,,,,.F.,,.T.,,.F.,,,)
		oLbIncSeq:addColumn( TCColumn():New( STR0091 , { || aIncSeq[oLbIncSeq:nAt,01] } ,,,, "LEFT" ,  35 ,.F.,.F.,,,,.F.,) )  // Sequencia
		oLbIncSeq:addColumn( TCColumn():New( STR0092 , { || aIncSeq[oLbIncSeq:nAt,02] } ,,,, "LEFT" ,  100 ,.F.,.F.,,,,.F.,) ) // Pacote/Inconveniente
		oLbIncSeq:bLDblClick   := { || &(cVarSeq) := aIncSeq[oLbIncSeq:nAt,01] , oTELINCSEQ:End() }
		oLbIncSeq:nAt := 1
		oLbIncSeq:SetArray(aIncSeq)
		DEFINE SBUTTON FROM 157,154 TYPE 1 ACTION (&(cVarSeq) := aIncSeq[oLbIncSeq:nAt,01] , oTELINCSEQ:End()) ENABLE OF oTELINCSEQ
		DEFINE SBUTTON FROM 157,184 TYPE 2 ACTION (oTELINCSEQ:End()) ENABLE OF oTELINCSEQ
		ACTIVATE MSDIALOG oTELINCSEQ CENTER
	ElseIf len(aIncSeq) == 1
		&(cVarSeq) := aIncSeq[01,01]
	EndIf
	cTempRetF3 := &(cVarSeq)
Return .t.

/*/{Protheus.doc} OA602035M_INCONV
Inclui inconveniente
@type function
@version
@author Jessé Augusto
@since 18/11/2025
@param nOpc, numeric, param_description
@param _cGrupo, variant, param_description
@param _cCodigo, variant, param_description
@param _cDescricao, variant, param_description
@param _cEdit, variant, param_description
@param _nVlrFixSrv, variant, param_description
@return variant, return_description
/*/
Function OA602035M_INCONV( nOpc , _cGrupo , _cCodigo , _cDescricao , _cEdit , _nVlrFixSrv)
	Local nCntFor2, nCntFor
	Local nAuxPos, cSeqInc
	Local nValSeq       := 0
	Local nPosV00       := 0
	Local nVSTSEQINC    := FG_POSVAR("VST_SEQINC","aHeaderVST")
	Local nTamSeqInc    := TamSX3("VST_SEQINC")[1]

	Default _nVlrFixSrv := 0
	
	// Verificar Inconveniente Duplicado
	If !Empty(cCodInc) // Inconveniente Cadastrado
		
		nVSTGRUINC := FG_POSVAR("VST_GRUINC","aHeaderVST")
		nVSTCODINC := FG_POSVAR("VST_CODINC","aHeaderVST")
		nStart 	   :=  1
		lAchou     := .F.

		For nAuxPos := 1 To Len(oGetDadVST:aCols)

			nPos    := aSCan( oGetDadVST:aCols,{|x| x[nVSTGRUINC] + x[nVSTCODINC] == cGruInc + cCodInc },  nStart )
			
			lAchou  := !( nPos <= 0 )

			If !lAchou
				Exit
			Else
				lAchou := If( !oGetDadVST:aCols[nPos][ Len(oGetDadVST:aHeader)+ 1], .T., .F. )
				
				If lAchou
					Exit
				Else
					nStart := nPos + 1
				EndIf
			EndIf
		Next nAuxPos

		If lAchou
			FMX_HELP( "OA6020351", STR0093, STR0094 ) // Pacote/Inconveniente já Cadastrado para esta Tarefa // Utilize um valor disponível para cadastro
			Return .F.
		EndIf

	ElseIf !Empty(cDesInc) // Inconveniente Avulso
		For nAuxPos := 1 to len(oGetDadVST:aCols)
			If 	Alltrim(cDesInc) == Alltrim(oGetDadVST:aCols[nAuxPos,FG_POSVAR("VST_DESINC","aHeaderVST")])
				FMX_HELP( "OA6020352", STR0095, STR0094 ) // Pacote/Inconveniente Avulso já Cadastrado // Utilize um valor disponível para cadastro
				Return .f.
			EndIf
		Next
	EndIf
	
	nPosV00 := aScan( oGetDadV00:aHeader,{|x| x[2] == "V00_SEQUEN" })

	nPosV00 := If( nPosV00 > 0 , nPosV00, 1 )

	
	nPosV00 := aScan(oGetDadV00:aCols,{|x| x[nPosV00] == cSeqTar })
	
	If nPosV00 > 0
		If _cEdit == "C"
			cSeqTar := M->VST_SEQTAR := space(TamSX3("VST_SEQTAR")[1]) // NAO RELACIONADO A NENHUMA TAREFA
		Else // _cEdit == "D"
			If Empty(_cDescricao) .and. Empty(_cGrupo) .and. Empty(_cCodigo)
				If aScan(oGetDadVST:aCols,{|x| x[FG_POSVAR("VST_SEQTAR","aHeaderVST")] == cSeqTar .and. Empty(x[FG_POSVAR("VST_CODINC","aHeaderVST")]) }) == 0
					_cDescricao := oGetDadV00:aCols[nPosV00,FG_POSVAR("V00_DESCRI","aHeaderV00")] // Preencher com a Descricao da Tarefa ( Tarefa Avulsa )
				EndIf
			EndIf
		EndIf
	EndIf
	
	_cDescricao := FwNoAccent(_cDescricao)
	
	nUsadoI := Len(aHeaderVST)
	nUsadoP := Len(aHeaderV02)
	nUsadoS := Len(aHeaderV03)
	
	// Se for chamada pela edicao do campo de codigo e nao informado codigo ou grupo nao faz nda
	// Se for chamada pela edicao do campo de descricao e nao informada a descricao nao faz nda
	if (_cEdit == "C" .and. (Empty(_cGrupo) .or. Empty(_cCodigo))) .or. ;
		(_cEdit == "D" .and. Empty(_cDescricao))
		return .t.
	endif

	// Valida se é possível adicionar um inconveniente ...
	// If !OA602036M_VLINC("Servico")
	// 	Return(.F.)
	// EndIf

	// If !OA602036M_VLINC("Peca")
	// 	Return(.F.)
	// EndIf

	// Procura o inconveniente
	if !empty(_cGrupo) .and. !empty(_cCodigo)
		dbSelectArea("VSL")
		dbSetOrder(1) // VSL_CODMAR+VSL_CODGRU+VSL_CODINC
		if !dbSeek(xFilial("VSL") + VV1->VV1_CODMAR + _cGrupo + _cCodigo)
			if !dbSeek(xFilial("VSL") + Space(TamSX3("VV1_CODMAR")[1]) + _cGrupo + _cCodigo)
				FWAlertWarning(STR0097, STR0029) // Pacote/Inconveniente não Encontrado // Atenção
				Return .f.
			endif
		Endif
		_cDescricao := VSL->VSL_DESINC

		// Se nao for informado grupo e codigo do inconveniente, exibe tela para editar as pecas e servicos
		// Chama a Consulta de Inconvenientes
		aRet := OFIOM420( _cGrupo , _cCodigo , VV1->VV1_CHAINT , M->VSO_KILOME , , _cDescricao , , , .T. , .F. , "" , "" , "" , .T. ) // Inconvenientes
		aPeca := aRet[1]
		aServ := aRet[2]

	EndIf

	cGruInc := space(TamSX3("VST_GRUINC")[1])
	cCodInc := space(TamSX3("VST_CODINC")[1])
	cDesInc := space(TamSX3("VST_DESINC")[1])
	cSeqInc := Space(TamSX3("VST_SEQINC")[1])

	//###########################################
	//# Adiciona na GetGados dos Inconvenientes #
	//###########################################
	// Se tiver em branco, adicionou inconveniente pelo grupo e codigo
	if empty(_cDescricao)
		if len(aPeca) > 0
			_cDescricao := aPeca[1,6]
		else
			_cDescricao := aServ[1,6]
		endif
	endif
	//

	// Verifica se é a primeira linha da aCols
	lPrimeiraLinha := .f.
	nAuxPos := FG_POSVAR("VST_DESINC","aHeaderVST")
	if Len(oGetDadVST:aCols) == 1
		if empty(oGetDadVST:aCols[1,nAuxPos])
			lPrimeiraLinha := .t.
		endif
	endif
	nAuxPos := 0
	If Empty(_cGrupo+_cCodigo) .and. !Empty(_cDescricao)
		nAuxPos := aScan(oGetDadVST:aCols, {|x| Alltrim(x[FG_POSVAR("VST_DESINC","aHeaderVST")]) == Alltrim(_cDescricao) }) // Procurar se ja existe Inconveniente por Descricao
	EndIf
	If nAuxPos <= 0
		if !lPrimeiraLinha
			AADD(oGetDadVST:aCols,Array(nUsadoI+1))
		endif
		nAuxPos := Len(oGetDadVST:aCols)
		If Empty(cSeqInc)
			cSeqInc := StrZero(0,nTamSeqInc)
			For nCntFor := 1 to ( len(oGetDadVST:aCols) - 1 )
				If oGetDadVST:aCols[nCntFor,nVSTSEQINC] > cSeqInc
					cSeqInc := oGetDadVST:aCols[nCntFor,nVSTSEQINC]
				EndIf
			Next
			cSeqInc := StrZero(val(cSeqInc)+1,nTamSeqInc)
		EndIf
		oGetDadVST:aCols[nAuxPos,FG_POSVAR("VST_SEQINC","aHeaderVST")] := M->VST_SEQINC := cSeqInc
		oGetDadVST:aCols[nAuxPos,FG_POSVAR("VST_GRUINC","aHeaderVST")] := M->VST_GRUINC := _cGrupo
		oGetDadVST:aCols[nAuxPos,FG_POSVAR("VST_CODINC","aHeaderVST")] := M->VST_CODINC := _cCodigo
		oGetDadVST:aCols[nAuxPos,FG_POSVAR("VST_DESINC","aHeaderVST")] := M->VST_DESINC := _cDescricao
	EndIf

	oGetDadVST:nAt := nAuxPos
	oGetDadVST:aCols[oGetDadVST:nAt,FG_POSVAR("VST_SEQINC","aHeaderVST")] := StrZero(Len(oGetDadVST:aCols),TamSx3("VST_SEQINC")[1])
	oGetDadVST:aCols[oGetDadVST:nAt,FG_POSVAR("VST_SEQTAR","aHeaderVST")] := cSeqTar
	oGetDadVST:aCols[nAuxPos,nUsadoI+1] := .f.
	oGetDadVST:oBrowse:Refresh()

	//###########################################
	//# Adiciona na GetDados de Pecas           #
	//###########################################
	If Len(aPeca) > 0
		lPrimeiraLinha := .f.
		if Len(oGetDadV02:aCols) == 1
			cPeca := oGetDadV02:aCols[1,fg_posvar("V02_CODITE","aHeaderV02")]
			cGrupo := oGetDadV02:aCols[1,fg_posvar("V02_GRUITE","aHeaderV02")]
			// 1a linha vazia (inicio)
			if oGetDadV02:aCols[oGetDadV02:nAt,Len(oGetDadV02:aCols[oGetDadV02:nAt])]
				lPrimeiraLinha := .f.
			elseif Empty(cGrupo) .and. Empty(cPeca)
				lPrimeiraLinha := .t.
			endif
		endif
		for nCntFor := 1 to Len(aPeca)
			if !lPrimeiraLinha
				AADD(oGetDadV02:aCols,Array(nUsadoP+1))
			endif
			lPrimeiraLinha := .f.
			oGetDadV02:aCols[Len(oGetDadV02:aCols),nUsadoP+1]:=.F.
			For nCntFor2:=1 to nUsadoP
				oGetDadV02:aCols[Len(oGetDadV02:aCols),nCntFor2]:=CriaVar(aHeaderV02[nCntFor2,2])
			Next
			oGetDadV02:nAt := n := Len(oGetDadV02:aCols)
			DBSelectArea("SB1")
			DBSetOrder(7)
			DBSeek(xFilial("SB1")+aPeca[nCntFor,1]+aPeca[nCntFor,2])
			aVetCmp := {}
			aAdd(aVetCmp,{"V02_GRUITE",aPeca[nCntFor,1]} )
			aAdd(aVetCmp,{"V02_CODITE",aPeca[nCntFor,2]} )
			aAdd(aVetCmp,{"V02_QTDITE",aPeca[nCntFor,3]} )
			RegToMemory("V02",.t.)
			
			oGetdadV02:aCols[oGetdadV02:nAt,FG_POSVAR("V02_GRUITE","aHeaderV02")] := M->V02_GRUITE := aPeca[nCntFor,1]
			oGetdadV02:aCols[oGetdadV02:nAt,FG_POSVAR("V02_CODITE","aHeaderV02")] := M->V02_CODITE := aPeca[nCntFor,2]
			oGetdadV02:aCols[oGetdadV02:nAt,FG_POSVAR("V02_DESITE","aHeaderV02")] := M->V02_DESITE := SB1->B1_DESC
			oGetdadV02:aCols[oGetdadV02:nAt,FG_POSVAR("V02_QTDITE","aHeaderV02")] := M->V02_QTDITE := aPeca[nCntFor,3]
			oGetdadV02:aCols[oGetdadV02:nAt,FG_POSVAR("V02_GRUINC","aHeaderV02")] := M->V02_GRUINC := aPeca[nCntFor,4]
			oGetdadV02:aCols[oGetdadV02:nAt,FG_POSVAR("V02_CODINC","aHeaderV02")] := M->V02_CODINC := aPeca[nCntFor,5]
			oGetdadV02:aCols[oGetdadV02:nAt,FG_POSVAR("V02_DESINC","aHeaderV02")] := M->V02_DESINC := aPeca[nCntFor,6]
			oGetDadV02:aCols[oGetDadV02:nAt,FG_POSVAR("V02_SEQINC","aHeaderV02")] := M->V02_SEQINC := cSeqInc

			for nCntFor2 := 1 to Len(aVetCmp)
				oGetdadV02:nAt := n := Len(oGetdadV02:aCols)
				__ReadVar := "M->"+aVetCmp[nCntFor2,1]
				&("M->"+aVetCmp[nCntFor2,1]) := aVetCmp[nCntFor2,2]
				oGetdadV02:aCols[oGetdadV02:nAt,FG_POSVAR(aVetCmp[nCntFor2,1],"aHeaderV02")] := aVetCmp[nCntFor2,2]
			next

			oGetDadV02:aCols[oGetDadV02:nAt,FG_POSVAR("V02_SEQTAR","aHeaderV02")] := M->V02_SEQTAR := cSeqTar

		next
		
		oGetdadV02:oBrowse:refresh()
		FG_MEMVAR(aHeaderV02,oGetdadV02:aCols,oGetdadV02:nAt)
	EndIf
	
	//###########################################
	//# Adiciona na GetDados de Servicos        #
	//###########################################
	If Len(aServ) > 0
		lPrimeiraLinha := .f.
		if Len(oGetDadV03:aCols) == 1
			cSer := oGetDadV03:aCols[1,fg_posvar("V03_CODSER","aHeaderV03")]
			cGrupo := oGetDadV03:aCols[1,fg_posvar("V03_GRUSER","aHeaderV03")]
			// 1a linha vazia (inicio)
			if oGetDadV03:aCols[oGetDadV03:nAt,Len(oGetDadV03:aCols[oGetDadV03:nAt])]
				lPrimeiraLinha := .f.
			elseif Empty(cGrupo) .and. Empty(cSer)
				lPrimeiraLinha := .t.
			endif
		endif
		for nCntFor := 1 to Len(aServ)
			if !lPrimeiraLinha
				AADD(oGetDadV03:aCols,Array(nUsadoS+1))
			endif
			lPrimeiraLinha := .f.
			oGetDadV03:aCols[Len(oGetDadV03:aCols),nUsadoS+1]:=.F.
			For nCntFor2:=1 to nUsadoS
				oGetDadV03:aCols[Len(oGetDadV03:aCols),nCntFor2]:=CriaVar(aHeaderV03[nCntFor2,2])
			Next
			oGetDadV03:nAt := n := Len(oGetDadV03:aCols)
			
			aVetCmp := {}
			aAdd(aVetCmp,{"V03_GRUSER",aServ[nCntFor,1]} )
			aAdd(aVetCmp,{"V03_CODSER",aServ[nCntFor,2]} )
			aAdd(aVetCmp,{"V03_TIPSER",aServ[nCntFor,3]} )
			RegToMemory("V03",.t.)
			
			oGetDadV03:aCols[oGetDadV03:nAt,FG_POSVAR("V03_GRUSER","aHeaderV03")] := M->V03_GRUSER := aServ[nCntFor,1]
			oGetDadV03:aCols[oGetDadV03:nAt,FG_POSVAR("V03_CODSER","aHeaderV03")] := M->V03_CODSER := aServ[nCntFor,2]
			oGetDadV03:aCols[oGetDadV03:nAt,FG_POSVAR("V03_TIPSER","aHeaderV03")] := M->V03_TIPSER := aServ[nCntFor,3]
			oGetDadV03:aCols[oGetDadV03:nAt,FG_POSVAR("V03_GRUINC","aHeaderV03")] := M->V03_GRUINC := aServ[nCntFor,4]
			oGetDadV03:aCols[oGetDadV03:nAt,FG_POSVAR("V03_CODINC","aHeaderV03")] := M->V03_CODINC := aServ[nCntFor,5]
			oGetDadV03:aCols[oGetDadV03:nAt,FG_POSVAR("V03_DESINC","aHeaderV03")] := M->V03_DESINC := aServ[nCntFor,6]
			oGetDadV03:aCols[oGetDadV03:nAt,FG_POSVAR("V03_SEQINC","aHeaderV03")] := M->V03_SEQINC := cSeqInc
			
			If V03->(FieldPos("V03_CODSEC")) > 0
				M->V03_CODSEC := aServ[nCntFor,7]
				aAdd(aVetCmp,{"V03_CODSEC",aServ[nCntFor,7]} )
			EndIf
			DbSelectArea("VO6")
			dbSetOrder(3)
			if VO6->(dbSeek(xFilial("VO6")+FG_MARSRV(VV1->VV1_CODMAR,aServ[nCntFor,2])+aServ[nCntFor,1]+aServ[nCntFor,2]))
				oGetDadV03:aCols[oGetDadV03:nAt,FG_POSVAR("V03_DESSER","aHeaderV03")] := M->V03_DESSER := VO6->VO6_DESSER
				oGetDadV03:aCols[oGetDadV03:nAt,FG_POSVAR("V03_TEMPAD","aHeaderV03")] := M->V03_TEMPAD := VO6->VO6_TEMFAB
			endif
			for nCntFor2 := 1 to Len(aVetCmp)
				oGetDadV03:nAt := n := Len(oGetDadV03:aCols)
				__ReadVar := "M->"+aVetCmp[nCntFor2,1]
			next
			
		next
		nValSeq := 0

		oGetDadV03:oBrowse:refresh()

	EndIf
	
	VE1->(dbSetOrder(1))
	VE1->(dbSeek(xFilial("VE1") + VV1->VV1_CODMAR)) //FNC 18967/2010 - BOBY - 30/08/10

	oGetDadVST:oBrowse:Refresh()

	OA602038M_TOTHORAS(.t.)

return .t.

/*/{Protheus.doc} OA602036M_VLINC
Valida inclusão
@type function
@version
@author Jessé Augusto
@since 11/18/2025
@return variant, return_description
/*/
// Static Function OA602036M_VLINC(cTipo As Character) As Logical

// 	Local nCntFor := 0 As Numeric
// 	Local nPosGruInc := FG_POSVAR("V02_GRUINC", "aHeaderV02")
// 	Local nPosCodInc := FG_POSVAR("V02_CODINC", "aHeaderV02")
// 	Local nPosSeqInc := FG_POSVAR("V02_SEQINC", "aHeaderV02")
// 	Local nPosDesInc := FG_POSVAR("V02_DESINC", "aHeaderV02")
// 	Local lRet       := .F. As Logical

// 	If cTipo == "Servico"
// 		If !(oGetDadV03:aCols[oGetDadV03:nAt,len(oGetDadV03:aCols[oGetDadV03:nAt])])
// 			lRet := .T.
// 		EndIf
// 	Else	
// 		If !(oGetdadV02:aCols[oGetdadV02:nAt,len(oGetdadV02:aCols[oGetdadV02:nAt])])
// 			lRet := .T.
// 		EndIf
// 	EndIf	

// 	// Verifica se ja existe peca/servico e esta sem inconveniente 
// 	If lInconvObr .Or. Empty(cIncDefault)
// 		If cTipo == "Servico" .And. !lRet
// 			nPosDESINC := FG_POSVAR("V03_DESINC", "aHeaderV03")
// 		Else
// 			nPosDESINC := FG_POSVAR("V02_DESINC", "aHeaderV02")
// 		EndIf
// 	Else
// 		nPosInc := aScan(oGetDadVST:aCols,{|x| FwNoAccent(AllTrim(x[FG_POSVAR("VST_DESINC", "aHeaderVST")])) == FwNoAccent(cIncDefault) .And. !x[len(oGetDadVST:aHeader) + 1]})
// 		If nPosInc == 0
// 			cDescInconv := cIncDefault
// 			OA602037M_SEQINC(cDescInconv)
// 			nPosInc := aScan(oGetDadVST:aCols,{|x| FwNoAccent(Alltrim(x[FG_POSVAR("VST_DESINC", "aHeaderVST")])) == FwNoAccent(cIncDefault) .And. !x[len(oGetDadVST:aHeader) + 1]})
// 		EndIf
// 		M->V02_GRUINC := ""
// 		M->V02_CODINC := ""
// 		M->V02_SEQINC := oGetDadVST:aCols[nPosInc, 1]
// 		M->V02_DESINC := oGetDadVST:aCols[nPosInc, 4]
// 		For nCntFor := 1 To Len(oGetdadV02:aCols)
// 			If !oGetdadV02:aCols[nCntFor, Len(oGetdadV02:aCols[nCntFor])] .And. Empty(oGetdadV02:aCols[nCntFor, nPosDESINC])
// 				oGetdadV02:aCols[nCntFor, nPosGruInc] := M->V02_GRUINC
// 				oGetdadV02:aCols[nCntFor, nPosCodInc] := M->V02_CODINC
// 				oGetdadV02:aCols[nCntFor, nPosSeqInc] := M->V02_SEQINC
// 				oGetdadV02:aCols[nCntFor, nPosDesInc] := M->V02_DESINC
// 			EndIf
// 		Next nCntFor
// 	EndIf

// Return(lRet)

/*/{Protheus.doc} OA602037M_SEQINC
Gera sequência na inclusão
@type function
@version
@author Jessé Augusto
@since 18/11/2025
@param cDescInconv, character, param_description
@return variant, return_description
/*/
Function OA602037M_SEQINC(cDescInconv)

	Local nVSTSEQINC := IIf(lInconveniente,FG_POSVAR("VST_SEQINC","oGetDadVST:aHeader"),0)
	Local nVSTDESINC := IIf(lInconveniente,FG_POSVAR("VST_DESINC","oGetDadVST:aHeader"),0)
	Local nTamSeqInc := TamSX3("VST_SEQINC")[1]
	Local nPos       := 0
	Local cAux       := ""
	Local ni         := 0
	nPos := aScan(oGetDadVST:aCols, {|x| FwNoAccent(Alltrim(x[nVSTDESINC])) == FwNoAccent(Alltrim(cDescInconv)) .and. !x[len(oGetDadVST:aHeader)+1] }) // Verifica se Existe o Inconveniente na aCols de Incovenientes
	If nPos <= 0
		nPos := aScan(oGetDadVST:aCols, {|x| ( Empty(x[nVSTDESINC]) ) .and. !x[len(oGetDadVST:aHeader)+1] }) // Verifica se Existe linha em branco
	EndIf
	If nPos <= 0
		AADD(oGetDadVST:aCols,Array(len(oGetDadVST:aHeader)+1))
		oGetDadVST:aCols[Len(oGetDadVST:aCols),len(oGetDadVST:aHeader)+1] := .F.
		For nPos := 1 to len(oGetDadVST:aHeader)
			oGetDadVST:aCols[Len(oGetDadVST:aCols),nPos] := CriaVar(oGetDadVST:aHeader[nPos,2])
		Next
		oGetDadVST:nAt := nPos := Len(oGetDadVST:aCols)
	EndIf
	If Empty(oGetDadVST:aCols[nPos,nVSTSEQINC])
		cAux := StrZero(0,nTamSeqInc)
		For ni := 1 to len(oGetDadVST:aCols)
			If oGetDadVST:aCols[ni,nVSTSEQINC] > cAux
				cAux := oGetDadVST:aCols[ni,nVSTSEQINC]
			EndIf
		Next
		cAux := StrZero(val(cAux)+1,nTamSeqInc)
		oGetDadVST:aCols[nPos,nVSTSEQINC] := cAux
		oGetDadVST:aCols[nPos,nVSTDESINC] := cDescInconv
	EndIf

Return(oGetDadVST:aCols[nPos,nVSTSEQINC])

/*/{Protheus.doc} OA602038M_TOTHORAS
Atualiza a contabilização das horas
@type function
@version
@author Jessé Augusto
@since 18/11/2025
@param lRefresh, logical, param_description
@return variant, return_description
/*/
Static Function OA602038M_TOTHORAS(lRefresh)
	Local nCntFor := 0
	Local nTempo  := 0
	Local nPos    := 0
	Local nHrsAnt := 0
	
	Local nV00TEMCAL := FG_POSVAR("V00_TEMCAL","aHeaderV00")
	Local nV00TEMINF := FG_POSVAR("V00_TEMINF","aHeaderV00")
	Local nV00SEQUEN := FG_POSVAR("V00_SEQUEN","aHeaderV00")
	Local nV00CODPRO := FG_POSVAR("V00_CODPRO","aHeaderV00")
	Local nV00NOMPRO := FG_POSVAR("V00_NOMPRO","aHeaderV00")
	
	Local nV03CODPRO := FG_POSVAR("V03_CODPRO","aHeaderV03")
	Local nV03NOMPRO := FG_POSVAR("V03_NOMPRO","aHeaderV03")
	Local nV03SEQTAR := FG_POSVAR("V03_SEQTAR","aHeaderV03")
	Local nV03TEMPAD := FG_POSVAR("V03_TEMPAD","aHeaderV03")
	
	For nCntFor := 1 to len(oGetDadV00:aCols)
		oGetDadV00:aCols[nCntFor,nV00TEMCAL] := 0
	Next
	If len(aTotHrs) >= 2
		nHrsAnt := aTotHrs[2,2]
	EndIf
	aTotHrs := {}
	aAdd(aTotHrs,{STR0102,0,""}) // Total Geral de Horas
	aAdd(aTotHrs,{STR0103,0,""}) // Produtivos trabalhando em paralelo
	For nCntFor := 1 to len(oGetDadV03:aCols)
		If !oGetDadV03:aCols[nCntFor,len(oGetDadV03:aCols[nCntFor])]
			nTempo := oGetDadV03:aCols[nCntFor,nV03TEMPAD]
			If nTempo > 0
				nPos := aScan(aTotHrs,{ |x| x[1] == ("- "+oGetDadV03:aCols[nCntFor,nV03CODPRO]) } )
				If nPos == 0
					aAdd(aTotHrs,{"- "+oGetDadV03:aCols[nCntFor,nV03CODPRO],0,oGetDadV03:aCols[nCntFor,nV03NOMPRO]})
					nPos := len(aTotHrs)
				EndIf
				aTotHrs[1,2]    += nTempo
				aTotHrs[nPos,2] += nTempo
				nPos := aScan(oGetDadV00:aCols,{ |x| x[nV00SEQUEN] == oGetDadV03:aCols[nCntFor,nV03SEQTAR] } )
				If nPos > 0
					oGetDadV00:aCols[nPos,nV00TEMCAL] += nTempo
				EndIf
			EndIf
		EndIf
	Next
	For nCntFor := 1 to len(oGetDadV00:aCols)
		nTempo := oGetDadV00:aCols[nCntFor,nV00TEMCAL]
		oGetDadV00:aCols[nCntFor,nV00TEMCAL] := OA602044M_TPO15(Int(nTempo/100) * 100 + ( MOD(nTempo,100) / 100 * 60 ))
		If oGetDadV00:aCols[nCntFor,nV00TEMCAL] > 0
			oGetDadV00:aCols[nCntFor,nV00TEMINF] := 0
		EndIf
		If !oGetDadV00:aCols[nCntFor,len(oGetDadV00:aCols[nCntFor])] .and. oGetDadV00:aCols[nCntFor,nV00TEMINF] > 0
			nPos := aScan(aTotHrs,{ |x| x[1] == ("- "+oGetDadV00:aCols[nCntFor,nV00CODPRO]) } )
			If nPos == 0
				aAdd(aTotHrs,{"- "+oGetDadV00:aCols[nCntFor,nV00CODPRO],0,oGetDadV00:aCols[nCntFor,nV00NOMPRO]})
				nPos := len(aTotHrs)
			EndIf
			nTempo := oGetDadV00:aCols[nCntFor,nV00TEMINF]
			nTempo := (Int(nTempo/100) * 100 + ( MOD(nTempo,100) / 60 * 100 ))
			aTotHrs[1,2]    += nTempo
			aTotHrs[nPos,2] += nTempo
		EndIf
	Next
	For nCntFor := 1 to len(aTotHrs)
		nTempo := aTotHrs[nCntFor,2]
		aTotHrs[nCntFor,2] := OA602044M_TPO15(Int(nTempo/100) * 100 + ( MOD(nTempo,100) / 100 * 60 ))
		If nCntFor >= 3
			If aTotHrs[nCntFor,2] > aTotHrs[2,2]
				aTotHrs[2,2] := aTotHrs[nCntFor,2] // Qtde Maxima de Horas com produtivos paralelos
			EndIf
		EndIf
	Next
	If lRefresh
		oGetDadV00:oBrowse:Refresh()
		oLbTotHrs:nAt := 1
		oLbTotHrs:SetArray(aTotHrs)
		oLbTotHrs:Refresh()
		If nHrsAnt <> aTotHrs[2,2]
			OA602040M_LIMPAAGENDA()
			OA602030M_CORES()
		EndIf
	EndIf
	
Return

/*/{Protheus.doc} OA602039M_CLICKHR
Evento disparado no clique do botão relacionado a horas
@type function
@version
@author Jessé Augusto
@since 18/11/2025
@param nPosDesejada, numeric, param_description
@param cHrDesejada, character, param_description
@return variant, return_description
/*/
Static Function OA602039M_CLICKHR(nPosDesejada, cHrDesejada)

	Local cQuery     := "" As Character
	Local cQAlSQL    := "SQLVSO" As Character
	Local cHrAux     := "" As Character
	Local cMnAux     := "" As Character
	Local nQtdAux    := 0 As Numeric
	Local nQtdDia    := 0 As Numeric
	Local cHrAtual   := "" As Character
	Local nPosIni    := nPosDesejada As Numeric
	Local nPosFin    := nPosDesejada As Numeric
	Local nQtdPos    := 0 As Numeric
	Local nCntFor    := 0 As Numeric
	Local cBoxAux    := "" As Character
	Local lOk        := .F. As Logical
	Local lPesqBox   := .T. As Logical
	Local lRet       := .T. As Logical
	Local cBkpFilAnt := cFilAnt As Character // Salva cFilAnt
	Local cHoraAtual  := ""
	
	If Empty(aBoxSel) 
		FWAlertInfo(STR0235, STR0231) // "Nenhum Box Selecionado" // "Atenção"
		lRet := .F.
	EndIf

	If !INCLUI .And. !ALTERA
		lRet := .F.
	EndIf
	
	cHoraAtual	:= Time()
	IF FindFunction("FGX_TimeUF")
		cHoraAtual := FGX_TimeUF()[2]
	Endif

	If dDtaSelect == dDataAtual
		cHrAtual := substr(cHoraAtual,1,2)+substr(cHoraAtual,4,2)
		// Validar Hora Atual
		If cHrDesejada < cHrAtual
			FWAlertInfo(STR0104 + CRLF + CRLF + Transform(dDataAtual, "@D") + " " + Transform(cHrAtual, "@R 99:99"), STR0029) // Favor selecionar um horário posterior ao atual. // Atenção
			lRet := .F.
		EndIf
	EndIf

	If lRet
		cHrAux := left(strzero(aTotHrs[2,2],4),2)
		cMnAux := right(strzero(aTotHrs[2,2],4),2)
		//
		nQtdPos := Int( ( val(cHrAux) * 4 )+( val(cMnAux) / 15 ) ) // Total de Horas para Produtivos trabalhando em paralelo
		//
		While nQtdAux < nQtdPos
			For nCntFor := nPosIni to 96
				If substr(cHoraBox,nCntFor,1) == "X"
					nQtdAux++
				EndIf
				If nQtdAux == nQtdPos
					nPosFin := nCntFor
					Exit
				EndIf
			Next
			If nQtdAux < nQtdPos
				nQtdDia++
				nPosIni := 1
			EndIf
		EndDo
		
		M->VSO_NUMBOX := ""
		M->VSO_DATAGE := dDtaSelect
		M->VSO_HORAGE := aHoraBox[nPosDesejada]
		M->VSO_DATFIN := dDtaSelect + nQtdDia
		M->VSO_HORFIN := val(aHoraBox[nPosFin+1])
		M->VSO_TEMPAD := aTotHrs[2,2]
		
		If substr(cHoraBoxCOR,nPosDesejada,1) == "3" // Ja tem Agendamentos para esse horario
			lPesqBox := .f.
			If FWAlertYesNo(STR0105,STR0029) // Existe(m) Agendamento(s) para o mesmo horário selecionado. Deseja continuar? // Atenção
				For nCntFor := 1 to len(aBoxes)
					If aBoxes[nCntFor,1]
						M->VSO_NUMBOX := aBoxes[nCntFor,2]
						Exit
					EndIf
				Next
			EndIf
		EndIf
		
		If lPesqBox
			
			cFilAnt := cFilSelect // Filial Selecionada

			For nCntFor := 1 to len(aBoxes)
				If aBoxes[nCntFor,1]
					If Empty(cBoxAux)
						cBoxAux := aBoxes[nCntFor,2]
					EndIf
					aParams := {}
					cQuery  := "SELECT VSO_DATAGE , VSO_HORAGE , VSO_DATFIN , VSO_HORFIN "
					cQuery  += "  FROM "+RetSqlName("VSO")+" "
					cQuery  += " WHERE VSO_FILIAL = ? "
					cQuery  += "   AND VSO_NUMBOX = ? "
					cQuery  += "   AND "
					cQuery  += "   ( "
					cQuery  += "       VSO_DATAGE = ? OR "
					cQuery  += "       VSO_DATFIN = ? OR "
					cQuery  += "     ( VSO_DATAGE < ? AND VSO_DATFIN > ? ) "
					cQuery  += "   ) "

					aAdd( aParams, xFilial("VSO")    )
					aAdd( aParams, aBoxes[nCntFor,2] )
					aAdd( aParams, dtos(dDtaSelect)  )
					aAdd( aParams, dtos(dDtaSelect)  )
					aAdd( aParams, dtos(dDtaSelect)  )
					aAdd( aParams, dtos(dDtaSelect)  )
					
					If ALTERA // Se ALTERA, não considerar o registro
						cQuery += "   AND R_E_C_N_O_ <> ? "

						aAdd( aParams, +Alltrim(str(VSO->(RecNo())))  )
					EndIf
					cQuery += "   AND VSO_STATUS <> ? "
					cQuery += "   AND D_E_L_E_T_=' ' "
					
					aAdd( aParams,'4')

					oExec := FWExecStatement():New()
					oExec:SetQuery(cQuery)
					oExec:SetParams(aParams)
					
					cQAlSQL := oExec:OpenAlias()

					If ( cQAlSQL )->( Eof() )
						( cQAlSQL )->( DbCloseArea() )
						DbSelectArea("VSO")
						M->VSO_NUMBOX := aBoxes[nCntFor,2]
					Else
						
						cDtDesI := dtos(M->VSO_DATAGE)                                 // Data Inicial Desejada
						cHrDesI := M->VSO_HORAGE                                       // Hora Inicial Desejada
						cDtDesF := dtos(M->VSO_DATFIN)                                 // Data Final Desejada
						cHrDesF := right(strzero(M->VSO_HORFIN,5),4)                   // Hora Final Desejada
						
						lOk := .t.
						
						While !( cQAlSQL )->( Eof() ) .and. lOk
							
							cDtAgeI := ( cQAlSQL )->( VSO_DATAGE )                     // Data Inicial dos Agendamentos
							cHrAgeI := ( cQAlSQL )->( VSO_HORAGE )                     // Hora Inicial dos Agendamentos
							cDtAgeF := ( cQAlSQL )->( VSO_DATFIN )                     // Data Final dos Agendamentos
							cHrAgeF := right(strzero(( cQAlSQL )->( VSO_HORFIN ),5),4) // Hora Final dos Agendamentos
							
							// Data Inicial Desejada == Data Inicial Agendamentos
							If cDtDesI == cDtAgeI

								// Data Final Desejada == Data Final Agendamentos
								If cDtDesF == cDtAgeF
									If 		cHrDesI <= cHrAgeI .and.;	// Hora Inicial Desejada <= Hora Inicial Agendamentos
											cHrDesF >  cHrAgeI			// Hora Final Desejada > Hora Inicial Agendamentos
											lOk := .f. 					// Descartar Box
									ElseIf 	cHrDesI >= cHrAgeI .and.;	// Hora Inicial Desejada >= Hora Inicial Agendamentos
											cHrDesI <  cHrAgeF			// Hora Inicial Desejada < Hora Final Agendamentos
											lOk := .f. 					// Descartar Box
									EndIf

								// Data Final Desejada < Data Final Agendamentos
								ElseIf cDtDesF < cDtAgeF
									If cHrDesF > cHrAgeI				// Hora Final Desejada > Hora Inicial Agendamentos
										lOk := .f. 						// Descartar Box
									EndIf

								// Data Final Desejada > Data Final Agendamentos
								ElseIf cDtDesF > cDtAgeF
									If cHrDesI <= cHrAgeI				// Hora Inicial Desejada <= Hora Inicial Agendamentos
										lOk := .f. 						// Descartar Box
									EndIf

								EndIf

							// Data Inicial Desejada < Data Inicial Agendamentos
							ElseIf cDtDesI < cDtAgeI

							// Data Inicial Desejada > Data Inicial Agendamentos
							ElseIf cDtDesI > cDtAgeI

							EndIf

							( cQAlSQL )->( DbSkip() )
						EndDo
						( cQAlSQL )->( DbCloseArea() )
						DbSelectArea("VSO")

						If lOk
							M->VSO_NUMBOX := aBoxes[nCntFor,2]
						EndIf

					EndIf
				EndIf
				If !Empty(M->VSO_NUMBOX)
					Exit
				EndIf
			Next
			DbSelectArea("VSO")
			cFilAnt := cBkpFilAnt // Volta cFilAnt
		EndIf
		If Empty(M->VSO_NUMBOX)
			OA602040M_LIMPAAGENDA()
		EndIf
		
		OA602030M_CORES() // Printa horarios com cores
	EndIf

Return()

/*/{Protheus.doc} OA602040M_LIMPAAGENDA
Reinicia os campos ligados a legenda
@type function
@version
@author Jessé Augusto
@since 18/11/2025
@return variant, return_description
/*/
Static Function OA602040M_LIMPAAGENDA()
	If INCLUI // .or. ALTERA
		M->VSO_NUMBOX := ""
		M->VSO_DATAGE := ctod("")
		M->VSO_HORAGE := ""
		M->VSO_DATFIN := ctod("")
		M->VSO_HORFIN := 0
		M->VSO_TEMPAD := 0
	EndIf
Return()

/*/{Protheus.doc} OA602041M_CONTROLA_ORCAMENTO
Controla Geração x Relação do Orçamento
@type function
@version
@author Jessé Augusto
@since 18/11/2025
@return variant, return_description
/*/
Function OA602041M_CONTROLA_ORCAMENTO()

	Local lAltSalva := Altera
	Local lIncSalva := Inclui
	Local cNroVS1   := ""
	// 18/06/2019 - Manoel-Sil - verificar e permitir que STATUS 5 crie um novo orçamento e posteriormente faça a relação
	If VSO->VSO_STATUS <> "1" .and. VSO->VSO_STATUS <> "2" .and. VSO->VSO_STATUS <> "5"
		FMX_HELP( "OA6020411", STR0011 +" ( "+ UPPER(Alltrim(X3CBOXDESC("VSO_STATUS",VSO->VSO_STATUS)))+" )", STR0029 ) // Agendamento
		Return()
	EndIf
	If VSO->VSO_STATUS == "1" .or. VSO->VSO_STATUS == "5" // 1-Em Aberto /  5-Orcamento Aberto
		If VSO->VSO_STATUS == "1"
			nOpcao := Aviso(STR0107,"- "+ STR0108 + CHR(13)+CHR(10)+ "- "+ STR0109 , { STR0110 , STR0111 , STR0112 } ) // Orçamento Oficina // Novo Orçamento //Relacionar com Orçamento existente // Novo // Relacionar // Cancelar
		Else // VSO->VSO_STATUS == "5"
	
			nOpcao := Aviso( STR0107,"- "+ STR0108 + CHR(13)+CHR(10) + "- " + STR0109 + CHR(13)+CHR(10) + "- " + STR0113 , { STR0110 , STR0111 , STR0114, STR0112 } )
			// Orçamento Oficina // Novo Orçamento // Relacionar com Orçamento existente // Visualizar Orçamentos existentes // Novo // Relacionar // Visualizar // Cancelar
			If nOpcao == 3 // Visualizar
				cNroVS1 := OA6020091_SelecionaOrcamento( VSO->VSO_NUMIDE )
				If !Empty(cNroVS1)
					OFIC170( xFilial("VS1") , cNroVS1 )
				EndIf
			Endif
		Endif
		If nOpcao == 1 		// Criar novo Orcamento
			If VSO->VSO_STATUS == "5"
				FMX_HELP("OA6020411", STR0225 , STR0226 ) // Já existe um Orçamento associado a este código de agendamento selecionado // Utilize um Agedamento cujo Orçamento ainda não tenha sido gerado
			Else
				OA602042M_GERORC(1)
			EndIf
		ElseIf nOpcao == 2  // Relacionar Agendamento com Orcamento existente
			OA602042M_GERORC(2)
		EndIf
	ElseIf VSO->VSO_STATUS == "2"   // 2-OS Aberta
		//OFIXA011(VSO->VSO_NUMIDE) // Filtra todos os Orcamentos criados pelo Agendamento
		cNroVS1 := OA6020091_SelecionaOrcamento( VSO->VSO_NUMIDE )
		If !Empty(cNroVS1)
			OFIC170( xFilial("VS1") , cNroVS1 )
		EndIf
	EndIf
	Altera := lAltSalva
	Inclui := lIncSalva
	
Return

/*/{Protheus.doc} OA602042M_GERORC
Gera Orçamento
@type function
@version
@author Jessé Augusto
@since 18/11/2025
@param nTp, numeric, param_description
@return variant, return_description
/*/
Function OA602042M_GERORC(nTp)
Local aRet := {}
Local aParamBox := {}
Local cTTPadPec := AllTrim(GetNewPar("MV_INCTTPA","")) // TT padrao para Pecas para inconvenientes manuais
Local cTTPadSer := AllTrim(GetNewPar("MV_INCTTSA","")) // TT padrao para Servicos para inconvenientes manuais
Local cNumOrc   := ""
Local nAuxSeqVS3, nAuxSeqVS4
Local nValPec
Local nValSer
Local nValHor
Local cQuery := ""
Local cQAlSQL  := "SQLORC"
Local aVetVS1 := {}
Local aVetVST := {}
Local aVetVS3 := {}
Local aVetVS4 := {}
Local aVetAux := {}
Local aParams := {}
local lDiarioOficina := FindFunction("OA5480062_RegistraEventoDiarioOficina")

Default nTp := 1 // 1 - Gerar Orcamento / 2 - Relacionar Agendamento com Orcamento existente

Private cFormulPeca := ""

If Empty(VSO->VSO_CODMAR) .or. Empty(VSO->VSO_PROVEI+VSO->VSO_LOJPRO) .or. Empty(VSO->VSO_GETKEY)
	FMX_HELP( "OA6020421", STR0115, STR0116 ) // Não é possivel gerar orcamento do agendamento selecionado. Cadastro do Cliente e/ou Veiculo incompleto! // Corrija o cadastro do do Cliente e/ou Veiculo e tente novamente.  
	Return
EndIf

If nTp == 2 // Relacionar Agendamento com Orcamento exitente
	aAdd(aParamBox,{1,RetTitle("VS1_NUMORC"),space(TamSX3("VS1_NUMORC")[1]),"@!","","VS1ORC","",0,.T.})
	While .T.
		If ParamBox(aParamBox,STR0117 ,@aRet,,,,,,,,.F.) // Relacionar ao Agendamento
			VS1->(DbSetOrder(1))
			If VS1->(DbSeek(xFilial("VS1")+aRet[1]))
				If VS1->VS1_TIPORC == "2" // Orcamento de Oficina
					If Empty(VS1->VS1_NUMAGE)
						DbSelectArea("VS1")
						RecLock("VS1",.f.)
							VS1->VS1_NUMAGE := VSO->VSO_NUMIDE
						MsUnLock()
						Exit
					Else
						FWAlertWarning(STR0118,STR0029) // Orçamento já relacionado com outro Agendamento! // Atenção
					EndIf
				Else
					FWAlertWarning(STR0119, STR0029 ) // Relacione somente Orçamentos do Tipo Oficina // Atenção
				EndIf
			Else
				FMX_HELP("OA6020422", STR0120, STR0029 )  // Orçamento não encontrado! // Utilize um Orçamento válido
			EndIf
		Else
			Return
		EndIf
	EndDo
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Gera Orcamentos³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Begin Transaction

If nTp == 1 // Criar Novo Orcamento

	// Posiciona Cliente
	dbSelectArea("SA1")
	dbSetOrder(1)
	dbSeek(xFilial("SA1") + VSO->VSO_PROVEI + VSO->VSO_LOJPRO )
		
	// Posiciona Veiculo
	dbSelectArea("VV1")
	dbSetOrder(2)
	dbSeek(xFilial("VV1")+VSO->VSO_GETKEY)

	dbSelectArea("VOI")
	dbSetOrder(1)
	dbSeek(xFilial("VOI")+cTTPadPec)

	// Formula para calculo do valor das pecas
	cFormulPeca := iif( !Empty(VOI->VOI_VALPEC) , VOI->VOI_VALPEC , &(GETMV("MV_FMLPECA")) ) // Formula do Tipo de Tempo
		
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Cabecalho do Orcamento³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	aAdd(aVetVS1,{"VS1_TIPORC","2"                  }) // Orcamento de Oficina
	aAdd(aVetVS1,{"VS1_NUMAGE",VSO->VSO_NUMIDE      })
	aAdd(aVetVS1,{"VS1_CLIFAT",VSO->VSO_PROVEI      })
	aAdd(aVetVS1,{"VS1_LOJA"  ,VSO->VSO_LOJPRO      })
	aAdd(aVetVS1,{"VS1_NCLIFT",SA1->A1_NOME         })
	aAdd(aVetVS1,{"VS1_TIPCLI",SA1->A1_TIPO         })
	aAdd(aVetVS1,{"VS1_OBSMEM",VSO->VSO_OBSMEM      })
	aAdd(aVetVS1,{"VS1_CODMAR",VSO->VSO_CODMAR      })
	aAdd(aVetVS1,{"VS1_DATORC",CriaVar("VS1_DATORC")})
	aAdd(aVetVS1,{"VS1_HORORC",CriaVar("VS1_HORORC")})
	aAdd(aVetVS1,{"VS1_CODVEN",CriaVar("VS1_CODVEN")})
	aAdd(aVetVS1,{"VS1_DATVAL",CriaVar("VS1_DATVAL")})
	aAdd(aVetVS1,{"VS1_TIPTEM",cTTPadPec            })
	aAdd(aVetVS1,{"VS1_TIPTSV",cTTPadSer            })
	aAdd(aVetVS1,{"VS1_FORMUL",cFormulPeca          })
	aAdd(aVetVS1,{"VS1_CHAINT",VV1->VV1_CHAINT      })
	aAdd(aVetVS1,{"VS1_TIPVEN","1"                  }) // Varejo
	aAdd(aVetVS1,{"VS1_STATUS","0"                  })
	aAdd(aVetVS1,{"VS1_CFNF"  ,"1"                  }) // Gera Nota Fiscal
	aAdd(aVetVS1,{"VS1_KILOME",VSO->VSO_KILOME      })
	If VSO->(FieldPos("VSO_HORTRI")) <> 0
		aAdd(aVetVS1,{"VS1_HORTRI",VSO->VSO_HORTRI  })
	Endif
	If VS1->(FieldPos("VS1_TPATEN")) <> 0
		aAdd(aVetVS1,{"VS1_TPATEN",VSO->VSO_TPATEN  })
	Endif
	
	// Grava Inconveientes
	cQuery := "SELECT * "
	cQuery += "  FROM "+RetSqlName("VST")+" "
	cQuery += " WHERE VST_FILIAL = ? "
	cQuery += "   AND VST_TIPO   = ? AND VST_CODIGO = ? AND D_E_L_E_T_=' ' "
	
	aAdd(aParams, xFilial("VST")  )
	aAdd(aParams, '3' 			  )
	aAdd(aParams, VSO->VSO_NUMIDE )

	oExec := FWExecStatement():New()
	oExec:SetQuery(cQuery)
	oExec:SetParams(aParams)

	cQAlSQL := oExec:OpenAlias()

	While !( cQAlSQL )->( Eof() )
		aVetAux := {}
		aAdd(aVetAux,{"VST_CODMAR",( cQAlSQL )->( VST_CODMAR )})
		aAdd(aVetAux,{"VST_SEQINC",( cQAlSQL )->( VST_SEQINC )})
		aAdd(aVetAux,{"VST_CODINC",( cQAlSQL )->( VST_CODINC )})
		aAdd(aVetAux,{"VST_GRUINC",( cQAlSQL )->( VST_GRUINC )})
		aAdd(aVetAux,{"VST_DESINC",( cQAlSQL )->( VST_DESINC )})
		aAdd(aVetAux,{"VST_EXPSRV",( cQAlSQL )->( VST_EXPSRV )})
		aAdd(aVetAux,{"VST_EXPPEC",( cQAlSQL )->( VST_EXPPEC )})
		aAdd(aVetAux,{"VST_INFREP",( cQAlSQL )->( VST_INFREP )})
		aAdd(aVetAux,{"VST_CHASSI",( cQAlSQL )->( VST_CHASSI )})
		aAdd(aVetAux,{"VST_CODFAL",( cQAlSQL )->( VST_CODFAL )})
		aAdd(aVetAux,{"VST_SEQTAR",( cQAlSQL )->( VST_SEQTAR )})
		
		aAdd(aVetVST,aClone(aVetAux))
		( cQAlSQL )->(DbSkip())
	Enddo
	( cQAlSQL )->(DbCloseArea())

	// Variaveis auxiliares para controlar sequencial
	nAuxSeqVS3 := 0
	nAuxSeqVS4 := 0
	aParams    := {}

	// Grava Peças
	cQuery := "SELECT SB1.R_E_C_N_O_ AS RECSB1, V02.* "
	cQuery += "  FROM "+RetSqlName("V02")+" V02 "
	cQuery += "  JOIN "+RetSqlName("SB1")+" SB1  ON (SB1.B1_FILIAL= ? AND SB1.B1_GRUPO = V02.V02_GRUITE AND SB1.B1_CODITE = V02.V02_CODITE AND SB1.D_E_L_E_T_ = ' ')"
	cQuery += " WHERE V02.V02_FILIAL = ?  "
	cQuery += " AND V02.V02_CODAGE   = ?  "
	cQuery += " AND V02.D_E_L_E_T_   =' ' "
	cQuery += " ORDER BY V02.R_E_C_N_O_   "
	
	aAdd(aParams, xFilial("SB1")  )
	aAdd(aParams, xFilial("V02")  )
	aAdd(aParams, VSO->VSO_NUMIDE )

	oExec := FWExecStatement():New()
	oExec:SetQuery(cQuery)
	oExec:SetParams(aParams)

	cQAlSQL := oExec:OpenAlias()

	While !( cQAlSQL )->( Eof() )
		++nAuxSeqVS3
		dbSelectArea("SB1")
		DbGoTo( (cQAlSQL)->( RECSB1 ) )
		nValPec := FG_VALPEC("","cFormulPeca",(cQAlSQL)->( V02_GRUITE ),(cQAlSQL)->( V02_CODITE ),,.f.,.t.)
		aVetAux := {}
		aAdd(aVetAux,{"VS3_SEQUEN",STRZERO(nAuxSeqVS3,TamSX3("VS3_SEQUEN")[1])}) // Sequencia
		aAdd(aVetAux,{"VS3_SEQINC",(cQAlSQL)->( V02_SEQINC )})	// Sequencia Inconveniente
		aAdd(aVetAux,{"VS3_GRUITE",(cQAlSQL)->( V02_GRUITE )}) 	// Grupo do Item
		aAdd(aVetAux,{"VS3_CODITE",(cQAlSQL)->( V02_CODITE )}) 	// Codigo do Item
		aAdd(aVetAux,{"VS3_FORMUL",cFormulPeca}) 		// Formula do Calculo Valor
		aAdd(aVetAux,{"VS3_LOCAL" ,FM_PRODSBZ(SB1->B1_COD,"SB1->B1_LOCPAD")}) 	// Armazem
		aAdd(aVetAux,{"VS3_CODSIT",CriaVar("VS3_CODSIT")}) // Codigo Si
		aAdd(aVetAux,{"VS3_QTDINI",(cQAlSQL)->( V02_QTDITE )})	// Quantidade Inicial
		aAdd(aVetAux,{"VS3_QTDITE",(cQAlSQL)->( V02_QTDITE )}) 	// Qtde Requisitada
		aAdd(aVetAux,{"VS3_VALPEC",nValPec}) 			// Valor da Peca
		aAdd(aVetAux,{"VS3_VALTOT",(cQAlSQL)->( V02_QTDITE ) * nValPec})  // Vl Total // Valor Total M->VS3_VALTOT := (M->VS3_QTDITE * M->VS3_VALPEC) - M->VS3_VALDES
		aAdd(aVetAux,{"VS3_VALLIQ",nValPec}) 			// Valor da Peca
		cCodTES := ""
		if !Empty(VOI->VOI_CODOPE)
			aAdd(aVetAux,{"VS3_OPER"  , VOI->VOI_CODOPE})
			cCodTES := MaTesInt(2,VOI->VOI_CODOPE,VSO->VSO_PROVEI,VSO->VSO_LOJPRO,"C",SB1->B1_COD) // TES Inteligente
		Endif
		if Empty(cCodTES)
			cCodTES := FM_PRODSBZ(SB1->B1_COD,"SB1->B1_TS")	// TES PADRAO
		endif
		aAdd(aVetAux,{"VS3_CODTES",cCodTES})
		
		aAdd(aVetVS3,aClone(aVetAux))
		( cQAlSQL )->(DbSkip())
	Enddo
	( cQAlSQL )->(DbCloseArea())

	// Grava Serviços
	cQuery := "SELECT VOK.R_E_C_N_O_ AS RECVOK, V03.* "
	cQuery += "  FROM "+RetSqlName("V03")+" V03 "
	cQuery += "  JOIN "+RetSqlName("VOK")+" VOK  ON (VOK.VOK_FILIAL= ? AND VOK.VOK_TIPSER = V03.V03_TIPSER AND VOK.D_E_L_E_T_ = ' ')"
	cQuery += " WHERE V03.V03_FILIAL = ? "
	cQuery += "   AND V03.V03_CODAGE = ? AND V03.D_E_L_E_T_=' ' "
	cQuery += " ORDER BY V03.R_E_C_N_O_"
	
	aParams := {}
	aAdd(aParams, xFilial("VOK")  )
	aAdd(aParams, xFilial("V03")  )
	aAdd(aParams, VSO->VSO_NUMIDE )

	oExec := FWExecStatement():New()
	oExec:SetQuery(cQuery)
	oExec:SetParams(aParams)

	cQAlSQL := oExec:OpenAlias()

	While !( cQAlSQL )->( Eof() )
		++nAuxSeqVS4
		dbSelectArea("VOK")
		DbGoTo( (cQAlSQL)->( RECVOK ) )
		nValHor := If(VOK->VOK_INCMOB $ "0/2/5/6",0,FG_VALHOR(cTTPadSer,dDataAtual,,,VSO->VSO_CODMAR,(cQAlSQL)->( V03_CODSER ),(cQAlSQL)->( V03_TIPSER ),VSO->VSO_PROVEI,VSO->VSO_LOJPRO))
		nValSer := ((cQAlSQL)->( V03_TEMPAD ) /100) * nValHor
		aVetAux := {}
		aAdd(aVetAux,{"VS4_SEQUEN",STRZERO(nAuxSeqVS4,TamSX3("VS4_SEQUEN")[1])}) // Sequencia
		aAdd(aVetAux,{"VS4_SEQINC",(cQAlSQL)->( V03_SEQINC )})	// Sequencia Inconveniente
		aAdd(aVetAux,{"VS4_GRUSER",(cQAlSQL)->( V03_GRUSER )}) 	// Grupo de Servico
		aAdd(aVetAux,{"VS4_CODSER",(cQAlSQL)->( V03_CODSER )}) 	// Codigo do Servico
		aAdd(aVetAux,{"VS4_TIPSER",(cQAlSQL)->( V03_TIPSER )}) 	// Tipo de Servico
		aAdd(aVetAux,{"VS4_TEMPAD",(cQAlSQL)->( V03_TEMPAD )})	// Tempo Padrao
		aAdd(aVetAux,{"VS4_VALHOR",nValHor}) 			// Vlr da Hora
		aAdd(aVetAux,{"VS4_CODPRO",(cQAlSQL)->( V03_CODPRO )})	// Tipo de Servico
		aAdd(aVetAux,{"VS4_KILROD",0}) 								// Kilometro Rodado
		aAdd(aVetAux,{"VS4_VALSER",nValSer}) 					// Valor do Servico
		aAdd(aVetAux,{"VS4_CODSEC",(cQAlSQL)->( V03_CODSEC )})	// Secao da Oficina
		aAdd(aVetAux,{"VS4_VALTOT",nValSer}) 					// Valor Total
		aAdd(aVetAux,{"VS4_SEQSER",""})

		aAdd(aVetVS4,aClone(aVetAux))
		( cQAlSQL )->(DbSkip())
	Enddo
	( cQAlSQL )->(DbCloseArea())

	cNumOrc := OA6020011_CriaOrcamento( aVetVS1 , aVetVST , aVetVS3 , aVetVS4 ) // Cria Orcamento com VS1 / VST - Inconvenientes / VS3 - Pecas / VS4 - Servicos

EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Atualiza Status do Agendamento³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
OM350STATUS(VSO->VSO_NUMIDE,"1","5")

if lDiarioOficina
	OA5480062_RegistraEventoDiarioOficina(VS1->VS1_NUMORC, "012") // 012 – ELABORACAO DO PRIMEIRO ORCAMENTO
endif

End Transaction

If nTp == 1 // Criar Novo Orcamento

	FWAlertInfo( STR0122 + CHR(13)+CHR(10)+CHR(13)+CHR(10) + VS1->VS1_NUMORC , STR0029) //Orçamento gerado com sucesso! //Atenção

Else // nTp == 2 // Relacionar Agendamento com Orcamento existente
	
	FWAlertInfo( STR0123 , STR0029 ) // Orçamento relacionado com sucesso! // Atenção
EndIf

Return()

/*/{Protheus.doc} OA602043M_VLDGRUPOMARCA
Valida a presença do grupo / marca usado na tabela VSK
@type function
@version
@author Jessé Augusto
@since 18/11/2025
@param cCodMar, character, param_description
@param cGruInc, character, param_description
@return variant, return_description
/*/
 
Static Function OA602043M_VLDGRUPOMARCA(cCodMar,cGruInc)
	Local lRet 		:= .f.
	Local cAliasVSK := "SQLVSK"

	cQuery := "SELECT VSK.R_E_C_N_O_ RECVSK , VSK.VSK_CODMAR "
	cQuery += "FROM "+RetSQLName("VSK")+" VSK "
	cQuery += "WHERE VSK.VSK_FILIAL= ? AND VSK.VSK_CODGRU = ? AND VSK.D_E_L_E_T_ = ' '"

	aParams := {}
	aAdd(aParams, xFilial("VSK") )
	aAdd(aParams, cGruInc  		 )
	
	oExec := FWExecStatement():New()
	oExec:SetQuery(cQuery)
	oExec:SetParams(aParams)

	cAliasVSK := oExec:OpenAlias()

	Do While !( cAliasVSK )->( Eof() )

		VSK->(DBGoTo(( cAliasVSK )->RECVSK))

		if ( cAliasVSK )->VSK_CODMAR == cCodMar .or. Empty(( cAliasVSK )->VSK_CODMAR)
			lRet := .t.
			Exit
		Else
			lRet := .f.
		Endif
		dbSelectArea(cAliasVSK)
		( cAliasVSK )->(dbSkip())
	Enddo

	( cAliasVSK )->( dbCloseArea() )

Return(lRet)

/*/{Protheus.doc} OA602044M_TPO15
Define o tempo informado
@type function
@version
@author Jessé Augusto
@since 18/11/2025
@param nTpoConv, numeric, param_description
@return variant, return_description
/*/
Static Function OA602044M_TPO15(nTpoConv)

	Local cHorInf := ""
	Local cMinInf := ""

	cHorInf :=  Left(StrZero(nTpoConv,5),3)
	cMinInf := Right(StrZero(nTpoConv,5),2)
	If Val(cMinInf) > 0 .and. Val(cMinInf) < 15
		nTpoConv := Val(cHorInf+"15")
	ElseIf Val(cMinInf) > 15 .and. Val(cMinInf) < 30
		nTpoConv := Val(cHorInf+"30")
	ElseIf Val(cMinInf) > 30 .and. Val(cMinInf) < 45
		nTpoConv := Val(cHorInf+"45")
	ElseIf Val(cMinInf) > 45 .and. Val(cMinInf) <= 99
		nTpoConv := Val(Left(StrZero(Val(cHorInf)+1,3),3)+"00")
	Endif
Return nTpoConv

Static Function MenuDef()
	Local aRotOA602 := {}
	
	aAdd(aRotOA602,{ STR0124  , "AxPesqui"  			        , 0 , 1     })  // Pesquisar
	aAdd(aRotOA602,{ STR0125  , "OA602010M_VISUALIZA"           , 0 , 2     })  // Visualizar // OA602010M_Visualiza
	aAdd(aRotOA602,{ STR0126  , "OA602011M_INCLUI"    	        , 0 , 3     })  // Incluir
	aAdd(aRotOA602,{ STR0127  , "OA602012M_ALTERA"    	        , 0 , 4     })  // Alterar
	aAdd(aRotOA602,{ STR0128  , "OA602013M_CANCELA"   	        , 0 , 5     })  // Cancelar
	aAdd(aRotOA602,{ STR0129  , "OM350L"    			        , 0 , 0 , 2 })  // Legenda
	aAdd(aRotOA602,{ STR0130  , "OA602041M_CONTROLA_ORCAMENTO"  , 0 ,     2 })  // Orcamento
	aAdd(aRotOA602,{ STR0131  , "OM350OS"   , 0 , 2     					})  // Consulta O.S.
	aAdd(aRotOA602,{ STR0132  , "OM350CONF" , 0 , 2     					})  // Confirma Agendam.
	aAdd(aRotOA602,{ STR0227  , "OA6020102_AbrirOS" , 0 , 3     			})  // Abrir O.S.
	

	if ExistBlock("OM350PRO")
		aAdd(aRotOA602,{ STR0133 , "U_OM350PRO" , 0 , 2 })   					// Relatorio de Pré-Ordem de servico.
	EndIf
	
	aAdd(aRotOA602,{ STR0134 , "OFIXC006" 					, 0 , 2 })  		// Confirma Presenca
	aAdd(aRotOA602,{ STR0135 , "OA6020061_ClonarAgendamento" , 0 , 4 })  		// Clonar Agendamento

	If ExistBlock("OA602ROT")
		aRecebe := ExecBlock("OA602ROT",.f.,.f.,{aRotOA602} )
		If ( ValType(aRecebe) == "A" )
			aRotOA602 := aClone(aRecebe)
		EndIf
	Endif

Return aRotOA602

/*/{Protheus.doc} OA602045M_LEGHR
Legenda de horário
@type function
@version
@author Jessé Augusto
@since 18/11/2025
@return variant, return_description
/*/
Function OA602045M_LEGHR()

	Local aLegenda := {}

	aAdd(aLegenda,{'BR_VERDE'   , STR0136 })  // Livre
	aAdd(aLegenda,{'BR_AZUL'    , STR0137 })  // Agendado
	aAdd(aLegenda,{'BR_VERMELHO', STR0138 })  // Já utilizado

	BrwLegenda(STR0139,STR0140,aLegenda) 	  // Horários // Legenda

Return

/*/{Protheus.doc} OA602046M_ENVIA_EMAIL
Dispara o envio de e-mail
@type function
@version
@author Jessé Augusto
@since 18/11/2025
@param nOpc, numeric, param_description
@return variant, return_description
/*/
Static Function OA602046M_ENVIA_EMAIL(nOpc)
	Local lOk := .f., lSendOK := .f.
	Local cError := ""
	Local nCount := 0
	Local cMailConta := GETMV("MV_EMCONTA")               // Usuario/e-mail de envio
	Local cMailServer:= GETMV("MV_RELSERV")               // Server de envio
	Local cMailSenha := GETMV("MV_EMSENHA")               // Senha e-mail de envio
	Local lAutentica := GetMv("MV_RELAUTH",,.f.)          // Determina se o Servidor de E-mail necessita de Autenticacao
	Local cUserAut   := Alltrim(GetMv("MV_RELAUSR",," ")) // Usuario para Autenticacao no Servidor de E-mail
	Local cPassAut   := Alltrim(GetMv("MV_RELAPSW",," ")) // Senha para Autenticacao no Servidor de E-mail
	Local cMsgPerg   := STR0141 						  // Deseja enviar e-mail de confirmação para o cliente?
	Private cEmail	 := ""
	Private cTitulo  := STR0142  						  // Confirmacao do Agendamento
	Private cMensagem := ""
	
	If !Empty(M->VSO_EMAIL)
		cEmail := alltrim(M->VSO_EMAIL)
	EndIf

	If !Empty(M->VSO_GESTOR)
		DbSelectArea("VAI")
		DbSetOrder(1)
		DbSeek(xFilial("VAI")+M->VSO_GESTOR)
		cEmail += ";"+alltrim(VAI->VAI_EMAIL)
	EndIf

	If !Empty(M->VSO_EMAIL) .and. !Empty(cMailConta) .And. !Empty(cMailServer) .And. !Empty(cMailSenha)
		If nOpc == 5 // Excluir
			OA602067M_PERGUNTE(.f.)
			IF MV_PAR01 <> 1
				Return .t.
			EndIf
			cTitulo  := STR0143 // Cancelamento de Agendamento
			cMsgPerg := STR0144 // Deseja enviar e-mail de cancelamento para o cliente ?
		EndIf
		If !FWAlertYesNo(cMsgPerg, STR0029)  // Deseja enviar e-mail de confirmação para o cliente?  // Atencao
			Return .t.
		EndIf
		DbSelectArea("VON")
		DbSetOrder(1)
		DbSeek( xFilial("VON") + M->VSO_NUMBOX )
		If ExistBlock("O351EMAIL")                       // Ponto de Entrada para formatacao do email
			ExecBlock("O351EMAIL",.f.,.f.)
		Else // HTML Padrao //
			cMensagem+= "<center><table border=0 width=80%><tr>"
			If !Empty( GetNewPar("MV_ENDLOGO","") )
				cMensagem+= "<td width=20%><img src='" + GetNewPar("MV_ENDLOGO","") + "'></td>"
			EndIf
			cMensagem+= "<td align=center width=80%><font size=3 face='verdana,arial' Color=#0000cc><b>"
			cMensagem+= FWFilialName()+"<br></font></b>"
			cMensagem+= "</td></tr></table><hr width=80%>"
			cMensagem+= "<font size=3 face='verdana,arial' Color=black><b>"+cTitulo+"<br></font></b><hr width=80%><br>"
			cMensagem+= "<table border=0 width=80%><tr>"
			cMensagem+= "<td><font size=3 face='verdana,arial' Color=black>"+ STR0145 +":"+"</font></td>" // Data
			cMensagem+= "<td><font size=3 face='verdana,arial' Color=#0000cc><b>"+Transform(M->VSO_DATAGE,"@D")+" - "+FG_CDOW(M->VSO_DATAGE)+"</b></font></td>"
			cMensagem+= "<td><font size=3 face='verdana,arial' Color=black>"+ STR0146 +":"+"</font></td>" // Hora
			cMensagem+= "<td><font size=3 face='verdana,arial' Color=#0000cc><b>"+Transform(M->VSO_HORAGE,"@R 99:99")+"</b></font></td>"
			cMensagem+= "<td><font size=3 face='verdana,arial' Color=black>"+ STR0147 +":"+"</font></td>" // Box
			cMensagem+= "<td><font size=3 face='verdana,arial' Color=#0000cc><b>"+M->VSO_NUMBOX+"</b></font></td>"
			cMensagem+= "</tr></table><br>"
			cMensagem+= "<table border=0 width=80%><tr>"
			cMensagem+= "<td><font size=3 face='verdana,arial' Color=black>"+ STR0148 +":"+"</font></td>" // Chassi
			cMensagem+= "<td><font size=3 face='verdana,arial' Color=#0000cc><b>"+M->VSO_GETKEY+"</b></font></td>"
			cMensagem+= "<td><font size=3 face='verdana,arial' Color=black>"+ STR0149 +":"+"</font></td>" // Placa
			cMensagem+= "<td><font size=3 face='verdana,arial' Color=#0000cc><b>"+Transform(M->VSO_PLAVEI,VV1->(x3Picture("VV1_PLAVEI")))+"</b></font></td>"
			cMensagem+= "</tr><tr>"
			cMensagem+= "<td><font size=3 face='verdana,arial' Color=black>"+ STR0150 +":"+"</font></td>" // Proprietario
			cMensagem+= "<td><font size=3 face='verdana,arial' Color=#0000cc><b>"+M->VSO_NOMPRO+"</b></font></td>"
			cMensagem+= "<td><font size=3 face='verdana,arial' Color=black>"+ STR0151 +":"+"</font></td>" // Fone
			cMensagem+= "<td><font size=3 face='verdana,arial' Color=#0000cc><b>"+M->VSO_FONPRO+"</b></font></td>"
			cMensagem+= "</tr><tr>"
			cMensagem+= "<td><font size=3 face='verdana,arial' Color=black>"+ STR0152 +":"+"</font></td>" // Endereco
			cMensagem+= "<td><font size=3 face='verdana,arial' Color=#0000cc><b>"+M->VSO_ENDPRO+"</b></font></td>"
			cMensagem+= "<td><font size=3 face='verdana,arial' Color=black>"+ STR0153 +":"+"</font></td>" // Cidade
			cMensagem+= "<td><font size=3 face='verdana,arial' Color=#0000cc><b>"+M->VSO_CIDPRO+" - "+M->VSO_ESTPRO+"</b></font></td>"
			cMensagem+= "</tr></table><br>"
			If GetNewPar("MV_MOBSEMA","N") == "S" .and. !Empty(M->VSO_OBSERV)
				cMensagem+= "<table border=0 width=80%><tr><td>"
				cMensagem+= "<pre><font size=3 face='verdana,arial' Color=black>"+ STR0154 +":"+"</font><br>" // Observacao
				cMensagem+= "<font size=2 face='verdana,arial' Color=#0000cc><b>" + M->VSO_OBSERV + "</b></font></pre>"
				cMensagem+= "</td></tr></table>"
			EndIf
			cMensagem+= "<table border=1 width=80%><tr>"
			cMensagem+= "<td bgcolor=#0000cc><font size=1 face='verdana,arial' color=white><b>"+ STR0155 +"</font></b></td>" // Servicos Agendados
			cMensagem+= "</tr>"
			For nCount := 1 to len(oGetDadV00:aCols)
				If !oGetDadV00:aCols[nCount,len(oGetDadV00:aCols[nCount])]
					cMensagem+= "<tr><td><font size=2 face='verdana,arial' color=#0000cc><b>"
					cMensagem+= oGetDadV00:aCols[nCount,FG_POSVAR("V00_DESCRI","aHeaderV00")]
					cMensagem+= "</font></b></td></tr>"
				EndIf
			Next
			cMensagem+= "</table><br><hr width=80%><table border=0 width=80%><tr>"
			cMensagem+= "<td><p align=justify><font size=1 face='verdana,arial' Color=black>"
			cMensagem+= "Lembrete: Para melhor atendê-lo, solicitamos que compareça com 5 minutos de antecedência. Em caso de atraso superior"+" "
			cMensagem+= "a 15 minutos, liberaremos seu horário para outro atendimento. Solicitamos também sua permanência nos primeiros 20"+" "
			cMensagem+= "minutos do atendimento para realizar a inspecção visual dos componentes do seu veículo junto ao Técnico designado. Em caso de"+" "
			cMensagem+= "necessidade de alteração da data/hora do atendimento, por favor, entre em contacto com nosso centro de atendimento ao cliente pelo telefone"+".<br>"
			cMensagem+= "A"+" "+FWFilialName()+", através do Departamento de Atendimento ao Cliente. Agradecemos a preferência."+"</p>"
			cMensagem+= "</font></td></tr></table><hr width=80%><table border=0 width=80%><tr>"
			cMensagem+= "<td><font size=1 face='verdana,arial' Color=black>"+ STR0137 +":"+"</font></td>" // Agendado
			cMensagem+= "<td><font size=1 face='verdana,arial' Color=black>"+M->VSO_NOMAGE+"</font></td>"
			cMensagem+= "<td><font size=1 face='verdana,arial' Color=black>"+ STR0145 +":"+"</font></td>" // Data
			cMensagem+= "<td><font size=1 face='verdana,arial' Color=black>"+Transform(M->VSO_DATREG,"@D")+"</font></td>"
			cMensagem+= "<td><font size=1 face='verdana,arial' Color=black>"+ STR0146 +":"+"</font></td>" // Hora
			cMensagem+= "<td><font size=1 face='verdana,arial' Color=black>"+Transform(M->VSO_HORREG,"@R 999:99")+"</font></td>" // hs
			cMensagem+= "</tr></table><br></center>"
		EndIf
		// Conecta uma vez com o servidor de e-mails
		CONNECT SMTP SERVER cMailServer ACCOUNT cMailConta PASSWORD cMailSenha RESULT lOk
		If lOk
			lOk := .f.
			If lAutentica
				If !MailAuth(cUserAut,cPassAut)
					FMX_HELP( "OA6020461", STR0156, STR0157 ) // Erro no envio de e-mail // Verifique se as credenciais de autenticaçao estão corretas e tente novamente
					
					DISCONNECT SMTP SERVER
				Else
					lOk := .t.
				EndIf
			Else
				lOk := .t.
			EndIf
			If lOk
				// Envia e-mail com os dados necessarios
				SEND MAIL FROM cMailConta to Alltrim(cEmail) SUBJECT (cTitulo) BODY cMensagem FORMAT TEXT RESULT lSendOk
				If !lSendOk
					//Erro no Envio do e-mail
					GET MAIL ERROR cError
					FMX_HELP( "OA6020462", STR0156, STR0157 ) // Erro no envio de e-mail // Verifique se as credenciais de autenticaçao estão corretas e tente novamente
				EndIf
				// Desconecta com o servidor de e-mails
				DISCONNECT SMTP SERVER
			EndIf
		Else
			FMX_HELP( "OA6020463", STR0158 +" "+ chr(13)+chr(10) + cMailServer , STR0157 ) // Não foi possivel conectar no servidor de e-mail. // Verifique se as credenciais de autenticaçao estão corretas e tente novamente
		EndIf
	EndIf

Return(.t.)


/*/{Protheus.doc} OA602067M_PERGUNTE
Configurações da Rotina
@author Rubens
@since 18/05/2017
@version undefined
@param lExibe, logical, descricao
@type function
/*/
Static Function OA602067M_PERGUNTE(lExibe)

	Pergunte( "OFIA602", lExibe,,,,.f.)
Return

/*/{Protheus.doc} OA602069M_ALTVEI
Alterar Dados do Veiculo
@author Manoel
@since 19/06/2018
@version undefined
@param nopc, cChassi
@type function
/*/
Static Function OA602069M_ALTVEI(nOpc,cChassi)

	If !Empty(cChassi) .and. ( nOpc == 3 .or. nOpc == 4 )
		DbSelectArea("VV1")
		DbSetOrder(2)
		If DbSeek(xFilial("VV1")+cChassi)
			FGX_ALTVEI("A") // 28/02/2012 - VEIXFUNA - FGX_ALTVEI 
			OA602071M_CARREGA()
		EndIf
	EndIf

Return

/*/{Protheus.doc} OA602071M_CARREGA
Carrega M-> do VSO e VST
@type function
@version
@author Andre Luis Almeida
@since 19/11/2025
@return variant, return_description
/*/
Static Function OA602071M_CARREGA()

	M->VSO_CHAINT := VV1->VV1_CHAINT
	M->VSO_PLAVEI := VV1->VV1_PLAVEI
	M->VSO_CODFRO := VV1->VV1_CODFRO

	dbSelectArea("VSO")
	VV2->(DbSelectArea(1))
	VV2->(DbSeek(xFilial("VV2")+VV1->VV1_CODMAR+VV1->VV1_MODVEI))
	VVC->(DbSelectArea(1))
	VVC->(DbSeek(xFilial("VVC")+VV1->VV1_CODMAR+VV1->VV1_CORVEI))
	SA1->(DbSelectArea(1))
	SA1->(DbSeek(xFilial("SA1")+VV1->VV1_PROATU+VV1->VV1_LJPATU))
	
	DbSelectArea("VE1")
	DbSetOrder(1)
	DbSeek(xFilial("VE1") + VV1->VV1_CODMAR)
	
	M->VSO_CODMAR := VE1->VE1_CODMAR
	M->VSO_DESMAR := VE1->VE1_DESMAR
	M->VSO_MODVEI := VV2->VV2_MODVEI
	M->VSO_DESMOD := VV2->VV2_DESMOD
	M->VSO_DESCOR := VVC->VVC_DESCRI
	M->VSO_PROVEI := SA1->A1_COD
	M->VSO_NOMPRO := SA1->A1_NOME
	M->VSO_LOJPRO := SA1->A1_LOJA
	M->VSO_ENDPRO := SA1->A1_END
	M->VSO_CIDPRO := SA1->A1_MUN
	M->VSO_ESTPRO := SA1->A1_EST
	M->VSO_FONPRO := SA1->A1_TEL
	M->VSO_EMAIL  := Left(SA1->A1_EMAIL+space(Len(VSO->VSO_EMAIL)),Len(VSO->VSO_EMAIL))
	M->VST_CODMAR := VE1->VE1_CODMAR

Return()

/*/{Protheus.doc} OA6020061_ClonarAgendamento
Clonar Agendamento
@author Andre Luis Almeida
@since 12/08/2019
@version undefined
@type function
/*/

Function OA6020061_ClonarAgendamento()
	
	OA602014M_EXECUTA("VSO",VSO->(RecNo()),4,.t.)

Return

/*/{Protheus.doc} OA6020011_CriaOrcamento
Cria Orcamento VS1, VST, VS3 e VS4
@type function
@version
@author Andre Luis Almeida
@since 23/01/2020
@param aVetVS1, array, param_description
@param aVetVST, array, param_description
@param aVetVS3, array, param_description
@param aVetVS4, array, param_description
@return variant, return_description
/*/
Static Function OA6020011_CriaOrcamento( aVetVS1 , aVetVST , aVetVS3 , aVetVS4 )
	Local nCntFor := 0
	Local nCntAux := 0
	Local aVetAux  := {}
	
	dbSelectArea("VS1")
	RecLock("VS1",.T.)
		VS1->VS1_FILIAL := xFilial("VS1")
		VS1->VS1_NUMORC := GetSXENum("VS1","VS1_NUMORC",,1)
		ConfirmSX8()
		For nCntFor := 1 to len(aVetVS1)
			&(aVetVS1[nCntFor,1]) := aVetVS1[nCntFor,2]
		Next
		//Ponto de entrada para gravacao do agendamento no orcamento.
		If ExistBlock("OF350GRORC")
			ExecBlock("OF350GRORC",.f.,.f.)
		EndIf
	MsUnLock()
	For nCntFor := 1 to len(aVetVST)
		aVetAux := aClone(aVetVST[nCntFor])
		dbSelectArea("VST")
		RecLock("VST",.T.)
			VST->VST_FILIAL := xFilial("VST")
			VST->VST_TIPO   := "1"
			VST->VST_CODIGO := VS1->VS1_NUMORC
			For nCntAux := 1 to len(aVetAux)
				&(aVetAux[nCntAux,1]) := aVetAux[nCntAux,2]
			Next
		MsUnLock()
	Next
	For nCntFor := 1 to len(aVetVS3)
		aVetAux := aClone(aVetVS3[nCntFor])
		dbSelectArea("VS3")
		RecLock("VS3",.T.)
			VS3->VS3_FILIAL := xFilial("VS3")
			VS3->VS3_NUMORC := VS1->VS1_NUMORC
			For nCntAux := 1 to len(aVetAux)
				&(aVetAux[nCntAux,1]) := aVetAux[nCntAux,2]
			Next
		MsUnLock()
	Next
	For nCntFor := 1 to len(aVetVS4)
		aVetAux := aClone(aVetVS4[nCntFor])
		dbSelectArea("VS4")
		RecLock("VS4",.T.)
			VS4->VS4_FILIAL := xFilial("VS4")
			VS4->VS4_NUMORC := VS1->VS1_NUMORC
			For nCntAux := 1 to len(aVetAux)
				&(aVetAux[nCntAux,1]) := aVetAux[nCntAux,2]
			Next
		MsUnLock()
	Next
	If ExistFunc("FM_GerLog")
		//grava log das alteracoes das fases do orcamento
		FM_GerLog("F",VS1->VS1_NUMORC)
	EndIf
Return VS1->VS1_NUMORC

/*/{Protheus.doc} OA6020081_Inconvenientes_PlanoRevisao
	Inconvenientes e Plano de Revisao - chamada da Funcao OM350INCPR do OFIOM350
	 
	@type function
	@author Andre Luis Almeida
	@since 19/10/2021
/*/
Static Function OA6020081_Inconvenientes_PlanoRevisao(nOpc)
	Private oAuxGetDados := oGetDadVST // Objeto utilizado no OFIOM350

	Processa( {|| OM350INCPR(nOpc) } )

	oGetDadVST := oAuxGetDados // Volta Objeto oGetDadVST

Return

/*/{Protheus.doc} OA6020091_SelecionaOrcamento
	Seleciona o Orcamento corresponte ao Agendamento
	 
	@type function
	@author Andre Luis Almeida
	@since 04/11/2021
/*/
Static Function OA6020091_SelecionaOrcamento(cNumAge)
	Local cNroVS1 := ""
	Local cQuery  := ""
	Local cQAlSQL := "SQLVS1"
	Local aOrctos := {}

	cQuery := "SELECT VS1.VS1_NUMORC , VS1.VS1_DATORC , VS1.VS1_CLIFAT , VS1.VS1_LOJA , SA1.A1_NOME "
	cQuery += "  FROM "+RetSqlName("VS1")+" VS1 "
	cQuery += "  JOIN "+RetSqlName("SA1")+" SA1 ON SA1.A1_FILIAL= ? AND SA1.A1_COD=VS1.VS1_CLIFAT AND SA1.A1_LOJA=VS1.VS1_LOJA AND SA1.D_E_L_E_T_=' '"
	cQuery += " WHERE VS1.VS1_FILIAL = ? "
	cQuery += "   AND VS1.VS1_NUMAGE = ? "
	cQuery += "   AND VS1.D_E_L_E_T_=' ' "
	
	aParams := {}
	aAdd( aParams, xFilial("SA1") )
	aAdd( aParams, xFilial("VS1") )
	aAdd( aParams, cNumAge 		  )

	oExec := FWExecStatement():New()
	oExec:SetQuery(cQuery)
	oExec:SetParams(aParams)

	cQAlSQL := oExec:OpenAlias()

	While !( cQAlSQL )->( Eof() )
		aadd(aOrctos,{	( cQAlSQL )->( VS1_NUMORC ) ,;
						stod(( cQAlSQL )->( VS1_DATORC )) ,;
						( cQAlSQL )->( VS1_CLIFAT ) ,;
						( cQAlSQL )->( VS1_LOJA ) ,;
						( cQAlSQL )->( A1_NOME ) })
		( cQAlSQL )->( DbSkip() )
	EndDo
	( cQAlSQL )->( DbCloseArea() )
	If len(aOrctos) == 1
		cNroVS1 := aOrctos[1,1] // Unico Orcamento
	ElseIf len(aOrctos) > 1 // Escolher Orcamento
		DEFINE MSDIALOG oTELASELORC TITLE STR0207 FROM  00,00 TO 23,55 OF oMainWnd // Selecione o Orçamento a Visualizar
			oLbOrctos := TWBrowse():New( 05,05,210,150,,,,oTELASELORC,,,,,,,,,,,,.F.,,.T.,,.F.,,,)
			oLbOrctos:addColumn( TCColumn():New( STR0130, { || aOrctos[oLbOrctos:nAt,01] } ,,,, "LEFT" , 37 ,.F.,.F.,,,,.F.,) ) 	 // Orçamento
			oLbOrctos:addColumn( TCColumn():New( STR0145, { || aOrctos[oLbOrctos:nAt,02] } ,,,, "LEFT" , 37 ,.F.,.F.,,,,.F.,) ) 	 // Data
			oLbOrctos:addColumn( TCColumn():New( STR0169, { || aOrctos[oLbOrctos:nAt,03]+"-"+aOrctos[oLbOrctos:nAt,04]+" - "+aOrctos[oLbOrctos:nAt,05] } ,,,, "LEFT" , 100 ,.F.,.F.,,,,.F.,) ) // Cliente
			oLbOrctos:bLDblClick   := { || cNroVS1 := aOrctos[oLbOrctos:nAt,01] , oTELASELORC:End() }
			oLbOrctos:nAt := 1
			oLbOrctos:SetArray(aOrctos)
			DEFINE SBUTTON FROM 157,154 TYPE 1 ACTION ( cNroVS1 := aOrctos[oLbOrctos:nAt,01] , oTELASELORC:End()) ENABLE OF oTELASELORC
			DEFINE SBUTTON FROM 157,184 TYPE 2 ACTION (oTELASELORC:End()) ENABLE OF oTELASELORC
		ACTIVATE MSDIALOG oTELASELORC CENTER
	EndIf
	DbSelectArea("VS1")

Return cNroVS1

/*/{Protheus.doc} OA602070M_AtualizaListaTarefas
Replica as tarefas digitadas pelo usuário da primeira para aúltima pasta
@type function
@version
@author Jessé Augusto
@since 02/12/2025
@param oGetDadV00, object, param_description
@param oGetDadVST, object, param_description
@return variant, return_description
/*/
Static Function OA602070M_AtualizaListaTarefas( oGetDadV00, oGetDadVST )
	Local nTam     :=  1
	Local aLinCols := {}

	aLinCols := aClone( oGetDadVST:aCols[1] )
	
	nLin     := oGetDadV00:nAt
	nSeqV00  := aSCan( oGetDadV00:aHeader, {|x| x[2] == "V00_SEQUEN"}) // Sequencia
	nSeqTar  := aSCan( oGetDadVST:aHeader, {|x| x[2] == "VST_SEQTAR"}) // Seq Tarefa
	nSeqInc  := aSCan( oGetDadVST:aHeader, {|x| x[2] == "VST_SEQINC"}) // Sequencial
	nDesInc  := aSCan( oGetDadVST:aHeader, {|x| x[2] == "VST_DESINC"}) // Descrição Tarefa / Pacote
	nPacote  := aSCan( oGetDadVST:aHeader, {|x| x[2] == "VST_GRUINC"}) // Grupo de Pacote
	
	cSeq 	 := oGetDadV00:aCols[nLin][nSeqV00]

	nPos 	 := aSCan( oGetDadVST:aCols,{|x| x[nSeqTar] == cSeq  })

	If nPos > 0

		oGetDadVST:aCols[nPos][nDesInc] := Alltrim(M->V00_DESCRI)
	Else
		nTam   := Len(oGetDadVST:aCols)

		lLinOk := nTam == 1 .And. Empty( oGetDadVST:aCols[nTam][nSeqTar] + oGetDadVST:aCols[nTam][nPacote])

		If !lLinOk
			
			oGetDadVST:AddLine(.T.,.F.) // Atualiza aCols e Add linha sem validação
			nTam := Len( oGetDadVST:aCols )
			oGetDadVST:lNewLine := .F. // Impedir a inserção manual de linhas
		EndIf

		oGetDadVST:aCols[nTam][nSeqTar] := cSeq
		oGetDadVST:aCols[nTam][nSeqInc] := StrZero( nTam, TamSX3("V00_SEQUEN")[1] )
		oGetDadVST:aCols[nTam][nDesInc] := Alltrim(M->V00_DESCRI)
	EndIf

	oGetDadV00:oBrowse:Refresh()
	oGetDadVST:oBrowse:Refresh()

Return

/*/{Protheus.doc} OA602073M_ReordenaItem
Ordena os campos do dicionário
@type function
@version
@author Jessé Augusto
@since 16/12/2025
@param oGetDados, object, param_description
@param aItens, array, param_description
@return variant, return_description
/*/
Static Function OA602073M_ReordenaItem( aHeader, aItens )

	Local nX         := 0
	Local aAux       := {}
	Local aNovaOrdem := {}

	aAux 			 := aClone(aHeader)

	For nX := 1 To Len( aItens )

		nPos := aSCan( aAux,{|x| Upper( Alltrim( aItens[nX] ) ) == Alltrim(x[2]) })

		If nPos > 0
			
			aAdd( aNovaOrdem, aClone( aAux[nPos] ) )
			
			ADel( aAux , nPos          )
			ASize( aAux, Len(aAux) - 1 )
		EndIf

	Next nX
	
	For nX := 1 To Len( aAux )

		aAdd( aNovaOrdem, aClone( aAux[nX] ) )

	Next nX
	
	If !Empty(aNovaOrdem)
		
		aHeader := aClone( aNovaOrdem )
	EndIf

Return aHeader


/*/{Protheus.doc} OA6020102_AbrirOS
Abre a tela OS para criação com base no agendamento

@author Bruno Forcato
@since 20/02/2026
@type function
/*/
function OA6020102_AbrirOS()
	local cAlias := GetNextAlias()
	Private lGarMut := (VO1->(FieldPos("VO1_GARMUT")) <> 0 )
	Private nValGarMut := 0
	Private lA1_IBGE := If(SA1->(FieldPos("A1_IBGE"))>0,.t.,.f.)
	Private nLimCre := val(&(GetMV("MV_LIMCRE"))) , nIndVO1 := 0
	Private lImpOsv := .t.

	If !( VSO->VSO_STATUS $ "1/5" )
		FMX_HELP("OA6020102", STR0228 + " ( " + Upper(Alltrim(X3CBoxDesc("VSO_STATUS",VSO->VSO_STATUS ))) + " )" , STR0229 ) // "Impossivel ALTERAR Agendamento da Oficina com STATUS // Utilize um Agedamento cujo Orçamento ainda não tenha sido gerado
		Return
	EndIf

	OM010I(cAlias,,3, .t.)
return