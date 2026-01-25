#INCLUDE "acdv176.ch" 
#INCLUDE "PROTHEUS.CH"
#INCLUDE "APVT100.CH"


Static __nSem:=0
Static lExistEDIF := ExistBlock("V176EDIF")
Static __lSaOrdSep := Nil
Static __lLoteOPConf := NIL

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Descri‡…o ³ PLANO DE MELHORIA CONTINUA                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ITEM PMC  ³ Responsavel              ³ Data         |BOPS:             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³      01  ³                          ³              |                  ³±±
±±³      02  ³Erike Yuri da Silva       ³09/03/2006    |00000094383       ³±±
±±³      03  ³                          ³              |                  ³±±
±±³      04  ³                          ³              |                  ³±±
±±³      05  ³                          ³              |                  ³±±
±±³      06  ³                          ³              |                  ³±±
±±³      07  ³                          ³              |                  ³±±
±±³      08  ³                          ³              |                  ³±±
±±³      09  ³                          ³              |                  ³±±
±±³      10  ³Erike Yuri da Silva       ³09/03/2006    |00000094383       ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±± Parametros  lTACDA100, recebe .T. quando executado pela rotina de gera ³±±
±± 		ção da ordem se separação - ACDA100 do ERP Protheus 			  ³±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
/*/             


Function ACDV176(lTACDA100)
Local aTela
Local nOpc
IF !Type("lVT100B") == "L"
	Private lVT100B := .F.
EndIf
DEFAULT lTACDA100 := .F.

If lTACDA100
	ACDV176X(0,lTACDA100)
Else	
	aTela := VtSave()
	VTCLear()
	If lVT100B // GetMv("MV_RF4X20")
		@ 0,0 VTSAY STR0001 //"Desfaz Separacao"
		@ 1,0 VTSay STR0002 //"Selecione:"
		nOpc:=VTaChoice(2,0,3,VTMaxCol(),{STR0003,STR0004,STR0005,STR0006}) //"Ordem de Separacao"###"Pedido de Venda"###"Nota Fiscal"###"Ordem Producao"
	Else
		@ 0,0 VTSAY STR0001 //"Desfaz Separacao"
		@ 1,0 VTSay STR0002 //"Selecione:"
		nOpc:=VTaChoice(3,0,6,VTMaxCol(),{STR0003,STR0004,STR0005,STR0006}) //"Ordem de Separacao"###"Pedido de Venda"###"Nota Fiscal"###"Ordem Producao"
	EndIf
	VtRestore(,,,,aTela)
	If nOpc == 1     //-- por ordem de separacao
		ACDV176A()
	ElseIf nOpc == 2 //-- por pedido de venda
		ACDV176B()
	ElseIf nOpc == 3 //-- por Nota Fiscal
		ACDV176C()
	ElseIf nOpc == 4 //-- por Ordem de producao
		ACDV176D()
	EndIf
Endif
Return 1
                 
Function ACDV176A()
ACDV176X(1)
Return
Function ACDV176B()
ACDV176X(2)
Return
Function ACDV176C()
ACDV176X(3)
Return
Function ACDV176D()
ACDV176X(4)
Return


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao    ³ ACDV176X ³ Autor ³ ACD                   ³ Data ³ 23/02/05 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ Desfaz a separacao                                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ SIGAACD                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±³ Parametro³ lTACDA100, lógico, Se .T. executado via tela Protheus      ³±±
±±                                Se .F. (default), via VT100             ³±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function ACDV176X(nOpc,lTACDA100)
Local ckey09
Local cKey22
Local bkey09
Local bKey22
Local nType := 1	// executa pelo VT100

Private cOriExp
Private cNota
Private cUltTipoExp
Private cCodOpe     :=CBRetOpe()
Private cOrdSep     := Space(TamSX3("CB8_ORDSEP")[1])
Private aItens      := {}
Private cImp        := CBRLocImp("MV_IACD01")
Private cDivItemPv  := Alltrim(GetMV("MV_DIVERPV"))
Private cPictQtdExp := PesqPict("CB8","CB8_QTDORI")
DEFAULT lTACDA100   := .F.

If !lTACDA100
 	ckey09  := VTDescKey(09)
 	cKey22  := VTDescKey(22)
 	bkey09  := VTSetKey(09)
	bKey22  := VTSetKey(22)
Endif

__nSem := 0 //-- variavel static do fonte para controle de semaforo

If lTACDA100
	nType := 2	// Executa pelo ERP Protheus
EndIf

If Empty(cCodOpe) .And. !lTACDA100
	ACDAlert( nType, STR0007, STR0008, 4000, .F., 2 ) //"Ordem de separacao nao encontrada."###"Aviso"
	Return 
EndIf
CB5->(DbSetOrder(1))
If !CB5->(DbSeek(xFilial("CB5")+cImp)) //-- cadastro de locais de impressao
	ACDAlert( nType, STR0009, STR0008, , .F., 3 )
	Return
EndIf

If !lTACDA100
	VTClear()
	@ 0,0 VtSay STR0001 //"Desfaz Separacao"
Endif
If nOpc == 0 .Or. lTACDA100
	//-- ja estah posicionado
	cOrdSep := CB7->CB7_ORDSep
	If !VldCodSep( nType )
		Return MSCBASem() //-- valor necessario para finalizar o acv170 e liberar o semaforo
	EndIf
Else
	If !CBSolCB7(nOpc,{|| VldCodSep( nType )})
		Return MSCBASem() //-- valor necessario para finalizar o acv170 e liberar o semaforo
	EndIf
Endif
cUltTipoExp:= CBUltExp(CB7->CB7_TIPEXP)

If !ACDYesNo( nType, STR0010, STR0011 ) //"Deseja desfazer a separacao ?"###"Atencao"
   MSCBASem()
   Return 1
Endif

If !lTACDA100
    VTSetKey(09,{|| Informa()},NoAcento(STR0012)) //"Informacoes"
Endif

//-- Desfaz Ordem de Separacao
If !Desfaz( nType )
	MSCBASem() //-- valor necessario para finalizar o acv170 e liberar o semaforo
	Return 1
EndIf

If !lTACDA100
    vtsetkey(09,bkey09,cKey09)
    vtsetkey(22,bkey22,cKey22)
Endif
MSCBASem() //-- valor necessario para finalizar o acv170 e liberar o semaforo
Return FimProcesso( nType )

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao    ³ VldEnd   ³ Autor ³ ACD                   ³ Data ³ 23/02/05 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ Validacao do endereco no estorno da separacao.             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ SIGAACD                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function VldEnd(cArmazem,cEndereco,cEtiqEnd)
Local aRet
Default cEtiqEnd:=""

VtClearBuffer()
If Empty(cArmazem+cEndereco+cEtiqEnd)
	Return .f.
Endif
If Empty(cEtiqEnd) .and. UsaCB0("02")
	VtAlert(STR0013,STR0008,.t.,4000,3) //"Etiqueta invalida"###"Aviso"
	VtKeyboard(Chr(20))  // zera o get
	Return .f.
EndIf
If ! Empty(cEtiqEnd) .and. UsaCB0("02") //--> Etiqueta de Endereco com CB0
	aRet := CBRetEti(cEtiqEnd,"02")
	If Empty(aRet)
		VtAlert(STR0013,STR0008,.t.,4000,3) //"Etiqueta invalida"###"Aviso"
		VtKeyboard(Chr(20)) //-- zera o get
		Return .f.
	EndIf
	cArmazem  := aRet[2]
	cEndereco := aRet[1]
EndIf

If CB9->(CB9_LOCAL+CB9_LCALIZ)==cArmazem+cEndereco
	Return .T.
EndIf
VtAlert(STR0014,STR0008,.t.,4000,3) //"Endereco incorreto"###"Aviso"
VTClearGet("cArmazem")
VTClearGet("cEndereco")
VTGetSetFocus("cArmazem")
VtKeyboard(Chr(20)) //-- zera o get
Return .F.

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao    ³ VldCaixa ³ Autor ³ ACD                   ³ Data ³ 23/02/05 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ Rotina de validacao da leitura da etiq da caixa "granel"   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ SIGAACD                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function VldCaixa(cEtiqCaixa)
Local aRet
Default lEstEnd := .F.

If Empty(cEtiqCaixa)
	Return .f.
EndIf
aRet := CBRetEti(cEtiqCaixa,"01")
If Empty(aRet)
	VtAlert(STR0013,STR0008,.t.,4000,3) //"Etiqueta invalida"###"Aviso"
	VtKeyboard(Chr(20)) //-- zera o get
	Return .F.
EndIf
If ! Empty(aRet[2])
	VtAlert(STR0013,STR0008,.t.,4000,3) //"Etiqueta invalida"###"Aviso"
	VtKeyboard(Chr(20)) //-- zera o get
	Return .f.
EndIf

If !(CB9->CB9_PROD == aRet[1])
	VtAlert(STR0015,STR0008,.t.,4000,3) //"Etiqueta de produto diferente"###"Aviso"
	VtKeyboard(Chr(20)) //-- zera o get
	Return .F.
EndIf
Return .t.

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao    ³ VldEtiDesfaz³ Autor ³ ACD                  ³ Data ³ 23/02/05 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ Valida a etiqueta (codigo interno) para desfazer             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ SIGAACD                                                      ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function VldEtiDesfaz(cEtiqProd,lPallet)
Local nP          := 0
Local aEtiqueta   := {}
Local lIsPallet   := .t.
Local lV176EDIF   := .F.
Local lACD170VD	:= ExistBlock("ACD170VD")

Default lPallet   := .f.

If Empty(cEtiqProd)
	Return .f.
EndIf

aItensPallet := CBItPallet(cEtiqProd)
If Empty(aItensPallet)
	aItensPallet	:={cEtiqProd}
	lIsPallet 		:= .f.
EndIf
If lPallet .and. !lIsPallet
	VtAlert(STR0013,STR0008,.t.,4000,3) //"Etiqueta invalida"###"Aviso"
	VtKeyboard(Chr(20)) //-- zera o get
	Return .F.
Endif
// Ponto de entrada para permitir informar um ID da etiqueta diferente do que o coletor solicitar.
If lExistEDIF
	lV176EDIF:=ExecBlock("V176EDIF",.F.,.F.) 
	If ValType(lV176EDIF)<>"L"
	   lV176EDIF:= .F.
	EndIf			   
EndIf   
For nP:= 1 to Len(aItensPallet)
	cEtiqueta:= aItensPallet[nP]
	aEtiqueta:= CBRetEti(cEtiqueta,"01")
	If Empty(aEtiqueta)
		VtAlert(STR0013,STR0008,.t.,4000,3) //"Etiqueta invalida"###"Aviso"
		VtKeyboard(Chr(20)) //-- zera o get
		Return .F.
	EndIf
	If lIsPallet
		If !lV176EDIF .And. cPallet # CB0->CB0_PALLET
			VtAlert(STR0016+CB0->CB0_PALLET+STR0017,STR0008,.t.,4000,3) //"Pallet da etiqueta "###" diferente"###"Aviso"
			VtKeyboard(Chr(20)) //-- zera o get
			Return .f.
		EndIf
	Else
		If ! Empty(CB0->CB0_PALLET)
			VTALERT(STR0018,STR0008,.T.,4000,2) //"Etiqueta invalida, Produto pertence a um Pallet"###"Aviso"
			VtKeyboard(Chr(20)) //-- zera o get
			Return .f.
		Endif
		If !lV176EDIF .And. CB9->CB9_CODETI # CB0->CB0_CODETI
			VtAlert(STR0019+CB0->CB0_CODETI+STR0017,STR0008,.t.,4000,3) //"Etiqueta "###" diferente"###"Aviso"
			VtKeyboard(Chr(20)) //-- zera o get
			Return .f.
		EndIf
		nQtdLida:= aEtiqueta[2]
	EndIf
	If lACD170VD
		aEtiqueta:=ExecBlock("ACD170VD",,,aEtiqueta)
		If Empty(aEtiqueta)
			Return .f.
		EndIf
	EndIf
	CB9->(DbSetOrder(1))
	If !CB9->(DbSeek(xFilial("CB9")+cOrdSep+CB0->CB0_CODETI))
		VtAlert(STR0013,STR0008,.t.,4000,3) //"Etiqueta invalida"###"Aviso"
		VtKeyboard(Chr(20)) //-- zera o get  
		VTGetSetFocus("cEtiqProd")        
		Exit
	EndIf	
Next
VtKeyboard(Chr(20)) //-- zera o get
Return .t.

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao    ³ VldProdDf³ Autor ³ ACD                   ³ Data ³ 23/02/05 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ Expedicao                                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ SIGAACD                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function VldProdDf(cProduto,nQtde,nSldQtdDev)
Local aRet  := {}
Local cLote := Space(TamSX3("B8_LOTECTL")[1])
Local cSLote:= Space(TamSX3("B8_NUMLOTE")[1])

If Empty(cProduto)
	Return .f.
EndIf
If !CBLoad128(@cProduto)
	VtKeyboard(Chr(20)) //-- zera o get
	Return .F.
EndIf
If ! CbRetTipo(cProduto) $ "EAN8OU13-EAN14-EAN128"
	VtAlert(STR0013,STR0008,.t.,4000,3) //"Etiqueta invalida"###"Aviso"
	VtKeyboard(Chr(20)) //-- zera o get
	Return .F.
EndIf
aRet     := CBRetEtiEan(cProduto)
If Empty(aRet)
	VtAlert(STR0013,STR0008,.t.,4000,3) //"Etiqueta invalida"###"Aviso"
	VtKeyboard(Chr(20)) //-- zera o get
	Return .F.
EndIf
If AllTrim(CB9->CB9_PROD)!=AllTrim(aRet[01])  
	VtAlert(STR0020,STR0008,.t.,4000,3) //"Produto nao confere."###"Aviso"
	VtKeyboard(Chr(20)) //-- zera o get
	Return .F.
EndIf
cLote := aRet[3]
If ! CBRastro(CB9->CB9_PROD,@cLote,@cSLote)
	VTKeyBoard(chr(20))
	Return .f.
EndIf
If ! cLote+cSLote == CB9->(CB9_LOTECT+CB9_NUMLOT)
	VtAlert(STR0021,STR0008,.t.,4000,3) //"Lote invalido"###"Aviso"
	VtKeyboard(Chr(20)) //-- zera o get
	Return .F.
EndIf
nQtdLida := aRet[2]*nQtde
If nQtdLida > nSldQtdDev //-- CB9->CB9_QTESEP
	VtAlert(STR0022,STR0008,.t.,4000,3)  //"Quantidade maior que necessario"###"Aviso"
	VtKeyboard(Chr(20)) //-- zera o get
	Return .F.
EndIf
Return .t.

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao    ³ FimProcesso³ Autor ³ ACD                 ³ Data ³ 23/01/02 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ Finaliza o processo de estorno da separacao                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ SIGAACD                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±³ Parametro³ nType, number, indica onde será a exibição, sendo 1=VT100; ³±±
±±									2=via ERP Protheus e 3=API.           ³±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function FimProcesso( nType, lApp, cAppLog )
Local nSai := 1

DEFAULT nType	:= 1	// executa pelo VT100
DEFAULT lApp	:= .F.
DEFAULT cAppLog	:= ""

//Validação do ambiente para Ordem de Separacao de SA
If Type("__lSaOrdSep") == "U"
	If (__lSaOrdSep := FindFunction( 'AcdVldSA' ))
		__lSaOrdSep := AcdVldSA("CB7","CB7_NUMSA")
	EndIf
EndIf

Reclock("CB7",.f.)
If Separou()
	CB7->CB7_STATUS := "2"  //-- separacao finalizada
	CB7->CB7_STATPA := " "
	CB7->CB7_DTFIMS := dDataBase
	CB7->CB7_HRFIMS := LEFT(TIME(),5) 
Else
	CB7->CB7_STATUS := "1"  //-- separando
	CB7->CB7_STATPA := "1"  //-- Em pausa
	CB7->CB7_DTFIMS := Ctod("  /  /  ")
	CB7->CB7_HRFIMS := "     "
	nSai := 10
EndIf
CB7->(MsUnlock())

If	CB7->CB7_ORIGEM == "3"
	SC2->(DbSetOrder(1))
	If	SC2->(DbSeek(xFilial("SC2")+CB7->CB7_OP))
		RecLock("SC2",.F.)
		SC2->C2_ORDSEP:= " " //-- Limpa Ordem de Separacao p/ que possa ser possivel a separacao parcial das mesmas.
		SC2->(MsUnlock())
	Endif
Endif

If CB7->CB7_ORIGEM == "4" .And. CB7->CB7_STATUS <> "2" .And. __lSaOrdSep

	refazCB8SA(CB7->CB7_NUMSA, CB7->CB7_ORDSEP)

	If EstornSA(lApp, @cAppLog)
		nSai := 1
	EndIf

Endif

If ExistBlock("CB176FIM")
	ExecBlock("CB176FIM",.F.,.F.,cOrdSep)
EndIf

If !lApp
	CB9->(DbSetOrder(12))
	If	CB9->(DbSeek(xFilial("CB9")+CB7->CB7_ORDSEP))
		ACDAlert( nType, STR0023, STR0008 ) //"Ainda existem produtos separados"###"Aviso"
	Else
		ACDAlert( nType, STR0024, STR0008 ) //"Separacao desfeita completamente"###"Aviso"
	EndIf
EndIf
CBLogExp(cOrdSep)
Return nSai

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao    ³ Separou  ³ Autor ³ Anderson Rodrigues    ³ Data ³ 26/11/03      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ Verifica se todos os itens da Ordem de Separacao foram separados³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³SIGAACD                                                          ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function Separou()
Local lRet := .t.

CB8->(DBSetOrder(1))
CB8->(DbSeek(xFilial("CB8")+cOrdSep))
While CB8->(! Eof() .and. CB8_FILIAL+CB8_ORDSEP == xFilial("CB8")+cOrdSep)
	If !Empty(CB8->CB8_OCOSEP) .AND. Alltrim(CB8->CB8_OCOSEP) == cDivItemPv
		CB8->(DbSkip())
		Loop
	Endif
	If CB8->CB8_SALDOS > 0
		lRet:= .f.
		Exit
	EndIf
	CB8->(DbSkip())
Enddo
Return(lRet)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o	 ³ Informa    ³ Autor ³ ACD                 ³ Data ³ 24/02/05 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Mostra produtos que ja foram lidos                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ SIGAACD                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function Informa()
Local nPos
Local nTam
Local nRecCB9 := CB9->(RecNo())
Local cChave,cChaveM
Local aTemp   := {}
Local aCB9	  := CB9->(GetArea())
Local aCab,aSize,aSave := VTSAVE()

VTClear()

If Empty(cOrdSep)
	Return .f.
Endif

If "01" $ CB7->CB7_TIPEXP
	aCab  := {STR0025,STR0026,STR0027,STR0028,STR0029} //"Volume"###"Pedido"###"Nota"###"Serie"###"Tipo"
	aSize := { 10,6,6,5,4}
	If CB7->CB7_ORIGEM == "1"
		CB6->(DbSetOrder(2))
		cChave:=xFilial("CB6")+CB7->CB7_PEDIDO
		cChaveM:= "CB6_FILIAL+CB6_PEDIDO"
	Else
		CB6->(DbSetOrder(5))
		cChave:=xFilial("CB6")+CB7->(CB7_NOTA+CB7_SERIE)
		cChaveM:= "CB6_FILIAL+CB6_NOTA+CB6_SERIE"
	EndIf
	CB9->(DbSetOrder(2))
	CB6->(DbSeek(cChave))
	While CB6->(! Eof() .and. cChave == &cChaveM)
		If CB6->CB6_STATUS == "5" .and. CB9->(DbSeek(xFilial("CB9")+CB7->CB7_ORDSEP+CB6->CB6_VOLUME))
			CB6->(aadd(aTemp,{CB6_VOLUME,CB6_PEDIDO,CB6_NOTA,CB6_SERIE,CB6_TIPVOL}))
		EndIf
		CB6->(DbSkip())
	End
	nPos := 0
Else
	If UsaCB0("01")
		aCab  := {STR0030,STR0031,STR0032,STR0033,STR0034,STR0035,STR0036,STR0025,STR0037} //######################## //"Produto"###"Quantidade"###"Armazem"###"Endereco"###"Lote"###"Sub-Lote"###"Sub-volume"###"Volume"###"Id Etiqueta"
	Else
		aCab  := {STR0030,STR0031,STR0032,STR0033,STR0034,STR0035,STR0036,STR0025}  //##################### //"Produto"###"Quantidade"###"Armazem"###"Endereco"###"Lote"###"Sub-Lote"###"Sub-volume"###"Volume"
	EndIf
	nTam := len(aCab[2])
	If nTam < len(Transform(0,cPictQtdExp))
		nTam := len(Transform(0,cPictQtdExp))
	EndIf
	If UsaCB0("01")
		aSize := {15,nTam,7,10,10,8,10,10,12}
	Else
		aSize := {15,nTam,7,10,10,8,10,10}
	Endif
	nTam := len(aCab[2])
	If nTam < len(Transform(0,cPictQtdExp))
		nTam := len(Transform(0,cPictQtdExp))
	EndIf
	If UsaCB0("01")
		aSize := {15,nTam,7,10,10,8,10,10,12}
	Else
		aSize := {15,nTam,7,10,10,8,10,10}
	Endif
	CB9->(DbSetOrder(6))
	CB9->(DbSeek(xFilial("CB9")+cOrdSep))
	While CB9->(! Eof() .and. CB9_FILIAL+CB9_ORDSEP == xFilial("CB9")+cOrdSep)
		If UsaCB0("01")
			aadd(aTemp,{CB9->CB9_PROD,Transform(CB9->CB9_QTESEP,cPictQtdExp),CB9->CB9_LOCAL,CB9->CB9_LCALIZ,CB9->CB9_LOTECT,CB9->CB9_NUMLOT,CB9->CB9_SUBVOL,CB9->CB9_VOLUME,CB9->CB9_CODETI})
		Else
			aadd(aTemp,{CB9->CB9_PROD,Transform(CB9->CB9_QTESEP,cPictQtdExp),CB9->CB9_LOCAL,CB9->CB9_LCALIZ,CB9->CB9_LOTECT,CB9->CB9_NUMLOT,CB9->CB9_SUBVOL,CB9->CB9_VOLUME})
		Endif
		If "01" $ CB7->CB7_TIPEXP
			If UsaCB0("01")
				aadd(aTemp,{CB9->CB9_VOLUME,CB9->CB9_PROD,Transform(CB9->CB9_QTESEP,cPictQtdExp),Transform(CB9->CB9_QTEEMB,cPictQtdExp),CB9->CB9_LOCAL,CB9->CB9_LCALIZ,CB9->CB9_LOTECT,CB9->CB9_NUMLOT,CB9->CB9_SUBVOL,CB9->CB9_CODETI})
			Else
				aadd(aTemp,{CB9->CB9_VOLUME,CB9->CB9_PROD,Transform(CB9->CB9_QTESEP,cPictQtdExp),Transform(CB9->CB9_QTEEMB,cPictQtdExp),CB9->CB9_LOCAL,CB9->CB9_LCALIZ,CB9->CB9_LOTECT,CB9->CB9_NUMLOT,CB9->CB9_SUBVOL})
			Endif
		Endif
		CB9->(DbSkip())
	Enddo
	If "01" $ CB7->CB7_TIPEXP
		nPos := 1
		@ 0,0 VtSay Left(STR0038+cVolume,20) //"Volume "
	Else
		nPos := 0
	EndIf
EndIf
VTaBrowse(nPos,0,7,19,aCab,aTemp,aSize)
VtRestore(,,,,aSave)
RestArea(aCB9)
CB9->(DbGoto(nRecCB9))
Return

//-------------------------------------------------------------------
/*/{Protheus.doc} EstProc176
 Função que realiza o estorno da separação(É necessário estar posicionado no registro da CB9)

