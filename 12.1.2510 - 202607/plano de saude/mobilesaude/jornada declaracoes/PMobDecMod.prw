#Include "PROtHEUS.CH"
#Include "PMOBDECMOD.CH"

//-------------------------------------------------------------------
/*/{Protheus.doc} PMobDecMod
Classe responsavel por retornar uma lista de declarações do beneficiário

@author Rafael Soares da Silva
@version Protheus 12
@since 19/01/2022
/*/
//------------------------------------------------------------------- 
Class PMobDecMod From PMobJornMod

	// Propriedades obrigatorias nas API da Mobile
	Data message
	Data oParametersMap
	Data oConfig
	//Dados de Entrada
	Data lMultiContract 	
	Data lLoginByCPF		
	Data cChaveBeneficiario
	Data cMatriculaContrato	
	Data cIdDeclaracao
	//Dados de Saída
	Data declaracoesMap
	Data PdfDeclaracaoMap
	Data cBinaryFile
	Data cURLFile
	
	Method New() CONSTRUCTOR 

	// Metodos das regras de negocio da Classe
	Method declaracoes()
	Method listaDeclaracoes(aMatricula)
	Method getdeclaracoes()
	
	Method pdfDeclaracao()
	Method geraPdf()
	Method pdfDecIRPF(cAno, cMatricula, cPath)
	Method pdfDecCQ(cAno, cMatricula, cPath)
	Method getPdfdeclaracao()

	// Métodos de apoio para a regra de negocio
	Method getAnosDeclaracao(cMatricula, nAnoDeclaracao)
	Method getNomeDeclaracao(cDeclaracao)
	Method getTiposDeclaracao(cDeclaracao)
	Method getMessage()
	
EndClass


//-------------------------------------------------------------------
/*/{Protheus.doc} New
Método Construtor da Classe

@author Rafael Soares da Silva
@version Protheus 12
@since 19/01/2022
/*/
//------------------------------------------------------------------- 
Method New(oparametersMap) Class PMobDecMod

	_Super:New()

	Self:oParametersMap	:= oParametersMap	
	Self:message := ""
	Self:oConfig := Nil

	Self:declaracoesMap	:= JsonObject():New() 
	Self:declaracoesMap["tipoDeclaracoes"]	:= {} 
	
	Self:PdfDeclaracaoMap := JsonObject():New()
	Self:cBinaryFile := ""
	Self:cURLFile := ""
	
	Self:lMultiContract := .F.
	Self:lLoginByCPF := .F.
	Self:cChaveBeneficiario	:= ""
	Self:cMatriculaContrato := ""
	Self:cIdDeclaracao := ""

Return


//-------------------------------------------------------------------
/*/{Protheus.doc} declaracoes
Retornar uma lista de declarações do beneficiário

@author Rafael Soares da Silva
@version Protheus 12
@since 19/01/2022
/*/
//------------------------------------------------------------------- 
Method declaracoes() Class PMobDecMod
	
	Local aMatricula := {}
	Local lRetorno := .F.
		
	//Dados recebidos do json
	Self:lMultiContract := Self:oParametersMap["multiContract"]
	Self:lLoginByCPF := Self:oParametersMap["chaveBeneficiarioTipo"] == "CPF"
	Self:cChaveBeneficiario	:= Self:oParametersMap["chaveBeneficiario"]
	Self:cMatriculaContrato := Self:oParametersMap["matriculaContrato"]

	aMatricula := _Super:GetMatriculas(Self:cMatriculaContrato, .F.)
		
	If Len(aMatricula) > 0 .And. !Empty(aMatricula[1][1])
		lRetorno := Self:listaDeclaracoes(aMatricula)
	Else
		Self:message := STR0001 // "Nenhum beneficiário encontrado para os parâmetros informados."
	EndIf	
	
Return lRetorno


