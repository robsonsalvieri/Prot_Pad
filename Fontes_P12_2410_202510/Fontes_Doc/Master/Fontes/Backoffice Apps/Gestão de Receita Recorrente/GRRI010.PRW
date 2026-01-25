#include "protheus.ch"
#include "GRRI010.ch"

// tipos de documento
#DEFINE CGC         1   
#DEFINE CNPJ        2   

//-------------------------- GRRI010 ------------------------------
// Funções de sincronismo da Organization ( Filiais ) com a plataforma GRR
//-------------------------------------------------------------------

//-------------------------------------------------------------------------------------
/*/{Protheus.doc} GRRI010
Função que prepara as informações necessárias para a sincronização das empresas\filiais
do Protheus com a plataforma GRR.

@param oStatus, object, Painel onde serão mostrados as etapas de gravação.
@param aBranches, array, vetor com as informações das filiais selecionadas.
@param aPrvBranches, array, filiais configuradas em execuções anteriores

@return caracter, resultado das ações de sincronismo.
@author  Marcia Junko
@since   24/03/2022
/*/
//-------------------------------------------------------------------------------------
Function GRRI010( oStatus, aBranches, aPrvBranches )
    Local aSvAlias := GetArea()
    Local aSM0 := {}
    Local aItem := {}
    Local aJsonOrganizations := {}
    Local aHierarchy := {}
    Local aControl := {}
    Local aData := {}
    Local cEndpoint := ''
    Local cPath := '/organizations/many'
    Local cPathUnique := '/organizations'
    Local cMsg := ''
    Local cReference := ''
    Local cName := ''
    Local cCGC := ''
    Local cResult := ''
    Local nX := 0
    Local nY := 0
    Local nCompany := 0
    Local lUpdate := .F.
    Local jOrganization := NIL

    cEndPoint := GRRURL()
    aSM0 := FWLoadSM0()    

    For nX := 1 to len( aBranches )
        aHierarchy := {}
        lUpdate := .F.
        aItem := StrTokArr( aBranches[ nX ], '-' )

        If ( nCompany := Ascan( aSM0, { |x| Alltrim( x [ SM0_GRPEMP ] ) == Alltrim( aItem[ 1 ] ) .And. ;
                Alltrim( x [ SM0_CODFIL ] ) == Alltrim( aItem[ 2 ] ) } ) ) > 0

            aData := aSM0[ nCompany ]
            cReference := aData[ SM0_GRPEMP ] + '|' + aData[ SM0_CODFIL ]
            cName := Alltrim( aData[ SM0_NOME ] ) + ' - ' + Alltrim( aData[ SM0_NOMRED ] )
            cCGC := aData[ SM0_CGC ]

            jOrganization := SetJson( cReference, cName, cCGC )

            //--------------------------------------------------------------
            // Cria a hierarquia das filiais selecionadas
            //--------------------------------------------------------------
            aHierarchy := SetTreeJson( aData, aControl )

            If !Empty( aPrvBranches )
                lUpdate := ( Ascan( aPrvBranches, {|x| alltrim( aItem[ 1 ] ) + ' - ' + alltrim( aItem[ 2 ] ) $ x[1] } ) > 0 )
                If lUpdate
                    jOrganization[ "isActive" ] := "true" 
                EndIf
            EndIf
            
            cMsg := I18N( STR0001, { alltrim( jOrganization[ "reference" ] ) } )    //"Dados da organization #1 enviados com sucesso para a plataforma."
            
            //--------------------------------------------------------------
            // Alimenta o vetor de uso em lote
            //--------------------------------------------------------------
            AAdd( aJsonOrganizations, jOrganization )

            //--------------------------------------------------------
            // Sincroniza a hierarquia
            //--------------------------------------------------------
            For nY := 1 to len( aHierarchy )
                aAdd( aControl, aHierarchy[ nY ][ 1 ] )
                cMsg := I18N( STR0001, { alltrim( aHierarchy[ nY ][ 1 ] ) } )    //"Dados da organization #1 enviados com sucesso para a plataforma."
                
                //--------------------------------------------------------------
                // Alimenta o vetor de uso em lote
                //--------------------------------------------------------------
                AAdd( aJsonOrganizations, aHierarchy[ nY ][2] )
            Next
        EndIf
    Next

    //--------------------------------------------------------------
    // Chama o sincronismo para cada paginação se estiver rodando em lote
    //--------------------------------------------------------------
    iF !Empty( aJsonOrganizations ) 
        cResult := GRRSyncData( oStatus, aJsonOrganizations, cEndPoint, cPath )
    EndIf

    // TODO - Pensar numa forma para não ter que duplicar o bloco todo.

    //------------------------------------------------------------------------
    // Desabilita os registros que não estão sendo mais usados na plataforma.
    //------------------------------------------------------------------------
    For nX := 1 to len( aPrvBranches )
        If Ascan( aBranches, {|x| aPrvBranches[ nX ][1] $ x } ) == 0
            aItem := StrTokArr( aPrvBranches[ nX ][1], '-' )

            If ( nCompany := Ascan( aSM0, { |x| Alltrim( x [ SM0_GRPEMP ] ) == Alltrim( aItem[ 1 ] ) .And. ;
                    Alltrim( x [ SM0_CODFIL ] ) == Alltrim( aItem[ 2 ] ) } ) ) > 0
                
                aData := aSM0[ nCompany ]
                cReference := aData[ SM0_GRPEMP ] + '|' + aData[ SM0_CODFIL ]
                cName := Alltrim( aData[ SM0_NOME ] ) + ' - ' + Alltrim( aData[ SM0_NOMRED ] )
                cCGC := aData[ SM0_CGC ]

                jOrganization := SetJson( cReference, cName, cCGC )                 
            
                jOrganization[ "isActive" ] := "false" 
                
                cMsg := I18N( STR0002, { alltrim( jOrganization[ "reference" ] ) } )    //"Organization #1 desabilitada com sucesso na plataforma."
                
                cResult := GRRSyncData( @oStatus, jOrganization, cEndPoint, cPathUnique, 2, NIL, cMsg )
            EndIf
        EndIf
    Next
    
    RestArea( aSvAlias )

    FWFreeArray( aSvAlias )
    FWFreeArray( aSM0 )
    FWFreeArray( aJsonOrganizations )
    FWFreeArray( aItem )
    FWFreeArray( aData )
    FWFreeArray( aHierarchy )
    FWFreeArray( aControl )
    FreeObj( jOrganization )
