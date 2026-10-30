#INCLUDE "RWMAKE.CH" 
#INCLUDE "TBICONN.CH"

User Function IncL1L2L4()
Local c_Emp 		:= "99"
Local c_Fil 		:= "01"
Local nOrcIni 		:= 1
Local nOrcFim 		:= 5
//Local nOrcFim 		:= 2
Local nInd 			:= 0
Local nX 			:= 0
Local nY 			:= 0
Local aSL1 			:= {}
Local aSL2 			:= {}
Local aSL4 			:= {}
Local cNumOrc  		:= ""
Local cNumDoc		:= ""
Local cItem 		:= "00"
Local nQtdeItens 	:= 2
Local nVlrTotal 	:= 0
Local nVlrParc 		:= 0
Local nDinheiro		:= 0
Local nCheque 		:= 0

//Abre Ambiente
PREPARE ENVIRONMENT EMPRESA c_Emp Filial c_Fil modulo 'LOJ'

//////// CABECALHO ////////
aSL1 := {	{ "L1_VEND"   , "000001"},;
			{ "L1_CLIENTE", "000001"},;
			{ "L1_LOJA"   , "01" },;
			{ "L1_TIPOCLI", "F" },;
			{ "L1_VLRTOT" , 7.15 },;
			{ "L1_VLRLIQ" , 7.15 },;
			{ "L1_DTLIM"  , dDataBase },;
			{ "L1_SERIE"  , "001" },;
			{ "L1_PDV"    , "9999" },;
			{ "L1_EMISNF" , dDataBase },;
			{ "L1_VALBRUT", 7.15 },;
			{ "L1_VALMERC", 7.15 },;
			{ "L1_TIPO"   , "V" },;
			{ "L1_DESCNF" , 0 },;
			{ "L1_OPERADO", "C03" },;
			{ "L1_DINHEIR", 2.39 },;
			{ "L1_CHEQUES", 4.76 },;
			{ "L1_ENTRADA", 2.39 },;
			{ "L1_PARCELA", 3 },;
			{ "L1_CONDPG" , "CN" },;
			{ "L1_FORMPG" , "R$" },;
			{ "L1_EMISSAO", dDataBase },;
			{ "L1_CONFVEN", "SSSSSSSSNSSS" },;
			{ "L1_IMPRIME", "1S" },;
			{ "L1_SITUA"  , "RX" },;
			{ "L1_ESTACAO", "001" },;
			{ "L1_NUMMOV" , "1" } }

			
//////// ITENS ////////
For nInd:=1 To (nQtdeItens/2)
	//Item 01

	aAdd( aSL2, {	{ "L2_PRODUTO", "000001" },; ////////////////////////////
					{ "L2_DESCRI" , "PRODUTO 1" },; ////////////
					{ "L2_QUANT"  , 1 },;    ////////////////////////
					{ "L2_VRUNIT" , 2.75 },; ////////////////////////
					{ "L2_VLRITEM", 2.75 },; ////////////////////////
					{ "L2_LOCAL"  , "01" },;
					{ "L2_UM"     , "PC" },;
					{ "L2_TES"    , "501" },;
					{ "L2_CF"     , "512" },;
					{ "L2_VENDIDO", "S" },;
					{ "L2_TABELA" , "1" },;
					{ "L2_EMISSAO", dDataBase },;
					{ "L2_PRCTAB" , 2.75 },; ///////////////////
					{ "L2_GRADE"  , "N" },;
					{ "L2_VEND"   , "000001" },;
					{ "L2_SITUA"  , "TX" },;
					{ "L2_ITEMSD1", "000000" },;
					{ "L2_ENTREGA", "3" },;
					{ "L2_SITTRIB", "T1800" } } )
	nVlrTotal := nVlrTotal + 2.75

	
	//Item 02				
	aAdd( aSL2, { 	{ "L2_PRODUTO", "000002" },; ////////////////////////////
					{ "L2_DESCRI" , "PRODUTO 2" },; ////////////
					{ "L2_QUANT"  , 1 },;    ////////////////////////
					{ "L2_VRUNIT" , 4.4 },; ////////////////////////
					{ "L2_VLRITEM", 4.4 },; ////////////////////////
					{ "L2_LOCAL"  , "01" },;
					{ "L2_UM"     , "PC" },;
					{ "L2_TES"    , "501" },;
					{ "L2_CF"     , "512" },;
					{ "L2_VENDIDO", "S" },;
					{ "L2_TABELA" , "1" },;
					{ "L2_EMISSAO", dDataBase },;
					{ "L2_PRCTAB" , 4.4 },; ///////////////////
					{ "L2_GRADE"  , "N" },;
					{ "L2_VEND"   , "000001" },;
					{ "L2_SITUA"  , "TX" },;
					{ "L2_ITEMSD1", "000000" },;
					{ "L2_ENTREGA", "2" },;
					{ "L2_SITTRIB", "T1800" } } )
	nVlrTotal := nVlrTotal + 4.4    
Next nInd

			
//////// CONDICAO DE PAGAMENTO ////////
nVlrParc := NoRound( nVlrTotal / 3 , 2)
nDinheiro := nVlrParc + (nVlrTotal - (nVlrParc * 3) )
nCheque := nVlrParc

// Parcela 1
aAdd( aSL4, {	{ "L4_DATA"	  , dDataBase 	},; ////////////////////////
				{ "L4_VALOR"  , nDinheiro  	},; ////////////////////////
				{ "L4_FORMA"  , "R$" 		},; ////////////////////////
				{ "L4_ADMINIS", "" 			},; ////////////////////////
				{ "L4_NUMCART", "" 			},; ////////////////////////
				{ "L4_AGENCIA", "" 			},; ////////////////////////
				{ "L4_CONTA"  , "" 			},; ////////////////////////
				{ "L4_TERCEIR", .F.			},;
				{ "L4_SITUA"  , "TX" 		} } )
				
