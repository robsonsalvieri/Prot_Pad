#Include "QIEM010.CH"
#Include "TOTVS.CH"

#Define PROD_ORIGEM     1
#Define REV_ORIGEM      2
#Define PROD_DESTINO    3
#Define REV_DESTINO     4
#Define ORIGEM_DESC     5
#Define DESC_DESTINO    6
#Define COPIA_ARQUIVOS  7

/*/{Protheus.doc} QIEM010AuxClass
Classe agrupadora de métodos auxiliares do QIEM010
@author Jefferson Possidonio
@since 03/10/2024
@version 1.0
/*/
CLASS QIEM010AuxClass FROM LongNameClass

	METHOD new() Constructor
	METHOD criaTelaParametrosCopia()
	METHOD validaDescricaoProduto()

ENDCLASS

/*/{Protheus.doc} New
Construtor da Classe
@author Jefferson Possidonio
@since 03/10/2024
@version 1.0
/*/
Method New() CLASS QIEM010AuxClass
   
Return Self
	
/*/{Protheus.doc} validaDescricaoProduto
Método que valida os campos obrigatório ao confirmar o formulário
@author Jefferson Possidonio
@since 03/10/2024
@version 1.0
/*/
METHOD validaDescricaoProduto() CLASS QIEM010AuxClass

	Local cOriSel := Nil
	Local cDesSel := Nil
	Local lRet    := .T.

	cOriSel := MV_PAR05
	cDesSel := MV_PAR06

	If Empty(cOriSel) .And. !("MV_PAR" $ ReadVar())
		// STR0019 - "Campo Descrição do Produto Destino Vazio."
		// STR0020 - "Selecione uma opção valida para o campo Descrição do Produto Destino."
		Help("",1,"HELP",,STR0019,1,0,,,,,,{STR0020})
		lRet := .F.

	ElseIf Empty(cDesSel)
		// STR0021 - "Campo Descrição Vazio."
		// STR0022 - "Preencha corretamente o campo Descrição."
		Help("",1,"HELP",,STR0021,1,0,,,,,,{STR0022})
		lRet := .F.

	Endif

Return(lRet)

