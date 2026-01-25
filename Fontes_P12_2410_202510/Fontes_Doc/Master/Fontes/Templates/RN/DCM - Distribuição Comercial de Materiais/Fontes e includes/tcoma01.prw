#INCLUDE "PROTHEUS.CH"
#INCLUDE "TCOMA01.CH"
#INCLUDE "RWMAKE.CH"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณTCOMA01   บAutor  ณVendas Clientes     บ Data ณ  27/08/01   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณManutencao da tabela LH7 - Politica de precos				  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ TPL DCM                                                    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Template Function TCOMA01()
Local _nX

Private cCadastro   := STR0001
Private cDelFunc    := ".T."
Private cPerg       := Padr("COMA01",Len(SX1->X1_GRUPO)) //"Manutencao da Politica de Precos"
Private cString     := "LH7"
Private _cMarca     := "XX"
Private _lFiltra    := .F.
Private _lMarca
Private _cProdIni
Private _cProdFim
Private _lTotForn
Private _cForn
Private _cInclui    := "Inclusao"
Private _cAltera    := "Alteracao"
Private _cExclui    := "Exclusao"
Private _cLote      := "Manutencao em Lote"
Private _cRecDolar  := "recdolar"
Private _vCampos    := {}
Private _vCamposLit := {}
Private _vCamposTip := {}
Private _vCamposBox := {}
Private _nTotSel    := _nTotZero := 0
Private _nTroca     := 1
Private _cValPara   := Space(30)
Private _cValCbox   := Space(1)
Private _nValPara   := 0
Private _dValPara   := CTOD('  /  /  ')
Private _cCampoLit
Private _cPictTroca := "@er 999,999,999.9999"
Private _vTroca     := {}
Private _vTabelas   := {}

CHKTEMPLATE("DCM")

DbSelectArea("SU0")
DbSetOrder(1)
DbGoTop()
While !Eof()
	AaDd(_vTabelas,SU0->U0_CODIGO+' - '+SU0->U0_NOME)
	DbSkip()
End

If Len(_vTabelas) == 0
	MsgBox("A Tabela Grupo de Atendimento (SU0), nao pode estar vazia!")
	Return
Endif

Private _cTabela   := _vTabelas[1]
Private _nTabPrc   := 1
Private _cSitMoeda := "1"
Private _cFiltro   := ""

For _nX := 1 To Len(_vTabelas)
	_cX := 'lCheck'+StrZero(_nX,2)+':=.F.'
	_cX := &_cX
Next _nX 

DbSelectArea("LH7")

//  1 pesquisa, sem alteracoes
//  3 Rotina de inclusao chamada continuamente ao
//  4 alteracao.

Private aRotina := {;
					{STR0002         	,"Axpesqui"			   , 0, 3},; //"Pesquisa"
					{STR0003       		,"T_COM01a(_cInclui)"  , 0, 3},; //"Incluir   "
					{STR0004       		,"T_COM01a(_cAltera)"  , 0, 3},; //"Alterar   "
					{STR0005    		,"T_COM01a(_cLote)"    , 0, 3},; //"Manut em lote"###
					{STR0007    		,'T_COM01i'			   , 0, 3},; //"Atual em Lote"
					{STR0008   			,"T_COM01b"			   , 0, 3},; //"Filtrar/Marcar"
					{STR0009			,'T_COM01c'			   , 0, 3},; //"Atualizar Tabelas"
					{STR0010   			,'T_COM01g'			   , 0, 3},; //"Produtos novos"
					{STR0011  			,'T_COM01a(_cRecDolar)', 0, 3}}	 //"Rec.Valor Dolar"
DbSelectArea("LH7")
If T_COM01b()
	DbSelectArea("LH7")
	MarkBrowse("LH7","LH7_MARC","",,,_cMarca)
	RetIndex("LH7")
Endif
Return
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณCOM01a    บAutor  ณVendas Clientes     บ Data ณ  08/22/05   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณManutencao de registros                                     บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ MP8                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Template Function COM01a( _cOper )
Local _nLin := 0
Local _nVez := 0	// controle de loop

CHKTEMPLATE("DCM")

do case
	case "lote" $lower(_cOper)
		// Ponto de Entrada que adiciona no vetor de Atualizacao em Lote, novos campos a serem atualizados.
		If ExistBlock("TCOMA01CAM")
			_vCampos := ExecBlock("TCOMA01CAM")		
		Else
			_vCampos := Exectemplate("TCOMA01CAM")					
		Endif
		For _nVez := 1 to len(_vCampos)
			_vCampos[_nVez] := Posicione("SX3",2,_vCampos[_nVez],"x3_ordem")+_vCampos[_nVez]
		Next _nVez
		asort(_vCampos)
		For _nVez := 1 to len(_vCampos)
			_vCampos[_nVez] := Substr(_vCampos[_nVez],3)
		Next _nVez
		For _nVez := 1 to len(_vCampos)
			aadd(_vCamposLit,posicione("SX3",2,_vCampos[_nVez],"x3_descric"))
			aadd(_vCamposTip,{Alltrim(SX3->X3_DESCRIC),SX3->X3_TIPO,IIf(Empty(Alltrim(SX3->X3_CBOX)),{""},T_Split(Alltrim(SX3->X3_CBOX),";"))})
			aadd(_vCamposBox,{Alltrim(SX3->X3_DESCRIC),IIf(Empty(Alltrim(SX3->X3_CBOX)),{""},T_Split(Alltrim(SX3->X3_CBOX),";"))})
		Next _nVez
		_cCampoLit := _vCamposLit[1]
		_vTroca := {STR0013,STR0014,STR0015} //"Para o seguinte valor: "###"Para seu proprio valor MAIS o percentual  de: "###"Para seu proprio valor MENOS o percentual de: "
		_vCBOX     := _vCamposBox[AsCan(_vCamposBox,{|x|x[1]==Alltrim(_cCampoLit)}),2]
		_cValCbox  := _vCBOX[1]
		_nTotSel := 0
		msaguarde({|| COM01c1()},STR0016) //'Analisando registros marcados...'
		If _nTotSel==0
			MsgBox(STR0017) //"Nenhum registro esta marcado..."
		else
			@ 000,000 TO 180,515 DIALOG _oDlg2 TITLE _cOper
			@ 005,010 say STR0018+alltrim(str(_nTotSel))+STR0019 //"Alterar, para "###" registro(s) marcado(s), o valor do campo: "
			@ 005,160 MSCOMBOBOX oCombo1 VAR _cCampoLit ITEMS _vCamposLit size 095,012 OF _oDlg2 PIXEL valid validcbox()
			@ 018,160 MSCOMBOBOX oCombo2 VAR _cValCbox  ITEMS _vCBOX      size 095,012 OF _oDlg2 PIXEL  
			@ 022,010 RADIO _vTroca VAR _nTroca
			@ 032,160 get _nValPara picture _cPictTroca size 095,011 when _vCamposTip[AsCan(_vCamposTip,{|x|x[1]==Alltrim(_cCampoLit)}),2] = "N" 
			@ 044,205 get _dValPara                     size 050,011 when _vCamposTip[AsCan(_vCamposTip,{|x|x[1]==Alltrim(_cCampoLit)}),2] = "D" 
			@ 056,160 get _cValPara picture "@S30"      size 095,011 when _vCamposTip[AsCan(_vCamposTip,{|x|x[1]==Alltrim(_cCampoLit)}),2] = "C" .And. Empty(_vCBOX[1])
			@ 075,200 BmpButton Type 1 action COM01a1()
			@ 075,230 BmpButton Type 2 action Close(_oDlg2)
			ACTIVATE DIALOG _oDlg2 CENTER
		Endif
		Return
	case "recdolar" $lower(_cOper)
		_nTotSel := 0
		msaguarde({|| COM01c1()},STR0016) //'Analisando registros marcados...'
		If _nTotSel==0
			MsgBox(STR0017) //"Nenhum registro esta marcado..."
		else
			COM01j()
		Endif
		Return
	case "inclusao" $ lower(_cOper)
		lRefresh := .T.
		altera := .F.
		inclui := .F.
		LH7->(axinclui(alias(),0,2))
	case "exclusao"$lower(_cOper)
		If LH7->(reclock(alias(),.F.)).AND.msgyesno(STR0024) //"Confirma a exclusao do registro ?"
			LH7->(dbdelete())
			LH7->(msunlock())
		Endif
	case "alteracao" $ lower(_cOper)
		lRefresh := .T.
		inclui := .F.
		altera := .T.
		LH7->(axaltera(alias(),recno(),2))
