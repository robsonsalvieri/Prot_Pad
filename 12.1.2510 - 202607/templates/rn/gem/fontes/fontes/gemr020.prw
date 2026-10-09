#INCLUDE "protheus.ch" 
#INCLUDE "gemr020.ch"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³GEMR020   ³ Autor ³ Reynaldo Miyashita    ³ Data ³ 06.02.06 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Extrato do Empreendimento/Cliente                           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³Nenhum                                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³Nenhum                                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³   DATA   ³ Programador   ³Manutencao efetuada                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ 06.02.06 ³Reynaldo Miyash³ Criação                                    ³±± 
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Template Function GEMR020()
Local aArea  := GetArea()
Local aItens := {}
Local lOk    := .F.
Local lEnd

Private nLin := 280

// Valida se tem licenças para o Template GEM = Gestao de Empreendimentos Imobiliarios							 
ChkTemplate("LOT")

AjustaSX1()

oPrint := PcoPrtIni(STR0001,.T.,2,,@lOk,"GMR020")  // //"Extrato de Contrato"

If lOk
	//
	// Filtra as informacoes
	//
	Processa({||GMR020Ini(@aItens)},STR0002) // //"Processando..."
    
	RptStatus( {|lEnd| GMR020Imp(@lEnd,oPrint,aItens)})
	PcoPrtEnd(oPrint)
EndIf

RestArea(aArea)

Return

//
//
//
Static Function GMR020Imp( lEnd, oPrint ,aItens )
Local nLin      := 0
Local nCount    := 0
Local nCount2   := 0
Local aTamCols  := {}

