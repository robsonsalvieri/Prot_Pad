#INCLUDE "PROTHEUS.CH"
#INCLUDE "PCPA119.CH"
#INCLUDE "TOPCONN.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "FWADAPTEREAI.CH"
#include "TbIconn.ch"
#include "TopConn.ch"

/*/{Protheus.doc} PCPA119EVDEF
Eventos padrão do cadastro de versão da produção
@author Fabio Cortes
@since 25/04/2018
@version P12.1.17
/*/

CLASS PCPA119EVDEF FROM FWModelEvent

	METHOD New() CONSTRUCTOR

	METHOD ModelPosVld()
	METHOD VldActivate()

ENDCLASS

METHOD New() CLASS  PCPA119EVDEF

Return

METHOD ModelPosVld(oModel, cModelId) Class PCPA119EVDEF

	Local dQtdeSVC  := oModel:GetModel('SVCMASTER'):GetValue('VC_QTDDE')
	Local dQtatSVC  := oModel:GetModel('SVCMASTER'):GetValue('VC_QTDATE')
	Local dtIniSVC  := oModel:GetModel('SVCMASTER'):GetValue('VC_DTINI')
	Local dtFimSVC  := oModel:GetModel('SVCMASTER'):GetValue('VC_DTFIM')
	Local cProdSVC  := oModel:GetModel('SVCMASTER'):GetValue('VC_PRODUTO')
	Local cVerSVC   := oModel:GetModel('SVCMASTER'):GetValue('VC_VERSAO')
	Local cRevSVC   := oModel:GetModel('SVCMASTER'):GetValue('VC_REV')
	Local cRotSVC   := oModel:GetModel('SVCMASTER'):GetValue("VC_ROTEIRO")

	Local lRet		:= .T.
	Local lCommit   := .T.

  	Local cQuery    := ""
  	Local cQuery2   := ""
  	Local cWhere1   := ""
  	Local cWhere2   := ""
  	Local cWhere3   := ""
  	Local cWhere4   := ""
  	Local cWhere5   := ""

  	Local aBkpArea  := GetArea()
  	Local cAliasQry := GetNextAlias()

	If oModel:GetOperation() != MODEL_OPERATION_DELETE

		dbSelectArea("SG1")
		dbSetOrder(1)
		If !MsSeek( xFilial("SG1")+cProdSVC)
			Help(" ",1,"A119ESTREXISTE") //Não existe estrutura para o produto.
			lRet := .F.
		EndIf

		If lRet
			dbSelectArea("SG2")
			dbSetOrder(1)
			If !MsSeek( xFilial("SG2")+cProdSVC+cRotSVC)
				Help(" ",1,"A119ROTPROD") //Roteiro não cadastrado para o produto
				lRet := .F.
			EndIf
		Endif

		If oModel:GetOperation() == MODEL_OPERATION_INSERT
			If !Empty(cVerSVC) .AND. !Empty(cProdSVC) .AND. lRet
				dbSelectArea("SVC")
				dbSetOrder(1)
				If MsSeek( xFilial("SVC")+cVerSVC+cProdSVC)
					Help(" ",1,"A119JAEXISTE") //Versão da produção já existe para o produto informado.
					lRet := .F.
				EndIf
			EndIf
		EndIf

		IF lRet .And. !Empty(cProdSVC)
			IF !PCPVldRev(cProdSVC,cRevSVC)
				Help(" ",1,"A119REVEXISTE") //Revisão não existe para o produto informado.
				lRet := .F.
			EndIf
		EndIf

		If lRet
			If Empty(dQtdeSVC) .OR. Empty(dQtatSVC)
				Help(" ",1,"A119VLDQTDZ") //Quantidade não pode ser zero
				lRet	 := .F.
			Else
				If dQtdeSVC = 0 .OR. dQtatSVC = 0
					Help(" ",1,"A119VLDQTDZ") //Quantidade não pode ser zero
					lRet	 := .F.
				Else
					If dQtdeSVC < 0 .OR. dQtatSVC < 0
						Help(" ",1,"A119VLDQTNG") //Quantidade não pode ser negativa
						lRet	 := .F.
					EndIf
				EndIf
			EndIf
		EndIf

		If lRet
			If dQtdeSVC >= dQtatSVC
				Help(" ",1,"A119VLDQTD") //Quantidade final nao pode ser menor que inicial
				lRet	 := .F.
			EndIf
		EndIf

		If lRet
			If !Empty(dtIniSVC) .And. !Empty(dtFimSVC)
				If Dtos(dtIniSVC) > Dtos(dtFimSVC)
					Help(" ",1,"A119VLDDATA") //Data final nao pode ser menor que inicial
					lRet	 := .F.
				EndIf
			EndIf
			If lRet
				If !Empty(dtIniSVC) .And. Empty(dtFimSVC)
					Help(" ",1,"A119DTOBRIGAT") //Datas de validade devem ser informadas em conjunto. Não é permitido cadastrar apenas a validade inicial ou final.
					lRet := .F.
				ElseIf (Empty(dtIniSVC) .And. !Empty(dtFimSVC))
					Help(" ",1,"A119DTOBRIGAT") //Datas de validade devem ser informadas em conjunto. Não é permitido cadastrar apenas a validade inicial ou final.
					lRet := .F.
				EndIf
			EndIf
		EndIf

		If lRet
			cQuery := " SELECT VC_VERSAO "
			cQuery += " FROM " + RetSqlName("SVC") + " SVC "
			cQuery += " WHERE SVC.VC_FILIAL  = '" + xFilial("SVC") + "' "
			cQuery += " AND SVC.VC_PRODUTO     = '" + cProdSVC + "'"
			If oModel:GetOperation() == MODEL_OPERATION_UPDATE
				cQuery += " AND SVC.VC_VERSAO     <> '" + cVerSVC + "'"
			EndIf

			cWhere1 := " AND (" + Str(dQtdeSVC) + " BETWEEN VC_QTDDE AND VC_QTDATE )"
			cWhere1 += " AND (" + Str(dQtatSVC) + " BETWEEN VC_QTDDE AND VC_QTDATE )"

			cWhere2 := " AND ((" + Str(dQtdeSVC) + " BETWEEN VC_QTDDE AND VC_QTDATE )"
			cWhere2 += " OR (" + Str(dQtatSVC) + " BETWEEN VC_QTDDE AND VC_QTDATE ))"

			cWhere3 := " AND (SVC.VC_QTDDE >= " + Str(dQtdeSVC) + " AND SVC.VC_QTDATE <= " + Str(dQtatSVC) + " )"

			//Valida se quantidade inicial informada está dentro de alguma faixa.
			cWhere4 := " AND ( " + Str(dQtdeSVC) + " >= SVC.VC_QTDDE AND " +  Str(dQtdeSVC) + " <= SVC.VC_QTDATE )"

			//Valida se quantidade inicial informada está dentro de alguma faixa. Qtd menor que range inicial e menor que range final.
			cWhere5 := " AND (( " + Str(dQtdeSVC) + " <= SVC.VC_QTDDE AND " +  Str(dQtdeSVC) + " <= SVC.VC_QTDATE ) AND (" + Str(dQtatSVC) + " >  SVC.VC_QTDATE ))

			If Empty(dtIniSVC) .And. Empty(dtFimSVC)
				cDate := " "
			Else
				cDate := " AND ( "
				cDate +=      " ( SVC.VC_DTINI = ' ' OR SVC.VC_DTINI BETWEEN '"+ DtoS(dtIniSVC) +"' AND '"+ DtoS(dtFimSVC) +"' ) "
				cDate +=   " OR ( SVC.VC_DTFIM = ' ' OR SVC.VC_DTFIM BETWEEN '"+ DtoS(dtIniSVC) +"' AND '"+ DtoS(dtFimSVC) +"' ) "
				cDate +=   " OR ( SVC.VC_DTINI <> ' ' AND '"+ DtoS(dtIniSVC) +"' BETWEEN SVC.VC_DTINI AND SVC.VC_DTFIM ) "
				cDate +=   " OR ( SVC.VC_DTFIM <> ' ' AND '"+ DtoS(dtFimSVC) +"' BETWEEN SVC.VC_DTINI AND SVC.VC_DTFIM ) "
				cDate += ")"
			EndIf

			cQuery += " AND D_E_L_E_T_ = '' "

			cQuery2 := cQuery + cDate + cWhere1
			cQuery2 := ChangeQuery(cQuery2)
			dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery2),cAliasQry,.T.,.T.)
			If (cAliasQry)->(Eof())
				lRet	 := .T.
			Else
				Help(" ",1,"A119FAIXAEXIST") //Faixa de quantidade/data já existe para esse produto.
				lRet	 := .F.
			EndIf
			(cAliasQry)->(dbCloseArea())
			RestArea(aBkpArea)

			If lRet
				cQuery2 := cQuery + cDate + cWhere2
				cQuery2 := ChangeQuery(cQuery2)
				dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery2),cAliasQry,.T.,.T.)
				If (cAliasQry)->(Eof())
					lRet	 := .T.
				Else
					Help(" ",1,"A119FAIXAEXIST") //Faixa de quantidade/data já existe para esse produto.
					lRet	 := .F.
				EndIf
				(cAliasQry)->(dbCloseArea())
				RestArea(aBkpArea)
			EndIf

			If lRet
				cQuery2 := cQuery + cDate + cWhere3
				cQuery2 := ChangeQuery(cQuery2)
				dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery2),cAliasQry,.T.,.T.)
				If (cAliasQry)->(Eof())
					lRet	 := .T.
				Else
					Help(" ",1,"A119FAIXAEXIST") //Faixa de quantidade/data já existe para esse produto.
					lRet	 := .F.
				EndIf
				(cAliasQry)->(dbCloseArea())
				RestArea(aBkpArea)
			EndIf

			If lRet
				cQuery2 := cQuery + cDate + cWhere4
				cQuery2 := ChangeQuery(cQuery2)
				dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery2),cAliasQry,.T.,.T.)
				If (cAliasQry)->(Eof())
					lRet	 := .T.
				Else
					Help(" ",1,"A119FAIXAEXIST") //Faixa de quantidade/data já existe para esse produto.
					lRet	 := .F.
				EndIf
				(cAliasQry)->(dbCloseArea())
				RestArea(aBkpArea)
			EndIf

			If lRet
				cQuery2 := cQuery + cDate + cWhere5
				cQuery2 := ChangeQuery(cQuery2)
				dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery2),cAliasQry,.T.,.T.)
				If (cAliasQry)->(Eof())
					lRet	 := .T.
				Else
					Help(" ",1,"A119FAIXAEXIST") //Faixa de quantidade/data já existe para esse produto.
					lRet	 := .F.
				EndIf
				(cAliasQry)->(dbCloseArea())
				RestArea(aBkpArea)
			EndIf


			//Validar na base se tem data em branco na base quando o registro novo possuir datas.
			If lRet .and. !Empty(dtFimSVC) .AND. !Empty(dtIniSVC)
				cQuery2 := cQuery + " AND (SVC.VC_DTFIM = '' AND SVC.VC_DTINI = '' ) "  + cWhere5
				cQuery2 := ChangeQuery(cQuery2)
				dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery2),cAliasQry,.T.,.T.)
				If (cAliasQry)->(Eof())
					lRet	 := .T.
				Else
					Help(" ",1,"A119FAIXAEXIST") //Faixa de quantidade/data já existe para esse produto.
					lRet	 := .F.
				EndIf
				(cAliasQry)->(dbCloseArea())
				RestArea(aBkpArea)
			EndIf

			//Após todas as validações refaz as validações do after field campo quantidade.
			IF lRet .And. A119VldQtd(lCommit)
				lRet	 := .T.
			Else
				lRet	 := .F.
			EndIf
		EndIf
	EndIf

