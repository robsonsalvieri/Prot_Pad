#INCLUDE "PROTHEUS.CH"
#INCLUDE "TOPCONN.CH"


/*/{Protheus.doc} TSI
	Mecanismo responsável por chamar o motor de integração
	@author Wesley Matos

    Com as mudanças no SCHEDULE na release 12.1.2610, houve a necessidade de criar um novo fonte (TSI.prw).
    Esse fonte contém a função principal TSI() que irá chamar o motor TAFA573, antigo programa principal do TSI.
   
	@since 02/07/2026
	@return Nil, nulo, não tem retorno. 
/*/
Function TSI()

    TAFA573({cEmpAnt,cFilAnt})

Return Nil


//-------------------------------------------------------------------
/*/{Protheus.doc} SchedDef
Informacoes de definicao dos parametros do schedule
@Return  Array com as informacoes de definicao dos parametros do schedule
		 Array[x,1] -> Caracter, Tipo: "P" - para Processo, "R" - para Relatorios
		 Array[x,2] -> Caracter, Nome do Pergunte
		 Array[x,3] -> Caracter, Alias(para Relatorio)
		 Array[x,4] -> Array, Ordem(para Relatorio)
		 Array[x,5] -> Caracter, Titulo(para Relatorio)
         Array[x,6] -> Caracter, Layout de impressão
         Array[x,7] -> Logico, Permite agendamento sempre ativo?
         Array[x,7] -> Logico, Permite agendamento por filiais? 

@author Wesley Matos
@since  02/07/2026
@version 1.0

/*///----------------------------------------------------------------
Static Function SchedDef()

	Local aParam  := {}
    Local cRelRpo := GetRPORelease()

	aParam := { 'P','ParamDef', '', {}, '', ''}

    If cRelRpo >= '12.1.2610'
        aAdd(aParam, .F.) // Sempre Ativo
        aAdd(aParam, .T.) // Seleção de Filiais
    EndIf

Return ( aParam )

