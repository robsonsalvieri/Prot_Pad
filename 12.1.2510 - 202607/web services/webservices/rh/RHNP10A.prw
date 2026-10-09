#INCLUDE "TOTVS.CH"
#INCLUDE "APWEBSRV.CH"
#INCLUDE "RESTFUL.CH"
#INCLUDE "RHNP10.CH"

/*/{Protheus.doc} fDependents
- Retorna uma lista com os dependentes cadastrados para o usuário logado.

@author:	Henrique Ferreira
@since:		20/12/2021
@param:		cBranchVld - Filial do usuário logado;
			cMatSRA    - Matrícula do usuário logado.;
/*/
Function fDependents( cBranchVld, cMatSRA )

Local aArea			:= GetArea()
Local aDepedents	:= {}
Local oDependente	:= NIL

DEFAULT cBranchVld	:= ""
DEFAULT cMatSRA		:= ""

DbSelectArea("SRB")
DbSetOrder(1)
If SRB->( dbSeek( cBranchVld + cMatSRA ) )
	while SRB->(!eof()) .And. SRB->RB_FILIAL == cBranchVld .And. SRB->RB_MAT == cMatSRA
		oDependente := JsonObject():New()
		oDependente["id"] := SRB->RB_COD
		oDependente["label"] := AllTrim( SRB->RB_NOME )

		aAdd( aDepedents, oDependente )
		SRB->( dbSkip() )
	endDo
EndIf
FreeObj( oDependente )
RestArea(aArea)

Return aDepedents

/*/{Protheus.doc} detailDependent
- Retorna os detalhes do dependente selecionado

@author:	Henrique Ferreira
@since:		20/12/2021
@param:		cBranchVld - Array com os dados da transferencia;
			cBranchVld - Posicao do registro que esta sendo avaliado dentro do array;
			oDependente - Alias da query recebido por referencia;
/*/
Function detailDependent( cBranchVld, cMatSRA, cId, oDetail )

Local aArea			:= GetArea()
Local oGeneralData  := NIL
Local oRegisterData := NIL
Local oRecord		:= NIL

DEFAULT cBranchVld	:= ""
DEFAULT cMatSRA		:= ""
DEFAULT cId			:= ""
DEFAULT oDetail 	:= JsonObject():New()

DbSelectArea("SRB")
DbSetOrder(1)
If SRB->( dbSeek( cBranchVld + cMatSRA + cId ) )

	oDetail := JsonObject():New()

	oRegisterData := JsonObject():New()
	oRegisterData["degreeOfDependence"] := fGrauDep( SRB->RB_GRAUPAR )
	oRegisterData["gender"] := If( SRB->RB_SEXO == "M", "male", "female")
	oRegisterData["cpf"] := SRB->RB_CIC
	oRegisterData["birthDate"] := formatGMT( DTOS( SRB->RB_DTNASC ), .T. )
	oRegisterData["birthCity"] := EncodeUTF8( AllTrim( SRB->RB_LOCNASC ) )
	oRegisterData["uf"] := NIL

	oDetail["registerData"] := oRegisterData

	oRecord := JsonObject():New()
	oRecord["record"] := AllTrim( SRB->RB_NUMAT )
	oRecord["registry"] := AllTrim( SRB->RB_NREGCAR )
	oRecord["page"] := AllTrim( SRB->RB_NUMFOLH )
	oRecord["certificateDelivery"] := IIf( !Empty( SRB->RB_DTENTRA ), formatGMT( DTOS( SRB->RB_DTENTRA ), .T. ), "" )
	oRecord["book"] := AllTrim( SRB->RB_NUMLIVR )

	oDetail["record"] := oRecord

	oGeneralData := JsonObject():New()
	oGeneralData["incidence"] := fTpDpIr( SRB->RB_TIPIR )
	oGeneralData["sitSalFamily"] := fTpDpSf( SRB->RB_TIPSF )

	oDetail["generalData"] := oGeneralData
EndIf

Freeobj(oGeneralData)
Freeobj(oRecord)
Freeobj(oRegisterData)
RestArea(aArea)

Return .T.

