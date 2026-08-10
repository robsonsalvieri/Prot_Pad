#INCLUDE "SIGACUS.CH" 
#INCLUDE "PROTHEUS.CH"
#DEFINE PULALINHA CHR(13)+CHR(10)
/*/
苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北
北谀哪哪哪哪履哪哪哪哪穆哪哪哪穆哪哪哪哪哪哪哪哪哪哪哪穆哪哪哪履哪哪哪哪目北
北矲un噮o   ?a440F4   ?Autor ?Gilson do Nascimento  ?Data ?29/04/94 潮?
北媚哪哪哪哪拍哪哪哪哪牧哪哪哪牧哪哪哪哪哪哪哪哪哪哪哪牧哪哪哪聊哪哪哪哪拇北
北矰escri噮o?Faz a consulta ao controle de Poder Terceiros.       *      潮?
北媚哪哪哪哪拍哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪拇北
北砈intaxe  砤440F4(a,b,c,ExpC1,ExpC2,ExpC3,ExpC4,ExpC5,ExpC6,ExpC7,ExpC8潮?
北媚哪哪哪哪拍哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪拇北
北砅arametro?a,b,c = parametros padroes quando utiliza-se o Set Key     潮?
北?        ?ExpC1 = Arquivo a pesquisar no SX3                         潮?
北?        ?ExpC2 = Variavel que sera usada para o Seek                潮?
北?        ?ExpC3 = Nome do campo em o cursor deve estar posicionado   潮?
北?        ?        para ativar esta rotina.                           潮?
北?        ?ExpC4 = Se rotina de Entrada ou Saida                      潮?
北?        ?ExpC5 = Codigo do Cliente / Fornecedor                     潮?
北?        ?ExpC6 = Loja                                               潮?
北?        ?ExpC7 = Codigo da Tes                                      潮?
北?        ?ExpC8 = Tipo da Nota                                       潮?
北媚哪哪哪哪拍哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪拇北
北?Uso     ?Generico                                                   潮?
北滥哪哪哪哪聊哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪馁北
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北?
哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌?
*/
Function A440F4(cAlias,cCodPRD,cLocal,cCampoF3,cESx,cCliFor,cLoja,lAltera,lRecebto,nRecSD2,cTpCliFor,aNFOrigBen,lRetBenef)

Local nSaldo   := 0,;
nPosNNF  := 0,;
nPosSER  := 0,;
nPosQTD  := 0,;
nPosID6  := 0,;
nPosPRC  := 0,;
nPosLoc  := 0,;
nPosLote := 0,;
nPosSLote:= 0,;
nPosDtVld:= 0,;
nPosPoten:= 0,;
nQtdPed  := 0,;
nPosItOri:= 0,;
nPProvEnt:= 0,;
nPNumSeri:= 0,;
nPLocaliz:= 0,;
cProvEnt := ""

LOCAL nSavOrdSD2:= SD2->(IndexOrd()),;
nPosAliqIcm		:= 0

Local nIndex,nPosEl,cCampo
Local nOption  := 0,nRet:=0, nOAT
Local cSeek:=" "
Local aArrayF4 := {},;
aAuxArF4 := {},;
aQtTamX3 := {},;
aProvEnt := {}

Local nHdl  := Nil,;
oDlg  := Nil,;
oDlgBen  := Nil,;
oQual := Nil

Local cTipoLote := "",;
cLoteCtl  := "",;
cItemOri  := "",;
cNumLote  := "",;
cSeekLote := "",;
cNumSeri  := "",;
cLocaliz  := "",;
dDtValid  := Ctod(""),;  		// Sergio Fuzinaka - 05.11.01
nPotencia := 0

Local aAreaSD1:={}
Local aAreaSD2:={}
Default aNFOrigBen := {}
Default lRetBenef  := .F.

lRecebto	:= If( (lRecebto == NIL),.F.,lRecebto )

If !Empty( cCodPRD ) .And. (AllTrim( Upper( cCampoF3 ) ) == "B6_PRODUTO")
	
	cTipoLote:=If(Rastro(cCodPRD),If(Rastro(cCodPRD,"S"),"S","L"),"N")
	
	nHdl := GetFocus()
	
	For nIndex := 1 To Len( aHeader )
		
		cCampo := SubStr( AllTrim( aHeader[ nIndex,2 ] ),3 )
		
		Do Case
			Case  (cESx == "D") .And. (cCampo == "_PRCVEN")
				nPosPRC := nIndex
				
			Case !(cESx == "D") .And. (cCampo == "_VUNIT")
				nPosPRC := nIndex
				
				
			Case !(cESx == "D") .And. (cCampo == "_PICM")
				nPosAliqIcm := nIndex
				
			Case (cCampo == "_NFORI")
				nPosNNF := nIndex
				
			Case cCampo == "_SERIE"
				nPosSER := nIndex

			Case cCampo == "_SERIORI"
				nPosSER := nIndex

			Case cCampo == "_ITEMORI"
				nPosItOri:= nIndex
				
			Case cCampo == "_IDENTB6"
				nPosID6 := nIndex
				
			Case cCampo == "_QUANT"
				nPosQTD := nIndex
				
			Case cCampo == "_QTDVEN"
				nPosQTD := nIndex
				
			Case cCampo == "_LOCAL"
				nPosLoc := nIndex
				
			Case cCampo == "_LOTECTL"
				nPosLote:= nIndex
				
			Case cCampo == "_NUMLOTE"
				nPosSLote:= nIndex
				
			Case cCampo == "_DTVALID"
				nPosDtVld:= nIndex

			Case cCampo == "_POTENCI"
				nPosPoten:= nIndex
				
			Case cCampo == "_PROVENT"
				nPProvEnt:= nIndex
			
			Case cCampo == "_NUMSERI"
				nPNumSeri:= nIndex
				
			Case cCampo == "_LOCALIZ"
				nPLocaliz:= nIndex
				
		EndCase
	Next
	
	If IsTriangular()
		cSeek:=cCodPrd
	Else
		cSeek:=(cCodPrd+cClifor+cLoja+"R")
	Endif
	
	dbSelectArea(cAlias)
	dbSetOrder(2)                                                            
	
	If dbSeek( xFilial( cAlias )+cSeek )
		
		If Type("__cExpF4") != "C"
			__cExpF4 := ".T."
		Endif
		
		aQtTamX3 := TamSX3( "B6_QUANT" )
		
		While !Eof() .And. ;
			(xFilial(cAlias)+cSeek == If(IsTriangular(),B6_FILIAL+B6_PRODUTO,B6_FILIAL+B6_PRODUTO+B6_CLIFOR+B6_LOJA+B6_PODER3))

			// BOPS - Verifica se trata-se de cliente ou fornecedor para
			// prevenir casos onde o codigo de cliente e fornecedor sao iguais  
			// e os dois tem poder de terceiros
			If Valtype(cTpCliFor) == "C" .And. !Empty(cTpClifor) .And. cTpCliFor # B6_TPCF
				dbSkip()
				Loop			
			EndIf   

			If &__cExpF4
				
				nQtdPed:=0
				
				If ((cESx == "E") .And. (SB6->B6_TIPO == "E")) .Or. (cESx != "E" .And. B6_TIPO == "D")
					
					For nIndex := 1 To Len( aCols )
						If !lRetBenef .And. !aCols[nIndex][Len(aCols[nIndex])].And.aCols[ nIndex,nPosID6 ] == SB6->B6_IDENT .And.(n # nIndex)
							nQtdPed += aCols[ nIndex,nPosQtd ]
						EndIf
					Next nIndex
										
					If lAltera .And. !Empty(SC5->C5_NOTA) // este pedido tem itens faturados
						dbSelectArea("SC6")
						dbSetOrder(2)
						dbseek(xFilial("SC6")+SB6->B6_PRODUTO+SC5->C5_NUM)
						While xFilial("SC6")+SB6->B6_PRODUTO+SC5->C5_NUM == C6_FILIAL+C6_PRODUTO+C6_NUM .And. !Eof()
							If SB6->(B6_DOC+B6_SERIE) == C6_NFORI+C6_SERIORI
								nQtdPed -= C6_QTDENT
							EndIf
							dbSkip()
						EndDo
						dbSetOrder(1)
						dbSelectArea("SB6")
					EndIf
					If lAltera .And. !lRecebto
						If ((nPosEl := AScan( aQtdLib,{ | aEl | aEl[ 2 ] == SB6->B6_IDENT } )) # 0)
							nSaldo   := B6_SALDO - B6_QULIB + aQtdLib[ nPosEl,3 ]+aQtdLib[ nPosEl,4 ] -  nQtdPed
						Else
							nSaldo   := B6_SALDO - B6_QULIB - nQtdPed
						Endif
					Else
						nSaldo := B6_SALDO - B6_QULIB - nQtdPed
					EndIf
					
					If (nSaldo > 0)
						cItemOri	:=	""
						// Pesquisa rastreabilidade
						If cTipoLote $ "SL" .Or. cPaisLoc <> "BRA"  
							If SB6->B6_TES <= "500"
								dbSelectArea("SD1")
								aAreaSD1:=GetArea()
								dbSetOrder(1)
								cSeekLote:=xFilial("SD1")+SB6->B6_DOC+SB6->B6_SERIE+SB6->B6_CLIFOR+SB6->B6_LOJA+SB6->B6_PRODUTO
								dbSeek(cSeekLote)
								cLoteCtl:=CriaVar("D1_LOTECTL");cNumLote:=CriaVar("D1_NUMLOTE");dDtValid:=CriaVar("D1_DTVALID");nPotencia:=CriaVar("D1_POTENCI")
								While !Eof() .And. D1_FILIAL+D1_DOC+D1_SERIE+D1_FORNECE+D1_LOJA+D1_COD == cSeekLote
									If D1_IDENTB6 == SB6->B6_IDENT
										cLoteCtl	:=	SD1->D1_LOTECTL
										cNumLote	:=	SD1->D1_NUMLOTE
										dDtValid	:=	SD1->D1_DTVALID
										nPotencia:=	SD1->D1_POTENCI
										cItemOri	:=	SD1->D1_ITEM
										cNumSeri	:=	SD1->D1_NUMSERI
										cLocaliz	:=	SD1->D1_LOCALIZ
										If cPaisLoc == "ARG" .And. nPProvEnt > 0
											cProvEnt	:= SD1->D1_PROVENT
										Endif
										Exit
									EndIf
									dbSkip()
								EndDo
								RestArea(aAreaSD1)	
							ElseIf SB6->B6_TES > "500"
								dbSelectArea("SD2")
								aAreaSD2:=GetArea()
								dbSetOrder(3)
								cSeekLote:=xFilial("SD2")+SB6->B6_DOC+SB6->B6_SERIE+SB6->B6_CLIFOR+SB6->B6_LOJA+SB6->B6_PRODUTO
								dbSeek(cSeekLote)
								While !Eof() .And. D2_FILIAL+D2_DOC+D2_SERIE+D2_CLIENTE+D2_LOJA+D2_COD == cSeekLote
									If D2_IDENTB6 == SB6->B6_IDENT
										cLoteCtl	:=	SD2->D2_LOTECTL
										cNumLote	:=	SD2->D2_NUMLOTE
										dDtValid	:=	SD2->D2_DTVALID
										nPotencia	:=	SD2->D2_POTENCI
										cItemOri	:=	SD2->D2_ITEM
										cNumSeri	:=	SD2->D2_NUMSERI
										cLocaliz	:=	SD2->D2_LOCALIZ
										If cPaisLoc == "ARG" .And. nPProvEnt > 0
											cProvEnt	:= SD2->D2_PROVENT
										Endif
										Exit
									EndIf
									dbSkip()
								EndDo
								RestArea(aAreaSD2)
								dbSelectArea("SB6")
							EndIf						
						EndIf
						
						AAdd( aArrayF4,{ SB6->B6_DOC,;
						SB6->B6_SERIE,;
						DtoC( SB6->B6_EMISSAO ),;
						xPadl( Str( nSaldo,aQtTamX3[ 1 ],aQtTamX3[ 2 ] ),100 ),SB6->B6_LOCAL,cLoteCtl,cNumLote,dDtValid,nPotencia,cItemOri,IIf(lRetBenef,SB6->B6_PRUNIT,),IIf(lRetBenef,SB6->B6_IDENT,),cNumSeri,cLocaliz})
						AAdd( aAuxArF4,{ nSaldo,;
						SB6->B6_IDENT,;
						SB6->B6_PRUNIT } )
						If cPaisLoc == "ARG" .And. nPProvEnt > 0
							Aadd(aProvEnt,cProvEnt)
						Endif
					EndIf
				EndIf
			EndIf
			dbSelectArea(cAlias)
			dbSkip(1)
		EndDo
		If (Len( aAuxArF4 ) # 0)
			If lRetBenef 
				aNFOrigBen := aClone(aArrayF4)
				nRet := 1
			Else
				DEFINE MSDIALOG oDlg TITLE OemToAnsi(STR0001) From 9,0 To 18,60 OF oMainWnd	//"Notas Poder Terceiro"
					@ .25,.9 LISTBOX oQual VAR cVar Fields HEADER OemToAnsi(STR0002),OemToAnsi(STR0003),OemToAnsi(STR0004),OemToAnsi(STR0005),OemToAnsi(STR0006),OemToAnsi(STR0018),OemToAnsi(STR0021),OemToAnsi(STR0016) SIZE 190,62 ON DBLCLICK (nOption := 1,oDlg:End())	//"Nota"###"S俽ie"###"Emiss刼"###"Saldo Atual"###"Local"###"Lote"###"Sub-Lote"###"Validade"
					oQual:SetArray( aArrayF4 )
					oQual:bLine := { || { aArrayF4[ oQual:nAT,1 ],aArrayF4[ oQual:nAT,2 ],aArrayF4[ oQual:nAT,3 ],aArrayF4[ oQual:nAT,4 ],aArrayF4[ oQual:nAT,5 ],aArrayF4[ oQual:nAT,6 ],aArrayF4[ oQual:nAT,7 ] ,aArrayF4[ oQual:nAT,8 ]} }
				DEFINE SBUTTON FROM 5   ,200  TYPE 1 ACTION (nOption := 1,oDlg:End()) ENABLE OF oDlg
				DEFINE SBUTTON FROM 17.5,200  TYPE 2 ACTION oDlg:End()                ENABLE OF oDlg
				
				ACTIVATE MSDIALOG oDlg VALID (nOAT := oQual:nAT,.t.)
				
				If nOption == 1
		
					If nPosItOri> 0 ;	aCols[n,nPosItOri]:=aArrayF4[nOAT,10]	;	Endif
		
					aCols[n,nPosNNF]  :=aArrayF4[nOAT,1]
					aCols[n,nPosSER]  :=aArrayF4[nOAT,2]
					aCols[n,nPosLoc]  :=aArrayF4[nOAT,5]
					aCols[n,nPosID6]  :=aAuxArF4[nOAT,2]
					//tratamento aqui
					aCols[n,nPosPrc]  :=aAuxArF4[nOAT,3]
					If cPaisLoc == "ARG" .And. nPProvEnt > 0
						aCols[n,nPProvEnt] := aProvEnt[nOAT]
					Endif
					If nPosLote > 0 ;	aCols[n,nPosLote] :=aArrayF4[nOAT,6]	;	Endif
					If nPosSLote> 0 ;	aCols[n,nPosSLote]:=aArrayF4[nOAT,7]	;	Endif
					If nPosDtVld> 0 ;	aCols[n,nPosDtVld]:=aArrayF4[nOAT,8]	;	Endif
					If nPosPoten> 0 ;	aCols[n,nPosPoten]:=aArrayF4[nOAT,9]	;	Endif
		
					//谀哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪目
					//?Nas NFs de entrada posiciona SD2 origem e obtem aliq. ICMS   ?
					//滥哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪馁
					If cEsx == "E" .And. (nPosAliqIcm > 0 .Or. cPaisLoc<>"BRA")
						dbSelectArea("SD2")
						dbSetOrder(4)
						If dbSeek(xFilial("SD2")+aAuxArF4[nOAT,2])  
							If nPosAliqIcm > 0
								aCols[n][nPosAliqIcm]	:= SD2->D2_PICM
							EndIf
							nRecSD2	:= SD2->(RecNo())
						EndIf
						dbSetOrder(nSavOrdSD2)
					EndIf
					If !lRecebto
						aCols[n,nPosQtd]	:= Val(aArrayF4[ nOAT,4 ])
						&(ReadVar())		:= Val(aArrayF4[ nOAT,4 ])
						nRet				:= Val(aArrayF4[ nOAT,4 ])
					Else
						&(ReadVar())		:= aArrayF4[ nOAT,1 ]
					EndIf
					DbSelectArea( cAlias )  ; SetFocus( nHdl ) 
				EndIf
			EndIf
		ElseIf !lRetBenef
			Help(" ",1,"A440N/SB6")
		EndIf
	ElseIf !lRetBenef
		Help(" ",1,"a440F4") ; DbSetOrder( 1 )
	Endif
Else
	Return( If( lRecebto, TamSX3( "D1_NFORI" )[ 1 ] ,0 ) )
EndIf
Return( nRet )

/*
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北?
北谀哪哪哪哪穆哪哪哪哪哪履哪哪哪履哪哪哪哪哪哪哪哪哪哪哪履哪哪穆哪哪哪哪哪勘?
北矲un噮o    ?F4Compl  ?Autor ?Rosane L. Chene       ?Data ?11/05/95 潮?
北媚哪哪哪哪呐哪哪哪哪哪聊哪哪哪聊哪哪哪哪哪哪哪哪哪哪哪聊哪哪牧哪哪哪哪哪幢?
北矰escri噮o ?Faz a consulta das Notas Fiscais para compl.de IPI         潮?
北媚哪哪哪哪呐哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪幢?
北砈intaxe   ?F4Compl(a,b,c,ExpC1,ExpC2,ExpC3,ExpC4                      潮?
北媚哪哪哪哪呐哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪幢?
北砅arametros?a,b,c = parametros padroes quando utiliza-se o Set Key     潮?
北?         ?ExpC1 = Codigo do Cliente ou Fornecedor                    潮?
北?         ?ExpC2 = Loja                                               潮?
北?         ?ExpC3 = Codigo do Produto                                  潮?
北?         ?ExpC4 = Codigo do Produto                                  潮?
北媚哪哪哪哪呐哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪幢?
北?Uso      ?Generico                                                   潮?
北滥哪哪哪哪牧哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪俦?
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北?
哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌?
*/
Function F4Compl(a,b,c,cCliFor,cLoja,cProd,cProg,nRecSD1,cVar)
Local aArrayF4[0]            

Local aObjects  := {}
Local aInfo     := {}
Local aPosObj   := {}
Local aSize     := MsAdvSize( .F. )
Local aRecSD1	:= {}
Local cSeek     := ""
Local cTexto1   := ""
Local cTexto2   := ""
Local cCadastro := ""
Local cCampo    := ""
Local nOpt1     := 1
Local nX        := 0 
Local nEndereco
Local cAlias    := Alias()
Local nOrdem    := IndexOrd()
Local nRec      := RecNo()
Local nOAT      := 0
Local nPosNf    := 0
Local nPosSer   := 0
Local nPosIt    := 0
Local nOpca     := 0
Local nHdl      := GetFocus()
Local nPosSeek  := 0
Local oDlg
Local oQual
Local cAliasQry	:= GetNextAlias()   
Local lSIGAF7CON := ExistBlock('SIGAF7CON')  
Local aRecSD2	:= {}

cVar := If(cVar==Nil,ReadVar(),cVar)       // variavel corrente

If Substr(cVar,6,6)!= "_NFORI"
	Return Nil
Endif

If cProg $ "A440/A920"
	cArq  := "SF2"
	cSeek := "F2_FILIAL+F2_CLIENTE+F2_LOJA"
Else
	cArq  := "SF1"
	cSeek := "F1_FILIAL+F1_FORNECE+F1_LOJA"
Endif

If cProg $ "A440/A920"
	BeginSql Alias cAliasQry
	SELECT 
		SD2.D2_FILIAL, SD2.D2_COD, SD2.D2_DOC, SD2.D2_SERIE, SD2.D2_CLIENTE, SD2.D2_LOJA, SD2.D2_ORIGLAN, SD2.D2_ITEM, SD2.D2_TOTAL, SD2.D2_VALIPI, D2_VALICM, SD2.D2_PRCVEN,
		SF2.F2_FILIAL, SF2.F2_CLIENTE, SF2.F2_LOJA, SF2.F2_TIPO, SF2.F2_DOC, SF2.F2_SERIE, SD2.R_E_C_N_O_			
	FROM
		%table:SD2% SD2, %table:SF2% SF2
	WHERE 
		SD2.D2_FILIAL=%xFilial:SD2% AND 
		SD2.D2_COD=%Exp:cProd% AND
		SD2.D2_CLIENTE=%Exp:cCliFor% AND 
		SD2.D2_LOJA=%Exp:cLoja% AND 
		SD2.D2_ORIGLAN<>'LF' AND
		SD2.%NotDel% AND
	
		SF2.F2_FILIAL=%xFilial:SF2% AND
		SF2.F2_DOC=SD2.D2_DOC AND
		SF2.F2_SERIE=SD2.D2_SERIE AND
		SF2.F2_CLIENTE=SD2.D2_CLIENTE AND
		SF2.F2_LOJA=SD2.D2_LOJA AND
		SF2.%NotDel% AND
		SF2.F2_TIPO NOT IN('D','B','P','I')
	ORDER BY 
		SD2.D2_FILIAL, SD2.D2_DOC, SD2.D2_SERIE, SD2.D2_CLIENTE, SD2.D2_LOJA, SD2.D2_COD, SD2.D2_ITEM
	EndSql    	
Else
   	BeginSql Alias cAliasQry
	SELECT 
		SD1.D1_FILIAL, SD1.D1_COD, SD1.D1_DOC, SD1.D1_SERIE, SD1.D1_FORNECE, SD1.D1_LOJA, SD1.D1_ORIGLAN, SD1.D1_ITEM, SD1.D1_TOTAL, SD1.D1_VALIPI, SD1.D1_VUNIT,
		SF1.F1_FILIAL, SF1.F1_FORNECE, SF1.F1_LOJA, SF1.F1_TIPO, SF1.F1_DOC, SF1.F1_SERIE			
	FROM
		%table:SD1% SD1, %table:SF1% SF1
	WHERE 
		SD1.D1_FILIAL=%xFilial:SD1% AND 
		SD1.D1_COD=%Exp:cProd% AND
		SD1.D1_FORNECE=%Exp:cCliFor% AND 
		SD1.D1_LOJA=%Exp:cLoja% AND 
		SD1.D1_ORIGLAN<>'LF' AND
		SD1.%NotDel% AND
	
		SF1.F1_FILIAL=%xFilial:SF1% AND
		SF1.F1_DOC=SD1.D1_DOC AND
		SF1.F1_SERIE=SD1.D1_SERIE AND
		SF1.F1_FORNECE=SD1.D1_FORNECE AND
		SF1.F1_LOJA=SD1.D1_LOJA AND
		SF1.%NotDel% AND
		SF1.F1_TIPO NOT IN('D','B','P','I')
	ORDER BY 
		SD1.D1_FILIAL, SD1.D1_DOC, SD1.D1_SERIE, SD1.D1_FORNECE, SD1.D1_LOJA, SD1.D1_COD, SD1.D1_ITEM
	EndSql
EndIf

If (cAliasQry)->(Eof())
HELP(" ",1,"F4NAONOTA")
dbSelectArea(cAlias)
dbSetOrder(nOrdem)
dbGoto(nRec)
Return .T.
Endif

For Nx:=1 to Len(aHeader)
cCampo := Trim(aHeader[nx][2])
cCampo := Subs(cCampo,3,len(cCampo)-2)
If cCampo == "_NFORI"
	nPosNf	:= nx
ElseIf cCampo == "_SERIORI"
	nPosSer	:= nx
ElseIf cCampo == "_ITEMORI"
	nPosIt 	:= nx
Endif
Next Nx

While !(cAliasQry)->(Eof())
If cProg $ "A440/A920"
	AADD(aArrayF4,{(cAliasQry)->D2_DOC,(cAliasQry)->D2_SERIE,(cAliasQry)->D2_ITEM,STR((cAliasQry)->D2_TOTAL,11,2),Str((cAliasQry)->D2_VALIPI,11,2),Str((cAliasQry)->D2_VALICM,11,2),Str((cAliasQry)->D2_PRCVEN,11,2)})
	If cProg == "A920" 
		aAdd(aRecSD2,(cAliasQry)->R_E_C_N_O_)
	EndIf
Else
	AADD(aArrayF4,{(cAliasQry)->D1_DOC,(cAliasQry)->D1_SERIE,(cAliasQry)->D1_ITEM,STR((cAliasQry)->D1_TOTAL,11,2),Str((cAliasQry)->D1_VALIPI,11,2),Str((cAliasQry)->D1_VALIPI,11,2),Str((cAliasQry)->D1_VUNIT,11,2)})
	aAdd(aRecSD1,SD1->(RecNo()))
EndIf
(cAliasQry)->(dbSkip())
End


//谀哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪目
//?Ponto de Entrada para alterar o array da visualicao do F7    ?
//滥哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪馁
If lSIGAF7CON .And. !cProg $ "A440/A920" 
	aRetPE:= ExecBlock("SIGAF7CON",.F.,.F.,{aArrayF4,aRecSD1})	
	If ValType(aRetPE) == "A" .And.	 ValType(aRetPE[1]) == "A" .And. ValType(aRetPE[2]) == "A"
	    If len(aRetPE[1]) == len(aRetPE[2])  
		aArrayF4:= aClone(aRetPE[1])		
		aRecSD1 := aClone(aRetPE[2])
		EndIF
	EndIf
EndIf

If !Empty(aArrayF4)

	aSize[1] /= 1.5
	aSize[2] /= 1.5
	aSize[3] /= 1.5
	aSize[4] /= 1.3
	aSize[5] /= 1.5
	aSize[6] /= 1.3
	aSize[7] /= 1.5
	
	AAdd( aObjects, { 100, 020,.T.,.F.,.T.} )
	AAdd( aObjects, { 100, 060,.T.,.T.,.T.} )
	AAdd( aObjects, { 100, 020,.T.,.F.} )
	aInfo   := { aSize[ 1 ], aSize[ 2 ], aSize[ 3 ], aSize[ 4 ], 3, 3 }
	aPosObj := MsObjSize( aInfo, aObjects,.T.)


	cCadastro:= OemToAnsi(STR0007)+"-"+OemToAnsi(STR0033) 	//"Notas Fiscais de Origem"
	nOpca := 0
	DEFINE MSDIALOG oDlg TITLE cCadastro From aSize[7],000 To aSize[6],aSize[5] OF oMainWnd PIXEL

	@ aPosObj[1,1],aPosObj[1,2] MSPANEL oPanel PROMPT "" SIZE aPosObj[1,3],aPosObj[1,4] OF oDlg CENTERED LOWERED
    
    If cArq  == "SF1"
		cTexto1 := AllTrim(RetTitle("F1_FORNECE"))+"/"+AllTrim(RetTitle("F1_LOJA"))+": "+SA2->A2_COD+"/"+SA2->A2_LOJA+"  -  "+RetTitle("A2_NOME")+": "+SA2->A2_NOME
	Else
		cTexto1 := AllTrim(RetTitle("F2_CLIENTE"))+"/"+AllTrim(RetTitle("F2_LOJA"))+": "+SA1->A1_COD+"/"+SA1->A1_LOJA+"  -  "+RetTitle("A1_NOME")+": "+SA1->A1_NOME		
	EndIf
	@ 002,005 SAY cTexto1 SIZE aPosObj[1,3],008 OF oPanel PIXEL
	cTexto2 := AllTrim(RetTitle("B1_COD"))+": "+SB1->B1_COD+"/"+SB1->B1_DESC
	@ 012,005 SAY cTexto2 SIZE aPosObj[1,3],008 OF oPanel PIXEL	
	
	@ aPosObj[2,1],aPosObj[2,2] LISTBOX oQual VAR cVar Fields HEADER OemToAnsi(STR0002),OemToAnsi(STR0003),OemToAnsi(STR0008),OemToAnsi(STR0012),OemToAnsi(STR0013),OemToAnsi(STR0032),OemToAnsi(STR0010) SIZE aPosObj[2,3],aPosObj[2,4] ON DBLCLICK (nOpca := 1,oDlg:End()) PIXEL	//"Nota"###"S俽ie"###"Item"###"Valor Item"###"Valor IPI"
	oQual:SetArray(aArrayF4)
	oQual:bLine := { || {aArrayF4[oQual:nAT][1],aArrayF4[oQual:nAT][2],aArrayF4[oQual:nAT][3],aArrayF4[oQual:nAT][4],aArrayF4[oQual:nAT][5],aArrayF4[oQual:nAT][6],aArrayF4[oQual:nAT][7]}}
	
	DEFINE SBUTTON FROM aPosObj[3,1]+000,aPosObj[3,4]-030  TYPE 1 ACTION (nOpca := 1,oDlg:End()) 	ENABLE OF oDlg PIXEL
	DEFINE SBUTTON FROM aPosObj[3,1]+012,aPosObj[3,4]-030 TYPE 2 ACTION oDlg:End() 					ENABLE OF oDlg PIXEL
	
	ACTIVATE MSDIALOG oDlg VALID (nOAT := oQual:nAT, .t.) CENTERED

	If nOpca == 1
		If cProg == "A920"
			nRecSD1	:= aRecSD2[nOAT]
		ElseIf cProg != "A440"
			nRecSD1	:= aRecSD1[nOAT]
		EndIf

		aCols[n][nPosNf] := aArrayF4[nOAT][1]
		aCols[n][nPosSer] := aArrayF4[nOAT][2]
		aCols[n][nPosIt]  := aArrayF4[nOAT][3]
		&(ReadVar()) 		:= aArrayF4[nOAT][1]
	Endif
Else
	HELP(" ",1,"F4NAONOTA")
Endif

dbSelectArea(cAlias)
dbSetOrder(nOrdem)
dbGoto(nRec)
SetFocus(nHdl)

Return .T.

/*
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北?
北谀哪哪哪哪穆哪哪哪哪哪履哪哪哪履哪哪哪哪哪哪哪哪哪哪哪履哪哪穆哪哪哪哪哪勘?
北矲un噮o    ?F4Lote   ?Autor ?Marcos Bregantim      ?Data ?19/09/94 潮?
北媚哪哪哪哪呐哪哪哪哪哪聊哪哪哪聊哪哪哪哪哪哪哪哪哪哪哪聊哪哪牧哪哪哪哪哪幢?
北矰escri噮o ?Faz a consulta aos Saldos do Lotes da Rastreabilidade      潮?
北媚哪哪哪哪呐哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪幢?
北砈intaxe   ?F4Lote(a,b,c,ExpC1,ExpC2,ExpC3)                            潮?
北媚哪哪哪哪呐哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪幢?
北砅arametros?a,b,c = parametros padroes quando utiliza-se o Set Key     潮?
北?         ?ExpC1 = Programa que chamou a rotina                       潮?
北?         ?ExpC2 = Codigo do Produto                                  潮?
北?         ?ExpC3 = Local                                              潮?
北?         ?ExpL4 = lParam                                             潮?
北?         ?ExpC5 = Localizacao                                        潮?
北?         ?ExpN6 = Verifica se atualiza o aCols do Lote               潮?
北?         ?ExpC6 = Numero da Ordem de Producao                        潮?
北媚哪哪哪哪呐哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪幢?
北?Uso      ?Generico                                                   潮?
北滥哪哪哪哪牧哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪俦?
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北?
哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌?
*/
Function F4Lote(	a		, b			, c			, cProg		,;
					cCod	, cLocal	, lParam	, cLocaliz	,;
					nLoteCtl, cOP		, lLoja		, lAtNumLote, cCampo)
Local aStruSB8		:={} 
Local aArrayF4		:={}
Local aHeaderF4		:={}
Local nOpt1			:= 1
Local nX
Local cVar
Local cSeek
Local cWhile
Local nEndereco
Local cAlias		:= Alias()
Local nOrdem		:= IndexOrd()
Local nRec			:= RecNo()
Local nValA440		:= 0
Local nHdl			:= GetFocus()
Local cCpo
Local oDlg2
Local cCadastro
Local nOpca
Local cLoteAnt		:= ""
Local cLoteFor		:= ""
Local dDataVali		:= ""
Local dDataCria		:= ""
Local lAdd			:= .F.
Local nSalLote		:= 0
Local nSalLote2		:= 0
Local nPotencia		:= 0
Local nPos2			:= 7
Local nPos3			:= 5
Local nPos4			:= 9
Local nPos5			:= 10
Local nPos6			:= 11
Local nPos7			:= 12
Local nPos8			:= 13
Local aTamSX3		:= {}
Local nOAT
Local aCombo1		:= {STR0018,STR0016,STR0017} 
Local aPosObj		:= {}
Local aObjects		:= {}
Local aSize			:= MsAdvSize(.F.)

Local cCombo1		:= ""
Local oCombo1
Local lRastro := Rastro(cCod,"S")						
Local aAreaSBF:={}  
Local cQuery    := ""
Local cAliasSB8 := "SB8"
Local nLoop     := 0 
Local aUsado     := {}
Local cLote241   := ''
Local cSLote241  := ''
Local lLote      := .F.
Local lSLote     := .F.
Local nPos       := 0
Local nPCod241   := 0
Local nPLoc241   := 0
Local nPLote241  := 0
Local nPSLote241 := 0
Local nQuant241  := 0
Local nPQuant241 := 0
Local nPCod261   := 0
Local nPLoc261   := 0
Local nPosLt261  := 0
Local nPSlote261 := 0
Local nQuant261  := 0
Local nPosQuant  := 0
Local nPosQtdLib := 0
Local nMultiplic := 1
Local lRet := .T.
Local lSelLote := (SuperGetMV("MV_SELLOTE") == "1")   
Local lMTF4Lote:= .T.
Local lExisteF4Lote := ExistBlock("F4LoteHeader")
Local cNumDoc  := ""
Local cSerie   := ""
Local cFornece := ""
Local cLoja    := ""
Local cLocProc	:= GetMvNNR('MV_LOCPROC','99')
Local lEmpPrev := If(SuperGetMV("MV_QTDPREV")== "S",.T.,.F.)
Local nSaldoCons:=0
//谀哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪目
//?MV_VLDLOTE - Utilizado para visualizar somente os lotes que  | 
//| possuem o campo B8_DATA com o valor menor ou igual a database|
//| do sistema                                                   ?
//滥哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪馁
Local lVldDtLote := SuperGetMV("MV_VLDLOTE",.F.,.T.)

Default cLocaliz:= ""
Default cOP     := ""
Default nLoteCtl:= 1  
Default lLoja	:= .F.
Default lAtNumLote := .T.
Default Ccampo := ""

//谀哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪目
//?Ponto de entrada para impedir a apresentacao da Dialog de Saldos ?
//滥哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪馁
If ExistBlock("MTF4LOTE")
	lMTF4Lote := ExecBlock("MTF4LOTE",.F.,.F.,{cProg})
	If Valtype(lMTF4Lote) <> "L"
		lMTF4Lote := .T.
	EndIf
EndIf

cCpo := ReadVar()
lParam := IIf(lParam== NIL, .T., lParam) 
SB1->(dbSetOrder(1))
SB1->(MsSeek(xFilial("SB1")+cCod))
lLote  := Rastro(cCod)
lSLote := Rastro(cCod, 'S')
If !lLote
	Help(" ",1,"NAORASTRO")
	Return nil
Endif
If !lRastro
	nPos2:=1;nPos3:=5;nPos4:=8;nPos5:=9;nPos6:=10;nPos7:=11;nPos8:=12
EndIf	
If (cProg == "A240" .Or. cProg == "A241") .And. cCpo != "M->D3_NUMLOTE" .And. cCpo != "M->D3_LOTECTL"
	Return nil
Endif
If cProg == "A100"
	If cTipo != "D"
		Return Nil
	Endif
Endif
If cProg == "A440" .And. cCpo != "M->C6_NUMLOTE" .And. cCpo != "M->C6_LOTECTL"
	Return Nil
Endif
If cProg == "A240"
	IF  M->D3_TM <= "500" .and. SF5->F5_APROPR != "S" .And. SB1->B1_APROPRI == "I"
		cLocal := cLocProc
	Endif
Endif
If cProg == "A241"
	//谀哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪目
	//?Inicializa o array aUsado com os Lotes ja digitados no aCols ?
	//滥哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪馁
	nMultiplic := If(cTM<='500',1,-1)
	For nX := 1 To Len(aHeader)
		If '_COD'         == Right(AllTrim(aHeader[nX, 2]), 4)
			nPCod241   := nX
		ElseIf '_LOCAL'   == Right(AllTrim(aHeader[nX, 2]), 6)
			nPLoc241   := nX
		ElseIf '_LOTECTL' == Right(AllTrim(aHeader[nX, 2]), 8)
			cLote241   := aCols[n, nX]
			nPLote241  := nX
		ElseIf '_NUMLOTE' == Right(AllTrim(aHeader[nX, 2]), 8)
			cSLote241  := aCols[n, nX]
			nPSlote241 := nX
		ElseIf '_QUANT'   == Right(AllTrim(aHeader[nX, 2]), 6)
			nQuant241  := aCols[n, nX]
			nPQuant241 := nX
		EndIf
	Next nX
	For nX := 1 To Len(aCols)
		If !(nX==n) .And. If(ValType(aCols[nX,Len(aCols[nX])])=='L', !aCols[nX,Len(aCols[nX])], .T.)
			If aCols[nX, nPCod241] == cCod .And. aCols[nX,nPLoc241] == cLocal
				If (nPos:=aScan(aUsado, {|x| x[1] == aCols[nX,nPLote241] .And. If(lSLote, x[2]==aCols[nX, nPSlote241], .T.)})) == 0
					aAdd(aUsado, {aCols[nX, nPLote241], aCols[nX, nPSlote241], (aCols[nX, nPQuant241]*nMultiplic)})
				Else
					aUsado[nPos, 3] += (aCols[nX, nPQuant241]*nMultiplic)
				EndIf
			EndIf
		EndIf
	Next nX
	IF  cTm <= "500" .and. SF5->F5_APROPR != "S" .And. SB1->B1_APROPRI == "I"
		cLocal := cLocProc
	Endif
Endif
If cProg == "A261" // Transferencia interna mod. II
	//谀哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪目
	//?Inicializa o array aUsado com os Lotes ja digitados no aCols ?
	//?Importante: A rotina MATA261 utiliza posicoes fixas no aCols ?
	//滥哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪馁

	// Localiza as saidas do lote
	nPCod261   := 1  // Produto origem
	nPLoc261   := 4  // Local origem
	nPosLt261  := Iif(!__lPyme,12,9)  // Lote 
	nPSlote261 := Iif(!__lPyme,13,10) // Sub-lote  
	nQuant261  := 16 // Quantidade
	
	For nX := 1 To Len(aCols)
		If !(nX==n) .And. If(ValType(aCols[nX,Len(aCols[nX])])=='L', !aCols[nX,Len(aCols[nX])], .T.)
			If aCols[nX, nPCod261] == cCod .And. aCols[nX,nPLoc261] == cLocal
				If (nPos:=aScan(aUsado, {|x| x[1] == aCols[nX,nPosLt261] .And. If(lSLote, x[2]==aCols[nX, nPSlote261], .T.)})) == 0
					aAdd(aUsado, {aCols[nX, nPosLt261], aCols[nX, nPSlote261], (aCols[nX, nQuant261]*-1)})
				Else
					aUsado[nPos, 3] += (aCols[nX, nQuant261]*-1) // Saida do lote
				EndIf
			EndIf
		EndIf
	Next nX

	// Localiza as entradas no lote
	nPCod261   := 6  // Produto destino	
	nPLoc261   := Iif(!__lPyme,9,8)  // Local destino  	//Armazem Destino
	nPosLt261  := Iif(!__lPyme,20,17) // Lote destino  //Lote Destino
	nQuant261  := 16 // Quantidade 	//Quantidade
	
	For nX := 1 To Len(aCols)
		If !(nX==n) .And. If(ValType(aCols[nX,Len(aCols[nX])])=='L', !aCols[nX,Len(aCols[nX])], .T.)
			If aCols[nX, nPCod261] == cCod .And. aCols[nX,nPLoc261] == cLocal
				If (nPos:=aScan(aUsado, {|x| x[1] == aCols[nX,nPosLt261]})) == 0
					aAdd(aUsado, {aCols[nX, nPosLt261], Nil, (aCols[nX, nQuant261])})
				Else
					aUsado[nPos, 3] += (aCols[nX, nQuant261]) // Entrada no lote
				EndIf
			EndIf
		EndIf
	Next nX
Endif
If cProg == "A270" .And. cCpo != "M->B7_NUMLOTE" .And. cCpo != "M->B7_LOTECTL"
	Return Nil
Endif
If cProg == "A380" .And. cCpo != "M->D4_NUMLOTE" .And. cCpo != "M->D4_LOTECTL"
	Return Nil
Endif
If cProg == "A381" .And. cCpo != "M->D4_NUMLOTE" .And. cCpo != "M->D4_LOTECTL"
	Return Nil
Endif
If cProg == "A275" .And. cCpo != "M->DD_NUMLOTE" .And. cCpo != "M->DD_LOTECTL"
	Return Nil
Endif

If cPaisLoc $ "ARG|POR|EUA"
	If cProg == "A465" .And. ;
		cCpo != "M->D2_NUMLOTE" .and. cCpo != "M->D2_LOTECTL" .and.;
		cCpo != "M->CN_NUMLOTE" .And. cCpo != "M->CN_LOTECTL" .and.;
		cCpo != "M->D1_NUMLOTE" .And. cCpo != "M->D1_LOTECTL"
		Return Nil
	EndIf
Endif

If cProg == "A440"
	nPosQuant := Ascan(aHeader,{|x| AllTrim(x[2])=="C6_QTDVEN"})
	nPosQtdLib:= Ascan(aHeader,{|x| AllTrim(x[2])=="C6_QTDLIB"})
Endif

// Verifica se o arquivo que chamou a consulta tem potencia para informar no lote
If Type("nPosPotenc") != "N"
	nPosPotenc := 0
Endif

//谀哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪目
//?Verifica o arquivo a ser pesquisado                          ?
//滥哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪馁
dbSelectArea("SB8")
dbSetOrder(1)
cSeek := cCod+cLocal
dbSeek(xFilial("SB8")+cSeek)
If !Found()
	HELP(" ",1,"F4LOTE")
	dbSelectArea(cAlias)
	dbSetOrder(nOrdem)
	dbGoto(nRec)
	Return nil
Endif

//谀哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪目
//?Obtem o numero de casas decimais que dever ser utilizado na  ?
//?consulta.                                                    ?
//滥哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪馁
aTamSX3:=TamSX3(Substr(cCpo,4,3)+"QUANT")
If Empty(aTamSX3)
	aTamSX3:=TamSX3("B8_SALDO")
EndIf

//谀哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪目
//?Caso utilize controle de enderecamento e tenha endereco      ?
//?preenchido.                                                  ?
//滥哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪馁
If Localiza(cCod) .And. !Empty(cLocaliz)
	dbSelectArea("SB8")
	dbSetOrder(3)
	dbSelectArea("SBF")
	aAreaSBF:=GetArea()
	dbSetOrder(1)
	cSeek:=xFilial("SBF")+cLocal+cLocaliz+cCod
	dbSeek(cSeek)
	Do While !Eof() .And. cSeek == BF_FILIAL+BF_LOCAL+BF_LOCALIZ+BF_PRODUTO
		If SB8->(dbSeek(xFilial("SB8")+SBF->BF_PRODUTO+SBF->BF_LOCAL+SBF->BF_LOTECTL+If(!Empty(SBF->BF_NUMLOTE),SBF->BF_NUMLOTE,"")))
			If lVldDtLote .And. SB8->B8_DATA > dDataBase
				SBF->(dbSkip())
				Loop
			EndIf		
			If !Empty(SBF->BF_NUMLOTE) .And. lRastro
				AADD(aArrayF4, F4LoteArray(cProg, lSLote, "SBF", "SBF", {SBF->BF_NUMLOTE,SBF->BF_PRODUTO,Str(SBFSaldo(),14,aTamSX3[2]),Str(SBFSaldo(,,,.T.),14,aTamSX3[2]),SB8->B8_DTVALID,SB8->B8_LOTEFOR,SBF->BF_LOTECTL,SB8->B8_DATA,SB8->B8_POTENCI,SBF->BF_LOCALIZ,SBF->BF_NUMSERI}))
			Else
				AADD(aArrayF4, F4LoteArray(cProg, lSLote, "SBF", "SBF", {SBF->BF_LOTECTL,SBF->BF_PRODUTO,Str(SBFSaldo(),14,aTamSX3[2]),Str(SBFSaldo(,,,.T.),14,aTamSX3[2]),SB8->B8_DTVALID,SB8->B8_LOTEFOR,SB8->B8_DATA,SB8->B8_POTENCI,SBF->BF_LOCALIZ,SBF->BF_NUMSERI}))
			EndIf
		EndIf
		dbSelectArea("SBF")
		dbSkip()
	EndDo
	RestArea(aAreaSBF)
ElseIf lSLote      
	SB8->( dbSetOrder( 1 ) ) 
	cAliasSB8 := GetNextAlias()
	
	aStruSB8 := SB8->( dbStruct() ) 
	
	cQuery := "SELECT * FROM " + RetSqlName( "SB8" ) + " SB8 "
	cQuery += "WHERE "
	cQuery += "B8_FILIAL='"  + xFilial( "SB8" )	+ "' AND " 
	cQuery += "B8_PRODUTO='" + cCod            	+ "' AND " 
	cQuery += "B8_LOCAL='"   + cLocal          	+ "' AND "
	cQuery += IIf(lVldDtLote,"B8_DATA <= '" + DTOS(dDataBase) 	+ "' AND ","")
	cQuery += "D_E_L_E_T_=' ' "
	cQuery += "ORDER BY " + SqlOrder( SB8->( IndexKey() ) ) 		
	
	cQuery := ChangeQuery( cQuery ) 
	
	dbUseArea( .t., "TOPCONN", TcGenQry( ,,cQuery ), cAliasSB8, .f., .t. )
	
	For nLoop := 1 To Len( aStruSB8 ) 			
		If aStruSB8[ nLoop, 2 ] <> "C" 
			TcSetField( cAliasSB8, aStruSB8[nLoop,1],	aStruSB8[nLoop,2],aStruSB8[nLoop,3],aStruSB8[nLoop,4])
		EndIf 		
	Next nLoop 		
		
	While !( cAliasSB8 )->(Eof()) .And. xFilial("SB8")+cSeek == ( cAliasSB8 )->B8_FILIAL+( cAliasSB8 )->B8_PRODUTO+( cAliasSB8 )->B8_LOCAL
		If !(cProg $ "A100/A240/A440/A241/A270/A465/A685/AT460")
			If SB8Saldo(NIL,NIL,NIL,NIL,cAliasSB8,lEmpPrev,.T.,IIf(cProg=="A380",dDataBase,Nil)) > 0
				AADD(aArrayF4, F4LoteArray(cProg, lSLote, "SB8", cAliasSB8, {( cAliasSB8 )->B8_NUMLOTE, ( cAliasSB8 )->B8_PRODUTO, Str(SB8Saldo(NIL,NIL,NIL,NIL,cAliasSB8,lEmpPrev,.T.),14,aTamSX3[2]), Str(SB8Saldo(,,,.T.,cAliasSB8,lEmpPrev,.T.),14,aTamSX3[2]), ( cAliasSB8 )->B8_DTVALID, ( cAliasSB8 )->B8_LOTEFOR, ( cAliasSB8 )->B8_LOTECTL, ( cAliasSB8 )->B8_DATA,( cAliasSB8 )->B8_POTENCI}))
			Endif
		ElseIf cProg == "A240" .Or. cProg == "A241" .Or. cProg == "A261"
			nSalLote  := SB8Saldo(NIL,NIL,NIL,NIL,cAliasSB8,lEmpPrev,.T.)
			nSalLote2 := SB8Saldo(,,,.T.,cAliasSB8,lEmpPrev,.T.)
			If cProg == 'A241' .Or. cProg == "A261"
				//谀哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪?
				//?Atualiza o Saldo com as quantidades ja digitadas no aCols ?
				//滥哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪?
				If QtdComp(nSalLote) > QtdComp(0)
					If (nPos:=aScan(aUsado, {|x| x[1] == ( cAliasSB8 )->B8_LOTECTL .And. x[2] == ( cAliasSB8 )->B8_NUMLOTE})) > 0
						nSalLote  += aUsado[nPos, 3]
						nSalLote2 += ConvUM(cCod, aUsado[nPos, 3], 0, 2)
					EndIf
				EndIf		
			EndIf	
			IF SF5->F5_TIPO == "D" .or. nSalLote > 0
				AADD(aArrayF4, F4LoteArray(cProg, lSLote, "SB8", cAliasSB8, {( cAliasSB8 )->B8_NUMLOTE, ( cAliasSB8 )->B8_PRODUTO, Str(nSalLote,14,aTamSX3[2]), Str(nSalLote2,14,aTamSX3[2]), ( cAliasSB8 )->B8_DTVALID, ( cAliasSB8 )->B8_LOTEFOR, ( cAliasSB8 )->B8_LOTECTL, ( cAliasSB8 )->B8_DATA,( cAliasSB8 )->B8_POTENCI}))
			Endif
		ElseIf cProg $ "A100/A270"
			AADD(aArrayF4, F4LoteArray(cProg, lSLote, "SB8", cAliasSB8, {( cAliasSB8 )->B8_NUMLOTE, ( cAliasSB8 )->B8_PRODUTO, Str(SB8Saldo(NIL,NIL,NIL,NIL,cAliasSB8,lEmpPrev,.T.),14,aTamSX3[2]), Str(SB8Saldo(,,,.T.,cAliasSB8,lEmpPrev,.T.),14,aTamSX3[2]), ( cAliasSB8 )->B8_DTVALID, ( cAliasSB8 )->B8_LOTEFOR, ( cAliasSB8 )->B8_LOTECTL, ( cAliasSB8 )->B8_DATA,( cAliasSB8 )->B8_POTENCI}))
		ElseIf cProg == "A440" .Or. cProg == "AT460"
			nValA440 := QtdLote(( cAliasSB8 )->B8_PRODUTO,( cAliasSB8 )->B8_LOCAL,( cAliasSB8 )->B8_NUMLOTE,.F.,( cAliasSB8 )->B8_LOTECTL)
			If SB8Saldo(NIL,NIL,NIL,NIL,cAliasSB8,lEmpPrev,.T.)-nValA440 > 0
				AADD(aArrayF4, F4LoteArray(cProg, lSLote, "SB8", cAliasSB8, {( cAliasSB8 )->B8_NUMLOTE, ( cAliasSB8 )->B8_PRODUTO, Str(SB8Saldo(NIL,NIL,NIL,NIL,cAliasSB8,lEmpPrev,.T.)-nValA440,14,aTamSX3[2]), Str(SB8Saldo(,,,.T.,cAliasSB8,lEmpPrev,.T.)-ConvUM(( cAliasSB8 )->B8_PRODUTO,nValA440,0,2),14,aTamSX3[2]), ( cAliasSB8 )->B8_DTVALID, ( cAliasSB8 )->B8_LOTEFOR, ( cAliasSB8 )->B8_LOTECTL, ( cAliasSB8 )->B8_DATA,( cAliasSB8 )->B8_POTENCI}))
			Endif                                         
		ElseIf cProg == "A685"          
			If (SB8Saldo(NIL,NIL,NIL,NIL,cAliasSB8,lEmpPrev,.T.) > 0 .And. lParam) .Or. (!lParam)	
			   AADD(aArrayF4, F4LoteArray(cProg, lSLote, "SB8", cAliasSB8, {( cAliasSB8 )->B8_NUMLOTE, ( cAliasSB8 )->B8_PRODUTO, Str(SB8Saldo(NIL,NIL,NIL,NIL,cAliasSB8,lEmpPrev,.T.),14,aTamSX3[2]), Str(SB8Saldo(,,,.T.,cAliasSB8,lEmpPrev,.T.),14,aTamSX3[2]), ( cAliasSB8 )->B8_DTVALID, ( cAliasSB8 )->B8_LOTEFOR, ( cAliasSB8 )->B8_LOTECTL, ( cAliasSB8 )->B8_DATA,( cAliasSB8 )->B8_POTENCI}))
			ElseIf !Empty(cOP) .And. ( SB8Saldo(NIL,NIL,NIL,NIL,cAliasSB8,lEmpPrev,.T.,,,cOP) > 0 .And. lParam )
			   AADD(aArrayF4, F4LoteArray(cProg, lSLote, "SB8", cAliasSB8, {( cAliasSB8 )->B8_NUMLOTE, ( cAliasSB8 )->B8_PRODUTO, Str(SB8Saldo(NIL,NIL,NIL,NIL,cAliasSB8,lEmpPrev,.T.),14,aTamSX3[2]), Str(SB8Saldo(,,,.T.,cAliasSB8,lEmpPrev,.T.),14,aTamSX3[2]), ( cAliasSB8 )->B8_DTVALID, ( cAliasSB8 )->B8_LOTEFOR, ( cAliasSB8 )->B8_LOTECTL, ( cAliasSB8 )->B8_DATA,( cAliasSB8 )->B8_POTENCI}))
			EndIf   
		ElseIf cProg $ "A465"
			AADD(aArrayF4, F4LoteArray(cProg, lSLote, "SB8", cAliasSB8, {( cAliasSB8 )->B8_NUMLOTE, ( cAliasSB8 )->B8_PRODUTO, Str((SB8SALDO(,,,,cAliasSB8,lEmpPrev,,,.T.)-(SB8SALDO(.T.,,,,cAliasSB8,lEmpPrev,,,.T.)+nValA440)),14,aTamSX3[2]), ;
			Str((SB8SALDO(,,,.T.,cAliasSB8,lEmpPrev,,,.T.)-(SB8SALDO(.T.,,,.T.,cAliasSB8,lEmpPrev,,,.T.)+ConvUM(( cAliasSB8 )->B8_PRODUTO,nValA440,0,2))),14,aTamSX3[2]), ;
			( cAliasSB8 )->B8_DTVALID, ( cAliasSB8 )->B8_LOTEFOR, ( cAliasSB8 )->B8_LOTECTL, ( cAliasSB8 )->B8_DATA,( cAliasSB8 )->B8_POTENCI}))
		Endif
		( cAliasSB8 )->( dbSkip() ) 
	EndDo
	
	( cAliasSB8 )->( dbCloseArea() ) 
	dbSelectArea( "SB8" ) 

	
Else
	SB8->( dbSetOrder( 3 ) ) 
	cAliasSB8 := GetNextAlias()
	
	aStruSB8 := SB8->( dbStruct() ) 
	
	cQuery := "SELECT * FROM " + RetSqlName( "SB8" ) + " SB8 "
	cQuery += "WHERE "
	cQuery += "B8_FILIAL='"  + xFilial( "SB8" )	+ "' AND " 
	cQuery += "B8_PRODUTO='" + cCod            	+ "' AND " 
	cQuery += "B8_LOCAL='"   + cLocal          	+ "' AND "
	cQuery += IIf(lVldDtLote,"B8_DATA <= '" + DTOS(dDataBase) 	+ "' AND ","")
	cQuery += "D_E_L_E_T_=' ' "
	cQuery += "ORDER BY " + SqlOrder( SB8->( IndexKey() ) ) 		
	
	cQuery := ChangeQuery( cQuery ) 
	
	dbUseArea( .t., "TOPCONN", TcGenQry( ,,cQuery ), cAliasSB8, .f., .t. )
	
	For nLoop := 1 To Len( aStruSB8 ) 			
		If aStruSB8[ nLoop, 2 ] <> "C" 
			TcSetField( cAliasSB8, aStruSB8[nLoop,1],	aStruSB8[nLoop,2],aStruSB8[nLoop,3],aStruSB8[nLoop,4])
		EndIf 		
	Next nLoop 		
	                                            
	While !( cAliasSB8 )->( Eof()) .And. xFilial("SB8")+cSeek == ( cAliasSB8 )->B8_FILIAL+( cAliasSB8 )->B8_PRODUTO+( cAliasSB8 )->B8_LOCAL
		cLoteAnt:=( cAliasSB8 )->B8_LOTECTL
		cLoteFor:=( cAliasSB8 )->B8_LOTEFOR
		dDataVali:=( cAliasSB8 )->B8_DTVALID
		dDataCria:=( cAliasSB8 )->B8_DATA
		nPotencia:=( cAliasSB8 )->B8_POTENCI 
		cNumDoc  := ( cAliasSB8 )->B8_DOC
		cSerie   := ( cAliasSB8 )->B8_SERIE
		cFornece := ( cAliasSB8 )->B8_CLIFOR
		cLoja    := ( cAliasSB8 )->B8_LOJA

		lAdd	  :=.F.
		nSalLote  :=0
		nSalLote2 :=0
		If cProg == "A440" .Or. cProg == "AT460"
			nValA440 := QtdLote(( cAliasSB8 )->B8_PRODUTO,( cAliasSB8 )->B8_LOCAL,"",.F.,cLoteAnt)
		EndIf
		While !( cAliasSB8 )->( Eof() ) .And. xFilial("SB8")+cSeek+cLoteAnt == ( cAliasSB8 )->B8_FILIAL+( cAliasSB8 )->B8_PRODUTO+( cAliasSB8 )->B8_LOCAL+( cAliasSB8 )->B8_LOTECTL
			If !(cProg $ "A100/A240/A440/A241/A242/A270/AT460/A685")
				nSalLote += SB8Saldo(NIL,NIL,NIL,NIL,cAliasSB8,lEmpPrev,.T.,IIf(cProg == "A380",dDataBase,Nil))
				nSalLote2+= SB8Saldo(,,,.T.,cAliasSB8,lEmpPrev,.T.,IIf(cProg == "A380",dDataBase,Nil))
			ElseIf cProg == "A240" .Or. cProg == "A241" .Or. cProg == "A242"
				nSalLote += SB8Saldo(NIL,NIL,NIL,NIL,cAliasSB8,lEmpPrev,.T.,,,cOP)
				nSalLote2+= SB8Saldo(,,,.T.,cAliasSB8,lEmpPrev,.T.,,,cOP)
			ElseIf cProg $ "A100/A270"
				nSalLote += SB8Saldo(NIL,NIL,NIL,NIL,cAliasSB8,lEmpPrev,.T.)
				nSalLote2+= SB8Saldo(,,,.T.,cAliasSB8,lEmpPrev,.T.)
			ElseIf cProg == "A440" .Or. cProg == "AT460"
				nSalLote  += SB8Saldo(NIL,NIL,NIL,NIL,cAliasSB8,lEmpPrev,.T.) - nValA440
				nSalLote2 += SB8Saldo(,,,.T.,cAliasSB8,lEmpPrev,.T.) - ConvUM(cCod,nValA440,0,2)
                nValA440 :=0 
			ElseIf cProg == "A685"
				If Empty(cOP)
					nSalLote += SB8Saldo(NIL,NIL,NIL,NIL,cAliasSB8,lEmpPrev,.T.,IIf(cProg == "A380",dDataBase,Nil))
					nSalLote2+= SB8Saldo(,,,.T.,cAliasSB8,lEmpPrev,.T.,IIf(cProg == "A380",dDataBase,Nil))
				Else
					nSalLote += SB8Saldo(NIL,NIL,NIL,NIL,cAliasSB8,lEmpPrev,.T.,IIf(cProg == "A380",dDataBase,Nil),,cOP)
					nSalLote2+= SB8Saldo(NIL,NIL,NIL,.T.,cAliasSB8,lEmpPrev,.T.,IIf(cProg == "A380",dDataBase,Nil),,cOP)
				EndIf	
			EndIf
			( cAliasSB8 )->( dbSkip() )
		EndDo
		If cProg == 'A241' .Or. cProg == "A261"
			//谀哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪?
			//?Atualiza o Saldo com as quantidades ja digitadas no aCols ?
			//滥哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪?
			If QtdComp(nSalLote) > QtdComp(0)
				If (nPos:=aScan(aUsado, {|x| x[1] == cLoteAnt})) > 0
					nSalLote  += aUsado[nPos, 3]
					nSalLote2 += ConvUM(cCod, aUsado[nPos, 3], 0, 2)
				EndIf
			EndIf		
		EndIf	
		If QtdComp(nSalLote) > QtdComp(0) .Or. ((cProg == "A270" .And. !lParam) .Or. (cProg == "A685" .And. !lParam) .Or. ((cProg == "A240" .Or. cProg == "A241") .And. SF5->F5_TIPO == "D") .Or. (cProg == "A242" .And. cCpo == "M->D3_LOTECTL"))
			AADD(aArrayF4, F4LoteArray(cProg, lSLote, "", "", {cLoteAnt,cCod,Str(nSalLote,aTamSX3[1],aTamSX3[2]),Str(nSalLote2,aTamSX3[1],aTamSX3[2]), (dDataVali), cLoteFor, dDataCria,nPotencia,cNumDoc,cSerie,cFornece,cLoja}))
		EndIf
	EndDo
	
	( cAliasSB8 )->( dbCloseArea() ) 
	dbSelectArea( "SB8" ) 
	
EndIf

If ExistBlock("F4LOTIND")
	aRetPE:= ExecBlock("F4LOTIND",.F.,.F.,{aArrayF4})
	If ValType(aRetPE) == "A" .And. Len(aRetPE) > 0
		aArrayF4:= aClone(aRetPE)
	EndIf
EndIf 

If lMTF4Lote
	If !Empty(aArrayF4)
	
		AAdd( aObjects, { 100, 100, .t., .t.,.t. } )
		AAdd( aObjects, { 100, 30, .t., .f. } )
	
		aSize[ 3 ] -= 50
		aSize[ 4 ] -= 50 	
		
		aSize[ 5 ] -= 100
		aSize[ 6 ] -= 100
		
		aInfo   := { aSize[ 1 ], aSize[ 2 ], aSize[ 3 ], aSize[ 4 ], 3, 2 }
		aPosObj := MsObjSize( aInfo, aObjects )
	
		cCadastro := OemToAnsi(STR0014)	//"Saldos por Lote"
		nOpca := 0
	
		DEFINE MSDIALOG oDlg2 TITLE cCadastro From aSize[7],00 To  aSize[6],aSize[5] OF oMainWnd PIXEL	
		@ 7.1,.4 Say OemToAnsi(STR0023) //"Pesquisa Por: "
		If lSLote
			aHeaderF4 := {STR0011,STR0015,STR0005,STR0041,STR0016,STR0017,STR0018,STR0024,STR0029,STR0042,STR0003,STR0043,STR0044} //"Sub-Lote"###"Produto"###"Saldo Atual"###"Saldo Atual 2aUM"###"Validade"###"Lote Fornecedor"###"Lote"###"Dt Emissao"###"Potencia"###"Nota Fiscal"###"Serie"###"Cliente/Fornecedor"###"Loja"
			aHeaderF4 := RetExecBlock("F4LoteHeader", {cProg, lSLote, aHeaderF4}, "A", aHeaderF4)
			
			If lExisteF4Lote  
				AjustaPosHeaderF4(aHeaderF4, @nPos2, @nPos3, @nPos4, @nPos5, @nPos6, @nPos7, @nPos8)
			EndIf
	        
	        oQual := VAR := cVar := TWBrowse():New( aPosObj[1][1], aPosObj[1][2], aPosObj[1][3], aPosObj[1][4],,aHeaderF4,,,,,,,{|nRow,nCol,nFlags|(nOpca := 1,oDlg2:End())},,,,,,, .F.,, .T.,, .F.,,, )    
			oQual:SetArray(aArrayF4)
			oQual:bLine := { || aArrayF4[oQual:nAT] }
		Else
			aHeaderF4 := {STR0018,STR0015,STR0005,STR0041,STR0016,STR0017,STR0024,STR0029,STR0042,STR0003,STR0043,STR0044}//"Lote"###"Produto"###"Saldo Atual"###"Saldo Atual 2aUM"###"Validade"###"Lote Fornecedor"###"Dt Emissao"###"Potencia"###"Nota Fiscal"###"Serie"###"Cliente/Fornecedor"###"Loja"
			aHeaderF4 := RetExecBlock("F4LoteHeader", {cProg, lSLote, aHeaderF4}, "A", aHeaderF4)
			
			If lExisteF4Lote
				AjustaPosHeaderF4(aHeaderF4, @nPos2, @nPos3, @nPos4, @nPos5, @nPos6, @nPos7, @nPos8)
			EndIf
			
	        oQual := VAR := cVar := TWBrowse():New( aPosObj[1][1], aPosObj[1][2], aPosObj[1][3], aPosObj[1][4],,aHeaderF4,,,,,,,{|nRow,nCol,nFlags|(nOpca := 1,oDlg2:End())},,,,,,, .F.,, .T.,, .F.,,, )    
			oQual:SetArray(aArrayF4)
			oQual:bLine := { || aArrayF4[oQual:nAT] }
		EndIf
		@ aPosObj[2][1]+10,aPosObj[2][2] Say OemToAnsi(STR0023) PIXEL //"Pesquisa Por: " 	
		@ aPosObj[2][1]+10,aPosObj[2][2]+50 MSCOMBOBOX oCombo1 VAR cCombo1 ITEMS aCombo1 SIZE 100,44  VALID F4LotePesq(cCombo1,aArrayF4,oQual,oCombo1) OF oDlg2 FONT oDlg2:oFont PIXEL
		
		DEFINE SBUTTON FROM aPosObj[2][1]+10 ,aPosObj[2][4]-58  TYPE 1 ACTION (nOpca := 1,oDlg2:End()) ENABLE OF oDlg2
		DEFINE SBUTTON FROM aPosObj[2][1]+10 ,aPosObj[2][4]-28   TYPE 2 ACTION oDlg2:End() ENABLE OF oDlg2
		
		ACTIVATE MSDIALOG oDlg2 VALID (nOAT := oQual:nAT,.t.) CENTERED
		
		If nOpca ==1
			If cProg == "A260" .Or. cProg == "A242"
				If !(Substr(cCpo,7) == "LOTECTL" .Or. Substr(cCpo,7) == "_LOTECT")
					If lSLote
						cNumLote := aArrayF4[nOAT][1]
					EndIf
					cLoteDigi:= aArrayF4[nOAT][nPos2]
					dDtValid := aArrayF4[nOAT][nPos3]
					nPotencia:= aArrayF4[nOAT][nPos4]
				EndIf
				If cProg == "A242"
					If Substr(cCpo,7) == "LOTECTL" .Or. Substr(cCpo,7) == "_LOTECT"
						&(ReadVar()) :=  aArrayF4[nOAT][nPos2]
						If Type('aCols') == 'A'
							If lSLote
								aCols[n][nPosLote]:=aArrayF4[nOAT][1]
							EndIf
							If nLoteCtl == 1
								aCols[n][nPosLotCTL] :=aArrayF4[nOAT][nPos2]
								aCols[n][nPosDValid] :=aArrayF4[nOAT][nPos3]
							EndIf	
							If nPosPotenc > 0
								aCols[n][nPosPotenc] :=aArrayF4[nOAT][nPos4]
							EndIf
						Endif
					EndIf
				EndIf
				If cPaisLoc $ "ARG|POR|EUA"
					If cProg == "A260"
						nQuant260D := 0.00
						nQuant260  := Val(aArrayF4[nOAT][3])
						nQuant260D := ConvUm(aArrayF4[nOAT][2],nQuant260,nQuant260D,2)
					EndIf
				EndIf
				
			ElseIf cProg == "A240"
				If lSLote
					nEndereco := Ascan(aGets,{ |x| Subs(x,9,10) == "D3_NUMLOTE" } )
					If nEndereco > 0
						aTela[Val(Subs(aGets[nEndereco],1,2))][Val(Subs(aGets[nEndereco],3,1))*2] := aArrayF4[nOAT][1]
						M->D3_NUMLOTE := aArrayF4[nOAT][1]
					EndIf
				EndIf
				nEndereco := Ascan(aGets,{ |x| Subs(x,9,10) == "D3_LOTECTL" } )
				If nEndereco > 0
					aTela[Val(Subs(aGets[nEndereco],1,2))][Val(Subs(aGets[nEndereco],3,1))*2] := aArrayF4[nOAT][nPos2]
					M->D3_LOTECTL := aArrayF4[nOAT][nPos2]
				EndIf
				nEndereco := Ascan(aGets,{ |x| Subs(x,9,10) == "D3_DTVALID" } )
				If nEndereco > 0
					aTela[Val(Subs(aGets[nEndereco],1,2))][Val(Subs(aGets[nEndereco],3,1))*2] := aArrayF4[nOAT][nPos3]
					M->D3_DTVALID := aArrayF4[nOAT][nPos3]
				EndIf             
				nEndereco := Ascan(aGets,{ |x| Subs(x,9,10) == "D3_POTENCI" } )
				If nEndereco > 0
					aTela[Val(Subs(aGets[nEndereco],1,2))][Val(Subs(aGets[nEndereco],3,1))*2] := aArrayF4[nOAT][nPos4]
					M->D3_POTENCI := aArrayF4[nOAT][nPos4]
				EndIf
			ElseIf cProg == "A270"
				If lSLote
					nEndereco := Ascan(aGets,{ |x| Subs(x,9,10) == "B7_NUMLOTE" } )
					If nEndereco > 0
						aTela[Val(Subs(aGets[nEndereco],1,2))][Val(Subs(aGets[nEndereco],3,1))*2] := aArrayF4[nOAT][1]
						M->B7_NUMLOTE := aArrayF4[nOAT][1]
					EndIf
				EndIf
				nEndereco := Ascan(aGets,{ |x| Subs(x,9,10) == "B7_LOTECTL" } )
				If nEndereco > 0
					aTela[Val(Subs(aGets[nEndereco],1,2))][Val(Subs(aGets[nEndereco],3,1))*2] := aArrayF4[nOAT][nPos2]
					M->B7_LOTECTL := aArrayF4[nOAT][nPos2]
				EndIf
				nEndereco := Ascan(aGets,{ |x| Subs(x,9,10) == "B7_DTVALID" } )
				If nEndereco > 0
					M->B7_DTVALID := aArrayF4[nOAT][nPos3]
					aTela[Val(Subs(aGets[nEndereco],1,2))][Val(Subs(aGets[nEndereco],3,1))*2] := aArrayF4[nOAT][nPos3]
				EndIf
				nEndereco := Ascan(aGets,{ |x| Subs(x,9,10) == "B7_NUMDOC " } )
				If nEndereco > 0
					aTela[Val(Subs(aGets[nEndereco],1,2))][Val(Subs(aGets[nEndereco],3,1))*2] := aArrayF4[nOAT][nPos5]
					M->B7_NUMDOC:=SB8->B8_DOC
				EndIf  
	                                                                                                           
				nEndereco := Ascan(aGets,{ |x| Subs(x,9,10) == "B7_SERIE  " } )
				If nEndereco > 0
					aTela[Val(Subs(aGets[nEndereco],1,2))][Val(Subs(aGets[nEndereco],3,1))*2] := aArrayF4[nOAT][nPos6]
					M->B7_SERIE:=SB8->B8_SERIE
				EndIf  
	                                                                                                             
				nEndereco := Ascan(aGets,{ |x| Subs(x,9,10) == "B7_FORNECE" } )
				If nEndereco > 0
					aTela[Val(Subs(aGets[nEndereco],1,2))][Val(Subs(aGets[nEndereco],3,1))*2] := aArrayF4[nOAT][nPos7]
					M->B7_FORNECE:=SB8->B8_CLIFOR
				EndIf  
	                                                                                                              
				nEndereco := Ascan(aGets,{ |x| Subs(x,9,10) == "B7_LOJA   " } )
				If nEndereco > 0
					aTela[Val(Subs(aGets[nEndereco],1,2))][Val(Subs(aGets[nEndereco],3,1))*2] := aArrayF4[nOAT][nPos8]
					M->B7_LOJA:=SB8->B8_LOJA
				EndIf  

			ElseIf cProg == "A380"
				If lSLote
					nEndereco := Ascan(aGets,{ |x| Subs(x,9,10) == "D4_NUMLOTE" } )
					If nEndereco > 0
						aTela[Val(Subs(aGets[nEndereco],1,2))][Val(Subs(aGets[nEndereco],3,1))*2] := aArrayF4[nOAT][1]
						M->D4_NUMLOTE := aArrayF4[nOAT][1]
					EndIf
				EndIf
				nEndereco := Ascan(aGets,{ |x| Subs(x,9,10) == "D4_LOTECTL" } )
				If nEndereco > 0
					aTela[Val(Subs(aGets[nEndereco],1,2))][Val(Subs(aGets[nEndereco],3,1))*2] := aArrayF4[nOAT][nPos2]
					M->D4_LOTECTL := aArrayF4[nOAT][nPos2]
				EndIf
				nEndereco := Ascan(aGets,{ |x| Subs(x,9,10) == "D4_DTVALID" } )
				If nEndereco > 0
					aTela[Val(Subs(aGets[nEndereco],1,2))][Val(Subs(aGets[nEndereco],3,1))*2] := aArrayF4[nOAT][nPos3]
					M->D4_DTVALID :=  aArrayF4[nOAT][nPos3]
				EndIf
			ElseIf cProg == "A275"
				If lSLote
					nEndereco := Ascan(aGets,{ |x| Subs(x,9,10) == "DD_NUMLOTE" } )
					If nEndereco > 0
						aTela[Val(Subs(aGets[nEndereco],1,2))][Val(Subs(aGets[nEndereco],3,1))*2] := aArrayF4[nOAT][1]
						M->DD_NUMLOTE := aArrayF4[nOAT][1]
					EndIf
				EndIf
				nEndereco := Ascan(aGets,{ |x| Subs(x,9,10) == "DD_LOTECTL" } )
				If nEndereco > 0
					aTela[Val(Subs(aGets[nEndereco],1,2))][Val(Subs(aGets[nEndereco],3,1))*2] := aArrayF4[nOAT][nPos2]
					M->DD_LOTECTL := aArrayF4[nOAT][nPos2]
				EndIf
				nEndereco := Ascan(aGets,{ |x| Subs(x,9,10) == "DD_DTVALID" } )
				If nEndereco > 0
					aTela[Val(Subs(aGets[nEndereco],1,2))][Val(Subs(aGets[nEndereco],3,1))*2] := aArrayF4[nOAT][nPos3]
					M->DD_DTVALID :=  aArrayF4[nOAT][nPos3]
				EndIf
			ElseIf cProg == "A465"
				If lRastro        
				   aCols[n][nPosLote] := aArrayF4[nOAT][1]	
					aCols[n][nPosLotCTL] := aArrayF4[nOAT][nPos2]
				Else   
	            aCols[n][nPosLotCTL] := aArrayF4[nOAT][1]
				EndIf   
				aCols[n][nPosDValid] := aArrayF4[nOAT][5]
				If Substr(cCpo,7) == "LOTECTL"
				   If lRastro			
					  	&(ReadVar()) :=  aArrayF4[nOAT][nPos2]
					Else
						&(ReadVar()) :=  aArrayF4[nOAT][1]					
				   EndIf	  
				Else
					If lRastro
						&(ReadVar()) :=  aArrayF4[nOAT][1]
					EndIf
				EndIf		
			ElseIf cProg == "AT460"
				If lSLote
					If SubStr(cCpo,8) == "NUMLOT"
						&(ReadVar()) := aArrayF4[nOAT][1]
					Else
						GDFieldPut("ABA_NUMLOT",aArrayF4[nOAT][1],n)
					EndIf
				EndIf
				If SubStr(cCpo,8) == "LOTECT"
					&(ReadVar()) := aArrayF4[nOAT][nPos2]
				Else
					GDFieldPut("ABA_LOTECT",aArrayF4[nOAT][nPos2],n)
				EndIf 
			ElseIf cProg == "A310" 
				If lSLote
					cNumLote := aArrayF4[nOAT][1]
				EndIf
				cLoteDigi:= aArrayF4[nOAT][nPos2]
				dDtValid2 := aArrayF4[nOAT][nPos3]
				nQuant:=0
				nQuant2UM :=0		
			ElseIf cProg == "ESTA009"
				FwFldPut("IN2_LOTECT",aArrayF4[nOAT][nPos2] )
				If lSLote
					FwFldPut("IN2_NUMLOT",aArrayF4[nOAT][1])
				EndIf			
			ElseIf cProg == "AGR900"
				If 	Alltrim(cCpo) == "M->NPN_LOTE"
					FwFldPut("NPN_LOTE", aArrayF4[nOAT][nPos2])
				EndIf	
			ElseIf cProg == "A311"	
				If cCpo == "M->NNT_LOTECT"
					If lSLote
						M->NNT_NUMLOT	:=  PadR(aArrayF4[nOAT][1],TamSx3("NNT_NUMLOT")[1])
						FwFldPut( "NNT_NUMLOT" , PadR(aArrayF4[nOAT][1],TamSx3("NNT_NUMLOT")[1]),,,,.T.)
					EndIf	
					M->NNT_LOTECT	:= aArrayF4[nOAT][nPos2]
					M->NNT_NUMLOT	:=  PadR(aArrayF4[nOAT][1],TamSx3("NNT_NUMLOT")[1])
				ElseIf cCpo == "M->NNT_NUMLOT"
					M->NNT_NUMLOT	:=  PadR(aArrayF4[nOAT][1],TamSx3("NNT_NUMLOT")[1])
					FwFldPut( "NNT_LOTECT" , aArrayF4[nOAT][nPos2],,,,.T. )
				EndIf
			ElseIf cProg == "ACDI011"
				MV_PAR05 := aArrayF4[nOAT][nPos2] 	// LOTE
				If lSLote
					MV_PAR06 := aArrayF4[nOAT][1] 	// SUBLOTE
				EndIf
				MV_PAR07 := aArrayF4[nOAT][nPos3] 	
			Else
				lRet := .T.
				If lSelLote .and. nPosQuant > 0
					SB8->(DbSetOrder(3))
					If lSLote
						cSeek:=xFilial("SB8")+cCod+cLocal+aArrayF4[nOAT][nPos2]+aArrayF4[nOAT][1]
						cWhile:="SB8->(B8_FILIAL+B8_PRODUTO+B8_LOCAL+B8_LOTECTL+B8_NUMLOTE)"
					Else
						cSeek:=xFilial("SB8")+cCod+cLocal+aArrayF4[nOAT][nPos2]
						cWhile:="SB8->(B8_FILIAL+B8_PRODUTO+B8_LOCAL+B8_LOTECTL)"
					EndIf
					dbSeek(cSeek)
					nSaldoCons:=0
					While !EOF() .And. cSeek == &(cWhile)
						nSaldoCons+=SB8SALDO(,,,,,lEmpPrev,,,.T.)
						dbSkip()
					End
					If IIf(cProg == "A440",aCols[n][nPosQtdLib] > nSaldoCons,aCols[n][nPosQuant] > nSaldoCons)
						If cProg == "A440"
							Aviso(STR0030,STR0045,{"Ok"}) //"Atencao"###"Quantidade informada e maior que a quantidade do lote selecionado, modifique a quantidade do item"
						Else
							Aviso(STR0030,STR0031,{"Ok"}) //"Atencao"###"Quantidade informada e maior que a quantidade disponivel do lote selecionado, modifique a quantidade liberada do item"
						EndIf	
						lRet := .F.
					EndIf	
				EndIf
				If lRet
					If !Empty(cProg) .And. Type('aCols') == 'A'
						If lSLote                                 
							If lLoja
								aColsDet[n][nPosLote]:=aArrayF4[nOAT][1]
							Else
								If lAtNumLote
									aCols[n][nPosLote]:=aArrayF4[nOAT][1]
								EndIf
							EndIf														
						EndIf
						If nLoteCtl == 1
							If lLoja
								aColsDet[n][nPosLotCTL] :=aArrayF4[nOAT][nPos2]
								aColsDet[n][nPosDValid] :=aArrayF4[nOAT][nPos3]
							Else
								aCols[n][nPosLotCTL] :=aArrayF4[nOAT][nPos2]
								aCols[n][nPosDValid] :=aArrayF4[nOAT][nPos3]
							EndIf							
						EndIf	
						If nPosPotenc > 0
							aCols[n][nPosPotenc] :=aArrayF4[nOAT][nPos4]
						EndIf
					Endif
					If Substr(cCpo,7) == "LOTECTL" .Or. Substr(cCpo,7) == "_LOTECT"
						&(ReadVar()) :=  aArrayF4[nOAT][nPos2]
					else
						cCampo :=  aArrayF4[nOAT][nPos2]
						If lSLote
							&(ReadVar()) :=  aArrayF4[nOAT][1]
						EndIf
					Endif
				EndIf	
			EndIf
		EndIf
	Else
		HELP(" ",1,"F4LOTE")
	Endif 
EndIf	
dbSelectArea(cAlias)
dbSetOrder(nOrdem)
dbGoto(nRec)
SetFocus(nHdl)
Return Nil

/*
苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北
北谀哪哪哪哪哪履哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪目北
北?Fun噭o    ?AjustaPosHeaderF4                                          潮?
北媚哪哪哪哪哪拍哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪穆哪哪哪履哪哪哪哪拇北
北?Autor     ?Julio C.Guerato				             ?Data ?22/03/12 潮?
北媚哪哪哪哪哪拍哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪牧哪哪哪聊哪哪哪哪拇北
北?Descri噭o ?Ajuste variaveis nPos caso as mesmas tenham sido alteradas 潮?
北?		  ?o seu posicionamento atrav閟 do pe:  F4LoteHeader		   潮?
北?		  ?As vari醰eis nPosX est鉶 sendo passadas como refer阯cia    潮?
北?          | para serem atualizadas conforme o novo posicionamento      潮?
北媚哪哪哪哪哪拍哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪拇北
北? Uso      ?SigaEST/SIGAPCP                                            潮?
北滥哪哪哪哪哪聊哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪馁北
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北
哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌
*/
Function AjustaPosHeaderF4(aHeaderF4, nPos2, nPos3, nPos4, nPos5, nPos6, nPos7, nPos8)
Local n:=0                                         

nPos2:=iif((n:=AScan(aHeaderF4,{|aHeaderF4| aHeaderF4 == STR0018}))>0,n,nPos2)
nPos3:=iif((n:=AScan(aHeaderF4,{|aHeaderF4| aHeaderF4 == STR0016}))>0,n,nPos3)
nPos4:=iif((n:=AScan(aHeaderF4,{|aHeaderF4| aHeaderF4 == STR0029}))>0,n,nPos4)
nPos5:=iif((n:=AScan(aHeaderF4,{|aHeaderF4| aHeaderF4 == STR0042}))>0,n,nPos5)
nPos6:=iif((n:=AScan(aHeaderF4,{|aHeaderF4| aHeaderF4 == STR0003}))>0,n,nPos6)
nPos7:=iif((n:=AScan(aHeaderF4,{|aHeaderF4| aHeaderF4 == STR0043}))>0,n,nPos7)
nPos8:=iif((n:=AScan(aHeaderF4,{|aHeaderF4| aHeaderF4 == STR0044}))>0,n,nPos8)

Return

/*
苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北
北谀哪哪哪哪哪履哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪目北
北?Fun噭o    ?ListBoxAll()                                               潮?
北媚哪哪哪哪哪拍哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪穆哪哪哪履哪哪哪哪拇北
北?Autor     ?Rodrigo de Almeida Sartorio              ?Data ?05/10/98 潮?
北媚哪哪哪哪哪拍哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪牧哪哪哪聊哪哪哪哪拇北
北?Descri噭o ?Troca marcador entre x e branco para todos itens do array  潮?
北媚哪哪哪哪哪拍哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪拇北
北? Uso      ?SigaEST/SIGAPCP                                            潮?
北滥哪哪哪哪哪聊哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪馁北
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北
哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌
*/
Function ListBoxAll(nRow,nCol,oLbx,oOk,oNo,aArray)
Local oMenu,nChoice:=0,zi
MENU oMenu POPUP
MENUITEM STR0019 ACTION nChoice:=1	//"&Marca Todos"
SEPARATOR
MENUITEM STR0020 ACTION nChoice:=2	//"&Desmarca Todos"
ENDMENU
ACTIVATE POPUP oMenu AT nRow - 60, nCol OF oLbx
// Marca Todos
If nChoice == 1
	For zi:=1 to Len(aArray)
		aArray[zi,1]:=.T.
	Next zi
	// Desmarca Todos
ElseIf nChoice == 2
	For zi:=1 to Len(aArray)
		aArray[zi,1]:=.F.
	Next zi
EndIf
// Atualiza Array
If nChoice == 1 .Or. nChoice == 2
	oLbx:SetArray(aArray)
	oLbx:bLine := { || {If(aArray[oLbx:nAt,1],oOk,oNo),aArray[oLbx:nAt,2]}}
	oLbx:Refresh()
EndIf
Return

/*
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北?
北谀哪哪哪哪穆哪哪哪哪哪履哪哪哪履哪哪哪哪哪哪哪哪哪哪哪履哪哪穆哪哪哪哪哪勘?
北矲un噭o    砯LibRejCQ ?Autor ?Fernando Joly Siquini ?Data ?09/02/99 潮?
北媚哪哪哪哪呐哪哪哪哪哪聊哪哪哪聊哪哪哪哪哪哪哪哪哪哪哪聊哪哪牧哪哪哪哪哪幢?
北矰escri噭o ?Retorna os Itens Liberados e Rejeitados do CQ.             潮?
北媚哪哪哪哪呐哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪幢?
北砈intaxe   ?fLibRejCQ(ExpC1, ExpC2, ExpC3, ExpC4, ExpC5, ExpC6, ExpC7) 潮?
北媚哪哪哪哪呐哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪幢?
北砇etorno	 ?Um Array no seguinte formato:                              潮?
北?      	 ?Array[n,1] = Tipo de Movimenta噭o (0=Qtd.Orig./1=Lib/2=Rej)潮?
北?      	 ?Array[n,2] = Quantidade Movimentada                        潮?
北?      	 ?Array[n,3] = Local Destino da Movimenta噭o                 潮?
北媚哪哪哪哪呐哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪幢?
北砅arametros?ExpC1 = Codigo do Produto;                                 潮?
北?         ?ExpC2 = Numero da NF;                                      潮?
北?         ?ExpC3 = S俽ie da NF;                                       潮?
北?         ?ExpC4 = Codigo do Fornecedor;                              潮?
北?         ?ExpC5 = Loja do Fornecedor;                                潮?
北?         ?ExpC6 = Lote do Produto;                                   潮?
北?         ?ExpC7 = Numero do Item da NF.                              潮?
北媚哪哪哪哪呐哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪幢?
北?Uso      ?Ger俽ico                                                   潮?
北滥哪哪哪哪牧哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪俦?
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北?
哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌?/
Function fLibRejCQ(cProduto, cDocOri, cSerieOri, cCliente, cLoja, cLote, cItemOri)

//-- Inicializa Variaveis Locais
Local cAliAnt    := Alias()
Local nRecAnt    := Recno()
Local nOrdAnt    := Indexord()
Local nSD1Rec    := SD1->(Recno())
Local nSD1Ord    := SD1->(IndexOrd())
Local nSD7Rec    := SD7->(Recno())
Local nSD7Ord    := SD7->(IndexOrd())
Local aRet       := {}
Local cSeekSD1   := xFilial('SD1')+cDocOri+cSerieOri+cCliente+cLoja+cProduto
Local cSeekSD7   := xFilial('SD7')+SD1->D1_NUMCQ+SD1->D1_COD+SD1->D1_LOCAL
Local lAchou     := .F.

//-- Reinicializa Variaveis
cLote := IF(cLote==NIL,cLote:=Space(6),cLote)

//-- Inicializa Ordens dos Arquivos utilizados na Fun噭o
SD1->(dbSetOrder(1))
SD7->(dbSetOrder(1))

//-- Procura Notas originarias da Movimenta噭o no CQ
If SD1->(dbSeek(cSeekSD1, .F.))
	//-- Verifica se esta posicionado no item correto
	If cItemOri # NIL
		Do While !SD1->(Eof()) .And. ;
			cSeekSD1 == SD1->D1_FILIAL+SD1->D1_DOC+SD1->D1_SERIE+SD1->D1_FORNECE+SD1->D1_LOJA+SD1->D1_COD
			If SD1->D1_ITEM == cItemOri
				lAchou := .T.
				Exit
			EndIf
			SD1->(dbSkip())
		EndDo
		SD1->(dbGoto(If(!lAchou,nSD1Rec,SD1->(Recno()))))
		cSeekSD7 := xFilial('SD7')+SD1->D1_NUMCQ+SD1->D1_COD+SD1->D1_LOCAL
	EndIf
	//-- Procura a Movimenta噭o no CQ referente a Nota Original
	If SD7->(dbSeek(cSeekSD7, .F.))
		Do While !SD7->(Eof()) .And. ;
			cSeekSD7 == SD7->D7_FILIAL+SD7->D7_NUMERO+SD7->D7_PRODUTO+SD7->D7_LOCAL
			If SD7->D7_TIPO >= 1.And.SD7->D7_TIPO <= 2.And.SD7->D7_ESTORNO # 'S'
				If (nPos:=aScan(aRet,{|x|x[1]==SD7->D7_TIPO.And.x[3]==SD7->D7_LOCDEST}))==0
					aAdd(aRet, {0,0,''})
					nPos := Len(aRet)
					aRet[nPos, 1] := SD7->D7_TIPO
					aRet[nPos, 3] := SD7->D7_LOCDEST
				EndIf
				aRet[nPos, 2] += SD7->D7_QTDE
			ElseIf SD7->D7_TIPO == 0
				aAdd(aRet, {0, SD7->D7_SALDO, SD7->D7_LOCAL})
			EndIf
			SD7->(dbSkip())
		EndDo
	EndIf
EndIf

SD1->(dbSetOrder(nSD1Ord))
SD1->(dbGoto(nSD1Rec))
SD7->(dbSetOrder(nSD7Ord))
SD7->(dbGoto(nSD7Rec))
dbSelectArea(cAliAnt)
dbSetOrder(nOrdAnt)
dbGoto(nRecAnt)

Return aRet


/*/
苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘?
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北?
北谀哪哪哪哪穆哪哪哪哪哪履哪哪履哪哪哪哪哪哪哪哪哪哪哪哪穆哪哪哪履哪哪哪哪目北
北矲un噮o    矲4LotePesq矨utor砅atricia A. Salomao       ?Data ?4.07.00  潮?
北媚哪哪哪哪呐哪哪哪哪哪聊哪哪聊哪哪哪哪哪哪哪哪哪哪哪哪牧哪哪哪聊哪哪哪哪拇北
北矰escri噮o 砄rdena o ListBox de acordo com a opcao escolhida no ComboBox 潮?
北媚哪哪哪哪呐哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪拇北
北砅arametros矱xpC1	: Opcao escolhida no ComboBox ( 1-Lote / 2-Validade   潮?
北?         矱xpA2	: Array contendo as informacoes dos Lotes             潮?
北?         矱xpC3	: Objeto ListBox                                      潮?
北媚哪哪哪哪呐哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪拇北
北?Uso      矲uncao F4Lote()                                              潮?
北滥哪哪哪哪牧哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪馁北
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北
哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌
/*/
Function F4LotePesq(cCombo,aArrayF4,oQual)

Local nPosicao := aScan(oQual:aHeaders,cCombo)

aArrayF4:=aSort( aArrayF4,,, { | x , y | x[nPosicao] < y[nPosicao] } )
oQual:Refresh()

Return ( .T. )

/*
苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北
北谀哪哪哪哪穆哪哪哪哪哪哪履哪哪履哪哪哪哪哪哪哪哪哪哪哪履哪哪穆哪哪哪哪哪目北
北矲un噮o    矴ravaSDG    矨utor砅atricia A. Salomao    ?Data ?6.10.2001 潮?
北媚哪哪哪哪呐哪哪哪哪哪哪聊哪哪聊哪哪哪哪哪哪哪哪哪哪哪聊哪哪牧哪哪哪哪哪拇北
北矰escri噮o 矴rava Custo do Movimento de Transporte                       潮?
北媚哪哪哪哪呐哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪拇北
北砅arametros矱xpC1 - Alias do Arquivo                                     潮?
北?         矱xpC2 - Tipo de Rateio (Veiculo/Viagem ou Frota)             潮?
北?         矱xpA1 - Array contendo Rateio por Veiculo/Viagem ou por Frota潮?
北?         矱xpA2 - Array Contendo os Custos do Item rateado             潮?
北?         矱xpC3 - Numero do Documento                                  潮?
北?         矱xpC4 - Codigo da Despesa de Transporte                      潮?
北?         矱xpL1 - Indica se o programa que originou o Rateio e' de Movi潮?
北?         ?       mentos Internos (Mata240/Mata241)                    潮?
北?         矱xpC5 - Numero da Sequencia                                  潮?
北?         矱xpD1 - Data de Vencimento                                   潮?
北?         矱xpN1 - Valor Cobrado                                        潮?
北媚哪哪哪哪呐哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪拇北
北?Uso      矴enerico                                                     潮?
北滥哪哪哪哪牧哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪馁北
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北
哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌
*/
Function GravaSDG(cAlias,cTpRateio,aDados,aCustoVei,cDoc,cCodDesp,lMovim,cSeqSDG,dDatVenc,nValCob)

DEFAULT cAlias    := ""
DEFAULT cTpRateio := ""
DEFAULT aDados    := {}
DEFAULT aCustoVei := {}
DEFAULT cDoc      := NextNumero("SDG",1,"DG_DOC",.T.)
DEFAULT cCodDesp  := ""
DEFAULT lMovim    := .F.
DEFAULT cSeqSDG   := &(cAlias+"->"+Subs(cAlias,2,2)+"_NUMSEQ")
DEFAULT dDatVenc  := dDataBase
DEFAULT nValCob   := 0

RecLock("SDG",.T.)
SDG->DG_ORIGEM   := cAlias
SDG->DG_FILIAL   := xFilial("SDG")
SDG->DG_DOC      := cDoc
SDG->DG_EMISSAO  := &(cAlias+"->"+Subs(cAlias,2,2)+"_EMISSAO")
SDG->DG_SEQMOV   := &(cAlias+"->"+Subs(cAlias,2,2)+"_NUMSEQ")
SDG->DG_TES      := &(cAlias+"->"+Subs(cAlias,2,2)+If(lMovim,"_TM","_TES"))
SDG->DG_CODDES   := cCodDesp
SDG->DG_NUMSEQ   := cSeqSDG
SDG->DG_SEQORI   := cSeqSDG
SDG->DG_DATVENC  := dDatVenc
SDG->DG_VALCOB   := nValCob
SDG->DG_SALDO    := nValCob
SDG->DG_STATUS   := StrZero(1,Len(SDG->DG_STATUS)) //-- Em Aberto

If Len(aDados) > 0
	//谀哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪目
	//砎erifica se o rateio foi feito por Veiculo/Viagem ou por Frota.       ?
	//砪TpRateio == "V" - Rateio do Item da NF foi feito por Veiculo/Viagem. ?
	//砪TpRateio == "F" - Rateio do Item da NF foi feito por Frota           ?	
	//滥哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪馁	
	SDG->DG_ITEM     := aDados[1]                          			
	SDG->DG_CODVEI   := If(cTpRateio=="V", aDados[2], "")
	SDG->DG_FILORI   := If(cTpRateio=="V", aDados[3], "")
	SDG->DG_VIAGEM   := If(cTpRateio=="V", aDados[4], "")
	SDG->DG_TOTAL    := If(cTpRateio=="V", aDados[5], aCustoVei[1])
	If Len(aCustoVei) > 0
		SDG->DG_CUSTO1 := aCustoVei[1]
		SDG->DG_CUSTO2 := aCustoVei[2]
		SDG->DG_CUSTO3 := aCustoVei[3]
		SDG->DG_CUSTO4 := aCustoVei[4]
		SDG->DG_CUSTO5 := aCustoVei[5]
		SDG->DG_PERC   := aCustoVei[6]
	EndIf	
EndIf

DT7->(dbSetOrder(1))
If 	DT7->(MsSeek(xFilial('DT7')+cCodDesp))
	SDG->DG_CLVL    := DT7->DT7_CLVL
	SDG->DG_ITEMCTA := DT7->DT7_ITEMCT
	SDG->DG_CONTA   := DT7->DT7_CONTA
	SDG->DG_CC      := DT7->DT7_CC
EndIf

MsUnlock()
Return

/*
苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘?
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北?
北谀哪哪哪哪穆哪哪哪哪哪哪履哪哪履哪哪哪哪哪哪哪哪哪哪哪履哪哪穆哪哪哪哪哪勘?
北矲un噮o    矱stornaSDG  矨utor砅atricia A. Salomao    ?Data ?6.10.2001潮?
北媚哪哪哪哪呐哪哪哪哪哪哪聊哪哪聊哪哪哪哪哪哪哪哪哪哪哪聊哪哪牧哪哪哪哪哪幢?
北矰escri噮o 矱storna o Custo do Movimento de Transporte (Integracao TMS) 潮?
北媚哪哪哪哪呐哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪幢?
北砅arametros矱xpC1 - Alias do Arquivo                                    潮?
北?         矱xpC2 - Numeracao Sequencial                                潮?
北?         矱xpL1 - Contabilizacao On Line ?                            潮?
北?         矱xpN1 - Cabecalho do Lancamento Contabil                    潮?
北?         矱xpN2 - Total do Lancamento Contabil (@)                    潮?
北?         矱xpC3 - Lote para Lancamento Contabil                       潮?
北?         矱xpC4 - Nome do Programa                                    潮?
北媚哪哪哪哪呐哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪幢?
北?Uso      矼ata103/Mata240/Mata241/Tmsa070                             潮?
北滥哪哪哪哪牧哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪俦?
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北?
哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌?
*/
Function EstornaSDG(cAlias,cNumSeq,lCtbOnLine,nHdlPrv,nTotalLcto,cLote,cProg)

Local aAreaAnt     := GetArea()
Local aAreaSDG     := SDG->(GetArea())
Default cNumSeq    := &(cAlias+"->"+Subs(cAlias,2,2)+"_NUMSEQ")
Default lCtbOnLine := .F.
Default nHdlPrv    := 0
Default nTotalLcto := 0
Default cLote      := ""
Default cProg      := 'MATA103'

dbSelectArea('SDG')
dbSetOrder(7)
If MsSeek(xFilial("SDG")+cAlias+cNumSeq)    
	Do While !Eof() .And. DG_FILIAL+DG_ORIGEM+DG_SEQMOV == xFilial('SDG')+cAlias+cNumSeq
		If lCtbOnLine .And. nHdlPrv <> 0 
		   If !Empty(SDG->DG_DTLANC)
				nTotalLcto+=DetProva(nHdlPrv,"902",cProg,cLote)
			EndIf	                                            
			If  !Empty(SDG->DG_DTLAEMI)
				nTotalLcto+=DetProva(nHdlPrv,"904",cProg,cLote)
			EndIf			
		EndIf	
		Reclock("SDG",.F.)
		dbDelete()
		MsUnLock()
		SDG->(dbSkip())     
	EndDo	
EndIf	

RestArea(aAreaAnt)
RestArea(aAreaSDG)

Return

/*/
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北
北谀哪哪哪哪穆哪哪哪哪哪履哪哪哪履哪哪哪哪哪哪哪哪哪哪哪履哪哪穆哪哪哪哪哪目北
北矲un噭o    矲4NfOri   ?Autor ?Eduardo Riera         ?Data ?7.02.2001 潮?
北媚哪哪哪哪呐哪哪哪哪哪聊哪哪哪聊哪哪哪哪哪哪哪哪哪哪哪聊哪哪牧哪哪哪哪哪拇北
北?         矷nterface de visualizacao dos documentos de entrada/saida    潮?
北?         硃ara devolucao                                               潮?
北媚哪哪哪哪呐哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪拇北
北砅arametros矱xpC1: Nome da rotina chamadora                              潮?
北?         矱xpN2: Numero da linha da rotina chamadora              (OPC)潮?
北?         矱xpC4: Nome do campo GET em foco no momento             (OPC)潮?
北?         矱xpC5: Codigo do Cliente/Fornecedor                          潮?
北?         矱xpC6: Loja do Cliente/Fornecedor                            潮?
北?         矱xpC7: Codigo do Produto                                     潮?
北?         矱xpC8: Local a ser considerado                               潮?
北?         矱xpN9: Numero do recno do SD1/SD2                            潮?
北媚哪哪哪哪呐哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪拇北
北砇etorno   砃enhum                                                       潮?
北?         ?                                                            潮?
北媚哪哪哪哪呐哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪拇北
北矰escri噭o 矱sta rotina tem como objetivo atualizar os eventos vinculados潮?
北?         砤 uma solicitacao de compra:                                 潮?
北?         矨) Atualizacao das tabelas complementares.                   潮?
北?         矪) Atualizacao das informacoes complementares a SC           潮?
北?         ?                                                            潮?
北媚哪哪哪哪呐哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪拇北
北砋so       ?Materiais                                                   潮?
北滥哪哪哪哪牧哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪馁北
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北
哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌
/*/
Function F4NfOri(cRotina,nLinha,cReadVar,cCliFor,cLoja,cProduto,cPrograma,cLocal,nRecSD2,nRecSD1)

Local aArea     := GetArea()
Local aAreaSF1  := SF1->(GetArea())
Local aAreaSF2  := SF2->(GetArea())
Local aAreaSD1  := SD1->(GetArea())
Local aAreaSD2  := SD2->(GetArea())
Local aStruTRB  := {}
Local aStruSD1  := {}
Local aStruSD2  := {}
Local aStruSF1  := {}
Local aStruSF2  := {}
Local aValor    := {}
Local aOrdem    := {AllTrim(RetTitle("F2_DOC"))+"+"+AllTrim(RetTitle("F2_SERIE")),AllTrim(RetTitle("F2_EMISSAO"))}
Local aChave    := {}
Local aPesq     := {}
Local aNomInd   := {}
Local aObjects  := {}
Local aInfo     := {}
Local aPosObj   := {}
Local aSize     := MsAdvSize( .F. )
Local aHeadTRB  := {}
Local aSavHead  := aClone(aHeader)
Local cAliasSD1 := "SD1"
Local cAliasSD2 := "SD2"
Local cAliasSF1 := "SF1"
Local cAliasSF2 := "SF2"
Local cAliasSF4 := "SF4"
Local cAliasTRB := "F4NFORI"
Local cNomeTrb  := ""
Local cQuery    := ""
Local cCombo    := ""
Local cTexto1   := ""
Local cTexto2   := ""
Local lRetorno  := .F.
Local lSkip     := .F.
Local cTpCliFor := "C"
Local nX        := 0
Local nY        := 0
Local nSldQtd   := 0
Local nSldQtd2  := 0
Local nSldLiq   := 0
Local nSldBru   := 0
Local nHdl      := GetFocus()
Local nOpcA     := 0
Local nPNfOri   := 0
Local nPSerOri  := 0
Local nPItemOri := 0
Local nPLocal   := 0
Local nPPrUnit  := 0
Local nPPrcVen  := 0
Local nPQuant   := 0
Local nPQuant2UM:= 0
Local nPLoteCtl := 0
Local nPNumLote := 0
Local nPDtValid := 0
Local nPPotenc  := 0
Local nPValor   := 0
Local nPValDesc := 0
Local nPDesc    := 0
Local nPOrigem  := 0
Local nPDespacho:= 0
Local nPTES     := 0
Local nPProvEnt := 0
Local nPConcept := 0
Local nD1Fabric := 0
Local nPPeso	:= 0
Local nFciCod   := 0
Local nPCC      := 0 // Posici髇 Centro de Costo
Local xPesq     := ""
Local oDlg
Local oCombo
Local oGet
Local oGetDb
Local oPanel
Local cFiltraQry:=""
Local lFiltraQry:=ExistBlock('F4NFORI')
Local lUsaNewKey:= TamSX3("F2_SERIE")[1] == 14 // Verifica se o novo formato de gravacao do Id nos campos _SERIE esta em uso
Local lUUID     := cPrograma == "A100" .AND. cPaisLoc == "MEX"  .and. funname() $ "MATA465N" // Activaci髇 de campos 
Local lDescSai  := IIF(cPaisLoc == "BRA",SuperGetMV("MV_DESCSAI",.F.,"2"),SuperGetMV("MV_DESCSAI",.F.,"1")) == "1"
Local cCtrl     := CHR(13) + CHR(10) // Salto de l韓ea para los UUID Relacionados
Local nUniaduD1 	:= 0		
Local nUsdaduD1 	:= 0		
Local nValaduD1 	:= 0		
Local nCanaduD1 	:= 0
Local nFraccaD1 	:= 0		


DEFAULT cReadVar := ReadVar()

PRIVATE aRotina  := {}


For nX := 1 To 11	// Walk_Thru
	aAdd(aRotina,{"","",0,0})
Next

If ("_NFORI"$cReadVar) .Or. ( lUsaNewKey .And. ("_SERIORI"$cReadVar .Or. "_ITEMORI"$cReadVar )  )
	Do Case
		Case cPrograma $ "A440|A466|LOJA920"
			cTpCliFor := "F"
			aChave    := {"D1_DOC+D1_SERIE","D1_EMISSAO"}
			aPesq     := {{Space(Len(SD1->D1_DOC+SD1->D1_SERIE)),"@!"},{Ctod(""),"@!"}}
			//谀哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪?
			//?Montagem do arquivo temporario dos itens do SD1                     ?
			//滥哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪?
			dbSelectArea("SX3")
			dbSetOrder(1)
			MsSeek("SD1")
			While !Eof() .And. SX3->X3_ARQUIVO == "SD1" 
				If ( X3USO(SX3->X3_USADO) .And. cNivel >= SX3->X3_NIVEL .And.;
					Trim(SX3->X3_CAMPO) <> "D1_COD" .And.;
					SX3->X3_CONTEXT<>"V" .And.;
					SX3->X3_TIPO<>"M" ) .Or.;
					Trim(SX3->X3_CAMPO) == "D1_DOC" .Or.;
					Trim(SX3->X3_CAMPO) == "D1_SERIE"  .Or.;
					Trim(SX3->X3_CAMPO) == "D1_EMISSAO" .Or.;
					Trim(SX3->X3_CAMPO) == "D1_TIPO"					
					aadd(aHeadTrb,{ TRIM(X3Titulo()),;
						SX3->X3_CAMPO,;
						SX3->X3_PICTURE,;
						SX3->X3_TAMANHO,;
						SX3->X3_DECIMAL,;
						SX3->X3_VALID,;
						SX3->X3_USADO,;
						SX3->X3_TIPO,;
						SX3->X3_ARQUIVO,;
						SX3->X3_CONTEXT,;
						IIf(AllTrim(SX3->X3_CAMPO)$"D1_DOC#D1_SERIE#D1_ITEM#D1_TIPO","00",SX3->X3_ORDEM) })
					aadd(aStruTRB,{SX3->X3_CAMPO,SX3->X3_TIPO,SX3->X3_TAMANHO,SX3->X3_DECIMAL,IIf(AllTrim(SX3->X3_CAMPO)$"D1_DOC#D1_SERIE#D1_ITEM","00",SX3->X3_ORDEM)})
					If Trim(SX3->X3_CAMPO) == "D1_VUNIT"
						aadd(aHeadTrb,{ OemToAnsi(STR0025),; //"Valor Liquido"
							"D1_V_UNIT2",;
							SX3->X3_PICTURE,;
							SX3->X3_TAMANHO,;
							SX3->X3_DECIMAL,;
							SX3->X3_VALID,;
							SX3->X3_USADO,;
							SX3->X3_TIPO,;
							SX3->X3_ARQUIVO,;
							SX3->X3_CONTEXT,;
							IIf(AllTrim(SX3->X3_CAMPO)$"D1_DOC#D1_SERIE#D1_ITEM#D1_TIPO","00",SX3->X3_ORDEM) })
						aadd(aStruTRB,{"D1_V_UNIT2",SX3->X3_TIPO,SX3->X3_TAMANHO,SX3->X3_DECIMAL,IIf(AllTrim(SX3->X3_CAMPO)$"D1_DOC#D1_SERIE#D1_ITEM","00",SX3->X3_ORDEM)})
					EndIf
				EndIf				
				dbSelectArea("SX3")
				dbSkip()
			EndDo
			//谀哪哪哪哪哪哪哪哪哪哪哪哪哪目
			//砏alk-Thru                   ?
			//滥哪哪哪哪哪哪哪哪哪哪哪哪哪馁	
			ADHeadRec("SD1",aHeadTrb)
			aSize(aHeadTrb[Len(aHeadTrb)-1],11)
			aSize(aHeadTrb[Len(aHeadTrb)],11)
			aHeadTrb[Len(aHeadTrb)-1,11] := "ZY"
			aHeadTrb[Len(aHeadTrb),11]	 := "ZZ"
			aadd(aStruTRB,{"D1_ALI_WT","C",3,0,"ZY"})
			aadd(aStruTRB,{"D1_REC_WT","N",18,0,"ZZ"})

			aHeadTrb := aSort(aHeadTrb,,,{|x,y| x[11] < y[11]})
			aStruTrb := aSort(aStruTrb,,,{|x,y| x[05] < y[05]})

			cNomeTrb := FWOpenTemp(cAliasTRB,aStruTRB,,.T.)

			dbSelectArea(cAliasTRB)
			For nX := 1 To Len(aChave)
				aAdd( aNomInd , StrTran( (SubStr( cNomeTrb, 1 , 7 ) + Chr( 64 + nX ) ), "_" , "") )
				IndRegua(cAliasTRB,aNomInd[nX],aChave[nX])
			Next nX
			dbClearIndex()
			For nX := 1 To Len(aNomInd)
				dbSetIndex(aNomInd[nX])
			Next nX
			//谀哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪?
			//?Atualizacao do arquivo temporario com base nos itens do SD1         ?
			//滥哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪?		
			If lFiltraQry
				cFiltraQry	:=	ExecBlock('F4NFORI',.F.,.F.,{"SD1",cPrograma,cClifor,cLoja})
				If ValType(cFiltraQry) <> 'C'
					cFiltraQry	:=	''
				Endif	
			Endif
			dbSelectArea("SF1")
			dbSetOrder(2)
		    cAliasSF1 := "F4NFORI_SQL"
		    cAliasSD1 := "F4NFORI_SQL"			    
		    cAliasSF4 := "F4NFORI_SQL"			    			    
		    aStruSF1 := SF1->(dbStruct())
		    aStruSD1 := SD1->(dbStruct())
			cQuery := "	SELECT	"
			cQuery += "		SF4.F4_PODER3,	"
			cQuery += "		SD1.R_E_C_N_O_ D1_REC_WT,	"
			cQuery += "		SF1.F1_FILIAL, SF1.F1_FORNECE, SF1.F1_LOJA, SF1.F1_TIPO, SF1.F1_DOC, SF1.F1_SERIE,	"
			cQuery += "		SD1.D1_FILIAL, SD1.D1_COD, SD1.D1_TIPO, SD1.D1_DOC, SD1.D1_SERIE, SD1.D1_FILIAL, SD1.D1_FORNECE,	"
			cQuery += "		SD1.D1_LOJA, SD1.D1_QTDEDEV, SD1.D1_VALDEV, SD1.D1_ORIGLAN, SD1.D1_TES	"
			If cPaisLoc <> "BRA"
				cQuery += "	,SD1.D1_TIPODOC	"
			EndIf
			For nX := 1 To Len(aStruTRB)
				If !"D1_REC_WT"$aStruTRB[nX][1] .And. !"D1_ALI_WT"$aStruTRB[nX][1] .And. !"D1_V_UNIT2"$aStruTRB[nX][1]
					cQuery += ","+aStruTRB[nX][1]
				EndIf
			Next nX
			cQuery += "		FROM	" +	RetSqlName("SF1")+" SF1,	"
			cQuery +=  					RetSqlName("SD1")+"	SD1,	"
			cQuery +=  RetSqlName("SF4")+" SF4 "				
			cQuery += "		WHERE "
			cQuery += "			SF1.F1_FILIAL = '"+xFilial("SF1")+"' AND	"
			cQuery += "			SF1.F1_FORNECE = '"+cCliFor+"' AND	"
			cQuery += "			SF1.F1_LOJA = '"+cLoja+"' AND	"
			cQuery += "			SF1.D_E_L_E_T_=' ' AND	"
			cQuery += "			SD1.D1_FILIAL='"+xFilial("SD1")+"' AND	"
			cQuery += "			SD1.D1_FORNECE=SF1.F1_FORNECE AND	"
			cQuery += "			SD1.D1_LOJA=SF1.F1_LOJA AND	"
			cQuery += "			SD1.D1_DOC=SF1.F1_DOC AND	"
			cQuery += "			SD1.D1_SERIE=SF1.F1_SERIE AND	"
			cQuery += "			SD1.D1_TIPO=SF1.F1_TIPO AND	"
			cQuery += "			SD1.D1_COD='"+cProduto+"' AND	"
			cQuery += "			SD1.D1_ORIGLAN<>'LF' AND	"
			cQuery += "			SD1.D_E_L_E_T_=' ' AND	"
			cQuery += "			SF4.F4_FILIAL='"+xFilial("SF4")+"' AND	"
			cQuery += "			SF4.F4_CODIGO=SD1.D1_TES AND	"
			cQuery += "			SF4.D_E_L_E_T_=' '	"
		    If !Empty(cFiltraQry)
				cQuery += "	AND	"+cFiltraQry
	        Endif
			cQuery += "	ORDER BY	"+SqlOrder(SF1->(IndexKey()))
			
			cQuery := ChangeQuery(cQuery)
			dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasSF1,.T.,.T.)
			
			For nX := 1 To Len(aStruSD1)
				If aStruSD1[nX][2] <> "C" 
					TcSetField(cAliasSF1,aStruSD1[nX][1],aStruSD1[nX][2],aStruSD1[nX][3],aStruSD1[nX][4])
				EndIf				
			Next nX
			For nX := 1 To Len(aStruSF1)
				If aStruSF1[nX][2] <> "C" 
					TcSetField(cAliasSF1,aStruSF1[nX][1],aStruSF1[nX][2],aStruSF1[nX][3],aStruSF1[nX][4])
				EndIf				
			Next nX				

			While !Eof() .And. (cAliasSF1)->F1_FILIAL = xFilial("SF1") .And.;
				(cAliasSF1)->F1_FORNECE == cCliFor .And.;
				(cAliasSF1)->F1_LOJA == cLoja
				lSkip := .F.
				While !Eof() .And. xFilial("SD1") == (cAliasSD1)->D1_FILIAL .And.;
					cProduto == (cAliasSD1)->D1_COD .And.;
					(cAliasSF1)->F1_DOC == (cAliasSD1)->D1_DOC .And.;
					(cAliasSF1)->F1_SERIE == (cAliasSD1)->D1_SERIE .And.;
					(cAliasSF1)->F1_FORNECE == (cAliasSD1)->D1_FORNECE .And.;
					(cAliasSF1)->F1_LOJA == (cAliasSD1)->D1_LOJA
					

					If (cAliasSF4)->F4_PODER3 == "N" .And. !Empty((cAliasSD1)->D1_TES) .And. (cAliasSD1)->D1_ORIGLAN<>"LF" .And. (cAliasSD1)->D1_TIPO<>"D"
						
						If Empty(cFiltraQry) .Or.  ValType(cFiltraQry) == "C"
				        	If cPaisloc = "BRA" .or. Iif( "MATA102" $ Funname(), (cAliasSD1)->D1_TIPODOC >= "50", (cAliasSD1)->D1_TIPODOC < "50" ) 
								aValor := A410SNfOri((cAliasSD1)->D1_FORNECE,(cAliasSD1)->D1_LOJA,(cAliasSD1)->D1_DOC,(cAliasSD1)->D1_SERIE,(cAliasSD1)->D1_ITEM,(cAliasSD1)->D1_COD,,cLocal,cAliasSD1)
								nSldQtd:= aValor[1]
								nSldQtd2:=ConvUm((cAliasSD1)->D1_COD,nSldQtd,0,2)
								nSldLiq:= aValor[2]			
								If cPrograma $ "A466" .And. cPaisLoc <>"BRA" .And. nSldLiq == 0 .And. ((cAliasSD1)->D1_TOTAL-(cAliasSD1)->D1_VALDESC) == 0  // Item com desconto total
									nSldBru:= (cAliasSD1)->D1_TOTAL
								Else
									nSldBru:= nSldLiq+A410Arred(nSldLiq*(cAliasSD1)->D1_VALDESC/((cAliasSD1)->D1_TOTAL-(cAliasSD1)->D1_VALDESC),"C6_VALOR")
								EndIf					
								If ( IIF( cPrograma $ "LOJA920", nSldQtd <> 0,  nSldQtd <> 0 .Or. nSldLiq <> 0 ) )
									If Empty(aValor[3])
										RecLock(cAliasTRB,.T.)
										For nX := 1 To Len(aStruTRB)
											//FieldPos necess醨io para n鉶 realizar o FieldPut nos campos virtuais. Ex.: D1_V_UNIT2
											If !(AllTrim(aStruTRB[nX][1]) $ "D1_ALI_WT|D1_REC_WT|D1_V_UNIT2")
												If (cAliasSD1)->(FieldPos(aStruTRB[nX][1]))<>0
													(cAliasTRB)->(FieldPut(nX,(cAliasSD1)->(FieldGet(FieldPos(aStruTRB[nX][1])))))
												EndIf
											EndIf	
										Next nX
										(cAliasTRB)->D1_QUANT := a410Arred(nSldQtd,"C6_QTDVEN")
										(cAliasTRB)->D1_QTSEGUM:= a410Arred(nSldQtd2,"C6_UNSVEN")
										(cAliasTRB)->D1_TOTAL := a410Arred(nSldBru,"C6_VALOR")
										(cAliasTRB)->D1_VUNIT := a410Arred(nSldBru/IIf(nSldQtd==0,1,nSldQtd),"C6_PRCVEN")
										If Abs((cAliasTRB)->D1_VUNIT-(cAliasSD1)->D1_VUNIT)<0.01
											(cAliasTRB)->D1_VUNIT := (cAliasSD1)->D1_VUNIT
										EndIf
										If (cAliasTRB)->D1_VALDESC>0
											(cAliasTRB)->D1_V_UNIT2:= a410Arred(nSldLiq/IIf(nSldQtd==0,1,nSldQtd),"C6_PRCVEN")
										Else
											(cAliasTRB)->D1_V_UNIT2:= (cAliasTRB)->D1_VUNIT
										EndIf
										(cAliasTRB)->D1_ALI_WT := "SD1"
										MsUnLock()
									Else
										For nY := 1 To Len(aValor[3])
											RecLock(cAliasTRB,.T.)
											For nX := 1 To Len(aStruTRB)
												If !(AllTrim(aStruTRB[nX][1]) $ "D1_ALI_WT|D1_REC_WT|D1_V_UNIT2")
													(cAliasTRB)->(FieldPut(nX,(cAliasSD1)->(FieldGet(FieldPos(aStruTRB[nX][1])))))
												EndIf	
											Next nX
											(cAliasTRB)->D1_VUNIT := a410Arred(nSldBru/IIf(nSldQtd==0,1,nSldQtd),"C6_PRCVEN")
											If Abs((cAliasTRB)->D1_VUNIT-(cAliasSD1)->D1_VUNIT)<0.01
												(cAliasTRB)->D1_VUNIT := (cAliasSD1)->D1_VUNIT
											EndIf
											If (cAliasTRB)->D1_VALDESC>0
												(cAliasTRB)->D1_V_UNIT2:= a410Arred(nSldLiq/IIf(nSldQtd==0,1,nSldQtd),"C6_PRCVEN")
											Else
												(cAliasTRB)->D1_V_UNIT2:= (cAliasTRB)->D1_VUNIT
											EndIf
											(cAliasTRB)->D1_QUANT  := a410Arred(aValor[3][nY][1],"C6_QTDVEN")
											(cAliasTRB)->D1_QTSEGUM:= a410Arred(aValor[3][nY][2],"C6_UNSVEN")
											(cAliasTRB)->D1_TOTAL  := a410Arred(aValor[3][nY][1]*(cAliasTRB)->D1_V_UNIT2,"C6_VALOR")
											(cAliasTRB)->D1_LOCAL  := aValor[3][nY][3]
											(cAliasTRB)->D1_ALI_WT := "SD1"
											MsUnLock()
										Next nY
									EndIf
								EndIf
							EndIf
						Endif
				    EndIf
					dbSelectArea(cAliasSD1)
					dbSkip()
					lSkip := .T.
				EndDo
			EndDo
			dbSelectArea(cAliasSF1)
			dbCloseArea()
			dbSelectArea("SF1")	
		OtherWise
			cTpCliFor := "C"
			aChave    := {"D2_DOC+D2_SERIE","D2_EMISSAO"}
			aPesq     := {{Space(Len(SD2->D2_DOC+SD2->D2_SERIE)),"@!"},{Ctod(""),"@!"}}
			//谀哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪?
			//?Montagem do arquivo temporario dos itens do SF2                     ?
			//滥哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪?
			If lUUID 
				dbSelectArea("SX3")
				dbSetOrder(1)
				MsSeek("SF2")
				While !Eof() .And. SX3->X3_ARQUIVO == "SF2" 
					If ( X3USO(SX3->X3_USADO) .And. cNivel >= SX3->X3_NIVEL .And.;
						SX3->X3_CONTEXT<>"V") .And.;
						Trim(SX3->X3_CAMPO) == "F2_FECTIMB" .Or.;
						Trim(SX3->X3_CAMPO) == "F2_UUID"  				
						aadd(aHeadTrb,{ TRIM(X3Titulo()),;
							SX3->X3_CAMPO,;
							SX3->X3_PICTURE,;
							SX3->X3_TAMANHO,;
							SX3->X3_DECIMAL,;
							SX3->X3_VALID,;
							SX3->X3_USADO,;
							SX3->X3_TIPO,;
							SX3->X3_ARQUIVO,;
							SX3->X3_CONTEXT,;
							IIf(AllTrim(SX3->X3_CAMPO)$"D1_DOC#D1_SERIE#D1_ITEM#D1_TIPO","00",SX3->X3_ORDEM) })
						aadd(aStruTRB,{SX3->X3_CAMPO,SX3->X3_TIPO,SX3->X3_TAMANHO,SX3->X3_DECIMAL,IIf(AllTrim(SX3->X3_CAMPO)$"D1_DOC#D1_SERIE#D1_ITEM","00",SX3->X3_ORDEM)})
					EndIf
					SX3->(dbSkip())
				EndDo
			EndIf
			//谀哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪?
			//?Montagem do arquivo temporario dos itens do SD2                     ?
			//滥哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪?
			dbSelectArea("SX3")
			dbSetOrder(1)
			MsSeek("SD2")
			While !Eof() .And. SX3->X3_ARQUIVO == "SD2"
				If ( X3USO(SX3->X3_USADO) .And. cNivel >= SX3->X3_NIVEL .And.;
					Trim(SX3->X3_CAMPO) <> "D2_COD" .And.;
					SX3->X3_CONTEXT <> "V"  .And.;
					SX3->X3_TIPO<>"M" ) .Or.;
					Trim(SX3->X3_CAMPO) == "D2_DOC" .Or.;
					Trim(SX3->X3_CAMPO) == "D2_SERIE"  .Or.;
					Trim(SX3->X3_CAMPO) == "D2_EMISSAO" .Or.;
					Trim(SX3->X3_CAMPO) == "D2_TIPO" .Or.;
					Trim(SX3->X3_CAMPO) == "D2_PRUNIT" .Or. ;
					Trim(SX3->X3_CAMPO) == "D2_DESCZFR"
					Aadd(aHeadTrb,{ TRIM(X3Titulo()),;
						SX3->X3_CAMPO,;
						SX3->X3_PICTURE,;
						SX3->X3_TAMANHO,;
						SX3->X3_DECIMAL,;
						SX3->X3_VALID,;
						SX3->X3_USADO,;
						SX3->X3_TIPO,;
						SX3->X3_ARQUIVO,;
						SX3->X3_CONTEXT,;
						IIf(AllTrim(SX3->X3_CAMPO)$"D2_DOC#D2_SERIE#D2_ITEM#D2_TIPO","00",SX3->X3_ORDEM) })
					aadd(aStruTRB,{SX3->X3_CAMPO,SX3->X3_TIPO,SX3->X3_TAMANHO,SX3->X3_DECIMAL,IIf(AllTrim(SX3->X3_CAMPO)$"D2_DOC#D2_SERIE#D2_ITEM","00",SX3->X3_ORDEM)})
				EndIf				
				dbSelectArea("SX3")
				dbSkip()
			EndDo
			//谀哪哪哪哪哪哪哪哪哪哪哪哪哪目
			//砏alk-Thru                   ?
			//滥哪哪哪哪哪哪哪哪哪哪哪哪哪馁	
			ADHeadRec("SD2",aHeadTrb)
			aSize(aHeadTrb[Len(aHeadTrb)-1],11)
			aSize(aHeadTrb[Len(aHeadTrb)],11)
			aHeadTrb[Len(aHeadTrb)-1,11] := "ZX"
			aHeadTrb[Len(aHeadTrb),11]	 := "ZY"
			aadd(aStruTRB,{"D2_ALI_WT","C",3,0,"ZX"})
			aadd(aStruTRB,{"D2_REC_WT","N",18,0,"ZY"})

			aadd(aStruTRB,{"D2_TOTAL2","N",18,2,"ZZ"})
			aHeadTrb := aSort(aHeadTrb,,,{|x,y| x[11] < y[11]})
			aStruTrb := aSort(aStruTrb,,,{|x,y| x[05] < y[05]})

			cNomeTrb := FWOpenTemp(cAliasTRB,aStruTRB,,.T.)

			dbSelectArea(cAliasTRB)
			For nX := 1 To Len(aChave)
				aAdd( aNomInd , StrTran( (SubStr( cNomeTrb, 1 , 7 ) + Chr( 64 + nX ) ), "_" , "") )
				IndRegua(cAliasTRB,aNomInd[nX],aChave[nX])
			Next nX
			dbClearIndex()
			For nX := 1 To Len(aNomInd)
				dbSetIndex(aNomInd[nX])
			Next nX
			//谀哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪?
			//?Atualizacao do arquivo temporario com base nos itens do SD2         ?
			//滥哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪?
			If lFiltraQry
				cFiltraQry	:=	ExecBlock('F4NFORI',.F.,.F.,{"SD2",cPrograma,cClifor,cLoja})
				If ValType(cFiltraQry) <> 'C'
					cFiltraQry	:=	''
				Endif	
			Endif
			dbSelectArea("SF2")
			dbSetOrder(2)

		    cAliasSF2 := "F4NFORI_SQL"
		    cAliasSD2 := "F4NFORI_SQL"			    
		    cAliasSF4 := "F4NFORI_SQL"			    			    
		    aStruSF2 := SF2->(dbStruct())
		    aStruSD2 := SD2->(dbStruct())
			cQuery := "SELECT SF4.F4_PODER3,SD2.R_E_C_N_O_ SD2RECNO,"
			cQuery += "SF2.F2_FILIAL,SF2.F2_CLIENTE,SF2.F2_LOJA,"
			If lUUID
				cQuery += "SF2.F2_FECTIMB,SF2.F2_UUID, "
			EndIF
			cQuery += "SF2.F2_TIPO,SF2.F2_DOC,SF2.F2_SERIE,SD2.D2_FILIAL,SD2.D2_COD,"
			cQuery += "SD2.D2_TIPO,SD2.D2_DOC,SD2.D2_SERIE,SD2.D2_FILIAL,SD2.D2_CLIENTE,"
			cQuery += "SD2.D2_LOJA,SD2.D2_QTDEDEV,SD2.D2_VALDEV,SD2.D2_ORIGLAN,SD2.D2_TES,SD2.D2_TIPOREM "
			If cPaisLoc <> "BRA"
				cQuery += ",SD2.D2_TIPODOC "
			EndIf
			For nX := 1 To Len(aStruTRB)
				If !"D2_REC_WT"$aStruTRB[nX][1] .And. !"D2_ALI_WT"$aStruTRB[nX][1] .And. !"D2_TOTAL2"$aStruTRB[nX][1]
					cQuery += ","+aStruTRB[nX][1]
				EndIf
			Next nX
			cQuery += " FROM "+RetSqlName("SF2")+" SF2,"
			cQuery +=  RetSqlName("SD2")+" SD2,"
			cQuery +=  RetSqlName("SF4")+" SF4 "
			cQuery += "WHERE "
			cQuery += "SF2.F2_FILIAL = '"+xFilial("SF2")+"' AND "
			cQuery += "SF2.F2_CLIENTE = '"+cCliFor+"' AND "
			cQuery += "SF2.F2_LOJA = '"+cLoja+"' AND "
			If lUUID
				cQuery += "SF2.F2_UUID <> ' ' AND "
			EndIF
			cQuery += "SF2.D_E_L_E_T_=' ' AND "
			cQuery += "SD2.D2_FILIAL='"+xFilial("SD2")+"' AND "
			cQuery += "SD2.D2_CLIENTE=SF2.F2_CLIENTE AND "
			cQuery += "SD2.D2_LOJA=SF2.F2_LOJA AND "
			cQuery += "SD2.D2_DOC=SF2.F2_DOC AND "
			cQuery += "SD2.D2_SERIE=SF2.F2_SERIE AND "        
			cQuery += "SD2.D2_TIPO=SF2.F2_TIPO AND "
			
			IF cTipo == "N" // Tipo da nota de entrada
				cQuery += "F2_TIPO = 'B' AND " // Tipo da nota de sa韉a
			ELSE
			   cQuery += "F2_TIPO not in('B','D') AND " // Tipo da nota de sa韉a
			ENDIF
			cQuery += "SD2.D2_COD='"+cProduto+"' AND "
			cQuery += "SD2.D2_ORIGLAN<>'LF' AND "
			cQuery += "SD2.D_E_L_E_T_=' ' AND "
			cQuery += "SF4.F4_FILIAL='"+xFilial("SF4")+"' AND "	
			cQuery += "SF4.F4_CODIGO=SD2.D2_TES AND "
			cQuery += "SF4.D_E_L_E_T_=' ' "
			
	      	If !Empty(cFiltraQry)
				cQuery += " AND "+cFiltraQry
      		Endif
			cQuery += "ORDER BY "+SqlOrder(SF2->(IndexKey()))
			
			cQuery := ChangeQuery(cQuery)

			dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasSF2,.T.,.T.)
							
			For nX := 1 To Len(aStruSD2)
				If aStruSD2[nX][2] <> "C" 
					TcSetField(cAliasSF2,aStruSD2[nX][1],aStruSD2[nX][2],aStruSD2[nX][3],aStruSD2[nX][4])
				EndIf				
			Next nX
			For nX := 1 To Len(aStruSF2)
				If aStruSF2[nX][2] <> "C" 
					TcSetField(cAliasSF2,aStruSF2[nX][1],aStruSF2[nX][2],aStruSF2[nX][3],aStruSF2[nX][4])
				EndIf				
			Next nX				

			While !Eof() .And. (cAliasSF2)->F2_FILIAL = xFilial("SF2") .And.;
				(cAliasSF2)->F2_CLIENTE == cCliFor .And.;
				(cAliasSF2)->F2_LOJA == cLoja
				lSkip := .F.

				While !Eof() .And. xFilial("SD2") == (cAliasSD2)->D2_FILIAL .And.;
					cProduto == (cAliasSD2)->D2_COD .And.;
					(cAliasSF2)->F2_DOC == (cAliasSD2)->D2_DOC .And.;
					(cAliasSF2)->F2_SERIE == (cAliasSD2)->D2_SERIE .And.;
					(cAliasSF2)->F2_CLIENTE == (cAliasSD2)->D2_CLIENTE .And.;
					(cAliasSF2)->F2_LOJA == (cAliasSD2)->D2_LOJA

					
					If (cAliasSD2)->D2_TIPO ==(cAliasSF2)->F2_TIPO .And. ( (cAliasSF4)->F4_PODER3 == "N" .Or. ((cAliasSF4)->F4_PODER3 == "R" .And. (cAliasSD2)->D2_TIPOREM == "A")) .And. !Empty((cAliasSD2)->D2_TES) .And. (cAliasSD2)->D2_ORIGLAN<>"LF" .And. (cAliasSD2)->D2_TIPO<>"D"
												
			      		If Empty(cFiltraQry) .Or. ValType(cFiltraQry) == "C"
			         		If cPaisloc = "BRA" .or. Iif( "MATA462" $ Funname(), (cAliasSD2)->D2_TIPODOC >= "50", (cAliasSD2)->D2_TIPODOC < "50" )
								nSldQtd:= (cAliasSD2)->D2_QUANT-(cAliasSD2)->D2_QTDEDEV
								nSldQtd2:=ConvUm((cAliasSD2)->D2_COD,nSldQtd,0,2)
								nSldBru:= (cAliasSD2)->D2_TOTAL+((cAliasSD2)->D2_DESCON+(cAliasSD2)->D2_DESCZFR)-(cAliasSD2)->D2_VALDEV
								If cPrograma $ "A140I"
									nPNfOri   := aScan(aHeader,{|x| AllTrim(x[2])=="DT_NFORI"})
									nPSerOri  := aScan(aHeader,{|x| AllTrim(x[2])=="DT_SERIORI"})
									nPItemOri := aScan(aHeader,{|x| AllTrim(x[2])=="DT_ITEMORI"})
									nPValor   := aScan(aHeader,{|x| AllTrim(x[2])=="DT_TOTAL"})
									nPQuant   := aScan(aHeader,{|x| AllTrim(x[2])=="DT_QUANT"})
								Else
									//谀哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪?
									//?Verifica a quantidade ja informada no Documento de Entrada          ?
									//滥哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪?							
									nPNfOri   := aScan(aHeader,{|x| AllTrim(x[2])=="D1_NFORI"})
									nPSerOri  := aScan(aHeader,{|x| AllTrim(x[2])=="D1_SERIORI"})
									nPItemOri := aScan(aHeader,{|x| AllTrim(x[2])=="D1_ITEMORI"})
									nPValor   := aScan(aHeader,{|x| AllTrim(x[2])=="D1_TOTAL"})
									nPQuant   := aScan(aHeader,{|x| AllTrim(x[2])=="D1_QUANT"})
									nPQuant2UM:= aScan(aHeader,{|x| AllTrim(x[2])=="D1_QTSEGUM"})
								EndIf
								For nX := 1 To Len(aCols)
									If nX <> N .And.;
											!aCols[nX][Len(aHeader)+1] .And.;
											aCols[nX][nPNfOri] == (cAliasSD2)->D2_DOC .And.;
											aCols[nX][nPSerOri] == (cAliasSD2)->D2_SERIE .And.;
											aCols[nX][nPItemOri] == (cAliasSD2)->D2_ITEM
										nSldQtd -= aCols[nX][nPQuant]
										nSldBru -= aCols[nX][nPValor]
									EndIf
								Next nX
								nSldQtd2:=ConvUm((cAliasSD2)->D2_COD,nSldQtd,0,2)
								nSldLiq:= nSldBru-A410Arred(nSldBru*((cAliasSD2)->D2_DESCON+(cAliasSD2)->D2_DESCZFR)/((cAliasSD2)->D2_TOTAL+((cAliasSD2)->D2_DESCON+(cAliasSD2)->D2_DESCZFR)),"C6_VALOR")
								//谀哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪?
								//?Atualiza o arquivo de trabalho                                      ?
								//滥哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪?
								If nSldQtd <> 0 .Or. nSldLiq <> 0
									RecLock(cAliasTRB,.T.)
									For nX := 1 To Len(aStruTRB)
										If !(AllTrim(aStruTRB[nX][1]) $ "D2_ALI_WT|D2_REC_WT|D2_TOTAL2")
											(cAliasTRB)->(FieldPut(nX,(cAliasSD2)->(FieldGet(FieldPos(aStruTRB[nX][1])))))
										EndIf	
									Next nX
									(cAliasTRB)->D2_QUANT := a410Arred(nSldQtd,"C6_QTDVEN")
									(cAliasTRB)->D2_QTSEGUM:= a410Arred(nSldQtd2,"C6_UNSVEN")
									(cAliasTRB)->D2_TOTAL := a410Arred(nSldLiq,"C6_VALOR")
									(cAliasTRB)->D2_TOTAL2:= a410Arred(nSldBru,"C6_VALOR")
									(cAliasTRB)->D2_PRCVEN:= a410Arred(nSldLiq/IIf(nSldQtd==0,1,nSldQtd),"C6_PRCVEN")
									If Abs((cAliasTRB)->D2_PRCVEN-(cAliasSD2)->D2_PRCVEN)<= 0.01
										(cAliasTRB)->D2_PRCVEN := (cAliasSD2)->D2_PRCVEN
									EndIf
									If (cAliasTRB)->D2_DESCON+(cAliasTRB)->D2_DESCZFR>0
										(cAliasTRB)->D2_PRUNIT:= a410Arred(nSldBru/IIf(nSldQtd==0,1,nSldQtd),"C6_PRCVEN")
									Else
										(cAliasTRB)->D2_PRUNIT := (cAliasTRB)->D2_PRCVEN
									EndIf
									(cAliasTRB)->D2_REC_WT:= (cAliasSD2)->SD2RECNO
									(cAliasTRB)->D2_ALI_WT := "SD2"
									MsUnLock()
								EndIf
							EndIf
				  		EndIf
					Endif
					dbSelectArea(cAliasSD2)
					dbSkip()
					lSkip := .T.
				EndDo
				If !lSkip
					dbSelectArea(cAliasSF2)
					dbSkip()
				EndIf
			EndDo
	
		(cAliasSF2)->(dbCloseArea())
						
	EndCase
	If (cAliasTRB)->(LastRec())<>0
		PRIVATE aHeader := aHeadTRB
		xPesq := aPesq[(cAliasTRB)->(IndexOrd())][1]
		//谀哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪?
		//?Posiciona registros                                                 ?
		//滥哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪?
		If cTpCliFor == "C"
			dbSelectArea("SA1")
			dbSetOrder(1)
			MsSeek(xFilial("SA1")+cCliFor+cLoja)
		Else
			dbSelectArea("SA2")
			dbSetOrder(1)
			MsSeek(xFilial("SA2")+cCliFor+cLoja)
		EndIf
		dbSelectArea("SB1")
		dbSetOrder(1)
		MsSeek(xFilial("SB1")+cProduto)
		
		dbSelectArea(cAliasTRB)
		dbGotop()	
		//谀哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪?
		//?Calcula as coordenadas da interface                                 ?
		//滥哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪?
		aSize[1] /= 1.5
		aSize[2] /= 1.5
		aSize[3] /= 1.5
		aSize[4] /= 1.3
		aSize[5] /= 1.5
		aSize[6] /= 1.3
		aSize[7] /= 1.5
		
		AAdd( aObjects, { 100, 020,.T.,.F.,.T.} )
		AAdd( aObjects, { 100, 060,.T.,.T.} )
		AAdd( aObjects, { 100, 020,.T.,.F.} )
		aInfo   := { aSize[ 1 ], aSize[ 2 ], aSize[ 3 ], aSize[ 4 ], 3, 3 } 
		aPosObj := MsObjSize( aInfo, aObjects,.T.)
	
		//谀哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪?
		//?Interface com o usuario                                             ?
		//滥哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪?
		DEFINE MSDIALOG oDlg TITLE OemToAnsi(STR0007) FROM aSize[7],000 TO aSize[6],aSize[5] OF oMainWnd PIXEL //"Notas Fiscais de Origem"
		@ aPosObj[1,1],aPosObj[1,2] MSPANEL oPanel PROMPT "" SIZE aPosObj[1,3],aPosObj[1,4] OF oDlg CENTERED LOWERED
		If cTpCliFor == "C" 
			cTexto1 := AllTrim(RetTitle("F2_CLIENTE"))+"/"+AllTrim(RetTitle("F2_LOJA"))+": "+SA1->A1_COD+"/"+SA1->A1_LOJA+"  -  "+RetTitle("A1_NOME")+": "+SA1->A1_NOME
		Else
			cTexto1 := AllTrim(RetTitle("F1_FORNECE"))+"/"+AllTrim(RetTitle("F1_LOJA"))+": "+SA2->A2_COD+"/"+SA2->A2_LOJA+"  -  "+RetTitle("A2_NOME")+": "+SA2->A2_NOME	
		EndIf
		@ 002,005 SAY cTexto1 SIZE aPosObj[1,3],008 OF oPanel PIXEL
		cTexto2 := AllTrim(RetTitle("B1_COD"))+": "+SB1->B1_COD+"/"+SB1->B1_DESC
		@ 012,005 SAY cTexto2 SIZE aPosObj[1,3],008 OF oPanel PIXEL	
		
		@ aPosObj[3,1]+00,aPosObj[3,2]+00 SAY OemToAnsi(STR0027) PIXEL //Pesquisar por:
		@ aPosObj[3,1]+12,aPosObj[3,2]+00 SAY OemToAnsi(STR0026) PIXEL //Localizar
		@ aPosObj[3,1]+00,aPosObj[3,2]+40 MSCOMBOBOX oCombo VAR cCombo ITEMS aOrdem SIZE 100,044 OF oDlg PIXEL ;
		VALID ((cAliasTRB)->(dbSetOrder(oCombo:nAt)),(cAliasTRB)->(dbGotop()),xPesq := aPesq[(cAliasTRB)->(IndexOrd())][1],.T.)
	  	@ aPosObj[3,1]+12,aPosObj[3,2]+40 MSGET oGet VAR xPesq Of oDlg PICTURE aPesq[(cAliasTRB)->(IndexOrd())][2] PIXEL ;
	  	VALID ((cAliasTRB)->(MsSeek(Iif(ValType(xPesq)=="C",AllTrim(xPesq),xPesq),.T.)),.T.).And.IIf(oGetDb:oBrowse:Refresh()==Nil,.T.,.T.)
	  	
	  	oGetDb := MsGetDB():New(aPosObj[2,1],aPosObj[2,2],aPosObj[2,3],aPosObj[2,4],1,"Allwaystrue","allwaystrue","",.F., , ,.F., ,cAliasTRB)
		
		DEFINE SBUTTON FROM aPosObj[3,1]+000,aPosObj[3,4]-030 TYPE 1 ACTION (nOpcA := 1,oDlg:End()) ENABLE OF oDlg
		DEFINE SBUTTON FROM aPosObj[3,1]+012,aPosObj[3,4]-030 TYPE 2 ACTION (nOpcA := 0,oDlg:End()) ENABLE OF oDlg
		ACTIVATE MSDIALOG oDlg CENTERED
		
		If nOpcA == 1
			lRetorno := .T.
			aHeader   := aClone(aSavHead)
			Do Case
		 		Case cPrograma $ "A440|A466|LOJA920"
					If cPrograma $ "LOJA920|A466"
			 			nPNfOri   := aScan(aHeader,{|x| AllTrim(x[2])=="D2_NFORI"})
			 			nPSerOri  := aScan(aHeader,{|x| AllTrim(x[2])=="D2_SERIORI"})
			 			nPItemOri := aScan(aHeader,{|x| AllTrim(x[2])=="D2_ITEMORI"})
			 			nPLocal   := aScan(aHeader,{|x| AllTrim(x[2])=="D2_LOCAL"})
			 			nPPrcVen  := aScan(aHeader,{|x| AllTrim(x[2])=="D2_PRCVEN"})
			 			nPQuant   := aScan(aHeader,{|x| AllTrim(x[2])=="D2_QUANT"})
			 			nPQuant2UM:= aScan(aHeader,{|x| AllTrim(x[2])=="D2_QTSEGUM"})
			 			nPLoteCtl := aScan(aHeader,{|x| AllTrim(x[2])=="D2_LOTECTL"})
			 			nPNumLote := aScan(aHeader,{|x| AllTrim(x[2])=="D2_NUMLOTE"})
			 			nPDtValid := aScan(aHeader,{|x| AllTrim(x[2])=="D2_DTVALID"})
			 			nPPotenc  := aScan(aHeader,{|x| AllTrim(x[2])=="D2_POTENCI"})
			 			nPValor   := aScan(aHeader,{|x| AllTrim(x[2])=="D2_TOTAL"})
			 			nPValDesc := aScan(aHeader,{|x| AllTrim(x[2])=="D2_DESCON"})
			 			nPDesc    := aScan(aHeader,{|x| AllTrim(x[2])=="D2_DESC"})
						nPTES     := aScan(aHeader,{|x| AllTrim(x[2])=="D2_TES"})
						nPProvEnt := aScan(aHeader,{|x| AllTrim(x[2])=="D2_PROVENT"})
						nPConcept := aScan(aHeader,{|x| AllTrim(x[2])=="D2_CONCEPT"})
		 		    Else
			 			nPNfOri   := aScan(aHeader,{|x| AllTrim(x[2])=="C6_NFORI"})
			 			nPSerOri  := aScan(aHeader,{|x| AllTrim(x[2])=="C6_SERIORI"})
			 			nPItemOri := aScan(aHeader,{|x| AllTrim(x[2])=="C6_ITEMORI"})
			 			nPLocal   := aScan(aHeader,{|x| AllTrim(x[2])=="C6_LOCAL"})
			 			nPPrUnit  := aScan(aHeader,{|x| AllTrim(x[2])=="C6_PRUNIT"})
			 			nPPrcVen  := aScan(aHeader,{|x| AllTrim(x[2])=="C6_PRCVEN"})
			 			nPQuant   := aScan(aHeader,{|x| AllTrim(x[2])=="C6_QTDVEN"})
			 			nPQuant2UM:= aScan(aHeader,{|x| AllTrim(x[2])=="C6_UNSVEN"})
			 			nPLoteCtl := aScan(aHeader,{|x| AllTrim(x[2])=="C6_LOTECTL"})
			 			nPNumLote := aScan(aHeader,{|x| AllTrim(x[2])=="C6_NUMLOTE"})
			 			nPDtValid := aScan(aHeader,{|x| AllTrim(x[2])=="C6_DTVALID"})
			 			nPPotenc  := aScan(aHeader,{|x| AllTrim(x[2])=="C6_POTENCI"})
			 			nPValor   := aScan(aHeader,{|x| AllTrim(x[2])=="C6_VALOR"})
			 			nPValDesc := aScan(aHeader,{|x| AllTrim(x[2])=="C6_VALDESC"})
						nPTES     := aScan(aHeader,{|x| AllTrim(x[2])=="C6_TES"})
						nPProvEnt := aScan(aHeader,{|x| AllTrim(x[2])=="C6_PROVENT"})
					Endif
					If cPaisLoc <> "BRA"
						If nPTES <> 0
							SF4->(DbSetOrder(1))
							If SF4->(MsSeek(xFilial("SF4")+(cAliasTRB)->D1_TES)) .And. !Empty(SF4->F4_TESDV)
								aCols[N][nPTES] := SF4->F4_TESDV
							Endif
			 			Endif
			 			If nPProvEnt <> 0 
			 				aCols[N][nPProvEnt] := (cAliasTRB)->D1_PROVENT
			 			Endif
			 		Endif
		 			If nPNfOri <> 0
		 				aCols[N][nPNfOri] := (cAliasTRB)->D1_DOC
		 			EndIf
		 			If nPSerOri <> 0
		 				aCols[N][nPSerOri] := (cAliasTRB)->D1_SERIE
		 			EndIf
	 				If nPItemOri <> 0
		 				aCols[N][nPItemOri] := (cAliasTRB)->D1_ITEM
	 				EndIf
	 				If nPPrUnit <> 0
		 				aCols[N][nPPrUnit] := (cAliasTRB)->D1_VUNIT
		 			EndIf
		 			If nPPrcVen <> 0
		 				If AllTrim( Upper( cPrograma ) ) == "LOJA920"    
			 				aCols[N][nPPrcVen] := (cAliasTRB)->D1_VUNIT
		 				Else
			 				aCols[N][nPPrcVen] := (cAliasTRB)->D1_V_UNIT2
			 			EndIf
		 			EndIf           
		 			If nPLocal <> 0
		 				aCols[N][nPLocal] := (cAliasTRB)->D1_LOCAL
		 			EndIf
		 			If nPQuant <> 0 .And. (aCols[N][nPQuant] > (cAliasTRB)->D1_QUANT .Or. aCols[N][nPQuant] == 0 )
						aCols[N][nPQuant] := (cAliasTRB)->D1_QUANT
						If nPQuant2UM <> 0
							aCols[N][nPQuant2UM] := (cAliasTRB)->D1_QTSEGUM
						EndIf
					EndIf
					If nPConcept <> 0 
			 				aCols[N][nPConcept] := (cAliasTRB)->D1_CONCEPT
			 		Endif
					If Rastro(cProduto) .And. ( SF4->(dbSeek(xFilial("SF4")+aCols[N][nPTES])) .And. SF4->F4_ESTOQUE == 'S' )
						If nPLoteCtl <> 0
							aCols[N][nPLoteCtl] := (cAliasTRB)->D1_LOTECTL
						EndIf
						If nPNumLote <> 0
							aCols[N][nPNumLote] := (cAliasTRB)->D1_NUMLOTE
						EndIf
						If nPDtValid <> 0 .Or. npPotenc <> 0
							dbSelectArea("SB8")
							dbSetOrder(3)
							If MsSeek(xFilial("SB8")+cProduto+aCols[N][nPLocal]+aCols[n][nPLoteCtl]+IIf(Rastro(cProduto,"S"),aCols[N][nPNumLote],""))
								If nPDtValid <> 0
									aCols[n][nPDtValid] := SB8->B8_DTVALID
								EndIf
								If npPotenc <> 0	
									aCols[n][nPPotenc] := SB8->B8_POTENCI
								EndIf
							EndIf
						EndIf
					EndIf
					If cPrograma $ "A440"
						A410MultT("C6_QTDVEN",aCols[N,nPQuant])	
						A410MultT("C6_PRCVEN",aCols[N,nPPrcVen])
					Endif
					//谀哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪?
					//?Ajusta o valor total do documento de saida qdo houver dev. total    ?
					//滥哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪?
					If nPValDesc <> 0
						aCols[n][nPValDesc] := a410Arred((cAliasTRB)->D1_VALDESC,"C6_VALDESC")
						If cPrograma $ "A440" .And. aCols[n][nPValDesc]<>0
							A410MultT("C6_VALDESC",aCols[n][nPValDesc])  
						EndIf
						If AllTrim( Upper( cPrograma ) ) == "LOJA920"
							aCols[n][nPValDesc] := (cAliasTRB)->D1_VALDESC
						EndIf
					EndIf
					
					If nPValDesc <> 0 .And. nPQuant <> 0 .And. nPDesc <> 0 .And. AllTrim( Upper( cPrograma ) ) == "LOJA920"
						aCols[n][nPDesc]    :=  (cAliasTRB)->D1_DESC
					EndIf

					If aCols[n,nPQuant] == (cAliasTRB)->D1_QUANT .And. (cAliasTRB)->D1_QUANT <> 0 .And.;
						Abs((aCols[N,nPValor]+aCols[n][nPValDesc])-(cAliasTRB)->D1_TOTAL)<=0.49
							aCols[N,nPValor] := (cAliasTRB)->D1_TOTAL-(cAliasTRB)->D1_VALDESC
						If cPrograma $ "A440"
							A410MultT("C6_VALOR",aCols[N,nPValor])
						Endif
					EndIf
					//谀哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪?
					//?Ajusta o valor total do documento de saida qdo nao for Brasil       ?
					//滥哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪?
					If cPrograma $ "A466" .and. cPaisLoc <>"BRA"
						aCols[N,nPValor] := (cAliasTRB)->D1_TOTAL-(cAliasTRB)->D1_VALDESC
					EndIf

					If ("_NFORI"$cReadVar)
						&(cReadVar) := (cAliasTRB)->D1_DOC
					EndIf

					If ("_SERIORI"$cReadVar)
						&(cReadVar) := (cAliasTRB)->D1_SERIE
					EndIf

					If ("_ITEMORI"$cReadVar)
						&(cReadVar) := (cAliasTRB)->D1_ITEM
					EndIf

					nRecSD1	:= (cAliasTRB)->D1_REC_WT
				OtherWise			
					nRecSD2	:= (cAliasTRB)->D2_REC_WT
					SD2->(MsGoto(nRecSD2))
					If cPrograma $ "A140I"
						nPNfOri   := aScan(aHeader,{|x| AllTrim(x[2])=="DT_NFORI"})
			 			nPSerOri  := aScan(aHeader,{|x| AllTrim(x[2])=="DT_SERIORI"})
			 			nPItemOri := aScan(aHeader,{|x| AllTrim(x[2])=="DT_ITEMORI"})
			 			nPPrcVen  := aScan(aHeader,{|x| AllTrim(x[2])=="DT_VUNIT"})
			 			nPQuant   := aScan(aHeader,{|x| AllTrim(x[2])=="DT_QUANT"})
			 			nPValor   := aScan(aHeader,{|x| AllTrim(x[2])=="DT_TOTAL"})
			 			nPValDesc := aScan(aHeader,{|x| AllTrim(x[2])=="DT_VALDESC"})
			 			If aCols[N][nPQuant] > (cAliasTRB)->D2_QUANT
							Aviso(STR0030,STR0084,{"Ok"})	// "Quantidade a devolver superior ao item vendido. Efetue a gera玢o do documento e realize o ajuste na pr?nota de entrada."
							lRetorno := .F.
			 			ElseIf aCols[N][nPQuant] <= (cAliasTRB)->D2_QUANT
							If nPNfOri <> 0
				 				aCols[N][nPNfOri] := (cAliasTRB)->D2_DOC
				 			EndIf
				 			If nPSerOri <> 0
				 				aCols[N][nPSerOri] := (cAliasTRB)->D2_SERIE
				 			EndIf
			 				If nPItemOri <> 0
				 				aCols[N][nPItemOri] := (cAliasTRB)->D2_ITEM
			 				EndIf
			 			Else
			 				Help(" ",1,"A410UNIDIF")
							lRetorno := .F.
						EndIf
					Else
			 			nPNfOri   := aScan(aHeader,{|x| AllTrim(x[2])=="D1_NFORI"})
			 			nPSerOri  := aScan(aHeader,{|x| AllTrim(x[2])=="D1_SERIORI"})
			 			nPItemOri := aScan(aHeader,{|x| AllTrim(x[2])=="D1_ITEMORI"})
			 			nPLocal   := aScan(aHeader,{|x| AllTrim(x[2])=="D1_LOCAL"})
			 			nPPrcVen  := aScan(aHeader,{|x| AllTrim(x[2])=="D1_VUNIT"})
			 			nPQuant   := aScan(aHeader,{|x| AllTrim(x[2])=="D1_QUANT"})
			 			nPQuant2UM:= aScan(aHeader,{|x| AllTrim(x[2])=="D1_QTSEGUM"})
			 			nPLoteCtl := aScan(aHeader,{|x| AllTrim(x[2])=="D1_LOTECTL"})
			 			nPNumLote := aScan(aHeader,{|x| AllTrim(x[2])=="D1_NUMLOTE"})
			 			nPDtValid := aScan(aHeader,{|x| AllTrim(x[2])=="D1_DTVALID"})
			 			nPPotenc  := aScan(aHeader,{|x| AllTrim(x[2])=="D1_POTENCI"})
			 			nPValor   := aScan(aHeader,{|x| AllTrim(x[2])=="D1_TOTAL"})
			 			nPValDesc := aScan(aHeader,{|x| AllTrim(x[2])=="D1_VALDESC"})
			 			nPDesc    := aScan(aHeader,{|x| AllTrim(x[2])=="D1_DESC"})
						nPOrigem	 := aScan(aHeader,{|x| AllTrim(x[2])=="D1_ORIGEM"})
						nPDespacho:= aScan(aHeader,{|x| AllTrim(x[2])=="D1_NUMDESP"})
						nPTES     := aScan(aHeader,{|x| AllTrim(x[2])=="D1_TES"})
						nPProvEnt := aScan(aHeader,{|x| AllTrim(x[2])=="D1_PROVENT"})
						nD1Fabric := aScan(aHeader,{|x| AllTrim(x[2])=="D1_DFABRIC"})
						nPPeso	  := aScan(aHeader,{|x| Alltrim(x[2])=="D1_PESO"})
						nFciCod   := aScan(aHeader,{|x| Alltrim(x[2])=="D1_FCICOD"})
						nPCC	  := aScan(aHeader,{|x| AllTrim(x[2])=="D1_CC"})
						
						If cPaisLoc <> "BRA"
							nUniaduD1 := aScan(aHeader,{|x| AllTrim(x[2]) == "D1_UNIADU"})
							nUsdaduD1 := aScan(aHeader,{|x| AllTrim(x[2]) == "D1_USDADU"})
							nValaduD1 := aScan(aHeader,{|x| AllTrim(x[2]) == "D1_VALADU"})
							nCanaduD1 := aScan(aHeader,{|x| AllTrim(x[2]) == "D1_CANADU"})
							nFraccaD1 := aScan(aHeader,{|x| AllTrim(x[2]) == "D1_FRACCA"})	

							If (nUniaduD1 > 0  ,  aCOLS[N][nUniaduD1]:=(cAliasTRB)->D2_UNIADU,)			
							If (nUsdaduD1 > 0  ,  aCOLS[N][nUsdaduD1]:=(cAliasTRB)->D2_USDADU,)	
							If (nValaduD1 > 0  ,  aCOLS[N][nValaduD1]:=(cAliasTRB)->D2_VALADU,)	
							If (nCanaduD1 > 0  ,  aCOLS[N][nCanaduD1]:=(cAliasTRB)->D2_CANADU,)	
							If (nFraccaD1 > 0  ,  aCOLS[N][nFraccaD1]:=(cAliasTRB)->D2_FRACCA,)	
						
							If nPTES <> 0
								SF4->(DbSetOrder(1))
								If SF4->(MsSeek(xFilial("SF4")+(cAliasTRB)->D2_TES)) .And. !Empty(SF4->F4_TESDV)
									aCols[N][nPTES] := SF4->F4_TESDV
								Endif
							Endif
				 			If nPProvEnt <> 0 
				 				aCols[N][nPProvEnt] := (cAliasTRB)->D2_PROVENT
				 			Endif
						EndIf
			 			If nPNfOri <> 0
			 				aCols[N][nPNfOri] := (cAliasTRB)->D2_DOC
			 			EndIf
			 			If nPSerOri <> 0
			 				aCols[N][nPSerOri] := (cAliasTRB)->D2_SERIE
			 			EndIf
		 				If nPItemOri <> 0
			 				aCols[N][nPItemOri] := (cAliasTRB)->D2_ITEM
		 				EndIf
		 				If nPLocal <> 0
			 				aCols[N][nPLocal] := (cAliasTRB)->D2_LOCAL
						EndIf
			 			If nPPrcVen <> 0
							If cPaisLoc == "PER" .And. lDescSai
			 					aCols[N][nPPrcVen] := (cAliasTRB)->D2_PRCVEN
			 				Else
			 					aCols[N][nPPrcVen] := (cAliasTRB)->D2_PRUNIT
							EndIf
			 			EndIf
			 			If nPQuant <> 0 .And. ( aCols[N][nPQuant] > (cAliasTRB)->D2_QUANT .Or. aCols[N][nPQuant]==0 )
							aCols[N][nPQuant] := (cAliasTRB)->D2_QUANT
							If nPQuant2UM <> 0
								aCols[N][nPQuant2UM] := (cAliasTRB)->D2_QTSEGUM
							EndIf
						EndIf
						If Rastro(cProduto) .And. nPTES > 0
							If  ( SF4->(dbSeek(xFilial("SF4")+aCols[N][nPTES])) .And. SF4->F4_ESTOQUE == 'S' )
							If nPLoteCtl <> 0
								aCols[N][nPLoteCtl] := (cAliasTRB)->D2_LOTECTL
							EndIf
							If nPNumLote <> 0
								aCols[N][nPNumLote] := (cAliasTRB)->D2_NUMLOTE
							EndIf
							If nPDtValid <> 0 .or. nPPotenc <> 0 .Or. nPDespacho <> 0 .Or. nPOrigem <> 0
								dbSelectArea("SB8")
								dbSetOrder(3)
								If MsSeek(xFilial("SB8")+cProduto+aCols[N][nPLocal]+aCols[n][nPLoteCtl]+IIf(Rastro(cProduto,"S"),aCols[N][nPNumLote],""))
									If nPDtValid <> 0
										aCols[n][nPDtValid] := SB8->B8_DTVALID
									EndIf
									If nPPotenc <> 0
										aCols[n][nPPotenc] := SB8->B8_POTENCI
									EndIf
									If nPDespacho <> 0 
										aCols[n][nPDespacho] := SB8->B8_NUMDESP
									EndIf
									If nPOrigem <> 0
										aCols[n][nPOrigem] := SB8->B8_ORIGEM
									EndIf
									If nD1Fabric <> 0
										aCols[n][nD1Fabric] := SB8->B8_DFABRIC
									EndIf
								EndIf
							EndIf
							EndIf
						EndIf
						If nPValDesc <> 0 .And. nPQuant <> 0 .And. nPDesc <> 0
							aCols[n][nPValDesc] := a410Arred(((cAliasTRB)->D2_PRUNIT-(cAliasTRB)->D2_PRCVEN)*IIf(aCols[n][nPQuant]==0,1,aCols[n][nPQuant]),"D1_VALDESC")
							aCols[n][nPDesc]    :=  (cAliasTRB)->D2_DESC
						EndIf
						If SD2->D2_QUANT+SD2->D2_QTDEDEV == aCols[n][nPQuant] // devolucao total
							aCols[n][nPValDesc] := (cAliasTRB)->D2_DESCON + (cAliasTRB)->D2_DESCZFR							
							aCols[n][nPValor]	:= (cAliasTRB)->D2_TOTAL + IIF(lDescSai .AND. cPaisLoc $ "ARG|PER",0,(cAliasTRB)->D2_DESCON) + (cAliasTRB)->D2_DESCZFR
						Else
							aCols[n][nPValor] := a410Arred(IIf(aCols[n][nPQuant]==0,1,aCols[n][nPQuant])*aCols[n][nPPrcVen],"D1_TOTAL")
							If aCols[n][nPValor] > (cAliasTRB)->D2_TOTAL2
								aCols[n][nPValor]   := (cAliasTRB)->D2_TOTAL2
								aCols[n][nPValDesc] := (cAliasTRB)->D2_TOTAL2-(cAliasTRB)->D2_TOTAL
							EndIf
						EndIf	
						If nPPeso <> 0
							aCols[n][nPPeso] := (cAliasTRB)->D2_PESO
						EndIf						
						If nFciCod <> 0
						   aCols[n][nFciCod] := (cAliasTRB)->D2_FCICOD
						EndIf					
					EndIf
					
					If lUUID
						If !((cAliasTRB)->F2_UUID $ M->F1_UUIDREL)
							M->F1_UUIDREL +=  (cAliasTRB)->F2_UUID + cCtrl
						EndIf
					EndIF

					If ("_NFORI"$cReadVar)
						&(cReadVar) := (cAliasTRB)->D2_DOC
					EndIf

					If ("_SERIORI"$cReadVar)
						&(cReadVar) := (cAliasTRB)->D2_SERIE
					EndIf

					If ("_ITEMORI"$cReadVar)
						&(cReadVar) := (cAliasTRB)->D2_ITEM
					EndIf
					If nPCC <> 0
						aCols[n][nPCC] := (cAliasTRB)->D2_CCUSTO
					EndIf
			EndCase
		EndIf
	Else
		HELP(" ",1,"F4NAONOTA")
	EndIf
	//谀哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪?
	//?Restaura a integridade da rotina                                    ?
	//滥哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪?
	dbSelectArea(cAliasTRB)
	//谀哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪目
	//矨RQUIVO TEMPORARIO DE MEMORIA (CTREETMP)                            ?
	//矨 funcao MSCloseTemp ira substituir a linha de codigo abaixo:       ?
	//|--> dbCloseArea()                                                   |
	//滥哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪馁	
	FWCloseTemp(cAliasTRB,cNomeTrb)
EndIf
dbSelectArea("SA1")
RestArea(aArea)
SetFocus(nHdl)
Return(lRetorno)

/*
苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘?
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北?
北谀哪哪哪哪穆哪哪哪哪哪履哪哪哪履哪哪哪哪哪哪哪哪哪哪哪履哪哪穆哪哪哪哪哪勘?
北矲un噮o    砅otencLote?Autor ?Rodrigo de A. Sartorio?Data ?17/06/02 潮?
北媚哪哪哪哪呐哪哪哪哪哪聊哪哪哪聊哪哪哪哪哪哪哪哪哪哪哪聊哪哪牧哪哪哪哪哪幢?
北矰escri噮o 砅esquisa se o produto controla potencia de lote             潮?
北媚哪哪哪哪呐哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪幢?
北砈intaxe   ?PotencLote(cProd)    	                                  潮?
北?         ?cProd := Cigo do produto a ser pesquisado no SB1.        潮?
北媚哪哪哪哪呐哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪幢?
北?Uso      ?EST/PCP/FAT/COM	                                          潮?
北滥哪哪哪哪牧哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪俦?
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北?
哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌?
*/
Function PotencLote(cCod)
Local aArea:=GetArea()
Local aAreaSB1:=SB1->(GetArea())
Local lRet:= .F.
SB1->(dbSetOrder(1))
If SB1->B1_FILIAL+SB1->B1_COD # xFilial("SB1")+cCod
	SB1->(dbSeek(xFilial("SB1")+cCod))
EndIf
If !SB1->(Eof()) .And. Rastro(cCod)
	If SB1->B1_CPOTENC $ " 2"
		lRet:=.F.
	Else
		lRet:=.T.
	EndIf	
EndIf	
RestArea(aAreaSB1)
RestArea(aArea)
Return lRet

/*
苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘?
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北?
北谀哪哪哪哪穆哪哪哪哪哪穆哪哪哪穆哪哪哪哪哪哪哪哪哪哪哪履哪哪穆哪哪哪哪哪勘?
北矲un噮o    矲4LoteArray?Autor ?Marcelo Iuspa        ?Data ?20/10/04 潮?
北媚哪哪哪哪呐哪哪哪哪哪牧哪哪哪牧哪哪哪哪哪哪哪哪哪哪哪聊哪哪牧哪哪哪哪哪幢?
北矰escri噮o 砅esquisa se o produto controla potencia de lote             潮?
北媚哪哪哪哪呐哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪幢?
北砈intaxe   ?PotencLote(cProd)    	                                  潮?
北?         ?cProd := Cigo do produto a ser pesquisado no SB1.        潮?
北媚哪哪哪哪呐哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪幢?
北?Uso      ?EST/PCP/FAT/COM	                                          潮?
北滥哪哪哪哪牧哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪俦?
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北?
哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌?
*/
Function F4LoteArray(cProg, lSLote, cAlias, cAliasTop, aArray)
Static lF4LoteArray
Local aRet := {}

If lF4LoteArray == Nil
	lF4LoteArray := ExistBlock("F4LoteArray")
Endif	

If ! lF4LoteArray
	Return(aArray)
Endif	

If (ValType(aRet := ExecBlock("F4LoteArray",.F.,.F.,{cProg, lSLote, cAlias, cAliasTop, aArray}))) == "A"
	Return(aRet)
Else
	Return(aArray)
Endif
Return(.T.)

/*
苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘?
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北?
北谀哪哪哪哪穆哪哪哪哪哪穆哪哪哪穆哪哪哪哪哪哪哪哪哪哪哪履哪哪穆哪哪哪哪哪勘?
北矲un噮o    矼AvalCusOp ?Autor 砇odrigo de A Sartorio ?Data ?08/12/05 潮?
北媚哪哪哪哪呐哪哪哪哪哪牧哪哪哪牧哪哪哪哪哪哪哪哪哪哪哪聊哪哪牧哪哪哪哪哪幢?
北矰escri噮o ?Funcao utilizada para avaliar se custo do movimento interno潮?
北?		 ?deve ser agregado a ordem de producao informada.           潮?
北媚哪哪哪哪呐哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪幢?
北砈intaxe   ?MAvalCusOP(cProduto,cTm)                                   潮?
北?         ?cProduto := Cigo do produto a ser pesquisado no SB1 e    潮?
北?         ?avaliado para custeio.                                     潮?
北?         ?cTm      := Cigo do tipo de movimentacao interna a ser   潮?
北?         ?pesquisada no SF5 e avaliada para custeio.                 潮?
北媚哪哪哪哪呐哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪幢?
北?Uso      ?EST/PCP/FAT/COM	                                          潮?
北滥哪哪哪哪牧哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪俦?
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北?
哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌?
*/
Function MAvalCusOP(cProduto,cTm)
Local lRet := .T.
Local aArea:=GetArea()
Local aAreaSB1:=SB1->(GetArea())
Local aAreaSF5:=SF5->(GetArea())
// Checa se produto permite nao agregar custo
dbSelectArea("SB1")
dbSetOrder(1)
If MsSeek(xFilial("SB1")+cProduto) .And. SB1->B1_AGREGCU == "1"
	// Checa se tipo de movimentacao interna esta configurada para nao agregar custo
	dbSelectArea("SF5")
	dbSetOrder(1)
	If MsSeek(xFilial("SF5")+cTm) .And. SF5->F5_AGREGCU == "2"
		lRet:=.F.
    EndIf
EndIf
// Restaura area original
SB1->(RestArea(aAreaSB1))
SF5->(RestArea(aAreaSF5))

RestArea(aArea)
Return lRet

/*
苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘?
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北?
北谀哪哪哪哪穆哪哪哪哪哪穆哪哪哪穆哪哪哪哪哪哪哪哪哪哪哪履哪哪穆哪哪哪哪哪勘?
北矲un噮o    ?MVULMES   ?Autor 砇odrigo de A Sartorio ?Data ?02/08/06 潮?
北媚哪哪哪哪呐哪哪哪哪哪牧哪哪哪牧哪哪哪哪哪哪哪哪哪哪哪聊哪哪牧哪哪哪哪哪幢?
北矰escri噮o ?Funcao utilizada para retornar o conteudo do parametro     潮?
北?		 ?MVULMES ou a data do parametro MV_DBLQMOV.                 潮?
北媚哪哪哪哪呐哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪幢?
北砈intaxe   ?MVULMES()                                                  潮?
北媚哪哪哪哪呐哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪幢?
北?Uso      ?Generico                                                   潮?
北滥哪哪哪哪牧哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪俦?
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北?
哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌?
*/
Function MVULMES()
Local dRet     := Getmv("MV_ULMES")
Local dDataBloq:= SuperGetMV("MV_DBLQMOV",,dRet)

Return Max(dRet,dDataBloq)

/*
苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北
北谀哪哪哪哪哪履哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪目北
北?Fun噮o    ?MatFilCalc (Original MA330FCalc)                           潮?
北媚哪哪哪哪哪拍哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪穆哪哪哪履哪哪哪哪拇北
北?Autor     ?Microsiga Software S/A                   ?Data ?22/01/06 潮?
北媚哪哪哪哪哪拍哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪牧哪哪哪聊哪哪哪哪拇北
北?Descri噮o ?Funcao para selecao das filiais para calculo por empresa   潮?
北媚哪哪哪哪哪拍哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪拇北
北砅arametros ?ExpL1 = Indica se apresenta tela para selecao              潮?
北?          ?ExpA2 = Lista com as filiais a serem consideradas (Batch)  潮?
北?          ?ExpN6 = 0=Legado/1=CNPJ iguais/2=CNPJ+IE iguais/3=CNPJ Pai 潮?
北衬哪哪哪哪哪拍哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪某北
北砇etorno    ?Array: aFilsCalc[3][n]                                     潮?
北?          ?aFilsCalc[1][n]:           - Logico                        潮?
北?          ?aFilsCalc[2][n]: Filial    - Caracter                      潮?
北?          ?aFilsCalc[3][n]: Descricao - Caracter                      潮?
北?          ?aFilsCalc[4][n]: CNPJ      - Caracter                      潮?
北媚哪哪哪哪哪拍哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪拇北
北? Uso      ?Generico                                                   潮?
北滥哪哪哪哪哪聊哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪馁北
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北
哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌
*/
Function MatFilCalc(lMostratela,aListaFil,lChkUser,lConsolida,nOpca,nValida,lContEmp)
Local aFilsCalc	:= {}
// Variaveis utilizadas na selecao de categorias
Local oChkQual,lQual,oQual,cVarQ
// Carrega bitmaps
Local oOk       := LoadBitmap(GetResources(),"LBOK")
Local oNo       := LoadBitmap(GetResources(),"LBNO")
// Variaveis utilizadas para lista de filiais
Local nx        := 0
Local nAchou    := 0
Local lMtFilcal	:= ExistBlock('MTFILCAL')
Local aRetPE	:= {}           
Local lIsBlind  := IsBlind()

Local aAreaSM0	:= SM0->(GetArea())
Local aSM0      := FWLoadSM0(.T.,,.T.) 

Local cSelCNPJIE:=""
local nSelCNPJIE:=0

Default nValida	:= 0 //0=Legado Sele玢o Livre
Default lMostraTela	:= .F.
Default aListaFil	:= {{.T., cFilAnt}}  
Default lchkUser	:= .T.
Default lConsolida	:= .F.
Default lContEmp 	:= .F.
Default nOpca		:= 1

//-- Carrega filiais da empresa corrente 
lChkUser := !GetAPOInfo("FWFILIAL.PRW")[4] < CTOD("10/01/2013") 

aEval(aSM0,{|x| If(x[SM0_GRPEMP] == cEmpAnt .And.; 
	              Iif (!lContEmp ,x[SM0_EMPRESA] == FWCompany(),.T.) .And.; 
	              (!lChkUser .Or. x[SM0_USEROK].Or. lIsBlind) .And.; 
	              (x[SM0_EMPOK] .Or. lIsBlind),;
		          aAdd(aFilsCalc,{.F.,x[SM0_CODFIL],x[SM0_NOMRED],x[SM0_CGC],Posicione("SM0",1,x[SM0_GRPEMP]+x[SM0_CODFIL],"M0_INSC"), ;
		               Posicione("SM0",1,x[SM0_GRPEMP]+x[SM0_CODFIL],"M0_INSCM")}),;
			      NIL)})

If lConsolida
	aSort(aFilsCalc,,,{|x,y| x[4]+x[5]+x[6]+x[2] < y[4]+y[5]+x[6]+y[2]}) //-- Ordena por CNPJ, IE, Insc.Municipal e Codigo de Filial para facilitar a quebra de rotinas consolidadas
EndIf

//-- Monta tela para selecao de filiais
If lMostraTela
	If lMtFilCal
		//-- Ponto de entrada para montagem de tela alternativa p/ selecao de filiais
		aFilsCalc := If(ValType(aRetPE := ExecBlock('MTFILCAL',.F.,.F.,{aFilsCalc})) == "A",aRetPE,aFilsCalc)
	Else
		DEFINE MSDIALOG oDlg TITLE OemToAnsi(STR0036) STYLE DS_MODALFRAME From 145,0 To 445,628 OF oMainWnd PIXEL
		oDlg:lEscClose := .F.
		@ 05,15 TO 125,300 LABEL OemToAnsi(STR0037) OF oDlg  PIXEL
		If lConsolida
			@ 15,20 LISTBOX oQual VAR cVarQ Fields HEADER "",OemToAnsi(STR0035),OemToAnsi(STR0039),OemToAnsi(STR0054),OemToAnsi(STR0055),OemToAnsi(STR0070) SIZE 273,105 ON DBLCLICK (aFilsCalc:=MtFClTroca(oQual:nAt,aFilsCalc,nValida,@nSelCNPJIE,@cSelCNPJIE),oQual:Refresh()) NoScroll OF oDlg PIXEL
			bLine := {|| {If(aFilsCalc[oQual:nAt,1],oOk,oNo),aFilsCalc[oQual:nAt,2],aFilsCalc[oQual:nAt,3],Transform(aFilsCalc[oQual:nAt,4],"@R 99.999.999/9999-99"),aFilsCalc[oQual:nAt,5],aFilsCalc[oQual:nAt,6]}}
		Else
			@ 15,20 CHECKBOX oChkQual VAR lQual PROMPT OemToAnsi(STR0038) SIZE 50, 10 OF oDlg PIXEL ON CLICK (AEval(aFilsCalc, {|z| z[1] := If(z[1]==.T.,.F.,.T.)}), oQual:Refresh(.F.))
			@ 30,20 LISTBOX oQual VAR cVarQ Fields HEADER "",OemToAnsi(STR0035),OemToAnsi(STR0039),OemToAnsi(STR0054) SIZE 273,090 ON DBLCLICK (aFilsCalc:=MtFClTroca(oQual:nAt,aFilsCalc),oQual:Refresh()) NoScroll OF oDlg PIXEL
			bLine := {|| {If(aFilsCalc[oQual:nAt,1],oOk,oNo),aFilsCalc[oQual:nAt,2],aFilsCalc[oQual:nAt,3],Transform(aFilsCalc[oQual:nAt,4],"@R 99.999.999/9999-99")}}
		EndIf
		oQual:SetArray(aFilsCalc)
		oQual:bLine := bLine
		DEFINE SBUTTON FROM 134,240 TYPE 1 ACTION If(MtFCalOk(@aFilsCalc,.T.,.T.,lConsolida,nValida,@nOpca),oDlg:End(),) ENABLE OF oDlg
		DEFINE SBUTTON FROM 134,270 TYPE 2 ACTION If(MtFCalOk(@aFilsCalc,.F.,.T.,lConsolida,nValida,@nOpca),oDlg:End(),) ENABLE OF oDlg
		ACTIVATE MSDIALOG oDlg CENTERED
	EndIf
//-- Valida lista de filiais passada como parametro
Else
	//-- Checa parametros enviados
	For nX := 1 to Len(aListaFil)
		If (nAchou := aScan(aFilsCalc,{|x| x[2] == aListaFil[nX,2]})) > 0
			aFilsCalc[nAchou,1] := .T.
		EndIf
	Next nX
	//-- Valida e assume somente filial corrente em caso de problema
	If !MtFCalOk(@aFilsCalc,.T.,.F.,lConsolida,nValida,@nOpca)
		For nX := 1 To Len(aFilsCalc)
			//--  Adiciona filial corrente
			aFilsCalc[nX,1] := aFilsCalc[nX,2] == cFilAnt
		Next nX
	EndIf
EndIf
RestArea(aAreaSM0)
Return aFilsCalc

/*
苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北
北谀哪哪哪哪哪履哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪目北
北?Fun噮o    ?MtFCalOk (Original MA330FOk)                               潮?
北媚哪哪哪哪哪拍哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪穆哪哪哪履哪哪哪哪拇北
北?Autor     ?Microsiga Software S/A                   ?Data ?22/01/06 潮?
北媚哪哪哪哪哪拍哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪牧哪哪哪聊哪哪哪哪拇北
北?Descri噮o ?Checa marcacao das filiais para calculo por empresa        潮?
北媚哪哪哪哪哪拍哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪拇北
北砅arametros ?ExpA1 = Array com a selecao das filiais                    潮?
北?          ?ExpL2 = Valida array de filiais (.t. se ok e .f. se cancel)潮?
北?          ?ExpL3 = Mostra tela de aviso no caso de inconsistencia     潮?
北?          ?ExpL4 = Indica se consolida ou n鉶 o arquivo			   潮?
北?          ?ExpN5 = 0=Legado/1=CNPJ iguais/2=CNPJ+IE iguais/3=CNPJ Raiz潮?
北?          ?4=CNPJ+IE+Inscr.Municipal iguais                           潮?
北媚哪哪哪哪哪拍哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪拇北
北? Uso      ?Generico                                                   潮?
北滥哪哪哪哪哪聊哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪馁北
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北
哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌
*/
Static Function MtFCalOk(aFilsCalc,lValidaArray,lMostraTela,lConsolida,nValida)
Local lRet    	:= .F.
Local nX   	  	:= 0
Local nOpca		:= 0
Local nPos		:= 0
Local aEmpresas := {}

Default lMostraTela := .T.
Default lConsolida	:= .F.
Default nValida		:= 0

If !lValidaArray
	aFilsCalc := {}
	lRet := .T.
Else
	//-- Checa se existe alguma filial marcada na confirmacao
	If !(lRet := aScan(aFilsCalc,{|x| x[1]}) > 0) .And. lMostraTela
		Aviso(OemToAnsi(STR0034),OemToAnsi(STR0040),{"Ok"})
	EndIf

	//-- Se rotina consolidada, valida se todas as filiais da empresa (CNPJ+IE) foram marcadas
	If lRet .And. lConsolida
		For nX := 1 To Len(aFilsCalc)
			If nValida == 1         		// CNPJ Igual
				nPos := aScan(aEmpresas,{|x| x[3] == aFilsCalc[nX,4]})
			ElseIf nValida == 2			// CNPJ + I.E. iguais
				nPos := aScan(aEmpresas,{|x| x[1] == aFilsCalc[nX,4]+aFilsCalc[nX,5]})
			ElseIf nValida == 3			// CNPJ Raiz
				nPos := aScan(aEmpresas,{|x| x[4] == Substr(aFilsCalc[nX,4],1,8)})
			ElseIf nValida == 4			// CNPJ + Insc.Municipal iguais
				nPos := aScan(aEmpresas,{|x| x[5] == aFilsCalc[nX,4]+aFilsCalc[nX,6] })
			Else						// Legado - n鉶 valida
				nPos := 0
			EndIf
		
			If !Empty(nPos) .And. aFilsCalc[nX,1] # aEmpresas[nPos,2]
				If Empty(nOpca)
					If lMostraTela
						nOpca := Aviso(STR0030,STR0056,{STR0057,STR0058,STR0059},2) //"A execu玢o desta rotina foi parametrizada para modo consolidado por閙 n鉶 foram selecionadas todas as filiais de uma ou mais empresas. Deseja que estas filiais sejam adicionadas a sele玢o ou mant閙 a sele玢o atual?"
					Else
						nOpca := 1
					EndIf
				EndIf
				If nOpca == 1
					aEmpresas[nPos,2] := .T.
				Else
					If nOpca == 3
						lRet := .F.
					EndIf
					Exit
				EndIf
			ElseIf Empty(nPos)
				aAdd(aEmpresas,{aFilsCalc[nX,4]+aFilsCalc[nX,5], aFilsCalc[nX,1], aFilsCalc[nX,4], Substr(aFilsCalc[nX,4],1,8), aFilsCalc[nX,4]+aFilsCalc[nX,6] })
			EndIf					
		Next nX
		
		If nOpca == 1
			aFilsCalc := {}
						
			//-- Percorre SM0 adicionando filiais com CNPJ+IE marcados
			SM0->(dbGoTop())
			If nValida < 2         		// CNPJ Igual
				SM0->(dbEval({|| If(aScan(aEmpresas,{|x| M0_CODIGO == cEmpAnt .And. x[3] == M0_CGC .And. x[2]}) == 0,NIL,aAdd(aFilsCalc,{.T.,M0_CODFIL,M0_FILIAL,M0_CGC,M0_INSC,M0_INSCM}))}))
			ElseIf nValida == 2			// CNPJ + I.E. iguais
				SM0->(dbEval({|| If(aScan(aEmpresas,{|x| M0_CODIGO == cEmpAnt .And. x[1] == M0_CGC+M0_INSC .And. x[2]}) == 0,NIL,aAdd(aFilsCalc,{.T.,M0_CODFIL,M0_FILIAL,M0_CGC,M0_INSC,M0_INSCM}))}))
			ElseIf nValida == 3			// CNPJ Raiz
				SM0->(dbEval({|| If(aScan(aEmpresas,{|x| M0_CODIGO == cEmpAnt .And. x[4] == SubStr(M0_CGC,1,8) .And. x[2]}) == 0,NIL,aAdd(aFilsCalc,{.T.,M0_CODFIL,M0_FILIAL,M0_CGC,M0_INSC,M0_INSCM}))}))
			ElseIf nValida == 4			// CNPJ + Insc.Municipal iguais
				SM0->(dbEval({|| If(aScan(aEmpresas,{|x| M0_CODIGO == cEmpAnt .And. x[5] == M0_CGC+M0_INSCM .And. x[2]}) == 0,NIL,aAdd(aFilsCalc,{.T.,M0_CODFIL,M0_FILIAL,M0_CGC,M0_INSC,M0_INSCM}))}))
			EndIf
			
			//-- Ordena por CNPJ+IE+Ins.Mun+Codigo para facilitar a quebra da rotina
			aSort(aFilsCalc,,,{|x,y| x[4]+x[5]+x[6]+x[2] < y[4]+y[5]+x[6]+y[2]})
			
		ElseIf nOpca # 3
			//-- Deleta filiais que nao serao processadas
			nX := 1
			While nX <= Len(aFilsCalc)
				If !aFilsCalc[nX,1]
					aDel(aFilsCalc,nX)
					aSize(aFilsCalc,Len(aFilsCalc)-1)
				Else
					nX++
				EndIf
			End
		EndIf
	EndIf	
EndIf

Return lRet

/*
苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北
北谀哪哪哪哪哪履哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪目北
北?Fun噮o    ?MtFClTroca(Original CA330Troca)                            潮?
北媚哪哪哪哪哪拍哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪穆哪哪哪履哪哪哪哪拇北
北?Autor     ?Microsiga Software S/A                   ?Data ?12/01/06 潮?
北媚哪哪哪哪哪拍哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪牧哪哪哪聊哪哪哪哪拇北
北?Descri噮o ?Troca marcador entre x e branco                            潮?
北媚哪哪哪哪哪拍哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪拇北
北砅arametros ?ExpN1 = Linha onde o click do mouse ocorreu                潮?
北?          ?ExpA2 = Array com as opcoes para selecao                   潮?
北?          ?ExpN3 = Valida sele玢o de CNPJ/IE na fun玢o MatFilCalc     潮?
北?          ?0=Legado n鉶 Valida / 1=CNPJ / 2=CNPJ+IE / 3=CNPJ Raiz     潮?
北?          ?4=CNPJ+IE+Insc.Municipal 							       潮?
北?          ?ExpN4 = Quantidade de Itens marcados - CNPJ/IE iguais      潮?
北?          ?ExpC5 = CNPJ/IE selecionado                                潮?
北媚哪哪哪哪哪拍哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪拇北
北? Uso      ?Protheus 8.11                                              潮?
北滥哪哪哪哪哪聊哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪馁北
北?5/08/2013 ?Wagner Montenegro 										   潮?
北?		  ?Adicionado os parametros ExpL3,ExpN4,ExpC5 para permitir   潮?
北?		  ?sele玢o apenas de CNPJ/IE iguais na fun玢o MatFilCalc	   潮?
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北
哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌
*/
Static Function MtFClTroca(nIt,aArray,nValida,nSelCNPJIE,cSelCNPJIE)
Default nValida := 0 	//1= Valida apenas CNPJ com mesmo numero MatFilCalc() / 2=Valida apenas CNPJ+IE com mesmo numero MatFilCalc()
						//3= Valida CNPJ Raiz (8 primeiros d韌itos) com mesmo n鷐ero/ 4= Valida CNPJ+IE+Insc.Municipal com mesmo n鷐ero
If nValida == 0
	aArray[nIt,1] := !aArray[nIt,1]
Else
	If aArray[nIt,1]
	   	nSelCNPJIE--
		If nSelCNPJIE==0
 	   		cSelCNPJIE:=""
		Endif
		aArray[nIt,1] := !aArray[nIt,1]
	Else
 		If nSelCNPJIE > 0
 	    	If ( nValida==1 .and. aArray[nIt,4]==cSelCNPJIE ) .or. ( nValida==2 .and. aArray[nIt,4]+aArray[nIt,5]==cSelCNPJIE ) .or.;
 	    		( nValida==3 .and. Substr(aArray[nIt,4],1,8) == Substr(cSelCNPJIE,1,8) ) .or. ( nValida==4 .and. aArray[nIt,4]+aArray[nIt,6] == cSelCNPJIE )
	 	   		nSelCNPJIE++
		 	   	aArray[nIt,1] := !aArray[nIt,1]
	 	  	Else
	 	  		If nValida == 1 
	 	  			//'SIGACUSCNPJ' ; 'A Consolida玢o por CNPJ est?habilitado. Selecione apenas Filiais com o mesmo CNPJ [' ; '] j?marcado, ou refa鏰 sua sele玢o!'
		 	  		Help(nil,1,STR0060,nil,STR0061+Transform(cSelCNPJIE,"@R 99.999.999/9999-99")+STR0062,3,0)
		 	  	ElseIf nValida == 2
		 	  	   //'SIGACUSCNPJIE' ; 'A Consolida玢o por CNPJ+IE est?habilitado. Selecione apenas Filiais com o mesmo CNPJ+IE [' ; '] j?marcado, ou refa鏰 sua sele玢o!'
		 	  		Help(nil,1,STR0063,nil,STR0064+Transform(Substr(cSelCNPJIE,1,14),"@R 99.999.999/9999-99")+" - "+Substr(cSelCNPJIE,15)+STR0062,3,0)
		 	  	ElseIf nValida == 3
					//'SIGACUSCNPJP' ; 'A Consolida玢o por CNPJ Raiz est?habilitado. Selecione apenas Filiais com o mesmo CNPJ Raiz [' ; '] j?marcado, ou refa鏰 sua sele玢o!'
					Help(nil,1,STR0066,nil,STR0067+Transform(Substr(cSelCNPJIE,1,8),"@R 99.999.999")+" - "+Substr(cSelCNPJIE,15)+STR0062,3,0)
		 	  	Else	
					//'SIGACUSCNPJIM' ; 'A Consolida玢o por CNPJ + Insc.Municiap est?habilitado. Selecione apenas Filiais com o mesmo CNPJ e Inscri玢o Municipal [' ; '] j?marcado, ou refa鏰 sua sele玢o!'
					Help(nil,1,STR0068,nil,STR0069+Transform(Substr(cSelCNPJIE,1,14),"@R 99.999.999/9999-99")+" - "+Substr(cSelCNPJIE,15)+STR0062,3,0)
		 	  	Endif
	 	   	Endif
		Else
			nSelCNPJIE++ 
			If nValida==1									// Valida CNPJ 
				cSelCNPJIE := aArray[nIt,4]
			ElseIf nValida ==2								// Valida CNPJ + I.E.
				cSelCNPJIE := aArray[nIt,4]+aArray[nIt,5]
			ElseIf nValida ==3								// Valida CNPJ Raiz (oito primeiros d韌itos)
				cSelCNPJIE := Subs(aArray[nIt,4],1,8)
			Else											// Valida CNPJ + Insc.Municipal
				cSelCNPJIE := aArray[nIt,4]+aArray[nIt,6]
			Endif
			aArray[nIt,1] := !aArray[nIt,1]
 		Endif
 	Endif
Endif 	   	
Return aArray

/*
苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘?
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北?
北谀哪哪哪哪穆哪哪哪哪哪履哪哪哪履哪哪哪哪哪哪哪哪哪哪哪履哪哪穆哪哪哪哪哪勘?
北矲un噮o    ?FullRange?Autor ?Felipe Nunes de Toledo?Data ?30/01/07 潮?
北媚哪哪哪哪呐哪哪哪哪哪聊哪哪哪聊哪哪哪哪哪哪哪哪哪哪哪聊哪哪牧哪哪哪哪哪幢?
北矰escricao ?Converte os parametros do tipo range, para um range cheio, 潮?
北?         ?caso o conteudo do parametro esteja vazio.                 潮?
北媚哪哪哪哪呐哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪幢?
北砈intaxe   矲ullRange(cPerg)                                            潮?
北媚哪哪哪哪呐哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪幢?
北砅arametros?cPerg = Nome do Grupo de Perguntas                         潮?
北媚哪哪哪哪呐哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪幢?
北砇etorno   ?Nenhum                                                     潮?
北媚哪哪哪哪呐哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪幢?
北砋so       ?Generico                                                   潮?
北滥哪哪哪哪牧哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪俦?
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北?
哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌?
*/
Function FullRange(cPerg)
Local aArea      := { SX1->(GetArea()), GetArea() }
Local aTamSX3    := {}
Local cMvPar     := ''
Local nTamSX1Cpo := Len(SX1->X1_GRUPO)

cPerg := Upper(PadR(cPerg,nTamSX1Cpo))

SX1->( dbSetOrder(1) )
SX1->( MsSeek(cPerg) )
Do While SX1->( !Eof() .And. Trim(X1_GRUPO) == Trim(cPerg) )
	If Upper(SX1->X1_GSC) == 'R'
		cMvPar := 'MV_PAR'+SX1->X1_ORDEM
		If Empty(&(cMvPar))
			aTamSX3 := TamSx3(SX1->X1_CNT01)
			If Upper(aTamSX3[3]) == 'C'
				&(cMvPar) := Space(aTamSX3[1])+'-'+Replicate('z',aTamSX3[1])
			ElseIf Upper(aTamSX3[3]) == 'D'
				&(cMvPar) := '01/01/80-31/12/49'
			ElseIf Upper(aTamSX3[3]) == 'N'
				&(cMvPar) := Replicate('0',aTamSX3[1])+'-'+Replicate('9',aTamSX3[1])
			EndIf
		EndIf
	EndIf
	SX1->( dbSkip() )
EndDo

RestArea( aArea[1] )
RestArea( aArea[2] )
Return Nil

/*
苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北
北谀哪哪哪哪穆哪哪哪哪哪穆哪哪哪穆哪哪哪哪哪哪哪哪哪哪哪穆哪哪哪履哪哪哪哪目北
北矲un噮o    ?UsaNewPrc ?Autor ?Andre Anjos			 ?Data ?10/09/08 潮?
北媚哪哪哪哪呐哪哪哪哪哪牧哪哪哪牧哪哪哪哪哪哪哪哪哪哪哪牧哪哪哪聊哪哪哪哪拇北
北矰escricao ?Analisa parametro MV_USANPRC, que define se sera utilizado  潮?
北?		 | o componente NewProces nas rotinas de processamento		   潮?
北媚哪哪哪哪呐哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪拇北
北砇etorno   ?Logico                                                      潮?
北媚哪哪哪哪呐哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪拇北
北砋so       ?Generico                                                    潮?
北滥哪哪哪哪牧哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪馁北
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北
哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌
*/
Function UsaNewPrc()
Return (SuperGetMV("MV_USANPRC",.F.,.F.))

/*
苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北
北谀哪哪哪哪穆哪哪哪哪哪穆哪哪哪穆哪哪哪哪哪哪哪哪哪哪哪穆哪哪哪履哪哪哪哪目北
北矲un噮o    ?ARetBenef ?Autor ?Rodrigo Toledo	 	 ?Data ?10/09/12 潮?
北媚哪哪哪哪呐哪哪哪哪哪牧哪哪哪牧哪哪哪哪哪哪哪哪哪哪哪牧哪哪哪聊哪哪哪哪拇北
北矰escricao ?Carrega no aCols da nota de entrada os itens que foram 	   潮?
北?		 ?enviados para remessa de beneficiamento					   潮?
北媚哪哪哪哪呐哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪拇北
北砇etorno   ?Logico			   										   潮?
北媚哪哪哪哪呐哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪拇北
北砋so       ?Retorno de Beneficiamento                                   潮?
北滥哪哪哪哪牧哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪馁北
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北
哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌
*/
Function ARetBenef()
Local lRet		:= .T.
Local cNumOp   	:= CriaVar("D1_OP")
Local cProduto 	:= CriaVar("C2_PRODUTO")
Local cTipEnt  	:= CriaVar("D1_TES")
Local nQtdProd  := 0
Local nPos   	:= 0
Local nIndBaixa := 0
Local oDlgBen  	:= Nil
Local lMonAcols	:= .F.
Local nBkp		:= n

If Type("aOPBenef") # "A"
	aOPBenef := {}
EndIf

If cTipo # "N"
	Aviso(STR0034,STR0049,{"OK"}) //"Aten玢o#Esta funcionalidade n鉶 se aplica a este tipo de documento."
	lRet := .F.
EndIf

If Empty(cA100For) .Or. Empty(cLoja)
	Aviso(STR0034,STR0050,{"OK"}) //"Aten玢o##Fornecedor n醥 informado no cabe鏰lho do documento."
	lRet := .F.
EndIf

If lRet
	//谀哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪?
	//?Monta a Tela de Retorno de Beneficiamento   ?
	//滥哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪?
	DEFINE MSDIALOG oDlgBen TITLE STR0046 From 9,0 To 20,50 OF oMainWnd	//"Retorno de Beneficiamento"
	
	@ 12,10 SAY RetTitle("D1_OP") PIXEL OF oDlgBen  //Numero da OP
	@ 10,52 MSGET cNumOp PICTURE PesqPict("SC2","C2_NUM") F3 "SC2" VALID CusVPrdOp(cNumOp,@cProduto,@nQtdProd) OF oDlgBen PIXEL SIZE 55,10
	@ 28,10 SAY RetTitle("C2_PRODUTO") PIXEL OF oDlgBen  //Produto
	@ 26,52 MSGET cProduto WHEN .F. OF oDlgBen PIXEL SIZE 95,10
	@ 44,10 SAY RetTitle("C2_QUANT") PIXEL OF oDlgBen  //Quantidade
	@ 42,52 MSGET nQtdProd VALID CusVQtdPR0(cNumOp,nQtdProd,@nIndBaixa) Picture PesqPict("SC2","C2_QUANT") OF oDlgBen PIXEL SIZE 55,10
	@ 60,10 SAY RetTitle("D1_TES") PIXEL OF oDlgBen  //Tipo Entrada
	@ 58,52 MSGET cTipEnt F3 "SF4" VALID CusVldTes(@cTipEnt) OF oDlgBen PIXEL SIZE 30,10
	DEFINE SBUTTON FROM 22,160  TYPE 1 ACTION (lRet := .T.,oDlgBen:End()) ENABLE OF oDlgBen
	DEFINE SBUTTON FROM 35,160  TYPE 2 ACTION (lRet := .F.,oDlgBen:End()) ENABLE OF oDlgBen
	
	ACTIVATE MSDIALOG oDlgBen   
	
	If lRet
		If (nPos := aScan(aOPBenef,{|x| x[1] == cNumOP})) == 0
			aAdd(aOPBenef,{cNumOP,nQtdProd})
		Else
			aOPBenef[nPos,2] := nQtdProd	
		EndIf
		
		MsgRun(STR0051,STR0052,{|| lMonACols := AProcReBen(cNumOP,nQtdProd,nIndBaixa,cTipEnt)})//"Processando estrutura e busca pelos documentos origem..."Aguarde"
			
		If !lMonAcols
			Aviso(STR0030,STR0047,{"Ok"}) //"Atencao"###"Nao foi identificado nenhuma remessa de beneficiamento para esta ordem de produ玢o."
		Else	
			oGetDados:lNewLine := .F.
			oGetDados:oBrowse:Refresh()
		EndIf
		
		If ExistBlock("NFRETBEN")
			ExecBlock("NFRETBEN",.F.,.F.,{cA100For,cLoja,cNumOp,nQtdProd,cTipEnt})
		EndIf
		
		n := nBkp
	EndIf
EndIf

Return lRet

/*
苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘?
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北?
北赏屯屯屯屯脱屯屯屯屯屯送屯屯屯淹屯屯屯屯屯屯屯屯屯退屯屯屯淹屯屯屯屯屯屯槐?
北篜rograma  矨ProcReBen篈utor  ?Rodrigo Toledo	 ?Data ? 04/11/12   罕?
北掏屯屯屯屯拓屯屯屯屯屯释屯屯屯贤屯屯屯屯屯屯屯屯屯褪屯屯屯贤屯屯屯屯屯屯贡?
北篋escricao ?Processa a criacao dos itens de retorno de beneficiamento. 罕?
北掏屯屯屯屯拓屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯贡?
北篣so       ?ARetBenef	                                              罕?
北韧屯屯屯屯拖屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯急?
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北?
哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌?
*/
Static Function AProcReBen(cNumOP,nQtdProd,nIndBaixa,cTipEnt)
Local lRet      := .F.
Local nLinha    := 0
Local nQtdEstr  := 0
Local nX	    := 0
Local nY	    := 0
Local nPITEM	:= GDFieldPos("D1_ITEM")
Local nPCOD     := GDFieldPos("D1_COD")
Local nPQUANT 	:= GDFieldPos("D1_QUANT")
Local nPOP      := GDFieldPos("D1_OP")
Local nPTES  	:= GDFieldPos("D1_TES")
Local nPNFORI   := GDFieldPos("D1_NFORI")
Local nPSERIORI := GDFieldPos("D1_SERIORI")
Local nPITEMORI := GDFieldPos("D1_ITEMORI")
Local nPVUNIT	:= GDFieldPos("D1_VUNIT")
Local nPTOTAL	:= GDFieldPos("D1_TOTAL")
Local nPIDENTB6 := GDFieldPos("D1_IDENTB6")
Local nPLoteCtl := GDFieldPos("D1_LOTECTL")
Local nPNumLote := GDFieldPos("D1_NUMLOTE")
Local nPNumSeri := GDFieldPos("D1_NUMSERI")
Local nPLocaliz := GDFieldPos("D1_LOCALIZ")
Local nProvEnt 	:= aScan(aHeader,{|x| AllTrim(Subs(x[2],4)) $ "PROVENT"})
Local aArea		:= SD4->(GetArea())
Local aNFOrig   := {}

SD4->(dbSetOrder(2))
SD4->(dbSeek(xFilial("SD4")+cNumOp))
While SD4->(!EOF()) .And. SD4->(D4_FILIAL+D4_OP) ==  xFilial("SD4")+cNumOp
	//-- Se totalmente baixado ou item negativo, pula
	If !(SD4->D4_QUANT > 0)
		SD4->(dbSkip())
		Loop
	EndIf
	
	//谀哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪?
	//?Posiciona na tabela SD4 para buscar o saldo do componente ?
	//滥哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪?
	nQtdEstr := nIndBaixa * SD4->D4_QTDEORI
	aNFOrig  := {}
	
	If A440F4("SB6",SD4->D4_COD,Posicione("SB1",1,xFilial("SB1")+SD4->D4_COD,'B1_LOCPAD'),"B6_PRODUTO","E",cA100For,cLoja,.F.,.F.,0,IIF(cTipo=="N","F","C"),@aNFOrig,.T.) > 0
		nX := 0
		While nQtdEstr > 0 .And. nX < Len(aNFOrig)
			For nX := 1 To Len(aNFOrig)
				nLinha := aScan(aCols,{|x| x[nPCOD]+x[nPOP]+x[nPNFORI]+x[nPSERIORI]+x[nPITEMORI] == SD4->(D4_COD+D4_OP)+aNFOrig[nX,1]+aNFOrig[nX,2]+aNFOrig[nX,10]})
			
		 		If Empty(nLinha)
		 			If !Empty(aCols[n,nPCOD])
						nLinha := Len(aCols) + 1
						aAdd(aCols,Array(Len(aHeader)+1))
						For nY := 1 to Len(aHeader)
							If IsHeadRec(aHeader[nY,2])
								aCols[nLinha,nY] := 0
							ElseIf IsHeadAlias(aHeader[nY,2])
								aCols[nLinha,nY] := "SD1"
                                    Else						
								aCols[nLinha,nY] := CriaVar(aHeader[nY,2],.T.)
							EndIf
						Next nY
						aTail(aCols[nLinha]) := .F.
						aCols[nLinha,nPITEM] := StrZero(nLinha,TamSX3("D1_ITEM")[1])
					Else
						nLinha := n
					EndIf
				EndIf
				
				n := nLinha
				
				// Executa as funcoes do CheckSX3 e forca a execucao dos trigers
				aCols[nLinha,nPCOD] := SD4->D4_COD
				M->D1_COD := aCols[nLinha,nPCOD]
				__READVAR := "M->D1_COD"
				CheckSX3("D1_COD",aCols[nLinha,nPCOD])
				If ExistTrigger('D1_COD')
					RunTrigger(2,nLinha,,'D1_COD')
				EndIf
										
				aCols[nLinha,nPQUANT] := Min(nQtdEstr,Val(aNFOrig[nX,4]))
				M->D1_QUANT := aCols[nLinha,nPQUANT]
				__ReadVar := 'M->D1_QUANT'
				CheckSX3('D1_QUANT',aCols[nLinha,nPQUANT])
				If ExistTrigger('D1_QUANT')
					RunTrigger(2,nLinha,,'D1_QUANT')
				EndIf
				
				aCols[nLinha,nPTES] := cTipEnt
				M->D1_TES := aCols[nLinha,nPTES]
				__ReadVar := 'M->D1_TES'
				CheckSX3('D1_TES',aCols[nLinha,nPTES])
				If ExistTrigger('D1_TES')
					RunTrigger(2,nLinha,,'D1_TES')
				EndIf
				
				aCols[nLinha,nPVUNIT] := aNFOrig[nX,11]
				M->D1_VUNIT := aCols[nLinha,nPVUNIT]
				__ReadVar := 'M->D1_VUNIT'
				If cPaisLoc $ "BRA|ARG"
					CheckSX3('D1_VUNIT',aCols[nLinha,nPVUNIT])
				EndIf
				If ExistTrigger('D1_VUNIT')
					RunTrigger(2,nLinha,,'D1_VUNIT')
				EndIf
				
				aCols[nLinha,nPTOTAL] := aCols[nLinha,nPQUANT] * aCols[nLinha,nPVUNIT]
				M->D1_TOTAL := aCols[nLinha,nPTOTAL]
				__ReadVar := 'M->D1_TOTAL'
				CheckSX3('D1_TOTAL',aCols[nLinha,nPTOTAL])
				If ExistTrigger('D1_TOTAL')
					RunTrigger(2,nLinha,,'D1_TOTAL')
				EndIf
				
				aCols[nLinha,nPNFORI] := aNFOrig[nX,1]
				M->D1_NFORI := aCols[nLinha,nPNFORI]
				__ReadVar := 'M->D1_NFORI'
				CheckSX3('D1_NFORI',aCols[nLinha,nPNFORI])
				If ExistTrigger('D1_NFORI')
					RunTrigger(2,nLinha,,'D1_NFORI')
				EndIf
				
				aCols[nLinha,nPSERIORI] := aNFOrig[nX,2]
				M->D1_SERIORI := aCols[nLinha,nPSERIORI]
				__ReadVar := 'M->D1_SERIORI'
				CheckSX3('D1_SERIORI',aCols[nLinha,nPSERIORI])
				If ExistTrigger('D1_SERIORI')
					RunTrigger(2,nLinha,,'D1_SERIORI')
				EndIf
				
				aCols[nLinha,nPITEMORI] := aNFOrig[nX,10]
				M->D1_ITEMORI := aCols[nLinha,nPITEMORI]
				__ReadVar := 'M->D1_ITEMORI'
				CheckSX3('D1_ITEMORI',aCols[nLinha,nPITEMORI])
				If ExistTrigger('D1_ITEMORI')
					RunTrigger(2,nLinha,,'D1_ITEMORI')
				EndIf
				
				aCols[nLinha,nPIDENTB6] := aNFOrig[nX,12]
				M->D1_IDENTB6 := aCols[nLinha,nPIDENTB6]
				__ReadVar := 'M->D1_IDENTB6'
				CheckSX3('D1_IDENTB6',aCols[nLinha,nPIDENTB6])
				If ExistTrigger('D1_IDENTB6')
					RunTrigger(2,nLinha,,'D1_IDENTB6')
				EndIf
				
				aCols[nLinha,nPOP] := cNumOp
				M->D1_OP := aCols[nLinha,nPOP]
				__ReadVar:='M->D1_OP'
				CheckSX3('D1_OP',aCols[nLinha,nPOP])
				If ExistTrigger('D1_OP')
					RunTrigger(2,nLinha,,'D1_OP')
				EndIf
				
				If nPLoteCtl > 0
					aCols[nLinha,nPLoteCtl] := aNFOrig[nX,6]
					M->D1_LOTECTL := aCols[nLinha,nPLoteCtl]
					__ReadVar:='M->D1_LOTECTL'
					CheckSX3('D1_LOTECTL',aCols[nLinha,nPLoteCtl])
					If ExistTrigger('D1_LOTECTL')
						RunTrigger(2,nLinha,,'D1_LOTECTL')
					EndIf
				Endif
				
				If nPNumLote > 0
					aCols[nLinha,nPNumLote] := aNFOrig[nX,7]
					M->D1_NUMLOTE := aCols[nLinha,nPNumLote]
					__ReadVar:='M->D1_NUMLOTE'
					CheckSX3('D1_NUMLOTE',aCols[nLinha,nPNumLote])
					If ExistTrigger('D1_NUMLOTE')
						RunTrigger(2,nLinha,,'D1_NUMLOTE')
					EndIf
				Endif
				
				If nPNumSeri > 0
					aCols[nLinha,nPNumSeri] := aNFOrig[nX,13]
					M->D1_NUMSERI := aCols[nLinha,nPNumSeri]
					__ReadVar:='M->D1_NUMSERI'
					CheckSX3('D1_NUMSERI',aCols[nLinha,nPNumSeri])
					If ExistTrigger('D1_NUMSERI')
						RunTrigger(2,nLinha,,'D1_NUMSERI')
					EndIf
				Endif
				
				If nPLocaliz > 0
					aCols[nLinha,nPLocaliz] := aNFOrig[nX,14]
					M->D1_LOCALIZ := aCols[nLinha,nPLocaliz]
					__ReadVar:='M->D1_LOCALIZ'
					CheckSX3('D1_LOCALIZ',aCols[nLinha,nPLocaliz])
					If ExistTrigger('D1_LOCALIZ')
						RunTrigger(2,nLinha,,'D1_LOCALIZ')
					EndIf
				Endif
										
				//谀哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪?
				//?Atualiza a Funcao Fiscal                    ?
				//滥哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪?
				MaColsToFis(aHeader,aCols,nLinha,"MT100",.F.)
				If cPaisLoc == "ARG" .And. nProvEnt > 0
					MaFisAlt("IT_PROVENT",aCols[nLinha,nProvEnt],nLinha)
				Endif 
				If IsInCallStack("LOCXNF")
					Eval(bDoRefresh) //Atualiza o folder financeiro.
					Eval(bListRefresh)
				EndIf
				
				nQtdEstr -= Min(nQtdEstr,Val(aNFOrig[nX,4]))
				lRet := .T.
				If nQtdEstr <= 0
					Exit
				EndIf
			Next nX
		End
	EndIf		

	SD4->(dbSkip())
End

//谀哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪目
//?Apos atualizacao do aCols move o cursor para primeira linha do aCols ?
//滥哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪馁
n := 1

SD4->(RestArea(aArea))
Return lRet


/*
苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北
北谀哪哪哪哪穆哪哪哪哪哪穆哪哪哪穆哪哪哪哪哪哪哪哪哪哪哪穆哪哪哪履哪哪哪哪目北
北矲un噮o    ?CusCarrPd ?Autor ?Rodrigo Toledo	 	 ?Data ?27/08/12 潮?
北媚哪哪哪哪呐哪哪哪哪哪牧哪哪哪牧哪哪哪哪哪哪哪哪哪哪哪牧哪哪哪聊哪哪哪哪拇北
北矰escricao ?Caso a ordem de producao seja preenchida gatilhar o codigo  潮?
北?		 ?do produto PA				   							   潮?
北媚哪哪哪哪呐哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪拇北
北砅arametros?cOP   = Numero da Ordem de Producao              		   潮?
北?		 ?cPrdOrd = Codigo do produto da ordem de producao			   潮?
北媚哪哪哪哪呐哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪拇北
北砇etorno   ?Logico			   										   潮?
北媚哪哪哪哪呐哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪拇北
北砋so       ?Retorno de Beneficiamento                                   潮?
北滥哪哪哪哪牧哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪馁北
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北
哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌
*/
Static Function CusVPrdOp(cOP,cPrdOrd,nQuant)
Local lRet 	   := .T.
Local aAreaSC2 := SC2->(GetArea())

SC2->(dbSetOrder(1))
If SC2->(dbSeek(xFilial("SC2")+cOP))
	If !Empty(SC2->C2_DATRF)
		Help(" ",1,"MA240OPENC")
		lRet := .F.
	Else
		nQuant  := SC2->(C2_QUANT - C2_QUJE - C2_PERDA)
		cPrdOrd := SC2->C2_PRODUTO
	EndIf
Else
	Help(" ",1,"REGNOIS")
	lRet := .F.	
EndIf

RestArea(aAreaSC2)
Return lRet

/*
苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北
北谀哪哪哪哪穆哪哪哪哪哪穆哪哪哪穆哪哪哪哪哪哪哪哪哪哪哪穆哪哪哪履哪哪哪哪目北
北矲un噮o    ?CusVldTes ?Autor ?Rodrigo Toledo	 	 ?Data ?10/09/12 潮?
北媚哪哪哪哪呐哪哪哪哪哪牧哪哪哪牧哪哪哪哪哪哪哪哪哪哪哪牧哪哪哪聊哪哪哪哪拇北
北矰escricao ?Valida o codigo da TES informada pelo usuario  		   	   潮?
北媚哪哪哪哪呐哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪拇北
北砅arametros?cCodTes = Codigo da TES              		   			   潮?
北媚哪哪哪哪呐哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪拇北
北砇etorno   ?Logico			   										   潮?
北媚哪哪哪哪呐哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪拇北
北砋so       ?Retorno de Beneficiamento                                   潮?
北滥哪哪哪哪牧哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪馁北
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北
哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌
*/
Static Function CusVldTes(cCodTES)
Local lRet 	   := .T.
Local aAreaSF4 := GetArea()

SF4->(dbSetOrder(1))
If !SF4->(dbSeek(xFilial("SF4")+cCodTES))
	Help('   ',1,'A103TPNFOR')
	lRet := .F.
ElseIf cTipo == "D" .And. SF4->F4_PODER3 <> "N"
	Help('   ',1,'A103TESNFD')
	lRet := .F.	
ElseIf cTipo$"NB" .And. SF4->F4_PODER3 <> "D"
	Help('   ',1,'A103TESNFB')
	lRet := .F.		
EndIf

//谀哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪?
//?Verifica se a TES digitada pode ser utilizada na operacao ?
//滥哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪?
If lRet
	lRet := MaAvalTes("E",cCodTES)
EndIf

RestArea(aAreaSF4)
Return lRet


/*
苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘?
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北?
北赏屯屯屯屯脱屯屯屯屯屯退屯屯屯脱屯屯屯屯屯屯屯屯屯退屯屯屯淹屯屯屯屯屯屯槐?
北篜rograma  矼TEstornPR 篈utor  砇odrigo Toledo     ?Data ? 18/09/12   罕?
北掏屯屯屯屯拓屯屯屯屯屯褪屯屯屯拖屯屯屯屯屯屯屯屯屯褪屯屯屯贤屯屯屯屯屯屯贡?
北篋escricao 砎erifica se os empenhos foram baixados e se a OP tem saldo  罕?
北?		 砪aso as duas condicoes sejam atendidas executar a rotina	  罕?
北?		 砤utomatica MATA250 para digitacoes das OP's	  			  罕?
北掏屯屯屯屯拓屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯贡?
北篜arametros矱xpC1: Numero do documento de entrada           			  罕?
北?		 矱xpC2: Serie do documento de entrada           			  罕?
北?		 矱xpC3: Codigo do fornecedor           			  		  罕?
北?		 矱xpC4: Loja do fornecedor           			  		  	  罕?
北掏屯屯屯屯拓屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯贡?
北篣so       砇etorno de Beneficiamento                                   罕?
北韧屯屯屯屯拖屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯急?
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北?
哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌?
*/
Function MTEstornPR(cDoc,cSerie,cFornec,cLoja)
Local aAreaSD3 := SD3->(GetArea())
Local lRet     := .T.
Local aApont := {}

Private lMsErroAuto := .F.

	SD3->(dbSetOrder(13))
	SD3->(dbSeek(xFilial("SD3")+xFilial("SF1")+cDoc+cSerie+cFornec+cLoja))

	Begin Transaction
	
	While !SD3->(EOF()) .And. AllTrim(SD3->(D3_FILIAL+D3_CHAVEF1)) == AllTrim(xFilial("SD3")+xFilial("SF1")+cDoc+cSerie+cFornec+cLoja)
		If SD3->D3_ESTORNO # "S"
			aApont := {}
			Aadd(aApont,{"D3_DOC"    ,SD3->D3_DOC       ,Nil})
			Aadd(aApont,{"D3_OP"     ,SD3->D3_OP        ,Nil})
			Aadd(aApont,{"D3_COD"    ,SD3->D3_COD       ,Nil})
			Aadd(aApont,{"D3_UM"     ,SD3->D3_UM        ,Nil})
			Aadd(aApont,{"D3_QUANT"  ,SD3->D3_QUANT     ,Nil})
			Aadd(aApont,{"D3_LOCAL"  ,SD3->D3_LOCAL     ,Nil})
			Aadd(aApont,{"D3_CC"     ,SD3->D3_CC        ,Nil})
			Aadd(aApont,{"D3_EMISSAO",SD3->D3_EMISSAO   ,Nil})
			Aadd(aApont,{"D3_LOTECTL",SD3->D3_LOTECTL   ,Nil})
			Aadd(aApont,{"D3_DTVALID",SD3->D3_DTVALID   ,Nil})
			Aadd(aApont,{"D3_NUMSEQ" ,SD3->D3_NUMSEQ    ,Nil})
			Aadd(aApont,{"D3_CHAVE"  ,SD3->D3_CHAVE     ,Nil})
			Aadd(aApont,{"D3_CF"     ,"PR0"             ,Nil})
			aAdd(aApont,{"INDEX"     , 4                ,Nil})
			MsExecAuto({|x,y| MATA250(x,y)},aApont,5)
			If lMsErroAuto
				DisarmTransaction()
				Mostraerro()
				lRet := .F.
				Exit
			EndIf
		EndIf
		SD3->(dbSkip())
	EndDo
	
	End Transaction

	RestArea(aAreaSD3)

Return lRet

/*
苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘?
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北?
北赏屯屯屯屯脱屯屯屯屯屯退屯屯屯脱屯屯屯屯屯屯屯屯屯退屯屯屯淹屯屯屯屯屯屯槐?
北篜rograma  矼TIncluiPR 篈utor  砇odrigo Toledo     ?Data ? 30/08/12   罕?
北掏屯屯屯屯拓屯屯屯屯屯褪屯屯屯拖屯屯屯屯屯屯屯屯屯褪屯屯屯贤屯屯屯屯屯屯贡?
北篋escricao 砎erifica se os empenhos foram baixados e se a OP tem saldo, 罕?
北?		 砪aso as duas condicoes sejam atendidas executar a rotina	  罕?
北?		 砤utomatica MATA250 para digitacoes das OP's	  			  罕?
北掏屯屯屯屯拓屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯贡?
北篜arametros矱xpA1: Array contendo as OP's do remito de entrada          罕?
北掏屯屯屯屯拓屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯贡?
北篣so       矼TIncluiPR()                                                罕?
北韧屯屯屯屯拖屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯急?
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北?
哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌?
*/
Function MTIncluiPR(aNFOps)
Local lRet     := .T.
Local nX       := 0
Local aMata250 := {}
Local cChaveF1 := SF1->(F1_FILIAL+F1_DOC+F1_SERIE+F1_FORNECE+F1_LOJA)
Local cFornecedor	:=SF1->F1_FORNECE	
Local cLoja			:=SF1->F1_LOJA
Local cTMPAD   := SuperGetMv("MV_TMPAD")
Local lFornece := SD3->(ColumnPos("D3_FORNDOC")) > 0 .And. SD3->(ColumnPos("D3_LOJADOC")) > 0

Default aNFOps := {}

Private lMsErroAuto := .F.

Begin Transaction

For nX := 1 To Len(aNFOps)
	aMata250 := {}
	aAdd(aMata250,{'D3_TM'     ,cTMPAD                ,Nil})
	aAdd(aMata250,{'D3_OP'     ,aNFOps[nX,1] 		  ,Nil})
	aAdd(aMata250,{'D3_QUANT'  ,aNFOps[nX,2] 		  ,Nil})
	aAdd(aMata250,{'D3_CHAVEF1',cChaveF1			  ,Nil})
	If lFornece
		aAdd(aMata250,{'D3_FORNDOC',cFornecedor		  ,Nil})
		aAdd(aMata250,{'D3_LOJADOC',cLoja			  ,Nil})
	EndIf
	aAdd(aMata250,{'REQAUT'	   ,"N"					  ,Nil})
	MSExecAuto({|x,y| mata250(x,y)},aMata250,3)
	If lMsErroAuto
		DisarmTransaction()
		Mostraerro()
		lRet := .F.
	EndIf
Next nX

End Transaction

Return lRet

/*
苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘?
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北?
北赏屯屯屯屯脱屯屯屯屯屯退屯屯屯脱屯屯屯屯屯屯屯屯屯退屯屯屯淹屯屯屯屯屯屯槐?
北篜rograma  矯usVQtdPR0 篈utor  砇odrigo Toledo     ?Data ? 09/11/12   罕?
北掏屯屯屯屯拓屯屯屯屯屯褪屯屯屯拖屯屯屯屯屯屯屯屯屯褪屯屯屯贤屯屯屯屯屯屯贡?
北篋escricao 砎alida se a quantidade eh superior ao saldo da ordem de     罕?
北?		 硃roducao.	  												  罕?
北掏屯屯屯屯拓屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯贡?
北篜arametros矱xpC1: Numero da Ordem de Producao				          罕?
北?		 矱xpN1: Quantidade da Ordem de Proucao			              罕?
北?		 矱xpN2: Indica a baixa de OP			              		  罕?
北掏屯屯屯屯拓屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯贡?
北篣so       矼TIncluiPR()                                                罕?
北韧屯屯屯屯拖屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯急?
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北?
哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌?
*/
Static Function CusVQtdPR0(cNumOp,nQtdProd,nIndBaixa)
Local lRet := .T.

SC2->(dbSetOrder(1))
SC2->(dbSeek(xFilial("SC2")+cNumOp))

If nQtdProd > SC2->(C2_QUANT - C2_QUJE)
	Aviso(STR0034,STR0053,{"OK"}) //Aten玢o##Quantidade superior ao saldo da ordem de produ敲o.
	lRet := .F.
Else
	nIndBaixa := Min(1,nQtdProd/SC2->C2_QUANT)
EndIf

Return lRet

/*
苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北
北谀哪哪哪哪穆哪哪哪哪哪哪哪穆哪哪哪穆哪哪哪哪哪哪哪哪哪穆哪哪哪履哪哪哪哪目北
北矲un嘺o    ?RCPE_BLOCO    ?Autor ?TOTVS S/A    	 ?Data ?01/04/13 潮?
北媚哪哪哪哪呐哪哪哪哪哪哪哪牧哪哪哪牧哪哪哪哪哪哪哪哪哪牧哪哪哪聊哪哪哪哪拇北
北矰escricao ?RCPE MG - ARQUIVO MAGNETICO                                 潮?
北?		 | Esta funcao tem o objetivo de recuperar informacoes de      潮?
北?		 | Estoque/Fiscal/Contabil para geracao de BLOCO               潮?
北媚哪哪哪哪呐哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪拇北
北砅arametros?dDataDe    = Data Inicial para geracao das informacoes      潮?
北?         ?dDataAte   = Data Final para geracao das informacoes        潮?
北?         ?cAlias0210 = Alias para geracao do BLOCO 0210               潮?
北?         ?cAlias0250 = Alias para geracao do BLOCO 0250               潮?
北?         ?cAliasH200 = Alias para geracao do BLOCO H200               潮?
北?         ?cAliasH220 = Alias para geracao do BLOCO H220               潮?
北?         ?cAliasH230 = Alias para geracao do BLOCO H230               潮?
北?         ?cAliasH235 = Alias para geracao do BLOCO H235               潮?
北?         ?cAliasH250 = Alias para geracao do BLOCO H250               潮?
北?         ?cAliasH255 = Alias para geracao do BLOCO H255               潮?
北?         ?cAliasH260 = Alias para geracao do BLOCO H260               潮?
北?         ?cAliasH265 = Alias para geracao do BLOCO H265               潮?
北?         ?cAliasH270 = Alias para geracao do BLOCO H270               潮?
北?         ?cAliasH275 = Alias para geracao do BLOCO H275               潮?
北?         ?cAliasI100 = Alias para geracao do BLOCO I100               潮?
北?         ?cAliasI210 = Alias para geracao do BLOCO I210               潮?
北?         ?lClose     = Indica se deve fechar os arquivos temporarios  潮?
北媚哪哪哪哪呐哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪拇北
北砋so       ?Arquivo Magnetico RCPE MG                                   潮?
北滥哪哪哪哪牧哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪馁北
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北
哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌
*/
Function RCPE_BLOCO (	dDataDe,;
						dDataAte,;
						cAlias0210,;
						cAlias0250,;
						cAliasH200,;
						cAliasH220,;
						cAliasH230,;
						cAliasH235,;
						cAliasH250,;
						cAliasH255,;
						cAliasH260,;
						cAliasH265,;
						cAliasH270,;
						cAliasH275,;
						cAliasI100,;
						cAliasI210,;
						lClose)
Local nX       := 0
Local cQuery   := ''
// Alias das tabelas de movimentacao
Local cAliasSD1:= 'SD1'
Local cAliasSD2:= 'SD2'
Local cAliasSD3:= 'SD3'
// Estrutura das tabelas de movimentacao
Local aStruSD1 := SD1->(dbStruct())
Local aStruSD2 := SD2->(dbStruct())
Local aStruSD3 := SD3->(dbStruct())
// Parametros para configuracao dos tipos de produtos (B1_TIPO)
Local cTipo00  := SuperGetMv("MV_RCPETP0",.F.,"'MR'")	// 00 - Mercadoria para Revenda
Local cTipo01  := SuperGetMv("MV_RCPETP1",.F.,"'MP'")	// 01 - Materia-prima
Local cTipo02  := SuperGetMv("MV_RCPETP2",.F.,"'EM'")	// 02 - Embalagem
Local cTipo03  := SuperGetMv("MV_RCPETP3",.F.,"'PP'")	// 03 - Produto em Processo
Local cTipo04  := SuperGetMv("MV_RCPETP4",.F.,"'PA'")	// 04 - Produto Acabado
Local cTipo05  := SuperGetMv("MV_RCPETP5",.F.,"'SP'")	// 05 - SubProduto
Local cTipo06  := SuperGetMv("MV_RCPETP6",.F.,"'PI'")	// 06 - Produto Intermediario
// Datas de apuracao
Default dDataDe    := CTOD("01/01/2013")
Default dDataAte   := CTOD("31/12/2013")
Default lClose     := .T.

//谀哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪目
//?MONTAGEM DOS ARQUIVOS DE TRABALHO                        ?
//滥哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪馁
RCPE_CRIATRB( '0210', @cAlias0210, 'FILIAL+COD_ITEM+COD_I_COMP'		)
RCPE_CRIATRB( '0250', @cAlias0250, 'FILIAL+UNID'					)
RCPE_CRIATRB( 'H200', @cAliasH200, 'FILIAL+DTOS(DT_MOV)+COD_ITEM' 	)
RCPE_CRIATRB( 'H220', @cAliasH220, 'FILIAL+NUMSEQ'					)
RCPE_CRIATRB( 'H230', @cAliasH230, 'FILIAL+COD_DOC_OP'				)
RCPE_CRIATRB( 'H235', @cAliasH235, 'FILIAL+COD_DOC_OP'				)
RCPE_CRIATRB( 'H250', @cAliasH250, 'FILIAL+DTOS(DT_PROD)+COD_ITEM'	)
RCPE_CRIATRB( 'H255', @cAliasH255, 'FILIAL+CHAVE'					)
RCPE_CRIATRB( 'H260', @cAliasH260, 'FILIAL+COD_ITEM'				)
RCPE_CRIATRB( 'H265', @cAliasH265, 'FILIAL+COD_ITEM'				)
RCPE_CRIATRB( 'H270', @cAliasH270, 'FILIAL+COD_DOC_OP'				)
RCPE_CRIATRB( 'H275', @cAliasH275, 'FILIAL+COD_PAI'					)
RCPE_CRIATRB( 'I100', @cAliasI100, 'FILIAL+COD_CCUS'				)
RCPE_CRIATRB( 'I210', @cAliasI210, 'FILIAL+COD_ITEM'				)

//谀哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪目
//?D O C U M E N T O   D E   E N T R A D A                  ?
//滥哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪馁
cQuery := "SELECT "
cQuery +=        "SD1.D1_FILIAL , SD1.D1_COD     , SD1.D1_QUANT    , SD1.D1_DTDIGIT   , SD1.D1_TIPO    , SD1.D1_CC , "
cQuery +=        "SD1.D1_SERIE  , SD1.D1_DOC     , SD1.D1_NUMSEQ   , SD1.D1_TES       , SF4.F4_PODER3  , SB1.B1_UM , "
cQuery +=        "SB1.B1_TIPO   , SB1.B1_EMAX    , SF4.F4_TRANFIL  , SD1.D1_BASEIPI   , SD1.D1_TOTAL   , SD1.D1_OP , "
cQuery +=        "SD1.D1_UM     , SD1.D1_CF      , SF4.F4_FINALID  , SD1.D1_FORNECE   , SD1.D1_LOJA    , SD1.R_E_C_N_O_ RECNOSD1 "
cQuery +=   "FROM "
cQuery +=           RetSqlName("SD1")  + " SD1 ,"
cQuery +=           RetSqlName("SF4")  + " SF4 ,"
cQuery +=           RetSqlName("SB1")  + " SB1  "
cQuery +=  "WHERE "
cQuery +=            "SD1.D1_FILIAL = '" + xFilial("SD1")	+ "' "
cQuery +=        "AND SF4.F4_FILIAL = '" + xFilial("SF4")	+ "' "
cQuery +=        "AND SB1.B1_FILIAL = '" + xFilial("SB1")	+ "' "
// Amarracao SD1 x SF4 x SB1
cQuery +=        "AND SD1.D1_TES     = SF4.F4_CODIGO "
cQuery +=        "AND SD1.D1_COD     = SB1.B1_COD "
// Despreza Notas Fiscais Lancadas Pelo Modulo do Livro Fiscal e de complemento de ICMS
cQuery +=        "AND SD1.D1_ORIGLAN <> 'LF' "
cQuery +=        "AND SD1.D1_TIPO    <> 'I' "
// Filtra o periodo/ano selecionado
cQuery +=        "AND SD1.D1_DTDIGIT >= '" + DTOS(dDataDe)  + "' "
cQuery +=        "AND SD1.D1_DTDIGIT <= '" + DTOS(dDataAte) + "' "
// Verifica os tipos de produtos
cQuery +=        "AND SB1.B1_TIPO IN (" + cTipo00 + "," + cTipo01 + "," + cTipo02 + "," + cTipo03 + "," + cTipo04 + "," + cTipo05 + "," + cTipo06 +" ) "
// Verifica se o TES atualiza estoque
cQuery +=        "AND SF4.F4_ESTOQUE = 'S' "
cQuery +=        "AND SD1.D_E_L_E_T_  = ' ' "
cQuery +=        "AND SF4.D_E_L_E_T_  = ' ' "
cQuery +=        "AND SB1.D_E_L_E_T_  = ' ' "
//谀哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪?
//?Define o alias para a query                                 ?
//滥哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪?
cAliasSD1  := GetNextAlias()
//谀哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪?
//?Verifica se o alias esta em uso                             ?
//滥哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪?
If Select( cAliasSD1 ) > 0
	dbSelectArea( cAliasSD1 )
	dbCloseArea()
EndIf
//谀哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪?
//?Compatibiliza a query com o banco de dados                  ?
//滥哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪?
cQuery := ChangeQuery(cQuery)
//谀哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪?
//?Cria o alias executando a query                             ?
//滥哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪?
dbUseArea( .T., 'TOPCONN', TCGENQRY(,,cQuery), cAliasSD1 , .F., .T.)
//谀哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪?
//?Compatibiliza os campos de acordo com a TopField            ?
//滥哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪?
For nX := 1 To Len(aStruSD1)
	If aStruSD1[nX][2] <> "C" 
		TcSetField(cAliasSD1,aStruSD1[nX][1],aStruSD1[nX][2],aStruSD1[nX][3],aStruSD1[nX][4])
	EndIf
Next nX 
	
	
// Processamento dos documentos de entrada
dbSelectArea(cAliasSD1)
Do While (cAliasSD1)->(!Eof())
	// Gravacao dos Blocos
	RCPE_GRAVA('0250','SD1',cAliasSD1,cAlias0250)
	RCPE_GRAVA('H200','SD1',cAliasSD1,cAliasH200)
	RCPE_GRAVA('H250','SD1',cAliasSD1,cAliasH250)
	RCPE_GRAVA('H255','SD1',cAliasSD1,cAliasH255)
	RCPE_GRAVA('I100','SD1',cAliasSD1,cAliasI100)
	(cAliasSD1)->(dbSkip())
EndDo	

// Encerra Alias de Trabalho	
If Select(cAliasSD1) > 0 
	(cAliasSD1)->(dbCloseArea())
EndIf

//谀哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪目
//?D O C U M E N T O  D E   S A I D A                       ?
//滥哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪馁
cQuery := "SELECT "
cQuery +=        "SD2.D2_FILIAL , SD2.D2_COD     , SD2.D2_QUANT    , SD2.D2_EMISSAO   , SD2.D2_TIPO    , SD2.D2_CCUSTO, " 
cQuery +=        "SD2.D2_SERIE  , SD2.D2_DOC     , SD2.D2_NUMSEQ   , SD2.D2_TES       , SF4.F4_PODER3  , SB1.B1_UM , "
cQuery +=        "SB1.B1_TIPO   , SB1.B1_EMAX    , SF4.F4_TRANFIL  , SD2.D2_BASEIPI   , SD2.D2_TOTAL   , SD2.D2_OP , "
cQuery +=        "SD2.D2_UM     , SD2.D2_CF      , SF4.F4_FINALID  , SD2.D2_CLIENTE   , SD2.D2_LOJA    , SD2.R_E_C_N_O_ RECNOSD2 "
cQuery +=   "FROM "
cQuery +=        RetSqlName("SD2")  + " SD2 ,"
cQuery +=        RetSqlName("SB1")  + " SB1 ,"
cQuery +=        RetSqlName("SF4")  + " SF4 "
cQuery += "WHERE "
cQuery +=        "SD2.D2_FILIAL = '" + xFilial("SD2")	+ "' "
cQuery +=    "AND SB1.B1_FILIAL = '" + xFilial("SB1") 	+ "' "
cQuery +=    "AND SF4.F4_FILIAL = '" + xFilial("SF4")	+ "' "
// Amarracao SD2 x SB1 x SF4
cQuery +=    "AND SD2.D2_COD    = SB1.B1_COD "
cQuery +=    "AND SD2.D2_TES    = SF4.F4_CODIGO "
// Despreza Notas Fiscais Lancadas Pelo Modulo do Livro Fiscal e de complementos de preco e impostos.
cQuery +=    "AND SD2.D2_ORIGLAN <> 'LF' "
cQuery +=    "AND SD2.D2_TIPO    <> 'C' "
cQuery +=    "AND SD2.D2_TIPO    <> 'P' "
cQuery +=    "AND SD2.D2_TIPO    <> 'I' "
// Filtra o periodo/ano selecionado
cQuery +=    "AND SD2.D2_EMISSAO >= '" + DTOS(dDataDe)  + "' "
cQuery +=    "AND SD2.D2_EMISSAO <= '" + DTOS(dDataAte) + "' "
// Verifica os tipos de produtos
cQuery +=    "AND SB1.B1_TIPO IN (" + cTipo00 + "," + cTipo01 + "," + cTipo02 + "," + cTipo03 + "," + cTipo04 + "," + cTipo05 + "," + cTipo06 +" ) "
// Verifica se o TES atualiza estoque
cQuery +=    "AND SF4.F4_ESTOQUE = 'S' "
cQuery +=    "AND SD2.D_E_L_E_T_  = ' ' "
cQuery +=    "AND SB1.D_E_L_E_T_  = ' ' " 
cQuery +=    "AND SF4.D_E_L_E_T_  = ' ' "
//谀哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪?
//?Define o alias para a query                                 ?
//滥哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪?
cAliasSD2  := GetNextAlias()
//谀哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪?
//?Verifica se o alias esta em uso                             ?
//滥哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪?
If Select( cAliasSD2 ) > 0
	dbSelectArea( cAliasSD2 )
	dbCloseArea()
EndIf
//谀哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪?
//?Compatibiliza a query com o banco de dados                  ?
//滥哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪?
cQuery := ChangeQuery(cQuery)
//谀哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪?
//?Cria o alias executando a query                             ?
//滥哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪?
dbUseArea( .T., 'TOPCONN', TCGENQRY(,,cQuery), cAliasSD2 , .F., .T.)
//谀哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪?
//?Compatibiliza os campos de acordo com a TopField            ?
//滥哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪?
For nX := 1 To Len(aStruSD2)
	If aStruSD2[nX][2] <> "C"
		TcSetField(cAliasSD2,aStruSD2[nX][1],aStruSD2[nX][2],aStruSD2[nX][3],aStruSD2[nX][4])
	EndIf
Next nX 

// Processamento dos documentos de saida
dbSelectArea(cAliasSD2)
Do While (cAliasSD2)->(!Eof())
	// Gravacao dos Blocos
	RCPE_GRAVA('0250','SD2',cAliasSD2,cAlias0250)
	RCPE_GRAVA('H200','SD2',cAliasSD2,cAliasH200)
	RCPE_GRAVA('I100','SD2',cAliasSD2,cAliasI100)
	(cAliasSD2)->(dbSkip())
EndDo	

// Encerra Alias de Trabalho	
If Select(cAliasSD2) > 0 
	(cAliasSD2)->(dbCloseArea())
EndIf

//谀哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪目
//?M O V I M E N T O S   I N T E R N O S                    ?
//滥哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪馁
cQuery := "SELECT "
cQuery +=         "SD3.D3_FILIAL  , SD3.D3_COD, SD3.D3_LOCAL, SD3.D3_QUANT , SD3.D3_EMISSAO, SD3.D3_DOC    , SD3.D3_NUMSEQ,"
cQuery +=         "SD3.D3_CC      , SD3.D3_CF , SD3.D3_TM   , SD3.D3_CUSTO1, SD3.D3_QTSEGUM, SD3.D3_ESTORNO, SD3.D3_SERVIC, "
cQuery +=         "SD3.D3_OP      , SD3.D3_UM , SB1.B1_TIPO , SB1.B1_EMAX  , SB1.B1_OPERPAD, SB1.B1_UM     , SD3.R_E_C_N_O_ RECNOSD3 "
cQuery +=   "FROM "
cQuery +=         RetSqlName("SD3")  + " SD3, "
cQuery +=         RetSqlName("SB1")  + " SB1  "
cQuery +=  "WHERE "
cQuery +=         "SD3.D3_FILIAL   = '" + xFilial("SD3")	+ "' "
cQuery +=     "AND SB1.B1_FILIAL   = '" + xFilial("SB1")	+ "' "
// Amarracao SD3 x SB1
cQuery +=     "AND SD3.D3_COD      = SB1.B1_COD "
// Verifica os tipos de produtos
cQuery +=     "AND SB1.B1_TIPO IN (" + cTipo00 + "," + cTipo01 + "," + cTipo02 + "," + cTipo03 + "," + cTipo04 + "," + cTipo05 + "," + cTipo06 +" ) "
// Filtra o periodo/ano selecionado
cQuery +=     "AND SD3.D3_EMISSAO >= '" + DTOS(dDataDe)  + "' "
cQuery +=     "AND SD3.D3_EMISSAO <= '" + DTOS(dDataAte) + "' "
cQuery +=     "AND SD3.D3_ESTORNO  = ' ' "
cQuery +=     "AND SD3.D_E_L_E_T_  = ' ' "
cQuery +=     "AND SB1.D_E_L_E_T_  = ' ' "
//谀哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪?
//?Define o alias para a query                                 ?
//滥哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪?
cAliasSD3  := GetNextAlias()
//谀哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪?
//?Verifica se o alias esta em uso                             ?
//滥哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪?
If Select( cAliasSD3 ) > 0
	dbSelectArea( cAliasSD3 )
	dbCloseArea()
EndIf
//谀哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪?
//?Compatibiliza a query com o banco de dados                  ?
//滥哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪?
cQuery := ChangeQuery(cQuery)
//谀哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪?
//?Cria o alias executando a query                             ?
//滥哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪?
dbUseArea( .T., 'TOPCONN', TCGENQRY(,,cQuery), cAliasSD3 , .F., .T.)
//谀哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪?
//?Compatibiliza os campos de acordo com a TopField            ?
//滥哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪?
For nX := 1 To Len(aStruSD3)
	If aStruSD3[nX][2] <> "C"
		TcSetField(cAliasSD3,aStruSD3[nX][1],aStruSD3[nX][2],aStruSD3[nX][3],aStruSD3[nX][4])
	EndIf
Next nX  


// Processamento dos movimentos internos
dbSelectArea(cAliasSD3)
Do While (cAliasSD3)->(!Eof())
	// Gravacao dos Blocos
	RCPE_GRAVA('0210','SD3',cAliasSD3,cAlias0210)
	RCPE_GRAVA('0250','SD3',cAliasSD3,cAlias0250)
	RCPE_GRAVA('H200','SD3',cAliasSD3,cAliasH200)
	RCPE_GRAVA('H220','SD3',cAliasSD3,cAliasH220)
	RCPE_GRAVA('H230','SD3',cAliasSD3,cAliasH230)
	RCPE_GRAVA('H235','SD3',cAliasSD3,cAliasH235)
	RCPE_GRAVA('H260','SD3',cAliasSD3,cAliasH260)
	RCPE_GRAVA('H270','SD3',cAliasSD3,cAliasH270)
	RCPE_GRAVA('H275','SD3',cAliasSD3,cAliasH275)
	RCPE_GRAVA('I100','SD3',cAliasSD3,cAliasI100)
	RCPE_GRAVA('I210','SD3',cAliasSD3,cAliasI210,dDataAte)
	(cAliasSD3)->(dbSkip())
EndDo	

// Encerra Alias de Trabalho	
If Select(cAliasSD3) > 0 
	(cAliasSD3)->(dbCloseArea())
EndIf

// Realiza o fechamento dos arquivos de trabalho
If lClose
	If Select(cAlias0210) > 0
		(cAlias0210)->(dbCloseArea())
	EndIf	
	If Select(cAlias0250) > 0
		(cAlias0250)->(dbCloseArea())
	EndIf	
	If Select(cAliasH200) > 0
		(cAliasH200)->(dbCloseArea())
	EndIf	
	If Select(cAliasH220) > 0
		(cAliasH220)->(dbCloseArea())
	EndIf	
	If Select(cAliasH230) > 0
		(cAliasH230)->(dbCloseArea())
	EndIf	
	If Select(cAliasH235) > 0
		(cAliasH235)->(dbCloseArea())
	EndIf	
	If Select(cAliasH250) > 0
		(cAliasH250)->(dbCloseArea())
	EndIf	
	If Select(cAliasH255) > 0
		(cAliasH255)->(dbCloseArea())
	EndIf	
	If Select(cAliasH260) > 0
		(cAliasH260)->(dbCloseArea())
	EndIf	
	If Select(cAliasH265) > 0
		(cAliasH265)->(dbCloseArea())
	EndIf	
	If Select(cAliasH270) > 0
		(cAliasH270)->(dbCloseArea())
	EndIf	
	If Select(cAliasH275) > 0
		(cAliasH275)->(dbCloseArea())
	EndIf	
	If Select(cAliasI100) > 0
		(cAliasI100)->(dbCloseArea())
	EndIf	
	If Select(cAliasI210) > 0
		(cAliasI210)->(dbCloseArea())
	EndIf	
EndIf

Return

/*
苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北
北谀哪哪哪哪穆哪哪哪哪哪哪哪履哪哪哪履哪哪哪哪哪哪哪哪哪穆哪哪哪履哪哪哪哪目北
北矲un嘺o    ?RCPE_GRAVA   ?Autor ?TOTVS S/A			 ?Data ?01/04/13 潮?
北媚哪哪哪哪呐哪哪哪哪哪哪哪聊哪哪哪聊哪哪哪哪哪哪哪哪哪牧哪哪哪聊哪哪哪哪拇北
北矰escricao ?RCPE MG - ARQUIVO MAGNETICO                                 潮?
北?		 | Esta funcao tem o objetivo de gravar as informacoes de      潮?
北?		 | Estoque/Fiscal/Contabil em seus respectivos blocos.         潮?
北媚哪哪哪哪呐哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪拇北
北砅arametros?cBloco      = Codigo do bloco a ser gravado                 潮?
北?         ?cTabela     = Codigo da tabela de movimento em processamento潮?
北?         ?cAliasQRY   = Query ou Filtro de informacoes para gravacao  潮?
北?         ?cAliasTRB   = Alias do arquivo de trabalho do Bloco         潮?
北?         ?dDataAte    = Data Final da Apuracao                        潮?
北媚哪哪哪哪呐哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪拇北
北砋so       ?Arquivo Magnetico RCPE MG                                   潮?
北滥哪哪哪哪牧哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪馁北
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北
哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌
*/
Static Function RCPE_GRAVA(cBloco,cTabela,cAliasQRY,cAliasTRB,dDataAte)

Local nValorUnit    := 0
Local nX            := 0
Local cCodOri       := ''
Local cUMOri        := ''
Local cCodDest      := ''
Local cUMDest       := ''
Local cChave        := ''
Local cRoteiro      := ''
Local cChave250     := ''
Local cCodPai       := ''
Local cCodFase      := ''
Local aSaldo        := {}
Local aSalAtu       := {0,0,0,0,0,0,0}
Local dDataIni      := CTOD('  /  /  ')
Local dDataFim      := CTOD('  /  /  ')
Local lFound        := .F.

Local cTipo00       := SuperGetMv("MV_RCPETP0",.F.,"'MR'")
Local cTipo01       := SuperGetMv("MV_RCPETP1",.F.,"'MP'")
Local cTipo02       := SuperGetMv("MV_RCPETP2",.F.,"'EM'")
Local cTipo03       := SuperGetMv("MV_RCPETP3",.F.,"'PP'")
Local cTipo04       := SuperGetMv("MV_RCPETP4",.F.,"'PA'")
Local cTipo05  		:= SuperGetMv("MV_RCPETP5",.F.,"'SP'")
Local cTipo06       := SuperGetMv("MV_RCPETP6",.F.,"'PI'")
Local cIndustr      := SuperGetMv("MV_CFOPIND",.F.,"1124|1125")
Local cConsumo      := SuperGetMv("MV_CFOPCON",.F.,"1902")   
Local cRecnoSG1		:= 0    
Local aH260Ext		:= {}
Local cRevatu		
Local aPrEstr		:= {}

Default cBloco      := ''          
Default cTabela     := ''
Default cAliasQRY   := ''
default dDataAte    := CTOD('31/12/2013')

Do Case

	//谀哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪目
	//?Gravacao do Bloco 0210                                   ?
	//滥哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪馁
	Case cBloco == '0210'
	
		If cTabela == 'SD3'                                  
			// Este bloco somente deve existir quando o produto pai possuir os tipos: 03 e 04
			If	(cAliasQRY)->B1_TIPO $ cTipo03 .Or.	(cAliasQRY)->B1_TIPO $ cTipo04  
				If !((cAliasTRB)->(MsSeek(xFilial('SD3')+(cAliasQRY)->D3_COD)))
//					cRevAtu := Posicione("SB1",1,xFilial("SB1")+(cAliasQRY)->D3_COD,'B1_REVATU')
					dbSelectArea("SG1")
					dbSetOrder(1)
					If MsSeek(cChave:=xFilial("SG1")+(cAliasQRY)->D3_COD)  

						Do While !Eof() .And. SG1->G1_FILIAL+SG1->G1_COD == xFilial("SG1")+(cAliasQRY)->D3_COD
							// cTipo := Posicione("SB1",1,xFilial("SB1")+(cAliasQRY)->D3_COD,'B1_TIPO')
//							If cRevatu # Nil .and. 	!(SG1->G1_REVINI <= cRevatu .And. SG1->G1_REVFIM >= cRevatu) 
//                              Dbskip()
//                              Loop
//     						EndIf
							if len(aPrEstr) > 0        							// evita componentes duplicados por revis鮡s
								if ASCAN(aPrEstr,{|x| x == SG1->G1_COMP}) > 0  
	                               Dbskip()
		                           Loop								   							
		      					EndIf
		      				EndIf
							aadd(aPrEstr,SG1->G1_COMP)     
							
							cTipo := Posicione("SB1",1,xFilial("SB1")+SG1->G1_COMP,'B1_TIPO')
							// Este bloco somente deve existir quando o produto 'i possuir os tipos de 00 a 05
							If	cTipo $ cTipo00 .Or. cTipo $ cTipo01 .Or.;
								cTipo $ cTipo02 .Or. cTipo $ cTipo03 .Or.;
								cTipo $ cTipo04 .Or. cTipo $ cTipo05

								// Recupera o codigo da Fase
								cCodFase := RCPE_CODFASE()
														
								// Gravacao do bloco 0210
								Reclock(cAliasTRB,.T.)
								FILIAL      := (cAliasQRY)->D3_FILIAL 								// Campo 00 - Codigo da Filial (Nao pertence ao Layout)
								REG         := cBloco		   										// Campo 01 - Codigo do Bloco
								COD_ITEM    := (cAliasQRY)->D3_COD									// Campo 02 - Codigo do Produto Item (Nao pertence ao Layout)
								UNID_ITEM   := (cAliasQRY)->B1_UM									// Campo 03 - Unidade de Medida Item
								COD_I_COMP  := SG1->G1_COMP											// Campo 04 - Codigo do Produto Componente
								QTD_C_MIN   := SG1->G1_QUANT										// Campo 05 - Quantidade Minima
								QTD_C_MAX   := SG1->G1_QUANT*(1+((100-SG1->G1_PERDA)/100))		// Campo 06 - Quantidade Maxima
								UNID_COMP   := SB1->B1_UM									 		// Campo 07 - Unidade de medida Componente
								COD_FASE    := cCodFase												// Campo 08 - Codigo da Fase
								TIPO        := cTipo												// Campo 09 - Tipo do Produto Componente (Nao pertence ao Layout)
								ALIAS       := cTabela												// Campo 10 - Alias da Tabela PROTHEUS   (Nao pertence ao Layout)
								RECNOPRO    := (cAliasQRY)->RECNOSD3								// Campo 11 - Recno da Tabela PROTHEUS   (Nao pertence ao Layout)
							EndIf
							dbSelectArea("SG1")
							dbSkip()
						EndDo	
					EndIf
				EndIf
			EndIf    
		EndIf	

	//谀哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪目
	//?Gravacao do Bloco 0250                                   ?
	//滥哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪馁
	Case cBloco == '0250'
	
		dbSelectArea(cAliasTRB)
		If cTabela == 'SD1'
			If !MsSeek(xFilial("SD1")+(cAliasQRY)->B1_UM)
				// Gravacao do bloco 0250
				Reclock(cAliasTRB,.T.)
				FILIAL      := (cAliasQRY)->D1_FILIAL 												// Campo 00 - Codigo da Filial (Nao pertence ao Layout)
				REG         := cBloco		   														// Campo 01 - Codigo do Bloco
				UNID 	    := (cAliasQRY)->B1_UM													// Campo 02 - Codigo da Unidade de Medida
		    	DESCR     	:= Posicione("SAH",1,xFilial("SAH")+(cAliasQRY)->B1_UM,'AH_DESCPO')	// Campo 03 - Descricao do Centro de Custos
				TIPO_UNI    := 'S'				                                                    // Campo 04 - Tipo da Unidade de Medida
				ALIAS       := cTabela																// Campo 05 - Alias da Tabela PROTHEUS (Nao pertence ao Layout)
				RECNOPRO    := (cAliasQRY)->RECNOSD1												// Campo 06 - Recno da Tabela PROTHEUS (Nao pertence ao Layout)
				MsUnLock()
			EndIf
		ElseIf cTabela == 'SD2'
			If !MsSeek(xFilial("SD2")+(cAliasQRY)->B1_UM)
				// Gravacao do bloco 0250
				Reclock(cAliasTRB,.T.)
				FILIAL      := (cAliasQRY)->D2_FILIAL 												// Campo 00 - Codigo da Filial (Nao pertence ao Layout)
				REG         := cBloco		   														// Campo 01 - Codigo do Bloco
				UNID 	    := (cAliasQRY)->B1_UM													// Campo 02 - Codigo da Unidade de Medida
		    	DESCR     	:= Posicione("SAH",1,xFilial("SAH")+(cAliasQRY)->B1_UM,'AH_DESCPO')	// Campo 03 - Descricao do Centro de Custos
				TIPO_UNI    := 'S'																	// Campo 04 - Tipo da Unidade de Medida
				ALIAS       := cTabela																// Campo 05 - Alias da Tabela PROTHEUS (Nao pertence ao Layout)
				RECNOPRO    := (cAliasQRY)->RECNOSD2												// Campo 06 - Recno da Tabela PROTHEUS (Nao pertence ao Layout)
				MsUnLock()
			EndIf
		ElseIf cTabela == 'SD3'
			If !MsSeek(xFilial("SD3")+(cAliasQRY)->B1_UM)
				// Gravacao do bloco 0250
				Reclock(cAliasTRB,.T.)
				FILIAL      := (cAliasQRY)->D3_FILIAL 												// Campo 00 - Codigo da Filial (Nao pertence ao Layout)
				REG         := cBloco		   														// Campo 01 - Codigo do Bloco
				UNID 	    := (cAliasQRY)->B1_UM													// Campo 02 - Codigo da Unidade de Medida
		    	DESCR     	:= Posicione("SAH",1,xFilial("SAH")+(cAliasQRY)->B1_UM,'AH_DESCPO')	// Campo 03 - Descricao do Centro de Custos
				TIPO_UNI    := 'S'																	// Campo 04 - Tipo da Unidade de Medida
				ALIAS       := cTabela																// Campo 05 - Alias da Tabela PROTHEUS (Nao pertence ao Layout)
				RECNOPRO    := (cAliasQRY)->RECNOSD3												// Campo 06 - Recno da Tabela PROTHEUS (Nao pertence ao Layout)
				MsUnLock()
			EndIf	
		EndIf
		dbSelectArea(cAliasQRY)

	//谀哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪目
	//?Gravacao do Bloco H200                                   ?
	//滥哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪馁
	Case cBloco == 'H200'

		// Processar somente Tipos: 00, 01, 02, 03, 04, 05 e 06
		If	(cAliasQRY)->B1_TIPO $ cTipo00 .Or.	(cAliasQRY)->B1_TIPO $ cTipo01 .Or.;
			(cAliasQRY)->B1_TIPO $ cTipo02 .Or.	(cAliasQRY)->B1_TIPO $ cTipo03 .Or.;
			(cAliasQRY)->B1_TIPO $ cTipo04 .Or.	(cAliasQRY)->B1_TIPO $ cTipo05 .Or.;
			(cAliasQRY)->B1_TIPO $ cTipo06 

			If cTabela == "SD1"
				// Calculo do Valor Unitario (Obrigatorio somente para os tipo 00, 01, 02 e 06)
				If	(cAliasQRY)->B1_TIPO $ cTipo00 .Or.	(cAliasQRY)->B1_TIPO $ cTipo01 .Or.;
					(cAliasQRY)->B1_TIPO $ cTipo02 .Or.	(cAliasQRY)->B1_TIPO $ cTipo06 
					If (cAliasQRY)->D1_QUANT > 0 
						nValorUnit := IIf( (cAliasQRY)->D1_BASEIPI>0,(cAliasQRY)->D1_BASEIPI,(cAliasQRY)->D1_TOTAL) / (cAliasQRY)->D1_QUANT 
					Else
						nValorUnit := IIf((cAliasQRY)->D1_BASEIPI>0,(cAliasQRY)->D1_BASEIPI,(cAliasQRY)->D1_TOTAL )
					EndIf  
				EndIf
				// Gravacao do bloco H200
				Reclock(cAliasTRB,.T.)
				FILIAL         := (cAliasQRY)->D1_FILIAL 				// Campo 00 - Codigo da Filial (Nao pertence ao Layout)
				REG            := cBloco								// Campo 01 - Codigo do Bloco
				DT_MOV         := (cAliasQRY)->D1_DTDIGIT				// Campo 02 - Data da Entrada no Estoque
				COD_ITEM       := (cAliasQRY)->D1_COD					// Campo 03 - Codigo do Produto
				VL_UNIT        := nValorUnit							// Campo 04 - Valor Unitario da Entrada
				QTD 	       := ABS((cAliasQRY)->D1_QUANT)			// Campo 05 - Quantidade Absoluta do Produto
				UNID 	       := (cAliasQRY)->B1_UM					// Campo 06 - Codigo da Unidade de Medida
				IND_OPE        := RCPE_TPINF(cTabela,cAliasQRY)			// Campo 07 - Indicador do tipo de informacao
	            If !(IND_OPE $ "0|1|2")
					TIPO_MOV   := RCPE_TPMOV(cTabela,cAliasQRY)			// Campo 08 - Tipo de Movimentacao
					IND_DOC_OP := 'F' // F-Documento Fiscal				// Campo 09 - Indicador de Documento
					COD_CCUS   := (cAliasQRY)->D1_CC					// Campo 10 - Codigo Centro de Custos
					FINALID    :=(cAliasQRY)->F4_FINALID				// Campo 11 - Descricao da Finalidade
				EndIf	
				CAPAC_ARMZ := (cAliasQRY)->B1_EMAX			            // Campo 12 - Capacidade de Armazenagem
				ALIAS      := cTabela									// Campo 13 - Alias da Tabela PROTHEUS (Nao pertence ao Layout)
				RECNOPRO   := (cAliasQRY)->RECNOSD1						// Campo 14 - Recno da Tabela PROTHEUS (Nao pertence ao Layout)
				TIPO       := (cAliasQRY)->B1_TIPO						// Campo 15 - Tipo de Produto (Nao pertence ao Layout)
				MsUnLock()
	
			ElseIf cTabela == "SD2"
				// Calculo do Valor Unitario (Obrigatorio somente para os tipo 00, 01, 02 e 06)
				If	(cAliasQRY)->B1_TIPO $ cTipo00 .Or.	(cAliasQRY)->B1_TIPO $ cTipo01 .Or.;
					(cAliasQRY)->B1_TIPO $ cTipo02 .Or.	(cAliasQRY)->B1_TIPO $ cTipo06 
					If (cAliasQRY)->D2_QUANT > 0 
						nValorUnit := IIf((cAliasQRY)->D2_BASEIPI>0,(cAliasQRY)->D2_BASEIPI,(cAliasQRY)->D2_TOTAL) / (cAliasQRY)->D2_QUANT
					Else
						nValorUnit := IIf((cAliasQRY)->D2_BASEIPI>0,(cAliasQRY)->D2_BASEIPI,(cAliasQRY)->D2_TOTAL)
					EndIf  
				EndIf
				// Gravacao do bloco H200
				Reclock(cAliasTRB,.T.)
				FILIAL         := (cAliasQRY)->D2_FILIAL 					// Campo 00 - Codigo da Filial (Nao pertence ao Layout)
				REG            := cBloco									// Campo 01 - Codigo do Bloco
				DT_MOV         := (cAliasQRY)->D2_EMISSAO   				// Campo 02 - Data da Entrada no Estoque
				COD_ITEM       := (cAliasQRY)->D2_COD						// Campo 03 - Codigo do Produto
				VL_UNIT        := nValorUnit								// Campo 04 - Valor Unitario da Entrada
				QTD 	       := ABS((cAliasQRY)->D2_QUANT)				// Campo 05 - Quantidade Absoluta do Produto	
				UNID 	       := (cAliasQRY)->B1_UM						// Campo 06 - Codigo da Unidade de Medida
				IND_OPE        := RCPE_TPINF(cTabela,cAliasQRY)			 	// Campo 07 - Indicador do tipo de informacao
	            If !(IND_OPE $ "0|1|2")
					TIPO_MOV   := RCPE_TPMOV(cTabela,cAliasQRY) 			// Campo 08 - Tipo de Movimentacao
					IND_DOC_OP := 'F' // F-Documento Fiscal	 				// Campo 09 - Indicador de Documento
					COD_CCUS   :=(cAliasQRY)->D2_CCUSTO						// Campo 10 - Codigo Centro de Custos
					FINALID    :=(cAliasQRY)->F4_FINALID					// Campo 11 - Descricao da Finalidade
				EndIf
				CAPAC_ARMZ := (cAliasQRY)->B1_EMAX			           		// Campo 12 - Capacidade de Armazenagem
				ALIAS      := cTabela										// Campo 13 - Alias da Tabela PROTHEUS (Nao pertence ao Layout)
				RECNOPRO   := (cAliasQRY)->RECNOSD2							// Campo 14 - Recno da Tabela PROTHEUS (Nao pertence ao Layout)
				TIPO       := (cAliasQRY)->B1_TIPO							// Campo 15 - Tipo de Produto (Nao pertence ao Layout)
				MsUnLock()

			ElseIf cTabela == "SD3" //.And. !((cAliasQRY)->D3_CF $ "RE4|DE4" .and. Empty((cAliasQRY)->D3_OP) )
				// Calculo do Valor Unitario (Obrigatorio somente para os tipo 00, 01, 02 e 06)
				If	(cAliasQRY)->B1_TIPO $ cTipo00 .Or.	(cAliasQRY)->B1_TIPO $ cTipo01 .Or.;
					(cAliasQRY)->B1_TIPO $ cTipo02 .Or.	(cAliasQRY)->B1_TIPO $ cTipo06 
					If (cAliasQRY)->D3_QUANT > 0 
						nValorUnit := (cAliasQRY)->D3_CUSTO1 / (cAliasQRY)->D3_QUANT
					Else
						nValorUnit := (cAliasQRY)->D3_CUSTO1
					EndIf  
				EndIf
				// Gravacao do bloco H200
				Reclock(cAliasTRB,.T.)
				FILIAL         := (cAliasQRY)->D3_FILIAL 				// Campo 00 - Codigo da Filial (Nao pertence ao Layout)
				REG            := cBloco								// Campo 01 - Codigo do Bloco
				DT_MOV         := (cAliasQRY)->D3_EMISSAO   			// Campo 02 - Data da Entrada no Estoque
				COD_ITEM       := (cAliasQRY)->D3_COD					// Campo 03 - Codigo do Produto
				VL_UNIT        := nValorUnit							// Campo 04 - Valor Unitario da Entrada
				QTD 	       := ABS((cAliasQRY)->D3_QUANT)			// Campo 05 - Quantidade Absoluta do Produto	
				UNID 	       := (cAliasQRY)->B1_UM					// Campo 06 - Codigo da Unidade de Medida
				IND_OPE        := RCPE_TPINF(cTabela,cAliasQRY)  		// Campo 07 - Indicador do tipo de informacao
	            If !(IND_OPE $ "0|1|2")
					TIPO_MOV   := RCPE_TPMOV(cTabela,cAliasQRY)  		// Campo 08 - Tipo de Movimentacao
					IND_DOC_OP := 'I' // I-Documento Interno			// Campo 09 - Indicador de Documento
					COD_CCUS   := (cAliasQRY)->D3_CC					// Campo 10 - Codigo Centro de Custos
	 				If AllTrim(TIPO_MOV) == 'CS'
	 				   FINALID     := 'Consumo no Estabelecimento'      // Campo 11 - Descricao da Finalidade
	 				Else
		 				FINALID    := ''								// Campo 11 - Descricao da Finalidade
		 			Endif	
				Else
					If IND_OPE == '0'
						TIPO_MOV   := RCPE_TPMOV(cTabela,cAliasQRY)  		// Campo 08 - Tipo de Movimentacao
						IND_DOC_OP := 'I' // I-Documento Interno			// Campo 09 - Indicador de Documento
						COD_CCUS   := (cAliasQRY)->D3_CC					// Campo 10 - Codigo Centro de Custos
		 				If AllTrim(TIPO_MOV) == 'CS'
		 				    FINALID     := 'Consumo no Estabelecimento'     // Campo 11 - Descricao da Finalidade
		 				Else
			 				FINALID    := ''								// Campo 11 - Descricao da Finalidade
			 			Endif	
					EndIF
				EndIF					
				CAPAC_ARMZ := (cAliasQRY)->B1_EMAX			           	// Campo 12 - Capacidade de Armazenagem
				ALIAS      := cTabela									// Campo 13 - Alias da Tabela PROTHEUS (Nao pertence ao Layout)
				RECNOPRO   := (cAliasQRY)->RECNOSD3						// Campo 14 - Recno da Tabela PROTHEUS (Nao pertence ao Layout)
				TIPO       := (cAliasQRY)->B1_TIPO						// Campo 15 - Tipo de Produto (Nao pertence ao Layout)
				MsUnLock()
			EndIf

	    EndIf
	    
	//谀哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪目
	//?Gravacao do Bloco H220                                   ?
	//滥哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪馁
	Case cBloco == 'H220'

		// Considerar somente movimentos que nao sao de producao
		If cTabela == 'SD3' .And. Empty((cAliasQRY)->D3_OP) .And. (cAliasQRY)->D3_CF $ "RE4|DE4"
			// Avaliacao de Tranferencia Interna
			If (cAliasQRY)->D3_CF $ "RE4"
				cCodOri  := (cAliasQRY)->D3_COD
				cUMOri   := (cAliasQRY)->B1_UM
			  	SD3->(dbSetOrder(4))
			  	If SD3->(MsSeek(xFilial('SD3')+((cAliasQRY)->D3_NUMSEQ)+'E9'))
					cCodDest  := SD3->D3_COD
					If SB1->(MsSeek(xFilial('SB1')+SD3->D3_COD))
						cUMDest := SB1->B1_UM
					EndIf	
				EndIf
				If Empty(cCodDest)                                                        // Apontamentos de perda n鉶 tem E9
					If SD3->(MsSeek(xFilial('SD3')+((cAliasQRY)->D3_NUMSEQ)+'E0')) 
					  	Do While SD3->D3_FILIAL = xFilial('SD3') .and. SD3->D3_NUMSEQ+SD3->D3_CHAVE = ((cAliasQRY)->D3_NUMSEQ)+'E0' 
							If SD3->D3_CF $ "DE4"
								cCodDest  := SD3->D3_COD
								If SB1->(MsSeek(xFilial('SB1')+SD3->D3_COD))
									cUMDest := SB1->B1_UM
								EndIf	
							EndIf
							SD3->(dbSkip())
						EndDo
					EndIf
				EndIf
				dbSelectArea(cAliasQRY)
			// Avaliacao de Tranferencia Interna
			ElseIf (cAliasQRY)->D3_CF $ "DE4"
				cCodDest  := (cAliasQRY)->D3_COD
				cUMDest   := (cAliasQRY)->B1_UM
				dbSelectArea(cAliasTRB)
			  	SD3->(dbSetOrder(4))
			  	If SD3->(MsSeek(xFilial('SD3')+((cAliasQRY)->D3_NUMSEQ)+'E0'))
					cCodOri   := SD3->D3_COD
					If SB1->(MsSeek(xFilial('SB1')+SD3->D3_COD))
						cUMOri := SB1->B1_UM
					EndIf	
			  	EndIf
				dbSelectArea(cAliasQRY)
			// Outros Movimentos Internos
			Else
				cCodOri := (cAliasQRY)->D3_COD
				cUMOri  := (cAliasQRY)->D3_UM
			EndIf
			// Gravacao do bloco H220
			If  cCodOri <> cCodDest
				Reclock(cAliasTRB,.T.)
				FILIAL          := (cAliasQRY)->D3_FILIAL 			// Campo 00 - Codigo da Filial (Nao pertence ao Layout)
				REG             := cBloco							// Campo 01 - Codigo do Bloco
				DT_MOV          := (cAliasQRY)->D3_EMISSAO         // Campo 02 - Data da Movimentacao
				COD_ITEM_O  	:= cCodOri							// Campo 03 - Codigo do Produto Origem
				UNID_ORI    	:= cUMOri							// Campo 04 - Unidade de Medida Origem
				COD_ITEM_D  	:= cCodDest							// Campo 05 - Codigo do Produto Destino
				UNID_DES    	:= cUMDest							// Campo 06 - Unidade de Medida Destino
				QTD             := (cAliasQRY)->D3_QUANT			// Campo 07 - Quantidade da Movimentaca
				NUMSEQ          := (cAliasQRY)->D3_NUMSEQ			// Campo 08 - Campo de Controle (Nao faz Parte do RCPE)
				ALIAS           := cTabela							// Campo 09 - Alias da Tabela PROTHEUS (Nao pertence ao Layout)
				RECNOPRO        := (cAliasQRY)->RECNOSD3			// Campo 10 - Recno da Tabela PROTHEUS (Nao pertence ao Layout)
				MsUnLock()
			EndIf
		EndIf

	//谀哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪目
	//?Gravacao do Bloco H230                                   ?
	//滥哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪馁
	Case cBloco == 'H230'

		// Considerar somente Apontamento de Producao
		If cTabela == 'SD3' .And. !Empty((cAliasQRY)->D3_OP) .And. (cAliasQRY)->D3_CF $ "PR0|PR1"
			// Considerar somente Produtos Tipo 03 e 04
			If	(cAliasQRY)->B1_TIPO $ cTipo03 .Or.	(cAliasQRY)->B1_TIPO $ cTipo04
				// Recuperar data de inicio/fim da tabela de Ordem de Procucao
				SC2->(dbSetOrder(1))
				If SC2->(MsSeek(xFilial("SC2")+(cAliasQRY)->D3_OP)) 
				    dDataIni := SC2->C2_DATPRI
				    dDataFim := SC2->C2_DATPRF
				EndIf

				// Recupera o codigo da Fase
				cCodFase := RCPE_CODFASE()
				
				// Gravacao do bloco H230
				Reclock(cAliasTRB,!lFound)
				FILIAL          := (cAliasQRY)->D3_FILIAL 			// Campo 00 - Codigo da Filial (Nao pertence ao Layout)
				REG             := cBloco							// Campo 01 - Codigo do Bloco
				DT_INI_OP       := dDataIni							// Campo 02 - Data de Inicio da Ordem de Producao
				DT_FIN_OP       := (cAliasQRY)->D3_EMISSAO			// Campo 03 - Data de apontamento da Ordem de Producao
				COD_DOC_OP      := (cAliasQRY)->D3_OP				// Campo 04 - Codigo da Ordem de Producao
				COD_ITEM        := (cAliasQRY)->D3_COD				// Campo 05 - Codigo do Produto
				UNID            := (cAliasQRY)->D3_UM				// Campo 06 - Unidade de Medida
				QTD_ENC         := (cAliasQRY)->D3_QUANT			// Campo 07 - Quantidade Produzida
				COD_FASE        := cCodFase							// Campo 08 - Codigo da Fase
				ALIAS           := cTabela							// Campo 09 - Alias da Tabela PROTHEUS (Nao pertence ao Layout)
				RECNOPRO        := (cAliasQRY)->RECNOSD3			// Campo 10 - Recno da Tabela PROTHEUS (Nao pertence ao Layout)
				MsUnLock()
		    EndIf
 		EndIf
				
	//谀哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪目
	//?Gravacao do Bloco H235                                   ?
	//滥哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪馁
	Case cBloco == 'H235'

		// Considerar somente Consumo de Producao
		If cTabela == 'SD3' .And. !Empty((cAliasQRY)->D3_OP) .And. Substr((cAliasQRY)->D3_CF,1,1)=='R'
			// Considerar somente Produtos Tipo 01 a 05
			If	(cAliasQRY)->B1_TIPO $ cTipo01 .Or.	(cAliasQRY)->B1_TIPO $ cTipo02 .Or.;
				(cAliasQRY)->B1_TIPO $ cTipo03 .Or.	(cAliasQRY)->B1_TIPO $ cTipo04 .Or.;			
				(cAliasQRY)->B1_TIPO $ cTipo05
				// Gravacao do bloco H235
				Reclock(cAliasTRB,.T.)
				FILIAL          := (cAliasQRY)->D3_FILIAL 			// Campo 00 - Codigo da Filial (Nao pertence ao Layout)
				REG             := cBloco							// Campo 01 - Codigo do Bloco
				DT_SAIDA        := (cAliasQRY)->D3_EMISSAO			// Campo 02 - Data de Saida do Estoque
				COD_ITEM        := (cAliasQRY)->D3_COD				// Campo 03 - Codigo do Produto
				QTD             := (cAliasQRY)->D3_QUANT			// Campo 04 - Quantidade Consumida
				UNID            := (cAliasQRY)->D3_UM				// Campo 05 - Unidade de Medida
				COD_INS_SU      := ''								// Campo 06 - Codigo do Insumo Substituido
				COD_DOC_OP      := (cAliasQRY)->D3_OP				// Campo 07 - Codigo da Ordem de Producao (Nao Pertence ao Layout)
				ALIAS           := cTabela							// Campo 08 - Alias da Tabela PROTHEUS (Nao pertence ao Layout)
				RECNOPRO        := (cAliasQRY)->RECNOSD3			// Campo 09 - Recno da Tabela PROTHEUS (Nao pertence ao Layout)
				MsUnLock()
		    EndIf
		EndIf

	//谀哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪目
	//?Gravacao do Bloco H250                                   ?
	//滥哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪馁
	Case cBloco == 'H250'

		// Considerar somente Produtos Tipo 03 e 04
		If	(cAliasQRY)->B1_TIPO $ cTipo03 .Or.	(cAliasQRY)->B1_TIPO $ cTipo04
			// Considerar somente devolucao de poder de terceiros e CFOP configurados no parametro MV_CFOPIND
			If cTabela == 'SD1' .And. (cAliasQRY)->F4_PODER3 == 'D' .And. AllTrim((cAliasQRY)->D1_CF) $ AllTrim(cIndustr)
				//Chave para amarracao dos blocos H250/H255
				cChave250 := (cAliasQRY)->D1_DOC+(cAliasQry)->D1_SERIE+(cAliasQry)->D1_FORNECE+(cAliasQry)->D1_LOJA
				// Gravacao do bloco H250
				Reclock(cAliasTRB,.T.)
				FILIAL          := (cAliasQRY)->D1_FILIAL 			// Campo 00 - Codigo da Filial (Nao pertence ao Layout)
				REG             := cBloco							// Campo 01 - Codigo do Bloco
				DT_PROD         := (cAliasQRY)->D1_DTDIGIT         // Campo 02 - Data do reconhecimento da producao
				COD_ITEM        := (cAliasQRY)->D1_COD             // Campo 03 - Codigo do Produto  
				QTD             := (cAliasQRY)->D1_QUANT           // Campo 04 - Quantidade Produzida
				UNID            := (cAliasQRY)->D1_UM              // Campo 05 - Unidade de Medida do item
				COD_FASE        := ''                           	// Campo 06 - Codigo da Fase de producao
				CHAVE           := cChave250	                    // Campo 07 - Chave para amarracao entre H250/H255
				ALIAS           := cTabela							// Campo 08 - Alias da Tabela PROTHEUS (Nao pertence ao Layout)
				RECNOPRO        := (cAliasQRY)->RECNOSD1			// Campo 09 - Recno da Tabela PROTHEUS (Nao pertence ao Layout)
				MsUnLock()
			EndIf
		EndIf

	//谀哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪目
	//?Gravacao do Bloco H255                                   ?
	//滥哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪馁
	Case cBloco == 'H255'

		// Considerar somente Produtos Tipo 01 a 05
		If	(cAliasQRY)->B1_TIPO $ cTipo01 .Or.	(cAliasQRY)->B1_TIPO $ cTipo02 .Or.;
			(cAliasQRY)->B1_TIPO $ cTipo03 .Or.	(cAliasQRY)->B1_TIPO $ cTipo04 .Or.;			
			(cAliasQRY)->B1_TIPO $ cTipo05
			// Considerar somente devolucao de poder de terceiros e CFOP configurados no parametro MV_CFOPIND
			If cTabela == 'SD1' .And. (cAliasQRY)->F4_PODER3 == 'D' .And. AllTrim((cAliasQRY)->D1_CF) $ AllTrim(cConsumo)
				//Chave para amarracao dos blocos H250/H255
				cChave250 := (cAliasQRY)->D1_DOC+(cAliasQry)->D1_SERIE+(cAliasQry)->D1_FORNECE+(cAliasQry)->D1_LOJA
				// Gravacao do bloco H250
				Reclock(cAliasTRB,.T.)
				FILIAL          := (cAliasQRY)->D1_FILIAL 			// Campo 00 - Codigo da Filial (Nao pertence ao Layout)
				REG             := cBloco							// Campo 01 - Codigo do Bloco
				DT_CONS         := (cAliasQRY)->D1_DTDIGIT         // Campo 02 - Data do reconhecimento da producao
				COD_ITEM        := (cAliasQRY)->D1_COD             // Campo 03 - Codigo do Produto  
				QTD             := (cAliasQRY)->D1_QUANT           // Campo 04 - Quantidade Produzida
				UNID            := (cAliasQRY)->B1_UM              // Campo 05 - Unidade de Medida do item
				COD_INS_SUBST   := ''                               // Campo 06 - Codigo do insumo substituto
				CHAVE           := cChave250	                    // Campo 07 - Chave para amarracao entre H250/H255 (Nao pertence ao Layout)
				ALIAS           := cTabela							// Campo 08 - Alias da Tabela PROTHEUS (Nao pertence ao Layout)
				RECNOPRO        := (cAliasQRY)->RECNOSD1			// Campo 09 - Recno da Tabela PROTHEUS (Nao pertence ao Layout)
				MsUnLock()
			EndIf
		EndIf

	//谀哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪目
	//?Gravacao do Bloco H260                                   ?
	//滥哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪馁
	Case cBloco == 'H260'

		// Considerar somente Apontamento de Producao
		If cTabela == 'SD3' .And. !Empty((cAliasQRY)->D3_OP) .And. (cAliasQRY)->D3_CF $ "PR0|PR1"
			// Considerar somente Produtos Tipo 03 e 04
			If	(cAliasQRY)->B1_TIPO $ cTipo03 .Or.	(cAliasQRY)->B1_TIPO $ cTipo04
				SC2->(dbSetOrder(1))
				If SC2->(MsSeek(xFilial('SC2')+(cAliasQRY)->D3_OP, .F.)) .And. !Empty(SC2->C2_ROTEIRO)
					cRoteiro := SC2->C2_ROTEIRO
				ElseIf !Empty(SB1->B1_OPERPAD)
					cRoteiro := (cAliasQRY)->B1_OPERPAD
				Else
					cRoteiro := ''
				EndIf
				
				// Gravacao das Fase de Producao (Tabela SG2)
				If !Empty(cRoteiro)
					SG2->(MsSeek(cChave:=xFilial('SG2')+(cAliasQRY)->D3_COD+cRoteiro))
					Do While !SG2->(Eof()) .And. cChave == SG2->G2_FILIAL+SG2->G2_PRODUTO+SG2->G2_CODIGO

						dbSelectArea("SG1")
						dbSetOrder(1)
						MsSeek(xFilial("SG1")+(cAliasQRY)->D3_COD)       // Usa o nivel invertido para a ordena玢o da produ玢o.

						// Gravacao do bloco H260
						Reclock(cAliasTRB,.T.)
						FILIAL          := xFilial('SG2')					// Campo 00 - Codigo da Filial (Nao pertence ao Layout)
						REG             := cBloco							// Campo 01 - Codigo do Bloco
						COD_FASE        := SG2->G2_CODIGO					// Campo 02 - Codigo da Fase
						DESCR_FASE      := SG2->G2_DESCRI					// Campo 03 - Descricao da Fase
						ORD_FASE        := Val(SG2->G2_OPERAC)   			// Campo 04 - Codigo da Operacao
						ORD_FASE        := val(SG1->G1_NIVINV)
						CAPAC_PROD      := SG2->G2_LOTEPAD					// Campo 05 - Lote Padrao de Producao
						UNID_CAPAC      := (cAliasQRY)->D3_UM				// Campo 06 - Unidade de Medida da Operacao
						COD_ITEM        := (cAliasQRY)->D3_COD             // Campo 07 - Codigo do Produto (Nao pertence ao layout)
						ALIAS           := cTabela							// Campo 08 - Alias da Tabela PROTHEUS (Nao pertence ao Layout)
						RECNOPRO        := (cAliasQRY)->RECNOSD3			// Campo 09 - Recno da Tabela PROTHEUS (Nao pertence ao Layout)
						MsUnLock()
						SG2->(dbSkip())
					EndDo
				Else
					// ponto de entrada para gera玢o do Registro H260 na ausencia do roteiro
					If Existblock ('RCPEP3R0') .and. !Empty((cAliasQRY)->D3_FILIAL)  .and. !Empty((cAliasQRY)->D3_OP) .and. !Empty((cAliasQRY)->D3_COD)
						aH260Ext := ExecBlock("RCPEP3R0",.F.,.F.,{(cAliasQRY)->D3_FILIAL,(cAliasQRY)->D3_OP,(cAliasQRY)->D3_COD})  
						Reclock(cAliasTRB,.T.)
						FILIAL          := xFilial('SG2')					// Campo 00 - Codigo da Filial (Nao pertence ao Layout)
						REG             := cBloco							// Campo 01 - Codigo do Bloco
						COD_FASE        := aH260ext[1]         				// Campo 02 - Codigo da Fase
						DESCR_FASE      := aH260ext[2]						// Campo 03 - Descricao da Fase
						ORD_FASE        := aH260ext[3]     		  			// Campo 04 - Codigo da Operacao
						CAPAC_PROD      := aH260ext[4]						// Campo 05 - Lote Padrao de Producao
						UNID_CAPAC      := aH260ext[5]						// Campo 06 - Unidade de Medida da Operacao
						COD_ITEM        := (cAliasQRY)->D3_COD             // Campo 07 - Codigo do Produto (Nao pertence ao layout)
						ALIAS           := cTabela							// Campo 08 - Alias da Tabela PROTHEUS (Nao pertence ao Layout)
						RECNOPRO        := (cAliasQRY)->RECNOSD3			// Campo 09 - Recno da Tabela PROTHEUS (Nao pertence ao Layout)
						MsUnLock()
					EndIf
				EndIf			
			EndIf
		EndIf	                                                     
	
	//谀哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪目
	//?Gravacao do Bloco H265                                   ?
	//滥哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪馁
	Case cBloco == 'H265'

		// Este bloco nao sera gerado pois as unidades de medidas sao identificas no Protheus
		
	//谀哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪目
	//?Gravacao do Bloco H270                                   ?
	//滥哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪馁
	Case cBloco == 'H270'

		// Neste Bloco deve ser considerados somente os movimentos de acerto apontamento de producao (Inventario)
		If cTabela == 'SD3' .And. Empty((cAliasQRY)->D3_OP) .And. AllTrim((cAliasQRY)->D3_DOC) == 'INVENT'
			// Considerar somente Produtos Tipo 03 e 04
			If	(cAliasQRY)->B1_TIPO $ cTipo03 .Or.	(cAliasQRY)->B1_TIPO $ cTipo04 
				Reclock(cAliasTRB,.T.)
				FILIAL          := xFilial('SD3')					// Campo 00 - Codigo da Filial (Nao pertence ao Layout)
				REG             := cBloco							// Campo 01 - Codigo do Bloco
				DT_INI          := (cAliasQRY)->D3_EMISSAO			// Campo 02 - Data Inicial do periodo de apuracao
				DT_FIN          := (cAliasQRY)->D3_EMISSAO			// Campo 03 - Data Inicial do periodo de apuracao
				COD_DOC_OP      := (cAliasQRY)->D3_OP				// Campo 04 - Codigo da Ordem de Producao
				COD_ITEM        := (cAliasQRY)->D3_COD				// Campo 05 - Codigo do Produto
				UNID            := (cAliasQRY)->D3_UM				// Campo 06 - Unidade de Medida
				If Substr((cAliasQRY)->D3_CF,1,1) == 'D'
					QTD_AC_POS  := (cAliasQRY)->D3_QUANT			// Campo 07 - Quantidade de acerto Positivo
				ElseIf Substr((cAliasQRY)->D3_CF,1,1) == 'R'
					QTD_AC_NEG  :=(cAliasQRY)->D3_QUANT				// Campo 08 - Quantidade de acerto Negativo
				EndIf
				COD_FASE        := ''								// Campo 09 - Codigo da Fase
				TIPO            := (cAliasQRY)->B1_TIPO            // Campo 10 - Tipo do Produto (Nao pertence ao Layout)
				ALIAS           := cTabela							// Campo 11 - Alias da Tabela PROTHEUS (Nao pertence ao Layout)
				RECNOPRO        := (cAliasQRY)->RECNOSD3			// Campo 12 - Recno da Tabela PROTHEUS (Nao pertence ao Layout)
				MsUnLock()
			EndIf	
		EndIf

	//谀哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪目
	//?Gravacao do Bloco H275                                   ?
	//滥哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪馁
	Case cBloco == 'H275'

		// Neste Bloco deve ser considerados somente os movimentos de acerto consumo (Inventario)
		If cTabela == 'SD3' .And. Empty((cAliasQRY)->D3_OP) .And. AllTrim((cAliasQRY)->D3_DOC) == 'INVENT'
			// Considerar somente Produtos Tipo 01 a 05
			If	(cAliasQRY)->B1_TIPO $ cTipo00 .Or.	 (cAliasQRY)->B1_TIPO $ cTipo01 .Or.;
				(cAliasQRY)->B1_TIPO $ cTipo02 .Or. (cAliasQRY)->B1_TIPO $ cTipo05
				dbSelectArea("SG1")
				dbSetOrder(2)
				If MsSeek(xFilial("SG1")+(cAliasQRY)->D3_COD)
				   cCodPai := SG1->G1_COD
				EndIf   
				Reclock(cAliasTRB,.T.)
				FILIAL          := xFilial('SD3')					// Campo 00 - Codigo da Filial (Nao pertence ao Layout)
				REG             := cBloco							// Campo 01 - Codigo do Bloco
				COD_ITEM        := (cAliasQRY)->D3_COD				// Campo 02 - Codigo do Produto
				UNID            := (cAliasQRY)->D3_UM				// Campo 03 - Unidade de Medida
				If Substr((cAliasQRY)->D3_CF,1,1) == 'D'
					QTD_AC_POS  := (cAliasQRY)->D3_QUANT			// Campo 04 - Quantidade de acerto Positivo
				ElseIf Substr((cAliasQRY)->D3_CF,1,1) == 'R'
					QTD_AC_NEG  :=(cAliasQRY)->D3_QUANT				// Campo 05 - Quantidade de acerto Negativo
				EndIf
				COD_INS_S       := ''								// Campo 06 - Codigo do Insumo Substituto
				COD_PAI         := cCodPai                          // Campo 07 - Codigo do Produto Pai (Quando Houver)
				TIPO            := (cAliasQRY)->B1_TIPO            // Campo 08 - Tipo do Produto (Nao pertence ao Layout)
				ALIAS           := cTabela							// Campo 09 - Alias da Tabela PROTHEUS (Nao pertence ao Layout)
				RECNOPRO        := (cAliasQRY)->RECNOSD3			// Campo 10 - Recno da Tabela PROTHEUS (Nao pertence ao Layout)
				MsUnLock()
			EndIf
		EndIf

	//谀哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪目
	//?Gravacao do Bloco I100                                   ?
	//滥哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪馁
	Case cBloco == 'I100'
		dbSelectArea(cAliasTRB)
		If cTabela == 'SD1' .And. !Empty((cAliasQRY)->D1_CC)
			If !MsSeek(xFilial("SD1")+(cAliasQRY)->D1_CC)
				RecLock(cAliasTRB,.T.)
				FILIAL   := xFilial('SD1')  													// Campo 00 - Codigo da Filial (Nao pertence ao Layout)
				REG      := cBloco																// Campo 01 - Codigo do Bloco
				DT_ALT   := dDatabase															// Campo 02 - Data da Alteracao
		    	COD_CCUS := (cAliasQRY)->D1_CC													// Campo 03 - Codigo do Centro de Custo
		    	CCUS     := Posicione("CTT",1,xFilial("CTT")+(cAliasQRY)->D1_CC,'CTT_DESC01')	// Campo 04 - Descricao do Centro de Custos
				ALIAS    := cTabela				 												// Campo 05 - Alias da Tabela PROTHEUS (Nao pertence ao Layout)
				RECNOPRO := (cAliasQRY)->RECNOSD1												// Campo 06 - Recno da Tabela PROTHEUS (Nao pertence ao Layout)
				MsUnLock()
			EndIf	
		ElseIf cTabela == 'SD2' .And. !Empty((cAliasQRY)->D2_CCUSTO)
			If !MsSeek(xFilial("SD2")+(cAliasQRY)->D2_CCUSTO)
				RecLock(cAliasTRB,.T.)
				FILIAL   := xFilial('SD2')  														// Campo 00 - Codigo da Filial (Nao pertence ao Layout)
				REG      := cBloco																	// Campo 01 - Codigo do Bloco
				DT_ALT   := dDatabase																// Campo 02 - Data da Alteracao
		    	COD_CCUS := (cAliasQRY)->D2_CCUSTO													// Campo 03 - Codigo do Centro de Custo
		    	CCUS     := Posicione("CTT",1,xFilial("CTT")+(cAliasQRY)->D2_CCUSTO,'CTT_DESC01')	// Campo 04 - Descricao do Centro de Custos
				ALIAS    := cTabela				 													// Campo 05 - Alias da Tabela PROTHEUS (Nao pertence ao Layout)
				RECNOPRO := (cAliasQRY)->RECNOSD2													// Campo 06 - Recno da Tabela PROTHEUS (Nao pertence ao Layout)
				MsUnLock()
			EndIf	
		ElseIf cTabela == 'SD3' .And. !Empty((cAliasQRY)->D3_CC)
			If !MsSeek(xFilial("SD3")+(cAliasQRY)->D3_CC)
				RecLock(cAliasTRB,.T.)
				FILIAL   := xFilial('SD3')  													// Campo 00 - Codigo da Filial (Nao pertence ao Layout)
				REG      := cBloco																// Campo 01 - Codigo do Bloco
				DT_ALT   := dDatabase															// Campo 02 - Data da Alteracao
		    	COD_CCUS := (cAliasQRY)->D3_CC													// Campo 03 - Codigo do Centro de Custo
		    	CCUS     := Posicione("CTT",1,xFilial("CTT")+(cAliasQRY)->D3_CC,'CTT_DESC01')	// Campo 04 - Descricao do Centro de Custos
				ALIAS    := cTabela				 												// Campo 05 - Alias da Tabela PROTHEUS (Nao pertence ao Layout)
				RECNOPRO := (cAliasQRY)->RECNOSD3												// Campo 06 - Recno da Tabela PROTHEUS (Nao pertence ao Layout)
				MsUnLock()
			EndIf	
		EndIf
		dbSelectArea(cAliasQRY)

	//谀哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪目
	//?Gravacao do Bloco I210                                   ?
	//滥哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪馁
	Case cBloco == 'I210'

		// Considerar somente Produtos Tipo 03 e 04
		If	(cAliasQRY)->B1_TIPO $ cTipo03 .Or.	(cAliasQRY)->B1_TIPO $ cTipo04 
			dbSelectArea(cAliasTRB)
			If cTabela == 'SD3' 
				dbSelectArea(cAliasTRB)			
				If MsSeek(xFilial("SD3")+(cAliasQRY)->D3_COD)
					// Gravacao do item
					RecLock(cAliasTRB,.F.)
					FILIAL     := xFilial('SD3')  					// Campo 00 - Codigo da Filial (Nao pertence ao Layout)
					REG        := cBloco							// Campo 01 - Codigo do Bloco
					COD_ITEM   := (cAliasQRY)->D3_COD				// Campo 02 - Codigo do Produto
					CUSTO_PROD := CUSTO_PROD+(cAliasQRY)->D3_CUSTO1// Campo 04 - Custo de Producao
				  //CUSTO_EST  -> NAO PRECISA ATUALIZAR				// Campo 05 - Custo de Estoque
					ALIAS      := cTabela				 			// Campo 06 - Alias da Tabela PROTHEUS (Nao pertence ao Layout)
					RECNOPRO   := (cAliasQRY)->RECNOSD3				// Campo 07 - Recno da Tabela PROTHEUS (Nao pertence ao Layout)
					MsUnLock()	
				Else
					// Verifica a quantidade/custo em estoque
					dbSelectArea("SB2")
					Do While !Eof() .And.  SB2->B2_FILIAL+SB2->B2_COD == xFilial("SB2")+(cAliasQRY)->D3_COD
						aSaldo:= CalcEst(SB2->B2_COD,SB2->B2_LOCAL,dDataAte+1,Nil)
						If Len(aSalAtu) == 0
							aSalAtu:=ACLONE(aSaldo)
						Else
							For nX:=1 to Len(aSalAtu)
								aSalAtu[nX] += aSaldo[nX]
							Next nX
						EndIf
						dbSkip()
					EndDo
					dbSelectArea(cAliasQRY)
					// Gravacao do item
					RecLock(cAliasTRB,.T.)
					FILIAL     := xFilial('SD3')  					// Campo 00 - Codigo da Filial (Nao pertence ao Layout)
					REG        := cBloco							// Campo 01 - Codigo do Bloco
					COD_ITEM   := (cAliasQRY)->D3_COD				// Campo 02 - Codigo do Produto
					CUSTO_PROD := (cAliasQRY)->D3_CUSTO1			// Campo 04 - Custo de Producao
					CUSTO_EST  := aSalAtu[2]						// Campo 05 - Custo de Estoque
					ALIAS      := cTabela				 			// Campo 06 - Alias da Tabela PROTHEUS (Nao pertence ao Layout)
					RECNOPRO   := (cAliasQRY)->RECNOSD3				// Campo 07 - Recno da Tabela PROTHEUS (Nao pertence ao Layout)
					MsUnLock()	
				EndIf		
				dbSelectArea(cAliasQRY)
			EndIf
	    EndIf

EndCase

Return

/*
苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北
北谀哪哪哪哪穆哪哪哪哪哪哪哪穆哪哪哪穆哪哪哪哪哪哪哪哪哪穆哪哪哪履哪哪哪哪目北
北矲un嘺o    ?RCPE_TPINF    ?Autor ?TOTVS S/A		 ?Data ?01/04/13 潮?
北媚哪哪哪哪呐哪哪哪哪哪哪哪牧哪哪哪牧哪哪哪哪哪哪哪哪哪牧哪哪哪聊哪哪哪哪拇北
北矰escricao ?RCPE MG - ARQUIVO MAGNETICO                                 潮?
北?		 | Regra para preenchimento do campo IND_OPE contido no Bloco  潮?
北?		 | H200.                                                       潮?
北媚哪哪哪哪呐哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪拇北
北砅arametros?cTabela     = Codigo da tabela de movimento em processamento潮?
北?         ?cAliasQRY   = Alias da tabela de movimentacao para analise  潮?
北?         ?              da regra do campo IND_OPE.                    潮?
北媚哪哪哪哪呐哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪拇北
北砋so       ?Arquivo Magnetico RCPE MG                              
     潮?
北滥哪哪哪哪牧哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪馁北
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北
哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌
*/
Static Function RCPE_TPINF(cTabela,cAliasQRY)
Local cIND_OPE    := ''
Local cNewIND_OPE := ''

Static lRCPEP3R1 := ExistBlock('RCPEP3R1')

Default cTabela := ''

//谀哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪目
//?Campo IND_OPE - Indicador do tipo de informacao          ?
//滥哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪馁
// E = Entrada
// S = Saida
// 0 = Estoque de propriedade do informante e em seu poder
// 1 = Estoque de propriedade do informante e em posse de terceiros
// 2 = Estoque de propriedade de terceiros e em posse do informante

Do Case
	Case cTabela == 'SD1'
		cIND_OPE := 'E'
		If (cAliasQRY)->F4_PODER3 == 'D' .And. (cAliasQRY)->D1_TIPO $ 'N|B'
			cIND_OPE := '0'
		ElseIf (cAliasQRY)->F4_PODER3 == 'R'
			cIND_OPE := '2'
		EndIf
	Case cTabela == 'SD2'
		cIND_OPE := 'S'
		If (cAliasQRY)->F4_PODER3 == 'D' .And. (cAliasQRY)->D2_TIPO $ 'N|B'
			cIND_OPE := '2'
		ElseIf (cAliasQRY)->F4_PODER3 == 'R'
			cIND_OPE := '1'
		EndIf
	Case cTabela == 'SD3'
		If SubStr((cAliasQRY)->D3_CF,1,1) == "D" .Or. (cAliasQRY)->D3_CF $ "PR1|PR0"
			cIND_OPE := 'E'
		ElseIf SubStr((cAliasQRY)->D3_CF,1,1) == "R" .And. alltrim((cAliasQRY)->D3_DOC) <> 'INVENT'   // 
			cIND_OPE := 'S'
		ElseIf SubStr((cAliasQRY)->D3_CF,1,1) == "R" .And. Alltrim((cAliasQRY)->D3_DOC) == 'INVENT'			
			cIND_OPE := '0'
		ElseIf SubStr((cAliasQRY)->D3_CF,1,1) == "D" .And. alltrim((cAliasQRY)->D3_DOC) == 'INVENT'			
			cIND_OPE := '0'			
		EndIf	
EndCase

// Ponto de entrada SPEDP3R1 - Utilizado para manipular a regra do campo IND_OPE (Bloco H200)
If lRCPEP3R1
	cNewIND_OPE := ExecBlock("RCPEP3R1",.F.,.F.,{cTabela,cAliasQRY,cIND_OPE})
	If Valtype(cNewIND_OPE) == "C" 
		cIND_OPE := cNewIND_OPE
	EndIf
EndIf
	
Return cIND_OPE
/*
苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北
北谀哪哪哪哪穆哪哪哪哪哪哪哪穆哪哪哪穆哪哪哪哪哪哪哪哪哪穆哪哪哪履哪哪哪哪目北
北矲un嘺o    ?RCPE_TPMOV    ?Autor ?TOTVS S/A		 ?Data ?01/04/13 潮?
北媚哪哪哪哪呐哪哪哪哪哪哪哪牧哪哪哪牧哪哪哪哪哪哪哪哪哪牧哪哪哪聊哪哪哪哪拇北
北矰escricao ?RCPE MG - ARQUIVO MAGNETICO                                 潮?
北?		 | Regra para preenchimento do campo TIPO_MOV contido no bloco 潮?
北?		 | H200.                                                       潮?
北媚哪哪哪哪呐哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪拇北
北砅arametros?cTabela     = Codigo da tabela de movimento em processamento潮?
北?         ?cAliasQRY   = Alias da tabela de movimentacao para analise  潮?
北?         ?              da regra do campo TIPO_MOV.                   潮?
北媚哪哪哪哪呐哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪拇北
北砋so       ?Arquivo Magnetico RCPE MG                                   潮?
北滥哪哪哪哪牧哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪馁北
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北
哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌
*/
Static Function RCPE_TPMOV(cTabela,cAliasQRY)
Local cTIPO_MOV := ''

Static lRCPEP3R2 := ExistBlock('RCPEP3R2')

Default cTabela := ''

//谀哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪目
//?T I P O S  D E  E N T R A D A  N O  E S T O Q U E        ?
//滥哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪馁
// Codigo   Descricao
// CO       Compra (SD1)
// TE       Transferencia (SD1/SD3)
// EM       Entrada de mercadoria propria estocada em Terceiro (SD1)
// ED       Entrada de mercadoria de Terceiro para ser Industrializada (SD1)
// DC       Devolucao pelo Cliente (SD1)
// PA       Producao Acabada (SD3)
// MA       Movimentacao Interna por Adicao (SD3)
// EA       Acerto Positivo de Estoque Escriturado - Correcao de erro de apontamento de producao ou consumo (SD3)
// AP       Acerto Positivo de Estoque Escriturado - Correcao de erro de Apontamento de Demais Movimentacoes (SD3)
// PS       Producao de SubProduto (SD3)
// DE       Demais Entradas de Mercadoria de Propriedade de Terceiro (SD1)
// OE       Outras Entradas de Mercadoria de Propriedade do Informante (SD1)

//谀哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪目
//?T I P O S  D E  S A I D A  N O  E S T O Q U E            ?
//滥哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪馁
// Codigo   Descricao
// VE       Venda (SD2)
// TS       Transferencia (SD2)
// SM       Saida de Mercadoria propria para estoque em terceiros (SD2)
// SF       Saida de produto industrializado para terceiros (SD2)
// DF       Devolucao ao Fornecedor (SD2)
// CS       Consumo no Estabelecimento (SD2)
// MD       Movimentacao Interna por Deducao (SD3)
// SA       Acerto Negativo de Estoque Escriturado - Correcao de erro de apontamento de producao ou consumo (SD3)
// AN       Acerto Negativo de Estoque Escriturado - Correcao de erro de apontamento de demais movimentacoes (SD3)
// DS       Demais Saidas de Mercadoria de Propriedade de Terceiros (SD2)
// OS       Outras Saidas de Mercadorias de Propriedade do Informante (SD2)

If cTabela == 'SD1'
	Do Case
		Case (cAliasQRY)->F4_TRANFIL == '1'
			cTIPO_MOV := 'TE'
		Case (cAliasQRY)->D1_TIPO == 'D'
	   		cTIPO_MOV := 'DC'
		Case (cAliasQRY)->F4_PODER3 == 'D' .And. (cAliasQRY)->D1_TIPO $ 'N|B'
			cTIPO_MOV := 'EM'
		Case (cAliasQRY)->F4_PODER3 == 'R' .And. !Empty((cAliasQRY)->D1_OP)
			cTIPO_MOV := 'ED'
		Case (cAliasQRY)->F4_PODER3 == 'R' .And.  Empty((cAliasQRY)->D1_OP)
			cTIPO_MOV := 'DE'
		Otherwise
			cTipo_MOV := 'CO'
	EndCase
ElseIf cTabela == 'SD2'
	Do Case
		Case (cAliasQRY)->F4_TRANFIL == '1'
			cTIPO_MOV := 'TS'
		Case (cAliasQRY)->D2_TIPO == 'D'
	   		cTIPO_MOV := 'DF'
		Case (cAliasQRY)->F4_PODER3 == 'D' .And. (cAliasQRY)->D2_TIPO $ 'N|B'
			cTIPO_MOV := 'SM'
		Case (cAliasQRY)->F4_PODER3 == 'R' .And. !Empty((cAliasQRY)->D1_OP)
			cTIPO_MOV := 'SF'
		Case (cAliasQRY)->F4_PODER3 == 'R' .And.  Empty((cAliasQRY)->D1_OP)
			cTIPO_MOV := 'DS'
		Otherwise
			cTipo_MOV := 'VE'
	EndCase			
ElseIf cTabela == 'SD3'
	If (cAliasQRY)->D3_CF == "RE4"
		cTIPO_MOV := 'TS'   
		If RCPE_APPERDA ((cAliasQRY)->D3_OP,(cAliasQRY)->D3_CF,(cAliasQRY)->D3_NUMSEQ,(cAliasQRY)->D3_COD)
  	      cTIPO_MOV := 'MD'
		EndIf
	ElseIf (cAliasQRY)->D3_CF == "DE4"
		cTIPO_MOV := 'TE'
		If RCPE_APPERDA ((cAliasQRY)->D3_OP,(cAliasQRY)->D3_CF,(cAliasQRY)->D3_NUMSEQ,(cAliasQRY)->D3_COD)
  	      cTIPO_MOV := 'MA'
		EndIf
	ElseIf (cAliasQRY)->D3_CF $ "PR0|PR1" .And. !Empty((cAliasQRY)->D3_OP) .And. SubStr((cAliasQRY)->D3_OP,7,2) == '01' //.And. SubStr((cAliasQRY)->D3_OP,9,3)=='001'
		cTIPO_MOV := 'PA'
	ElseIf Substr((cAliasQRY)->D3_CF,1,1) == 'D' .And. !Empty((cAliasQRY)->D3_OP)
		cTIPO_MOV := 'PS'
	ElseIf (cAliasQRY)->D3_CF == "DE0" .And. Empty((cAliasQRY)->D3_OP) .And. alltrim((cAliasQRY)->D3_DOC) <> 'INVENT'
		cTIPO_MOV := 'MA'
	ElseIf (cAliasQRY)->D3_CF == "DE0" .And. Empty((cAliasQRY)->D3_OP) .And. alltrim((cAliasQRY)->D3_DOC) == 'INVENT'
		cTIPO_MOV := 'AP'		
	ElseIf Substr((cAliasQRY)->D3_CF,1,1) == 'D'
		cTIPO_MOV := 'OE'
	ElseIf (cAliasQRY)->D3_CF == "RE0" .And. Empty((cAliasQRY)->D3_OP) .And. alltrim((cAliasQRY)->D3_DOC) <> 'INVENT'
		cTIPO_MOV := 'MD'        
	ElseIf (cAliasQRY)->D3_CF == "RE0" .And. Empty((cAliasQRY)->D3_OP) .And. alltrim((cAliasQRY)->D3_DOC) == 'INVENT'
		cTIPO_MOV := 'SA'				
	ElseIf Substr((cAliasQRY)->D3_CF,1,1) == 'R' .And. !Empty((cAliasQRY)->D3_OP)
		cTIPO_MOV := 'CS'
	ElseIf Substr((cAliasQRY)->D3_CF,1,1) == 'R'
		cTIPO_MOV := 'OS'
	EndIf	
EndIf

// Ponto de entrada SPEDP3R2 - Utilizado para manipular a regra do campo TIPO_MOV (Bloco H200)
If lRCPEP3R2
	cNewTIPO_MOV := ExecBlock("RCPEP3R2",.F.,.F.,{cTabela,cAliasQRY,cTIPO_MOV})
	If Valtype(cNewTIPO_MOV) == "C" 
		cTIPO_MOV := cNewTIPO_MOV
	EndIf
EndIf

Return cTIPO_MOV

/*
苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北
北谀哪哪哪哪穆哪哪哪哪哪哪哪哪履哪哪哪履哪哪哪哪哪哪哪哪穆哪哪哪履哪哪哪哪目北
北矲un嘺o    ?RCPE_CRIATRB   ?Autor ?TOTVS S/A		 ?Data ?01/04/13 潮?
北媚哪哪哪哪呐哪哪哪哪哪哪哪哪聊哪哪哪聊哪哪哪哪哪哪哪哪牧哪哪哪聊哪哪哪哪拇北
北矰escricao ?RCPE MG - ARQUIVO MAGNETICO                                 潮?
北?		 | Criacao do arquivo temporario para retorno de informacoes.  潮?
北媚哪哪哪哪呐哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪拇北
北砅arametros?cBloco    = Nome do Bloco para geracao arquivo de trabalho  潮?
北?         ?cAliasTRB = Nome do arquivo de trabalho                     潮?
北?         ?cChave    = Chave de Indice do Bloco                        潮?
北媚哪哪哪哪呐哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪拇北
北砋so       ?Arquivo Magnetico RCPE MG                                   潮?
北滥哪哪哪哪牧哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪馁北
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北
哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌
*/
Static Function RCPE_CRIATRB( cBloco, cAliasTRB, cChave )

Local cDirRCPE	:= GetSrvProfString("Startpath","")+"RCPE\"
Local oTempTable	:= ""
Default cAliasTRB	:= ''
Default cBloco	:= ''
Default cChave	:= 'FILIAL'

// Verifica a existencia do diretorio
If !ExistDir(cDirRCPE)
	MakeDir(cDirRCPE)
EndIf	

//谀哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪目
//?Criacao do Arquivo de Trabalho                           ?
//滥哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪馁
If !Empty(cBloco)
	cAliasTRB := UPPER(cBloco)+"_"+CriaTrab(,.F.)
		
	oTempTable := FWTemporaryTable():New( cAliasTRB )
	oTempTable:SetFields( RCPE_LAYOUT(cBloco) )
	oTempTable:AddIndex("indice1", {"FILIAL"} )
	oTempTable:Create()

EndIf	

Return


/*
苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北
北谀哪哪哪哪穆哪哪哪哪哪哪哪哪履哪哪哪履哪哪哪哪哪哪哪哪穆哪哪哪履哪哪哪哪目北
北矲un嘺o    ?RCPE_CODFASE   ?Autor ?TOTVS S/A		 ?Data ?01/04/13 潮?
北媚哪哪哪哪呐哪哪哪哪哪哪哪哪聊哪哪哪聊哪哪哪哪哪哪哪哪牧哪哪哪聊哪哪哪哪拇北
北矰escricao ?RCPE MG - ARQUIVO MAGNETICO                                 潮?
北?		 | Funcao responsavel pelo retorno do codigo da fase amarrado  潮?
北?		 | na tabela SG1/SGF (Necessita do registro posicionado SG1)   潮?
北媚哪哪哪哪呐哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪拇北
北砅arametros?                                                            潮?
北媚哪哪哪哪呐哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪拇北
北砋so       ?Arquivo Magnetico RCPE MG                                   潮?
北滥哪哪哪哪牧哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪馁北
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北
哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌
*/
Static Function RCPE_CODFASE()
Local cCodFase    := ''
Local cNewCodFase := ''
Local aAreaAnt    := GetArea()
Local aAreaSGF    := SGF->(GetArea())

Static lRCPEP3R3 := ExistBlock('RCPEP3R2')

// Procura pelo Roteiro/Operacao
if SD4->(FieldPos('D4_PRODUTO')) > 0
	SD4->(dbSetOrder(7))
	SD4->(MsSeek(xFilial("SD4")+SG1->G1_COD))
	Do While SD4->(!Eof()) .And. SD4->(D4_FILIAL)==xFilial("SD4") .And. SD4->D4_PRODUTO==SG1->G1_COD
		If SD4->D4_COD == SG1->G1_COMP
	   		cCodFase := SD4->D4_ROTEIRO //+SGF->GF_OPERAC
			Exit
		EndIf
		SGF->(dbSkip())
	EndDo
Else
	SGF->(dbSetOrder(2))
	SGF->(MsSeek(xFilial("SGF")+SG1->G1_COD))
	Do While SGF->(!Eof()) .And. SGF->(GF_FILIAL)==xFilial("SGF") .And. SGF->GF_PRODUTO==SG1->G1_COD
		If SGF->GF_COMP == SG1->G1_COMP
	   		cCodFase := SGF->GF_ROTEIRO //+SGF->GF_OPERAC
			Exit
		EndIf
		SGF->(dbSkip())
	EndDo
Endif

// Ponto de entrada SPEDP3R3 - Utilizado para manipular o codigo da fase para o registro 0210
If lRCPEP3R3
	cNewCodFase := ExecBlock("RCPEP3R3",.F.,.F.,{cCodFase,SG1->G1_COD,SG1->G1_COMP})
	If Valtype(cCodFase) == "C" 
		cCodFase := cNewCodFase
	EndIf
EndIf

RestArea(aAreaSGF)
RestArea(aAreaAnt)
Return cCodFase
/*
苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北
北谀哪哪哪哪穆哪哪哪哪哪哪哪哪履哪哪哪履哪哪哪哪哪哪哪哪穆哪哪哪履哪哪哪哪目北
北矲un嘺o    ?RCPE_LAYOUT    ?Autor ?TOTVS S/A		 ?Data ?01/04/13 潮?
北媚哪哪哪哪呐哪哪哪哪哪哪哪哪聊哪哪哪聊哪哪哪哪哪哪哪哪牧哪哪哪聊哪哪哪哪拇北
北矰escricao ?RCPE MG - ARQUIVO MAGNETICO                                 潮?
北?		 | Funcao responsavel pela montagem do layout do bloco         潮?
北媚哪哪哪哪呐哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪拇北
北砅arametros?cBloco = Nome do bloco para geracao do Layout               潮?
北媚哪哪哪哪呐哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪拇北
北砋so       ?Arquivo Magnetico RCPE MG                                   潮?
北滥哪哪哪哪牧哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪馁北
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北
哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌
*/
Static Function RCPE_LAYOUT(cBloco)

Local aCampos    := {}
Local aTamFil    := TamSX3("D1_FILIAL")
Local aTamData   := TamSX3("D1_DTDIGIT")
Local aTamCod    := TamSX3("D1_COD")
Local aTamUnit   := TamSX3("D1_VUNIT")
Local aTamQtde   := TamSX3("D1_QUANT")
Local aTamMax    := TamSX3("B1_EMAX")
Local aTamUM     := TamSX3("B1_UM")
Local aTamCC     := TamSX3("B1_CC")
Local aTamOP     := TamSX3("D3_OP")
Local aTamConv   := TamSX3("B1_CONV")
Local aTamNumSeq := TamSX3("D3_NUMSEQ")
Local aTamSaldo  := TamSX3("B2_VATU1")
Local aTamDscUM  := TamSX3("AH_DESCPO")
Local aTamDoc    := TamSX3("D1_DOC")
Local aTamSerie  := TamSX3("D1_SERIE")
Local aTamForn   := TamSX3("D1_FORNECE")
Local aTamLoja   := TamSX3("D1_LOJA")
Local nTamChave  := aTamDoc[1]+aTamSerie[1]+aTamForn[1]+aTamLoja[1]
Local aTamReg    := {4,0}

Default cBloco := ''

Do Case

	Case cBloco == '0210'
		//谀哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪目
		//?Criacao do Arquivo de Trabalho - BLOCO 0210              ?
		//滥哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪馁
    	aCampos := {}
		AADD(aCampos,{"FILIAL"		,"C",aTamFil[1]		,0})
		AADD(aCampos,{"REG"			,"C",aTamReg[1]		,0})
		AADD(aCampos,{"COD_ITEM"	,"C",aTamCod[1]		,0})
		AADD(aCampos,{"UNID_ITEM"	,"C",aTamUM[1]		,0})
		AADD(aCampos,{"COD_I_COMP"	,"C",aTamCod[1]		,0})
		AADD(aCampos,{"QTD_C_MIN"	,"N",aTamQtde[1]	,aTamQtde[2]})
		AADD(aCampos,{"QTD_C_MAX"	,"N",aTamQtde[1]	,aTamQtde[2]})
		AADD(aCampos,{"UNID_COMP"	,"C",aTamUM[1]		,0})
		AADD(aCampos,{"COD_FASE"	,"C",60				,0})
		AADD(aCampos,{"TIPO"		,"C",2				,0})
		AADD(aCampos,{"ALIAS"		,"C",3				,0})
		AADD(aCampos,{"RECNOPRO"	,"N",14				,0})

	Case cBloco == '0250'
		//谀哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪目
		//?Criacao do Arquivo de Trabalho - BLOCO 0250              ?
		//滥哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪馁
    	aCampos := {}
		AADD(aCampos,{"FILIAL"		,"C",aTamFil[1]		,0})
		AADD(aCampos,{"REG"			,"C",aTamReg[1]		,0})
		AADD(aCampos,{"UNID"		,"C",aTamUM[1]		,0})
		AADD(aCampos,{"DESCR"		,"C",aTamDscUM[1]	,0})
		AADD(aCampos,{"TIPO_UNI"	,"C",1				,0})
		AADD(aCampos,{"ALIAS"		,"C",3				,0})
		AADD(aCampos,{"RECNOPRO"	,"N",14				,0})

	Case cBloco == 'H200'
		//谀哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪目
		//?Criacao do Arquivo de Trabalho - BLOCO H200              ?
		//滥哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪馁
    	aCampos := {}
		AADD(aCampos,{"FILIAL"		,"C",aTamFil[1]		,0})
		AADD(aCampos,{"REG"			,"C",aTamReg[1]		,0})
		AADD(aCampos,{"DT_MOV"		,"D",aTamData[1]	,0})
		AADD(aCampos,{"COD_ITEM"	,"C",aTamCod[1]		,0})
		AADD(aCampos,{"VL_UNIT"		,"N",aTamUnit[1]	,aTamUnit[2]})
		AADD(aCampos,{"QTD"			,"N",aTamQtde[1]	,aTamQtde[2]})
		AADD(aCampos,{"UNID"		,"C",aTamUM[1]		,0})
		AADD(aCampos,{"IND_OPE"		,"C",1				,0})
		AADD(aCampos,{"TIPO_MOV"	,"C",2				,0})
		AADD(aCampos,{"IND_DOC_OP"	,"C",1				,0})
		AADD(aCampos,{"COD_CCUS"	,"C",aTamCC[1]		,0})
		AADD(aCampos,{"FINALID"		,"C",255			,0})
		AADD(aCampos,{"CAPAC_ARMZ"	,"N",aTamMax[1]		,aTamMax[2]})
		AADD(aCampos,{"TIPO"		,"C",2				,0})
		AADD(aCampos,{"ALIAS"		,"C",3				,0})
		AADD(aCampos,{"RECNOPRO"	,"N",14				,0})
	Case cBloco == 'H220'		
		//谀哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪目
		//?Criacao do Arquivo de Trabalho - BLOCO H220              ?
		//滥哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪馁
		aCampos := {}
		AADD(aCampos,{"FILIAL"		,"C",aTamFil[1]		,0})
		AADD(aCampos,{"REG"			,"C",aTamReg[1]		,0})
		AADD(aCampos,{"DT_MOV"		,"D",aTamData[1]	,0})
		AADD(aCampos,{"COD_ITEM_O"	,"C",aTamCod[1]		,0})
		AADD(aCampos,{"UNID_ORI"	,"C",aTamUM[1]		,0})
		AADD(aCampos,{"COD_ITEM_D"	,"C",aTamCod[1]		,0})
		AADD(aCampos,{"UNID_DES"	,"C",aTamUM[1]		,0})
		AADD(aCampos,{"QTD"			,"N",aTamQtde[1]	,aTamQtde[2]})
		AADD(aCampos,{"NUMSEQ"		,"C",aTamNumSeq[1]	,0})
		AADD(aCampos,{"ALIAS"		,"C",3				,0})
		AADD(aCampos,{"RECNOPRO"	,"N",14				,0})
		
	Case cBloco == 'H230'
		//谀哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪目
		//?Criacao do Arquivo de Trabalho - BLOCO H230              ?
		//滥哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪馁
		aCampos := {}
		AADD(aCampos,{"FILIAL"		,"C",aTamFil[1]		,aTamFil[2]})
		AADD(aCampos,{"REG"			,"C",aTamReg[1]		,0})
		AADD(aCampos,{"DT_INI_OP"	,"D",aTamData[1]	,0})
		AADD(aCampos,{"DT_FIN_OP"	,"D",aTamData[1]	,0})
		AADD(aCampos,{"COD_DOC_OP"	,"C",aTamOP[1]		,0})
		AADD(aCampos,{"COD_ITEM"	,"C",aTamCod[1]		,0})
		AADD(aCampos,{"UNID"		,"C",aTamUM[1]		,0})
		AADD(aCampos,{"QTD_ENC"		,"N",aTamQtde[1]	,aTamQtde[2]})
		AADD(aCampos,{"COD_FASE"	,"C",60				,0})
		AADD(aCampos,{"ALIAS"		,"C",3				,0})
		AADD(aCampos,{"RECNOPRO"	,"N",14				,0})

	Case cBloco == 'H235'		
		//谀哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪目
		//?Criacao do Arquivo de Trabalho - BLOCO H235              ?
		//滥哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪馁
		aCampos := {}
		AADD(aCampos,{"FILIAL"		,"C",aTamFil[1]		,0})
		AADD(aCampos,{"REG"			,"C",aTamReg[1]		,0})
		AADD(aCampos,{"DT_SAIDA"	,"D",aTamData[1]	,0})
		AADD(aCampos,{"COD_ITEM"	,"C",aTamCod[1]		,0})
		AADD(aCampos,{"QTD"			,"N",aTamQtde[1]	,aTamQtde[2]})
		AADD(aCampos,{"UNID"		,"C",aTamUM[1]		,0})
		AADD(aCampos,{"COD_INS_SU"	,"C",aTamCod[1]		,0})
		AADD(aCampos,{"COD_DOC_OP"	,"C",aTamOP[1]		,0})
		AADD(aCampos,{"ALIAS"		,"C",3				,0})
		AADD(aCampos,{"RECNOPRO"	,"N",14				,0})

	Case cBloco == 'H250'
		//谀哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪目
		//?Criacao do Arquivo de Trabalho - BLOCO H250              ?
		//滥哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪馁
		aCampos := {}
		AADD(aCampos,{"FILIAL"		,"C",aTamFil[1]		,0})
		AADD(aCampos,{"REG"			,"C",aTamReg[1]		,0})
		AADD(aCampos,{"DT_PROD"		,"D",aTamData[1]	,0})
		AADD(aCampos,{"COD_ITEM"	,"C",aTamCod[1]		,0})
		AADD(aCampos,{"QTD"			,"N",aTamQtde[1]	,aTamQtde[2]})
		AADD(aCampos,{"UNID"		,"C",aTamUM[1]		,0})
		AADD(aCampos,{"COD_FASE"	,"C",60				,0})
		AADD(aCampos,{"CHAVE"		,"C",nTamChave		,0})
		AADD(aCampos,{"ALIAS"		,"C",3				,0})
		AADD(aCampos,{"RECNOPRO"	,"N",14				,0})
		
	Case cBloco == 'H255'
		//谀哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪目
		//?Criacao do Arquivo de Trabalho - BLOCO H255              ?
		//滥哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪馁
		aCampos := {}
		AADD(aCampos,{"FILIAL"		,"C",aTamFil[1]		,0})
		AADD(aCampos,{"REG"			,"C",aTamReg[1]		,0})
		AADD(aCampos,{"DT_CONS"		,"D",aTamData[1]	,0})
		AADD(aCampos,{"COD_ITEM"	,"C",aTamCod[1]		,0})
		AADD(aCampos,{"QTD"			,"N",aTamQtde[1]	,aTamQtde[2]})
		AADD(aCampos,{"UNID"		,"C",aTamUM[1]		,0})
		AADD(aCampos,{"COD_INS_SU"	,"C",aTamCod[1]		,0})
		AADD(aCampos,{"CHAVE"		,"C",nTamChave		,0})
		AADD(aCampos,{"ALIAS"		,"C",3				,0})
		AADD(aCampos,{"RECNOPRO"	,"N",14				,0})

	Case cBloco == 'H260'
		//谀哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪目
		//?Criacao do Arquivo de Trabalho - BLOCO H260              ?
		//滥哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪馁
		aCampos := {}
		AADD(aCampos,{"FILIAL"		,"C",aTamFil[1]		,0})
		AADD(aCampos,{"REG"			,"C",aTamReg[1]		,0})
		AADD(aCampos,{"COD_FASE"	,"C",20				,0})
		AADD(aCampos,{"DESCR_FASE"	,"C",250			,0})
		AADD(aCampos,{"ORD_FASE"	,"N",4				,0})
		AADD(aCampos,{"CAPAC_PROD"	,"N",17				,3})
		AADD(aCampos,{"UNID_CAPAC"	,"C",aTamUM[1]		,0})
		AADD(aCampos,{"COD_ITEM"	,"C",aTamCod[1]		,0})
		AADD(aCampos,{"ALIAS"		,"C",3				,0})
		AADD(aCampos,{"RECNOPRO"	,"N",14				,0})

	Case cBloco == 'H265'
		//谀哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪目
		//?Criacao do Arquivo de Trabalho - BLOCO H265              ?
		//滥哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪馁
		aCampos := {}
		AADD(aCampos,{"FILIAL"		,"C",aTamFil[1]		,0})
		AADD(aCampos,{"REG"			,"C",aTamReg[1]		,0})
		AADD(aCampos,{"COD_ITEM"	,"C",aTamCod[1]		,0})
		AADD(aCampos,{"UNID_ITEM"	,"C",aTamUM[1]		,0})
		AADD(aCampos,{"IND_CONV"	,"N",aTamConv[1]	,aTamConv[2]})
		AADD(aCampos,{"ALIAS"		,"C",3				,0})
		AADD(aCampos,{"RECNOPRO"	,"N",14				,0})
		
	Case cBloco == 'H270'
		//谀哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪目
		//?Criacao do Arquivo de Trabalho - BLOCO H270              ?
		//滥哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪馁
		aCampos := {}
		AADD(aCampos,{"FILIAL"		,"C",aTamFil[1]		,0})
		AADD(aCampos,{"REG"			,"C",aTamReg[1]		,0})
		AADD(aCampos,{"DT_INI"		,"D",aTamData[1]	,0})
		AADD(aCampos,{"DT_FIN"		,"D",aTamData[1]	,0})
		AADD(aCampos,{"COD_DOC_OP"	,"C",aTamOP[1]		,0})
		AADD(aCampos,{"COD_ITEM"	,"C",aTamCod[1]		,0})
		AADD(aCampos,{"UNID"		,"C",aTamUM[1]		,0})
		AADD(aCampos,{"QTD_AC_POS"	,"N",aTamQtde[1]	,aTamQtde[2]})
		AADD(aCampos,{"QTD_AC_NEG"	,"N",aTamQtde[1]	,aTamQtde[2]})
		AADD(aCampos,{"COD_FASE"	,"C",60				,0})
		AADD(aCampos,{"TIPO"		,"C",2				,0})
		AADD(aCampos,{"ALIAS"		,"C",3				,0})
		AADD(aCampos,{"RECNOPRO"	,"N",14				,0})

	Case cBloco == 'H275'
		//谀哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪目
		//?Criacao do Arquivo de Trabalho - BLOCO H275              ?
		//滥哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪馁
		aCampos := {}
		AADD(aCampos,{"FILIAL"		,"C",aTamFil[1]		,0})
		AADD(aCampos,{"REG"			,"C",aTamReg[1]		,0})
		AADD(aCampos,{"COD_ITEM"	,"C",aTamCod[1]		,0})
		AADD(aCampos,{"UNID"		,"C",aTamUM[1]		,0})
		AADD(aCampos,{"QTD_AC_POS"	,"N",aTamQtde[1]	,aTamQtde[2]})
		AADD(aCampos,{"QTD_AC_NEG"	,"N",aTamQtde[1]	,aTamQtde[2]})
		AADD(aCampos,{"COD_INS_S"	,"C",aTamCod[1]		,0})
		AADD(aCampos,{"COD_PAI"		,"C",aTamCod[1]		,0})
		AADD(aCampos,{"TIPO"		,"C",2				,0})
		AADD(aCampos,{"ALIAS"		,"C",3				,0})
		AADD(aCampos,{"RECNOPRO"	,"N",14				,0})

	Case cBloco == 'I100'
		//谀哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪目
		//?Criacao do Arquivo de Trabalho - BLOCO I100              ?
		//滥哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪馁
		aCampos := {}
		AADD(aCampos,{"FILIAL"		,"C",aTamFil[1]		,0})
		AADD(aCampos,{"REG"			,"C",aTamReg[1]		,0})
		AADD(aCampos,{"DT_ALT"		,"D",aTamData[1]	,0})
		AADD(aCampos,{"COD_CCUS"	,"C",aTamCC[1]		,0})
		AADD(aCampos,{"CCUS"		,"C",250			,0})
		AADD(aCampos,{"ALIAS"		,"C",3				,0})
		AADD(aCampos,{"RECNOPRO"	,"N",14				,0})

	Case cBloco == 'I210'
		//谀哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪目
		//?Criacao do Arquivo de Trabalho - BLOCO I210              ?
		//滥哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪馁
		aCampos := {}
		AADD(aCampos,{"FILIAL"		,"C",aTamFil[1]		,0})
		AADD(aCampos,{"REG"			,"C",aTamReg[1]		,0})
		AADD(aCampos,{"COD_ITEM"	,"C",aTamCod[1]		,0})
		AADD(aCampos,{"CUSTO_PROD"	,"N",aTamSaldo[1]	,aTamSaldo[2]})
		AADD(aCampos,{"CUSTO_EST"	,"N",aTamSaldo[1]	,aTamSaldo[2]})
		AADD(aCampos,{"ALIAS"		,"C",3				,0})
		AADD(aCampos,{"RECNOPRO"	,"N",14				,0})

EndCase
		
Return aCampos
                   
/*
苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北
北谀哪哪哪哪穆哪哪哪哪哪哪哪哪履哪哪哪履哪哪哪哪哪哪哪哪穆哪哪哪履哪哪哪哪目北
北矲un嘺o    ?RCPE_APPERDA   ?Autor ?TOTVS S/A		 ?Data ?08/10/13 潮?
北媚哪哪哪哪呐哪哪哪哪哪哪哪哪聊哪哪哪聊哪哪哪哪哪哪哪哪牧哪哪哪聊哪哪哪哪拇北
北矰escricao ?RCPE MG - ARQUIVO MAGNETICO                                 潮?
北?		 | Funcao Verifica se o movimento SD3 ?de apontamento de perda潮?
北媚哪哪哪哪呐哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪拇北
北砅arametros?                                                            潮?
北媚哪哪哪哪呐哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪拇北
北砋so       ?Arquivo Magnetico RCPE MG                                   潮?
北滥哪哪哪哪牧哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪馁北
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北
哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌
*/
Static Function RCPE_APPERDA(nCodOP, cTpMov, nNumSEQ, cCodProd)
Local aAreaAnt    := GetArea()
Local lret		  := .F.

BeginSQL Alias "SBCTMP"
	SELECT BC_OP 
		FROM  %Table:SBC% SBC 
		WHERE SBC.BC_SEQSD3 = %EXP:nNumSEQ% AND SBC.%NotDel%  		  
	EndSQL
	While SBCTMP->(!Eof())  
      Lret := .T.
      SBCTMP->(Dbskip())
	Enddo
	SBCTMP->(Dbclosearea()) 

RestArea(aAreaAnt)

If Empty(nCodOP) .And.  cTpMov $ "RE4|DE4"
	If  cTpMov $ "RE4"
		If SD3->(MsSeek(xFilial('SD3')+nNumSEQ+'E9'))
			If SD3->D3_COD <> cCodProd
				lret := .T.
			EndIf
		EndIf	
	ElseIf  cTpMov $ "DE4" 
		If SD3->(MsSeek(xFilial('SD3')+nNumSEQ+'E0'))
			If SD3->D3_COD <> cCodProd
				lret := .T.
			EndIf
		EndIf	
	EndIf
EndIf
Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} SIGACUS_V
Verifica a data da 鷏tima altera玢o do SIGACUS (DEVER?SER RETIRADA AP覵 A DIVIS肙 DESTE FONTE ENTRE OS M覦ULOS)

@author jose.eulalio
@since 08/05/2014
@version P12
@return nRet
/*/
//-------------------------------------------------------------------
Function SIGACUS_V
Local nRet := 20140508 
Return nRet 
/*
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北?
北谀哪哪哪哪穆哪哪哪哪哪哪履哪哪哪履哪哪哪哪哪哪哪哪哪哪履哪哪穆哪哪哪哪哪勘?
北矲un嘺o	 砇astroToNF  ?Autor ?TOTVS S/A   	    ?Data ?10/11/14 潮?
北媚哪哪哪哪呐哪哪哪哪哪哪聊哪哪哪聊哪哪哪哪哪哪哪哪哪哪聊哪哪牧哪哪哪哪哪幢?
北矰escri噮o ?Rastreamento dos documentos de entrada atraves Lote/SubLote潮?
北媚哪哪哪哪呐哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪幢?
北砋so		 ?GENERICO													  潮?
北媚哪哪哪哪呐哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪幢?
北砅arametros?cLoteCtl - Codigo do Lote                                  潮?
北?         ?cSubLote - Codigo do SubLote                               潮?
北?         ?cProdut  - Codigo do Produto                               潮?
北?         ?cLocal   - Codigo do Armazem                               潮?
北?         ?nRecOrig - USO INTERNO                                     潮?
北?         ?cUltSeq  - USO INTERNO                                     潮?
北滥哪哪哪哪牧哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪俦?
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北?
哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌?
*/
Function RastroToNF(cLoteCtl,cSubLote,cProdut,cLocal,nRecOrig,cUltSeq)

Local aArea    := GetArea()
Local aAreaSD5 := SD5->(GetArea())
Local aRetorno := {}
Private aRecur := {}
Private lRecur := .F.

aRetorno := RastrToNF2(cLoteCtl,cSubLote,cProdut,cLocal,nRecOrig,cUltSeq)

RestArea(aAreaSD5)
RestArea(aArea)

Return aRetorno
/*
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北?
北谀哪哪哪哪穆哪哪哪哪哪哪履哪哪哪履哪哪哪哪哪哪哪哪哪哪履哪哪穆哪哪哪哪哪勘?
北矲un嘺o	 砇astrToNF2 ?Autor ?TOTVS S/A   	    ?Data ?10/11/14 潮?
北媚哪哪哪哪呐哪哪哪哪哪哪聊哪哪哪聊哪哪哪哪哪哪哪哪哪哪聊哪哪牧哪哪哪哪哪幢?
北矰escri噮o ?Rastreamento dos documentos de entrada atraves Lote/SubLote潮?
北媚哪哪哪哪呐哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪幢?
北砋so		 ?GENERICO													  潮?
北媚哪哪哪哪呐哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪幢?
北砅arametros?cLoteCtl - Codigo do Lote                                  潮?
北?         ?cSubLote - Codigo do SubLote                               潮?
北?         ?cProdut  - Codigo do Produto                               潮?
北?         ?cLocal   - Codigo do Armazem                               潮?
北?         ?nRecOrig - USO INTERNO                                     潮?
北?         ?cUltSeq  - USO INTERNO                                     潮?
北滥哪哪哪哪牧哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪俦?
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北?
哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌?
*/
Static Function RastrToNF2(cLoteCtl,cSubLote,cProdut,cLocal,nRecOrig,cUltSeq)
Local aArea    := GetArea()
Local aAreaSD5 := SD5->(GetArea())
Local aRetorno := {}
Local aLoteRE4 := {}
Local cTmSD3   := ""
Local cQuery   := ""
Local cCliFor  := ""
Local cCompara := ""
Local cAliasSD5:= "SD5"
Local cCampos  := "D5_FILIAL+D5_PRODUTO+D5_LOCAL+D5_LOTECTL"
Local lRastro  := Rastro(cProdut)
Local lSubLote := Rastro(cProdut,"S")
Local nX       := 0
Local nPos     := 0
Local lQuery   := .F.

Default cUltSeq  := ""
Default cLoteCtl := ""
Default cSubLote := ""

If Ascan(aRecur,{|x| x == cProdut+cLoteCtl+cSubLote+cLocal}) > 0
	ConOut(STR0080+Alltrim(cProdut)+STR0081+Alltrim(cLoteCtl)+Alltrim(cSubLote)+STR0082+Alltrim(cLocal)+STR0083)//"RastrToNF2 - Existe recursividade no produto '"##"', lote/sublote '"##"' no armaz閙 '"##"'. As informa珲es para este item ser鉶 ignoradas."
	lRecur := .T.
Else
	AADD(aRecur,cProdut+cLoteCtl+cSubLote+cLocal)
EndIf

If !lRecur .And. !Empty(cProdut) .And. (lRastro .Or. lSubLote)
	//谀哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪?
	//?Recupera as notas de entrada de composicao do saldo do lote                   ?
	//| aRetorno - Array contendo os itens da nota de entrada                         |
	//| aRetorno[nX,01] - Numero Documento     (D1_DOC)                               |
	//| aRetorno[nX,02] - Numero de Serie      (D1_SERIE)                             |
	//| aRetorno[nX,03] - Codigo do Fornecedor (D1_FORNECE)                           |
	//| aRetorno[nX,04] - Codigo da Loja       (D1_LOJA)                              |
	//| aRetorno[nx,05] - Codigo do Item da NF (D1_ITEM)                              |
	//| aRetorno[nX,06] - Codigo do Produto    (D1_COD)                               |
	//| aRetorno[nX,07] - Codigo do Armazem    (D1_LOCAL)                             |
	//| aRetorno[nX,08] - Codigo do Lote       (D1_LOTECTL)                           |
	//| aRetorno[nX,09] - Codigo do SubLote    (D1_NUMLOTE)                           |
	//| aRetorno[nX,10] - Numero Sequencial do item da NF (D1_NUMSEQ)                 |
	//滥哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪?
	dbSelectArea("SD5")
	dbSetOrder(2)
	#IFDEF TOP
		cAliasSD5 := GetNextAlias()
		cCliFor   := Space(Len(SD5->D5_CLIFOR))
		If Select(cAliasSD5) > 0 
			dbSelectArea(cAliasSD5)
			dbCloseArea()
		EndIf
		lQuery := .T.
		cQuery := " SELECT D5_FILIAL,  D5_PRODUTO, "
		cQuery +=        " D5_LOCAL,   D5_LOTECTL, "
		cQuery +=        " D5_NUMLOTE, D5_NUMSEQ,  "
		cQuery +=        " D5_CLIFOR,  D5_LOJA,    "
		cQuery +=        " D5_ORIGLAN, D5_DOC,     "
		cQuery +=        " D5_SERIE,   "
		cQuery +=        " SD5.R_E_C_N_O_ RECNOSD5 "
		cQuery += " FROM " +RetSqlName('SD5') + ' SD5 '
		cQuery += " WHERE "
		cQuery +=         " SD5.D5_FILIAL  = '"+xFilial("SD5")+"'"
		cQuery +=     " AND SD5.D5_PRODUTO = '"+cProdut+"'"
		cQuery +=     " AND SD5.D5_LOCAL   = '"+cLocal+"'"
		If !Empty(cLoteCtl)
			cQuery += " AND SD5.D5_LOTECTL = '"+cLoteCtl+"'"
		EndIf
		If !Empty(cSubLote).And. lSubLote
			cQuery += " AND SD5.D5_NUMLOTE = '"+cSubLote+"'"
		EndIf	
		cQuery +=     " AND SD5.D5_ESTORNO  = ' '"
		cQuery +=     " AND SD5.D5_ORIGLAN <> 'MAN'"
		cQuery +=     " AND SD5.D5_ORIGLAN <= '500'"
		cQuery +=     " AND SD5.D5_CLIFOR  <> '"+cCliFor+"' "
		cQuery +=     " AND SD5.D_E_L_E_T_  = ' '"
		cQuery += " ORDER BY "+SqlOrder(SD5->(IndexKey()))
		cQuery := ChangeQuery(cQuery)
		dbUseArea(.T.,'TOPCONN',TCGENQRY(,,cQuery),cAliasSD5,.F.,.T.)
		dbSelectArea(cAliasSD5)

	#ELSE
	
		If lSubLote .And. !Empty(cSubLote)
			cCampos +="+D5_NUMLOTE"
			cCompara+=cSubLote
		EndIf
	
		cCompara := xFilial('SD5')+cProdut+cLocal+cLoteCtl
	
	#ENDIF
	
	Do While !Eof() .And. (lQuery .Or. cCompara == &cCampos)
		//-- Impede o Processamento de Movimentacoes Estornadas
		If !lQuery .And. !Empty((cAliasSD5)->D5_ESTORNO)
			dbSkip()
			Loop
		EndIf
	
		// Entrada de Material
		dbSelectArea("SD1")
		dbSetOrder(5)
		// Nota fiscal de Entrada
		If MsSeek(xFilial("SD1")+(cAliasSD5)->D5_PRODUTO+(cAliasSD5)->D5_LOCAL+(cAliasSD5)->D5_NUMSEQ )
			aAdd(aRetorno,{SD1->D1_DOC,SD1->D1_SERIE,SD1->D1_FORNECE,SD1->D1_LOJA,SD1->D1_ITEM,SD1->D1_COD,SD1->D1_LOCAL,SD1->D1_LOTECTL,SD1->D1_NUMLOTE,SD1->D1_NUMSEQ})
		EndIf
		dbSelectArea(cAliasSD5)
		dbSkip()
	EndDo
	
	// Encerra area de trabalho temporaria
	If lQuery
	   (cAliasSD5)->(dbCloseArea())
	EndIf

	// Caso nao tenha documento de entrada procurar por transferencia de lotes (RE4/DE4)
	If Empty(aRetorno)
		dbSelectArea("SD5")
		dbSetOrder(2)
		#IFDEF TOP
			cAliasSD5 := GetNextAlias()
			If Select(cAliasSD5) > 0 
				dbSelectArea(cAliasSD5)
				dbCloseArea()
			EndIf
			lQuery := .T.
			cQuery := " SELECT D5_FILIAL,  D5_PRODUTO, "
			cQuery +=        " D5_LOCAL,   D5_LOTECTL, "
			cQuery +=        " D5_NUMLOTE, D5_NUMSEQ,  "
			cQuery +=        " D5_CLIFOR,  D5_LOJA,    "
			cQuery +=        " D5_ORIGLAN, D5_DOC,     "
			cQuery +=        " D5_SERIE,   "
			cQuery +=        " SD5.R_E_C_N_O_ RECNOSD5 "
			cQuery += " FROM " +RetSqlName('SD5') + ' SD5 '
			cQuery += " WHERE "
			cQuery +=         " SD5.D5_FILIAL  = '"+xFilial("SD5")+"'"
			cQuery +=     " AND SD5.D5_PRODUTO = '"+cProdut+"'"
			cQuery +=     " AND SD5.D5_LOCAL   = '"+cLocal+"'"
			If !Empty(cLoteCtl)
				cQuery += " AND SD5.D5_LOTECTL = '"+cLoteCtl+"'"
			EndIf
			If !Empty(cSubLote).And. lSubLote
				cQuery += " AND SD5.D5_NUMLOTE = '"+cSubLote+"'"
			EndIf	
			cQuery +=     " AND SD5.D5_ESTORNO = ' '"
			cQuery +=     " AND SD5.D5_ORIGLAN = '499'" //Devolucao interna transferencia
			cQuery +=     " AND SD5.D_E_L_E_T_ = ' '"
			cQuery += " ORDER BY "+SqlOrder(SD5->(IndexKey()))
			cQuery := ChangeQuery(cQuery)
			dbUseArea(.T.,'TOPCONN',TCGENQRY(,,cQuery),cAliasSD5,.F.,.T.)
			dbSelectArea(cAliasSD5)
		
		#ELSE
		
			If lSubLote .And. !Empty(cSubLote)
				cCampos +="+D5_NUMLOTE"
				cCompara+=cSubLote
			EndIf
		
			cCompara := xFilial('SD5')+cProdut+cLocal+cLoteCtl
		
		#ENDIF
		
		Do While !Eof() .And. (lQuery .Or. cCompara == &cCampos)
			cTmSD3  := ""

			// Verifica procedencia do registro para evitar loop eterno
			If (nRecorig != Nil .And. IIf(lQuery,(cAliasSD5)->RECNOSD5 == nRecOrig,(Recno() == nRecOrig)) )
				dbSkip()
				Loop
			EndIf
		
			//-- Impede o Processamento de Movimentacoes Estornadas
			If !lQuery .And. !Empty((cAliasSD5)->D5_ESTORNO)
				dbSkip()
				Loop
			EndIf
			
			//-- Impede voltar para um numero sequencial anterior
			If !Empty(cUltSeq) .And. (cAliasSD5)->D5_NUMSEQ <= cUltSeq
				dbSkip()
				Loop
			EndIf   

			// Recupera registro de Origem de trasferencia
			dbSelectArea(cAliasSD5)
			cTmSD3:=AC040TM((cAliasSD5)->D5_NUMSEQ,(cAliasSD5)->D5_ORIGLAN)
			If cTmSD3 == "DE4"
				aLoteRE4 := BuscaLoteRE4((cAliasSD5)->D5_NUMSEQ,IIf(lQuery,(cAliasSD5)->RECNOSD5,Recno()))
				If !Empty(aLoteRE4)
					//谀哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪目
					//矯hamada recursiva da funcao RastroToNF para encontrar a nota de origem.     |
					//砤LoteRE4 - Array que contem os lotes de origem do processo de transferencia.|
					//砤LoteRE4[1] - Codigo do Lote                                                |
					//砤LoteRE4[2] - Codigo do SubLote                                             |
					//砤LoteRE4[3] - Codigo do Produto                                             |
					//砤LoteRE4[4] - Codigo do Armazem                                             |
					//砤LoteRE4[5] - Numero Sequencial                                             |
					//滥哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪馁
					aRetRE4 := RastrToNF2(aLoteRE4[1],aLoteRE4[2],aLoteRE4[3],aLoteRE4[4],IIf(lQuery,(cAliasSD5)->RECNOSD5,Recno()),aLoteRE4[5])
					// Se estiver recursivo aborta o processamento
					If lRecur
						Exit
					EndIf
					//Alimenta o array aRetorno com o resultado da recursividade
					For nX := 1 to Len(aRetRE4)
						//谀哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪?
						//| aRetorno - Array contendo os itens da nota de entrada                         |
						//| aRetorno[nX,01] - Numero Documento     (D1_DOC)                               |
						//| aRetorno[nX,02] - Numero de Serie      (D1_SERIE)                             |
						//| aRetorno[nX,03] - Codigo do Fornecedor (D1_FORNECE)                           |
						//| aRetorno[nX,04] - Codigo da Loja       (D1_LOJA)                              |
						//| aRetorno[nx,05] - Codigo do Item da NF (D1_ITEM)                              |
						//| aRetorno[nX,06] - Codigo do Produto    (D1_COD)                               |
						//| aRetorno[nX,07] - Codigo do Armazem    (D1_LOCAL)                             |
						//| aRetorno[nX,08] - Codigo do Lote       (D1_LOTECTL)                           |
						//| aRetorno[nX,09] - Codigo do SubLote    (D1_NUMLOTE)                           |
						//| aRetorno[nX,10] - Numero Sequencial do item da NF (D1_NUMSEQ)                 |
						//滥哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪?
						nPos := aScan(aRetorno,{|x| x[1]+x[2]+x[3]+x[4]+x[5]==aRetRE4[nX,1]+aRetRE4[nX,2]+aRetRE4[nX,3]+aRetRE4[nX,4]+aRetRE4[nX,5]})
						If nPos == 0
							aAdd(aRetorno,aRetRE4[nX])
						EndIf	
					Next nX
				EndIf
			EndIf       
			dbSelectArea(cAliasSD5)
			dbSkip()
		EndDo
		
		// Encerra area de trabalho temporaria
		If lQuery
		   (cAliasSD5)->(dbCloseArea())
		EndIf
	EndIf
EndIf

If !lRecur
	ADel(aRecur,len(aRecur))
	ASize(aRecur,len(aRecur)-1)
EndIf  

RestArea(aAreaSD5)
RestArea(aArea)
Return aRetorno

/*
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北?
北谀哪哪哪哪穆哪哪哪哪哪哪穆哪哪哪穆哪哪哪哪哪哪哪哪哪哪履哪哪穆哪哪哪哪哪勘?
北矲un噮o	 矪uscaLoteRE4 ?Autor ?TOTVS S/A   		?Data ?18/11/14 潮?
北媚哪哪哪哪呐哪哪哪哪哪哪牧哪哪哪牧哪哪哪哪哪哪哪哪哪哪聊哪哪牧哪哪哪哪哪幢?
北矰escri噮o 砅esquisa o Lote de Origem - Movimento RE4					  潮?
北媚哪哪哪哪呐哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪幢?
北?Uso		 ?RastroToNF												  潮?
北媚哪哪哪哪呐哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪幢?
北砅arametros?cNumSeq - Codigo Sequencial (D3_NUMSEQ/D5_NUMSEQ)          潮?
北?         ?nRecno  - Numero do Registro da tabela SD5 posicionada     潮?
北滥哪哪哪哪牧哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪俦?
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北?
哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌?
*/
Static Function BuscaLoteRE4(cNumSeq,nRecno)
Local aAreaAnt:= GetArea()
Local aRetorno:= {}
Local cFilSD5 := xFilial("SD5")

Default cNumSeq := ""
Default nRecno  := 0

dbSelectArea("SD5")
dbSetOrder(3)
dbSeek(xFilial("SD5")+cNumSeq)
While !Eof() .And. cFilSD5+cNumSeq == D5_FILIAL+D5_NUMSEQ
	//-- Impede o Processamento de Movimentacoes Estornadas
	If !Empty(SD5->D5_ESTORNO)
		dbSkip()
		Loop
	EndIf
	If Recno() != nRecno
		aRetorno:={SD5->D5_LOTECTL,SD5->D5_NUMLOTE,SD5->D5_PRODUTO,SD5->D5_LOCAL,SD5->D5_NUMSEQ}
		Exit
	EndIf
	dbSkip()
End
RestArea(aAreaAnt)
Return (aRetorno)

/*苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘?
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北?
北谀哪哪哪哪哪穆哪哪哪哪哪穆哪哪哪穆哪哪哪哪哪哪哪哪哪哪哪履哪哪穆哪哪哪哪哪勘?
北?Funcao     ?MATPrcPrd ?Autor ?Materiais            ?Data ?06/11/14 潮?
北媚哪哪哪哪哪呐哪哪哪哪哪牧哪哪哪牧哪哪哪哪哪哪哪哪哪哪哪聊哪哪牧哪哪哪哪哪幢?
北?Descricao  ?Funcao Principal de Processamento de Producoes             潮?
北媚哪哪哪哪哪呐哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪幢?
北?Parametros ?ExpC1: cMes     - Mes a processar                          潮?
北?           ?ExpC2: cAno     - Ano a processar                          潮?
北?           ?ExpC3: cProdDe  - Do Produto                               潮?
北?           ?ExpC4: cProdAte - Ate o produto                            潮?
北?           ?ExpC5: cFisLeg  - Legislacao Processada                    潮?
北?           ?ExpL6: lStart   - Inicia proc. zerando / apagando registros潮?
北?           ?                  da tabela e calculando as entradas       潮?
北滥哪哪哪哪哪牧哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪俦?
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北?
哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌*/
Function MATPrcPrd(cMes,cAno,cProdDe,cProdAte,cAliLeg,lStart,cLOGRec,lFinish,lCarga)   

Private aProc     := {}
Private cTBProc   := cAliLeg // Tabela de Apuracao
Private cTexto    := ""
//谀哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪?
//?PRIVATES em referencia aos campos da tabela cAliLeg, utilizadas em Macros no processamento?
//滥哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪?
Private cTBFil    := ""
Private cTBCod    := ""
Private cTBPeriod := ""
Private cTBVlr    := ""
Private cTBProCom := ""
Private cTBSD3Vlr := ""

Default cLOGRec   := ""
Default lStart    := .F.
Default lFinish   := .F.
Default lCarga    := .F.

cTexto := cLOGRec

//谀哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪?
//?Atualiza Privates com o nome dos campos da Tabela de Apuracao para uso em Macro           ?
//滥哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪?
MATTable()

//谀哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪?
//?Deleta registros ja existentes na Tabela para o periodo processado                        ?
//滥哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪?
If lStart
	MATDelRec(cMes,cAno)
EndIf

//谀哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪?
//?Zera campo no SD3 para o Periodo processado                                               ?
//滥哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪?
If lStart 
	MATZeraD3(cMes,cAno)
EndIf

//谀哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪?
//?Processa todas as Entradas de Materia-Prima para o Periodo correspondente                 ?
//滥哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪?
If lStart .Or. lCarga
	MATMedEnt(cMes,cAno,PadR('',TamSX3('D3_COD')[1]),Replicate('Z',TamSX3('D3_COD')[1]),'Z')
EndIf

//谀哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪?
//?Processa as Ordens de Producao do periodo de acordo com o range de Produtso informado     ?
//滥哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪?
If (!lStart .And. !lFinish) .Or. lCarga
	MATProcPR(cMes,cAno,PadR(cProdDe ,TamSX3("D3_COD")[1]),PadR(cProdAte,TamSX3("D3_COD")[1]))
EndIf      

If !lFinish
	cLOGRec := cTexto
EndIf

If lFinish .And. !Empty(cTexto)
	cTexto := STR0072+PULALINHA+PULALINHA + cTexto //"Existe recursividade na estrutura gerada atrav閟 da movimenta玢o. Abaixo est鉶 listadas as Ordens de Produ玢o cujo calculo foi comprometido por este motivo: "
	MATGrvLOG(cTexto)
EndIf

Return Nil   

/*苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘?
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北?
北谀哪哪哪哪哪穆哪哪哪哪哪穆哪哪哪穆哪哪哪哪哪哪哪哪哪哪哪履哪哪穆哪哪哪哪哪勘?
北?Funcao     ?MATMedEnt ?Autor ?Fiscal               ?Data ?06/11/14 潮?
北媚哪哪哪哪哪呐哪哪哪哪哪牧哪哪哪牧哪哪哪哪哪哪哪哪哪哪哪聊哪哪牧哪哪哪哪哪幢?
北?Descricao  ?Chamada do calculo das entradas por Legislacao             潮?
北媚哪哪哪哪哪呐哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪幢?
北?Parametros ?ExpA1: cMes     - Mes a ser calculado                      潮?
北?           ?ExpA2: cAno     - Ano a ser calculado                      潮?
北?           ?ExpA3: cProdDe  - Range de produtos                        潮?
北?           ?ExpA4: cProdAte - Range de produtos                        潮?
北滥哪哪哪哪哪牧哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪俦?
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北?
哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌*/
Static Function MATMedEnt(cMes,cAno,cProdDe,cProdAte)

If cTBProc == "CLJ"
	X073MedEnt(cMes,cAno,cProdDe,cProdAte)
EndIf

Return

/*苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘?
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北?
北谀哪哪哪哪哪穆哪哪哪哪哪穆哪哪哪穆哪哪哪哪哪哪哪哪哪哪哪履哪哪穆哪哪哪哪哪勘?
北?Funcao     ?MATUltPr  ?Autor ?Materiais            ?Data ?06/11/14 潮?
北媚哪哪哪哪哪呐哪哪哪哪哪牧哪哪哪牧哪哪哪哪哪哪哪哪哪哪哪聊哪哪牧哪哪哪哪哪幢?
北?Descricao  ?Verifica ultimo periodo de entrada do produto              潮?
北媚哪哪哪哪哪呐哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪幢?
北?Parametros ?ExpA1: cProduto - Produto a ser avaiado                    潮?
北?           ?ExpA2: cMes     - Mes a ser avaliado                       潮?
北?           ?ExpA3: cAno     - Ano a ser avaliado                       潮?
北媚哪哪哪哪哪呐哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪幢?
北?Retorno    ?cPeriodo: Mes e Ano / String 000000 caso sem entrada       潮?
北滥哪哪哪哪哪牧哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪俦?
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北?
哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌*/
Static Function MATUltPr(cProduto,cMes,cAno)

Local aAreaSD1  := SD1->(GetArea())
Local cAlias    := ""
Local cQuery    := ""

//谀哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪目
//?Efetua query para retornar o periodo no qual houve a ultima entrada de nota para o produto ?
//?Caso nao localize, o retorno sera a string 000000                                          ?
//滥哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪馁
cAlias := GetNextAlias()
cQuery	:= "SELECT " + MATIsNull() + " (SUBSTRING(MAX(SD1.D1_DTDIGIT),1,6),'000000') AS PERIODO "
cQuery += "FROM "+RetSqlName("SD1")+" SD1 "
cQuery += "WHERE (SD1.D1_FILIAL = '"+xFilial('SD1')+"') "
cQuery += "AND (SD1.D1_COD = '"+cProduto+"' AND SUBSTRING(SD1.D1_DTDIGIT,1,6) <= '"+cAno+cMes+"' "
cQuery += "AND D1_TIPO = 'N' "
cQuery += "AND D_E_L_E_T_ = '')"

cQuery := ChangeQuery(cQuery)
dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAlias,.T.,.T.)   

cMes := Substr((cAlias)->(PERIODO),5,2)
cAno := Substr((cAlias)->(PERIODO),1,4)

(cAlias)->(DbCloseArea())

RestArea(aAreaSD1)     

Return cMes+cAno

/*苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘?
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北?
北谀哪哪哪哪哪穆哪哪哪哪哪穆哪哪哪穆哪哪哪哪哪哪哪哪哪哪哪履哪哪穆哪哪哪哪哪勘?
北?Funcao     ?MATProcPR ?Autor ?Materiais            ?Data ?06/11/14 潮?
北媚哪哪哪哪哪呐哪哪哪哪哪牧哪哪哪牧哪哪哪哪哪哪哪哪哪哪哪聊哪哪牧哪哪哪哪哪幢?
北?Descricao  ?Processa as Producoes do Periodo                           潮?
北媚哪哪哪哪哪呐哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪幢?
北?Parametros ?ExpA1: cMes     - Mes a ser calculado                      潮?
北?           ?ExpA2: cAno     - Ano a ser calculado                      潮?
北?           ?ExpA3: cProdDe  - Range de produtos                        潮?
北?           ?ExpA4: cProdAte - Range de produtos                        潮?
北滥哪哪哪哪哪牧哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪俦?
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北?
哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌*/
Static Function MATProcPR(cMes,cAno,cProdDe,cProdAte)

Local aAreaSD3  := SD3->(GetArea())
Local cAliasSB1 := GetNextAlias()
Local cQuery    := ""                                                      	

//谀哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪?
//?Efetua query para obter a producao de todos os produtos acabados. ?
//滥哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪?
cQuery := "SELECT SUBSTRING(MAX(SD3.D3_EMISSAO),1,6) AS PERIODO, D3_COD AS PRODUTO "
cQuery += "FROM "+RetSqlName("SD3")+" SD3 LEFT JOIN "+RetSqlName("SB1")+" SB1 "
cQuery += "ON B1_FILIAL = '"+xFilial('SB1')+"' AND D3_FILIAL = '"+xFilial('SD3')+"' AND SB1.B1_COD = SD3.D3_COD "
cQuery += "WHERE SD3.D3_CF IN ('PR0','PR1') "
cQuery += "AND SD3.D3_COD >= '"+cProdDe+"' AND SD3.D3_COD <= '"+cProdAte+"' "
cQuery += "AND SUBSTRING((SD3.D3_EMISSAO),1,6) = '" + cAno+cMes +"' "
cQuery += "AND SD3.D_E_L_E_T_ = '' AND SD3.D3_ESTORNO = '' " 
cQuery += "AND SB1.D_E_L_E_T_ = '' " 
cQuery += "GROUP BY SD3.D3_COD "    

cQuery := ChangeQuery(cQuery)
dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasSB1,.T.,.T.)   

While !(cAliasSB1)->(Eof())
	//谀哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪?
	//?Verifica se ja existe registro na Tabela para o produto e periodo ?
	//滥哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪?
	(cTBProc)->(DbSetOrder(1))
	If (cTBProc)->(MsSeek(xFilial(cTBProc)+(cAliasSb1)->PRODUTO+Substr((cAliasSB1)->PERIODO,5,2)+Substr((cAliasSB1)->PERIODO,1,4)))
		(cAliasSB1)->(DbSkip())
		Loop
	Else
		//谀哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪?
		//?Se nao localizado na Tabela, sera necessario apurar sua media ?
		//滥哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪?
		MATMedPR((cAliasSb1)->PRODUTO,Substr((cAliasSB1)->PERIODO,5,2),Substr((cAliasSB1)->PERIODO,1,4))
		(cAliasSB1)->(DbSkip())
		Loop
	EndIf
EndDo

(cAliasSB1)->(dbclosearea())
RestArea(aAreaSD3)     
                                       
Return 

/*苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘?
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北?
北谀哪哪哪哪哪穆哪哪哪哪哪穆哪哪哪穆哪哪哪哪哪哪哪哪哪哪哪履哪哪穆哪哪哪哪哪勘?
北?Funcao     ?MATMedPR  ?Autor ?Materiais            ?Data ?06/11/14 潮?
北媚哪哪哪哪哪呐哪哪哪哪哪牧哪哪哪牧哪哪哪哪哪哪哪哪哪哪哪聊哪哪牧哪哪哪哪哪幢?
北?Descri嘺o  ?Calcular a media do VI para o produto produzido no periodo 潮?
北媚哪哪哪哪哪呐哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪幢?
北?Parametros ?ExpC1 = Codigo do produto acabado                          潮?
北?           ?ExpC2 = Mes para calculo da media                          潮?
北?           ?ExpC3 = Ano para calculo da media                          潮?
北滥哪哪哪哪哪牧哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪俦?
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北?
哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌*/
Function MATMedPR(cProduto,cMes,cAno)

Local aAreaSD3  := SD3->(GetArea())
Local aAreaTAB  := (cTBProc)->(GetArea())
Local cAlias    := GetNextAlias()
Local cOp       := ""      
Local lAchou    := .F.
Local lRecursiv := .F.
Local nQuantTot := 0
Local nVi       := 0 
Local nViTotal  := 0

//谀哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪?     
//?Efetua query para obter todas as ordens de producao do periodo para o produto |
//滥哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪?
cQuery := "SELECT SUM(D3_QUANT) AS QUANTIDADE, D3_OP,D3_COD "
cQuery += "FROM "+RetSqlName("SD3")+" SD3 "
cQuery += "WHERE SD3.D3_FILIAL = '"+xFilial('SD3')+"' AND SD3.D3_COD = '"+cProduto+"' "
cQuery += "AND SD3.D_E_L_E_T_ = '' AND SD3.D3_ESTORNO = '' " 
cQuery += "AND SD3.D3_OP <> '' AND SD3.D3_CF IN ('PR0','PR1') " 
cQuery += "AND SD3.D3_OP IN( "
cQuery += "SELECT D3_OP "
cQuery += "FROM "+RetSqlName("SD3")+" SD3OP "
cQuery += "WHERE SD3OP.D3_FILIAL = '"+xFilial('SD3')+"' AND SD3OP.D3_COD = '"+cProduto+"' "
cQuery += "AND SD3OP.D_E_L_E_T_ = '' AND SD3OP.D3_ESTORNO = '' " 
cQuery += "AND SD3.D3_OP <> '' AND SD3.D3_CF IN ('PR0','PR1') " 
cQuery += "AND SUBSTRING (SD3OP.D3_EMISSAO,1,6) = '"+cAno+cMes+"' "
cQuery += " ) " 
cQuery += "GROUP BY D3_OP,D3_COD ORDER BY SD3.D3_COD"

cQuery := ChangeQuery(cQuery)
dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAlias,.T.,.T.)   

While !(cAlias)->(Eof())
	cOp       := (cAlias)->D3_OP
	cProduto  := (cAlias)->D3_COD        
	lRecursiv := .F.
	
	//谀哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪?
	//砎erifica se o VI deste produto ja foi calculado por outra chamada             			  |
	//滥哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪?
	(cTBProc)->(DbSetOrder(1)) 
	lAchou := (cTBProc)->(MsSeek(xFilial(cTBProc)+cProduto+cMes+cAno))
	
	If !lAchou .Or. (lAchou .And. (cTBProc)->&(cTBProCom) = "C")
		//谀哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪?
		//矨diciona produto pai no array aProc (controle de recursividade na estrutura)				  |
		//滥哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪?
		If Ascan(aProc,{|x| x[1] == cProduto})>0
			cTexto += STR0073 + aProc[Len(aProc)][2] + STR0074 + aProc[Len(aProc)][1] + STR0075 + cMes+"/"+cAno+PULALINHA // "Ordem de Produ玢o: " ##"- Produto: " ## 
			lRecursiv := .T.
		Else
			AADD(aProc,{cProduto,cOP})
		EndIf
		//谀哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪?
		//?Obtem o VI atraves da composicao dos VIs dos produtos requisitados para a OP. 			  |
		//滥哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪?
		If !lRecursiv
			nVi 		:= MATExplRQ(cOp,cMes,cAno,cProduto)
		EndIf
			nViTotal 	+= nVi                
			nVi    		:= nVi/(cAlias)->QUANTIDADE
			nQuantTot 	+= (cAlias)->QUANTIDADE
		
		//谀哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪?
		//?Grava o VI no registro de producao da SD3.									 			  |
		//滥哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪?
		dbSelectArea('SD3')
		SD3->(DbSetOrder(1))
		If SD3->(MsSeek(xFilial('SD3')+cOp))
			While SD3->D3_FILIAL = xFilial('SD3') .And. SD3->D3_OP = cOP
				If SD3->D3_CF $ 'PR0|PR1' .And. SD3->D3_ESTORNO != "S"
					MATGrvSD3(nVi*D3_QUANT)
				EndIf
				SD3->(DbSkip())
			End
		EndIf
		(cAlias)->(DbSkip())
		//谀哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪目
		//?Ao processar todas as OPs, registra o VI do produto acabado na tabela      ?
		//滥哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪馁
		If (cAlias)->(Eof())
			DbSelectArea(cTBProc)
			(cTBProc)->(DbSetOrder(1))
			If !MsSeek(xFilial(cTBProc)+cProduto+cMes+cAno)
				MATGrvTAB(cProduto,cMes+cAno,(nViTotal/nQuantTot),"P",.T.)
			Else
				MATGrvTAB(cProduto,cMes+cAno,(nViTotal/nQuantTot),"P",.F.)
			EndIf  
			nViTotal  := 0
			nQuantTot := 0	
		EndIf
		//谀哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪?
		//?Retira produto pai no array aProc (controle de recursividade na estrutura)				   ?
		//滥哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪?
		If !lRecursiv
			ADel(aProc,len(aProc))
			ASize(aProc,len(aProc)-1)
		EndIf  
	Else 
		(cAlias)->(DbSkip())
	EndIf
End

(cAlias)->(DbCloseArea())   
RestArea(aAreaTAB)
RestArea(aAreaSD3)

Return

/*苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘?
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北?
北谀哪哪哪哪哪穆哪哪哪哪哪穆哪哪哪穆哪哪哪哪哪哪哪哪哪哪哪履哪哪穆哪哪哪哪哪勘?
北?Funcao     ?MATExplRQ ?Autor ?Materiais            ?Data ?06/11/14 潮?
北媚哪哪哪哪哪呐哪哪哪哪哪牧哪哪哪牧哪哪哪哪哪哪哪哪哪哪哪聊哪哪牧哪哪哪哪哪幢?
北?Descricao  ?Explode as requisicoes e devolve o somatorio do VI de cada 潮?
北?           ?materia prima utilizada na requisicao. (Recursiva)         潮?
北媚哪哪哪哪哪呐哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪幢?
北?Parametros ?ExpA1: cOp  - Op a ter as requisicoes explodidas           潮?
北?           ?ExpA2: cMes - Mes a ser avaliado                           潮?
北?           ?ExpA3: cAno - Ano a ser avaliado                           潮?
北?           ?ExpA4: cProd - Produto pai da ordem de producao            潮?
北媚哪哪哪哪哪呐哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪幢?
北?Retorno    ?nVi  : Valor da parcela importada do produto acabado       潮?
北滥哪哪哪哪哪牧哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪俦?
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北?
哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌*/
Static Function MATExplRQ(cOp,cMes,cAno,cProd)

Local cAliasReq := GetNextAlias()
Local cAliasPi  := GetNextAlias()
Local cAliasSD3 := SD3->(GetArea())
Local cCccusto  := Criavar("B1_CCCUSTO",.F.)
Local cPeriodo  := ""
Local cQuery    := ""  
Local nVi       := 0
Local lMATINFVL := ExistBlock('MATINFVL')
Default cProd   := ""

//谀哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪?
//?Efetua query para localizar todas as requisicoes realizadas para a OP ?
//滥哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪?
cQuery := "SELECT SUM(CASE WHEN SD3.D3_CF LIKE ('DE%') THEN (SD3.D3_QUANT*-1) "
cQuery += "WHEN SD3.D3_CF LIKE ('RE%') THEN (SD3.D3_QUANT) ELSE 0 END) AS QUANTIDADE, SD3.D3_COD "
cQuery += "FROM "+RetSqlName("SD3")+" SD3 JOIN "+RetSqlName("SB1")+" SB1 "
cQuery += "ON SB1.B1_FILIAL = '"+xFilial("SB1")+"' AND SB1.B1_COD = SD3.D3_COD AND SB1.D_E_L_E_T_ = '' "
cQuery += "WHERE SD3.D3_FILIAL = '"+xFilial('SD3')+"' "
cQuery += "AND SD3.D_E_L_E_T_ = '' AND SD3.D3_ESTORNO = '' " 
cQuery += "AND SD3.D3_OP = '"+cOP+"' AND (SD3.D3_CF LIKE ('RE%') OR SD3.D3_CF LIKE ('DE%')) "
cQuery += "AND SUBSTRING (SB1.B1_COD,1,3) <> 'MOD' "
cQuery += "AND SB1.B1_CCCUSTO = '"+cCccusto+"' " 
cQuery += "GROUP BY D3_COD ORDER BY SD3.D3_COD"

cQuery := ChangeQuery(cQuery)
dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasReq,.T.,.T.)   	 

//谀哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪?
//?Efetua query para avaliar se o produto requisitado foi produzido ou fabricado ?
//滥哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪?
While !(cAliasReq)->(Eof())
	cProd := (cAliasReq)->D3_COD
	cQuery := "SELECT SUBSTRING(MAX(SD3.D3_EMISSAO),1,6) AS PERIODO "
	cQuery += " FROM "+RetSqlName("SD3")+" SD3"
	cQuery += "WHERE SD3.D3_FILIAL = '"+xFilial('SD3')+"' "
	cQuery += "AND SD3.D_E_L_E_T_ = '' AND SD3.D3_ESTORNO = '' "
	cQuery += "AND SD3.D3_CF IN ('PR0','PR1') AND SD3.D3_COD = '" +cProd+"' " 
	cQuery += "AND SUBSTRING (SD3.D3_EMISSAO,1,6) <= '"+cAno+cMes+"'"
	
	cQuery := ChangeQuery(cQuery)
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasPi,.T.,.T.) 
	
	//谀哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪?
	//?Caso o produto requisitado tenha sido produzido, calcula a media de suas producoes no periodo ?
	//滥哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪?
	If !Empty((cAliasPI)->PERIODO) 
		MATProcPR(Substr((cAliasPi)->PERIODO,5,2),Substr((cAliasPi)->PERIODO,1,4),cProd,cProd)
		//谀哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪?
		//?Apos calcular a media, recupera o valor gravado na Tabela ?
		//滥哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪?
		If (cTBProc)->(MsSeek(xFilial(cTBProc)+cProd+Substr((cAliasPi)->PERIODO,5,2)+Substr((cAliasPi)->PERIODO,1,4)))       
			nVi += (cTBProc)->&(cTBVlr)*(cAliasReq)->QUANTIDADE
		EndIf
	Else                                                                                              	
		//谀哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪目
		//?Caso o produto requisitado tenha sido comprado, localiza se existe Tabela para o periodo ?
		//滥哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪馁
		(cTBProc)->(DbSetOrder(1)) 
		If (cTBProc)->(MsSeek(xFilial(cTBProc)+(cAliasReq)->D3_COD+cMes+cAno))
			nVi += (cTBProc)->&(cTBVlr)*(cAliasReq)->QUANTIDADE
		Else 
			//谀哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪目
			//?Se nao houver, verifica quando foi a ultimo aquisicao do produto     ?
			//滥哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪馁
			cPeriodo := MATUltPr((cAliasReq)->D3_COD,cMes,cAno)
			//谀哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪?
			//?Se nao houve compra para o produto, pode ser utilizado o ponto de entrada 'MATINFVL' para ?
			//?informacao do valor. Caso contrario, sera assumido que a parcela de importacao eh zero    ?
			//滥哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪?
			If cPeriodo == "000000" 
				If lMATINFVL // *** Ponto de Entrada
					nVi += ExecBlock('MATINFVL',.F.,.F.,{(cAliasReq)->D3_COD,cMes,cAno,cTBProc})					                       	
				Else
					nVi += 0
				EndIf
			Else
				//谀哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪?
				//?Se houve compra em mes anterior, verifica que se o VI deste mes ja esta apurado na Tabela ?
				//滥哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪?
				If (cTBProc)->(MsSeek(xFilial(cTBProc)+(cAliasReq)->D3_COD+cPeriodo))  
					nVi += (cTBProc)->&(cTBVlr)*(cAliasReq)->QUANTIDADE			
				Else 
					//谀哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪目
					//?Se nao ha, processa sua gravacao e obtencao do VI do mes correspondente    ?
					//滥哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪馁
					MATMedEnt(Substr(cPeriodo,1,2),Substr(cPeriodo,3,4),(cAliasReq)->D3_COD,(cAliasReq)->D3_COD)
					If (cTBProc)->(MsSeek(xFilial(cTBProc)+(cAliasReq)->D3_COD+cPeriodo))
						nVi += (cTBProc)->&(cTBVlr)*(cAliasReq)->QUANTIDADE
					EndIf
				EndIf
			EndIf
		EndIf
	EndIf 
	(cAliasPI)->(DbCloseArea())
	(cAliasReq)->(DbSkip())
End 
(cAliasReq)->(DbCloseArea())
RestArea(cAliasSD3)

Return nVi

/*苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘?
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北?
北谀哪哪哪哪哪穆哪哪哪哪哪穆哪哪哪穆哪哪哪哪哪哪哪哪哪哪哪履哪哪穆哪哪哪哪哪勘?
北?Funcao     ?MATDelRec ?Autor ?Materiais            ?Data ?06/11/14 潮?
北媚哪哪哪哪哪呐哪哪哪哪哪牧哪哪哪牧哪哪哪哪哪哪哪哪哪哪哪聊哪哪牧哪哪哪哪哪幢?
北?Descricao  ?Deleta os registros gerados na Tabela caso a apuracao ja   潮?
北?           ?tenha sido realizada anteriormente                         潮?
北媚哪哪哪哪哪呐哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪幢?
北?Parametros ?ExpC1: cMes     - Mes a processar                          潮?
北?           ?ExpC2: cAno     - Ano a processar                          潮?
北滥哪哪哪哪哪牧哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪俦?
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北?
哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌*/
Static Function MATDelRec(cMes,cAno)

Local aArea := GetArea()

(cTBProc)->(DbSetOrder(2))
If (cTBProc)->(MsSeek(xFilial(cTBProc)+cMes+cAno))
	While (cTBProc)->&(cTBFil) == xFilial(cTBProc) .And. (cTBProc)->&(cTBPeriod) == cMes+cAno
		RecLock(cTBProc,.F.)
		(cTBProc)->(DbDelete())
		(cTBProc)->(MsUnLock())
		(cTBProc)->(DbSkip())
	EndDo
EndIf

RestArea(aArea)

Return       

/*苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘?
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北?
北谀哪哪哪哪哪穆哪哪哪哪哪穆哪哪哪穆哪哪哪哪哪哪哪哪哪哪哪履哪哪穆哪哪哪哪哪勘?
北?Funcao     ?MATZeraD3 ?Autor ?Materiais            ?Data ?06/11/14 潮?
北媚哪哪哪哪哪呐哪哪哪哪哪牧哪哪哪牧哪哪哪哪哪哪哪哪哪哪哪聊哪哪牧哪哪哪哪哪幢?
北?Descricao  ?Funcao responsavel pela delecao dos valores registrados na 潮?
北?           ?SD3 caso a apuracao ja tenha sido realizada anteriormente  潮?
北媚哪哪哪哪哪呐哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪幢?
北?Parametros ?ExpC1: cMes     - Mes a processar                          潮?
北?           ?ExpC2: cAno     - Ano a processar                          潮?
北滥哪哪哪哪哪牧哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪俦?
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北?
哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌*/
Static Function MATZeraD3(cMes,cAno)

Local aArea    := GetArea()
Local aAreaSD3 := SD3->(GetArea())
Local cQuery   := ""

cQuery := "UPDATE "
cQuery += RetSqlName("SD3")+" "	
cQuery += "SET " + cTBSD3Vlr + " = 0 "
cQuery += "WHERE D3_FILIAL='"+xFilial("SD3")+"' AND "
cQuery += "D_E_L_E_T_= ' ' AND "
cQuery += "D3_ESTORNO <> 'S' AND "
cQuery += "D3_CF IN ('PR0','PR1') AND D3_EMISSAO BETWEEN '"+cAno+cMes+"01' AND '"+cAno+cMes+"31'"

TcSqlExec(cQuery)

RestArea(aArea)
RestArea(aAreaSD3)

Return

/*苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘?
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北?
北谀哪哪哪哪哪穆哪哪哪哪哪穆哪哪哪穆哪哪哪哪哪哪哪哪哪哪哪履哪哪穆哪哪哪哪哪勘?
北?Funcao     ?MATGrvLOG ?Autor ?Materiais            ?Data ?06/11/14 潮?
北媚哪哪哪哪哪呐哪哪哪哪哪牧哪哪哪牧哪哪哪哪哪哪哪哪哪哪哪聊哪哪牧哪哪哪哪哪幢?
北?Descricao  ?Funcao utilizada para gravacao do Log                      潮?
北媚哪哪哪哪哪呐哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪幢?
北?Parametros ?ExpC1: cTexto - Texto para geracao do LOG                  潮?
北滥哪哪哪哪哪牧哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪俦?
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北?
哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌*/
Static Function MATGrvLOG(cTexto)

Local cFile  := ''

cFile := 'RECMAT'+Right(CriaTrab(, .F.), 3)+'.LOG'
lRet := MemoWrite(cFile, cTexto)
If lRet 
	Aviso(STR0076, cTexto+PULALINHA+STR0077+cFile+STR0078, {'Ok'},3) //"Recursividade" ##"Aten玢o: LOG salvo automaticamente como " ##" no StartPath." ##
Else 
	Aviso(STR0076, cTexto+PULALINHA+STR0079+cFile+STR0078, {'Ok'},3) //"N鉶 foi poss韛el salvar o arquivo " ##" no StartPath."
EndIf

Return Nil

/*苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘?
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北?
北谀哪哪哪哪哪穆哪哪哪哪哪穆哪哪哪穆哪哪哪哪哪哪哪哪哪哪哪履哪哪穆哪哪哪哪哪勘?
北?Funcao     ?MATGrvTAB ?Autor ?Materiais            ?Data ?06/11/14 潮?
北媚哪哪哪哪哪呐哪哪哪哪哪牧哪哪哪牧哪哪哪哪哪哪哪哪哪哪哪聊哪哪牧哪哪哪哪哪幢?
北?Descricao  ?Funcao utilizada para Gravacao da Tabela de Apuracao       潮?
北媚哪哪哪哪哪呐哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪幢?
北?Parametros ?ExpC1: cProduto - Codigo do Produto                        潮?
北?           ?ExpC2: cPeriodo - Periodo                                  潮?
北?           ?ExpN3: nVi      - Valor Apurado                            潮?
北?           ?ExpC5: cProcom  - Produto Comprado / Produzido             潮?
北?           ?ExpL6: lInclui  - Incluir registro                         潮?
北滥哪哪哪哪哪牧哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪俦?
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北?
哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌*/
Function MATGrvTAB(cProduto,cPeriodo,nVi,cProcom,lInclui)

RecLock(cTBProc,lInclui)

If lInclui
	&(cTBFil)    := xFilial(cTBProc)
	&(cTBCod)    := cProduto
	&(cTBPeriod) := cPeriodo
	&(cTBVlr)    := nVi
	&(cTBProCom) := cProcom
Else
	&(cTBVlr)    := nVi
	&(cTBProCom) := cProcom
EndIf

(cTBProc)->(MsUnlock())

Return Nil

/*苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘?
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北?
北谀哪哪哪哪哪穆哪哪哪哪哪穆哪哪哪穆哪哪哪哪哪哪哪哪哪哪哪履哪哪穆哪哪哪哪哪勘?
北?Funcao     ?MATGrvSD3 ?Autor ?Materiais            ?Data ?06/11/14 潮?
北媚哪哪哪哪哪呐哪哪哪哪哪牧哪哪哪牧哪哪哪哪哪哪哪哪哪哪哪聊哪哪牧哪哪哪哪哪幢?
北?Descricao  ?Funcao utilizada para Gravacao do valor apurado no SD3     潮?
北媚哪哪哪哪哪呐哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪幢?
北?Parametros ?ExpC1: cTexto - Texto para geracao do LOG                  潮?
北滥哪哪哪哪哪牧哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪俦?
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北?
哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌*/
Function MATGrvSD3(nValor)

RecLock("SD3",.F.)
&(cTBSD3Vlr) := nValor
SD3->(MsUnlock())

Return Nil

/*苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘?
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北?
北谀哪哪哪哪哪穆哪哪哪哪哪穆哪哪哪穆哪哪哪哪哪哪哪哪哪哪哪履哪哪穆哪哪哪哪哪勘?
北?Funcao     ?MATTable  ?Autor ?Materiais            ?Data ?06/11/14 潮?
北媚哪哪哪哪哪呐哪哪哪哪哪牧哪哪哪牧哪哪哪哪哪哪哪哪哪哪哪聊哪哪牧哪哪哪哪哪幢?
北?Descricao  ?Atualiza Privates com nome dos campos para uso em Macro    潮?
北滥哪哪哪哪哪牧哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪俦?
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北?
哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌*/
Static Function MATTable()

If cTBProc == "CLJ"
	cTBFil    := "CLJ_FILIAL"   // Campo Filial
	cTBCod    := "CLJ_COD"      // Campo Produto
	cTBPeriod := "CLJ_PERIOD"   // Campo Periodo
	cTBVlr    := "CLJ_VLRVI"    // Campo Valor
	cTBProCom := "CLJ_PROCOM"   // Campo Produzido/Comprado
	cTBSD3Vlr := "D3_VLRPD"
EndIf

Return Nil

/*苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘?
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北?
北谀哪哪哪哪哪穆哪哪哪哪哪穆哪哪哪穆哪哪哪哪哪哪哪哪哪哪哪履哪哪穆哪哪哪哪哪勘?
北?Funcao     ?MATIsNull ?Autor ?Materiais            ?Data ?06/11/14 潮?
北媚哪哪哪哪哪呐哪哪哪哪哪牧哪哪哪牧哪哪哪哪哪哪哪哪哪哪哪聊哪哪牧哪哪哪哪哪幢?
北?Descricao  ?Tratamento para ISNULL no cQuery em diferentes BD's        潮?
北滥哪哪哪哪哪牧哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪俦?
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北?
哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌*/
Function MATIsNull()

Local cFuncNull := " "
Local cDbType   := TCGetDB()

Do Case
	Case cDbType $ "DB2|POSTGRES"
		cFuncNull	:= "COALESCE"
	Case cDbType $ "ORACLE|INFORMIX"  
  		cFuncNull	:= "NVL"
 	Otherwise
 		cFuncNull	:= "ISNULL"
EndCase

Return cFuncNull

/*
苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘?
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北?
北谀哪哪哪哪穆哪哪哪哪哪哪穆哪哪哪穆哪哪哪哪哪哪哪哪哪哪履哪哪穆哪哪哪哪哪勘?
北矲un噮o	  ?ISalmTerc  ?Autor ?TOTVS S/A   	       ?Data ?5/11/2015潮?
北媚哪哪哪哪呐哪哪哪哪哪哪牧哪哪哪牧哪哪哪哪哪哪哪哪哪哪聊哪哪牧哪哪哪哪哪幢?
北矰escri噮o ?Valida armazem de terceiros                                潮?
北媚哪哪哪哪呐哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪幢?
北?Uso	  ?                                                            潮?
北媚哪哪哪哪呐哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪幢?
北砅arametros?cMcampo   - armazem digitado pelo usu醨io                  潮?
北?         ?                                                           潮?
北滥哪哪哪哪牧哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪俦?
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北?
哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌?
*/

Function ISalmTerc(cMcampo)


Local lCampo      := .F.
Local cALMTERC  := GetMvNNR('MV_ALMTERC','80')
Local aAreaNNR := {}
Default cMcampo := ""

AjustaHelp()

IF AliasInDic("NNR")
	aAreaNNR := NNR->(GetArea())
	If !empty(cMcampo)
		NNR->(dbSelectArea("NNR"))
	    NNR->(DbSetOrder(1))
		IF NNR->(DbSeek(xFilial("NNR")+cMcampo))
		    if  Alltrim(cMcampo) $ cALMTERC
				lCampo := .T.
			Else 
				lcampo := .F.
				HELP(" ",1,"NOARMAZEM")
			EndIf
		else
			HELP(" ",1,"NOARMAZEM")
			lCampo := .F.
		EndIf
	else 
		HELP(" ",1,"NOARMAZEM")
	EndIf
	RestArea(aAreaNNR)
Elseif  Alltrim(cMcampo) $ cALMTERC
		lCampo:= .T.
Else 
	lCampo:= .F.
	HELP(" ",1,"NOARMAZEM")
EndIf

Return lCampo

/*
苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北
北谀哪哪哪哪穆哪哪哪哪哪哪哪履哪哪哪履哪哪哪哪哪哪哪哪哪哪穆哪哪哪履哪哪哪哪目北
北矲un噭o    | AjustaHelp    Autor  ?TOTVS S/A   	      ?Data ?5/11/2015|北
北媚哪哪哪哪呐哪哪哪哪哪哪哪聊哪哪哪聊哪哪哪哪哪哪哪哪哪哪牧哪哪哪聊哪哪哪哪拇北
北矰escri噭o 矨justa os helps                                                潮?
北媚哪哪哪哪呐哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪拇北
北砈intaxe   矨justaHelp()                                                   潮?
北媚哪哪哪哪呐哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪拇北
北砅arametros砃enhum                                                         潮?
北媚哪哪哪哪呐哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪拇北
北砇etorno   砃enhum                                                         潮?
北滥哪哪哪哪牧哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪馁北
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北
*/
Static Function AjustaHelp()
Local aArea 	:= GetArea()
Local aHelpPor	:= {}
Local aHelpEng	:= {}
Local aHelpSpa	:= {}


aHelpPor :=	{"Armaz閙 n鉶 Localizado "}
aHelpSpa :=	{"Arrendamiento no encuentra"}
aHelpEng :=	{"Lease Located not"}
PutHelp("PNOARMAZEM",aHelpPor,aHelpEng,aHelpSpa,.F.)

aHelpPor :=	{"Verifique o Par鈓etro "," MV_ALMTERC e o cadastro"," de armaz閙"}
aHelpSpa :=	{"Comprobar Par醡etro", "MV_ALMTERC","y la base de almac閚"}
aHelpEng :=	{"Check Parameter", "MV_ALMTERC","and warehouse base"}
PutHelp("SNOARMAZEM",aHelpPor,aHelpEng,aHelpSpa,.F.)

Return 

/*
苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘?
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北?
北谀哪哪哪哪穆哪哪哪哪哪哪穆哪哪哪穆哪哪哪哪哪哪哪哪哪哪履哪哪穆哪哪哪哪哪勘?
北矲un噮o	 ?ProcCAT83   ?Autor ?TOTVS S/A   		?Data ?07/08/15 潮?
北媚哪哪哪哪呐哪哪哪哪哪哪牧哪哪哪牧哪哪哪哪哪哪哪哪哪哪聊哪哪牧哪哪哪哪哪幢?
北矰escri噮o ?Preenche o campo D3_CODLAN dos movimentos na SD3           潮?
北媚哪哪哪哪呐哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪幢?
北?Uso		 ?CAT83                                                      潮?
北媚哪哪哪哪呐哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪幢?
北砅arametros?dDtIni   - Data inicial dos registros a processar          潮?
北?         ?dDtFim   - Data final dos registros a processar            潮?
北?         ?lProcAll - Processa tudo (.T.) ou so D3_CODLAN vazio (.F.) 潮?
北滥哪哪哪哪牧哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪俦?
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北?
哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌?
*/
Function PCAT83_SD3(dDtIni,dDtFim,lProcAll)

Local cQuery	:= ""
Local cWhere	:= ""
Local cProduto	:= ""
Local aArea		:= GetArea()
Local cAliTMP	:= GetNextAlias()

Default lProcAll := .F.

#IFDEF TOP
//谀哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪目
//?Seleciona registros para processamento       ?
//滥哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪馁
cQuery := "SELECT D3_COD,D3_CF,D3_OP,D3_DOC,D3_CODLAN,R_E_C_N_O_,D3_NUMSEQ FROM " + RetSQLName("SD3")
cWhere := " WHERE D_E_L_E_T_ = ' ' AND D3_ESTORNO = ' ' AND D3_FILIAL = '" + xFilial("SD3") + "'"
cWhere += " AND D3_CF NOT IN ('RE9','DE9') AND D3_EMISSAO BETWEEN '" + DtoS(dDtIni) + "'"
cWhere += " AND '" + DtoS(dDtFim) + "' " + If(lProcAll,"","AND D3_CODLAN = ' ' ")
cQuery += cWhere

ChangeQuery(cQuery)
dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliTMP,.T.,.T.)

//谀哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪?
//?Limpa o D3_CODLAN quando processar todos os registros ?
//滥哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪?
If lProcAll
	cQuery := "UPDATE SD3T10 SET D3_CODLAN = ''"
	cQuery += cWhere
	TcSqlExec(cQuery)
EndIf

//谀哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪目
//?Processa os movimentos da SD3                ?
//滥哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪馁
dbSelectArea("SD3")
While (cAliTMP)->(!Eof())
	SD3->(dbGoTo((cAliTMP)->R_E_C_N_O_))
	Reclock("SD3",.F.)
	If SD3->D3_CF == "DE7"
		cProduto := PCAT83_Ori((cAliTMP)->D3_NUMSEQ)
		SD3->D3_CODLAN := A240CAT83(cProduto)
	Else
		SD3->D3_CODLAN := A240CAT83()
	EndIf
	SD3->(MSUnlock())
	(cAliTMP)->(dbSkip())
EndDo

(cAliTMP)->(DbCloseArea())
#ENDIF

RestArea(aArea)

Return

/*
苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘?
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北?
北谀哪哪哪哪穆哪哪哪哪哪哪穆哪哪哪穆哪哪哪哪哪哪哪哪哪哪履哪哪穆哪哪哪哪哪勘?
北矲un噮o	 ?PCAT83_Ori  ?Autor ?TOTVS S/A   		?Data ?11/01/17 潮?
北媚哪哪哪哪呐哪哪哪哪哪哪牧哪哪哪牧哪哪哪哪哪哪哪哪哪哪聊哪哪牧哪哪哪哪哪幢?
北矰escri噮o ?Retorna o produto de origem do movimento                   潮?
北媚哪哪哪哪呐哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪幢?
北?Uso		 ?CAT83                                                      潮?
北媚哪哪哪哪呐哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪幢?
北砅arametros?cNumSeq  - Numero sequencial do movimento                  潮?
北滥哪哪哪哪牧哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪俦?
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北?
哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌?
*/
Static Function PCAT83_Ori(cNumSeq)

Local cQuery	:= ""
Local cMovOri	:= ""
Local cRet		:= ""
Local aArea		:= GetArea()
Local cAliTMP	:= GetNextAlias()

//谀哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪目
//?Define o movimento de Origem                 ?
//滥哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪馁
If SD3->D3_CF == "DE7"
	cMovOri := "RE7"
EndIf

//谀哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪目
//?Seleciona registros para processamento       ?
//滥哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪馁
cQuery := "SELECT D3_COD,D3_CF FROM "+RetSQLName("SD3")+" WHERE D_E_L_E_T_ = ' ' AND "
cQuery += "D3_FILIAL = '" + xFilial("SD3") + "' AND D3_NUMSEQ = '"+ cNumSeq +"' ORDER BY 2 DESC"

ChangeQuery(cQuery)
dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliTMP,.T.,.T.)

//谀哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪目
//?Busca o produto de origem da desmontagem     ?
//滥哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪馁
While (cAliTMP)->(!Eof())
	If (cAliTMP)->D3_CF == cMovOri
		cRet := (cAliTMP)->D3_COD
		Exit
	EndIf
	(cAliTMP)->(dbSkip())
EndDo

RestArea(aArea)

Return cRet

/*
苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘?
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北?
北谀哪哪哪哪穆哪哪哪哪哪哪穆哪哪哪穆哪哪哪哪哪哪哪哪哪哪履哪哪穆哪哪哪哪哪勘?
北矲un噮o	 ?PCAT83_MOD  ?Autor ?TOTVS S/A   		?Data ?10/08/15 潮?
北媚哪哪哪哪呐哪哪哪哪哪哪牧哪哪哪牧哪哪哪哪哪哪哪哪哪哪聊哪哪牧哪哪哪哪哪幢?
北矰escri噮o ?Retorna movimentos de MOD e GGF do periodo                 潮?
北媚哪哪哪哪呐哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪幢?
北?Uso		 ?CAT83                                                      潮?
北媚哪哪哪哪呐哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪幢?
北砅arametros?dDtIni   - Data inicial dos registros a processar          潮?
北?         ?dDtFim   - Data final dos registros a processar            潮?
北?         ?cMODIni  - Codigo Inicial                                  潮?
北?         ?cMODFim  - Codigo Final                                    潮?
北?         ?cAliTRB  - Alias Temporario                                潮?
北滥哪哪哪哪牧哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪俦?
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北?
哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌?
*/
Function PCAT83_MOD(dDtIni,dDtFim,cMODIni,cMODFim,cAliTRB)

Local cQuery	:= ""
Local cSubstr	:= "SUBSTRING"
Local cDbType	:= TCGetDB()
Local aArea		:= GetArea()

#IFDEF TOP
//谀哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪目
//?Tratamento para SUBSTRING em diferentes BD's ?
//滥哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪馁
If cDbType $ "ORACLE/POSTGRES"
	cSubstr  := "SUBSTR"
EndIf

cQuery := "SELECT SC2.C2_PRODUTO, SD3.D3_COD, "
cQuery += "SUM(CASE WHEN SD3.D3_CF LIKE ('DE%') THEN (SD3.D3_QUANT*-1) "
cQuery += "WHEN SD3.D3_CF LIKE ('RE%') THEN (SD3.D3_QUANT) ELSE 0 END) AS QUANTIDADE "
cQuery += "FROM "+ RetSQLName("SD3") +" SD3 JOIN "+ RetSQLName("SB1")
cQuery += " SB1 ON SB1.B1_FILIAL = '"+ xFilial("SB1") +"' AND " 
cQuery += "SB1.B1_COD = SD3.D3_COD AND SB1.D_E_L_E_T_ = ' ' "
cQuery += "JOIN "+ RetSQLName("SC2") +" SC2 ON SC2.C2_FILIAL = '"+ xFilial("SC2") +"' AND "
cQuery += "SC2.C2_NUM||SC2.C2_ITEM||SC2.C2_SEQUEN = SD3.D3_OP AND SC2.D_E_L_E_T_ = ' ' "
cQuery += "WHERE SD3.D3_FILIAL = '"+ xFilial("SD3") +"' AND SD3.D_E_L_E_T_ = ' ' AND " 
cQuery += "SD3.D3_ESTORNO = ' ' AND SD3.D3_OP <> ' ' AND " 
cQuery += "SD3.D3_EMISSAO BETWEEN '"+ DtoS(dDtIni) +"' AND '"+ DtoS(dDtFim) +"' AND "
cQuery += "SD3.D3_COD BETWEEN '"+ cMODIni +"' AND '"+ cMODFim +"'  AND "
cQuery += "(SD3.D3_CF LIKE ('RE%') OR SD3.D3_CF LIKE ('DE%')) AND " 
cQuery += "("+ cSubstr +"(SB1.B1_COD,1,3) = 'MOD' OR SB1.B1_CCCUSTO <> ' ') "
cQuery += "GROUP BY SC2.C2_PRODUTO, SD3.D3_COD ORDER BY SC2.C2_PRODUTO, SD3.D3_COD"

cQuery := ChangeQuery(cQuery)
dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliTRB,.T.,.T.)
#ENDIF

RestArea(aArea)

Return

// ---------------------------------------------------------------------------
/*/{Protheus.doc} RetNFOri
Realiza a montagem de um arquivo temp髍ario (TRB) contendo os componentes 
utilizados na produ玢o de um produto e suas respectivas Notas Fiscais de
compra, dentro do periodo informado nos parametros. A busca e montagem do 
arquivo temporario ?reallizada com base no FIFO. 
@author robson.ribeiro
@since 01/03/2016
@version 1.0
@param dDtIni,		data,	(Data inicial para Produ玢o)
@param dDtFim,		data,	(Data final para Produ玢o)
@param dDtIniCom,	data,	(Data inicial para Compra)
@param dDtFimCom,	data,	(Data final para Compra)
@param aAliVenda,	array,	(Array contendo os produtos que ser鉶 processados)
@param aCpoSD1,		array,	(Campos da SD1 que devem ser retornados no TRB)
@return ${return}, ${Retorna o Alias do arquivo tempor醨io (TRB) gerado}
/*/
// ---------------------------------------------------------------------------
Function RetNFOri(dDtIni,dDtFim,dDtIniCom,dDtFimCom,aAliVenda,aCpoSD1,lTotal,oTable)

Local aComps		:= {}
Local aNF			:= {}
Local cOP			:= ""
Local cAliRet		:= ""
Local nCpoPad		:= 0
Local nX, nY, nZ
Local oTable 		:= NIL
Private cDbType		:= TCGetDB()

Default lTotal  	:= .F.

oTable := MontTRB(@cAliRet,aCpoSD1)
If !lTotal
	For nX := 1 To Len(aAliVenda)
	
		cOP		:= RetLastOP(dDtIni,dDtFim,aAliVenda[nX])
		
		If !Empty(cOP) 
			aComps	:= RetOPCom(dDtIni,dDtFim,cOP)
		EndIf
		
		For nY := 1 to Len(aComps)
			aNF := RetUltNF(aComps[nY][1],dDtIniCom,dDtFimCom,aCpoSD1)
			If Len(aNF) > 0
				Reclock(cAliRet, .T.)
				(cAliRet)->PROD_PA		:= aAliVenda[nX]
				(cAliRet)->PROD_COMP	:= aComps[nY][1]
				(cAliRet)->QUANT		:= aComps[nY][2]
				(cAliRet)->OP_PA		:= cOP
				(cAliRet)->D1_DOC		:= aNF[1]
				(cAliRet)->D1_SERIE		:= aNF[2]
				(cAliRet)->D1_FORNECE	:= aNF[3]
				(cAliRet)->D1_LOJA		:= aNF[4]
				(cAliRet)->D1_ITEM		:= aNF[5]
				
				nCpoPad := Len(aNF) - Len(aCpoSD1)
				For nZ := (nCpoPad + 1) To Len(aNF)
					(cAliRet)->(&(aCpoSD1[nZ - nCpoPad])) := aNF[nZ]
				Next nZ
				(cAliRet)->(MsUnlock())
			EndIf
		Next nY
	Next nX
Else
	For nX := 1 To Len(aAliVenda)
	
		cOP		:= RetLastOP(dDtIni,dDtFim,aAliVenda[nX])
		
		If !Empty(cOP) 
			aComps	:= RetOPCom(dDtIni,dDtFim,cOP)
			For nY := 1 to Len(aComps)
				aNF := RetUltNF(aComps[nY][1],dDtIniCom,dDtFimCom,aCpoSD1)
				If Len(aNF) > 0
					Reclock(cAliRet, .T.)
					(cAliRet)->PROD_PA		:= aAliVenda[nX]
					(cAliRet)->PROD_COMP	:= aComps[nY][1]
					(cAliRet)->QUANT		:= aComps[nY][2]
					(cAliRet)->OP_PA		:= cOP
					(cAliRet)->D1_DOC		:= aNF[1]
					(cAliRet)->D1_SERIE		:= aNF[2]
					(cAliRet)->D1_FORNECE	:= aNF[3]
					(cAliRet)->D1_LOJA		:= aNF[4]
					(cAliRet)->D1_ITEM		:= aNF[5]
					(cAliRet)->TIPO			:= 'Produc'
					
					nCpoPad := Len(aNF) - Len(aCpoSD1)
					For nZ := (nCpoPad + 1) To Len(aNF)
						(cAliRet)->(&(aCpoSD1[nZ - nCpoPad])) := aNF[nZ]
					Next nZ
					(cAliRet)->(MsUnlock())
				EndIf
			Next nY
	 	Else
			aNF := RetUltNF(aAliVenda[nX],dDtIniCom,dDtFimCom,aCpoSD1)
			If Len(aNF) > 0
				Reclock(cAliRet, .T.)
				(cAliRet)->PROD_PA		:= aAliVenda[nX]
				(cAliRet)->PROD_COMP	:= " "
				(cAliRet)->QUANT		:= aNF[6]
				(cAliRet)->OP_PA		:= " "
				(cAliRet)->D1_DOC		:= aNF[1]
				(cAliRet)->D1_SERIE		:= aNF[2]
				(cAliRet)->D1_FORNECE	:= aNF[3]
				(cAliRet)->D1_LOJA		:= aNF[4]
				(cAliRet)->D1_ITEM		:= aNF[5]
				(cAliRet)->TIPO			:= 'Reven'	
				
				nCpoPad := Len(aNF) - Len(aCpoSD1)
				For nZ := (nCpoPad + 1) To Len(aNF)
					(cAliRet)->(&(aCpoSD1[nZ - nCpoPad])) := aNF[nZ]
				Next nZ
				(cAliRet)->(MsUnlock())
			EndIf
		EndIf
	Next nX
EndIf
Return cAliRet

// ---------------------------------------------------------------------------
/*/{Protheus.doc} RetOPCom
Lista todos os componentes que foram utilizados na produ玢o do produto acabado
da Ordem de Produ玢o. 
@author robson.ribeiro
@since 01/03/2016
@version 1.0
@param dDtIni,		data,	(Data inicial para Produ玢o)
@param dDtFim,		data,	(Data final para Produ玢o)
@param cOP,		character,	(C骴igo da Ordem de Produ玢o)
@return ${return}, ${Array contendo os componentes do PA da OP}
/*/
// ---------------------------------------------------------------------------
Static Function RetOPCom(dDtIni,dDtFim,cOP)

Local cFuncSubst	:= If(cDbType $ "ORACLE/POSTGRES","SUBSTR","SUBSTRING")
Local cCccusto		:= Criavar("B1_CCCUSTO",.F.)
Local cAliComp		:= GetNextAlias()
Local aRet			:= {}
Local aComps		:= {}
Local cQuery		:= ""
Local nRecur		:= 0
Local nQtdProd		:= 0
Local nX

cQuery := "SELECT SUM(CASE WHEN SD3.D3_CF LIKE ('DE%') THEN (SD3.D3_QUANT*-1) "
cQuery += "WHEN SD3.D3_CF LIKE ('RE%') THEN (SD3.D3_QUANT) ELSE 0 END) AS QUANTIDADE, SD3.D3_COD "
cQuery += "FROM "+ RetSqlName("SD3") +" SD3 JOIN "+ RetSqlName("SB1") +" SB1 "
cQuery += "ON SB1.B1_FILIAL = '"+ xFilial("SB1") +"' AND SB1.B1_COD = SD3.D3_COD AND SB1.D_E_L_E_T_ = ' ' "
cQuery += "WHERE SD3.D3_FILIAL = '"+ xFilial("SD3") +"' AND SD3.D_E_L_E_T_ = ' ' AND SD3.D3_ESTORNO = ' ' " 
cQuery += "AND SD3.D3_OP = '"+ cOP +"' AND (SD3.D3_CF LIKE ('RE%') OR SD3.D3_CF LIKE ('DE%')) "
cQuery += "AND "+ cFuncSubst +" (SB1.B1_COD,1,3) <> 'MOD' "
cQuery += "AND SB1.B1_CCCUSTO = '"+ cCccusto +"' AND SB1.D_E_L_E_T_ = ' ' "  
cQuery += "GROUP BY D3_COD ORDER BY SD3.D3_COD"
	
cQuery := ChangeQuery(cQuery)
dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliComp,.T.,.T.)

nQtdProd := RetQtdProd(cOP)
	
While !(cAliComp)->(Eof())
	If IsPI((cAliComp)->D3_COD,dDtIni,dDtFim)
		aComps := RetPICom(dDtIni,dDtFim,(cAliComp)->D3_COD,@nRecur)
		nRecur := 0
		
		For nX := 1 to Len(aComps)
			Aadd(aRet,{aComps[nX][1],(aComps[nX][2] * (cAliComp)->QUANTIDADE) / nQtdProd})
		Next nX
	Else
		Aadd(aRet,{(cAliComp)->D3_COD,(cAliComp)->QUANTIDADE / nQtdProd})
	EndIf
	(cAliComp)->(dbSkip())
EndDo

(cAliComp)->(dbCloseArea())

Return aRet

// ---------------------------------------------------------------------------
/*/{Protheus.doc} RetPICom
Lista todos os componentes que foram utilizados na produ玢o do produto 
intermedi醨io. Utiliza o FIFO para a busca da OP.
@author robson.ribeiro
@since 01/03/2016
@version 1.0
@param dDtIni,		data,		(Data inicial para Produ玢o)
@param dDtFim,		data,		(Data final para Produ玢o)
@param cComponente,	character,	(C骴igo do PI)
@param nRecur, 		num閞ico,	(Controlador de Recursividade)
@return ${return}, ${Array contendo os componentes do PI da OP}
/*/
// ---------------------------------------------------------------------------
Static Function RetPICom(dDtIni,dDtFim,cComponente,nRecur)

Local cFuncSubst	:= If(cDbType $ "ORACLE/POSTGRES","SUBSTR","SUBSTRING")
Local cCccusto		:= Criavar("B1_CCCUSTO",.F.)
Local cAliComp		:= GetNextAlias()
Local aRet			:= {}
Local aComps		:= {}
Local cQuery		:= ""
Local cOP			:= ""
Local nQtdProd		:= 0
Local nX

If nRecur < 99 // Controle de recursividade
	nRecur++
	cOP			:= RetLastOP(dDtIni,dDtFim,cComponente)
	nQtdProd	:= RetQtdProd(cOP)
	
	cQuery := "SELECT SUM(CASE WHEN SD3.D3_CF LIKE ('DE%') THEN (SD3.D3_QUANT*-1) "
	cQuery += "WHEN SD3.D3_CF LIKE ('RE%') THEN (SD3.D3_QUANT) ELSE 0 END) AS QUANTIDADE, SD3.D3_COD "
	cQuery += "FROM "+ RetSqlName("SD3") +" SD3 JOIN "+ RetSqlName("SB1") +" SB1 "
	cQuery += "ON SB1.B1_FILIAL = '"+ xFilial("SB1") +"' AND SB1.B1_COD = SD3.D3_COD AND SB1.D_E_L_E_T_ = ' ' "
	cQuery += "WHERE SD3.D3_FILIAL = '"+ xFilial("SD3") +"' AND SD3.D_E_L_E_T_ = ' ' AND SD3.D3_ESTORNO = ' ' " 
	cQuery += "AND SD3.D3_OP = '"+ cOP +"' AND (SD3.D3_CF LIKE ('RE%') OR SD3.D3_CF LIKE ('DE%')) "
	cQuery += "AND "+ cFuncSubst +" (SB1.B1_COD,1,3) <> 'MOD' "
	cQuery += "AND SB1.B1_CCCUSTO = '"+ cCccusto +"' AND SB1.D_E_L_E_T_ = ' ' "  
	cQuery += "GROUP BY D3_COD ORDER BY SD3.D3_COD"

	cQuery := ChangeQuery(cQuery)
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliComp,.T.,.T.)
		
	While !(cAliComp)->(Eof())
		If IsPI((cAliComp)->D3_COD,dDtIni,dDtFim)
			aComps := RetPICom(dDtIni,dDtFim,(cAliComp)->D3_COD,@nRecur)
			
			For nX := 1 to Len(aComps)
				Aadd(aRet,{aComps[nX][1],(aComps[nX][2] * (cAliComp)->QUANTIDADE) / nQtdProd})
			Next nX
		Else
			Aadd(aRet,{(cAliComp)->D3_COD,(cAliComp)->QUANTIDADE / nQtdProd})
		EndIf
		(cAliComp)->(dbSkip())
	EndDo
	
	(cAliComp)->(dbCloseArea())
	nRecur--
EndIf

Return aRet


// ---------------------------------------------------------------------------
/*/{Protheus.doc} IsPI
Verifica se o produto ?um Produto Intermedi醨io.
@author robson.ribeiro
@since 01/03/2016
@version 1.0
@param cProd,	character,	(C骴igo do Produto)
@param dDtIni,	data,		(Data inicial para Produ玢o)
@param dDtFim,	data,		(Data final para Produ玢o)
@return ${return}, ${L骻ico indicando se o produto ?ou n鉶 um PI}
/*/
// ---------------------------------------------------------------------------
Static Function IsPI(cProd,dDtIni,dDtFim)

Local cAliasPI		:= GetNextAlias()
Local cQuery		:= ""
Local lRet			:= .T.

cQuery := "SELECT MAX(SD3.D3_EMISSAO) AS PERIODO "
cQuery += " FROM "+ RetSqlName("SD3") +" SD3 "
cQuery += "WHERE SD3.D3_FILIAL = '"+ xFilial("SD3") +"' "
cQuery += "AND SD3.D_E_L_E_T_ = ' ' AND SD3.D3_ESTORNO = ' ' "
cQuery += "AND SD3.D3_CF IN ('PR0','PR1') AND SD3.D3_COD = '"+ cProd +"' " 
cQuery += "AND SD3.D3_EMISSAO <= '"+ DtoS(dDtFim) +"'"

cQuery := ChangeQuery(cQuery)
dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasPI,.T.,.T.)

If Empty((cAliasPI)->PERIODO)
	lRet := .F.
EndIf

(cAliasPI)->(DbCloseArea())

Return lRet


// ---------------------------------------------------------------------------
/*/{Protheus.doc} RetQtdProd
Retorna a quantidade j?producida de uma ordem de produ玢o.
@author robson.ribeiro
@since 01/03/2016
@version 1.0
@param cOP,		character,	(C骴igo da Ordem de Produ玢o)
@return ${return}, ${Quantidade Produzida da Ordem de Produ玢o}
/*/
// ---------------------------------------------------------------------------
Static Function RetQtdProd(cOP)

Local cFuncSubst	:= If(cDbType $ "ORACLE/POSTGRES","SUBSTR","SUBSTRING")
Local cCccusto		:= Criavar("B1_CCCUSTO",.F.)
Local cAliasPI		:= GetNextAlias()
Local cQuery		:= ""
Local nRet			:= 0

cQuery := "SELECT SUM(SD3.D3_QUANT) AS QUANTIDADE, SD3.D3_COD "
cQuery += "FROM "+ RetSqlName("SD3") +" SD3 JOIN "+ RetSqlName("SB1") +" SB1 "
cQuery += "ON SB1.B1_FILIAL = '"+ xFilial("SB1") +"' AND SB1.B1_COD = SD3.D3_COD AND SB1.D_E_L_E_T_ = ' ' "
cQuery += "WHERE SD3.D3_FILIAL = '"+ xFilial("SD3") +"' AND SD3.D_E_L_E_T_ = ' ' AND SD3.D3_ESTORNO = ' ' " 
cQuery += "AND SD3.D3_OP = '"+ cOP +"' AND SD3.D3_CF IN ('PR0','PR1') "
cQuery += "AND "+ cFuncSubst +" (SB1.B1_COD,1,3) <> 'MOD' "
cQuery += "AND SB1.B1_CCCUSTO = '"+ cCccusto +"' AND SB1.D_E_L_E_T_ = ' ' "  
cQuery += "GROUP BY D3_COD ORDER BY SD3.D3_COD"

cQuery := ChangeQuery(cQuery)
dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasPI,.T.,.T.)

If !Empty((cAliasPI)->QUANTIDADE)
	nRet := (cAliasPI)->QUANTIDADE
EndIf

(cAliasPI)->(DbCloseArea())

Return nRet

// ---------------------------------------------------------------------------
/*/{Protheus.doc} RetUltNF
Processa e identifica a ultima NF de Compra dentro de um per韔do. Utiliza o
conceito FIFO.
@author robson.ribeiro
@since 01/03/2016
@version 1.0
@param cProduto, character, (C骴igo do Produto)
@param dDtIniCom,	data,	(Data inicial para Compra)
@param dDtFimCom,	data,	(Data final para Compra)
@param aCpoSD1,		array,	(Campos da SD1 que devem ser retornados no TRB)
@return ${return}, ${Array com informa珲es da NF de Compra.}
/*/
// ---------------------------------------------------------------------------
Static Function RetUltNF(cProduto,dDtIniCom,dDtFimCom,aCpoSD1)

Local cAliNF		:= GetNextAlias()
Local aRet			:= {}
Local cQuery		:= ""
Local nX

cQuery := "SELECT D1_DTDIGIT, D1_DOC, D1_SERIE, D1_ITEM, D1_FORNECE, D1_LOJA, D1_QUANT "
For nX := 1 To Len(aCpoSD1)
	cQuery += ", " + aCpoSD1[nX]
Next nX
cQuery += " FROM "+ RetSqlName("SD1") +" SD1 JOIN "
cQuery += RetSqlName("SB1") +" SB1 ON SB1.B1_FILIAL = '"+ xFilial("SB1") +"' AND "
cQuery += "SB1.B1_COD = SD1.D1_COD WHERE SD1.D_E_L_E_T_ = ' ' AND SB1.D_E_L_E_T_ = ' ' AND " 
cQuery += "SD1.D1_FILIAL = '"+ xFilial("SD1") +"' AND SD1.D1_COD = '"+ cProduto +"' AND "
cQuery += "SD1.D1_DTDIGIT BETWEEN '"+ DtoS(dDtIniCom) +"' AND '"+ DtoS(dDtFimCom) +"' "
cQuery += "ORDER BY 1 DESC"
	
cQuery := ChangeQuery(cQuery)
dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliNF,.T.,.T.)
	
If !(cAliNF)->(Eof())
	Aadd(aRet,(cAliNF)->D1_DOC)
	Aadd(aRet,(cAliNF)->D1_SERIE)
	Aadd(aRet,(cAliNF)->D1_FORNECE)
	Aadd(aRet,(cAliNF)->D1_LOJA)
	Aadd(aRet,(cAliNF)->D1_ITEM)
	Aadd(aRet,(cAliNF)->D1_QUANT)
	For nX := 1 To Len(aCpoSD1)
		Aadd(aRet,(cAliNF)->(&(aCpoSD1[nX])))
	Next nX
EndIf

(cAliNF)->(dbCloseArea())

Return aRet

// ---------------------------------------------------------------------------
/*/{Protheus.doc} MontTRB
Realiza a montagem de Arquivo Tempor醨io com base nos campos que devem ser
retornados, basedo no aCpoSD1. 
@author robson.ribeiro
@since 01/03/2016
@version 1.0
@param cAliasTRB, character,	(Alias do Arquivo Tempor醨io)
@param aCpoSD1,		array,		(Campos da SD1 que devem ser retornados no TRB)
/*/
// ---------------------------------------------------------------------------
Static Function MontTRB(cAliasTRB,aCpoSD1)
Local oTable		:= NIL
Local nTamCod		:= TamSX3("B1_COD")[1]
Local aCampos		:= {}

cAliasTRB	:= GetNextAlias()

// Layout do Arquivo de Trabalho
AADD(aCampos,{"PROD_PA"		,"C",nTamCod					,0						})
AADD(aCampos,{"PROD_COMP"	,"C",nTamCod					,0						})
AADD(aCampos,{"QUANT"   		,"N",TamSX3("D3_QUANT")[1]	,TamSX3("D3_QUANT")[2]})
AADD(aCampos,{"OP_PA"   		,"C",TamSX3("D3_OP")[1]		,0						})
AADD(aCampos,{"TIPO"			,"C",6							,0					   	})
AADD(aCampos,{"D1_DOC"   	,"C",TamSX3("D1_DOC")[1]		,0						})
AADD(aCampos,{"D1_SERIE"   	,"C",TamSX3("D1_SERIE")[1]	,0						})
AADD(aCampos,{"D1_FORNECE"	,"C",TamSX3("D1_FORNECE")[1],0						})
AADD(aCampos,{"D1_LOJA"   	,"C",TamSX3("D1_LOJA")[1]	,0						})
AADD(aCampos,{"D1_ITEM"   	,"C",TamSX3("D1_ITEM")[1]	,0						})

aEval(aCpoSD1,{|x| aAdd(aCampos,{x,TamSX3(x)[3],TamSX3(x)[1],TamSX3(x)[2]})})

cAliasTRB := GetNextAlias()

oTable := FWTemporaryTable():New(cAliasTRB)
oTable:SetFields(aCampos)
oTable:AddIndex("01",{"PROD_PA","PROD_COMP"})
oTable:Create()

Return oTable

// ---------------------------------------------------------------------------
/*/{Protheus.doc} RetLastOP
Processa e identifica a ultima OP produzida dentro de um per韔do.
@author robson.ribeiro
@since 01/03/2016
@version 1.0
@param dDtIni,		data,	(Data inicial para Produ玢o)
@param dDtFim,		data,	(Data final para Produ玢o)
@param cProduto, character,	(C骴igo do produto)
@return ${return}, ${C骴igo da Ordem de Produ玢o}
/*/
// ---------------------------------------------------------------------------
Static Function RetLastOP(dDtIni,dDtFim,cProduto)

Local cAliOP		:= GetNextAlias()
Local cQuery		:= ""
Local cRet			:= ""

// Busca a ultima OP produzida dentro do Periodo
cQuery := "SELECT MAX(SD3.D3_EMISSAO) AS EMISSAO, MAX(SD3.D3_NUMSEQ) AS NUMSEQ, MAX(SD3.D3_OP) AS OP "
cQuery += "FROM "+ RetSqlName("SD3") +" SD3 JOIN "+ RetSqlName("SB1") +" SB1 ON SB1.B1_FILIAL = '"
cQuery += xFilial("SB1") + "' AND SB1.B1_COD = SD3.D3_COD "
cQuery += "WHERE SD3.D3_FILIAL = '"+ xFilial("SD3") +"' AND SD3.D_E_L_E_T_ = ' ' AND SD3.D3_ESTORNO = ' ' AND "
cQuery += "SD3.D3_EMISSAO BETWEEN '"+ DtoS(dDtIni) +"' AND '"+ DtoS(dDtFim) +"' AND "
cQuery += "SD3.D3_CF IN ('PR0','PR1') AND SD3.D3_COD = '"+ cProduto +"'"

cQuery := ChangeQuery(cQuery)
dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliOP,.T.,.T.)

If !Empty((cAliOP)->OP)
	cRet := (cAliOP)->OP
EndIf

(cAliOP)->(dbCloseArea())

Return cRet




