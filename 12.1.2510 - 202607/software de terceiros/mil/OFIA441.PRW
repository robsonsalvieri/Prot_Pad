#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "OFIA441.CH"

/*/{Protheus.doc} OFIA441()
Movimentações das Promoções VBN - Filho do Cadastro OFIA440 - Incluir VBN em MVC

@author Andre Luis Almeida
@since 26/05/2022
@version 1.0
@return NIL
/*/
Function OFIA441()
Return NIL

/*/{Protheus.doc} MenuDef()
Função para criação do menu 

@author Andre Luis Almeida
@since 26/05/2022
@version 1.0
@return aRotina 
/*/
Static Function MenuDef()
Local aRotina := {}
ADD OPTION aRotina TITLE STR0002 ACTION 'VIEWDEF.OFIA441' OPERATION 2 ACCESS 0 // Visualizar
ADD OPTION aRotina TITLE STR0003 ACTION 'VIEWDEF.OFIA441' OPERATION 3 ACCESS 0 // Incluir
Return aRotina

/*/{Protheus.doc} ModelDef
Definição do modelo de Dados

@author Andre Luis Almeida
@since 26/05/2022
@version 1.0
@Return oModel
/*/
Static Function ModelDef()
Local oStrVBN := FWFormStruct(1,"VBN")

oModel := MPFormModel():New("OFIA441", /* bPre */, /* bPost */ , /* bCommit */ , /* bCancel */ )

oModel:AddFields("VBNMASTER",/*cOwner*/ , oStrVBN)

oModel:SetDescription(STR0001) // Movimentações das Promoções

//oModel:InstallEvent("OFIA441LOG", /*cOwner*/, MVCLOGEV():New("OFIA441") ) // CONSOLE.LOG para verificar as chamadas dos eventos

Return oModel

/*/{Protheus.doc} ViewDef
Definição do interface

@author Andre Luis Almeida
@since 26/05/2022
@version 1.0
@Return oView
/*/
Static Function ViewDef()
Local oView
Local oModel := ModelDef()
Local oStrVBN:= FWFormStruct(2,"VBN")

oView := FWFormView():New()
oView:SetModel(oModel)

oView:AddField( 'VIEW_VBN', oStrVBN, 'VBNMASTER' )

// definição de como será a tela
oView:CreateHorizontalBox('CABEC' ,100)
oView:SetOwnerView('VIEW_VBN', 'CABEC' )

oView:SetCloseOnOk({||.T.})

Return oView

/*/
{Protheus.doc} OA4410011_Incluir_Movimentacoes_Promocao
Incluir o VBN - Movimentações das Promoções

@author Andre Luis Almeida
@since 26/05/2022
/*/
Function OA4410011_Incluir_Movimentacoes_Promocao( cSeqVEN , cTipMov , nQtdMov , cFilOrc , cNumOrc , cSeqOrc , cObserv )
Local oModVBN := FWLoadModel( 'OFIA441' )
Local lRetVBN := .f.
Local cCodVBM := OA4400011_Codigo_Saldo_Promocao( cSeqVEN )
Local cQuery  := ""
If !Empty(cCodVBM)
	If cCodVBM == "SEM_VBM" // Validar quando não existir o Cadastro do VBM
		Help("",1,"OA4410011_Incluir_Movimentacoes_Promocao",,STR0004,1,0) // Não existe o Cadastro do Saldo da Promoção. Impossivel continuar.
		Return .f.
	EndIf
	If cTipMov == "1" // Utilização
		If OA4410021_Saldo_Promocao( cCodVBM ) < nQtdMov // Verificar se Saldo é MENOR que a quantidade que deseja utilizar
			Help("",1,"OA4410011_Incluir_Movimentacoes_Promocao",,STR0005,1,0) // Não existe Saldo da Promoção. Impossivel continuar.
			Return .f.
		EndIf
	ElseIf cTipMov == "2" // Devolução
		cQuery := "SELECT R_E_C_N_O_"
		cQuery += "  FROM "+RetSqlName("VBN")
		cQuery += " WHERE VBN_FILIAL = '"+xFilial("VBN")+"'"
		cQuery += "   AND VBN_CODVBM = '"+cCodVBM+"'"
		cQuery += "   AND VBN_TIPMOV = '1'"
		cQuery += "   AND VBN_FILORC = '"+cFilOrc+"'"
		cQuery += "   AND VBN_NUMORC = '"+cNumOrc+"'"
		cQuery += "   AND VBN_SEQORC = '"+cSeqOrc+"'"
		cQuery += "   AND D_E_L_E_T_ = ' '"
		If FM_SQL(cQuery) == 0
			Return .t. // Se não foi criada a utilização, NÃO devolve pro VBM e deixa seguir o processo
		EndIf
	EndIf
	oModVBN:SetOperation( MODEL_OPERATION_INSERT )
	lRetVBN := oModVBN:Activate()
	if lRetVBN
		oModVBN:LoadValue( "VBNMASTER" , "VBN_CODVBM" , cCodVBM )
		oModVBN:LoadValue( "VBNMASTER" , "VBN_CODIGO" , GetSXENum("VBN","VBN_CODIGO") )
		oModVBN:LoadValue( "VBNMASTER" , "VBN_TIPMOV" , cTipMov )
		oModVBN:LoadValue( "VBNMASTER" , "VBN_DATMOV" , dDataBase )
		oModVBN:LoadValue( "VBNMASTER" , "VBN_HORMOV" , SUBSTR(time(),1,2)+SUBSTR(time(),4,2))
		oModVBN:LoadValue( "VBNMASTER" , "VBN_QTDMOV" , nQtdMov )
		oModVBN:LoadValue( "VBNMASTER" , "VBN_FILORC" , cFilOrc )
		oModVBN:LoadValue( "VBNMASTER" , "VBN_NUMORC" , cNumOrc )
		oModVBN:LoadValue( "VBNMASTER" , "VBN_SEQORC" , cSeqOrc )
		oModVBN:LoadValue( "VBNMASTER" , "VBN_OBSERV" , cObserv )
		oModVBN:LoadValue( "VBNMASTER" , "VBN_USRMOV" , __cUserID )
		If oModVBN:VldData()
			oModVBN:CommitData()
		EndIf
		oModVBN:DeActivate()
	EndIf
EndIf
FreeObj(oModVBN)
Return lRetVBN

/*/
{Protheus.doc} OA4410021_Saldo_Promocao
Saldo do VBN - Movimentações da Promoção

@author Andre Luis Almeida
@since 26/05/2022
/*/
Function OA4410021_Saldo_Promocao( cCodVBM )
Local cQuery  := ""
cQuery := "SELECT SUM( VBN_QTDMOV * CASE VBN_TIPMOV WHEN '1' THEN -1 ELSE 1 END ) QTDATU"
cQuery += "  FROM "+RetSqlName("VBN")
cQuery += " WHERE VBN_FILIAL = '"+xFilial("VBN")+"'"
cQuery += "   AND VBN_CODVBM = '"+cCodVBM+"'"
cQuery += "   AND D_E_L_E_T_ = ' '"
Return FM_SQL(cQuery)