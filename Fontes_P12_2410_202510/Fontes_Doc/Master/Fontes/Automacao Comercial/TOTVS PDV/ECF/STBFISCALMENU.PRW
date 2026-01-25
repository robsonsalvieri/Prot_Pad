#INCLUDE	"STPOS.CH"
#INCLUDE	"FILEIO.CH"
#INCLUDE	"DIRECTRY.CH"
#INCLUDE 	"PARMTYPE.CH"
#INCLUDE	"AUTODEF.CH"
#INCLUDE	"STBFISCALMENU.CH"
#INCLUDE	"TOTVS.CH"

#DEFINE	F_NAME		1

/* -----------------------------------------------------------------------
	Evitar na declaração de static a chamada de funções que acessem 
	outros fontes, pois estava dando problema de falta da sigaloja.dll
	em outros modulos devido a chamada de uma função nesse fonte que 
	altera o MD5 dos campos da Nota
------------------------------------------------------------------------*/
Static	aDadosEcf	:= {}						// PAF-ECF: Salva dados do ECF, movimento por ecf é emitido com o ECF desligado
Static	cModPaf		:= "PROTHEUS"
Static	lHomolPaf	:= STBHomolPaf()
Static	aArqLstPaf	:= {}						// Armazena Relacao de Arquivos do PAF-ECF com o MD5  
Static	aAliquotas	:= {} 						// Array de Aliquotas // Tipo do Imposto, Indice, Aliquota
Static	lTotvsPdv	:= STFIsPOS()
Static	lAjstInfos	:= NIL

//--------------------------------------------------------

/*{Protheus.doc}STBFMImpEst
Realiza a Criação e a Gravação dos dados relacionados ao
Estoque para PAF-ECF.
@author  	Varejo
@version 	P11.8
@since   	03/09/2012
@return  	Nil
@obs     	LjxImpEst
@sample
*/
//--------------------------------------------------------
Function STBFMImpEst(cWSServer, lPOS, lSelEst, nHandle,;
					 dDataIni, dDataFim, lIncManual, lReducao,;
					 cPDV)
Local nTotRecno	:= 0
Local cConteudo                                  // Variavel Para a Foracao da Linha.
Local cTabela		:= ""                        //Arquivo
Local lRet			:= .F.                          //Retorno
Local lEstPerProd	:= .F.							//Verifica se selecinou estoque por produto
Local nX			:= 0                        // Contador 
Local aRetWs		:= {}							//Array contendo retorno do WebService
Local cNumFabEcf	:= ""                           //Numero de Fabricação
Local cMFAdic		:= ""                           //Memória adicional
Local cTipoEcf		:= ""
Local cMarcaEcf		:= ""
Local cModelEcf 	:= ""
Local cSeriePDV		:= ""
Local cDtEmissao	:= ""
Local cHrEmissao	:= ""
Local cRazaoSoc		:= ""
Local oItensProd	:= NIL							//Objeto do Client do WebService
Local aItens		:= {}
Local aRetPDV		:= {}
// Variaveis referentes a tela de seleção
Local oDlg 
Local oGpTela
Local oGpTipo   
Local oCodProd  
Local oProdutos
Local oBtAdd
Local oBtRemov 
Local oRbTpSel 
Local oBtnOK
Local oBtnCancel
Local oSayProd
Local cCodProd 	:= Space( TamSx3("B1_COD")[1] )
Local aProdutos	:= {{"",""}}
Local nTpSel 		:= 1   
Local lInterrogacao := .F.
Local nI		:= 0
Local nPagina	:= 0 //Paginas
Local cLastProd := "" //Ultimo Produto
Local lFim		:= .F. //Final de Arquivo
Local aTmp		:= {}
Local nTotReg	:= 0
Local lGeraE2	:= .F.
Local aRetVldE3	:= {}

Default lPOS		:= .F.
Default nHandle		:= 0
Default cWSServer	:= ""
Default lSelEst		:= .T. 
Default dDataIni	:= dDataBase 
Default dDataFim	:= dDataBase
Default lIncManual	:= .F.
Default lReducao	:= .F.

// ****** Executa a consulta no WebService *****
oWS := WsFrtPafEcf():New()
iIf(ExistFunc("LjWsGetAut"),LjWsGetAut(@oWS),Nil) //Monta o Header de Autenticação do Web Service

//Ajusta o caminho do servico
oWs:_URL := "http://"+cWSServer+"/FRTPAFECF.apw"

nPagina	:= Val(GetPvProfString("PAF-ECF","Registros_LstEstoque"	,"2900", GetClientDir()+"SIGALOJA.INI")) //Paginas
nTotReg	:= Val(GetPvProfString("PAF-ECF","Registros_TotLstEstoque"	,"5000", GetClientDir()+"SIGALOJA.INI"))

If nModulo == 12 .Or. lPOS
	cTabela := "SB1"
Else
	cTabela := "SBI"		
EndIf

If lSelEst
	oDlg := MSDIALOG():Create()
		oDlg:cName := "oDlg"
		oDlg:cCaption := "Estoque"
		oDlg:nLeft := 0
		oDlg:nTop := 0
		oDlg:nWidth := 700
		oDlg:nHeight := 530
		oDlg:lShowHint := .F.
		oDlg:lCentered := .T.
		
		oGpTela := TGROUP():Create(oDlg)
		oGpTela:cName := "oGpTela"
		oGpTela:cCaption := ""
		oGpTela:nLeft := 2
		oGpTela:nTop := 2
		oGpTela:nWidth := 690
		oGpTela:nHeight := 450
		oGpTela:lShowHint := .F.
		oGpTela:lReadOnly := .F.
		oGpTela:Align := 0
		oGpTela:lVisibleControl := .T.
		
		oGpTipo := TGROUP():Create(oDlg)
		oGpTipo:cName := "oGpTipo"
		oGpTipo:cCaption := "Tipo de Seleção"
		oGpTipo:nLeft := 9
		oGpTipo:nTop := 16
		oGpTipo:nWidth := 115
		oGpTipo:nHeight := 90
		oGpTipo:lShowHint := .F.
		oGpTipo:lReadOnly := .F.
		oGpTipo:Align := 0
		oGpTipo:lVisibleControl := .T.
		
		oRbTpSel := TRADMENU():Create(oDlg)
		oRbTpSel:cName := "oRbTpSel"
		oRbTpSel:nLeft := 18
		oRbTpSel:nTop := 40
		oRbTpSel:nWidth := 100
		oRbTpSel:nHeight := 100
		oRbTpSel:lShowHint := .F.
		oRbTpSel:Align := 0
		oRbTpSel:cVariable := "nTpSel"
		oRbTpSel:bSetGet := {|u| If(PCount()>0,nTpSel:=u,nTpSel) }
		oRbTpSel:lVisibleControl := .T.
		oRbTpSel:aItems  := {"Estoque Total","Estoque Parcial"} //"Estoque Total","Estoque Parcial"
		oRbTpSel:nOption := nTpSel
		oRbTpSel:bChange := {|| STBFMVlProd(nTpSel,@oCodProd,@cCodProd,@oProdutos)}
		
		oSayProd:= TSAY():Create(oDlg)
		oSayProd:cName := "oSayProd"
		oSayProd:cCaption := "Produto:" //"Produto: "
		oSayProd:nLeft := 150
		oSayProd:nTop := 20
		oSayProd:nWidth := 100
		oSayProd:nHeight := 16
		oSayProd:lShowHint := .F.
		oSayProd:lReadOnly := .F.
		oSayProd:Align := 0
		oSayProd:lVisibleControl := .T.
		oSayProd:lWordWrap := .F.
		oSayProd:lTransparent := .F.
		
		oCodProd:= TGET():Create(oDlg)
		oCodProd:cName := "oCodProd"
		oCodProd:nLeft := 195
		oCodProd:nTop := 18
		oCodProd:nWidth := 200
		oCodProd:nHeight := 20
		oCodProd:lShowHint := .F.
		oCodProd:Align := 0
		oCodProd:cVariable := "cCodProd"
		oCodProd:bSetGet := {|u| If(PCount()>0,cCodProd:=u,cCodProd) }
		oCodProd:lVisibleControl := .T.
		oCodProd:lPassword := .F.
		oCodProd:Picture := "@!"
		oCodProd:lHasButton := .F.
		oCodProd:cF3:= cTabela
		oCodProd:bWhen	 := {|| nTpSel == 2 }
		
		oBtAdd	:= TBtnBmp2():New( 18,400, 30, 20, "DOWN"  , /*<cResName2>*/, /*<cBmpFile1>*/, /*<cBmpFile2>*/, {|| STBFMAdd(cTabela,@oProdutos,@aProdutos,@cCodProd,@oCodProd) } , oDlg, "Adicionar" /*"Adicionar" <cMsg>*/,{ ||If(nTpSel==2,.T.,.F.) }, /*<.adjust.>*/, /*<.lUpdate.>*/ ) //"Mover para cima"
		oBtRemov:= TBtnBmp2():New( 18,430, 30, 20, "UP"  , /*<cResName2>*/, /*<cBmpFile1>*/, /*<cBmpFile2>*/, {|| STBFMRemov(@oProdutos,@aProdutos) } , oDlg, "Remover"  /*"Remover" <cMsg>*/, { ||If(nTpSel==2,.T.,.F.) }/*{|| oListVar:nAt > 1 }*/ /*<{uWhen}>*/, /*<.adjust.>*/, /*<.lUpdate.>*/ ) //"Mover para cima"
		
		oProdutos := TWBrowse():New( 20/*<nRow>*/, 75/*<nCol>*/, 265 /*<nWidth>*/, 200/*<nHeight>*/, /*[\{|| \{<Flds> \} \}]*/, {"Código","Descrição"} ;
					/*{"Código","Descrição"}*/ /*[\{<aHeaders>\}]*/, {70, 180}/*[\{<aColSizes>\}]*/, oDlg/*<oDlg>*/, /*<(cField)>*/, /*<uValue1>*/, /*<uValue2>*/,;
					/*[<{uChange}>]*/, /*[\{|nRow,nCol,nFlags|<uLDblClick>\}]*/, /*[\{|nRow,nCol,nFlags|<uRClick>\}]*/, /*<oFont>*/, /*<oCursor>*/, /*<nClrFore>*/,;
					 /*<nClrBack>*/, /*<cMsg>*/, /*<.update.>*/, /*<cAlias>*/, .T./*<.pixel.>*/, /*<{uWhen}>*/, /*<.design.>*/, /*<{uValid}>*/, /*<{uLClick}>*/, /*[\{<{uAction}>\}]*/ ) //
		oProdutos :SetArray(aProdutos)
		oProdutos :bLine := {|| { aProdutos[oProdutos:nAt,1], aProdutos[oProdutos:nAt,2] } }
		
		oBtnOK:= TButton():Create(oDlg)
		oBtnOK:cName := "oBtnOK"
		oBtnOK:cCaption := "OK" //"OK"
		oBtnOK:nLeft := 450
		oBtnOK:nTop := 460
		oBtnOK:nWidth := 90
		oBtnOK:nHeight := 25
		oBtnOK:lShowHint := .F.
		oBtnOK:lReadOnly := .F.
		oBtnOK:Align := 0
		oBtnOK:bAction := {|| lRet := .T., oDlg:End() }
		
		oBtnCancel:= TButton():Create(oDlg)
		oBtnCancel:cName := "oBtnCancel"
		oBtnCancel:cCaption := "Cancelar" //"Cancelar"
		oBtnCancel:nLeft := 550
		oBtnCancel:nTop := 460
		oBtnCancel:nWidth := 90
		oBtnCancel:nHeight := 25
		oBtnCancel:lShowHint := .F.
		oBtnCancel:lReadOnly := .F.
		oBtnCancel:Align := 0
		oBtnCancel:bAction := {|| lRet := .F., oDlg:End() }
		
		oDlg:lEscClose := .F.
	oDlg:Activate()

Else
	lRet := .T.
EndIF

If lRet	
	
	If Len(aProdutos) > 0 .AND. !Empty(AllTrim(aProdutos[1][1]))
		lEstPerProd	:= .T.
	EndIf
		
	STFMessage("STBFMImpEst1", "RUN",STR0004 + ' LstVendEst ',{||lRet := oWs:LstVendEst(dDataIni, dDataFim, cEmpAnt , cFilAnt , lHomolPaf)}) // "Executando consulta na retaguarda"
	STFShowMessage("STBFMImpEst1")

	If (lRet == Nil) .OR. (!lRet)
		STFMessage("STBFMImpEst2", "STOP", STR0005 + ":LstVendEst") //"Erro na execução do WebService"
		STFShowMessage("STBFMImpEst2")
		LjGrvLog(Nil, GetWSCError() )
		Return .F.
	Else
		aRetEst := aClone(oWs:oWsLstVendEstResult:oWsLstEstInfo)
		oWs:RESET()
		
		If Len(aRetEst) > 0
			If lHomolPaf .And. !aRetEst[1]:lPAFMD5OK 
				lInterrogacao := .T.
			Else
				lInterrogacao := .F.
			EndIf
			
			If aRetEst[1]:lIncManual
				IncManual := .T.
			EndIf

			cDtEmissao := PadR(DTOS(aRetEst[1]:dEmissao),8)
			cHrEmissao := aRetEst[1]:cHora			
		
			STFMessage("STBFMImpEst3", "RUN", STR0004,{||lRet := oWs:LstInfoPDV(cEmpAnt,cFilAnt, cPDV)}) // "Executando consulta na retaguarda"
			STFShowMessage("STBFMImpEst3")
								
			If (lRet == Nil) .OR. (!lRet)
				STFMessage("STBFMImpEst4", "STOP", STR0005 + ":LstInfoPDV") //"Erro na execução do WebService"						
				STFShowMessage("STBFMImpEst4")
				LjGrvLog(Nil, GetWSCError() )
				Return .F.
			Else
				STBPDVBusca(oWs:oWsLstInfoPDVResult:oWsLstInfoPDV, @aRetPDV)
				(nI := aScan(aRetPDV, { |u| AllTrim(u:cSerPDV) == AllTrim(aRetEst[1]:cSerPDV)}))
			EndIf
		EndIf
	EndIf
	
	//o E2 somente é gerado para o primeiro ECF que mandou a RedZ, os outros não mostra o E2
	If !lReducao
		lGeraE2 := .T.
	Else
		lGeraE2 := StbVldE2Paf(lPOS,.F.,"")[1]
	EndIf
	
	If lGeraE2
		
		If lEstPerProd
			oWs:oWsAProdutos:oWsACodProduto := FRTPAFECF_ARRAYOFCODPROD():NEW()
			
			For nX := 1 to Len(aProdutos)
				oItensProd := FRTPAFECF_CODPROD():NEW()
				oItensProd:cxProduto := aProdutos[nX][1]
				
				Aadd( aItens , oItensProd )
			Next nX
			
			oWs:oWsAProdutos:oWsACodProduto:oWSCODPROD := AClone(aItens)
		Else
			oWs:oWsAProdutos:oWsACodProduto := NIL
		EndIf

		CursorWait()
		
		//Executa a Paginação do WebService
		Do While !lFim
			
			STFMessage("STBFMImpEst5", "RUN", STR0004 + " LstEstoque - " + cLastProd,{||lRet :=;
			 				oWs:LstEstoque(cEmpAnt , cFilAnt , /*aProdutos*/ , lHomolPaf,;
			 				.F. /*!lSelEst*/, nPagina, cLastProd )}) // "Executando consulta na retaguarda"
			STFShowMessage("STBFMImpEst5")
			
			If (lRet == Nil) .OR. (!lRet)
				STFMessage("STBFMImpEst6", "STOP", STR0005 + "[LstEstoque]") //"Erro na execução do WebService"
				STFShowMessage("STBFMImpEst6")
	
				lFim := .T.
				lRet := .F.
				Loop
			Else
				aTmp := aClone(oWs:oWsLstEstoqueResult:oWsEstList)
				aEval(aTmp, { |e| nX := nX + 1, IIF(nTotReg == 0 .OR. nX <= nTotReg,   aAdd(aRetWS, e), ) }) //Insere os dados do Produto
				If len(aTmp) > 0
				   cLastProd := aTail(aTmp):cCodigo
					lFim := aTail(aTmp):lFimLista .or. (nTotReg > 0 .AND. nX > nTotReg) 
				EndIf
				aTmp := NIL
				oWs:RESET()
			 
				If nPagina == 0
					lFim := .T.
				EndIf			
			EndIf
		EndDo
	
		CursorArrow()
	
		oWs:RESET()
		nX := 0
		If !Len(aRetWs) > 0
			If lPos
				STFMessage("STBFMImpEst8", "STOPPOPUP", STR0006) //"Nenhum produto encontrado."
				STFShowMessage("STBFMImpEst8")
			Else
				MsgStop(STR0006)
			EndIf
			lRet := .F.
		EndIf
	Else
		lRet := .T.
    EndIf
                     
	If lRet
		If nHandle > 0
			If nI == 0
				STBDadosEcf(lPOS)
				STBGetInfEcf("24",@cMFAdic)
				STBGetInfEcf("25",@cTipoEcf)
				STBGetInfEcf("26",@cMarcaEcf)
				STBGetInfEcf("27",@cModelEcf)
				cNumFabEcf := Iif( lPos , STFGetStat("SERPDV") , LjGetStation("SERPDV"))
			Else
				cMFAdic :=  STBGetPDVInfo("24", aRetPDV[nI]:cECFInfo )
				cTipoEcf := STBGetPDVInfo("25", aRetPDV[nI]:cECFInfo )
				cModelEcf := STBGetPDVInfo("27", aRetPDV[nI]:cECFInfo )
				cMarcaEcf := aRetPDV[nI]:cImpFisc
				cNumFabEcf:= aRetEst[1]:cSerPDV
			EndIf
			
			nX := At(" ",AllTrim(cMarcaEcf))
			If nX > 1
				cMarcaEcf := SubStr(cMarcaEcf,1,nX-1)
			EndIf			
			cRazaoSoc := PADR( SM0->M0_NOMECOM, 50 ) 	// Razao Social
			cSeriePDV := PADR( cNumFabEcf , 20 )		// Numero de Serie

			If lHomolPaf
				For nX := 1 to Len(aRetWs)				
					If aRetWs[nX]:lIncManual 
						cRazaoSoc := StrTran( PADR( SM0->M0_NOMECOM, 50 ), " " ,"?") 	// Razao Social
						lIncManual := .T.
					EndIf
				Next nX
		   	EndIf
		
			If lInterrogacao
				cModelEcf := StrTran(PADR(cModelEcf,20) ," ","?")
			Else
				cModelEcf := PADR(cModelEcf,20)
			EndIf
			
			aRetVldE3 := StbVldE3Paf(lPos,.F.,'',dDataFim,@cSeriePDV,@cMFAdic,@cTipoEcf,@cMarcaEcf,@cModelEcf,@cDtEmissao,@cHrEmissao)
			
			If !lIncManual
				lIncManual := aRetVldE3[1][2] .Or. aRetVldE3[1][3]
			EndIf 
			
			For nX := 1 To   Len(aRetWs)
				If aRetWs[nX]:nQtdeAtu <> 0
					cConteudo := "E2"
					cConteudo += PADR(aRetWs[nX]:cCnpj, 14) // CNPJ	
	  
					If !Empty(aRetWs[nX]:cCodBar)					 
						cConteudo += PADR( aRetWs[nX]:cCodBar , 14 )
					Else
						cConteudo += PADR( aRetWs[nX]:cCodigo, 14 )
					EndIf
	
					cConteudo += PADR( aRetWs[nX]:cDescricao , 50 ) 		// Descricao
					
					//Unidade - qdo há alteração no banco este campo deve demonstrar a alteração
					If lHomolPaf		
						If !aRetWs[nX]:lIncManual .And. aRetWs[nX]:lPAFMD5OK .And. aRetVldE3[1][1] .And. !aRetVldE3[1][2] .And. !aRetVldE3[1][3]								
							cConteudo += PADR( aRetWs[nX]:cUM, 6 )
						Else
							cConteudo += StrTran(PADR( aRetWs[nX]:cUM , 6 ) ," ","?")
							If !lIncManual 
								lIncManual := aRetVldE3[1][2] .Or. aRetVldE3[1][3]
							EndIf
						EndIf
						
					ElseIf !lHomolPaf .OR. aRetWs[nX]:lPAFMD5OK 
						cConteudo += PADR( aRetWs[nX]:cUM, 6 )
					Else
						cConteudo += StrTran(PADR( aRetWs[nX]:cUM , 6 ) ," ","?") 	
					EndIf
					
					cConteudo	+= If(aRetWs[nX]:nQtdeAtu < 0,"-","+")	//Mensuração do estoque			
					cQATU	:= StrZero(Abs(aRetWs[nX]:nQtdeAtu), TamSx3("B2_QATU")[1],3) //Colocado o TamSx3 para impedir vir com '***', qdo qtde maior que 9 caracteres 
					cQATU	:= StrTran(StrTran(cQATU,"."),",")
					cConteudo += PadL(Substr(cQATU,Len(cQATU)-9,9), 9, "0") // Quantidade em estoque	
					cConteudo += CHR(13) + CHR(10)
					nTotRecno++ // contador de registros
					FWRITE( nHandle, cConteudo, LEN( cConteudo ) )
				EndIf
			Next nX
				
			If Len(aRetEst) > 0 .And. !aRetVldE3[1][2] //Deleção Manual
				cConteudo := "E3"
				cConteudo += cSeriePDV	//Numero de fabricação do ECF
				cConteudo += PADR( cMFAdic , 1 )	//Letra indicativa de MF adicional
				cConteudo += PADR( cTipoEcf, 7 )	//Tipo de ECF
				cConteudo += PADR( cMarcaEcf, 20 )	//Marca do ECF
				
				If lHomolPaf .And. (!aRetVldE3[1][1] .OR. aRetVldE3[1][3])
					cConteudo += StrTran(Padr( cModelEcf, 20 )," ","?")	//Modelo do ECF
				Else
					cConteudo += Padr( cModelEcf, 20 )	//Modelo do ECF
				EndIf
								
				cConteudo += cDtEmissao // data do estoque
				
				cHrEmissao := AllTrim(StrTran(cHrEmissao,":"))
				If Len(cHrEmissao) <> 6
					cHrEmissao += "00"
				EndIf
				
				If lHomolPaf .And. !lIncManual 
					lIncManual := aRetVldE3[1][2] .Or. aRetVldE3[1][3]
				EndIf
				
				cConteudo += cHrEmissao //Hora do estoque
				cConteudo += CHR(13) + CHR(10)
				FWRITE( nHandle, cConteudo, LEN( cConteudo ) )
			EndIf

		EndIf
	EndIf
EndIf

Return Nil
				
//--------------------------------------------------------
/*{Protheus.doc}STBFMVlProd
Valid para atualizar o objeto oProdutos.

@author  	Varejo
@version 	P11.8
@since   	03/09/2012
@return  	Nil
@obs     	LjxVlProd
@sample
*/
//--------------------------------------------------------
Static Function STBFMVlProd(nTpSel,oCodProd,cCodProd,oProdutos)
Local lRet := .F.

cCodProd  := Space( TamSx3("B1_COD")[1] )
If nTpSel == 1
	oProdutos:SetFocus()
Else
	oCodProd:SetFocus()
EndIf	

Return lRet

//--------------------------------------------------------
/*{Protheus.doc}STBFMAdd
Adiciona o produto selecionado do objeto oProdutos

@author  	Varejo
@version 	P11.8
@since   	03/09/2012
@return  	Nil
@obs     	LjxDAdd
@sample
*/
//--------------------------------------------------------
Static Function STBFMAdd(cTabela,oProdutos,aProdutos,cCodProd,oCodProd)
Local lRet		:= .T.
Local aProd  	:= aClone(aProdutos) 
Local lVerif 	:= .F.  
Local cPrefixo 	:= SubStr(cTabela,2,2)

If !Empty(Alltrim(cCodProd))

	If lRet .AND. Len( aProd )== 1 .AND. Empty(aProd[1][1])
		aProd	:=	{}
	EndIf

	If lRet 
		(cTabela)->( DbSetOrder(1) )
		If (cTabela)->( DbSeek(xFilial(cTabela)+cCodProd) )
	
			lVerif :=  Ascan( aProd , {|x| x[1]== cCodProd} ) > 0 		
			If !lVerif
				Aadd( aProd, { cCodProd, (cTabela)->(&(cPrefixo + "_DESC")) } )
			Else
				STFMessage("STBFMAdd", "POPUP",STR0007)  //"Produto já adicionado"
				STFShowMessage("STBFMAdd")
			EndIf
			aProdutos:=aClone(aProd)
			oProdutos:SetArray(aProdutos)
			oProdutos:bLine := {|| { aProdutos[oProdutos:nAt,1], aProdutos[oProdutos:nAt,2] } }	
			oProdutos:Refresh() 
		
			cCodProd := space(TamSx3("B1_COD")[1])
		   	oCodProd:Refresh()	   
		Else
			STFMessage("STBFMAdd", "POPUP",STR0008)  //Produto não encontrado"
			STFShowMessage("STBFMAdd")
		EndIf
	EndIf
Else
	STFMessage("STBFMAdd", "POPUP",STR0009) //"Informe um produto."
	STFShowMessage("STBFMAdd")
	cCodProd := Space(TamSx3("B1_COD")[1])
   	oCodProd:Refresh()	  
Endif

Return lRet

//--------------------------------------------------------
/*{Protheus.doc}STBFMRemov
Remove o produto selecionado do objeto oProdutos

@author  	Varejo
@version 	P11.8
@since   	02/08/2013
@return  	Nil
@obs     	LjxDRemov
@sample
*/
//--------------------------------------------------------
Static Function STBFMRemov(oProdutos,aProdutos)
Local lRet := .T.
Local aProd := aClone(aProdutos)

If Len( aProd )== 1 .AND. Empty(aProd[oProdutos:nAt,1])
	 lRet := .F.
Endif 

If lRet
	aDel(aProd,oProdutos:nAt)
	aProdutos := {}

	ASize(aProd, Len(aProd)-1)	
	If Len( aProd ) == 0
		aProdutos := { {"",""} }
	Else
		aProdutos := aClone(aProd)	
	Endif
	
	oProdutos :SetArray(aProdutos)
	oProdutos :bLine := {|| { aProdutos[oProdutos:nAt,1], aProdutos[oProdutos:nAt,2] } }	
	oProdutos :Refresh()
EndIf

Return lRet 

//--------------------------------------------------------
/*/{Protheus.doc}STBFMMeiPgto
Realiza a impressao de um relatorio gerencial onde passa a
ser Movimento por ECF para o PAF-ECF.
@author  	Varejo
@version 	P11.8
@since   	03/09/2012
@return  	Nil
@obs     	LjxMeiPgto
@sample
/*/
//--------------------------------------------------------
FUNCTION STBFMMeiPgto( 	dDataIni, dDataFim, lPOS, 		cPDV, ;
						cWSServer, lIncManual, nHandle, lReducao,;
						lAllPDV )

Local aArea			:= GetArea()			// Armazena o Status da tabela atual
Local oWs			:= WsFrtPafEcf():New() 
Local cConteudo		:= ""
Local nPos			:= 0 
Local nX			:= 0 
Local nY			:= 0
Local nI			:= 0
Local nPosData		:= 0
Local aTextoImp		:= {}  //Array de 4 Posições que trara : Data , Forma Pagto , Tipo Doc , Valor
Local cData			:= DtoC(dDataBase)
Local aTotais		:= {{},{}}
Local aPrinter		:= {}
Local aPDV			:= {""}
Local cSimbMoeda	:= ""   
Local cTipoDoc		:= ""
Local cForma		:= ""
Local aDatVendas	:= {}

Default cPDV		:= ""
Default lIncManual	:= .F. 
Default cWSServer	:= "" 
Default nHandle		:= 0  
Default lReducao	:= .f.

If !lAllPDV
	If lPOS
		cSimbMoeda	:= SuperGetMV( "MV_SIMB" + Str( STBGetCurrency(),1 ) )
	
		aPrinter := STFFireEvent( ProcName(0) , "STGetPDV" , aPDV )		
		If ValType(aPrinter) <> "A" .OR. Len(aPrinter) == 0 .OR. aPrinter[1] <> 0 .OR. Len(aPDV) < 1     
			STFMessage("STBFMGerFile1", "STOP", STR0067)	//"Erro ao pegar o número do PDV após a impressão do pedido. Verifique o ECF."
			STFShowMessage("STBFMGerFile1")
		Else
			cPDV := aPDV[1]
		EndIf
		
		cWSServer	:= AllTrim(STFGetStat("WSSRV")) 
	Else 
		cWSServer	:= AllTrim(LjGetStation("WSSRV"))
		cSimbMoeda:= SuperGetMV("MV_SIMB1")
		cPDV := Space(TamSX3("L1_PDV")[1])   // Armazena o numero do PDV
		If IFPegPDV(nHdlECF, @cPDV) <> 0 
			STFMessage("STBFMMeiPgto1", "STOP",STR0010)//"Erro ao conectar com a Impressora Fiscal."
			STFShowMessage( "STBFMMeiPgto1")
			LjGrvLog(Nil, GetWSCError() )
			Return .F.
		EndIf
	EndIf 
EndIf

oWs:_URL	:= "http://" + cWSServer + "/FRTPAFECF.apw"
iIf(ExistFunc("LjWsGetAut"),LjWsGetAut(@oWS),Nil) //Monta o Header de Autenticação do Web Service

aDatVendas := STBPerVendas(dDataIni, dDataFim)
For nI := 1 to Len(aDatVendas)	

	//³Executa o web service³
	STFMessage("STBFMMeiPgto2", "RUN", STR0004 + "-> Metodo LstMePagto",{||lRet := oWs:LstMePagto(aDatVendas[nI][1],aDatVendas[nI][2],cPDV,;
											cEmpAnt,cFilAnt,lHomolPaf, .T.,.F.)}) //"Executando consulta na retaguarda"
	STFShowMessage("STBFMMeiPgto2")
	
	//Segundo o Ato Cotepe deve estar agrupado por : Dia + Forma de Pagto(Dinheiro, Cheque, CC, CD, etc) + Tipo De doc( CF, NF, CNF, etc)
	For nX := 1 to Len(oWs:oWsLstMePagtoRESULT:oWsMeiPgtList) 
	
		If oWs:oWsLstMePagtoRESULT:oWsMeiPgtList[nX]:lIncManual 
			lIncManual := .T.
		EndIf 
		
		For nY := 1 to Len(oWs:OWSLSTMEPAGTORESULT:OWSMEIPGTLIST[nX]:OWSDADOSPAG:OWSPAGLIST)
			If Len(aTextoImp) > 0
				nPosData := aScan(aTextoImp,{ |x| AllTrim(x[1]) == AllTrim(DtoC(oWs:oWsLstMePagtoRESULT:oWsMeiPgtList[nX]:dEmissao)) })
			EndIf
									
			If nPosData == 0
									
				cTipoDoc := space(1)
						    
	    		If AllTrim(oWs:oWsLstMePagtoRESULT:oWsMeiPgtList[nX]:oWsDadosPag:oWsPagList[nY]:cTipoDoc) == "Nota Fiscal"
					cTipoDoc := "3"
				ElseIf AllTrim(oWs:oWsLstMePagtoRESULT:oWsMeiPgtList[nX]:oWsDadosPag:oWsPagList[nY]:cTipoDoc) == "Cupom Fiscal"
					cTipoDoc := "1"
				ElseIf AllTrim(oWs:oWsLstMePagtoRESULT:oWsMeiPgtList[nX]:oWsDadosPag:oWsPagList[nY]:cTipoDoc) == "Documento Não Fiscal"
					cTipoDoc := "2"
				EndIf
					
				AAdd( aTextoImp , {	AllTrim(DtoC(oWs:oWsLstMePagtoRESULT:oWsMeiPgtList[nX]:dEmissao))								,;
										AllTrim(oWs:oWsLstMePagtoRESULT:oWsMeiPgtList[nX]:oWsDadosPag:oWsPagList[nY]:cDescTpPag)	,;
										AllTrim(oWs:oWsLstMePagtoRESULT:oWsMeiPgtList[nX]:oWsDadosPag:oWsPagList[nY]:cTipoDoc) 		,;
										oWs:oWsLstMePagtoRESULT:oWsMeiPgtList[nX]:oWsDadosPag:oWsPagList[nY]:nValor				   ,;
										cTipoDoc,;
										( !lHomolPaf .OR. oWs:oWsLstMePagtoRESULT:oWsMeiPgtList[nX]:oWsDadosPag:oWsPagList[nY]:LPAFMD5OK)	} )
			Else
				cData	:= AllTrim(DtoC(oWs:oWsLstMePagtoRESULT:oWsMeiPgtList[nX]:dEmissao))
				cForma	:= AllTrim(oWs:oWsLstMePagtoRESULT:oWsMeiPgtList[nX]:oWsDadosPag:oWsPagList[nY]:cDescTpPag)
				cTipoDoc :=  AllTrim(oWs:oWsLstMePagtoRESULT:oWsMeiPgtList[nX]:oWsDadosPag:oWsPagList[nY]:cTipoDoc)
				nPosData := aScan(aTextoImp,{ |x| 	AllTrim(x[1]) == cData .and. AllTrim(x[2]) == cForma .AND. AllTrim(x[3]) == cTipoDoc })
					
				If nPosData > 0
			
					aTextoImp[nPosData][4] += oWs:oWsLstMePagtoRESULT:oWsMeiPgtList[nX]:oWsDadosPag:oWsPagList[nY]:nValor   
					aTextoImp[nPosData][6] := aTextoImp[nPosData][6] .AND. ;
					 							( !lHomolPaf .OR. oWs:oWsLstMePagtoRESULT:oWsMeiPgtList[nX]:oWsDadosPag:oWsPagList[nY]:LPAFMD5OK)
					
				Else//If (nPosFormaPgto = 0) .OR. (nPosTipDoc = 0)
					cTipoDoc := space(1)
		    		If AllTrim(oWs:oWsLstMePagtoRESULT:oWsMeiPgtList[nX]:oWsDadosPag:oWsPagList[nY]:cTipoDoc) == "Nota Fiscal"
						cTipoDoc := "3"
					ElseIf AllTrim(oWs:oWsLstMePagtoRESULT:oWsMeiPgtList[nX]:oWsDadosPag:oWsPagList[nY]:cTipoDoc) == "Cupom Fiscal"
						cTipoDoc := "1"
					ElseIf AllTrim(oWs:oWsLstMePagtoRESULT:oWsMeiPgtList[nX]:oWsDadosPag:oWsPagList[nY]:cTipoDoc) == "Documento Não Fiscal"
						cTipoDoc := "2"
					EndIf
			
					AAdd( aTextoImp , {	AllTrim(DtoC(oWs:oWsLstMePagtoRESULT:oWsMeiPgtList[nX]:dEmissao))							,;
											AllTrim(oWs:oWsLstMePagtoRESULT:oWsMeiPgtList[nX]:oWsDadosPag:oWsPagList[nY]:cDescTpPag)	,;
											AllTrim(oWs:oWsLstMePagtoRESULT:oWsMeiPgtList[nX]:oWsDadosPag:oWsPagList[nY]:cTipoDoc) 		,;
											oWs:oWsLstMePagtoRESULT:oWsMeiPgtList[nX]:oWsDadosPag:oWsPagList[nY]:nValor					,;
											cTipoDoc,;
											( !lHomolPaf .OR. oWs:oWsLstMePagtoRESULT:oWsMeiPgtList[nX]:oWsDadosPag:oWsPagList[nY]:LPAFMD5OK) } )							
				EndIf						
			EndIf
			
			// Totaliza formas de pagamento
			nPos := aScan(aTotais[1],AllTrim(oWs:oWsLstMePagtoRESULT:oWsMeiPgtList[nX]:oWsDadosPag:oWsPagList[nY]:cDescTpPag))
			If nPos == 0
				AAdd(aTotais[1],AllTrim(oWs:oWsLstMePagtoRESULT:oWsMeiPgtList[nX]:oWsDadosPag:oWsPagList[nY]:cDescTpPag))
				AAdd(aTotais[2],oWs:oWsLstMePagtoRESULT:oWsMeiPgtList[nX]:oWsDadosPag:oWsPagList[nY]:nValor)
			Else
				aTotais[2][nPos] += oWs:oWsLstMePagtoRESULT:oWsMeiPgtList[nX]:oWsDadosPag:oWsPagList[nY]:nValor
			EndIf	
		Next nY						
	Next nX
	
	oWs:Reset()
Next nI

//Realiza a gravação do arquivo
If nHandle > 0
	For nX := 1 to Len(aTextoImp)
	    cConteudo := "A2" //Tipo de Registro 02 - 01/02 X
	    cConteudo += DtoS(CtoD(aTextoImp[nX][1]))    //Data 08 - 03/10 YYYYMMDD 
	    If (!lReducao	.AND. lHomolPAF) .AND.  !aTextoImp[nX][6]
	    	cConteudo += StrTran(PadR(aTextoImp[nX][2],25), " " , "?")
	    Else
	    	cConteudo += PadR(aTextoImp[nX][2],25)   //Meio de Pagamento 25 - 11/35 X
	    EndIf
	    cConteudo += aTextoImp[nX][5] //Codigo do Tipo de documento 01 - 36/36 X
	    cConteudo += StrTran(StrZero(aTextoImp[nX][4],13,2),".") + CHR(13) + CHR(10) //Valor 12 - 37/48 N + CRLF
	    
	    FWRITE( nHandle, cConteudo, LEN( cConteudo ) )	
    Next
EndIf

oWs := FreeObj( oWs )
RestArea( aArea )

Return .T.

//--------------------------------------------------------
/*/{Protheus.doc}STBFMMenAbrECF
Abre comunicao com a impressora qdo o menu fiscal for
executado pelo menu do protheus.
@author  	Varejo
@version 	P11.8
@since   	03/09/2012
@return  	.T. se conseguiu reposicionar.
@obs       	LjxMenAbrECF
@sample		NIL
/*/
//--------------------------------------------------------
Static Function STBFMMenAbrECF(cPortaMenu, lPOS)
Local nRet		:= 0				
Local cImpMenu	:= ""
Local lRetPrint	:= .T.
Local lRet		:= .T.
Local nECFHdl	:= -1

Default lPos	:= .F.

If Empty(cEstacao)
	Help(" ",1,"NOESTACAO")
	cEstacao := "001"
EndIf
DbSelectArea("SLG")
If !DbSeek(xFilial("SLG")+cEstacao)
	Help(" ",1,"NOESTACAO")
	lRet := .F.
EndIf

If lRet 

	If lPos
		cImpMenu	:= STFGetStation("IMPFISC")
		cPortaMenu	:= STFGetStation("PORTIF")
		nECFHdl		:= STWOpenCom(cImpMenu,cPortaMenu,.T.) //Abertura da Impressora Fiscal 
	Else
		cImpMenu	:= LjGetStation("IMPFISC") 
		cPortaMenu	:= LjGetStation("PORTIF")
		nHdlECF		:= IFAbrir(cImpMenu, cPortaMenu) //Abertura da Impressora Fiscal
		nECFHdl		:= nHdlECF //Passa o conteúdo da variável publica para a local
	EndIf

	If nECFHdl == -1
		STFMessage("STBFMMenAbrECF1", "STOP", STR0010 + AllTrim(cImpMenu) + STR0018 +cPortaMenu+".") //"Erro ao conectar com a Impressora Fiscal "#" na porta " 
		STFShowMessage("STBFMMenAbrECF1")		
		If !lHomolPaf
			lRet := .F.
		EndIf
	EndIf
		
	If lRet
		If lPos
			lRetPrint := STBOpenECF()
			nRet := IIf(lRetPrint,0,-1)
		Else
			nRet := IFAbrECF(nECFHdl)
		EndIf
			
		If nRet <> 0
			If lHomolPaf //no Ato Cotepe 01.13 deve permitir acesso ao sistema mesmo sem comunicação com o ECF
				STFMessage("STBFMMenAbrECF2", "STOPPOPUP", STR0019) //"Sem comunicação com o ECF! Vendas não estão acessíveis."
		   		STFShowMessage("STBFMMenAbrECF2")
			Else
				// "Não consegui abrir o ECF. É possível que esteja desligado. Erro: " ###, "Atenção"
				STFMessage("STBFMMenAbrECF3", "STOP", STR0020) //"Não foi possivel abrir o ECF."
		   		STFShowMessage("STBFMMenAbrECF3")
		   		
	   			If nECFHdl >= 0
	   				If lPos
	   					STFFireEvent( ProcName(0), "STCloseCom", {cPortaMenu } )
	   				Else
	   					IFFechar( nECFHdl, cPortaMenu )
	   				EndIf
				EndIf
				lRet := .F.
			EndIf
		EndIf
	EndIf
EndIf

Return lRet

//--------------------------------------------------------
/*/{Protheus.doc}STBFMGerPath
Realiza o retorno do caminho onde serão gerados os arquivos
para o PAF-ECF.
@author  	Varejo
@version 	P11.8
@since   	03/09/2012
@return  	Logico
@obs     	LjxGerPath
/*/
//--------------------------------------------------------
FUNCTION STBFMGerPath( cPath )
Local lRetValue := .T.

DEFAULT cPath := ""        	// Define o Caminho onde serao gravados os arquivos do PAF-ECF

// Monta o path do arquivo de acordo com o SIGALOJA.INI
cPath := GetPvProfString("paf-ecf", "patharquivo", "C:\TOTVS PAF-ECF", GetClientDir() + "SIGALOJA.INI") 
cPath := AllTrim(cPath)

If cPath == ""
	lRetValue := .F. 
Else
    If SubStr(cPath, Len(cPath), 1) <> "\"
    	cPath += "\"
    EndIf 

	//Cria pasta para salvar arquivos Paf-Ecf
    If !ExistDir(cPath)
    	lRetValue := (MakeDir(cPath) == 0)
    EndIf
EndIf

Return lRetValue 

//--------------------------------------------------------
/*/{Protheus.doc}STBFMSignPaf
Rotina de geracao de chave RSA sobre o MD5 do conteudo do
arquivo passado via parametro. 
@author  	Varejo
@version 	P11.8
@since   	03/09/2012
@return  	Logico
@obs     	STBFMSignPaf
/*/
//--------------------------------------------------------
Function STBFMSignPaf(cFile, lMensagem, lCreateTXT, lEdita)
Local lRet			:= .T.
Local nHdl			:= 0
Local nTamanho		:= 0
Local cTexto		:= ""
Local cAssinat		:= "EAD"  
Local cErro			:= ""
Local cArqChPri		:= ""
Local cArqChPub		:= ""
Local cAssRSA		:= ""
Local lArqAssinado	:= .F.
Local lGravado		:= .F.
Local cFiles		:= ""

Default cFile		:= ""
Default lMensagem	:= .T.
Default lCreateTXT	:= .F. //Cria TXT com o EAD
Default	lEdita		:= .F.

cTexto := cFile
cTexto := MD5File(cTexto,1)

nHdl := FOpen(Upper(cFile),FO_READWRITE)

If nHdl <= 0
	STFMessage("STBFMSignPaf1", "STOP", STR0021 + cFile + STR0022)  //"Problemas ao tentar abrir o arquivo "  # " para gravação."
	STFShowMessage("STBFMSignPaf1")
	lRet := .F.
EndIf

If lRet
	fseek(nHdl,0,FS_END)
	lRet := STBGrChPubRSA(@cArqChPri,@cArqChPub)
EndIf

If lRet
	cAssRSA	:= PrivSignRSA(cArqChPri,cTexto,1,"",@cErro,3)
 	If !Empty(AllTrim(cErro)) .Or. ValType(cAssRSA) <> "C" .Or. Empty(allTrim(cAssRSA))
		LjGrvLog(NIL, "Retorno de cErro " , cErro )
		LjGrvLog(NIL, "Retorno de cAssRSA " , cAssRSA )
		lArqAssinado := .F.
		lRet := .F.
	Else
		lArqAssinado := .T.
	EndIf
EndIf
	
If !lArqAssinado
	STFMessage("STBFMSignPaf2", "STOPPOPUP", STR0024 + cFile) //"Problemas na geração da chave RSA para assinatura do arquivo "
	STFShowMessage("STBFMSignPaf2")	
	LjGrvLog(NIL, STR0024 + cFile )
EndIf

//O arquivo sempre deve ser apagado
If !Empty(cArqChPri) .AND. File(cArqChPri)
	FErase(cArqChPri)
EndIf

If lRet .AND. PrivVeryRSA(cArqChPub,cTexto,1,cAssRSA,"",3)
	cAssinat := cAssinat + STBAsc2Hex(cAssRSA)
	
	If lEdita .Or. !(Upper(Substr(cFile,At('.',cFile)+1,Len(cFile))) $ "MF|BIN|MFD") //Os arquivos citados não podem ter a assinatura - Homologacao PAF 2015
		FWRITE( nHdl, cAssinat, LEN(cAssinat) )
	EndIf
	
	lGravado := .T.
	lRet := .T.
Else
	If !lArqAssinado
		STFMessage("STBFMSignPaf3", "STOPPOPUP", STR0025 + cFile) //"Problema na geração da assinatura EAD do arquivo "
		STFShowMessage("STBFMSignPaf3")
	EndIf
EndIf

If nHdl > 0
	FClose(nHdl)
EndIf

If lRet
	cFiles := cFile
	If lGravado .AND. lCreateTXT
		nTamanho := At( ".", cFile)
		If nTamanho > 0
			cFile :=  Left(cFile, nTamanho) + "TXT"
		EndIf
		If File(cFile)
			fErase(cFile)
		EndIf
		nHdl := 0
		
		nHdl := FCREATE( cFile, FC_NORMAL )	 		
		
		If nHdl > 0
			FWRITE( nHdl, cAssinat, LEN(cAssinat) )
			FClose(nHdl)
		    cFiles += "," + cFile
		EndIf
		
	EndIf
	
	If lMensagem 
		STFMessage("STBFMSignPaf4", "POPUP", STR0237 + CHR(10) + CHR(13) + cFiles) //"Arquivo(s) gerado(s) com sucesso: "
		STFShowMessage("STBFMSignPaf4")
	Else 
		Sleep(3000) //Para mostrar a mensagem
	EndIf
EndIf

Return lRet

//--------------------------------------------------------
/*{Protheus.doc}STBGrChPubRSA
Gera a chave publica e privada para assinatura digital.
@author  	Varejo
@version 	P11.8
@since   	24/07/2013
@return  	Logico
@obs     	GrChPubRSA - LOJXFUND.PRW
@sample
/*/
//--------------------------------------------------------
Static Function STBGrChPubRSA(cChPriv,cChPubl)
Local cTxtCh 	:= ""			// Conteudo do arquivo
Local nHandle	:= 0			// Handler para manipulacao do arquivo
Local lRet		:= .T.			// Retorno da rotina
Local cXml		:= "TOTVSSA.XML"

//------------------------------------------------------------------------------
//³########################### I M P O R T A N T E ############################³
//³As chaves publica e privada de 1024 bits foram geradas utilizando o OpenSSL.³
//³As duas chaves devem sempre ser geradas em conjunto.                        ³
//³Comandos para geracao das chaves no OpenSSL:                                ³
//³                                                                            ³
//³1) Chave privada (1024 bits):                                               ³
//³openssl genrsa -out chvpriv.pem 1024                                        ³
//³                                                                            ³
//³2) Chave publica:                                                           ³
//³openssl rsa -in chvpriv.pem -pubout -out chvpubl.pem                        ³
//------------------------------------------------------------------------------

//------------------------------------------------------------------------------
//³Para a chave publica, o nome pode ser fixo.                                ³
//³Para a chave privada, o arquivo recebera um nome aleatorio e sera apagado  ³
//³em seguida, por seguranca. A rotina PrivSignRSA exige um arquivo fisico com³
//³a chave privada RSA.                                                       ³
//------------------------------------------------------------------------------
cChPubl := "ljpafpub.pem"
cChPriv	:= GetNextAlias()+ ".dbf"

//Chave privada
cTxtCh := "-----BEGIN RSA PRIVATE KEY-----"+CHR(10)
cTxtCh += "MIICXQIBAAKBgQDBRrRlwN41DhPma3uQx6XGhIKGgoMQop3yg3760q0jOoUcPJzS"+CHR(10)
cTxtCh += "Yb6Ab7MZewBuXec1jHIX6TakTiUQDDy/SLZ4RtNfa7utYTd8rvRWOxF4oYlUOoZd"+CHR(10)
cTxtCh += "gFwEJ8lWDk76qLxLtsir4aqQQ6Q6xYGc3qkiGwrfGZTrVBlKv8aKCUdJewIDAQAB"+CHR(10)
cTxtCh += "AoGAEn8xxIswuOMgBG1E5hY1R0pnM3hKEs19UDhFbru61iRDmPA0Ee5IzQHjogyj"+CHR(10)
cTxtCh += "fex+tCE8yg0HrbHM2jxRk/zheXZX3uR3LyzoavWk9rnp8/1UcGbR0EvJ1BSAFRYn"+CHR(10)
cTxtCh += "eYW+l63HciCpwfRq8VtMcmiw21287HXpgPq+CVVivLwYyAECQQD+aIYZkV1qMCMD"+CHR(10)
cTxtCh += "aRcosX8O3Gekj/0AyvyT8fCHXZ8mxWABJxNAvVlFAJQHMsw5twh23/XrRKKsVm/m"+CHR(10)
cTxtCh += "WD9FsFUjAkEAwnxEkpIAH9yUhlKUA/rWAqhyAPlaEMkyv201mV5uj1j8LyLn+JrS"+CHR(10)
cTxtCh += "f2tAnHA29xkeRSKoaX+tDa3KYhS8cbtbyQJATpPWJ3uAkNXBWsJQxt7b0ak90dQv"+CHR(10)
cTxtCh += "XtlTXhayJf1CtOTtnC2Hgs15Dxj4n6iO75ya3qyZ9krCu9wOv+St1kZ6ZQJBAJ8q"+CHR(10)
cTxtCh += "WmhlympI+NixTmevamREfQClEXu5Xanic8Iv0WXJmqHs/FGuS2VyXi9peuJhES/d"+CHR(10)
cTxtCh += "fFzS28rdF0uL0ul1P1kCQQDL5ChSsIcmhirHeAJtcp0Ylz6NXDyD3uOsaTlZee2d"+CHR(10)
cTxtCh += "fAgvlAHKFQY0B2gBZhpLFTTmvuKI6+xb5DTzifLchwsg"+CHR(10)
cTxtCh += "-----END RSA PRIVATE KEY-----"+CHR(10)

//Cria o arquivo
If ( nHandle := FCREATE( cChPriv, FC_NORMAL+FC_HIDDEN ) ) > 0
	FWRITE( nHandle, cTxtCh, LEN( cTxtCh ) )
	FClose(nHandle)
Else
	lRet := .F.
	cChPriv := ""
EndIf

/*Verifica se ja existe a chave publica. Se nao existir, esta sera gerada.*/
If !File(cChPubl)
	nHandle:= 0

	cTxtCh := "-----BEGIN PUBLIC KEY-----"+CHR(10)
	cTxtCh += "MIGfMA0GCSqGSIb3DQEBAQUAA4GNADCBiQKBgQDBRrRlwN41DhPma3uQx6XGhIKG"+CHR(10)
	cTxtCh += "goMQop3yg3760q0jOoUcPJzSYb6Ab7MZewBuXec1jHIX6TakTiUQDDy/SLZ4RtNf"+CHR(10)
	cTxtCh += "a7utYTd8rvRWOxF4oYlUOoZdgFwEJ8lWDk76qLxLtsir4aqQQ6Q6xYGc3qkiGwrf"+CHR(10)
	cTxtCh += "GZTrVBlKv8aKCUdJewIDAQAB"+CHR(10)
	cTxtCh += "-----END PUBLIC KEY-----"+CHR(10)
	
	If  ( nHandle := FCREATE( cChPubl, FC_NORMAL ) ) > 0 
		FWRITE( nHandle, cTxtCh, LEN( cTxtCh ) )
		FClose(nHandle)
	Else
		lRet := .F.
		cChPubl := ""
	EndIf
EndIf

/*Cria o arquivo xml com informacoes da empresa, 
 conforme o  ATO COTEPE/ICMS Nº 9, DE 19 DE MARÇO DE 2009 */
If !File(cXml)

	nHandle := 0

	cTxtCh 	:= '<?xml version="1.0"?>'+CRLF
	cTxtCh 	+= '<empresa_desenvolvedora>'+CRLF
	cTxtCh 	+= '<nome>TOTVSSA</nome>'+CRLF
	cTxtCh 	+= '<chave>'+CRLF		
	cTxtCh 	+= '<modulo>C146B465C0DE350E13E66B7B90C7A5C6848286828310A29DF2837EFAD2AD233A851C3C9CD261BE806FB3197B006E5DE7358C7217E936A44E25100C3CBF48B67846D35F6BBBAD61377CAEF4563B1178A189543A865D805C0427C9560E4EFAA8BC4BB6C8ABE1AA9043A43AC5819CDEA9221B0ADF1994EB54194ABFC68A0947497B</modulo>'+CRLF
	cTxtCh 	+= '<expoente_publico>0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000010001</expoente_publico>'+CRLF
	cTxtCh 	+= '</chave>'+CRLF
	cTxtCh 	+= '</empresa_desenvolvedora>'

	If  ( nHandle := FCREATE( cXml, FC_NORMAL ) ) > 0 
		FWRITE( nHandle, cTxtCh, LEN( cTxtCh ) )
		FClose(nHandle)	
	Else
		lRet := .F.
	EndIf
EndIf

Return lRet

//--------------------------------------------------------
/*{Protheus.doc}STBFMImpTabProd
Realiza a Criação e a Gravação dos dados relacionados ao
tabela de Produtos e servicos para PAF-ECF. 
@author  	Varejo
@version 	P11.8
@since   	03/09/2012
@return  	Logico
@obs     	LjxImpTabProd
@sample
/*/
//--------------------------------------------------------
Function STBFMImpTabProd(cWSServer, lPOS, nHandle, lIncManual,;
 						lReducao)
Local nTotRecno		:= 0
Local cConteudo		:= ""                            // Variavel Para a Foracao da Linha.
Local cPreco   		:= ""							 // Campo do Preco
Local lRet			:= .T.
Local nX			:= 0
Local aRetWs		:= {}
Local oWS			:= NIL
Local cLastProd		:= ""	//Ultimo Produto
Local lFim			:= .F.	//Final de Arquivo
Local aTmp			:= {}
Local nPagina		:= 0
Local nTotReg		:= 0
Local lGeraP2		:= .F.
Local cSitTrib		:= ""

Default nHandle		:= 0
Default lIncManual	:= .F.
Default lReducao	:= .F.

If !lReducao
	lGeraP2 := .T.
Else
	lGeraP2 := StbVldE2Paf(lPOS,.F.,"")[1]
EndIf

If lGeraP2
	nPagina	:= Val(GetPvProfString("PAF-ECF","Registros_LstProduto"	,"2650", GetClientDir()+"SIGALOJA.INI")) //Paginas
	nTotReg	:= Val(GetPvProfString("PAF-ECF","Registros_TotLstProduto"	,"5000", GetClientDir()+"SIGALOJA.INI"))
	
	/*Executa a consulta no WebService*/
	oWS := WsFrtPafEcf():New()
	iIf(ExistFunc("LjWsGetAut"),LjWsGetAut(@oWS),Nil) //Monta o Header de Autenticação do Web Service
	
	//Ajusta o caminho do servico
	oWs:_URL := "http://"+cWSServer+"/FRTPAFECF.apw"
	
	/*Executa o web service*/
	CursorWait()
	While !lFim
		STFMessage("STBFMImpTabProd1", "RUN", STR0004,{||lRet := oWs:LstProduto(cEmpAnt , cFilAnt , lHomolPaf, nPagina,;
		 																		cLastProd)})  //"Executando consulta na retaguarda"
		STFShowMessage("STBFMImpTabProd1")
				
		If (lRet == Nil) .OR. !lRet
			STFMessage("STBFMImpTabProd2", "STOP", STR0005 + ":LstProduto") //"Erro na execução do WebService"
			STFShowMessage("STBFMImpTabProd2")
			If !lPOS
				FCLOSE( nHandle )
			EndIf
			lFim := .T.
			lRet := .F.
			Loop
		Else
			aTmp := aClone(oWs:oWsLstProdutoResult:oWsProdList)
			aEval(aTmp, { |e| nX := nX + 1, IIF(nTotReg == 0 .OR. nX <= nTotReg,   aAdd(aRetWS, e), ) }) //Insere os dados do Produto
			If len(aTmp) > 0
			   cLastProd := aTail(aTmp):cCodigo
				lFim := aTail(aTmp):lFimLista .or. (nTotReg > 0 .AND. nX > nTotReg) 
			EndIf
			aTmp := NIL
			//Reseta o Ws
			oWs:RESET()
			
			If nPagina == 0
				lFim := .T.
			EndIf
		EndIf
	End
	
	STFMessage("STBFMImpTabProd6", "STOP", "")  //"Executando consulta na retaguarda"
	STFShowMessage("STBFMImpTabProd6")
	
	CursorArrow()
	oWs:RESET()
	oWs := Nil
	If !Len(aRetWs) > 0
		STFMessage("STBFMImpTabProd3", "STOP", STR0006) //"Nenhum produto encontrado."
		STFShowMessage("STBFMImpTabProd3")
		lRet := .F.
	EndIf
	
	nX := 0
	
	If lRet .AND. lHomolPaf
		For nX := 1 to Len(aRetWs)
			If aRetWs[nX]:lIncManual
				lIncManual := .T.
			EndIf
		Next nX
	EndIf
	
	If lRet
		
		For nX := 1 to Len(aRetWs)
		
			cConteudo := "P2"
			//Trazer Cnpj da Retaguarda
			cConteudo += PADR(aRetWs[nX]:cCnpj , 14 ) // CNPJ
			
			If Empty(AllTrim(aRetWs[nX]:cCodBar))				
				cConteudo += PADR( aRetWs[nX]:cCodigo , 14 )
			Else
				cConteudo += PADR( aRetWs[nX]:cCodBar , 14 )
			EndIf
				
			cConteudo += PADR( aRetWs[nX]:cDescricao , 50 ) 
			
			If !lHomolPAF .OR. aRetWs[nX]:lPAFMD5OK
				cConteudo += PADR( aRetWs[nX]:cUM , 6 )
			Else 
				cConteudo += StrTran(PADR( aRetWs[nX]:cUM , 6 ) ," " ,"?")
			EndIf
	
			cConteudo += PADR( aRetWs[nX]:cIAT , 1 )
			cConteudo += PADR( aRetWs[nX]:cIPPT , 1 )
	
			// Situacao tributaria
			If lHomolPAF
				//deve mostrar caso seja feita alteração no Banco de Dados - TESTE BLOCO VII
				If aRetWs[nX]:nPIcm > 0
					cSitTrib := AllTrim(aRetWs[nX]:cSitTrib) + AllTrim(cValToChar( aRetWs[nX]:nPICM ))
				Else
					cSitTrib := AllTrim(aRetWs[nX]:cSitTrib) + AllTrim(cValToChar( aRetWs[nX]:nAliqIss ))
				EndIf
			Else
				cSitTrib := STBFMSitTrib(aRetWs[nX]:cCodigo)
				//cSitTrib := SFMAlqIssI(cSitTrib) -- Comentado por hora caso, descomentar não possa mostrar aliquota IS/NS/FS
			EndIf
			
			If SubStr(cSitTrib,1,2) $ "FS|IS|NS"
				cSitTrib := "S"
				cSitTrib += "0000"
				cConteudo+= cSitTrib
			Else
				cConteudo += PadL( cSitTrib , 1 ) // sit tributaria         
				
				// aliquota
				If SubStr(cSitTrib,1,1) $ "T|S"
					cSitTrib := StrZero(Val(SubStr(cSitTrib,2,5)),5,2)
					cSitTrib := StrTran(cSitTrib,".")
					cSitTrib := StrTran(cSitTrib,",")		
					cConteudo += PadL(cSitTrib, 4 )    	// aliquota
		    	Else        
					cConteudo += "0000"       			// aliquota                
				EndIf
			EndIf
	
			cPreco := StrZero( aRetWs[nX]:nPreco , 13 , 2 )
			cPreco := StrTran(cPreco,".")
			cPreco := StrTran(cPreco,",")		
			cConteudo += PadR( cPreco, 12 )						
			
			cConteudo += CHR(13) + CHR(10)
			nTotRecno++			
			FWRITE( nHandle, cConteudo, LEN( cConteudo ) )			
		Next nX	
	EndIf
EndIf

Return lRet

//--------------------------------------------------------
/*/{Protheus.doc}STBFMDavEmt
Retorna a lista de DAVs emitidos para a data selecionada 
@author  	Varejo
@version 	P11.8
@since   	03/09/2012
@return  	Logico
@obs        LjxDavEmt
/*/
//--------------------------------------------------------
Function STBFMDavEmt(dDataIni, 	dDataFim, 	lArqTxt, cFile,;
					lPOS,	cWSServer,  lIncManual, nHandle )
Local cLista	:= ""
Local cECF		:= ""
Local cPictTot	:= "@E 99,999,999.99"  
Local cMarca	:= ""
Local cModelo	:= ""          
Local cModeloAux:= "" 
Local cTipoEcf	:= "ECF-IF" 
Local cMFAdic	:= ""
Local cCabec	:= "" 
Local cPath		:= ""
Local cConteudo	:= ""
Local cNumSerie	:= "" 
Local cTotalDAV	:= ""      
Local cCOO		:= ""       
Local cCOODAV	:= "" 
Local nNumDav	:= 0
Local nVias		:= 1 
Local nX		:= 0         
Local nY		:= 0  
Local oWs 		:= WsFrtPafEcf():New() 
Local lRet		:= .T.    
Local cRet		:= ""
Local lMvLjDAVOS:= SuperGetMv("MV_LJDAVOS",,.F.)
Local lCooDav	:= .F.
Local cRazaoSoc	:= ""
Local aDatVendas:= {}
Local nI		:= 0
Local nCountReg := 0
Local aResultD2	:= {}
Local aResultD3	:= {}
Local aResultD4 := {}

Default dDataIni	:= dDataBase
Default lIncManual	:= .F.   
Default cWSServer	:= ""
Default nHandle		:= 0

If lPOS
	cECF		:= STFGetStation("IMPFISC")
Else
	cWSServer	:= AllTrim(LjGetStation("WSSRV"))   
	cECF		:= LjGetStation("IMPFISC")	
EndIf

//PAF-ECF: Remove a versão e envia apenas o modelo
nX := At(" ",cECF)            
nY := At("-",cECF) 
cMarca := SubStr(cECF,1,nX-1)
cModelo:= SubStr(cECF,nX+1,nY-nX-2)

If At('[FW]',cModelo) > 0
	cModelo := allTrim(Substr(cModelo,5,Len(cModelo)))
EndIf

//³Verifica se o servidor de WS esta configurado³
If Empty(cWSServer)   
	STFMessage("STBFMDavEmt1", "STOP", STR0027) //"O servidor de Web Services não está configurado nesta estação"
	STFShowMessage("STBFMDavEmt1")
	LjGrvLog(Nil, GetWSCError() )
	Return .F.
EndIf

aDatVendas := STBPerVendas(dDataIni, dDataFim)       

For nI := 1 to Len(aDatVendas)

	//Ajusta o caminho do servico
	oWs:_URL := "http://"+cWSServer+"/FRTPAFECF.apw"
	iIf(ExistFunc("LjWsGetAut"),LjWsGetAut(@oWs),Nil) //Monta o Header de Autenticação do Web Service

	//Executa o web service
	STFMessage("STBFMDavEmt2", "RUN",STR0004,;
	{||lRet := oWs:LstDavEmit(aDatVendas[nI][1], aDatVendas[nI][2], cEmpAnt, cFilAnt, lHomolPaf)}) //"Executando consulta na retaguarda"
	STFShowMessage("STBFMDavEmt2")
	
	If ValType(lRet) <> "L" .Or. !lRet
		STFMessage("STBFMDavEmt3", "STOP",STR0027 + GetWSCError()) //"Falha no Web Service: "
		STFShowMessage("STBFMDavEmt3")
		LjGrvLog(Nil, GetWSCError() )
		Return .F.
	EndIf
	
	If !lArqTxt
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Prepara o texto a ser impresso³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		For nX := 1 to Len(oWs:oWsLstDavEmitResult:oWsDavList)	           
		
			cCOO	  := AllTrim(oWs:oWsLstDavEmitResult:oWsDavList[nX]:cCOO)
			cCOODAV  := SubStr(oWs:oWsLstDavEmitResult:oWsDavList[nX]:cCOODAV,1,6) 
	
			cLista += PADR(oWs:oWsLstDavEmitResult:oWsDavList[nX]:cCodigo,15) + "  "
			cLista += oWs:oWsLstDavEmitResult:oWsDavList[nX]:cTitulo + "  "
			cLista += PADR( If(Empty(cCOODAV),"000000",cCOODAV), 13) 
			cLista += CRLF //PulaLinha
			                                                        		
			cLista += DtoC(oWs:oWsLstDavEmitResult:oWsDavList[nX]:dEmissao) + "  "
			cLista += PADR( AllTrim(Transform(oWs:oWsLstDavEmitResult:oWsDavList[nX]:nValor,cPictTot)), 16)
			cLista += PADR( If(Empty(cCOO),"000000",cCOO), 13) 
			cLista += CRLF //PulaLinha			
			cLista += CRLF //PulaLinha - Insere uma linha em branco para separar os DAV
		Next nX
		
		/*Monta o cabecalho e imprime, se houver itens. Caso contrario notifica o usuario*/                                          
		If !Empty(cLista)         
			If lMvLjDAVOS
				cCabec	:= PadC(STR0028,40) + CRLF //"D A V - O S   E M I T I D O S"
			Else
				cCabec	:= PadC(STR0029,40) + CRLF //"D A V   E M I T I D O S"
			EndIf
			
			cCabec += " " + CRLF
			cCabec	+= STR0030 + Dtoc(dDataIni) + STR0031 + Dtoc(dDataFim) + CRLF  //"Periodo Solicitado : "#" a "
			cCabec += " " + CRLF
			  
			If lMvLjDAVOS
				cCabec 	+= STR0032		+ CRLF  //"Numero DAV-OS     Titulo       COO RG"
				cCabec 	+= STR0033 	+ CRLF   //"Data DAV-OS        Valor       COO Venda"
			Else
				cCabec 	+= STR0034 		+ CRLF //"Numero DAV        Titulo       COO RG"
				cCabec 	+= STR0035	+ CRLF	 //"Data DAV           Valor       COO Venda" 
			EndIf
			
			lRet := .T.
			If STBImpItMF( "LjxDavEmt" , cCabec+cLista , nVias, lPOS ) <> 0
				STFMessage("STBFMDavEmt4", "STOP",STR0010)   //"Erro ao conectar com a Impressora Fiscal."
				STFShowMessage("STBFMDavEmt4")
				lRet := .F.
			EndIf		
		Else
			STFMessage("STBFMDavEmt5", "OK", STR0036) //"Não foram encontrados registros de DAV para o período solicitado."
			STFShowMessage("STBFMDavEmt5")
		EndIf
	
	Else 
		
		If lRet .And. Len(oWs:oWsLstDavEmitResult:oWsDavList) > 0
			
			If nHandle < 0
				STFMessage("STBFMDavEmt6", "STOP",STR0037 + cPath + cFile) //"Erro ao criar arquivo "
				STFShowMessage("STBFMDavEmt6")
				LjGrvLog(Nil, GetWSCError() )
				Return .F.
			EndIf
			
			cRazaoSoc := PADR( SM0->M0_NOMECOM, 50 ) // Razao Social
			
			For nX := 1 to Len(oWs:owsLstDavEmitResult:oWsDavList)
				If oWs:oWsLstDavEmitResult:oWsDavList[nX]:lIncManual
					cRazaoSoc := StrTran( PADR( SM0->M0_NOMECOM, 50 ) , " " , "?" ) // Razao Social
					lIncManual := .T.
				EndIf
			Next nX
		
			//Recupera série do PDV sem conectar com o ECF - "VI  -  Consultas:  funções  do  PAF-ECF  que  não  necessitam  de  informações coletadas diretamente do ECF.". 
			STBDadosEcf(lPOS)
			STBGetInfEcf("SERIE",@cNumSerie)		
			
			/* REGISTRO TIPO D2 - RELAÇÃO DOS DAV EMITIDOS */	
			For nX := 1 to Len(oWs:oWsLstDavEmitResult:oWsDavList)

				cCOO	:= oWs:oWsLstDavEmitResult:oWsDavList[nX]:cCOO
				cCOODAV	:= oWs:oWsLstDavEmitResult:oWsDavList[nX]:cCOODAV
				lCooDav	:= If(Empty(AllTrim(cCOODAV)) .OR. (cCOODAV == "000000   ") .OR. (Val(cCOODAV) == 0), .F., .T.)
	            cModelo := oWs:oWsLstDavEmitResult:oWsDavList[nX]:cModelo
	                                     
				/* Quando possui alteração na DAV, conforme legislação PAF, deverá ser evidenciada */
				If lHomolPAF
					If oWs:oWsLstDavEmitResult:oWsDavList[nX]:LPAFMD5OK
						cModeloAux := PADR( If(!lCooDav ," ",cModelo), 20)			// Modelo do ECF			
					ElseIf lCooDav
						cModeloAux := StrTran(PADR(cModelo,20) , " ", "?") // Modelo do ECF quando ocorre modificação nos registros TESTE 103
					ElseIf !oWs:oWsLstDavEmitResult:oWsDavList[nX]:LPAFMD5OK .AND. !lCooDav
						cModeloAux := REPLICATE("?",20)
					Else
						cModeloAux := REPLICATE(" ",20)   // Modelo do ECF quando ocorre modificação nos registros TESTE 103
					EndIf
				Else
					cModeloAux := PADR( cModelo, 20 )
				EndIf
	
				cTotalDAV := StrZero(oWs:oWsLstDavEmitResult:oWsDavList[nX]:nValor,9,2)
				cTotalDAV := StrTran(cTotalDAV,".")
				cTotalDAV := StrTran(cTotalDAV,",")
				
				Aadd(aResultD2 ,Array(16))
				nCountReg := Len(aResultD2)
				 
				aResultD2[nCountReg][1] := "D2"
				aResultD2[nCountReg][2] := PADL( oWs:oWsLstDavEmitResult:oWsDavList[nX]:cCNPJ, 14 ) 			//02- CNPJ
				
				cNumSerie := AllTrim(oWs:oWsLstDavEmitResult:oWsDavList[nX]:cSerPDV)
				cMFAdic   := AllTrim(oWs:oWsLstDavEmitResult:oWsDavList[nX]:cMFAdic)
				cTipoEcf  := AllTrim(oWs:oWsLstDavEmitResult:oWsDavList[nX]:cTipoEcf)
				cMarca	  := AllTrim(oWs:oWsLstDavEmitResult:oWsDavList[nX]:cMarca)
				
				aResultD2[nCountReg][3] := PADR( IIF(!lCooDav ,"",cNumSerie), 20 )							//03- Num. de fabricação do ECF  
				aResultD2[nCountReg][4] := PADR(cMFAdic,1)								  					//04- Letra indicativa de MF adicional 
				aResultD2[nCountReg][5] := PADR( IIF(!lCooDav ,"",cTipoEcf), 7)								//05- Tipo do ECF 								
				aResultD2[nCountReg][6] := PADR( IIF(!lCooDav ,"",cMarca), 20)	  							//06- Marca do ECF
				aResultD2[nCountReg][7] := cModeloAux															//07- Modelo do ECF
				aResultD2[nCountReg][8] := StrZero( If(Empty(cCOODAV),0,Val(cCOODAV)), 9 )					//08- COO DA IMPRESSÃO DA DAV por ECF
				aResultD2[nCountReg][9] := PADR( oWs:oWsLstDavEmitResult:oWsDavList[nX]:cCodigo, 13)			//09- DAV
				aResultD2[nCountReg][10] := PADR( DtoS(oWs:oWsLstDavEmitResult:oWsDavList[nX]:dEmissao),8)		//10- Data da operacao
				aResultD2[nCountReg][11] := PADR( oWs:oWsLstDavEmitResult:oWsDavList[nX]:cTitulo,30)			//11- Titulo atribuido ao DAV
				aResultD2[nCountReg][12] := PADL( cTotalDAV,8)													//12- Valor total do DAV	
				aResultD2[nCountReg][13] := StrZero( If(Empty(cCOO),0,Val(cCOO)), 9)					//13- COO do Cupom Vinculado
				aResultD2[nCountReg][14] := StrZero( Val(oWs:oWsLstDavEmitResult:oWsDavList[nX]:cSerie), 3)			//14- Número sequencial do ECF emissor do documento fiscal vinculado
				aResultD2[nCountReg][15] := PADR( oWs:oWsLstDavEmitResult:oWsDavList[nX]:cNomeClient, 40)			//15- Nome do Cliente 
				aResultD2[nCountReg][16] := StrZero( Val(oWs:oWsLstDavEmitResult:oWsDavList[nX]:cCnpjClient), 14)	//16- CPF ou CNPJ do adquirente
				
				/* REGISTRO  TIPO  D3  -  DETALHE  DO  DOCUMENTO  AUXILIAR  DE VENDA - DAV  */
				For nY := 1 to Len(oWs:oWsLstDavEmitResult:oWsDavList[nX]:oWsLstItemDav:oWsItDavList)
				   	Aadd(aResultD3 ,Array(16))
				   	nCountReg := Len(aResultD3)
				   	
				   	//Busca o Codigo do Totalizador				   	
			   		cRet := STBBuscaTotECF( oWs:oWsLstDavEmitResult:oWsDavList[nX]:oWsLstItemDav:oWsItDavList[nY]:cTotParc, lPOS )
					cRet := SubStr(cRet,3,5)
					
					aResultD3[nCountReg][1] := "D3"             																							// 01-Tipo
					
					nNumDav	:= Val(oWs:oWsLstDavEmitResult:oWsDavList[nX]:cCodigo)
					aResultD3[nCountReg][2] := StrZero( nNumDav, 13)																							// 02-Número do DAV onde está contido este item
					aResultD3[nCountReg][3] := PADR( DtoS(oWs:oWsLstDavEmitResult:oWsDavList[nX]:oWsLstItemDav:oWsItDavList[nY]:dEmissao),08)				// 03-Data de inclusão do item							                    
					aResultD3[nCountReg][4] := StrZero( oWs:oWsLstDavEmitResult:oWsDavList[nX]:oWsLstItemDav:oWsItDavList[nY]:nNumItem, 03)				// 04-Número  sequencial  do  item  registrado no documento 																																	
					aResultD3[nCountReg][5] := PADR(oWs:oWsLstDavEmitResult:oWsDavList[nX]:oWsLstItemDav:oWsItDavList[nY]:cCodProd, 14) 				 	// 05-Código  do  produto  ou  serviço registrado no documento.
					
					If lHomolPAF .AND. !oWs:oWsLstDavEmitResult:oWsDavList[nX]:oWsLstItemDav:oWsItDavList[nY]:lPAFMD5OK // 06-Descrição  do  produto  ou  serviço constante no Cupom Fiscal
						aResultD3[nCountReg][6] := StrTran(PADR(oWs:oWsLstDavEmitResult:oWsDavList[nX]:oWsLstItemDav:oWsItDavList[nY]:cDescricao, 100)," ","?")
					Else
						aResultD3[nCountReg][6] := PADR(oWs:oWsLstDavEmitResult:oWsDavList[nX]:oWsLstItemDav:oWsItDavList[nY]:cDescricao, 100) 	
					EndIf	
						
					aResultD3[nCountReg][7] := StrZero(oWs:oWsLstDavEmitResult:oWsDavList[nX]:oWsLstItemDav:oWsItDavList[nY]:nQuantidade, 07)				// 07-Quantidade,  sem  a  separação  das casas decimais 
					aResultD3[nCountReg][8] := PADR( oWs:oWsLstDavEmitResult:oWsDavList[nX]:oWsLstItemDav:oWsItDavList[nY]:cUnMedida	,03 )				// 08-Unidade de medida
					aResultD3[nCountReg][9] := StrZero(oWs:oWsLstDavEmitResult:oWsDavList[nX]:oWsLstItemDav:oWsItDavList[nY]:nVlrUnit	,08 )				// 09-Valor  unitário  do  produto  ou  serviço, sem a separação das casas decimais. 
					aResultD3[nCountReg][10] := StrTran(StrZero(oWs:oWsLstDavEmitResult:oWsDavList[nX]:oWsLstItemDav:oWsItDavList[nY]:nDescItem,9,2),'.')	// 10-Valor  do  desconto  incidente  sobre  o valor  do  item,  com  duas  casas decimais.				
					aResultD3[nCountReg][11] := StrTran(StrZero(oWs:oWsLstDavEmitResult:oWsDavList[nX]:oWsLstItemDav:oWsItDavList[nY]:nAcreItem,9,2),'.')	// 11-Valor  do  acréscimo  incidente  sobre  o valor  do  item,  com  duas  casas decimais. 		
					aResultD3[nCountReg][12] := StrTran(StrZero(oWs:oWsLstDavEmitResult:oWsDavList[nX]:oWsLstItemDav:oWsItDavList[nY]:nVlrLiq,15,2),'.')	// 12-Valor  total  líquido  do  item,  com  duas casas decimais. 
					
					//Ajustar a formação dependendo do tipo de alíquota
					If ("S" $ cRet) .OR. ("T" $ cRet)
						aResultD3[nCountReg][13] := PADR( cRet	,05 )		// 13 e 14-Código  do  totalizador  relativo  ao produto  ou  serviço  conforme  tabela abaixo.					 
					Else                                                                        
						aResultD3[nCountReg][13] := PadR(oWs:oWsLstDavEmitResult:oWsDavList[nX]:oWsLstItemDav:oWsItDavList[nY]:cTotParc + "0000", 05)
					EndIf
					
					aResultD3[nCountReg][14] := PADR(If(oWs:oWsLstDavEmitResult:oWsDavList[nX]:oWsLstItemDav:oWsItDavList[nY]:lItCancel,"S","N"), 01 )		// 15-Informar  "S"  ou  "N",  conforme  tenha ocorrido  ou  não,  a  marcação  do cancelamento  do  item  no  documento auxiliar de venda.  
					aResultD3[nCountReg][15] := CVALTOCHAR(oWs:oWsLstDavEmitResult:oWsDavList[nX]:oWsLstItemDav:oWsItDavList[nY]:nDecQtde)	// 16-Casas decimais da qtde
					aResultD3[nCountReg][16] := CVALTOCHAR(oWs:oWsLstDavEmitResult:oWsDavList[nX]:oWsLstItemDav:oWsItDavList[nY]:nDecVlrUnt)	// 17-Casas decimais do valor unitario
		   		Next nY
		   		
		   		/*REGISTRO  TIPO  D4  -  LOG DE ALTERACAO DE ITENS DO DAV - DAV  */
		   		If ValType(oWs:oWsLstDavEmitResult:oWsDavList[nX]:oWsLstItDavLog:oWsItDavLstLg) == "A"
	            
					For nY := 1 to Len(oWs:oWsLstDavEmitResult:oWsDavList[nX]:oWsLstItDavLog:oWsItDavLstLg)
						
						Aadd(aResultD4 ,Array(17))
						nCountReg := Len(aResultD4)
						
						If lHomolPaf .And. oWs:oWsLstDavEmitResult:oWsDavList[nX]:oWsLstItDavLog:oWsItDavLstLg[nY]:lIncManual
							lIncManual := .T.
						EndIf

					   	//Busca o Codigo do Totalizador ICMS
				   		cRet := STBBuscaTotECF( oWs:oWsLstDavEmitResult:oWsDavList[nX]:oWsLstItDavLog:oWsItDavLstLg[nY]:cTotParc, lPOS )
						cRet := SubStr(cRet,3,5)
						
						aResultD4[nCountReg][1] := "D4"   																							// 01-Tipo
						
						nNumDav	:= Val(oWs:oWsLstDavEmitResult:oWsDavList[nX]:cCodigo)
						aResultD4[nCountReg][2] := StrZero( nNumDav, 13)																							// 02-Número do DAV onde está contido este item
						aResultD4[nCountReg][3] := PADR( DtoS(oWs:oWsLstDavEmitResult:oWsDavList[nX]:oWsLstItDavLog:oWsItDavLstLg[nY]:dAlteracao),08)				// 03-Data de alteracao do item							                    
						aResultD4[nCountReg][4] := PADR( StrTran(oWs:oWsLstDavEmitResult:oWsDavList[nX]:oWsLstItDavLog:oWsItDavLstLg[nY]:cHora,":"),06)				// 04-Hora de alteracao do item	
						aResultD4[nCountReg][5] := PADR(oWs:oWsLstDavEmitResult:oWsDavList[nX]:oWsLstItDavLog:oWsItDavLstLg[nY]:cCodProd, 14) 				 	// 06-Código do produto  ou  serviço registrado no documento.
						
						If lHomolPaf .And. !oWs:oWsLstDavEmitResult:oWsDavList[nX]:oWsLstItDavLog:oWsItDavLstLg[nY]:lPafMD5OK // 07-Descrição  do  produto  ou  serviço constante no Cupom Fiscal
							aResultD4[nCountReg][6] := StrTran(PADR(oWs:oWsLstDavEmitResult:oWsDavList[nX]:oWsLstItDavLog:oWsItDavLstLg[nY]:cDescricao, 100)," ","?")	
						Else
							aResultD4[nCountReg][6] := PADR(oWs:oWsLstDavEmitResult:oWsDavList[nX]:oWsLstItDavLog:oWsItDavLstLg[nY]:cDescricao, 100)
						EndIF
							
						aResultD4[nCountReg][7] := StrZero(oWs:oWsLstDavEmitResult:oWsDavList[nX]:oWsLstItDavLog:oWsItDavLstLg[nY]:nQuantidade, 07)				// 08-Quantidade,  sem  a  separação  das casas decimais 
						aResultD4[nCountReg][8] := PADR(oWs:oWsLstDavEmitResult:oWsDavList[nX]:oWsLstItDavLog:oWsItDavLstLg[nY]:cUnMedida	,03 )				// 09-Unidade de medida
						aResultD4[nCountReg][9] := StrZero(oWs:oWsLstDavEmitResult:oWsDavList[nX]:oWsLstItDavLog:oWsItDavLstLg[nY]:nVlrUnit	,08 )				// 10-Valor  unitário  do  produto  ou  serviço, sem a separação das casas decimais. 
						aResultD4[nCountReg][10] := StrTran(StrZero(oWs:oWsLstDavEmitResult:oWsDavList[nX]:oWsLstItDavLog:oWsItDavLstLg[nY]:nDescItem,9,2),'.')	// 11-Valor  do  desconto  incidente  sobre  o valor  do  item,  com  duas  casas decimais.				
						aResultD4[nCountReg][11] := StrTran(StrZero(oWs:oWsLstDavEmitResult:oWsDavList[nX]:oWsLstItDavLog:oWsItDavLstLg[nY]:nAcreItem,9,2),'.')	// 12-Valor  do  acréscimo  incidente  sobre  o valor  do  item,  com  duas  casas decimais. 		
						aResultD4[nCountReg][12] := StrTran(StrZero(oWs:oWsLstDavEmitResult:oWsDavList[nX]:oWsLstItDavLog:oWsItDavLstLg[nY]:nVlrLiq,15,2),'.')	// 13-Valor  total  líquido  do  item,  com  duas casas decimais. 
						
						//Ajustar a formação dependendo do tipo de alíquota
						If ("S" $ cRet) .OR. ("T" $ cRet)
							aResultD4[nCountReg][13] := PADR( cRet	,05 )		// 14 e 15-Código  do  totalizador  relativo  ao produto  ou  serviço  conforme  tabela abaixo.					 
						Else                                                                        
							aResultD4[nCountReg][13] := PADR(oWs:oWsLstDavEmitResult:oWsDavList[nX]:oWsLstItDavLog:oWsItDavLstLg[nY]:cTotParc + "0000", 5)
						EndIf
						
						aResultD4[nCountReg][14] := PADR(IIf(oWs:oWsLstDavEmitResult:oWsDavList[nX]:oWsLstItDavLog:oWsItDavLstLg[nY]:lItCancel,"S","N"), 01 ) // 16-Informar  "S"  ou  "N",  conforme  tenha ocorrido  ou  não,  a  marcação  do cancelamento  do  item  no  documento auxiliar de venda.  
						aResultD4[nCountReg][15] := CVALTOCHAR(oWs:oWsLstDavEmitResult:oWsDavList[nX]:oWsLstItDavLog:oWsItDavLstLg[nY]:nDecQtde)// 17-Casas decimais da qtde
						aResultD4[nCountReg][16] := CVALTOCHAR(oWs:oWsLstDavEmitResult:oWsDavList[nX]:oWsLstItDavLog:oWsItDavLstLg[nY]:nDecVlrUnt)//18-Casas decimais do valor unitario
						aResultD4[nCountReg][17] := PADR(oWs:oWsLstDavEmitResult:oWsDavList[nX]:oWsLstItDavLog:oWsItDavLstLg[nY]:cTipoAlt, 01 )	//19 - Tipo de Alteracao
			   		Next nY
			   	EndIf
			Next nX
			
			lRet := .T.
		EndIf
	EndIf
Next nI

If Len(aResultD2) > 0
	//Ordena por: Data + Numero DAV
	aSort(aResultD2,,,{|a,b| a[10]+a[9] < b[10]+b[9]})
	For nX := 1 to Len(aResultD2)
		cConteudo:= ""
		For nY := 1 to Len(aResultD2[nX])
			cConteudo += aResultD2[nX][nY]
		Next nY
		cConteudo += CHR(13) + CHR(10)
		FWRITE( nHandle, cConteudo, LEN( cConteudo ) )
	Next nX
	
	//Ordena por: Data + NUmero DAV + Numero Item
	aSort(aResultD3,,,{|a,b| a[3]+a[2]+a[4] <;
	 						 b[3]+b[2]+b[4]})
	For nX := 1 to Len(aResultD3)
		cConteudo:= ""
		For nY := 1 to Len(aResultD3[nX])
			cConteudo += aResultD3[nX][nY]
		Next nY
		cConteudo += CHR(13) + CHR(10)
		FWRITE( nHandle, cConteudo, LEN( cConteudo ) )
	Next nX
	
	//Ordena por: Data + Numero da DAV
	If Len(aResultD4) > 0
		aSort(aResultD4,,,{|a,b| a[3]+a[2] <;
			 					b[3]+b[2]})
		For nX := 1 to Len(aResultD4)
			cConteudo:= ""
			For nY := 1 to Len(aResultD4[nX])
				cConteudo += aResultD4[nX][nY]
			Next nY
			cConteudo += CHR(13) + CHR(10)
			FWRITE( nHandle, cConteudo, LEN( cConteudo ) )
		Next nX	
	EndIf
EndIf

Return lRet

//--------------------------------------------------------
/*/{Protheus.doc}STBFMImpIdPE
Impressão do Relatório Gerencial (via ECF) "IDENTIFICACAO DO
PAF-ECF", com informacoes do Laudo de Analise Funcional 
@author  	Varejo
@version 	P11.8
@since   	03/09/2012
@return  	Logico
@obs     	LjxImpIdPE
@sample
/*/
//--------------------------------------------------------
Function STBFMImpIdPE(lPOS)
Local cConteudo	:= ""				// Texto a ser impresso pelo ECF
Local cNomCom	:= ""				// Versao corrente do sistema
Local cArquivo	:= ""				//Nome do Arquivo que foi realizado o MD5
Local cMd5Paf	:= ""				//MD5 do Arquivo
Local nX		:= 0				//For
Local cNumSerie	:= "" 				//Nr. de Serie da Impressora
Local cERPAFECF	:= ""
Local cNumLaudo	:= ""				// No. do Laudo
Local cVerAplic	:= ""				// Versao do Aplicativo
Local cDtLaudo	:= ""   
Local cSerPdv	:= ""
Local cPDV		:= ""
Local lRet		:= .T.				// Retorno da funcao
Local lIsPafNfce:= STFGetCfg("lPAFNFCE") .Or. IIf(ExistFunc("LjPafNFCe"),LjPafNFCe(),.F.)	 //Usa PAF-NFC-e c/ Impressora Não Fiscal

cNumLaudo	:= STBVerPAFECF("NUMLAUDO")	
cVerAplic	:= STBVerPAFECF("VERSAOAPLIC")
cERPAFECF	:= STBVerPAFECF("ERPAFECF")
cDtLaudo	:= STBVerPAFECF("DATALAUDO")
	
If lPos
	cSerPDV 	:= STFGetStat("SERPDV")
	cPDV		:= STFGetStat("PDV")
Else
	cSerPDV		:= LjGetStation("SERPDV")
	cPDV 		:= LjGetStation("PDV")
EndIf

cNomCom := STBFMModPaf()

Conteudo := Iif(lIsPafNfce, STR0242, STR0039) + CRLF + CRLF //"IDENTIFICAÇÃO DO PAF-ECF" ### "IDENTIFICAÇÃO DO PAF-NFC-e"

cConteudo += STR0040 + CRLF 							//"---EMPRESA DESENVOLVEDORA---"
cConteudo += STR0041 + cNumLaudo	+ CRLF 				//"Numero do laudo: "
cConteudo += STR0042 + _CNPJFMTTOT 	+ CRLF 				//"CNPJ: "
cConteudo += STR0043 + _RAZSOC 		+ CRLF				//"Razão Social: "
cConteudo += STR0044 + _ENDTOTVS	+ CRLF 				//"Endereço: "
cConteudo += STR0045 + _CEPTOTVS	+ CRLF				//"CEP: "
cConteudo += STR0046 + _TELTOTVS	+ CRLF				//"Telefone: "
cConteudo += STR0047 + _CONTOTVS	+ CRLF + CRLF 		//"Contato: "

cConteudo += Iif(lIsPafNfce, "", STR0048 + CRLF + CRLF)	//"---IDENTIFICAçãO DO PAF-ECF---"
cConteudo += STR0049 + cModPaf 			+ CRLF 			//"Nome comercial: "
cConteudo += STR0050 + cVerAplic		+ CRLF 			//"Versão: "			 

If lIsPafNfce
	cConteudo += STR0245 + CRLF //"Banco de dados local"
	cConteudo += STR0244 + " " + "SMARTCLIENT.EXE" + CRLF //"PAF-NFC-e Local:"
Else
	//Pega MD5 da Array aArqLstPaf, alimentada na Function LjxArqIdPaf(), função da LIB MD5FILE não funciona quando arquivo em Uso ou Somente Leitura
	For nX := 1 To Len(aArqLstPaf)
			
		cArquivo 	:= aArqLstPaf[nX][1]
		cMd5Paf		:= aArqLstPaf[nX][2]

		If nX = 1 
			cConteudo += STR0051 + cArquivo + CRLF //"Principal Arquivo:"
		ElseIf nX = 2
			cConteudo += STR0052 + CRLF + cArquivo + CRLF //"Demais arquivos utilizados:"
		Else 
			cConteudo += cArquivo + CRLF	
		EndIf
		cConteudo += STR0053 + cMd5Paf + CRLF
	Next nX

	//c5) Nome do arquivo texto que contém a lista de arquivos autenticados
	cMd5Paf	:= STBMd5CF()
	cConteudo += STR0054 + CRLF	    			//"Arquivo com lista de arquivos autenticados:"
	cConteudo += Upper("paflista.txt") + CRLF	   
	cConteudo += STR0055 + cMd5Paf + CRLF 		//"MD-5:"
	cConteudo += STR0056 + cERPAFECF + CRLF 	//"VERSAO DA ER PAF-ECF(Versão do Ato Cotepe)
	cConteudo += "Data de Emissão do Laudo:" + cDtLaudo + CRLF				//"Data do Laudo:"
						
	//Busca série dos ecf's cadastrados na retaguarda
	oWS 	 := WsFrtPafEcf():New()
	iIf(ExistFunc("LjWsGetAut"),LjWsGetAut(@oWS),Nil) //Monta o Header de Autenticação do Web Service
	cWSServer:= IIF(lPOS, STFGetStat("WSSRV") , LjGetStation("WSSRV"))
	oWs:_URL := "http://" + cWSServer + "/FRTPAFECF.apw" //Ajusta o caminho do servico

	//Executa o web service
	STFMessage("STBFMImpIdPE2", "RUN", STR0004 ,;
				{||lRet := oWs:LstPdvs(cEmpAnt, cFilAnt, "LG_SERPDV",lHomolPaf,cPDV, cSerPDV)})  //"Executando consulta na retaguarda"
	STFShowMessage("STBFMImpIdPE2")

	If !lRet
		LjGrvLog(Nil, GetWSCError() )
		
		STFMessage("STBFMImpIdPE3", "STOP", STR0005)//"Erro na execução do WebService"
		STFShowMessage("STBFMImpIdPE3")
		oWs := Nil
		lRet:= .T.

		If lPOS
			cNumSerie := Space(30)
			STWGetSerie(@cNumSerie)
			cNumSerie := AllTrim(cNumSerie)
			
			If Empty(cNumSerie)
				lRet := .F.
			EndIf
		Else
			If IFPegSerie(nHdlECF, @cNumSerie) <> 0
				lRet := .F.
			EndIf
		EndIf
		
		If lRet 
			cConteudo += STR0057 + cNumSerie + CRLF //"Nr. Serie:"
		Else
			STFMessage("STBFMImpIdPE4", "STOP", STR0010) //"Erro ao conectar com a Impressora Fiscal."
			STFShowMessage("STBFMImpIdPE4")
		EndIf
	Else
		For nX := 1 To Len(oWS:oWsLstPdvsResult:cString)
			cConteudo += STR0057 + oWS:oWsLstPdvsResult:cString[nX] + CRLF //"Nr. Serie:" 	
		Next nX
		lRet := .T.
	EndIf
EndIf
If lRet
	If lIsPafNfce 
		STIIdPafNf(cConteudo)
	Else	
		If STBImpItMF( "LjxImpIdPE" , cConteudo , 1, lPOS ) <> 0
			STFMessage("STBFMImpIdPE4", "STOP", STR0010) //"Erro ao conectar com a Impressora Fiscal."
			STFShowMessage("STBFMImpIdPE4")
			lRet := .F.
		EndIf
	EndIf	
EndIf

Return lRet

//--------------------------------------------------------
/*/{Protheus.doc}STBFMTipArq
Realiza a montagem da tela para que possa ser informado
o tipo de arquivo que sera gerado 1=Sintegra 2=Sped
@author  	Varejo
@version 	P11.8
@since   	03/09/2012
@return  	.T. Se for precionado o botao de Ok.   
@obs     	LjxTipArq
@sample
/*/
//--------------------------------------------------------
Static Function STBFMTipArq(	cTitulo	, nOpcao )	

Local oDlg          := Nil
Local oTipoRel		:= Nil			   // Objeto para o tipo de arquivo a ser gerado
Local nTipoRel		:= 1			   // Variavel que tera o tipo de relatorio 1= Sintegra 2=Sped
Local lRetValue     := .F.

	DEFINE MSDIALOG oDlg FROM  15,6 TO 260,300 TITLE cTitulo PIXEL
	
	@ 013,008 Radio oTipoRel Var nTipoRel Items STR0058, STR0059 3D Size 85,10 PIXEL OF oDlg //"CONVENIO 57/95" #"ATO COTEPE 09/08" 
	
	nOpcao := nTipoRel	
				
	DEFINE 	SBUTTON   oBtnOk     ;
            FROM      100, 087   ;
            TYPE      1          ;
            ENABLE OF oDlg       ;
            ACTION    ( lRetValue := .T., oDlg:End() )
	
	DEFINE 	SBUTTON   oBtnCancel ;
            FROM      100, 115   ;
            TYPE      2          ;
            ENABLE OF oDlg       ;
            ACTION    ( lRetValue := .F., oDlg:End() )
	
	ACTIVATE MSDIALOG oDlg CENTERED 
	
nOpcao := nTipoRel

Return lRetValue 


//--------------------------------------------------------
/*/{Protheus.doc}STBFMSinteg
Gera arquivo CONVENIO 57/95(Sintegra) para o PAF-ECF
@author  	Varejo
@version 	P11.8
@since   	03/09/2012
@return  	Nil
@obs     	LjxSinteg
@sample
/*/
//--------------------------------------------------------
Function STBFMSinteg(lPOS) 

Local aParamPerg	:= {}   
Local aItem			:= {}
Local cTitulo		:= STR0060 	//"SINTEGRA"
Local cText1		:= STR0061 	//"Esta rotina tem como objetivo gerar o arquivo pre-formatado de acordo com os"
Local cText2		:= STR0062 	//"Convenios ou Portarias indicado nos parametros"
Local cPerg			:= "MTA940"
Local aSays			:= {}
Local aButtons		:= {}
Local nOpca			:= 0
Local nTamSX1		:= 0
Local cPathSrv		:= ""	
Local cFileSrv		:= ""
Local cPathLocal	:= ""	
Local cFileLocal	:= "" 
Local lRet			:= .F.
Local lProssegue	:= .F.  
Local cFilA940		:= ""


Pergunte(cPerg,.F.)

AADD(aSays,OemToAnsi( cText1 ) )
AADD(aSays,OemToAnsi( cText2 ) )
AADD(aButtons, { 1,.T.,{|o| nOpca:= 1,o:oWnd:End()}} )
AADD(aButtons, { 2,.T.,{|o| o:oWnd:End() }} )
AADD(aButtons, { 5,.T.,{|| Pergunte(cPerg,.T. ) } } )
FormBatch( cTitulo, aSays, aButtons )

    
If nOpca == 1 
	//Nao deve informar diretorio, adotando dessa forma StartPath como default
	MV_PAR13 := ""                  
	
	//Emite Alerta e permite ajuste caso não tenha selecionado o Lay-Out esperado para essa rotina, 
	STFMessage("STBFMSinteg1", "YESNO", STR0063 + AllTrim(MV_PAR03) + STR0064)	//"LayOut informado:"#" não é o padrão esperado para o PAF-ECF. Deseja ajustar defindo o LayOut para SINTEG05 ?"
	If !("SINTEG05"$Upper(ALLTRIM(MV_PAR03))) .AND. STFShowMessage("STBFMSinteg1") //"LayOut informado:" //" não é o padrão esperado para o PAF-ECF. Deseja ajustar defindo o LayOut para SINTEG05 ?" //"Atenção"
		MV_PAR03 := "SINTEG05"
	EndIf
	
	//Alimenta Parametros no Array para passar como parametro no CallProc
	DbSelectArea("SX1")
	SX1->(DbSetOrder(1))
	nTamSX1   := Len(SX1->X1_GRUPO)
	
	SX1->(DbSeek(Padr(cPerg,nTamSX1)))
	
	While !SX1->(EOF()) .AND. AllTrim(SX1->X1_GRUPO) == cPerg
		aItem := {}

		Aadd(aItem,SX1->X1_VAR01)
		Aadd(aItem,&("MV_PAR" + SX1->X1_ORDEM))

		Aadd(aParamPerg,aItem)
		SX1->(DbSkip())
	EndDo 
	
	//Chama rotina(RPC) para gerar arquivo na Retaguarda
	If !lPOS
		STFMessage("STBFMSinteg2", "RUN", STR0065, { || FR271CMyCall( "MATA940",Nil,aParamPerg)} )
		STFShowMessage("STBFMSinteg2")
	Else 
		//to do: chamada da função pelo componente de comunicação
		lProssegue := STBRemoteExecute(	"MATA940"		,;
										{ aParamPerg }	,;
										Nil				,;
										.F. 			,;
										@lRet			)   
		If lHomolPaf
			If lProssegue
				ConOut("Execução com sucesso  - MATA940")
			Else
				ConOut("erro na execução - MATA940")
			EndIf  
		EndIf
			
	EndIf

	//StartPath no servidor(RPC), local onde eh gerado o arquivo
	cPathSrv := STBFMPathSrv(lPos)				
	
	//Arquivo que será gerado no servidor(RPC)
	cFileSrv := AllTrim(MV_PAR04)	
	
	//Path local padrao PAF-ECF para armazenar o arquivo
	STBFMGerPath( @cPathLocal )
	
	//Nome do arquivo padrao PAF-ECF
	cFileLocal := STBFMNomeArq(lPOS)  	
				
	//Chama rotina(RPC) para copiar o conteudo do arquivo na pasta padrao do PAF-ECF
	STBFMGetFile( cPathSrv,	cFileSrv,	cPathLocal,	cFileLocal,	.T. ,lPOS)
	
	//Assina arquivo conforme previsto no PAF-ECF
	If File(cPathLocal + cFileLocal)
		STBFMSignPaf( cPathLocal + cFileLocal  )
	Else 
		STFMessage("STBFMSinteg3", "STOPPOPUP", STR0026 + cPathLocal + cFileLocal)  //"Não foi possível gerar o arquivo:"	
		STFShowMessage("STBFMSinteg3")
	EndIf
EndIf

Return Nil

//--------------------------------------------------------
/*/{Protheus.doc}STBFMSpedPaf
Gera arquivo "ATO COTEPE 09/08"(SpedFiscal) para o PAF-ECF
@author  	Varejo
@version 	P11.8
@since   	03/09/2012
@return  	Nil 
@obs      	LjxSpedPaf
@sample
/*/
//--------------------------------------------------------
Function STBFMSpedPaf(lPOS)  
  
Local cNomWiz	:=	"SPEDFIS"
Local cPerfil	:=	SuperGetMv("MV_PRFSPED",.F.,"")
Local aWizard	:=	{}  
Local aRet		:= 	{}
Local cPathSrv		:= ""	
Local cFileSrv		:= ""
Local cPathLocal	:= ""	
Local cFileLocal	:= ""
Local lProssegue	:= .F.
Local lRet			:= .F.
         
//Monta Wizard 
If SpedMntWiz(cNomWiz,cPerfil) 
	If !xMagLeWiz(cNomWiz,@aWizard,.T.)
		Return	//Se por algum motivo a leitura do CFP falhar aborta a rotina.
	EndIf                         
	
	//Limpa diretorio destino, mantendo como default a mesma pasta onde eh gerado o arquivo CTRAB do Sped(StarPath)
	aWizard[1][4]	:= ""
		
	//Deve informar o arquivo destino, caso nao tenha informado adota nome Default
	If Empty(AllTrim(aWizard[1][5]))                         	
		aWizard[1][5] := "SPEDFISPAF.TXT"
	EndIf

	If !lPOS
		STFMessage("STBFMSpedPaf1", "RUN", STR0065, { || FR271CMyCall( "SPEDFISCAL",Nil,aWizard)})	
		STFShowMessage("STBFMSpedPaf1")
	Else 

		lProssegue := STBRemoteExecute(	"SPEDFISCAL"		,;
										{aWizard}	,;
										Nil				,;
										.F. 			,;
										@lRet			)
		If lHomolPaf	
			If lProssegue
				ConOut("Execução com sucesso")
			Else
				ConOut("erro na execução")
			EndIf
		EndIf
	EndIf
	
	//StartPath no servidor(RPC), local onde eh gerado o arquivo
	cPathSrv := STBFMPathSrv(lPos)				
		
	//Arquivo que sera gerado no servidor(RPC)
	cFileSrv := AllTrim(aWizard[1][5])	
	
	//Path local padrao PAF-ECF para armazenar o arquivo
	STBFMGerPath( @cPathLocal )
	
	//Nome do arquivo padrao PAF-ECF
	cFileLocal := STBFMNomeArq(lPOS)

	//Chama rotina(RPC) para copiar o conteudo do arquivo na pasta padrao do PAF-ECF
	STBFMGetFile( cPathSrv,	cFileSrv,	cPathLocal,	cFileLocal,.T. , lPos)

	//Assina arquivo conforme previsto no PAF-ECF
	If File(cPathLocal + cFileLocal)
		STBFMSignPaf( cPathLocal + cFileLocal  )
	Else 
		STFMessage("STBFMSpedPaf2", "STOPPOPUP", STR0026 + cPathLocal + cFileLocal)	 //"Não foi possível gerar o arquivo:"
		STFShowMessage("STBFMSpedPaf2")
	EndIf		
EndIf

Return Nil
                                                           
//--------------------------------------------------------
/*/{Protheus.doc}STBFMModPaf
Gera arquivo Realiza o retorno do Modulo Usado no PafEcf 
@author  	Varejo
@version 	P11.8
@since   	03/09/2012
@return  	Caracter 
@obs      	LjxModPaf
/*/
//--------------------------------------------------------
Function STBFMModPaf()
Local cRet			:= ""

cRet	:= cModPaf

Return cRet

//--------------------------------------------------------
/*/{Protheus.doc}STBFMArqIdEmp
Cria arquivo PAFLISTA.TXT 
@author  	Varejo
@version 	P11.8
@since   	03/09/2012
@return  	Caracter 
@obs      	LjxArqIdEmp
@sample
/*/
//--------------------------------------------------------
Function STBFMArqIdEmp(cCnpjTotvs	, cNomeCom		, cMd5Master	, cCnpjCli	,;
 						lPos		, aRetInfoPAF 	)
Local cArquivo		:= ""
Local nHandle 		:= 0 						// Handle para tratamento do arquivo a ser utilizado
Local cPath			:= ""
Local cLinha		:= ""						//Conteúdo da linha
Local cBuffer		:= ""						//Conteúdo do arquivo
Local nSize 		:= 0						// Tamanho do arquivo a ser lido
Local nPos			:= 0						//Posição de leitura do conteúdo do arquivo
Local cVariavel		:= ""						//Variavel que será atualizada

Default	cCnpjTotvs 	:= ""
Default	cNomeCom    := ""
Default	cMd5Master  := ""
Default	cCnpjCli    := ""
Default aRetInfoPAF := Array(10)

If Len(aRetInfoPAF) <> 10
	ASize(aRetInfoPAF,0)
	aRetInfoPAF := Array(10)
EndIF

//PAF-ECF teste 106 do Roteiro 1.4 Ato Cotepe 0106: Armazenar CNPJ da TOTVS, nome comercial do PAF-ECF e MD5 do principal.
//arquivo executável, para não alterar a estrutura do SIGAMAT.EMP a validação será através do arquivo PAFEMP.TXT.		   
                           
//Path do Client                                                               
cPath 		:= GetClientDir()

//Caminho completo do arquivo(Path do client + nome do arquivo)
cArquivo 	:= cPath + "PAFEMP.TXT"

//Carrega dados da Versao Homologada 
If lHomolPaf
	cMd5Master	:= STBVerPAFECF("MD5MASTER")
Else
	cMd5Master := STBRETMD5()
EndIf
                                  
//PAF-ECF: Arquivo deverá ser criado quando não existir
If !File( cArquivo )
	STArqEmp()
EndIf

If File( cArquivo )
	//Abre arquivo com dados CNPJTOTVS, NomeComercial, MD5Principal, CNPJCliente
	nHandle := fOpen(cArquivo)
	
	If nHandle == -1
		STFMessage("STBFMArqIdEmp1", "STOPPOPUP", STR0066 + cArquivo) //"Ocorreu um erro ao ler o arquivo criptografado:"	
		STFShowMessage("STBFMArqIdEmp1")
	EndIf
	
	nSize 	:= FSeek( nHandle, 0, 2 )
	FSeek( nHandle, 0 )
	cBuffer := Space( nSize )	
	FRead( nHandle, @cBuffer, nSize )
	fClose(nHandle)
	  
	//Atualiza Posicao a ser lida
	nPos := At(Chr(10), cBuffer)
	
	While nPos > 0
		//Atualiza Linha
		cLinha := SubStr(cBuffer,1,nPos)
		
		//Atualiza Conteudo do arquivo
		cBuffer := SubStr(cBuffer,nPos+1,Len(cBuffer)-nPos)

		//Atualiza Posicao a ser lida na linha
		nPos := At(":", cLinha)

		//Atualiza o nome da Variavel
		cVariavel := "c" + SubStr(cLinha,1,nPos-1)
		                                                  		
		cLinha	:= SubStr(cLinha,nPos+1,Len(cLinha))
		If cVariavel == "cMd5Master"
			cLinha := Decode64(cLinha)
		Else
			cLinha := Encript(cLinha,0)					//Decript do conteúdo
			cLinha 	:= AllTrim(SubStr(cLinha,1,Len(cLinha)-1)) //PH -> Estava retornando um caracter a mais no final
		EndIf

		If cVariavel == "cCnpjTotvs"
			aRetInfoPAF[1]:= cLinha
        	cCnpjTotvs 	:= cLinha
		ElseIf cVariavel == "cNomeCom"
			aRetInfoPAF[2]:= cLinha
			cNomeCom	:= cLinha
		ElseIf cVariavel == "cMd5Master"
			aRetInfoPAF[3]:= cLinha
			cMd5Master	:= cLinha
		ElseIf cVariavel == "cCnpjCli"
			aRetInfoPAF[4]:= cLinha
			cCnpjCli	:= cLinha
		ElseIf cVariavel == "cNumSer"
			aRetInfoPAF[5]:= cLinha
		ElseIf cVariavel == "cVersCom"
			aRetInfoPAF[6]:= cLinha
		ElseIf cVariavel == "cRazao Social"
			aRetInfoPAF[7]:= cLinha
		ElseIf cVariavel == "cIE"
			aRetInfoPAF[8]:= cLinha
		ElseIf cVariavel == "cIM"
			aRetInfoPAF[9]:= cLinha
		ElseIf cVariavel == "cIEU"
			aRetInfoPAF[10]:= cLinha
		EndIf
		
		//Atualiza Posicao a ser lida
		nPos := At(Chr(10), cBuffer)
	End	
EndIf
	
Return Nil                   
 
                                                        
//--------------------------------------------------------
/*/{Protheus.doc}STBFMTipoDoc
Define o Tipo do Documento usado no registro R06 
@author  	Varejo
@version 	P11.8
@since   	03/09/2012
@return  	Caracter 
@obs      	LjxTipoDoc
/*/
//--------------------------------------------------------
Function STBFMTipoDoc(aRetWs, lIsArray, nPos)
Local aRet := {}

Default lIsArray:= .F.
Default nPos	:= 0

//aRet[1] - Contador de Comprovante Nao Fiscal
//aRet[2] - Contador de Relatorio Gerencial
//aRet[3] - Contador de Comprovante de Credito ou Debito
//aRet[4] - Tipo de Documento
//aRet[5] - Data de Impressao 
//aRet[6] - Hora de Impressoao dDataEmiss

If lIsArray .And. nPos > 0
	If aRetWs[nPos][22] > 0
		AADD( aRet, {0, aRetWs[nPos][22], 0, "RG", aRetWs[nPos][25], aRetWs[nPos][26]} )  //Relatorio Gerencial RG
		LjGrvLog("STBFMTipoDoc","R06 - NumContRg - aRet: ", aRet )
	EndIf
	
	If aRetWs[nPos][23] > 0
		AADD( aRet, {aRetWs[nPos][21], 0, aRetWs[nPos][23] , "CC", aRetWs[nPos][25], aRetWs[nPos][26]} ) //Comprovante de Credito ou Debito CC
		LjGrvLog("STBFMTipoDoc","R06 - NumContCdc - aRet: ", aRet )
	EndIf
Else
	
	If aRetWs:nNumContRg  > 0
		AADD( aRet, {0, aRetWs:nNumContRg, 0, "RG", aRetWs:cDataTef, aRetWs:cHoraTef} )  //Relatorio Gerencial RG
		LjGrvLog("STBFMTipoDoc","R06 - NumContRg - aRet: ", aRet )
	EndIf  
	             
	If aRetWs:nNumContCdc > 0
		AADD( aRet, {aRetWs:nNumContOnf, 0, aRetWs:nNumContCdc, "CC", aRetWs:cDataTef, aRetWs:cHoraTef} ) //Comprovante de Credito ou Debito CC
		LjGrvLog("STBFMTipoDoc","R06 - NumContCdc - aRet: ", aRet )
	EndIf
EndIf

Return aRet 

//--------------------------------------------------------
/*/{Protheus.doc}STBFMGerFile
Realiza a montagem do nome do arquivo que sera gerado para o PAF-ECF.  
@author  	Varejo
@version 	P11.8
@since   	03/09/2012
@return  	Caracter 
@obs      	LjxGerFile
/*/
//--------------------------------------------------------
Function STBFMGerFile( cTipo, lPOS )
Local cRet		:= ""
Local cPDV		:=	Space(TamSX3("L1_PDV")[1])           // Armazena o numero do PDV
Local aPDV		:=	{""}			// Retorno evento pegar PDV
Local aPrinter	:=	{}
Local lIsPafNfce:= STFGetCfg("lPAFNFCE") .Or. IIf(ExistFunc("LjPafNFCe"),LjPafNFCe(),.F.)	 //Usa PAF-NFC-e c/ Impressora Não Fiscal

DEFAULT cTipo := ""        // Define a posicao inicial na geração do nome do arquivo

If lIsPafNfce
	cPDV:= AllTrim(SLG->LG_PDV)
Else 
	If lPOS
		aPrinter := STFFireEvent( ProcName(0) , "STGetPDV" , aPDV )		
		If ValType(aPrinter) <> "A" .OR. Len(aPrinter) == 0 .OR. aPrinter[1] <> 0 .OR. Len(aPDV) < 1     
			STFMessage("STBFMGerFile1", "STOP", STR0067)	//"Erro ao pegar o número do PDV após a impressão do pedido. Verifique o ECF."
			STFShowMessage("STBFMGerFile1")
		Else
			cPDV := aPDV[1]
		EndIf
	Else
		If IFPegPDV(nHdlECF, @cPDV) <> 0 
			STFMessage("STBFMGerFile2", "STOP", STR0067)	//"Erro ao pegar o número do PDV após a impressão do pedido. Verifique o ECF."
			STFShowMessage("STBFMGerFile2")
		EndIf 
	EndIf
Endif 

cRet := cTipo + Dtos( dDataBase ) + Right( cPDV, 2 ) + AllTrim(SM0->M0_CODIGO) + AllTrim(SM0->M0_CODFIL) + ".TXT"

Return cRet

//--------------------------------------------------------
/*/{Protheus.doc}STBFMSitTrib
 Realizao o retorno da situação tributaria do produto. 
@author  	Varejo
@version 	P11.8
@since   	03/09/2012
@return  	Caracter 
@obs      	LjxSitTrib
/*/
//--------------------------------------------------------
Function STBFMSitTrib(	cProduto	, cTipo 	, cTabPesq , lPosSA1 ,;
 						cAliasSA1	, cRecTES	)
Local cRetValue := ""        							// Contem a situação tributaria do produto
Local cF4_TS	:= ""
Local cTpSolCf	:= ""             //Parametro para validacao do tipo de cliente para o calculo do solidario
Local cTesPad	:= ""
Local nMV_ICMPAD:= 0
Local nAliq		:= 0
Local nX		:= 0
Local lExcecaoFcl:= .F.
Local lAlqISSIse:= .F.
Local lFindProd := .F.
Local aAreaTab	:= {}
Local aLjExcecao:= {}
Local lCfgTrib := If(FindFunction("LjCfgTrib"), LjCfgTrib(), .F.) //Verifica se Configurador de Tributos esta habilitado

DEFAULT cTabPesq:= ""
DEFAULT cTipo	:= ""
DEFAULT lPosSA1	:= .T.
DEFAULT cAliasSA1:= "SA1"
DEFAULT cRecTES := ""

AAdd(aAreaTab,SB1->(GetArea()))
AAdd(aAreaTab,SA1->(GetArea()))
AAdd(aAreaTab,SF4->(GetArea()))
AAdd(aAreaTab,SB0->(GetArea()))

SB1->(DbSetOrder(1)) //B1_FILIAL + B1_COD

//Posiciona o SA1
If lPosSA1
	(cAliasSA1)->(DbSeek( xFilial("SA1") + SuperGetmv("MV_CLIPAD") + SuperGetmv("MV_LOJAPAD") ) )
EndIf

//Posiciona o SB1
lFindProd :=SB1->(DbSeek( xFilial("SB1") + cProduto ) )

If lFindProd	
	cRetValue := If(lCfgTrib, LjCfgSitTrb(, .T.), "") //Busca situacao tributaria no Configurador de tributos
		
	If Empty(cRetValue)
		cTpSolCf	:= SuperGetMv("MV_TPSOLCF")             //Parametro para validacao do tipo de cliente para o calculo do solidario
		cTesPad	:= AllTrim(SuperGetMV("MV_TESSAI"))
		nMV_ICMPAD:= SuperGetMv("MV_ICMPAD")
	
		//Posiciona o SF4
		If Empty(cRecTES)
			cF4_TS := AllTrim(SB1->B1_TS)
			If Empty(cF4_TS)
				SF4->(DbSeek(xFilial("SF4")+cTesPad))
			Else
				SF4->(DbSeek(xFilial("SF4")+cF4_TS))
			EndIf
		Else
			SF4->(DbSeek(xFilial("SF4")+cRecTES))
		EndIf
	
		aLjExcecao := LjxExcecao(.T.)
		lExcecaoFcl:= Len(aLjExcecao) > 0
	
		/*Segundo regras do Fiscal para considerar a isenção de ISS
		é necessário a regra abaixo para que não seja feito nenhum calculo*/
		If SF4->F4_ICM == "N" .And. SF4->F4_ISS == "N"
			//	Foi avaliado somente permitir a configuração dos tipos 07 e 06
			//	no caso do Isento pois os outros tipos se referem a modalidades
			//	que não são comumente usadas no PDV
			If SF4->F4_LFISS == "I" .And. ((ALLTRIM(SF4->F4_CSTISS) $ "07|06") .Or. (Empty(ALLTRIM(SF4->F4_CSTISS))))
				If ALLTRIM(SF4->F4_CSTISS) == "07" //Nao tributado
					cRetValue := "NS"
				ElseIf ALLTRIM(SF4->F4_CSTISS) == "06" //Isento
					cRetValue := "IS" 
				Else                          
					//Caso não esteja configurado, considero isento
					cRetValue := "IS" //Isento
				EndIf
				lAlqISSIse := .T.
			ElseIf SF4->F4_LFISS == "O"	// Outros
				cRetValue := "NS"
				lAlqISSIse := .T.
			EndIf
		EndIf
	
		If !lAlqISSIse
			If SF4->F4_ISS == "S" .AND. ( ( AllTrim((cAliasSA1)->A1_RECISS) == "1" .AND. SuperGetMv("MV_DESCISS",,.F.) ) .OR.;
				( AllTrim((cAliasSA1)->A1_RECISS) <> "1" ) )
				
				If SB1->B1_ALIQISS > 0
					cRetValue := "S" + AllTrim (StrZero( SB1->B1_ALIQISS,5,2 ))
				Else
					cRetValue := "S" + AllTrim (StrZero( SuperGetMv("MV_ALIQISS"),5,2 ))
				EndIf
			ElseIf If(SF4->(ColumnPos("F4_MKPSOL")) > 0,AllTrim(SF4->F4_MKPSOL)<>"1",.T.) .And. ;
				(( SB1->B1_PICMRET > 0) .Or.;
				(SB1->B1_PICMRET > 0 .AND. ALLTRIM(SF4->F4_SITTRIB) == "60") .Or. ;
				(lExcecaoFcl .AND. (aLjExcecao[3] > 0 .OR. aLjExcecao[16] > 0 )) ) .And.;
				((cAliasSA1)->A1_TIPO $ cTpSolCf) .AND. (SF4->F4_BSICMST <> 100)
				
				cRetValue := "F"										// Substituicao tributaria (Icms Solidario)				
			ElseIf (SF4->F4_BASEICM > 0 .AND. SF4->F4_BASEICM < 100) .Or. ;
				(lExcecaoFcl .AND. (aLjExcecao[14] > 0) .AND. (aLjExcecao[14] < 100))// Com redução de Icms na Base de Cálculo do Imposto
			
				//Posiciona o SB0
				SB0->(DbSeek(xFilial("SB0")+SB1->B1_COD))
			
				nAliq := SB0->B0_ALIQRED
				
				If ExistBlock("LJ7017")
					LjGrvLog(Nil,"Ponto de Entrada LJ7017 será executado")
					nAliq := ExecBlock("LJ7017",.F.,.F.)
					LjGrvLog(Nil,"Ponto de Entrada LJ7017 - Retorno", nAliq)
			
					If Valtype(nAliq) <> "N" .OR. nAliq >= 100
					nAliq := SB0->B0_ALIQRED
					LjGrvLog(Nil,"Ponto de Entrada LJ7017 - alterado para B0_ALIQRED", nAliq)
					EndIf
				EndIf
				
				cRetValue := "T" + AllTrim( StrZero( nAliq , 5, 2 ) )
				
			ElseIf SF4->F4_LFICM == "I"								// Isento
				If AllTrim(SF4->F4_SITTRIB) == "41"
					cRetValue := "N"
				Else
					cRetValue := "I"
				EndIf
				
			ElseIf SF4->F4_LFICM == "N" .OR. SF4->F4_LFICM == "O"	// N„o sujeito a ICMS
				cRetValue := "N"
			Else // Com ICMS
				
				nAliq := AliqIcms("N","S",(cAliasSA1)->A1_TIPO,"I",NIL,.T.)
				
				If nAliq == 0
					nAliq := SB1->B1_PICM
					
					If nAliq == 0
						nAliq := nMV_ICMPAD
					EndIf
				EndIf
				
				cRetValue := "T" + AllTrim( StrZero( nAliq, 5, 2 ) )
			ENDIF
		EndIf
	
		If cTipo == "P"
			If lAlqISSIse
				cRetValue := SubStr(cRetValue,1,2)
			Else
				cRetValue := SubStr(cRetValue,1,1)
			EndIf
		EndIf
	EndIf
EndIf

For nX := 1 to Len(aAreaTab)
	RestArea(aAreaTab[nX])
Next nX

Return cRetValue

//--------------------------------------------------------
/*/{Protheus.doc}STBFMPathSrv
Retorna  StatrPath do Servidor RPC 
@author  	Varejo
@version 	P11.8
@since   	03/09/2012
@return  	Caracter 
@obs      	LjxPathSrv
/*/
//--------------------------------------------------------
Function STBFMPathSrv(lPOS,cChave)    
Local aRet	:= {}  
Local cRet	:= "" 
Local cBarra:= IIF(GetRemoteType()==2,"/","\")

Default cChave := "StartPath"

//StartPath no servidor(RPC) 
If !lPOS
	aRet :=	FR271CMyCall( "GetSrvProfString",Nil,cChave,"")
	LjGrvLog("STBFMPathSrv",'aRet',aRet)
	If Len(aRet) > 0
		cRet := aRet[1]
		If Valtype(cRet) == "C"
			If (SubStr(cRet,1,1)<>cBarra) .And. (cChave == "StartPath")
				cRet	:=	cBarra+cRet
			EndIf
			
			If (SubStr(cRet,Len(cRet),1)<>cBarra)
				cRet	+=	cBarra
			EndIf
		Else
			cRet := "\"
		EndIf	
	EndIf
Else

   	lProssegue := STBRemoteExecute("GetSrvProfString",;
					{ cChave ,""  }	,;
					Nil				,;
					.F. 			,;
					@cRet			) 
	LjGrvLog("STBFMPathSrv",'cRet',cRet)
EndIf

If lHomolPaf
	If Valtype(cRet) == "C"
		ConOut("Execução com sucesso - GetSrvProfString")
	Else
		ConOut("Erro na execução - GetSrvProfString")
	EndIf
EndIf
                 
Return cRet


//--------------------------------------------------------
/*/{Protheus.doc}STBFMNomeArq
Realiza a montagem do nome do arquivo para opcao 12 no menu fiscal 
@author  	Varejo
@version 	P11.8
@since   	03/09/2012
@return  	Caracter 
@obs      	LjxNomeArq
@sample
/*/
//--------------------------------------------------------
Static Function STBFMNomeArq(lPOS)	 

Local cDiaMes   := SubStr(StrTran(DtoC(Date()), "/"), 1 , Len(StrTran(DtoC(Date()), "/")) - 2) 
Local cAno      := cValToChar(Year(Date())) 
Local cNomeArq  := ""
Local cLaudo	  := ""

Default lPos := .F.

cLaudo	:= STBVerPAFECF("NUMLAUDO")
cNomeArq := cLaudo + cDiaMes + cAno + StrTran( Time(), ":") + ".txt"

Return cNomeArq     


//--------------------------------------------------------
/*{Protheus.doc}STBDadosEcf
Atualiza aDadosEcf.
@param1 	lPos - PDV Pos?
@author  	Varejo
@version 	P11.8
@since   	02/08/2013
@return  	Nil 
@obs      	LjDadosEcf
@sample
*/
//--------------------------------------------------------
Function STBDadosEcf(lPOS)
Local cMfAdic 	:= ""
Local cTipoEcf	:= ""
Local cModelo	:= ""
Local cVerSB	:= ""
Local cDtInsSB	:= ""
Local cHrInsSB	:= ""
Local cCodECF	:= ""
Local nUsuEcf	:= 0
Local cSeriePDV	:= ""
Local cMarca	:= "" 
Local cRet 		:= "" 
Local aRet		:= {}
Local aDados	:= {}   
Local lRedZPend	:= .F.
Local lOnlyMenuFiscal := If(lPos,STFGetCfg( "lOnlyMenuFiscal" ),.F.)

If Len(aDadosEcf) < 1 .AND. !lOnlyMenuFiscal
    If lPOS
		// Recupera letra indicativa de MF adicional
	    aDados := {"24", cMfAdic}
		aRet :=	STFFireEvent(	ProcName(0) ,;		// Nome do processo
								"STPrinterStatus"	,;		// Nome do evento
								aDados )
		
		If Len(aRet) > 0 .AND. aRet[1] == 0 .AND. Len(aDados) > 1 .AND. !Empty(aDados[2])
	    	cMfAdic := aDados[2]
	 	ElseIf Len(aRet) = 0 .OR. aRet[1] <> 0
	 		Return .T.
	 	EndIf	
		
		// Recupera Tipo de ECF 
	    aDados := {"25", cTipoEcf}
		aRet :=	STFFireEvent(	ProcName(0) ,;		// Nome do processo
	 							"STPrinterStatus",;		// Nome do evento
	 							aDados )
		
		If Len(aRet) > 0 .AND. aRet[1] == 0 .AND. Len(aDados) > 1 .AND. !Empty(aDados[2])
	    	cTipoEcf := AllTrim(aDados[2])
	 	ElseIf Len(aRet) = 0 .OR. aRet[1] <> 0
	 		Return .F.
	 	EndIf
	 	
	 	// Recupera Marca do ECF 
	    aDados := {"26", cMarca}
		aRet :=	STFFireEvent(	ProcName(0) ,;		// Nome do processo
	 							"STPrinterStatus",;		// Nome do evento
	 							aDados )
		
		If Len(aRet) > 0 .AND. aRet[1] == 0 .AND. Len(aDados) > 1 .AND. !Empty(aDados[2])
	    	cMarca := AllTrim(aDados[2])
	 	ElseIf Len(aRet) = 0 .OR. aRet[1] <> 0
	 		Return .F.
	 	EndIf
		
		// Recupera Modelo do ECF 
	    aDados := {"27", cModelo}
		aRet :=	STFFireEvent(	ProcName(0) ,;		// Nome do processo
	 							"STPrinterStatus",;		// Nome do evento
	 							aDados )
		
		If Len(aRet) > 0 .AND. aRet[1] == 0 .AND. Len(aDados) > 1 .AND. !Empty(aDados[2])
	    	cModelo := AllTrim(aDados[2])
	 	ElseIf Len(aRet) = 0 .OR. aRet[1] <> 0
	 		Return .F.
	 	EndIf
	
		
		// Recupera Versão atual do Software Basico do ECF gravada na MF 
	    aDados := {"28", cVerSB}
		aRet :=	STFFireEvent(	ProcName(0) ,;		// Nome do processo
	 							"STPrinterStatus",;		// Nome do evento
	 							aDados )
		
		If Len(aRet) > 0 .AND. aRet[1] == 0 .AND. Len(aDados) > 1 .AND. !Empty(aDados[2])
	    	cVerSB := AllTrim(aDados[2])
	 	ElseIf Len(aRet) = 0 .OR. aRet[1] <> 0
	 		Return .F.
	 	EndIf
		
		// Recupera Data de instalacao da versao atual do Software Basico do ECF
	    aDados := {"29", cDtInsSB}
		aRet :=	STFFireEvent(	ProcName(0) ,;		// Nome do processo
	 							"STPrinterStatus",;		// Nome do evento
	 							aDados )
		
		If Len(aRet) > 0 .AND. aRet[1] == 0 .AND. Len(aDados) > 1 .AND. !Empty(aDados[2])
	    	cDtInsSB := AllTrim(aDados[2])
	 	ElseIf Len(aRet) = 0 .OR. aRet[1] <> 0
	 		Return .F.
	 	EndIf
	
		// Recupera Horario de instalacao da versao atual do Software Basico do ECF
	    aDados := {"30", cHrInsSB}
		aRet :=	STFFireEvent(	ProcName(0) ,;		// Nome do processo
	 							"STPrinterStatus"	,;		// Nome do evento
	 							aDados )
		
		If Len(aRet) > 0 .AND. aRet[1] == 0 .AND. Len(aDados) > 1 .AND. !Empty(aDados[2])
	    	cHrInsSB := AllTrim(aDados[2])
	 	ElseIf Len(aRet) = 0 .OR. aRet[1] <> 0
	 		Return .F.
	 	EndIf
	   		
		// Recupera Codigo Nacional do ECF
	    aDados := {"40", cCodECF}
		aRet :=	STFFireEvent(	ProcName(0) ,;		// Nome do processo
								"STPrinterStatus",;		// Nome do evento
	 							aDados )
		
		If Len(aRet) > 0 .AND. aRet[1] == 0 .AND. Len(aDados) > 1 .AND. !Empty(aDados[2])
	    	cCodECF := AllTrim(aDados[2])
	 	ElseIf Len(aRet) = 0 .OR. aRet[1] <> 0
	 		Return .F.
	 	EndIf
	 		
		// Recupera N de ordem do usuario do ECF relativo respectiva Reducao Z
		aDados := {space(20), Nil}
		aRet := STFFireEvent(	ProcName(0) ,;		// Nome do processo
	 							"STGetPDV"	,;		// Nome do evento
	 							aDados )
	 													  
		If Len(aRet) > 0 .AND. aRet[1] == 0 .AND. Len(aDados) > 0 .AND. !Empty(aDados[1])
			cRet := AllTrim(aDados[1])
		ElseIf Len(aRet) = 0 .OR. aRet[1] <> 0
			Return .F.
		EndIf
		
		nUsuEcf := Val(cRet) 
		
		// Serie do Ecf 
		aDados := {space(30), Nil} 
		aRet := STFFireEvent(	ProcName(0) ,;		// Nome do processo
	 													  "StGetSerie"																,;		// Nome do evento
	 													  aDados )
	 													  	
		If Len(aRet) > 0 .AND. aRet[1] == 0 .AND. Len(aDados) > 0 .AND. !Empty(aDados[1])
			cSeriePDV := AllTrim(aDados[1])
		ElseIf Len(aRet) = 0 .OR. aRet[1] <> 0
			Return .F.
		EndIf  
	
		//Grava em arquivo para que possa recuperar as informações quando ECF estiver desligado
		//verifica se a Z esta pendente porque qdo nesse status nao captura todas as informações
		// do ECF e causa falta de informação prejudicando o relatorio de Movimento por ECF
		aRet1 :=	STFFireEvent(	ProcName(0)			,;		// Nome do processo
									"STPrinterStatus"	,;		// Nome do evento
									{"8"," "} )
		
		//Verifica se Redução Z esta pendente 
		lRedZPend :=  Len(aRet) > 0 .AND. aRet[1] == 10
	
	Else 
		If IFStatus(nHdlECF, "24", @cMfAdic) <> 0  
			Return .F.
		EndIf                                      
		
		// Recupera Tipo de ECF 
		If IFStatus(nHdlECF, "25", @cTipoEcf) <> 0  
			Return .F.
		EndIf
		
		// Recupera Modelo do ECF 
		If IFStatus(nHdlECF, "26", @cMarca) <> 0  
			Return .F.
		EndIf  
		
		// Recupera Modelo do ECF 
		If IFStatus(nHdlECF, "27", @cModelo) <> 0  
			Return .F.
		EndIf  
		
		// Recupera Versão atual do Software Basico do ECF gravada na MF 
		If IFStatus(nHdlECF, "28", @cVerSB) <> 0  
			Return .F.
		EndIf 
		
		// Recupera Data de instalacao da versao atual do Software Basico do ECF
		If IFStatus(nHdlECF, "29", @cDtInsSB) <> 0  
			Return .F.
		EndIf  
		
		// Recupera Horario de instalacao da versao atual do Software Basico do ECF
		If IFStatus(nHdlECF, "30", @cHrInsSB) <> 0  
			Return .F.
		EndIf    
		
		// Recupera Codigo Nacional do ECF
		If IFStatus(nHdlECF, "40", @cCodECF) <> 0  
			Return .F.
		EndIf    
		
		// Recupera N de ordem do usuario do ECF relativo respectiva Reducao Z
		If IFPegPDV(nHdlECF, @cRet) <> 0 
			Return .F.
		EndIf  
		nUsuEcf := Val(cRet)
		
		// Serie do Ecf 
		If IFPegSerie(nHdlECF, @cSeriePDV) <> 0  
			Return .F.
		EndIf	
		
		lRedZPend := (IFStatus(nHdlECF, "8", @cRet) == 10)
	EndIf 
	
	If ! ("BEMATECH" $ Upper(cMarca))	
		cDtInsSB := Stuff(cDtInsSB,3,0,"/") 
		cDtInsSB := Stuff(cDtInsSB,6,0,"/")
		cDtInsSB := Ctod(cDtInsSB)
		cDtInsSB := Dtos(cDtInsSB) //Formato: AAAAmmDD
	EndIf
	                          
	//Atualiza Matriz
	aAdd(aDadosEcf, {"24"	,	cMfAdic})
	aAdd(aDadosEcf, {"25"	,	cTipoEcf})
	aAdd(aDadosEcf, {"26"   ,   cMarca})
	aAdd(aDadosEcf, {"27"	,	cModelo})
	aAdd(aDadosEcf, {"28"	,	cVerSB})
	aAdd(aDadosEcf, {"29"	,	cDtInsSB})
	aAdd(aDadosEcf, {"30"	,	cHrInsSB})
	aAdd(aDadosEcf, {"40"	,	cCodECF})
	aAdd(aDadosEcf, {"PDV"	,	nUsuEcf})
	aAdd(aDadosEcf, {"SERIE",	cSeriePDV})
	aAdd(aDadosEcf, {"IE",	Alltrim(SM0->M0_INSC)})
	aAdd(aDadosEcf, {"CNPJ",	Alltrim(SM0->M0_CGC)})	
	
    If !lRedZPend
		STBLeCria(.T.,aDadosEcf, .T.)
	EndIf
EndIf
	
Return Nil    

//--------------------------------------------------------
/*{Protheus.doc}STBLeCria
Cria e le arquivo contando infos ECF	
@param1		lCria - Cria o arquivo 
@author  	Varejo
@version 	P11.8
@since   	02/08/2013
@return  	Nil 
@obs      	LjDadosEcf
@sample
*/
//--------------------------------------------------------
Static Function STBLeCria( lCria , aConteudoTXT, lECFInfo)
Local nHandleTXT:= 0
Local nX		:= 0
Local cPathSmart:= ""
Local cSerPDV	:= ""
Local cNomeArq	:= "DTECF.LOJ"
Local cConteudo	:= ""
Local cVarTXT	:= ""
Local cDadoTXT	:= ""
Local cVariavel	:= ""
Local cCRECFPA	:= ""
Local cMsg		:= ""
Local lRet		:= .T.
Local lContinua	:= .F.
Local lOK		:= .F.
Local aSLG		:= {}
Local aTXT		:= {}

DEFAULT lCria			:=	.F.
DEFAULT aConteudoTXT	:=	{}
Default lECFInfo		:= .F.

cPathSmart := GetClientDir()

If lCria .AND. Len(aConteudoTXT) > 0	
	If File(cPathSmart + cNomeArq)
		FErase(cPathSmart + cNomeArq)
	EndIf
	nHandleTXT := FCREATE( cPathSmart + "Dado.TXT", FC_NORMAL )
	
	If nHandleTXT < 0 
		If lHomolPaf
			Conout(" STBFiscalMenu -> Erro ao criar arquivo " + cPathSmart + cNomeArq) //"Erro ao criar arquivo "
		EndIf
	Else
		cConteudo := ""
		For nX := 1 to Len(aConteudoTXT)
			If aConteudoTXT[nX][1] == "PDV" //Campo numerico
				cConteudo += aConteudoTXT[nX][1] + "|" + IIf(aConteudoTXT[nX][2] == 0, "1" ,cValToChar(aConteudoTXT[nX][2])) + CHR(10)	 
				cVariavel += aConteudoTXT[nX][1] + "|" + IIf(aConteudoTXT[nX][2] == 0, "1" ,cValToChar(aConteudoTXT[nX][2])) + "#"
			Else
				cConteudo += aConteudoTXT[nX][1] + "|" + IIf(empty(AllTrim(aConteudoTXT[nX][2])), "  " ,aConteudoTXT[nX][2]) + CHR(10)
				cVariavel += aConteudoTXT[nX][1] + "|" + IIf(empty(AllTrim(aConteudoTXT[nX][2])), "  " ,aConteudoTXT[nX][2]) + "#"
			EndIf	
		Next nX
		FWRITE( nHandleTXT, cConteudo, LEN( cConteudo ) )
		FCLOSE( nHandleTXT )
		FRENAME(cPathSmart + "Dado.TXT" ,cPathSmart + cNomeArq)
		FERASE(cPathSmart + "Dado.TXT") 
		If lHomolPaf
			cMsg := " STBFiscalMenu - STBLeCria -> Arquivo " + cPathSmart + cNomeArq + " Gerado com Sucesso"
			Conout(cMsg)
			LjGrvLog(NIL,cMsg)
		EndIf

		If lECFInfo
			If lTotvsPDV
				cConteudo := Upper(AllTrim(STFGetStat("IMPFISC")))
				cSerPDV	:= AllTrim(STFGetStat("SERPDV"))
				cCRECFPA:= AllTrim(STFGetStat("CRECFPA"))
			Else
				cConteudo := Upper(AllTrim(LjGetStation("IMPFISC")))
				cSerPDV := AllTrim(LjGetStation("SERPDV"))
				cCRECFPA:= AllTrim(LjGetStation("CRECFPA"))
			EndIf
			
			aSLG	:=	{;	
							{"LG_ECFINFO"	, AllTrim(cVariavel)},;
							{"LG_PAFMD5"	, MD5(AllTrim(cVariavel+cConteudo),2) },;
							{"LG_SERPDV"	, cSerPDV },;
							{"LG_CRECFPA"	, cCRECFPA};
						}
			cMsg := 'STBLeCria - cVariavel :' + cVariavel
			Conout(cMsg)
			LjGrvLog(NIL,cMsg)
			
			cMsg := "STBLeCria - cConteudo :" + cConteudo
			Conout(cMsg)
			LjGrvLog(NIL,cMsg)
			
			If lTotvsPDV
				cConteudo := STFGetStat("ECFINFO")
			Else
				cConteudo := LjGetStation("ECFINFO")
			EndIf
			
			SetStat( xFilial("SLG") , Iif(lTotvsPDV , STFGetStat("CODIGO") , LjGetStation("CODIGO") ),  aSLG)
			
			If lTotvsPDV
				STBRemoteExecute( "SetStat" , { xFilial("SLG") , STFGetStation("CODIGO") , aSLG }, Nil, .F. , @lOk )
			Else
				FR271CMyCall("SetStat",{"SLG"},xFilial('SLG'),LjGetStation("CODIGO") , aSLG)				
			EndIf
			lContinua := .T.
			
			lRet := lRet .AND. lContinua	
		EndIf	
	EndIf
	
ElseIf !lCria
	
	aTXT := STWReadFile( cPathSmart , cNomeArq, 0, .F. ) //Pega conteudo de cFile , no caminho cPathDLLArq com indice 0 e permite a deleção do arquivo 

	If ValType(aTXT) == "A" .AND. Len(aTXT) > 1
		aConteudoTXT := {}
		For nX := 1 To Len(aTXT)
			If !Empty(AllTrim(aTXT[nX]))				
				cVarTXT	:= Substr(aTXT[nX] ,1,At("|",aTXT[nX])-1)
				cDadoTXT	:= Substr(aTXT[nX] ,At("|",aTXT[nX])+1,Len(aTXT[nX]))
				If cVarTXT == "PDV" //Campo numerico
					Aadd( aConteudoTXT , {cVarTXT,Val(cDadoTXT)})
				Else				
					Aadd( aConteudoTXT , {cVarTXT,cDadoTXT} )
				EndIf	
			EndIf							
		Next nX				
	EndIf
EndIf	

Return lRet     

//--------------------------------------------------------
/*{Protheus.doc}STWReadFile
Le o arquivo	
@param1		cPath - Caminho o arquivo 
@param2		cFile - Nome do arquivo
@param3		nRecNo - Posicao do arquivo 
@param4		lDelFile - Apaga o arquivo ?
@author  	Varejo
@version 	P11.8
@since   	02/08/2013
@return  	aRet - Linhas do arquivo 
@obs      	STWReadFile
@sample
*/
//--------------------------------------------------------
Static Function STWReadFile( cPath, cFile, nRecNo, lDelFile )
Local aRet	 		:= {}		//array de retorno 
Local nHandle		:= 0		//handle do arquivo
Local cLine			:= ""		//conteudo a ser adicionado no array
Local nLength		:= 0        //bytes lidos
Local nBytesCrLf	:= 2      	//bytes
Local lProcessa		:= .T.		//sinaliza erro na leitura
                        
Default cPath			:= "" 		//Path do arquivo
Default cFile			:= ""       //Nome do arquivo
Default nRecNo			:= 0		//Recno para leitura a partir de uma posicao, quando 0(zero) inicio do arquivo
Default lDelFile		:= .F.		//Delete arquivo apos leitura finalizada(nRecno==0)

    
//Verifica se o arquivo existe
If !File(cPath + cFile)
	lProcessa := .F.                   
	cLine	:= STR0068 + cPath + cFile //"Arquivo não encontrado:"											//"Arquivo não encontrado:"
	Aadd(aRet,cLine) 
EndIf
     
//Abre o arquivo
If lProcessa
	nHandle := FT_FUse(cPath + cFile)
	If nHandle = -1
		lProcessa 	:= .F.	
		cLine		:= STR0069 + cPath + cFile		//"Não foi possível abrir o arquivo:"
		Aadd(aRet,cLine) 
	EndIf
EndIf
  
//Realiza leitura do arquivo texto
If lProcessa
	//Posiciona o cursor no inicio ou no ponto onde parou
	If nRecNo == 0
		FT_FGoTop() 	
	Else
		FT_FGoto( nRecNo )
	EndIf
	
	While !FT_FEOF() //.OR. nLength < nMaxLength
		 
		cLine 	:= FT_FReadLn() // Retorna dados da linha corrente
		        
		nLength += Len(cLine) + nBytesCrLf //Soma 2 bytes da linha
		
		Aadd(aRet,cLine) //Inclui linha na Array
		
		//Proxima linha
		FT_FSKIP()
		
		nRecNo	:= FT_FRecno() // Retorna o ponteiro da linha atual
	End              
	
	//Se final de arquivo(EOF), sinaliza que terminou a leitura
	If FT_FEOF()                        
		nRecNo := 0
	EndIf
	
	//Sinaliza na ultima posicao do array se finalizou leitura do arquivo(nRecNo=0) ou (nRecNo=Recno onde parou)
	Aadd(aRet,Str(nRecNo))
	
	// Fecha o Arquivo
	FT_FUSE()
	
	//Remove arquivo lido
	If nRecNo == 0 .AND. lDelFile
		FErase(cPath + cFile)
	EndIf
EndIf	

Return aRet           

//--------------------------------------------------------
/*{Protheus.doc}STBBuscaDados
Busca Informações do ECF	
@param1		cMfAdic - Memoria adicional 
@param2		cTipoEcf - Tipo do ECF
@param3		cModelo - Modelo do ECF 
@param4		cVerSB - Versao do Software Basico
@param5		cDtInsSB - Data de Instalação do Software Basico 
@param6		cHrInsSB - Hora de Instalação do software Basico
@param7		cCodECF - Codigo do ECF
@param8		cSeriePDV - Serie do PDV
@author  	Varejo
@version 	P11.8
@since   	02/08/2013
@return  	NIL
@obs      	STBBuscaDados
@sample
*/
//--------------------------------------------------------
Function STBBuscaDados(cMfAdic , cTipoEcf, cModelo, cVerSB, ;
                     cDtInsSB, cHrInsSB, cCodECF, nUsuEcf,;
                     cSeriePDV, cMarcaEcf , cIEECF, cCnpjECF)
Local lRet := .T. 

// Recupera letra indicativa de MF adicional
STBGetInfEcf("24",@cMfAdic)

// Recupera Tipo de ECF 
STBGetInfEcf("25",@cTipoEcf)

//Recupera Marca do ECF
STBGetInfEcf("26",@cMarcaEcf)

// Recupera Modelo do ECF  
STBGetInfEcf("27",@cModelo)

// Recupera Versão atual do Software Basico do ECF gravada na MF 
STBGetInfEcf("28",@cVerSB)

// Recupera Data de instalacao da versao atual do Software Basico do ECF
STBGetInfEcf("29",@cDtInsSB)

// Recupera Horario de instalacao da versao atual do Software Basico do ECF
STBGetInfEcf("30",@cHrInsSB)

// Recupera Codigo Nacional do ECF
STBGetInfEcf("40",@cCodECF)

// Recupera N de ordem do usuario do ECF relativo respectiva Reducao Z
STBGetInfEcf("PDV",@nUsuEcf)

//Serie do ECF
STBGetInfEcf("SERIE",@cSeriePDV)

//IE do ECF
STBGetInfEcf("IE",@cIEECF)

//Cnpj do ECF
STBGetInfEcf("CNPJ",@cCnpjECF)

Return lRet

//--------------------------------------------------------
/*{Protheus.doc}STBGetInfEcf
Busca Informações do ECF	
@param1		cTipo - Tipo da Informação
@param2		cValor - Valor da Informação
@author  	Varejo
@version 	P11.8
@since   	02/08/2013
@return  	NIL
@obs      	STBGetInfEcf
@sample
*/
//--------------------------------------------------------
Function STBGetInfEcf(cTipo, cValor )
Local nPos			

//PAF-ECF: Atualiza dados do ECF para ser utilizado no Movimento por ECF

If Len(aDadosEcf) == 0 //Caso necessario busca do arquivo de backup, quando o ECF estiver desligado
	STBLeCria( .F. , @aDadosEcf)
EndIf

nPos 	:= Ascan(aDadosEcf, { |x| x[1] == cTipo } )

If nPos > 0
	cValor 	:= aDadosEcf[nPos][2]
	
	If Empty(AllTrim(cValor)) .AND. (cTipo == "29" .OR. cTipo == "30")
		STBLeCria( .F. , @aDadosEcf)
		nPos 	:= Ascan(aDadosEcf, { |x| x[1] == cTipo } )
		If nPos > 0
			cValor 	:= aDadosEcf[nPos][2]
		EndIf				
	EndIf
EndIf

Return Nil

//--------------------------------------------------------
/*{Protheus.doc}STBMenFis
Menu Fiscal PAF-ECF	
@param1		lFrontMenu - Menu Front?
@param2		lPOS - PDV POS? 
@param2		lECFOK - ECF ok?
@author  	Varejo
@version 	P11.8
@since   	02/08/2013
@return  	NIL
@obs      	STBMenFis
@sample
*/
//--------------------------------------------------------
FUNCTION STBMenFis(lFrontMenu, lPOS, lECFOK)
Local oDlg
Local oTPane1
Local oTPane2
Local oOpcao                       // Objeto para as Opções Disponiveis para o Usuário
Local lMenFisOnLog:= IsInCallStack("LjMenFiLog")//Valida se foi chamado Menu Fiscal da Tela de Login
Local lConfirma := .T.      
Local cOpcao	:= SPACE(02)       // Opção a ser selecionada pelo usuário
Local dDataIni	:= CTOD("")        // Data Inicial da Memoria Fiscal
Local dDataFim	:= CTOD("")        // Data Final da Memoria Fiscal
Local cPDV		:= SPACE(04)       // Numero do PDV
Local cCpfCnpj	:= Space(14)		//Numero do Cpf/Cnpj do cliente para relatorio de vendas identificadas 
Local lRet		:= .F.
Local cPortaMenu:= ""
Local cPath		:= ""
Local cFile		:= ""
Local nLnMenu	:= 0					//Controle de Linha dos itens do Menu Fiscal
Local aRetPrinter	:= {}     
Local lTplAbPend	:= HasTemplate("PCL") .AND. ExistTemplate("TpPclAPend")
Local lArqPend		:= .F.    
Local aMenuOpt		:= {} 
Local cERPAFECF		:= "" 
Local nPOS			:= 0 
Local nLimite		:= 0    
Local nC			:= 0
Local lLjSimpNac	:= SuperGetMV("MV_LJSIMPN",,.F.)
Local cRetEcf		:= ""	
Local lMvLjPdvPa	:= LjxBGetPaf()[2]
Local lIsPafNfce    := STFGetCfg("lPAFNFCE") .Or. IIf(ExistFunc("LjPafNFCe"),LjPafNFCe(),.F.)	 //Usa PAF-NFC-e c/ Impressora Não Fiscal
Local cArqPNFCe		:= ""

Default lFrontMenu	:=	.F.
Default lPOS		:=	STFIsPOS()  //Chamada a partir do PDV Pos
Default lEcfOk		:=	.F.

If GetRemoteType() == 5
	MsgAlert (STR0241)//"Menu Fiscal não disponível para ambiente SmartClient WebApp."
Else 
	If lMvLjPdvPa .And. !lIsPafNfce
		If lPos
			cRetEcf:=  space(20)
			aRetPrinter	:=	STFFireEvent(ProcName(0) , "STPrinterStatus",{"1",@cRetEcf} )
				
			If Len(aRetPrinter) > 0 .AND. aRetPrinter[1] == 0
				lEcfOk := .T.
			Else
				lEcfOk := .F.
			EndIf 
		Else
			lEcfOk	:= IFStatus( nHdlECF, '1', @cRetEcf ) == 0
		EndIf
			
		cERPAFECF	:= STBVerPAFECF("ERPAFECF")
		
		//PAF-ECF: Não permitir abrir menu fiscal quando cupom fiscal aberto
		If lECFOK .AND. STBIsCupOpen(lPOS)     
			STFMessage("STBMenFis3", "ALERT", STR0072) //"Não é permitido acessar o Menu Fiscal durante a emissão de Cupom Fiscal."	
			STFShowMessage("STBMenFis3")
			lConfirma := .F.
		EndIf
		
		If lConfirma
			If lPOS
				lEcfOk := lECFOK .AND. !(!STWValGT() .OR. !STWValSerie())  
			Else 
				lEcfOk := lECFOK .And. IIF( lMenFisOnLog , .T. , !(!LJValGT() .OR. !LjVldSerie()))
			EndIf
			
			If !lFrontMenu .AND. IIF(lPOS, STFProfile(3)[1] , LJProfile(3)  .AND. !(nModulo == 12))
				STFMessage("STBMenFis4", "RUN", STR0073 , { || lRet := STBFMMenAbrECF(@cPortaMenu, lPOS) })	 //"Aguarde. Abrindo a Impressora Fiscal..."
				STFShowMessage("STBMenFis4")
				If !lRet
					lConfirma := .F.
				EndIf
			EndIf
		EndIf
	EndIf

	If lConfirma
		/*
		Conforme Item de homologação devo validar se possui pendencia de envio do arquivo e travo algumas 
		funções caso não haja comunicação com a SEFAZ ou não exista comunicação com a SEFAZ
		*/
		lArqPend := STBArqPend()
		
		DEFINE MSDIALOG oDlg TITLE STR0074 FROM 0,0 TO 330,255 PIXEL //"Menu Fiscal" //COM SPEDFISCAL, DEIXAR O TAMANHO DEFAULT E O MENU FIXO
		
			oTPane1 := TPanel():New(0,0,"",oDlg,NIL,.T.,.F.,NIL,NIL,170,070,.T.,.F.)   //"Menu Fiscal"
			oTPane1:Align := CONTROL_ALIGN_ALLCLIENT
			
			oTPane2 := TPanel():New(0,0,"",oDlg,NIL,.T.,.F.,NIL,NIL,170,020,.T.,.F.)
			oTPane2:Align := CONTROL_ALIGN_BOTTOM
			nLnMenu := 002 
			nPOS := 0
			If Len(aMenuOpt) == 0  
				aMenuOpt := StbLoadFisMenu(cERPAFECF, .F., lTplAbPend, @nLimite, nLnMenu)
			EndIf
			
			For nC := 1 to Len(aMenuOpt)
				tSay():New( &(StrZero(aMenuOpt[nC, 04],3)),  004  , &("{ || '" + aMenuOpt[nC, 01] + " - " + aMenuOpt[nC, 02] +  "' } "),oTPane1,,,,,,.T.,,, 105, 009  )
			Next nC
			
				@ 004,004 SAY   STR0075                       SIZE 050, 008 OF oTPane2 PIXEL //"Opcao:"
				@ 004,024 MSGET oOpcao VAR cOpcao PICTURE "99" SIZE 040, 010 OF oTPane2 PIXEL VALID VAL( cOpcao ) >= 1 .AND. VAL( cOpcao ) <= nLimite
			
			DEFINE 	SBUTTON   oBtnOk     ;
					FROM      003, 072   ;
					TYPE      1          ;
					ENABLE OF oTPane2    ;
					ACTION    ( lConfirma := .T.,  oDlg:End() )
			
			DEFINE 	SBUTTON   oBtnCancel ;
					FROM      003, 100   ;
					TYPE      2          ;
					ENABLE OF oTPane2    ;
					ACTION    ( lConfirma := .F., oDlg:End() )
		
		ACTIVATE MSDIALOG oDlg CENTERED  
		
		
		cOpcao := StrZero( VAL( cOpcao ), 2 ) 
		nPos := aScan(aMenuOpt, { |x| x[1] == cOpcao })    
		
		If nPos == 0
			lConfirma := .F.
		EndIf
	EndIf
			
	If lConfirma
		
		Do Case			
			
			Case aMenuOpt[nPos, 03] == "01"  // LX
			
				If lEcfOk
					STWFMLX(lPOS)
				Else
					Alert('ECF desligado')
				EndIf

			Case aMenuOpt[nPos, 03] == "19"  // LMF
				
				If lEcfOk			
					STWFMLMF( aMenuOpt[nPos, 03], lPOS )
				Else
					Alert('ECF desligado')
				EndIf	
				
			Case aMenuOpt[nPos, 03] == "20"  // Arq MF
				
				If lEcfOk			
					STWFMLMFD( lPOS )
				Else
					Alert('ECF desligado')
				EndIf	

			Case aMenuOpt[nPos, 03] == "23" // Espelho MFD
				
				If lEcfOk			
					STWFMMirrorMFD( aMenuOpt[nPos, 03], lPOS ) 
				Else
					Alert('ECF desligado')
				EndIf
				
			Case aMenuOpt[nPos, 03] == "21"  // Arq mfD - to do: este requisito mudou a memória é extraída em formato binário - talvez tenha que alterar a STFECFControl
				If lEcfOk
					STWFMFileMFD( aMenuOpt[nPos, 03], lPOS )
				Else
					Alert('ECF desligado')
				EndIf

			Case aMenuOpt[nPos, 03] == "11"   // Identificação do PAF-ECF
				If (lEcfOk .And. lArqPend) .Or. lIsPafNfce
					STBFMImpIdPE(lPOS)
				ElseIf !lArqPend
					Alert("Operação Bloqueada devido a pendencia de envio dos arquivos XML")
				Else
					Alert('ECF desligado')
				EndIf

			Case aMenuOpt[nPos, 03] == "12"   // Vendas no período *Não busca dados na retaguarda sendo necessário conectar direto na retaguarda para processar
				If !lPOS .OR. !lLjSimpNac
					STWFMSellReport(lPOS)
				EndIf
			Case aMenuOpt[nPos, 03] == "13"   // Tab.Ind.Tec.Producao 
				
				If !lLjSimpNac .And. lArqPend
					STFMessage("STBMenFis5", "STOPPOPUP", STR0077)	//"Este PAF-ECF não executa funções de baixa de estoque com base em índices técnicos de produção, não podendo ser utilizado por estabelecimento que necessite deste recurso."
					STFShowMessage("STBMenFis5")
				ElseIf !lArqPend
					Alert("Operação Bloqueada devido a pendencia de envio dos arquivos XML")
				EndIf
				
			Case aMenuOpt[nPos, 03] == "14"   // Parâmetros de Configuração"
				If lEcfOk .And. lArqPend
					STBPConfig(lPOS)
				ElseIf !lArqPend
					Alert("Operação Bloqueada devido a pendencia de envio dos arquivos XML")
				Else
					Alert('ECF desligado')
				EndIf

			/*Case aMenuOpt[nPos, 03] == "15"   //Troco em Cartao - Não disponilizado no PAF-ECF - Homologacao 2017 
				If lEcfOk .AND. lUsaTrocoSC .AND. ;
					STITelMenFis( STR0078 , aMenuOpt[nPos, 01], @dDataIni, @dDataFim ,;
									NIl,				nil, 	nil, 	nil,;
									nil,			lPOS) //"Troco em Cartão"
					
					If STBTrcCard(dDataIni, dDataFim, @cFile, lPOS) //manda por padrão a geração do TXT
						STBFMGerPath( @cPath )
						STBFMSignPaf( cPath + cFile )
					EndIf
				Else
					Alert('ECF desligado')
				EndIf*/
			
			Case aMenuOpt[nPos, 03] == "16"   // TPL Posto: Abastecimentos Pendentes
				If lEcfOk
					If lTplAbPend
						T_TpPclAPend()
					EndIf
				Else
					Alert('ECF desligado')
				EndIf
				
			Case aMenuOpt[nPos, 03] == "17"   // TPL Posto: Encerrantes
				If STITelMenFis( STR0079 , cOpcao, @dDataIni, @dDataFim, /* Nil */, /* Nil */, @cPDV, NIL, NIL,	lPOS ) //"Encerrantes"
													
					If HasTemplate("PCL") .AND. ExistTemplate("TpPclEncer") .AND. T_TpPclEncer(dDataIni,dDataFim,@cFile)
						STBFMGerPath( @cPath )   
						STBFMSignPaf(cPath + cFile)					
					EndIf
				EndIf

			Case aMenuOpt[nPos, 03] == "18"   //TPL Posto: Manutencão da Bomba
				If lTplAbPend .AND. ;
					STITelMenFis( STR0080 , cOpcao, @dDataIni, @dDataFim, /* Nil */, /* Nil */, /* Nil */ , /*@lArqTxt*/ , NIL,	 lPOS) //"Manutenção da Bomba"
										
					If ExistFunc("LjxManBomb") .AND. LjxManBomb(@dDataIni, @dDataFim, .T. /*@lArqTxt*/, @cFile) //manda por padrão a geração do TXT
						STBFMGerPath( @cPath )   
						STBFMSignPaf(cPath + cFile)
					EndIf
				EndIf
				
			Case aMenuOpt[nPos, 03] == "22"  // Registros PAF-ECF
				STWRegPAF(aMenuOpt[nPos, 03], lPOS, lIsPafNfce)
			
			Case aMenuOpt[nPos, 03] == "24"  // Envio ao FISCO-REDUÇÃO Z
				LPXVlEnvFi(lPos,.T.,"R")
			
			Case aMenuOpt[nPos, 03] == "25"  // Envio ao FISCO-ESTOQUE
				LPXVlEnvFi(lPos,.T.,"E")
			
			Case aMenuOpt[nPos, 03] == "26"  // Vendas Identificadas pelo CPF/CNPJ
				If STITelMenFis( "Vendas Identificadas pelo CPF/CNPJ" , aMenuOpt[nPos, 03], @dDataIni, @dDataFim,;
									/* Nil */, /* Nil */, /* Nil */ , /*@lArqTxt*/ , NIL,lPOS,/*nTipoMfd*/,@cCpfCnpj) //"Vendas Identificadas pelo CPF/CNPJ"
					STBVndsId(dDataIni,dDataFim,cCpfCnpj,lPos) 
				EndIf
			
			Case aMenuOpt[nPos, 3] == "27"
				If lEcfOk
					STWFMFileMFD( aMenuOpt[nPos, 03], lPOS , "Arq. AC 17/04")
				Else
					Alert('ECF desligado')
				EndIf
				
			Case aMenuOpt[nPos, 3] == "29" //Transmitir arquivos Requisito XXVI
				STrReqXXVI(aMenuOpt[nPos, 3], lPOS)		

			Case aMenuOpt[nPos, 3] == "30" //Requisições Externas Registradas
				If FINDFUNCTION("LjGeReqExt")
					cArqPNFCe:= LjGeReqExt(lPOS)
					If !Empty(cArqPNFCe)
						STBGeraXML(cArqPNFCe, "V") 
					Endif 
				Endif 

			Case aMenuOpt[nPos, 3] == "31" //Controle dos DAV
				If FINDFUNCTION("LJGeCtrDAV")
					cArqPNFCe:= LJGeCtrDAV(xFilial("SLG"), lPOS)
					If !Empty(cArqPNFCe)
						STBGeraXML(cArqPNFCe, "VI") 
					Endif 
				Endif 
			
			EndCase
	EndIf

	If lMvLjPdvPa
		If !lFrontMenu .AND. (IIF(lPOS, STFProfile(3)[1] , LJProfile(3)  .AND. !(nModulo == 12))) 
			If lPOS
				STFFireEvent( ProcName(0), "STCloseCom", {cPortaMenu} )  
			Else
				IFFechar( nHdlECF, cPortaMenu )
			EndIf
		EndIf
	EndIf
Endif 

Return  Nil

//--------------------------------------------------------
/*{Protheus.doc}STxArqIdPaf
Gera o arquivo de MD5 do PAF-ECF (AppServer e SmartClient)	
@author  	Varejo
@version 	P11.8
@since   	02/08/2013
@return  	NIL
@obs      	STxArqIdPaf
@sample
*/
//-------------------------------------------------------- 
Function STxArqIdPaf()
Local nHandle 		:= 0 						// Handle para tratamento do arquivo a ser criado
Local cPathSmart	:= ""                 // Caminho onde deve ser gravado o arquivo, conforme previsto no PAF-ECF
Local cPathServer	:= ""					 // Caminho da pasta server
Local cArqNome		:= ""						// Nome do arquivo da lista
Local cArqMd5		:= ""							// MD-5 do arquivo da lista
Local cArqLista		:= "paflista.txt"			// Nome do arquivo contendo a lista de arquivos  
Local cLinha		:= ""						// Conteudo do arquivo de Identificação do PAF, no formato definido no Ato Cotepe
Local cAux			:= ""
Local nX			:= 0						// Controle do Looping
Local cNumLaudo		:= ""						// No. do Laudo
Local cMd5Master	:= ""						// MD-5 do principal executavel
Local cVerAplic		:= ""						// Versao do Aplicativo 
Local aArqPAFSmart	:= {} 						// lista com todos os arquivos do PAF e seu MD-5 da pasta SmartClient
Local cERPAFECF		:= ""						//ER do PAF-ECF
Local aRet			:= ""
	
cPathSmart := GetClientDir() 		//Path do client

//Forma encontrada para resgatar caminho da appserver por nao achar função adequada ( que até o momento nao existe )
If lHomolPAF
	cPathServer:= AllTrim(GetPvProfString("GENERAL","INSTALLPATH","",GetAdv97()))			//Path do Server
	If !Empty(cPathServer)
	    If Right(cPathServer,1) <> "\"
	        cPathServer	+=	"\"
	    EndIf
	    If cPathServer+"bin\" $ cPathSmart
	    	cPathServer	+= "bin\appserver\"
	    Else
			STFMessage("STxArqIdPaf1", "STOPPOPUP", STR0081 ) //"Diretorio de instalação do Protheus não informado no arquivo de configuração do servidor (Appserver.ini)"	
			STFShowMessage("STxArqIdPaf1")
	    EndIf
	Else
		STFMessage("STxArqIdPaf1", "STOPPOPUP", STR0081 ) //"Diretorio de instalação do Protheus não informado no arquivo de configuração do servidor (Appserver.ini)"	
		STFShowMessage("STxArqIdPaf1")
	EndIf
EndIf

If File(cPathSmart + cArqLista)
	fErase(cPathSmart + cArqLista) 	//Regra do Requisito IX: Gerar o arquivo a cada inicializacao..
EndIf

//Carrega dados da Versao Homologada
cNumLaudo	:= STBVerPAFECF("NUMLAUDO")
cERPAFECF	:= STBVerPAFECF("ERPAFECF")
cMd5Master	:= STBVerPAFECF("MD5MASTER")
cVerAplic	:= STBVerPAFECF("VERSAOAPLIC")
aRet		:= STBMD5Arqs( lTotvsPdv , cNumLaudo )
aArqPAFSmart:= aRet[1]
aArqLstPaf	:= {}

/*
	Requisito: IX
	O PAF-ECF deve, a cada inicializacao:
	a) gerar, por meio do algoritmo Message Digest-5 (MD-5), código de autenticação para cada arquivo
	executável que realize os requisitos estabelecidos nesta especificação;                          
	b) gerar um arquivo texto, conforme o leiaute estabelecido no Anexo X do Ato                     
	COTEPE/ICMS 06/08, contendo a lista de arquivos autenticados, e seus respectivos códigos MD-5;   
*/
cArqMd5	:= cMd5Master
cArqNome:= "SIGAPAF.EXE" //Principal arquivo executavel
If lHomolPAF
	cArqMd5	:= STBMd5File(cPathSmart + cArqNome)
EndIf
Aadd(aArqLstPaf,{cArqNome,cArqMd5})

cArqNome:= "SMARTCLIENT.EXE"
If cNumLaudo == "POL0852017"
	cArqMD5 := "DF804ACCFAB738478AFF56431722ADF9"
Else
	cArqMd5	:= "EBF8A85BBE87D39A11465A8CE6565DF4"

	If lHomolPAF
		cAux := STBMd5File(cPathSmart + cArqNome)
		If ! Empty(AllTrim(cAux))
			cArqMd5	:= cAux
		EndIf
	EndIf
EndIf
Aadd(aArqLstPaf,{cArqNome,cArqMd5})

//Captura os arquivos das pasta SmartClient
For nX:= 1 to Len(aArqPAFSmart)
	cArqNome	:= Upper(AllTrim(aArqPAFSmart[nX][2]))
	cArqMd5	:= IIf(lHomolPAF, STBMd5File(cPathSmart + cArqNome),AllTrim(Upper(aArqPAFSmart[nX][1])))
	If Empty(AllTrim(cArqMd5))
		cArqMd5	:= AllTrim(Upper(aArqPAFSmart[nX][1]))
	EndIf		
	Aadd(aArqLstPaf,{cArqNome,cArqMd5})
Next nX

//Cria o arquivo
nHandle := fCreate(cPathSmart + cArqLista)

//REGISTRO TIPO N1 - IDENTIFICAÇÃO DO DESENVOLVEDOR DO PAFECF:
cLinha	:= "N1"						// 01 - Tipo de registro 
cLinha	+= PADL( _CNPJTOT, 	14)		// 02 - CNPJ
cLinha 	+= PADR( _INSCEST,	14)		// 03 - Inscrição Estadual
cLinha	+= PADR( _INSCMUN, 	14)		// 04 - Inscrição Municipal 	
cLinha	+= PADR( _RAZSOC,	50)	+ CHR(13)+CHR(10)	// 05 - Razão Social
fWrite(nHandle,cLinha)

//REGISTRO TIPO N2 - IDENTIFICAÇÃO DO PAF-ECF
cLinha	:= "N2"							// 01 - Tipo de registro 
cLinha	+= PADR( cNUMLAUDO, 	10)		// 02 - Laudo do PAFECF
cLinha	+= PADR( cModPaf,50)	// 03 - Nome do PAF-ECF
cLinha	+= PADR( cVerAplic,10)	+ CHR(13)+CHR(10)			// 04 - Versão do PAFECF
fWrite(nHandle,cLinha)

//REGISTRO TIPO N3 - RELAÇÃO DOS EXECUTÁVEIS E SEUS CÓDIGOS DE AUTENTICAÇÃO (MD5):
For nX := 1 To Len(aArqLstPaf)
	cLinha 	:= "N3"							// 01 - Tipo de registro	
	cLinha	+= PADR(aArqLstPaf[nX][1],50)		// 02 - Nome do arquivo "executavel" * Conforme orientação Polimg, arquivos DLL´s deverão ser listados
	cLinha	+= PADR(aArqLstPaf[nX][2],32) + CHR(13)+CHR(10)	// 03 - Código de autenticação (MD-5)		
	fWrite(nHandle,cLinha )	
Next nX

// REGISTRO TIPO N9 - TOTALIZAÇÃO DO ARQUIVO 
cLinha	:= "N9"								// 01 - Tipo de registro 
cLinha	+= PADL( _CNPJTOT, 	14)				// 02 - CNPJ
cLinha 	+= PADR( _INSCEST,	14)				// 03 - Inscrição Estadual
cLinha	+= ALLTRIM( StrZero(Len(aArqLstPaf),6) )	+ CHR(13)+CHR(10)// 04 - Total de registros tipo N3

fWrite(nHandle,cLinha)             
fClose(nHandle)                           

//(REQUISITO IX)
//Assina Arquivo conforme previsto para o PAF-ECF(Ato Cotepe): REGISTRO TIPO EAD - ASSINATURA DIGITAL
//O arquivo deverá ser gravado em disco rígido do computador do usuário, devendo o programa aplicativo informar o local da gravação.
Processa({ || AllTrim(STBFMSignPaf(cPathSmart + "paflista.txt",.F.))}, STR0082 + AllTrim(cPathSmart + "paflista.txt") ) //"Arquivo com lista de arquivos autenticados(PAF-ECF):"

//Chama rotina para armazenar MD-5 do arquivo paflista.txt no arquivo criptografado, para utilizar na impressao do Cupom 
//Requisito IX: "...gravar o resultado no arquivo auxiliar criptografado" 
If nModulo == 12
	STBGrvMd5Ls(.F.)
EndIf

Return Nil

//--------------------------------------------------------
/*{Protheus.doc} STBPConfig
Emite relatorio Gerencial com Parametros de Configuracao (PAF-ECF).
 Opcao "14" "Parametros de configuracao" 
@author  	Varejo
@version 	P11.8
@since   	03/09/2012
@return  	.T. se conseguiu reposicionar.
@sample
*/
//--------------------------------------------------------
Function STBPConfig(lPOS) 
Local cConteudo	:= ""					// Texto a ser impresso pelo ECF
Local lRet		:= .T.					// Retorno da funcao
Local cPulaLinha:= REPLICATE("-",48)	// Texto para separar as linhas
Local cVerAplic	:= ""					// Versao do Aplicativo Protheus
Local nMaxColuna:= 48					// Quantidade de colunas por linha    
Local nCentraliza	:= 0					// Posicao para centralizar o texto 

nCentraliza	:= INT( (nMaxColuna - Len(AllTrim(STR0083))) / 2) + Len(AllTrim(STR0083))
cConteudo += PadL( AllTrim(STR0083), nCentraliza ) + CRLF	//"PARAMETROS DE CONFIGURACAO"

cConteudo := cPulaLinha + CRLF  
cConteudo += STR0096 + STBPerfPAF() + CRLF //"Perfil de Requisitos...........: "                                                                                                                                                                                                                                                                                                                                                                                                                                                                                 
cConteudo += STR0097+ SM0->M0_ESTCOB + CRLF	 //"Unidade de Federação...........: "
cConteudo += cPulaLinha + CRLF

If STBImpItMF( "LjxPConfig" , cConteudo , 1, lPOS ) <> 0
	If lPOS
		STFMessage("STBPConfig", "STOP",STR0177) //"Erro ao conectar com a Impressora Fiscal "
		STFShowMessage("STBPConfig")
	Else
		MsgStop(STR0177)
	EndIf
	lRet := .F.
EndIf

Return Nil

//--------------------------------------------------------
/*{Protheus.doc} STBImpItMF
Impressão dos Itens do Menu Fiscal por Relatorio Gerencial

@author  	Varejo
@version 	P11.8
@since   	03/09/2012
@return  	.T. se conseguiu reposicionar.
@obs     	LjxImpItMF
@sample
*/
//--------------------------------------------------------
Function STBImpItMF( cItem		, cTexto	, nVias	, lPOS	,;
					 cImgQrCode	)
Local aTotalizadores := {}
Local cDirClient	:= GetClientDir()
Local cIndTotaliz	:= ""
Local nPos			:= 0
Local nRet			:= -1
Local lTplAbPend	:= HasTemplate("PCL") .AND. ExistTemplate("TpPclAPend")   //Indica que esta utilizando o template de posto e a Rotina de Abastecimentos Pendentes 
Local aPrinter		:= {}

DEFAULT cItem		:= ""
DEFAULT cTexto		:= ""
DEFAULT nVias		:= 1
DEFAULT cImgQrCode	:= ""

//aTotalizadores[1] = Item do Menu Fiscal
//aTotalizadores[2] = Indice do Relatorio Gerencial Cadastrado no ECF
//- Nao pega valor default para as chaves pois se não estiver cadastrado imprime um Rel Gerencial Comum
If SuperGetMV("MV_LJDAVOS",,.F.)
	AAdd(aTotalizadores , { "LjxDavEmt" 	, GetPvProfString("PAF-ECF","OrdemServico"	, "" /*"DAVOSS"*/	, cDirClient+"SIGALOJA.INI") })	   	
Else
	AAdd(aTotalizadores , { "LjxDavEmt" 	, GetPvProfString("PAF-ECF","DAV"			, "" /*"DAVS"*/		, cDirClient+"SIGALOJA.INI") })
EndIf
AAdd(aTotalizadores , { "LjxMeiPgto"	, GetPvProfString("PAF-ECF","MeiosPagto"	, "" /*"MEIOSPGTO"*/, cDirClient+"SIGALOJA.INI") })
AAdd(aTotalizadores , { "LjxPConfig"	, GetPvProfString("PAF-ECF","ParamConfig"	, "" /*"PARAMCFG"*/	, cDirClient+"SIGALOJA.INI") })
AAdd(aTotalizadores , { "LjxImpIdPE" 	, GetPvProfString("PAF-ECF","IdPaf"			, "" /*"IDPAF"*/	, cDirClient+"SIGALOJA.INI") })
AAdd(aTotalizadores , { "ImpRelECF"	    , GetPvProfString("PAF-ECF","DavEcf"		, "" /*"DAVECF"*/	, cDirClient+"SIGALOJA.INI") })

If lTplAbPend
	AAdd(aTotalizadores , {   "TpPclAPend"	, GetPvProfString("PAF-ECF","AbastePendente"	, "" /*"ABASTEPENDE"*/				, cDirClient+"SIGALOJA.INI") })
	AAdd(aTotalizadores , {   "TpPclEcfTo"	, GetPvProfString("PAF-ECF","Encerrantes"		, "" /*"Controle de Encerrantes"*/	, cDirClient+"SIGALOJA.INI") })
EndIf

Aadd(aTotalizadores , { "LojNfce" , GetPvProfString("PAF-ECF","danfenfce"		, "" /*"DanfeNfce"*/	, cDirClient+"SIGALOJA.INI") })

nPos := aScan( aTotalizadores , { |x| Upper(AllTrim(x[1])) == Upper(AllTrim(cItem))} )
cIndTotaliz := AllTrim(Upper(aTotalizadores[nPos][2]))

If lPOS
	
	If nPos > 0 .AND. !Empty(cIndTotaliz)
		aPrinter :=	STFFireEvent(	ProcName(0),"STMenuFiscReport",{cTexto, nVias, cIndTotaliz,cImgQrCode} )
	Else	
		aPrinter :=	STFFireEvent(	ProcName(0),"STManagReportPrint",{cTexto, nVias,cImgQrCode} )
	EndIf

	If Len(aPrinter) > 0
		nRet := aPrinter[1]
	EndIf

Else	
	If nPos > 0 .AND. !Empty(cIndTotaliz)
		nRet := IFRelMFisc( nHdlECF , cIndTotaliz  , cTexto, nVias ,cImgQrCode)
	Else
		nRet := IFRelGer( nHdlECF, cTexto, nVias , cImgQrCode)
	EndIf
EndIf

Return nRet

//--------------------------------------------------------
/*{Protheus.doc} STBTrcCard
Impressão dos Itens do Menu Fiscal por Relatorio Gerencial

@author  	Varejo
@version 	P11.8
@since   	03/09/2012
@return  	.T. se conseguiu reposicionar.
@obs     	LjxTrcCard
@sample
*/
//--------------------------------------------------------
Function STBTrcCard(dDataIni, dDataFim, cFile, lPOS, ;
						cWSServer, nHandle )
Local cLista	:= ""
Local cCabec	:= ""
Local cPath		:= ""
Local cConteudo	:= ""
Local cCnpj		:= ""
Local cStrAux	:= "" //Variavel auxiliar para efetuar as conversões, remover caractres, etc.
Local cNumFabEcf:= ""
Local cMFAdic	:= ""
Local cTipoEcf	:= ""
Local cMarcaEcf := ""
Local cModelEcf := ""
Local nValor	:= 0  
Local nX		:= 0
Local oWs 		:= WsFrtPafEcf():New() 
Local lRet		:= .T.    
Local nTotReg	:= 0
Local aRet		:= {}

Default dDataIni	:= dDataBase
Default dDataFim	:= dDataBase
Default cFile		:= "" 
Default nHandle		:= 0
Default cWSServer	:= ""

If !Empty(cWSServer)
	cWSServer	:= IIF(lPOS, AllTrim(STFGetStation("WSSRV")), AllTrim(LjGetStation("WSSRV")) )   
EndIf

If dDataIni > dDataFim
	If lPos
		STFMessage("STBTrcCard1", "STOP", STR0178)//"Data de início maior que a data final. Verifique"
		STFShowMessage("STBTrcCard1")
	Else
		MsgStop(STR0178)
	EndIf
	lRet := .F.
EndIf

If lRet
	//Verifica se o servidor de WS esta configurado
	If Empty(cWSServer)
		If lPos
			STFMessage("STBTrcCard2", "STOP", STR0179)//"O servidor de Web Services não está configurado nesta estação"
			STFShowMessage("STBTrcCard2")
		Else
			MsgStop(STR0179)
		EndIf
		lRet := .F.
	EndIf
	
	If lRet
		//Ajusta o caminho do servico
		oWs:_URL := "http://"+cWSServer+"/FRTPAFECF.apw"
		iIf(ExistFunc("LjWsGetAut"),LjWsGetAut(@oWs),Nil) //Monta o Header de Autenticação do Web Service
	
		//Executa o web service		
		STFMessage("STBTrcCard3", "RUN", STR0004 + " -> LstTrcCard ", {||lRet := oWs:LstTrcCard(dDataIni,dDataFim, cEmpAnt, cFilAnt, lHomolPaf)}) // "Executando consulta na retaguarda"
		STFShowMessage("STBTrcCard3")
	EndIf

	If !lRet
		If lPos
			STFMessage("STBTrcCard4", "ALERT", STR0027)//"Data de início maior que a data final. Verifique"
			STFShowMessage("STBTrcCard4")
		Else
			MsgAlert(STR0027)
		EndIf
	EndIf
EndIf

If lRet	 
	
	If Len(oWs:oWsLstTrcCardResult:oWsTrcCrdList) == 0
		STFMessage("STBTrcCard5", "OK", STR0180)//"Não foram encontrados registros de Troco em Cartão para o período solicitado"
		STFShowMessage("STBTrcCard5")
		lRet := .F.
	ElseIf !oWs:oWsLstTrcCardResult:oWsTrcCrdList[1]:lUsaTroco
		STFMessage("STBTrcCard6", "OK", STR0181)//"Ative o troco em Cartão no ambiente da retaguarda: MV_LJTROCO com .T. e/ou crie o campo L1_TROCO1"
		STFShowMessage("STBTrcCard6")
	    lRet := .F.
	EndIf
		
	If lRet
		
		If nHandle < 0
			STFMessage("STBTrcCard7", "STOP", STR0002 +  cPath + cFile)//"Erro ao criar arquivo "
			STFShowMessage("STBTrcCard7")
			lRet := .F.
		Else
			cCnpj := PADR( SM0->M0_CGC, 14 ) //CNPJ   
			STBDadosEcf(lPOS)
			STBGetInfEcf("SERIE",@cNumFabEcf)
			STBGetInfEcf("24",@cMFAdic)
			STBGetInfEcf("25",@cTipoEcf)
			STBGetInfEcf("26",@cMarcaEcf)
			nX := At(" ",cMarcaEcf)
			cMarcaEcf := SubStr(cMarcaEcf,1,nX-1)
			
			STBGetInfEcf("27",@cModelEcf)

			For nX := 1 to Len(oWs:oWsLstTrcCardResult:oWsTrcCrdList)		 
				cStrAux := AllTrim(oWs:oWsLstTrcCardResult:oWsTrcCrdList[nX]:cCnpjAdm)
				If !Empty(cStrAux)
					cStrAux := StrTran(cStrAux,".","")
					cStrAux := StrTran(cStrAux,"/","")
					cStrAux := StrTran(cStrAux,"-","")
					cStrAux := Replicate("0", 14-Len(cStrAux)) + cStrAux
				Else
				    cStrAux := StrZero(0,14,0)
				EndIf  
				
				cConteudo  := "H2"
				cConteudo += PADR( cStrAux , 14 )

				cConteudo += PADR( cNumFabEcf, 20 )	//Numero de fabricação do ECF
				cConteudo += PADR( cMFAdic , 1 )	//Letra indicativa de MF adicional
				cConteudo += PADR( cTipoEcf, 7 )	//Tipo de ECF
				cConteudo += PADR( cMarcaEcf, 20 )	//Marca do ECF
				
				If lHomolPaf .And. !oWs:oWsLstTrcCardResult:oWsTrcCrdList[nX]:LPAFMD5OK 
			    	cModelEcf := StrTran(PadR(cModelEcf, 20), " " , "?")   
			    Else
			    	cConteudo += PADR( cModelEcf, 20 )	//Modelo do ECF 
			    EndIf
				
				cConteudo += PADR(AllTrim(oWs:oWsLstTrcCardResult:oWsTrcCrdList[nX]:cCOO),9)
				cConteudo += PADR(AllTrim(oWs:oWsLstTrcCardResult:oWsTrcCrdList[nX]:cCCF),9)				
				
				nValor := oWs:oWsLstTrcCardResult:oWsTrcCrdList[nX]:nTroco
				cStrAux:= PadL(StrTran(StrTran(AllTrim(Str(nValor)), "." , ""),"," , ""),  13, "0")
				cConteudo += PADR(cStrAux,13)
				
				cConteudo += PADR(Dtos(oWs:oWsLstTrcCardResult:oWsTrcCrdList[nX]:dDtEmissao),8)		//11 - Data do Troco (formato aaaammdd)
				
				cStrAux := AllTrim(oWs:oWsLstTrcCardResult:oWsTrcCrdList[nX]:cCpfCli)
				cStrAux:= StrTran(StrTran(cStrAux , "." , ""), "-" , "")

				If Empty(cStrAux)
					Loop
				EndIf
				
				cConteudo += PADR(PadL(cStrAux, 14, "0"), 14) // 12 - CPF do adquirente do título de capitalização ou do doador
				cConteudo += PADR(AllTrim(oWs:oWsLstTrcCardResult:oWsTrcCrdList[nX]:cTitulo), 7 ) // 13 - Número do titulo de capitalização 
				
				cStrAux	:= AllTrim(oWs:oWsLstTrcCardResult:oWsTrcCrdList[nX]:cCnpjEnti) // 14 - CNPJ da entidade recebedora da doação
				cStrAux	:= StrTran(StrTran(StrTran(cStrAux , "." , ""), "-" , ""),"/","") 
				cConteudo += PADR(PadL(cStrAux, 14, "0"), 14)

				cConteudo += CHR(13) + CHR(10)
				FWRITE( nHandle, cConteudo, LEN( cConteudo ) )
			Next nX

			lRet := .T.
		EndIf
	EndIf
EndIf

Return lRet

//--------------------------------------------------------
/*{Protheus.doc} STBAsc2Hex
Converte um texto com caracteres ASCII em texto com caracteres HEXA.

@author  	Varejo
@version 	P11.8
@since   	02/08/2013
@return  	cResult - Resultado da conversao
@obs     	LjAsc2Hex
@sample
*/
//--------------------------------------------------------
Function STBAsc2Hex(cString)

Local nX     	:= 1 
Local cResult	:= ""
Local nVal		:= 0

For nX := 1 to Len(cString)
	nVal 	:= Asc(SubStr(cString,nX,1))
	cResult += STFDec2Hex(nVal)
Next nX     

cResult := Lower(cResult)

Return cResult

//--------------------------------------------------------
/*{Protheus.doc} STBPAFMD5
PAF-ECF

@author  	Varejo
@version 	P11.8
@since   	02/08/2013
@return  	cPafMd5 - valor(PAFMD5) para validacao do Registro(PAF-ECF)
@obs     	STxPafMd5
@sample
*/
//--------------------------------------------------------
Function STBPAFMD5(cAlias , cDadoAdic , cTipo)    
Local cPafMd5	:= ""

cPafMd5 := STxPafMd5(cAlias , cDadoAdic , cTipo)

Return cPafMd5

//--------------------------------------------------------
/*{Protheus.doc} STBBuscaTotECF
Busca o codigo do Totalizador no ECF

@author  	Varejo
@version 	P11.8
@since   	02/08/2013
@return  	
@obs     	STBBuscaTotECF
@sample
*/
//------------------------------------------------------
Function STBBuscaTotECF( cImposto, lPOS, aAlq )
Local nPos := 0
Local aRet		:= {}
Local aDados	:= {} 
Local lOnlyMenuFiscal := Iif(lPos,STFGetCfg( "lOnlyMenuFiscal" ),.F.)
Local aAliqICM	:= {}
Local aAliqISS	:= {}
Local nC		:= 0
Local lBusca	:= .F.

If ValType(aAlq) == "U"  
	aAlq := aClone(aAliquotas)
EndIf

If lOnlyMenuFiscal .Or. Len(aAlq) > 0
	If Len(aAliquotas) == 0
		STBLeArq( .F. , @aAliquotas)
	EndIf
	
	lBusca := .T.
Else
	If Len(aAliquotas) == 0
		If lPos
		   aDados := {space(100)} 
		   aRet := STFFireEvent(ProcName(0) ,"STGetAliq",aDados)
		   If Len(aRet) > 0 .AND. aRet[1] == 0  .AND. Len(aDados) > 0
		   		If At("," , aDados[1] ) > 0
		   			aDados[1] := AllTrim(Substr(aDados[1], At("," , aDados[1] )+ 1) )
		   		EndIf
		
		   		aAliqICM := StrTokArr( aDados[1] , "|" )
		   		aDados := {space(100)}
		   		aRet := STFFireEvent(ProcName(0) ,"STGetAliISS", aDados )   
				If Len(aRet) > 0 .AND. aRet[1] == 0  .AND. Len(aDados) > 0		
					If At("," , aDados[1] ) > 0
						aDados[1] := AllTrim(Substr(aDados[1], At("," , aDados[1] )+ 1) )
					EndIf
					aAliqISS := StrTokArr( aDados[1] , "|" )
			    EndIf
			EndIf

			nC := 0
			aEval(aAliqICM, { |a| IIF(Val(a) > 0, (nC := nC + 1, aAdd(aAliquotas, {StrZero(nC, 2), "T"+StrTran(StrZero( Val(a), 5,2), ".") } )), NIL )})  
	      	nC := 0
	      	aEval(aAliqISS, { |a| IIF(Val(a) > 0, (nC := nC + 1, aAdd(aAliquotas, {StrZero(nC, 2), "S"+StrTran(StrZero( Val(a), 5,2), ".")} )), NIL )})			
		Else
			aAliqICM := aClone(LjSetAliq( "ICMS" ))
			aAliqISS := aClone(LjSetAliq( "ISS" ))

			nC := 0
			aEval(aAliqICM, { |a| IIF(a[1] > 0, (nC := nC + 1, aAdd(aAliquotas, {StrZero(nC, 2), "T"+StrTran(StrZero( a[1], 5,2), ".") } )), NIL )})  
	      	nC := 0
	      	aEval(aAliqISS, { |a| IIF(a[1] > 0, (nC := nC + 1, aAdd(aAliquotas, {StrZero(nC, 2), "S"+StrTran(StrZero( a[1], 5,2), ".")} )), NIL )})			
		EndIf
      	
      	STBLeArq( .T. , aAliquotas)
      	aAlq := aClone(aAliquotas)
      	lBusca := .T.      	
	EndIf
EndIf

If lBusca .And. !Empty(cImposto)
	If (nPos := AScan(aAlq, { |x| AllTrim(x[2]) == AllTrim(cImposto) } ) ) > 0
		cImposto := AllTrim(aAlq[nPos, 1]) + cImposto
	EndIf
EndIf

Return cImposto

//--------------------------------------------------------
/*{Protheus.doc} STBGetB0Prv
Se o preco do produto na tabela SB1 for zerado, utilizamos o preco da tabela SB0.

@author  	Varejo
@version 	P11.8
@since   	02/08/2013
@return  	nPreco - Valor do produto, segundo a tabela de preco (MV_TABPAD)
@obs     	LjGetB0Prv
@sample
*/
//--------------------------------------------------------
Function STBGetB0Prv(cCod, cTabPreco)
Local aArea		:= GetArea()
Local nPreco	:= SB1->B1_PRV1	//preco do produto, conforme a tabela de preco
Local cTab		:= ""

Default cCod		:= ""
Default cTabPreco	:= SuperGetMV("MV_TABPAD",,"1")

cTab := AllTrim(cTabPreco)

If SB1->B1_PRV1 == 0 
	LjGrvLog(Nil,"Pesquisa de Preço de Produto na SB0 - B0_COD: ",cCod)
	LjGrvLog(Nil,"Pesquisa de Preço de Produto na SB0 - Tabela de Preço: ",cTab)
	
	DbSelectArea("SB0")
	SB0->( DbSetOrder(1) )	//B0_FILIAL + B0_COD
	If SB0->( DbSeek(xFilial("SB0") + cCod) )
		nPreco := &("B0_PRV" + cTab)
		LjGrvLog(Nil,"Preço de Produto encontrado na SB0 - Preço: ",nPreco)
	EndIf
	RestArea( aArea )
EndIf

LjGrvLog(Nil,"Retorno do Preço do Produto - ",nPreco)

Return nPreco
                                
//--------------------------------------------------------
/*{Protheus.doc} STBMd5File
Recebe Arquivo com Path para calculo do codigo MD-5 

@author  	Varejo
@version 	P11.8
@since   	02/08/2013
@return  	cRet - Codigo MD-5 do arquivo	
@obs     	LjxMd5File
*/
//--------------------------------------------------------
Function STBMd5File( cFile )
Local cRet			:= ""
Local aAttrib		:= {}
Local lPafNFCe		:= IIf(ExistFunc("LjPafNFCe"),LjPafNFCe(),.F.) //Usa PAF-NFC-e c/ Impressora Não Fiscal

DEFAULT cFile 		:= ""
                
cFile := Alltrim(cFile)

If File(cFile)
	cRet := Upper(Md5File(cFile,2)) //Retorna Chave MD5 do arquivo
	
	//Function MD5FILE retorna vazio quando atributo do arquivo somente leitura, verifica se arquivo somente leitura e envia mensagem
	If Empty(cRet)
		
		aAttrib := Directory( cFile )
		
		If !Empty(aAttrib) .AND. "R" $ aAttrib[1][5] 
			STFMessage("STBMd5File1",;
			 			"STOPPOPUP", STR0182 + CHR(13) + ;	//"Não foi possível extrair código MD-5 do arquivo:"#"Remova o atributo Somente Leitura do arquivo"
						cFile + CHR(13) + STR0183)
			STFShowMessage("STBMd5File1")
		EndIf
	EndIf
ElseIf !lPafNFCe
   STFMessage("STBMd5File2","STOP" , STR0184 + cFile ) //"Não foi possível localizar o arquivo:" 
   STFShowMessage("STBMd5File2")
EndIf

Return cRet

//--------------------------------------------------------
/*{Protheus.doc} STBFMGetFile
PAF-ECF

@param1		cPathOri 	- Path do arquivo no server que sera acessado via RPC;
@param2		cFileOri 	- Nome do arquivo no server que sera acessado via RPC;
@param3		cPathDest	- Path local onde sera gerado o arquivo;  
@param4		cFileDest 	- Nome do arquivo que ser gerado;
@param5		lDelOri 	- Apos a leitura se deve excluir o arquivo origem	

@author  	Varejo
@version 	P11.8
@since   	02/08/2013
@return  	lRet	
@obs     	LjxGetFile
*/
//--------------------------------------------------------
Function STBFMGetFile(	cPathOri	,cFileOri	,cPathDest	,cFileDest	,;
						lDelOri		,lPOS 		)
Local lRet 			:= .F.
Local aRet			:= {}
Local aBuffer		:= {}
Local lContinua		:= .T.
Local oRPCServer
Local cRPCServer	:= ""
Local nRPCPort      := 0
Local cRPCEnv       := ""
Local nPos			:= 0
Local nHandle		:= 0
Local nX			:= 0      
Local nMaxLength	:= 1022	//Tamanho máximo da linha
Local nQuebra		:= 0
Local cMsgErro		:= ""
Local cMsg			:= ""
Local cRPCEmp       := ""
Local cRPCFil       := ""
Local lProssegue	:= ""
Local aParamPerg	:= {}

Default cFileOri	:= ""		//Nome do arquivo no server que sera acessado via RPC
Default cPathOri	:= ""		//Path do arquivo no server que sera acessado via RPC
Default cFileDest	:= ""		//Nome do arquivo local que gerado
Default cPathDest	:= ""		//Path do arquivo local
Default lDelOri		:= .F.		//Sinaliza se apos a leitura devera excluir o arquivo no server

cMsg := "Inicio da função STBFMGetFile"
LJRPLogProc(cMsg)

If lPOS
	aRet := STFGetStation({"RPCSRV", "RPCPORT", "RPCENV", "RPCEMP","RPCFIL" })
Else
	aRet := LjGetStation({"RPCSRV", "RPCPORT", "RPCENV", "RPCEMP","RPCFIL" })
EndIf

nQuebra := Val(AllTrim(GetPvProfString("paf-ecf", "quebraREG", "0", GetClientDir() + "sigaloja.ini")))
//Preve-se no maximo um arquivo de cerca de 1Mb ( a conta será: Fator * 32Kb )
If nQuebra > 20
	nQuebra := 10
	cMsg := "Leitura da Chave quebraREG - Foi setado valor maior que o "+;
			"permitido portanto será setado o valor medio  - conteudo [" + cValToChar(nQuebra) + "]"
	LJRPLogProc(cMsg)
EndIf

cMsg := "Leitura da Chave quebraREG - conteudo [" + cValToChar(nQuebra) + "]"
LJRPLogProc(cMsg)
                 
//Apaga destino caso já exista
If File(cFileDest)
	FErase(cFileDest)
EndIf

If !lPOS               

	cRPCServer	:= aRet[1]
	nRPCPort	:= Val(aRet[2])
	cRPCEnv		:= aRet[3]
	cRPCEmp     := aRet[4]	
	cRPCFil     := aRet[5]	
	
	oRPCServer	:= FwRpc():New( cRPCServer, nRPCPort , cRpcEnv )
	oRPCServer:SetRetryConnect(1)
	
	If !oRPCServer:Connect( cRPCServer, nRPCPort )
		lContinua := .F.
	EndIf
	
	While lContinua
		oRPCServer:CallProc("RPCSetType", 3 )
		oRPCServer:SetEnv(cRPCEmp, cRPCFil)
		aBuffer := oRPCServer:CallProc( 'LjxReadFile', cPathOri, cFileOri, nPos, lDelOri ,nQuebra)
		If ValType(aBuffer) == "A"
			//Grava conteudo de aBuffer no arquivo destino
			If Len(aBuffer) > 1 
				If nHandle == 0
					nHandle := FCREATE(cPathDest + cFileDest)
				EndIf
			    
				For nX := 1 To Len(aBuffer)-1       
					//Escreve linha e adiciona caracter de fim de linha quando for o caso
					If Len(aBuffer[nX]) <= nMaxLength 
						fWrite(nHandle,aBuffer[nX]+Chr(13)+Chr(10))
					Else 
						fWrite(nHandle,aBuffer[nX]) 
					EndIf
			
				Next nX         		
			ElseIf Len(aBuffer) == 1 //Retorna uma posicao com a mensagem de erro no Server(RPC)
				cMsg := aBuffer[1]
				MsgStop(cMsg)
				LJRPLogProc(cMsg)
			EndIf
			
			nPos		:= Val(aBuffer[Len(aBuffer)])
			lContinua 	:= IIF( nPos > 0, .T., .F. )  //Quando arquivo maior que 32kb, realiza leitura em partes
			
			cMsg := "Copia arquivo ->  lContinua [" + Iif(lContinua,"S","N") + "] / nPos [" + cValToChar(nPos) + "]"
			LJRPLogProc(cMsg)
		Else
			lContinua := .F.
			cMsgErro := STR0185	//"Funcao LjxReadFile não retornou conteúdo da Retaguarda. Verifique se o Arquivo origem foi gerado:"
			cMsgErro += cPathOri
			cMsgErro += cFileOri
			
			LJRPLogProc(cMsgErro)
			If !IsBlind()     
				MsgAlert(cMsgErro)  	
			EndIf
		EndIf                                           
	End
Else

	While lContinua
	
		aParamPerg := {cPathOri, cFileOri, nPos, lDelOri, nQuebra}
	
		lProssegue := STBRemoteExecute(	"LjxReadFile"	,;
										aParamPerg		,;
										Nil				,;
										.F. 			,;
										@aBuffer		)   

		lContinua := lProssegue
		
		If lProssegue
			cMsg := "Execução com sucesso  - LjxReadFile"
		Else
			cMsg := "erro na execução - LjxReadFile"
		EndIf
		
		LJRPLogProc(cMsg)

		If ValType(aBuffer) == "A"
			//Grava conteudo de aBuffer no arquivo destino
			If Len(aBuffer) > 1 
				If nHandle == 0
					nHandle := FCREATE(cPathDest + cFileDest)
				EndIf
			    
				For nX := 1 To Len(aBuffer)-1       
					//Escreve linha e adiciona caracter de fim de linha quando for o caso
					If Len(aBuffer[nX]) <= nMaxLength 
						fWrite(nHandle,aBuffer[nX]+Chr(13)+Chr(10))
					Else 
						fWrite(nHandle,aBuffer[nX]) 
					EndIf
			
				Next nX         		
			ElseIf Len(aBuffer) == 1 //Retorna uma posicao com a mensagem de erro no Server(RPC)
				MsgStop(aBuffer[1])
			EndIf
			nPos := 0
			If Len(aBuffer) > 0
				nPos := Val(aBuffer[Len(aBuffer)])
			EndIf
			lContinua 	:= IIF( nPos > 0, .T., .F. )  //Quando arquivo maior que 32kb, realiza leitura em partes
			cMsg := "Copia arquivo ->  lContinua [" + Iif(lContinua,"S","N") + "] / nPos [" + cValToChar(nPos) + "]"
			LJRPLogProc(cMsg)
		Else                 
			lContinua := .F.
			cMsgErro := STR0185 	//"Funcao LjxReadFile não retornou conteúdo da Retaguarda. Verifique se o Arquivo origem foi gerado:"
			cMsgErro += cPathOri
			cMsgErro += cFileOri
		
			LJRPLogProc(cMsgErro)

			If !IsBlind()     
				MsgAlert(cMsgErro)
			EndIf
		EndIf
	End
EndIf
	
//Fecha arquivo 
If nHandle > 0
	fClose(nHandle)   
	lRet := .T.
EndIf

LJRPLogProc(cMsg,,lRet)

Return lRet  

//--------------------------------------------------------
/*{Protheus.doc} STBIsCupOpen
Verifica se o cupom está aberto
@param1		lPOS 	- PDV POS?
@author  	Varejo
@version 	P11.8
@since   	02/08/2013
@return  	lRet  - Cupom aberto?	
@obs     	STBIsCupOpen
*/
//--------------------------------------------------------
Static Function STBIsCupOpen(lPOS)
Local lRet := .F. 
Local cRetorno := ""
Local aRetPrinter := {}

If lPOS
	aRetPrinter := STFFireEvent( ProcName(0),"STPrinterStatus",{"5",""}) // Verifica Cupom Fechado
	lRet := ( Len(aRetPrinter) > 0 .AND. ValType(aRetPrinter[1]) == "N"	.AND. aRetPrinter[1] == 7 )	
Else   
	nRet := IFStatus(nHdlECF, '5', @cRetorno)
	lRet :=  nRet == 7 
EndIf

Return lRet                                                                                                                                                                                                                  

//-------------------------------------------------------------------
/*/{Protheus.doc} STWFMLX
imprimir leitura X - Opcao "01" "LX"

@author  Varejo
@version P11.8
@since   29/03/2012
@return  Nil
/*/
//-------------------------------------------------------------------
Static Function STWFMLX(lPos)
Local lTplAbPend := HasTemplate("PCL") .AND. ExistTemplate("TpPclAPend")   //Indica que esta utilizando o template de posto e a Rotina de Abastecimentos Pendentes 

Default lPos := .F.

If lPos
	If STFProFile(21)[1]
		STBReadingX()
	EndIf
Else
	FR271CPrintLeitX()
Endif

STBLeRelGer(lPOS)

//ER 02.06 - Item 6.26.1.4
LjxGrvMdz("LX", 0, "LeituraX", "", "")

If lTplAbPend
	T_TpPclEcfTo(dDatabase)
EndIf

Return Nil

//-------------------------------------------------------------------
/*{Protheus.doc} STITelMenFis
Realiza a montagem da tela, referente ao menu fiscal, 
para que possa ser solicitado os dados para o usuário.

@author  Varejo
@version P11.8
@since   29/03/2012
@return  Nil
@obs     
@sample
*/
//-------------------------------------------------------------------
Static Function STITelMenFis(	cTitulo		, cOpcao	, dDataIni	, dDataFim	,;
								cContIni	, cContFim	, cPDV		, lArqTxt	,;
								lAto1704	, lPOS		, nTipoMF	, cCpfCnpj,;
								lCheckPDV	)
Local oDlg
Local oDataIni                     // Objeto para a Data Inicial
Local oDataFim                     // Objeto para a Data Final
Local oContIni                     // Objeto para o Contador Inicial
Local oContFim                     // Objeto para o Contador Final
Local oPDV                         // Objeto para o PDV
Local oChkBox					   // Objeto para o Checkbox
Local oChkBoxAto				   // Objeto para o Checkbox
Local oCPFCNPJ					// Objeto que guarda o número do CPF/CNPJ
Local oMes						//Objeto do Mes da seleção
Local oAno						//Obejto do ano da seleção
Local oWS						   // Objeto do WebService
Local lRetValue                    // Retorno da janela
Local cWsServer					   // Server do WS configurado 
Local lRet						   // Retorno no WS   
Local oTipo		:= NIL             // Objeto da rotina
Local aMeses	:= {}
Local cMes		:= ""
Local nAno		:= 0
Local nX		:= 0
Local cMskCont	:= "@K 9999"
Local lSelPerXM := cOpcao == "XMLEST"

Default dDataIni 	:= CTOD("")        	// Data Inicial da Memoria Fiscal
Default dDataFim 	:= CTOD("")        	// Data Final da Memoria Fiscal
Default cContIni 	:= SPACE(04)       	// Contador Inicial da Memoria Fiscal
Default cContFim 	:= SPACE(04)       	// Contador Final da Memoria Fiscal
Default cPDV     	:= SPACE(04)       	// Numero do PDV
Default lArqTxt		:= .F.             	// Indica se gera arquivo texto
Default lAto1704	:= .F.				// Indica se gera Ato Cotepe 17/04 para LMFC     
Default nTipoMF		:= 1
Default lPOS		:= .F.
Default cCpfCnpj	:= Space(14)			//Número do CPF/CNPJ
Default lCheckPDV	:= .F.					

	DEFINE MSDIALOG oDlg FROM  15,6 TO 260,300 TITLE cTitulo PIXEL
	
	If !(cOpcao == "26") .AND. !lSelPerXM
		@ 013,008 SAY  	STR0186			   			SIZE 035, 007 OF oDlg PIXEL //"Periodo De"
		@ 011,050 MSGET oDataIni VAR dDataIni       PICTURE "@E 99/99/99" SIZE 050, 10 OF oDlg PIXEL
		
		@ 033,008 SAY   STR0187			    		SIZE 035, 007 OF oDlg PIXEL //"Periodo Ate"
		@ 031,050 MSGET oDataFim VAR dDataFim       PICTURE "@E 99/99/99" SIZE 050, 10 OF oDlg PIXEL
	EndIf
	
	Do Case
		Case (cOpcao == "02" .Or. cOpcao == "03" .Or. cOpcao == "27")  .or. ( cOpcao == "19"  .OR.  cOpcao == "20")

			If cOpcao == "27"
				cContIni := space(6)
				cContFim := space(6)
				cMskCont := "@K 999999"
			EndIf
			
			@ 053,008 SAY   STR0188		       			SIZE 035, 007 OF oDlg PIXEL //"Contador Ini"
			@ 051,050 MSGET oContIni VAR cContIni       PICTURE cMskCont SIZE 050, 10 OF oDlg PIXEL
			
			@ 073,008 SAY   STR0189		  				SIZE 035, 007 OF oDlg PIXEL //"Contador Final"
			@ 071,050 MSGET oContFim VAR cContFim       PICTURE cMskCont SIZE 050, 10 OF oDlg PIXEL
			
			If cOpcao == "27"
				lAto1704 := .T.
			EndIf
			
			If cOpcao <> "19" .AND. cOpcao <> "20" .And. cOpcao <> '27'			

				@ 093,008 CheckBox oChkBox Var lArqTxt Prompt STR0190 Size 105,008 PIXEL OF oDlg //"Saida em disco"

				If cOpcao == "02"
					@ 105,008 CheckBox oChkBoxAto Var lAto1704 Prompt STR0191 Size 105,008 PIXEL OF oDlg //"Ato Cotepe 17/04" 
				EndIf
				
			ElseIf cOpcao == "19"
	        	@ 093, 008 RADIO oTipo VAR nTipoMF SIZE 105,008 PROMPT STR0192, STR0193 OF oDlg //"Leitura Completa"###"Leitura Simplificada"
			Else			
				If !(cOpcao == '27')  //"20"
					lArqTxt := .T.
				EndIf
			EndIf
			
			
		Case cOpcao == "04" .Or. cOpcao == "05" .or.  cOpcao == "21" .Or. cOpcao == "23" 
			cMskCont := "@K 999999"
			cContIni := space(6)
			cContFim := space(6)
			@ 053,008 SAY   STR0194		          		SIZE 035, 007 OF oDlg PIXEL //"COO Ini"
			@ 051,050 MSGET oContIni VAR cContIni       PICTURE cMskCont SIZE 050, 10 OF oDlg PIXEL
			
			@ 073,008 SAY  STR0195		            	SIZE 035, 007 OF oDlg PIXEL //"COO Final"
			@ 071,050 MSGET oContFim VAR cContFim       PICTURE cMskCont SIZE 050, 10 OF oDlg PIXEL
			
		Case cOpcao == "08"
			
			oWS 		:= WsFrtPafEcf():New()
			iIf(ExistFunc("LjWsGetAut"),LjWsGetAut(@oWS),Nil) //Monta o Header de Autenticação do Web Service
			cWSServer	:= AllTrim(IF(lPOS, STFGetStation("WSSRV"),LjGetStation("WSSRV") ))

			//Ajusta o caminho do servico
			oWs:_URL := "http://"+cWSServer+"/FRTPAFECF.apw"
			
			//Executa o web service
			STFMessage("STITelMenFis1", "RUN", STR0004, {||lRet := oWs:LstPdvs(cEmpAnt, cFilAnt, ,lHomolPaf)}) //"Executando consulta na retaguarda"
			STFShowMessage("STITelMenFis1")

			If !lRet 
				MsgStop(STR0005 + ":LstPdvs" ) //"Erro na execução do WebService"
				oWs := Nil  
				Return Nil
			EndIf
			
			@ 053,008 SAY   "PDV"		           		  SIZE 035, 007 OF oDlg PIXEL //"PDV"
			//@ 051,050 MSGET oPDV     VAR cPDV           PICTURE "@E 9999" SIZE 050, 10 OF oDlg PIXEL
			@ 051,050 COMBOBOX oPDV VAR cPDV ITEMS oWS:oWsLstPdvsResult:cString  SIZE 50,10 OF oDlg PIXEL
			

		Case cOpcao == "10"
			
			@ 053,008 CheckBox oChkBox Var lArqTxt Prompt STR0196 Size 105,008 PIXEL OF oDlg //"Geração de arquivo texto"
		
		Case cOpcao == "26" .Or. lSelPerXM //"Vendas Identificadas pelo CPF/CNPJ"
			
			aMeses := {"Janeiro","Fevereiro","Março","Abril","Maio","Junho","Julho","Agosto","Setembro","Outubro","Novembro","Dezembro"}
			
			@ 013,008 SAY  	"Mês"	SIZE 035, 007 OF oDlg PIXEL //"Mes"
			@ 011,050 COMBOBOX oMes VAR cMes ITEMS aMeses SIZE 50, 10 OF oDlg PIXEL
			
			@ 033,008 SAY   "Ano"			    		SIZE 035, 007 OF oDlg PIXEL //"Ano"
			@ 031,050 MSGET oAno VAR nAno  PICTURE "@E 9999" SIZE 50, 10 OF oDlg PIXEL
		    
		    If lSelPerXM
		    	@ 053,008 SAY   "O período corresponde ao ultimo dia do mes selecionado" SIZE 035,050 OF oDlg PIXEL
		    Else
				@ 053,008 SAY   "CPF/CNPJ"		       		SIZE 035,007 OF oDlg PIXEL									//"CPF/CNPJ:"
				@ 051,050 MSGET oCPFCNPJ VAR cCpfCnpj       PICTURE "@K 99999999999999" SIZE 55,10 OF oDlg PIXEL
			EndIf
			
		Case cOpcao == "29"
			@ 013,008 SAY  	"Tipo de Seleção" SIZE 035, 007 OF oDlg PIXEL //"Tipo de Seleção"
			@ 013, 008 RADIO oTipo VAR nTipoMF SIZE 105,008 PROMPT ;
			 		"Automaticamente - On-Line", "Gerar Remessa para entrega manual" OF oDlg
			
	EndCase
				
	DEFINE 	SBUTTON   oBtnOk     ;
            FROM      110, 087   ;
            TYPE      1          ;
            ENABLE OF oDlg       ;
            ACTION    ( lRetValue := .T., oDlg:End() )
	
	DEFINE 	SBUTTON   oBtnCancel ;
            FROM      110, 115   ;
            TYPE      2          ;
            ENABLE OF oDlg       ;
            ACTION    ( lRetValue := .F., oDlg:End() )
	
	ACTIVATE MSDIALOG oDlg CENTERED
	
	If !lRetValue
		dDataIni := CTOD("")
		dDataFim := CTOD("")
		cContIni := SPACE(04)
		cContFim := SPACE(04)
		cPDV     := SPACE(04)
		cCpfCnpj := Space(14)
	Else
		If (cOpcao == "26" .Or. lSelPerXM) .And. !Empty(cMes) .And. (nAno > 0)
	    	nX := 0
	    	nX := Ascan(aMeses,cMes)

	    	If nX > 0
	    		dDataIni := CTOD('01/'+StrZero(nX,2)+'/'+cValToChar(nAno))
	    		dDataFim := LastDay(dDataIni,0)
	    	EndIf
	    EndIf
	EndIf    
	
Return lRetValue
								
//-------------------------------------------------------------------
/*/{Protheus.doc}STWFMLMF
Opcao "02" "LMFC"
@author  	Varejo
@version 	P11.8
@since   	03/09/2012
@return  	Nil
/*/
//-------------------------------------------------------------------
Static Function STWFMLMF( cOpcao, lPOS )
Local dDataIni  := CTOD("")        	// Data Inicial da Memoria Fiscal
Local dDataFim  := CTOD("")        	// Data Final da Memoria Fiscal
Local cContIni  := SPACE(04)       	// Contador Inicial da Memoria Fiscal
Local cContFim  := SPACE(04)       	// Contador Final da Memoria Fiscal
Local lArqTxt	:= .F.         		// Indica se sera gerado arquivo texto
Local lAto1704	:= .F.					// Gera Ato Cotepe
Local cChPriv	:= ""				// Cahave primaria
Local cChPubl 	:= ""					// Chave publica
Local cPath		:= ""					// Caminho
Local cSeriePDV	:= ""					// Serie PDV
Local cFile		:= ""    				// Arquivo
Local aRet		:= {}                   // Retorno do Strategy
Local aDados	:= {}                   // Dados do Strategy
Local cPathDLLArq := ""                 // Path do Arquivo 
Local nI		:= 0                    //Contador
Local lLinux	:= (GetRemoteType() == REMOTE_LINUX) //Remote Linux?
Local cSep 		:= Iif( lLinux, "/", "\" ) 	//Separador de Diretorio
Local aArqsDir  := {}                   // Diretorio
Local aTXT		:= {}
Local lRet		:= .T.                  // Retorno de execução
Local cTipoMem	:= "C"                  // Tipo da Memoria 
Local cDescrMem := STR0197          // Completa Descrição do tipo da Memoria
Local nTipoMem	:= 1                    // Tipo de Memoria
Local lGerado	:= .F.

DEFAULT cOpcao	:= SPACE(02)       	// Opção a ser selecionada pelo usuário

If STITelMenFis( STR0199 + cDescrMem, cOpcao, 	@dDataIni,;
 				@dDataFim, @cContIni,	@cContFim, NIL,;
 				@lArqTxt, @lAto1704,	lPOS ,	@nTipoMem) //"Memoria Fiscal"						    
	
	If nTipoMem == 2     
		cTipoMem	:= "S" 
		cDescrMem := STR0198 //"Simplificada"
	Else
		cTipoMem	:= "C" 
		cDescrMem := STR0197 //"Completa"
	EndIf
	
	If lAto1704
		cChPriv := 'CHAVEPUBLICA'
		cChPubl	:= 'CHAVEPRIVADA'
								
		STBFMGerPath( @cPath )
		 
		If lPOS
			aDados := {Space(30), Nil}
			aRet := STFFireEvent( ProcName(0), "StGetSerie", aDados )
		
			If Len(aRet) > 0 .AND. aRet[1] == 0 .AND. Len(aDados) > 0 .AND. !Empty(aDados[1])
				cSeriePDV := AllTrim(aDados[1])
			ElseIf Len(aRet) = 0 .OR. aRet[1] <> 0
				lRet := .F.
				STFMessage(ProcName(),"STOP",STR0200) //"Erro na comunicação com o ECF."
				STFShowMessage(ProcName())
			EndIf  
		Else 
			IFPegSerie(nHdlECF, @cSeriePDV)
		EndIf
		
		If lRet						
			cFile := cSeriePDV
			cFile += "_" + SubStr(DTOS(dDataIni),7,2) + SubStr(DTOS(dDataIni),5,2) + SubStr(DTOS(dDataIni),3,2)
			cFile += "_" + SubStr(DTOS(dDataFim),7,2) + SubStr(DTOS(dDataFim),5,2) + SubStr(DTOS(dDataFim),3,2)
		
			//Gera arquivo pelo ECF	
			If lPOS
				STFMessage("STWFMLMF1","RUN", STR0201,{ || STFFireEvent(ProcName(0), "STArqMFD", { DTOC(dDataIni), DTOC(dDataFim), cContIni,cContFim,; //"Gerando Arquivo..."
														 		cChPriv, cChPubl, cPath, cFile + '.TXT' })})     //"Gerando Arquivo..."
				STFShowMessage("STWFMLMF1")

			Else 
				STFMessage("STWFMLMF2","RUN", STR0201,{ || lRet := IFArqMFD(nHdlECF, DTOC(dDataIni), DTOC(dDataFim), cContIni, cContFim, cPath+cFile) } ) //"Gerando Arquivo..."
				STFShowMessage("STWFMLMF2")
			EndIf
				
			cPathDLLArq := GetPvProfString("PAF-ECF", "PathArqMFD", cPath , GetClientDir() + "sigaloja.ini") // Pega chave do SIGALOJA.INI onde o arquivo MFD do ECF é gerado
			cPathDLLArq := AllTrim(cPathDLLArq)
   			If !Subs(cPathDLLArq,Len(cPathDLLArq)-1,1) == cSep
   				cPathDLLArq := cPathDLLArq + cSep
   			EndIf
   					    	
    		If lLinux							   
				If At(":",cPathDLLArq) == 0 .AND. !Empty(cPathDLLArq)
					cPathDLLArq := "i:"+cPathDLLArq
			   Endif
			Endif	 

			aArqsDir := Directory(cPathDLLArq + "*.TXT")   //Lista os arquivos .TXT do diretorio
			For nI:= 1 To Len(aArqsDir)
				If Upper(cSeriePDV) $ Upper(aArqsDir[nI][F_NAME]) //Pega o arquivo que possui a serie, arquivo criado pelo ECF nao possui o mesmo nome.
					cFile := aArqsDir[nI][F_NAME]
					Exit
				EndIf
			Next nI							
			
			aTXT := STWReadFile( cPathDLLArq, cFile, 0, .T. ) //Pega conteudo de cFile , no caminho cPathDLLArq com indice 0 e permite a deleção do arquivo 

			If ValType(aTXT) == "A" .AND. Len(aTXT) > 1
				If File(cPath + cFile)
					FErase(cPath + cFile)
				EndIf
				
				nHndTXT := FCREATE(cPath + cFile)
				If nHndTXT > 0							    
					For nI := 1 To Len(aTXT)-1
						If !Subs(aTXT[nI],1,3) == 'EAD' //Não Insere a linha que possui a assinatura
							//Escreve linha e adiciona caracter de fim de linha quando for o caso									
							If Len(aTXT[nI]) <= nMaxLength
								fWrite(nHndTXT,aTXT[nI]+Chr(13)+Chr(10))
							Else
								fWrite(nHndTXT,aTXT[nI])
							EndIf
						EndIf							
					Next nI
					FCLOSE( nHndTXT )
					STBFMSignPaf(cPath + cFile + ".txt")
					lGerado := .T. 
				Else
					STFMessage("STWFMLMF3", "POPUP", STR0026 + cFile + STR0202+ cPath )   //' Não foi possível gerar o arquivo :' #" na pasta "
					STFShowMessage("STWFMLMF3")
				EndIf
			Else
				STFMessage("STWFMLMF4", "ALERT", STR0203) //"Problemas na geração do Arquivo. Verifique ! "
				STFShowMessage("STWFMLMF4")
			EndIf
		EndIf	 							
	Else				    
		If lArqTxt
			If lPOS
				STFMessage("STWFMLMF5", "RUN", STR0201, { || STFFireEvent(	ProcName(0),;
														"STMemFisc", ;
														{DTOC(dDataIni), DTOC(dDataFim), cContIni, cContFim,'A'+  cTipoMem} )})    //"Gerando Arquivo...",
				STFShowMessage("STWFMLMF5")

			Else 
				STFMessage("STWFMLMF6", "RUN", STR0201,, { || lRet := IFMemFisc(nHdlECF, DTOC(dDataIni), DTOC(dDataFim), cContIni, cContFim, 'A'+  cTipoMem) } ) //"Gerando Arquivo..."
				STFShowMessage("STWFMLMF6")

			EndIf
			STBFMGerPath( @cPath ) 				
			STBFMSignPaf(cPath + "LMF"+ cTipoMem + ".TXT")
			lGerado := .T.
		Else
			If lPOS
				STFFireEvent(	ProcName(0),;
								"STMemFisc", ;
								{DTOC(dDataIni), DTOC(dDataFim), cContIni, cContFim,'I'+cTipoMem} ) 
			Else 
				IFMemFisc( nHdlECF, DTOC(dDataIni), DTOC(dDataFim), cContIni, cContFim, 'I'+ cTipoMem)
			EndIf
			lGerado := .T.
		EndIf	
    EndIf
EndIf

If lGerado
	//A impressora demora para imprimir o LMF, 
	//portanto espero para não ter problema
	Sleep(5000)
	
	//ER 02.06 - Item 6.26.1.4	
	LjxGrvMdz("MF", 0, "LeituraMemoria", "", "")
EndIf

Return Nil   

//-------------------------------------------------------------------
/*/{Protheus.doc}STWFMLMFD
Opcao "03" Arquivo MF
@param1		cOpcao - Opcao do relatorio
@param2		lPOS - PDV POS?
@author  	Varejo
@version 	P11.8
@since   	03/09/2012
@return  	Nil
/*/
//-------------------------------------------------------------------
Static Function STWFMLMFD(lPOS,aParams)
Local cPath		:= ""
Local nRet		:= 0
Local cDadoIni	:= ""
Local cDadoFim	:= ""
Local cTipo		:= ""
Local aRet		:= {"","",""}

Default aParams := {}

If Len(aParams) > 0
	cTipo	:= aParams[2]
	cDadoIni:= aParams[3]
	cDadoFim:= aParams[4]
	aRet[1]	:= aParams[2]
	aRet[2] := aParams[3]
	aRet[3] := aParams[4]
EndIf

STBFMGerPath( @cPath ) //Caminho
cPath += "mfiscal.bin"
If File( cPath )
	FErase(cPath)
EndIf

If lPOS
	STFMessage("STWFMLMFD1", "RUN", STR0201, { || STFFireEvent(	ProcName(0),"STDownMF", aRet)}) //"Gerando Arquivo..."
	STFShowMessage("STWFMLMFD1")
Else
	LjMsgRun( STR0201 ,, { || nRet := IFMFDown(nHdlECF,cTipo,cDadoIni,cDadoFim) } ) //"Gerando Arquivo..."
EndIf

Return Nil   

//-------------------------------------------------------------------
/*/{Protheus.doc}STWFMMirrorMFD
Opcao "04" "Espelho MFD" 
@param1		cOpcao - Opcao do relatorio
@param2		lPOS - PDV POS?
@author  	Varejo
@version 	P11.8
@since   	03/09/2012
@return  	Nil
/*/
//-------------------------------------------------------------------
Static Function STWFMMirrorMFD( cOpcao, lPOS , lMensagem, aParam)

Local dDataIni  := CTOD("")        			// Data Inicial da Memoria Fiscal
Local dDataFim  := CTOD("")        			// Data Final da Memoria Fiscal
Local cContIni  := SPACE(04)       			// Contador Inicial da Memoria Fiscal
Local cContFim  := SPACE(04)       			// Contador Final da Memoria Fiscal
Local lArqTxt	:= .F.          			// Indica se sera gerado arquivo texto
Local cPath		:= ""						// Caminho
Local cTipo		:= ""						// Tipo
Local nRet		:= 0						// Retorno
Local lAutExc := .F.

DEFAULT cOpcao		:= SPACE(02)       	// Opção a ser selecionada pelo usuário
Default lMensagem	:= .T.
Default aParam		:= {}

lAutExc := Len(aParam) > 0

If lAutExc .Or. STITelMenFis(STR0205, cOpcao,@dDataIni, @dDataFim,@cContIni,@cContFim,,,,lPOS) //"Memoria Fita Detalhe"
 	
 	If lAutExc
 		dDataIni := CtoD(aParam[1])
 		dDataFim := CtoD(aParam[2])
 	EndIf
 	
	If DTOC(dDataIni) <> "  /  /  " .AND. DTOC(dDataFim) <> "  /  /  "
		cTipo := "1"
	Else
		cTipo := "2"
	EndIf

	If lPOS
		STFMessage("STWFMMirrorMFD1", "RUN", STR0201, { || 	STFFireEvent(ProcName(0),;
											"STDownMFD", ;
											{cTipo, If(cTipo == "1",DTOC(dDataIni),cContIni), If(cTipo == "1",DTOC(dDataFim),cContFim)}) } ) //"Gerando Arquivo"
		STFShowMessage("STWFMMirrorMFD1")
	Else
		LjMsgRun(STR0201,, { || nRet := IFDownMFD( nHdlECF, cTipo,;
		 						If(cTipo == "1",DTOC(dDataIni),cContIni), If(cTipo == "1",DTOC(dDataFim),cContFim)) } ) //"Gerando Arquivo"		
	EndIf
EndIf

Return Nil 
 
//-------------------------------------------------------------------
/*/{Protheus.doc}STWFMFileMFD
Opcao "05"  "Arquivo MFD"
@param1		cOpcao - Opcao do relatorio
@param2		lPOS - PDV POS?
@author  	Varejo
@version 	P11.8
@since   	03/09/2012
@return  	Nil
/*/
//-------------------------------------------------------------------
Static Function STWFMFileMFD( cOpcao, lPOS , cTitulo)
Local dDataIni  := CTOD("")        						// Data Inicial da Memoria Fiscal
Local dDataFim  := CTOD("")        						// Data Final da Memoria Fiscal
Local cContIni  := SPACE(04)       						// Contador Inicial da Memoria Fiscal
Local cContFim  := SPACE(04)       						// Contador Final da Memoria Fiscal
Local cPath		:= ""									// Caminho
Local cTipo		:= ""				   					// Tipo
Local lRet		:= .F.									// Retorno     
Local nCont		:= 0 									// Contador
Local nFimArq	:= 0
Local nNewHdl	:= 0
Local nAux		:= 0
Local lLinux	:= (GetRemoteType() == REMOTE_LINUX)   	//Remote Linux?
Local lArqCopy	:= .F.
Local lLineEAD	:= .F.
Local cPathMFD	:= ""                                   //Arquivo MFD
Local cBinario	:= "0" 									//Formato Binário?
Local cInicio	:= ""
Local cFinal	:= ""
Local cBarPath	:= ""
Local cNewPath	:= ""
Local cNameFile	:= ""
Local cNumSerie	:= ""
Local cContTXT	:= ""
Local cLine		:= ""
Local cAux		:= ""
Local aFile		:= {}                                   //Array de Arquivos
Local aDados	:= {}


DEFAULT cOpcao	:= SPACE(02)       	// Opção a ser selecionada pelo usuário
Default cTitulo	:= STR0206			//"Arquivo MFD"

LjGrvLog("", ProcName(0) + "-> Inicio" )
Conout(ProcName(0) + "-> Inicio")

If STITelMenFis(	cTitulo		, cOpcao		, @dDataIni	, @dDataFim	,;
					@cContIni	, @cContFim		,			,			,;
								, lPOS 									)

	LjGrvLog("", ProcName(0) + "-> cOpcao =" + cOpcao )
	Conout(ProcName(0) + "-> cOpcao =" + cOpcao)

	If cOpcao == "21"
		cBinario  := "1"	
	EndIf
	
	If DTOC(dDataIni) <> "  /  /  " .AND. DTOC(dDataFim) <> "  /  /  "
		cTipo	:= "1"
		cInicio	:= DTOC(dDataIni)
		cFinal	:= DTOC(dDataFim)
	Else
		cTipo	:= "2"
		cInicio	:= cContIni
		cFinal	:= cContFim
	EndIf

	LjGrvLog("",ProcName(0) + "-> cBinario:" + cBinario + " / cTipo:" + cTipo + " / cInicio:" + cInicio + " / cFinal:" + cFinal )
	Conout(ProcName(0) + "-> cBinario:" + cBinario + " / cTipo:" + cTipo + " / cInicio:" + cInicio + " / cFinal:" + cFinal)
	
	If lPos
		aDados	:= {Space(30), Nil} 
		aFile	:= STFFireEvent( ProcName(0), "StGetSerie", aDados  )
		If Len(aFile) > 0 .AND. aFile[1] == 0 .AND. Len(aDados) > 0 .AND. !Empty(aDados[1])
			cNumSerie	:= AllTrim(aDados[1])
		ElseIf Len(aFile) = 0 .OR. aFile[1] <> 0
			STFMessage(ProcName(),"STOP","Erro na comunicação com o ECF.") //"Erro na comunicação com o ECF."
			STFShowMessage(ProcName())
		EndIf
		aFile := {}
	Else
		IFPegSerie(nHdlECF, @cNumSerie)
	EndIf
	
	STBFMGerPath( @cPath )
	cPathMFD := cPath

	LjGrvLog("", ProcName(0) + "-> cPathMFD =" + cPathMFD )
	Conout(ProcName(0) + "-> cPathMFD =" + cPathMFD)
	
	If lLinux
	   cPathMFD := cPath + "arq_mfd/"
	   If (At(":",cPathMFD) == 0) .And. !Empty(cPathMFD)
			cPathMFD := "i:"+cPathMFD
	   Endif
	   cBarPath := '/'
	Else
		cPathMFD += PAF_ARQMFD + "\"
		cBarPath := '\'
	Endif
	
	/*Exclui o arquivo para evitar problemas de duplicidade*/	
	If !(cBinario == "1") .And. (cTipo == "2")
		//Efetua a assinatura	
		aFile := Directory(cPathMFD + "*.TXT")
		For nCont:= 1 To Len(aFile)
			If File(cPathMFD + aFile[nCont][F_NAME])
				FErase(cPathMFD + aFile[nCont][F_NAME])
			EndIf
		Next nCont
	EndIf

	If lPOS
		STFMessage("STWFMFileMFD1", "RUN", STR0201, { || STFFireEvent(ProcName(0), "STGerRegTypE", ;
															{ cTipo, cInicio, cFinal, cBinario})}) //"Gerando Arquivo"
		STFShowMessage("STWFMFileMFD1")
	Else
		LjMsgRun( STR0201,, { || lRet := IFGerRegTipoE( nHdlECF, cTipo, cInicio, cFinal, cBinario) } ) //"Gerando Arquivo"
	EndIf
	
	If !(cBinario == "1")
		/*Na impressora Daruma o arquivo do tipo por COO não é copiado para a pasta pela DLL, 
		portanto faço a cópia pelo Protheus de forma generica, caso alguma outra impressora 
		apresente este problema	*/
		aFile := Directory(cPathMFD + "*.TXT")
		If	cTipo == "2" .And. !(Len(aFile) > 0)
			cNewPath := GetPvProfString("PAF-ECF","pathatoecf"	, ""	, GetClientDir() +"SIGALOJA.INI")
			
			If Empty(AllTrim(cNewPath))				 
				If lPOS
					STFMessage(ProcName()+"_2","ALERT",'Arquivo não encontrado no Local padrão! ' + CHR(10)+CHR(13) +;
										"Configure o arquivo SIGALOJA.INI seção [PAF-ECF] a chave pathatoecf com o caminho do arquivo gerado ")
					STFShowMessage(ProcName()+"_2")
				Else
					MsgAlert('Arquivo não encontrado no Local padrão! ' + CHR(10)+CHR(13) +;
							"Configure o arquivo SIGALOJA.INI seção [PAF-ECF], na chave pathatoecf com o caminho do arquivo gerado")
				EndIf

				If lPOS
					STFMessage(ProcName()+"_1","ALERT","Diretorio não informado! Arquivo não encontrado")
					STFShowMessage(ProcName()+"_1")
				Else
					MsgAlert("Diretorio não informado! Arquivo não encontrado")
				EndIf
			Else
				cNewPath += IIf(SubStr(cNewPath,Len(cNewPath)-1,1) <> cBarPath,cBarPath,"")

				aFile := Directory(cNewPath+"*.TXT")
				For nCont := 1 to Len(aFile)
					If !lArqCopy .And. ("ATO_MFD_COO" $ Upper(aFile[nCont][F_NAME]))
						cNameFile := cPathMFD + Upper("MFD" + cNumSerie + "_" +  StrTran(DtoC(dDatabase),'/') + "_" + StrTran(Time(),":") + ".TXT")
						FRenameEx(cNewPath + aFile[nCont][F_NAME],Upper(cNameFile),NIL)
						lArqCopy := .T.
					endIf
					FErase(cNewPath + aFile[nCont][F_NAME])
				Next nCont
			EndIf
		EndIf
		
		//Efetua a assinatura	
		aFile := Directory(cPathMFD + "*.TXT")
		LjGrvLog("", ProcName(0) + "-> variavel aFile ", aFile)
		VarInfo(ProcName(0) + "-> variavel aFile", aFile)
		
		For nCont:= 1 To Len(aFile)
			lLineEAD := .F.
			
			If File(cPathMFD + aFile[nCont][F_NAME])
				
				/*Caso a ultima linha venha assinada devo remover a assinatura e assinar conforme o Protheus*/
				cAux := cPathMFD + "Copy.txt"
				FErase(cAux)
				nNewHdl:= FCreate(cAux)
				
				nHdlArq := FT_FUse(cPathMFD + aFile[nCont][F_NAME])
				FT_FGoTop()
				nFimArq := FT_FLastRec()
				nAux	:= 0
				While !FT_FEof()
					nAux += 1
					If nFimArq == nAux
						cContTXT := FT_FReadLn()
				    
					    If "EAD" $ Upper(cContTXT)
					       Conout("Linha EAD apagada")
					       lLineEAD := .T.
					    EndIf
					Else
						cLine := FT_FReadLn() + CHR(10)
						FWrite(nNewHdl,cLine,Len(cLine))
					EndIf
					
					FT_FSkip()
				End
				
				FT_FUse()
				FClose(nNewHdl)
				
				If lLineEAD
					FErase(cPathMFD + aFile[nCont][F_NAME])
					__CopyFile(cAux,cPathMFD + Upper(aFile[nCont][F_NAME]))
				EndIf
				
				FErase(cAux)
				
				STBFMSignPaf(cPathMFD + aFile[nCont][F_NAME]) //Se alterado o nome do arquivo tera que ser alterado na Sigaloja.Dll
			EndIf
		Next nCont
	Else
		If File(cPathMFD + "DOWNLOAD.BIN")
			STBFMSignPaf(cPathMFD + "DOWNLOAD.BIN",.F., .T.)
			
			cNameFile := cPathMFD + "MFD" + cNumSerie + "_" +  StrTran(DtoC(dDatabase),'/') + "_" + StrTran(Time(),":")
			__CopyFile(cPathMFD + "DOWNLOAD.BIN",cNameFile+".BIN")
			__CopyFile(cPathMFD + "DOWNLOAD.TXT",cNameFile+".TXT")
			
			FErase(cPathMFD + "DOWNLOAD.BIN")
			FErase(cPathMFD + "DOWNLOAD.TXT")
			
			MsgInfo("Arquivo Gerado com Sucesso em [" + cPathMFD + "]","PAF-ECF") 			
		Else
			LjGrvLog("", ProcName(0) + "-> Arquivo DOWNLOAD.BIN não encontrado em : [" + cPathMFD  + "]")
			Conout(ProcName(0) + "-> Arquivo DOWNLOAD.BIN não encontrado em : [" + cPathMFD  + "]")
			MsgAlert(ProcName(0) + "-> Arquivo DOWNLOAD.BIN não encontrado em : [" + cPathMFD  + "]")
		EndIf
	EndIf
EndIf

Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc}STWFMMovEcf
Opcao "08" "Mov por ECF"
@param1		cOpcao - Opcao do relatorio
@param2		lPOS - PDV POS?
@author  	Varejo
@version 	P11.8
@since   	03/09/2012
@return  	Nil
/*/
//-------------------------------------------------------------------
Static Function STWFMMovEcf(cOpcao, lPOS)
Local dDataIni  := CTOD("")        // Data Inicial
Local dDataFim  := CTOD("")        // Data Final
Local cPdv		:= ""				// Numero do pdv
Local xRet		:= NIL

DEFAULT cOpcao	:= SPACE(02)       	// Opção a ser selecionada pelo usuário

If STITelMenFis( STR0207, cOpcao, @dDataIni, @dDataFim, ;
					Nil, Nil, @cPDV, nil,;
					Nil, lPOS ) //"Movimento por ECF"
	/*
		A partir desta versão o registro do PAF 
		será gerado todo na retaguarda e copiado via RPC,
		devido a problemas de perfomance e problema de comunicação
		via WebService
	*/				
	xRet := LJMFRGPaf(lPOS,dDataIni, dDataFim, cPDV,lHomolPaf)
EndIf

Return Nil       

//------------------------------------------------------------------
/*/{Protheus.doc}STWFMTypePay
Opcao "09"  "Meios de Pagtos"
@param1		cOpcao - Opcao do relatorio
@param2		lPOS - PDV POS?
@author  	Varejo
@version 	P11.8
@since   	03/09/2012
@return  	Nil
/*/
//-------------------------------------------------------------------
Static Function STWFMTypePay( cOpcao, lPOS )
Local dDataIni  := CTOD("")        // Data Inicial
Local dDataFim  := CTOD("")        // Data Final

DEFAULT cOpcao	:= SPACE(02)       	// Opção a ser selecionada pelo usuário

If STITelMenFis( STR0208, cOpcao, @dDataIni, @dDataFim,;
				,		,			,			,;
				,	lPOS ) //"Meios de Pagamento"
	STBFMMeiPgto( @dDataIni, @dDataFim, lPOS )
EndIf	

Return Nil      

//-------------------------------------------------------------------
/*/{Protheus.doc}STWFMSellReport
Opcao "12" "Vendas no periodo"
@param1		lPOS - PDV POS?
@author  	Varejo
@version 	P11.8
@since   	03/09/2012
@return  	Nil
/*/
//-------------------------------------------------------------------
Static Function STWFMSellReport(lPOS)
Local nOpcao := 0					// Variavel que armazena a opção digitada

DEFAULT lPOS		:= .F.

If STBFMTipArq(STR0211, @nOpcao) 	//Selecione o Relatorio
	If nOpcao == 1
		STBFMSinteg(lPOS)
	Else 
		STBFMSpedPaf(lPOS)
	EndIf
EndIf
	
Return Nil   

//-------------------------------------------------------------------
/*/{Protheus.doc}STBPerVendas
Pega o intervalo de datas informado e retorna em array
@param dDataIni, date, Data Inicial
@param dDAtaFim, date, Data Final
@author  	Varejo
@version 	P11.8
@since   	03/09/2012
@return  	array
/*/
//-------------------------------------------------------------------
Static Function STBPerVendas(dDataIni, dDataFim, nAtuStep)
Local aPeriodos 	:= {}   					//Periodos 
Local nDifDias  	:= 0
Local lContinua	:= .T.
Local dDtIni		:= CtoD("")
Local dDtFim		:= CtoD("")

DEFAULT dDataIni	:= CtoD("")
DEFAULT dDataFim	:= CtoD("")
DEFAULT nAtuStep	:= 4

nDifDias := dDataFim - dDataIni  // Diferenca de dias

If nDifDias >= 0 .And. nDifDias <= 1
	Aadd( aPeriodos, { dDataIni, dDataFim })
	lContinua := .F.			
Endif

If lContinua
	dDtIni		:= dDataIni
	dDtFim		:= dDataFim
	
	while dDtIni <= dDtFim
		Aadd(aPeriodos,{dDtIni,dDtIni})
		dDtIni := dDtIni + 1 
	End
EndIf
	
Return aPeriodos  

               
//-------------------------------------------------------------------
/*{Protheus.doc} STBLeRelGer
Efetua a leitura dos Relatorios Gerenciais cadastrados no ECF.
@param1		lPOS - PDV POS?
@author  Varejo
@version P11.8
@since   29/03/2012
@return  Nil
@obs     
@sample
*/
//-------------------------------------------------------------------
Static Function STBLeRelGer(lPOS)
Local aTot		 	:= {} 					//Array de Totalizadores
Local cDirClient 	:= GetClientDir()		//Diretorio do Cliente
Local cMsg		 	:= ""					//Mensagem
Local nI		 	:= 0					//Contador
Local lTplAbPend 	:= HasTemplate("PCL") .AND. ExistTemplate("TpPclAPend")   //Indica que esta utilizando o template de posto e a Rotina de Abastecimentos Pendentes
Local lMsg			:= .F.  //Não é necessario mais validar os relatorios (Homologacao 2017 - ER 02.05)

Default lPOS := .F.

If !lPOS

	If SuperGetMV("MV_LJDAVOS",,.F.)
		AAdd(aTot , {	"DAV-OS's Emitidos"			, GetPvProfString("PAF-ECF","OrdemServico"	, ""	, cDirClient+"SIGALOJA.INI") })
	Else
		AAdd(aTot , {	"DAVs Emitidos"				, GetPvProfString("PAF-ECF","DAV"			, ""	, cDirClient+"SIGALOJA.INI") })
	EndIf	
	AAdd(aTot , {   "Meios de Pagamento"		, GetPvProfString("PAF-ECF","MeiosPagto"	, ""	, cDirClient+"SIGALOJA.INI") })
	AAdd(aTot , {   "Parametros de Configuracao", GetPvProfString("PAF-ECF","ParamConfig"	, ""	, cDirClient+"SIGALOJA.INI") })
	AAdd(aTot , {   "Identificação do PAF"		, GetPvProfString("PAF-ECF","IdPaf"			, ""	, cDirClient+"SIGALOJA.INI") })
	AAdd(aTot , {"Documento Auxiliar de Venda - Orcamento", GetPvProfString("PAF-ECF","DAVECF", "", cDirClient+"SIGALOJA.INI") })
	If lTplAbPend
		AAdd(aTot , {   "Abastecimentos Pendentes"	, GetPvProfString("PAF-ECF","AbastePendente"	, ""	, cDirClient+"SIGALOJA.INI") })
		AAdd(aTot , {   "Controle de Encerrantes"	, GetPvProfString("PAF-ECF","Encerrantes"		, "" 	, cDirClient+"SIGALOJA.INI") })
	EndIf
	
	//PafNfce - não exigido - Ato ER 02.05
	//Aadd(aTot , { "LojNfce" , GetPvProfString("PAF-ECF","danfenfce"		, "" /*"DanfeNfce"*/	, cDirClient+"SIGALOJA.INI") })
	
Else
	AAdd(aTot , {   "Parametros de Configuracao", GetPvProfString("PAF-ECF","ParamConfig"	, ""	, cDirClient+"SIGALOJA.INI") })
	AAdd(aTot , {   "Identificação do PAF"		, GetPvProfString("PAF-ECF","IdPaf"			, ""	, cDirClient+"SIGALOJA.INI") })
EndIf	

For nI := 1 to Len(aTot)
	If Empty(AllTrim(aTot[nI][2]))
		cMsg += " - " + aTot[nI][1] +CHR(13)
	EndIf
Next nI

If lMsg .And. !Empty(AllTrim(cMsg))
	
	If lPos
		STFMessage("STBLeRelGer", "STOPPOPUP", STR0212 +; //"Verifique se o Relatório(s) Gerencial(is) para impressão de: "
			 								CHR(13) + cMsg +;
			 								STR0213) //"Exigido(s) no PAF-ECF, está(ão) cadastrado(s) no arquivo SIGALOJA.INI e no ECF"
			 
		STFShowMessage( "STBLeRelGer")
	Else
		MsgStop( STR0212 +; //"Verifique se o Relatório(s) Gerencial(is) para impressão de: "
			 	CHR(13) + cMsg +;
			 	STR0213) //"Exigido(s) no PAF-ECF, está(ão) cadastrado(s) no arquivo SIGALOJA.INI e no ECF"
	EndIf                                          
EndIf

Return

//--------------------------------------------------------
/*{Protheus.doc}STBLoadFisMenu
Carrega o Menu Fiscal - PAF-ECF
@param1		cERPAFECF - ER PAF-ECF
@param2		lUsaTrocoSC - Usa Troco SC?
@param3		lTplAbPend - Tabela Abastecimentos Pendentes
@param4		nLimite - Limite Menu fiscal
@param5		nLnMenu - Linha do Menu
@author  	Varejo
@version 	P11.8
@since   	02/08/2013
@return  	aRet - Array de Retorno 
@obs   
@sample
*/
//-------------------------------------------------------
Function STBLoadFisMenu(cERPAFECF, lUsaTrocoSC, lTplAbPend, nLimite,;
						nLnMenu)
Local aRet 				:= {}																//Retorno da Rotina
Local lOnlyMenuFiscal 	:= STFGetCfg( "lOnlyMenuFiscal" ) //Somente Menu Fiscal
Local lMvLjPdvPa		:= LjxBGetPaf()[2]
Local lIsPafNfce        := STFGetCfg("lPAFNFCE") .Or. IIf(ExistFunc("LjPafNFCe"),LjPafNFCe(),.F.)	 //Usa PAF-NFC-e c/ Impressora Não Fiscal
Local lAutomato 		:= If(Type("lAutomatoX")<>"L",.F.,lAutomatoX)


Default cERPAFECF		:= ""
Default lUsaTrocoSC 	:= .F.  
Default lTplAbPend 		:= .F.  
Default nLnMenu 		:= 2
Default nLimite			:= 0

//Posicao do Array aREt
//1 - Código da Função selecionada pelo usuário
//2 - Descrição do Menu
//3 - Código Interno da Função
If lMvLjPdvPa .OR. lIsPafNfce
	If !lOnlyMenuFiscal

		If lIsPafNfce //Função para validar PAF-NFC-e
			aAdd(aRet, {"01","Identificação do PAF-NFC-e","11", nLnMenu := nLnMenu + 8}) //"Identificação do PAF-NFC-e"
			aAdd(aRet, {"02","Registros do PAF-NFC-e","22", nLnMenu := nLnMenu + 8}) //"Registros do PAF-NFC-e"
			aAdd(aRet, {"03","Saídas Identificadas pelo CPF/CNPJ","26", nLnMenu := nLnMenu + 8}) //"Saídas Identificadas pelo CPF/CNPJ"
			aAdd(aRet, {"04","Requisições  Externas  Registradas","30", nLnMenu := nLnMenu + 8})//"Requisições  Externas  Registradas"
			aAdd(aRet, {"05","Controle dos DAV","31", nLnMenu := nLnMenu + 8}) //"Controle dos DAV" 
			
		Else
			aAdd(aRet, {"01",STR0214, "01", nLnMenu} ) //"LX" 
			aAdd(aRet, {"02",STR0232 ,"19", nLnMenu := nLnMenu + 8}) //"LMF"
			aAdd(aRet, {"03",STR0233 ,"20", nLnMenu := nLnMenu + 8}) //"Arq. MF"
			aAdd(aRet, {"04",STR0218 ,"21", nLnMenu := nLnMenu + 8}) //"Arq. MFD"
			aAdd(aRet, {"05","Arq. AC 17/04", "27", nLnMenu := nLnMenu + 8})
			aAdd(aRet, {"06",STR0224,"11", nLnMenu := nLnMenu + 8}) //"Identificação do PAF-ECF"
			//aAdd(aRet, {"07",STR0225,"12", nLnMenu := nLnMenu + 8})    //"Vendas do Periodo" - Removido do Ato na ER 02.05
			aAdd(aRet, {"07",STR0226,"13", nLnMenu := nLnMenu + 8}) //"Tab.Ind.Tec.Producao"
			aAdd(aRet, {"08",STR0227,"14", nLnMenu := nLnMenu + 8}) //"Parâmetros de Configuração"
			aAdd(aRet, {"09",STR0234,"22", nLnMenu := nLnMenu + 8}) //"Registros do PAF-ECF"
			aAdd(aRet, {"10","Espelho MFD","23", nLnMenu := nLnMenu + 8}) //"Espelho MFD"
			aAdd(aRet, {"11","Envio ao FISCO-REDUÇÃO Z","24", nLnMenu := nLnMenu + 8}) //"Envio ao FISCO-REDUÇÃO Z"		
			aAdd(aRet, {cValToChar(len(aRet)+1),"Envio ao FISCO-ESTOQUE","25", nLnMenu := nLnMenu + 8})  	//"Envio ao FISCO-ESTOQUE"
			aAdd(aRet, {cValToChar(len(aRet)+1),"Vendas Identificadas pelo CPF/CNPJ","26", nLnMenu := nLnMenu + 8}) //"Vendas Identificadas pelo CPF/CNPJ"
		EndIf
					
		/*If lUsaTrocoSC - Ate homologacao 2017 não disponibilizamos no PAF
			aAdd(aRet, {"15",STR0228,"15", nLnMenu := nLnMenu + 8})   //"Troco em cartao"
			nLimite := 15
		EndIf*/	
		
		If lTplAbPend
			aAdd(aRet, {"16",STR0229,"16", nLnMenu := nLnMenu + 8})//"Abastecimentos Pendentes"
			aAdd(aRet, {"17",STR0230,"17", nLnMenu := nLnMenu + 8})//"Encerrantes
			aAdd(aRet, {"18",STR0231,"18", nLnMenu := nLnMenu + 8})	//"Manutenção de Bomba" 
		EndIf

	Else
		aAdd(aRet, {"01",STR0226,"13", nLnMenu := nLnMenu + 8}) //"Tab.Ind.Tec.Producao"
		aAdd(aRet, {"02",STR0234,"22", nLnMenu := nLnMenu + 8})	//"Registros do PAF-ECF"
		aAdd(aRet, {"03","Envio ao FISCO-REDUÇÃO Z","24", nLnMenu := nLnMenu + 8})    //"Envio ao FISCO-REDUÇÃO Z"		
		aAdd(aRet, {"04","Envio ao FISCO-ESTOQUE","25", nLnMenu := nLnMenu + 8})    //"Envio ao FISCO-ESTOQUE"
		aAdd(aRet, {"05","Vendas Identificadas pelo CPF/CNPJ","26", nLnMenu := nLnMenu + 8})    //"Vendas Identificadas pelo CPF/CNPJ"
	EndIf
Else
	//Retaguarda pode enviar os arquivos XML
	aAdd(aRet, {"01","Envio ao FISCO-REDUÇÃO Z","24", nLnMenu})    //"Envio ao FISCO-REDUÇÃO Z"		
	aAdd(aRet, {"02","Envio ao FISCO-ESTOQUE","25", nLnMenu := nLnMenu + 8})    //"Envio ao FISCO-ESTOQUE"
EndIf

nLimite := Len(aRet)

Return aRet  

//--------------------------------------------------------
/*{Protheus.doc}STBImRgPAF
Gera o Arquivo do PAF-ECF
@param1		dDataIni - Data Inicial
@param2		dDataFim - Data Final
@param3		cPDV - Código do PDV
@param4		lReducao - Execução após Redução?
@param5		lPOS - PDV POS
@param6 	lIsPafNfce - lógico - PAF-NFCe
@author  	Varejo
@version 	P11.8
@since   	02/08/2013
@return  	lGera, logico, se arquivo será gerado ou não ?  
@obs   
@sample
*/
//-------------------------------------------------------
Function STBImRgPAF( dDataIni, dDataFim	, cPDV, lReducao,;
					lPOS	 , lIsPafNfce)
Local lRet			:= .F.					//Retorno de Processamento
Local nHandle		:= 0					//Handle do arquivo
Local nX			:= 0 					//Variavel contadora   
Local nValor		:= 0					//Valor da rotina
Local cPath			:= ""     	        	//Variavel contendo o Caminho para os arquivos do PAF-ECF
Local cFile     	:= ""               	//Variavel contendo o Nome do Arquivo que sera gerado
Local cConteudo		:= ""					//Conteudo do arquivo
Local cSeriePDV		:= ""					//Serie do PDV	
Local cDataAtu		:= Dtos(dDataBase) 	//Data Base
Local cECF			:= ""					//ECF
Local cCodECF		:= ""                   //Codigo Nacional de Identificação de ECF 
Local cMarca    	:= ""					//Marca do ECF
Local cModelo   	:= ""					//Modelo do ECF 
Local cMfAdic   	:= ""              		//Letra indicativa de MF adicional 
Local cTipoEcf  	:= ""              		//Tipo de ECF 
Local cVerSB    	:= ""              		//Versão atual do Software Basico do ECF gravada na MF 
Local cDtInsSB  	:= ""             		//Data de instalacao da versao atual do Software Basico do ECF
Local cHrInsSB  	:= ""              		//Horario de instalacao da versao atual do Software Basico do ECF
Local nUsuEcf   	:= 0               		//N de ordem do usuario do ECF relativo respectiva Reducao Z 				
Local cERPAFECF		:= ""					//ER do PAF-ECF			
Local cRazaoSoc		:= ""					//Razão Social
Local cIEECF		:= ""
Local cCnpjECF		:= ""
Local lInterroga	:= .F. 
Local cWSServer		:= ""  //Server WS
Local lLjSimpNac 	:= SuperGetMV("MV_LJSIMPN",,.F.) //Simples Nacional?
Local lPreVenda	 	:= SuperGetMV("MV_LJPRVEN",,.F.)	//Pre-Venda?
Local lIncManu		:= .F.					//Inclusão Manual
Local lAllPDV		:= .f.					//Todos PDVs?
Local lOK			:= .F.
Local lGera			:= .T.
Local xRet			:= NIL
Local cArqPNFCe		:= ""		//nome do arquivo PAF-NFCE gravado

Default dDataIni 	:= CtoD("")
Default dDataFim 	:= CtoD("")
Default cPDV 		:= ""
Default lReducao 	:= .F.
Default lPOS 		:= .F.
Default lIsPafNfce	:= .F. 

//Validação de tabelas necessárias para geração do arquivo
If !lReducao
	If !StbVldTab()
		lGera := .F.
	EndIf
	
	//Validação dos dados para geração do arquivo
	If lGera .And. !lHomolPaf .And. !StbVldArq(dDataIni, dDataFim) .And.;
		! MsgYesNo("Arquivo de Registro do PAF será gerado com inconsistência. Deseja Continuar ?","Registros do PAF-ECF")

		lGera := .F.
	EndIf
	
	If lGera
		STBBuscaTotECF( "", lPOS, {} )
	EndIf
EndIf

If lGera
	/*
		A partir desta versão o registro do PAF 
		será gerado todo na retaguarda e copiado via RPC,
		devido a problemas de perfomance e problema de comunicação
		via WebService
	*/
	If ExistFunc("LJMFRGPaf")
		LjGrvLog(Nil,"Chamada da nova geração do Registro do PAF via RPC")
		xRet := LJMFRGPaf(lPOS,dDataIni, dDataFim, cPDV,lHomolPaf,lReducao, lIsPafNfce, @cArqPNFCe)
		LjGrvLog(Nil,"Retorna da nova geração do Registro do PAF via RPC",xRet)
		If xRet .AND. lIsPafNfce
			STBGeraXML(cArqPNFCe, "II") 
		Endif 
	Else
		
		LjGrvLog(Nil,"Função LJMFRGPaf não encontrada, portanto Registros do" +;
			" PAF serão efetuados via WebService [ATUALIZAR FONTE LOJREGPAF]")

		cERPAFECF	:= STBVerPAFECF("ERPAFECF")
		
		If lPOS
			cECF		:= STFGetStat("IMPFISC")
			cWSServer	:= AllTrim(STFGetStat("WSSRV"))
		Else
			cECF		:= LJGetStation("IMPFISC")
			cWSServer	:= AllTrim(LjGetStation("WSSRV"))
		EndIf
		
		/* Recupera marca e modelo do ECF */
		nX := At(" ",cECF)
		cMarca := SubStr(cECF,1,nX-1)
				
		DBSelectArea("SFI")
		SFI->(DbSetOrder(1)) //FI_FILIAL+DTOS(FI_DTMOVTO)+FI_PDV+FI_NUMREDZ
		SFI->(DbSeek(xFilial("SFI") + DTOS(dDataIni),.T.))
		
		//PAF-ECF: Atualiza dados do ECF para ser utilizado no Movimento por ECF
		STBDadosEcf(lPOS)
		
		cPDV	:= AllTrim(cPDV)
		lAllPDV := Empty(cPDV)
		
		STFMessage("STBImRgPAF1", "RUN","Buscando dados da estação" ,{||lRet := ;
														STBBuscaDados(	@cMfAdic, @cTipoEcf, @cModelo, @cVerSB, ;
																		@cDtInsSB, @cHrInsSB, @cCodECF, @nUsuEcf, ;
																		@cSeriePDV, @cMarca , @cIEECF, @cCnpjECF)})
		STFShowMessage("STBImRgPAF1")
		
		If !lRet 
			lGera := .F.
		EndIf    
		
		If lGera
			nHandle := STBCrtRegPAF(dDataIni, dDataFim, cPDV, lReducao,cSeriePDV, cCodECF, cDataAtu, @cFile)	
			
			If nHandle > 0
				//Primeiro Registro
			   	cConteudo := Replicate("X",94) + CHR(13) + CHR(10)
				FWRITE( nHandle, cConteudo, LEN( cConteudo ) )
			
				//Gera o Registros A´s
				If !lLjSimpNac				  
					STBFMMeiPgto( 	dDataIni, dDataFim, 	lPOS, 	cPDV, ;
									cWSServer, @lIncManu, nHandle, 	lReducao,;
									lAllPDV)
				EndIf
			
				lInterroga	:=  lIncManu
				If lIncManu
					Conout("STBFMMeiPgto com interrogação")
					LjGrvLog(Nil,"STBFMMeiPgto com interrogação")
				Endif
				lIncManu	:= .F.
				
				//Gera os Registros P's
				xRet := STBFMImpTabProd(cWSServer, lPOS, nHandle, @lIncManu,lReducao)
			
				lInterroga	:=  lInterroga .Or. lIncManu
				If lIncManu
					Conout("STBFMImpTabProd com interrogação")
					LjGrvLog(Nil,"STBFMImpTabProd com interrogação")
				Endif
				lIncManu 	:= .F.
				
				//Gera os Registros E2, E3 (verificando a selecao)
				If xRet .And. !lLjSimpNac	
					STBFMImpEst(	cWSServer, lPOS , !lReducao, nHandle, ;
									dDataIni, dDataFim, @lIncManu   ,;
									lReducao,cPDV	)
					lInterroga	:=  lInterroga .Or. lIncManu
					If lIncManu
						Conout("STBFMImpEst com interrogação")
						LjGrvLog(Nil,"STBFMImpEst com interrogação")
					Endif
					lIncManu	:= .F.
				EndIf
				
				If xRet .And. !lPreVenda
					//Gera os Registros D2,D3,D4 
					STBFMDavEmt(dDataIni, 	dDataFim, 	.T., "",;
								lPOS,		cWSServer,  @lIncManu, nHandle)  
					lInterroga	:=  lInterroga .Or. lIncManu
					If lIncManu
						Conout("STBFMDavEmt com interrogação")
						LjGrvLog(Nil,"STBFMDavEmt com interrogação")
					Endif
					lIncManu	:= .F.	
				EndIf
						
				//Gera o registros H2 
				/*If lUsaTrocoSC - revogado do ato
					STBTrcCard(dDataIni, dDataFim, cFile, lPOS, cWSServer, nHandle)  
				EndIf*/
				
				If xRet <> NIL .And. ValType(xRet) == "L" .And. xRet
					lInterroga	:=  lInterroga .Or. lIncManu
	
					lIncManu	:= .F.
					
					cRazaoSoc := PADR( SM0->M0_NOMECOM, 50 )
					If lHomolPaf .AND. lInterroga
						cRazaoSoc := StrTran( PADR( SM0->M0_NOMECOM, 50 ) , " ", "?" ) 	// Razao Social
					EndIf
					cConteudo := "U1"
					cConteudo += PADR( SM0->M0_CGC, 14 ) 		// CNPJ
					cConteudo += PADR( SM0->M0_INSC, 14 )	 	// Incricao Estadual                      
					cConteudo += PADR( SM0->M0_INSCM, 14 ) 		// Incricao Municipal
					cConteudo += cRazaoSoc
					cConteudo += CHR(13) + CHR(10)
					
					FSEEK(nHandle, 0, 0)
					FWRITE(nHandle, cConteudo, LEN( cConteudo ))
					FCLOSE(nHandle)
				
					STBFMSignPaf(cFile)
					LjGrvLog(Nil,"Arquivo gerado com sucesso")
					lOK := .T.
				EndIf
			EndIf
		
			If !lOk
				Alert("Arquivo incompleto - Erro na Execução - Verifique os Logs (Console,LogLoja) em busca das inconsistências")
				LjGrvLog(Nil,"Pilha:" + CHR(10)+CHR(13) +;
						ProcName(0) + CHR(10)+CHR(13)+;
						ProcName(1) + CHR(10)+CHR(13)+;
						ProcName(2) + CHR(10)+CHR(13)+;
						ProcName(3) + CHR(10)+CHR(13))	
			EndIf
		EndIf
	EndIf
EndIf

ASize(aAliquotas,0)

Return lGera

//--------------------------------------------------------
/*{Protheus.doc}STBCrtRegPAF
Cria o Arquivo do PAF-ECF
@param1		dDataIni - Data Inicial
@param2		dDataFim - Data Final
@param3		cPDV - Código do PDV
@param4		lReducao - Execução após Redução?
@param5		cSeriePDV - Serie do PDV
@param6		cCodECF - Codido do ECF
@param7		cDataAtu - Data de Atualização
@param8		cFile - Arquivo
@author  	Varejo
@version 	P11.8
@since   	02/08/2013
@return  	nHandle - Handle do Arquivo 
@obs   
@sample
*/
//--------------------------------------------------------
Function STBCrtRegPAF(	dDataIni, 	dDataFim, cPDV	, lReducao, ;
						cSeriePDV, 	cCodECF, cDataAtu, cFile)
Local nHandle	:= -1				// Handle do Arquivo
Local cRet		:= ""     			// Variavel Temporaria
Local cPath		:= ""    			// Variavel contendo o caminho para os arquivos do PAF-ECF
Local lRet		:= .T.
Local lTry		:= .F.
Local nTry		:= 0
	
Default	dDataIni	:= CtoD("")
Default	dDataFim	:= CtoD("")
Default	cPDV		:= ""
Default	lReducao	:= .F. 
Default	cSeriePDV	:= ""
Default	cCodECF	:= ""
Default	cDataAtu	:= ""
Default	cFile		:= ""

cSeriePDV := AllTrim(cSeriePDV) // 14 (quatorze) ultimos dígitos do numero de fabricação do ECF

//Gera Arquivo
cFile	:= PadR(cCodECF , 6, "0")
cFile	+= PADR(Right(cSeriePDV,14) , 14, "_")
If lReducao
	cRet    := Dtos( dDataIni )
	cFile	+= SubStr(cRet,7,2)+SubStr(cRet,5,2)+SubStr(cRet,1,4)
Else
	cFile	+= SubStr(cDataAtu,7,2)+SubStr(cDataAtu,5,2)+SubStr(cDataAtu,1,4)
EndIf
cFile	+= ".TXT"

//Pega Path e verifica se o Arquivo ja existe
If !STBFMGerPath( @cPath )
	lRet	:= .F.
	nHandle:= -1
EndIf

If lRet
	While !lTry
		If File(cPath + cFile)
			FErase(cPath + cFile)
		EndIf

		nHandle := FCREATE(cPath + cFile, FC_NORMAL )
		
		If nHandle <= 0
			STFMessage("STBCrtRegPAF1","STOPPOPUP",STR0002 + cFile) //"Erro ao criar o arquivo "
			STFShowMessage("STBCrtRegPAF1")
			nTry += 1
			If nTry < 5
				MsgAlert("Tentaremos re-gerar o arquivo , verifique se ele esta sendo usado por outro programa !!!","PAF-ECF")
				Sleep(1000)
			EndIf
		Else
			cFile:= cPath + cFile
			nTry := 5
		EndIf
		
		lTry := nTry == 5
	End
EndIf
	
Return nHandle

//--------------------------------------------------------
/*{Protheus.doc}STWRegPAF
Função do Menu Fiscal - Registros do PAF-ECF
@param1		cOpcao - Opção do Menu Fiscal
@param2		lPOS - PDV POS?
@param3		lIsPafNfce - lógico - PAF-NFCe
@author  	Varejo
@version 	P11.8
@since   	02/08/2013
@return  	NIL 
@obs   
@sample
*/
//--------------------------------------------------------
Static Function STWRegPAF(cOpcao, lPOS, lIsPafNfce )
Local dDataIni	:= CtoD("")		// Data Inicial
Local dDataFim	:= CtoD("")		// Data Final	
Local cPDV		:= ""			// PDV
Local lCheckPDV	:= .F.
Local lRedZ		:= .F.

Default	cOpcao		:= ""
Default	lPOS		:= .F.
Default lIsPafNfce	:= .F. 

If STITelMenFis(	STR0234, cOpcao	, @dDataIni	, @dDataFim	,;
					Nil		, Nil		, @cPDV		, nil			,;
					Nil		, lPOS		, Nil			, Nil			,;
					@lCheckPDV ) //"Registros do PAF-ECF"

	/* Efetua ajuste de acordo com os dados que necessitam estar 
	preenchidos para correta geração do arquivo de Registro do PAF */
	AjstPAFECF(lPOS)

	If lCheckPDV
		If lPOS
			cPDV := STFGetStat("PDV")
		Else
			cPDV := LJGetStation("PDV") 
		EndIf 
		lRedZ	:= .T.
	Else
		cPDV := ""
	EndIf

	STBImRgPAF(dDataIni, dDataFim, cPDV, lRedZ,lPOS, lIsPafNfce)
EndIf

Return

//--------------------------------------------------------
/*{Protheus.doc}STDRetagPDV
Verifica se existe algum PDV cadastrado como POS na retaguarda
@param1		cFilSLG - Filial do SLG
@author  	Varejo
@version 	P11.8
@since   	02/08/2013
@return  	lRet - PDV Pos cadastrado 
@obs  - Função criada neste fonte para ter somente um fonte PAF na retaguarda     
@sample
*/
//--------------------------------------------------------
Function STDRetagPDV(cFilSLG) 
Local aArea		:= GetArea()			//WorkArea Ativa
Local aAreaSLG 	:= SLG->(GetArea()) 	//WorkAreaSLG
Local lRet 		:= .F.					//Retorno da rotina 
	
Default cFilSLG := xFilial("SLG") 

SLG->(DbSetOrder(1)) //LG_FILIAL+LG_CODIGO
SLG->(DbSeek(cFilSLG))
Do While !lRet .AND. SLG->(!Eof() .AND. LG_FILIAL == cFilSLG)  
	lRet := SLG->LG_ISPOS == "1"
	SLG->(DbSkip())
EndDo

RestArea(aAreaSLG)
RestArea(aArea)

Return lRet


//-----------------------------------------------------------------
/*{Protheus.doc} STBCotepe3505
Efetua a geração do arquivo do Ato Cotepe 35/2005.
@author  Varejo
@version P11.8
@since   17/09/2013
@return  Nil
@obs     
@sample
*/
//-------------------------------------------------------------------
Function STBCotepe3505(lPos)
Local	aFiliais	:= ""				   	// Filiais do Arquivo
Local	lEnd		:= .F.					// Final da rotina	
Local	lProssegue	:= .F.					// Prossegue com o processamento?
Local	aWizard 	:= {}					// Wizard da rotina
Local	cNomWiz		:= "COTEPE35"+ FWGrpCompany() + FWGETCODFILIAL	// Nome do Wizard
Local	lRet		:= .F.					// Retorno da rotina
Local	cPathSrv  	:= "\SYSTEM\"			// Path do sistema 
Local	cFileSrv	:= "COTEPE3505.TXT"		// Arquivo gerado
Local	cPathLocal	:= ""					// Path destino
Local	cPerg		:= ""					// Pergunta

cPerg := PadR("COTEPE",Len(SX1->X1_GRUPO))

PERGUNTE(cPerg, .F.)

aFiliais := MatFilCalc(.F.)
MV_PAR01 := 2
MV_PAR02 := 2
MV_PAR03 := 1

lProssegue := Cot35MontWiz( cNomWiz )

If lProssegue

	If !xMagLeWiz(cNomWiz,@aWizard,.T.)
		lProssegue := .F.
	EndIf
	
	If lProssegue
	    cPathSrv := aWizard[1][4] := "\system\"
	    
	    If Empty(aWizard[1][5])
	    	aWizard[1][5] := cFileSrv
	    Else
	    	cFileSrv := aWizard[1][5]
	    EndIf	
	   
		If !lPOS  
	   		LjMsgRun(STR0235 ,, { || FR271CMyCall( "PAFCot35",Nil,@lEnd, aWizard, @cFileSrv,aFiliais, .T.)} ) //"Processando dados..."			
		Else
						                
			lProssegue := STBRemoteExecute(	"PAFCot35"		,;
											{lEnd, aWizard, cFileSrv,aFiliais, .T.}	,;
											Nil				,;
											.F. 			,;
											@lRet			)
			STFShowMessage("STBCotepe3505_1")
		EndIf
						
		If lProssegue
			If lHomolPaf
				ConOut("Execução com sucesso - PAFCot35")
			EndIf				
			
			//StartPath no servidor(RPC), local onde eh gerado o arquivo
			cPathSrv := STBFMPathSrv(lPos)
			
			//Path local padrao PAF-ECF para armazenar o arquivo
			STBFMGerPath( @cPathLocal )				
						
			//Chama rotina(RPC) para copiar o conteudo do arquivo na pasta padrao do PAF-ECF
			STBFMGetFile( cPathSrv,	cFileSrv,	cPathLocal,	cFileSrv,.T. , lPos)
			
			//Assina arquivo conforme previsto no PAF-ECF
			If File(cPathLocal + cFileSrv)
				STBFMSignPaf( cPathLocal + cFileSrv  )
			Else
				If lPos
					STFMessage("STBCotepe3505_2","STOPPOPUP",  STR0236 + cPathLocal + cFileSrv) //"Não foi possível gerar o arquivo:"
					STFShowMessage("STBCotepe3505_2")
				Else
					Alert(STR0236 + cPathLocal + cFileSrv) //"Não foi possível gerar o arquivo:"
				EndIf
			EndIf			
	
	
		ElseIf lHomolPaf
			ConOut("erro na execução - " + "PAFCot35")
		EndIf
	EndIf
EndIf

Return

//--------------------------------------------------------
/*{Protheus.doc}STBLeArq
Cria e le arquivo contando infos ECF	
@param1		lCria - Cria o arquivo
@param2		aConteudoTXT - Conteudo do Arquivo 
@author  	Varejo
@version 	P11.8
@since   	02/08/2013
@return  	lRet - Arquivo Criado/Lido 
@obs     
@sample
*/
//--------------------------------------------------------
Static Function STBLeArq( lCria , aConteudoTXT)
Local cPathSmart:= "" 				//Caminho da pasta Smart Client
Local cNomeArq	:= "ALECF.LOJ" 		//Nome do Arquivo de Aliquotas do ECF
Local nHandleTXT:= 0				//Handle do arquvio			
Local nX		:= 0				//Variavel Contadora
Local cConteudo	:= ""				//Conteudo do Arquivo
Local cVarTXT	:= ""				//Conteudo do Arquivo
Local cDadoTXT	:= ""				//Conteudo do Arquivo
Local aTXT		:= {}				//Linhas do Arquivo
Local lRet		:= .T.				//Retorno da Rotina
Local cVariavel	:= ""               //Variável de gravação
Local lOk		:= .F.				//Retorno da rotina
Local lContinua	:= .T.              //Continua processamento?

DEFAULT lCria			:=	.F.
DEFAULT aConteudoTXT	:=	{}
 
cPathSmart := GetClientDir()

If lCria .AND. Len(aConteudoTXT) > 0	
	If File(cPathSmart + cNomeArq)
		FErase(cPathSmart + cNomeArq)
	EndIf
	
	nHandleTXT := FCREATE( cPathSmart + "DadoAr.TXT", FC_NORMAL )
	
	If lHomolPaf
		ConOut(" STBFiscalMenu - STBLeArq-> HANDLE " + cValToChar(nHandleTXT))
	EndIf
	
	If nHandleTXT < 0  
		If lHomolPaf
			Conout(" STBFiscalMenu - STBLeArq-> Erro ao criar arquivo " + cPathSmart + cNomeArq) //"Erro ao criar arquivo "
		EndIf			
	Else
		cConteudo := ""
		cVariavel := ""
		For nX := 1 to Len(aConteudoTXT)
			cConteudo := aConteudoTXT[nX][1] + "|" + aConteudoTXT[nX][2] + CHr(13) + CHR(10)
			cVariavel += aConteudoTXT[nX][1] + "|" + aConteudoTXT[nX][2] + "#"
			FWRITE( nHandleTXT, cConteudo, LEN( cConteudo ) )
		Next nX				
		
		FCLOSE( nHandleTXT )
		FRENAME(cPathSmart + "DadoAr.TXT" ,cPathSmart + cNomeArq)
		FERASE(cPathSmart + "DadoAr.TXT")     
		If lHomolPaf
			Conout(" STBFiscalMenu - STBLeArq -> Arquivo " + cPathSmart + cNomeArq + " Gerado com Sucesso")
		EndIf
		
		aSLG := {{"LG_ALQINFO", AllTrim(cVariavel)}}
		
		lContinua := .T.
		SetStat( xFilial("SLG") , Iif(lTotvsPDV , STFGetStat("CODIGO") , LjGetStation("CODIGO") ),  aSLG)
		If lTotvsPDV
			STBRemoteExecute( "SetStat" , { xFilial("SLG") , STFGetStation("CODIGO") , aSLG }, Nil, .F. , @lOk )
		Else
			FR271CMyCall("SetStat",{"SLG"},xFilial('SLG'),LjGetStation("CODIGO") , aSLG)				
		EndIf
		
		lRet := lRet .AND. lContinua
	EndIf
	

ElseIf !lCria
	
	aTXT := STWReadFile( cPathSmart , cNomeArq, 0, .F. ) //Pega conteudo de cFile , no caminho cPathDLLArq com indice 0 e permite a deleção do arquivo 

	If ValType(aTXT) == "A" .AND. Len(aTXT) > 1
		aConteudoTXT := {}
		For nX := 1 To Len(aTXT)
			If !Empty(AllTrim(aTXT[nX]))				
				cVarTXT	:= Substr(aTXT[nX] ,1,At("|",aTXT[nX])-1)
				cDadoTXT	:= Substr(aTXT[nX] ,At("|",aTXT[nX])+1,Len(aTXT[nX]))
				Aadd( aConteudoTXT , {cVarTXT,cDadoTXT} )	
			EndIf							
		Next nX				
	EndIf
EndIf	

Return lRet    

//--------------------------------------------------------
/*{Protheus.doc}STBPDVBusca
Formata as informações do PDV retornadas pela retaguarda	
@param1		aRetPDV - Dados da Estação
@param2		aECF - Retorno da Função (tratado) 
@author  	Varejo
@version 	P11.8
@since   	15/10/2013
@obs     
@sample
*/
//--------------------------------------------------------
Static Function STBPDVBusca(aRetPDV, aECF)
Local	nX			:= 0	// Variavel contadora
Local	nY			:= 0	// Varivavel contadora    
Local	cAlqInfo	:= ""	// Informações da Alíquota
Local	cECFInfo	:= ""	// Informações do ECF
Local	nZ			:= 0	// Contador
Local	cTmp		:= ""	// Variável temporária
	
Default	aRetPDV:= {}
Default	aECF	:= {}	
	
For nX	:= 1 to Len(aRetPDV) 
	aAdd(aECF, aRetPDV[nX] )
	nZ 					:= Len(aECF)
	cAlqInfo			:= aECF[nZ]:cAlqInfo
	cECFInfo			:= aECF[nZ]:cECFInfo
	aECF[nZ]:cAlqInfo	:= {}
	aECF[nZ]:cECFInfo	:= {}
	aECF[nZ]:cImpFisc	:= Substr(aECF[nZ]:cImpFisc, 1, At(" - ",  aECF[nZ]:cImpFisc))
	
	Do While !Empty(cAlqInfo)
		nY := AT("#", cAlqInfo)
		
		If nY > 0
			cTmp := Substr(cAlqInfo, 1, nY-1)
			cAlqInfo := Substr(cAlqInfo, nY+1)
			nY := AT("|", cTmp)
			If nY > 0
				aAdd(aECF[nZ]:cAlqInfo, {Substr(cTmp, 1, nY-1),Substr(cTmp, nY+1) })
			EndIf
		Else
			cAlqInfo := ""
		EndIf
	 EndDo

	Do While !Empty(cECFInfo)
		nY := AT("#", cECFInfo)
		
		If nY > 0
			cTmp := Substr(cECFInfo, 1, nY-1)
			cECFInfo := Substr(cECFInfo, nY+1)
			nY := AT("|",cTmp)
			If nY > 0
				aAdd(aECF[nZ]:cECFInfo, {Substr(cTmp, 1, nY-1),Substr(cTmp, nY+1) })
			EndIf
		Else
			cECFInfo := ""
		EndIf
	 EndDo
Next nX

Return

//--------------------------------------------------------
/*{Protheus.doc}STBGetPDVInfo
Retorna as informações do PDV	
@param1		cTipo - Tipo da Informação
@param2		aECF - Dados da Estação
@author  	Varejo
@version 	P11.8
@since   	15/10/2013
@return  	cRet - Informação 
@obs     
@sample
*/
//--------------------------------------------------------
Static Function STBGetPDVInfo(cTipo, aDados)
Local	cRet 	:= ""  // Retorno da função
Local	nPos	:= ""  // Posição do Campo

Default	cTipo 	:= ""
Default	aDados	:= {}
	
If (nPos := aScan(aDados, { |x| x[1] == cTipo}) ) > 0
	cRet := aDados[nPos][02]
EndIf

Return cRet

//--------------------------------------------------------
/*{Protheus.doc}STDBusDEst
Busca as informações do ECF	
@param1		cECFInfo - String com informações do ECF
@param2		cTipoEcfE - Tipo do ECF
@param3		cModeloE - Modelo do ECF
@param4		cVerSBE - Versão do SB do ECF
@param5		cDtInsSBE - Tipo do SB do ECF
@param6		cHrInsSBE - Hora do SB do ECF
@param7		cIEE - IEE do ECF
@param8		cCGCE - CGC do ECF
@param9		cMarcaEcf - Marca do ECF
@param10	cSerEcf - Serie do ECF
@param11	cPdvEcf - PDV do ECF
@param12	cCodNacEcf - Codigo Nacional do ECF
@param13	cMFAdicEcf - Mf Adicional do ECF
@author  	Varejo
@version 	P11.8
@since   	15/10/2013
@obs     
@sample
*/
//--------------------------------------------------------
Function STDBusDEst(	cECFInfo, cTipoEcfE, cModeloE, cVerSBE,; 
						cDtInsSBE, cHrInsSBE, cIEE, cCGCE ,;
						cMarcaEcf, cSerEcf	, cPdvEcf , cCodNacEcf,;
						cMFAdicEcf)
						
Local	nPoS 		:= ""		// Posição do Campo
Local	cTmp 		:= ""		// Variável temporária				
Local	aECFInfo	:= {}		// Informações ECF
Local	nY 			:= ""		// Variavel contadora For(laço de repetição)

Default	cECFInfo	:= ""
Default	cTipoEcfE	:= ""
Default	cModeloE	:= ""
Default	cVerSBE		:= ""
Default	cDtInsSBE	:= ""
Default	cHrInsSBE	:= ""
Default	cIEE		:= ""
Default	cCGCE		:= ""
Default cMarcaEcf	:= ""
Default cSerEcf		:= ""
Default cPdvEcf		:= ""
Default cCodNacEcf	:= ""
Default cMFAdicEcf	:= ""
	
Do While !Empty(cECFInfo)
	nY := AT("#", cECFInfo)
	
	If nY > 0
		cTmp := Substr(cECFInfo, 1, nY-1)
		cECFInfo := Substr(cECFInfo, nY+1)
		nY := AT("|",cTmp)
		If nY > 0
			aAdd(aECFInfo, {Substr(cTmp, 1, nY-1),Substr(cTmp, nY+1) })
		EndIf
	Else
		cECFInfo := ""
	EndIf
EndDo	

If ( nPos := aScan(aEcfInfo, {|a| a[1] == "24"}) ) > 0
	cMFAdicEcf := aECFInfo[nPos,2]
EndIf

If ( nPos := aScan(aECFInfo, {|a| a[1] == "25"}) ) > 0
	cTipoEcfE := aECFInfo[nPos, 2]
EndIf

//Marca do ECF
If ( nPos := aScan(aECFInfo, {|a| a[1] == "26"}) ) > 0
	cMarcaEcf := aECFInfo[nPos, 2]
EndIf

// Recupera Modelo do ECF  
If ( nPos := aScan(aECFInfo, {|a| a[1] == "27"}) ) > 0
	cModeloE := aECFInfo[nPos, 2]
EndIf	

// Recupera Versão atual do Software Basico do ECF gravada na MF 
If ( nPos := aScan(aECFInfo, {|a| a[1] == "28"}) ) > 0
	cVerSBE := aECFInfo[nPos, 2]
EndIf

// Recupera Data de instalacao da versao atual do Software Basico do ECF
If ( nPos := aScan(aECFInfo, {|a| a[1] == "29"}) ) > 0
	cDtInsSBE := aECFInfo[nPos, 2]
EndIf

// Recupera Horario de instalacao da versao atual do Software Basico do ECF
If ( nPos := aScan(aECFInfo, {|a| a[1] == "30"}) ) > 0
	cHrInsSBE := aECFInfo[nPos, 2]
EndIf

//NUmero do Cadastro Nacional do ECF
If ( nPos := aScan(aECFInfo, {|a| a[1] == "40"}) ) > 0
	cCodNacEcf := aECFInfo[nPos, 2]
EndIf

If ( nPos := aScan(aECFInfo, {|a| a[1] == "PDV"}) ) > 0
	cPdvEcf := StrZero(Val(aECFInfo[nPos, 2]),3)
EndIf

If ( nPos := aScan(aECFInfo, {|a| a[1] == "SERIE"}) ) > 0
	cSerEcf := aECFInfo[nPos, 2]
EndIf	

If ( nPos := aScan(aECFInfo, {|a| a[1] == "IE"}) ) > 0
	cIEE := aECFInfo[nPos, 2]
EndIf

If ( nPos:= aScan(aECFInfo, {|a| a[1] == "CNPJ"}) ) > 0
	cCGCE := aECFInfo[nPos, 2]
EndIf

Return  

//--------------------------------------------------------
/*{Protheus.doc}STDEstDel
Verifica se existe estação excluída
@author  	Varejo
@version 	P11.8
@since   	15/10/2013
@return  	lRet  - Existe estação excluída 
@obs     
@sample
*/
//--------------------------------------------------------
Static Function STDEstDel() 
Local	lRet		:= .F.					// Retorno de Processamento 
Local	aArea		:= GetArea() 			// Armazena o Status da tabela atual
Local	aAreaSLG	:= SLG->(GetArea())		// WorkAreaSLG  
Local	cFilSLG		:= xFilial("SLG")		// Filial Cadastro de Estações       
	
SET DELETED OFF    
	SLG->(DbSeek(cFilSLG))
	Do While !lRet .AND. SLG->(!Eof() .AND. LG_FILIAL == cFilSLG) .And. Empty(AllTrim(SLG->LG_PAFMD5))
		lRet := SLG->(Deleted())
		SLG->(DbSkip())		
	EndDo
SET DELETED ON	   

RestArea(aAreaSLG)
RestArea(aArea)
Return lRet

//--------------------------------------------------------
/*{Protheus.doc}STBVndsId
Relatorio de Vendas Identificadas com CPF/CNPJ
@author  	Varejo
@version 	P11.8
@since   	03/07/2015
@return  	lRet  - Relatorio emitido com sucesso 
@obs     
@sample
*/
//--------------------------------------------------------
Function STBVndsId(dDataIni,dDataFim,cCpfCnpj,lPos)
Local aDados	:= {}
Local lRet		:= .T.
Local cWSServer	:= ""
Local cFile		:= ""
Local cConteudo	:= ""
Local cPath		:= ""
Local cPictVal	:= "@E 99999999999.99"
Local oWs		:= Nil
Local nHandle	:= -1
Local nI		:= 0	//Contador
Local lIsPafNfce:= STFGetCfg("lPAFNFCE") .Or. IIf(ExistFunc("LjPafNFCe"),LjPafNFCe(),.F.)	 //Usa PAF-NFC-e c/ Impressora Não Fiscal

Default dDataIni	:= Stod("")
Default dDataFim	:= Stod("")
Default cCpfCnpj	:= ""
Default lPos		:= .F.

If Empty(dDataIni) .Or. Empty(dDataFim)
	If lPos
		STFMessage("STBFMImpECF23", "ALERT", "Selecione o período") //"Selecione o período"
		STFShowMessage("STBFMImpECF23")
	Else
		MsgAlert("Selecione o período") 
	EndIf
	
	lRet := .F.
EndIf

If lRet
	cWSServer	:= AllTrim(IIF(lPos,STFGetStat("WSSRV"),LjGetStation("WSSRV")))
	oWS			:= WsFrtPafEcf():New()
	iIf(ExistFunc("LjWsGetAut"),LjWsGetAut(@oWS),Nil) //Monta o Header de Autenticação do Web Service
	oWs:_URL	:= "http://" + cWSServer + "/FRTPAFECF.apw"	
	STFMessage("STBFMImpECF21", "RUN", STR0004 + ' -> LstVndCpf', {||lRet := oWs:LstVndCpf(dDataIni, dDataFim,cEmpAnt,cFilAnt,cCpfCnpj,lHomolPAF)}) //"Executando consulta na retaguarda"
	STFShowMessage("STBFMImpECF21")
EndIf

If (lRet == Nil) .OR. !lRet
	If lPos	
		STFMessage("STBFMImpECF22", "STOP", STR0005 + '-> LstVndCpf ')   //"Erro na execução do WebService"
		STFShowMessage("STBFMImpECF22")
	Else
		MsgAlert(STR0005 + '-> LstVndCpf ')
	EndIf
	lRet := .F.
Else
	aDados := aClone(oWs:oWSLSTVNDCPFRESULT:oWsVndsIdent)
	oWs:RESET()
	oWs := Nil
EndIf

If lRet .And. Len(aDados) > 0
	cFile	:= STBFMGerFile( "VndId", lPOS )
	lRet	:= STBFMGerPath( @cPath )
	
	If lRet	
		nHandle := FCREATE( cPath + cFile, FC_NORMAL )
		
		If nHandle > 0			
			//Registro "Z1"
			cConteudo := "Z1"							//01 - Tipo de Registro
			cConteudo += PADL( SM0->M0_CGC, 14 )	//02 - CNPJ
			cConteudo += PADR( Upper(SM0->M0_INSC), 14 )	//03 - Incricao Estadual
			cConteudo += PADR( Upper(SM0->M0_INSCM), 14 )	//04 - Incricao Municipal		
			cConteudo += PADR( Upper(NoAcento(SM0->M0_NOMECOM)), 50 )	//05 - Razao Social
			cConteudo += CHR(13) + CHR(10)
			FWRITE( nHandle, cConteudo, LEN( cConteudo ) )
			
			//Registro "Z2"
			cConteudo := "Z2"									//01-Tipo do registro
			cConteudo += PADL(_CNPJTOT,14)						//02 - CNPJ da empresa desenvolvedora do PAF-ECF - Totvs
			cConteudo += PADR(Upper(_INSCEST),14)				//03 - Inscricao Estadual da empresa desenvolvedora do PAF-ECF
			cConteudo += PADR(Upper(_INSCMUN),14)				//04 - Inscricao Municipal da empresa desenvolvedora do PAF-ECF
			cConteudo += PADR(Upper(_RAZSOC),50)				//05 - Denominacao da empresa desenvolvedora do PAF-ECF - Razao social
			cConteudo += CHR(13) + CHR(10)
			FWRITE( nHandle, cConteudo, LEN( cConteudo ) )
			
			//Registro "Z3"
			cConteudo := "Z3"											 			 //01-Tipo do registro
			cConteudo += Iif(lIsPafNfce,"", PADR(Upper(STBVerPAFECF("NUMLAUDO")),10))//02 - Número do Laudo de Análise Funcional
			cConteudo += PADR(Upper("PROTHEUS"),50)					 				 //03 - Nome do aplicativo indicado no Laudo de Análise Técnica
			cConteudo += PADR(Upper(STBVerPAFECF("VERSAOAPLIC")),10) 				 //04 - Versão atual do aplicativo indicado no Laudo de Análise Técnica
			cConteudo += CHR(13) + CHR(10)
			FWRITE( nHandle, cConteudo, LEN( cConteudo ) )
			
			//Registro "Z4"
			//Criar função para buscar dados na retaguarda
			For nI := 1 to Len(aDados)
				cConteudo := "Z4"												//01-Tipo do registro
				cConteudo += StrZero(Val(aDados[nI]:cCpfCnpj),14)				//02 - Número do CPF/CNPJ identificado no campo previsto no item 2 do Requsito VIII
				cConteudo += PADL(StrTran(StrTran(AllTrim(Transform(aDados[nI]:nTotalVnd,cPictVal)),","),"."),14,"0") //03 - Total de vendas no mês, com duas casas decimais, ao CPF/CNPJ indicado no campo 02
				cConteudo += Iif(lIsPafNfce, PADL(StrTran(StrTran(AllTrim(Transform(aDados[nI]:nTotalVnd,cPictVal)),","),"."),14,"0"),"") //04 = Totalização das Vendas
				cConteudo += Iif(lIsPafNfce, PADL(StrTran(StrTran(AllTrim(Transform(0,cPictVal)),","),"."),14,"0"),"") //05 - Totalização das Outras Saídas
				cConteudo += PADR(Dtos(dDataIni),8) //PADR(Dtos(aDados[nI]:dDtFirstS),8)		//04 - Primeiro dia do mes do relatorio
				cConteudo += PADR(Dtos(dDataFim),8)  //PADR(Dtos(aDados[nI]:dDtLastS),8)		//05 - Ultimo dia do mes do relatorio
				
				//caso precise validar alteração -> aDados[nI]:lPafMD5OK
				cConteudo += PADR(DtoS(dDatabase),8)			//06 - Data da Geração do Relatorio
				cConteudo += PadR( StrTran(Time(),":",""), 6 )	//07 - Hora da Geração do Relatorio
				cConteudo += CHR(13) + CHR(10)
				FWRITE( nHandle, cConteudo, LEN( cConteudo ) )
			Next nI
			
			//Registro "Z9"
			cConteudo := "Z9"									//01-Tipo do registro
			cConteudo += PADL(_CNPJTOT,14)					//02 - CNPJ da empresa desenvolvedora do PAF-ECF - Totvs
			cConteudo += PADR(Upper(_INSCEST),14)			//03 - Inscricao Estadual da empresa desenvolvedora do PAF-ECF
			cConteudo += PADR(AllTrim(StrZero(Len(aDados),6)),6)	//04 - Totalizador do Z4
			cConteudo += CHR(13) + CHR(10)
			FWRITE( nHandle, cConteudo, LEN( cConteudo ) )
			lRet := .T.
		EndIf
	EndIf
EndIf

If nHandle > 0
	FCLOSE( nHandle )
	STBFMSignPaf(cPath + cFile)
	If lIsPafNfce
		STBGeraXML(cPath + cFile , "III")
	Endif 

Else
	Alert("Não foram localizadas vendas no período selecionado")
EndIf

Return lRet

//-------------------------------------------------
/*/
{Protheus.doc}StbFunNme

Função que cria o arquivo na pasta de instalação

@Param1 cFile - nome do arquivo
@author  	Varejo
@version 	P11.8
@since   	10/11/2015
@return  	lRet  - função executada com sucesso 
@obs     
@sample
/*/
//--------------------------------------------------
Function StbFunNme(cFile)
Local	nHandle	:= -1				// Handle do Arquivo
Local	cPath	:= ""    			// Variavel contendo o caminho para os arquivos do PAF-ECF
Local	cMsg	:= ""

Default cFile	:= ""

cPath := LjxGetPath()[1]

If File(cPath + cFile)
	FErase(cPath + cFile)
EndIf

nHandle := FCREATE(cPath + cFile, 0 )

If nHandle <= 0
	cMsg := "Erro ao criar arquivo " + cFile
	LJRPLogProc(cMsg)
Else
	cFile := cPath + cFile
EndIf
		
Return nHandle
 
//------------------------------------------
/*/
{Protheus.Doc} AjstPAFECF

Ajusta valores que precisam estar preenchidos para a geração 
dos registros do PAF-ECF

@author  	Varejo
@version 	P11.8
@since   	10/11/2015
@return  	
@obs     
@sample

/*/
//--------------------------------------------
Function AjstPAFECF(lPos)

Default lPos	:= STFIsPOS()

If lAjstInfos == NIL
	aDadosEcf := {}
	STFMessage("AjstPAFECF1", "RUN", "Ajustando Informações do PDV" , { || STBDadosEcf(lPOS) } )
	STFShowMessage("AjstPAFECF1") 
	lAjstInfos := .T.
EndIf

Return lAjstInfos

//------------------------------------------------------------------------
/*/
{Protheus.doc}	SetStat
Altera os dados da estação (SLG)

@author  	Varejo
@version 	P11.8
@since   	10/11/2015
@return  	lRet  - função executada com sucesso 
/*/
//-------------------------------------------------------------------------
Function SetStat(cFilStation, cCodigo , aCampos)
Local aArea		:= {}
Local lSet		:= .T. //Retorno da função
Local nI		:= 0	

LjGrvLog("SetStat",'Inicio da função - Alteração de SLG')

DbSelectArea("SLG")
aArea := SLG->(GetArea())
SLG->(DbSetOrder(1))

LjGrvLog("SetStat",'Dados da Pesquisa (SLG): ' + cFilStation + cCodigo )
If SLG->(DbSeek( cFilStation + cCodigo))
	LjGrvLog("SetStat",'Estação encontrada na tabela SLG')	
	RecLock("SLG", .F.)		
	For nI := 1 To Len(aCampos)
		FieldPut( ColumnPos( If(! Left(aCampos[nI, 1],3) == "LG_","LG_","") + aCampos[nI, 1]), aCampos[nI, 2])
		LjGrvLog("SetStat",'Campo Alterado da tabela SLG: ' + aCampos[nI, 1])			
	Next nI
	SLG->(MsUnLock())
Else
	lSet := .F.
	LjGrvLog("SetStat",'Estação não encontrada na tabela SLG')
EndIf

If Len(aArea) > 0
	RestArea(aArea)
EndIf

LjGrvLog("SetStat",'Final da função')

Return lSet

//--------------------------------------------------------------
/*/
{Protheus.doc} Função AtuSerPDV

atualiza a série do PDV caso não esteja preenchida
@author  	Varejo
@version 	P11.8
@since   	10/11/2015
@return  	lRet  - função executada com sucesso 
/*/
//---------------------------------------------------------------
Function AtuSerPDV()
Local cAux		:= ""
Local lL1PafMd5 := .F.
Local lL2PafMd5 := .F.
Local lL4PafMd5 := .F.
Local lAtuMD5	:= .T.

DbSelectArea('SLG')
DbSelectArea('SL1')
DbSelectArea('SL2')
DbSelectArea('SL4')
SLG->(dbSetOrder(1))
SL1->(dbSetOrder(8))
SL2->(dbSetOrder(1))
SL4->(dbSetOrder(1))

lL1PafMd5 := .T.
lL2PafMd5 := .T.
lL4PafMd5 := .T.

SLG->(dbGoTop())

While !SLG->(Eof()) 
	If SL1->(DbSeek(xFilial('SLG')+SLG->LG_PDV)) .And. (AllTrim(SL1->L1_SERIE) == AllTrim(SLG->LG_SERIE)) .And.;
		!Empty(AllTrim(SLG->LG_SERPDV))
		
		cAux := AllTrim(SLG->LG_SERPDV)
		
		While !SL1->(Eof()) .And. SL1->(L1_FILIAL+L1_PDV) == xFilial('SLG')+SLG->LG_PDV .And. Empty(AllTrim(SL1->L1_SERPDV)) 	

			RecLock('SL1',.F.)
			Replace L1_SERPDV With cAux
			/*If lL1PafMd5 .And. lAtuMD5
				Replace L1_PAFMD5 with STxPafMd5("SL1")
			EndIf*/
			SL1->(MsUnlock())
			
			If SL2->(DbSeek(SL1->L1_FILIAL+SL1->L1_NUM))
				While !SL2->(Eof()) .And. (SL2->L2_FILIAL+SL2->L2_NUM) == (SL1->L1_FILIAL+SL1->L1_NUM) .And. Empty(AllTrim(SL2->L2_SERPDV))
					RecLock('SL2',.F.)
					Replace L2_SERPDV With cAux
					/*If lL2PafMd5 .And. lAtuMD5
						Replace L2_PAFMD5 with STxPafMd5("SL2")
					EndIf*/
					SL2->(MsUnlock())
							
					SL2->(DbSkip())
				End
			EndIf
			
			If SL4->(DbSeek(SL1->L1_FILIAL+SL1->L1_NUM))
				While !SL4->(Eof()) .And. (SL4->(L4_FILIAL+L4_NUM)) == (SL1->(L1_FILIAL+L1_NUM)) .And. Empty(AllTrim(SL4->L4_SERPDV))
					RecLock('SL4',.F.)
					Replace L4_SERPDV With cAux
					/*If lL4PafMd5 .And. lAtuMD5
						Replace L4_PAFMD5 with STxPafMd5("SL4")
					EndIf*/
					SL4->(MsUnlock())
							
					SL4->(DbSkip())
				End
			EndIf
			
			SL1->(DbSkip())
		End
	EndIf
	SLG->(DbSkip())
End

Return 

//-----------------------------------------------------
/*/
{protheus.doc}StbVldE2Paf

Valida qual ECF emitiu a Redução Z 
@author  	Varejo
@version 	P11.8
@since   	10/11/2015
@return  	lRet  - função executada com sucesso 
@obs     
@sample

/*/
//------------------------------------------------------
Function StbVldE2Paf(lTotvsPDV,lConsulta,cFilSLG,dData)
Local lEmiteE2	:= .F.
Local lAchou	:= .F.
Local lExistSale:= .F.
Local nTry		:= 0
Local aRet		:= {}
Local cRet		:= ""
Local cSeriePDV := ""
Local cSerieRet := ""
Local dDtPesq	:= CtoD( '' )

If lConsulta

	dDtPesq := dData
	nTry	:= 1
	
	DbSelectArea("MDZ")
	MDZ->(DbSetOrder(1))
	
	//Pesquisa até encontrar um registro dentro de 20 dias para tras 
	While !lAchou .And. nTry <= 20
		
		lExistSale := MDZ->(DbSeek(cFilSLG + DtoS(dDtPesq)))
		
		If lExistSale
			While MDZ->(!Eof()) .And. !lAchou
				If MDZ->MDZ_SIMBOL == "RP"
					cRet	:= AllTrim(MDZ->MDZ_SERPDV) //Retorna a série do PDV que emitiu a primeira RedZ 
					lAchou	:= .T.
					Exit
				EndIf
				MDZ->(DbSkip())
			End
		Else
			dDtPesq -= 1
			nTry++
		EndIf
	End
	
	Aadd(aRet, {lAchou , cRet } )
Else
	If lTotvsPDV
		lRet := STBRemoteExecute("StbVldE2Paf", {lTotvsPDV,.T.,xFilial('SLG'),dDatabase}, NIL, .F.,@aRet)
		cSeriePDV := STFGetStation("SERPDV")
	Else
		aRet := FR271CMyCall("StbVldE2Paf",{"SLG","MDZ"},lTotvsPDV,.T.,xFilial('SLG'),dDataBase)		
		cSeriePDV := LjGetStation("SERPDV")
	EndIf
	
	If ValType(aRet) == "A" .And. Len(aRet) > 0 .And. ValType(aRet[1]) == "A"
		cSerieRet := aRet[1][2]
	Else
		lRet := .F.
	EndIf
	Conout('StbVldE2Paf -> Serie Ret:' + cSerieRet +' - Serie PDV: ' + cSeriePDV)
	lEmiteE2:=  (AllTrim(cSerieRet) == AllTrim(cSeriePDV))		
	aRet	:= {}
	Aadd( aRet , lEmiteE2 )
EndIf

Return  aRet

//--------------------------------------------------------
/*/
{Protheus.doc}StbVldE3Paf
Função para validar a alteração do E3 

@author  	Varejo
@version 	P11.8
@since   	10/11/2015
@return  	lRet  - função executada com sucesso 
@obs     
@sample
/*/
//--------------------------------------------------------
Function StbVldE3Paf(	lTotvsPDV, lPesquisa,cFilSL1, dData,; 
						cSeriePDV,cMFAdic,cTipoEcf,cMarcaEcf,;
						cModelEcf, cDtEmissao, cHrEmissao,cMd5Pdv)
Local nTry			:= 0
Local cAux			:= ""
Local cMD5			:= ""
Local cLGPafMd5		:= ""
Local lRet 			:= .T.
Local lExistSale	:= .F.
Local aRet			:= {}
Local dDtPesq		:= CtoD( '' )
//Variaveis da RET
Local cRetTipoEcfE	:= ""
Local cRetModeloE	:= ""
Local cRetVerSBE	:= ""
Local cRetDtInsSBE	:= ""
Local cRetHrInsSBE	:= ""
Local cRetIEE		:= ""
Local cRetCGCE		:= ""
Local cRetMarcaEcf	:= ""
Local cRetSerEcf	:= ""
Local cRetPdvEcf 	:= ""
Local cRetCodNacEcf	:= ""
Local cRetMFAdicEcf	:= ""
Local lDelManual	:= .F.
Local lIncManual	:= .F.

Default lTotvsPDV	:= .F.
Default lPesquisa	:= .F.
Default cFilSL1		:= xFilial('SL1')
Default cSeriePDV	:= ""
Default	cMFAdic		:= ""
Default cTipoEcf	:= ""
Default cMarcaEcf	:= ""
Default cModelEcf	:= ""
Default cDtEmissao	:= "" 
Default cHrEmissao	:= ""

/* Para fazer as validações caso haja alteração do banco altere os dados
do campo LG_ECFINFO */
If lPesquisa
	SET DELETED OFF
	
	DbSelectArea('SL1')
	DbSelectArea('SF2')
	DbSelectArea('SLG')
	SL1->(DbSetOrder(4)) //Filial + Data Emissao
	SF2->(DbSetOrder(1))
	dDtPesq := dData
	nTry	:= 0
	
	//Pesquisa até encontrar uma venda
	While !lExistSale .And. nTry <= 90 //Permite voltar 90 dias
		lExistSale := SL1->(DbSeek(cFilSL1 + Dtos(dDtPesq)))
		
		If !lExistSale
			dDtPesq -= 1
			nTry++
		EndIf
	End
	
	If lExistSale
		cAux	:= AllTrim(LjPesqPdv( SL1->L1_PDV , SL1->L1_SERIE , "LG_ECFINFO"))
		cMD5	:= AllTrim(MD5( cAux + Upper(LjPesqPdv( SL1->L1_PDV , SL1->L1_SERIE , "LG_IMPFISC")) ,2))
		cLGPafMd5 := AllTrim(LjPesqPdv( SL1->L1_PDV , SL1->L1_SERIE , "LG_PAFMD5"))
		
		/*Para validar a alteração da data pego um campo diferente de L1_EMISSAO, pois
		o registro será encontrado mas não será validado devido a diferença de data*/
		//as Duas ultimas posições tratam Exclusão Manual / Inclusão Manual
		//Exclusão - deixar como deletado o primeiro movimento
		//Inclusão - incluir um registro de primeiro movimento e deixar o MD5 em branco
		If !SL1->(Deleted())
			If (AllTrim(SL1->L1_ESPECIE) == "NFCF" .Or. AllTrim(SL1->L1_ESPECIE) == "NFM") //Quando só tenho nota emitida, ele deve validar o E2/E3
				Aadd(aRet,{"", Dtos(SL1->L1_EMISSAO) , Dtos(SL1->L1_DTLIM) ,;
								 StrTran(SL1->L1_HORA,":") , StrTran(SL1->L1_HORA,":"), "" , "",.F., Empty(SL1->L1_PAFMD5)})
			Else
				If SF2->(DbSeek(cFilSL1+SL1->L1_DOC+SL1->L1_SERIE))		
					Aadd(aRet, {AllTrim(cAux), Dtos(SL1->L1_EMISSAO) , Dtos(SL1->L1_DTLIM) ,;
								StrTran(SL1->L1_HORA,":") , StrTran(SF2->F2_HORA,":") , cMD5, cLGPafMd5, .F., Empty(SL1->L1_PAFMD5)})
				ElseIf !Empty(SL1->L1_DOC)
					Aadd(aRet, {AllTrim(cAux), Dtos(SL1->L1_EMISSAO) , Dtos(SL1->L1_DTLIM) ,;
							 	StrTran(SL1->L1_HORA,":") , StrTran(Time(),":"), cMD5 , cLGPafMd5, .F., Empty(SL1->L1_PAFMD5)})
				Else//Caso não haja venda , não pode retornar que não foi validado (senão serão colocadas interrogações no Registro do PAF) 
					Aadd(aRet,{"", Dtos(dDtPesq) , Dtos(dDtPesq) , StrTran(Time(),":") , StrTran(Time(),":"), "" , "",.F.,.F.})
				EndIf
			EndIf
		Else
			Aadd(aRet,{"", Dtos(dDtPesq) , Dtos(dDtPesq) , StrTran(Time(),":") , StrTran(Time(),":"), "" , "",.T.,.T.})
		EndIf
	Else
		aRet := {}
	EndIf
	
	SET DELETED ON
Else
	//Faz Conexao RPC e retorna a pesquisa da primeira venda do dia
	If lTotvsPDV
		STBRemoteExecute("StbVldE3Paf", {.T.,.T.,xFilial('SLG'),dData}, NIL, .F.,@aRet)
	Else
		aRet := FR271CMyCall("StbVldE3Paf",{"SLG","SL1","SF2"},.F.,.T., xFilial('SLG'),dData)
	EndIf
	
	If ValType(aRet) == "A" .And. Len(aRet) > 0 .And. ValType(aRet[1]) == "A"
		If (aRet[1][6] <> aRet[1][7]) .Or. (aRet[1][2] <> aRet[1][3]) .Or. (AllTrim(aRet[1][4]) <> SubStr(AllTrim(aRet[1][5]),1,4))
			lRet := .F.
			
			STDBusDEst(	aRet[1][1]	, @cRetTipoEcfE, @cRetModeloE, @cRetVerSBE,; 
						@cRetDtInsSBE, @cRetHrInsSBE, @cRetIEE, @cRetCGCE ,;
						@cRetMarcaEcf, @cRetSerEcf  , @cRetPdvEcf , @cRetCodNacEcf,;
						@cRetMFAdicEcf)
					
			cSeriePDV	:= cRetSerEcf			
			cMFAdic		:= cRetMFAdicEcf
			cTipoEcf	:= cRetTipoEcfE
			cMarcaEcf	:= cRetMarcaEcf
			cModelEcf	:= cRetModeloE
			cDtEmissao	:= aRet[1][2]
			cHrEmissao	:= aRet[1][4]
		Else
			lRet := .T.
		EndIf
		
		lDelManual := aRet[1][8]
		lIncManual := aRet[1][9]
	Else
		//Se retornar array vazio está OK também
		lRet := .T.
	EndIf
	
	aRet := {}
	Aadd(aRet,{lRet,lDelManual,lIncManual})
EndIf

Return aRet

//--------------------------------------------------------
/*{Protheus.doc}StbVldTab
Função para validação das tabelas do registro do PAF

@author  	Varejo
@version 	P11.8
@since   	16/11/2015
@return  	lRet  - função executada com sucesso 
@obs     
@sample
*/
//--------------------------------------------------------
Function StbVldTab()
Local lRet	:= .F.
Local nX	:= 0
Local aRet	:= {}
Local cMsg	:= ""

Conout('LstTabPaf -> Consultando Tabelas...')
LjGrvLog(Nil,"LstTabPaf -> Consultando Tabelas...")

If lTotvsPDV
	STFMessage("StbVldTab1", "RUN", "Consultando dados....", { || STBRemoteExecute("LstTabPaf",Nil,Nil,.F.,@aRet) })
	STFShowMessage("StbVldTab1")
Else
	LJMsgRun("Consultando dados....",,{||aRet := FR271CMyCall("LstTabPaf",Nil) })
EndIf

If ValType(aRet) == "A" .And. Len(aRet) > 0 .And. ValType(aRet[1]) == "A"
	lRet := .T.
EndIf

If lRet
	For nX := 1 to Len(aRet)
		If !aRet[nX][1]
			cMsg += aRet[nX][2] + ','
		EndIf
	Next nX
	
	If !Empty(cMsg)
		cMsg := Substr(cMsg,1,Len(cMsg)-1)
		cMsg := "Tabelas não encontradas -> " + cMsg + ". Não será possível gerar arquivo" +CHR(10)+Chr(13)
		cMsg += " Aplique o UPDDISTR relativo ao Pacote de Liberação do PAF-ECF POL0852017R1" 
		
		If lTotvsPDV
			STFMessage("StbVldTab2", "ALERT", cMsg)
			STFShowMessage("StbVldTab2")
		Else
			MsgInfo(cMsg,"PAF-ECF")
		EndIf
		
		LjGrvLog("StbVldTab",cMsg)
	EndIf
EndIf

lRet := Empty(AllTrim(cMsg))

Return lRet

//--------------------------------------------------------
/*/{Protheus.doc}StbVldArq
Função para validação dos dados do registro do PAF

@author  	Varejo
@version 	P11.8
@since   	10/11/2015
@return  	lRet  - função executada com sucesso 
/*/
//--------------------------------------------------------
Function StbVldArq(dDataIni, dDataFim)
Local aRet	:= {}
Local aMsg	:= {} 
Local nX	:= 0
Local cMsg	:= ""
Local lRet	:= .T.

Conout('StbVldArq -> Consultando dados...')

If lTotvsPDV
	STFMessage("StbVldArq1", "RUN", "Consultando dados....", { || STBRemoteExecute(	"LstSumReg"	,{dDataIni, dDataFim},Nil,.F.,@aRet) } )
	STFShowMessage("StbVldArq1")
Else
	LJMsgRun("Consultando dados....",,{||aRet := FR271CMyCall( "LstSumReg",{"SL1","SL2","SL4","SLX","MDZ","SFI"},dDataIni, dDataFim) })
EndIf

If ValType(aRet) == "A" .And. Len(aRet) > 0 .And. ValType(aRet[1]) == "A"
	aMsg := aRet
	lRet := .T.
Else
	lRet := .F.
EndIf

If lRet
	For nX := 1 to Len(aMsg)
		cMsg += "ECF Série " + aMsg[nX][4] + ' PDV ' + aMsg[nX][3] + aMsg[nX][2] + " no dia " + Dtoc(aMsg[nX][1]) + CHR(10) + CHR(13)	
	Next nX
	
	cMsg += CHR(10) + CHR(13)
	cMsg += "**********************************"
	cMsg += "			SOLUÇÃO 			   "	
	cMsg += "**********************************"
	cMsg += CHR(10) + CHR(13)
	cMsg += 'Verifique :' + CHR(10) + CHR(13) +;
			'- Cancelamentos que não foram para o PDV (Tabela SLI)'+ CHR(10) + CHR(13) +;
			'- Vendas que não foram para o PDV (Tabela SL1)' + CHR(10) + CHR(13) +;
			"- Se os Jobs de Subida de Venda estão ativos" + CHR(10) + CHR(13) +;
			"- Se houve troca de ECF em um mesmo PDV: Caixa com movimento anterior, ECF foi trocado e a Redução Z efetuada"
			
	STPosMSG( "Inconsistência nos Dados dos Registros do PAF" , cMsg, .T., .F., .F.)
	
	LjGrvLog("StbVldArq",cMsg)	
EndIf

lRet := Empty(AllTrim(cMsg))

Return lRet

//--------------------------------------------------------
/*/{Protheus.doc}StbReqXIIZ
Arquivos do Requisito XII no momento da Redução Z

@author  	Varejo
@version 	P12
@since   	05/05/2017
@return  	lRet  - função executada com sucesso 
/*/
//--------------------------------------------------------
Function StbReqXIIZ(lTotvsPDV,cDtIni,cDtFinal)
Local lRet		:= .T.
Local cPathArq	:= ""
Local cPathMFD	:= PAF_ARQMFD + "\"
Local cSerieIF	:= AllTrim(IIF(lTotvsPDV, STFGetStat("SERPDV") , LjGetStation("SERPDV")))
Local aArqsDir	:= {}
Local nX		:= 0
Local nY		:= 0

Default lTotvsPDV := .F.

STBFMGerPath( @cPathArq )

//Lista os arquivos .XXX do diretorio
Aadd(aArqsDir , Directory(cPathArq + "*.BIN"))
Aadd(aArqsDir , Directory(cPathArq + "*.TXT"))
If Len(aArqsDir[1]) > 0
	For nX:= 1 To Len(aArqsDir)
		For nY := 1 to Len(aArqsDir[nX])
			If cSerieIF $ Upper(aArqsDir[nX][nY][F_NAME]) //Pega o arquivo que possui a serie, arquivo criado pelo ECF nao possui o mesmo nome.
				FErase(cPathArq + aArqsDir[nX][nY][F_NAME])
			EndIf
		Next nY
	Next nX
EndIf

aArqsDir := {}
Aadd(aArqsDir , Directory(cPathArq + cPathMFD + "*.BIN"))
Aadd(aArqsDir , Directory(cPathArq + cPathMFD + "*.TXT"))
If Len(aArqsDir[1]) > 0
	For nX:= 1 To Len(aArqsDir)
		For nY := 1 to Len(aArqsDir[nX])
			If cSerieIF $ Upper(aArqsDir[nX][nY][F_NAME]) //Pega o arquivo que possui a serie, arquivo criado pelo ECF nao possui o mesmo nome.
				FErase(cPathArq + cPathMFD + aArqsDir[nX][nY][F_NAME])
			EndIf
		Next nY
	Next nX
EndIf

/*  Os arquivos eletrônicos a que se refere os itens 2 e 3 devem ser gravados no mesmo 
	subdiretório onde está instalado o PAF-ECF com nome “xxxxxx_aaaammdd_hhmmss.MMM”
	onde:
	“xxxxxx” representa o número de fabricação do ECF
	“aaaammdd” representa a data de geração do arquivo
	“hhmmss” representa o horário de geração do arquivo 
	MMM, representa o tipo de arquivo, devendo o PAF-ECF assiná-los digitalmente criando
	um arquivo TXT com mesmo nome contendo uma linha com o registro tipo EAD
	especificado no requisito XXXI */
STWFMLMFD( lTotvsPDV , { .F. , "1" , cDtIni , cDtFinal } )
STWFMMirrorMFD( "", lTotvsPDV , .F., {cDtIni,cDtFinal})

Return lRet

//--------------------------------------------------------
/*/{Protheus.doc}STBS2RPAF
Envia arquivos para retaguarda, conforme exigido no Ato

@author  	Varejo
@version 	P12
@since   	13/06/2017
@return  	lRet  - função executada com sucesso 
/*/
//--------------------------------------------------------
Function STBS2RPAF(cConteudo,cNome)
Local nHandle:= 0
Local aRet	 := {}
Local lMsgErro:= .F.

LjGrvLog("STBS2RPAF","Inicio da Função")
LjGrvLog("STBS2RPAF","Geração do arquivo")

nHandle := StbFunNme(@cNome)
		
If nHandle > 0
	If ! Empty(AllTrim(cConteudo))
		FWRITE( nHandle, cConteudo, LEN( cConteudo ) )
		FCLOSE( nHandle )
		Aadd(aRet ,{ .T. })
		LjGrvLog("STBS2RPAF","Finalização da gravação do arquivo" , aRet)
	Else
		lMsgErro := .T.			
	EndIf
Else
	lMsgErro := .T.
EndIf

If lMsgErro
	LjGrvLog("STBS2RPAF","Arquivo não gerado")
	Conout("Função STBS2RPAF - Arquivo não gerado")
	Aadd(aRet ,{ .F. })
EndIf

Return aRet

//-------------------------------------------------------------------
/*/{Protheus.doc} STBArqPend
Verifica a qtde de arquivos pendentes do PAF
@author  Varejo
@version P11-P12
@since   06/06/2017
@return  lRet
/*/
//-------------------------------------------------------------------
Function STBArqPend(cTpEnvio)
Local lRet		:= .T.
Local lSTBPEnvXML:= .F.
Local lMvLjPdvPa:= .F.
Local aRet		:= {}
Local nContRZ	:= 0
Local nContES	:= 0
Local nX		:= 0

Default cTpEnvio := ""

If cPaisLoc == "BRA"
	
	lMvLjPdvPa:= LjxBGetPaf()[2]
	DbSelectArea("MDZ")
	DbSelectArea("SFI")
	lSTBPEnvXML := STBPEnvXML()
	
	If ( (lTotvsPdv .And. STbIsPaf()) .Or.;
	 	lMvLjPdvPa .Or.;
	 	LjNfPafEcf(SM0->M0_CGC) ) .And.;
		lSTBPEnvXML .And. STBPafCSef("C")
	
		If Empty(cTpEnvio) .Or. (cTpEnvio == "E")
			aRet := STEstqXML(lMvLjPdvPa,"Q")
			
			If ValType(aRet) == "A" .And. Len(aRet) > 0
				//Foi alterado o retorno tipo "Q", portanto verifico o que vem da retaguarda
				If ValType(aRet[1]) == "A"
					For nX := 1 to Len(aRet)
						nContES += aRet[nX,1]
					Next nX
				Else
					If ValType(aRet[1]) == "N"					
						nContES := aRet[1]
					Else
						nContES := 0
						LjGrvLog( NIL, "Atualize o fonte STFISCALMENU na retaguarda ou configure a comunicação entre os ambientes")
					EndIf
				EndIf
			EndIf
		EndIf
		
		If Empty(cTpEnvio) .Or. (cTpEnvio == "R")
			aRet := STRedXML("Q")
			nContRZ := Len(aRet)	
		EndIf
		
		If nContRZ > 0
			If nContRZ <= 9
				lRet := .T.	
			Else
				lRet := .F.	 
			EndIf
			
			//ER PAF-ECF 02.05 - Para esses estados, não bloqueia a Redução Z
			If !lRet .And. AllTrim(SM0->M0_ESTCOB) $ "TO|DF"
				lRet := .T.
			EndIf
		EndIf
		
		If lRet .And. (nContES > 0)
			If nContES <= 4
				lRet := .T.
			Else		
				lRet := .F.
			EndIf
		EndIf
		
		/*Devido aos problemas nos clientes por causa da
		falta de envio e ajustes que precisam ser feito,
		foi solicitado a abertura de acesso ao módulo - criado uma chave 
		para que seja permitido - SOMENTE PARA A TOTVS EM TESTES INTERNOS*/
		If	AllTrim(GetPvProfString("paf-ecf", "pendentes", "", GetClientDir() + "sigaloja.ini")) == "0" .And.;
			!lRet .And. !lHomolPaf
			
			LjGrvLog( NIL, "Existe arquivos pendentes do Bloco X e acesso ao PDV permitido")
			lRet := .T.
		EndIf
	EndIf
EndIf

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} STRedXML

Informações do XML da Redução Z
@author  Varejo
@version P11-P12
@since   10/08/2017
@return  lRet
/*/
//-------------------------------------------------------------------
Function STRedXML(cPesq,cKey,aConteudo,dData)
Local aRet		:= {}
Local aArea		:= {}
Local nX		:= 0
Local nRecSFI	:= 0
Local cFilSFI	:= ""
Local cDtIniBlX := STDtIniBlX("R")

Default cPesq		:= ""
Default cKey		:= ""
Default aConteudo	:= {}
Default dData		:= CtoD( '' )

//Q - quantidade de XML's pendentes
//E - grava o xml de envio na retaguarda
//X - retorna o campo desejado da tabela
//R - Grava o XML de retorno na retaguarda
//V - Validar Processamento na SEFAZ
//AE - arquivos XML com Erros no envio
//S - arquivos XML com Sucesso no envio
//N - arquivos XML com Não Enviado

DbSelectArea("SFI")
Aadd(aArea,SFI->(GetArea()))
SFI->(DbSetOrder(1)) //FI_FILIAL + FI_DTMOVTO + FI_PDV + FI_NUMREDZ
cFilSFI := xFilial("SFI")

Do Case
	Case cPesq == "Q"
		SFI->(DbSetOrder(4)) //FI_FILIAL, FI_XMLENV
		If SFI->(DbSeek(xFilial("SFI") + "N"))
			While !SFI->(Eof()) .And. SFI->FI_FILIAL+AllTrim(SFI->FI_XMLENV) == cFilSFI+"N"
				If SFI->FI_DTMOVTO >= StoD(cDtIniBlX)
					Aadd(aRet,{1, SFI->FI_DTMOVTO})
				EndIf
				SFI->(DbSkip())
			End
		EndIf
	
	Case cPesq == "E"
		If SFI->(DbSeek(cKey))
			nRecSFI := SFI->(Recno())
			RecLock("SFI",.F.)
			REPLACE SFI->FI_XMLENV WITH aConteudo[1]
			REPLACE SFI->FI_XMLEPAF WITH aConteudo[2] //XML de Envio, caso envio OK	
			SFI->(MsUnlock())
		EndIf
		
		Aadd(aRet,.T.)
		
	Case cPesq == "X"
		If SFI->(DbSeek(cKey))
			//Pode retornar qualquer campo - na teoria somente os campos de XML
			//aConteudo[1]: manda o nome do campo FI_XMLXXXX			
			Aadd(aRet,AllTrim(SFI->&(aConteudo[1])))
		EndIf
	
	Case cPesq == "R"
	
		If SFI->(DbSeek(cKey))
			nRecSFI := SFI->(Recno())
			RecLock("SFI",.F.)
			If !Empty(AllTrim(aConteudo[1]))
				REPLACE SFI->FI_XMLENV WITH aConteudo[1]
			EndIf
			
			If !Empty(AllTrim(aConteudo[2]))
				REPLACE SFI->FI_XMLRPAF WITH aConteudo[2] //XML de Retorno, caso envio OK
			EndIf
			SFI->(MsUnlock())
		EndIf
		
		Aadd(aRet,.T.)
		
	Case cPesq == "V"
		// Verifica se existe o campo SFI->FI_XMLENV 
		SFI->(DbSetOrder(4)) //FI_FILIAL, FI_XMLENV

		If SFI->(DbSeek(xFilial("SFI") + "A"))
			While !SFI->(Eof()) .And. SFI->FI_FILIAL+AllTrim(SFI->FI_XMLENV) == cFilSFI+"A"
				If SFI->FI_DTMOVTO >= StoD(cDtIniBlX) 
					//Envia o indice 1 : FI_FILIAL + FI_DTMOVTO + FI_PDV + FI_NUMREDZ
					Aadd(aRet,{1,AllTrim(SFI->FI_XMLEPAF),AllTrim(SFI->FI_XMLRPAF),;
							SFI->(Recno()),SFI->(FI_FILIAL + DTOS(FI_DTMOVTO) + FI_PDV + FI_NUMREDZ)})
				EndIf
				
				SFI->(DbSkip())
			End
		EndIf

		If SFI->(DbSeek(xFilial("SFI") + "S"))
			While !SFI->(Eof()) .And. SFI->FI_FILIAL+AllTrim(SFI->FI_XMLENV) == cFilSFI+"S"
				If SFI->FI_DTMOVTO >= StoD(cDtIniBlX) .AND. (Upper("Aguardando") $ Upper(SFI->FI_XMLRPAF)) 
					//Envia o indice 1 : FI_FILIAL + FI_DTMOVTO + FI_PDV + FI_NUMREDZ
					Aadd(aRet,{1,AllTrim(SFI->FI_XMLEPAF),AllTrim(SFI->FI_XMLRPAF),;
							SFI->(Recno()),SFI->(FI_FILIAL + DTOS(FI_DTMOVTO) + FI_PDV + FI_NUMREDZ)})
				EndIf
				
				SFI->(DbSkip())
			End
		EndIf

		If SFI->(DbSeek(xFilial("SFI") + "E"))
			While !SFI->(Eof()) .And. SFI->FI_FILIAL+AllTrim(SFI->FI_XMLENV) == cFilSFI+"E"
				If SFI->FI_DTMOVTO >= StoD(cDtIniBlX) .AND. (Upper("Aguardando") $ Upper(SFI->FI_XMLRPAF)) 
					//Envia o indice 1 : FI_FILIAL + FI_DTMOVTO + FI_PDV + FI_NUMREDZ
					Aadd(aRet,{1,AllTrim(SFI->FI_XMLEPAF),AllTrim(SFI->FI_XMLRPAF),;
							SFI->(Recno()),SFI->(FI_FILIAL + DTOS(FI_DTMOVTO) + FI_PDV + FI_NUMREDZ)})
				EndIf
				
				SFI->(DbSkip())
			End
		EndIf
		
		If Len(aRet) == 0
			Aadd(aRet,{0,"","",0,""})
		EndIf
	
	Case cPesq == "AE"
		 
		SFI->(DbSetOrder(4)) //FI_FILIAL + FI_XMLENV
		If SFI->(DbSeek(cFilSFI + "E"))
			While !SFI->(Eof()) .And. SFI->FI_FILIAL+AllTrim(SFI->FI_XMLENV) == cFilSFI+"E" 
				 If SFI->FI_DTMOVTO >= StoD(cDtIniBlX) 
					//Envia o indice 1 : FI_FILIAL + FI_DTMOVTO + FI_PDV + FI_NUMREDZ
					Aadd(aRet,{1,;
							AllTrim(SFI->FI_XMLEPAF),;
							AllTrim(SFI->FI_XMLRPAF),;
							SFI->(Recno()),;
							SFI->(FI_FILIAL + DTOS(FI_DTMOVTO) + FI_PDV + FI_NUMREDZ),;
							SFI->FI_DTMOVTO})
				EndIf
				
				SFI->(DbSkip())
			End
		EndIf
		
		If Len(aRet) == 0
			Aadd(aRet,{0,"","",0,""})
		EndIf
		
	Case cPesq == "S"
		
		SFI->(DbSetOrder(4)) //FI_FILIAL + FI_XMLENV
		If SFI->(DbSeek(cFilSFI + "S"))
			While !SFI->(Eof()) .And. SFI->FI_FILIAL == cFilSFI
			 	If  AllTrim(SFI->FI_XMLENV) == "S"
					//Envia o indice 1 : FI_FILIAL + FI_DTMOVTO + FI_PDV + FI_NUMREDZ
					Aadd(aRet,{1,AllTrim(SFI->FI_XMLEPAF),AllTrim(SFI->FI_XMLRPAF),;
								SFI->(Recno()),SFI->(FI_FILIAL + DTOS(FI_DTMOVTO) + FI_PDV + FI_NUMREDZ)})
				EndIf
				
				SFI->(DbSkip())
			End
		EndIf
		
		If Len(aRet) == 0
			Aadd(aRet,{0,"","",0,""})
		EndIf
	
	Case cPesq == "N"
		SFI->(DbSetOrder(4)) //FI_FILIAL, FI_XMLENV
		If SFI->(DbSeek(cFilSFI + "N"))
			While !SFI->(Eof()) .And. SFI->FI_FILIAL == cFilSFI
			 	If AllTrim(SFI->FI_XMLENV) == "N"
					//Envia o indice 1 : FI_FILIAL + FI_DTMOVTO + FI_PDV + FI_NUMREDZ
					Aadd(aRet,{1,AllTrim(SFI->FI_XMLEPAF),AllTrim(SFI->FI_XMLRPAF),;
								SFI->(Recno()),SFI->(FI_FILIAL + DTOS(FI_DTMOVTO) + FI_PDV + FI_NUMREDZ)})
				EndIf
				
				SFI->(DbSkip())
			End
		EndIf
	
		If Len(aRet) == 0
			Aadd(aRet,{0,"","",0,""})
		EndIf
EndCase

If (cPesq $ "E|R")
	STFUpFIXML(,,nRecSFI)
EndIf

For nX := 1 to Len(aArea)
	RestArea(aArea[nX])
next nX

Return aRet

//-------------------------------------------------------------------
/*/{Protheus.doc} STEstqXML

Informações do XML de Estoque
@author  Varejo
@version P11-P12
@since   10/08/2017
@return  lRet
/*/
//-------------------------------------------------------------------
Function STEstqXML(	lIsPDV	, cPesq	, cKey		, aConteudo	,;
					dData	, lHomol, cNumCreden,cFILMDZ,cDtIniBlcX)
Local aRet		:= {}
Local aArea		:= {}
Local aAux		:= {}
Local cMDZNum	:= ""
Local nContES	:= 0
Local nX		:= 0
Local lGrvMDZ	:= .T.
Local lTemMDZ	:= .F.

Default lIsPDV	:= .T.
Default cPesq	:= ""
Default cKey	:= ""
Default aConteudo:= Array(2)
Default dData	:= CtoD('')
Default cNumCreden:= ""
Default cFILMDZ := FwxFilial("MDZ")
Default cDtIniBlcX:= Stod("20201001")

If lIsPDV
	If STBPafCom(lIsPDV, .F.)
		cNumCreden := AllTrim(SubStr(SuperGetMV("MV_LJCRPAF",,""),1,15))

		If lTotvsPdv
			STFMessage(	"STEstqXML1", "RUN", "Busca das Informações de Estoque",;
						{ || STBRemoteExecute("STEstqXML",;
							{	.F.		,	cPesq		,	@cKey		,aConteudo,;
								dData	,	lHomolPaf	,	cNumCreden	,FwxFilial("MDZ"),STDtIniBlX()},;
						Nil,.F.,@aRet) } )
			STFShowMessage("STEstqXML1")
		Else
			LjMsgRun("Busca das Informações de Estoque",,{ || ;
					aRet := FR271CMyCall("STEstqXML",NIL,;
							.F.		,	cPesq	,	@cKey	,	aConteudo	,;
							dData	,	lHomolPaf,cNumCreden,	FwxFilial("MDZ"),STDtIniBlX())})
		EndIf
	EndIf

	If ValType(aRet) == "A" .And. Len(aRet) > 0
		If ValType(aRet[1]) == "C" .And. (aRet[1] == "ERRO")
			aRet := {}
		EndIf
	Else
		aRet := {}
	EndIf
	
	LjGrvLog( NIL, "Retorno da consulta na função STEstqXML", aRet)
Else

	LjGrvLog( NIL, "MDZ->MDZ_XMLENV = " + cPesq, ,.T.)
	
	If !ValType(cDtIniBlcX)=="D" .AND. Len(cDtIniBlcX)==8 .AND. !Empty(cDtIniBlcX) .AND. !cDtIniBlcX $ "/"
		cDtIniBlcX= StoD(cDtIniBlcX)
	EndIf 

	If ValType(lHomol) == "L"
		lHomolPaf := lHomol
	EndIf

	//Q - quantidade de XML's pendentes
	//E - grava o xml de envio na retaguarda
	//X - retorna o campo desejado da tabela
	//R - Grava o XML de retorno na retaguarda
	//T - Todos os arquivos pendentes
	//V - Valida Processamento na SEFAZ
	//AE - arquivos (XML) com erros
	//S - arquivos XML com Sucesso no envio
	//N - arquivos XML com Não Enviado
	
	DbSelectArea("MDZ")
	Aadd(aArea,MDZ->(GetArea()))
	MDZ->(DbSetOrder(1)) //MDZ_FILIAL + MDZ_DATA

	If Empty(cKey)
		cKey := cFILMDZ + DtoS(dData)
	EndIf

	//Existem situações em que o campo não é gravado 
	//por estar em branco, por isso insiro um espaço em branco
	If Len(aConteudo) > 0
		If Empty(AllTrim(aConteudo[1])) 
			aConteudo[1] := " "
		EndIf
		
		If Empty(AllTrim(aConteudo[2])) 
			aConteudo[2] := " "
		EndIf
	EndIf
	
	Do Case
		Case cPesq == "Q"
			MDZ->(DbSeek(cFILMDZ))
			While !MDZ->(Eof()) .AND. MDZ->MDZ_FILIAL == cFILMDZ
				If AllTrim(MDZ->MDZ_SIMBOL) == "XM" .AND. AllTrim(MDZ->MDZ_XMLENV) == "N" .AND. MDZ->MDZ_DATA >= cDtIniBlcX
				 	
					Aadd(aRet,{1,;
								MDZ->MDZ_FILIAL,;
								DtoS(MDZ->MDZ_DATA),;
								MDZ->MDZ_FILIAL + DtoS(MDZ->MDZ_DATA),;
								AllTrim(MDZ->MDZ_XMLEPA),;
								MDZ->MDZ_DATA})
				EndIf

				MDZ->(DbSkip())
			End
			
			If Len(aRet) == 0
				Aadd(aRet,{nContES,"","","",""})
			EndIf

		Case cPesq == "E"
			lTemMDZ := MDZ->(DbSeek(cKey))
			While !MDZ->(Eof()) .And. lTemMDZ .And. MDZ->(MDZ_FILIAL+DTOS(MDZ_DATA)) == cKey
				//Verifica se já foi gerado o estoque do mes
				If AllTrim(MDZ->MDZ_SIMBOL) == "XM"
					lGrvMDZ := .F.
					Exit
				EndIf
				
				MDZ->(DbSkip())
			End
			
			If lGrvMDZ
				If ExistFunc("LjxConfMDZ")
					cMDZNum := ""
					LjxConfMDZ(@cMDZNum)
				Else
					cMDZNum := "Atualizar o fonte LOJXFUND - Pode haver erro de gravação da MDZ - Chave Duplicada"
					LjGrvlog( NIL, cMDZNum)
					COnout(cMDZNum)
					cMDZNum := ""
					nX	:= GetSX8Len()
					cMDZNum := GetSx8Num("MDZ","MDZ_NUM")
					If __lSx8
						While (GetSx8Len() > nX)
							ConfirmSx8()
						End
					Else
						RollBackSX8()
					EndIf
				EndIf
			
				RecLock("MDZ",.T.)
				MDZ->MDZ_NUM	:= cMDZNum
				MDZ->MDZ_FILIAL	:= cFILMDZ
				MDZ->MDZ_PDV	:= "0"
				MDZ->MDZ_COO 	:= cMDZNum
				MDZ->MDZ_GNF 	:= ""
				MDZ->MDZ_Grg 	:= ""
				MDZ->MDZ_CDC	:= ""
				MDZ->MDZ_CCF	:= cMDZNum
				MDZ->MDZ_SIMBOL	:= "XM"
				MDZ->MDZ_TIPO	:= "XML"
				MDZ->MDZ_VALOR	:= 0
				MDZ->MDZ_SERPDV	:= ""
				MDZ->MDZ_SERIE 	:= ""
				MDZ->MDZ_DATA	:= dData
				MDZ->MDZ_HORA	:= Left( Time() , 5)
				MDZ->MDZ_NOMCLI	:= ""
				MDZ->MDZ_CGCCLI	:= ""
				MDZ->MDZ_XMLENV := aConteudo[1]
				MDZ->MDZ_XMLEPAF:= aConteudo[2]
				MDZ->MDZ_XMLRPAF:= " "
				MDZ->(MsUnlock())
			Else
				If lTemMDZ
					RecLock("MDZ",.F.)
					MDZ->MDZ_DATA	:= dData
					MDZ->MDZ_HORA	:= Left( Time() , 5)
					MDZ->MDZ_XMLENV := aConteudo[1]
					MDZ->MDZ_XMLEPAF:= aConteudo[2]
					MDZ->(MsUnlock())
				EndIf
			EndIf
			
			If lGrvMDZ .Or. lTemMDZ
				RecLock("MDZ",.F.)
				MDZ->MDZ_PAFMD5	:= STxPafMd5("MDZ")
				MDZ->MDZ_SITUA	:= "RX"
				MDZ->(MsUnlock())
			EndIf
			
			Aadd(aRet,.T.)
		
		Case cPesq == "X" .Or. cPesq == "R"
			
			lTemMDZ := MDZ->(DbSeek(cKey))
			LjGrvLog( NIL, "MDZ - Chave (Filial+Data) [" + cKey + "] - Encontrada ? ", lTemMDZ)
			While !MDZ->(Eof()) .And. lTemMDZ .And. MDZ->(MDZ_FILIAL+DTOS(MDZ_DATA)) == cKey
				//Verifica se já foi gerado o estoque do mes
				If AllTrim(MDZ->MDZ_SIMBOL) == "XM"
					LjGrvLog( NIL, "MDZ - Tipo XM Encontrada ", MDZ->(Recno()))
					Exit
				EndIf
				MDZ->(DbSkip())
			End
			
			Aadd(aRet,.T.)
		
		Case cPesq == "T"
			
			While !MDZ->(Eof())
				If	!(AllTrim(MDZ->MDZ_XMLENV) == "S") .And. AllTrim(MDZ->MDZ_SIMBOL) == "XM"
					
					If Empty(AllTrim(MDZ->MDZ_XMLEPA))
						LjGrvLog( NIL, "Geração de XML de Estoque - STEstqXML", {.T. , .F. , dData-1 , lHomolPaf, dData})
						//a Data vem com o mes de geração do nome do arquivo porém para geração
						//é necessário retornar ao mes anterior (dData - 1)
						aAux := LPXFiscoEstMen( .T.		, .F. 			, dData-1 			, lHomolPaf,;
						 						dData	,/*ArrayProd*/	, FwxFilial("SB1")	, .T.		,;
						 						cNumCreden)
						LjGrvLog( NIL, "Retorno da Geração de XML de Estoque - STEstqXML", aAux)
						If aAux[1][1]
							RecLock("MDZ",.F.)
							REPLACE MDZ->MDZ_XMLEPA WITH aAux[1][2]
							MDZ->(MsUnlock())
						EndIf
					EndIf
					
					Aadd(aRet,{AllTrim(MDZ->MDZ_XMLEPA) , MDZ->(Recno())})
				EndIf
				MDZ->(DbSkip())
			End
			
		Case cPesq == "V"
			MDZ->(DbSeek(cFILMDZ))
			While !MDZ->(Eof()) .AND. MDZ->MDZ_FILIAL == cFILMDZ
				If MDZ->MDZ_DATA >= cDtIniBlcX  .And.	AllTrim(MDZ->MDZ_SIMBOL) == "XM" .And.;
					( ;
					( AllTrim(MDZ->MDZ_XMLENV) == "A" ) .Or.;
					( AllTrim(MDZ->MDZ_XMLENV) == "S" .And. (Upper("Aguardando") $ Upper(MDZ->MDZ_XMLRPAF)) ) .Or.;
					( AllTrim(MDZ->MDZ_XMLENV) == "E" .And. (Upper("Aguardando") $ Upper(MDZ->MDZ_XMLRPAF)) ) ;
					)
				 	
				 	//Envia o indice 1: MDZ_FILIAL + MDZ_DATA
				 	Aadd(aRet,{1,AllTrim(MDZ->MDZ_XMLEPAF),AllTrim(MDZ->MDZ_XMLRPAF),;
				 				MDZ->(Recno()),MDZ->(MDZ_FILIAL + DTOS(MDZ_DATA))}) //Já retorna os XMLs para agilizar validações				 	
				EndIf
				MDZ->(DbSkip())
			End
			
			If Len(aRet) == 0
				Aadd(aRet,{0,"","",0,""})
			EndIf
		
		Case cPesq == "AE"
			MDZ->(DbSeek(cFILMDZ))
			While !MDZ->(Eof()) .AND. MDZ->MDZ_FILIAL == cFILMDZ
				If MDZ->MDZ_DATA >= cDtIniBlcX   .And.	AllTrim(MDZ->MDZ_SIMBOL) == "XM" .And. AllTrim(MDZ->MDZ_XMLENV) == "E"
				 	//Envia o indice 1: MDZ_FILIAL + MDZ_DATA
				 	Aadd(aRet,{1,;
					 			AllTrim(MDZ->MDZ_XMLEPAF),;
								AllTrim(MDZ->MDZ_XMLRPAF),;
				 				MDZ->(Recno()),;
								MDZ->(MDZ_FILIAL + DTOS(MDZ_DATA)),;
								MDZ->MDZ_DATA}) //Já retorna os XMLs para agilizar validações				 	
				EndIf
				MDZ->(DbSkip())
			End
			
			If Len(aRet) == 0
				Aadd(aRet,{0,"","",0,""})
			EndIf

		Case cPesq == "S"
			MDZ->(DbGoTop())
			While !MDZ->(Eof())
				If MDZ->MDZ_FILIAL == cFILMDZ .And.	AllTrim(MDZ->MDZ_SIMBOL) == "XM" .And.;
					AllTrim(MDZ->MDZ_XMLENV) == "S"
				 	
				 	//Envia o indice 1: MDZ_FILIAL + MDZ_DATA
				 	Aadd(aRet,{1,AllTrim(MDZ->MDZ_XMLEPAF),AllTrim(MDZ->MDZ_XMLRPAF),;
				 				MDZ->(Recno()),MDZ->(MDZ_FILIAL + DTOS(MDZ_DATA))}) //Já retorna os XMLs para agilizar validações				 	
				EndIf
				MDZ->(DbSkip())
			End
			
			If Len(aRet) == 0
				Aadd(aRet,{0,"","",0,""})
			EndIf
		
		Case cPesq == "N"
			MDZ->(DbGoTop())
			While !MDZ->(Eof())
				If MDZ->MDZ_FILIAL == cFILMDZ .And.	AllTrim(MDZ->MDZ_SIMBOL) == "XM" .And.;
					AllTrim(MDZ->MDZ_XMLENV) == "N"
				 	
				 	//Envia o indice 1: MDZ_FILIAL + MDZ_DATA
				 	Aadd(aRet,{1,AllTrim(MDZ->MDZ_XMLEPAF),AllTrim(MDZ->MDZ_XMLRPAF),;
				 				MDZ->(Recno()),MDZ->(MDZ_FILIAL + DTOS(MDZ_DATA))}) //Já retorna os XMLs para agilizar validações				 	
				EndIf
				MDZ->(DbSkip())
			End
			
			If Len(aRet) == 0
				Aadd(aRet,{0,"","",0,""})
			EndIf
	EndCase	

	If lTemMDZ
		If cPesq == "R"
			RecLock("MDZ",.F.)
			
			If !Empty(AllTrim(aConteudo[1]))
				REPLACE MDZ->MDZ_XMLENV  WITH aConteudo[1]
			EndIf
			
			If !Empty(AllTrim(aConteudo[2]))
				REPLACE MDZ->MDZ_XMLRPAF WITH aConteudo[2]
			EndIf
			MDZ->(MsUnlock())
		EndIf
		
		If cPesq == "X"
			//Pode retornar qualquer campo - na teoria somente os campos de XML
			//aConteudo[1]: manda o nome do campo MDZ_XMLXXXX
			Aadd(aRet,AllTrim(MDZ->&(aConteudo[1])))
		EndIf
	EndIf
	
	For nX := 1 to Len(aArea)
		RestArea(aArea[nX])
	next nX
EndIf

Return aRet

//-------------------------------------------------------------------
/*/{Protheus.doc} STFMMd5NS - MD5 da Nota de Saída
-Chamada pelos fontes da DANFE/LOJXFUNC para gerar o MD-5 dos 
campos de SD2 e SF2, no momento da geração da DANFE da NF-e
-Atendimento do Requisito do PAF-ECF
-Não desposicionar nenhuma tabela e se o fizer retorne a área
@author  Varejo
@version P11-P12
@since   14/08/2017
@return  lRet
@obs Deixar os ExistFunc e ColumnPos para evitar problema na 
	geração da DANFE da NF-e (fontes DANFEII e DANFEIII) e 
	usada também pelo LOJXFUNC.
	A tabela SF2 já deve estar posicionada no registro correto 
/*/
//-------------------------------------------------------------------
Function STFMMd5NS()
Local lRet		:= .T.
Local lLjGrvLog	:= ExistFunc("LjGrvLog")
Local aAreaSD2	:= {}
Local cPafMD5 	:= ""
Local cKeySF2	:= ""
Local nTamVLUn	:= TamSX3("D2_PRUNIT")[2]
Local nTamQtde	:= TamSX3("D2_QUANT")[2]

If	SF2->(ColumnPos("F2_PAFMD5")) > 0 .And. SD2->(ColumnPos("D2_PAFMD5")) > 0 .And.;
	SD2->(ColumnPos("D2_DECVLU")) > 0 .And. SD2->(ColumnPos("D2_DECQTD")) > 0 .And.;
	STFMIMd5Doc(SF2->F2_ESPECIE)

 	If lLjGrvLog
		LjGrvLog(Nil,"Inicia Gravação de Campos SF2 e SD2 para PAF-ECF")
		LjGrvLog(Nil,"Geração MD5 campo [F2_PAFMD5]")
	EndIf	
	
	cPafMD5 := STxPafMd5("SF2")
	RecLock("SF2",.F.)
	REPLACE SF2->F2_PAFMD5 WITH cPafMD5 
	SF2->(MsUnlock())
	
	 If lLjGrvLog
		LjGrvLog(Nil,"Campo [F2_PAFMD5] gravado")
		LjGrvLog(Nil,"Inicia Pesquisa da SD2")
	EndIf
	
	aAreaSD2:= SD2->(GetArea())
	
	cKeySF2	:= SF2->(F2_FILIAL+F2_DOC+F2_SERIE+F2_CLIENTE+F2_LOJA)
	
	SD2->(DbSetOrder(3)) //D2_FILIAL, D2_DOC, D2_SERIE, D2_CLIENTE, D2_LOJA, D2_COD, D2_ITEM
	If SD2->(DbSeek(SF2->(cKeySF2)))
		If lLjGrvLog
			LjGrvLog(Nil," Informações na tabela SD2 encontradas - Campos [D2_DECVLU,D2_DECQTD,D2_PAFMD5] serão gravados")
		EndIf
	EndIf
	
	cPafMD5 := ""
	
	While !SD2->(Eof()) .And. (SD2->(D2_FILIAL+D2_DOC+D2_SERIE+D2_CLIENTE+D2_LOJA) == SF2->(cKeySF2))
		
		RecLock("SD2",.F.)
		REPLACE SD2->D2_DECVLU WITH nTamVLUn
		REPLACE SD2->D2_DECQTD WITH nTamQtde
		SD2->(MsUnlock())
		
		cPafMD5 := STxPafMd5("SD2",SF2->(AllTrim(F2_CHVNFE)+AllTrim(F2_ESPECIE)))
		RecLock("SD2",.F.)
		REPLACE SD2->D2_PAFMD5	WITH cPafMD5
		SD2->(MsUnlock())

		SD2->(DbSkip())
	End
	
	RestArea(aAreaSD2)
	
	If lLjGrvLog
		If !Empty(cPafMD5)
			LjGrvLog(Nil,"Finaliza Gravação de Campos SF2 e SD2 para PAF-ECF")
		Else
			LjGrvLog(Nil,"Campos referentes ao PAF-ECF não foram encontrados nas " +;
					" tabelas SF2 ou SD2. Verifique atualização do ambiente para o Laudo POL0852017R1")
		EndIf
	EndIf
EndIf								

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} STFMMD5Nfe
 
 Ato Cotepe 09/2013 - PAF-ECF ER 02.01 - Requisito XXVIII - item 3
 Imprimir o MD5 do Cupom Fiscal nas mensagens adicionais na NF-e
 
 - Valido somente o parametro pois se entrar na função do LjNfPafECf
 pode solicitar alguma DLL do Loja pra outros modulos
 
@author  Varejo
@version P11-P12
@since   24/08/2017
@param	cMsgFis , caracter , passado como referencia 
		pois já vem com um conteúdo do fonte NFESEFAZ
@return  cMD5
@obs Deixar os ExistFunc e ColumnPos para evitar problema na 
	geração da DANFE da NF-e no Fonte NFESEFAZ
/*/
//-------------------------------------------------------------------
Function STFMMD5Nfe(cMsgFis)
Local cMD5Master := ""

If SuperGetMV("MV_LJPAFEC",,.F.)
	cMD5Master := STBVerPAFECF( "MD5LISTA" , .T. , .T. )
	
	If Len(cMsgFis) > 0
		cMsgFis := "MD-5:" + Upper(cMd5Master) + " " + cMsgFis
	Else
		cMsgFis := "MD-5:" + Upper(cMd5Master)
	EndIf
EndIf 

Return cMD5Master

//-------------------------------------------------------------------
/*/{Protheus.doc} STFMIMd5Doc
 
Valida se insere MD5 nessa nota
 
@author  Varejo
@version P11-P12
@since   24/08/2017
@param	cEspecNF , caracter , especie da nota
@return  lRet, logico, série é permitida
/*/
//-------------------------------------------------------------------
Function STFMIMd5Doc(cEspecNF)
Local lRet	:= .F.
Local cEspec:= "" 

Default cEspecNF := ""

cEspec := AllTrim(Upper(cEspecNF))

If	cEspec == 'SPED' .Or. cEspec == 'NFCE' .Or. cEspec == 'NF' .Or.;
	cEspec == 'NFCF' .Or. cEspec == 'NFM'
	lRet := .T.
EndIf

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} STFUpFIXML
 
Atualiza os dados da SFI relativos ao XML do PAF
 
@author  Varejo
@version P12
@since   18/04/2019
@param	aFldUp , array , campos e valores a serem alterados na SFI
@param	lAtuMD5, lógico, atualiza o MD5?
@return  lRet, logico
/*/
//-------------------------------------------------------------------
Function STFUpFIXML(aFldUpd,lAtuMD5,nRecSFI)
Local cPafMD5	:= ""
Local cPafTrbMD5:= ""
Local lRet		:= .T.
Local lMvLjPdvPa:= LjxBGetPaf()[2]
Local nX		:= 0

Default aFldUpd := {}
Default lAtuMD5	:= .T.

If nRecSFI > 0	
	SFI->(MsGoTo(nRecSFI))
	
	If Len(aFldUpd) > 0
		RecLock("SFI",.F.)
		For nX := 1 to Len(aFldUpd)
			REPLACE &(aFldUpd[nX][1]) WITH aFldUpd[nX][2] 
		Next nX
		SFI->(MsUnlock())
	EndIf
	
	If lAtuMD5
		//Atualiza o MD-5
		cPafMD5		:=	STxPafMd5("SFI")
		cPafTrbMD5	:=	STxPafMd5("SFI",,"2")
		RecLock("SFI",.F.)
		Replace SFI->FI_PAFMD5 WITH	cPafMd5
		Replace SFI->FI_MD5TRIB WITH cPafTrbMD5
		If lMvLjPdvPa //Manda esse para que os dados sejam atualizados na retaguarda
			Replace SFI->FI_SITUA WITH "00"
		EndIf
		SFI->(MsUnlock())
	EndIf
EndIf

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} SFMStocMen
Posição mensal de Estoque para cada produto
Leitura da SB3 
aSB3
[nX][1] - Codigo do Produto
[nX][2] - Mes de Referencia para pesquisa

@author  Varejo
@version P12
@since   25/06/2019
@param	aSb3 , array , campos e valores a serem alterados na SFI
@return  lRet, logico
/*/
//-------------------------------------------------------------------
Function SFMStocMen(aSb3)
Local aRet	:= {}
Local nSb	:= 0

Default aSb3:= {}

If Len(aSb3) > 0
	DBSelectArea("SB3")
	SB3->(DBSetOrder(1)) //B3_FILIAL, B3_COD, R_E_C_N_O_, D_E_L_E_T_
EndIf

For nSb := 1 To Len(aSb3)
	
	If SB3->(DbSeek( xFilial("SB3") + aSb3[nSb][1] ))
		aSb3[nSb][3]	:= SB3->(&("B3_Q"+aSb3[nSb][2]))// Campo da tabela B3_QXX , onde XX é o mes
		If ValType(aSb3[nSb][3]) == "N"
			aSb3[nSb][3] := cValToChar(aSb3[nSb][3])
		EndIf
		aSb3[nSb][4]	:= Dtos(SB3->B3_MES) //DATA DE ATUALIZACAO DO ESTOQUE
	Else
		aSb3[nSb][3]	:= "0"
		aSb3[nSb][4]	:= ""
	EndIf

Next nSb

Aadd(aRet, aSb3)

Return aRet

//-------------------------------------------------------------------
/*/{Protheus.doc} STrReqXXVI
 
Tratamento para o requisito XXVI - envio do arquivo de Registros 
do PAF
 
@author  Varejo
@version P12
@since   18/04/2019
@param	aFldUp , array , campos e valores a serem alterados na SFI
@param	lAtuMD5, lógico, atualiza o MD5?
@return  lRet, logico
/*/
//-------------------------------------------------------------------
Static Function STrReqXXVI(cOpcao, lPOS)
Local dDataIni	:= CtoD("")	// Data Inicial
Local dDataFim	:= CtoD("")	// Data Final	
Local lRedZ		:= .F.
Local nTipoTr	:= 0

Default	cOpcao	:= ""
Default	lPOS	:= .F.

MsgInfo(" FUNÇÃO INDISPONÍVEL - Não existe serviço habilitado na SEFAZ para esse envio ","PAF-ECF")


/*If STITelMenFis(	"Transmitir arquivos Requisito XXVI", cOpcao	, @dDataIni	, @dDataFim	,;
					Nil		, Nil		, @cPDV		, nil			,;
					Nil		, lPOS		, @nTipoTr	, Nil			,;
					Nil		)
					
LPXTrXXVI(lPOS,dDataIni,dDataFim,nTipoTr)	

EndIf*/

Return NIL

//-------------------------------------------------------------------
/*/{Protheus.doc} SFMProcXEs

Função permitir o Reprocessamento do Arquivo de Estoque 
 
@author	Varejo
@version P12
@since	06/06/2019
@param	lSelData , logico , permite selecionar a data de geração da data
@param	dUltMov, data, data do ultimo movimento
@return	lRet, logico
/*/
//-------------------------------------------------------------------
Function SFMProcXEs(lSelData	, lPOS	, dUltMov)
Local dData		:= dDatabase
Local dDataIni	:= CTOD("")
Local dDataFim	:= CTOD("")
Local lOK		:= .F.

Default lSelData:= .F.
Default lPOS	:= .F.
Default dUltMov	:= CTOD("") 

If lSelData
	If STITelMenFis("XML de Estoque"	, "XMLEST"	, @dDataIni		, @dDataFim		,;
					/* Nil */			, /* Nil */	, /* Nil */		, /*@lArqTxt*/	,;
					NIL					, lPOS		, /*nTipoMfd*/	, NIL			)
		dData	:= dDataIni-1 //Pega o mes posterior na tela, se referindo ao Estoque do mes passado
		lOK		:= .T.
	EndIf
EndIf

If !Empty(StrTran(DtoC(dUltMov),"/"))
	dData	:= dUltMov
	dDataFim:= LastDay(dData,0) + 1 //Data de referencia
	lOK		:= .T.
EndIf

If lOK
	LPXFiscoEstMen(	.F.			,lPOS			,LastDay(dData,0),lHomolPaf,;
					dDataFim	,/*ArrayProd*/	,FwxFilial("SB1"),/*lDelFile*/,;
					/*cNumCreden*/) 	//Deve passar o ultimo dia do mes
EndIf

Return 

//-------------------------------------------------------------------
/*/{Protheus.doc} SFMAlqIssI

Efetua o tratamento das alíquotas de ISS Isento/Nao Tributado/Substituido
pois no Ato Cotepe não tem referência dessas alíquotas, portanto 
criei esse tratamento, devendo retornar S00.00
 
@author	Julio.Nery
@version P12
@since	07/10/2019
@param	cSitrib, caracter, alíquota de ISS Isento - NS/IS/FS
@param	lRetVal, lógico, retorna o valor de ISS - que sempre será zerado
@return	cRet, caracter, retorno - S00.00
/*/
//-------------------------------------------------------------------
Function SFMAlqIssI(cSitTrib,lRetVal)
Local cRet := ""

Default cSitTrib:= ""
Default lRetVal	:= .T.
 
/*
	Segundo o Ato Cotepe não tem tratamento 
	para essas alíquotas de ISS, portanto
	eu trato inserindo uma alíquota de ISS zerada
	que é aceita pelos fontes 
*/
If !Empty(AllTrim(cSitTrib))
	If cSitTrib $ "NS|IS|FS"		
		cRet := "S"
		If lRetVal
			cRet += AllTrim( StrZero( 0 , 5, 2 ) ) 
		EndIf
	Else
		cRet := cSitTrib
	EndIf
EndIf

Return cRet

//-------------------------------------------------------------------
/*/{Protheus.doc} SFMSlxSl2

Retorna a alíquota de um produto da SLX a partir da SL2
 
@author	Julio.Nery
@version P12
@since	07/10/2019
@param	cProduto, caracter, código do produto já formatado ( com PADR e TAM do campo)
@return	cSitTrib, caracter, retorna a tributação
/*/
//-------------------------------------------------------------------
Function SFMSlxSl2(cProduto,dData,lLX_SITTRI)
Local aArea		:= {}
Local cSitTrib	:= ""
Local cFilSL2	:= ""
Local cAux		:= ""
Local nPos		:= 0
Local nLimite	:= 60
Local lAchouReg := .F.
Local lPesqProd := .F.

Default lLX_SITTRI := .F.

Static aProdLXL2 := {} //array para economia do processamento

nPos := Ascan(aProdLXL2, {|x| x[1] == Upper(AllTrim(cProduto))})

If nPos > 0
	cSitTrib := aProdLXL2[nPos][2]
Else
	DbSelectArea("SL2")
	aArea	:= SL2->(GetArea())
	cFilSL2	:= xFilial("SL2")
	
	SL2->(DbSetOrder(2)) //L2_FILIAL + L2_PRODUTO + L2_EMISSAO
	IF	SL2->(DbSeek(cFilSL2+cProduto+ DTOS(dData) )) .And.;
		!Empty(AllTrim(SL2->L2_PAFMD5)) .And. !Empty(AllTrim(SL2->L2_DOC)) .And.;
		!( AllTrim(SL2->L2_ENTREGA) == "3" )
		
		lAchouReg := .T. 
	EndIf
	
	If !lAchouReg
		nPos := 1
		lPesqProd := .T.
		//Pesquiso a venda do Produto nos ultimo(s) mes(es) 
		//para poder pegar uma tributação recente
		//pois pode acontecer da tributação ter mudado
		While lPesqProd
			IF	SL2->(DbSeek(cFilSL2+cProduto+ DTOS(dData-nPos) )) .And.;
				!Empty(AllTrim(SL2->L2_PAFMD5)) .And. !Empty(AllTrim(SL2->L2_DOC)) .And.;
				!( AllTrim(SL2->L2_ENTREGA) == "3" )
			
				lAchouReg := .T. 
			EndIf
			
			nPos++
			lPesqProd := nPos <= nLimite
			lPesqProd := !lPesqProd .And. !lAchouReg
		End
	EndIf
	
	If lAchouReg
		aadd(aProdLXL2,{Upper(AllTrim(cProduto)),AllTrim(SL2->L2_SITTRIB)})
		cSitTrib := AllTrim(SL2->L2_SITTRIB)
		cAux	 := Substr(cSitTrib,2,Len(cSitTrib))
		nPos	 := Val(cAux)/100
		
		//A SLX ja deve estar posicionada antes de chamar aqui
		RecLock("SLX",.F.)
		If lLX_SITTRI
			REPLACE SLX->LX_SITTRIB WITH cSitTrib
		EndIf
		
		If Substr(cSitTrib,1,1) == "T" //Somente grava se for ICMS
			REPLACE SLX->LX_ALIQICM WITH nPos
		EndIf
		SLX->(MsUnlock())
	EndIf
	
	RestArea(aArea)
EndIf

Return cSitTrib

//-------------------------------------------------------------------
/*/{Protheus.doc} STDtIniBlX

Retorna a data inicio validação bloco X
 
@author	caio.okamoto
@version P12
@since	08/2020
@param	nil
@return	data inicio validação bloco X 
/*/
//-------------------------------------------------------------------

Function STDtIniBlX(cTipo)
Local cData 		:= "" 
Local cSigaloja 	:= GetClientDir()+"SIGALOJA.INI" 	//verifica se existe arquivo sigaloja.ini 
Local cDtIniBlX 	:= 	""								// Data inicio vegencia Bloco X

Default cTipo		:= ""

	If Empty(cDtIniBlX) .AND. File (cSigaloja) 
		cData := GetPvProfString("PAF-ECF","BlocoX","", cSigaloja)
		LjGrvLog("STDtIniBlX","sigaloja.ini->blocoX = " + cData )
		If !Empty(cData) .AND. (Len(cData) == 8) .AND. !('/'$cData)
			cDtIniBlX := cData
		Else
			cDtIniBlX := "20201001"
			LjGrvLog("STDtIniBlX","sigaloja.ini->blocoX não preenchido ou inválido. Vai utilizar valor default " + cDtIniBlX)
			Conout("sigaloja.ini->blocoX = " + cData + "  preencha corretamente AAAAMMDD.")
		EndIf
	Elseif GetRemoteType() == 5 
		cDtIniBlX 	:= 	"20991231" 	//quando é SmartClient HTML não terá acesso ao arquivo, 
									//por isso cosidera data futura para que nunca ative a
									//validação do Bloco X
	EndIf

	/*ATO DIAT 46/2022-SOMENTE DEVE SER ENVIADO ESTOQUE A PARTIR DO DIA 31/12/2022 ANUALMENTE*/
	cDtIniBlX :=Iif(cTipo=="R" .OR. (ExistFunc("LJPENDESTQ") .AND. LJPENDESTQ()), cDtIniBlX, "20221231")

Return cDtIniBlX

//-------------------------------------------------------------------
/*/{Protheus.doc} STIIdPafNf

Informações da opção de Identificação do PAF-NFC-e
 
@author	bruno.costa
@version P12
@since	27/07/2022
@param	cConteudo, character, Informações da opção de Identificação do PAF-NFC-e
@return	nil
/*/
//-------------------------------------------------------------------
Static Function STIIdPafNf(cConteudo)

Local oDlg
Local cTitulo	:= STR0242
Local cPath  	:= ""
Local cFile		:= "" 


DEFINE MSDIALOG oDlg FROM 10,10 TO 290,380 TITLE cTitulo PIXEL

	@ 002,045 SAY cConteudo SIZE 150,190 OF oDlg PIXEL // Identificação do PAF-NFC-e

	DEFINE SBUTTON oBtnOk FROM 110,085 TYPE 1 ENABLE OF oDlg ACTION (oDlg:End())

ACTIVATE MSDIALOG oDlg CENTERED 

STBFMGerPath( @cPath ) 
cFile	:= STBFMGerFile( "identpafnfce", .T. )

/*Identificação do PAF-NFC-e não tem gravação do arquivo txt, por isso será enviado 
no parametro cNomeArq o nome do arquivo xml que será gerado e no parametro cContArq o conteúdo que será gravado no xml*/
STBGeraXML(  cPath + Substr(cFile ,1,len(cFile )-3) +"xml", "I", cConteudo) 

Return



/*/{Protheus.doc} STBGeraXML
Gera XML dos arquivos do PAF-NFC-e Requisito XI 
	@type  Function
	@author caio.okamoto
	@since 05/09/2022
	@version 12.1.33
	@param1 cNomeArq , caracter, nome do arquivo original gerado como .txt
	@param2 cTipoArq , caracter, tipo do arquivo do PAF-NFC-e I –“Identificação do PAF-NFC-e;II –“Registros do PAF-NFC-e”; III –“Saídas  Identificadas  pelo  CPF/CNPJ”
	@param3 cContArq , caracter, conteúdo a ser gravado no arquivo XML caso não exista arquivo .txt
	/*/
Static Function STBGeraXML(cNomeArq, cTipoArq, cContArq)
Local cXML			:= ""
Local cConteudo 	:= "" 
Local aXMLRet		:= {}
Local nHdlArq 		:= 0
Local cNomeArqXML	:= ""

Default cContArq 	:= ""

LJRPLogProc("Início da rotina STBGeraXML-geração do XML do PAF-NFC-e do arquivo "+ cNomeArq )

If !Empty(cContArq)
	//quando !Empty(cContArq) significa que não existe arquivo .txt ex.: I –Identificação do PAF-NFC-e
	cConteudo:= cContArq
	cNomeArqXML	:= cNomeArq
Else
	nHdlArq := FOpen(cNomeArq)
	If !Empty(nHdlArq)
		nSize := FSeek(nHdlArq, 0, 2)
		cConteudo:= Space(nSize)
		FSeek(nHdlArq, 0, 0)
		FRead(nHdlArq, @cConteudo, nSize)
		FClose(nHdlArq)
	Endif 

	Iif (Empty(nHdlArq), LJRPLogProc("Erro ao tentar abrir o arquivo "+ cNomeArq ),nil)
	
	// altera a extensão do nome arquivo .txt para .xml para gravar o arquivo com o mesmo nome 
	cNomeArqXML	:= Substr(cNomeArq,1,len(cNomeArq)-3) + "xml"
Endif 

If !Empty(cConteudo)

	cConteudo:= Encode64(cConteudo)

	cXML := '<?xml version="1.0" encoding="utf-8"?>'
	cXML += '<menuFiscal xmlns= "http://www.sef.sc.gov.br/nfce">' 
	cXML += "<arquivo>" + cConteudo + "</arquivo>"
	cXML +="<nroArquivo>" + ctipoArq + "</nroArquivo>"
	cXML +="<data>" + DTOC(dDatabase) + "</data>"
	cXML +="<hora>"+ Time() +"</hora>"
	cXML +="<arqBD>"+ 'Banco de dados local' + "</arqBD>"
	cXML +="<arqSist>" + 'PAF-NFC-e Local'+ "</arqSist>"

	aXMLRet := LPXXmlAss(.F., lTotvsPdv ,"</menuFiscal>",cXML) 

	Iif (aXMLRet[1][1], cXML += aXMLRet[1][2], LJRPLogProc("Problemas na assinatura do arquivo XML - Arquivo XML será gerado sem assinatura"))

	cXML += "</menuFiscal>"

	nHdlArq:= FCREATE( cNomeArqXML,0)
	
	If !Empty(nHdlArq)
		FWRITE(nHdlArq, cXML, Len(cXML))
		FCLOSE(nHdlArq)

		LJRPLogProc("Arquivo XML do PAF-NFC-e "+ cNomeArqXML + " gerado com sucesso")
	
		STFMessage("STBGeraXML", "POPUP","Arquivo XML do PAF-NFC-e "+ CRLF + cNomeArqXML + CRLF + " gerado com sucesso!")
		STFShowMessage("STBGeraXML")
	Endif 

	Iif(Empty(nHdlArq), LJRPLogProc("Erro ao tentar criar o arquivo "+ cNomeArqXML ), nil)	
	
Endif 

Return 