aTamCols := Array(6)	
aTamCols[1] := {10,220,280,310}
aTamCols[2] := {10,220,1200,1600,1820,2485,3150}
aTamCols[3] := {10,220,1200,1600,1820,2440}
aTamCols[4] := {10,140,360,490,610,830,1050,1270,1490,1710,1930,2150,2370,2590,2810,3030,3100}
aTamCols[5] := {10,2440}
aTamCols[6] := {20            ,610,830,1050,1270,1490,1710,1930,2150,2370,2590,2810,3030,3100}

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Imprime os dados.             ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If (Len(aItens) > 0)
	
	For nCount := 1 To Len(aItens)                       
	
		nLin := 0
		R020Cab( @oPrint, @nLin, aItens ,nCount, aTamCols	)
			
		nTipoParcela := 0
		For nCount2 := 1 To len(aItens[nCount][10])
		    //
			R020Cab( @oPrint, @nLin, aItens ,nCount, aTamCols )

			If nTipoParcela <> aItens[nCount][10][nCount2][1]
				Do Case 
					// titulos recebidos
					Case aItens[nCount][10][nCount2][1] == 1
						// Definicao das colunas do Status da parcela
						PcoPrtCol(aTamCols[5],.T.,len(aTamCols[5]))
						PcoPrtCell(PcoPrtPos( 1),nLin,PcoPrtTam( 1),90,STR0003,oPrint,2,3)  //"PARCELAS RECEBIDAS"
					// titulos renegociados
					Case aItens[nCount][10][nCount2][1] == 2
						// Definicao das colunas do Status da parcela
						PcoPrtCol(aTamCols[5],.T.,len(aTamCols[5]))
						PcoPrtCell(PcoPrtPos( 1),nLin,PcoPrtTam( 1),90,STR0038,oPrint,2,3)  //"Parcelas Renegociadas"
					// titulos Atrasados
					Case aItens[nCount][10][nCount2][1] == 3
						// Definicao das colunas do Status da parcela
						PcoPrtCol(aTamCols[5],.T.,Len(aTamCols[5]))
						PcoPrtCell(PcoPrtPos( 1),nLin,PcoPrtTam( 1),90,STR0004,oPrint,2,3)  //"PARCELAS ATRASADAS"
					// titulos a receber
					Case aItens[nCount][10][nCount2][1] == 4
						// Definicao das colunas do Status da parcela
						PcoPrtCol(aTamCols[5],.T.,len(aTamCols[5]))
						PcoPrtCell(PcoPrtPos( 1),nLin,PcoPrtTam( 1),90,STR0005,oPrint,2,3)  //"PARCELAS A RECEBER"
						
					// titulos transferidos
					Case aItens[nCount][10][nCount2][1] == 4
						// Definicao das colunas do Status da parcela
						PcoPrtCol(aTamCols[5],.T.,len(aTamCols[5]))
						PcoPrtCell(PcoPrtPos( 1),nLin,PcoPrtTam( 1),90,STR0044,oPrint,2,3)  //PARCELAS TRANSFERIDAS
						
				EndCase
				nLin+=90
				nTipoParcela := aItens[nCount][10][nCount2][1]
			EndIf
			// Definicao das colunas dos titulos a receber
			PcoPrtCol(aTamCols[4],.T.,len(aTamCols[4]))
			PcoPrtCell(PcoPrtPos( 1),nLin,PcoPrtTam( 1),50,aItens[nCount][10][nCount2][ 2],oPrint,2,1) 
			PcoPrtCell(PcoPrtPos( 2),nLin,PcoPrtTam( 2),50,aItens[nCount][10][nCount2][ 3],oPrint,2,1) 
			PcoPrtCell(PcoPrtPos( 3),nLin,PcoPrtTam( 3),50,aItens[nCount][10][nCount2][ 4],oPrint,2,1) 
			PcoPrtCell(PcoPrtPos( 4),nLin,PcoPrtTam( 4),50,aItens[nCount][10][nCount2][ 5],oPrint,2,1) 
			PcoPrtCell(PcoPrtPos( 5),nLin,PcoPrtTam( 5),50,aItens[nCount][10][nCount2][ 6],oPrint,2,1,,,.T.) 
			PcoPrtCell(PcoPrtPos( 6),nLin,PcoPrtTam( 6),50,aItens[nCount][10][nCount2][ 7],oPrint,2,1,,,.T.) 
			PcoPrtCell(PcoPrtPos( 7),nLin,PcoPrtTam( 7),50,aItens[nCount][10][nCount2][ 8],oPrint,2,1,,,.T.) 
			PcoPrtCell(PcoPrtPos( 8),nLin,PcoPrtTam( 8),50,aItens[nCount][10][nCount2][ 9],oPrint,2,1,,,.T.)
			 
			PcoPrtCell(PcoPrtPos( 9),nLin,PcoPrtTam( 9),50,aItens[nCount][10][nCount2][10] ,oPrint,2,1,,,.T.) 
			PcoPrtCell(PcoPrtPos(10),nLin,PcoPrtTam(10),50,aItens[nCount][10][nCount2][11] ,oPrint,2,1,,,.T.)
			
			PcoPrtCell(PcoPrtPos(11),nLin,PcoPrtTam(11),50,aItens[nCount][10][nCount2][12],oPrint,2,1,,,.T.)
			PcoPrtCell(PcoPrtPos(12),nLin,PcoPrtTam(12),50,aItens[nCount][10][nCount2][13],oPrint,2,1,,,.T.)
			PcoPrtCell(PcoPrtPos(13),nLin,PcoPrtTam(13),50,aItens[nCount][10][nCount2][14],oPrint,2,1,,,.T.)
			PcoPrtCell(PcoPrtPos(14),nLin,PcoPrtTam(14),50,aItens[nCount][10][nCount2][15],oPrint,2,1,,,.T.)
			PcoPrtCell(PcoPrtPos(15),nLin,PcoPrtTam(15),50,aItens[nCount][10][nCount2][16],oPrint,2,1,,,.T.)
			PcoPrtCell(PcoPrtPos(16),nLin,PcoPrtTam(16),50,aItens[nCount][10][nCount2][17],oPrint,2,1)
			nLin+=50

		Next nCount2		

		//
		// totais do contrato
		//
		For nCount2 := 1 To len(aItens[nCount][11])
		
		    //
			R020Cab( @oPrint, @nLin, aItens ,nCount, aTamCols )
			
			// Definicao das colunas dos totais por status dos titulos a receber
			PcoPrtCol(aTamCols[6],.T.,len(aTamCols[6]))
			Do Case 
				// recebidas
				Case aItens[nCount][11][nCount2][1] == 1
					PcoPrtCell(PcoPrtPos( 1),nLin,PcoPrtTam( 1),50,STR0006,oPrint,2,3)  //"RECEBIDAS"
				//renegociadas
				Case aItens[nCount][11][nCount2][1] == 2
					PcoPrtCell(PcoPrtPos( 1),nLin,PcoPrtTam( 1),50,STR0039,oPrint,2,3) // "Renegociadas"
				//atrasadas
				Case aItens[nCount][11][nCount2][1] == 3
					PcoPrtCell(PcoPrtPos( 1),nLin,PcoPrtTam( 1),50,STR0007,oPrint,2,3)  //"ATRASADAS"
				// a receber
				Case aItens[nCount][11][nCount2][1] == 4
					PcoPrtCell(PcoPrtPos( 1),nLin,PcoPrtTam( 1),50,STR0008,oPrint,2,3)  //"A RECEBER"
				// transferidos
				Case aItens[nCount][11][nCount2][1] == 5
					PcoPrtCell(PcoPrtPos( 1),nLin,PcoPrtTam( 1),50,STR0045,oPrint,2,3) // "TRANSFERIDOS"
			EndCase
			
			PcoPrtCell(PcoPrtPos( 2),nLin,PcoPrtTam( 2),50,aItens[nCount][11][nCount2][ 2],oPrint,2,2,,,.T.) 
			PcoPrtCell(PcoPrtPos( 3),nLin,PcoPrtTam( 3),50,aItens[nCount][11][nCount2][ 3],oPrint,2,2,,,.T.) 
			PcoPrtCell(PcoPrtPos( 4),nLin,PcoPrtTam( 4),50,aItens[nCount][11][nCount2][ 4],oPrint,2,2,,,.T.) 
			
			PcoPrtCell(PcoPrtPos( 5),nLin,PcoPrtTam( 5),50,aItens[nCount][11][nCount2][ 5],oPrint,2,2,,,.T.) 
			PcoPrtCell(PcoPrtPos( 6),nLin,PcoPrtTam( 6),50,aItens[nCount][11][nCount2][ 6],oPrint,2,2,,,.T.) 
			
			PcoPrtCell(PcoPrtPos( 7),nLin,PcoPrtTam( 7),50,aItens[nCount][11][nCount2][ 7],oPrint,2,2,,,.T.) 
			PcoPrtCell(PcoPrtPos( 8),nLin,PcoPrtTam( 8),50,aItens[nCount][11][nCount2][ 8],oPrint,2,2,,,.T.) 
			PcoPrtCell(PcoPrtPos( 9),nLin,PcoPrtTam( 9),50,aItens[nCount][11][nCount2][ 9],oPrint,2,2,,,.T.) 
			PcoPrtCell(PcoPrtPos(10),nLin,PcoPrtTam(10),50,aItens[nCount][11][nCount2][10],oPrint,2,2,,,.T.)
			PcoPrtCell(PcoPrtPos(11),nLin,PcoPrtTam(11),50,aItens[nCount][11][nCount2][11],oPrint,2,2,,,.T.)
			PcoPrtCell(PcoPrtPos(12),nLin,PcoPrtTam(12),50,aItens[nCount][11][nCount2][12],oPrint,2,2,,,.T.)
			nLin+=50
		
		Next nCount2
		
		//
		// Total geral do contrato
		//
		// Definicao das colunas dos totais por status dos titulos a receber
		PcoPrtCol(aTamCols[6],.T.,len(aTamCols[6]))                         
		PcoPrtCell(PcoPrtPos( 1),nLin,PcoPrtTam( 1),60,STR0009,oPrint,2,3)  // //"TOTAL GERAL"
		For nCount2 := 1 To len(aItens[nCount][12])
			PcoPrtCell(PcoPrtPos( nCount2+1 ),nLin,PcoPrtTam( nCount2+1 ),50,aItens[nCount][12][nCount2],oPrint,2,2,,,.T.) 
		Next nCount2
		nLin+=50
	    
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Verifica o cancelamento pelo usuario...                             ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If lEnd
	    	Exit
		EndIf  
		
    Next nCount
    
