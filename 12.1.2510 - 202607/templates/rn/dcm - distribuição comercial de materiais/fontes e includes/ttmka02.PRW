#INCLUDE "ttmka02.ch"
#INCLUDE "rwmake.ch"
#INCLUDE "TOPCONN.CH"

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณTTMKA02   บ Autor ณ EWERTON C TOMAZ    บ Data ณ  18/12/02   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ MarkBrowse com filtro dos clientes                         บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP5 IDE                                                    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/

Template Function TTMKA02(_cCli)

CHKTEMPLATE("DCM")  

If  Alltrim(_cCli)+" " <> '1 ' .And. Alltrim(_cCli)+" " <> '2 ' .And. !lProspect 
	_aArea := GetArea()
	If !Empty(SU7->U7_CODVEN)
		M->UA_VEND := SU7->U7_CODVEN
	EndIf
	SA1->(DbSeek(xFilial("SA1")+_cCli))
	If !ChecaVend(M->UA_VEND) .And. !ChecaVend2(M->UA_VEND)
		_cCliente  := ''
		M->UA_LOJA := ''
	Else
		_cCliente := If(!TkCliente(),'',_cCli)
	EndIf
	M->UA_LOJA := SA1->A1_LOJA
	T_TMKCLI()
	RestArea(_aArea)
	Return(_cCliente)
ElseIf Alltrim(_cCli) = '2'
	_aArea := GetArea()
	lProspect := .T.	
	RestArea(_aArea)
	Return(M->UA_CLIENTE)
Else
	_aArea := GetArea()
	_nTipoCar := If(IsAlpha(_cCli),2,1)
EndIf
_cCliente := Alltrim(_cCli)

Private cCadastro :=STR0004 //"Clientes do Vendedor"
Private cQueryCad := ""
Private aFields   := {}
Private cArq      := ""
Private _nCount   := 0  
Private _cCampos  := If(Upper(cUserName) $ Alltrim(SuperGetMv('MV_USUCANT')),;
                        "A1_VEND,A1_COD,A1_LOJA,A1_NOME,A1_CONTATO,A1_TEL,A1_MUN,A1_CGC,A1_END,A1_ULTCOM,A1_ULTVIS,A1_ULTCOT,A1_VENCCLI",;
                        "A1_COD,A1_LOJA,A1_NOME,A1_CONTATO,A1_TEL,A1_MUN,A1_CGC,A1_END,A1_ULTCOM,A1_ULTVIS,A1_ULTCOT,A1_VENCCLI")                        

_nOrdA1 := SA1->(IndexOrd())

aCamposMB := {}
DbSelectArea('SX3')
DbSetOrder(1)
DbSeek('SA1')
While !Eof() .And. X3_ARQUIVO = 'SA1'
	If ALLTRIM(X3_CAMPO) $ _cCampos .And. X3_CAMPO <> 'A1_CONTA  ' 
		AADD(aCamposMB,{Alltrim(X3_TITULO),Alltrim(X3_CAMPO),Alltrim(X3_TIPO),X3_TAMANHO,X3_DECIMAL,Alltrim(X3_PICTURE)})
	Endif
	DbSkip()
End  
AAdd(aCamposMB,{'Ult.Cotacao','A1_ULTCOT','D',8,0,''})

Cria_TRBA1()

DbSelectArea('TRBA1')

Processa({|| Monta_TRBA1() } ,STR0005) //"Selecionando Informacoes dos Clientes..."

aRotinaOld := aRotina

aRotina := MenuDef()

aCores := {{ ' (dDatabase-A1_ULTCOM > 90)',                                                                 'BR_VERMELHO'},;
           { '!(dDatabase-A1_ULTCOM > 90).And.(dDatabase-A1_ULTCOT > 60)',                                  'BR_AMARELO'},;
           { '!(dDatabase-A1_ULTCOM > 90).And.!(dDatabase-A1_ULTCOT > 60).And.(dDatabase-A1_ULTVIS > 30)',  'BR_AZUL'},;
           { '!(dDatabase-A1_ULTCOM > 90).And.!(dDatabase-A1_ULTCOT > 60).And.!(dDatabase-A1_ULTVIS > 30)', 'BR_VERDE'}}
_lInclui := INCLUI
mBrowse( 2,2,22,75,"TRBA1",aCamposMB,,,,,aCores)

M->UA_CLIENTE := TRBA1->A1_COD
M->UA_LOJA    := TRBA1->A1_LOJA
M->UA_DESCCLI := TRBA1->A1_NOME

DbSelectArea("TRBA1")
DbCloseArea()
FErase(cArq+OrdBagExt())
DbSelectArea('SA1')
DbClearFil()
RetIndex('SA1')
DbSetOrder(_nOrdA1)

If !Empty(M->UA_CLIENTE)
	TkCliente()
EndIf

