#include "protheus.ch"
#Include 'FWMVCDef.ch'

//-------------------------- GRRI040 ------------------------------------------------
// Funções de sincronização dos clientes Protheus com a plataforma GRR ( customers ).
//-----------------------------------------------------------------------------------

//-------------------------------------------------------------------------------------
/*/{Protheus.doc} GRRI040
Função que prepara as informações necessárias para a sincronização pontual dos clientes
Protheus com a plataforma GRR.

@param aInfo, array, Vetor com as informações do cliente a sincronizar, sendo:
    [1] = filial
    [2] = codigo do cliente
    [3] = loja do cliente

@author  Marcia Junko
@since   05/05/2022
/*/
//-------------------------------------------------------------------------------------
Function GRRI040( aInfo )
    Local aSvAlias := GetArea()
    Local cEndpoint := ''
    Local cPath := '/customers'
    Local cResult := ''     
    Local jCustomer

    Default aInfo := {}

    If !Empty( aInfo )
        SA1->( DbSetOrder( 1 ) )    // A1_FILIAL+A1_COD+A1_LOJA
        If SA1->( DBSeek( xFilial("SA1", aInfo[1] ) + aInfo[2] + aInfo[3]) )
            cEndPoint := GRRURL()
            jCustomer := SetJson(  )
            
            // Só chama o sincronismo se não for chamado da subscrição
            If !( "GRRI050" $ ProcSource(1) )
                cResult := GRRSyncData( NIL, jCustomer, cEndPoint, cPath )
                If !Empty( cResult )
                    jCustomer := JSONObject():New() 
                    jCustomer:FromJSON( cResult )
                Else
                    FreeObj( jCustomer )
                EndIf
            EndIf
        EndIf
    EndIf

    If !Empty( aSvAlias )
        RestArea( aSvAlias )
    EndIf

    FWFreeArray( aSvAlias )
Return jCustomer

//-------------------------------------------------------------------------------------
/*/{Protheus.doc} SetJson
Função que prepara as informações necessárias para a sincronização das empresas\filiais
do Protheus com a plataforma.

@param aData, array, vetor com informações da filial para sincronizar.

@return json, componente com as propriedades no formato JSON para envio à plataforma.
@author  Marcia Junko
@since   05/05/2022
/*/
//-------------------------------------------------------------------------------------
Static Function SetJson( cTmpAlias, lValidate )
    Local jData := NIL
    Local cDate := ''

    Default cTmpAlias := "SA1"
    Default lValidate := .T.

    If !lValidate .or. ( !Empty( ( cTmpAlias )->A1_CGC ) .And. !Empty( ( cTmpAlias )->A1_EMAIL ) )
        jData := JsonObject():New()

        cDate := Dtos( ( cTmpAlias )->A1_DTNASC )
        
        jData[ "organizationIntegrationId" ] :=  cEmpAnt + '|' + ( cTmpAlias )->A1_FILIAL   
        jData[ "code" ] := ( cTmpAlias )->A1_COD + ( cTmpAlias )->A1_LOJA     
        jData[ "reference" ] := ( cTmpAlias )->A1_COD + ( cTmpAlias )->A1_LOJA
        jData[ "name" ] := EncodeUTF8( Alltrim( ( cTmpAlias )->A1_NOME ) )
        jData[ "documentNumber" ] := Alltrim( ( cTmpAlias )->A1_CGC )
        jData[ "typeDocument" ] := Iif( Len( Alltrim( ( cTmpAlias )->A1_CGC ) ) == 11, '1', '2' )        
        jData[ "stateRegistration" ] := Alltrim( ( cTmpAlias )->A1_INSCR )                              
        jData[ "cityRegistration" ] := Alltrim( ( cTmpAlias )->A1_INSCRM )
        jData[ "integrationId" ] := cEmpAnt + '|'+ ( cTmpAlias )->A1_FILIAL + '|' + Alltrim( ( cTmpAlias )->A1_COD )+ '|' + Alltrim( ( cTmpAlias )->A1_LOJA )
        jData[ "status" ] := 1
        If !Empty( cDate )
            jData[ "birthDate" ] :=  Subs( cDate, 1, 4 ) + '-' + Subs( cDate, 5, 2 ) + '-' + Subs( cDate, 7 ) 
        EndIf
        jData[ "addresses" ] := MakeAddress( cTmpAlias )
        jData[ "emails" ] := MakeEmail( cTmpAlias )
        jData[ "phones" ] := MakePhones( cTmpAlias )
    EndIf
Return jData

