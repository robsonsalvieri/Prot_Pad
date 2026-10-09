#include "AP5MAIL.CH"
#include "QADXFUN.CH"
#Include "TOTVS.ch"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o	 ³ QADCBox  ³ Autor ³ Iuspa                 ³ Data ³ 10/11/00 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Retorna String com descricao do combo                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function QADCBox(cCampo, cConteudo)
Local cBox := GetSx3Cache(cCampo, "X3_CBOX")
Local nPos := At(cConteudo + "=", cBox)
Local cSub := SubStr(cBox, nPos)
Local nFim := If(";" $ cSub, At(";", cSub) - 1, Len(cSub))
Local cRet := If(nPos=0,"",SubStr(cSub, 1, nFim))
                                      
Return(cRet)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o	 ³ QADDivLin³ Autor ³ Iuspa                 ³ Data ³ 10/11/00 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Retorna um array com string quebrada em linhas             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe	 ³ QADDivLin(ExpC1,ExpN1)                              		  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpC1 = String a ser quebrada em linhas                    ³±±
±±³          ³ ExpC2 = Largura maxima de cada linha                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso		 ³ Generico                               					  ³±±
±±³      	 ³                                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function QADDivLin(cTexto, nLargura)
Local aRet := {}, nLinha
cTexto := rTrim(cTexto)
For nLinha := 1 to MlCount(cTexto, nLargura)
	Aadd(aRet, MemoLine(cTexto, nLargura, nLinha))
Next
Return(aRet)	

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o	 ³QADImpCampo³ Autor ³ Iuspa                ³ Data ³ 10/11/00 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Retorna um array para impressao de cabecalhos e registros  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe	 ³ QADDivLin(ExpA1)                                  		  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpA1 = Array com os campos desejados                      ³±±
±±³          ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ                   ³±±
±±³      	 ³ Recebe um Array, com os campos desejados para impressao e  ³±±
±±³      	 ³ Retorna um Array com duas colunas sendo a primeira para    ³±±
±±³      	 ³ impressao do cabecalho (pesquisado no SX3 obedecendo a     ³±±
±±³      	 ³ lingua corrente) e a segunda um bloco de codigo para       ³±±
±±³      	 ³ impressao do registro corrente formatado pela picture      ³±±
±±³      	 ³ especificada no SX3.                                       ³±±
±±³      	 ³ Sera obedecido a largura de cada coluna em funcao do       ³±±
±±³      	 ³ tamanho maximo entre titulo (cabecalho) e campo impresso.  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function QADImpCampo(aArray)
Local x, nPos
Local aRet, cCab, cPic, nTam, cBlo
aRet := {}
For x := 1 to Len(aArray)
	cCab := RetTitle(aArray[x])
	cPic := PesqPict(GetSX3Cache(aArray[x], "X3_ARQUIVO"), aArray[x])
	nPos := FieldPos(aArray[x])
	nTam := Max(Len(AllTrim(cCab)), Len(Transform(FieldGet(nPos), cPic)))
	cCab := Pad(cCab, nTam)
	cBlo := '{|| Pad(Transform(' + aArray[x] + ', "' + cPic + '"), ' + Str(nTam, 3) + ')}'
	Aadd(aRet, {cCab, &cBlo})
Next	
Return(aRet)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºFuncao    ³QADCombo      ºAutor  ³Marcelo Iuspa   º Data ³  17/10/00   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Funcao que le o itens do combo no SX3 e retorna num array   º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP5                                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function QADCombo(cCampo,cCombo)
Local aArea    := GetArea()
Local cBox     := ""
Local aBox     := {}
Local nPosicao1:= 0
Local nPosicao2:= 0
Local cElem1 	:= cElem2:= ""

If ( !Empty(GetSX3Cache(cCampo,"X3_CAMPO")) )
	If __LANGUAGE == "PORTUGUESE"
		cBox  := GetSX3Cache(cCampo,"X3_CBOX")
	ElseIf __LANGUAGE == "SPANISH"
		cBox  := GetSX3Cache(cCampo,"X3_CBOXSPA")
	ElseIf __LANGUAGE == "ENGLISH"
		cBox  := GetSX3Cache(cCampo,"X3_CBOXENG")
	EndIf
	While ( !Empty(cBox) )
		nPosicao1   := At(";",cBox)
		If ( nPosicao1 == 0 )
			nPosicao1 := Len(cBox)+1
		EndIf
		nPosicao2   := At("=",cBox)
		cElem1 := SubStr(cBox,1,nPosicao2-1)
		cElem2 := SubStr(cBox,nPosicao2+1,nPosicao1-nPosicao2-1)
		aadd(aBox,{cElem1+' - '+cElem2,cElem1})
		cBox := SubStr(cBox,nPosicao1+1)
	EndDo
EndIf
dbSelectArea("SX3")
dbSetOrder(1)

RestArea(aArea)
Return(aBox)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o	 ³ QADVerCHK³ Autor ³ Paulo Emidio          ³ Data ³ 12/11/00 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ Verifica se existe alguma questao respondida no check list ³±±
±±³          ³ associado a Auditoria.									  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe	 ³ QadVerChk(cNumAud,cChkLst,cRevChkLst)			          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpC1 = Numero da Auditoria                                ³±±
±±³          ³ ExpC2 = Numero do Check List                               ³±±
±±³          ³ ExpC3 = Numero da Revisao do Check List                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso		 ³ Generico                               					  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function QadVerChk(cNumAud,cChkLst,cRevChkLst)
Local lRetorno := .T.
Local aOldArea := GetArea()

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Verifica se a Auditoria possui Questoes respondidas			 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ	
dbSelectArea("QUD")
dbSetOrder(2)
dbSeek(xFilial("QUD")+cNumAud+cChkLst+cRevChkLst)
While !Eof() .And. xFilial("QUD") == QUD->QUD_FILIAL .And.;
	QUD->QUD_NUMAUD == cNumAud	.And. QUD->QUD_CHKLST == cChkLst .And.;
	QUD->QUD_REVIS == cRevChkLst

	If !Empty(QUD->QUD_DTAVAL) 
		Help("",1,"QADAUDJRES")
		lRetorno := .F.
		Exit
	EndIf
	QUD->(dbSkip())
EndDo	

RestArea(aOldArea)

Return(lRetorno)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o	 ³ QadChkInt³ Autor ³ Paulo Emidio          ³ Data ³ 12/11/00 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ Verifica se o Check List possui Topicos e Questoes relacio-³±±
±±³          ³ nadas								              	      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe	 ³ QadVerChk(cChkLst,cRevChkLst)			         	      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpC1 = Numero da Auditoria                                ³±±
±±³          ³ ExpC2 = Numero do Check List                               ³±±
±±³          ³ ExpC3 = Numero da Revisao do Check List                    ³±±
±±³          ³ ExpL1 = Realiza pesquisa das questoes adicionais no QUE    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso		 ³ Generico                               				      ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function QadChkInt(cNumAud,cChkLst,cRevChkLst,lSeekPad)
Local lRetorno := .T.
Local cChkLstPad := GetMv("MV_QCHKPAD")
Local cRevi      := "00"
Local nTamChkPad := TAMSX3("QU2_CHKLST")[1]

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Tratamento para evitar falha do tamanho da variavel no DbSeek ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
IF LEN(cChkLstPad) < nTamChkPad
	cChkLstPad+=Space(nTamChkPad - LEN(cChkLstPad))+cRevi
Else
	cChkLstPad:=SUBS(cChkLstPad,1,nTamChkPad)+cRevi
Endif	

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Verifica se existem topicos	associados ao Check List		  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ	
QU3->(dbSetOrder(1))
QU3->(dbSeek(xFilial("QU3")+cChkLst+cRevChkLst))
If (QU3->QU3_CHKLST+QU3->QU3_REVIS) # (cChkLst+cRevChkLst)
	Help(cChkLst+" "+cRevChkLst,1,"QADNAOTOP")
 	lRetorno := .F.
EndIf           

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Verifica se existem questoes	 associadas ao Check List		 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ	
If (cChkLst+cRevChkLst) # cChkLstPad
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Realiza a pesquisa no Questionario associado ao Check List   ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ	
	QU4->(dbSetOrder(1))
	QU4->(dbSeek(xFilial("QU4")+cChkLst+cRevChkLst))
	If (QU4->QU4_CHKLST+QU4->QU4_REVIS) # (cChkLst+cRevChkLst)
		Help(cChkLst+" "+cRevChkLst,1,"QADNAOQST")
 		lRetorno := .F.
	EndIf                
Else
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Realiza a pesquisa no Questionario Adicional				 ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ	
	If lSeekPad
		QUE->(dbSetOrder(1))
		QUE->(dbSeek(xFilial("QUE")+cNumAud+cChkLst+cRevChkLst))
		If QUE->(Eof())
			Help(cChkLst+" "+cRevChkLst,1,"QADNAOADIC") 
			lRetorno := .F.
		EndIf
	EndIf

EndIf

Return(lRetorno)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³QADCHKEFET³ Autor ³Paulo Emidio de Barros ³ Data ³ 16/11/00 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Verifica a existencia do Check List e se o mesmo esta efe- ³±±
±±³          ³ vado.													  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ EXPC1 = Numero do Check List+Numero da Revisao			  ³±±
±±³		     ³ EXPL1 = Indica se o checklist esta efetivado. 		  	  ³±±
±±³			 ³ EXPL2 = Indica se o status do Checklist sera verificado.   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Generico                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function QadChkEfet(cKey,lEfetiva,lVerEfeChk,lVerObsChk,lBloKia)
Local lRetorno  := .T.              
Local aARea	    := GetArea()              
Local oDlgA 
Local oQual	 
Local cVar 
Local aRegQUE   := {}
Local nOpc      := 0
Local cRvQU2    := ""
Local cChkqList := ""
Local lFecha	:= .F.
Local lCpoQu3   := iif (Existblock("QADCPOQU3"),ExecBlock( "QADCpoQu3", .f., .f.),.F.)

Default lEfetiva   := .T.
Default lVerEfeChk := .T.
Default lVerObsChk := .F.
Default lBloKia	   := .F.	

DbSelectArea("QU2")
QU2->(dbSetOrder(1))
QU2->(dbSeek(xFilial("QU2")+cKey))
If QU2->(!Eof())
	If lVerEfeChk               
		If lEfetiva
			If (QU2->QU2_EFETIV == "3")  
				Help("",1,"QADCHKNEFE") 
				lRetorno := .F.
			EndIf		
		Else
			If (QU2->QU2_EFETIV == "1") .Or. (QU2->QU2_EFETIV == "2")
				Help("",1,"QADCHKJEFE") 
				lRetorno := .F.
			EndIf		
		EndIf
	EndIf
	If lVerObsChk
		If QU2->QU2_EFETIV == "2"
			Help("",1,"020CHKOBS") 
			lRetorno := .F.
		EndIf
	Endif
Else
	Help("",1,"QADNCHKLST")
	lRetorno := .F.