T_TMKCLI()

INCLUI := _lInclui
aRotina := aRotinaOld

RestArea(_aArea)

Return(M->UA_CLIENTE)

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
ฑฑณ Uso      ณ TTMKA02                                                    ณฑฑ
ฑฑภฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤูฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/
Static Function MenuDef()
Local aRotina := {{STR0006, 'T_PesqSA1()', 0, 2, 0, .F.},;	//"Pesquisa"
             	    {STR0007, 'T_VeLegenda()', 0, 2, 0, .T.}}	//"Legenda"
Return(aRotina)  

// Funcoes Auxiliares pois na apresentacao do menu nao se pode passar parametro
Template Function PesqSA1()	; T_Pesq("SA1")		; Return(.T.)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณVeLegenda บ Autor ณ Vendas Clientes    บ Data ณ  18/12/02   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ 									                          บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ TPL DCM                                                    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/
Template Function VeLegenda()

CHKTEMPLATE("DCM")  

aCorDesc := {{'ENABLE'     ,'Em condicoes normais'},;
             {'BR_VERMELHO','Sem vendas a mais de 90 dias' },;
             {'BR_AMARELO' ,'Sem cotacao a mais de 60 dias'},;
             {'BR_AZUL'    ,'Sem contato a mais de 30 dias'}}
BrwLegenda( STR0007, STR0008, aCorDesc ) //"Legenda"###"Status"
Return( .T. )
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณPesq      บAutor  ณMicrosiga           บ Data ณ  10/27/05   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Template DCM                                               บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Template Function Pesq(cTipCad)

CHKTEMPLATE("DCM")  

_cPesqRaz := Space(40)
_cPesqCgc := Space(14)
@ 220,005 TO 320,226 DIALOG oDlgPesC TITLE 'Pesquisa Cliente'
@ 003,002 SAY 'Razao'
@ 002,020 GET _cPesqRaz   SIZE 89,15 PICTURE "@!" VALID IIf(cTipCad='SA1',PesquiNom(_cPesqRaz),PesquiNomUS(_cPesqRaz))
@ 018,002 SAY 'CNPJ'
@ 017,020 GET _cPesqCgc   SIZE 89,15 PICTURE "@!" VALID IIf(cTipCad='SA1',PesquiNom(_cPesqCGC),PesquiNomUS(_cPesqCGC))
@ 030,038 BUTTON "_Ok" SIZE 40,15 ACTION Close(oDlgPesC)
ACTIVATE DIALOG oDlgPesC CENTERED
Return(.T.)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณPesquiNom บAutor  ณMicrosiga           บ Data ณ  10/27/05   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Template DCM                                               บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/       

Static Function PesquiNom(_cPesq)
If !Empty(_cPesq)
	If Len(_cPesq) = 40
		DbSelectArea('TRBA1')
		If DbSeek(Rtrim(_cPesq))
			Close(oDlgPesC)
			SysRefresh()
		Else
			MsgBox(STR0009+Chr(13)+; //"Razao Social Nao Encontrado!"
			STR0010) //"Procure pelo CNPJ."
			_cPesqRaz := Space(40)
			DbSelectArea('TRBA1')
			DbGoTop()
		EndIf
	Else
		DbSelectArea('SA1')
		DbSetOrder(3)
		If DbSeek(xFilial('SA1')+_cPesq)
			DbSelectArea('TRBA1')
			If DbSeek(Rtrim(SA1->A1_NOME))
				Close(oDlgPesC)
				SysRefresh()
			Else
				If SU7->U7_CODVEN <> SA1->A1_VEND .And.;
					SA1->A1_VEND <> SuperGetMv('MV_VENDLIS') .And.;
					!(Upper(cUserName) $ Alltrim(SuperGetMv('MV_USUCANT')))
					MsgBox(SA1->A1_NOME+Chr(13)+;
					STR0011+Chr(13)+; //"Cliente Pertence ao Vendedor:"
					SA1->A1_VEND+" - "+Posicione('SA3',1,xFilial('SA3')+SA1->A1_VEND,'A3_NOME'),'Pesquisa','INFO')
					DbSelectArea('TRBA1')
					DbGoTop()
				ElseIf SA1->A1_VEND = SuperGetMv('MV_VENDLIS')
					If MsgBox(SA1->A1_NOME+Chr(13)+;
						'Cliente Inativo!'+Chr(13)+;
						'Deseja Transferir para sua Lista?','Pesquisa','YESNO')
						PegaCliente(2)
						DbSelectArea('SA1')
						DbSetOrder(3)
						DbSeek(xFilial('SA1')+_cPesq)
						DbSelectArea('TRBA1')
						DbSeek(Rtrim(SA1->A1_NOME))
						Close(oDlgPesC)
						SysRefresh()
					EndIf
				EndIf
			EndIf
		Else
			MsgBox("CNPJ Nao Encontrado!")
			DbSelectArea('TRBA1')
			DbGoTop()
		EndIf
	EndIf
