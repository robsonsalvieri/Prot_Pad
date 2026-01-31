#Include 'Protheus.ch'

/*/{Protheus.doc} PLSBLOFLM
Rotina Criada Para validar existencia de empresas sem data de bloqueio, porem com todos os usarios bloqueados
@version 12.1.2510
@author rafael.aoliveira
@since 17/01/2025
/*/
Function PLSBLOFML()

	LOCAL cQuery  := "" as character
    LOCAL oExecBA3 := Nil as object
	LOCAL nOrder := 1 as numeric
	Local cAlias := "" as character


	cQuery := "WITH ? AS (  "
	cQuery += "SELECT ? "
	cQuery += "FROM ? "
	cQuery += " WHERE "
	cQuery += "D_E_L_E_T_ = ''  "
	cQuery += "GROUP BY  "
	cQuery += " ? "
	cQuery += "HAVING  "
	cQuery += "COUNT(R_E_C_N_O_) = SUM(  "
	cQuery += "CASE WHEN BA1_DATBLO <> ' ' THEN 1 ELSE 0 END   "
	cQuery += ")  "
	cQuery += "AND MAX(BA1_DATBLO) <= ? "
	cQuery += ")  "
	cQuery += "SELECT "
	cQuery += " ? "
	cQuery += "FROM  "
	cQuery += " ? BA3  "
	cQuery += "INNER JOIN ? BT ON BA3.BA3_FILIAL = BT.BA1_FILIAL   "
	cQuery += "AND BA3.BA3_CODEMP = BT.BA1_CODEMP    "
	cQuery += "AND BA3.BA3_MATRIC = BT.BA1_MATRIC    "
	cQuery += "AND BA3.BA3_CODINT = BT.BA1_CODINT    "
	cQuery += "WHERE "
	cQuery += "BA3.D_E_L_E_T_ = ' ' "
	cQuery += "AND BA3.BA3_DATBLO = ' ' "

	oExecBA3 := FwExecStatement():new(cQuery)

	oExecBA3:setUnsafe(nOrder++, " BLOQUEADOS_TOTAL ")
	oExecBA3:setUnsafe(nOrder++, " BA1_FILIAL, BA1_CODEMP, BA1_MATRIC, BA1_CODINT  ")
	oExecBA3:setUnsafe(nOrder++, RetSqlName("BA1") )
	oExecBA3:setUnsafe(nOrder++, " BA1_FILIAL, BA1_CODINT, BA1_CODEMP, BA1_MATRIC ")
	oExecBA3:setString(nOrder++, dToS(dDatabase))
	oExecBA3:setUnsafe(nOrder++, " BA3.R_E_C_N_O_  ")
	oExecBA3:setUnsafe(nOrder++, RetSqlName("BA3"))
	oExecBA3:setUnsafe(nOrder++, "BLOQUEADOS_TOTAL")


	cAlias := oExecBA3:openAlias()

	
	while !(cAlias)->(eof())

		updBa3Bc3((cAlias)->R_E_C_N_O_)
	
		(cAlias)->(dbSkip())
		
	end


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
Static Function updBa3Bc3(nRecBA3)
	
	LOCAL cSql  := "" as character
	Local oExecBCA := Nil  as object
	Local nOrder := 1 as numeric
	Local cAlias := "" as character
	Local cMotBlo := AllTrim(MV_PAR01) as character

	Default nRecBA3 := 0 

	BA3->(DbGoTo(nRecBA3))

	cSQL := " SELECT ? FROM "
	cSQL += " ? BCA  "
	cSQL += " INNER JOIN ? BA1 ON  "
	cSQL += " BCA.BCA_FILIAL = BA1.BA1_FILIAL AND "
	cSQL += " BCA.BCA_MATRIC = BA1.BA1_CODINT+BA1.BA1_CODEMP+BA1.BA1_MATRIC AND "
	cSQL += " BCA.BCA_TIPREG = BA1.BA1_TIPREG  "
	cSQL += " WHERE  "
	cSQL += " BA1.BA1_FILIAL = ?   AND "
	cSQL += " BA1.BA1_CODINT = ?   AND "
	cSQL += " BA1.BA1_CODEMP = ?   AND "
	cSQL += " BA1.BA1_MATRIC = ?   AND "
	cSQL += " BA1.BA1_TIPUSU = 'T' AND "
	cSQL += " BA1.D_E_L_E_T_ = ''  AND "
	cSQL += " BCA.BCA_FILIAL = ?   AND "
	cSQL += " BCA.BCA_TIPO   = '0' AND "
	cSQL += " BCA.D_E_L_E_T_ = '' "


	oExecBCA := FwExecStatement():new(cSQL)

	oExecBCA:setUnsafe(nOrder++, "MAX(BCA.BCA_ID) BCA_ID")
	oExecBCA:setUnsafe(nOrder++, RetSqlName("BCA"))
	oExecBCA:setUnsafe(nOrder++, RetSqlName("BA1"))
	oExecBCA:setString(nOrder++, BA3->BA3_FILIAL)
	oExecBCA:setString(nOrder++, BA3->BA3_CODINT)
	oExecBCA:setString(nOrder++, BA3->BA3_CODEMP)
	oExecBCA:setString(nOrder++, BA3->BA3_MATRIC)
	oExecBCA:setString(nOrder++, BA3->BA3_FILIAL)

	cAlias := oExecBCA:openAlias()

	Begin Transaction

		BA3->(RecLock("BA3",.F.))
			BA3->BA3_DATBLO := dDataBase
			BA3->BA3_MOTBLO := cMotBlo
		BA3->(MsUnlock())


		BC3->(RecLock("BC3",.T.))
		
			BC3->BC3_FILIAL := BA3->BA3_FILIAL
			BC3->BC3_MATRIC := BA3->(BA3_CODINT + BA3_CODEMP + BA3_MATRIC)
			BC3->BC3_TIPO := "0"
			BC3->BC3_DATA := dDataBase
			BC3->BC3_MOTBLO := cMotBlo
			BC3->BC3_USUOPE:=cUserName
			BC3->BC3_NIVBLQ := "F"
			BC3->BC3_BLOFAT := "1"
			BC3->BC3_DATLAN :=dDataBase
			BC3->BC3_HORLAN := Time()
			BC3->BC3_SOL412 :="0"
			BC3->BC3_ORIBLO := "03"
			BC3->BC3_IDBCA := (cAlias)->BCA_ID

		BC3->(MsUnlock())

	End Transaction

	(cAlias)->(dbCloseArea())
	oExecBCA:destroy()
    freeObj(oExecBCA)
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
	Local aParam := {}

	aParam := {'P', 'PLBLOFMY', 'BG3', {}, 'Bloqueio Automatico'}

Return aParam