@return logical

@author	 	Leonardo Kichitaro
@since		05/02/2025
@version	12.1.2410
/*/
//-------------------------------------------------------------------
Function EstProc176(nQdte)

	GrvEstCB9(nQdte, nQdte)

Return .T.

//-------------------------------------------------------------------
/*/{Protheus.doc} FimProc176
 Aciona a função de Finaliza o processo do estorno da separacao

@return logical

@author	 	Leonardo Kichitaro
@since		05/02/2025
@version	12.1.2410
/*/
//-------------------------------------------------------------------

Function FimProc176(lApp, cSepOrd)

	Local nRet		:= 0
	Local cAppLog	:= ""

	Private cOrdSep		:= cSepOrd
	Private cDivItemPv	:= Alltrim(GetMV("MV_DIVERPV"))

	nRet := FimProcess(2, lApp, @cAppLog)

Return({nRet,cAppLog})

//-------------------------------------------------------------------
/*/{Protheus.doc} EstornSA
 Função que realiza o estorno das SAs separadas

@return logical

@author	 	Leonardo Kichitaro
@since		03/02/2025
@version	12.1.2410
/*/
//-------------------------------------------------------------------
Static Function EstornSA(lApp, cAppLog)

	Local aMata     := {}
	Local aBxSCP	:= {}
	Local dValid    := ctod('')
	Local nModuloOld:= nModulo
	Local aCB8      := CB8->(GetArea())
	Local aSCP      := SCP->(GetArea())
	Local nQtdEst	:= 0
	Local nQujeAnt	:= 0
	Local nRecSCP	:= 0
	Local lRet		:= .T.

	Private nModulo  := 4
	Private lMsErroAuto := .F.

	Default lApp	:= .F.
	Default cAppLog	:= ""

	SB1->(DbSetOrder(1))
	SCP->(DbSetOrder(5))
	CB8->(DbSetOrder(4))
	CB8->(DbSeek(xFilial("CB8")+CB7->CB7_ORDSEP))
	While CB8->(! Eof() .And. xFilial("CB8")+CB7->CB7_ORDSEP == CB8_FILIAL+CB8_ORDSEP)
		If CB8->CB8_QTDORI == CB8->CB8_SALDOS
			SB1->(DbSeek(xFilial("SB1")+CB8->CB8_PROD))

			If SCP->(DbSeek(xFilial("SCP")+CB8->CB8_NUMSA+CB8->CB8_ITEM+CB8->CB8_ORDSEP))
				nQujeAnt := SCP->CP_QUJE
				nQtdEst	 := (SCP->CP_QUANT - SCP->CP_QUJE)
				If nQtdEst <> SCP->CP_QUANT
					nRecSCP	:= SCP->(Recno())
					aBxSCP	:= {}
					aadd(aBxSCP,{"CP_NUM"  ,SCP->CP_NUM			,nil})
					aadd(aBxSCP,{"CP_ITEM" ,SCP->CP_ITEM		,nil})
					aadd(aBxSCP,{"CP_QUANT",nQtdEst				,nil})

					aMata  := {}
					aadd(aMata,{"D3_COD"    ,CB8->CB8_PROD		,nil})
					aadd(aMata,{"D3_UM"     ,SB1->B1_UM			,nil})
					aadd(aMata,{"D3_QUANT"  ,nQtdEst		  	,nil})
					aadd(aMata,{"D3_LOCAL"  ,CB8->CB8_LOCAL		,nil})
					aadd(aMata,{"D3_LOCALIZ",CB8->CB8_LCALIZ	,nil})
					aadd(aMata,{"D3_LOTECTL",CB8->CB8_LOTECT	,nil})
					aadd(aMata,{"D3_NUMLOTE",CB8->CB8_NUMLOT	,nil})
					aadd(aMata,{"D3_EMISSAO",dDataBase			,nil})
					If	Rastro(CB8->CB8_PROD)
						dValid := dDataBase+SB1->B1_PRVALID
						aadd(aMata,{"D3_DTVALID",dValid            	,nil})
					EndIf
					aadd(aMata,{"D3_NUMSERI"    , CB8->CB8_NUMSER	,nil})

					//Em caso de estorno limpar os campos informados no APP
					RecLock( "CB8",.F. )
					CB8->CB8_LCALIZ := CriaVar("CB8_LCALIZ")
					CB8->CB8_LOTECT := CriaVar("CB8_LOTECT")
					CB8->CB8_NUMLOT := CriaVar("CB8_NUMLOT")
					CB8->CB8_NUMSER := CriaVar("CB8_NUMSER")
					CB8->( MsUnlock() )	

					lMSErroAuto := .F.
					lMSHelpAuto := .F.
					MSExecAuto({|v,x,y,z,w| mata185(v,x,y,z,w)},aBxSCP,aMata,2,Nil,Nil)   // 2 = ESTORNO (ROT.AUT)

					SCP->(dbGoTo(nRecSCP))
					If SCP->CP_QUJE == nQujeAnt .And. !lMSErroAuto
						lMSErroAuto := .T.
					EndIf

					If	lMSErroAuto
						cAppLog := STR0076 + AllTrim(CB7->CB7_NUMSA)	//"Falha no estorno da baixa da SA "
						lRet := .F.
						Exit
					EndIf
				EndIf
			EndIf
		EndIf
		CB8->(DbSkip())
	EndDo
	nModulo := nModuloOld

	SCP->(RestArea(aSCP))
	CB8->(RestArea(aCB8))

Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao    ³ Desfaz   ³ Autor ³ ACD                   ³ Data ³ 23/02/05 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ Desfaz Ordem de Separacao                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ SIGAACD                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±³ Parametro³ nType, number, indica onde será a exibição, sendo 1=VT100; ³±±
±±									2=via ERP Protheus e 3=API.	          ³±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function Desfaz( nType )

Local lRetTelDev := .T.

Private cPallet     := Space(10)
Private cArmazem    := Space(Tamsx3("B1_LOCPAD")[1])
Private cEndereco   := Space(TamSX3("BF_LOCALIZ")[1])
Private aItensCB9   := {}
Private aPalletsCB9 := {}
Private aItensPallet:= {}

DEFAULT nType := 1	// executa pelo VT100

If nType == 2	// Executa pelo ERP Protheus
	lRetTelDev := DevItTela()
Else
	CB9->(DbSetOrder(12))
	CB9->(DbSeek(xFilial("CB9")+cOrdSep))
	While ! CB9->(Eof()) .and. CB9->(CB9_FILIAL+CB9_ORDSEP) == xFilial("CB9")+cOrdSep
		If Empty(CB9->CB9_QTESEP)
			CB9->(DbSkip())
			Loop
		Endif
		cPallet  := RetPalletCB9(CB9->CB9_CODETI)
		If ! Empty(cPallet)
			If Ascan(aPalletsCB9,{|x| x == cPallet}) > 0
				CB9->(DbSkip())
				Loop
			Else
				aadd(aPalletsCB9,cPallet)
			EndIf
			
			If ! DevPallets()
				Exit
			Endif
		Else
			If !Endereco()
				Exit
			EndIf
			
			If ! DevItens()
				Exit
			Endif
		Endif
		//CB9->(DbSkip())
	EndDo
Endif
Return lRetTelDev

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao    ³RetPalletCB9³ Autor ³ ACD                 ³ Data ³ 03/01/02 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³Verifica se existe o Pallet para a etiqueta informada       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ SIGAACD                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function RetPalletCB9(cEtiqueta)
Local cPallet:= ""
Local aArea  := CB0->(GetArea())

If ! UsaCB0("01") .or. Empty(cEtiqueta)
	Return(cPallet)
EndIf

CB0->(DbSetOrder(1))
If CB0->(DbSeek(xFilial("CB0")+cEtiqueta))
	cPallet:= CB0->CB0_PALLET
EndIf
RestArea(aArea)
Return(cPallet)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao    ³ DevItens ³ Autor ³ ACD                 ³ Data ³ 23/02/05 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³Faz a devolucao dos Itens separados                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ SIGAACD                                                  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function DevItens(lEnd)
Local cEtiqEnd      := Space(20)
Local cUnidade
Local cEtiqCaixa
Local cEtiqAvulsa
Local cEtiqProd
Local nSldQtdDev    := 0
Local nQtdDev       := 0
Local nQtde         := 0
Local lMV_CFENDIG   := SuperGetMv("MV_CFENDIG") =="1"
Local aTamQtdOri    := TamSx3("CB8_QTDORI")
Local aEtiqueta     := {}
Local lVolta
Private lEstEnd     := .t.
Private lForcaQtd   := GetMV("MV_CBFCQTD",,"2") =="1"
Private nQtdLida    := 0
Private cVolume     := Space(10)
Private cLoteNew    := Space(TamSX3("B8_LOTECTL")[1])
Private cSLoteNew   := Space(TamSX3("B8_NUMLOTE")[1])
Default lEnd        := .f.

SB1->(DbSetOrder(1))
If ! SB1->(DbSeek(xFilial("SB1")+CB9->CB9_PROD))
	VtAlert(STR0039+CB9->CB9_PROD+STR0040) //"Inconsistencia de Base, produto "###" nao encontrado"
	Return .f.
EndIf

nSldQtdDev := AglutCB9(cOrdSep,cArmazem,cEndereco,CB9->CB9_PROD,CB9->CB9_LOTECT,CB9->CB9_NUMLOT) 

VTClear()
If GetNewPar("MV_OSEP2UN","0") $ "0 "
	nQtdDev := nSldQtdDev
	cUnidade:= If(nQtdDev==1,STR0041,STR0042) //"item "###"itens "
Else
	SB1->(DbSetOrder(1))
	SB1->(DbSeek(xFilial("SB1")+CB9->CB9_PROD))
	nQtdCX:= If(Empty(SB1->B1_QE),1,SB1->B1_QE)
	If ExistBlock("CBRQEESP")
		nQtdCX:=ExecBlock("CBRQEESP",,,SB1->B1_COD)
	EndIf
	If nSldQtdDev/nQtdCX < 1
		nQtdDev := nSldQtdDev
		cUnidade:= If(nQtdDev==1,STR0041,STR0042) //"item "###"itens "
	Else
		nQtdDev := nSldQtdDev/nQtdCX
		cUnidade:= If(nQtdDev == 1,STR0025,STR0043) //"Volume"###"Volumes"
	EndIf
EndIf
If lExistEDIF
	@ 0,0 VTSay "Desfazendo Ordem de Separacao " +cOrdSep
Else
	@ 0,0 VTSay Padr(STR0044+Alltrim(Str(nQtdDev,aTamQtdOri[1],aTamQtdOri[2]))+" "+cUnidade,20) //"Devolva "
	@ 1,0 VTSay CB9->CB9_PROD
	@ 2,0 VTSay Left(SB1->B1_DESC,20)
	If Rastro(CB9->CB9_PROD,"L")
		@ 3,0 VTSay STR0045+CB9->CB9_LOTECT //"Lote: "
	ElseIf Rastro(CB9->CB9_PROD,"S")
		@ 3,0 VTSay CB9->(CB9_LOTECT+"-"+CB9_NUMLOT)
	EndIf
	If !Empty(CB9->CB9_NUMSER)
		@ 4,0 VTSay CB9->CB9_NUMSER
	EndIf
EndIf
If ! CBProdUnit(CB9->CB9_PROD)  // granel
	cEtiqCaixa := Space(TamSx3("CB0_CODET2")[1])
	@ 6,0 VTSay STR0046 //"Leia a caixa"
	@ 7,0 VtGet cEtiqCaixa pict "@!" Valid VldCaixa(cEtiqCaixa)
	VtRead
	If VTLastkey() == 27
		Return .f.
	EndIf
	cEtiqAvulsa:= Space(TamSx3("CB0_CODET2")[1])
	@ 5,0 VTClear to 7,19
	@ 5,0 VTSay STR0047 //"Leia a etiq. avulsa"
	@ 6,0 VTSay STR0048+CB9->CB9_CODETI //"com ID "
	@ 7,0 VtGet cEtiqAvulsa pict "@!" Valid VldEtiqAvulsa(cEtiqAvulsa)
	VtRead
	If VTLastkey() == 27
		Return .f.
	EndIf
Else
	If UsaCB0("01")
		cEtiqProd  := Space(TamSx3("CB0_CODET2")[1])
		@ 5,0 VTSay STR0049 //"Leia a etiqueta"
		If !lExistEDIF
			@ 6,0 VTSay STR0048+CB9->CB9_CODETI //"com ID "
		EndIf
		@ 7,0 VTGet cEtiqProd pict "@!" Valid VldEtiDesfaz(cEtiqProd)
		VTRead
		If VTLastkey() == 27 
			If VTYesNo(STR0050,STR0011,.T.) //"Confirma a saida?"###"Atencao"
				Return .f.
			EndIf
			lVolta := .T.
		EndIf
		nQtde := nQtdLida
	Else
		nQtde := 1
		cProduto   := IIf( FindFunction( 'AcdGTamETQ' ), AcdGTamETQ(), Space(48) )
		@ 5,0 VTSay STR0051 VtGet nQtde pict cPictQtdExp valid nQtde > 0 when (lForcaQtd .or. VtLastkey()==5) //"Qtde "
		@ 6,0 VTSay STR0052 //"Leia o produto"
		@ 7,0 VTGet cProduto pict "@!" VALID VTLastkey() == 5 .or. VldProdDf(cProduto,nQtde,nSldQtdDev)
		VTRead
		If VTLastkey() == 27
			If  VTYesNo(STR0050,STR0011,.T.) //"Confirma a saida?"###"Atencao"
				Return
			EndIf
			lVolta := .T.
		EndIf
	EndIf
EndIf
If !lVolta
	If ! CBProdUnit(CB9->CB9_PROD)  .or. UsaCB0("01")
		cCodEti  := CB9->CB9_CODETI
		aEtiqueta:= CBRetEti(cCodEti,"01")
		nQtdLida:=  aEtiqueta[2]
		cLoteNew := aEtiqueta[16]
		cSLoteNew:= aEtiqueta[17]
	Else
		cCodEti := NIL
		If nQtdLida <= 0
			nQtdLida:=  1
		Else
			nQtde := nQtdLida
		Endif
	Endif
	GrvEstCB9(nQtde,nSldQtdDev)
	nQtdDev:= (nQtdDev - nQtdLida)
EndIf
If Empty(nQtdDev)
	If lMV_CFENDIG
		cArmazem   := Space(Tamsx3("B1_LOCPAD")[1])
		cEndereco  := Space(TamSX3("BF_LOCALIZ")[1])
	EndIf
	cEtiqEnd   := Space(TamSx3("CB0_CODET2")[1])
	cEtiqProd  := Space(TamSx3("CB0_CODET2")[1])
	cEtiqCaixa := Space(TamSx3("CB0_CODET2")[1])
	cEtiqAvulsa:= Space(TamSx3("CB0_CODET2")[1])
	cProduto   := IIf( FindFunction( 'AcdGTamETQ' ), AcdGTamETQ(), Space(48) )
	nQtde      := 0
EndIf
CB9->(DbSetOrder(12))
CB9->(DbSeek(xFilial("CB9")+cOrdSep))
Return .T.

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao    ³ DevPallets³ Autor ³ ACD                 ³ Data ³ 03/01/02 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³Faz a devolucao dos Pallets separados                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ SIGAACD                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function DevPallets()

Local nP
Local cEtiqEnd      := Space(20)
Local cEtiqPallet   := Space(20)
Local aEtiqueta     := {}
Local lMV_CFENDIG   := GetMV("MV_CFENDIG") =="1"
Local lVolta        := .f.
Local lMV_CONFEND   := SuperGetMv("MV_CONFEND") # "1"
Local nTamEnd       := TamSX3("BF_LOCALIZ")[1]
Local nTamLoc       := TamSX3("B2_LOCAL")[1]
Private nQtdLida    := 0
Private cVolume     := Space(10)

//For nX:=1 to Len(aPalletsCB9)
While .t.
	If lVT100B // GetMv("MV_RF4X20")
		If !CB9->(CB9_LOCAL+CB9_LCALIZ) == cArmazem+cEndereco
			VTClear()
			cArmazem   := Space(nTamLoc)
			cEndereco  := Space(nTamEnd)
			cEtiqEnd   := Space(20)
			cEtiqPallet:= Space(20)
					@ 0,0 VTSay STR0053 //"Va para o endereco"
					@ 1,0 VTSay CB9->(CB9_LOCAL+"-"+CB9_LCALIZ)
			
			If lMV_CONFEND
						@ 3,0 VTPause STR0054 //"Enter para continuar"
			Else
						@ 2,0 VTSay STR0055 //"Leia o endereco"
				If UsaCB0("02")
							@ 3,0 VTGet cEtiqEnd pict "@!" valid VldEnd(@cArmazem,@cEndereco,cEtiqEnd)
				Else
							@ 3,0 VTGet cArmazem pict "@!" valid ! Empty(cArmazem) when iif(lVolta,(VTKeyBoard(chr(13)),lVolta := .F.,.T.),.T.)
							@ 3,3 VTSay "-" VTGet cEndereco pict "@!" valid VtLastKey()==5 .or. VldEnd(@cArmazem,@cEndereco,NIL)
				EndIf
				VTRead
				If VTLastkey() == 27
					Return .f.
				EndIf
			EndIf
			cArmazem := CB9->CB9_LOCAL
			cEndereco:= CB9->CB9_LCALIZ
		EndIf
		VTClear()
				@ 0,0 VTSay STR0056 //"Devolva  o Pallet"
		If UsaCB0("01")
			cEtiqProd  := Space(TamSx3("CB0_CODET2")[1])
					@ 1,0 VTSay STR0057 //"Leia o Pallet "
					@ 2,0 VTSay STR0048+cPallet //"com ID "
					@ 3,0 VTGet cEtiqPallet pict "@!" Valid VldEtiDesfaz(cEtiqPallet,.t.) when iif(vtRow() == 3 .and. vtLastKey() == 5,(VTKeyBoard(chr(27)),lVolta := .T.),.T.)
			VTRead
					If lVolta
						cArmazem   := Space(Tamsx3("B1_LOCPAD")[1])
						cEndereco  := Space(TamSX3("BF_LOCALIZ")[1])
						Loop
					EndIf
			If VTLastkey() == 27
				If ! VTYesNo(STR0050,STR0011,.T.) //"Confirma a saida?"###"Atencao"
					Loop
				EndIf
				Exit
			EndIf
			For nP:= 1 to Len(aItensPallet)
				aEtiqueta:= CBRetEti(aItensPallet[nP],"01")
				If ! CBProdUnit(aEtiqueta[1]) .or. UsaCB0("01")
					cCodEti := CB0->CB0_CODETI
					cLoteNew:= CB9->CB9_LOTECT
					cSLoteNew:=CB9->CB9_NUMLOT
				Else
					cCodEti := NIL
				Endif
				
				CB9->(DbSetOrder(1))
				If !CB9->(DbSeek(xFilial("CB9")+cOrdSep+CB0->CB0_CODETI))
					VTAlert(STR0019+CB0->CB0_CODETI+STR0058,STR0008,.T.,4000) //"Etiqueta "###" nao Separada "###"Aviso"
					lVolta:= .t.
					Exit
				Endif
				
				nQtdLida:= aEtiqueta[2]
				GrvEstCB9(nQtdLida,CB9->CB9_QTESEP)
			Next
			If !lVolta
				Exit
			Endif
			If lMV_CFENDIG
				cArmazem   := Space(Tamsx3("B1_LOCPAD")[1])
				cEndereco  := Space(TamSX3("BF_LOCALIZ")[1])
			EndIf
		Endif
	Else
		If !CB9->(CB9_LOCAL+CB9_LCALIZ) == cArmazem+cEndereco
			VTClear()
			cArmazem   := Space(nTamLoc)
			cEndereco  := Space(nTamEnd)
			cEtiqEnd   := Space(20)
			cEtiqPallet:= Space(20)
			@ 1,0 VTSay STR0053 //"Va para o endereco"
			@ 2,0 VTSay CB9->(CB9_LOCAL+"-"+CB9_LCALIZ)
	
		If lMV_CONFEND
				@ 6,0 VTPause STR0054 //"Enter para continuar"
			Else
				@ 4,0 VTSay STR0055 //"Leia o endereco"
				If UsaCB0("02")
					@ 5,0 VTGet cEtiqEnd pict "@!" valid VldEnd(@cArmazem,@cEndereco,cEtiqEnd)
				Else
					@ 5,0 VTGet cArmazem pict "@!" valid ! Empty(cArmazem)
					@ 5,3 VTSay "-" VTGet cEndereco pict "@!" valid VtLastKey()==5 .or. VldEnd(@cArmazem,@cEndereco,NIL)
				EndIf
				VTRead
				If VTLastkey() == 27
					Return .f.
				EndIf
			EndIf
			cArmazem := CB9->CB9_LOCAL
			cEndereco:= CB9->CB9_LCALIZ
		EndIf
		VTClear()
		@ 1,0 VTSay STR0056 //"Devolva  o Pallet"
		If UsaCB0("01")
			cEtiqProd  := Space(TamSx3("CB0_CODET2")[1])
			@ 4,0 VTSay STR0057 //"Leia o Pallet "
			@ 5,0 VTSay STR0048+cPallet //"com ID "
			@ 6,0 VTGet cEtiqPallet pict "@!" Valid VldEtiDesfaz(cEtiqPallet,.t.)
			VTRead
			If VTLastkey() == 27
				If ! VTYesNo(STR0050,STR0011,.T.) //"Confirma a saida?"###"Atencao"
					Loop
				EndIf
				Exit
			EndIf
			For nP:= 1 to Len(aItensPallet)
				aEtiqueta:= CBRetEti(aItensPallet[nP],"01")
				If ! CBProdUnit(aEtiqueta[1]) .or. UsaCB0("01")
					cCodEti := CB0->CB0_CODETI
					cLoteNew:= CB9->CB9_LOTECT
					cSLoteNew:=CB9->CB9_NUMLOT
				Else
					cCodEti := NIL
				Endif
		
				CB9->(DbSetOrder(1))
				If !CB9->(DbSeek(xFilial("CB9")+cOrdSep+CB0->CB0_CODETI))
					VTAlert(STR0019+CB0->CB0_CODETI+STR0058,STR0008,.T.,4000) //"Etiqueta "###" nao Separada "###"Aviso"
					lVolta:= .t.
					Exit
				Endif
		
				nQtdLida:= aEtiqueta[2]
				GrvEstCB9(nQtdLida,CB9->CB9_QTESEP)
			Next
			If !lVolta
				Exit
			Endif
			If lMV_CFENDIG
				cArmazem   := Space(Tamsx3("B1_LOCPAD")[1])
				cEndereco  := Space(TamSX3("BF_LOCALIZ")[1])
			EndIf
		Endif
	EndIf
EndDo
Return .t.

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±
±±³Fun‡ao    ³VldEtiqAvulsa³ Autor ³ ACD                   ³ Data ³ 27/01/05 ³±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±
±±³Descri‡ao ³ Rotina de registro da etiqueta avulsa  qdo "granel"           ³±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±
±±³ Uso      ³ SIGAACD                                                       ³±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function VldEtiqAvulsa(cEtiqAvulsa)
Local aEtiqueta:= {}
Default lEstEnd:= .F.

If Empty(cEtiqAvulsa)
	Return .f.
EndIf

aEtiqueta:= CBRetEti(cEtiqAvulsa,"01")

If Empty(aEtiqueta)
	VtAlert(STR0013,STR0008,.t.,4000,3) //"Etiqueta invalida"###"Aviso"
	VtKeyboard(Chr(20)) //-- zera o get
	Return .f.
EndIf
nQtdLida := aEtiqueta[2]
Return .t.

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao    ³GrvEstCB9 ³ Autor ³ ACD                   ³ Data ³ 28/01/05 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ Estorna CB9                                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ SIGAACD                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function GrvEstCB9(nQtde,nSldQtdDev)
Local nDevQtd := 0
Local cProd	  := CB9->CB9_PROD
Local cArm 	  := CB9->CB9_LOCAL
Local cEnd 	  := CB9->CB9_LCALIZ
Local cLote   := CB9->CB9_LOTECT
Local cSLote  := CB9->CB9_NUMLOT
Local cNumSer := CB9->CB9_NUMSER
Local cLoteOri:= Nil

//Permite validar a quantidade no estorno da separacao
If ExistBlock("ACDGCB9E")
	ExecBlock("ACDGCB9E",.F.,.F.,{nQtde})
EndIf

//Carrega variável static '__lLoteOPConf'
FnVlOpOs()

If __lLoteOPConf
	cLoteOri := CB9->CB9_LOTORI
EndIf

If nQtde <= CB9->CB9_QTESEP
	//Devolve item(s) ja separados para o CB8
	DevItemCB8(nQtde,cLoteOri)
	
	//Atualiza item(s) separados
	RecLock("CB9",.F.)
	CB9->CB9_QTESEP -= nQtde
	If Empty(CB9->CB9_QTESEP)
		CB9->(DbDelete())
	EndIf
	CB9->(MsUnlock())
Else
	CB9->(DbSetOrder(9))
	CB9->(DbSeek(xFilial("CB9")+cOrdSep+cProd+cArm+cEnd+cLote+cSLote+cNumSer))
	While !CB9->(Eof()) .and. ;
		CB9->(CB9_FILIAL+CB9_ORDSEP+CB9_PROD+CB9_LOCAL+CB9_LCALIZ+CB9_LOTECT+CB9_NUMLOT+CB9_NUMSER) ==;
		xFilial("CB9")+cOrdSep+cProd+cArm+cEnd+cLote+cSLote+cNumSer
		If Empty(nQtde)
			Exit
		EndIf
		
		If Empty(CB9->CB9_QTESEP) //-- ja devolvido
			CB9->(DbSkip())
			Loop
		EndIf
		
		If nQtde <= CB9->CB9_QTESEP
			nDevQtd := nQtde
			nQtde	  := 0
		Else
			nDevQtd := CB9->CB9_QTESEP
			nQtde   -= nDevQtd
		EndIf
		
		If !DevItemCB8(nDevQtd)
			VTAlert(STR0059,STR0008,.T.,4000,3) //"Item separado nao localizado!"###"Aviso"
			CB9->(DbSetOrder(12))
			CB9->(DbSeek(xFilial("CB9")+cOrdSep))
			Return
		EndIf
		
		RecLock("CB9",.F.)
		CB9->CB9_QTESEP -= nDevQtd
		If Empty(CB9->CB9_QTESEP)
			CB9->(DbDelete())
		EndIf
		CB9->(MsUnlock())
	EndDo
EndIf

RecLock("CB7",.F.)
CB7->CB7_STATUS := "1"
CB7->(MsUnlock())
Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o	 ³DevItemCB8  ³ Autor ³ ACD                 ³ Data ³ 16/02/05 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Devolve Items separados para o itens a separar CB8         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ SIGAACD                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function DevItemCB8(nQtde,cLoteOri)

Local aCB8			:= CB8->(GetArea())
Local aLoteOri		:= {}
Local lAtuLotCB8	:= .F.

Default cLoteOri	:= ""

CB8->(DbSetOrder(4))
If !CB8->(DbSeek(xFilial("CB8")+CB9->(CB9_ORDSEP+CB9_ITESEP+CB9_PROD+CB9_LOCAL+CB9_LCALIZ+CB9_LOTECT+CB9_NUMLOT+CB9_NUMSER)))
	Return .F.
EndIf

While CB8->(!Eof() .AND. ;
	CB8_FILIAL+CB8_ORDSEP+CB8_ITEM+CB8_PROD+CB8_LOCAL+CB8_LCALIZ+CB8_LOTECT+CB8_NUMLOT+CB8_NUMSER ==;
	xFilial("CB8")+CB9->(CB9_ORDSEP+CB9_ITESEP+CB9_PROD+CB9_LOCAL+CB9_LCALIZ+CB9_LOTECT+CB9_NUMLOT+CB9_NUMSER))
	If CB8->CB8_PEDIDO # CB9->CB9_PEDIDO
		CB8->(DbSkip())
		Loop
	EndIf

	If CB8->CB8_SEQUEN # CB9->CB9_SEQUEN
		CB8->(DbSkip())
		Loop
	EndIf

	If CB7->CB7_ORIGEM == "3" .And. CB8->CB8_CFLOTE $ "2" .And. CB9->CB9_LOTECT <> CB9->CB9_LOTORI .And. __lLoteOPConf
		UpLotEmp(CB8->CB8_OP,CB8->CB8_PROD,CB8->CB8_LOCAL,CB8->CB8_QTDORI,CB8->CB8_SALDOS,cLoteOri,CB8->CB8_NUMLOT,CB9->CB9_LOTECT,CB8->CB8_TRT)

		aLoteOri   := LoteOriCB8(CB8->CB8_PROD,CB8->CB8_OP)
		lAtuLotCB8 := LoteCB9Exc(CB9->CB9_ORDSEP,CB9->CB9_ITESEP,CB9->CB9_PROD,CB9->CB9_LOCAL,CB9->CB9_LCALIZ,CB9->CB9_LOTECT,CB9->CB9_NUMLOT,CB9->CB9_NUMSER,CB9->(Recno()))
	EndIf

	RecLock("CB8")
	If nQtde < CB8->CB8_QTDORI
		CB8->CB8_SALDOS := CB8->CB8_SALDOS + nQtde
	Else
		CB8->CB8_SALDOS := CB8->CB8_SALDOS + CB8->CB8_QTDORI
	EndIf

	If "01" $ CB7->CB7_TIPEXP .And. !"01" $ CB7->CB7_TIPEXP
		CB8->CB8_SALDOE := CB8->CB8_SALDOE + nQtde
	EndIf

	If lAtuLotCB8
		CB8->CB8_LOTECT := aTail(aLoteOri)
	EndIf

	CB8->(MsUnlock())
	CB8->(DbSkip())
EndDo

//Restaura Ambiente
CB8->(RestArea(aCB8))

Return .T.

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao    ³ VldCodSep³ Autor ³ ACD                   ³ Data ³ 25/01/05 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ Validacao da Ordem de Separacao                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ SIGAACD                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±³ Parametro³ nType, number, indica onde será a exibição, sendo 1=VT100; ³±±
±±									2=via ERP Protheus e 3=API	          ³±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function VldCodSep( nType )
Local cMsg := ""
Local lReturn := .T.

DEFAULT nType := 1	// executa pelo VT100

If Empty(cOrdSep)
	If nType == 1	// executa pelo VT100
		VtKeyBoard(chr(23))
	EndIf
	lReturn := .F.
EndIf

If lReturn 
	CB7->(DbSetOrder(1))
	CB7->(DbSeek(xFilial("CB7")+cOrdSep))
	If CB7->(Eof())
		cMsg := STR0060		//"Ordem de separacao nao encontrada.
		lReturn := .F.
	Endif
EndIf

If lReturn .And. CB7->CB7_STATUS == "3"
	cMsg := STR0061		//"Ordem de separacao em processo de embalagem"
	lReturn := .F.
Endif

If lReturn .And. CB7->CB7_STATUS == "4"
	cMsg := STR0062		//"Ordem de separacao com embalagem finalizada"
	lReturn := .F.
Endif

If lReturn .And. CB7->CB7_STATUS  == "5"  .OR.  CB7->CB7_STATUS  == "6" .OR. !Empty(CB7->CB7_NOTA)
	cMsg := STR0063		//"Ordem de separacao possui Nota gerada"
	lReturn := .F.
Endif

If lReturn .And. CB7->CB7_STATUS  == "7"
	cMsg := STR0064 	//"Ordem de separacao possui etiquetas oficiais de volumes"
	lReturn := .F.
Endif

If lReturn .And. CB7->CB7_STATUS  == "8"
	cMsg := STR0065		//"Ordem de separacao em processo de embarque"
	lReturn := .F.
Endif

If lReturn .And. CB7->CB7_STATUS == "9" .And. ("06" $ CB7->CB7_TIPEXP) .And. !("09" $ CB7->CB7_TIPEXP)
	cMsg := STR0066		//"Ordem de separacao ja Embarcada"
	lReturn := .F.
Endif

CB9->(DbSetOrder(12))
If lReturn .And. !CB9->(DbSeek(xFilial("CB9")+CB7->CB7_ORDSEP)) 
	cMsg :=  STR0067	//"Ordem de separacao ainda nao foi separada"
	lReturn := .F.
EndIf

If lReturn .And. CB7->CB7_STATPA == "1" .AND. CB7->CB7_CODOPE # cCodOpe  // SE ESTIVER EM SEPARACAO E PAUSADO SE DEVE VERIFICAR SE O OPERADOR E" O MESMO
	If !ACDYesNo( nType, STR0068 + CB7->CB7_CODOPE + STR0069, STR0008, 3 )	 //"Ordem Separacao iniciada pelo operador "###". Deseja continuar ?"###"Aviso"
		If nType == 1	// executa pelo VT100
		   VtKeyboard(Chr(20))
		Endif
		lReturn := .F.
	Endif
Endif

If lReturn .And. !MSCBFSem() //-- fecha o semaforo, somente um separador por ordem de separacao
	cMsg := STR0070		//"Processo que desfaz Ordem Separacao ja esta em andamento...!"
	lReturn := .F.
EndIf

If lReturn .And. CB7->CB7_STATUS == "9" .And. ("09" $ CB7->CB7_TIPEXP)
	nRecCB7 := CB7->( Recno() )
	CB7->( dbGoTop() )
	While CB7->( !Eof() )
		If CB7->CB7_PRESEP == cOrdSep
			ACDAlert( nType, STR0071, STR0008, 4000, .T., 3 )		//"Pre-Separacao possui Separacao gerada !!!"###"Aviso"
			MSCBASem()
			lReturn := .F.
		EndIf
		CB7->( dbSkip() )
	EndDo
	CB7->( dbGoTo(nRecCB7) )
EndIf

If !lReturn .And. !Empty( cMsg )
	ACDAlert( nType, cMsg, STR0008, 4000, .T., 3 )		//"Aviso"
EndIf

Return lReturn


Static Function AglutCB9(cOrdSep,cArm,cEnd,cProd,cLote,cSLote)
Local nRecnoCB9:= CB9->(Recno())
Local aCB9	   := CB9->(GetArea())
Local nSaldoDev:=0

CB9->(DbSetOrder(9))
CB9->(DbSeek(xFilial("CB9")+cOrdSep+cProd+cArm+cEnd+cLote+cSLote))
While ! CB9->(Eof()) .and. ;
	CB9->(CB9_FILIAL+CB9_ORDSEP+CB9_PROD+CB9_LOCAL+CB9_LCALIZ+CB9_LOTECT+CB9_NUMLOT) ==;
	xFilial("CB9")+cOrdSep+cProd+cArm+cEnd+cLote+cSLote
	If Empty(CB9->CB9_QTESEP) //-- ja devolvido
		CB9->(DbSkip())
		Loop
	EndIf
	nSaldoDev +=CB9->CB9_QTESEP
	CB9->(DbSkip())
End
RestArea(aCB9)
CB9->(DbGoto(nRecnoCB9))
Return nSaldoDev


Static Function MSCBFSem()
Local nC:= 0
__nSem := -1
While __nSem  < 0
	__nSem  := MSFCreate("V176"+cCodOpe+".sem")
	IF  __nSem  < 0
		SLeep(50)
		nC++
		If nC == 3
			Return .f.
		EndIf
	Endif
End
FWrite(__nSem,STR0072+cCodOpe+STR0073+cOrdSep) //"Operador: "###" Ordem de Separacao: "
Return .t.

Static Function MSCBASem()
If __nSem > 0
	Fclose(__nSem)
	FErase("V176"+cCodOpe+".sem")
EndIf
Return 10

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao    ³ Endereco   ³ Autor ³ ACD                 ³ Data ³ 27/01/05 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ Rotina de solicitacao do endereco                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ SIGAACD                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function Endereco()
Local lMV_CFENDIG   := SuperGetMv("MV_CFENDIG") =="1"
Local nTamLoc       := TamSX3("B2_LOCAL")[1]
Local nTamEnd       := TamSX3("BF_LOCALIZ")[1]
Local lMV_CONFEND   := SuperGetMv("MV_CONFEND") # "1"

If !Empty(CB9->CB9_LCALIZ) .and. ! lMV_CFENDIG
	cArmazem := CB9->CB9_LOCAL
	cEndereco:= CB9->CB9_LCALIZ
Endif

If CB9->(CB9_LOCAL+CB9_LCALIZ)==cArmazem+cEndereco
	Return .t.
EndIf

cArmazem   := Space(nTamLoc)
cEndereco  := Space(nTamEnd)
cEtiqEnd   := Space(20)

VtClear()
If SuperGetMV("MV_LOCALIZ")<>"S" .or. ! Localiza(CB9->CB9_PROD)
	//-- quando nao controla o endereco GERAL ou
	//-- quanto este produto nao tiver controle de endereco
		@ IIf(lVT100B /*GetMv("MV_RF4X20")*/,0,1),0 VTSay STR0074 //"Va para o armazem"
		@ IIf(lVT100B /*GetMv("MV_RF4X20")*/,1,2),0 VTSay CB9->CB9_LOCAL
		@ IIf(lVT100B /*GetMv("MV_RF4X20")*/,3,6),0 VTPause STR0054 //"Enter para continuar"
	cArmazem := CB9->CB9_LOCAL
	Return .t.
