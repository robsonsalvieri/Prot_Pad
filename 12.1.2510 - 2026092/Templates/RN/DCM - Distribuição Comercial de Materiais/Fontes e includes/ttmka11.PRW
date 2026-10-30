#INCLUDE "ttmka11.ch"
#INCLUDE "rwmake.ch"
#INCLUDE "TOPCONN.CH"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณTTMKA11   บAutor  ณEwerton Carlos Tomazบ Data ณ  13/01/02   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Novo cadastro de contratos                                 บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP7                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

Template Function TTMKA11(_cOper)

CHKTEMPLATE("DCM")

Static _lPrim
If _lPrim == Nil
	_lPrim := .T.
EndIf
DbSelectArea("LH4")
Private cString   := Alias()
Private cCadastro := cTitulo := Posicione("SX2",1,alias(),"x2_chave+' - '+x2_nome")
Private _cTudoOk  := "TudoOk" 
Private _cLinhaOk := "LinhaOk" 
Private _cRefresh := "Refresh"
Private _cVisual  := "VISUALIZAR"
Private _cIncluir := "INCLUIR"
Private _cAlterar := "ALTERAR"
Private _cExcluir := "EXCLUIR" 
Private cPerg     := Padr("TTMA11", Len(SX1->X1_GRUPO) )
Private _cFiliais := "FILIAIS"
Private _cRemaneja:= "REMANEJA"
Private Inclui    := altera := _lAtEnd := .F.

Do Case
	Case _cOper == Nil // Chamada do menu
		
		cDelFunc := ".T."
		
        aRotina := MenuDef()
		
		mBrowse( 6,1,22,75,'LH4',,"LH4_NUMORC")
	Case _cOper==_cLinhaOk
		_lLinhaOk:=.T.
		Return _lLinhaOk
	Case _cOper==_cTudoOk
		_lTudoOk:=.t.
		Return _lTudoOk
	Case _cOper==_cFiliais
		cCadastro := STR0008 //"Cadastro de Filiais para Contrato"
		
		DbSelectArea("LH6")
		DbSetOrder(1)
		
		_cFiltroZF :="LH6_CODCON = '" + LH4->LH4_COD + "'"
		Indregua('LH6',criatrab(,.f.),"LH6_FILIAL+LH6_NOMESO",,_cFiltroZF,STR0009) //'Selecionando registros'
		DbGotop()
		
		AXCadastro("LH6",cCadastro)
		
		RetIndex("LH6")
		DbSelectArea("LH4")
		cCadastro:=cTitulo:=posicione("SX2",1,alias(),"x2_chave+' - '+x2_nome")
		Return
	Case "pegalinha" $ Lower(Alltrim(_cOper))
		Return(StrZero(val(aCols[Len(aCols)-1,1])+1,4,0))
	Case "remaneja" $ Lower(Alltrim(_cOper))
		Private oEstoque
		_cCodPro := Space(TamSX3("B1_COD")[01])
		_cCliente:= Space(100)
		_aCliente:= {}
		_cPedido := Space(6)
		_nQuant  := 0
		DEFINE MSDIALOG oEstoque FROM  63,181 TO 335,700 TITLE STR0010 PIXEL  //"Remaneja Contrato / Estoque"
		@ 010,002 TO  050,255
		@ 002,002 SAY "Informe o Produto"  SIZE  56, 7
		@ 016,004 SAY "Codigo"             SIZE  21, 7
		@ 015,033 GET _cCodPro             SIZE  115, 9 Valid(Busca(1))
		@ 016,180 SAY STR0011              SIZE  25, 7  //"Unidade"
		@ 015,215 GET SB1->B1_UM           SIZE  14, 9 When .F.
		@ 035,004 SAY STR0012              SIZE  32, 7  //"Descricao"
		@ 034,033 GET SB1->B1_DESC         SIZE 135, 9 When .F.
		@ 065,002 TO 115,255
		
		DEFINE SBUTTON FROM 122,170 TYPE 1 ACTION Atualiza()      ENABLE OF oEstoque
		DEFINE SBUTTON FROM 122,210 TYPE 2 ACTION Close(oEstoque) ENABLE OF oEstoque
		ACTIVATE MSDIALOG oEstoque CENTER
		
	OtherWise
		msgbox(STR0013+_cOper) //"Rotina nao prevista: "
