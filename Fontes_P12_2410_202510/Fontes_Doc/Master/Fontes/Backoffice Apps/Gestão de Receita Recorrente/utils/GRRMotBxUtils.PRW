#include "protheus.ch"
#include "GRRXDefs.ch"

//-------------------------- GRRMotBxUtils --------------------------
// Biblioteca de funções relacionadas ao cadastro de motivos de baixa
//-------------------------------------------------------------------

//-------------------------------------------------------------------------------------
/*/{Protheus.doc} GRRNewMotBx
Inclui um motivo de baixa.

@param cCode, caracter, nome do motivo de baixa
@param Desc, caracter, descrição do motivo de baixa
@param aOptions, array, vetor com as configurações do motivo de baixa. Onde:
    [1] = Nome da configuração
    [2] = conteúdo a ser gravado

@return Logico, Verdadeiro se for incluído.
@author  Marcia Junko
@since   08/08/2022
/*/
//-------------------------------------------------------------------------------------
Function GRRNewMotBx( cCode, cDesc, aOptions )
    Local aSvAlias := GetArea()
    Local aFields := {}
    Local aContent := {}
    Local lRet  := .T.
    Local cFile	:= "SIGAADV.MOT"
    Local cField := ""
    Local cAlias := ''
    Local nI := 0
    Local nPos := 0
    Local oTmpTable := NIL

    If !Empty( cCode )
        // Executa a função de leitura das baixas para forçar a criação do arquivo, caso não exista.
        aContent := ReadMotBx()

        aFields := MotBxStruct()

        oTmpTable := FWTemporaryTable():New( "cArqTmp" )  
        oTmpTable:SetFields( aFields ) 	
        oTmpTable:Create()	

        cAlias := "cArqTmp"
        dbSelectArea( cAlias )

        APPEND FROM &cFile SDF
        dbGoTop()

        while ( cAlias )->( !Eof() )
            if ( cAlias )->SIGLA == cCode 
                lRet := .F.
                exit
            ENDIF

            ( cAlias )->( dbSkip() )
        END

        IF ( lRet )
            lRet := .F.

            BEGIN TRANSACTION
                RecLock( cAlias , .T. )
                    ( cAlias )->Sigla := cCode
                    ( cAlias )->Descr := cDesc
                    For nI := 1 to len( aFields )
                        cField := aFields[ nI ][1]
                        If !( Upper( alltrim( cField ) ) $ 'SIGLA|DESCR' )
                            If ( nPos := Ascan( aOptions, {|x| upper( alltrim( x[1] ) ) == upper( alltrim( cField ) ) } ) ) > 0
                                ( cAlias )->&( cField ) := aOptions[ nPos ][2]
                            Else
                                ( cAlias )->&( cField ) := "N"
                            EndIf
                        EndIf
                    Next
                MsUnLock()

                dbSelectArea( cAlias )
                FERASE( cFile )
                Copy to &cFile SDF

                lRet := .T.
            END TRANSACTION
        Endif
        
        ( cAlias )->( DbCloseArea() )
    EndIf

    RestArea( aSvAlias )

    FWFreeArray( aFields )
    FWFreeArray( aSvAlias )
    FWFreeArray( aContent )
    FreeObj( oTmpTable )
RETURN lRet

//-------------------------------------------------------------------------------------
/*/{Protheus.doc} MotBxStruct
Indica a estrutura do arquivo SIGAADV.MOT

@return array, Estrutura do arquivo de motivos de baixa
@author  Marcia Junko
@since   08/08/2022
/*/
//-------------------------------------------------------------------------------------
Static Function MotBxStruct( )
    Local aFields := {}

    aFields := { {"SIGLA"	, "C", 03, 0 },;
                {"DESCR"	, "C", 10, 0 },;
                {"CARTEIRA"	, "C", 01, 0 },;
                {"MOVBANC"	, "C", 01, 0 },;
                {"COMIS"	, "C", 01, 0 },;
                {"CHEQUE"	, "C", 01, 0 },;
                {"ESPECIE"	, "C", 01, 0 }	}

RETURN aFields


//-------------------------------------------------------------------------------------
/*/{Protheus.doc} GRRSetMotBx
Adiciona ao array de controle aContent um valor específico para o campo do arquivo SIGAADV.MOT

@param @aContent, array, Vetor com as configurações que serão salvas
@param cName, caracter, nome da configuração
@param cValue, caracter, conteúdo da configuração

@author  Marcia Junko
@since   08/08/2022
/*/
//-------------------------------------------------------------------------------------
Function GRRSetMotBx( aContent, cName, cValue )
    Local aFields := MotBxStruct( )
    Local nPos := 0 

    If ( nPos := Ascan( aFields, {|x| x[1] == cName } ) ) > 0
        aAdd( aContent, { cName, cValue } )
    EndIf
RETURN 