Else
		@ IIf(lVT100B /*GetMv("MV_RF4X20")*/,0,3),0 VTSay STR0053 //"Va para o endereco"
		@ IIf(lVT100B /*GetMv("MV_RF4X20")*/,1,2),0 VTSay CB9->(CB9_LOCAL+"-"+CB9_LCALIZ)
EndIf

While .t.
	cArmazem  := Space(nTamLoc)
	cEndereco := Space(nTamEnd)
	cEtiqEnd  := Space(20)
	If lMV_CONFEND  //-- nao valida o endereco, somente informa
			@ @ IIf(lVT100B /*GetMv("MV_RF4X20")*/,3,6),0 VTPause STR0054 //"Enter para continuar"
		cArmazem := CB9->CB9_LOCAL
		cEndereco:= CB9->CB9_LCALIZ
	Else
			@ IIf(lVT100B /*GetMv("MV_RF4X20")*/,2,4),0 VTSay STR0055 //"Leia o endereco"
		If UsaCB0("02")
				@ IIf(lVT100B /*GetMv("MV_RF4X20")*/,3,5),0 VTGet cEtiqEnd pict "@!" valid VldEnd(@cArmazem,@cEndereco,cEtiqEnd)
		Else
				@ IIf(lVT100B /*GetMv("MV_RF4X20")*/,3,5),0 VTGet cArmazem pict "@!" valid ! Empty(cArmazem)
				@ IIf(lVT100B /*GetMv("MV_RF4X20")*/,3,5),3 VTSay "-" VTGet cEndereco pict "@!" valid VtLastKey()==5 .or. VldEnd(@cArmazem,@cEndereco,"")
		EndIf
		VTRead
		If VtLastKey() == 27
			If VTYesNo(STR0050,STR0011,.T.) //"Confirma a saida?"###"Atencao"
				Return .f.
			Endif
			Loop
		Endif
	Endif
	Exit
