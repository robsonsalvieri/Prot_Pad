#INCLUDE "tcomr03.ch"
#INCLUDE "rwmake.ch"
#INCLUDE "TOPCONN.CH"

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ TCOMR03  บ Autor ณ Ewerton C Tomaz    * Data ณ  06/02/04   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ Ponto de entrada para relatorio de ponto de pedido         บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP5 IDE                                                    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/

Template Function TCOMR03()

CHKTEMPLATE("DCM")  

If Upper(cUserName) $ Alltrim(GetMv('MV_USUCOM'))
	T_TCOMR03b(1)
Endif                  
Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ TCOMR03b บ Autor ณ Ewerton C Tomaz    * Data ณ  06/02/04   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ                                                            บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/

Template Function TCOMR03b(_nTipo)

CHKTEMPLATE("DCM")  

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Declaracao de Variaveis                                             ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู

Private CbTxt        := ""
Private lEnd         := .F.
Private lAbortPrint  := .F.
Private limite       := 132
Private tamanho      := "M"
Private nomeprog     := "TCOMR03"
Private nTipo        := 18
Private aReturn      := { STR0001, 1, STR0002, 2, 2, 1, "", 1} //"Zebrado"###"Administracao"
Private aOrd         := {}
Private nLastKey     := 0
Private cString      := "SB1"
Private wnrel        := "TCOMR03"
Private cDesc1       := STR0003 //"Este programa tem como objetivo imprimir relatorio "
Private cDesc2       := STR0004 //"de ponto de pedido."
Private cDesc3       := ""
Private cPict        := ""
Private imprime      := .T.
Private titulo       := STR0005 //"Ponto de Pedido - Fabricante"
Private nLin         := 80
Private cbcont       := 00
Private CONTFL       := 01
Private m_pag        := 01
Private Cabec1       := STR0006 //"Fabricante      Produto         Descricao                                                     UM   |  Minimo | Vendas |  Total"
Private Cabec2       := ""
Private PRICOMP      := Space(08)
Private _nPTipo      := IIF(_nTipo=nil,2,_nTipo)

//                         Fabricante      Produto                        Descricao                                                     UM   |  Minimo | Vendas |  Total
//                         123456789012345 123456789012345678901234567890 123456789012345678901234567890123456789012345678901234567890  12   |  999999 | 999999 | 999999
//                         01234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789
//                                   1         2         3         4         5         6         7         8         9         0         1         2         3
If _nPTipo == 1
	DbSelectArea("SX6")
	Dbsetorder(1)
	if GetMV("MV_PRICOMP", .T.)
		PRICOMP := GETMV("MV_PRICOMP")
	Endif
	If ALLTRIM(PRICOMP) == ALLTRIM(DTOS(DDATABASE))
		Return
	EndIf
Endif

wnrel := SetPrint(cString,NomeProg,"",@titulo,cDesc1,cDesc2,cDesc3,.F.,,.F.,Tamanho,,.F.)

If nLastKey == 27
	DbCloseArea()
	Return
Endif

SetDefault(aReturn,cString)

If nLastKey == 27
	DbCloseArea()
	Return
Endif

nTipo := If(aReturn[4]==1,15,18)

RptStatus({|| RunReport(Cabec1,Cabec2,Titulo,nLin) },Titulo)   

DbCloseArea()

If _nPTipo == 1
	PutMV("MV_PRICOMP",DTOS(DDATABASE))
Endif
Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบFuno    ณRUNREPORT บ Autor ณ AP5 IDE            บ Data ณ  09/08/01   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescrio ณ Funcao auxiliar chamada pela RPTSTATUS. A funcao RPTSTATUS บฑฑ
ฑฑบ          ณ monta a janela com a regua de processamento.               บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Programa principal                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/

Static Function RunReport(Cabec1,Cabec2,Titulo,nLin)
Local _nX

Private nTotal := 0

DbSelectArea("SB1")