EndIf  

//Tratamento para apresentar os check list. . .

If lRetorno .And. IsInCallStack("QADA100")
	If lBloKia
		If !Empty(M->QUJ_CHKLST)
			cChkqList := M->QUJ_CHKLST
			QU2->(dbSetOrder(1))//Localiza a ultima revisao...
			While QU2->(!Eof()) .and. Alltrim(QU2->QU2_CHKLST) == Alltrim(M->QUJ_CHKLST)
				If QU2->QU2_EFETIV == "1"  
					cRvQU2 := QU2->QU2_REVIS						
				Endif	
				QU2->(dbSkip())
			Enddo			
		
			dbSelectArea("QU3")
			dbSetOrder(1)
			If dbSeek(xFilial("QU3")+M->QUJ_CHKLST+cRvQU2)			
				While QU3->(!Eof()) .and. QU3->QU3_FILIAL+QU3->QU3_CHKLST == xFilial("QU3")+M->QUJ_CHKLST      
					If Ascan(aRegQUE,{|X| Alltrim(X[1])+Alltrim(X[2])+Alltrim(X[3]) == Alltrim(QU3->QU3_CHKLST)+Alltrim(QU3->QU3_REVIS)+Alltrim(QU3->QU3_CHKITE)}) == 0
                        if !lCpoQU3
						    Aadd(aRegQUE,{QU3->QU3_CHKLST,QU3->QU3_REVIS,QU3->QU3_CHKITE})
						Else
							Aadd(aRegQUE,{QU3->QU3_CHKLST,QU3->QU3_REVIS,QU3->QU3_CHKITE,QU3->QU3_DESCRI})
						Endif	
					Endif
					QU3->(dbSkip())
				Enddo

				DEFINE MSDIALOG oDlgA TITLE OemToAnsi(STR0027) From 09,0 To 21.5,50 OF oMainWnd //Topicos
				If !lCpoQu3
					@ .5,1 LISTBOX oQual VAR cVar Fields HEADER OemToAnsi(STR0028),OemToAnsi(STR0029),OemToAnsi(STR0030),"B" SIZE 150,80 OF oDlgA
    			Else
					@ .5,1 LISTBOX oQual VAR cVar Fields HEADER OemToAnsi(STR0028),OemToAnsi(STR0029),OemToAnsi(STR0030),"Descr." SIZE 150,80 OF oDlgA					
				EndIf
				oQual:SetArray(aRegQUE)
				If !lCpoQu3
		   			oQual:bLine := { || {aRegQUE[oQual:nAT,1],aRegQUE[oQual:nAT,2],aRegQUE[oQual:nAT,3]}}
				Else
					oQual:bLine := { || {aRegQUE[oQual:nAT,1],aRegQUE[oQual:nAT,2],aRegQUE[oQual:nAT,3],aRegQUE[oQual:nAT,4]}}
				EndIf
				DEFINE SBUTTON FROM 10	,166	TYPE 1 ENABLE OF oDlgA ACTION (nOpc := 1,lFecha := .T.,nRegQM2 := oQual:nAT ,oDlgA:End()) 
				DEFINE SBUTTON FROM 22.5,166	TYPE 2 ENABLE OF oDlgA ACTION (nOpc := 0,lFecha := .F.,nRegQM2 := oQual:nAT,oDlgA:End()) 

				ACTIVATE MSDIALOG oDlgA Centered VALID lFecha
			Endif   
			
			If nOpc == 1
				M->QUJ_CHKLST:= aRegQUE[nRegQM2][1]
				M->QUJ_REVIS := aRegQUE[nRegQM2][2]
				M->QUJ_CHKITE:= aRegQUE[nRegQM2][3]         
				aCols[n][1]  := aRegQUE[nRegQM2][1]
				aCols[n][2]  := aRegQUE[nRegQM2][2]
				aCols[n][3]  := aRegQUE[nRegQM2][3]				
			Else
				M->QUJ_CHKLST:= CriaVar("QUJ_CHKLST",.T.) 
				M->QUJ_REVIS:=  CriaVar("QUJ_REVIS",.T.)    
				M->QUJ_CHKITE:= CriaVar("QUJ_CHKITE",.T.)     
				M->QUJ_NIVEL := CriaVar("QUJ_NIVEL",.T.)    				 
				M->QUJ_DESCRI := CriaVar("QUJ_DESCRI",.T.)    				 
				M->QUJ_EFETIV:= CriaVar("QUJ_EFETIV",.T.)    								
			Endif
		Endif
	Endif
Endif

RestArea(aARea)
Return(lRetorno)


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³qPsqChkLst³ Autor ³Paulo Emidio de Barros ³ Data ³ 16/11/00 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Verifica a existencia de Topicos associados e verifica se  ³±±
±±³          ³ o Check List informado esta efetivado. 					  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ EXPC1 = Numero do CheckList								  ³±±
±±³          ³ EXPC2 = Revisao do CheckList								  ³±±
±±³          ³ EXPL1 = Indica a pesquisa do CheckList					  ³±±
±±³          ³ EXPL2 = Indica a efetivacao do CheckList					  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Generico                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function qPsqChkLst(cChkLst,cRevi,lSeek,lEfet)
Local lRetorno := .T.
Local cKey     := ""
Local aAreaAnt := GetArea()                                   

lSeek := If(lSeek==NIL,.T.,lSeek)        
lEfet := If(lEfet==NIL,.T.,lEfet)
cKey  := If(Empty(cRevi),cChkLst,cChkLst+cRevi)

dbSelectArea("QU3")
dbSetOrder(1)      
dbSeek(xFilial("QU3")+cKey)
If lSeek
	If Eof()
		Help("",1,"QADNCHKLST") 
		lRetorno := .F.	
    EndIf
Else     
	If !Eof()
		Help("",1,"QADJCHKLST")
		lRetorno := .F.	
	EndIf
EndIf
   
If lRetorno
	lRetorno := QadChkEfet(cKey,lEfet,.T.)
EndIf

RestArea(aAreaAnt)                          
Return(lRetorno)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³QADVAudEnc³ Autor ³Paulo Emidio de Barros ³ Data ³ 16/11/00 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Verifica se a Auditoria esta encerrada			          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ EXPC1 = Numero da Auditoria								  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Generico                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function QadVAudEnc(cSeekAud)
Local lRetorno := .T.
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Verifica se a Auditoria esta encerrada						 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
QUB->(dbSetOrder(1))
QUB->(dbSeek(xFilial("QUB")+cSeekAud))
If QUB->(!Eof())
	If ! Empty(QUB->QUB_ENCREA)
		Help("",1,"QADAUDENC") 
		lRetorno := .F.
	EndIf
Else
	Help("",1,"QADNEXIAUD")  
	lRetorno := .F.
EndIf                 
Return(lRetorno)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³QAudEnvMai³ Autor ³Paulo Emidio de Barros ³ Data ³ 16/11/00 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Realiza o Envio de Emails								  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ EXPA1 = Enderecos com as contas para envio		 		  ³±±
±±³			 ³ EXPC1 = Conta para Envio dos emails						  ³±±
±±³			 ³ EXPC2 = Nomer do Servidor								  ³±±
±±³			 ³ EXPC3 = Senha da Conta para conexao						  ³±±
±±³			 ³ EXPL1 = Verifica se a conexao falhou						  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Generico                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function QAudEnvMail(aUsuarios,cMailConta,cMailServer,cMailSenha,lResult,cTipoemail)
Local cError	:= ""
Local lAuth 	:= GetMv("MV_RELAUTH",,.F.)
Local lMsgError	:= GetMv("MV_QMSGERM", .T., .T.) 
Local cSendConta:= QA_USUARIO()[5]	// Email do SigaCfg ou do Sra
Local nI		:=1
Local nAtConta

Default cTipoemail	:= "1" //1=Sistemas 2=Usuario

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Verifica se a conta de email do usuario esta com mais de uma e considera apenas ³
//³ a primeira para conectar e enviar email                                         ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If ";" $ cSendConta
	nAtConta := AT(";",cSendConta)
	cSendConta := SubStr(cSendConta,1,nAtConta-1)
Endif

IF cTipoemail=="2"  //Tipo 2=Usuario
	If cSendConta == ("SIGA"+cModulo) .Or. Empty(AllTrim(cSendConta))
		PswOrder(1)
		PswSeek(__CUSERID)
		aRetUser := PswRet(1)
		If !Empty(aRetUser[1][14])
			cSendConta := AllTrim(aRetUser[1][14])
	    Else                      
	        cSendConta := GetMV("MV_EMCONTA")
	        IF Empty(AllTrim(cSendConta))    
				cSendConta := "SIGA"+cModulo+"@PROTHEUS"
			Endif	
		EndIf
	Endif
Else				//Tipo 1=Sistemas
	cSendConta := GetMV("MV_EMCONTA")
	IF Empty(AllTrim(cSendConta))                
		cSendConta := "SIGA"+cModulo+"@PROTHEUS"
	Endif		
Endif	

cMailConta :=AllTrim(If(cMailConta  == NIL,GETMV("MV_RELACNT"),cMailConta))
cMailServer:=AllTrim(If(cMailServer == NIL,GETMV("MV_RELSERV"),cMailServer))
cMailSenha :=AllTrim(If(cMailSenha  == NIL,GETMV("MV_RELPSW") ,cMailSenha))

cSendConta := If(Empty(GetMV("MV_RELFROM",.F.,"")),cSendConta,AllTrim(GetMV("MV_RELFROM")))

If !Empty(cMailServer) .And. !Empty(cMailConta) .And. !Empty(cMailSenha)

	// Envia e-mail com os dados necessarios
	CONNECT SMTP SERVER cMailServer ACCOUNT cMailConta PASSWORD cMailSenha RESULT lResult

	// Autenticacao da conta de e-mail 
	If lResult .And. lAuth
		lResult := MailAuth(cMailConta,cMailSenha)
 		If !lResult
			lResult := QADGetMail() // Funcao que abre uma janela perguntando o usuario e senha para fazer autenticacao
		EndIf
		If !lResult
			//Erro na conexao com o SMTP Server
			If lMsgError
				GET MAIL ERROR cError
				MsgInfo(cError,OemToAnsi(STR0008)) //"Erro de Autenticacao"
			Endif
			Return Nil
		Endif
	Else
		If !lResult
			//Erro na conexao com o SMTP Server
			If lMsgError
				GET MAIL ERROR cError
				MsgInfo(cError,OemToAnsi(STR0009)) //"Erro de Conexao"
			Endif
			Return Nil
		Endif
	EndIf

	For nI :=1 to Len(aUsuarios)
		If Len(aUsuarios[nI]) == 3
			Aadd(aUsuarios[nI], "")
		Endif	
		If lResult
			SEND MAIL  				  ;
			FROM       cSendConta;
			TO		   aUsuarios[nI,1];
			SUBJECT	   aUsuarios[nI,2];
			BODY	   aUsuarios[nI,3];
			ATTACHMENT aUsuarios[nI,4];   
			RESULT	   lResult  
		Endif
		If !lResult
			If lMsgError
				GET MAIL ERROR cError
				MsgInfo(cError,OemToAnsi(STR0001)) //"Erro no envio de e-Mail"
			Endif
			Exit
		EndIf
	Next
	
	DISCONNECT SMTP SERVER

