#Include "GTPA802.ch"
#INCLUDE "TOTVS.CH"
#INCLUDE "FWMVCDEF.CH"

Static cCampo802        := ""
Static cCodProd         := ""

//------------------------------------------------------------------------------
/*/{Protheus.doc} GTPA802
Tabela de frete - Encomendas
@type Function
@author henrique.toyada
@since 18/09/2019
@version 1.0
@param , character, (Descrição do parâmetro)
@return , return_description
@example
(examples)
@see (links_or_references)
/*/
//------------------------------------------------------------------------------
Function GTPA802()

Local oBrowse := FWMBrowse():New()

If ( !FindFunction("GTPHASACCESS") .Or.; 
	( FindFunction("GTPHASACCESS") .And. GTPHasAccess() ) ) 
    
    oBrowse := FWMBrowse():New()

    oBrowse:SetAlias('G5J')
    oBrowse:SetMenuDef('GTPA802')
    oBrowse:AddLegend('G5J_MSBLQL == "1"',"RED"  , STR0029 )//"Inativo"
    oBrowse:AddLegend('G5J_MSBLQL == "2"',"GREEN", STR0030 )//"Ativo"
    oBrowse:SetDescription(STR0001) //'Tabela de frete - Encomendas'

    oBrowse:Activate()

EndIf

Return()

//------------------------------------------------------------------------------
/*/{Protheus.doc} MenuDef
Função responsavel pela definição do menu
@type Static Function
@author 
@since 18/09/2019
@version 1.0
@return aRotina, retorna as opções do menu
/*/
//------------------------------------------------------------------------------
Static Function MenuDef()
Local aRotina := {} 

    ADD OPTION aRotina TITLE STR0003	    ACTION 'VIEWDEF.GTPA802' OPERATION OP_VISUALIZAR	ACCESS 0 // Visualizar //'Visualizar'
    ADD OPTION aRotina TITLE STR0004		ACTION 'VIEWDEF.GTPA802' OPERATION OP_INCLUIR		ACCESS 0 // Incluir //'Incluir'
    ADD OPTION aRotina TITLE STR0005		ACTION 'VIEWDEF.GTPA802' OPERATION OP_ALTERAR		ACCESS 0 // Alterar //'Alterar'
    ADD OPTION aRotina TITLE STR0006		ACTION 'VIEWDEF.GTPA802' OPERATION OP_EXCLUIR		ACCESS 0 // Excluir //'Excluir'

Return aRotina
//------------------------------------------------------------------------------
/*/{Protheus.doc} ModelDef
Função responsavel pela definição do modelo
@type Static Function
@author 
@since 18/09/2019
@version 1.0
@return oModel, retorna o Objeto do Menu
/*/
//------------------------------------------------------------------------------
Static Function ModelDef()
    Local oModel	:= nil
    Local oStrG5J	:= FWFormStruct(1,'G5J')
    Local oStrG9S	:= FWFormStruct(1,'G9S')
    Local oStrGZN	:= FWFormStruct(1,'GZN')
    Local oStrH66	:= nil
    Local bPosValid := {|oModel|PosValid(oModel)}
    Local bPreLine  := { |oModelG9S, nLine, cOperation, cField, uValue| GA802LnPre(oModelG9S, nLine, cOperation, cField, uValue)}

    If AliasInDic("H66")
        oStrH66	:= FWFormStruct(1,'H66')
    EndIf

    SetModelStruct(oStrG5J,oStrG9S,oStrGZN,oStrH66)

    oModel := MPFormModel():New('GTPA802', /*bPreValid*/, bPosValid, /*bCommit*/, /*bCancel*/ )

    oModel:AddFields('G5JMASTER',/*cOwner*/,oStrG5J)
    oModel:AddGrid('G9SDETAIL','G5JMASTER',oStrG9S, bPreLine, /*bLinePost*/, /*bPreVal*/,/*bPosVld*/,/*BLoad*/)
    oModel:AddGrid('GZNDETAIL','G5JMASTER',oStrGZN,/*bLinePre*/,/*bLinePost*/, /*bPreVal*/,/*bPosVld*/,/*BLoad*/)
    If AliasInDic("H66")
        oModel:AddGrid('H66DETAIL','G5JMASTER',oStrH66,/*bLinePre*/,{|oSubMdl,nLine| FiscalLine(oSubMdl,nLine)}, /*bPreVal*/,/*bPosVld*/,/*BLoad*/)
    EndIf
    
    oModel:SetRelation('G9SDETAIL',{{ 'G9S_FILIAL','XFILIAL("G5J")'},{'G9S_CODIGO','G5J_CODIGO' }},G9S->(IndexKey(1)))
    oModel:SetRelation('GZNDETAIL',{{ 'GZN_FILIAL','XFILIAL("G5J")'},{'GZN_CODIGO','G5J_CODIGO' }},GZN->(IndexKey(1)))
    If AliasInDic("H66")
        oModel:SetRelation('H66DETAIL',{{ 'H66_FILIAL','XFILIAL("H66")'},{'H66_CODG5J','G5J_CODIGO' }},H66->(IndexKey(1)))
    EndIf
    oModel:SetDescription(STR0001)//'Tabela de frete - Encomendas'

    oModel:GetModel('G5JMASTER'):SetDescription(STR0007) //'Tabela de frete'

    oModel:GetModel('G9SDETAIL'):SetDescription(STR0008) //'Faixas'
    oModel:GetModel('G9SDETAIL'):SetOptional(.T.)
    
    If G9S->(FieldPos('G9S_KGINI')) > 0 .And. G9S->(FieldPos('G9S_KGFIM')) > 0
        oModel:GetModel('G9SDETAIL'):SetUniqueLine( { 'G9S_KMINI','G9S_KMFIM','G9S_KGINI','G9S_KGFIM' } )
    Else
        oModel:GetModel('G9SDETAIL'):SetUniqueLine( { 'G9S_KMINI','G9S_KMFIM' } )    
    Endif

    oModel:GetModel('GZNDETAIL'):SetDescription(STR0009)	 //'Clientes'
    oModel:GetModel('GZNDETAIL'):SetOptional(.T.)
    oModel:GetModel('GZNDETAIL'):SetUniqueLine( { 'GZN_CLIENT','GZN_LOJA' } )

    If AliasInDic("H66")
        oModel:GetModel('H66DETAIL'):SetDescription("Regras Fiscais")	 //'Clientes'
        oModel:GetModel('H66DETAIL'):SetOptional(.T.)
    EndIf

    oModel:SetPrimaryKey({'G5J_FILIAL','G5J_CODIGO'})

Return oModel

