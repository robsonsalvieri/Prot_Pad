#include "totvs.ch"

//------------------------------------------------------------------
/*/{Protheus.doc} COMA230

Executa app Angular Substituição do aprovador

@author  juan.felipe
@since   05/06/2024
/*/
//-------------------------------------------------------------------
Function COMA230()
    PGCA010('COMA230')
Return

//-------------------------------------------------------------------
/*/{Protheus.doc} A230GetAbsence
    Obtém dados da ausência do aprovador.
@author	juan.felipe
@since 17/16/2023
@param cApprover, character, aprovador.
@param cUser, character, usuário.
@return oJsonAbsence, object, json com as informações.
/*/
//-------------------------------------------------------------------
Function A230GetAbsence(cApprover, cUser)
    Local cAliasTemp As Character
    Local cFilDKJ As Character
    Local cQuery As Character
    Local oQuery As Object
    Local oJsonAbsence As Object
	Default cApprover := ''
	Default cUser := ''

    oJsonAbsence := JsonObject():New()
    oJsonAbsence['hasAbsence'] := .F.
    oJsonAbsence['DKJ_FILIAL'] := ''
    oJsonAbsence['DKJ_USRORI'] := ''
    oJsonAbsence['DKJ_USRSUB'] := ''
    oJsonAbsence['DKJ_APRORI'] := ''
    oJsonAbsence['DKJ_APRSUB'] := ''
    oJsonAbsence['DKJ_DATINI'] := STod('')
    oJsonAbsence['DKJ_DATFIM'] := STod('')

    If AliasIndic('DKJ') .And. !Empty(RetSqlName('DKJ'))
        cFilDKJ := FWxFilial('DKJ')

        cQuery := " SELECT"
        cQuery += "   DKJ.DKJ_FILIAL, "
        cQuery += "   DKJ.DKJ_USRORI, "
        cQuery += "   DKJ.DKJ_USRSUB, "
        cQuery += "   DKJ.DKJ_APRORI, "
        cQuery += "   DKJ.DKJ_APRSUB, "
        cQuery += "   MAX(DKJ.DKJ_DATINI) DATINI, "
        cQuery += "   MAX(DKJ.DKJ_DATFIM) DATFIM "
        cQuery += " FROM "+ RetSQLName("DKJ") +" DKJ "
        cQuery += " WHERE DKJ.DKJ_FILIAL = ? "
        cQuery += " AND DKJ.DKJ_APRORI = ? "
        cQuery += " AND DKJ.DKJ_USRORI = ? "
        cQuery += " AND DKJ.D_E_L_E_T_ = ' ' "
        cQuery += " GROUP BY "
        cQuery += " DKJ.DKJ_FILIAL, "
        cQuery += " DKJ.DKJ_USRORI, "
        cQuery += " DKJ.DKJ_USRSUB, "
        cQuery += " DKJ.DKJ_APRORI, "
        cQuery += " DKJ.DKJ_APRSUB"
        
        oQuery := FWPreparedStatement():New(cQuery)

        oQuery:SetString(1, cFilDKJ)
        oQuery:SetString(2, cApprover)
        oQuery:SetString(3, cUser)

        cAliasTemp := MpSysOpenQuery(oQuery:getFixQuery())

        If !(cAliasTemp)->(Eof())
            oJsonAbsence['DKJ_FILIAL'] := (cAliasTemp)->DKJ_FILIAL
            oJsonAbsence['DKJ_USRORI'] := (cAliasTemp)->DKJ_USRORI
            oJsonAbsence['DKJ_USRSUB'] := (cAliasTemp)->DKJ_USRSUB
            oJsonAbsence['DKJ_APRORI'] := (cAliasTemp)->DKJ_APRORI
            oJsonAbsence['DKJ_APRSUB'] := (cAliasTemp)->DKJ_APRSUB
            oJsonAbsence['DKJ_DATINI'] := SToD((cAliasTemp)->DATINI)
            oJsonAbsence['DKJ_DATFIM'] := SToD((cAliasTemp)->DATFIM)

            If oJsonAbsence['DKJ_DATFIM'] > Date()
                oJsonAbsence['hasAbsence'] := .T.
            EndIf
        EndIf

        (cAliasTemp)->(dbCloseArea())
        oQuery:Destroy()
        FreeObj(oQuery)
    EndIf
Return oJsonAbsence


