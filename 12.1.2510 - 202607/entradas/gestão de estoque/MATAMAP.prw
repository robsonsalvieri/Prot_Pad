#include "Protheus.ch"

/*/{Protheus.doc} MATAMAP
    Nova rotina para geração do Mapa de Controle de Produtos Químicos conforme Portaria nº 240 de 12 de Março de 2019.
    A nova legislação entra em vigor em 01/09/2019 conforme Portaria nº 577 de 05 de Junho de 2019.
    @type  Function
    @author SQUAD Entradas
    @since 01/08/2019
    @version P12.1.25
    @see (http://www.in.gov.br/materia/-/asset_publisher/Kujrw0TZC2Mb/content/id/66952742/do1-2019-03-14-portaria-n-240-de-12-de-marco-de-2019-66952457)
/*/
Function MATAMAP(dDataDe, dDataAte, cArqDest, cDir, nProcFil,nAglutina,aFilCalNew) //Adicionado parametro nAglutina

	Local oMapasPF
	Local cGrupoDe := ""
	Local cGrupoAte := ""
	Local cProdDe := ""
	Local cProdAte := ""
	Local cFilBkp := ""
	Local cDeclMapas := ""
	Local nFil := 0
	Local lRet := .T.
	Local lFileOk := .F.
	Local lMAPPFTP := ExistBlock("MAPPFTP")
	Local aFilsCalc := {}//MatFilCalc(nProcFil == 1)
	Local lUCREPrdCt := .F.
	Local lTNFiltDtN := .T.

	//Incrementado para Aglutinação
	Local lAglutina	 := ( nAglutina == 1)
	Local cArqFinal  := ""
	Local nHandle 	 := 0
	Local nE,nX
	Local cCnpjBkp	:= ""

	Default aFilCalNew := {}
	
	// Decide a origem das filiais
	If ValType(aFilCalNew) == 'A' .and. Len(aFilCalNew) > 0
		aFilsCalc := aFilCalNew
	Else
		aFilsCalc := MatFilCalc(nProcFil == 1)
	EndIf

	If Empty(aFilsCalc)
		Return .F.
	EndIf

	If lRet .And. !Pergunte("MAPASV2", .T.)
		lRet := .F.
	EndIf

	cGrupoDe := mv_par01
	cGrupoAte := mv_par02
	cProdDe := mv_par03
	cProdAte := mv_par04
	cDeclMapas := mv_par05
	If !Empty(mv_par06)
		lUCREPrdCt := mv_par06 == 2
	EndIf
	If !Empty(mv_par07)
		lTNFiltDtN := mv_par07 == 1 //Filtro por data de emissão da NFC
	EndIf

	If lRet

		IF !lAglutina //Verifica se aglutina ou não.

			cFilBkp := cFilAnt

			For nFil := 1 to Len(aFilsCalc)

				If aFilsCalc[nFil][1]

					cFilAnt  := aFilsCalc[nFil][2]

					oMapasPF := MAPASPF():New(dDataDe, dDataAte, cGrupoDe, cGrupoAte, cProdDe, cProdAte, nProcFil, aFilsCalc[nFil][4], cDeclMapas, lUCREPrdCt, lTNFiltDtN)

					If !oMapasPF:lConfigOk
						Exit
					EndIf

					If lMAPPFTP
						ExecBlock("MAPPFTP",.F.,.F.,{oMapasPF:aTrab})
					EndIf

					lFileOk := oMapasPF:GeraTXT(cArqDest, cDir)

					oMapasPF:Destructor()

					FreeObj(oMapasPF)

					If !lFileOk
						Exit
					EndIf

				EndIf

			Next
			cFilAnt := cFilBkp
		Else
			cFilBkp := cFilAnt

			cArqFinal  := Alltrim(cDir)+Alltrim(cArqDest)
			nHandle 	 := FCreate(cArqFinal)

			//Tratamento de aglutinação, somente para filiais com o mesmo CNPJ e IE
			For nE := 1 To Len(aFilsCalc)
				cCnpjBkp := aFilsCalc[nE][4]

				// Percorre o array novamente para comparar com os outros registros
				For nX := 1 To Len(aFilsCalc)
					// Evita comparar o mesmo índice
					If nX <> nE .And. aFilsCalc[nX][4] == cCnpjBkp
						aFilsCalc[nE][1] := .T.
					EndIf
				Next nX
			Next nE

			// Cria um único arquivo consolidado antes de começar
			For nFil := 1 To Len(aFilsCalc)

				If aFilsCalc[nFil][1]

					cFilAnt := aFilsCalc[nFil][2]

					oMapasPF := MAPASPF():New(dDataDe, dDataAte, cGrupoDe, cGrupoAte, cProdDe, cProdAte, ;
						nProcFil, aFilsCalc[nFil][4], cDeclMapas, lUCREPrdCt, lTNFiltDtN)

					If !oMapasPF:lConfigOk
						Exit
					EndIf

					// Escreve diretamente no mesmo arquivo
					lFileOk := oMapasPF:ProcAglt(nHandle)

					oMapasPF:Destructor()
					FreeObj(oMapasPF)

					If !lFileOk
						Exit
					EndIf
				EndIf
			Next

			// Fecha o arquivo consolidado
			FClose(nHandle)
			cFilAnt := cFilBkp

		Endif



	EndIf

Return (lRet)