EndIf
Return(.T.)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณPesquiNomUS บAutor  ณMicrosiga           บ Data ณ  10/27/05   บฑฑ
ฑฑฬออออออออออุออออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                              บฑฑ
ฑฑบ          ณ                                                              บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Template DCM                                                 บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

Static Function PesquiNomUS(_cPesq)
If !Empty(_cPesq)
	If Len(_cPesq) = 40
		DbSelectArea('TUS')
		If DbSeek(Rtrim(_cPesq))
			Close(oDlgPesC)
			SysRefresh()
		Else
			MsgBox(STR0009+Chr(13)+; //"Razao Social Nao Encontrado!"
			STR0010) //"Procure pelo CNPJ."
			_cPesqRaz := Space(40)
			DbSelectArea('TUS')
			DbGoTop()
		Endif
	Else
		DbSelectArea('SUS')
		DbSetOrder(4)
		If DbSeek(xFilial('SUS')+_cPesq)
			DbSelectArea('TUS')
			If DbSeek(Rtrim(SUS->US_NOME))
				Close(oDlgPesC)
				SysRefresh()
			Else
				If SU7->U7_CODVEN <> SUS->US_VEND .And.;
					!(Upper(cUserName) $ Alltrim(SuperGetMv('MV_USUCANT')))
					MsgBox(SUS->US_NOME+Chr(13)+;
					STR0012+Chr(13)+; //"Prospect Pertence ao Vendedor:"
					SUS->US_VEND+" - "+Posicione('SA3',1,xFilial('SA3')+SUS->US_VEND,'A3_NOME'),'Pesquisa','INFO')
					DbSelectArea('TUS')
					DbGoTop()
				EndIf
			EndIf
		Else
			MsgBox(STR0013) //"CNPJ Nao Encontrado!"
			DbSelectArea('TUS')
			DbGoTop()
		EndIf
	EndIf
EndIf
Return(.T.)


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณCria_TRBA1  บAutor  ณMicrosiga           บ Data ณ  10/27/05   บฑฑ
ฑฑฬออออออออออุออออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                              บฑฑ
ฑฑบ          ณ                                                              บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Template DCM                                                 บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

Static Function Cria_TRBA1()

DbSelectArea('SX3')
DbSetOrder(1)
DbSeek('SA1')
aFields := {}
While !Eof() .And. X3_ARQUIVO == 'SA1'
	If ALLTRIM(X3_CAMPO) $ _cCampos .And. X3_CAMPO <> 'A1_CONTA  '
		AADD(aFields,{X3_CAMPO,X3_TIPO,X3_TAMANHO,X3_DECIMAL})
	EndIf
	DbSkip()
End  
AADD(aFields,{'A1_ULTCOT','D',8,0})
cArq:=Criatrab(aFields,.T.)
DBUSEAREA(.t.,,cArq,"TRBA1")

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณCria_TUS    บAutor  ณMicrosiga           บ Data ณ  10/27/05   บฑฑ
ฑฑฬออออออออออุออออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                              บฑฑ
ฑฑบ          ณ                                                              บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Template DCM                                                 บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

Static Function Cria_TUS()

DbSelectArea('SX3')
DbSetOrder(1)
DbSeek('SUS')
aFields := {}
While !Eof() .And. X3_ARQUIVO == 'SUS'
	If ALLTRIM(X3_CAMPO) $ _cCampos
		AADD(aFields,{X3_CAMPO,X3_TIPO,X3_TAMANHO,X3_DECIMAL})
	Endif
	DbSkip()
End  
cArq:=Criatrab(aFields,.T.)
DBUSEAREA(.t.,,cArq,"TUS")
Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณMonta_TRBA1 บAutor  ณMicrosiga           บ Data ณ  10/27/05   บฑฑ
ฑฑฬออออออออออุออออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                              บฑฑ
ฑฑบ          ณ                                                              บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Template DCM                                                 บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

Static Function Monta_TRBA1()
Local _lExibeTudo := .T.
Local _nX

/*
Retirado o filtro de apenas 10 clientes porque o comando TOP nao funciona em todos os bancos

If Upper(cUserName) $ Alltrim(SuperGetMv('MV_USUCANT'))
	If !MsgBox('Confirma a Exibi็ใo de todos os Clientes?','Filtro de Clientes','YESNO')
		_lExibeTudo := .F.	
	Endif
Endif
*/
DbSelectArea('SU7')
DbSetOrder(1)
DbSeek(xFilial('SU7')+M->UA_OPERADO)

