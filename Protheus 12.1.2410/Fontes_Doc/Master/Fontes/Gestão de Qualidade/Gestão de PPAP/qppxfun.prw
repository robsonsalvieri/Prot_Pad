#INCLUDE "QPPXFUN.CH"
#INCLUDE "TOTVS.CH"
#INCLUDE 'FILEIO.CH'
#DEFINE Confirma 1
#DEFINE Redigita 2
#DEFINE Abandona 3 

// Funcoes renomeadas trazidas do QAXFUN, exclusiva para o modulo PPAP
// Robson Ramiro A. Oliveira 27/07/01
                                
/*
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o	 ³QO_TEXTO	³ Autor ³ Vera / Wanderley 	    ³ Data ³ 01.12.97 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Trata textos - VERSAO DOS/WINDOWS						  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe	 ³ QO_TEXTO(ExpC1,ExpC2,ExpN1,ExpC3,ExpC4,ExpA1,ExpN2,ExpC5,; ³±±
±±³			 ³ 			ExpL1,ExpC6)									  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpC1 = Chave do Texto (j  convertida) 					  ³±±
±±³			 ³ ExpC2 = Especie do Texto									  ³±±
±±³			 ³ ExpN1 = Tamanho da linha do texto						  ³±±
±±³			 ³ ExpC3 = Titulo do Texto: somente informativo na tela		  ³±±
±±³			 ³ ExpC4 = Codigo do Titulo: somente informativo na tela 	  ³±±
±±³			 ³ ExpA1 = Array contendo os textos a serem editados		  ³±±
±±³			 ³ ExpN2 = Linha do vetor axTextos							  ³±±
±±³			 ³ ExpC5 = Cabecalho da tela de Texto						  ³±±
±±³			 ³ ExpL1 = Edita ou nÆo o texto. 							  ³±±
±±³			 ³ ExpC6 = Alias do arquivo para gravar o texto 			  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso		 ³ Generico 												  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Obs		 ³ O vetor axTextos deve ser criado no programa chamador, como³±±
±±³			 ³ private, e passado via parametro, como referencia (@).	  ³±±
±±³			 ³ O vetor axTextos deve ser inicializado apos cada funcao de ³±±
±±³			 ³ inclusao,alteracao e exclusao.							  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ ATUALIZACOES SOFRIDAS DESDE A CONSTRUCAO INICIAL.                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ PROGRAMADOR  ³ DATA   ³ BOPS ³  MOTIVO DA ALTERACAO                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Robson Ramir ³02.08.01³------³ Alteracao no size da var Memo para ser ³±±
±±³              ³        ³      ³ calculado com base no nTamLin          ³±±
±±³ Robson Ramir ³06.12.02³------³ Acerto do tamanho do dialogo devido a  ³±±
±±³              ³        ³      ³ troca da fonte                         ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Function QO_TEXTO(cChave,cEspecie,nTamLin,cTit,cCod,axTextos,nLi,cCab,;
	lEdita,cAliasQKO)

Local oFontMet   	:= TFont():New("Courier New",6,0)
Local oFontDialog	:= TFont():New("Arial",6,15,,.T.)
Local oDlg
Local oTexto
Local cAlias		:= iif(cAliasQKO == Nil,"QKO",cAliasQKO)
Local cTexto
Local cDescricao
Local nOpcA 		:= 0
Local nPasso		:= 0
Local nLinTotal		:= 0
Local nPos			:= 0
Local nTamPix		:= Iif(nTamlin == 75, 2.6756, 2.79)

cAliasQKO := iif(cAliasQKO == Nil,"QKO",cAliasQKO)

Private lEdit := Iif(lEdita == NIL, .T., lEdita)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Recupera Texto ja' existente (nLi e' a linha atual da getdados)     ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
cTexto := QO_RecTxt( cChave, cEspecie, nLi, nTamLin, cAliasQKO, axtextos)

DEFINE MSDIALOG oDlg FROM	62,100 TO 320,610 TITLE cCab PIXEL FONT oFontDialog

@ 003, 004 TO 027, 250 LABEL cTit OF oDlg PIXEL
@ 040, 004 TO 110, 250			   OF oDlg PIXEL

@ 013, 010 MSGET cCod WHEN .F. SIZE 185, 010 OF oDlg PIXEL

If lEdit  // Obs. Cada caracter Courier New 06 tem aproximadamente 2.6756 pixels num dialogo assim.
	@ 050, 010 GET oTexto VAR cTexto MEMO NO VSCROLL SIZE (nTamLin*nTamPix), 051 OF oDlg PIXEL
Else
	@ 050, 010 GET oTexto VAR cTexto MEMO READONLY NO VSCROLL SIZE (nTamLin*nTamPix), 051 OF oDlg PIXEL
Endif

oTexto:SetFont(oFontMet)

DEFINE SBUTTON FROM 115,190 TYPE 1 ACTION (nOpca := 1,oDlg:End()) ENABLE OF oDlg
DEFINE SBUTTON FROM 115,220 TYPE 2 ACTION (nOpca := 2,oDlg:End()) ENABLE OF oDlg

ACTIVATE MSDIALOG oDlg CENTERED

If nOpca = Confirma
	// Confirma
	lGrava	  := .T.
	nPos := ascan(axTextos, {|x| x[1] == nLi })
	If nPos == 0
		Aadd(axTextos, { nLi, cTexto } )
	Else
		axTextos[nPos][2] := cTexto
	Endif
EndIf

Return If(nOpca==Confirma,.T.,.F.)


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o	 ³QO_Rectxt ³ Autor ³ Vera / Wanderley 	    ³ Data ³ 02.12.97 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Recupera um texto do arquivo de textos 					  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe	 ³ QO_RecTxt(ExpC1,ExpC2,ExpN1,ExpN2,ExpC3,ExpA1)			  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpC1 = Chave do Texto (ja' convertida)                    ³±±
±±³			 ³ ExpC2 = Especie do Texto									  ³±±
±±³			 ³ ExpN1 = Linha da GetDados que esta posicionada	    	  ³±±
±±³			 ³ ExpN2 = Tamanho da linha do texto						  ³±±
±±³			 ³ ExpC3 = Alias do arquivo para leitura (QKO ou tempor.)	  ³±±
±±³			 ³  Obs.:  Se for arq. temp., deve ter a mesma estrut. do QKO.³±±
±±³			 ³ ExpA1 = Array contendo o texto a ser recuperado 			  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso		 ³ QO_TEXTO 												  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function QO_Rectxt(cChave,cEspecie,nX,nTamLin,cAliasQKO,axTextos,lQuebra)
Local nPos	:= 0
Local cTexto:= ""
Local cAlias:= Iif(cAliasQKO == NIL,"QKO",cAliasQKO)
Local cQuebra:= Chr(13)+Chr(10)
Local nRec   := &(cAlias+"->(Recno())")
Local nOrd   := &(cAlias+"->(IndexOrd(IndexKey()))")

Default nX       := 1
Default nTamLin  := TamSx3("QKO_TEXTO")[1]
Default axTextos := {}
Default lQuebra  := .T.

If Len(axTextos) > 0
	nPos := ascan(axTextos,{ |x| x[1] == nX })
	If nPos <> 0
		cTexto:= axTextos[nPos][2]
	EndIf
EndIf

If nPos == 0
	dbSelectArea( cAlias )
	dbSetOrder(If(cAlias=="QKO",1,IndexOrd()))
	If dbSeek( xFilial(cAlias) + cEspecie + cChave )
		If Alltrim(cAlias) == "QKO" 
			While !Eof() .and. QKO->QKO_FILIAL+QKO->QKO_ESPEC+QKO->QKO_CHAVE == xFilial(cAlias)+cEspecie+cChave
				If At("\13\10",QKO->QKO_TEXTO) > 0
					cTexto+= SubStr(QKO->QKO_TEXTO,1,At("\13\10",QKO->QKO_TEXTO) - 1) + If(lQuebra,cQuebra,Space(1))
				Else
					// Para tratamento de postgress x linux
					If At("",QKO->QKO_TEXTO) > 0
						cTexto+= SubStr(QKO->QKO_TEXTO,1,At("",QKO->QKO_TEXTO) - 1) + cQuebra	
					Else
						cTexto+= RTrim(QKO->QKO_TEXTO)
					Endif	
				EndIf            
				QKO->(DbSkip())
			Enddo
		Endif
	EndIf
EndIf

&(cAlias+"->(dbGoTo("+Alltrim(Str(nRec))+"))")
&(cAlias+"->(dbSetOrder("+Alltrim(Str(nOrd))+"))")

Return(cTexto)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o	 ³QO_GrvTxt ³ Autor ³ Vera / Wanderley 	    ³ Data ³ 02.12.97 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Grava o texto editado com QO_TEXTO, a partir do axTextos   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe	 ³ QO_GrvTxt(ExpC1,ExpC2,ExpN1,ExpA1,ExpC3)				      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpC1 = Chave do Texto (j  convertida) 					  ³±±
±±³			 ³ ExpC2 = Especie do Texto									  ³±±
±±³			 ³ ExpN1 = Linha da Getdados que esta posicionado			  ³±±
±±³			 ³ ExpA1 = Vetor axTextos, que contem os textos digitados	  ³±±
±±³			 ³ ExpC3 = Alias do arquivo para gravacao (QKO ou tempor.)	  ³±±
±±³			 ³  Obs.:  Se for arq. temp., deve ter a mesma estrut. do QKO.³±±
±±³			 ³ ExpN2 = Tamanho da linha na tela - Default 75 Carct.		  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso		 ³ Generico 												  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function QO_GrvTxt(cChave,cEspecie,nX,axTextos,cAliasQKO,nTamLin)

Local cOldAlias	:= Select()
Local cTexto		:= ""
Local nI 			:= 0
Local nLinhas		:= {}
Local nPos			:= 0
Local nChr			:= 0
Local cAlias

Local cCampo 		:= "" // Auxiliar na grava‡Æo, para gerar macro do campo

Default nTamLin		:= 75
Default cAlias 		:= "QKO"
Default axTextos	:= {}
Default cAliasQKO	:= "QKO"

If len(axTextos) > 0

	cTexto    := axTextos[1,2]
	nTamLin   := If(nTamLin >= Len(QKO->QKO_TEXTO),nTamLin-6,nTamLin)

	While !Empty(cTexto)
		cLine := Subs(cTexto,1,nTamLin)
		nTexto:= At(Chr(13),cLine)
		If nTexto > 0
			cLine := Subs(cLine,1,nTexto-1)+"\13\10"
			nTexto+= 2
		Else
			If !Empty(cLine)
				nTexto := nTamLin+1
			    nLen1 := Len(cLine)
				nLen2 := Len(Trim(cLine))
				
				//verifica se tem espaco no final da linha para colocar no inicio do proximo registro
				If nLen1 <> nLen2
					cLine := Trim(cLine)
					nTexto -= (nLen1 - nLen2)
				EndIf
			Else
				If Len(cTexto) > nTamLin
					nTexto := nTamLin+1
				Endif
			EndIf
		EndIf
		cTexto := Subs(cTexto,nTexto)
		aadd(nLinhas,cLine)
	EndDo
	
	dbSelectArea(cAliasQKO)
	dbSetOrder(1)
	dbseek(xFilial(cAliasQKO) + cEspecie + cChave)
	For nI := 1 to len(nLinhas)
		If Alltrim(cAliasQKO) == "QKO" 
			If !Eof() .and. QKO_FILIAL+QKO_ESPEC+QKO_CHAVE == xFilial(cAliasQKO)+cEspecie+cChave
				RecLock(cAliasQKO, .f.) // Lock
			Else
				RecLock(cAliasQKO, .t.) // Append
				cCampo  := cAliasQKO+"->"+cAliasQKO+"_FILIAL"
				&cCampo := xFilial(cAliasQKO)
				cCampo  := cAliasQKO+"->"+cAliasQKO+"_CHAVE"
				&cCampo := cChave
				cCampo  := cAliasQKO+"->"+cAliasQKO+"_ESPEC"
				&cCampo := cEspecie
			EndIf
			cCampo  := cAliasQKO+"->QKO_SEQ"
			&cCampo := StrZero(nI,3)
			cCampo  := cAliasQKO+"->"+cAliasQKO+"_TEXTO" 
			&cCampo := nLinhas[nI]
			MsUnlock()
		Endif
		dbSkip()
	Next nI

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Deleta as linhas anteriores se texto digitado for menor 	³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If Alltrim(cAliasQKO) == "QKO" 	
		While QKO->(!Eof()) .And. QKO_FILIAL+QKO_ESPEC+QKO_CHAVE == xFilial('QKO')+cEspecie+cChave
			RecLock(cAliasQKO)
			dbDelete()
			MsUnlock()
			QKO->(dbSkip())
		Enddo
	Endif
Else
	cTexto    := "\13\10"
	dbSelectArea(cAliasQKO)
	dbseek(xFilial(cAliasQKO) + cEspecie + cChave)
	If Alltrim(cAliasQKO) == "QKO" 
		If !Eof() .and. QKO_FILIAL+QKO_ESPEC+QKO_CHAVE == xFilial(cAliasQKO)+cEspecie+cChave
			RecLock(cAliasQKO, .f.) // Lock
		Else
			RecLock(cAliasQKO, .t.) // Append
			cCampo  := cAliasQKO+"->"+cAliasQKO+"_FILIAL"
			&cCampo := xFilial(cAliasQKO)
			cCampo  := cAliasQKO+"->"+cAliasQKO+"_CHAVE"
			&cCampo := cChave
			cCampo  := cAliasQKO+"->"+cAliasQKO+"_ESPEC"
			&cCampo := cEspecie
		EndIf
		cCampo  := cAliasQKO+"->QKO_SEQ"
		&cCampo := "001"
		cCampo  := cAliasQKO+"->"+cAliasQKO+"_TEXTO" 
		&cCampo := cTexto
		MsUnlock()
	Endif
EndIf

dbSelectArea(cOldAlias)

Return NIl


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o	 ³QO_DelTxt ³ Autor ³ Vera / Wanderley 	    ³ Data ³ 04.12.97 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Deleta o texto editado com QO_TEXTO, a partir do axTextos. ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe	 ³ QO_DelTxt(ExpC1,ExpC2,ExpN1,ExpC3)						  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpC1 = Chave do Texto (j  convertida) 					  ³±±
±±³			 ³ ExpC2 = Especie do Texto									  ³±±
±±³			 ³ ExpC3 = Alias do arquivo para leitura (QKO ou tempor.)	  ³±±
±±³			 ³  Obs.:  Se for arq. temp., deve ter a mesma estrut. do QKO.³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso		 ³ Generico 												  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function QO_DelTxt(cChave,cEspecie,cAliasQKO)

Local cOldAlias := Select()
Local cAlias

cAlias := Iif(cAliasQKO == NIL,"QKO",cAliasQKO)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Deleta o texto no QKO ou arq. temporario 				    ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
dbSelectArea(cAlias)
dbseek(xFilial(cAlias) + cEspecie + cChave)
While !Eof() .and. QKO_FILIAL+QKO_ESPEC+QKO_CHAVE == xFilial(cAlias)+cEspecie+cChave
	RecLock(cAlias, .f.) 
	dbDelete()        
	MsUnlock()
	dbSkip()
Enddo
FKCOMMIT()

dbSelectArea(cOldAlias)
Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao	 ³QPP_CRONO ³ Autor ³ Robson Ramiro A Olivei³ Data ³ 06.09.01 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Atualiza Cronograma                                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe	 ³ QPP_CRONO(ExpC1,ExpC2,ExpC3)			        			  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpC1 = Peca                           					  ³±±
±±³			 ³ ExpC2 = Revisao          								  ³±±
±±³			 ³ ExpC3 = ID da Atividade				                	  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso		 ³ SIGAPPAP 												  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

Function QPP_CRONO(cPeca,cRev,cID)

Local aArea 	:= {}
Local aUsrMat	:= {}

aArea 	:= GetArea()
aUsrMat	:= QA_USUARIO()

DbSelectArea("QKZ")
DbSetOrder(3)
If DbSeek(xFilial("QKZ") + cID)

	DbSelectArea("QKP")
	DbSetOrder(3)

	If DbSeek(xFilial("QKP")+ cPeca + cRev + QKZ->QKZ_COD)
		RecLock("QKP",.F.)

		If Empty(QKP->QKP_MAT)
			QKP->QKP_FILMAT	:= aUsrMat[2]
			QKP->QKP_MAT 	:= aUsrMat[3]
		Endif
	
		If Empty(QKP->QKP_DTINI)
			QKP->QKP_DTINI := dDataBase
		Endif

		If Empty(QKP->QKP_DTPRA)  
			QKP->QKP_DTPRA := dDataBase
		Endif

		QKP->QKP_DTFIM  := dDataBase
		QKP->QKP_PCOMP  := "4"
		QKP->QKP_LEGEND := "BR_CINZA"

		MsUnlock()
	Endif
Endif

DbSelectArea("QKP")
DbSetOrder(1)
 
RestArea(aArea)

Return


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao	 ³QPPVldAlt ³ Autor ³ Robson Ramiro A Olivei³ Data ³ 22.10.02 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Verifica se o processo pode ser alterado                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe	 ³ QPPVldAlt(ExpC1,ExpC2) 			        			      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpC1 = Peca                           					  ³±±
±±³			 ³ ExpC2 = Revisao          								  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso		 ³ SIGAPPAP 												  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

Function QPPVldAlt(cPeca,cRev,cAprov)

Local aArea 	:= {}
Local lReturn	:= .T.
Local cRotina	:= Funname()

aArea 	:= GetArea()

DbSelectArea("QK1")
DbSetOrder(1)
DbSeek(xFilial("QK1")+ cPeca + cRev)

If QK1->QK1_STATUS <> "1"
	Alert(STR0001) //"O processo deve estar em aberto para ser alterado !"
	lReturn := .F.
Endif
If cRotina $ "QPPA120/QPPA130/QPPA131/QPPA150/QPPA160/QPPA170/QPPA180/QPPA190/QPPA200/QPPA210/QPPA340/QPPA350/QPPA360"
   	If !Empty(cAprov)
		If ALLTRIM(UPPER(cAprov)) <> ALLTRIM(UPPER(cUserName))
			DbSelectArea("QAA")
			DbSetOrder(6)
			If DbSeek(UPPER(cAprov))
				If QA_SitFolh()
					messagedlg(STR0002) //"O usuário logado não é o aprovador/responsável, para alteração deverá estar logado com o usuário aprovador"
					lReturn:= .F. 
				Else
					DbSelectArea("QAA")
					DbSetOrder(6)
					If DbSeek(UPPER(cUserName)) 
						messagedlg(STR0003) //"O usuário logado não é o aprovador, mas o usuário aprovador está inativo,será permitida a alteração por outro usuário"
					
						lReturn:= .T.
					Else
						messagedlg(STR0004)//"O usuário logado não está cadastrado no cadastro de usuários do módulo, portanto não poderá ser o aprovador")
					    lReturn:= .F.
					Endif
				Endif
			Endif
		Endif		    
	Endif 	
Endif

RestArea(aArea)

Return lReturn

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao	 ³QPPTAMGET ³ Autor ³ Robson Ramiro A Olivei³ Data ³ 09.05.03 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Retorna o tamanho limite da GetDados                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe	 ³ QPPTAMGET(ExpC1, ExpN1)                        			  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpC1 = Campo a ser avaliado           					  ³±±
±±³          ³ ExpN1 = Tipo do retorno                					  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso		 ³ SIGAPPAP 												  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

Function QPPTAMGET(cCampo,nTipo)

Local nTam := 0
Local cTam := ""
Local nReturn

nTam := TamSx3(cCampo)[1]

cTam := Replicate('9',nTam)

If nTipo == 1
	nReturn := Val(cTam)
Elseif nTipo == 2
	nReturn := nTam
Endif

Return nReturn

/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ PPAPVld      ³ Autor ³ Robson Ramiro A. Olive³ Data ³ 26.08.03 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Validacao da digitacao, devido ao FreeForUse()                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ PPAPVld()                                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpC1 = Alias para validacao ExistChav                         ³±±
±±³          ³ ExpC2 = Chave de pesquisa                                      ³±±
±±³          ³ ExpN1 = Ordem                                                  ³±±
±±³          ³ ExpC3 = Alias para validacao ExistCpo                          ³±±
±±³          ³ ExpN2 = Ordem                                                  ³±±
±±³          ³ ExpN3 = Tipo de verificacao                                    ³±±
±±³          ³ ExpN4 = Numero de caracteres finais a excluir                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ PPAP                                                           ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
/*/

