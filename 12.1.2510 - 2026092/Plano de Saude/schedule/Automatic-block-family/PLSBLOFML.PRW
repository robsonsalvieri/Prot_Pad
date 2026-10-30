#Include 'TOTVS.ch'
#INCLUDE "PLSBLOFML.CH"
#define LOG_FILE "schedule.block.family.log"

/*/{Protheus.doc} PLSBLOFLM
Rotina Criada Para validar existencia de empresas sem data de bloqueio, porem com todos os usarios bloqueados
@version 12.1.2510
@author rafael.aoliveira
@since 17/01/2025
/*/
Function PLSBLOFML()

	LOCAL cQuery   := "" as character
    LOCAL oExecBA3 := Nil as object
	Local oError   := Nil as object
	Local cAlias   := "" as character
	Local cMotBlo  := AllTrim(MV_PAR02) as character
	Local nBloPdr  := MV_PAR01 as numeric
	Local lVldBc3  := BC3->(FieldPos("BC3_ORIBLO")) > 0
	Local lVldBG3  := BG3->(FieldPos("BG3_BLOFML")) > 0

	if empty(cMotBlo) .AND. nBloPdr == 2 // MOTIVO DE BLOQUEIO GENERICO

    	oError := ErrorClass():New()
    	oError:description := STR0001 // 'Falha no bloqueio automático: A configuração exige um motivo de bloqueio padrão, mas o campo correspondente está vazio ou não foi informado.'                                                                                                                                                                                                                                                                                                                                                                      
		oError:Operation   := 'PLSBLOFML'
		oError:Severity    := 2 

		MLogBloAlt(STR0001)                                                                                                                                                                                                                                                                                                                                                                    

    	THROW oError

	elseif nBloPdr == 1 // MOTIVO DE BLOQUEIO ULTIMO DO BENEFICIARIO 
		if !lVldBG3

			oError := ErrorClass():New()
    		oError:description := STR0002 // 'Não foi possível realizar o bloqueio automático da família: o campo BG3_BLOFML não foi localizado no dicionário de dados.'                                                                                                                                                                                                                                                                                                                                                                                          
			oError:Operation   := 'PLSBLOFML'
			oError:Severity    := 2 

			MLogBloAlt(STR0002) 

    		THROW oError
		endif

		cMotBlo := "" // Deixe em branco para herdar o motivo de bloqueio do último beneficiário.
	
	endif

	cQuery := "WITH BLOQUEADOS_TOTAL AS (  "
	cQuery += "SELECT BA1_FILIAL, BA1_CODEMP, BA1_MATRIC, BA1_CODINT FROM " + RetSqlName("BA1")

	cQuery += " WHERE "
	cQuery += "D_E_L_E_T_ =  ' '"


	cQuery += " GROUP BY BA1_FILIAL, BA1_CODINT, BA1_CODEMP, BA1_MATRIC "

	cQuery += " HAVING COUNT(R_E_C_N_O_) = SUM( CASE WHEN BA1_DATBLO <> ' ' THEN 1 ELSE 0 END  ) "
	cQuery += " AND MAX(BA1_DATBLO) <= '"+ dToS(dDatabase)+ "' "
	cQuery += " ) "

	cQuery += "SELECT BA3.R_E_C_N_O_ FROM "+  RetSqlName("BA3")+" BA3  "
	cQuery += "	INNER JOIN BLOQUEADOS_TOTAL BT "
	cQuery += "  	ON BA3.BA3_FILIAL = BT.BA1_FILIAL     "  
	cQuery += "		AND BA3.BA3_CODINT = BT.BA1_CODINT    "
	cQuery += "		AND BA3.BA3_CODEMP = BT.BA1_CODEMP    "
	cQuery += "		AND BA3.BA3_MATRIC = BT.BA1_MATRIC    "

	cQuery += "WHERE "
	cQuery += "BA3.D_E_L_E_T_ = ' ' "
	cQuery += "AND BA3.BA3_DATBLO = ' ' "

	oExecBA3 := FwExecStatement():new(cQuery)

	cAlias := oExecBA3:openAlias()

	While !(cAlias)->(eof())

		updBa3Bc3((cAlias)->R_E_C_N_O_, cMotBlo, lVldBc3, lVldBG3, nBloPdr)

		(cAlias)->(dbSkip())
	EndDo

	(cAlias)->(dbCloseArea())

	oExecBA3:destroy()
    freeObj(oExecBA3)

