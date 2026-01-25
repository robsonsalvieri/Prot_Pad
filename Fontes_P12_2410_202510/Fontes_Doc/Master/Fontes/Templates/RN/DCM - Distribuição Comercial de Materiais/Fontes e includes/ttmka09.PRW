#INCLUDE "ttmka09.ch"
#INCLUDE "rwmake.ch"
#INCLUDE "topconn.ch"
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณTTMKA09a  บAutor  ณMicrosiga           บ Data ณ  10/27/05   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Template DCM                                               บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Template function TTMKA09a()
// Calcula a proxima sequencia para o codigo em SB1, com base no fornecedor

Local _cGrupo:=M->B1_PROC,_cRetorno:=M->B1_COD,_cSequencia:='000001',;
_nRecB1:=sb1->(Recno()),_nOrdB1:=sb1->(indexord()),_cProxGrupo

CHKTEMPLATE("DCM")  

If inclui.and.!Empty(_cGrupo)
	sb1->(DbSetorder(1))
	If sb1->(DbSeek(xfilial("SB1")+_cGrupo,.f.))
		_cProxGrupo:=soma1(_cGrupo)
		sb1->(DbSeek(xfilial("SB1")+_cProxGrupo,.t.))
		while SB1->(!Eof()) .AND. SB1->B1_FILIAL == xfilial("SB1") .AND. left(SB1->B1_COD,6) <> _cGrupo
			SB1->(DbSkip(-1))
		End  
		_cSequencia:=substr(sb1->b1_cod,7,6)
		_cSequencia:=soma1(_cSequencia)
	EndIf
	SB1->(DbSetorder(_nOrdB1))
	SB1->(DbGoto(_nRecB1))
	_cRetorno:=_cGrupo+_cSequencia+'001'
EndIf

Return (_cRetorno)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณTTMKA09b  บAutor  ณMicrosiga           บ Data ณ  10/27/05   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Template DCM                                               บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Template Function TTMKA09b(_cProduto)
// Consulta a UMs adicionais de SB1

Local _nLen:=25
Local _nVez
Local _cCampo
Local _cCampo2
Local _cConteudo

CHKTEMPLATE("DCM")  

Private _vItens,_cReturn

_cCampo2:=(Readvar())
_cReturn:=&_cCampo2

If !Empty(Posicione("SAH",1,xfilial("SAH")+_cReturn,"AH_UMRES"))
	Return(.T.)
EndIf
_vItens:={Space(_nLen)}
If sb1->(DbSeek(xfilial("SB1")+_cProduto,.F.))
	For _nVez:=2 To 4
		If _nVez = 2
			_cCampo:="SB1->B1_SEGUM"
			_cConteudo:=&_cCampo
			_cCapacidade:="'('+alltrim(str(SB1->B1_CONV))+')'"
			_cCapacidade:=&_cCapacidade
		Else
			_cCampo:="SB1->B1_UM"+alltrim(str(_nVez))
			_cConteudo:=&_cCampo
			_cCapacidade:="'('+Alltrim(Str("+_cCampo+"FAT))+')'"
			_cCapacidade:=&_cCapacidade
		EndIf
		If !Empty(_cConteudo)
			AAdd(_vItens,_cConteudo+ Space(2)+posicione("SAH",1,xfilial("SAH")+_cConteudo,"AH_UMRES")+ Space(2)+_cCapacidade)
		EndIf
	Next
EndIf

_nList:=ascan(_vItens,_cReturn)
If _nList==0
	_nList:=1
	@ 000,000 TO 100,240 DIALOG _oDlg1 TITLE STR0001 //"Opcoes de Embalagem"
	@ 005,005 LISTBOX _nList ITEMS _vItens SIZE 80,40
	@ 010,090 BmpButton Type 1 Action close(_oDlg1)
	Activate DIALOG _oDlg1 Centered
