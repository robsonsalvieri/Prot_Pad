#include 'Protheus.ch'
#include "Fileio.ch"

//-------------------------------------------------------------------
/*/{Protheus.doc} PLSBCIOBSSvc

@author    Lucas Nonato
@version   V12
@since     10/02/2021
/*/
class PLSBCIOBSSvc

method new() constructor
method grava()

data oRest
endclass

//-------------------------------------------------------------------
/*/{Protheus.doc} new

@author    Lucas Nonato
@version   V12
@since     23/02/2021
/*/
method new(oRest) class PLSBCIOBSSvc
::oRest := oRest
return self

//-------------------------------------------------------------------
/*/{Protheus.doc} grava

@author    Lucas Nonato
@version   V12
@since     23/02/2021
/*/
method grava(cObs) class PLSBCIOBSSvc

BCI->( RecLock( "BCI", .f. ) )
BCI->BCI_OBSERV := cObs
BCI->( MsUnlock() )

return