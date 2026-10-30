#INCLUDE "tcoma08.ch"
#INCLUDE "rwmake.ch"
#INCLUDE "COLORS.CH"

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³TCOMA08   º Autor ³ Ewerton C Tomaz    º Data ³  26/11/01   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Programa de Geracao de Pedidos de Compra pelo Filtro da    º±±
±±º          ³ Politica de Precos                                         º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP5 IDE                                                    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

Template Function TCOMA08()

CHKTEMPLATE("DCM")  

Private cCadastro:=STR0001 //"Manutencao da Politica de Precos"
Private cPerg    := Padr("COMA01",Len(SX1->X1_GRUPO))
Private cString  := "LH7"
Private _cMarca  := "XX"
Private _lFiltra := .F.
Private aCampos1 := {}
Private aTam1    := {}
Private aEstru1  := {}
Private aEstru2  := {}
Private TMP      := "" 
Private cIndTrb1 := ""
Private cMark    := GETMARK()
Private _nTotal  := 0
Private oTotalF

Dbselectarea("LH7")

Private aRotina := MenuDef()

DbSelectArea("LH7")
If !T_COM01b()
	Return
Endif
Dbselectarea("LH7")
MarkBrowse("LH7","LH7_MARC","",,,_cMarca)
RetIndex("LH7")
Return   

/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Função    ³ MenuDef  ³ Autor ³ Conrado Q. Gomes      ³ Data ³ 11.12.06 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Definição do aRotina (Menu funcional)                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ MenuDef()                                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ TCOMA08                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/   

Static Function MenuDef()
Local aRotina := {{STR0002, "Axpesqui",   0, 3},;	//"Pesquisa"
                  {STR0003, "T_COM01b",   0, 3},;	//"Filtrar/Marcar"
                  {STR0004, "T_TCOMA08G", 0, 3}}		//"Gera Pedido   "
Return(aRotina)

/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Função    ³ TCOMA08G ³ Autor ³ Conrado Q. Gomes      ³ Data ³ 11.12.06 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³											                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ TCOMA08                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/   

Template Function TCOMA08G()

Local _xy
Local _nX
Private oDlg3
Private _aCamposPer := {}
Private _cCamposPer := "" 

CHKTEMPLATE("DCM")  

If ExistBlock("TCOMA01PC")
	_cVarProg := "U_TCOMA01PC()"
Else
	_cVarProg := "T_TCOMA01PC()"
Endif

_cMarca:="XX"
AaDd(_aCamposPer,{"C7_ITEM","StrZero(nCnt,4)"})
AaDd(_aCamposPer,{"C7_PRODUTO","LH7->LH7_COD"})
AaDd(_aCamposPer,{"C7_DESCRI","LH7->LH7_DESC"})
AaDd(_aCamposPer,{"C7_UM","LH7->LH7_UM"})
AaDd(_aCamposPer,{"C7_QUANT","IIF(Posicione('SB1',1,xFilial('SB1')+LH7->LH7_COD,'B1_EMIN')>0,SB1->B1_EMIN,1)"})
AaDd(_aCamposPer,{"C7_PRECO",_cVarProg}) // AaDd(_aCamposPer,{"C7_PRECO","T_TCOMA01PC()"}) 
AaDd(_aCamposPer,{"C7_TOTAL","(aCols[nCnt,Ascan(aHeader,{|x|Alltrim(x[2])=='C7_QUANT'})]*"+_cVarProg+")"})//AaDd(_aCamposPer,{"C7_TOTAL","(aCols[nCnt,Ascan(aHeader,{|x|Alltrim(x[2])=='C7_QUANT'})]*T_TCOMA01PC())"})  

altera := .T.
@ 100,1 TO 450,640 DIALOG oDlg3 TITLE STR0006 //"Gera Pedido de Compra"
cAliasO:= "LH7"
cAlias := "SC7"
DbSelectArea( cAlias )
nOrdem := IndexOrd()
aHeader := {}


