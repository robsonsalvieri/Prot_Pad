#INCLUDE "gema080.ch"
#INCLUDE "Protheus.ch"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ GMA080   ³ Autor ³ Reynaldo Miyashita    ³ Data ³ 06.04.2005 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Fechamento da Correcao monetaria por mes/ano para os titulos ³±±
±±³          ³ a receber provisorios. E a conversao dos titulos provisorio  ³±±
±±³          ³ do mes/ano para titulo normal(nota fiscal)                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Template GEM                                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Template Function GEMA080()
Local oDlg

Private oProcess

// Valida se tem licenças para o Template GEM = Gestao de Empreendimentos Imobiliarios							 
ChkTemplate("LOT")

Pergunte("GMA080",.F.) 

DEFINE MSDIALOG oDlg FROM  96,9 TO 330,552 TITLE OemToAnsi(STR0001) PIXEL //"Fechamento da CM"
DEFINE FONT oArialBold NAME "Arial" SIZE 0, -14 BOLD

@ 18, 6 TO 76, 267 LABEL "" OF oDlg  PIXEL
@ 29, 15 SAY OemToAnsi(STR0002) FONT oArialBold SIZE 250, 10 OF oDlg PIXEL  //"Este programa irá substituir os titulos a receber tipo "
@ 38, 15 SAY OemToAnsi(STR0003) FONT oArialBold SIZE 250, 10 OF oDlg PIXEL  //"Provisorio para Nota fiscal conforme o mes informado."
@ 48, 15 SAY OemToAnsi(STR0004) FONT oArialBold SIZE 250, 10 OF oDlg PIXEL  //"ATENÇÃO: após a execucao deste programa os titulos do mes e "
@ 58, 15 SAY OemToAnsi(STR0005) FONT oArialBold SIZE 250, 10 OF oDlg PIXEL  //"retrocedentes não será executado a correção monetária."

DEFINE SBUTTON oBtnParam FROM 80, 163 TYPE 5 ACTION pergunte("GMA080",.T.) ENABLE OF oDlg
oBtnParam:nWidth := 80
DEFINE SBUTTON FROM 80, 203 TYPE 1 ACTION { oProcess := MsNewProcess():New({|lEnd| T_GMFechaMes(StrZero(MV_PAR01,2),StrZero(MV_PAR02,4),"","zzzzzzzzzzzzzzz" )},STR0006) ; //"Processando o Fechamento da CM"
                                           ,oProcess:Activate() ,oDlg:End() ;
                                          } ENABLE OF oDlg
DEFINE SBUTTON FROM 80, 233 TYPE 2 ACTION oDlg:End() ENABLE OF oDlg
	
ACTIVATE MSDIALOG oDlg CENTER

Return .T.

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³GMFechaMes³ Autor ³ Reynaldo Miyashita    ³ Data ³17.04.2005  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Gera o fechamento da CM do mes referente do titulo, altera   ³±± 
±±³          ³ o status do tipo  de titulo de Provisorio ("PR ") para Nota  ³±± 
±±³          ³  Fiscal ("NF ")                                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³GMFechaMes()                                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ .T.                                                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³                                                              ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Template Function GMFechaMes(cMes,cAno,cContrDe,cContrAte)
Local oDlg 
Local oSBtnOk
Local oFont
Local oMemo
Local aArea        := GetArea()
Local aAreaTMP     := {}
Local aRecord      := {}
Local aAux         := {}
Local aContrProc   := {}
Local aNaoProc     := {}
Local nCntTit      := 0
Local nCount       := 0
Local nX           := 0
Local nQtdParcelas := 0
Local lContinua    := .T.
Local lSuccess     := .F.
Local cUltFech     := GetMV("MV_GMULTFE")
Local cTexto       := ""
Local cFilLIT      := xFilial("LIT")
Local cFilLIW      := xFilial("LIW")

// se naum encontrou o parametro
If ValType(cUltFech)=="L"
	// Help("",1,"GMA080001")
