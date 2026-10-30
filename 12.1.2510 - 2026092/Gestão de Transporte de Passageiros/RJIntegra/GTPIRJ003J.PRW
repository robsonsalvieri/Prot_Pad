#INCLUDE "PROTHEUS.CH"
#INCLUDE "RESTFUL.CH"
#INCLUDE "FWMVCDEF.CH"

//------------------------------------------------------------------------------------------
/*/{Protheus.doc} GTPIRJ003J

Função utilizada para consumir o serviço através de um JOB via Schedule

@type 		function
@sample 	GTPIRJ003J()
@author 	João Pires
@since 		02/06/2026
@version 	1.0
/*/
//GI003JOB()
//------------------------------------------------------------------------------------------
Function GTPIRJ003J()
	Local dDtRef  := MV_PAR01
	Local cEmpRj  := ALLTRIM(MV_PAR02)
	Local aParam  := {}

	dDtRef := STRTRAN(dDtRef,"Date(","")
	dDtRef := STRTRAN(dDtRef,")","")
	dDtRef := STOD(dDtRef)

	dDtRef := IIF(Empty(dDtRef),dDatabase-1,dDtRef)

	aParam := {dDtRef,cEmpRj}

	GI003AUT(aParam)

	ASize(aParam,0)
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
	Local aParam := { "P", "GTPIRJ003", Nil, Nil, Nil }

Return aParam