Endif

Return Nil

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao	 ³QADPsqPsw ³ Autor ³Paulo Emidio de Barros   ³ Data ³ 27/11/00 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³Verifica a existencia de apelido no configurador              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe	 ³QADPsqPsw                                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametro ³.T. or .F.                                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso		 ³SIGAQAD                                                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³         ATUALIZACOES SOFRIDAS DESDE A CONSTRU€AO INICIAL.               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Robson Ramir³14/05/02³ Meta ³Alteracao do alias da familia QU para QA    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function QADPsqPsw()
Local lRetorno := .T.
Local aSavArea := GetArea()
local cChave   := IIf(Alias()=="QU1",M->QU1_APELID,M->QAA_LOGIN)


PswUpper( .T. )
PswOrder( 2 )
If PswSeek( cChave )
   dbSelectArea("QAA")
   dbSetOrder(1)
   If dbSeek( xFilial("QAA")+cChave)
       Help("",1,"QADEXISADT") 
       lRetorno := .F.
   Endif
Else                    
	Help("",1,"QADINEXCFG") 
    lRetorno := .F.
Endif          
PswUpper( .F. )  

RestArea(aSavArea)
Return(lRetorno) 

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao	 ³QADSomPon ³ Autor ³Paulo Emidio de Barros   ³ Data ³ 19/04/01 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ Soma e devolve os pontos possíveis em uma Auditoria          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe	 ³QadSomPon(EXPC1)   										    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametro ³EXPC1 = Numero da Auditoria								    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³EXPN1 = Somatoria da pontuacao								³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso		 ³SIGAQAD                                                       ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/                                                                         
Function QADSomPon(cNumAud)
Local nPontos  := 0 
Local cSeek    := ""
Local cKeyQUD  := ""
Local nMin     := 0
Local nMax     := 0
Local nPeso    := 0            
Local nPesoTot := 0
Local lCpoApl := If(QUD->(FieldPos("QUD_APLICA")) > 0,.T.,.F.)

dbSelectArea("QUD")  
dbSetOrder(1)
dbSeek(cSeek:=xFilial("QUD")+cNumAud)
While !Eof() .and. (xFilial("QUD")+QUD->QUD_NUMAUD) == cSeek		

    If lCpoApl
		If QUD->QUD_APLICA == "2" // Nao considera questao
			dbSkip()
			Loop
		Endif
    Endif
	cKeyQUD := (QUD->QUD_CHKLST+QUD->QUD_REVIS+QUD->QUD_CHKITE+QUD->QUD_QSTITE)

	//Verifica o Tipo de Pontuacao								 
	If QUD->QUD_TIPO = "1"   //Padrao
		QU4->(dbSeek(xFilial("QU4")+cKeyQUD))
		nMin  := QU4->QU4_FAIXIN
		nMax  := QU4->QU4_FAIXFI
		nPeso := If(QU4->QU4_PESO==0,1,QU4->QU4_PESO)
		
	ElseIf QUD->QUD_TIPO = "2" //Adicional  
		QUE->(dbSeek(xFilial("QUE")+QUD->QUD_NUMAUD+cKeyQUD))
		nMin  := QUE->QUE_FAIXIN
		nMax  := QUE->QUE_FAIXFI
		nPeso := If(QUE->QUE_PESO==0,1,QUE->QUE_PESO)
	Endif	
	nPontos	 += (((nMax * nPeso)*100)/If(nMax>0,nMax,1))
	nPesoTot += (nPeso)
	dbSkip()             
	
Enddo	     
nPontos := nPontos / If(nPesoTot>0,nPesoTot,1)
Return(nPontos)

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³QADGetMail³ Autor ³ Eduardo de Souza      ³ Data ³ 30/10/02 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Tela solicitando usuario e senha para autenticacao da conta³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ QADGetMail()                                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ GENERICO                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function QADGetMail()

Local oDlg
Local oMailUsr
Local oMailPsw
Local oBtn1
Local oBtn2
Local cMailUsr:= Space(50)
Local cMailPsw:= Space(50)
Local lReturn := .F.

DEFINE MSDIALOG oDlg TITLE OemToAnsi(STR0002) FROM 000,000 TO 105,425 OF oDlg PIXEL // "Autenticacao de e-Mail"

@ 006,003 SAY OemToAnsi(STR0003) SIZE 040,010 OF oDlg PIXEL // "e-Mail"
@ 005,033 MSGET oMailUsr VAR cMailUsr SIZE 160,005 OF oDlg PIXEL

@ 019,003 SAY OemToAnsi(STR0004) SIZE 040,010 OF oDlg PIXEL // "Senha"
@ 018,033 MSGET oMailPsw VAR cMailPsw PASSWORD SIZE 160,005 OF oDlg PIXEL

DEFINE SBUTTON oBtn1 FROM 038,151 TYPE 1 ENABLE OF oDlg;
       ACTION If(MailAuth(AllTrim(cMailUsr),AllTrim(cMailPsw)),;
       			(lReturn:= .T.,oDlg:End()),MsgStop(OemToAnsi(STR0005))) // "Usuario e/ou Senha nao estao corretos, tente novamente."

DEFINE SBUTTON oBtn2 FROM 038,181 TYPE 2 ENABLE OF oDlg;
       ACTION  oDlg:End() 

ACTIVATE MSDIALOG oDlg CENTERED

Return lReturn

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³QADCkLstVig³ Autor ³ Eduardo de Souza     ³ Data ³ 13/11/02 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Retorna o Check-List Vigente                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ QADCkLstVig(ExpC1)                                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpC1 - Check-List                                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ GENERICO                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function QADCkLstVig(cChkLst)

Local cRevChkLst:= Space(Len(QU2->QU2_REVIS))

If QU2->(DbSeek(xFilial("QU2")+cChkLst))
	While QU2->(!Eof()) .And. QU2->QU2_FILIAL+QU2->QU2_CHKLST == xFilial("QU2")+cChkLst
		If QU2->QU2_EFETIV == "1"
			cRevChkLst:= QU2->QU2_REVIS
			Exit
		EndIf
		QU2->(DbSkip())
	EndDo
EndIf

Return cRevChkLst

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³QADCkAudit ³ Autor ³ Eduardo de Souza     ³ Data ³ 28/11/02 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Verifica se o usuario logado e auditor nesta auditoria     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ QADCkAudit(ExpC1)                                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpC1 - Auditoria                                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ SIGAQAD                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function QADCkAudit(cAuditoria,lHelp,lSoLider)

Local lAuditor:= .F.
Local nOrdQUB := QUB->(IndexOrd())
Local nPosQUB := QUB->(Recno())
Local nOrdQUC := QUC->(IndexOrd())
Local nPosQUH := QUH->(Recno())
Local nOrdQUH := QUH->(IndexOrd())
Local aUsrMat := QA_USUARIO()
Local cMatFil := aUsrMat[2]
Local cMatCod := aUsrMat[3]

Default cMatFil  := ""
Default cMatCod  := ""
Default lHelp    := .T.
Default lSoLider := .F.

If ! lSoLider
	QUC->(DbSetOrder(4))
	If QUC->(DbSeek(xFilial("QUC")+cMatCod+cAuditoria))
		lAuditor:= .T.
	EndIf
	QUC->(DbSetOrder(nOrdQUC))
Endif

If !lAuditor
	QUB->(DbSetOrder(1))
	If QUB->(DbSeek(xFilial("QUB")+cAuditoria))
		If QUB->QUB_FILMAT == cMatFil .AND. QUB->QUB_AUDLID == cMatCod
			lAuditor:= .T.
		EndIf
	EndIf
	QUB->(DbSetOrder(nOrdQUB))
	QUB->(DbGoto(nPosQUB))
EndIf

If ! lAuditor
	QUH->(DbSetOrder(2))
	If QUH->(DbSeek(xFilial("QUH")+cAuditoria))
		While QUH->(!Eof()) .And. QUH->QUH_FILIAL+QUH->QUH_NUMAUD == xFilial("QUH")+cAuditoria
			If QUH->QUH_FILMAT == cMatFil .AND. QUH->QUH_CODAUD == cMatCod
				lAuditor:= .T.
				Exit
			EndIf
			QUH->(DbSkip())
		EndDo
	EndIf
	QUH->(DbSetOrder(nOrdQUH))
	QUH->(DbGoto(nPosQUH))
EndIf
                           
If !lAuditor .And. lHelp
	//STR0041 "Você não tem permissão para efetuar manutenção nesta Auditoria."
	//STR0042 "Aguarde o encerramento da Auditoria. Ela estará disponível para você apenas como Visualização, após encerrada."
	Help("",1,"QADNAUDFUN",, STR0041, 1, 0, , , , , , {STR0042})
EndIf

Return lAuditor

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³FQADDrive  ³ Autor ³ Telso Carneiro       ³ Data ³21/01/2004³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Programa generico para Selecionar diretorio do Documento   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ FQADDrive(nOpc)                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ Expn1 - Opcao do Cadastro                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Generico                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function FQADDrive(nOpc,cArqAnexo,cNewArq)

Local cFile		:= ""
Local cFileTmp := ""
Local nTrm     := 0
Local aQPath   := QDOPATH()
Local cQPathQAD:= Alltrim(GetMv("MV_QADPDOC"))  
Local cExten   := ""
Local nCont	   := 0
Private cQPathTrm:= aQPath[3]

If !Right( cQPathQAD,1 ) == "\"
	cQPathQAD := cQPathQAD + "\"
Endif
If !Right( cQPathTrm,1 ) == "\"
	cQPathTrm := cQPathTrm + "\"
Endif

IF Empty(cArqAnexo)	
	If nOpc == 2	// Visualizar - Opcao Cadastro
		MsgAlert(OemToAnsi(STR0031),OemToAnsi(STR0032))  //"Nao existe nenhum documento anexo nesta Reunião." # "Atenção"
	Else
		cFile := Trim(cGetFile((OemToAnsi(STR0033))+"|*.DOC|"+;  //"Documentos Anexos(*.Doc/*.Docx)"
		PADR(OemToAnsi(STR0034),27)+"|*.TXT|"+;            //"Arquivos Texto(*.Txt)"
		PADR(OemToAnsi(STR0035),27)+"|*.*|" ,; //"Todos Arquivos(*.*)"
		OemToAnsi( STR0036),0,,.T.,49))//"Selecione Diretorio e Arquivo"
		
		If !Empty(cFile)			
			cQPathQAD 	:= StrTran(cQPathQAD,"SERVIDOR","")
			For nCont:= Len (alltrim(CFILE)) to 1 STEP -1
				If SubSTr (alltrim(CFILE),nCont,1) == "."  
					cExten:= SubSTr (alltrim(CFILE),nCont+1,Len (alltrim(CFILE))) 
					Exit
				EndIf
			Next
