#INCLUDE "AGDA010G.ch"
#INCLUDE "TOTVS.ch"
#INCLUDE "FWMVCDEF.CH"


/*/{Protheus.doc} AGDA010G
Fonte para as regras de Grupo Familiar
AGDA10GPOS - Botao confirmar do AGDA010 - Validacoes para impedir salvar cliente fora do grupo familiar
@type function
@version P12
@author carlos.augusto
@since 17/10/2025
@return Logical, valor logico .T. ou .F.
/*/
Function AGDA10GPOS()
	Local lRet		 := .T.
	Local oModel	 := FWModelActive()
	Local oModelNEA	 := oModel:GetModel("AGDA010_NEA")
	Local oModelNEB	 := oModel:GetModel("AGDA010_NEB")
	Local nX         := 1
	Local aAreaNEA   := NEA->(FwGetArea())
	Local cCodGrpCab := ""

	If AGDA10GGRP(oModelNEA:GetValue("NEA_CODCLI"), oModelNEA:GetValue("NEA_LOJCLI"))
		cCodGrpCab := NEX->NEX_CODGRP
		For nX := 1 to oModelNEB:Length()
			oModelNEB:GoLine( nX )

			If !oModelNEB:IsDeleted() .And. !AGDA10GGRP(oModelNEB:GetValue("NEB_CLIENT"), oModelNEB:GetValue("NEB_LOJENT"))
				lRet := .F.
				AGDHELP(STR0001, AGD10GErro(1,cCodGrpCab), STR0002 ) //#"Ajuda""Verifique o cadastro do grupo familiar."

			ElseIf !oModelNEB:IsDeleted() .And. AGDA10GGRP(oModelNEB:GetValue("NEB_CLIENT"), oModelNEB:GetValue("NEB_LOJENT")) .And. cCodGrpCab != NEX->NEX_CODGRP
				lRet := .F.
				AGDHELP(STR0001, AGD10GErro(2,cCodGrpCab,NEX->NEX_CODGRP), STR0002 ) //#"Ajuda""Verifique o cadastro do grupo familiar."

			EndIf
		Next nX
	EndIf
	RestArea(aAreaNEA)
Return lRet


/*/{Protheus.doc} AGD10VLCLI
Chamado pela função AGD10VDNEB. Valid do campo NEB_CLIENT e NEB_LOJENT
Validacoes para não deixar inserir cliente fora do grupo familiar da negociação
@type function
@version P12
@author carlos.augusto
@since 17/10/2025
@return Logical, valor logico .T. ou .F.
/*/
Function AGD10VLCLI(cReadVar)
	Local lRet      := .T.
	Local oModel    := FwModelActive()
	Local oModelNEB	:= oModel:GetModel("AGDA010_NEB")
	Local oModelNEA	:= oModel:GetModel("AGDA010_NEA")
	Local cCodGrpCab := ""
	Local aAreaSA1  := SA1->(FwGetArea())

	//Se encontrar o cadastro de grupo familiar do cabecalho, verifica se existe vinvculo com cliente do insumo
	If AGDA10GGRP(oModelNEA:GetValue("NEA_CODCLI"), oModelNEA:GetValue("NEA_LOJCLI"))
		cCodGrpCab := NEX->NEX_CODGRP
		If "NEB_CLIENT" $ cReadVar .And. !AGDA10GGRP(oModelNEB:GetValue("NEB_CLIENT"))
			lRet := .F.
			AGDHELP(STR0001, AGD10GErro(1, cCodGrpCab), STR0002) //#"Ajuda""Verifique o cadastro do grupo familiar."
		EndIf
		If "NEB_LOJENT" $ cReadVar 
			If !AGDA10GGRP(oModelNEB:GetValue("NEB_CLIENT"),oModelNEB:GetValue("NEB_LOJENT"))
				lRet := .F.
				AGDHELP(STR0001, AGD10GErro(1, cCodGrpCab), STR0002 ) //#"Ajuda""Verifique o cadastro do grupo familiar."
			ElseIf AGDA10GGRP(oModelNEB:GetValue("NEB_CLIENT"),oModelNEB:GetValue("NEB_LOJENT")) .And. cCodGrpCab != NEX->NEX_CODGRP
				AGDHELP(STR0001, AGD10GErro(2, cCodGrpCab, NEX->NEX_CODGRP), STR0002) //#"Ajuda""Verifique o cadastro do grupo familiar."
				lRet := .F.
			EndIf
		EndIf
	EndIf

	RestArea(aAreaSA1)
Return lRet


