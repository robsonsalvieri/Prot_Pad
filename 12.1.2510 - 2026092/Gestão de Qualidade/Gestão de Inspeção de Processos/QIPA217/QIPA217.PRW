#INCLUDE "FWMVCDEF.CH"  
#INCLUDE "QIPA217.CH"
#INCLUDE "TOTVS.CH"

/*/{Protheus.doc} QIPA217
Cadastro Anexo de Amostras
@author brunno.costa
@since 15/05/2023
@param 01 - oAnexos, objeto, objeto para controle anexos em memória
@param 02 - nOpc, Numérico, indica a opção executada no browse principal, sendo 3 = Resultados (Incluir e alterar).
/*/
Function QIPA217(oAnexos, nOpc)

	Local aColsAmo    := aOBJETOS[4,nOperacao,nFldLab,nEnsaio]:aCols
	Local lAlteraBkp  := ALTERA
	Local lIncluiBkp  := INCLUI
	Local nAmostra    := aOBJETOS[4,nOperacao,nFldLab,nEnsaio]:nAt
	Local nPosRecno   := aScan(aOBJETOS[4,nOperacao,nFldLab,nEnsaio]:aHeader,{|x|Alltrim(x[2])=="QPR_REC_WT"})
	Local nPosResult  := aScan(aOBJETOS[4,nOperacao,nFldLab,nEnsaio]:aHeader,{|x|Alltrim(x[2])=="QPR_RESULT"})
	Local oEvent      := Nil
	Local oModel      := Nil
	Local oQLTManager := Nil

	Private lIncAlt := nOpc == 3

	//Atualiza Status QQM_MODULO
	If !Empty(GetSx3Cache("QQM_MODULO" ,"X3_TAMANHO")) .And. FindFunction("QLTQueryManager")
		oQLTManager := QLTQueryManager():New()
		If oQLTManager:ConfirmaNecessidadeDeExecucaoMensalViaSemaforo("001", "UPDQQMMODU", Nil, 9999) //9999 meses - 833 anos
			FwMsgRun(,{|| UPDQQMMODU() }, Nil, STR0013)//"Aguarde, atualizando vínculo dos anexos..."
		EndIf
	EndIf

	nPosResult := Iif(nPosResult == 0, aScan(aOBJETOS[4,nOperacao,nFldLab,nEnsaio]:aHeader,{|x|Alltrim(x[2])=="QPQ_RESULT"}), nPosResult)

	If nFldOpe == 2
		If Empty(aColsAmo[nAmostra, nPosResult])
			//STR0011 - "Amostra sem resultado."
			//STR0012 - "Selecione uma amostra com resultado preenchido."
			Help(NIL, NIL, "QIPA217NORES", NIL, STR0011, 1, 0, NIL, NIL, NIL, NIL, NIL, {STR0012})
		Else
			If !Empty(FWSX2Util():GetFile( "QQM" ))
				If X3Uso(GetSx3Cache("QQM_NOMEOR","X3_USADO"))
					oModel     := FWLoadModel("QIPA217")
					oEvent     := gtMdlEvent(oModel, "QIPA217EVDEF")
					DbSelectArea("QQM")
					oEvent:oInclusao     := oAnexos['inclusao']
					oEvent:oExclusao     := oAnexos['exclusao']
					If aColsAmo[nAmostra, nPosRecno] > 0
						DbSelectArea("QPR")
						QPR->(DbGoTo(aColsAmo[nAmostra, nPosRecno]))
						oEvent:cChaveAtual := QPR->QPR_FILIAL + QPR->QPR_CHAVE
						oEvent:lAtualDB    := .T.
					Else
						oEvent:cChaveAtual := Str(nOperacao) + ";" + Str(nFldLab) + ";" + Str(nEnsaio) + ";" + Str(nAmostra)
						oEvent:lAtualDB    := .F.
					EndIf
					FWExecView(STR0001, "QIPA217", MODEL_OPERATION_VIEW,,{|| .T. },{|| .T.}, 20,,,,,oModel) //"Anexos Amostra da Inspeção"
				Else
					//STR0008 - "Dicionário do Protheus desatualizado."
					//STR0010 - "Atualize o pacote de dicionário mais recente do módulo SIGAQIP para atualização da tabela QQM."
					Help(NIL, NIL, "QIPA217USED", NIL, STR0008, 1, 0, NIL, NIL, NIL, NIL, NIL, {STR0010})
				EndIf
			Else
				//STR0008 - "Dicionário do Protheus desatualizado."
				//STR0009 - "Atualize o pacote de dicionário mais recente do módulo SIGAQIP para criação da tabela QQM."
				Help(NIL, NIL, "QIPA217NOQQM", NIL, STR0008, 1, 0, NIL, NIL, NIL, NIL, NIL, {STR0009})
			EndIf
		EndIf

	Else
		//STR0002 - "Não foi possivel identificar a amostra para consulta dos anexos."
		//STR0003 - "Selecione uma amostra na aba 'Laboratórios'."
		Help(NIL, NIL, "QIPA217NOLAB", NIL, STR0002, 1, 0, NIL, NIL, NIL, NIL, NIL, {STR0003})
		Return
	EndIf

	INCLUI := lIncluiBkp
	ALTERA := lAlteraBkp