EndIf

Return( .T. )

Static Function R020Cab( oPrint, nLin, aItens ,nCount, aTamCols	)
Local nCount2 := 0

	If PcoPrtLim(nLin) .OR. nLin == 0
	    //
	    // Imprime o cabecalho do relatorio
	    // 
		nLin:=280
		PcoPrtCab(oPrint)                      
		
		// Definicao das colunas do Cabecalho do relatorio sobre cliente, loja e nome do cliente
		PcoPrtCol(aTamCols[1],.T.,len(aTamCols[1]))
	
		// Cabecalho sobre cliente, loja e nome do cliente
		PcoPrtCell(PcoPrtPos(1),nLin,PcoPrtTam(1),30,STR0010,oPrint,2,1,RGBConv(230,230,230))  //"Cliente"
		PcoPrtCell(PcoPrtPos(2),nLin,PcoPrtTam(2),30,STR0011,oPrint,2,1,RGBConv(230,230,230))  //"Loja"
		PcoPrtCell(PcoPrtPos(3),nLin,PcoPrtTam(3),30,STR0012,oPrint,2,1,RGBConv(230,230,230))  //"Nome"
		nLin+=25
		PcoPrtCell(PcoPrtPos(1),nLin,PcoPrtTam(1),50,aItens[nCount][1],oPrint,4,2) 
		PcoPrtCell(PcoPrtPos(2),nLin,PcoPrtTam(2),50,aItens[nCount][2],oPrint,4,2) 
		PcoPrtCell(PcoPrtPos(3),nLin,PcoPrtTam(3),50,aItens[nCount][3],oPrint,4,2)
		nLin+=90
	
		// Definicao das colunas do Cabecalho sobre contrato, Status, Data do contrato e valor original e atual do contrato
		PcoPrtCol(aTamCols[2],.T.,len(aTamCols[2]))
		
		PcoPrtCell(PcoPrtPos(1),nLin,PcoPrtTam(1),30,STR0013,oPrint,2,1,RGBConv(230,230,230))  //"Contrato"
		PcoPrtCell(PcoPrtPos(2),nLin,PcoPrtTam(2),30,STR0014,oPrint,2,1,RGBConv(230,230,230))  //"Status"
		PcoPrtCell(PcoPrtPos(3),nLin,PcoPrtTam(3),30,""     ,oPrint,0,1,RGBConv(230,230,230)) 
		PcoPrtCell(PcoPrtPos(4),nLin,PcoPrtTam(4),30,STR0015,oPrint,2,1,RGBConv(230,230,230))  //"Data do Contrato"
		PcoPrtCell(PcoPrtPos(5),nLin,PcoPrtTam(5),30,STR0040,oPrint,2,1,RGBConv(230,230,230))  //"Valor Original do Contrato"
		PcoPrtCell(PcoPrtPos(6),nLin,PcoPrtTam(6),30,STR0016,oPrint,2,1,RGBConv(230,230,230))  //"Valor Atual do Contrato"
		nLin+=25
		PcoPrtCell(PcoPrtPos(1),nLin,PcoPrtTam(1),50,aItens[nCount][4],oPrint,2,1) 
		PcoPrtCell(PcoPrtPos(2),nLin,PcoPrtTam(2),50,aItens[nCount][5],oPrint,2,1) 
		PcoPrtCell(PcoPrtPos(3),nLin,PcoPrtTam(3),50,""               ,oPrint,0,1) 
		PcoPrtCell(PcoPrtPos(4),nLin,PcoPrtTam(4),50,aItens[nCount][6],oPrint,2,1) 
		PcoPrtCell(PcoPrtPos(5),nLin,PcoPrtTam(5),50,aItens[nCount][7],oPrint,2,1,,,.T.) 
		PcoPrtCell(PcoPrtPos(6),nLin,PcoPrtTam(6),50,aItens[nCount][12][2],oPrint,2,1,,,.T.) 
		nLin+=75

		// Definicao das colunas do Cabecalho do empreendimento adquirido
		PcoPrtCol(aTamCols[1],.T.,len(aTamCols[1]))
		// Cabecalho com as informacoes do Empreendimento referente ao contrato
		PcoPrtCol(aTamCols[3],.T.,len(aTamCols[3]))
		PcoPrtCell(PcoPrtPos(1),nLin,PcoPrtTam(1),30,STR0017,oPrint,2,1,RGBConv(230,230,230))  //"Unidade"
		PcoPrtCell(PcoPrtPos(2),nLin,PcoPrtTam(2),30,STR0018,oPrint,2,1,RGBConv(230,230,230))  //"Descrição"
		PcoPrtCell(PcoPrtPos(3),nLin,PcoPrtTam(3),30,""     ,oPrint,0,1,RGBConv(230,230,230)) 
		PcoPrtCell(PcoPrtPos(4),nLin,PcoPrtTam(4),30,STR0019,oPrint,2,1,RGBConv(230,230,230))  //"Empreendimento"
		PcoPrtCell(PcoPrtPos(5),nLin,PcoPrtTam(5),30,STR0020,oPrint,2,1,RGBConv(230,230,230))  //"Descricao"
		nLin+=25
		
		For nCount2 := 1 to len(aItens[nCount][9])
			PcoPrtCell(PcoPrtPos(1),nLin,PcoPrtTam(1),50,aItens[nCount][9][nCount2][1],oPrint,2,1) 
			PcoPrtCell(PcoPrtPos(2),nLin,PcoPrtTam(2),50,aItens[nCount][9][nCount2][2],oPrint,2,1) 
			PcoPrtCell(PcoPrtPos(3),nLin,PcoPrtTam(3),50,""                           ,oPrint,0,1) 
			PcoPrtCell(PcoPrtPos(4),nLin,PcoPrtTam(4),50,aItens[nCount][9][nCount2][3],oPrint,2,1) 
			PcoPrtCell(PcoPrtPos(5),nLin,PcoPrtTam(5),50,aItens[nCount][9][nCount2][4],oPrint,2,1) 
			nLin+=50
		Next nCount2
		nLin+=25
		
		// Definicao das colunas do Cabecalho dos titulos a receber
		PcoPrtCol(aTamCols[4],.T.,len(aTamCols[4]))
		// Cabecalho dos titulos a receber
		PcoPrtCell(PcoPrtPos( 1),nLin,PcoPrtTam( 1),30,STR0021,oPrint,2,1,RGBConv(230,230,230)) // "Parcela"
		PcoPrtCell(PcoPrtPos( 2),nLin,PcoPrtTam( 2),30,STR0022,oPrint,2,1,RGBConv(230,230,230)) // "Tipo"
		PcoPrtCell(PcoPrtPos( 3),nLin,PcoPrtTam( 3),30,STR0023,oPrint,2,1,RGBConv(230,230,230)) // "Data Vencto."
		PcoPrtCell(PcoPrtPos( 4),nLin,PcoPrtTam( 4),30,STR0024,oPrint,2,1,RGBConv(230,230,230)) // "Data Baixa"
		PcoPrtCell(PcoPrtPos( 5),nLin,PcoPrtTam( 5),30,STR0025,oPrint,2,1,RGBConv(230,230,230)) // "Valor Pago"
		PcoPrtCell(PcoPrtPos( 6),nLin,PcoPrtTam( 6),30,STR0026,oPrint,2,1,RGBConv(230,230,230)) // "Valor Titulo"
		PcoPrtCell(PcoPrtPos( 7),nLin,PcoPrtTam( 7),30,STR0027,oPrint,2,1,RGBConv(230,230,230)) // "Principal"
		PcoPrtCell(PcoPrtPos( 8),nLin,PcoPrtTam( 8),30,STR0036,oPrint,2,1,RGBConv(230,230,230)) // "C.M."
		
		PcoPrtCell(PcoPrtPos( 9),nLin,PcoPrtTam( 9),30,STR0037,oPrint,2,1,RGBConv(230,230,230)) // "Juros"
		PcoPrtCell(PcoPrtPos(10),nLin,PcoPrtTam(10),30,STR0042,oPrint,2,1,RGBConv(230,230,230)) // "CM Juros"
		
		PcoPrtCell(PcoPrtPos(11),nLin,PcoPrtTam(11),30,STR0046,oPrint,2,1,RGBConv(230,230,230)) //"Pro Rata"
		PcoPrtCell(PcoPrtPos(12),nLin,PcoPrtTam(12),30,STR0041,oPrint,2,1,RGBConv(230,230,230)) // "Multa"
		PcoPrtCell(PcoPrtPos(13),nLin,PcoPrtTam(13),30,STR0028,oPrint,2,1,RGBConv(230,230,230)) //"Juros Mora" 
		PcoPrtCell(PcoPrtPos(14),nLin,PcoPrtTam(14),30,STR0029,oPrint,2,1,RGBConv(230,230,230)) //"Desconto" 
		PcoPrtCell(PcoPrtPos(15),nLin,PcoPrtTam(15),30,STR0030,oPrint,2,1,RGBConv(230,230,230)) //"Valor Atualizado" 
		PcoPrtCell(PcoPrtPos(16),nLin,PcoPrtTam(16),30,STR0031,oPrint,2,1,RGBConv(230,230,230)) //"Taxa" 
		nLin+=25
		
	EndIf
	
