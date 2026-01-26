#INCLUDE "ttmka16.ch"
#INCLUDE "rwmake.ch"
#INCLUDE "TOPCONN.CH"
#INCLUDE "COLORS.CH"

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณTTMKA16   บ Autor ณ EWERTON CARLOS TOM บ Data ณ  20/10/03   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ CONSULTA PRECO                                             บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP5 IDE                                                    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/

Template Function TTMKA16()
Private oDlgTelaPreco
Private oSay14,oSay50
Private oBmp1, oCliente

Private _cMarca   := GetMark()
Private _cCliente := Space(6)
Private _cLoja    := Space(2)
Private _cProduto := Space(75)
Private _cProdSel := Space(15)
Private _cEst     := Space(2)
Private _cCondicao:= Space(3)
Private _cFrete   := 'F' 

Private _dEmissao:= dDatabase
Private _cQuery  := ''
Private _aDados  := {}
Private _cArqTrab:= ''
Private aStru    := {}
Private _lSai    := .T.
Private _cTabs   := ''
Private _cAliasPP := 'LH7'
Private _aArea    := IIF(Alias()="SB1",SB1->(GetArea()),SX5->(GetArea()))
Private _cTESCli  := ''
Private _cLocal   := Posicione('SU0',1,xFilial('SU0')+IIf(!Empty(SA1->A1_GRUPOAT),SA1->A1_GRUPOAT,SU7->U7_POSTO),'U0_LOCPAD')
Private _cAtiv    := ''
Private _aTabs 

CHKTEMPLATE("DCM")

If M->UA_POLITIC = "1"
	_aTabs    := If(SU0->U0_TABMIN>0.And.SU0->U0_TABMAX>0,{SU0->U0_TABMIN,SU0->U0_TABMAX},{1,2})
ElseIf M->UA_POLITIC = "2"
	_aTabs    := If(SU0->U0_TABMIN2>0.And.SU0->U0_TABMAX2>0,{SU0->U0_TABMIN2,SU0->U0_TABMAX2},{1,2})
ElseIf Empty(M->UA_POLITIC)
	MsgStop("ษ preciso preencher o campo 'Polํtica'.")
	Return
EndIf
Private aCampos   := {}

AAdd(aCampos,{"T_OK","",""})
AAdd(aCampos,{"T_DESCRI",STR0001})	 //"Descri็ใo"
AAdd(aCampos,{"T_UM"    ,STR0002})	     //"UM"
AAdd(aCampos,{"T_REF"   ,STR0003})	 //"Refer๊ncia"
AAdd(aCampos,{"T_MARCA" ,STR0004})	 //"Marca"
AAdd(aCampos,{"T_PREPRO",STR0005,"@E 99999.9999"}) //"Promo็ใo"
AAdd(aCampos,{"T_EST01" ,STR0006  ,"@E 99999999"}) //"Est 01"
AAdd(aCampos,{"T_MINIMO",STR0007  ,"@E 99999.9999"}) //"Minimo"
AAdd(aCampos,{"T_SEGUM" ,STR0008}) //"Seg.UM"
AAdd(aCampos,{"T_PRESEG",STR0009,"@E 99999.9999"}) //"Pre็o UM2"
AAdd(aCampos,{"T_MAXIMO",STR0010  ,"@E 99999.9999"}) //"Maximo"
If _cLocal <> '01'
	AAdd(aCampos,{"T_EST02" ,STR0011,"@E 99999999"}) //"Est 2"
EndIf
AAdd(aCampos,{"T_PROINI",STR0012,""}) //"Inicio P. "
AAdd(aCampos,{"T_PROFIM",STR0013  ,""})		 //"Fim P."
AAdd(aCampos,{"T_CODPRO",STR0014}) //"Produto"

While _lSai
	CriaDialog(_cCliente,_cProduto,_cProdSel,_cFrete)	
End  

If Select("TCP") > 0
	DbSelectArea("TCP")
	DbCloseArea()
	FERASE(_cArqTrab+'.dbf')
Endif

RestArea(_aArea)

Return(.T.)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณLabels    บ Autor ณ EWERTON CARLOS TOM บ Data ณ  20/10/03   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP5 IDE                                                    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/

// Monta os labels da tela
Static Function Labels()
@ 04,004 SAY STR0015 //"Cliente"
@ 04,074 SAY STR0016 //"Estado"
@ 04,118 SAY STR0017 //"Cond.Pagto."
@ 02,235 SAY STR0018 //"Frete"
@ 07,235 SAY STR0019 //"(F)ob / (C)if"
@ 19,004 SAY STR0020 //"Pesquisa Produto"

