#INCLUDE "TOTVS.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "mdtm005.ch"

//----------------------------------------------------------------------------------------------------------------
//----------------------------------------------------------------------------------------------------------------
//----------------------------------------------------------------------------------------------------------------
//  _______           _______  _       _________ _______             _______  _______  _______  _______  ___   ---
// |  ____ \|\     /||  ____ \| \    /|\__   __/|  ___  |           |  ____ \/ ___   |/ ___   |/ ___   |/   \  ---
// | |    \/| \   / || |    \/|  \  | |   | |   | |   | |           | |    \/\/   |  |\/   |  |\/   |  |\/| |  ---
// | |__    | |   | || |__    |   \ | |   | |   | |   | |   _____   | |_____     /   |    /   |    /   )  | |  ---
// |  __|   | |   | ||  __)   | |\ \| |   | |   | |   | |  |_____|  |_____  |  _/   /   _/   /   _/   /   | |  ---
// | |       \ \_/ / | |      | | \   |   | |   | |   | |                 | | /   _/   /   _/   /   _/    | |  ---
// | |____/\  \   /  | |____/\| |  \  |   | |   | |___| |           /\____| ||   |__/\|   |__/\|   |__/\__| |_ ---
// |_______/   \_/   |_______/|/    \_|   |_|   |_______|           \_______|\_______/\_______/\_______/\____/ ---
//----------------------------------------------------------------------------------------------------------------
//----------------------------------------------------------------------------------------------------------------
//----------------------------------------------------------------------------------------------------------------
//----------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} MDTM005
Rotina de Envio de Eventos - Exame Toxicológico do Motorista Profissional (S-2221)
Realiza o envio das informações de Exames Toxicológicos para o TAF

@author Luis Fellipy Bett
@since 18/09/2018

@param lValida, indica se é avaliação ou envio
@param aMensagem, preencher com mensagens de retorno da validação
@param nOperacao, indica o tipo de operação do cadastro
@param cChave, chave do registro na RJE

@return cRetorno, caso seja envio do evento retorna o xml
/*/
//----------------------------------------------------------------------------------------------------
Function MDTM005( lValida, aMensagem, nOperacao, cChave )

	Local aAreaTM5	 	:= TM5->( GetArea() )
	Local cRetorno		:= ''

	Private cNumMat		:= ''
	Private cCpfTrab	:= ''
	Private cNisTrab	:= ''
	Private cMatricula	:= ''
	Private cCodCateg	:= ''
	Private dDtAdm		:= CtoD( '  /  /    ' )
	Private cCCusto		:= ''

	Private dDtExame	:= CtoD( '  /  /    ' )
	Private dDtDem		:= CtoD( '  /  /    ' )
	Private cCnpjLab	:= ''
	Private cCodSeq		:= ''
	Private cNmMed		:= ''
	Private cNrCRM		:= ''
	Private cUFCRM		:= ''
	Private cIndRecusa	:= ''

	Default aMensagem	:= {}
	Default cChave 		:= ''
	Default lValida		:= .F.
	Default nOperacao	:= 3

	DbSelectArea( 'TM0' )
	( 'TM0' )->( DbSetOrder( 1 ) )
	If ( 'TM0' )->( DbSeek( xFilial( 'TM0' ) + M->TM5_NUMFIC ) )

		cNumMat := TM0->TM0_MAT

		DbSelectArea( 'SRA' )
		( 'SRA' )->( DbSetOrder( 1 ) )
		If ( 'SRA' )->( DbSeek( xFilial( 'SRA' ) + cNumMat ) )

			cCpfTrab 	:= SRA->RA_CIC
			cNisTrab	:= SRA->RA_PIS
			cMatricula	:= SRA->RA_CODUNIC
			cCodCateg	:= SRA->RA_CATEFD
			dDtAdm		:= SRA->RA_ADMISSA
			cCCusto		:= SRA->RA_CC
			dDtDem		:= SRA->RA_DEMISSA

		EndIf

	EndIf

	dDtExame	:= If( Empty( M->TM5_DTRESU ), M->TM5_DTPROG, M->TM5_DTRESU )
	cCnpjLab	:= Posicione( "SA2", 1, xFilial( "SA2" ) + M->TM5_FORNEC + M->TM5_LOJA, "A2_CGC" )
	cCodSeq		:= SubStr( M->TM5_CODDET, 1, 11 )

	DbSelectArea( 'TNP' )
	( 'TNP' )->( DbSetOrder( 1 ) )
	If ( 'TNP' )->( DbSeek( xFilial( 'TNP' ) + M->TM5_USUARI ) )

		cNmMed	:= TNP->TNP_NOME
		cNrCRM	:= TNP->TNP_NUMENT
		cUFCRM	:= TNP->TNP_UF

	EndIf

	cIndRecusa := IIf( "RECUSA" $ M->TM5_CODDET, "S", "N" )

	If cIndRecusa == "S"
		dDtExame := dDtDem
	EndIf

	cNmMed := MDTSubTxt( AllTrim( cNmMed ), '1' )

	If lValida
		fInconsis( @aMensagem )
	Else
		cRetorno := fCarrTox( nOperacao, cChave )
		// aErros := TafPrepInt( cEmpAnt, cFilAnt, cXml,, "1", "S2221" )
	EndIf

	RestArea( aAreaTM5 )

Return cRetorno

//---------------------------------------------------------------------
/*/{Protheus.doc} fCarrTox
Carrega os exames toxicológicos

