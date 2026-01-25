#include 'protheus.ch'
#include 'parmtype.ch'

//---------------------------------------------------------------------------------------------------
/*/ {Protheus.doc} GFEXFB_A
//TODO Função principal para fonte ser listado nos fontes do TDS
@author André Luis W
@since 10/06/15
@version 1.0
/*///------------------------------------------------------------------------------------------------
function GFEXFBA()
	/* **********************************
		AS VARIAVEIS UTILIZADAS NESTE FONTE DEVE SER 
		DECLARADAS COMO PRIVATE NO FONTE CHAMADOR
	   ********************************** */
return

//---------------------------------------------------------------------------------------------------
/*/{Protheus.doc} GFEXFB_2TOP
//TODO Vai para o primeiro registro da tabela e do array

@param  lTabTmp		Indica se é tabela temporária ou array 
@param  cTabTmp 	Nome da tabela temporia que será manipulada
@param  aTabTmp		Array que deve ser manipulado
@param  nArray		Código do array que será manipulado

@author André Luis W
@since 10/06/15
@version 1.0
/*///------------------------------------------------------------------------------------------------
function GFEXFB_2TOP(lTabTmp, cTabTmp, aTabTmp, nArray)
	
	IF nArray == 0
		idpGRU := 1
	ELSEIF nArray == 1
		idpDOC := 1
	ELSEIF nArray == 2
		idpSTF := 1
	ELSEIF nArray == 3
		idpSIM := 1
	ELSEIF nArray == 4
		idpGRB := 1
	ELSEIF nArray == 5
		idpTCF := 1
	ELSEIF nArray == 6
		idpUNC := 1
	ELSEIF nArray == 7
		idpTRE := 1
	ELSEIF nArray == 8
		idpITE := 1
	ELSEIF nArray == 9
		idpCCF := 1
	ELSEIF nArray == 10
		idpPED := 1
	ELSEIF nArray == 11
		idpSEL := 1
	ELSEIF nArray == 12
		idpENT := 1
	ELSEIF nArray == 13
		idpROT := 1
	ENDIF 
Return

//---------------------------------------------------------------------------------------------------
/*/{Protheus.doc} GFEXFB_3EOF
//TODO Verificar se não é final do arquivo ou do array

@param  lTabTmp		Indica se é tabela temporária ou array 
@param  cTabTmp 	Nome da tabela temporia que será manipulada
@param  aTabTmp		Array que deve ser manipulado
@param  nArray		Código do array que será manipulado

@author André Luis W
@since 10/06/15
@version 1.0
/*///------------------------------------------------------------------------------------------------
function GFEXFB_3EOF(lTabTmp, cTabTmp, aTabTmp, nArray)
Return GFEXFB_4IDX(nArray,.F.) > Len(aTabTmp) 

//---------------------------------------------------------------------------------------------------
/*/{Protheus.doc} GFEXFB_4IDX
//TODO Retorna a posição do Index do array

@param  nArray		Código do array que será manipulado
@param  lInc		Informa se deve incrementar ou não antes de retornar.

@author André Luis W
@since 10/06/15
@version 1.0
/*///------------------------------------------------------------------------------------------------
Function GFEXFB_4IDX(nArray, lInc, nInc)
	Default nInc := 1
	IF nArray == 0
		IIF(lInc, idpGRU += nInc ,idpGRU)
		Return idpGRU
	ELSEIF nArray == 1
		IIF(lInc, idpDOC += nInc ,idpDOC)
		Return idpDOC
	ELSEIF nArray == 2
		IIF(lInc, idpSTF += nInc ,idpSTF)
		Return idpSTF
	ELSEIF nArray == 3
		IIF(lInc, idpSIM += nInc ,idpSIM)
		Return idpSIM
	ELSEIF nArray == 4
		IIF(lInc, idpGRB += nInc ,idpGRB)
		Return idpGRB
	ELSEIF nArray == 5
		IIF(lInc, idpTCF += nInc ,idpTCF)
		Return idpTCF
	ELSEIF nArray == 6
		IIF(lInc, idpUNC += nInc ,idpUNC)
		Return idpUNC
	ELSEIF nArray == 7
		IIF(lInc, idpTRE += nInc ,idpTRE)
		Return idpTRE
	ELSEIF nArray == 8
		IIF(lInc, idpITE += nInc ,idpITE)
		Return idpITE
	ELSEIF nArray == 9
		IIF(lInc, idpCCF += nInc ,idpCCF)
		Return idpCCF
	ELSEIF nArray == 10
		IIF(lInc, idpPED += nInc ,idpPED)
		Return idpPED
	ELSEIF nArray == 11
		IIF(lInc, idpSEL += nInc ,idpSEL)
		Return idpSEL
	ELSEIF nArray == 12
		IIF(lInc, idpENT += nInc ,idpENT)
		Return idpENT
	ELSEIF nArray == 13
		IIF(lInc, idpROT += nInc ,idpROT)
		Return idpROT
	ENDIF 
