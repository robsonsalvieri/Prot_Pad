#INCLUDE "tcoma04.ch"
#INCLUDE "rwmake.ch"
#INCLUDE "TOPCONN.CH"

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณTCOMA04   บ Autor ณ EWERTON C TOMAZ    บ Data ณ  21/08/01   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ MarkBrowse com filtro de pedidos para pesquisa, visualiza  บฑฑ
ฑฑบ          ณ cao e impressao                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP5 IDE                                                    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/

Template function TCOMA04()
Local _nX

CHKTEMPLATE("DCM")  

/*
MV_PAR01 - Pedido De
MV_PAR02 - Pedido Ate
MV_PAR03 - Fornecedor De
MV_PAR04 - Fornecedor Ate
MV_PAR05 - Produto De
MV_PAR06 - Produto Ate
MV_PAR07 - Fantasia For
MV_PAR08 - Fantasia For
MV_PAR09 - Emissao De
MV_PAR10 - Emissao Ate
MV_PAR11 - Entrega De
MV_PAR12 - Entrega Ate
MV_PAR13 - Situacao (Aberto/Atendido Parcial/Atendido/Ambos)
MV_PAR14 - Ordem (Pedido/Fornecedor+Pedido/Entrega+Fornecedor+Pedido)
MV_PAR15 - Comprador
*/
           
Private cPerg        := Padr("COMA04",Len(SX1->X1_GRUPO))

If !Pergunte(cPerg,.T.)
	//mv_par01 = "Pedido De          ?"
	//mv_par02 = "Pedido Ate         ?"
	//mv_par03 = "Fornecedor De      ?"
	//mv_par04 = "Fornecedor Ate     ?"
	//mv_par05 = "Produto De         ?"
	//mv_par06 = "Produto Ate        ?"
	//mv_par07 = "Fantasia For De    ?"
	//mv_par08 = "Fantasia For Ate   ?"
	//mv_par09 = "Emissao De         ?"
	//mv_par10 = "Emissao Ate        ?"
	//mv_par11 = "Entrega De         ?"
	//mv_par12 = "Entrega Ate        ?"
	//mv_par13 = "Situacao           ?" ("Aberto";"Atendido Parcial";"Atendido";"Ambos")
	//mv_par14 = "Ordem              ?" ("Pedido";"Fornecedor+Pedido";"Entrega+Fornec.+Pedido";"Nome Reduzido+Pedido")
	//mv_par15 = "Comprador          ?"
	Return(.T.)
Endif

Private _cMarca
Private cCadastro:=STR0001+If(MV_PAR13=1,STR0002,If(MV_PAR13=2,STR0003,If(MV_PAR13=3,STR0004,STR0005))) //"Pedidos de Compra "###"Abertos"###"Atendidos Parcialmente"###"Atendidos"###"Abertos/Atendidos Parcialmente/Atendidos"
Private cDelFunc := ".T."
Private cString:="SC7"
Private _lFiltra:=.f.
Private _cOper
Private _lSair:=.f.
Private cQueryCad := ""
Private aFields := {}  
Private cArq    := ""
Private _nCount := _nCount2 := _nCount3 := _nCount4 := _nCount5 := 0
Private _cCampos  := 'C7_NUM, C7_EMISSAO, C7_DATPRF, C7_FORNECE, C7_LOJA,'+;
                     ' C7_NREDUZ, C7_CONTATO, C7_COND, Y1_NOME, C7_ENCER '
//Private _cArqSel  := 'SC7/SY1'
Private _aArqSel  := {'SC7','SY1'}
//Private _cArqSel2 := 'SC7'+SM0->M0_CODIGO+'0, SY1'+SM0->M0_CODIGO+'0'
Private _cArqSel2 := RetSqlName('SC7')+' , '+RetSqlName('SY1')+'  '
Private _cOrdem   := ''
Private _cPesqPed := Space(6)
If MV_PAR14 = 1
   _cOrdem := 'C7_NUM'
ElseIf MV_PAR14 = 2
   _cOrdem := 'C7_FORNECE, C7_NUM'
ElseIf MV_PAR14 = 3
   _cOrdem := 'C7_DATPRF, C7_FORNECE, C7_NUM'
ElseIf MV_PAR14 = 4
   _cOrdem := 'C7_NUM'
Endif