EndCase
Return

Template Function LH4Cadastro(cOpcao)
Local _ni
Local _nVez

CHKTEMPLATE("DCM")

Do Case
	Case cOpcao=="INCLUIR"; nOpcE:=3 ; nOpcG:=3
	Case cOpcao=="ALTERAR"; nOpcE:=3 ; nOpcG:=3
	Case cOpcao=="EXCLUIR"; nOpcE:=2 ; nOpcG:=2
	Case cOpcao=="VISUALIZAR"; nOpcE:=2 ; nOpcG:=2
EndCase
//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Cria variaveis M->????? da Enchoice                          ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
RegToMemory("LH4",(cOpcao=="INCLUIR"))
//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Cria aHeader e aCols da GetDados                             ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
nUsado:=0
DbSelectArea("SX3")
DbSeek("LH5")
aHeader:={}
While !Eof().And.(x3_arquivo=="LH5")
	If Alltrim(x3_campo)$"LH5_CODCON;LH5_CLIENT;LH5_MSEXP;LH5_USERGA;LH5_USERGI"
		DbSkip()
		Loop
	EndIf
	If X3USO(x3_usado).And.cNivel>=x3_nivel
		nUsado:=nUsado+1
		Aadd(aHeader,{ Trim(x3_titulo), x3_campo, x3_picture,;
		x3_tamanho, x3_decimal, x3_valid,;
		x3_usado, x3_tipo, x3_arquivo, x3_context } )
	EndIf
	DbSkip()
End

If cOpcao=="INCLUIR"
	aCols:={Array(nUsado+1)}
	aCols[1,nUsado+1]:=.F.
	For _ni:=1 To nUsado
		aCols[1,_ni]:=CriaVar(aHeader[_ni,2])
	Next
Else
	aCols:={}
	DbSelectArea("LH5")
	DbSetOrder(2)
	DbSeek(xFilial("LH5")+M->LH4_COD)
	While LH5->(! Eof()) .AND. LH5->LH5_FILIAL == xfilial("LH5") .AND. LH5_CODCON==M->LH4_COD
		AADD(aCols,Array(nUsado+1))
		For _ni:=1 To nUsado
			aCols[Len(aCols),_ni]:=FieldGet(FieldPos(aHeader[_ni,2]))
		Next
		aCols[Len(aCols),nUsado+1]:=.F.
		DbSkip()
	End