For _nX := 1 To 2
	If _nX = 1
		cQueryCad := "SELECT Count(*) AS TOTAL FROM "+RetSqlName('SA1')+"  WHERE "
	Else
		If Upper(cUserName) $ Alltrim(SuperGetMv('MV_USUCANT'))
			cQueryCad := "SELECT "+("")+" A1_VEND, A1_COD, A1_LOJA, A1_NOME, A1_ULTCOM, A1_ULTVIS, A1_VENCCLI, "
		Else
			cQueryCad := "SELECT "+("")+" A1_COD, A1_LOJA, A1_NOME, A1_ULTCOM, A1_ULTVIS, A1_VENCCLI, "
		Endif
		cQueryCad += " ('') AS A1_ULTCOT, A1_TEL, A1_CONTATO, A1_MUN, A1_END, A1_VEND, A1_CGC FROM "+RetSqlName('SA1')+"  WHERE "
	EndIf
	cQueryCad += RetSqlName('SA1')+".D_E_L_E_T_ <> '*' AND "
	cQueryCad += RetSqlName('SA1')+".A1_FILIAL  = '"+xFilial('SA1')+"' "	
	If !Empty(SU7->U7_CODVEN) .And.;
		!(Upper(cUserName) $ Alltrim(SuperGetMv('MV_USUCANT')))
		cQueryCad += " AND A1_VEND = '"+SU7->U7_CODVEN+"' "
	ElseIf Upper(cUserName) $ Alltrim(SuperGetMv('MV_USUCANT'))
		cQueryCad += " AND A1_VEND <> '"+SuperGetMv("MV_VENDLIS")+"' "
	End
	If _nTipoCar = 2
		cQueryCad += " AND A1_NOME LIKE '"+_cCliente+"%' "
	EndIf
	If _lExibeTudo .Or. (!_lExibeTudo .And. _nX = 2)
	
	
		cQueryCad := ChangeQuery(cQueryCad)
	
		TCQUERY cQueryCad NEW ALIAS "CAD"
	EndIf
	If _lExibeTudo .And. _nX = 1
		_nCount := CAD->TOTAL
		DbCloseArea()
	ElseIf _nX = 1
		_nCount := 10
	EndIf
Next

TcSetField("CAD","A1_ULTCOM","D")
TcSetField("CAD","A1_ULTVIS","D")
TcSetField("CAD","A1_ULTCOT","D")
TcSetField("CAD","A1_VENCCLI","D")

Dbselectarea("CAD")
DbGoTop()
ProcRegua(_nCount)

While CAD->(!EOF())
	IncProc()
	RecLock('TRBA1',.T.)
	
	For _nX := 1 To Len(aFields)
		If aFields[_nX,2] = 'C'
			_cX := 'TRBA1->'+aFields[_nX,1]+' := Alltrim(CAD->'+aFields[_nX,1]+')'
		Else
			If aFields[_nX,1] == 'A1_ULTCOT'
				_cX := 'TRBA1->'+aFields[_nX,1]+' := StoD(BuscaDTEMI(CAD->A1_COD)) ' //busca data do ultimo atendimento
			Else
				_cX := 'TRBA1->'+aFields[_nX,1]+' := CAD->'+aFields[_nX,1]
			EndIf
		EndIf
		_cX := &_cX
	Next
	MsUnLock()
	CAD->(Dbskip())
End  
Dbselectarea("CAD")
DbCloseArea()
Dbselectarea('TRBA1')
DbGoTop()
_cIndex:=Criatrab(Nil,.F.)
_cChave:="A1_NOME"
Indregua('TRBA1',_cIndex,_cChave,,,STR0014) //"Ordenando registros selecionados..."
DbSetIndex(_cIndex+ordbagext())
Dbselectarea('TRBA1')
SysRefresh()
Return


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณBuscaDTEMI  บAutor  ณMicrosiga           บ Data ณ  11/06/2012 บฑฑ
ฑฑฬออออออออออุออออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                              บฑฑ
ฑฑบ          ณ                                                              บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Template DCM                                                 บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function BuscaDTEMI(cCodCli)
Local cQuery := ''
Local cRet

cQuery := "SELECT ISNULL(UA_EMISSAO,' ') AS ULTEMI FROM "+RetSqlName('SUA')+"  WHERE UA_CLIENTE = '" + cCodCli + "' AND "+RetSqlName('SUA')+".D_E_L_E_T_ <> '*'  ORDER BY  UA_EMISSAO DESC"

cQuery := ChangeQuery(cQuery)
TCQUERY cQuery NEW ALIAS "DTEMI"

Dbselectarea("DTEMI")
DbGoTop()

cRet := DTEMI->ULTEMI

DTEMI->(DbCloseArea())

Return cRet


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณMonta_TUS   บAutor  ณMicrosiga           บ Data ณ  10/27/05   บฑฑ
ฑฑฬออออออออออุออออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                              บฑฑ
ฑฑบ          ณ                                                              บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Template DCM                                                 บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

