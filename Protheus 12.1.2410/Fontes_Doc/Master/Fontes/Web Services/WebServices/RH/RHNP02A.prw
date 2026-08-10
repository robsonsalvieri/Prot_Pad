#INCLUDE "TOTVS.CH"
#INCLUDE "APWEBSRV.CH"
#INCLUDE "RESTFUL.CH"

#INCLUDE "RHNP02.CH"


/*/{Protheus.doc} getProfReqRH3
Recebe Empresa, Filial e matrícula de um funcionário
Devolve todas as solicitações de alteração salarial
no formato profileRequestsResponse
@type		Function
@author		Alberto Ortiz
@since		18/10/2022
@param      cEmp      - Empresa do funcionário
            cFil      - Filial do funcionário.
            cCod      - Matrícula do funcionário.
			nCount    - Controle de paginação.
			nIniCount - Controle de paginação.
			nFimCount - Controle de paginação.
@return		aReturn, array com todas as solicitações de 
            alteração de cadastro no formato 
			profileRequestsResponse.
/*/
Function getProfReqRH3(cEmp, cBranch, cMat, nCount, nIniCount, nFimCount)

	Local aReturn  := {}

	Local cQryRH3  := GetNextAlias()
	Local cTabRH3  := ""

	Local oCampos  := JsonObject():New()

	DEFAULT cEmp      := cEmpAnt
	DEFAULT cBranch   := ""
	DEFAULT cMat      := ""
	DEFAULT nCount    := 0
	DEFAULT nIniCount := 1
	DEFAULT nFimCount := 10	

	cTabRH3  := "%" + RetFullName("RH3", cEmp) + "%"

	BeginSql alias cQryRH3
		SELECT
			RH3.RH3_CODIGO,
			RH3.RH3_FILINI,
			RH3.RH3_EMPINI,
			RH3.RH3_MATINI,
			RH3.RH3_FILIAL,
			RH3.RH3_DTSOLI,
			RH3.RH3_MAT,
			RH3.RH3_STATUS,
			RH3.RH3_EMP
		FROM  
			%exp:cTabRH3% RH3
		WHERE   
			RH3.RH3_TIPO = '2' AND
			RH3.RH3_FILIAL = %Exp:cBranch% AND
			RH3.RH3_MAT = %Exp:cMat% AND
			RH3.%notDel%
		ORDER BY RH3_DTSOLI DESC
	EndSql

	While (cQryRH3)->(!Eof())
		nCount++
		If( nCount >= nIniCount .And. nCount <= nFimCount )
			oCampos         := JsonObject():New()

			oCampos["id"]                  := (cQryRH3)->RH3_FILIAL +"|"+ (cQryRH3)->RH3_MAT +"|"+ (cQryRH3)->RH3_EMP +"|"+ (cQryRH3)->RH3_CODIGO
			oCampos["date"]                := AllTrim(formatGMT( (cQryRH3)->RH3_DTSOLI, .T. ))
			oCampos["changesDescription"]  := fGetAgrupador((cQryRH3)->RH3_FILIAL, (cQryRH3)->RH3_CODIGO)
			oCampos["responsable"]         := fGetRANome((cQryRH3)->RH3_FILINI, (cQryRH3)->RH3_MATINI, (cQryRH3)->RH3_EMPINI)
			oCampos["justify"]             := AllTrim(getRGKJustify((cQryRH3)->RH3_FILIAL, (cQryRH3)->RH3_CODIGO, , .T.))
			oCampos["status"]              := If( (cQryRH3)->RH3_STATUS=='2', "approved", If((cQryRH3)->RH3_STATUS=='3', 'rejected', 'pending') )
			oCampos["statusLabel"]         := fStatusLabel( (cQryRH3)->RH3_STATUS )
			oCampos["canDelete"]	       := (cQryRH3)->RH3_STATUS == "4"

			aAdd(aReturn, oCampos)
		Else 
			If nCount >= nFimCount
				Exit
			EndIf
		EndIf

		(cQryRH3)->(DbSkip())
	EndDo

	(cQryRH3)->( DBCloseArea() )

Return(aReturn)

/*/{Protheus.doc} fGetAgrupador
Verifica quais campos da alteração de dados cadastrais
foram alterados, classifica em grupos, e retorna uma string
com todos os grupos separados por vírgulas.
@type		Function
@author		Alberto Ortiz
@since		18/10/2022
@param      cBranch - Filial da solicitação.
            cCodigo - Código da solicitação.
@return		cReturn, string com os grupos dos campos alterados
            separados por vírgula.
/*/