//-------------------------------------------------------------------
/*/{Protheus.doc} listaDeclaracoes
Retorna o Map da lista de declarações

@author Rafael Soares da Silva
@version Protheus 12
@since 26/01/2022
/*/
//------------------------------------------------------------------- 
Method listaDeclaracoes(aMatricula) Class PMobDecMod

	Local lRetorno := .F.
	Local nX := 0
	Local nZ := 0
	Local nW := 0
	Local nDeclaracao := 0
	Local ntipoDeclaracao := 0
	Local cMatricula := ""
	Local cContrato := ""
	Local nAnoDeclaracao := Self:oConfig["declaracoes"]["yearListDec"]
	Local cDeclaracao := Self:oConfig["declaracoes"]["activeDeclaration"]
	Local aDeclaracoes := Self:getTiposDeclaracao(cDeclaracao)

	Self:message := IIf(Len(aDeclaracoes) == 0, STR0007, Self:message) // "Nenhuma declaração configurada pela operadora."

	If Empty(Self:message)
		For nW := 1 to Len(aMatricula)

			cContrato := aMatricula[nW][1] + aMatricula[nW][2] + aMatricula[nW][3]
			cMatricula := aMatricula[nW][1] + aMatricula[nW][2] + aMatricula[nW][3] + aMatricula[nW][4] + aMatricula[nW][5]
			
			For nX := 1 to Len(aDeclaracoes)

				aAnos := Self:getAnosDeclaracao(cMatricula, nAnoDeclaracao)

				aAdd(Self:declaracoesMap["tipoDeclaracoes"], JsonObject():New())
				ntipoDeclaracao := Len(Self:declaracoesMap["tipoDeclaracoes"])

				Self:declaracoesMap["tipoDeclaracoes"][ntipoDeclaracao]["nome"] := Self:getNomeDeclaracao(aDeclaracoes[nX])
				Self:declaracoesMap["tipoDeclaracoes"][ntipoDeclaracao]["declaracoes"] := {}

				For nZ := 1 to Len(aAnos)

					aAdd(Self:declaracoesMap["tipoDeclaracoes"][ntipoDeclaracao]["declaracoes"], JsonObject():New())
					nDeclaracao := Len(Self:declaracoesMap["tipoDeclaracoes"][ntipoDeclaracao]["declaracoes"])

					Self:declaracoesMap["tipoDeclaracoes"][ntipoDeclaracao]["declaracoes"][nDeclaracao]["nome"] := _Super:SetAtributo(aAnos[nZ]+"-"+cMatricula, "String")
					Self:declaracoesMap["tipoDeclaracoes"][ntipoDeclaracao]["declaracoes"][nDeclaracao]["idDeclaracao"] := _Super:SetAtributo(aAnos[nZ] + ":"+aDeclaracoes[nX]+":" + cMatricula, "String")
					Self:declaracoesMap["tipoDeclaracoes"][ntipoDeclaracao]["declaracoes"][nDeclaracao]["codigoContrato"]	:= _Super:SetAtributo(cContrato, "String")
					
				Next nZ
				
			Next nX
		Next nW

		lRetorno := .T.
	EndIf

Return lRetorno


//-------------------------------------------------------------------
/*/{Protheus.doc} getdeclaracoes
Retorna o Map da lista de declarações

@author Rafael Soares da Silva
@version Protheus 12
@since 19/01/2022
/*/
//------------------------------------------------------------------- 
Method getDeclaracoes() Class PMobDecMod
Return(Self:declaracoesMap)


//-------------------------------------------------------------------
/*/{Protheus.doc} pdfDeclaracao
Este método irá retornar uma URL ou um campo BASE64 contendo o arquivo 
PDF da declaração.

@author Rafael Soares da Silva
@version Protheus 12
@since 02/02/2022
/*/
//------------------------------------------------------------------- 
Method pdfDeclaracao() Class PMobDecMod
	
	Local lRet := .F.

	//Dados recebidos do json
	Self:cIdDeclaracao := Self:oParametersMap["idDeclaracao"]

	If Self:geraPdf()		
		Self:PdfDeclaracaoMap["base64"] := Self:cBinaryFile
		Self:PdfDeclaracaoMap["url"] := Self:cURLFile

		lRet := .T.
	EndIf

Return lRet


