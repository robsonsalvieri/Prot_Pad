#INCLUDE "rwmake.ch" 
#INCLUDE "TOPCONN.CH"
#INCLUDE "ttmkc01.CH"

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ PERF    ³ Autor ³ Ewerton C Tomaz        ³ Data ³ 01/12/00 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Ponto de Entrada em que trata a Consulta dos Produtos      ³±±
±±³            Botão Caracteristicas dos Produto                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ TMKVCA.PRW                                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Projeto Ewerton                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

Template Function TTMKC01(_cProd)

CHKTEMPLATE("DCM")  

Private _aAreaRest := GetArea()
Private _cProduto,cObs
Private oEstoque ,oObs
Private _nPEDVEN   := 0
Private _nEmp	   := 0
Private _nSalPedi  := 0
Private _nReserva  := 0
Private _nStok2	   := 0
Private _cBitPro   := "",oBitPro
Private _cLocal    := ""
Private _cPictSB2  := SPACE(12)
Private _cSLQPEDV  := GetNewPar("MV_SLQPEDV","N")
Private _aPrecosPro:= {}

DbSelectArea('SU7')
DbSetOrder(3)
If !DbSeek(xFilial('SU7') + cUserName )
	RestArea(_aAreaRest)
	MsgStop(STR0062) //"Usuario nao Encontrado como Operador!"
	Return(.F.)
EndIf

DbSelectArea('SU0')
DbSetOrder(1)
If !DbSeek(xFilial('SU0')+SU7->U7_POSTO)
	RestArea(_aAreaRest)
	MsgStop(STR0063) //"Grupo de Atendimento nao Encontrado!"
	Return(.F.)
Else
	If SU0->U0_TABMIN == 0 .Or. SU0->U0_TABMAX == 0
		RestArea(_aAreaRest)
		MsgStop(STR0064) //"Tabelas da Area nao definidas no Grupo de Atendimento!"
		Return(.F.)
	EndIf
EndIf

DbSelectarea( "SB2" )
If _cProd <> nil
	DbSetOrder(1)
	If !DbSeek(xFilial('SB2')+_cProd+If(!Empty(SU0->U0_LOCPAD),SU0->U0_LOCPAD,""))
		MsgStop(STR0065) //"Item sem Estoque Lancado!"
		RestArea(_aAreaRest)
		Return(.T.)
	EndIf
EndIf
_cProduto:=SB2->B2_COD
_cLocal  :=SB2->B2_LOCAL
_cObs    := ""
_nQtUM   := 1

DbSelectArea( "SB0" )
DbSetOrder(1)
If !DbSeek( xFilial("SB0") + _cProduto )
	MsgStop(STR0066) //"Item sem Preco Lancado! Contate Adminitrador de Materiais"
	RestArea(_aAreaRest)
	Return(.T.)
EndIf

DbSelectarea( "SB1" )
DbSetorder(1)
DbSeek( xFilial("SB1") + _cProduto + _cLocal)

DbSelectArea('LH7')
DbSetOrder(1)
If !DbSeek( xFilial("LH7") + _cProduto)
	MsgStop(STR0067) //"Item sem Politica de Precos Definida! Contate Adminitrador de Materiais"
	RestArea(_aAreaRest)
	Return(.T.)
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Mostra dados do Produto.					                 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

DEFINE MSDIALOG oEstoque FROM  000,000 TO 370,565 TITLE STR0003 PIXEL //"Caracteristicas"
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Dados das caracteristicas do produto                 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

@ 010,002 TO 105,200
@ 003,002    SAY STR0004      	   SIZE  56, 7 //"Dados do Produto"
@ 016,004    SAY STR0005     	   SIZE  21, 7 //"Codigo"
@ 015,029    GET SB1->B1_COD  	   SIZE  115, 9 When .F.
@ 016,148    SAY STR0007      	   SIZE  18, 7 //"Grupo"
@ 015,168    GET SB1->B1_GRUPO 	   SIZE  14, 9 When .F.
@ 031,004    SAY STR0008  	       SIZE  32, 7 //"Descricao"
@ 030,029    GET SB1->B1_DESC  	   SIZE 135, 9 When .F.
@ 046,004    SAY STR0009     	   SIZE  25, 7 //"Unidade"
@ 045,029    GET SB1->B1_UM   	   SIZE  14, 9 When .F.
@ 046,054    SAY STR0010      	   SIZE  25, 7 //"Fator 1"
@ 045,079    GET _nQtUM    	       SIZE  14, 9 When .F.
@ 046,103    SAY STR0011  	       SIZE  25, 7 //"Unidade 2"
@ 045,128    GET SB1->B1_SEGUM 	   SIZE  14, 9 When .F.
@ 046,153    SAY STR0012     	   SIZE  25, 7 //"Fator 2"
@ 045,178    GET SB1->B1_CONV 	   SIZE  14, 9 When .F.
@ 061,004    SAY STR0013    	   SIZE  25, 7 //"Unidade 3"
@ 060,029    GET SB1->B1_UM3 	   SIZE  14, 9 When .F.
@ 061,054    SAY STR0014           SIZE  25, 7 //"Fator 3"
@ 060,079    GET SB1->B1_UM3FAT	   SIZE  14, 9 When .F.
@ 061,103    SAY STR0015    	   SIZE  25, 7 //"Unidade 4"
@ 060,128    GET SB1->B1_UM4   	   SIZE  14, 9 When .F.
@ 061,153    SAY STR0016     	   SIZE  25, 7 //"Fator 4"
@ 060,178    GET SB1->B1_UM4FAT	   SIZE  14, 9 When .F.
@ 076,004    SAY STR0017  	       SIZE  21, 7 //"Fornec."
@ 075,029    GET SB1->B1_PROC	   SIZE  40, 9 When .F.
@ 076,079    SAY STR0018    	   SIZE  21, 7 //"Marca"
@ 075,103    GET SB1->B1_FABRIC	   SIZE  96, 9 When .F.
@ 091,004    SAY STR0019           SIZE  25, 7 //"EspecIf."
_cEspec1 := SubStr(SB1->B1_ESPECIf,1,40)
_cEspec2 := SubStr(SB1->B1_ESPECIf,41,40)
@ 85, 29   GET _cEspec1      	   SIZE  170, 9 When .F.
@ 94, 29   GET _cEspec2      	   SIZE  170, 9 When .F.

