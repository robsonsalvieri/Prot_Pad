#INCLUDE "PROTHEUS.CH"

//-------------------------------------------------------------------
/*/{Protheus.doc} TAFSST1
Rotina para Limpeza das tabelas referentes ao SST na versão 2.5
referentes ao evento S-2240.

@obs - Essa rotina deve ser descontinuada no segundo semestre de 2021,
ela foi criada somente para o WR de Abr/2021.

@return nil 

@Author Evandro dos Santos Oliveira Teixeira
@Since 14/04/2021
@Version 1.0
/*/
//-------------------------------------------------------------------
Main Function TAFSST1()

    If(IsBlind(), TAFConOut("[TAFSST1] Atenção! Esta rotina foi descontinuada!"),;
        MsgAlert("[TAFSST1] Esta rotina foi descontinuada!", "Atenção!"))

Return 

//-------------------------------------------------------------------
/*/{Protheus.doc} tafajustSST
Rotina para Limpeza das tabelas referentes ao SST na versão 2.5

@param lAtualizador - Identifica se a chamada da rotina foi executada
pelo atualizador (ou smart e-social)

@param jParam - parametros de controle do ambiente:
{
    "blind":true,
    "user":"admin",
    "password":"",
    "simulacao":false,
    "localizacao":"BRA",
    "sixexclusive":true,
    "empresas":["99", "01"],
    "logprocess":true,
    "logatualizacao":true,
    "logwarning":true,
    "loginclusao":true,
    "logcritical":true,
    "updstop":false,
    "oktoall":true,
    "deletebkp":true,
    "keeplog":true
}

@return lOkGrp - retorna verdadeiro se a rotina conseguiu excluir as tabelas
ou se a exclusão não for necessária por conta da parametrização do ambiente.

@Author Evandro dos Santos Oliveira Teixeira
@Since 14/04/2021
@Version 1.0
/*/
//-------------------------------------------------------------------
Function tafajustSST()
    
    If(IsBlind(), TAFConOut("[tafajustSST] Atenção! Esta rotina foi descontinuada!"),;
        MsgAlert("[tafajustSST] Esta rotina foi descontinuada!", "Atenção!"))
    
Return