EndIf
If Len(aCols)>0
	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณ Executa a Modelo 3                                           ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	cTitulo:=STR0014 //"Manutencao na Tabela de Contratos"
	cAliasEnchoice:="LH4"
	cAliasGetD:="LH5"
	cLinOk:="T_TTMKA11(_cLinhaOk)"
	cTudOk:="T_TTMKA11(_cTudoOk)"
	cFieldOk:="AllwaysTrue()"
	aCpoEnchoice:={"LH4_CLIENT"}
	
	_lRet := Modelo3(cTitulo /*cTitulo*/, cAliasEnchoice /*cAlias*/, cAliasGetD /*cAlias2*/,;
	                 aCpoEnchoice /*aMyEncho*/, cLinOk /*cLinhaOk*/, cTudOk /*cTudoOk*/,;
	                 nOpcE /*nOpcE*/, nOpcG /*nOpcG*/, cFieldOk /*cFieldOk*/, /*lVirtual*/,;
	                 9999 /*nLinhas*/, /*aAltEnchoice*/, /*nFreeze*/, /*aButtons*/,;
	                 /*aCordW*/, 300 /*nSizeHeader*/)

	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณ Executar processamento                                       ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	If _lRet
		_nOrdLH4:=LH4->(indexord())
		LH4->(Dbsetorder(1))
		Do case
			case cOpcao=="INCLUIR"
				_nItem:=1
				For _nVez:=1 To Len(aCols)
					// so appEnda se nao estiver marcado e nao existir
					If _nVez = 1 .And. !LH4->(DbSeek(xfilial("LH4")+M->LH4_COD))
						RecLock('LH4',.T.)
						LH4->LH4_FILIAL :=xfilial("LH4")
						LH4->LH4_COD    :=M->LH4_COD
						LH4->LH4_CLIENT :=M->LH4_CLIENT
						LH4->LH4_LOJA   :=M->LH4_LOJA
						LH4->LH4_NOME   :=M->LH4_NOME
						LH4->LH4_INICIO :=M->LH4_INICIO
						LH4->LH4_FINAL  :=M->LH4_FINAL
						LH4->LH4_REAJUS :=M->LH4_REAJUS
						LH4->LH4_COMISS :=M->LH4_COMISS
						LH4->LH4_CONDPA :=M->LH4_CONDPA
						LH4->LH4_NUMORC :=M->LH4_NUMORC
						LH4->LH4_OBSERV :=M->LH4_OBSERV
						MsUnlock()
					EndIf
					If !aCols[_nVez,nUsado+1]
						LH5->(reclock('LH5',.t.))
						_fReplLH5(_nVez)
						LH5->(msunlock())
					EndIf
				Next
				ConfirmSx8()
			Case cOpcao=="ALTERAR"
				// Primeiro verIfica eventuais exclusoes de itens
				
				LH5->(DbSetOrder(2))
				For _nVez:=1 to len(aCols)
					If _nVez = 1 .And. LH4->(DbSeek(xfilial("LH4")+M->LH4_COD))
						RecLock('LH4',.F.)
						LH4->LH4_FILIAL :=xfilial("LH4")
						LH4->LH4_COD    :=M->LH4_COD
						LH4->LH4_CLIENT :=M->LH4_CLIENT
						LH4->LH4_LOJA   :=M->LH4_LOJA
						LH4->LH4_NOME   :=M->LH4_NOME
						LH4->LH4_INICIO :=M->LH4_INICIO
						LH4->LH4_FINAL  :=M->LH4_FINAL
						LH4->LH4_REAJUS :=M->LH4_REAJUS
						LH4->LH4_COMISS :=M->LH4_COMISS
						LH4->LH4_CONDPA :=M->LH4_CONDPA
						LH4->LH4_NUMORC :=M->LH4_NUMORC
						LH4->LH4_OBSERV :=M->LH4_OBSERV
						MsUnlock()
					EndIf
					
					// Inclui os Itens de Contrato Novamente
					
					_lAchou:=.f.
					If LH5->(Dbseek(xfilial("LH5")+M->LH4_COD+aCols[_nVez,1],.f.))
						_lAchou := .t.
					EndIf
					
					If !aCols[_nVez,nUsado+1] .And. _lAchou  // Se Achar o Registro Regrava
						LH5->(reclock('LH5',.f.))
						_fReplLH5(_nVez)
						LH5->(msunlock())
					ElseIf !aCols[_nVez,nUsado+1] .And. .Not. _lAchou  // Se Nao Achar o Registro Adiciona
						LH5->(reclock('LH5',.t.))
						_fReplLH5(_nVez)
						LH5->(msunlock())
					ElseIf aCols[_nVez,nUsado+1] .And. _lAchou
						// Se linha deletada apaga o item do arquivo
						
						If LH5->(reclock(alias(),.f.))
							LH5->(dbdelete())
							LH5->(msunlock())
						EndIf
					EndIf
				Next
			Case cOpcao=="EXCLUIR".and.msgyesno(STR0015) //"Confirma a exclusao do contrato ?"
				
				// Apaga o Cabe็alho do Contrato Posicionado
				
				LH4->(Dbsetorder(1))
				LH4->(Dbseek(xfilial("LH4")+M->LH4_COD,.f.))
				If LH4->(reclock(alias(),.f.))
					LH4->(dbdelete())
					LH4->(msunlock())
				EndIf
				
				// Apaga todas as Informa็๕es Referentes ao Contrato Anterior
				// Arquivo de Itens
				
				LH5->(DbSetOrder(2))
				LH5->(dbseek(xfilial("LH5")+M->LH4_COD,.f.))
				While LH5->(! Eof()) .AND. LH5->LH5_FILIAL == xfilial("LH5") .AND. LH5->LH5_CODCON == M->LH4_COD
					If LH5->(reclock(alias(),.f.))
						LH5->(dbdelete())
						LH5->(msunlock())
					EndIf
					LH5->(Dbskip(1))
				End
				
				// Apaga todas as Informa็๕es Referentes ao Contrato Anterior
				// Clientes Associados
				
				LH6->(DbSetOrder(1))
				LH6->(Dbseek(xfilial("LH6")+M->LH4_COD,.f.))
				While LH6->(! Eof()) .And. LH6->LH6_FILIAL == xfilial("LH6") .AND. LH6->LH6_CODCON == M->LH4_COD
					If LH6->(reclock(alias(),.f.))
						LH6->(dbdelete())
						LH6->(msunlock())
					EndIf
					LH6->(Dbskip(1))
				End
		EndCase
		LH4->(DbSetOrder(_nOrdLH4))
	EndIf
	Return
