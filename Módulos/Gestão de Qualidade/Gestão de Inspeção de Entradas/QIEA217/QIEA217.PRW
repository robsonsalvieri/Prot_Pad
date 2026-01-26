#INCLUDE "FWMVCDEF.CH"  
#INCLUDE "QIEA217.CH"
#INCLUDE "TOTVS.CH"

/*/{Protheus.doc} QIEA217
Cadastro Anexo de Amostras
@author brunno.costa
@since 17/12/2024
@param 01 - oAnexos, objeto, objeto para controle anexos em memória
@param 02 - nOpc, Numérico, indica a opção executada no browse principal, sendo 3 = Resultados (Incluir e alterar).
/*/
Function QIEA217(oAnexos, nOpc)

	Local aColsAmo    := aOBJETOS[2,nFldLab,nFldEns]:aCols
	Local lAlteraBkp  := ALTERA
	Local lIncluiBkp  := INCLUI
	Local nAmostra    := aOBJETOS[2,nFldLab,nFldEns]:nAt
	Local nPosRecno   := aScan(aOBJETOS[2,nFldLab,nFldEns]:aHeader,{|x|Alltrim(x[2])=="QER_REC_WT"})
	Local nPosResult  := aScan(aOBJETOS[2,nFldLab,nFldEns]:aHeader,{|x|Alltrim(x[2])=="QER_RESULT"})
	Local oEvent      := Nil
	Local oModel      := Nil

	Private lIncAlt := nOpc == 3

	If Empty(GetSx3Cache("QQM_MODULO" ,"X3_TAMANHO")) .OR.;
	   Empty(FWSX2Util():GetFile( "QQM" )) .OR.;
	   !X3Uso(GetSx3Cache("QQM_NOMEOR","X3_USADO"))
		//STR0009 - "Dicionário do Protheus desatualizado."
		//STR0011 - "Atualize o pacote de dicionário mais recente do módulo SIGAQIE para atualização da tabela QQM."
		Help(NIL, NIL, "QIEA217USED", NIL, STR0009, 1, 0, NIL, NIL, NIL, NIL, NIL, {STR0011})
		Return
	EndIf

	nPosResult := Iif(nPosResult == 0, aScan(aOBJETOS[2,nFldLab,nFldEns]:aHeader,{|x|Alltrim(x[2])=="QEQ_RESULT"}), nPosResult)

	If nFldLab < nFldLabGer
		If Empty(aColsAmo[nAmostra, nPosResult])
			//STR0012 - "Amostra sem resultado."
			//STR0013 - "Selecione uma amostra com resultado preenchido."
			Help(NIL, NIL, "QIEA217NORES", NIL, STR0012, 1, 0, NIL, NIL, NIL, NIL, NIL, {STR0013})
		Else
			oModel     := FWLoadModel("QIEA217")
			oEvent     := gtMdlEvent(oModel, "QIEA217EVDEF")
			DbSelectArea("QQM")
			oEvent:oInclusao     := oAnexos['inclusao']
			oEvent:oExclusao     := oAnexos['exclusao']
			If aColsAmo[nAmostra, nPosRecno] > 0
				DbSelectArea("QER")
				QER->(DbGoTo(aColsAmo[nAmostra, nPosRecno]))
				oEvent:cChaveAtual := QER->QER_FILIAL + QER->QER_CHAVE
				oEvent:lAtualDB    := .T.
			Else
				oEvent:cChaveAtual := Str(nFldLab) + ";" + Str(aOBJETOS[1,nFldLab]:nAt) + ";" + Str(aOBJETOS[2,oFolder:nOption,aOBJETOS[1,oFolder:nOption]:nAt]:nAt) //Laboratorio;Ensaio;Amostra
				oEvent:lAtualDB    := .F.
			EndIf
			FWExecView(STR0001, "QIEA217", MODEL_OPERATION_VIEW,,{|| .T. },{|| .T.}, 20,,,,,oModel) //"Anexos Amostra da Inspeção"
		EndIf

	Else
		//STR0002 - "Não foi possivel identificar a amostra para consulta dos anexos."
		//STR0003 - "Selecione uma amostra na aba 'Laboratórios'."
		Help(NIL, NIL, "QIEA217NOLAB", NIL, STR0002, 1, 0, NIL, NIL, NIL, NIL, NIL, {STR0003})
		Return
	EndIf

	INCLUI := lIncluiBkp
	ALTERA := lAlteraBkp

Return Nil

