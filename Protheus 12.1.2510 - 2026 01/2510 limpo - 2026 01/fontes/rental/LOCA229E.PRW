#Include "LOCA229E.CH"
#INCLUDE "TOTVS.CH"
#include "FWMVCDEF.CH"
#INCLUDE "FWEditPanel.CH "

/*/{Protheus.doc} MODELDEF
Define o model da Separação de A.S.
@type function
@version  25.10
@author Alexandre Circenis
@since 4/1/2025
@return variant, Modelo de dados
/*/
STATIC FUNCTION MODELDEF()
Local oModel   
Local oStrFQU  := FWFormStruct( 1, 'FQU', /*bAvalCampo*/,/*lViewUsado*/ )
Local cGrupos  := LOCA00189()
Local cGrpACes := {}

cGrpAces := "('"+ StrTran( cGrupos, ";", "','" ) +"')"

oModel := MPFormModel():New( 'LOCA229E', /*bPreValidacao*/, /*bPosValidacao*/, /*bCommit*/, /*bCancel*/ )
// Adiciona ao modelo uma estrutura de formulário de edição por campo
oModel:AddFields( 'MASTER', /*cOwner*/, oStrFQU, /*bPreValidacao*/, /*bPosValidacao*/, /*bCarga*/ )
oModel := LOCA259EMD(oModel)

oModel:SetRelation( 'FQ5BEM', { { 'FQ5_FILIAL', 'xFilial("FQ5")' } ,{"FQ5_XROMAN","FQU_NUM"}, {"FQ5_STATUS" , "'1'"}}, FQ5->( IndexKey( 22 ) ) )
oModel:SetRelation( 'FQ5QTD', { { 'FQ5_FILIAL', 'xFilial("FQ5")' } ,{"FQ5_XROMAN","FQU_NUM"}, {"FQ5_STATUS" , "'1'"}}, FQ5->( IndexKey( 22 ) ) )
oModel:SetRelation( 'FQ5PAT', { { 'FQ5_FILIAL', 'xFilial("FQ5")' } ,{"FQ5_XROMAN","FQU_NUM"}, {"FQ5_STATUS" , "'1'"}}, FQ5->( IndexKey( 22 ) ) )

//oModel:GetModel( 'FQ5BEM'):SetLoadFilter( , " EXISTS ( SELECT T9_CODESTO FROM "+ RetSqlName("ST9") + " ST9 WHERE T9_FILIAL = '"+xFilial("ST9")+"' and T9_CODESTO = FQ5_XPROD and ST9.D_E_L_E_T_ = ' ')" ) 
//oModel:GetModel( 'FQ5QTD'):SetLoadFilter( , " NOT EXISTS ( SELECT T9_CODESTO FROM "+ RetSqlName("ST9") + " ST9 WHERE T9_FILIAL = '"+xFilial("ST9")+"' and T9_CODESTO = FQ5_XPROD and ST9.D_E_L_E_T_ = ' ' )" ) 
oModel:GetModel("RESUMO"):bLoad :=   {|oMdl| Loca229ELG(oMdl,FQU->FQU_NUM) }
oModel:GetModel("FH2QTD"):bLoad :=   {|oMdl| Loca259ELP(oMdl, oModel) }
// Adiciona a descricao do Modelo de Dados
oModel:SetDescription( STR0001 )  //"Separação Romaneio"
// Adiciona a descricao do Componente do Modelo de Dados
oModel:GetModel( 'MASTER' ):SetDescription( STR0002 )  //"Demanda" //"Romaneio"
 
oModel:GetModel( 'MASTER' ):SetOnlyView(.T.)

oModel:SetPrimaryKey({"FQU_FILIAL","FQU_NUM"})

Return oModel


//-----------------------------------------------------------------------------
/*/{Protheus.doc}ViewDef
Interface.
@type Function 
@author Alexandre Circenis
@since  01/04/2025
@version 25.10
/*/	
Static Function ViewDef()
Local oView := FWFormView():New()
Local oModel := FWLoadModel("LOCA229E")
Local oStrFQU	:= FWFormStruct(2,'FQU', {|cCampo| cCampo $ "FQU_NUM    FQU_PROJET FQU_OBRA   "})

oStrFQU:SetProperty("FQU_NUM", MVC_VIEW_GROUP_NUMBER, "" )
oStrFQU:SetProperty("FQU_PROJET", MVC_VIEW_GROUP_NUMBER, "")
oStrFQU:SetProperty("FQU_OBRA", MVC_VIEW_GROUP_NUMBER, "")
oStrFQU:aGroups := {}

oView:SetModel( oModel )

oView:AddField("VIEW_MASTER",oStrFQU,"MASTER")

oView := Loca529EVI(oView, oModel)
oView:SetViewAction("BUTTONOK", { |oView| Loca259EPR( oView, .T. ) } ) 

RETURN oView

/*/{Protheus.doc} Loca229ELG
Retorna o array de dados dados para carga do Model de REsumo dos itens com bens
@type function
@version 25.10 
@author Alexandre Circenis
@since 4/1/2025
@param oGrid, object, Grid que será carregado
@param cDemanda, character, Demanda em processamento
@return variant, Array com os dados
/*/
Function Loca229ELG(oGrid, cRomaneio)
Local aArea := GetArea()
Local aDados := {}
Local cQuery := ""
Local aBindParam := {}
Local cItem      := '001'
Local aLinha

