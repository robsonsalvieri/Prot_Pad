#INCLUDE "PROTHEUS.CH"
#INCLUDE "MATA103.CH"

/*
Fonte desenvolvido para receber funções de validação para o documento de entrada
*/

Static __lTrbGen := NIL

/*/{Protheus.doc} MatEst175
//
@author andre. Maximo 
@since 23/09/2019
@version 1.0
@return logico
@param item posicionado na SD1 de origem da nota
@type function
/*/

Function MatEst175(cTabSd1)
Local aAreaSD1 := (cTabSd1)->(GetArea())
Local aQtd := {}
Local lRet := .F.
Local cCq      := SuperGetMV("MV_CQ")

dbSelectArea("SD1")
dbSetOrder(1)
If MsSeek(xFilial("SD1")+(cTabSd1)->D1_NFORI+(cTabSd1)->D1_SERIORI+(cTabSd1)->D1_FORNECE+(cTabSd1)->D1_LOJA+(cTabSd1)->D1_COD+(cTabSd1)->D1_ITEMORI,.F.)
    If alltrim((cTabSd1)->D1_LOCAL) == alltrim(cCq)
        SD7->(DbSetorder(1))
        If SD7->(dbSeek(xfilial("SD7")+(cTabSd1)->(D1_NUMCQ+D1_COD) ))
            aQtd := A175CalcQt((cTabSd1)->D1_NUMCQ, (cTabSd1)->D1_COD, (cTabSd1)->D1_LOCAL)
            If len(aQtd) > 0 .And. (QtdComp(aQtd[6])==QtdComp(0) .Or. !Empty(SD7->D7_LIBERA))
                lRet:=.F.
            else
                lRet:= .T.
            EndIf
        EndIf
    EndIf
EndIf
RestArea(aAreaSD1)

return(lRet)

/*/{Protheus.doc} A103Usado
	@type  Function
	@author miqueias.coelho
	@since 21/10/2022
    @descricao 'Funcao criada para realizar validacao e verificacao de campos que estao com uso desabilitado'
	@return lRet
	/*/
Function A103Usado()

Local aArea		:= GetArea()
Local lRet		:= .T.
Local lRastro	:= .F.
Local lGrade	:= .F.
Local lSegUM	:= .F.
Local nPosCod	:= GetPosSD1("D1_COD")
Local nI		:= 0
Local cMsg		:= ""
Local aCpoSD1	:= {"D1_LOTECTL","D1_LOTEFOR","D1_NUMLOTE","D1_DTVALID","D1_GRADE","D1_ITEMGRD","D1_SEGUM","D1_QTSEGUM"}

If nPosCod > 0
	lRastro := Rastro(aCols[n][nPosCod])
	lGrade	:= MatGrdPrrf(aCols[n][nPosCod],.T.)

	DbSelectArea("SB1")
	SB1->(DbSetOrder(1))
	SB1->(MsSeek(xFilial("SB1")+aCols[n][nPosCod]))
	If !Empty(SB1->B1_SEGUM) .And. SB1->B1_CONV > 0
		lSegUM := .T.
	Endif

	If lRastro .Or. lGrade .Or. lSegUM
		For nI := 1 To Len(aCpoSD1)
			
			//Valida se o produto controla lote e se os campos D1_LOTECTL, D1_LOTEFOR, D1_NUMLOTE e D1_DTVALID
			If lRastro .And. AllTrim(aCpoSD1[nI]) $ "D1_LOTECTL|D1_LOTEFOR|D1_NUMLOTE|D1_DTVALID|" .And. !X3Uso(GetSx3Cache(aCpoSD1[nI],'X3_USADO'))
				cMsg := STR0385 + Alltrim(aCols[n][nPosCod]) + " " + STR0563 + TRIM(GetSx3Cache(aCpoSD1[nI],'X3_TITULO')) + " (" + Alltrim(aCpoSD1[nI]) + ")" + STR0566
				lRet := .F.
				Exit
			Endif

			//Valida se o produto tem grade
			If lGrade .And. AllTrim(aCpoSD1[nI]) $ "D1_GRADE|D1_ITEMGRD" .And. !X3Uso(GetSx3Cache(aCpoSD1[nI],'X3_USADO'))
				cMsg := STR0385 + Alltrim(aCols[n][nPosCod]) + " " + STR0564 + TRIM(GetSx3Cache(aCpoSD1[nI],'X3_TITULO')) + " (" + Alltrim(aCpoSD1[nI]) + ")" + STR0566
				lRet := .F.
				Exit
			Endif

			//Valida se o produto utiliza segunda unidade de medida no cadastro (SB1)
			If lSegUM .And. AllTrim(aCpoSD1[nI]) $ "D1_SEGUM|D1_QTSEGUM" .And. !X3Uso(GetSx3Cache(aCpoSD1[nI],'X3_USADO'))
				cMsg := STR0385 + Alltrim(aCols[n][nPosCod]) + " " + STR0565 + TRIM(GetSx3Cache(aCpoSD1[nI],'X3_TITULO')) + " (" + Alltrim(aCpoSD1[nI]) + ")" + STR0566
				lRet := .F.
				Exit
			Endif
		Next nI
	Endif

	If !lRet
		Help(" ",1,"ESTUSADO",,cMsg,1,0)
	Endif
Endif

RestArea(aArea)
Return lRet

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³A103xETrSl³ Autor ³ Microsiga S/A         ³ Data ³22/03/2023³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³Funcao utilizada para transferir o saldo classificado para  ³±±
±±³          ³o Armazem de Transito definido pelo parametro MV_LOCTRAN.   ³±±
±±³          ³ Função migrada do mata103 A103TrfSld mantida por compatil. ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³lDeleta - .T. = Exclusao NFE                                ³±±
±±³          ³          .F. = Classificao da Pre-Nota                     ³±±
±±³          ³nTipo   - 1 = Transferencia para Armazem de Transito        ³±±
±±³          ³          2 = Retorno do saldo para o armazem orginal       ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function A103xETrSl(lDeleta,nTipo)

Local aAreaAnt   := GetArea()
Local aAreaSF4   := SF4->(GetArea())
Local aAreaSD1   := SD1->(GetArea())
Local aAreaSD3   := SD3->(GetArea())
Local aAreaSB2   := SD3->(GetArea())
Local cLocTran   := SuperGetMV("MV_LOCTRAN",.F.,"95")
Local cLocCQ     := SuperGetMV("MV_CQ",.F.,"98")
Local aArray     := {}
Local aStruSD3   := {}
Local cSeek      := ''
Local cQuery     := ''
Local cAliasSD3  := 'SD3'
Local cChave     := Space(TamSX3("D3_CHAVE")[1])
Local nX         := 0
Local lQuery     := .F.
Local lContinua  := .F.
Local lVldPE  	 := .T.
Local lTransit   := .F.

Default lDeleta     := .F.
Default nTipo       := 1

Private lMsErroAuto := .F.

//Ponto de Entrada para validar se permite a operacao
If ExistBlock("A103TRFVLD")
	lVldPE:= ExecBlock("A103TRFVLD",.F.,.F.,{nTipo,lDeleta})
	If Valtype (lVldPE) != "L"
		lVldPE:= .T.
	EndIf
EndIf