Else
	lContinua := .T.
	
	// senao tiver nada, assume um mes anterior ao atual
	If Empty(cUltFech)
		cUltFech := left(dtos(dDatabase),6)
		PutMV("MV_GMULTFE" ,cUltFech )
	EndIf
		
	// se naum foi informado os parametros de mes/ano	
	If cAno == replicate("0",4) .OR. cMes == replicate("0",2)
		// mes/ano nao foi informado
		Help("",1,"GMA080002")
		lContinua := .F.
	EndIf
		
	// Se o Mes/ano informado para o recalculo não for superior ao mes/ano do fechamento no parametro MV_GMULTFE
	// eh feito um aviso e pergunta se deseja continuar
	If lContinua .And. (cAno+cMes <= cUltFech)
		If LIT->(FieldPos("LIT_FECHAM"))>0 .And. LIT->(FieldPos("LIT_DTCM"))>0
			lContinua := MsgYesNo(STR0007 + cMes + "/" + cAno + STR0008 + CRLF ; //### //"O Mês/Ano: "###" informado é igual "
				      + STR0009+right(cUltFech,2)+"/"+Left(cUltFech,4) + "." + CRLF + STR0013,STR0014) // "ou inferior ao último fechamento: " "Deseja continuar o processo?", "Atenção"
		Else
	      HELP( "   ",1,"GMA080ERRO001",,STR0007 + cMes + "/" + cAno + STR0008 + CRLF ; //"O Mês/Ano: "###" informado é igual "
			      + STR0009+right(cUltFech,2)+"/"+Left(cUltFech,4) + ".",1,0) //"ou inferior ao último fechamento: "
			lContinua := .F.
		EndIf
	Endif
		
	If lContinua

		// inicializa as reguas
		oProcess:SetRegua1(LIT->(recCount()))
		oProcess:SetRegua2(0)
		
		// Contrato de venda - Cabecalho
		dbSelectArea("LIT")
		LIT->(dbSetOrder(2)) // LIT_FILIAL+LIT_NCONTR
		dbSeek(cFilLIT+cContrDe,.T.)
		While LIT->(!eof()) .And. (LIT->(LIT_FILIAL+LIT_NCONTR) <= cFilLIT+cContrAte)

			If LIT->(FieldPos("LIT_FECHAM"))>0 .And. LIT->(FieldPos("LIT_DTCM"))>0
				If !(Empty(LIT->LIT_FECHAM))

					If LIT->LIT_FECHAM >= cAno+cMes
						//data de fechamento do contrato superior ou igual a data de fechamento
						aAdd( aNaoProc , {LIT->LIT_NCONTR , STR0030+Substr(LIT->LIT_FECHAM,5,2)+"/"+Substr(LIT->LIT_FECHAM,1,4) }) //" não processado - contrato fechado até a data de (mm/aaaa)"#######
						LIT->(DbSkip())
						Loop
					Else
						//data de fechamento do contrato inferior em 2 ou mais meses da data de fechamento
						dAux := GMNextMonth(StoD(LIT->LIT_FECHAM+"01"),1)
						If dAux < StoD(cAno+cMes+"01")
							aAdd( aNaoProc , {LIT->LIT_NCONTR , STR0031+Substr(LIT->LIT_FECHAM,5,2)+"/"+Substr(LIT->LIT_FECHAM,1,4)+STR0032 }) //" não processado - data do ultimo fechamento do contrato("####") incompativel com o fechamento atual."
							LIT->(DbSkip())
							Loop
						EndIf
					EndIf

					If ( LIT->LIT_DTCM < cAno+cMes )
						aAdd( aNaoProc , {LIT->LIT_NCONTR , STR0033+cMes+"/"+cAno }) //" não processado - o contrato não possui a correção monetária de "###
						LIT->(DbSkip())
						Loop
					EndIf

				EndIf
			EndIf

			// Contrato em aberto
			// se mes/ano do contrato for inferior ao mes/ano de CM deve corrigir
			If LIT->LIT_STATUS == "1" .AND. StrZero(YEAR(LIT->LIT_EMISSAO),4)+StrZero(Month(LIT->LIT_EMISSAO),2) < cAno+cMes
				// atualiza as reguas
				oProcess:IncRegua1(STR0015 + LIT->LIT_NCONTR ) //"Contrato: "
				oProcess:IncRegua2("")
				nCntTit := 0
				nQtdParcelas := 0
				
				// busca a condicao de pagamento
				dbSelectArea("LJO")
				LJO->(dbSetOrder(1)) // LJO_FILIAL+LJO_NCONTR+LJO_ITEM
				dbSeek(xFilial("LJO")+LIT->LIT_NCONTR)
				While LJO->(!Eof()) .And. LJO->LJO_FILIAL+LJO->LJO_NCONTR==xFilial("LJO")+LIT->LIT_NCONTR
					// Quantidade total de titulos
					nQtdParcelas += LJO->LJO_NUMPAR
					LJO->(dbSkip())
				EndDo
				
				// Atualiza a regua de parcelas
				oProcess:SetRegua2(nQtdParcelas)
			  	
				// Detalhes do titulos a receber
				dbSelectArea("LIX")
				dbSetOrder(3) // LIX_FILIAL+LIX_NCONTR+LIX_PREFIX+LIX_NUM+LIX_PARCEL+LIX_TIPO
				dbSeek( xFilial("LIX")+LIT->LIT_NCONTR)
				While LIX->(!eof()) .AND. LIX->(LIX_FILIAL+LIX_NCONTR) == xFilial("LIX")+LIT->LIT_NCONTR

					// Titulos a receber
					dbSelectArea("SE1")
					dbSetOrder(1) // E1_FILIAL+ E1_PREFIXO+ E1_NUM+ E1_PARCELA+ E1_TIPO 
					If dbSeek(xFilial("SE1")+LIX->(LIX_PREFIX+LIX_NUM+LIX_PARCEL+LIX_TIPO))
					
						oProcess:IncRegua2(STR0016 + SE1->E1_PREFIXO +" "+SE1->E1_NUM+"-"+SE1->E1_PARCELA ) //"Parcela : "
					   
						// se tiver saldo, atualiza valor dos titulos
						If SE1->E1_SALDO > 0 
							// contador de prestacao recalculadas
							nCntTit++
						EndIf
					
						If left(dtos(SE1->E1_VENCTO),6) <= cAno+cMes .AND. SE1->E1_TIPO == MVPROVIS
							aRecord := {}
							
							// copia o registro da tabela SE1
							dbSelectArea("SE1")
							RecLock("SE1",.F.,.T.)
							For nCount := 1 to FCount()
								aAdd( aRecord ,FieldGet( nCount ) )
							Next nCount
						
							SE1->(dbDelete())
							SE1->(MsUnlock())
							
							RecLock("SE1",.T.)
								For nCount := 1 to Len(aRecord)
									SE1->(FieldPut( nCount ,aRecord[nCount] ))
								Next nCount
								SE1->E1_TIPO := MVNOTAFIS
							SE1->(MsUnlock())
						
							// copia o registro da tabela LIX
							aAreaTMP := LIX->(GetArea())
							aRecord  := {}
							dbSelectArea("LIX")
							RecLock("LIX",.F.,.T.)
								For nCount := 1 to FCount()
									aAdd( aRecord ,FieldGet( nCount ) )
								Next nCount
								LIX->(dbDelete())
							LIX->(MsUnlock())
						
							RecLock("LIX",.T.)
								For nCount := 1 to Len(aRecord)
									FieldPut( nCount ,aRecord[nCount] )
								Next nCount
								LIX->LIX_TIPO := MVNOTAFIS
							LIX->(MsUnlock())
							
							RestARea(aAreaTMP)

							// Valor de correcao monetaria dos titulos a receber
							dbSelectArea("LIW")
							dbSetOrder(1) // LIW_FILIAL+LIW_PREFIX+LIW_NUM+LIW_PARCEL+LIW_TIPO+LIW_DTREF
							If DbSeek( cFilLIW+SE1->E1_PREFIXO+SE1->E1_NUM+SE1->E1_PARCELA+MVPROVIS+cAno+cMes,.T. )
								aRecord := {}

								While cFilLIW+SE1->E1_PREFIXO+SE1->E1_NUM+SE1->E1_PARCELA+MVPROVIS==LIW->(LIW_FILIAL+LIW_PREFIX+LIW_NUM+LIW_PARCEL+LIW_TIPO)
									aAdd(aRecord,LIW->(RECNO()))
									LIW->(DbSkip())
								EndDo
							
								For nCount := 1 to Len(aRecord)
								
									LIW->(DbGoto(aRecord[nCount]))
									
									aAux := {}
									RecLock("LIW",.F.,.T.)
									For nX := 1 to FCount()
										aAdd( aAux ,FieldGet( nX ) )
									Next nX
									LIW->(dbDelete())
									LIW->(MsUnlock())

									RecLock("LIW",.T.)
									For nX := 1 to Len(aAux)
							   		FieldPut( nX ,aAux[nX] )
									Next nX
									LIW->LIW_TIPO := MVNOTAFIS
									LIW->(MsUnlock())
									
								Next nCount
							EndIf

						EndIf
					EndIf
					
					dbSelectArea("LIX")
					dbSkip()
					
				EndDo
				
				aAdd( aContrProc, {LIT->LIT_NCONTR ,nCntTit})

				If LIT->(FieldPos("LIT_FECHAM"))>0
					RecLock("LIT",.F.)
					LIT->LIT_FECHAM := cAno+cMes
					LIT->(MsUnlock())
				EndIf
					
			EndIf

			dbSelectArea("LIT")
			dbSkip()

		EndDo
				
		cTexto := STR0020 + CRLF //"Log do Fechamento de Mês(Titulos)"
		cTexto := cTexto + replicate("-",20) + CRLF + CRLF
		cTexto := cTexto + STR0021 + CRLF //"Parametros Utilizados: "
		cTexto := cTexto + STR0022 + cMes+"/"+cAno + CRLF //"Mês/Ano: "
		
		For nCount := 1 To Len(aContrProc)
			cTexto := cTexto + STR0015 + aContrProc[nCount][1] + STR0023 + Transform( aContrProc[nCount][2] ,"@E 999,999") + STR0024 + CRLF //"Contrato: "###" foram processadas "###" parcelas."
		Next nCount
		For nCount := 1 To Len(aNaoProc)
			cTexto := cTexto + STR0015 + aNaoProc[nCount][1] + aNaoProc[nCount][2] + CRLF //###### //"Contrato: "###" foram processadas "###" parcelas."
		Next nCount

		cTexto := cTexto + CRLF
		cTexto := cTexto + STR0025 + Transform( Len(aContrProc) ,"@E 999,999,999,999,999") + CRLF //"Total de Contratos processados: "
		cTexto := cTexto + STR0034 + Transform( Len(aNaoProc) ,"@E 999,999,999,999,999") //"Total de Contratos não processados: "
		
		__cFileLog := Criatrab(,.f.)+".LOG"
		lSuccess := MemoWrite(__cFileLog ,cTexto)
		DEFINE FONT oFont NAME "Arial" SIZE 6,14
		DEFINE MSDIALOG oDlg TITLE STR0026 From 3,0 to 340,417 PIXEL //"Fechamento de Mês Concluído"
		@ 5,5 GET oMemo  VAR cTexto MEMO SIZE 200,145 OF oDlg PIXEL 
		oMemo:bRClicked := {||AllwaysTrue()}
		oMemo:oFont:=oFont
		
		DEFINE SBUTTON oSBtnOk FROM 153,175 TYPE 1 ACTION oDlg:End() ENABLE OF oDlg PIXEL //Apaga
		oSBtnOk:SetFocus()
		ACTIVATE MSDIALOG oDlg CENTER
		          
		fErase(__cFileLog)

		If GetMV("MV_GMULTFE") != NIL
			PutMV("MV_GMULTFE",cAno+cMes)
		EndIf

	EndIf
		
