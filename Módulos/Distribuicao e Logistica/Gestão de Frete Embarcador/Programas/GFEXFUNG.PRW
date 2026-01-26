#INCLUDE "PROTHEUS.CH" 
#INCLUDE "FWMVCDEF.CH"
//------------------------------------------------------------------------------------------------
/* Funções de utilidade para interface (Browse, MsGet, etc) 									*/
//------------------------------------------------------------------------------------------------

//---------------------------------------------------------------------------------------------------
/*/{Protheus.doc} GFEGRABARC
Classe para gráfico em barra horizontal
Generico

@author Israel A. Possoli
@since 18/05/12
@version 1.0
/*///------------------------------------------------------------------------------------------------
CLASS GFEGRABARC
	DATA oContainer
	DATA oControl
	DATA nBarHeight
	DATA nTamMax
	DATA nValueMax
	DATA oBars
	DATA nCor
	DATA aValues
	DATA oFont
	DATA oLabels
	DATA oLabelsPorc
	DATA nTotalId
	/*
	  aValues[n][1]: Texto
	  aValues[n][2]: Valor (comparação)
	  aValues[n][3]: Porcentagem
	  aValues[n][4]: Tam X
	*/
	 
	// Declaração dos Métodos da Classe
	METHOD New(oOwner, nBarHeight, nTamMax) CONSTRUCTOR
	METHOD SetTotal(cTexto, nValor)
	METHOD AddSerie(cTexto, nValor)
	METHOD UpdateTotal(cTexto, nValor)
	METHOD UpdateSerie(nId, cTexto, nValor)
	METHOD Refresh()
	METHOD Clear()
	METHOD Build()
	METHOD Hide()
	METHOD Show()
	METHOD IsVisible()
ENDCLASS
 
// Criação do construtor, onde atribuimos os valores default// para as propriedades e retornamos Self
METHOD New(oOwner, nTamMax, nCor, nBarHeight) Class GFEGRABARC
	Default nTamMax    := 100
	Default nBarHeight := 12
	Default nCor 	   := RGB(167, 207, 252)
	
	Self:nTamMax  	  := nTamMax
	Self:nBarHeight := nBarHeight
	Self:nCor 		  := nCor
   	Self:oBars       := {}
	Self:aValues     := {}
	Self:nValueMax  := 0
	Self:oFont       := TFont():New('Arial',,-12,.T.)
	
	//::oContainer := tPanel():New(nLeft,nTop,,oOwner,,,,CLR_YELLOW,CLR_RED,nWidth,nHeight)
	Self:oContainer := tPanel():New(0, 0,, oOwner,,,, , , 0, 0)
	Self:oContainer:Align := CONTROL_ALIGN_ALLCLIENT
Return Self

METHOD Hide() Class GFEGRABARC
	Self:oContainer:Hide()
Return Nil

METHOD Show() Class GFEGRABARC
	Self:oContainer:Show()
Return Nil

METHOD IsVisible() Class GFEGRABARC

Return Self:oContainer:lVisibleControl

METHOD SetTotal(cTexto, nValor) Class GFEGRABARC
	Self:nValueMax := nValor
	aADD(Self:aValues, {cTexto, nValor, 0, 1})
	Self:nTotalId := Len(Self:aValues)
Return Nil

METHOD AddSerie(cTexto, nValor) Class GFEGRABARC
	aADD(Self:aValues, {cTexto, nValor, 0, 1})
Return Nil

METHOD UpdateSerie(nId, cTexto, nValor) Class GFEGRABARC
	If cTexto != Nil
		Self:aValues[nId][1] := cTexto
	EndIf
	
	If nValor != Nil
		Self:aValues[nId][2] := nValor
	EndIf
Return Nil

METHOD UpdateTotal(cTexto, nValor) Class GFEGRABARC
	Self:nValueMax := nValor
	Self:UpdateSerie(Self:nTotalId, cTexto, nValor)
