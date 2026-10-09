#Include "GTPA421C.ch"
#Include "Protheus.ch"
#INCLUDE "TOTVS.CH"
#INCLUDE 'TOPCONN.CH'
#INCLUDE "FWMVCDEF.CH"

Static lOpDesej := .F.

/*/{Protheus.doc} GTPA421C
    Chamada para ativar receita
    @type  Function
    @author Henrique Madureira
    @since 09/06/2020
    @version 1
    @param 
    @return nil,null, Sem Retorno
    @see (links_or_references)
/*/
Function GTPA421CR ()
lOpDesej := .T.

GTPA421C()

Return

/*/{Protheus.doc} GTPA421C
    Chamada para ativar despesa
    @type  Function
    @author Henrique Madureira
    @since 09/06/2020
    @version 1
    @param 
    @return nil,null, Sem Retorno
    @see (links_or_references)
/*/
Function GTPA421CD ()
lOpDesej := .F.

GTPA421C()

Return

/*/{Protheus.doc} GTPA421C
    Programa em MVC da conferência de Receita/Despesa
    @type  Function
    @author Henrique Madureira
    @since 09/06/2020
    @version 1
    @param 
    @return nil,null, Sem Retorno
    @see (links_or_references)
/*/
Function GTPA421C()

	FwMsgRun(, {|| FwExecView("","VIEWDEF.GTPA421C",MODEL_OPERATION_UPDATE,,{|| .T.})},"", STR0001) //STR0001 //"Buscando registros..."
	
Return()

/*/{Protheus.doc} ModelDef
    Model - Conferência de receita/despesa
    @type  Static Function
    @author Henrique Madureira
    @since 09/06/2020
    @version 1
    @param 
    @return oModel, objeto, instância da classe FwFormModel
    @see (links_or_references)
/*/
Static Function ModelDef()
Local oModel   := Nil
Local oStruG6X := FwFormStruct( 1, "G6X",,.F. ) // Ficha de Remessa 
Local oStruGZG := FWFormStruct( 1,"GZG" ) //Estrutura de Receita/Despesa
Local cTitulo  := IIF(lOpDesej,STR0002,STR0003) //"Receita" //"Despesa"
Local bFldVld  := {|oMdl,cField,cNewValue,cOldValue| FieldValid(oMdl,cField,cNewValue,cOldValue)}
Local bTrig    := {|oMdl,cField,uVal| G421CBTrigger(oMdl,cField,uVal)}
Local cTipo    := ''

If FwIsInCallStack('GTPA421CR')
    cTipo := '1'
ElseIf FwIsInCallStack('GTPA421CD')
    cTipo := '2'
EndIf

oModel := MPFormModel():New("GTPA421C",,,)

oStruGZG:SetProperty('GZG_CONFER', MODEL_FIELD_VALID, bFldVld)
oStruGZG:SetProperty('*', MODEL_FIELD_WHEN, {|| .F. } )
oStruGZG:SetProperty('GZG_CONFER', MODEL_FIELD_WHEN, {|| .T.} )
oStruGZG:SetProperty('GZG_MOTREJ', MODEL_FIELD_WHEN, {|oMdl| oMdl:GetValue('GZG_CONFER') == "3" })
oStruGZG:SetProperty('GZG_VLACER', MODEL_FIELD_WHEN, {|oMdl| !(oMdl:GetValue('GZG_CARGA'))} )
oStruGZG:AddTrigger('GZG_CONFER','GZG_CONFER',{||.T.}, bTrig)

oModel:AddFields("G6XMASTER", /*cOwner*/, oStruG6X,,,/*bLoad*/)
oModel:AddGrid('GZGDETAIL', 'G6XMASTER', oStruGZG,,,,,/*bLoad*/)

oModel:SetRelation('GZGDETAIL', {{'GZG_FILIAL', 'xFilial( "GZG" )' },{'GZG_AGENCI', 'G6X_AGENCI'} ,{'GZG_NUMFCH','G6X_NUMFCH'},{ 'GZG_TIPO', "'" + cTipo + "'" } }, GZG->(IndexKey(1)))

