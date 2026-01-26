#INCLUDE "TPLFuncs.ch"
#xcommand DEFAULT <uVar1> := <uVal1> ;
                  [, <uVarN> := <uValN> ] => ;
                  <uVar1> := If( <uVar1> == nil, <uVal1>, <uVar1> ) ;;
                  [ <uVarN> := If( <uVarN> == nil, <uValN>, <uVarN> ); ]

#INCLUDE "rwmake.ch"

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณTplCadLX5 บ Autor ณCarlos A. Gomes Jr. บ Data ณ  31/03/04   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ Cadastro de Tabelas especificas de Templates. (LX5)        บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Templates                                                  บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/

Template Function TplALX5

Private cCadastro := STR0001 //"Cadastro de Tabelas Templates"
Private aRotina   := MenuDef()

Private cDelFunc := ".T."
Private cString := "LX5"

DbSelectArea("LX5")
DbSetOrder(1)
mBrowse( 6,1,22,75,cString)

Return
/*/
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑฺฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฟฑฑ
ฑฑณFun็ใo    ณ MenuDef  ณ Autor ณ Conrado Q. Gomes      ณ Data ณ 11.12.06 ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณDescri…o ณ Defini็ใo do aRotina (Menu funcional)                      ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณSintaxe   ณ MenuDef()                                                  ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณParametrosณ                                                            ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณ Uso      ณ TPLFUNCS                                                   ณฑฑ
ฑฑภฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤูฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/
Static Function MenuDef()
Local aRotina := {{STR0002, "AxPesqui",  0, 1, 0, .F.},;	//"Pesquisar"
                  {STR0003, "T_TelaLx5", 0, 2, 0, .T.},;	//"Visualizar"
                  {STR0004, "T_TelaLx5", 0, 3, 0, .T.},;	//"Incluir"
                  {STR0005, "T_TelaLx5", 0, 4, 0, .T.},;	//"Alterar"
                  {STR0006, "T_TelaLx5", 0, 5, 0, .T.},;	//"Excluir"
                  {STR0007, "T_TelaLXB", 0, 6, 0, .T.}}		//"Campos F3"
Return(aRotina)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณTela LX5  บAutor  ณCarlos A. Gomes Jr. บ Data ณ  31/03/04   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Tela de Cadastro / Consulta / Delecao LX5                  บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

Template Function TelaLx5(cArq,nReg,nOpcx)

Local lNewReg    := .T.
Local aOldCols   := {}
Local aOldDel    := {}
Local aTempx     := {}
Local _nX

Private cTabela  := Space(2)
Private cDescri  := Space(55)
Private aHeader  := {}
Private aCols    := {}
Private aC       := {}
Private aR       := {}
Private nLinGetD := 0
Private cTitulo  := ""
Private aCGD     := {065,005,130,380}
Private n        := 1

If nOpcx != 3
	If nReg == 0
		MsgAlert(STR0008) //"Inclua um item primeiro!"
		Return
	Else
		If LX5->LX5_TABELA != "00"
			LX5->(DbSeek(xFilial("LX5") + "00" + LX5->LX5_TABELA))
		EndIf
		cTabela := Left(LX5->LX5_CHAVE,2)
		cTitulo := LX5->LX5_DESCRI
	EndIf
EndIf

Aadd(aHeader, {STR0009, "LX5_CHAVE",  "@!", 06, 0, "!Empty(M->LX5_CHAVE) .And. T_VLDLX5(M->LX5_CHAVE)", , "C", "LX5", "R"}) //"Chave"
Aadd(aHeader, {STR0010, "LX5_DESCRI", "@!", 55, 0,                                                    , , "C", "LX5", "R"}) //"Desc. Port."
Aadd(aHeader, {STR0011, "LX5_DESCSP", "@!", 55, 0,                                                    , , "C", "LX5", "R"}) //"Desc. Esp."
Aadd(aHeader, {STR0012, "LX5_DESCEN", "@!", 55, 0,                                                    , , "C", "LX5", "R"}) //"Desc. Ing."

If nOpcx == 3
	Aadd(aCols,{Space(6),Space(55),Space(55),Space(55),.F.})
Else
	cChave  := LX5->LX5_CHAVE
	cDescri := LX5->LX5_DESCRI
	If LX5->( DbSeek( xFilial("LX5") + cTabela ) )
		Do While LX5->(! Eof()) .AND. LX5->LX5_FILIAL == xFilial("LX5") .AND. LX5->LX5_TABELA == cTabela
			Aadd(aCols,{LX5->LX5_CHAVE,LX5->LX5_DESCRI,LX5->LX5_DESCSP,LX5->LX5_DESCEN,.F.})
			LX5->(DbSkip())
		EndDo
	Else
		Aadd(aCols,{Space(6),Space(55),Space(55),Space(55),.F.})
	EndIf
EndIf

If nOpcx == 4
	aOldCols := AClone(aCols)
EndIf

AADD(aC, {"cTabela", {20,05}, STR0013, "@!", "ExistChav('LX5','00'+cTabela)", "", nOpcx == 3}) //"Tabela "
AADD(aC, {"cDescri", {20,40}, " ",     "@!", " ", "", nOpcx == 3})

cLinhaOk := "!Empty(aCols[n,1]) .Or. aCols[n,Len(aHeader)+1]"
cTudoOk  := "AllwaysTrue() .And. T_DelTelaLX5()"

If Modelo2(cTitulo, aC, aR, aCGD, nOpcx, cLinhaOk, cTudoOk,,,,999,{100,0,600,800}) .And. nOpcx != 2

	If nOpcx == 5 .And. MsgYesNo(STR0014 + cTitulo ) //"Deseja excluir toda a tabela "
		LXB->(DbSetOrder(2))
		If LXB->(DbSeek(xFilial("LXB")+cTabela))
			MsgAlert(STR0015) //"Exclua o relacionamento com campos F3 antes de excluir a tabela"
			Return
		EndIf
		LX5->(DbGoto(nReg))
		RecLock("LX5",.F.)
		DbDelete()
		MsUnLock()
		Do While LX5->(DbSeek(xFilial("LX5")+cTabela))
			RecLock("LX5",.F.)
			DbDelete()
			MsUnLock()
		EndDo
	Else
		If nOpcx == 3
			RecLock("LX5",.T.)
			LX5->LX5_FILIAL := xFilial("LX5")
			LX5->LX5_TABELA := "00"
			LX5->LX5_CHAVE  := cTabela
			LX5->LX5_DESCRI := cDescri
			MsUnLock()
		EndIf

		For _nX := 1 To Len(aCols)
			lNewReg := !(LX5->(DbSeek(xFilial("LX5")+cTabela+aCols[_nX,1])))
			If aCols[_nX,5] .And. !lNewReg
				RecLock("LX5",.F.)
				DbDelete()
				MsUnLock()
			Elseif !aCols[_nX,5]
				RecLock("LX5",lNewReg)
				LX5->LX5_FILIAL := xFilial("LX5")
				LX5->LX5_TABELA := cTabela
				LX5->LX5_CHAVE  := aCols[_nX,1]
				LX5->LX5_DESCRI := aCols[_nX,2]
				LX5->LX5_DESCSP := aCols[_nX,3]
				LX5->LX5_DESCEN := aCols[_nX,4]
				MsUnLock()
			EndIf
		Next
        
        n := _nX
        		
		If nOpcx == 4
			AEval(aOldCols,{|x,y| aTempx := AClone(x), If( AScan(aCols,{|a| a[1] ==  aTempx[1] })== 0 , AAdd(aOldDel,aClone(aTempx)) , ) })
			If Len(aOldDel) > 0
				For _nX := 1 To Len(aOldDel)
					If LX5->(DbSeek(xFilial("LX5")+cTabela+aOldDel[_nX,1]))
						RecLock("LX5",.F.)
						DbDelete()
						MsUnLock()
					EndIf
				Next
				n := _nX
			EndIf
		EndIf
	EndIf			
	DbCommitAll()
Endif

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณTPLConPad บAutor  ณCarlos A. Gomes Jr. บ Data ณ  01/04/04   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Funcao de pesquisa de dados na tabela especial.            บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

Template Function TPLConPad()

Local oTplCon, oBtn1, oBtn2, oBtn3, oBtn4, oBtn5, oBrw
Local cCampo   := AllTrim(Substr(ReadVar(),4))
Local cTabela  := Space(2)
Local cReturn  := &(ReadVar())
Local cFind    := Space(55)
Local cTitulo  := Space(55)
Local cOrdem   := "Chave"
Local aColsLXB := {}
Local aHeadLXB := {}
Local cSeek    := ""
Local cWhile   := ""
Local cBline   := ""
Local aRet     := {}
Local aCab     := {}
Local aLin     := {}
Local aTam     := {}
Local aCpo     := {}
Local cFiltro  := ""
Local cFiltro2 := Space(60)
Local lBotInc  := .F.
Local nI

LXB->(DbSetOrder(1))
If !(LXB->(DbSeek(xFilial("LXB")+cCampo)))
	MsgAlert(STR0016 + cCampo + STR0017) //"Pesquisa para o campo "###" nใo relacionada no LXB."
	Return cReturn
EndIf

cTabela := LXB->LXB_TABELA
cFiltro := Iif(!Empty(LXB->LXB_FILTRO),".And. (" + LXB->LXB_FILTRO + ")","")
lBotInc := (LXB->LXB_INCLUI == "1")

If LX5->( DbSeek( xFilial("LX5") + "00" + cTabela ) )
	cTitulo := LX5->LX5_DESCRI
	If !LX5->( DbSeek( xFilial("LX5") + cTabela ) )
		MsgAlert(STR0013 + cTabela + STR0018) //"Tabela "###" nใo possui conte๚do!"
		Return cReturn
	EndIf
Else
	MsgAlert(STR0013 + cTabela + STR0019) //"Tabela "###" nใo cadastrada!"
	Return cReturn
EndIf

cSeek   := '"' + xFilial("LX5") + cTabela + '"'
cWhile  := '!EOF() .And. LX5_FILIAL=="' + xFilial("LX5") + '" .And. LX5_TABELA=="' + cTabela + '"' + cFiltro
aRet    := LocxGrid("LX5",cWhile,,,,cSeek,1,,{"LX5_FILIAL","LX5_TABELA"})
aCpo    := AClone(aRet[1])
aCab    := AClone(aRet[3])
aTam    := AClone(aRet[4])
aLin    := AClone(aRet[5])

For nI:=1 to Len(aCpo)
	If !Empty(aCpo[nI,3])
		cBLine  += IIf(Empty(cBLine),"{",", ") + " Transform(oBrw:aArray[oBrw:nAT][" + alltrim(Str(nI))+ "], '" + aCpo[nI,3] + "')"
	Else
		cBLine  += IIf(Empty(cBLine),"{",", ") + "oBrw:aArray[oBrw:nAT][" + alltrim(Str(nI))+ "]"
	EndIf
Next nI

DEFINE MSDIALOG oTplCon TITLE STR0020+cTitulo FROM 4,3 TO 20,60 //"Consulta Template - "
oBrw					:= TWBrowse():New(12, 12, 170, 70,,aCab,aTam,oTPLCon,,,,,,,,,,,,,,.T.)
oBrw:SetArray(aLin)
oBrw:bLine				:= &("{ ||" + cBLine + "} }")
oBrw:bLDblClick		:= {|| cReturn := ConRet(oBrw,aLin), oTplCon:End() }
oBtn1					:= SButton():New(10,190, 1, {|| cReturn := ConRet(oBrw,aLin), oTplCon:End() },,)
oBtn2					:= SButton():New(23,190, 2, {|| oTplCon:End() },,)
oBtn3					:= SButton():New(36,190, 4, {|| LX5->(DbSeek(xFilial("LX5")+"00"+cTabela)), T_TelaLx5(,,4) },,lBotInc)
oBtn4					:= SButton():New(49,190,15, {|| LX5->(DbSeek(xFilial("LX5")+"00"+cTabela)), T_TelaLx5(,,2) },,)
oBtn5					:= SButton():New(62,190,17, {|| .T. },,.F.)
oCbox					:= TComboBox():New(7,6,,{STR0009,STR0021}, 130, 10, oTplCon) //"Chave"###"Descri็ใo"
oCbox:bSetGet			:= {|u| If(PCount()>0,cOrdem:=u,cOrdem) }
oCbox:bChange			:= {|| Ordena(cOrdem,@oBrw,aLin) }
oSay1					:= IW_Say( 92,12,STR0022,,,,,) //"Pesquisa por:"
oSay2					:= IW_Say(104,12,STR0023,,,,,) //"Localizar"
oGet1					:= IW_Edit(104,48,cFind,"@!",130,10,,,,,,{|x| Iif(PCount()>0,cFind := x,cFind)} )
oGet1:bChange			:= {|| ConPesq(@oBrw,cFind,aLin,cOrdem) }
ACTIVATE MSDIALOG oTplCon

Return cReturn

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณDelTelaLX5บAutor  ณCarlos A. Gomes Jr. บ Data ณ  01/04/04   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Verifica se hแ no minimo um acols valido                   บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

Template Function DelTelaLX5()

Local lRet := .T.

If AScan(aCols,{|x| !(x[5]) }) == 0 .And. nOpcx != 5
	MsgAlert(STR0024) //"Para deletar uma tabela inteira entre na op็ใo EXCLUIR"
	lRet := .F.
EndIf

Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณOrdena    บAutor  ณCarlos A. Gomes Jr. บ Data ณ  01/04/04   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Reordena o vetor                                           บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

Static Function Ordena(cOrdem,oBrw,aLin)
If cOrdem == "Chave"
	ASort(aLin,,,{|x,y| x[1] < y[1]})
	ASort(oBrw:aArray,,,{|x,y| x[1] < y[1]})
Else
	ASort(aLin,,,{|x,y| x[2] < y[2]})
	ASort(oBrw:aArray,,,{|x,y| x[2] < y[2]})
EndIf
oBrw:Refresh()
Return .T.

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณConRet    บAutor  ณCarlos A. Gomes Jr. บ Data ณ  01/04/04   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Atualiza o retorno da pesquisa                             บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

Static Function ConRet(oBrw,aLin)

Local cReturn := aLin[oBrw:NAT][1]

Return cReturn

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณConPesq   บAutor  ณCarlos A. Gomes Jr. บ Data ณ  01/04/04   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Atualiza o retorno da pesquisa                             บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function ConPesq(oBrw,cFind,aLin,cOrdem)

Local nOrdem := Iif(cOrdem == "Chave",1,2)
Local nNat   := 1

If (nNat := AScan(aLin, {|x| AllTrim(cFind) $ AllTrim(x[nOrdem]) }) ) != 0
	oBrw:NAT := nNat
	oBrw:Refresh()
EndIf

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณTelaLXB   บAutor  ณCarlos A. Gomes Jr. บ Data ณ  01/04/04   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Permite a inclusao de pesquisas em campos.                 บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

Template Function TelaLXB

Local aRet       := {}
Local aCampos    := {}
Local cSeek      := ""
Local cWhile     := ""
Local aCampo     := ""

Private aCGD     := {065,005,130,380}
Private aC       := {}
Private aR       := {}
Private aHeader  := {}
Private aCols    := {}
Private cTabela  := Iif(!LX5->(Eof()),Iif(LX5->LX5_TABELA=="00",Left(LX5->LX5_CHAVE,2),LX5->LX5_TABELA),"")
Private cLinhaOk := "( !Empty(aCols[n,1]) .And. ExistCpo('SX3',aCols[n,1],2) ) .Or. aCols[n,Len(aHeader)+1]"
Private cTudoOk  := "AllwaysTrue()"
Private cDescri  := Iif(!Empty(cTabela),Posicione("LX5",1,xFilial("LX5")+"00"+cTabela,"LX5_DESCRI"),"")

cSeek      := '"' + xFilial("LXB") + cTabela + '"'
cWhile     := '!EOF() .And. LXB_FILIAL=="' + xFilial("LXB") + '" .And. LXB_TABELA=="' + cTabela + '"'

If Empty(cTabela)
	MsgAlert(STR0025) //"Cadatre uma tabela Primeiro"
	Return
EndIf

If !(cUserName == STR0026) //"Administrador"
	MsgAlert(STR0027) //"Somente o Administrador pode cadastrar consultas!"
	Return
EndIf

AADD(aC, {"cTabela", {20,05}, STR0013, "@!",    " ", "", .F. }) //"Tabela "
AADD(aC, {"cDescri", {20,40}, " ",     "@!S30", " ", "", .F. })

aRet    := LocxGrid("LXB",cWhile,,,,cSeek,2,,{"LXB_FILIAL","LXB_TABELA"})
aHeader := AClone(aRet[1])
aCampos := AClone(aRet[3])
aCols   := AClone(aRet[5])

If Modelo2(STR0028, aC, aR, aCGD, 4, cLinhaOk, cTudoOk,,,,999,{100,0,600,800}) //"Campos de Pesquisa com F3."
	AEval(aCols, {|x,y| aCampo := AClone(x), GravaLXB(cTabela,aCampo) })
	AEval(aRet[5], {|x,y| aCampo := AClone(x) , If(AScan(aCols,{|a| AllTrim(aCampo[1]) == AllTrim(a[1])}) == 0, GravaLXB(cTabela,aCampo,.F.) , ) })
EndIf

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณGravaLXB  บAutor  ณCarlos A. Gomes Jr. บ Data ณ  01/04/04   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Grava dados no LXB                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

Static Function GravaLXB(cTabela,aVetor,lLXB)

Local lNew := .T.
Default lLXB := .T.

LXB->(DbSetOrder(2))
lNew := !(LXB->(DbSeek(xFilial("LXB")+cTabela+aVetor[1])))

If lLXB .And. !aVetor[4]
	If lNew
		SX3->(DbSetorder(2))
		If SX3->(DbSeek(aVetor[1]))
			If Empty(SX3->X3_F3) .Or. MsgYesNo(STR0029 + aVetor[1] + STR0030 + SX3->X3_F3 + "!"+Chr(10)+Chr(13) + ; //"O Campo "###" ja pesquisa a tabela "
			                                   STR0031 + cTabela + "?" ) //"Deseja realmente substituir pela tabela "
				RecLock("SX3",.F.)
				SX3->X3_F3 := "LX5"
				MsUnLock()
			Else
				MsgAlert(STR0032 + SX3->X3_F3 + STR0033) //"Voc๊ optou por manter a pesquisa "###". Esse registro nใo serแ gravado."
				Return
			EndIf
		Else
			MsgAlert(STR0034 + aVetor[1] + STR0035) //"Campo "###" nใo existe. Registro nใo cadastrado!"
			Return
		EndIf
	EndIf
	RecLock("LXB",lNew)
	LXB->LXB_FILIAL := xFilial("LXB")
	LXB->LXB_TABELA := cTabela
	LXB->LXB_CAMPO  := aVetor[1]
	LXB->LXB_FILTRO := aVetor[2]
	LXB->LXB_INCLUI := aVetor[3]
	MsUnLock()

ElseIf !lNew

	RecLock("LXB",.F.)
	DbDelete()
	MsUnLock()

	SX3->(DbSetorder(2))
	If SX3->(DbSeek(aVetor[1]))
		RecLock("SX3",.F.)
		SX3->X3_F3 := ""
		MsUnLock()
	EndIf

EndIf

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณVLDLX5    บAutor  ณCarlos A. Gomes Jr. บ Data ณ  01/04/04   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Validacao do campo chave                                   บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Template Function VLDLX5(cCampo)

If !(AScan(aCols,{|x| x[1] == cCampo }) == 0)
	MsgAlert(STR0036) //"Chave jแ cadastrada"
	Return .F.
EndIf

Return .T.
