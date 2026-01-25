#include "protheus.ch"
#include "GRRDataUtils.ch"

//-------------------------- GRRDataUtils -----------------------------------
// Biblioteca de funções para tratamento de dados específicos do produto GRR
//---------------------------------------------------------------------------


//------------------------------------------------------------------------------
/*/{Protheus.doc} IsGRRPayment
Função que avalia se a condição de pagamento é do produto GRR

@param  cPayment, caracter, Condição de pagamento

@return logico, Retorna se a condição de pagamento está relacionada ao GRR.
@author Marcia Junko
@since  21/07/2022
/*/
//------------------------------------------------------------------------------
Function IsGRRPayment( cPayment )
    Local aArea         := GetArea()
    Local aAreaSE4      := SE4->( GetArea() )
    Local lGRRPayment   := .F.

    Default cPayment    := ""

    If !Empty( cPayment )
        SE4->( DbSetOrder(1) )  // E4_FILIAL+E4_CODIGO
        If SE4->( MsSeek( xFilial( "SE4" ) + cPayment ) )
            If SE4->( ColumnPos( "E4_PAGGRR" ) ) > 0
                lGRRPayment := SE4->E4_PAGGRR
            EndIf
        EndIf
    EndIf

    RestArea( aAreaSE4 )
    RestArea( aArea )
    
    FWFreeArray( aArea )
    FWFreeArray( aAreaSE4 )
Return lGRRPayment


//------------------------------------------------------------------------------
/*/{Protheus.doc} GRRInvGenerate
Função que indica quando a nota fiscal deve ser gerada de acordo com a condição 
de pagamento

@param  cPayment, caracter, Condição de pagamento

@return caracter, Indica qual o tipo geração de NF atribuída a condição de 
    pagamento, onde: 1=Emite NF após pagamento (B2C);2=Emite NF no vencimento (B2B) 
@author Marcia Junko
@since  21/07/2022
/*/
//------------------------------------------------------------------------------
Function GRRInvGenerate( cPayment )
    Local aArea         := GetArea()
    Local aAreaSE4      := SE4->( GetArea() )
    Local cMakingType   := ''

    Default cPayment    := ""

    If !Empty( cPayment )
        SE4->( DbSetOrder(1) )  // E4_FILIAL+E4_CODIGO
        If SE4->( MsSeek( xFilial( "SE4" ) + cPayment ) )
            IF SE4->( ColumnPos( "E4_PAGGRR" ) ) > 0 .and. SE4->E4_PAGGRR
                cMakingType := '1'
                If SE4->( ColumnPos( "E4_GRRNF" ) ) > 0 .and. SE4->E4_GRRNF $ '1|2'
                    cMakingType := SE4->E4_GRRNF
                EndIf
            EndIf
        EndIf
    EndIf

    RestArea( aAreaSE4 )
    RestArea( aArea )
    
    FWFreeArray( aArea )
    FWFreeArray( aAreaSE4 )
Return cMakingType


//-------------------------------------------------------------------
/*/{Protheus.doc} GRRPayPerOrder
Função chamada para retornar se a condição de pagamento de um pedido 
é do GRR.

@param cOrderNumber, caracter, Número do Pedido de Venda.

@return boolean, indica se o pedido de venda usa uma condição de 
pagamento do GRR
@author Marcia Junko
@since  21/07/2022
/*/
//-------------------------------------------------------------------
Function GRRPayPerOrder( cOrderNumber )
    Local aArea := GetArea()
    Local aAreaSC5	:= SC5->( GetArea() )
    Local lGRRPay := .F. 

    Default cOrderNumber := ""

    dbSelectArea( "SC5" )
    SC5->( DbSetOrder(1) )    // C5_FILIAL+C5_NUM

    If !Empty( cOrderNumber )
        If SC5->( MsSeek( xFilial( "SC5" ) + cOrderNumber ) )
            lGRRPay := IsGRRPayment( SC5->C5_CONDPAG )
        EndIf 
    EndIf

    RestArea( aAreaSC5 )
    RestArea( aArea ) 

    FWFreeArray( aAreaSC5 )
    FWFreeArray( aArea )
Return lGRRPay


//-------------------------------------------------------------------
/*/{Protheus.doc} GRROBSInvoice
Função chamada como gatilho do campo C5_PLANGRR para preencher
a mensagem no campo C5_MENNOTA.

@param cPlanCode, Código do plano
@param cMessage, Messagem padrão caso o pedido não seja do GRR.

@return caracter, mensagem que será gravada no campo C5_MENNOTA
@author  Marcia Junko
@since   15/08/2022
/*/
//-------------------------------------------------------------------
// Function GRROBSInvoice( cPlanCode, cMessage )  
//     Local aSvAlias := GetArea()
//     Local aContent := {}

//     Default cPlanCode := ""
//     Default cMessage := ""