/*/{Protheus.doc} SetModelStruct
//TODO Descrição auto-gerada.
@author henrique.toyada
@since 14/08/2019
@version 1.0
@return ${return}, ${return_description}
@param oStrG5J, object, descricao
@type function
/*/
Static Function SetModelStruct(oStrG5J,oStrG9S,oStrGZN,oStrH66)

    Local bTrig		:= {|oMdl,cField,uVal| FieldTrigger(oMdl,cField,uVal)}
    Local bFldVld	:= {|oMdl,cField,uVal,nLine,uOldValue| FieldValid(oMdl,cField,uVal,nLine,uOldValue)}
    Local bWhenVld	:= {|oMdl,cField,uVal,nLine,uOldValue| WhenValid(oMdl,cField,uVal,nLine,uOldValue)}

    oStrG5J:AddTrigger('G5J_PRODUT','G5J_PRODUT',{||.T.}, bTrig)
    oStrG5J:AddTrigger('G5J_TIPOKM','G5J_TIPOKM',{||.T.}, bTrig)
    oStrGZN:AddTrigger('GZN_CLIENT','GZN_CLIENT',{||.T.}, bTrig)

    oStrG5J:SetProperty('G5J_PRODUT', MODEL_FIELD_VALID	  ,bFldVld) 
    oStrG9S:SetProperty('G9S_KMFIM' , MODEL_FIELD_VALID	  ,bFldVld) 
    If G9S->(FieldPos('G9S_KGFIM')) > 0
        oStrG9S:SetProperty('G9S_KGFIM' , MODEL_FIELD_VALID	  ,bFldVld) 
    Endif
    oStrG5J:SetProperty('G5J_TIPOKM', MODEL_FIELD_WHEN	  ,bWhenVld) 

    If G5J->(FieldPos('G5J_STPLAN')) > 0
        oStrG5J:SetProperty('G5J_STPLAN', MODEL_FIELD_WHEN	  ,bWhenVld) 
    Endif

    If G5J->(FieldPos('G5J_GIMCOD')) > 0
        oStrG5J:SetProperty('G5J_GIMCOD', MODEL_FIELD_WHEN	  ,bWhenVld) 
    Endif

    //Fazer o controle da habilitacao dO Campo pela trigger obedecendo a seleção do Combo Tipo 'G5J_TIPOKM'
    oStrG9S:SetProperty('G9S_KMINI', MODEL_FIELD_WHEN	  ,bWhenVld) 
    oStrG9S:SetProperty('G9S_KMFIM', MODEL_FIELD_WHEN	  ,bWhenVld) 
    If G9S->(FieldPos('G9S_KGINI')) > 0
        oStrG9S:SetProperty('G9S_KGINI', MODEL_FIELD_WHEN	  ,bWhenVld)
    Endif
    If G9S->(FieldPos('G9S_KGFIM')) > 0
        oStrG9S:SetProperty('G9S_KGFIM', MODEL_FIELD_WHEN	  ,bWhenVld) 
    Endif
    If G5J->(FieldPos("G5J_TES")) > 0
        oStrG5J:SetProperty("G5J_TES", MODEL_FIELD_OBRIGAT, .T.)
    EndIf
    If G5J->(FieldPos("G5J_CFOP")) > 0
        oStrG5J:SetProperty("G5J_CFOP", MODEL_FIELD_OBRIGAT, .T.)
    EndIf

Return

/*/{Protheus.doc} PosValid
(long_description)
@type  Static Function
@author henrique.toyada
@since 25/09/2019
@version 1.0
@param oModel, objeto, param_descr
@return lRet, Lógico, Lógico
@example
(examples)
@see (links_or_references)
/*/
Static Function PosValid(oModel)

    Local   oMdlG5J	:= oModel:GetModel('G5JMASTER')
    Local   oMdlG9S	:= oModel:GetModel('G9SDETAIL')
    Local   lRet	  := .T.
    Local   lVal      := .F.
    Local   n1        := 0
    Local   nValor    := 0
    Local   nCnt      :=  0

    If oMdlG5J:GetValue("G5J_TIPOKM") == '3' .AND. oMdlG5J:GetValue("G5J_PECDCL") > 100
        lRet := .F.
        Help(,,STR0031,, STR0032, 1,0)//"Valor porcentagem"#"Valor maior que 100%"
    EndIf

    If G5J->(FieldPos("G5J_STPLAN")) > 0 .And. G5J->(FieldPos("G5J_GIMCOD")) > 0
        If oMdlG5J:GetValue("G5J_STPLAN") == '1' .And. Empty(oMdlG5J:GetValue("G5J_GIMCOD"))
            lRet := .F.
            Help(,,STR0039,, STR0038, 1,0)  //"Cód. Custo" //"Necessário informar o codigo da PLanilha"
        EndIf
    Endif

    If lRet .AND. oMdlG5J:GetValue("G5J_TIPOKM") == '4'
        If G9S->(FieldPos("G9S_KGINI")) > 0 .And. G9S->(FieldPos("G9S_KGFIM")) > 0
            For nCnt := 1 To oMdlG9S:Length()
                If !oMdlG9S:IsDeleted(nCnt)
                    If oMdlG9S:GetValue("G9S_KMINI", nCnt) = 0 .And. oMdlG9S:GetValue("G9S_KMFIM", nCnt) = 0 .And. oMdlG9S:GetValue("G9S_KGINI", nCnt) = 0 .And. oMdlG9S:GetValue("G9S_KGFIM", nCnt) = 0
                        lRet := .F.
                    EndIf
                    If oMdlG9S:GetValue("G9S_VALOR", nCnt) = 0 
                        lVal := .T.
                    EndIf
                Endif
            Next nCnt
            If !lRet 
                Help(,,STR0040,, STR0041, 1,0)  //"Range KM e KG" //"Necessário informar o Range de valores incial e final de KM e KG."
            EndIf
        Endif
    Endif

    If lRet .AND. (oMdlG5J:GetOperation() == MODEL_OPERATION_INSERT .OR. oMdlG5J:GetOperation() == MODEL_OPERATION_UPDATE)
        nValor := RetMaxVal()
        For n1	:= 1 to oMdlG9S:Length()
            If !oMdlG9S:IsDeleted(n1)
                oMdlG9S:GoLine(n1)
                If oMdlG5J:GetValue("G5J_TIPOKM") <> '3'
                    If oMdlG5J:GetValue("G5J_TIPOKM") <> '4'
                        If nValor == oMdlG9S:GetValue('G9S_KMFIM')
                            lRet := .T.
                        Else
                            lRet := .F.
                        EndIf
                    Endif
                    If oMdlG9S:GetValue('G9S_VALOR',n1) == 0
                        lVal := .T.
                    EndIf
                Else
                    oMdlG9S:Deleteline()
                EndIf
            Endif
        Next

        If !lRet
   	        Help(,,STR0010,, STR0011, 1,0)      //'ValidKm' //"Necessário ter uma valor final de KM de 9999.99" 
        Endif
    EndIf

    If lVal
        Help(,,STR0010,, STR0025, 1,0)//Existe valor zerado no range de KM
        If oMdlG5J:GetValue("G5J_TIPOKM") == '4'
            lRet := .F.
        Endif
    EndIf

