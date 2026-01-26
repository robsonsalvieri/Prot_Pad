#INCLUDE "WSRESTRICOESTL.CH"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "TOTVS.CH"
#INCLUDE "RESTFUL.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "FILEIO.CH"
#INCLUDE "PARMTYPE.CH"
#INCLUDE "SHELL.CH"

//-------------------------------------------------------------------
/*/{Protheus.doc} JURRESTRICOES
Métodos WS REST do Jurídico para restrições do TOTVS Legal

@author SIGAJURI
@since 12/03/2021

/*/
//-------------------------------------------------------------------
WSRESTFUL JURRESTRICOES DESCRIPTION STR0001 // "WS Jurídico Restrições"

	WSDATA filial       AS STRING
	WSDATA cajuri       AS STRING
	WSDATA rotina       AS STRING
	WSDATA codPesq      AS STRING
	WSDATA grupoUsuario AS STRING

	WSMETHOD GET restricRot             DESCRIPTION STR0002 PATH 'restricRot'                               PRODUCES APPLICATION_JSON // 'Restrições de Rotinas do TOTVS Legal'
	WSMETHOD GET assJurxPesq            DESCRIPTION STR0003 PATH 'assJurxPesq'                              PRODUCES APPLICATION_JSON // 'Busca o assunto jurídico correspondente ao código da pesquisa'
	WSMETHOD GET getAcessoUsu           DESCRIPTION STR0004 PATH "grpusu/accessRestriction"                 PRODUCES APPLICATION_JSON // "Retornar as Restrição de acessos do Grupo do usuário logado" 
	WSMETHOD GET RoutineRestrictionTJD  DESCRIPTION STR0006 PATH "grpusu/accessRestriction/options"         PRODUCES APPLICATION_JSON // "Retorna as Rotinas de restrições do Grupo do usuário"
	WSMETHOD GET groupRestrictionTJD    DESCRIPTION STR0007 PATH "grpusu/{grupoUsuario}/routineRestricted"  PRODUCES APPLICATION_JSON // "Retorna as rotinas que estão restritas ao grupo" 
	
	WSMETHOD PUT updRestrictionTJD      DESCRIPTION STR0005 PATH "grpusu/{grupoUsuario}/accessRestriction"  PRODUCES APPLICATION_JSON // "Atualiza as restrições do Grupo do usuário" 

	WSMETHOD DELETE delRestrictionTJD   DESCRIPTION STR0009 PATH "grpusu/{grupoUsuario}/accessRestriction"  PRODUCES APPLICATION_JSON // "Excluir as restrições do grupo de usuário"
END WSRESTFUL

//-------------------------------------------------------------------
/*/{Protheus.doc} restricRot
Busca as restrições do usuário para as rotinas do TOTVS Legal

@param filial: Filial do assunto jurídico
@param cajuri: Código do assunto jurídico
@param rotina: Rotina

@since 12/03/2021

@example GET -> http://localhost:12173/rest/JURRESTRICOES/restricRot?filial=D MG 01 &cajuri=0000000247
/*/
//-------------------------------------------------------------------
WSMETHOD GET restricRot WSRECEIVE filial, cajuri, rotina WSREST JURRESTRICOES

Local aArea      := GetArea()
Local oResponse  := JsonObject():New()
Local cFilPro    := self:filial
Local cCajuri    := self:cajuri
Local cRotina    := IIF( VALTYPE(self:rotina) <> "U", self:rotina, "")
Local cAssJur    := ""
Local cResult    := ""
Local aRestric   := {}
Local nX         := 0

	Self:SetContentType("application/json")
	oResponse['restricoes'] := {}

	If !Empty(cCajuri)
		cAssJur  := JurGetDados("NSZ", 1, cFilPro + cCajuri, "NSZ_TIPOAS")
		cResult  := JPermissTL(cAssJur, cRotina)
		aRestric := JURSQL(cResult,"*")

		For nX := 1 To Len(aRestric)
			Aadd(oResponse['restricoes'], JsonObject():New())
			oResponse['restricoes'][nX]['visualizar'] := aRestric[nX][1] == '1'
			oResponse['restricoes'][nX]['incluir']    := aRestric[nX][2] == '1'
			oResponse['restricoes'][nX]['alterar']    := aRestric[nX][3] == '1'
			oResponse['restricoes'][nX]['excluir']    := aRestric[nX][4] == '1'
			oResponse['restricoes'][nX]['rotina']     := aRestric[nX][5]
		Next nX
	EndIf

	aSize(aRestric, 0)
	RestArea( aArea )

	Self:SetResponse(FWJsonSerialize(oResponse, .F., .F., .T.))

