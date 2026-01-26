#INCLUDE "Protheus.ch"

#DEFINE KB_ENTER Chr(13)+Chr(10)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ HHImpPed ³ Autor ³ Fabio Garbin          ³ Data ³ 15.10.04 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Importacao dos pedidos de vendas do Palm Pilot             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ HHImpPed                                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³                            	                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Generico                                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³         ATUALIZACOES SOFRIDAS DESDE A CONSTRU€AO INICIAL.             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Programador ³ Data   ³ BOPS ³  Motivo da Alteracao                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³            ³  /  /  ³      ³                                          ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
User Function XIMPHC5()

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Define Variaveis Locais do Programa 				   	     ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Local aMata410Cab := {}
Local aMata410Item:= {}
Local aArquivos   := {}
Local cFilePedC   :="HC5" + cEmpAnt + "0" //+(PSALIAS)->P_EMPFI
Local cFilePedI   :="HC6" + cEmpAnt + "0" //+(PSALIAS)->P_EMPFI

Private aCab      := {}
Private aItem     := {}

aAdd(aArquivos, {cFilePedC, "HC5", "C5_NUM"})
aAdd(aArquivos, {cFilePedI, "HC6", "C6_NUM+C6_ITEM"})

aAdd(aMATA410Cab,{"C5_NUM"                ,"C",06,0}) // Numero do pedido
aAdd(aMATA410Cab,{"C5_TIPO"               ,"C",01,0}) // Tipo de pedido
aAdd(aMATA410Cab,{"C5_CLIENTE"            ,"C",06,0}) // Codigo do cliente
aAdd(aMATA410Cab,{"C5_LOJACLI"            ,"C",02,0}) // Loja do cliente
aAdd(aMATA410Cab,{"C5_CONDPAG"            ,"C",03,0}) // Codigo da condicao de pagamanto
aAdd(aMATA410Cab,{"C5_VEND1"              ,"C",06,0}) // Codigo do vendedor
aAdd(aMATA410Cab,{"C5_MENNOTA"            ,"C",30,0}) // Mensagem da nota
aAdd(aMATA410Cab,{"C5_EMISSAO"            ,"D",08,0}) // Data de emissao
aAdd(aMATA410Cab,{"C5_COTACAO"            ,"C",06,0}) // Licitacao
aAdd(aMATA410Cab,{"C5_TABELA"             ,"C",03,0}) // Codigo da Tabela de Preco
aAdd(aMATA410Cab,{"C5_TIPOCLI"            ,"C",01,0}) // Tipo do Cliente
aadd(aMATA410Cab,{"C5_DESCONT"            ,"N",15,2}) // Valor da Indenizacao
aadd(aMATA410Cab,{"C5_FORMAPG"            ,"C",06,0}) // Forma de Pagamento
aadd(aMATA410Cab,{"C5_TPFRETE"            ,"C",01,0}) // Tipo de Frete (CIF ou FOB)
aadd(aMATA410Cab,{"C5_TRANSP"             ,"C",06,0}) // Codigo da Transportadora
If cPaisLoc <> "BRA"
	aAdd(aMATA410Cab,{"C5_CLCGC"                ,"C",14,0}) // RUT
EndIf

aAdd(aMATA410Item,{"C6_NUM"               ,"C",06,0}) // Numero do Pedido
aAdd(aMATA410Item,{"C6_ITEM"              ,"C",02,0}) // Numero do Item no Pedido
aAdd(aMATA410Item,{"C6_PRODUTO"           ,"C",15,0}) // Codigo do Produto
aAdd(aMATA410Item,{"C6_QTDVEN"            ,"N",09,2}) // Quantidade Vendida
aAdd(aMATA410Item,{"C6_PRUNIT"            ,"N",11,2}) // Preco Unitario Bruto
aAdd(aMATA410Item,{"C6_PRCVEN"            ,"N",11,2}) // Preco Unitario Liquido
aAdd(aMATA410Item,{"C6_VALOR"             ,"N",12,2}) // Valor Total do Item
aAdd(aMATA410Item,{"C6_ENTREG"            ,"D",08,0}) // Data da Entrega
aAdd(aMATA410Item,{"C6_UM"                ,"C",02,0}) // Unidade de Medida Primar.
aAdd(aMATA410Item,{"C6_TES"               ,"C",03,0}) // Tipo de Entrada/Saida do Item
aAdd(aMATA410Item,{"C6_LOCAL"             ,"C",02,0}) // Almoxarifado
aAdd(aMATA410Item,{"C6_DESCONT"           ,"N",05,2}) // Percentual de Desconto
aAdd(aMATA410Item,{"C6_ICMS"              ,"N",12,2}) // I.C.M.S
aAdd(aMATA410Item,{"C6_IPI"               ,"N",12,2}) // I.P.I

ConOut("PALMJOB: " + Space(4)  + "Importando Pedidos para " + Trim(HHU->HHU_NOMUSR))
//If PChkFile(cPathPalm, aArquivos)
U_PedMontaVetor(aMata410Cab, aMata410Item, @aCab, @aItem)
U_XIMPHD5()
//Else
//	ConOut("PALMJOB: Arquivo de pedido nao encontrado.")
//EndIf
*/

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o	 ³ PMontaVetor³ Autor ³ Kleber              ³ Data ³ 15/10/99 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ fMontaVetor(aMata410Cab,aMata410Item,aCab,aItem)           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ aMata410Cab : Estrutura do arquivo do PedidoC (Cabecalho)  ³±±
±±³          ³ aMata410Item: Estrutura do arquivo do PedidoI (Item)       ³±±
±±³          ³ aCab        : Array com os Dados do Arquivo CDB (Cabecalho)³±±
±±³          ³ aItem       : Array com os Dados do Arquivo CDB (Item)     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso 	 ³ AFVM020                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
User Function PedMontaVetor(aMata410Cab, aMata410Item, aCab, aItem)

