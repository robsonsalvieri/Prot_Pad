#INCLUDE 'PROTHEUS.CH'
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "GTPA801.CH"

Static  lPlaCust    :=  .F.

/*/
 * {Protheus.doc} GTPA801()
 * Documento do Cliente para Transporte
 * type    Function
 * author  Eduardo Ferreira
 * since   16/08/2019
 * version 12.25
 * param   Não há
 * return  oBrowse
/*/
Function GTPA801()

    Local oBrowse := Nil
    
    Private aRotina := {}
    
    If ( !FindFunction("GTPHASACCESS") .Or.; 
	    ( FindFunction("GTPHASACCESS") .And. GTPHasAccess() ) ) 
    
        aRotina := MenuDef()
        oBrowse := FWLoadBrw('GTPA801')
        oBrowse:SetMenuDef('GTPA801')

        oBrowse:Activate()
        GTPMSWord(.t.)  //fechar a conexão com o word
        
    EndIf

Return()

//------------------------------------------------------------------------------
/*/{Protheus.doc} BrowseDef
Função responsavel pela definição do browse da Amarração de Recurso x Documento
@type Static Function
@author jacomo.fernandes
@since 09/07/2019
@version 1.0
@param , character, (Descrição do parâmetro)
@return oBrowse, retorna o objeto de browse
@example
(examples)
@see (links_or_references)
/*/
//------------------------------------------------------------------------------
Static Function BrowseDef()
Local oBrowse       := FWMBrowse():New()

oBrowse:SetAlias("G99")

oBrowse:SetDescription(STR0033) //"Entrada de Encomendas"

//Status Encomenda
oBrowse:AddLegend("G99_STAENC=='1'"    , "YELLOW"       ,STR0003 ,"G99_STAENC")// "Encomenda aguardando Transporte"             
oBrowse:AddLegend("G99_STAENC=='2'"    , "BLUE"         ,STR0004 ,"G99_STAENC")// "Encomenda em Transporte"                     
//oBrowse:AddLegend("G99_STAENC=='3'"    , "ORANGE"       ,STR0005 ,"G99_STAENC")// "Encomenda em Transbordo"                     
oBrowse:AddLegend("G99_STAENC=='4'"    , "GREEN"        ,STR0006 ,"G99_STAENC")// "Encomenda Recebida"                          
oBrowse:AddLegend("G99_STAENC=='5'"    , "BLACK"        ,STR0007 ,"G99_STAENC")// "Encomenda Retirada"                          

//Status Transmissão
oBrowse:AddLegend("G99_STATRA=='0'"    , "WHITE"        ,STR0008 ,"G99_STATRA")// "CTe Não Transmitido"                         
oBrowse:AddLegend("G99_STATRA=='1'"    , "YELLOW"       ,STR0009 ,"G99_STATRA")// "CTe Aguardando"                              
oBrowse:AddLegend("G99_STATRA=='2'"    , "GREEN"        ,STR0010 ,"G99_STATRA")// "CTe Autorizado"                              
oBrowse:AddLegend("G99_STATRA=='3'"    , "RED"          ,STR0011 ,"G99_STATRA")// "CTe Nao Autorizado"                          
oBrowse:AddLegend("G99_STATRA=='4'"    , "BLUE"         ,STR0012 ,"G99_STATRA")// "CTe em Contingencia"                         
oBrowse:AddLegend("G99_STATRA=='5'"    , "GRAY"         ,STR0013 ,"G99_STATRA")// "CTe com Falha na Comunicacao"                
oBrowse:AddLegend("G99_STATRA=='6'"    , "BR_PRETO_1"   ,STR0014 ,"G99_STATRA")// "Doc. de Saída Excluído"                      
oBrowse:AddLegend("G99_STATRA=='7'"    , "BROWN"        ,STR0015 ,"G99_STATRA")// "Rejeitado Cancelamento"                      
oBrowse:AddLegend("G99_STATRA=='8'"    , "BLACK"        ,STR0016 ,"G99_STATRA")// "CTe Cancelado"                               
oBrowse:AddLegend("G99_STATRA=='9'"    , "ORANGE"       ,STR0017 ,"G99_STATRA")// "Documento não preparado para transmissão"    
oBrowse:AddLegend("G99_STATRA=='A'"    , "PINK"   ,'CT-e de Anulação Autorizada' ,"G99_STATRA")// "Documento não preparado para transmissão"    

//Status Averbação
oBrowse:AddLegend("G99_AVERBA $ ' |0'" , "WHITE"        ,STR0018 ,"G99_AVERBA")// "Averbação não transmitida"                   
oBrowse:AddLegend("G99_AVERBA=='1'"    , "YELLOW"       ,STR0019 ,"G99_AVERBA")// "Averbação aguardando retorno"                
oBrowse:AddLegend("G99_AVERBA=='2'"    , "GREEN"        ,STR0020 ,"G99_AVERBA")// "Averbação aceita"                            
oBrowse:AddLegend("G99_AVERBA=='3'"    , "RED"          ,STR0021 ,"G99_AVERBA")// "Averbação rejeitada"                         
oBrowse:AddLegend("G99_AVERBA=='4'"    , "BLACK"        ,STR0022 ,"G99_AVERBA")// "Averbação cancelada"                         

//Tipo CTE
// Adiciona as colunas do Browse
oColumn := FWBrwColumn():New()
oColumn:SetData( {|| RetCboxBrw("G99_TIPCTE", G99->G99_TIPCTE)} )
oColumn:SetTitle("Tipo CTE")
oColumn:SetSize(1)
oBrowse:SetColumns({oColumn})

Return oBrowse

//------------------------------------------------------------------------------
/*/{Protheus.doc} RetCboxBrw
Função responsavel pela definição do browse da Amarração de Recurso x Documento
@type Static Function
@author jacomo.fernandes
@since 09/07/2019
@version 1.0
@param , character, (Descrição do parâmetro)
@return oBrowse, retorna o objeto de browse
/*/
//------------------------------------------------------------------------------
Static Function RetCboxBrw(cField,uVal)
Local uRet  := uVal

Do Case
    Case cField == "G99_TIPCTE"
        If uVal == "0"
            uRet    := STR0023 //"Normal"
        ElseIf uVal == "1"
            uRet    := STR0024 //"Complemento"
        ElseIf uVal == "2"
            uRet    := STR0025 //"Anulação"
        Else
            uRet    := STR0026 //"Substituição"
        Endif

EndCase

Return uRet


/*/
 * {Protheus.doc} MenuDef()
 * Menu da Rotina 
 * type    Static Function
 * author  Eduardo Ferreira
 * since   16/08/2019
 * version 12.25
 * param   Não há
 * return  aRotina
/*/
Static Function MenuDef()
Local aMenu := {}
		
ADD OPTION aMenu TITLE STR0027 ACTION "VIEWDEF.GTPA801"                        OPERATION 2 ACCESS 0 //"Visualizar"            
ADD OPTION aMenu TITLE STR0028 ACTION "GA801INC()"                             OPERATION 3 ACCESS 0 //"Incluir"               
ADD OPTION aMenu TITLE STR0029 ACTION "VIEWDEF.GTPA801"                        OPERATION 4 ACCESS 0 //"Alterar"               
ADD OPTION aMenu TITLE STR0030 ACTION "VIEWDEF.GTPA801"                        OPERATION 5 ACCESS 0 //"Excluir"               
ADD OPTION aMenu TITLE STR0031 ACTION "ExeRecibo()"                            OPERATION 8 ACCESS 0 //"Recibo"                
ADD OPTION aMenu TITLE STR0032 ACTION "MsDocument('G99' , G99->(Recno()),3 )"  OPERATION 4 ACCESS 0 //"Base de Conhecimento"  
ADD OPTION aMenu TITLE STR0158 ACTION "GTPR801"                                OPERATION 4 ACCESS 0   //"Decl. Responsabilidade" 

Return aMenu

/*/
 * {Protheus.doc} ModelDef()
 * Model 
 * type    Static Function
 * author  Eduardo Ferreira
 * since   16/08/2019
 * version 12.25
 * param   Não há
 * return  oModel
/*/
Static Function ModelDef()
Local oModel    := nil
Local oStrG99   := FWFormStruct(1, "G99") //Entrada de Encomendas
Local oStrG9R   := FWFormStruct(1, "G9R") //Declaração
Local oStrG9Q   := FWFormStruct(1, "G9Q") //Serviços
Local oStrG9P   := FWFormStruct(1, "G9P") //Estados
Local oStrGIR	:= FWFormStruct(1, "GIR") //Formas de Pagamento
Local oStrGIY	:= FWFormStruct(1, "GIY") //Formas de Pagamento

Local bPreLine  := {|oModel,nLine,cAction,cField,uValue| VldPreLine(oModel,nLine,cAction,cField,uValue)}
Local bPosValid := {|oModel| PosValid(oModel)}
// Local bCommit   := {|oModel| Commit(oModel)}

SetModelStruct(oStrG99,oStrG9R,oStrG9Q,oStrG9P, oStrGIR)

    If G99->(FieldPos('G99_KGFRET')) > 0
        oStrG99:SetProperty('G99_KGFRET',MODEL_FIELD_OBRIGAT, .F. )
    ENDIF

oModel := MPFormModel():New("GTPA801",/*PREVALID*/, bPosValid/*POSVALID*/, /*COMMIT*/)
oModel:SetDescription(STR0033)//"Entrada de Encomendas"

//Cabeçalho G99 -- Entrada de Encomendas
oModel:AddFields("MASTERG99",/*oOwner*/, oStrG99)
oModel:GetModel("MASTERG99"):SetDescription(STR0033)//"Entrada de Encomendas"

//Grid - G9R -- Declaração
oModel:AddGrid("DETAILG9R", "MASTERG99", oStrG9R, bPreLine)
oModel:SetRelation("DETAILG9R", {{"G9R_FILIAL", "xFilial('G9R')"}, {"G9R_CODIGO", "G99_CODIGO"}}, G9R->(IndexKey(1)))
oModel:GetModel("DETAILG9R"):SetUniqueLine({"G9R_DESCRI"})
oModel:GetModel("DETAILG9R"):SetDescription(STR0034)//"Declaração de Encomendas"

//Grid - G9Q -- Serviços de transporte
oModel:AddGrid("DETAILG9Q", "MASTERG99", oStrG9Q,bPreLine )
oModel:SetRelation("DETAILG9Q", {{"G9Q_FILIAL", "xFilial('G9Q')"}, {"G9Q_CODIGO", "G99_CODIGO"}}, G9Q->(IndexKey(1)))
oModel:GetModel("DETAILG9Q"):SetUniqueLine({'G9Q_CODLIN', 'G9Q_SERVIC','G9Q_LOCINI','G9Q_LOCFIM'})
oModel:GetModel("DETAILG9Q"):SetDescription(STR0035)//"Serviços de transporte"

//Grid - G9P -- Lista de Estados
oModel:AddGrid("DETAILG9P", "MASTERG99", oStrG9P)
oModel:SetRelation("DETAILG9P", {{"G9P_FILIAL", "xFilial('G9P')"}, {"G9P_CODIGO", "G99_CODIGO"}}, G9P->(IndexKey(1)))
oModel:GetModel("DETAILG9P"):SetUniqueLine({'G9P_ESTADO'})
oModel:GetModel("DETAILG9P"):SetDescription(STR0036)//"Lista de Estados"

//Grid - GIR -- Formas de Pagamento
oModel:AddGrid("DETAILGIR", "MASTERG99", oStrGIR)
oModel:SetRelation("DETAILGIR", {{"GIR_FILIAL", "xFilial('GIR')"}, {"GIR_CODIGO", "G99_CODIGO"}}, GIR->(IndexKey(1)))
oModel:GetModel("DETAILGIR"):SetDescription(STR0137) //"Formas de Pagamento"
oModel:GetModel("DETAILGIR"):SetMaxLine(99)

//Grid - GIY -- Formas de Pagamento x Baixas de Tit.Receber 
oModel:AddGrid("DETAILGIY", "DETAILGIR", oStrGIY)
oModel:SetRelation("DETAILGIY", {{"GIY_FILIAL", "xFilial('GIY')"}, {"GIY_CODIGO", "GIR_CODIGO"}, {"GIY_SEQ", "GIR_SEQ"}}, GIY->(IndexKey(1)))
oModel:GetModel("DETAILGIY"):SetDescription(STR0159) //"Formas de Pagamento x BAIXA TIT. "
oModel:GetModel("DETAILGIY"):SetOptional(.t.) 


oModel:SetPrimarykey({"G99_FILIAL", "G99_CODIGO"})

Return oModel

/*/
 * {Protheus.doc} ViewDef()
 * View
 * type    Static Function
 * author  Eduardo Ferreira
 * since   16/08/2019
 * version 12.25
 * param   Não há 
 * return  oView
/*/
Static Function ViewDef()

Local oModel    := FWLoadModel("GTPA801")
Local oStG99E   := FWFormStruct(2, "G99")
Local oStG99C   := FWFormStruct(2, "G99")
Local oStrG9R   := FWFormStruct(2, "G9R")
Local oStrG9Q   := FWFormStruct(2, "G9Q")
Local oStrG9P   := FWFormStruct(2, "G9P")
Local oStrGIR   := FWFormStruct(2, "GIR")

Local oView     := nil
Local bVisuDoc := {|oView| GTPDocFis()}

SetViewStruct(oStG99E,oStG99C,oStrG9R,oStrG9Q,oStrG9P,oStrGIR)

oView := FwFormView():New()
oView:SetModel(oModel)

//Cabeçalho - G99
oView:AddField("FILD_VIEWG99E", oStG99E, "MASTERG99")
oView:AddField("FILD_VIEWG99O", oStG99C, "MASTERG99")
oView:AddGrid("GRID_VIEWG9R" , oStrG9R, "DETAILG9R")
oView:AddGrid("GRID_VIEWG9Q" , oStrG9Q, "DETAILG9Q")
oView:AddGrid("GRID_VIEWG9P" , oStrG9P, "DETAILG9P")
oView:AddGrid("GRID_VIEWGIR" , oStrGIR, "DETAILGIR")

oView:CreateFolder("FOLDER")

oView:AddSheet( "FOLDER", "ABA01", STR0037) // "Encomendas"
oView:CreateHorizontalBox( 'BOX_ENCOMENDAS' , 60, /*owner*/,/*lUsePixel*/, 'FOLDER', 'ABA01' ) 
oView:CreateHorizontalBox( 'BOX_BAIXO'      , 40, /*owner*/,/*lUsePixel*/, 'FOLDER', 'ABA01' ) 

oView:CreateFolder("FOLDER_BAIXO", "BOX_BAIXO")
oView:AddSheet("FOLDER_BAIXO",'SHEET_DECLARACOES' , STR0038)//"Declarações"
oView:AddSheet("FOLDER_BAIXO",'SHEET_SERVICOS'    , STR0039)//"Serviços"
oView:AddSheet("FOLDER_BAIXO",'SHEET_PAGAMENTO'   , STR0137)//"Formas de Pagamento"

oVIew:CreateHorizontalBox('BOX_DECLARACOES', 100,,,'FOLDER_BAIXO', 'SHEET_DECLARACOES' )

oView:CreateVerticalBox( 'BOX_SERVICO', 80, , , 'FOLDER_BAIXO', 'SHEET_SERVICOS')
oView:CreateVerticalBox( 'BOX_ESTADOS', 20, , , 'FOLDER_BAIXO', 'SHEET_SERVICOS')
oView:CreateVerticalBox( 'BOX_PAGAMENTO', 100, , , 'FOLDER_BAIXO', 'SHEET_PAGAMENTO')

oView:AddSheet( "FOLDER", "ABA02", STR0040) // "Conhecimento"
oView:CreateHorizontalBox( 'BOX_CONHECIMENTO' , 100, /*owner*/,/*lUsePixel*/, 'FOLDER', 'ABA02' ) 

oView:SetOwnerView("FILD_VIEWG99E" , "BOX_ENCOMENDAS"   )
oView:SetOwnerView("FILD_VIEWG99O" , "BOX_CONHECIMENTO" )
oView:SetOwnerView("GRID_VIEWG9R"  , "BOX_DECLARACOES"  )
oView:SetOwnerView("GRID_VIEWG9Q"  , "BOX_SERVICO"      )
oView:SetOwnerView("GRID_VIEWG9P"  , "BOX_ESTADOS"      )
oView:SetOwnerView("GRID_VIEWGIR"  , "BOX_PAGAMENTO"    )

oView:addIncrementField("GRID_VIEWG9R", "G9R_ITEM")
oView:addIncrementField("GRID_VIEWG9Q", "G9Q_ITEM")
oView:addIncrementField("GRID_VIEWG9P", "G9P_ITEM")
oView:addIncrementField("GRID_VIEWGIR", "GIR_SEQ")

If oModel:GetOperation()==MODEL_OPERATION_VIEW
	oView:AddUserButton(STR0002, "MAGIC_BMP",bVisuDoc, STR0002) //"Visualiza Doc."
EndIf
    
oView:AddUserButton( "Calc Preco", "", {|| GA801Calc(oView)},,VK_F5,{MODEL_OPERATION_INSERT, MODEL_OPERATION_UPDATE} ) //"Executar Filtro" //"Calc Custo"

oView:SetAfterViewActivate( { || AfterActiv(oView)})

Return oView

/*/
 * {Protheus.doc} SetModelStruct()
 * Estrutura do Model
 * type    Static Function
 * author  Eduardo Ferreira
 * since   16/08/2019
 * version 12.25
 * param   oStrG99, oStrG9R, oStrG9Q, oStrG9P
 * return  Não há
/*/
Static Function SetModelStruct(oStrG99, oStrG9R, oStrG9Q, oStrG9P, oStrGIR)
Local bFldVld	    := {|oMdl,cField,uNewValue,uOldValue|FieldValid(oMdl,cField,uNewValue,uOldValue) }
Local bTrig		    := {|oMdl,cField,uVal| FieldTrigger(oMdl,cField,uVal)}
Local bInit		    := {|oMdl,cField| FieldInit(oMdl,cField)}
Local bWhen         := {|oMdl,cField,uVal| FieldWhen(oMdl,cField,uVal)}
Local nX            := 0
Local aFldG9P 	    := {}
Local cFldG9P 	    := "G9P_CODG6X|G9P_SERIE|G9P_NUMDOC|G9P_VALOR|"
Local lNewFlds      := G99->(FieldPos("G99_CLIEXP")) > 0

//Entrada de Documentos
If ValType(oStrG99) == "O"
    
    oStrG99:AddField(STR0148, STR0148, "G99_DOCREM", "C", 14, 0, {|| .T.},{|| .T.},{},.F.,NIL,.F.,.F.,.T.) // "Docto. Remetente"
    oStrG99:AddField(STR0149, STR0149, "G99_DOCDES", "C", 14, 0, {|| .T.},{|| .T.},{},.F.,NIL,.F.,.F.,.T.) // "Docto. Destinatário"

    oStrG99:SetProperty("G99_TS"     , MODEL_FIELD_OBRIGAT, .F.)
    oStrG99:SetProperty("G99_CFOP"   , MODEL_FIELD_OBRIGAT, .F.)
    oStrG99:SetProperty("G99_DTPREV" , MODEL_FIELD_OBRIGAT, .F.)
    oStrG99:SetProperty("G99_HRPREV" , MODEL_FIELD_OBRIGAT, .F.)

    oStrG99:SetProperty("G99_NOMREM" , MODEL_FIELD_INIT, bInit)
    oStrG99:SetProperty("G99_NOMDES" , MODEL_FIELD_INIT, bInit)
    oStrG99:SetProperty("G99_DOCREM" , MODEL_FIELD_INIT, bInit)
    oStrG99:SetProperty("G99_DOCDES" , MODEL_FIELD_INIT, bInit)
    oStrG99:SetProperty("G99_DESEMI" , MODEL_FIELD_INIT, bInit)
    oStrG99:SetProperty("G99_DESREC" , MODEL_FIELD_INIT, bInit)
    oStrG99:SetProperty("G99_DESPRO" , MODEL_FIELD_INIT, bInit)

    If  G99->(ColumnPos("G99_TIPMOD")) > 0
        oStrG99:SetProperty("G99_TIPMOD" , MODEL_FIELD_INIT, bInit)
        oStrG99:SetProperty("G99_DTPREV" , MODEL_FIELD_WHEN, bWhen)
        oStrG99:SetProperty("G99_INFMAN" , MODEL_FIELD_WHEN, bWhen)
        oStrG99:SetProperty("G99_TARCL"  , MODEL_FIELD_WHEN, bWhen)
        oStrG99:SetProperty("G99_TARVAL" , MODEL_FIELD_WHEN, bWhen)
        oStrG99:AddTrigger("G99_TIPMOD" ,"G99_TIPMOD" ,{||.T.} ,bTrig)       
    EndIf

    oStrG99:SetProperty("G99_NTBFRE" , MODEL_FIELD_INIT, bInit)
    oStrG99:SetProperty("G99_SERIE"  , MODEL_FIELD_INIT, bInit)
    oStrG99:SetProperty("G99_DTEMIS" , MODEL_FIELD_INIT, bInit)
    oStrG99:SetProperty("G99_HREMIS" , MODEL_FIELD_INIT, bInit)
    oStrG99:SetProperty("G99_USUINC" , MODEL_FIELD_INIT, bInit)
    oStrG99:SetProperty("G99_TIPCTE" , MODEL_FIELD_INIT, bInit)
    
    oStrG99:SetProperty("G99_STAENC" , MODEL_FIELD_INIT, bInit)
    oStrG99:SetProperty("G99_STATRA" , MODEL_FIELD_INIT, bInit)
    oStrG99:SetProperty("G99_AVERBA" , MODEL_FIELD_INIT, bInit)

    oStrG99:SetProperty("G99_CLIREM" , MODEL_FIELD_VALID, bFldVld)
    oStrG99:SetProperty("G99_LOJREM" , MODEL_FIELD_VALID, bFldVld)
    oStrG99:SetProperty("G99_CLIDES" , MODEL_FIELD_VALID, bFldVld)
    oStrG99:SetProperty("G99_LOJDES" , MODEL_FIELD_VALID, bFldVld)
    oStrG99:SetProperty("G99_TOMADO" , MODEL_FIELD_VALID, bFldVld)

    if lNewFlds
        oStrG99:AddField("Docto. Expedidor", "Docto. Expedidor", "G99_DOCEXP", "C", 14, 0, {|| .T.},{|| .T.},{},.F.,NIL,.F.,.F.,.T.) // "Docto. Expedidor"
        
        oStrG99:SetProperty("G99_DOCEXP" , MODEL_FIELD_INIT, bInit)
        oStrG99:SetProperty("G99_DOCEXP" , MODEL_FIELD_VALID, bFldVld)        
        oStrG99:SetProperty("G99_CLIEXP" , MODEL_FIELD_VALID, bFldVld)
        oStrG99:SetProperty("G99_LOJEXP" , MODEL_FIELD_VALID, bFldVld) 
        
        oStrG99:AddTrigger("G99_DOCEXP" ,"G99_DOCEXP" ,{||.T.} ,bTrig)
        oStrG99:AddTrigger("G99_CLIEXP" ,"G99_CLIEXP" ,{||.T.} ,bTrig)
        oStrG99:AddTrigger("G99_LOJEXP" ,"G99_LOJEXP" ,{||.T.} ,bTrig)       
    Endif
    oStrG99:SetProperty("G99_CODEMI" , MODEL_FIELD_VALID, bFldVld)
    oStrG99:SetProperty("G99_CODREC" , MODEL_FIELD_VALID, bFldVld)
    oStrG99:SetProperty("G99_CODPRO" , MODEL_FIELD_VALID, bFldVld)
    oStrG99:SetProperty("G99_TABFRE" , MODEL_FIELD_VALID, bFldVld)
    oStrG99:SetProperty("G99_HRPREV" , MODEL_FIELD_VALID, bFldVld)
    oStrG99:SetProperty("G99_SERIE"  , MODEL_FIELD_VALID, bFldVld)
    oStrG99:SetProperty("G99_DOCREM" , MODEL_FIELD_VALID, bFldVld)
    oStrG99:SetProperty("G99_DOCDES" , MODEL_FIELD_VALID, bFldVld)
    
    oStrG99:SetProperty("G99_TIPCTE" , MODEL_FIELD_VALUES, RetCboxFld("G99_TIPCTE"))
    oStrG99:SetProperty("G99_STAENC" , MODEL_FIELD_VALUES, RetCboxFld("G99_STAENC"))
    oStrG99:SetProperty("G99_STATRA" , MODEL_FIELD_VALUES, RetCboxFld("G99_STATRA"))
    oStrG99:SetProperty("G99_AVERBA" , MODEL_FIELD_VALUES, RetCboxFld("G99_AVERBA"))
    oStrG99:SetProperty("G99_TPEMIS" , MODEL_FIELD_VALUES, RetCboxFld("G99_TPEMIS"))
    oStrG99:SetProperty("G99_VALOR"  , MODEL_FIELD_WHEN, bWhen)

    oStrG99:AddTrigger("G99_CLIREM" ,"G99_CLIREM" ,{||.T.} ,bTrig)
    oStrG99:AddTrigger("G99_LOJREM" ,"G99_LOJREM" ,{||.T.} ,bTrig)
    oStrG99:AddTrigger("G99_CLIDES" ,"G99_CLIDES" ,{||.T.} ,bTrig)
    oStrG99:AddTrigger("G99_LOJDES" ,"G99_LOJDES" ,{||.T.} ,bTrig)
    oStrG99:AddTrigger("G99_CODEMI" ,"G99_CODEMI" ,{||.T.} ,bTrig)
    oStrG99:AddTrigger("G99_CODREC" ,"G99_CODREC" ,{||.T.} ,bTrig)
    oStrG99:AddTrigger("G99_CODPRO" ,"G99_CODPRO" ,{||.T.} ,bTrig)
    oStrG99:AddTrigger("G99_TABFRE" ,"G99_TABFRE" ,{||.T.} ,bTrig)
    oStrG99:AddTrigger("G99_KMFRET" ,"G99_KMFRET" ,{||.T.} ,bTrig)
    oStrG99:AddTrigger("G99_TOMADO" ,"G99_TOMADO" ,{||.T.} ,bTrig)
    oStrG99:AddTrigger("G99_VALOR"  ,"G99_VALOR"  ,{||.T.} ,bTrig)
    oStrG99:AddTrigger("G99_DOCREM" ,"G99_DOCREM" ,{||.T.} ,bTrig)
    oStrG99:AddTrigger("G99_DOCDES" ,"G99_DOCDES" ,{||.T.} ,bTrig)

    oStrG9Q:SetProperty("G9Q_KILOME"    , MODEL_FIELD_WHEN, bWhen)

