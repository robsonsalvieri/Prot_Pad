#Include "loca259c.ch"
#INCLUDE "TOTVS.CH"
#include "FWMVCDEF.CH"



//-------------------------------------------------------------------
/*/{Protheus.doc} ModelDef
Define um modelo para o resumo
//-------------------------------------------------------------------/*/
Static Function ModelDef()
    local oModel    as object
    local oStrCampo as object
    local oStrGrid  as object

    // Estrutura Fake de Field
    oStrCampo := FWFormModelStruct():New()

    //Adiciona um campo a estrutura.
    oStrCampo:AddField( 'X_ZMVC' , 'X_ZMVC' , 'X_ZMVC' , 'C' , 15 ) 

    //Estrutura de Grid
    oStrGrid := FWFormModelStruct():New()

    oStrGrid:AddField( STR0012 , ' ',"PRODUTO"	  , 'C', TamSx3("FQ5_XPROD")[1]	, 0, , , {}, .F.) //STR0012 //"Produto"
    oStrGrid:AddField( STR0021 , ' ',"DESCPRO"	  , 'C', TamSx3("B1_DESC")[1]	, 0, , , {}, .F.) //"Produto"  //"Descrição"
	oStrGrid:AddField( STR0001 , ' ',"QTDE"	      , 'N', TamSx3("FQ5_XQTD")[1], TamSx3("FQ5_XQTD")[2], , , {}, .F.) //STR0001 //"Quantidade"
	oStrGrid:AddField( STR0002 , ' ',"QSEGUNID"   , 'N', TamSx3("FQ5_QTD2")[1], TamSx3("FQ5_QTD2")[2], , , {}, .F.) //STR0002 //"Qtde 2nd"
	oStrGrid:AddField( STR0003 , ' ',"ARMAZEM"	  , 'C', TamSx3("FPA_LOCAL")[1], 0                   , , , {}, .F.) //STR0003 //"Armazém"
	oStrGrid:AddField( STR0004 , ' ',"PENDENTE"	  , 'N', TamSx3("FQ5_XQTD")[1], TamSx3("FQ5_XQTD")[2], , , {}, .F.) //STR0004 //"Pendente"
    oStrGrid:AddField( STR0005 , ' ',"SEPARADO"	  , 'N', TamSx3("FQ5_XQTD")[1], TamSx3("FQ5_XQTD")[2], , , {}, .F.) //STR0005 //"Separado"
    oStrGrid:AddField( STR0006 , ' '     ,"CONFERIDO"  , 'N', TamSx3("FQ5_XQTD")[1]  , TamSx3("FQ5_XQTD")[2]  , , , {}, .F.) //STR0006 //"Conferido"
    oStrGrid:AddField( STR0007 ,  ' ',"EMBARCADO"  , 'N', TamSx3("FQ5_XQTD")[1]  , TamSx3("FQ5_XQTD")[2]  , , , {}, .F.) //"Embarcado //"Embarcado"
    oStrGrid:AddField( STR0008 , ' '     ,"NOTAGERADA" , 'N', TamSx3("FQ5_XQTD")[1]  , TamSx3("FQ5_XQTD")[2]  , , , {}, .F.) //STR0008 //"Nota Emitida"
    oStrGrid:AddField( STR0009,' ',"PESLIQ"     , 'N', TamSx3("FQ5_PESLIQ")[1], TamSx3("FQ5_PESLIQ")[2], , , {}, .F.) //"Nota Emitida"
    oStrGrid:AddField( STR0010 , ' ',"PESBRU"     , 'N', TamSx3("FQ5_PESBRU")[1], TamSx3("FQ5_PESBRU")[2], , , {}, .F.) //"Nota Emitida"
    oStrGrid:AddField( STR0011 , ' '        ,"M3"         , 'N', TamSx3("FQ5_M3")[1]    , TamSx3("FQ5_M3")[2]    , , , {}, .F.) //"Nota Emitida"

    oModel   := MPFormModel():New( 'LOCA259C' )

    //Atribuindo formulários para o modelo
    oModel:AddFields('CABEC', , oStrCampo ,,,{|oSub| LOCA259CCL(oSub) })
    oModel:AddGrid( 'RESUMO', 'CABEC', oStrGrid)
    oModel:GetModel( 'RESUMO' ):SetOptional( .T. )
    oModel:GetModel( 'RESUMO' ):SetNoInserLine(.F.)
    oModel:GetModel( 'RESUMO' ):SetNoDeleteLine(.T.)
    
    //Adicionando descrição ao modelo
    oModel:SetDescription( "Resumo" )
    // Adiciona a descricao do Componente do Modelo de Dados
    oModel:GetModel( 'CABEC' ):SetDescription( 'MODEL FAKE' )
    oModel:GetModel( 'RESUMO' ):SetDescription( 'Resumo' )
    oModel:SetPrimaryKey( { 'X_ZMVC' } )
    
   
   Return oModel

