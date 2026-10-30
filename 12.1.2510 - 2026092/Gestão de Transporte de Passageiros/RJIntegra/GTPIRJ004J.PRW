#INCLUDE "PROTHEUS.CH"
#INCLUDE "RESTFUL.CH"
#INCLUDE "FWMVCDEF.CH"

//------------------------------------------------------------------------------------------
/*/{Protheus.doc} GTPIRJ004J

Função utilizada para consumir o serviço através de um JOB via Schedule

@type 		function
@sample 	GTPIRJ004J()
@author 	João Pires
@since 		02/06/2026
@version 	1.0
/*/
//
//------------------------------------------------------------------------------------------
Function GTPIRJ004J()
	Local cEmpRJ := ALLTRIM(MV_PAR01)
	Local dDtIni := MV_PAR02
	Local cHrIni := MV_PAR03
	Local dDtFim := MV_PAR04
	Local cHrFim := MV_PAR05
   	Local aParam := {}

	dDtIni := Iif(Empty(dDtIni),dDataBase-1,dDtIni)
	dDtFim := Iif(Empty(dDtFim),dDataBase-1,dDtFim)
	cHrIni := Iif(Empty(cHrIni),"00:00",cHrIni)
	cHrFim := Iif(Empty(cHrFim),"23:59",cHrFim)

    	aParam := {cEmpRJ,dDtIni,cHrIni,dDtFim,cHrFim}
	GI004AUT(aParam)

    	aSize(aParam,0)
Return


/*/{Protheus.doc} SchedDef
Retorna informacoes de definicao dos parametros do schedule.
@author Luiz.jesus
@since 06/04/2023
@version 1.0
@Return  Array com as informacoes de definicao dos parametros do schedule
		 Array[x,1] -> Caracter, Tipo: "P" - para Processo, "R" - para Relatorios
		 Array[x,2] -> Caracter, Nome do Pergunte
		 Array[x,3] -> Caracter, Alias(para Relatorio)
		 Array[x,4] -> Array, Ordem(para Relatorio)
		 Array[x,5] -> Caracter, Titulo(para Relatorio)
/*/
Static Function SchedDef()
	Local aParam := { "P", "GTPIRJ004", Nil, Nil, Nil }

Return aParam
