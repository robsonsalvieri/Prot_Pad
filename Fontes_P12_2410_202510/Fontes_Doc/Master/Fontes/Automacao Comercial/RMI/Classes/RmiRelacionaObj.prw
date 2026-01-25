#INCLUDE "PROTHEUS.CH"
#INCLUDE "RMIRELACIONAOBJ.CH"

//-------------------------------------------------------------------
/*/{Protheus.doc} Classe RmiRelacionaObj
Classe responsável pela Gravação/Consulta dos relacionamentos 
das tabelas auxiliares
    
/*/
//-------------------------------------------------------------------
Class RmiRelacionaObj
    
    Data oMessageError      As Object
    Data cTipRel            As Character    //Tipo do relacionamento a ser trabalhado

    Method New()                              //Metodo construtor da classe

    Method Inclui(cFilent,cEntrada,cSaida)    //Metodo responsável pela inclusão dos dados do relacionamento

    Method Grava(cFilent,cEntrada,cSaida)     //Metodo responsável pela gravação dos dados do relacionamento

    Method Exclui(cFilent,cEntrada,cSaida)    //Metodo responsável pela exclusão dos dados do relacionamento

    Method Consulta(lEntr,cVal,cFil)          //Metodo responsavel por realizar a consulta dos dados do relacionamento

    Method Limpa()                            //Metodo para fechar a area da tabela de relacionamentos

    Method SetTipo(cTipo)                     //Metodo para definir o tipo  do relacionamento a ser trabalhado

EndClass
//-------------------------------------------------------------------
/*/{Protheus.doc} New
Metodo construtor da classe

@type    method
@param  cTipo   -> Definição do tipo do relacionamento que será manipulado (Exemplo: FECP/PISCOFINS)

@author  Evandro Pattaro
@since   03/11/2021
@version 1.0
/*/
//-------------------------------------------------------------------
Method New() Class RmiRelacionaObj
    Local   cComp := FWModeAccess("MIL",1)

    Self:oMessageError := LjMessageError():New()

    If cComp == 'C'
        DbSelectArea("MIL")
        MIL->(DbSetOrder(1))    //MIL_FILIAL, MIL_TIPREL, MIL_FILENT, MIL_ENTRAD, MIL_SAIDA, R_E_C_N_O_, D_E_L_E_T_
    Else
        Self:oMessageError:SetError(GetClassName(Self),STR0001,1) //"Tabela de relacionamentos (MIL) exclusiva. Configurar compartilhamento da tabela para compartilhado a nível de empresa."
    EndIf

Return Nil
//-------------------------------------------------------------------
/*/{Protheus.doc} Inclui
Metodo responsável pela Inclusão dos dados do relacionamento
@type    method

@param  cFilent    -> String - Indica a filial do valor de entrada. Irá depender do compartilhamento do cadastro da entrada.
@param  cEntrada    -> String - Indica o código da entrada. 
@param  cSaida    -> String - Indica o código de saída do relacionamento.

@author  Evandro Pattaro
@since   03/11/2021
@version 1.0
/*/
//-------------------------------------------------------------------
Method Inclui(cFilent,cEntrada,cSaida) Class RmiRelacionaObj
Local aRet := {}

aRet := Self:Consulta(.T.,cEntrada,cFilent)
If Len(aRet) > 0
    If aRet[1,4] != cSaida
        Self:Exclui(aRet[1,2],aRet[1,3],aRet[1,4])
    EndIf
EndIf
If Self:oMessageError:GetStatus()
    Self:Grava(cFilent,cEntrada,cSaida)
EndIf

Return Nil
//-------------------------------------------------------------------
/*/{Protheus.doc} Grava
Metodo responsável pela gravação dos dados do relacionamento
@type    method

@param  cFilent    -> String - Indica a filial do valor de entrada. Irá depender do compartilhamento do cadastro da entrada.
@param  cEntrada    -> String - Indica o código da entrada. 
@param  cSaida    -> String - Indica o código de saída do relacionamento.

@author  Evandro Pattaro
@since   03/11/2021
@version 1.0
/*/
//-------------------------------------------------------------------
Method Grava(cFilent,cEntrada,cSaida) Class RmiRelacionaObj

Default cFilent := Space(FwSizeFilial())

cFilent     := padR(cFilent , TamSX3("MIL_FILENT")[1]   )
cEntrada    := padR(cEntrada, TamSX3("MIL_ENTRAD")[1]   )
cSaida      := padR(cSaida  , TamSX3("MIL_SAIDA")[1]    )    

If !Empty(Self:cTipRel)
    If !MIL->( DbSeek(xFilial("MIL") + Self:cTipRel + cFilent + cEntrada + cSaida) )
    
        RecLock("MIL", .T.)
            MIL->MIL_FILIAL := xFilial("MIL")
            MIL->MIL_TIPREL := Self:cTipRel
            MIL->MIL_FILENT := cFilent
            MIL->MIL_ENTRAD := cEntrada
            MIL->MIL_SAIDA  := cSaida
        MIL->( MsUnLock() )

    EndIf
