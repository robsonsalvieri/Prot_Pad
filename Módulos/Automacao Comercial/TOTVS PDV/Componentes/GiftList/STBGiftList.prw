#INCLUDE "PROTHEUS.CH"
#INCLUDE "PARMTYPE.CH"  
#INCLUDE "STBGIFTLIST.CH"

#DEFINE POS_MMODO			1				//Modo de abertura
#DEFINE POS_MRET			2       		//Modo de retorno
#DEFINE POS_MTPL			3				//Tipo da lista
#DEFINE POS_MNL			4				//Numero da lista (Filtro ME1)
#DEFINE POS_MONL			5				//Online
#DEFINE POS_MLNOM			6				//Entrar com nomes dos presenteadores
#DEFINE POS_MLENVM		7				//Enviar mensagem
#DEFINE POS_MLITAB		8				//Listar itens em aberto
#DEFINE POS_MORI			9				//Origem da lista (filtro ME1)
#DEFINE POS_MFILT			10				//Filtro (ME2)
#DEFINE POS_MMULT			11				//Multi-selecao
#DEFINE POS_MMTOD			12				//Marcar todos
#DEFINE POS_MQTDU			13				//Quantidade utilizada
#DEFINE POS_MLAQTD		14				//Alterar quantidade
#DEFINE POS_MAME			15				//Alterar modo de entrega
#DEFINE POS_MTPEVE		16				//Tipo de evento (filtro ME1)
#DEFINE POS_MSTAT			17	  			//Status da lista (filtro ME1)



//-------------------------------------------------------------------
/*/{Protheus.doc} STBGLQyCr
Monta a String de Pesquisa, conforme a lista de seleção
@param		 cCampo	 - campo manipulado
@param		 cTipo - tipo do campo
@param		 cCriterio - criterio
@param		 cOpConj - opcao para pesquisa
@param		 cOpDisj - opcao para pesquisa
@param		 lFrmtTC -  opcao para pesquisa
@author  Varejo
@version P11.8
@since   17/12/14
@return  cRet	 - Expressão SQl de Busca
@sample
/*/
//-------------------------------------------------------------------
Function STBGLQyCr( cCampo ,cTipo,cCriterio,cOpConj,;
						cOpDisj,lFrmtTC)

Local aAreaSX2		:= SX2->(GetArea())				// area dos campos
Local cRet			:= ""								// retorno da funcao
Local ni			:= 0								// contador do FOR
Local nx			:= 0								// contador do FOR
Local aLstCri		:= {}								// array da lista
Local nPos			:= 1								// posicao do ascan
Local cCarac		:= ""								// criterios
Local cTMP			:= ""								// temporario
Local nTam			:= 0								// tamanho 
Local cAlias		:= ""								// area de trabalho
Local aLstUNQ		:= {}								//Lista de campos de chave unica da tabela
                                                        	
Default cCampo		:= ""                              // campo manipulado
Default cTipo		:= ""                              // tipo do campo
Default cCriterio	:= ""                              // criterio
Default cOpConj		:= "+"                             // opcao para pesquisa
Default cOpDisj		:= "^"                             // opcao para pesquisa
Default lFrmtTC		:= .F.                            // opcao para pesquisa


STFMessage("STBGLQyCr", "STOP", STR0002) //"Data inválida!

If Empty(cCampo) .OR. Empty(cCriterio)
	Return cRet
Endif
If Empty(cTipo)
	If Empty(cTipo := GetSX3Cache(cCampo,"X3_TIPO"))
		Return cRet
	Endif
Endif
//Tamanho do campo
nTam 	:= GetSX3Cache(cCampo,"X3_TAMANHO")
cAlias 	:= GetSX3Cache(cCampo,"X3_ARQUIVO")
//Levantar campos da chave unica (que permitem que um campo chave pode ser pequisado por intervalo)
If cTipo == "C"
	DbSelectArea("SX2")
	SX2->(DbSetOrder(1))
	If SX2->(DbSeek(cAlias))
		aLstUNQ := StrTokArr(FWX2Unico(cAlias),"+")
	Endif