/*/{Protheus.doc} A230ExecSched
	Função responsável por executar o schedule da devolução dos documentos do aprovador.
@author juan.felipe
@since 18/06/2024
@return Nil, nulo.
/*/
Function A230ExecSched(aParam, dDate)
    Local cAliasTemp As Character
    Local cFilDKJ As Character
    Local cQuery As Character
    Local oQuery As Object
    Local oSubsRepo As Object
	Default aParam := {}
    Default dDate := Date()

    If Len(aParam) > 0
        RpcSetType(3)
        RpcSetEnv(aParam[1], aParam[2],,, 'COM') //-- Define empresa/filial logada
		
		If AliasIndic('DKJ') .And. !Empty(RetSqlName('DKJ'))
			oSubsRepo := alc.substitutionRepository.alcSubstitutionRepository():New()

			cFilDKJ := FWxFilial('DKJ')

			cQuery := " SELECT"
			cQuery += "   DKJ.DKJ_FILIAL, "
			cQuery += "   DKJ.DKJ_USRORI, "
			cQuery += "   DKJ.DKJ_USRSUB, "
			cQuery += "   DKJ.DKJ_APRORI, "
			cQuery += "   DKJ.DKJ_APRSUB, "
			cQuery += "   DKJ.DKJ_DATINI, "
			cQuery += "   DKJ.DKJ_DATFIM "
			cQuery += " FROM "+ RetSQLName("DKJ") +" DKJ "
			cQuery += " WHERE DKJ.DKJ_FILIAL = ? "
			cQuery += " AND DKJ.DKJ_DATFIM < ? "
			cQuery += " AND DKJ.D_E_L_E_T_ = ' ' "

			oQuery := FWPreparedStatement():New(cQuery)

			oQuery:SetString(1, cFilDKJ)
			oQuery:SetString(2, DTOS(dDate))

			cAliasTemp := MpSysOpenQuery(oQuery:getFixQuery())

			DKJ->(dbSetOrder(1))

			While !(cAliasTemp)->(Eof())
				If DKJ->(MsSeek(cFilDKJ + (cAliasTemp)->DKJ_APRORI + (cAliasTemp)->DKJ_DATINI + (cAliasTemp)->DKJ_DATFIM))
					Begin Transaction
						oSubsRepo:transferApproverDocuments(; //-- Transfere os documentos para o aprovador original
								(cAliasTemp)->DKJ_APRSUB,;
								(cAliasTemp)->DKJ_USRSUB,;
								(cAliasTemp)->DKJ_APRORI,;
								(cAliasTemp)->DKJ_USRORI,;
								.F., .T.;
							)
                                    
                        RecLock("DKJ",.F.)
                        DKJ->(dbDelete()) //-- Deleta ausência do aprovador
                        DKJ->(MsUnlock())
					End Transaction
				EndIf

				(cAliasTemp)->(DbSkip())
			EndDo

			(cAliasTemp)->(dbCloseArea())
			oQuery:Destroy()
			FreeObj(oQuery)
			FreeObj(oSubsRepo)
		EndIf

        RpcClearEnv()
    EndIf
Return

/*/{Protheus.doc} A230EmpFilSched
	Função responsável por verificar se existe schedule cadastrado para empresa/filial logada.
@author juan.felipe
@since 18/06/2024
@return lRet, logical, indica se existe schedule para empresa/filial logada.
/*/
Function A230EmpFilSched()
    Local lRet As Logical
    Local oQuery As Object
    Local cQuery As Character
    Local cAliasTemp As Character

    If FindFunction("FWOpenXX1") .And. FindFunction("FWOpenXX2") 
        //Caso não exista as tabelas XX1 e XX2 na base elas serão criadas atraves do FwOpen...
        FWOpenXX1()
        FWOpenXX2()
    EndIf

    If ChkFile('XX1') .And. ChkFile('XX2')

        cQuery := " SELECT XX1.XX1_DATA "
        cQuery += " FROM " + RetSQLName('XX1') + " XX1 "
        cQuery += " INNER JOIN " + RetSQLName('XX2') + " XX2 ON "
        cQuery += " XX2.XX2_AGEND = XX1.XX1_CODIGO "
        cQuery += " AND XX2.D_E_L_E_T_ = ' ' "
        cQuery += " WHERE UPPER(XX1.XX1_ROTINA) = ? "
        cQuery += " AND (XX2.XX2_EMPFIL = ? OR XX2.XX2_EMPFIL = ?)"
        cQuery += " AND XX1.D_E_L_E_T_ = ' ' "

        oQuery := FwExecStatement():New(ChangeQuery(cQuery))
        oQuery:SetString(1, 'A230EXECSCHED')
        oQuery:SetString(2, cEmpAnt)
        oQuery:SetString(3, cEmpAnt+'/'+cFilAnt)

        cAliasTemp := oQuery:OpenAlias() 

        lRet := !(cAliasTemp)->(Eof())

        (cAliasTemp)->(dbCloseArea())
        oQuery:Destroy()
        FreeObj(oQuery)
    EndIf

Return lRet