Function fGetAgrupador(cBranch, cCodigo)
	
	Local aCposRH4          := {}

	Local cReturn    := ""
	Local cAgrup     := ""
	Local cEndereco  := "RA_PAISEXT|RA_LOGRTP|RA_LOGRDSC|RA_COMPLEM|RA_LOGRNUM|RA_CEP|RA_ESTADO|RA_BAIRRO|RA_CODMUN|RA_MUNICIP|RA_CODMUNN"
	Local cEmail     := "RA_EMAIL|RA_EMAIL2"
	Local cTelefone  := "RA_DDDFONE|RA_TELEFON|RA_DDDCELU|RA_NUMCELU"
	Local cCNH       := "RA_HABILIT|RA_CNHORG|RA_CATCNH|RA_DTEMCNH|RA_DTVCCNH|RA_UFCNH"
	Local cRne       := "RA_RNE|RA_RNEORG|RA_RNEDEXP|RA_CASADBR|RA_FILHOBR|RA_DATCHEG|RA_CLASEST"
	Local cNacion    := "RA_NACIONC|RA_CPAISOR"
	Local cDefic     := "RA_PORTDEF|RA_OBSDEFI"
	Local cEstCivil  := "RA_ESTCIVI"
	Local cEscol     := "RA_GRINRAI"
	Local cAposent   := "RA_EAPOSEN"
	Local cRegProg   := "RA_CODIGO|RA_OCEMIS|RA_OCDTEXP|RA_OCDTVAL"
	Local cCTPS      := "RA_NUMCP|RA_SERCP|RA_UFCP"
	Local cRegCivil  := "RA_NUMRIC|RA_EMISRIC|RA_UFRIC|RA_CDMURIC|RA_DEXPRIC"
	Local cDepend    := "RB_NOME|RB_DTNASC|RB_SEXO|RB_GRAUPAR|RB_TPDEP|RB_TIPSF|RB_TIPIR|RB_LOCNASC|RB_CARTORI|RB_NREGCAR|RB_NUMLIVR|RB_NUMFOLH|RB_DTENTRA|RB_DTBAIXA|RB_NUMAT|RB_CIC|"
	Local cJuridico  := "RA_NJUD14"

	Local nCpos      := 0 
	
	DEFAULT cBranch  := ""
	DEFAULT cCodigo  := ""

	aCposRH4 := fGetRH4Cpos(cBranch, cCodigo)
	If Len(aCposRH4) > 0
		For nCpos := 1 To Len(aCposRH4)
			// Construção do agrupador, string com grupos de alteração separado por vírgulas.
			cAgrup += If(aCposRH4[nCpos,1] $ cEndereco .And. !(EncodeUTF8(STR0019) $ cAgrup), EncodeUTF8(STR0019) + ", ", "") //Endereço, 
			cAgrup += If(aCposRH4[nCpos,1] $ cEmail    .And. !(EncodeUTF8(STR0020) $ cAgrup), EncodeUTF8(STR0020) + ", ", "") //Email, 
			cAgrup += If(aCposRH4[nCpos,1] $ cTelefone .And. !(EncodeUTF8(STR0021) $ cAgrup), EncodeUTF8(STR0021) + ", ", "") //Telefone, 
			cAgrup += If(aCposRH4[nCpos,1] $ cCNH      .And. !(EncodeUTF8(STR0022) $ cAgrup), EncodeUTF8(STR0022) + ", ", "") //CNH, 
			cAgrup += If(aCposRH4[nCpos,1] $ cRne      .And. !(EncodeUTF8(STR0023) $ cAgrup), EncodeUTF8(STR0023) + ", ", "") //RNE,
			cAgrup += If(aCposRH4[nCpos,1] $ cNacion   .And. !(EncodeUTF8(STR0024) $ cAgrup), EncodeUTF8(STR0024) + ", ", "") //Nacionalidade, 
			cAgrup += If(aCposRH4[nCpos,1] $ cDefic    .And. !(EncodeUTF8(STR0025) $ cAgrup), EncodeUTF8(STR0025) + ", ", "") //Deficiência, 
			cAgrup += If(aCposRH4[nCpos,1] $ cEstCivil .And. !(EncodeUTF8(STR0026) $ cAgrup), EncodeUTF8(STR0026) + ", ", "") //Estado civil, 
			cAgrup += If(aCposRH4[nCpos,1] $ cEscol    .And. !(EncodeUTF8(STR0027) $ cAgrup), EncodeUTF8(STR0027) + ", ", "") //Escolaridade, 
			cAgrup += If(aCposRH4[nCpos,1] $ cAposent  .And. !(EncodeUTF8(STR0028) $ cAgrup), EncodeUTF8(STR0028) + ", ", "") //Aposentadoria, 
			cAgrup += If(aCposRH4[nCpos,1] $ cRegProg  .And. !(EncodeUTF8(STR0029) $ cAgrup), EncodeUTF8(STR0029) + ", ", "") //Registro Profissional,
			cAgrup += If(aCposRH4[nCpos,1] $ cCTPS     .And. !(EncodeUTF8(STR0030) $ cAgrup), EncodeUTF8(STR0030) + ", ", "") //CTPS, 
			cAgrup += If(aCposRH4[nCpos,1] $ cRegCivil .And. !(EncodeUTF8(STR0031) $ cAgrup), EncodeUTF8(STR0031) + ", ", "") //Registro de identificação civil,
			cAgrup += If(aCposRH4[nCpos,1] $ cDepend   .And. !(EncodeUTF8(STR0032) $ cAgrup), EncodeUTF8(STR0032) + ", ", "") //Dependentes,
			cAgrup += If(aCposRH4[nCpos,1] $ cJuridico .And. !(EncodeUTF8(STR0033) $ cAgrup), EncodeUTF8(STR0033) + ", ", "") //Jurídico,
		Next nCpos

		//Remove a última vírgula
		cAgrup := LEFT(cAgrup, LEN(cAgrup) - 2)
	EndIf

	cReturn := cAgrup

Return cReturn

