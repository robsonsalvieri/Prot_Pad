#INCLUDE "PROTHEUS.CH"
#INCLUDE "TAFAADM.CH"
//-------------------------------------------------------------------
/*/{Protheus.doc} TAFAADM
Programa que garante o acesso dos cadastros de empresa/usuário somente para membros do Grupo Administrador

@author Gustavo G. Rueda
@since 29/08/2016
@version 1.0 

@aParam Nil	

@return lRet - (.T.) Ok ou (.F.) NOK 
/*/
//-------------------------------------------------------------------
Function TAFAADM()
Return

Function TAFCFGA510()
TAFVldAccess( 'CFGA510' )
Return

Function TAFCFGA520()
TAFVldAccess( 'CFGA520' )
Return

Function TAFCFGA530()
TAFVldAccess( 'CFGA530' )
Return

Function TAFCFGA540()
TAFVldAccess( 'CFGA540' )
Return

Function TAFCFGA550()
TAFVldAccess( 'CFGA550' )
Return

Function TAFCFGA560()
TAFVldAccess( 'CFGA560' )
Return
//-------------------------------------------------------------------
/*/{Protheus.doc} TAFADMGRP
Funcao utilizada para chamar algumas rotinas do CFG e de outros módulos num formato padrão validando se o usuario logado eh admin

@author Gustavo G. Rueda
@since 29/08/2016
@version 1.0 

@aParam Nil	

@return Nil 
/*/
//-------------------------------------------------------------------
Function TAFADMGRP()
TAFVldAccess( 'FWCADGRPCO' )
Return
//-------------------------------------------------------------------
/*/{Protheus.doc} TAFADMEMP
Funcao utilizada para chamar algumas rotinas do CFG e de outros módulos num formato padrão validando se o usuario logado eh admin

@author Gustavo G. Rueda
@since 29/08/2016
@version 1.0 

@aParam Nil	

@return Nil 
/*/
//-------------------------------------------------------------------
Function TAFADMEMP()
TAFVldAccess( 'FWCADCOMPA' )
Return
//-------------------------------------------------------------------
/*/{Protheus.doc} TAFADMUNN
Funcao utilizada para chamar algumas rotinas do CFG e de outros módulos num formato padrão validando se o usuario logado eh admin

@author Gustavo G. Rueda
@since 29/08/2016
@version 1.0 

@aParam Nil	

@return Nil 
/*/
//-------------------------------------------------------------------
Function TAFADMUNN()
TAFVldAccess( 'FWCADUNIDN' )
Return
//-------------------------------------------------------------------
/*/{Protheus.doc} TAFADMFIL
Funcao utilizada para chamar algumas rotinas do CFG e de outros módulos num formato padrão validando se o usuario logado eh admin

@author Gustavo G. Rueda
@since 29/08/2016
@version 1.0 

@aParam Nil	

@return Nil 
/*/
//-------------------------------------------------------------------
Function TAFADMFIL()
TAFVldAccess( 'FWCADFILIA' )
Return
//-------------------------------------------------------------------
/*/{Protheus.doc} TAFADMSCH
Funcao utilizada para chamar algumas rotinas do CFG e de outros módulos num formato padrão validando se o usuario logado eh admin

@author Gustavo G. Rueda
@since 29/08/2016
@version 1.0 

@aParam Nil	

@return Nil 
/*/
//-------------------------------------------------------------------
Function TAFADMSCH()
TAFVldAccess( 'CFGA010' )
Return
//-------------------------------------------------------------------
/*/{Protheus.doc} TAFMSGPAD
Funcao utilizada para mostrar mensagem padrao de acesso restrito ao administrador

@author Gustavo G. Rueda
@since 29/08/2016
@version 1.0 

@aParam Nil	

@return Nil 
/*/
//-------------------------------------------------------------------
Static Function TAFVldAccess( cOpcMenu as character )
If FWIsAdmin( __cUserID )
	&cOpcMenu.()
Else
	MsgInfo( STR0001 + FWSFUser( __cUserId, "DATAUSER", "USR_CODIGO" ) + STR0002, STR0003 )	//'Somente usuários com perfil de Administradores possuem acesso a esta funcionalidade; este( '###' ) em questão não tem este perfil, entre em contato com o administrador do sistema para que libere o acesso se necessário.'###'Somente usuários Administradores...'
EndIf
Return