/*/{Protheus.doc} criaTelaParametrosCopia
Monta tela de parametros para a cópia da especificação completa, respeitando o layout original do QIEM010OLD
@author brunno.costa
@since 26/11/2025
@version 1.0
@return lConfirm, lógico, indica se confirmou a cópia
/*/
Method criaTelaParametrosCopia() CLASS QIEM010AuxClass

	Local aItensDesc := {"", STR0001, STR0013, STR0014} //"Informado" ### "Produto Origem " ### "Produto Destino"
	Local aPergs     := {}
	Local cF3ProdDes := ""
	Local dVigRev    := dDataBase
	Local lConfirm   := .F.
	Local lQEM10F3   := ExistBlock("QEM10F3")
	Local lTemQQO    := !Empty(FWX2Nome( "QQO" ))
	Local nTamDesc   := GetSx3Cache("B1_DESC" , "X3_TAMANHO")
	Local nTamProd   := GetSx3Cache("B1_COD" , "X3_TAMANHO")
	Local nTamRev    := GetSx3Cache("QE6_REVI", "X3_TAMANHO")

	nTamDesc := Iif(ValType(nTamDesc) == "N" .And. nTamDesc > 0, nTamDesc, TamSX3("B1_DESC")[1])
	nTamProd := Iif(ValType(nTamProd) == "N" .And. nTamProd > 0, nTamProd, TamSX3("B1_COD")[1])
	nTamRev  := Iif(ValType(nTamRev ) == "N" .And. nTamRev  > 0, nTamRev , Len("00"))

	Private aItem     := aItensDesc
	Private aParamDup := {}
	Private cCadastro := STR0025 //"Especificação de Produtos - Copiar"
	Private cDesPro   := Space(nTamDesc)
	Private cOriDes   := Iif(IsInCallStack("Q010Dup") .And. !Empty(MV_PAR05), MV_PAR05, aItensDesc[1]  )
	Private cCopArqu  := Iif(IsInCallStack("Q010Dup") .And. !Empty(MV_PAR07), MV_PAR07, STR0026        ) //"Sim"
	Private cProdDes  := Iif(IsInCallStack("Q010Dup") .And. !Empty(MV_PAR03), MV_PAR03, Space(nTamProd))
	Private cProdOri  := Iif(IsInCallStack("Q010Dup")                       , MV_PAR01, Space(nTamProd))
	Private cRevDes   := Iif(IsInCallStack("Q010Dup") .And. !Empty(MV_PAR04), MV_PAR04, Space(nTamRev) )
	Private cRevOri   := Iif(IsInCallStack("Q010Dup")                       , MV_PAR02, Space(nTamRev) )
	Private oSelf     := Self

	QE6->(dbSetorder(1))
	SB1->(dbSetOrder(1))

	cF3ProdDes := Iif(lQEM10F3, ExecBlock("QEM10F3", .F., .F.), "QE6")

	/* 	[1]: Tipo do parâmetro  (numérico) -> 1 - MsGet
		[2]: Descrição
		[3]: String contendo o inicializador do campo
		[4]: String contendo a Picture do campo
		[5]: String contendo a validação
		[6]: Consulta F3
		[7]: String contendo a validação When
		[8]: Tamanho do MsGet
		[9]: Flag .T./.F. Parâmetro Obrigatório ? */

	aAdd(aPergs, {1, STR0005, cProdOri, "@!"      , 'QIE010UpIn()'                  , "QE7"        , "" , nTamProd * 3, .T.             }) //"Produto Origem ?"
	aAdd(aPergs, {1, STR0006, cRevOri , "@!"      , 'A010ExProd("O")'               , ""           , "" , nTamRev  * 3, .T.             }) //"Revisão Origem ?"
	aAdd(aPergs, {1, STR0007, cProdDes, "@!"      , '.T.'                           , cF3ProdDes   , "" , nTamProd * 3, .T.             }) //"Produto Destino ?"
	aAdd(aPergs, {1, STR0008, cRevDes , "@!"      , 'A010ExProd("D")'               , ""           , "" , nTamRev  * 3, .T.             }) //"Revisão Destino ?"
	aAdd(aPergs, {2, STR0010, cOriDes , aItensDesc, 100                             , ""           , .T., "QIE010VERIF(aItem,MV_PAR05)" }) //"Quanto a Descrição ?"
	aAdd(aPergs, {1, STR0009, cDesPro , "@!"      , 'oSelf:validaDescricaoProduto()', ""           , "AllTrim(MV_PAR05) == AllTrim('" + STR0001 + "')" , nTamDesc * 2, .T. }) //"Descrição do Produto Destino ?"
	If lTemQQO
		aAdd(aPergs, {2, STR0028, cCopArqu, {STR0026, STR0027}  , 100         , "" , .T., ""                                                }) //"Copia Arquivos da Especificação ?" # Sim # Não
	EndIf

	aParamDup := Array(Len(aPergs))

	If ParamBox(aPergs, STR0004, @aParamDup, { || A010ExProd("O", .T.) .And. A010ExProd("D", .T.) .And. oSelf:validaDescricaoProduto() },, .T.,,, NIL, "QIEM010", .F., .F.) //"Parâmetros"

		cProdOri := Upper(aParamDup[PROD_ORIGEM ])
		cRevOri  := Upper(aParamDup[REV_ORIGEM  ])
		cProdDes := Upper(aParamDup[PROD_DESTINO])
		cRevDes  := Upper(aParamDup[REV_DESTINO ])
		cOriDes  := Iif(ValType(aParamDup[ORIGEM_DESC]) == "C", aParamDup[ORIGEM_DESC], aItensDesc[1])
		cDesPro  := AllTrim(Iif(ValType(aParamDup[DESC_DESTINO]) == "C", aParamDup[DESC_DESTINO], ""))
		cCopArqu := IIF(lTemQQO, aParamDup[COPIA_ARQUIVOS ], STR0027) // "Não"

		dVigRev  := A010CkProd()
		lConfirm := .T.

		// Ponto de Entrada para validar ou nao a Duplicado da Especificacao do Produto
		If Existblock("QIEVALDUP")
			lConfirm := Execblock("QIEVALDUP", .F. , .F. , {cProdOri,cRevOri,cProdDes,cRevDes} )
		Endif

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Confirma a duplicacao do Produto										  ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If lConfirm 
			QIEDupEsp(cProdOri,cRevOri,cProdDes,cRevDes,cDesPro,dVigRev)

			QE6->(DbSetOrder(3))
			QE6->(DbSeek(xFilial("QE6") + cProdDes + cRevDes))
		EndIf
	EndIf