//Remessa para o Armazem de Transito
If nTipo == 1 .And. lVldPE
		If !Localiza(SD1->D1_COD) .And. Empty(SD1->D1_OP) .And. AllTrim(SD1->D1_LOCAL) # AllTrim(cLocCQ)
			dbSelectArea("SF4")
			dbSetOrder(1)
			//-- Tratamento para Transferencia de Saldos
		If cPaisLoc == "BRA"
			If dbSeek(xFilial("SF4")+SD1->D1_TES) .And. SF4->F4_ESTOQUE == 'S' .And. ;
	           SF4->F4_TRANSIT == 'S' .And. SF4->F4_CODIGO <= '500'
				//Estorno da transferencia para o Armazem de Terceiros
				If lDeleta 
					if !Empty(SD1->D1_TRANSIT)
						lTransit:=.T.
					EndIf
					//-- Retira o Flag que indica produto em transito
					RecLock("SD1",.F.)
					SD1->D1_TRANSIT := " "
					MsUnLock()
					lMsErroAuto := .F.
					cSeek:=xFilial("SD3")+SD1->D1_NUMSEQ+cChave+SD1->D1_COD

						aStruSD3 := SD3->(dbStruct())
						//Selecionar os registros da SD3 pertencentes a movimentacao de transferencia
						//e recebimento do armazem de transito. Pode ser que a nota ja tenha sido recebida
						//atraves do botao "Docto. em transito" e entao o saldo do armazem de transito tambem
						//deve ser estornado. Primeiro as saidas, depois as entradas.
						cQuery := "SELECT D3_FILIAL, D3_COD, D3_LOCAL, D3_NUMSEQ, D3_CF, D3_TM, D3_ESTORNO "
						cQuery +=  " FROM "+RetSQLTab('SD3')
						cQuery += " WHERE D3_FILIAL = '"+xFilial("SD3")+"' "
						cQuery +=   " AND D_E_L_E_T_  = ' ' "
						cQuery +=   " AND D3_ESTORNO <> 'S' "
						cQuery += 	" AND D3_COD      = '"+SD1->D1_COD+"' "
						cQuery += 	" AND D3_NUMSEQ   = '"+SD1->D1_NUMSEQ+"' "
						If !lTransit
							cQuery += 	" AND D3_LOCAL = '"+cLocTran+"' "
						EndIf 
						cQuery += " ORDER BY D3_FILIAL, D3_COD, D3_TM DESC "

						//--Executa a Query
						lQuery    := .T.
						cAliasSD3 := GetNextAlias()
						cQuery    := ChangeQuery( cQuery )
						DbUseArea( .T., 'TOPCONN', TcGenQry(,,cQuery), cAliasSD3, .T., .F. )
						For nX := 1 To Len(aStruSD3)
							If aStruSD3[nX,2]<>"C"
								TcSetField(cAliasSD3,aStruSD3[nX,1],aStruSD3[nX,2],aStruSD3[nX,3],aStruSD3[nX,4])
							EndIf
						Next nX

					Do While !(cAliasSD3)->(Eof()) .And. cSeek == xFilial("SD3")+(cAliasSD3)->D3_NUMSEQ+cChave+(cAliasSD3)->D3_COD
						aAdd(aArray,{{"D3_FILIAL"	,(cAliasSD3)->D3_FILIAL , NIL},;
									 {"D3_COD"		,(cAliasSD3)->D3_COD	, NIL},;
								     {"D3_LOCAL"	,(cAliasSD3)->D3_LOCAL	, NIL},;
									 {"D3_NUMSEQ"	,(cAliasSD3)->D3_NUMSEQ , NIL},;
									 {"D3_CF"		,(cAliasSD3)->D3_CF     , NIL},;
									 {"D3_TM"		,(cAliasSD3)->D3_TM     , NIL},;
									 {"INDEX"		,3						, NIL} })

						(cAliasSD3)->(dbSkip())
					EndDo

					// Ordenar o vetor para que as saidas sejam estornadas primeiro
					aSort(aArray,,,{|x,y| x[1,2]+x[2,2]+x[5,2] > y[1,2]+y[2,2]+y[5,2]})

					// Percorre todo o vetor com os registros a estornar
					For nX := 1 to Len(aArray)

						// Se for movimento de entrada e do armazem de transito
						If (aArray[nX][6][2] <= "500") .And. (aArray[nX][3][2] == cLocTran)
							//-- Desbloqueia o armazem de terceiro
							dbSelectArea("SB2")
							dbSetOrder(1)
							If dbSeek(xFilial("SB2")+SD1->D1_COD+cLocTran)
								RecLock("SB2",.F.)
								Replace B2_STATUS With "1"
								MsUnLock()
							EndIf
						EndIf

						MSExecAuto({|x,y| MATA240(x,y)},aArray[nX],5) // Operacao de estorno do movimento interno (SD3)

						//-- Tratamento de erro para rotina automatica
						If lMsErroAuto
							DisarmTransaction()
							MostraErro()
							Break
						EndIf

						// Se for movimento de entrada e do armazem de transito
						If (aArray[nX][6][2] <= "500") .And. (aArray[nX][3][2] == cLocTran)
							//-- Bloqueia o armazem de terceiro
							dbSelectArea("SB2")
							dbSetOrder(1)
							If dbSeek(xFilial("SB2")+SD1->D1_COD+cLocTran)
								RecLock("SB2",.F.)
								Replace B2_STATUS With "2"
								MsUnLock()
							EndIf
						EndIf
					Next nX

					If lQuery
						//--Fecha a area corrente
						dbSelectArea(cAliasSD3)
						dbCloseArea()
						dbSelectArea("SD3")
					EndIf

				//Transferencia para o Armazem de Terceiros
				ElseIf !lDeleta
					//-- Grava Flag que indica produto em transito
					RecLock("SD1",.F.)
					SD1->D1_TRANSIT := "S"
					MsUnLock()
					//-- Requisita o produto do armazem origem (Valorizado)
					dbSelectArea("SB2")
					dbSetOrder(1)
					If dbSeek(xFilial("SB2")+SD1->D1_COD+SD1->D1_LOCAL)
						RecLock("SD3",.T.)
						SD3->D3_FILIAL	:= xFilial("SD3")
						SD3->D3_COD		:= SD1->D1_COD
						SD3->D3_QUANT	:= SD1->D1_QUANT
						SD3->D3_TM		:= "999"
						SD3->D3_OP		:= SD1->D1_OP
						SD3->D3_LOCAL	:= SD1->D1_LOCAL
						SD3->D3_DOC		:= SD1->D1_DOC
						SD3->D3_EMISSAO	:= SD1->D1_DTDIGIT
						SD3->D3_NUMSEQ	:= SD1->D1_NUMSEQ
						SD3->D3_UM		:= SD1->D1_UM
						SD3->D3_GRUPO	:= SD1->D1_GRUPO
						SD3->D3_TIPO	:= SD1->D1_TP
						SD3->D3_SEGUM	:= SD1->D1_SEGUM
						SD3->D3_CONTA	:= SD1->D1_CONTA
						SD3->D3_CF		:= "RE6"
						SD3->D3_QTSEGUM	:= SD1->D1_QTSEGUM
						SD3->D3_USUARIO	:= SubStr(cUsuario,7,15)
						SD3->D3_CUSTO1	:= SD1->D1_CUSTO
						SD3->D3_CUSTO2	:= SD1->D1_CUSTO2
						SD3->D3_CUSTO3	:= SD1->D1_CUSTO3
						SD3->D3_CUSTO4	:= SD1->D1_CUSTO4
						SD3->D3_CUSTO5	:= SD1->D1_CUSTO5
						SD3->D3_NUMLOTE	:= SD1->D1_NUMLOTE
						SD3->D3_LOTECTL	:= SD1->D1_LOTECTL
						SD3->D3_DTVALID	:= SD1->D1_DTVALID
						SD3->D3_POTENCI	:= SD1->D1_POTENCI
						MsUnLock()
						dbSelectArea("SB2")
						B2AtuComD3({SD3->D3_CUSTO1,SD3->D3_CUSTO2,SD3->D3_CUSTO3,SD3->D3_CUSTO4,SD3->D3_CUSTO5})
						If Rastro(SD3->D3_COD) //posiciona SB8 no lote criado para referencia na criação do lote
							dbSelectArea('SB8')//de transito abaixo no B2AtuComD3
							dbSetOrder(3) 
							dbSeek(xFilial("SB8")+SD1->D1_COD+SD1->D1_LOCAL+SD1->D1_LOTECTL+IF(Rastro(SD3->D3_COD,"S"),SD1->D1_NUMLOTE,""))
						EndIf
						lContinua := .T.
					EndIf
					//-- Devolucao do produto para o armazem destino (Valorizado)
					If lContinua
						dbSelectArea("SB2")
						dbSetOrder(1)
						If !dbSeek(xFilial("SB2")+SD1->D1_COD+cLocTran)
							CriaSB2(SD1->D1_COD,cLocTran)
						EndIf
						//-- Desbloqueia o armazem de terceiro
						dbSelectArea("SB2")
						dbSetOrder(1)
						If dbSeek(xFilial("SB2")+SD1->D1_COD+cLocTran)
							RecLock("SB2",.F.)
							Replace B2_STATUS With "1"
							MsUnLock()
						EndIf
						RecLock("SD3",.T.)
						SD3->D3_FILIAL	:= xFilial("SD3")
						SD3->D3_COD		:= SD1->D1_COD
						SD3->D3_QUANT	:= SD1->D1_QUANT
						SD3->D3_TM		:= "499"
						SD3->D3_LOCAL	:= cLocTran
						SD3->D3_DOC		:= SD1->D1_DOC
						SD3->D3_EMISSAO	:= SD1->D1_DTDIGIT
						SD3->D3_NUMSEQ	:= SD1->D1_NUMSEQ
						SD3->D3_UM		:= SD1->D1_UM
						SD3->D3_GRUPO	:= SD1->D1_GRUPO
						SD3->D3_TIPO	:= SD1->D1_TP
						SD3->D3_SEGUM	:= SD1->D1_SEGUM
						SD3->D3_CONTA	:= SD1->D1_CONTA
						SD3->D3_CF		:= "DE6"
						SD3->D3_QTSEGUM	:= SD1->D1_QTSEGUM
						SD3->D3_USUARIO	:= SubStr(cUsuario,7,15)
						SD3->D3_CUSTO1	:= SD1->D1_CUSTO
						SD3->D3_CUSTO2	:= SD1->D1_CUSTO2
						SD3->D3_CUSTO3	:= SD1->D1_CUSTO3
						SD3->D3_CUSTO4	:= SD1->D1_CUSTO4
						SD3->D3_CUSTO5	:= SD1->D1_CUSTO5
						SD3->D3_NUMLOTE	:= SD1->D1_NUMLOTE
						SD3->D3_LOTECTL	:= SD1->D1_LOTECTL
						SD3->D3_DTVALID	:= SD1->D1_DTVALID
						SD3->D3_POTENCI	:= SD1->D1_POTENCI
						MsUnLock()
						dbSelectArea("SB2")
						B2AtuComD3({SD3->D3_CUSTO1,SD3->D3_CUSTO2,SD3->D3_CUSTO3,SD3->D3_CUSTO4,SD3->D3_CUSTO5})
						//-- Bloqueia o armazem de terceiro
						dbSelectArea("SB2")
						dbSetOrder(1)
						If dbSeek(xFilial("SB2")+SD1->D1_COD+cLocTran)
							RecLock("SB2",.F.)
							Replace B2_STATUS With "2"
							MsUnLock()
						EndIf
			    	EndIf
			    EndIf
			EndIf
		EndIf
	EndIf
