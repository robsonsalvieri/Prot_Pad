#include 'protheus.ch'

Function TAFGRSA6(aFilial as Array, cDatIni as Char, cDatFim as Char, cCabecalho as Char)

	Local cTxtSys  	as char
	Local cStrTxt   as char

	Local nHandle   as numeric
	Local nLinha    as numeric
	Local nPos 		as numeric
	Local nTotal    as numeric

	Local aAnexo as array
	Local nTotal    := 0

	Begin Sequence

		cTxtSys  	:= CriaTrab( , .F. ) + ".TXT"
		nHandle   	:= MsFCreate( cTxtSys )
		cStrTxt		:= ""

		aAnexo := {}
		aAnexo := VlAjuApGRS(6, aFilial[1], aFilial[7], cDatIni, cDatFim, "00411")

		//======================A N E X O  VI ================================
		AADD(aTotAnexo, {"qtdAnexoVI", len(aAnexo)})

		If (len(aAnexo) > 0)

			nLinha := 1
			nSeqGiaRS++
			nQtdInic := (If ((len(aAnexo) > 32), 32, len(aAnexo)))

			cStrTxt += cCabecalho						             //Cabeçalho
			cStrTxt += StrZero(nSeqGiaRS,4)				             //Contador de Linha do Arquivo
			cStrTxt += "X06 "							             //Identificador do Registro - FIXO X07A
			cStrTxt += StrZero(nQtdInic, 2)							 //Qtd Linha

			For nPos := 1 To len(aAnexo)

				cStrTxt += StrZero( VAL(aAnexo[nPos,1]), 10  )
				cStrTxt += StrZero( VAL(aAnexo[nPos,2]), 3   )
				cStrTxt += StrZero( aAnexo[nPos,3] * 100, 13 )

				nTotal +=  aAnexo[nPos,3]

				If (nPos % 32 == 0)
					nSeqGiaRS++
					nLinha++
					cStrTxt += CRLF
					cStrTxt += cCabecalho						             //Cabeçalho
					cStrTxt += StrZero(nSeqGiaRS,4)				             //Contador de Linha do Arquivo
					cStrTxt += "X06 "							             //Identificador do Registro - FIXO X07A
					cStrTxt += (If ((len(aAnexo) - (32 * nLinha) > 0), "32", StrZero(len(aAnexo) - nPos, 2))) //Qtd Linha
				EndIf

			Next nPos
			cStrTxt += CRLF
		EndIf

	    AADD(aTotAnexo, {"AnexoVI_DebTransf", nTotal})

    	If  cStrTxt != ''
    		WrtStrTxt( nHandle, cStrTxt)
    		GerTxtGRS( nHandle, cTxtSys, aFilial[1] + "_X06")
    	EndIf

	    Recover
		lFound := .F.

	End Sequence

Return