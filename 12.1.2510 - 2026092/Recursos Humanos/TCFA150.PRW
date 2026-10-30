#INCLUDE "TOTVS.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "TCFA150.CH"

PUBLISH MODEL REST NAME TCFA150  

Function TCFA150()

	Local lRux	  := ChkFile("RUX")
	Local oBrowse := FWMBrowse():New()

    IF !lRux
        Help(" ",1,STR0002,NIL, STR0003,1,0) // Atenção! - Tabela RUX não encontrada. Atualize o seu ambiente
        Return
    EndIf
	
	DbSelectArea("RUX")
	DbSetOrder(1)
	
	oBrowse:SetAlias("RUX")
	oBrowse:SetDescription(STR0001) // Cadastro dos tipos de notificação
	oBrowse:SetMenuDef("TCFA150")

	// Inicia registros caso n existam.
	TCFA150SRV()

    //Ativa a tela.
    oBrowse:Activate()

Return

/*/{Protheus.doc} MenuDef
Disponibiliza as Operações da rotina
@type  Static Function
@author Henrique Ferreira
@since 05/10/2021
@return aRotina, Array, Operações disponíveis no menu da rotina
/*/
Static Function MenuDef()
	
	Local aRotina := {}

	ADD OPTION aRotina Title STR0005  Action "VIEWDEF.TCFA150" 	OPERATION 2 ACCESS 0	//"Visualizar"  
	ADD OPTION aRotina Title STR0004  Action "VIEWDEF.TCFA150" 	OPERATION 4 ACCESS 0	//"Alterar" 
	
Return aRotina

/*/{Protheus.doc} ModelDef
Regras de modelagem da gravação.
@author Henrique Ferreira
@since 17/01/2024
@version 12.1.2410

@return nulo
/*/
Static Function ModelDef()
	Local oModel := MPFormModel():New("TCFA150")
	Local oStruRUX:= FWFormStruct(1,"RUX")

	oModel:addFields("RUXMASTER",NIL,oStruRUX)

	oModel:SetDescription( STR0001 )

Return oModel

/*/{Protheus.doc} ViewDef
Regras de interface do usuário.
@author Henrique Ferreira
@since 17/01/2024
@version 12.1.2410
@return nulo
/*/
Static Function ViewDef()
	Local oModel := FWLoadModel( "TCFA150" )
	Local oView := FWFormView():New()
	Local oStruRUX:= FWFormStruct(2,"RUX")

	oView:SetModel(oModel)
	oView:addField("RUXMASTER",oStruRUX)
	oView:SetCloseOnOk({|| .T.}) // remove o botão salvar e criar novo.
	
Return oView

Static Function TCFA150SRV()
	Local aArea			:= GetArea()
	Local aRegistros 	:= {}
	Local cVersao		:= "002"
	Local cCliVersao	:= ""

	// Array onde constarão os tipos de notificação disponibilizados.
	Aadd(aRegistros,{"001" ,STR0006 /* Envelope */			   , STR0007 /*"Ficou Sabendo?"*/ 				   ,STR0008 /*"Seu envelope de pagamento está disponível!"*/ })
	Aadd(aRegistros,{"002" ,STR0010 /* Férias - Solicitação */ , STR0011 /*"Tem funcionário pedindo férias!"*/ ,STR0012 /*"Clique aqui e finalize a pendência de aprovação de férias!"*/ })
	Aadd(aRegistros,{"003" ,STR0013 /* Férias - Aprovação*/    , STR0014 /*"Ótima notícia!"*/                  ,STR0015 /*"Suas férias foram aprovadas! Aproveite cada momento de suas férias e volte renovado!"*/ })
	Aadd(aRegistros,{"004" ,STR0016 /* Férias - Reprovação*/   , STR0017 /*"Suas férias não foram aprovadas."*/,STR0018 /*"Veja com o seu gestor ou RH o motivo da não aprovação."*/ })

	RUX->( DbGoTop() )
	If RUX->(dbSeek(FWxFilial("RUX") + "001")) // Busca sempre o primeiro registro do envelope.
		cCliVersao := RUX->( RUX_VERSAO )
	EndIf
	
	RestArea(aArea)

	If !( cVersao == cCliVersao )
		Processa({|| AtuRUX( aRegistros, cVersao )}, STR0009) //"Atualizando tabela dos tipos de notificação."
	EndIf

Return

/*/{Protheus.doc} AtualRJD
//Realiza o controle de atualizacao da tabela RJD
@author Henrique Ferreira
@since 29/01/2024
@version 1.0
@param aRegistros, array, descricao
@param cVersao, characters, descricao
@type function
/*/
Static Function AtuRUX( aRegistros, cVersao )

	Local nRegs := Len(aRegistros)
	Local nX 	:= 0

	RUX->( DbGoTop() )
	RUX->(dbSetOrder(1))

	// Verifica se achou o primeiro registro.
	For nX := 1 To nRegs
		// Se não encontrar, cria o registro.
		If !( RUX->(dbSeek(xFilial("RUX") + aRegistros[nX,1])))
			Begin Transaction
				RecLock("RUX", .T.)
					RUX->RUX_FILIAL := xFilial("RUX")
					RUX->RUX_CODIGO := aRegistros[nX,1]
					RUX->RUX_DESCRI := aRegistros[nX,2]
					RUX->RUX_TITULO := aRegistros[nX,3]
					RUX->RUX_MENSAG := aRegistros[nX,4]
					RUX->RUX_VERSAO	:= cVersao
					RUX->(MsUnLock())
			End Transaction
		Endif
	Next nX
Return



