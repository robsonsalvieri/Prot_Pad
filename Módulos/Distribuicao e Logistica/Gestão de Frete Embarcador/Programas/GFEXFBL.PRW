#include 'protheus.ch'

/*----------------------------------------------------------------------------
{Protheus.doc} GFEDefPes
Calcula Frete.
Uso: GFECLCFRT

@sample GFEDefPes()

@author João Leonardo Schmidt
@since 23/06/2025
@version 1.0
----------------------------------------------------------------------------*/
Function GFEDefPes()
    Local nX 	 	:= 0
    Local nY 	 	:= 0
	Local nZ		:= 0
	Local cAliasGU3 := ""
	Local nQtdCalc	:= 0
	Local nPesoReal := 0
	Local nPesoCub	:= 0
	Local nPesRCla	:= 0
	Local nPesCCla	:= 0
	Local cNrNota	:= ""
	
	oGFEXFBFLog:setTexto(CRLF + CRLF)

	oGFEXFBFLog:setTexto("	# Determinando o peso cubado para o cálculo..." + CRLF + CRLF)

	If GFXCP2610("GU3_DEFPES")
		oGFEXFBFLog:setTexto("		Percorrendo as unidades de cálculo..." + CRLF + CRLF)

		For nX := 1 To Len(aTRBTCF1)
			oGFEXFBFLog:setTexto("			Unidade de Cálculo: " + aTRBTCF1[nX][1] + CRLF)
			oGFEXFBFLog:setTexto("			Transportador: " + aTRBTCF1[nX][7] + CRLF)
			oGFEXFBFLog:setTexto("			Classificação: " + aTRBTCF1[nX][2] + CRLF)
			oGFEXFBFLog:setTexto("			Peso Real Atual: " + cValToChar(aTRBTCF1[nX][15]) + CRLF)
			oGFEXFBFLog:setTexto("			Peso Cubado Atual: " + cValToChar(aTRBTCF1[nX][16]) + CRLF)

			nQtdCalc := 0

			cAliasGU3 := GetNextAlias()

			BeginSQL Alias cAliasGU3
				SELECT GU3.GU3_DEFPES DEFPES
				FROM %Table:GU3% GU3
				WHERE GU3.GU3_FILIAL = %xFilial:GU3%
				AND GU3.GU3_CDEMIT = %Exp:aTRBTCF1[nX][7]%
				AND GU3.GU3_SIT = '1'
				AND GU3.%NotDel%
			EndSQL

			oGFEXFBFLog:setTexto("			Escopo para o peso cubado (GU3_DEFPES): ")

			If (cAliasGU3)->DEFPES == "2"
				oGFEXFBFLog:setTexto("Nota Fiscal " + CRLF + CRLF)

				For nY := 1 To Len(aTRBTRE1)
					If aTRBTRE1[nY][18] == aTRBTCF1[nX][1]
						nPesoReal 	:= 0
						nPesoCub	:= 0
						nPesRCla	:= 0
						nPesCCla	:= 0
						cNrNota		:= ""
												
						For nZ := 1 To Len(aTRBITE1)
							If aTRBITE1[nZ][1] + aTRBITE1[nZ][2] + aTRBITE1[nZ][3] + aTRBITE1[nZ][4] == ;
							   aTRBTRE1[nY][1] + aTRBTRE1[nY][2] + aTRBTRE1[nY][3] + aTRBTRE1[nY][4]

								nPesoReal 	:= nPesoReal + aTRBITE1[nZ][9] 
								nPesoCub	:= nPesoCub + aTRBITE1[nZ][10]
							EndIf

							If aTRBITE1[nZ][1] + aTRBITE1[nZ][2] + aTRBITE1[nZ][3] + aTRBITE1[nZ][4] + aTRBITE1[nZ][6] == ;
							   aTRBTRE1[nY][1] + aTRBTRE1[nY][2] + aTRBTRE1[nY][3] + aTRBTRE1[nY][4] + aTRBTCF1[nX][2]

								cNrNota := aTRBITE1[nZ][3]

								nPesRCla 	:= nPesRCla + aTRBITE1[nZ][9] 
								nPesCCla	:= nPesCCla + aTRBITE1[nZ][10]
							EndIf
						Next nZ

						oGFEXFBFLog:setTexto("			Novos Pesos calculados para a Nota Fiscal " + cNrNota + CRLF)
						oGFEXFBFLog:setTexto("			Peso Real: " + cValToChar(nPesoReal) + CRLF)
						oGFEXFBFLog:setTexto("			Peso Cubado: " + cValToChar(nPesoCub) + CRLF)

						If nPesoReal > nPesoCub
							oGFEXFBFLog:setTexto("			Peso Real Maior. Peso adicionado dessa classificação: " + cValToChar(nPesRCla) + CRLF + CRLF)

							nQtdCalc := nQtdCalc + nPesRCla
						Else
							oGFEXFBFLog:setTexto("			Peso Cubado Maior. Peso adicionado dessa classificação: " + cValToChar(nPesCCla) + CRLF + CRLF)

							nQtdCalc := nQtdCalc + nPesCCla
						EndIf
					EndIf					
				Next nY

				oGFEXFBFLog:setTexto("			Novo Peso definido para a unidade de Cálculo: " + cValToChar(nQtdCalc) + CRLF + CRLF)

				aTRBTCF1[nX][13] := nQtdCalc
			Else
				oGFEXFBFLog:setTexto("Classificação / Romaneio " + CRLF)
				oGFEXFBFLog:setTexto("			Mantido o peso para cálculo  " + CRLF + CRLF)		
			EndIf

			(cAliasGU3)->(dbCloseArea())
		Next nX		
	Else
		oGFEXFBFLog:setTexto("			Campo de Escopo de definição de peso não criado, mantido peso por Classificação / Romaneio " + CRLF)
		oGFEXFBFLog:setTexto("			Mantido o peso para cálculo  " + CRLF + CRLF)
	EndIf

Return
