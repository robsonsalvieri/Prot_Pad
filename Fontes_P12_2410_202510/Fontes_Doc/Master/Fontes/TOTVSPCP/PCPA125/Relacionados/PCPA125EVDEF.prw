#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "PCPA125.CH"

#DEFINE CAMPOS_DESCRICAO "|D3_CODDSC|H6_PROEDSC|CYV_CDACSC|C2_PRODESC|"
#DEFINE CAMPOS_VISIVEIS_OP "|C2_PRODUTO|C2_QUANT|C2_DATPRI|C2_DATPRF|"
Static _lLoadData := .F.

/*/{Protheus.doc} PCPA125EVDEF
//EVENTOS PCPA125
@author Thiago Zoppi
@since 12/05/2018
/*/
CLASS PCPA125EVDEF FROM FWModelEvent
	METHOD New() CONSTRUCTOR

	METHOD BeforeTTS(oModel, cModelId)
	METHOD FieldPreVld(oSubModel, cModelID, cAction, cId, xValue)
	METHOD InTTS(oModel, cModelId)
	METHOD ModelPosVld(oModel, cModelId)
	METHOD GridLinePosVld(oSubModel, cModelID, nLine)

ENDCLASS

METHOD New() CLASS  PCPA125EVDEF
Return

/*/{Protheus.doc} BeforeTTS
Método que é chamado pelo MVC quando ocorrer as ações do commit antes da transação.

@type  METHOD
@author lucas.franca
@since 02/03/2021
@version P12
@param oModel  , Object   , Referência do modelo de dados
@param cModelId, Character, ID do submodelo.
@return Nil
/*/
METHOD BeforeTTS(oModel, cModelId) CLASS PCPA125EVDEF
	Local cIdForm    := ""
	Local cVisual    := ""
	Local cInclui    := ""
	Local cAltera    := ""
	Local cExclui    := ""
	Local cPrgApo    := oModel:GetModel("OXMASTER"):GetValue("OX_PRGAPON")
	Local nIndex     := 0
	Local nTotal     := 0
	Local oMdlSMJ    := Nil
	Local oMdlPermis := Nil

	If cPrgApo $ "|1|3|4|" .And. oModel:GetOperation() != MODEL_OPERATION_DELETE
		//Atualiza as informações de permissões do modelo DETAIL_SMJ, com as informações existentes no modelo SMJ_PERMISSAO
		cIdForm    := oModel:GetModel("OXMASTER"):GetValue("OX_FORM")
		oMdlSMJ    := oModel:GetModel("DETAIL_SMJ")
		oMdlPermis := oModel:GetModel("SMJ_PERMISSAO")

		cVisual    := oMdlPermis:GetValue("MJ_VISUAL")
		cInclui    := oMdlPermis:GetValue("MJ_INCLUI")
		cAltera    := oMdlPermis:GetValue("MJ_ALTERA")
		cExclui    := oMdlPermis:GetValue("MJ_EXCLUI")

		nTotal := oMdlSMJ:Length()
		For nIndex := 1 To nTotal
			oMdlSMJ:GoLine(nIndex)
			oMdlSMJ:SetValue("MJ_CODFORM", cIdForm)
			oMdlSMJ:SetValue("MJ_VISUAL" , cVisual)
			oMdlSMJ:SetValue("MJ_INCLUI" , cInclui)
			oMdlSMJ:SetValue("MJ_ALTERA" , cAltera)
			oMdlSMJ:SetValue("MJ_EXCLUI" , cExclui)
		Next nIndex
	EndIf
Return Nil

/*/{Protheus.doc} INSERTHZT
Insere os registros de parâmetros do formulário na tabela HZT
@type Static Function
@author juliana.oliveira
@since 07/08/2025
@version P12
@param  cCodForm, caracter, Código do formulário
@param  cParam  , caracter, Parâmetro
@param  cValor  , caracter, Valor do parâmetro
@return Nil
/*/
Static Function INSERTHZT(cCodForm,cParam,cValor)

	dbSelectArea("HZT")
	dbSetOrder(1)
	dbSeek(xFilial("HZT")+cCodForm+cParam)
	If HZT->(!EoF()) 
		If Alltrim(HZT->HZT_VALOR) != cValor
			RecLock("HZT",.F.)
			HZT->HZT_VALOR   := cValor
			HZT->(MsUnLock())
		EndiF
	Else 
		RecLock('HZT',.T.)
			HZT->HZT_FILIAL  := xFilial("HZT")
			HZT->HZT_FORM    := cCodForm
			HZT->HZT_PARAM   := cParam
			HZT->HZT_VALOR   := cValor
			HZT->HZT_LISTA   := ""
		HZT->(MsUnlock())
	EndIf	
Return

/*/{Protheus.doc} A125TipoParam
Trata dos tipos de parâmetros
@type Static Function
@author juliana.oliveira
@since 07/08/2025
@version P12
@param  xValor, any, valor do parâmetro
@return cReturn, caracter, Valor do parametro convertido para string.
/*/
Static Function A125TipoParam(xValor)
	Local cTipo     := ""
	Local cValorHZT := ""

	cTipo := ValType(xValor)

	If cTipo == "C"
		cValorHZT := xValor
		cReturn   := cValorHZT
/*	ElseIf cTipo == "N"
		cValorHZT := cValToChar(xValor)
		cReturn   := cValorHZT*/
	ElseIf cTipo == "L" .And. xValor
		cValorHZT := "true"
		cReturn   := cValorHZT
	ElseIf cTipo == "L" .And. !xValor
		cValorHZT := "false"
		cReturn   := cValorHZT
	EndIf
	
Return cReturn