Return .T.

//-------------------------------------------------------------------
/*/{Protheus.doc} JVldRestri
Valida a restrição de acessos do usuário

@param cTpAssJur, string, Código do tipo de assunto jurídico
@param cRotina,   string, Código da rotina
@param nOpc,      string, Operaçãoexecutada

@return lRet,     boolean, Retorna .F. caso o usuário não possua acesso

@since 12/03/2021
/*/
//-------------------------------------------------------------------
Function JVldRestri(cTpAssJur, cRotina, nOpc)

Local cAlias      := ""
Local cQuery      := ""
Local lRet        := .F.

Default cTpAssJur := '001'
Default cRotina   := '14'
Default nOpc      := 2
	
	// Se o usuário é do grupo de subsídio,for da rotina de anexo ou solicitação de subsídio, permite a manipulação.
	If cRotina $ "'03'/'19'"
		aEval(J218RetGru( __cUserId ), {|cGrupo| lRet := lRet .or. Posicione('NZX',1,xFilial('NZX')+cGrupo,'NZX_TIPOA') == '4' })
	Endif

	If !lRet
		cAlias      := GetNextAlias()
		cQuery := JPermissTL(cTpAssJur, cRotina)
		cQuery := ChangeQuery(cQuery)
		DbUseArea( .T., "TOPCONN", TCGenQry(,,cQuery), cAlias, .T., .F. )

		lRet := (cAlias)->(! Eof())

		While lRet .And. (cAlias)->(! Eof()) 
			Do case 
				Case nOpc == 2
					If (cAlias)->NWP_CVISU == '2'
						lRet := .F.
					EndIf
				Case nOpc == 3
					If (cAlias)->NWP_CINCLU == '2'
						lRet := .F.
					EndIf
				Case nOpc == 4
					If (cAlias)->NWP_CALTER == '2'
						lRet := .F.
					EndIf
				Case nOpc == 5
					If (cAlias)->NWP_CEXCLU == '2'
						lRet := .F.
					EndIf
			End Case

			(cAlias)->(dbSkip())
		End

		(cAlias)->(DbCloseArea())
	Endif

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} JPermissTL
Busca as permissoes de acessos do usuário para o TOTVS Legal

@param cTpAssJur, string, Código do tipo de assunto jurídico
@param cRotina,   string, Código da rotina

@return cQuery,   string, retorno da query com acessos do usuário
@since 12/03/2021
/*/
//-------------------------------------------------------------------
Function JPermissTL(cTpAssJur, cRotina)

Local cQuery      := ""
Local cUser       :=  __CUSERID 
Local cGrupos     := ArrTokStr(J218RetGru(cUser),"','")
Local lNVKCasJur  := .F.

Default cRotina := ""

	// Verifica se o campo NVK_CASJUR existe no dicionário
	If Select("NVK") > 0
		lNVKCasJur := (NVK->(FieldPos('NVK_CASJUR')) > 0)
	Else
		DBSelectArea("NVK")
			lNVKCasJur := (NVK->(FieldPos('NVK_CASJUR')) > 0)
		NVK->( DBCloseArea() )
	EndIf

	cQuery := " SELECT NWP_CVISU, "
	cQuery +=        " NWP_CINCLU, "
	cQuery +=        " NWP_CALTER, "
	cQuery +=        " NWP_CEXCLU, "
	cQuery +=        " NWP_CROT, "
	cQuery +=        " NVK_CGRUP "
	cQuery += " FROM   " + RetSqlname("NVK") + " NVK "
	cQuery +=        " LEFT JOIN " + RetSqlname("NWP") + " NWP "
	cQuery +=                " ON ( NWP_CCONF = NVK_COD "
	cQuery +=                     " AND NWP_FILIAL = '" + xFilial("NWP") + "'"
	If !Empty(cRotina)
		cQuery +=                 " AND NWP_CROT IN ( " + cRotina + " ) "
	EndIf
	cQuery +=                     " AND NWP.D_E_L_E_T_ = ' ' ) "
	cQuery +=        " LEFT JOIN " + RetSqlname("NVJ") + " NVJ "
	cQuery +=               " ON ( NVJ_FILIAL = '" + xFilial("NVJ") + "'"
	cQuery +=                    " AND NVK_CPESQ = NVJ_CPESQ "
	cQuery +=                    " AND NVJ.D_E_L_E_T_ = ' ' ) "
	cQuery += " WHERE ( NVK_CUSER = '" + cUser + "' "
	cQuery +=               " OR NVK_CGRUP IN ( '" + cGrupos + "' ) ) "

	If lNVKCasJur
		cQuery +=       " AND ( NVK_CASJUR = '" + cTpAssJur + "' "
		cQuery +=               " OR NVJ_CASJUR = '" + cTpAssJur + "' ) "
	Else
		cQuery +=               " AND NVJ_CASJUR = '" + cTpAssJur + "' "
	EndIf

	cQuery +=       " AND NVK.D_E_L_E_T_ = ' ' "

Return cQuery

//-------------------------------------------------------------------
/*/{Protheus.doc} GET assJurxPesq
Busca o assunto jurídico correspondente ao código da pesquisa