Return lRet

/*/{Protheus.doc} GA802LnPre
(long_description)
@type  Static Function
@author user
@since 01/10/2019
@version version
@param oModelG9S, param_type, param_descr
@param nLine, param_type, param_descr
@param cOperation, param_type, param_descr
@param cField, param_type, param_descr
@param uValue, param_type, param_descr
@return lRet, return_type, return_description
@example
(examples)
@see (links_or_references)
/*/
Static Function GA802LnPre(oModelG9S, nLine, cOperation, cField, uValue)

    Local   lRet        := .T.
    Local   oMdl   	    := FwModelActive()
    Local   oMdlG5J	    := oMdl:GetModel('G5JMASTER')
    Local   oModelg99   := oModelG9S:GetModel("G5JMASTER")
    Local   cCbBox      := oMdlG5J:GetValue('G5J_TIPOKM')// 1=Por Km;2=Intervalo de Km;3=Per Declaração;4=Intervalo de Km|Kg    

    IF (cOperation == "DELETE") .AND. !IsInCallStack("ValTrig")
        If nLine != oModelG9S:Length()  .And. cCbBox <> '4'
            lRet := .F.
		    Help(,,STR0010,, STR0013, 1,0)  //"Só pode ser excluido a ultima linha."
        EndIf

    ELSEIF (cOperation == "UNDELETE")  .AND. !IsInCallStack("ValTrig")
        If nLine != oModelG9S:Length()
            lRet := .F.
        EndIf

    ELSEIF (cOperation == "SETVALUE" .AND. cField == "G9S_VALOR") .AND. !IsInCallStack("ValTrig")
        If uValue == 0
            lRet := MSGYESNO( STR0014, STR0010 )    //"Valor zerado, deseja continuar?" //'ValidKm'
        EndIf

    ELSEIF (cOperation == "ADDLINE") .AND. !IsInCallStack("ValTrig")
        If oModelG9S:GETVALUE("G9S_KMFIM") == RetMaxVal() .AND. oModelg99:GETVALUE("G5J_TIPOKM") <> '3'
            lRet := .F.
            Help(,,STR0010,, STR0015, 1,0)  //'ValidKm' //"Ultima linha com valor maximo"
        EndIf
    ENDIF

Return lRet

/*/{Protheus.doc} RetMaxVal
(long_description)
@type  Static Function
@author user
@since 25/09/2019
@version version
@return nValor, numeric, return_description
@example
(examples)
@see (links_or_references)
/*/
Static Function RetMaxVal()
    
    Local n1     := 0
    Local nValor := 0

    For n1 := 1 To TAMSX3('G9S_KMFIM')[1]
        If nValor == 0
            nValor += 9
        Else
            nValor += 9 * val('1' + strzero(0,n1-1))
        EndIf
    Next

    nValor := VAL(STRTRAN(cvaltochar(nValor),"9",".",TAMSX3('G9S_KMFIM')[1] - TAMSX3('G9S_KMFIM')[2],1))

Return nValor

/*/{Protheus.doc} FieldTrigger
//TODO Descrição auto-gerada.
@author henrique.toyada
@since 14/08/2019
@version 1.0
@return ${return}, ${return_description}
@param oMdl, object, descricao
@param cField, characters, descricao
@param uVal, undefined, descricao
@type function
/*/
Static Function FieldTrigger(oMdl,cField,uVal)
Local uRet   := ""
Do Case
	Case cField == 'G5J_PRODUT'
        cCodProd    := uVal
        uRet := POSICIONE("SB1",1,XFILIAL("SB1") + uVal,"B1_DESC")
        oMdl:SetValue('G5J_DSCPRD',uRet)
    Case cField == 'GZN_CLIENT'
        oMdl:SetValue('GZN_LOJA',POSICIONE("SA1",1,XFILIAL("SA1") + uVal,"A1_LOJA"))
        oMdl:SetValue('GZN_NOME',POSICIONE("SA1",1,XFILIAL("SA1") + uVal,"A1_NOME"))
    Case cField == 'G5J_TIPOKM'
    	ValTrig(oMdl, cField)
EndCase

Return uVal