Function PPAPVld(cAlias, cChave, nOrd, cAlias2, nOrd2, nTipo, nSizeCut)
Local lRetorno := .F.
Local cChaveX

Default cAlias2	 := "QK1"
Default nOrd	 := 1
Default nOrd2	 := 1
Default nTipo 	 := 1
Default nSizeCut := 3

If nTipo == 1
	cChaveX := cChave
Elseif nTipo == 2
	cChaveX := Subst(cChave,1,Len(cChave)-nSizeCut)
Endif

If ExistChav(cAlias,cChave,nOrd) .and. ExistCpo(cAlias2,cChaveX,nOrd2) .and. !Empty(cChave);
	.and. FreeForUse(cAlias, cChave)
	lRetorno := .T.
Endif

Return lRetorno


/*/{Protheus.doc} PPALOADEXEC
    Chamada das funcoes necessarias para inicializacao e validações do modulo SIGAPPA
	Execução antes das funções do Modulo SIGAPPA                   	
    @type  Function
	@author Jamer N. Pedroso 
	@since 30/06/2023
	@version 1.0
/*/

Function PPALOADEXEC()

QA_TRAVUSR()  //Verificacao de Usuario Ativo

Return(NIL)


/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ PPALOAD      ³ Autor ³ Robson Ramiro A. Olive³ Data ³ 06.01.04 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Funcao criada para substituir o X2_ROTINA()                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ PPALoad()                                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ Void                                                           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ PPAP                                                           ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
/*/

Function PPALOAD()

QPP110Email()	// Dispara email
QPPC010(.T.)	// Checa pendencias

If GetMv("MV_QALOGIX") == "1" //Caso haja integracao com o Logix e exista alias QNB - verifica se tem inconsistencias nos WebServices
	If ChkFile("QNB")
		If GetMV("MV_QMLOGIX",.T.,"1") == "1" //Define se mostra a tela de inconsistencia 
		QXMSLOGIX()
		Endif
	Endif	
Endif	

Return Nil    

/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ PPALOAD      ³ Autor ³ Robson Ramiro A. Olive³ Data ³ 06.01.04 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Funcao criada para substituir o X2_ROTINA()                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ PPALoad()                                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ Void                                                           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ PPAP                                                           ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
/*/