/*/{Protheus.doc} FieldPreVld
Método que é chamado pelo MVC quando ocorrer a ação de pré validação do Field

@author tp.thiago.zoppi
@since 15/05/2018
@version 1.0
/*/
METHOD FieldPreVld(oSubModel, cModelID, cAction, cId, xValue) CLASS PCPA125EVDEF
	Local aCampSOY	 := {}
	Local aCamposADD := {}
	Local cDescFld   := ""
	Local cVisivel   := ""
	Local cEdita     := ""
	Local lRet       := .T.
	Local nIndice	 := 0
	Local nLinha	 := 1
	Local nTamHeader := 0
	Local oModel	 := FWModelActive()
	Local oModelSOY	 := oModel:GetModel("DETAIL_SOY")

	If cAction == "SETVALUE" .And. cId == "OX_PRGAPON"
		If xValue $ "|2|5|"
			lRet := .F.
			Return lRet
		EndIf
		cargaSMC(oModel, xValue)

		oModelSOY:SetNoInsertLine(.F.)
		oModelSOY:SetNoDeletetLine(.F.)

		If oModelSOY:Length() > 1
			//Apaga todas a linhas da grid
			For nIndice := 1 to oModelSOY:Length()
				oModelSOY:GoLine(nIndice)
				oModelSOY:DeleteLine(.T.,.T.)
			Next nIndice

			//LIMPAR LINHAS DELETADAS, NAO DEIXANDO LINHAS CINZAS NA GRID
			nTamHeader	:= Len(oModelSOY:aHeader)
			oModelSOY:GoLine(1)
			ASIZE(oModelSOY:aDataModel, 1)
			ASIZE(oModelSOY:aCols, 1)

			For nIndice := 1 To nTamHeader
				oModel:ClearField('DETAIL_SOY' , oModelSOY:aHeader[nIndice][2])
			Next nIndice

			//AddLine Força um refresh no grid, os aSizes removem a nova linha em branco.
			oModelSOY:AddLine()
			ASIZE(oModelSOY:aDataModel, 1)
			ASIZE(oModelSOY:aCols, 1)

			oModelSOY:GoLine(1)
			oModelSOY:UnDeleteLine() // sempre fica uma linha deletada na grid, entao retiramos o delete;
		EndIf

		If xValue $ "|1|3|4|6|7|"
			A125CMPPAD(xValue,@aCamposADD)
		ElseIf xValue == "2" //CAMPOS DA ROTINA MATA680
			aCamposADD := {"H6_OP"     , "H6_PRODUTO", "H6_OPERAC" , "H6_RECURSO", "H6_FERRAM" ,;
						   "H6_DATAINI", "H6_HORAINI", "H6_DATAFIN", "H6_HORAFIN", "H6_QTDPROD",;
						   "H6_QTDPERD", "H6_PT"     , "H6_DTAPONT", "H6_DESDOBR", "H6_TEMPO"  ,;
						   "H6_LOTECTL", "H6_NUMLOTE", "H6_DTVALID", "H6_OPERADO", "H6_SEQ"    ,;
						   "H6_QTDPRO2", "H6_POTENCI", "H6_RATEIO" , "H6_LOCAL"}
		ElseIf xValue == "5" //CAMPOS DA ROTINA MATA250 SEM O CAMPO D3_OP
			aCamposADD := {"D3_TM"     , "D3_COD"    , "D3_UM"     , "D3_QUANT"  , "D3_CONTA",;
						   "D3_LOCAL"  , "D3_DOC"    , "D3_EMISSAO", "D3_CC"     , "D3_PARCTOT",;
						   "D3_SEGUM"  , "D3_QTSEGUM", "D3_PERDA"  , "D3_LOTECTL", "D3_DTVALID",;
						   "D3_POTENCI",IIF(IntWms(),"D3_SERVIC",'')}
		EndIf

		For nIndice := 1 to Len(aCamposADD)
			If !Empty(aCamposADD[nIndice])
				If "|" + aCamposADD[nIndice] + "|" $ CAMPOS_DESCRICAO
					cDescFld := STR0034 //"Descrição do produto"
				Else
					cDescFld := FWSX3Util():GetDescription(aCamposADD[nIndice])
				EndIf
				Aadd(aCampSOY,{aCamposADD[nIndice], cDescFld})
			EndIf
		Next

		//Variável de controle para não executar validações de WHEN da SOY.
		_lLoadData := .T.
		For nIndice := 1 To Len(aCampSOY)
			If !Empty(oModelSOY:GetValue("OY_CAMPO"))
				oModelSOY:AddLine()
			EndIf

			If "|" + aCampSOY[nIndice][1] + "|" $ CAMPOS_DESCRICAO
				cEdita   := "2"
				If xValue == "4"
					cVisivel := "1"
				Else
					cVisivel := "2"
				EndIf
			Else
				cEdita   := "1"
				cVisivel := "1"
			EndIf

			If xValue == "6"
				If !(aCampSOY[nIndice][1] $ CAMPOS_VISIVEIS_OP)
					cVisivel := "2"
				EndIf
			EndIf

			oModelSOY:SetValue("OY_CAMPO"  , aCampSOY[nIndice][1])
			oModelSOY:SetValue("OY_DESCAMP", aCampSOY[nIndice][2])
			oModelSOY:SetValue("OY_CODBAR" , "2")
			oModelSOY:SetValue("OY_VISIVEL", cVisivel)
			oModelSOY:SetValue("OY_EDITA"  , cEdita)
			oModelSOY:SetValue("OY_VALPAD" , "")
			If oModelSOY:HasField("OY_POSIC")
				oModelSOY:SetValue("OY_POSIC", nIndice * 10)
			EndIf
		Next nIndice
		_lLoadData := .F.

		If oModelSOY:Length() > 0
			oModelSOY:goLine(nLinha)
		EndIf

		If xValue $ "|1|3|4|"
			cargaSMJ(oModel)
		EndIf

		oModelSOY:SetNoDeletetLine(.T.) //Bloqueia exclusao de linhas
		oModelSOY:SetNoInsertLine(.T.) //Bloqueia inclusão de linhas
	EndIf