Endif

    If G99->(FieldPos('G99_KGFRET')) > 0
        oStrG99:SetProperty('G99_KGFRET', MODEL_FIELD_WHEN	   ,bWhen)
        oStrG99:AddTrigger("G99_KGFRET" ,"G99_KGFRET" ,{||.T.} ,bTrig)
    Endif

    If G99->(FieldPos('G99_ALTURA')) > 0
        oStrG99:SetProperty('G99_ALTURA', MODEL_FIELD_WHEN	   ,bWhen)
        oStrG99:AddTrigger("G99_ALTURA" ,"G99_ALTURA" ,{||.T.} ,bTrig)
    Endif

    If G99->(FieldPos('G99_LARGUR')) > 0
        oStrG99:SetProperty('G99_LARGUR', MODEL_FIELD_WHEN	   ,bWhen)
        oStrG99:AddTrigger("G99_LARGUR" ,"G99_LARGUR" ,{||.T.} ,bTrig)
    Endif

    If G99->(FieldPos('G99_COMPRI')) > 0
        oStrG99:SetProperty('G99_COMPRI', MODEL_FIELD_WHEN	   ,bWhen)
        oStrG99:AddTrigger("G99_COMPRI" ,"G99_COMPRI" ,{||.T.} ,bTrig)
    Endif

//Serviços
If ValType(oStrG9Q) == "O"
	oStrG9Q:SetProperty("G9Q_STAENC" , MODEL_FIELD_INIT, bInit)
    oStrG9Q:SetProperty("G9Q_DLOCIN" , MODEL_FIELD_INIT, bInit)
    oStrG9Q:SetProperty("G9Q_DLOCFI" , MODEL_FIELD_INIT, bInit)
    oStrG9Q:SetProperty("G9Q_DAGORI" , MODEL_FIELD_INIT, bInit)
    oStrG9Q:SetProperty("G9Q_DAGDES" , MODEL_FIELD_INIT, bInit)

    oStrG9Q:SetProperty("G9Q_CODLIN" , MODEL_FIELD_VALID, bFldVld)
    oStrG9Q:SetProperty("G9Q_SERVIC" , MODEL_FIELD_VALID, bFldVld)
    oStrG9Q:SetProperty("G9Q_LOCINI" , MODEL_FIELD_VALID, bFldVld)
    oStrG9Q:SetProperty("G9Q_LOCFIM" , MODEL_FIELD_VALID, bFldVld)
    oStrG9Q:SetProperty("G9Q_AGEORI" , MODEL_FIELD_VALID, bFldVld)
    oStrG9Q:SetProperty("G9Q_AGEDES" , MODEL_FIELD_VALID, bFldVld)

    oStrG9Q:SetProperty("G9Q_KILOME"    , MODEL_FIELD_WHEN, bWhen)

    oStrG9Q:AddTrigger("G9Q_CODLIN" ,"G9Q_CODLIN", {||.T.}, bTrig)
    oStrG9Q:AddTrigger("G9Q_SERVIC" ,"G9Q_SERVIC", {||.T.}, bTrig)
    oStrG9Q:AddTrigger("G9Q_LOCINI" ,"G9Q_LOCINI", {||.T.}, bTrig)
    oStrG9Q:AddTrigger("G9Q_LOCFIM" ,"G9Q_LOCFIM", {||.T.}, bTrig)
    oStrG9Q:AddTrigger("G9Q_AGEORI" ,"G9Q_AGEORI", {||.T.}, bTrig)
    oStrG9Q:AddTrigger("G9Q_AGEDES" ,"G9Q_AGEDES", {||.T.}, bTrig)
    oStrG9Q:AddTrigger("G9Q_KILOME" ,"G9Q_KILOME", {||.T.}, bTrig)
	
	oStrG9Q:SetProperty("G9Q_STAENC" , MODEL_FIELD_VALUES, RetCboxFld("G9Q_STAENC"))
Endif

//Estados
If ValType(oStrG9P) == "O"
    oStrG9P:SetProperty("G9P_ESTADO", MODEL_FIELD_VALID, bFldVld)

    aFldG9P := oStrG9P:GetFields()

    For nX := 1 to Len(aFldG9P)

        If (aFldG9P[nX][3] $ cFldG9P) 
            oStrG9P:SetProperty(aFldG9P[nX][3], MODEL_FIELD_OBRIGAT, .F. )
        Endif
      	
    Next 

Endif

//Desclaração
If ValType(oStrG9R) == "O"

    oStrG9R:AddTrigger("G9R_VALOR" ,"G9R_VALOR", {||.T.}, bTrig)
    
    If ( VldDicG9R() )
        oStrG9R:SetProperty("G9R_NFEID" , MODEL_FIELD_VALID, bFldVld)
        oStrG9R:AddTrigger("G9R_NFEID" ,"G9R_NFEID", {||.T.}, bTrig)
    EndIf

EndIf

If ValType(oStrGIR) == "O"
    oStrGIR:SetProperty("GIR_TPCART", 	MODEL_FIELD_WHEN, bWhen)
    oStrGIR:SetProperty("GIR_NUMPAR",	MODEL_FIELD_WHEN, bWhen)
    oStrGIR:SetProperty("GIR_NSU",	 	MODEL_FIELD_WHEN, bWhen)
    oStrGIR:SetProperty("GIR_AUT", 		MODEL_FIELD_WHEN, bWhen)
    oStrGIR:SetProperty("GIR_CODADM", 	MODEL_FIELD_WHEN, bWhen)

    oStrGIR:SetProperty("GIR_TIPPAG",	MODEL_FIELD_VALID, bFldVld)
    
    oStrGIR:AddTrigger("GIR_TIPPAG" ,"GIR_TIPPAG" ,{||.T.}, bTrig)
    oStrGIR:AddTrigger("GIR_TPCART" ,"GIR_TPCART" ,{||.T.}, bTrig)
    
Endif

Return 

//------------------------------------------------------------------------------
/*/{Protheus.doc} FieldWhen
Função responsavel pelo When dos Campos
@type function
@author 
@since 10/06/2019
@version 1.0
@param uVal, character, (Descrição do parâmetro)
@return return, return_description
@example
(examples)
@see (links_or_references)
/*/
//------------------------------------------------------------------------------
Static Function FieldWhen(oMdl,cField,uVal)
Local lRet		:= .T.
Local oModel	:= oMdl:GetModel()
Local cMdlId	:= oMdl:GetID()

Do Case
    Case cMdlId == "MASTERG99"
        If cField == "G99_KMFRET"
            lRet := !(ValTpFrete(oModel))
        Endif
        If cField == "G99_VALOR"
            lRet := !(ValTpFrete(oModel))   
        Endif
        If cField $ "G99_DTPREV|G99_INFMAN|G99_TARCL|G99_TARVAL"
            lRet := oMdl:GetValue('G99_TIPMOD') == '2'
        EndIf
        If G99->(FieldPos('G99_KGFRET')) > 0 .And. cField $ "G99_KGFRET"
            lRet    := (RetTpFrete(oModel)) == '4'
        EndIf
        If G99->(FieldPos('G99_ALTURA')) > 0 .And. cField $ "G99_ALTURA"
            lRet    := (RetTpFrete(oModel)) == '4'
        EndIf
        If G99->(FieldPos('G99_LARGUR')) > 0 .And. cField $ "G99_LARGUR"
            lRet    := (RetTpFrete(oModel)) == '4'
        EndIf
        If G99->(FieldPos('G99_COMPRI')) > 0 .And. cField $ "G99_COMPRI"
            lRet    := (RetTpFrete(oModel)) == '4'
        EndIf
    Case cMdlId == "DETAILG9R"
        If cField == "G9R_VALOR"
            lRet := ValTpFrete(oModel)
        Endif
    Case cMdlId == "DETAILG9Q"
        If cField == "G9Q_KILOME"
            lRet := !(ValTpFrete(oModel))
        Endif
    Case cMdlId == "DETAILGIR"
        If cField $ 'GIR_TPCART|GIR_NUMPAR|GIR_NSU|GIR_AUT|GIR_CODADM'
            lRet := oMdl:GetValue('GIR_TIPPAG') == '2'
        Endif
EndCase

Return lRet

/*/{Protheus.doc} ValTpFrete
(long_description)
@type  Static Function
@author user
@since 11/12/2019
@version 1.0
@param param_name, param_type, param_descr
@return lRet, return_type, return_description
@example
(examples)
@see (links_or_references)
/*/
Static Function ValTpFrete(oModel)
Local lRet     := .F.
Local aArea    := GetArea()
Local oMdlG99  := oModel:GetModel('MASTERG99')
Local cFrete   := oMdlG99:GetValue("G99_TABFRE")

G5J->(DbSetOrder(1))
If G5J->(DbSeek(xFilial("G5J") + cFrete))
    If G5J->G5J_TIPOKM == '3'
        lRet := .T.
    EndIf
EndIf

RestArea(aArea)

Return lRet

/*/{Protheus.doc} RetTpFrete
(long_description)
@type  Static Function
@author user
@since 31/07/2024
@version 1.0
@param param_name, param_type, param_descr
@return lRet, return_type, return_description
@example
(examples)
@see (links_or_references)
/*/
Static Function RetTpFrete(oModel)
    
    Local cRet     := ""
    Local aArea    := GetArea()
    Local oMdlG99  := oModel:GetModel('MASTERG99')
    Local cFrete   := oMdlG99:GetValue("G99_TABFRE")

    G5J->(DbSetOrder(1))
    If G5J->(DbSeek(xFilial("G5J") + cFrete))
        cRet     := G5J->G5J_TIPOKM
    EndIf

    RestArea(aArea)

Return cRet

//------------------------------------------------------------------------------
/* /{Protheus.doc} RetCboxFld

@type Static Function
@author jacomo.fernandes
@since 11/11/2019
@version 1.0
@param cField, character, (Descrição do parâmetro)
@return aRet, return_description
/*/
//------------------------------------------------------------------------------
Static Function RetCboxFld(cField)
Local aRet  := {}
Do Case
    Case cField == "G99_TIPCTE"
        aAdd(aRet,STR0042)//"0=Normal"
        aAdd(aRet,STR0043)//"1=Complemento"
        aAdd(aRet,STR0044)//"2=Anulação"
        aAdd(aRet,STR0045)//"3=Substituição"

    Case cField == "G99_STAENC"
        aAdd(aRet,STR0046)//"1=Aguardando"
        aAdd(aRet,STR0047)//"2=Em Transporte"
        //aAdd(aRet,STR0048)//"3=Em Transbordo"
        aAdd(aRet,STR0049)//"4=Recebido"
        aAdd(aRet,STR0050)//"5=Retirado"
    Case cField == "G99_STATRA"
        aAdd(aRet,STR0051)//"0=CTe Não Transmitido"
        aAdd(aRet,STR0052)//"1=CTe Aguardando"
        aAdd(aRet,STR0053)//"2=CTe Autorizado"
        aAdd(aRet,STR0054)//"3=CTe Nao Autorizado"
        aAdd(aRet,STR0055)//"4=CTe em Contingencia"
        aAdd(aRet,STR0056)//"5=CTe com Falha na Comunicacao"
        aAdd(aRet,STR0057)//"6=Doc. de Saída Excluído"
        aAdd(aRet,STR0058)//"7=Cancelamento Rejeitado"
        aAdd(aRet,STR0059)//"8=Cte Cancelado"
        aAdd(aRet,STR0060)//"9=Documento não preparado para transmissão"
    Case cField == "G99_AVERBA"
        aAdd(aRet,STR0061)//"0=Averbação não transmitida"
        aAdd(aRet,STR0062)//"1=Averbação aguardando retorno"
        aAdd(aRet,STR0063)//"2=Averbação aceita"
        aAdd(aRet,STR0064)//"3=Averbação rejeitada"
        aAdd(aRet,STR0065)//"4=Averbação cancelada"
     Case cField == "G99_TPEMIS
        aAdd(aRet,STR0129)//1=Normal;
        //aAdd(aRet,STR0130)//4=EPEC pela SVC;
        //aAdd(aRet,STR0131)//5=Contingência FSDA;
        aAdd(aRet,STR0132)//7=Autorização pela SVC-RS;  
        aAdd(aRet,STR0133)//8=Autorização pela SVC-SP         
    Case cField == "G9Q_STAENC"
      	aAdd(aRet,STR0046   )//"1=Aguardando"
        aAdd(aRet,STR0047   )//"2=Em Transporte"
        aAdd(aRet,STR0135   )//"3=Recebido"
		aAdd(aRet,STR0136   )//"4=Retirado"
        aAdd(aRet,STR0134   )//"5=Encerrado"
        aAdd(aRet,STR0144   )//"6=Transbordo"
    Case cField == "G99_TARCL"
        aAdd(aRet," "       )//" "
        aAdd(aRet,STR0197   )//"M=Tarifa Mínima"
        aAdd(aRet,STR0198   )//"G=Tarifa Geral"
        aAdd(aRet,STR0199   )//"E=Tarifa Específica"
    Case cField == "G99_TIPMOD"
        aAdd(aRet,STR0200   )//"1=Rodoviário"
        aAdd(aRet,STR0201   )//"2=Aéreo"
    Case cField == "G99_INFMAN"
        aAdd(aRet," "       )//" "
      	aAdd(aRet,STR0181   )//"01=certificado do expedidor para embarque de animal vivo"
        aAdd(aRet,STR0182   )//"02=artigo perigoso conforme Declaração do Expedidor anexa"
        aAdd(aRet,STR0183   )//"03=somente em aeronave cargueira"
		aAdd(aRet,STR0184   )//"04=artigo perigoso - declaração do expedidor não requerida"
        aAdd(aRet,STR0185   )//"05=artigo perigoso em quantidade isenta"
        aAdd(aRet,STR0186   )//"06=gelo seco para refrigeração (especificar no campo observações a quantidade)"
        aAdd(aRet,STR0187   )//"07=não restrito (especificar a Disposição Especial no campo observações)"
        aAdd(aRet,STR0188   )//"08=artigo perigoso em carga consolidada (especificar a quantidade no campo observações)"
        aAdd(aRet,STR0189   )//"09=autorização da autoridade governamental anexa (especificar no campo observações)"
        aAdd(aRet,STR0190   )//"10=baterias de íons de lítio em conformidade com a Seção II da PI965 – CAO"
        aAdd(aRet,STR0191   )//"11=baterias de íons de lítio em conformidade com a Seção II da PI966"
        aAdd(aRet,STR0192   )//"12=baterias de íons de lítio em conformidade com a Seção II da PI967"
        aAdd(aRet,STR0193   )//"13=baterias de metal lítio em conformidade com a Seção II da PI968 — CAO"
        aAdd(aRet,STR0194   )//"14=baterias de metal lítio em conformidade com a Seção II da PI969"
        aAdd(aRet,STR0195   )//"15=baterias de metal lítio em conformidade com a Seção II da PI970"
        aAdd(aRet,STR0196   )//"99=outro (especificar no campo observações)"
    Case cField == "G99_TIPSER"
        aRet := GtpxCbox("G99_TIPSER")
EndCase

Return aRet

//------------------------------------------------------------------------------
/* /{Protheus.doc} FieldInit

@type Function
@author 
@since 27/09/2019
@version 1.0
@param , character, (Descrição do parâmetro)
@return , return_description
@example
(examples)
@see (links_or_references)
/*/
//------------------------------------------------------------------------------
Static Function FieldInit(oMdl,cField)
Local aStruct   := oMdl:GetStruct():GetFields()
Local nPos      := 0
Local uRet      := nil//M->&(cField)
Local oModel	:= oMdl:GetModel()
Local lInsert	:= oModel:GetOperation() == MODEL_OPERATION_INSERT //.Or. oModel:GetOperation() == 4
Local aArea     := GetArea()

If (nPos := aScan(aStruct,{|x| x[3] == cField })) > 0
    uRet    := GTPCastType(,aStruct[nPos][4])
Endif

Do Case 
//G99
    Case cField == "G99_NOMREM"
        uRet := If(!lInsert,Posicione('SA1',1,xFilial('SA1')+G99->G99_CLIREM+G99->G99_LOJREM,'A1_NOME'),'')
        uRet := Left(uRet,TamSX3("G99_NOMREM")[1])
    Case cField == "G99_NOMDES"
        uRet := If(!lInsert,Posicione('SA1',1,xFilial('SA1')+G99->G99_CLIDES+G99->G99_LOJDES,'A1_NOME'),'')
        uRet := Left(uRet,TamSX3("G99_NOMDES")[1])
    Case cField == "G99_DESEMI"
        uRet := If(!lInsert,Posicione('GI6',1,xFilial('GI6')+G99->G99_CODEMI,'GI6_DESCRI'),'')
    Case cField == "G99_DESREC"
        uRet := If(!lInsert,Posicione('GI6',1,xFilial('GI6')+G99->G99_CODREC,'GI6_DESCRI'),'')
    Case cField == "G99_DESPRO"
        uRet := If(!lInsert,Posicione('SB1',1,xFilial('SB1')+G99->G99_CODPRO,'B1_DESC'),'')
    Case cField == "G99_NTBFRE"
        uRet := If(!lInsert,Posicione('G5J',1,xFilial('G5J')+G99->G99_TABFRE,'G5J_DESCRI'),'')
    Case cField == "G99_SERIE"
        uRet := GTPGetRules("SERIECTE",,,"")
    Case cField == "G99_DTEMIS"
        uRet := dDataBase
    Case cField == "G99_HREMIS"
        uRet := Time()
    Case cField == "G99_USUINC"
        uRet := AllTrim(RetCodUsr())
    Case cField == 'G99_TIPCTE'
        uRet := '0' //Normal
    Case cField == "G99_STAENC"
        uRet := '1' //Aguardando
    Case cField == "G99_STATRA"
        uRet := '9' //
    Case cField == "G99_AVERBA"
        uRet := '0' //
    Case cField == "G99_DOCREM"
        uRet := If(!lInsert,Posicione('SA1',1,xFilial('SA1')+G99->G99_CLIREM+G99->G99_LOJREM,'A1_CGC'),'')
    Case cField == "G99_DOCDES"
        uRet := If(!lInsert,Posicione('SA1',1,xFilial('SA1')+G99->G99_CLIDES+G99->G99_LOJDES,'A1_CGC'),'')
    Case cField == "G99_DOCEXP"
        uRet := If(!lInsert,Posicione('SA1',1,xFilial('SA1')+G99->G99_CLIEXP+G99->G99_LOJEXP,'A1_CGC'),'')
   
    Case cField == "G99_TIPMOD"
        uRet := '1'
//G9Q
    Case cField == "G9Q_DLOCIN" 
        uRet := If(!lInsert,Posicione('GI1',1,xFilial('GI1')+G9Q->G9Q_LOCINI,'GI1_DESCRI'),'')
    Case cField == "G9Q_DLOCFI"
        uRet := If(!lInsert,Posicione('GI1',1,xFilial('GI1')+G9Q->G9Q_LOCFIM,'GI1_DESCRI'),'')
    Case cField == "G9Q_DAGORI"
        uRet := If(!lInsert,Posicione('GI6',1,xFilial('GI6')+G9Q->G9Q_AGEORI,'GI6_DESCRI'),'')
    Case cField == "G9Q_DAGDES"
        uRet := If(!lInsert,Posicione('GI6',1,xFilial('GI6')+G9Q->G9Q_AGEDES,'GI6_DESCRI'),'')
	Case cField == "G9Q_STAENC"
        uRet := '1' //Aguardando
    
EndCase 

RestArea(aArea)

Return uRet