Return lConfirm

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o	 ³ QIEM010	³ Autor ³ Marcelo Pimentel      ³ data ³ 19/05/98 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Duplica Especifica‡oes       			  	              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso		 ³ SIGAQIE													  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ STR		 ³ Ultimo utilizado: 032                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³         ATUALIZACOES SOFRIDAS DESDE A CONSTRU€AO INICIAL.             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Programador ³ Data   ³ BOPS ³  Motivo da Alteracao                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Paulo Emidio³20/04/01³META  ³Gravacao do B1_TIPOCQ quando o produto for³±±
±±³            ³        ³      ³cadastrado no SB1.						  ³±±
±±³			   ³        ³      ³Implementacao do parametro MV_QRASTRO     ³±±
±±³Robson Ramir³14/05/01³META  ³Remodelamento da Tela da Duplicacao de Pro³±±
±±³            ³        ³      ³dutos.									  ³±±
±±³Robson Ramir³15/05/01³008439³Implementacao opcao para selecionar a ori-³±±
±±³			   ³		³	   ³gem da Descricao, se a mesma sera informa-³±±
±±³			   ³        ³      ³da, ou originada do Cadastro de produtos  ³±±
±±³			   ³        ³      ³ou Especificacao. 						  ³±±
±±³Cleber Souza³14/05/03³064155³Sugere numero da proxima revisao automati-³±± 
±±³			   ³        ³      ³camente na digitacao do produto.          ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Function QIEM010()
	Local oQIEM010AuxClass := QIEM010AuxClass():New()
