#INCLUDE "BADEFAPP.CH"

NEW APP Transporte

//-------------------------------------------------------------------
/*/{Protheus.doc} BAAppTMS
Modelagem da área de TMS.

@author  Angelo Lee
@since   03/12/2018
/*/
//-------------------------------------------------------------------
Class TmsAppFast
	Data cApp

	Method Init() CONSTRUCTOR
	Method ListEntities()
EndClass

//-------------------------------------------------------------------
/*/{Protheus.doc} Init
Instancia a classe de App e gera um nome único para a área. 

@author  Angelo Lee
@since   03/12/2018
/*/
//-------------------------------------------------------------------
Method Init() Class TmsAppFast
	::cApp := "Transporte"
Return Self

//-------------------------------------------------------------------
/*/{Protheus.doc} ListEntities
Lista as entidades (fatos e dimensões) disponíveis da área, deve ser 
necessariamente o nome das classes das entidades.

@author  Angelo Lee
@since   03/12/2018
/*/
//-------------------------------------------------------------------
Method ListEntities() Class TmsAppFast
Return		{"EMPRESA"							, + ;
			"CLIENTE"							, + ;
			"FILIAL"							, + ;
			"REGIAO"							, + ;
			"ITEM"								, + ;
			"43TPDCT"							, + ;//--Tipo Documento de Transporte
			"43NEGTR"							, + ;//--Negociação de Transporte
			"43TTIPT"							, + ;//--Tipo de Transporte
			"43CMPFR"			 				, +	;//--Componente de Frete
			"43SRVNE"							, +	;//--Serviço de Negociação
			"43STIND"							, + ;//--Status da Indenização
			"43RmSeg"							, + ;//--Ramo de Seguro			
			"43Veicu"							, + ;//--Veiculos
			"43REGTR"							, + ;//--Região de Transporte			
			"43TPOCO"							, +	;//--Tipo de Ocorrência
			"43SrvTMS"							, + ;//--Serviço TMS
			"43OcoTpt"							, +	;//--OcorrÊncia de Transporte
			"43Ociosi"							, + ;//--Ociosidade do Veículo
			"43PFMENT"							, +	;//--Performance de Entrega						
			"43TABOCO"							, +	;//--Tabela de ocorrência			
			"43MOVCAR"							, +	;//--Movimentação da Carga									
			"43INDTPT"							, + ;//--Indenização e Transporte
			"43Viage"							, + ;//--Viagens
			"43RESOC"							, + ;//--Responsável Ocorrência
			"43RECTPT"								}//--Receita de Transporte
	
			