//------------------------------------------------------------------------------
/* /{Protheus.doc} FieldValid

@type Static Function
@author 
@since 27/09/2019
@version 1.0
@param , character, (Descrição do parâmetro)
@return , return_description
@example
(examples)
@see (links_or_references)
/*/
//------------------------------------------------------------------------------
Static Function FieldValid(oMdl,cField,uNewValue,uOldValue)

    Local lRet		:= .T.

    Local oModel	:= oMdl:GetModel()

    Local cMdlId	:= oMdl:GetId()
    Local cMsgErro	:= ""
    Local cMsgSol	:= ""
   
    Do Case 
        Case Empty(uNewValue)
            lRet := .T.
    //G99
        Case cField == 'G99_CLIREM' .or. cField == 'G99_LOJREM'
            If !GxVlCliFor('SA1',oMdl:GetValue('G99_CLIREM'),oMdl:GetValue('G99_LOJREM'))
                lRet        := .F.
                cMsgErro	:= STR0066//"Cliente selecionado não encontrado ou se encontra inativo"
                cMsgSol	    := STR0067//"Selecione um cliente valido"
            Endif
            
        Case cField == 'G99_CLIDES' .or. cField == 'G99_LOJDES'
            If !GxVlCliFor('SA1',oMdl:GetValue('G99_CLIDES'),oMdl:GetValue('G99_LOJDES'))
                lRet        := .F.
                cMsgErro	:= STR0066//"Cliente selecionado não encontrado ou se encontra inativo"
                cMsgSol	    := STR0067//"Selecione um cliente valido"
            Endif
        Case cField == 'G99_CLIEXP' .or. cField == 'G99_LOJEXP'
            If !GxVlCliFor('SA1',oMdl:GetValue('G99_CLIEXP'),oMdl:GetValue('G99_LOJEXP'))
                lRet        := .F.
                cMsgErro	:= STR0066//"Cliente selecionado não encontrado ou se encontra inativo"
                cMsgSol	    := STR0067//"Selecione um cliente valido"
            Endif
        Case cField == 'G99_TOMADO'
            If uNewValue == '1' .AND. Empty(oMdl:GetValue('G99_CLIEXP'))
                lRet        := .F.
                cMsgErro	:= STR0212 //"Expedidor não informado"
                cMsgSol	    := STR0213 //"Informe o código e loja do expedidor"
            Endif

        Case cField == 'G99_CODEMI' .or. cField == 'G99_CODREC'
            IF !GTPExistCpo('GI6',uNewValue)
                lRet        := .F.
                cMsgErro	:= STR0068//"Agencia selecionada não encontrada ou se encontra inativa"
                cMsgSol	    := STR0069//"Selecione uma agencia valida"
            ElseIf !GxVldAgEnc(uNewValue)
                lRet        := .F.
                cMsgErro	:= STR0070//"Agencia selecionada não é do tipo de Encomenda"
                cMsgSol	    := STR0069//"Selecione uma agencia valida"
            ElseIf !GxAgMunDif(oMdl:GetValue('G99_CODEMI'),oMdl:GetValue('G99_CODREC'))
                lRet        := .F.
                cMsgErro	:= STR0071//"Agencias selecionadas são do mesmo municipio"
                cMsgSol	    := STR0072//"Selecione uma agencia que seja de outro municipio"
            ElseIf cField == 'G99_CODEMI' .and. !ValidUserAg(oMdl,cField,uNewValue,uOldValue)
                lRet        := .F.
            ElseIf cField == 'G99_CODEMI' .and. !VldFilAge(uNewValue, @cMsgErro, @cMsgSol)     
                lRet        := .F.       
            Endif
        
        Case cField == 'G99_CODPRO'
            IF !GTPExistCpo('SB1',uNewValue)
                lRet        := .F.
                cMsgErro	:= STR0073//"Produto informado não existe ou se encontra inativo"
                cMsgSol	    := STR0074//"Selecione um produto valido"
            ElseIF !GTPExistCpo('G5J',uNewValue,2)
                lRet        := .F.
                cMsgErro	:= STR0075//"Produto informado não vinculado à uma tabela de Frete"
                cMsgSol	    := STR0074//"Selecione um produto valido"
            Endif
            
        Case cField == 'G99_TABFRE'
            IF !GTPExistCpo('G5J',uNewValue)
                lRet        := .F.
                cMsgErro	:= STR0076//"Tabela informada não existe ou se encontra inativa"
                cMsgSol	    := STR0077//"Selecione uma Tabela valida"
            ElseIf Posicione("G5J",1,xFilial('G5J')+uNewValue,'G5J_PRODUT') <> oMdl:GetValue('G99_CODPRO')
                lRet        := .F.
                cMsgErro	:= STR0078//"Tabela informada não corresponde ao produto selecionado"
                cMsgSol	    := STR0077//"Selecione uma Tabela valida"
            Endif
        Case cField == "G99_TS"
            If !GTPExistCpo('SF4',uNewValue)
                lRet        := .F.
                cMsgErro	:= STR0079//"Tipo de Saída informada não existe ou se encontra inativa"
                cMsgSol	    := STR0080//"Selecione um Tipo de Saída valido"
            ElseIf uNewValue <= "500"
                lRet        := .F.
                cMsgErro	:= STR0081//"Foi informado um tipo de Entrada"
                cMsgSol	    := STR0082//"Selecione um tipo de saída (Código maior que 500)"
            Endif
    
        Case cField == "G99_HRPREV"
            IF !GxVldHora(uNewValue,,.F.) 
                lRet        := .F.
                cMsgErro	:= STR0085//"Formato da hora informado invalido"
                cMsgSol	    := STR0086//"Informe uma hora entre 00:00 às 23:59"
            Endif
        Case cField == "G99_SERIE"
            IF !GTPxIsDigit(uNewValue)
                lRet        := .F.
                cMsgErro	:= STR0087//"Serie informada se encontra em formato alfanumérico"
                cMsgSol	    := STR0088//"Para geração do Conhecimento de Transporte, a Série deve estar em formato numérico"
            ElseIf Empty(A460Especie(uNewValue))
                lRet        := .F.
                cMsgErro	:= STR0089//"Série informada não possuí vinculo à especie CTE"
                cMsgSol	    := STR0090//"Verifique a parametrização fiscal da Especie"
            Endif
        Case cField $ "G99_DOCREM|G99_DOCDES"
            If !(VldDocSA1(uNewValue))
                lRet        := .F.
                cMsgErro	:= STR0150 // "Documento não encontrado no cadastro de clientes"
                cMsgSol	    := STR0151 // "Verifique o documento informado"
            Endif

    //G9Q
        Case cField == 'G9Q_CODLIN'
            IF  !GTPExistCpo('GI2',uNewValue+'2',4)
                lRet        := .F.
                cMsgErro	:= STR0091//"Linha selecionada não encontrada ou se encontra inativa"
                cMsgSol	    := STR0092//"Selecione uma Linha valida"
            Endif
        Case cField == 'G9Q_SERVIC'
            IF  !GTPExistCpo('GID',uNewValue+'2',4)
                lRet        := .F.
                cMsgErro	:= STR0093//"Serviço selecionado não encontrado ou se encontra inativo"
                cMsgSol	    := STR0094//"Selecione um Serviço valida"
            ElseIf !VldLocalIni(oMdl, uNewValue)
                lRet        := .F.
                cMsgErro	:= STR0152 // "Localidade da agência emissora não consta no serviço selecionado"
                cMsgSol	    := STR0153 // "Selecione um serviço que possua a localidade da agência emissora"
            Endif
        Case cField == 'G9Q_AGEORI' .or. cField == 'G9Q_AGEDES'
            IF  !GTPExistCpo('GI6',uNewValue)
                lRet        := .F.
                cMsgErro	:= STR0068//"Agencia selecionada não encontrada ou se encontra inativa"
                cMsgSol	    := STR0069//"Selecione uma agencia valida"
            Endif

            If ( lRet .And. !GtpVldAgency(xFilial("GI6"),uNewValue,"CTE") )
                lRet := .f.
                cMsgErro    := GTPRetMsg()[1]
                cMsgSol	    := GTPRetMsg()[2]
            EndIf
            
        Case cField == 'G9Q_LOCINI' .or. cField == 'G9Q_LOCFIM'
            IF !GTPExistCpo('GI1',uNewValue)
                lRet        := .F.
                cMsgErro	:= STR0095//"Localidade selecionada não encontrada ou se encontra inativa"
                cMsgSol	    := STR0096//"Selecione uma Localidade valida"
            ElseIf !GTPExistCpo('G5I',oMdl:GetValue('G9Q_CODLIN')+uNewValue+"2",3)
                lRet        := .F.
                cMsgErro	:= STR0097//"Localidade selecionada não pertence a Linha selecionada"
                cMsgSol	    := STR0096//"Selecione uma Localidade valida"
            ElseIf !VldSeqLoc(oMdl)
                lRet        := .F.
                cMsgErro	:= STR0098//"A Localidade Inicial/Final não está na sequencia correta da linha"
                cMsgSol	    := STR0099//"Verifique a sequencia da linha"
            Endif
        
    //G9P
        Case cField == "G9P_ESTADO"
            IF !GTPExistCpo('SX5','12'+uNewValue)
                lRet        := .F.
                cMsgErro	:= STR0100//"Estado selecionado não encontrado ou se encontra inativo"
                cMsgSol	    := STR0101//"Selecione um Estado valido"
            Endif

            //GIR
        Case cField == "GIR_TIPPAG"
            lRet := VldOpcPag(oModel,@cMsgErro,@cMsgSol)
        Case ( cField == "G9R_NFEID" )            
            lRet := !HasChvNFe(uNewValue,oMdl,@cMsgErro,@cMsgSol)
    EndCase 

    If !lRet .and. !Empty(cMsgErro)
        oModel:SetErrorMessage(cMdlId,cField,cMdlId,cField,"FieldValid",cMsgErro,cMsgSol,uNewValue,uOldValue)
    Endif

Return lRet

//------------------------------------------------------------------------------
/* /{Protheus.doc} FieldTrigger

@type Function
@author 
@since 26/09/2019
@version 1.0
@param , character, (Descrição do parâmetro)
@return , return_description
@example
(examples)
@see (links_or_references)
/*/
//------------------------------------------------------------------------------

Static Function FieldTrigger(oMdl,cField,uVal)

    Local oView		:= FwViewActive()
    Local oModel	:= oMdl:GetModel()
    Local oModelG9R := oModel:GetModel("DETAILG9R")

    Local aArea     := GetArea()
    Local aAreaSB1  := nil
    Local aNota     := {"",""}
    
    Local lRet      := .T.
    Local nX        := 0

    Local cNFeNota  := ""

    Do Case 
    //G99
        Case cField == 'G99_CLIREM'
            oMdl:SetValue("G99_LOJREM", Posicione('SA1',1,xFilial('SA1')+uVal,'A1_LOJA'),.T.,.T.)
        Case cField == 'G99_LOJREM'
            oMdl:SetValue("G99_NOMREM", Left(Posicione('SA1',1,xFilial('SA1')+oMdl:GetValue('G99_CLIREM')+uVal,'A1_NOME'),TamSX3("G99_NOMREM")[1]))
            oMdl:SetValue("G99_DOCREM", Posicione('SA1',1,xFilial('SA1')+oMdl:GetValue('G99_CLIREM')+uVal,'A1_CGC'))
            UpdTpPgto(oMdl)
        Case cField == 'G99_CLIDES'
            oMdl:SetValue("G99_LOJDES", Posicione('SA1',1,xFilial('SA1')+uVal,'A1_LOJA'),.T.,.T.)
        Case cField == 'G99_LOJDES'
            oMdl:SetValue("G99_NOMDES", Left(Posicione('SA1',1,xFilial('SA1')+oMdl:GetValue('G99_CLIDES')+uVal,'A1_NOME'),TamSx3("G99_NOMDES")[1]))
            oMdl:SetValue("G99_DOCDES", Posicione('SA1',1,xFilial('SA1')+oMdl:GetValue('G99_CLIDES')+uVal,'A1_CGC'))
            UpdTpPgto(oMdl)
        Case cField == 'G99_CLIEXP'
            oMdl:SetValue("G99_LOJEXP", Posicione('SA1',1,xFilial('SA1')+uVal,'A1_LOJA'),.T.,.T.)
        Case cField == 'G99_LOJEXP'
            oMdl:SetValue("G99_NOMEXP", Left(Posicione('SA1',1,xFilial('SA1')+oMdl:GetValue('G99_CLIEXP')+uVal,'A1_NOME'),TamSx3("G99_NOMEXP")[1]))
            oMdl:SetValue("G99_DOCEXP", Posicione('SA1',1,xFilial('SA1')+oMdl:GetValue('G99_CLIEXP')+uVal,'A1_CGC'))
            UpdTpPgto(oMdl)

        Case cField == 'G99_CODEMI'

            oMdl:SetValue("G99_DESEMI", Posicione('GI6',1,xFilial('GI6')+uVal,'GI6_DESCRI'))
        
        Case cField == 'G99_CODREC'
            
            oMdl:SetValue("G99_DESREC", Posicione('GI6',1,xFilial('GI6')+uVal,'GI6_DESCRI'))    

        Case cField == 'G99_CODPRO'
            aAreaSB1 := SB1->(GetArea())
            
            SB1->(DbSetOrder(1))
            If !Empty(uVal) .and. SB1->(DbSeek(xFilial('SB1')+uVal))
                oMdl:SetValue("G99_DESPRO"  , SB1->B1_DESC)
            Else
                oMdl:SetValue("G99_DESPRO"  ,"")
            Endif
            RestArea(aAreaSB1)
            If oMdl:GetValue('G99_TOMADO') == "0"
                oMdl:SetValue("G99_TABFRE", GetTabFrete(uVal,oMdl:GetValue('G99_CLIREM'),oMdl:GetValue('G99_LOJREM')) )
                
            else
                oMdl:SetValue("G99_TABFRE", GetTabFrete(uVal,oMdl:GetValue('G99_CLIDES'),oMdl:GetValue('G99_LOJDES')) )
            Endif

        Case cField == 'G99_TABFRE'
            If EMPTY(GTPValG5J())  
                lRet        := .F.
                cMsgErro	:= STR0146//"Tabela de frete não associada a cliente"
                cMsgSol	    := STR0147//"Selecione outra tabela"
            EndIf
            
            oMdl:SetValue("G99_NTBFRE" , Posicione('G5J',1,xFilial('G5J')+uVal,'G5J_DESCRI'))
            oMdl:LoadValue("G99_VALOR" , 0)
            oMdl:LoadValue("G99_KMFRET", 0)
            If G99->(FieldPos('G99_KGFRET')) > 0
                oMdl:LoadValue("G99_KGFRET", 0)
            Endif
            If G99->(FieldPos('G99_VLRFRT')) > 0
                oMdl:LoadValue("G99_VLRFRT", 0)
            Endif
            If G99->(FieldPos('G99_ALTURA')) > 0
                oMdl:LoadValue("G99_ALTURA", 0)
            Endif
            If G99->(FieldPos('G99_LARGUR')) > 0
                oMdl:LoadValue("G99_LARGUR", 0)
            Endif
            If G99->(FieldPos('G99_COMPRI')) > 0
                oMdl:LoadValue("G99_COMPRI", 0)
            Endif
            If G99->(FieldPos('G99_VLRPLN')) > 0
                oMdl:LoadValue("G99_VLRPLN", 0)
                lPlaCust := !Empty(GetAdvFval('G5J','G5J_GIMCOD',xFilial('G5J')+uVal,1))
            Endif            
            If !(ValTpFrete(oModel))
                For nX := 1 To oModelG9R:length()
                    oModelG9R:GoLine(nX)
                    oModelG9R:LoadValue("G9R_VALOR" ,0)
                    oModelG9R:LoadValue("G9R_VLFRET",0)
                Next
                If !IsBlind()
                    oView:Refresh()
                EndIf
            EndIf

        Case cField == "G99_KMFRET"
            If G99->(FieldPos('G99_KGFRET')) > 0
                oMdl:SetValue("G99_VALOR",RetTabFrt(oMdl:GetValue('G99_TABFRE'), oMdl:GetValue('G99_KMFRET'), oMdl:GetValue('G99_KGFRET'), (RetTpFrete(oModel)) ))
                If G99->(FieldPos('G99_VLRFRT')) > 0
                    oMdl:SetValue("G99_VLRFRT",RetTabFrt(oMdl:GetValue('G99_TABFRE'), oMdl:GetValue('G99_KMFRET'), oMdl:GetValue('G99_KGFRET'), (RetTpFrete(oModel)) ))
                Endif
            Else
                oMdl:SetValue("G99_VALOR",RetTabFrt(oMdl:GetValue('G99_TABFRE'), oMdl:GetValue('G99_KMFRET'), 0,  (RetTpFrete(oModel)) ))           
                If G99->(FieldPos('G99_VLRFRT')) > 0
                    oMdl:SetValue("G99_VLRFRT",RetTabFrt(oMdl:GetValue('G99_TABFRE'), oMdl:GetValue('G99_KMFRET'), 0,  (RetTpFrete(oModel)) ))
                Endif
            Endif

        Case  G99->(FieldPos('G99_KGFRET')) > 0 .And. cField == "G99_KGFRET"
            oMdl:SetValue("G99_VALOR",RetTabFrt(oMdl:GetValue('G99_TABFRE'), oMdl:GetValue('G99_KMFRET'), oMdl:GetValue('G99_KGFRET'), (RetTpFrete(oModel)) ))
            If G99->(FieldPos('G99_VLRFRT')) > 0
                oMdl:SetValue("G99_VLRFRT",RetTabFrt(oMdl:GetValue('G99_TABFRE'), oMdl:GetValue('G99_KMFRET'), oMdl:GetValue('G99_KGFRET'), (RetTpFrete(oModel)) ))
            Endif

        Case cField == "G99_TOMADO"
            UpdPagto(oModel)
            UpdTpPgto(oMdl)
        Case cField == "G99_VALOR"
            UpdTpPgto(oMdl)
        Case cField == "G99_DOCREM"
            oMdl:LoadValue("G99_CLIREM", Posicione('SA1',3,xFilial('SA1')+uVal,'A1_COD'))
            oMdl:LoadValue("G99_LOJREM", Posicione('SA1',3,xFilial('SA1')+uVal,'A1_LOJA'))
            oMdl:LoadValue("G99_NOMREM", Left(Posicione('SA1',3,xFilial('SA1')+uVal,'A1_NOME'),TamSX3("G99_NOMREM")[1]))
        Case cField == "G99_DOCDES"
            oMdl:LoadValue("G99_CLIDES", Posicione('SA1',3,xFilial('SA1')+uVal,'A1_COD'))
            oMdl:LoadValue("G99_LOJDES", Posicione('SA1',3,xFilial('SA1')+uVal,'A1_LOJA'))
            oMdl:LoadValue("G99_NOMDES", Left(Posicione('SA1',3,xFilial('SA1')+uVal,'A1_NOME'),TamSX3("G99_NOMDES")[1]))
         Case cField == "G99_DOCEXP"
            oMdl:LoadValue("G99_CLIEXP", Posicione('SA1',3,xFilial('SA1')+uVal,'A1_COD'))
            oMdl:LoadValue("G99_LOJEXP", Posicione('SA1',3,xFilial('SA1')+uVal,'A1_LOJA'))
            oMdl:LoadValue("G99_NOMEXP", Left(Posicione('SA1',3,xFilial('SA1')+uVal,'A1_NOME'),TamSX3("G99_NOMEXP")[1]))
        Case cField == 'G9Q_CODLIN'
            oMdl:LoadValue("G9Q_SERVIC","",.T.,.T.)
        Case cField == 'G9Q_SERVIC'
            oMdl:SetValue("G9Q_LOCINI","")
            oMdl:SetValue("G9Q_LOCFIM","")
            SetLocal(oMdl)
        Case cField == 'G9Q_LOCINI'
            oMdl:SetValue("G9Q_DLOCIN", Posicione('GI1',1,xFilial('GI1')+uVal,'GI1_DESCRI'))
            oMdl:SetValue("G9Q_AGEORI", GetAgOriDes(oMdl,"INICIO"))    //oMdl:SetValue("G9Q_AGEORI", Posicione('GI6',3,xFilial('GI6')+uVal,'GI6_CODIGO'))
            oMdl:SetValue("G9Q_LOCFIM","")
            
        Case cField == 'G9Q_LOCFIM'
            oMdl:SetValue("G9Q_DLOCFI", Posicione('GI1',1,xFilial('GI1')+uVal,'GI1_DESCRI'))
            oMdl:SetValue("G9Q_AGEDES", GetAgOriDes(oMdl,"FIM"))    //oMdl:SetValue("G9Q_AGEDES", Posicione('GI6',3,xFilial('GI6')+uVal,'GI6_CODIGO'))
            oMdl:SetValue("G9Q_KILOME", Posicione('GI4',/*nOrd*/,xFilial('GI4')+oMdl:GetValue('G9Q_CODLIN')+oMdl:GetValue('G9Q_LOCINI')+uVal+'2','GI4_KM','GI4LOCHIST' ))
            SetEstadosG9P(oMdl:GetModel())
        Case cField == 'G9Q_KILOME'
            GetTotKm(oMdl:GetModel())
        Case cField == 'G9Q_AGEORI'
            oMdl:SetValue("G9Q_DAGORI", Posicione('GI6',1,xFilial('GI6')+uVal,'GI6_DESCRI'))

        Case cField == 'G9Q_AGEDES'
            oMdl:SetValue("G9Q_DAGDES", Posicione('GI6',1,xFilial('GI6')+uVal,'GI6_DESCRI'))
        
        Case cField == 'GIR_TIPPAG' 
        
            If  uVal != '2'
                oMdl:ClearField("GIR_TPCART")
                oMdl:ClearField("GIR_NSU")
                oMdl:ClearField("GIR_AUT")
                oMdl:ClearField("GIR_NUMPAR")
                oMdl:ClearField("GIR_CODADM")
    
            Endif

            oMdl:SetValue('GIR_TOMADO', oModel:GetModel('MASTERG99'):GetValue('G99_TOMADO'))
            oMdl:SetValue('GIR_CODIGO', oModel:GetModel('MASTERG99'):GetValue('G99_CODIGO'))
            oMdl:SetValue('GIR_DTPAG',	oModel:GetModel('MASTERG99'):GetValue('G99_DTEMIS'))
            
            If oMdl:Length() > 1
                oMdl:SetValue('GIR_VALOR',	valLinPgto(oModel))
            Else
                oMdl:SetValue('GIR_VALOR',	oModel:GetModel('MASTERG99'):GetValue('G99_VALOR'))
            EndIf

            If oModel:GetModel('MASTERG99'):GetValue('G99_TOMADO') == '0'
                oMdl:SetValue('GIR_CLIPAG',	oModel:GetModel('MASTERG99'):GetValue('G99_CLIREM'))
                oMdl:SetValue('GIR_LOJPAG',	oModel:GetModel('MASTERG99'):GetValue('G99_LOJREM'))
            ElseIf oModel:GetModel('MASTERG99'):GetValue('G99_TOMADO') == '1'
                oMdl:SetValue('GIR_CLIPAG',	oModel:GetModel('MASTERG99'):GetValue('G99_CLIEXP'))
                oMdl:SetValue('GIR_LOJPAG',	oModel:GetModel('MASTERG99'):GetValue('G99_LOJEXP'))
            Else
                oMdl:SetValue('GIR_CLIPAG',	oModel:GetModel('MASTERG99'):GetValue('G99_CLIDES'))
                oMdl:SetValue('GIR_LOJPAG',	oModel:GetModel('MASTERG99'):GetValue('G99_LOJDES'))
            Endif
            
            
        Case cField == 'GIR_TPCART'
            oMdl:SetValue('GIR_NUMPAR',	1)
        Case ( cField == "G9R_NFEID" )
            
            cNFeNota  := oMdl:GetValue("G9R_NFEID")
            
            If ( !Empty(cNFeNota) .And. Len(cNFeNota) == 44 )
                aNota := GetDocSerie(cNFeNota)
                
                oMdl:LoadValue("G9R_NOTA",aNota[1]) 
                oMdl:LoadValue("G9R_SERNOT",aNota[2])
                
			EndIf

        Case ( cField == "G99_TIPMOD" )

            If oModel:GetModel('MASTERG99'):GetValue('G99_TIPMOD') == '1'    
                oMdl:LoadValue("G99_DTPREV", "")      
                oMdl:LoadValue("G99_INFMAN", "")
                oMdl:LoadValue("G99_TARCL" , "")
                oMdl:LoadValue("G99_TARVAL", 0 )
            EndIf

    EndCase 

    If !lRet .and. !Empty(cMsgErro)
        Help(,,"FieldTrigger",, cMsgErro, 1,0,,,,,,{cMsgSol})
    Endif

    RestArea(aArea)

    GtpDestroy(aArea)
    GtpDestroy(aAreaSb1)