Return oQIEM010AuxClass:criaTelaParametrosCopia()

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÂÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ QIEDupEsp   ³ Autor ³ Paulo Emidio de Barros³Data³14/04/04 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÁÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Duplica a Especificacao de Produtos						  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ QIEDupEsp(EXPC1,EXPC2,EXPC3,EXPC4,EXPC5,EXPD1)		  	  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³	EXPC1 = Produto Origem									  ³±±
±±³		  	 ³	EXPC2 =	Revisao Origem									  ³±±
±±³			 ³	EXPC3 =	Produto Destino									  ³±±
±±³			 ³	EXPC4 =	Revisao Destino									  ³±±
±±³			 ³	EXPC5 =	Descricao Destino								  ³±±
±±³			 ³	EXPD1 =	Vigencia da Especificacao						  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ SIGAQIE													  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function QIEDupEsp(cProdOri,cRevOri,cProdDes,cRevDes,cDesPro,dVigRev)

	Local aArea     := {}
	Local aAreaQE6  := {}
	Local aArq      := {}
	Local aEnsaios  := {}
	Local bCConQA2H := Nil
	Local bCConQE6  := Nil
	Local bCConQE7  := Nil
	Local bCConQE8  := Nil
	Local bCConQE9  := Nil
	Local bCConQQO  := Nil
	Local bCRepQA2H := Nil
	Local bCRepQE6  := Nil
	Local bCRepQE7  := Nil
	Local bCRepQE8  := Nil
	Local bCRepQE9  := Nil
	Local bCRepQQO  := Nil
	Local cDesEsp   := Space(TamSX3("QE6_DESCES")[1])
	Local cDesIng   := Space(TamSX3("QE6_DESCIN")[1])
	Local cEspecH   := ""
	Local cKeyNewH  := ""
	Local cLocPad   := ""
	Local cRastro   := ""
	Local cRevPesq  := QA_UltRevEsp(cProdDes,dDataBase,.F.,.T.,"QIE")
	Local cTipoCQ   := ""
	Local lAltProd  := If(GetMv("MV_QALTPRO",.F.,"1") == "1",.T.,.F.) //Indica se o produto destino tera o camp Tipo C.Q. alterado pra Q na duplicacao
	Local lAtuSB1   := .T.
	Local lQEPM10B1 := ExistBlock("QEPM10B1") // Ponto de Entrada utilizado para verificar se atualiza o arquivo SB1.                         
	Local lRetSB1   := .F.
	Local lVolta    := .T.
	Local nAscan    := Ascan(aItem,cOriDes)
	Local nI        := 0
	Local nRec      := 0

	QE6->(dbSetorder(1))
	If nAscan == 3	
		If QE6->(DbSeek(xFilial("QE6")+cProdOri+Inverte(cRevOri)))
			cDesEsp := QE6->QE6_DESCES
			cDesIng := QE6->QE6_DESCIN
		EndIf	
	ElseIf nAscan == 4
		If QE6->(DbSeek(xFilial("QE6")+cProdDes+Inverte(cRevPesq)))
			cDesEsp := QE6->QE6_DESCES
			cDesIng := QE6->QE6_DESCIN
		Endif
	Endif

	//Caso a data da vigencia nao seja informada, a mesma sera gerada.
	If dVigRev == NIL
		dVigRev := A010CkProd()
	EndIf

	If QE6->(dbSeek(xFilial("QE6")+cProdOri+Inverte(cRevOri)))
		nRec := Recno()
		// Atualiza o SB1(Cadastro de Produtos) se o mesmo nao existir
		cRastro := "N"
		cLocPad := "01"
		SB1->(dbSetOrder(1))
		If SB1->(dbSeek(xFilial("SB1")+cProdOri))
			If Rastro(cProdOri)
				cRastro := If(GetMv("MV_RASTRO")=="S",GetMv("MV_QRASTRO"),"")
			Else
				cRastro := "N"
			EndIf
			cTipoCQ := SB1->B1_TIPOCQ
			cLocPad := SB1->B1_LOCPAD
		EndIf	

		lAtuSB1 := If(lQEPM10B1, ExecBlock("QEPM10B1",.F.,.F.), lAtuSB1)	
		If lAtuSB1
			lRetSB1 := QIEAtuSB1(.T.,cProdDes,cDesPro,cRastro,cLocPad,cTipoCQ)
			If lAltProd
				If RetArqProd(cProdDes)
					If AllTrim(SB1->B1_COD) <> "Q"
						RecLock("SB1",.F.)
							If lAltProd
								SB1->B1_TIPOCQ := "Q"
							Else
								SB1->B1_TIPOCQ:= cTipoCQ
							Endif
						MsUnLock()
					EndIf
				ElseIf AllTrim(RetFldProd(SB1->B1_COD,"B1_TIPOCQ")) <> "Q"
					aArea := GetArea()
					RecLock("SBZ",.F.)
						If lAltProd
							SBZ->BZ_TIPOCQ := "Q"
						Else
							SBZ->BZ_TIPOCQ:= "M"
						Endif
					MsUnLock()
					RestArea(aArea)
				EndIf
			EndIf
				// Verifica se o Produto ja esta cadastrado
				If QE6->(dbSeek(xFilial("QE6")+cProdDes+Inverte(cRevDes)))
					Help(" ",1,"M010EXIREV")	// "Produto/Revisao já cadastrados."
					Return(Nil)
				EndIf
				DbGoTo(nRec)

				// Inicializa Array
				aArq := {}
					
					
				// Chave de ligacao do QE6
				cEspecH	 := "QIEA010 "
				aAreaQE6 := QE6->(GetArea())
				cKeyNewH := QA_NewChave("QE6",2)
				RestArea(aAreaQE6)   

				bCrepQE6 := {||QE6->QE6_PRODUT  := cProdDes	   	    ,;
								QE6->QE6_REVI   := cRevDes	  	    ,;
								QE6->QE6_DESCPO := cDesPro	        ,;
								QE6->QE6_DESCES := cDesEsp	        ,;
								QE6->QE6_DESCIN := cDesIng	        ,;
								QE6->QE6_REVINV := Inverte(cRevDes) ,;
								QE6->QE6_CHAVE  := cKeyNewH         ,;
								QE6->QE6_DTCAD  := dDataBase}
									
				bCconQE6 := {||!Eof() .and. xFilial("QE6") == QE6_FILIAL .and.;
								QE6_PRODUT == cProdOri .and. QE6_REVI == cRevOri}
					
				Aadd(aArq,{"QE6",cProdOri+Inverte(cRevOri),bCRepQE6,bCConQE6,1})
					

				// Condicoes para QA2 - Historico
				QE6->(dbSeek(xFilial("QE6")+cProdOri+Inverte(cRevOri)))
					
				cKeyH 	:= QE6->QE6_CHAVE
				cEspecH	:= "QIEA010 "

				bCRepQA2H := {||QA2->QA2_CHAVE := cKeyNewH}
				bCConQA2H := {||!QA2->(eof()) .and. xFilial("QA2") == QA2_FILIAL .and.;
								QA2_CHAVE == cKeyh .and. QA2_ESPEC == cEspecH}
															
				Aadd(aArq,{"QA2",cEspecH+cKeyH,bCRepQA2H,bCConQA2H,1})
					

				// Condicoes para QE7
				QE7->(dbSetOrder(1))
				QE7->(dbSeek(xFilial("QE7")+cProdOri+cRevOri))
					
				bCrepQE7 := {||QE7->QE7_PRODUT := cProdDes,QE7->QE7_REVI := cRevDes}
					
				bCconQE7 := {||QE7->(!Eof()) .and. xFilial("QE7") == QE7->QE7_FILIAL .and.;
								QE7->QE7_PRODUT == cProdOri .and. QE7->QE7_REVI	 == cRevOri}
													
				Aadd(aArq,{"QE7",cProdOri+cRevOri,bCRepQE7,bCConQE7,1})
					

				// Condicoes para QE8
				bCrepQE8 := {||QE8->QE8_PRODUT := cProdDes,QE8->QE8_REVI := cRevDes}
						
				bCconQE8 := {||!QE8->(Eof()) .and. xFilial("QE8") == QE8->QE8_FILIAL .and.;
								QE8->QE8_PRODUT == cProdOri .and. QE8->QE8_REVI == cRevOri}
						
				Aadd(aArq,{"QE8",cProdOri+cRevOri,bCRepQE8,bCConQE8,1})
						

				// Condicoes para QE9
				bCrepQE9 := {||QE9->QE9_PRODUT := cProdDes,;
							   QE9->QE9_REVI   := cRevDes}
										
				bCconQE9 := {||!QE9->(eof()) .and. xFilial("QE9") == QE9->QE9_FILIAL .and.;
								QE9->QE9_PRODUT == cProdOri .and. QE9->QE9_REVI == cRevOri}

				Aadd(aArq,{"QE9",cProdOri+cRevOri,bCRepQE9,bCConQE9,1})

				//Copia Arquivos da Especificação
				If AllTrim(cCopArqu) == AllTrim(STR0026) //"Sim"
					// Condicoes para QQO
					bCRepQQO := {|| QQO->QQO_PRODUT := cProdDes,;
									QQO->QQO_REVI   := cRevDes}
											
					bCconQQO := {|| !QQO->(eof()) .and. xFilial("QQO") == QQO->QQO_FILIAL .and.;
									QQO->QQO_PRODUT == cProdOri .and. QQO->QQO_REVI == cRevOri}

					//1 - QQO_FILIAL+QQO_FILENT+QQO_ENTIDA+QQO_PRODUT+QQO_REVI+QQO_ROTEIR+QQO_OPERAC+QQO_ENSAIO+QQO_GRUPO+QQO_REVIGR
					Aadd(aArq,{"QQO",xFilial("QE6")+"QE6"+cProdOri+cRevOri,bCRepQQO,bCconQQO,1})
				EndIf

				// Executa a duplicacao dos produtos
				For nI := 1 to Len(aArq)
					dbSelectArea(aArq[nI,1])
					dbSetOrder(aArq[nI,5])
					dbSeek(xFilial()+aArq[nI,2])

					While Eval(aArq[nI,4])
						lVolta := .T.
						If QA_Dupl(lVolta, aArq[nI,3], aArq[nI,1])
							dbSkip()
						Else
							Exit
						Endif
					EndDo
				Next
					
				// Grava a data de vigencia da nova revisao da especificacao
				QE6->(dbSetOrder(1))
				If QE6->(dbSeek(xFilial("QE6")+cProdDes+Inverte(cRevDes)))
					RecLock("QE6",.F.)
						QE6->QE6_DTINI := dVigRev
										
						// Verifica se o produto destino existe no SB1 para atualização de algumas infos do SB1
						SB1->(dbSetOrder(1))
						If SB1->(dbSeek(xFilial("SB1")+cProdDes))
							QE6->QE6_UNMED1  := SB1->B1_UM 
							QE6->QE6_TIPO    := SB1->B1_TIPO
						EndIf     

						If lRetSB1 // Caso o produto já estiver cadastrado na SB1, atualiza Unidade de Medida conforme cadastro do produto
							QE6->QE6_UNMED1  := SB1->B1_UM
							QE6->QE6_UNAMO1  := QE6->QE6_UNMED1
							QE6->QE6_TIPO    := SB1->B1_TIPO
						EndIf				
					MsUnLock()
				EndIf

				// Atualiza o Plano de Amostragens por Ensaios de acordo com a revisao ante- 
				// rior da Especificacao do Produto.										  
				aEnsaios := {}
					
				//Armazena os ensaios mensuraveis no vetor aEnsaios
				QE7->(dbSetorder(1))
				QE7->(dbSeek(xFilial("QE7")+cProdDes+cRevDes))
				While QE7->(!Eof()) .And. QE7->QE7_FILIAL == xFilial("QE7") .And.;
					QE7->(QE7_PRODUT+QE7_REVI) == (cProdDes+cRevDes)
					Aadd(aEnsaios,{QE7->QE7_ENSAIO,.F.})			
					QE7->(dbSkip())	
				EndDo	

				//Armazena os ensaios textos no vetor aEnsaios		
				QE8->(dbSetorder(1))
				QE8->(dbSeek(xFilial("QE8")+cProdDes+cRevDes))
				While QE8->(!Eof()) .And. QE8->QE8_FILIAL == xFilial("QE8") .And.;
					QE8->(QE8_PRODUT+QE8_REVI) == (cProdDes+cRevDes)
					Aadd(aEnsaios,{QE8->QE8_ENSAIO,.F.})			
					QE8->(dbSkip())	
				EndDo	
										
				If (cProdOri == cProdDes) 
					MsgRun(STR0011,STR0012,{||QComMovPAE(cProdDes,cRevDes,aEnsaios,,1)}) //"Atualizando o Plano de Amostragem por Ensaios..." ### "Aguarde"
				EndIf
		EndIf
	EndIf                                       

	If ExistBlock("QEM010R")
		ExecBlock("QEM010R",.F.,.F.)
	Endif