//-------------------------------------------------------------------------------------
/*/{Protheus.doc} MakeAddress
Função que prepara as informações necessárias para a montagem do endereço do cliente.

@param cTmpAlias, caracter, alias de cliente que está sendo verificado.

@return array, vetor com os endereços do cliente
@author  Marcia Junko
@since   05/05/2022
/*/
//-------------------------------------------------------------------------------------
Static Function MakeAddress( cTmpAlias )
    Local aAddress := {}
    Local jAddress 

    If !Empty( ( cTmpAlias )->A1_END ) .and. !Empty( ( cTmpAlias )->A1_BAIRRO ) .And. !Empty( ( cTmpAlias )->A1_CEP ) .And. ;
        !Empty( ( cTmpAlias )->A1_MUN ) .And. !Empty( ( cTmpAlias )->A1_EST )
            jAddress := JsonObject():New()
            jAddress[ "type" ] := Iif( Len( Alltrim( ( cTmpAlias )->A1_CGC ) ) == 11, 1, 2 )                     // 1=Home;2=Business;3=Billing 
            jAddress[ "street" ] := EncodeUTF8( Alltrim( ( cTmpAlias )->A1_END ) )
            jAddress[ "number" ] := GrrNumAddress( Alltrim( ( cTmpAlias )->A1_END ) )               
            jAddress[ "complement" ] := EncodeUTF8( Alltrim( ( cTmpAlias )->A1_COMPLEM ) )
            jAddress[ "district" ] := EncodeUTF8( Alltrim( ( cTmpAlias )->A1_BAIRRO ) )
            jAddress[ "zipCode" ] := Alltrim( ( cTmpAlias )->A1_CEP )
            jAddress[ "cityName" ] := EncodeUTF8( Alltrim( ( cTmpAlias )->A1_MUN ) )
            jAddress[ "stateInitials" ] := EncodeUTF8( Alltrim( ( cTmpAlias )->A1_EST ) )
            jAddress[ "stateName" ] := EncodeUTF8( GRRX5Content( '12', Alltrim( ( cTmpAlias )->A1_EST ) ) )
            // TODO - Como pegar a descrição do país - por enquanto não vou mandar
            // Para isso, teria que ter uma entidade país ou localização mapeada, o que hoje ainda não foi estruturada
            jAddress[ "countryName" ] := "BR"            

            aAdd( aAddress, jAddress )
    EndIf
    
    // Inclui o endereço de Billing                
    If !Empty( ( cTmpAlias )->A1_ENDCOB ) .and. !Empty( ( cTmpAlias )->A1_BAIRROC ) .And. !Empty( ( cTmpAlias )->A1_CEPC ) .And. ;
        !Empty( ( cTmpAlias )->A1_MUNC ) .And. !Empty( ( cTmpAlias )->A1_ESTC )
        jAddress := JsonObject():New()
        jAddress[ "type" ] := 3                     // 1=Home;2=Business;3=Billing 
        jAddress[ "street" ] := EncodeUTF8( Alltrim( ( cTmpAlias )->A1_ENDCOB ) )
        jAddress[ "number" ] := GrrNumAddress( Alltrim( ( cTmpAlias )->A1_ENDCOB ) )           
        // TODO - Não tem complemento de cobrança no Protheus?
        // jAddress[ "complement" ] := Alltrim( ( cTmpAlias )->A1_COMPLEM )  
        jAddress[ "complement" ] := ""
        jAddress[ "district" ] := EncodeUTF8( Alltrim( ( cTmpAlias )->A1_BAIRROC ) )
        jAddress[ "zipCode" ] := Alltrim( ( cTmpAlias )->A1_CEPC )
        jAddress[ "cityName" ] := EncodeUTF8( Alltrim( ( cTmpAlias )->A1_MUNC ) )
        jAddress[ "stateInitials" ] := EncodeUTF8( Alltrim( ( cTmpAlias )->A1_ESTC ) )
        jAddress[ "stateName" ] := EncodeUTF8( GRRX5Content( '12', Alltrim( ( cTmpAlias )->A1_ESTC ) ) )
        jAddress[ "countryName" ] := "BR"        

        aAdd( aAddress, jAddress )
    EndIf
Return aAddress

//-------------------------------------------------------------------------------------
/*/{Protheus.doc} MakeEmail
Função que prepara as informações necessárias para a montagem do email do cliente.

@param cTmpAlias, caracter, alias de cliente que está sendo verificado.

@return array, vetor com o email do cliente
@author  Marcia Junko
@since   05/05/2022
/*/
//-------------------------------------------------------------------------------------
Static Function MakeEmail( cTmpAlias )
    Local aEmail := {}
    Local jEmail

    if !empty(allTrim((cTmpAlias)->A1_EMAIL))
        jEmail := JsonObject():New()
        jEmail[ "type" ] := 1                     // 1=Personal;2=Work;3=Home;4=Business;5=Billing 
        jEmail[ "emailAddress" ] := EncodeUTF8( Alltrim( ( cTmpAlias )->A1_EMAIL ) )
        
        aAdd( aEmail, jEmail )
    endIf


Return aEmail

//-------------------------------------------------------------------------------------
/*/{Protheus.doc} MakePhones
Função que prepara as informações necessárias para a montagem do telefone do cliente.

@param cTmpAlias, caracter, alias de cliente que está sendo verificado.

@return array, vetor com o telefone do cliente
@author  Marcia Junko
@since   05/05/2022
/*/
//-------------------------------------------------------------------------------------
Static Function MakePhones( cTmpAlias )
    Local aPhones := {}
    Local jPhones

    If !Empty( ( cTmpAlias )->A1_TEL )
        jPhones := JsonObject():New()
        jPhones[ "type" ] := Iif( Len( Alltrim( ( cTmpAlias )->A1_CGC ) ) == 11, 1, 2 )                     // 1=Home;2=Business;3=CellPhone
        jPhones[ "countryCode" ] := Alltrim( ( cTmpAlias )->A1_DDI )          
        jPhones[ "areaCode" ] :=  Alltrim( ( cTmpAlias )->A1_DDD )
        jPhones[ "number" ] :=  Alltrim( ( cTmpAlias )->A1_TEL )
        jPhones[ "extension" ] :=  ''              

        aAdd( aPhones, jPhones )
    EndIf
Return aPhones

//-------------------------------------------------------------------
/*/{Protheus.doc} GRRI040J
    @description Gera o JSON da entidade Customer independentemente de validações 
    ou de comunicação com o GRR.
	@author guilherme.sordi@totvs.com.br
	@since 28/02/2025
	@type function
	@version 12.1.2410
/*/
//-------------------------------------------------------------------
function GRRI040J() as object
    local jCustomer := setJson("SA1", .F.)
return jCustomer