@ 100,005 TO 500,750 DIALOG oDlgPedC TITLE STR0006 //"Pedidos de Compra"
aCampos := {}
DbSelectArea('SX3')
DbSetOrder(1)
AADD(aCampos,{'000','C7_OK','','@!','2','0'})
For _nX := 1 To Len(_aArqSel)
	DbSeek(_aArqSel[_nX])
	While !Eof() .And. X3_ARQUIVO = _aArqSel[_nX]
	   If ALLTRIM(X3_CAMPO)+',' $ _cCampos .Or. ALLTRIM(X3_CAMPO)+' ' $ _cCampos
    	  AADD(aCampos,{StrZero(AT(ALLTRIM(X3_CAMPO),_cCampos),3,0),Alltrim(X3_CAMPO),Alltrim(X3_TITULO),X3_PICTURE,X3_TAMANHO,X3_DECIMAL})
	   Endif
	   DbSkip()
	EndDo   
Next
ASort(aCampos,,,{|x,y|x[1]<y[1]})

aCampos2 := {}
For _nX := 1 To Len(aCampos)
    AADD(aCampos2,{aCampos[_nX,2],aCampos[_nX,3],aCampos[_nX,4],aCampos[_nX,5],aCampos[_nX,6]})
Next
aCampos := {}
aCampos := aCampos2
Cria_TC7()
DbSelectArea('TC7')
@ 006,005 TO 190,325 BROWSE "TC7" MARK "C7_OK" ENABLE "VerHabiC()" FIELDS aCampos 
@ 006,330 BUTTON "_Manut.Pedidos"  SIZE 40,15 ACTION ChamaManPed(1)
@ 026,330 BUTTON "_Visual.Pedido"  SIZE 40,15 ACTION ChamaManPed(2)
@ 046,330 BUTTON "_Imp.Pedidos"    SIZE 40,15 ACTION ImprimirPed()
@ 066,330 BUTTON "Imp._Relatorio"  SIZE 40,15 ACTION ImprimirRel()
@ 183,330 BUTTON "_Sair"                         SIZE 40,15 ACTION Close(oDlgPedC)
                          
Processa({|| Monta_TC7() } ,STR0007) //"Selecionando Informacoes dos Pedidos de Compra..."

//@ 126,330 SAY "Pesquisa Pedido"
//@ 136,335 GET _cPesqPed    Valid Pesquisa()

@ 193,005 SAY STR0008+Alltrim(Str(_nCount,6,0))+; //"Foram processados "
   STR0009+Alltrim(Str(_nCount2,6,0))+; //" registro(s), sendo "
   STR0010+Alltrim(Str(_nCount3,6,0))+;    //" Aberto(s), "
   STR0011+Alltrim(Str(_nCount4,6,0))+; //" Atendido(s) Parcialmente, "
   STR0012 //" Atendido(s) Totalmente"

ACTIVATE DIALOG oDlgPedC CENTERED

DbSelectArea("TC7")
DbCloseArea()
FErase(cArq+OrdBagExt())

Return(.T.)

/*
******************************************************
Static FUNCTION Pesquisa()
Local _aArea := GetArea()
If MV_PAR14 = 1
   If !Empty(_cPesqPed) 
      DbSeek(_cPesqPed)   
      DlgRefresh(oDlgPedC)
      SysRefresh()
   Endif
Else 
   MsgStop('A ordem nao esta por pedido!')
Endif                    
RestArea(_aArea)
Return(.T.)
*/

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณVerHabiC	  บAutor  ณVendas Clientes     บ Data ณ  09/15/05   บฑฑ
ฑฑฬออออออออออุออออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                              บฑฑ
ฑฑบ          ณ                                                              บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ MP8                                                          บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

Function VerHabiC()

CHKTEMPLATE("DCM")  

If Empty(TC7->C7_ENCER) 
   Return(.F.)
Endif   
Return(.T.)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณChamaManPed บAutor  ณVendas Clientes     บ Data ณ  09/15/05   บฑฑ
ฑฑฬออออออออออุออออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                              บฑฑ
ฑฑบ          ณ                                                              บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ MP8                                                          บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function ChamaManPed(_nOpPed)
Local _nX