/*/{Protheus.doc} DelRH3RH4
Excluir registro da RH3 e registros da RH4
referentes a solicitação de alteração
Só permite a exclusão se o RH3_STATUS = '4'
@type		Function
@author		Alberto Ortiz
@since		24/10/2022
@param      cFil - Filial da solicitação.
            cRH3Cod - Código da solicitação.
            lContinua - Caso consiga excluir .T., caso contrário .F.
@return		.T.
/*/
Function DelRH3RH4(cFil, cRH3Cod, lContinua)

	Local cKeyRH3     := ""
	Local cKeyRH4     := ""

	DEFAULT cFil      := ""
	DEFAULT cRH3Cod   := ""
	DEFAULT lContinua := .T.

	cKeyRH3  := cFil + cRH3Cod

	DBSelectArea("RH3")
	DBSetOrder(1)
   	
	If RH3->(dbSeek(cKeyRH3) )
		If RH3->RH3_STATUS == "4"

            cKeyRH4 := RH3->RH3_FILIAL + RH3->RH3_CODIGO

			RecLock("RH3", .F.)
			RH3->(dbDelete())
   			RH3->(MsUnlock())

			DBSelectArea("RH4")
			DBSetOrder(1)

			If RH4->( dbSeek(cKeyRH4) )
				While !Eof() .And. RH4->(RH4_FILIAL+RH4_CODIGO) == cKeyRH4
					RecLock("RH4",.F.)
					RH4->(dbDelete())
					RH4->(MsUnlock())
					RH4->(dBSkip())
				EndDo	
			EndIf

		Else
			lContinua := .F.
		EndIf
	EndIf	

Return (.T.)

/*/{Protheus.doc} DelRGKRDY
Excluir registro da RGK e registros da RDY
@type		Function
@author		Alberto Ortiz
@since		24/10/2022
@param      cFil - Filial da solicitação.
            cRGKMat - Matrícula do solicitante.
            cRGKCod - Código da RGK
@return		.T.
/*/
Function DelRGKRDY(cFil, cRGKMat, cRGKCod)

	Local cKeyRGK   := ""
	Local cKeyRDY   := ""
	Local cKeyRDX	:= ""
	Local lRet      := .T.
	Local lExist	:= ChkFile("RDX")

	DEFAULT cFil    := ""
	DEFAULT cRGKCod := ""

	cKeyRGK	:= cFil + cRGKMat + cRGKCod

	DBSelectArea("RGK")
	DBSetOrder(1)
   	
	If RGK->( dbSeek(cKeyRGK) )
		While !Eof() .And. RGK->(RGK_FILIAL+RGK_MAT+RGK_CODIGO) == cKeyRGK
			cKeyRDY := xFilial("RDY", RGK->RGK_FILIAL) + RGK->RGK_CODCON
			cKeyRDX := xFilial("RDX", RGK->RGK_FILIAL) + RGK->RGK_CODCON
			//Exclui da RGK
			RecLock("RGK",.F.)
			RGK->(dbDelete())
			RGK->(MsUnlock())
			RGK->(dBSkip())

			DBSelectArea("RDY")
			DBSetOrder(1)

			If RDY->(dbSeek(cKeyRDY))
				//Exclui da RDY
				While !Eof() .And. RDY->(RDY_FILIAL+RDY_CHAVE) == cKeyRDY
					RecLock("RDY",.F.)
					RDY->(dbDelete())
					RDY->(MsUnlock())
					RDY->(dBSkip())
				EndDo
			EndIf

			If lExist
				DBSelectArea("RDX")
				DBSetOrder(1)
				If RDX->(dbSeek(cKeyRDX))
					//Exclui da RDY
					While !Eof() .And. RDX->(RDX_FILIAL+RDX_CHAVE) == cKeyRDX
						RecLock("RDX",.F.)
						RDX->(dbDelete())
						RDX->(MsUnlock())
						RDX->(dBSkip())
					EndDo
				EndIf
			EndIf
		EndDo
	EndIf

Return lRet

/*/{Protheus.doc} fCidades
	Retorna as cidades brasileiras, conforme o estado
	@type  Function
	@author Henrique Ferreira
	@since 21/11/2022
	@version version
	@param cBranchVld - Filial
		   cMatSRA	  - Matrícula
	       aQryParam  - Parametros utilizados
	@return oResponse - objeto Json para resposta
	/*/
Function fCidades( cBranchVld, cMatSRA, aQryParam )

Local oCidade   := NIL
Local oPais     := NIL
Local oEstado   := NIL
Local oRet      := NIL

Local lMorePage := .F.

Local nCount    := 0
Local nPage     := 1
Local nPageSize := 10
Local nRegIni   := 1
Local nRegFim   := 10

Local aCidades  := {}
Local aArea     := GetArea()
Local aEstado   := {}

Local cQuery   	:= GetNextAlias()
Local cEstId 	:= ""
Local cEstName  := EncodeUTF8( STR0040 ) // São Paulo
Local cCidade 	:= ""
Local cFiltro   := ""

Local nX      := 1
Local nLen    := Len( aQryParam )

