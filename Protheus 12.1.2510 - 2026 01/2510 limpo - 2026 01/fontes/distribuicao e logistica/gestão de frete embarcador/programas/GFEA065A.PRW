#INCLUDE "PROTHEUS.CH"
#INCLUDE "GFEA065A.CH"

/*-------------------------------------------------------------------
{Protheus.doc} GFEA065A

@author Luiz Fernando Soares	
@since 28/05/10
@version 1.0
-------------------------------------------------------------------*/
                                      
Function GFEA065A(aCompDF,cNrCalcPri)                      

	Local oDlg
	Local cDSTRAN,cCombo
	Local nAlt     := (GetScreenRes()[2]-400)
	Local nLrg     := (GetScreenRes()[1]-100)
	Local aItensCB := {STR0001, STR0002} //"Complementar Valor" ### "Complementar Imposto"
	Local nLinha   := 0
	Local nCount   := 0
	Local nI       := 0
	
	Private aNewButton  := {}
	Private cCadastro   := STR0003 //"Documentos de Carga"
	Private cMarca      := GetMark()
	Private oListDoc
	Private oGetComp    //:= aCompDF
	Private aComp		  := DefTabComp()
	Private aColsComp   := aCompDF 
	Private nVlTot      := 0 
	Private nAliqImp    := 0 
	Private nVlImp      := 0
	Private cNrCalc     := cNrCalcPri
	
	//--------------------------
	// Montagem da tela        
	//--------------------------
	
	IIF (nAlt < 584,nAlt := 584, .T.)

	Define MsDialog oDlg Title cCadastro From 40,65 To nAlt,nLrg Of oMainWnd Color CLR_BLACK,RGB(225,225,225) Pixel
	oDlg:lEscClose := .F.
	
	oPainel := tPanel():New(00,00,,oDlg,,,,,,10,100,.F.,.F.)
	oPainel:Align := CONTROL_ALIGN_ALLCLIENT

	//----- Painel superior da tela principal, com as informacoes do romaneio -----//
	oPnlA := tPanel():New(00,00,,oPainel,,,,,,10,100,.F.,.F.)
	oPnlA:Align := CONTROL_ALIGN_TOP
	
	oPnlC := tPanel():New(0,0,,oPainel,,,,,/*CLR_HRED*/,40,100)
   	oPnlC:align:= CONTROL_ALIGN_ALLCLIENT
		
	//--------------- Fim do painel inferior da tela principal-----------------------//

		// ----- Criacao dos fields referente ao romaneio no painel superior da tela principal -----//
		cDSTRAN := posicione("GU3",1,xFilial("GU3")+GW3->GW3_EMISDF,"GU3_NMEMIT")	  			
		
		@ 07,10 Say STR0004 Of oPnlA COLOR CLR_BLACK Pixel //"Emissor: "
		@ 05,50 MSGET GW3->GW3_EMISDF  Picture "@!" Of oPnlA Valid /*ValidDic()*/ When .F.   Pixel 
		@ 05,105 MSGET cDSTRAN Picture "@!" Of oPnlA Valid /*ValidDic()*/ When .F.   Pixel
		@ 22,10  Say STR0005 Of oPnlA COLOR CLR_BLACK Pixel //"Número: "
	   	@ 20,50  MSGET GW3->GW3_NRDF Picture "@!" Of oPnlA Valid /*ValidDic()*/ When .F.   Pixel
		@ 37,10  Say STR0006 Of oPnlA COLOR CLR_BLACK Pixel //"Série: "	
		@ 35,50 MSGET GW3->GW3_SERDF  Picture "@!" Of oPnlA Valid /*ValidDic()*/ When .F.   Pixel 
		@ 52,10  Say STR0007 Of oPnlA COLOR CLR_BLACK Pixel //"Tipo: "
		@ 50,50 MSGET GW3->GW3_TPDF  Picture "@!" Of oPnlA Valid /*ValidDic()*/ When .F.   Pixel 
		@ 52,70  Say STR0008 Of oPnlA COLOR CLR_BLACK Pixel	//"Especie: "
		@ 50,110 MSGET GW3->GW3_CDESP  Picture "@!" Of oPnlA Valid /*ValidDic()*/ When .F.   Pixel 
		
		@ 22,180  Say STR0009 Of oPnlA COLOR CLR_BLACK Pixel //"Data Emissão: "
	   	@ 20,220  MSGET GW3->GW3_DTEMIS Picture "@!" Of oPnlA Valid /*ValidDic()*/ When .F.   Pixel
		@ 37,180  Say STR0010 Of oPnlA COLOR CLR_BLACK Pixel //"Data Entrada: "
	   	@ 35,220  MSGET GW3->GW3_DTENT  Picture "@!" Of oPnlA Valid /*ValidDic()*/ When .F.   Pixel 
	   	
	   	@ 52,180  Say STR0011 Of oPnlA COLOR CLR_BLACK Pixel //"Tipo Cálculo: "
	   	@ 50, 220 COMBOBOX oCombo VAR cCombo ITEMS aItensCB SIZE 180,10 PIXEL OF oPnlA	
	   	
	   	@ 67,180  Say STR0012 Of oPnlA COLOR CLR_BLACK Pixel //"Aliquota Imp: "
	   	@ 65,220  MSGET nAliqImp Picture "999.99" Of oPnlA Valid GFEVlImpAl() When {||GFEA065CB(cCombo)}   Pixel
	   	@ 67,350  Say STR0013 Of oPnlA COLOR CLR_BLACK Pixel //"Valor Imposto: "
	   	@ 65,390  MSGET nVlImp  Picture "999,999.99" Of oPnlA When .F.   Pixel
	   	
	   	@ 82,180  Say STR0014 Of oPnlA COLOR CLR_BLACK Pixel //"Valor Total: "
	   	@ 80,220  MSGET nVlTot  Picture "999,999.99" Of oPnlA When .F.   Pixel
	   		                                                                                                                                                                      
		//---------Fim da criacao dos fields ----------//                                                      
			
	    // Folders
		oFolder := TFolder():New(0,0,{STR0015},{"HEADER 1"},oPnlC,,,,.T.,, 420, 222,) //"Componentes"
		oFolder:Align := CONTROL_ALIGN_ALLCLIENT	
		
		oPnlC := tPanel():New(0,0,,oFolder:aDialogs[1],,,,,/*CLR_HRED*/,40,100)
	   	oPnlC:align:= CONTROL_ALIGN_ALLCLIENT
		
		// Grid Componentes
	   	oGetComp := MsNewGetDados():New( 005, 005, 120, 265,7 ,/*"GFEA065LIN()"*/,,,{'CDCOMP','VALFIX'},,,,,, oPnlC, aComp , )
	   	oGetComp:oBrowse:Align := CONTROL_ALIGN_ALLCLIENT 
	   	
		Processa({|lEnd| LoadComp()}, STR0016, STR0017) //"Processando informações" ### "Aguarde" 
		CursorArrow()
		
		ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar(ODlg,{||If(GFEA65AOK(cCombo,GW3->GW3_EMISDF,GW3->GW3_NRDF,GW3->GW3_SERDF,GW3->GW3_TPDF,GW3->GW3_CDESP,GW3->GW3_DTEMIS,nAliqImp,nVlImp),ODlg:End(),NIL)},;
			{||ODlg:End()},,aNewButton) CENTERED 
	
		//-----------------------------------------//

	//Depois de limpar as temp-table é necessário selecionar uma tabela, para que não ocorra erros//
	dbSelectArea("GWN")
	