//			cNewArq	:= Left(cNewArq, Len(cNewArq) - 3) + Right(cFile, (LEN(CFILE)-At(".",cFile)))		// Uso a extensao selecionada
			cNewArq	:= Left(cNewArq, Len(cNewArq) - 3) + cExten

			If AT(":",cFile) > 0
				__CopyFile(cFile,cQPathTrm + cNewArq)
				If !File(cQPathTrm + cNewArq)
					Help(" ",1,"QADNAOANEX")
					Return
				Endif
			Else
				If !CpyS2T(cFile,cQPathTrm + cNewArq,.T.)
					Help(" ",1,"QADNAOANEX")
					Return
				Endif
				
				cFileTmp := ""
				For nTrm:= Len(cFile) to 1 STEP -1
					If SubStr(cFile,nTrm,1) == "\"
						Exit
					Endif
					cFileTmp := SubStr(cFile,nTrm,1)+cFileTmp
				Next				
			Endif						     
			If !CpyT2S(cQPathTrm + cNewArq,cQPathQAD,.T.)
				If !File(cQPathQAD+AllTrim(cNewArq))
					Help(" ",1,"QADNAOANEX")
					Return    
				Endif
			Endif

			If File(cQPathTrm+cNewArq) .And.  MsgYesNo(OemToAnsi(STR0037),OemToAnsi(STR0032)) //"Deseja Visualizar o Documento Agora?"#	     	
				QA_OPENARQ(cQPathTrm+cNewArq)//Programa para abrir arquivo com qualquer extensao. - QAXFUNA.PRX
			Endif    			
			cArqAnexo:=cNewArq
		Endif
	Endif
Else
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Visualiza Documento Anexo. 			   ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If !File(cQPathTrm+AllTrim(cArqAnexo))
		If !CpyS2T(cQPathQAD+AllTrim(cArqAnexo),cQPathTrm,.T.)
			If !File(cQPathTrm+AllTrim(cArqAnexo))
				Help(" ",1,"QADNAOANEX")
				Return
			Endif
		Endif
	EndIf	
	If File(cQPathTrm+cArqAnexo)
		QA_OPENARQ(cQPathTrm+cArqAnexo)//Programa para abrir arquivo com qualquer extensao. - QAXFUNA.PRX
	Endif    	             	
Endif

Return(cArqAnexo)

/*/{Protheus.doc} QADLOADEXEC
    Chamada das funcoes necessarias para inicializacao e validações do modulo SIGAQAD
	Execução antes das funções do Modulo SIGAQAD                   	
    @type  Function
	@author Jamer N. Pedroso 
	@since 30/06/2023
	@version 1.0
/*/

Function QADLOADEXEC()

QA_TRAVUSR()  //Verificacao de Usuario Ativo

Return(NIL)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³QADLOAD   ºAutor  ³Telso Carneiro	     º Data ³  01/05/04   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Chamada das funcoes necessarias para inicializacao do      º±±
±±º          ³ modulo SIGAQAD                                             º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Inicializacao do Modulo SIGAQAD                            º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Function QADLOAD()
Local lRelease := If( GetRPORelease() < "12.1.2610", .T., .F. )

If lRelease // Proteção para as chamadas das functions em ambiente inferior a release 12.1.2610. 

	//Envia E-mail para os usuarios com Auditorias nao encerradas.³
	If GetMV("MV_QADAVEM") == "1"
		QADAVMAIL()
	Endif            

	If GetMv("MV_QALOGIX") == "1" //Caso haja integracao com o Logix e exista alias QNB - verifica se tem inconsistencias nos WebServices
		If ChkFile("QNB")
			If GetMV("MV_QMLOGIX",.T.,"1") == "1" //Define se mostra a tela de inconsistencia 
			QXMSLOGIX()
			Endif
		Endif	
	Endif	
Endif

Return NIL

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ QADAVMAIL  ³ Autor ³ Rodrigo Gomes       ³ Data ³ 29/08/03 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Envia E-mail para usuarios com pendencias no formato HTML  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ QADAVMAIL()                                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ SIGAQNC                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function QADAVMAIL()

Local dDtVenc    := dDataBase + GetMv("MV_QDVQAD") // Data de Vencimento 
Local dDtFlag    := GetMv("MV_QUDQAD") // Flag contendo o ultimo dia de envio de e-mail  
Local aUsrMat    := QNCUSUARIO()
Local aUsuarios  := {}
Local cMensag    := ""
Local cTVenc     := ""
Local cDesCod    := ""
Local cMsg       := ""
Local nIndQUB    := 0
Local nIndQUA    := 0
Local cKey       := ""
Local cFiltro    := "" 
Local cFilUsr    := Space(FWSizeFilial()) // Filial do usuario
Local cMatUsr    := "" // Matricula do usuario
Local aMail      := {} // Corpo do E-mail
Local nDias      := Getmv("MV_QINTERV",.F.,0) //INTERVALO DE DIAS PARA ENVIAR O EMAIL DE PENDENCIAS DE AUDITORIA
Local aAreaAnt	 := GetArea()
Local aAreaSX6	 := SX6->(GetArea())
Local lQADMSGAD  := ExistBlock( "QADMSGAD" )                                    
Local lQADMSGAG  := ExistBlock( "QADMSGAG" )
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ-¿
//³aMail  ==>  aMail[x][1] --> Codigo            ³
//³            aMail[x][2] --> Data Inicio       ³
//³            aMail[x][3] --> Data Encerramento ³
//³            aMail[x][4] --> Tipo              ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ-Ù

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Verifica se os usuarios receberam E-mail hoje de acordo com o intervalo definido.³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If !Empty(dDtFlag) .And. (CToD(dDtFlag) + nDias) >= dDataBase
	Return( Nil )                                                          	
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Filtra o Arquivo QUB - Auditoria³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
cIndQUB := CriaTrab(NIL,.F.)
dbSelectArea("QUB")
cKey := "QUB_FILMAT+QUB_AUDLID+QUB_NUMAUD"

cFiltro := "Dtos(QUB_ENCAUD) < '" + Dtos(dDataBase) + "' .And. "
cFiltro += "!Empty(Dtos(QUB_ENCAUD)) .And. Empty(Dtos(QUB_ENCREA)) "

IndRegua("QUB",cIndQUB,cKey,,cFiltro,STR0010) //"Selecionando Registro no QUB..."

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Filtra o Arquivo QUA - Agendamento  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
cIndQUA := CriaTrab(NIL,.F.)
dbSelectArea("QUA")
cKey := "QUA_FILMAT+QUA_MAT+Dtos(QUA_ALOC)+QUA_NUMAUD"

cFiltro := "Dtos(QUA_ALOC) <= '" + Dtos(dDtVenc) + "' .And. "
cFiltro += "!Empty(Dtos(QUA_ALOC)) .And. QUA_STATUS == '1' "

IndRegua("QUA",cIndQUA,cKey,,cFiltro,STR0011) //"Selecionando Registro no QUA..."

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ----ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Seleciona o indice temporario QUB e posiciona no primeiro registro³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ----ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
nIndQUB := RetIndex("QUB")
#IFNDEF TOP
	dbSetIndex(cIndQUB+OrdBagExt())
#ENDIF
dbSetOrder(nIndQUB + 1)
dbGoTop() 

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Posiciona no cadastro de usuarios para pegar os dados futuramente³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
dbSelectArea("QAA")
dbSetOrder(1)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Pega todas as Fichas de todos os usuarios.³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
While QUB->(!Eof())
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Limpa o Array com os dados do E-mail.³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	aMail := {}
	
	// Pega o novo usuario
	cFilUsr := QUB->QUB_FILMAT
	cMatUsr := QUB->QUB_AUDLID
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Faz a validacao do usuario para que o usuario receba e-mail devera ³
	//³ser: Ativo, Recebe  E-mail, e o campo EMAIL nao estiver vazio      ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If QAA->(MsSeek(cFilUsr + cMatUsr ))
		If QAA->QAA_RECMAI == "1" .And. QAA->QAA_STATUS == "1"  .And. !Empty(QAA->QAA_EMAIL)
			
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Pega os dados de cada usuario e envia o E-mail com os dados da ficha³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			While QUB->( !Eof() .And. QUB->QUB_FILMAT + QUB->QUB_AUDLID == cFilUsr + cMatUsr )
				AADD(aMail,{QUB->QUB_NUMAUD, QUB->QUB_INIAUD, QUB->QUB_ENCAUD, 1})
				QUB->( dbSkip() )
			EndDo
		EndIf
	EndIf
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Caso esse usuario tenha alguma pendencia Vencida ou a          ³
	//³vencer a rotina envia E-mail no formato que o usuario cadastrou³
	//³contendo as pendencias e seus respectivos vencimentos          ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If Len(aMail) > 0
        
		cMensag  := STR0012 //"Existem lancamentos de auditorias nao encerradas"
	    cTVenc   := STR0013 //"Auditorias"
	    cDesCod  := STR0014 //"Auditoria"
		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Monta o Corpo do E-mail no Formato HTML ou Texto.³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ		
		cMsg := QNCMAILVCT(3,aMail,Val(QAA->QAA_TPMAIL),cMensag,cTVenc,cDesCod) 
		
		cAttach := ""
		aMsg:={{cTVenc + Space(10)+DTOC(Date())+"-"+SubStr(TIME(),1,5) , cMsg, cAttach } }
		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ExecBlock responsavel pela alteracao do Layout do E-mail³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		IF lQADMSGAD
			aMsg := ExecBlock( "QADMSGAD", .f., .f. )
		Endif
		
		AADD(aUsuarios, {QAA->QAA_LOGIN, QAA->QAA_EMAIL, aMsg} )
	Else
		QUB->( dbSkip() )
	EndIf
EndDo

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ----ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Seleciona o indice temporario QUA e posiciona no primeiro registro³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ----ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
nIndQUA := RetIndex("QUA")
#IFNDEF TOP
	dbSetIndex(cIndQUA+OrdBagExt())