//Posiciona SRA
dbSelectArea("SRA")
SRA->( dbSetOrder(1) )
If SRA->( dbSeek( cBranchVld + cMatSRA ) ) 
	If nLen > 0
		cEstId := If( !Empty( SRA->RA_ESTADO ), SRA->RA_ESTADO, "SP" )
		For nX := 1 To nLen
			Do Case
				Case Upper( aQryParam[nX,1] ) == "STATEID"
					cEstId  := AllTrim( Upper( aQryParam[nX,2] ) )
				Case Upper( aQryParam[nX,1] ) == "NAME"
					cCidade := AllTrim( Upper( aQryParam[nX,2] ) )
				Case Upper( aQryParam[nX,1] ) == "PAGE"
					nPage := Val( aQryParam[nX,2] )
				Case Upper( aQryParam[nX,1] ) == "PAGESIZE"
					nPageSize := Val( aQryParam[nX,2] )
			EndCase
		Next nX

		cFiltro := "%"
		If !Empty( cCidade )
			cFiltro += " AND CC2_MUN LIKE '%" + cCidade + "%'"
		EndIf
		cFiltro += "%"

		BEGINSQL ALIAS cQuery
			SELECT 
				CC2.CC2_CODMUN,
				CC2.CC2_MUN,
				CC2.CC2_EST
			FROM 
				%Table:CC2% CC2
			WHERE
				CC2.CC2_FILIAL = %exp:xFilial("CC2", cBranchVld )% 
				AND CC2.CC2_EST = %exp:cEstId% 
				AND CC2.%notDel% 
				%exp:cFiltro%
		ENDSQL

		If nPage == 1
			nRegIni := 1
			nRegFim := nPageSize
		Else
			nRegIni := ( nPageSize * ( nPage - 1 ) ) + 1
			nRegFim := ( nRegIni + nPageSize ) - 1
		EndIf

		While (cQuery)->(!Eof())
			
			nCount++
			If ( nCount >= nRegIni .And. nCount <= nRegFim )
				oCidade := JsonObject():New()
				oEstado := JsonObject():New()
				oPais   := JsonObject():New()

				oCidade["id"]   := AllTrim( (cQuery)->CC2_CODMUN )
				oCidade["name"] := AllTrim( (cQuery)->CC2_MUN )

				aEstado  := FWGetSX5("12", (cQuery)->CC2_EST )
				cEstName := If( Len( aEstado ) > 0, Upper( EncodeUTF8( aEstado[1,4]) ), Upper( cEstName )  ) 

				oEstado["id"]   := (cQuery)->CC2_EST
				oEstado["name"] := AllTrim( cEstName )
				oEstado["abbr"] := (cQuery)->CC2_EST

				oPais["id"]   := "01058"
				oPais["name"] := Upper( EncodeUTF8( STR0041 ) )
				oPais["abbr"] := "BR"

				oEstado["country"]   := oPais
				oCidade["state"]     := oEstado
				oCidade["country"]   := oPais

				aAdd(aCidades, oCidade)
			ElseIf nCount >= nRegFim
				lMorePage := .T.
				Exit
			EndIf
			(cQuery)->(dbSkip())
		EndDo
		(cQuery)->(dbCloseArea())
	EndIf
EndIf

RestArea(aArea)

FreeObj(oCidade)
FreeObj(oEstado)
FreeObj(oPais)

oRet            := JsonObject():New()
oRet["items"]   := aCidades
oRet["hasNext"] := lMorePage
	
Return oRet

/*/{Protheus.doc} fEstados
	Retorna os estados brasileiros
	@type  Function
	@author Henrique Ferreira
	@since 21/11/2022
	@version version
	@param cBranchVld - Filial
	       aQryParam  - Parametros utilizados
	@return oResponse - objeto Json para resposta
	/*/
Function fEstados( cBranchVld, aQryParam )

Local oPais     := NIL
Local oEstado   := NIL
Local oRet      := NIL

Local aArea     := GetArea()
Local aEstado   := {}

Local cEstName  :=""

Local nX      := 1
Local nLen    := Len( aQryParam )

If nLen > 0
	For nX := 1 To nLen
		Do Case
			Case Upper( aQryParam[nX,1] ) == "NAME"
				cEstName := AllTrim( Upper( aQryParam[nX,2] ) )
		EndCase
	Next nX
EndIf

aEstados  := FWGetSX5("12")

oPais 		  := JsonObject():New()
oPais["id"]   := "01058"
oPais["name"] := Upper( EncodeUTF8( STR0041 ) )
oPais["abbr"] := "BR"

If Len( aEstados ) > 0
	For nX := 1 To Len( aEstados )
		If  Empty(cEstName) .Or. ;
			( ( cEstName $ AllTrim( aEstados[nX,3] ) ) .Or.;
			( cEstName $ AllTrim( aEstados[nX,4] ) ) )
			oEstado 		:= JsonObject():New()
			oEstado["id"]   := AllTrim( aEstados[nX,3] )
			oEstado["abbr"] := AllTrim( aEstados[nX,3] )
			oEstado["name"] := AllTrim( aEstados[nX,4] )
			oEstado["country"] := oPais

			aAdd(aEstado, oEstado)
		EndIf
	Next nX
EndIf

RestArea(aArea)

FreeObj(oEstado)
FreeObj(oPais)

oRet            := JsonObject():New()
oRet["items"]   := aEstado
oRet["hasNext"] := .F.
	
Return oRet

/*/{Protheus.doc} fPaises
	Retorna os paises
	@type  Function
	@author Henrique Ferreira
	@since 21/11/2022
	@version version
	@param cBranchVld - Filial
	       aQryParam  - Parametros utilizados
	@return oResponse - objeto Json para resposta
	/*/
Function fPaises( cBranchVld, aQryParam )

Local oPais     := NIL
Local oRet      := NIL

Local lMorePage := .F.

Local nCount    := 0
Local nPage     := 1
Local nPageSize := 10
Local nRegIni   := 1
Local nRegFim   := 10

Local aPaises   := {}
Local aArea     := GetArea()

Local cFilCCH	:= xFilial("CCH", cBranchVld)
Local cPaisName := ""
Local cPaisId	:= ""
Local cQuery   	:= GetNextAlias()
Local cFiltro   := ""

Local nX      := 1
Local nLen    := Len( aQryParam )

