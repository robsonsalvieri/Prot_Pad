#Include 'Protheus.ch'
#INCLUDE 'FWMVCDEF.CH'
#INCLUDE 'GTPA008X.CH'
/*/{Protheus.doc} GTPA008X
	Atualiza a tabela de recursos no siga GTP com base na SRA Protheus e RM API de integração
	@type function
	@author Cleiton Genuino da Silva
	@since 08/09/2026
	@version 1.0
	@param lJob, logical, (Indica se o processo está sendo executado em modo cego)
/*/
Function GTPA008X(oSay)
	Local aAreaGYG    := {}       as array
	Local aColab      := {}       as array
	Local cAliasTmp   := ""       as character
	Local cCatCNH     := ""       as character
	Local cCNHOrg     := ""       as character
	Local cCPF        := ""       as character
	Local cDriDesc    := ""       as character
	Local cFilOld     := ""       as character
	Local cFilSRA     := ""       as character
	Local cMarca      := ""       as character
	Local cMatric     := ""       as character
	Local cNome       := ""       as character
	Local cRA_CARGO   := ""       as character
	Local cRA_CODFUNC := ""       as character
	Local cRA_RG      := ""       as character
	Local cRA_USRADM  := ""       as character
	Local cSitFolh    := ""       as character
	Local cStatus     := ""       as character
	Local dAdmissA    := CTOD("") as date
	Local dDtEmCNH    := CTOD("") as date
	Local dDtNasc     := CTOD("") as date
	Local dDtVCCNH    := CTOD("") as date
	Local dRA_NASC    := CTOD("") as date
	Local lColaBor    := .F.      as logical
	Local lJob        := .F.      as logical
	Local lOnlyNew    := .T.      as logical
	Local lRet        := .F.      as logical
	Local lURBANO     := .F.      as logical
	Local nAtual      := 0        as numeric
	Local nImpErro    := 0        as numeric
	Local nImpOk      := 0        as numeric
	Local nOpc        := 0        as numeric
	Local nTotal      := 0        as numeric
	Local nX          := 0        as numeric
	Local oGTPLog     := nil      as object
	Local oMdl008     := nil      as object
	Local oMdlGYG     := nil      as object
	Local oStrGYG     := nil      as object
	Default oSay      := nil

	lJob := IsBlind() // Define se o processo está sendo executado em modo cego (sem interação com o usuário)
	cFilOld   := cFilAnt
	aAreaGYG  := GYG->( FwGetArea() )
	cDriDesc  := "Não encontrada"
	oGTPLog   := GTPLog():New(STR0001, lJob/*lSalva*/, !lJob/*lShow*/) //"Integracao Colaborador RH"
	oMdl008   := FwLoadModel( 'GTPA008' )
	oMdlGYG   := oMdl008:GetModel( 'GYGMASTER' )
	oStrGYG   := oMdlGYG:GetStruct()
	cMarca 	:= IIF(SuperGetMV("MV_GSXINT",,"2") == "3", "RM", "")

	oStrGYG:SetProperty('*', MODEL_FIELD_WHEN, {||.T.})

	If Valtype(oSay) # 'U'
		oSay:SetText("Iniciando processamento...")
		ProcessMessage()
	Endif

	If cMarca == "RM" .And. Pergunte('GTP008RM',!lJob)
		lOnlyNew := MV_PAR03 == 1
		aColab := CargaFuncRM(cMarca,lOnlyNew)

		For nX := 1 To Len(aColab)
			cFilSRA	:= aColab[nX][1]
			cMatric	:= aColab[nX][2]
			cNome	:= aColab[nX][3]
			cCPF	:= aColab[nX][4]
			dDtNasc := aColab[nX][5]

			cFilAnt := cFilSRA

			If !GYG->(DbSeek(xFilial('GYG')+cMatric+Padr(cCPF,TamSx3('GYG_CPF')[1])))
				nOpc	:= MODEL_OPERATION_INSERT
			ElseIf !lOnlyNew
				nOpc	:= MODEL_OPERATION_UPDATE
			Endif

			oMdl008:SetOperation(nOpc)
			If oMdl008:Activate()
				If nOpc == MODEL_OPERATION_INSERT .and. Empty(oMdlGYG:GetValue('GYG_CODIGO'))
					lRet := oMdlGYG:SetValue('GYG_CODIGO',GtpXeNum('GYG','GYG_CODIGO'))
				Endif

				lRet := lRet ;
					.and. oMdlGYG:SetValue('GYG_FUNCIO'	,cMatric);
					.and. oMdlGYG:SetValue('GYG_FILSRA'	,cFilSRA);
					.and. oMdlGYG:SetValue('GYG_NOME'	,cNome);
					.and. oMdlGYG:SetValue('GYG_CPF'	,cCPF);
					.and. oMdlGYG:SetValue('GYG_DTNASC'	,dDtNasc);
					.and. oMdlGYG:SetValue('GYG_RECCOD'	,'01')

				If lRet .and. oMdl008:VldData() .and. oMdl008:CommitData()
					nImpOk++
					oGTPLog:SetText(I18n(STR0011,{cFilSRA,cMatric,cNome}))//'Colaborador filial: #1, matricula #2, nome: #3 importado com sucesso'
				Else
					nImpErro++
					oGTPLog:SetText(I18n(STR0012,{cFilSRA,cMatric,cNome})) //'Colaborador filial: #1, matricula #2, nome: #3 importado com erro'
					oGTPLog:SetText(I18n(STR0013,{JurShowErro( oMdl008:GetErrorMessage(), , , .F.)}))//'Erro: #1'
				Endif

				oMdl008:DeActivate()
			Endif
		Next nX

	ElseIf cMarca <> "RM"
		aDescr := FWGetSX5("31")
		If Pergunte('GTPA008I',!lJob)
			cAliasTmp := BuscaFuncionarios(lJob)

			cFilDe    := MV_PAR01 //Filial De ?
			cFilAte   := MV_PAR02 //Filial Ate ?
			cCargoDe  := MV_PAR03 //Cargo De ?
			cCargoAte := MV_PAR04 //Cargo Ate ?
			cFuncDe   := MV_PAR05 //Func De ?
			cFuncAte  := MV_PAR06 //Func Ate ?
			lOnlyNew  := MV_PAR07 == 1 // Filtrar Matriculas sem Colab ?
			lUrbano   := MV_PAR08 == 1 // Recurso do Ubano ? 1 = Sim # 2 = Não
			nAtUrbano := MV_PAR09 // Atualizar recurso Ubano ? - # 1 = nenhum # 2 = Sim # 3 = Não

			oGTPLog:SetText(STR0002             )//'Iniciado processo de importação'
			oGTPLog:SetText("")
			oGTPLog:SetText(STR0003             )//"Dados utilizados para busca:"
			oGTPLog:SetText(STR0004 + cCargoDe  )//"Cargo de:"
			oGTPLog:SetText(STR0005 + cCargoAte  )//"Cargo até:"
			oGTPLog:SetText(STR0006 + cFuncDe  )//"Função de:"
			oGTPLog:SetText(STR0007 + cFuncAte  )//"Função até:"
			oGTPLog:SetText(STR0008 + IF(lOnlyNew, STR0009,STR0010) )//"Filtrar Matriculas sem Colaborador:"##"Sim"##"Não"
			oGTPLog:SetText("Recurso do Urbano :" + IF(lUrbano, STR0009,STR0010) )//"Recurso do Urbano :"##"Sim"##"Não" // Se marcar como sim o recurso será importado do RH marcando como um recurso do Urbano se deixar desmarcado será retirado como recurso do Urbano
			oGTPLog:SetText("Filial de:  " + cFilDe )
			oGTPLog:SetText("Filial até: " + cFilAte )
			oGTPLog:SetText("Atualizar recurso Ubano ?" + IF(nAtUrbano == 2, "2 = Sim ", "3 = Não")) // Atualizar recurso Ubano ? - # 1 = nenhum # 2 = Sim # 3 = Não :
			oGTPLog:SetText("")

			GYG->(DbSetOrder(2)) //GYG_FILIAL+GYG_FUNCIO+GYG_CPF+GYG_FILSRA
			If ( !empty(cAliasTmp) )
				Count To nTotal
				(cAliasTmp)->(DbGoTop())

				While (cAliasTmp)->(!EoF())
					nAtual++
					lAtuali := nAtUrbano == 2 //Por segurança só atualiza se marcar com 2=sim

					cFilSRA     := (cAliasTmp)->RA_FILIAL
					cMatric     := (cAliasTmp)->RA_MAT
					cCPF        := (cAliasTmp)->RA_CIC
					cRA_RG      := (cAliasTmp)->RA_RG
					cNome       := AllTrim((cAliasTmp)->RA_NOME)
					cStatus     := AllTrim((cAliasTmp)->RA_STATUS)
					cRA_CODFUNC := AllTrim((cAliasTmp)->RA_CODFUNC)
					cSitFolh    := (cAliasTmp)->RA_SITFOLH
					dAdmissA    := (cAliasTmp)->RA_ADMISSA
					cRA_CARGO   := (cAliasTmp)->RA_CARGO
					cRA_USRADM  := (cAliasTmp)->RA_USRADM
					dRA_NASC    := (cAliasTmp)->RA_NASC
					cFilAnt     := cFilSRA
					cCNHOrg     := DV_CNH(AllTrim((cAliasTmp)->RA_HABILIT),.T.)
					cCatCNH     := AllTrim((cAliasTmp)->RA_CATCNH)
					dDtEmCNH    := (cAliasTmp)->RA_DTEMCNH
					dDtVCCNH    := (cAliasTmp)->RA_DTVCCNH

					If Valtype(oSay) # 'U'
						oSay:SetText("Processando matrícula: " + cMatric + " Analisando registro : " + cValToChar(nAtual) + " de " + cValToChar(nTotal) + "...")
						ProcessMessage()
					Endif

					If len(aDescr) > 0 .And. ( nPos := AScan(aDescr, {|x| AllTrim(x[3]) == AllTrim(cSitFolh)}) ) > 0
						cDriDesc := AllTrim(aDescr[nPos][4])
					Endif

					If !GYG->(DbSeek(xFilial('GYG')+cMatric+Padr(cCPF,TamSx3('GYG_CPF')[1]))) // GYG_FILIAL + GYG_FUNCIO + GYG_CPF + GYG_FILSRA
						nOpc	:= MODEL_OPERATION_INSERT
						lRet	:= .T.
					Else
						lColaBor := GYG->GYG_FILSRA <> cFilSRA
						nOpc     := MODEL_OPERATION_UPDATE
						lRet     := .T.
					Endif

					If lRet
						oMdl008:SetOperation(nOpc)
						If oMdl008:Activate()
							If nOpc == MODEL_OPERATION_INSERT .and. Empty(oMdlGYG:GetValue('GYG_CODIGO'))
								lRet := oMdlGYG:SetValue('GYG_CODIGO',GtpXeNum('GYG','GYG_CODIGO'))
							Endif
							If lRet .And.GYG->(FieldPos("GYG_FUNCIO")) > 0 .And. TamSX3('GYG_FUNCIO')[3] == valtype(cMatric)
								lRet := oMdlGYG:SetValue('GYG_FUNCIO'	,cMatric)
							Endif
							If lRet .And. lColaBor .And. GYG->(FieldPos("GYG_FILSRA")) > 0 .And. TamSX3('GYG_FILSRA')[3] == valtype(cFilSRA)
								lRet := oMdlGYG:SetValue('GYG_FILSRA'	,cFilSRA)
							Endif
							If lRet .And.GYG->(FieldPos("GYG_NOME")) > 0 .And. TamSX3('GYG_NOME')[3] == valtype(cNome)
								lRet := oMdlGYG:SetValue('GYG_NOME'	,cNome)
							Endif
							If lRet .And.GYG->(FieldPos("GYG_STATUS")) > 0 .And. TamSX3('GYG_STATUS')[3] == valtype(cStatus)
								lRet := oMdlGYG:SetValue('GYG_STATUS'	,cStatus)
							Endif
							If lRet .And.GYG->(FieldPos("GYG_CPF")) > 0 .And. TamSX3('GYG_CPF')[3] == valtype(cCPF)
								lRet := oMdlGYG:SetValue('GYG_CPF'	,cCPF)
							Endif
							If lRet .And.GYG->(FieldPos("GYG_RG")) > 0 .And. TamSX3('GYG_RG')[3] == valtype(cRA_RG)
								lRet := oMdlGYG:SetValue('GYG_RG'	,cRA_RG)
							Endif
							If lRet .And.GYG->(FieldPos("GYG_FUNCOD")) > 0 .And. TamSX3('GYG_FUNCOD')[3] == valtype(cRA_CODFUNC)
								lRet := oMdlGYG:SetValue('GYG_FUNCOD'	,cRA_CODFUNC)
							Endif
							If lRet .And.GYG->(FieldPos("GYG_URBANO")) > 0 .And. TamSX3('GYG_URBANO')[3] == valtype(lUrbano)
								lRet := oMdlGYG:SetValue('GYG_URBANO'	,If(lAtuali,lUrbano,oMdlGYG:GetValue('GYG_URBANO')))
							Endif
							If lRet .And.GYG->(FieldPos("GYG_SITFOL")) > 0 .And. TamSX3('GYG_SITFOL')[3] == valtype(cSitFolh)
								lRet := oMdlGYG:SetValue('GYG_SITFOL',cSitFolh)
							Endif
							If lRet .And.GYG->(FieldPos("GYG_DESFOL")) > 0 .And. TamSX3('GYG_DESFOL')[3] == valtype(cDriDesc)
								lRet := oMdlGYG:SetValue('GYG_DESFOL',cDriDesc)
							Endif
							If lRet .And.GYG->(FieldPos("GYG_USR")) > 0 .And. TamSX3('GYG_USR')[3] == valtype(cRA_USRADM)
								lRet := oMdlGYG:SetValue('GYG_USR'	,cRA_USRADM)
							Endif
							If lRet .And.GYG->(FieldPos("GYG_DTNASC")) > 0 .And. TamSX3('GYG_DTNASC')[3] == valtype(dRA_NASC)
								lRet := oMdlGYG:SetValue('GYG_DTNASC'	,dRA_NASC)
							Endif
							If lRet .And.GYG->(FieldPos("GYG_RECCOD")) > 0
								lRet := oMdlGYG:SetValue('GYG_RECCOD'	,'01')
							Endif
							If lRet .and. oMdl008:VldData() .and. oMdl008:CommitData()
								AtuG6VG6W( GYG->(recno()) , cAliasTmp, @oGTPLog )
								nImpOk++
								oGTPLog:SetText(I18n(STR0011,{cFilSRA,cMatric,cNome}))//'Colaborador filial: #1, matricula #2, nome: #3 importado com sucesso'
							Else
								nImpErro++
								oGTPLog:SetText(I18n(STR0012,{cFilSRA,cMatric,cNome})) //'Colaborador filial: #1, matricula #2, nome: #3 importado com erro'
								oGTPLog:SetText(I18n(STR0013,{JurShowErro( oMdl008:GetErrorMessage(), , , .F.)}))//'Erro: #1'
							Endif

							oMdl008:DeActivate()
						Endif
					Endif
					(cAliasTmp)->(DbSkip())
				End
			Endif

			oGTPLog:SetText(STR0015                             )//"Finalizado processo de importação"
			oGTPLog:SetText(STR0016+ cValToChar(nImpOk+nImpErro))//"Total de Funcionários importados/alterados: "
			oGTPLog:SetText(STR0017+ cValToChar(nImpOk)         )//"Importações com Sucesso: "
			oGTPLog:SetText(STR0018+ cValToChar(nImpErro)       )//"Importações com Erro: "

			oGTPLog:ShowLog()
			If Valtype(oGTPLog) == "O"
				FREEOBJ(oGTPLog)
			Endif
		Endif

	EndIf

	If Valtype(oMdl008) == "O"
		FREEOBJ(oMdl008)
	Endif

	cFilAnt := cFilOld

	FwRestArea( aAreaGYG )