#ENDIF
dbSetOrder(nIndQUA + 1)
dbGoTop() 

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ-----------ÄÄÄÄÄÄÄÄÄÄÄ¿
//³Pega todos os Planos de Acao de todos os usuarios.³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ-----------ÄÄÄÄÄÄÄÄÄÄÄÙ
While QUA->(!Eof())
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Limpa o Array com os dados do E-mail.³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	aMail := {}
	
	// Pega o novo usuario
	cFilUsr := QUA->QUA_FILMAT
	cMatUsr := QUA->QUA_MAT

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Faz a validacao do usuario para que o usuario receba e-mail devera ³
	//³ser: Ativo, Recebe  E-mail, e o campo EMAIL nao estiver vazio      ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If QAA->(MsSeek(cFilUsr + cMatUsr ))
		If QAA->QAA_RECMAI == "1" .And. QAA->QAA_STATUS == "1"  .And. !Empty(QAA->QAA_EMAIL)
			
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ------¿
			//³Pega os dados de cada usuario e envia o E-mail com os dados do Agendamento³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ------Ù
			While QUA->( !Eof() .And. QUA->QUA_FILMAT + QUA->QUA_MAT == cFilUsr + cMatUsr )
				AADD(aMail,{QUA->QUA_NUMAUD, Left(FQNCDSX5("QE",QUA->QUA_MOTAUD),50), QUA->QUA_ALOC, 2})
				QUA->( dbSkip() )
			EndDo
		EndIf
	EndIf
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Caso esse usuario tenha alguma pendencia Vencida ou a          ³
	//³vencer a rotina envia E-mail no formato que o usuario cadastrou³
	//³contendo as pendencias e seus respectivos vencimentos          ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If Len(aMail) > 0
		
		cMensag  := STR0015 //"Existem agendamentos de auditorias nao efetivadas/encerradas"
   		cTVenc   := STR0016 //"Agendamentos"
		cDesCod  := STR0014 //"Auditoria"
		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Monta o Corpo do E-mail no Formato HTML ou Texto.³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		cMsg := QNCMAILVCT(3,aMail,Val(QAA->QAA_TPMAIL),cMensag,cTVenc,cDesCod) 

		cAttach := ""
		aMsg:={{cTVenc + Space(10)+DTOC(Date())+"-"+SubStr(TIME(),1,5) , cMsg, cAttach } }
		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ExecBlock responsavel pela alteracao do Layout do E-mail³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		IF lQADMSGAG
			aMsg := ExecBlock( "QADMSGAG", .f., .f. )
		Endif
		
		AADD(aUsuarios, {QAA->QAA_LOGIN, QAA->QAA_EMAIL, aMsg} )
	Else
		QUA->( dbSkip() )
	EndIf
EndDo

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Envia E-mail para cada usuario com as pendencias em vencimento ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If Len(aUsuarios) > 0	
	QaEnvMail(aUsuarios,,,,aUsrMat[5],"1")
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Apaga arquivos tempor rios e os indices	  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
RetIndex("QUB")
If file(cIndQUB+OrdBagExt())
	Ferase(cIndQUB+OrdBagExt())
EndIf

RetIndex("QUA")
If file(cIndQUA+OrdBagExt())
	Ferase(cIndQUA+OrdBagExt())
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Adiciona o Flag no SX6, indicando que ja enviou E-mail hoje³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ---ÄÄÙ
dDtFlag := Iif(Empty(dDtFlag),"01/01/04",dDtFlag)
dbSelectArea("SX6")
SX6->(DbGoTop())
If GetMV("MV_QUDQAD", .T.) .And. CToD(dDtFlag) < dDataBase
	PutMv("MV_QUDQAD",DtoC(dDatabase))	
EndIf

RestArea(aAreaSX6)
RestArea(aAreaAnt)

QUB->(DbClearFilter())

Return( Nil )


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³QADP      ³ Autor ³ Sergio S. Fuzinaka    ³ Data ³ 03.03.08 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³Retorna a Picture do Campo, somente quando NAO for chamada  ³±±
±±³          ³atraves das Consultas Genericas.                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³Generico                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function QADP(cCampo)

Local aArea		:= GetArea()
Local cPict		:= ""

If !Empty(GetSX3Cache(cCampo,"X3_CAMPO"))
	If Alltrim(FunName()) <> "LERDA" .And. Alltrim(FunName()) <> "MPVIEW" .And. Alltrim(FunName()) <> "EDAPP"
		cPict := PesqPict(GetSX3Cache(cCampo,"X3_ARQUIVO"),cCampo)
	Endif
Endif

RestArea( aArea )

Return( cPict )


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³QADVDATAUDºAutor  ³ Cicero Cruz        º Data ³  03/13/08   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Valida os campos Data Inicial / Hora Inicial / Data Fim  e º±±
±±º          ³ Hora Fim nos Cadastros de Auditoria e Agenda Auditoria     º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ QADA100 e QADA150                                          º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function QADVDATAUD (cAliasC, cAliasI, cValid, cCampo, cCont, aCols, aHeader, nLinha)
Local lRet := .T. 
Local nDataHora  := -1
Local nPosDTIn   := 0
Local nPosHRIn   := 0
Local nPosDTFi   := 0
Local nPosHRFi   := 0
Local dIniAud    := Ctod("  /  /  ")
Local dFimAud    := Ctod("  /  /  ")    
Local aDatas	 := {} 
Local nY := 0
Local nX := 0

Local aQHelpPor := {	{"Data Inicio e Data Fim devem estar     ","entre o periodo da Auditoria.          "},; 
						{"Preencha os campos Data Inicio e Data  ","Fim Corretamente.                      "},;
						{"Formato da Hora informada invalido.    ","                                       "},; 
						{"Campos do tipo Hora devem ser preenchi-","dos com valores entre 00:00 e 23:59.   "},;
						{"Campo Data Inicio não Informado.       ","                                       "},; 
						{"Preencha o campo Data Inicio para  con-","tinuar o cadastro.                     "},;
						{"Campo Data Fim não Informado.          ","                                       "},; 
						{"Preencha o campo Data Fim para  conti- ","nuar o cadastro.                       "},;
						{"Data + Hora Inicio devem ser menor que "," Data + Hora Fim.                      "},; 
						{"Preencha o campo Data + Hora Fim com um","valor superior a Data + Hora Inicio.   "},;
						{"Campo Hora Inicio não Informado.       ","                                       "},; 
						{"Preencha o campo Hora Inicio para  con-","tinuar o cadastro.                     "},;
						{"Campo Hora Fim não Informado.          ","                                       "},; 
						{"Preencha o campo Hora Fim para  conti- ","nuar o cadastro.                       "},;
						{"Data + Hora Inicio deve ser menor que  ","o periodo da Alocacao.                 "},; 
						{"Preencha os campos Data Inicio e Data  ","Fim Corretamente.                      "},;
						{"Periodo informado já utilizado nesta   ","auditoria/agenda.                      "},; 
						{"Informe um período que não esteja sendo","utilizado.                             "}}
Local aQHelpEng := {	{"Data Inicio e Data Fim devem estar     ","entre o periodo da Auditoria.          "},; 
						{"Preencha os campos Data Inicio e Data  ","Fim Corretamente.                      "},;
						{"Formato da Hora informada invalido.    ","                                       "},; 
						{"Campos do tipo Hora devem ser preenchi-","dos com valores entre 00:00 e 23:59.   "},;
						{"Campo Data Inicio não Informado.       ","                                       "},; 
						{"Preencha o campo Data Inicio para  con-","tinuar o cadastro.                     "},;
						{"Campo Data Fim não Informado.          ","                                       "},; 
						{"Preencha o campo Data Fim para  conti- ","nuar o cadastro.                       "},;
						{"Data + Hora Inicio devem ser menor que "," Data + Hora Fim.                      "},; 
						{"Preencha o campo Data + Hora Fim com um","valor superior a Data + Hora Inicio.   "},;
						{"Campo Hora Inicio não Informado.       ","                                       "},; 
						{"Preencha o campo Hora Inicio para  con-","tinuar o cadastro.                     "},;
						{"Campo Hora Fim não Informado.          ","                                       "},; 
						{"Preencha o campo Hora Fim para  conti- ","nuar o cadastro.                       "},;
						{"Data + Hora Inicio deve ser menor que  ","o periodo da Alocacao.                 "},; 
						{"Preencha os campos Data Inicio e Data  ","Fim Corretamente.                      "},;
						{"Periodo informado já utilizado nesta   ","auditoria/agenda.                      "},; 
						{"Informe um período que não esteja sendo","utilizado.                             "}}
Local aQHelpSpa := {	{"Data Inicio e Data Fim devem estar     ","entre o periodo da Auditoria.          "},; 
						{"Preencha os campos Data Inicio e Data  ","Fim Corretamente.                      "},;
						{"Formato da Hora informada invalido.    ","                                       "},; 
						{"Campos do tipo Hora devem ser preenchi-","dos com valores entre 00:00 e 23:59.   "},;
						{"Campo Data Inicio não Informado.       ","                                       "},; 
						{"Preencha o campo Data Inicio para  con-","tinuar o cadastro.                     "},;
						{"Campo Data Fim não Informado.          ","                                       "},; 
						{"Preencha o campo Data Fim para  conti- ","nuar o cadastro.                       "},;
						{"Data + Hora Inicio deve ser menor que  "," Data + Hora Fim.                      "},; 
						{"Preencha o campo Data + Hora Fim com um","valor superior a Data + Hora Inicio.   "},;
						{"Campo Hora Inicio não Informado.       ","                                       "},; 
						{"Preencha o campo Hora Inicio para  con-","tinuar o cadastro.                     "},;
						{"Campo Hora Fim não Informado.          ","                                       "},; 
						{"Preencha o campo Hora Fim para  conti- ","nuar o cadastro.                       "},;
						{"Data + Hora Inicio deve ser menor que  ","o periodo da Alocacao.                 "},; 
						{"Preencha os campos Data Inicio e Data  ","Fim Corretamente.                      "},;
						{"Periodo informado já utilizado nesta   ","auditoria/agenda.                      "},; 
						{"Informe um período que não esteja sendo","utilizado.                             "}}

PutHelp("PQ_DTFRPERI",aQHelpPor[1] ,aQHelpEng[1] ,aQHelpSpa[1] ,.T.) //Problema
PutHelp("SQ_DTFRPERI",aQHelpPor[2] ,aQHelpEng[2] ,aQHelpSpa[2] ,.T.) //Solucao
PutHelp("PQ_HORAINVA",aQHelpPor[3] ,aQHelpEng[3] ,aQHelpSpa[3] ,.T.) //Problema
PutHelp("SQ_HORAINVA",aQHelpPor[4] ,aQHelpEng[4] ,aQHelpSpa[4] ,.T.) //Solucao
PutHelp("PQ_DATAINIC",aQHelpPor[5] ,aQHelpEng[5] ,aQHelpSpa[5] ,.T.) //Problema
PutHelp("SQ_DATAINIC",aQHelpPor[6] ,aQHelpEng[6] ,aQHelpSpa[6] ,.T.) //Solucao
PutHelp("PQ_DATAFIM" ,aQHelpPor[7] ,aQHelpEng[7] ,aQHelpSpa[7] ,.T.) //Problema
PutHelp("SQ_DATAFIM" ,aQHelpPor[8] ,aQHelpEng[8] ,aQHelpSpa[8] ,.T.) //Solucao
PutHelp("PQ_DTIMDTF" ,aQHelpPor[9] ,aQHelpEng[9] ,aQHelpSpa[9] ,.T.) //Problema
PutHelp("SQ_DTIMDTF" ,aQHelpPor[10],aQHelpEng[10],aQHelpSpa[10],.T.) //Solucao
PutHelp("PQ_HORAINIC",aQHelpPor[11],aQHelpEng[11],aQHelpSpa[11],.T.) //Problema
PutHelp("SQ_HORAINIC",aQHelpPor[12],aQHelpEng[12],aQHelpSpa[12],.T.) //Solucao
PutHelp("PQ_HORAFIM" ,aQHelpPor[13],aQHelpEng[13],aQHelpSpa[13],.T.) //Problema
PutHelp("SQ_HORAFIM" ,aQHelpPor[14],aQHelpEng[14],aQHelpSpa[14],.T.) //Solucao
PutHelp("PQ_DTFRPERA",aQHelpPor[15],aQHelpEng[15],aQHelpSpa[15],.T.) //Problema
PutHelp("SQ_DTFRPERA",aQHelpPor[16],aQHelpEng[16],aQHelpSpa[16],.T.) //Solucao
PutHelp("PQ_PERJAUTI",aQHelpPor[17],aQHelpEng[17],aQHelpSpa[17],.T.) //Problema
PutHelp("SQ_PERJAUTI",aQHelpPor[18],aQHelpEng[18],aQHelpSpa[18],.T.) //Solucao