//Retorno para o Armazem Original
ElseIf nTipo == 2 .And. lVldPE
	//-- Grava Flag que indica produto em transito
	RecLock("SD1",.F.)
	SD1->D1_TRANSIT := " "
	MsUnLock()
	//-- Desbloqueia o armazem de terceiro
	dbSelectArea("SB2")
	dbSetOrder(1)
	If dbSeek(xFilial("SB2")+SD1->D1_COD+cLocTran)
		RecLock("SB2",.F.)
		Replace B2_STATUS With "1"
		MsUnLock()
	EndIf
	//-- Requisita o produto do armazem de transito (Valorizado)
	dbSelectArea("SB2")
	dbSetOrder(1)
	If dbSeek(xFilial("SB2")+SD1->D1_COD+cLocTran)
		RecLock("SD3",.T.)
		SD3->D3_FILIAL	:= xFilial("SD3")
		SD3->D3_COD		:= SD1->D1_COD
		SD3->D3_QUANT	:= SD1->D1_QUANT
		SD3->D3_TM		:= "999"
		SD3->D3_OP		:= SD1->D1_OP
		SD3->D3_LOCAL	:= cLocTran
		SD3->D3_DOC		:= SD1->D1_DOC
		SD3->D3_EMISSAO	:= dDataBase
		SD3->D3_NUMSEQ	:= SD1->D1_NUMSEQ
		SD3->D3_UM		:= SD1->D1_UM
		SD3->D3_GRUPO	:= SD1->D1_GRUPO
		SD3->D3_TIPO	:= SD1->D1_TP
		SD3->D3_SEGUM	:= SD1->D1_SEGUM
		SD3->D3_CONTA	:= SD1->D1_CONTA
		SD3->D3_CF		:= "RE6"
		SD3->D3_QTSEGUM	:= SD1->D1_QTSEGUM
		SD3->D3_USUARIO	:= SubStr(cUsuario,7,15)
		SD3->D3_CUSTO1	:= SD1->D1_CUSTO
		SD3->D3_CUSTO2	:= SD1->D1_CUSTO2
		SD3->D3_CUSTO3	:= SD1->D1_CUSTO3
		SD3->D3_CUSTO4	:= SD1->D1_CUSTO4
		SD3->D3_CUSTO5	:= SD1->D1_CUSTO5
		SD3->D3_NUMLOTE	:= SD1->D1_NUMLOTE
		SD3->D3_LOTECTL	:= SD1->D1_LOTECTL
		SD3->D3_DTVALID	:= SD1->D1_DTVALID
		SD3->D3_POTENCI	:= SD1->D1_POTENCI
		MsUnLock()
		dbSelectArea("SB2")
		B2AtuComD3({SD3->D3_CUSTO1,SD3->D3_CUSTO2,SD3->D3_CUSTO3,SD3->D3_CUSTO4,SD3->D3_CUSTO5})
		MsUnLock()
		//-- Bloqueia o armazem de terceiro
		dbSelectArea("SB2")
		dbSetOrder(1)
		If dbSeek(xFilial("SB2")+SD1->D1_COD+cLocTran)
			RecLock("SB2",.F.)
			Replace B2_STATUS With "2"
			MsUnLock()
		EndIf
		lContinua := .T.
	EndIf
	//-- Devolucao do produto para o armazem destino (Valorizado)
	dbSelectArea("SB2")
	dbSetOrder(1)
	If lContinua .And. dbSeek(xFilial("SB2")+SD1->D1_COD+SD1->D1_LOCAL)
		RecLock("SD3",.T.)
		SD3->D3_FILIAL	:= xFilial("SD3")
		SD3->D3_COD		:= SD1->D1_COD
		SD3->D3_QUANT	:= SD1->D1_QUANT
		SD3->D3_TM		:= "499"
		SD3->D3_LOCAL	:= SD1->D1_LOCAL
		SD3->D3_DOC		:= SD1->D1_DOC
		SD3->D3_EMISSAO	:= dDataBase
		SD3->D3_NUMSEQ	:= SD1->D1_NUMSEQ
		SD3->D3_UM		:= SD1->D1_UM
		SD3->D3_GRUPO	:= SD1->D1_GRUPO
		SD3->D3_TIPO	:= SD1->D1_TP
		SD3->D3_SEGUM	:= SD1->D1_SEGUM
		SD3->D3_CONTA	:= SD1->D1_CONTA
		SD3->D3_CF		:= "DE6"
		SD3->D3_QTSEGUM	:= SD1->D1_QTSEGUM
		SD3->D3_USUARIO	:= SubStr(cUsuario,7,15)
		SD3->D3_CUSTO1	:= SD1->D1_CUSTO
		SD3->D3_CUSTO2	:= SD1->D1_CUSTO2
		SD3->D3_CUSTO3	:= SD1->D1_CUSTO3
		SD3->D3_CUSTO4	:= SD1->D1_CUSTO4
		SD3->D3_CUSTO5	:= SD1->D1_CUSTO5
		SD3->D3_NUMLOTE	:= SD1->D1_NUMLOTE
		SD3->D3_LOTECTL	:= SD1->D1_LOTECTL
		SD3->D3_DTVALID	:= SD1->D1_DTVALID
		SD3->D3_POTENCI	:= SD1->D1_POTENCI
		MsUnLock()
		dbSelectArea("SB2")
		B2AtuComD3({SD3->D3_CUSTO1,SD3->D3_CUSTO2,SD3->D3_CUSTO3,SD3->D3_CUSTO4,SD3->D3_CUSTO5})
		MsUnLock()
	EndIf