@param codPesq: Código da pesquisa

@since 29/04/2021

@example GET -> http://localhost:12173/rest/JURRESTRICOES/assJurxPesq?codPesq=002
/*/
//-------------------------------------------------------------------
WSMETHOD GET assJurxPesq WSRECEIVE codPesq WSREST JURRESTRICOES

Local aArea      := GetArea()
Local oResponse  := Nil
Local cCodPesq   := self:codPesq
Local cQuery     := ""
Local aListAss   := {}
Local nX         := 0

Default codPesq := ""

	Self:SetContentType("application/json")

	If !Empty(cCodPesq)
		oResponse := JsonObject():New()
		oResponse['assuntos'] := {}

		cQuery := " SELECT NVJ_CASJUR ASSUNTO "
		cQuery += " FROM " + RetSqlname("NVJ") + " NVJ "
		cQuery += " WHERE NVJ.NVJ_FILIAL = '" + xFilial("NVJ") + "' "
		cQuery +=   " AND NVJ.NVJ_CPESQ = '" + cCodPesq + "' "
		cQuery +=   " AND NVJ.D_E_L_E_T_ = ' ' "

		aListAss := JURSQL(cQuery,"*")

		For nX := 1 To Len(aListAss)
			Aadd(oResponse['assuntos'], JsonObject():New())
			oResponse['assuntos'][nX]['codAssJur'] := aListAss[nX][1]
		Next nX
	EndIf

	aSize(aListAss, 0)
	RestArea( aArea )

	Self:SetResponse(FWJsonSerialize(oResponse, .F., .F., .T.))

Return .T.


//-------------------------------------------------------------------
/*/{Protheus.doc} StrToOpt(cOptions)
Transforma o Options do CBOX em Array

@param cOptions - CBOX = 1=Sim;2=Não

@return [n][1] - Valor
        [n][2] - Descrição

@since 28/12/2022
/*/
//-------------------------------------------------------------------
Static Function StrToOpt(cOptions)
Local aRet     := {}
Local aOptions := StrTokArr(cOptions, ";")
Local nI       := 0
Local nAtDiv   := 0

	For nI := 1 To Len(aOptions)
		nAtDiv := At("=", aOptions[nI])
		aAdd(aRet, { SubStr(aOptions[nI], 0, nAtDiv-1),  SubStr(aOptions[nI], nAtDiv+1) })
	Next nI
Return aRet

//-------------------------------------------------------------------
/*/{Protheus.doc} GET RoutineRestrictionTJD
Retorna as opções de Rotinas a serem restringidas no TJD 