Return

/*-------------------------------------------------------------------
{Protheus.doc} AddTabHead

Função auxiliar para incluir o Header (Definição) da temp-table

@author Luiz Fernando Soares
@since 17/05/10
@version 1.0
-------------------------------------------------------------------*/

Static Function DefTabComp()
	Local aDefTabComp := {} // Campos da temp-table de Tabela de Frete
	
	AddTabHead(@aDefTabComp, STR0018 , "CDCOMP" , "C", 20, 0, "@!", "GV2FRT")	//"Componente"
	AddTabHead(@aDefTabComp, STR0019 , "VALFIX" , "N", 05, 3, "999,999.99",'') //"Valor Fixo"

Return aDefTabComp

/*-------------------------------------------------------------------
{Protheus.doc} AddTabHead

Função auxiliar para incluir o Header (Definição) da temp-table

@author Luiz Fernando Soares
@since 17/05/10
@version 1.0
-------------------------------------------------------------------*/   

Static Function AddTabHead(aHead, Titulo, Nome, TipoDado, Tamanho, Decimal, Mascara,nomeF3)

	aAdd( aHead, { ;	
	Titulo			, ;    // 01 - Titulo
	Nome    		, ;    // 02 - Campo
	Mascara      	, ;    // 03 - Picture
	Tamanho      	, ;    // 04 - Tamanho
	Decimal      	, ;    // 05 - Decimal
	''          	, ;    // 06 - Valid
	''          	, ;    // 07 - Usado
	TipoDado     	, ;    // 08 - Tipo
	nomeF3       	, ;    // 09 - F3
	'R'         	, ;    // 10 - Contexto
	''          	, ;    // 11 - ComboBox
	''      		, ;    // 12 - Relacao
	'.T.'        	, ;    // 13 - Alterar
	''        		, ;    // 14 - Visual
	''          	} )    // 15 - Valid Usuario