Return lRet

/*/{Protheus.doc} InTTS
Método que é chamado pelo MVC quando ocorrer as ações do commit Após as gravações porém
antes do final da transação.

@type  METHOD
@author lucas.franca
@since 02/03/2021
@version P12
@param oModel  , Object   , Referência do modelo de dados
@param cModelId, Character, ID do submodelo.
@return Nil
/*/
METHOD InTTS(oModel, cModelId) CLASS PCPA125EVDEF
	Local aCamposHZT := {}
	Local cCdMq      := ""
	Local cFormular  := ""
	Local cIdForm    := ""
	Local cPrgApon   := oModel:GetModel("OXMASTER"):GetValue("OX_PRGAPON")
	Local nOperation := oModel:GetOperation()
	Local nIndHWS    := 0
	Local nIndHZT    := 0
	Local oHWS       := Nil
	Local oHZT       := Nil
	Local xValor     := Nil

	If cPrgApon == "4"
		cFormular := oModel:GetModel("OXMASTER"):GetValue("OX_FORM")
		oHWS      := oModel:GetModel('DETAIL_HWS')

		HWS->(dbSetOrder(1))

		For nIndHWS := 1 To oHWS:Length()
			cCdMq := oHWS:GetValue("HWS_CDMQ", nIndHWS)

			If HWS->(dbSeek(xFilial("HWS")+cFormular+cCdMq))
				If nOperation == MODEL_OPERATION_DELETE .Or. !oHWS:GetValue("MARCA", nIndHWS)
					RecLock("HWS",.F.)
					HWS->(dbDelete())
					HWS->(MsUnlock())
				EndIf
			ElseIf oHWS:GetValue("MARCA", nIndHWS)
				RecLock("HWS",.T.)
				HWS->HWS_FILIAL := xFilial('HWS')
				HWS->HWS_FORM   := cFormular
				HWS->HWS_CDMQ   := cCdMq
				HWS->(MsUnlock())
			EndIf
		Next nIndHWS
		
	ElseIf cPrgApon == "3" .And. AliasInDic("HZT")
		cIdForm    := oModel:GetModel("OXMASTER"):GetValue("OX_FORM")
		oHZT       := oModel:GetModel("HZTFIELDS")

		HZT->(dbSetOrder(1))

		Aadd(aCamposHZT, {"INT_CRP", oHZT:GetValue("INT_CRP")})
		Aadd(aCamposHZT, {"OP_PROGR", oHZT:GetValue("OP_PROGR")})
		Aadd(aCamposHZT, {"EX_PROGR", oHZT:GetValue("EX_PROGR")})
		Aadd(aCamposHZT, {"SETUP_INICIAL", oHZT:GetValue("SETUP_INICIAL")})
		Aadd(aCamposHZT, {"PRODUCAO", oHZT:GetValue("PRODUCAO")})
		Aadd(aCamposHZT, {"FINALIZACAO", oHZT:GetValue("FINALIZACAO")})
		Aadd(aCamposHZT, {"REMOCAO", oHZT:GetValue("REMOCAO")})
		
		For nIndHZT := 1 To Len(aCamposHZT)
			If HZT->(dbSeek(xFilial("HZT")+cIdForm+aCamposHZT[nIndHZT][1]))
				If nOperation == MODEL_OPERATION_DELETE
					RecLock("HZT",.F.)
					HZT->(dbDelete())
					HZT->(MsUnlock())
				Else
					xValor = A125TipoParam(aCamposHZT[nIndHZT][2])
					INSERTHZT(cIdForm, aCamposHZT[nIndHZT][1], xValor)
				EndIf	
			ELSE 
				xValor = A125TipoParam(aCamposHZT[nIndHZT][2])
				INSERTHZT(cIdForm, aCamposHZT[nIndHZT][1], xValor)
			EndIf	
		Next nIndHZT

		oHWS := oModel:GetModel('DETAIL_HWSC')

		HWS->(dbSetOrder(1))

		For nIndHWS := 1 To oHWS:Length()
			cCdMq := oHWS:GetValue("HWS_CDMQ", nIndHWS)

			If HWS->(dbSeek(xFilial("HWS")+cIdForm+cCdMq))
				If nOperation == MODEL_OPERATION_DELETE .Or. !oHWS:GetValue("MARCA", nIndHWS)
					RecLock("HWS",.F.)
					HWS->(dbDelete())
					HWS->(MsUnlock())
				EndIf
			ElseIf oHWS:GetValue("MARCA", nIndHWS)
				RecLock("HWS",.T.)
				HWS->HWS_FILIAL := xFilial('HWS')
				HWS->HWS_FORM   := cIdForm
				HWS->HWS_CDMQ   := cCdMq
				HWS->(MsUnlock())
			EndIf
		Next nIndHWS
	EndIf

Return Nil

