#INCLUDE "PROTHEUS.CH"

//-------------------------------------------------------------------
/*/{Protheus.doc} Classe RmiGrvMsgExternoObj
Classe responsável em gravar o Json de publicação no campo MHQ_MENSAG
    
/*/
//-------------------------------------------------------------------
Class RmiGrvMsgPubTerceirosObj From RmiGrvMsgPubPdvSyncObj
    Method New()            	//Metodo construtor da Classe
    Method Venda()              //Efetua tratamentos especificos na publicação da venda 
    Method Especificos(cPonto)  //Efetua tratamento especificos para a publicação da MHQ_MENSAG.
EndClass

//-------------------------------------------------------------------
/*/{Protheus.doc} New
Método construtor da Classe

@author  Everson S P Junior
@version 1.0
/*/
//-------------------------------------------------------------------
Method New() Class RmiGrvMsgPubTerceirosObj
    _Super:New("TERCEIROS")
    self:oBuscaObj  := RmiBusTerceirosObj():New()

Return Nil

//--------------------------------------------------------
/*/{Protheus.doc} Venda
Efetua tratamentos especificos na publicação da venda Pdv 
Terceiros

@author  Danilo Rodrigues
@version 1.0
@since   19/01/22   
/*/
//--------------------------------------------------------
Method Venda() Class RmiGrvMsgPubTerceirosObj

    LjGrvLog( "RmiGrvMsgExternoObj", "Metodo de Venda para PDV Terceiros." )

Return Nil


//--------------------------------------------------------
/*/{Protheus.doc} Especificos
Efetua tratamento especificos para a publicação da MHQ_MENSAG.

@type    Method
@param   cPonto, Caractere, Define o ponto onde esta sendo chamado o metodo.
@author  Rafael Tenorio da Costa
@version 1.0
@since   01/12/21   
/*/
//--------------------------------------------------------
Method Especificos(cPonto) Class RmiGrvMsgPubTerceirosObj

    Local cProcesso := AllTrim(self:oBuscaObj:cProcesso)

    If cPonto == "INICIO"
    
        If cProcesso == "VENDA"

            //Atualiza a filial para a que será processada, para a correta execução do layout de publicação
            cFilAnt := self:oBuscaObj:oRegistro["Loja"]["IdRetaguarda"]

            //Carrega o Xml da Sefaz para ficar disponivel para a publicação (oXmlSefaz).
            self:CarregaXml()
            
            // -- Se for Inutilização simplifico o layout para os campos que serão necessarios.
            If self:oBuscaObj:cEvento == "3"
                Self:Inutilizacao()
            EndIf 
        EndIf

    ElseIf cPonto == "FIM"

        If cProcesso == "VENDA"
            self:Venda()
        EndIf

    EndIf

Return Nil