oSay14                 := TSAY():Create(oDlgTelaPreco)
oSay14:cName           := "oSay9"
oSay14:cCaption        := STR0021 //"Condi็ใo"
oSay14:nLeft           := 360
oSay14:nTop            := 6
oSay14:nWidth          := 95
oSay14:nHeight         := 17
oSay14:lShowHint       := .F.
oSay14:lReadOnly       := .F.
oSay14:Align           := 0
oSay14:lVisibleControl := .T.
oSay14:lWordWrap       := .F.
oSay14:lTransparent    := .F.

Return(Nil)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณGrupos    บ Autor ณ EWERTON CARLOS TOM บ Data ณ  20/10/03   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP5 IDE                                                    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/    

// Monta os grupos da tela
Static Function Grupos()
@ 033,004 TO 203,394
@ 035,006 SAY STR0022 //"Resultado"
Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณGets      บ Autor ณ EWERTON CARLOS TOM บ Data ณ  20/10/03   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP5 IDE                                                    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/

// Monta os Gets da Tela
Static Function Gets(_cC,_cP,_cPS,_nCC,_nCF,_cF)

@ 03,004 GET _cCliente  Picture '@!' F3 'CLT' Valid ValidaGets(1,_cCliente) Size 35,15 ;
             When If(SU0->U0_CALAFRE=='S'.Or.SU0->U0_CALAFIN=='S'.Or.SU0->U0_DIFICM1>0.Or.SU0->U0_DIFICM2>0.Or.SU0->U0_DIFICM3>0,.T.,.F.)
@ 03,052 GET _cLoja     Picture '@!' Size 15,15 When .F.
@ 03,100 GET _cEst      Picture '@!' Size 15,15 When .F.
@ 03,150 GET _cCondicao Picture '@!' F3 "SE4" Valid ValidaGets(3) ;
             When If(SU0->U0_CALAFRE=='S'.Or.SU0->U0_CALAFIN=='S'.Or.SU0->U0_DIFICM1>0.Or.SU0->U0_DIFICM2>0.Or.SU0->U0_DIFICM3>0,.T.,.F.)
@ 03,270 GET _cFrete    Picture '@!' Valid (_cFrete $ "CF" .And.ValidaGets(4)) ;
             When If(SU0->U0_CALAFRE=='S'.Or.SU0->U0_CALAFIN=='S'.Or.SU0->U0_DIFICM1>0.Or.SU0->U0_DIFICM2>0.Or.SU0->U0_DIFICM3>0,.T.,.F.)
@ 18,055 GET _cProduto  Picture '@!' SIZE 155,15 Valid ValidaGets(5)

oSay14:cCaption := SubStr(SE4->E4_DESCRI,1,15)
oSay14:Refresh(.T.)                        

If !Empty(_cCliente) .And. (Empty(_cEst) .Or. Empty(_cCondicao))
	_cEst      := Posicione('SA1',1,xFilial('SA1')+_cCliente,'A1_EST')
	_cCondicao := SA1->A1_COND
EndIf

SysRefresh()

Return(Nil)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณBotoes    บ Autor ณ EWERTON CARLOS TOM บ Data ณ  20/10/03   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP5 IDE                                                    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/
// Monta os Botoes da tela
Static Function Botoes()

@ 018,356 BUTTON STR0023 SIZE 35,15 ACTION FechaCon() //"Sair"
@ 018,258 BUTTON STR0024 SIZE 35,15 ACTION RunProc()  //"Confirma"
@ 018,218 BUTTON STR0025 SIZE 35,15 ACTION T_TTMKC01(TCP->T_CODPRO) //"Todos Est."

Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณFechaCon  บ Autor ณ EWERTON CARLOS TOM บ Data ณ  20/10/03   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP5 IDE                                                    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/ 

// Fecha a tela quando for consulta                       
Static Function FechaCon()
Close(oDlgTelaPreco)
_lSai := .F.
SysRefresh()
Return (Nil)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณCriaDialogบ Autor ณ EWERTON CARLOS TOM บ Data ณ  20/10/03   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP5 IDE                                                    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/    

// Monta a tela chamando funcao por funcao
Static Function CriaDialog(_cC,_cP,_cPS,_cCC,_cCF,_cF)

