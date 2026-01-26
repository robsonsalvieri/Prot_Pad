#Include 'totvs.ch'
#Define CORRESP '6'
//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} PLVLDCOA01

Funcao criada para validar Critica CA01
Somatório dos itens referente a Planos IFAL não confere com o total das contas 411X1101.
41111101;Planos Individuais/Familiares antes da Lei
41121101;Planos Individuais/Familiares antes da Lei
41131101;Planos Individuais/Familiares antes da Lei
41141101;Planos Individuais/Familiares antes da Lei
41151101;Planos Individuais/Familiares antes da Lei
41171101;Planos Individuais/Familiares antes da Lei
41181101;Planos Individuais/Familiares antes da Lei
41191101;Planos Individuais/Familiares antes da Lei

@return lRetorno	.F. registro criticado ou .T. registro nao criticado

@author Roger C
@since 23/11/2016
/*/
//--------------------------------------------------------------------------------------------------
Function PLVLDCOA01()
	Local lRetorno	:= .F.
	Local cPlano	:= 'IFAL'
	Local aContas	:= {'41111101',;
						'41121101',;
						'41131101',;
						'41141101',;
						'41151101',;
						'41171101',;
						'41181101',;
						'41191101'}

	lRetorno	:= PlVldCoAGe(cPlano, aContas)

Return lRetorno

//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} PLVLDCOA02

Funcao criada para validar Critica CA02
Somatório dos itens referente a Planos IFPL não confere com o total das contas 411X1102.
41111102;Planos Individuais/Familiares depois da Lei
41121102;Planos Individuais/Familiares depois da Lei
41131102;Planos Individuais/Familiares depois da Lei
41141102;Planos Individuais/Familiares depois da Lei
41151102;Planos Individuais/Familiares depois da Lei
41171102;Planos Individuais/Familiares depois da Lei
41181102;Planos Individuais/Familiares depois da Lei
41191102;Planos Individuais/Familiares depois da Lei

@return lRetorno	.F. registro criticado ou .T. registro nao criticado

@author Roger C
@since 23/11/2016
/*/
//--------------------------------------------------------------------------------------------------
Function PLVLDCOA02()
	Local lRetorno	:= .F.
	Local cPlano	:= 'IFPL'
	Local aContas	:= {'41111102',;
						'41121102',;
						'41131102',;
						'41141102',;
						'41151102',;
						'41171102',;
						'41181102',;
						'41191102'}

	lRetorno	:= PlVldCoAGe(cPlano, aContas)

Return lRetorno

//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} PLVLDCOA03

Funcao criada para validar Critica CA03
Somatório dos itens referente a Planos PLAL não confere com o total das contas 411X1103.
41111103;Planos Coletivos por Adesão antes da Lei
41121103;Planos Coletivos por Adesão antes da Lei
41131103;Planos Coletivos por Adesão antes da Lei
41141103;Planos Coletivos por Adesão antes da Lei
41151103;Planos Coletivos por Adesão antes da Lei
41171103;Planos Coletivos por Adesão antes da Lei
41181103;Planos Coletivos por Adesão antes da Lei
41191103;Planos Coletivos por Adesão antes da Lei
@return lRetorno	.F. registro criticado ou .T. registro nao criticado

@author Roger C
@since 23/11/2016
/*/
//--------------------------------------------------------------------------------------------------
Function PLVLDCOA03()
	Local lRetorno	:= .F.
	Local cPlano	:= 'PLAL'
	Local aContas	:= {'41111103',;
						'41121103',;
						'41131103',;
						'41141103',;
						'41151103',;
						'41171103',;
						'41181103',;
						'41191103'}

	lRetorno	:= PlVldCoAGe(cPlano, aContas)

Return lRetorno

//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} PLVLDCOA04

Funcao criada para validar Critica CA04
Somatório dos itens referente a Planos PLAP não confere com o total das contas 411X1104.
41111104;Planos Coletivos por Adesão depois da  Lei
41121104;Planos Coletivos por Adesão depois da  Lei
41131104;Planos Coletivos por Adesão depois da  Lei
41141104;Planos Coletivos por Adesão depois da  Lei
41151104;Planos Coletivos por Adesão depois da  Lei
41171104;Planos Coletivos por Adesão depois da  Lei
41181104;Planos Coletivos por Adesão depois da  Lei
41191104;Planos Coletivos por Adesão depois da  Lei
@return lRetorno	.F. registro criticado ou .T. registro nao criticado

@author Roger C
@since 23/11/2016
/*/
//--------------------------------------------------------------------------------------------------
Function PLVLDCOA04()
	Local lRetorno	:= .F.
	Local cPlano	:= 'PLAP'
	Local aContas	:= {'41111104',;
						'41121104',;
						'41131104',;
						'41141104',;
						'41151104',;
						'41171104',;
						'41181104',;
						'41191104'}

	lRetorno	:= PlVldCoAGe(cPlano, aContas)