Endif
//Montar array de criterios : [1]CAMPO [2]VALOR [3]OPERADOR
aAdd(aLstCri,{cCampo,"",""})
For ni := 1 to Len(cCriterio)
	cCarac := Substr(cCriterio,ni,1)
	Do Case 
		Case cCarac == cOpConj
			aTail(aLstCri[nPos]) := "AND"
			aAdd(aLstCri,{cCampo,"",""})
			nPos++
		Case cCarac == cOpDisj
			aTail(aLstCri[nPos]) := "OR"
			aAdd(aLstCri,{cCampo,"",""})
			nPos++
		Otherwise
			Do Case
				Case cTipo == "D"
					If !IsDigit(cCarac) .AND. !cCarac $ "/ "
						STFShowMessage("STBGLQyCr")
						RestArea(aAreaSX2)
						Return cRet
					Endif
					aLstCri[nPos][2] += cCarac
				Otherwise
					aLstCri[nPos][2] += cCarac
			EndCase
	EndCase
Next ni
//Em caso de data, limitar a dois criterios (intervalo)
If cTipo == "D" .AND. Len(aLstCri) > 2
	nx := 0
	For ni := 3 to Len(aLstCri)
		aDel(aLstCri,ni)
		nx++
	Next ni
	aSize(aLstCri,Len(aLstCri) - nx)
Endif
//Caso existam mais de 02 criterios, descaracteriza um intervalo, zerar aLstUNQ
If cTipo == "C" .AND. Len(aLstCri) # 2 .AND. Len(aLstUNQ) > 0
	aLstUNQ := Array(0)
Endif
//Montar a expressao
For ni := 1 to Len(aLstCri)
	//Ajustar o tamanho do criterio de acordo com o tamanho do campo
	If cTipo $ "C|M" 
		If lFrmtTC .AND. !Empty(nTam)
			aLstCri[ni][2] := PadR(Substr(aLstCri[ni][2],1,nTam),nTam)
		Else
			If !Empty(nTam)
				aLstCri[ni][2] := Substr(RTrim(aLstCri[ni][2]),1,nTam)
			Else
				aLstCri[ni][2] := RTrim(aLstCri[ni][2])
			Endif
		Endif
	Endif	
	Do Case
		Case cTipo $ "C|M"
			If !Empty(aLstCri[ni])
				If ni > 1
					If Empty(aTail(aLstCri[ni - 1]))
						aTail(aLstCri[ni - 1]) := "+"
						cTMP += " AND "
					Else
						cTMP += " " + aTail(aLstCri[ni - 1]) + " "
					Endif
				Endif
				If Len(aLstUNQ) == 0 .OR. aScan(aLstUNQ,{|x| Upper(AllTrim(x)) ==  Upper(AllTrim(cCampo))}) == 0
					//Caso nao seja pesquisa de intervalo ou o campo nao faca parte da chave unica para pesquisa de intervalo
					If Len(aLstCri[ni][2]) == nTam
						cTMP += cAlias + "." + cCampo + " = '" + aLstCri[ni][2] + "'"
					Else
						cTMP += cAlias + "." + cCampo + " LIKE '%" + aLstCri[ni][2] + "%'"
					Endif
				Else
					//Caso seja pesquisa de intervalo
					If ni == 1
						If AllTrim(aTail(aLstCri[ni])) == "AND"
							cTMP += cAlias + "." + cCampo + " BETWEEN '" + PadR(aLstCri[ni][2],nTam) + "'"
						Else
							cTMP += cAlias + "." + cCampo + " = '" + PadR(aLstCri[ni][2],nTam) + "'"
						Endif
					Else
						If AllTrim(aTail(aLstCri[ni - 1])) == "AND"
							cTMP += "'" + PadR(aLstCri[ni][2],nTam) + "'"
						Else
							cTMP += cAlias + "." + cCampo + " = '" + PadR(aLstCri[ni][2],nTam) + "'"
						Endif
					Endif					
				Endif
			Endif
		Case cTipo == "D"
			If Empty(CtoD(aLstCri[ni][2]))

				STFShowMessage("STBGLQyCr")
				RestArea(aAreaSX2)
				Return cRet
			Endif
			If !Empty(aLstCri[ni][2])
				If ni > 1
					If Empty(aTail(aLstCri[ni - 1]))
						aTail(aLstCri[ni - 1]) := "+"
						cTMP += " AND "
					Else
						cTMP += " " + aTail(aLstCri[ni - 1]) + " "
					Endif
				Endif
				If Len(aLstCri) == 1
					cTMP += cAlias + "." + cCampo + " = '" + DtoS(CtoD(aLstCri[ni][2])) + "'"
				Else
					If ni == 1
						If AllTrim(aTail(aLstCri[ni])) == "AND"
							cTMP += cAlias + "." + cCampo + " BETWEEN '" + DtoS(CtoD(aLstCri[ni][2])) + "'"
						Else
							cTMP += cAlias + "." + cCampo + " = '" + DtoS(CtoD(aLstCri[ni][2])) + "'"
						Endif
					Else
						If AllTrim(aTail(aLstCri[ni - 1])) == "AND"
							cTMP += "'" + DtoS(CtoD(aLstCri[ni][2])) + "'"
						Else
							cTMP += cAlias + "." + cCampo + " = '" + DtoS(CtoD(aLstCri[ni][2])) + "'"
						Endif
					Endif
				Endif
			Endif		
		Case cTipo == "N"
			If !Empty(aLstCri[ni])
				//Validar conteudo
				lOk := .T.
				For nx := 1 to Len(aLstCri[ni])
					If !Substr(aLstCri[ni],ni,1) $ "0123456789,.+-"
						lOk := .F.
					Endif
				Next nx
				//Se tudo ok, montar expressao
				If lOk
					If ni > 1
						If Empty(aTail(aLstCri[ni - 1]))
							aTail(aLstCri[ni - 1]) := "+"
							cTMP += " AND "
						Else
							cTMP += " " + aTail(aLstCri[ni - 1]) + " "
						Endif
					Endif
					cTMP += cAlias + "." + cCampo + " = " + cValToChar(GetDToVal(aLstCri[ni][2]))
				Endif
			Endif
	EndCase
