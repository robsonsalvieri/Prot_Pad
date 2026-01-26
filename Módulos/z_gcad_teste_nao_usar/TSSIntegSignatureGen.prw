#Include 'Protheus.ch'   
#DEFINE REMESSA	1
#DEFINE CONSULTA	2
#DEFINE ADMCFG		3
#DEFINE MONITOR	4
//-----------------------------------------------------------------------
/*/{Protheus.doc} getQuery
Executa query

@author Renato Nagib
@since 25/04/2014
@version 1.0 

@param	nProcesso		codigo do Processo em execução
@param	aParametros 	parametros para montagem da query

@return	cQuery		String da query para execução 
/*/
//-----------------------------------------------------------------------
/*/{Protheus.doc} getQuery
Executa query

@author Renato Nagib
@since 25/04/2014
@version 1.0 

@param	nProcesso		codigo do Processo em execução
@param	aParametros 	parametros para montagem da query

@return	cQuery		String da query para execução 
/*/
//-----------------------------------------------------------------------
/*/{Protheus.doc} getQuery
Executa query

@author Renato Nagib
@since 25/04/2014
@version 1.0 

@param	nProcesso		codigo do Processo em execução
@param	aParametros 	parametros para montagem da query

@return	cQuery		String da query para execução 
/*/
//-----------------------------------------------------------------------
/*/{Protheus.doc} getQuery
Executa query

@author Renato Nagib
@since 25/04/2014
@version 1.0 

@param	nProcesso		codigo do Processo em execução
@param	aParametros 	parametros para montagem da query

@return	cQuery		String da query para execução 
/*/
//-----------------------------------------------------------------------
/*/{Protheus.doc} getQuery
Executa query

@author Renato Nagib
@since 25/04/2014
@version 1.0 

@param	nProcesso		codigo do Processo em execução
@param	aParametros 	parametros para montagem da query

@return	cQuery		String da query para execução 
/*/
//-----------------------------------------------------------------------
/*/{Protheus.doc} getQuery
Executa query

@author Renato Nagib
@since 25/04/2014
@version 1.0 

@param	nProcesso		codigo do Processo em execução
@param	aParametros 	parametros para montagem da query

@return	cQuery		String da query para execução 
/*/
//-----------------------------------------------------------------------
function getQuery(nProcesso, cIdEnt, cModelo, cIdInicial, cIdFinal, cStatus)
	
	local cQuery := ""
	Local cPais := getPais(cIdEnt)
	Local cInMod:= ""

	if nProcesso == ADMCFG	//QUERY DO CADASTRO DE EMPRESAS
		cQuery += " SELECT R_E_C_N_O_ REC "
		cQuery += " FROM SPED001M A "
		cQuery += " WHERE A.ID_ENT = '"+cIdEnt+"' "
		cQuery += " AND A.DTULTALT = (SELECT MAX(DTULTALT)""
		cQuery += " FROM SPED001M B "
		cQuery += " WHERE B.ID_ENT = '"+cIdEnt+"'" 
		cQuery += " AND	B.D_E_L_E_T_='') AND "	
		cQuery += " A.D_E_L_E_T_='' "	

	elseif nProcesso == MONITOR//QUERY DO MONITOR 
		cQuery += " SELECT REC50L.R_E_C_N_O_ REC50L, REC54L.R_E_C_N_O_ REC54L, REC52L.R_E_C_N_O_ REC52L "
		cQuery += " FROM SPED050L REC50L "
		cQuery += " LEFT JOIN SPED054L REC54L "
		cQuery += " ON 	REC54L.ID_ENT = REC50L.ID_ENT AND " 
		cQuery += " REC54L.NFE_ID = REC50L.NFE_ID AND "
		cQuery += " REC54L.D_E_L_E_T_=''"
		cQuery += " LEFT JOIN SPED052L REC52L "
		cQuery += " ON 	REC52L.ID_ENT = REC54L.ID_ENT AND "
		cQuery += " REC52L.LOTE   = REC54L.LOTE AND "
		cQuery += " REC52L.D_E_L_E_T_=''"
		cQuery += " WHERE REC50L.NFE_ID BETWEEN '"+cIdInicial+"' AND '"+cIdFinal+"' "
		cQuery += " AND REC50L.ID_ENT ='"+ cIdEnt +"'  "
		cQuery += " AND REC50L.D_E_L_E_T_='' "
		if !empty(cModelo)
			If cPais $ "152" 
				If cModelo $ "S1" 
					cQuery += " AND REC50L.MODELO IN ('S1','S8','SB','SC','SF','SG') "
				ElseIF cModelo $ "S4" 
					cQuery += " AND REC50L.MODELO IN ('S4','S9') "
				ElseIF cModelo $ "S5" 
					cQuery += " AND REC50L.MODELO IN ('S5','SA') "
				EndIf
			Else
			cQuery += " AND REC50L.MODELO = '"+cModelo+ "' "
			EndIf
		endif
		cQuery += " ORDER BY REC50L.ID_ENT,REC50L.NFE_ID,REC52L.LOTE "		

	elseif nProcesso == REMESSA .or. nProcesso == CONSULTA //QUERY DOS JOBS
		cQuery += " SELECT R_E_C_N_O_ "
		cQuery += " FROM SPED050L "
		cQuery += " WHERE "
		cQuery += " ID_ENT IN("+ cIdEnt +") AND "
		cQuery += " STATUS IN("+cStatus+") AND "
		If cPais $ "152|604"
			cQuery += " AMBIENTE IN (SELECT CONTEUDO FROM SPED000L WHERE ID_ENT IN ("+cIdEnt+") AND PARAMETRO='MV_AMBIENT' AND D_E_L_E_T_=' ') AND "
		EndIf
		cQuery += " D_E_L_E_T_='' "
		cQuery += " ORDER BY ID_ENT "
		//CONOUT(cQuery)		
	endif
	
