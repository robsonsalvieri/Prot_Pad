#INCLUDE 'totvs.ch'

//-------------------------------------------------------------------
/*{Protheus.doc} getStrutObj
@description Prepara a estrutura dos campos para o Objeto de negócios
@param aCpos1 array: Array com os campos do relatório
@param aCpos2 array: Array com os campos personalizados do relatório
			  array[1,1]: Nome do Campo
			  array[1,2]: Tipo de dados do campo
			  array[1,3]: Titulo de tela do campo
	    lRetUnder, lógico, .T. retira o underline do campos
		                   .F. não retira (default)
@author Leonardo Pereira
@since 27/07/2023
@version 1.0
@Return array: Array com a estrutura dos campos
*/
//-------------------------------------------------------------------
Function getStrutObj( aCpos1, aCpos2, lRetUnder )

	Local aDeParaCpo as array
	Local aCpoTmp    as array

	Local cCampo     as character
	Local cCpoQry    as character
	Local cTipR      as character

	Local nPos       as numeric
	Local nC         as numeric
	Local cIdioma    as character
	Local cTitulo    as character

	Default aCpos1 := { }
	Default aCpos2 := { }
	Default lRetUnder := .F. 

	aDeParaCpo := { { 'C', 'string' }, { 'D', 'date' }, { 'N', 'number' }, { 'L', 'boolean' }, { 'M', 'string' } }
	aCpoTmp    := { }

	cCampo := ''
	cCpoQry := ''
	cTipR := ''

	nPos := 0
	nC := 0

	For nC := 1 To Len( aCpos1 )
		cCampo := ''
		cCpoQry := aCpos1[nC]
		nPos := ( aT( '.', aCpos1[nC] ) + 1 )

		cCampo := IIf ( nPos > 0 , SubStr( cCpoQry, nPos ), cCpoQry)

		cTipo := GetSX3Cache( cCampo, 'X3_TIPO')

		If ( ( nPos := aScan( aDeParaCpo, { | c | c[01] = cTipo } ) ) > 0 )
			cTipR := aDeParaCpo[nPos, 02]
		EndIf 

		// idioma
		cIdioma := lower(LEFT(FwRetIdiom(),2))
		cTitulo := IIF(cIdioma == "pt","X3_TITULO",IIF(cIdioma == "es","X3_TITSPA","X3_TITENG"))

		// Adiciona campos que não existem na tabela (virtuais ou calculados)
		nPos := aScan( aCpos2, { | x | AllTrim( x[1] ) == cCampo } )
		If ( nPos > 0 )		    
			aAdd( aCpoTmp, { IIf(lRetUnder,StrTran(aCpos2[nPos, 1],"_",""),aCpos2[nPos, 1]), aCpos2[nPos, 2], aCpos2[nPos, 3], aCpos2[nPos, 4], aCpos2[nPos, 1] } )
		Else
			aAdd( aCpoTmp, { IIf(lRetUnder,StrTran(cCampo,"_",""),cCampo), FWSX3Util():GetDescription( cCampo ), cTipR, GetSx3Cache( cCampo, cTitulo ), cCampo } )
		EndIf
	Next

Return( aCpoTmp )

//-------------------------------------------------------------------
/*{Protheus.doc} getParamToArray
@description Converte string com parametros do objeto de negocios em array
@param cFiltro string: String com os filtros/parametros informados no SMART VIEW
@author Leonardo Pereira
@since 17/08/2023
@version 1.0
@Return array: Array com a estrutura dos parametros informados no SMART VIEW
*/
//-------------------------------------------------------------------
Function getParamToArr( cFiltro )

	Local cStr as string
	Local cTexto as string

	Local nCount as numeric
	Local nX as numeric

	Local aParam as array
	Local aFiltro as array

	Default cFiltro := ''

	nCount := 0
	nX := 0

	cStr := ''
	cTexto := ''

	aParam := { }
	aFiltro := { }

	For nX := 1 To Len( cFiltro )
		cStr := SubStr( cFiltro, nX, 1 )
		If Empty( cStr )
			nCount++
			aAdd( aParam, cTexto )
			cTexto := ''
			IIF( nCount == 4, aAdd( aFiltro, aParam ),.T.)
			IIF( nCount == 4, nCount := 0, .T.)
			IIF( nCount == 4, aParam := { },.T.)
		ElseIf ( cStr == '(' ) .Or. ( cStr == ')' )
			Loop
		Else
			cTexto += cStr
		EndIf
	End

	If !Empty( cTexto )
		aAdd( aParam, cTexto )
		aAdd( aFiltro, aParam )
	EndIf

Return( aFiltro )

//-------------------------------------------------------------------
/*{Protheus.doc} getArrayToParam
@description Converte array com parametros do objeto de negocios em string
@param aFiltro array: Array com os filtros/parametros
@author Leonardo Pereira
@since 17/08/2023
@version 1.0
@Return string: String com a estrutura dos parametros informados
*/
//-------------------------------------------------------------------
Function getArrToParam( aFiltro )

	Local cFiltro as string

	Local nX as numeric
	Local nY as numeric

	Default aFiltro := { }

	cFiltro := ''

	nX := 0
	nY := 0

	// Verifica a estrutura do array de parametros
	For nX := 1 To Len( aFiltro )
		If ( Len( aFiltro[nX] ) == 3 )
			// Adiciona operador SQL
			aAdd( aFiltro[nX], 'AND' )
		EndIf
		If ( nX == Len( aFiltro ) )
			// Exclui o operador SQL desnecessario
			aDel( aFiltro[nX], 4 )

			// Redimensiona o Array
			aSize( aFiltro[nX], ( Len( aFiltro[nX] ) - 1 ) )
		EndIf
	Next

	cFiltro += '( '
	For nX := 1 To Len( aFiltro )
		cFiltro += '( '
		For nY := 1 To Len( aFiltro[nX] )
			IIf( nY == 4,cFiltro += ' ',.T. )
			cFiltro += aFiltro[nX, nY] + Space( 1 )
			If ( nY == 3 )
				cFiltro += ') '
			EndIf
		Next
	Next
	cFiltro += ' )'

