#INCLUDE "TOTVS.CH"
#include "OFIPA980.CH"
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡Æo    ³ OFIPA980 ³ Autor ³  Emilton              ³ Data ³ 24/06/99 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡Æo ³ Parametro da Fabrica                                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Generico                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function OFIPA980()
Private cCadastro := OemToAnsi(STR0006)

/////////////////////////////////////////////////////////////////////////////////////////////////////
// Valida se a empresa tem autorizacao para utilizar os modulos de Veiculos, Oficina ou Auto-Peças //
/////////////////////////////////////////////////////////////////////////////////////////////////////
If !AMIIn(11,14,41) .or. !FMX_AMIIn({"OFIPA980"})
	Return()
EndIf

axCadastro("VE4", cCadastro,"FS_VERDEL()")

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³FL_DESCRI980³ Autor ³ Fabio               ³ Data ³ 13/07/99 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Retorno de Descricoes                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ wAliasO -> Aquivo que vai ser pesquisado                   ³±±
±±³          ³ cChave  -> Chave do arquivo pesquisado                     ³±±
±±³          ³ cOrdem  -> Ordem usada na pesquisa                         ³±±
±±³          ³ cCamposO-> Campos que serao retornados do arquivo de pesq. ³±±
±±³          ³ cCamposD-> Campos que receberao o conteudo das variaveis   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Generico                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function FS_DESCRI980()
If FG_SEEK("SA1","M->VE4_CGCFAB",3,.f.) == .F.
	MsgStop(OemToAnsi(STR0007)) //"Montadora NAO cadastrada no cadastro de Clientes !"
	Return .f.
EndIf
M->VE4_CODFAB := SA1->A1_COD
M->VE4_LOJA   := SA1->A1_LOJA
M->VE4_NOMFAB := SA1->A1_NOME
If FG_SEEK("SA2","M->VE4_CGCFAB",3,.f.) == .F.
	MsgStop(OemToAnsi(STR0008)) //"Montadora NAO cadastrada no cadastro de Fornecedor!"
	Return .f.
EndIf
M->VE4_CODFOR := SA2->A2_COD
M->VE4_LOJFOR := SA2->A2_LOJA
Return .t.

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡Æo    ³ FS_VERDEL³ Autor ³  Emilton              ³ Data ³ 11/10/01 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡Æo ³ Alerta o usuario para a delecao deste registro             ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function FS_VERDEL()

Return MsgYesNo(OemToAnsi(STR0009),OemToAnsi(STR0010))

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡Æo    ³ FS_VERSEG³ Autor ³  Emilton              ³ Data ³ 14/11/01 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡Æo ³ Verifica segmento do modelo                                ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function FS_VERSEG()
Local lRet := .t.
Local aAlias := SGetArea()
Local lSegMod := M->VE4_SEGMOD == "0"
SGetArea(aAlias,"VV2")
// Analisa se existe algum modelo previamente cadastrado para manter compatibilidade com o que estiver parametrizado
// na marca em cadastramento.
DbselectArea("VV2")
DbsetOrder(1)
Dbseek(xFilial("VV2")+M->VE4_PREFAB)
Do While xFilial("VV2")+M->VE4_PREFAB == VV2->(VV2_FILIAL+VV2_CODMAR) .and. !VV2->(Eof())
	// se configurar para utilizar segmento e já existe algum modelo cadastrado sem segmento, nao podera alterar o parametro
	If lSegMod .and. Empty(VV2->VV2_SEGMOD)
		lRet := .f.
		Exit
	Elseif !lSegMod .and. !Empty(VV2->VV2_SEGMOD)
		// se configurar para nao utilizar segmento e já existe algum modelo cadastrado com segmento, nao podera alterar o parametro
		lRet := .f.
		Exit
	Endif
	VV2->(Dbskip())
Enddo
If !lRet
	Help("  ",1,"VERSEGMOD")
Endif
sRestArea(aAlias)
Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡Æo    ³ MenuDef  ³ Autor ³  Emilton              ³ Data ³ 14/11/01 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡Æo ³ Monta MenuDef                                              ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function MenuDef()
Local aRotina := {  { oemtoansi(STR0001),"AxPesqui", 0 , 1,,.F.},;  // "Pesquisar"
                    { oemtoansi(STR0002),"AxCadVis", 0 , 2},;       // "Visualizar"
                    { oemtoansi(STR0003),"AxCadInc", 0 , 3},;       // "Incluir"
                    { oemtoansi(STR0004),"AxCadAlt", 0 , 4},;       // "Alterar"
                    { oemtoansi(STR0005),"AxCadDel", 0 , 5}}        // "Excluir"