Return( .T. )

//
//
//
Static Function GMR020Ini( aItens )

Local nCount      := 0
Local aGrpTit     := {}
Local aTitulo     := {}
Local aTotais     := {}
Local aTotGeral   := {}
Local aContrato   := {}
Local aValor      := {}
Local nMoeda      := 0
Local nSaldo      := 0
Local nIndCorr    := 0
Local nPorcJurMor := 0
Local nPorcMulta  := 0
Local nVlrContrat := 0
Local dVencto     := stod("")
Local lContinua   := .F.
Local lFindSE5    := .F.
Local nCMPrinc    := 0
Local nCMJuros    := 0
Local aVlrCM      := {}
Local nVlrParcela   := 0 
Local nVlrProRata   := 0
Local nVlrJurosMora := 0
Local nVlrMulta     := 0
Local nVlrDescon    := 0
Local nDescto       := 0
Local nVlrBaixa     := 0
Local nVlrReceb     := 0
Local nVlrLiq       := 0
Local nVlrDistr     := 0
Local nStatus       := 0          
Local dHabite       := stod("")
Local dUltFech      := stod("")
Local nDiaCorr      := 0
Local nMes          := 0
Local nCntRegua     := 0
Local nCntSE5       := 0
Local aTipoDOC      := {}
Local nVlrAtual     := 0
Local nVlrCM        := 0 
Local aBaixas       := {}
Local dUltBaixa := stod("")