// Concentro toda a  validação de  datas nesta função
Default cValid  = 'CAM' // CAM - LIN - ALL
If cAliasC = "QUB"
     Default aHeader = oGetArea:aHeader
     Default aCols   = oGetArea:aCols
     Default nLinha  = oGetArea:oBrowse:nAt
	 nPosDTIn := Ascan(aHeader,{|x| AllTrim(x[2]) == "QUH_DTIN"})
	 nPosHRIn := Ascan(aHeader,{|x| AllTrim(x[2]) == "QUH_HRIN"})
	 nPosDTFi := Ascan(aHeader,{|x| AllTrim(x[2]) == "QUH_DTFI"})
	 nPosHRFi := Ascan(aHeader,{|x| AllTrim(x[2]) == "QUH_HRFI"}) 
     nPosAud := Ascan(aHeader,{|x| AllTrim(x[2]) == "QUH_CODAUD"})
     nPosSeq := Ascan(aHeader,{|x| AllTrim(x[2]) == "QUH_SEQ"})
	 dIniAud := M->QUB_INIAUD
	 dFimAud := M->QUB_ENCAUD
ElseIf cAliasC = "QUA"
     Default aHeader = oGet:aHeader    
     Default aCols   = oGet:aCols
     Default nLinha  = oGet:oBrowse:nAt
	 nPosDTIn   := Ascan(aHeader,{|x| AllTrim(x[2]) == "QUM_DTIN"})
	 nPosHRIn   := Ascan(aHeader,{|x| AllTrim(x[2]) == "QUM_HRIN"})
	 nPosDTFi   := Ascan(aHeader,{|x| AllTrim(x[2]) == "QUM_DTFI"})
	 nPosHRFi   := Ascan(aHeader,{|x| AllTrim(x[2]) == "QUM_HRFI"})	 
     nPosAud	:= Ascan(aHeader,{|x| AllTrim(x[2]) == "QUM_CODAUD"})
     nPosSeq    := Ascan(aHeader,{|x| AllTrim(x[2]) == "QUM_SEQ"})
	 dIniAud    := M->QUA_ALOC
	 dFimAud    := M->QUA_ALOCFI
EndIf

If cValid = 'CAM'

    If cCampo == "DTIN" .AND. Empty(cCont)
    	Help(" ",1,"Q_DATAINIC")// "Campo Data Inicio não informado."
		Return .F.
    ElseIf cCampo == "DTIN" .AND. ( cCont < dIniAud .OR. cCont > dFimAud )
		If cAliasC = "QUB"
			Help(" ",1,"Q_DTFRPERI") // "Data Inicio e Data Fim devem estar entre o periodo da Auditoria"   
		ElseIf cAliasC = "QUA"
			Help(" ",1,"Q_DTFRPERA") // "Data + Hora Inicio deve ser menor que o periodo da Alocacao."   		
		EndIf
		Return .F.
    EndIf
    If cCampo == "DTFI" .AND. Empty( cCont )
	    Help(" ",1,"Q_DATAFIM") // "Campo Data Fim não Informado."
   			Return .F.
    ElseIf cCampo == "DTFI" .AND. ( cCont < dIniAud .OR. cCont > dFimAud  )
		If cAliasC = "QUB"
			Help(" ",1,"Q_DTFRPERI") // "Data Inicio e Data Fim devem estar entre o periodo da Auditoria"   
		ElseIf cAliasC = "QUA"
			Help(" ",1,"Q_DTFRPERA") // "Data + Hora Inicio deve ser menor que o periodo da Alocacao."   		
		EndIf
		Return .F.
    EndIf
    If cCampo == "HRIN" .AND. ( Empty(cCont) .OR. cCont == "  :  " )   
	    Help(" ",1,"Q_HORAINIC") // "Campo Hora Inicio não Informado."
		Return .F.
    ElseIf cCampo == "HRIN" .AND. (Substr(cCont,1,2) > '23' .Or. Substr(cCont,4,2) > '59')
		Help(" ",1,"Q_HORAINVA") //	"Formato da Hora informada invalido.    "
		Return .F.
    EndIf
    If cCampo == "HRFI" .AND. ( Empty(AllTrim(cCont)) .OR. cCont == "  :  " )
	    Help(" ",1,"Q_HORAFIM") // "Campo Hora Fim não Informado."
		Return .F.
    ElseIf cCampo == "HRFI" .AND. (Substr(cCont,1,2) > '23' .Or. Substr(cCont,4,2) > '59')
		Help(" ",1,"Q_HORAINVA") //	"Formato da Hora informada invalido."
		Return .F.
    EndIf

