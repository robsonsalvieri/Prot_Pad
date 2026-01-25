#INCLUDE "tfatr02.ch"
#INCLUDE "rwmake.ch"

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³RFATR02   º Autor ³ EWERTON C TOMAZ    * Data ³  09/08/01   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Relatorio do filtro criado atraves da tela de pesquisa de  º±±
±±º          ³ pedidos                                                    º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP5 IDE                                                    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

Template Function TFATR02(cTitAnt,nComp)

CHKTEMPLATE("DCM")  

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Declaracao de Variaveis                                             ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
                                   
Private nCompras     := nComp
Private lEnd         := .F.
Private lAbortPrint  := .F.
Private limite       := 220
Private tamanho      := "G"
Private nomeprog     := "RFATR02"
Private nTipo        := 15
Private aReturn      := { STR0001, 1, STR0002, 1, 2, 1, "", 1} //"Zebrado"###"Administracao"
Private nLastKey     := 0
Private cbtxt        := Space(10)
Private cbcont       := 00
Private CONTFL       := 01
Private m_pag        := 01
Private cString      := "TC9"
Private wnrel        := "RFATR02"
Private aOrd           := {}
Private cDesc1         := STR0003 //"Este programa tem como objetivo imprimir relatorio "
Private cDesc2         := STR0004 //"de acordo com os parametros informados pelo usuario."
Private cDesc3         := STR0005 //"Pedidos"
Private cPict          := ""
Private imprime        := .T.
Private titulo         := cTitAnt
Private nLin           := 80
Private Cabec1         := If(nCompras=1,STR0006,; //"Pedido Item Seq Cliente Loja Requisitante         Pedido Cliente      Produto    Descricao                      Quantidade      Preco      Total Dt.Liber. Bl.Est. Bl.Cre. Bl.Pre. Conf. Vendedor Orcamento NF.Saida NF.Seri"
                                        STR0007 ) //"Pedido Item Seq Cliente Loja Requisitante         Pedido Cliente      Produto    Descricao                      Quantidade    Compras    Entrega"
Private Cabec2         := ""

//Pedido Item Seq Cliente Loja Requisitante         Pedido Cliente      Produto    Descricao                      Quantidade      Preco      Total Dt.Liber. Bl.Est. Bl.Cre. Bl.Pre. Conf. Vendedor Orcamento NF.Saida NF.Serie
//Pedido Item Seq Cliente Loja Requisitante         Pedido Cliente      Produto    Descricao                      Quantidade    Compras    Entrega
//999999 99   99  999999   99  12345678901234567890 1234567890123456789 9999999999 123456789012345678901234567890  999999.99 999,999.99 999,999.99 99/99/99   1234    1234    1234   1234    999999    999999   999999    99999
//999999 99   99  999999   99  12345678901234567890 1234567890123456789 9999999999 123456789012345678901234567890  999999.99 999,999.99   99/99/99
//01234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890
//          1         2         3         4         5         6         7         8         9         0         1         2         3         4         5         6         7         8         9         0         1         2       

DbSelectArea("TC9")
DbSetOrder(1)

wnrel := SetPrint(cString,NomeProg,"",@titulo,cDesc1,cDesc2,cDesc3,.F.,,.F.,Tamanho,,.F.)

If nLastKey == 27
	Return
Endif

SetDefault(aReturn,cString)

If nLastKey == 27
	Return
Endif

nTipo := If(aReturn[4]==1,15,18)

RptStatus({|| RunReport(Cabec1,Cabec2,Titulo,nLin) },Titulo)
Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºFun‡„o    ³RUNREPORT º Autor ³ AP5 IDE            º Data ³  09/08/01   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescri‡„o ³ Funcao auxiliar chamada pela RPTSTATUS. A funcao RPTSTATUS º±±
±±º          ³ monta a janela com a regua de processamento.               º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Programa principal                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

Static Function RunReport(Cabec1,Cabec2,Titulo,nLin)

DbSelectArea(cString)
DbSetOrder(1)

SetRegua(RecCount())

DbGoTop()