Function PPAPLOAD()

/*
VISANDO MANTER  COMPATIBILIDADE COM OS OUTROS RELEASES DESTA VERSAO FOI DETERMINADO QUE A FUNCAO
PPAPLOAD CHAMARA A PPALOAD DESTA  FORMA CASO ESTA FUNCAO PRECISE DE ATUALIZACOES ESTAS NAO IRAO
PREJUDICAR O FUNCIONAMENTO DO MODULO EM OUTROS RELEASES.
ATENTAR PARA O FATO QUE AS ALTERACOES  DEVEM SER  FEITAS NA  FUNCAO ACIMA
*/
PPALOAD()

Return Nil

/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ PPAPBMP      ³ Autor ³ Robson Ramiro A. Olive³ Data ³ 30.03.04 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Retira o BMP do RPO e salva em local especifico e retorn T ou F³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ PPAPBMP()                                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpC1 = Nome do BMP no RPO                                     ³±±
±±³          ³ ExpC2 = Path para salvar o arquivo                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Quality                                                        ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
/*/

Function PPAPBMP(cNome, cPath)

Local lReturn := .F.

cNome := Upper(cNome)

If !File(cPath+cNome,0) // 0 Default, 1 Server, 2 Remote
	lReturn := Resource2File(cNome, cPath+cNome)
Endif

Return lReturn


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³QPPXFUN   ºAutor  ³Renata Cavalcante   º Data ³  05/25/07   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³  Validação da exclusão                                     º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Valida se a operação pode ser executada                    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function QPPVldExc(cRev,cAprov)

Local aArea 	:= {}
Local lReturn	:= .T.
Local cRotina	:= Funname()

aArea 	:= GetArea()

If cRotina $ "QPPA120/QPPA130/QPPA150/QPPA160/QPPA170/QPPA180/QPPA190/QPPA200/QPPA210/QPPA340/QPPA350/QPPA360"
   	If !Empty(cAprov)
		If ALLTRIM(UPPER(cAprov)) <> ALLTRIM(UPPER(cUserName))
			DbSelectArea("QAA")
			DbSetOrder(6)
			If DbSeek(UPPER(cAprov))
				If QA_SitFolh()
					messagedlg(STR0005) //"O usuário logado não é o aprovador/responsável, para exclusão deverá estar logado com o usuário aprovador"
					lReturn:= .F. 
				Else
					DbSelectArea("QAA")
					DbSetOrder(6)
					If DbSeek(UPPER(cUserName)) 
						messagedlg(STR0006) //"O usuário logado não é o aprovador, mas o usuário aprovador está inativo,será permitida a exclusão por outro usuário"
					
						lReturn:= .T.
					Else
						messagedlg(STR0007)//"O usuário logado não está cadastrado no cadastro de usuários do módulo, portanto não poderá ser o aprovador")
					    lReturn:= .F.
					Endif
				Endif
			Endif
		Endif		    
	Endif 	
Endif

RestArea(aArea)

Return lReturn