// Parcela 2
aAdd( aSL4, {	{ "L4_DATA"	  , dDataBase+1	},; ////////////////////////
				{ "L4_VALOR"  , nCheque  	},; ////////////////////////
				{ "L4_FORMA"  , "CH" 		},; ////////////////////////
				{ "L4_ADMINIS", "341"		},; ////////////////////////
				{ "L4_NUMCART", "12346"		},; ////////////////////////
				{ "L4_AGENCIA", "1024"		},; ////////////////////////
				{ "L4_CONTA"  , "1234"		},; ////////////////////////
				{ "L4_TERCEIR", .F.			},;
				{ "L4_SITUA"  , "TX" 		} } )
				
// Parcela 3
nVlrParc := nVlrParc + (nVlrTotal - (nVlrParc * 3) )
aAdd( aSL4, {	{ "L4_DATA"	  , dDataBase+2	},; ////////////////////////
				{ "L4_VALOR"  , nCheque  	},; ////////////////////////
				{ "L4_FORMA"  , "CH" 		},; ////////////////////////
				{ "L4_ADMINIS", "341"		},; ////////////////////////
				{ "L4_NUMCART", "12347"		},; ////////////////////////
				{ "L4_AGENCIA", "1024"		},; ////////////////////////
				{ "L4_CONTA"  , "1234"		},; ////////////////////////
				{ "L4_TERCEIR", .F.			},;
				{ "L4_SITUA"  , "TX" 		} } )
				

For nInd:=nOrcIni To nOrcFim
		
	cNumero := GetSx8Num("SC0","C0_NUM")
	ConfirmSx8()
	
	cNumOrc := "_"+StrZero(nInd,5)
	cNumDoc := StrZero(nInd,6)
	cItem := "00"
	
	//Inclui SL1 (Cabecalho do Orcamento)
	DbSelectArea("SL1")
	RecLock("SL1",.T.)
	SL1->L1_FILIAL 	:= xFilial("SL1")
	SL1->L1_NUM 	:= cNumOrc
	SL1->L1_DOC 	:= cNumDoc
	SL1->L1_NUMCFIS := SL1->L1_DOC
	SL1->L1_HORA 	:= Time()
	For nY:=1 To Len(aSL1)
		&(aSL1[nY][1]) := aSL1[nY][2]
	Next nY
	SL1->L1_VLRTOT 	:= nVlrTotal
	SL1->L1_VLRLIQ 	:= nVlrTotal
	SL1->L1_VALBRUT := nVlrTotal
	SL1->L1_VALMERC := nVlrTotal
	SL1->L1_DINHEIR := nDinheiro
	SL1->L1_CHEQUES := (nCheque * 2)
	SL1->L1_ENTRADA := nDinheiro
	SL1->L1_DOCPED	:= cNumero
	SL1->( MsUnLock() )
	
	//Inclui SL2 (Itens do Orcamento)
	DbSelectArea("SL2")
	For nX:=1 To Len(aSL2)
		cItem := Soma1(cItem)
		RecLock("SL2",.T.)
		SL2->L2_FILIAL := xFilial("SL2")
		SL2->L2_NUM    := SL1->L1_NUM
		SL2->L2_ITEM   := cItem
		SL2->L2_DOC    := SL1->L1_DOC
		SL2->L2_SERIE  := SL1->L1_SERIE
		SL2->L2_PDV    := SL1->L1_PDV
		For nY:=1 To Len(aSL2[nX])
			&(aSL2[nX][nY][1]) := aSL2[nX][nY][2]
		Next nY

 		If AllTrim(SL2->L2_PRODUTO) == "000001"
			SL2->L2_RESERVA := cNumero
		EndIf
		
		SL2->( MsUnLock() )
	Next nX
	
	//Inclui SL4 (Condicao Negociada)
	DbSelectArea("SL4")
	For nX:=1 To Len(aSL4)
		RecLock("SL4",.T.)
		SL4->L4_FILIAL 	:= xFilial("SL4")
		SL4->L4_NUM 	:= SL1->L1_NUM
		For nY:=1 To Len(aSL4[nX])
			&(aSL4[nX][nY][1]) := aSL4[nX][nY][2]
		Next nY
		SL4->( MsUnLock() )
	Next nX
	
	Reclock("SC0", .T.)
	REPLACE	C0_FILIAL	WITH	'01'
	REPLACE	C0_NUM		WITH	cNumero
	REPLACE	C0_TIPO		WITH	'LJ'
	REPLACE	C0_DOCRES	WITH	'1'
	REPLACE	C0_SOLICIT	WITH	'1'
	REPLACE	C0_FILRES	WITH	'01'
	REPLACE	C0_PRODUTO	WITH	'000001'
	REPLACE	C0_LOCAL	WITH	'01'
	REPLACE	C0_QUANT	WITH	1

	REPLACE	C0_VALIDA	WITH	CToD('30/10/2012')	//'20121030'
	REPLACE	C0_EMISSAO	WITH	CToD('29/10/2012')	//'20121030'
	REPLACE	C0_NUMLOTE	WITH	''
	REPLACE	C0_LOTECTL	WITH	''
	REPLACE	C0_LOCALIZ	WITH	''
	REPLACE	C0_NUMSERI	WITH	''
	REPLACE	C0_QTDORIG	WITH	1
	REPLACE	C0_QTDPED	WITH	0
	REPLACE	C0_OBS		WITH	'Pedido:000150 Filial:01'
	REPLACE	C0_QTDELIM	WITH	0
	SC0->(Msunlock())
	
	conout("************ Inclusao do Orcamento " + SL1->L1_NUM)
	
Next nInd

Return 