//     If ( Empty( cPlanCode ) .And. Type( "M->C5_PLANGRR" ) == "C" )
//         cPlanCode := M->C5_PLANGRR
//     EndIf

//     If ( Empty( cMessage ) .And. Type( "M->C5_MENNOTA" ) == "C" )  
//         cMessage := M->C5_MENNOTA
//     EndIf       
    
//     If GRRIsActive()
//         If !Empty( cPlanCode ) .And. IsGRRPayment( cPlanCode )
//             cMessage := I18N( 'Compra efetuada através do #1 em #2 parcelas. Central de atendimento do #1: #3. Central de cobrança do #1: #4', aContent )   //'Compra efetuada através do #1 em #2 parcelas. Central de atendimento do #1: #3. Central de cobrança do #1: #4'
//         EndIF
//     EndIf

//     RestArea( aSvAlias ) 

//     FWFreeArray( aContent )  
//     FWFreeArray( aSvAlias )
// Return cMessage 

//-------------------------------------------------------------------
/*/{Protheus.doc} GRRPlanF3
Apresenta a consulta padrão dos planos recorrentes.

@return caracter, mensagem que será gravada no campo C5_MENNOTA
@author  Marcia Junko
@since   30/08/2022
/*/
//-------------------------------------------------------------------
Function GRRPlanF3( )  
    Local aArea	:= GetArea()

    //-----------------------------------------------------------------------
    // Limpa o conteúdo da pergunte para forçar o usuário a sempre
    // selecionar o plano.
    //-----------------------------------------------------------------------
    Pergunte( "GRRPLAN", .F. )
    SetMVValue( "GRRPLAN", "MV_PAR01", "" )

    If Pergunte( "GRRPLAN", .T. )
        M->HRD_CODE := MV_PAR01

        GRRLoadPlan( MV_PAR01 )
    EndIf

    RestArea( aArea )
Return


//-------------------------------------------------------------------
/*/{Protheus.doc} GRRPlanCbx
Determina as opções da lista do combo do cadastro de planos

@param nType, number, indica qual o conteúdo será retornado.

@return caracter, Texto com as opções do combo de acordo com o tipo enviado.
@author Marcia Junko
@since 04/05/2022
/*/
//-------------------------------------------------------------------
Function GRRPlanCbx( nType )
	Local cCbxOpc := ''
	
	Default nType := 1

	If nType == 1   // Forma de pagamento
		cCbxOpc := STR0001 +';' + ;     //'1=Boleto'
					STR0002 +';' + ;    //'2=Cartão de Crédito'
					STR0003             //'3=PIX'
	EndIf
Return cCbxOpc


//-------------------------------------------------------------------------------------
/*/{Protheus.doc} GRRTypeCont
Função que irá validar se o tipo de contrato com a condição de pagamento é valido.  

@param cTypeCont, string, Código do tipo de contrato que será validado.
@param cCondPag, string, Código da condição de pagamento que será validado.

@author  Rodrigo G. Soares
@since   23/01/2023
/*/
//-------------------------------------------------------------------------------------
Function GRRTypeCont( cTypeCont, cCondPag )
    Local aArea	        := GetArea()
    Local aAreaCN1	    := CN1->( GetArea() )
    Local aAreaSE4	    := SE4->( GetArea() )
    Local lRet          := .F.
    Local oModel		:= FWModelActive()
    Local oModelCN9	    := NIL

    DEFAULT cTypeCont := M->CN9_TPCTO
    DEFAULT cCondPag := M->CN9_CONDPG
    
    CN1->( DbSetOrder(1) )    // CN1_FILIAL+CN1_CODIGO+CN1_ESPCTR
    SE4->( DbSetOrder(1) )    // E4_FILIAL+E4_CODIGO

    If FindFunction( "GRRIsActive" ) .And. GRRIsActive()  
        If oModel:Activate()
            oModelCN9	:= oModel:GetModel( 'CN9MASTER' ) //--Cabeçalho do contrato   

            if !Empty( cTypeCont )  .and. CN1->( MsSeek( xFilial( "CN1" ) + cTypeCont ) )
                if CN1->CN1_RECORR = .T. .and. !Empty( cCondPag ) .and. SE4->( MsSeek( xFilial( "SE4" ) + cCondPag ))
                    if SE4->E4_PAGGRR
                        lRet := .T.
                    else
                        oModelCN9:LoadValue( "CN9_PLAGRR", "" )
                    EndIf
                else
                    oModelCN9:LoadValue( "CN9_PLAGRR", "" )
                EndIf
            EndIf
        EndIf
    EndIf

    RestArea( aArea )
    RestArea( aAreaCN1 )
    RestArea( aAreaSE4 )

    FWFreeArray( aArea )
    FWFreeArray( aAreaCN1 )
    FWFreeArray( aAreaSE4 )
Return lRet