cQuery += "SELECT FQ5_XPROD, SUM(FQ5_XQTD) FPA_QUANT, FPA_LOCAL"
cQuery += " FROM "+RetSqlName("FQ5")+ " FQ5"
cQuery += " INNER JOIN "+RetSqlName("FPA")+ " FPA"
cQuery += "  ON FPA_FILIAL = '"+xFilial("FPA")+"'"
cQuery += "  and FPA_AS = FQ5_AS "
cQuery += "  and FPA.D_E_L_E_T_ = ' '"
cQuery += " WHERE FQ5_FILIAL = '"+xFilial("FQ5")+"'"
cQuery += " AND FQ5_STATUS = '1'"
cQuery += " and FQ5_XROMAN = ?"
Aadd( aBindParam, cRomaneio)
cQuery += " and Exists ( SELECT T9_CODESTO FROM "+RetSqlName("ST9")+ " ST9"
cQuery += "  WHERE T9_FILIAL = '"+xFilial("ST9")+"'"
cQuery += "  and T9_CODESTO = FQ5_XPROD "
cQuery += "  and ST9.D_E_L_E_T_ = ' ' )"
cQuery += " and  NOT EXISTS ( SELECT B1_COD FROM "+RetSqlName("SB1") + " SB1"  
cQuery += "   INNER JOIN "+RetSqlName("SBM") + " SBM"  
cQuery += "   ON BM_FILIAL = '"+xFilial("SBM")+"' and BM_GRUPO = B1_GRUPO and BM_XACESS = '3'and SBM.D_E_L_E_T_ = ' '
cQuery += "   WHERE B1_FILIAL = '"+xFilial("SB1")+"' and B1_COD = FQ5_XPROD and SB1.D_E_L_E_T_ = ' ' )"

cQuery += " GROUP BY  FQ5_XPROD, FPA_LOCAL"
cQuery += " ORDER BY  FQ5_XPROD, FPA_LOCAL"

cQuery := ChangeQuery(cQuery)
MPSysOpenQuery(cQuery,"FQ5TRB",,,aBindParam)

aLinha := {  }
While !(FQ5TRB->(Eof()))

	SB1->(dbSetOrder(1))
	SB1->(dbSeek(xFilial("SB1")+FQ5TRB->FQ5_XPROD))

	Aadd(aLinha, cItem )   // Item
	Aadd(aLinha, FQ5TRB->FQ5_XPROD ) // Produto
	Aadd(aLinha, SB1->B1_DESC )  // Descricao
	Aadd(aLinha, SB1->B1_UM )    // Unidade
	Aadd(aLinha, FQ5TRB->FPA_QUANT ) // Quantidade
	Aadd(aLinha, FQ5TRB->FPA_LOCAL ) // Local
	Aadd(aLinha, Loca259EDB(FQ5TRB->FQ5_XPROD) )  // Disponival
	Aadd(aLinha, Loca229EEM(cRomaneio, FQ5TRB->FQ5_XPROD, .T.) ) // Empenhada Demanda
	Aadd(aLinha, Loca229EEM(cRomaneio, FQ5TRB->FQ5_XPROD, .F.) ) // Empenhada Outras demanda
	Aadd(aLinha, 0 )
	Aadd(aLinha, 0 )
	Aadd(aLinha, 0 )
	Aadd(aLinha, 0 )
	Aadd(aLinha, 0 )

	Aadd( aDados, { 0 , aLinha })

	FQ5TRB->(dbSkip())
	cItem  := Soma1(cItem)
	aLinha := {}

enddo

FQ5TRB->(dbCloseArea())
RestArea(aArea)

Return aDados


/*/{Protheus.doc} Loca229EEM
REtorna a quantidade de um produto empenhada na demanda ou em outras demandas
@type function
@version 25.10
@author Alexandre Circenis
@since 4/1/2025
@param cRomaneio, character, Romaneio analisado
@param cProduto, character, Produto Analisado
@param lNaDemanda, logical, Emepnhado na Demanda (.T.) ou em outras demandas (.F.)
@return variant, Quantidade empenhada
/*/
FUNCTION Loca229EEM(cRomaneio, cProduto, lNaDemanda)
Local nEmpenhada := 0
Local cQuery := ''
Local aArea := GetArea()
Local aBindParam := {}

cQuery := " SELECT SUM(FQ5_XQTD) EMPENHADA"
cQuery += " FROM "+RetSqlName("FQ5")
cQuery += " WHERE FQ5_FILIAL = '"+xFilial("FQ5")+ "'"
cQuery += " AND FQ5_XPROD = ?"
Aadd(aBindParam, cProduto)
if lNaDemanda 
	cQuery += " AND FQ5_XROMAN = ?"
else
	cQuery += " AND FQ5_XROMAN <> ?"
endif	
cQuery += " AND FQ5_DEMAND <> ' '"
cQuery += " AND FQ5_STATUS = '6'" // Considerar empenhada as A.S. Separada/Aceita

Aadd(aBindParam, cRomaneio)
cQuery += " AND D_E_L_E_T_ = ' '"
cQuery := ChangeQuery(cQuery)
MPSysOpenQuery(cQuery,"FQ5EMP",,,aBindParam)

if !FQ5EMP->(Eof())
	nEmpenhada := FQ5EMP->EMPENHADA
endif

FQ5EMP->(dbCloseArea())
RestArea(aArea)

Return nEmpenhada