endcase

return

Static Function ValidCBox()
_vCBOX     := _vCamposBox[AsCan(_vCamposBox,{|x|x[1]==Alltrim(_cCampoLit)}),2]
_cValCbox  := _vCBOX[1]          
oCombo2:AItems := _vCBOX
return(.T.)
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณRecMarkup บAutor  ณVendas Clientes     บ Data ณ  08/22/05   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ MP8                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Template Function RecMarkup( _cAliasRM, _nCampo )
Local _nValMkp := 0
Local _cXRM    := ''

CHKTEMPLATE("DCM")

_cXRM := _cAliasRM+"->LH7_TAB"+StrZero(_nCampo,2)+">0
If &_cXRM
	_cXRM := _cAliasRM+"->LH7_MKP"+StrZero(_nCampo,2)+":=(("+_cAliasRM+"->LH7_TAB"+StrZero(_nCampo,2)+"/"+_cAliasRM+"->LH7_PRC)-1)*100"
	_nValMkp := &_cXRM
Endif
_cXRM := _cAliasRM+"->LH7_TAB"+StrZero(_nCampo,2)+"2>0
If &_cXRM
	_cXRM := _cAliasRM+"->LH7_MKP"+StrZero(_nCampo,2)+"2:=(("+_cAliasRM+"->LH7_TAB"+StrZero(_nCampo,2)+"2/"+_cAliasRM+"->LH7_PRC)-1)*100"
	_nValMkp := &_cXRM
Endif
Return(.T.)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณCOM01a1   บAutor  ณVendas Clientes     บ Data ณ  08/22/05   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ MP8                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static function COM01a1()
Local _nRecZZ := LH7->(Recno())
Local _cMens
Local _cCampoTP := _vCamposTip[AsCan(_vCamposTip,{|x|x[1]==Alltrim(_cCampoLit)}),2]
Local _cCampoBox:= _vCamposTip[AsCan(_vCamposTip,{|x|x[1]==Alltrim(_cCampoLit)}),3]

If "dt."$lower(_cCampoLit) .AND. _nTroca <> 1
	_nTroca := 1
Endif

_cMens := If(!("dt."$lower(_cCampoLit)),STR0025 + If(_nTroca==1,STR0026+alltrim(_cCampoLit)+STR0027+;
IIf(_cCampoTP="C".And.Empty(_cCampoBox[1]),alltrim(_cValPara),IIf(_cCampoTP="C".And.!Empty(_cCampoBox[1]),alltrim(_cValCBox),;
alltrim(tran(_nValPara,_cPictTroca))))+;
"] ",If(_nTroca==2,STR0028+alltrim(tran(_nValPara,_cPictTroca))+STR0029+alltrim(_cCampoLit)+"] ",If(_nTroca==3,STR0030+alltrim(tran(_nValPara,_cPictTroca))+STR0029+alltrim(_cCampoLit)+"] ",STR0031))),; //"Confirma "###"a alteracao do campo ["###"] para o valor ["###" o acrescimo de ["###" %] no valor do campo ["###" a reducao de ["###" %] no valor do campo ["###"Erro na selecao"
STR0032+alltrim(_cCampoLit)+STR0027+DTOC(_dValPara)+"] ") //"Confirma a alteracao do campo ["###"] para o valor ["

_cMens+=STR0036+alltrim(str(_nTotSel))+STR0037 //"em "###" registro(s) marcado(s) ?"

If !MsgYesNo(_cMens)
	Return
EndIf
MsAguarde({|| COM01a2()},STR0038) //'Atualizando registros marcados...'
LH7->(DbGoto(_nRecZZ))
Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณCOM01a2   บAutor  ณVendas Clientes     บ Data ณ  08/22/05   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ MP8                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/ 

Static Function  COM01a2()
Local _nAlt   := 0
Local _nJafoi := _nAlt 
Local _cCampo := _vCampos[ascan(_vCamposLit,_cCampoLit)]
Local _cCampoTP := _vCamposTip[AsCan(_vCamposTip,{|x|x[1]==Alltrim(_cCampoLit)}),2]
Local _cCampoBox:= _vCamposTip[AsCan(_vCamposTip,{|x|x[1]==Alltrim(_cCampoLit)}),3]
Local _cMen1
Local _lAltera := .F.

LH7->(dbgotop())
While LH7->(!Eof())
	If LH7->(LH7_MARC ==_cMarca .AND. Reclock(Alias(),.F.))
		_cComando := "LH7->"+_cCampo+":="

		_lAltera := .F.
		If _cCampoTP = "N"
			if _nTroca==1     // alterar
				_cComando+="_nValPara"
				_lAltera := .T.
			elseif _nTroca==2 // acrescentar %
				_cComando+="LH7->"+_cCampo+"+(LH7->"+_cCampo+"*_nValPara/100)"
				_lAltera := .T.
			elseif _nTroca==3 // reducao %
				_cComando+="LH7->"+_cCampo+"-(LH7->"+_cCampo+"*_nValPara/100)"
				_lAltera := .T.
			Endif
		ElseIf _cCampoTP = "D"
			if _nTroca==1     // alterar
				_cComando+="_dValPara"
				_lAltera := .T.
			Endif
		ElseIf _cCampoTP = "C" .And. Empty(_cCampoBox[1])
			if _nTroca==1     // alterar
				_cComando+="_cValPara"
				_lAltera := .T.
			Else
				_cComando := ""
			Endif
		ElseIf _cCampoTP = "C" .And. !Empty(_cCampoBox[1])
			if _nTroca==1     // alterar
				_cComando+="SubStr(_cValCBox,1,1)"
				_lAltera := .T.
			Endif
		Endif

		If	_lAltera
			_x := &_cComando
			LH7->(msunlock())
			LH7->(reclock(alias(),.F.))
			If ExistBlock("COM01D")
				U_COM01D("LH7")
			Else
				T_COM01d("LH7")	
			Endif
			_nAlt++
		EndIf
		LH7->(msunlock())
	Endif
	_nJafoi++
	_cMen1 := STR0039+alltrim(str(_nJafoi))+STR0040+alltrim(str(_nAlt)) //"Registros percorridos: "###"  alterados: "
	msproctxt(_cMen1)
	LH7->(DbSkip())
end
MsgBox(STR0041+_cMen1,STR0034,"INFO") //"Concluido, "###"Politica de Precos"
return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณCOM01b    บAutor  ณVendas Clientes     บ Data ณ  08/22/05   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ MP8                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Template Function COM01b

CHKTEMPLATE("DCM")

If pergunte(cPerg,.T.)
	//MV_PAR01 = "Quanto a marcacao  :" ("Marcar";"Desmarcar";"Manter")
	//MV_PAR02 = "Filtrar registros  :" ("Sim";"Nao")
	//MV_PAR03 = "Produto de  (Cod)  :"
	//MV_PAR04 = "Produto ate (Cod)  :"
	//MV_PAR05 = "Produto de  (Descr):"
	//MV_PAR06 = "Produto ate (Descr):"
	//MV_PAR07 = "Quanto a moeda     :" ("Real";"Dolar Comercial";"Dolar HP";"Dolar Outros";"Todos")
	//MV_PAR08 = "Filtrar fornecedor :" ("Sim";"Nao")
	//MV_PAR09 = "Apenas o fornecedor:"
	msaguarde({|| COM01b1()},STR0042) //'Aguarde, realizando a consulta'
else
	return(.F.)
Endif
return(.T.)
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณCOM01b1   บAutor  ณVendas Clientes     บ Data ณ  08/22/05   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณFiltragem de registros com base nos parametros (execucao)   บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ MP8                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function  COM01b1
Local _nJafoi := 0
Local cArqInd

msproctxt(STR0043) //"Liberando registros do ultima filtragem"

_nMarca   := MV_PAR01       //1-Marcados 2-Desmarcados 3-Manter
_lFiltra  := MV_PAR02 == 1 // Filtrar registros
_cProdIni := AllTrim(MV_PAR03)     // Produto de  (Cod)
_cProdFim := AllTrim(MV_PAR04)     // Produto ate (Cod)
_cDescIni := AllTrim(MV_PAR05)      // Produto de  (Descr)
_cDescFim := AllTrim(MV_PAR06)      // Produto ate (Descr)
_nMoeda   := MV_PAR07       // 1-Somente em dolares;2-Somente em Reais;3-Todos
_lTotForn := MV_PAR08 == 2  // Filtrar fornecedores
_cSoForn  := AllTrim(MV_PAR09)     // Apenas do fornecedor