Return
/*/{Protheus.doc} BuscaFuncionarios
	Busca os funcionários na SRA considerando os novos campos para integração
	de documentos (CNH, Toxicológico) e espelhamento global de Status (GYG).
	Refatorado para Sincronização Global
	@type function
	@author Cleiton Genuino da Silva  
	@since 10/09/2026
	@version 1.0
	@param lJob, logical, Define se a execução é via JOB ou Tela
	@return character , Alias da Query temporaria.
	@obs : GTPA008I
		MV_PAR01 - Filial de ?   
		MV_PAR02 - Filial até ?   
		MV_PAR03 - Cargo de ?   
		MV_PAR04 - Cargo até ?   
		MV_PAR05 - Função de ?   
		MV_PAR06 - Função até ? 
		MV_PAR07 - Filtrar Matriculas sem Colab ?
		MV_PAR08 - Recurso do Ubano ? .T. ou .F. 
		MV_PAR09 - Atualizar recurso Ubano ? - # 1 = Sim # 2 = Não
/*/
Static Function BuscaFuncionarios(lJob)
	Local cAliasTmp := ""   as character
	Local cCargoAte := ""   as character
	Local cCargoDe  := ""   as character
	Local cFilAte   := ""   as character
	Local cFilDe    := ""   as character
	Local cFuncAte  := ""   as character
	Local cFuncDe   := ""   as character
	Local cJoinGYG  := "%%" as character
	Local cLtCargos := ""   as character
	Local cLtFunca  := ""   as character
	Local cQryCarg  := ""   as character
	Local cQryFunc  := ""   as character
	Local cWhere    := ""   as character
	Local lOnlyNew  := .F.  as logical
	Local lUrbano   := .F.  as logical
	Local nAtUrbano := 0    as numeric

	cAliasTmp := GetNextAlias()

	cFilDe    := MV_PAR01
	cFilAte   := MV_PAR02
	cCargoDe  := MV_PAR03
	cCargoAte := MV_PAR04
	cFuncDe   := MV_PAR05
	cFuncAte  := MV_PAR06
	IF(!lJob , lOnlyNew  := MV_PAR07 == 1,lOnlyNew := .F.  ) // Filtrar Matriculas sem Colab ?
		lUrbano := MV_PAR08 == 1 // Recurso do Ubano ? .T. ou .F.
		nAtUrbano := MV_PAR09 // Atualizar recurso Ubano ? - # 1 = nenhum # 2 = Sim # 3 = Não

		If Empty(cCargoDe) // De branco
			cCargoDe := Space(TamSx3('RA_CARGO')[1])
		Endif

		If Empty(cCargoAte) // Até a ZZZ
			cCargoAte := Replicate("Z", TamSx3('RA_CARGO')[1])
		Endif

		If Empty(cFuncDe) // De branco
			cFuncDe := Space(TamSx3('RA_CODFUNC')[1])
		Endif

		If Empty(cFuncAte) // Até a ZZZ
			cFuncAte := Replicate("Z", TamSx3('RA_CODFUNC')[1])
		Endif

		If lJob

			cLtCargos := Alltrim(GTPGetRules("LISTACARGO",.F.)) // Mantido por legado
			cLtFunca  := Alltrim(GTPGetRules("LISTAFUNCA",.F.)) // Mantido por legado

			If !Empty(cLtCargos)
				cQryCarg :=" AND SRA.RA_CARGO IN "+FormatIn(GTPGetRules("LISTACARGO",.F.),";") + " "
			Else
				cQryCarg :=" AND SRA.RA_CARGO BETWEEN '" + cCargoDe + "' AND '" + cCargoAte + "' "
			Endif

			If !Empty(cLtFunca)
				cQryFunc := " AND SRA.RA_CODFUNC IN "+ FormatIn(GTPGetRules("LISTAFUNCA",.F.),";") + " "
			Else
				cQryFunc := " AND SRA.RA_CODFUNC BETWEEN '" + cFuncDe + "' AND '" + cFuncAte + "' "
			Endif

		Else
			cQryCarg :=" AND SRA.RA_CARGO BETWEEN '" + cCargoDe + "' AND '" + cCargoAte + "' "
			cQryFunc := " AND SRA.RA_CODFUNC BETWEEN '" + cFuncDe + "' AND '" + cFuncAte + "' "
		Endif

		If Empty(cFilDe) // De branco
			cFilDe := Space(TamSx3('RA_FILIAL')[1])
		Endif

		If Empty(cFilAte) // Até a ZZZ
			cFilAte := Replicate("Z", TamSx3('RA_FILIAL')[1])
		Endif

		If Alltrim(cFilDe) # Alltrim(cFilAte) // Se os valores de filial de e até forem diferentes, usa BETWEEN
			cWhere+= " SRA.RA_FILIAL BETWEEN '" + cFilDe + "' AND '" + cFilAte + "'"
		ELSE
			cWhere += " SRA.RA_FILIAL = '" + AllTrim(xFilial('SRA')) + "'"
		Endif

		cWhere += cQryCarg
		cWhere += cQryFunc

		If lOnlyNew
			cJoinGYG := "%"
			cJoinGYG += " Left Join "+RetSqlName("GYG")+" GYG ON "
			cJoinGYG += " GYG.GYG_FILSRA = SRA.RA_FILIAL "
			cJoinGYG += " AND GYG.GYG_FUNCIO = SRA.RA_MAT "
			cJoinGYG += " AND GYG.D_E_L_E_T_ = ' ' "
			cJoinGYG += "%"
			cWhere+= " AND GYG.GYG_CODIGO IS NULL "
		Endif

		cWhere := '%'+cWhere+'%'

		BeginSql Alias cAliasTmp
		COLUMN RA_DTEMCNH AS DATE
		COLUMN RA_DTVCCNH AS DATE
		COLUMN RA_ADMISSA AS DATE
		COLUMN RA_NASC    AS DATE
		Select
			SRA.RA_FILIAL,
			SRA.RA_MAT,
			SRA.RA_CIC,
			SRA.RA_RG,
			SRA.RA_CODFUNC,
			SRA.RA_NOME,
			SRA.RA_HABILIT,
			SRA.RA_DTEMCNH,
			SRA.RA_DTVCCNH,
		    SRA.RA_ADMISSA,
			SRA.RA_NASC,
			CASE
				WHEN SRA.RA_CATCNH = '1' THEN 'A'
				WHEN SRA.RA_CATCNH = '2' THEN 'B'
				WHEN SRA.RA_CATCNH = '3' THEN 'C'
				WHEN SRA.RA_CATCNH = '4' THEN 'D'
				WHEN SRA.RA_CATCNH = '5' THEN 'E'
				WHEN SRA.RA_CATCNH = '6' THEN 'AB'
				WHEN SRA.RA_CATCNH = '7' THEN 'AC'
				WHEN SRA.RA_CATCNH = '8' THEN 'AD'
				WHEN SRA.RA_CATCNH = '9' THEN 'AE'
				ELSE ' '
			END AS RA_CATCNH,
			SRA.RA_SITFOLH,
			SRA.RA_RESCRAI,
			SRA.RA_CARGO,
			SRA.RA_USRADM,
			CASE
				WHEN ISNULL(SRA.RA_SITFOLH, '') = '' AND SRA.RA_ADMISSA > ' ' THEN 'Sit. Normal'
				WHEN SRA.RA_SITFOLH = 'A' THEN 'Afastado'
				WHEN SRA.RA_SITFOLH = 'D' THEN 'Demitido'
				WHEN SRA.RA_SITFOLH = 'F' THEN 'Férias'
				WHEN SRA.RA_SITFOLH = 'T' THEN 'Transferido'
				WHEN SRA.RA_SITFOLH = 'I' THEN 'Inativo'
				ELSE 'Outros'
			END AS RA_DESCSTA,
			CASE
				WHEN ISNULL(SRA.RA_SITFOLH, '') = '' AND SRA.RA_ADMISSA > ' ' THEN '1'ELSE '2' //1=Ativo;2=Inativo		
			END AS RA_STATUS
		From
			%Table:SRA% SRA %Exp:cJoinGYG%
		Where
			%Exp:cWhere%
			and SRA.%NotDel%
		Order By
			SRA.RA_FILIAL,
			SRA.RA_MAT,
			SRA.RA_CIC,
			SRA.RA_NOME
		EndSql

		FwLogMsg('INFO',, "GTPA008X", "GTPA008X", "", 'BuscaFuncionarios', "* cQuery - " + GetLastQuery()[2] )

		Return cAliasTmp

