#INCLUDE "PROTHEUS.CH"
#INCLUDE "PLSMGER.CH"
#INCLUDE "hatActions.ch"

//-------------------------------------------------------------------
/*/{Protheus.doc}) PLHATMap
Retorna o array com os campos/tags correspondentes de cada API do HAT

Retorno:
[01] - Tag do HAT
[02] - Campo PLS
[03] - Indica se a tag pode ser gerada vazia

@author  Renan Sakai 
@version P12
@since    29.10.18
/*/
//-------------------------------------------------------------------
Function PLHATMap(cAlias)
    Local aRet := {}

    /*-----------------------------------------------
    API: batchesAuthorization/integration
    Acoes: _billing_BCI_alt         "0050" 
    -------------------------------------------------*/
    if cAlias == "BCI"
         Aadd(aRet,{'batchNumber','BCI_LOTGUI',.F.})
        Aadd(aRet,{'healthProviderId','BCI_CODRDA',.F.})
        Aadd(aRet,{'status','BCI_STTISS',.F.})
        Aadd(aRet,{'value','BCI_VLRGUI',.F.})  
        Aadd(aRet,{'glossedValue','BCI_VLRGLO',.F.})
        Aadd(aRet,{'step','BCI_FASE',.F.})
    endif 

Return aRet
//-------------------------------------------------------------------