@example [Sem Opcional] GET -> http://127.0.0.1:12173/rest/JURRESTRICOES/grpusu/accessRestriction/options
/*/
//-------------------------------------------------------------------
WSMETHOD GET RoutineRestrictionTJD WSREST JURRESTRICOES
Local lRet  := .T.
Local aOpts := {}
Local nI    := 0
Local oResponse := {}

	aOpts := StrToOpt(J309Rotina())

	For nI := 1 To Len(aOpts)
		aAdd(oResponse, JSonObject():New())
		oResponse[nI]["value"] := aOpts[nI][1]
		oResponse[nI]["label"] := JurConvUTF8(aOpts[nI][2])
	Next nI
	
	Self:SetResponse(FWJsonSerialize(oResponse, .F., .F., .T.))
	aSize(oResponse, 0)
Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} GET groupRestrictionTJD
Retorna o código das rotinas que estão Bloqueadas para o Grupo de usuário

@param grupoUsuario - Path - Grupo de acesso a ser verificado
@return - {}

@example [Sem Opcional] GET -> http://127.0.0.1:12173/rest/JURRESTRICOES/grpusu/{grupoUsuario}/routineRestricted
/*/
//-------------------------------------------------------------------
WSMETHOD GET groupRestrictionTJD PATHPARAM grupoUsuario WSREST JURRESTRICOES
Local lRet      := .T.
Local nI        := 0
Local cQuery    := ""
Local cGrpUsu   := Self:grupoUsuario
Local aRotinas  := {}
Local oResponse := JSonObject():New()

Default cGrpUsu := ""

	oResponse['rotinas'] := {}
	
	If (FWAliasInDic("O1G"))
		cQuery := " SELECT O1G_ROTINA "
		cQuery +=   " FROM " + RetSqlName("O1G") + " O1G "
		cQuery +=  " WHERE O1G.O1G_BLOQUE = '1' "
		cQuery +=    " AND O1G.D_E_L_E_T_ = ' ' "
		cQuery +=    " AND O1G.O1G_GRPUSU = '"+cGrpUsu+"' "

		aRotinas := JurSQL(cQuery, {"O1G_ROTINA"})
		
		For nI := 1 To Len(aRotinas)
			aAdd(oResponse['rotinas'], aRotinas[nI][1])
		Next nI
	Else
		oResponse['status']  = '204'
		oResponse['message'] = JurEncUTF8(STR0010) // "A tabela O1G não existe no dicionário de dados."
	EndIf

	Self:SetResponse(oResponse:toJson())
	oResponse:fromJson("{}")
	oResponse := NIL
Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} GET RoutineRestrictionTJD
Retorna as opções de Rotinas a serem restringidas no TJD 

@param grupoUsuario - Código do Grupo de usuário

@Body ["rotinas"] = Array com as rotinas a serem BLOQUEADAS

@notes Os códigos das rotinas que não forem recebidas serão desbloqueadas

@example [Sem Opcional] PUT -> http://127.0.0.1:12173/rest/JURRESTRICOES/grpusu/accessRestriction
/*/
//-------------------------------------------------------------------
WSMETHOD PUT updRestrictionTJD  PATHPARAM grupoUsuario WSREST JURRESTRICOES
Local oBody        := JSonObject():New()
Local oResponse    := JSonObject():New()
Local cBody        := Self:GetContent()
Local cGrpUsu      := Self:grupoUsuario
Local lRet         := .T.
Local cQuery       := ""
Local aRotinas     := {}
Local aRstGrpUsu   := {}
Local nI           := 0
Local nIndRestr    := 0

	oBody:FromJson(cBody)
	aRotinas := oBody['rotinas']

	If (FWAliasInDic("O1G"))
		cQuery := " SELECT O1G.O1G_ROTINA, O1G.O1G_BLOQUE, R_E_C_N_O_ Recno "
		cQuery +=   " FROM " + RetSqlName("O1G") + " O1G "
		cQuery +=  " WHERE O1G_GRPUSU = '" + cGrpUsu + "'"
		cQuery +=    " AND O1G.D_E_L_E_T_ = ' ' "

		aRstGrpUsu := JurSQL(cQuery, {"O1G_ROTINA", "O1G_BLOQUE", "Recno"})

		// Processa as rotinas que foram recebidas via Body, bloqueando as rotinas
		For nI := 1 to Len(aRotinas) //Body
			nIndRestr := aScan(aRstGrpUsu,{|x| x[1] == aRotinas[nI]})
			If (nIndRestr == 0) 
				lRet := JUpdBlqO1G(/* Não tem Recno */, cGrpUsu, aRotinas[nI], '1')
			Else 
				lRet := JUpdBlqO1G(aRstGrpUsu[nIndRestr][3], cGrpUsu, aRotinas[nI], '1')
			EndIf
		Next nI

		// Irá processar as rotinas restantes para habilitar o acesso
		For nI := 1 To Len(aRstGrpUsu)
			nIndRestr := aScan(aRotinas, aRstGrpUsu[nI][1])
			If nIndRestr == 0 // N | S | X
				lRet := JUpdBlqO1G(aRstGrpUsu[nI][3], cGrpUsu, aRstGrpUsu[nI][1], '2')
			EndIf
		Next nI
		
		If (lRet)
			oResponse['status']  = '200'
			oResponse['message'] = JurEncUTF8(STR0008)//"As restrições das rotinas do grupo foram atualizadas com sucesso!"
		EndIf
	EndIf

	Self:SetResponse(oResponse:toJson())
	oResponse:fromJson("{}")
	oResponse := NIL