DEFINE SBUTTON FROM 167,253 TYPE 1 ACTION {||RestArea(_aAreaRest),(oEstoque:End())} ENABLE OF oEstoque

@ 010, 202  TO 105, 283
@ 003, 205  SAY STR0020    		 SIZE 100, 7 //"Estoque:"
@ 019, 205  BUTTON STR0021 		 SIZE 35,12 ACTION MsgInfo(STR0068 + CHR(13) + STR0091 ) //"Pendente" //"Quantidade Pendente'+Chr(13)+'Aguardando Liberacao de Estoque."
@ 033, 205  BUTTON STR0022		 SIZE 35,12 ACTION MsgInfo(STR0069) //"Quantidade Reservada para o Contratos."
@ 047, 205  BUTTON STR0023		 SIZE 35,12 ACTION MsgInfo(STR0070 + CHR(13) + STR0092 ) //"Quantidade do Item com Pedido de Compra em Aberto'+Chr(13)+'Aguardando Entrada de Nota."
@ 061, 205  BUTTON STR0024		 SIZE 35,12 ACTION MsgInfo(STR0071 + CHR(13) + STR0093 ) //"Quantidade Reservada com'+Chr(13)+'Pedidos em Aberto Aguardando Faturamento."
_nMix := T_BuscaSalCon('',SB2->B2_COD)
@ 075, 205  BUTTON STR0025	     SIZE 35,12 ACTION MsgInfo(STR0072 + Transform(SB2->B2_QATU,'@ER 9999999')+Chr(13)+; //"Quantidade Real em Estoque = "
                                                           STR0073+ Transform(SB2->B2_RESERVA,'@ER 9999999')+Chr(13)+; //"Quantidade Reservada = "
                                                           STR0074+ Transform(_nMix,'@ER 9999999')+Chr(13)+; //"Quantidade Saldo Contrato = "
                                                           STR0075 + Transform(SB2->B2_QATU-SB2->B2_RESERVA,'@ER 9999999')) //"Quantidade Real Disponivel (SEM CONT.) = "
@ 089, 205  BUTTON STR0057	  SIZE 35,12 ACTION MsgInfo(STR0076 + Chr(13)+; //"Quantidade Disponivel"
STR0077 +Chr(13)+; //"Para que o Pedido Aberto possa ser Liberado"
STR0078) //"Fora essa Quantidade o Pedido ficara Pendente."

DbSelectarea( "SB2" )
If Type('M->UA_CLIENTE') <> 'U'
	If T_BuscaSalCon(M->UA_CLIENTE,SB2->B2_COD) > 0
		_nMix    := T_BuscaSalCon(M->UA_CLIENTE,SB2->B2_COD)
		_nReserva:= T_BuscaResSC9(M->UA_CLIENTE,SB2->B2_COD)
		_nEmp    := _nMix + _nReserva
		_nDisp   := _nMix
		_nStok2  := _nMix + _nReserva
		_nPEDVEN :=(SB2->B2_QPEDVEN-SB2->B2_RESERVA)
	Else
		_nMix    := T_BuscaSalCon('',SB2->B2_COD)
		_nReserva:= SB2->B2_RESERVA
		_nEmp    := _nMix
		_nDisp   := SaldoMov() - _nMix
		_nStok2  := B2_QATU
		_nPEDVEN :=(SB2->B2_QPEDVEN-_nReserva)
	EndIf
Else
	_nMix    := T_BuscaSalCon('',SB2->B2_COD)
	_nReserva:= SB2->B2_RESERVA
	_nEmp    := _nMix
	_nDisp   := SaldoMov() - _nMix
	_nStok2  := B2_QATU
	_nPEDVEN :=(SB2->B2_QPEDVEN-_nReserva)
EndIf
_nSalPedi:=SB2->B2_SALPEDI

If ALLTRIM(_cSLQPEDV) == "S"
	_nDisp -= SB2->B2_QPEDVEN
EndIf

@ 019,240  GET  _nPEDVEN  Picture "@E 99999999" SIZE 40, 9 When .F.
@ 033,240  GET  _nEmp     Picture "@E 99999999" SIZE 40, 9 When .F.
@ 047,240  GET  _nSalPedi Picture "@E 99999999" SIZE 40, 9 When .F.
@ 061,240  GET  _nReserva Picture "@E 99999999" SIZE 40, 9 When .F.
@ 075,240  GET  _nStok2   Picture "@E 99999999" SIZE 40, 9 When .F.
@ 089,240  GET  _nDisp    Picture "@E 99999999" SIZE 40, 9 When .F.