ProcRegua(100)

//
// Empreendimento
//     
dbSelectArea("LK3")
dbSetOrder(1) // LK3_FILIAL+LK3_CODEMP+LK3_DESCRI
dbSeek(xFilial("LK3")+MV_PAR01,.T.)
While LK3->(!eof()) .AND. (LK3->(LK3_FILIAL+LK3_CODEMP) >= xFilial("LK3")+MV_PAR01 .AND. LK3->(LK3_FILIAL+LK3_CODEMP) <= xFilial("LK3")+MV_PAR02 ) 
	//
	// cabecalho do Contratos
	//
	dbSelectArea("LIT")
	dbSetOrder(2) // LIT_FILIAL+LIT_NCONTR
	dbSeek(xFilial("LIT")+MV_PAR09,.T.)
	While LIT->(!eof()) .AND. (LIT->(LIT_FILIAL+LIT_NCONTR) >= xFilial("LIT")+MV_PAR09 .AND. LIT->(LIT_FILIAL+LIT_NCONTR) <= xFilial("LIT")+MV_PAR10 ) 
		
		If (LIT->(LIT_CLIENT+LIT_LOJA) >= MV_PAR05+MV_PAR06 .AND. LIT->(LIT_CLIENT+LIT_LOJA) <= MV_PAR07+MV_PAR08 ) 
			//
			// cliente
			//
			dbSelectArea("SA1")
			dbSetOrder(1) // A1_FILIAL+A1_COD+A1_LOJA
			If dbSeek(xFilial("SA1")+LIT->(LIT_CLIENT+LIT_LOJA))
			
				aContrato := Array(12)
				aGrpTit   := {}
				aTotGeral := Array(11)
				aFill(aTotGeral,0)
				aTotais   := {}
				nVlrContrat := 0
				
				// codigo/loja/nome do cliente
				aContrato[ 1] := SA1->A1_COD
				aContrato[ 2] := SA1->A1_LOJA
				aContrato[ 3] := SA1->A1_NOME
						
				// numero/Data/status do contrato
				aContrato[ 4] := LIT->LIT_NCONTR
				Do Case
					Case LIT->LIT_STATUS == "1"
						aContrato[ 5] := STR0032 //"Em Aberto"
					Case LIT->LIT_STATUS == "2"
						aContrato[ 5] := STR0033 //"Encerrado"
					Case LIT->LIT_STATUS == "3"
						aContrato[ 5] := STR0034 //"Cancelado"
					Case LIT->LIT_STATUS == "4"
						aContrato[ 5] := STR0043 //"Cessão de direito"
					Otherwise
						aContrato[ 5] := STR0035 //"Desconhecido"
				EndCase
				
				aContrato[ 6] := dtoc(LIT->LIT_EMISSA)
				
				// valor original do contrato
				aContrato[7] := Transform( LIT->LIT_VALBRU ,x3Picture("LIT_VALBRU"))
				
				// Itens do Contrato
				aContrato[9] := {}
				// Titulos a receber 
				aContrato[10] := {}
				
				lContinua := .F.
				
				// Itens do Contrato
				dbSelectArea("LIU")
				LIU->(dbSetOrder(3)) //LIU_FILIAL+LIU_NCONTR+LIU_COD+LIU_ITEM
				LIU->(dbSeek(xFilial("LIU")+LIT->(LIT_NCONTR), .T.))
				While LIU->(!EOF()) .AND. (LIU->(LIU_FILIAL+LIU_NCONTR) == LIT->(xFilial("LIT")+LIT->LIT_NCONTR))
					If (LIU->LIU_CODEMP >= MV_PAR03 .And. LIU->LIU_CODEMP <= MV_PAR04)
					// Unidades
					dbSelectArea("LIQ")
					dbSetOrder(1) // LIQ_FILIAL+LIQ_COD
						If dbSeek(xFilial("LIQ")+LIU->LIU_CODEMP)
					
				  		// se for a unidade do empreendimento
						If LK3->(LK3_CODEMP)==LIQ->(LIQ_CODEMP) .AND. !lContinua
							lContinua := .T.
						EndIf
						aAdd( aContrato[9],{})
						// unidade vendida
						aAdd( aContrato[9][Len(aContrato[9])],LIQ->LIQ_COD )
						aAdd( aContrato[9][Len(aContrato[9])],LIQ->LIQ_DESC )
						//Empreendimento
						aAdd( aContrato[9][Len(aContrato[9])],LK3->LK3_CODEMP )
						aAdd( aContrato[9][Len(aContrato[9])],LK3->LK3_DESCRI )
						
						dHabite := iIf( !Empty( LIQ->LIQ_HABITE) ,LIQ->LIQ_HABITE ,LIQ->LIQ_PREVHB )
						EndIf
				    EndIf
				
				LIU-> ( dbSkip() )
				EndDo
				
				If lContinua 
					// Detalhes do Titulos a receber
					dbSelectArea("LIX")
					dbSetOrder(3) // LIX_FILIAL+LIX_NCONTR+LIX_PREFIX+LIX_NUM+LIX_PARCEL+LIX_TIPO
					dbSeek(xFilial("LIX")+LIT->LIT_NCONTR)
					While LIX->(!EOF()) .AND. LIX->(LIX_FILIAL+LIX_NCONTR)==xFilial("LIX")+LIT->LIT_NCONTR
						
						IncProc(STR0002+STR0013+" "+LIT->LIT_NCONTR) //"Processando..."+"Contrato"
						nCntRegua++
						If nCntRegua == 100
							ProcRegua(100)
							nCntRegua := 0
						EndIf
						
						//
						// Retorna um array com os dados detalhados do titulo a receber 
						//
						//	aTitulo[01] - Situacao do titulo: recebido/Atrasado/A Receber 
						//	aTitulo[02] - Parcela (aaa/bbb/-cc)
						//	aTitulo[03] - Descricao do tipo de parcela
						//	aTitulo[04] - data de vencimento
						//	aTitulo[05] - Data da baixa
						//	aTitulo[06] - Valor Recebido
						//	aTitulo[07] - Valor do Titulo
						//	aTitulo[08] - Valor Principal Original
						//	aTitulo[09] - Correcao monetaria do Valor Principal 
						//	aTitulo[10] - Valor Juros Fcto Original
						//	aTitulo[11] - Correcao monetaria do Valor Juros Fcto 
						//	aTitulo[12] - Pro rata
						//	aTitulo[13] - Juros Mora
						//	aTitulo[14] - Multa
						//	aTitulo[15] - Desconto
						//	aTitulo[16] - Valor Atualizado
						//	aTitulo[17] - Taxa
						//
						aTitulo := t_GMCalcTit(	LIT->LIT_NCONTR ,LIX->LIX_PREFIX ,LIX->LIX_NUM ,;
														LIX->LIX_PARCEL ,LIX->LIX_TIPO ,LIT->LIT_EMISSA ,dHabite ,;
														LIT->LIT_JURMOR ,LIT->LIT_MULTA ,LIT->LIT_JURTIP ,(MV_PAR11==1) ,dDatabase )
						If !Empty(aTitulo)
						
							If (nPos:=aScan( aTotais ,{|x| x[1] == aTitulo[1]} ))<=0 
								aAdd(aTotais,Array(12))
								nPos := len(aTotais)
								aFill( aTotais[nPos],0)
								aTotais[nPos][1] := aTitulo[1]
							EndIf
								
							// Houve baixa total/parcial da parcela
							If aTitulo[06] > 0 
								// se diferente de 1, houve baixa parcial 
								If aTitulo[01] <> 1
									// se naum existir totalizador de recebido, cria
									If (nPos1:=aScan( aTotais ,{|x| x[1] == 1 } ))<=0 
										aAdd(aTotais,Array(12))
										nPos1 := len(aTotais)
										aFill( aTotais[nPos1],0)
										aTotais[nPos1][1] := 1
									EndIf
									aTotais[nPos1][ 2] += aTitulo[ 6]
								Else
									aTotais[nPos][ 2] += aTitulo[ 6]
								EndIf
							EndIf 

							aTotais[nPos][ 3] += aTitulo[ 7]
							aTotais[nPos][ 4] += aTitulo[ 8]
							aTotais[nPos][ 5] += aTitulo[ 9]
							aTotais[nPos][ 6] += aTitulo[10]
							aTotais[nPos][ 7] += aTitulo[11]
							aTotais[nPos][ 8] += aTitulo[12]
							aTotais[nPos][ 9] += aTitulo[13]
							aTotais[nPos][10] += aTitulo[14]
							aTotais[nPos][11] += aTitulo[15]
							aTotais[nPos][12] += aTitulo[16]
						
							//
							// se nao for um titulo renegocia, acumula para obter o valor atual do contrato
							//
							If !(aTitulo[1]==2)
								// Valor Principal + CM
								nVlrContrat += aTitulo[ 8]+aTitulo[ 9]
							EndIf
							
							For nCount := 6 To 16
								aTitulo[nCount] := Transform(aTitulo[nCount] ,x3Picture("E1_VALOR"))
							Next nCount
						               
					    	aAdd( aGrpTit , aTitulo)
						EndIf
						
						dbSelectArea("LIX")
						dbSkip()
					EndDo
					
					//
					//  totalizar por tipo de parcela
					//
					For nCount := 1 To len(aTotais)
						// Acumula os totais dos tipos de parcelas
						aTotGeral[ 1] += aTotais[nCount][ 2]
						aTotGeral[ 2] += aTotais[nCount][ 3]
						aTotGeral[ 3] += aTotais[nCount][ 4]
						aTotGeral[ 4] += aTotais[nCount][ 5]
						aTotGeral[ 5] += aTotais[nCount][ 6]
						aTotGeral[ 6] += aTotais[nCount][ 7]
						aTotGeral[ 7] += aTotais[nCount][ 8]
						aTotGeral[ 8] += aTotais[nCount][ 9]
						aTotGeral[ 9] += aTotais[nCount][10]
						aTotGeral[10] += aTotais[nCount][11]
						aTotGeral[11] += aTotais[nCount][12]
						
						//
						// Formata os valores dos totais por tipo de parcelas
						//
						aTotais[nCount][ 2] := Transform(aTotais[nCount][ 2] ,x3Picture("E1_VALOR")) // Valor do Titulo
						aTotais[nCount][ 3] := Transform(aTotais[nCount][ 3] ,x3Picture("E1_SALDO")) // Valor Pago
						aTotais[nCount][ 4] := Transform(aTotais[nCount][ 4] ,x3Picture("E1_VALOR")) // Valor Principal
						aTotais[nCount][ 5] := Transform(aTotais[nCount][ 5] ,x3Picture("E1_VALOR")) // CM Principal
						aTotais[nCount][ 6] := Transform(aTotais[nCount][ 6] ,x3Picture("E1_VALOR")) // Juros
						aTotais[nCount][ 7] := Transform(aTotais[nCount][ 7] ,x3Picture("E1_VALOR")) // Cm Juros
						aTotais[nCount][ 8] := Transform(aTotais[nCount][ 8] ,x3Picture("E1_VALOR")) // Pro Rata
						aTotais[nCount][ 9] := Transform(aTotais[nCount][ 9] ,x3Picture("E1_VALOR")) // Multa
						aTotais[nCount][10] := Transform(aTotais[nCount][10] ,x3Picture("E1_VALOR")) // Juros Mora
						aTotais[nCount][11] := Transform(aTotais[nCount][11] ,x3Picture("E1_VALOR")) // desconto
						aTotais[nCount][12] := Transform(aTotais[nCount][12] ,x3Picture("E1_VALOR")) // valor total atualizado
						
					Next nCount
					
					//
					//  totalizar por contrato
					//
					For nCount := 1 To len(aTotGeral)
						aTotGeral[nCount] := Transform(aTotGeral[nCount] ,x3Picture("E1_VALOR"))
					Next nCount
					
					If MV_PAR12 == 1
						// ordena os titulos por tipo(recebida/renegociada/atrasada/a pagar) e por data de vencimento
						aSort( aGrpTit,,,{|x,y| str(x[1],2)+dtos(ctod(x[4])) < str(y[1],2)+dtos(ctod(y[4])) })
					Else
						// ordena os titulos por tipo(recebida/renegociada/atrasada/a pagar) e por data de pagamento e por data de vencimento
						aSort( aGrpTit,,,{|x,y| str(x[1],2)+dtos(ctod(x[5]))+dtos(ctod(x[4])) < str(y[1],2)+dtos(ctod(y[5]))+dtos(ctod(y[4])) })
					EndIf
					
					// valor atual do contrato
					aContrato[8] := Transform( nVlrContrat ,x3Picture("E1_VALOR"))
					
					aContrato[10] := aGrpTit
					aContrato[11] := aTotais
					aContrato[12] := aTotGeral
					
					aAdd( aItens ,aContrato )
				EndIf
		    EndIf
		EndIf
	
		dbSelectArea("LIT")
		dbSkip()
	EndDo
   
	dbSelectArea("LK3")
	dbSkip()