Return( cFiltro )

//-------------------------------------------------------------------
/*{Protheus.doc} getCpoUser
@description Coleta os campos incluidos pelo usuario
@param aCustomFields array: Array com os campos incluidos pelo usuário
@author Leonardo Pereira
@since 16/11/2023
@version 1.0
@Return string: String com a lista de campos da tabela informada
*/
//-------------------------------------------------------------------
Function getCpoUser( aCustomFields, cPrefixo, cSufixo, cSeparador )

	Local cRet as character

	Local nX as numeric

	Default aCustomFields := { }

	Default cPrefixo := ''

	Default cSufixo := ''

	Default cSeparador := ''

	cRet := ''

	nX := 0

	For nX := 1 To Len( aCustomFields )
		If ( SubStr( aCustomFields[nX, 1], 1, Len( cSufixo ) ) == cSufixo )
			cRet += IIF(Empty( cPrefixo ),aCustomFields[nX, 1] + cSeparador,cPrefixo + '.' + aCustomFields[nX, 1] + cSeparador)
		EndIf
	Next

Return( cRet )

//-------------------------------------------------------------------
/*{Protheus.doc} CpoText
@description Coleta os textos dos campos de status, tipo, situação dos contratos
@cCampo: Caracter: Nome do campo
@ccChave: Caracter: Chave a ser pesquisado o texto
@author Leonardo Pereira
@since 09/01/2024
@version 1.0
@Return string: String com o texto correspondente a chave informada
*/
//-------------------------------------------------------------------
Function getCpoText( cCampo, cChave )

	Local aSx3Box := {}
	Local cRet    := ''
	Local nQual   := 0
	Local nPosBox := 0

	Default cCampo := ''
	Default cChave := ''

	aSx3Box := RetSX3Box( Posicione( 'SX3', 2, cCampo, 'X3CBox( )' ),,, 1 )
	nQual := IIf( cCampo == 'CN9_SITUAC', 1, 2 )
	nPosBox := aScan( aSx3Box, { | aBox | aBox[nQual] = cChave } )
	cRet := IIf( nPosBox > 0, Upper( AllTrim( aSx3Box[nPosBox][3] ) ), 'Indeterminado' )

Return( cRet )


//-------------------------------------------------------------------
/*{Protheus.doc} MIAvisoSX1
@description Exibe tela com aviso do DT no TDN quando não existe SX1
@cGrupo: Caracter: nome do grupo de perguntas
@cURL: Caracter: URL com o DT
@author Marcelo Hruschka
@since 08/12/2025
@version 1.0
@Return string: nil
*/
//-------------------------------------------------------------------
Function MIAvisoSX1(cGrupo,cURL)
	local oSay1    as object
	local oSay2    as object
	local oSay3    as object
	local oSay4    as object
	local oSay5    as object
	local oModal   as object
	Local cMsg1    as character
	Local cMsg2    as character
	Local cMsg3    as character
	Local cMsg4    as character
	Local cMsg5    as character
	Local cRelease as character

	cRelease := GetRPORelease()

	oModal := FWDialogModal():New()
	oModal:SetCloseButton( .F. )
	oModal:SetEscClose( .F. )
	oModal:setTitle("Falta de Preguntas - TOTVS Linha Protheus")

	//define a altura e largura da janela em pixel
	oModal:setSize(180, 250)

	oModal:createDialog()

	oModal:AddButton( "OK", {||oModal:DeActivate()}, "OK", , .T., .F., .T., )

	oContainer := TPanel():New( ,,, oModal:getPanelMain() )
	oContainer:Align := CONTROL_ALIGN_ALLCLIENT
	cEndWeb := cURL

	cMsg1 := "El grupo de preguntas " + cGrupo + " no existe en su ambiente. "
	cMsg5 := "Por favor registrelo de acuerdo al documento"
	cMsg2 := cEndWeb
	cMsg4 := "Para mayor información, favor de contactar al administrador del sistema o a su ESN TOTVS"

	oSay1 := TSay():New( 10,10,{||cMsg1 },oContainer,,,,,,.T.,,,220,20,,,,,,.T.)
	oSay5 := TSay():New( 20,10,{||cMsg5 },oContainer,,,,,,.T.,,,220,20,,,,,,.T.)

	oSay2 := TSay():New( 40,10,{||cMsg2 },oContainer,,,,,,.T.,,,220,20,,,,,,.T.)

	cMsg3 := ""
	If ! Empty(cEndWeb)
		cMsg3 += "<b><a target='_blank' href='"+cEndWeb+"'> "
		cMsg3 += Alltrim("clique aqui")
		cMsg3 += " </a></b>."
		cMsg3 += "<span style='font-family: Verdana; font-size: 12px; color: #565759;' >" + ' ' +"</span>"
		oSay3 := TSay():New(60,10,{||cMsg3},oContainer,,,,,,.T.,,,220,20,,,,,,.T.)
		oSay3:bLClicked := {|| MsgRun( "Abrindo o link... Aguarde...", "URL",{|| ShellExecute("open",cEndWeb,"","",1) } ) } //
	EndIf
	oSay4 := TSay():New( 80,10,{||cMsg4 },oContainer,,,,,,.T.,,,220,20,,,,,,.T.)

	oModal:Activate()

Return