If nLen > 0
	For nX := 1 To nLen
		Do Case
			Case Upper( aQryParam[nX,1] ) == "ID"
				cPaisId  := AllTrim( Upper( aQryParam[nX,2] ) )
			Case Upper( aQryParam[nX,1] ) == "NAME"
				cPaisName := AllTrim( Upper( aQryParam[nX,2] ) )
			Case Upper( aQryParam[nX,1] ) == "PAGE"
				nPage := Val( aQryParam[nX,2] )
			Case Upper( aQryParam[nX,1] ) == "PAGESIZE"
				nPageSize := Val( aQryParam[nX,2] )
		EndCase
	Next nX
EndIf

cFiltro := "%"
If !Empty( cPaisId )
	cFiltro += " AND CCH_CODIGO = '" + cPaisId + "'"
EndIf

If !Empty( cPaisName )
	cFiltro += " AND CCH_PAIS LIKE '%" + cPaisName + "%'"
EndIf
cFiltro += "%"

BeginSql Alias cQuery
	SELECT CCH_CODIGO, CCH_PAIS
	FROM %table:CCH% CCH
	WHERE
		CCH_FILIAL = %exp:cFilCCH%
		AND CCH.%notDel%
		%exp:cFiltro%
EndSql

If nPage == 1
	nRegIni := 1
	nRegFim := nPageSize
Else
	nRegIni := ( nPageSize * ( nPage - 1 ) ) + 1
	nRegFim := ( nRegIni + nPageSize ) - 1
EndIf

While (cQuery)->(!Eof())
	nCount++
	If ( nCount >= nRegIni .And. nCount <= nRegFim )
		oPais   := JsonObject():New()

		oPais["id"]   := AllTrim( (cQuery)->CCH_CODIGO )
		oPais["name"] := AllTrim( EncodeUTF8( (cQuery)->CCH_PAIS ) )
		oPais["abbr"] := NIL

		aAdd(aPaises, oPais)
	ElseIf nCount >= nRegFim
		lMorePage := .T.
		Exit
	EndIf
	(cQuery)->(dbSkip())
EndDo

(cQuery)->(dbCloseArea())

RestArea(aArea)
FreeObj(oPais)

oRet            := JsonObject():New()
oRet["items"]   := aPaises
oRet["hasNext"] := lMorePage
	
Return oRet

/*/{Protheus.doc} fGrInstr
	Retorna os graus de instrucao
	@type  Function
	@author Henrique Ferreira
	@since 21/11/2022
	@version version
	@param cBranchVld - Filial
	       aQryParam  - Parametros utilizados
	@return oResponse - objeto Json para resposta
	/*/
Function fGrInstr( cBranchVld, aQryParam )

Local oGrau     := NIL
Local oRet      := NIL

Local aArea      := GetArea()
Local aGrau      := {}
Local aListGraus := {}

Local cFiltro  	 := ""

Local nX      	 := 1
Local nLen    	 := 0

DEFAULT cBranchVld	:= ""
DEFAULT aQryParam	:= {}

nLen := Len( aQryParam )

If nLen > 0
	For nX := 1 To nLen
		Do Case
			Case Upper( aQryParam[nX,1] ) == "NAME"
				cFiltro := AllTrim( Upper( aQryParam[nX,2] ) )
		EndCase
	Next nX
EndIf

aGrau  := FWGetSX5("26")

If Len( aGrau ) > 0
	For nX := 1 To Len( aGrau )
		If  Empty(cFiltro) .Or. ;
			( ( cFiltro $ AllTrim( aGrau[nX,3] ) ) .Or.;
			( cFiltro $ AllTrim( aGrau[nX,4] ) ) )
			oGrau 		:= JsonObject():New()
			oGrau["id"]   := AllTrim( aGrau[nX,3] )
			oGrau["name"] := AllTrim(Upper(EncodeUTF8(aGrau[nX,4]) ) )

			aAdd(aListGraus, oGrau)
		EndIf
	Next nX
EndIf

RestArea(aArea)
FreeObj(oGrau)
oRet            := JsonObject():New()
oRet["items"]   := aListGraus
oRet["hasNext"] := .F.
	
Return oRet

/*/{Protheus.doc} fCategsCNH
	Retorna as categorias da CNH.
	@type  Function
	@author Henrique Ferreira
	@since 21/11/2022
	@version version
	@param
	@return oResponse - objeto Json para resposta
	/*/
Function fCategsCNH()

Local oCNH      := NIL
Local oRet      := NIL

Local aArea       := GetArea()
Local aCNH 		  := {}
Local aBoxCNH     := Iif(cPaisLoc == "BRA", RetSx3Box( Posicione("SX3", 2, "RA_CATCNH", "X3CBox()" ),,, 1 ), {})
Local nLenCNH     := Len( aBoxCNH )
Local nX          := 1

If nLenCNH > 0
	For nX := 1 To nLenCNH
		oCNH 		 := JsonObject():New()
		oCNH["id"]   := AllTrim( aBoxCNH[nX,2] )
		oCNH["name"] := AllTrim(Upper(EncodeUTF8(aBoxCNH[nX,3]) ) )

		aAdd( aCNH, oCNH )
	Next nX
EndIF

RestArea(aArea)
FreeObj(oCNH)

oRet := JsonObject():New()
oRet["items"] := aCNH
oRet["hasNext"] := .F.

Return oRet