EndDo
Return .t.


//-------------------------------------------------------------------
/*/{Protheus.doc} DevItTela
	 Monta a tela de seleção de itens separados para desfazer
@author marcelo hruschka
@since dez/2023
*/
//-------------------------------------------------------------------
Static Function DevItTela()

	Local aArea      := GetArea()
	Local aAreaCB8	 := CB8->(GetArea())
	Local nOpca		 := 0
	Local bConfirma  := {|| nOpcA := 1, oModal:DeActivate() }
	Local bFechar 	 := {|| nOpcA := 0, oModal:DeActivate() }
	Local bGetData	 := {}
	Local aColunas	 := {}
	Local nX		 := 0
	Local oModal	 := Nil
	Local oBrowse	 := Nil
	Local oTabTemp   := Nil
	Local cAliasQry  := GetNextAlias()
	Local aCampoTmp  := {}
	Local aFiltro    := {}
	Local aIndex     := {}
	Local aSeek      := {}
	Local aCpoCB9    := FWSX3Util():GetAllFields( "CB9" , .F. )
	Local lAltMark	 := .T.
	Local lRetDesf	 := .F.
 
	//Carrega variável static '__lLoteOPConf'
	FnVlOpOs()

	// retira o campo filial e numero do array
	aDel(aCpoCB9,ASCAN(aCpoCB9,"CB9_FILIAL"))
	aDel(aCpoCB9,ASCAN(aCpoCB9,"CB9_ORDSEP"))
	aSize(aCpoCB9, Len(aCpoCB9)-2)

	// busca campos do SX3 da tabela CB9
	For nX := 1 To Len(aCpoCB9)
		cCampoX3  := aCpoCB9[nX]
		cTitulo	:= GetSx3Cache( cCampoX3, "X3_TITULO")
		nTamCpo	:= GetSx3Cache( cCampoX3, "X3_TAMANHO")
		cTipoCpo:= GetSx3Cache( cCampoX3, "X3_TIPO")
		nDecCpo	:= GetSx3Cache( cCampoX3, "X3_DECIMAL")
		aAdd(aCampoTmp	,{cCampoX3,cTipoCpo,nTamCpo,nDecCpo})
		aAdd(aFiltro	,{cCampoX3,cTitulo,cTipoCpo,nTamCpo,nDecCpo, GetSx3Cache(cCampoX3,"X3_PICTURE")})//Adiciona o título dos campos na pesquisa por filtro
		If cTipoCpo == "C"
			aAdd(aIndex	, cCampoX3)			
			aAdd(aSeek	,{cTitulo, { {cTitulo, cTipoCpo, nTamCpo, 0, cTitulo, GetSx3Cache(cCampoX3,"X3_PICTURE"), cCampoX3} } , Len(aIndex), .T. })
		EndIf
		bGetData := &("{ ||(oBrowse:Alias())-> " + cCampoX3 + " }")
		aAdd( aColunas, FWBrwColumn():New())
		aColunas[nX]:SetData(bGetData)
    	aColunas[nX]:SetTitle(cTitulo)
    	aColunas[nX]:SetSize(nTamCpo)
    	aColunas[nX]:SetID(cCampoX3)
	Next

	// cria campo para selecionar os registros
	aAdd(aCampoTmp	,{"MARK" ,"N", 1,0})
	aAdd(aCampoTmp	,{"RECNO","N",99,0})

	oTabTemp:= FWTemporaryTable():New(cAliasQry) // seta tabela temporária
	oTabTemp:SetFields(aCampoTmp) // seta os campos da tabela temporária
	For nX := 1 to Len(aIndex)		
		oTabTemp:AddIndex( StrZero(nX,2), {aIndex[nX]} )//Adiciona os Indices da tabela temporária
	Next nX	
	oTabTemp:Create() //Cria a tabela temporaria	

	// monta tabela temporaria
	CB9SqlToTrb( aCampoTmp, cAliasQry, @lAltMark)//Adiciona os dados da query na tabela temporária

	// monta tela
	oModal	:= FWDialogModal():New()
	oModal:SetEscClose(.T.)
	oModal:SetTitle(OemToAnsi(FwSX2Util():GetX2Name("CB9")))
	oModal:EnableAllClient()
	oModal:CreateDialog()
	oModal:addButtons({ { 1,"Confirmar", bConfirma, "",0,.T.,.F.} , { 1,"Cancelar", bFechar, "",0,.T.,.F.}})
	oBrowse := FWFormBrowse():New()
	oBrowse:AddMarkColumns( { || IIf( (cAliasQry)->MARK == 1, "LBOK", "LBNO" ) }, { || IIf( (cAliasQry)->MARK == 0 .Or. !lAltMark, (cAliasQry)->MARK := 1, (cAliasQry)->MARK := 0 ) } )
	oBrowse:DisableDetails()
	oBrowse:DisableReport()	
	oBrowse:SetDescription(OemToAnsi(STR0075 + CB7->CB7_ORDSEP))
	oBrowse:SetDataTable()
	oBrowse:SetAlias(oTabTemp:GetAlias())
	oBrowse:SetColumns(aColunas)
	oBrowse:SetSeek(,aSeek)
	oBrowse:SetDoubleClick(bConfirma)
	oBrowse:SetOwner(oModal:getPanelMain())
	oBrowse:SetFieldFilter(aFiltro)
	oBrowse:SetUseFilter()
	If lAltMark
		oBrowse:aColumns[1]:bHeaderClick := {|| A176MkAll( oBrowse ) }
		oBrowse:SetDoubleClick( {|| A176MkOne( oBrowse ) } )
	EndIf
	oBrowse:Activate()
	oModal:Activate()
	
	// confirmação da tela
	If nOpcA == 1
		CB8->( DbSetOrder(4) ) //CB8_FILIAL+CB8_ORDSEP+CB8_ITEM+CB8_PROD+CB8_LOCAL+CB8_LCALIZ+CB8_LOTECT+CB8_NUMLOT+CB8_NUMSER
		
		lRetDesf := .T.
		// processa tabela temporaria e desfaz separação dos registros marcados
		DbSelectArea(cAliasQry)
		DbGoTop()
		While !(cAliasQry)->(EOF())
			If (cAliasQry)->MARK == 1
				CB9->(DbGoTo((cAliasQry)->RECNO))

				//Tratamento caso o lote da CB8 não seja o lote que está sendo estornado na CB9
				If __lLoteOPConf .And. !lAltMark
					If CB8->(DbSeek(xFilial("CB8")+CB9->(CB9_ORDSEP+CB9_ITESEP+CB9_PROD+CB9_LOCAL+CB9_LCALIZ))) .And. CB9->CB9_LOTECT <> CB8->CB8_LOTECT
						RecLock("CB8")
						CB8->CB8_LOTECT := CB9->CB9_LOTECT
						CB8->(MsUnlock())
					EndIf
				EndIf

				GrvEstCB9((cAliasQry)->CB9_QTESEP,(cAliasQry)->CB9_QTESEP)
			Endif
			(cAliasQry)->(DbSkip())
		EndDo
	EndIf

	RestArea( aAreaCB8 )
	RestArea( aArea )

	oTabTemp:Delete() //Deletando a tabela temporária e liberando a memória utilizada
	FreeObj( oModal )
	FreeObj( oBrowse )
	FreeObj( oTabTemp )

	FwFreeArray( aIndex )
	FwFreeArray( aSeek )
	FwFreeArray( aCampoTmp )
	FwFreeArray( aFiltro )
	FwFreeArray( aCpoCB9 )
	FwFreeArray( aAreaCB8 )
	FwFreeArray( aArea )

