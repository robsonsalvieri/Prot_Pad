#INCLUDE "ttmka14.ch"
#INCLUDE "rwmake.ch"
#INCLUDE "TOPCONN.ch"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³TTMKA14   ºAutor  ³Ewerton C Tomaz     º Data ³  ??/??/??   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Tela de Liberacao de Credito                               º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP5                                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Template Function TTMKA14()

Local _OldAcols		:= aClone(Acols)
Local _OldAheader	:= aClone(aHeader)
Local _aArea, _cFiltro, cTrabSUA, dIndexSUA
Local _nAnt			:= n
Local _nX

CHKTEMPLATE("DCM")  

Private aCampos   	:= {}     
Private aCampos2  	:= {}     
Private aFields, aTitPict,aFields2, aTitPict2
Private cArq := ''
Private _cIndex := ''
Private cArq2 := ''
Private _cIndex2 := ''
Private _cCampos   := 'UA_NUM, UA_NUMSC5, UA_CLIENTE, UA_DESCCLI, UA_EMISSAO, UA_VALMERC, UA_CONDPG, UA_OBSDCM, UA_ENDENT, UA_ENDCOB, UA_OPER'
Private _cCampos2  := 'UB_NUM, UB_ITEM, UB_PRODUTO, UB_DESCRI, UB_QUANT, UB_VRUNIT, UB_VLRITEM'

_aArea := T_SRArea('S',nil)

If Select('TUA') > 0
   DbSelectArea('TUA')
   DbCloseArea()
EndIf

Cria_TUA()

Processa({||Monta_TUA()})

DbSelectArea("TUA")
DbGoTop()

For _nX := 1 To Len(aTitPict)
   AADD(aCampos,{StrZero(AT(ALLTRIM(aTitPict[_nX,1]),_cCampos),3,0),aTitPict[_nX,1],aTitPict[_nX,2],aTitPict[_nX,3]})
Next
ASort(aCampos,,,{|x,y|x[1]<y[1]})

aCamposSort := {}
For _nX := 1 To Len(aCampos)
	AADD(aCamposSort,{aCampos[_nX,2],aCampos[_nX,3],aCampos[_nX,4]})
Next
aCampos := {}
aCampos := aCamposSort

If !Eof()
	@ 000,000 TO 225,797 DIALOG oDlgPeds TITLE STR0001 //"Ultimos Pedidos e Orcamentos do Cliente"
	@ 005,005 TO 100,355 BROWSE "TUA" FIELDS aCampos ENABLE "UA_OPER=='1'"
	@ 010,360	BUTTON STR0002 SIZE 30,15 ACTION Prod_Custo() //"Detalhes"
	@ 070,360	BmpButton Type 2 Action Close(oDlgPeds)
	ACTIVATE DIALOG oDlgPeds CENTERED
EndIf

DbSelectArea("TUA")
DbCloseArea()
If Select('TUB') > 0
   DbSelectArea("TUB")
   DbCloseArea()
EndIf   

If File(cArq)
   Ferase(cArq) 
EndIf
If File(_cIndex+OrdBagExt())   
   Ferase(_cIndex+OrdBagExt()) 
EndIf                 

If cArq2 <> ''
   If File(cArq2+OrdBagExt())
      Ferase(cArq2+OrdBagExt()) 
   EndIf
   If File(_cIndex2+OrdBagExt())   
      Ferase(_cIndex2+OrdBagExt()) 
   EndIf                 
EndIf   

T_SRArea('R',_aArea)

n		:= _nAnt
aCols	:= _OldAcols
aHeader	:= _OldaHeader
Return (Nil)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ DETALHE  ³ Autor ³ CLEBER L. SOUZA       ³ Data ³ 06/05/00 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ CRIA TELA COM DETALHES DO ORCAMENTO                        ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ---ÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

Static Function Prod_Custo()
Local _cAlias2    	:= Alias()
Local _nOrder2    	:= Indexord()
Local _nRecno2    	:= Recno()
Local aCampos2   	:= {}
Local cSit			:= ""
Local cOK 			:= ""
Local aStru		   	:= {}
Local _cFiltro   	:= ""
Local _nValTot      := _nCustoGer :=0
Local _nX

Private _cNumOrc	    := ""

If !Empty(TUA->UA_NUM)
	_cNumOrc := TUA->UA_NUM
EndIf

If Empty(_cNumOrc)
Return
EndIf

If Select('TUB') > 0
	DbSelectArea('TUB')
	DbCloseArea()
	If File(cArq2+OrdBagExt())
		Ferase(cArq2+OrdBagExt())
	EndIf
	If File(_cIndex2+OrdBagExt())
		Ferase(_cIndex2+OrdBagExt())
	EndIf