/*/{Protheus.doc} fEstCivis
	Retorna os estados civis.
	@type  Function
	@author Henrique Ferreira
	@since 21/11/2022
	@version version
	@param cBranchVld - Filial
	       aQryParam  - Parametros utilizados
	@return oResponse - objeto Json para resposta
	/*/
Function fEstCivis(cBranchVld, aQryParam)

Local oEstCiv   := NIL
Local oRet      := NIL

Local aArea       := GetArea()
Local aEstCiv     := {}
Local aListEstCiv := {}
Local nLen        := 0
Local nX          := 1
Local cFiltro	  := ""

DEFAULT cBranchVld	:= ""
DEFAULT aQryParam	:= {}

nLen := Len( aQryParam )

If nLen > 0
	For nX := 1 To nLen
		If Upper(aQryParam[nX,1]) == "NAME"
			cFiltro := AllTrim( Upper(aQryParam[nX,2]))
		EndIf	
	Next nX
EndIf

aEstCiv  := FWGetSX5("33")

If Len( aEstCiv ) > 0
	For nX := 1 To Len( aEstCiv )
		If  Empty(cFiltro) .Or.;
		( ( cFiltro $ AllTrim(Upper(aEstCiv[nX,3])) ) .Or.;
		  ( cFiltro $ AllTrim(Upper(aEstCiv[nX,4])) ) )
			oEstCiv 		:= JsonObject():New()
			oEstCiv["id"]   := AllTrim( aEstCiv[nX,3] )
			oEstCiv["name"] := AllTrim( EncodeUTF8( Upper( aEstCiv[nX,4] ) ) )

			aAdd( aListEstCiv, oEstCiv )
		EndIf	
	Next nX
EndIF

RestArea(aArea)
FreeObj(oEstCiv)

oRet := JsonObject():New()
oRet["items"] := aListEstCiv
oRet["hasNext"] := .F.

Return oRet

/*/{Protheus.doc} fLogrTypes
	Retorna os tipos de logradouro.
	@type  Function
	@author Henrique Ferreira
	@since 21/11/2022
	@version version
	@param cBranchVld - Filial
	       aQryParam  - Parametros utilizados
	@return oResponse - objeto Json para resposta
	/*/
Function fLogrTypes( cBranchVld, aQryParam )

Local oLogr     := NIL
Local oRet      := NIL

Local lMorePage	:= .F.

Local cName     := ""

Local nCount    := 0
Local nPage     := 1
Local nPageSize := 10
Local nRegIni   := 1
Local nRegFim   := 10
Local nX	    := 0
Local nLen      := Len( aQryParam )


Local aArea       := GetArea()
Local aLogr       := {}
Local aListLogr   := {}

If nLen > 0
	For nX := 1 To nLen
		Do Case
			Case Upper( aQryParam[nX,1] ) == "NAME"
				cName := AllTrim( Upper( aQryParam[nX,2] ) )
			Case Upper( aQryParam[nX,1] ) == "PAGE"
				nPage := Val( aQryParam[nX,2] )
			Case Upper( aQryParam[nX,1] ) == "PAGESIZE"
				nPageSize := Val( aQryParam[nX,2] )
		EndCase
	Next nX
EndIf

If nPage == 1
	nRegIni := 1
	nRegFim := nPageSize
Else
	nRegIni := ( nPageSize * ( nPage - 1 ) ) + 1
	nRegFim := ( nRegIni + nPageSize ) - 1
EndIf

fCarrTab(@aLogr, "S054", NIL, .T., NIL, .F., cBranchVld )

nLen := Len( aLogr )

If nLen > 0
	For nX := 1 To nLen
		If Empty( cName ) .Or. ;
		( ( cName $ AllTrim(Upper(aLogr[nX,5]) ) .Or. cName $ AllTrim(Upper(aLogr[nX,6])) .Or. cName $ AllTrim(aLogr[nX,4] )  ) )
			nCount++
			If ( nCount >= nRegIni .And. nCount <= nRegFim )
				oLogr   := JsonObject():New()

				oLogr["id"]   := AllTrim( aLogr[nX,4] )
				oLogr["name"] := AllTrim( EncodeUTF8( aLogr[nX,6] ) )
				oLogr["abbr"] := AllTrim( aLogr[nX,5] )

				aAdd(aListLogr, oLogr)
			ElseIf nCount >= nRegFim
				lMorePage := .T.
				Exit
			EndIf
		EndIf
	Next nX
EndIf

RestArea( aArea )
FreeObj( oLogr )

oRet := JsonObject():New()
oRet["items"] := aListLogr
oRet["hasNext"] := lMorePage

Return oRet

/*/{Protheus.doc} fProfDep
- Retorna uma lista com os dependentes cadastrados para o usuário logado.

@author:	Henrique Ferreira
@since:		20/12/2021
@param:		cBranchVld - Filial do usuário logado;
			cMatSRA    - Matrícula do usuário logado.;
/*/
Function fProfDep( cBranchVld, cMatSRA )

Local aArea			:= GetArea()
Local aDepedents	:= {}
Local oDependente	:= NIL
Local oTypeDep	    := NIL

DEFAULT cBranchVld	:= ""
DEFAULT cMatSRA		:= ""