oDlgTelaPreco           := MSDIALOG():Create()
oDlgTelaPreco:cName     := "oDlgTelaPreco"
oDlgTelaPreco:cCaption  := STR0026 //"Consulta Pre็os"
oDlgTelaPreco:nLeft     := 0
oDlgTelaPreco:nTop      := 0
oDlgTelaPreco:nWidth    := 796
oDlgTelaPreco:nHeight   := 436
oDlgTelaPreco:lShowHint := .F.
oDlgTelaPreco:lCentered := .T.

Labels()
Grupos()
Botoes()
Gets(_cC,_cP,_cPS,_cCC,_cCF,_cF)
Similares()
If !Empty(_cP)
	DbSelectArea("TCP")
	DbGoTop()
	@ 043,006 TO 200,392 BROWSE "TCP" MARK "T_OK" ENABLE "VerHabTK16()" FIELDS aCampos Object oBrowseSQL
	GeraDados(_cP)
	oBrowseSQL:bMark := {||Marcar()}	
EndIf

oDlgTelaPreco:Activate()
Return(Nil)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณSimilares บ Autor ณ EWERTON CARLOS TOM บ Data ณ  20/10/03   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP5 IDE                                                    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/    

// Gera os dados dos produtos similares
Static Function Similares()

If Select('TCP') > 0
	TCP->(DbCloseArea())
EndIf
aStru := {}

AAdd(aStru,{ "T_OK"    ,"C",2,0})
AAdd(aStru,{ "T_CODPRO","C",15,0})
AAdd(aStru,{ "T_DESCRI","C",40,0})
AAdd(aStru,{ "T_REF"   ,"C",15,0})
AAdd(aStru,{ "T_UM"    ,"C",02,0})
AAdd(aStru,{ "T_MARCA" ,"C",15,0})
AAdd(aStru,{ "T_MINIMO","N",14,4})
AAdd(aStru,{ "T_SEGUM" ,"C",02,0})
AAdd(aStru,{ "T_PRESEG","N",14,4})
AAdd(aStru,{ "T_MAXIMO","N",14,4})
AAdd(aStru,{ "T_EST01" ,"N",08,0})
AAdd(aStru,{ "T_EST02" ,"N",08,0})
AAdd(aStru,{ "T_PREPRO","N",14,4})
AAdd(aStru,{ "T_PROINI","D",08,0})
AAdd(aStru,{ "T_PROFIM","D",08,0})
_cArqTrab := CriaTrab(aStru, .T.)
USE &_cArqTrab ALIAS TCP NEW EXCLUSIVE

Return (Nil)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณGeraDados บ Autor ณ EWERTON CARLOS TOM บ Data ณ  20/10/03   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP5 IDE                                                    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/    

// Busca os dados do produto selecionado
Static Function GeraDados(_cP)
Local _nX, _nI
Private _aAliasSB1 := SB1->(GetArea())
Private _aAliasLH7 := LH7->(GetArea())
Private _cPS := _cP
Private _aArrayPS := STRTOARRAY(_cPS,';','C')
Private _aPreMin  := _aPreMax := {}
    
DbSelectArea("TCP")
	
If !NetERR()
	ZAP
Else
	MsgStop(STR0027) //"Nao Foi possivel o Limpar o Arquivo"
EndIF

cQuery := "SELECT TOP 100 B1_COD AS CODIGO,  B1_DESC, B1_UM, B1_SEGUM, B1_FABRIC,  "

For _nX := 1 To Len(_aTabs)
	cQuery += "ISNULL((SELECT B0_PRV"+Alltrim(Str(_aTabs[_nX]))+" AS TAB_00"+Alltrim(Str(_aTabs[_nX]))+" FROM "+RetSQLName("SB0")+" B0   WHERE B1_COD = B0_COD AND B0_FILIAL = '"+xFilial("SB0")+"' AND B0.D_E_L_E_T_ <> '*'),0) AS PRC_00"+Alltrim(Str(_aTabs[_nX]))+", "
Next
cQuery += "ISNULL((SELECT B2_QATU - B2_RESERVA AS SLD_01 FROM "+RetSQLName("SB2")+" B2   WHERE B2_FILIAL = '"+xFilial("SB2")+"' AND B2_LOCAL = '01' AND B1_COD = B2_COD AND B2.D_E_L_E_T_ <> '*'),0) AS SLD_01 "
If _cLocal <> '01'
	cQuery += ",ISNULL((SELECT B2_QATU - B2_RESERVA AS SLD_02 FROM "+RetSQLName("SB2")+" B2   WHERE B2_LOCAL = '"+_cLocal+"' AND B2_FILIAL = '"+xFilial("SB2")+"' AND B1_COD = B2_COD AND B2.D_E_L_E_T_ <> '*'),0) AS SLD_02 "