_cPrecoMin := "SB0->B0_PRV"+Alltrim(Str(SU0->U0_TABMIN,2))
_cPrecoMin := &_cPrecoMin 
_cPrecoMax := "SB0->B0_PRV"+Alltrim(Str(SU0->U0_TABMAX,2))
_cPrecoMax := &_cPrecoMax
_nDescUM2  := Posicione('LH7',1,xFilial('LH7')+SB1->B1_COD,'LH7_DU2'+SU0->U0_CODIGO)
_nDescUM3  := Posicione('LH7',1,xFilial('LH7')+SB1->B1_COD,'LH7_DU3'+SU0->U0_CODIGO)
_cPrcMinU2 := (_cPrecoMin*SB1->B1_CONV)*(1-(_nDescUM2/100)) 
_cPrcMinU3 := (_cPrecoMin*SB1->B1_UM3FAT)*(1-(_nDescUM3/100)) 
_cPrcMinU4 := _cPrecoMin*SB1->B1_UM4FAT
_cPrcMaxU2 := (_cPrecoMax*SB1->B1_CONV)*(1-(_nDescUM2/100)) 
_cPrcMaxU3 := (_cPrecoMax*SB1->B1_UM3FAT)*(1-(_nDescUM3/100)) 
_cPrcMaxU4 := _cPrecoMax*SB1->B1_UM4FAT

_aPrecosPro := T_BuscaPrePro(SB1->B1_COD)

@ 112,002 TO 160,200
@ 112,202 TO 160,283
If FunName(0) <> "#TCOMA02" .And. FunName(0) <> "#TCOMA05"
	@ 105,202 SAY STR0027  SIZE 63, 7    // "Promocao:" 
	@ 105,003 SAY STR0028  SIZE 63, 7     //"Precos de Venda:"
	@ 105,102 SAY "UM2"    SIZE 11, 7
	@ 105,145 SAY "UM3"    SIZE 11, 7
	@ 105,188 SAY "UM4"    SIZE 11, 7
	@ 115,006 SAY "Max"    SIZE 11, 7
	@ 125,006 SAY "Min"    SIZE 11, 7
	@ 115,030 GET _cPrecoMax    Picture "@E 999,999.99" SIZE 40, 9  When .F.
	@ 125,030 GET _cPrecoMin    Picture "@E 999,999.99" SIZE 40, 9  When .F.
	If SB1->B1_CONV > 0
		@ 115,073 GET _cPrcMaxU2    Picture "@E 999,999.99" SIZE 40, 9  When .F.
		@ 125,073 GET _cPrcMinU2    Picture "@E 999,999.99" SIZE 40, 9  When .F.
	EndIf
	If SB1->B1_UM3FAT > 0	
		@ 115,116 GET _cPrcMaxU3    Picture "@E 999,999.99" SIZE 40, 9  When .F.
		@ 125,116 GET _cPrcMinU3    Picture "@E 999,999.99" SIZE 40, 9  When .F.
	EndIf
	If SB1->B1_UM4FAT > 0	
		@ 115,159 GET _cPrcMaxU4    Picture "@E 999,999.99" SIZE 40, 9  When .F.
		@ 125,159 GET _cPrcMinU4    Picture "@E 999,999.99" SIZE 40, 9  When .F.
	EndIf
	If Len(_aPrecosPro) > 0
		@ 115,205 SAY STR0079 SIZE 30,15 //"PROMOCAO"
		@ 125,205 BUTTON Alltrim(Str(_aPrecosPro[1],10,4)) SIZE 30,15 ACTION MsgBox(STR0080,STR0081,STR0082) //"Preco Promocional que Aparece como Prioridade na Tela de Vendas."###"Informacao"###"INFO"
		@ 140,205 SAY STR0083 + DTOC(_aPrecosPro[2]) SIZE 40,15 //"INICIO:"
		@ 150,205 SAY STR0084 + DTOC(_aPrecosPro[3]) SIZE 40,15 //"FINAL :"
		If !Empty(SB1->B1_SEGUM)
			@ 115,248 SAY SB1->B1_SEGUM+'/'+Alltrim(Str(SB1->B1_CONV,3)) SIZE 15,15
			@ 125,248 SAY Alltrim(Str((_aPrecosPro[1]*SB1->B1_CONV)*(1-(_nDescUM2/100)),10,4)) SIZE 30,15  
		EndIf
		If !Empty(SB1->B1_UM3)
			@ 135,248 SAY SB1->B1_UM3+'/'+Alltrim(Str(SB1->B1_UM3FAT,3)) SIZE 15,15
			@ 145,248 SAY Alltrim(Str((_aPrecosPro[1]*SB1->B1_UM3FAT)*(1-(_nDescUM3/100)),10,4)) SIZE 30,15  
		EndIf
	EndIf	