Return(Nil)
    
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o	 ³ A010ExProd ³ Autor ³ Marcelo Pimentel      ³ Data ³ 19/05/98 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Verif. se Prod. est  cadastrado ou se já existe	            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Sintaxe  ³ A010ExProd(ExpC1)                             				³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpC1: "O" se for Produto Origem              				³±±
±±³          ³ ExpC1: "D" se for Produto Destino             				³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso		 ³ X1_VALID (QEM010)                            				³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function A010ExProd(cPerg, lTudoOk)

	Local cChave := Nil
	Local lRet   := .F.

	DEFAULT lTudoOk := .F.

	cProdOri := Upper(MV_PAR01)
	cRevOri  := Upper(MV_PAR02)
	cProdDes := Upper(MV_PAR03)
	cRevDes  := Upper(MV_PAR04)
	cOriDes  := MV_PAR05
	cDesPro  := MV_PAR06

	If cPerg == "O"

		// Produto Origem
		cChave := cProdOri + Inverte(cRevOri)

		// Verifica se existe o Produto+Revisao
		QE6->(dbSetOrder(1))
		If QE6->(DbSeek(xFilial('QE6') + cChave ))

			// Sugere a descricao do Produto (Especificacao do Produto)
			If ! lTudoOk .And. !Empty(cOriDes)
				cDesPro := QE6->QE6_DESCPO
			Endif

			// Sugere a Proxima Revisao no campo de Destino
			If Empty(cProdDes) .And. Empty(cRevDes)

				cRevDes  := QA_UltRevEsp(cProdOri,dDataBase,.F.,.T.,"QIE")
				cProdDes := cProdOri

				If Empty(cRevDes)

					cRevDes := "00"

				Else

					cRevDes := Soma1(cRevDes)
					While .T.
						
						cChave := cProdDes + Inverte(cRevDes)
						If QE6->(DbSeek(xFilial('QE6') + cChave )) .Or. !FreeForUse("QE6",xFilial("QE6")+cProdOri+cRevDes)
							cRevDes := Soma1(cRevDes)
						Else
							Exit
						EndIf
						
					EndDo

				EndIf
			EndIf

			lRet    := .T.

		Else

			Help(" ",1,"Q_010PRNAO") // "Produto/Revisao não cadastrados."

		EndIf

	Else

		// Produto Destino
		If Empty(cProdDes)
			MsgAlert(STR0017, STR0018) // "Produto destino não informado !" #  "Atenção"
			Return(.F.)
		EndIf

		cChave := (cProdDes + Inverte(cRevDes))
		// Verifica se existe o Produto+Revisao
		QE6->(dbSetOrder(1))
		If !QE6->(DbSeek(xFilial('QE6') + cChave ))
			lRet := .T.
		Else
			Help(" ",1,"Q_010PRJAC") // "Produto/Revisao já cadastrados."
		EndIf

	EndIf

	MV_PAR01 := cProdOri
	MV_PAR02 := cRevOri
	MV_PAR03 := cProdDes
	MV_PAR04 := cRevDes
	MV_PAR05 := cOriDes
	MV_PAR06 := cDesPro

