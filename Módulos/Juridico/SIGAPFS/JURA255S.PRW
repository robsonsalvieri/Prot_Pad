//-------------------------------------------------------------------
/*/{Protheus.doc} JURA255S
Chamada via schedule para atualizar a posição do contas a receber referente ao ano-mês atual

@author Bruno Ritter
@since 07/02/2018
@version 1.0
/*/
//-------------------------------------------------------------------
Function JURA255S()

	J255UpdHis()

Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} SchedDef
Parâmetros para execução via Schedule.

@author  Bruno Ritter | Jorge Martins
@since   09/02/2018
/*/
//-------------------------------------------------------------------
Static Function SchedDef()
Local aOrd   := {}
Local aParam := {}

aParam := { "P"       ,; // Tipo R para relatorio P para processo
            "PARAMDEF",; // Pergunte do relatorio, caso nao use passar ParamDef
            ""        ,; // Alias
            aOrd      ,; // Array de ordens
          }
Return aParam

//------------------------------------------------------------------------------