Else
	@ 115,003 SAY STR0034 SIZE 63, 7 //"Medias de Venda:"
	DbSelectArea('LFW')
	DbSetOrder(1)
	_cMes1 := Str(Val(Str(Year(dDatabase),4)+StrZero(Month(dDatabase),2))-1,6)
	If Val(SubStr(_cMes1,5,2)) == 0 
		_cMes1 := Str(Val(Str(Year(dDatabase)-1,4)+'12'),6)			
	EndIf
	_cMes2 := Str(Val(_cMes1)-1,6) 
	If Val(SubStr(_cMes2,5,2)) == 0 
		_cMes2 := Str(Val(Str(Val(SubStr(_cMes2,1,4))-1,4)+'12'),6)			
	EndIf
	_cMes3 := Str(Val(_cMes2)-1,6)
	If Val(SubStr(_cMes3,5,2)) == 0 
		_cMes3 := Str(Val(Str(Val(SubStr(_cMes3,1,4))-1,4)+'12'),6)			
	EndIf
	@ 115,092 SAY SubStr(_cMes1,1,4)+'/'+SubStr(_cMes1,5,2) SIZE 30, 10
	@ 115,135 SAY SubStr(_cMes2,1,4)+'/'+SubStr(_cMes2,5,2) SIZE 30, 10
	@ 115,178 SAY SubStr(_cMes3,1,4)+'/'+SubStr(_cMes3,5,2) SIZE 30, 10
	DbSeek(xFilial('LFW')+xFilial('SB2')+SB0->B0_COD+_cMes1)
	_nZLQtd1 := LFW->LFW_QUANT
	DbSeek(xFilial('LFW')+xFilial('SB2')+SB0->B0_COD+_cMes2)
	_nZLQtd2 := LFW->LFW_QUANT
	DbSeek(xFilial('LFW')+xFilial('SB2')+SB0->B0_COD+_cMes3)
	_nZLQtd3 := LFW->LFW_QUANT
	_nMedia  := (_nZLQtd1+_nZLQtd2+_nZLQtd3)/3
	@ 122,006 GET _nMedia    Picture "@E 999999" SIZE 40, 9  When .F.
	@ 122,048 SAY STR0035   SIZE 40, 9 //"3 Meses"
	@ 122,073 GET _nZLQtd1    Picture "@E 999999" SIZE 40, 9  When .F.
	@ 122,116 GET _nZLQtd2    Picture "@E 999999" SIZE 40, 9  When .F.
	@ 122,159 GET _nZLQtd3    Picture "@E 999999" SIZE 40, 9  When .F.
	DbSelectArea('SD1')
	DbSetOrder(7)
	If DbSeek(xFilial('SD1')+SB2->B2_COD+SB2->B2_LOCAL+DTOS(SB1->B1_UCOM))
		While SD1->(! Eof()) .AND. SD1->D1_FILIAL == xFilial('SD1') .AND. SD1->D1_COD == SB2->B2_COD .AND. DTOS(SD1->D1_EMISSAO) == DTOS(SB1->B1_UCOM)
			If Empty(SD1->D1_NFORI)
				Exit
			EndIf
			DbSkip()
		End  
		@ 129,2 TO 139,200
		@ 133,006  SAY STR0085+ DTOC(SB1->B1_UCOM) SIZE 100, 9 //"Ultima Compra: "
		@ 133,088  SAY STR0086 + Transf(SD1->D1_QUANT,"@E 999999") SIZE 40, 9 //"Qtde: "
		_cCond := Posicione('SF1',1,xFilial('SF1')+SD1->D1_DOC+SD1->D1_SERIE+SD1->D1_FORNECE+SD1->D1_LOJA,'F1_COND')
		_nUltCompra := SD1->D1_VUNIT + Round((SD1->D1_VUNIT * SD1->D1_IPI)/100,2)
		@ 133,131  SAY STR0087 + Transf(_nUltCompra,"@E 999,999.99") SIZE 40, 9 //"Preco: "
		@ 141,006  SAY STR0088 + Posicione('SE4',1,xFilial('SE4')+_cCond,'E4_DESCRI') SIZE 60, 9 //"Condicao: "
		@ 141,080  SAY STR0089 + SubStr(Posicione('SA2',1,xFilial('SA2')+SD1->D1_FORNECE+SD1->D1_LOJA,'A2_NOME'),1,30) SIZE 150, 9 //"Fornecedor: "
	Else
		If !Empty(SB1->B1_UCOM)
			@ 129,2 TO 140,200
			@ 133,006  SAY STR0085 + DTOC(SB1->B1_UCOM) SIZE 100, 9 //"Ultima Compra: "
			@ 133,131  SAY STR0087+ Transf(SB1->B1_UPRC,"@E 999,999.99") SIZE 40, 9 //"Preco: "
		Else
			@ 133,006  SAY STR0090 SIZE 200, 9 //"Nao existem referencias de compras para o produto."
		EndIf
	EndIf
	DbSelectarea( "SB2" )
EndIf
If FunName(0) $ "MATA121/#TCOMA02/#TCOMA05"
	_nPrcCus := LH7->LH7_VALREF
	_nPrcCus2:= _nPrcCus * SB1->B1_CONV
	_nPrcCus3:= _nPrcCus * SB1->B1_UM3FAT
	_nPrcCus4:= _nPrcCus * SB1->B1_UM4FAT
	@ 151,006  SAY STR0036                             SIZE 21, 7  // "Custo :"
	@ 149,025  GET _nPrcCus    Picture "@E 999,999.99" SIZE 40, 9  When .F.
	@ 149,068  GET _nPrcCus2   Picture "@E 999,999.99" SIZE 40, 9  When .F.
	@ 149,111  GET _nPrcCus3   Picture "@E 999,999.99" SIZE 40, 9  When .F.
	@ 149,154  GET _nPrcCus4   Picture "@E 999,999.99" SIZE 40, 9  When .F.
EndIf
@ 167,010 BUTTON STR0037		    SIZE 55,15 ACTION DETALHE()  //"Previsao Entrega"
@ 167,070 BUTTON STR0038	        SIZE 30,15 ACTION SIMILAR()  //"Similares" 
@ 167,105 BUTTON STR0039		    SIZE 30,15 ACTION ESTFIL()   //"Est.Filiais"
ACTIVATE MSDIALOG oEstoque CENTER

RestArea(_aAreaRest)

Return(.T.)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ DETALHE ³ Autor ³ Ewerton C Tomaz        ³ Data ³ 01/12/00 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Projeto Ewerton                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/        

Static Function DETALHE()
Private _aAliasDet :=GetArea()
private cPro       :=SB1->B1_COD
private _aArqSel   := {"SC7"}
private cArq       :=""
private cCampos    :="C7_NUM,C7_ITEM,C7_PRODUTO,C7_DESCRI,C7_QUANT,C7_QUJE,C7_AQUANT,C7_UM,C7_DATPRF,"
private aFields    :={}