/*/{Protheus.doc} fBeneficiaries
- Retorna uma lista com os beneficiários cadastrados para o usuário logado.

@author:	Henrique Ferreira
@since:		20/12/2021
@param:		cBranchVld - Array com os dados da transferencia;
			cBranchVld - Posicao do registro que esta sendo avaliado dentro do array;
			oDependente - Alias da query recebido por referencia;
/*/
Function fBeneficiaries( cBranchVld, cMatSRA )
Local aArea			:= GetArea()
Local aBeneficiares	:= {}
Local oBeneficiares	:= NIL

DEFAULT cBranchVld	:= ""
DEFAULT cMatSRA		:= ""

DbSelectArea("SRQ")
DbSetOrder(1)
If SRQ->( dbSeek( cBranchVld + cMatSRA ) )
	while SRQ->(!eof()) .And. SRQ->RQ_FILIAL == cBranchVld .And. SRQ->RQ_MAT == cMatSRA .And. SRQ->RQ_SEQUENC == "01"
		oBeneficiares := JsonObject():New()
		oBeneficiares["id"] := SRQ->RQ_ORDEM + "|" + SRQ->RQ_SEQUENC
		oBeneficiares["label"] := AllTrim( SRQ->RQ_NOME )

		aAdd( aBeneficiares, oBeneficiares )
		SRQ->( dbSkip() )
	endDo
EndIf
FreeObj( oBeneficiares )
RestArea(aArea)

Return aBeneficiares

/*/{Protheus.doc} detailBeneficiary
- Busca os detalhes do beneficiário

@author:	Henrique Ferreira
@since:		20/12/2021
@param:		cBranchVld - Array com os dados da transferencia;
			cBranchVld - Posicao do registro que esta sendo avaliado dentro do array;
			oDependente - Alias da query recebido por referencia;
/*/
Function detailBeneficiary( cBranchVld, cMatSRA, aId, oDetail )

Local aArea			:= GetArea()
Local cOrdem		:= ""
Local cSeq			:= ""
Local lLenId		:= .F.
Local oBenefits  	:= NIL
Local oRegisterData := NIL
Local oPayment		:= NIL
Local oNormalReg	:= NIL
Local oVacation		:= NIL
Local oPLR			:= NIL
Local oChristmas	:= NIL

DEFAULT cBranchVld	:= ""
DEFAULT cMatSRA		:= ""
DEFAULT aId			:= {}
DEFAULT oDetail 	:= JsonObject():New()

lLenId := Len( aId ) >= 2
cOrdem := IIf( lLenId, aId[1], "" )
cSeq := IIf( lLenId, aId[2], "" )

DbSelectArea("SRQ")
DbSetOrder(1)
If SRQ->( dbSeek( cBranchVld + cMatSRA + cOrdem + cSeq ) )

	oDetail := JsonObject():New()

	oRegisterData := JsonObject():New()
	oRegisterData["cpf"] := SRQ->RQ_CIC
	oRegisterData["pensionSituation"] := fPensaoSituation( SRQ->RQ_DTFIM )
	oRegisterData["situationData"] := formatGMT( DTOS( dDataBase ), .T. )
	oDetail["registerData"] := oRegisterData

	oBenefits := JsonObject():New()
	oBenefits["pension"] := EncodeUTF8( STR0018 ) // "Pensão Alimentícia."
	oDetail["benefits"] := oBenefits

	oPayment := JsonObject():New()
	oPayment["paymentMethod"] := IIf( SRQ->RQ_TPCTSAL == "2", EncodeUTF8( STR0020 ), EncodeUTF8( STR0019 ) )
	oPayment["bank"] := SubStr( SRQ->RQ_BCDEPBE, 1, 3 )
	oPayment["agency"] := SubStr( SRQ->RQ_BCDEPBE, 4, 4 )
	oPayment["currentAccount"] := AllTrim( SRQ->RQ_CTDEPBE )
	oDetail["paymentMethodCard"] := oPayment

	oNormalReg := JsonObject():New()
	oNormalReg["calculationTypeBase"] := cValToChar( SRQ->RQ_PERCENT ) + "%"
	oNormalReg["calculationTypePension"] := IIf( SRQ->RQ_NRSLMIN > 0, ; 
												EncodeUTF8( STR0021 ),; 	  // "Pensão sobre Sal. Mínimo."
												Iif( SRQ->RQ_VALFIXO > 0, ;
													EncodeUTF8( STR0022 ), ;  // "Pensão em valor Fixo."
													EncodeUTF8( STR0023 ) ) ) // "Pensão calculada sobre o líquido."
	oDetail["normalRegister"] := oNormalReg

	oVacation := JsonObject():New()
	oVacation["calculationTypeBase"] := NIL
	oVacation["calculationTypePension"] := NIL
	oDetail["vacationRegister"] := oVacation

	oPLR := JsonObject():New()
	oPLR["calculationTypeBase"] := NIL
	oPLR["calculationTypePension"] := NIL
	oDetail["prlRegister"] := oPLR

	oChristmas := JsonObject():New()
	oChristmas["calculationTypeBase"] := NIL
	oChristmas["calculationTypePension"] := NIL
	oDetail["christmasBonusSalary"] := oChristmas