DbSelectArea("SX3")
_aAreaSX3 := GetArea()
DbSetOrder(2)
For _nx := 1 to Len(_aCamposPer) 
    If dBSeek(_aCamposPer[_nx,1]) 
		AADD(aHeader,{ TRIM(X3_TITULO), X3_CAMPO, X3_PICTURE,;
		X3_TAMANHO, X3_DECIMAL,"",;         //X3_VALID,; 
		X3_USADO, X3_TIPO, X3_ARQUIVO } )
    Endif
Next 
DbSelectArea("SX3")
RestArea(_aAreaSX3)

DbSelectArea( cAliasO )
DbGoTop()
nCnt := 0
While !EOF()
	If LH7->LH7_MARC == _cMarca
		nCnt ++
	Endif
	DbSkip()
End
aCOLS := Array(nCnt,Len(_aCamposPer)+1)
DbSelectArea( cAliasO )
DbGoTop()
nCnt := _nTotal := 0
While !EOF()
	If LH7->LH7_MARC <> _cMarca
		DbSkip()
		Loop
	Endif
	nCnt ++
	For _nX := 1 To Len(_aCamposPer)
			aCOLS[nCnt][_nX] := &(_aCamposPer[_nX,2])	
	Next
	aCOLS[nCnt][Len(_aCamposPer)+1] := .F.
	DbSkip()
EndDo       
//---------------------------------------------------------------
_nPosxQTD := Ascan(aHeader,{|x|Alltrim(x[2])=='C7_QUANT'})
_nPosxPRE := Ascan(aHeader,{|x|Alltrim(x[2])=='C7_PRECO'})
For _xy := 1 to Len(aCols)
	_nTotal += ( aCOLS[_xy][_nPosxQTD] * aCOLS[_xy][_nPosxPRE])
Next _xy
//---------------------------------------------------------------
DbSelectArea( cAliasO )
DbGoTop()
nRegistro := RecNo()

oTotalF:= TGET():Create(oDlg3)
oTotalF:cName := "oGet1"
oTotalF:cCaption := STR0007 //"Total"
oTotalF:nLeft := 080
oTotalF:nTop := 310
oTotalF:nWidth := 100
oTotalF:nHeight := 21
oTotalF:lShowHint := .T.
oTotalF:lReadOnly := .T.
oTotalF:Align := 0
oTotalF:lVisibleControl := .T.
oTotalF:lPassword := .F.
oTotalF:lHasButton := .F.
oTotalF:Picture := '@ER 999,999.9999'
oTotalF:cVariable := "_nTotal"
oTotalF:bSetGet := {|u| If(PCount()>0,_nTotal:=u,_nTotal) }
oTotalF:oFont := TFont():New("Times New Roman",6,15,,.T.,,,,.F.,.F.)
oTotalF:SetColor(CLR_BLUE,CLR_WHITE)
                 
@ 158,005 SAY STR0008 //"Total:"
//@ 158,025 GET _nTotal SIZE 40,15 When .F.
@ 6,5 TO 155,315 MULTILINE MODIFY DELETE VALID LineOk() FREEZE 1
@ 158,220 BUTTON STR0009 SIZE 40,15 ACTION Confirma(LH7->LH7_CODF, LH7->LH7_LOJA, aCols) //"_Confirma"
@ 158,270 BUTTON STR0010 SIZE 40,15 ACTION Close(oDlg3) //"_Sair"
ACTIVATE DIALOG oDlg3 CENTERED
dbSelectArea( cAlias )
DbSetOrder(nOrdem)
DbGoTop()

Return
           
/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Função    ³ LineOk   ³ Autor ³ Conrado Q. Gomes      ³ Data ³ 11.12.06 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³											                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ TCOMA08                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/   

Static Function LineOk()               
Local _aColsTot := aCols      
Local _nPosxQTD := Ascan(aHeader,{|x|Alltrim(x[2])=='C7_QUANT'})
Local _nPosxPRE := Ascan(aHeader,{|x|Alltrim(x[2])=='C7_PRECO'})
Local _nX

_nTotal   := 0
For _nX := 1 To Len(_aColsTot)
	_nTotal += GDFieldGet("C7_TOTAL",_nX) //aCOLS[_nX][AsCan(aHeader,{|x|Alltrim(x[2])=="C7_TOTAL"})]
	//_nTotal += ( aCOLS[_xy][_nPosxQTD] * aCOLS[_xy][_nPosxPRE])