Next ni
cRet := cTMP
RestArea(aAreaSX2)

Return cRet


//-------------------------------------------------------------------
/*/{Protheus.doc} STBGLVlQtd
Funcao para validar digitacao de quantidade
@param		 oGD	 - Objeto do tipo GRID 
@param		 nQtde -  Quantidade digitada 
@param		 cExtra - Aceita quantidades extras alem do determinado na list
@param		 aHead - Header do Grid
@param		 aDados - Dados do Grid
@param		 lMessage - Exibe mensagen (default .f.)
@author  Varejo
@version P11.8
@since   17/12/14
@return  lRet - Quantidade Válida
@sample
/*/
//-------------------------------------------------------------------
Function STBGLVlQtd(oGD,nQtde,cExtra, aHead, aDados, lMessage)

Local lRet				:= .T.				//retorno da funcao
Local nQtdeDisp		:= 0 //Quantidade Disponivel

Default oGD			:= NIL				//objeto da lista
Default nQtde			:= 0				//quantidade digitada
Default cExtra		:= "2"				//extras na quantidade (não)
Default lMessage		:= .F.

If oGD == Nil .OR. ValType(oGD) # "O" .OR. ValType(nQtde) # "N" .OR. Empty(nQtde) .AND. ValType(cExtra) # "C" .OR. !AllTrim(cExtra) $ "1|2"
	Return !lRet
Endif