EndIf

RestArea(aArea)
		
Return( .T. )

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³EstorFech ³ Autor ³ Daniel Tadashi Batori ³ Data ³02.10.2007  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Estorna o fechamento atual do contrato desde que os titulos  ³±± 
±±³          ³ alterados para NF nao tenhan sofrido qualquer tipo de baixa  ³±± 
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³EstorFech()                                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ .T.                                                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ chamdo pela rotina gema070                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Template Function EstorFech(cMes,cAno,cContrDe,cContrAte)
Local oDlg
Local oSBtnOk
Local oFont
Local oMemo
Local aArea        := GetArea()
Local aAux         := {}
Local aAux1        := {}
Local aRecord      := {}
Local aContrProc   := {}
Local aNaoProc     := {}
Local nCntTit      := 0
Local nCount       := 0
Local nX           := 0
Local nY           := 0
Local nQtdParcelas := 0
Local lContinua    := .T.
Local lSuccess     := .F.
Local cTexto       := ""
Local cFilLIT      := xFilial("LIT")
Local cFilLIX      := xFilial("LIX")
Local cFilLIW      := xFilial("LIW")
Local cMesAnt      := Left ( DtoS( GMPrevMonth( StoD(cAno+cMes+"01") , 1 ) ) , 6 )
	
