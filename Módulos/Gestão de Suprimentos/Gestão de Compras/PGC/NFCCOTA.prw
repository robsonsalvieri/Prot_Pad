#INCLUDE "PROTHEUS.CH"
#INCLUDE "PARMTYPE.CH"
#INCLUDE "FWBROWSE.CH"
#INCLUDE "FWMVCDEF.CH"

Static _oHashCot	:= Nil

//-------------------------------------------------------------------
// Função principal que abre a tela
//-------------------------------------------------------------------
Function NFCCOTA()  
Return


//-------------------------------------------------------------------
/*/{Protheus.doc} MenuDef()
Menu Funcional da Rotina 

@author Ali Ahmad
@since 08/2025
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function MenuDef()   

Local aRotina := {}

ADD OPTION aRotina TITLE 'Visualizar' ACTION 'VIEWDEF.NFCCOTA' OPERATION 2 ACCESS 0

Return(aRotina) 


//-------------------------------------------------------------------
// Definição do Modelo (Model)
//-------------------------------------------------------------------
Static Function ModelDef()

    Local oStrDHU	:= FWFormStruct( 1, 'DHU' )
    Local oStrDHV	:= FWFormStruct( 1, 'DHV' )
    Local oStrSC8	:= NFCC8MD()
    Local oModel	:= nil
    Local bLoadFil 	:= {}
 
    _oHashCot	:= JsonObject():New()

    oModel  := MPFormModel():New('NFCCOTA')
    
    //Cabeçalho
    oModel:AddFields('DHUMASTER', , oStrDHU)

    //Itens
    oModel:AddGrid( 'DHVDETAIL', 'DHUMASTER', oStrDHV,,,,, )
    oModel:SetRelation('DHVDETAIL', { { 'DHV_FILIAL', 'fwxFilial("DHU")' }, { 'DHV_NUM', 'DHU_NUM' } }, DHV->(IndexKey(1)) ) // DHV_FILIAL, DHV_NUM

    //Cotações
    bLoadFil := {|| FilLstPro(oModel) }
    oModel:AddGrid( "SC8DETAIL", 'DHVDETAIL', oStrSC8,,,,, bLoadFil)
    oModel:GetModel( 'SC8DETAIL' ):SetDescription( 'Cotacao' ) 

    oModel:GetModel('DHVDETAIL'):SetOptional(.T.)
    oModel:GetModel('DHVDETAIL'):SetNoInsertLine(.T.)
    oModel:GetModel('DHVDETAIL'):SetNoDeleteLine(.T.)

    oModel:SetDescription("Analise Cotação NFC")
    oModel:GetModel('DHUMASTER'):SetDescription("Analise Cotação")
    
    oModel:SetPrimaryKey({'DHU_NUM'})

Return oModel

//-------------------------------------------------------------------
// Definição da View
//-------------------------------------------------------------------
Static Function ViewDef()

    Local oModel 	:= FWLoadModel('NFCCOTA')
    Local oStrDHU 	:= FWFormStruct( 2, 'DHU', {|cCampo| AllTrim(cCampo)$ "DHU_NUM|DHU_TPDOC|DHU_DTEMIS|DHU_AGPCOT|DHU_DTRCOT|DHU_QTDFOR|DHU_QTDPRO|DHU_CODCOM|DHU_COMPRA"} )  
    Local oStrDHV 	:= FWFormStruct( 2, 'DHV', {|cCampo| AllTrim(cCampo)$ "DHV_ITEM|DHV_CODPRO|DHV_QUANT|DHV_SALDO|DHV_UM|DHV_DATPRF"} )  
    Local oStrSC8	:= NFCC8VW()

    Local oView     := FWFormView():New()

    oView:SetModel(oModel)
    oView:AddField('VIEW_DHU', oStrDHU, 'DHUMASTER')
    oView:AddGrid( 'VIEW_DHV', oStrDHV, 'DHVDETAIL' )
    oView:AddGrid( 'VIEW_SC8', oStrSC8, 'SC8DETAIL' )

    oView:SetViewProperty("VIEW_DHV", "CHANGELINE", {{|oView| FilLstPro(oModel) }})

    oView:CreateHorizontalBox('SUPERIOR', 40)
    oView:CreateHorizontalBox('INFERIOR1', 30)
    oView:CreateHorizontalBox('INFERIOR2', 30)

    oView:SetOwnerView('VIEW_DHU', 'SUPERIOR')
    oView:SetOwnerView('VIEW_DHV', 'INFERIOR1')
    oView:SetOwnerView('VIEW_SC8', 'INFERIOR2')

Return oView


Static Function FilLstPro(oModel)

    Local oView	    := FwViewActive()
    Local cQuery    := ""
    Local oQuery    := Nil
    Local cAliasTmp := GetNextAlias()
    Local aCotac    := {}

    Local cNumCot  := ""
    Local cNumItem := ""

    Local cNumPro  := ""
    Local cFornece := ""
    Local cLoja    := ""
    Local cFornome := ""
    Local cEmissao := ""

    Default oModel := FwModelActive()

    oObjDHV := oModel:GetModel("DHVDETAIL")
    oObjSC8 := oModel:GetModel("SC8DETAIL")
    
    cNumCot  := oObjDHV:GetValue("DHV_NUM")
    cNumItem := oObjDHV:GetValue("DHV_ITEM")
    
    if _oHashCot[cNumCot+cNumItem] != Nil
		aCotac := aClone(_oHashCot[cNumCot+cNumItem])
    Else 
        oQuery := FWPreparedStatement():New()

        cQuery := " SELECT SC8.C8_NUMPRO, SC8.C8_ITEM, SC8.C8_PRODUTO, SC8.C8_FORNECE, SC8.C8_LOJA, SC8.C8_PRECO, SC8.C8_QUANT, SC8.C8_TOTAL, SC8.C8_FORNOME, SC8.C8_EMISSAO, "
        cQuery += " SCE.CE_QUANT, SCE.CE_FORNECE "
        cQuery += " FROM "+RetSqlName("SC8")+" SC8 "
        cQuery += " LEFT JOIN "
        cQuery += "    "+RetSqlName("SCE")+" SCE "
        cQuery += "    ON  SCE.CE_FILIAL = ? "
        cQuery += "    AND SCE.CE_NUMCOT = SC8.C8_NUM "
        cQuery += "    AND SCE.CE_ITEMCOT = SC8.C8_ITEM "
        cQuery += "    AND SCE.CE_PRODUTO = SC8.C8_PRODUTO "
        cQuery += "    AND SCE.CE_FORNECE = SC8.C8_FORNECE "
        cQuery += "    AND SCE.CE_LOJA = SC8.C8_LOJA "
        cQuery += "    AND SCE.CE_ITEMGRD = SC8.C8_ITEMGRD "
        cQuery += "    AND SCE.CE_NUMPRO = SC8.C8_NUMPRO "
        cQuery += "    AND SCE.D_E_L_E_T_ = ' ' "
        cQuery += " INNER JOIN ( "
        cQuery += "    SELECT C8_FORNECE, C8_LOJA, MAX(C8_NUMPRO) AS MAX_NUMPRO "
        cQuery += "    FROM "+RetSqlName("SC8")+" "
        cQuery += "    WHERE "
        cQuery += "        C8_FILIAL = ? AND "
        cQuery += "        C8_NUM = ? AND "
        cQuery += "        C8_ITEM = ? AND "
        cQuery += "        D_E_L_E_T_ = ' ' "
        cQuery += "    GROUP BY "
        cQuery += "        C8_FORNECE, C8_LOJA "
        cQuery += " ) Ultimas "
        cQuery += "    ON SC8.C8_FORNECE = Ultimas.C8_FORNECE "
        cQuery += "    AND SC8.C8_LOJA = Ultimas.C8_LOJA "
        cQuery += "    AND SC8.C8_NUMPRO = Ultimas.MAX_NUMPRO "
        cQuery += " WHERE "
        cQuery += "    SC8.C8_FILIAL = ? AND "
        cQuery += "    SC8.C8_NUM = ? AND "
        cQuery += "    SC8.C8_ITEM = ? AND "
        cQuery += "    SC8.D_E_L_E_T_ = ' ' "
        cQuery += "    ORDER BY SCE.CE_FORNECE DESC "

        oQuery:SetQuery(cQuery)
        oQuery:SetString(1, xFilial( "SCE" ))
        oQuery:SetString(2, xFilial( "SC8" ))
        oQuery:SetString(3, cNumCot)
        oQuery:SetString(4, cNumItem)
        oQuery:SetString(5, xFilial( "SC8" ))
        oQuery:SetString(6, cNumCot)
        oQuery:SetString(7, cNumItem)

        cAliasTmp := MpSysOpenQuery(oQuery:getFixQuery(), cAliasTmp)

        While ( cAliasTmp )->( !EoF() )

            cNumPro   := (cAliasTmp)->C8_NUMPRO
            cFornece  := (cAliasTmp)->C8_FORNECE
            cLoja     := (cAliasTmp)->C8_LOJA
            cFornome  := (cAliasTmp)->C8_FORNOME
            cPreco    := (cAliasTmp)->C8_PRECO
            cQuant    := (cAliasTmp)->C8_QUANT
            cTotal    := (cAliasTmp)->C8_TOTAL
            cEmissao  := SToD((cAliasTmp)->C8_EMISSAO)
            cQuantEnt := (cAliasTmp)->CE_QUANT
            cWinCot   := IIf(cQuantEnt > 0, "BR_VERDE", "BR_BRANCO")

            aadd(aCotac, {0, {cWinCot, cNumPro, cFornece, cLoja, cFornome, cPreco, cQuant, cTotal, cEmissao, cQuantEnt}})
            ( cAliasTmp )->( DbSkip() )
        End

        if (empty(aCotac))
            aAdd(aCotac,{0, {'', '', '', '', '', 0, 0, 0, dDatabase, 0}})
        endif

        _oHashCot[cNumCot+cNumItem] := aClone(aCotac)
        
        (cAliasTmp)->(dbCloseArea())
	    FreeObj(oQuery)
    EndIf

    NFCCRfSC8(oView)
Return aCotac


/*/{Protheus.doc} NFCCRfSC8
	Realiza refresh da view da tabela SC8 e do grid de impostos