/*/{Protheus.doc} ModelPosVld
Método que é chamado pelo MVC quando ocorrer as ações de pos validação do Model

@type  METHOD
@author lucas.franca
@since 02/03/2021
@version P12
@param oModel  , Object   , Referência do modelo de dados
@param cModelId, Character, ID do submodelo.
@return lRet, Logic, Retorno se o modelo está válido
/*/
METHOD ModelPosVld(oModel, cModelId) CLASS PCPA125EVDEF
	Local cProgApont := oModel:GetModel("OXMASTER"):GetValue("OX_PRGAPON")
	Local lFinaliz   := ""	
	Local lIntCRP    := ""
	Local lProducao  := ""
	Local lRemocao   := ""
	Local lRet       := .T.
	Local lSetInic   := ""
	Local nI         := 0
	Local nOperation := oModel:GetOperation()
	Local oMdlHZT    := Nil
	Local oMdlHWS    := Nil
	Local oMdlPermis := Nil
	Local oMdlSMJ    := Nil

	If cProgApont == "4"
		oMdlHWS := oModel:GetModel('DETAIL_HWS')
		If (nOperation == MODEL_OPERATION_INSERT .Or. nOperation == MODEL_OPERATION_UPDATE)
			lRet := .F.
			For nI := 1 To oMdlHWS:Length()
				If oMdlHWS:GetValue("MARCA", nI)
					lRet := .T.
					Exit
				EndIf
			Next

			If !lRet
				Help(' ',1,"Help" ,,STR0014,; //"Nenhuma Máquina foi selecionada."
			         2,0,,,,,,{STR0015}) //"Deverá ser selecionada pelo menos uma máquina."
			EndIf
		EndIf
	EndIf

	If lRet .And. cProgApont $ "|1|3|4|"
		oMdlPermis := oModel:GetModel("SMJ_PERMISSAO")
		oMdlSMJ    := oModel:GetModel("DETAIL_SMJ")
		If oMdlPermis:GetValue("MJ_VISUAL") == "2" .And. ;
		   (oMdlPermis:GetValue("MJ_INCLUI") == "1" .Or. ;
		    oMdlPermis:GetValue("MJ_ALTERA") == "1" .Or. ;
		    oMdlPermis:GetValue("MJ_EXCLUI") == "1")
			Help(' ', 1, "Help",, STR0027,; //"Permissão de visualização de empenhos inválida."
			     2, 0, , , , , , {STR0028}) //"Quando as permissões de Inclusão, Alteração ou Exclusão estão selecionadas como Sim, a permissão de Visualização deve possuir conteúdo Sim. Ajuste as permissões na aba 'Empenhos'."
			lRet := .F.
		EndIf
	EndIf

	If lRet .And. cProgApont = "3" .And. AliasInDic("HZT")
		oMdlHZT    := oModel:GetModel("HZTFIELDS")
		lIntCRP    := oMdlHZT:GetValue("INT_CRP")
		lSetInic   := oMdlHZT:GetValue("SETUP_INICIAL")
		lProducao  := oMdlHZT:GetValue("PRODUCAO")
		lFinaliz   := oMdlHZT:GetValue("FINALIZACAO")
		lRemocao   := oMdlHZT:GetValue("REMOCAO")
		If lIntCRP .And. !lSetInic .And. !lProducao .And. !lFinaliz .And. !lRemocao
			Help(' ',1,"Help" ,,STR0080,; //"Nenhum Tipo de Alocação foi selecionado."
		         2,0,,,,,,{STR0081}) //"Deverá ser selecionado pelo menos um tipo de alocação."
			lRet := .F.				 
		EndIf

		If lRet .And. lIntCRP
			oMdlHWS := oModel:GetModel('DETAIL_HWSC')
			If (nOperation == MODEL_OPERATION_INSERT .Or. nOperation == MODEL_OPERATION_UPDATE)
				lRet := .F.
				For nI := 1 To oMdlHWS:Length()
					If oMdlHWS:GetValue("MARCA", nI)
						lRet := .T.
						Exit
					EndIf
				Next

				If !lRet
					Help(' ',1,"Help" ,,STR0085,; //"Nenhum Recurso foi selecionado."
						2,0,,,,,,{STR0086}) //"Deverá ser selecionado pelo menos um recurso para formulários integrados ao CRP."
				EndIf
			EndIf
		EndIf
	EndIf

Return lRet

/*/{Protheus.doc} GridLinePosVld
Método que é chamado pelo MVC quando ocorrer as ações de pos validação da linha do Grid
@author renan.roeder
@since 03/11/2021
@version 1.0
@param 01 oSubModel    , Objeto  , Modelo principal
@param 02 cModelId     , Caracter, Id do submodelo
@param 03 nLine        , Numérico, Linha do grid
@return lOK
/*/
METHOD GridLinePosVld(oSubModel, cModelID, nLine) CLASS PCPA125EVDEF
	Local lRet      := .T.
	Local cCampo    := ""	
	Local cTabela   := ""
	Local cTipo     := ""
	Local cValPad   := ""
	Local aDadosSX5 := {}

	If cModelID == "DETAIL_SMC"
		If oSubModel:HasField("MC_TABELA")
			If "CustomFieldList" $ oSubModel:GetValue("MC_TIPO", nLine)
				cTabela := AllTrim(oSubModel:GetValue("MC_TABELA", nLine))
				cValPad := RTrim(oSubModel:GetValue("MC_VALPAD", nLine))
				cCampo  := AllTrim(oSubModel:GetValue("MC_CAMPO", nLine))
				If Empty(cTabela) .And. !Empty(cValPad)
						Help(' ',1,"Help" ,,STR0035 + STR0038,; //"O Valor Padrão não está vinculado a uma Tabela."
							2,0,,,,,,{STR0039}) //"Informe a tabela para estabelecer o Valor Padrão da lista."
						lRet := .F.
				ElseIf !Empty(cTabela) .And. !Empty(cValPad)
					aDadosSX5 := FWGetSX5(cTabela, cValPad)
					If Len(aDadosSX5) == 0
						Help(' ',1,"Help" ,,STR0035 + "'" + cValPad + "'" + STR0036 + "'" + cTabela + "'.",; //"O Valor Padrão '" + cValPad + "' não pertence a Tabela '" + cTabela + "'."
							2,0,,,,,,{STR0037}) //"O Valor Padrão deve pertencer a tabela selecionada."
						lRet := .F.
					EndIf
				EndIf
				If lRet 
					cTipo := GetSX3Cache(cCampo,"X3_TIPO")
					If !Empty(cTipo) .And. cTipo != "C"
						Help(' ',1,"Help" ,,STR0049 + "'" + cCampo + "'" + STR0050,; //"O campo " + cCampo + " não é do tipo caracter."
							2,0,,,,,,{STR0051}) //"Informe um campo do tipo caracter para receber a informação da lista."
						lRet := .F.
					EndIf
				EndIf				
			EndIf
		EndIf
		If lRet
			If oSubModel:HasField("MC_TPFORM")
				lRet := validCampo(oSubModel, nLine, "MC_TPFORM")
			Else
				If oSubModel:HasField("TPFORM")
					lRet := validCampo(oSubModel, nLine, "TPFORM")
				EndIf
			EndIf
		EndIf
	EndIf