LH7->(DbClearfil())
LH7->(RetIndex(Alias()))

_cFiltro  := ''

If _lFiltra
	msproctxt(STR0044) //"Compondo a expressao do filtro"
	_cFiltro := "LH7_FILIAL ='"+xFilial("LH7")+"'.AND."
	_cFiltro+="LH7_COD  >='"+_cProdIni+"'.AND.LH7_COD  <='"+_cProdFim+"'"
 	If !Empty(_cDescFim)
		_cFiltro+=".AND. LH7_DESC>='"+_cDescIni+"'.AND.LH7_DESC<='"+_cDescFim+"'"
	Endif
	If !_lTotForn
		_cFiltro+=".AND.LH7_CODF='"+_cSoForn+"'"
	Endif
	If _nMoeda<>5
		_cExpMoeda := ".AND.LH7_EMDO='"+Str(_nMoeda,1)+"'"
		_cFiltro+=_cExpMoeda
	Endif
	
	cArqInd := criatrab(,.F.)
	IndRegua('LH7',cArqInd,"LH7_FILIAL+LH7_COD",,_cFiltro,STR0045) //'Selecionando registros'
	LH7->(DbSetOrder(1))
	LH7->(DbGoTop())
Endif
If _nMarca<>3
	LH7->(dbgotop())
	While !LH7->(eof())
		If LH7->(Reclock(alias(),.F.))
			REPLACE LH7->LH7_MARC WITH If( _nMarca == 1, _cMarca, '' )
			LH7->(MsUnlock())
		Endif
		LH7->(DbSkip())
		_nJafoi++
		msproctxt(If(_nMarca==1,"M",STR0046)+STR0047+alltrim(str(_nJafoi))) //"Desm"###"arcando registros: "
	End
	MsgBox(STR0048+If(_nMarca==1,"m",STR0046)+STR0049+alltrim(str(_nJafoi)),STR0034,"INFO") //"Registros "###"desm"###"arcados agora: "###"Politica de Precos"
	LH7->(DbGoTop())
Endif
Return


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณCOM01c    บAutor  ณVendas Clientes     บ Data ณ  08/22/05   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณTela principal da atualizacao de precos					  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ MP8                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Template function  COM01c
Local _nX := 0	// controle de loop

CHKTEMPLATE("DCM")
_nTotZero := 0
_nTotSel  := _nTotZero
_nPreco0  :=1
_vPreco0  := {STR0050,STR0051} //"Todos os produtos selecionados                                       "###"Apenas os que estao com valor superior a 0 na tabela correspondente"

msaguarde({|| COM01c1()},STR0016) //'Analisando registros marcados...'
If !msgyesno(STR0052+alltrim(str(_nTotSel))+STR0053+alltrim(str(_nTotZero))+STR0054) //"Ha "###" registros marcados, dos quais "###" estao sem preco, deseja continuar ?"
	Return
Endif

@ 050,091 To 365,627 Dialog _oDlg1 Title STR0055 //"Atualizacao das tabelas de precos"
@ 007,016 Say STR0056 //"Esta  rotina  ira atualizar  as tabelas de  precos  utilizadas nos modulos de"
@ 017,016 Say STR0057 //"automacao  comercial,  com base nos  parametros  informados. De acordo"
@ 027,016 Say STR0058+alltrim(str(_nTotSel))+STR0059 //"com o escopo selecionado, "###" produtos terao seus precos atualizados."
@ 037,016 Say STR0060 //"Para os casos em que o cadastro de produtos informe unidades de medida"
@ 047,016 Say STR0061 //"e fatores  de  conversao  (unidades 2,3 e 4)"
@ 057,016 Say ""
@ 067,016 Say ""

@ 078,016 RADIO _vPreco0 VAR _nPreco0

@ 100,016 say STR0062 //"Atualizar tabela: "
//@ 100,060 COMBOBOX _cTabela ITEMS _vTabelas SIZE 080,50
For _nX := 0 To Len(_vTabelas)-1
	_cX := 'lCheck'+StrZero(_nX+1,2)
	@ If(_nX >= Len(_vTabelas) / 2, 100 + ((_nX - Len(_vTabelas)/2) * 10), 100+(_nX*10)), 060 + If(_nX >= Len(_vTabelas)/2, 095, 0) CHECKBOX RTRIM(_vTabelas[_nX + 1]) VAR &_cX
Next _nX
@ 135,195 BmpButton Type 1 Action  COM01c2()
@ 135,225 BmpButton Type 2 Action close(_oDlg1)
Activate Dialog _oDlg1 centered

Return
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณCOM01c1   บAutor  ณVendas Clientes     บ Data ณ  08/22/05   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณAnalise dos registros que serao submetidos a atualizacao de บฑฑ
ฑฑบ          ณprecos                                                      บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ MP8                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static function  COM01c1
LH7->(dbgotop())
_nTotZero := 0
_nTotSel  := _nTotZero
_nPerc    := _nTotSel

while LH7->(!eof())
	_nPerc++
	_nTotSel +=If(LH7->LH7_MARC==_cMarca,1,0)
	_nTotZero+=If(empty(LH7->LH7_PRC),1,0)
	LH7->(DbSkip())
	msproctxt("("+alltrim(str(_nTotSel))+STR0063+alltrim(str(_nPerc))+STR0064) //") registros marcados, ("###") percorridos"
end

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณCOM01c2   บAutor  ณVendas Clientes     บ Data ณ  08/22/05   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ 															  บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ MP8                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function  COM01c2
Local _nRecZZ := LH7->(recno())

If !MsgYesNo(STR0065) //"Confirma o inicio da atualizacao das tabelas marcadas ?"
	return
Endif
MsAguarde({|| COM01c3()},STR0038) //'Atualizando registros marcados...'
LH7->(dbgoto(_nRecZZ))

Return
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณCOM01c3   บAutor  ณVendas Clientes     บ Data ณ  08/22/05   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ 															  บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ MP8                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function  COM01c3()
Local _nX := 0	// controle de loop

Private _nInc   := 0
Private _nAlt   := _nInc
Private _nJafoi := _nAlt
Private _cMen1  := ""
Private _cComando
Private _cCampoDU2
Private _cCampoDU3

_nTabprc := 1
For _nX := 1 To Len(_vTabelas)
	_cX := 'lCheck'+StrZero(_nX,2)
	If &_cX
		_nJafoi := _nAlt := _nInc:=0
		_cMen1 := ""
		_nTabprc2 := _nTabprc+1
		
		_cCampo := "B0_PRV"+AllTrim(Str(_nTabprc))
		_cComando := "SB0->"+_cCampo+":=LH7->LH7_TAB"+StrZero(_nX,2)
		
		_cCampo2 := "B0_PRV"+AllTrim(Str(_nTabprc2))
		_cComando2 := "SB0->"+_cCampo2+":=LH7->LH7_TAB"+StrZero(_nX,2)+"2"
		
		LH7->(dbgotop())
		SB0->(DbSetOrder(1))
		SLK->(dBOrderNickName("SLKDCM01"))
		SB1->(DbSetOrder(1))
		
		_cCondPreco0 := "LH7->LH7_TAB"+StrZero(_nX,2)+">0 .OR. LH7->LH7_TAB"+StrZero(_nX,2)+"2>0"
		
		While LH7->(!eof())
			_nJafoi++
			If LH7->LH7_MARC==_cMarca.AND.&(_cCondPreco0)
				If SB0->(DbSeek(xfilial("SB0")+LH7->LH7_COD,.F.))
					If SB0->(reclock(alias(),.F.))
						If (round(SB0->B0_PRV1,2)<>round(LH7->LH7_TAB01,2)) .OR. (round(SB0->B0_PRV3,2)<>round(LH7->LH7_TAB02,2))
							SB0->B0_ULTREVI := dDatabase
						Endif
						_x := &_cComando
						_x := &_cComando2
						cString := cUserName + Save4in2(MsDate() - Ctod("01/01/96"))
						cString := Embaralha(cString,0)
						SB0->(msunlock())
						_nAlt++
					Endif
				ElseIf SB0->(reclock(alias(),.T.))
					SB0->B0_filial := xfilial("SB0")
					SB0->B0_cod    := LH7->LH7_COD
					If (round(SB0->B0_PRV1,2)<>round(LH7->LH7_TAB01,2)) .OR. (round(SB0->B0_PRV3,2)<>round(LH7->LH7_TAB02,2))
						SB0->B0_ULTREVI := dDatabase
					Endif
					_x := &_cComando
					_x := &_cComando2
					cString := cUserName + Save4in2(MsDate()-Ctod("01/01/96"))
					cString := Embaralha(cString,0)
					SB0->(msunlock())
					_nInc++
				Endif
				If _nX = 1
					// Somente Loja utiliza a tabela de Codigo de Barras para
					// comparacao de descontos por unidade
					_cCampoDU2 := "LH7->LH7_DU2"+strzero(_nX,2)
					_cCampoDU3 := "LH7->LH7_DU3"+strzero(_nX,2)
					If SB1->(DbSeek(xFilial("SB1")+LH7->LH7_COD))
						If !Empty(SB1->B1_SEGUM) .AND. SB1->B1_UM <> SB1->B1_SEGUM
							If SLK->(DbSeek(xFilial("SLK")+LH7->LH7_COD+SB1->B1_SEGUM))
								RecLock("SLK",.F.)
								REPLACE SLK->LK_DESCTO WITH &_cCampoDU2
								MsUnLock()
							Endif
						Endif
						If !Empty(SB1->B1_UM3) .AND. SB1->B1_UM <> SB1->B1_UM3
							If SLK->(DbSeek(xFilial("SLK")+LH7->LH7_COD+SB1->B1_UM3))
								RecLock("SLK",.F.)
								REPLACE SLK->LK_DESCTO WITH &_cCampoDU3
								MsUnLock()
							Endif
						Endif
					Endif
				Endif
			Endif
			_cMen1 := STR0066+AllTrim(Str(_nJafoi))+STR0040+AllTrim(Str(_nAlt))+STR0067+AllTrim(Str(_nInc))+STR0068+StrZero(_nX,2) //"Percorridos: "###"  alterados: "###" Incluidos: "###" Tabela: "
			msproctxt(_cMen1)
			LH7->(DbSkip())
		End
	Endif
	_nTabprc +=2