DbSelectArea("SRB")
DbSetOrder(1)
If SRB->( dbSeek( cBranchVld + cMatSRA ) )
	while SRB->(!eof()) .And. SRB->RB_FILIAL == cBranchVld .And. SRB->RB_MAT == cMatSRA
		oDependente := JsonObject():New()
		oTypeDep    := JsonObject():New()
		oDependente["id"] := cBranchVld + "|" + cMatSRA + "|" + SRB->RB_COD
		oDependente["name"] := AllTrim( SRB->RB_NOME )
		oDependente["cpf"] := SRB->RB_CIC
		oDependente["bornDate"] := FormatGMT( DTOS( SRB->RB_DTNASC ), .T. )
		oDependente["incomeTax"] := fTpDpIr( SRB->RB_TIPIR )
		oDependente["salaryFamily"] := fTpDpSf( SRB->RB_TIPSF )

		oTypeDep["id"] :=  SRB->RB_TPDEP 
		oTypeDep["name"] := fTypeDep( SRB->RB_TPDEP )

		oDependente["degreeOfDependence"] := oTypeDep

		aAdd( aDepedents, oDependente )
		SRB->( dbSkip() )
	endDo
EndIf
FreeObj( oDependente )
FreeObj( oTypeDep )
RestArea(aArea)

Return aDepedents

/*/{Protheus.doc} fTpsDeps
	Retorna os tipos de dependentes do eSocial
	@type  Function
	@author Henrique Ferreira
	@since 21/11/2022
	@version version
	@param aQryParam  - Parametros utilizados
	@return oResponse - objeto Json para resposta
	/*/
Function fTpsDeps( aQryParam )

Local oTipo     := NIL
Local oRet      := NIL

Local lMorePage := .F.

Local nCount    := 0
Local nPage     := 1
Local nPageSize := 10
Local nRegIni   := 1
Local nRegFim   := 10

Local aTipos   := {}
Local aOcor := {;
				OemToAnsi(STR0048),;		//"01=Cônjuge;"
				OemToAnsi(STR0049),;		//"02=Companheiro(a) com o(a) qual tenha filho ou viva há mais de 5 (cinco) anos ou possua Declaração de União Estável; "
				OemToAnsi(STR0050),;		//"03=Filho(a) ou enteado(a);"
				OemToAnsi(STR0051),;		//"04=Filho(a) ou enteado(a) universitário(a) ou cursando escola técnica de 2º grau; "
				OemToAnsi(STR0052),;		//"05=Filho(a) ou enteado(a) em qualquer idade, quando incapacitado física e/ou mentalmente para o trabalho; "
				OemToAnsi(STR0053),;		//"06=Irmão(ã), neto(a) ou bisneto(a) sem arrimo dos pais, do(a) qual detenha a guarda judicial; "
				OemToAnsi(STR0054),;		//"07=Irmão(ã), neto(a) ou bisneto(a) sem arrimo dos pais se ainda estiver cursando estabelecimento de nível superior ou escola técnica de 2º grau, desde que tenha detido sua guarda judicial; "
				OemToAnsi(STR0055),;		//"08=Irmão(ã), neto(a) ou bisneto(a) sem arrimo dos pais, do(a) qual detenha a guarda judicial, em qualquer idade, quando incapacitado física e/ou mentalmente para o trabalho; "
				OemToAnsi(STR0056),;		//"09=Pais, avós e bisavós;"
				OemToAnsi(STR0057),;		//"10=Menor pobre que crie e eduque e do qual detenha a guarda judicial; "
				OemToAnsi(STR0058),;		//"11=A pessoa absolutamente incapaz, da qual seja tutor ou curador; "
				OemToAnsi(STR0059),;		//"12=Ex-cônjuge."
	            OemToAnsi(STR0060)}		//"13=AGregado\Outros"
Local aArea     := GetArea()

Local cFiltro   := ""
Local cName		:= ""
Local cCodigo   := ""

Local nX      := 1
Local nLen    := Len( aQryParam )

If nLen > 0
	For nX := 1 To nLen
		Do Case
			Case Upper( aQryParam[nX,1] ) == "NAME"
				cFiltro := AllTrim( Upper( aQryParam[nX,2] ) )
			Case Upper( aQryParam[nX,1] ) == "PAGE"
				nPage := Val( aQryParam[nX,2] )
			Case Upper( aQryParam[nX,1] ) == "PAGESIZE"
				nPageSize := Val( aQryParam[nX,2] )
		EndCase
	Next nX
EndIf

If nPage == 1
	nRegIni := 1
	nRegFim := nPageSize
Else
	nRegIni := ( nPageSize * ( nPage - 1 ) ) + 1
	nRegFim := ( nRegIni + nPageSize ) - 1
EndIf

For nX := 1 To Len( aOcor )
	cCodigo := SubStr( aOcor[nX], 1, 2 )
	cName 	:= Upper( SubStr( aOcor[nX], 4, Len( aOcor[nX] ) ) )
	If Empty(cFiltro) .Or. ( cFiltro $ cCodigo ) .Or. ( cFiltro $ cName )
		nCount++
		If ( nCount >= nRegIni .And. nCount <= nRegFim )
			oTipo   := JsonObject():New()

			oTipo["id"]   := cCodigo
			oTipo["name"] := EncodeUTF8( cName )

			aAdd(aTipos, oTipo)
		ElseIf nCount >= nRegFim
			lMorePage := .T.
			Exit
		EndIf
	EndIf
Next nX

RestArea(aArea)
FreeObj(oTipo)

oRet            := JsonObject():New()
oRet["items"]   := aTipos
oRet["hasNext"] := lMorePage
	
Return oRet

/*/{Protheus.doc} fTypeDep
	retorna o tipo de dependente conforme o eSocial
	@type  Function
	@author user
	@since 24/11/2022
	@version 1.0
	@param cType - Tipo do dependente
	@return cDesc - Descrição
	/*/