cria_TC7()
Processa({|| monta_TC7()},STR0039 )     //"Selecionando registros..."

aTela :={}
aAdd(aTela,{"C7_NUM"    ,STR0041                  }) //"Pedido"
aAdd(aTela,{"C7_ITEM"   ,STR0042  ,"@E 99"        }) //"Item"
aAdd(aTela,{"C7_DESCRI" ,STR0008  ,"@!"           }) //"Descricao"
aAdd(aTela,{"C7_QUANT"  ,STR0043  ,"@E 999,999.99"}) //"Quantidade"
aAdd(aTela,{"C7_UM"     ,STR0009  ,"@!"           }) //"Unidade"
aAdd(aTela,{"C7_QUJE"   ,STR0044  ,"@E 999,999.99"}) //"Qt.Recebida"
aAdd(aTela,{"C7_AQUANT" ,STR0045  ,"@E 999,999.99"}) //"a Receber"
aAdd(aTela,{"C7_DATPRF" ,STR0046                  }) //"Dt.Previsao"
aAdd(aTela,{"C7_PRODUTO",STR0047                  }) //"Produto"

@ 000,000 To 220,700 Dialog oDlg2 Title STR0048 //"Detalhes da Previsao de Entrega"
@ 000,000 To 110,350 Browse "TC7" Fields aTela

Activate Dialog oDlg2 Center

DbSelectArea("TC7")
DbCloseArea()
If file(cArq+OrdBagExt())
	fErase(cArq+OrdBagExt())
EndIf

RestArea(_aAliasDet)

Return (Nil)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ cria_TC7³ Autor ³ Ewerton C Tomaz        ³ Data ³ 01/12/00 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Projeto Ewerton                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/     

Static Function cria_TC7()
Local _nX

DbSelectArea('SX3')
DbSetOrder(1)
For _nX := 1 To Len(_aArqSel)
	DbSeek(_aArqSel[_nX])
	While !Eof() .And. X3_ARQUIVO = _aArqSel[_nX]
		If (alltrim(X3_CAMPO)+"," $cCampos)
			aadd(aFields,{X3_CAMPO,X3_TIPO,X3_TAMANHO,X3_DECIMAL})
		EndIf
		DbSkip()
	End  
Next
AAdd(aFields,{"C7_AQUANT","N",12,2})

cArq:=criatrab(aFields,.T.)
DbUseArea(.t.,,cArq,"TC7")
Return(Nil)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ cria_TC7³ Autor ³ Ewerton C Tomaz        ³ Data ³ 01/12/00 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Projeto Ewerton                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/     

Static Function monta_TC7()

Local _nX

cQueryCad :="select C7_NUM,C7_ITEM,C7_DESCRI,C7_DATPRF,C7_QUANT,C7_QUJE,C7_PRODUTO,"
cQueryCad +="       (C7_QUANT-C7_QUJE) As C7_AQUANT,C7_UM"
cQueryCad +="  from "+RetSqlName('SC7')+" "
cQueryCad +=" where D_E_L_E_T_ <>'*' and C7_PRODUTO ='"+alltrim(cPro)+"' and "
cQueryCad +=" C7_QUANT >C7_QUJE and C7_RESIDUO <> 'S' and "
cQueryCad +=" C7_FILIAL = '"+xFilial("SC7")+"' "
cQueryCad +=" order by C7_DATPRF"

tcQuery cQueryCad new alias "CAD"

tcSetField("CAD","C7_DATPRF","D")

DbSelectArea("CAD")
DbGoTop()

ProcRegua(RecCount())
while CAD->(!Eof())
	IncProc()
	RecLock("TC7",.T.)
	For _nX := 1 To Len(aFields)
		If aFields[_nX,2] ='C'
			cX :='TC7->'+aFields[_nX,1]+' :=alltrim(CAD->'+aFields[_nX,1]+')'
		Else
			cX :='TC7->'+aFields[_nX,1]+' :=CAD->'+aFields[_nX,1]
		EndIf
		cX :=&cX
	Next
	msUnLock()
	CAD->(DbSkip())
End  
DbSelectarea("CAD")
DbCloseArea()

DbSelectarea("TC7")
DbGoTop()
SysRefresh()
Return(Nil)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³SIMILAR  ³ Autor ³ Ewerton C Tomaz        ³ Data ³ 01/12/00 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Projeto Ewerton                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
     
Static Function SIMILAR()
Private _aAliasSIM    	:= GetArea()
Private aCampos1 		:= {}
Private _cNumProd	    := SB1->B1_COD
Private _nOrder3        := SB1->(IndexOrd())
Private _nRecno3        := SB1->(Recno())


DbSelectArea("SB1")
AADD(aCampos1,	{"TB_COD"		,STR0047		,"@!"}) //"Produto"
AADD(aCampos1,	{"TB_DESC"		,STR0008	,"@!"}) //"Descricao"
AADD(aCampos1,	{"TB_QUANT"		,STR0025	    ,"@E 999999.99"}) //"Estoque"
AADD(aCampos1,	{"TB_MARCA"		,STR0018		,"@!"}) //"Marca"
AADD(aCampos1,	{"TB_PRECO"		,STR0049	,"@E 999,999.99"}) //"Prc Minimo"
AADD(aCampos1,	{"TB_PRECOM"    ,STR0050	,"@E 999,999.99"}) //"Prc Maximo"