Return

//---------------------------------------------------------------------------------------------------
/*/{Protheus.doc} GFEXFB_5CMP
//TODO Retorna o conteudo de um campo

@param  lTabTmp		Indica se é tabela temporária ou array 
@param  cTabTmp 	Nome da tabela temporia que será manipulada
@param  aTabTmp		Array que deve ser manipulado
@param  nArray		Código do array que será manipulado
@param  cCampo		Descrição 

@author André Luis W
@since 10/06/15
@version 1.0
/*///------------------------------------------------------------------------------------------------
function GFEXFB_5CMP(lTabTmp, cTabTmp, aTabTmp, nArray, cCampo, cValor)
	Local nX := GFEXFB_4IDX(nArray,.F.)
	if cValor == Nil
		if nX <= 0 .OR. nX > Len(aTabTmp)
			Return ''
		Else				
			Return aTabTmp[nX,GFEXFB_7CMPARRAY(nArray,cCampo)]
		EndIf
	Else
		aTabTmp[nX,GFEXFB_7CMPARRAY(nArray,cCampo)] := cValor
	EndIf
Return

//---------------------------------------------------------------------------------------------------
/*/{Protheus.doc} GFEXFB_7CMPARRAY
//TODO Retorna qual campo do array é para retornar a informação

@param  cCampo		Campo a ser procurado no array 

@author André Luis W
@since 10/06/15
@version 1.0
/*///------------------------------------------------------------------------------------------------
function GFEXFB_7CMPARRAY(nArray, cCampo)
	cCampo := UPPER(cCampo)
	IF nArray == 0
		Return ASCAN(_aCmpGRU,{|X| X == cCampo})
	ELSEIF nArray == 1
		Return ASCAN(_aCmpDOC,{|X| X == cCampo})
	ELSEIF nArray == 2
		Return ASCAN(_aCmpSTF,{|X| X == cCampo})
	ELSEIF nArray == 3
		Return ASCAN(_aCmpSIM,{|X| X == cCampo})
	ELSEIF nArray == 4
		Return ASCAN(_aCmpGRB,{|X| X == cCampo})
	ELSEIF nArray == 5
		Return ASCAN(_aCmpTCF,{|X| X == cCampo})
	ELSEIF nArray == 6
		Return ASCAN(_aCmpUNC,{|X| X == cCampo})
	ELSEIF nArray == 7
		Return ASCAN(_aCmpTRE,{|X| X == cCampo})
	ELSEIF nArray == 8
		Return ASCAN(_aCmpITE,{|X| X == cCampo})
	ELSEIF nArray == 9
		Return ASCAN(_aCmpCCF,{|X| X == cCampo})
	ELSEIF nArray == 10
		Return ASCAN(_aCmpPED,{|X| X == cCampo})
	ELSEIF nArray == 11
		Return ASCAN(_aCmpSEL,{|X| X == cCampo})
	ELSEIF nArray == 12
		Return ASCAN(_aCmpENT,{|X| X == cCampo})
	ELSEIF nArray == 13
		Return ASCAN(_aCmpROT,{|X| X == cCampo})
	ENDIF 
Return

/*/{Protheus.doc} GFEXFB_8SKIP
//TODO Retorna qual campo do array é para retornar a informação
@author andre.wisnheski
@since 19/06/2015
@version 
@param lTabTmp, Logico, Indica se é tabela temporária ou array
@param cTabTmp, Caracter, Nome da tabela temporia que será manipulada
@param nArray, Numerico, Código do array que será manipulado
@type function
/*/
Function GFEXFB_8SKIP(lTabTmp, cTabTmp, nArray, nInc)
	Default nInc := 1
Return GFEXFB_4IDX(nArray,.T.,nInc)

/*/{Protheus.doc} GFEXFB_9GETAREA
//TODO Pega a area atual do array ou da tabela temporária
@author andre.wisnheski
@since 19/06/2015
@version 1.0 
@param lTabTmp, Logico, Indica se é tabela temporária ou array
@param cTabTmp, Caracter, Nome da tabela temporia que será manipulada
@param nArray, Numerico, Código do array que será manipulado
@type function
/*/
function GFEXFB_9GETAREA(lTabTmp, cTabTmp, nArray)
Return GFEXFB_4IDX(nArray,.F.)

