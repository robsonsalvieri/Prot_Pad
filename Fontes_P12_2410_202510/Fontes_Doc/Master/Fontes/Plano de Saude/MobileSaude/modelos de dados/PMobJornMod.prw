#Include "PROTHEUS.CH"

//-------------------------------------------------------------------
/*/{Protheus.doc} PMobJornMod
Classe com métodos genéricos para serem utilizados nas classes das 
jornadas da mobile, como herença.

@author Vinicius Queiros Teixeira
@version Protheus 12
@since 02/02/2022
/*/
//------------------------------------------------------------------- 
Class PMobJornMod

	Data cTipoTitular
	Data lGravaLog 
	Data cArquivoLog

	Method New() CONSTRUCTOR 

	Method GetCPFMatriculas(lLoginByCPF, cChaveBeneficiario, lTitularFamilia)
	Method GetMatriculas(cChaveBeneficiario, lTitularFamilia)
	Method BreakAutorizacao(cChaveAutorizacao)
	Method SetAtributo(xValor, cTipo)
	Method GetDeParaCampo(cCampoExterno, cCampoInterno, cValorExterno, cValorInterno)
	Method DownloadArquivos(aDownload)
	Method AnexarArquivos(aDownload, cAlias, cChaveDocument)
	Method AddCritica(oForm, nCod, cDescricao, cOrigem)
	Method ImpLogApi(cMensagem, lTime)
	
EndClass


//-------------------------------------------------------------------
/*/{Protheus.doc} New
Método Construtor da Classe

@author Vinicius Queiros Teixeira
@version Protheus 12
@since 21/01/2022
/*/
//------------------------------------------------------------------- 
Method New() Class PMobJornMod

	Self:cTipoTitular := GetNewPar("MV_PLCDTIT", "T")
	Self:lGravaLog := .F. 
	Self:cArquivoLog := ""

Return Self


//-------------------------------------------------------------------
/*/{Protheus.doc} GetCPFMatriculas
Retorna as matriculas das familias vinculadas ao CPF informado.
Se o beneficiário solicitado for o titular, será retornado a chave da
familia.

@author Vinicius Queiros Teixeira
@version Protheus 12
@since 24/01/2022
/*/
//------------------------------------------------------------------- 
Method GetCPFMatriculas(lLoginByCPF, cChaveBeneficiario, lTitularFamilia) Class PMobJornMod
	
	Local cQuery := ""
	Local cAliasTemp := ""
	Local cCpf := ""
	Local cCodInt := ""
	Local cCodEmp := ""
	Local cMatric := ""
	Local cTipReg := ""
	Local cDigito := ""
	Local aMatriculas := {{"", "", "", "", ""}}
	Local aAreaBA1 := BA1->(GetArea())

	Default lLoginByCPF := .F.
	Default cChaveBeneficiario := ""
	Default lTitularFamilia := .F.

	If lLoginByCPF
		cCpf := cChaveBeneficiario
	Else
		BA1->(DbSetOrder(2))
		If BA1->(MsSeek(xFilial("BA1")+cChaveBeneficiario))
			cCpf := Alltrim(BA1->BA1_CPFUSR)
		EndIf
	EndIf

	cQuery += " SELECT BA1_CODINT, BA1_CODEMP, BA1_MATRIC, BA1_TIPREG, BA1_DIGITO, BA1_TIPUSU "
	cQUery += " FROM "+RetSqlName("BA1")+" BA1 "
	cQuery += " WHERE BA1.BA1_FILIAL = '"+xFilial("BA1")+"' "
	cQuery += "   AND BA1.BA1_CPFUSR = '"+cCpf+"' "
	cQuery += "   AND BA1.D_E_L_E_T_ = ' ' "

	cAliasTemp := GetNextAlias()
	dbUseArea(.T., "TOPCONN", TcGenQry(,, cQuery), cAliasTemp, .T., .F.)
    
	If !(cAliasTemp)->(Eof())
		aMatriculas := {}

		while !(cAliasTemp)->(Eof())

			cCodInt := (cAliasTemp)->BA1_CODINT
			cCodEmp := (cAliasTemp)->BA1_CODEMP
			cMatric := (cAliasTemp)->BA1_MATRIC
			cTipReg := IIf(lTitularFamilia .And. (Self:cTipoTitular == (cAliasTemp)->BA1_TIPUSU), "", (cAliasTemp)->BA1_TIPREG)
			cDigito := IIf(lTitularFamilia .And. (Self:cTipoTitular == (cAliasTemp)->BA1_TIPUSU), "", (cAliasTemp)->BA1_DIGITO)

			aAdd(aMatriculas, {cCodInt, cCodEmp, cMatric, cTipReg, cDigito})

			(cAliasTemp)->(DbSkip())
		EndDo
	EndIf

	(cAliasTemp)->(DbCloseArea())

	RestArea(aAreaBA1)