EndIf

//Ponto de entrada finalidades diversas na rotina de transferência de Armazem de Trânsito
If ExistBlock("MT103TRF")
	ExecBlock("MT103TRF",.F.,.F.,{nTipo,SD1->D1_FILIAL,SD1->D1_DOC,SD1->D1_SERIE,SD1->D1_FORNECE,SD1->D1_LOJA,SD1->D1_COD,SD1->D1_ITEM})
EndIf

RestArea(aAreaSB2)
RestArea(aAreaSD1)
RestArea(aAreaSD3)
RestArea(aAreaSF4)
RestArea(aAreaAnt)
Return Nil

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³A103Custo³ Autor ³ Edson Maricate         ³ Data ³27.01.2000³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Calcula o custo de entrada do Item                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³A103Custo(nItem)                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ExpN1 : Item da NF                                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ MATA103 , A103Grava()                                      ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function A103xCusto(nItem,aHeadSE2,aColsSE2,lTxNeg,aNFCompra)

Local aCusto     := {}
Local aRet       := {}
Local aSM0       := {}
Local nPos       := 0
Local nValIV     := 0
Local nX         := 0
Local nZ         := 0
Local nFatorPS2  := 1
Local nFatorCF2  := 1
Local nValPS2    := 0
Local nValCF2    := 0
Local nValNCalc  := 0
Local lCustPad   := .T.
Local uRet       := Nil
Local lCredICM   := SuperGetMV("MV_CREDICM", .F., .F.) // Parametro que indica o abatimento do credito de ICMS no custo do item, ao utilizar o campo F4_AGREG = "I"
Local lCredPis   := SuperGetMV("MV_CREDPIS", .F., .F.)
Local lCredCof   := SuperGetMV("MV_CREDCOF", .F., .F.)
Local lDEDICMA   := SuperGetMV("MV_DEDICMA", .F., .F.) // Efetua deducao do ICMS anterior nao calculado pelo sistema
Local lDedIcmAnt := .F.
Local lValCMaj   := !Empty(MaFisScan("IT_VALCMAJ",.F.)) // Verifica se a MATXFIS possui a referentcia IT_VALCMAJ
Local lValPMaj   := !Empty(MaFisScan("IT_VALPMAJ",.F.)) // Verifica se a MATXFIS possui a referentcia IT_VALCMAJ
Local nPosItOri  := GetPosSD1("D1_ITEMORI")
Local cCodFil    := ""
Local cAliasAux  := ""
Local lCustRon   := SuperGetMV("MV_CUSTRON",.F.,.T.)
Local lSimpNac   := MaFisRet(,"NF_SIMPNAC") == "1" .Or. MaFisRet(,"NF_UFORIGEM") == "EX"
Local nBaseCusto := 0
Local nValorImp  := 0 
Local nValorTribGen  := 0 
Local oItNfTribs as json
Local cOperacao  as character
Local cCredICMS  as character

Default lTxNeg := .F.

if __lTrbGen == NIL // declaracao no fonte backoffice.stock.calculationcost.tlpp
	__lTrbGen := FindFunction('backoffice.stock.calculationcost.CalcTribGen',.T.)
EndIF

//Calcula o percentual para credito do PIS / COFINS
If !Empty( SF4->F4_BCRDPIS )
	nFatorPS2 := SF4->F4_BCRDPIS / 100
EndIf

If !Empty( SF4->F4_BCRDCOF )
	nFatorCF2 := SF4->F4_BCRDCOF / 100
EndIf

nValPS2 := MaFisRet(nItem,"IT_VALPS2") * nFatorPS2
nValCF2 := MaFisRet(nItem,"IT_VALCF2") * nFatorCF2

If SF4->(FieldPos("F4_CRDICMA")) > 0 .And. !Empty(SF4->F4_CRDICMA)
	lDedIcmAnt := SF4->F4_CRDICMA == '1'
Else
	lDedIcmAnt := lDEDICMA
EndIf
If lDedIcmAnt
	nValNCalc := MaFisRet(nItem,"IT_ICMNDES")
EndIf

l103Auto := Type("l103Auto") <> "U" .And. l103Auto

If l103Auto .And. (nPos:= aScan(aAutoItens[nItem],{|x|Trim(x[1])== "D1_CUSTO" })) > 0
	aADD(aCusto,{	aAutoItens[nItem,nPos,2],;
					0.00,;
					0.00,;
					SF4->F4_CREDIPI,;
					SF4->F4_CREDICM,;
					MaFisRet(nItem,"IT_NFORI"),;
					MaFisRet(nItem,"IT_SERORI"),;
					SD1->D1_COD,;
					SD1->D1_LOCAL,;
					SD1->D1_QUANT,;
					If(SF4->F4_IPI=="R",MaFisRet(nItem,"IT_VALIPI"),0) ,;
					SF4->F4_CREDST,;
					MaFisRet(nItem,"IT_VALSOL"),;
					MaRetIncIV(nItem,"1"),;
					SF4->F4_PISCOF,;
					SF4->F4_PISCRED,;
					nValPS2 - (IIf(lValPMaj,MaFisRet(nItem,"IT_VALPMAJ"),0)),;
					nValCF2 - (IIf(lValCMaj,MaFisRet(nItem,"IT_VALCMAJ"),0)),;
					IIf(SF4->F4_ESTCRED>0,MaFisRet(nItem,"IT_ESTCRED"),0)   ,;
					IIf(lSimpNac,MaFisRet(nItem, "LF_CRDPRES"),0),;
					MaFisRet(nItem,"IT_VALANTI"),;
					If(nPosItOri > 0, aCols[nItem][nPosItOri], ""),;
					MaFisRet(nItem, "IT_VALFEEF"); // Issue DMANMAT01-21311 - Apropriação do imposto FEEF ao custo de entrada
				})