Return aRotina

/*/{Protheus.doc} OA9800018_VldCUIT()
    ARGENTINA - Validação para o campo VE4_CGCFAB. Valida se o campo VE4_CGCFAB tem um CUID válido e preenche os campos 
@type function
@version 1.0
@author André Luis Guimarães Cruz
@since 26/01/2024
@return logical,
/*/
Function OA9800018_VldCUIT()
Local lRet    := .t.
Local cQAlSQL := "ALIASSQL"
Local cQuery  := ""
Local cCGC    := M->VE4_CGCFAB
Local cPict   := VE4->(X3PICTURE("VE4_CGCFAB"))
Local aSA1Rec := {}
Local aSA1Sel := {}
Local aSA2Rec := {}
Local aSA2Sel := {}
Local nPosSA1 := 1
Local nPosSA2 := 1
Local cSA1Sel := ""
Local cSA2Sel := ""
Private cCadastro := Alltrim(RetTitle("A1_CGC"))+": "+Transform(cCGC,cPict) // Titulo Tela
If (cPaisLoc=="ARG" .and. VE4->(FieldPos("VE4_AFIP")) > 0) .or. cPaisLoc=="MEX"
	M->VE4_CODFAB := ""
	M->VE4_LOJA   := ""
	M->VE4_NOMFAB := ""
	M->VE4_CODFOR := ""
	M->VE4_LOJFOR := ""
	If Empty(cCGC)
		Return .t.
	EndIf
	lRet := IF(cPaisLoc=="ARG" .and. STR(VAL(M->VE4_AFIP),2)$'80|86| 1', CUIT(M->VE4_CGCFAB), .T.)
	If lRet
		cQuery := "SELECT A1_COD , A1_LOJA , A1_NOME , R_E_C_N_O_ AS RECSA1 "
		cQuery += "  FROM "+RetSqlName("SA1")
		cQuery += " WHERE A1_FILIAL='"+xFilial("SA1")+"'"
		cQuery += "   AND A1_CGC='"+cCGC+"'"
		cQuery += "   AND D_E_L_E_T_=' '"
		dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery ), cQAlSQL , .F., .T. )
		While !( cQAlSQL )->( Eof() )
			aAdd(aSA1Sel,  ( cQAlSQL )->( A1_COD )+"-"+( cQAlSQL )->( A1_LOJA )+" "+( cQAlSQL )->( A1_NOME ) )
			aAdd(aSA1Rec,{ ( cQAlSQL )->( A1_COD )+"-"+( cQAlSQL )->( A1_LOJA )+" "+( cQAlSQL )->( A1_NOME ) , ( cQAlSQL )->( RECSA1 ) })
			( cQAlSQL )->( DbSkip() )
		EndDo
		( cQAlSQL )->( DbCloseArea() )
		DbSelectArea("SA1")
		If len(aSA1Rec) == 0
			MsgStop(OemToAnsi(STR0007)) //"Montadora NAO cadastrada no cadastro de Clientes !"
			Return .f.
		EndIf
		cQuery := "SELECT A2_COD , A2_LOJA , A2_NOME , R_E_C_N_O_ AS RECSA2 "
		cQuery += "  FROM "+RetSqlName("SA2")
		cQuery += " WHERE A2_FILIAL='"+xFilial("SA2")+"'"
		cQuery += "   AND A2_CGC='"+cCGC+"'"
		cQuery += "   AND D_E_L_E_T_=' '"
		dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery ), cQAlSQL , .F., .T. )
		While !( cQAlSQL )->( Eof() )
			aAdd(aSA2Sel,  ( cQAlSQL )->( A2_COD )+"-"+( cQAlSQL )->( A2_LOJA )+" "+( cQAlSQL )->( A2_NOME ) )
			aAdd(aSA2Rec,{ ( cQAlSQL )->( A2_COD )+"-"+( cQAlSQL )->( A2_LOJA )+" "+( cQAlSQL )->( A2_NOME ) , ( cQAlSQL )->( RECSA2 ) })
			( cQAlSQL )->( DbSkip() )
		EndDo
		( cQAlSQL )->( DbCloseArea() )
		DbSelectArea("SA2")
		If len(aSA2Rec) == 0
			MsgStop(OemToAnsi(STR0008)) //"Montadora NAO cadastrada no cadastro de Fornecedor!"
			Return .f.
		EndIf
		If len(aSA1Sel) > 1 .or. len(aSA2Sel) > 1 // Quando existir mais de um registro, necessário o usuario selecionar
			nPosSA1 := 0
			nPosSA2 := 0
			lRet := .f.
			DEFINE MSDIALOG oDlgSelCF TITLE cCadastro+" "+STR0011+"/"+STR0012 FROM  001,000 TO 15,50 OF oMainWnd // Cliente/Fornecedor
			@ 05,05 TO 36,195 LABEL STR0011 OF oDlgSelCF PIXEL // Cliente
			@ 18,10 MSCOMBOBOX oSA1 VAR cSA1Sel SIZE 180,08 ITEMS aSA1Sel OF oDlgSelCF PIXEL COLOR CLR_BLUE
			@ 45,05 TO 76,195 LABEL STR0012 OF oDlgSelCF PIXEL // Fornecedor
			@ 58,10 MSCOMBOBOX oSA2 VAR cSA2Sel SIZE 180,08 ITEMS aSA2Sel OF oDlgSelCF PIXEL COLOR CLR_BLUE
			DEFINE SBUTTON oBotOkk FROM 085,130 TYPE 1 ACTION ( lRet := .t. , oDlgSelCF:End() ) ENABLE OF oDlgSelCF
			DEFINE SBUTTON oBotCan FROM 085,165 TYPE 2 ACTION ( oDlgSelCF:End() ) ENABLE OF oDlgSelCF
			ACTIVATE MSDIALOG oDlgSelCF CENTER
			If lRet
				nPosSA1 := aScan(aSA1Rec, {|x| Alltrim(x[1]) == Alltrim(cSA1Sel) })
				nPosSA2 := aScan(aSA2Rec, {|x| Alltrim(x[1]) == Alltrim(cSA2Sel) })
			EndIf
		EndIf
		If nPosSA1 > 0 .and. nPosSA2 > 0 // Possui SA1 e SA2 relacionado
			SA1->(DbGoTo(aSA1Rec[nPosSA1,2]))
			SA2->(DbGoTo(aSA2Rec[nPosSA2,2]))
			M->VE4_CODFAB := SA1->A1_COD
			M->VE4_LOJA   := SA1->A1_LOJA
			M->VE4_NOMFAB := SA1->A1_NOME
			M->VE4_CODFOR := SA2->A2_COD
			M->VE4_LOJFOR := SA2->A2_LOJA
		EndIf
	EndIf