EndIf
cQuery += "FROM "+RetSQLName("SB1")+" B1  "
cQuery += "WHERE B1.D_E_L_E_T_ <> '*' "
cQuery += "AND B1_FILIAL = '"+xFilial("SB1")+"' "
cQuery += "AND B1_SITPROD NOT IN ('IN','CS') "
_aArrayDesc := {}
_aArrayForn := {}
If Len(_aArrayPS)>1
	For _nX := 1 To Len(_aArrayPS)	
		If SubStr(_aArrayPS[_nX],1,1) = '#'
			AaDd(_aArrayForn,SubStr(_aArrayPS[_nX],2))
		Else
			AaDd(_aArrayDesc,_aArrayPS[_nX])		
		Endif
	Next
	If Len(_aArrayDesc)>0
	    cQuery += "AND ("
		For _nX := 1 To Len(_aArrayDesc)
	        cQuery += "B1.B1_DESC LIKE '"+_aArrayDesc[_nX]+"%' "
			If _nX < Len(_aArrayDesc)
				cQuery += " OR "
			EndIf	
		Next
		cQuery += ") "	
	EndIf
	If Len(_aArrayForn)>0
	    cQuery += "AND ("
		For _nX := 1 To Len(_aArrayForn)
	        cQuery += "B1.B1_FABRIC LIKE '"+_aArrayForn[_nX]+"%' "
			If _nX < Len(_aArrayForn)
				cQuery += " OR "
			EndIf	
		Next
		cQuery += ") "	
	EndIf	
Else	
	If SubStr(_cPS,1,1) = '#'
	    cQuery += "AND (B1.B1_FABRIC LIKE '"+Alltrim(SubStr(_cPS,2))+"%') "
    Else
	    cQuery += "AND (B1.B1_DESC LIKE '"+Alltrim(_cPS)+"%') "    
    EndIf
EndIf
cQuery += "ORDER BY B1_DESC, B1_COD"

_aDados := QryArr(cQuery)

SLK->(DbSetOrder(3))
SB1->(DbSetOrder(1))

If Len(_aDados) == 0
	Aadd(_aDados,{0})
	Aadd(_aDados,{0})
	Aadd(_aDados,{0})
	Aadd(_aDados,{0})
Else
	For _nI := 1 to Len(_aDados)
		If 	_aDados[_nI][6] > 0 .And. _aDados[_nI][7] > 0 
			SB1->(DbSeek(xFilial("SB1")+_aDados[_nI][1]))
			DbSelectArea(_cAliasPP)
			DbSetOrder(1)
			DbSeek(xFilial(_cAliasPP)+_aDados[_nI][1])
			RecLock("TCP",.T.)
			TCP->T_OK     := ThisMark()
			TCP->T_CODPRO := _aDados[_nI][1]
			TCP->T_DESCRI := _aDados[_nI][2]			
			TCP->T_REF    := SB1->B1_CODITE
			TCP->T_UM     := _aDados[_nI][3]				
			TCP->T_MARCA  := _aDados[_nI][5]							
			_aPreMin      := T_PerAcrePre(Round(_aDados[_nI][6],4),M->UA_CONDAF,SU0->U0_CALAFIN,SU0->U0_CALAFRE)
			_aPreMax      := T_PerAcrePre(Round(_aDados[_nI][7],4),M->UA_CONDAF,SU0->U0_CALAFIN,SU0->U0_CALAFRE)
			TCP->T_MINIMO := _aPreMin[1]
			TCP->T_MAXIMO := _aPreMax[1]
			TCP->T_EST01  := _aDados[_nI][8]
			If _cLocal <> '01'
				TCP->T_EST02  := _aDados[_nI][8]
			EndIf
			_aPreProm2 := T_BuscaPrePro(_aDados[_nI][1])
			If Len(_aPreProm2) > 0
				TCP->T_PREPRO := _aPreProm2[1]
				TCP->T_PROINI := _aPreProm2[2]
				TCP->T_PROFIM := _aPreProm2[3]
			EndIf
			If (SLK->(DbSeek(xFilial("SLK")+_aDados[_nI][1]+_aDados[_nI][4])))
				TCP->T_SEGUM := _aDados[_nI][4]
				TCP->T_PRESEG:= (_aPreMin[1]*SB1->B1_CONV)*(1-(SLK->LK_DESCTO/100))
			EndIf
			MsUnLock()
		EndIf
	Next _nI

	DbSelectArea("TCP")
	DbGoTop()