Local cNumPed		:= ""
Local cNumPedPalm   := ""
Local nPosR			:= 0
Local cItemNovo     := "00"
Local aItemTmp		:= {}
Local nPreco		:= 0
Local aPvlNfs       := {} // Valdir
Local lCtbOnline    := Iif(GetMv("MV_ATUSI2")="C",.F.,.T.)
Local cHrIni        := Time() // Hora de Inicio para a gravacao do Log
Local cHHPalm       := GetHHDir() + "\LOGS\"
Local cResp         := ""     // Mensagem do no Console do Server e no Log
Local cCliente      := ""
Local cLoja         := ""
Local lConfirmSX8   := .F.
Local i             := 1
Local j             := 1
Local cId           := HGU->HGU_CODBAS
Local nMail         := GetMv("MV_HHMAIL",, 2) // 1 - Não Envia E-mail; 2 - Envia quando ocorrer erro; 3 - Sempre Envia
Local cSubject      := "Importação de Pedido Handheld"
Local cMail         := ""
Local nItemSkip := 0
Local cFiltro := ""
DbSelectArea("HC5")
dbSetOrder(1)
cFiltro := "HC5_ID = '" + cId + "'"
Set Filter to &cFiltro
DbGoTop()
While !HC5->(Eof())
	If AllTrim(HC5->HC5_STATUS) = "N"

		cNumPedPalm := HC5->HC5_COTAC
		cCliente    := HC5->HC5_CLI    // CLIENTE
		cLoja       := HC5->HC5_LOJA   // LOJA
		nNumItem    := HC5->HC5_QTDITE // QTDE DE ITENS DO PEDIDO

		// Posiciona o Cadastro de Clientes
		SA1->(dbSetOrder(1))
		SA1->(dbSeek(xFilial("SA1")+cCliente+cLoja))

		dbSelectArea("HC5")
		For i:=1 to Len(aMata410Cab)
			If aMata410Cab[i,1] = "C5_NUM"
				aAdd(aCab,{aMata410Cab[i,1],cNumPedPalm,Nil})
			ElseIf aMata410Cab[i,1] = "C5_CLIENTE"
				aAdd(aCab,{aMata410Cab[i,1],HC5->HC5_CLI,Nil})
			ElseIf aMata410Cab[i,1] = "C5_EMISSAO"
				aAdd(aCab,{aMata410Cab[i,1],HC5->HC5_EMISS,Nil})				
			ElseIf aMata410Cab[i,1] = "C5_COTAC"
				aAdd(aCab,{aMata410Cab[i,1],cNumPedPalm,Nil})			
			ElseIf aMata410Cab[i,1] = "C5_TIPOCLI"
				aAdd(aCab,{aMata410Cab[i,1],SA1->A1_TIPO,Nil})	
			ElseIf aMata410Cab[i,1] = "C5_CLCGC"
				aAdd(aCab,{aMata410Cab[i,1],SA1->A1_CGC,Nil})
			ElseIf aMata410Cab[i,1] = "C5_MENNOTA"
				aAdd(aCab,{aMata410Cab[i,1],AllTrim(HC5->HC5_MENOTA),Nil})
			ElseIf aMata410Cab[i,1] = "C5_LOJACLI"
				aAdd(aCab,{aMata410Cab[i,1],HC5->HC5_LOJA,Nil})
			ElseIf aMata410Cab[i,1] = "C5_CONDPAG"
				aAdd(aCab,{aMata410Cab[i,1],HC5->HC5_COND,Nil})
			ElseIf aMata410Cab[i,1] = "C5_COTACAO"
				aAdd(aCab,{aMata410Cab[i,1],HC5->HC5_COTAC,Nil})
			ElseIf aMata410Cab[i,1] = "C5_TABELA"
				aAdd(aCab,{aMata410Cab[i,1],HC5->HC5_TAB,Nil})
			ElseIf aMata410Cab[i,1] = "C5_DESCONT"
				aAdd(aCab,{aMata410Cab[i,1],HC5->HC5_DESCONT,Nil})
			ElseIf aMata410Cab[i,1] = "C5_TPFRETE"
				If !Empty(HC5->HC5_TPFRET)
					aAdd(aCab,{aMata410Cab[i,1],HC5->HC5_TPFRET,Nil})
				EndIf
			ElseIf aMata410Cab[i,1] = "C5_TIPO"
				aAdd(aCab,{aMata410Cab[i,1],HC5->HC5_TIPO,Nil})
			ElseIf aMata410Cab[i,1] = "C5_VEND1"
				aAdd(aCab,{aMata410Cab[i,1],HC5->HC5_VEND1,Nil})
			ElseIf aMata410Cab[i,1] = "C5_FORMAPG"
				If FieldPos("C5_FORMAPG") > 0
					aAdd(aCab,{aMata410Cab[i,1],HC5->HC5_FORMPG,Nil})
				EndIf
			ElseIf aMata410Cab[i,1] = "C5_TPFRETE"
				aAdd(aCab,{aMata410Cab[i,1],HC5->HC5_TRFRET,Nil})
			ElseIf aMata410Cab[i,1] = "C5_TRANSP"
				aAdd(aCab,{aMata410Cab[i,1],HC5->HC5_TRANSP,Nil})
			EndIf
		Next

		DbSelectArea("HC6")
		dbSetOrder(1)
		dbGoTop()
		nPreco := 0
		If DbSeek(xFilial("SC6") + cId + cNumPedPalm, .F.)
			While !HC6->(Eof()) .And. HC6->HC6_FILIAL = xFilial("SC6") .And. HC6->HC6_ID = cId .And. HC6->HC6_NUM = cNumPedPalm
				If AllTrim(HC6->HC6_STATUS) != "N"
					HC6->(dbSkip())
					Loop
				EndIf

				// Verifica se o Produto esta bloqueado e/ou existe no SB1
				If SB1->(FieldPos("B1_MSBLQL")) > 0
					SB1->(dbSetOrder(1))
					If SB1->(dbSeek(xFilial("SB1") +  HC6->HC6_PROD))
						If SB1->B1_MSBLQL = "1"
							HC6->(dbSkip())
							nItemSkip++
							HHSaveLog(HGU->HGU_GRUPO, HGU->HGU_SERIE, 1012, .T., "Cotação " + cNumPedPalm+ ". Produto " + AllTrim(HC6->HC6_PROD) + " bloqueado.")
							Loop
						EndIf
					Else
						HC6->(dbSkip())
						nItemSkip++
						HHSaveLog(HGU->HGU_GRUPO, HGU->HGU_SERIE, 1012, .T., "Cotação " + cNumPedPalm+ ". Produto " + AllTrim(HC6->HC6_PROD) + " não encontrado.")
						Loop						
					EndIf							
				EndIf

				For j := 1 To Len(aMata410Item)
					If aMata410Item[j,1] = "C6_NUM"
						aAdd(aItemTmp,{aMata410Item[j,1],cNumPed,Nil})
					ElseIf aMata410Item[j,1] = "C6_ITEM"
						cItemNovo := Soma1(cItemNovo,2)
						aAdd(aItemTmp,{aMata410Item[j,1],cItemNovo,Nil})
					ElseIf aMata410Item[j,1] = "C6_PRCVEN"
						aAdd(aItemTmp,{aMata410Item[j,1],HC6->HC6_PRCVEN,Nil})
						dbSelectArea("HC6")
					ElseIf aMata410Item[j,1] = "C6_VALOR"
						aAdd(aItemTmp,{aMata410Item[j,1],Round(HC6->HC6_QTDVEN * HC6->HC6_PRCVEN,2),Nil})
					ElseIf aMata410Item[j,1] = "C6_PRUNIT"
						aAdd(aItemTmp,{aMata410Item[j,1],&("HC6->HC6_PRCVEN"),Nil}) // Preco Bruto
					ElseIf aMata410Item[j,1] = "C6_PRODUTO"
						aAdd(aItemTmp,{aMata410Item[j,1],HC6->HC6_PROD,Nil}) // Codigo do Produto
					ElseIf aMata410Item[j,1] = "C6_DESCONT"
						aAdd(aItemTmp,{aMata410Item[j,1],HC6->HC6_DESC,Nil}) // Desconto
					ElseIf aMata410Item[j,1] = "C6_TABELA"
						aAdd(aItemTmp,{aMata410Item[j,1],HC6->HC6_TAB,Nil}) // Tabela
					ElseIf aMata410Item[j,1] = "C6_QTDVEN"
						aAdd(aItemTmp,{aMata410Item[j,1],HC6->HC6_QTDVEN,Nil}) //  Quantidade
					ElseIf aMata410Item[j,1] = "C6_ENTREG"
						aAdd(aItemTmp,{aMata410Item[j,1],HC6->HC6_ENTREG,Nil}) // Data de Entrega
					ElseIf aMata410Item[j,1] = "C6_UM"
						aAdd(aItemTmp,{aMata410Item[j,1],HC6->HC6_UM,Nil}) // Unidade de Medida
					ElseIf aMata410Item[j,1] = "C6_TES"
						aAdd(aItemTmp,{aMata410Item[j,1],HC6->HC6_TES,Nil}) // TES
					ElseIf aMata410Item[j,1] = "C6_LOCAL"
						aAdd(aItemTmp,{aMata410Item[j,1],HC6->HC6_LOCAL,Nil}) // Local
					ElseIf aMata410Item[j,1] = "C6_ICMS"
						aAdd(aItemTmp,{aMata410Item[j,1],HC6->HC6_ICMS,Nil}) // ICMS
					ElseIf aMata410Item[j,1] = "C6_IPI"
						aAdd(aItemTmp,{aMata410Item[j,1],HC6->HC6_IPI,Nil}) // IPI
					EndIf
				Next
				If !Empty(HC5->HC5_NOTA) // Valdir	
					aAdd(aItemTmp,{"C6_QTDLIB",HC6->HC6_QTDVEN,Nil})
				EndIf
				dbSkip()
				If Len(aItemTmp) > 0
					aAdd(aItem, aClone(aItemTmp))
				EndIf
				aItemTmp   := {}
			EndDo
			cItemNovo := "00"
		EndIf
		
		// Total de Itens do HC5 (HC5_QTITPED) - Itens Bloqueados
		If (nNumItem - nItemSkip) != Len(aItem)
			ConOut("PALMJOB: "+ Space(4)  + "ATENCAO: Pedido " + cNumPedPalm + " nao Importado, pedido nao transmitido completamente !!!")
			HHSaveLog(HGU->HGU_GRUPO, HGU->HGU_SERIE, 1011, .T., "Pedido " + cNumPedPalm+ " nao Importado, pedido nao transmitido completamente !!!")
			aCab  := {}
			aItem := {}
		EndIf

	Endif

	// Ponto de entrada para possibilitar manipulacao dos Array aCab e aItem.
	If ( (ExistBlock("AFVM020A")) )
		ExecBlock("AFVM020A",.F.,.F.)
	EndIf

	If Len(aCab) > 0 .And. Len(aItem) > 0
		nPosR := Ascan(aCab, { |X| X[1] = "C5_MENNOTA" })
		If Empty(aCab[nPosR,2])
			aDel(aCab,nPosR)
			aSize(aCab,Len(aCab)-1)
		EndIf

		// Busca o Proximo Numero de Pedido
		SX3->(dbSetOrder(2))
		SX3->(dbSeek("C5_NUM"))
		If Empty(SX3->X3_RELACAO)
			lConfirmSX8 := .T.
			cNumPed     := GetSxeNum("SC5","C5_NUM")
			SC5->(dbSetOrder(1))
			While SC5->(dbSeek(xFilial("SC5")+cNumPed))
				ConfirmSX8()
				cNumPed := GetSxeNum("SC5","C5_NUM")
			EndDo
		EndIf
		SX3->(dbSetOrder(1))

		nPos := Ascan(aCab, { |X| X[1] = "C5_NUM" })
		If nPos > 0 .And. !Empty(cNumPed)
			aCab[nPos,2] := cNumPed
		ElseIf nPos > 0
			aCab := aDel(aCab,nPos)
			aCab := aSize(aCab,Len(aCab)-1)
		EndIf

	    lMsHelpAuto := .T.
	    lMsErroAuto := .F.
	    SF4->(Mata410(aCab,aItem,3))
	    cNumPed := SC5->C5_NUM
		ConOut("PALMJOB: " + Space(4) + "Importacao de arquivos - Pedido: " + cNumPed) //"Importacao de arquivos - Pedido: "
		cMail += " Importacao de arquivos - Pedido: " + cNumPed + Chr(13) + Chr(10)
		cItemNovo := "00"
		If !lMsErroAuto
		    cResp := "PALMJOB: " + Space(4) + "Pedido " + cNumPed + " importado com sucesso."
		    cMail += "Pedido " + cNumPedPalm +" importado com sucesso. "+ Chr(13) + Chr(10)
		    cMail += "Pedido " + cNumPedPalm +" transferido para o numero: "+cNumPed + Chr(13) + Chr(10)
		    dbSelectArea("HC5")	
			dbSetOrder(1)
			If dbSeek(xFilial("SC5") + cId + cNumPedPalm)
				RecLock("HC5",.F.)			// Altera o FLag para 0
				HC5->HC5_STATUS := "P"
				HC5->HC5_INTR := "X"
				HC5->(MsUnlock())
				
				dbSelectArea("HC6")	
				dbSetOrder(1)
				If dbSeek(xFilial("SC6") + cId + cNumPedPalm)
					While !HC6->(Eof()) .And. HC6->HC6_FILIAL = xFilial("SC6") .And. HC6->HC6_ID = cId .And. HC6->HC6_NUM = cNumPedPalm
						RecLock("HC6",.F.)			// Altera o FLag para 0
						HC6->HC6_STATUS := "P"
						HC6->HC6_INTR := "X"
						HC6->(MsUnlock())
						HC6->(dbSkip())
					EndDo
			   EndIf

			EndIf
			If lConfirmSX8
				ConfirmSX8()
			EndIf
			HHSaveLog(HGU->HGU_GRUPO, HGU->HGU_SERIE, 1010, .T., "Pedido " + cNumPed + " importado com sucesso. Itens = " + Str(Len(aItem),4,0))
			If !Empty(SA3->A3_EMAIL) .And. nMail = 3
				HHSendMail({SA3->A3_EMAIL},,,, "Pedido realizado em " + DtoC(HC5->HC5_EMISS) + " OK", cMail)
			EndIf
		    
			If !Empty(HC5->HC5_NOTA) // Valdir
				If HC6->(DbSeek(cNumPedPalm, .F.))
					LibCred(cNumPed)
					aPvlNfs:={}
					SC9->(DbSetOrder(1))
					SC5->(DbSetOrder(1))
					SC6->(DbSetOrder(1))
					SE4->(DbSetOrder(1))
					SB1->(DbSetOrder(1))
					SB2->(DbSetOrder(1))
					SF4->(DbSetOrder(1))
					While HC6->(!Eof()) .And. HC6->C6_NUM=cNumPedPalm
						SC9->(DbSeek(xFilial("SC9")+cNumPed+HC6->C6_ITEM))               //FILIAL+NUMERO+ITEM
						SC5->(DbSeek(xFilial("SC5")+cNumPed))                             //FILIAL+NUMERO
						SC6->(DbSeek(xFilial("SC6")+cNumPed+HC6->C6_ITEM))               //FILIAL+NUMERO+ITEM
						SE4->(DbSeek(xFilial("SE4")+HC5->C5_CONDPAG))                    //CONDICAO DE PGTO			
						SB1->(DbSeek(xFilial("SB1")+HC6->C6_PROD))                    //FILIAL+PRODUTO
						SB2->(DbSeek(xFilial("SB2")+HC6->C6_PROD+HC6->C6_LOCAL))    //FILIAL+PRODUTO+LOCAL
						SF4->(DbSeek(xFilial("SF4")+HC6->C6_TES))                        //FILIAL+CODIGO
						aAdd(aPvlNfs,{;
							cNumPed, ;              //Numero Pedido
							HC6->C6_ITEM,;         //Item
							HC6->C6_ITEM,;         //Sequencia
							HC6->C6_QTDVEN ,;      //Qtd Liberada
							HC6->C6_PRCVEN,;       //preco de Venda
							HC6->C6_PROD,.f.,; //Produto
							SC9->(RecNo()),;
							SC5->(RecNo()),;
							SC6->(RecNo()),;
							SE4->(RecNo()),;
							SB1->(RecNo()),;
							SB2->(RecNo()),;
							SF4->(RecNo())})
						HC6->(DbSkip())
					EndDo
					MaPvlNfs2(aPvlNfs,HC5->C5_SERIE,HC5->C5_NOTA, .F., .F., lCtbOnline, .T., .F., 0, 0, .T., .F.,)
				EndIf
			EndIf
		Else
			// Pedido nao Incluido
			cResp := "PALMJOB: " + Space(4)  + "ATENCAO: Pedido " + cNumPedPalm + " do vendedor " +  cId + " nao Incluido !!!"
			cMail += "ATENCAO: Pedido " + cNumPedPalm + " do vendedor " +  cId + " não Incluido !!!" + Chr(13) + Chr(10)
			If lConfirmSX8
				RollBackSX8()
			EndIf
			HHSaveLog(HGU->HGU_GRUPO, HGU->HGU_SERIE, 1011, .T., )//__cFileLog)
			ConOut(cHHPalm)
			MostraErro(cHHPalm)
			If !Empty(SA3->A3_EMAIL) .And. nMail != 1
				HHSendMail({SA3->A3_EMAIL},,,, "Pedido feito em " + DtoC(HC5->HC5_EMISS) + " não Incluido", cMail)
			EndIf
		EndIf
		ConOut(cResp)
		// Atualiza Data da Ultima Visita no cadastro de Clientes
		dbSelectArea("SA1")
		nPosR := Ascan(aCab, { |X| X[1] = "C5_CLIENTE" })
		If ( nPosR > 0 )
			If dbSeek( xFilial("SA1") + aCab[nPosR,2], .F. )
				RecLock("SA1",.F.)
				nPosR := Ascan(aCab, { |X| X[1] = "C5_EMISSAO" })
				SA1->A1_ULTVIS := aCab[nPosR,2]
				MsUnlock()
			EndIf
		EndIf
		// Atualiza do Proximo Pedido no cadastro de Vendedores
		dbSelectArea("SA3")
		nPosR := Ascan(aCab, { |X| X[1] = "C5_VEND1" })
		If ( nPosR > 0 )
			If dbSeek( xFilial("SA3") + aCab[nPosR,2], .F. )
				RecLock("SA3",.F.)
				SA3->A3_PROXPED := If(Val(cNumPedPalm)>=Val(SA3->A3_PROXPED),StrZero(Val(cNumPedPalm) + 1,6),SA3->A3_PROXPED)
				MsUnlock()
			EndIf
		Endif
	EndIf
	aCab    := {}
	aItem   := {}
	cNumped := ""
	dbSelectArea("HC5")
	dbSkip()