If _nOpPed = 1                                

   SetKey(120 , { || T_TCOMA03() } ) // F9 chama produto em ponto de pedido 
   MATA121()                                    
   SetKey(120 , )
   
   DbSelectArea('TC7')
   Pergunte(Padr("COMA04",Len(SX1->X1_GRUPO)) ,.F.)   
   If MsgYesNo(STR0013) //'Deseja refazer o Filtro ?'
      DbCloseArea()
      FErase(cArq+OrdBagExt())
      Cria_TC7()
      Processa({|| Monta_TC7() } ,STR0014)    //"Refazendo as Informacoes dos Pedidos de Compra..."
      DlgRefresh(oDlgPedC)
      SysRefresh()
      MsgBox(STR0015,STR0016,'INFO') //'Clique em OK e clique no grid para atualizar !'###'Informacao'
   Endif
ElseIf _nOpPed = 2
   nOpcx:=2
   dbSelectArea("Sx3")
   dbSetOrder(1)
   dbSeek("SC7")
   nUsado := 0
   aHeader:= {}
   aCols  := {}
   While !Eof() .And. (x3_arquivo == "SC7")
      IF X3USO(x3_usado) .AND. cNivel >= x3_nivel
       	 nUsado:=nUsado+1
         AADD(aHeader,{ TRIM(x3_titulo), x3_campo, x3_picture,;
            	x3_tamanho, x3_decimal,x3_valid,;
        	   	x3_usado, x3_tipo, x3_arquivo, x3_context } )
      Endif
      dbSkip()
   EndDo
   aCols:=Array(1,nUsado+1)    
   aCols[1][nUsado+1] := .F. 
              
   DbSelectArea('SC7')
   DbSetOrder(1)
   If DbSeek(xFilial('SC7')+TC7->C7_NUM)
	   cNumero  := SC7->C7_NUM
	   dEmissao := SC7->C7_EMISSAO
	   cFornece := SC7->C7_FORNECE
	   cLoja	:= SC7->C7_LOJA
	   cCond    := SC7->C7_COND
	   cContato := SC7->C7_CONTATO
	   cFilEnt  := SC7->C7_FILENT
	   cCalcIpi := SC7->C7_IPIBRUT
	   cNomeFor := SubStr(Posicione('SA2',1,xFilial('SA2')+cFornece+cLoja,'A2_NOME'),1,40)
	
	   _nAc := 1
	   While SC7->(! Eof()) .And. SC7->C7_FILIAL == xFilial('SC7') .AND. SC7->C7_NUM == cNumero
	      If _nAc > 1
	         AaDd(aCols,Array(nUsado+1))
	      EndIf
	      For _nX := 1 To Len(aHeader)
	          aCols[_nAc,_nX] := FieldGet(FieldPos(Alltrim(aHeader[_nX,2])))
	      Next
	      aCols[_nAc][nUsado+1] := .F. 
	      ++_nAc
	      DbSkip()    
	   EndDo
	
	   cTitulo:=STR0017 //"Pedido de Compra"
	
	   aC:={}
	   AADD(aC,{STR0018	,{15,001},STR0019          ,"@!",,,}) //"cNumero"###"Numero"
	   AADD(aC,{"dEmissao"	,{15,065},STR0020			,"@!",,,}) //"Emissao"
	   AADD(aC,{"cFornece"	,{15,130} ,STR0021	    ,"@!",,,}) //"Fornecedor"
	   AADD(aC,{"cLoja"	    ,{15,195} ,""	            ,"@!",,,})
	   AADD(aC,{"cCond"	    ,{15,240} ,STR0022	    ,"@!",,,}) //"Cond.Pagto"
	   AADD(aC,{"cContato"	,{30,001} ,STR0023 	    ,"@!",,,}) //"Contato"
	   AADD(aC,{"cFilEnt"	,{30,130} ,STR0024	,"@!",,,}) //"Fil.Entrega"
	   AADD(aC,{"cCalcIpi"	,{30,240} ,STR0025	    ,"@!",,,}) //"Calc.IPI"
	
	   aR:={}
	   AADD(aR,{"cNomeFor"	,{130,001},STR0026	,"@!",,,}) //"Fornecedor:"
	
	   aCGD:={85,005,115,315}
	
	   lRetMod2:=Modelo2(cTitulo,aC,aR,aCGD,nOpcx,,,,,,999,{100,0,600,800})
   Else
       MsgStop('Nใo existe nenhum Pedido Selecionado.')
   Endif       
   DbSelectArea('TC7')
                  
