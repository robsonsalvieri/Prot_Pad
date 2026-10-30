#INCLUDE "TFATR03.ch"
#INCLUDE "rwmake.ch"

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณTFATR03   บ Autor ณ Jose Maria         บ Data ณ  02/09/04   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ Relatorio para impressao da Tabela de Precos               บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Especifico - Koraicho                                      บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/

Template Function TFATR03()

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Declaracao de Variaveis                                             ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู

Local cDesc1         := STR0001 //"Este programa tem como objetivo imprimir relatorio "
Local cDesc2         := STR0002 //"de acordo com os parametros informados pelo usuario."
Local cDesc3         := STR0003 //"TABELA DE PRECOS"
Local cPict          := ""
Local titulo       := STR0003 //"TABELA DE PRECOS"
Local nLin         := 80
Local Cabec1       := ""
Local Cabec2       := STR0004 //" PRODUTO          DESCRICAO                                REFERENCIA      UM  PRECO MINIMO PRECO MAXIMO UM2 %DESC2 VAL_DESC2    UM3 %DESC3 VAL_DESC3    REVISAO  SIT  GRUPO                          FABRICANTE     "
Local imprime      := .T.

CHKTEMPLATE("DCM")  

Private aOrd             := {STR0005,STR0006} //"Descricao"###"Codigo"
Private lEnd         := .F.
Private lAbortPrint  := .F.
Private limite           := 220
Private tamanho          := "G"
Private nomeprog         := "TFATR03" // Coloque aqui o nome do programa para impressao no cabecalho
Private nTipo            := 15
Private aReturn          := { STR0007, 1, STR0008, 1, 2, 1, "", 1} //"Zebrado"###"Administracao"
Private nLastKey        := 0
Private cbtxt      := Space(10)
Private cbcont     := 00
Private CONTFL     := 01
Private m_pag      := 01
Private wnrel      := "TFATR03" // Coloque aqui o nome do arquivo usado para impressao em disco
Private cPerg     :=  Padr("FATR03",Len(SX1->X1_GRUPO))
Private cString := "SB0"

DbSelectArea("SB0")
DbSetOrder(1)

//******************************************************************
//  PARAMETROS
//******************************************************************
//  MV_PAR01             CODIGO   ?
//- Especifico Koraicho  MV_PAR02             FORNECEDOR    ?
//  MV_PAR02             ALFABETICA POR FABRICANTE  ?
//  MV_PAR03             CONSIDERA PRECO ZERO   ?
//  MV_PAR04             CONSIDERA ESTOQ. DISPONIVEL   ?
//  MV_PAR05             SITUACAO PRODUTO ?
//  MV_PAR06             FAMILIA / GRUPO ?
//- Especifico Koraicho  MV_PAR07             ALFABETICA POR FABRICANTE  ?
//******************************************************************

Pergunte(cPerg,.F.)
// mv_par01 = "Grupo Atendimento       ?" (F3 = "SU0")
// //- especifico Koraicho: mv_par02 = "Fornecedor              ?" (F3 = "SA2")
// mv_par02 = "Agrupar Fabric x Prod.  ?" ("Sim";"Nao")
// mv_par03 = "Considera Preco Zero    ?" ("Sim";"Nao")
// mv_par04 = "Cons.Estoque Disponivel ?" ("Sim";"Nao")
// mv_par05 = "Situacao do Produto     ?" (F3 = "T2")
// mv_par06 = "Grupo                   ?" (F3 = "SBM")
// //- especifico Koraicho mv_par07 = "Agrupar Fabric x Prod.  ?" ("Sim";Nao")

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Monta a interface padrao com o usuario...                           ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู

wnrel := SetPrint(cString,NomeProg,cPerg,@titulo,cDesc1,cDesc2,cDesc3,.F.,,.F.,Tamanho,,.F.)

If nLastKey == 27
	Return
Endif

SetDefault(aReturn,cString)

If nLastKey == 27
	Return
Endif

nTipo := If(aReturn[4]==1,15,18)

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Processamento. RPTSTATUS monta janela com a regua de processamento. ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู

RptStatus({|| RunReport(Cabec1,Cabec2,Titulo,nLin) },Titulo)
Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบFuno    ณRUNREPORT บ Autor ณ AP6 IDE            บ Data ณ  06/09/04   บฑฑ
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

Local nOrdem
//
// ANTES DO DIA 08-10-04  ZEMARIA
//_cQuery :=  "SELECT *  FROM "+RetSqlName("SB0")+" SB0  WHERE        "
//_cQuery += " SUBSTRING(SB0.B0_COD,1,6)      = '" + MV_PAR02 + "' AND"
//_cQuery += " SB0.D_E_L_E_T_ <> '*' "
//_cQuery += " ORDER BY B0_COD"
//_cQuery := ChangeQuery(_cQuery)
//

DbSelectArea("SU0")
DbSetOrder(1)
DbSeek(xFilial("SU0")+MV_PAR01,.T.)
                                          
If Eof() .OR. RecCount() == 0 .OR. Empty(MV_PAR01)
	MsgBox("Grupo Atendimento nao Localizado, ou Tabela Grupo Atendimento (SU0) esta vazia!")
	Return
Endif       

//_cPRCMIN  := "QRB->B0_PRV"+AllTrim(STR(SU0->U0_TABMIN))
//_cPRCMAX  := "QRB->B0_PRV"+AllTrim(STR(SU0->U0_TABMAX))

If MV_PAR04 == 1  //CONSIDERA ESTOQUE DISPONIVEL = SIM
	_cQuery := "SELECT B0_ULTREVI,B0_COD,B1_DESC,B1_CODITE,B1_UM,B1_SEGUM,B1_UM3,B1_UM4,B1_CONV,B1_UM3FAT,B1_UM4FAT, "
	_cQuery += " B1_SITPROD,B1_GRUPO,B1_FABRIC,B0_PRV"+AllTrim(STR(SU0->U0_TABMIN))+",B0_PRV"+AllTrim(STR(SU0->U0_TABMAX))+", "
	_cQuery += " LH7_DU2"+MV_PAR01+",LH7_DU3"+MV_PAR01+", "
	_cQuery += " (SELECT SUM(B2_QATU-B2_RESERVA) FROM "+RetSqlName("SB2")+" SB2 WHERE SB2.B2_COD = SB1.B1_COD AND SB2.D_E_L_E_T_ = ' ') AS ESTOQUE "
	_cQuery += " FROM "+RetSqlName("SB0")+" SB0,"+RetSqlName("SB1")+" SB1,"+RetSqlName("LH7")+" LH7  WHERE  "
	If !Empty(MV_PAR05)
		_cQuery += " SB1.B1_SITPROD = '"+MV_PAR05+"' AND "
	Endif
	If !Empty(MV_PAR06)
		_cQuery += " SB1.B1_GRUPO   = '"+MV_PAR06+"' AND "
	Endif
	//If !Empty(MV_PAR02)
	//	_cQuery += " SUBSTRING(SB0.B0_COD,1,6) = '"+MV_PAR02+"' AND SB1.B1_COD = SB0.B0_COD AND LH7.LH7_COD = SB0.B0_COD AND "
	//Else
		_cQuery += " SB1.B1_COD = SB0.B0_COD AND LH7.LH7_COD = SB0.B0_COD AND "
	//Endif
	_cQuery += " SB1.D_E_L_E_T_   = ' '  AND "
	_cQuery += " SB0.D_E_L_E_T_   = ' '  AND "
	_cQuery += " LH7.D_E_L_E_T_   = ' '      "