// se naum foi informado os parametros de mes/ano	
If cAno == replicate("0",4) .OR. cMes == replicate("0",2)
	// mes/ano nao foi informado
	Help("",1,"GMA080002")
	RestArea(aArea)
	Return .T.
EndIf

If LIT->(FieldPos("LIT_FECHAM"))=0 .Or. LIT->(FieldPos("LIT_DTCM"))=0
	Aviso(STR0040 ,STR0041, {STR0042} ) // "Estorno do Fechamento"  ## Tabela LIT desatualizada.Entre em contato com o suporte. ## ok
EndIf


// inicializa as reguas
oProcess:SetRegua1(LIT->(recCount()))
oProcess:SetRegua2(0)
		
// Contrato de venda - Cabecalho
dbSelectArea("LIT")
LIT->(dbSetOrder(2)) // LIT_FILIAL+LIT_NCONTR
dbSeek(cFilLIT+cContrDe,.T.)
While LIT->(!eof()) .And. (LIT->(LIT_FILIAL+LIT_NCONTR) <= cFilLIT+cContrAte)

	If !(Empty(LIT->LIT_FECHAM))
		If !(LIT->LIT_FECHAM==(cAno+cMes))
			// data de fechamento do contrato diferente do parametro de estorno
			aAdd( aNaoProc , {LIT->LIT_NCONTR , STR0038}) //" não estornado - contrato com data de fechamento diferente do parametro de estorno"
			LIT->(DbSkip())
			Loop
		EndIf
	Else
		aAdd( aNaoProc , {LIT->LIT_NCONTR , STR0039 }) //" não processado - contrato sem data de fechamento"
		LIT->(DbSkip())
		Loop
	EndIf


	// Contrato em aberto
	If LIT->LIT_STATUS == "1"
		// atualiza as reguas
		oProcess:IncRegua1(STR0015 + LIT->LIT_NCONTR ) //"Contrato: "
		oProcess:IncRegua2("")
		nCntTit := 0
		nQtdParcelas := 0
			
		// busca a condicao de pagamento
		dbSelectArea("LJO")
		LJO->(dbSetOrder(1)) // LJO_FILIAL+LJO_NCONTR+LJO_ITEM
		dbSeek(xFilial("LJO")+LIT->LIT_NCONTR)
		While LJO->(!Eof()) .And. LJO->LJO_FILIAL+LJO->LJO_NCONTR==xFilial("LJO")+LIT->LIT_NCONTR
			// Quantidade total de titulos
			nQtdParcelas += LJO->LJO_NUMPAR
			LJO->(dbSkip())
		EndDo
				
		// Atualiza a regua de parcelas
		oProcess:SetRegua2(nQtdParcelas)
			  	
		// Detalhes do titulos a receber
		dbSelectArea("LIX")
		dbSetOrder(3) // LIX_FILIAL+LIX_NCONTR+LIX_PREFIX+LIX_NUM+LIX_PARCEL+LIX_TIPO
		dbSeek( cFilLIX+LIT->LIT_NCONTR )

		lContinua = .T.
		aRecord := {}
		
		While LIX->(!eof()) .AND.;
			LIX->(LIX_FILIAL+LIX_NCONTR) == cFilLIX+LIT->LIT_NCONTR .And.;
			lContinua = .T.

			// Titulos a receber
			dbSelectArea("SE1")
			dbSetOrder(1) // E1_FILIAL+E1_PREFIXO+E1_NUM+E1_PARCELA+E1_TIPO 
			If dbSeek(xFilial("SE1")+LIX->(LIX_PREFIX+LIX_NUM+LIX_PARCEL+LIX_TIPO))
					
				oProcess:IncRegua2(STR0016 + SE1->E1_PREFIXO +" "+SE1->E1_NUM+"-"+SE1->E1_PARCELA ) //"Parcela : "
					   
				If SE1->E1_SALDO > 0 
					// contador de prestacao recalculadas
					nCntTit++
				EndIf
					
				If left(dtos(SE1->E1_VENCREA),6) == cAno+cMes .And.;
					SE1->E1_TIPO == MVNOTAFIS
					
					If SE1->E1_SALDO == SE1->E1_VALOR
						// guarda o recno para depois apagar
						aAdd( aRecord , SE1->(RECNO()))
					Else
						lContinua = .F.
						aAdd( aNaoProc , {LIT->LIT_NCONTR , STR0043 }) // nao processado
					EndIf
				EndIf
					
			EndIf
			dbSelectArea("LIX")
			dbSkip()
					
		EndDo


		If lContinua == .T. .And. Len(aRecord)>0

			For nCount := 1 to Len(aRecord)
				SE1->(DbGoto(aRecord[nCount]))
				
				LIX->(DbSetOrder(1)) // LIX_FILIAL+LIX_PREFIX+LIX_NUM+LIX_PARCEL+LIX_TIPO
				LIX->(DbSeek( cFilLIX+SE1->(E1_PREFIXO+E1_NUM+E1_PARCELA+E1_TIPO) ) )

				LIW->(DbSetOrder(1)) // LIW_FILIAL+LIW_PREFIX+LIW_NUM+LIW_PARCEL+LIW_TIPO+LIW_DTREF
				LIW->(DbSeek( cFilLIW+SE1->(E1_PREFIXO+E1_NUM+E1_PARCELA+E1_TIPO)+cAno+cMes ))

				// apaga e cria o registro da tabela LIW do tipo PR
				dbSelectArea("LIW")
				aAux := {}
				While cFilLIW+SE1->(E1_PREFIXO+E1_NUM+E1_PARCELA)+SE1->E1_TIPO==LIW->(LIW_FILIAL+LIW_PREFIX+LIW_NUM+LIW_PARCEL+LIW_TIPO)
					aAdd(aAux,LIW->(RECNO()))
					LIW->(DbSkip())
				EndDo

				For nX := 1 to Len(aAux)
					LIW->(DbGoto(aAux[nX]))

					aAux1 := {}
					RecLock("LIW",.F.,.T.)
					For nY := 1 to FCount()
						aAdd( aAux1 ,FieldGet( nY ) )
					Next nY
					LIW->(dbDelete())
					LIW->(MsUnlock())

					RecLock("LIW",.T.)
					For nY := 1 to FCount()
			   		FieldPut( nY ,aAux1[nY] )
					Next nY
					LIW->LIW_TIPO := MVPROVIS
					LIW->(MsUnlock())
				Next nCount

				// apaga e cria o registro da tabela SE1 do tipo PR
				aAux := {}
				DbSelectArea("SE1")
				RecLock("SE1",.F.,.T.)
				For nX := 1 to FCount()
					aAdd( aAux ,FieldGet( nX ) )
				Next nX
				SE1->(dbDelete())
				SE1->(MsUnlock())
				
				RecLock("SE1",.T.)
				For nX := 1 to FCount()
					SE1->(FieldPut( nX ,aAux[nX] ))
				Next nX
				SE1->E1_TIPO := MVPROVIS
				SE1->(MsUnlock())

				// apaga e cria o registro da tabela LIX do tipo PR
				aAux := {}
				dbSelectArea("LIX")
				RecLock("LIX",.F.,.T.)
				For nX := 1 to FCount()
					aAdd( aAux ,FieldGet( nX ) )
				Next nX
				LIX->(dbDelete())
				LIX->(MsUnlock())
						
				RecLock("LIX",.T.)
				For nX := 1 to FCount()
					FieldPut( nX ,aAux[nX] )
				Next nX
				LIX->LIX_TIPO := MVPROVIS
				LIX->(MsUnlock())

			Next nCount

			aAdd( aContrProc, {LIT->LIT_NCONTR ,nCntTit})
	
			RecLock("LIT",.F.)
			LIT->LIT_FECHAM := cMesAnt
			LIT->(MsUnlock())			

		EndIf

	EndIf
	LIT->(DbSkip())