Return Nil

/*/{Protheus.doc} QIPA217GRV
Grava Anexos da Amostra
@author brunno.costa
@since 16/05/2023
@param 01 - oAnexos  , objeto  , objeto para controle dos anexos em memória
@param 02 - cChaveMem, caracter, chave do registro no objeto json oInclusao
									oEvent:lAtualDB .T. -> QPR_FILIAL + QPR_CHAVE
									oEvent:lAtualDB .F. -> Str(nOperacao) + ";" + Str(nFldLab) + ";" + Str(nEnsaio) + ";" + Str(nAmostra)
@param 03 - cChaveQPR, caracter, chave do registro na QPR (QPR_CHAVE)
/*/
Function QIPA217GRV(oAnexos, cChaveMem, cChaveQPR)
	Local oEvent       := NIL
	Local oModel       := FWLoadModel("QIPA217")
	oEvent             := gtMdlEvent(oModel, "QIPA217EVDEF")
	oEvent:oInclusao   := oAnexos['inclusao']
	oEvent:oExclusao   := oAnexos['exclusao']
	oEvent:cChaveAtual := cChaveMem
	If !Empty(cChaveMem) .AND. (oEvent:oInclusao[cChaveMem] != Nil .OR. oEvent:oExclusao[cChaveMem] != Nil)
		oEvent:persisteAnexosAmostra(cChaveQPR)
	EndIf
Return

/*/{Protheus.doc} ModelDef
Definição do Modelo
@author brunno.costa
@since 15/05/2023
@return oModel, object, modelo de dados
/*/
Static Function ModelDef()

	Local oStrMaster := FWFormStruct(1,"QPR")
	Local oStrDetail := FWFormStruct(1,"QQM")
	Local oModel     := MPFormModel():New('QIPA217')
	Local oEventDef  := QIPA217EVDEF():New()

	//QPR_MASTER - Modelo do campo mestre (Cabeçalho)
	oModel:AddFields("QPR_MASTER", /*cOwner*/, oStrMaster)
	oModel:GetModel("QPR_MASTER"):SetDescription("Amostra")
    oModel:GetModel('QPR_MASTER'):SetOnlyView()

	//QQM_DETAIL - Modelo dos Anexos (Grid)
	oStrDetail:AddField(""                           ,; // [01] C Titulo do campo
	                    ""                           ,; // [02] C ToolTip do campo
	                    "NREG"                       ,; // [03] C Id do Field
	                    "N"                          ,; // [04] C Tipo do campo
	                    8                            ,; // [05] N Tamanho do campo
	                    0                            ,; // [06] N Decimal do campo
	                    NIL, NIL, NIL, .F.           ,;
	                    {|| 0}                       ,; // [11] B Code-block de inicializacao do campo
	                    NIL, NIL, .T.                )

	oModel:AddGrid("QQM_DETAIL", "QPR_MASTER", oStrDetail, /*bLinePre*/, /*bLinePost*/, /*bPre*/, /*bPost*/, /*bLoad*/)
	oModel:GetModel("QQM_DETAIL"):SetDescription(STR0004) //Anexos
	oModel:GetModel("QQM_DETAIL"):bLoad := {|| oEventDef:carregaItensDaGrid(oModel)}

	If !Empty(GetSx3Cache("QQM_MODULO" ,"X3_TAMANHO"))
		oModel:SetRelation("QQM_DETAIL",{{"QQM_FILIAL", "xFilial('QQM')"},{"QQM_CHAVE", "QPR_CHAVE"},{"QQM_MODULO", "QIP"}}, QQM->(IndexKey(1)))
	Else
		oModel:SetRelation("QQM_DETAIL",{{"QQM_FILIAL", "xFilial('QQM')"},{"QQM_CHAVE", "QPR_CHAVE"}}, QQM->(IndexKey(1)))
	EndIf

	//Propriedades do modelo principal
	oModel:SetDescription(STR0001) //"Anexos Amostra da Inspeção"
	oModel:InstallEvent("QIPA217EVDEF", /*cOwner*/, oEventDef)
    oModel:SetPrimaryKey( { "QPR_FILIAL", "QPR_CHAVE" } )