ELSE              //CONSIDERA ESTOQUE DISPONIVEL = NAO
	_cQuery := "SELECT B0_ULTREVI,B0_COD,B1_DESC,B1_CODITE,B1_UM,B1_SEGUM,B1_UM3,B1_UM4,B1_CONV,B1_UM3FAT,B1_UM4FAT, "
	_cQuery += " B1_SITPROD,B1_GRUPO,B1_FABRIC,B0_PRV"+AllTrim(STR(SU0->U0_TABMIN))+",B0_PRV"+AllTrim(STR(SU0->U0_TABMAX))+", "
	_cQuery += " LH7_DU2"+MV_PAR01+",LH7_DU3"+MV_PAR01+" "
	_cQuery += " FROM "+RetSqlName("SB0")+" SB0,"+RetSqlName("SB1")+" SB1,"+RetSqlName("LH7")+" LH7  WHERE  "
	If !Empty(MV_PAR05)
		_cQuery += " SB1.B1_SITPROD = '"+MV_PAR05+"' AND "
	Endif
	If !Empty(MV_PAR06)
		_cQuery += " SB1.B1_GRUPO   = '"+MV_PAR06+"' AND "
	Endif
	//If !Empty(MV_PAR02)
	//	_cQuery += " SUBSTRING(SB0.B0_COD,1,6) = '"+MV_PAR02+"' AND SB1.B1_COD = SB0.B0_COD AND LH7.LH7_COD = SB0.B0_COD AND "
	//Else
		_cQuery += " SB1.B1_COD = SB0.B0_COD AND LH7.LH7_COD = SB0.B0_COD AND "
	//Endif
	_cQuery += " SB1.D_E_L_E_T_     = ' '  AND "
	_cQuery += " SB0.D_E_L_E_T_     = ' '  AND "
	_cQuery += " LH7.D_E_L_E_T_     = ' '  "
ENDIF
IF MV_PAR02=1
   _cQuery += " ORDER BY B1_FABRIC,B0_COD "
ELSE
   _cQuery += " ORDER BY B0_COD "
ENDIF   

_cQuery := ChangeQuery(_cQuery)
dbUseArea(.T., "TOPCONN", TCGenQry(,,_cQuery), 'QRB', .F., .T.)

TcSetField("QRB","B0_ULTREVI","D")

DbSelectArea("QRB")
SetRegua(RecCount())
DbGoTop()

//                                                                                                     1         1         1         1         1         1         1         1         1         1         2         2         2
//           1         2         3         4         5         6         7         8         9         0         1         2         3         4         5         6         7         8         9         0         1         2
// 01234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890
//                                                                                                                                                         DT.ULTMA
// PRODUTO          DESCRICAO                                REFERENCIA      UM  PRECO MINIMO PRECO MAXIMO UM2 %DESC2 VAL_DESC2    UM3 %DESC3 VAL_DESC3    REVISAO  SIT  GRUPO                          FABRICANTE
//
// XXXXXXXXXXXXXXXX XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX xxxxxxxxxxxxxxx XX  000000000.00 000000000.00 XX   00.00 000000000.00 XX   00.00 000000000.00 00/00/00  XX  XXXXXXXXXXXXXXXXXXXXXXXXXXXXX  XXXXXXXXXXXXXXXXXXXX
//

Cabec1       := "GRP : "+MV_PAR01+" - "+GETADVFVAL("SU0","U0_NOME",XFILIAL("SU0")+MV_PAR01,1)  //+"      FORNEC. : "+MV_PAR02+" - "+GETADVFVAL("SA2","A2_NREDUZ",XFILIAL("SA2")+MV_PAR02,1)

DbSelectArea("SU0")
DbSetOrder(1)
DbSeek(xFilial("SU0")+MV_PAR01,.T.)

_cPRCMIN  := "QRB->B0_PRV"+AllTrim(STR(SU0->U0_TABMIN))
_cPRCMAX  := "QRB->B0_PRV"+AllTrim(STR(SU0->U0_TABMAX))

DbSelectArea("QRB")

