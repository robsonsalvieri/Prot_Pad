#INCLUDE "PROTHEUS.CH"
#INCLUDE "PARMTYPE.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "JURA312.CH"

//-------------------------------------------------------------------
/*/{Protheus.doc} JURA312
Contem as informacoes E-Social.

@since 12/06/2023
/*/
//-------------------------------------------------------------------
Function JURA312()

Local lRet         := .T.
Local lFound 	   := FwSX2Util():SeekX2File( "V9U" )
Local lPerg		   := JurvldSx1("JURA312")
Private cTipoAsJ   := ""
Private c162TipoAs := ""

	If lFound .and. lPerg
		JEsocial()
	Else
		JurMsgError(STR0007,,; //'Para correto funcionamento desta configuração, deverá possuir a tabela V9U no dicionário de dados.'
 			+STR0008+Chr(13)+Chr(10);//"Para mais informações, acesse o link da nossa documentação:"
			+ "https://tdn.totvs.com/pages/viewpage.action?pageId=776528455")
		lRet := .F.
	Endif

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} JEsocial
Chama o modelo MVC de acordo com o layout selecionado

@since 12/06/2023
/*/
//-------------------------------------------------------------------
Function JEsocial()
Local oGrid := Nil

	oGrid := FWGridProcess():New("TAFA608","E-Social",STR0001,{|| JLayout()},"JURA312") // Selecione o layout
	oGrid:Activate()

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} JLayout
Chama o modelo MVC de acordo com o layout selecionado

@since 12/06/2023
/*/
//-------------------------------------------------------------------
Function JLayout()
Local oModel608   := Nil
Local oMdl608V9V  := Nil
Local oModel100   := Nil
Local cAlias      := GetNextAlias()
Local cAliasC9V   := GetNextAlias()
Local cCajuri     := AllTrim(MV_PAR01)
Local cQuery      := ""
Local cID         := ""
Local cNumpro     := ""
Local cVara       := ""
Local cCGC        := ""
Local cNome       := ""
Local cXml        := ""
Local cEntdedEnv  := ""
Local cCodEnt     := ""
Local cMatricEnv  := ""
Local cOperacao   := STR0002 // Inclusão
Local cTitAnda    := STR0004 // Cadastro do Andamento
Local dDTNasc     := SToD("")
Local nOpc        := 3
Local lRet        := .T.
Local lTafOutSist := SuperGetMV('MV_JTAFOUT',, .F.) // O TAF e Juri estão config em ambiente diferente?
Local cCodAto     := SuperGetMV('MV_J2500AT',, .F.) // Parâmetro que abriga o Ato Processual
Local nV9VAdd     := 0

	cNumpro := JurGetDados('NUQ', 2, xFilial('NUQ') + cCajuri + '1', 'NUQ_NUMPRO')  // NUQ_FILIAL + NUQ_CAJURI + NUQ_INSATU
	cID     := JurGetDados('V9U', 7, xFilial('V9U') + Padr(cNumpro,TamSx3("V9U_NRPROC")[1]) + '1', 'V9U_ID') // V9U_FILIAL + V9U_NRPROC + V9U_ATIVO

	If !Empty(cID)
		nOpc := 4
		INCLUI := .F.
		ALTERA := .T.
		cOperacao := STR0003 // Alteração
	Else
		ALTERA := .F.
	EndIf

	cQuery += " SELECT NUQ_NUMPRO,"
	cQuery +=        " NUQ_CLOC3N,"
	cQuery +=        " NUQ_CCOMAR,"
	cQuery +=        " NUQ_ESTADO,"
	cQuery +=        " NT9_CGC,"
	cQuery +=        " NT9_NOME,"
	cQuery +=        " NT9_DTNASC,"
	cQuery +=        " NT9_ENTIDA,"
	cQuery +=        " NT9_CODENT"
	cQuery += " FROM " + RetSqlName("NSZ") + " NSZ"
	cQuery +=     " INNER JOIN " + RetSqlName("NUQ") + " NUQ"
	cQuery +=         " ON NUQ.NUQ_FILIAL = NSZ.NSZ_FILIAL"
	cQuery +=             " AND NSZ.NSZ_COD = NUQ.NUQ_CAJURI"
	cQuery +=             " AND NSZ.D_E_L_E_T_ = ' '"
	cQuery +=             " AND NUQ.NUQ_INSATU  = '1'"    // Instância origem
	cQuery +=             " AND NUQ.D_E_L_E_T_ = ' '"
	cQuery +=     " INNER JOIN " + RetSqlName("NT9") + " NT9"
	cQuery +=         " ON NT9.NT9_FILIAL = NSZ.NSZ_FILIAL"
	cQuery +=             " AND NT9.NT9_CAJURI = NSZ.NSZ_COD"
	cQuery +=             " AND NT9.NT9_PRINCI = '1'"  // Principal? 1=Sim
	cQuery +=             " AND NT9.NT9_TIPOEN = '1'"  // Tipo envolvimento? 1=Polo Ativo
	cQuery +=             " AND NT9.D_E_L_E_T_ = ' '"
	cQuery += " WHERE NUQ.NUQ_NUMPRO = ?" 

	dbUseArea( .T., 'TOPCONN', TCGenQry2(NIL,NIL,cQuery,{cNumpro}), cAlias, .T., .F. )

	If (cAlias)->(!EoF())
		cVara      := Alltrim((cAlias)->NUQ_CCOMAR)
		cCGC       := Alltrim((cAlias)->NT9_CGC)
		cNome      := Alltrim((cAlias)->NT9_NOME)
		dDTNasc    := Alltrim((cAlias)->NT9_DTNASC)
		cEntdedEnv := Alltrim((cAlias)->NT9_ENTIDA)
		cCodEnt    := Alltrim((cAlias)->NT9_CODENT)
		
		oModel608 := FWLoadModel("TAFA608")
		oModel608:SetOperation(nOpc)
		oModel608:Activate()

		If nOpc == 3
			oModel608:SetValue("MODEL_V9U", "V9U_ID", GetSx8Num("V9U","V9U_ID"))
			oModel608:SetValue("MODEL_V9U", "V9U_NRPROC", Padr(cNumpro,TamSx3("V9U_NRPROC")[1]))
			oModel608:SetValue("MODEL_V9U", "V9U_IDVARA", cVara)
			oModel608:SetValue("MODEL_V9U", "V9U_CPFTRA", cCGC )
			oModel608:SetValue("MODEL_V9U", "V9U_NMTRAB", cNome)
			oModel608:SetValue("MODEL_V9U", "V9U_DTNASC", STOD(dDTNasc))

			If cEntdedEnv == "SRA"

				// Carrega matrícula do Trabalhador
				cMatricEnv := Right(cCodEnt,TamSx3("RA_MAT")[1])
				oModel608:SetValue('MODEL_V9W','V9W_MATRIC', cMatricEnv)
				
				// Carrega os dependentes
				cQryC9V := " SELECT C9V_ID,"
				cQryC9V +=        " C9V_VERSAO,"
				cQryC9V +=        " C9V_NOMEVE,"
				cQryC9V +=        " C9V_CATCI,"
				cQryC9V +=        " C9V_DTINIV"
				cQryC9V +=   " FROM " + RetSqlName("C9V") + " C9V"
				cQryC9V +=  " WHERE C9V_CPF = ?"
				cQryC9V +=    " AND D_E_L_E_T_ = ' '"

				cQryC9V := ChangeQuery(cQryC9V)
				dbUseArea(.T.,"TOPCONN",TcGenQry2(,,cQryC9V,{cCGC}),cAliasC9V,.T.,.T.)

				C9Y->(DbSetOrder(1))
				T2F->(DbSetOrder(2))
				If C9Y->(DbSeek(xFilial("C9Y") + (cAliasC9V)->(C9V_ID + C9V_VERSAO)))
					oMdl608V9V := oModel608:GetModel( 'MODEL_V9V' )

					If (oMdl608V9V != Nil)
						nV9VAdd := oMdl608V9V:Length()

						While C9Y->(!Eof()) .And. (Alltrim(xFilial("C9Y") + C9Y->(C9Y_ID + C9Y_VERSAO))) == (Alltrim(xFilial("C9V") + (cAliasC9V)->(C9V_ID + C9V_VERSAO))) 
							
							If nV9VAdd > 1
								oModel608:GetModel("MODEL_V9V"):AddLine()
							EndIf

							oModel608:SetValue('MODEL_V9V','V9V_TPDEP' ,C9Y->C9Y_TPDEP)
							oModel608:SetValue('MODEL_V9V','V9V_CPFDEP',C9Y->C9Y_CPFDEP)

							C9Y->(DbSkip())
							nV9VAdd++
						EndDo
					EndIf
				ElseIf T2F->(DbSeek(xFilial("T2F") + (cAliasC9V)->(C9V_ID + C9V_VERSAO)))
					oMdl608V9V := oModel608:GetModel( 'MODEL_V9V' )

					If (oMdl608V9V != Nil)
						nV9VAdd := oMdl608V9V:Length()

						While T2F->(!Eof()) .And. (Alltrim(xFilial("T2F") + T2F->(T2F_ID + T2F_VERSAO))) == (Alltrim(xFilial("C9V") + (cAliasC9V)->(C9V_ID + C9V_VERSAO))) 
							
							If nV9VAdd > 1
								oModel608:GetModel("MODEL_V9V"):AddLine()
							EndIf

							oModel608:SetValue('MODEL_V9V','V9V_TPDEP' ,T2F->T2F_TPDEP)
							oModel608:SetValue('MODEL_V9V','V9V_CPFDEP',T2F->T2F_CPFDEP)

							T2F->(DbSkip())
							nV9VAdd++
						EndDo
					EndIf
				EndIf

				// Carrega Informações do contrato, complementares do contrato e remuneração
				If (cAliasC9V)->C9V_NOMEVE == "S2200"
					CUP->(DbSetOrder(1))
					If CUP->(DbSeek(xFilial("CUP") + (cAliasC9V)->(C9V_ID + C9V_VERSAO)))

						oModel608:SetValue('MODEL_V9W','V9W_CODCAT', CUP->(CUP_CODCAT))
						oModel608:SetValue('MODEL_V9X','V9X_CODCBO', CUP->(CUP_CBOCAR))
						oModel608:SetValue('MODEL_V9X','V9X_NATATV', CUP->(CUP_NATATV))
						oModel608:SetValue('MODEL_V9X','V9X_TPREGT', CUP->(CUP_TPREGT))
						oModel608:SetValue('MODEL_V9X','V9X_TPREGP', CUP->(CUP_TPREGP))
						oModel608:SetValue('MODEL_V9X','V9X_TMPPAR', CUP->(CUP_TMPARC))
						oModel608:SetValue('MODEL_V9X','V9X_TPCDUR', CUP->(CUP_TPCONT))
						oModel608:SetValue('MODEL_V9X','V9X_DTADM' , CUP->(CUP_DTADMI))
						oModel608:SetValue('MODEL_V9X','V9X_DTFIM' , CUP->(CUP_DTTERM))
						oModel608:SetValue('MODEL_V9Y','V9Y_UNDSAL', CUP->(CUP_UNSLFX))
						oModel608:SetValue('MODEL_V9Y','V9Y_VRSAL' , CUP->(CUP_VLSLFX))
						oModel608:SetValue('MODEL_V9Y','V9Y_DSCSAL', CUP->(CUP_DSCSAL))

					EndIf
				ElseIf (cAliasC9V)->C9V_NOMEVE == "S2300"
					CUU->(DbSetOrder(1))
					If CUU->(DbSeek(xFilial("CUU") + (cAliasC9V)->(C9V_ID + C9V_VERSAO)))

						oModel608:SetValue('MODEL_V9W','V9W_CODCAT', (cAliasC9V)->(C9V_CATCI))
						oModel608:SetValue('MODEL_V9W','V9W_DTINIC', (cAliasC9V)->(C9V_DTINIV))
						oModel608:SetValue('MODEL_V9X','V9X_CODCBO', CUU->(CUU_CBOCAR))
						oModel608:SetValue('MODEL_V9X','V9X_NATATV', CUU->(CUU_NATATV))
						oModel608:SetValue('MODEL_V9X','V9X_TPREGT', CUU->(CUU_TPREGT))
						oModel608:SetValue('MODEL_V9X','V9X_TPREGP', CUU->(CUU_TPREGP))
						oModel608:SetValue('MODEL_V9X','V9X_DTFIM' , CUU->(CUU_DTTERM))
						oModel608:SetValue('MODEL_V9Y','V9Y_UNDSAL', CUU->(CUU_UNSLCI))
						oModel608:SetValue('MODEL_V9Y','V9Y_VRSAL' , CUU->(CUU_VLSLCI))
						oModel608:SetValue('MODEL_V9Y','V9Y_DSCSAL', CUU->(CUU_DSCSAL))
					
					EndIf
				EndIf

				(cAliasC9V)->(DbCloseArea())
			EndIf
		EndIf
		
		lRet := (FWExecView("S-2500 - " + cOperacao,"TAFA608",nOpc, , {||lRet := .T., lRet}, , , , , , ,oModel608 ) == 0)

		If lRet
			// Gera arquivo XML na pasta local
			DbSelectArea("V9U")
			DbSetOrder(7)  //V9U_FILIAL + V9U_NRPROC + V9U_ATIVO

			If Dbseek( xFilial('V9U') + Padr(cNumpro,TamSx3("V9U_NRPROC")[1]) + '1' )
				/*
					Para utilizar com o TJD necessário passar o 4º parametro (lJob) como .T., 
					para não abrir a janela pro usuario escolher o caminho onde irá salvar o arquivo
				*/
				cXml := TAF608Xml(,,,lTafOutSist)
			Else
				Jurconout(STR0005) // Registro não encontrado!
			EndIf

			If !Empty(cXml) 
				oModel100 := FWLoadModel("JURA100")
				oModel100:SetOperation(MODEL_OPERATION_INSERT)
				oModel100:Activate()

				oModel100:SetValue("NT4MASTER", "NT4_CAJURI", cCajuri)
				oModel100:SetValue("NT4MASTER", "NT4_CATO", cCodAto)

				lRet := (FWExecView(cTitAnda,"JURA100",MODEL_OPERATION_INSERT, , , , , , , , ,oModel100 ) == 0)
		
			Endif
		Endif 
	EndIf

	(cAlias)->(DbCloseArea())
	
Return .T.
