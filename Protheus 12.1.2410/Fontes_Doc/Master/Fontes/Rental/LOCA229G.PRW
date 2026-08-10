#Include "loca229g.ch"

#INCLUDE "TOTVS.CH"
#include "FWMVCDEF.CH"

/*/{Protheus.doc} Loca229G
Função de apresentação de eventos de processamento
@type function
@version  25.10 
@author Alexandre Circenis
@since 6/10/2025
@param cTitulo, character, Titulo da janela de eventos
@param aEventos, array, Contem os eventos de processamento estrutura segue o exemplo abaixo:
AEventos := { 
                {lSucesso1, cEvento1 ,{ 
                                        { lSucesso1.1, cHistorico1.1 },
                                        { lSucesso1.2, cHistorico1.2 }
                                       } },
                {lSucesso2, cEvento2 ,{ 
                                        { lSucesso1.1, cHistorico1.1 },
                                        { lSucesso1.2, cHistorico1.2 },
                                        { lSucesso1.3, cHistorico1.3 },
                                        { lSucesso1.n, cHistorico1.3 }
                                       } }
            }                             
    lSucesso irá ser apresentado com um bitmap verde ou vermelho para indicar respectivamente o sucesso ou não 
    na analise do evento ou do histórico
    cEvento e cHistorico são strings                       
@return variant, true para garantir que o MVC não interprete como erro
/*/
Function Loca229G(cTitulo, aEventos)
//Local oTela := FWLoadModel("LOCA229G")

Local aEnableButtons := {}
Local nOperation := MODEL_OPERATION_VIEW

Private aMens := aClone(aEventos)

// Habilitar somente os botões Confirmar e Cancelar
aEnableButtons := {{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.T.,STR0001},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil}} //"Cancelar" //"Confirmar" //"Fechar"

// Incluir uma nova demanda 
FWExecView( cTitulo  , 'LOCA229G', nOperation, /*oDlg*/, {|| .T. } ,/*bOk*/ , 60, aEnableButtons, /*bCancel*/ , /*cOperatId*/, /*cToolBar*/) 

return .t.

/*/{Protheus.doc} ModelDef
Model para apresentação de eventos de validação no formato de grid
@type function
@version  25.10
@author Alexandre Circenis
@since 6/6/2025
@return variant, Model de apresentação
/*/
Static Function ModelDef()
Local oModel    as object
Local oStrCampo as object
Local oStrEvento  as object
Local oStrResult  as object

    // Estrutura Fake de Field
    oStrCampo := FWFormModelStruct():New()

    //Adiciona um campo a estrutura.
    oStrCampo:AddField( 'X_ZMVC' , 'X_ZMVC' , 'X_ZMVC' , 'C' , 15 ) 

    //Estrutura de Grid
    oStrEvento := FWFormModelStruct():New()
    oStrResult := FWFormModelStruct():New()

    oStrEvento:AddField( "EVENTO" , ' ',"XXEVENTO"	  , 'C', 3	, 0, , , {}, .F.) 
    oStrEvento:AddField( "STATUS" , ' ',"XXSTATUS"	  , 'C', 20	, 0, , , {}, .F.) 
	oStrEvento:AddField( "Descrição" , ' ',"XXDESC"	      , 'C', 60, 0, , , {}, .F.) 
	
    oStrResult:AddField( "EVENTO" , ' ',"XXEVENTO"	  , 'C', 3	, 0, , , {}, .F.) 
    oStrResult:AddField( "STATUS" , ' ',"XXSTATUS"	  , 'C', 20	, 0, , , {}, .F.) 
	oStrResult:AddField( "Descrição" , ' ',"XXDESC"	      , 'C', 100, 0, , , {}, .F.)
	
    oModel   := MPFormModel():New( 'LOCA229G' )

    //Atribuindo formulários para o modelo
    oModel:AddFields('CABEC', , oStrCampo ,,,{|oSub| LOCA259CCL(oSub) })
    oModel:AddGrid( 'EVENTO', 'CABEC', oStrEvento, , , , , {|oModel| Loca229GLd('1', oModel)} )
    oModel:AddGrid( 'RESULTADO', 'EVENTO', oStrResult, , , , , {|oModel| Loca229GLd('2', oModel)})
    
    oModel:GetModel( 'EVENTO' ):SetOptional( .T. )
   // oModel:GetModel( 'EVENTO' ):SetNoInserLine(.F.)
   // oModel:GetModel( 'EVENTO' ):SetNoDeleteLine(.T.)

    oModel:GetModel( 'RESULTADO' ):SetOptional( .T. )
   // oModel:GetModel( 'RESULTADO' ):SetNoInserLine(.F.)
    //oModel:GetModel( 'RESULTADO' ):SetNoDeleteLine(.T.)
    
    //Adicionando descrição ao modelo
    oModel:SetDescription( "Eventos " )
    //Setando a chave primária da rotina
    oModel:SetRelation( 'RESULTADO', { { 'XX_EVENTO', 'XX_EVENTO' }})

    // Adiciona a descricao do Componente do Modelo de Dados
    oModel:GetModel( 'CABEC' ):SetDescription( 'MODEL FAKE' )
    oModel:GetModel( 'EVENTO' ):SetDescription( STR0002 ) //'Eventos'
    oModel:GetModel( 'RESULTADO' ):SetDescription( STR0003 ) //'Resultados'
    oModel:SetPrimaryKey( { 'X_ZMVC' } )
    
