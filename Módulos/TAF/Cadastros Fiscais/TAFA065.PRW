#INCLUDE "PROTHEUS.CH" 
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "TAFA065.CH"

//-------------------------------------------------------------------
/*/{Protheus.doc} TAFA065
Det Base  Calc Cred Apur Per PIS/COFINS
Ajuste da Contribuição do Pis/Cofins 

@author: 
02/08/2012 - Marcio Nunes
03/10/2014 - Alterado por Rodrigo Aguilar

@since 02/08/2012
@version 1.0

/*/
//-------------------------------------------------------------------
Function TAFA065()
	Taf065Vld() //Chama a função de validação
	MsgInfo('Prezado cliente, o cadastro de detalhes do crédito de apuração do PIS/COFINS relativo ao periodo foi descontinuado!')
Return .t.

//-------------------------------------------------------------------
/*/{Protheus.doc} Taf065Vld

Funcao que valida os dados do registro posicionado,
verificando se ha incoerencias nas informacões 

lJob - Informa se foi chamado por Job

@return .T.

@author:
24/02/2014 - Paulo V.B. Santana
03/10/2014 - Alterado por Rodrigo Aguilar

@since 24/02/2014
@version 1.0
/*/                                                                                                                                          
//-------------------------------------------------------------------
Function Taf065Vld(cAlias,nRecno,nOpc,lJob)
	Local aLogErro := {}
Return(aLogErro)