EndIf
Return (Nil)

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
ฑฑณ Uso      ณ TTMKA11                                                    ณฑฑ
ฑฑภฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤูฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/                            
Static Function MenuDef()
	Local aRotina := {	{ STR0001	,"AxPesqui"		,0	,1	,0	,.F.	}	,;	//"Pesquisa"
	    	      		{ STR0002	,"T_LH4C1()"	,0	,2	,0	,.T.	}	,;	//"Visual"
	    		  		{ STR0003	,"T_LH4C2()"	,0	,3	,0	,.T.	}	,;	//"Inclui"
		      			{ STR0004	,"T_LH4C3()"	,0	,4	,20	,.T.	}	,;	//"Altera"
				    	{ STR0005	,"T_LH4C4()"	,0	,5	,21	,.T.	}	,;	//"Exclui"
				    	{ STR0006	,"T_A111()"		,0	,6	,21	,.T.	}	,;	//"Filiais"
				    	{ STR0007	,"T_A112()"		,0	,6	,21	,.T.	}	}	//"Remanejar"
Return(aRotina)
                                                    
//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณFun็๕es de atalho pois o MenuFuncional nใo permite itensณ
//ณcom parโmetros.                                         ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
Template Function LH4C1()	; T_LH4Cadastro("VISUALIZAR")	; Return(.T.)
Template Function LH4C2()	; T_LH4Cadastro("INCLUIR")		; Return(.T.)
Template Function LH4C3()	; T_LH4Cadastro("ALTERAR")		; Return(.T.)
Template Function LH4C4()	; T_LH4Cadastro("EXCLUIR")		; Return(.T.)
Template Function A111()	; T_TTMKA11("FILIAIS")			; Return(.T.)
Template Function A112()	; T_TTMKA11("REMANEJA")			; Return(.T.)
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณTTMKA11   บAutor  ณEwerton Carlos Tomazบ Data ณ  13/01/02   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Novo cadastro de contratos                                 บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP7                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

Static Function _fReplLH5(_nVez)