Static Function Monta_TUS()
Local _nX

DbSelectArea('SU7')
DbSetOrder(1)
DbSeek(xFilial('SU7')+M->UA_OPERADO)

For _nX := 1 To 2
	If _nX = 1
		cQueryCad := "SELECT Count(*) AS TOTAL FROM "+RetSqlName('SUS')+"  WHERE "
	Else
		cQueryCad := "SELECT "+_cCampos
		cQueryCad += " FROM "+RetSqlName('SUS')+"  WHERE "
	EndIf
	cQueryCad += RetSqlName('SUS')+".D_E_L_E_T_ <> '*' AND "
	cQueryCad += RetSqlName('SUS')+".US_FILIAL  = '"+xFilial('SUS')+"' "	
	If !Empty(SU7->U7_CODVEN) .And.;
		!(Upper(cUserName) $ Alltrim(SuperGetMv('MV_USUCANT')))
		cQueryCad += " AND US_VEND = '"+SU7->U7_CODVEN+"' "
	ElseIf Upper(cUserName) $ Alltrim(SuperGetMv('MV_USUCANT'))
		cQueryCad += " AND US_VEND <> '"+ SuperGetMv("MV_VENDLIS")+"' "
	End
	TCQUERY cQueryCad NEW ALIAS "CAD"
	If _nX = 1
		_nCount := CAD->TOTAL
		DbCloseArea()
	EndIf
Next

Dbselectarea("CAD")
DbGoTop()
ProcRegua(_nCount)

While CAD->(!EOF())
	IncProc()
	RecLock('TUS',.T.)
	For _nX := 1 To Len(aFields)
		If aFields[_nX,2] = 'C'
			_cX := 'TUS->'+aFields[_nX,1]+' := Alltrim(CAD->'+aFields[_nX,1]+')'
		Else
			_cX := 'TUS->'+aFields[_nX,1]+' := CAD->'+aFields[_nX,1]
		EndIf
		_cX := &_cX
	Next
	MsUnLock()
	CAD->(DbSkip())
End  
Dbselectarea("CAD")
DbCloseArea()
DbSelectArea('TUS')
DbGoTop()
_cIndex:=Criatrab(Nil,.F.)
_cChave:="US_NOME"
Indregua('TUS',_cIndex,_cChave,,,STR0014) //"Ordenando registros selecionados..."
DbSetIndex(_cIndex+ordbagext())

SysRefresh()
Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณListaGer    บAutor  ณMicrosiga           บ Data ณ  10/27/05   บฑฑ
ฑฑฬออออออออออุออออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                              บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Template DCM                                                 บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

Template Function ListaGer()
Local _nX
                 
CHKTEMPLATE("DCM")  

Private cCadastroG :=STR0015 //"Lista Geral de Clientes"
Private cQueryCadG := ""
Private aFieldsG   := {}
Private cArqG      := ""
Private _cCamposG  := "A1_COD, A1_LOJA, A1_NOME, A1_CONTATO,A1_TEL,A1_MUN, A1_END,  A1_ULTCOM, A1_CGC"

@ 120,005 TO 480,750 DIALOG oDlgCliG TITLE cCadastroG
aCamposG := {}
DbSelectArea('SX3')
DbSetOrder(1)
DbSeek('SA1')
While !Eof() .And. X3_ARQUIVO = 'SA1'
	If ALLTRIM(X3_CAMPO) $ _cCamposG .And. X3_CAMPO <> 'A1_CONTA  '
		AADD(aCamposG,{StrZero(AT(ALLTRIM(X3_CAMPO),_cCamposG),3,0),Alltrim(X3_CAMPO),Alltrim(X3_TITULO),X3_PICTURE,X3_TAMANHO,X3_DECIMAL})
	EndIf
	DbSkip()
End 
ASort(aCamposG,,,{|x,y|x[1]<y[1]})

aCampos2G := {}
For _nX := 1 To Len(aCamposG)
	AADD(aCampos2G,{aCamposG[_nX,2],aCamposG[_nX,3],aCamposG[_nX,4],aCamposG[_nX,5],aCamposG[_nX,6]})
Next
aCamposG := {}
aCamposG := aCampos2G
_cPesRaz := Space(40)
_cPesCnpj:= Space(14)
DbSelectArea('SA1')
Monta_ListaGer()
DbSelectArea('SA1')

@ 006,005 TO 170,325 BROWSE "SA1" FIELDS aCamposG OBJECT oBrowLista
@ 006,330 BUTTON STR0016         SIZE 40,15 ACTION PegaCliente(1) //"Pega Cliente"
@ 143,330 BUTTON STR0017         SIZE 40,15 ACTION Close(oDlgCliG) //"_Fechar"
@ 026,328 SAY STR0018 //"Pesquisa Razao"
@ 036,328 GET _cPesRaz    Valid Pesquisa(1) SIZE 40,10
@ 046,328 SAY STR0019 //"Pesquisa CNPJ"
@ 056,328 GET _cPesCnpj   Valid Pesquisa(2) SIZE 40,10 When (Empty(_cPesRaz))
ACTIVATE DIALOG oDlgCliG CENTERED