EndDo
Set Filter to
HC5->(dbCloseArea())
HC6->(dbCloseArea())
Return Nil

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o	 ³ LibCred    ³ Autor ³ VALDIR              ³ Data ³ 30/10/00 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ LibCred(cNumPed)						  		              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ cNumPed : Numero do Pedido a ser Liberado				  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ AFVM020                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function LibCred(cNumPed)
SC9->(DbSetOrder(1))
SC9->(DbSeek(xFilial("SC9")+cNumPed) )                    //FILIAL+NUMERO+ITEM
While SC9->(!EOF()) .and. SC9->C9_FILIAL == xFilial("SC9") .and. SC9->C9_PEDIDO == cNumPed
	// Parametros nOpc: 1 - Libera
	//                  2 - Rejeita
	//            lAtuCred : Indica se Libera Credito
	//            lAtuEst  : Indica se Libera Estoque
	a450Grava(1,.T.,.F.)
	SC9->(DbSkip())
End

Return


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ PImpNpos ³ Autor ³ Fabio Garbin          ³ Data ³ 29.05.01 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Importacao das Nao Positivacoes do Palm Pilot              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ PImpNPOS                                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³                             	                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ HHExpSC5                                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³         ATUALIZACOES SOFRIDAS DESDE A CONSTRU€AO INICIAL.             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Programador ³ Data   ³ BOPS ³  Motivo da Alteracao                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³            ³  /  /  ³      ³                                          ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
User Function XIMPHD5()
//Local aArquivos  := {}
Local nSeq       := 1
//Local cPathPalm   := GetSrvProfString("HandHeldDir","\HANDHELD\") + "P" + AllTrim(HGU->HGU_DIR) + "\atual\"
Local cVend       := HGU->HGU_CODBAS