/*/{Protheus.doc} CargaFuncRM
(long_description)
@type function
@author Luiz Gabriel
@since 16/03/2023
@version 1.0
@param cMarca, Caracter, Indica se a integração com a RM está ativa
@param lOnlyNew, Logico, Indica se vai buscar todos os funcionarios ou só os novos
@return aRet, Array com os funcionarios a serem incluidos
@example
(CargaFuncRM("RM",.T.)
/*/
Function CargaFuncRM(cMarca,lOnlyNew)
	Local lRet 		:= .T.
	Local oXML 		:= NIL
	Local oWS 		:= {}
	Local cXML 		:= ""
	Local cError 	:= ""
	Local cCodFilRM := ""
	Local oNodeColab:= NIL
	Local cMsgErro	:= ""
	Local aColab 	:= {}
	Local cFiltro 	:= ""
	Local cWarning 	:= ""
	Local nC 		:= 0
	Local aRet		:= {}

	oWS :=  GTPItRMWS(cMarca, .F., @cMsgErro, @cCodFilRM)

	If oWS <> NIL
		cFiltro :=  Gtp008FilRM()
		oWS:cFiltro := "PFUNC.CODFILIAL = '" + AllTrim(cCodFilRM) +"'" + IIF(!Empty(cFiltro), " AND "+cFiltro, "")
		oWS:cDataServerName := "FopFuncData"
		If oWS:ReadView()
			cXML:= oWS:cReadViewResult

			If !Empty(oWS:cReadViewResult)
				oXML := XmlParser(cXML, "_", @cError, @cWarning)

				If Empty(cError)
					oNodeColab := XmlChildEx ( oXML:_NEWDATASET, "_PFUNC")
					IIf(Valtype(oNodeColab) == "O",	aAdd(aColab, oNodeColab),;
						IIf(Valtype(oNodeColab) == "A",aColab := aClone(oNodeColab),nil))
				Else
					cMsgErro := STR0019 + cError//"Problemas no xml de retorno mensagem ReadView "
					lRet := .F.
				EndIf

				GYG->(DbSetOrder(2)) //GYG_FILIAL+GYG_FUNCIO+GYG_CPF+GYG_FILSRA
				Do While lRet .AND. ( (nC := nC + 1) <= Len(aColab))
					//Verifica se o funcionário deve ser adicionado
					If !Empty(aColab[nC]:_CHAPA:TEXT) .and. !Empty(aColab[nC]:_NOME)
						cMatr := PadR(aColab[nC]:_CHAPA:TEXT, TamSX3("GYG_FUNCIO")[1])
						If !lOnlyNew
							aAdd( aRet , {cFilAnt,;
								cMatr,;
								PadR(aColab[nC]:_NOME:TEXT,TamSX3("GYG_NOME")[1]),;
								Padr(aColab[nC]:_CPF:TEXT,TamSx3('GYG_CPF')[1]),;
								sToD( StrTran( SubStr(Padr(aColab[nC]:_DTNASCIMENTO:TEXT,10), 1, 10), "-" ) ),;
								"01"})

						ElseIf !GYG->(DbSeek(xFilial('GYG')+cMatr+Padr(aColab[nC]:_CPF:TEXT,TamSx3('GYG_CPF')[1])))
							aAdd( aRet , {cFilAnt,;
								cMatr,;
								PadR(aColab[nC]:_NOME:TEXT,TamSX3("GYG_NOME")[1]),;
								Padr(aColab[nC]:_CPF:TEXT,TamSx3('GYG_CPF')[1]),;
								sToD( StrTran( SubStr(Padr(aColab[nC]:_DTNASCIMENTO:TEXT,10), 1, 10), "-" ) ),;
								"01"})
						EndIf
					Endif
				EndDo

				Iif(Valtype(oNodeColab) == "O",	FreeObj(oNodeColab),;
					Iif(Valtype(oNodeColab) == "A",	aEval(oNodeColab, { |o| FreeObj(o)}), Nil))

				FreeObj(oXML)
			Else
				cMsgErro := STR0020 + "ReadView"//"XML em branco"
				Help(,, "GTPItEmpFil",, ,1, 0)
			EndIf
		Else
			cMsgErro := STR0021  + "ReadView"//"Problemas ao consumir o método:"
		EndIf
	EndIf

	If oWS <> NIL
		FreeObj(oWS)
		oWS := NIL
	EndIf

	oWS := NIL