Return lRet

/*/{Protheus.doc} validCampo
Valida o alias da tabela atribuído ao campo conforme o tipo de formulário

@type  Function
@author renan.roeder
@since 04/11/2022
@version P12
@param  oSubModel, Objeto  , Modelo principal
@param  nLine    , Numérico, Linha do grid
@return lRet     , Lógico  , Prefixo da tabela correto atribuído ao nome do campo
/*/
Function validCampo(oSubModel, nLine, cCampo)
	Local lRet      := .T.
	Local cAliasInp := SUBSTR(oSubModel:GetValue("MC_CAMPO",nLine),1,aT("_",oSubModel:GetValue("MC_CAMPO",nLine)))
	Local cAliasVal := ""
	Local cPrgApon  := oSubModel:GetModel():GetValue("OXMASTER", "OX_PRGAPON")
	Local cTpForm   := AllTrim(oSubModel:GetValue(cCampo,nLine))

	If cTpForm == "2"
		cAliasVal := "D4_"
		If cAliasInp != cAliasVal
			lRet := .F.
		EndIf
	ElseIf cTpForm == "1"
		If (cPrgApon == "1" .Or. cPrgApon == "5")
			cAliasVal := "D3_"
			If cAliasInp != cAliasVal
				lRet := .F.
			EndIf
		ElseIf (cPrgApon == "2" .Or. cPrgApon == "3")
			cAliasVal := "H6_"
			If cAliasInp != cAliasVal
				lRet := .F.
			EndIf
		ElseIf cPrgApon == "4"
			cAliasVal := "CYV_"
			If cAliasInp != cAliasVal
				lRet := .F.
			EndIf
		ElseIf cPrgApon == "7"
			cAliasVal := "BC_"
			If cAliasInp != cAliasVal
				lRet := .F.
			EndIf
		EndIf
	ElseIf cTpForm == "3"
		cAliasVal := "C2_"
		If cAliasInp != cAliasVal
			lRet := .F.
		EndIf	
	EndIf
	If !lRet
		Help(' ',1,"Help" ,,STR0045,; //"Foi atribuido valor incorreto ao atributo 'Campo'."
			2,0,,,,,,{STR0046 + "'"+cAliasVal+"'."}) //"O valor deve ter o prefixo "
	EndIf
Return lRet

/*/{Protheus.doc} cargaSMJ
Carrega os dados da tabela SMJ

@type  Static Function
@author lucas.franca
@since 02/03/2021
@version P12
@param oModel, Object, Referência do modelo de dados
@return Nil
/*/
Static Function cargaSMJ(oModel)
	Local oMdlSMJ    := oModel:GetModel("DETAIL_SMJ")
	Local oMdlPermis := oModel:GetModel("SMJ_PERMISSAO")

	If oMdlSMJ:IsEmpty()
		oMdlPermis:setValue("MJ_VISUAL", "1")
		oMdlPermis:setValue("MJ_INCLUI", "2")
		oMdlPermis:setValue("MJ_ALTERA", "2")
		oMdlPermis:setValue("MJ_EXCLUI", "2")

		//Remove restrições de modificação do modelo da SMJ
		A125PropMJ(oMdlSMJ, oMdlSMJ:GetStruct(), "REMOVER")

		//Adiciona os valores padrões na grid da tabela SMJ
		addGridSMJ(oMdlSMJ)

		//Adiciona novamente as restrições de modificação do modelo da SMJ
		A125PropMJ(oMdlSMJ, oMdlSMJ:GetStruct(), "ADICIONAR")
	EndIf
Return Nil