EndIf
Return lRet


/*/{Protheus.doc} OA9800018_VldRFC()
    MÉXICO - Validação para o campo VE4_CGCFAB. Valida se o campo VE4_CGCFAB tem um RFC e preenche os campos 
	relacionados ao cliente e fornecedor à motadora.
@type function
@version 1.0
@author André Luis Guimarães Cruz
@since 26/01/2024
@return logical,
/*/
function OA9800038_VldRFC()
return OA9800018_VldCUIT()


/*/{Protheus.doc} OA980002Z_VldRUC()
    PARAGUAY - Validação para o campo VE4_CGCFAB. Valida se o campo VE4_CGCFAB e preenche os campos 
@type function
@version 1.0
@author Jorge Eduardo Arévalo
@since 28/03/2024
@return logical,
/*/
Function OA980002Z_VldRUC()
Local lRet    := .t.
Local cQAlSQL := "ALIASSQL"
Local cQuery  := ""
Local cCGC    := M->VE4_CGCFAB
Local cPict   := VE4->(X3PICTURE("VE4_CGCFAB"))
Local aSA1Rec := {}
Local aSA1Sel := {}
Local aSA2Rec := {}
Local aSA2Sel := {}
Local nPosSA1 := 1
Local nPosSA2 := 1
Local cSA1Sel := ""
Local cSA2Sel := ""
Private cCadastro := Alltrim(RetTitle("A1_CGC"))+": "+Transform(cCGC,cPict) // Titulo Tela
If cPaisLoc=="PAR" 
	M->VE4_CODFAB := ""
	M->VE4_LOJA   := ""
	M->VE4_NOMFAB := ""
	M->VE4_CODFOR := ""
	M->VE4_LOJFOR := ""
	If Empty(cCGC)
		Return .t.
	EndIf
	cQuery := "SELECT A1_COD , A1_LOJA , A1_NOME , R_E_C_N_O_ AS RECSA1 "
	cQuery += "  FROM "+RetSqlName("SA1")
	cQuery += " WHERE A1_FILIAL='"+xFilial("SA1")+"'"
	cQuery += "   AND A1_CGC='"+cCGC+"'"
	cQuery += "   AND D_E_L_E_T_=' '"
	dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery ), cQAlSQL , .F., .T. )
	While !( cQAlSQL )->( Eof() )
	    aAdd(aSA1Sel,  ( cQAlSQL )->( A1_COD )+"-"+( cQAlSQL )->( A1_LOJA )+" "+( cQAlSQL )->( A1_NOME ) )
		aAdd(aSA1Rec,{ ( cQAlSQL )->( A1_COD )+"-"+( cQAlSQL )->( A1_LOJA )+" "+( cQAlSQL )->( A1_NOME ) , ( cQAlSQL )->( RECSA1 ) })
		( cQAlSQL )->( DbSkip() )
	EndDo
	( cQAlSQL )->( DbCloseArea() )
	DbSelectArea("SA1")
	If len(aSA1Rec) == 0
		MsgStop(OemToAnsi(STR0007)) //"Montadora NAO cadastrada no cadastro de Clientes !"
		Return .f.
	EndIf
	cQuery := "SELECT A2_COD , A2_LOJA , A2_NOME , R_E_C_N_O_ AS RECSA2 "
	cQuery += "  FROM "+RetSqlName("SA2")
	cQuery += " WHERE A2_FILIAL='"+xFilial("SA2")+"'"
	cQuery += "   AND A2_CGC='"+cCGC+"'"
	cQuery += "   AND D_E_L_E_T_=' '"
	dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery ), cQAlSQL , .F., .T. )
	While !( cQAlSQL )->( Eof() )
		aAdd(aSA2Sel,  ( cQAlSQL )->( A2_COD )+"-"+( cQAlSQL )->( A2_LOJA )+" "+( cQAlSQL )->( A2_NOME ) )
		aAdd(aSA2Rec,{ ( cQAlSQL )->( A2_COD )+"-"+( cQAlSQL )->( A2_LOJA )+" "+( cQAlSQL )->( A2_NOME ) , ( cQAlSQL )->( RECSA2 ) })
		( cQAlSQL )->( DbSkip() )
	EndDo
	( cQAlSQL )->( DbCloseArea() )
	DbSelectArea("SA2")
	If len(aSA2Rec) == 0
		MsgStop(OemToAnsi(STR0008)) //"Montadora NAO cadastrada no cadastro de Fornecedor!"
		Return .f.
	EndIf
	If len(aSA1Sel) > 1 .or. len(aSA2Sel) > 1 // Quando existir mais de um registro, necessário o usuario selecionar
		nPosSA1 := 0
		nPosSA2 := 0
		lRet := .f.
		DEFINE MSDIALOG oDlgSelCF TITLE cCadastro+" "+STR0011+"/"+STR0012 FROM  001,000 TO 15,50 OF oMainWnd // Cliente/Fornecedor
		@ 05,05 TO 36,195 LABEL STR0011 OF oDlgSelCF PIXEL // Cliente
		@ 18,10 MSCOMBOBOX oSA1 VAR cSA1Sel SIZE 180,08 ITEMS aSA1Sel OF oDlgSelCF PIXEL COLOR CLR_BLUE
		@ 45,05 TO 76,195 LABEL STR0012 OF oDlgSelCF PIXEL // Fornecedor
		@ 58,10 MSCOMBOBOX oSA2 VAR cSA2Sel SIZE 180,08 ITEMS aSA2Sel OF oDlgSelCF PIXEL COLOR CLR_BLUE
		DEFINE SBUTTON oBotOkk FROM 085,130 TYPE 1 ACTION ( lRet := .t. , oDlgSelCF:End() ) ENABLE OF oDlgSelCF
		DEFINE SBUTTON oBotCan FROM 085,165 TYPE 2 ACTION ( oDlgSelCF:End() ) ENABLE OF oDlgSelCF
		ACTIVATE MSDIALOG oDlgSelCF CENTER
		If lRet
			nPosSA1 := aScan(aSA1Rec, {|x| Alltrim(x[1]) == Alltrim(cSA1Sel) })
			nPosSA2 := aScan(aSA2Rec, {|x| Alltrim(x[1]) == Alltrim(cSA2Sel) })
		EndIf
	EndIf
	If nPosSA1 > 0 .and. nPosSA2 > 0 // Possui SA1 e SA2 relacionado
		SA1->(DbGoTo(aSA1Rec[nPosSA1,2]))
		SA2->(DbGoTo(aSA2Rec[nPosSA2,2]))
		M->VE4_CODFAB := SA1->A1_COD
		M->VE4_LOJA   := SA1->A1_LOJA
		M->VE4_NOMFAB := SA1->A1_NOME
		M->VE4_CODFOR := SA2->A2_COD
		M->VE4_LOJFOR := SA2->A2_LOJA	
	EndIf
EndIf
Return lRet