Else
	nValIV	:=	MaRetIncIV(nItem,"2")

	If SD1->D1_COD == Left(SuperGetMV("MV_PRODIMP"), Len(SD1->D1_COD))
		aADD(aCusto,{	MaFisRet(nItem,"IT_TOTAL")-IIF(cTipo=="P".Or.SF4->F4_IPI=="R",0,MaFisRet(nItem,"IT_VALIPI"))+MaFisRet(nItem,"IT_VALICM")+If((SF4->F4_CIAP=="S".And.SF4->F4_CREDICM=="S").Or.SF4->F4_ANTICMS=="1",0,MaFisRet(nItem,"IT_VALCMP"))-If(SF4->F4_INCSOL<>"N",MaFisRet(nItem,"IT_VALSOL"),0)-nValIV+IF(SF4->F4_ICM=="S" .And. SF4->F4_AGREG$'A|C',MaFisRet(nItem,"IT_VALICM"),0)+IF(SF4->F4_AGREG=='D' .And. SF4->F4_BASEICM == 0,MaFisRet(nItem,"IT_DEDICM"),0)-MaFisRet(nItem,"IT_CRPRESC")-MaFisRet(nItem,"IT_CRPREPR")+MaFisRet(nItem,"IT_VLINCMG")+IIf(!lCredPis .And. SF4->F4_AGRPIS=="2" .And. SF4->F4_AGREG$"I|B",nValPS2-(IIf(lValPMaj,MaFisRet(nItem,"IT_VALPMAJ"),0)),0)+IIf(!lCredCof .And. SF4->F4_AGRCOF=="2" .And. SF4->F4_AGREG$"I|B",nValCF2-(IIf(lValCMaj,MaFisRet(nItem,"IT_VALCMAJ"),0)),0) - nValNCalc,;
						MaFisRet(nItem,"IT_VALIPI"),;
						MaFisRet(nItem,"IT_VALICM"),;
						SF4->F4_CREDIPI,;
						SF4->F4_CREDICM,;
						MaFisRet(nItem,"IT_NFORI"),;
						MaFisRet(nItem,"IT_SERORI"),;
						SD1->D1_COD,;
						SD1->D1_LOCAL,;
						SD1->D1_QUANT,;
						If(SF4->F4_IPI=="R",MaFisRet(nItem,"IT_VALIPI"),0) ,;
						SF4->F4_CREDST,;
						MaFisRet(nItem,"IT_VALSOL"),;
						MaRetIncIV(nItem,"1"),;
						SF4->F4_PISCOF,;
						SF4->F4_PISCRED,;
						nValPS2 - (IIf(lValPMaj,MaFisRet(nItem,"IT_VALPMAJ"),0)),;
						nValCF2 - (IIf(lValCMaj,MaFisRet(nItem,"IT_VALCMAJ"),0)),;
						IIf(SF4->F4_ESTCRED>0,MaFisRet(nItem,"IT_ESTCRED"),0)   ,;
						IIf(lSimpNac,MaFisRet(nItem, "LF_CRDPRES"),0),;
						MaFisRet(nItem,"IT_VALANTI"),;
						If(nPosItOri > 0, aCols[nItem][nPosItOri], ""),;
						MaFisRet(nItem, "IT_VALFEEF"); // Issue DMANMAT01-21311 - Apropriação do imposto FEEF ao custo de entrada
					})
	Else
		oItNfTribs := JsonObject():new()
		cOperacao := ""
		cCredICMS := SF4->F4_CREDICM
		cCredST := SF4->F4_CREDST

		if __lTrbGen  .And. !Empty(SD1->D1_IDTRIB)
			cRetJson := backoffice.stock.calculationcost.CalcTribGen(nItem )
			cRet := oItNfTribs:FromJson(cRetJson)

			if oItNfTribs:HasProperty('Tributos')
				for nPos := 1 to len(oItNfTribs['Tributos'])
					If oItNfTribs['Tributos'][nPos]['idTOTVS']=="000021" // ICMS - Imposto sobre Circulação de Mercadorias e Serviços
						cOperacao := oItNfTribs['Tributos'][nPos]['Operacao']
						Exit
					EndIf
				next nPos

				//0=Sem Ação;1=Soma;2=Subtrai
				if cOperacao == "1" // SOMA = DEBITA
					cCredICMS := "N"
				elseif cOperacao == "2" // SUBTRAI = CREDITA
					cCredICMS := "S"
				EndIf

				//
				// COMO TRATAR ICMS RETIDO???? F4_CREDST e IT_VALSOL
				//
				cOperacao := ""
				for nPos := 1 to len(oItNfTribs['Tributos'])
					If oItNfTribs['Tributos'][nPos]['idTOTVS']=="000059" // TRIBUTAÇÃO MONOFÁSICA DE COMBUSTÍVEIS COBRADA ANTERIORMENTE
						cOperacao := oItNfTribs['Tributos'][nPos]['Operacao']
						Exit
					EndIf
				next nPos

				//0=Sem Ação;1=Soma;2=Subtrai
				if cOperacao == "1" // SOMA = CREDITA
					cCredST := "1"
				elseif cOperacao == "2" // SUBTRAI = RETIDO ST
					cCredST := "2"
				EndIf
			
				nValorTribGen := 0
				for nPos := 1 to len(oItNfTribs['Tributos'])
					If oItNfTribs['Tributos'][nPos]['idTOTVS']=="" // Tributo sem ID TOTVS
						if oItNfTribs['Tributos'][nPos]['Operacao'] == "1" // SOMA = DEBITA
							nValorTribGen := nValorTribGen + oItNfTribs['Tributos'][nPos]['Valor']
						elseif oItNfTribs['Tributos'][nPos]['Operacao'] == "2" // SUBTRAI = CREDITA			
							nValorTribGen := nValorTribGen - oItNfTribs['Tributos'][nPos]['Valor']
						EndIf
					EndIf
				next nPos

			EndIf
		EndIf

		nValorImp := MaFisRet(nItem,"IT_TOTAL")
		nBaseCusto := nBaseCusto + nValorImp

		nBaseCusto := nBaseCusto + nValorTribGen

		nValorImp :=  IIf(cTipo=="P".Or.SF4->F4_IPI=="R",0,MaFisRet(nItem,"IT_VALIPI"))
		nBaseCusto := nBaseCusto - nValorImp

		nValorImp := IIf((SF4->F4_CIAP=="S" .And. SF4->F4_CREDICM=="S") .Or. SF4->F4_ANTICMS=="1",0,MaFisRet(nItem,"IT_VALCMP"))
		nBaseCusto := nBaseCusto + nValorImp

		nValorImp := IIf(SF4->F4_INCSOL<>"N",MaFisRet(nItem,"IT_VALSOL"),0) 
		nBaseCusto := nBaseCusto - nValorImp

		nValorImp := nValIV
		nBaseCusto := nBaseCusto - nValorImp

		nValorImp := IIf(SF4->F4_ICM=="S" .And. SF4->F4_AGREG$'A|C',MaFisRet(nItem,"IT_VALICM"),0)
		nBaseCusto := nBaseCusto + nValorImp

		nValorImp := IIf(SF4->F4_AGREG=='D' .And. SF4->F4_BASEICM == 0,MaFisRet(nItem,"IT_DEDICM"),0)
		nBaseCusto := nBaseCusto + nValorImp

		nValorImp := MaFisRet(nItem,"IT_CRPRESC")
		nBaseCusto := nBaseCusto - nValorImp

		nValorImp := MaFisRet(nItem,"IT_CRPREPR")
		nBaseCusto := nBaseCusto - nValorImp

		nValorImp := MaFisRet(nItem,"IT_VLINCMG")
		nBaseCusto := nBaseCusto + nValorImp

		nValorImp := IIf(lCredICM .And. SF4->F4_AGREG$"I|B",MaFisRet(nItem,"IT_VALICM"),0)
		nBaseCusto := nBaseCusto - nValorImp

		nValorImp := IIf(SF4->F4_AGREG == "B",MaFisRet(nItem,"IT_VALSOL"),0)
		nBaseCusto := nBaseCusto - nValorImp

		nValorImp := IIf(!lCredPis .And. SF4->F4_AGRPIS=="2" .And. SF4->F4_AGREG$"I|B",nValPS2-(IIf(lValPMaj,MaFisRet(nItem,"IT_VALPMAJ"),0)),0)
		nBaseCusto := nBaseCusto + nValorImp

		nValorImp := IIf(!lCredCof .And. SF4->F4_AGRCOF=="2" .And. SF4->F4_AGREG$"I|B",nValCF2-(IIf(lValCMaj,MaFisRet(nItem,"IT_VALCMAJ"),0)),0) 
		nBaseCusto := nBaseCusto + nValorImp

		nValorImp := nValNCalc
		nBaseCusto := nBaseCusto - nValorImp

		aADD(aCusto,{ nBaseCusto	,;
						MaFisRet(nItem,"IT_VALIPI"),;
						MaFisRet(nItem,"IT_VALICM"),;
						SF4->F4_CREDIPI,;
						cCredICMS,;
						MaFisRet(nItem,"IT_NFORI"),;
						MaFisRet(nItem,"IT_SERORI"),;
						SD1->D1_COD,;
						SD1->D1_LOCAL,;
						SD1->D1_QUANT,;
						If(SF4->F4_IPI=="R",MaFisRet(nItem,"IT_VALIPI"),0),;
						cCredST ,; // SF4->F4_CREDST,;
						MaFisRet(nItem,"IT_VALSOL"),;
						MaRetIncIV(nItem,"1"),;
						SF4->F4_PISCOF,;
						SF4->F4_PISCRED,;
						nValPS2 - (IIf(lValPMaj,MaFisRet(nItem,"IT_VALPMAJ"),0)),;
						nValCF2 - (IIf(lValCMaj,MaFisRet(nItem,"IT_VALCMAJ"),0)),;
						IIf(SF4->F4_ESTCRED > 0,MaFisRet(nItem,"IT_ESTCRED"),0) ,;
						IIf(lSimpNac,MaFisRet(nItem, "LF_CRDPRES"),0),;
						Iif(SF4->F4_CREDST != '2' .And. SF4->F4_ANTICMS == '1',MaFisRet(nItem,"IT_VALANTI"),0),;
						If(nPosItOri > 0, aCols[nItem][nPosItOri], ""),;
						MaFisRet(nItem, "IT_VALFEEF"); // Issue DMANMAT01-21311 - Apropriação do imposto FEEF ao custo de entrada
					})

		if !Empty(SD1->D1_IDTRIB) .And. findFunction("backoffice.stock.calculationcost.HasRulesCust",.T.) .AND. FindClass("backoffice.stock.calculationcost.EntryCostCalculator")

			If backoffice.stock.calculationcost.HasRulesCust() // regras de custo esta habilitado
				oValuesTax := backoffice.stock.calculationcost.EntryCostCalculator():new()
				oValuesTax:loadTribGen(nItem) // Carrego o que esta em memoria

				nBaseCust1 := MaFisRet(nItem,"IT_TOTAL")

				If oValuesTax:getTax( "000022" )['por_cfgtrib'] == 0
					If  ! (cTipo=="P".Or.SF4->F4_IPI=="R")
						nVlrTributo := MaFisRet(nItem,"IT_VALIPI")
						nBaseCust1 := nBaseCust1 - nVlrTributo
					EndIf
				EndIf

				nValorImp := nValIV
				nBaseCust1 := nBaseCust1 - nValorImp

				nValorImp := nValNCalc
				nBaseCust1 := nBaseCust1 - nValorImp

				nValorImp := MaFisRet(nItem,"IT_VLINCMG")
				nBaseCust1 := nBaseCust1 - nValorImp

				nValorImp := IIf((SF4->F4_CIAP=="S" .And. SF4->F4_CREDICM=="S") .Or. SF4->F4_ANTICMS=="1",0,MaFisRet(nItem,"IT_VALCMP")) // IT_VALCMP = ICMS Complementar
				nBaseCust1 := nBaseCust1 + nValorImp

				If oValuesTax:getTax( "000021" )['por_cfgtrib'] == 0 // ICMS Não tem taxa pelo configurador	
					nValorImp := IIf(SF4->F4_ICM=="S" .And. SF4->F4_AGREG$'A|C',MaFisRet(nItem,"IT_VALICM"),0)
					nBaseCust1 := nBaseCust1 - nValorImp

					nValorImp := IIf(lCredICM .And. SF4->F4_AGREG$"I|B",MaFisRet(nItem,"IT_VALICM"),0)
					nBaseCust1 := nBaseCust1 - nValorImp

				EndIf
			
				If oValuesTax:getTax( "000056" )['por_cfgtrib'] == 0 // ICMSST Não tem taxa pelo configurador	
					nValorImp := IIf(SF4->F4_INCSOL<>"N",MaFisRet(nItem,"IT_VALSOL"),0) 
					nBaseCust1 := nBaseCust1 - nValorImp

					nValorImp := IIf(SF4->F4_AGREG == "B",MaFisRet(nItem,"IT_VALSOL"),0)
					nBaseCust1 := nBaseCust1 - nValorImp

				EndIf

				if oValuesTax:getTax( "000050" )['por_cfgtrib'] == 0 // Não tem DEDUÇÃO ICMS / ISS pelo configurador	
					nValorImp := IIf(SF4->F4_AGREG=='D' .And. SF4->F4_BASEICM == 0, MaFisRet(nItem,"IT_DEDICM"), 0)
					nBaseCust1 := nBaseCust1 - nValorImp
				EndIf

				if oValuesTax:getTax( "000029" )['por_cfgtrib'] == 0 // Não tem CREDITO PRESUMIDO pelo configurador	
					nValorImp := MaFisRet(nItem,"IT_CRPRESC")
					nBaseCust1 := nBaseCust1 - nValorImp
					nValorImp := MaFisRet(nItem,"IT_CRPREPR")
					nBaseCust1 := nBaseCust1 - nValorImp
				EndIf

				if oValuesTax:getTax( "000015" )['por_cfgtrib'] == 0 // TRIB_ID_PIS - Não tem PIS pelo configurador	
					nValPS2 := MaFisRet(nItem,"IT_VALPS2") * nFatorPS2 // TRIB_ID_PIS - PIS
				else
					nValPS2 := oValuesTax:getTax( "000015" )['valor']
				EndIf

				if oValuesTax:getTax( "000016" )['por_cfgtrib'] == 0 // TRIB_ID_COF - Não tem COFINS pelo configurador	
					nValCF2 := MaFisRet(nItem,"IT_VALCF2") * nFatorCF2 // TRIB_ID_COF - COFINS 
				else
					nValCF2 := oValuesTax:getTax( "000016" )['valor']
				EndIf
				
				nValorImp := IIf(!lCredPis .And. SF4->F4_AGRPIS=="2" .And. SF4->F4_AGREG$"I|B",nValPS2-(IIf(lValPMaj,MaFisRet(nItem,"IT_VALPMAJ"),0)),0)
				nBaseCust1 := nBaseCust1 - nValorImp

				nValorImp := IIf(!lCredCof .And. SF4->F4_AGRCOF=="2" .And. SF4->F4_AGREG$"I|B",nValCF2-(IIf(lValCMaj,MaFisRet(nItem,"IT_VALCMAJ"),0)),0) 
				nBaseCust1 := nBaseCust1 - nValorImp

				// ajuste no custo da mercadoria com os tributos genericos
				nValorImp := oValuesTax:compatibleTaxValue()
				nBaseCust1 := nBaseCust1+nValorImp

				aCusto := {}
				aADD(aCusto,{ nBaseCust1	,;
								MaFisRet(nItem,"IT_VALIPI"),;
								MaFisRet(nItem,"IT_VALICM"),;
								SF4->F4_CREDIPI,;
								cCredICMS,;
								MaFisRet(nItem,"IT_NFORI"),;
								MaFisRet(nItem,"IT_SERORI"),;
								SD1->D1_COD,;
								SD1->D1_LOCAL,;
								SD1->D1_QUANT,;
								If(SF4->F4_IPI=="R",MaFisRet(nItem,"IT_VALIPI"),0),;
								SF4->F4_CREDST,;
								MaFisRet(nItem,"IT_VALSOL"),;
								MaRetIncIV(nItem,"1"),;
								SF4->F4_PISCOF,;
								SF4->F4_PISCRED,;
								nValPS2 - (IIf(lValPMaj,MaFisRet(nItem,"IT_VALPMAJ"),0)),;
								nValCF2 - (IIf(lValCMaj,MaFisRet(nItem,"IT_VALCMAJ"),0)),;
								IIf(SF4->F4_ESTCRED > 0,MaFisRet(nItem,"IT_ESTCRED"),0) ,;
								IIf(lSimpNac,MaFisRet(nItem, "LF_CRDPRES"),0),;
								Iif(SF4->F4_CREDST != '2' .And. SF4->F4_ANTICMS == '1',MaFisRet(nItem,"IT_VALANTI"),0),;
								If(nPosItOri > 0, aCols[nItem][nPosItOri], ""),;
								MaFisRet(nItem, "IT_VALFEEF"),; // Issue DMANMAT01-21311 - Apropriação do imposto FEEF ao custo de entrada
								oValuesTax:getTaXRules(); // Os tributos genericos
								})
				FreeObj(oValuesTax)
			EndIf
		EndIf
	EndIf
