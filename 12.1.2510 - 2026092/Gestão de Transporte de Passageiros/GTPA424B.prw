#Include "GTPA424B.ch"
#INCLUDE 'PROTHEUS.CH'
#INCLUDE 'PARMTYPE.CH'
#INCLUDE 'FWMVCDEF.CH'

/*/{Protheus.doc} GTPA424B
    (long_description)
    @type  Function
    @author henrique.toyada
    @since 22/11/2022
    @version version
    @param , param_type, param_descr
    @return , return_type, return_description
    @example
    (examples)
    @see (links_or_references)
    /*/
Function GTPA424B()
    
Local aArea     := GetArea()	
Local oView     := FwViewActive()	
Local oModelH6P := nil

Private cEmpIrj := ''

oModelH6P := oView:GetModel():GetModel('H6PDETAIL')

cEmpIrj := oModelH6P:GetValue("H6P_CODEMP")

FwExecView(STR0001, "VIEWDEF.GTPA424B", MODEL_OPERATION_VIEW, /*oDlg*/, {||.T.} /*bCloseOk*/, {||.T.}/*bOk*/, 10 ,/*aButtons*/, {||.T.}/*bCancel*/,,,/*oModel*/) //"Bilhetes por empresa"

RestArea(aArea)

Return 

/*/{Protheus.doc} ModelDef
(long_description)
@type  Static Function
@author flavio.martins
@since 16/11/2022
@version 1.0
@param , param_type, param_descr
@return oModel, return_type, return_description
@example
(examples)
@see (links_or_references)
/*/
Static Function ModelDef()
Local oModel	:= Nil
Local oStruH6P	:= FwFormStruct(1,'H6P',{ |x| ALLTRIM(x)+"|" $ "H6P_CODEMP|H6P_DESEMP|" })
Local oStruGIC	:= FwFormStruct(1,'GIC',{ |x| ALLTRIM(x)+"|" $ "GIC_SERIE|GIC_BILHET|GIC_DTVIAG|GIC_LOCORI|GIC_LOCDES|GIC_HORA|GIC_LINHA|GIC_TAR|GIC_TAX|GIC_PED|GIC_SGFACU|GIC_TARTAB|GIC_TAXTAB|GIC_PEDTAB|GIC_SGTAB|GIC_NUMCOM|GIC_AGENCI|GIC_SENTID|GIC_CODIGO|"})
Local bLoad		:= {|oModel| G424BLoad(oModel)}
Local bInitData	:= {|oModel|InitData(oModel)}
oModel := MPFormModel():New('GTPA424B', /*bPreValid*/, /*bPosValid*/, /*bCommit*/, /*bCancel*/)

oModel:AddFields('H6PMASTER',/*cOwner*/,oStruH6P,,,bLoad)
oModel:AddGrid('GICDETAIL','H6PMASTER',oStruGIC, /*bLinePre*/, /*blinePost*/, /*bPre*/, /*bPost*/, /*bLoad*/)

//oModel:SetRelation('GICDETAIL', {{'GIC_FILIAL', 'xFilial("GIC")'}}, GIC->(IndexKey(1)))

oModel:GetModel('GICDETAIL'):SetOptional(.T.)
oModel:GetModel("GICDETAIL"):SetOnlyQuery(.T.)

oModel:SetDescription(STR0002) // "Caixa de Colaboradores - Consulta" //'Bilhetes'

oModel:GetModel('H6PMASTER'):SetDescription(STR0002) //'Bilhetes'

oModel:SetPrimaryKey({'H6P_FILIAL','H6P_CODEMP'})
oModel:SetActivate(bInitData)
Return oModel

/*/{Protheus.doc} ViewDef
(long_description)
@type  Static Function
@author flavio.martins
@since 16/11/2022
@version 1.0
@param , param_type, param_descr
@return oView, return_type, return_description
@example
(examples)
@see (links_or_references)
/*/
Static Function ViewDef()
Local oModel	 := ModelDef()
Local oView		 := FwFormView():New()
Local oStruG6X	 := FwFormStruct(2, 'H6P',{ |x| ALLTRIM(x)+"|" $ "H6P_CODEMP|H6P_DESEMP|" })
Local oStruH6M	 := FwFormStruct(2, 'GIC',{ |x| ALLTRIM(x)+"|" $ "GIC_SERIE|GIC_BILHET|GIC_DTVIAG|GIC_LOCORI|GIC_LOCDES|GIC_HORA|GIC_LINHA|GIC_TAR|GIC_TAX|GIC_PED|GIC_SGFACU|GIC_TARTAB|GIC_TAXTAB|GIC_PEDTAB|GIC_SGTAB|GIC_NUMCOM|GIC_AGENCI|GIC_SENTID|GIC_CODIGO|"})

oView:SetModel(oModel)

oView:SetDescription(STR0002) //'Bilhetes'

oView:AddField('VIEW_H6P', oStruG6X,'H6PMASTER')
oView:AddGrid('VIEW_GIC', oStruH6M,'GICDETAIL')

oView:CreateHorizontalBox('HEADER'  , 30)
oView:CreateHorizontalBox('GRID_GIC', 70)