Next _nX
_cMen1 := STR0066+AllTrim(Str(_nJafoi))+STR0040+AllTrim(Str(_nAlt))+STR0067+AllTrim(Str(_nInc)) //"Percorridos: "###"  alterados: "###" Incluidos: "
MsgInfo(STR0041+_cMen1) //"Concluido, "

Return
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณCOM01D    บ Autor ณ Vendas Clientes    บ Data ณ  28/06/05   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ Ponto de Entrada disparado na rotina de Politica de Precos บฑฑ
ฑฑบ          ณ para definicao das regras dos clientes p/calculo de preco. บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Template DCM - Distribuicao Comercial de Materiais         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/
Template Function COM01D( _cAlias )//Criado em Campo
Local _nX        := 0	// controle de loop
Local _nX2		 := 0	// controle de loop
Local _cAliasPE 

If _cAlias == NIL
	_cAliasPE := "M"
Else
	_cAliasPE := _cAlias
Endif
If Type('M->LH7_COD') = 'U' .AND. Type('aHeader') <> 'U'
	RegToMemory('LH7',.T.)
	For _nX := 1 To Len(aHeader)
		_cCon := 'aCols[n,ascan(aHeader,{|x|Alltrim(UPPER(x[2]))==Alltrim(UPPER(aHeader[_nx,2]))})]'
		_cVar := 'M->'+aHeader[_nx,2]+':='+_cCon
		_cVar := &_cVar
	Next _nX
Endif

_cX := _cAliasPE + "->LH7_CUSTM2 > 0 .AND. " + _cAliasPE + "->LH7_UM2 <> ''"

If (&_cX)
	_cX := _cAliasPE+"->LH7_CUSTMO := "+_cAliasPE+"->LH7_CUSTM2/"+;
	"If("+_cAliasPE+"->LH7_UM2 = posicione('SB1',1,xfilial('SB1')+"+_cAliasPE+"->LH7_COD,'B1_SEGUM'),SB1->B1_CONV,"+;
	"If("+_cAliasPE+"->LH7_UM2 = posicione('SB1',1,xfilial('SB1')+"+_cAliasPE+"->LH7_COD,'B1_UM3'),SB1->B1_UM3FAT,"+;
	"If("+_cAliasPE+"->LH7_UM2 = posicione('SB1',1,xfilial('SB1')+"+_cAliasPE+"->LH7_COD,'B1_UM4'),SB1->B1_UM4FAT,0)))"
	_cX := &_cX
Endif

// Atualizacao do custo em R$
_cX := _cAliasPE+"->LH7_CUSTMO:="+_cAliasPE+"->LH7_CUSTMO"
_cCondDol := _cAliasPE+"->LH7_EMDO<>'1'"
if (&_cCondDol)
	_cX := _cAliasPE+"->LH7_EMDO"
	_nTaxa := RecMoeda(dDatabase,&_cX)
	_nTaxa := If(empty(_nTaxa),1,_nTaxa)
	_cX+="*_nTaxa"
Endif

_cX := _cAliasPE+"->LH7_icmsai:=If("+_cAliasPE+"->LH7_icmsai=0,sb1->b1_picm,"+_cAliasPE+"->LH7_icmsai)"
_cX := &_cX
_cX := _cAliasPE+"->LH7_ipisai:=If("+_cAliasPE+"->LH7_ipisai=0,sb1->b1_ipi,"+_cAliasPE+"->LH7_ipisai)"
_cX := &_cX
_cX := _cAliasPE+"->LH7_cofins:=If(GetMv('MV_TXCOFIN')>0,GetMv('MV_TXCOFIN'),"+_cAliasPE+"->LH7_cofins)"
_cX := &_cX
_cX := _cAliasPE+"->LH7_pis:=If(GetMv('MV_TXPIS')>0,GetMv('MV_TXPIS'),"+_cAliasPE+"->LH7_pis)"
_cX := &_cX
_cX := _cAliasPE+"->LH7_COFENT := If(GetMv('MV_TXCOFIN')>0,GetMv('MV_TXCOFIN'),"+_cAliasPE+"->LH7_COFENT)"
_cX := &_cX
_cX := _cAliasPE+"->LH7_PISENT := If(GetMv('MV_TXPIS')>0,GetMv('MV_TXPIS'),"+_cAliasPE+"->LH7_PISENT)"
_cX := &_cX
_cX := _cAliasPE+"->LH7_OUTIM1 := If(GetMv('MV_POLIMP1')>0,GetMv('MV_POLIMP1'),"+_cAliasPE+"->LH7_OUTIM1)"
_cX := &_cX
_cX := _cAliasPE+"->LH7_OUTIM2 := If(GetMv('MV_POLIMP2')>0,GetMv('MV_POLIMP2'),"+_cAliasPE+"->LH7_OUTIM2)"
_cX := &_cX
_cX := _cAliasPE+"->LH7_OUTADC := If(GetMv('MV_POLADIC')>0,GetMv('MV_POLADIC'),"+_cAliasPE+"->LH7_OUTADC)"
_cX := &_cX

_cX := _cAliasPE+"->LH7_CUSTM2 > 0 .AND. "+_cAliasPE+"->LH7_UM2 <> ''"
If (&_cX)
	_cX := _cAliasPE+"->LH7_PRC := "+_cAliasPE+"->LH7_CUSTM2/"+"If("+_cAliasPE+"->LH7_UM2 = SB1->B1_SEGUM,SB1->B1_CONV,"+;
	"If("+_cAliasPE+"->LH7_UM2 = SB1->B1_UM3,SB1->B1_UM3FAT,"+;
	"If("+_cAliasPE+"->LH7_UM2 = SB1->B1_UM4,SB1->B1_UM4FAT,0)))"
	_cX := &_cX
Endif

_cCondDol := _cAliasPE+"->LH7_EMDO <>'1'.AND."+_cAliasPE+"->LH7_CUSTMO > 0"
If (&_cCondDol)
	_cX := _cAliasPE+"->LH7_PRC:="+_cAliasPE+"->LH7_CUSTMO"
	_cX := _cAliasPE+"->LH7_EMDO"
	_nTaxa := RecMoeda(dDatabase,&_cX)
	_nTaxa := If(empty(_nTaxa),1,_nTaxa)
	_cX+="*_nTaxa"
	_cX := &_cX
Endif
_cX := _cAliasPE+"->LH7_DESEMB:="+_cAliasPE+"->LH7_PRC"
_cX := &_cX