EndIf
_cReturn:=left(_vItens[_nList],2)
_cComUM2:=_cCampo2+" := '"+_cReturn+"' "
_cComUM2:=&_cComUM2
Return(.T.)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณTTMKA09c  บAutor  ณMicrosiga           บ Data ณ  10/27/05   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Template DCM                                               บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Template function TTMKA09c(_cProduto,_cCodsu,_nQtdSu)
//Retorna a quantidade ja convertida, com base no fator de conversao da 2a unid medida

Local _nFator:=1
Local _nRecSb1:=sb1->(Recno())
Local _nOrdSb1:=sb1->(indexOrd())
Local _nVez

CHKTEMPLATE("DCM")  

SB1->(DbSetorder(1))
If SB1->(DbSeek(xFilial("SB1")+_cProduto))
	For _nVez := 2 to 4
		If _nVez = 2
			_cEmbalagem:="SB1->B1_SEGUM"
			If _cCodSu==(&(_cEmbalagem))
				_nFator:="SB1->B1_CONV"
				_nFator:= &_nFator
				exit
			EndIf
		Else
			_cEmbalagem:="SB1->B1_UM"+str(_nVez,1)
			If _cCodSu==(&(_cEmbalagem))
				_nFator:="SB1->B1_UM"+str(_nVez,1)+"Fat"
				_nFator:=&_nFator
				Exit
			EndIf
		EndIf
	Next _nVez
EndIf
SB1->(DbGoto(_nRecSb1))
SB1->(DbSetorder(_nOrdSb1))

_nFator := If(_nFator>0,_nFator,1)

Return (_nQtdSu*_nFator)
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณTTMKA09d  บAutor  ณMicrosiga           บ Data ณ  10/27/05   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Template DCM                                               บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Template Function TTMKA09d(cProduto)

CHKTEMPLATE("DCM")  

// Gera a proxima sequencia do codigo do produto para a marca
_aArea := GetArea()
_cCodRet := cProduto
If !Empty(cProduto) .And. Substr(cProduto,7,6) == '??????'
	cQuery := "SELECT ISNULL(MAX(SUBSTRING(B1_COD,7,6)),0)+1 as RESULT "
	cQuery += "FROM "+RetSqlName('SB1')+"  WHERE SUBSTRING(B1_COD,1,6) = '"+Substr(cProduto,1,6)+"'"
	
	cQuery := ChangeQuery(cQuery)
	
	TcQuery cQuery NEW ALIAS 'RES'
	
	DbSelectArea('RES')
	_cCodRet := Substr(cProduto,1,6)+StrZero(RES->RESULT,6)+'001'
	DbCloseArea()
ElseIf !Empty(cProduto) .And. Len(Alltrim(cProduto)) < 12
	MsgBox(STR0002+Chr(13)+; //'Deve ser informado o codigo da seguinte forma para buscar o proximo codigo:'
	       STR0003+Chr(13)+; //'Ex. 999999??????'
	       STR0004+Chr(13)+; //'          +-----|----> Codigo do Fabricante Padrao'
	       STR0005) //'                +----> Interogacoes para buscar proximo Codigo'
EndIf
RestArea(_aArea)
Return(_cCodRet)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณTTMKA09e  บAutor  ณMicrosiga           บ Data ณ  10/27/05   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Template DCM                                               บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Template Function TTMKA09e()

CHKTEMPLATE("DCM")  

// Gera a proxima sequencia do codigo do produto para a marca
_aArea := GetArea()
cQuery := "SELECT ISNULL(MAX(A1_COD),0)+1 as RESULT "
cQuery += "FROM "+RetSqlName('SA1')+"  WHERE D_E_L_E_T_ <> '*' "

cQuery := ChangeQuery(cQuery)

TcQuery cQuery NEW ALIAS 'RES'

DbSelectArea('RES')
_cCodRet := StrZero(RES->RESULT,6)
DbCloseArea()
RestArea(_aArea)
Return(_cCodRet)