/*/{Protheus.doc} QIEA217GRV
Grava Anexos da Amostra
@author brunno.costa
@since 16/05/2023
@param 01 - oAnexos  , objeto  , objeto para controle dos anexos em memória
@param 02 - cChaveMem, caracter, chave do registro no objeto json oInclusao
									oEvent:lAtualDB .T. -> QER_FILIAL + QER_CHAVE
									oEvent:lAtualDB .F. -> Str(nFldLab) + ";" + Str(aOBJETOS[1,nFldLab]:nAt) + ";" + Str(aOBJETOS[2,oFolder:nOption,aOBJETOS[1,oFolder:nOption]:nAt]:nAt) //Laboratorio;Ensaio;Amostra
@param 03 - cChaveQER, caracter, chave do registro na QER (QER_CHAVE)
/*/
Function QIEA217GRV(oAnexos, cChaveMem, cChaveQER)
	Local oEvent       := NIL
	Local oModel       := FWLoadModel("QIEA217")
	oEvent             := gtMdlEvent(oModel, "QIEA217EVDEF")
	oEvent:oInclusao   := oAnexos['inclusao']
	oEvent:oExclusao   := oAnexos['exclusao']
	oEvent:cChaveAtual := cChaveMem
	If !Empty(cChaveMem) .AND. (oEvent:oInclusao[cChaveMem] != Nil .OR. oEvent:oExclusao[cChaveMem] != Nil)
		oEvent:persisteAnexosAmostra(cChaveQER)
	EndIf
Return

/*/{Protheus.doc} ModelDef
Definição do Modelo
@author brunno.costa
@since 17/12/2024
@return oModel, object, modelo de dados
/*/
Static Function ModelDef()

	Local oStrMaster := FWFormStruct(1,"QER")
	Local oStrDetail := FWFormStruct(1,"QQM")
	Local oModel     := MPFormModel():New('QIEA217')
	Local oEventDef  := QIEA217EVDEF():New()

	//QER_MASTER - Modelo do campo mestre (Cabeçalho)
	oModel:AddFields("QER_MASTER", /*cOwner*/, oStrMaster)
	oModel:GetModel("QER_MASTER"):SetDescription("Amostra")
    oModel:GetModel('QER_MASTER'):SetOnlyView()

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

	oModel:AddGrid("QQM_DETAIL", "QER_MASTER", oStrDetail, /*bLinePre*/, /*bLinePost*/, /*bPre*/, /*bPost*/, /*bLoad*/)
	oModel:GetModel("QQM_DETAIL"):SetDescription(STR0005) //Anexos
	oModel:GetModel("QQM_DETAIL"):bLoad := {|| oEventDef:carregaItensDaGrid(oModel)}

	oModel:SetRelation("QQM_DETAIL",{{"QQM_FILIAL", "xFilial('QQM')"},{"QQM_CHAVE", "QER_CHAVE"},{"QQM_MODULO", "QIE"}}, QQM->(IndexKey(1)))

	//Propriedades do modelo principal
	oModel:SetDescription(STR0001) //"Anexos Amostra da Inspeção"
	oModel:InstallEvent("QIEA217EVDEF", /*cOwner*/, oEventDef)
    oModel:SetPrimaryKey( { "QER_FILIAL", "QER_CHAVE" } )

Return oModel

/*/{Protheus.doc} ViewDef
Definição da View
@author brunno.costa
@since 17/12/2024
@return oView, object, objeto de View
/*/
Static Function ViewDef()
	Local oModel     := FWLoadModel("QIEA217")
	Local oView      := FWFormView():New()
	Local oStrMaster := FWFormStruct(2,"QER", {|cCampo| "|"+AllTrim(cCampo)+"|" $ "|QER_LABOR|QER_ENSAIO|QER_DTMEDI|QER_HRMEDI|"})
	Local oStrDetail := FWFormStruct(2,"QQM", {|cCampo| "|"+AllTrim(cCampo)+"|" $ "|QQM_NOMEOR|QQM_SIZE|"})
	Local oEventDef  := gtMdlEvent(oModel, "QIEA217EVDEF")

	oView:SetModel(oModel)

	//Seta os modelos na View
	oView:AddField("V_QER_MASTER", oStrMaster, "QER_MASTER")
	oView:AddGrid( "V_QQM_DETAIL", oStrDetail, "QQM_DETAIL")

	//Cria os BOXs para as Views
	oView:CreateHorizontalBox("UPPER" ,  0, , .T.)
	oView:CreateHorizontalBox("BOTTOM", 100)

	//Relaciona cada BOX com sua view
	oView:SetOwnerView("V_QER_MASTER", "UPPER" )
	oView:SetOwnerView("V_QQM_DETAIL", "BOTTOM")

	//Habilita o filtro e busca na grid.
	oView:SetViewProperty("V_QQM_DETAIL","GRIDFILTER",{.T.})
	oView:SetViewProperty("V_QQM_DETAIL","GRIDSEEK",{.T.})

	oView:SetViewProperty( "*", "GRIDNOORDER")

	//Adiciona o botão de importar demandas
	oView:AddUserButton(STR0007, "", {|oView| oEventDef:abrirAnexo()   }, , , ,  .T. ) //"Abrir"
	If lIncAlt
		oView:AddUserButton(STR0006, "", {|oView| oEventDef:incluirAnexoMemoria() }, , , ,  .T. ) //"Adicionar"	
		oView:AddUserButton(STR0008, "", {|oView| oEventDef:excluirAnexoMemoria() }, , , ,  .T. ) //"Excluir"
	EndIf
	//Adiciona barra de progresso.
	oView:SetProgressBar(.T.)

Return oView

/*/{Protheus.doc} gtMdlEvent
Recupera a referencia do objeto dos Eventos do modelo.
@author brunno.costa
@since 17/12/2024
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