/*/{Protheus.doc} GFEXFB_ARESTAREA
//TODO Restaura a area que foi congelada
@author andre.wisnheski
@since 19/06/2015
@version 1.0
@param lTabTmp, Logico, Indica se é tabela temporária ou array
@param aAreaTmp, Array/Numerico, Posição que deve ser retornada
@param nArray, Numerico, Código do array que será manipulado
@type function
/*/
function GFEXFB_ARESTAREA(lTabTmp, aAreaTmp, nArray)
	IF nArray == 0
		idpGRU := aAreaTmp
	ELSEIF nArray == 1
		idpDOC := aAreaTmp
	ELSEIF nArray == 2
		idpSTF := aAreaTmp
	ELSEIF nArray == 3
		idpSIM := aAreaTmp
	ELSEIF nArray == 4
		idpGRB := aAreaTmp
	ELSEIF nArray == 5
		idpTCF := aAreaTmp
	ELSEIF nArray == 6
		idpUNC := aAreaTmp		
	ELSEIF nArray == 7
		idpTRE := aAreaTmp
	ELSEIF nArray == 8
		idpITE := aAreaTmp
	ELSEIF nArray == 9
		idpCCF := aAreaTmp
	ELSEIF nArray == 10
		idpPED := aAreaTmp
	ELSEIF nArray == 11
		idpSEL := aAreaTmp
	ELSEIF nArray == 12
		idpENT := aAreaTmp
	ELSEIF nArray == 13
		idpROT := aAreaTmp
	ENDIF 
Return

/*/{Protheus.doc} GFEXFB_BORDER
//TODO Indica a ordem do indice a ser utilizada
@author andre.wisnheski
@since 19/06/2015
@version 1.0 
@param lTabTmp, Logico, Indica se é tabela temporária ou array
@param cTabTmp, Caracter, Nome da tabela temporia que será manipulada
@param nOrdem, Numérico, Ordem do indice
@param nArray, Numerico, Código do array que será manipulado
@type function
/*/
function GFEXFB_BORDER(lTabTmp, cTabTmp, nOrdem, nArray)
	IF nArray == 0
		idxGRU := nOrdem
	ELSEIF nArray == 1
		idxDOC := nOrdem
	ELSEIF nArray == 2
		idxSTF := nOrdem
	ELSEIF nArray == 3
		idxSIM := nOrdem
	ELSEIF nArray == 4
		idxGRB := nOrdem
	ELSEIF nArray == 5
		idxTCF := nOrdem
	ELSEIF nArray == 6
		idxUNC := nOrdem
	ELSEIF nArray == 7
		idxTRE := nOrdem
	ELSEIF nArray == 8
		idxITE := nOrdem
	ELSEIF nArray == 9
		idxCCF := nOrdem
	ELSEIF nArray == 10
		idxPED := nOrdem
	ELSEIF nArray == 11
		idxSEL := nOrdem
	ELSEIF nArray == 12
		idxENT := nOrdem
	ELSEIF nArray == 13
		idxROT := nOrdem
	ENDIF 
Return

Static function GFEXFB_AJARRAY(aAjust,aPos)
	Local nX		:= 0
	Local nY		:= 0
	for nX:= 1 to Len(aAjust)
		for nY:= 1 to Len(aPos)
			aAjust[nX][aPos[nY]] := AllTrim(Upper(aAjust[nX][aPos[nY]])) 
		next
	next

Return