ElseIf cValid = 'LIN'
    
	If !aCols[nLinha][Len(aCols[nLinha])]

	    If Empty(aCols[nLinha][nPosDTIn])
	    	Help(" ",1,"Q_DATAINIC")// "Campo Data Inicio não informado."
			Return .F.
	    ElseIf aCols[nLinha][nPosDTIn] < dIniAud .OR. aCols[nLinha][nPosDTIn] > dFimAud 
			If cAliasC = "QUB"
				Help(" ",1,"Q_DTFRPERI") // "Data Inicio e Data Fim devem estar entre o periodo da Auditoria"   
			ElseIf cAliasC = "QUA"
				Help(" ",1,"Q_DTFRPERA") // "Data Inicio e Data Fim devem estar entre o periodo da Auditoria"   
			EndIf
			Return .F.
	    EndIf
	    If nPosDTFi > 0
		    If Empty(aCols[nLinha][nPosDTFi])
			    Help(" ",1,"Q_DATAFIM") // "Campo Data Fim não Informado."
	   			Return .F.
		    ElseIf aCols[nLinha][nPosDTFi] < dIniAud .OR. aCols[nLinha][nPosDTFi] > dFimAud 
				If cAliasC = "QUB"
					Help(" ",1,"Q_DTFRPERI") // "Data Inicio e Data Fim devem estar entre o periodo da Auditoria"   
				ElseIf cAliasC = "QUA"
					Help(" ",1,"Q_DTFRPERA") // "Data + Hora Inicio deve ser menor que o periodo da Alocacao."   		
				EndIf
				Return .F.
		    EndIf
        Endif
	    If Empty(AllTrim(aCols[nLinha][nPosHRIn])) .OR. aCols[nLinha][nPosHRIn] == "  :  "    
		    Help(" ",1,"Q_HORAINIC") // "Campo Hora Inicio não Informado."
			Return .F.
	    ElseIf Substr(aCols[nLinha][nPosHRIn],1,2) > '23' .OR. Substr(aCols[nLinha][nPosHRIn],4,2) > '59'
			Help(" ",1,"Q_HORAINVA") //	"Formato da Hora informada invalido.    "
			Return .F.
	    EndIf
	    
	    If Empty(AllTrim(aCols[nLinha][nPosHRFi])) .OR. aCols[nLinha][nPosHRFi] == "  :  "
		    Help(" ",1,"Q_HORAFIM") // "Campo Hora Fim não Informado."
			Return .F.
	    ElseIf Substr(aCols[nLinha][nPosHRFi],1,2) > '23' .OR. Substr(aCols[nLinha][nPosHRFi],4,2) > '59'
			Help(" ",1,"Q_HORAINVA") //	"Formato da Hora informada invalido."
			Return .F.
	    EndIf

		nDataHora := SubtHoras( aCols[nLinha][nPosDTIn], aCols[nLinha][nPosHRIn], aCols[nLinha][nPosDTFi], aCols[nLinha][nPosHRFi] )

   		If nDataHora <= 0
			Help(" ",1,"Q_DTIMDTF") //	"Data + Hora Inicio deve ser menor que Data + Hora Fim."
			Return .F.
	    EndIf
        
		If nPosDTFi > 0 
			If !Empty(aCols[nLinha][nPosDTIn]) .AND. !Empty(aCols[nLinha][nPosHRIn]) .AND. !Empty(aCols[nLinha][nPosDTFi]) .AND. !Empty(aCols[nLinha][nPosHRFi])
	   	   		nDataHora := SubtHoras( aCols[nLinha][nPosDTIn], aCols[nLinha][nPosHRIn], aCols[nLinha][nPosDTFi], aCols[nLinha][nPosHRFi] ) 
	   	   		If nDataHora <= 0
					Help(" ",1,"Q_DTIMDTF") //	"Data + Hora Inicio deve ser menor que Data + Hora Fim."
					Return .F.
	   	   		EndIf
	  		EndIf
	
			// Verifico se o periodo esta  sendo utilizado
			For nY := 1 to Len(aCols)
			    If nY <> nLinha .AND. aCols[nLinha][nPosAud] == aCols[nY][nPosAud] // Pulo esta linha
				    If aCols[nLinha][nPosDTIn] == aCols[nY][nPosDTIn] .AND. aCols[nLinha][nPosDTFi] == aCols[nY][nPosDTFi] .AND. aCols[nLinha][nPosDTIn] == aCols[nLinha][nPosDTFi]
						If HoraToInt(aCols[nLinha][nPosHRIn]) >= HoraToInt(aCols[nY][nPosHRIn]) .AND. HoraToInt(aCols[nLinha][nPosHRFi]) <= HoraToInt(aCols[nY][nPosHRFi])
							AAdd(aDatas,{aCols[nY][nPosAud],aCols[nY][nPosSeq],aCols[nY][nPosDTIn],aCols[nY][nPosHRIn],aCols[nY][nPosDTFi],aCols[nY][nPosHRFi],"TIME-",aCols[nLinha][nPosSeq]})                   
						ElseIf HoraToInt(aCols[nLinha][nPosHRIn]) <= HoraToInt(aCols[nY][nPosHRFi]) .AND. HoraToInt(aCols[nLinha][nPosHRFi]) > HoraToInt(aCols[nY][nPosHRFi])
							AAdd(aDatas,{aCols[nY][nPosAud],aCols[nY][nPosSeq],aCols[nY][nPosDTIn],aCols[nY][nPosHRIn],aCols[nY][nPosDTFi],aCols[nY][nPosHRFi],"TIME-",aCols[nLinha][nPosSeq]})                   
						ElseIf HoraToInt(aCols[nLinha][nPosHRIn]) < HoraToInt(aCols[nY][nPosHRIn]) .AND. HoraToInt(aCols[nLinha][nPosHRFi]) >= HoraToInt(aCols[nY][nPosHRIn])
							AAdd(aDatas,{aCols[nY][nPosAud],aCols[nY][nPosSeq],aCols[nY][nPosDTIn],aCols[nY][nPosHRIn],aCols[nY][nPosDTFi],aCols[nY][nPosHRFi],"TIME-",aCols[nLinha][nPosSeq]})    
						EndIf
					// Entre
					ElseIf aCols[nLinha][nPosDTIn] >= aCols[nY][nPosDTIn] .AND. aCols[nLinha][nPosDTFi] <= aCols[nY][nPosDTFi]
						if aCols[nLinha][nPosDTFi] == aCols[nY][nPosDTFi] .AND.;
						   HoraToInt(aCols[nLinha][nPosHRFi]) < HoraToInt(aCols[nY][nPosHRFi])
							AAdd(aDatas,{aCols[nY][nPosAud],aCols[nY][nPosSeq],aCols[nY][nPosDTIn],aCols[nY][nPosHRIn],aCols[nY][nPosDTFi],aCols[nY][nPosHRFi],"BETW-",aCols[nLinha][nPosSeq]})
						EndIf
						if aCols[nLinha][nPosDTIn] == aCols[nY][nPosDTFi] .AND.;
						   HoraToInt(aCols[nLinha][nPosHRIn]) <= HoraToInt(aCols[nY][nPosHRFi])
							AAdd(aDatas,{aCols[nY][nPosAud],aCols[nY][nPosSeq],aCols[nY][nPosDTIn],aCols[nY][nPosHRIn],aCols[nY][nPosDTFi],aCols[nY][nPosHRFi],"BETW-",aCols[nLinha][nPosSeq]})
						EndIf
					// Inicio da  auditoria intersecciona com a  auditoria analizada
					ElseIf aCols[nLinha][nPosDTIn] <= aCols[nY][nPosDTFi] .AND. aCols[nLinha][nPosDTFi] > aCols[nY][nPosDTFi] 
						If aCols[nLinha][nPosDTIn] == aCols[nY][nPosDTFi] .AND.;
						   HoraToInt(aCols[nLinha][nPosHRIn]) < HoraToInt(aCols[nY][nPosHRFi])
			               		AAdd(aDatas,{aCols[nY][nPosAud],aCols[nY][nPosSeq],aCols[nY][nPosDTIn],aCols[nY][nPosHRIn],aCols[nY][nPosDTFi],aCols[nY][nPosHRFi],"INT-I",aCols[nLinha][nPosSeq]})                                                                                                 
						ElseIf aCols[nLinha][nPosDTIn] <> aCols[nY][nPosDTFi]
			               		AAdd(aDatas,{aCols[nY][nPosAud],aCols[nY][nPosSeq],aCols[nY][nPosDTIn],aCols[nY][nPosHRIn],aCols[nY][nPosDTFi],aCols[nY][nPosHRFi],"INT-I",aCols[nLinha][nPosSeq]})                                                                                                 
			 		 		EndIf
					// Fim da auditoria instersecciona com a auditoria analisada
					ElseIf aCols[nLinha][nPosDTIn] < aCols[nY][nPosDTIn] .AND. aCols[nLinha][nPosDTFi] >= aCols[nY][nPosDTIn]
						If aCols[nLinha][nPosDTFi] == aCols[nY][nPosDTIn] 
							if nlinha >= ny .and. HoraToInt(aCols[nY][nPosHRIn]) > HoraToInt(aCols[nLinha][nPosHRFi])				         
								AAdd(aDatas,{aCols[nY][nPosAud],aCols[nY][nPosSeq],aCols[nY][nPosDTIn],aCols[nY][nPosHRIn],aCols[nY][nPosDTFi],aCols[nY][nPosHRFi],"INT-F",aCols[nLinha][nPosSeq]})			
							elseif HoraToInt(aCols[nY][nPosHRIn]) <= HoraToInt(aCols[nLinha][nPosHRFi])				         							
								AAdd(aDatas,{aCols[nY][nPosAud],aCols[nY][nPosSeq],aCols[nY][nPosDTIn],aCols[nY][nPosHRIn],aCols[nY][nPosDTFi],aCols[nY][nPosHRFi],"INT-F",aCols[nLinha][nPosSeq]})			
							EndIf
				 		ElseIf aCols[nLinha][nPosDTFi] <> aCols[nY][nPosDTIn]
			 					AAdd(aDatas,{aCols[nY][nPosAud],aCols[nY][nPosSeq],aCols[nY][nPosDTIn],aCols[nY][nPosHRIn],aCols[nY][nPosDTFi],aCols[nY][nPosHRFi],"INT-F",aCols[nLinha][nPosSeq]})
						EndIf
					EndIf 
				EndIf			
			Next
	    Endif
		If Len(aDatas) > 0
			Help(" ",1,"Q_PERJAUTI") //	"Periodo informado já utilizado nesta auditoria/agenda."
			Return .F.
		EndIf
	       
	EndIf
		
ElseIf cValid = "ALL"

	For nX := 1 to Len(aCols)

		If !aCols[nX][Len(aCols[nX])]
	
		    If Empty(aCols[nX][nPosDTIn])
		    	Help(" ",1,"Q_DATAINIC")// "Campo Data Inicio não informado."
				Return .F.
		    ElseIf aCols[nX][nPosDTIn] < dIniAud .OR. aCols[nX][nPosDTIn] > dFimAud 
				If cAliasC = "QUB"
					Help(" ",1,"Q_DTFRPERI") // "Data Inicio e Data Fim devem estar entre o periodo da Auditoria"   
				ElseIf cAliasC = "QUA"
					Help(" ",1,"Q_DTFRPERA") // "Data + Hora Inicio deve ser menor que o periodo da Alocacao."   		
				EndIf
				Return .F.
		    EndIf
		    
		    If nPosDTFi > 0
			    If Empty(aCols[nX][nPosDTFi])
				    Help(" ",1,"Q_DATAFIM") // "Campo Data Fim não Informado."
		   			Return .F.
			    ElseIf aCols[nX][nPosDTFi] < dIniAud .OR. aCols[nX][nPosDTFi] > dFimAud 
					If cAliasC = "QUB"
						Help(" ",1,"Q_DTFRPERI") // "Data Inicio e Data Fim devem estar entre o periodo da Auditoria"   
					ElseIf cAliasC = "QUA"
						Help(" ",1,"Q_DTFRPERA") // "Data + Hora Inicio deve ser menor que o periodo da Alocacao."   		
					EndIf
					Return .F.
			    EndIf
	        Endif
		    If Empty(AllTrim(aCols[nX][nPosHRIn])) .OR. aCols[nX][nPosHRIn] == "  :  "    
			    Help(" ",1,"Q_HORAINIC") // "Campo Hora Inicio não Informado."
				Return .F.
		    ElseIf Substr(aCols[nX][nPosHRIn],1,2) > '23' .OR. Substr(aCols[nX][nPosHRIn],4,2) > '59'
				Help(" ",1,"Q_HORAINVA") //	"Formato da Hora informada invalido.    "
				Return .F.
		    EndIf
		    
		    If Empty(AllTrim(aCols[nX][nPosHRFi])) .OR. aCols[nX][nPosHRFi] == "  :  "
			    Help(" ",1,"Q_HORAFIM") // "Campo Hora Fim não Informado."
				Return .F.
		    ElseIf Substr(aCols[nX][nPosHRFi],1,2) > '23' .OR. Substr(aCols[nX][nPosHRFi],4,2) > '59'
				Help(" ",1,"Q_HORAINVA") //	"Formato da Hora informada invalido."
				Return .F.
		    EndIf


			nDataHora := SubtHoras( aCols[nLinha][nPosDTIn], aCols[nLinha][nPosHRIn], aCols[nLinha][nPosDTFi], aCols[nLinha][nPosHRFi] )
	
	   		If nDataHora <= 0
				Help(" ",1,"Q_DTIMDTF") //	"Data + Hora Inicio deve ser menor que Data + Hora Fim."
				Return .F.
		    EndIf
	
	
			If nPosDTFi > 0
				If !Empty(aCols[nX][nPosDTIn]) .AND. !Empty(aCols[nX][nPosHRIn]) .AND. !Empty(aCols[nX][nPosDTFi]) .AND. !Empty(aCols[nX][nPosHRFi])
		   	   		nDataHora := SubtHoras( aCols[nX][nPosDTIn], aCols[nX][nPosHRIn], aCols[nX][nPosDTFi], aCols[nX][nPosHRFi] ) 
		   	   		If nDataHora <= 0
						Help(" ",1,"Q_DTIMDTF") //	"Data + Hora Inicio deve ser menor que Data + Hora Fim."
						Return .F.
		   	   		EndIf
		  		EndIf
            Endif
			For nY := nX+1 to Len(aCols) 
		 		If aCols[nX][nPosAud] == aCols[nY][nPosAud]
				    If nPosDTFi > 0
				    If aCols[nX][nPosDTIn] == aCols[nY][nPosDTIn] .AND. aCols[nX][nPosDTFi] == aCols[nY][nPosDTFi] .AND. aCols[nX][nPosDTIn] == aCols[nX][nPosDTFi]
		               
		               If HoraToInt(aCols[nX][nPosHRIn]) >= HoraToInt(aCols[nY][nPosHRIn]) .AND. HoraToInt(aCols[nX][nPosHRFi]) <= HoraToInt(aCols[nY][nPosHRFi])
							AAdd(aDatas,{aCols[nY][nPosAud],aCols[nY][nPosSeq],aCols[nY][nPosDTIn],aCols[nY][nPosHRIn],aCols[nY][nPosDTFi],aCols[nY][nPosHRFi],"TIME-",aCols[nX][nPosSeq]})                   
		               ElseIf HoraToInt(aCols[nX][nPosHRIn]) <= HoraToInt(aCols[nY][nPosHRFi]) .AND. HoraToInt(aCols[nX][nPosHRFi]) > HoraToInt(aCols[nY][nPosHRFi])
							AAdd(aDatas,{aCols[nY][nPosAud],aCols[nY][nPosSeq],aCols[nY][nPosDTIn],aCols[nY][nPosHRIn],aCols[nY][nPosDTFi],aCols[nY][nPosHRFi],"TIME-",aCols[nX][nPosSeq]})                   
					   ElseIf HoraToInt(aCols[nX][nPosHRIn]) < HoraToInt(aCols[nY][nPosHRIn]) .AND. HoraToInt(aCols[nX][nPosHRFi]) >= HoraToInt(aCols[nY][nPosHRIn])
							AAdd(aDatas,{aCols[nY][nPosAud],aCols[nY][nPosSeq],aCols[nY][nPosDTIn],aCols[nY][nPosHRIn],aCols[nY][nPosDTFi],aCols[nY][nPosHRFi],"TIME-",aCols[nX][nPosSeq]})    
		               EndIf
					// Entre
					ElseIf aCols[nX][nPosDTIn] >= aCols[nY][nPosDTIn] .AND. aCols[nX][nPosDTFi] <= aCols[nY][nPosDTFi]
						if aCols[nX][nPosDTFi] == aCols[nY][nPosDTFi] .AND.;
						   HoraToInt(aCols[nX][nPosHRFi]) < HoraToInt(aCols[nY][nPosHRFi])
  						    AAdd(aDatas,{aCols[nY][nPosAud],aCols[nY][nPosSeq],aCols[nY][nPosDTIn],aCols[nY][nPosHRIn],aCols[nY][nPosDTFi],aCols[nY][nPosHRFi],"BETW-",aCols[nX][nPosSeq]})
						EndIf
						if aCols[nX][nPosDTIn] == aCols[nY][nPosDTFi] .AND.;
						   HoraToInt(aCols[nX][nPosHRIn]) <= HoraToInt(aCols[nY][nPosHRFi])
							AAdd(aDatas,{aCols[nY][nPosAud],aCols[nY][nPosSeq],aCols[nY][nPosDTIn],aCols[nY][nPosHRIn],aCols[nY][nPosDTFi],aCols[nY][nPosHRFi],"BETW-",aCols[nX][nPosSeq]})
						EndIf
					// Inicio da  auditoria intersecciona com a  auditoria analizada
					ElseIf aCols[nX][nPosDTIn] <= aCols[nY][nPosDTFi] .AND. aCols[nX][nPosDTFi] > aCols[nY][nPosDTFi] 
						If aCols[nX][nPosDTIn] == aCols[nY][nPosDTFi] .AND.;
						   HoraToInt(aCols[nX][nPosHRIn]) < HoraToInt(aCols[nX][nPosHRFi])
		               		AAdd(aDatas,{aCols[nY][nPosAud],aCols[nY][nPosSeq],aCols[nY][nPosDTIn],aCols[nY][nPosHRIn],aCols[nY][nPosDTFi],aCols[nY][nPosHRFi],"INT-I",aCols[nX][nPosSeq]})                                                                                                 
						ElseIf aCols[nX][nPosDTIn] <> aCols[nY][nPosDTFi]
		               		AAdd(aDatas,{aCols[nY][nPosAud],aCols[nY][nPosSeq],aCols[nY][nPosDTIn],aCols[nY][nPosHRIn],aCols[nY][nPosDTFi],aCols[nY][nPosHRFi],"INT-I",aCols[nX][nPosSeq]})                                                                                                 
		 		 		EndIf
					// Fim da auditoria instersecciona com a auditoria analisada
					ElseIf aCols[nX][nPosDTIn] < aCols[nY][nPosDTIn] .AND. aCols[nX][nPosDTFi] >= aCols[nY][nPosDTIn] 
		            	If aCols[nX][nPosDTFi] == aCols[nY][nPosDTIn] 
							if nX >= ny .and. HoraToInt(aCols[nY][nPosHRIn]) > HoraToInt(aCols[nX][nPosHRFi])				         
								AAdd(aDatas,{aCols[nY][nPosAud],aCols[nY][nPosSeq],aCols[nY][nPosDTIn],aCols[nY][nPosHRIn],aCols[nY][nPosDTFi],aCols[nY][nPosHRFi],"INT-F",aCols[nX][nPosSeq]})			
							ElseIf HoraToInt(aCols[nY][nPosHRIn]) <= HoraToInt(aCols[nX][nPosHRFi])				         								
								AAdd(aDatas,{aCols[nY][nPosAud],aCols[nY][nPosSeq],aCols[nY][nPosDTIn],aCols[nY][nPosHRIn],aCols[nY][nPosDTFi],aCols[nY][nPosHRFi],"INT-F",aCols[nX][nPosSeq]})			
							Endif
		 			    ElseIf aCols[nX][nPosDTFi] <> aCols[nY][nPosDTIn]
		 						AAdd(aDatas,{aCols[nY][nPosAud],aCols[nY][nPosSeq],aCols[nY][nPosDTIn],aCols[nY][nPosHRIn],aCols[nY][nPosDTFi],aCols[nY][nPosHRFi],"INT-F",aCols[nX][nPosSeq]})
		                EndIf
					EndIf 
					Endif			
				EndIf
			Next
		EndIf
	Next

	If Len(aDatas) > 0
		Help(" ",1,"Q_PERJAUTI") //	"Periodo informado já utilizado nesta auditoria/agenda."
		Return .F.
	EndIf
		