Return aMatriculas


//-------------------------------------------------------------------
/*/{Protheus.doc} GetMatriculas
Retorna a matricula do beneficiário. 
Se o beneficiário solicitado for o titular, será retornado a chave da
familia.

@author Vinicius Queiros Teixeira
@version Protheus 12
@since 24/01/2022
/*/
//------------------------------------------------------------------- 
Method GetMatriculas(cChaveBeneficiario, lTitularFamilia) Class PMobJornMod

	Local aMatriculas := {{"", "", "", "", ""}}
	Local aAreaBA1 := BA1->(GetArea())

	Default cChaveBeneficiario := ""
	Default lTitularFamilia := .F.

	BA1->(DbSetOrder(2))
	If BA1->(MsSeek(xFilial("BA1")+cChaveBeneficiario))
		aMatriculas := {}
		
		while !BA1->(Eof()) .And. BA1->(BA1_FILIAL+BA1_CODINT+BA1_CODEMP+BA1_MATRIC+BA1_TIPREG+BA1_DIGITO) == xFilial("BA1")+cChaveBeneficiario
		
			cCodInt := BA1->BA1_CODINT
			cCodEmp := BA1->BA1_CODEMP
			cMatric := BA1->BA1_MATRIC
			cTipReg := IIf(lTitularFamilia .And. (Self:cTipoTitular == BA1->BA1_TIPUSU), "", BA1->BA1_TIPREG)
			cDigito := IIf(lTitularFamilia .And. (Self:cTipoTitular == BA1->BA1_TIPUSU), "", BA1->BA1_DIGITO)

			aAdd(aMatriculas, {cCodInt, cCodEmp, cMatric, cTipReg, cDigito})

			BA1->(DbSkip())
		EndDo	
	EndIf

	RestArea(aAreaBA1)

Return aMatriculas


//-------------------------------------------------------------------
/*/{Protheus.doc} BreakAutorizacao
Quebra a string da chave da autorizacao em campos: Operadora, Ano, Mes
e Numero.

@author Vinicius Queiros Teixeira
@version Protheus 12
@since 24/01/2022
/*/
//------------------------------------------------------------------- 
Method BreakAutorizacao(cChaveAutorizacao) Class PMobJornMod 

	Local nTamOPEMOV := TamSx3("BEA_OPEMOV")[1]
	Local nTamANOAUT := TamSx3("BEA_ANOAUT")[1]
	Local nTamMESAUT := TamSx3("BEA_MESAUT")[1]
	Local nTamNUMAUT := TamSx3("BEA_NUMAUT")[1]
	Local aPosOperadora := {1, nTamOPEMOV}
	Local aPosAno := {aPosOperadora[2] + 1, nTamANOAUT}
	Local aPosMes := {aPosAno[1] + aPosAno[2], nTamMESAUT}
	Local aPosNumero := {aPosMes[1] + aPosMes[2], nTamNUMAUT}
	Local oGuiaAutorizacao := JsonObject():New()

	Default cChaveAutorizacao := ""

	If Len(cChaveAutorizacao) >= (nTamOPEMOV + nTamANOAUT + nTamMESAUT + nTamNUMAUT)

		oGuiaAutorizacao["operadora"] := Substr(cChaveAutorizacao, aPosOperadora[1], aPosOperadora[2])
		oGuiaAutorizacao["ano"] := Substr(cChaveAutorizacao, aPosAno[1], aPosAno[2])
		oGuiaAutorizacao["mes"] := Substr(cChaveAutorizacao, aPosMes[1], aPosMes[2])
		oGuiaAutorizacao["numero"] := Substr(cChaveAutorizacao, aPosNumero[1], aPosNumero[2])

	EndIf

Return oGuiaAutorizacao