//aAdd(aArquivos, {"npos", "NPO", "AD5_DTHR"})

ConOut("PALMJOB: " + Space(4) + "Importando Nao Positivacao para " + Trim(HHU->HHU_NOMUSR))
//If PChkFile(cPathPalm, aArquivos)
dbSelectArea("HD5")
dbSetOrder(1)
While !Eof()
	// Verifica a proxima sequencia
	dbSelectArea("AD5")
	dbSetOrder(1)
	While dbSeek(xFilial("AD5")+cVend+Subs(HD5->HD5_DTHR,1,8)+StrZero(nSeq,2))
		nSeq := nSeq + 1
	EndDo	

	RecLock("AD5",.T.)
	AD5->AD5_FILIAL  := xFilial("AD5")
	AD5->AD5_VEND    := cVend
	AD5->AD5_DATA    := StoD(Subs(HD5->HD5_DTHR,1,8))		
	AD5->AD5_SEQUEN  := StrZero(nSeq,2)
	AD5->AD5_CODCLI  := Subs(HD5->HD5_CODCLI,1,6)
	AD5->AD5_LOJA    := Subs(HD5->HD5_CODCLI,7,2)
	AD5->AD5_EVENTO  := HD5->HD5_CODNPO
	AD5->(MsUnlock())

	// Apaga registro do Diretorio Atual
	dbSelectArea("HD5")
	RecLock("HD5",.F.)
	dbDelete()
	HD5->(MsUnlock())
	HD5->(dbSkip())