return



/*/{Protheus.doc} updBa3Bc3
Faz atualização da BA3 com data de bloqueio atual e motivo de bloqueio
@version 12.1.2510
@author rafael.aoliveira
@since 17/01/2025
/*/
Static Function updBa3Bc3(nRecBA3, cMotBlo, lVldBc3, lVldBG3, nBloPdr)
	
	LOCAL cSql       := "" as character
	Local oExecBCA   := Nil  as object
	Local cAlias     := "" as character
	Local dDataBloBe := dDatabase
	Local lMotBlo    := .T.

	Default nRecBA3  := 0 
	Default cMotBlo  := ""
	Default lVldBc3  := .F.
    Default nBloPdr  := 2
	BA3->(DbGoTo(nRecBA3))

	if empty(cMotBlo) .OR. nBloPdr == 1

		cSQL := "SELECT BCA_MOTBLO, BCA_DATA FROM "+ RetSqlName("BCA")
		cSQL += " WHERE "
		cSQL += " BCA_FILIAL = '"+ BA3->BA3_FILIAL +"' AND "
		cSQL += " BCA_MATRIC = '"+BA3->(BA3_CODINT+BA3_CODEMP+BA3_MATRIC)+ "' AND "
		cSQL += " BCA_TIPO = '0' AND "
		cSQL += " D_E_L_E_T_ = ' ' "
		cSQL += " ORDER BY "
		cSQL += " BCA_DATA DESC, "
		cSQL += " BCA_DATLAN DESC, "
		cSQL += " BCA_HORLAN DESC, "
		cSQL += " R_E_C_N_O_ DESC "
     
		oExecBCA := FwExecStatement():new(cSQL)
		cAlias := oExecBCA:openAlias()

		If ! (cAlias)->(Eof())
			(cAlias)->(DbGoTop())
			BG3->(dbSetOrder(1))

			If BG3->(MsSeek( xFilial("BG3")+(cAlias)->BCA_MOTBLO))
				If lVldBG3
					If EmpTy(BG3->BG3_BLOFML)
						MLogBloAlt('Empresa ['+BA3->(BA3_CODINT+BA3_CODEMP+BA3_MATRIC)+'] '+ STR0003) //'Família não bloqueada. Motivo: O campo BG3_BLOFML está em branco.'                                                                                                                                                                                                                                                                                                                                                                                                                                                 
						lMotBlo := .F.
					Else

						cMotBlo    := BG3->BG3_BLOFML 
						dDataBloBe := SToD((cAlias)->BCA_DATA)
					EndIf
				EndIf	
			EndIf
    	EndIf
	
		(cAlias)->(dbCloseArea())
		oExecBCA:destroy()
    	freeObj(oExecBCA)

		If EmpTy(cMotBlo)
			MLogBloAlt('Empresa ['+BA3->(BA3_CODINT+BA3_CODEMP+BA3_MATRIC)+'] '+STR0004 ) //'Bloqueio de família interrompido por falta de motivo de bloqueio no cadastro do beneficiário.'                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                     
			lMotBlo := .F.
		EndIf
	EndIf

	if lMotBlo
		
		cSQL := " SELECT MAX(BCA_ID) BCA_ID FROM " + RetSqlName("BCA") + "  BCA  "

		cSQL += " 	INNER JOIN " + RetSqlName("BA1") + " BA1 ON "
		cSQL += " 	BCA_FILIAL = BA1_FILIAL AND "
		cSQL += " 	BCA_MATRIC = BA1_CODINT||BA1_CODEMP||BA1_MATRIC AND "
		cSQL += " 	BCA_TIPREG = BA1_TIPREG  "

		cSQL += " 	WHERE  "
		cSQL += " 	BA1_FILIAL = '"+BA3->BA3_FILIAL+"'   AND "
		cSQL += " 	BA1_CODINT = '"+BA3->BA3_CODINT+"'   AND "
		cSQL += " 	BA1_CODEMP = '"+BA3->BA3_CODEMP+"'   AND "
		cSQL += " 	BA1_MATRIC = '"+BA3->BA3_MATRIC+"'   AND "
		cSQL += " 	BA1_TIPUSU = 'T'      AND "
		cSQL += " 	BA1.D_E_L_E_T_ = ' '  AND "
		cSQL += " 	BCA_FILIAL = '"+BA3->BA3_FILIAL+"'   AND "
		cSQL += " 	BCA_TIPO   = '0' AND "
		cSQL += " 	BCA.D_E_L_E_T_ = ' ' "

		oExecBCA := FwExecStatement():new(ChangeQuery(cSQL))

		cAlias := oExecBCA:openAlias()

		Begin Transaction

			BA3->(RecLock("BA3",.F.))
				BA3->BA3_DATBLO := dDataBloBe
				BA3->BA3_MOTBLO := cMotBlo
				BA3->BA3_CONSID := "F"
			BA3->(MsUnlock())

			BC3->(RecLock("BC3",.T.))

				BC3->BC3_FILIAL := BA3->BA3_FILIAL
				BC3->BC3_MATRIC := BA3->(BA3_CODINT + BA3_CODEMP + BA3_MATRIC)
				BC3->BC3_TIPO   := "0"
				BC3->BC3_DATA   := dDataBloBe
				BC3->BC3_MOTBLO := cMotBlo
				BC3->BC3_USUOPE :=cUserName
				BC3->BC3_NIVBLQ := "F"
				BC3->BC3_BLOFAT := "1"
				BC3->BC3_DATLAN :=dDataBase
				BC3->BC3_HORLAN := Time()
				BC3->BC3_SOL412 :="0"
				if lVldBc3
					BC3->BC3_ORIBLO := "03"//03 Origem Do Bloqueio Pelo Bloqueio Automatico
				EndIF
				BC3->BC3_IDBCA := (cAlias)->BCA_ID

			BC3->(MsUnlock())

		End Transaction

		(cAlias)->(dbCloseArea())
		oExecBCA:destroy()
    	freeObj(oExecBCA)
	endif