//-------------------------------------------------------------------
/*/{Protheus.doc} geraPdf
Realiza a geração do arquivo PDF da Declaracao

@author Rafael Soares da Silva
@version Protheus 12
@since 02/02/2022
/*/
//------------------------------------------------------------------- 
Method geraPdf() Class PMobDecMod

	Local lRet := .F.
	Local lUrlPDF := Self:oConfig["financeiro"]["pdfMode"] == "1"
	Local lBase64PDF := Self:oConfig["financeiro"]["pdfMode"] == "2"
	Local cAno := ""
	Local cDeclaracao := ""
	Local cMatricula := ""
	Local cNameArquivo := ""
	Local cPath := PLSMUDSIS(getWebDir() + getSkinPls() + "\relatorios\")
	Local cEnderecoPDF := Self:oConfig["security"]["pdfUrl"]
	Local aIdDeclaracao := {}

	aIdDeclaracao := StrtokArr(Self:cIdDeclaracao, ":")

	If Len(aIdDeclaracao) >= 3

		cAno := aIdDeclaracao[1]
		cDeclaracao := aIdDeclaracao[2]
		cMatricula := aIdDeclaracao[3]

		Do Case
			Case cDeclaracao == "IRPF"
				cNameArquivo := Self:pdfDecIRPF(cAno, cMatricula, cPath)
			
			Case cDeclaracao == "CQ"
				cNameArquivo := Self:pdfDecCQ(cAno, cMatricula, cPath)
		EndCase

		If Empty(Self:message)
			// Validar geração do arquivo
			Self:message := IIf(Empty(cNameArquivo), STR0002, Self:message) // "Não foi possível gerar o PDF." 
			Self:message := IIf(!File(cPath+cNameArquivo) .And. Empty(Self:message), STR0003, Self:message) //"Não foi possível localizar o PDF"

			If Empty(Self:message)
				Self:cURLFile := IIf(lUrlPDF, Lower(cEnderecoPDF+cNameArquivo), "")
				Self:cBinaryFile := IIf(lBase64PDF, PMobFile64(cPath+cNameArquivo), "")
				lRet := .T.
			EndIf
		EndIf

	Else
		Self:message := STR0004 // "Chave de Declaração inválida."
	EndIf

Return lRet


//-------------------------------------------------------------------
/*/{Protheus.doc} pdfDecIRPF
Gera o PDF da declaração do Imposto de Renda

@author Rafael Soares da Silva
@version Protheus 12
@since 03/02/2022
/*/
//------------------------------------------------------------------- 
Method pdfDecIRPF(cAno, cMatricula, cPath) Class PMobDecMod

	Local cNameArquivo := ""
	Local cChaveFamilia := ""
	Local nTamChaveFamilia := TamSx3("BA1_CODINT")[1] + TamSx3("BA1_CODEMP")[1] + TamSx3("BA1_MATRIC")[1]
	Local aRetorno := {}

	cChaveFamilia := Substr(cMatricula, 1, nTamChaveFamilia)

	BA3->(DbSetOrder(1))
	If BA3->(MsSeek(xFilial("BA3")+cChaveFamilia))

		aRetorno := PLSR997(BA3->BA3_CODINT, BA3->BA3_CODEMP, BA3->BA3_CODEMP, "", "ZZZZZZZZZZ", "", "ZZZZZZZZ", BA3->BA3_MATRIC, BA3->BA3_MATRIC, cAno, 1, .T., cPath)

		If ValType(aRetorno) == "A" .And. Len(aRetorno) >= 3 .And. aRetorno[1]
			cNameArquivo := aRetorno[3]
		Else			
			Self:message := STR0008 // "Não encontrado imposto de renda referente ano informado."
		EndIf
	EndIf
		
Return cNameArquivo


//-------------------------------------------------------------------
/*/{Protheus.doc} pdfDecCQ
Gera o PDF da declaração da Quitação Anual

@author Rafael Soares da Silva
@version Protheus 12
@since 03/02/2022
/*/
//------------------------------------------------------------------- 
Method pdfDecCQ(cAno, cMatricula, cPath) Class PMobDecMod

	Local nTamChaveFamilia := TamSx3("BA1_CODINT")[1] + TamSx3("BA1_CODEMP")[1] + TamSx3("BA1_MATRIC")[1]
	Local aDados := {}
	Local cNameArquivo := ""
	Local xRetorno := ""
	Local cChaveFamilia := ""

	Self:message := IIf(!ExistBlock("PLSQTDEB"), STR0009, Self:message) // "Funcionalidade não habilitada, entre em contato com a Operadora."

	If Empty(Self:message)

		cChaveFamilia := Substr(cMatricula, 1, nTamChaveFamilia)
		
		BA3->(DbSetOrder(1))
		If BA3->(MsSeek(xFilial("BA3")+cChaveFamilia))

			aAdd(aDados, BA3->BA3_TIPOUS) // Tipo Contrato
			aAdd(aDados, BA3->BA3_CODEMP) // Empresa
			aAdd(aDados, BA3->BA3_CONEMP) // Contrato
			aAdd(aDados, BA3->BA3_SUBCON) // SubContrato
			aAdd(aDados, BA3->(BA3_CODINT+BA3_CODEMP+BA3_MATRIC+BA3_CONEMP+BA3_VERCON+BA3_SUBCON+BA3_VERSUB)) // Chave
			aAdd(aDados, cAno) // Ano de Referencia

			xRetorno := A772Acao(aDados, .T., cPath)

			If ValType(xRetorno) == "A" .And. Len(xRetorno) >= 3 .And. xRetorno[1]
				cNameArquivo := xRetorno[3]
			Else
				Self:message := STR0010 // "Não encontrado carta de quitação referente ano informado."
			EndIf

		EndIf
	EndIf

Return cNameArquivo


//-------------------------------------------------------------------
/*/{Protheus.doc} getPdfdeclaracao
Retorna o Map do PDF da Declaracao

@author Rafael Soares da Silva
@version Protheus 12
@since 19/01/2022
/*/
//------------------------------------------------------------------- 
Method getPdfDeclaracao() Class PMobDecMod
Return(Self:PdfDeclaracaoMap)


//-------------------------------------------------------------------
/*/{Protheus.doc} getAnosDeclaracao
Retorno o quanto de anos que precisam ser listados para o beneficiário 

@author Rafael Soares / Vinicius Queiros
@version Protheus 12
@since 01/02/2022
/*/
//------------------------------------------------------------------- 
Method getAnosDeclaracao(cMatricula, nAnoDeclaracao) Class PMobDecMod

	Local aAnos := {}
	Local nX := 0
	Local nAnoAtual := Year(dDataBase)

	For nX := 1 to nAnoDeclaracao

		aAdd(aAnos, cValtoChar(nAnoAtual - nX))
	
	Next nX

Return aAnos

//-------------------------------------------------------------------
/*/{Protheus.doc} getNomeDeclaracao
Retorna o nome da declaração 

@author Rafael Soares / Vinicius Queiros
@version Protheus 12
@since 01/02/2022
/*/
//------------------------------------------------------------------- 
Method getNomeDeclaracao(cDeclaracao) Class PMobDecMod

	Local cNomeDeclaracao := ""

	Do Case
		Case cDeclaracao == "IRPF"
			cNomeDeclaracao := "Imposto de Renda"//STR0005 // "Imposto de Renda"
		
		Case cDeclaracao == "CQ"
			cNomeDeclaracao := "Carta de Quitação" //STR0006 // "Carta de Quitação"
	EndCase


Return cNomeDeclaracao


//-------------------------------------------------------------------
/*/{Protheus.doc} getTiposDeclaracao 
Retorna os tipos de declaração a ser utilizado na API

@author Vinicius Queiros
@version Protheus 12
@since 08/02/2022
/*/
//------------------------------------------------------------------- 
Method getTiposDeclaracao(cDeclaracao) Class PMobDecMod

	Local aDeclaracoes := {}

	If !Empty(cDeclaracao)

		Do Case
			Case cDeclaracao == "0" // Ambas
				aAdd(aDeclaracoes, "IRPF")
				aAdd(aDeclaracoes, "CQ")

			Case cDeclaracao == "1" // Imposto de Renda
				aAdd(aDeclaracoes, "IRPF")

			Case cDeclaracao == "2" // Carta de Quitação
				aAdd(aDeclaracoes, "CQ")

		EndCase
	EndIf

Return aDeclaracoes


//-------------------------------------------------------------------
/*/{Protheus.doc} getMessage
Retorna mensagens de erro dos métodos

@author Rafael Soares da Silva
@version Protheus 12
@since 19/01/2022
/*/
//------------------------------------------------------------------- 
Method getMessage() Class PMobDecMod
Return (Self:message)