Return lRet


//-------------------------------------------------------------------
/*/{Protheus.doc} JUpdBlqO1G(nRecno, cGrpUsu, cRotina, cBloque)
Função que inicia a atualização/criação da Restrição de Rotina do Grupo

@param nRecno - Recno do Grupo na O1G
@param cGrpUsu - Código do Grupo de Usuário
@param cRotina - Código da Rotina a ser alterada
@param cBloque - Indica se a rotina será bloqueada ou não

@return lRet - Retorna se a operação foi bem sucedida ou não

@author Willian Kazahaya
@since 28/12/2022
/*/
//-------------------------------------------------------------------
Static Function JUpdBlqO1G(nRecno, cGrpUsu, cRotina, cBloque)
Local lRet := .T.
Default nRecno  := -1
Default cGrpUsu := ""
Default cRotina := ""

	If nRecno == -1 // Se o Recno for negativo é uma Inclusão
		lRet := JOpera309(3, cGrpUsu, cRotina)
	Else
		DbSelectArea("O1G")
		DbGoTo(nRecno)
		lRet := JOpera309(4, cGrpUsu, cRotina, cBloque)
	EndIf
Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} JUpdBlqO1G(nRecno, cGrpUsu, cRotina, cBloque)
Função que inicia a atualização/criação da Restrição de Rotina do Grupo

@param nRecno - Recno do Grupo na O1G
@param cGrpUsu - Código do Grupo de Usuário
@param cRotina - Código da Rotina a ser alterada
@param cBloque - Indica se a rotina será bloqueada ou não

@author Willian Kazahaya
@since 28/12/2022
/*/
//-------------------------------------------------------------------
Static Function JOpera309(nOper, cGrpUsu, cRotina, cBloque)
Local oModel    := Nil
Default nOper   := 4
Default cGrpUsu := "" //O1G->O1G_GRPUSU
Default cRotina := "" //O1G->O1G_ROTINA
Default cBloque := "" //O1G->O1G_BLOQUE

	oModel := FwLoadModel("JURA309")
	oModel:SetOperation(nOper)
	oModel:Activate()

	If nOper == MODEL_OPERATION_INSERT 
		oModel:SetValue("O1GMASTER", "O1G_GRPUSU", cGrpUsu)
		oModel:SetValue("O1GMASTER", "O1G_ROTINA", cRotina)
	ElseIf nOper == MODEL_OPERATION_UPDATE
		oModel:SetValue("O1GMASTER", "O1G_BLOQUE", cBloque)
	EndIf

	If ( lRet := oModel:VldData() )
		lRet := oModel:CommitData()
	EndIf
	
	If (!lRet)
		lRet := JurMsgErro(oModel:aErrorMessage[6]) 
	EndIf

	oModel:DeActivate()
	oModel:Destroy()
	oModel := Nil
Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} getAcessoUsu

Retornar as Restrição de acessos do Grupo do usuário logado
@since 28/12/2022
@version 1.0
@example [Sem Opcional] PUT -> localhost:12173/rest/JURRESTRICOES/grpusu/accessRestriction
/*/
//-------------------------------------------------------------------