_cCondIcmEmb := _cAliasPE+"->LH7_icmemb='2'.AND."+_cAliasPE+"->LH7_icment>0"
If (&_cCondIcmEmb)
	_cX := _cAliasPE+"->LH7_DESEMB:="+_cAliasPE+"->LH7_DESEMB/(1-("+_cAliasPE+"->LH7_icment/100))"
	_cX := &_cX
Endif
_cCondIpiEmb := _cAliasPE+"->LH7_ipiemb='2'.AND."+_cAliasPE+"->LH7_ipient>0"
If (&_cCondIpiEmb)
	_cX := _cAliasPE+"->LH7_DESEMB:="+_cAliasPE+"->LH7_DESEMB*(1+("+_cAliasPE+"->LH7_ipient/100))"
	_cX := &_cX
Endif
_cCondFinEmb := _cAliasPE+"->LH7_finemb='2'.AND."+_cAliasPE+"->LH7_cusfen>0"
If (&_cCondFinEmb)
	_cX := _cAliasPE+"->LH7_DESEMB:="+_cAliasPE+"->LH7_DESEMB*(1+("+_cAliasPE+"->LH7_cusfen/100))"
	_cX := &_cX
Endif

_cX := _cAliasPE+"->LH7_PF1:="+_cAliasPE+"->LH7_DESEMB"
_cX := &_cX

_cX := _cAliasPE+"->LH7_DESEMB:="+_cAliasPE+"->LH7_DESEMB*(1-("+_cAliasPE+"->LH7_desc1e/100))"
_cX := &_cX
_cX := _cAliasPE+"->LH7_DESEMB:="+_cAliasPE+"->LH7_DESEMB+"+_cAliasPE+"->LH7_fretee"
_cX := &_cX

_cX := _cAliasPE+"->LH7_PF2:="+_cAliasPE+"->LH7_PF1*(1-("+_cAliasPE+"->LH7_desc1e/100))"
_cX := &_cX
_cX := _cAliasPE+"->LH7_PF3:="+_cAliasPE+"->LH7_PF2/(1+("+_cAliasPE+"->LH7_ipient/100))"
_cX := &_cX
_cX := _cAliasPE+"->LH7_PF4:="+_cAliasPE+"->LH7_PF3*(1-("+_cAliasPE+"->LH7_icment/100))"
_cX := &_cX
_cX := _cAliasPE+"->LH7_PF5:="+_cAliasPE+"->LH7_PF4*(1-("+_cAliasPE+"->LH7_cusfen/100))"
_cX := &_cX
_cX := _cAliasPE+"->LH7_PF6:="+_cAliasPE+"->LH7_PF5*(1-("+_cAliasPE+"->LH7_pisent/100))"
_cX := &_cX
_cX := _cAliasPE+"->LH7_PF7:="+_cAliasPE+"->LH7_PF6*(1-("+_cAliasPE+"->LH7_cofent/100))"
_cX := &_cX
_cX := _cAliasPE+"->LH7_VALREF:="+_cAliasPE+"->LH7_PF7"
_cX := &_cX

_cX := _cAliasPE+"->LH7_RESU01:="+_cAliasPE+"->LH7_VALREF/(1-("+_cAliasPE+"->LH7_icmsai/100))"
_cX := &_cX
_cX := _cAliasPE+"->LH7_RESU02:="+_cAliasPE+"->LH7_RESU01*(1+("+_cAliasPE+"->LH7_ipisai/100))"
_cX := &_cX

_cCondIcmEmb := _cAliasPE+"->LH7_ipiemb='2'.AND."+_cAliasPE+"->LH7_ipient>0"
If (&_cCondIcmEmb)
	_cCondIcmEmb := _cAliasPE+"->LH7_icmemb='2'.AND."+_cAliasPE+"->LH7_icment>0"
	If (&_cCondIcmEmb)
		_cX := "_nCustoCICM := "+_cAliasPE+"->LH7_PRC/(1-("+_cAliasPE+"->LH7_icment/100))"
		_cX := &_cX
		_cX := "_LH7_dicmip:="+;
		"((((_nCustoCICM*(1-("+_cAliasPE+"->LH7_icment/100)))+("+;
		"_nCustoCICM*(1+("+_cAliasPE+"->LH7_ipient/100)))-_nCustoCICM)/(1-("+;
		_cAliasPE+"->LH7_icment/100))/((_nCustoCICM*(1+("+_cAliasPE+"->LH7_ipient/100)))))-1)*100"
		_cX := &_cX
		_cX := _cAliasPE+"->LH7_dicmip:=If(_LH7_dicmip>0.AND._LH7_dicmip<100,_LH7_dicmip,0)"
		_cX :=&_cX
	Else
		_cX := "_LH7_dicmip:="+;
		"(((("+_cAliasPE+"->LH7_PRC*(1-("+_cAliasPE+"->LH7_icment/100)))+("+;
		_cAliasPE+"->LH7_PRC*(1+("+_cAliasPE+"->LH7_ipient/100)))-"+_cAliasPE+"->LH7_PRC)/(1-("+;
		_cAliasPE+"->LH7_icment/100))/(("+_cAliasPE+"->LH7_PRC*(1+("+_cAliasPE+"->LH7_ipient/100)))))-1)*100"
		_cX := &_cX
		_cX := _cAliasPE+"->LH7_dicmip:=If(_LH7_dicmip>0.AND._LH7_dicmip<100,_LH7_dicmip,0)"
		_cX := &_cX
	Endif
Else
	_cX := _cAliasPE+"->LH7_dicmip:=0"
	_cX := &_cX
Endif
_cX := _cAliasPE+"->LH7_RESU03:="+_cAliasPE+"->LH7_RESU02*(1+("+_cAliasPE+"->LH7_DICMIP/100))"
_cX := &_cX
_cX := _cAliasPE+"->LH7_RESU04:="+_cAliasPE+"->LH7_RESU03/(1-("+_cAliasPE+"->LH7_PIS/100))"
_cX := &_cX
_cX := _cAliasPE+"->LH7_RESU05:="+_cAliasPE+"->LH7_RESU03/(1-(("+_cAliasPE+"->LH7_COFINS+"+_cAliasPE+"->LH7_PIS)/100))"
_cX := &_cX
_cX := _cAliasPE+"->LH7_RESU06:="+_cAliasPE+"->LH7_RESU03/(1-(("+_cAliasPE+"->LH7_OUTIM1+"+_cAliasPE+"->LH7_COFINS+"+_cAliasPE+"->LH7_PIS)/100))"
_cX := &_cX
_cX := _cAliasPE+"->LH7_RESU07:="+_cAliasPE+"->LH7_RESU06/(1-("+_cAliasPE+"->LH7_OUTIM2/100))"
_cX := &_cX
_cX := _cAliasPE+"->LH7_RESU08:="+_cAliasPE+"->LH7_RESU07/(1-("+_cAliasPE+"->LH7_OUTADC/100))"
_cX := &_cX