cArqDBF := CriaTrab(NIL,.f.)
aFields := {}
AAdd(aFields,{"TB_COD"   ,"C",TamSX3("B1_COD")[1],0})
AAdd(aFields,{"TB_DESC"  ,"C",TamSX3("B1_DESC")[1],0})
AAdd(aFields,{"TB_QUANT" ,"N",TamSX3("B2_QATU")[1],TamSX3("B2_QATU")[2]})
AAdd(aFields,{"TB_MARCA" ,"C",TamSX3("B1_FABRIC")[1],0})
AAdd(aFields,{"TB_PRECO" ,"N",TamSX3("B0_PRV1")[1],TamSX3("B0_PRV1")[2]})
AAdd(aFields,{"TB_PRECOM","N",TamSX3("B0_PRV1")[1],TamSX3("B0_PRV1")[2]})

DbCreate(cArqDbf,aFields)
DbUseArea(.T.,,cArqDbf,"TRB",.F.)
cIndCond := "TB_DESC"
cArqNtx  := CriaTrab(NIL,.f.)
IndRegua("TRB",cArqNtx,cIndCond,,,STR0040)  //"Selecionando Registros..."
DbGoTop()

DbSelectArea("SB1")
DbSetOrder(1)
DbSeek(xFilial("SB1")+_cNumProd)
_cDesc := SUBSTR(SB1->B1_DESC,1,10)
DbSetOrder(3)
DbSeek(xFilial("SB1")+_cDesc,.T.)
While SB1->(! Eof()) .AND. SB1->B1_FILIAL == xFilial("SB1") .AND. SUBSTR(SB1->B1_DESC,1,10) == _cDesc
	DbSelectarea( "SB2" )
	DbSetorder(1)
	DbSeek( xFilial("SB2") + SB1->B1_COD + SB1->B1_LOCPAD )
	_nSaldo := SaldoMov()
	
	DbSelectarea( "SB0" )
	DbSetorder(1)
	DbSeek( xFilial("SB0") + SB1->B1_COD)
	
	DbSelectArea("TRB")
	RecLock("TRB",.T.)
	TB_COD   := SB1->B1_COD
	TB_DESC  := SB1->B1_DESC
	TB_QUANT := _nSaldo
	TB_MARCA := SB1->B1_FABRIC
	_cPrcMinS := "SB0->B0_PRV"+Alltrim(Str(SU0->U0_TABMIN,2))
	_cPrcMinS := &_cPrcMinS
	_cPrcMaxS := "SB0->B0_PRV"+Alltrim(Str(SU0->U0_TABMAX,2))
	_cPrcMaxS := &_cPrcMaxS
	TB_PRECO  := _cPrcMinS
	TB_PRECOM := _cPrcMaxS	
	MsUnLock()
	
	DbSelectArea("SB1")
	DbSkip()
End
DbSelectArea("TRB")
DbGoTop()

@ 000,000 TO 220,700 DIALOG oDlg1 TITLE STR0051 //"Descricoes Similares"
@ 000,000 TO 110,350  BROWSE "TRB" FIELDS aCampos1

ACTIVATE DIALOG oDlg1 CENTER

DbSelectArea("TRB")
DbCloseArea()
Ferase(cArqDBF+OrdBagExt())

DBselectarea("SB1")
DBsetorder(_nOrder3)
DBGoto(_nRecno3)

RestArea(_aAliasSIM)

Return(.T.)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ESTFIL   ³ Autor ³ Ewerton C Tomaz        ³ Data ³ 01/12/00 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Projeto Ewerton                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

Static Function ESTFIL()
Private _aAliasSIM    	:= GetArea()
Private aCampos1 		:= {}
Private _cNumProd	    := SB1->B1_COD

AAdd(aCampos1,	{"TB_FILIAL"	,STR0052		,"@!"})  //"Filial"
AAdd(aCampos1,	{"TB_DESC"	    ,STR0008 		,"@!"})  //"Descricao"
AAdd(aCampos1,  {"TB_QUANT"     ,STR0025	    ,"@ER 99999999"}) //"Estoque"
AAdd(aCampos1,  {"TB_RESERVA"   ,STR0054	    ,"@ER 99999999"}) //"Reserva"
AAdd(aCampos1,  {"TB_CONTRA"    ,STR0022	    ,"@ER 99999999"}) //"Contrato"
AAdd(aCampos1,  {"TB_DISPO"     ,STR0026 	    ,"@ER 99999999"}) //"Disponivel"

cArqDBF := CriaTrab(NIL,.f.)
aFields := {}
AAdd(aFields,{"TB_FILIAL" ,"C",TamSX3("B2_FILIAL")[1],0})
AAdd(aFields,{"TB_DESC"   ,"C",40,0})
AAdd(aFields,{"TB_QUANT"  ,"N",TamSX3("B2_QATU")[1],TamSX3("B2_QATU")[2]})
AAdd(aFields,{"TB_RESERVA","N",TamSX3("B2_QATU")[1],TamSX3("B2_QATU")[2]})
AAdd(aFields,{"TB_CONTRA" ,"N",TamSX3("B2_QATU")[1],TamSX3("B2_QATU")[2]})
AAdd(aFields,{"TB_DISPO"  ,"N",TamSX3("B2_QATU")[1],TamSX3("B2_QATU")[2]})

DbCreate(cArqDbf,aFields)
DbUseArea(.T.,,cArqDbf,"TRB",.F.)
cIndCond := "TB_FILIAL"
cArqNtx  := CriaTrab(NIL,.f.)
IndRegua("TRB",cArqNtx,cIndCond,,,STR0040)  //"Selecionando Registros..."
DbGoTop()

