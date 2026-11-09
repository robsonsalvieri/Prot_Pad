#include "totvs.ch"

#Define MODULE_PERMISSION "ALL"

//------------------------------------------------------------------------------
/*/{Protheus.doc} ValidPermission
  
  Classe responsável por validar se um tenant tem permissão para acessar o Protheus Insights, 
  validando a existência de um token JWT e sua validade.
  @type class
  @author Danilo Santos
  @since 01/06/2023
  @version P12
/*/
//------------------------------------------------------------------------------
Class ValidPermission from LongNameClass
  Data cJWT

  Method New() Constructor
  Method ReadI14()
  Method VerifyPermissionInsight()
EndClass

//------------------------------------------------------------------------------
/*/{Protheus.doc} New
  
  Constructor Method
  @type method
  @author DANILO SANTOS
  @since 02/07/2023
  @version P12
  @return Self
  /*/
//------------------------------------------------------------------------------
Method New() Class ValidPermission
  ::cJWT := ""
Return Self

//------------------------------------------------------------------------------
/*/{Protheus.doc} ReadI14
  
  Busca o token JWT do tenant na tabela I14 e armazena em ::cJWT.
  
  @type method
  @author DANILO SANTOS
  @since 02/07/2023
  @version P12
  @return cToken, character, Token JWT da permissão do tenant
  /*/
//------------------------------------------------------------------------------
Method ReadI14( ) class ValidPermission
  Local cRAW := ""
 
  cRAW := VldTenantI14( )   
  ::cJWT := cRAW
Return cRAW


//------------------------------------------------------------------------------
/*/{Protheus.doc} VerifyPermissionInsight
  Verifica se o JsonWebToken do tenant é válido, avaliando a data de expiração do token.
  @return lValid, Logical, .T. se o token ainda é válido, .F. caso contrário
  @type method
  @author DANILO SANTOS
  @since 02/07/2023
  @version P12
  /*/
//------------------------------------------------------------------------------
Method VerifyPermissionInsight() class ValidPermission

Local aParts := StrTokArr( ::cJWT, '.')
Local cPayload := ""
Local cSign := ""
Local lTValid := .F.
Local oJsonA

If Len(aParts) >= 2
    cPayload := aParts[2]
    cSign := StrTran(decode64(cPayload), "=", "")
    oJsonA := JsonObject():new()
    oJsonA:fromJson(cSign)

    lTValid := oJsonA['exp'] > Val( FWTimeStamp( 4, DATE(), TIME()) )
    FreeObj( oJsonA )
Endif

Return lTValid

//------------------------------------------------------------------------------
/*/{Protheus.doc} VldTenantI14
Função que avalia a existência da permission para o tenant informado, 
buscando a informação na tabela I14. Caso a permissão exista, o JWT é retornado.

@return cJWTPerm, character, Informação de token JWT da permission.
@type function
@author Marcia Junko
@since  15/03/2025
/*/
//------------------------------------------------------------------------------
Function VldTenantI14( )
  Local aSvArea := GetArea()
  Local aAreaI14 := I14->( GetArea() )
  Local cQuery 		  As Character
  Local cNextAlias 	As Character 
  Local cJWTPerm := ""
  Local nRecI14   As Integer
  Local oQuery    As Object

  cQuery := "SELECT R_E_C_N_O_ ID "
  cQuery += " FROM " + RetSqlName( "I14" ) + " I14 "
  cQuery += " WHERE I14.I14_FILIAL = ? "
  cQuery += " AND I14.I14_MODULO = ? "
  cQuery += " AND I14.D_E_L_E_T_ = ? "

  cQuery := ChangeQuery( cQuery )
  oQuery := FWExecStatement():New( cQuery )
  oQuery:SetString( 1, SPACE( FWSizeFilial() ) )  // filial global (busca em todas as filiais)
  oQuery:SetString( 2, MODULE_PERMISSION )  //"ALL"
  oQuery:SetString( 3, " " )
  cNextAlias := oQuery:OpenAlias()

	If (cNextAlias)->(!Eof())
		nRecI14 := ( cNextAlias )->ID
		DbSelectArea('I14')
		DbSetOrder(1)
		dbgoto(nRecI14)  
		cJWTPerm := I14->I14_MSGRAW
	EndIf
  ( cNextAlias )->( dbCloseArea() )

  RestArea( aAreaI14 )
  RestArea( aSvArea )

  FWFreeArray( aAreaI14 ) 
  FWFreeArray( aSvArea )
  oQuery:Destroy()
Return cJWTPerm