If lOpDesej
    cTipo := '1'
    oModel:AddCalc('CALC_TOTAL', 'G6XMASTER', 'GZGDETAIL', 'GZG_VALOR', 'TOTAL_DEBITO', 'SUM', { || oModel:GetModel("GZGDETAIL"):GetValue('GZG_TIPO') == '1'},,STR0004)	// "Valor Total" //"Total Receita"
Else
    cTipo := '2'
    oModel:AddCalc('CALC_TOTAL', 'G6XMASTER', 'GZGDETAIL', 'GZG_VALOR', 'TOTAL_CREDITO', 'SUM', { || oModel:GetModel("GZGDETAIL"):GetValue('GZG_TIPO') == '2'},,STR0005)	// "Valor Total" //"Total Despesa"
EndIf

oModel:GetModel("G6XMASTER"):SetOnlyView(.T.)
oModel:GetModel("GZGDETAIL"):SetNoInsertLine(.T.)
oModel:GetModel('GZGDETAIL'):SetNoDeleteLine(.T.)

oModel:SetPrimaryKey({})

oModel:SetDescription(STR0006 + cTitulo) // //"Conferência de "

oModel:GetModel('G6XMASTER'):SetDescription(STR0007) // //"Ficha de Remessa"
oModel:GetModel('GZGDETAIL'):SetDescription(cTitulo) //

oModel:SetVldActivate({|oModel| G421CBVldAct(oModel)})

Return(oModel)

/*/{Protheus.doc} ViewDef
    View - Conferência de receita/despesa
    @type  Static Function
    @author Henrique Madureira
    @since 09/06/2020
    @version 1
    @param 
    @return oView, objeto, instância da Classe FWFormView
    @see (links_or_references)
/*/ 
Static Function ViewDef()
Local oView		:= nil
Local oModel    := FwLoadModel("GTPA421C")
Local oStruG6X	:= FwFormStruct(2,"G6X", {|cCpo| (AllTrim(cCpo))$ "G6X_AGENCI|G6X_NUMFCH|G6X_DTINI|G6X_DTFIN" })	//Ficha de Remessa
Local oStruGZG  := FWFormStruct(2,"GZG", {|cCpo| (AllTrim(cCpo))$ "GZG_SEQ|GZG_COD|GZG_DESCRI|GZG_VALOR|GZG_CONFER|GZG_DTCONF|GZG_MOTREJ|GZG_USUCON|GZG_VLACER" } ) //Estrutura de Receita
Local oStruCalc := FwCalcStruct( oModel:GetModel('CALC_TOTAL'))
Local cTitulo   := IIF(lOpDesej,STR0002,STR0003) //"Despesa" //"Receita"

// Cria o objeto de View
oView := FwFormView():New()

// Define qual o Modelo de dados será utilizado
oView:SetModel( oModel )

oView:AddField("VIEW_HEADER", oStruG6X, "G6XMASTER")
oView:AddGrid("VIEW_DETAIL", oStruGZG, "GZGDETAIL")
oView:AddField('VIEW_TOTAL', oStruCalc, "CALC_TOTAL")

oView:CreateHorizontalBox("HEADER", 20 )
oView:CreateHorizontalBox("DETAIL", 70 )
oView:CreateHorizontalBox("TOTAL", 10 )

oView:SetOwnerView("VIEW_HEADER", "HEADER")
oView:SetOwnerView("VIEW_DETAIL", "DETAIL")
oView:SetOwnerView("VIEW_TOTAL", "TOTAL")

oView:AddUserButton(STR0008, "", {|oModel| ConfereTudo(oModel)} )   //  //"Conferir Todos"

oView:EnableTitleView('VIEW_HEADER', STR0009) //  //"Dados da Ficha de Remessa"

oView:EnableTitleView('VIEW_DETAIL', cTitulo) // 

oView:GetViewObj("VIEW_DETAIL")[3]:SetSeek(.T.)
oView:GetViewObj("VIEW_DETAIL")[3]:SetFilter(.T.)

Return(oView)

/*/{Protheus.doc} G421CBTrigger(oMdl,cField,uVal)
(long_description)
@type function
@author flavio.martins
@since 03/06/2020
@version 1.0
@param oModel, objeto, (Descrição do parâmetro)
@return ${return}, ${return_description}
@example
(examples)
@see (links_or_references)
/*/
Static Function G421CBTrigger(oMdl,cField,uVal)
Local cUserLog  := AllTrim(RetCodUsr())

