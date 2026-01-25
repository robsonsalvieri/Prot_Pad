#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"

//-------------------------------------------------------------------
/*/{Protheus.doc} FsmRestModel
Classe dos modelos FSM
@since 07/07/2020
/*/
//-------------------------------------------------------------------
Class FsmRestModel From FwRestModel
	//Data searchKey AS STRING

	//Method Activate()
	Method SetFilter()
	
EndClass

//-------------------------------------------------------------------
/*/{Protheus.doc} SetFilter()
Filtro recebido da requisição.
@since 07/08/2020
/*/
//-------------------------------------------------------------------
Method SetFilter(cFilter)  Class FsmRestModel
Local cVerbo     	:= self:GetHttpHeader("_METHOD_")
Local cPath      	:= self:GetHttpHeader("_PATH_")
Local cQuery     	:= self:GetHttpHeader("_QUERY_")
Local cFiltFil   	:= ""
Local aDados 		:= {}
local lSupervisor 	:= .F.
Local lAtendente   	:= .F.
Local cFilGrpProd   := ''
Local cFilAtend     := ''

	If !Empty(cQuery)

		aDados      := StrTokArr(cQuery, '&') 
		cFilAtend   := FiltQry(aDados)
		cFilGrpProd := FilterGrpPrd(aDados)

	Endif

	If (cQuery == Nil)
		cQuery := ""
	EndIf

	If (cVerbo == "GET")
			Do Case 
				Case IsInPath(cPath, "FSMVENDEDOR")
					cFiltFil := "A3_FILIAL='" + FWxFilial("SA3") + "'"
				Case IsInPath(cPath, "FSMCLIENTES")
					cFiltFil := "A1_FILIAL='" + FWxFilial("SA1") + "'"
				Case IsInPath(cPath, "FSMGRUPOSPRODUTO")
					cFiltFil := "BM_FILIAL='" + FWxFilial("SBM") + "'"
				Case IsInPath(cPath, "FSMSERVICO")
					cFiltFil := "JN1_FILIAL='" + FWxFilial("JN1") + "'"
				Case IsInPath(cPath, "FSMBASE")
					cFiltFil := "AA3_FILIAL='" + FWxFilial("AA3") + "'"
				Case IsInPath(cPath, "FSMCOBERTURAS")
					cFiltFil := "AAA_FILIAL='" + FWxFilial("AAA") + "'"
				Case IsInPath(cPath, "FSMORDEM")
					cFiltFil := "JN3_FILIAL='" + FWxFilial("JN3") + "'"
				Case IsInPath(cPath, "FSMPRODUTOS")
					cFiltFil := "B1_FILIAL='" + FWxFilial("SB1") + "'"
					If (cFilGrpProd != '')
						cFiltFil += " AND " + cFilGrpProd
					Endif
				Case IsInPath(cPath, "FSMFORNECEDOR")
					cFiltFil := "A2_FILIAL='" + FWxFilial("SA2") + "'"
				Case IsInPath(cPath, "FSMORCAMENTO")
					cFiltFil := "JN7_FILIAL='" + FWxFilial("JN7") + "'"
				Case IsInPath(cPath, "FSMAGENDAS")
					cFiltFil  := cFilAtend
				Case IsInPath(cPath, "FSMCHECKLIST")
					cFiltFil := "JND_FILIAL='" + FWxFilial("JND") + "'"
				Case IsInPath(cPath, "FSMSX5")
					cFiltFil := "X5_FILIAL='" + FWxFilial("SX5") + "'"
				Case IsInPath(cPath, "FSMESTOQUE")
					cFiltFil := "B1_FILIAL='" + FWxFilial("SB1") + "'"	
				Case IsInPath(cPath, "FSMMOTIVOSPAUSA")
					cFiltFil := "JNM_FILIAL='" + FWxFilial("JNM") + "'"
				Case IsInPath(cPath, "FSMFORMULARIO")
					cFiltFil := "JNN_FILIAL='" + FWxFilial("JNN") + "'"
				Case IsInPath(cPath, "FSMPARAMETRO")
					cFiltFil := "JNU_FILIAL='" + FWxFilial("JNU") + "'"
				Case IsInPath(cPath, "FSMEVENTOS")
					cFiltFil := "JNK_FILIAL='" + FWxFilial("JNK") + "'"	
				Case IsInPath(cPath, "FSMPENDENCIASCLI")
					cFiltFil := "JNS_FILIAL='" + FWxFilial("JNS") + "'"	
				Case IsInPath(cPath, "FSMOSCHECK")
					cFiltFil := "JNR_FILIAL='" + FWxFilial("JNR") + "'"
				Case IsInPath(cPath, "FSMAPONTAMENTOHORAS")
					cFiltFil := "JNV_FILIAL='" + FWxFilial("JNV") + "'"
				Case IsInPath(cPath, "FSMLAUDO")
					cFiltFil := "JNY_FILIAL='" + FWxFilial("JNY") + "'"
				Case IsInPath(cPath, "FSMMIDIA")
					cFiltFil := "JO0_FILIAL='" + FWxFilial("JO0") + "'"
				Case IsInPath(cPath, "FSMESTADOCONSERVACAO")
					cFiltFil := "JO1_FILIAL='" + FWxFilial("JO1") + "'"
				Case IsInPath(cPath, "FSMPECAAPONTA")
					cFiltFil := "JO4_FILIAL='" + FWxFilial("JO4") + "'"
				Case IsInPath(cPath, "FSMUNIDADEMEDIDA")
					cFiltFil := "AH_FILIAL='" + FWxFilial("SAH") + "'"
				Case IsInPath(cPath, "FSMPREREQUISICAO")
					cFiltFil := "JO3_FILIAL='" + FWxFilial("JO3") + "'"
				Case IsInPath(cPath, "FSMREPROVACAOESTOQUE")
					cFiltFil := "JO5_FILIAL='" + FWxFilial("JO5") + "'"
				Case IsInPath(cPath, "FSMREJEICAOESTOQUE")
					cFiltFil := "JO6_FILIAL='" + FWxFilial("JO6") + "'"
				Case IsInPath(cPath, "FSMAREPROVAORCA")
					cFiltFil := "JO7_FILIAL='" + FWxFilial("JO7") + "'"
				Case IsInPath(cPath, "FSMARQUIVAORCAMENTO")
					cFiltFil := "JO8_FILIAL='" + FWxFilial("JO8") + "'"
				Case IsInPath(cPath, "FSMTIPODESPESA")
					cFiltFil := "JOD_FILIAL='" + FWxFilial("JOD") + "'"
				Case IsInPath(cPath, "FSMFUNCOES")
					cFiltFil := "RJ_FILIAL='" + FWxFilial("SRJ") + "'"
				Case IsInPath(cPath, "FSMNATFIN")
					cFiltFil := "ED_FILIAL='" + FWxFilial("SED") + "'"
				Case IsInPath(cPath, "FSMPRODFAT")
					cFiltFil := "B1_FILIAL='" + FWxFilial("SB1") + "'"
				Case IsInPath(cPath, "FSMCENTCUST")
					cFiltFil := "CTT_FILIAL='" + FWxFilial("CTT") + "'"
				Case IsInPath(cPath, "FSMCONTCONTABIL")
					cFiltFil := "CT1_FILIAL='" + FWxFilial("CT1") + "'"
				Case IsInPath(cPath, "FSMITEMCONTABIL")
					cFiltFil := "CTD_FILIAL='" + FWxFilial("CTD") + "'"
				Case IsInPath(cPath, "FSMCLASEE")
					cFiltFil := "CTH_FILIAL='" + FWxFilial("CTH") + "'"
				Case IsInPath(cPath, "FSMKITSATENDENTE")
					cFiltFil := "JOA_FILIAL='" + FWxFilial("JOA") + "'"
				Case IsInPath(cPath, "FSMKITSENTREGUES")
					cFiltFil := "JOC_FILIAL='" + FWxFilial("JOC") + "'"
				Otherwise
					cFiltFil := ""
			End Case

			If !Empty(cFiltFil)
				If !Empty(cFilter)
					cFilter += " AND "
				EndIf

				cFilter += cFiltFil
			EndIf
		EndIf

		lSupervisor := .F.
		lAtendente  := .F.