Return uVal

/*/{Protheus.doc} UpdTpPgto()
    Valida se existe parâmetro de cliente e retorna o tipo de pagamento
    @type  Static Function
    @author user
    @since 25/07/2022
    @version version
    @param param_name, param_type, param_descr
    @return return_var, return_type, return_description
    @example
    (examples)
    @see (links_or_references)
/*/
Static Function UpdTpPgto(oMdl)

Local cClient   := ""
Local cTpPagto  := ""
Local oView		:= FwViewActive()
If GIL->(FieldPos("GIL_RETIRA")) > 0 .AND. GIL->(FieldPos("GIL_FATURA")) > 0 .AND. GIL->(FieldPos("GIL_CARTAO")) > 0 .AND. GIL->(FieldPos("GIL_DINHEI")) > 0 .AND. GIL->(FieldPos("GIL_PIX")) > 0
    If oMdl:GetValue('G99_TOMADO') == '0'
        cClient := oMdl:GetValue('G99_CLIREM')+oMdl:GetValue('G99_LOJREM')
    ElseIf oMdl:GetValue('G99_TOMADO') == '1'
        cClient := oMdl:GetValue('G99_CLIEXP')+oMdl:GetValue('G99_LOJEXP')
    Else
        cClient := oMdl:GetValue('G99_CLIDES')+oMdl:GetValue('G99_LOJDES')
    EndIf
    GIL->(DbSetorder(1))
    If GIL->(DbSEEK(xfilial("GIL") + cClient))

            If GIL->GIL_DINHEI .And. Empty(cTpPagto)
                cTpPagto := "1"  
            Endif

            If GIL->GIL_CARTAO .And. Empty(cTpPagto)
                cTpPagto := "2"
            Endif

            If GIL->GIL_FATURA .And. Empty(cTpPagto)
                cTpPagto := "3"
            Endif

            If GIL->GIL_RETIRA .And. Empty(cTpPagto)
                cTpPagto := "4"
            Endif

            If GIL->GIL_PIX .And. Empty(cTpPagto)
                cTpPagto := "5"
            Endif

        oMdl:GetModel():GetModel("DETAILGIR"):SetValue("GIR_TIPPAG",cTpPagto)
        If !(IsBlind())
            oView:Refresh()
        EndIf
    EndIf
EndIf
Return
/*/{Protheus.doc} GetAgOriDes(oMdl,"INICIO")
    (long_description)
    @type  Static Function
    @author user
    @since 19/05/2022
    @version version
    @param param_name, param_type, param_descr
    @return return_var, return_type, return_description
    @example
    (examples)
    @see (links_or_references)
/*/
Static Function GetAgOriDes(oSubMdl,cPoint)
    Local oModel    := oSubMdl:GetModel()
    Local aSeek     := {}
    Local aResult   := {{"GI6_CODIGO"}}

    Local nP        := 0

    Local cAgencia  := ""
     
    Local xRetValue
    
    If ( oModel:GetModel("MASTERG99"):GetValue("G99_TOMADO") == "0" )    

        cAgencia := Iif(cPoint == "INICIO",;
            oModel:GetModel("MASTERG99"):GetValue("G99_CODEMI"),;
            oModel:GetModel("MASTERG99"):GetValue("G99_CODREC"))
    
    Else

        cAgencia := Iif(cPoint == "INICIO",;
            oModel:GetModel("MASTERG99"):GetValue("G99_CODREC"),;
            oModel:GetModel("MASTERG99"):GetValue("G99_CODEMI"))
    
    EndIf

    If ( cPoint == "INICIO" )
        aAdd(aSeek,{"GI6_FILIAL", xFilial("GI6") })
        aAdd(aSeek,{"GI6_LOCALI", oSubMdl:GetValue('G9Q_LOCINI') })
        aAdd(aSeek,{"GI6_ENCEXP", '1' })
    Else
        aAdd(aSeek,{"GI6_FILIAL", xFilial("GI6") })
        aAdd(aSeek,{"GI6_LOCALI", oSubMdl:GetValue('G9Q_LOCFIM') })
        aAdd(aSeek,{"GI6_ENCEXP", '1' })
    EndIf

    GTPSeekTable("GI6",aSeek,aResult)

    If ( Len(aResult) > 1 )
        
        nP := AScan(aResult, {|x| x[1] == cAgencia })        
        nP := IIf(nP == 0, 2, nP)

        xRetValue := aResult[nP][1]

    Else
        xRetValue := cAgencia        
    EndIf    

Return(xRetValue)

/*/{Protheus.doc} CalcFrete
(long_description)
@type  Static Function
@author henrique madureira
@since 07/12/2019
@version 1.0
@param param_name, param_type, param_descr
@return nVal, Valor, return_description
@example
(examples)
@see (links_or_references)
/*/
Static Function CalcFrete(oModel, nValor)

Local aArea    := GetArea()
Local oMdlG99  := oModel:GetModel('MASTERG99')
Local nVal     := 0
Local nPercent := 0
Local cFrete   := oMdlG99:GetValue("G99_TABFRE")
Local nValTot   := oMdlG99:GetValue("G99_VALOR")

G5J->(DbSetOrder(1))
If G5J->(DbSeek(xFilial("G5J") + cFrete))
    nPercent := G5J->G5J_PECDCL
    If G5J->G5J_TIPOKM == '3'
        nVal := (nValor * (nPercent/100))
    EndIf
EndIf

oMdlG99:LoadValue("G99_VALOR",nValTot+nVal)

RestArea(aArea)
Return nVal

/*/
 * {Protheus.doc} SetViewStruct()
 * Estrutura da View
 * type    Static Function
 * author  Eduardo Ferreira
 * since   16/08/2019
 * version 12.25
 * param   oStrG99, oStrG9R, oStrG9Q, oStrG9P
 * return  Não há
/*/
Static Function SetViewStruct(oStG99E,oStG99C,oStrG9R,oStrG9Q,oStrG9P,oStrGIR)
Local aFields 	:= aClone(oStG99E:GetFields())
Local cFldEnc 	:= ""
Local cFldCon 	:= ""
Local nX        := 0
Local aFldG9P 	:= {}
Local cFldG9P 	:= "G9P_CODG6X|G9P_SERIE|G9P_NUMDOC|G9P_VALOR|"
Local bPvar		:= {|oMdl,cField,uVal| SetViewPVar(oMdl,cField,uVal)}
Local lNewFld   := G99->(FieldPos("G99_CLIEXP")) > 0

cFldEnc := "G99_CODIGO|G99_DTEMIS|G99_HREMIS|G99_CLIREM|G99_LOJREM|G99_NOMREM|G99_CLIDES|"
cFldEnc += "G99_LOJDES|G99_NOMDES|G99_CODEMI|G99_DESEMI|G99_CODREC|G99_DESREC|G99_TOMADO|"

cFldEnc += "G99_CODPRO|G99_DESPRO|G99_TABFRE|G99_NTBFRE|G99_QTDVO|G99_KMFRET|"

If lNewFld
    cFldEnc += "G99_CLIEXP|G99_LOJEXP|G99_NOMEXP|"
Endif

If G99->(FieldPos('G99_KGFRET')) > 0
    cFldEnc += "G99_KGFRET|"
Endif

If G99->(FieldPos('G99_ALTURA')) > 0
    cFldEnc += "G99_ALTURA|"
Endif

If G99->(FieldPos('G99_LARGUR')) > 0
    cFldEnc += "G99_LARGUR|"
Endif

If G99->(FieldPos('G99_COMPRI')) > 0
    cFldEnc += "G99_COMPRI|"
Endif

If G99->(FieldPos('G99_VLRFRT')) > 0
    cFldEnc += "G99_VLRFRT|"
Endif

If G99->(FieldPos('G99_VLRPLN')) > 0
    cFldEnc += "G99_VLRPLN|"
Endif

cFldEnc += "G99_VALOR|"

If  G99->(ColumnPos("G99_TIPMOD")) > 0
    cFldEnc += "G99_DTPREV|G99_TIPMOD|G99_INFMAN|G99_TARCL|G99_TARVAL|"
EndIf
cFldEnc += "G99_STAENC|G99_STATRA|G99_AVERBA|G99_SERIE|"

cFldCon := "G99_TIPCTE|G99_CHVCTE|G99_CHVANU|G99_CHVSUB|G99_PROTOC|G99_PROTCA|G99_OBSERV|G99_XMLENV|G99_XMLRET|G99_MOTREJ|G99_TPEMIS|G99_TIPSER|"

For nX := 1 to Len(aFields)
    If !(AllTrim(aFields[nX][1])+"|" $ cFldEnc)
        oStG99E:RemoveField(aFields[nX][1])   	
    Endif

    If !(AllTrim(aFields[nX][1])+"|" $ cFldCon) 
        oStG99C:RemoveField(aFields[nX][1])   	
    Endif

Next

aFldG9P := oStrG9P:GetFields()

For nX := 1 to Len(aFldG9P)

    If (aFldG9P[nX][3] $ cFldG9P) 
        oStrG9P:RemoveField(aFldG9P[nX][3])	
    Endif
     	
Next 

oStG99C:AddGroup( "GRUPO_DOCUMENTO"       , ""      , ""                 , 1 )
oStG99C:AddGroup( "GRUPO_CHAVE"           , ""      , ""                 , 1 )
oStG99C:AddGroup( "GRUPO_PROTOCOLOS"      , ""      , ""                 , 1 )
oStG99C:AddGroup( "GRUPO_OBS"             , ""      , ""                 , 1 )
oStG99C:AddGroup( "GRUPO_XML"             , ""      , ""                 , 1 )
oStG99C:AddGroup( "GRUPO_XMLRET"          , ""      , ""                 , 1 )
oStG99C:AddGroup( "GRUPO_MOTIVO"          , ""      , ""                 , 1 )

oStG99E:AddField("G99_DOCREM", "00", STR0148, STR0148,{""},"GET","",NIL,"",.T.,NIL,NIL,{},NIL,NIL,.F.) // "Docto. Remetente"
oStG99E:AddField("G99_DOCDES", "01", STR0149, STR0149,{""},"GET","",NIL,"",.T.,NIL,NIL,{},NIL,NIL,.F.) // "Docto. Destinatário"
If lNewFld
    oStG99E:AddField("G99_DOCEXP", "03", "Docto. Expedidor", "Docto. Expedidor",{""},"GET","",NIL,"",.T.,NIL,NIL,{},NIL,NIL,.F.) // "Docto. Expedidor"
Endif
oStG99E:AddGroup("GRUPO_REGISTRO"         , ""      , "FOLDER_ENCOMENDA" , 2 )
oStG99E:AddGroup("GRUPO_REMETENTE"        , ""      , "FOLDER_ENCOMENDA" , 2 )
oStG99E:AddGroup("GRUPO_DESTINATARIO"     , ""      , "FOLDER_ENCOMENDA" , 2 )
If lNewFld
    oStG99E:AddGroup("GRUPO_EXPEDIDOR"     , ""      , "FOLDER_ENCOMENDA" , 2 )
Endif
oStG99E:AddGroup("GRUPO_EMITENTE"         , ""      , "FOLDER_ENCOMENDA" , 2 )
oStG99E:AddGroup("GRUPO_RECEBEDOR"        , ""      , "FOLDER_ENCOMENDA" , 2 )
oStG99E:AddGroup("GRUPO_TOMADOR"          , ""      , "FOLDER_ENCOMENDA" , 2 )
oStG99E:AddGroup("GRUPO_PRODUTO"          , STR0102 , "FOLDER_ENCOMENDA" , 2 )//"Dados do Produto"
oStG99E:AddGroup("GRUPO_TABELA_FRETE"     , ""      , "FOLDER_ENCOMENDA" , 2 )
oStG99E:AddGroup("GRUPO_VALOR_SERVICO"    , ""      , "FOLDER_ENCOMENDA" , 2 )
If  G99->(ColumnPos("G99_TIPMOD")) > 0
    oStG99E:AddGroup("GRUPO_AEREO"            , STR0180 , "FOLDER_ENCOMENDA" , 2 )//"Dados do Aéreo"
EndIf
oStG99E:AddGroup("GRUPO_STATUS"           , STR0105 , "FOLDER_ENCOMENDA" , 2 )//"Status"

oStG99C:SetProperty("G99_TIPCTE" , MVC_VIEW_GROUP_NUMBER, "GRUPO_DOCUMENTO" )
oStG99C:SetProperty("G99_CHVCTE" , MVC_VIEW_GROUP_NUMBER, "GRUPO_DOCUMENTO" )
oStG99C:SetProperty("G99_TIPSER" , MVC_VIEW_GROUP_NUMBER, "GRUPO_DOCUMENTO" )
oStG99C:SetProperty("G99_CHVANU" , MVC_VIEW_GROUP_NUMBER, "GRUPO_CHAVE" )
oStG99C:SetProperty("G99_CHVSUB" , MVC_VIEW_GROUP_NUMBER, "GRUPO_CHAVE" )
oStG99C:SetProperty("G99_PROTOC" , MVC_VIEW_GROUP_NUMBER, "GRUPO_PROTOCOLOS" )
oStG99C:SetProperty("G99_PROTCA" , MVC_VIEW_GROUP_NUMBER, "GRUPO_PROTOCOLOS" )
oStG99C:SetProperty("G99_OBSERV" , MVC_VIEW_GROUP_NUMBER, "GRUPO_OBS" )
oStG99C:SetProperty("G99_XMLENV" , MVC_VIEW_GROUP_NUMBER, "GRUPO_XML" )
oStG99C:SetProperty("G99_XMLRET" , MVC_VIEW_GROUP_NUMBER, "GRUPO_XMLRET" )
oStG99C:SetProperty("G99_MOTREJ" , MVC_VIEW_GROUP_NUMBER, "GRUPO_MOTIVO" )
oStG99E:SetProperty("G99_CODIGO" , MVC_VIEW_GROUP_NUMBER, "GRUPO_REGISTRO")
oStG99E:SetProperty("G99_DTEMIS" , MVC_VIEW_GROUP_NUMBER, "GRUPO_REGISTRO")
oStG99E:SetProperty("G99_HREMIS" , MVC_VIEW_GROUP_NUMBER, "GRUPO_REGISTRO")
If  G99->(ColumnPos("G99_TIPMOD")) > 0 
    oStG99E:SetProperty("G99_TIPMOD" , MVC_VIEW_GROUP_NUMBER, "GRUPO_REGISTRO")
EndIf
oStG99E:SetProperty("G99_DOCREM" , MVC_VIEW_GROUP_NUMBER, "GRUPO_REMETENTE")
oStG99E:SetProperty("G99_CLIREM" , MVC_VIEW_GROUP_NUMBER, "GRUPO_REMETENTE")
oStG99E:SetProperty("G99_LOJREM" , MVC_VIEW_GROUP_NUMBER, "GRUPO_REMETENTE")
oStG99E:SetProperty("G99_NOMREM" , MVC_VIEW_GROUP_NUMBER, "GRUPO_REMETENTE")
oStG99E:SetProperty("G99_DOCDES" , MVC_VIEW_GROUP_NUMBER, "GRUPO_DESTINATARIO")
oStG99E:SetProperty("G99_CLIDES" , MVC_VIEW_GROUP_NUMBER, "GRUPO_DESTINATARIO")
oStG99E:SetProperty("G99_LOJDES" , MVC_VIEW_GROUP_NUMBER, "GRUPO_DESTINATARIO")
oStG99E:SetProperty("G99_NOMDES" , MVC_VIEW_GROUP_NUMBER, "GRUPO_DESTINATARIO")
If lNewFld
    oStG99E:SetProperty("G99_DOCEXP" , MVC_VIEW_GROUP_NUMBER, "GRUPO_EXPEDIDOR")
    oStG99E:SetProperty("G99_CLIEXP" , MVC_VIEW_GROUP_NUMBER, "GRUPO_EXPEDIDOR")
    oStG99E:SetProperty("G99_LOJEXP" , MVC_VIEW_GROUP_NUMBER, "GRUPO_EXPEDIDOR")
    oStG99E:SetProperty("G99_NOMEXP" , MVC_VIEW_GROUP_NUMBER, "GRUPO_EXPEDIDOR")    
    oStG99E:SetProperty("G99_DOCEXP" , MVC_VIEW_PVAR,bPvar)
Endif
oStG99E:SetProperty("G99_CODEMI" , MVC_VIEW_GROUP_NUMBER, "GRUPO_EMITENTE")
oStG99E:SetProperty("G99_DESEMI" , MVC_VIEW_GROUP_NUMBER, "GRUPO_EMITENTE")
oStG99E:SetProperty("G99_CODREC" , MVC_VIEW_GROUP_NUMBER, "GRUPO_RECEBEDOR")
oStG99E:SetProperty("G99_DESREC" , MVC_VIEW_GROUP_NUMBER, "GRUPO_RECEBEDOR")
oStG99E:SetProperty("G99_TOMADO" , MVC_VIEW_GROUP_NUMBER, "GRUPO_TOMADOR")
oStG99E:SetProperty("G99_CODPRO" , MVC_VIEW_GROUP_NUMBER, "GRUPO_PRODUTO")
oStG99E:SetProperty("G99_DESPRO" , MVC_VIEW_GROUP_NUMBER, "GRUPO_PRODUTO")
oStG99E:SetProperty("G99_TABFRE" , MVC_VIEW_GROUP_NUMBER, "GRUPO_TABELA_FRETE")
oStG99E:SetProperty("G99_NTBFRE" , MVC_VIEW_GROUP_NUMBER, "GRUPO_TABELA_FRETE")
oStG99E:SetProperty("G99_SERIE"  , MVC_VIEW_GROUP_NUMBER, "GRUPO_TABELA_FRETE")
oStG99E:SetProperty("G99_QTDVO"  , MVC_VIEW_GROUP_NUMBER, "GRUPO_VALOR_SERVICO")
oStG99E:SetProperty("G99_KMFRET" , MVC_VIEW_GROUP_NUMBER, "GRUPO_VALOR_SERVICO")
If G99->(FieldPos('G99_KGFRET')) > 0
    oStG99E:SetProperty("G99_KGFRET" , MVC_VIEW_GROUP_NUMBER, "GRUPO_VALOR_SERVICO")
Endif
If G99->(FieldPos('G99_VLRFRT')) > 0
    oStG99E:SetProperty("G99_VLRFRT" , MVC_VIEW_GROUP_NUMBER, "GRUPO_VALOR_SERVICO")
Endif
If G99->(FieldPos('G99_ALTURA')) > 0
    oStG99E:SetProperty("G99_ALTURA" , MVC_VIEW_GROUP_NUMBER, "GRUPO_VALOR_SERVICO")
Endif
If G99->(FieldPos('G99_LARGUR')) > 0
    oStG99E:SetProperty("G99_LARGUR" , MVC_VIEW_GROUP_NUMBER, "GRUPO_VALOR_SERVICO")
Endif
If G99->(FieldPos('G99_COMPRI')) > 0
    oStG99E:SetProperty("G99_COMPRI" , MVC_VIEW_GROUP_NUMBER, "GRUPO_VALOR_SERVICO")
Endif
oStG99E:SetProperty("G99_VALOR"  , MVC_VIEW_GROUP_NUMBER, "GRUPO_VALOR_SERVICO")
If G99->(FieldPos('G99_VLRPLN')) > 0
    oStG99E:SetProperty("G99_VLRPLN"  , MVC_VIEW_GROUP_NUMBER, "GRUPO_VALOR_SERVICO")
    oStG99E:SetProperty("G99_VLRPLN"  , MVC_VIEW_ORDEM, "74")
Endif
If  G99->(ColumnPos("G99_TIPMOD")) > 0    
    oStG99E:SetProperty("G99_DTPREV" , MVC_VIEW_GROUP_NUMBER, "GRUPO_AEREO")
    oStG99E:SetProperty("G99_INFMAN" , MVC_VIEW_GROUP_NUMBER, "GRUPO_AEREO")
    oStG99E:SetProperty("G99_TARCL"  , MVC_VIEW_GROUP_NUMBER, "GRUPO_AEREO")
    oStG99E:SetProperty("G99_TARVAL" , MVC_VIEW_GROUP_NUMBER, "GRUPO_AEREO")
EndIf
oStG99E:SetProperty("G99_STAENC" , MVC_VIEW_GROUP_NUMBER, "GRUPO_STATUS")
oStG99E:SetProperty("G99_STATRA" , MVC_VIEW_GROUP_NUMBER, "GRUPO_STATUS")
oStG99E:SetProperty("G99_AVERBA" , MVC_VIEW_GROUP_NUMBER, "GRUPO_STATUS")
oStG99E:SetProperty("G99_DOCREM" , MVC_VIEW_PVAR,bPvar)
oStG99E:SetProperty("G99_DOCDES" , MVC_VIEW_PVAR,bPvar)

oStG99E:SetProperty("G99_STAENC" , MVC_VIEW_COMBOBOX, RetCboxFld("G99_STAENC"))
oStG99E:SetProperty("G99_STATRA" , MVC_VIEW_COMBOBOX, RetCboxFld("G99_STATRA"))
oStG99E:SetProperty("G99_AVERBA" , MVC_VIEW_COMBOBOX, RetCboxFld("G99_AVERBA"))
// Aba Dados do Aereo 
If  G99->(ColumnPos("G99_TIPMOD")) > 0   
    oStG99E:SetProperty("G99_TIPMOD" , MVC_VIEW_COMBOBOX, RetCboxFld("G99_TIPMOD"))
    oStG99E:SetProperty("G99_INFMAN" , MVC_VIEW_COMBOBOX, RetCboxFld("G99_INFMAN"))
    oStG99E:SetProperty("G99_TARCL"  , MVC_VIEW_COMBOBOX, RetCboxFld("G99_TARCL" ))
EndIf

oStG99C:SetProperty("G99_TIPCTE" , MVC_VIEW_COMBOBOX, RetCboxFld("G99_TIPCTE"))
oStG99C:SetProperty("G99_TPEMIS" , MVC_VIEW_GROUP_NUMBER, "GRUPO_DOCUMENTO" )
oStG99C:SetProperty('G99_TPEMIS' , MVC_VIEW_CANCHANGE , .T. )
oStG99C:SetProperty('G99_TIPSER' , MVC_VIEW_CANCHANGE , .T. )
oStG99C:SetProperty("G99_TIPSER" , MVC_VIEW_COMBOBOX, RetCboxFld("G99_TIPSER"))
oStG99C:SetProperty("G99_TPEMIS" , MVC_VIEW_COMBOBOX, RetCboxFld("G99_TPEMIS"))