Return lRetDesf

/*/{Protheus.doc} FnVlOpOs
Função para carregar a variavel static '__lLoteOPConf'
@author Leonardo Kichitaro
@since 08/05/2025
/*/
Static Function FnVlOpOs()
	//Validação do ambiente para Ordem de Separacao de SA
	If __lLoteOPConf == Nil
		If (__lLoteOPConf := FindFunction( 'AcdVldSA' ))
			__lLoteOPConf := AcdVldSA("CB9","CB9_LOTORI")
		EndIf
	EndIf
Return

//-------------------------------------------------------------------
/*/{Protheus.doc} CB9SqlToTrb
	Insere os registros dos itens da ordem de separação na tabela temporaria
@type  Static Function
@author marcelo hruschka
@since dez/2023
@param aStruTmp	, objeto, estrutura da tabela temporária
       cAliasTmp, caractere, alias da tabela temporária
@return Nil
/*/
//-------------------------------------------------------------------
Static Function CB9SqlToTrb( aStruTmp, cAliasTmp, lAltMark )

	Local aArea := GetArea()
	Local nI	:= 0
	
	// busca dados da separação
	CB9->( DbSetOrder(1) ) // CB9_FILIAL+CB9_ORDSEP+CB9_CODETI
	CB9->( DbSeek( CB7->CB7_FILIAL+CB7->CB7_ORDSEP ) )
	While !CB9->( EOF() ) .And. CB9->CB9_FILIAL+CB9->CB9_ORDSEP == CB7->CB7_FILIAL+CB7->CB7_ORDSEP
		( cAliasTmp )->( DbAppend() )
		For nI := 1 To Len(aStruTmp)
			If aStruTmp[nI,1] <> "MARK" 
				If aStruTmp[nI,1] == "RECNO" 
					( cAliasTmp )->RECNO := CB9->( RECNO() )
				Else
					( cAliasTmp )->( FieldPut( nI, CB9->( FieldGet( FieldPos( aStruTmp[ nI, 1 ] ) ) ) ) )				
				Endif
			ElseIf __lLoteOPConf .And. CB7->CB7_ORIGEM == "3" .And. CB9->CB9_LOTECT <> CB9->CB9_LOTORI
				lAltMark := .F.
			Endif
		Next 
		CB9->( DbSkip() )
	End

	If !lAltMark
		( cAliasTmp )->(dbGoTop())
		While !( cAliasTmp )->(Eof())
			//Atualiza item(s) separados
			RecLock(cAliasTmp, .F.)
			( cAliasTmp )->MARK := 1
			( cAliasTmp )->(MsUnlock())
			( cAliasTmp )->(dbSkip())
		EndDo
	EndIf

	RestArea( aArea )
	FWFreeArray( aArea )
	