Return lRet

/*/{Protheus.doc} VldActivate
Método executado antes da ativação do modelo
@author carlos.silveira
@since 15/05/2019
@version 1.0
@param oModel  , object , modelo principal
@param cModelId, logical, código do submodelo
@return lRet, logical, indica se o modelo poderá ser ativado
/*/
METHOD VldActivate(oModel, cModelId) CLASS PCPA119EVDEF
	Local lRet := .T.
	Local cQuery    := ""
	Local cAliasQry := ""
	Local aArea     := GetArea()

	If oModel:GetOperation() != MODEL_OPERATION_DELETE
		cQuery := " SELECT COUNT(*) TOTAL "
		cQuery += "   FROM " + RetSqlName("SG1") + " SG1 "
		cQuery += "  WHERE SG1.G1_FILIAL  = '" + xFilial("SG1") + "' "
		cQuery += "    AND SG1.D_E_L_E_T_ = ' ' "
		cQuery += "    AND (SG1.G1_GROPC <> ' ' OR SG1.G1_OPC <> ' ') "

		cQuery 	  := ChangeQuery(cQuery)
		cAliasQry := GetNextAlias()

		dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasQry,.T.,.T.)
		If (cAliasQry)->(TOTAL) > 0
			Help( ,  , "Help", ,  STR0010,;  //"Não é permitido utilizar a versão da produção em conjunto com o conceito de Componentes Opcionais."
			1, 0, , , , , , {STR0011})  //"Para utilizar a versão da produção, não pode existir nenhuma estrutura ou pré-estrutura com componentes opcionais."
			lRet := .F.
		EndIf
		(cAliasQry)->(dbCloseArea())

		RestArea(aArea)
	EndIf

	If lRet
		cQuery := " SELECT COUNT(*) TOTAL "
		cQuery +=   " FROM " + RetSqlName("SGG") + " SGG "
		cQuery +=  " WHERE SGG.GG_FILIAL  = '" + xFilial("SGG") + "' "
		cQuery +=    " AND SGG.D_E_L_E_T_ = ' ' "
		cQuery += "    AND (SGG.GG_GROPC <> ' ' OR SGG.GG_OPC <> ' ') "

		cQuery 	  := ChangeQuery(cQuery)
		cAliasQry := GetNextAlias()

		dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasQry,.T.,.T.)
		If (cAliasQry)->(TOTAL) > 0
			Help( ,  , "Help", ,  STR0010,;  //"Não é permitido utilizar a versão da produção em conjunto com o conceito de Componentes Opcionais."
	 		1, 0, , , , , , {STR0011})  //"Para utilizar a versão da produção, não pode existir nenhuma estrutura ou pré-estrutura com componentes opcionais."
			lRet := .F.
		EndIf
		(cAliasQry)->(dbCloseArea())

		RestArea(aArea)
	EndIf

Return lRet