Next
oTotalF:Refresh(.T.)
Return(.T.)

/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Função    ³ Confirma ³ Autor ³ Conrado Q. Gomes      ³ Data ³ 11.12.06 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³	 Grava o pedido de compra 				                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ TCOMA08                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/   

Static Function Confirma(_cFornece, _cLoja, _aItensSel)
Local aCab :={}
Local aItem:={}
Local cNumPedcom := GetSx8Num("SC7")
Local nOpc := 3
Local _aCloneCols := _aItensSel
Local _aCloneHeader := aHeader
Local _cItem := '0001'
Local _nX   
Local i := 0

lMsErroAuto := .F.

aCols   := Nil
aHeader := Nil

Posicione('SA2',1,xFilial('SA2')+_cFornece+_cLoja,'A2_COD')

aCab:={{"C7_NUM"     ,cNumPedcom  	  ,Nil},; // Numero do Pedido
        {"C7_EMISSAO" ,dDataBase  	  ,Nil},; // Data de Emissao
        {"C7_FORNECE" ,SA2->A2_COD   ,Nil},; // Fornecedor
        {"C7_LOJA"    ,SA2->A2_LOJA	  ,Nil},; // Loja do Fornecedor
 	    {"C7_CONTATO" ,SA2->A2_CONTATO,Nil},; // Contato
        {"C7_COND"    ,IIF(!Empty(SA2->A2_COND),SA2->A2_COND,"001")   ,Nil},; // Condicao de pagamento
        {"C7_MOEDA"   ,1			,Nil},;
        {"C7_TXMOEDA" ,1			,Nil},;        
	    {"C7_FILENT"  ,cFilial       ,Nil}} // Filial Entrega
                               
For _nX := 1 To Len(_aCloneCols)
	AaDd(aItem,{{"C7_ITEM"   ,_cItem,Nil},; 
	    	    {"C7_PRODUTO",_aCloneCols[_nX,AsCan(_aCloneHeader,{|x|Alltrim(x[2])=="C7_PRODUTO"})],Nil},; 
    	    	{"C7_QUANT"  ,_aCloneCols[_nX,AsCan(_aCloneHeader,{|x|Alltrim(x[2])=="C7_QUANT"})] ,Nil},; 
			    {"C7_PRECO"  ,_aCloneCols[_nX,AsCan(_aCloneHeader,{|x|Alltrim(x[2])=="C7_PRECO"})] ,Nil},; 
		    	{"C7_DATPRF" ,dDataBase		    ,Nil},; 
	        	{"C7_TES"    ,IIF(!Empty(Posicione('SB1',1,xFilial('SB1')+_aCloneCols[_nX,AsCan(_aCloneHeader,{|x|Alltrim(x[2])=="C7_PRODUTO"})],'B1_TE')),SB1->B1_TE,"001"),Nil},; 
			    {"C7_FLUXO"  ,"S"			    ,Nil},; 
			    {"C7_LOCAL"  ,SB1->B1_LOCPAD    ,Nil}})  
	_cItem := SomaIt(_cItem)
Next
// Cria variaveis De Parametro Caso Não Exista
For i := 1 To 20
	_cPar := "MV_PAR" + StrZero(i,2)
	_cParX:= "MV_PARX" + StrZero(i,2)
	&(_cParX) := &(_cPar)
Next

Pergunte(Padr("MTA120",Len(SX1->X1_GRUPO)) ,.f.)

MSExecAuto({|v,x,y,z| MATA120(v,x,y,z)},1,aCab,aItem,nOpc)

If lMsErroAuto
   MostraErro()
Else
   ConfirmSX8()
   MsgBox(STR0011+cNumPedcom+STR0012,STR0013,'INFO') //'Pedido '###' Gerado com Sucesso!'###'Gera Pedido de Compra'
EndIf 

For i := 1 To 20
	_cPar := "MV_PAR" + StrZero(i,2)
	_cParX:= "MV_PARX" + StrZero(i,2)
	&(_cPar) := &(_cParX)
Next
Close(oDlg3)

Return