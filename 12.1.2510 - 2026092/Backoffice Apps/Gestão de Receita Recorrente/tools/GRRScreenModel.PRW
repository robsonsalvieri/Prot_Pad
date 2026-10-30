#include "totvs.ch"
#include "GRRXDefs.ch"
#include "GRRScreenModel.ch"

//-------------------------- GRRScreeenModel -----------------------------------
// Biblioteca de funções de componentes visuais genéricas
//---------------------------------------------------------------------------

//-------------------------------------------------------------------------------------
/*/{Protheus.doc} GRRScrPlatform
Função que monta a tela de dados de conexão com a plataforma.

@param oPanel, object, Painel onde os componentes serão criados
@param cRegistry, caracter, Identificador do serviço
@param cPlatURL, caracter, Path da plataforma para validar os dados de conexão.
@param cPlatPath, caracter, Path da plataforma para validar os dados de conexão.
@param cGroupText, caracter, Texto apresentado no objeto GROUP

@author  Marcia Junko
@since   31/03/2022
/*/
//-------------------------------------------------------------------------------------
Function GRRScrPlatform( oPanel, cRegistry, cPlatURL, cPlatPath, cGroupText )
    Local aPlatInfo := Array( SIZE_PLATFORM )
    Local oConfig := GRRTFCfg()

    Default cGroupText := STR0001   //'Acesso a plataforma'
    Default oPanel := NIL

    IF !Empty( oConfig[ "platform-clientId" ] )
        aPlatInfo[ CLIENT_ID ] := oConfig[ "platform-clientId" ]
        aPlatInfo[ CLIENT_SECRET ] := oConfig[ "platform-secret" ]
    Else
        aPlatInfo[ CLIENT_ID ] := Space( 32 )
        aPlatInfo[ CLIENT_SECRET ] := Space( 32 )
    EndIf

    aPlatInfo[ REGISTRY ] := AllTrim( cRegistry )
    aPlatInfo[ PLATFORM_URL ] := AllTrim( cPlatURL )
    aPlatInfo[ PLATFORM_PATH ] := AllTrim( cPlatPath )

    If oPanel <> NIL
        @ 10, 60 GROUP TO 50, 290 PROMPT cGroupText OF oPanel PIXEL   

            @ 020, 065 SAY "Client ID" SIZE 200,20 OF oPanel PIXEL 
            @ 030, 065 MSGET aPlatInfo[ 1 ] SIZE 105,09 OF oPanel PIXEL

            @ 020, 180 SAY "Client Secret" SIZE 200,20 OF oPanel PIXEL 
            @ 030, 180 MSGET aPlatInfo[ 2 ] SIZE 105,09  OF oPanel PIXEL
    EndIf
Return aPlatInfo


//----------------------------------------------------------------------------------
/*/{Protheus.doc} GRRListScreen
Cria uma tela com controle de item a selecionar por lista.

@param oPanel, object, Painel onde os componentes serão criados
@param @aListLeft, array, Lista de itens disponíveis
@param @aListRight, array, Lista de itens selecionados

@return array, lista de itens selecionados
@author Marcia Junko
@since 24/03/2022
/*/
//----------------------------------------------------------------------------------
Function GRRListScreen( oPanel, aListLeft, aListRight )
    Local oListLeft
    Local oListRight
    Local oGetLeft
    Local oGetRight
    Local cGetLeft := space( 25 )
    Local cGeRight := space( 25 )
	Local nLeft	:= 1
	Local nRight := 1

    Default aListRight := {}

	@ 010, 015 SAY STR0002 OF oPanel SIZE 100, 10 PIXEL //"Itens disponíveis: "
	@ 010, 195 SAY STR0003 OF oPanel SIZE 100, 10 PIXEL //"Itens selecionados:"

	@ 020, 015 GET oGetLeft VAR cGetLeft PICTURE "@!" OF oPanel SIZE 130,009 PIXEL
	oGetLeft:bLostFocus := {|| FindInList( oListLeft:aItems, @cGetLeft, @oListLeft, @oGetLeft )}

	@ 035, 015 LISTBOX oListLeft VAR nLeft ITEMS aListLeft SIZE 130, 123  OF oPanel PIXEL

	@ 020, 195 GET oGetRight VAR cGeRight PICTURE "@!" OF oPanel SIZE 130,009 PIXEL
	oGetRight:bLostFocus := {|| FindInList( oListRight:aItems, @cGeRight, @oListRight, @oGetRight )}

	@ 035, 195 LISTBOX oListRight VAR nRight ITEMS aListRight SIZE 130, 123  OF oPanel PIXEL

    @ 035, 150 BUTTON ">" SIZE 40, 10 PIXEL OF oPanel ACTION ( Move2Lists( '+', @oListLeft , @oListRight ) )
    @ 045, 150 BUTTON ">>" SIZE 40, 10 PIXEL OF oPanel ACTION ( Move2Lists( '+', @oListLeft , @oListRight, .T. ) )
    @ 055, 150 BUTTON "<" SIZE 40, 10 PIXEL OF oPanel ACTION ( Move2Lists( '-', @oListLeft , @oListRight ) )
    @ 065, 150 BUTTON "<<" SIZE 40, 10 PIXEL OF oPanel ACTION ( Move2Lists( '-', @oListLeft , @oListRight, .T. ) )