/*/{Protheus.doc} GFEXFB_CSEEK
//TODO Semelhante a função dbSeek. Executa o dbSeek na tabela temporária. no Array executa a busca no o ASCAN()
@author andre.wisnheski
@since 19/06/2015
@version 1.0 
@param lTabTmp, Logico, Indica se é tabela temporária ou array
@param cTabTmp, Caracter, Nome da tabela temporia que será manipulada
@param aTabTmp, Array, Array que deve ser manipulado
@param nArray, Numerico, Código do array que será manipulado
@param aChave, Array, Array com a chave de busca
@type function
/*/
function GFEXFB_CSEEK(lTabTmp, cTabTmp, aTabTmp, nArray, aChave)
	Local nX		:= 0
	Local nChave	:= 0
	Local axChave	:= {}
	Local axTabTmp	:= aClone(aTabTmp)
	
	nChave := Len(aChave)
	for nX:= 1 to nChave
		aAdd(axChave,AllTrim(Upper(aChave[nX]))) 
	next

	if nArray == 0
		aPos := {1} // indicar as posições do array que serão utilizadas para realizar o ASCAN()
		GFEXFB_AJARRAY(@axTabTmp,aPos)
		idpGRU := (ASCAN(axTabTmp,{|X| X[1] == axChave[1]}))
		Return idpGRU > 0

	ElseIf nArray == 1
		// INDICES -	1 - "NRAGRU"
		//				2 - "CDTPDC+EMISDC+SERDC+NRDC"
		IF idxDOC == 1
			aPos := {16} // indicar as posições do array que serão utilizadas para realizar o ASCAN()
			GFEXFB_AJARRAY(@axTabTmp,aPos)
			idpDOC := (ASCAN(axTabTmp,{|X| X[16] == axChave[1]}))
		Else
			aPos := {4,1,2,3} // indicar as posições do array que serão utilizadas para realizar o ASCAN()
			GFEXFB_AJARRAY(@axTabTmp,aPos)
			idpDOC := (ASCAN(axTabTmp,{|X| IIF(nChave>=1,X[4] == axChave[1],.T.) .AND.;
										   IIF(nChave>=2,X[1] == axChave[2],.T.) .AND.;
										   IIF(nChave>=3,X[2] == axChave[3],.T.) .AND.;
										   IIF(nChave>=4,X[3] == axChave[4],.T.)  }))
		EndIf
		Return idpDOC > 0

	ElseIf nArray == 2
		// INDICES -	1 - "NRROM+NRTAB+NRNEG+NRROTA"
		//				2 - "NRCALC+CDCLFR+CDTPOP"
		//				3 - "EMIVIN+TABVIN+NRNEG+NRROTA"
		IF idxSTF == 1
			aPos := {1,4,5,11}
			GFEXFB_AJARRAY(@axTabTmp,aPos)
			idpSTF := (ASCAN(axTabTmp,{|X| 	IIF(nChave>=1,X[01] == axChave[1],.T.) .AND.;
									  		IIF(nChave>=2,X[04] == axChave[2],.T.) .AND.;
									  		IIF(nChave>=3,X[05] == axChave[3],.T.) .AND.;
									  		IIF(nChave>=4,X[11] == axChave[4],.T.)  }))
		ElseIf idxSTF == 2
			aPos := {6,7,8}
			GFEXFB_AJARRAY(@axTabTmp,aPos)
			idpSTF := (ASCAN(axTabTmp,{|X| IIF(nChave>=1,X[06] == axChave[1],.T.) .AND.;
										   IIF(nChave>=2,X[07] == axChave[2],.T.) .AND.;
										   IIF(nChave>=3,X[08] == axChave[3],.T.)  }))
		ElseIf idxSTF == 3
			aPos := {18,19,05,11}
			GFEXFB_AJARRAY(@axTabTmp,aPos)
			idpSTF := (ASCAN(axTabTmp,{|X|   IIF(nChave>=1,X[18] == axChave[1],.T.) .AND.;
											 IIF(nChave>=2,X[19] == axChave[2],.T.) .AND.;
 											 IIF(nChave>=3,X[05] == axChave[3],.T.) .AND.;
									  		 IIF(nChave>=4,X[11] == axChave[4],.T.)  }))
		EndIf
		Return idpSTF > 0

	ElseIf nArray == 3
		// INDICES -	1 - "NRROM + NRTAB + NRNEG + NRCALC + NRROTA + SELEC"
		//				2 - "NRCALC + CDCLFR + CDTPOP + EMIVIN + TABVIN + NRNEG + NRROTA"
		//				3 - "NRCALC + CDCLFR + CDTPOP"
		IF idxSIM == 1
			aPos := {01,04,05,06,11,28}
			GFEXFB_AJARRAY(@axTabTmp,aPos)
			idpSIM := (ASCAN(axTabTmp,{|X| IIF(nChave>=1,X[01] == axChave[1],.T.) .AND.;
										   IIF(nChave>=2,X[04] == axChave[2],.T.) .AND.;
										   IIF(nChave>=3,X[05] == axChave[3],.T.) .AND.;
										   IIF(nChave>=4,X[06] == axChave[4],.T.) .AND.;
										   IIF(nChave>=5,X[11] == axChave[5],.T.) .AND.;
										   IIF(nChave>=6,X[28] == axChave[6],.T.)  }))
		ElseIf idxSIM == 2 .OR. idxSIM == 3
			aPos := {06,07,08,18,19,05,11}
			GFEXFB_AJARRAY(@axTabTmp,aPos)
			idpSIM := (ASCAN(axTabTmp,{|X| IIF(nChave>=1,X[06] == axChave[1],.T.) .AND.;
										   IIF(nChave>=2,X[07] == axChave[2],.T.) .AND.;
										   IIF(nChave>=3,X[08] == axChave[3],.T.) .AND.;
										   IIF(nChave>=4,X[18] == axChave[4],.T.) .AND.;
										   IIF(nChave>=5,X[19] == axChave[5],.T.) .AND.;
										   IIF(nChave>=6,X[05] == axChave[6],.T.) .AND.;
										   IIF(nChave>=7,X[11] == axChave[7],.T.)  }))
		EndIf
		Return idpSIM > 0

	ElseIf nArray == 4
		// INDICES -	1 - "NRAGRU+CDREM+CDDEST+CDTPDC+TPFRET+NRREG+USO+CARREG+ENTNRC+ENTBAI+ENTEND"
		//				2 - "CDTPDC+EMISDC+SERDC+NRDC"
		//				3 - "NRGRUP"
		//				4 - "NRAGRU+CDREM+CDDEST+ENTNRC+ENTBAI+ENTEND"
		IF idxGRB == 1
			aPos := {16,06,07,05,13,12,14,15,10,09,08}
			GFEXFB_AJARRAY(@axTabTmp,aPos)
			idpGRB := (ASCAN(axTabTmp,{|X| IIF(nChave>=01,X[16] == axChave[01],.T.) .AND.;
										   IIF(nChave>=02,X[06] == axChave[02],.T.) .AND.;
										   IIF(nChave>=03,X[07] == axChave[03],.T.) .AND.;
										   IIF(nChave>=04,X[05] == axChave[04],.T.) .AND.;
										   IIF(nChave>=05,X[13] == axChave[05],.T.) .AND.;
										   IIF(nChave>=06,X[12] == axChave[06],.T.) .AND.;
										   IIF(nChave>=07,X[14] == axChave[07],.T.) .AND.;
										   IIF(nChave>=08,X[15] == axChave[08],.T.) .AND.;
										   IIF(nChave>=09,X[10] == axChave[09],.T.) .AND.;
										   IIF(nChave>=10,X[09] == axChave[10],.T.) .AND.;
										   IIF(nChave>=11,X[08] == axChave[11],.T.)  }))
		ElseIf idxGRB == 2 
			aPos := {05,02,03,04}
			GFEXFB_AJARRAY(@axTabTmp,aPos)
			idpGRB := (ASCAN(axTabTmp,{|X| IIF(nChave>=1,X[05] == axChave[1],.T.) .AND.;
										   IIF(nChave>=2,X[02] == axChave[2],.T.) .AND.;
										   IIF(nChave>=3,X[03] == axChave[3],.T.) .AND.;
										   IIF(nChave>=4,X[04] == axChave[4],.T.)  }))
		ElseIf idxGRB == 3 
			aPos := {01}
			GFEXFB_AJARRAY(@axTabTmp,aPos)
			idpGRB := (ASCAN(axTabTmp,{|X| X[01] == axChave[1]}))
		ElseIf idxGRB == 4 
			aPos := {16,06,07,10,09,08}
			GFEXFB_AJARRAY(@axTabTmp,aPos)
			idpGRB := (ASCAN(axTabTmp,{|X| IIF(nChave>=1,X[16] == axChave[01],.T.) .AND.;
										   IIF(nChave>=2,X[06] == axChave[02],.T.) .AND.;
										   IIF(nChave>=3,X[07] == axChave[03],.T.) .AND.;
										   IIF(nChave>=4,X[10] == axChave[04],.T.) .AND.;
										   IIF(nChave>=5,X[09] == axChave[05],.T.) .AND.;
										   IIF(nChave>=6,X[08] == axChave[06],.T.)  }))
		EndIf
		Return idpGRB > 0

	ElseIf nArray == 5
		// INDICES -	1 - NRCALC + CDCLFR + CDTPOP + SEQ",
		//				2 - "NRGRUP"
		IF idxTCF == 1
			if Len(aChave) == 1
				aPos := {01}
				GFEXFB_AJARRAY(@axTabTmp,aPos)
				idpTCF := (ASCAN(axTabTmp,{|X| X[01] == axChave[01]}))
			else
				aPos := {01,02,03}
				GFEXFB_AJARRAY(@axTabTmp,aPos)
				idpTCF := (ASCAN(axTabTmp,{|X| IIF(nChave>=1,X[01] == axChave[01],.T.) .AND.;
										  	   IIF(nChave>=2,X[02] == axChave[02],.T.) .AND.;
										  	   IIF(nChave>=3,X[03] == axChave[03],.T.)  }))
			EndIf
		ElseIf idxTCF == 2 
			aPos := {20}
			GFEXFB_AJARRAY(@axTabTmp,aPos)
			idpTCF := (ASCAN(axTabTmp,{|X| X[20] == axChave[1]}))
		EndIf
		Return idpTCF > 0

	ElseIf nArray == 6
		// INDICES -	1 - NRCALC
		//				2 - NRAGRU+NRCALC
		//				3 - NRAGRU+SEQTRE+NRCALC
		IF idxUNC == 1
			aPos := {01}
			GFEXFB_AJARRAY(@axTabTmp,aPos)
			idpUNC := (ASCAN(axTabTmp,{|X| X[01] == axChave[01]}))
		ElseIf idxUNC == 2 
			aPos := {19,01}
			GFEXFB_AJARRAY(@axTabTmp,aPos)
			idpUNC := (ASCAN(axTabTmp,{|X|	IIF(nChave>=1,X[19] == axChave[01],.T.) .AND.;
									 		IIF(nChave>=2,X[01] == axChave[02],.T.) }))
		ElseIf idxUNC == 3 
			aPos := {19,21,01}
			GFEXFB_AJARRAY(@axTabTmp,aPos)
			idpUNC := (ASCAN(axTabTmp,{|X|	IIF(nChave>=1,X[19] == axChave[01],.T.) .AND.;
									 		IIF(nChave>=2,X[21] == axChave[02],.T.) .AND.;
									 		IIF(nChave>=3,X[01] == axChave[03],.T.) }))
		ElseIf idxUNC == 4 
			aPos := {26}
			GFEXFB_AJARRAY(@axTabTmp,aPos)
			idpUNC := (ASCAN(axTabTmp,{|X|	IIF(nChave>=1,X[26] == axChave[01],.T.)}))
		EndIf
		Return idpUNC > 0

	ElseIf nArray == 7
		// INDICES -	1 - NRCALC
		//				2 - CDTPDC+EMISDC+SERDC+NRDC+SEQ
		//				3 - NRGRUP+SEQ+ORIGEM+DESTIN
		//				4 - NRGRUP+NRDC+SEQ+ORIGEM+DESTIN
		IF idxTRE == 1
			aPos := {18}
			GFEXFB_AJARRAY(@axTabTmp,aPos)
			idpTRE := (ASCAN(axTabTmp,{|X| X[18] == axChave[01]}))
		ElseIf idxTRE == 2
			aPos := {04,01,02,03,05}
			GFEXFB_AJARRAY(@axTabTmp,aPos)
			idpTRE := (ASCAN(axTabTmp,{|X|	IIF(nChave>=1,X[04] == axChave[01],.T.) .AND.;
											IIF(nChave>=2,X[01] == axChave[02],.T.) .AND.;
											IIF(nChave>=3,X[02] == axChave[03],.T.) .AND.;
											IIF(nChave>=4,X[03] == axChave[04],.T.) .AND.;
									 		IIF(nChave>=5,X[05] == axChave[05],.T.) }))
		ElseIf idxTRE == 3 
			aPos := {17,05,15,16}
			GFEXFB_AJARRAY(@axTabTmp,aPos)
			idpTRE := (ASCAN(axTabTmp,{|X|	IIF(nChave>=1,X[17] == axChave[01],.T.) .AND.;
											IIF(nChave>=2,X[05] == axChave[02],.T.) .AND.;
											IIF(nChave>=3,X[15] == axChave[03],.T.) .AND.;
											IIF(nChave>=4,X[16] == axChave[04],.T.)  }))
		ElseIf idxTRE == 4 
			aPos := {17,03,05,15,16}
			GFEXFB_AJARRAY(@axTabTmp,aPos)
			idpTRE := (ASCAN(axTabTmp,{|X|	IIF(nChave>=1,X[17] == axChave[01],.T.) .AND.;
											IIF(nChave>=2,X[03] == axChave[02],.T.) .AND.;
											IIF(nChave>=3,X[05] == axChave[03],.T.) .AND.;
											IIF(nChave>=4,X[15] == axChave[04],.T.) .AND.;
											IIF(nChave>=5,X[16] == axChave[05],.T.)  }))
		EndIf
		Return idpTRE > 0

	ElseIf nArray == 8
		// INDICES -	1 - CDTPDC + EMISDC + SERDC + NRDC + ITEM
		//				2 - NRGRUP + CDCLFR + ITEM
		IF idxITE == 1
			aPos := {04,01,02,03,05}
			GFEXFB_AJARRAY(@axTabTmp,aPos)
			idpITE := (ASCAN(axTabTmp,{|X|	IIF(nChave>=1,X[04] == axChave[01],.T.) .AND.;
											IIF(nChave>=2,X[01] == axChave[02],.T.) .AND.;
											IIF(nChave>=3,X[02] == axChave[03],.T.) .AND.;
											IIF(nChave>=4,X[03] == axChave[04],.T.) .AND.;
									 		IIF(nChave>=5,X[05] == axChave[05],.T.) }))
		Else
			aPos := {15,06,05}
			GFEXFB_AJARRAY(@axTabTmp,aPos)
			idpITE := (ASCAN(axTabTmp,{|X|	IIF(nChave>=1,X[15] == axChave[01],.T.) .AND.;
											IIF(nChave>=2,X[06] == axChave[02],.T.) .AND.;
											IIF(nChave>=3,X[05] == axChave[03],.T.) }))
		EndIf
		Return idpITE > 0

	ElseIf nArray == 9
		// INDICES -	1 - NRCALC + CDCLFR + CDTPOP + CDCOMP
		//				2 - NRCALC + CDCOMP
		//				3 - NRCALC + CDCLFR + CDTPOP + SEQ
		IF idxCCF == 1
			aPos := {01,02,03,05}
			GFEXFB_AJARRAY(@axTabTmp,aPos)
			idpCCF := (ASCAN(axTabTmp,{|X|	IIF(nChave>=1,X[01] == axChave[01],.T.) .AND.;
											IIF(nChave>=2,X[02] == axChave[02],.T.) .AND.;
											IIF(nChave>=3,X[03] == axChave[03],.T.) .AND.;
											IIF(nChave>=4,X[05] == axChave[04],.T.) }))
		ElseIf idxCCF == 2
			aPos := {01,05}
			GFEXFB_AJARRAY(@axTabTmp,aPos)
			idpCCF := (ASCAN(axTabTmp,{|X|	IIF(nChave>=1,X[01] == axChave[01],.T.) .AND.;
											IIF(nChave>=2,X[05] == axChave[02],.T.) }))
		ElseIf idxCCF == 3
			aPos := {01,02,03,04}
			GFEXFB_AJARRAY(@axTabTmp,aPos)
			idpCCF := (ASCAN(axTabTmp,{|X| 	IIF(nChave>=1,X[01] == axChave[01],.T.) .AND.;
											IIF(nChave>=2,X[02] == axChave[02],.T.) .AND.;
											IIF(nChave>=3,X[03] == axChave[03],.T.) .AND.;
											IIF(nChave>=4,X[04] == axChave[04],.T.) }))
		EndIf
		Return idpCCF > 0
		
	ElseIf nArray == 10
		// INDICES -	1 - NRCALC + CDCLFR + CDTPOP
		aPos := {01,02,03}
		GFEXFB_AJARRAY(@axTabTmp,aPos)
		idpPED := (ASCAN(axTabTmp,{|X|	IIF(nChave>=1,X[01] == axChave[01],.T.) .AND.;
										IIF(nChave>=2,X[02] == axChave[02],.T.) .AND.;
										IIF(nChave>=3,X[03] == axChave[03],.T.) }))
		Return idpPED > 0

	ElseIf nArray == 11
		// INDICES -	1 - CDTPDC + EMISDC + SERDC + NRDC
		aPos := {04,01,02,03}
		GFEXFB_AJARRAY(@axTabTmp,aPos)
		idpSEL := (ASCAN(axTabTmp,{|X|	IIF(nChave>=1,X[04] == axChave[01],.T.) .AND.;
										IIF(nChave>=2,X[01] == axChave[02],.T.) .AND.;
										IIF(nChave>=3,X[02] == axChave[03],.T.) .AND.;
										IIF(nChave>=4,X[03] == axChave[04],.T.) }))
		Return idpSEL > 0

	ElseIf nArray == 12
		//aIndexes := {"NRLCENT+CDCOMP","CDTRP+SEQTRE+ORIGEM+DESTIN+CDREM+CDDEST","CDTRP+SEQTRE+ORIGEM+DESTIN+CDREM+CDDEST+CDCOMP+CDCLFR+CDTPOP"}
		If idxEnt == 1
			aPos := {01,11}
			GFEXFB_AJARRAY(@axTabTmp,aPos)
			idpENT := (ASCAN(axTabTmp,{|X|	IIF(nChave>=1,X[01] == axChave[01],.T.) .AND.;
											IIF(nChave>=2,X[11] == axChave[02],.T.) }))
		ElseIf idxEnt == 2
			aPos := {02,03,04,05,06,07}
			GFEXFB_AJARRAY(@axTabTmp,aPos)
			idpENT := (ASCAN(axTabTmp,{|X|	IIF(nChave>=1,X[02] == axChave[01],.T.) .AND.;
											IIF(nChave>=2,X[03] == axChave[02],.T.) .AND.;
											IIF(nChave>=3,X[04] == axChave[03],.T.) .AND.;
											IIF(nChave>=4,X[05] == axChave[04],.T.) .AND.;
											IIF(nChave>=5,X[06] == axChave[05],.T.) .AND.;
											IIF(nChave>=6,X[07] == axChave[06],.T.) }))
		ElseIf  idxEnt == 3
			aPos := {02,03,04,05,06,07,11,12,13}
			GFEXFB_AJARRAY(@axTabTmp,aPos)
			idpENT := (ASCAN(axTabTmp,{|X|	IIF(nChave>=1,X[02] == axChave[01],.T.) .AND.;
											IIF(nChave>=2,X[03] == axChave[02],.T.) .AND.;
											IIF(nChave>=3,X[04] == axChave[03],.T.) .AND.;
											IIF(nChave>=4,X[05] == axChave[04],.T.) .AND.;
											IIF(nChave>=5,X[06] == axChave[05],.T.) .AND.;
											IIF(nChave>=6,X[07] == axChave[06],.T.) .AND.;
											IIF(nChave>=7,X[11] == axChave[07],.T.) .AND.;
											IIF(nChave>=8,X[12] == axChave[08],.T.) .AND.;
											IIF(nChave>=9,X[13] == axChave[09],.T.) }))
		EndIf 	
		Return idpENT > 0

	ElseIf nArray == 13
		If  idxROT == 1
			aPos := {01,02,03,04,05,06,07}
			GFEXFB_AJARRAY(@axTabTmp,aPos)
			idpROT := (ASCAN(axTabTmp,{|X|	IIF(nChave>=1, X[01] == axChave[01],.T.) .AND.;
											IIF(nChave>=2, X[02] == axChave[02],.T.) .AND.;
											IIF(nChave>=3, X[03] == axChave[03],.T.) .AND.;
											IIF(nChave>=4, X[04] == axChave[04],.T.) .AND.;
											IIF(nChave>=5, X[05] == axChave[05],.T.) .AND.;
											IIF(nChave>=6, X[06] == axChave[06],.T.) .AND.;
											IIF(nChave>=7, X[07] == axChave[07],.T.) }))
			Return idpROT > 0
		EndIf
	EndIf