WSMETHOD GET getAcessoUsu WSREST JURRESTRICOES
Local oResponse  := JsonObject():New()
Local oQuery     := Nil
Local cQuery     := ""
Local cAliasO1G  := ""

	oResponse["restringe"]                  := JsonObject():New()
	oResponse["restringe"]["publicacoes"]   := .F.
	oResponse["restringe"]["distribuicoes"] := .F.
	oResponse["restringe"]["config"]        := .F.
	oResponse["restringe"]["cadBasico"]     := .F.
	oResponse["restringe"]["usuarios"]      := .F.
	oResponse["restringe"]["auditoria"]     := .T. // Inicialização é invertida por sempre restringir


	If (FWAliasInDic("O1G"))
		JRestrAudit() // Verifica se há restrição cadastrada para o Módulo de auditoria

		cQuery := " SELECT O1G.O1G_ROTINA,"
		cQuery +=        " O1G.O1G_BLOQUE"
		cQuery +=  " FROM " + RetSqlName("NZY") + " NZY"
		cQuery += " INNER JOIN " + RetSqlName("NZX") + " NZX"
		cQuery +=    " ON (NZX.NZX_COD = NZY.NZY_CGRUP "
		cQuery +=   " AND NZX.D_E_L_E_T_ = ' ')"
		cQuery += " INNER JOIN " + RetSqlName("O1G") + " O1G"
		cQuery +=    " ON (O1G.O1G_GRPUSU = NZX.NZX_COD" 
		cQuery +=   " AND O1G.D_E_L_E_T_ = ' ')"
		cQuery += " WHERE NZY.NZY_CUSER = ?"
		cQuery +=   " AND NZY.D_E_L_E_T_ = ' '"
		cQuery += " GROUP BY O1G.O1G_ROTINA, O1G.O1G_BLOQUE"

		cAliasO1G := GetNextAlias()
		oQuery := FWPreparedStatement():New(cQuery)

		oQuery:SetString(1, __cUserID)
		MPSysOpenQuery(oQuery:GetFixQuery(), cAliasO1G)

		If (cAliasO1G)->(!Eof())

			While (cAliasO1G)->(!Eof())
				Do Case
					Case ((cAliasO1G)->(O1G_ROTINA)) =='1' .AND. ((cAliasO1G)->O1G_BLOQUE) == '1'
						oResponse["restringe"]["publicacoes"] := .T.

					Case ((cAliasO1G)->(O1G_ROTINA)) =='2' .AND. ((cAliasO1G)->O1G_BLOQUE) == '1'
						oResponse["restringe"]["distribuicoes"] := .T.

					Case ((cAliasO1G)->(O1G_ROTINA)) =='3' .AND. ((cAliasO1G)->O1G_BLOQUE) == '1'
						oResponse["restringe"]["config"] := .T.

					Case ((cAliasO1G)->(O1G_ROTINA)) =='4' .AND. ((cAliasO1G)->O1G_BLOQUE) == '1'
						oResponse["restringe"]["cadBasico"] := .T.

					Case ((cAliasO1G)->(O1G_ROTINA)) =='5' .AND. ((cAliasO1G)->O1G_BLOQUE) == '1'
						oResponse["restringe"]["usuarios"] := .T.

					Case ((cAliasO1G)->(O1G_ROTINA)) == '6' .AND. ((cAliasO1G)->O1G_BLOQUE) == '2'
						oResponse["restringe"]["auditoria"] := .F.
				End Case
				(cAliasO1G)->( dbSkip() )
			EndDo
		EndIf

		(cAliasO1G)->(DbCloseArea())
	EndIf

	Self:SetResponse(oResponse:toJson())
	oResponse:fromJson("{}")
	oResponse := NIL
Return .T.

//-------------------------------------------------------------------
/*/{Protheus.doc} DELETE delRestrictionTJD
Exclui as Restrições de Rotina do TJD do Grupo de usuário

@since 09/01/2023
@version 1.0
@example [Sem Opcional] DELETE -> http://127.0.0.1:12173/rest/JURRESTRICOES/grpusu/{grupoUsuario}/routineRestricted
/*/
//-------------------------------------------------------------------
WSMETHOD DELETE delRestrictionTJD PATHPARAM grupoUsuario WSREST JURRESTRICOES
Local oResponse  := JsonObject():New()
Local aRstGrpUsu := {}
Local cQuery     := ""
Local nI         := 0
Local lRet       := .T.

	If (FWAliasInDic("O1G"))
		cQuery := " SELECT R_E_C_N_O_ Recno "
		cQuery +=   " FROM " + RetSqlName("O1G") + " O1G "
		cQuery +=  " WHERE O1G_GRPUSU = '" + self:grupoUsuario + "'"
		cQuery +=    " AND O1G.D_E_L_E_T_ = ' ' "

		aRstGrpUsu := JurSQL(cQuery, { "Recno" })

		If (Len(aRstGrpUsu) > 0)
			For nI := 1 To Len(aRstGrpUsu)
				DbSelectArea("O1G")
				DbGoTo(aRstGrpUsu[nI][1])
				lRet := JOpera309(5)
			Next nI
		EndIf
	EndIf

	Self:SetResponse(oResponse:toJson())
	oResponse:fromJson("{}")
	oResponse := NIL

	aSize(aRstGrpUsu, 0)
Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} JRestrAudit
Verifica se há restrição para o Módulo de auditoria
Se não há restrição, cadastra para todos os grupos

