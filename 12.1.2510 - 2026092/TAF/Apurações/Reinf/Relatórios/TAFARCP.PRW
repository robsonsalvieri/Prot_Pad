#INCLUDE "PROTHEUS.CH" 

//-------------------------------------------------------------------
/*/{Protheus.doc} TAFARCP
Relatório em TReport para previa análise das informações que serão transmitidas
refernte aos eventos R-2010 e R-2020 

@author Henrique Pereira;
@since 10/08/2018
@version 1.0
/*/
//-------------------------------------------------------------------

Function TAFARCP(cPerApu, aFiliais, cEvent)

	MsgInfo("Prezado cliente, este relatório foi descontinuado. Para informações referente aos eventos R-2010 e R-2020 utilizar o painel REINF.")

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} TAFARCP
Busca a informação na determinada tabela pelo campo _ID

@author Henrique Pereira;
@since 10/08/2018
@version 1.0
/*/
//-------------------------------------------------------------------

Function SqlId20xx(cAlias as character, cId as character,  cCmpRet as character )
Local cRet		as character 
Local cAlsCons	as character
Local cSelect	as character
Local cFrom		as character
Local cWhere	as character 

cRet		:= 	''
cAlsCons	:=	GetNextAlias()
cSelect		:=	cCmpRet 
cFrom		:=	RetSqlName(cAlias) + ' ' + cAlias
cWhere		:=	cAlias + '.' + cAlias + "_ID = '" + cId + "' AND D_E_L_E_T_ <> '*' " 

	cSelect		:= "%" + cSelect 	+ 	"%"
	cFrom		:= "%" + cFrom 	+ 	"%"
	cWhere		:= "%" + cWhere 	+ 	"%"

	BeginSql Alias cAlsCons
		SELECT 
		%EXP:cSelect%
		FROM
		%EXP:cFrom%
		WHERE
		%EXP:cWhere%
	EndSql

	if SELECT(cAlsCons) > 0
		cRet := (cAlsCons)->&cCmpRet
	else
		cRet := 'Conteúdo Indisponível'
	endIf

Return (cRet)