Return(lRet)
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o	 ³ A010CkProd ³ Autor ³ Marcelo Pimentel      ³ Data ³ 19/05/98 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Verifica se produto está  cadastrado                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso		 ³ X1_VALID                            							³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function A010CkProd()
Local nRec      := 0
Local dVigencia := dDataBase

cProdDes := Upper(cProdDes)

nRec := QE6->(Recno())
	
QE6->(dbSetOrder(1))
If QE6->(DbSeek(xFilial('QE6') + cProdDes))
	
	While !QE6->(Eof()) .And. cProdDes == QE6->QE6_PRODUT
		If cRevDes < QE6->QE6_REVI
			cRevDes := Soma1(QE6->QE6_REVI)
		EndIf	
		If dVigencia <= QE6->QE6_DTINI
			dVigencia := (QE6->QE6_DTINI+1)
		EndIf
		QE6->(DbSkip()) 
	EndDo

EndIf
QE6->(DbGoTo(nRec))
              
Return(dVigencia)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o	 ³ Qie010UpIn ³ Autor ³ Wanderley Gon‡alves	  ³ Data ³ 29/01/98 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Verifica se Campo Produto nao esta vazio e converte para     ³±±
±±³			 ³ maiusculo.										            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso		 ³ X1_VALID                               					    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function Qie010UpIn()

	Local cValor   := MV_PAR01
	Local lRet     := .F.
	Local nTamProd := GetSx3Cache("B1_COD" , "X3_TAMANHO")

	If !Empty(cValor)

		cProdOri := Upper(cValor)
		MV_PAR01 := cProdOri
		lRet     := .T.

	Else

		cProdOri  := Space(nTamProd)

	EndIf