EndIf

//Nao considerar o custo de uma entrada por devolucao ou bonificacao
If (SD1->D1_TIPO == "D" .And. SF4->F4_DEVZERO == "2") .Or. Iif(cPaisLoc == "BRA", (SF4->F4_BONIF == "S"),.F.)
	aRet := {{0,0,0,0,0}}
ElseIf SF4->F4_TRANFIL == "1" .And. lCustRon .And. SD1->D1_TIPO == "N" //-- Para transferencia entre filiais, obtem o custo da origem
	SA2->(DbSetOrder(1))
	SA2->(MsSeek(xFilial("SA2") + SD1->D1_FORNECE + SD1->D1_LOJA))

	If UsaFilTrf() //-- Procura pelo campo
		cCodFil := SA2->A2_FILTRF
	Else //-- Procura pelo CNPJ
		aSM0 := FwLoadSM0(.T.)
		If Len(aSM0) > 0
			nX := aScan(aSM0,{|x| AllTrim(x[SM0_CGC]) == AllTrim(SA2->A2_CGC)})
			If nX > 0
				cCodFil := aSM0[nX, SM0_CODFIL]
			EndIf
		EndIf
	EndIf

	If !Empty(cCodFil)
		cAliasAux := GetNextAlias()
		BeginSQL Alias cAliasAux
            SELECT
                D2_CUSTO1,
                D2_CUSTO2,
                D2_CUSTO3,
                D2_CUSTO4,
                D2_CUSTO5
            FROM
                %Table:SD2% SD2
            WHERE
                D2_FILIAL = %Exp:xFilial("SD2", cCodFil)%
                AND D2_DOC = %Exp:SD1->D1_DOC%
                AND D2_SERIE = %Exp:SD1->D1_SERIE%
                AND D2_ITEM = %Exp:CodeSomax1(SD1->D1_ITEM, FwTamSX3("D2_ITEM")[1])%
                AND SD2.%NotDel%
		EndSQL

		aRet := {{0,0,0,0,0}}

		If !(cAliasAux)->(Eof())
			aRet := {{(cAliasAux)->D2_CUSTO1, (cAliasAux)->D2_CUSTO2, (cAliasAux)->D2_CUSTO3, (cAliasAux)->D2_CUSTO4, (cAliasAux)->D2_CUSTO5}}
			// Permite agregar o valor do ICMS ST (Retido) ao custo de entrada das notas fiscais de entrada,
			// geradas pelo processo de Transferência de Filiais.
			If SF4->F4_TRFICST == '1'
				For nX := 1 to len(aRet[01])
					If aRet[01,nX]>0
						If nX == 1
							aRet[01,nX] := aRet[01,nX]+SD1->D1_ICMSRET
						Else
							aRet[01,nX] := aRet[01,nX]+xMoeda(SD1->D1_ICMSRET,1,nX,SD1->D1_DTDIGIT)
						EndIf
					EndIf
				Next nX
			EndIf
		EndIf
		(cAliasAux)->(DbCloseArea())
	EndIf