/*/{Protheus.doc} AGDNEBNEX
Chamado pela consulta padrão de grupo familiar NEB001. Consulta inseri em NEB_CLIENT
Faz o filtro de clientes que fazem parte do grupo familiar
@type function
@version P12
@author carlos.augusto
@since 17/10/2025
@return Logical, valor logico .T. ou .F.
/*/
Function AGDNEBNEX()
	Local oModel    := FwModelActive()
	Local oModelNEA	:= oModel:GetModel("AGDA010_NEA")
	Local cWhere    := ""
	Local cCodGrpCab := ""

	//Se encontrar o cadastro de grupo familiar do cabecalho, verifica se existe vinvculo com cliente do insumo
	If AGDA10GGRP(oModelNEA:GetValue("NEA_CODCLI"),oModelNEA:GetValue("NEA_LOJCLI"))
		cCodGrpCab := NEX->NEX_CODGRP
		cWhere  += "@D_E_L_E_T_ = ' ' "
		cWhere  += " AND EXISTS ( "
		cWhere  += " SELECT 1 "
		cWhere  += " FROM "+RetSqlName('NEX')+" NEX "
		cWhere  += " WHERE NEX.NEX_FILIAL = '"+ FwXFilial("NEX") +"'"
		cWhere  += " AND NEX.NEX_CODGRP = '"+cCodGrpCab+"' "
		cWhere  += " AND NEX.NEX_CODCLI = A1_COD "
		cWhere  += " AND NEX.NEX_LOJCLI = A1_LOJA "
		cWhere  += " AND NEX.D_E_L_E_T_ = ' ') "
	EndIf
Return cWhere


/*/{Protheus.doc} AGDA10When
Caso o cliente da negociação e o cliente do insumo estejam em grupo familiar serão bloqueados cliente e loja.
@type function
@version P12
@author carlos.augusto
@since 17/10/2025
@return Logical, valor logico .T. ou .F.
/*/
Function AGDA10When(cCampoNEA)
	Local lRet		  := .T.
	Local oModel	  := FWModelActive()
	Local oModelNEA	  := oModel:GetModel("AGDA010_NEA")
	Local oModelNEB	  := oModel:GetModel("AGDA010_NEB")
	Local nX          := 1
	Default cCampoNEA := ""

	If cCampoNEA == "NEA_CODCLI" .Or. cCampoNEA == "NEA_LOJCLI"
		If	AGDA10GGRP(oModelNEA:GetValue("NEA_CODCLI"),oModelNEA:GetValue("NEA_LOJCLI"))
			For nX := 1 to oModelNEB:Length()
				oModelNEB:GoLine( nX )
				If !oModelNEB:IsDeleted() .and. AGDA10GGRP(oModelNEB:GetValue("NEB_CLIENT"),oModelNEB:GetValue("NEB_LOJENT"))
					lRet := .F.
					exit
				EndIf
			Next nX
		EndIf
	EndIf
Return lRet

/*/{Protheus.doc} AGDA10GGRP
Valida se cliente faz parte de um grupo familiar
@type function
@version P12
@author carlos.augusto
@since 17/10/2025
@return Logical, valor logico .T. ou .F.
/*/
Function AGDA10GGRP(cCliente, cLoja)
	Local lRet    := .F.
	Default cLoja := ""

	If TableInDic('NEX') 
		DbSelectArea("NEX")
		NEX->(DbSetOrder(2))
		If NEX->(DBSeek(FWxFilial("NEX")+cCliente+cLoja))
			lRet := .T.
		EndIf
	EndIf
Return lRet


/*/{Protheus.doc} AGD10GErro
Centraliza mensagem de erro para grupo familiar
@type function
@version P12
@author carlos.augusto
@since 17/10/2025
@return Logical, valor logico .T. ou .F.
/*/
Static Function AGD10GErro(nErro, cCodGrpCab, cCodGrpIte)
	Local cMsgErro     := ""
	Default cCodGrpCab := ""
	Default cCodGrpIte := ""

	Do Case
		Case nErro == 1
			//"O cliente informado em 'Dados da Negociação' faz parte do grupo familiar "" e o cliente informado em 'Insumos para Venda' não faz parte deste grupo."
			cMsgErro := STR0003 + cCodGrpCab + STR0004 
		Case nErro == 2
			//"O cliente informado em 'Dados da Negociação' faz parte do grupo familiar "" e o cliente informado em 'Insumos para Venda' faz do grupo familiar "
			cMsgErro := STR0003 + cCodGrpCab +STR0005 + cCodGrpIte+"."
	EndCase

Return cMsgErro


/*/{Protheus.doc} AGD10GGAT1
Gatilho incluido na NEB_CLIENT. Verifica se o cliente da negociacao faz parte do grupo familiar.
Se faz, gatilha a primeira loja do grupo.
Se não, gatilha loja do primeiro cliente com o codigo
@type function
@version P12
@author carlos.augusto
@since 22/10/2025
@return Logical, valor logico .T. ou .F.
/*/
Function AGD10GGAT1(cCliente)
	Local oModel    := FwModelActive()
	Local oModelNEA	:= oModel:GetModel("AGDA010_NEA")
	Local cLoja     := Space(TamSX3("NEB_LOJENT")[1])
	Local aAreaSA1  := SA1->(FwGetArea())

	//Se encontrar o cadastro de grupo familiar do cabecalho, verifica se existe vinvculo com cliente do insumo
	If AGDA10GGRP(oModelNEA:GetValue("NEA_CODCLI"),oModelNEA:GetValue("NEA_LOJCLI"))
		If AGDA10GGRP(cCliente)
			cLoja := NEX->NEX_LOJCLI
		EndIf
	Else
		SA1->(DbSetOrder(1))
		If SA1->(DbSeek(FwXFilial("SA1")+cCliente))
			cLoja := SA1->A1_LOJA
		EndIf
	EndIf
	
	RestArea(aAreaSA1)

Return cLoja
