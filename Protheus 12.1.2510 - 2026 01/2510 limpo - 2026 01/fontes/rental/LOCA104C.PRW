#Include "loca104c.ch"

#INCLUDE "TOTVS.CH"
#include "FWMVCDEF.CH"

//-------------------------------------------------------------------
/*/{Protheus.doc} ModelDef
Definição do Modelo da tela de resumo para a seleção de itens para devolução
@type function
@version 24.10 
@author Alexandre Circenis
@since 2/12/2025
@return variant, retorna o objeto view
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

    oStrGrid:AddField( STR0001 , ' ',"PRODUTO"	  , 'C', TamSx3("FQ5_XPROD")[1]	, 0, , , {}, .F.)  //"Produto"
    oStrGrid:AddField( STR0002 , ' ',"DESCPRO"	  , 'C', TamSx3("B1_DESC")[1]	, 0, , , {}, .F.) //"Produto"  // //"Descrição"
	oStrGrid:AddField( STR0003 , ' ',"QTDE"	      , 'N', TamSx3("FQ5_XQTD")[1], TamSx3("FQ5_XQTD")[2], , , {}, .F.) //STR0001 //STR0003 //"Quantidade"
	oStrGrid:AddField( STR0004 , ' ',"QSEGUNID"   , 'N', TamSx3("FQ5_QTD2")[1], TamSx3("FQ5_QTD2")[2], , , {}, .F.) //STR0002 // //"Qtde 2nd"
	oStrGrid:AddField( "ARMZ01" , ' ',"ARMZ01"	  , 'N', TamSx3("FQ5_XQTD")[1], TamSx3("FQ5_XQTD")[2], , , {}, .F.) //STR0004 //"Pendente"
    oStrGrid:AddField( "ARMZ02" , ' ',"ARMZ02"	  , 'N', TamSx3("FQ5_XQTD")[1], TamSx3("FQ5_XQTD")[2], , , {}, .F.) //STR0005 //"Separado"
    oStrGrid:AddField( "ARMZ03" , ' '     ,"ARMZ03"  , 'N', TamSx3("FQ5_XQTD")[1]  , TamSx3("FQ5_XQTD")[2]  , , , {}, .F.) //STR0006 //"Conferido"
    oStrGrid:AddField( "ARMZ04" ,  ' ',"ARMZ04"  , 'N', TamSx3("FQ5_XQTD")[1]  , TamSx3("FQ5_XQTD")[2]  , , , {}, .F.) //"Embarcado //"Embarcado"
    oStrGrid:AddField( "ARMZ05" , ' '     ,"ARMZ05" , 'N', TamSx3("FQ5_XQTD")[1]  , TamSx3("FQ5_XQTD")[2]  , , , {}, .F.) //STR0008 //"Nota Emitida"
    oStrGrid:AddField( STR0005,' ',"PESLIQ"     , 'N', TamSx3("FQ5_PESLIQ")[1], TamSx3("FQ5_PESLIQ")[2], , , {}, .F.) //"Nota Emitida" //"Peso Liquido"
    oStrGrid:AddField( STR0006 , ' ',"PESBRU"     , 'N', TamSx3("FQ5_PESBRU")[1], TamSx3("FQ5_PESBRU")[2], , , {}, .F.) //"Nota Emitida" //"Peso Bruto"
    oStrGrid:AddField( "" , ' '        ,"M3"         , 'N', TamSx3("FQ5_M3")[1]    , TamSx3("FQ5_M3")[2]    , , , {}, .F.) //"Nota Emitida"

    oModel   := MPFormModel():New( 'LOCA104C' )

    //Atribuindo formulários para o modelo
    oModel:AddFields('CABEC', , oStrCampo ,,,{|oSub| LOCA104CCL(oSub) })
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

    oStrGrid:AddField( "PRODUTO"	, '01', STR0001, STR0007,, 'C',GetSx3Cache( "B1_COD" , "X3_PICTURE"))  //"Produto" //"Codigo do Produto"
    oStrGrid:AddField( "DESCPRO"	, '02', STR0002, STR0008,, 'C',GetSx3Cache( "B1_DESC" , "X3_PICTURE")) //"Descrição" //"Descrição do Produto"
	oStrGrid:AddField( "QTDE"	    , '03', STR0003, STR0009,, 'N',GetSx3Cache( "FQ5_QTD2" , "X3_PICTURE"))  //"Quantidade" //"Quantidade na Primeira Unidade"
	oStrGrid:AddField( "QSEGUNID"   , '04', STR0011, STR0010,, 'N',GetSx3Cache( "FQ5_QTD2" , "X3_PICTURE"))  //"Quantidade na Segunda Unidade" //"Qtde Unid 2"
	oStrGrid:AddField( "ARMZ01"	    , '06', "ARMZ01", "ARMZ01",, 'N',GetSx3Cache( "FQX_ARMZ01" , "X3_PICTURE")) 
    oStrGrid:AddField( "ARMZ02" 	, '07', "ARMZ02", "ARMZ02",, 'N',GetSx3Cache( "FQX_ARMZ02" , "X3_PICTURE")) 
    oStrGrid:AddField( "ARMZ03"     , '08', "ARMZ03", "ARMZ03",, 'N',GetSx3Cache( "FQX_ARMZ03" , "X3_PICTURE")) 
    oStrGrid:AddField( "ARMZ04"     , '09', "ARMZ04", "ARMZ04",, 'N',GetSx3Cache( "FQX_ARMZ04" , "X3_PICTURE"))
    oStrGrid:AddField( "ARMZ05"     , '10', "ARMZ05", "ARMZ05",, 'N',GetSx3Cache( "FQX_ARMZ05" , "X3_PICTURE")) 
    oStrGrid:AddField( "PESLIQ"     , '11', STR0005, STR0005,, 'N',GetSx3Cache( "FQ5_PESLIQ" , "X3_PICTURE"))                   //STR0005 //"Peso Liquido"
    oStrGrid:AddField( "PESBRU"     , '12', STR0006, STR0006,, 'N',GetSx3Cache( "FQ5_PESBRU" , "X3_PICTURE") )  //STR0006 //"Peso Bruto"
    oStrGrid:AddField( "M3"         , '13', STR0012, STR0012,, 'N',GetSx3Cache( "FQ5_M3    " , "X3_PICTURE"))  //STR0012 //"Volume m3"

    oStrGrid:SetProperty("*", MVC_VIEW_CANCHANGE, .F.)
    
    // Carrega o Modelo
    oModel  := FWLoadModel( "LOCA104C")
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
/*/{Protheus.doc} LOCA104CCL()
Cria um registro fake
@type function
@example 	LOCA104CCL(oView)
@param		Object, Instância da Classe FwFormView
@return     Array, Contem a carga inicial da tabela fake
@author     Alexandre Circenis
@since      19/03/2019
@version    12
/*/
//------------------------------------------------------------------------------
Static Function LOCA104CCL(oSubModel) 

Local aReg  := {}
  //MASTER
    aReg := {{"FAKE"},0}  

Return(aReg)