Return aRet

/*/{Protheus.doc} Gtp008FilRM
(long_description)
@type function
@author Luiz Gabriel
@since 16/03/2023
@version 1.0
@return cFiltro, filtro a ser incluido na busca de colaboradores
@example
Gtp008FilRM
/*/
Static Function Gtp008FilRM()
	Local cFiltro := ""
	Local cFunc1	:= Alltrim(CFGA070Ext( "RM", "SRJ", "RJ_FUNCAO", cEmpAnt + "|" + xFilial("SRJ") + "|" + MV_PAR01))
	Local cFunc2 	:= Alltrim(CFGA070Ext( "RM", "SRJ", "RJ_FUNCAO", cEmpAnt + "|" + xFilial("SRJ") + "|" + MV_PAR02))

	If !Empty(cFunc1)
		cFunc1 := Substr(cFunc1, RAT("|", cFunc1)+1)
	EndIf

	If !Empty(cFunc2)
		cFunc2 := Substr(cFunc2, RAT("|", cFunc2)+1)
	EndIf

	If !Empty(cFunc1) .AND. !Empty(cFunc2)
		cFiltro := "(PFUNC.CODFUNCAO BETWEEN '" + AllTrim(cFunc1)  + "' AND '" + AllTrim(cFunc2) + "')"
	ElseIf !Empty(cFunc1)
		cFiltro := "(PFUNC.CODFUNCAO >=  '" + AllTrim(cFunc1) + "')"
	ElseIf EMPTY(cFunc1) .And. Empty(cFunc2)
		cFiltro := "1=2"
	EndIf