EndIf

RestArea(_aAliasLH7)
RestArea(_aAliasSB1)

Return (Nil)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณValidaGetsบ Autor ณ EWERTON CARLOS TOM บ Data ณ  20/10/03   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP5 IDE                                                    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/
    
// Funcao para validacao de todos os Gets da Tela
Static Function ValidaGets(_nOpc,_cCl)
If _nOpc = 1 
	_cCliente  := Posicione('SA1',1,xFilial('SA1')+_cCl,'A1_COD')
	_cLoja     := SA1->A1_LOJA
	_cCondicao := If(!Empty(SA1->A1_COND),SA1->A1_COND,SuperGetMV("MV_CONDPAD"))
	_cEst      := SA1->A1_EST
	_cFrete    := ""
	_cTESCli   := ""
	If !Empty(_cProduto)
		Close(oDlgTelaPreco)
	EndIf
ElseIf _nOpc = 3
	If Empty(_cCondicao)
		MsgStop(STR0028) //'Informe a Condicao de Pagamento!'
		Return(.F.)
	Else
		oSay14:cCaption := SubStr(SE4->E4_DESCRI,1,15)
		oSay14:Refresh(.T.)
	Endif
	If !Empty(_cProduto)
		Close(oDlgTelaPreco)
	Endif	
ElseIf _nOpc = 4  .Or. _nOpc = 5
	If !Empty(_cProduto)
		Close(oDlgTelaPreco)
	EndIf
EndIf
Return(.T.)


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณSTRTOARRAYบ Autor ณ EWERTON CARLOS TOM บ Data ณ  20/10/03   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP5 IDE                                                    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/

Static Function STRTOARRAY(_cTroca,_cCarac,_cTipo)
Local _nXSTA
Local _aRetArray := {}
Local _cRetArray := ''
For _nXSTA := 1 To Len(Alltrim(_cTroca))
	If SubStr(_cTroca,_nXSTA,1) <> _cCarac //.And. !Empty(SubStr(_cTroca,_nXSTA,1))
		_cRetArray += SubStr(_cTroca,_nXSTA,1)
	EndIf
	If SubStr(_cTroca,_nXSTA,1) = _cCarac .Or. _nXSTA = Len(Alltrim(_cTroca))
		AaDd(_aRetArray,If(_cTipo='N',Val(_cRetArray),_cRetArray))
		_cRetArray := ''
	EndIf
Next
Return(_aRetArray)

Static Function QryArr(cQuery,cTipo)

Local aEstou := GetArea()

//ษออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออป
//บ Gravacao do Ambiente Atual e Variaveis para Utilizacao                   บ
//ศออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออSilvio Cazelaอผ
Local aRet    := {}
Local aRet1   := {}
Local nRegAtu := 0
Local x       := 0
cTipo := If(cTipo==Nil,"A","V")

//ษออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออป
//บ Ajustes e Execucao da Query                                              บ
//ศออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออSilvio Cazelaอผ
cQuery := ChangeQuery(cQuery)

TCQUERY cQuery NEW ALIAS "_TCP"

//ษออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออป
//บ Montagem do Array para Retorno                                           บ
//ศออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออSilvio Cazelaอผ
DbSelectArea("_TCP")
aRet1   := Array(fcount())
nRegAtu := 1

While !eof()
	For x:=1 To fCount()
		aRet1[x] := FieldGet(x)
	Next
	AAdd(aRet,aclone(aRet1))
	DbSkip()
	nRegAtu += 1
End  

//ษออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออป
//บ Verifica e Ajusta o Tipo de Retorno                                      บ
//ศออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออSilvio Cazelaอผ
If cTipo=="V" .and. len(aRet)>0
	aRet := aRet[1,1]
ElseIf cTipo=="V"
	aRet := Nil
EndIf

//ษออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออป
//บ Encerra Query e Retorna Ambiente                                         บ
//ศออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออSilvio Cazelaอผ
DbSelectArea("_TCP")
_TCP->(DbCloseArea())

RestArea(aEstou)

Return(aRet)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณMarcar    บ Autor ณ EWERTON CARLOS TOM บ Data ณ  20/10/03   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP5 IDE                                                    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/    