LH5->LH5_FILIAL :=xFilial('LH5')
LH5->LH5_CODCON :=M->LH4_COD
LH5->LH5_ITEM   :=T__fValAcols(_nVez,"LH5_ITEM")
LH5->LH5_PRODUT :=T__fValAcols(_nVez,"LH5_PRODUT")
LH5->LH5_DESCRI :=T__fValAcols(_nVez,"LH5_DESCRI")
LH5->LH5_CODCLI :=T__fValAcols(_nVez,"LH5_CODCLI")
LH5->LH5_UM     :=T__fValAcols(_nVez,"LH5_UM")
LH5->LH5_VALOR  :=T__fValAcols(_nVez,"LH5_VALOR")
LH5->LH5_CLIENT :=M->LH4_CLIENT
LH5->LH5_QTDSOL :=T__fValAcols(_nVez,"LH5_QTDSOL")
LH5->LH5_QTDREA :=T__fValAcols(_nVez,"LH5_QTDREA")
LH5->LH5_QTDSAL :=T__fValAcols(_nVez,"LH5_QTDSAL")

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณBusca     บAutor  ณEwerton Carlos Tomazบ Data ณ  13/01/02   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP7                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

Static Function Busca(_nTipo)
If _nTipo = 1
	If Posicione('SB1',1,xFilial('SB1')+_cCodPro,'B1_COD') <> " "
		cQueryCad := "SELECT A1_COD,A1_NOME,LH5_QTDREA,LH5_QTDSAL "
		cQueryCad += "FROM "+RetSqlName('SA1')+","+RetSqlName('LH5')+" WHERE "
		cQueryCad += "LH5_FILIAL = '"+xFilial("LH5")+"' AND "
		cQueryCad += "LH5_CLIENT = A1_COD AND LH5_PRODUT = '"+_cCodPro+"' AND "
		cQueryCad += "LH5_QTDSAL > 0 AND "
		cQueryCad += RetSqlName('SA1')+".D_E_L_E_T_ <> '*' AND "
		cQueryCad += RetSqlName('LH5')+".D_E_L_E_T_ <> '*' "
		cQueryCad += " ORDER BY LH5_QTDSAL DESC , A1_NOME "
		TcQuery cQueryCad NEW ALIAS 'CAD'
		DbSelectArea('CAD')
		While !Eof()
			AAdd(_aCliente,CAD->A1_COD+'-'+SubStr(CAD->A1_NOME,1,30)+STR0016+Str(CAD->LH5_QTDREA,10)+STR0017+Str(CAD->LH5_QTDSAL,10)) //' Ctr:'###' Saldo:'
			DbSkip()
		End  
		DbCloseArea()
		
		@ 057,003 SAY STR0018  SIZE 100, 9  //"Informe os Dados do Cliente e Pedido "
		@ 070,004 SAY STR0019  SIZE  33, 9  //"Cliente"
		@ 069,032 COMBOBOX _cCliente ITEMS _aCliente SIZE  220, 09
		@ 090,004 SAY STR0020  SIZE  30, 9  //"Pedido"
		@ 090,085 SAY STR0021  SIZE  35, 9  //"Qtd.PEndente"
		@ 089,032 GET _cPedido SIZE  40, 9  Valid(Busca(2))
		@ 089,125 GET _nQuant  Picture "@E 999,999.99" SIZE 40, 9
		
		DlgRefresh(oEstoque)
		Return(.T.)
	Else
		MsgBox(STR0022)    //'Produto nao encontrado !'
	EndIf
ElseIf _nTipo = 2 .And. !Empty(_cPedido)
	If Posicione('SC9',3,xFilial('SC9')+_cPedido+SB1->B1_GRUPO+_cCodPro,'C9_PRODUTO')  <> " "
		_nQuant := 0
		While SC9->(! Eof()) .AND. SC9->C9_FILIAL == xFilial('SC9') .AND. SC9->C9_PEDIDO == _cPedido .AND. SC9->C9_PRODUTO == _cCodPro
			If SC9->C9_BLEST <> '02'
				SC9->(DbSkip())
				Loop
			EndIf
			_nQuant += SC9->C9_QTDLIB
			SC9->(DbSkip())
		End  
		If _nQuant = 0
			MsgBox(STR0023)    //'Produto nao esta pEndente para esse Pedido !'
			Return(.F.)
		Else
			Return(.T.)
		EndIf
	Else
		MsgBox(STR0024)    //'Pedido nao encontrado !'
	EndIf