For _nX := 1 To 15
	For _nX2 := 1 To 2
		_cCampo   := StrZero(_nX,2,0)+If(_nX2=1,"","2")
		_cX := _cAliasPE+"->LH7_TAB"+_cCampo+":="+_cAliasPE+"->LH7_VALREF/((100-"+_cAliasPE+"->LH7_MKP"+_cCampo+")/100)"
		_cX := &_cX
		_cX := _cAliasPE+"->LH7_TAB"+_cCampo+":="+_cAliasPE+"->LH7_TAB"+_cCampo+"/(1-("+_cAliasPE+"->LH7_ICMSAI/100))"
		_cX := &_cX
		_cX := _cAliasPE+"->LH7_TAB"+_cCampo+":="+_cAliasPE+"->LH7_TAB"+_cCampo+"*(1+("+_cAliasPE+"->LH7_IPISAI/100))"
		_cX := &_cX

		If _nX2 = 1
			_cX := _cAliasPE+"->LH7_TABR"+_cCampo+":=("+_cAliasPE+"->LH7_VALRE2/((100-"+_cAliasPE+"->LH7_MKP"+_cCampo+")/100))*"+_cAliasPE+"->LH7_IND"+_cCampo
			_cX := &_cX
		Endif
		
		_cCondIcmEmb := _cAliasPE+"->LH7_ipiemb='2'.AND."+_cAliasPE+"->LH7_ipient>0"
		If (&_cCondIcmEmb)
			_cCondIcmEmb := _cAliasPE+"->LH7_icmemb='2'.AND."+_cAliasPE+"->LH7_icment>0"
			If (&_cCondIcmEmb)
				_cX := "_nCustoCICM := "+_cAliasPE+"->LH7_PRC*(1+("+_cAliasPE+"->LH7_icment/100))"
				_cX := &_cX
				_cX := "_LH7_dicmip:="+;
				"((((_nCustoCICM*(1-("+_cAliasPE+"->LH7_icment/100)))+("+;
				"_nCustoCICM*(1+("+_cAliasPE+"->LH7_ipient/100)))-_nCustoCICM)/(1-("+;
				_cAliasPE+"->LH7_icment/100))/((_nCustoCICM*(1+("+_cAliasPE+"->LH7_ipient/100)))))-1)*100"
				_cX := &_cX
				_cX := _cAliasPE+"->LH7_dicmip:=If(_LH7_dicmip>0.AND._LH7_dicmip<100,_LH7_dicmip,0)"
				_cX := &_cX
			Else
				_cX := "_LH7_dicmip:="+;
				"(((("+_cAliasPE+"->LH7_PRC*(1-("+_cAliasPE+"->LH7_icment/100)))+("+;
				_cAliasPE+"->LH7_PRC*(1+("+_cAliasPE+"->LH7_ipient/100)))-"+_cAliasPE+"->LH7_PRC)/(1-("+;
				_cAliasPE+"->LH7_icment/100))/(("+_cAliasPE+"->LH7_PRC*(1+("+_cAliasPE+"->LH7_ipient/100)))))-1)*100"
				_cX := &_cX
				_cX := _cAliasPE+"->LH7_dicmip:=If(_LH7_dicmip>0.AND._LH7_dicmip<100,_LH7_dicmip,0)"
				_cX := &_cX
			Endif
		Else
			_cX := _cAliasPE+"->LH7_dicmip:=0"
			_cX := &_cX
		Endif
		_cX := _cAliasPE+"->LH7_TAB"+_cCampo+":="+_cAliasPE+"->LH7_TAB"+_cCampo+"*(1+("+_cAliasPE+"->LH7_DICMIP/100))"
		_cX := &_cX
		_cX := _cAliasPE+"->LH7_TAB"+_cCampo+":="+_cAliasPE+"->LH7_TAB"+_cCampo+"/(1-("+_cAliasPE+"->LH7_PIS/100))"
		_cX := &_cX
		_cX := _cAliasPE+"->LH7_TAB"+_cCampo+":="+_cAliasPE+"->LH7_TAB"+_cCampo+"/(1-("+_cAliasPE+"->LH7_COFINS/100))"
		_cX := &_cX
		_cX := _cAliasPE+"->LH7_TAB"+_cCampo+":="+_cAliasPE+"->LH7_TAB"+_cCampo+"/(1-("+_cAliasPE+"->LH7_OUTIM1/100))"
		_cX := &_cX
		_cX := _cAliasPE+"->LH7_TAB"+_cCampo+":="+_cAliasPE+"->LH7_TAB"+_cCampo+"/(1-("+_cAliasPE+"->LH7_OUTIM2/100))"
		_cX := &_cX
		_cX := _cAliasPE+"->LH7_TAB"+_cCampo+":="+_cAliasPE+"->LH7_TAB"+_cCampo+"/(1-("+_cAliasPE+"->LH7_OUTADC/100))"
		_cX := &_cX
	Next _nX2
Next _nX

Return(.T.)
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณCOM01e    บAutor  ณVendas Clientes     บ Data ณ  08/25/05   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณEncerra o MarkBrowse                                        บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ MP8                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Template function COM01e

CHKTEMPLATE("DCM")

ObjectMethod(GetMbrowse(),"END()")

Return
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณCOM01g    บAutor  ณVendas Clientes     บ Data ณ  08/25/05   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณInclusao de produtos que estam em SB1 mas nao em LH7        บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ MP8                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Template Function COM01g
Local _nRecLH7 := LH7->(Recno())
Local _nJafoi  := _nTodos:=0

CHKTEMPLATE("DCM")

MsAguarde({|| COM01g1()},STR0069) //'Aguarde, verificando registros para inclusao...'

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณCOM01g1   บAutor  ณVendas Clientes     บ Data ณ  08/29/05   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณFiltrar e verIficar produtos faltantes em LH7               บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ MP8                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function  COM01g1
Local _nRecLH7 := LH7->(Recno())
Local _nJafoi  := _nTodos:=0

MsProctxt(STR0043) //"Liberando registros do ultima filtragem"

LH7->(dbclearfil())
LH7->(RetIndex(alias()))
SB1->(DbSetOrder(1))
SB1->(DbGoTop())

while SB1->(!eof())
	If SB1->B1_MSBLQL == "2" .OR. SB1->B1_MSBLQL == " " .OR. SB1->B1_SITPROD <> "IN"
		If LH7->(!DbSeek(xfilial('LH7')+SB1->B1_COD,.F.))
			LH7->(Reclock('LH7',.T.))
			REPLACE LH7->LH7_FILIAL WITH xFilial("LH7")
			REPLACE LH7->LH7_COD    WITH SB1->B1_COD
			REPLACE LH7->LH7_DESC   WITH SB1->B1_DESC
			REPLACE LH7->LH7_CODF   WITH SB1->B1_PROC
			REPLACE LH7->LH7_LOJA   WITH SB1->B1_LOJPROC
			REPLACE LH7->LH7_UM     WITH SB1->B1_UM
			REPLACE LH7->LH7_NFORN  WITH Posicione("SA2",1,xFilial("SA2")+SB1->B1_PROC+SB1->B1_LOJPROC,"A2_NREDUZ")
			REPLACE LH7->LH7_EMDO   WITH "1"
			// Ponto de Entrada para preenchimento de campos especificos criados na rotina de Politica de Precos.
			// Utilizado na opcao de "Produtos Novos"
			If ExistBlock("TCOMA01ATU")
				ExecBlock("TCOMA01ATU")
			Endif
			LH7->(MsUnLock())
			_nJafoi++
		Endif
	Endif
	_nTodos++
	SB1->(DbSkip())
	msproctxt(STR0070+alltrim(str(_nTodos))+STR0071+alltrim(str(_nJafoi))) //"Registros..."###" Incluindos: "
end
MsgBox(STR0041+alltrim(str(_nJafoi)),STR0034,"INFO") //"Concluido, "###"Politica de Precos"
MsgBox(STR0072,STR0034,"INFO") //"A filtragem anterior foi desfeita..."###"Politica de Precos"
LH7->(dbgoto(_nRecLH7))

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณCOM01h    บAutor  ณVendas Clientes     บ Data ณ  08/29/05   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณRelatorio das atualizacoes feitas na politica de precos	  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ MP8                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Template Function  COM01h

CHKTEMPLATE("DCM")

Private lEnd         := .F.
Private lAbortPrint  := .F.
Private limite       := 80
Private tamanho      := "P"
Private nomeprog     := "TCOMA01"
Private nTipo        := 15
Private aReturn      := { STR0073, 1, STR0074, 1, 2, 1, "", 1} //"Zebrado"###"Administracao"
Private nLastKey     := 0
Private cbtxt        := Space(10)
Private cbcont       := 00
Private CONTFL       := 01
Private m_pag        := 01
Private cString      := "SB0"
Private wnrel        := "TCOMA01"
aOrd           := {}
cDesc1         := STR0075 //"Este programa tem como objetivo imprimir relatorio "
cDesc2         := STR0076 //"de acordo com os parametros informados pelo usuario."
cDesc3         := ""
cPict          := ""
imprime        := .T.
titulo         := STR0077 //"Precos Atualizados"
nLin           := 80
Cabec1         := STR0078 //"Produto         Descricao                                 UM          Preco Loja"
Cabec2         := ""

//Produto         Descricao                                 UM          Preco Loja
//123456789012345 1234567890123456789012345678901234567890  12          999,999.99
//01234567890123456789012345678901234567890123456789012345678901234567890123456789
//          1         2         3         4         5         6         7

DbSelectArea("SB0")
DbSetOrder(1)

wnrel := SetPrint(cString,NomeProg,' FTR1',@titulo,cDesc1,cDesc2,cDesc3,.F.,,.F.,Tamanho,,.F.)

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

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณRunReport บAutor  ณVendas Clientes     บ Data ณ  08/29/05   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ MP8                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function RunReport(Cabec1,Cabec2,Titulo,nLin)
Local _nX

Pergunte(Padr("COMA01B",Len(SX1->X1_GRUPO)) ,.F.)

//MV_PAR01 = "Tabela Alterada De ?"
//MV_PAR02 = "Tabela Alterada Ate?"
//MV_PAR03 = "Emitir             ?" ("Relatorio";"Etiquetas")
//MV_PAR04 = "Produto            ?"
//MV_PAR05 = "Quantidade Vias    ?"

