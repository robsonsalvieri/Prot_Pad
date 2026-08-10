#INCLUDE "BADEFINITION.CH"

NEW APP JURIDIC

//-------------------------------------------------------------------
/*/{Protheus.doc} BAAppJuridico
Modelagem da área de Juridico.

@author  Helio Leal
@author  henrique.cesar
@since   05/03/2018
/*/
//-------------------------------------------------------------------
Class BAAppJuridico
	Data cApp

	Method Init() CONSTRUCTOR
	Method ListEntities()
EndClass

//-------------------------------------------------------------------
/*/{Protheus.doc} Init
Instancia a classe de App e gera um nome único para a área. 

@author  Helio Leal
@author  henrique.cesar
@since   05/03/2018
/*/
//-------------------------------------------------------------------
Method Init() Class BAAppJuridico
	::cApp := "Jurídico"
Return Self

//-------------------------------------------------------------------
/*/{Protheus.doc} ListEntities
Lista as entidades (fatos e dimensões) disponíveis da área, deve ser 
necessariamente o nome das classes das entidades.

@author  Helio Leal
@author  henrique.cesar
@since   05/03/2018
/*/
//-------------------------------------------------------------------
Method ListEntities() Class BAAppJuridico

Return	{   "ANALISEPROCPEDIDOS", + ; //Fato BAAnaliseProcPedidos
			"AUDDESPESA", + ; //Fato BAAuditDespesa
			"AUDGARANTIA", + ; //Fato BAAuditGarantia
			"AUDOBJETOS", + ; //Fato BAAuditObjetos
			"AUDPEDIDOS", + ; //Fato BAAuditPedidos
			"AUDPROCESSO", + ; //Fato BAAuditProcesso
			"BENEFICIOECON", + ; //Fato BABeneficioEcon
			"PROCABERTOENCERRADO", + ; //Fato BAProcAbertosEncerrados
			"PROCANDAMENTO", + ; //Fato BAProcAndamento
			"PROCVALORES", + ; //Fato BAProcessoValores
			"PROVISACONSOLIDADA", + ; //Fato BAProvisaoConsolidada
			"COMPGARANTIA", + ; //Fato BAAuditCompGarantia
			"COMPCONTINGENCIA", + ; //Fato BACompContingencia
			"EMPRESA", + ; //Dimensão BAEmpresa
			"FILIAL", + ; //Dimensão BAFilial
			"ASSJURIDICO", + ; //Dimensão BAAssuntoJuridico
			"AREASJURIDICO", + ; //Dimensão BAAreasJuridico
			"COMARCA", + ; //Dimensão BAComarca
			"TPDESPESA", + ; //Dimensão BATpDespesa
			"MARCA", + ; //Dimensão BAMarca
			"TPGARANTIA", + ; //Dimensão BATpGarantia
			"FORMACORRECAO", + ; //Dimensão BAFormaCorrecao
			"PROGNOSTICO", + ; //Dimensão BAPrognostico
			"DECISAO", + ; //Dimensão BADecisao
			"BASEDECISAO", + ; //Dimensão BABaseDecisao
			"FUNDSOBJETO", + ; //Dimensão BAFundsObjeto
			"CLIENTE", + ; //Dimensão BACliente
			"CENTROCUSTO", + ; //Dimensão BACentroCusto
			"SUBAREA", + ; //Dimensão BASubArea
			"MOTIVENCERRAMENTO", + ; //Dimensão BAMotivEncerramento
			"CREDENCIADO", + ; //Dimensão BACredenciado
			"TPACAO", + ; //Dimensão BATpAcao
			"FOROTRIBUNAL", + ; //Dimensão BAForoTribunal
			"VARACAMARA", + ; //Dimensão BAVaraComarca
			"CARGO", + ; //Dimensão BACargo
			"FUNCAO", + ; //Dimensão BAFuncao
			"LOCALTRABALHO", + ; //Dimensão BALocalTrabalho
			"PROCESSO", + ; //Dimensão Processo
			"OBJJURIDICO", + ; //Dimensão ObjetoJuridico
			"PEDJURIDICO" } //Dimensão BAPedJuridico