EndIf

Cria_TUB()

Processa({||Monta_TUB()})

DbSelectArea("TUB")
DbGoTop()
_nValTot := 0
While !Eof()
	_nValTot += TUB->UB_VLRITEM
	DbSkip()
End
DbGoTop()

For _nX := 1 To Len(aTitPict2)
	AADD(aCampos2,{StrZero(AT(ALLTRIM(aTitPict2[_nX,1]),_cCampos2),3,0),aTitPict2[_nX,1],aTitPict2[_nX,2],aTitPict2[_nX,3]})
Next
ASort(aCampos2,,,{|x,y|x[1]<y[1]})

aCamposSort := {}
For _nX := 1 To Len(aCampos2)
	AADD(aCamposSort,{aCampos2[_nX,2],aCampos2[_nX,3],aCampos2[_nX,4]})
Next
aCampos2 := {}
aCampos2 := aCamposSort

@ 230,000 TO 545,797  DIALOG oDlg2 TITLE STR0003+If(TUA->UA_OPER='2','Orcamento:'+TUA->UA_NUM,'Pedido:'+TUA->UA_NUMSC5) //"Detalhes do "
@ 005,005 TO 143,390  BROWSE "TUB" FIELDS aCampos2
@ 145,310			   BmpButton Type 1 Action FechaDet()
@ 145,350			   BmpButton Type 2 Action Close(oDlg2)
@ 150,015 say /*T__fAjTxt(*/STR0004+tran(_nValTot,"@er 999,999,999.99")/*)*/ //"Valor de venda das mercadorias: "
ACTIVATE DIALOG oDlg2 CENTERED

Return (Nil)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ FechaDet ³ Autor ³ CLEBER L. SOUZA       ³ Data ³ 06/05/00 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ CRIA TELA COM DETALHES DO ORCAMENTO                        ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ---ÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

Static Function FechaDet()
Close(oDlg2)
Close(oDlgPeds)
Return (Nil)


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ Cria_TUA ³ Autor ³ CLEBER L. SOUZA       ³ Data ³ 06/05/00 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ CRIA TELA COM DETALHES DO ORCAMENTO                        ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ---ÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

Static Function Cria_TUA()

DbSelectArea('SX3')
DbSetOrder(1)
aFields := {}
aTitPict := {}
DbSeek('SUA')
While !Eof() .And. X3_ARQUIVO = 'SUA'
   If !(ALLTRIM(X3_CAMPO) $ _cCampos) .Or. ALLTRIM(X3_CAMPO) == 'UA_COND' .Or. ALLTRIM(X3_CAMPO) == 'UA_CODOBS' .Or. ALLTRIM(X3_CAMPO) == 'UA_OBS' 
   	  DbSkip()
      Loop
   EndIf   
   AAdd(aFields,{X3_CAMPO,X3_TIPO,X3_TAMANHO,X3_DECIMAL})
   AAdd(aTitPict,{X3_CAMPO,ALLTRIM(X3_TITULO),X3_PICTURE})
   DbSkip()
End   
cArq:=Criatrab(aFields,.T.)
DBUSEAREA(.t.,,cArq,"TUA")

Return(Nil)


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ Cria_TUB ³ Autor ³ CLEBER L. SOUZA       ³ Data ³ 06/05/00 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ CRIA TELA COM DETALHES DO ORCAMENTO                        ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ---ÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

Static Function Cria_TUB()

DbSelectArea('SX3')
DbSetOrder(1)
aFields2 := {}
aTitPict2 := {}
DbSeek('SUB')
While !Eof() .And. X3_ARQUIVO = 'SUB'
   If !(ALLTRIM(X3_CAMPO) $ _cCampos2) .Or. ALLTRIM(X3_CAMPO)+' ' = 'UB_DESC '
   	  DbSkip()
      Loop
   EndIf   
   AAdd(aFields2,{X3_CAMPO,X3_TIPO,X3_TAMANHO,X3_DECIMAL})
   If Alltrim(X3_CAMPO)+' ' <> 'UB_NUM '
      AADD(aTitPict2,{X3_CAMPO,ALLTRIM(X3_TITULO),X3_PICTURE})
   EndIf   
   DbSkip()
End   
cArq2:=Criatrab(aFields2,.T.)
DBUSEAREA(.t.,,cArq2,"TUB")

Return(Nil)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ Monta_TUA³ Autor ³ CLEBER L. SOUZA       ³ Data ³ 06/05/00 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ CRIA TELA COM DETALHES DO ORCAMENTO                        ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ---ÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