If oGD:nAt > 0
	nQtdeDisp := STDGLRtCol(2,"DISPO",1,oGD:nAt,aHead,aDados, .f., .f.)
	//Se a quantidade estiver a maior e a lista nao permitir quantidades extras, rejeitar
	
	If ValType(nQtdeDisp) # "N"
		Return  lRet := !lRet
	EndIf
	
	If (nQtde > 0  .AND. (nQtde > nQtdeDisp .AND. AllTrim(cExtra) # "1"))
		lRet := !lRet
	Endif
	
	
	If !lRet .AND. lMessage
		STFMessage("STBGLVlQtd", "STOP", STR0003) //"Quantidade informada superior à disponível na lista"
		STFShowMessage("STBGLVlQtd")
	Else
		STFCleanInterfaceMessage()
	EndIf
EndIf

Return lRet


//-------------------------------------------------------------------
/*/{Protheus.doc} STBGLConf
Funcao de Confirmação da Inclusão de Item de Lista/Alteração de Quantidade
@param		oGetQtde - Get Quantidade
@param		nGetQtde - Quantidade
@param		oCbxMet - Combo Método de Entrega
@param		cGetMet - Método de Entrega
@param		oGetProd - Get de Produto
@param		cGetProd  - Variavel de Produto
@param		aItRet - Itens de Lista Selecionados
@param		aDados02 - Dados dos Itens de Lista
@param		aHeader02 - Header dos Itens de Lista
@param		oGrpPrd - Grupo do Grid de Listas
@param		aDados03 - Dados de Mensagens
@param		aHeader03 - Array de Mensagens
@param		cNumLst - Numero da Lista
@param		cExtra - Item Extra 1 (Sim)/2 (Não)
@param		aCbxMet - Array de Métodos de Entrega
@param		lGrdMsgAtv - Grid de Mensagens Ativo
@param		aMainCFG - Configurações da Lista de Presentes
@author  Varejo
@version P11.8
@since   17/12/14
@return  Nil
@sample
/*/
//-------------------------------------------------------------------
Function STBGLConf(	oGetQtde,nGetQtde,oCbxMet, cGetMet,;
						oGetProd,  cGetProd  , aItRet,aDados02, ;
						aHeader02, oGrpPrd, aDados03, aHeader03,;
						cNumLst, cExtra, aCbxMet , lGrdMsgAtv, ;
						aMainCFG, lButton, cGetCodBar) 
						
Local nPos 		:= 0
Local cItem := ""
Local nTam := 0
Local cCodMens := ""
Local nX := 0
Local lQtdeVal := .T.
Local aTmp := {}
Local cProd := ""
Local cDesc := ""
Local lIncluiProd := .F.

Default lButton 	:= .T.
Default cGetCodBar 	:= "" 

If ValType(oGrpPrd) == "O"  .AND. ValType(nGetQtde) == "N" .AND. Len(aCbxMet) > 0

	// Verifica opção de inclusão ou alteração de quantidade
	If IIf(FindFunction("STIGlIncProd"),STIGlIncProd(),.F.)
		lIncluiProd := .T.
	EndIf

	STFCleanInterfaceMessage()
	
	//Valida se a lista selecionada no Grid de Lista é a mesma do Grid de Itens
	If Len(aDados02) > 0
		If cNumLst  <> STDGLRtCol(2,"ME2_CODIGO",1,1,aHeader02,aDados02, .f., .f.)
			STFMessage("STBGLConf", "STOP", STR0004) //"Posicionar na Grid de Lista Correspondente"
			STFShowMessage("STBGLConf")
			Return .F.		
		EndIf
	EndIf
	
	
	If  !oGetQtde:lVisible 
		//Inclusão valida se lista permite Extra
		lQtdeVal := AllTrim(cExtra) == "1"		
	Else
		If aMainCfg[POS_MLAQTD] 
			lQtdeVal := STBGLVlQtd(oGrpPrd,nGetQtde,cExtra, aHeader02,aDados02, .T.)
		EndIf		
	EndIf
	
	If lQtdeVal .AND. !oGetQtde:lVisible
		lQtdeVal := !Empty(cGetProd) 
	EndIf
	


	Do While lQtdeVal .and. lGrdMsgAtv .and. (nX := nX + 1) <= Len(aDados03) .AND. Empty(cCodMens)
		If  STDGLRtCol(2,"SEL",1,nX,aHeader03,aDados03, .f., .f.)  == "1"
			cCodMens := STDGLRtCol(2,"MED_CODIGO",1,nX,aHeader03,aDados03, .f., .f.)
		EndIf 
	EndDo

	nX := aScan(aItRet, { |l| l[1] == cNumLst})	
	
	//Inserção de Produto
	If lQtdeVal .AND. lIncluiProd .AND. AllTrim(cExtra) == "1" .AND. oGetProd:lVisible
		
			//Atualiza os Dados do item		
			aTmp :=	STDGLFRt(aHeader02, 0, , aDados02, ;
							cGetProd, "",nGetQtde, cNumLst, ;
							 aCbxMet[1], cCodMens,nGetQtde, ,;
							 aCbxMet)
							 
			aAdd(aDados02, aClone(aTmp[1]))
			nPos := Len(aDados02)
			oGrpPrd:SetArray(aDados02)
			oGrpPrd:GoTo(nPos, .t.)
			cProd := STDGLRtCol(2,"ME2_PRODUT",1,oGrpPrd:nAt,aHeader02,aDados02, .f., .f.)
			nPos := 0
			

	
	ElseIf lQtdeVal .AND. oGrpPrd:nAt > 0 .AND. (oGetQtde:lVisible .OR. oCbxMet:lVisible) .AND. !oGetProd:lVisible
				
					//Atualização de Grid 
					cItem := STDGLRtCol(2,"ME2_ITEM",1,oGrpPrd:nAt,aHeader02,aDados02, .f., .f.) 
					cProd := STDGLRtCol(2,"ME2_PRODUT",1,oGrpPrd:nAt,aHeader02,aDados02, .f., .f.) 
					If nX > 0 .And. lButton
						nPos := aScan(aItRet[nX][05], { |It| It[8] == cNumLst .AND. It[1] == cItem .and. It[2] == cProd})
					Else
						nPos := 0
					EndIf
	
	ElseIf AllTrim(cExtra) == "2"
			STFMessage("STBGLConf2", "STOP",STR0005) //"Lista não permite a inclusão de item Extra"
			STFShowMessage("STBGLConf2")	
			lQtdeVal := .F.
	EndIf

	
	
	If lQtdeVal
		
			If nGetQtde = 0 
				//Quantidade Zerada exclui o item do array de retorno
			
				If nPos > 0
					aDel(aItRet[nX,05], nPos)
					aSize(aItRet[nX,05], Len(aItRet[nX,05])-1)
				EndIf
				cCodMens := ""
			ElseIf oGrpPrd:nAt > 0
				//Atualiza o Item do Array de Retorno		
				If nPos = 0
					If nX = 0
						aAdd(aItRet, Array(5))
						nX := Len(aItRet)
						aItRet[nX, 01] := cNumLst
						aItRet[nX, 02] := cExtra
						aItRet[nX, 03] := "" //Remetente
						aItRet[nX, 04] := ""
						aItRet[nX, 05] := {}
					EndIf
					aAdd(aItRet[nX, 05], Array(9))
					nPos := Len(aItRet[nX, 05])
					aItRet[nX, 05][nPos, 1] :=  cItem
					aItRet[nX, 05][nPos, 2] := cProd  //Prod
					aItRet[nX, 05][nPos, 3] := STDGLRtCol(2,"DISPO",1,oGrpPrd:nAt,aHeader02,aDados02, .f., .f.)   //Dipo			
					aItRet[nX, 05][nPos, 8] := cNumLst
					aItRet[nX, 05][nPos, 6] := ""
				EndIf	
				
				If  aMainCfg[POS_MLAQTD]
	
					aItRet[nX, 05][nPos, 4] := nGetQtde
				Else
					aItRet[nX, 05][nPos, 4] := STDGLRtCol(2,"QTDE",1,oGrpPrd:nAt,aHeader02,aDados02, .f., .f.)
				EndIf
				aItRet[nX, 05][nPos, 7] := cCodMens //Mensagem
				
				If  aMainCfg[POS_MAME]	
					If Len(AllTrim(cGetMet)) > 1 .AND. !IsDigit(Substr(AllTrim(cGetMet),1,1))
						aItRet[nX, 05][nPos, 5] := aCbxMet[aScan(aCbxMet,{|x| Upper(AllTrim(x)) == Upper(AllTrim(cGetMet))})][1]
					Else
						aItRet[nX, 05][nPos, 5] := cGetMet
					Endif
					
					
				Else
					aItRet[nPos, 5] := Substr(STDGLRtCol(2,"ME1_TIPO",1,oGrpPrd:nAt,aHeader02,aDados02, .f., .f.),1,1)
				EndIf
	

			EndIf
			
			//Atualiza o Grid de Itens de Listas
			If aMainCfg[POS_MLAQTD]
				aDados02[oGrpPrd:nAt, STDGLGtCl("QTDE", aHeader02)] := nGetQtde
			EndIf
			aDados02[oGrpPrd:nAt, STDGLGtCl("MED_CODIGO", aHeader02)] := cCodMens
			
			If nGetQtde > 0 .AND. LEN(aCbxMet) > 1
				aDados02[oGrpPrd:nAt, STDGLGtCl("ME1_TIPO", aHeader02)] := aCbxMet[ Max(Val(aItRet[nX, 05][nPos, 5]), 1)]
			Else
				aDados02[oGrpPrd:nAt, STDGLGtCl("ME1_TIPO", aHeader02)] := aCbxMet[1] //Default
			EndIf
			oGrpPrd:GoTo(oGrpPrd:nAt, .t.)

			STFMessage("STBGLConf3", "STOP", STR0006) //"Item de lista atualizado com sucesso."
			STFShowMessage("STBGLConf3")


	EndIf
			
EndIf

Return