_nTotLib := 0
_nTotCon := 0
_nTotPen := 0
_nTotFat := 0
_nTotGer := 0

While !EOF()

	If lAbortPrint
		@nLin,00 PSAY STR0008 //"*** CANCELADO PELO OPERADOR ***"
		Exit
	Endif

	If nLin > 55
		Cabec(Titulo,Cabec1,Cabec2,NomeProg,Tamanho,nTipo)
		nLin := 8
	EndIf

	@ nLin,000 PSAY C9_PEDIDO
	@ nLin,007 PSAY C9_ITEM
	@ nLin,012 PSAY C9_SEQUEN
	@ nLin,016 PSAY C9_CLIENTE
	@ nLin,025 PSAY C9_LOJA
	@ nLin,029 PSAY SubStr(C5_NOMEREQ,1,20)
	@ nLin,050 PSAY SubStr(C5_REQCLI,1,19)
	@ nLin,070 PSAY SubStr(C9_PRODUTO,1,10)
	@ nLin,081 PSAY SubStr(C6_DESCRI,1,30)
	@ nLin,113 PSAY C9_QTDLIB             Picture "@ER 999999.99"
	If nCompras = 1
		@ nLin,123 PSAY C9_PRCVEN             Picture "@ER 999,999.99"
		@ nLin,134 PSAY C9_QTDLIB * C9_PRCVEN Picture "@ER 999,999.99"
		@ nLin,145 PSAY C9_DATALIB
		If C9_BLEST='02'
			@ nLin,156 PSAY 'Bloq'
			_nTotPen += (C9_QTDLIB * C9_PRCVEN)
		ElseIf C9_BLEST='10'
			@ nLin,156 PSAY 'Faturado'
			_nTotFat += (C9_QTDLIB * C9_PRCVEN)
		Else
			_nTotLib += (C9_QTDLIB * C9_PRCVEN)
		EndIf
		If C9_BLCRED='02'
			@ nLin,164 PSAY 'Bloq'
		EndIf
		If Empty(C9_BLPRE)
			@ nLin,172 PSAY 'Bloq'
		EndIf
		If !Empty(C9_BLCONF)
			@ nLin,179 PSAY 'OK'
			If Empty(C9_NFISCAL)
				_nTotCon += (C9_QTDLIB * C9_PRCVEN)
			EndIf
		EndIf
		_nTotGer += (C9_QTDLIB * C9_PRCVEN)
		@ nLin,187 PSAY C5_VEND1
		@ nLin,197 PSAY UA_NUM
		@ nLin,206 PSAY C9_NFISCAL
		@ nLin,216 PSAY C9_SERIENF
	Else
		@ nLin,123 PSAY C7_QUANT Picture "@ER 999,999.99"
		@ nLin,136 PSAY C7_DATPRF
	EndIf

	nLin := nLin + 1

	DbSkip()
End
If nCompras = 1
	If nLin > 45
		Cabec(Titulo,Cabec1,Cabec2,NomeProg,Tamanho,nTipo)
		nLin := 8
	Else
		nLin += 2
	Endif
	@ nLin,000 PSAY 'T O T A I S'
	++nLin
	@ nLin,000 PSAY 'Liberados.......:'+TransForm(_nTotLib,"@ER 9,999,999.99")
	++nLin
	@ nLin,000 PSAY 'Pendentes.......:'+TransForm(_nTotPen,"@ER 9,999,999.99")
	++nLin
	@ nLin,000 PSAY 'Faturados.......:'+TransForm(_nTotFat,"@ER 9,999,999.99")
	++nLin
	@ nLin,000 PSAY 'Conferidos N Fat:'+TransForm(_nTotCon,"@ER 9,999,999.99")
	nLin += 2
	@ nLin,000 PSAY 'Total Geral.....:'+TransForm(_nTotGer,"@ER 9,999,999.99")
EndIf
DbGoTop()

Set Device To Screen

If aReturn[5]==1
	Set Printer To
	OurSpool(wnrel)
EndIf

MS_FLUSH()
Return