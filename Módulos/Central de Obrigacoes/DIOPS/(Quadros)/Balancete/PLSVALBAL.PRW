#include 'totvs.ch'

//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} DIOVLDD001

Funcao criada para validar Critica D001
Valor da conta é diferente do valor da soma de seus subitens

@return lRetorno	.F. registro criticao ou .T. registro nao criticao

@author everton.mateus
@since 19/05/2016
/*/
//--------------------------------------------------------------------------------------------------
Function DIOVLDD001(oModel)
	Local lRet 		:= .T.

	Local cDB	  	:= TCGetDB()
	Local cSql 		:= ""
	Local cCodOpe 	:= ""
	Local cCodObr 	:= ""
	Local cAnoCmp 	:= ""
	Local cCodComp	:= ""
	Local cConta 	:= ""

	Default oModel := Nil

	If oModel == Nil
		cCodOpe  	:= AllTrim(B8A->B8A_CODOPE)
		cCodObr  	:= AllTrim(B8A->B8A_CODOBR)
		cAnoCmp  	:= AllTrim(B8A->B8A_ANOCMP)
		cCodComp 	:= AllTrim(B8A->B8A_CDCOMP)
		cConta 		:= AllTrim(B8A->B8A_CONTA)
	Else
		cCodOpe	:= AllTrim(oModel:GetValue( 'B8AMASTER', 'B8A_CODOPE' ))
		cCodObr	:= AllTrim(oModel:GetValue( 'B8AMASTER', 'B8A_CODOBR' ))
		cAnoCmp	:= AllTrim(oModel:GetValue( 'B8AMASTER', 'B8A_ANOCMP' ))
		cCodComp:= AllTrim(oModel:GetValue( 'B8AMASTER', 'B8A_CDCOMP' ))
		cConta 	:= AllTrim(oModel:GetValue( 'B8AMASTER', 'B8A_CONTA' ))
	EndIf

	//SELECT B8A_CONTA, B8A_SALFIN FROM B8AT10 WHERE B8A_CONTA LIKE '2%' AND LEN(B8A_CONTA) = 2 AND B8A_CONTA <> '29' OR B8A_CONTA = '2'
	cSql := " SELECT SUM(B8A_SALFIN) AS SUMPAI , ( "
	cSql += " 		SELECT Sum(B8A_SALFIN) "
	cSql += "		FROM " + RetSqlName("B8A")
	cSql += " 		WHERE B8A_FILIAL = '" + xFilial("B8A") + "' "
	cSql += " 				AND B8A_CODOPE = '" + cCodOpe + "' "
	cSql += " 				AND B8A_CODOBR = '" + cCodObr + "' "
	cSql += " 				AND B8A_ANOCMP = '" + cAnoCmp + "' "
	cSql += " 				AND B8A_CDCOMP = '" + cCodComp + "' "
	cSql += " 				AND ( B8A_CONTA like '" + cConta + "%' "
	If cConta == "4"
		cSql += " 				OR B8A_CONTA = '61' )"
	Else
		cSql += " ) "
	EndIf
	If cConta == "1"
		cSql += " 			AND B8A_CONTA <> '19' "
	ElseIf cConta == "2"
		cSql += " 			AND B8A_CONTA <> '29' "
	EndIf
	If (cDB $ "POSTGRES/ORACLE")
		cSql += " 				AND LENGTH(B8A_CONTA) = " + AllTrim(Str(Len(cConta)+1)) + " "
	Else

		cSql += " 				AND LEN(B8A_CONTA) = " + AllTrim(Str(Len(cConta)+1)) + " "
	EndIf
	cSql += " 				AND D_E_L_E_T_ = ' ' "
	cSql += "		) SUMFILHOS "
	cSql += "	FROM " + RetSqlName("B8A")
	cSql += "	WHERE B8A_FILIAL = '" + xFilial("B8A") + "' "
	cSql += "			AND B8A_CODOPE = '" + cCodOpe + "' "
	cSql += "			AND B8A_CODOBR = '" + cCodObr + "' "
	cSql += "			AND B8A_ANOCMP = '" + cAnoCmp + "' "
	cSql += "			AND B8A_CDCOMP = '" + cCodComp + "' "
	cSql += "			AND B8A_CONTA = '" + cConta + "' "
	cSql += " 			AND D_E_L_E_T_ = ' ' "


	IIf (cDB $ "POSTGRES/ORACLE",cSql += " GROUP BY 1 ",cSql += "")

	cSql := ChangeQuery(cSql)
	dbUseArea(.T.,"TOPCONN",TCGENQRY(,,cSql),"TRBCON",.F.,.T.)

	If !TRBCON->(Eof())

		lRet := NoRound(TRBCON->SUMFILHOS,2) == 0 .OR. NoRound(TRBCON->SUMPAI,2) - NoRound(TRBCON->SUMFILHOS,2) == 0

	EndIf

	TRBCON->(dbCloseArea())

Return lRet
//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} DIOVLDD002

Funcao criada para validar Critica D002
Para esta conta o do saldo final deve ser menor ou igual a zero

@return lRetorno	.F. registro criticao ou .T. registro nao criticao

@author everton.mateus
@since 19/05/2016
/*/
//--------------------------------------------------------------------------------------------------
Function DIOVLDD002(oModel)
	Local lRet := .T.
	Local aNegativo := DiCntRed()

	Default oModel := Nil

	If oModel == Nil
		cConta 	:= AllTrim(B8A->B8A_CONTA)
		nSldFin	:= B8A->B8A_SALFIN
	Else
		cConta 	:= AllTrim(oModel:GetValue( 'B8AMASTER', 'B8A_CONTA' ))
		nSldFin 	:= oModel:GetValue( 'B8AMASTER', 'B8A_SALFIN' )
	EndIf

	nPos := Ascan( aNegativo,{|x| x == cConta })

	lRet := nPos == 0 .OR. Round(nSldFin,2) <= 0