Return Nil


METHOD Clear() Class GFEGRABARC
	Local nCount
	
	For nCount := 1 To Len(Self:aValues)
		Self:oBars[nCount]:Free()
		Self:oLabels[nCount]:Free()
		Self:oLabelsPorc[nCount]:Free()
	Next
	
	Self:aValues 	 := {}
	Self:oBars 	 	 := {}
	Self:oLabels 	 := {}
	Self:oLabelsPorc := {}
Return Nil

METHOD Refresh() Class GFEGRABARC
	Local nCount
	Local nPorc
	Local nTam
	
	// Calcula o valor máximo caso não seja informado no SetTotal
	If Self:nValueMax == 0
		For nCount := 1 To Len(Self:aValues)
			If Self:aValues[nCount][2] > Self:nValueMax
				Self:nValueMax := Self:aValues[nCount][2]
			EndIf
		Next
	EndIf
	
	// Atualiza os valores do array aValues
	For nCount := 1 To Len(Self:aValues)
		nPorc := Round((100 * Self:aValues[nCount][2]) / Self:nValueMax,2)
		nTam  := (nPorc * Self:nTamMax) / 100
		If (nTam < 1) 
			nTam := 1
		EndIf
		
		If (nTam > Self:nTamMax)
			nTam := Self:nTamMax
		EndIf
		
		Self:aValues[nCount][3] := nPorc
		Self:aValues[nCount][4] := nTam
	Next
	
	// Atualiza os valores e as dimensões das barras de acordo com a porcentagem
	For nCount := 1 To Len(Self:aValues)
		Self:oLabels[nCount]:SetText(Self:aValues[nCount][1])
		Self:oLabelsPorc[nCount]:SetText(AllTrim(Str(Self:aValues[nCount][3])) + "%")
		Self:oLabelsPorc[nCount]:Move(Self:oLabelsPorc[nCount]:nTop, Self:aValues[nCount][4] + 4, Self:oLabelsPorc[nCount]:nWidth, Self:oLabelsPorc[nCount]:nHeight)
		Self:oLabelsPorc[nCount]:cTooltip := AllTrim(Str(Self:aValues[nCount][2]))
		Self:oBars[nCount]:Move(Self:oBars[nCount]:nTop, Self:oBars[nCount]:nLeft, Self:aValues[nCount][4], Self:oBars[nCount]:nHeight)
		
		If (Self:aValues[nCount][3] <= 100)
			Self:oBars[nCount]:SetColor(,Self:nCor)
		Else
			Self:oBars[nCount]:SetColor(,RGB(200, 65, 65))
		EndIf
	Next	
Return Nil

METHOD Build() Class GFEGRABARC
   	Local nSep := 4
   	Local nFontSize := (Self:oFont:nHeight * -1) - 4
	Local nCount
	
	Self:oBars 	 	 := {}
	Self:oLabels 	 := {}
	Self:oLabelsPorc := {}
	
	For nCount := 1 To Len(Self:aValues)
		nTamY := 3 + (Self:nBarHeight + nSep + nFontSize) * (nCount - 1)
		
		aADD(Self:oLabels, TSay():New(nTamY, 0, &("{|| '" + Self:aValues[nCount][1] + "'}"), Self:oContainer,, Self:oFont,.F.,.F.,.F.,.T.,0,0))
		aADD(Self:oBars, tPanel():New(nTamY + nFontSize, 0,,Self:oContainer,,,,Self:nCor,Self:nCor, 1, Self:nBarHeight))
		aADD(Self:oLabelsPorc, TSay():New(nTamY + (nFontSize / 2) + (Self:nBarHeight / 2), Self:aValues[nCount][4] + 4, {|| "0%" + Space(10) }, Self:oContainer,, Self:oFont,.F.,.F.,.F.,.T.,0,0))
	Next
	
	Self:Refresh()
Return Nil