Return cFiltro
/*/{Protheus.doc} AtuG6VG6W
Fynção que posiciona na tabela G6V pelo codigo da filial e coloborador filtra todos os tipos na G6W 
Verifica se o campo G6U_RELGYG e G6U_DATGYG está prenchido com o campo e data GYG a ser considerado no momento de atualizar G6W_DTINI com
o Conteudo do campo da GYG listado no campo G6U_DATGYG 


@type function
@author Cleiton Genuino da Silva
@since 14/09/2026
@version 1.0
@param nRecno, numeric, numero do registro a ser processado
@param cAliasTmp, character, alias temporario para uso no processo
@param oGTPLog, object, objeto de log para registro de mensagens
@return logical, lOk Indica se algum item foi atualizado e gravado na G6W.
/*/
Function AtuG6VG6W( nRecno as numeric, cAliasTmp as character, oGTPLog as object)
	Local aAreaG6U    := {}  as array
	Local aAreaG6V    := {}  as array
	Local aAreaGYG    := {}  as array
	Local cAliasG6V   := ""  as character
	Local cCampoDat   := ""  as character
	Local cCampoRel   := ""  as character
	Local cCodG6U     := ""  as character
	Local lOk         := .F. as logical
	Local lRet        := .T. as logical
	Local nLinha      := 0   as numeric
	Local nPosDat     := 0   as numeric
	Local nPosRel     := 0   as numeric
	Local oMdlG6V     := nil as object
	Local oMdlG6W     := nil as object
	Local oModel      := nil
	Default cAliasTmp := ''
	Default nRecno    := 0
	Default oGTPLog   := nil

	aAreaG6V  := G6V->(FwGetArea())
	aAreaG6U  := G6U->(FwGetArea())
	aAreaGYG  := GYG->(FwGetArea())
	cAliasG6V := GetNextAlias()

	If RepoRecno('GYG', nRecno ) .And. GYG->(FieldPos("GYG_CNHREG")) > 0 .And.GYG->(FieldPos("GYG_CNHEMS")) > 0 .And. GYG->(FieldPos("GYG_CNHVAL")) > 0 .And.GYG->(FieldPos("GYG_CNHCAT")) > 0

		If RecLock('GYG',.F.)
			GYG_CNHSEG := DV_CNH(AllTrim((cAliasTmp)->RA_HABILIT),.T.)
			GYG_CNHNUM := DV_CNH(AllTrim((cAliasTmp)->RA_HABILIT),.F.)
			GYG_CNHCAT := AllTrim((cAliasTmp)->RA_CATCNH)
			GYG_CNHEMS := (cAliasTmp)->RA_DTEMCNH
			GYG_CNHVAL := (cAliasTmp)->RA_DTVCCNH
			GYG->(MsUnlock())
		EndIf

		BeginSql Alias cAliasG6V
			Select G6V.R_E_C_N_O_
			From %Table:G6V% G6V
			Where G6V.G6V_FILIAL = %xFilial:G6V%
				And G6V.G6V_RECURS = %Exp:GYG->GYG_FUNCIO%
				And G6V.G6V_TRECUR = '1'
				And G6V.%NotDel%
		EndSql

	EndIf

	If (cAliasG6V)->(!Eof())

		If RepoRecno('GYG', nRecno ) .And. RepoRecno('G6V', (cAliasG6V)->R_E_C_N_O_)

			oModel := FwLoadModel('GTPA316')
			oModel:SetOperation(MODEL_OPERATION_UPDATE)

			If oModel:Activate()
				oMdlG6V := oModel:GetModel('G6VMASTER')
				lOk := oMdlG6V:SetValue('G6V_STATUS','1')

				oMdlG6W := oModel:GetModel('G6WDETAIL')

				For nLinha := 1 To oMdlG6W:Length()
					oMdlG6W:GoLine(nLinha)
					cCodG6U := oMdlG6W:GetValue('G6W_CODG6U')

					If !Empty(cCodG6U)
						G6U->(DbSetOrder(1))
						If G6U->(DbSeek(xFilial('G6U') + cCodG6U))
							cCampoRel := AllTrim(G6U->G6U_RELGYG)
							cCampoDat := AllTrim(G6U->G6U_DATGYG)

							If RepoRecno('GYG', nRecno )
								nPosRel := GYG->(FieldPos(cCampoRel))
								nPosDat := GYG->(FieldPos(cCampoDat)) //Chave Unica: GYG_FILIAL + GYG_CODIGO
							EndIf

							If !Empty(cCampoRel) .And. !Empty(cCampoDat) .And. nPosRel > 0 .And. nPosDat > 0 .And. !Empty(GYG->(FieldGet(nPosRel))) .And. !Empty(GYG->(FieldGet(nPosDat)))
								lRet := !Empty(oMdlG6W:getValue('G6W_DTINI')) .And. oMdlG6W:getValue('G6W_DTINI') < GYG->(FieldGet(nPosDat))
								If RecLock('G6W',.F.)
									G6W->G6W_DTINI := GYG->(FieldGet(nPosDat))
									G6W->(MsUnlock())
								EndIf
								If ! lRet .And. Valtype(oGTPLog) == "O"
									cMsgErro := ' Filial GYG [' + xFilial('GYG') + '] GYG_CODIGO [' + AllTrim(GYG->GYG_CODIGO) + '] CampoRel [' + cCampoRel + '] CampoDat [' + cCampoDat + ']' + ' Conteudo passado [' + dtoc(GYG->(FieldGet(nPosDat))) + ']' + ' Conteudo atual [' + dtoc(oMdlG6W:getValue('G6W_DTINI')) + ']'
									oGTPLog:SetText(cMsgErro)
									cMsgErro := 'Erro ao atualizar Filial G6U ['+ xFilial('G6U') +'] G6W_CODG6U [' + cCodG6U + '] G6W_DTINI [' + cCampoRel + '][' + cCampoDat + ']' + 'Conteudo[' + dtoc(GYG->(FieldGet(nPosDat))) + ']'
									oGTPLog:SetText(cMsgErro)
								EndIf
								lOk := lOk .Or. lRet
							EndIf
						EndIf
					EndIf
				Next nLinha

				If lOk .And. lRet .And. oModel:VldData() .And. oModel:CommitData()
					lOk := .T.
				ElseIf lOk
					lOk := .F.
				EndIf

				oModel:DeActivate()
			EndIf

			oModel:Destroy()

		EndIf

	EndIf

	(cAliasG6V)->(DbCloseArea())
	FwRestArea(aAreaG6V)
	FwRestArea(aAreaG6U)
	FwRestArea(aAreaGYG)