ElseIf _nOpPed = 3
   Pergunte(Padr('MTA120',Len(SX1->X1_GRUPO)) ,.F.)
   nOpcx      := 4
   nTipo      := 1
   lAlcada    :=.F.
   lAmarrZero := .F.
   lAp        := .F.
   Inclui     := .F.
   Altera     := .T.
   aTam       := TamSX3("C7_TOTAL")   
/*
aRotina := {{ 'Pesquisas',"A120Pesq", 0 , 1},;
{ 'Visualizar',"A120Visual", 0 , 2},;
{ 'Incluir',"A120Inclui", 0 , 3},;
{ 'Alterar',"A120Altera", 0 , 4, 6},;
{ 'Excluir',"A120Deleta", 0 , 5, 7} }
*/
 aRotina   := MenuDef()
                     
   DbSelectArea('SC7')            
   DbSetOrder(1)
   DbSeek(xFilial('SC7')+TC7->C7_NUM)   
//   A120Altera('SC7',Recno(),nOpcx)
   A120Pedido('SC7',Recno(),nOpcx,6)   
   DbSelectArea('TC7')   
   Pergunte(Padr("COMA04",Len(SX1->X1_GRUPO)) ,.F.)
   DbCloseArea()
   FErase(cArq+OrdBagExt())
   Cria_TC7()
   Processa({|| Monta_TC7() } ,STR0014)    //"Refazendo as Informacoes dos Pedidos de Compra..."
   DlgRefresh(oDlgPedC)
   SysRefresh()
   MsgStop(STR0015) //,'Informacao','INFO') //'Clique em OK e clique no grid para atualizar !'
Elseif _nOpPed =4
   DbSelectArea('TC7')
   Pergunte(Padr("COMA04",Len(SX1->X1_GRUPO)) ,.F.)   
   If msgYesNo(STR0013) //'Deseja refazer o Filtro ?'
      dbCloseArea()
      fErase(cArq+OrdBagExt())
      cria_TC7()
      Processa({|| monta_TC7() } ,STR0014) //"Refazendo as informacoes dos Pedidos de Compra..."
      DlgRefresh(oDlgPedC)
      SysRefresh()
      msgBox(STR0035,STR0016,'INFO') //'Clique em OK e clique no grid para atualizar!'###'Informacao'
   Endif
Endif
Return(.T.)