If G99->(FieldPos('G99_KGFRET')) > 0
    oStG99E:SetProperty("G99_KGFRET" , MVC_VIEW_ORDEM, "28")
Endif
If G99->(FieldPos('G99_VLRFRT')) > 0
    oStG99E:SetProperty("G99_VLRFRT" , MVC_VIEW_ORDEM, "29")
Endif
oStG99E:SetProperty("G99_VALOR"  , MVC_VIEW_ORDEM, "30")

oStG99C:SetProperty("G99_PROTOC" , MVC_VIEW_ORDEM, '37')
oStG99C:SetProperty("G99_PROTCA" , MVC_VIEW_ORDEM, '38')

//Aba Declarações
oStrG9R:SetProperty("G9R_VLFRET", MVC_VIEW_CANCHANGE , .F.)
oStrG9R:SetProperty("G9R_VALOR", MVC_VIEW_CANCHANGE , .T.)

//Aba Serviços
oStrG9Q:SetProperty("G9Q_ITEM", MVC_VIEW_CANCHANGE , .F.)	
oStrG9Q:SetProperty("G9Q_DTEVEN", MVC_VIEW_CANCHANGE , .F.)

oStrG9P:SetProperty("G9P_ITEM", MVC_VIEW_CANCHANGE, .F.)
oStrG9P:SetProperty("G9P_ESTADO", MVC_VIEW_CANCHANGE, .F.)

//Aba 
oStrGIR:RemoveField("GIR_CODIGO")  
oStrGIR:RemoveField("GIR_CLIPAG")  
oStrGIR:RemoveField("GIR_LOJPAG")  
oStrGIR:RemoveField("GIR_NOMCLI")  
oStrGIR:RemoveField("GIR_CODIGO") 
oStrGIR:RemoveField("GIR_DTPAG") 

oStrGIR:SetProperty("GIR_SEQ" 	,MVC_VIEW_ORDEM, '01')
oStrGIR:SetProperty("GIR_TIPPAG",MVC_VIEW_ORDEM, '02')
oStrGIR:SetProperty("GIR_VALOR"	,MVC_VIEW_ORDEM, '03')
oStrGIR:SetProperty("GIR_TOMADO",MVC_VIEW_ORDEM, '04')
oStrGIR:SetProperty("GIR_TPCART",MVC_VIEW_ORDEM, '05')
oStrGIR:SetProperty("GIR_CODADM",MVC_VIEW_ORDEM, '06')
oStrGIR:SetProperty("GIR_DESADM",MVC_VIEW_ORDEM, '07')
oStrGIR:SetProperty("GIR_ESTAB" ,MVC_VIEW_ORDEM, '08')
oStrGIR:SetProperty("GIR_NUMPAR",MVC_VIEW_ORDEM, '09')
oStrGIR:SetProperty("GIR_NSU"	,MVC_VIEW_ORDEM, '10')
oStrGIR:SetProperty("GIR_AUT"	,MVC_VIEW_ORDEM, '11')

oStrGIR:SetProperty('GIR_TOMADO', MVC_VIEW_CANCHANGE , .F.)

oStrG9Q:SetProperty("G9Q_STAENC" , MVC_VIEW_COMBOBOX, RetCboxFld("G9Q_STAENC"))

oStrG9Q:SetProperty("G9Q_AGEORI",	MVC_VIEW_LOOKUP , "GI6FIL")
oStrG9Q:SetProperty("G9Q_AGEDES",	MVC_VIEW_LOOKUP , "GI6ADE")

GtpDestroy(aFields)

Return 

//------------------------------------------------------------------------------
/* /{Protheus.doc} GetTotKm

@type Static Function
@author 
@since 27/09/2019
@version 1.0
@param , character, (Descrição do parâmetro)
@return , return_description
@example
(examples)
@see (links_or_references)
/*/
//------------------------------------------------------------------------------
Static Function GetTotKm(oModel)
Local oMdlG99   := oModel:GetModel('MASTERG99')
Local oMdlG9Q   := oModel:GetModel('DETAILG9Q')
Local nTotKm    := 0
Local n1        := 0

For n1  := 1 To oMdlG9Q:Length()
    If !oMdlG9Q:IsDeleted(n1)
        nTotKm += oMdlG9Q:GetValue('G9Q_KILOME',n1)
    Endif

Next

oMdlG99:SetValue('G99_KMFRET',nTotKm)

Return 

//------------------------------------------------------------------------------
/* /{Protheus.doc} SetEstadosG9P

@type Static Function
@author 
@since 27/09/2019
@version 1.0
@param , character, (Descrição do parâmetro)
@return , return_description
@example
(examples)
@see (links_or_references)
/*/
//------------------------------------------------------------------------------
Static Function SetEstadosG9P(oModel)
Local oMdlG9Q   := oModel:GetModel('DETAILG9Q')
Local oMdlG9P   := oModel:GetModel('DETAILG9P')
Local aUfEnc    := {}
Local aUfAux    := {}
Local n1        := 0
Local n2        := 0

For n1  := 1 To oMdlG9Q:Length()
    If !oMdlG9Q:IsDeleted(n1)
        aUfAux  := GxGetUFLin(oMdlG9Q:GetValue('G9Q_CODLIN',n1),oMdlG9Q:GetValue('G9Q_LOCINI',n1),oMdlG9Q:GetValue('G9Q_LOCFIM',n1))
        For n2  := 1 To Len(aUfAux)
            If aScan(aUfEnc,aUfAux[n2]) == 0
                aAdd(aUfEnc,aUfAux[n2])
            Endif
        Next

    Endif

Next

For n1 :=  1 to Len(aUfEnc)
    If oMdlG9P:Length() >= n1
        oMdlG9P:GoLine(n1)
    ElseIf oMdlG9P:Length() < n1
        oMdlG9P:AddLine()
    Endif
    
    If oMdlG9P:IsDeleted()
        oMdlG9P:UnDeleteLine()
    Endif

    oMdlG9P:SetValue('G9P_ESTADO',aUfEnc[n1])
Next

If oMdlG9P:Length(.T.) > Len(aUfEnc)
    For n1 := Len(aUfEnc)+1 to oMdlG9P:Length()
        oMdlG9P:GoLine(n1)
        oMdlG9P:DeleteLine()
    Next
Endif

GtpDestroy(aUfEnc)
GtpDestroy(aUfAux)

Return 

/*/{Protheus.doc} VldPreLine
(long_description)
@type function
@author jacomo.fernandes
@since 25/01/2019
@version 1.0
@param oModel, objeto, (Descrição do parâmetro)
@param nLine, numérico, (Descrição do parâmetro)
@param cAction, character, (Descrição do parâmetro)
@param cField, character, (Descrição do parâmetro)
@param uValue, ${param_type}, (Descrição do parâmetro)
@return ${return}, ${return_description}
@example
(examples)
@see (links_or_references)
/*/
Static Function VldPreLine(oMdl,nLine,cAction,cField,uValue)
Local lRet		:= .T.
Local oModel    := oMdl:GetModel()
Local cMdlId	:= oMdl:GetId()
Local aDataMdl	:= nil
Local cMsgErro	:= ""
Local cSolucao	:= ""
Local oModelG99 := oModel:GetModel("MASTERG99")
Local nValTot   := oModelG99:GetValue("G99_VALOR")
Local nValor    := 0

If cMdlId == "DETAILG9Q"

	If lRet .and. (cAction == "DELETE" .or. cAction == "UNDELETE")
		aDataMdl := oMdl:GetData()
		aDataMdl[nLine][3] := If(cAction == "DELETE",.T.,.F.)
		
        SetEstadosG9P(oModel)
        GetTotKm(oModel)
	Endif

Endif

If cMdlId == "DETAILG9R"

	IF (cAction == "DELETE")
        // Pega o valor do registro posicionado no delete 
        nValTot -= oMdl:GetValue("G9R_VLFRET", nLine)
        
        oModelG99:LoadValue("G99_VALOR", nValTot)
        
    ELSEIF (cAction == "UNDELETE") 
        nValTot += oMdl:GetValue("G9R_VLFRET", nLine)
        
        oModelG99:LoadValue("G99_VALOR", nValTot)

    ELSEIF (cAction == "SETVALUE" .AND. cField == "G9R_VALOR")
        // Se a linha está sendo modificada deve subtrair o valor da requisição atual do total
        IF oMdl:GetValue("G9R_VLFRET", nline) != 0
            nValTot -= oMdl:GetValue("G9R_VLFRET", nline)
        ENDIF
        
        nValor := CalcFrete(oMdl:GetModel(),uValue)
        oMdl:SetValue("G9R_VLFRET", nValor)

        // Utiliza o parâmetro uValue que corresponde ao valor do campo GQW_TOTAL (NÃO USAR oModel:GetValue()!)
        nValTot +=  oMdl:GetValue("G9R_VLFRET", nline)
        oModelG99:LoadValue("G99_VALOR", nValTot)   
    EndIf    

Endif

If !lRet .and. !Empty(cMsgErro)
    oModel:SetErrorMessage(oMdl:GetId(),cField,oMdl:GetId(),cField,'Gc300mPreLine',cMsgErro,cSolucao)
Endif


Return lRet 

//------------------------------------------------------------------------------
/* /{Protheus.doc} GetTabFrete

@type Static Function
@author jacomo.fernandes
@since 01/10/2019
@version 1.0
@param , character, (Descrição do parâmetro)
@return cRet, return_description
@example
(examples)
@see (links_or_references)
/*/
//------------------------------------------------------------------------------
Static Function GetTabFrete(cProduto,cCliente,cLoja)
Local cRet      := ""
Local cTmpAlias := GetNextAlias()

BeginSql Alias cTmpAlias
    select G5J_CODIGO 
    from (
            SELECT  
                G5J.G5J_CODIGO,
                DENSE_RANK() OVER (ORDER BY GZN_CLIENT DESC,G5J.G5J_CODIGO) RANK
            FROM %Table:G5J% G5J
                LEFT JOIN %Table:GZN% GZN ON 
                    GZN.GZN_FILIAL = G5J.G5J_FILIAL
                    AND GZN.GZN_CODIGO = G5J.G5J_CODIGO
                    AND GZN.%NotDel%
            WHERE
                G5J.G5J_FILIAL = %xFilial:G5J%
                AND G5J.G5J_PRODUT = %Exp:cProduto%
                AND  G5J.%NotDel%
                AND (
                        (GZN.GZN_CLIENT = %Exp:cCliente% AND GZN.GZN_LOJA = %Exp:cLoja%) 
                        OR GZN.GZN_CLIENT IS NULL
                    )
        ) T
    where 
        RANK = 1
EndSql

If (cTmpAlias)->(!Eof())
    cRet := (cTmpAlias)->G5J_CODIGO
Endif

(cTmpAlias)->(DbCloseArea())

Return cRet

//------------------------------------------------------------------------------
/* /{Protheus.doc} PosValid

@type Static Function
@author jacomo.fernandes
@since 01/10/2019
@version 1.0
@param , character, (Descrição do parâmetro)
@return cRet, return_description
@example
(examples)
@see (links_or_references)
/*/
//------------------------------------------------------------------------------
Static Function PosValid(oModel)
Local lRet      := .T.
Local cMdlId	:= oModel:GetId()
Local cMsgErro	:= ""
Local cMsgSol	:= ""
Local cCLient   := ""
Local cTpPagto  := ""
Local   lAchaFp :=  .F.
Local cTipCte	:= oModel:GetModel('MASTERG99'):GetValue('G99_TIPCTE')
Local cTipMod	:= ''
Local cObserv	:= oModel:GetModel('MASTERG99'):GetValue('G99_OBSERV')
Local cTpEmis	:= oModel:GetModel('MASTERG99'):GetValue('G99_TPEMIS')
Local aRetPV    := {}
Local aMsg      := {}
Local oView     := NIL
Local lVlrDif   := GTPGetRules('DIFPLANILH',.F.,NIL,.F.) .And. G99->(FieldPos('G99_VLRPLN')) > 0
GTPAppendSwitch(.T.)

If G99->(ColumnPos("G99_TIPMOD")) > 0
    cTipMod := oModel:GetModel('MASTERG99'):GetValue('G99_TIPMOD')
Endif

lRet := GTPVldClient(XFilial("G99"),;   //Params: cFilCli,cCodCli,cLojaCli,cEspDoc
                    oModel:GetModel("MASTERG99"):GetValue("G99_CLIREM"),;
                    oModel:GetModel("MASTERG99"):GetValue("G99_LOJREM"),;
                    "CTE")

If ( lRet ) .AND. G99->(FieldPos("G99_CLIEXP")) > 0 

    lRet := GTPVldClient(XFilial("G99"),;   //Params: cFilCli,cCodCli,cLojaCli,cEspDoc   
            oModel:GetModel("MASTERG99"):GetValue("G99_CLIEXP"),;
            oModel:GetModel("MASTERG99"):GetValue("G99_LOJEXP"),;
            "CTE")

Endif

If ( lRet )  

    lRet := GTPVldClient(XFilial("G99"),;   //Params: cFilCli,cCodCli,cLojaCli,cEspDoc   
                oModel:GetModel("MASTERG99"):GetValue("G99_CLIDES"),;
                oModel:GetModel("MASTERG99"):GetValue("G99_LOJDES"),;
                "CTE")
Else
    aMsg := GTPRetMsg()
EndIf

If ( lRet .And. UpdFiscalRule(oModel) ) 


    If  (oModel:GetOperation() == MODEL_OPERATION_INSERT .Or. oModel:GetOperation() == MODEL_OPERATION_UPDATE)
        If !(Empty(oModel:GetModel("MASTERG99"):GetValue("G99_CFOP")))
            lRet := GTPVldCFOP(oModel:GetModel("MASTERG99"):GetValue("G99_CFOP"),;
                        GxGetMunAg(oModel:GetModel("MASTERG99"):GetValue("G99_CODEMI"))[1],;
                        GxGetMunAg(oModel:GetModel("MASTERG99"):GetValue("G99_CODREC"))[1],"0","CTE") 
            If ( lRet )

                lRet := GTPVldDoc(oModel:GetModel("MASTERG99"):GetValue("G99_SERIE"),"CTE")
                
                If (!lRet)
                    aMsg := GTPRetMsg()
                EndIf

            Else
                aMsg := GTPRetMsg()
            EndIf   
        EndIf

    Endif 

Else
    aMsg := GTPRetMsg()
EndIf

If oModel:GetModel("MASTERG99"):GetValue('G99_TOMADO') == '0'
    cClient := oModel:GetModel("MASTERG99"):GetValue('G99_CLIREM')+oModel:GetModel("MASTERG99"):GetValue('G99_LOJREM')
ElseIf oModel:GetModel("MASTERG99"):GetValue('G99_TOMADO') == '1'
    cClient := oModel:GetModel("MASTERG99"):GetValue('G99_CLIEXP')+oModel:GetModel("MASTERG99"):GetValue('G99_LOJEXP')
Else
    cClient := oModel:GetModel("MASTERG99"):GetValue('G99_CLIDES')+oModel:GetModel("MASTERG99"):GetValue('G99_LOJDES')
EndIf

If GIL->(FieldPos("GIL_RETIRA")) > 0 .AND. GIL->(FieldPos("GIL_FATURA")) > 0 .AND. GIL->(FieldPos("GIL_CARTAO")) > 0 .AND. GIL->(FieldPos("GIL_DINHEI")) > 0 .AND. GIL->(FieldPos("GIL_PIX")) > 0
    GIL->(DbSetorder(1))//Validação feita para atender a tarefa DSERGTP-8000 GIL_FILIAL+GIL_CODIGO+GIL_LOJA
    If GIL->(DbSEEK(xfilial("GIL") + cClient))
            
            If GIL->GIL_PIX
                cTpPagto += Iif(Empty(cTpPagto),"5","|5")
            Endif

            If GIL->GIL_RETIRA
                cTpPagto += Iif(Empty(cTpPagto),"4","|4")
            Endif

            If GIL->GIL_FATURA
                cTpPagto += Iif(Empty(cTpPagto),"3","|3")
            Endif

            If GIL->GIL_CARTAO
                cTpPagto += Iif(Empty(cTpPagto),"2","|2")
            Endif

            If GIL->GIL_DINHEI
                cTpPagto += Iif(Empty(cTpPagto),"1","|1") 
            Endif

            If Empty(cTpPagto)
                cTpPagto := "0" 
            Endif

        //Verifica se o tipo de pagto é o mesmo informado pelo cliente
        If  oModel:GetModel("DETAILGIR"):GetValue('GIR_TIPPAG') $ cTpPagto
            lAchaFp :=  .T.
        Endif

//             cTpPagto != "0" .AND. cTpPagto != oModel:GetModel("DETAILGIR"):GetValue('GIR_TIPPAG')
        If (oModel:GetOperation() == MODEL_OPERATION_INSERT .Or. oModel:GetOperation() == MODEL_OPERATION_UPDATE) .And.;
             ( cTpPagto != "0" .And. !lAchaFp) 
            aMsg      := {STR0160,STR0161}//"Deve ser informado o mesmo tipo de pagamento cadastrado nos parâmetros de clientes encomendas"#"Tipo de pagamento divergente"
            lRet := .F.
        EndIf

    EndIf
EndIf
If ( lRet )

    If oModel:GetOperation() != MODEL_OPERATION_INSERT .AND.  !(oModel:GetModel("MASTERG99"):GetValue("G99_STATRA") $ '0|1|3|5')
        cMsgErro := STR0106//'O documento não está com os status de não transmitido ou aguardando.'
        cMsgSol	 := STR0107//'Item não pode ser atualizado'
        lRet := .F.
    EndIf

    If oModel:GetOperation() != MODEL_OPERATION_INSERT .AND. !(Empty(oModel:GetModel("MASTERG99"):GetValue("G99_NUMFCH")))
        cMsgErro := STR0108//'Existe ficha de remessa associada a este item.'
        cMsgSol	 := STR0109//'Ficha de remessa'
        lRet := .F.
    EndIf

    If lRet .And. cTipCte == '2' .And. AllTrim(cObserv) == ''
        cMsgErro := STR0110//'O preenchimento da observação é obrigatório para CT-e de Anulação'
        cMsgSol	 := STR0111//'Informe uma observação'
        lRet := .F.
    Endif

    If lRet .And. cTpEmis $ '7|8|'
        
        cUF := AllTrim(SM0->M0_ESTENT)	
            
        If cTpEmis=='7' .AND. cUF $  "AL|PB|PI|RS|MG|SC|PA|AM|BA|CE|ES|GO|MA|PR|RJ|RN|RO|SE|TO"
            cMsgErro := STR0125 + cUF + STR0127 //' deve ser selecionado o tipo de contingencia 8-SVC-SP.'
            cMsgSol	 := STR0126 //'Ajuste o tipo de CTE.'
            lRet := .F.
        ElseIf cTpEmis=='8' .AND. cUF $ "AP|SP|MT|MS|PE|RR"
            cMsgErro := STR0125 + cUF + STR0128//' deve ser selecionado o tipo de contingencia 7-SVC-RS.'
            cMsgSol	 := STR0126 //'Ajuste o tipo de CTE.'
            lRet := .F.
        EndIf	
            
    Endif

    If oModel:GetOperation() == MODEL_OPERATION_INSERT .Or. oModel:GetOperation() == MODEL_OPERATION_UPDATE 
        IF !(valAgServ(oModel,@cMsgErro,@cMsgSol))
            lRet        := .F.
        EndIf

        If lRet .AND. EMPTY(GTPValG5J())
                lRet        := .F.
                cMsgErro	:= STR0146//"Tabela de frete não associada a cliente"
                cMsgSol	    := STR0147//"Selecione outra tabela"
        EndIf

        If lRet .AND. !SomaPagto(oModel)
                cMsgErro := STR0138 //'Soma dos pagamentos difere do valor informado  do serviço' 
                cMsgSol	 := STR0139 //'Verifique os valores informados em formas de pagamento'
                lRet := .F.
        Endif

        If lRet .AND. cTipMod == '2' .AND. EMPTY(oModel:GetModel('MASTERG99'):GetValue('G99_DTPREV'))
                cMsgErro := STR0205 //"Data prevista de entrega não informado"
                cMsgSol	 := STR0206 //"Para modal Aereo é obrigatório o preenchimento da data prevista"
                lRet := .F.
        Endif

        If lRet .And. lPlaCust .And. !(lVlrDif) .And. oModel:GetModel("MASTERG99"):GetValue("G99_VALOR") <> oModel:GetModel("MASTERG99"):GetValue("G99_VLRPLN")
            cMsgErro := STR0210 //"Existe diferença de valor do serviço e valor calculado da planilha."
            cMsgSol	 := STR0211 //"Foi refeito o valor do serviço com base na planilha.Favor avaliar."
            lRet := .F.
            oView := FwViewActive()
            GA801Calc(oView)
            oView:Refresh()
        Endif   

        SomaFrete(oModel)
            
        If !lRet .and. !Empty(cMsgErro)
            oModel:SetErrorMessage(cMdlId,,cMdlId,,"PosValid",cMsgErro,cMsgSol)
        Endif

        If lRet
            FwMsgRun(, {|| G800Process(@lRet,cMdlId,cTipCte, oModel,@cMsgErro,@cMsgSol) }, , STR0112)//"Aguarde"
        EndIf

    EndIf
    If lRet .And. oModel:GetOperation() == MODEL_OPERATION_DELETE
        lRet := DeletaNF(oModel,@cMsgErro,@cMsgSol,@aRetPV)
        If lRet
            If Len(aRetPV) > 0
                lRet:= DeletaPV(aRetPV,@cMsgErro)
            EndIf
        EndIf

        If lRet .AND. GIR->(FieldPos('GIR_TITTEF')) > 0
            lRet:= DeletaTit(oModel,@cMsgErro)
        Endif

        If !lRet .and. !Empty(cMsgErro)
            oModel:SetErrorMessage(cMdlId,,cMdlId,,"PosValid",cMsgErro,cMsgSol)
        Endif
    EndIf
Else
    oModel:SetErrorMessage(cMdlId,"",cMdlId,"","PosValid",aMsg[1],aMsg[2])//,uNewValue,uOldValue)
    GTPResetMsg()
EndIf

Return lRet

/*/{Protheus.doc} valAgServ
    (long_description)
    @type  Static Function
    @author user
    @since 27/06/2022
    @version version
    @param param_name, param_type, param_descr
    @return return_var, return_type, return_description
    @example
    (examples)
    @see (links_or_references)
/*/
Static Function valAgServ(oModel,cMsgErro,cMsgSol)
    Local lRet    := .T.
    Local oMdlG99 := oModel:GetModel('MASTERG99')
    Local cAgEmis := oMdlG99:GetValue('G99_CODEMI')
    Local cAgRece := oMdlG99:GetValue('G99_CODREC')
    Local oMdlG9Q := oModel:GetModel('DETAILG9Q')
    
    If oMdlG9Q:GetValue('G9Q_AGEORI',1) != cAgEmis
        lRet := .F.
        cMsgErro    := STR0162  //"Na aba de serviços o campo de agência origem da primeira linha diferente da agência emissora."
        cMsgSol     := STR0163  //"Agência origem deve conter o mesmo valor que a emissora."
    EndIf
    
    If lRet .AND. oMdlG9Q:GetValue('G9Q_AGEDES',oMdlG9Q:Length()) != cAgRece
        lRet := .F.
        cMsgErro    := STR0164  //"Na aba de serviços o campo de agência destino da ultima linha difere da agência recebedora"
        cMsgSol     := STR0165  //"Agência destino deve conter o mesmo valor que a recebedora."
    EndIf