Static Function fTypeDep(cType)
Local nPos  := 0
Local cDesc	:= ""
Local aOcor := {;
				OemToAnsi(STR0048),;		//"01=Cônjuge;"
				OemToAnsi(STR0049),;		//"02=Companheiro(a) com o(a) qual tenha filho ou viva há mais de 5 (cinco) anos ou possua Declaração de União Estável; "
				OemToAnsi(STR0050),;		//"03=Filho(a) ou enteado(a);"
				OemToAnsi(STR0051),;		//"04=Filho(a) ou enteado(a) universitário(a) ou cursando escola técnica de 2º grau; "
				OemToAnsi(STR0052),;		//"05=Filho(a) ou enteado(a) em qualquer idade, quando incapacitado física e/ou mentalmente para o trabalho; "
				OemToAnsi(STR0053),;		//"06=Irmão(ã), neto(a) ou bisneto(a) sem arrimo dos pais, do(a) qual detenha a guarda judicial; "
				OemToAnsi(STR0054),;		//"07=Irmão(ã), neto(a) ou bisneto(a) sem arrimo dos pais se ainda estiver cursando estabelecimento de nível superior ou escola técnica de 2º grau, desde que tenha detido sua guarda judicial; "
				OemToAnsi(STR0055),;		//"08=Irmão(ã), neto(a) ou bisneto(a) sem arrimo dos pais, do(a) qual detenha a guarda judicial, em qualquer idade, quando incapacitado física e/ou mentalmente para o trabalho; "
				OemToAnsi(STR0056),;		//"09=Pais, avós e bisavós;"
				OemToAnsi(STR0057),;		//"10=Menor pobre que crie e eduque e do qual detenha a guarda judicial; "
				OemToAnsi(STR0058),;		//"11=A pessoa absolutamente incapaz, da qual seja tutor ou curador; "
				OemToAnsi(STR0059),;		//"12=Ex-cônjuge."
	            OemToAnsi(STR0060)}		//"13=AGregado\Outros"


If ( nPos := aScan( aOcor, {|x| cType $ x } ) )  > 0
	cDesc := Upper( SubStr( aOcor[nPos], 4, Len( aOcor[nPos] ) ) )
EndIf
	
Return EncodeUTF8( cDesc )

/*/{Protheus.doc} fSetDef
	Setar o json com as deficiências do colaborador
	@type  Function
	@author user
	@since 25/11/2022
	@version version
	@param Array com as Deficiências
	@return aListDef - Json pronto para ser enviado
	/*/
Function fSetDef(cDefs)

Local oDef := JsonObject():New()
Local aDef := {}

Default cDefs := ""

//"Portador de deficiência Física."
oDef["id"] 				:= "1"
oDef["name"]			:= ENCODEUTF8( STR0061 )
oDef["value"]			:= "1" $ cDefs
Aadd(aDef, oDef)

//"Portador de deficiência Auditiva."
oDef := JsonObject():New()
oDef["id"] 				:= "2"
oDef["name"]			:= ENCODEUTF8( STR0062 )
oDef["value"]			:= "2" $ cDefs
Aadd(aDef, oDef)

//"Portador de deficiência Visual."
oDef := JsonObject():New()
oDef["id"] 				:= "3"
oDef["name"]			:= ENCODEUTF8( STR0063 )
oDef["value"]			:= "3" $ cDefs
Aadd(aDef, oDef)

//"Portador de deficiência Mental."
oDef := JsonObject():New()
oDef["id"] 				:= "4"
oDef["name"]			:= ENCODEUTF8( STR0064 )
oDef["value"]			:= "4" $ cDefs
Aadd(aDef, oDef) 

//"Portador de deficiência Intelectual."
oDef := JsonObject():New()
oDef["id"] 				:= "5"
oDef["name"]			:= ENCODEUTF8( STR0065 )
oDef["value"]			:= "5" $ cDefs
Aadd(aDef, oDef) 

//"O trabalhador é reabilitado, e apto a retornar ao trabalho."
oDef := JsonObject():New()
oDef["id"] 				:= "6"
oDef["name"]			:= ENCODEUTF8( STR0066 )
oDef["value"]			:= "6" $ cDefs
Aadd(aDef, oDef) 
	
Return aDef

/*/{Protheus.doc} fUpdDep
	Atualiza o cadastro de dependentes.
	@type  Function
	@author user
	@since 30/11/2022
	@version 1.0
	@param aId - Id do dependente
		   oDepends - Objeto com os dados do dependente.
		   cMsg - Msg de validação
	/*/
Function fUpdDep(aId, oDepends, cMsg)

Local aArea   := GetArea()
Local cCodFil := ""
Local cCodMat := ""
Local cCodDep := ""

DEFAULT  aId 	 := {}
DEFAULT  oDepends := NIL
DEFAULT  cMsg     := ""

If Len( aId ) >= 3
	cCodFil := aId[1]
	cCodMat := aId[2]
	cCodDep := aId[3]

	SRB->( DBSelectArea('SRB') )
	SRB->( DBSetOrder(1) )
	If SRB->( dbSeek(xFilial("SRB", cCodFil ) + cCodMat + cCodDep ) )
		If !( SRB->RB_CIC == oDepends:cicDep ) .Or. !( SRB->RB_TPDEP == oDepends:tpDep )
			AddDependent( cCodMat, cCodDep, oDepends, cCodFil, @cMsg, .T. )
		ENDIF
	EndIf

EndIf

RestArea( aArea )
	
Return .T.