cQueryCad :="SELECT B2_FILIAL, B1_DESC, B2_QATU, B2_RESERVA"
cQueryCad +=" FROM "+RetSqlName('SB2')+" SB2 , "+RetSqlName('SB1')+" SB1  "
cQueryCad +=" WHERE SB2.D_E_L_E_T_ <> '*' and SB1.D_E_L_E_T_ <> '*' and "
cQueryCad +=" B2_COD = '"+alltrim(_cNumProd)+"' and "
cQueryCad +=" B1_COD = B2_COD and "
cQueryCad +=" B2_FILIAL <> '"+xFilial("SB2")+"' AND "
cQueryCad +=" B1_FILIAL = '"+xFilial("SB1")+"' "
cQueryCad +=" ORDER BY B2_LOCAL"

tcQuery cQueryCad new alias "TRB2"

DbSelectArea("TRB2")
DbGoTop()

While !Eof() 
	DbSelectArea("TRB")
	RecLock("TRB",.T.)
	TRB->TB_FILIAL := TRB2->B2_FILIAL
	TRB->TB_DESC   := TRB2->B1_DESC
	TRB->TB_QUANT  := TRB2->B2_QATU
	TRB->TB_RESERVA:= TRB2->B2_RESERVA
	TRB->TB_CONTRA := T_BuscaSalCon("",Alltrim(_cNumProd),TRB2->B2_FILIAL)
	TRB->TB_DISPO  := TRB2->B2_QATU-TRB2->B2_RESERVA-TRB->TB_CONTRA
	MsUnLock()
	DbSelectArea("TRB2")
	DbSkip()
End
DbSelectArea("TRB")
DbGoTop()

@ 000,000 TO 220,700 DIALOG oDlg1 TITLE STR0055 //"Estoque nas Filiais"
@ 000,000 TO 110,350  BROWSE "TRB" FIELDS aCampos1

ACTIVATE DIALOG oDlg1 CENTER

DbSelectArea("TRB2")
DbCloseArea()

DbSelectArea("TRB")
DbCloseArea()
Ferase(cArqDBF+OrdBagExt())

RestArea(_aAliasSIM)

Return(.T.)
           
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³BuscaValCon³ Autor ³ Ewerton C Tomaz        ³ Data ³ 01/12/00 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³                                                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Projeto Ewerton                                              ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

Template Function BuscaValCon(_cCliente, _cProduto)

Local _aAreaBVC := GetArea()

CHKTEMPLATE("DCM")  

_lRet := .F.
DbSelectArea("LH5")
DbSetOrder(4)
If !DbSeek(xFilial("LH5")+_cCliente+_cProduto)
	DbSelectArea("LH6")
	DbSetOrder(3)
	If DbSeek(xFilial("LH6")+_cCliente)
		DbSelectArea("LH5")
		DbSetOrder(4)
		If DbSeek(xFilial("LH5")+LH6->LH6_CLIENT+_cProduto)
			DbSelectArea('LH4')
			DbSetOrder(2)
			DbSeek(xFilial('LH4')+LH6->LH6_CLIENT)
			_lRet := .T.
		EndIf
	EndIf
Else
	DbSelectArea('LH4')
	DbSetOrder(2)
	DbSeek(xFilial('LH4')+_cCliente)
	_lRet := .T.
EndIf
If !(dDatabase >= LH4->LH4_INICIO .And. dDatabase <= LH4->LH4_FINAL)
	_lRet := .F.
EndIf
RestArea(_aAreaBVC)
Return(_lRet)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³BuscaSalCon³ Autor ³ Ewerton C Tomaz        ³ Data ³ 01/12/00 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³                                                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Projeto Ewerton                                              ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

Template Function BuscaSalCon(_cCliente, _cProduto,_cFil)

Local _aAreaBSC := GetArea()
Local _cFilSC  := IIf(_cFil==nil,"",_cFil)


CHKTEMPLATE("DCM")  

_nRet := 0
If !Empty(_cCliente)
	DbSelectArea("LH5")
	DbSetOrder(4)
	If !DbSeek(xFilial("LH5")+_cCliente+_cProduto)
		DbSelectArea("LH6")
		DbSetOrder(3)
		If DbSeek(xFilial("LH6")+_cCliente)
			DbSelectArea("LH5")
			DbSetOrder(4)
			If DbSeek(xFilial("LH5")+LH6->LH6_CLIENT+_cProduto)
				_nRet := LH5->LH5_QTDSAL - T_BuscaResSC9(_cCliente, _cProduto)
			EndIf
		EndIf
	Else
		_nRet := LH5->LH5_QTDSAL - T_BuscaResSC9(_cCliente, _cProduto)
	EndIf