/*/
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑฺฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฟฑฑ
ฑฑณFun็ใo    ณ MenuDef  ณ Autor ณ Conrado Q. Gomes      ณ Data ณ 11.12.06 ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณDescri…o ณ Defini็ใo do aRotina (Menu funcional)                      ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณSintaxe   ณ MenuDef()                                                  ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณParametrosณ                                                            ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณ Uso      ณ TCOMA04                                                    ณฑฑ
ฑฑภฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤูฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/
Static Function MenuDef()
	Local aRotina := {	{ STR0027	,"PesqBrw"		,0	,1	,0	,.F.	}	,;	//"Pesquisar" //"Pesquisar"
						{ STR0028	,"A120Pedido"	,0	,2	,0	,.T.	}	,;	//"Visualizar" //"Visualizar"
						{ STR0029	,"A120Pedido"	,0	,3	,0	,.T.	}	,;	//"Incluir" //"Incluir"
						{ STR0030	,"A120Pedido"	,0	,4	,6	,.T.	}	,;	//"Alterar" //"Alterar"
						{ STR0031	,"A120Pedido"	,0	,5	,7	,.T.	}	,;	//"Excluir" //"Excluir"
						{ STR0032	,"A120Copia"	,0	,3	,0	,.T.	}	,;	//"Copia"		 //"Copia"
						{ STR0033	,"A120Impri"	,0	,2	,0	,.T.	}	,;	//"Imprimir" //"Imprimir"
						{ STR0034	,"A120Legend"	,0	,2	,0	,.T.	}	}	//"Legenda"                //"Legenda"
Return(aRotina)
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณImprimirPed บAutor  ณMicrosiga           บ Data ณ  09/15/05   บฑฑ
ฑฑฬออออออออออุออออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                              บฑฑ
ฑฑบ          ณ                                                              บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ MP8                                                          บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function ImprimirPed()
DbSelectArea('SX1')
DbSetOrder(1)
DbSeek('MTR110')
While !Eof() .And. X1_GRUPO = 'MTR110'
	RecLock('SX1',.F.)
	If X1_ORDEM $ '01/02'
		X1_CNT01 := TC7->C7_NUM
	ElseIf X1_ORDEM $ '03/04'
		X1_CNT01 := DTOC(TC7->C7_EMISSAO)
	ElseIf X1_ORDEM == '05'
		X1_PRESEL := 2
	ElseIf X1_ORDEM == '06'
		X1_CNT01 := 'C7_DESCRI'
	ElseIf X1_ORDEM == '07'
		X1_PRESEL := 2
	ElseIf X1_ORDEM $ '08/09'
		X1_PRESEL := 1
	ElseIf X1_ORDEM $ '10/11'
		X1_PRESEL := 3
	Endif
	MsUnLock()
	DbSkip()
EndDo
MATR110()
DbSelectArea('TC7')
Return(.T.)
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณImprimirRel บAutor  ณMicrosiga           บ Data ณ  09/15/05   บฑฑ
ฑฑฬออออออออออุออออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                              บฑฑ
ฑฑบ          ณ                                                              บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ MP8                                                          บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function ImprimirRel()
T_TCOMR01(STR0036+If(MV_PAR14=1,STR0037,If(MV_PAR14=2,STR0038,If(MV_PAR14=3,STR0039,STR0040)))) //'Pedidos de Compra - Ordenados por: '###'Pedido'###'Fornecedor+Pedido'###'Entrega+Fornecedor+Pedido'###'Nome Reduzido+Pedido'
DbGoTop()
Return(.T.)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณCria_TC7    บAutor  ณMicrosiga           บ Data ณ  09/15/05   บฑฑ
ฑฑฬออออออออออุออออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                              บฑฑ
ฑฑบ          ณ                                                              บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ MP8                                                          บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function Cria_TC7()
Local _nX

DbSelectArea('SX3')
DbSetOrder(1)
aFields:={}
AADD(aFields,{"C7_OK"     ,"C",02,0})
For _nX := 1 To Len(_aArqSel)
	DbSeek(_aArqSel[_nX])
	While !Eof() .And. X3_ARQUIVO = _aArqSel[_nX]
	   If ALLTRIM(X3_CAMPO)+',' $ _cCampos .Or. ALLTRIM(X3_CAMPO)+' ' $ _cCampos
    	  AADD(aFields,{X3_CAMPO,X3_TIPO,X3_TAMANHO,X3_DECIMAL})
	   Endif   
	   DbSkip()
	EndDo   
Next	
AADD(aFields,{"C7_QUANT","N",12,2})
AADD(aFields,{"C7_QUJE" ,"N",12,2})
cArq:=Criatrab(aFields,.T.)
DBUSEAREA(.t.,,cArq,"TC7")
Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณMonta_TC7   บAutor  ณMicrosiga           บ Data ณ  09/15/05   บฑฑ
ฑฑฬออออออออออุออออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                              บฑฑ
ฑฑบ          ณ                                                              บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ MP8                                                          บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function Monta_TC7()
Local _nX

_nCount := 0
_nCount2:= 0
_nCount3:= 0
_nCount4:= 0
_nCount5:= 0           
_cC7USER:= IIF( !Empty(MV_PAR15), GetAdvFVal("SY1","Y1_USER",xFilial("SY1")+RTRIM(MV_PAR15),1) , MV_PAR15 )
For _nX := 1 To 2
    If _nX = 1
   	   cQueryCad := "SELECT Count(DISTINCT C7_NUM+C7_DATPRF) AS TOTAL FROM "+RetSqlName("SC7")+" LEFT OUTER JOIN "+RetSqlName("SY1")+" ON C7_USER = Y1_USER WHERE "
   	Else 
   	   cQueryCad := "SELECT DISTINCT "
   	   cQueryCad += _cCampos+ ", SUM(C7_QUANT) AS C7_QUANT, SUM(C7_QUJE) AS C7_QUJE"
   	   cQueryCad += " FROM "+RetSqlName("SC7")+" LEFT OUTER JOIN "+RetSqlName("SY1")+" ON C7_USER = Y1_USER WHERE "
   	Endif
	cQueryCad += RetSqlName("SC7")+".D_E_L_E_T_ <> '*' AND "
	cQueryCad += "C7_FILIAL = '"+xFilial("SC7")+"' AND "
	cQueryCad += "C7_RESIDUO = ' ' "	
	If !Empty(MV_PAR01)
	   cQueryCad += "AND C7_NUM >= '"+MV_PAR01+"' AND C7_NUM <= '"+MV_PAR02+"' "
	Endif
	If !Empty(MV_PAR03)
	   cQueryCad += "AND C7_FORNECE >= '"+MV_PAR03+"' AND C7_FORNECE <= '"+MV_PAR04+"' "
	Endif
	If !Empty(MV_PAR05)
	   cQueryCad += "AND C7_PRODUTO >= '"+MV_PAR05+"' AND C7_PRODUTO <= '"+MV_PAR06+"' "
	Endif
	If !Empty(MV_PAR07)
        cQueryCad += "AND C7_NREDUZ >= '"+MV_PAR07+"' AND C7_NREDUZ <= '"+MV_PAR08+"' "
	Endif
	If !Empty(MV_PAR09)
	   cQueryCad += "AND C7_EMISSAO >= '"+DTOS(MV_PAR09)+"' AND C7_EMISSAO <= '"+DTOS(MV_PAR10)+"' "
	Endif
	If !Empty(MV_PAR11)
	   cQueryCad += "AND C7_DATPRF >= '"+DTOS(MV_PAR11)+"' AND C7_DATPRF <= '"+DTOS(MV_PAR12)+"' "
	Endif
	If MV_PAR13 = 1
	   cQueryCad += "AND C7_QUJE = 0 AND C7_ENCER <> 'E' "
	ElseIf MV_PAR13 = 2
	   cQueryCad += "AND C7_QUJE > 0 AND C7_ENCER <> 'E' "	   
	ElseIf MV_PAR13 = 3
	   cQueryCad += "AND C7_ENCER = 'E' "	   
	Endif
	If !Empty(MV_PAR15)
       cQueryCad += "AND C7_USER = '"+_cC7USER+"' "
	Endif
    If _nX = 2
  	   cQueryCad += " GROUP BY "+_cCampos
  	   cQueryCad += " ORDER BY "+_cOrdem
  	Endif   
	TCQUERY cQueryCad NEW ALIAS "CAD"
	If _nX = 1
	   _nCount := CAD->TOTAL
	   DbCloseArea()
	Endif
Next	

TcSetField("CAD","C7_EMISSAO","D")
TcSetField("CAD","C7_DATPRF","D")
Dbselectarea("CAD")                  

ProcRegua(_nCount)

While CAD->(!EOF())
	IncProc()
	RecLock("TC7",.T.)
    For _nX := 1 To Len(aFields)
        If !(aFields[_nX,1] $ 'C7_OK')
           If aFields[_nX,2] = 'C'
              _cX := 'TC7->'+aFields[_nX,1]+' := Alltrim(CAD->'+aFields[_nX,1]+')'
           Else
              _cX := 'TC7->'+aFields[_nX,1]+' := CAD->'+aFields[_nX,1]           
           Endif   
           _cX := &_cX           
        Endif   
    Next
	MsUnLock()
    RecLock("TC7",.F.)       	
	If (TC7->C7_QUANT - TC7->C7_QUJE) <= 0 .And. TC7->C7_ENCER = 'E'
       TC7->C7_OK    := ThisMark()
       ++_nCount4   
  	ElseIf TC7->C7_QUJE > 0 .And. TC7->C7_QUANT > TC7->C7_QUJE .And. Empty(TC7->C7_ENCER)
       TC7->C7_OK    := ThisMark()
       ++_nCount3
  	Else    
       TC7->C7_OK := _cMarca
  	   ++_nCount2  	   
    Endif   
    MsUnLock()   	       
	CAD->(dBSkip())
EndDo
Dbselectarea("CAD")                  
DbCloseArea()
Dbselectarea("TC7")                  
DbGoTop()

_cIndex:=Criatrab(Nil,.F.)
_cChave:=StrTran(_cOrdem,",","+")
Indregua("TC7",_cIndex,_cChave,,,STR0041) //"Ordenando registros selecionados..."
DbSetIndex(_cIndex+ordbagext())

DlgRefresh(oDlgPedC)
SysRefresh()

Return