/*/{Protheus.doc} addGridSMJ
Retorna os valores default do formulário de empenhos

@type  Static Function
@author lucas.franca
@since 03/03/2021
@version P12
@param oModel, Object, Referência do modelo de dados da SMJ.
@return aData, Array , Array com os valores de carga do formulário de empenhos
/*/
Static Function addGridSMJ(oModel)
	Local aData      := {}
	Local aValues    := {}
	Local aFields    := oModel:oFormModelStruct:aFields
	Local nTamCmp    := GetSX3Cache("MJ_CAMPO"  , "X3_TAMANHO")
	Local nTamDesc   := GetSX3Cache("MJ_DESCAMP", "X3_TAMANHO")
	Local nIndex     := 0
	Local nTotal     := 0
	Local nIndFields := 0
	Local nTotalFld  := Len(aFields)
	Local oPosition  := JsonObject():New()

	oPosition["MJ_CAMPO"  ] := 1
	oPosition["MJ_CODBAR" ] := 2
	oPosition["MJ_VISIVEL"] := 3
	oPosition["MJ_EDITA"  ] := 4
	oPosition["MJ_VISUAL" ] := 5
	oPosition["MJ_INCLUI" ] := 6
	oPosition["MJ_ALTERA" ] := 7
	oPosition["MJ_EXCLUI" ] := 8
	oPosition["MJ_POSIC"  ] := 9
	oPosition["MJ_DESCAMP"] := 0

	//aValues - MJ_CAMPO, MJ_CODBAR, MJ_VISIVEL, MJ_EDITA, MJ_VISUAL, MJ_INCLUI, MJ_ALTERA, MJ_EXCLUI, MJ_POSIC
	aAdd(aValues, {PadR("D4_COD"    , nTamCmp), "1", "1", "1", "1", "2", "2", "2", 10})
	aAdd(aValues, {PadR("D4_LOCAL"  , nTamCmp), "2", "1", "1", "1", "2", "2", "2", 20})
	aAdd(aValues, {PadR("D4_DATA"   , nTamCmp), "2", "1", "1", "1", "2", "2", "2", 30})
	aAdd(aValues, {PadR("D4_QTDEORI", nTamCmp), "2", "1", "1", "1", "2", "2", "2", 40})
	aAdd(aValues, {PadR("D4_QUANT"  , nTamCmp), "2", "1", "1", "1", "2", "2", "2", 50})
	aAdd(aValues, {PadR("D4_TRT"    , nTamCmp), "2", "1", "1", "1", "2", "2", "2", 60})
	aAdd(aValues, {PadR("D4_LOTECTL", nTamCmp), "1", "1", "1", "1", "2", "2", "2", 70})
	aAdd(aValues, {PadR("D4_NUMLOTE", nTamCmp), "1", "1", "1", "1", "2", "2", "2", 80})
	aAdd(aValues, {PadR("D4_DTVALID", nTamCmp), "2", "1", "2", "1", "2", "2", "2", 90})
	aAdd(aValues, {PadR("D4_OPORIG" , nTamCmp), "2", "1", "2", "1", "2", "2", "2", 100})
	aAdd(aValues, {PadR("D4_QTSEGUM", nTamCmp), "2", "1", "1", "1", "2", "2", "2", 110})
	aAdd(aValues, {PadR("D4_POTENCI", nTamCmp), "2", "1", "2", "1", "2", "2", "2", 120})
	aAdd(aValues, {PadR("D4_SEQ"    , nTamCmp), "2", "1", "2", "1", "2", "2", "2", 130})
	aAdd(aValues, {PadR("D4_EMPROC" , nTamCmp), "2", "1", "1", "1", "2", "2", "2", 140})
	aAdd(aValues, {PadR("D4_PRODUTO", nTamCmp), "2", "1", "2", "1", "2", "2", "2", 150})
	aAdd(aValues, {PadR("D4_OPERAC" , nTamCmp), "2", "1", "2", "1", "2", "2", "2", 160})
	aAdd(aValues, {PadR("D4_PRDORG" , nTamCmp), "1", "1", "1", "1", "2", "2", "2", 170})

	nTotal := Len(aValues)
	For nIndex := 1 To nTotal
		If !Empty(oModel:GetValue("MJ_CAMPO"))
			oModel:AddLine()
		EndIf
		For nIndFields := 1 To nTotalFld
			If oPosition[aFields[nIndFields][3]] != Nil
				If aFields[nIndFields][3] == "MJ_DESCAMP"
					oModel:SetValue("MJ_DESCAMP", PadR(FWSX3Util():GetDescription(aValues[nIndex][oPosition["MJ_CAMPO"]]), nTamDesc))
				Else
					oModel:SetValue(aFields[nIndFields][3], aValues[nIndex][oPosition[aFields[nIndFields][3]]])
				EndIf
			EndIf
		Next nIndFields
	Next nIndex
	oModel:GoLine(1)
	aSize(aValues, 0)
	FreeObj(oPosition)
Return aData

/*/{Protheus.doc} cargaSMC
Carrega os dados da tabela SMC

@type Static Function
@author marcelo.neumann
@since 23/06/2021
@version P12
@param oModel   , Object   , Referência do modelo de dados
@param cProgApon, Character, Indicador do Programa de Apontamento
@return Nil
/*/
Static Function cargaSMC(oModel, cProgApon)
	Local aCamposSMC := {}
	Local nIndex     := 1
	Local nTotal     := 0
	Local oModelSMC  := oModel:GetModel("DETAIL_SMC")

	//Permite a inclusão e exclusão de linhas
	oModelSMC:SetNoInsertLine(.F.)
	oModelSMC:SetNoDeletetLine(.F.)
	If cProgApon == "1" //CAMPOS DA ROTINA MATA250
		A125CMPSMC(@aCamposSMC,"D3")
		A125CMPSMC(@aCamposSMC,"D4")
	ElseIf cProgApon == "3" //CAMPOS DA ROTINA MATA681
		A125CMPSMC(@aCamposSMC,"H6")
		A125CMPSMC(@aCamposSMC,"D4")
	ElseIF cProgApon == "4"
		A125CMPSMC(@aCamposSMC,"CYV")
		A125CMPSMC(@aCamposSMC,"D4")
	ElseIf cProgApon == "6" //CAMPOS DA ROTINA MATA650
		A125CMPSMC(@aCamposSMC,"C2")
	ElseIf cProgApon == "7" //APONTAMENTO DE PERDA (MATA685)
		A125CMPSMC(@aCamposSMC,"BC")
	EndIf
	nTotal := Len(aCamposSMC)
	_lLoadData := .T.
	For nIndex := 1 To nTotal
		oModelSMC:AddLine()
		oModelSMC:SetValue("MC_TIPO"   , aCamposSMC[nIndex][1])
		oModelSMC:SetValue("MC_CAMPO"  , aCamposSMC[nIndex][2])
		oModelSMC:SetValue("MC_DESCAMP", "")
		oModelSMC:SetValue("MC_CODBAR" , "2")
		oModelSMC:SetValue("MC_VISIVEL", "2")
		oModelSMC:SetValue("MC_EDITA"  , "2")
		oModelSMC:SetValue("MC_VALPAD" , "")
		oModelSMC:SetValue("MC_TABELA" , "")
		If oModelSMC:HasField("MC_POSIC")
			oModelSMC:SetValue("MC_TPFORM" , aCamposSMC[nIndex][3])
			oModelSMC:SetValue("MC_POSIC"  , 0)
		Else
			oModelSMC:SetValue("TPFORM"    , aCamposSMC[nIndex][3])
		EndIf
	Next nIndex
	_lLoadData := .F.
	If oModelSMC:Length() > 0
		oModelSMC:GoLine(1)
	EndIf
	//Bloqueia inclusão e exclusão de linhas
	oModelSMC:SetNoInsertLine(.T.)
	oModelSMC:SetNoDeletetLine(.T.)