Return Nil


//-------------------------------------------------------------------
/*/{Protheus.doc} A176MkOne
	Funcao Responsavel para marcar/desmarcar o registros selecionado
@type  Static Function
@author Marcelo Hruschka
@since Dez/2023
@param oObjMark, objeto fwBrowse
@return nil
/*/
//-------------------------------------------------------------------
Static Function A176MkOne( oObjMark )

	Local nMark 
	Local cMarkCB9 := ''

	Default oObjMark := Nil
	If oObjMark <> Nil
		cMarkCB9 := oObjMark:cAlias
		nMark := IIF( ( cMarkCB9 )->MARK == 1, 0, 1 )
		( cMarkCB9 )->MARK := nMark
		oObjMark:Refresh( , .T. )
	EndIf

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} A176MkAll
	Funcao Responsavel para marcar/desmarcar todos os registros no markbrowse
@type  Static Function
@author Marcelo Hruschka
@since Dez/2023
@version 1.00
@param oObjMark, objeto fwBrowse
@return nil
/*/
//-------------------------------------------------------------------
Static Function A176MkAll( oObjMark )

	Local nMark 
	Local cMarkCB9 := ''
	Default oObjMark := Nil

	If oObjMark <> Nil
		cMarkCB9 := oObjMark:cAlias
		( cMarkCB9 )->( DbGoTop() )
		nMark := IIF( ( cMarkCB9 )->MARK == 1, 0, 1 )
		While ( cMarkCB9 )->( !EOF() ) 
			( cMarkCB9 )->MARK := nMark
			( cMarkCB9 )->( DbSkip() )
		End
		( cMarkCB9 )->( DbGoTop() )
		oObjMark:Refresh( , .T. )
	EndIf

Return

//-------------------------------------------------------------------
/*{Protheus.doc} ACDERP176
	Funcao executada no ACDA100 para chamada da rotina ACDV176 pelo Protheus
@type  Function
@author Marcelo Hruschka
@since Jan/2024
@version 1.00
@return nil
/*/
//-------------------------------------------------------------------
Function ACDERP176()
Return ACDV176( .T. )