Return

//--------------------------------------------------------------------

Function GFEA65AOK(cCbTpCalc,cEmisDF,CNrDF,cSerDF,cTipoDF,cEspecie,dDtEmissao,nAliqImp,nVlImp) 
	Local aColsCompFr := {}
	Local nAliqICMS := 0
	Local nAliqISS  := 0
	Local nCount, nCount2

	If cCbTpCalc == STR0001 //"Complementar Valor"
		cTpCal := "2"
	ElseIf cCbTpCalc == STR0002 //"Complementar Imposto"
		cTpCal := "3"
	EndIf
	
	dbSelectArea("GWF")                                                  
	dbSetOrder(1)
	If dbSeek(xFilial("GWF")+cNrCalc)
		nAliqICMS := GWF->GWF_PCICMS
		nAliqISS  := GWF->GWF_PCISS	
	EndIf
	
	For nCount := 1 To Len(oGetComp:aCols)		
		If oGetComp:aCols[nCount,3] == .F.  //Somente não excluídos		
			If AllTrim(Posicione("GV2",1,xFilial("GV2")+oGetComp:aCols[nCount,1],"GV2_CDCOMP")) == ""
				MsgAlert("Componente " + AllTrim(oGetComp:aCols[nCount,1])  + " não cadastrado.")
				Return .F.
			EndIf
		
			For nCount2 := 1 To Len(oGetComp:aCols)
				If nCount2 > nCount .And. (Vazio(oGetComp:aCols[nCount2,3]) .Or. oGetComp:aCols[nCount2,3] == .F.)
					If oGetComp:aCols[nCount,1] == oGetComp:aCols[nCount2,1] 
						MsgAlert("Componente " + AllTrim(oGetComp:aCols[nCount,1]) + " informado mais de uma vez.")
						Return .F.				
					EndIf
				EndIf
			Next nCount2		

			If oGetComp:aCols[nCount,2] > 0
				AAdd(aColsCompFr, {nCount, oGetComp:aCols[nCount,1], oGetComp:aCols[nCount,2]})
			EndIf
		EndIf
	Next nCount
	
	GFECalComp(aColsCompFr,cTpCal,cEmisDF,CNrDF,cSerDF,cTipoDF,cEspecie,dDtEmissao,nAliqImp,nVlImp,nVlTot,nAliqICMS,nAliqISS)
	
Return .T.

//---------------------------------------------------------------------

Static Function LoadComp()
	Local aCols := {}
	Local nCount := 0
	Local nCount2:= 0
	Local lSoma := .F.
	
	// Mostra na grid os Componentes relacionados à negociação selecionada
	aCols := {}	
	For nCount := 1 To Len(aColsComp)
		
		For nCount2 := 1 to Len(aCols)
		   If aCols[nCount2,1] == aColsComp[nCount,2]
				aCols[nCount2,2] += aColsComp[nCount,3]
				lSoma := .T.			   
		   EndIf
		Next nCount2
		
		If !lsoma
			AAdd(aCols,Array(Len(aComp)+1))
				aCols[Len(aCols),1] := aColsComp[nCount,2]
				aCols[Len(aCols),2] := aColsComp[nCount,3]
				aCols[Len(aCols),Len(aComp)+1] := .F.
		EndIf
		
		nVlTot += aColsComp[nCount,3]
		
	Next nCount	
	
	// Atualiza os dados da grid de Rotas
	oGetComp:SetArray(aCols, .T.)
	oGetComp:oBrowse:Refresh()		
Return

//------------------------------------------------------------

Static Function GFEA065CB(cTipComple)
	Local lHabCampo := .T.

	If cTipComple == STR0001 //"Complementar Valor"
	   	lHabCampo := .F.
	   	oGetComp:oBrowse:Enable()
	ElseIf cTipComple == STR0002 //"Complementar Imposto"
		oGetComp:oBrowse:Disable()
		lHabCampo := .T.
	EndIf

Return lHabCampo

//------------------------------------------------------------

Static Function GFEVlImpAl()

	nVlImp := nVlTot * (nAliqImp/100)

Return