Return lOk
/*/{Protheus.doc} DV_CNH
Geração de dígito verificador de CNH
Recebe o número da CNH em String, com 9 dígitos 
Calcula os dois dígitos verificadores


@type function STATIC
@author Cleiton Genuino da Silva
@since 14/09/2026
@version 1.0
@param cCNH, character, número da CNH com 9 dígitos
@param lConDv, logical, indica se deve retornar a CNH com os dígitos verificadores.
@return character, dígito verificador da CNH.
/*/
STATIC Function DV_CNH( cCNH as character , lConDv as logical) as character
	Local lMaior   := .F. as logical
	Local nDV1     := 0   as numeric
	Local nDV2     := 0   as numeric
	Local nI       := 0   as numeric
	Local nM1      := 9   as numeric
	Local nM2      := 1   as numeric
	Local nVL      := 0   as numeric
	Default cCNH   := ''
	Default lConDv := .F.

	// Calculo dos valores dos dígitos baseado no fator multiplicativo de acordo com a posição de cada dígito.
	If !Empty(cCNH)

		cCNH := AllTrim(cCNH)
		cCNH := Left(cCNH, 9) // Quero pegar os 9 primeiros digitos

		For nI := 1 to 9
			nVL := val( substr(cCNH,nI,1) )
			nDV1 += (  nVL * nM1 )
			nDV2 += (  nVL * nM2 )
			nM1--
			nM2++
			nVA := nVL
		Next

		// Determina o primeiro dígito verificador
		nDV1 := nDV1 % 11
		If nDV1 > 9
			nDV1 := 0
			lMaior := .T.
		Endif

		// Determina o segundo dígito verificador
		nDV2 := nDV2 % 11
		If lMaior
			// Regra diferenciada para caso o módulo 11
			// do primeiro dígito verificador seja maior que 9
			If nDV2 - 2 < 0
				nDV2 += 9
			ElseIf nDV2 - 2 >= 0
				nDV2 -= 2
			Endif
		Endif

		// Ajuste final
		IF nDV2 > 9
			nDV2 := 0
		Endif

		// Retorna os dígitos calculados como string
		IF lConDv
			cCNH += chr(48+nDV1) + chr(48+nDV2)
		EndIf

	Endif

