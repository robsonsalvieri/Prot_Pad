#INCLUDE "PROTHEUS.CH"
#INCLUDE "LOJXMENUNI.CH"
#INCLUDE "FWADAPTEREAI.CH"

//-------------------------------------------------------------------------------------------------
/*/{Protheus.doc} LjMuDePaCb
Retorna o De\Para de Cadastros Basicos (Ex: SA4, SL6).

@param cMarca	   	- Marca que enviou a mensagem
@param cCodigo	   	- Código do Protheus
@param cValExt 		- InternalId do outro Sistema
@param cTabela		- Tabela utilizada para localizar o De\Para (Ex: SA4, SLG)
@param cCmpCod 		- Nome do campo de código utilizada para localizar o De\Para (Ex: A4_COD, LG_CODIGO)
@param cDescricao 	- Descrição da tabela utilizada para retornar o erro
@param lObriga		- Define se a informação é obrigatória

@return aRet	   - {Logico	,;	- Definindo se encontrou o registro
@return aRet	   	  Caractere}	- Retorna o código do Protheus ou descrição do erro
				
@author  Rafael Tenorio da Costa
@since 	 21/11/2018
@version 1.0				
/*/	
//-------------------------------------------------------------------------------------------------
Function LjMuDePaCb(cMarca 	  , cCodigo, cValExt, cTabela, cCmpCod,;
					cDescricao, lObriga)

	Local aArea	   	 := GetArea()
	Local aAreaXXX 	 := (cTabela)->( GetArea() )
	Local aRet	   	 := {.T., ""}
	Local aAux	   	 := {}
	Local nTamCmpFil := Len(cFilAnt)
	
	Default cMarca	:= "PROTHEUS"
	Default cCodigo := ""
	Default cValExt := ""
	Default lObriga	:= .F.

	If Empty(cCodigo) .And. Empty(cValExt)

		If lObriga
			aRet[1] := .F.
			aRet[2] := I18n(STR0001, {cDescricao})	//"Não foi recebida(o) #1, está informação é obrigatória."
		EndIf

	Else

		//Tenta localizar pelo InternalId
		If !Empty(cValExt)
		
			aAux := Separa( CfgA070Int(cMarca, cTabela, cCmpCod, cValExt), "|")
			
			If Len(aAux) >= 3 .And. !Empty(aAux[3])
				If (RTrim(aAux[2]) == RTrim(xFilial(cTabela)))
					(cTabela)->( DbSetOrder(1) )	//Indice unico de cadastro basico. Ex: A4_FILIAL + A4_COD
					If (cTabela)->( DbSeek( PadR(aAux[2], nTamCmpFil) + PadR(aAux[3], TamSx3(cCmpCod)[1]) ) )
						aRet[1] := .T.
						aRet[2] := &(cTabela + "->" + cCmpCod)
					EndIf
				EndIf
			EndIf

			If Empty(aRet[2])//tenta localizar pelo codigo externo com filial (cadastro AUTOMATICO)
				aAux := Separa( CfgA070Int(cMarca, cTabela, cCmpCod, cEmpAnt + "|" +RTrim( xFilial(cTabela) )+"|"+cValExt), "|")
				If Len(aAux) >= 3 .And. !Empty(aAux[3]) 	
					(cTabela)->( DbSetOrder(1) )	//Indice unico de cadastro basico. Ex: A4_FILIAL + A4_COD
					If (cTabela)->( DbSeek( PadR(aAux[2], nTamCmpFil) + PadR(aAux[3], TamSx3(cCmpCod)[1]) ) )
						aRet[1] := .T.
						aRet[2] := &(cTabela + "->" + cCmpCod)
					EndIf
				EndIf	
			EndIf
		EndIf
		
		//Tenta localizar pelo codigo do protheus
		If Empty(aRet[2]) .And. !Empty(cCodigo)
		
			(cTabela)->( DbSetOrder(1) )	//Indice unico de cadastro basico. Ex: A4_FILIAL + A4_COD
			If (cTabela)->( DbSeek( xFilial(cTabela) + PadR(cCodigo, TamSx3(cCmpCod)[1]) ) )
				aRet[1] := .T.
				aRet[2] := &(cTabela + "->" + cCmpCod)
			EndIf
		EndIf	

		//Se não encontrou retorna erro			
		If Empty(aRet[2])
			aRet[1] := .F.
			aRet[2] := I18n(STR0002, {cDescricao, cCodigo, cValExt})		//"#1 (#2\#3) não integrada no Protheus, verifique o De\Para da integração de #1."
		EndIf

	EndIf
	
	FwFreeObj(aAux)
	
	RestArea(aAreaXXX)
	RestArea(aArea)

Return aRet