Return lRet

//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} DiCntRed

Funcao para retornar um array com relacao de contas negativas ANS

@return aNegativo

@author p.drivas
@since 12/03/2020
/*/
//--------------------------------------------------------------------------------------------------
Function DiCntRed()
	Local aNegativo := {"12211909","122119099","12212909","122129099","12213909",;
		"122139099","12218909","122189099","12221909","122219099",;
		"12222909","122229099","12223909","122239099","12228909",;
		"122289099","12311109","12311209","12312109","12312209",;
		"123219019","123219029","123229019","123229029","123311019",;
		"123312019","123321019","123322019","12341109","123411091",;
		"12341209","123412091","12342109","123421091","12342209",;
		"123422091","123911019","123911029","123911089","123912089",;
		"123921019","123921029","123921089","123922089","124119019",;
		"124119029","124119089","124129019","124129029","124129089",;
		"127419019","127619019","127719019","127729019","127819019",;
		"129119019","13111909","131119099","13112909","131129099",;
		"13113909","131139099","13118909","131189099","13121909",;
		"131219099","13122909","131229099","13123909","131239099",;
		"13128909","131289099","131419012","131419019","131419022",;
		"131419029","131419039","131429012","131429019","131429082",;
		"131429089","131439012","131439022","131489012","131489019",;
		"131819012","131819019","132119019","132119029","132129019",;
		"132129029","132139019","132139029","132149019","132149029",;
		"132159019","132159029","132319019","13241902","132419021",;
		"132419022","13241903","13281909","132819091","132819098",;
		"13311902","13311903","13312902","13312903","13321902",;
		"13321903","13322902","13322903","13331902","13332902",;
		"13341902","13341903","13342902","13342903","13411902",;
		"134119021","134119022","134119023","134119024","134119029",;
		"13411903","134119031","134119032","134119033","134119034",;
		"134119039","13412902","134129021","134129022","134129029",;
		"13412903","134129031","134129032","134129039","216119012",;
		"216119022","217119019","217219019","237719019","237729019",;
		"238829019","238839019","238889089","2512","25121",;
		"251219","25121901","251219011","251219012","25325",;
		"253259","25325901","253259011","253259012","255",;
		"2551","25511","255119","25511901","255119011",;
		"3117","31171","31172","3119","31191",;
		"31192","32","321","3211","32111",;
		"321119","32111901","321119011","321119012","321119013",;
		"32112","321129","32112901","321129011","321129012",;
		"321129013","332119012","332129012","332139012","332149012",;
		"332159012","34","341","3411","34111",;
		"341119","34111901","341119011","341119012","341119013",;
		"34112","341129","34112901","341129011","341129012",;
		"341129013","4314","43141","431419 ","43141901",;
		"43142","431429","43142901","441319043","441329043",;
		"4416","44161","441619","44161901","441619011",;
		"441619019","44162","441629","44162901","441629011",;
		"441629019","441919019","441919029","441919039","441919059",;
		"441929019","441929029","441929039","441929059","44211902",;
		"442119021","442119029","442119039","44212902","442129021",;
		"442129029","442129039","471119019"}

Return aNegativo
//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} DIOVLDD003

Funcao criada para validar Critica D004
Conta não existe no Plano de Contas da ANS

@return lRetorno	.F. registro criticao ou .T. registro nao criticao

@author everton.mateus
@since 19/05/2016
/*/
//--------------------------------------------------------------------------------------------------
Function DIOVLDD003(oModel)
	Local lRet := .T.
	Local cSql 	:= ""
	Local aPerIni := {}
	Local aPerFim := {}
	Default oModel := Nil

	aAdd(aPerIni,{"01","04","07","10"})
	aAdd(aPerFim,{"03","06","09","12"})

	If oModel == Nil
		cAnoCmp  	:= AllTrim(B8A->B8A_ANOCMP)
		cCodComp 	:= AllTrim(B8A->B8A_CDCOMP)
		cConta 	:= AllTrim(B8A->B8A_CONTA)
	Else
		cAnoCmp	:= AllTrim(oModel:GetValue( 'B8AMASTER', 'B8A_ANOCMP' ))
		cCodComp	:= AllTrim(oModel:GetValue( 'B8AMASTER', 'B8A_CDCOMP' ))
		cConta 	:= AllTrim(oModel:GetValue( 'B8AMASTER', 'B8A_CONTA' ))
	EndIf

	cDataFim := cAnoCmp + aPerFim[1,val(cCodComp)] + "99"
	cDataIni := cAnoCmp + aPerIni[1,val(cCodComp)] + "01"

	cSql := " SELECT B8B_CONTA FROM " + RetSqlName("B8B")
	cSql += " WHERE B8B_FILIAL = '" + xFilial("B8B") + "' "
	cSql += " AND B8B_CONTA = '" + subStr(cConta,1,9) + "' "
	cSql += " AND B8B_VIGINI <= '" + cDataFim + "' "
	cSql += " AND (B8B_VIGFIN >= '" + cDataIni + "' or B8B_VIGFIN=' ') "
	cSql += " AND D_E_L_E_T_ = ' '"
	cSql := ChangeQuery(cSql)
	dbUseArea(.T.,"TOPCONN",TCGENQRY(,,cSql),"TRBB8B",.F.,.T.)

	lRet := !TRBB8B->(Eof())

	TRBB8B->(dbCloseArea())