//-----------------------------------------------------------------
/*/{Protheus.doc} SetAtributo
Set Atributo no JSON

@author Vinicius Queiros Teixeira
@version Protheus 12
@since 24/01/2022
/*/
//-----------------------------------------------------------------
Method SetAtributo(xValor, cTipo) Class PMobJornMod
    
    Local xRetorno

    Default xValor := ""
    Default cTipo := "String"

	xRetorno := IIf(ValType(xValor) == "C", Alltrim(xValor), xValor)

    If !Empty(xValor)
        Do Case
            Case cTipo == "Integer" .And. ValType(xValor) == "C"
                xRetorno := Val(xValor)

			Case cTipo == "Date" .And. ValType(xValor) == "C" .And. Len(xValor) == 8
                xRetorno := Transform(xValor, "@R 9999-99-99")
			
			Case cTipo == "Float" .And. ValType(xValor) == "N"
                xRetorno := Round(xValor, 2)
			
			Case cTipo == "String" .And. ValType(xValor) == "N"
                xRetorno := cValToChar(xValor)
        EndCase	    
    EndIf

Return xRetorno


//-------------------------------------------------------------------
/*/{Protheus.doc} GetDeParaCampo
Retorna os dados de de/para do campo

@author Vinicius Queiros Teixeira
@version Protheus 12
@since 18/03/2022
/*/
//------------------------------------------------------------------- 
Method GetDeParaCampo(cCampoExterno, cCampoInterno, cValorExterno, cValorInterno, cTipo) Class PMobJornMod

	Local cReferencia := "PMOBATUCADMOD"
	Local cAliasTemp := GetNextAlias()
	Local cQuery := ""
	Local oDados := JsonObject():New()

	Default cCampoExterno := ""
	Default cCampoInterno := ""
	Default cValorExterno := ""
	Default cValorInterno := ""
	Default cTipo := ""

	oDados["status"] := .F.
	oDados["dados"] := JsonObject():New()

	cQuery := " SELECT B7V.B7V_REFERE, B7V.B7V_EXCAMP, B7V.B7V_INCAMP, B7V.B7V_TIPO, B7V.B7V_EXVALO, B7V.B7V_INVALO, B7V.B7V_URLVAL, B7V.B7V_ATIVO" 
	cQuery += " FROM "+RetSQLName("B7V")+" B7V " 
	cQuery += " WHERE B7V.B7V_FILIAL = '"+xFilial("B7V")+"' " 
	cQuery += "   AND B7V.B7V_REFERE = '"+cReferencia+"' " 	
	
	If !Empty(cCampoExterno)
		cQuery += "   AND B7V.B7V_EXCAMP = '"+cCampoExterno+"' " 
	EndIf	

	If !Empty(cCampoInterno)
		cQuery += "   AND B7V.B7V_INCAMP = '"+cCampoInterno+"' " 	
	EndIf

	If !Empty(cValorExterno)
		cQuery += "   AND B7V.B7V_EXVALO = '"+cValorExterno+"' " 
	EndIf

	If !Empty(cValorInterno)	
		cQuery += "   AND B7V.B7V_INVALO = '"+cValorInterno+"' " 	
	EndIf

	If !Empty(cTipo)	
		cQuery += "   AND B7V.B7V_TIPO = '"+cTipo+"' " 	
	EndIf

	cQuery += "   AND B7V.D_E_L_E_T_ = ' ' " 

	dbUseArea(.T., "TOPCONN", TcGenQry(,, cQuery), cAliasTemp, .T., .F.)

	If !(cAliasTemp)->(Eof())

		oDados["status"] := .T.
		oDados["dados"]["referencia"] := Alltrim((cAliasTemp)->B7V_REFERE)
		oDados["dados"]["campoExterno"] := Alltrim((cAliasTemp)->B7V_EXCAMP)
		oDados["dados"]["campoInterno"] := Alltrim((cAliasTemp)->B7V_INCAMP)
		oDados["dados"]["valorExterno"] := Alltrim((cAliasTemp)->B7V_EXVALO)
		oDados["dados"]["valorInterno"] := Alltrim((cAliasTemp)->B7V_INVALO)
		oDados["dados"]["tipo"] := Alltrim((cAliasTemp)->B7V_TIPO)
		oDados["dados"]["url"] := Alltrim((cAliasTemp)->B7V_URLVAL)
		oDados["dados"]["ativo"] := Alltrim((cAliasTemp)->B7V_ATIVO)

	EndIf

	(cAliasTemp)->(DbCloseArea())