RetIndex('SA1')

Return(.T.)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณPesquisa    บAutor  ณMicrosiga           บ Data ณ  10/27/05   บฑฑ
ฑฑฬออออออออออุออออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                              บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Template DCM                                                 บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

Static Function Pesquisa(_nTipo)
If Empty(_cPesRaz) .And. Empty(_cPesCnpj)
	Monta_ListaGer()
	Return(.T.)
EndIf
DbSelectArea('SA1')
If _nTipo = 1
	_cFiltro := 'A1_VEND="'+ SuperGetMv('MV_VENDLIS')+'"'
	IndRegua('SA1',criatrab(,.f.),"A1_FILIAL+A1_NOME",,_cFiltro,'Selecionando registros')
	If !DbSeek(xFilial('SA1')+Rtrim(_cPesRaz))
		MsgStop('Cliente nao Encontrado! (Razao Social)')
	Else
		oBrowLista:oBrowse:Refresh()
		DlgRefresh(oDlgCliG)
		SysRefresh()
	EndIf
ElseIf _nTipo = 2
	_cFiltro := 'A1_VEND="'+ SuperGetMv('MV_VENDLIS')+'"'
	IndRegua('SA1',criatrab(,.f.),"A1_FILIAL+A1_CGC",,_cFiltro,'Selecionando registros')
	If !DbSeek(xFilial('SA1')+Rtrim(_cPesCnpj))
		MsgStop('Cliente nao Encontrado! (CNPJ)')
	Else
		oBrowLista:oBrowse:Refresh()
		DlgRefresh(oDlgCliG)
		SysRefresh()
	EndIf
EndIf
Return(.T.)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณPegaCliente บAutor  ณMicrosiga           บ Data ณ  10/27/05   บฑฑ
ฑฑฬออออออออออุออออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                              บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Template DCM                                                 บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

Static Function PegaCliente(_nTipo)
DbSelectArea('SU7')
DbSetOrder(1)
DbSeek(xFilial('SU7')+M->UA_OPERADO)

If SA1->A1_VENDANT = SU7->U7_CODVEN
	MsgStop('Nao e possivel pegar este cliente!'+Chr(13)+;
	'Porque foi seu anteriormente e apos'+Chr(13)+;
	'vencer o prazo voltou a lista geral.')
	Return
Endif

If _nTipo = 1
	Close(oDlgCliG)
Endif

DbSelectArea('SA1')
RecLock('SA1',.F.)
SA1->A1_VEND    := SU7->U7_CODVEN
MsUnLock()

DbSelectArea("TRBA1")
DbCloseArea()
FErase(cArq+OrdBagExt())
Cria_TRBA1()
Processa({|| Monta_TRBA1() } ,STR0005) //"Selecionando Informacoes dos Clientes..."

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณMonta_ListaGer บAutor  ณMicrosiga           บ Data ณ  10/27/05   บฑฑ
ฑฑฬออออออออออุอออออออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                                 บฑฑ
ฑฑฬออออออออออุอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Template DCM 	                                               บฑฑ
ฑฑศออออออออออฯอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

Static Function Monta_ListaGer()
DbSelectArea("SA1")
_cFiltro := 'A1_VEND="'+ SuperGetMv('MV_VENDLIS')+'"'
IndRegua('SA1',criatrab(,.f.),"A1_FILIAL+A1_NOME",,_cFiltro,'Selecionando registros')
DbGoTop()
Return(.T.)


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณRelatorio      บAutor  ณMicrosiga           บ Data ณ  10/27/05   บฑฑ
ฑฑฬออออออออออุอออออออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                                 บฑฑ
ฑฑฬออออออออออุอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Template DCM 	                                               บฑฑ
ฑฑศออออออออออฯอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

Template Function Relatorio(_nCount)

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Declaracao de Variaveis                                             ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู

Local cDesc1         := STR0020 //"Este programa tem como objetivo imprimir relatorio "
Local cDesc2         := STR0021 //"de acordo com os parametros informados pelo usuario."
Local cDesc3         := STR0022 //"Situacao dos Clientes"
Local cPict          := ""
Local titulo       := STR0022 //"Situacao dos Clientes"
Local nLin         := 80

Local Cabec1       := STR0023 //"Codigo Nome                                     Contato         Telefone         Ult.Compra Ult.Cotacao Ult.Contato Venc.Cliente Sit"
//                     123456 1234567890123456789012345678901234567890 123456789012345 123456789012345  99/99/99   99/99/99    99/99/99    99/99/99
//                     012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901
//                               1         2         3         4         5         6         7         8         9         0         1         2         3
Local Cabec2       := ""
Local imprime      := .T.
Local aOrd := {}