Return lRet

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao	 ³ Qie010Verif³ Autor ³ Robson R. A. Oliveira ³ Data ³ 14/05/01 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Verifica de onde vira a descricao do produto                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ EXPA1 = Array contendo as opcoes do ComboBox					³±±
±±³          ³ EXPC1 = Descricao da posicao atual na ComboBox				³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso		 ³ QIEM010                                 					    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function Qie010Verif(aItem, cOriDes)  

	Local cDes     := Iif(Empty(MV_PAR06),Space(TamSX3("B1_DESC")[1]),MV_PAR06)
	Local cRevPesq := Nil
	Local nAscan   := Ascan(aItem, cOriDes)

	If (nAscan == 2)

		cDes := Space(TamSX3("B1_DESC")[1])

	ElseIf (nAscan == 3)

		If QE6->(MsSeek(xFilial("QE6")+cProdOri+Inverte(cRevOri)))
			cDes := QE6->QE6_DESCPO
		EndIf	

	ElseIf (nAscan == 4)
	
		cRevPesq := QA_UltRevEsp(cProdDes,dDataBase,.F.,.T.,"QIE")

		If QE6->(MsSeek(xFilial("QE6")+cProdDes+Inverte(cRevPesq)))
			cDes := QE6->QE6_DESCPO
		Else
			If SB1->(MsSeek(xFilial("SB1")+cProdDes))
				cDes := SB1->B1_DESC
			Else
				// STR0023 - "Produto Destino inexistente."
				// STR0024 - "Selecione a Descrição do Produto Destino = 'Informado' e preencha o campo Descrição."
				Help("",1,"HELP",,STR0023,1,0,,,,,,{STR0024})  
				cDes     := Space(TamSX3("B1_DESC")[1])
				cOriDes  := STR0001 //"Informado"
				MV_PAR05 := STR0001 //"Informado"
				MV_PAR06 := cDes
			EndIf
		EndIf

	EndIf

	If !Empty(cDes)
		MV_PAR06 := cDes
	EndIf

Return .T.