EndDo		
//EndIf
Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ HHImpCli  ³ Autor ³ Fabio Garbin         ³ Data ³ 14.02.01 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Importacao dos Clientes do Palm Pilot                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ HHImpCli                                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³                             	                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Generico                                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³         ATUALIZACOES SOFRIDAS DESDE A CONSTRU€AO INICIAL.             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Programador ³ Data   ³ BOPS ³  Motivo da Alteracao                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³            ³  /  /  ³      ³                                          ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
User Function XIMPHA1()

Local aCliente   := {} // Contem os dados do arquivo de CLIENTES
Local aMata030   := {}
Local aArquivos  := {}
Local i          := 0
Local cVend      := HGU->HGU_CODBAS
Local cCodCli    := ""
Local cCodLoja   := ""
Local cCliPalm   := ""
Local cLojPalm   := ""
Local cFiltro    := ""
Local aCliNovo   :={}
Local cId        := cVend
Local cHHPalm    := GetHHDir() + "\LOGS\"
// Preenche o array com os campos do cliente a serem enviados
aadd(aMata030,{"A1_COD"					, "C", 06, 0}) // Codigo do Cliente
aadd(aMata030,{"A1_LOJA"				, "C", 02, 0}) // Loja do Cliente
aadd(aMata030,{"A1_CGC"					, "C", 14, 0}) // CGC/CPF do cliente
aadd(aMata030,{"A1_NOME"				, "C", 40, 0}) // Nome do cliente
aadd(aMata030,{"A1_NREDUZ"				, "C", 20, 0}) // Nome Reduzido do cliente
aadd(aMata030,{"A1_TIPO"				, "C", 01, 0}) // Tipo do cliente
aadd(aMata030,{"A1_END"			   		, "C", 40, 0}) // Endereco do cliente
aadd(aMata030,{"A1_MUN"					, "C", 15, 0}) // Municipio do cliente
aadd(aMata030,{"A1_EST"					, "C", 02, 0}) // Estado do cliente
aadd(aMata030,{"A1_BAIRRO"				, "C", 30, 0}) // Bairro do cliente
aadd(aMata030,{"A1_CEP"					, "C", 08, 0}) // Cod Enderecamento Postal
aadd(aMata030,{"A1_TEL"					, "C", 15, 0}) // Telefone do cliente
aadd(aMata030,{"A1_VEND"				, "C", 06, 0}) // Codigo do Vendedor
aadd(aMata030,{"A1_RISCO"				, "C", 01, 0}) // Grau de Risco do cliente
aadd(aMata030,{"A1_EMAIL"				, "C", 01, 0}) // Grau de Risco do cliente
aadd(aMata030,{"A1_INSCR" 				, "C", 18, 0}) // Inscricao estadual
aadd(aMata030,{"A1_ULTVIS"				, "D", 08, 0}) // Data da ultima Visita
aadd(aMata030,{"A1_STATUS"			    , "C", 01, 0}) // Status (N=Novo, A=Alterado)

ConOut("PALMJOB: " + Space(4) + "Importando Cliente para " + Trim(HHU->HHU_NOMUSR))
dbSelectArea("HA1")
dbSetOrder(1)
cFiltro := "HA1_ID = '" + cVend + "' .AND. ( HA1_STATUS = 'N' .Or. HA1_STATUS = 'A')"
Set Filter to &cFiltro
HA1->(dbGoTop())