If MV_PAR03 = 2
	Private cCode
	nHeight   := 15
	lBold     := .F.
	lUnderLine := .F.
	nLin := 0
	
	Private Arial   := TFont():New( "Arial",,nHeight,,lBold,,,,,lUnderLine )
	Private Arial08 := TFont():New( "Arial",,08,,.F.,,,,,.F. )
	Private Arial10 := TFont():New( "Arial",,10,,.F.,,,,,.F. )
	Private Arial12 := TFont():New( "Arial Black Itแlico",,12,,.T.,,,,,.F. )
	Private Arial20 := TFont():New( "Arial",,20,,.T.,,,,,.F. )
	Private Arial28 := TFont():New( "Arial",,28,,.T.,,,,,.F. )
	//   Private Arial36:= TFont():New( "Arial Black Itแlico",,36,,.T.,,,,,.F. )
	Private Arial36 := TFont():New( "Arial Black",,36,,.T.,,,,,.F. )
	Private Arial48 := TFont():New( "Arial",,48,,.T.,,,,,.F. )
	
	Private Times14 := TFont():New( "Times New Roman",,14,,.T.,,,,,.F. )
	Private Times18 := TFont():New( "Times New Roman",,18,,.T.,,,,,.F. )
	Private Times18T:= TFont():New( "Times New Roman",,18,,.T.,,,,,.T. )
	Private Times20 := TFont():New( "Times New Roman",,20,,.T.,,,,,.F. )
	Private Times28 := TFont():New( "Times New Roman",,28,,.T.,,,,,.T. )
	
	Private HAETTEN := TFont():New( "HAETTENSCHWEILLER",,10,,.T.,,,,,.F. )
	
	Private Free44 := TFont():New( "Free 3 of 9",,44,,.T.,,,,,.F. )
	Private Free38 := TFont():New( "Free 3 of 9",,38,,.T.,,,,,.F. )
	
	oPrn := TMSPrinter():New()
	
Endif

Cabec2 := STR0079+DTOC(MV_PAR01)+STR0080+DTOC(MV_PAR02) //'Atualizacao - De:'###' Ate:'

DbSelectArea(cString)
DbSetOrder(1)
_aAtuali := {}
_nCount  := 0
If Empty(MV_PAR04)
	_cFiltroB0 :="DTOS(B0_ULTREVI) >= '"+DTOS(MV_PAR01)+"' .AND. DTOS(B0_ULTREVI) <= '"+DTOS(MV_PAR02)+"' .AND. B0_PRV1 > 0"
	Indregua('SB0',criatrab(,.F.),"B0_FILIAL+B0_COD",,_cFiltroB0,STR0045) //'Selecionando registros'
	dbGoTop()
	While !EOF()
		DbSelectArea('SB1')
		DbSetOrder(1)
		DbSeek(xFilial('SB1')+SB0->B0_COD)
		DbSelectArea('LH7')
		DbSetOrder(1)
		DbSeek(xFilial('LH7')+SB0->B0_COD+SB1->B1_PROC)
		AaDd(_aAtuali,{SB0->B0_COD,SB1->B1_DESC,SB1->B1_UM,SB0->B0_PRV1,LH7->LH7_NFORN})
		++_nCount
		DbSelectArea('SB0')
		DbSkip()
	End
Else
	DbSelectArea('SB0')
	DbSetOrder(1)
	DbSeek(xFilial('SB0')+MV_PAR04)
	DbSelectArea('SB1')
	DbSetOrder(1)
	DbSeek(xFilial('SB1')+MV_PAR04)
	DbSelectArea('LH7')
	DbSetOrder(1)
	DbSeek(xFilial('LH7')+MV_PAR04+SB1->B1_PROC)
	If MV_PAR05 > 0
		For _nX := 1 To MV_PAR05
			AaDd(_aAtuali,{SB0->B0_COD,SB1->B1_DESC,SB1->B1_UM,SB0->B0_PRV1,LH7->LH7_NFORN})
			++_nCount
		Next _nX
	Else
		AaDd(_aAtuali,{SB0->B0_COD,SB1->B1_DESC,SB1->B1_UM,SB0->B0_PRV1,LH7->LH7_NFORN})
		++_nCount
	Endif
Endif

aSort(_aAtuali,,,{|x,y|x[5]+x[1]<y[5]+y[1]})

SetRegua(_nCount)
_cForn := ''
_nCont := 0
_nCont2:= 0
For _nX := 1 To Len(_aAtuali)
	
	IncRegua()
	
	If lAbortPrint .AND. MV_PAR03 = 1
		@nLin,00 PSAY STR0081 //"*** CANCELADO PELO OPERADOR ***"
		Exit
	Endif
	
	If (nLin > 55 .OR. _cForn <> _aAtuali[_nX,5]) .AND. MV_PAR03 = 1
		Cabec(Titulo,Cabec1,Cabec2,NomeProg,Tamanho,nTipo)
		nLin := 9
		@ nLin,000 PSAY STR0082+_aAtuali[_nX,5] //'Fornecedor: '
		nLin += 2
		_cForn := _aAtuali[_nX,5]
	Endif
	
	If MV_PAR03 = 1
		@ nLin,000 PSAY _aAtuali[_nX,1]
		@ nLin,016 PSAY _aAtuali[_nX,2]
		@ nLin,058 PSAY _aAtuali[_nX,3]
		@ nLin,070 PSAY _aAtuali[_nX,4] Picture "@ER 999,999.99"
		++nLin
	Else
		cBitMap := "bmpetiq.bmp"
		
		oPrn:Say( 000,000, " ",Arial,100 )
		//      oPrn:Box(020+(_nCont*470),080+(_nCont2*1600),440+(_nCont*470),1570+(_nCont2*1600) )
		oPrn:SayBitmap( 020+(_nCont*470),100+(_nCont2*1600),cBitMap,1265,380 )
		//      oPrn:Box(020+(_nCont*470),830+(_nCont2*1600),440+(_nCont*470),840+(_nCont2*1600) )
		oPrn:Say( 105+(_nCont*470),435+(_nCont2*1600), STR0083+_aAtuali[_nX,1],Arial12,100  ) //'Cod:'
		oPrn:Say( 040+(_nCont*470),815+(_nCont2*1600), 'R$',Times20,100  )
		oPrn:Say( 135+(_nCont*470),845+(_nCont2*1600), TransForm(_aAtuali[_nX,4],"@E 999.99"),Arial36,100  )
		oPrn:Say( 230+(_nCont*470),120+(_nCont2*1600), SubStr(_aAtuali[_nX,2],1,20),Arial12,100)
		oPrn:Say( 300+(_nCont*470),120+(_nCont2*1600), SubStr(_aAtuali[_nX,2],21,20),Arial12,100)
		If _nCont2 = 1
			_nCont ++
			_nCont2 := 0
		Else
			_nCont2 ++
		Endif
		If _nCont = 5
			oPrn:EndPage()
			oPrn:StartPage()
			_nCont := 0
			_nCont2 := 0
		Endif
	Endif
	
Next _nX

If MV_PAR03 = 1
	SET DEVICE TO SCREEN
	If aReturn[5]==1
		//dbCommitAll()
		SET PRINTER TO
		OurSpool(wnrel)
	Endif
Else
	oPrn:EndPage()
	oPrn:Preview()
	oPrn:End()
Endif

MS_FLUSH()

RetIndex("SB0")

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณCOM01i    บAutor  ณVendas Clientes     บ Data ณ  08/24/05   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ MP8                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Template Function COM01i
Local _nX := 0	// controle de loop

CHKTEMPLATE("DCM")

Private oDlg3
If !MsgYesNo(STR0110) //"Esta rotina atualiza a politica, de acordo com os itens marcados, Confirma ?"
	Return(.T.)
Endif
_cMarca := "XX"                            

// Ponto de Entrada que adiciona no vetor de Atualizacao em Lote, novos campos a serem atualizados.
_aCamposPer := If(ExistBlock("TCOMA01CAM"),ExecBlock("TCOMA01CAM"),ExecTemplate("TCOMA01CAM"))
_cCamposPer := ""
AaDd(_aCamposPer,"LH7_COD")
AaDd(_aCamposPer,"LH7_DESC")
For _nX := 1 To Len(_aCamposPer)
	_cCamposPer += AllTrim(_aCamposPer[_nX])+";"
Next _nX