Static Function Monta_TUA()
Local _nX

_nCount := 0
cQueryCad := ""
For _nX := 1 To 2
	If _nX = 1
		cQueryCad := "SELECT COUNT(*) AS TOTAL FROM "+RetSqlName('SUA')+" UA WHERE "
	Else
		cQueryCad := "SELECT TOP 10 "+_cCampos
		cQueryCad += " FROM "+RetSqlName('SUA')+" UA  WHERE "
	EndIf
	cQueryCad += "UA.D_E_L_E_T_ <> '*' AND "
	cQueryCad += "UA.UA_FILIAL = '"+xFilial("SUA")+"' AND "
	cQueryCad += "UA.UA_CLIENTE = '"+M->UA_CLIENTE+"'"
	If _nX = 2
		cQueryCad += " ORDER BY UA_NUM DESC "
	EndIf
	TCQUERY cQueryCad NEW ALIAS "CAD"
	If _nX = 1
		_nCount := If(CAD->TOTAL>10,10,CAD->TOTAL)
		DbCloseArea()
	EndIf
Next

TcSetField('CAD','UA_EMISSAO','D')

DbSelectArea("CAD")
DbGoTop()
ProcRegua(_nCount)

While CAD->(!Eof())
	IncProc()
	RecLock("TUA",.T.)
	For _nX := 1 To Len(aFields)
		If aFields[_nX,2] = 'C'
			_cX := 'TUA->'+aFields[_nX,1]+' := Alltrim(CAD->'+aFields[_nX,1]+')'
		Else
			_cX := 'TUA->'+aFields[_nX,1]+' := CAD->'+aFields[_nX,1]
		EndIf
		_cX := &_cX
	Next
	MsUnLock()
	CAD->(DbSkip())
End
DbSelectArea("CAD")
DbCloseArea()
DbSelectArea("TUA")
DbGoTop()

_cIndex:=Criatrab(Nil,.F.)
_cChave:="UA_CLIENTE"
Indregua("TUA",_cIndex,_cChave,,,STR0005) //"Ordenando registros selecionados..."
DbSetIndex(_cIndex+ordbagext())

SysRefresh()
Return(Nil)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ Monta_TUB³ Autor ³ CLEBER L. SOUZA       ³ Data ³ 06/05/00 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ CRIA TELA COM DETALHES DO ORCAMENTO                        ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ---ÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

Static Function Monta_TUB()
Local _nX

_nCount := 0
cQueryCad := ""
For _nX := 1 To 2
    If _nX = 1
   	   cQueryCad := "SELECT COUNT(*) AS TOTAL FROM "+RetSqlName('SUB')+" UB WHERE "
   	Else 
   	   cQueryCad := "SELECT "+_cCampos2
   	   cQueryCad += " FROM "+RetSqlName('SUB')+" UB WHERE "   	   
   	EndIf
	cQueryCad += "UB.D_E_L_E_T_ <> '*' AND "
	cQueryCad += "UB.UB_FILIAL = '"+xFilial("SUB")+"' AND "
    cQueryCad += "UB.UB_NUM = '"+TUA->UA_NUM+"' "
    If _nX = 2   	
       cQueryCad += " ORDER BY UB_NUM, UB_ITEM "
    EndIf   
	TCQUERY cQueryCad NEW ALIAS "CAD"
	If _nX = 1
	   _nCount := CAD->TOTAL
	   DbCloseArea()
	EndIf
Next	

DbSelectArea("CAD")                  
DbGoTop()
ProcRegua(_nCount)

While CAD->(!Eof())
	IncProc()
	RecLock("TUB",.T.)
    For _nX := 1 To Len(aFields2)
        If aFields2[_nX,2] = 'C'
           _cX := 'TUB->'+aFields2[_nX,1]+' := Alltrim(CAD->'+aFields2[_nX,1]+')'
        Else
           _cX := 'TUB->'+aFields2[_nX,1]+' := CAD->'+aFields2[_nX,1]           
        EndIf   
        _cX := &_cX           
    Next
	MsUnLock()	
	CAD->(DBSkip())
End  
Dbselectarea("CAD")                  
DbCloseArea()
Dbselectarea("TUB")                  
DbGoTop()

_cIndex2:=Criatrab(Nil,.F.)
_cChave:="UB_NUM+UB_ITEM"
Indregua("TUB",_cIndex2,_cChave,,,STR0005) //"Ordenando registros selecionados..."
DbSetIndex(_cIndex2+ordbagext())

SysRefresh()
Return(Nil)