@author ali.neto
@since 08/2025
@return logical, .T.
/*/
Function NFCCRfSC8(oView, cViewName)
	Default oView 		:= FwViewActive()
	Default cViewName	:= "VIEW_SC8" //padrão de atualização é sempre a SC8

	If ValType(oView) == "O" .And. oView:IsActive() //Atualizar a view
		oView:Refresh(cViewName)
	EndIf
Return .T.



/*/{Protheus.doc} NFCC8VW
	Função que realiza a montagem da struct dos dados da View, para montar o grid de Tributos Genérico.
@author ali.neto
@return oStructMn, objeto, objeto com a struct dos dados da grid, para a View.
@since 08/2025
/*/
static function NFCC8VW()
	Local oStrSC8	:= FWFormViewStruct():New()

	oStrSC8:AddField('LEGEND'       , '01', 'Vencedor'      , 'Vencedor'     ,, 'C' , '@BMP' , , , .F., , , , , , , , ) 
    oStrSC8:AddField('C8_NUMPRO'    , '02', 'Proposta'      , 'Proposta'     ,, 'C' , Nil , , , .F., , , , , , .T., , ) 
	oStrSC8:AddField('C8_FORNECE'   , '03', 'Fornecedor'    , 'Fornecedor'   ,, 'C' , Nil , , , .F., , , , , , .T., , )
	oStrSC8:AddField('C8_LOJA'      , '04', 'Loja'          , 'Loja'         ,, 'C' , Nil , , , .F., , , , , , .T., , )
	oStrSC8:AddField('C8_FORNOME'   , '05', 'Nome'          , 'Nome'         ,, 'C' , Nil , , , .F., , , , , , .T., , )
    oStrSC8:AddField('C8_PRECO'     , '06', 'Preco Unit.'   , 'Preco Unit.'  ,, 'N' , PesqPict("SC8","C8_PRECO") , , , .F., , , , , , .T., , )
    oStrSC8:AddField('C8_QUANT'     , '07', 'Quantidade'    , 'Quantidade'   ,, 'N' , PesqPict("SC8","C8_QUANT") , , , .F., , , , , , .T., , ) 
    oStrSC8:AddField('C8_TOTAL'     , '08', 'Total Item'    , 'Total Item'   ,, 'N' , PesqPict("SC8","C8_TOTAL") , , , .F., , , , , , .T., , )
    oStrSC8:AddField('C8_EMISSAO'   , '09', 'DT Emissao'    , 'DT Emissao'   ,, 'D' , PesqPict("SC8","C8_EMISSAO") , , , .F., , , , , , .T., , )
    oStrSC8:AddField('CE_QUANT'     , '10', 'Qtd. Entrega'  , 'Qtd. Entrega' ,, 'N' , PesqPict("SCE","CE_QUANT") , , , .F., , , , , , .T., , ) 
return oStrSC8


/*/{Protheus.doc} NFCC8MD
	Função que realiza a montagem da struct dos dados da Model, para montar o grid de Tributos Genérico.