altera := .T.
@ 100,1 TO 450,640 DIALOG oDlg3 TITLE STR0111 //"Manutencao Politica"
cAlias := "LH7"
DbSelectArea( cAlias )
nOrdem := IndexOrd()
aHeader := {}
DbSelectArea('SX3')
DbSetOrder(1)
DbSeek(cAlias)
nUsado := 0
While !EOF() .AND. X3_ARQUIVO == cAlias
	If x3_usado <> " " .AND. cNivel >= X3_NIVEL .AND.;
		ALLTRIM(X3_CAMPO)+";" $ _cCamposPer
		nUsado := nUsado + 1
		AADD(aHeader,{ TRIM(X3_TITULO), X3_CAMPO, X3_PICTURE,;
		X3_TAMANHO, X3_DECIMAL, X3_VALID,; //+ If(!Empty(X3_VALID),' .AND. ','')+'T_AtuaCol()',;
		X3_USADO, X3_TIPO, X3_ARQUIVO } )
	Endif
	DbSkip()
End
DbSelectArea( cAlias )
DbGoTop()
nCnt := 0
While !EOF()
	If LH7->LH7_MARC == _cMarca
		nCnt ++
	Endif
	DbSkip()
End
aCOLS := Array(nCnt,nUsado+1)
DbSelectArea( cAlias )
DbGoTop()
nCnt := 0
While !EOF()
	If LH7->LH7_MARC <> _cMarca
		DbSkip()
		Loop
	Endif
	nCnt ++
	nUsado := 0
	DbSelectArea('SX3')
	DbSeek(cAlias)
	While !EOF() .AND. X3_ARQUIVO == cAlias
		If x3_usado <> " " .AND. cNivel >= X3_NIVEL .AND.;
			ALLTRIM(X3_CAMPO)+";" $ _cCamposPer
			nUsado++
			aCOLS[nCnt][nUsado] := &(cAlias+"->"+x3_campo)
		Endif
		DbSkip()
	End
	aCOLS[nCnt][nUsado+1] := .F.
	DbSelectArea( cAlias )
	DbSkip()
End
DbSelectArea( cAlias )
DbGoTop()
nRegistro := RecNo()

@ 6,5 TO 155,315 MULTILINE MODIfY DELETE VALID LineOk() FREEZE 1
@ 158,220 BUTTON "_Confirma" SIZE 40,15 ACTION Processa({||T_AtuaLH7()})
@ 158,270 BUTTON "_Sair"     SIZE 40,15 ACTION Close(oDlg3)
ACTIVATE DIALOG oDlg3 CENTERED
DbSelectArea( cAlias )
DbSetOrder(nOrdem)
DbGoTop()    

Return
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณCOM01j    บAutor  ณVendas Clientes     บ Data ณ  08/25/05   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ MP8                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function  COM01j()
Local _nRecLH7 := LH7->(Recno())
Local _cMens   := STR0112 //"Confirma o recalculo do Dolar ? "

_cMens += STR0036 + AllTrim(Str(_nTotSel)) + STR0037 //"em "###" registro(s) marcado(s) ?"

If !MsgYesNo(_cMens)
	Return
Endif
MsAguarde({|| COM01j1()},STR0038) //'Atualizando registros marcados...'
LH7->(dbgoto(_nRecLH7))

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณCOM01j1   บAutor  ณVendas Clientes     บ Data ณ  08/25/05   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ MP8                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static function  COM01j1()
Local _nAlt := 0
Local _nJafoi := _nAlt
Local _cMen1          

LH7->(dbgotop())
While LH7->(!eof())
	If LH7->(LH7_MARC == _cMarca .AND. Reclock(Alias(),.F.))
		If ExistBlock("COM01D")
			U_COM01D("LH7")
		Else
			T_COM01d("LH7")
		Endif
		
		LH7->(msunlock())
		_nAlt++
	Endif
	_nJafoi++
	_cMen1 := STR0039+alltrim(str(_nJafoi))+STR0040+alltrim(str(_nAlt)) //"Registros percorridos: "###"  alterados: "
	msproctxt(_cMen1)
	LH7->(DbSkip())
End
MsgInfo(STR0041+_cMen1,STR0113) //,"INFO") //"Concluido, "###"Atualiza Valores em Dolar"

Return
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณLineOk    บAutor  ณVendas Clientes     บ Data ณ  08/25/05   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ MP8                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function LineOk()

If ExistBlock("COM01D")
	U_COM01D()
Else
	T_COM01d()
Endif

Return .T.
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณAtuaCol   บAutor  ณVendas Clientes     บ Data ณ  08/25/05   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ MP8                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Template Function AtuaCol()

CHKTEMPLATE("DCM")

_cVar := Readvar()
aCols[n,ascan(aHeader,{|x|Alltrim(UPPER(x[2]))==Alltrim(UPPER(SubStr(_cVar,4)))})] := &_cVar

Return .T.
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณAtuaLH7   บAutor  ณVendas Clientes     บ Data ณ  08/25/05   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ MP8                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Template Function AtuaLH7()
Local nLinha := 0	// controle de loop
Local nColun := 0 	// controle de loop 
Local nPosProd := Ascan(aHeader,{|x| Alltrim(x[1]) == "Cod Prod"})

CHKTEMPLATE("DCM")

DbSelectArea('LH7')
DbSetOrder(1)
ProcRegua(Len(aCols))
For nLinha := 1 To Len(aCols)
	IncProc(STR0114+Str(nLinha,5)+' '+Alltrim(aCols[nLinha,nPosProd])+'...') //'Atualizando produto: '
	If !Empty(aCols[nLinha,nPosProd])
		If DbSeek(xFilial('LH7')+aCols[nLinha,nPosProd])
			RecLock('LH7',.F.)
			For nColun := 1 To Len(aHeader)
				REPLACE &("LH7->"+Alltrim(aHeader[nColun,2])) WITH aCols[nLinha,nColun]
			Next nColun
			If ExistBlock("COM01D")
				U_COM01D("LH7")
			Else
				T_COM01d('LH7')
			Endif
			
			DbSelectArea('LH7')
			MsUnLock()
			SysRefresh()
		Endif
	Endif
Next nLinha
MsgBox(STR0115,STR0116,'INFO') //'Concluido com Sucesso !'###'Politica de Precos'
DbSelectArea('LH7')
DbSetOrder(nOrdem)
DbGoTop()         

Return .T.
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณTCOMA01CAMบAutor  ณVendas Clientes     บ Data ณ  08/29/05   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณColocar os campos de manutencao em lote da politica         บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ MP8                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Template Function TCOMA01CAM()
Local  _aAreaSX3 := SX3->(GetArea())   
Local _aCampManu := {}

SX3->(DbSeek("LH7"))
While SX3->(!Eof()) .AND. SX3->X3_CAMPO = "LH7"
	If SX3->X3_TIPO $ "C/N/D/L" .AND. SX3->X3_VISUAL <> "V" .AND. SX3->X3_CONTEXT <> "V" .AND. Alltrim(SX3->X3_CAMPO)+"/" <> "LH7_COD/"
		AaDd(_aCampManu,SX3->X3_CAMPO)
	Endif
   SX3->(DbSkip())
End
RestArea(_aAreaSX3)

Return(_aCampManu)
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณTCOMA01PC บAutor  ณVendas Clientes     บ Data ณ  08/25/05   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Template Function TCOMA01PC
Local _nValCus := 0
Local _aArea   := GetArea()

DbSelectArea("LH7")
DbSetOrder(1)
If DbSeek(xfilial("LH7")+SB1->B1_COD)
	_nValCus := LH7->LH7_PRC
Endif
RestArea(_aArea)
Return(_nValCus)
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณTCONFPRE  บAutor  ณVendas Clientes     บ Data ณ  08/25/05   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ MP8                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Template Function TCONFPRE(_nValor)
Local _nRet := .T.

CHKTEMPLATE("DCM")

If ExistBlock("TCOMA01PC")
	_nValCusto := ExecBlock("TCOMA01PC")
	If ValType('_nValCusto') <> 'N'
		MsgAlert(STR0117) //"Aten็ใo. O retorno do Ponto de Entrada TCOMA01PC ้ invแlido!"
		_nValCusto := 0
	Endif
Else
	_nValCusto := T_TCOMA01PC()
Endif


If !((_nValor<>_nValCusto) .AND. MsgBox(STR0118,STR0119,"YESNO")) //"Preco de Compra Diferente da Politica, Confirma?"###"Pedido de Compra"
	_nRet := .F.
Endif

Return(_nRet)