Return

/*/{Protheus.doc} GFEXFB_FRECCOUNT
//TODO Similar ao comando RecCount. Retorna a quantidade de registros
@author andre.wisnheski
@since 22/06/2015
@version 1.0
@param lTabTmp, Logico, Indica se é tabela temporária ou array
@param cTabTmp, Caracter, Nome da tabela temporia que será manipulada
@param aTabTmp, Array, Array que deve ser manipulado
@type function
/*/
function GFEXFB_FRECCOUNT(lTabTmp, cTabTmp, aTabTmp)
Return Len(aTabTmp)

/*/{Protheus.doc} GFEXFB_GRECNO
//TODO Retorna o RecNo Atual da Tabela/Array
@author andre.wisnheski
@since 29/06/2015
@version 
@param lTabTmp, Logico, Indica se é tabela temporária ou array
@param cTabTmp, Caracter, Nome da tabela temporia que será manipulada
@param nArray, Numerico, Código do array que será manipulado
@type function
/*/
function GFEXFB_GRECNO(lTabTmp, cTabTmp, nArray)
Return GFEXFB_4IDX(nArray,.F.)

/*/{Protheus.doc} GFEXFB_HGOTO
//TODO Simular a função dbGoTo()
@author andre.wisnheski
@since 29/06/2015
@version 
@param lTabTmp, Logico, Indica se é tabela temporária ou array
@param cTabTmp, Caracter, Nome da tabela temporia que será manipulada
@param nArray, Numerico, Código do array que será manipulado
@param nRec, Numerico, Posição que deverá retornar a tabela/array
@type function
/*/
function GFEXFB_HGOTO(lTabTmp, cTabTmp, nArray, nRec)
	IF nArray == 0
		idpGRU := nRec
	ELSEIF nArray == 1
		idpDOC := nRec
	ELSEIF nArray == 2
		idpSTF := nRec
	ELSEIF nArray == 3
		idpSIM := nRec
	ELSEIF nArray == 4
		idpGRB := nRec
	ELSEIF nArray == 5
		idpTCF := nRec
	ELSEIF nArray == 6
		idpUNC := nRec
	ELSEIF nArray == 7
		idpTRE := nRec
	ELSEIF nArray == 8
		idpITE := nRec
	ELSEIF nArray == 9
		idpCCF := nRec
	ELSEIF nArray == 10
		idpPED := nRec
	ELSEIF nArray == 11
		idpSEL := nRec
	ELSEIF nArray == 12
		idpENT := nRec
	ELSEIF nArray == 13
		idpROT := nRec
	ENDIF 