Return aListRight


//-------------------------------------------------------------------
/*/{Protheus.doc} Move2Lists
Função para movimentação de um item de um listbox para o outro.

@param cType, caracter,	Tipo de movimentação a ser feita
@param oListLeft, object, Listbox com os itens disponíveis
@param oListRight, object, Listbox com os itens selecionados
@param lAll, boolean, Indica se a ação afetará todos os registros ou 
    somente o registro posicionado

@author Marcia Junko
@since 24/03/2022
/*/
//-------------------------------------------------------------------
Static Function Move2Lists( cType, oListLeft, oListRight, lAll )
	Local nPos  := 0
	Local nCont := 0
    Local lAdd := Iif( cType == '+', .T., .F. )
    Local aRight := {}
    Local aLeft := {}

    Default lAll := .F.

    aRight := oListRight:aItems
    aLeft := oListLeft:aItems
    If lAll
        If lAdd
            For nCont := 1 To Len( aLeft )
                aAdd( aRight , aLeft[ nCont ] )
            Next nCont
            aLeft := {}
            aSize( aLeft , 0 )
        else
            //----------------------------------------------------------------------------------
            // TODO - Está em modo recursivo, pois não está validando corretamente se existe 
            // algum item selecionado.
            // O cenário é reproduzido ao utilizar a tela de seleção dentro de um Wizard, prosseguir
            // para a próxima etapa do Wizard e retornar na tela de seleção, removendo todos os itens
            // selecionados de uma única vez, aparentemente a função de validação não recebe o 
            // array com os elementos atualizados, por isso a validação falha.
            //----------------------------------------------------------------------------------
            For nCont := 1 To Len( aRight )
                oListRight:nAt := 1
                Move2Lists( '-', @oListLeft, @oListRight )
            Next nCont
        EndIf
    Else
        If lAdd
            nPos := oListLeft:GetPos()
        else
            nPos := oListRight:GetPos()
        EndIf
        If nPos <> 0
            If lAdd 
                aAdd( aRight , oListLeft:GetSelText() )
        
                aDel( aLeft , nPos )
                aSize( aLeft , Len( aLeft ) - 1 )
            else
                aAdd( aLeft , oListRight:GetSelText() )
        
                aDel( aRight , nPos )
                aSize( aRight , Len( aRight ) - 1 )    
            EndIf
        Else
            ApMsgAlert( STR0004 ) //"Selecione um item para mover!"
        EndIf
    EndIf

    aSort( aRight, , , {|x, y| AllTrim( Upper( x ) ) < AllTrim( Upper( y ) ) } )
    aSort( aLeft, , , {|x, y| AllTrim( Upper( x ) ) < AllTrim( Upper( y ) ) } )

    oListRight:SetArray( aRight )
    oListRight:Refresh()

    oListLeft:SetArray( aLeft )
    oListLeft:Refresh()
Return

//-------------------------------------------------------------------
/*/{Protheus.doc} FindInList
Função para pesquisar um conteúdo dentro de uma listbox.
@param aInfo	Vetor contendo as informações.
@param cItem	Valor a ser pesquisado.
@param oList	Objeto da Listbox.
@param oGet		Objeto do campo de pesquisa.

@author  Marcia Junko
@since   24/03/2022
/*/
//-------------------------------------------------------------------
Static Function FindInList( aInfo, cItem, oList, oGet )
	Local nPos := 0

	nPos := Ascan( aInfo, {|x| Alltrim( cItem ) $ x } )

	If nPos > 0
		oList:nAt := nPos
		oList:Refresh()

		cItem := Space( 25 )
		oGet:Refresh()
	Endif
Return


//-------------------------------------------------------------------
/*/{Protheus.doc} GRRGrpLInArray
Função que trata e agrupa os dados de uma lista.

Por exemplo, se o array tiver os seguintes dados:
    T1 - D MG 01 - Filial 01 
    T1 - D SP 02 - Filial 02 
    T1 - M SP 01 - Filial 01 
    T2 - D RJ 01 - Filial 01
    T2 - D SC 01 - Filial 01

O resultado seria:
    TI
        D MG 01
        D SP 02
        M SP 01
    T2
        D RJ 01
        D SC 01

@param aData, array, Vetor com os dados que serão tratados
@param cSeparator, caracter, Caracter separador

@return array, Vetor agrupado
@author  Marcia Junko
@since   01/04/2022
/*/
//-------------------------------------------------------------------
Function GRRGrpLInArray( aData, cSeparator )
	Local aResult := {}
    Local aDataAux := {}
    Local nPos := 0
    Local nI := 0

    Default cSeparator := '-'

    For nI := 1 to len( aData )
        aDataAux := StrtokArr( aData[ nI ], cSeparator )

        If ( nPos := Ascan( aResult, {|x| x[ 1 ] == alltrim( aDataAux[ 1 ] ) } ) ) > 0 
            aAdd( aResult[ nPos ][ 2 ], alltrim( aDataAux[ 2 ] ) )
        else
            aAdd( aResult, { alltrim( aDataAux[ 1 ] ), { alltrim( aDataAux[ 2 ] ) } } )
        EndIf
    Next

    FWFreeArray( aDataAux )    
Return aResult