Else
    Self:oMessageError:SetError(GetClassName(Self),STR0003,1)  //"Tipo do relacionamento não especificado."    
EndIf    

Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} Exclui
Metodo responsável pela exclusão dos dados do relacionamento
@type    method

@param  cFilent    -> String - Indica a filial do valor de entrada. Irá depender do compartilhamento do cadastro da entrada.
@param  cEntrada    -> String - Indica o código da entrada. 
@param  cSaida    -> String - Indica o código de saída do relacionamento.

@author  Evandro Pattaro
@since   03/11/2021
@version 1.0
/*/
//-------------------------------------------------------------------
Method Exclui(cFilent,cEntrada,cSaida) Class RmiRelacionaObj

cEntrada := PadR(AllTrim(cEntrada),TamSX3("MIL_ENTRAD")[1])
cSaida  := PadR(AllTrim(cSaida),TamSX3("MIL_SAIDA")[1])

If !Empty(Self:cTipRel)
    If MIL->(DbSeek(xFilial("MIL")+Self:cTipRel + cFilent + cEntrada + cSaida))
        RecLock("MIL", .F.)
            MIL->(dbDelete())    
        MIL->( MsUnLock() )    
    Else
        Self:oMessageError:SetError(GetClassName(Self),STR0004,1)   //"Registro não localizado."              
    EndIf 
Else
    Self:oMessageError:SetError(GetClassName(Self),STR0003,1) //"Tipo do relacionamento não especificado."          
EndIf

Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} Consulta
Metodo responsavel por realizar a consulta dos dados do relacionamento
@type    method
@param  lEntr   -> {

.T. = Pesquisa pelo valor de entrada. Serão retornadas os valores de saída. ;

.F. = Pesquisa pelo valor de saída. Serão retornados os valores de entrada.

}
@param  cVal    -> Conteudo a ser consultado. Caso não seja informado, retornará todas as entradas de acordo com o tipo de relacionamento especificado.
@param  cFil    -> Filial a ser consultada. Caso não seja informada, retornará todas a filiais do resultado da consulta.

@return aRet    Array com os dados da filial do registro | dado de entrada/saída

@author  Evandro Pattaro
@since   03/11/2021
@version 1.0
/*/
//-------------------------------------------------------------------
Method Consulta(lEntr,cVal,cFil) Class RmiRelacionaObj
    
    Local cAlias    := GetNextAlias()
    Local cQuery    := ""
    Local aRet      := {}
    Local cWhere    := IIF(lEntr,"MIL_ENTRAD","MIL_SAIDA")

    Default cFil := ""
    Default cVal := ""
    cQuery := " SELECT MIL_TIPREL,MIL_FILENT,MIL_ENTRAD,MIL_SAIDA"
    cQuery += " FROM "+RetSqlName("MIL")
    cQuery += " WHERE D_E_L_E_T_  = ' '

    If !Empty(cVal)
        cQuery += "AND "+cWhere+" = '"+UPPER(ALLTRIM(cVal))+"'"
    EndIf

    If !Empty(Self:cTipRel)
        cQuery += "AND MIL_TIPREL = '"+Self:cTipRel+"' 
    EndIf

    If !Empty(cFil)
        cQuery += " AND MIL_FILENT = '"+cFil+"'"
    EndIf

    LjGrvLog(" RmiRelacionaObj ", "Method Consulta() cQuery => "+cQuery )
    
    DbUseArea(.T., "TOPCONN", TcGenQry( , , cQuery), cAlias, .T., .F.)

    While !(cAlias)->( Eof() )
        Aadd(aRet,{(cAlias)->MIL_TIPREL,(cAlias)->MIL_FILENT,(cAlias)->MIL_ENTRAD,(cAlias)->MIL_SAIDA})
        (cAlias)->(DbSkip())
    EndDo
    (cAlias)->(DbCloseArea()) 
Return aRet

//-------------------------------------------------------------------
/*/{Protheus.doc} Limpa
Prepara objeto para o proximo processamento.

@author  Evandro Pattaro
@since   03/11/2021
@version 1.0
/*/
//-------------------------------------------------------------------
Method Limpa() Class RmiRelacionaObj

    self:oMessageError:ClearError()

Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} SetTipo
Metodo para definir o tipo  do relacionamento a ser trabalhado
@type    method
@param  cTipo   -> Definição do tipo do relacionamento que será manipulado (Exemplo: FECP/PISCOFINS)

@author  Evandro Pattaro
@since   16/11/2021
@version 1.0
/*/
//-------------------------------------------------------------------
Method SetTipo(cTipo) Class RmiRelacionaObj

    Self:cTipRel := PadR(UPPER(ALLTRIM(cTipo)),TamSX3("MIL_TIPREL")[1])

Return Nil