While !HA1->(Eof())
	If HA1->HA1_STATUS = "N"

		// Guardo o codigo e loja do palm
		cCliPalm:=HA1->HA1_COD
		cLojPalm:=HA1->HA1_LOJA

		cCodCli := GetSxeNum("SA1","A1_COD")
		cCodLoj := HA1->HA1_LOJA  // Loja que foi incluida no Palm
		dbSelectArea("SA1")
		dbSetOrder(1)
		While dbSeek(xFilial("SA1")+cCodCli+cCodLoj )
			ConfirmSX8()
			cCodCli := GetSxeNum("SA1","A1_COD")
			dbSkip()
		EndDo
		dbSelectArea("HA1")
		dbSetOrder(1)	  			
	ElseIf HA1->HA1_STATUS = "A"
		cCodCli := HA1->HA1_COD
		cCodLoj := HA1->HA1_LOJA  // Loja que foi incluida no Palm
	EndIf		
	For i := 1 To Len(aMata030)
		If aMata030[i,1] = "A1_COD"
			aadd(aCliente,{aMata030[i,1], cCodCli, Nil})
		ElseIf aMata030[i,1] = "A1_LOJA"
			aadd(aCliente,{aMata030[i,1], cCodLoj, Nil})
		ElseIf aMata030[i,1] = "A1_NOME"
			aadd(aCliente,{aMata030[i,1], HA1->HA1_NOME, Nil})
		ElseIf aMata030[i,1] = "A1_NREDUZ"
			aadd(aCliente,{aMata030[i,1], HA1->HA1_NREDUZ, Nil})
		ElseIf aMata030[i,1] = "A1_TIPO"
			aadd(aCliente,{aMata030[i,1], HA1->HA1_TIPO, Nil})
		ElseIf aMata030[i,1] = "A1_CGC"
			dbSelectArea("SA1")
			dbSetOrder(3)
			If SA1->(dbSeek(xFilial("SA1")+ HA1->HA1_CGC))
				ConOut("PALMJOB: CPF/CNPJ ja existe no cadastro de cliente (SA1). Nao sera gravado para o novo cliente.")
			Else
				aadd(aCliente,{aMata030[i,1], HA1->HA1_CGC, Nil})
			EndIf			
		ElseIf aMata030[i,1] = "A1_VEND"
			aadd(aCliente,{aMata030[i,1], cVend, Nil})
		ElseIf aMata030[i,1] = "A1_END"
			aadd(aCliente,{aMata030[i,1], HA1->HA1_END, Nil})
		ElseIf aMata030[i,1] = "A1_MUN"
			aadd(aCliente,{aMata030[i,1], HA1->HA1_MUN, Nil})
		ElseIf aMata030[i,1] = "A1_EST"
			aadd(aCliente,{aMata030[i,1], HA1->HA1_EST, Nil})
		ElseIf aMata030[i,1] = "A1_BAIRRO"
			aadd(aCliente,{aMata030[i,1], HA1->HA1_BAIRRO, Nil})
		ElseIf aMata030[i,1] = "A1_CEP"
			If !Empty(HA1->HA1_CEP)
				aadd(aCliente,{aMata030[i,1], HA1->HA1_CEP, Nil})
			EndIf
		ElseIf aMata030[i,1] = "A1_TEL"
			If !Empty(HA1->HA1_TEL)
				aadd(aCliente,{aMata030[i,1], HA1->HA1_TEL, Nil})
			EndIf
		ElseIf aMata030[i,1] = "A1_RISCO"
			If !Empty(HA1->HA1_RISCO)
				aadd(aCliente,{aMata030[i,1], HA1->HA1_RISCO, Nil})
			EndIf
		ElseIf aMata030[i,1] = "A1_INSCR"
			If !Empty(HA1->HA1_INSCR)
				aadd(aCliente,{aMata030[i,1], HA1->HA1_INSCR, Nil})
			EndIf
		ElseIf aMata030[i,1] = "A1_EMAIL"
			If !Empty(HA1->HA1_EMAIL)
				aadd(aCliente,{aMata030[i,1], HA1->HA1_EMAIL, Nil})
			EndIf
		EndIf
	Next

	lMsHelpAuto := .T.
	lMsErroAuto := .F.
	If HA1->HA1_STATUS = "N"   // Inclui novo Cliente
		Mata030(aCliente)
	ElseIf HA1->HA1_STATUS = "A"
		Mata030(aCliente,4)   // Altera Cliente
	EndIf
	If !lMsErroAuto// .And. HA1->HA1_STATUS $ "AN"
		ConOut("PALMJOB:  " + Space(4) + "Cliente " + cCodCli + " cadastrado com sucesso.")
		ConfirmSX8()
		dbSelectArea("HA1")
		dbSetOrder(1)
		If dbSeek(xFilial("SA1") + cVend + cCliPalm + cLojPalm)
			// Acerta Codigo do cliente
			AcertaPed(cCliPalm, cCodCLi, cCodLoj)
			AcertaCon(cCliPalm, cCodCli, cCodLoj)

			cStatus := HA1->HA1_STATUS
			RecLock("HA1",.F.)
			HA1->HA1_STATUS := "P"
			HA1->HA1_INTR   := "E"
			HA1->HA1_VER    := HHGenericUpd(cVend, "HA1", .F.,)
			HA1->(MsUnlock())
		EndIf
		HHSaveLog(HGU->HGU_GRUPO, HGU->HGU_SERIE, If(cStatus = "N", 1020, 1021) , .T., "Cliente " + cCodCli)
		
		// Atualiza do Proximo Cliente no cadastro de Vendedores
		dbSelectArea("SA3")
		dbSetOrder(1)
		If dbSeek( xFilial("SA3") + cVend , .F. )
			RecLock("SA3",.F.)
			SA3->A3_PROXCLI := StrZero( Val(SA3->A3_PROXCLI)+1,6 )
			SA3->(MsUnlock())   		 	
		EndIf
		// Nesta saida o vetor so deve conter codigos novos de clientes
	Else
		// Cliente nao Incluido
		ConOut("PALMJOB:  " + Space(4) + "ATENCAO: Cliente nao Incluido !!!")
		If HA1->HA1_STATUS = "N"
			RollBackSX8()
		EndIf
		HHSaveLog(HGU->HGU_GRUPO, HGU->HGU_SERIE, 1022, .T.,)// __cFileLog)
		MostraErro(cHHPalm)
	EndIf						
	aCliente := {}
	dbSelectArea("HA1")
	dbSkip()