Return cCNH
/*/{Protheus.doc} RepoRecno
	Reposiciona no renco de trabalho da tabela atual
	@type function
	@author Cleiton Genuino da Silva
	@since 14/09/2026
	@version 1.0
	@param cTabela, character, nome da tabela.
	@param nRecno, numeric, número do registro a ser reposicionado.
	@return logical, indica se a reposição foi bem-sucedida.
/*/
Function RepoRecno( cTabela as character , nRecno as numeric) as logical
	Local lPosicina := .F. as logical
	Default cTabela := ''
	Default nRecno := 0

	// Calculo dos valores dos dígitos baseado no fator multiplicativo de acordo com a posição de cada dígito.
	If !Empty(cTabela) .And. nRecno > 0
		(cTabela)->(DbGoTo(nRecno))
		lPosicina := (cTabela)->(!Eof()) .And. (cTabela)->(recno()) == nRecno
	Endif

Return lPosicina
/*/{Protheus.doc} SchedDef
	Uso - Execucao da rotina via Schedule.

	Permite usar o botao Parametros da nova rotina de Schedule
	para definir os parametros(SX1) que serao passados a rotina agendada.
	@type function
	@author Cleiton Genuino da Silva
	@since 14/09/2026
	@version 1.0
	@return  array , aParam parametros para execução da rotina via scheduler
/*/

Static Function SchedDef(aEmp as array ) as array
	Local aParam := {} as array
	Default aEmp := {}

	aParam :=	{"P"		,;	//Tipo R para relatorio P para processo
	"GTPA008I"	,;	//Nome do grupo de perguntas (SX1)
	Nil			,;	//cAlias (para Relatorio)
	Nil			,;	//aArray (para Relatorio)
	Nil			,;	//Titulo (para Relatorio)
	Nil			,;	//Nome do Relatório
	.F.			,;	//Indica se permite que o agendamento possa ser cadastrado como sempre ativo
	.F.			}	//Indica que o agendamento pode ser realizado por filiais

Return aParam
