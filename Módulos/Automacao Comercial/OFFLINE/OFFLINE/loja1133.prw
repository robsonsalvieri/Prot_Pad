#INCLUDE "PROTHEUS.CH"
/* 
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³LJ1133AdM1 ºAutor  ³ Vendas Cliente   º Data ³  08/23/05   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Valida os itens digitados ou selecionados no panel 3       º±±
±±º          ³que contem os produtos a serem trocados/devolvidos.         º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºParametros³ExpC1 - Alias do arquivo temporario.                        º±±
±±º          ³ExpA2 - Array com o Recno e a quantidade a ser devolvida    º±±
±±º          ³ExpN3 - Valor total de mercadorias.                         º±±
±±º          ³ExpN4 - Recno da area de trabalho                           º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ SIGALOJA - VENDA ASSISTIDA                                 º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/


Function LJ1133AdM1 ()

Local lRet := .T.
Local aMd1 := {}
Local aEstrut	:= {}
Local i 	:= 0
Local j	:= 0


aEstrut := {"MD1_FILIAL" , "MD1_CODIGO"	, "MD1_DESCRI"	, "MD1_TIPO", "MD1_ENABLE"}
				
Aadd(aMd1,{	xFilial("MD1"), "001"		, "CAD PROCESSOS"	, "I"			, .F.})
Aadd(aMd1,{	xFilial("MD1"), "002"		, "CAD PRAC X TAB"	, "I"			, .F.})
Aadd(aMd1,{	xFilial("MD1"), "003"		, "CAD WS"			, "I"			, .F.})
Aadd(aMd1,{	xFilial("MD1"), "004"		, "CAD AMBIENTES"	, "I"			, .F.})
Aadd(aMd1,{	xFilial("MD1"), "005"		, "CAD PROC X AMB"	, "I"			, .F.})
Aadd(aMd1,{	xFilial("MD1"), "006"		, "VENDA ASSISTIDA"	, "I"			, .F.})
Aadd(aMd1,{	xFilial("MD1"), "007"		, "CLIENTES"		, "I"			, .F.})
Aadd(aMd1,{	xFilial("MD1"), "008"		, "DEVOLUCAO"		, "I"			, .F.})
Aadd(aMd1,{	xFilial("MD1"), "009"		, "RESUMO REDUCAO"	, "I"			, .F.})
Aadd(aMd1,{	xFilial("MD1"), "010"		, "PRECO E PRODUTO"	, "I"			, .F.})
Aadd(aMd1,{	xFilial("MD1"), "011"		, "CODIGO DE BARRA"	, "I"			, .F.})
Aadd(aMd1,{	xFilial("MD1"), "012"		, "ADM FINANCEIRA"	, "I"			, .F.})
Aadd(aMd1,{	xFilial("MD1"), "013"		, "COND PAGAMENTO"	, "I"			, .F.})
Aadd(aMd1,{	xFilial("MD1"), "014"		, "TES"				, "I"			, .F.})
Aadd(aMd1,{	xFilial("MD1"), "015"		, "BANCOS"			, "I"			, .F.})
Aadd(aMd1,{	xFilial("MD1"), "016"		, "CAIXA"			, "I"			, .F.})
Aadd(aMd1,{	xFilial("MD1"), "017"		, "SENHAS"			, "I"			, .F.})
Aadd(aMd1,{	xFilial("MD1"), "018"		, "BAIXA DE TITULO"	, "I"			, .F.})	
	

DbSelectArea("MD1")

For i:= 1 To Len(aMD1)
	RecLock("MD1",.T.)
	For j:=1 To Len(aMD1[i])
		If FieldPos(aEstrut[j])>0
			FieldPut(FieldPos(aEstrut[j]),aMD1[i,j])
		EndIf
	Next j
	dbCommit()
	MsUnLock()
Next i    


Return(lRet)


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³LJ1133AdM2 ºAutor  ³ Vendas Cliente   º Data ³  08/23/05   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Valida os itens digitados ou selecionados no panel 3       º±±
±±º          ³que contem os produtos a serem trocados/devolvidos.         º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºParametros³ExpC1 - Alias do arquivo temporario.                        º±±
±±º          ³ExpA2 - Array com o Recno e a quantidade a ser devolvida    º±±
±±º          ³ExpN3 - Valor total de mercadorias.                         º±±
±±º          ³ExpN4 - Recno da area de trabalho                           º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ SIGALOJA - VENDA ASSISTIDA                                 º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/


Function LJ1133AdM2 ()

Local aMd2 := {}
Local aEstrut	:= {}
Local i 	:= 0
Local j	:= 0


aEstrut := {"MD2_FILIAL" , "MD2_PROCES"	, "MD2_TABELA"	, "MD2_ENABLE"}
				

Aadd(aMd2,{	xFilial("MD2"), "001"		, "MD1"	,  .T.})
Aadd(aMd2,{	xFilial("MD2"), "002"		, "MD2"	,  .T.})
Aadd(aMd2,{	xFilial("MD2"), "003"		, "MD3"	,  .T.})
Aadd(aMd2,{	xFilial("MD2"), "004"		, "MD4"	,  .T.})
Aadd(aMd2,{	xFilial("MD2"), "005"		, "MD5"	,  .T.})
Aadd(aMd2,{	xFilial("MD2"), "006"		, "SD2"	,  .T.})
Aadd(aMd2,{	xFilial("MD2"), "006"		, "SE1"	,  .T.})
Aadd(aMd2,{	xFilial("MD2"), "006"		, "SE5"	,  .T.})
Aadd(aMd2,{	xFilial("MD2"), "006"		, "SEF"	,  .T.})
Aadd(aMd2,{	xFilial("MD2"), "006"		, "SF2"	,  .T.})
Aadd(aMd2,{	xFilial("MD2"), "006"		, "SL1"	,  .T.})
Aadd(aMd2,{	xFilial("MD2"), "006"		, "SL2"	,  .T.})
Aadd(aMd2,{	xFilial("MD2"), "006"		, "SC0"	,  .T.})
Aadd(aMd2,{	xFilial("MD2"), "006"		, "SL4"	,  .T.})
Aadd(aMd2,{	xFilial("MD2"), "006"		, "SB2"	,  .T.})
Aadd(aMd2,{	xFilial("MD2"), "007"		, "SA1"	,  .T.})
Aadd(aMd2,{	xFilial("MD2"), "007"		, "AI0"	,  .T.})
Aadd(aMd2,{	xFilial("MD2"), "008"		, "SF1"	,  .T.})
Aadd(aMd2,{	xFilial("MD2"), "008"		, "SE5"	,  .T.})
Aadd(aMd2,{	xFilial("MD2"), "008"		, "SD1"	,  .T.})
Aadd(aMd2,{	xFilial("MD2"), "009"		, "SFI"	,  .T.})
Aadd(aMd2,{	xFilial("MD2"), "010"		, "SB0"	,  .T.})
Aadd(aMd2,{	xFilial("MD2"), "010"		, "SB1"	,  .T.})
Aadd(aMd2,{	xFilial("MD2"), "011"		, "SLK"	,  .T.})
Aadd(aMd2,{	xFilial("MD2"), "012"		, "SAR"	,  .T.})
Aadd(aMd2,{	xFilial("MD2"), "013"		, "SE4"	,  .T.})
Aadd(aMd2,{	xFilial("MD2"), "014"		, "SF4"	,  .T.})
Aadd(aMd2,{	xFilial("MD2"), "015"		, "SA6"	,  .T.})
Aadd(aMd2,{	xFilial("MD2"), "016"		, "SLF"	,  .T.})
Aadd(aMd2,{	xFilial("MD2"), "017"		, "SLF"	,  .T.})
Aadd(aMd2,{	xFilial("MD2"), "018"		, "SE1"	,  .T.})
Aadd(aMd2,{	xFilial("MD2"), "018"		, "SEF"	,  .T.})
Aadd(aMd2,{	xFilial("MD2"), "018"		, "SE5"	,  .T.})


	



DbSelectArea("MD2")

For i:= 1 To Len(aMD2)
	RecLock("MD2",.T.)
	For j:=1 To Len(aMD2[i])
		If FieldPos(aEstrut[j])>0
			FieldPut(FieldPos(aEstrut[j]),aMD2[i,j])
		EndIf
	Next j
	dbCommit()
	MsUnLock()
Next i    




/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³LJ1133ExReg ºAutor  ³ Vendas Cliente   º Data ³  08/23/05   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Valida os itens digitados ou selecionados no panel 3       º±±
±±º          ³que contem os produtos a serem trocados/devolvidos.         º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºParametros³ExpC1 - Alias do arquivo temporario.                        º±±
±±º          ³ExpA2 - Array com o Recno e a quantidade a ser devolvida    º±±
±±º          ³ExpN3 - Valor total de mercadorias.                         º±±
±±º          ³ExpN4 - Recno da area de trabalho                           º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ SIGALOJA - VENDA ASSISTIDA                                 º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Function LJ1133ExReg (cAlias)

Default cAlias := ""
DbSelectArea(cAlias)


lRet := (cAlias)->(!Eof())



Return(lRet)