@author ali.neto
@return oStructMn, objeto, objeto com a struct dos dados da grid, para a Model.
@since 08/2025
/*/
static function NFCC8MD()
	Local oStrSC8	:= FWFormModelStruct():New()

	Local aSzNumPro	:= TamSX3("C8_NUMPRO")
	Local aSzPreco	:= TamSX3("C8_PRECO")
    Local aSzQuant	:= TamSX3("C8_QUANT")
    Local aSzTotIt	:= TamSX3("C8_TOTAL")
    Local aSzFornec	:= TamSX3("C8_FORNECE")
	Local aSzLoja	:= TamSX3("C8_LOJA")
	Local aSzFNome	:= TamSX3("C8_FORNOME")
    Local aSzEmiss	:= TamSX3("C8_EMISSAO")
    Local aSzQtdEnt	:= TamSX3("CE_QUANT")

    oStrSC8:AddField('Vencedor'         , 'Vencedor'        , 'LEGEND'      , 'C', aSzNumPro[1] , aSzNumPro[2] , , Nil, {}, .F., , Nil, Nil, .T.)
	oStrSC8:AddField('Proposta'         , 'Proposta'        , 'C8_NUMPRO'   , 'C', aSzNumPro[1] , aSzNumPro[2], , Nil, {}, .F., , .F., .F., .T.) 
	oStrSC8:AddField('Fornecedor'       , 'Fornecedor'      , 'C8_FORNECE'  , 'C', aSzFornec[1] , aSzFornec[2], , Nil, {}, .F., , .F., .F., .T.) 
	oStrSC8:AddField('Loja'             , 'Loja'            , 'C8_LOJA'     , 'C', aSzLoja[1]   , aSzLoja[2], , Nil, {}, .F., , .F., .F., .T.) 
	oStrSC8:AddField('Nome'             , 'Nome'            , 'C8_FORNOME'  , 'C', aSzFNome[1]  , aSzFNome[2], , Nil, {}, .F., , .F., .F., .T.)
    oStrSC8:AddField('Preco Unit.'      , 'Preco Unit.'     , 'C8_PRECO'    , 'N', aSzPreco[1]  , aSzPreco[2], , Nil, {}, .F., , .F., .F., .T.)    
    oStrSC8:AddField('Quantidade'       , 'Quantidade'      , 'C8_QUANT'    , 'N', aSzQuant[1]  , aSzQuant[2], , Nil, {}, .F., , .F., .F., .T.) 
    oStrSC8:AddField('Total Item'       , 'Total Item'      , 'C8_TOTAL'    , 'N', aSzTotIt[1]  , aSzTotIt[2], , Nil, {}, .F., , .F., .F., .T.) 
    oStrSC8:AddField('DT Emissao'       , 'DT Emissao'      , 'C8_EMISSAO'  , 'D', aSzEmiss[1]  , aSzEmiss[2], , Nil, {}, .F., , .F., .F., .T.) 
    oStrSC8:AddField('Qtd. Entrega'     , 'Qtd. Entrega'    , 'CE_QUANT'    , 'N', aSzQtdEnt[1] , aSzQtdEnt[2], , Nil, {}, .F., , .F., .F., .T.) 

	FwFreeArray(aSzNumPro)
    FwFreeArray(aSzPreco)
    FwFreeArray(aSzQuant)
    FwFreeArray(aSzTotIt)
	FwFreeArray(aSzFornec)
	FwFreeArray(aSzLoja)
	FwFreeArray(aSzFNome)
    FwFreeArray(aSzEmiss)
    FwFreeArray(aSzQtdEnt)
return oStrSC8