EndDo
				


				
		cTexto := STR0020 + CRLF //"Log do Estorno de Fechamento"
		cTexto := cTexto + replicate("-",20) + CRLF + CRLF
		cTexto := cTexto + STR0021 + CRLF //"Parametros Utilizados: "
		cTexto := cTexto + STR0022 + cMes+"/"+cAno + CRLF //"Mês/Ano: "
		cTexto := cTexto + STR0035 + cContrDe + STR0036 + cContrAte + "'" + CRLF + CRLF //### //"Filtro de Contratos: '"###"' a '"
		
		For nCount := 1 To Len(aContrProc)
			cTexto := cTexto + STR0015 + aContrProc[nCount][1] + STR0023 + Transform( aContrProc[nCount][2] ,"@E 999,999") + STR0024 + CRLF //"Contrato: "###" foram processadas "###" parcelas."
		Next nCount
		For nCount := 1 To Len(aNaoProc)
			cTexto := cTexto + STR0015 + aNaoProc[nCount][1] + aNaoProc[nCount][2] + CRLF //###### //"Contrato: "###" foram processadas "###" parcelas."
		Next nCount

		cTexto := cTexto + CRLF
		cTexto := cTexto + STR0025 + Transform( Len(aContrProc) ,"@E 999,999,999,999,999") + CRLF //"Total de Contratos processados: "
		cTexto := cTexto + STR0034 + Transform( Len(aNaoProc) ,"@E 999,999,999,999,999") //"Total de Contratos não processados: "
		
		__cFileLog := Criatrab(,.f.)+".LOG"
		lSuccess := MemoWrite(__cFileLog ,cTexto)
		DEFINE FONT oFont NAME "Arial" SIZE 6,14
		DEFINE MSDIALOG oDlg TITLE STR0037 From 3,0 to 340,417 PIXEL //"Estorno do Fechamento Concluído"
		@ 5,5 GET oMemo  VAR cTexto MEMO SIZE 200,145 OF oDlg PIXEL 
		oMemo:bRClicked := {||AllwaysTrue()}
		oMemo:oFont:=oFont
		
		DEFINE SBUTTON oSBtnOk FROM 153,175 TYPE 1 ACTION oDlg:End() ENABLE OF oDlg PIXEL //Apaga
		oSBtnOk:SetFocus()
		ACTIVATE MSDIALOG oDlg CENTER
		          
		fErase(__cFileLog)


RestArea(aArea)
		
Return( .T. )