CHKTEMPLATE("DCM")  

Private lEnd         := .F.
Private lAbortPrint  := .F.
Private limite           := 80
Private tamanho          := "M"
Private nomeprog         := "TMKA24"
Private nTipo            := 15
Private aReturn          := { STR0024, 1, STR0025, 2, 2, 1, "", 1} //"Zebrado"###"Administracao"
Private nLastKey        := 0
Private cPerg       := Padr("TMKA24",Len(SX1->X1_GRUPO))
Private cbtxt      := Space(10)
Private cbcont     := 00
Private CONTFL     := 01
Private m_pag      := 01
Private wnrel      := "TMKA24"

Private cString := "TRBA1"

DbSelectArea("TRBA1")
DbSetOrder(1)

Pergunte(cPerg,.F.)

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Monta a interface padrao com o usuario...                           ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู

Wnrel := SetPrint(cString,NomeProg,cPerg,@titulo,cDesc1,cDesc2,cDesc3,.F.,aOrd,.T.,Tamanho,,.F.)

If nLastKey == 27
	Return
EndIf

SetDeFault(aReturn,cString)

If nLastKey == 27
	Return
EndIf

nTipo := If(aReturn[4]==1,15,18)

RptStatus({|| RunReport(Cabec1,Cabec2,Titulo,nLin) },Titulo)
Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณRunReport      บAutor  ณMicrosiga           บ Data ณ  10/27/05   บฑฑ
ฑฑฬออออออออออุอออออออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                                 บฑฑ
ฑฑฬออออออออออุอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Template DCM 	                                               บฑฑ
ฑฑศออออออออออฯอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

Static Function RunReport(Cabec1,Cabec2,Titulo,nLin)

DbSelectArea(cString)
DbSetOrder(1)

SetRegua(_nCount)

DbGoTop()
While !EOF()
	IncRegua()
	_cSit := 0
	If MV_PAR01 <> 5
		If MV_PAR01 = 1 .And. !(dDatabase-A1_ULTCOM > 90)
			DbSkip()
			Loop
		ElseIf MV_PAR01 = 2 .And. !(!(dDatabase-A1_ULTCOM > 90).And.(dDatabase-A1_ULTCOT > 60))
			DbSkip()
			Loop
		ElseIf MV_PAR01 = 3 .And. !(!(dDatabase-A1_ULTCOM > 90).And.!(dDatabase-A1_ULTCOT > 60).And.(dDatabase-A1_ULTVIS > 30))
			DbSkip()
			Loop
		ElseIf MV_PAR01 = 4 .And. !(!(dDatabase-A1_ULTCOM > 90).And.!(dDatabase-A1_ULTCOT > 60).And.!(dDatabase-A1_ULTVIS > 30))
			DbSkip()
			Loop
		EndIf
	EndIf
	If (dDatabase-A1_ULTCOM > 90)
		_cSit := 1
	ElseIf (!(dDatabase-A1_ULTCOM > 90).And.(dDatabase-A1_ULTCOT > 60))
		_cSit := 2
	ElseIf (!(dDatabase-A1_ULTCOM > 90).And.!(dDatabase-A1_ULTCOT > 60).And.(dDatabase-A1_ULTVIS > 30))
		_cSit := 3
	ElseIf (!(dDatabase-A1_ULTCOM > 90).And.!(dDatabase-A1_ULTCOT > 60).And.!(dDatabase-A1_ULTVIS > 30))
		_cSit := 4
	Else
		_cSit := 5
	EndIf
	
	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณ Verifica o cancelamento pelo usuario...                             ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	
	If lAbortPrint
		@nLin,00 PSAY STR0026 //"*** CANCELADO PELO OPERADOR ***"
		Exit
	EndIf
	
	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณ Impressao do cabecalho do relatorio. . .                            ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	
	If nLin > 55 // Salto de Pแgina. Neste caso o formulario tem 55 linhas...
		Cabec(Titulo,Cabec1,Cabec2,NomeProg,Tamanho,nTipo)
		nLin := 8
	EndIf
	
	@nLin,000 PSAY TRBA1->A1_COD
	@nLin,007 PSAY TRBA1->A1_NOME
	@nLin,048 PSAY TRBA1->A1_CONTATO
	@nLin,064 PSAY TRBA1->A1_TEL
	@nLin,081 PSAY TRBA1->A1_ULTCOM
	@nLin,092 PSAY TRBA1->A1_ULTCOT
	@nLin,104 PSAY TRBA1->A1_ULTVIS
	@nLin,116 PSAY TRBA1->A1_VENCCLI
	@nLin,129 PSAY If(_cSit=1,'SVE',If(_cSit=2,'SCT',If(_cSit=3,'SCO',If(_cSit=4,'NOR',''))))
	
	nLin++
	
	DbSkip()