//------------------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
Função responsavel pela definição da view
@type Static Function
@author henrique.toyada
@since 18/09/2019
@version 1.0
@return oView, retorna o Objeto da View
/*/
//------------------------------------------------------------------------------
Static Function ViewDef()

    Local oView	  := FWFormView():New()
    Local oModel  := FwLoadModel('GTPA802')
    Local oStrG5J := FWFormStruct(2, 'G5J')
    Local oStrG9S := FWFormStruct(2, 'G9S')
    Local oStrGZN := FWFormStruct(2, 'GZN')
    Local oStrH66 := NIL

    If AliasInDic("H66")
        oStrH66 := FWFormStruct(2, 'H66')
    EndIf

    SetViewStruct(oStrG5J,oStrG9S,oStrGZN,oStrH66)

    oView:SetModel(oModel)

    oView:AddField('VIEW_G5J',oStrG5J,'G5JMASTER')
    oView:AddGrid('GRID_G9S' ,oStrG9S,'G9SDETAIL')
    oView:AddGrid('GRID_GZN' ,oStrGZN,'GZNDETAIL')
    If AliasInDic("H66")
        oView:AddGrid('GRID_H66' ,oStrH66,'H66DETAIL')
    EndIf
    oView:CreateHorizontalBox('UPPER', 40)
    oView:CreateHorizontalBox('BOTTOM', 60)
    // oView:CreateHorizontalBox('FOOTER', 30)

    oView:CreateFolder( "PASTA", "BOTTOM" )
    oView:AddSheet( "PASTA", "ABA01", "Regras de Frete")
    oView:AddSheet( "PASTA", "ABA02", "Regras Fiscais")

    oView:CreateHorizontalBox('G9SHORIZONTAL', 50,,, 'PASTA', 'ABA01' )
    oView:CreateHorizontalBox('GZNHORIZONTAL', 50,,, 'PASTA', 'ABA01' )
    If AliasInDic("H66")
        oView:CreateHorizontalBox( 'H66HORIZONTAL', 100,,, 'PASTA', 'ABA02' ) 
    EndIf
    oView:SetOwnerView('VIEW_G5J','UPPER')
    oView:SetOwnerView('GRID_G9S','G9SHORIZONTAL')
    oView:SetOwnerView('GRID_GZN','GZNHORIZONTAL')
    If AliasInDic("H66")
        oView:SetOwnerView('GRID_H66','H66HORIZONTAL')
    EndIf
    oView:AddIncrementField("GRID_G9S", "G9S_SEQ")
    oView:AddIncrementField("GRID_GZN", "GZN_SEQ")

    oView:SetDescription(STR0001)//Tabela de frete - Encomendas

Return oView

/*/{Protheus.doc} SetViewStruct
//TODO Descrição auto-gerada.
@author henrique.toyada
@since 14/08/2019
@version 1.0
@return ${return}, ${return_description}
@param oStruG56, object, descricao
@type function
/*/
Static Function SetViewStruct(oStrG5J,oStrG9S,oStrGZN,oStrH66)

    oStrG5J:AddGroup( "CODIGO", "", "" , 1 )

    oStrG5J:SetProperty("G5J_CODIGO" , MVC_VIEW_GROUP_NUMBER, "CODIGO" )
    oStrG5J:SetProperty("G5J_DESCRI" , MVC_VIEW_GROUP_NUMBER, "CODIGO" )

    oStrG5J:AddGroup( "PRODUTO", "", "" , 1 )
    oStrG5J:SetProperty("G5J_PRODUT" , MVC_VIEW_GROUP_NUMBER, "PRODUTO" )
    oStrG5J:SetProperty("G5J_DSCPRD" , MVC_VIEW_GROUP_NUMBER, "PRODUTO" )

    oStrG5J:AddGroup( "COMBO", "", "" , 1 )
    oStrG5J:SetProperty("G5J_TIPOKM" , MVC_VIEW_GROUP_NUMBER, "COMBO" )
    oStrG5J:SetProperty("G5J_PECDCL" , MVC_VIEW_GROUP_NUMBER, "COMBO" )
    oStrG5J:SetProperty("G5J_MSBLQL" , MVC_VIEW_GROUP_NUMBER, "COMBO" )

    If G5J->(FieldPos("G5J_STPLAN")) > 0 .And. G5J->(FieldPos("G5J_GIMCOD")) > 0
        oStrG5J:AddGroup( "PLANILHA", "", "" , 1 )
        oStrG5J:SetProperty("G5J_STPLAN" , MVC_VIEW_GROUP_NUMBER, "PLANILHA" )
        oStrG5J:SetProperty("G5J_GIMCOD" , MVC_VIEW_GROUP_NUMBER, "PLANILHA" )
    Endif

    oStrG5J:RemoveField("G5J_VLFRET")
    oStrG9S:RemoveField("G9S_CODIGO")
    oStrGZN:RemoveField("GZN_CODIGO")

    oStrG5J:SetProperty("G5J_CODIGO", MVC_VIEW_CANCHANGE, .F.)
    oStrG9S:SetProperty("G9S_SEQ"   , MVC_VIEW_CANCHANGE, .F.)
    oStrGZN:SetProperty("GZN_SEQ"   , MVC_VIEW_CANCHANGE, .F.)  

    // Agrupamento Regra Padrão Fiscal
    oStrG5J:AddGroup( "FISCAL", "Regra Fiscal Padrão", "Regra Fiscal Padrão" , 2 )

    If G5J->(FieldPos("G5J_TES")) > 0
        oStrG5J:SetProperty("G5J_TES" , MVC_VIEW_GROUP_NUMBER, "FISCAL" )
        oStrG5J:SetProperty("G5J_TES", MVC_VIEW_LOOKUP, "SF4 TR")
    EndIf

    If G5J->(FieldPos("G5J_CFOP")) > 0
        oStrG5J:SetProperty("G5J_CFOP" , MVC_VIEW_GROUP_NUMBER, "FISCAL" )
        oStrG5J:SetProperty("G5J_CFOP" , MVC_VIEW_LOOKUP, "CFCTE" )
    EndIf

    //Grid Tabela d Regras fiscais da tabela de frete
    If AliasInDic("H66")
        oStrH66:RemoveField("H66_CODG5J")
        oStrH66:SetProperty("H66_TES", MVC_VIEW_LOOKUP, "SF4 TR")
        oStrH66:SetProperty("H66_CFNORM", MVC_VIEW_LOOKUP, "CFCTE")
    EndIf

    If G5J->(FieldPos("G5J_GIMCOD")) > 0
        oStrG5J:SetProperty('G5J_GIMCOD', MVC_VIEW_LOOKUP, "GIMENC")
    Endif

    If G9S->(FieldPos("G9S_KGINI")) > 0
        oStrG9S:SetProperty("G9S_KGINI" , MVC_VIEW_ORDEM, '05')
    Endif

    If G9S->(FieldPos("G9S_KGFIM")) > 0
        oStrG9S:SetProperty("G9S_KGFIM" , MVC_VIEW_ORDEM, '06')
    Endif

    oStrG9S:SetProperty("G9S_VALOR" , MVC_VIEW_ORDEM, '08')

Return

/*/{Protheus.doc} ValidG9S
(long_description)
@type  Function
@author gustavo.silva2
@since 25/09/2019
@version 1.0
@param oMdl, objeto, Modelo 
@param cField, caracter, Campo
@return uRet, undefined, Valor de retorno
@example
(examples)
@see (links_or_references)
ValidG9S("G9S_KMFIM")
/*/
Function ValidG9S(cField)

    Local oMdl   	:= FwModelActive()
    Local oMdlG5J	:= oMdl:GetModel('G5JMASTER')
    Local oMdlG9S	:= oMdl:GetModel('G9SDETAIL')
    Local cCbBox	:= " " 
    Local nKmIni	:= 0
    Local nKmAnt	:= 0
    Local nKgIni	:= 0
    Local nKgAnt	:= 0
    Local nTamGrid	:= 0
    Local uRet		:= 0
    Local n1        := 0

    cCbBox := oMdlG5J:GetValue('G5J_TIPOKM')// 1=Por Km;2=Intervalo de Km;3=Per Declaração;4=Intervalo de Km|Kg                                                                

    If cCbBox $ '1|2'
        If cField == 'G9S_KMFIM'
            If cCbBox <> '2'
                uRet:= RetMaxVal()
                oMdlG9S:SetNoInsertLine(.T.)
            EndIf
        ElseIf G9S->(FieldPos('G9S_KGFIM')) > 0 .And. cField == 'G9S_KGFIM'
            uRet:= RetMaxVal()
        Else
            If cCbBox == '1'
                uRet:= 0
            Else
                If cField == 'G9S_KMINI'
                    If oMdlG9S:Length() < 1
                        uRet:= 0
                    Else
                        nTamGrid:= oMdlG9S:Length()
                        If oMdlG9S:IsDeleted(nTamGrid)
                            n1:= nTamGrid
                            While n1>1
                                If !oMdlG9S:IsDeleted(n1)
                                    nTamGrid := n1
                                    EXIT
                                EndIf
                                n1--
                            End
                        EndIf
                        nKmAnt	:= oMdlG9S:GetValue('G9S_KMFIM', nTamGrid)
                        nKmIni	:= nKmAnt + VAL("0." + PADL("1",TAMSX3('G9S_KMFIM')[2],"0"))//0.01	
                        uRet	:= nKmIni
                    EndIf
                Endif
            EndIf
        EndIf
    ElseIf cCbBox == '4'
                If cField == 'G9S_KMINI'
                    If oMdlG9S:Length() < 1
                        uRet:= 0
                    Else
                        nTamGrid:= oMdlG9S:Length()
                        uRet    :=  oMdlG9S:GetValue('G9S_KMINI', nTamGrid)
                    EndIf
                Endif
                If cField == 'G9S_KMFIM'
                    If oMdlG9S:Length() < 1
                        uRet:= 0
                    Else
                        nTamGrid:= oMdlG9S:Length()
                        uRet    :=  oMdlG9S:GetValue('G9S_KMFIM', nTamGrid)
                    EndIf
                Endif

                If G9S->(FieldPos('G9S_KGINI')) > 0 .And. G9S->(FieldPos('G9S_KGFIM')) > 0 .And. cField == 'G9S_KGINI'
                    If oMdlG9S:Length() < 1
                        uRet:= 0
                    Else
                        nTamGrid:= oMdlG9S:Length()
                        nKgAnt	:= oMdlG9S:GetValue('G9S_KGFIM', nTamGrid)
                        nKgIni	:= nKgAnt + VAL("0." + PADL("1",TAMSX3('G9S_KGFIM')[2],"0"))//0.01	
                        If nKgIni < RetMaxVal()
                            uRet	:= nKgIni
                        Else
                            uRet	:= 0
                        Endif
                    EndIf
                Endif

                If G9S->(FieldPos('G9S_KGFIM')) > 0 .And. cField == 'G9S_KGFIM'
                    oMdlG9S:SetNoInsertLine(.F.)
                Endif
    EndIf

Return uRet

/*/{Protheus.doc} FieldValid
(long_description)
@type  Static Function
@author gustavo.silva2
@since 25/09/2019
@version 1.0
@param oMdl, objeto, Modelo 
@param cField, caracter, Campo
@param uVal, undefined, Modelo
@param nLine, numerico, Modelo
@param uOldValue, undefined, Modelo
@return uRet, undefined, Valor de retorno
@example
(examples)
@see (links_or_references)
/*/
Static Function FieldValid(oMdl,cField,uVal,nLine,uOldValue)

    Local lRet     := .T.
    Local cMsgErro := ""

    Do Case 
	    Case cField == 'G9S_KMFIM'
            lRet := ValidKm(oMdl,@cMsgErro)
            If !lRet 
        	    Help(,,STR0010,, cMsgErro, 1,0) //"O Km da linha atual deve ser maior que a anterior"
            EndIf

        Case cField == 'G5J_PRODUT'
            SB1->(DbSetOrder(1))
            If !(SB1->(DbSeek(XFILIAL("SB1") + uVal)))
                cCodProd         := uVal
                lRet:= .F.
                Help(,,STR0010,, STR0026, 1,0)//Valor informado não existe
            EndIf
	
        Case G9S->(FieldPos('G9S_KGFIM')) > 0 .And. cField == 'G9S_KGFIM'
            lRet := ValidKg(oMdl,@cMsgErro)
            If !lRet 
        	    Help(,,STR0033,, cMsgErro, 1,0) //STR0033 - "Validação KG" //"O Km da linha atual deve ser maior que a anterior"
        EndIf
    EndCase

Return lRet

/*/{Protheus.doc} ValidKm
(long_description)
@type  Static Function
@author gustavo.silva2
@since 25/09/2019
@version 1.0
@param oMdl, objeto, Modelo 
@param cField, caracter, Campo
@example
(examples)
@see (links_or_references)
/*/
Static Function ValidKm(oMdl,cMsgErro)

    Local nKmAtual	:= oMdl:GetValue('G9S_KMFIM')
    Local nTamGrid  := oMdl:Length()
    Local nKmInAtua	:= oMdl:GetValue('G9S_KMINI')
    Local nKmFiAtua	:= oMdl:GetValue('G9S_KMFIM')
    Local nKmAnte	:= 0
    Local nLinhaAtu	:= 0
    Local nCnt      := 0
    Local nLinAtu   := 0
    Local nLiNPos   := 0
    Local lRet		:= .T.
    Local cKMINI    := ''
    Local cKMIN2    := ''
    Local cKMFIM    := ''
    Local nValor    :=  0

    Local oModel   	:= FwModelActive()
    Local oMdlG5J	:= oModel:GetModel('G5JMASTER')
    Local cCbBox 	:= oMdlG5J:GetValue('G5J_TIPOKM')

    nLinhaAtu       := oMdl:GetLine()
    nLinAtu         := nLinhaAtu
    nValor          := RetMaxVal()

    If cCbBox == '4'
        If nLinhaAtu > 1 
	        If !oMdl:IsDeleted(nLinhaAtu - 1)
		        nKmAnte:= oMdl:GetValue("G9S_KMFIM", nLinhaAtu - 1 )
		        If nKmAtual < nKmAnte .And. nKmAnte <> nValor
                    lRet:= .F.
                    cMsgErro := STR0012//O Km da linha atual deve ser maior que a anterior
		        EndIf
	        EndIf
        EndIf

        If lRet
            If nLinhaAtu > 1 
	            If !oMdl:IsDeleted(nLinhaAtu)
		            If nKmFiAtua < nKmInAtua
                        lRet:= .F.
                        cMsgErro := STR0037 //"O KM Final da linha atual deve ser maior que KM Inicial"
	    	        EndIf
    	        EndIf
            EndIf
        Endif
    Else
        If nLinhaAtu > 1 
	        If !oMdl:IsDeleted(nLinhaAtu - 1)
		        nKmAnte:= oMdl:GetValue("G9S_KMFIM", nLinhaAtu - 1 )
		        If nKmAtual < nKmAnte 
                    lRet:= .F.
                    cMsgErro := STR0012//O Km da linha atual deve ser maior que a anterior
		        EndIf
	        EndIf
        EndIf

        If lRet
            If nLinhaAtu > 1 
	            If !oMdl:IsDeleted(nLinhaAtu)
		            If nKmFiAtua < nKmInAtua
                        lRet:= .F.
                        cMsgErro := STR0037 //"O KM Final da linha atual deve ser maior que KM Inicial"
	    	        EndIf
    	        EndIf
            EndIf
        Endif
    Endif

If lRet
    nCnt:= oMdl:Length()
    While nCnt > 1
        If !oMdl:IsDeleted(nCnt)
            nTamGrid := nCnt
            EXIT
        EndIf
        nCnt--
    End
    If nLinhaAtu != nTamGrid .And. cCbBox <> '4'
        lRet:= .F.
        cMsgErro := STR0027//"Não pode alterar, por não ser ultima linha."
    EndIf
EndIf

Return lRet

/*/{Protheus.doc} ValidKg
(long_description)
@type  Static Function
@author flavio.oliveira
@since 25/07/2024
@version 1.0
@param oMdl, objeto, Modelo 
@param cField, caracter, Campo
@example
(examples)
@see (links_or_references)
/*/
Static Function ValidKg(oMdl,cMsgErro)

    Local nKgAtual	:= 0
    Local nKmAtual	:= oMdl:GetValue('G9S_KMFIM')
    Local nKgInAtua	:= 0
    Local nKgFiAtua	:= 0
    Local nTamGrid  := oMdl:Length()
    Local nKgAnte	:= 0
    Local nLinhaAtu	:= 0
    Local nCnt      := 0
    Local nLinAtu   := 0
    Local nLiNPos   := 0
    Local lRet		:= .T.
    Local cKMINI    := ''
    Local cKGIN2    := ''
    Local cKGFIM    := ''
    Local nValor    :=  0

    Local oModel   	:= FwModelActive()
    Local oMdlG5J	:= oModel:GetModel('G5JMASTER')
    Local cCbBox 	:= oMdlG5J:GetValue('G5J_TIPOKM')

    nLinhaAtu       := oMdl:GetLine()
    nLinAtu         := nLinhaAtu
    nValor          := RetMaxVal()

    If G9S->(FieldPos('G9S_KGINI')) > 0 .And. G9S->(FieldPos('G9S_KGFIM')) > 0
    
        nKgAtual	:= oMdl:GetValue('G9S_KGFIM')
        nKgInAtua	:= oMdl:GetValue('G9S_KGINI')
        nKgFiAtua	:= oMdl:GetValue('G9S_KGFIM')

        If cCbBox == '4'
            If nLinhaAtu > 1 
	            If !oMdl:IsDeleted(nLinhaAtu - 1)
		            nKgAnte:= oMdl:GetValue("G9S_KGFIM", nLinhaAtu - 1 )
		            nKmAnte:= oMdl:GetValue("G9S_KMFIM", nLinhaAtu - 1 )
    		        If ( nKgAtual < nKgAnte .And. nKmAtual = nKmAnte ) .And. nKgAnte <> nValor
                       lRet:= .F.
                       cMsgErro := STR0034 //"O KG da linha atual deve ser maior que a anterior"
    		        EndIf
           	    EndIf
            EndIf

            If lRet
                If nLinhaAtu > 1 
	                If !oMdl:IsDeleted(nLinhaAtu)
		                If nKgFiAtua < nKgInAtua
                            lRet:= .F.
                            cMsgErro := STR0036 //"O KG Final da linha atual deve ser maior que KG Inicial"
		                EndIf
    	            EndIf
                EndIf
            Endif
        Endif
 
        If lRet
            nLiNPos := IF((nLinAtu < nTamGrid), (nLinAtu + 1), nLinAtu)

            IF oMdl:IsUpdated(nLinAtu) .and. nLinAtu < nLiNPos
                cKMINI := oMdl:GetValue('G9S_KGINI', nLiNPos)
                cKGIN2 := oMdl:GetValue('G9S_KGINI', nLinAtu)
                cKGFIM := oMdl:GetValue('G9S_KGFIM', nLinAtu)

                IF (cKMINI < cKGFIM .or. cKGFIM < cKGIN2) .And. cCbBox <> '4'
                    lRet := .F.
                    cMsgErro := STR0028//"Valor informado menor que o anterior."
                ENDIF
            EndIf
        EndIf
    Endif

Return lRet

/*/{Protheus.doc} ValTrig
(long_description)
@type  Static Function
@author gustavo.silva2
@since 25/09/2019
@version 1.0
@param oMdl, objeto, Modelo 
@param cField, caracter, Campo
@example
(examples)
@see (links_or_references)
/*/
Static Function ValTrig(oMdl, cField)

    Local oModel	:= oMdl:GetModel()
    Local oMdlG9S	:= oModel:GetModel('G9SDETAIL')
    Local cCbBox 	:= oMdl:GetValue('G5J_TIPOKM')
    Local nCnt      := 0

    Do case
    
        case cCbBox == '1'

            If oMdlG9S:Length() > 0
                oMdlG9S:SetNoInsertLine(.F.)
                For nCnt := 1 To oMdlG9S:Length()
                    If !oMdlG9S:IsDeleted(nCnt)
                        oMdlG9S:Goline(nCnt)
                        oMdlG9S:DeleteLine(.T.)
                    EndIf
                Next nCnt
		        oMdlG9S:AddLine()
		        oMdlG9S:LoadValue('G9S_KMINI', 0)
		        oMdlG9S:LoadValue('G9S_KMFIM', RetMaxVal())
                If G9S->(FieldPos('G9S_KGINI')) > 0
                    oMdlG9S:LoadValue('G9S_KGINI', 0)
                Endif
                If G9S->(FieldPos('G9S_KGFIM')) > 0
                    oMdlG9S:LoadValue('G9S_KGFIM', RetMaxVal())
                Endif
                oMdlG9S:SetNoInsertLine( .T.)
	        EndIf
	
        case cCbBox == '2'
            If oMdlG9S:Length() > 0
                For nCnt := 1 To oMdlG9S:Length()
                    If !oMdlG9S:IsDeleted(nCnt)
                        oMdlG9S:Goline(nCnt)
                        oMdlG9S:DeleteLine(.T.)
                    EndIf
                Next nCnt
                oMdlG9S:SetNoInsertLine(.F.)
                oMdlG9S:AddLine()
                oMdlG9S:LoadValue('G9S_KMINI', 0)
                oMdlG9S:LoadValue('G9S_KMFIM', 0)
                If G9S->(FieldPos('G9S_KGINI')) > 0
                    oMdlG9S:LoadValue('G9S_KGINI', 0)
                Endif
                If G9S->(FieldPos('G9S_KGFIM')) > 0
                    oMdlG9S:LoadValue('G9S_KGFIM', RetMaxVal())
                Endif
	        EndIf

        Case cCbBox == '3'
            If oMdlG9S:Length() > 0
                oMdlG9S:SetNoInsertLine(.F.)
                For nCnt := 1 To oMdlG9S:Length()
                    If !oMdlG9S:IsDeleted(nCnt)
                        oMdlG9S:Goline(nCnt)
                        oMdlG9S:DeleteLine(.T.)
                    EndIf
                Next nCnt
		
                oMdlG9S:SetNoInsertLine( .T.)
	        EndIf

        case cCbBox == '4'
            If oMdlG9S:Length() > 0
                For nCnt := 1 To oMdlG9S:Length()
                    If !oMdlG9S:IsDeleted(nCnt)
                        oMdlG9S:Goline(nCnt)
                        oMdlG9S:DeleteLine(.T.)
                    EndIf
                Next nCnt
                oMdlG9S:SetNoInsertLine(.F.)
                oMdlG9S:AddLine()
                oMdlG9S:LoadValue('G9S_KMINI', 0)
                oMdlG9S:LoadValue('G9S_KMFIM', 0)
                If G9S->(FieldPos('G9S_KGINI')) > 0
                    oMdlG9S:LoadValue('G9S_KGINI', 0)
                Endif
                If G9S->(FieldPos('G9S_KGFIM')) > 0
                    oMdlG9S:LoadValue('G9S_KGFIM', 0)
                Endif
            EndIf
    
    EndCase

Return

/*/{Protheus.doc} WhenValid
(long_description)
@type  Static Function
@author gustavo.silva2
@since 25/09/2019
@version 1.0
@param oMdl, objeto, Modelo 
@param cField, caracter, Campo
@example
(examples)
@see (links_or_references)
/*/
Static Function WhenValid(oMdl,cField,uVal,nLine,uOldValue)

    Local lRet		:= .T.
    Local oModel	:= oMdl:GetModel()
    Local oMdlG5J	:= oModel:GetModel('G5JMASTER')
    Local cCbBox	:= oMdlG5J:GetValue('G5J_TIPOKM')

    If cCbBox <> '2'
	    lRet:= .F.
    Else
	    lRet:= .T.
    EndIf

    If cField == 'G5J_TIPOKM'
        If oMdlG5J:GetOperation() == MODEL_OPERATION_INSERT
            lRet:= .T.
        Else
            lRet:= .F.
        Endif
    Endif

    If G5J->(FieldPos('G5J_STPLAN')) > 0 .And. cField == 'G5J_STPLAN'
        If oMdlG5J:GetOperation() == MODEL_OPERATION_INSERT
            lRet:= .T.
        Else
            lRet:= .F.
        Endif
    Endif

    If G5J->(FieldPos('G5J_GIMCOD')) > 0 .And. cField == 'G5J_GIMCOD'
        If G5J->(FieldPos('G5J_STPLAN')) > 0 .And. oMdlG5J:GetOperation() == MODEL_OPERATION_INSERT .And. oMdlG5J:GetValue('G5J_STPLAN') == '1'
            lRet:= .T.
        Else
            lRet:= .F.
        Endif
    Endif

    //Tratativa para Hbailitar apenas os campos envolvidos
    If cCbBox == '4'
        Do Case
            Case cField == 'G9S_KMINI'
	            lRet:= .T.
            Case cField == 'G9S_KMFIM'
	            lRet:= .T.
            Case G9S->(FieldPos('G9S_KGINI')) > 0 .And. cField == 'G9S_KGINI'
	            lRet:= .T.
            Case G9S->(FieldPos('G9S_KGFIM')) > 0 .And. cField == 'G9S_KGFIM'
	            lRet:= .T.
        EndCase
    ElseIf cCbBox == '2'
        Do Case
            Case cField == 'G9S_KMINI'
	            lRet:= .F.
            Case cField == 'G9S_KMFIM'
	            lRet:= .T.
            Case G9S->(FieldPos('G9S_KGINI')) > 0 .And. cField == 'G9S_KGINI'
	            lRet:= .F.
            Case G9S->(FieldPos('G9S_KGFIM')) > 0 .And. cField == 'G9S_KGFIM'
	            lRet:= .F.
        EndCase
    Endif

Return lRet

//------------------------------------------------------------------------------
/*/{Protheus.doc} RetTabFrt