cQueryCad := "SELECT B1_FABRIC AS FORNEC, B1_COD, B1_DESC, B1_UM, B1_EMIN, B1_UPRC, "
cQueryCad += "ISNULL((SELECT SUM(B2_QATU-B2_RESERVA) FROM "+RetSqlName("SB2")+" B2  WHERE B2_COD = B1_COD AND B2.D_E_L_E_T_ <> '*' ),0) AS ESTTOT, "
cQueryCad += "ISNULL((SELECT SUM(LFW_QUANT) FROM "+RetSqlName("LFW")+" LFW  WHERE LFW.D_E_L_E_T_ <> '*' AND LFW.LFW_FILIAL = '"+xFilial("LFW")+"' AND LFW.LFW_PRODUT = B1.B1_COD AND LFW.LFW_ANO = '"+SubStr(DTOS(dDatabase),1,4)+"' AND LFW.LFW_MES = '"+SubStr(DTOS(dDatabase),5,2)+"' ),0) AS ESTVEN "
cQueryCad += "FROM "+RetSqlName("SB1")+" B1 WHERE  "
cQueryCad += "B1.D_E_L_E_T_ <> '*' AND "
cQueryCad += "B1.B1_FILIAL = '"+xFilial("SB1")+"' AND "
cQueryCad += "B1_EMIN <> 0 AND "
cQueryCad += "B1_EMIN >= ISNULL((SELECT SUM(B2_QATU-B2_RESERVA) FROM "+RetSqlName("SB2")+" B23  WHERE B2_COD = B1_COD AND B23.D_E_L_E_T_ <> '*' ),0) AND "
cQueryCad += "NOT EXISTS (SELECT 'EX' FROM "+RetSqlName("SC7")+" C7  WHERE C7.D_E_L_E_T_ <> '*' AND C7_PRODUTO = B1_COD AND C7_QUANT > C7_QUJE AND C7_ENCER <> 'E' AND C7_RESIDUO <> 'S' ) "
cQueryCad += "ORDER BY B1_FABRIC, B1_COD "

cQueryCad := ChangeQuery(cQueryCad)

TCQUERY cQueryCad NEW ALIAS "CAD"

DbSelectArea("CAD")
DbGoTop()

_aTotMarca := {}

While !EOF()
	If nLin > 55
		Cabec(Titulo,Cabec1,Cabec2,NomeProg,Tamanho,nTipo)
		nLin := 8
	Endif
   // Fabricante      Produto                        Descricao                                                     UM   |  Minimo | Vendas |  Total
   // 123456789012345 123456789012345678901234567890 123456789012345678901234567890123456789012345678901234567890  12   |  999999 | 999999 | 999999
   // 01234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789
   //           1         2         3         4         5         6         7         8         9         0         1         2         3
	@ nLin,000 PSAY SubStr(CAD->FORNEC,1,15)
	@ nLin,016 PSAY CAD->B1_COD
	@ nLin,047 PSAY CAD->B1_DESC
	@ nLin,109 PSAY CAD->B1_UM	
	@ nLin,114 PSAY "|"
	@ nLin,117 PSAY CAD->B1_EMIN Picture "@ER 999999"
	@ nLin,124 PSAY "|"
	@ nLin,126 PSAY CAD->ESTVEN  Picture "@ER 999999"
	@ nLin,133 PSAY "|"
	@ nLin,135 PSAY CAD->ESTTOT  Picture "@ER 999999"
	
	_nPosMarca := AsCan(_aTotMarca,{|x|x[1]=SubStr(CAD->FORNEC,1,15)})
	If _nPosMarca = 0
		AaDd(_aTotMarca,{SubStr(CAD->FORNEC,1,15),((CAD->B1_EMIN-CAD->ESTTOT)*CAD->B1_UPRC)})
	Else
		_aTotMarca[_nPosMarca,2] += ((CAD->B1_EMIN-CAD->ESTTOT)*CAD->B1_UPRC)
	Endif
	nLin ++
	_cFornec := CAD->FORNEC
	DbSkip()
	If _cFornec <> CAD->FORNEC
		nLin ++
	Endif
End
nLin += 2
If nLin > 55
	Cabec(Titulo,Cabec1,Cabec2,NomeProg,Tamanho,nTipo)
	nLin := 8
Endif
@ nLin, 000 PSAY "RESUMO DE VALORES - FABRICANTE"
nLin += 2
ASort(_aTotMarca,,,{|x,y|x[2]>y[2]})
For _nX := 1 To Len(_aTotMarca)
	@ nLin, 000 PSAY _aTotMarca[_nX,1]
	@ nLin, 020 PSAY _aTotMarca[_nX,2] Picture IIf(_aTotMarca[_nX,2]>0,"@ER 999,999,999.99","@ER 999,999,999.99 <- Informar Ultimo Preco de Compra")
	nLin ++
	If nLin > 55
		Cabec(Titulo,Cabec1,Cabec2,NomeProg,Tamanho,nTipo)
		nLin := 8
	Endif
Next

RODA(CBCONT,CBTXT)
SET DEVICE TO SCREEN

If aReturn[5]==1
//dbCommitAll()
	SET PRINTER TO
	OurSpool(wnrel)
Endif

MS_FLUSH()
Return