If cField == 'GZG_CONFER'

    If uVal != '3'
        oMdl:ClearField('GZG_MOTREJ')
    Endif
    
    If uVal > '1'
        oMdl:LoadValue('GZG_DTCONF', dDataBase)
        oMdl:LoadValue('GZG_USUCON', cUserLog)
    Else
        oMdl:ClearField('GZG_DTCONF')
        oMdl:ClearField('GZG_USUCON')
    Endif

Endif

Return

/*/{Protheus.doc} GA115VldAct
(long_description)
@type function
@author jacomo.fernandes
@since 03/10/2018
@version 1.0
@param oModel, objeto, (Descrição do parâmetro)
@return ${return}, ${return_description}
@example
(examples)
@see (links_or_references)
/*/
Static Function G421CBVldAct(oModel)

Local lRet		:= .T.
Local cStatus	:= G6X->G6X_STATUS
Local aNewFlds  := {'GZG_CONFER', 'GZG_DTCONF', 'GZG_USUCON', 'GZG_VLACER'}
Local cMsgErro  := ''
Local cMsgSol   := ''

If !(GTPxVldDic('GZG', aNewFlds, .F., .T.))
    lRet     := .F.
    cMsgErro := STR0020 //  //"Dicionário desatualizado"
    cMsgSol  := STR0021   //  //"Atualize o dicionário para utilizar esta rotina"
Endif

If cStatus <> '2'
    cMsgErro := STR0022//"Status atual da Ficha de Remessa não permite a conferência"
    cMsgSol  := ""
    lRet := .F.
Endif

If lRet .AND. !(VldArrecFch(@cMsgErro,@cMsgSol))
    lRet := .F.
EndIf

If lRet .AND. FunName() =="GTPA421" .AND. !(G421CValConf(@cMsgErro,@cMsgSol))
    lRet := .F.
EndIf

If !lRet
    oModel:SetErrorMessage(oModel:GetId(),,oModel:GetId(),,"G421CBVldAct",cMsgErro,cMsgSol,,)
Endif

Return lRet

//------------------------------------------------------------------------------
/*/{Protheus.doc} VldArrecFch
Valida se a ficha de remessa tem uma arrecadação
@type Function
@author 
@since 29/06/2020
@version 1.0
@param , character, (Descrição do parâmetro)
@return , return_description
@example
(examples)
@see (links_or_references)
/*/
//------------------------------------------------------------------------------
Function VldArrecFch(cMsgErro,cMsgSol)

Local lRet      := .T.
Local cAgencia  := G6X->G6X_AGENCI
Local cNumFch   := G6X->G6X_NUMFCH
Local cQuery    := ''
Local oQryTmp   as object
Local cAliasTmp as character

cQuery := "SELECT G59.R_E_C_N_O_ RECNO "
cQuery += " FROM " + RetSqlName('G59') + " G59 "
cQuery += " WHERE G59.G59_FILIAL = ? "
cQuery += "     AND G59.G59_AGENCI = ? "
cQuery += "     AND G59.G59_NUMFCH = ? "
cQuery += "     AND G59.D_E_L_E_T_ = ' ' "

cQuery := ChangeQuery(cQuery)

oQryTmp := FwExecStatement():New(cQuery)
oQryTmp:SetString(1, xFilial("G59"))
oQryTmp:SetString(2, cAgencia)
oQryTmp:SetString(3, cNumFch)

cAliasTmp := oQryTmp:OpenAlias()

If !(cAliasTmp)->(Eof())
    lRet := .F.
    cMsgErro := STR0023//"Fechamento da arrecadação criada para está ficha."
    cMsgSol  := STR0024//"Exclua a arrecadação antes de conferir novamente."
EndIf

(cAliasTmp)->(DbCloseArea())

Return lRet 

//------------------------------------------------------------------------------
/*/{Protheus.doc} (oModel)
Confere todos os bilhetes disponiveis na grid

@type  Static Function
@param oModel
@return
@example (examples)
@see (links_or_references)

@author Henrique Madureira
@since 27/10/2017
@version 1
/*/
//------------------------------------------------------------------------------
Static Function ConfereTudo(oView)