//-------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
Função estática do ViewDef
@type function
@version 24.10 
@author Alexandre Circenis
@since 2/12/2025
@return variant, retorna o objeto view
/*///-------------------------------------------------------------------/*/
Static Function ViewDef()
local oView    as object
local oModel   as object
local oStrCabec  as object
local oStrGrid as object

    // Instancia a Estrutura
    oStrCabec := FWFormViewStruct():New()
    oStrCabec:AddField( 'X_ZMVC' , '01' , 'X_ZMVC' , 'X_ZMVC',{},'@!'  )
    
    // Instancia a Estrutura
    oStrGrid := FWFormViewStruct():New()

    oStrGrid:AddField( "PRODUTO"	, '01', STR0012, STR0013,, 'C') //STR0012
    oStrGrid:AddField( "DESCPRO"	, '02', STR0021, STR0022,, 'C') //STR0012 //"Descrição" //"Descrição do Produto"
	oStrGrid:AddField( "QTDE"	    , '03', STR0001, STR0001,, 'N') //STR0001
	oStrGrid:AddField( "QSEGUNID"   , '04', STR0002, STR0014,, 'N') //STR0002
	oStrGrid:AddField( "ARMAZEM"	, '05', STR0015, STR0015,, 'C') //"Armazém"
	oStrGrid:AddField( "PENDENTE"	, '06', STR0004, STR0004,, 'N') //STR0004
    oStrGrid:AddField( "SEPARADO"	, '07', STR0005, STR0005,, 'N') //STR0005
    oStrGrid:AddField( "CONFERIDO"  , '08', STR0006, STR0006,, 'N') //STR0006
    oStrGrid:AddField( "EMBARCADO"  , '09', STR0007, STR0007,, 'N') //STR0007
    oStrGrid:AddField( "NOTAGERADA" , '10', STR0008, STR0008,, 'N') //STR0008
    oStrGrid:AddField( "PESLIQ"     , '11', STR0016, STR0017,, 'N') //"Nota Emitida"
    oStrGrid:AddField( "PESBRU"     , '12', STR0018, STR0019,, 'N' ) //"Nota Emitida"
    oStrGrid:AddField( "M3"         , '13 ',STR0020, STR0020,, 'N') //"Nota Emitida"
    oStrGrid:SetProperty("*", MVC_VIEW_CANCHANGE, .F.)
    
    // Carrega o Modelo
    oModel  := FWLoadModel( "LOCA259C")
    // Instancia a VIEW
    oView   := FwFormView():New()

    // Seta o Modelo da View
    oView:SetModel( oModel )
    
    // Estrutura visual dos campos
    oView:AddField('VIEW_CAB', oStrCabec, 'CABEC')
    
    // Estrutura visual das grids
    oView:AddGrid('VIEW_RESUMO', oStrGrid, 'RESUMO')

    //Criando um container com nome tela com 100%
    oView:CreateHorizontalBox( 'CABEC', 0 )
    oView:CreateHorizontalBox( 'GRID', 100 )
     
    oView:SetOwnerView('VIEW_CAB' , 'CABEC' )
    oView:SetOwnerView('VIEW_RESUMO', 'GRID')
    
    oView:SetDescription( "Resumo" )
    
Return oView

//------------------------------------------------------------------------------
/*/{Protheus.doc} LOCA259CCL()
Cria um registro fake
@type function
@example 	LOCA259CCL(oView)
@param		Model, Instância da Classe FwFormView
@return     Array, Contem a carga inicial da tabela fake
@author     Alexandre Circenis
@since      19/03/2019
@version    12
/*/
//------------------------------------------------------------------------------
Static Function LOCA259CCL(oSubModel) 

Local aReg  := {}
  //MASTER
    aReg := {{"FAKE"},0}  

Return(aReg)

