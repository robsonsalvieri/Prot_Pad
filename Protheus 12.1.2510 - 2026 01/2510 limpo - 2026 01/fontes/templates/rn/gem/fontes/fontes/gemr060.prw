#INCLUDE "protheus.ch" 
#INCLUDE "gemr060.ch"

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³GEMR060   ³ Autor ³ Reynaldo Miyashita    ³ Data ³ 06.02.06 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Extrato do Empreendimento/Cliente Simplificado              ³±±
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
/*/
Template Function GEMR060()
Local aArea		:= GetArea()
Local lOk		:= .F.
Local lEnd

Private nLin    := 280

// Valida se tem licenças para o Template GEM = Gestao de Empreendimentos Imobiliarios							 
ChkTemplate("LOT")

AjustaSX1()

oPrint := PcoPrtIni(STR0001,.F.,2,,@lOk,"GMR060") //"Extrato de Contrato Simplificado"

If lOk
	RptStatus( {|lEnd| GMR060Imp(@lEnd,oPrint)})
	PcoPrtEnd(oPrint)
EndIf

RestArea(aArea)

Return( .T. )

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o	 ³ GMR060Imp ³ Autor ³ Reynaldo              ³ Data ³ 01.06.92 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Imprime relat¢rio                                           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ lEnd    - A‡Æo do Codeblock                                 ³±±
±±³			 ³ oPrint  - objeto da impressao                               ³±±
±±³			 ³ cString - Mensagem                                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso		 ³ Generico                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function GMR060Imp( lEnd, oPrint )
Local aItens    := {}
Local nLin      := 0
Local nCount    := 0
Local nCount2   := 0
Local aTamCols  := {}
Local nDecs	    := GetMv("MV_CENT")
Local cImpAtual := STR0058

aTamCols := Array(8)
aTamCols[1] := TamToCols( { 300 ,100 ,1980 } ,10 ) // dados do cliente
aTamCols[7] := TamToCols( { 300 ,100 ,900 ,400 ,680 } ,10 ) // dados dos solidarios
aTamCols[2] := TamToCols( { 300 ,800 ,130 ,300 ,450 ,400 } ,10 ) // dados do contrato
aTamCols[3] := TamToCols( { 300 ,800 ,130 ,300 ,850 } ,10 ) // dados do empreendimento II
aTamCols[8] := TamToCols( { 100 ,200 ,215 ,205 ,200 ,200 ,170 ,235 ,190 ,170 ,130 ,115 , 135, 115 } ,10 ) // formas de pagamento
aTamCols[4] := TamToCols( { 180 ,200 ,210 ,200 ,200 ,210 ,200 ,200 ,200 ,190 ,290 ,100 } ,10 ) // dados dos titulos
aTamCols[5] := TamToCols( {2380} ,10 ) // status dos titulos
aTamCols[6] := TamToCols( { 790 ,200 ,210 ,200 ,200 ,200 ,190 ,290 } ,10 ) // totais
            
//
// Filtra as informacoes
//
Processa({||GMR060Ini(@aItens)},STR0002) //"Processando..."
	
	
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Imprime os dados.             ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If (Len(aItens) > 0)
	
	For nCount := 1 To Len(aItens)
      
		//*********Condicao de venda***********
		cImpAtual := STR0058
		nLin := 0
		R060Cab( @oPrint, @nLin, aItens ,nCount, aTamCols, cImpAtual , .T. )
		
		For nCount2 := 1 To len(aItens[nCount][14])

			R060Cab( @oPrint, @nLin, aItens ,nCount, aTamCols , cImpAtual , .F. )

			// Definicao das colunas das condicoes de venda
			PcoPrtCell(PcoPrtPos( 1),nLin,PcoPrtTam( 1),50,aItens[nCount][14][nCount2][ 1] ,oPrint,2,8)       //"Item"
			PcoPrtCell(PcoPrtPos( 2),nLin,PcoPrtTam( 2),50,aItens[nCount][14][nCount2][ 2] ,oPrint,2,8,,,.T.) //"Qtd. Parcelas"
			PcoPrtCell(PcoPrtPos( 3),nLin,PcoPrtTam( 3),50,aItens[nCount][14][nCount2][ 3] ,oPrint,2,8,,,.T.) //"Valor Parcela"
			PcoPrtCell(PcoPrtPos( 4),nLin,PcoPrtTam( 4),50,aItens[nCount][14][nCount2][ 4] ,oPrint,2,8,,,.T.) //"Valor Total"   
			PcoPrtCell(PcoPrtPos( 5),nLin,PcoPrtTam( 5),50,aItens[nCount][14][nCount2][ 5] ,oPrint,2,8)       //"Tipo Parcela"
			PcoPrtCell(PcoPrtPos( 6),nLin,PcoPrtTam( 6),50,aItens[nCount][14][nCount2][ 6] ,oPrint,2,8)       //"Descrição"
			PcoPrtCell(PcoPrtPos( 7),nLin,PcoPrtTam( 7),50,aItens[nCount][14][nCount2][ 7] ,oPrint,2,8)       //"1o. Venc."
			PcoPrtCell(PcoPrtPos( 8),nLin,PcoPrtTam( 8),50,aItens[nCount][14][nCount2][ 8] ,oPrint,2,8)       //"Tipo Sistema"
			PcoPrtCell(PcoPrtPos( 9),nLin,PcoPrtTam( 9),50,aItens[nCount][14][nCount2][ 9] ,oPrint,2,8,,,.T.) //"Taxa Anual"
			PcoPrtCell(PcoPrtPos(10),nLin,PcoPrtTam(10),50,aItens[nCount][14][nCount2][10] ,oPrint,2,8,,,.T.) //"Coeficiente"
			PcoPrtCell(PcoPrtPos(11),nLin,PcoPrtTam(11),50,aItens[nCount][14][nCount2][11] ,oPrint,2,8)       //"Ind.Pre"
			PcoPrtCell(PcoPrtPos(12),nLin,PcoPrtTam(12),50,aItens[nCount][14][nCount2][12] ,oPrint,2,8,,,.T.) //"Meses"
			PcoPrtCell(PcoPrtPos(13),nLin,PcoPrtTam(13),50,aItens[nCount][14][nCount2][13] ,oPrint,2,8)       //"Ind.Pos"
			PcoPrtCell(PcoPrtPos(14),nLin,PcoPrtTam(14),50,aItens[nCount][14][nCount2][14] ,oPrint,2,8,,,.T.) //"Meses"
			nLin+=50

		Next nCount2
		
		//*********Titulos***********		
		cImpAtual := STR0059
		R060Cab( @oPrint, @nLin, aItens ,nCount, aTamCols, cImpAtual , .T. )
		nTipoParcela := 0
		For nCount2 := 1 To len(aItens[nCount][10])

			R060Cab( @oPrint, @nLin, aItens ,nCount, aTamCols , cImpAtual , .F. )

			If nTipoParcela <> aItens[nCount][10][nCount2][1]
				Do Case 
					// titulos recebidos
					Case aItens[nCount][10][nCount2][1] == 1
						// Definicao das colunas do Status da parcela
						PcoPrtCol(aTamCols[5],.T.,len(aTamCols[5]))
						PcoPrtCell(PcoPrtPos( 1),nLin,PcoPrtTam( 1),90,STR0003,oPrint,2,3) //"PARCELAS RECEBIDAS"
					// titulos renegociados
					Case aItens[nCount][10][nCount2][1] == 2
						// Definicao das colunas do Status da parcela
						PcoPrtCol(aTamCols[5],.T.,len(aTamCols[5]))
						PcoPrtCell(PcoPrtPos( 1),nLin,PcoPrtTam( 1),90,STR0004,oPrint,2,3) //"Parcelas Renegociadas"
					// titulos Atrasados
					Case aItens[nCount][10][nCount2][1] == 3
						// Definicao das colunas do Status da parcela
						PcoPrtCol(aTamCols[5],.T.,Len(aTamCols[5]))
						PcoPrtCell(PcoPrtPos( 1),nLin,PcoPrtTam( 1),90,STR0005,oPrint,2,3) //"PARCELAS ATRASADAS"
					// titulos a receber
					Case aItens[nCount][10][nCount2][1] == 4
						// Definicao das colunas do Status da parcela
						PcoPrtCol(aTamCols[5],.T.,len(aTamCols[5]))
						PcoPrtCell(PcoPrtPos( 1),nLin,PcoPrtTam( 1),90,STR0006,oPrint,2,3) //"PARCELAS A RECEBER"
					// titulos transferidos
					Case aItens[nCount][10][nCount2][1] == 5
						// Definicao das colunas do Status da parcela
						PcoPrtCol(aTamCols[5],.T.,len(aTamCols[5]))
						PcoPrtCell(PcoPrtPos( 1),nLin,PcoPrtTam( 1),90,STR0060,oPrint,2,3)     //"PARCELAS TRANSFERIDAS"
						
				EndCase
				nLin+=90
				nTipoParcela := aItens[nCount][10][nCount2][1]
			EndIf
			// Definicao das colunas dos titulos a receber
			PcoPrtCol(aTamCols[4],.T.,len(aTamCols[4]))
			PcoPrtCell(PcoPrtPos( 1),nLin,PcoPrtTam( 1),50,aItens[nCount][10][nCount2][ 2] ,oPrint,2,8)
			PcoPrtCell(PcoPrtPos( 2),nLin,PcoPrtTam( 2),50,aItens[nCount][10][nCount2][ 3] ,oPrint,2,8)
			PcoPrtCell(PcoPrtPos( 3),nLin,PcoPrtTam( 3),50,aItens[nCount][10][nCount2][ 4] ,oPrint,2,8)
			PcoPrtCell(PcoPrtPos( 4),nLin,PcoPrtTam( 4),50,aItens[nCount][10][nCount2][ 5] ,oPrint,2,8)       // "Data Baixa"     
			PcoPrtCell(PcoPrtPos( 5),nLin,PcoPrtTam( 5),50,aItens[nCount][10][nCount2][ 6] ,oPrint,2,8,,,.T.) // "Valor Pago"     
			PcoPrtCell(PcoPrtPos( 6),nLin,PcoPrtTam( 6),50,aItens[nCount][10][nCount2][ 7] ,oPrint,2,8,,,.T.) // "Valor Titulo"   
			PcoPrtCell(PcoPrtPos( 7),nLin,PcoPrtTam( 7),50,aItens[nCount][10][nCount2][ 8] ,oPrint,2,8,,,.T.) // "Principal"      
			PcoPrtCell(PcoPrtPos( 8),nLin,PcoPrtTam( 8),50,aItens[nCount][10][nCount2][ 9] ,oPrint,2,8,,,.T.) // "Juros"           
			PcoPrtCell(PcoPrtPos( 9),nLin,PcoPrtTam( 9),50,aItens[nCount][10][nCount2][10] ,oPrint,2,8,,,.T.) // "Penalidades"    
			PcoPrtCell(PcoPrtPos(10),nLin,PcoPrtTam(10),50,aItens[nCount][10][nCount2][11] ,oPrint,2,8,,,.T.) // "Descontos       
			PcoPrtCell(PcoPrtPos(11),nLin,PcoPrtTam(11),50,aItens[nCount][10][nCount2][12] ,oPrint,2,8,,,.T.) //"Valor Atualizado"
			PcoPrtCell(PcoPrtPos(12),nLin,PcoPrtTam(12),50,aItens[nCount][10][nCount2][13] ,oPrint,2,8)       //"Taxa"            
			nLin+=50

		Next nCount2		

		//*********sub totais do contrato***********
		cImpAtual := STR0061
		For nCount2 := 1 To len(aItens[nCount][11])
		
			R060Cab( @oPrint, @nLin, aItens ,nCount, aTamCols, cImpAtual , .F. )
			
			// Definicao das colunas dos totais por status dos titulos a receber
			PcoPrtCol(aTamCols[6],.T.,len(aTamCols[6]))
			Do Case 
				// recebidas
				Case aItens[nCount][11][nCount2][1] == 1
					PcoPrtCell(PcoPrtPos( 1),nLin,PcoPrtTam( 1),50,STR0007,oPrint,2,3) //"RECEBIDAS"
				//renegociadas
				Case aItens[nCount][11][nCount2][1] == 2
					PcoPrtCell(PcoPrtPos( 1),nLin,PcoPrtTam( 1),50,STR0008,oPrint,2,3) //"Renegociadas"
				//atrasadas
				Case aItens[nCount][11][nCount2][1] == 3
					PcoPrtCell(PcoPrtPos( 1),nLin,PcoPrtTam( 1),50,STR0009,oPrint,2,3) //"ATRASADAS"
				// a receber
				Case aItens[nCount][11][nCount2][1] == 4
					PcoPrtCell(PcoPrtPos( 1),nLin,PcoPrtTam( 1),50,STR0010,oPrint,2,3) //"A RECEBER"
				// Transferidas
				Case aItens[nCount][11][nCount2][1] == 5
					PcoPrtCell(PcoPrtPos( 1),nLin,PcoPrtTam( 1),50,STR0062,oPrint,2,3)  // TRANSFERIDAS
			EndCase
			
			PcoPrtCell(PcoPrtPos( 2),nLin,PcoPrtTam( 2),50,aItens[nCount][11][nCount2][ 2],oPrint,2,2,,,.T.)  // "Valor Pago"     
			PcoPrtCell(PcoPrtPos( 3),nLin,PcoPrtTam( 3),50,aItens[nCount][11][nCount2][ 3],oPrint,2,2,,,.T.)  // "Valor Titulo"   
			PcoPrtCell(PcoPrtPos( 4),nLin,PcoPrtTam( 4),50,aItens[nCount][11][nCount2][ 4],oPrint,2,2,,,.T.)  // "Principal"      
			PcoPrtCell(PcoPrtPos( 5),nLin,PcoPrtTam( 5),50,aItens[nCount][11][nCount2][ 5],oPrint,2,2,,,.T.)  // "Juros"                              
			PcoPrtCell(PcoPrtPos( 6),nLin,PcoPrtTam( 6),50,aItens[nCount][11][nCount2][ 6],oPrint,2,2,,,.T.)  // "Penalidades"    
			PcoPrtCell(PcoPrtPos( 7),nLin,PcoPrtTam( 7),50,aItens[nCount][11][nCount2][ 7],oPrint,2,2,,,.T.)  // "Descontos       
			PcoPrtCell(PcoPrtPos( 8),nLin,PcoPrtTam( 8),50,aItens[nCount][11][nCount2][ 8],oPrint,2,2,,,.T.)  //"Valor Atualizado"
			nLin+=50                                                                                          
		                                                                                                            
		Next nCount2                                                                                                
		                                                                                                            
		//*********Total Geral do Contrato***********
		// Definicao das colunas dos totais por status dos titulos a receber
		PcoPrtCol(aTamCols[6],.T.,len(aTamCols[6]))                         
		PcoPrtCell(PcoPrtPos( 1),nLin,PcoPrtTam( 1),50,STR0011,oPrint,2,3) //"TOTAL GERAL"
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

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³R060Cab    ³ Autor ³Reynaldo                  ³ Data ³          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Impressao dos cabecalhos                                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³Nenhum                                                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³oPrint : objeto da impressao                                    ³±±
±±³          |nLin : linha atual da impressao                                 ³±±
±±³          ³aItens : array com todos os dados a serem impressos             ³±±
±±³          ³nCount : posicao do array que contem os dados a serem impressos ³±±
±±³          ³aTamCols : array com os tamanhos das celulas                    ³±±
±±³          ³cImpAtual : define qual registro esta sendo impresso para       ³±±
±±³          ³         imprimir o cabecalho correto("CondVenda"/"Titulo")     ³±±
±±³          ³cImpItem : define se deve imprimir forcado o cabecalho dos itens³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³   DATA   ³ Programador   ³Manutencao efetuada                             ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function R060Cab( oPrint, nLin, aItens ,nCount, aTamCols, cImpAtual, lImpItem)
Local nCount2  := 0
Local cRelacao := ""

	If PcoPrtLim(nLin) .Or. nLin == 0
	    //
	    // Imprime o cabecalho do relatorio
	    // 
		nLin:=280
		PcoPrtCab(oPrint)                      
		
		// Definicao das colunas do Cabecalho do relatorio sobre cliente, loja e nome do cliente
		PcoPrtCol(aTamCols[1],.T.,len(aTamCols[1]))
	
		// Cabecalho sobre cliente, loja e nome do cliente
		PcoPrtCell(PcoPrtPos(1),nLin,PcoPrtTam(1),60,STR0012,oPrint,2,4,RGBConv(230,230,230)) //"Cliente"
		PcoPrtCell(PcoPrtPos(2),nLin,PcoPrtTam(2),60,STR0013,oPrint,2,4,RGBConv(230,230,230)) //"Loja"
		PcoPrtCell(PcoPrtPos(3),nLin,PcoPrtTam(3),60,STR0014,oPrint,2,4,RGBConv(230,230,230)) //"Nome"
		nLin+=60
		PcoPrtCell(PcoPrtPos(1),nLin,PcoPrtTam(1),50,aItens[nCount][1],oPrint,2,8) 
		PcoPrtCell(PcoPrtPos(2),nLin,PcoPrtTam(2),50,aItens[nCount][2],oPrint,2,8) 
		PcoPrtCell(PcoPrtPos(3),nLin,PcoPrtTam(3),50,aItens[nCount][3],oPrint,2,8)
		nLin+=100

		If !Empty(aItens[nCount][13])
			// Definicao das colunas do Cabecalho  sobre os solidarios
			PcoPrtCol(aTamCols[7],.T.,len(aTamCols[7]))
			// Cabecalho sobre solidarios
			PcoPrtCell(PcoPrtPos(1),nLin,PcoPrtTam(1),60,STR0015,oPrint,2,4,RGBConv(230,230,230)) //"Solidário"
			PcoPrtCell(PcoPrtPos(2),nLin,PcoPrtTam(2),60,STR0013,oPrint,2,4,RGBConv(230,230,230)) //"Loja"
			PcoPrtCell(PcoPrtPos(3),nLin,PcoPrtTam(3),60,STR0014,oPrint,2,4,RGBConv(230,230,230)) //"Nome"
			PcoPrtCell(PcoPrtPos(4),nLin,PcoPrtTam(4),60,STR0016,oPrint,2,4,RGBConv(230,230,230)) //"CPF/CNPJ"
			PcoPrtCell(PcoPrtPos(5),nLin,PcoPrtTam(5),60,STR0017,oPrint,2,4,RGBConv(230,230,230)) //"Relação"
			nLin+=60
			
			For nCount2 := 1 To len(aItens[nCount][13])
				cRelacao := X3Combo( "LK6_GRAU" , aItens[nCount][13][nCount2][5] )
				PcoPrtCell(PcoPrtPos(1),nLin,PcoPrtTam(1),50,aItens[nCount][13][nCount2][1],oPrint,2,8) 
				PcoPrtCell(PcoPrtPos(2),nLin,PcoPrtTam(2),50,aItens[nCount][13][nCount2][2],oPrint,2,8) 
				PcoPrtCell(PcoPrtPos(3),nLin,PcoPrtTam(3),50,aItens[nCount][13][nCount2][3],oPrint,2,8) 
				PcoPrtCell(PcoPrtPos(4),nLin,PcoPrtTam(4),50,aItens[nCount][13][nCount2][4],oPrint,2,8)
				PcoPrtCell(PcoPrtPos(5),nLin,PcoPrtTam(5),50,cRelacao,oPrint,2,8) 
				nLin+=50
			Next nCount2
			nLin+=50
		EndIf
	
		// Definicao das colunas do Cabecalho sobre contrato, Status, Data do contrato e valor original e atual do contrato
		PcoPrtCol(aTamCols[2],.T.,len(aTamCols[2]))
		
		PcoPrtCell(PcoPrtPos(1),nLin,PcoPrtTam(1),60,STR0018,oPrint,2,4,RGBConv(230,230,230)) //"Contrato"
		PcoPrtCell(PcoPrtPos(2),nLin,PcoPrtTam(2),60,STR0019,oPrint,2,4,RGBConv(230,230,230)) //"Status"
		PcoPrtCell(PcoPrtPos(3),nLin,PcoPrtTam(3),60,""     ,oPrint,0,4,RGBConv(230,230,230)) 
		PcoPrtCell(PcoPrtPos(4),nLin,PcoPrtTam(4),60,STR0020,oPrint,2,4,RGBConv(230,230,230)) //"Data Contrato"
		PcoPrtCell(PcoPrtPos(5),nLin,PcoPrtTam(5),60,STR0021,oPrint,2,4,RGBConv(230,230,230)) //"Valor Original Contrato"
		PcoPrtCell(PcoPrtPos(6),nLin,PcoPrtTam(6),60,STR0022,oPrint,2,4,RGBConv(230,230,230)) //"Valor Atual Contrato"
		nLin+=60
		PcoPrtCell(PcoPrtPos(1),nLin,PcoPrtTam(1),50,aItens[nCount][4],oPrint,2,8) 
		PcoPrtCell(PcoPrtPos(2),nLin,PcoPrtTam(2),50,aItens[nCount][5],oPrint,2,8) 
		PcoPrtCell(PcoPrtPos(3),nLin,PcoPrtTam(3),50,""               ,oPrint,0,8) 
		PcoPrtCell(PcoPrtPos(4),nLin,PcoPrtTam(4),50,aItens[nCount][6],oPrint,2,8) 
		PcoPrtCell(PcoPrtPos(5),nLin,PcoPrtTam(5),50,aItens[nCount][7],oPrint,2,8,,,.T.)  //valor original do contrato
		PcoPrtCell(PcoPrtPos(6),nLin,PcoPrtTam(6),50,IIF(MV_PAR09==1,aItens[nCount][12][2],aItens[nCount][8]),oPrint,2,8,,,.T.)  //Valor atual do contrato
		nLin+=100

		// Definicao das colunas do Cabecalho do empreendimento adquirido
		PcoPrtCol(aTamCols[1],.T.,len(aTamCols[1]))
		// Cabecalho com as informacoes do Empreendimento referente ao contrato
		PcoPrtCol(aTamCols[3],.T.,len(aTamCols[3]))
		PcoPrtCell(PcoPrtPos(1),nLin,PcoPrtTam(1),60,STR0023,oPrint,2,4,RGBConv(230,230,230)) //"Unidade"
		PcoPrtCell(PcoPrtPos(2),nLin,PcoPrtTam(2),60,STR0024,oPrint,2,4,RGBConv(230,230,230)) //"Descrição"
		PcoPrtCell(PcoPrtPos(3),nLin,PcoPrtTam(3),60,""     ,oPrint,0,4,RGBConv(230,230,230)) 
		PcoPrtCell(PcoPrtPos(4),nLin,PcoPrtTam(4),60,STR0025,oPrint,2,4,RGBConv(230,230,230)) //"Empreendimento"
		PcoPrtCell(PcoPrtPos(5),nLin,PcoPrtTam(5),60,STR0026,oPrint,2,4,RGBConv(230,230,230)) //"Descrição"
		nLin+=60
		
		For nCount2 := 1 to len(aItens[nCount][9])
			PcoPrtCell(PcoPrtPos(1),nLin,PcoPrtTam(1),50,aItens[nCount][9][nCount2][1],oPrint,2,8) 
			PcoPrtCell(PcoPrtPos(2),nLin,PcoPrtTam(2),50,aItens[nCount][9][nCount2][2],oPrint,2,8) 
			PcoPrtCell(PcoPrtPos(3),nLin,PcoPrtTam(3),50,""                           ,oPrint,0,8) 
			PcoPrtCell(PcoPrtPos(4),nLin,PcoPrtTam(4),50,aItens[nCount][9][nCount2][3],oPrint,2,8) 
			PcoPrtCell(PcoPrtPos(5),nLin,PcoPrtTam(5),50,aItens[nCount][9][nCount2][4],oPrint,2,8) 
			nLin+=60
		Next nCount2
		
		lImpItem := .T.
	EndIf


	If lImpItem == .T.
		nLin+=60
		If cImpAtual == STR0058   // CODVENDA
			// Definicao das colunas do Cabecalho das Formas de Pagto
			PcoPrtCol(aTamCols[8],.T.,len(aTamCols[8]))
			// Cabecalho das Formas de Pagto
			PcoPrtCell(PcoPrtPos( 1),nLin,PcoPrtTam( 1),60,STR0043,oPrint,2,4,RGBConv(230,230,230)) //"Item"
			PcoPrtCell(PcoPrtPos( 2),nLin,PcoPrtTam( 2),60,STR0044,oPrint,2,4,RGBConv(230,230,230)) //"Qtd. Parcelas"
			PcoPrtCell(PcoPrtPos( 3),nLin,PcoPrtTam( 3),60,STR0045,oPrint,2,4,RGBConv(230,230,230)) //"Valor Parcela"
			PcoPrtCell(PcoPrtPos( 4),nLin,PcoPrtTam( 4),60,STR0046,oPrint,2,4,RGBConv(230,230,230)) //"Valor Total"
			PcoPrtCell(PcoPrtPos( 5),nLin,PcoPrtTam( 5),60,STR0047,oPrint,2,4,RGBConv(230,230,230)) //"Tipo Parcela"
			PcoPrtCell(PcoPrtPos( 6),nLin,PcoPrtTam( 6),60,STR0048,oPrint,2,4,RGBConv(230,230,230)) //"Descrição"
			PcoPrtCell(PcoPrtPos( 7),nLin,PcoPrtTam( 7),60,STR0049,oPrint,2,4,RGBConv(230,230,230)) //"1o. Venc."
			PcoPrtCell(PcoPrtPos( 8),nLin,PcoPrtTam( 8),60,STR0050,oPrint,2,4,RGBConv(230,230,230)) //"Tipo Sistema"
			PcoPrtCell(PcoPrtPos( 9),nLin,PcoPrtTam( 9),60,STR0051,oPrint,2,4,RGBConv(230,230,230)) //"Taxa Anual"
			PcoPrtCell(PcoPrtPos(10),nLin,PcoPrtTam(10),60,STR0052,oPrint,2,4,RGBConv(230,230,230)) //"Coeficiente"
			PcoPrtCell(PcoPrtPos(11),nLin,PcoPrtTam(11),60,STR0053,oPrint,2,4,RGBConv(230,230,230)) //"Ind.Pre"
			PcoPrtCell(PcoPrtPos(12),nLin,PcoPrtTam(12),60,STR0054,oPrint,2,4,RGBConv(230,230,230)) //"Meses"
			PcoPrtCell(PcoPrtPos(13),nLin,PcoPrtTam(13),60,STR0055,oPrint,2,4,RGBConv(230,230,230)) //"Ind.Pos"
			PcoPrtCell(PcoPrtPos(14),nLin,PcoPrtTam(14),60,STR0054,oPrint,2,4,RGBConv(230,230,230)) //"Meses"
			nLin+=60
		ElseIf cImpAtual == STR0059 // TITULO
			// Definicao das colunas do Cabecalho dos titulos a receber
			PcoPrtCol(aTamCols[4],.T.,len(aTamCols[4]))
			// Cabecalho dos titulos a receber
			PcoPrtCell(PcoPrtPos( 1),nLin,PcoPrtTam( 1),60,STR0027,oPrint,2,4,RGBConv(230,230,230)) //"Parcela"
			PcoPrtCell(PcoPrtPos( 2),nLin,PcoPrtTam( 2),60,STR0028,oPrint,2,4,RGBConv(230,230,230)) //"Tipo"
			PcoPrtCell(PcoPrtPos( 3),nLin,PcoPrtTam( 3),60,STR0029,oPrint,2,4,RGBConv(230,230,230)) //"Data Vencto"
			PcoPrtCell(PcoPrtPos( 4),nLin,PcoPrtTam( 4),60,STR0030,oPrint,2,4,RGBConv(230,230,230)) //"Data Baixa"
			PcoPrtCell(PcoPrtPos( 5),nLin,PcoPrtTam( 5),60,STR0031,oPrint,2,4,RGBConv(230,230,230)) //"Valor Pago"
			PcoPrtCell(PcoPrtPos( 6),nLin,PcoPrtTam( 6),60,STR0032,oPrint,2,4,RGBConv(230,230,230)) //"Valor Titulo"
			PcoPrtCell(PcoPrtPos( 7),nLin,PcoPrtTam( 7),60,STR0033,oPrint,2,4,RGBConv(230,230,230)) //"Principal"
			PcoPrtCell(PcoPrtPos( 8),nLin,PcoPrtTam( 8),60,STR0034,oPrint,2,4,RGBConv(230,230,230)) //"Juros Fcto"
			PcoPrtCell(PcoPrtPos( 9),nLin,PcoPrtTam( 9),60,STR0035,oPrint,2,4,RGBConv(230,230,230)) //"Penalidade"
			PcoPrtCell(PcoPrtPos(10),nLin,PcoPrtTam(10),60,STR0036,oPrint,2,4,RGBConv(230,230,230)) //"Desconto"
			PcoPrtCell(PcoPrtPos(11),nLin,PcoPrtTam(11),60,STR0037,oPrint,2,4,RGBConv(230,230,230)) //"Valor Atualizado"
			PcoPrtCell(PcoPrtPos(12),nLin,PcoPrtTam(12),60,STR0038,oPrint,2,4,RGBConv(230,230,230)) //"Taxa"
			nLin+=60
		EndIf
	EndIf
	
Return( .T. )

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³GMR060Ini  ³ Autor ³Reynaldo                  ³ Data ³          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Carrega o array que sera utilizado para impressao               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³Nenhum                                                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ aItens : array que sera carregado                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³   DATA   ³ Programador   ³Manutencao efetuada                             ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function GMR060Ini( aItens )

Local nCount      := 0
Local aGrpTit     := {}
Local aTitulo     := {}
Local aTmpTit     := {}
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
Local dUltBaixa   := stod("")
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
Local nVlrCM        := 0 
Local nVlrAtual     := 0
Local aBaixas       := {}
Local cFilSA1       := xFilial("SA1")
Local cFilLK6       := xFilial("LK6")
Local cFilLJN       := xFilial("LJN")
Local cFilSE4       := xFilial("SE4")
Local cFilLIR       := xFilial("LIR")
Local cFilLIS       := xFilial("LIS")
Local cCGC          := ""
Local cNumPed       := ""
Local d1Venc

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
	dbSeek(xFilial("LIT")+MV_PAR07,.T.)
	While LIT->(!eof()) .AND. (LIT->(LIT_FILIAL+LIT_NCONTR) >= xFilial("LIT")+MV_PAR07 .AND. LIT->(LIT_FILIAL+LIT_NCONTR) <= xFilial("LIT")+MV_PAR08 ) 

		If LIT->(LIT_CLIENT+LIT_LOJA) >= MV_PAR03+MV_PAR04 .and. LIT->(LIT_CLIENT+LIT_LOJA) <= MV_PAR05+MV_PAR06
			//
			// cliente
			//
			dbSelectArea("SA1")
			dbSetOrder(1) // A1_FILIAL+A1_COD+A1_LOJA
			If dbSeek(xFilial("SA1")+LIT->(LIT_CLIENT+LIT_LOJA))

				aContrato := Array(14)
				aGrpTit   := {}
				aTotGeral := Array(7)
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
						aContrato[ 5] := STR0039 //"Em Aberto"
					Case LIT->LIT_STATUS == "2"
						aContrato[ 5] := STR0040 //"Encerrado"
					Case LIT->LIT_STATUS == "3"
						aContrato[ 5] := STR0041 //"Cancelado"
					Case LIT->LIT_STATUS == "4"
						aContrato[ 5] := STR0056 //"Cessão de direito"
					Case LIT->LIT_STATUS == "5"
						aContrato[ 5] := STR0057 //"Distrato"
					Otherwise
						aContrato[ 5] := STR0042 //"Desconhecido"
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
				dbSetOrder(3) //LIU_FILIAL+LIU_NCONTR+LIU_COD+LIU_ITEM
				dbSeek(xFilial("LIU")+LIT->LIT_NCONTR)
				While LIU->(!eof()) .AND. (LIU->(LIU_FILIAL+LIU_NCONTR) == xFilial("LIT")+LIT->LIT_NCONTR)
					// Unidades
					dbSelectArea("LIQ")
					dbSetOrder(1) // LIQ_FILIAL+LIQ_COD
					If dbSeek(xFilial("LIQ")+LIU->LIU_CODEMP)
						// se for a unidade do empreendimento
						If LK3->LK3_FILIAL+LK3->LK3_CODEMP==LIQ_FILIAL+LIQ->LIQ_CODEMP .AND. !lContinua
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
					
					cNumPed := LIU->LIU_PEDIDO
					d1Venc  := LIU->LIU_EMISSA
					dbSelectArea("LIU")
					dbSkip()
				EndDo
				
				If lContinua 
					// Detalhes do Titulos a receber
					dbSelectArea("LIX")
					dbSetOrder(3) // LIX_FILIAL+LIX_NCONTR+LIX_PREFIX+LIX_NUM+LIX_PARCEL+LIX_TIPO
					dbSeek(xFilial("LIX")+LIT->LIT_NCONTR)
					While LIX->(!EOF()) .AND. LIX->(LIX_FILIAL+LIX_NCONTR)==xFilial("LIX")+LIT->LIT_NCONTR

						IncProc() 
						nCntRegua++
						If nCntRegua == 100
							ProcRegua(100)
							nCntRegua := 0
						EndIf
						
						//
						// Retorna um array com os dados detalhados do titulo a receber 
						//
						//	aTmpTit[01] - Situacao do titulo: recebido/Atrasado/A Receber 
						//	aTmpTit[02] - Parcela (aaa/bbb/-cc)
						//	aTmpTit[03] - Descricao do tipo de parcela
						//	aTmpTit[04] - data de vencimento
						//	aTmpTit[05] - Data da baixa
						//	aTmpTit[06] - Valor Recebido
						//	aTmpTit[07] - Valor do Titulo
						//	aTmpTit[08] - Valor Principal Original
						//	aTmpTit[09] - Correcao monetaria do Valor Principal 
						//	aTmpTit[10] - Valor Juros Fcto Original
						//	aTmpTit[11] - Correcao monetaria do Valor Juros Fcto 
						//	aTmpTit[12] - Pro rata
						//	aTmpTit[13] - Juros Mora
						//	aTmpTit[14] - Multa
						//	aTmpTit[15] - Desconto
						//	aTmpTit[16] - Valor Atualizado
						//	aTmpTit[17] - Taxa
						//
						If !Empty(aTmpTit := t_GMCalcTit( LIT->LIT_NCONTR ,LIX->LIX_PREFIX ,LIX->LIX_NUM ,LIX->LIX_PARCEL ,LIX->LIX_TIPO ,LIT->LIT_EMISSA ,dHabite ,LIT->LIT_JURMOR ,LIT->LIT_MULTA ,LIT->LIT_JURTIP ,(MV_PAR09==1) ,dDatabase ))
						
							//	aTitulo[01] - Situacao do titulo: recebido/Atrasado/A Receber 
							//	aTitulo[02] - Parcela (aaa/bbb/-cc)
							//	aTitulo[03] - Descricao do tipo de parcela
							//	aTitulo[04] - data de vencimento
							//	aTitulo[05] - Data da baixa
							//	aTitulo[06] - Valor Recebido
							//	aTitulo[07] - Valor do Titulo
							//	aTitulo[08] - Valor Principal Corrigido
							//	aTitulo[09] - Valor Juros Fcto Corrigido
							//	aTitulo[10] - Pro rata + Juros Mora + Multa
							//	aTitulo[11] - Desconto
							//	aTitulo[12] - Valor Atualizado
							//	aTitulo[13] - Taxa
							aTitulo := Array(13)
						    aTitulo[01] := aTmpTit[01]
						    aTitulo[02] := aTmpTit[02]
						    aTitulo[03] := aTmpTit[03]
						    aTitulo[04] := aTmpTit[04]
						    aTitulo[05] := aTmpTit[05]
						    aTitulo[06] := aTmpTit[06]
						    aTitulo[07] := aTmpTit[07]
						    aTitulo[08] := aTmpTit[08]+ aTmpTit[09]
						    aTitulo[09] := aTmpTit[10]+ aTmpTit[11]
						    aTitulo[10] := aTmpTit[12]+ aTmpTit[13]+ aTmpTit[14] 
						    aTitulo[11] := aTmpTit[15]
						    aTitulo[12] := aTmpTit[16]
						    aTitulo[13] := aTmpTit[17]
						    
							If (nPos:=aScan( aTotais ,{|x| x[1] == aTitulo[1]} ))<=0 
								aAdd(aTotais,Array(8))
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
							
							//
							// se nao for um titulo renegocia, acumula para obter o valor atual do contrato
							//
							If !(aTitulo[1]==2)
								// Valor Principal + CM
								nVlrContrat += aTitulo[ 8]
							EndIf
							
							For nCount := 6 To 12
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
						
						//
						// Formata os valores dos totais por tipo de parcelas
						//
						aTotais[nCount][ 2] := Transform(aTotais[nCount][ 2] ,x3Picture("E1_VALOR")) // Valor do Titulo
						aTotais[nCount][ 3] := Transform(aTotais[nCount][ 3] ,x3Picture("E1_SALDO")) // Valor Pago
						aTotais[nCount][ 4] := Transform(aTotais[nCount][ 4] ,x3Picture("E1_VALOR")) // Valor Principal
						aTotais[nCount][ 5] := Transform(aTotais[nCount][ 5] ,x3Picture("E1_VALOR")) // Juros Fcto
						aTotais[nCount][ 6] := Transform(aTotais[nCount][ 6] ,x3Picture("E1_VALOR")) // Penalidade
						aTotais[nCount][ 7] := Transform(aTotais[nCount][ 7] ,x3Picture("E1_VALOR")) // Desconto
						aTotais[nCount][ 8] := Transform(aTotais[nCount][ 8] ,x3Picture("E1_VALOR")) // Desconto
						
					Next nCount
					
					//
					//  totalizar por contrato
					//
					For nCount := 1 To len(aTotGeral)
						aTotGeral[nCount] := Transform(aTotGeral[nCount] ,x3Picture("E1_VALOR"))
					Next nCount
					
				    // ordena os titulos por tipo(recebida/renegociada/atrasada/a pagar) e por
				    // ordem de no. da parcela
					aSort( aGrpTit,,,{|x,y| str(x[1],2)+dtos(ctod(x[4])) < str(y[1],2)+dtos(ctod(y[4])) })
					
					// valor atual do contrato
					aContrato[8] := Transform( nVlrContrat ,x3Picture("E1_VALOR"))
					
					aContrato[10] := aGrpTit
					aContrato[11] := aTotais
					aContrato[12] := aTotGeral

					// solidarios
					aContrato[13] := {}
					LK6->(DbSetOrder(1)) //filial+contrato+LK6_codsol+LK6_ljsoli
					If LK6->(DbSeek(cFilLK6+LIT->LIT_NCONTR))
						While	!LK6->(EOF()) .And. LK6->(LK6_FILIAL+LK6_NCONTR)==cFilLK6+LIT->LIT_NCONTR
							If SA1->(DbSeek(cFilSA1+LK6->(LK6_CODSOL+LK6_LJSOLI)))
								If SA1->A1_PESSOA = "F"
									cCGC := Transform(SA1->A1_CGC , "@R 999.999.999-99")
								Else
									cCGC := Transform(SA1->A1_CGC , "@R 99.999.999/9999-99")
								EndIf
								aAdd( aContrato[13] , {LK6->LK6_CODSOL,LK6->LK6_LJSOLI,SA1->A1_NOME,cCGC,LK6->LK6_GRAU})
							EndIf
							LK6->(DbSkip())
						EndDo
					EndIf
					
					aContrato[14] := {}
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³ Condicao de venda do Pedido de Venda                      |
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					If LIT->LIT_COND == GetMV("MV_GMCPAG")
						// Condicao de venda "GEM"
						LJN->(DbSetOrder(1)) //filial+LJN_NUM+LJN_ITEM
						LJN->(DbSeek(cFilLJN+cNumPed))
						While LJN->(!Eof()) .and. LJN->(LJN_FILIAL+LJN_NUM) == cFilLJN+cNumPed
							aAdd( aContrato[14] , {LJN->LJN_ITEM, ;
														  Transform( LJN->LJN_NUMPAR ,x3Picture("LJN_NUMPAR") )+Space(01) , ;
														  Transform( LJN->LJN_VALOR/LJN->LJN_NUMPAR ,x3Picture("LJN_VALOR") ) , ;
														  Transform( LJN->LJN_VALOR ,x3Picture("LJN_VALOR") ) , ;
														  LJN->LJN_TIPPAR , ;
														  LJN->LJN_TPDESC , ;
														  Transform( LJN->LJN_1VENC ,x3Picture("LJN_1VENC") ) , ;
														  QA_CBox("LJN_TPSIST",LJN->LJN_TPSIST) , ;
														  Transform( LJN->LJN_TAXANO ,x3Picture("LJN_TAXANO") ) , ;
														  Transform( LJN->LJN_COEF ,x3Picture("LJN_COEF") ) , ;
														  LJN->LJN_IND , ;
														  Transform( LJN->LJN_NMES1 ,x3Picture("LJN_NMES1") ) , ;
														  LJN->LJN_INDPOS , ;
														  Transform( LJN->LJN_NMES2 ,x3Picture("LJN_NMES2") )   })
						
							LJN->(DbSkip())
						EndDo
					Else
						// Condicao de Pagamento
						SE4->(DbSetOrder(1))
						If SE4->(DbSeek(cFilSE4+cCondPag))
							// condicao de venda - cabecalho
							LIR->(DbSetOrder(1))
							If LIR->(DbSeek(cFilLIR+SE4->E4_CODCND))
								LIS->(DbSetOrder(1))
								If LIS->(DbSeek(cFilLIS+LIR->LIR_CODCND))
									While LIS->(!Eof()) .and. LIS->(LIS_FILIAL+LIS_CODCND) == cFilLIS+LIR->LIR_CODCND
										aAdd( aContrato[14],{ LIS->LIS_ITEM , ;
																	Transform( LIS->LIS_NUMPAR ,x3Picture("LIS_NUMPAR") ) , ;
																	Transform( (LIT->LIT_VALBRU*(LIS->LIS_PERCLT/100))/LIS->LIS_NUMPAR ,x3Picture("LJN_VALOR") ) , ;
																	Transform( (LIT->LIT_VALBRU*(LIS->LIS_PERCLT/100)) ,x3Picture("LJN_VALOR") ) , ;
																	LIS->LIS_TIPPAR , ;
																	LIS->LIS_TPDESC , ;
																	Transform( d1Venc ,x3Picture("LJN_1VENC") ) , ;
																	QA_CBox("LIS_TPSIST",LIS->LIS_TPSIST) , ;
																	Transform( LIS->LIS_TAXANO ,x3Picture("LIS_TAXANO") ) , ;
																	Transform( LIS->LIS_COEF ,x3Picture("LIS_COEF") ) , ;
																	LIS->LIS_IND , ;
																	Transform( LIS->LIS_NMES1 ,x3Picture("LIS_NMES1") ) , ;
																	LIS->LIS_INDPOS , ;
																	Transform( LIS->LIS_NMES2 ,x3Picture("LIS_NMES2") )    })
										LIS->(DbSkip())
									EndDo
								EndIf
							EndIf
						EndIf
					EndIf

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

Local cAlias	:= Alias()
Local aCposSX1	:= {}
Local aRegs		:= {}
Local nX 		:= 0
Local nJ		:= 0
Local cPerg		:= PadR ( "GMR060", Len( SX1->X1_GRUPO ) )
                         
aCposSX1 := {"X1_ORDEM","X1_PERGUNT","X1_PERSPA","X1_PERENG","X1_VARIAVL","X1_TIPO","X1_TAMANHO",;
             "X1_DECIMAL","X1_PRESEL","X1_GSC","X1_VALID","X1_VAR01","X1_DEF01","X1_DEF02","X1_DEFSPA1",;
             "X1_DEFENG1","X1_VAR02","X1_DEFSPA2","X1_DEFENG2",;
             "X1_VAR03","X1_DEF03","X1_DEFSPA3","X1_DEFENG3","X1_F3","X1_PYME","X1_CNT01"}

aAdd(aRegs,{"01","Empreendimento De?" ,"","","mv_ch1","C",TamSX3("LIQ_COD")[1]   ,00,0,"G",""          ,"mv_par01",   "",   "","","","","","","","","","","LIQ","",""})
aAdd(aRegs,{"02","Empreendimento Ate?","","","mv_ch2","C",TamSX3("LIQ_COD")[1]   ,00,0,"G","naovazio()","mv_par02",   "",   "","","","","","","","","","","LIQ","",Replicate("Z",TamSX3("LIQ_COD")[1])})
aAdd(aRegs,{"03","Cliente De ?"       ,"","","mv_ch3","C",TamSX3("A1_COD")[1]    ,00,0,"G",""          ,"mv_par03",   "",   "","","","","","","","","","","SA1","",""})
aAdd(aRegs,{"04","Loja De ?"          ,"","","mv_ch4","C",TamSX3("A1_LOJA")[1]   ,00,0,"G",""          ,"mv_par04",   "",   "","","","","","","","","","",""   ,"",""})
aAdd(aRegs,{"05","Cliente Ate ?"      ,"","","mv_ch5","C",TamSX3("A1_COD")[1]    ,00,0,"G","naovazio()","mv_par05",   "",   "","","","","","","","","","","SA1","",Replicate("Z",TamSX3("A1_COD")[1])})
aAdd(aRegs,{"06","Loja Ate ?"         ,"","","mv_ch6","C",TamSX3("A1_LOJA")[1]   ,00,0,"G","naovazio()","mv_par06",   "",   "","","","","","","","","","",""   ,"",Replicate("Z",TamSX3("A1_LOJA")[1])})
aAdd(aRegs,{"07","Contrato De ?"      ,"","","mv_ch7","C",TamSX3("LIT_NCONTR")[1],00,0,"G",""          ,"mv_par07",   "",   "","","","","","","","","","","LIT","",""})
aAdd(aRegs,{"08","Contrato Ate ?"     ,"","","mv_ch8","C",TamSX3("LIT_NCONTR")[1],00,0,"G","naovazio()","mv_par08",   "",   "","","","","","","","","","","LIT","",Replicate("Z",TamSX3("LIT_NCONTR")[1])})
aAdd(aRegs,{"09","Atualiza Valores ?" ,"","","mv_ch9","N",01                     ,00,0,"C",""          ,"mv_par09","Sim","Nao","","","","","","","","","","","",""})

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



/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³TamToCols ³ Autor ³ Reynaldo Miyashita    ³ Data ³ 02.10.06 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Define o inicio de impressao de cada coluna                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³Nenhum                                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³Nenhum                                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³   DATA   ³ Programador   ³Manutencao efetuada                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ 25.09.06 ³Reynaldo Miyash³ Criação                                    ³±± 
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function TamToCols( aTamCols ,nLeft, nRight )

Local aRetorno := {}
Local nCount   := 0
Local nCol     := 0

Default nLeft  := 10
Default nRight := 10

	aAdd( aRetorno ,nLeft )
	nCol := nLeft

	For nCount := 1 to len( aTamCols )
	
		nCol += aTamCols[nCount]
		aAdd( aRetorno ,nCol )
	
	Next nCount
	aAdd( aRetorno ,nCol )

Return( aRetorno )