Return

/*/{Protheus.doc} GFEXFB_IBOTTOM
//TODO Função Similar a DBGOBOTTOM
@author andre.wisnheski
@since 28/07/2015
@version 1.0 
@param  lTabTmp		Indica se é tabela temporária ou array 
@param  cTabTmp 	Nome da tabela temporia que será manipulada
@param  aTabTmp		Array que deve ser manipulado
@param  nArray		Código do array que será manipulado

@type function
/*/
function GFEXFB_IBOTTOM(lTabTmp, cTabTmp, aTabTmp, nArray)
	IF nArray == 0
		idpGRU := Len(aTabTmp)
	ELSEIF nArray == 1
		idpDOC := Len(aTabTmp)
	ELSEIF nArray == 2
		idpSTF := Len(aTabTmp)
	ELSEIF nArray == 3
		idpSIM := Len(aTabTmp)
	ELSEIF nArray == 4
		idpGRB := Len(aTabTmp)
	ELSEIF nArray == 5
		idpTCF := Len(aTabTmp)
	ELSEIF nArray == 6
		idpUNC := Len(aTabTmp)
	ELSEIF nArray == 7
		idpTRE := Len(aTabTmp)
	ELSEIF nArray == 8
		idpITE := Len(aTabTmp)
	ELSEIF nArray == 9
		idpCCF := Len(aTabTmp)
	ELSEIF nArray == 10
		idpPED := Len(aTabTmp)
	ELSEIF nArray == 11
		idpSEL := Len(aTabTmp)
	ELSEIF nArray == 12
		idpENT := Len(aTabTmp)
	ELSEIF nArray == 13
		idpROT := Len(aTabTmp)
	ENDIF
Return
/*/{Protheus.doc} GFEXFB_JCLONE
@author siegklenes.beulke
@since 28/07/2015
@version 1.0
@description Clona um array, mantendo a referência entre os campos, sendo possível reordenar sem afetar o original, mas afetando quando o conteúdo de um campo é alterado 
@param  aArray		aArray a ser clonado por referencia

@type function
/*/
Function GFEXFB_JCLONE(aArray)
Local nX
Local aRet := {}
For nX := 1 To Len(aArray)
	aAdd(aRet,@aArray[nX])
Next nX
Return aRet