Else
	aRet := RetCusEnt(aDupl,aCusto,cTipo,,,aNFCompra,,,,,lTxNeg)
	If SF4->F4_AGREG == "N"
		For nX := 1 to Len(aRet[1])
			aRet[1][nX] := If(aRet[1][nX]>0,aRet[1][nX],0)
		Next nX
	EndIf
EndIf

//A103CUST - Ponto de entrada utilizado para manipular os valores
//           do custo de entrada nas 5 moedas.
If ExistBlock("A103CUST")
	uRet := ExecBlock("A103CUST",.F.,.F.,{aRet})
	If Valtype(uRet) == "A" .And. Len(uRet) > 0
		For nX := 1 To Len(uRet)
			For nZ:=1 To 5
				If Valtype(uRet[nX,nZ]) != "N"	//Uso o array original se retorno nao for numerico
					lCustPad := .F.
					Exit
				EndIf
			Next nZ
		Next nX
		If lCustPad
			aRet := aClone(uRet)
		EndIf
	EndIf
EndIf
 
FreeObj(oItNfTribs)

Return aRet[1]

/*/{Protheus.doc} CodeSoma1 
//TODO Converte o valor do campo D1_ITEM para o campo D2_ITEM. 
Devido ao tamanho dos campos serem diferente e ter o uso da função SOMA1()
@author reynaldo
@since 08/05/2018
@version 1.0
@return ${return}, ${return_description}
@param cItem, characters, Conteudo do campo D1_ITEM
@param nTamanho, numeric, Tamanho do campo D2_ITEM
@type function
/*/
Static Function CodeSomax1(cItem,nTamanho)
Local cResult
Local nLoop
Local nValor
		
nValor := DecodSoma1(cItem)

cResult := strzero(0,nTamanho)
For nLoop := 1 to nValor
	cResult := Soma1(cResult)
Next nLoop

Return cResult

/*/{Protheus.doc} A103xTrfIPI
Valida se e necessario alterar a Base do IPI conforme
implementacao do parametro MV_PBIPITR. 

@author Materiais
@since 11/09/2019
/*/
Function A103xTrfIPI(cTES, n)

Local nPosItem   := GetPosSD1("D1_ITEM")
Local nPosTES    := GetPosSD1("D1_TES")
Local nPosCod    := GetPosSD1("D1_COD")
Local nPosQtd    := GetPosSD1("D1_QUANT")
Local nPbIPITr   := SuperGetMv("MV_PBIPITR",.F.,0)
Local cFilOri    := ""
Local cNumPV     := ""
Local cItmPV     := ""
Local aAreaSF4   := {}
Local aAreaSC6   := {}
Local aItmSD2    := {}
Local lTesTrfOk  := .T.
Default cTES     := aCols[n,nPosTES]

If !Empty(MaFisScan("IT_PRCCF",.F.)) .And. nPbIPITr > 0
	aAreaSF4 := SF4->(GetArea())
	aAreaSC6 := SC6->(GetArea())
	SF4->(dbSetOrder(1))
	If SF4->(MsSeek(xFilial("SF4")+cTES)) .And. SF4->F4_TRANFIL == "1" .And. cTipo <> "D"
 		If A103TrFil(cTES,cTipo,ca100For,cLoja,cNFiscal,cSerie,aCols[n,nPosCod],aCols[n,nPosQtd],@aItmSD2,GdFieldGet('D1_LOTECTL',n),GdFieldGet('D1_NUMLOTE',n),.F.,aCols[n,nPosItem])
 			If Len(aItmSD2) > 0
	 			cFilOri := aItmSD2[aScan(aItmSD2,{|x| AllTrim(x[1])=="D2_FILIAL"})][2]
	 			cNumPV  := aItmSD2[aScan(aItmSD2,{|x| AllTrim(x[1])=="D2_PEDIDO"})][2]
	 			cItmPV  := aItmSD2[aScan(aItmSD2,{|x| AllTrim(x[1])=="D2_ITEMPV"})][2]
	 			dbSelectArea("SC6") 
	 			SC6->(dbSetOrder(1))
	 			If SC6->(FieldPos("C6_IPITRF")) > 0 .And. SC6->(MsSeek(cFilOri+cNumPV+cItmPV)) 
					MaFisAlt("IT_PRCCF",SC6->C6_IPITRF,n)
				EndIf
			EndIf
		EndIf
	ElseIf SF4->(MsSeek(xFilial("SF4")+cTES)) .And. SF4->F4_TRANFIL == "1" .And. cTipo == "D"
		lTesTrfOk := .F.
	EndIf
	RestArea(aAreaSF4)
	RestArea(aAreaSC6)
EndIf

Return lTesTrfOk