@type Function
@author 
@since 25/09/2019
@version 1.0
@param , character, (Descrição do parâmetro)
@return , return_description
@example
(examples)
@see (links_or_references)
/*/
//------------------------------------------------------------------------------
Function RetTabFrt(cTabFrete, nTotalKm, nTotalKg, ctipoFrt)

    Local cAliasQry     := GetNextAlias()
    Local nValCont      := 0
    Default cTabFrete   := ""
    Default nTotalKm    := 0
    Default nTotalKg    := 0
    Default ctipoFrt    := ""

    If ctipoFrt <> '4'
        BeginSQL Alias cAliasQry
            SELECT G9S.G9S_VALOR, R_E_C_N_O_ AS RECNOG9S 
            FROM %Table:G9S% G9S
            WHERE G9S.%NotDel%
                AND G9S.G9S_FILIAL = %xFilial:G9S%
                AND G9S.G9S_CODIGO = %Exp:cTabFrete%
                AND %Exp:nTotalKm% BETWEEN G9S.G9S_KMINI AND G9S.G9S_KMFIM
        EndSQL
    Else
        If G9S->(FieldPos('G9S_KGINI')) > 0 
            BeginSQL Alias cAliasQry
                SELECT G9S.G9S_VALOR, R_E_C_N_O_ AS RECNOG9S 
                FROM %Table:G9S% G9S
                WHERE G9S.%NotDel%
                    AND G9S.G9S_FILIAL = %xFilial:G9S%
                    AND G9S.G9S_CODIGO = %Exp:cTabFrete%
                    AND %Exp:nTotalKm% BETWEEN G9S.G9S_KMINI AND G9S.G9S_KMFIM
                    AND %Exp:nTotalKg% BETWEEN G9S.G9S_KGINI AND G9S.G9S_KGFIM
            EndSQL
        Else
            BeginSQL Alias cAliasQry
                SELECT G9S.G9S_VALOR, R_E_C_N_O_ AS RECNOG9S 
                FROM %Table:G9S% G9S
                WHERE G9S.%NotDel%
                    AND G9S.G9S_FILIAL = %xFilial:G9S%
                    AND G9S.G9S_CODIGO = %Exp:cTabFrete%
                    AND %Exp:nTotalKm% BETWEEN G9S.G9S_KMINI AND G9S.G9S_KMFIM
            EndSQL
        Endif
    Endif

    If (cAliasQry)->(!Eof())	
        nValCont := (cAliasQry)->G9S_VALOR
    EndIf
    
    (cAliasQry)->(DbCloseArea())

Return nValCont



//------------------------------------------------------------------------------
/*/{Protheus.doc} ValG5J
utilizado na consulta padrão G5J e validação de campo de frete na GTPA801 
@type Function
@author 
@since 16/12/2019
@version 1.0
@param , character, (Descrição do parâmetro)
@return cCodG5j, return_description
@example
(examples)
@see (links_or_references)
/*/
//------------------------------------------------------------------------------
Function GTPValG5J()
Local cCodG5j := ""
Local lVal    := .T.
Local aArea   := GetArea()

GZN->(DbSetOrder(1))
If !(GZN->(DbSeek(G5J->G5J_FILIAL + G5J->G5J_CODIGO)))
    cCodG5j += '|' + G5J->G5J_CODIGO
    lVal := .F.
EndIf

If lVal
    GZN->(DbSetOrder(3))
    If FWFLDGET("G99_TOMADO") == "0"
        If GZN->(DbSeek(G5J->G5J_FILIAL + G5J->G5J_CODIGO + FWFLDGET("G99_CLIREM") + FWFLDGET("G99_LOJREM"))) 
            cCodG5j += '|' + G5J->G5J_CODIGO
        EndIf
    Else
        If GZN->(DbSeek(G5J->G5J_FILIAL + G5J->G5J_CODIGO + FWFLDGET("G99_CLIDES") + FWFLDGET("G99_LOJDES"))) 
            cCodG5j += '|' + G5J->G5J_CODIGO
        EndIf
    EndIf
EndIf
RestArea(aArea)
Return cCodG5j

Static Function FiscalLine(oSubMdl,nLine)

    Local lRet  := .T.

    Local nOpt  := oSubMdl:GetModel():GetOperation()

    Local cMsgErro  := ""
    Local cMsgSolu  := ""

    If ( nOpt == MODEL_OPERATION_INSERT .Or. nOpt == MODEL_OPERATION_UPDATE )

        If ( !oSubMdl:IsDeleted(nLine) )

            If ( Empty(oSubMdl:GetValue("H66_TES",nLine))  )            
                
                lRet := .F.

                cMsgErro    := "Não foi preenchido o conteúdo para o campo [TES]."                

            EndIf

            If ( lRet .And. Empty(oSubMdl:GetValue("H66_CFNORM",nLine)) )
                
                lRet := .F.
                
                cMsgErro    := "Não foi preenchido o conteúdo para o campo [CFOP Normal]."
                
            EndIf
            
            If ( oSubMdl:GetValue("H66_CFNORM",nLine) == oSubMdl:GetModel():GetModel("G5JMASTER"):GetValue("G5J_CFOP") .And.;
                    oSubMdl:GetValue("H66_TES",nLine) == oSubMdl:GetModel():GetModel("G5JMASTER"):GetValue("G5J_TES"))
                
                lRet := .F.

                cMsgErro := "O código fiscal e TES escolhidos já foram preenchidos no "
                cMsgErro += "cabeçalho do Formulário [campos Cod. Fiscal e TES]."
                
                cMsgSolu := "O conteúdo de TES e Código Fiscal preenchidos no " 
                cMsgSolu += "cabeçalho serão utilizados de forma padrão para a criação da encomenda. "
                
                cMsgSolu += "Tanto a TES quanto o CFOP definidos neste Grid de Regras Fiscais devem ser "
                cMsgSolu += "uma especificidade para a operação realizada com o "
                cMsgSolu += "produto selecionado (" 
                
                If ( !Empty(oSubMdl:GetModel():GetModel("G5JMASTER"):GetValue("G5J_PRODUT"))  )
                    cMsgSolu += oSubMdl:GetModel():GetModel("G5JMASTER"):GetValue("G5J_PRODUT") 
                Else
                    cMsgSolu += "aquele informado no campo [Produto]. " 
                EndIf

                cMsgSolu += ") e entre os estados " 
                
                If ( !Empty(oSubMdl:GetValue("H66_UFORIG")) .And. !Empty(oSubMdl:GetValue("H66_UFDEST")) )

                    cMsgSolu += Alltrim(oSubMdl:GetValue("H66_UFORIG")) + " e "
                    cMsgSolu += Alltrim(oSubMdl:GetValue("H66_UFDEST"))
                
                Else
                    cMsgSolu += "preenchidos para os campos [UF Origem] e [UF Destino]. "
                EndIf

                cMsgSolu += "Utilize outra TES e CFOP."

            EndIf

            If ( lRet .And. Empty(oSubMdl:GetValue("H66_UFORIG",nLine)) )

                lRet := .F.
                
                cMsgErro    := "Não foi preenchido o conteúdo para o campo [UF Origem]."

            EndIf
            
            If ( lRet .And. Empty(oSubMdl:GetValue("H66_UFDEST",nLine)) )
                
                lRet := .F.

                cMsgErro    := "Não foi preenchido o conteúdo para o campo [UF Destino]."

            EndIf

            If ( !lRet  )
               
                If  (Empty(cMsgSolu) )
                    cMsgSolu := "Preencha com conteúdo o referido campo."
                EndIf

                oSubMdl:GetModel():SetErrorMessage(oSubMdl:GetModel():GetId(),,oSubMdl:GetId(),,"PosLine",cMsgErro,cMsgSolu)

            EndIf

        EndIf        

    EndIf

Return(lRet)

/*/{Protheus.doc} GTPA802SXB
(long_description)
@type function
@author flavio.oliveira
@since 02/08/2024
@version 1.0
@return ${return}, ${return_description}
@example
(examples)
@see (links_or_references)
/*/
Function GTPA802SXB()

    Local lRet		:= .F.
    Local oLookUp  	:= Nil
    Local aIndice  	:= {}
    Local aRetorno 	:= {}
    Local cQuery   	:= ""          
    Local n1		:= 0

	cFields := "GIM_COD,GIM_DESCRI"
	aAdd(aIndice,{"Código"		, "GIM_COD"})
	aAdd(aIndice,{"Descrição"	, "GIM_DESCRI"})

    cQuery := ""
    cQuery += " SELECT " + cFields  
    cQuery += " FROM "+RetSqlName("GIM")+" GIM "
    cQuery += " WHERE "
    cQuery += " 	GIM.GIM_FILIAL = '"+xFilial('GIM')+"' "
    cQuery += " 	AND GIM.GIM_UTILIZ = '3' "
    cQuery += " 	AND GIM.GIM_PRODUT = '" + cCodProd + "' "
    cQuery += " 	AND GIM.D_E_L_E_T_ = ' ' "
	
    oLookUp := GTPXLookUp():New(StrTran(cQuery, '#', '"'), Separa(cFields,","))

    For n1 := 1 To Len(aIndice)
	    oLookUp:AddIndice(aIndice[n1][1], aIndice[n1][2])
    Next

    If oLookUp:Execute()
	    lRet       := .T.
	    aRetorno   := oLookUp:GetReturn()
	    cCampo802 := aRetorno[1]
    EndIf   

    FreeObj(oLookUp)

Return lRet

//GTPA802SXB()                                                                                                                                                                                                                                              
//GTPA802RET()
/*/{Protheus.doc} GTPA802RET
(long_description)
@type function
@author flavio.oliveira
@since 02/08/2024
@version 1.0
@param nOpc, numérico, (Descrição do parâmetro)
@return ${return}, ${return_description}
@example
(examples)
@see (links_or_references)
/*/
Function GTPA802RET()
Return cCampo802