Return oModel

/*/{Protheus.doc} ViewDef
Definição da View
@author brunno.costa
@since 15/05/2023
@return oView, object, objeto de View
/*/
Static Function ViewDef()
	Local oModel     := FWLoadModel("QIPA217")
	Local oView      := FWFormView():New()
	Local oStrMaster := FWFormStruct(2,"QPR", {|cCampo| "|"+AllTrim(cCampo)+"|" $ "|QPR_LABOR|QPR_ENSAIO|QPR_DTMEDI|QPR_HRMEDI|QPR_OPERAC|"})
	Local oStrDetail := FWFormStruct(2,"QQM", {|cCampo| "|"+AllTrim(cCampo)+"|" $ "|QQM_NOMEOR|QQM_SIZE|"})
	Local oEventDef  := gtMdlEvent(oModel, "QIPA217EVDEF")

	oView:SetModel(oModel)

	//Seta os modelos na View
	oView:AddField("V_QPR_MASTER", oStrMaster, "QPR_MASTER")
	oView:AddGrid( "V_QQM_DETAIL", oStrDetail, "QQM_DETAIL")

	//Cria os BOXs para as Views
	oView:CreateHorizontalBox("UPPER" ,  0, , .T.)
	oView:CreateHorizontalBox("BOTTOM", 100)

	//Relaciona cada BOX com sua view
	oView:SetOwnerView("V_QPR_MASTER", "UPPER" )
	oView:SetOwnerView("V_QQM_DETAIL", "BOTTOM")

	//Habilita o filtro e busca na grid.
	oView:SetViewProperty("V_QQM_DETAIL","GRIDFILTER",{.T.})
	oView:SetViewProperty("V_QQM_DETAIL","GRIDSEEK",{.T.})

	oView:SetViewProperty( "*", "GRIDNOORDER")

	//Adiciona o botão de importar demandas
	oView:AddUserButton(STR0006, "", {|oView| oEventDef:abrirAnexo()   }, , , ,  .T. ) //"Abrir"
	If lIncAlt
		oView:AddUserButton(STR0005, "", {|oView| oEventDef:incluirAnexoMemoria() }, , , ,  .T. ) //"Adicionar"	
		oView:AddUserButton(STR0007, "", {|oView| oEventDef:excluirAnexoMemoria() }, , , ,  .T. ) //"Excluir"
	EndIf
	//Adiciona barra de progresso.
	oView:SetProgressBar(.T.)

Return oView

/*/{Protheus.doc} gtMdlEvent
Recupera a referencia do objeto dos Eventos do modelo.
@author brunno.costa
@since 15/05/2023
@version P12
@param 01 - oModel  , Object   , Modelo de dados
@param 02 - cIdEvent, Character, ID do evento que se deseja recuperar.
@return oEvent , Object   , Referência do evento do modelo de dados.
/*/
Static Function gtMdlEvent(oModel, cIdEvent)
	Local nIndex  := 0
	Local oEvent  := Nil
	Local oMdlPai := Nil

	If oModel != Nil
		oMdlPai := oModel:GetModel()
	EndIf

	If oMdlPai != Nil .And. AttIsMemberOf(oMdlPai, "oEventHandler", .T.) .And. oMdlPai:oEventHandler != NIL
		For nIndex := 1 To Len(oMdlPai:oEventHandler:aEvents)
			If oMdlPai:oEventHandler:aEvents[nIndex]:cIdEvent == cIdEvent
				oEvent := oMdlPai:oEventHandler:aEvents[nIndex]
				Exit
			EndIf
		Next nIndex
	EndIf

Return oEvent


/*/{Protheus.doc} UPDQQMMODU
BAKA para Atualização do Status QQM_MODULO
@author brunno.costa
@since 08/11/2024
@version 1.0
/*/
Function UPDQQMMODU()

	Local cIniUpdate      := ""
	Local oErrorBlock := ErrorBlock({|| FWLogMsg('WARN',, 'SIGAQIP', funName(), '', '01', "UPDQQMMODU Fail", 0, 0, {}) })

	DbSelectArea("QQM")

	cIniUpdate += " UPDATE " + RetSqlName("QQM")
	cIniUpdate += " SET QQM_MODULO = 'QIP' "
	cIniUpdate +=  " FROM " + RetSqlName("QQM")
	cIniUpdate += " WHERE QQM_MODULO = ' ' AND D_E_L_E_T_ = ' ' "

	nStatus := TcSQLExec(cIniUpdate)
	
	ErrorBlock(oErrorBlock)
Return