Return

/*/{Protheus.doc} A125CMPSMC
Monta o array com a lista de campos customizados conforme o alias parametrizado

@type  Static Function
@author renan.roeder
@since 04/11/2022
@version P12
@param  aCamposSMC , Array   , Array passado por referência para receber a lista de campos
@param  cAlias     , Caracter, Alias da tabela
@return Nil
/*/
Function A125CMPSMC(aCamposSMC,cAlias)
	Local cTpForm := IIF(cAlias == "D4","2",IIF(cAlias == "C2", "3","1"))

	Aadd(aCamposSMC, {"CustomFieldCharacter01",cAlias+"_CCCA01",cTpForm})
	Aadd(aCamposSMC, {"CustomFieldCharacter02",cAlias+"_CCCA02",cTpForm})
	Aadd(aCamposSMC, {"CustomFieldCharacter03",cAlias+"_CCCA03",cTpForm})
	Aadd(aCamposSMC, {"CustomFieldCharacter04",cAlias+"_CCCA04",cTpForm})
	Aadd(aCamposSMC, {"CustomFieldCharacter05",cAlias+"_CCCA05",cTpForm})
	Aadd(aCamposSMC, {"CustomFieldDecimal01"  ,cAlias+"_CCDE01",cTpForm})
	Aadd(aCamposSMC, {"CustomFieldDecimal02"  ,cAlias+"_CCDE02",cTpForm})
	Aadd(aCamposSMC, {"CustomFieldDecimal03"  ,cAlias+"_CCDE03",cTpForm})
	Aadd(aCamposSMC, {"CustomFieldDecimal04"  ,cAlias+"_CCDE04",cTpForm})
	Aadd(aCamposSMC, {"CustomFieldDecimal05"  ,cAlias+"_CCDE05",cTpForm})
	Aadd(aCamposSMC, {"CustomFieldDate01"	  ,cAlias+"_CCDA01",cTpForm})
	Aadd(aCamposSMC, {"CustomFieldDate02"	  ,cAlias+"_CCDA02",cTpForm})
	Aadd(aCamposSMC, {"CustomFieldDate03"	  ,cAlias+"_CCDA03",cTpForm})
	Aadd(aCamposSMC, {"CustomFieldDate04"	  ,cAlias+"_CCDA04",cTpForm})
	Aadd(aCamposSMC, {"CustomFieldDate05"	  ,cAlias+"_CCDA05",cTpForm})
	Aadd(aCamposSMC, {"CustomFieldLogical01"  ,cAlias+"_CCLO01",cTpForm})
	Aadd(aCamposSMC, {"CustomFieldLogical02"  ,cAlias+"_CCLO02",cTpForm})
	Aadd(aCamposSMC, {"CustomFieldLogical03"  ,cAlias+"_CCLO03",cTpForm})
	Aadd(aCamposSMC, {"CustomFieldLogical04"  ,cAlias+"_CCLO04",cTpForm})
	Aadd(aCamposSMC, {"CustomFieldLogical05"  ,cAlias+"_CCLO05",cTpForm})
	Aadd(aCamposSMC, {"CustomFieldList01"	  ,cAlias+"_CCLI01",cTpForm})
	Aadd(aCamposSMC, {"CustomFieldList02"	  ,cAlias+"_CCLI02",cTpForm})
	Aadd(aCamposSMC, {"CustomFieldList03"	  ,cAlias+"_CCLI03",cTpForm})
	Aadd(aCamposSMC, {"CustomFieldList04"	  ,cAlias+"_CCLI04",cTpForm})
	Aadd(aCamposSMC, {"CustomFieldList05"	  ,cAlias+"_CCLI05",cTpForm})
	dbSelectArea("SMC")
	If FieldPos("MC_POSIC") > 0
		Aadd(aCamposSMC, {"CustomFieldButton01"   ,cAlias+"_CCBT01",cTpForm})
		Aadd(aCamposSMC, {"CustomFieldButton02"   ,cAlias+"_CCBT02",cTpForm})
		Aadd(aCamposSMC, {"CustomFieldButton03"   ,cAlias+"_CCBT03",cTpForm})
		Aadd(aCamposSMC, {"CustomFieldButton04"   ,cAlias+"_CCBT04",cTpForm})
		Aadd(aCamposSMC, {"CustomFieldButton05"   ,cAlias+"_CCBT05",cTpForm})
	EndIf
Return

