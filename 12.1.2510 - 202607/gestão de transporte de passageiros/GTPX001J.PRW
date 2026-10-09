#include 'protheus.ch'
#INCLUDE 'FWMVCDEF.CH'

//------------------------------------------------------------------------------------------
/*/{Protheus.doc} GTPX001J

Função utilizada para consumir o serviço através de um JOB via Schedule

@type 		function
@sample 	GTPX001J()
@author 	João Pires
@since 		02/06/2026
@version 	1.0
/*/
//
//------------------------------------------------------------------------------------------
Function GTPX001J()
	Local dDtIni := MV_PAR01
	Local dDtFim := MV_PAR02
	Local cAgenc := ALLTRIM(MV_PAR03)

	dDtIni := Iif(Empty(dDtIni),dDataBase-1,dDtIni)
	dDtFim := Iif(Empty(dDtFim),dDataBase-1,dDtFim)

	GTPJBPE(.T., Nil, DTOS(dDtIni), DTOS(dDtFim), cAgenc)
	
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
	Local aParam := { "P", "GTPR600", Nil, Nil, Nil }

Return aParam