@return lRet - Indica se é necessário cadastrar restrições
@since 19/03/2024
/*/
//-------------------------------------------------------------------
Static Function JRestrAudit()
Local oQuery := Nil
Local lRet   := .F.
Local cQuery := ""
Local cAlias  := ""

	cQuery += " SELECT COUNT(1) QTD"
	cQuery +=   " FROM " + RetSqlName("O1G") + " O1G"
	cQuery +=  " WHERE O1G_ROTINA = '6'"  // 6=Módulo de auditoria
	cQuery +=    " AND O1G.D_E_L_E_T_ = ' '"

	cQuery := ChangeQuery(cQuery)
	oQuery := FWPreparedStatement():New(cQuery)
	cAlias := MPSysOpenQuery(oQuery:GetFixQuery())

	If !(cAlias)->(Eof())
		lRet := (cAlias)->QTD == 0
	EndIf

	(cAlias)->( DbCloseArea() )

	// Obtem todos os grupos para cadastrar a restrição ao módulo auditoria
	If lRet
		STARTJOB("JIncO1G", GetEnvServer(), .F., cEmpAnt, cFilAnt, __CUSERID)
	EndIf

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} JIncO1G
Busca todos os grupos de usuário do juridico para cadastrar restrição
ao módulo de auditoria.

@param cEmpAnt - Empresa logada
@param cFilAnt - Empresa logada
@param cUserID - Código do usuário logado

@since 19/03/2024
/*/
//-------------------------------------------------------------------
Function JIncO1G(cEmpAnt, cFilAnt, cUserID)
Local aArea   := GetArea()
Local cAlias  := ""
Local cQuery  := ""
Local oMdl309 := Nil
Local lRet    := .T.

	RPCSetType(3) // Prepara o ambiente e não consome licença
	RPCSetEnv(cEmpAnt, cFilAnt, , , 'JURI') // Abre o ambiente

	cQuery += " SELECT NZX_COD"
	cQuery +=   " FROM " + RetSqlName("NZX") + " NZX"
	cQuery +=  " WHERE NZX.D_E_L_E_T_ = ' '"

	cQuery := ChangeQuery(cQuery)
	oQuery := FWPreparedStatement():New(cQuery)
	cAlias := MPSysOpenQuery(oQuery:GetFixQuery())

	If !(cAlias)->(Eof())
		oMdl309 := FWLoadModel("JURA309")
		oMdl309:SetOperation(3)  // Inclusão

		While !(cAlias)->(Eof())
			oMdl309:Activate()
			oMdl309:SetValue( "O1GMASTER", "O1G_GRPUSU", (cAlias)->NZX_COD   )
			oMdl309:SetValue( "O1GMASTER", "O1G_ROTINA", "6"                 ) // 6=Módulo de auditoria
			oMdl309:SetValue( "O1GMASTER", "O1G_USUINC", UsrRetName(cUserID) )
			oMdl309:SetValue( "O1GMASTER", "O1G_DTINCL", Date()              )
			oMdl309:SetValue( "O1GMASTER", "O1G_BLOQUE", "1"                 ) // Bloqueado? 1=Sim / 2=Não

			lRet := oMdl309:VldData() .AND. oMdl309:CommitData()

			If !lRet
				JurMsgErro(oMdl309:aErrorMessage[6], "JIncO1G: " + STR0011 + (cAlias)->NZX_COD, ;  // "Não foi possível gravar a restrição do Módulo de auditoria para o grupo "
							oMdl309:aErrorMessage[7]) 
			EndIf

			oMdl309:DeActivate()
			(cAlias)->( dbSkip() )
		EndDo

		oMdl309:Destroy()
		oMdl309 := Nil
		(cAlias)->( DbCloseArea() )
	EndIf
	RestArea(aArea)

Return Nil