oView:SetOwnerView('VIEW_H6P', 'HEADER')
oView:SetOwnerView('VIEW_GIC', 'GRID_GIC')

Return oView

/*/{Protheus.doc} G424BLoad
(long_description)
@type  Static Function
@author flavio.martins
@since 16/11/2022
@version 1.0
@param oModel, param_type, param_descr
@return nil, return_type, return_description
@example
(examples)
@see (links_or_references)
/*/
Static Function G424BLoad(oModel)
Local aLoad 	:= {}
Local aDados    := {} 
Local aAux      := {}

If oModel:GetId() == 'H6PMASTER'

    aAdd(aDados, cEmpIrj)
    aAux := FWEAIEMPFIL(cEmpIrj,,'TOTALBUS')
    aAdd(aDados, SUBSTR(FWFilialName(aAux[1],aAux[2]),0,TamSX3("H6P_DESEMP")[1])) 
        
    aAdd(aLoad, aDados)
    aAdd(aLoad, 0)

Endif

Return aLoad


//-------------------------------------------------------------------
/*/{Protheus.doc} InitData
Inicializador caso seja feito versionamento
@author Inovação 
@since 11/04/2017
@version undefined
@param oModel
@type function
/*/
//-------------------------------------------------------------------

Static Function InitData(oModel)
Local oMdlGIC	:= oModel:GetModel('GICDETAIL')
Local cAliasTmp := GetNextAlias()

BeginSql Alias cAliasTmp
   
    SELECT  GIC_SERIE 
            ,GIC_BILHET
            ,GIC_DTVIAG
            ,GIC_LOCORI
            ,GIC_LOCDES
            ,GIC_HORA  
            ,GIC_LINHA 
            ,GIC_TAR   
            ,GIC_TAX   
            ,GIC_PED   
            ,GIC_SGFACU
            ,GIC_TARTAB
            ,GIC_TAXTAB
            ,GIC_PEDTAB
            ,GIC_SGTAB 
            ,GIC_NUMCOM
            ,GIC_AGENCI
            ,GIC_SENTID
            ,GIC_CODIGO
            ,GIC.R_E_C_N_O_ RECGIC
    FROM %Table:GI6% GI6
    INNER JOIN %Table:GIC% GIC
    ON GIC.GIC_AGENCI = GI6.GI6_CODIGO
        AND GIC.GIC_NUMFCH != ''
        AND GIC.GIC_INTEGR = '1'
        AND GIC.GIC_NUMOPE != ''
        AND GIC.%NotDel%
    WHERE GI6.GI6_FILIAL = %xFilial:GI6%
        AND GI6.GI6_EMPRJI = %Exp:cEmpIrj%
        AND GI6.%NotDel%
EndSql

If (cAliasTmp)->(!Eof())
    While (cAliasTmp)->(!Eof())
        If !oMdlGIC:IsEmpty()
            oMdlGIC:addLine(.T.)
        Endif
        oMdlGIC:LoadValue('GIC_SERIE ',(cAliasTmp)->GIC_SERIE )
        oMdlGIC:LoadValue('GIC_BILHET',(cAliasTmp)->GIC_BILHET)
        oMdlGIC:LoadValue('GIC_DTVIAG',stod((cAliasTmp)->GIC_DTVIAG))
        oMdlGIC:LoadValue('GIC_LOCORI',(cAliasTmp)->GIC_LOCORI)
        oMdlGIC:LoadValue('GIC_LOCDES',(cAliasTmp)->GIC_LOCDES)
        oMdlGIC:LoadValue('GIC_HORA  ',(cAliasTmp)->GIC_HORA  )
        oMdlGIC:LoadValue('GIC_LINHA ',(cAliasTmp)->GIC_LINHA )
        oMdlGIC:LoadValue('GIC_TAR   ',(cAliasTmp)->GIC_TAR   )
        oMdlGIC:LoadValue('GIC_TAX   ',(cAliasTmp)->GIC_TAX   )
        oMdlGIC:LoadValue('GIC_PED   ',(cAliasTmp)->GIC_PED   )
        oMdlGIC:LoadValue('GIC_SGFACU',(cAliasTmp)->GIC_SGFACU)
        oMdlGIC:LoadValue('GIC_TARTAB',(cAliasTmp)->GIC_TARTAB)
        oMdlGIC:LoadValue('GIC_TAXTAB',(cAliasTmp)->GIC_TAXTAB)
        oMdlGIC:LoadValue('GIC_PEDTAB',(cAliasTmp)->GIC_PEDTAB)
        oMdlGIC:LoadValue('GIC_SGTAB ',(cAliasTmp)->GIC_SGTAB )
        oMdlGIC:LoadValue('GIC_NUMCOM',(cAliasTmp)->GIC_NUMCOM)
        oMdlGIC:LoadValue('GIC_AGENCI',(cAliasTmp)->GIC_AGENCI)
        oMdlGIC:LoadValue('GIC_SENTID',(cAliasTmp)->GIC_SENTID)
        oMdlGIC:LoadValue('GIC_CODIGO',(cAliasTmp)->GIC_CODIGO)
        
        (cAliasTmp)->(dbSkip())

    EndDo
EndIf

(cAliasTmp)->(dbCloseArea())
Return