Local oGridGZG	:= oView:GetModel('GZGDETAIL')
Local lFiltrado	:= oView:GetViewObj('VIEW_DETAIL')[3]:oBrowse:Filtrate()
Local aFiltrado	:= Nil
Local nX		:= 0
Local lUsrConf  := GZG->(FieldPos('GZG_USUCON')) > 0
Local cUserLog  := AllTrim(RetCodUsr())

If !lFiltrado
	For nX := 1 To oGridGZG:Length()
		oGridGZG:GoLine(nX)
		If oGridGZG:GetValue('GZG_CONFER') == '1'
			oGridGZG:SetValue('GZG_CONFER', '2')
			
			If lUsrConf
                oGridGZG:LoadValue('GZG_USUCON', cUserLog )
                oGridGZG:LoadValue('GZG_DTCONF', dDataBase)
			EndIf

		Endif
	Next nX 
Else
	aFiltrado := oView:GetViewObj('VIEW_DETAIL')[3]:GetFilLines()
	For nX := 1 To Len(aFiltrado)
		oGridGZG:GoLine(aFiltrado[nX])
		If oGridGZG:GetValue('GZG_CONFER') == '1'
			oGridGZG:SetValue('GZG_CONFER', '2')

			If lUsrConf
				oGridGZG:LoadValue('GZG_USUCON', cUserLog )
			EndIf

		Endif
	Next nX
Endif

oGridGZG:GoLine(1)
GTPDestroy(aFiltrado)

Return

/*/{Protheus.doc} FieldValid(oMdl,cField,cNewValue,cOldValue) 
//TODO Descrição auto-gerada.
@author flavio.martins
@since 21/07/2020
@version 1.0
@return ${return}, ${return_description}
@param oModel, object, descricao
@type function
/*/
Static Function FieldValid(oMdl,cField,cNewValue,cOldValue) 
Local lRet := .T.

If cField == 'GZG_CONFER'

    If cNewValue == '3' .And. oMdl:GetValue('GZG_CARGA')
        lRet := .F.
        oMdl:GetModel():SetErrorMessage(oMdl:GetId(),,oMdl:GetId(),,"FieldValid",STR0025,,,) // "Receitas e Despesas geradas automaticamente não podem ser rejeitadas"
    Endif

Endif

Return lRet


//------------------------------------------------------------------------------
/*/{Protheus.doc} G421CValConf
Valida se possui itens a serem conferidos
@type Function
@author João Pires
@since 20/05/2024
@version 1.0
@param , character, (Descrição do parâmetro)
@return , return_description
@example
(examples)
@see (links_or_references)
/*/
//------------------------------------------------------------------------------
Static Function G421CValConf(cMsgErro,cMsgSol)
    Local lRet      := .T.
    Local cAgencia  := G6X->G6X_AGENCI
    Local cNumFch   := G6X->G6X_NUMFCH
    Local cTipo     := IIF(lOpDesej,"1","2")
    Local cQuery    := ''
    Local oQryTmp   as object
    Local cAliasTmp as character

    cQuery := "SELECT COUNT(GZG_SEQ) AS TOTAL "
    cQuery += " FROM " + RetSqlName('GZG') 
    cQuery += " WHERE GZG_FILIAL = ? "
    cQuery += "     AND GZG_AGENCI = ? " 
    cQuery += "     AND GZG_NUMFCH = ? "  
    cQuery += "     AND GZG_TIPO = ? " 
    cQuery += "     AND D_E_L_E_T_ = ' ' " 

    cQuery := ChangeQuery(cQuery)

    oQryTmp := FwExecStatement():New(cQuery)
    oQryTmp:SetString(1, xFilial("GZG"))
    oQryTmp:SetString(2, cAgencia)
    oQryTmp:SetString(3, cNumFch)
    oQryTmp:SetString(4, cTipo)

    cAliasTmp := oQryTmp:OpenAlias()
   
    If (cAliasTmp)->(Eof()) .OR. (cAliasTmp)->TOTAL == 0
        lRet := .F.
        IF lOpDesej
            cMsgErro := STR0028//"Não há registros de receitas na ficha selecionada."
        ELSE
            cMsgErro := STR0030//"Não há registros de despesas na ficha selecionada."
        ENDIF
        cMsgSol  := STR0029//"Não há conferencia a ser feita" 
    EndIf

    (cAliasTmp)->(DbCloseArea())

Return lRet 