@author Luis Fellipy Bett
@since 30/08/2018

@param nOperacao, operação a ser realizada
@param cChave, chave do registro na RJE

@return cXml, estrutura XML a ser enviada para o TAF
/*/
//---------------------------------------------------------------------
Static Function fCarrTox( nOperacao, cChave )

	Local cXml := ''

	Default nOperacao := 3

	MDTGerCabc( @cXml, 'S2221', cValToChar( nOperacao ), cChave )

			cXml += '<ideVinculo>'
				cXml += '<cpfTrab>' + cCpfTrab + '</cpfTrab>'
				cXml +=	'<matricula>' + cMatricula + '</matricula>'
			cXml += '</ideVinculo>'
			cXml += '<toxicologico>'
				cXml += '<dtExame>' + MDTAjsData( dDtExame ) + '</dtExame>'
				cXml += '<cnpjLab>' + cCnpjLab + '</cnpjLab>'
				cXml += '<codSeqExame>' + cCodSeq + '</codSeqExame>'
				cXml += '<nmMed>' + cNmMed + '</nmMed>'
				cXml += '<nrCRM>' + SubStr( cNrCRM, 1, 10 ) + '</nrCRM>'
				cXml += '<ufCRM>' + cUFCRM + '</ufCRM>'
			cXml += '</toxicologico>'
		cXml += '</evtToxic>'
	cXml += '</eSocial>'

Return cXml

//---------------------------------------------------------------------
/*/{Protheus.doc} fInconsis
Valida se há inconsistências na geração do evento

@author Luis Fellipy Bett
@since 30/08/2018

@param aMensagem, recebe os logs

/*/
//---------------------------------------------------------------------
Static Function fInconsis( aMensagem )

	Local cStrFunc		:= ""

	cStrFunc	:= STR0014 + ": " + AllTrim( cNumMat ) + " - " + AllTrim( Posicione( "SRA", 1, xFilial( "SRA" ) + cNumMat, "RA_NOME" ) ) // "Funcionário"
	cDtImp   	:= DToS( dDtEsoc )
	cDtImp   	:= " (" + SubStr( cDtImp, 7, 2 ) + "/" + SubStr( cDtImp, 5, 2 ) + "/" + SubStr( cDtImp, 1, 4 ) + ")"

	If Empty( cCpfTrab ) .Or. !ChkCpf( cCpfTrab )
		aAdd( aMensagem, STR0019 + ': ' + STR0020 ) // "C.P.F." // "Deve ser um número de CPF válido"
		aAdd( aMensagem, '' )
	EndIf

	If Empty( cCnpjLab ) .Or. !CGC( cCnpjLab )
		aAdd( aMensagem, STR0028 + ': ' + STR0029 ) // "CNPJ Laboratório Resp. Toxicológico" // "Deve ser um número de CNPJ válido"
		aAdd( aMensagem, '' )
	EndIf

	If Empty( cNrCRM )
		aAdd( aMensagem, STR0031 + ': ' + STR0034 ) // "Número Inscrição Med. Resp. Toxicológico" // "Em Branco"
		aAdd( aMensagem, '' )
	EndIf

	If Empty( cUFCRM )
		aAdd( aMensagem, STR0032 + ': ' + STR0034 ) // "UF Med. Resp. Toxicológico" // "Em Branco"
		aAdd( aMensagem, '' )
	EndIf

	If !IsAlpha( SubStr( cCodSeq, 1, 1 ) ) .Or. !IsAlpha( SubStr( cCodSeq, 2, 1 ) ) .Or. !IsNumeric( SubStr( cCodSeq, 3 ) )
		aAdd( aMensagem, STR0006 + ': ' + AllTrim( M->TM5_EXAME ) + ' / ' + STR0033 + ': ' + cCodSeq ) // "Laudo Exame"
		aAdd( aMensagem, STR0035 + STR0036 ) // "Validação: " // "Deve possuir 11 caracteres, composto por duas letras mais nove algarismos"
	EndIf

Return
