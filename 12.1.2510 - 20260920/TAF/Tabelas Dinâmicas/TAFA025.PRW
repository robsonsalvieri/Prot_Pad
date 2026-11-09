#INCLUDE "PROTHEUS.CH"
#INCLUDE "TAFA025.CH"

//-------------------------------------------------------------------
/*/{Protheus.doc} FAtuCont

Rotina para carga e atualização da tabela autocontida para Tipos de Eventos.

@Param nVerEmp - Versão corrente na empresa
       nVerAtu - Versão atual ( passado como referência )

@Return	aRet - Array com estrutura de campos e conteúdo da tabela

@Author	juan.felipe
@Since 27/10/2025
@Version 1.0
/*/
//-------------------------------------------------------------------
Static Function FAtuCont( nVerEmp, nVerAtu )
	Local aHeader := {}
	Local aBody   := {}
	Local aRet 	  := {}

	nVerAtu := 1033.82

	If nVerEmp < nVerAtu
		aAdd( aHeader, "T7E_FILIAL" )
		aAdd( aHeader, "T7E_ID" 	)
		aAdd( aHeader, "T7E_EVENTO" )
		aAdd( aHeader, "T7E_DESCRI" )
		aAdd( aHeader, "T7E_AUTOR"  )
		aAdd( aHeader, "T7E_TEMITE" )

		aAdd( aBody, { "", "000001", "112110", STR0002, "1", "2" } ) //-- Informação de efetivo pagamento integral para liberar crédito presumido do adquirente
		aAdd( aBody, { "", "000002", "112120", STR0003, "1", "1" } ) //-- Importação em ALC/ZFM não convertida em isenção
		aAdd( aBody, { "", "000003", "112130", STR0004, "1", "1" } ) //-- Perecimento, perda, roubo ou furto durante o transporte contratado pelo fornecedor
		aAdd( aBody, { "", "000004", "112140", STR0005, "1", "1" } ) //-- Fornecimento não realizado com pagamento antecipado
		aAdd( aBody, { "", "000005", "112150", STR0006, "1", "2" } ) //-- Atualização da Data de Previsão de Entrega
		aAdd( aBody, { "", "000006", "211110", STR0007, "2", "1" } ) //-- Solicitação de Apropriação de crédito presumido
		aAdd( aBody, { "", "000007", "211120", STR0008, "4", "1" } ) //-- Destinação de item para consumo pessoal
		aAdd( aBody, { "", "000008", "211124", STR0009, "2", "1" } ) //-- Perecimento, perda, roubo ou furto durante o transporte contratado pelo adquirente
		aAdd( aBody, { "", "000009", "211128", STR0010, "2", "2" } ) //-- Aceite de débito na apuração por emissão de nota de crédito
		aAdd( aBody, { "", "000010", "211130", STR0011, "2", "1" } ) //-- Imobilização de Item
		aAdd( aBody, { "", "000011", "211140", STR0012, "2", "1" } ) //-- Solicitação de Apropriação de Crédito de Combustível
		aAdd( aBody, { "", "000012", "211150", STR0013, "2", "1" } ) //-- Solicitação de Apropriação de Crédito para bens e serviços que dependem de atividade do adquirente
		aAdd( aBody, { "", "000013", "212110", STR0014, "3", "2" } ) //-- Manifestação sobre Pedido de Transferência de Crédito de IBS em Operações de Sucessão
		aAdd( aBody, { "", "000014", "212120", STR0015, "3", "2" } ) //-- Manifestação sobre Pedido de Transferência de Crédito de CBS em Operações de Sucessão
		aAdd( aBody, { "", "000017", "110001", STR0016, " ", "2" } ) //-- Cancelamento de Evento

		aAdd( aRet, { aHeader, aBody } )
	EndIf
Return( aRet )