Static Function Marcar()
DbSelectArea('TCP')
RecLock('TCP',.F.)
TCP->T_OK := IIf(Empty(TCP->T_OK),_cMarca,ThisMark())
MsUnlock()
DlgRefresh(oDlgTelaPreco)
SysRefresh()
Return(.T.)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณVerHabTK16บ Autor ณ EWERTON CARLOS TOM บ Data ณ  20/10/03   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP5 IDE                                                    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/ 
   
Function VerHabTK16()
If !Empty(TCP->T_EST01) .Or. !Empty(TCP->T_EST02)
	Return(.F.)
EndIf
Return(.T.)


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณRunProc   บ Autor ณ EWERTON CARLOS TOM บ Data ณ  20/10/03   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP5 IDE                                                    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/  
  
Static Function RunProc()
Processa( { || RunProc2() } )
MsgBox(STR0029,STR0030,"INFO") //"Confirme cada Produto para Escolha de Faixa de Pre็os"###"ATENวรO"
FechaCon()                  
Return
                                               
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณRunProc2  บ Autor ณ EWERTON CARLOS TOM บ Data ณ  20/10/03   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP5 IDE                                                    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/  

Static Function RunProc2()
Local _nConta   := 0
Local _aAreaRun := GetArea()
Local _nProcesso:= 0
                         
DbSelectArea('SB1')
DbSetOrder(1)
            
DbSelectArea('TCP')
DbGoTop()

While !Eof()
	If TCP->T_OK == _cMarca
		++_nConta
	EndIf
	DbSkip()
End  
DbGoTop()

_nPosIte  := aScan(aHeader,{|e|Trim(e[2])=='UB_ITEM'   })
_nPosCod  := aScan(aHeader,{|e|Trim(e[2])=='UB_PRODUTO'})
_nPosDesc := aScan(aHeader,{|e|Trim(e[2])=='UB_DESCRI' })
_nPosUm   := aScan(aHeader,{|e|Trim(e[2])=='UB_UM'     })

If Len(aCols)>=1 .And. !Empty(aCols[n,_nPosCod])
	_nProcesso:= Len(aCols)    
	n := Len(aCols)
EndIf

ProcRegua(_nConta)

While !Eof()

	IncProc(TCP->T_CODPRO)
	
	If TCP->T_OK == _cMarca .And. Ascan(aCols,{|x|Alltrim(x[_nPosCod])==Alltrim(TCP->T_CODPRO)}) = 0
	
		SB1->(DbSeek(xFilial('SB1')+TCP->T_CODPRO))
	
		If _nProcesso > 0 .And. !Empty(aCols[n,_nPosCod])
			AADD(aCols,Array(Len(aHeader)+1))
			++n
			PreparaAcols(n)
		EndIf
		_nProcesso++
		
		aCols[n,_nPosIte]  := StrZero(n,2)
		aCols[n,_nPosCod]  := TCP->T_CODPRO
		aCols[n,_nPosDesc] := TCP->T_DESCRI
		aCols[n,_nPosUm]   := SB1->B1_UM
		
		DbSelectArea('TCP')
	
	EndIf
	
	DbSkip()
End  


RestArea(_aAreaRun)

Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณPreparaAcolsบ Autor ณ EWERTON CARLOS TOM บ Data ณ  20/10/03   บฑฑ
ฑฑฬออออออออออุออออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ                                                              บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP5 IDE                                                      บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/
  
Static Function PreparaAcols(nPos)
Local i2
For i2:=1 to Len(aHeader)
	cCampo:=Alltrim(aHeader[i2,2])
	If aHeader[i2,10] # "V"
		If aHeader[i2,8] == "C"
			If cCampo == "UB_ITEM"
				aCols[nPos][i2] := Repl("0",aHeader[i2,4]-1)+"1"
			Else
				aCols[nPos][i2] := Space(aHeader[i2,4])
			EndIf
		ElseIf aHeader[i2,8] == "N"
			aCOLS[nPos][i2] := 0
		ElseIf aHeader[i2,8] == "D"
			aCOLS[nPos][i2] := dDataBase
		ElseIf aHeader[i2,8] == "M"
			aCOLS[nPos][i2] := ""
		Else
			aCOLS[nPos][i2] := .F.
		EndIf
	Else
		aCols[nPos][i2] := CriaVar(cCampo)
	EndIf
Next i2
aCols[nPos][Len(aHeader)+1] := .F.
Return(Nil)