/*/{Protheus.doc} A125WhnSMC
Função de avaliação de WHEN para o campo MC_TABELA.

@type  Function
@author renan.roeder
@since 03/11/2021
@version P12
@param oModel, Object   , Referência do modelo de dados
@param cCampo, Character, Indica qual campo está sendo analisado.
@return lRet , Logic    , Indica se o campo pode ter seu conteúdo modificado
/*/
Function A125WhnSMC(oModel, cCampo)
	Local lRet := .F.

	If _lLoadData
		lRet := .T.
	Else
		If cCampo == "MC_TABELA"
			If "CustomFieldList" $ oModel:GetValue("MC_TIPO")
				lRet := .T.
			EndIf
		Else 
			lRet := .T.
			If "CustomFieldButton" $ oModel:GetValue("MC_TIPO")
				lRet := .F.
			EndIf
		EndIf
	EndIf

Return lRet

/*/{Protheus.doc} A125WhnSOY
Função de avaliação de WHEN para os campos da tabela SOY.

@type Function
@author lucas.franca
@since 12/07/2021
@version P12
@param oModel, Object   , Referência do modelo de dados
@param cCampo, Character, Indica qual campo está sendo analisado.
@return lRet , Logic    , Indica se o campo pode ter seu conteúdo modificado
/*/
Function A125WhnSOY(oModel, cCampo)
	Local lRet := .T.

	If !_lLoadData .And. "|" + AllTrim(oModel:GetValue("OY_CAMPO")) + "|" $ CAMPOS_DESCRICAO
		lRet := .F.
	EndIf
Return lRet

/*/{Protheus.doc} A125CMPPAD
Retorna os campos padrões que serão listados para cada tipo de programa de apontamento
@type Function
@author renan.roeder
@since 25/07/2023
@version P12
@param  cPrgApon, caracter, Código do programa de apontamento
@param  aCampos , array   , Array passado como referência para receber os campos
@return Nil
/*/
Function A125CMPPAD(cPrgApon,aCampos)
	Do Case
		Case cPrgApon == "1"
			aCampos := {"D3_TM"     , "D3_OP"     , "D3_COD"    , "D3_CODDSC" , "D3_UM"     , "D3_QUANT"  ,;
						"D3_PERDA"  , "D3_PARCTOT", "D3_CONTA"  , "D3_CC"     , "D3_LOCAL"  , "D3_DOC"    ,;
						"D3_EMISSAO", "D3_SEGUM"  , "D3_QTSEGUM", "D3_LOTECTL", "D3_DTVALID", "D3_POTENCI",;
						IIF(IntWms(), "D3_SERVIC" , "")}
		Case cPrgApon == "3"
			aCampos := {"H6_OP"     , "H6_OPERAC" , "H6_PRODUTO", "H6_PROEDSC", "H6_RECURSO",;
						"H6_FERRAM" , "H6_DATAINI", "H6_HORAINI", "H6_DATAFIN", "H6_HORAFIN",;
						"H6_TEMPO"  , "H6_QTDPROD", "H6_QTDPERD", "H6_PT"     , "H6_DTAPONT",;
						"H6_DESDOBR", "H6_LOTECTL", "H6_NUMLOTE", "H6_DTVALID", "H6_POTENCI",;
						"H6_OBSERVA", "H6_OPERADO", "H6_SEQ"    , "H6_QTDPRO2", "H6_RATEIO" , "H6_LOCAL"}
		Case cPrgApon == "4"
			aCampos := {"CYV_CDMQ"  ,"CYV_NRORPO","CYV_CDACRP","CYV_CDACSC","CYV_CDAT"  ,;
						"CYV_IDATQO","CYV_DTBGSU","CYV_HRBGSU","CYV_DTEDSU","CYV_HREDSU","CYV_CDSU"  ,;
						"CYV_DTRPBG","CYV_HRRPBG","CYV_DTRPED","CYV_HRRPED","CYV_CDTN"  ,"CYV_QTATAP","CYV_NRDO",;
						"CYV_NRSR"  ,"CYV_CDDP"  ,"CYV_CDLOSR","CYV_DTVDLO","CYW_CDOE"  ,"CYW_CDGROE","CZ0_CDFE"}
		 Case cPrgApon == "6"
			aCampos := {"C2_PRODUTO", "C2_PRODESC", "C2_LOCAL" , "C2_CC"     , "C2_QUANT",;
						"C2_UM"     , "C2_DATPRI" , "C2_DATPRF", "C2_OBS"    , "C2_EMISSAO",;
						"C2_PRIOR"  , "C2_STATUS" , "C2_SEGUM" , "C2_QTSEGUM", "C2_ROTEIRO",;
						"C2_PEDIDO" , "C2_ITEMPV" , "C2_TPOP"  , "C2_REVISAO", "C2_ITEMCTA",;
						"C2_CLVL"   , "C2_SEQMRP" , "C2_LINHA" , "C2_PROGRAM", "C2_DIASOCI",;
						"C2_OPTERCE", "C2_TPPR"}		
		 Case cPrgApon == "7"
			aCampos := {"BC_OP"     , "BC_OPERAC" , "BC_RECURSO", "BC_PRODUTO", "BC_LOCORIG",;
						"BC_LOCALIZ", "BC_NUMSERI", "BC_TIPO"   , "BC_MOTIVO" , "BC_QUANT"  ,;
						"BC_QTSEGUM", "BC_CC"     , "BC_CODDEST", "BC_LOCAL"  , "BC_LOCDEST", "BC_NSEDEST",;
						"BC_QTDDEST", "BC_QTDDES2", "BC_OPERADO", "BC_DATA"   , "BC_LOTECTL", "BC_NUMLOTE",;
						"BC_DTVALID", "BC_LOTDEST", "BC_DTVLDES", "BC_CODLAN" , "BC_OBSERVA" }
	End Case
Return