Return lRet

//------------------------------------------------------------------------------
/* /{Protheus.doc} GeraNf

@type Static Function
@author jacomo.fernandes
@since 01/10/2019
@version 1.0
@param , character, (Descrição do parâmetro)
@return cRet, return_description
@example
(examples)
@see (links_or_references)
/*/
//------------------------------------------------------------------------------
Static Function VldNF(oModel,cMsgErro,cMsgSol)
Local lRet 		:= .T.
Local nOpc 		:= oModel:GetOperation()
Local cTipCte	:= oModel:GetModel('MASTERG99'):GetValue('G99_TIPCTE')
Local cNumDocAnt:= ''
Local cSerieAnt := ''
Local aRetPV    := {}

Begin Transaction

    If nOpc == MODEL_OPERATION_UPDATE .or. nOpc == MODEL_OPERATION_DELETE
    	cNumDocAnt:= G99->G99_NUMDOC
    	cSerieAnt := G99->G99_SERIE
        lRet := DeletaNF(oModel,@cMsgErro,@cMsgSol,@aRetPV)
        If lRet
            If Len(aRetPV) > 0
                lRet:= DeletaPV(aRetPV,@cMsgErro)
            EndIf
        EndIf
    Endif

    If lRet .and. (nOpc == MODEL_OPERATION_INSERT .or. nOpc == MODEL_OPERATION_UPDATE) .And. cTipCte <> '2'
    
        If nOpc == MODEL_OPERATION_UPDATE .AND. oModel:GetModel('MASTERG99'):GetValue('G99_SERIE') == cSerieAnt //reutilizar numero e serie
        	lRet := GeraNf(oModel,@cMsgErro,@cMsgSol, cNumDocAnt )
        Else
            lRet := GeraNf(oModel,@cMsgErro,@cMsgSol)
        Endif
    
    Endif

    If !lRet 
        DisarmTransaction()
        Break		
    Endif

End Transaction

Return lRet 

//------------------------------------------------------------------------------
/* /{Protheus.doc} GeraNf

@type Static Function
@author jacomo.fernandes
@since 01/10/2019
@version 1.0
@param , character, (Descrição do parâmetro)
@return cRet, return_description
@example
(examples)
@see (links_or_references)
/*/
//------------------------------------------------------------------------------
Static Function GeraNf(oModel,cMsgErro,cMsgSol, cNumDoc)
Local lRet          := .T.
Local aDadosCab     := {}
Local aItem         := {}
Local aDadosItem    := {}
Local bFiscalSF2    := nil
Local cNumero       := ""
Local oMdlG99       := oModel:GetModel('MASTERG99')
Local oMdlGIR       := oModel:GetModel('DETAILGIR')
Local cSerie        := oMdlG99:GetValue('G99_SERIE')
Local cEspecie      := "CTE"
Local cEstDev       := ""
Local cTipoCli      := ""
Local cSitTrib      := ""
Local aMunIni       := GxGetMunAg(oMdlG99:GetValue('G99_CODEMI'))
Local aMunFim       := GxGetMunAg(oMdlG99:GetValue('G99_CODREC'))
Local nXy           := 1
Local lLancTEF      := .F.
Local cTitTEF       := ""
Local aTitTEF       := {}

Default cNumDoc := ''

//-------------------------------------------------------------------------------
//Criação dos Dados de Cabeçalho
//-------------------------------------------------------------------------------
DbSelectArea( "SB0" )

SA1->(DbSetOrder(1))//
SF4->(DbSetOrder(1))
SB1->(DbSetOrder(1))
SBZ->(DbSetOrder(1))
SB0->(DbSetOrder(1))

aAdd(aDadosCab,{"F2_FILIAL"     ,xFilial("SF2")                 })
aAdd(aDadosCab,{"F2_TIPO"       ,"N"                            })
aAdd(aDadosCab,{"F2_SERIE"      ,cSerie                         })
aAdd(aDadosCab,{"F2_EMISSAO"    ,oMdlG99:GetValue('G99_DTEMIS') })

If oMdlG99:GetValue('G99_TOMADO') == "0"  //Remetente
    SA1->(DbSeek(xFilial('SA1')+oMdlG99:GetValue('G99_CLIREM')+oMdlG99:GetValue('G99_LOJREM') ))
ElseIf oMdlG99:GetValue('G99_TOMADO') == "1"  //Expedidor
    SA1->(DbSeek(xFilial('SA1')+oMdlG99:GetValue('G99_CLIEXP')+oMdlG99:GetValue('G99_LOJEXP') ))
Else
    SA1->(DbSeek(xFilial('SA1')+oMdlG99:GetValue('G99_CLIDES')+oMdlG99:GetValue('G99_LOJDES') ))
Endif

aAdd(aDadosCab,{"F2_CLIENTE"    ,SA1->A1_COD })
aAdd(aDadosCab,{"F2_LOJA"       ,SA1->A1_LOJA })

cEstDev     := SA1->A1_EST
cTipoCli    := SA1->A1_TIPO

aAdd(aDadosCab,{"F2_TIPOCLI"    ,cTipoCli})
aAdd(aDadosCab,{"F2_ESPECIE"    ,cEspecie})
aAdd(aDadosCab,{"F2_COND"       ,'001'})
aAdd(aDadosCab,{"F2_DTDIGIT"    ,oMdlG99:GetValue('G99_DTEMIS') })
aAdd(aDadosCab,{"F2_EST"        ,aMunIni[1]})
aAdd(aDadosCab,{"F2_VALMERC"    ,oMdlG99:GetValue('G99_VALOR') })
aAdd(aDadosCab,{"F2_MOEDA"      ,CriaVar( 'F2_MOEDA' )})
aAdd(aDadosCab,{"F2_UFORIG"     ,aMunIni[1]})
aAdd(aDadosCab,{"F2_CMUNOR"     ,aMunIni[2]})
aAdd(aDadosCab,{"F2_UFDEST"     ,aMunFim[1]})
aAdd(aDadosCab,{"F2_CMUNDE"     ,aMunFim[2]})

//-------------------------------------------------------------------------------
//Criação dos Dados de Item
//-------------------------------------------------------------------------------
aAdd(aItem,{"D2_FILIAL"     ,xFilial("SF2")     })
aAdd(aItem,{"D2_ITEM"       ,StrZero(1,TamSx3("D2_ITEM")[1])     })
aAdd(aItem,{"D2_SERIE"      ,cSerie             })
aAdd(aItem,{"D2_CLIENTE"    ,SA1->A1_COD        })
aAdd(aItem,{"D2_LOJA"       ,SA1->A1_LOJA       })
aAdd(aItem,{"D2_EMISSAO"    ,oMdlG99:GetValue('G99_DTEMIS')            })
aAdd(aItem,{"D2_TIPO"       ,"N"                })
aAdd(aItem,{"D2_UM"         ,"UN"               })
aAdd(aItem,{"D2_QUANT"      ,1                  })
aAdd(aItem,{"D2_PRUNIT"     ,oMdlG99:GetValue('G99_VALOR')    })
aAdd(aItem,{"D2_PRCVEN"     ,oMdlG99:GetValue('G99_VALOR')    })
aAdd(aItem,{"D2_TOTAL"      ,oMdlG99:GetValue('G99_VALOR')    })
aAdd(aItem,{"D2_EST"        ,aMunIni[1]            })
aAdd(aItem,{"D2_ESPECIE"    ,cEspecie	        })
If SB1->(DbSeek(xFilial('SB1')+oMdlG99:GetValue('G99_CODPRO') ))
            
    aAdd(aItem,{"D2_LOCAL"      ,SB1->B1_LOCPAD     })
    aAdd(aItem,{"D2_COD"        ,SB1->B1_COD        })
    aAdd(aItem,{"D2_TP"         ,SB1->B1_TIPO       })
    aAdd(aItem,{"D2_CONTA"      ,SB1->B1_CONTA      })

    If !Empty( SB1->B1_CODISS )
        aAdd(aItem,{"D2_CODISS"     ,SB1->B1_CODISS     })
    ElseIf SBZ->( dbSeek( xFilial("SBZ") + oMdlG99:GetValue('G99_CODPRO') ) ) .And. !Empty( SBZ->BZ_CODISS )
        aAdd(aItem,{"D2_CODISS"     ,SBZ->BZ_CODISS     })
    EndIf

    aAdd(aItem,{"D2_TES"        ,oMdlG99:GetValue('G99_TS')     })
    aAdd(aItem,{"D2_CF"         ,oMdlG99:GetValue('G99_CFOP')         })
    aAdd(aItem,{"D2_ESTOQUE"    ,Posicione('SF4',1,xFilial('SF4')+oMdlG99:GetValue('G99_TS'),'F4_ESTOQUE')    })

    SB0->(DbSeek(xFilial("SB0")+SB1->B1_COD))
    
    //Executa funções padrões do LOJA para retornar a situação tributária a ser gravada na SD2
    Lj7Strib(@cSitTrib ) 
    Lj7AjustSt(@cSitTrib)

    aAdd(aItem,{"D2_SITTRIB"    ,cSitTrib           })

Endif

aAdd(aDadosItem,aItem)

bFiscalSF2 := {||;
                    MaFisAlt( "NF_UFORIGEM"     , aMunIni[1]   , , , , , , .F./*lRecal*/   ),;
                    MaFisAlt( "NF_UFDEST"       , aMunFim[1]   , , , , , , .F./*lRecal*/   ),;
                    MaFisAlt( "NF_PNF_UF"       , cEstDev      , , , , , , .F./*lRecal*/   ),;
                    MaFisAlt( "NF_ESPECIE"      , cEspecie     , , , , , , .F./*lRecal*/   ),;
                    MaFisAlt( "NF_PNF_TPCLIFOR" , cTipoCli );
                }

cNumero := GTPxNFS(cSerie,aDadosCab,aDadosItem,bFiscalSF2,cNumDoc)

If !Empty(cNumero)
    oMdlG99:SetValue('G99_NUMDOC',cNumero)
    oMdlG99:SetValue('G99_STATRA',"0")

    If G99->(FieldPos('G99_FILDOC')) > 0
        oMdlG99:LoadValue('G99_FILDOC', xFilial('SF2'))
    Endif

    For nXy:= 1 to oMdlGIR:Length() 
        oMdlGIR:GoLine(nXy)
        If !oMdlGIR:IsDeleted() .AND. oMdlGIR:GetValue('GIR_TIPPAG') == "2" .AND. GIR->(FieldPos('GIR_TITTEF')) > 0
            lLancTEF := IIF(!lLancTEF,MsgYesNo(STR0204),.T.) //"Realizar a inclusão de títulos financeiros de cartões?"
            If lLancTEF
                aTitTEF := {}

                aAdd(aTitTEF,oMdlGIR:GetValue('GIR_NUMPAR'))
                aAdd(aTitTEF,oMdlGIR:GetValue('GIR_VALOR'))
                aAdd(aTitTEF,oMdlG99:GetValue('G99_DTEMIS'))
                aAdd(aTitTEF,SA1->A1_NATUREZ)
                aAdd(aTitTEF,SA1->A1_COD)
                aAdd(aTitTEF,SA1->A1_LOJA)
                aAdd(aTitTEF,IIF(oMdlGIR:GetValue('GIR_TPCART')=='1','CD','CC'))
                aAdd(aTitTEF,'')
                aAdd(aTitTEF,oMdlGIR:GetValue('GIR_AUT'))
                aAdd(aTitTEF,oMdlGIR:GetValue('GIR_NSU'))
                aAdd(aTitTEF,'')
                aAdd(aTitTEF,'')
                aAdd(aTitTEF,STR0033+' '+cNumero)
                aAdd(aTitTEF,'')
                aAdd(aTitTEF,'')
                aAdd(aTitTEF,'')

                IF oModel:GetOperation() == MODEL_OPERATION_UPDATE
                    DeletaTit(oModel,cMsgErro)
                    oMdlGIR:GoLine(nXy)
                Endif

                cTitTEF := GTPP003(aTitTEF,oMdlGIR:GetValue('GIR_CODADM'),.F.,cNumero)

                If Empty(cTitTEF)
                    lRet := .F.
                    cMsgErro    := STR0209 //"Não foi possivel gerar o título de cartão"
                    cMsgSol     := ""
                Else
                    oMdlGIR:SetValue('GIR_TITTEF',cTitTEF)
                Endif
            Endif
        ENDIF
    Next nXy
    

Else
    lRet := .F.
    cMsgErro    := STR0113//"Não foi possivel gerar o documento de Saida"
    cMsgSol     := STR0114//"Verifique se o cliente, produto, tipo de Saída ou o CFOP estão cadastrados corretamente"
Endif

Return lRet

//------------------------------------------------------------------------------
/* /{Protheus.doc} DeletaNF

@type Static Function
@author jacomo.fernandes
@since 01/10/2019
@version 1.0
@param , character, (Descrição do parâmetro)
@return cRet, return_description
@example
(examples)
@see (links_or_references)
/*/
//------------------------------------------------------------------------------
Static Function DeletaNF(oModel,cMsgErro,cMsgSol,aRetPV)
Local lRet      := .T.
Local nOpc      := oModel:GetOperation()
Local oMdlG99   := oModel:GetModel('MASTERG99')
Local dDtdigit  := Stod('')
Local cChvNF    := ""
Local aRegSD2   := {}
Local aRegSE1   := {}
Local aRegSE2   := {}
Local cFilDoc   := ""

If G99->(FieldPos('G99_FILDOC')) > 0
    cFilDoc := oMdlG99:GetValue('G99_FILDOC')
Else
    cFilDoc := Posicione('GI6',1,xFilial('GI6')+oMdlG99:GetValue('G99_CODEMI'),"GI6_FILRES")
Endif

SF2->(DbSetOrder(1))//F2_FILIAL+F2_DOC+F2_SERIE+F2_CLIENTE+F2_LOJA+F2_FORMUL+F2_TIPO
If !Empty(oMdlG99:GetValue('G99_NUMDOC')) 
    
    cChvNF := cFilDoc+oMdlG99:GetValue('G99_NUMDOC')+oMdlG99:GetValue('G99_SERIE')

    If oMdlG99:GetValue('G99_TOMADO') == "0"
        cChvNF += oMdlG99:GetValue('G99_CLIREM')+oMdlG99:GetValue('G99_LOJREM')
    ElseIf oMdlG99:GetValue('G99_TOMADO') == "1"
        cChvNF += oMdlG99:GetValue('G99_CLIEXP')+oMdlG99:GetValue('G99_LOJEXP')
    Else
        cChvNF += oMdlG99:GetValue('G99_CLIDES')+oMdlG99:GetValue('G99_LOJDES')
    Endif

    If SF2->(DbSeek(cChvNF))
        // Exclui a nota
        dDtdigit 	:= IIf(!Empty(SF2->F2_DTDIGIT),SF2->F2_DTDIGIT,SF2->F2_EMISSAO)
        IF dDtDigit >= MVUlmes()
            If MaCanDelF2("SF2",SF2->(RecNo()),@aRegSD2,@aRegSE1,@aRegSE2)
                SF2->(MaDelNFS(aRegSD2,aRegSE1,aRegSE2,.F.,.F.,.T.,.F.))
                Aadd(aRetPV,{SD2->D2_FILIAL,SD2->D2_PEDIDO,SD2->D2_CLIENTE,SD2->D2_LOJA})
                If nOpc <> MODEL_OPERATION_DELETE
                    oMdlG99:SetValue('G99_NUMDOC',"")
                    oMdlG99:SetValue('G99_STATRA',"9")

                    If G99->(FieldPos('G99_FILDOC')) > 0
                        oMdlG99:SetValue('G99_FILDOC',"")
                    Endif

                Endif
            Else
                lRet        := .F.
                cMsgErro    := STR0115//"Não foi possivel excluir a nota"
                cMsgSol     := ""
            Endif
                
        EndIf
    Endif
EndIf

Return lRet 
//------------------------------------------------------------------------------
/* /{Protheus.doc} VldLocxAge

@type Static Function
@author jacomo.fernandes
@since 01/10/2019
@version 1.0
@param , character, (Descrição do parâmetro)
@return cRet, return_description
@example
(examples)
@see (links_or_references)
/*/
//------------------------------------------------------------------------------
Static Function VldLocxAge(oModel,cMsgErro,cMsgSol)
Local lRet  := .T.
Local oMdlG99   := oModel:GetModel('MASTERG99')
Local oMdlG9Q   := oModel:GetModel('DETAILG9Q')
Local cLocIni   := ""
Local cLocFim   := ""
Local n1        := 0

For n1 := 1 To oMdlG9Q:Length()
    If !oMdlG9Q:IsDeleted(n1)
        If Empty(cLocIni)
            cLocIni := oMdlG9Q:GetValue('G9Q_LOCINI',n1)
        Endif

        cLocFim := oMdlG9Q:GetValue('G9Q_LOCFIM',n1)
    Endif
Next

If !GxVldLocAg(oMdlG99:GetValue('G99_CODEMI'),cLocIni)
    lRet        := .F.
    cMsgErro    := STR0116//"Localidade inicial difere da localidade da agencia emissora"
    cMsgSol     := STR0117//"Informe outra localidade inicial"
ElseIf !GxVldLocAg(oMdlG99:GetValue('G99_CODREC'),cLocFim)
    lRet        := .F.
    cMsgErro    := STR0118//"Localidade Final difere da localidade da agencia recebedora"
    cMsgSol     := STR0119//"Informe outra localidade final"
Endif

Return lRet

//------------------------------------------------------------------------------
/* /{Protheus.doc} VldSeqServ

@type Static Function
@author jacomo.fernandes
@since 01/10/2019
@version 1.0
@param , character, (Descrição do parâmetro)
@return cRet, return_description
@example
(examples)
@see (links_or_references)
/*/
//------------------------------------------------------------------------------
Static Function VldSeqServ(oModel,cMsgErro,cMsgSol)
Local lRet      := .T.
Local oMdlG9Q   := oModel:GetModel('DETAILG9Q')
Local n1        := 0
Local n2        := 0
Local cLocFim   := ""
Local cLocIni   := ""

For n1  := 1 to oMdlG9Q:Length() -1
    If !oMdlG9Q:IsDeleted(n1)
        cLocFim := oMdlG9Q:GetValue("G9Q_LOCFIM",n1)

        For n2 := n1+1 to oMdlG9Q:Length()
            If !oMdlG9Q:IsDeleted(n2)
                cLocIni := oMdlG9Q:GetValue("G9Q_LOCINI",n2)
                Exit
            Endif
        Next
        
        If cLocFim <> cLocIni
            lRet        := .F.
            cMsgErro    := I18n(STR0120,{oMdlG9Q:GetValue("G9Q_ITEM",n2),oMdlG9Q:GetValue("G9Q_ITEM",n1)})//"Localidade Incial da Sequência de Servico: #1 difere da localidade final da sequência: #2"
            cMsgSol     := STR0121//"Informe uma sequencia lógica de serviços "
            Exit
        Endif

    Endif

Next

Return lRet

//------------------------------------------------------------------------------
/* /{Protheus.doc} VldSeqServ

@type Static Function
@author jacomo.fernandes
@since 01/10/2019
@version 1.0
@param , character, (Descrição do parâmetro)
@return cRet, return_description
@example
(examples)
@see (links_or_references)
/*/
//------------------------------------------------------------------------------
Static Function VldSeqLoc(oMdl)
Local lRet      := .T.
Local cCodLin   := oMdl:GetValue('G9Q_CODLIN')
Local cLocIni   := oMdl:GetValue('G9Q_LOCINI')
Local cLocFim   := oMdl:GetValue('G9Q_LOCFIM')
Local cSeqIni   := ""
Local cSeqFim   := ""

If !Empty(cLocIni) .and. !Empty(cLocFim)
    cSeqIni   := Posicione('G5I',3,xFilial('G5I')+cCodLin+cLocIni+"2",'G5I_SEQ')
    cSeqFim   := Posicione('G5I',3,xFilial('G5I')+cCodLin+cLocFim+"2",'G5I_SEQ')

    If cSeqIni >= cSeqFim
        lRet := .F.
    Endif
        
Endif
Return lRet

/*/
* {Protheus.doc} ExeRecibo()
* Recibo CTE
* type    Function
* author  Eduardo Ferreira
* since   24/10/2019
* version 12.25
* param   Não há
* return  Não há
/*/
Function ExeRecibo()

    If ExistBlock("GTPR801ENC")
        ExecBlock("GTPR801ENC", .f., .f., {G99->(Recno())})
    Else
        FwAlertHelp(STR0124)//'Função não Compilada!'
    Endif

Return 

//------------------------------------------------------------------------------
/* /{Protheus.doc} G800Process

@type Static Function
@author jacomo.fernandes
@since 01/10/2019
@version 1.0
@param , character, (Descrição do parâmetro)
@return cRet, return_description
@example
(examples)
@see (links_or_references)
/*/
//------------------------------------------------------------------------------
Static Function G800Process(lRet,cMdlId,cTipCte, oModel,cMsgErro,cMsgSol)
Local oMdlGIY       := oModel:GetModel('DETAILGIY')
Local oMdlGIR       := oModel:GetModel('DETAILGIR')

IF lRet .and. !VldLocxAge(oModel,@cMsgErro,@cMsgSol) .And. cTipCte <> '2'
    lRet := .F.
Endif

iF lRet .and. !VldSeqServ(oModel,@cMsgErro,@cMsgSol) .And. cTipCte <> '2'
    lRet := .F.
Endif

Begin Transaction

If lRet    
    IF oMdlGIR:GetValue('GIR_TIPPAG') $ '1|2|5'//1=Dinheiro;2=Cartão;3=Faturado;4=Pago na Retirada;5=PIX                                                                               
        
        oMdlGIY:LoadValue('GIY_IDORIG','')      
        oMdlGIY:LoadValue('GIY_VALOR', oModel:GetModel("MASTERG99"):GetValue("G99_VALOR"))    
        oMdlGIY:LoadValue('GIY_DTBAIX', dDataBase  ) 
            
    ENDIF
EndIf

If lRet .and. !VldNF(oModel,@cMsgErro,@cMsgSol)
    lRet := .F.
    DisarmTransaction()
Endif

End Transaction

If !lRet .and. !Empty(cMsgErro)
    oModel:SetErrorMessage(cMdlId,,cMdlId,,"PosValid",cMsgErro,cMsgSol)
Endif

Return lRet