//-------------------------------------------------------------------------------------------------
/*/{Protheus.doc} LjINewEst
Retorna uma novo código de Estacao disponivel na SLG (LG_CODIGO)
@return cRet, Código da Estação disponível SLG (LG_CODIGO)
				
@author rafael.pessoa
@since 07/08/2019
@version P12.1.25				
/*/	
//-------------------------------------------------------------------------------------------------
Function LjINewEst(cStation)

Local cRet 		:= ""

Default cStation  := ""

Do While Empty(cRet)

    cStation := Soma1(cStation) 

    If !LjIExEst(cStation) 
        cRet := cStation
        Exit 
    EndIf

EndDo

Return cRet


//-------------------------------------------------------------------------------------------------
/*/{Protheus.doc} LjIExSer
Verifica se a Serie já existe para outro PDV na Filial Corrente
@return lRet, Retorna se a Serie já Existe para outro PDV
				
@author rafael.pessoa
@since 06/08/2019
@version P12.1.25				
/*/	
//-------------------------------------------------------------------------------------------------
Static Function LjIExEst(cStation)

Local lRet 		:= .F.
Local cAliasQry	:= GetNextAlias()
Local cWhere	:= "" 

Default cStation  := ""

cWhere	:= "%"
cWhere	+= "LG_CODIGO = '" + cStation + "'"
cWhere	+= "%"

BeginSql alias cAliasQry
	SELECT	 LG_CODIGO		
	FROM %table:SLG% SLG
	WHERE	LG_FILIAL = %xfilial:SLG%	AND
			%exp:cWhere% 			    AND				
			SLG.%notDel%
EndSql

If (cAliasQry)->(!EoF()) .And. !Empty((cAliasQry)->LG_CODIGO)
	lRet := .T.
EndIf

(cAliasQry)->(DbCloseArea())

Return lRet


//-------------------------------------------------------------------------------------------------
/*/{Protheus.doc} LjINewSer
Retorna uma nova Serie disponivel na SLG (LG_SERIE)
@return cRet, Serie na SLG (LG_SERIE)
				
@author rafael.pessoa
@since 06/08/2019
@version P12.1.25				
/*/	
//-------------------------------------------------------------------------------------------------
Function LjINewSer(cSerie)

Local cRet 		:= ""

Default cSerie  := ""

Do While Empty(cRet)

    cSerie := Soma1(cSerie) 

    //Valida se a Serie nao Existe na SLG e SF2 para poder Usar
    If !LjIExSer(cSerie) .And. !LjIExNF(cSerie)
        cRet := cSerie
        Exit 
    EndIf

EndDo

Return cRet


//-------------------------------------------------------------------------------------------------
/*/{Protheus.doc} LjIExSer
Verifica se a Serie já existe para outro PDV na Filial Corrente
@return lRet, Retorna se a Serie já Existe para outro PDV
				
@author rafael.pessoa
@since 06/08/2019
@version P12.1.25				
/*/	
//-------------------------------------------------------------------------------------------------
Static Function LjIExSer(cSerie)

Local lRet 		:= .F.
Local cAliasQry	:= GetNextAlias()
Local cWhere	:= "" 

Default cSerie  := ""

cWhere	:= "%"
cWhere	+= "LG_SERIE = '" + cSerie + "'"
cWhere	+= "%"

BeginSql alias cAliasQry
	SELECT	 LG_SERIE		
	FROM %table:SLG% SLG
	WHERE	LG_FILIAL = %xfilial:SLG%	AND
			%exp:cWhere% 			    AND				
			SLG.%notDel%
EndSql

If (cAliasQry)->(!EoF()) .And. !Empty((cAliasQry)->LG_SERIE)
	lRet := .T.
EndIf

(cAliasQry)->(DbCloseArea())

Return lRet


//-------------------------------------------------------------------------------------------------
/*/{Protheus.doc} LjIExNF
Verifica se a Serie já existe nos Documentos de Saida SF2 na Filial Corrente
@return lRet, Retorna se a já Existe documento de Saida com essa Serie
				
@author rafael.pessoa
@since 06/08/2019
@version P12.1.25				
/*/	
//-------------------------------------------------------------------------------------------------
Static Function LjIExNF(cSerie)

Local lRet 		:= .F.
Local cAliasQry	:= GetNextAlias()
Local cWhere	:= "" 

Default cSerie  := ""

cWhere	:= "%"
cWhere	+= "F2_SERIE = '" + cSerie + "'"
cWhere	+= "%"

BeginSql alias cAliasQry
	SELECT	 F2_SERIE		
	FROM %table:SF2% SF2
	WHERE	F2_FILIAL = %xfilial:SF2%	AND
			%exp:cWhere% 			    AND				
			SF2.%notDel%
EndSql

If (cAliasQry)->(!EoF()) .And. !Empty((cAliasQry)->LG_SERIE)
	lRet := .T.
EndIf

(cAliasQry)->(DbCloseArea())

Return lRet