EndIf

Freeobj( oRegisterData )
Freeobj( oNormalReg )
Freeobj( oPayment )
Freeobj( oBenefits )
RestArea(aArea)

Return .T.


/*/{Protheus.doc} fPensaoSituation
- Verifica a situação da pensão conforme a data fim.

@author:	Henrique Ferreira
@since:		10/08/2022
@param:		dDataFim - Data de término da pensão.
/*/

Function fPensaoSituation( dDataFim )

Local cSituation := EncodeUTF8( STR0016 ) // "Ativa."

DEFAULT dDataFim := Ctod("//")

If !Empty( dDataFim ) .And. dDataFim <= dDataBase
	cSituation := EncodeUTF8( STR0017 ) // "Inativa."
EndIf

Return cSituation


/*/{Protheus.doc} fGrauDep
- Retorna o grau de parentesco do dependente conforme o tipo passado.

@author:	Henrique Ferreira
@since:		10/08/2022
@param:		cTipo - Tipo do dependente.
/*/
Function fGrauDep( cTipo )

Local cRet := ""

DEFAULT cTipo = ""

If cTipo == "C"
   cRet := EncodeUTF8( STR0005 ) // "Cônjuge."
ElseIf cTipo == "F"
   cRet := EncodeUTF8( STR0006 ) // "Filho."
ElseIf cTipo == "E"
   cRet := EncodeUTF8( STR0007 ) // "Enteado."
elseif cTipo == "P"
   cRet := EncodeUTF8( STR0008 ) // "Pai/Mãe."
elseif cTipo == "O"
   cRet := EncodeUTF8( STR0009 ) // "Agregados/Outros."
Else
   cRet := EncodeUTF8( STR0004 ) // "Não Informado."
EndIf

Return cRet

/*/{Protheus.doc} fTpDpIr
- Retorna o tipo de dependência para fins de IRRF.

@author:	Henrique Ferreira
@since:		10/08/2022
@param:		cTipo - Tipo do dependente.
/*/
Function fTpDpIr( cTipo )

Local cRet := ""

DEFAULT cTipo = ""

If cTipo == "1"
   cRet := EncodeUTF8( STR0010 ) // "Dependente s/ limite de idade."
ElseIf cTipo == "2"
   cRet := EncodeUTF8( STR0011 ) // "Dependente até 21 anos."
ElseIf cTipo == "3"
   cRet := EncodeUTF8( STR0012 ) // "Dependente até 24 anos."
Else
   cRet := EncodeUTF8( STR0013 ) // "Não é dependente."
EndIf

Return cRet

/*/{Protheus.doc} fTpDpSf
- Retorna o tipo de dependência para fins de Salário Familia.

@author:	Henrique Ferreira
@since:		10/08/2022
@param:		cTipo - Tipo do dependente.
/*/
Function fTpDpSf( cTipo )

Local cRet := ""

DEFAULT cTipo = ""

If cTipo == "1"
   cRet := EncodeUTF8( STR0010 ) // "Dependente s/ limite de idade."
ElseIf cTipo == "2"
   cRet := EncodeUTF8( STR0014 ) // "Dependente até 14 anos."
Else
	cRet := EncodeUTF8( STR0013 ) // "Não é dependente."
EndIf

Return cRet