EndDo
	
Return( .T. )


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    | RGBConv   ³ Autor ³ Reynaldo Miyashita     ³ Data ³ 05.08.2005 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Converte os valores do RBG para o valor numerico da cor        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³Generico                                                        ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function RGBConv(nRed ,nGreen ,nBlue)
Return( T_GEMRGB(nRed ,nGreen ,nBlue) )

Static Function AjustaSX1

Local cAlias   := Alias()
Local aCposSX1 := {}
Local aRegs    := {}
Local nX       := 0
Local nJ       := 0
Local cPerg    := PadR ( "GMR020", Len( SX1->X1_GRUPO ) )
                         
aCposSX1 := {"X1_ORDEM","X1_PERGUNT","X1_PERSPA","X1_PERENG","X1_VARIAVL","X1_TIPO","X1_TAMANHO",;
             "X1_DECIMAL","X1_PRESEL","X1_GSC","X1_VALID","X1_VAR01","X1_DEF01","X1_DEF02","X1_DEFSPA1",;
             "X1_DEFENG1","X1_VAR02","X1_DEFSPA2","X1_DEFENG2",;
             "X1_VAR03","X1_DEF03","X1_DEFSPA3","X1_DEFENG3","X1_F3","X1_PYME","X1_CNT01"}

aAdd(aRegs,{"12","Ordenar por?"       ,"","","mv_chC","N",01                     ,00,0,"C",""          ,"mv_par12","Data de Vencto.","Data de Baixa","","","","","","","","","","","",""})

dbSelectArea("SX1")
dbSetOrder(1) // X1_GRUPO+X1_ORDEM
For nX := 1 to Len(aRegs)
	If !(dbSeek(cPerg+aRegs[nX][1]))
		RecLock("SX1",.T.)
		Replace X1_GRUPO with cPerg
		For nJ := 1 to Len(aCposSX1)
			If FieldPos(Alltrim(aCposSX1[nJ])) > 0
				FieldPut(FieldPos(Alltrim(aCposSX1[nJ])),aRegs[nX][nJ])
			EndIf
		Next nJ
		MsUnlock()
	EndIf		
Next

dbSelectArea(cAlias)
Return