EndIf

Return lRet
//----------------------------------------------------------------------
/*/{Protheus.doc} QVldDH() 
Valida os campos Data Inicial / Hora Inicial / Data Fim  e 
Hora Fim no Cadastro de Agenda Auditoria
@author Leonardo Bratti
@since 21/07/2017
@version 1.0
@return .T.
/*/
//----------------------------------------------------------------------
Function QVldDH(cCampo, cCont)
	Local lRet     := .T. 
	Local dIniAud  := Ctod("  /  /  ")
	Local dFimAud  := Ctod("  /  /  ")  
	Local oModel   := FWModelActive()
	Local oModelCB

	
	If oModel:GetId() == "QADA201"
		oModelCB   := oModel:GetModel('QUAMASTER')
		dIniAud    := oModelCB:GetValue('QUA_ALOC')
		dFimAud    := oModelCB:GetValue('QUA_ALOCFI') 
	ElseIf oModel:GetId() == "QADA250"
		oModelCB   := oModel:GetModel('QUBMASTER')
		dIniAud    := oModelCB:GetValue('QUB_INIAUD')
		dFimAud    := oModelCB:GetValue('QUB_ENCAUD')
	EndIf
	
 	Do case
 		case cCampo == "DTIN" .AND. Empty(cCont)    	
    		Help(" ",1,"Q_DATAINIC") // "Campo Data Inicio não informado."
			Return .F.		
  		case  cCampo == "DTIN" .AND. ( cCont < dIniAud .OR. cCont > dFimAud )		
			If oModel:GetId() == "QADA250"
				Help(" ",1,"Q_DTFRPERI")   // "Data Inicio e Data Fim devem estar entre o periodo da Auditoria"
			ElseIf oModel:GetId() == "QADA201"
					Help(" ",1,"Q_DTFRPERA")   // "Data + Hora Inicio deve ser menor que o periodo da Alocacao."		
			EndIf
			Return .F.						
  		case cCampo == "DTFI" .AND. Empty( cCont )
	    	Help(" ",1,"Q_DATAFIM") 
   			Return .F.
   		case  cCampo == "DTFI" .AND. ( cCont < dIniAud .OR. cCont > dFimAud  )
   			If oModel:GetId() == "QADA250"
				Help(" ",1,"Q_DTFRPERI") // "Data Inicio e Data Fim devem estar entre o periodo da Auditoria"   
			ElseIf  oModel:GetId() == "QADA201"
					Help(" ",1,"Q_DTFRPERA") // "Data + Hora Inicio deve ser menor que o periodo da Alocacao."   		
			EndIf
			Return .F.
   		case cCampo == "HRIN" .AND. ( Empty(cCont) .OR. cCont == "  :  " )   
	    	Help(" ",1,"Q_HORAINIC") // "Campo Hora Inicio não Informado."
			Return .F.
 	 	case cCampo == "HRIN" .AND. (Substr(cCont,1,2) > '23' .Or. Substr(cCont,4,2) > '59')
			Help(" ",1,"Q_HORAINVA") //	"Formato da Hora informada invalido.    "
			Return .F.
		case cCampo == "HRFI" .AND. ( Empty(AllTrim(cCont)) .OR. cCont == "  :  " )
	   		Help(" ",1,"Q_HORAFIM") // "Campo Hora Fim não Informado."
			Return .F.
		case cCampo == "HRFI" .AND. (Substr(cCont,1,2) > '23' .Or. Substr(cCont,4,2) > '59')
			Help(" ",1,"Q_HORAINVA") //	"Formato da Hora informada invalido."
			Return .F.
	EndCase
Return lRet

//----------------------------------------------------------------------
/*/{Protheus.doc} QAvisoQad() 
Avisa o cliente sobre as atualizações que serão realizadas no SIGAQAD. 
@author Luiz Henrique Bourscheid
@since 15/03/2018
@version 1.0
@return .T.
/*/
//----------------------------------------------------------------------
Function QAvisoQad()
	Local oFile
	Local cPath
	Local ctexto
	
	Private lChk := .F.
	
	ctexto := "Foram criadas versões em MVC das seguintes telas:" + Chr(13) + Chr(10) +;
		      "   - CHECKLIST - QADA020 => QADA220 " + Chr(13) + Chr(10) +;
			  "   - TOPICO - QADA025 => QADA225" + Chr(13) + Chr(10) +;
			  "   - QUESTIONARIO - QADA030 => QADA230" + Chr(13) + Chr(10) +;
			  "   - AUDITORIA - QADA100 => QADA250" + Chr(13) + Chr(10) +;
			  "   - RESULTADOS - QADA130 => QADA251" + Chr(13) + Chr(10) +;
			  "   - ENCERRAMENTO - QADA140 => QADA280" + Chr(13) + Chr(10) +;
			  "   - AGENDA AUDITORIA - QADA150 => QADA201" + Chr(13) + Chr(10) + Chr(13) + Chr(10) +;
			  "Elas serão subtituídas pela sua versão em MVC na próxima release."
	
	cPath := GetSrvProfString("STARTPATH","")
	cUsr  := RetCodUsr()
	oFile := FWFileIOBase():New(cPath+"Controleqad\\"+cUsr+".qad")
	oFile:CreateDirectory()
	If !oFile:Exists()
		DEFINE MSDIALOG oDlg TITLE "Atualização SIGAQAD" From 109,095 To 400,600 OF oMainWnd PIXEL
		
		@ 10,10 SAY ctexto OF oDlg PIXEL SIZE 200,200
		@ 110,10 CHECKBOX oCheck VAR lChk SIZE 008,008 
		@ 110,20 SAY "Não visualizar mais esta mensagem." OF oDlg PIXEL SIZE 200,200
		@ 132,210 BUTTON "Fechar" SIZE 035 ,010  FONT oDlg:oFont ACTION (oDlg:End()) OF oDlg PIXEL  //'Fechar'
		
		ACTIVATE MSDIALOG oDlg CENTERED
		
		If lChk
			oFile:Create()
		EndIf
	EndIf
Return Nil