/*/{Protheus.doc} GTPDocFis
//Visualiza documento.
@author osmar.junior
@since 29/10/2019
@version 1.0
@return ${return}, ${return_description}

@type function
/*/
Function GTPDocFis()
	Local cCliLoj   := ''
    Local cFilDoc   := ''
    
	If G99->G99_TOMADO == '0' //REMETENTE
		cCliLoj := G99->(G99_CLIREM + G99_LOJREM)
    ElseIf G99->G99_TOMADO == '1' //EXPEDIDOR
        cCliLoj := G99->(G99_CLIEXP + G99_LOJEXP)
	ElseIf G99->G99_TOMADO == '3' //DESTINATARIO
		cCliLoj := G99->(G99_CLIDES + G99_LOJDES)
	EndIf

    If G99->(FieldPos('G99_FILDOC')) > 0
        cFilDoc := G99->G99_FILDOC
    Else
        cFilDoc := Posicione('GI6',1,xFilial('GI6')+G99->G99_CODEMI,"GI6_FILRES")
    Endif    

	dbSelectArea("SF2")
	dbSetOrder(1)			
	If  MsSeek(cFilDoc+G99->G99_NUMDOC+G99->G99_SERIE+cCliLoj)
		FwMsgRun(, {|| Mc090Visua() }, , STR0001	)	//'Carregendo documento...'	
	Endif

Return

//------------------------------------------------------------------------------
/* /{Protheus.doc} Gtp801AtuSta

@type Function
@author jacomo.fernandes
@since 27/11/2019
@version 1.0
@param , character, (Descrição do parâmetro)
/*/
//------------------------------------------------------------------------------
Function Gtp801AtuSta(cCodigo,cEvento,cViagem,cAgeFim)
Local cStatusG99	:= ""
Local cStatusG9Q	:= ""
Local cLinha		:= Space(TamSx3('GYN_LINCOD')[1])
Local cServico		:= Space(TamSx3('GYN_CODGID')[1])

Default cAgeFim		:= ""

G99->(DbSetOrder(1))//
G9Q->(DbSetOrder(2))//
GYN->(DbSetOrder(1))//

If GYN->(DbSeek(xFilial('GYN')+cViagem))
	cLinha   := GYN->GYN_LINCOD
	cServico := GYN->GYN_CODGID
Endif
/* G99_STAENC
"1=Encomenda aguardando Transporte"             
"2=Encomenda em Transporte"                     
"3=Encomenda em Transbordo"                     
"4=Encomenda Recebida"                          
"5=Encomenda Retirada"                          
*/

/* G9Q_STAENC
"1=Aguardando"
"2=Em Transporte"
"3=Recebido"
"4=Retirado"
"5=Encerrado"
"6=Transbordo"
*/

If G99->(DbSeek(xFilial('G99')+cCodigo))

	Do Case
		Case cEvento == "1" //Cancelamento
			cStatusG99	:= "1" // "aguardando Transporte"  
		Case cEvento == "2" //Encerramento
			If G99->G99_STAENC <> '4' //Recebido
				If cAgeFim <> G99->G99_CODREC
					cStatusG99	:= "1" //"aguardando Transporte"  
				Else
					cStatusG99	:= "2" // "Encomenda em Transporte"  
				Endif
			Endif
		Case cEvento == "3" //Inclusão Manifesto
			cStatusG99	:= "2" // "2=Em Transporte"
		Case cEvento == "4" //Recebimento
			If cAgeFim == G99->G99_CODREC
				cStatusG99	:= "4" // "4=Recebido"
			Else
				cStatusG99	:= "1" //"aguardando Transporte" 
			Endif
		Case cEvento == "5" //Retirada
			cStatusG99	:= "5" // "5=Retirado"
		Case cEvento == "6" //Exclusão Manifesto
			cStatusG99	:= "1" // "aguardando Transporte"  
		
	EndCase


	G99->(RecLock('G99',.F.))
	G99->G99_STAENC := cStatusG99
	If cEvento  == "2"//Encerramento
		G99->G99_USUENC := AllTrim(RetCodUsr())
	Endif
    If cEvento == "4"
        G99->G99_DTRECB := dDataBase
    Endif
	G99->(MsUnlock())

	If G9Q->(DbSeek(xFilial('G9Q')+cCodigo+cLinha+cServico)) ;
		.or. G9Q->(DbSeek(xFilial('G9Q')+cCodigo+cLinha))
		
		Do Case
			Case cEvento == "1" //Cancelamento
				cStatusG9Q	:= "1" // "aguardando Transporte"  
			Case cEvento == "2" //Encerramento
				If G9Q->G9Q_STAENC <> '3' //Recebido
					If cAgeFim == G9Q->G9Q_AGEDES 
						cStatusG9Q	:= "5" // "Encerrado"  
					Else
						cStatusG9Q	:= "1" // "aguardando Transporte"  
					Endif
				Endif
			Case cEvento == "3" //Inclusão de Manifesto
				cStatusG9Q	:= "2" // "em Transporte"  
            Case cEvento == "4" //Recebmento
                If cAgeFim == G9Q->G9Q_AGEDES 
                    IF G9Q->G9Q_AGEDES == G99->G99_CODREC
                        cStatusG9Q	:= "3" // "Recebido"  
                    Else
                        cStatusG9Q	:= "6" //"6=Transbordo"
                    Endif
				Else
					cStatusG9Q	:= "1" // "aguardando Transporte"  
				Endif
			Case cEvento == "5" //Retirada
				cStatusG9Q	:= "4" // "Retirado"
			Case cEvento == "6" //Exclusão Manifesto
				cStatusG9Q	:= "1" // "aguardando Transporte"  
		EndCase


		G9Q->(RecLock('G9Q',.F.))
        G9Q->G9Q_STAENC := cStatusG9Q
        G9Q->G9Q_DTEVEN := dDataBase
		    If cEvento  == "4"
			G9Q->G9Q_USUREC := AllTrim(RetCodUsr())
		Endif
		G9Q->(MsUnlock())
    Endif
Endif
Return

//------------------------------------------------------------------------------
/* /{Protheus.doc} VldOpcPag
@type Function
@author flavio.martins
@since 05/12/2019
@version 1.0
@param , character, (Descrição do parâmetro)
/*/
//------------------------------------------------------------------------------
Static Function VldOpcPag(oModel, cMsgErro, cMsgSol)
Local lRet 		:= .T.
Local cCliRem	:= oModel:GetModel('MASTERG99'):GetValue('G99_CLIREM')
Local cLojRem	:= oModel:GetModel('MASTERG99'):GetValue('G99_LOJREM')
Local cCliDes	:= oModel:GetModel('MASTERG99'):GetValue('G99_CLIDES')
Local cLojDes	:= oModel:GetModel('MASTERG99'):GetValue('G99_LOJDES')
Local cTomador	:= oModel:GetModel('MASTERG99'):GetValue('G99_TOMADO')
Local cTipPag	:= oModel:GetModel('DETAILGIR'):GetValue('GIR_TIPPAG')

If cTomador $ '0|1' //Remetente e expedidor

    If cTipPag == '1'
        If AliasInDic("H65")
            H65->(DBSETORDER(2))
            If H65->(DBSEEK(XFILIAL("H65") + oModel:GetModel('MASTERG99'):GetValue('G99_CODEMI') + '1'))
                cMsgErro := STR0166//"Opção inválida para agência bloqueada"
                cMsgSol  := STR0167//"Efetue o desbloqueio da agência."
                lRet     := .F.
            EndIf
        EndIf
    EndIf
    If lRet
	    If cTipPag == '3'  // Faturado
			If !(GIL->(dbSeek(xFilial('GIL')+cCliRem+cLojRem)))
				cMsgErro := STR0140 //'Opção inválida para clientes sem contrato'
				cMsgSol	 := STR0141 //'Selecione outra forma de pagamento'
				lRet	 := .F.
			ElseIf (GIL->(dbSeek(xFilial('GIL')+cCliRem+cLojRem))) .And. GIL->GIL_TPFRET == '2'
				cMsgErro := STR0142 //'Tipo de contrato do cliente não permite esta opção'
				cMsgSol	 := STR0141 //'Selecione outra forma de pagamento'
				lRet	 := .F.
			Endif

		ElseIf cTipPag == '4'  // Pago na Retirada
				cMsgErro := STR0145 //'Opção inválida quando o tomador é o remetente'
				cMsgSol	 := STR0141 //'Selecione outra forma de pagamento'
				lRet	 := .F.
		Endif
    EndIf

Else //Destinatário

	If cTipPag $ '1|2|5' // Dinheiro, Cartão, PIX

//		If !(GIL->(dbSeek(xFilial('GIL')+cCliDes+cLojDes)))
			cMsgErro := STR0143 //'Opção inválida quando o tomador é o destinatário'
			cMsgSol	 := STR0141 //'Selecione outra forma de pagamento'
			lRet	 := .F.
//		Endif
	
	ElseIf cTipPag =='3' // Faturado
	
		If !(GIL->(dbSeek(xFilial('GIL')+cCliDes+cLojDes)))
			cMsgErro := STR0140 //'Opção inválida para clientes sem contrato'
			cMsgSol	 := STR0141 //'Selecione outra forma de pagamento'
			lRet	 := .F.
		ElseIf (GIL->(dbSeek(xFilial('GIL')+cCliDes+cLojDes))) .And. GIL->GIL_TPFRET == '1'
			cMsgErro := STR0142 //'Tipo de contrato do cliente não permite esta opção'
			cMsgSol	 := STR0141 //'Selecione outra forma de pagamento'
			lRet	 := .F.
		Endif
	
	Endif
	
Endif

Return lRet

//------------------------------------------------------------------------------
/* /{Protheus.doc} UpdPagto
@type Function
@author flavio.martins
@since 05/12/2019
@version 1.0
@param , character, (Descrição do parâmetro)
/*/
//------------------------------------------------------------------------------
Static Function UpdPagto(oModel)
Local oMdlGIR	:= oModel:GetModel('DETAILGIR')
Local nX		:= 0

For nX := 1 To oMdlGIR:Length()
	
	oMdlGIR:GoLine(nX)
	oMdlGIR:ClearField('GIR_TIPPAG')
	oMdlGIR:ClearField('GIR_VALOR')
	oMdlGIR:ClearField('GIR_TOMADO')

Next

Return

//------------------------------------------------------------------------------
/* /{Protheus.doc} SomaPagto
@type Function
@author flavio.martins
@since 05/12/2019
@version 1.0
@param , character, (Descrição do parâmetro)
/*/
//------------------------------------------------------------------------------
Static Function SomaPagto(oModel)
Local lRet		:= .T.
Local oMdlGIR	:= oModel:GetModel('DETAILGIR')
Local nTotGIR	:= 0
Local nTotG99	:= oModel:GetModel('MASTERG99'):GetValue('G99_VALOR')
Local nX	  	:= 0

For nX := 1 To oMdlGIR:Length() 
	If (!oMdlGIR:IsDeleted(nX)) 
        nTotGIR += oMdlGIR:GetValue('GIR_VALOR', nX)
    EndIf
Next
	
lRet := (nTotGIR == nTotG99)

Return lRet

//------------------------------------------------------------------------------
/* /{Protheus.doc} SomaFrete
@type Function
@author 
@since 17/12/2019
@version 1.0
@param , character, (Descrição do parâmetro)
/*/
//------------------------------------------------------------------------------
Static Function SomaFrete(oModel)
Local oMdlG9R	:= oModel:GetModel('DETAILG9R')
Local nTotG9R	:= 0
Local nTotG99	:= oModel:GetModel('MASTERG99'):GetValue('G99_VALOR')
Local nX	  	:= 0

If ValTpFrete(oModel)
    For nX := 1 To oMdlG9R:Length()
        nTotG9R += oMdlG9R:GetValue('G9R_VLFRET', nX)
    Next
Else
    nTotG9R := nTotG99
EndIf
oModel:GetModel('MASTERG99'):LoadValue('G99_VALOR',nTotG9R)

Return 

/*/{Protheus.doc} valLinPgto
    (Calcula valor de inicialização da proxima linha da Grid de pagamento )
    @type  Static Function
    @author marcelo.adente
    @since 14/06/2022
    @version 1.0
    @return nVal, number, Valor Total da Encomenda menos valores das linhas de pagamento
    @see (links_or_references)
/*/
Static Function valLinPgto(oModel)
Local nVal := 0
Local oMdlGIR	:= oModel:GetModel('DETAILGIR')
Local nTotGIR	:= 0
Local nTotG99	:= oModel:GetModel('MASTERG99'):GetValue('G99_VALOR')
Local nX	  	:= 0

nVal := nTotG99

For nX := 1 To oMdlGIR:Length()
	If (!oMdlGIR:IsDeleted(nX)) 
        nTotGIR += oMdlGIR:GetValue('GIR_VALOR', nX)
    EndIf
Next

nVal := nTotG99 - nTotGIR

Return nVal

/*/{Protheus.doc} AfterActiv
//TODO Descrição auto-gerada.
@author flavio.martins
@since 24/06/2022
@version 1.0
@return ${return}, ${return_description}
@param oView, object, descricao
@type function
/*/
Static Function AfterActiv(oView)
    Local oMdl := Nil 

    If oView:GetModel():GetOperation() == MODEL_OPERATION_UPDATE
        oMdl := FwModelActive()
        lPlaCust := !Empty(GetAdvFval('G5J','G5J_GIMCOD',xFilial('G5J')+oMdl:GetModel("MASTERG99"):GetValue("G99_TABFRE"),1)) 
        FwAlertWarning(STR0168,STR0169) //"A efetivação da alteração do CT-e irá excluir o documento de saída gerado anteriormente e irá gerar um novo documento de saída."#"Atenção"
    Endif

Return

//------------------------------------------------------------------------------
/*/{Protheus.doc} G801TabFrt

Função responsável pela busca da TES e CFOP que foram cadastrados dentro da tabela
de frete

@type Static Function
@author Fernando Radu Muscalu
@since 15/07/2022
@version 1.0
@params
    1° oSubMl, objeto, instância da classe FwFormFields
    2° cIdFrete, caractere, código do Frete
    3° cFilSeek, caractere, código da Filial

@return aFisFrete, array,   aFisFrete[1], caractere, código da TES
                            aFisFrete[2], caractere, código da CFOP
@example
(examples)
@see (links_or_references)
/*/
//------------------------------------------------------------------------------
Function  G801TabFrt(oSubMdl,cIdFrete,cFilSeek,cTipo)

    Local aFisFrete     := {}
    Local aSeek         := {}
    Local aResult       := {}
    Local aMunIni       := {}
    Local aMunFim       := {}

    Local cTesPadrao    := ""
    Local cCFOPadrao    := ""
    Local cTes          := ""
    Local cCFOP         := ""

    Default cFilSeek    := xFilial("G5J")
    
    
    If ValType(oSubMdl) == 'O'
        If ( oSubMdl:GetId() == "MASTERG99" )
            aAdd(aSeek,{"G5J_FILIAL",cFilSeek})
            aAdd(aSeek,{"G5J_CODIGO",cIdFrete})
            aMunIni := GxGetMunAg(oSubMdl:GetValue('G99_CODEMI'))
            aMunFim := GxGetMunAg(oSubMdl:GetValue('G99_CODREC'))
        EndIf
    ElseIf !Empty(G99->G99_CODEMI) .AND. !Empty(G99->G99_CODREC)

        aMunIni := GxGetMunAg(G99->G99_CODEMI)
        aMunFim := GxGetMunAg(G99->G99_CODREC)

    EndIf    
    If Len(aMunIni) > 0 .AND. Len(aMunFim) > 0
        If ( GTPSeekTable("G5J",aSeek) )
            If G5J->(FieldPos("G5J_TES")) > 0
                cTesPadrao := G5J->G5J_TES
            EndIf
            If G5J->(FieldPos("G5J_CFOP")) > 0
                cCFOPadrao := G5J->G5J_CFOP
            EndIf
        EndIf

        aSeek := {}
        If AliasInDic("H66")
            aAdd(aSeek,{"H66_FILIAL",xFilial("H66")})
            aAdd(aSeek,{"H66_CODG5J",cIdFrete})
            aAdd(aSeek,{"H66_UFORIG",aMunIni[1]})
            aAdd(aSeek,{"H66_UFDEST",aMunFim[1]})
            
            If !Empty(cTipo) .AND. H66->(FieldPos("H66_OPTIPO")) > 0
                aAdd(aSeek,{"H66_OPTIPO",cTipo})
            EndIf
            
            aResult := {{"H66_TES","H66_CFNORM"}}
            
            GTPSeekTable("H66",aSeek,aResult)
            
            If ( Len(aResult) > 1 )
                
                cTes := aResult[2,1]
                cCFOP:= aResult[2,2]

            Else
                    
                cTes := cTesPadrao
                cCFOP:= cCFOPadrao

            EndIf
        EndIf
    EndIf

    aFisFrete := {cTes,cCFOP}
    
Return(aFisFrete)

//------------------------------------------------------------------------------
/*/{Protheus.doc} UpdFiscalRule

Função responsável pela atualização da TES e CFOP utilizados pela encomenda

@type Static Function
@author Fernando Radu Muscalu
@since 15/07/2022
@version 1.0
@params
    1° oModel, objeto, instância da classe FwFormModel
@return lRet, Lógica, .t. - atualização realizada com sucesso
@example
(examples)
@see (links_or_references)
/*/
//------------------------------------------------------------------------------
Static Function UpdFiscalRule(oModel)

    Local oSubG99 := oModel:GetModel("MASTERG99")

    Local aFisFrete := G801TabFrt(oSubG99,oSubG99:GetValue("G99_TABFRE"),,'1')

    Local lRet      := .T.

    If oModel:GetOperation() == MODEL_OPERATION_INSERT .Or. oModel:GetOperation() == MODEL_OPERATION_UPDATE
        If ( Len(aFisFrete) >= 1 )

            lRet := oSubG99:LoadValue("G99_TS",aFisFrete[1]) .And.;
                    oSubG99:LoadValue("G99_CFOP",aFisFrete[2])            
        
        EndIf
    Endif

Return(lRet)         

Static Function VldDocSA1(cDocto)
Local lRet := .T.

dbSelectArea("SA1")

SA1->(dbSetOrder(3))

lRet := SA1->(dbSeek(xFilial('SA1')+cDocTo))

Return lRet

//------------------------------------------------------------------------------
/* /{Protheus.doc} SetViewPVar(a,b,c,d,e,f,g,h,i,j)

@type Static Function
@author jacomo.fernandes
@since 03/12/2019
@version 1.0
@param , character, (Descrição do parâmetro)
@return cPictVar, return_description
/*/
//------------------------------------------------------------------------------
Static Function SetViewPVar(oMdl,cField,uVal)
Local cPictVar	:= nil

If cField $ "G99_DOCREM|G99_DOCDES|G99_DOCEXP"
	uVal := StrTran( uVal, "/", "")
	uVal := StrTran( uVal, ".", "")
	uVal := StrTran( uVal, "-", "")
	
	If !Empty(uVal) .and. Len(AllTrim(uVal)) <= 11
		cPictVar := "@R 999.999.999-99"
	Else
        cPictVar := "@!R NN.NNN.NNN/NNNN-99"
	Endif
	cPictVar += "%C"
Endif

Return cPictVar

/*/{Protheus.doc} GA801INC()
//TODO Descrição auto-gerada.
@author flavio.martins
@since 12/12/2022
@version 1.0
@return Nil
@param 
@type function
/*/
Function GA801INC()
Local oModel	:= FwLoadModel("GTPA801")
Local cAgencia  := GetAgencia()

If !Empty(cAgencia)

    oModel:SetOperation(MODEL_OPERATION_INSERT)
    oModel:Activate()
    oModel:SetValue('MASTERG99', 'G99_CODEMI', cAgencia)

	FwExecView(Upper(STR0028),"VIEWDEF.GTPA801",MODEL_OPERATION_INSERT,,,,,/*aEnableButtons*/,,,, oModel) // "Incluir"

Endif

Return

/*/{Protheus.doc} GetAgencia()
//TODO Descrição auto-gerada.
@author flavio.martins
@since 12/12/2022
@version 1.0
@return lRet
@param cAgencia
@type function
/*/
Static Function GetAgencia()
Local cAliasTmp := GetNextAlias()
Local nTotReg   := 0
Local cAgencia  := ""

BeginSql Alias cAliasTmp

    SELECT GI6.GI6_CODIGO
    FROM %Table:GI6% GI6
    INNER JOIN %Table:G9X% G9X ON G9X.G9X_FILIAL = %xFilial:G9X%
    AND G9X.G9X_CODGI6 = GI6.GI6_CODIGO
    AND G9X.G9X_CODUSR = %Exp:AllTrim(RetCodUsr())%
    AND G9X.%NotDel%
    WHERE GI6.GI6_FILIAL = %xFilial:GI6%
      AND GI6.GI6_FILRES = %Exp:cFilAnt%
      AND GI6.GI6_ENCEXP = '1'
      AND GI6.%NotDel%

EndSql

cAgencia := (cAliasTmp)->GI6_CODIGO
nTotReg  := (cAliasTmp)->(ScopeCount())

If nTotReg == 0
    FwAlertWarning(STR0154, STR0155) // "Não foram encontradas agências de encomendas vinculadas na filial selecionada", "Aviso"
ElseIf nTotReg == 1
    Return cAgencia
Else
    FwAlertInfo(STR0156, STR0157) // "Encontrada mais de uma agência vinculada a filial logada. Selecione a seguir a agência emissora da encomenda", "Informação"
    dbSelectArea("GI6")
    If Conpad1(,,, "GI6FIL")
        cAgencia := aCpoRet[1]
    Else
        cAgencia := ""
    Endif
Endif

(cAliasTmp)->(dbCloseArea())

Return cAgencia

/*/{Protheus.doc} VldLocalIni(oMdl, cCodSer)
//TODO Descrição auto-gerada.
@author flavio.martins
@since 12/12/2022
@version 1.0
@return lRet
@param oMdl, cCodSer
@type function
/*/
Static Function VldLocalIni(oMdl, cCodSer)
Local lRet       := .T.
Local cAgencia   := ""
Local cCodLoc    := ""
Local nX         := 0
Local nFirstLine := 0
Local nLastLine  := 0

For nX := 1 To oMdl:Length()

    If !oMdl:IsDeleted(nX)

        If nFirstLine == 0
            nFirstLine := nX
        Endif 

        If nX < oMdl:GetLine()
            nLastLine := nX
        Endif

    Endif

Next

If oMdl:GetLine() == nFirstLine

    cAgencia := oMdl:GetModel():GetValue('MASTERG99', 'G99_CODEMI')

    cCodLoc := Posicione('GI6',1,xFilial('GI6')+cAgencia,"GI6_LOCALI")

    lRet := VldLocAge(cCodLoc, cCodSer, "INICIAL")
    
Else

    cCodLoc := oMdl:GetValue("G9Q_LOCFIM", nLastLine)

    lRet := VldLocAge(cCodLoc, cCodSer, "INICIAL")

Endif

Return lRet

/*/{Protheus.doc} VldLocAge(cCodLoc, cCodSer, cTpLocal)
//TODO Descrição auto-gerada.
@author flavio.martins
@since 12/12/2022
@version 1.0
@return lRet
@param cAgencia, cCodSer, cTpLocal
@type function
/*/
Static Function VldLocAge(cCodLoc, cCodSer, cTpLocal)
Local lRet      := .T.
Local cAliasTmp := GetNextAlias()
Local cQuery    := ""
Local cField    := ""

dbSelectArea('GI6')

If cTpLocal == 'INICIAL'
    cField := "% GIE_IDLOCP AS IDLOCAL %"
    cQuery := "%  AND GIE_IDLOCP = '" + cCodLoc + "' %"