Return oDados


//-------------------------------------------------------------------
/*/{Protheus.doc} DownloadArquivos
Realiza o download dos arquivos recebidos

@author Vinicius Queiros Teixeira
@version Protheus 12
@since 17/03/2022
/*/
//------------------------------------------------------------------- 
Method DownloadArquivos(aDownload) Class PMobJornMod

	Local lDownload := .T.
	Local nX := 0
	Local cNomeArquivo := ""
	Local cURLDownload := ""
	Local cExtensao := ""
	Local cError := ""
	Local nStatusCode := 0
	Local nCodError := 0
	Local lWrite := .F.
	Local cPathWeb := GetNewPar("MV_PLURDOW", "")
	
	Default aDownload := {}
	Default cLocalFile := ""

	For nX := 1 To Len(aDownload)

		cURLDownload := aDownload[nX][1]
		cNomeArquivo := aDownload[nX][2]

		splitPath(cURLDownload, Nil, Nil, Nil, @cExtensao)

		If At("?", cExtensao) > 0
			cExtensao := Substr(cExtensao, 1, At("?", cExtensao)-1)
		EndIf

		If Empty(cPathWeb)
			cPathWeb := PLSMUDSIS(GetWebDir()+GetSkinPls()+"\relatorios\")
		EndIf

		If !File(cPathWeb+cNomeArquivo+cExtensao)
	
			lWrite := MemoWrite(cPathWeb+cNomeArquivo+cExtensao, HttpGet(cURLDownload))

			nStatusCode := HTTPGetStatus(@cError)
			
			If !lWrite
				nCodError := FError()
			EndIf

			If nStatusCode == 200 .And. File(cPathWeb+cNomeArquivo+cExtensao)
				aDownload[nX][3] := cPathWeb+cNomeArquivo+cExtensao
			Else
				lDownload := .F.
				Exit
			EndIf
		Else
			aDownload[nX][3] := cPathWeb+cNomeArquivo+cExtensao	
		EndIf

	Next nX

Return lDownload


//-------------------------------------------------------------------
/*/{Protheus.doc} AnexarArquivos
Anexa os arquivos no protocolo - Banco de conhecimento

@author Vinicius Queiros Teixeira
@version Protheus 12
@since 17/03/2022
/*/
//------------------------------------------------------------------- 
Method AnexarArquivos(aDownload, cAlias, cChaveDocument) Class PMobJornMod

	Local nX := 0
	Local lAnexo := .F.

	Default aDownload := {}
	Default cAlias := ""
	Default cChaveDocument := ""

	If !Empty(cAlias) .And. !Empty(cChaveDocument)
		For nX := 1 To Len(aDownload)

			PLSINCONH(aDownload[nX][3], "BBA", cChaveDocument, .T.)

			fErase(aDownload[nX][3])
			lAnexo := .T.
		Next nX
	EndIf

Return lAnexo


//-------------------------------------------------------------------
/*/{Protheus.doc} AddCritica
Adiciona critica ao Json informado

@author Vinicius Queiros Teixeira
@version Protheus 12
@since 10/03/2022
/*/
//------------------------------------------------------------------- 
Method AddCritica(oForm, nCod, cDescricao, cOrigem) Class PMobJornMod

	Local nAddCritica := 0

	aAdd(oForm["critica"], JsonObject():New())
	nAddCritica := Len(oForm["critica"])

	oForm["critica"][nAddCritica]["cod"] := nCod
	oForm["critica"][nAddCritica]["descricao"] := cDescricao
	oForm["critica"][nAddCritica]["origem"] := cOrigem
	oForm["critica"][nAddCritica]["trace"] := ""

Return oForm


//-------------------------------------------------------------------
/*/{Protheus.doc} ImpLogApi
Imprime Log da API

@author Vinicius Queiros Teixeira
@version Protheus 12
@since 22/06/2022
/*/
//------------------------------------------------------------------- 
Method ImpLogApi(cMensagem, lTime) Class PMobJornMod

    Default cMensagem := ""
    Default lTime := .T.

    If Self:lGravaLog .And. !Empty(Self:cArquivoLog)	
		
		If lTime 
			PlsLogFil("["+Time()+"]"+cMensagem, Self:cArquivoLog)
		Else
			PlsLogFil(cMensagem, Self:cArquivoLog)
		EndIf
    
    EndIf

Return