Return lRetorno

//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} PLVLDCOA05

Funcao criada para validar Critica CA05
Somatório dos itens referente a Planos PCEA não confere com o total das contas 411X1105.
41111105;Planos Coletivos Empresariais antes da Lei
41121105;Planos Coletivos Empresariais antes da Lei
41131105;Planos Coletivos Empresariais antes da Lei
41141105;Planos Coletivos Empresariais antes da Lei
41151105;Planos Coletivos Empresariais antes da Lei
41171105;Planos Coletivos Empresariais antes da Lei
41181105;Planos Coletivos Empresariais antes da Lei
41191105;Planos Coletivos Empresariais antes da Lei
@return lRetorno	.F. registro criticado ou .T. registro nao criticado

@author Roger C
@since 23/11/2016
/*/
//--------------------------------------------------------------------------------------------------
Function PLVLDCOA05()
	Local lRetorno	:= .F.
	Local cPlano	:= 'PCEA'
	Local aContas	:= {'41111105',;
						'41121105',;
						'41131105',;
						'41141105',;
						'41151105',;
						'41171105',;
						'41181105',;
						'41191105'}

	lRetorno	:= PlVldCoAGe(cPlano, aContas)

Return lRetorno

//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} PLVLDCOA06

Funcao criada para validar Critica CA06
Somatório dos itens referente a Planos PCEL não confere com o total das contas 411X1106.
41111106;Planos Coletivos Empresariais depois da  Lei
41121106;Planos Coletivos Empresariais depois da  Lei
41131106;Planos Coletivos Empresariais depois da  Lei
41141106;Planos Coletivos Empresariais depois da  Lei
41151106;Planos Coletivos Empresariais depois da  Lei
41171106;Planos Coletivos Empresariais depois da  Lei
41181106;Planos Coletivos Empresariais depois da  Lei
41191106;Planos Coletivos Empresariais depois da  Lei
@return lRetorno	.F. registro criticado ou .T. registro nao criticado

@author Roger C
@since 23/11/2016
/*/
//--------------------------------------------------------------------------------------------------
Function PLVLDCOA06()
	Local lRetorno	:= .F.
	Local cPlano	:= 'PCEL'
	Local aContas	:= {'41111106',;
						'41121106',;
						'41131106',;
						'41141106',;
						'41151106',;
						'41171106',;
						'41181106',;
						'41191106'}

	lRetorno	:= PlVldCoAGe(cPlano, aContas)

Return lRetorno

//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} PLVLDCOA07

Funcao criada para validar Critica CA07
Somatório dos itens referente a Planos CRAS não confere com o total das contas 411X1108.
41111108;Corresponsabilidade Assumida
41121108;Corresponsabilidade Assumida
41131108;Corresponsabilidade Assumida
41141108;Corresponsabilidade Assumida
41151108;Corresponsabilidade Assumida
41191108;Corresponsabilidade Assumida
@return lRetorno	.F. registro criticado ou .T. registro nao criticado

@author Everton.mateus
@since 23/05/2019
/*/
//--------------------------------------------------------------------------------------------------
Function PLVLDCOA07()
	Local lRetorno	:= .F.
	Local cPlano	:= 'CRAS'
	Local aContas	:= {'41111108',;
						'41121108',;
						'41131108',;
						'41141108',;
						'41151108',;
						'41191108'}

	lRetorno	:= PlVldCoAGe(cPlano, aContas)

Return lRetorno

//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} PLVLDCOA08

Funcao criada para validar Critica CA08
Somatório dos itens referente a IFAL - Corresponsabilidade Cedida não confere com o total da conta 31171101.
@return lRetorno	.F. registro criticado ou .T. registro nao criticado

@author everton.mateus
@since 23/05/2019
/*/
//--------------------------------------------------------------------------------------------------
Function PLVLDCOA08()
	Local lRetorno	:= .F.
	Local cPlano	:= 'IFAL'
	Local aContas	:= {'31171101'}

	lRetorno	:= PlVldCoAGe(cPlano, aContas, CORRESP)

Return lRetorno

//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} PLVLDCOA09

Funcao criada para validar Critica CA09
Somatório dos itens referente a IFPL - Corresponsabilidade Cedida não confere com o total da conta 31171102.
@return lRetorno	.F. registro criticado ou .T. registro nao criticado

