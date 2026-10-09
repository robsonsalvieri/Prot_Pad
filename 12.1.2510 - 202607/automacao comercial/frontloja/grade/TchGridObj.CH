// ######################################################################################
// Projeto: Touch Screen Library
// Modulo : Include
// Fonte  : Grade.ch
// -----------+-------------------+------------------------------------------------------
// Data       | Autor             | Descricao
// -----------+-------------------+------------------------------------------------------
// 18.10.2006   Marcelo Dolis
// --------------------------------------------------------------------------------------

#include "fileio.ch"
#include "msobject.ch"
#include "xmlxfun.ch"
#include "topconn.ch"

/*----------------------------------------------------------------------------------------
Definição as constantes do teclado
-----------------------------------------------------------------------------------------*/

/*----------------------------------------------------------------------------------------
                            
#xcommand property <propname> := <value>;
	=> <propname> := iif(valType(<value>)=="U", <propname>, <value>)

#xcommand abstract;
	=> ExUserException("Abstract method in " + ::ClassName())

#define CRLF chr(13)+chr(10)

*/

#ifdef SPANISH
	#define STR2001 "Erro no tipo do parâmetro da grade. Entre em contato com o Administrador do Sistema."
	#define STR2002 "Erro na estrutura do parâmetro da grade. Entre em contato com o Administrador do Sistema."
#else
	#ifdef ENGLISH
		#define STR2001 "Erro no tipo do parâmetro da grade. Entre em contato com o Administrador do Sistema."
		#define STR2002 "Erro na estrutura do parâmetro da grade. Entre em contato com o Administrador do Sistema."
	#else
		#define STR2001 "Erro no tipo do parâmetro da grade. Entre em contato com o Administrador do Sistema."
		#define STR2002 "Erro na estrutura do parâmetro da grade. Entre em contato com o Administrador do Sistema."
	#endif
#endif