return cQuery

//-----------------------------------------------------------------------
/*/{Protheus.doc} executeQuery
Executa query

@author Renato Nagib
@since 25/04/2014
@version 1.0 

@param	cQuery		String da query a ser executada 

@return	cAlias	Alias de resultado da query
/*/
//-----------------------------------------------------------------------
function executeQuery(cQuery)

	local cAlias := getNextAlias()
	
	cQuery := ChangeQuery( cQuery )
	
	dbUseArea(.T., "TOPCONN", TCGenQry(,,cQuery), cAlias, .F., .T.)
	
	if (cAlias)->(eof())
		(cAlias)->(dbCloseArea())
		cAlias := ""
	endif

return cAlias

//-----------------------------------------------------------------------
/*/{Protheus.doc} TSSSigTag
Função que válida existência da tag e de seu conteúdo.

@author Renato Nagib
@since 28/04/2014
@version 1.0 

@param	cTag			Nome da TAG
@param	cConteudo		Conteúdo da TAF
@param	lBranco		Se aceita branco ou não

@return	cRetorno	A TAG criada
/*/
//-----------------------------------------------------------------------
function TSSSigTag( cTag, cConteudo, lBranco )
	
	Local cRetorno := "" 
	
	Local lBreak   := .F.
	
	Local bErro    := ErrorBlock({|e| lBreak := .T. }) 
	
	DEFAULT lBranco := .F. 
	
	Begin Sequence
		cConteudo := &(cConteudo)
		If lBreak
			BREAK
		EndIf	
	Recover
		If lBranco
			cConteudo := ""
		Else
			cConteudo := Nil
		EndIf
	End Sequence  
	
	ErrorBlock(bErro) 
	
	If cConteudo<>Nil .And. ((!Empty(AllTrim(cConteudo)) .And. (HasAlpha(AllTrim(cConteudo))) .Or. Val(AllTrim(cConteudo))<>0) .Or. lBranco)
		cRetorno := cTag+AllTrim(cConteudo)+SubStr(cTag,1,1)+"/"+SubStr(cTag,2)
	EndIf
	
Return cRetorno

Static Function HasAlpha( cTexto )  

Local lRetorno := .F. 

Local cAux     := ""

While !Empty(cTexto)
	cAux := SubStr(cTexto,1,1)
	If Asc(cAux) > 64 .And. Asc(cAux) < 123
		lRetorno := .T.
		cTexto := ""
	EndIf
		cTexto := SubStr(cTexto,2)
EndDo  

Return lRetorno

//-----------------------------------------------------------------------
/*/{Protheus.doc} retSiglaPais
retorna Sigla do pais de acordo com o codigo 

@author  Renato Nagib
@since   23/04/2014
@version 12 
/*/
//-----------------------------------------------------------------------
function retSiglaPais(cCodPais)

	local cSigla := ""
	
	do Case
	 	case alltrim(cCodPais) == "218"		//Equador
	 		cSigla := "EC"
	 	case alltrim(cCodPais) == "152"		//Chile
	 		cSigla := "CL"
	 	case alltrim(cCodPais) == "170"		//Colombia
	 		cSigla := "CO"
	 	case alltrim(cCodPais) == "858"		//Uruguai
	 		cSigla := "UY"	 			 			 			 			 		
	 	case alltrim(cCodPais) == "604"		//Peru
	 		cSigla := "PE"
	 	case alltrim(cCodPais) == "188"		//Costa Rica
	 		cSigla := "CR"
	 	case alltrim(cCodPais) == "068"		//Bolivia
	 		cSigla := "BO"
	 	case alltrim(cCodPais) == "320"		//Guatemala
	 		cSigla := "GT"	 		
	 	case alltrim(cCodPais) == "484"		//Mexico
	 		cSigla := "MX"
	 	case alltrim(cCodPais) == "032"		//Argentina
	 		cSigla := "AR"	 			 			 			 			 		
	end Case
return cSigla

function getKeySignature(cEntidade, cAmbiente)
		
	local cKey := ""
	
	default cAmbiente := Alltrim( LocGetMv("MV_AMBIENT",cEntidade) )
	
	if cAmbiente == "1"
		cKey := "8fb756ea-87fe-46d5-85fe-b37b8a1efa32"
	else
		cKey := "1436f7ef-b0c1-4cef-8baf-d1453168eba5"
	endif

return cKey

Function getPais(cIdEnt)
	Local cPais := ""
	Local cAlias := ""
	Local cQuery := ""
	cQuery += " SELECT COD_PAIS "
	cQuery += " FROM SPED001M "
	cQuery += " WHERE "
	cQuery += " ID_ENT in ("+ cIdEnt +") AND "
	cQuery += " D_E_L_E_T_='' "
	cQuery += " ORDER BY ID_ENT "
	cAlias := executeQuery(cQuery)
	
	IF !Empty(cAlias)
		while (cAlias)->(!eof())
			cPais := (cAlias)-> COD_PAIS
			(cAlias)->(dbSkip())
		EndDo
	EndIF
	
Return ALLTRIM(cPais)