End  

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Finaliza a execucao do relatorio...                                 ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู

Set Device To Screen

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Se impressao em disco, chama o gerenciador de impressao...          ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู

If aReturn[5]==1
	
	Set Printer To
	OurSpool(Wnrel)
EndIf

MS_FLUSH()

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณChecaVend      บAutor  ณMicrosiga           บ Data ณ  10/27/05   บฑฑ
ฑฑฬออออออออออุอออออออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                                 บฑฑ
ฑฑฬออออออออออุอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Template DCM 	                                               บฑฑ
ฑฑศออออออออออฯอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

Static Function ChecaVend(cVendCli)
If (cVendCli <> SA1->A1_VEND) .And. !(Upper(cUserName) $ Alltrim(GetMv('MV_USUCANT')))
	If MsgBox('Cliente de Outro Vendedor!','Informa็ใo','INFO')
		M->UA_CLIENTE := Space(6)
		M->UA_LOJA    := Space(2)
		M->UA_DESCCLI := Space(40)
		Return(.F.)
	EndIf
EndIf
Return(.T.)

Static Function ChecaVend2(cVendCli)
If (cVendCli <> SUS->US_VEND) .And. !(Upper(cUserName) $ Alltrim(GetMv('MV_USUCANT')))
	If !MsgBox('Prospect de Outro Vendedor!','Informa็ใo','YESNO')
		M->UA_CLIENTE := Space(6)
		M->UA_LOJA    := Space(2)
		M->UA_DESCCLI := Space(40)
		Return(.F.)
	Endif
Endif
Return(.T.)


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณChecaVend      บAutor  ณMicrosiga           บ Data ณ  10/27/05   บฑฑ
ฑฑฬออออออออออุอออออออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                                 บฑฑ
ฑฑฬออออออออออุอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Template DCM 	                                               บฑฑ
ฑฑศออออออออออฯอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

Template Function FProspect()

CHKTEMPLATE("DCM")  

Private cCadastro :=STR0033 //"Prospects do Vendedor"
Private cQueryCad := ""
Private aFields   := {}
Private cArq      := ""
Private _nCount   := 0
Private _cCampos  := If(Upper(cUserName) $ Alltrim(SuperGetMv('MV_USUCANT')),;
                        "US_VEND,US_COD,US_LOJA,US_NOME,US_NREDUZ,US_TEL,US_END,US_MUN,US_CGC,US_EMAIL",;
                        "US_COD,US_LOJA,US_NOME,US_NREDUZ,US_TEL,US_END,US_MUN,US_CGC,US_EMAIL")

_cAlias := Alias()
_nOrdA1 := SUS->(IndexOrd())

aCamposMB := {}
DbSelectArea('SX3')
DbSetOrder(1)
DbSeek('SUS')
While !Eof() .And. X3_ARQUIVO = 'SUS'
	If ALLTRIM(X3_CAMPO) $ _cCampos
		AADD(aCamposMB,{Alltrim(X3_TITULO),Alltrim(X3_CAMPO)})
	EndIf
	DbSkip()
End

Cria_TUS()

DbSelectArea('TUS')

Processa({|| Monta_TUS() } ,STR0005) //"Selecionando Informacoes dos Clientes..."

aRotinaOld := aRotina

aRotina := MenuDef1() 

_lInclui := INCLUI
mBrowse( 6,1,22,75,"TUS",aCamposMB,,,,,)

M->UA_CLIENTE := TUS->US_COD
M->UA_LOJA    := TUS->US_LOJA
M->UA_DESCCLI := TUS->US_NOME
If !Empty(SU7->U7_CODVEN)
	M->UA_VEND    := SU7->U7_CODVEN
	M->UA_DESCVEN := SU7->U7_NOME
Endif
M->UA_PROSPEC := .T.

DbSelectArea("TUS")
DbCloseArea()
FErase(cArq+OrdBagExt())
DbSelectArea('SUS')
DbClearFil()
RetIndex('SUS')
DbSetOrder(_nOrdA1)
DbSelectArea(_cAlias)

INCLUI := _lInclui
aRotina := aRotinaOld

Return(M->UA_CLIENTE)

/*/
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑฺฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฟฑฑ
ฑฑณFun็ใo    ณ MenuDef1 ณ Autor ณ Conrado Q. Gomes      ณ Data ณ 11.12.06 ณฑฑ
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
                 
Static Function MenuDef1() 
Local := { {STR0006      ,'T_PesqSUS()' , 0, 2} } //"Pesquisa"
Return(aRotina)       

Template Function PesqSUS() ; T_Pesq("SUS")  ; Return(.T.)   