@author everton.mateus
@since 23/05/2019
/*/
//--------------------------------------------------------------------------------------------------
Function PLVLDCOA09()
	Local lRetorno	:= .F.
	Local cPlano	:= 'IFPL'
	Local aContas	:= {'31171102'}

	lRetorno	:= PlVldCoAGe(cPlano, aContas, CORRESP)

Return lRetorno

//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} PLVLDCOA10

Funcao criada para validar Critica CA10
Somatório dos itens referente a PLAL - Corresponsabilidade Cedida não confere com o total da conta 31171103.

@return lRetorno	.F. registro criticado ou .T. registro nao criticado

@author everton.mateus
@since 23/05/2019
/*/
//--------------------------------------------------------------------------------------------------
Function PLVLDCOA10()
	Local lRetorno	:= .F.
	Local cPlano	:= 'PLAL'
	Local aContas	:= {'31171103'}

	lRetorno	:= PlVldCoAGe(cPlano, aContas, CORRESP)

Return lRetorno

//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} PLVLDCOA11

Funcao criada para validar Critica CA11
Somatório dos itens referente a PLAP - Corresponsabilidade Cedida não confere com o total da conta 31171104.

@return lRetorno	.F. registro criticado ou .T. registro nao criticado

@author everton.mateus
@since 23/05/2019
/*/
//--------------------------------------------------------------------------------------------------
Function PLVLDCOA11()
	Local lRetorno	:= .F.
	Local cPlano	:= 'PLAP'
	Local aContas	:= {'31171104'}

	lRetorno	:= PlVldCoAGe(cPlano, aContas, CORRESP)

Return lRetorno

//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} PLVLDCOA12

Funcao criada para validar Critica CA12
Somatório dos itens referente a PCEA - Corresponsabilidade Cedida não confere com o total da conta 31171105.

@return lRetorno	.F. registro criticado ou .T. registro nao criticado

@author everton.mateus
@since 23/05/2019
/*/
//--------------------------------------------------------------------------------------------------
Function PLVLDCOA12()
	Local lRetorno	:= .F.
	Local cPlano	:= 'PCEA'
	Local aContas	:= {'31171105'}

	lRetorno	:= PlVldCoAGe(cPlano, aContas, CORRESP)

Return lRetorno

//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} PLVLDCOA13

Funcao criada para validar Critica CA13
Somatório dos itens referente a PCEL - Corresponsabilidade Cedida não confere com o total da conta 31171106.

@return lRetorno	.F. registro criticado ou .T. registro nao criticado

@author everton.mateus
@since 23/05/2019
/*/
//--------------------------------------------------------------------------------------------------
Function PLVLDCOA13()
	Local lRetorno	:= .F.
	Local cPlano	:= 'PCEL'
	Local aContas	:= {'31171106'}

	lRetorno	:= PlVldCoAGe(cPlano, aContas, CORRESP)

Return lRetorno

//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} PLVLDCOA14

Funcao criada para validar Critica CA14
Checa se o plano é CRAS, caso seja, critica se a origem do pagamento for Reembolso ou COrresp.cedida
@return lRetorno	.F. registro criticado ou .T. registro nao criticado

@author jose.paulo
@since 17/07/2019
/*/
//--------------------------------------------------------------------------------------------------
Function PLVLDCOA14()
	Local lRetorno	:= .T.
	Local cPlano	:= 'CRAS'

    If B8I->B8I_PLANO == cPlano .And. B8I->B8I_ORIGEM $ '2/6'
    	lRetorno:= .F.
    EndIf

Return lRetorno

//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} PlVldCoAGe

Funcao criada para fazer as queries de comparação entre as contas e o balancete.

@return lRetorno	.F. registro criticao ou .T. registro nao criticao