Else 
    cField := "% GIE_IDLOCD AS IDLOCAL %"
    cQuery := "%  AND GIE_IDLOCD = '" + cCodLoc + "' %"
Endif

BeginSql Alias cAliasTmp

    SELECT %Exp:cField%
    FROM %Table:GIE%
    WHERE GIE_FILIAL = %xFilial:GIE%
      AND GIE_CODGID = %Exp:cCodSer%
      AND GIE_HIST = '2'
      %Exp:cQuery%
      AND %NotDel%

EndSql

lRet := !Empty((cAliasTmp)->IDLOCAL)

(cAliasTmp)->(dbCloseArea())

Return lRet

/*/{Protheus.doc} SetLocal(oMdl)
//TODO Descrição auto-gerada.
@author flavio.martins
@since 12/12/2022
@version 1.0
@return Nil
@param oMdl
@type function
/*/
Static Function SetLocal(oMdl)
Local cCodSer    := oMdl:GetValue("G9Q_SERVIC")
Local cAgeEmi    := oMdl:GetModel():GetValue('MASTERG99', 'G99_CODEMI')
Local cAgeRec    := oMdl:GetModel():GetValue('MASTERG99', 'G99_CODREC')
Local cLocIni    := ""
Local cLocFim    := ""
Local nFirstLine := 0
Local nLastLine  := 0
Local nX         := 0

For nX := 1 To oMdl:Length()

    If !oMdl:IsDeleted(nX)

        If nFirstLine == 0
            nFirstLine := nX
        Endif

        If nX < oMdl:GetLine()
            nLastLine := nX
        Endif

    Endif

Next

If oMdl:GetLine() == nFirstLine

    dbSelectArea('GI6')
    cLocIni := Posicione('GI6',1,xFilial('GI6')+cAgeEmi,"GI6_LOCALI")

    oMdl:SetValue("G9Q_LOCINI", cLocIni)
    oMdl:SetValue("G9Q_DLOCIN", Posicione('GI1',1,xFilial('GI1')+oMdl:GetValue("G9Q_LOCINI"),'GI1_DESCRI'))    
    oMdl:SetValue("G9Q_AGEORI", GetAgOriDes(oMdl,"INICIO")) 
    
Else

    oMdl:SetValue("G9Q_LOCINI", oMdl:GetValue("G9Q_LOCFIM", nLastLine))
    oMdl:SetValue("G9Q_DLOCIN", Posicione('GI1',1,xFilial('GI1')+oMdl:GetValue("G9Q_LOCINI"),'GI1_DESCRI'))    
    oMdl:SetValue("G9Q_AGEORI", GetAgOriDes(oMdl,"INICIO")) 
   
Endif

cLocFim := Posicione('GI6',1,xFilial('GI6')+cAgeRec,"GI6_LOCALI")

If !Empty(cAgeRec) .And. VldLocAge(cLocFim, cCodSer, "FINAL")
    oMdl:SetValue("G9Q_LOCFIM", cLocFim)
    oMdl:SetValue("G9Q_DLOCFI", Posicione('GI1',1,xFilial('GI1')+oMdl:GetValue("G9Q_LOCFIM"),'GI1_DESCRI'))    
    oMdl:SetValue("G9Q_AGEDES", GetAgOriDes(oMdl,"FIM"))
Endif

Return

//------------------------------------------------------------------------------
/*/{Protheus.doc} HasChvNFe
Verifica se existe a chave e nota registrado em base 
@type Function
@author Fernando Radu Muscalu
@since 31/01/2023
/*/
//------------------------------------------------------------------------------
Static Function HasChvNFe(cIdChave,oSub,cMsgErro,cMsgSol)
    
    Local aSeek     := {}
    Local aResult    := {{"G9R_CODIGO","G9R_NOTA","G9R_SERNOT"}}
    
    Local cDoc      := ""
    Local cSerie    := ""
    
    Local nI        := 0
    Local nLine     := 0
    Local _nx       := 1

    Local lHasChvNFe:= .f.
    
    Default cIdChave := ""
 
    If ( VldDicG9R() )
   
        If ( !Empty(cIdChave) )

            If ( VldFormChv(cIdChave,@cMsgErro,@cMsgSol) )

                aSeek := GetDocSerie(cIdChave)

                cDoc    := aSeek[1]
                cSerie  := aSeek[2]

                aSeek := {}
                
                aAdd(aSeek,{"G9R_NFEID",cIdChave})
                
                If ( !Empty(cDoc) )
                    aAdd(aSeek,{"G9R_NOTA",cDoc})
                EndIf

                If ( !Empty(cSerie) )
                    aAdd(aSeek,{"G9R_SERNOT",cSerie})
                EndIf

                lHasChvNFe := GTPSeekTable("G9R",aSeek,aResult)

                nLine := oSub:GetLine()
                
                //senão achou em base, pesquisa no grid
                If ( !lHasChvNFe )

                    If ( nLine > 1 )

                        for _nx := 1 to nLine-1
                            oSub:GoLine(_nx)

                            If ALLTRIM(oSub:GetValue("G9R_NFEID")) == ALLTRIM(aSeek[1][2])
                                lHasChvNFe := .T.
                                nI := _nx
                                Exit
                            Endif

                        Next

                        oSub:GoLine(nLine)

                        If ( lHasChvNFe )

                            cMsgErro    := STR0170 + alltrim(cIdChave) + ", "  //"A chave digitada, "
                            cMsgErro    += STR0171  //"juntamente com o documento e série, "
                            cMsgErro    += Alltrim(cDoc) + " e " + Alltrim(cSerie) + STR0172 //" (respectivamente), "
                            cMsgErro    += STR0173 + cValToChar(nI)    //"já foram utilzados no item declarado da linha "

                            cMsgSol     := STR0174   //"Digite outros valores para a chave eletrônica, nro de documento e série."
                            
                        EndIf

                        oSub:GoLine(nLine)
                        
                    EndIf
            
                Else

                    If ( lHasChvNFe .And. Len(aResult) > 1 )
                    
                        cMsgErro    := STR0170 + alltrim(cIdChave) + ", " //"A chave digitada, "
                        cMsgErro    += STR0171   //"juntamente com o documento e série, "
                        cMsgErro    += Alltrim(cDoc) + " e " + Alltrim(cSerie) + STR0172 //" (respectivamente), "
                        cMsgErro    += STR0175 + Alltrim(aResult[2,1]) //"já foram utilzados no CTe "

                        cMsgSol     := STR0174  //"Digite outros valores para a chave eletrônica, nro de documento e série."

                    EndIf

                EndIf
 
            Else
                lHasChvNFe := .T.
            EndIf

        EndIf

    EndIf

    Return(lHasChvNFe)   


//------------------------------------------------------------------------------
/*/{Protheus.doc} GetDocSerie
retorna array com o nro do documento e série
@type Static Function
@author Fernando Radu Muscalu
@since 31/01/2023
/*/
//------------------------------------------------------------------------------
Static Function GetDocSerie(cChaveNFe)

    Local cDocNum   := ""
    Local cSerie    := ""

    If ( !Empty(cChaveNFe) )
        cDocNum :=  SubStr(cChaveNFe, 26, 9)    //Nro documento fiscal
        cSerie :=  PadR(cValToChar( Val( SubStr(cChaveNFe, 23, 3) ) ), 3)// serie do documento fiscal
    EndIf

Return({cDocNum,cSerie})

//------------------------------------------------------------------------------
/*/{Protheus.doc} VldDicG9R
Função responsavel pela validação dos novos campo da tabela G9R
@type Static Function
@author Fernando Radu Muscalu
@since 01/02/2023
@version 1.0
@param , character, (Descrição do parâmetro)
@return oBrowse, retorna o objeto de browse
@example
(examples)
@see (links_or_references)
/*/
//------------------------------------------------------------------------------
Static function VldDicG9R()

    Local aFldsG9R  := {"G9R_NFEID","G9R_NOTA","G9R_SERNOT","G9R_DTNOTA","G9R_VLNOTA"}
    
    Local nI        := 0

    Local lValid    :=  GTPxVldDic("G9R",aFldsG9R,.F.)  //valida se existe dicionário

    Local oStruct

    If ( lValid )
        //valida se existe na esrutura de modelo de dados
        oStruct := FWFormStruct(1,"G9R")

        For nI := 1 to LEN(aFldsG9R)
            
            lValid := IIf( ValType(oStruct) == "O", oStruct:HasField(aFldsG9R[nI]), .f.)

            If ( !lValid )
                Exit
            EndIf

        Next nI

    EndIf

Return(lValid)

//------------------------------------------------------------------------------
/*/{Protheus.doc} VldFormChv
Função responsavel pela validação do formato da chave
@type Static Function
@author Fernando Radu Muscalu
@since 01/02/2023
@version 1.0
@param , character, (Descrição do parâmetro)
@return oBrowse, retorna o objeto de browse
@example
(examples)
@see (links_or_references)
/*/
//------------------------------------------------------------------------------
Static Function VldFormChv(cIdChave,cMsgErro,cMsgSol)

    Local lRet := .T.
    
    If ( Len(Alltrim(cIdChave)) == 44 )
        
        If ( !IsNumeric(cIdChave) )
        
            lRet := .f.

            cMsgErro    := STR0176  //"A chave digitada possui caracteres alfanuméricos."
            cMsgSol     := STR0177  //"Somente números podem ser digitados para a chave."

        EndIf

    Else

        lRet := .f.

        cMsgErro    := STR0178  //"Tamanho da chave é diferente de 44 caracteres."
        cMsgSol     := STR0179  //"Reveja a chave digitada. Ela tem de possuir 44 caracteres."
    
    EndIf

Return(lRet)

//------------------------------------------------------------------------------
/* /{Protheus.doc} DeletaPV
@type Static Function
@author Mick William da Silva
@since 13/05/2024
@version 1.0
@param  aRetPV  , Array     , Array com a Filial + Pedido de Vendas + Código Cliente e Loja para exclusão  
@param  cMsgErro, Caracter  , Retorna a Mensage de Erro
@return lRet    , Lógico    , .T. quando o processo ocorreu corretamente, senão .F. 
/*/
//------------------------------------------------------------------------------
Static Function DeletaPV(aRetPV,cMsgErro)

    Local lRet      := .T.
    Local aCabec    := {}
    Local aItens    := {}

    Private lMsErroAuto    := .F.
    Private lAutoErrNoFile := .F.    

    DbSelectArea("SC5")
    
    SC5->(DbSetOrder(3)) //C5_FILIAL+C5_CLIENTE+C5_LOJACLI+C5_NUM
    If SC5->(Dbseek(aRetPV[1][1] + aRetPV[1][3] + aRetPV[1][4] + aRetPV[1][2] ))
        aadd(aCabec, {"C5_NUM",     SC5->C5_NUM     ,   Nil} )
        aadd(aCabec, {"C5_TIPO",    SC5->C5_TIPO    ,   Nil} )
        aadd(aCabec, {"C5_CLIENTE", SC5->C5_CLIENTE ,   Nil} )
        aadd(aCabec, {"C5_LOJACLI", SC5->C5_LOJACLI ,   Nil} )
        aadd(aCabec, {"C5_LOJAENT", SC5->C5_LOJAENT ,   Nil} )
        aadd(aCabec, {"C5_CONDPAG", SC5->C5_CONDPAG ,   Nil} )      

        DbSelectArea("SC6")
        SC6->(DbGoTop() )
        SC6->(DbSetOrder(1)) //C6_FILIAL, C6_NUM, C6_ITEM, C6_PRODUTO, R_E_C_N_O_, D_E_L_E_T_
        SC6->(Dbseek(SC5->C5_FILIAL + SC5->C5_NUM ))                         
        While !SC6->(EOF()) .AND. SC6->C6_FILIAL == SC5->C5_FILIAL .AND. SC6->C6_NUM == SC5->C5_NUM
            MaAvalSC6("SC6",4,"SC5",Nil,Nil,Nil ,Nil,Nil,Nil) //Estorna o Pedido de Vendas
         SC6->( dbSkip() )
        EndDo

        MSExecAuto({|a, b, c| MATA410(a, b, c)}, aCabec, aItens, 5)                

        If lMsErroAuto
            lRet    := .F.
            MostraErro()
            cMsgErro:=STR0202 //"Não foi possivel excluir o pedido de vendas"
        EndIf
        
    EndIf

Return lRet 

/*/{Protheus.doc} GA801Calc
(long_description)
@type function
@author flavio.oliveira
@since 07/08/2024
@version 1.0
@return ${return}, ${return_description}
@example
(examples)
@see (links_or_references)
/*/
Static Function GA801Calc(oView)

    Local oModel    	:= oView:GetModel()
    Local oMdlCab	    := oModel:GetModel('MASTERG99')
    Local oStruCab		:= FWFormStruct(2, "G99")  //    Local oStruCab		:= oMdlCab:GetStruct() 
    Local oMdlDG9R		:= oModel:GetModel('DETAILG9R')
    Local oStrG9R       := FWFormStruct(2, "G9R")
    Local oMdlDG9Q		:= oModel:GetModel('DETAILG9Q')
    Local oStrG9Q       := FWFormStruct(2, "G9Q")
//    Local oMdlDG9P		:= oModel:GetModel('DETAILG9P')
//    Local oStrG9P       := FWFormStruct(2, "G9P")
//    Local oMdlDGIR		:= oModel:GetModel('DETAILGIR')
//    Local oStrGIR       := FWFormStruct(2, "GIR")
//    Local oMdlDGIY		:= oModel:GetModel('DETAILGIY')
//    Local oStrGIY       := FWFormStruct(2, "GIY")

    Local oWorkSheet	:= FWUIWorkSheet():New(/*oWinPlanilha*/,.F. , /*WS_ROWS*/, /*WS_COLS*/)
    Local nCell			:= 0
    Local n1			:= 0
    Local nValue		:= 0

    Local lRet			:= .T.
    Local cTabFret      :=  ""
    Local cXmlPla       :=  ""
    Local cTpCust       :=  ""
    Local nValorser     :=   0

    oWorkSheet:lShow    := .F.
    If G99->(FieldPos('G99_KGFRET')) > 0
        oMdlCab:SetValue("G99_VALOR",RetTabFrt(oMdlCab:GetValue('G99_TABFRE'), oMdlCab:GetValue('G99_KMFRET'), oMdlCab:GetValue('G99_KGFRET'), (RetTpFrete(oModel)) ))
    Else
        oMdlCab:SetValue("G99_VALOR",RetTabFrt(oMdlCab:GetValue('G99_TABFRE'), oMdlCab:GetValue('G99_KMFRET'), 0, (RetTpFrete(oModel)) ))
    Endif
    cTabFret            :=  oMdlCab:GetValue("G99_TABFRE")
    nValorser           :=  oMdlCab:GetValue("G99_VALOR")

    If !Empty(cTabFret)

        G5J->(DbSetOrder(1))
        If (G5J->(DbSeek(xFilial("G5J") + cTabFret)))
            cXmlPla :=  GetAdvFval("GIM","GIM_PLAN",xFilial("GIM")+G5J->G5J_GIMCOD,1)
            cTpCust :=  GetAdvFval("GIM","GIM_TPCUST",xFilial("GIM")+G5J->G5J_GIMCOD,1)

            lPlaCust    :=  .T. //Validar a variável Caso não tenha sido executado na Inclusão e/ou alteração NÃO deixar gravar
                                //Coloca uma pergunta se aciona ou não a planilha

            oWorkSheet:LoadXmlModel(cXmlPla)

            For nCell := 2 To oWorkSheet:NTOTALLINES			
			    If oWorkSheet:CellExists("A"+ cValTochar(nCell))
				    cCellValue	:= oWorkSheet:GetCellValue("A"+ cValTochar(nCell))
				    cCellValue	:= "G99"+SubStr(cCellValue,4)
				    If oStruCab:HasField(cCellValue)
					    If Valtype(oMdlCab:GetValue( cCellValue  )) == "N"
						    lRet := oWorkSheet:SetCellValue("C" + cValToChar(nCell), oMdlCab:GetValue(cCellValue))
					    Else
						    lRet := oWorkSheet:SetCellValue("C" + cValToChar(nCell), cValToChar(oMdlCab:GetValue(cCellValue)))
					    Endif
				    Endif
			    EndIf
		    Next

            For n1 := 1 to oMdlDG9Q:Length()
	            If !oMdlDG9Q:IsDeleted(n1)
		            oMdlDG9Q:GoLine(n1)
            		For nCell := 2 To oWorkSheet:NTOTALLINES			
			            If oWorkSheet:CellExists("A"+ cValTochar(nCell))
				            cCellValue	:= oWorkSheet:GetCellValue("A"+ cValTochar(nCell))
				            cCellValue	:= "G9Q"+SubStr(cCellValue,4)
				            If oStrG9Q:HasField(cCellValue)
					            If Valtype(oMdlDG9Q:GetValue( cCellValue  )) == "N"
						            lRet := oWorkSheet:SetCellValue("C" + cValToChar(nCell), oMdlDG9Q:GetValue(cCellValue))
					            Else
						            lRet := oWorkSheet:SetCellValue("C" + cValToChar(nCell), cValToChar(oMdlDG9Q:GetValue(cCellValue)))
					            Endif
				            Endif
			            EndIf
		            Next
	            Endif
            Next

            For n1 := 1 to oMdlDG9R:Length()
	            If !oMdlDG9R:IsDeleted(n1)
		            oMdlDG9R:GoLine(n1)
            		For nCell := 2 To oWorkSheet:NTOTALLINES			
			            If oWorkSheet:CellExists("A"+ cValTochar(nCell))
				            cCellValue	:= oWorkSheet:GetCellValue("A"+ cValTochar(nCell))
				            cCellValue	:= "G9R"+SubStr(cCellValue,4)
				            If oStrG9R:HasField(cCellValue)
					            If Valtype(oMdlDG9R:GetValue( cCellValue  )) == "N"
						            lRet := oWorkSheet:SetCellValue("C" + cValToChar(nCell), oMdlDG9R:GetValue(cCellValue))
					            Else
						            lRet := oWorkSheet:SetCellValue("C" + cValToChar(nCell), cValToChar(oMdlDG9R:GetValue(cCellValue)))
					            Endif
				            Endif
			            EndIf
		            Next
	            Endif
            Next

		    If oWorkSheet:CellExists("D2") 	
			    nValue := oWorkSheet:GetCellValue("D2")
		    EndIf

		    oMdlCab:SetValue('G99_VALOR', nValue) // + nValorser)
            If G99->(FieldPos('G99_VLRPLN')) > 0
                oMdlCab:SetValue('G99_VLRPLN', nValue)
            Endif
		    oWorkSheet:Close()

        EndIf
    
    Endif

    GTPDestroy(oWorkSheet)

Return

//------------------------------------------------------------------------------
/* /{Protheus.doc} DeletaTit
@type Static Function
@author João Pires
@since 14/03/2025
@version 1.0
@param  cMsgErro, Caracter  , Retorna a Mensage de Erro
@return lRet    , Lógico    , .T. quando o processo ocorreu corretamente, senão .F. 
/*/
//------------------------------------------------------------------------------
Static Function DeletaTit(oModel,cMsgErro)
    Local lRet      := .T.    
    Local aTitSE1   := {}
    Local aTitSE2   := {}
    Local nX        := 1    
    Local cChvTit   := ""
    Local cTipoTit  := ""
    Local cNumero   := ""
    Local oMdlGIR   := oModel:GetModel("DETAILGIR")
    
    DBSelectArea("SE1")
    SE1->(DBSetOrder(1)) //E1_FILIAL+E1_PREFIXO+E1_NUM+E1_PARCELA+E1_TIPO

    DBSelectArea("SE2")
    SE2->(DBSetOrder(1)) //E2_FILIAL+E2_PREFIXO+E2_NUM+E2_PARCELA+E2_TIPO+E2_FORNECE+E2_LOJA

    If oModel:GetOperation() == MODEL_OPERATION_UPDATE
        cNumero := G99->G99_NUMDOC
    Else
        cNumero := oModel:GetModel("MASTERG99"):GetValue("G99_NUMDOC")    
    EndIf

    Begin transaction
        For nX := 1 to oMdlGIR:Length()
            oMdlGIR:GoLine(nX)            

            cChvTit := oMdlGIR:GetValue("GIR_TITTEF")                                     

            If !Empty(cChvTit) .AND. SE1->(DBSeek(cChvTit))
                cChvTit := SE1->(E1_FILIAL+E1_NUM+E1_PREFIXO+E1_TIPO+E1_CLIENTE+E1_LOJA)

                While lRet .AND. SE1->(!Eof()) .AND. SE1->(E1_FILIAL+E1_NUM+E1_PREFIXO+E1_TIPO+E1_CLIENTE+E1_LOJA) == cChvTit

                    If SE1->E1_SALDO < SE1->E1_VALOR
                        lRet := .F.
                        cMsgErro := STR0207 //"Não foi possível excluir o título de cartão. Título já baixado"
                    Else
                        aTitSE1	:= {{"E1_FILIAL"	, SE1->E1_FILIAL 		,Nil},;
                                {"E1_PREFIXO"	, SE1->E1_PREFIXO 		,Nil},;
                                {"E1_NUM"		, SE1->E1_NUM       	,Nil},;
                                {"E1_PARCELA"	, SE1->E1_PARCELA  		,Nil},;
                                {"E1_TIPO"	    , SE1->E1_TIPO     		,Nil},;
                                {"E1_CLIENTE"   , SE1->E1_CLIENTE      	,Nil},;
                                {"E1_LOJA"		, SE1->E1_LOJA			,Nil},;
                                {"E1_ORIGEM"	, SE1->E1_ORIGEM		,Nil},;
                                {"AUTHIST"	    , STR0208               ,Nil}} // "Exclusão de encomenda"
                    
                        lRet := GTPP004(aTitSE1,@cMsgErro,"CR")
                    Endif                                                   
                    
                    SE1->(DBSkip())
                Enddo
            Endif

            cTipoTit := IIF(oMdlGIR:GetValue('GIR_TPCART')=='1','CD ','CC ')
            
            IF lRet .AND. !EMPTY(oMdlGIR:GetValue("GIR_TITTEF")) .AND. SE2->(DBSeek(xFilial('SE2') + 'TEF' + cNumero + ' ' + cTipoTit))

                IF SE2->E2_SALDO < SE2->E2_VALOR
                    lRet := .F.
                    cMsgErro := STR0207 //"Não foi possível excluir o título de cartão. Título já baixado"
                ELSE
                    aTitSE2	:= {;
                                {"E2_FILIAL"	, SE2->E2_FILIAL 		,Nil},;
                                {"E2_PREFIXO"	, SE2->E2_PREFIXO 		,Nil},;
                                {"E2_NUM"		, SE2->E2_NUM       	,Nil},;
                                {"E2_PARCELA"	, SE2->E2_PARCELA  		,Nil},;
                                {"E2_TIPO"	    , SE2->E2_TIPO     		,Nil},;
                                {"E2_FORNECE"   , SE2->E2_FORNECE      	,Nil},;
                                {"E2_LOJA"		, SE2->E2_LOJA			,Nil}} 
                    
                    lRet := GTPP004(aTitSE2,@cMsgErro,"CP")
                ENDIF
            Endif

            If !lRet
                DisarmTransaction()
                Exit
            Endif

        Next nX
    End transaction

    SE1->(DBCloseArea())

Return lRet 
