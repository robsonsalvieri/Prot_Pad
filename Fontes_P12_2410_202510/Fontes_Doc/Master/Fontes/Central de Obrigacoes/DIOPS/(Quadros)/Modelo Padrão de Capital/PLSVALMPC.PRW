#Include 'totvs.ch'

//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} PLVLDMP01
@return lRetorno .F. registro criticado ou .T. registro nao criticado

@author jose.paulo
@since 05/08/2019
/*/
//--------------------------------------------------------------------------------------------------
Function PLVLDMP01()
    Local cSql    := ""
    Local lRet    := .F.
    Local nValMTP := 0
    Local nValMVI := 0
    

 	cSql := " SELECT SUM(B82_NMRMVI) MVI, SUM(B82_NMRMTP) AS MTP FROM " + RetSqlName("B82") 
	cSql += "	WHERE B82_FILIAL = '" + xFilial("B82") + "' " 
	cSql += "	  AND B82_CODOPE = '" + B3D->B3D_CODOPE + "' "
	cSql += "	  AND B82_CODOBR = '" + B3D->B3D_CDOBRI + "' "
	cSql += "	  AND B82_ANOCMP = '" + B3D->B3D_ANO + "' "
	cSql += "	  AND B82_CDCOMP = '" + B3D->B3D_CODIGO + "' "
	cSql += " 	  AND D_E_L_E_T_ = ' ' " 	

   	cSql := ChangeQuery(cSql)
	dbUseArea(.T.,"TOPCONN",TCGENQRY(,,cSql),"TRBMPC",.F.,.T.)

	If !TRBMPC->(Eof())
		// Se há dados sobre o quadro, guarda valor para comparação com a conta	
		nValMVI	:= TRBMPC->MVI
  		nValMTP	:= TRBMPC->MTP
       
		TRBMPC->(dbCloseArea())

	EndIf

	// Alterado de 1 para 0
    If nValMTP >= 0 .And. nValMTP <= 2147483647 .And. nValMVI >= 0 .And. nValMVI <= 2147483647
        lRet := .T.
    EndIf

Return lRet

//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} PLSVALCPOS
@return lRetorno .F. registro criticado ou .T. registro nao criticado

@author jose.paulo
@since 05/08/2019
/*/
//--------------------------------------------------------------------------------------------------

Function PLSVALCPOS(nVal,cCpo) 
    Local lRet   := .F.
    Default nVal := 0
    Default cCpo := ""

    If nVal >= 0 .And. nVal <= 2147483647     //aqui permito o zero para que seja possivel sair do campo
		lRet   := .T.
    EndIf

    If !lRet

        If cCpo == "MTP"
		    HELP( ,, 'HELP',,"O campo Num.Remid T, está com conteúdo inválido.", 1,0,NIL,NIL,NIL,NIL,NIL,{"O conteúdo do campo deve ser maior que 0 e Menor ou igual a 2147483647."})
        Else
		    HELP( ,, 'HELP',,"O campo Num.Remid V, está com conteúdo inválido.", 1,0,NIL,NIL,NIL,NIL,NIL,{"O conteúdo do campo deve ser maior que 0 e menor ou igual a 2147483647."})
        EndIf


    EndIf

Return lRet