Return lRet

//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} DIOVLDD004

Funcao criada para validar Critica D005 - Verifica se foi importado todos os grupos 1-Ativo, 2-Passivo, 3-Receitas e 4-Despesas

@return lRetorno	.F. registro criticao ou .T. registro nao criticao

@author timoteo.bega
@since 04/12/2017
/*/
//--------------------------------------------------------------------------------------------------
Function DIOVLDD004(oModel)
	Local lRet		:= .T.
	Local cSql		:= ""
	Local aGrupos	:= {{'1',.F.},{'2',.F.},{'3',.F.},{'4',.F.}}
	Local cCodOpe	:= ""
	Local cCodObr	:= ""
	Local cAnoCmp	:= ""
	Local cCdComp	:= ""
	Local cNAlias	:= GetNextAlias()

	If oModel == Nil
		cCodOpe := AllTrim(B8A->B8A_CODOPE)
		cCodObr := AllTrim(B8A->B8A_CODOBR)
		cAnoCmp := AllTrim(B8A->B8A_ANOCMP)
		cCdComp := AllTrim(B8A->B8A_CDCOMP)
	Else
		cCodOpe := AllTrim(oModel:GetValue( 'B8AMASTER', 'B8A_CODOPE' ))
		cCodObr := AllTrim(oModel:GetValue( 'B8AMASTER', 'B8A_CODOBR' ))
		cAnoCmp := AllTrim(oModel:GetValue( 'B8AMASTER', 'B8A_ANOCMP' ))
		cCdComp := AllTrim(oModel:GetValue( 'B8AMASTER', 'B8A_CDCOMP' ))
	EndIf

	cSql := "SELECT B8A_CONTA FROM " + RetSqlName("B8A") + " WHERE B8A_FILIAL='"+xFilial("B8A")+"' AND B8A_CODOPE='"+cCodOpe+"' AND B8A_CODOBR='"+cCodObr+"' AND B8A_ANOCMP='"+cAnoCmp+"' AND B8A_CDCOMP='"+cCdComp+"' AND B8A_CONTA IN ('1','2','3','4') AND D_E_L_E_T_=' '"
	cSql := ChangeQuery(cSql)
	dbUseArea(.T.,"TOPCONN",TCGENQRY(,,cSql),cNAlias,.F.,.T.)

	While !(cNAlias)->(Eof())

		nPos := aScan(aGrupos,{|x| x[1] == AllTrim((cNAlias)->B8A_CONTA) })
		//Para cada grupo encontrado eu tiro a critica
		If nPos > 0
			aGrupos[nPos,2] := .T.
		EndIf
		(cNAlias)->(dbSkip())

	EndDo

	(cNAlias)->(dbCloseArea())

	//Se encontrou algum grupo .F. retorna critica
	If aScan(aGrupos,{|x| x[2] == .F. }) > 0
		lRet := .F.
	EndIf

Return lRet

//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} DIOVLDD005

Funcao criada para validar Critica D006 - Verifica se a conta 1-Ativo bate com a soma das contas 12 e 13

@return lRetorno	.F. registro criticao ou .T. registro nao criticao

@author timoteo.bega
@since 04/12/2017
/*/
//--------------------------------------------------------------------------------------------------
Function DIOVLDD005(oModel)
	Local lRet		:= .T.
	Local cSql		:= ""
	Local aContas	:= {"'1'","'12','13'"}//Ativo
	Local cCodOpe	:= ""
	Local cCodObr	:= ""
	Local cAnoCmp	:= ""
	Local cCdComp	:= ""
	Local cNAlias	:= GetNextAlias()
	Local nSoma		:= 0//Indice 1
	Local nTotal	:=	0//Indice 2
	Local nFor		:= 0

	If oModel == Nil
		cCodOpe := AllTrim(B8A->B8A_CODOPE)
		cCodObr := AllTrim(B8A->B8A_CODOBR)
		cAnoCmp := AllTrim(B8A->B8A_ANOCMP)
		cCdComp := AllTrim(B8A->B8A_CDCOMP)
	Else
		cCodOpe := AllTrim(oModel:GetValue( 'B8AMASTER', 'B8A_CODOPE' ))
		cCodObr := AllTrim(oModel:GetValue( 'B8AMASTER', 'B8A_CODOBR' ))
		cAnoCmp := AllTrim(oModel:GetValue( 'B8AMASTER', 'B8A_ANOCMP' ))
		cCdComp := AllTrim(oModel:GetValue( 'B8AMASTER', 'B8A_CDCOMP' ))
	EndIf

	For nFor := 1 TO 2

		cSql := "SELECT SUM(B8A_SALFIN) B8A_SALFIN FROM " + RetSqlName("B8A") + " WHERE B8A_FILIAL='"+xFilial("B8A")+"' AND B8A_CODOPE='"+cCodOpe+"' AND B8A_CODOBR='"+cCodObr+"' AND B8A_ANOCMP='"+cAnoCmp+"' AND B8A_CDCOMP='"+cCdComp+"' AND B8A_CONTA IN (" + aContas[nFor] + ") AND D_E_L_E_T_=' '"
		cSql := ChangeQuery(cSql)
		dbUseArea(.T.,"TOPCONN",TCGENQRY(,,cSql),cNAlias,.F.,.T.)

		If !(cNAlias)->(Eof())

			If nFor == 1
				nTotal := Round( (cNAlias)->B8A_SALFIN,2)
			Else
				nSoma := Round( (cNAlias)->B8A_SALFIN,2)
			EndIf

		EndIf

		(cNAlias)->(dbCloseArea())

	Next nFor

	//Se encontrou algum grupo .F. retorna critica
	If nSoma != nTotal
		lRet := .F.
	EndIf