/*/{Protheus.doc} refazCB8SA
Refaz os registros da CB8 a partir dos dados da SCP, atualizando a quantidade original e o saldo. Quando encerrado uma OS por SA parcialmente a CB8 é ajustada conforme CB9.
@type function
@version 1.0 
@author wellington.melo
@since 8/21/2025
@param cNumSA, character, recebe a numero da SA
@param cOrdSepara, character, recebe a ordem de separação a ser processada
/*/
Static Function refazCB8SA(cNumSA, cOrdSepara)
	
	Local aAreaSCP   := SCP->(FwGetArea())
	Local aAreaCB8   := CB8->(FwGetArea())

	Default cNumSA := ""
	Default cOrdSepara := ""

	SCP->( DbSetOrder(1) )
	CB8->( DbSetOrder(4) ) //CB8_FILIAL+CB8_ORDSEP+CB8_ITEM+CB8_PROD+CB8_LOCAL+CB8_LCALIZ+CB8_LOTECT+CB8_NUMLOT+CB8_NUMSER
	If SCP->( DbSeek( FWxFilial("SCP") + cNumSA ) )
		While !SCP->( Eof() ) .And. SCP->CP_FILIAL + SCP->CP_ORDSEP == FWxFilial("SCP") + cOrdSepara
			If CB8->( DbSeek( FWxFilial("CB8") + SCP->( CP_ORDSEP + CP_ITEM + CP_PRODUTO ) ) )
				//Avalio se a quantidade CP_QUANT é diferente a CB8_QTDORI e se for, atualizo o qtdori e saldo
				If SCP->CP_QUANT <> CB8->CB8_QTDORI
					CB8->( RecLock("CB8", .F.) )
					CB8->CB8_QTDORI := SCP->CP_QUANT
					CB8->CB8_SALDOS := SCP->CP_QUANT

					CB8->( MsUnlock() )
				EndIf
			EndIf
		SCP->( DbSkip() )
		EndDo
	EndIf

	FwRestArea(aAreaCB8)
	FwRestArea(aAreaSCP)
Return 