While !Eof()
	
	IncRegua()
	
	If lAbortPrint
		@nLin,00 PSAY "*** CANCELADO PELO OPERADOR ***"
		Exit
	Endif
	
	If MV_PAR04 == 1 .and. QRB->ESTOQUE <= 0   //CONSIDERA ESTOQUE DISPONIVEL = SIM
		dBSkip()
		Loop
	Endif
	
	IF MV_PAR03 == 1 .And. &_cPRCMIN = 0  //Considera preco Zero = Sim
		DbSkip()
		Loop
	Endif
	
	If nLin > 55 // Salto de Pแgina. Neste caso o formulario tem 55 linhas...
		Cabec(Titulo,Cabec1,Cabec2,NomeProg,Tamanho,nTipo)
		nLin := 8
	Endif
	//dBSelectArea("LH7")
	//dBSeek(xFilial("LH7")+QRB->B0_COD,.T.)
	_nLH7DU2  := "QRB->LH7_DU2"+MV_PAR01      //"LH7->LH7_DU2"+MV_PAR01
	_nLH7DU3  := "QRB->LH7_DU3"+MV_PAR01      //"LH7->LH7_DU3"+MV_PAR01
	//_nLH7DU4  := "QRB->LH7_DU4"+MV_PAR01    //"LH7->LH7_DU4"+MV_PAR01   conforme Sueli sera trata somente em compras
	//-----------------------------------------------------------------------------
	_nB1_CONV   := QRB->B1_CONV   //GETADVFVAL("SB1","B1_CONV",xFILIAL("SB1")+QRB->B0_COD,1)
	_nB1_UM3FAT := QRB->B1_UM3FAT //GETADVFVAL("SB1","B1_UM3FAT",xFILIAL("SB1")+QRB->B0_COD,1)
	//_nB1_UM4FAT := QRB->B1_UM4FAT //GETADVFVAL("SB1","B1_UM4FAT",xFILIAL("SB1")+QRB->B0_COD,1)
	//-----------------------------------------------------------------------------
	_nDESCUM2   := (&_cPRCMIN*_nB1_CONV  ) * ((100-&_nLH7DU2)/100)
	_nDESCUM3   := (&_cPRCMIN*_nB1_UM3FAT) * ((100-&_nLH7DU3)/100)
	//_nDESCUM4   := (&_cPRCMIN*_nB1_UM4FAT) *                        //((100-&_nLH7DU4)/100)
	//-----------------------------------------------------------------------------
	DbSelectArea("QRB")
	
	@ nLin, 001 PSAY QRB->B0_COD
	@ nLin, 017 PSAY QRB->B1_DESC                //GETADVFVAL("SB1","B1_DESC",xFILIAL("SB1")+QRB->B0_COD,1)
	@ nLin, 058 PSAY SUBSTR(QRB->B1_CODITE,1,15) //SUBSTR(GETADVFVAL("SB1","B1_CODITE",xFILIAL("SB1")+QRB->B0_COD,1),1,15)
	@ nLin, 074 PSAY QRB->B1_UM                  //GETADVFVAL("SB1","B1_UM",xFILIAL("SB1")+QRB->B0_COD,1)
	@ nLin, 078 PSAY &_cPRCMIN     Picture "@e 999999999.99"
	@ nLin, 091 PSAY &_cPRCMAX     Picture "@e 999999999.99"
	@ nLin, 104 PSAY QRB->B1_SEGUM //GETADVFVAL("SB1","B1_SEGUM",xFILIAL("SB1")+QRB->B0_COD,1)
	@ nLin, 109 PSAY &_nLH7DU2     Picture "@e 99.99"
	@ nLin, 115 PSAY _nDESCUM2     Picture "@e 999999999.99"
	@ nLin, 128 PSAY QRB->B1_UM3   //GETADVFVAL("SB1","B1_UM3",xFILIAL("SB1")+QRB->B0_COD,1)
	@ nLin, 133 PSAY &_nLH7DU3     Picture "@e 99.99"
	@ nLin, 139 PSAY _nDESCUM3     Picture "@e 999999999.99"
	@ nLin, 152 PSAY dToc(QRB->B0_ULTREVI)
	@ nLin, 162 PSAY QRB->B1_SITPROD
	@ nLin, 166 PSAY GetAdvFVal("SBM","BM_DESC",xFilial("SBM")+QRB->B1_GRUPO,1)
	@ nLin, 197 PSAY QRB->B1_FABRIC
	
	nLin := nLin + 1 // Avanca a linha de impressao
	dbSkip() // Avanca o ponteiro do registro no arquivo
EndDo

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Finaliza a execucao do relatorio...                                 ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู

SET DEVICE TO SCREEN

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Se impressao em disco, chama o gerenciador de impressao...          ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู

SETPGEJECT(.T.)

If aReturn[5]==1
   //	dbCommitAll()
	SET PRINTER TO
	OurSpool(wnrel)
Endif

MS_FLUSH()

#IFDEF TOP
	dBSelectArea("QRB")
	dBCloseArea()
#ENDIF

Return