Return 

/*/{Protheus.doc} MgsLogBloFml
	(long_description)
	@type  Static Function
	@author user
	@since 28/01/2026
	@version version
	@param param_name, param_type, param_descr
	@return return_var, return_type, return_description
	@example
	(examples)
	@see (links_or_references)
/*/
Static Function MLogBloAlt(cMegBloAut)
	
	Default cMegBloAut := ""

	plsLogFil('------------------------------------------INICIO-----------------------------------------------',  LOG_FILE )
	PlsLogFil("DATA [" + DToC(ddatabase) + "]", LOG_FILE)
	PlsLogFil("HORA [" +  Time() + "]", LOG_FILE)
	plsLogFil(cMegBloAut, LOG_FILE )
	plsLogFil("Em caso de dúvidas, consulte a documentação técnica: https://tdn.totvs.com/pages/viewpage.action?pageId=1023303146", LOG_FILE )
	plsLogFil('-------------------------------------------FIM-------------------------------------------------' , LOG_FILE)
Return 

/*/{Protheus.doc} schedDef
Definicao dos perguntes para o botao parametros do schedule
@type function
@version 12.1.2510
@author rafael.aolivera
@since 17/01/2025
@return array, com o tipo (P = Processo e R = Relatorios), pergunte, alias, ordem e titulo.
/*/
Static Function Scheddef()

Return  {'P', 'PLBLOFMY', 'BG3', {}, 'Bloqueio Automatico',,.F.,.F.}