Return lRet

//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} DIOVLDD006

Funcao criada para validar Critica D007 - Verifica se a conta 2-Passivo bate com a soma das contas 21, 23 e 25

@return lRetorno	.F. registro criticao ou .T. registro nao criticao

@author timoteo.bega
@since 04/12/2017
/*/
//--------------------------------------------------------------------------------------------------
Function DIOVLDD006(oModel)
	Local lRet		:= .T.
	Local cSql		:= ""
	Local aContas	:= {"'2'","'21','23','25'"}//Passivo
	Local cCodOpe	:= ""
	Local cCodObr	:= ""
	Local cAnoCmp	:= ""
	Local cCdComp	:= ""
	Local cNAlias	:= GetNextAlias()
	Local nSoma		:= 0//Indice 1
	Local nTotal	:=	0//Indice 2
	Local nFor		:= 0

	If oModel == Nil
		cCodOpe := AllTrim(B8A->B8A_CODOPE)
		cCodObr := AllTrim(B8A->B8A_CODOBR)
		cAnoCmp := AllTrim(B8A->B8A_ANOCMP)
		cCdComp := AllTrim(B8A->B8A_CDCOMP)
	Else
		cCodOpe := AllTrim(oModel:GetValue( 'B8AMASTER', 'B8A_CODOPE' ))
		cCodObr := AllTrim(oModel:GetValue( 'B8AMASTER', 'B8A_CODOBR' ))
		cAnoCmp := AllTrim(oModel:GetValue( 'B8AMASTER', 'B8A_ANOCMP' ))
		cCdComp := AllTrim(oModel:GetValue( 'B8AMASTER', 'B8A_CDCOMP' ))
	EndIf

	For nFor := 1 TO 2

		cSql := "SELECT SUM(B8A_SALFIN) B8A_SALFIN FROM " + RetSqlName("B8A") + " WHERE B8A_FILIAL='"+xFilial("B8A")+"' AND B8A_CODOPE='"+cCodOpe+"' AND B8A_CODOBR='"+cCodObr+"' AND B8A_ANOCMP='"+cAnoCmp+"' AND B8A_CDCOMP='"+cCdComp+"' AND B8A_CONTA IN (" + aContas[nFor] + ") AND D_E_L_E_T_=' '"
		cSql := ChangeQuery(cSql)
		dbUseArea(.T.,"TOPCONN",TCGENQRY(,,cSql),cNAlias,.F.,.T.)

		If !(cNAlias)->(Eof())

			If nFor == 1
				nTotal := Round( (cNAlias)->B8A_SALFIN,2)
			Else
				nSoma := Round( (cNAlias)->B8A_SALFIN,2)
			EndIf

		EndIf

		(cNAlias)->(dbCloseArea())

	Next nFor

	//Se encontrou algum grupo .F. retorna critica
	If cValToChar(nSoma) != cValTochar(nTotal)
		lRet := .F.
	EndIf

Return lRet

//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} DIOVLDD007

Funcao criada para validar Critica D007 - Verifica a regra (Sld. Anterior + Débitos - Créditos) diferente do Saldo Final - Ativo

@return lRetorno	.F. registro criticao ou .T. registro nao criticao

@author timoteo.bega
@since 04/12/2017
/*/
//--------------------------------------------------------------------------------------------------
Function DIOVLDD007()
	Local lRet		:= .T.
	Local cConta	:= AllTrim(SubStr(B8A->B8A_CONTA,1,1))
	Local nValFin	:= Round( B8A->B8A_SALFIN, 2 )
	Local nValCal	:= Round( B8A->B8A_SALANT + B8A->B8A_DEBITO - B8A->B8A_CREDIT, 2 )

 	If cConta $ '1/4/6/7' .And. nValFin != nValCal
		lRet := .F.
	EndIf

Return lRet

//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} DIOVLDD008

Funcao criada para validar Critica D007 - Verifica a regra (Sld. Anterior + Débitos - Créditos) diferente do Saldo Final - Passivo

@return lRetorno	.F. registro criticao ou .T. registro nao criticao

@author timoteo.bega
@since 04/12/2017
/*/
//--------------------------------------------------------------------------------------------------
Function DIOVLDD008()
	Local lRet		:= .T.
	Local cConta	:= AllTrim(SubStr(B8A->B8A_CONTA,1,1))
	Local nValFin	:= Round( B8A->B8A_SALFIN, 2 )
	Local nValCal	:= Round( B8A->B8A_SALANT - B8A->B8A_DEBITO + B8A->B8A_CREDIT, 2 )

	If cConta $ '2/3' .And. nValFin != nValCal
		lRet := .F.
	EndIf

Return lRet