EndIf
Return(.F.)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณAtualiza  บAutor  ณEwerton Carlos Tomazบ Data ณ  13/01/02   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP7                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

Static Function Atualiza()
If Empty(_cCliente)
	MsgStop(STR0025) //'Informe o Cliente de Contrato, para remanejar a quantidade !'
	Return(.T.)
EndIf
_cX := Posicione('LH5',4,xFilial('LH5')+SubStr(_cCliente,1,6)+_cCodPro,'LH5_PRODUT')
_cX := Posicione('SC5',1,xFilial('SC5')+_cPedido,'C5_NUM')
_cX := Posicione('SC6',2,xFilial('SC6')+_cCodPro+_cPedido,'C6_NUM')
_cX := Posicione('SC9',1,xFilial('SC9')+SC6->C6_NUM+SC6->C6_ITEM,'C9_PEDIDO')
_nSC9Pen := 0
_nSC9Lib := 0
_nSequen := 0
_cLibPre := ''
If !MsgYesNo(STR0026+Alltrim(SC9->C9_PEDIDO)+STR0027+SC9->C9_ITEM+' ?') //'Confirma a Atualizacao do pedido '###' item '
	Return(.T.)
EndIf
DbSelectArea('SC9')
While SC9->(! Eof()) .AND. SC9->C9_FILIAL == xFilial("SC9") .AND. SC9->C9_PEDIDO == SC6->C6_NUM .AND.;
      SC9->C9_PRODUTO == SC6->C6_PRODUTO .AND. SC9->C9_LOCAL == SC6->C6_LOCAL
	If !Empty(SC9->C9_NFISCAL)
		DbSkip()
		_nSequen++
		Loop
	EndIf
	If Empty(SC9->C9_BLEST) .And. _nQuant > 0
		_nSC9Lib  += SC9->C9_QTDLIB
		_cLibPre  := SC9->C9_BLPRE
		RecLock('SC9',.F.)
		SC9->C9_BLINF   := Upper(Rtrim(cUserName))+" "+dtoc(date())+" "+time()+" h"
		MsUnLock()
		A460Estorna()
	EndIf
	If SC9->C9_BLEST = '02' .And. _nQuant > 0
		_nSC9Pen  += SC9->C9_QTDLIB
		_cLibPre  := SC9->C9_BLPRE
		RecLock('SC9',.F.)
		SC9->C9_BLINF   := Upper(Rtrim(cUserName))+" "+dtoc(date())+" "+time()+" h"
		MsUnLock()
		A460Estorna()
	EndIf
	DbSkip()
End  

If _nSC9Pen > 0 .And. _nQuant > 0
	
	If _nQuant+_nSC9Lib > 0
		MaLibDoFat(SC6->(Recno()),_nQuant+_nSC9Lib,.T.,.T.,.F.,.T.,.T.,.F.) //,{SC6->C6_LOCAL})
	EndIf
	If _nSC9Pen-_nQuant > 0
		MaLibDoFat(SC6->(Recno()),_nSC9Pen-_nQuant,.T.,.F.,.F.,.F.,.F.,.F.) //,{SC6->C6_LOCAL})
	EndIf
	
	DBSelectArea("LH5")
	RecLock('LH5',.F.)
	LH5->LH5_QTDREA -= _nQuant
	LH5->LH5_QTDSAL  -= _nQuant
	MsUnLock()
	
	MsgBox(STR0028,STR0029,'INFO') //'Operacao Concluida !'###'Remanejamento'
	Close(oEstoque)
Else
	MsgStop(STR0030) //'Informe a Quantidade a Remanejar!'
EndIf
Return(.T.)