@author Roger C
@since 22/11/2016
/*/
//--------------------------------------------------------------------------------------------------
Function PlVldCoAGe(cPlano, aConta, cOrigem)
	Local lRet := .T.
	Local cSql 	:= ""
	Local cCodOpe := ""
	Local cCodObr := ""
	Local cAnoCmp := ""
	Local cCdComp:= ""
	Local cConta:= ""
	Local nSldCob	:= 0
	Local nVez	:= 0
	Local nLen	:= 0
	Local nAlia1	:= GetNextAlias()
	Local nAlia2	:= GetNextAlias()

	Default cOrigem := ''
	Default cPlano	:= ''
	Default aConta	:= {}
	
	lRet := !Empty(cPlano) .And. !Empty(aConta)
	If lRet
		nLen := Len(aConta)
		cCodOpe := AllTrim(B3D->B3D_CODOPE)
		cCodObr := AllTrim(B3D->B3D_CDOBRI)
		cAnoCmp := AllTrim(B3D->B3D_ANO)
		cCdComp := AllTrim(B3D->B3D_CODIGO)
	
		cSql := " SELECT SUM(B8I_CONSUL) CONSULTAS,"
		cSql += " SUM(B8I_EXAMES) EXAMES,"
		cSql += " SUM(B8I_TERAPI) TERAPI,"
		cSql += " SUM(B8I_INTERN) INTERN,"
		cSql += " SUM(B8I_OUTROS) OUTROS,"
		cSql += " SUM(B8I_DEMAIS) DEMAIS "
		cSql += "	FROM " + RetSqlName("B8I")
		cSql += "	WHERE B8I_FILIAL = '" + xFilial("B8I") + "' "
		cSql += "			AND B8I_CODOPE = '" + cCodOpe + "' "
		cSql += "			AND B8I_CODOBR = '" + cCodObr + "' "
		cSql += "			AND B8I_ANOCMP = '" + cAnoCmp + "' "
		cSql += "			AND B8I_CDCOMP = '" + cCdComp + "' "
		cSql += "			AND B8I_PLANO  = '" + cPlano + "' "
		If !Empty(cOrigem)
			cSql += "		AND B8I_ORIGEM  = '" + cOrigem + "' "
		Else
			cSql += "		AND B8I_ORIGEM  <> '" + '6' + "' "
		EndIf
		cSql += " 			AND D_E_L_E_T_ = ' ' "
			
		cSql := ChangeQuery(cSql)
		dbUseArea(.T.,"TOPCONN",TCGENQRY(,,cSql),nAlia1,.F.,.T.)

		If !(nAlia1)->(Eof())
			// Se há dados sobre o quadro, guarda valor para comparação com a conta	
			nSldCob	:= (nAlia1)->( CONSULTAS + EXAMES + TERAPI + INTERN + OUTROS + DEMAIS )

			For nVez := 1 to nLen
				cConta += aConta[nVez]+IIf(nVez<>nLen,',','')
			Next
			cConta := FormatIn(cConta,",")

			cSql := " SELECT SUM(B8A_SALFIN) AS VALCTB "
			cSql += "	FROM " + RetSqlName("B8A")
			cSql += "	WHERE B8A_FILIAL = '" + xFilial("B8A") + "' "
			cSql += "			AND B8A_CODOPE = '" + cCodOpe + "' "
			cSql += "			AND B8A_CODOBR = '" + cCodObr + "' "
			cSql += "			AND B8A_ANOCMP = '" + cAnoCmp + "' "
			cSql += "			AND B8A_CDCOMP = '" + cCdComp + "' "
			cSql += "			AND B8A_CONTA  IN " + cConta + " "
			cSql += " 			AND D_E_L_E_T_ = ' ' "
				
			cSql := ChangeQuery(cSql)
			dbUseArea(.T.,"TOPCONN",TCGENQRY(,,cSql),nAlia2,.F.,.T.)

			If !(nAlia2)->(Eof())
				lRet := ( (nAlia2)->VALCTB == nSldCob )
			Else
				lRet	:= .F.
			EndIf
			(nAlia2)->(dbCloseArea())
		Else
			lRet := .T.
		EndIf
		(nAlia1)->(dbCloseArea())
	EndIf
	 
Return lRet


//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} PLSCKPGT

Funcao criada para validar o Plano X Origem Pagamento

@return lRetorno	.F. registro criticao ou .T. registro nao criticao

@author José paulo
@since 17/07/2019
/*/
//--------------------------------------------------------------------------------------------------
Function PLSCKPGT(cOrigem)
	Local lReturn   := .T.
	Local cContPla  := ""
	Default cOrigem := ""

	If cOrigem = "P"
		If M->B8I_PLANO =='CRAS' .And. M->B8I_ORIGEM $ '2/6'
			HELP( ,, 'HELP',,"O campo Plano não pode ter o conteúdo Corresp.Assumida quando o campo Origem Pgto for igual a Reembolso ou Corresp.Cedida.", 1,0,NIL,NIL,NIL,NIL,NIL,{"Favor alterar o conteúdo de um dos campos mencionados."})
			lReturn   := .F.
		EndIf

	ElseIf cOrigem = "O"
		If M->B8I_PLANO =='CRAS' .And. M->B8I_ORIGEM $ '2/6'
			HELP( ,, 'HELP',,"O campo Origem Pgto não pode ter o conteúdo Reembolso ou Corresp.Cedida quando o campo Plano for igual a Corresp.Assumida.", 1,0,NIL,NIL,NIL,NIL,NIL,{"Favor alterar o conteúdo de um dos campos mencionados."})
			lReturn   := .F.
		EndIf
	EndIf

return lReturn