Return _Super:SetFilter(cFilter)

//-------------------------------------------------------------------
/*/{Protheus.doc} IsInPath(cPath, cFonte)
Verifica se o Endpoint (cFonte) está na requisição (cPath)

@Param cPath - Path completo da requisição
@Param cFonte - Nome do fonte a ser verificado

@since 30/09/2019
/*/
//-------------------------------------------------------------------
Static Function IsInPath(cPath, cFonte)
Default cPath  := ""
Default cFonte := ""

Return  cFonte $ cPath

//-------------------------------------------------------------------
/*/{Protheus.doc} ReplaceAcc()


/*/
//-------------------------------------------------------------------

Static Function ReplaceAcc(cFiltro)

Return cFiltro

//-------------------------------------------------------------------
/*/{Protheus.doc} FiltQry()
 Retorna o conteudo do Filtro da query
/*/
//-------------------------------------------------------------------

Static Function FiltQry(aParams)
Local nPosParam := aScan(aParams,"SUPERVISOR")
Local aParam    := Nil
Local cRet   := ''

	If (nPosParam > 0)

		aParam := StrTokArr(aParams[nPosParam],"=")

		If (aParam[2] == '2')

			cRet := " JN6_FILIAL='" + FWxFilial("JN6") + "' AND JN6_CODAA1 =  " + CRLF
			cRet += " (SELECT AA1_CODTEC FROM  "+RetSqlName( "AA1" )+" AA1    " + CRLF
			cRet += "  WHERE AA1_CODUSR = '"+__cUserID+"' AND AA1.D_E_L_E_T_ = ' ' " + CRLF
			cRet += " AND  AA1_FILIAL = '" + FWxFilial("AA1") + "') "

		ElseIf (aParam[2] == '1')

			cRet := " JN6_FILIAL='" + FWxFilial("JN6") + "' AND JN6_CODAA1  IN   "         + CRLF
			cRet += " (SELECT JNI_CODATD FROM "+RetSqlName("JNI")+" WHERE        "         + CRLF
			cRet += " JNI_CODSUP = (SELECT AA1_CODTEC FROM "+RetSqlName( "AA1" )+" AA12  " + CRLF
			cRet += " WHERE AA1_CODUSR = '"+__cUserID+"' AND AA12.D_E_L_E_T_ = ' ')  "             + CRLF
			cRet += " AND D_E_L_E_T_ = ' ' AND JNI_FILIAL =  '" + FWxFilial("JNI") + "') "   

		Endif

	Else
		cRet := "JN6_FILIAL='" + FWxFilial("JN6") + "'"
	Endif

Return cRet

Static Function FilterGrpPrd(aParams) 
Local nPosParam := aScan(aParams,"FILTERGROUP")
Local aParam    := Nil
Local cRet   := ''

	If (nPosParam > 0)
		aParam := StrTokArr(aParams[nPosParam],"=")

		If (aParam[2] != '')

			cRet := " B1_GRUPO IN (SELECT JNZ_GRUPO FROM " + RetSqlName('JNZ')
            cRet += " WHERE JNZ_FILIAL = '" + xFilial('JNZ') + "'"
			cRet += " AND JNZ_CODJN1 = '" + aParam[2] + "' AND D_E_L_E_T_ = ' ')"
			cRet += " AND D_E_L_E_T_ = ' ' "

		Endif

	Endif

Return cRet
