#Include 'Protheus.ch'
#INCLUDE 'FWMVCDEF.CH' 
#INCLUDE 'GTPA008X.CH' 

Function GTPA008X(lJob)
Local cAliasTmp	:= Nil
Local lRet		:= .T.
Local aAreaGYG	:= GYG->( GetArea() )

Local oMdl008	:= FwLoadModel('GTPA008')
Local oMdlGYG	:= oMdl008:GetModel('GYGMASTER')
Local oStrGYG	:= oMdlGYG:GetStruct()
Local nOpc		:= 0

Local oGTPLog	:= GTPLog():New(STR0001,lJob/*lSalva*/,!lJob/*lShow*/)//"Integracao Colaborador RH"
Local cFilOld	:= cFilAnt

Local cFilSRA	:= ""
Local cMatric	:= ""
Local cCPF		:= ""
Local cNome		:= ""

Local nImpOk	:= 0
Local nImpErro	:= 0

Local cMarca 	:= IIF(SuperGetMV("MV_GSXINT",,"2") == "3", "RM", "")
Local aColab 	:= {}
Local nX		:= 0
Local dDtNasc	:= CTOD("")
Local lOnlyNew 	:= .T.

Default lJob	:= Iif(Select("SX6")==0,.T.,.F.)

oStrGYG:SetProperty('*', MODEL_FIELD_WHEN, {||.T.})

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
	If Pergunte('GTPA008I',!lJob)
		cAliasTmp := BuscaFuncionarios(lJob)
		
		oGTPLog:SetText(STR0002             )//'Iniciado processo de importação'
		oGTPLog:SetText("")
		oGTPLog:SetText(STR0003             )//"Dados utilizados para busca:"
		oGTPLog:SetText(STR0004 + MV_PAR01  )//"Cargo de:"
		oGTPLog:SetText(STR0005 + MV_PAR02  )//"Cargo até:"
		oGTPLog:SetText(STR0006 + MV_PAR03  )//"Função de:"
		oGTPLog:SetText(STR0007 + MV_PAR04  )//"Função até:"
		oGTPLog:SetText(STR0008 + IF(MV_PAR05==1, STR0009,STR0010) )//"Filtrar Matriculas sem Colaborador:"##"Sim"##"Não"
		oGTPLog:SetText("")

		GYG->(DbSetOrder(2)) //GYG_FILIAL+GYG_FUNCIO+GYG_CPF+GYG_FILSRA
		While (cAliasTmp)->(!EoF())
			cFilSRA	:= (cAliasTmp)->RA_FILIAL
			cMatric	:= (cAliasTmp)->RA_MAT
			cCPF	:= (cAliasTmp)->RA_CIC
			cNome	:= AllTrim((cAliasTmp)->RA_NOME)
			
			cFilAnt := cFilSRA 
			
			If !GYG->(DbSeek(xFilial('GYG')+cMatric+Padr(cCPF,TamSx3('GYG_CPF')[1])))
				nOpc	:= MODEL_OPERATION_INSERT
				lRet	:= .T.
			ElseIf GYG->GYG_FILSRA <> cFilSRA
				nOpc	:= MODEL_OPERATION_UPDATE
				lRet	:= .T.
			Else
				lRet	:= .F.
			Endif
			
			If lRet
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
			Else
				oGTPLog:SetText(I18n(STR0013,{cFilSRA,cMatric,cNome}))//'Colaborador filial: #1, matricula #2, nome: #3 já cadastrado, sem necessidade de mudanças'
			Endif
			(cAliasTmp)->(DbSkip())
		End
		
		oGTPLog:SetText(STR0015                             )//"Finalizado processo de importação"
		oGTPLog:SetText(STR0016+ cValToChar(nImpOk+nImpErro))//"Total de Funcionários importados/alterados: "
		oGTPLog:SetText(STR0017+ cValToChar(nImpOk)         )//"Importações com Sucesso: "
		oGTPLog:SetText(STR0018+ cValToChar(nImpErro)       )//"Importações com Erro: "
		
		
		oGTPLog:ShowLog()
		oGTPLog:Destroy()
	Endif

EndIf 

oMdl008:Destroy()

cFilAnt := cFilOld 

RestArea( aAreaGYG )
	
GTPDestroy(oMdl008)
GTPDestroy(aAreaGYG)
GTPDestroy(oGTPLog)

Return

/*/{Protheus.doc} BuscaFuncionarios
(long_description)
@type function
@author jacomo.fernandes
@since 11/02/2019
@version 1.0
@param lJob, ${param_type}, (Descrição do parâmetro)
@return ${return}, ${return_description}
@example
(examples)
@see (links_or_references)
/*/
Static Function BuscaFuncionarios(lJob)
Local cAliasTmp	:= GetNextAlias()

Local cJoinGYG	:= "%%"
Local cQryFunc	:= ""
Local cQryCarg	:= ""
Local cWhere	:= ""

Local lOnlyNew	:= .T.

If lJob
	cQryCarg :=	" AND SRA.RA_CARGO IN "+FormatIn(GTPGetRules("LISTACARGO",.F.),";") + " "
	cQryFunc := " AND SRA.RA_CODFUNC IN "+ FormatIn(GTPGetRules("LISTAFUNCA",.F.),";") + " "
Else
	cQryCarg :=	" AND SRA.RA_CARGO BETWEEN '" + MV_PAR01 + "' AND '" + MV_PAR02 + "' "
	cQryFunc := " AND SRA.RA_CODFUNC BETWEEN '" + MV_PAR03 + "' AND '" + MV_PAR04 + "' "
	lOnlyNew := MV_PAR05 == 1
Endif

cWhere += cQryCarg
cWhere += cQryFunc

If lOnlyNew
	cJoinGYG := "%"
	cJoinGYG += " Left Join "+RetSqlName("GYG")+" GYG ON "
	cJoinGYG += 	" GYG.GYG_FILSRA = SRA.RA_FILIAL "
	cJoinGYG += 	" AND GYG.GYG_FUNCIO = SRA.RA_MAT "
	cJoinGYG += 	" AND GYG.D_E_L_E_T_ = ' ' "
	cJoinGYG += "%"
	cWhere	+= " AND GYG.GYG_CODIGO IS NULL "
Endif

cWhere := '%'+cWhere+'%'

BeginSql Alias cAliasTmp
	
	Select 
		SRA.RA_FILIAL,
		SRA.RA_MAT,
		SRA.RA_CIC,
		SRA.RA_NOME
	From %Table:SRA% SRA
		%Exp:cJoinGYG%
	Where
		SRA.RA_FILIAL LIKE %Exp:AllTrim(xFilial('SRA'))% || '%'
		AND SRA.RA_SITFOLH NOT IN ('D','T')
		%Exp:cWhere%
		and SRA.%NotDel%
	Order By
		SRA.RA_FILIAL,
		SRA.RA_MAT,
		SRA.RA_CIC,
		SRA.RA_NOME
EndSql

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