Else
	 
	_cQuery := "SELECT ISNULL(SUM(LH5_QTDSAL)-"
	_cQuery += "              ISNULL((SELECT SUM(C9_QTDLIB) FROM "+RetSqlName('SC9')+"  WHERE"
	_cQuery += "                      "+RetSqlName('SC9')+".D_E_L_E_T_ <> '*' AND "
	_cQuery += "                      C9_PRODUTO = '"+_cProduto+"'  AND "
	_cQuery += "                      C9_BLEST = ' ' AND C9_NFENT = ' ' AND "
	_cQuery += "                      (EXISTS (SELECT 'E' FROM "+RetSqlName('LH5')+" LH5  WHERE "
	_cQuery += "                      LH5.LH5_FILIAL = '"+xFilial("LH5")+"' AND "	
	_cQuery += "                      LH5.D_E_L_E_T_ <> '*' AND "
	_cQuery += "                      LH5.LH5_PRODUT = C9_PRODUTO AND "
	_cQuery += "                      LH5.LH5_CLIENT = C9_CLIENTE) OR "
	_cQuery += "		      EXISTS (SELECT 'E' FROM "+RetSqlName('LH6')+" LH6  WHERE "
	_cQuery += "                      LH6.D_E_L_E_T_ <> '*' AND "
	_cQuery += "                      LH6.LH6_FILIAL = '"+xFilial("LH6")+"' AND "	
	_cQuery += "		      LH6_SOCIO = C9_CLIENTE))),0),0) AS TOTAL "
	_cQuery += "FROM "+RetSqlName('LH5')+"  WHERE "
	_cQuery += RetSqlName('LH5')+".D_E_L_E_T_ <> '*' AND "
	If Empty(_cFilSC)
		_cQuery += RetSqlName('LH5')+".LH5_FILIAL = '"+xFilial("LH5")+"' AND "
	Else
		_cQuery += RetSqlName('LH5')+".LH5_FILIAL = '"+_cFilSC+"' AND "	
	EndIf
	_cQuery += "LH5_PRODUT = '"+_cProduto+"' "
	_cQuery += " AND LH5_QTDSAL > 0 "
	_cQuery += " AND NOT EXISTS (SELECT 'E' FROM "+RetSqlName('LH4')+"  WHERE "
	_cQuery += RetSqlName('LH4')+".D_E_L_E_T_ <> '*' AND "
	If Empty(_cFilSC)	
		_cQuery += RetSqlName('LH4')+".LH4_FILIAL = '"+xFilial("LH4")+"' AND "
	Else
		_cQuery += RetSqlName('LH4')+".LH4_FILIAL = '"+_cFilSC+"' AND "	
	EndIf
	_cQuery += " LH4_COD = LH5_CODCON AND LH4_NUMORC <> ' ') "
	
	_cQuery := ChangeQuery(_cQuery)
	
	TcQuery _cQuery NEW ALIAS "RESUL"
	_nRet := RESUL->TOTAL
	DbSelectArea('RESUL')
	DbCloseArea()
EndIf
RestArea(_aAreaBSC)
Return(_nRet)
                                              
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³BuscaResSC9³ Autor ³ Ewerton C Tomaz        ³ Data ³ 01/12/00 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³                                                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Projeto Ewerton                                              ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

Template Function BuscaResSC9(_cCliente, _cProduto)

Local _aAreaBRS := GetArea()

CHKTEMPLATE("DCM")  

If !Empty(_cCliente)
	_cQuery := "SELECT ISNULL(SUM(C9_QTDLIB),0) AS TOTAL FROM "+RetSqlName('SC9')+ "  "
	_cQuery += " WHERE C9_PRODUTO = '"+_cProduto+"' AND "
	_cQuery += " D_E_L_E_T_ <> '*' AND "
	_cQuery += " C9_FILIAL = '"+xFilial("SC9")+"' AND "	
	_cQuery += " C9_BLEST = ' ' AND C9_NFENT = ' ' AND"
	_cQuery += " C9_CLIENTE = '"+_cCliente+"' "
Else
	_cQuery := " SELECT ISNULL(SUM(C9_QTDLIB),0) AS TOTAL FROM "+RetSqlName('SC9')+"  "
	_cQuery += " WHERE C9_PRODUTO = '"+_cProduto+"' AND "
	_cQuery += " D_E_L_E_T_ <> '*' AND "
	_cQuery += " C9_FILIAL = '"+xFilial("SC9")+"' AND "	
	_cQuery += " C9_BLEST = ' ' AND C9_NFENT = ' ' AND "
	_cQuery += " ( EXISTS (SELECT 'E' FROM "+RetSqlName('LH5')+"  "
	_cQuery += " WHERE "+RetSqlName('LH5')+".D_E_L_E_T_ <> '*' AND "
	_cQuery += " LH5_PRODUT = C9_PRODUTO AND "
	_cQuery += " LH5_CLIENT = C9_CLIENTE AND "
	_cQuery += " EXISTS (SELECT 'E' FROM "+RetSqlName('LH4')+"   "
	_cQuery += "    WHERE "+RetSqlName('LH4')+".D_E_L_E_T_ <> '*' "
	_cQuery += "    AND "+RetSqlName('LH4')+".LH4_FILIAL = '"+xFilial("LH4")+"' "	
	_cQuery += "	AND LH4_COD = LH5_CODCON AND LH4_NUMORC = ' ') "
	_cQuery += " ) OR "
	_cQuery += " EXISTS (SELECT 'E' FROM "+RetSqlName('LH6')+"  "
	_cQuery += " WHERE "+RetSqlName('LH6')+".D_E_L_E_T_ <> '*' AND "
	_cQuery += RetSqlName('LH6')+".LH6_FILIAL = '"+xFilial("LH6")+"' AND "		
	_cQuery += " LH6_SOCIO = C9_CLIENTE AND "
	_cQuery += " EXISTS (SELECT 'E' FROM "+RetSqlName('LH4')+"  "
	_cQuery += "    WHERE "+RetSqlName('LH4')+".D_E_L_E_T_ <> '*' AND "
	_cQuery += RetSqlName('LH4')+".LH4_FILIAL = '"+xFilial("LH4")+"' AND "		
	_cQuery += "	LH4_CLIENT = LH6_SOCIO AND LH4_NUMORC = ' ') ) ) "
EndIf

_cQuery := ChangeQuery(_cQuery)

TcQuery _cQuery NEW ALIAS "RESUL"

_nRet := RESUL->TOTAL
DbSelectArea('RESUL')
DbCloseArea()
RestArea(_aAreaBRS)
Return(_nRet)