EndDo
Set Filter to
Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ AcertaPed| Autor ³ Fabio Garbin          ³ Data ³ 27.09.01 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Acerta o Codigo do Pedido na tabela PedidoC do ATUAL qdo   ³±±
±±³          ³ Cliente for Novo                                           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ AcertaPed                                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³                             	                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ HHImpCli                                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³         ATUALIZACOES SOFRIDAS DESDE A CONSTRU€AO INICIAL.             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Programador ³ Data   ³ BOPS ³  Motivo da Alteracao                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³            ³  /  /  ³      ³                                          ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/

Static Function AcertaPed(cCodPalm, cCodCli, cCodLoja)
// So para quem usa numeracao do Proheus
// Lembra que guardei o codigo la do cliente no vetor ?
// Pois eh agora vou pesquisar no vetor se ele este codigo do pedido estiver lah
// siguinfica que o cliente deste pedido tb eh novo.
// Qdo o Pedido e de um Cliente Novo Altera o Cliente no Diretorio Atual
Local cId     := HHCheckId("HA1", "SA1")
Local cFilter := "HC5_ID = '" + cId + "' .AND. HC5_CLI = '" + cCodPalm + "'"
//Local cChave := cFilAnt + cId + cCodPalm	//Alterado em 08/07/2003 (Cleber)
dbSelectArea("HC5")
dbSetOrder(1)
Set Filter To &cFilter
While !HC5->(Eof())
	RecLock("HC5", .F.)
	HC5->HC5_CLI := cCodCli
	HC5->HC5_LOJA:= cCodLoja
	HC5->(MsUnlock())
	HC5->(dbSkip())
EndDo
Set Filter To
Return Nil

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ AcertaCon| Autor ³ Fabio Garbin          ³ Data ³ 14.11.01 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Acerta o Codigo do Cliente na tabela Contato do ATUAL qdo  ³±±
±±³          ³ Cliente for Novo                                           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ AcertaPed                                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³                             	                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ PImpCli                                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³         ATUALIZACOES SOFRIDAS DESDE A CONSTRU€AO INICIAL.             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Programador ³ Data   ³ BOPS ³  Motivo da Alteracao                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³            ³  /  /  ³      ³                                          ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/

Static Function AcertaCon(cCodPalm, cCodCli, cCodLoja)
// So para quem usa numeracao do Proheus
// Lembra que guardei o codigo la do cliente no vetor ?
// Pois eh agora vou pesquisar no vetor se ele este codigo do pedido estiver lah
// siguinfica que o cliente deste pedido tb eh novo.
// Qdo o Pedido e de um Cliente Novo Altera o Cliente no Diretorio Atual
Local cId := HHCheckId("HU5", "SA1")
Local cFilter := "HU5_ID = '" + cId + "' .AND. HU5_CLIENT = '" + cCodPalm + "'"

dbSelectArea("HU5")
dbSetOrder(1)
Set Filter To &cFilter
While !HU5->(Eof())
	RecLock("HU5", .F.)
	HU5->HU5_CLIENTE := cCodCli
	HU5->HU5_LOJA    := cCodLoja
	HU5->(MsUnlock())
	HU5->(dbSkip())
EndDo
Set Filter To
Return


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ HHImpCon  ³ Autor ³ Fabio Garbin          ³ Data ³ 15.02.01 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Importacao dos Contatos do Palm Pilot                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ HHImpCon                                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³                             	                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Generico                                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³         ATUALIZACOES SOFRIDAS DESDE A CONSTRU€AO INICIAL.             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Programador ³ Data   ³ BOPS ³  Motivo da Alteracao                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³            ³  /  /  ³      ³                                          ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
User Function XIMPHU5()

Local aContato   := {} // Contem os dados do arquivo de CONTATOS
Local aArquivos  := {}
Local i          := 0
Local cVend      := HGU->HGU_CODBAS
Local cPath      := ""
Local cCodCon    := ""
Local cFiltro    := ""

ConOut("PALMJOB:  " + Space(4) + "Importando Contatos para " + Trim(HHU->HHU_NOMUSR))
dbSelectArea("HU5")
dbSetOrder(1)
cFiltro := "HU5_ID = '" + cVend + "' .AND. (HU5_STATUS = 'N' .Or. HU5_STATUS = 'A')"
Set Filter to &cFiltro
While !Eof()
	If HU5->HU5_STATUS = "N"
		cCodCon := GetSxeNum("SU5","U5_CODCONT")
		dbSelectArea("SU5")
		dbSetOrder(1)
		While dbSeek(xFilial("SU5") + cCodCon )
			ConfirmSX8()
			cCodCon := GetSxeNum("SU5","U5_CODCONT")
			dbSkip()
		EndDo
		dbSelectArea("HU5")
		dbSetOrder(1)	  	
	ElseIf HU5->HU5_STATUS = "A"
		cCodCon := HU5->HU5_CODCONT
	EndIf	
	dbSelectArea("SU5")
	dbSetOrder(1)
	If HU5->HU5_STATUS = "N"
		RecLock("SU5",.T.)
	ElseIf HU5->HU5_STATUS = "A"
		dbSeek(xFilial("SU5")+cCodCon)
		RecLock("SU5",.F.)	
	EndIf
	If SA1->(dbSeek( xFilial("SU5")+HU5->HU5_CLIENTE+HU5->HU5_LOJA ))
		If !Empty(cCodCon)
			SU5->U5_FILIAL  := xFilial("SU5")
			SU5->U5_CODCONT := cCodCon
			SU5->U5_CLIENTE := HU5->HU5_CLIENTE
			SU5->U5_LOJA    := HU5->HU5_LOJA
			SU5->U5_CONTAT  := HU5->HU5_CONTAT
			SU5->U5_FONE    := HU5->HU5_FONE
			SU5->U5_CPF     := HU5->HU5_CPF			
			SU5->U5_FUNCAO  := HU5->HU5_FUNCAO
			SU5->U5_CELULAR := HU5->HU5_CEL
			SU5->U5_NIVER   := HU5->HU5_DTNASC
			SU5->U5_NIVEL   := "01"
			SU5->U5_ATIVO   := "1"
			SU5->(MsUnlock())
			ConfirmSX8()
		EndIf
		If dbSeek(xFilial("SU5")+cCodCon) .And. HU5->HU5_STATUS $ "AN"
			dbSelectArea("AC8")
			dbSetOrder(1)
			If dbSeek(xFilial("AC8")+cCodCon+"SA1"+xFilial("SA1")+HU5->HU5_CLIENTE)
				RecLock("AC8", .F.)
			Else
				RecLock("AC8", .T.)
			EndIf
			AC8->AC8_FILIAL := xFilial("AC8")
			AC8->AC8_FILENT := xFilial("SA1")
			AC8->AC8_ENTIDA := "SA1"
			AC8->AC8_CODENT := HU5->HU5_CLIENTE + HU5->HU5_LOJA
			AC8->AC8_CODCON := cCodCon
			AC8->(MsUnlock())
			ConOut("PALMJOB:  " + Space(4) + "Contato " + cCodCon + " cadastrado com sucesso.")
			HHSaveLog(HGU->HGU_GRUPO, HGU->HGU_SERIE, If(HU5->HU5_STATUS = "N",1030,1031), .T., "Contato " + cCodCon)
			dbSelectArea("HU5")	
			RecLock("HU5",.F.)
			HU5->HU5_STATUS := "P"
			HU5->HU5_INTR := "X"
			MsUnlock()
		Else
			ConOut("PALMJOB:  " + Space(4) + "ATENCAO: Contato nao cadastrado !!!")
			HHSaveLog(HGU->HGU_GRUPO, HGU->HGU_SERIE, 1032, .T.)
		EndIf

	Else
		ConOut("PALMJOB:  " + Space(4) + "ATENCAO: Cliente deste contato nao cadastrado !!!")
	EndIf
	dbSelectArea("HU5")
	dbSkip()