Return cResult

//-------------------------------------------------------------------------------------
/*/{Protheus.doc} SetJson
Função que prepara as informações necessárias para a sincronização das empresas\filiais
do Protheus com a plataforma.

@param cReference, caracter, Identificação da empresa\filial.
@param cName, caracter, Descrição da empresa\filial.
@param cCGC, caracter, CPF\CNPJ

@return json, componente com as propriedades no formato JSON para envio à plataforma.
@author  Marcia Junko
@since   24/03/2022
/*/
//-------------------------------------------------------------------------------------
Static Function SetJson( cReference, cName, cCGC )
    Local jData := NIL
    
    jData := JsonObject():New()

    jData[ "reference" ]      := cReference
    jData[ "name" ]           := EncodeUTF8( cName )
    jData[ "typeDocument" ]   := Iif( Len( cCGC ) == 14, CNPJ, CGC )  // 1 = CGC; 2=CNPJ
    jData[ "documentNumber" ] := cCGC
    jData[ "integrationId" ]  := cReference
Return jData

//-------------------------------------------------------------------------------------
/*/{Protheus.doc} SetTreeJson
Função que prepara as informações necessárias para a sincronização da hierarquia das 
filiais selecionadas no Protheus com a plataforma.

@param aData, array, vetor com informações da filial para sincronizar.
@param @aControl, array, vetor de controle com os objetos que já foram sincronizados

@return array, vetor com os objetos a sincronizar
@author  Marcia Junko
@since   24/03/2022
/*/
//-------------------------------------------------------------------------------------
Static Function SetTreeJson( aData, aControl )
    Local jData := NIL
    Local aHierarchy := {}
    Local nSize := FWSizeFilial()
    Local cOrganizationCode := ""
    Local cName := ""
    
    //------------------------------------------------------
    // Avalia a criação da estrutura do grupo de empresas
    //------------------------------------------------------
    If Ascan( aControl, {|x| x == aData[ SM0_GRPEMP ] } ) == 0
        cOrganizationCode := aData[ SM0_GRPEMP ] + '|' + Space( nSize )
        cName := Alltrim( aData[ SM0_DESCGRP ] )
  
        jData := SetJson( cOrganizationCode, cName, aData[ SM0_CGC ] )

        Aadd( aHierarchy, { aData[ SM0_GRPEMP ], jData } )
    EndIf

    //------------------------------------------------------
    // Avalia a criação da estrutura da empresa
    //------------------------------------------------------
    If !Empty( aData[ SM0_EMPRESA ] )
        If Ascan( aControl, {|x| x == aData[ SM0_GRPEMP ] + '|' + aData[ SM0_EMPRESA ] } ) == 0
            cOrganizationCode := aData[ SM0_GRPEMP ] + '|' + Padr( aData[ SM0_EMPRESA ], nSize )
            cName := Alltrim( aData[ SM0_DESCEMP ] )

            jData := SetJson( cOrganizationCode, cName, aData[ SM0_CGC ] )

            Aadd( aHierarchy, { aData[ SM0_GRPEMP ] + '|' + aData[ SM0_EMPRESA ], jData } )
        EndIf

        //------------------------------------------------------
        // Avalia a criação da estrutura da unidade de negócio
        //------------------------------------------------------
        If !Empty( aData[ SM0_UNIDNEG ] )
            If Ascan( aControl, {|x| x == aData[ SM0_GRPEMP ] + '|' + aData[ SM0_EMPRESA ] + aData[ SM0_UNIDNEG ] } ) == 0
                cOrganizationCode := aData[ SM0_GRPEMP ] + '|' + Padr( aData[ SM0_EMPRESA ] + aData[ SM0_UNIDNEG ], nSize )
                cName := Alltrim( aData[ SM0_DESCEMP ] ) + ' - ' + Alltrim( aData[ SM0_DESCUN ] )

                jData := SetJson( cOrganizationCode, cName, aData[ SM0_CGC ] )

                Aadd( aHierarchy, { aData[ SM0_GRPEMP ] + '|' + aData[ SM0_EMPRESA ] + aData[ SM0_UNIDNEG ], jData } )
            EndIf
        EndIf
    EndIf

    FreeObj( jData )
Return aHierarchy