/*/{Protheus.doc} aOPBenefGrava
Exibe o dialog das OPs a serem apontadas referente ao beneficiamento, e grava o Array aOPBenef
@type function
@author vicente.gomes
@since 25/06/2024
/*/
Function aOPBenefGrava()
	Local lContinuaBN := nil
    //Fontes
    Local cFontUti    := "Tahoma"
    Local oFontBtn    := TFont():New(cFontUti,,-14)
    //Janela e componentes
    Local oDlgGrp
    Local oPanGrid
    Local oGetGrid
    Local aColunas    := {}
    Local cAliasTab   := "TMPBNF"
    //Tamanho da janela
    Local aTamanho    := MsAdvSize()
    Local nJanLarg    := aTamanho[3]
    Local nJanAltu    := aTamanho[4]
    
    //Cria a temporária
    oTempTable := FWTemporaryTable():New(cAliasTab)
        
    //Adiciona no array das colunas as que serão incluidas (Nome do Campo, Tipo do Campo, Tamanho, Decimais)
    aFields := {}
    aAdd(aFields, {"XXOP",     "C",   14, 0})
    aAdd(aFields, {"XXQUANTI", "N",   12, 2})
        
    //Define as colunas usadas, adiciona indice e cria a temporaria no banco
    oTempTable:SetFields( aFields )
    oTempTable:AddIndex("1", {"XXOP"} )
    oTempTable:Create()
    
    //Monta o cabecalho
    fMontaHead(cAliasTab,aColunas)
    
    //Montando os dados, eles devem ser montados antes de ser criado o FWBrowse
    FWMsgRun(, {|oSay| fMontDados(oSay,cAliasTab) }, STR0591, STR0592)
    
    //Criando a janela
    DEFINE MSDIALOG oDlgGrp TITLE STR0396 FROM 000, 000 TO nJanAltu, nJanLarg COLORS 0, 16777215 PIXEL
        //Botões
        @ 006, (nJanLarg/2-001)-(0052*01) BUTTON oBtnFech  PROMPT STR0593 SIZE 050, 018 OF oDlgGrp ACTION (lContinuaBN := .T.,oDlgGrp:End()) FONT oFontBtn PIXEL
    
        //Dados
        @ 024, 003 GROUP oGrpDad TO (nJanAltu/2-003), (nJanLarg/2-003) PROMPT STR0585 OF oDlgGrp COLOR 0, 16777215 PIXEL
        oGrpDad:oFont := oFontBtn
        oPanGrid := tPanel():New(033, 006, "", oDlgGrp, , , , RGB(000,000,000), RGB(254,254,254), (nJanLarg/2 - 13), (nJanAltu/2 - 45))
        oGetGrid := FWBrowse():New()
        oGetGrid:DisableFilter()
        oGetGrid:DisableConfig()
        oGetGrid:DisableReport()
        oGetGrid:DisableSeek()
        oGetGrid:DisableSaveConfig()
        oGetGrid:SetFontBrowse(oFontBtn)
        oGetGrid:SetAlias(cAliasTab)
        oGetGrid:SetDataTable()
        oGetGrid:SetEditCell(.T., {|| .T.}) 
        oGetGrid:lHeaderClick := .F.
        oGetGrid:AddLegend(cAliasTab + "->XXQUANTI == 0", "YELLOW", STR0588)
        oGetGrid:AddLegend(cAliasTab + "->XXQUANTI <  0", "RED",    STR0589)
        oGetGrid:AddLegend(cAliasTab + "->XXQUANTI >  0", "GREEN",  STR0590)
        oGetGrid:SetColumns(aColunas)
        oGetGrid:SetOwner(oPanGrid)
        oGetGrid:Activate()

    ACTIVATE MsDialog oDlgGrp CENTERED

	dbSelectArea(cAliasTab)
	dbGoTop()

	If lContinuaBN
		If (cAliasTab)->XXQUANTI > 0
			While (cAliasTab)->(!Eof())
				aAdd(aOPBenef, {(cAliasTab)->XXOP, (cAliasTab)->XXQUANTI})
				(cAliasTab)->(dbSkip())
			EndDo
		Else
			//Deleta a temporaria
    		oTempTable:Delete()
			Help(" ",1,"103BEN0ORNEG",,STR0586,1,0)
			Return .F.
		EndIf
    Else
		//Deleta a temporaria
    	oTempTable:Delete()
		Help(" ",1,"103BENNOQUANT",,STR0587,1,0)
		Return .F.
	EndIf

    //Deleta a temporaria
    oTempTable:Delete()
    
Return .T.

/*/{Protheus.doc} fMontaHead
Retorna as colunas para montagem da tabela temporária do Grid referente ao apontamento das OPs inseridas no beneficiamento.
@type function
@author vicente.gomes
@since 25/06/2024
/*/
Static Function fMontaHead(cAliasTab, aColunas)
    Local nAtual   := 0
    Local aHeadAux := {}
    
    //Adicionando colunas
    aAdd(aHeadAux, {"XXOP", 	STR0596, "C",   14,  0, "",                  .F.})
    aAdd(aHeadAux, {"XXQUANTI", STR0277, "N",   12,  2, "@E 999,999,999.99", .T.})
    
    //Percorrendo e criando as colunas
    For nAtual := 1 To Len(aHeadAux)
        oColumn := FWBrwColumn():New()
        oColumn:SetData(&("{|| " + cAliasTab + "->" + aHeadAux[nAtual][1] +"}"))
        oColumn:SetTitle(aHeadAux[nAtual][2])
        oColumn:SetType(aHeadAux[nAtual][3])
        oColumn:SetSize(aHeadAux[nAtual][4])
        oColumn:SetDecimal(aHeadAux[nAtual][5])
        oColumn:SetPicture(aHeadAux[nAtual][6])

        If aHeadAux[nAtual][7]
            oColumn:SetEdit(.T.)
            oColumn:SetReadVar(aHeadAux[nAtual][1])
        EndIf

        aAdd(aColunas, oColumn)
    Next
Return

/*/{Protheus.doc} fMontDados
Retorna os dados que serão inseridos da tabela temporária do Grid referente ao apontamento das OPs inseridas no beneficiamento.
@type function
@author vicente.gomes
@since 25/06/2024
/*/
Static Function fMontDados(oSay,cAliasTab)
    Local aAreaBN   := GetArea()
    Local nAtual  := 0
    Local cCodAtu := ""
    Local nQuanti := 0
	Local aOPsProcess := {}
	Local nPosOp	  := GetPosSD1("D1_OP")
    
    //Faz um laço de repetição
    For nAtual := 1 To Len(aCols)
		If aScan(aOPsProcess, aCols[nAtual][nPosOP]) == 0 .And. !Empty(aCols[nAtual][nPosOP])
			//Muda a mensagem na regua
			oSay:SetText(STR0594 + cValToChar(nAtual) + STR0595 + cValToChar(Len(aCols)) + "...")
	
			//Pega as variáveis que vão ser gravadas
			cCodAtu := aCols[nAtual][nPosOP]
	
			//Insere os dados na temporária
			RecLock(cAliasTab, .T.)
				(cAliasTab)->XXOP     := cCodAtu
				(cAliasTab)->XXQUANTI := nQuanti
			(cAliasTab)->(MsUnlock())

		EndIf
		aAdd(aOPsProcess, aCols[nAtual][nPosOP])
    Next
    
    RestArea(aAreaBN)
Return

/*/{Protheus.doc} A103EChSGO
Valida a existencia de campos na SGO
@author nilton.mioshi
@return lRet
/*/

Function A103EChSGO()

Local aCpoSGO   := {"GO_LOTECTL","GO_NUMLOTE","GO_ORDEM","GO_OPORIG","GO_SEQ"}
Local lRet		:= .T.
Local nI		:= 1

For nI := 1 To Len(aCpoSGO)
	If SGO->(FieldPos(aCpoSGO[nI])) == 0 
		lRet := .F.
		Exit
	Endif
Next nI

FwFreeArray(aCpoSGO)

Return lRet