EndDo
Set Filter to
Return
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ HHImpMsg ³ Autor ³ Marcelo Vieira        ³ Data ³ 10.08.01 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Importacao das mensagens do Palm Pilot                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ HHImpMsg                                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³                             	                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Generico                                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³         ATUALIZACOES SOFRIDAS DESDE A CONSTRU€AO INICIAL.             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Programador ³ Data   ³ BOPS ³  Motivo da Alteracao                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³            ³  /  /  ³      ³                                          ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
User Function XIMPHMV()
Local aMensagem  := {} // Contem os dados do arquivo de Mensagens
Local aArquivos  := {}
Local i          := 0
//Local cPathPalm  := GetSrvProfString("HandHeldDir","\HANDHELD\") + "P" + AllTrim(HGU->HGU_DIR) + "\atual\"
Local cVend      := HGU->HGU_CODBAS
Local cPath      := ""
Local cCodMsg    := ""
Local cFiltro    := ""
Local cAliasMsg  := ""
Local cPrefixCpo := ""
Local cFileMsg   := "HMV" + cEmpAnt + "0"
Local nMaxVer := 0

cAliasMsg  := GetMv("MV_TBLMSG",,"")
cPrefixCpo := Subs(cAliasMsg,2,2)+"_"

aAdd(aArquivos, { cFileMsg, "HMV", "HMV_COD"})
	
ConOut("PALMJOB: " + Space(4) + "Importando Mensagens para " + Trim(HHU->HHU_NOMUSR))
If Empty(cAliasMsg)
	ConOut("PALMJOB: " + Space(4) + "Tabela de mensagens nao definida ( verifique o parametro MV_TBLMSG )" )
	Return
Endif

dbSelectArea("HMV")
dbSetOrder(1)
cFiltro := "HMV_STATUS = 'N' .Or. HMV_STATUS = 'A' "
Set Filter to &cFiltro
While HMV->(!Eof())
	If HMV->HMV_STATUS = "N"
		cCodMsg := GetSxeNum(cAliasMsg, cPrefixCpo + "CODMSG")
		dbSelectArea(cAliasMsg)
		dbSetOrder(1)
		While (cAliasMsg)->( dbSeek(xFilial(cAliasMsg) + cCodMsg))
			ConfirmSX8()
			cCodMsg := GetSxeNum(cAliasMsg, cPrefixCpo + "CODMSG")
			dbSkip()
		EndDo	  		
	ElseIf 	HMV->HMV_STATUS = "A"
		cCodMsg := MSG->HMV_CODMSG
	Else	  	
		dbSelectArea("HMV")
		dbSetOrder(1)	  	
		dbSkip()
		Loop	
	EndIf	

	dbSelectArea(cAliasMsg)
	dbSetOrder(1)

	If HMV->HMV_STATUS = "N"
		(cAliasMsg)->( RecLock(cAliasMsg,.T.) )
	Else
		If dbSeek(xFilial(cAliasMsg)+cCodMsg + MSG->Z6_ORIMSG + cVend )
			(cAliasMsg)->( RecLock(cAliasMsg,.F.) )	
		EndIf
	EndIf

	(cAliasMsg)->&(cPrefixCpo+"FILIAL")  := xFilial(cAliasMsg)
	(cAliasMsg)->&(cPrefixCpo+"CODMSG")  := cCodMsg
	(cAliasMsg)->&(cPrefixCpo+"CODVEND") := HMV->HMV_VEND
	(cAliasMsg)->&(cPrefixCpo+"DATAMSG") := HMV->HMV_DATA
	(cAliasMsg)->&(cPrefixCpo+"DATAVIG") := HMV->HMV_DTVIG
	(cAliasMsg)->&(cPrefixCpo+"ORIMSG")  := HMV->HMV_ORI
	(cAliasMsg)->&(cPrefixCpo+"MENSAGE") := HMV->HMV_MSG
	(cAliasMsg)->(MsUnlock())

	If (cAliasMsg)->( dbSeek(xFilial(cAliasMsg)+ cCodMsg ) .And. HMV->HMV_STATUS $ "N" )
		ConfirmSX8()
		ConOut("PALMJOB: " + Space(4) + "Mensagem " + cCodMsg + " cadastrada com sucesso.")
		HHSaveLog(HGU->HGU_GRUPO, HGU->HGU_SERIE, 1040, .T., "Mensagem " + cCodMsg)
		dbSelectArea("HMV")	
		RecLock("HMV",.F.)
		HMV->HMV_STATUS := "P"
		HMV->HMV_INTR := "E"
		HMV->HMV_VER  	:= nMaxVer := HHGenericUpd(HMV->HMV_VEND,"HMV")
		HMV->(MsUnlock())
		HHAtuCtr(HMV->HMV_VEND, "HMV", nMaxVer)
	Else
		ConOut("PALMJOB: " + Space(4) + "ATENCAO: Mensagem nao cadastrada !!!")
		HHSaveLog(HGU->HGU_GRUPO, HGU->HGU_SERIE, 1041, .T.)
	EndIf

	dbSelectArea("HMV")
	HMV->(dbSkip())
EndDo
HMV->(dbCloseArea())
Set Filter to
Return