Return oModel


/*/{Protheus.doc} ViewDef
Função estática da view de apresnetação de analise
@type function
@version 24.10 
@author Alexandre Circenis
@since 2/12/2025
@return variant, retorna o objeto view
/*/
Static Function ViewDef()
local oView    as object
local oModel   as object
local oStrCabec  as object
local oStrEvento as object
local oStrResult as object

    // Instancia a Estrutura
    oStrCabec := FWFormViewStruct():New()

    oStrCabec:AddField( 'X_ZMVC' , '01' , 'X_ZMVC' , 'X_ZMVC',{},'C','@!'  )
    
    // Instancia a Estrutura
    oStrEvento := FWFormViewStruct():New()

    oStrEvento:AddField( 'XXSTATUS'	, '01', STR0004, STR0004,, 'C','@BMP')  //"Status" //'C'
    oStrEvento:AddField( "XXDESC"	, '02', STR0006, STR0006,, 'C')  //STR0006 //"Descrição"
	
    oStrResult := FWFormViewStruct():New()

    oStrResult:AddField( 'XXSTATUS'	, '01', STR0004, STR0004,, 'C','@BMP')  //STR0004 //"Status"
    oStrResult:AddField( "XXDESC"	, '02', STR0007, STR0007,, 'C')  //STR0007 //"Descricão"
	
    // Carrega o Modelo
    oModel  := FWLoadModel( "LOCA229G")
    // Instancia a VIEW
    oView   := FwFormView():New()

    // Seta o Modelo da View
    oView:SetModel( oModel )
    
    // Estrutura visual dos campos
    oView:AddField('VIEW_CAB', oStrCabec, 'CABEC')
    
    // Estrutura visual das grids
    oView:AddGrid('VIEW_EVENTO', oStrEvento, 'EVENTO')
    oView:AddGrid('VIEW_RESULT', oStrResult, 'RESULTADO')

    //Criando um container com nome tela com 100%
    oView:CreateHorizontalBox( 'W_CABEC', 0 )
    oView:CreateHorizontalBox( 'W_EVENTO', 50 )
    oView:CreateHorizontalBox( 'W_RESULT', 50 )
     
    oView:SetOwnerView('VIEW_CAB' , 'W_CABEC' )
    oView:SetOwnerView('VIEW_EVENTO', 'W_EVENTO')
    oView:SetOwnerView('VIEW_RESULT', 'W_RESULT')

Return oView

/*/{Protheus.doc} LOCA259CCL()
Cria um registro fake
@type function
@param		oSubModel, object, Instância da Classe FwFormView
@return     Array, Contem a carga inicial da tabela fake
@author     Alexandre Circenis
@since      19/03/2019
@version    12
/*/
Static Function LOCA259CCL(oSubModel) 

Local aReg  := {}
  //MASTER
    aReg := {{"FAKE"},0}  

Return(aReg)

/*/{Protheus.doc} Loca229GLd
Retorna os dados para preenchimento do model LOCA229G
@type function
@version  25.10 
@author Alexandre Circenis
@since 6/6/2025
@param cTipo, character, Tipo do submodel a sem preenchido
@param oModel, object, Model que será preenchido
@return variant, Array com os dados para preencher o model
/*/
Function Loca229GLd(cTipo, oModel)
Local nX
LOcal nY
Local cErro := "SPS_ERROR_S"
Local cSucesso := "SPS_SUCCESS_S"
Local aData := {}
Local cEvento
Local oEvento := oModel:GetModel():GetModel("EVENTO")

for nX := 1 to Len(aMens)
    if cTipo = '1' // Preencher o model de eventos
        Aadd( aData, { 0 , {  StrZero(nX, 3,0), If( aMens[nX, 1], cSucesso, cErro) , aMens[nX, 2]}})
    elseif cTipo = '2' // Preencher o Submodel RESULT 
        cEvento := oEvento:GetValue('XXEVENTO')// Codigo do evento principal para usar indicar qual subarray sera usado 
        if  StrZero(nX, 3,0) = cEvento 
            for nY := 1 to Len(aMens[nX, 3])
                Aadd( aData ,{ 0, { StrZero(nX, 3,0), If( aMens[nX, 3, nY , 1], cSucesso, cErro), aMens[nX, 3, nY , 2]}})
            next nY
        endif
    endif
next nx

Return aData
