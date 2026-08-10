#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "GTPA900.CH"

Static oG900Model

/*/{Protheus.doc} GTPA900()
(long_description)
@type  Function
@author Lucivan Severo Correia
@since 25/06/2020
@version 1
@param 
@return 
@example
(examples)
@see (links_or_references)
/*/
Function GTPA900()
Local oBrowse
Local cMsgErro	:= ''

If ( !FindFunction("GTPHASACCESS") .Or.; 
	( FindFunction("GTPHASACCESS") .And. GTPHasAccess() ) ) 
		
	If ValidaDic(@cMsgErro)
		oBrowse := FWMBrowse():New()
		oBrowse:SetAlias("GY0")
		oBrowse:SetDescription(STR0007) //"Orçamento de Contrato"
			
		oBrowse:AddLegend('GY0_STATUS == "1"',"YELLOW",STR0041, 'GY0_STATUS')//"Em orçamento"
		oBrowse:AddLegend('GY0_STATUS == "2"',"GREEN" ,STR0042, 'GY0_STATUS')//"Contrato vigente"
		oBrowse:AddLegend('GY0_STATUS == "3"',"RED"	  ,STR0043, 'GY0_STATUS')//"Cancelado"
		oBrowse:AddLegend('GY0_STATUS == "4"',"BLACK" ,STR0072, 'GY0_STATUS')//"Finalizado"
		oBrowse:AddLegend('GY0_STATUS == "5"',"ORANGE",STR0081, 'GY0_STATUS')//"Em Revisão"
		oBrowse:AddLegend('GY0_STATUS == "6"',"BLUE"  ,STR0082, 'GY0_STATUS')//"Revisão vigente"
		oBrowse:AddLegend('GY0_STATUS == "7"',"WHITE" ,STR0083, 'GY0_STATUS')//"Obsoleto"

		oBrowse:ACTIVATE()
	Else
		FwAlertHelp(cMsgErro, STR0017)	// "Banco de dados desatualizado, não é possível iniciar a rotina"
	EndIf

EndIf

Return()

/*/{Protheus.doc} MenuDef
(long_description)
@type  Static Function
@author Lucivan Severo Correia
@since 25/06/2020
@version 1
@param 
@return aRotina, return_type, return_description
@example
(examples)
@see (links_or_references)
/*/
Static Function MenuDef()
Local aRotina 	:= {}
Local aRevisa	:= {}

	ADD OPTION aRevisa TITLE STR0094 ACTION "G900IniRev(1)"	OPERATION 2 ACCESS 0 // "Aberta"
	ADD OPTION aRevisa TITLE STR0095 ACTION "G900IniRev(2)"	OPERATION 2 ACCESS 0 // "Reajuste"

	ADD OPTION aRotina TITLE STR0001 ACTION "VIEWDEF.GTPA900" OPERATION 2 ACCESS 0 // "Visualizar"
	ADD OPTION aRotina TITLE STR0002 ACTION "VIEWDEF.GTPA900" OPERATION 3 ACCESS 0 // "Incluir"
	ADD OPTION aRotina TITLE STR0003 ACTION "UpdDelCtr(4)"    OPERATION 4 ACCESS 0 // "Alterar"
	ADD OPTION aRotina TITLE STR0004 ACTION "UpdDelCtr(5)"    OPERATION 5 ACCESS 0 // "Excluir"
	ADD OPTION aRotina TITLE STR0024 ACTION "GTPA900CTR()"    OPERATION 2 ACCESS 0 // Gerar contrato 
	ADD OPTION aRotina TITLE STR0025 ACTION "GTPA900CAN()"    OPERATION 2 ACCESS 0 // Cancelar contrato 
	ADD OPTION aRotina TITLE STR0073 ACTION "GTPA900ENC()"    OPERATION 2 ACCESS 0 // Finalizar contrato 
	ADD OPTION aRotina TITLE STR0046 ACTION "G900GerVia(1)"   OPERATION 2 ACCESS 0 // Gerar Viagens
	ADD OPTION aRotina TITLE STR0047 ACTION "G900GerVia(2)"   OPERATION 2 ACCESS 0 // Consultar Viagens
	ADD OPTION aRotina TITLE STR0049 ACTION "G900GerVia(3)"   OPERATION 2 ACCESS 0 // Viagens Extras
	ADD OPTION aRotina TITLE STR0058 ACTION "G900Ctr()"       OPERATION 2 ACCESS 0 // Visualizar contrato
	ADD OPTION aRotina TITLE STR0084 ACTION aRevisa	   		  OPERATION 2 ACCESS 0 // SubMenu - Revisões
	ADD OPTION aRotina TITLE STR0085 ACTION 'G900GerRev()'    OPERATION 2 ACCESS 0 // "Efetivar Revisão"
	// ADD OPTION aRotina TITLE STR0104 ACTION 'GTPX900R()'	  OPERATION 8 ACCESS 0 // Impressão do Contrato
	ADD OPTION aRotina TITLE STR0104 ACTION 'G900REL()'	  OPERATION 8 ACCESS 0 // Impressão do Contrato
	ADD OPTION aRotina TITLE STR0107 ACTION 'G900VESLin()'    OPERATION 3 ACCESS 0 // Viagens Extra Sem Linha
	ADD OPTION aRotina TITLE STR0109 ACTION 'GTPA900B()'	  OPERATION 8 ACCESS 0 // Documentos Operacionais
	ADD OPTION aRotina TITLE STR0110 ACTION 'GTPA900C()'	  OPERATION 8 ACCESS 0 // Checklist Documentos Operacionais


Return aRotina

/*/{Protheus.doc} ModelDef
	(long_description)
	@type  Function
	@author Lucivan Severo Correia
	@since 25/06/2020
	@version 1
	@param param_name, param_type, param_descr
	@return oModel, return_type, return_description
	@example
	(examples)
	@see (links_or_references)
	/*/
Static Function ModelDef()
	// Local oModel
	Local oStruGY0      := FWFormStruct(1,"GY0")//cabeçalho cadastral
	Local oStruGYD      := FWFormStruct(1,"GYD")//dados da linha
	Local oStruGQJ      := FWFormStruct(1,"GQJ")//Custos adicionais Cadastral
	Local oStruGYX      := FWFormStruct(1,"GYX")//custos adicionais linha
	Local oStruGQZ      := FWFormStruct(1,"GQZ")//custos operacionais
	Local oStruGQI      := FWFormStruct(1,"GQI")//itinerarios
	Local oStruGQ8      := FWFormStruct(1,"GQ8")//Lista de Passageiros - Header
	Local oStruGQB      := FWFormStruct(1,"GQB")//Lista de Passageiros - Detail
	Local oStruGYY      := FWFormStruct(1,"GYY")//Reajuste de Contrato
	Local bPreGYD       := { |oModel, nLine, cOperation, cField, uValue| GYDLnPre(oModel, nLine, cOperation, cField, uValue)}
	Local bPreGQI       := { |oModel, nLine, cOperation, cField, uValue| GQILnPre(oModel, nLine, cOperation, cField, uValue)}
	Local bPosValid     := { |oModel|PosValid(oModel)}
	Local bPosGYD		:= { |oModel|PosVldGYD(oModel)}
	Local oStrTot       := FWFormModelStruct():New()
	Local cMsgErro		:= ''
	Local lHasNewTables := ChkFile('GY0') .AND. ChkFile('GYD') .AND. ChkFile('GQI');
						   .AND. ChkFile('GQZ') .AND. ChkFile('GYX') .AND. ChkFile('GQJ');
						   .AND. ChkFile('GYY')
	Local bCommit		:= {|oModel| G900Commit(oModel)}
	
	If lHasNewTables .And. ValidaDic(@cMsgErro)

		SetModelStruct(oStruGY0,oStruGYD,oStruGQJ,oStruGYX,oStruGQZ,oStruGQI,oStruGYY,oStrTot)

		oG900Model := MPFormModel():New("GTPA900", /*bPreValid*/, bPosValid, /*bCommit*/, /*bCancel*/ )
		oG900Model:setDescription(STR0007) //"Orçamento de Contrato"

		oG900Model:addFields("GY0MASTER",,oStruGY0)
		oG900Model:AddFields("GYYFIELDS","GY0MASTER", oStruGYY,/*bPre*/,/*bPos*/)

		oG900Model:AddGrid("GQJDETAIL" , "GY0MASTER"  , oStruGQJ)
		oG900Model:AddGrid("GYDDETAIL" , "GY0MASTER"  , oStruGYD, bPreGYD, bPosGYD )
		oG900Model:AddGrid("GQIDETAIL" , "GYDDETAIL"  , oStruGQI, bPreGQI )
		oG900Model:AddGrid("GYXDETAIL" , "GYDDETAIL"  , oStruGYX)
		oG900Model:AddGrid("GQZDETAIL" , "GYDDETAIL"  , oStruGQZ)

		oG900Model:AddGrid("GQ8DETAIL" , "GYDDETAIL"  , oStruGQ8)
		oG900Model:AddGrid("GQBDETAIL" , "GQ8DETAIL"  , oStruGQB)
		
		oG900Model:getModel("GY0MASTER"):SetDescription(STR0008) //"Dados do Orçamento de Contrato"
		oG900Model:getModel('GQJDETAIL'):SetDescription(STR0010) //"Custos"		
		oG900Model:getModel("GYDDETAIL"):SetDescription(STR0009) //"Itinerários"
		oG900Model:getModel("GQIDETAIL"):SetDescription(STR0011) //"Percurso"
		oG900Model:getModel('GYXDETAIL'):SetDescription(STR0010) //"Custos"
		oG900Model:getModel('GQZDETAIL'):SetDescription(STR0010) //"Custos"
		
		If GY0->(FieldPos("GY0_FILIAL")) > 0 .AND. GY0->(FieldPos("GY0_NUMERO")) > 0
			oG900Model:SetPrimaryKey({"GY0_FILIAL","GY0_NUMERO","GY0_REVISA"})
		EndIf

		If GQJ->(FieldPos("GQJ_FILIAL")) > 0 .AND. GQJ->(FieldPos("GQJ_CODIGO")) > 0 
		oG900Model:SetRelation("GQJDETAIL", ;
			{{"GQJ_FILIAL",'xFilial("GQJ")'},;
			 {"GQJ_CODIGO","GY0_NUMERO"},;
			 {"GQJ_REVISA","GY0_REVISA"}})
		EndIf

		If GYD->(FieldPos("GYD_FILIAL")) > 0 .AND. GYD->(FieldPos("GYD_NUMERO")) > 0
		oG900Model:SetRelation("GYDDETAIL", ;
			{{"GYD_FILIAL",'xFilial("GYD")'},;
			 {"GYD_NUMERO","GY0_NUMERO"  },;
			 {"GYD_REVISA","GY0_REVISA" }},GYD->(IndexKey(1)))
		EndIf

		If GQI->(FieldPos("GQI_FILIAL")) > 0 .AND. GQI->(FieldPos("GQI_CODIGO")) > 0
		oG900Model:SetRelation("GQIDETAIL", ;
			{{"GQI_FILIAL",'xFilial("GQI")'},;
			{"GQI_CODIGO","GY0_NUMERO"},;
			{"GQI_REVISA","GY0_REVISA"},;
			{"GQI_ITEM  ","GYD_CODGYD"}})
		EndIf

		If GYX->(FieldPos("GYX_FILIAL")) > 0 .AND. GYX->(FieldPos("GYX_CODIGO")) > 0 
		oG900Model:SetRelation("GYXDETAIL", ;
			{{"GYX_FILIAL",'xFilial("GYX")'},;
			{"GYX_CODIGO","GY0_NUMERO"},;
			{"GYX_REVISA","GY0_REVISA" },;
			{"GYX_ITEM  ","GYD_CODGYD"}})
		EndIf

		If GQZ->(FieldPos("GQZ_FILIAL")) > 0 .AND. GQZ->(FieldPos("GQZ_CODIGO")) > 0
		oG900Model:SetRelation("GQZDETAIL", ;
			{{"GQZ_FILIAL",'xFilial("GQZ")'},;
			{"GQZ_CODIGO","GY0_NUMERO"},;
			{"GQZ_REVISA","GY0_REVISA" },;
			{"GQZ_ITEM  ","GYD_CODGYD"}})
		EndIf

		If GQ8->(FieldPos("GQ8_FILIAL")) > 0 .AND. GQ8->(FieldPos("GQ8_CODGY0")) > 0 .AND. GQ8->(FieldPos("GQ8_CODGYD")) > 0
		oG900Model:SetRelation("GQ8DETAIL", ;
			{{"GQ8_FILIAL",'xFilial("GQ8")'},;
			{"GQ8_CODGY0","GYD_NUMERO"}, ;
			{"GQ8_CODGYD","GYD_CODGYD"}})
		EndIf

		If GQB->(FieldPos("GQB_FILIAL")) > 0 .AND. GQB->(FieldPos("GQB_CODIGO")) > 0
		oG900Model:SetRelation("GQBDETAIL", ;
			{{"GQB_FILIAL",'xFilial("GQB")'},;
			{"GQB_CODIGO","GQ8_CODIGO"}})
		EndIf

		If GQB->(FieldPos("GQB_FILIAL")) > 0 .AND. GQB->(FieldPos("GQB_CODIGO")) > 0
		oG900Model:SetRelation("GQBDETAIL", ;
			{{"GQB_FILIAL",'xFilial("GQB")'},;
			{"GQB_CODIGO","GQ8_CODIGO"}})
		EndIf

		oG900Model:SetRelation("GYYFIELDS",;
			{{"GYY_FILIAL",'xFilial("GY0")'},;
			{"GYY_NUMERO","GY0_NUMERO"},;
			{"GYY_REVISA","GY0_REVISA"}},GYY->(IndexKey(1)))

		oG900Model:GetModel('GQBDETAIL'):SetDelAllLine(.T.)

		oG900Model:SetOptional("GYDDETAIL", .T. )
		oG900Model:SetOptional("GQIDETAIL", .T. )
		oG900Model:SetOptional("GQJDETAIL", .T. )
		oG900Model:SetOptional("GYXDETAIL", .T. )
		oG900Model:SetOptional("GQZDETAIL", .T. )
		oG900Model:SetOptional("GQ8DETAIL", .T. )
		oG900Model:SetOptional("GQBDETAIL", .T. )
		oG900Model:SetOptional("GYYFIELDS", .T. )
		
	Else
		FwAlertHelp(cMsgErro, STR0017) // "Banco de dados desatualizado, não é possível iniciar a rotina"
	EndIf

	oG900Model:SetCommit(bCommit)

Return oG900Model

/*/{Protheus.doc} PosValid
(long_description)
@type  Static Function
@author Teixeira
@since 20/08/2020
@version 1.0
@param oModel, objeto, param_descr
@return lRet, Lógico, Lógico
@example
(examples)
@see (links_or_references)
/*/
Static Function PosValid(oModel)

	Local oMdlGY0	:= oModel:GetModel('GY0MASTER')
	Local oMdlGYD	:= oModel:GetModel('GYDDETAIL')
	Local oMdlGQI	:= oModel:GetModel('GQIDETAIL')

	Local lRet	    := .T.

	Local nGqi      := 0
	Local nGyd      := 0

	Local cMsgErro	:= ""
	Local cMsgSoluc	:= ""
	Local cField	:= ""

	Local aRIdaVlta	:={}

	If oModel:GetOperation() == MODEL_OPERATION_INSERT .OR. oModel:GetOperation() == MODEL_OPERATION_UPDATE

		cField := "GY0_CLIENT"

		lRet := GA900VldCli("GY0MASTER",oModel:GetModel("GY0MASTER"),,@cMsgErro,@cMsgSoluc)
		
		If ( lRet )
		
			For nGyd := 1 To oMdlGYD:Length()
				
				If !oMdlGYD:IsDeleted(nGyd)
					oMdlGYD:GoLine(nGyd)

					nGqi:= oMdlGQI:Length()
					While nGqi > 1
						If !oMdlGQI:IsDeleted(nGqi)
							oMdlGQI:GoLine(nGqi)
							lRet := (oMdlGQI:GetValue("GQI_CODDES",nGqi) == oMdlGYD:GetValue("GYD_LOCFIM",nGyd)) .OR.(oMdlGYD:GetValue("GYD_SENTID",nGyd) == '3' )
							EXIT
						EndIf
						nGqi--
					End

					If !lRet 
						Help(,,"PosValid",, STR0026, 1,0)//"Necessário que a ultima linha do itnerario finalize com a localidade final da linha"
					Else
						
						If GYD->(FieldPos('GYD_PLCONV')) > 0 .And. ( oMdlGYD:GetValue("GYD_PLCONV",nGYD) != "1"; 
							.And. Empty(oMdlGYD:GetValue("GYD_VLRTOT",nGYD)) )

							lRet := .F.	

							cMsgErro  := STR0116 //"Foi optado por não utilizar a planilha de custos para a composição do valor convecionado. Entretanto, esse valor está zerado."
							cMsgSoluc := STR0117
							
							cField := "GYD_VLRTOT"

						ElseIf GYD->(FieldPos('GYD_PLCONV')) > 0 .And. ( oMdlGYD:GetValue("GYD_PLCONV",nGYD) == "1"; 
							.And. Empty(oMdlGYD:GetValue("GYD_IDPLCO",nGYD)) )

							cMsgErro := STR0118 //"Foi optado por utilizar a planilha de custos para a composição do valor convecionado.Entretanto, nenhuma planilha foi escolhida."
							
							cMsgSoluc := STR0119 //"Preencha o campo [Id.Pl.Conven] com o identificar de alguma planilha de custos."
							
							cField := "GYD_IDPLCO"

							lRet := .F.

						EndIf
						
						If ( lRet .And. !Empty(oMdlGYD:GetValue("GYD_PREEXT",nGYD));
							.And. GYD->(FieldPos('GYD_PLEXTR')) > 0 .And. oMdlGYD:GetValue("GYD_PLEXTR",nGYD) != "1"; 
							.And. Empty(oMdlGYD:GetValue("GYD_VLREXT",nGYD)) )

							lRet := .F.	

							cMsgErro := STR0120 //"Foi optado por não utilizar a planilha de custos para a composição do valor extra. Entretanto, esse valor está zerado."
							
							cMsgSoluc := STR0121 //"Preencha o campo [Valor Extra] com um valor maior que 0,00"
							
							cField := "GYD_VLREXT"
						
							// Exit
						ElseIf GYD->(FieldPos('GYD_PLEXTR')) > 0 .And. ( oMdlGYD:GetValue("GYD_PLEXTR",nGYD) == "1"; 
							.And. Empty(oMdlGYD:GetValue("GYD_IDPLEX",nGYD)) )
							
							lRet := .F.	

							cMsgErro := STR0122 //"Foi optado por utilizar a planilha de custos para a composição do valor extra. Entretanto, nenhuma planilha foi escolhida."
							
							cMsgSoluc := STR0023 //"Preencha o campo [Id.Pl.Extra] com o identificar de alguma planilha de custos."
							
							cField := "GYD_IDPLEX"
						
						EndIf
						
						If lRet .And. oMdlGYD:GetValue("GYD_SENTID",nGYD) == '3'
							aRIdaVlta:=(G900ValIdaVolta(oMdlGQI,oMdlGYD,nGYD))
							If !(aRIdaVlta[1])
								cMsgErro := aRIdaVlta[2]
								cMsgSoluc:= aRIdaVlta[3]
								lRet:= .F.
							EndIf
						EndIf

						If lRet .AND. GY0->(FieldPos('GY0_DTINIC'))
							If oMdlGYD:GetValue("GYD_INIVIG",nGYD) < oMdlGY0:GetValue('GY0_DTINIC')
								cMsgErro := STR0124 //'A Data do Inicio da Vigência da Linha não pode ser menor que a data de Inicio do Contrato.'
								cMsgSoluc:= STR0125 + DToC(oMdlGY0:GetValue('GY0_DTINIC')) + STR0126 + DToC(oMdlGY0:GetValue('GY0_DTVIGE'))//'Defina um ínicio de Vigência de Linha entre o Inicio do Contrato: ' // ' e a Vigência do Contrato: '
								lRet:= .F.
							EndIf
						EndIf

						If lRet .AND. GY0->(FieldPos('GY0_DTVIGE'))
							If oMdlGYD:GetValue("GYD_INIVIG",nGYD) > oMdlGY0:GetValue('GY0_DTVIGE')
								cMsgErro := STR0127 //'A Data do Fim da Vigência da Linha não pode ser maior que a data de Vigência do Contrato.'
								cMsgSoluc:= STR0128 + DToC(oMdlGY0:GetValue('GY0_DTINIC')) + STR0126 + DToC(oMdlGY0:GetValue('GY0_DTVIGE'))//'Defina um fim de Vigência de Linha entre o Inicio do Contrato: '
								lRet:= .F.
							EndIf
						EndIf
						If lRet .AND. oMdlGY0:HasField('GY0_DTVORC')
							If !(oMdlGY0:GetValue('GY0_DTVORC') >= dDataBase)
								cMsgErro := STR0141 //'Verifique a data de validade do Orçamento do contrato'
								cMsgSoluc:= STR0142 //'A data deve ser maior ou igual a Data do Sistema'
								lRet := .F.
							EndIf
						EndIf
						
						If ( lRet )
							
							For nGQI := 1 to oMdlGQI:Length()
								
								If ( !(oMdlGQI:IsDeleted()) )

									lRet := WrongWay(oModel,oMdlGQI:GetValue("GQI_SENTID",nGQI),@cMsgErro,nGQI,nGYD)
									
									If (!lRet)
										cMsgSoluc := "Para Linhas de único sentido, os trechos devem possuir o mesmo sentido."
										Exit
									EndIf

								EndIf

							Next nGQI

						EndIf
						
					EndIf

					//Verificar cliente bloqueado
					If ( lRet )						
						lRet := GA900VldCli("GYDDETAIL",oModel:GetModel("GYDDETAIL"),nGYD,@cMsgErro,@cMsgSoluc)						
					EndIf
					
					If ( !lRet )
						oModel:SetErrorMessage(oMdlGYD:GetId(),cField,oMdlGYD:GetId(),cField,"PosValid",cMsgErro,cMsgSoluc)//,cNewValue,cOldValue)
						Exit
					EndIf

				EndIf	

			Next nGyd

		Else
			oModel:SetErrorMessage(oMdlGY0:GetId(),cField,oMdlGY0:GetId(),cField,"PosValid",cMsgErro,cMsgSoluc)//,cNewValue,cOldValue)
		EndIf

	EndIf

Return lRet

/*/{Protheus.doc} GYDLnPre
(long_description)
@type  Static Function
@author Teixeira
@since 01/10/2019
@version version
@param oModelGYD, param_type, param_descr
@param nLine, param_type, param_descr
@param cOperation, param_type, param_descr
@param cField, param_type, param_descr
@param uValue, param_type, param_descr
@return lRet, return_type, return_description
@example
(examples)
@see (links_or_references)
/*/
Static Function GYDLnPre(oModel, nLine, cOperation, cField, uValue)
Local lRet      := .T.
Local nCnt      := 0
Local cMsgTitu  := ""
Local cMsgErro  := ""
Local oMdl      := FwModelActive()
Local oModelGYD := oMdl:GetModel("GYDDETAIL")
Local oModelGQI := oMdl:GetModel("GQIDETAIL")
Local oModelGYX := oMdl:GetModel("GYXDETAIL")
Local oModelGQZ := oMdl:GetModel("GQZDETAIL")

IF (cOperation == "DELETE") 
    
    If oModelGQI:Length() > 0
        nCnt:= oModelGQI:Length()
		While nCnt > 0
			If !oModelGQI:IsDeleted(nCnt)
				oModelGQI:Goline(nCnt)
				oModelGQI:DeleteLine(.T.)
			EndIf
			nCnt--
		End
	EndIf
	
	If oModelGYX:Length() > 0
        For nCnt := 1 To oModelGYX:Length()
            If !oModelGYX:IsDeleted(nCnt)
                oModelGYX:Goline(nCnt)
                oModelGYX:DeleteLine(.T.)
            EndIf
        Next nCnt
	EndIf
	If oModelGQZ:Length() > 0
        For nCnt := 1 To oModelGQZ:Length()
            If !oModelGQZ:IsDeleted(nCnt)
                oModelGQZ:Goline(nCnt)
                oModelGQZ:DeleteLine(.T.)
            EndIf
        Next nCnt
	EndIf
ELSEIF (cOperation == "UNDELETE")
    
    If oModelGQI:Length() > 0
        For nCnt := 1 To oModelGQI:Length()
            If oModelGQI:IsDeleted(nCnt)
                oModelGQI:Goline(nCnt)
                oModelGQI:UnDeleteLine(.T.)
            EndIf
        Next nCnt
	EndIf
	If oModelGYX:Length() > 0
        For nCnt := 1 To oModelGYX:Length()
            If oModelGYX:IsDeleted(nCnt)
                oModelGYX:Goline(nCnt)
                oModelGYX:UnDeleteLine(.T.)
            EndIf
        Next nCnt
	EndIf
	If oModelGQZ:Length() > 0
        For nCnt := 1 To oModelGQZ:Length()
            If oModelGQZ:IsDeleted(nCnt)
                oModelGQZ:Goline(nCnt)
                oModelGQZ:UnDeleteLine(.T.)
            EndIf
        Next nCnt
	EndIf
ELSEIF (cOperation == "SETVALUE" .AND. cField == "GYD_LOCFIM")
    lRet := !(oModelGYD:SeekLine({{'GYD_LOCINI',oModelGYD:GetValue("GYD_LOCINI")},{'GYD_LOCFIM',uValue}}))
	If !lRet .AND. oModelGYD:GetLine() != nLine
		cMsgTitu := STR0027//"Linha duplicada"
		cMsgErro := STR0028//"Sequência já utilizada"
		Help(,,cMsgTitu,, cMsgErro, 1,0)
	EndIf

ENDIF

Return lRet

/*/{Protheus.doc} GQILnPre
(long_description)
@type  Static Function
@author Teixeira
@since 01/10/2019
@version version
@param oModelGYD, param_type, param_descr
@param nLine, param_type, param_descr
@param cOperation, param_type, param_descr
@param cField, param_type, param_descr
@param uValue, param_type, param_descr
@return lRet, return_type, return_description
@example
(examples)
@see (links_or_references)
/*/
Static Function GQILnPre(oModel, nLine, cOperation, cField, uValue)
Local lRet      := .T.
Local nCnt      := 0
Local nTamGrid  := 0
Local nLinhaAtu := 0
Local cMsgTitu  := ""
Local cMsgErro  := ""
Local oMdl      := FwModelActive()
Local oMdlGQI   := oMdl:GetModel("GQIDETAIL")

IF (cOperation == "DELETE") 
    
	nCnt:= oMdlGQI:Length()
	While nCnt > 1
		If !oMdlGQI:IsDeleted(nCnt)
			nTamGrid := nCnt
			EXIT
		EndIf
		nCnt--
	End
	If nLine != nTamGrid .AND. nTamGrid > 0
		lRet:= .F.
		cMsgTitu := STR0029//"Alteração indevida"
		cMsgErro := STR0030//"Não pode alterar, por não ser ultima linha."
		Help(,,cMsgTitu,, cMsgErro, 1,0)
	EndIf
ELSEIF (cOperation == "UNDELETE")
    
    nCnt:= oMdlGQI:Length()
	While nCnt > 1
		If !oMdlGQI:IsDeleted(nCnt)
			nTamGrid := nCnt
			EXIT
		EndIf
		nCnt--
	End
	If nLine != nTamGrid .AND. nTamGrid > 0 .AND. nLinhaAtu > 0
		lRet:= .F.
		cMsgTitu := STR0029//"Alteração indevida"
		cMsgErro := STR0030//"Não pode alterar, por não ser ultima linha."
		Help(,,cMsgTitu,, cMsgErro, 1,0)
	EndIf
ELSEIF (cOperation == "SETVALUE" .AND. cField == "GQI_CODDES")
    nCnt:= oMdlGQI:Length()
	While nCnt > 1
		If !oMdlGQI:IsDeleted(nCnt)
			nTamGrid := nCnt
			EXIT
		EndIf
		nCnt--
	End
	If nLine != nTamGrid .AND. nTamGrid > 0 .AND. nLinhaAtu > 0
		lRet:= .F.
		cMsgTitu := STR0029//"Alteração indevida"
		cMsgErro := STR0030//"Não pode alterar, por não ser ultima linha."
		Help(,,cMsgTitu,, cMsgErro, 1,0)
	EndIf

ENDIF

Return lRet

/*/{Protheus.doc} SetModelStruct
	(long_description)
	@type  Static Function
	@author Teixeira
	@since 18/08/2020
	@version version
	@param param_name, param_type, param_descr
	@return return_var, return_type, return_description
	@example
	(examples)
	@see (links_or_references)
	/*/
Static Function SetModelStruct(oStruGY0,oStruGYD,oStruGQJ,oStruGYX,oStruGQZ,oStruGQI,oStruGYY,oStrTot)

	Local aArea     := GetArea()
	Local aTrigAux  := {}
	Local bInit	    := {|oMdl,cField,uVal| FieldInit(oMdl,cField,uVal)}
	Local bTrig     := {|oMdl,cField,uVal| FieldTrigger(oMdl,cField,uVal)}
	Local bFldWhen	:= {|oMdl,cField,uVal| FieldWhen(oMdl,cField,uVal) } 
	Local bFldVld	:= {|oMdl,cField,uVal,nLine,uOldValue| FieldValid(oMdl,cField,uVal,nLine,uOldValue)}
	
	Local lHasFields:= .F.

	If GQZ->(FieldPos("GQZ_CODCLI")) > 0
		oStruGQZ:RemoveField("GQZ_CODCLI")
	EndIf
	If GQZ->(FieldPos("GQZ_CODLOJ")) > 0
		oStruGQZ:RemoveField("GQZ_CODLOJ")
	EndIf
	DbSelectArea("SX3")
	SX3->(dbSetOrder(2))
	If SX3->(dbSeek( "GQZ_NOMCLI"))
		oStruGQZ:RemoveField("GQZ_NOMCLI")
	EndIf

	If GY0->(FieldPos("GY0_CODVD")) > 0
		oStruGY0:AddTrigger("GY0_CODVD","GY0_CODVD",{||.T.},bTrig)	
	EndIf
	
	If GY0->(FieldPos("GY0_DTINIC")) > 0
		oStruGY0:AddTrigger("GY0_DTINIC","GY0_DTINIC",{||.T.},bTrig)	
	EndIf

	If GY0->(FieldPos("GY0_VIGE")) > 0
		oStruGY0:AddTrigger("GY0_VIGE","GY0_VIGE",{||.T.},bTrig)
	EndIf
	
	If GY0->(FieldPos("GY0_UNVIGE")) > 0
		oStruGY0:AddTrigger("GY0_UNVIGE","GY0_UNVIGE",{||.T.},bTrig)	
	EndIf

	If GY0->(FieldPos("GY0_UNORCV")) > 0
		oStruGY0:AddTrigger("GY0_UNORCV","GY0_UNORCV",{||.T.},bTrig)	
	EndIf

	If GY0->(FieldPos("GY0_VALORC")) > 0
		oStruGY0:AddTrigger("GY0_VALORC","GY0_VALORC",{||.T.},bTrig)	
	EndIf

	If GY0->(FieldPos("GY0_DTVIGE")) > 0
		oStruGY0:AddTrigger("GY0_DTVIGE","GY0_DTVIGE",{||.T.},bTrig)
	EndIf

	If GY0->(FieldPos("GY0_DTVORC")) > 0
		oStruGY0:AddTrigger("GY0_DTVORC","GY0_DTVORC",{||.T.},bTrig)
	EndIf

	If GY0->(FieldPos("GY0_ALTLOG")) > 0
		oStruGY0:SetProperty("GY0_ALTLOG", MODEL_FIELD_WHEN, bFldWhen)	
	EndIf

	If GQZ->(FieldPos("GQZ_INIVIG")) > 0
		oStruGQZ:RemoveField("GQZ_INIVIG")
	EndIf
	If GQZ->(FieldPos("GQZ_FIMVIG")) > 0
		oStruGQZ:RemoveField("GQZ_FIMVIG")
	EndIf
	If GQZ->(FieldPos("GQZ_TPDESC"))  > 0
		oStruGQZ:RemoveField("GQZ_TPDESC")
	EndIf
	If GQZ->(FieldPos("GQZ_VALOR")) > 0
		oStruGQZ:RemoveField("GQZ_VALOR")
	EndIf
	If GQZ->(FieldPos("GQZ_TIPCUS")) > 0
		oStruGQZ:RemoveField("GQZ_TIPCUS")
	EndIf

	If GY0->(FieldPos("GY0_DTINIC")) > 0
		oStruGY0:SetProperty('GY0_DTINIC',MODEL_FIELD_OBRIGAT, .T. )
	EndIf
	If GY0->(FieldPos("GY0_UNVIGE")) > 0
		oStruGY0:SetProperty('GY0_UNVIGE',MODEL_FIELD_OBRIGAT, .T. )
	EndIf
	If GY0->(FieldPos("GY0_MOEDA")) > 0
		oStruGY0:SetProperty('GY0_MOEDA' ,MODEL_FIELD_OBRIGAT, .T. )
	EndIf
	If GY0->(FieldPos("GY0_CONDPG")) > 0
		oStruGY0:SetProperty('GY0_CONDPG',MODEL_FIELD_OBRIGAT, .T. )
	EndIf
	If GY0->(FieldPos("GY0_TPCTO")) > 0
		oStruGY0:SetProperty('GY0_TPCTO' ,MODEL_FIELD_OBRIGAT, .T. )
	EndIf
	If GY0->(FieldPos("GY0_FLGREJ")) > 0
		oStruGY0:SetProperty('GY0_FLGREJ',MODEL_FIELD_OBRIGAT, .T. )
	EndIf
	If GY0->(FieldPos("GY0_FLGCAU")) > 0
		oStruGY0:SetProperty('GY0_FLGCAU',MODEL_FIELD_OBRIGAT, .T. )
	EndIf
	If GY0->(FieldPos("GY0_CLIENT")) > 0
		oStruGY0:SetProperty('GY0_CLIENT',MODEL_FIELD_OBRIGAT, .T. )
	EndIf
	If GY0->(FieldPos("GY0_LOJACL")) > 0
		oStruGY0:SetProperty('GY0_LOJACL',MODEL_FIELD_OBRIGAT, .T. )
		// oStruGY0:SetProperty('GY0_LOJACL', MODEL_FIELD_VALID, bFldVld)
	EndIf

	If GY0->(FieldPos("GY0_CODVD")) > 0
		oStruGY0:SetProperty('GY0_CODVD',MODEL_FIELD_OBRIGAT, .T. )
	EndIf
	If GY0->(FieldPos("GY0_TABPRC")) > 0
		oStruGY0:SetProperty('GY0_TABPRC',MODEL_FIELD_OBRIGAT, .T. )
	EndIf
	If GY0->(FieldPos("GY0_TIPPLA")) > 0
		oStruGY0:SetProperty('GY0_TIPPLA',MODEL_FIELD_OBRIGAT, .T. )
	EndIf
	If GY0->(FieldPos("GY0_PRODUT")) > 0
		oStruGY0:SetProperty('GY0_PRODUT',MODEL_FIELD_OBRIGAT, .T. )
	EndIf
	
	If GY0->(FieldPos("GY0_CODCN9")) > 0
		oStruGY0:SetProperty('GY0_CODCN9',MODEL_FIELD_OBRIGAT, .F. )
	EndIf

	oStruGQJ:SetProperty('*', MODEL_FIELD_OBRIGAT, .F.)
	oStruGYX:SetProperty('*', MODEL_FIELD_OBRIGAT, .F.)
	oStruGQZ:SetProperty('*', MODEL_FIELD_OBRIGAT, .F.)

	If GYD->(FieldPos("GYD_PRECON")) > 0	
		oStruGYD:SetProperty('GYD_PRECON', MODEL_FIELD_OBRIGAT, .T.)
	EndIf
	If GYD->(FieldPos("GYD_NUMCAR")) > 0
	 	oStruGYD:SetProperty('GYD_NUMCAR', MODEL_FIELD_OBRIGAT, .T.)
	EndIf

	If GY0->(FieldPos("GY0_PRODUT")) > 0
		oStruGY0:AddTrigger("GY0_PRODUT","GY0_PRODUT",{||.T.},bTrig)	
	EndIf
	
	If GY0->(FieldPos("GY0_CODVD")) > 0
		oStruGY0:AddTrigger("GY0_CODVD","GY0_CODVD",{||.T.},bTrig)	
	EndIf

	If oStruGY0:HasField("GY0_CLIENT") 
		oStruGY0:AddTrigger("GY0_CLIENT","GY0_NOMCLI",{||.T.},bTrig)	
	EndIf

	If oStruGY0:HasField("GY0_LOJACL") 
		oStruGY0:AddTrigger("GY0_LOJACL","GY0_NOMCLI",{||.T.},bTrig)	
	EndIf

	If oStruGYD:HasField("GYD_CLIENT")
		oStruGYD:AddTrigger("GYD_CLIENT","GYD_NOMCLI",{||.T.},bTrig)
	EndIf

	If oStruGYD:HasField("GYD_LOJACL") 
		oStruGYD:AddTrigger("GYD_LOJACL","GYD_NOMCLI",{||.T.},bTrig)
	EndIf

	If GYD->(FieldPos("GYD_ORGAO")) > 0
		oStruGYD:AddTrigger("GYD_ORGAO","GYD_ORGAO",{||.T.},bTrig)	
	EndIf
	If GYD->(FieldPos("GYD_LOCINI")) > 0 .AND. SX3->(dbSeek( "GYD_DLOCIN"))
		aTrigAux := FwStruTrigger("GYD_LOCINI", "GYD_DLOCIN", "Posicione('GI1',1,xFilial('GI1') + FwFldGet('GYD_LOCINI'), 'GI1_DESCRI')")
		oStruGYD:AddTrigger(aTrigAux[1],aTrigAux[2],aTrigAux[3],aTrigAux[4])	
	EndIf
	If GYD->(FieldPos("GYD_LOCFIM")) > 0 .AND. SX3->(dbSeek( "GYD_DLOCFI"))
		aTrigAux := FwStruTrigger("GYD_LOCFIM", "GYD_DLOCFI", "Posicione('GI1',1,xFilial('GI1') + FwFldGet('GYD_LOCFIM'), 'GI1_DESCRI')")
		oStruGYD:AddTrigger(aTrigAux[1],aTrigAux[2],aTrigAux[3],aTrigAux[4])	
	EndIf

	If GYD->(FieldPos("GYD_LOCFIM")) > 0
		oStruGYD:AddTrigger("GYD_LOCFIM","GYD_LOCFIM",{||.T.},bTrig)	
	EndIf
	
	If oStruGYD:HasField("GYD_TPCARR") 
		oStruGYD:AddTrigger("GYD_TPCARR","GYD_TPCARR",{||.T.},bTrig)	
	EndIf

	If GYD->(FieldPos("GYD_PRODUT")) > 0
		oStruGYD:AddTrigger("GYD_PRODUT","GYD_PRODUT",{||.T.},bTrig)	
	EndIf
	If GYD->(FieldPos("GYD_PRONOT")) > 0
		oStruGYD:AddTrigger("GYD_PRONOT","GYD_PRONOT",{||.T.},bTrig)	
	EndIf
	If GYD->(FieldPos("GYD_PRECON")) > 0
		oStruGYD:AddTrigger("GYD_PRECON","GYD_PRECON",{||.T.},bTrig)	
	EndIf

	lHasFields := GYD->(FieldPos("GYD_PLCONV")) > 0; 
		.And. GYD->(FieldPos("GYD_PRECON")) > 0;
		.And. GYD->(FieldPos("GYD_PREEXT")) > 0;
		.And. GYD->(FieldPos("GYD_IDPLCO")) > 0; 
		.And. GYD->(FieldPos("GYD_PLEXTR")) > 0;
		.And. GYD->(FieldPos("GYD_IDPLEX")) > 0
		
	If ( lHasFields )
		oStruGYD:AddTrigger("GYD_PLCONV","GYD_PLCONV",{||.T.},bTrig)	
		oStruGYD:AddTrigger("GYD_PLEXTR","GYD_PLEXTR",{||.T.},bTrig)
		//Ajuste do When dos campos
		oStruGYD:SetProperty("GYD_VLRTOT", MODEL_FIELD_WHEN, bFldWhen)
		oStruGYD:SetProperty("GYD_VLREXT", MODEL_FIELD_WHEN, bFldWhen)
		oStruGYD:SetProperty("GYD_IDPLCO", MODEL_FIELD_WHEN, bFldWhen)
		oStruGYD:SetProperty("GYD_IDPLEX", MODEL_FIELD_WHEN, bFldWhen)
		oStruGYD:SetProperty("GYD_CODGI2", MODEL_FIELD_WHEN, bFldWhen)
	EndIf

	lHasFields := GY0->(FieldPos("GY0_PLCONV")) > 0; 
					.And. GY0->(FieldPos("GY0_PREEXT")) > 0;
					.And. GY0->(FieldPos("GY0_IDPLCO")) > 0; 
					.And. GY0->(FieldPos("GY0_PRDEXT")) > 0; 
					.And. GY0->(FieldPos("GY0_PRONOT")) > 0;
					.And. GY0->(FieldPos("GY0_PLCONV")) > 0;

	If ( lHasFields )
		oStruGY0:AddTrigger("GY0_PLCONV","GY0_PLCONV",{||.T.},bTrig)
		oStruGY0:AddTrigger("GY0_PRDEXT","GY0_PRDEXT",{||.T.},bTrig)
		oStruGY0:AddTrigger("GY0_PRONOT","GY0_PRONOT",{||.T.},bTrig)
		oStruGY0:AddTrigger("GY0_PREEXT","GY0_PREEXT",{||.T.},bTrig)

		//Ajuste do When dos campos
		oStruGY0:SetProperty("GY0_IDPLCO", MODEL_FIELD_WHEN, bFldWhen)
		oStruGY0:SetProperty("GY0_VLRACO", MODEL_FIELD_WHEN, bFldWhen)
		oStruGY0:SetProperty("GY0_PREEXT", MODEL_FIELD_WHEN, bFldWhen)
		oStruGY0:SetProperty("GY0_PLCONV", MODEL_FIELD_WHEN, bFldWhen)	
	EndIf

	If GYD->(FieldPos("GYD_VLFAT1")) > 0
		oStruGYD:SetProperty("GYD_VLFAT1", MODEL_FIELD_WHEN, bFldWhen)
	Endif 

	If GYD->(FieldPos("GYD_VLFAT2")) > 0
		oStruGYD:SetProperty("GYD_VLFAT2", MODEL_FIELD_WHEN, bFldWhen)
	Endif 

	If GQJ->(FieldPos("GQJ_CUSUNI")) > 0
		oStruGQJ:AddTrigger("GQJ_CUSUNI","GQJ_CUSUNI",{||.T.},bTrig)	
	EndIf
	If GQJ->(FieldPos("GQJ_QUANT")) > 0
		oStruGQJ:AddTrigger("GQJ_QUANT","GQJ_QUANT",{||.T.},bTrig)	
	EndIf
	If GQJ->(FieldPos("GQJ_UN")) > 0
		oStruGQJ:AddTrigger("GQJ_UN","GQJ_UN",{||.T.},bTrig)	
	EndIf
	If GYX->(FieldPos("GYX_CUSUNI")) > 0
		oStruGYX:AddTrigger("GYX_CUSUNI","GYX_CUSUNI",{||.T.},bTrig)	
	EndIf
	If GYX->(FieldPos("GYX_QUANT")) > 0
		oStruGYX:AddTrigger("GYX_QUANT","GYX_QUANT",{||.T.},bTrig)	
	EndIf
	If GYX->(FieldPos("GYX_UM")) > 0
		oStruGYX:AddTrigger("GYX_UM","GYX_UM",{||.T.},bTrig)	
	EndIf
	If GQZ->(FieldPos("GQZ_CUSUNI")) > 0
		oStruGQZ:AddTrigger("GQZ_CUSUNI","GQZ_CUSUNI",{||.T.},bTrig)	
	EndIf
	If GQZ->(FieldPos("GQZ_QUANT")) > 0
		oStruGQZ:AddTrigger("GQZ_QUANT","GQZ_QUANT",{||.T.},bTrig)	
	EndIf
	If GQZ->(FieldPos("GQZ_UM")) > 0
		oStruGQZ:AddTrigger("GQZ_UM","GQZ_UM",{||.T.},bTrig)	
	EndIf
	If GQJ->(FieldPos("GQJ_CODGIM")) > 0
		oStruGQJ:AddTrigger("GQJ_CODGIM", "GQJ_CODGIM", {||.T.},bTrig)
	EndIf
	If GYX->(FieldPos("GYX_CODGIM")) > 0
		oStruGYX:AddTrigger("GYX_CODGIM", "GYX_CODGIM", {||.T.},bTrig)
	EndIf

	If GY0->(FieldPos("GY0_VLRACO")) > 0
		oStruGY0:AddTrigger("GY0_VLRACO" , "GY0_VLRACO", {||.T.},bTrig)
	EndIf

	oStruGYD:AddTrigger("GYD_VLRTOT", "GYD_VLRTOT", {||.T.},bTrig)
	oStruGYD:AddTrigger("GYD_VLREXT", "GYD_VLREXT", {||.T.},bTrig)
	oStruGYX:AddTrigger("GYX_VALTOT", "GYX_VALTOT", {||.T.},bTrig)
	oStruGQZ:AddTrigger("GQZ_VALTOT", "GQZ_VALTOT", {||.T.},bTrig)
	oStruGQJ:AddTrigger("GQJ_VALTOT", "GQJ_VALTOT", {||.T.},bTrig)
		
	If GYD->(FieldPos("GYD_PRODUT")) > 0
		oStruGYD:SetProperty('GYD_PRODUT', MODEL_FIELD_VALID, bFldVld)
	EndIf
	If GYD->(FieldPos("GYD_PRONOT")) > 0
		oStruGYD:SetProperty('GYD_PRONOT', MODEL_FIELD_VALID, bFldVld)
	EndIf

	If GYD->(FieldPos("GYD_LOCINI")) > 0
		oStruGYD:SetProperty('GYD_LOCINI', MODEL_FIELD_VALID, bFldVld)
	EndIf


	If GYD->(FieldPos("GYD_LOCFIM")) > 0
		oStruGYD:SetProperty('GYD_LOCFIM', MODEL_FIELD_VALID, bFldVld)		
	EndIf

	If GYD->(FieldPos("GYD_NUMCAR")) > 0
		oStruGYD:SetProperty('GYD_NUMCAR', MODEL_FIELD_VALID, bFldVld)
	EndIf

	If GQI->(FieldPos("GQI_CODORI")) > 0
		oStruGQI:AddTrigger("GQI_CODORI","GQI_CODORI",{||.T.},bTrig)	
	EndIf

	If GQI->(FieldPos("GQI_CODDES")) > 0
		oStruGQI:AddTrigger("GQI_CODDES","GQI_CODDES",{||.T.},bTrig)	
	EndIf

	If GQI->(FieldPos("GQI_CODDES")) > 0
		oStruGQI:SetProperty('GQI_CODDES', MODEL_FIELD_VALID, bFldVld)
	EndIf

	If GQJ->(FieldPos("GQJ_CODGIM")) > 0
		oStruGQJ:SetProperty('GQJ_CODGIM', MODEL_FIELD_VALID, bFldVld)
	EndIf

	If GYX->(FieldPos("GYX_CODGIM")) > 0
		oStruGYX:SetProperty('GYX_CODGIM', MODEL_FIELD_VALID, bFldVld)
	EndIf

	If GY0->(FieldPos("GY0_PRODUT")) > 0
		oStruGY0:SetProperty('GY0_PRODUT', MODEL_FIELD_VALID, bFldVld)
	EndIf

	If GY0->(FieldPos("GY0_VLRACO")) > 0
		oStruGY0:SetProperty('GY0_VLRACO', MODEL_FIELD_VALID, bFldVld)
	EndIf

	If GY0->(FieldPos("GY0_TPCTO")) > 0
		oStruGY0:SetProperty('GY0_TPCTO', MODEL_FIELD_VALID, bFldVld)
	EndIf

	If GY0->(FieldPos("GY0_TIPPLA")) > 0
		oStruGY0:SetProperty('GY0_TIPPLA', MODEL_FIELD_VALID, bFldVld)
	EndIf

	If GY0->(FieldPos("GY0_TIPREV")) > 0
		oStruGY0:SetProperty('GY0_TIPREV', MODEL_FIELD_VALID, bFldVld)
	EndIf

	If GY0->(FieldPos("GY0_REVISA")) > 0
		oStruGY0:SetProperty("GY0_REVISA" , MODEL_FIELD_INIT, bInit)
	EndIf

	If oStruGY0:HasField("GY0_NOMCLI") 
		oStruGY0:SetProperty("GY0_NOMCLI" , MODEL_FIELD_INIT, bInit)
	EndIf

	If oStruGYD:HasField("GYD_NOMCLI") 
		oStruGYD:SetProperty("GYD_NOMCLI"	, MODEL_FIELD_INIT,FwBuildFeature(STRUCT_FEATURE_INIPAD,'IIF(INCLUI, "",POSICIONE("SA1",1,XFILIAL("SA1") + GYD->GYD_CLIENT + GYD->GYD_LOJACL , "A1_NOME"))'))
	EndIf

	If oStruGY0:HasField("GY0_NOMVD") 
		oStruGY0:SetProperty("GY0_NOMVD" , MODEL_FIELD_INIT, bInit)
	EndIf

	If GY0->(FieldPos("GY0_ATIVO")) > 0
		oStruGY0:SetProperty("GY0_ATIVO" , MODEL_FIELD_INIT, bInit)
	EndIf
	If GYD->(FieldPos("GYD_NUMERO")) > 0
		oStruGYD:SetProperty("GYD_NUMERO" , MODEL_FIELD_INIT, bInit)
	EndIf
	If GYD->(FieldPos("GYD_REVISA")) > 0
		oStruGYD:SetProperty("GYD_REVISA" , MODEL_FIELD_INIT, bInit)
	EndIf

	If GYD->(FieldPos("GYD_NUMCAR")) > 0
		oStruGYD:SetProperty("GYD_NUMCAR" , MODEL_FIELD_INIT, bInit)
	EndIf
	
	If oStruGYD:HasField("GYD_DTIPLI") 
		oStruGYD:SetProperty("GYD_DTIPLI"	, MODEL_FIELD_INIT,FwBuildFeature(STRUCT_FEATURE_INIPAD,'IIF(INCLUI, "",POSICIONE("GQC",1,XFILIAL("GQC") + GYD->GYD_TIPLIN , "GQC_DESCRI"))'))

	EndIf

	If oStruGYD:HasField("GYD_TIPLIN") 
		oStruGYD:AddTrigger("GYD_TIPLIN","GYD_TIPLIN",{||.T.},bTrig)	
	EndIf
	
	If oStruGYD:HasField("GYD_ORGAO") .And. oStruGYD:HasField("GYD_TIPLIN")
		aTrigAux := FwStruTrigger("GYD_ORGAO", "GYD_TIPLIN", "''")
		oStruGYD:AddTrigger(aTrigAux[1],aTrigAux[2],aTrigAux[3],aTrigAux[4])
	EndIf

	If oStruGYD:HasField("GYD_ORGAO") .And. oStruGYD:HasField("GYD_DTIPLI")
		aTrigAux := FwStruTrigger("GYD_ORGAO", "GYD_DTIPLI", "''")
		oStruGYD:AddTrigger(aTrigAux[1],aTrigAux[2],aTrigAux[3],aTrigAux[4])
	EndIf

	If oStruGYD:HasField("GYD_DTIPLI") .And. oStruGYD:HasField("GYD_TPCARR")
		aTrigAux := FwStruTrigger("GYD_DTIPLI", "GYD_TPCARR", "''")
		oStruGYD:AddTrigger(aTrigAux[1],aTrigAux[2],aTrigAux[3],aTrigAux[4])
	EndIf

	If oStruGYD:HasField("GYD_DTIPLI") .And. oStruGYD:HasField("GYD_DESCAT")
		aTrigAux := FwStruTrigger("GYD_DTIPLI", "GYD_DESCAT", "''")
		oStruGYD:AddTrigger(aTrigAux[1],aTrigAux[2],aTrigAux[3],aTrigAux[4])
	EndIf

	If oStruGYD:HasField("GYD_DESCAT") 
		oStruGYD:SetProperty("GYD_DESCAT"	, MODEL_FIELD_INIT,FwBuildFeature(STRUCT_FEATURE_INIPAD,'IIF(INCLUI, "", POSICIONE("GYR", 1, XFILIAL("GYR") + GYD->GYD_TPCARR, "GYR_DESCRI"))'))
	EndIf

	If GQZ->(FieldPos("GQZ_CODIGO")) > 0
		oStruGQZ:SetProperty("GQZ_CODIGO" , MODEL_FIELD_INIT, bInit)
	EndIf
	If GYY->(FieldPos("GYY_NUMERO")) > 0
		oStruGYY:SetProperty("GYY_NUMERO" , MODEL_FIELD_INIT, bInit)
	EndIf
	If GYY->(FieldPos("GYY_PERGYD")) > 0
		oStruGYY:SetProperty("GYY_PERGYD" , MODEL_FIELD_INIT, bInit)
	EndIf
	If GYY->(FieldPos("GYY_PERGQJ")) > 0
		oStruGYY:SetProperty("GYY_PERGQJ" , MODEL_FIELD_INIT, bInit)
	EndIf
	If GYY->(FieldPos("GYY_PERGYX")) > 0
		oStruGYY:SetProperty("GYY_PERGYX" , MODEL_FIELD_INIT, bInit)
	EndIf
	If GYY->(FieldPos("GYY_PERGQZ")) > 0
		oStruGYY:SetProperty("GYY_PERGQZ" , MODEL_FIELD_INIT, bInit)
	EndIf

	If GQZ->(FieldPos("GQZ_REVISA")) > 0
		oStruGQZ:SetProperty("GQZ_REVISA" , MODEL_FIELD_INIT, bInit)
	EndIf
	If GQI->(FieldPos("GQI_CODIGO")) > 0
		oStruGQI:SetProperty("GQI_CODIGO" , MODEL_FIELD_INIT, bInit)
	EndIf
	If GQI->(FieldPos("GQI_REVISA")) > 0
		oStruGQI:SetProperty("GQI_REVISA" , MODEL_FIELD_INIT, bInit)
	EndIf
	If GYY->(FieldPos("GYY_REVISA")) > 0
		oStruGYY:SetProperty("GYY_REVISA" , MODEL_FIELD_INIT, bInit)
	EndIf

	If GYX->(FieldPos("GYX_CODIGO")) > 0
		oStruGYX:SetProperty("GYX_CODIGO" , MODEL_FIELD_INIT, bInit)
	EndIf
	If GYX->(FieldPos("GYX_REVISA")) > 0
		oStruGYX:SetProperty("GYX_REVISA" , MODEL_FIELD_INIT, bInit)
	EndIf
	If GQI->(FieldPos("GQI_ITEM")) > 0
		oStruGQI:SetProperty("GQI_ITEM" , MODEL_FIELD_INIT, bInit)
	EndIf
	If GYX->(FieldPos("GYX_ITEM")) > 0
		oStruGYX:SetProperty("GYX_ITEM" , MODEL_FIELD_INIT, bInit)
	EndIf
	If GQZ->(FieldPos("GQZ_ITEM")) > 0
		oStruGQZ:SetProperty("GQZ_ITEM" , MODEL_FIELD_INIT, bInit)
	EndIf
	If GY0->(FieldPos("GY0_MOEDA")) > 0
		oStruGY0:SetProperty("GY0_MOEDA" , MODEL_FIELD_INIT, bInit)
	EndIf
	If GQJ->(FieldPos("GQJ_CODIGO")) > 0
		oStruGQJ:SetProperty("GQJ_CODIGO" , MODEL_FIELD_INIT, bInit)
	EndIf
	If GQJ->(FieldPos("GQJ_REVISA")) > 0
		oStruGQJ:SetProperty("GQJ_REVISA" , MODEL_FIELD_INIT, bInit)
	EndIf

	If GY0->(FieldPos("GY0_TIPREV")) > 0
		oStruGY0:SetProperty("GY0_TIPREV", MODEL_FIELD_WHEN, bFldWhen)
	EndIf

	If GYD->(FieldPos("GYD_VLRACO")) > 0
		oStruGYD:SetProperty("GYD_VLRACO", MODEL_FIELD_WHEN, bFldWhen)
	EndIf

	If GYD->(FieldPos("GYD_PRODUT")) > 0
		oStruGYD:SetProperty("GYD_PRODUT", MODEL_FIELD_WHEN, bFldWhen)
	EndIf

	If GYD->(FieldPos("GYD_PRONOT")) > 0
		oStruGYD:SetProperty("GYD_PRONOT", MODEL_FIELD_WHEN, bFldWhen)
	EndIf

	If ValType(oStrTot) == "O"
		oStrTot:AddField(STR0051   ,STR0051 ,"TOTADIC"	,"N",09,2,Nil,Nil,Nil,.F.,NIL,.F.,.F.,.T.)//"Adicional" 
   	 	oStrTot:AddField(STR0052   ,STR0052 ,"TOTOPE"	,"N",09,2,Nil,Nil,Nil,.F.,NIL,.F.,.F.,.T.) //"Operacional" 
		oStrTot:AddField(STR0053   ,STR0053 ,"TOTLINHA"	,"N",09,2,Nil,Nil,Nil,.F.,NIL,.F.,.F.,.T.) //"Total"
		oStrTot:AddField(STR0054   ,STR0054 ,"VLRITEM"	,"N",09,2,Nil,Nil,Nil,.F.,NIL,.F.,.F.,.T.) //"Vlr. Item"
		oStrTot:AddField(STR0055   ,STR0055 ,"VLREXTRA"	,"N",09,2,Nil,Nil,Nil,.F.,NIL,.F.,.F.,.T.) //"Extra"
	Endif   
	
	If GQI->(FieldPos("GQI_SENTID")) > 0
		oStruGQI:SetProperty("GQI_SENTID", MODEL_FIELD_WHEN, bFldWhen)	
		oStruGQI:SetProperty("GQI_SENTID", MODEL_FIELD_INIT, bInit)	
		oStruGQI:SetProperty("GQI_SENTID" , MODEL_FIELD_VALID, bFldVld)

	EndIf
	
	If GYD->(FieldPos("GYD_LOTACA")) > 0
		oStruGYD:SetProperty("GYD_LOTACA",MODEL_FIELD_OBRIGAT,.T.)
	EndIF

	If GYD->(FieldPos("GYD_CODGI2")) > 0
		oStruGYD:SetProperty("GYD_CODGI2",MODEL_FIELD_VALID, bFldVld)
	EndIF

	oStruGYD:SetProperty('GYD_PRODUT',MODEL_FIELD_OBRIGAT, .F. )

	oStruGY0:AddField( 	STR0200,;// [01] C Titulo do campo //"Rateio Prod."
						STR0201,;// [02] C ToolTip do campo //"Rateio de Produtos"    
						"GY0_RATEIO",;// [03] C identificador (ID) do Field
						"C",;// [04] C Tipo do campo
						1,;// [05] N Tamanho do campo
						0,;// [06] N Decimal do campo
						{|| .T.},;// [07] B Code-block de validação do campo
						NIL,;// [08] B Code-block de validação When do campo
						Nil,;// [09] A Lista de valores permitido do campo --> "1=Venda"##"2=Reembolso"##"3=Ambos"
						.F.,;// [10] L Indica se o campo tem preenchimento obrigatório
						bInit,;// [11] B Code-block de inicializacao do campo
						NIL,;// [12] L Indica se trata de um campo chave
						NIL,;// [13] L Indica se o campo pode receber valor em uma operação de update.
						.T. )// [14] L Indica se o campo é virtual


	oStruGYD:AddField( 	STR0200,;// [01] C Titulo do campo //"Rateio Prod."
						STR0201,;// [02] C ToolTip do campo //"Rateio de Produtos" 
						"GYD_RATEIO",;// [03] C identificador (ID) do Field
						"C",;// [04] C Tipo do campo
						1,;// [05] N Tamanho do campo
						0,;// [06] N Decimal do campo
						{|| .T.},;// [07] B Code-block de validação do campo
						NIL,;// [08] B Code-block de validação When do campo
						Nil,;// [09] A Lista de valores permitido do campo --> "1=Venda"##"2=Reembolso"##"3=Ambos"
						.F.,;// [10] L Indica se o campo tem preenchimento obrigatório
						bInit,;// [11] B Code-block de inicializacao do campo
						NIL,;// [12] L Indica se trata de um campo chave
						NIL,;// [13] L Indica se o campo pode receber valor em uma operação de update.
						.T. )// [14] L Indica se o campo é virtual

RestArea(aArea)
Return 

/*/{Protheus.doc} FieldInit
(long_description)
@type  Static Function
@author Teixeira
@since 24/07/2020
@version 1
@param oMdl, object, modelo
@param cField, caracter, campo
@return uRet, return_type, return_description
@example
(examples)
@see (links_or_references)
/*/
Static Function FieldInit(oMdl,cField,uVal)

	Local uRet      := nil
	Local oModel	:= oMdl:GetModel()
	Local oModelGY0 := oModel:GetModel('GY0MASTER')
	Local lInsert	:= oModel:GetOperation() == MODEL_OPERATION_INSERT
	Local lRevisa	:= oModel:GetOperation() == 4
	Local aArea     := GetArea()
	Local oModelGYD := oModel:GetModel("GYDDETAIL")
	Local nLineGYD  := oModelGYD:GetLine()

	Do Case
	Case cField == "GY0_NUMERO"
		If lInsert
			uRet := GETSXENUM("GY0","GY0_NUMERO")
		ElseIf lRevisa
			uRet := GY0->GY0_NUMERO
		Endif
	Case cField == "GY0_REVISA" 
		If lRevisa
			uRet := SetRevisao(oModel)
		Else
			uRet := ''
		Endif
	Case cField == "GY0_NOMCLI"
			uRet := oModelGY0:GetValue("GY0_CLIENT") + oModelGY0:GetValue("GY0_LOJACL") 
			uRet := IIF(INCLUI, "", POSICIONE("SA1", 1, XFILIAL("SA1") + uRet , "A1_NOME") )
	Case cField == "GY0_NOMVD"
			uRet := oModelGY0:GetValue("GY0_CODVD")
			uRet := IIF(INCLUI, "", POSICIONE("SA3",1,XFILIAL("SA3") + uRet, "A3_NOME") )
	Case cField $ "GYD_REVISA|GQI_REVISA|GYX_REVISA|GQZ_REVISA|GQJ_REVISA|GYY_REVISA"
		uRet := oModelGY0:GetValue('GY0_REVISA') 
		If cField == 'GYD_REVISA' .And. lRevisa
			oModel:LoadValue('GYYFIELDS','GYY_PERGYD', 0)
			oModel:LoadValue('GYYFIELDS','GYY_PERGQJ', 0)
			oModel:LoadValue('GYYFIELDS','GYY_PERGYX', 0)
			oModel:LoadValue('GYYFIELDS','GYY_PERGQZ', 0)
		Endif
	Case cField $ "GYD_NUMERO|GQZ_CODIGO|GQI_CODIGO|GQJ_CODIGO|GYX_CODIGO|GYY_NUMERO"
		uRet := If(lInsert,FwFldGet("GY0_NUMERO"),GY0->GY0_NUMERO)
	Case cField == 'GY0_ATIVO' .And. (lInsert .Or. lRevisa)
		uRet := '1'
	Case cField == "GQI_ITEM"
		uRet := oModelGYD:GetValue("GYD_CODGYD",nLineGYD)
	Case cField == "GYX_ITEM"
		uRet := oModelGYD:GetValue("GYD_CODGYD",nLineGYD)
	Case cField == "GQZ_ITEM"
		uRet := oModelGYD:GetValue("GYD_CODGYD",nLineGYD)
	Case cField == "GY0_MOEDA"
		uRet := "1"
	Case cField $ "GYY_PERGYD|GYY_PERGQJ|GYY_PERGYX|GYY_PERGQZ"
		uRet := 0
	Case cField == 'GYD_NUMCAR'
		uRet := 1
	Case cField == 'GQI_SENTID'
		uRet := ''
	Case cField == 'GY0_RATEIO'
		If !lInsert
			If RateioPrd(GY0->GY0_CLIENT,GY0->GY0_LOJACL)
				uRet := "1"
			Else
				uRet := "2"
			Endif
		Else
			uRet := "2"
		Endif
	Case cField == 'GYD_RATEIO'
		If !lInsert
			If RateioPrd(GYD->GYD_CLIENT,GYD->GYD_LOJACL)
				uRet := "1"
			Else
				uRet := "2"
			Endif
		Else
			uRet := "2"
		Endif
	EndCase

	RestArea(aArea)

Return uRet

/*/{Protheus.doc} FieldTrigger
//TODO Descrição auto-gerada.
@author Teixeira
@since 14/08/2019
@version 1.0
@return ${return}, ${return_description}
@param oMdl, object, descricao
@param cField, characters, descricao
@param uVal, undefined, descricao
@type function
/*/
Static Function FieldTrigger(oMdl,cField,uVal)

	Local uRet     	:= ""
	
	Local oModel   	:= FwModelActive()
	Local oMdlGY0  	:= oModel:GetModel('GY0MASTER')
	Local oMdlGYD  	:= oModel:GetModel('GYDDETAIL')
	Local oMdlGQJ  	:= oModel:GetModel('GQJDETAIL')
	Local oMdlGYX  	:= oModel:GetModel('GYXDETAIL')
	Local oMdlGQI  	:= oModel:GetModel("GQIDETAIL")
	Local oMdlGQZ  	:= oModel:GetModel("GQZDETAIL")
	
	Local cCliente	:= ""
	Local cLoja		:= ""

	Local n1      	:= 0
	Local nLineGYD	:= oMdlGYD:GetLine()
	Local nLineGQI	:= oMdlGQI:GetLine()
	Local nLineGQJ	:= oMdlGQJ:GetLine()
	Local nLineGYX	:= oMdlGYX:GetLine()
	Local nLineGQZ	:= oMdlGQZ:GetLine()

	Private cG900AltLog := ''

	DbSelectArea("SX3")
	SX3->(dbSetOrder(2))

	uRet := uVal

Do Case
	Case cField == "GY0_PRODUT"
		If SX3->(dbSeek( "GY0_DSCPRD"))
			oMdlGY0:SetValue("GY0_DSCPRD", POSICIONE("SB1",1,XFILIAL("SB1") + uVal,"B1_DESC"))
		EndIf
	Case cField == 'GYD_LOCFIM'
		uRet := oMdlGYD:GetValue("GYD_LOCINI")
		oMdlGYD:GoLine(nLineGYD)
		If nLineGQI > 1
			For n1	:= 1 to oMdlGQI:Length()
				If !oMdlGQI:IsDeleted(n1)
					oMdlGQI:GoLine(n1)
					oMdlGQI:Deleteline()
				Endif
			Next
		EndIf
		If nLineGQI != 1
			oMdlGQI:AddLine()
		EndIf
        oMdlGQI:SetValue('GQI_CODORI',uRet)
		oMdlGQI:SetValue('GQI_CODDES',uVal)

	Case cField $ "GY0_LOJACL|GY0_CLIENT"

		If ( cField == "GY0_CLIENT" )
			cCliente	:= uVal
			cLoja		:= oMdlGY0:GetValue('GY0_LOJACL')
		Else
			cCliente	:= oMdlGY0:GetValue('GY0_CLIENT')
			cLoja		:= uVal
		EndIf

		uRet := POSICIONE("SA1", 1, XFILIAL("SA1") + cCliente + cLoja, "A1_NOME")
		
		If RateioPrd(cCliente,cLoja) //se houver rateio limpar os campos
			oMdlGY0:SetValue("GY0_RATEIO", "1")
		Else
			oMdlGY0:SetValue("GY0_RATEIO", "2")
		Endif
	Case cField $ "GYD_LOJACL|GYD_CLIENT"

		If ( cField == "GYD_CLIENT" )
			cCliente	:= uVal
			cLoja		:= oMdlGYD:GetValue('GYD_LOJACL')
		Else
			cCliente	:= oMdlGYD:GetValue('GYD_CLIENT')
			cLoja		:= uVal
		EndIf

		uRet := POSICIONE("SA1", 1, XFILIAL("SA1") + cCliente + cLoja, "A1_NOME")		

		If RateioPrd(cCliente,cLoja) //se houver rateio limpar os campos
			If GYD->(FieldPos("GYD_PRODUT")) > 0
				oMdlGYD:SetValue("GYD_PRODUT", "")
			EndIf
			If GYD->(FieldPos("GYD_PRONOT")) > 0
				oMdlGYD:SetValue("GYD_PRONOT", "")
			EndIf
			oMdlGYD:SetValue("GYD_RATEIO", "1")
		Else
			oMdlGYD:SetValue("GYD_RATEIO", "2")
		Endif
	Case cField == 'GQJ_CODGIM'
		TrigGIMPrd(oMdlGQJ, oMdlGY0:GetValue('GY0_PRODUT'), uVal)
	Case cField == 'GYX_CODGIM'
		TrigGIMPrd(oMdlGYX, oMdlGYD:GetValue('GYD_PRODUT'), uVal)
	Case cField = "GQJ_CUSUNI"
		uRet := oMdlGQJ:GetValue('GQJ_CUSUNI',nLineGQJ) * oMdlGQJ:GetValue('GQJ_QUANT',nLineGQJ)
		oMdlGQJ:SetValue('GQJ_VALTOT',uRet)
	Case cField = "GQJ_QUANT"
		uRet := oMdlGQJ:GetValue('GQJ_CUSUNI',nLineGQJ) * oMdlGQJ:GetValue('GQJ_QUANT',nLineGQJ)
		oMdlGQJ:SetValue('GQJ_VALTOT',uRet)
	Case cField = "GYX_CUSUNI"
		uRet := oMdlGYX:GetValue('GYX_CUSUNI',nLineGYX) * oMdlGYX:GetValue('GYX_QUANT',nLineGYX)
		oMdlGYX:SetValue('GYX_VALTOT',uRet)
	Case cField = "GYX_QUANT"
		uRet := oMdlGYX:GetValue('GYX_CUSUNI',nLineGYX) * oMdlGYX:GetValue('GYX_QUANT',nLineGYX)
		oMdlGYX:SetValue('GYX_VALTOT',uRet)
	Case cField = "GQZ_CUSUNI"
		uRet := oMdlGQZ:GetValue('GQZ_CUSUNI',nLineGQZ) * oMdlGQZ:GetValue('GQZ_QUANT',nLineGQZ)
		oMdlGQZ:SetValue('GQZ_VALTOT',uRet)
	Case cField = "GQZ_QUANT"
		uRet := oMdlGQZ:GetValue('GQZ_CUSUNI',nLineGQZ) * oMdlGQZ:GetValue('GQZ_QUANT',nLineGQZ)
		oMdlGQZ:SetValue('GQZ_VALTOT',uRet)
	Case cField == "GQJ_UN"
		oMdlGQJ:SetValue('GQJ_DESCUN',POSICIONE("SAH",1,XFILIAL("SAH")+uVal,"AH_UMRES"))
	Case cField == "GYX_UM"
		oMdlGYX:SetValue('GYX_DESUM',POSICIONE("SAH",1,XFILIAL("SAH")+uVal,"AH_UMRES"))
	Case cField == "GQZ_UM"
		oMdlGQZ:SetValue('GQZ_DESUM',POSICIONE("SAH",1,XFILIAL("SAH")+uVal,"AH_UMRES"))
	Case cField == "GYD_PRODUT"
		If GYD->(FieldPos("GYD_PRONOT")) > 0
			oMdlGYD:SetValue("GYD_PRONOT", uVal)
		EndIf
		If SX3->(dbSeek( "GYD_DSCPRD"))
			oMdlGYD:SetValue("GYD_DSCPRD", POSICIONE("SB1",1,XFILIAL("SB1") + uVal,"B1_DESC"))
		EndIf
	Case cField == "GYD_PRONOT"
		If SX3->(dbSeek( "GYD_DPRDNF"))
			oMdlGYD:SetValue("GYD_DPRDNF", POSICIONE("SB1",1,XFILIAL("SB1") + uVal,"B1_DESC"))
		EndIf
	Case cField == "GYD_ORGAO"
		If SX3->(dbSeek( "GYD_DORGAO"))
			oMdlGYD:SetValue("GYD_DORGAO", POSICIONE("GI0", 1, XFILIAL("GI0") + uVal, "GI0_DESCRI"))
		EndIf
	Case cField == "GYD_PRECON" 
		If GYD->(FieldPos('GYD_VLRACO')) > 0 .And. oMdlGYD:GetValue("GYD_PRECON") == '1'
			oMdlGYD:LoadValue("GYD_VLRACO", 0)
		Endif
	Case cField == 'GYD_TPCARR'
		If oMdlGYD:HasField("GYD_DESCAT") 
			oMdlGYD:SetValue("GYD_DESCAT", POSICIONE("GYR", 1, XFILIAL("GYK") + uVal, "GYR_DESCRI"))
		EndIf
	Case ( cField == "GYD_PLCONV" )
		
		If ( uVal == "1" )
			oMdlGYD:LoadValue("GYD_VLRTOT", 0)	
		Else
			oMdlGYD:LoadValue("GYD_IDPLCO", "")	
			If  GYD->(FieldPos("GYD_VLFAT1")) > 0
				oMdlGYD:LoadValue("GYD_VLFAT1", 0)	
			EndIf 
		EndIf

	Case ( cField == "GYD_PLEXTR" )

		If ( uVal == "1" )
			oMdlGYD:LoadValue("GYD_VLREXT", 0)				
		Else
			oMdlGYD:LoadValue("GYD_IDPLEX", "")	
			If  GYD->(FieldPos("GYD_VLFAT2")) > 0
				oMdlGYD:LoadValue("GYD_VLFAT2", 0)	
			EndIf 			
		EndIf
	Case ( cField == "GY0_PLCONV" )
		
		If ( uVal == "1" )
			oMdlGY0:LoadValue("GY0_VLRACO", 0)	
		Else
			oMdlGY0:LoadValue("GY0_IDPLCO", "")	
			oMdlGY0:LoadValue("GY0_PREEXT", "")	
		EndIf
	Case ( cField == "GY0_VLRACO" )
		If ( uVal > 0 )
			oMdlGY0:LoadValue("GY0_PLCONV", '')	
			oMdlGY0:LoadValue("GY0_IDPLCO", '')	
		EndIf
	Case cField == "GY0_PRDEXT"
		If GY0->(FieldPos("GY0_PRONOT")) > 0
			oMdlGY0:SetValue("GY0_PRONOT", uVal)
		EndIf
		oMdlGY0:SetValue("GY0_PRDDSC", POSICIONE("SB1",1,XFILIAL("SB1") + uVal,"B1_DESC"))
	Case cField == "GY0_PRONOT"
		If GY0->(FieldPos("GY0_PRONOT")) > 0
			oMdlGY0:SetValue("GY0_DPRDNF", POSICIONE("SB1",1,XFILIAL("SB1") + uVal,"B1_DESC"))
		EndIf		
	Case cField == "GY0_CODVD"
		If oMdlGY0:HasField("GY0_NOMVD")  
			oMdlGY0:SetValue("GY0_NOMVD", POSICIONE("SA3",1,XFILIAL("SA3") + uVal,"A3_NOME"))
		EndIf	
	Case cField $ "GY0_DTINIC|GY0_UNVIGE|GY0_VIGE"
		If cField == 'GY0_UNVIGE' .And. uVal == '4'
			oMdlGY0:LoadValue("GY0_VIGE",0)
		EndIf
		If GY0->(FieldPos("GY0_DTVIGE")) > 0 .AND. !(Empty(oMdlGY0:GetValue("GY0_DTINIC")) .AND. Empty(oMdlGY0:GetValue("GY0_UNVIGE")))
			oMdlGY0:LoadValue("GY0_DTVIGE",G900DtFim(oMdlGY0:GetValue("GY0_UNVIGE"),oMdlGY0:GetValue("GY0_DTINIC"),oMdlGY0:GetValue("GY0_VIGE")))
		EndIf	
	Case cField $ "GY0_VALORC|GY0_UNORCV"
		If cField == 'GY0_UNORCV' .And. uVal == '4'
			oMdlGY0:LoadValue("GY0_VALORC",0)
			oMdlGY0:LoadValue("GY0_DTVORC",G900DtFim(oMdlGY0:GetValue("GY0_UNORCV"),dDataBase,0))
		Else
			If GY0->(FieldPos("GY0_DTVORC")) > 0 .AND. (!(Empty(oMdlGY0:GetValue("GY0_VALORC")) .AND. Empty(oMdlGY0:GetValue("GY0_UNORCV")).OR. oMdlGY0:GetValue("GY0_UNORCV")  == '4'))
				oMdlGY0:LoadValue("GY0_DTVORC",G900DtFim(oMdlGY0:GetValue("GY0_UNORCV"),dDataBase,oMdlGY0:GetValue("GY0_VALORC")))
			EndIf
		EndIf
		If !Empty(GY0->GY0_DTVORC)
			If oMdlGY0:GetOperation() == 4 
				cG900AltLog := GY0->GY0_ALTLOG
				oMdlGY0:LoadValue("GY0_ALTLOG", "Usuario da Alteração:" + cUserName + ";Data_Orçamento_Anterior:" + DtoC(GY0->GY0_DTVORC) + ";Alterado:" + FwTimeStamp(2) + CRLF + cG900AltLog)
			EndIf
		Else
			oMdlGY0:LoadValue("GY0_ALTLOG", "Usuario da Alteração:" + cUserName + ";Data_Orçamento_Anterior:" + DtoC(GY0->GY0_DTVORC) + ";Alterado:" + FwTimeStamp(2) + CRLF + cG900AltLog)
		EndIf
	Case cField == "GY0_DTVIGE"	
			oMdlGY0:LoadValue("GY0_VIGE",0)
			oMdlGY0:LoadValue("GY0_UNVIGE",'')
	Case cField == "GY0_DTVORC"	
		If !Empty(GY0->GY0_DTVORC)
			If oMdlGY0:GetOperation() == 4 
				cG900AltLog := GY0->GY0_ALTLOG
				oMdlGY0:LoadValue("GY0_ALTLOG", "Usuario:" + cUserName + ";Data_Orçamento_Anterior:" + DtoC(GY0->GY0_DTVORC) + ";Alterado:" + FwTimeStamp(2) + CRLF + cG900AltLog)
				oMdlGY0:LoadValue("GY0_VALORC",0)
				oMdlGY0:LoadValue("GY0_UNORCV",'')
			EndIf
		Else
			oMdlGY0:LoadValue("GY0_ALTLOG", cG900AltLog + CRLF + "Usuario:" + cUserName + ";Data_Orçamento_Anterior:" + DtoC(GY0->GY0_DTVORC) + ";Alterado:" + FwTimeStamp(2) )
			oMdlGY0:LoadValue("GY0_VALORC",0)
			oMdlGY0:LoadValue("GY0_UNORCV",'')
		EndIf
	Case cField == "GQI_CODORI"
		oMdlGQI:SetValue("GQI_DESORI",POSICIONE("GI1",1,XFILIAL("GI1") + uVal,"GI1_DESCRI"))
	Case cField == "GQI_CODDES"
		oMdlGQI:SetValue("GQI_DESDES",POSICIONE("GI1",1,XFILIAL("GI1") + uVal,"GI1_DESCRI"))
	Case cField == "GYD_TIPLIN"
		oMdlGYD:SetValue("GYD_DTIPLI",POSICIONE("GQC",1,XFILIAL("GQC") + uVal,"GQC_DESCRI"))

EndCase

Return uRet

/*/{Protheus.doc} FieldValid
(long_description)
@type  Static Function
@author Teixeira
@since 25/09/2019
@version 1.0
@param oMdl, objeto, Modelo 
@param cField, caracter, Campo
@param uVal, undefined, Modelo
@param nLine, numerico, Modelo
@param uOldValue, undefined, Modelo
@return uRet, undefined, Valor de retorno
@example
(examples)
@see (links_or_references)
/*/
Static Function FieldValid(oMdl,cField,uVal,nLine,uOldValue)

	Local lRet      := .T.
	
	Local cMsgErro  := ""
	Local cMsgSolu  := ""
	Local cMsgTitu  := ""
	
	Local oModel    := oMdl:GetModel()
	Local oMdlGYD   := oModel:GetModel("GYDDETAIL")
	Local oMdlGQI   := oModel:GetModel("GQIDETAIL")
	
	Local nCnt      := 0
	Local nTamGrid  := 0
	Local nLinhaAtu := 0
	
	Local aAreaAux  := {}
	
	Do Case 
		Case cField $ 'GYD_PRODUT|GYD_PRONOT|GY0_PRODUT|GY0_PRONOT|GY0_PRDEXT'
			If !Empty(uVal)
				aAreaAux := SB1->(GetArea())
				SB1->(DbSetOrder(1))//B1_FILIAL+B1_COD
				If !SB1->(DbSeek(xFilial('SB1')+uVal))
					lRet	:= .F.
					cMsgTitu:= STR0033//"Produto não encontrado"
					cMsgErro:= STR0034//"Selecione algum produto que exista"
					
				ElseIf !RegistroOk("SB1")
					lRet	:= .F.
					cMsgTitu:= STR0035//"Produto informado se encontra bloqueado" 
					cMsgErro:= STR0036//"Informe um produto valido"
					
				ElseIf SB1->B1_TIPO <> "SV"
					lRet	:= .F.
					cMsgTitu:= STR0037//"Tipo de Produto inválido."
					cMsgErro:= STR0038//"O tipo do produto de ser do tipo serviço 'SV'"

				ElseIf EMPTY(SB1->B1_TS)
					lRet := .F.
					cMsgTitu:= STR0079 //'Produto sem TES'
					cMsgErro:= STR0080 //'O campo TES do produto não foipreenchido.'
				Endif 

				RestArea(aAreaAux)
			Endif
		Case cField == 'GYD_NUMCAR'
			If uVal < 1
				cMsgTitu := STR0113 //'Quantidade Minima de Onibus por Viagem'
				cMsgErro := STR0114 //'Não é possível ter menos que um ônibus por viagem.'
				lRet := .F.
			EndIf

		Case cField $ 'GYD_LOCFIM|GYD_LOCINI'
			If nLine > 0
				If oMdlGYD:GetValue('GYD_LOCFIM',nLine) == oMdlGYD:GetValue('GYD_LOCINI',nLine) 
					cMsgTitu := STR0153 //'Localização Inicial / Localização Final'
					cMsgErro := STR0154 //'A Localização Inicial não pode ser Igual a Localização Final '
					lRet := .F.
				EndIf
		
			EndIf
			
		Case cField == 'GQI_CODDES'
			nLinhaAtu:= oMdlGQI:GetLine()
			nCnt:= oMdlGQI:Length()
			While nCnt > 1
				If !oMdlGQI:IsDeleted(nCnt)
					nTamGrid := nCnt
					EXIT
				EndIf
				nCnt--
			End
			If nLinhaAtu != nTamGrid .AND. nTamGrid > 0 .AND. nLinhaAtu > 0
				lRet:= .F.
				cMsgTitu := STR0029//"Alteração indevida"
				cMsgErro := STR0030//"Não pode alterar, por não ser ultima linha."
			EndIf

		Case cField $ 'GQJ_CODGIM|GYX_CODGIM'
			GIM->(DbSetOrder(1))
			If !GIM->(DbSeek(xFilial('GIM')+uVal))
				lRet:= .F.
				cMsgTitu := STR0044 //"Código não encontrado"
				cMsgErro := STR0045 //"Utilize um código válido"
			Endif

		Case cField == 'GY0_TPCTO'
			cMsgErro := VldCn1(uVal)
			
			If !(Empty(cMsgErro))
				lRet := .F.
			//	oModel:SetErrorMessage(oModel:GetId(),,oModel:GetId(),,,cMsgErro,)
			Endif

		Case cField == 'GY0_TIPPLA'
			cMsgErro := VldCnl(uVal)
			
			If !(Empty(cMsgErro))
				lRet := .F.
			Endif

		Case cField == 'GY0_TIPREV'
			CN0->(dbSetOrder(1))
			If CN0->(dbSeek(xFilial('CN0')+uVal))
				If CN0->CN0_TIPO != 'G'
					cMsgErro := STR0129 //"Apenas revisões do tipo Aberta 'G' são permitidas"
					lRet := .F.
				Endif
			Else
				cMsgErro := STR0130 //"Código de tipo de revisão não encontrado."
				lRet := .F.
			Endif
		Case cField == 'GY0_VLRACO'
			If uVal < 0
				cMsgErro := STR0131 //"O valor Acordado não pode ser negativo."
				lRet := .F.
			Endif
		Case ( cField == "GQI_SENTID" )		
			lRet := WrongWay(oModel,uVal,@cMsgErro)		
		
		Case ( cField == "GYD_CODGI2" )	
			GI2->(dbSetOrder(1))
			if !IsInCallStack("G900GerLin") .AND. GI2->(DBSeek(xFilial('GI2')+uVal)) 
				cMsgErro := STR0213 //"Linha já existente"
				lRet := .F.
			EndIf

	EndCase

	If !lRet
		oModel:SetErrorMessage(oModel:GetId(),,oModel:GetId(),,,cMsgErro,cMsgSolu)
	EndIF

Return lRet

/*/{Protheus.doc} WrongWay
Função que avalia se o itinerário possui o mesmo sentido que a linha
(gtrid dados da linha)
@type  Static Function
@author Teixeira
@since 25/05/2023
@version 1.0
@param 
	oModel, objeto, instância do modelo de dados 
	cSentido, caracter, sentido do trecho (ida ou volta)
	cMsgErro, caractere, parâmetro passado por referência para 
	ser atualizado com mensagem de erro, caso haja.
	nLnGQI, numerico, linha do submodelo GQIDETAIL
	nLnGYD, numerico, linha do submodelo GYDDETAIL
	
@return LRet, lógico, .t. sentido está correto; .f. não está correto
@example
(examples)
@see (links_or_references)
/*/
Static Function WrongWay(oModel,cSentido,cMsgErro,nLnGQI,nLnGYD)
		
	Local oMdlGQI := oModel:GetModel("GQIDETAIL")
	Local oMdlGYD := oModel:GetModel("GYDDETAIL")

	Local lRet := .t.
	
	Default nLnGQI	:= oMdlGQI:GetLine()
	Default nLnGYD	:= oMdlGYD:GetLine()

	If ( (!oMdlGYD:IsDeleted(nLnGYD) .And. !oMdlGQI:IsDeleted(nLnGQI)) .And.; 
		(oMdlGYD:GetValue("GYD_SENTID",nLnGYD) != "3" .And. cSentido != oMdlGYD:GetValue("GYD_SENTID",nLnGYD)) .Or.;
		Empty(cSentido))
		
		lRet := .F.

		cMsgErro := STR0155	//"O sentido da linha (Grade Dados da Linha) que foi definido ("
		cMsgErro += X3Combo("GYD_SENTID",oMdlGYD:GetValue("GYD_SENTID",nLnGYD))  
		cMsgErro += STR0156	//"), não é o mesmo sentido do trecho do itinerário, do item " 
		cMsgErro += cValToChar(nLnGQI) 
		cMsgErro += STR0157	//" que foi selecionado na Grade Itinerários."
	
	EndIf

Return(lRet)

/*/{Protheus.doc} ViewDef
(long_description)
@type  Function
@author Lucivan Severo Correia
@since 25/06/2020
@version 1
@param param_name, param_type, param_descr
@return oView, return_type, return_description
@example
(examples)
@see (links_or_references)
/*/
Static Function ViewDef()
	Local oModel        := ModelDef()
	Local oView
	Local oStruGY0      := FWFormStruct(2,"GY0", {|cCpo| !(AllTrim(cCpo)) $ "GY0_REVISA|GY0_DATREV|GY0_MOTREV|GY0_TIPREV|GY0_JUSREV|"})//cadastral	
	Local oStruRev	    := FWFormStruct(2,"GY0", {|cCpo| (AllTrim(cCpo)) $ "GY0_REVISA|GY0_DATREV|GY0_MOTREV|GY0_TIPREV|GY0_JUSREV|"})//dados da revisão	
	Local oStruGYD      := FWFormStruct(2,"GYD")//dados da linha
	Local oStruGQJ      := FWFormStruct(2,"GQJ")//Custos adicionais Cadastral
	Local oStruGYX      := FWFormStruct(2,"GYX")//custos adicionais linha
	Local oStruGQZ      := FWFormStruct(2,"GQZ")//custos operacionais
	Local oStruGQI      := FWFormStruct(2,"GQI")//itinerarios
	Local oStrTot 	    := FWFormViewStruct():New()
	Local cMsgErro 		:= ''
	Local nI			:= 0
	Local nX			:= 0
	Local cOrcContrato	:= '|GY0_NUMERO|GY0_CLIENT|GY0_LOJACL|GY0_NOMCLI|GY0_CODVD|GY0_NOMVD|GY0_RATEIO'
	Local aOrcContrato	:= {}
	Local cViagExtraSLin:= 'GY0_PLCONV|GY0_IDPLCO|GY0_PREEXT|GY0_PRDEXT|GY0_PRDDSC|GY0_PRONOT|GY0_DPRDNF|GY0_VLRACO'
	Local aViagExtraSLin:= {}
	Local cVigencias 	:= 'GY0_ASSINA|GY0_UNORCV|GY0_VALORC|GY0_DTVORC|GY0_UNVIGE|GY0_VIGE|GY0_DTVIGE|GY0_DTINIC'
	Local aVigencias	:= {}
	Local cGerLog		:= 'GY0_ALTLOG'
	Local aGerLog		:= {}
	
	aOrcContrato	:= STRTOKARR( cOrcContrato, '|' )
	aViagExtraSLin 	:= STRTOKARR( cViagExtraSLin, '|' )
	aVigencias 		:= STRTOKARR( cVigencias, '|' )
	aGerLog 		:= STRTOKARR( cGerLog, '|' )

	If ValidaDic(@cMsgErro)

		SetViewStruct(oStruGY0,oStruGYD,oStruGQJ,oStruGYX,oStruGQZ,oStruGQI,oStrTot)
		
		oStruGY0:AddGroup('ORÇAMENTO_CONTRATO'	, STR0133	, '', 2 )//Orçamento de Contrato
		oStruGY0:AddGroup('VIGENCIAS'			, STR0134	, '', 2 )//Vigencias
		oStruGY0:AddGroup('GERAIS'				, STR0135	, '', 2 )//Dados Gerais
		oStruGY0:AddGroup('EXTRAORDINARIA'		, STR0136	, '', 2 )//Viagens Extra sem Linha
		oStruGY0:AddGroup('GERLOG'				, STR0137	, '', 2 )//Log de Alteração Orçamento
		
		
		For nI:= 1 To Len(oStruGY0:aFields)
			If (oStruGY0:aFields[nI][1] $ cOrcContrato)
				oStruGY0:SetProperty(oStruGY0:aFields[nI][1], MVC_VIEW_GROUP_NUMBER, "ORÇAMENTO_CONTRATO" )
				For nX:= 1 To Len(aOrcContrato)
					If aOrcContrato[nX] == Alltrim(Upper(oStruGY0:aFields[nI][1]))
						Exit
					EndIf
				Next
			ElseIf (oStruGY0:aFields[nI][1] $ cVigencias)
				oStruGY0:SetProperty(oStruGY0:aFields[nI][1], MVC_VIEW_GROUP_NUMBER, "VIGENCIAS" )
				For nX:= 1 To Len(aVigencias)
					If aVigencias[nX] == Alltrim(Upper(oStruGY0:aFields[nI][1]))
						Exit
					EndIf
				Next
			ElseIf (oStruGY0:aFields[nI][1] $ cViagExtraSLin)
				oStruGY0:SetProperty(oStruGY0:aFields[nI][1], MVC_VIEW_GROUP_NUMBER, "EXTRAORDINARIA" )
				For nX:= 1 To Len(aViagExtraSLin)
					If aViagExtraSLin[nX] == Alltrim(Upper(oStruGY0:aFields[nI][1]))
						Exit
					EndIf
				Next
			ElseIf (oStruGY0:aFields[nI][1] $ cGerLog)
				oStruGY0:SetProperty(oStruGY0:aFields[nI][1], MVC_VIEW_GROUP_NUMBER, "GERLOG" )
				For nX:= 1 To Len(aGerLog)
					If aGerLog[nX] == Alltrim(Upper(oStruGY0:aFields[nI][1]))
						Exit
					EndIf
				Next
			Else
				oStruGY0:SetProperty(oStruGY0:aFields[nI][1], MVC_VIEW_GROUP_NUMBER, "GERAIS" )
			EndIf
			oStruGY0:SetProperty(oStruGY0:aFields[nI][1],MVC_VIEW_ORDEM,g900GetOrder(oStruGY0:aFields[nI][1]))
		Next

		For nI:= 1 To Len(oStruGYD:aFields)
			oStruGYD:SetProperty(oStruGYD:aFields[nI][1],MVC_VIEW_ORDEM,g900GetOrder(oStruGYD:aFields[nI][1]))
		Next

		// Cria o objeto de View
		oView := FWFormView():New()
		oView:SetContinuousForm(.T.)
		// Define qual o Modelo de dados será utilizado
		oView:SetModel(oModel)

		oView:AddField("VIEW_GY0", oStruGY0 ,"GY0MASTER" )
		oView:AddField("VIEW_REV", oStruRev ,"GY0MASTER" )
		oView:AddGrid("VIEW_GYD" , oStruGYD ,"GYDDETAIL" )
		oView:AddGrid('VIEW_GQJ' , oStruGQJ ,"GQJDETAIL" )
		oView:AddGrid('VIEW_GYX' , oStruGYX ,"GYXDETAIL" )
		oView:AddGrid('VIEW_GQZ' , oStruGQZ ,"GQZDETAIL" )
		oView:AddGrid("VIEW_GQI" , oStruGQI ,"GQIDETAIL" )
		//oView:AddField('VW_TOTDETAIL' 	, oStrTot	,"TOTDETAIL")

		oView:CreateFolder("FOLDER")
		// Divisão Horizontal
		oView:AddSheet( "FOLDER", "ABA01", STR0012) //"Cadastral"
		oView:CreateHorizontalBox( "SUPERIOR", 60,,,"FOLDER", "ABA01")
		oView:CreateHorizontalBox( "INFERIOR", 40,,,"FOLDER", "ABA01")
		
		oView:EnableTitleView("VIEW_GQJ" , STR0013) //"Custos adicionais/Cortesia"

		oView:AddSheet( "FOLDER", "ABA02", STR0014) //"Precificação/Itinerário"
		oView:CreateHorizontalBox( "BOX_SUPERIOR", 25,,,"FOLDER", "ABA02")

		oView:CreateHorizontalBox( "BOX_ITINERARIO", 25, , , "FOLDER", "ABA02")
		oView:CreateHorizontalBox( "BOX_CUSTOS", 20, , , "FOLDER", "ABA02")
		oView:CreateHorizontalBox( "BOX_CUSTOS_OPERACIONAIS" , 20, /*owner*/,/*lUsePixel*/, "FOLDER", "ABA02" )
		oView:CreateHorizontalBox("TOTAL", 10 , , , "FOLDER", "ABA02") 

		oView:AddSheet("FOLDER", "ABA03", 'Dados da Revisão')
		oView:CreateHorizontalBox("REVISA", 100,,,"FOLDER", "ABA03")

		oView:EnableTitleView("VIEW_GYD"  , STR0015) //"Dados da Linha"
		oView:EnableTitleView("VIEW_GQI"  , STR0009) //"Itinerário"
		oView:EnableTitleView("VIEW_GYX" , STR0013) //"Custos adicionais/Cortesia"
		oView:EnableTitleView("VIEW_GQZ" , STR0016) //"Custos operacionais"
		//oView:EnableTitleView('VW_TOTDETAIL' ,STR0057) //"Totalizadores"

		oView:SetOwnerView("VIEW_GY0" , "SUPERIOR")
		oView:SetOwnerView("VIEW_REV" , "REVISA")
		oView:SetOwnerView("VIEW_GYD" , "BOX_SUPERIOR")
		oView:SetOwnerView("VIEW_GQJ" , "INFERIOR")
		oView:SetOwnerView("VIEW_GYX" , "BOX_CUSTOS")
		oView:SetOwnerView("VIEW_GQZ" , "BOX_CUSTOS_OPERACIONAIS")
		oView:SetOwnerView("VIEW_GQI" , "BOX_ITINERARIO")
		//oView:SetOwnerView('VW_TOTDETAIL'   ,'TOTAL')
		
		
		oView:AddIncrementField( 'VIEW_GYD', 'GYD_SEQ' )
		oView:AddIncrementField( 'VIEW_GQJ', 'GQJ_SEQ' )
		oView:AddIncrementField( 'VIEW_GYX', 'GYX_SEQ' )
		oView:AddIncrementField( 'VIEW_GQI', 'GQI_SEQ' )
		oView:AddIncrementField( 'VIEW_GQZ', 'GQZ_SEQ' )
		
		oView:AddUserButton( STR0039, "", {|| GA900Calc(oView)},,VK_F4 )						//"Cálculo Custo (F4)"
		oView:AddUserButton( STR0040, "", {|| GA900Inc(oView)},,VK_F5, {MODEL_OPERATION_INSERT})//"Listagem passageiros (F5)"
		oView:AddUserButton( STR0138, "", {|oView| GTPA900A(oView)},,VK_F6 ) 					//"Reajuste (F6)"
		oView:AddUserButton( STR0139, "", {|| GTPA901A()},,VK_F7) 								//"Importar Lista de Passageiros (F7)"
		
		If ( GTPxVldDic("H6Q",,.T.,.T.,/*@cMsgErro*/) )
			oView:AddUserButton(STR0202, "", {|oView| G900Rateio(oView)},,VK_F8 ) 				//"Consulta de Rateio de Produtos (F8)"			
		EndIf

		oView:SetAfterViewActivate( { || AfterActiv(oView)})

		oStruGY0:RemoveField('GY0_PCOMVD')
		oStruGQI:RemoveField("GQI_TIPLOC")
	
		oStruGYD:RemoveField('GYD_CUSMOT')
		oStruGYD:RemoveField('GYD_ANOCAR')
		oStruGYD:RemoveField('GYD_ATENDI')
		oStruGY0:RemoveField('GY0_KMFRAN')
		
		
		If INCLUI
			If GY0->(FieldPos("GY0_OBSCAN")) > 0
				oStruGY0:RemoveField("GY0_OBSCAN")
			EndIf

			If GY0->(FieldPos("GY0_DTCANC")) > 0
				oStruGY0:RemoveField("GY0_DTCANC")
			End

			If GY0->(FieldPos("GY0_USUCAN")) > 0
				oStruGY0:RemoveField("GY0_USUCAN")
			End
		EndIf
				
	Else
	    FwAlertHelp(cMsgErro, STR0017)	// "Banco de dados desatualizado, não é possível iniciar a rotina"
	EndIf

Return oView

/*/{Protheus.doc} SetViewStruct
(long_description)
@type  Static Function
@author Teixeira
@since 18/08/2020
@version version
@param param_name, param_type, param_descr
@return return_var, return_type, return_description
@example
(examples)
@see (links_or_references)
/*/
Static Function SetViewStruct(oStruGY0,oStruGYD,oStruGQJ,oStruGYX,oStruGQZ,oStruGQI,oStrTot)

	Local aArea := GetArea()

	If GQZ->(FieldPos("GQZ_CODCLI")) > 0
		oStruGQZ:RemoveField("GQZ_CODCLI")
	EndIf
	If GQZ->(FieldPos("GQZ_CODLOJ")) > 0
		oStruGQZ:RemoveField("GQZ_CODLOJ")
	EndIf
	DbSelectArea("SX3")
	SX3->(dbSetOrder(2))
	If SX3->(dbSeek( "GQZ_NOMCLI"))
		oStruGQZ:RemoveField("GQZ_NOMCLI")
	EndIf
	If GQZ->(FieldPos("GQZ_INIVIG")) > 0
		oStruGQZ:RemoveField("GQZ_INIVIG")
	EndIf
	If GQZ->(FieldPos("GQZ_FIMVIG")) > 0
		oStruGQZ:RemoveField("GQZ_FIMVIG")
	EndIf
	If GQZ->(FieldPos("GQZ_TPDESC"))  > 0
		oStruGQZ:RemoveField("GQZ_TPDESC")
	EndIf
	If GQZ->(FieldPos("GQZ_VALOR")) > 0
		oStruGQZ:RemoveField("GQZ_VALOR")
	EndIf
	If GQZ->(FieldPos("GQZ_TIPCUS")) > 0
		oStruGQZ:RemoveField("GQZ_TIPCUS")
	EndIf

	If GY0->(FieldPos("GY0_STATUS")) > 0
		oStruGY0:RemoveField("GY0_STATUS")
	EndIf

	If GYD->(FieldPos("GYD_CODCNA")) > 0
		oStruGYD:RemoveField("GYD_CODCNA")
	EndIf

	If GYD->(FieldPos("GYD_TPOPER")) > 0
		oStruGYD:RemoveField("GYD_TPOPER")
	EndIf
	
	If GYD->(FieldPos("GYD_CODPLA")) > 0
		oStruGYD:RemoveField("GYD_CODPLA")
	EndIf

	If GYD->(FieldPos("GYD_PLAEXT")) > 0
		oStruGYD:RemoveField("GYD_PLAEXT")
	EndIf

	If GQJ->(FieldPos("GQJ_PLAN")) > 0
		oStruGQJ:RemoveField("GQJ_PLAN")
	EndIf

	If GYX->(FieldPos("GYX_PLAN")) > 0
		oStruGYX:RemoveField("GYX_PLAN")
	EndIf

	If GY0->(FieldPos("GY0_CODCN9")) > 0
		oStruGY0:SetProperty('GY0_CODCN9', MVC_VIEW_CANCHANGE , .F. )
	EndIf
	
	If GYD->(FieldPos("GYD_NUMERO")) > 0
		oStruGYD:SetProperty('GYD_NUMERO', MVC_VIEW_CANCHANGE , .F. )
	EndIf
	If GYD->(FieldPos("GYD_CODGYD")) > 0
		oStruGYD:SetProperty('GYD_CODGYD', MVC_VIEW_CANCHANGE , .F. )
	EndIf

	If GQJ->(FieldPos("GQJ_VALTOT")) > 0
		oStruGQJ:SetProperty('GQJ_VALTOT', MVC_VIEW_CANCHANGE , .F. )
	EndIf

	If GQI->(FieldPos("GQI_DESORI")) > 0
		oStruGQI:SetProperty('GQI_DESORI', MVC_VIEW_CANCHANGE , .F. )
	EndIf
	If GQI->(FieldPos("GQI_DESDES")) > 0
		oStruGQI:SetProperty('GQI_DESDES', MVC_VIEW_CANCHANGE , .F. )
	EndIf

	If GYX->(FieldPos("GYX_CODIGO")) > 0
		oStruGYX:SetProperty('GYX_CODIGO', MVC_VIEW_CANCHANGE , .F. )
	EndIf
	If GYX->(FieldPos("GYX_SEQ")) > 0
		oStruGYX:SetProperty('GYX_SEQ'   , MVC_VIEW_CANCHANGE , .F. )
	EndIf
	If GYX->(FieldPos("GYX_ITEM")) > 0
		oStruGYX:SetProperty('GYX_ITEM'  , MVC_VIEW_CANCHANGE , .F. )
	EndIf
	If GYX->(FieldPos("GYX_VALTOT")) > 0
		oStruGYX:SetProperty('GYX_VALTOT' , MVC_VIEW_CANCHANGE , .F. )
	EndIf

	If GQZ->(FieldPos("GQZ_VALTOT")) > 0
		oStruGQZ:SetProperty('GQZ_VALTOT', MVC_VIEW_CANCHANGE , .F. )
	EndIf
	If GQZ->(FieldPos("GQZ_CODIGO")) > 0
		oStruGQZ:SetProperty('GQZ_CODIGO', MVC_VIEW_CANCHANGE , .F. )
	EndIf
	If GQZ->(FieldPos("GQZ_SEQ")) > 0
		oStruGQZ:SetProperty('GQZ_SEQ'   , MVC_VIEW_CANCHANGE , .F. )
	EndIf
	If GQZ->(FieldPos("GQZ_ITEM")) > 0
		oStruGQZ:SetProperty('GQZ_ITEM'  , MVC_VIEW_CANCHANGE , .F. )
	EndIf

	If GY0->(FieldPos("GY0_TPCTO")) > 0
		oStruGY0:SetProperty('GY0_TPCTO' , MVC_VIEW_LOOKUP, "CN1")
	EndIf

	If GYD->(FieldPos("GYD_TIPLIN")) > 0
		oStruGYD:SetProperty('GYD_TIPLIN' , MVC_VIEW_LOOKUP, "GQDGYD")
	EndIf

	If GYD->(FieldPos("GYD_LOCINI")) > 0
		oStruGYD:SetProperty('GYD_LOCINI', MVC_VIEW_LOOKUP, "GI1")
	EndIf
	If GYD->(FieldPos("GYD_LOCFIM")) > 0
		oStruGYD:SetProperty('GYD_LOCFIM', MVC_VIEW_LOOKUP, "GI1")
	EndIf
	If GYD->(FieldPos("GYD_ORGAO")) > 0
		oStruGYD:SetProperty('GYD_ORGAO' , MVC_VIEW_LOOKUP, "GI0")
	EndIf

	If GQI->(FieldPos("GQI_CODORI")) > 0
		oStruGQI:SetProperty('GQI_CODORI', MVC_VIEW_LOOKUP, "GI1")
	EndIf
	If GQI->(FieldPos("GQI_CODDES")) > 0
		oStruGQI:SetProperty('GQI_CODDES', MVC_VIEW_LOOKUP, "GI1")
	EndIf
	//Cabeçalho
	If SX3->(dbSeek( "GY0_DSCPRD"))
		oStruGY0:SetProperty('GY0_DSCPRD', MVC_VIEW_CANCHANGE , .F. )
	EndIf
	//custos adicionais cabeçalho
	If GQJ->(FieldPos("GQJ_SEQ")) > 0
		oStruGQJ:SetProperty("GQJ_SEQ"    , MVC_VIEW_ORDEM, '01')
	EndIf
	If GQJ->(FieldPos("GQJ_CODGIM")) > 0
		oStruGQJ:SetProperty("GQJ_CODGIM" , MVC_VIEW_ORDEM, '02')
	EndIf
	If GQJ->(FieldPos("GQJ_DCUSTO")) > 0
		oStruGQJ:SetProperty("GQJ_DCUSTO" , MVC_VIEW_ORDEM, '03')
	EndIf
	If GQJ->(FieldPos("GQJ_FORMUL")) > 0
		oStruGQJ:SetProperty("GQJ_FORMUL" , MVC_VIEW_ORDEM, '04')
	EndIf
	If GQJ->(FieldPos("GQJ_TIPO")) > 0
		oStruGQJ:SetProperty("GQJ_TIPO"   , MVC_VIEW_ORDEM, '05')
	EndIf
	If GQJ->(FieldPos("GQJ_UN")) > 0
		oStruGQJ:SetProperty("GQJ_UN"     , MVC_VIEW_ORDEM, '06')
	EndIf
	If GQJ->(FieldPos("GQJ_DESCUN")) > 0
		oStruGQJ:SetProperty("GQJ_DESCUN"     , MVC_VIEW_ORDEM, '07')
	EndIf
	
	If GQJ->(FieldPos("GQJ_QUANT")) > 0
		oStruGQJ:SetProperty("GQJ_QUANT"  , MVC_VIEW_ORDEM, '08')
	EndIf
	If GQJ->(FieldPos("GQJ_CUSUNI")) > 0
		oStruGQJ:SetProperty("GQJ_CUSUNI" , MVC_VIEW_ORDEM, '09')
	EndIf
	If GQJ->(FieldPos("GQJ_VALTOT")) > 0
		oStruGQJ:SetProperty("GQJ_VALTOT" , MVC_VIEW_ORDEM, '10')
	EndIf
	//Dados da linha
	If GYD->(FieldPos("GYD_CODGYD")) > 0
		oStruGYD:SetProperty("GYD_CODGYD" , MVC_VIEW_TITULO , 'Seq.Lin')
	EndIf
	If SX3->(dbSeek( "GYD_DORGAO"))
		oStruGYD:SetProperty("GYD_DORGAO"  , MVC_VIEW_CANCHANGE, .F.) 
	EndIf
	If SX3->(dbSeek( "GYD_DSCPRD"))
		oStruGYD:SetProperty("GYD_DSCPRD"  , MVC_VIEW_CANCHANGE, .F.)
	EndIf
	If SX3->(dbSeek( "GYD_DLOCFI"))
		oStruGYD:SetProperty("GYD_DLOCFI"  , MVC_VIEW_CANCHANGE, .F.)
	EndIf
	If GYD->(FieldPos("GYD_PRECON")) > 0
		oStruGYD:SetProperty("GYD_PRECON" , MVC_VIEW_TITULO , 'Precif. Conven.')
	EndIf
	If GYD->(FieldPos("GYD_VLRTOT")) > 0
		oStruGYD:SetProperty("GYD_VLRTOT" , MVC_VIEW_TITULO , 'Valor Conven.')
	EndIf
	If oStruGYD:HasField("GYD_DPRDNF") 
		oStruGYD:SetProperty("GYD_DPRDNF"  , MVC_VIEW_CANCHANGE, .F.)
	EndIf
	If GYD->(FieldPos("GYD_CODGI2")) > 0
		oStruGYD:SetProperty("GYD_CODGI2"  , MVC_VIEW_CANCHANGE, .T.)
		oStruGYD:SetProperty("GYD_CODGI2" , MVC_VIEW_TITULO , 'Linha Gerada')
	EndIf

	//Itinerario
	If GQI->(FieldPos("GQI_CODIGO")) > 0
		oStruGQI:SetProperty("GQI_CODIGO", MVC_VIEW_ORDEM, '01')
		oStruGQI:SetProperty("GQI_CODIGO"   , MVC_VIEW_CANCHANGE, .F.)
	EndIf
	If GQI->(FieldPos("GQI_SEQ")) > 0
		oStruGQI:SetProperty("GQI_SEQ"   , MVC_VIEW_ORDEM, '02')
		oStruGQI:SetProperty("GQI_SEQ"   , MVC_VIEW_CANCHANGE, .F.)
	EndIf
	If GQI->(FieldPos("GQI_ITEM")) > 0
		oStruGQI:SetProperty("GQI_ITEM"  , MVC_VIEW_ORDEM, '03')
		oStruGQI:SetProperty("GQI_ITEM"   , MVC_VIEW_CANCHANGE, .F.)
	EndIf
	If GQI->(FieldPos("GQI_CODORI")) > 0
		oStruGQI:SetProperty("GQI_CODORI", MVC_VIEW_ORDEM, '04')
	EndIf
	If GQI->(FieldPos("GQI_DESORI")) > 0
		oStruGQI:SetProperty("GQI_DESORI", MVC_VIEW_ORDEM, '05')
	EndIf
	If GQI->(FieldPos("GQI_CODDES")) > 0
		oStruGQI:SetProperty("GQI_CODDES", MVC_VIEW_ORDEM, '06')
	EndIf
	If GQI->(FieldPos("GQI_DESDES")) > 0
		oStruGQI:SetProperty("GQI_DESDES", MVC_VIEW_ORDEM, '07')
	EndIf
	If GQI->(FieldPos("GQI_DTORIG")) > 0
		oStruGQI:SetProperty("GQI_DTORIG", MVC_VIEW_ORDEM, '08')
	EndIf
	If GQI->(FieldPos("GQI_HRORIG")) > 0
		oStruGQI:SetProperty("GQI_HRORIG", MVC_VIEW_ORDEM, '09')
	EndIf
	If GQI->(FieldPos("GQI_DTDEST")) > 0
		oStruGQI:SetProperty("GQI_DTDEST", MVC_VIEW_ORDEM, '10')
	EndIf
	If GQI->(FieldPos("GQI_HRDEST")) > 0
		oStruGQI:SetProperty("GQI_HRDEST", MVC_VIEW_ORDEM, '11')
	EndIf
		
	If GQI->(FieldPos("GQI_SENTID")) > 0
		oStruGQI:SetProperty("GQI_SENTID" , MVC_VIEW_ORDEM, '16')
	EndIf
	
	//adicionais
	If GYX->(FieldPos("GYX_CODIGO")) > 0
		oStruGYX:SetProperty("GYX_CODIGO" , MVC_VIEW_ORDEM, '01')
	EndIf
	If GYX->(FieldPos("GYX_SEQ")) > 0
		oStruGYX:SetProperty("GYX_SEQ", MVC_VIEW_ORDEM, '02')
	EndIf
	If GYX->(FieldPos("GYX_ITEM")) > 0
		oStruGYX:SetProperty("GYX_ITEM", MVC_VIEW_ORDEM, '03')
	EndIf
	If GYX->(FieldPos("GYX_CODGIM")) > 0
		oStruGYX:SetProperty("GYX_CODGIM", MVC_VIEW_ORDEM, '04')
	EndIf
	If GYX->(FieldPos("GYX_DCUSTO")) > 0
		oStruGYX:SetProperty("GYX_DCUSTO", MVC_VIEW_ORDEM, '05')
	EndIf
	If GYX->(FieldPos("GYX_FORMUL")) > 0
		oStruGYX:SetProperty("GYX_FORMUL", MVC_VIEW_ORDEM, '06')
	EndIf
	If GYX->(FieldPos("GYX_TIPO")) > 0
		oStruGYX:SetProperty("GYX_TIPO", MVC_VIEW_ORDEM, '07')
	EndIf
	If GYX->(FieldPos("GYX_UM")) > 0
		oStruGYX:SetProperty("GYX_UM", MVC_VIEW_ORDEM, '08')
	EndIf
	DbSelectArea("SX3")
	SX3->(dbSetOrder(2))
	If SX3->(dbSeek( "GYX_DESUM"))
		oStruGYX:SetProperty("GYX_DESUM", MVC_VIEW_ORDEM, '09')
	EndIf
	If GYX->(FieldPos("GYX_QUANT")) > 0
		oStruGYX:SetProperty("GYX_QUANT"  , MVC_VIEW_ORDEM, '10')
	EndIf
	If GYX->(FieldPos("GYX_CUSUNI")) > 0
		oStruGYX:SetProperty("GYX_CUSUNI" , MVC_VIEW_ORDEM, '11')
	EndIf
	If GYX->(FieldPos("GYX_VALTOT")) > 0
		oStruGYX:SetProperty("GYX_VALTOT" , MVC_VIEW_ORDEM, '12')
	EndIf
	//operacionais
	If GQZ->(FieldPos("GQZ_CODIGO")) > 0
		oStruGQZ:SetProperty("GQZ_CODIGO", MVC_VIEW_ORDEM, '01')
	EndIf
	If GQZ->(FieldPos("GQZ_SEQ")) > 0
		oStruGQZ:SetProperty("GQZ_SEQ"   , MVC_VIEW_ORDEM, '02')
	EndIf
	If GQZ->(FieldPos("GQZ_ITEM")) > 0
		oStruGQZ:SetProperty("GQZ_ITEM"  , MVC_VIEW_ORDEM, '03')
	EndIf

	If ValType(oStrTot) == "O"
		oStrTot:AddField("VLRITEM"	,'01',STR0054 ,STR0054 ,{STR0054 },"N",'@E 9,999,999,999,999.99' ,NIL,NIL,.F.,NIL,NIL,NIL,NIL,NIL,.T.,'' )
		oStrTot:AddField("VLREXTRA"	,'02',STR0055 ,STR0055 ,{STR0055 },"N",'@E 9,999,999,999,999.99' ,NIL,NIL,.F.,NIL,NIL,NIL,NIL,NIL,.T.,'' )
		oStrTot:AddField("TOTADIC"	,'03',STR0051 ,STR0051 ,{STR0051 },"N",'@E 9,999,999,999,999.99' ,NIL,NIL,.F.,NIL,NIL,NIL,NIL,NIL,.T.,'' )
		oStrTot:AddField("TOTOPE"	,'04',STR0052 ,STR0052 ,{STR0052 },"N",'@E 9,999,999,999,999.99' ,NIL,NIL,.F.,NIL,NIL,NIL,NIL,NIL,.T.,'' )
		oStrTot:AddField("TOTLINHA"	,'05',STR0053 ,STR0053 ,{STR0053 },"N",'@E 9,999,999,999,999.99' ,NIL,NIL,.F.,NIL,NIL,NIL,NIL,NIL,.T.,'' )	
	EndIf

	If GY0->(FieldPos('GY0_DTCANC')) > 0
		oStruGY0:SetProperty("GY0_DTCANC", MVC_VIEW_CANCHANGE, .F.)
	Endif

	If GY0->(FieldPos('GY0_USUCAN')) > 0
		oStruGY0:SetProperty("GY0_USUCAN", MVC_VIEW_CANCHANGE, .F.)
	Endif

	If GY0->(FieldPos('GY0_OBSCAN')) > 0
		oStruGY0:SetProperty("GY0_OBSCAN", MVC_VIEW_CANCHANGE, .F.)
	Endif

	oStruGY0:AddField(	"GY0_RATEIO",; // [01] C Nome do Campo
						"99",; // [02] C Ordem
						STR0200,; // [03] C Titulo do campo //"Rateio Prod."
						STR0201,; // [04] C Descrição do campo //"Rateio de Produtos"
						{},; // [05] A Array com Help
						"COMBO",; // [06] C Tipo do campo
						"@!",; // [07] C Picture
						NIL,; // [08] B Bloco de Picture Var
						"",; // [09] C Consulta F3
						.F.,; // [10] L Indica se o campo é editável
						NIL,; // [11] C Pasta do campo
						NIL,; // [12] C Agrupamento do campo
						{ "1=Sim", "2=Não"},; // [13] A Lista de valores permitido do campo //"1=Sim", "2=Não"
						Nil,; // [14] N Tamanho Máximo da maior opção do combo
						NIL,; // [15] C Inicializador de Browse
						.T.,; // [16] L Indica se o campo é virtual
						NIL )     // [17] C Picture Variáve

	oStruGYD:AddField(	"GYD_RATEIO",; // [01] C Nome do Campo
						"06",; // [02] C Ordem
						STR0200,; // [03] C Titulo do campo //"Rateio Prod."
						STR0201,; // [04] C Descrição do campo //"Rateio de Produtos"
						{},; // [05] A Array com Help
						"COMBO",; // [06] C Tipo do campo
						"@!",; // [07] C Picture
						NIL,; // [08] B Bloco de Picture Var
						"",; // [09] C Consulta F3
						.F.,; // [10] L Indica se o campo é editável
						NIL,; // [11] C Pasta do campo
						NIL,; // [12] C Agrupamento do campo
						{ "1=Sim", "2=Não"},; // [13] A Lista de valores permitido do campo //"1=Sim", "2=Não"
						Nil,; // [14] N Tamanho Máximo da maior opção do combo
						NIL,; // [15] C Inicializador de Browse
						.T.,; // [16] L Indica se o campo é virtual
						NIL )     // [17] C Picture Variáve
				
RestArea(aArea)
Return 

/*/{Protheus.doc} GA900Inc
(long_description)
@type  Static Function
@author Teixeira
@since 12/08/2020
@version 1.0
@param oView, param_type, param_descr
@return nil, return_type, return_description
@example
(examples)
@see (links_or_references)
/*/
Static Function GA900Inc(oView)
Local oModel	:= oView:GetModel()
Local n1        := 0
Local n2        := 0
Local aFldsGQ8  := oModel:GetModel('GQ8DETAIL'):GetStruct():GetFields()
Local aFldsGQB  := oModel:GetModel('GQBDETAIL'):GetStruct():GetFields()

Private oMdl901

GTPA901ORC(oModel)

If oMdl901:IsActive()

	For n1 := 1 To Len(aFldsGQ8)
		oModel:GetModel('GQ8DETAIL'):LoadValue(aFldsGQ8[n1][3], oMdl901:GetModel('GQ8MASTER'):GetValue(aFldsGQ8[n1][3]))
	Next

	oModel:GetModel('GQBDETAIL'):DelAllLine()

	For n2 := 1 To oMdl901:GetModel('GQBDETAIL'):Length()

		If !Empty(oModel:GetModel('GQBDETAIL'):GetValue('GQB_ITEM')) 
			oModel:GetModel('GQBDETAIL'):AddLine()
		Endif

		For n1 := 1 To Len(aFldsGQB)
			oModel:GetModel('GQBDETAIL'):LoadValue(aFldsGQB[n1][3], oMdl901:GetModel('GQBDETAIL'):GetValue(aFldsGQB[n1][3], n2))
		Next

	Next

	oModel:GetModel('GQ8DETAIL'):LoadValue('GQ8_CODGY0', oModel:GetModel('GYDDETAIL'):GetValue('GYD_NUMERO'))
	oModel:GetModel('GQ8DETAIL'):LoadValue('GQ8_CODGYD', oModel:GetModel('GYDDETAIL'):GetValue('GYD_CODGYD'))

	oMdl901:DeActivate()
	oMdl901:Destroy()

Endif

Return nil

/*/{Protheus.doc} TrigGIMPrd
Preenche grid da GIM com as tabelas de custos conforme o produto informado
@type function
@author jacomo.fernandes
@since 19/07/2018
@version 1.0
@param oMdlG6S, objeto, (Descrição do parâmetro)
@param cProduto, character, (Descrição do parâmetro)
@return ${return}, ${return_description}
@example
(examples)
@see (links_or_references)
/*/
Static Function TrigGIMPrd(oMdl, cProduto, cCodigo)
Local cAliasTmp	:= GetNextAlias()
Local cWhere	:= ""
Local lTrgGQJ	:= .F. //Se vier pelo gatilho do campo GQJ_CODGIM, não permitir que inclua linha.
Local cTable	:= oMdl:GetStruct():GetTable()[1]
Default cCodigo	:= ""

If GIM->(FieldPos('GIM_UTILIZ')) > 0
	cWhere := " AND GIM.GIM_UTILIZ = '2' "
Endif

If !Empty(cCodigo)
	cWhere	:= " AND GIM.GIM_COD = '"+cCodigo+"' "
	lTrgGQJ := .T.
Endif

cWhere := "%"+cWhere+"%"

BeginSql Alias cAliasTmp
	SELECT 
		GIM.GIM_COD AS CODGIM,  
		GIM.GIM_DESCRI AS DCUSTO, 
		GIM.GIM_UM AS UN, 
		SAH.AH_UMRES AS DESCUN,
		(CASE 
			WHEN GIM.GIM_TPCUST = '1' 
				THEN '2'
			ELSE '1' 
		END) AS FORMUL, 
		GIM.GIM_CBASE AS CUSUNI,
		(CASE 
			WHEN GIM.GIM_TPCUST = '1' 
				THEN GIM.GIM_CBASE 
			ELSE 0 
		END) AS VALTOT
	FROM %Table:GIM% GIM
		INNER JOIN %Table:SAH% SAH ON
			SAH.AH_FILIAL = %xFilial:SAH%
			AND SAH.AH_UNIMED = GIM.GIM_UM
			AND SAH.%NotDel%
		
	WHERE 
		GIM_FILIAL = %xFilial:GIM%
		AND GIM.%NotDel%
		
		%Exp: cWhere %
		
	Order By GIM.GIM_FILIAL, GIM.GIM_COD
EndSql

If (cAliasTmp)->(!EoF())
	While (cAliasTmp)->(!EoF())
		
		If !lTrgGQJ .and. (!oMdl:IsEmpty() .or. !Empty(oMdl:GetValue('GQJ_CODGIM')))
			oMdl:AddLine()
		Endif
		
		oMdl:LoadValue(cTable+'_CODGIM'	,(cAliasTmp)->CODGIM	)
		oMdl:LoadValue(cTable+'_DCUSTO'	,(cAliasTmp)->DCUSTO	)
		oMdl:LoadValue(cTable+'_FORMUL'	,(cAliasTmp)->FORMUL	)
		oMdl:LoadValue(If (cTable == 'GQJ','GQJ_UN','GYX_UM'), 	  (cAliasTmp)->UN	)
		oMdl:LoadValue(If (cTable == 'GQJ','GQJ_UN','GYX_DESUM'), (cAliasTmp)->UN	)
		oMdl:LoadValue(cTable+'_QUANT'	, 1						)
		oMdl:LoadValue(cTable+'_CUSUNI'	,(cAliasTmp)->CUSUNI	)
		oMdl:LoadValue(cTable+'_VALTOT'	,(cAliasTmp)->VALTOT	)
		oMdl:LoadValue(cTable+'_PLAN'	,Posicione('GIM',1,xFilial('GIM')+(cAliasTmp)->CODGIM,'GIM_PLAN') )

		(cAliasTmp)->(DbSkip())
	End 
Endif

(cAliasTmp)->(DbCloseArea())

Return

/*/{Protheus.doc} GA900Calc
(long_description)
@type function
@author jacomo.fernandes
@since 20/07/2018
@version 1.0
@return ${return}, ${return_description}
@example
(examples)
@see (links_or_references)
/*/
Static Function GA900Calc(oView)
Local oModel			:= oView:GetModel()
Local oMdlGY0			:= oModel:GetModel('GY0MASTER')
Local oMdlGQI			:= oModel:GetModel('GQIDETAIL')
Local oMdlGQJ			:= oModel:GetModel('GQJDETAIL')
Local oMdlGYX			:= oModel:GetModel('GYXDETAIL')
Local oMdlGQZ			:= oModel:GetModel('GQZDETAIL')
Local oMdlGYD			:= oModel:GetModel('GYDDETAIL')
Local oWorkSheet		:= FWUIWorkSheet():New(/*oWinPlanilha*/,.F. , /*WS_ROWS*/, /*WS_COLS*/)
Local nCell				:= 0
Local n1				:= 0
Local nValue			:= 0
Local cPlan				:= 0
Local lPlanilha			:= .F.

oWorkSheet:lShow := .F.

For n1 := 1 to oMdlGQJ:Length()
	If !oMdlGQJ:IsDeleted(n1) .and. oMdlGQJ:GetValue('GQJ_FORMUL',n1) == '1'
		oMdlGQJ:GoLine(n1)
		oWorkSheet:LoadXmlModel(oMdlGQJ:GetValue('GQJ_PLAN'))
		
		For nCell := 2 To oWorkSheet:NTOTALLINES			
			If oWorkSheet:CellExists("A"+ cValTochar(nCell))
				
				cCellValue	:= oWorkSheet:GetCellValue("A"+ cValTochar(nCell))
				cCellValue	:= AllTrim(cCellValue) 
				
				Do Case
					Case oMdlGY0:GetStruct():HasField(cCellValue)
						oWorkSheet:SetCellValue("C" + cValToChar(nCell), oMdlGY0:GetValue(cCellValue))
					Case oMdlGQI:GetStruct():HasField(cCellValue)
						oWorkSheet:SetCellValue("C" + cValToChar(nCell), oMdlGQI:GetValue(cCellValue))
					Case oMdlGQJ:GetStruct():HasField(cCellValue)
						oWorkSheet:SetCellValue("C" + cValToChar(nCell), oMdlGQJ:GetValue(cCellValue))
					Case oMdlGYX:GetStruct():HasField(cCellValue)
						oWorkSheet:SetCellValue("C" + cValToChar(nCell), oMdlGYX:GetValue(cCellValue))
					Case oMdlGQZ:GetStruct():HasField(cCellValue)
						oWorkSheet:SetCellValue("C" + cValToChar(nCell), oMdlGQZ:GetValue(cCellValue))
				EndCase

			EndIf
		Next
		
		If oWorkSheet:CellExists("D2") 	
			nValue := oWorkSheet:GetCellValue("D2")
		EndIf
				
		oMdlGQJ:SetValue('GQJ_CUSUNI',nValue)
		
		oWorkSheet:Close()
		
	Endif
Next

For n1 := 1 to oMdlGYX:Length()
	If !oMdlGYX:IsDeleted(n1) .and. oMdlGYX:GetValue('GYX_FORMUL',n1) == '1'
		oMdlGYX:GoLine(n1)
		oWorkSheet:LoadXmlModel(oMdlGYX:GetValue('GYX_PLAN'))
		
		For nCell := 2 To oWorkSheet:NTOTALLINES			
			If oWorkSheet:CellExists("A"+ cValTochar(nCell))
				
				cCellValue	:= oWorkSheet:GetCellValue("A"+ cValTochar(nCell))
				cCellValue	:= AllTrim(cCellValue) 
				
				Do Case
					Case oMdlGY0:GetStruct():HasField(cCellValue)
						oWorkSheet:SetCellValue("C" + cValToChar(nCell), oMdlGY0:GetValue(cCellValue))
					Case oMdlGQI:GetStruct():HasField(cCellValue)
						oWorkSheet:SetCellValue("C" + cValToChar(nCell), oMdlGQI:GetValue(cCellValue))
					Case oMdlGQJ:GetStruct():HasField(cCellValue)
						oWorkSheet:SetCellValue("C" + cValToChar(nCell), oMdlGQJ:GetValue(cCellValue))
					Case oMdlGYX:GetStruct():HasField(cCellValue)
						oWorkSheet:SetCellValue("C" + cValToChar(nCell), oMdlGYX:GetValue(cCellValue))
					Case oMdlGQZ:GetStruct():HasField(cCellValue)
						oWorkSheet:SetCellValue("C" + cValToChar(nCell), oMdlGQZ:GetValue(cCellValue))
				EndCase

			EndIf
		Next
		
		If oWorkSheet:CellExists("D2") 	
			nValue := oWorkSheet:GetCellValue("D2")
		EndIf
				
		oMdlGYX:SetValue('GYX_CUSUNI',nValue)
		
		oWorkSheet:Close()
		
	Endif
Next

If GYD->(FieldPos("GYD_CODPLA")) > 0 

	DbSelectArea("GIM")
	GIM->(DbSetOrder(1))
	For n1 := 1 to oMdlGYD:Length()
		If !oMdlGYD:IsDeleted(n1)
			oMdlGYD:GoLine(n1)
			If GIM->(dbSeek(xFilial('GIM')+oMdlGYD:GetValue('GYD_IDPLCO'))) .And. GIM->GIM_TPCUST == "2"
				oWorkSheet:LoadXmlModel(GIM->GIM_PLAN)			
				For nCell := 2 To oWorkSheet:NTOTALLINES
					If oWorkSheet:CellExists("A"+ cValTochar(nCell))
						cCellValue	:= oWorkSheet:GetCellValue("A"+ cValTochar(nCell))
						cCellValue	:= AllTrim(cCellValue) 						
						If oMdlGYD:GetStruct():HasField(cCellValue)
							oWorkSheet:SetCellValue("C" + cValToChar(nCell), oMdlGYD:GetValue(cCellValue))
						Endif
					EndIf
				Next
				
				cPlan := oWorkSheet:GetXmlModel()
				If !Empty(cPlan)
					oMdlGYD:SetValue('GYD_CODPLA',cPlan)
					lPlanilha := .T.
				Endif
				oWorkSheet:Close()

			Endif
			
		Endif
	Next

Endif

If GYD->(FieldPos("GYD_PLAEXT")) > 0 

	DbSelectArea("GIM")
	GIM->(DbSetOrder(1))
	For n1 := 1 to oMdlGYD:Length()
		If !oMdlGYD:IsDeleted(n1)
			oMdlGYD:GoLine(n1)
			If GIM->(dbSeek(xFilial('GIM')+oMdlGYD:GetValue('GYD_IDPLEX'))) .And. GIM->GIM_TPCUST == "2"
				oWorkSheet:LoadXmlModel(GIM->GIM_PLAN)			
				For nCell := 2 To oWorkSheet:NTOTALLINES
					If oWorkSheet:CellExists("A"+ cValTochar(nCell))
						cCellValue	:= oWorkSheet:GetCellValue("A"+ cValTochar(nCell))
						cCellValue	:= AllTrim(cCellValue) 						
						If oMdlGYD:GetStruct():HasField(cCellValue)
							oWorkSheet:SetCellValue("C" + cValToChar(nCell), oMdlGYD:GetValue(cCellValue))
						Endif
					EndIf
				Next
				
				cPlan := oWorkSheet:GetXmlModel()
				If !Empty(cPlan)
					oMdlGYD:SetValue('GYD_PLAEXT',cPlan)
					lPlanilha := .T.
				Endif
				oWorkSheet:Close()

			Endif
			
		Endif
	Next

Endif

If lPlanilha
	FwAlertSuccess('Gravado planilha de custo') 
Else 
	FWAlertInfo('Não há planilha de custo para gravação') 
EndIf 

GTPDestroy(oWorkSheet)

Return

/*/{Protheus.doc} GTPA900CTR
(long_description)
@type  Function
@author Osmar Cioni
@since 19/08/2020
@version 1.0
@param oView, param_type, param_descr
@return nil, return_type, return_description
@example
(examples)
@see (links_or_references)
/*/
Function GTPA900CTR()
Local lRet	:= .T.

If GY0->(FieldPos("GY0_STATUS")) > 0 .And. GY0->GY0_STATUS != '1' 
	lRet := .F.
	FwAlertWarning(STR0023, STR0020) //"Criação de contrato permitido apenas para registros com o status 'Em Aberto'", "Atenção"
Endif 

If lRet
	lRet := ValidDocs()
Endif

If lRet
	FwMsgRun( ,{|| lRet := G900GerCtr()},, STR0022 ) //"Gerando Contrato...." 	
Endif

Return

/*/{Protheus.doc} G900GerCtr
(long_description)
@type  Static Function
@author Osmar Cioni
@since 19/08/2020
@version 1.0
@param oView, param_type, param_descr
@return nil, return_type, return_description
@example
(examples)
@see (links_or_references)
/*/
Static Function G900GerCtr()

	Local lRet      := .T.
	Local lValOrc   := .T. // Valida Data Orçamento
	Local lBreak   	:= .F. // Valida Data Orçamento
	
	Local nX 		:= Nil
	Local nTotCadast:= 0
	Local nNumero	:= 0

	Local cContrat  := CN300Num()
	Local cMsgErro  := ""
	
	Local aSeek		:= Array(2,2)
	Local aDados	:= Array(2)

	Local oModel    := Nil
	Local oModelOrc	:= FwLoadModel("GTPA900")

	oModelOrc:SetOperation(MODEL_OPERATION_UPDATE) 
	oModelOrc:Activate()

	If oModelOrc:GetModel("GY0MASTER"):HasField('GY0_DTVORC')
		lValOrc := oModelOrc:GetModel("GY0MASTER"):GetValue('GY0_DTVORC') >= dDataBase
	EndIf

	If  lValOrc

		oModel := FWLoadModel('CNTA301')
		oModel:SetOperation(MODEL_OPERATION_INSERT)
		oModel:Activate()

		//Cabeçalho do Contrato  - //GY0MASTER
		oModel:SetValue('CN9MASTER','CN9_NUMERO', cContrat)
		oModel:SetValue('CN9MASTER','CN9_DTINIC', oModelOrc:GetModel('GY0MASTER'):GetValue('GY0_DTINIC'))
		oModel:SetValue('CN9MASTER','CN9_UNVIGE', oModelOrc:GetModel('GY0MASTER'):GetValue('GY0_UNVIGE'))
		oModel:SetValue('CN9MASTER','CN9_VIGE',   oModelOrc:GetModel('GY0MASTER'):GetValue('GY0_VIGE'))
		oModel:SetValue('CN9MASTER','CN9_MOEDA',  oModelOrc:GetModel('GY0MASTER'):GetValue('GY0_MOEDA')) 
		oModel:SetValue('CN9MASTER','CN9_TPCTO',  oModelOrc:GetModel('GY0MASTER'):GetValue('GY0_TPCTO'))
		oModel:SetValue('CN9MASTER','CN9_CONDPG', oModelOrc:GetModel('GY0MASTER'):GetValue('GY0_CONDPG'))
		If GY0->(FieldPos("GY0_NATURE")) > 0
			oModel:SetValue('CN9MASTER','CN9_NATURE', oModelOrc:GetModel('GY0MASTER'):GetValue('GY0_NATURE'))
		EndIf
		oModel:SetValue('CN9MASTER','CN9_AUTO',  '1')    
		//Vendedor do Contrato
		oModel:LoadValue('CNUDETAIL','CNU_CODVD'   , oModelOrc:GetModel('GY0MASTER'):GetValue('GY0_CODVD'))
		oModel:LoadValue('CNUDETAIL','CNU_PERCCM'  , oModelOrc:GetModel('GY0MASTER'):GetValue('GY0_PCOMVD'))

		aSeek[1,1] := "CNC_CLIENT"
		aSeek[2,1] := "CNC_LOJACL"
		
		aFill(aDados, "")
		nNumero	:= 1

		For nX := 1 to oModelOrc:GetModel('GYDDETAIL'):Length() //DADOS DA LINHA
			
			oModelOrc:GetModel('GYDDETAIL'):goline(nX)

			If  Empty(oModelOrc:GetModel('GYDDETAIL'):GetValue('GYD_CLIENT')) .AND. Empty(oModelOrc:GetModel('GYDDETAIL'):GetValue('GYD_LOJACL'))
				oModelOrc:LoadValue('GYDDETAIL','GYD_CLIENT',oModelOrc:GetModel('GY0MASTER'):GetValue('GY0_CLIENT'))
				oModelOrc:LoadValue('GYDDETAIL','GYD_LOJACL',oModelOrc:GetModel('GY0MASTER'):GetValue('GY0_LOJACL'))
			EndIf

			aSeek[1,2] := oModelOrc:GetModel('GYDDETAIL'):GetValue('GYD_CLIENT')
			aSeek[2,2] := oModelOrc:GetModel('GYDDETAIL'):GetValue('GYD_LOJACL')
			
			If !Empty(oModelOrc:GetValue('GYDDETAIL','GYD_CLIENT')) .AND. !Empty(oModelOrc:GetValue('GYDDETAIL','GYD_LOJACL'))
				//Cliente/Fornecedor do Contrato
				lSeek := oModel:GetModel('CNCDETAIL'):SeekLine(aSeek)
				
				If ( !lSeek )
				
					If ( !(oModel:GetModel('CNCDETAIL'):IsEmpty()) .Or.; 
						!Empty(oModel:GetModel('CNCDETAIL'):GetValue('CNC_CLIENT')) )
					
						oModel:GetModel('CNCDETAIL'):AddLine()
					
					EndIf

					oModel:SetValue('CNCDETAIL','CNC_CLIENT', oModelOrc:GetModel('GYDDETAIL'):GetValue('GYD_CLIENT'))
					oModel:SetValue('CNCDETAIL','CNC_LOJACL', oModelOrc:GetModel('GYDDETAIL'):GetValue('GYD_LOJACL'))
					
				EndIf

				//Planilhas do Contrato
				aSeek[1,1] := "CNA_CLIENT"
				aSeek[2,1] := "CNA_LOJACL"
				
				lBreak := (oModelOrc:GetModel('GYDDETAIL'):GetValue('GYD_CLIENT') +; 
						oModelOrc:GetModel('GYDDETAIL'):GetValue('GYD_LOJACL')) != (aDados[1] + aDados[2])
				
				If ( lBreak )

					lSeek := oModel:GetModel('CNADETAIL'):SeekLine(aSeek)
					
					If ( !lSeek )

						If( !Empty(oModel:GetModel('CNADETAIL'):GetValue('CNA_NUMERO')) )
							
							nNumero++	
							
							oModel:GetModel('CNADETAIL'):AddLine()

						EndIf		
						
						oModel:SetValue('CNADETAIL','CNA_NUMERO', StrZero(nNumero, Len(CNA->CNA_NUMERO)))
						oModel:SetValue('CNADETAIL','CNA_CLIENT', oModelOrc:GetModel('GYDDETAIL'):GetValue('GYD_CLIENT'))
						oModel:SetValue('CNADETAIL','CNA_LOJACL', oModelOrc:GetModel('GYDDETAIL'):GetValue('GYD_LOJACL'))
						oModel:SetValue('CNADETAIL','CNA_TIPPLA', oModelOrc:GetModel('GY0MASTER'):GetValue('GY0_TIPPLA'))
					
					EndIf

					If GYD->(FieldPos("GYD_CODCNA")) > 0
						oModelOrc:SetValue('GYDDETAIL','GYD_CODCNA', oModel:GetModel('CNADETAIL'):GetValue('CNA_NUMERO'))
					Endif

				EndIf				

			EndIf

			aDados[1]	:= oModelOrc:GetModel("GYDDETAIL"):GetValue("GYD_CLIENT")
			aDados[2]	:= oModelOrc:GetModel("GYDDETAIL"):GetValue("GYD_LOJACL")

		Next nX
		//GQZ-CUSTOS ADICIONAIS/CORTESIA
		//GQJ-Custo Cadastral
		//GYX-Custo Linha
		For nX := 1 to oModelOrc:GetModel('GQJDETAIL'):Length() //Custo Cadastral
			oModelOrc:GetModel('GQJDETAIL'):goline(nX)
			nTotCadast += oModelOrc:GetModel('GQJDETAIL'):GetValue('GQJ_VALTOT')
		Next nX 

		Begin Transaction

		If (oModel:VldData()) /*Valida o modelo como um todo*/
			oModel:CommitData()//--Grava Contrato

			If G900GerLin(oModelOrc)
				oModelOrc:SetValue('GY0MASTER','GY0_CODCN9', cContrat)	
				oModelOrc:SetValue('GY0MASTER','GY0_STATUS', '2')
				If (oModelOrc:VldData())
					oModelOrc:CommitData()
					FwAlertSuccess(STR0021) //"Contrato gerado com sucesso","'Ok'
				EndIf
			Else
				lRet := .F.
				DisarmTransaction()
				Break	
			EndIf
		Else
			cMsgErro := Alltrim(oModel:GetErrorMessage()[6]) + ". " + Alltrim(oModel:GetErrorMessage()[7])
			Help(,,"G900GerCtr",, cMsgErro, 1,0)
		EndIf

		End Transaction

		If lRet
			DbSelectArea("CN9")
			CN9->(dbSetOrder(1))

			If CN9->(dbSeek(xFilial('CN9')+cContrat)) 
				RecLock("CN9", .F.)
					CN9->CN9_SITUAC := '05'
				MsUnLock()
				lRet:= .T.
			EndIf
			IF !IsBlind() .AND. lRet
				If MsgYesNo(STR0048, STR0020) //"Deseja gerar as viagens agora?","Atenção"
					lRet := G900GerVia(1)
				Endif
			EndIf
		Endif
	Else
		lRet:= .F.
		FwAlertWarning(STR0143,STR0020)
	EndIf

Return lRet

/*/{Protheus.doc} G900GerLin
(long_description)
@type  Static Function
@author Osmar Cioni
@since 19/08/2020
@version 1.0
@param oView, param_type, param_descr
@return nil, return_type, return_description
@example
(examples)
@see (links_or_references)
/*/
Static Function G900GerLin(oModelOrc)
Local lRet 		:= .T.
Local oModel 	:= FwLoadModel("GTPA002")
Local oMdlGI2	:= Nil
Local oMdlG5I	:= Nil
Local nX		:= Nil
Local nY		:= Nil
Local cMsgErro  := ""
Local aLoc		:= {}
Local nSeq		:= 2
Local cCodOri	:= ''
Local cLocIni	:= ''
Local dDtIniGQI 
Local cHrIniGQI := ''
Local dDtFimGQI 
Local cHrFimGQI := ''
Local cCodGI2	:= ""
Local cNewRev	:= ""
Local cRevOld	:= ""
Local lRevGI3	:= .F.

	For nX := 1 to oModelOrc:GetModel('GYDDETAIL'):Length() //DADOS DA LINHA
		lRevGI3:= .F.
		oModelOrc:GetModel('GYDDETAIL'):goline(nX)
		If EMPTY(oModelOrc:GetModel('GYDDETAIL'):GetValue("GYD_LOCINI")) .AND. EMPTY(oModelOrc:GetModel('GYDDETAIL'):GetValue("GYD_LOCFIM"))
			Help(,,"G900GerLin",, STR0086, 1,0) // "Não foi cadastrado linha para esse orçamento"
			lRet := .F.
			EXIT
		EndIf

		cCodGI2:= oModelOrc:GetModel('GYDDETAIL'):GetValue("GYD_CODGI2")
		cNewRev:= oModelOrc:GetModel('GYDDETAIL'):GetValue("GYD_REVISA")
		If !Empty(Alltrim(cCodGI2))
			DbSelectArea("GI2")
			GI2->(DbSetOrder(4)) //GI2_FILIAL, GI2_COD, GI2_HIST, R_E_C_N_O_, D_E_L_E_T_
			If GI2->(dbSeek(xFilial("GI2") + cCodGI2 + "2"))
				cRevOld := GI2->GI2_REVISA
			EndIf 
		EndIf

		If lRet
			oModel:SetOperation(MODEL_OPERATION_INSERT)
			
			If oModel:Activate()
				oMdlGI2 := oModel:GetModel('FIELDGI2')
				oMdlG5I := oModel:GetModel('GRIDG5I')

				If !Empty(Alltrim(cCodGI2))
					oMdlGI2:LoadValue('GI2_COD',cCodGI2)
					lRevGI3:= .T.
				EndIf

				oMdlGI2:LoadValue('GI2_REVISA',cNewRev)
				oMdlGI2:SetValue('GI2_ORGAO',oModelOrc:GetModel('GYDDETAIL'):GetValue('GYD_ORGAO')) 
				oMdlGI2:SetValue('GI2_CATEG',oModelOrc:GetModel('GYDDETAIL'):GetValue('GYD_TPCARR')) 
				oMdlGI2:SetValue('GI2_PREFIX','CONTRATO')
				oMdlGI2:LoadValue('GI2_TIPLIN',oModelOrc:GetModel('GYDDETAIL'):GetValue('GYD_TIPLIN'))
				oMdlGI2:LoadValue('GI2_LOCINI',oModelOrc:GetModel('GYDDETAIL'):GetValue('GYD_LOCINI'))
				oMdlGI2:LoadValue('GI2_LOCFIM',oModelOrc:GetModel('GYDDETAIL'):GetValue('GYD_LOCFIM'))
				oMdlGI2:SetValue('GI2_KMIDA',oModelOrc:GetModel('GYDDETAIL'):GetValue('GYD_KMIDA'))
				oMdlGI2:SetValue('GI2_KMVOLT',oModelOrc:GetModel('GYDDETAIL'):GetValue('GYD_KMVOLT'))
				oMdlGI2:SetValue('GI2_KMTOTA',oModelOrc:GetModel('GYDDETAIL'):GetValue('GYD_KMIDA')+oModelOrc:GetModel('GYDDETAIL'):GetValue('GYD_KMVOLT'))

				
				oMdlGI2:LoadValue('GI2_LOCINI',oModelOrc:GetModel('GYDDETAIL'):GetValue('GYD_LOCINI'))
				oMdlGI2:LoadValue('GI2_LOCFIM',oModelOrc:GetModel('GYDDETAIL'):GetValue('GYD_LOCFIM'))

				oModel:GetModel('GRIDG5I'):AddLine()
				cLocIni:= oModelOrc:GetModel('GYDDETAIL'):GetValue('GYD_LOCINI')
				oMdlG5I:SetValue('G5I_SEQ','001')
				oMdlG5I:SetValue('G5I_LOCALI',cLocIni)
				oMdlG5I:SetValue('G5I_VENDA','1')
				oMdlG5I:SetValue('G5I_REVISA',cNewRev)
				
				//KM INICIAL 
				For nY := 1 to oModelOrc:GetModel('GQIDETAIL'):Length()
					oModelOrc:GetModel('GQIDETAIL'):goline(nY)
					cCodOri:= oModelOrc:GetModel('GQIDETAIL'):GetValue('GQI_CODORI')
					cCodDes:= oModelOrc:GetModel('GQIDETAIL'):GetValue('GQI_CODDES')
						If cCodOri == cLocIni .OR. cCodDes == cLocIni
							dDtIniGQI := oModelOrc:GetModel('GQIDETAIL'):GetValue('GQI_DTORIG')
							cHrIniGQI := GTFormatHour(oModelOrc:GetModel('GQIDETAIL'):GetValue('GQI_HRORIG'),'99:99')
							dDtFimGQI := oModelOrc:GetModel('GQIDETAIL'):GetValue('GQI_DTDEST')
							cHrFimGQI := GTFormatHour(oModelOrc:GetModel('GQIDETAIL'):GetValue('GQI_HRDEST'),'99:99')
							oMdlG5I:SetValue('G5I_KM',oModelOrc:GetModel('GQIDETAIL'):GetValue('GQI_KM'))
							oMdlG5I:SetValue('G5I_TEMPO',StrTran(GTDeltaTime(dDtIniGQI,cHrIniGQI,dDtFimGQI,cHrFimGQI),':',''))
							Exit
						EndIf
				Next

				oModel:GetModel('GRIDG5I'):AddLine()
				oMdlG5I:SetValue('G5I_SEQ','999')
				oMdlG5I:SetValue('G5I_LOCALI',oModelOrc:GetModel('GYDDETAIL'):GetValue('GYD_LOCFIM'))
				oMdlG5I:SetValue('G5I_VENDA','1')
				oMdlG5I:SetValue('G5I_REVISA',cNewRev)

				aAdd(aLoc,oModelOrc:GetModel('GYDDETAIL'):GetValue('GYD_LOCINI'))
				aAdd(aLoc,oModelOrc:GetModel('GYDDETAIL'):GetValue('GYD_LOCFIM'))
				dDtIniGQI := Nil
				cHrIniGQI := ''
				dDtFimGQI := Nil
				cHrFimGQI := ''
				For nY := 1 to oModelOrc:GetModel('GQIDETAIL'):Length()
					oModelOrc:GetModel('GQIDETAIL'):goline(nY)
					
					cCodOri:= oModelOrc:GetModel('GQIDETAIL'):GetValue('GQI_CODORI')

					If aScan(aLoc,cCodOri) == 0 
						dDtIniGQI := oModelOrc:GetModel('GQIDETAIL'):GetValue('GQI_DTORIG')
						cHrIniGQI := GTFormatHour(oModelOrc:GetModel('GQIDETAIL'):GetValue('GQI_HRORIG'),'99:99')
						dDtFimGQI := oModelOrc:GetModel('GQIDETAIL'):GetValue('GQI_DTDEST')
						cHrFimGQI := GTFormatHour(oModelOrc:GetModel('GQIDETAIL'):GetValue('GQI_HRDEST'),'99:99')
						oModel:GetModel('GRIDG5I'):AddLine()
						oMdlG5I:SetValue('G5I_SEQ',StrZero(nSeq,TamSx3('G5I_SEQ')[1]))
						oMdlG5I:SetValue('G5I_LOCALI',cCodOri)
						oMdlG5I:SetValue('G5I_KM',oModelOrc:GetModel('GQIDETAIL'):GetValue('GQI_KM'))
						oMdlG5I:SetValue('G5I_TEMPO',StrTran(GTDeltaTime(dDtIniGQI,cHrIniGQI,dDtFimGQI,cHrFimGQI),':',''))
						oMdlG5I:SetValue('G5I_VENDA','1') 
						oMdlG5I:SetValue('G5I_REVISA',cNewRev)
						aAdd(aLoc,cCodOri)
						nSeq++
					EndIf

				Next nY

				If (oModel:VldData())
					oModel:CommitData()
					If IsInCallStack("G900GerRev") //Altero a operação para atualizar o Código da Linha,Cliente e Loja quando for Revisão de Contrato
						
						//Desativa o registro da linha anterior
						cCodGI2:= oMdlGI2:GetValue('GI2_COD') 
						dbSelectArea("GI2")
						GI2->(dbSetOrder(3))//GI2_FILIAL + GI2_COD + GI2_REVISA
						If GI2->(dbSeek(xFilial("GI2")+cCodGI2+cRevOld)) 
							GI2->(RecLock(("GI2"),.F.))
							GI2->GI2_HIST:= "1"
							GI2->(MsUnlock())
							GI2->(dbSkip())
						EndIf
						
						dbSelectArea("G5I")
						G5I->(dbSetOrder(4))//G5I_FILIAL+G5I_CODLIN+G5I_REVISA                                                                                                                        				
						If G5I->(dbSeek(xFilial("G5I")+cCodGI2+cRevOld))
							While G5I->(!Eof()) .AND. G5I->G5I_CODLIN == cCodGI2 .And. G5I->G5I_REVISA == cRevOld
								G5I->(RecLock(("G5I"),.F.))
								G5I->G5I_HIST:= "1"
								G5I->(MsUnlock())
								G5I->(dbSkip())
							EndDo
						EndIf
						
						If lRevGI3
							cNewRev:= IIF(cNewRev=="001","",StrZero(Val(cNewRev)-1,TamSx3('GI3_REVISA')[1]))
						EndIf
						StartJob("GTPA002F",GetEnvServer(),.F.,.T.,cEmpAnt,cFilAnt,cCodGI2,cNewRev,3,lRevGI3,.T.)

						//Amarra a Linha (GI2) junto a Linha(GYD) do Orçamento de Contrato 
						oModelOrc:DeActivate()
						oModelOrc:SetOperation(MODEL_OPERATION_UPDATE)
						oModelOrc:Activate()
						oModelOrc:GetModel('GYDDETAIL'):GoLine(nX)
						oModelOrc:GetModel('GYDDETAIL'):SetValue('GYD_CODGI2', cCodGI2 )
						oModelOrc:GetModel('GYDDETAIL'):SetValue('GYD_CLIENT', IIF(Empty(Alltrim(oModelOrc:GetModel('GYDDETAIL'):GetValue('GYD_CLIENT'))),oModelOrc:GetModel('GY0MASTER'):GetValue('GY0_CLIENT'),oModelOrc:GetModel('GYDDETAIL'):GetValue('GYD_CLIENT')) )
						oModelOrc:GetModel('GYDDETAIL'):SetValue('GYD_LOJACL', IIF(Empty(Alltrim(oModelOrc:GetModel('GYDDETAIL'):GetValue('GYD_LOJACL'))),oModelOrc:GetModel('GY0MASTER'):GetValue('GY0_LOJACL'),oModelOrc:GetModel('GYDDETAIL'):GetValue('GYD_LOJACL')) )
						oModelOrc:VldData()
						oModelOrc:CommitData()
						oModelOrc:DeActivate()
						oModelOrc:SetOperation(MODEL_OPERATION_VIEW)
						oModelOrc:Activate()
						oModelOrc:GetModel('GYDDETAIL'):GoLine(nX)
					Else
						oModelOrc:GetModel('GYDDETAIL'):SetValue('GYD_CODGI2', oMdlGI2:GetValue('GI2_COD') )
						StartJob("GTPA002F",GetEnvServer(),.F.,.T.,cEmpAnt,cFilAnt,oMdlGI2:GetValue('GI2_COD'),cNewRev,3,.F.,.T.)
					EndIf
					lRet := G900GerSer(oModelOrc)					
				Else
					cMsgErro := Alltrim(oModel:GetErrorMessage()[6]) + ". " + Alltrim(oModel:GetErrorMessage()[7])
					Help(,,"G900GerLin",, cMsgErro, 1,0)
					lRet := .F.
				EndIf

				oModel:DeActivate()

			Endif
		EndIf
	Next nX

Return lRet

/*/{Protheus.doc} GTPA900CAN
(long_description)
@type  Static Function
@author Osmar Cioni
@since 19/08/2020
@version 1.0
@param oView, param_type, param_descr
@return nil, return_type, return_description
@example
(examples)
@see (links_or_references)
/*/
Function GTPA900CAN()

If !(GY0->GY0_STATUS $ '2|6') .Or. GY0->GY0_ATIVO == '2'
	FwAlertWarning(STR0078, STR0075) // "Status do orçamento de contrato não permite o seu cancelamento", "Opção válida apenas para contratos com status 'Contrato gerado'"
	Return
Else
	GTPA900D()
Endif

Return

/*/{Protheus.doc} GTPA900ENC
(long_description)
@type  Static Function
@author flavio.martins
@since 26/04/2021
@version 1.0
@param oView, param_type, param_descr
@return nil, return_type, return_description
@example
(examples)
@see (links_or_references)
/*/
Function GTPA900ENC()
Local lRet := .T.

If GY0->GY0_STATUS != '2' 
	FwAlertWarning(STR0074, STR0075) // "Status do orçamento de contrato não permite o seu encerramento", "Opção válida apenas para contratos com status 'Contrato gerado'"
	Return
Else
	CN9->(dbSetOrder(1))
	If CN9->(dbSeek(xFilial("CN9") + GY0->GY0_CODCN9))
		FwMsgRun( ,{|| lRet := CN100SitCh(CN9->CN9_NUMERO,CN9->CN9_REVISA,"08",,.F.)},, STR0077) // "Finalizando contrato..." 	

		If lRet
			RecLock("GY0",.F.)
			GY0->GY0_STATUS := '4'
			GY0->(MsUnlock())
		Else
			FwAlertHelp(STR0076) // "Erro ao finalizar o contrato"
		Endif
	Endif

Endif

Return


/*/{Protheus.doc} G900GerSer
(long_description)
@type  Static Function
@author Osmar Cioni
@since 28/09/2020
@version 1.0
@param oView, param_type, param_descr
@return nil, return_type, return_description
@example
(examples)
@see (links_or_references)
/*/
Static Function G900GerSer(oModelOrc)

	Local oModel	  	:= Nil
	Local oMdlGID	  	:= Nil
	Local oMdlGIE     	:= Nil
	
	Local cMsgErro    	:= ''
	Local cHrIniGQI		:= ''
	Local cHrFimGQI		:= ''
	Local cSentido		:= ''
	
	Local nY		  	:= 0
	Local nLength		:= 0
	Local nSeq			:= 0
	Local nDiaDec       := 0

	Local dDtIniGQI		:= StoD("") 
	Local dDtFimGQI		:= StoD("") 
	
	Local lRet := .T.
	Local lExecSer	  := GYD->(FieldPos("GYD_LOTACA")) > 0 .AND. GYD->(FieldPos("GYD_SENTID")) > 0 .AND. GYD->(FieldPos("GYD_INIVIG")) > 0 .AND. GYD->(FieldPos("GYD_FINVIG")) > 0
	Local lHeaderWriter	:= .T.

	If lExecSer
		
		oModel	:= FwLoadModel("GTPA004")
		oModel:SetOperation(MODEL_OPERATION_INSERT)
		
		oMdlGID := oModel:GetModel('GIDMASTER')
		oMdlGIE := oModel:GetModel('GIEDETAIL')
		
		nLength	:= oModelOrc:GetModel('GQIDETAIL'):Length()
		
		For nY := 1 to nLength	// For nIdaVolta := 1 To 2	
			
			cSentido := oModelOrc:GetModel('GQIDETAIL'):GetValue('GQI_SENTID',nY)
			
			If ( lHeaderWriter )
				nSeq := 0
				oModel:Activate()
			
				lRet := oMdlGID:SetValue ('GID_LINHA',	oModelOrc:GetModel('GYDDETAIL'):GetValue('GYD_CODGI2'))	.And.;
					oMdlGID:LoadValue('GID_INIVIG',		oModelOrc:GetModel('GYDDETAIL'):GetValue('GYD_INIVIG'))	.And.;
					oMdlGID:LoadValue('GID_FINVIG',		oModelOrc:GetModel('GYDDETAIL'):GetValue('GYD_FINVIG'))	.And.;
					oMdlGID:LoadValue('GID_LOTACA',		oModelOrc:GetModel('GYDDETAIL'):GetValue('GYD_LOTACA'))	.And.;
					oMdlGID:LoadValue('GID_SEG',		oModelOrc:GetModel('GYDDETAIL'):GetValue('GYD_SEG'))	.And.;
					oMdlGID:LoadValue('GID_TER',		oModelOrc:GetModel('GYDDETAIL'):GetValue('GYD_TER'))	.And.;
					oMdlGID:LoadValue('GID_QUA',		oModelOrc:GetModel('GYDDETAIL'):GetValue('GYD_QUA'))	.And.;
					oMdlGID:LoadValue('GID_QUI',		oModelOrc:GetModel('GYDDETAIL'):GetValue('GYD_QUI'))	.And.;
					oMdlGID:LoadValue('GID_SEX',		oModelOrc:GetModel('GYDDETAIL'):GetValue('GYD_SEX'))	.And.;
					oMdlGID:LoadValue('GID_SAB',		oModelOrc:GetModel('GYDDETAIL'):GetValue('GYD_SAB'))	.And.;
					oMdlGID:LoadValue('GID_DOM',		oModelOrc:GetModel('GYDDETAIL'):GetValue('GYD_DOM'))	.And.;	
					oMdlGID:LoadValue('GID_SENTID',		cSentido)	.And.; 
					oMdlGID:LoadValue('GID_HORCAB',		oModelOrc:GetModel('GQIDETAIL'):GetValue('GQI_HRORIG',nY))
				
				lHeaderWriter := .f.

			EndIf

			If ( lRet )

				dDtIniGQI := oModelOrc:GetModel('GQIDETAIL'):GetValue('GQI_DTORIG',nY)
				cHrIniGQI := GTFormatHour(oModelOrc:GetModel('GQIDETAIL'):GetValue('GQI_HRORIG',nY),'99:99')
				
				dDtFimGQI := oModelOrc:GetModel('GQIDETAIL'):GetValue('GQI_DTDEST',nY)
				cHrFimGQI := GTFormatHour(oModelOrc:GetModel('GQIDETAIL'):GetValue('GQI_HRDEST',nY),'99:99')
				
				If ( nY > 1 )
					oModel:GetModel('GIEDETAIL'):SetNoInsertLine(.F.)                                
					oModel:GetModel('GIEDETAIL'):AddLine()
				EndIf
				nSeq++
				oMdlGIE:LoadValue('GIE_SEQ', StrZero(nSeq,TamSx3("GIE_SEQ")[1])	)//oModelOrc:GetModel('GQIDETAIL'):GetValue('GQI_SEQ',nY)
				oMdlGIE:LoadValue('GIE_SENTID',	cSentido)
				oMdlGIE:LoadValue('GIE_HORCAB',	oModelOrc:GetModel('GQIDETAIL'):GetValue('GQI_HRORIG',nY))
				oMdlGIE:LoadValue('GIE_HORLOC',	oModelOrc:GetModel('GQIDETAIL'):GetValue('GQI_HRORIG',nY))	
				oMdlGIE:LoadValue('GIE_IDLOCP',	oModelOrc:GetModel('GQIDETAIL'):GetValue('GQI_CODORI',nY)) 
				oMdlGIE:LoadValue('GIE_HORDES',	oModelOrc:GetModel('GQIDETAIL'):GetValue('GQI_HRDEST',nY))
				oMdlGIE:LoadValue('GIE_IDLOCD',	oModelOrc:GetModel('GQIDETAIL'):GetValue('GQI_CODDES',nY))
				oMdlGIE:LoadValue('GIE_TEMPO',	StrTran(GTDeltaTime(dDtIniGQI,cHrIniGQI,dDtFimGQI,cHrFimGQI),':',''))

				If (dDtIniGQI != dDtFimGQI)
					nDiaDec := DateDiffDay(dDtIniGQI, dDtFimGQI)
					oMdlGIE:LoadValue('GIE_DIA', nDiaDec)
				EndIf
				
				If ( (nY == nLength) .Or.;
					(nY < nLength .and. cSentido <> oModelOrc:GetModel('GQIDETAIL'):GetValue('GQI_SENTID',(nY+1))))
				
					oMdlGID:LoadValue('GID_HORFIM',	oModelOrc:GetModel('GQIDETAIL'):GetValue('GQI_HRDEST',nY))

					If GID->(FieldPos('GID_REVCON')) > 0
						oMdlGID:LoadValue('GID_REVCON',	oModelOrc:GetModel('GYDDETAIL'):GetValue('GYD_REVISA'))
					EndIf 
				
					If (oModel:VldData())
						oModel:CommitData()									
					Else
						cMsgErro := Alltrim(oModel:GetErrorMessage()[6]) + ". " + Alltrim(oModel:GetErrorMessage()[7])
						Help(,,"G900GerSer",, cMsgErro, 1,0)								
						lRet := .F.
					EndIf

					oModel:DeActivate()		

					lHeaderWriter := .T.

				EndIf

			EndIf

		Next nY //antes, era next nIdaVolta

	EndIf

Return lRet

/*/{Protheus.doc} G900GerVia
(long_description)
@type  Static Function
@author flavio.martins
@since 01/10/2020
@version 1.0
@param oModel, param_type, param_descr
@return nil, return_type, return_description
@example
(examples)
@see (links_or_references)
/*/
Function G900GerVia(nOpc)
Local lRet 		:= .T.
Local oMdl300B	
Local oMdl300C
Local oModelOrc 

// If MSGYESNO( STR0149,STR0150 ) //'Deseja Gerar viagens do Contrato posicionado?', 'Gerar Viagens'
// 	oModelOrc := FwLoadModel('GTPA900')
// 	oModelOrc:SetOperation(MODEL_OPERATION_VIEW)
// 	oModelOrc:Activate()
// EndIf

If !(GY0->GY0_STATUS $ '2|6') .And. nOpc != 2
	FwAlertWarning(STR0115) // "Status do contrato não permite a geração de viagens")
	Return .F.
Endif

If nOpc == 1

	oMdl300B := FwLoadModel("GTPA300B")
	oMdl300B:SetOperation(MODEL_OPERATION_UPDATE)

	If oModelOrc <> Nil
		oMdl300B:GetModel('HEADER'):GetStruct():SetProperty('*', MODEL_FIELD_WHEN, {||.F.})
	Else
		oMdl300B:GetModel('HEADER'):GetStruct():SetProperty('TPVIAGEM'	, MODEL_FIELD_WHEN, {||.F.})
		oMdl300B:GetModel('HEADER'):GetStruct():SetProperty('EXTRA'		, MODEL_FIELD_WHEN, {||.F.})
	Endif

	oMdl300B:GetModel('HEADER'):GetStruct():SetProperty('DATAINI', MODEL_FIELD_WHEN,  {||.T.})
	oMdl300B:GetModel('HEADER'):GetStruct():SetProperty('DATAFIM', MODEL_FIELD_WHEN,  {||.T.})
	oMdl300B:GetModel('HEADER'):GetStruct():SetProperty('LINHAINI', MODEL_FIELD_WHEN, {||.T.})
	oMdl300B:GetModel('HEADER'):GetStruct():SetProperty('LINHAFIM', MODEL_FIELD_WHEN, {||.T.})

	oMdl300B:Activate()

	oMdl300B:GetModel('HEADER'):LoadValue('OPCAO', 1)
	oMdl300B:GetModel('HEADER'):LoadValue('TPVIAGEM', '3')
	oMdl300B:GetModel('HEADER'):LoadValue('EXTRA', '2')

	If oModelOrc <> Nil 

		oMdl300B:GetModel('HEADER'):LoadValue('DATAINI', oModelOrc:GetModel('GYDDETAIL'):GetValue('GYD_INIVIG'))
		oMdl300B:GetModel('HEADER'):LoadValue('DATAFIM', oModelOrc:GetModel('GYDDETAIL'):GetValue('GYD_FINVIG'))
		oMdl300B:GetModel('HEADER'):LoadValue('CLIEINI', oModelOrc:GetModel('GY0MASTER'):GetValue('GY0_CLIENT'))
		oMdl300B:GetModel('HEADER'):LoadValue('LOJAINI', oModelOrc:GetModel('GY0MASTER'):GetValue('GY0_LOJACL'))
		oMdl300B:GetModel('HEADER'):LoadValue('CLIEFIM', oModelOrc:GetModel('GY0MASTER'):GetValue('GY0_CLIENT'))
		oMdl300B:GetModel('HEADER'):LoadValue('LOJAFIM', oModelOrc:GetModel('GY0MASTER'):GetValue('GY0_LOJACL'))
		oMdl300B:GetModel('HEADER'):LoadValue('CONTRINI', oModelOrc:GetModel('GYDDETAIL'):GetValue('GYD_NUMERO'))
		oMdl300B:GetModel('HEADER'):LoadValue('CONTRFIM', oModelOrc:GetModel('GYDDETAIL'):GetValue('GYD_NUMERO'))
		oMdl300B:GetModel('HEADER'):LoadValue('LINHAINI', oModelOrc:GetModel('GYDDETAIL'):GetValue('GYD_CODGI2', 1))
		oMdl300B:GetModel('HEADER'):LoadValue('LINHAFIM', oModelOrc:GetModel('GYDDETAIL'):GetValue('GYD_CODGI2', oModelOrc:GetModel('GYDDETAIL'):GetLine()))

	Endif

	GTPA300B(oMdl300B)
	
	oMdl300B:DeActivate()
	oMdl300B:Destroy()	

ElseIf nOpc == 2

	oMdl300B := FwLoadModel("GTPA300B")
	oMdl300B:SetOperation(MODEL_OPERATION_UPDATE)

	oMdl300B:GetModel('HEADER'):GetStruct():SetProperty('TPVIAGEM', MODEL_FIELD_WHEN, {||.F.})

	oMdl300B:Activate()

	oMdl300B:GetModel('HEADER'):LoadValue('OPCAO', 2)
	oMdl300B:GetModel('HEADER'):LoadValue('TPVIAGEM', '3')

	GTPA300B(oMdl300B)
	
	oMdl300B:DeActivate()
	oMdl300B:Destroy()	

ElseIf nOpc == 3

	oMdl300C := FwLoadModel("GTPA300C")
	oMdl300C:SetOperation(MODEL_OPERATION_UPDATE)

	oMdl300C:Activate()

	oMdl300C:GetModel('HEADER'):GetStruct():SetProperty('TPVIAGEM', MODEL_FIELD_WHEN, {||.F.})
	oMdl300C:GetModel('HEADER'):LoadValue('TPVIAGEM', '3')

	GTPA300C(oMdl300C)

	oMdl300C:DeActivate()
	oMdl300C:Destroy()	

Endif

Return lRet

/*/{Protheus.doc} AfterActiv
//TODO Descrição auto-gerada.
@author GTP
@since 16/11/2020
@version 1.0
@return ${return}, ${return_description}
@param oView, object, descricao
@type function
/*/
Static Function AfterActiv(oView)
Local oModel := oView:GetModel()

If Empty(oModel:GetModel('GY0MASTER'):GetValue('GY0_REVISA'))
	oView:HideFolder('FOLDER',3, 2)
	oView:SelectFolder("FOLDER",1,2)
Endif

oView:Refresh()

If oModel:GetModel('GY0MASTER'):GetValue('GY0_MOTREV') == '2' .And.;
	oModel:GetOperation() == MODEL_OPERATION_INSERT
	GTPA900A(oView)
Endif

Return

/*/
{Protheus.doc} G900Ctr()"
(long_description)
@type  Function
@author Eduardo Ferreira
@since 19/03/2021
@version 12.1.30
@param 
@return 
/*/
Function G900Ctr()
Local cCodigo := ''
Local cStatus := ''

If GY0->(FieldPos("GY0_CODCN9")) > 0
	cCodigo := GY0->GY0_CODCN9
EndIf

If GY0->(FieldPos("GY0_STATUS")) > 0
	cStatus := GY0->GY0_STATUS
EndIf

IF cStatus != '1'
	DbSelectArea("CN9")
	CN9->(dbSetOrder(1))

	If CN9->(dbSeek(xFilial('CN9')+cCodigo)) 
		FWMsgRun(, {||FWExecView(STR0059,"CNTA301",MODEL_OPERATION_VIEW,,{|| .T.})},"", STR0060) //Contrato //Buscando Contrato		
	EndIf
Else
	MsgAlert(STR0061, STR0062) //Não foi gerado contrato //Atenção
EndIf

Return 

/*/{Protheus.doc} VldCn1()
(long_description)
@type  Static Function
@author Eduardo Ferreira
@since 23/03/2021
@version 12.1.30
@param cod
@return lRet
/*/
Static Function VldCn1(cod)
Local cAliasCn1 := GetNextAlias()
Local cMsgVld	:= ''

BeginSql Alias cAliasCn1
	SELECT 
		CN1.CN1_ESPCTR,
		CN1.CN1_CTRFIX,
		CN1.CN1_VLRPRV,
		CN1.CN1_MEDEVE
		
	FROM 
		%Table:CN1% CN1
	WHERE 
		CN1.CN1_FILIAL = %xFilial:CN1% AND
		CN1.CN1_CODIGO = %Exp:cod% AND
		CN1.%NotDel% 
EndSql

If (cAliasCn1)->CN1_ESPCTR <> '2'
	cMsgVld := STR0065 // "Espécie do tipo de contrato diferente de Venda"
	Return cMsgVld
Endif

If (cAliasCn1)->CN1_CTRFIX <> '2'
	cMsgVld := STR0066 // "Contrato selecionado não pode ser do tipo fixo"
	Return cMsgVld
Endif

If (cAliasCn1)->CN1_VLRPRV <> '2'
	cMsgVld := STR0067 // "Contrato selecionado deve estar configurado com Previsão Financeira igual a 'Não'"
	Return cMsgVld
Endif

If (cAliasCn1)->CN1_MEDEVE <> '1'
	cMsgVld := STR0068 // "Contrato selecionado deve estar configurado com Medição Eventual igual a 'Sim'"
	Return cMsgVld
Endif

(cAliasCn1)->(dbCloseArea())

Return cMsgVld

/*/{Protheus.doc} VldCnl()
(long_description)
@type  Static Function
@author Eduardo Ferreira
@since 23/03/2021
@version 12.1.30
@param cod
@return lRet
/*/
Static Function VldCnl(cod)
Local cAliasCnl := GetNextAlias()
Local cMsgVld	:= ''

BeginSql Alias cAliasCnl
	SELECT 
		CNL.CNL_CTRFIX,
		CNL.CNL_VLRPRV,
		CNL.CNL_MEDEVE
	FROM 
		%Table:CNL% CNL
	WHERE 
		CNL.CNL_FILIAL = %xFilial:CNL% AND
		CNL.CNL_CODIGO = %Exp:cod% AND
		CNL.%NotDel% 
EndSql

If !((cAliasCnl)->CNL_MEDEVE $ '0|1')
	cMsgVld :=  STR0069 // "Medição eventual do tipo de planilha não pode estar configurada como 'Não'"
	Return cMsgVld
Endif

If !((cAliasCnl)->CNL_CTRFIX $ '0|2')
	cMsgVld :=  STR0070 // "Tipo de planilha deve estar configurada como 'Fixo' ou 'Conforme Contrato'"
	Return cMsgVld
Endif

If !((cAliasCnl)->CNL_VLRPRV $ '0|2')
	cMsgVld :=  STR0071 // "Previsão financeira do tipo de planilha deve estar configurada como 'Não' ou 'Conforme Contrato'"
	Return cMsgVld
Endif

(cAliasCnl)->(dbCloseArea())

Return cMsgVld

/*/{Protheus.doc} UpdDelCtr()
(long_description)
@type  Function
@author Eduardo Ferreira
@since 24/03/2021
@version version
@param  nOper
@return lRet
/*/
Function UpdDelCtr(nOper)
Local cStatus 	:= ''
Local lRet    	:= .T.	
Local cMsgErro	:= ''
Local oModel	:= FwLoadModel('GTPA900')

If ValidaDic(@cMsgErro)

	oModel:SetOperation(nOper)

	If GY0->GY0_MOTREV == '2'
		ConfigModel(oModel, 2)
	Endif

	oModel:Activate()

	If GY0->(FieldPos("GY0_STATUS")) > 0
		cStatus := GY0->GY0_STATUS
	EndIf

	If (nOper = 4 .Or. nOper = 5) .And. cStatus $ '2|3|6|7'
		MsgAlert(STR0063, STR0064) //'Este registro não pode ser alterado ou excluído.' // Contrato gerado
		lRet := .F.
	Else
		if nOper = 4
			FwExecView(STR0003,"VIEWDEF.GTPA900",MODEL_OPERATION_UPDATE,,,,/*5*/,/*aEnableButtons*/,,,,oModel) // 'Alterar'
		else
			FwExecView(STR0004,"VIEWDEF.GTPA900",MODEL_OPERATION_DELETE,,,,/*5*/,/*aEnableButtons*/,,,,oModel) // 'Excluir'
		endif
	EndIf	

Else
    FwAlertHelp(cMsgErro, STR0017)	// "Banco de dados desatualizado, não é possível iniciar a rotina"
Endif

oModel:Deactivate()
oModel:Destroy()

Return lRet

/*/{Protheus.doc} G900IniRev()
//TODO Descrição auto-gerada.
@author flavio.martins
@since 12/05/2021
@version 1.0
@return ${return}, ${return_description}
@type function
/*/
Function G900IniRev(nOpc)
Local lRet 		:= .T.
Local cMsgErro	:= ''
Local oMdlRev	:= FwLoadModel('GTPA900')
Local cNumero   := GY0->GY0_NUMERO

If ValidaDic(@cMsgErro)

	If GY0->GY0_STATUS != '2' .And. GY0->GY0_STATUS != '6'
		FwAlertHelp(STR0087) //'Status atual do orçamento não permite revisão
		Return
	Endif

	If ExistRevisa()
		FwAlertHelp(STR0096) //'Contrato já possui uma revisão em andamento'
		Return
	Endif

	If nOpc == 2 .And. GY0->GY0_FLGREJ == '2'
		FwAlertHelp(STR0105) //"Configuração do contrato não permite reajustes"
		Return
	Endif

	oMdlRev:SetOperation(MODEL_OPERATION_INSERT)

	ConfigModel(oMdlRev, nOpc)

	oMdlRev:GetModel('GY0MASTER'):GetStruct():SetProperty('GY0_NUMERO' , MODEL_FIELD_INIT , FwBuildFeature(STRUCT_FEATURE_INIPAD , '' ) )
	oMdlRev:Activate(.T.)

	oMdlRev:LoadValue('GY0MASTER', 'GY0_NUMERO', cNumero)
	oMdlRev:LoadValue('GY0MASTER', 'GY0_STATUS', '5')

	Do Case
		Case nOpc = 1
			oMdlRev:GetModel('GY0MASTER'):LoadValue('GY0_MOTREV', '1')
		Case nOpc = 2
			oMdlRev:LoadValue('GY0MASTER', 'GY0_MOTREV', '2')
			oMdlRev:LoadValue('GYYFIELDS', 'GYY_NUMERO', oMdlRev:GetValue('GY0MASTER','GY0_NUMERO'))
	EndCase

	FwExecView(STR0099,"VIEWDEF.GTPA900",MODEL_OPERATION_INSERT,,,,/*5*/,/*aEnableButtons*/,,,,oMdlRev) //"Revisão"
Else
    FwAlertHelp(cMsgErro, STR0017)	// "Banco de dados desatualizado, não é possível iniciar a rotina"
Endif

Return lRet

/*/{Protheus.doc} ConfigModel(oModel, nOpc)
//TODO Descrição auto-gerada.
@author flavio.martins
@since 19/05/2021
@version 1.0
@return ${return}, ${return_description}
@type function
/*/
Static Function ConfigModel(oModel, nOpc)
Local aNCopyGY0	:= {'GY0_ATIVO','GY0_TIPREV','GY0_MOTREV','GY0_JUSREV','GY0_DATREV'}
Local aNCopyGYY	:= {'GYY_PERGYD','GYY_PERGQZ','GYY_PERGYX','GYY_PERGQJ'}

oModel:GetModel("GYYFIELDS"):SetFldNoCopy(aNCopyGYY)
oModel:GetModel("GY0MASTER"):SetFldNoCopy(aNCopyGY0)
oModel:GetModel("GYDDETAIL"):SetFldNoCopy({'GYD_REVISA'})
oModel:GetModel("GQIDETAIL"):SetFldNoCopy({'GQI_REVISA'})
oModel:GetModel("GYXDETAIL"):SetFldNoCopy({'GYX_REVISA'})
oModel:GetModel("GQZDETAIL"):SetFldNoCopy({'GQZ_REVISA'})
oModel:GetModel("GQJDETAIL"):SetFldNoCopy({'GQJ_REVISA'})
oModel:GetModel("GYYFIELDS"):SetFldNoCopy({'GYY_REVISA'})

If nOpc == 1
	oModel:GetModel('GYYFIELDS'):SetOnlyQuery(.T.)
	oModel:GetModel('GY0MASTER'):GetStruct():SetProperty('GY0_CLIENT' , MODEL_FIELD_WHEN, {||.F.})
	oModel:GetModel('GY0MASTER'):GetStruct():SetProperty('GY0_LOJACL' , MODEL_FIELD_WHEN, {||.F.})
	oModel:GetModel('GY0MASTER'):GetStruct():SetProperty('GY0_CODVD'  , MODEL_FIELD_WHEN, {||.F.})
ElseIf nOpc == 2
	oModel:GetModel('GY0MASTER'):GetStruct():SetProperty('*' , MODEL_FIELD_WHEN, {||.F.})
	oModel:GetModel('GY0MASTER'):GetStruct():SetProperty('GY0_TIPREV' , MODEL_FIELD_WHEN, {||.T.})
	oModel:GetModel('GY0MASTER'):GetStruct():SetProperty('GY0_JUSREV' , MODEL_FIELD_WHEN, {||.T.})

	oModel:GetModel('GYDDETAIL'):SetNoInsertLine(.T.)
	oModel:GetModel('GYDDETAIL'):SetNoUpdateLine(.T.)
	oModel:GetModel('GYDDETAIL'):SetNoDeleteLine(.T.)
	oModel:GetModel('GQJDETAIL'):SetNoInsertLine(.T.)
	oModel:GetModel('GQJDETAIL'):SetNoUpdateLine(.T.)
	oModel:GetModel('GQJDETAIL'):SetNoDeleteLine(.T.)
	oModel:GetModel('GYXDETAIL'):SetNoInsertLine(.T.)
	oModel:GetModel('GYXDETAIL'):SetNoUpdateLine(.T.)
	oModel:GetModel('GYXDETAIL'):SetNoDeleteLine(.T.)
	oModel:GetModel('GQZDETAIL'):SetNoInsertLine(.T.)
	oModel:GetModel('GQZDETAIL'):SetNoUpdateLine(.T.)
	oModel:GetModel('GQZDETAIL'):SetNoDeleteLine(.T.)
	oModel:GetModel('GQIDETAIL'):SetNoInsertLine(.T.)
	oModel:GetModel('GQIDETAIL'):SetNoUpdateLine(.T.)
	oModel:GetModel('GQIDETAIL'):SetNoDeleteLine(.T.)
Endif

Return

/*/{Protheus.doc} ExistRevisa()
//TODO Descrição auto-gerada.
@author flavio.martins
@since 19/05/2021
@version 1.0
@return ${return}, ${return_description}
@type function
/*/
Static Function ExistRevisa()
Local lRet 		:= .F.
Local cAliasGY0	:= GetNextAlias()

BeginSql Alias cAliasGY0
	SELECT GY0_NUMERO FROM %Table:GY0%
	WHERE
	GY0_NUMERO = %Exp:GY0->GY0_NUMERO%
	AND GY0_STATUS = '5'
	AND %NotDel%
EndSql

lRet :=  !Empty((cAliasGY0)->GY0_NUMERO)

(cAliasGY0)->(dbCloseArea())

Return lRet

/*/{Protheus.doc} SetRevisao()
//TODO Descrição auto-gerada.
@author flavio.martins
@since 12/05/2021
@version 1.0
@return ${return}, ${return_description}
@type function
/*/
Static Function SetRevisao(oModel)
Local cAliasGY0		:= GetNextAlias()
Local cRevisao		:= 0
Local cNumero		:= Alltrim(oModel:GetModel('GY0MASTER'):GetValue('GY0_NUMERO'))

If Empty(cNumero)
	cNumero := GY0->GY0_NUMERO
EndIf
	
BeginSql Alias cAliasGY0

	SELECT MAX(GY0_REVISA) NUMREV
	FROM %Table:GY0%
	WHERE GY0_FILIAL = %xFilial:GY0%
	  AND GY0_NUMERO = %Exp:cNumero%
	  AND %NotDel%

EndSql
If Empty((cAliasGY0)->NUMREV )
	cRevisao:= 0
Else
	cRevisao:= Val((cAliasGY0)->NUMREV)
EndIf

cRevisao := StrZero((cRevisao+1),TamSx3('GY0_REVISA')[1])

(cAliasGY0)->(dbCloseArea())

Return cRevisao

/*/{Protheus.doc} G900GerRev()
//TODO Descrição auto-gerada.
@author flavio.martins
@since 12/05/2021
@version 1.0
@return ${return}, ${return_description}
@type function
/*/
Function G900GerRev()
Local lRet		:= .T.
Local oModel	:= FwLoadModel('GTPA900')
Local nPercReaj := 0
Local cTipoRev 	:= ''
Local cJustRev	:= ''
Local cMsgErro	:= ''

If ValidaDic(@cMsgErro)

	If GY0->GY0_STATUS != '5' 
		FwAlertHelp(STR0102) // "Opção válida apenas para contratos em revisão"
		Return
	Endif

	oModel:SetOperation(MODEL_OPERATION_VIEW)
	oModel:Activate()

	cTipoRev := oModel:GetModel('GY0MASTER'):GetValue('GY0_TIPREV')
	cJustRev := oModel:GetModel('GY0MASTER'):GetValue('GY0_JUSREV')

	If Empty(cTipoRev)
		FwAlertHelp(STR0088, STR0089) //'Tipo de revisão não informado', 'Tipo de revisão obrigatório'
		Return .F.
	Endif

	If Empty(cJustRev)
		FwAlertHelp(STR0090, STR0091) //'Justificativa da revisão não informado', 'Justificativa da revisão obrigatória'
		Return .F.
	Endif

	If oModel:GetModel('GY0MASTER'):GetValue('GY0_MOTREV') == '2'
		nPercReaj := oModel:GetModel('GYYFIELDS'):GetValue('GYY_PERGYD') +;
					oModel:GetModel('GYYFIELDS'):GetValue('GYY_PERGQJ') +;
					oModel:GetModel('GYYFIELDS'):GetValue('GYY_PERGYX') +;
					oModel:GetModel('GYYFIELDS'):GetValue('GYY_PERGQZ')

		If nPercReaj == 0
			FwAlertHelp(STR0100, STR0101) //'Nenhum percentual de reajuste foi informado', 'Informe os percentuais antes de efetivar a revisão'
			Return
		Endif

	Endif

	FwMsgRun( ,{|| lRet := GrvRevisa(oModel)},, STR0097) //"Gerando Revisão...." 
Else
    FwAlertHelp(cMsgErro, STR0017)	// "Banco de dados desatualizado, não é possível iniciar a rotina"
Endif

oModel:DeActivate()
oModel:Destroy()

Return lRet

/*/{Protheus.doc} GrvRevisa()
//TODO Descrição auto-gerada.
@author flavio.martins
@since 12/05/2021
@version 1.0
@return ${return}, ${return_description}
@type function
/*/
Static Function GrvRevisa(oModel)
Local lRet 		:= .T.
Local oMdlCntr	:= Nil
Local cContrato	:= oModel:GetValue('GY0MASTER', 'GY0_CODCN9')
Local cRevAtu	:= oModel:GetValue('GY0MASTER', 'GY0_REVISA')
Local cRevVig	:= GetRevVig(oModel:GetValue('GY0MASTER', 'GY0_NUMERO'))

CN9->(dbSetOrder(1))
If CN9->(dbSeek(xFilial("CN9")+GY0->GY0_CODCN9+cRevVig))
 	
	Begin Transaction

 	A300STpRev("G")									
 	
 	oMdlCntr := FwLoadModel("CNTA300")			
	oMdlCntr:SetOperation(MODEL_OPERATION_INSERT)		
	 
	oMdlCntr:Activate(.T.) 

	If !(oMdlCntr:IsActive())
		If !(IsBlind())
			lRet := .F.
			DisarmTransaction()
	        JurShowErro(oMdlCntr:GetErrormessage())	
		Endif
	Else
		oMdlCntr:SetValue('CN9MASTER','CN9_TIPREV'	, oModel:GetModel('GY0MASTER'):GetValue('GY0_TIPREV'))
		oMdlCntr:SetValue('CN9MASTER','CN9_JUSTIF'	, oModel:GetModel('GY0MASTER'):GetValue('GY0_JUSREV'))

		oMdlCntr:SetValue('CN9MASTER','CN9_NUMERO'	, oModel:GetModel('GY0MASTER'):GetValue('GY0_CODCN9'))
		oMdlCntr:SetValue('CN9MASTER','CN9_DTINIC'	, oModel:GetModel('GY0MASTER'):GetValue('GY0_DTINIC'))
		oMdlCntr:SetValue('CN9MASTER','CN9_UNVIGE'	, oModel:GetModel('GY0MASTER'):GetValue('GY0_UNVIGE'))
		oMdlCntr:SetValue('CN9MASTER','CN9_VIGE'  	, oModel:GetModel('GY0MASTER'):GetValue('GY0_VIGE'))
		oMdlCntr:SetValue('CN9MASTER','CN9_MOEDA'	, oModel:GetModel('GY0MASTER'):GetValue('GY0_MOEDA')) 
		oMdlCntr:SetValue('CN9MASTER','CN9_TPCTO'	, oModel:GetModel('GY0MASTER'):GetValue('GY0_TPCTO'))
		oMdlCntr:SetValue('CN9MASTER','CN9_CONDPG'	, oModel:GetModel('GY0MASTER'):GetValue('GY0_CONDPG'))
		If GY0->(FieldPos("GY0_NATURE")) > 0
			oMdlCntr:SetValue('CN9MASTER','CN9_NATURE', oModel:GetModel('GY0MASTER'):GetValue('GY0_NATURE'))
		EndIf
		oMdlCntr:SetValue('CN9MASTER','CN9_AUTO'	, '1')    
			
		//Cliente/Fornecedor do Contrato
		oMdlCntr:LoadValue('CNCDETAIL','CNC_CLIENT'  , oModel:GetModel('GY0MASTER'):GetValue('GY0_CLIENT'))
		oMdlCntr:LoadValue('CNCDETAIL','CNC_LOJACL'  , oModel:GetModel('GY0MASTER'):GetValue('GY0_LOJACL'))

		//Vendedor do Contrato
		oMdlCntr:LoadValue('CNUDETAIL','CNU_CODVD'   , oModel:GetModel('GY0MASTER'):GetValue('GY0_CODVD'))
		oMdlCntr:LoadValue('CNUDETAIL','CNU_PERCCM'  , oModel:GetModel('GY0MASTER'):GetValue('GY0_PCOMVD'))

		If oMdlCntr:VldData() 
			oMdlCntr:CommitData()
		Else
			lRet := .F.
			DisarmTransaction()
			JurShowErro(oMdlCntr:GetErrormessage())	
		Endif

		If lRet

			oMdlCntr:Deactivate()

			FwMsgRun( ,{|| lRet :=  AprovaRev(cContrato, cRevAtu)},, STR0106) //"Aprovando Revisão..."

			lRet := InativGY0()

			If lRet
				If G900GerLin(oModel)
					RecLock('GY0', .F.)
						GY0->GY0_ATIVO  := '1'
						GY0->GY0_STATUS := '6'
						GY0->GY0_DATREV := dDataBase
					GY0->(MsUnLock())
					
					FwAlertSuccess(STR0093) //'Revisão gerada com sucesso'
				Else
					lRet := .F.
					DisarmTransaction()
				EndIf
			Endif
		Endif	
	Endif

	End Transaction

Else
	lRet := .F.
	FwAlertHelp(STR0092) //'Contrato não encontrado'
Endif

Return lRet

/*/{Protheus.doc} InativGY0
//TODO Descrição auto-gerada.
@author flavio.martins
@since 12/05/2021
@version 1.0
@return ${return}, ${return_description}
@type function
/*/
Static Function InativGY0()
Local lRet 		:= .T.
Local cAliasGY0	:= GetNextAlias()
Local aAreaGY0  := GY0->(GetArea()) 

BeginSql Alias cAliasGY0

	SELECT R_E_C_N_O_ AS Recno 
	FROM %Table:GY0%
	WHERE
	GY0_FILIAL = %xFilial:GY0%
	AND GY0_NUMERO = %Exp:GY0->GY0_NUMERO%
	AND GY0_ATIVO = '1'
	AND %NotDel%

EndSql

GY0->(dbGoto((cAliasGY0)->Recno))

RecLock('GY0', .F.)
	GY0->GY0_ATIVO  := '2'
	GY0->GY0_STATUS := '7'
GY0->(MsUnLock())

(cAliasGY0)->(dbCloseArea())

RestArea(aAreaGY0)

Return lRet

/*/{Protheus.doc} ValidaDic
//TODO Descrição auto-gerada.
@author flavio.martins
@since 11/05/2021
@version 1.0
@return ${return}, ${return_description}
@param
@type function
/*/
Static Function ValidaDic(cMsgErro)
Local lRet          := .T.
Local aTables       := {'GY0','GYD','GQI','GQZ','GYX','GQJ','GYY'}
Local aFields       := {}
Local nX            := 0
Default cMsgErro    := ''

aFields := {'GY0_REVISA','GY0_DATREV','GY0_JUSREV',;
            'GY0_TIPREV','GY0_ATIVO','GYD_REVISA',;
			'GQI_REVISA','GQZ_REVISA','GYX_REVISA',;
			'GQJ_REVISA','GYY_NUMERO','GYY_REVISA',;
			'GY0_MOTREV','GYY_PERGYD','GYY_PERGYX',;
			'GYY_PERGQJ','GYY_PERGQZ','GYD_VLRACO'}
			

For nX := 1 To Len(aTables)
    If !(GTPxVldDic(aTables[nX], {}, .T., .F., @cMsgErro))
        lRet := .F.
        Exit
    Endif
Next

if Empty(cMsgErro)
	For nX := 1 To Len(aFields)
	    If !(Substr(aFields[nX],1,3))->(FieldPos(aFields[nX]))
	        lRet := .F.
	        cMsgErro := I18n("Campo #1 não se encontra no dicionário",{aFields[nX]})
	        Exit
	    Endif
	Next
EndIf

Return lRet

/*/{Protheus.doc} FieldWhen(oMdl, cField, uVal)
//TODO Descrição auto-gerada.
@author flavio.martins
@since 12/05/2021
@version 1.0
@return ${return}, ${return_description}
@type function
/*/
Static Function FieldWhen(oMdl, cField, uVal)
Local lRet     := .T.
Local oModel   := oMdl:GetModel()
Local oMdlGY0  := oModel:GetModel('GY0MASTER')
Local oMdlGYD  := oModel:GetModel('GYDDETAIL')

Local nLineGYD := oMdlGYD:GetLine()

Do Case
	Case cField == "GY0_TIPREV"
        lRet := !Empty(oMdl:GetValue('GY0_REVISA'))
	Case cField == "GYD_VLRACO"  .AND. GYD->(FieldPos("GYD_VLRACO")) > 0
        lRet := oMdlGYD:GetValue('GYD_PRECON',nLineGYD) $ '2|3|4'
	Case cField == "GYD_VLRTOT"  .AND. GYD->(FieldPos("GYD_VLRTOT")) > 0
        lRet := oMdlGYD:GetValue('GYD_PLCONV',nLineGYD) != '1'
	Case cField == "GYD_VLREXT"  .AND. GYD->(FieldPos("GYD_VLREXT")) > 0
        lRet := oMdlGYD:GetValue('GYD_PLEXTR',nLineGYD) != '1'
	Case cField == "GYD_IDPLCO"  .AND. GYD->(FieldPos("GYD_IDPLCO")) > 0
        lRet := oMdlGYD:GetValue('GYD_PLCONV',nLineGYD) == '1'
	Case cField == "GYD_IDPLEX"  .AND. GYD->(FieldPos("GYD_IDPLEX")) > 0
        lRet := oMdlGYD:GetValue('GYD_PLEXTR',nLineGYD) == '1'
	Case cField == "GY0_VLRACO"  .AND. GY0->(FieldPos("GY0_VLRACO")) > 0
        lRet := oMdlGY0:GetValue('GY0_PLCONV') <> '1'	
	Case cField == "GY0_IDPLCO"  .AND. GY0->(FieldPos("GY0_IDPLCO")) > 0
        lRet := oMdlGY0:GetValue('GY0_PLCONV') == '1'
	Case cField == "GY0_PREEXT"  .AND. GY0->(FieldPos("GY0_PREEXT")) > 0
        lRet := oMdlGY0:GetValue('GY0_PLCONV') <> '1'
	Case cField == "GY0_PLCONV"  .AND. GY0->(FieldPos("GY0_PLCONV")) > 0
        lRet := oMdlGY0:GetValue('GY0_VLRACO') == 0
	Case cField == "GY0_ALTLOG"  .AND. GY0->(FieldPos("GY0_ALTLOG")) > 0
        lRet := .F.
	Case cField $ "GYD_PRODUT|GYD_PRONOT"
        lRet := WhenRateio(oMdlGYD:GetValue('GYD_CLIENT',nLineGYD),oMdlGYD:GetValue('GYD_LOJACL',nLineGYD))
	Case cField == "GYD_VLFAT1"  .AND. GYD->(FieldPos("GYD_VLFAT1")) > 0
        lRet := oMdlGYD:GetValue('GYD_PLCONV',nLineGYD) == '1'
	Case cField == "GYD_VLFAT2"  .AND. GYD->(FieldPos("GYD_VLFAT2")) > 0
        lRet := oMdlGYD:GetValue('GYD_PLEXTR',nLineGYD) == '1'			
	Case cField == "GYD_CODGI2"  .AND. GYD->(FieldPos("GYD_CODGI2")) > 0
        lRet := !IsInCallStack("G900IniRev") 			
EndCase

Return lRet

/*/{Protheus.doc} GetRevVig(cNumero)
//TODO Descrição auto-gerada.
@author flavio.martins
@since 11/05/2021
@version 1.0
@return ${return}, ${return_description}
@type function
/*/
Static Function GetRevVig(cNumero)
Local cAliasGY0	:= GetNextAlias()
Local cCodRev	:= ''

BeginSql Alias cAliasGY0 

	SELECT GY0_REVISA
		FROM %Table:GY0%
	WHERE	
	GY0_FILIAL = %xFilial:GY0%
	AND GY0_NUMERO = %Exp:cNumero%
	AND GY0_ATIVO = '1'
	AND %NotDel%

EndSql

If !Empty((cAliasGY0)->GY0_REVISA)
	cCodRev := (cAliasGY0)->GY0_REVISA
Endif

(cAliasGY0)->(dbCloseArea())

Return cCodRev

/*/{Protheus.doc} AprovaRev(cNumero, cRevisa)
//TODO Descrição auto-gerada.
@author flavio.martins
@since 11/05/2021
@version 1.0
@return ${return}, ${return_description}
@type function
/*/
Static Function AprovaRev(cNumero, cRevisa)
Local lRet 		:= .T.
Local cMsgErro	:= ''
Local nRet		:= 0

CN9->(dbSetOrder(1))
If CN9->(dbSeek(xFilial('CN9')+cNumero+cRevisa))
	
	nRet := CN300Aprov(.T.,,@cMsgErro) //- Função retorna 0 em caso de falha e 1 em caso de sucesso, também retorna a mensagem de erro por referência através do parâmetro cMsgErro.
	If nRet == 1
		lRet := .T.
	Else
		FwAlertHelp(STR0103+cNumero+ " "+cMsgErro) // "Erro na aprovação do contrato "
	EndIf

EndIf	

Return lRet

/*/{Protheus.doc} G900Commit(oModel)	
Commit do modelo
@author flavio.martins
@since 15/08/2021
@version 1.0
@return lógico
@type function
/*/
Static Function G900Commit(oModel)	
Local lRet		:= .T.
Local nOpc		:= oModel:GetOperation()
Local oMdl900B	:= Nil

lRet := FwFormCommit(oModel)

If (nOpc ==  3 .Or. nOpc == 4) 

	If AliasInDic('H69') .And. FindFunction('GTPA900B')

		oMdl900B := FwLoadModel('GTPA900B')
		oMdl900B:SetOperation(MODEL_OPERATION_UPDATE)
		oMdl900B:Activate()

		If oMdl900B:IsActive()
			G900BCopy(oMdl900B)

			If oMdl900B:VldData()
				oMdl900B:CommitData()
			Endif
		Endif

	Endif
	

Endif 

Return lRet

/*/{Protheus.doc} ValidDocs()	
Valida pendência de checklist dos documentos operacionais do contrato
@author flavio.martins
@since 22/08/2022
@version 1.0
@return lógico
@type function
/*/
Static Function ValidDocs()
Local lRet 	:= .T.

If ExistDocs()

	If !(IsBlind() )
		If FwAlertYesNo(STR0111, STR0020) //"Encontrado documentos obrigatórios para o contrato. Deseja realizar o checklist agora ? ", "Atenção"
			GTPA900C()
		EndIf
	Endif

	If ExistDocs()
		lRet := .F.
		FwAlertWarning(STR0112,STR0020) //"Preencha o campo data de Validade do Orçamento", "Atenção"
	Endif

Endif

Return lRet

/*/{Protheus.doc} ExistDocs()	
Verifica se existem documentos pendentes de checklist
@author flavio.martins
@since 22/08/2022
@version 1.0
@return lógico
@type function
/*/
Static Function ExistDocs()
Local lRet 		:= .T.
Local cAliasTmp	:= GetNextAlias()
If AliasInDic("H69")
	BeginSql Alias cAliasTmp 

		SELECT COALESCE(COUNT(H69_NUMERO), 0) AS TOTREG
		FROM %Table:H69%
		WHERE H69_FILIAL = %xFilial:H69%
		AND H69_NUMERO = %Exp:GY0->GY0_NUMERO%
		AND H69_REVISA = %Exp:GY0->GY0_REVISA%
		AND H69_EXIGEN IN ('1','3')
		AND H69_CHKLST = 'F'
		AND %NotDel%

	EndSql

	lRet := (cAliasTmp)->TOTREG > 0

	(cAliasTmp)->(dbCloseArea())
EndIf
Return lRet

/*/{Protheus.doc} G900VESLin
	(Valida se campos relacionados a cobrança de viagens extras sem linha estão preenchidos)
	@type  Function
	@author marcelo.adente
	@since 10/08/2022
	@version 1.0
	/*/
Function G900VESLin()
Local aArea := GetArea()

If !(GY0->GY0_STATUS $ '2|6')
	FwAlertWarning(STR0115) // "Status do contrato não permite a geração de viagens")
	Return .F.
Endif

DbSelectArea('GYN')

If GYN->(FieldPos("GYN_EXTCMP")) > 0
	If 	  GY0->(FieldPos("GY0_PREEXT")) > 0 ;
	.AND. GY0->(FieldPos("GY0_PRDEXT")) > 0 ;
	.AND. GY0->(FieldPos("GY0_PRONOT")) > 0 ;
	.AND. GY0->(FieldPos("GY0_VLRACO")) > 0 ;
	.AND. GY0->(FieldPos("GY0_PLCONV")) > 0 ;
	.AND. GY0->(FieldPos("GY0_IDPLCO")) > 0

		If (!Empty(GY0->GY0_PREEXT) .AND.;
			!Empty(GY0->GY0_PRDEXT) .AND.;
			!Empty(GY0->GY0_PRONOT) .AND.;
			!Empty(GY0->GY0_VLRACO)); 
			.OR.;
		(!Empty(GY0->GY0_PLCONV) .AND.;
			!Empty(GY0->GY0_IDPLCO))
			// Chama Rotina de criação de viagens  sem linha
			GTPA300(GY0->GY0_NUMERO,GY0->GY0_STATUS)
		Else
			MsgAlert(STR0108, STR0020)// 'Preencha os dados de Viagens Extra Sem Linha no Orçamento de Contrato', Atenção!
		EndIf
	EndIf
else
	MsgAlert(STR0144)
	RestArea(aArea)
EndIf

Return

/*/{Protheus.doc} g900GetOrder
	( Retorna Ordem dos Campos mencionados )
	@type  Static Function
	@author marcelo.adente
	@since 30/01/2023
	@version 1.0
	@param cCampo, String, Campo 
	@return cRet, String, Ordem associada
	@example
	(examples)
	@see (links_or_references)
/*/
Static Function g900GetOrder(cCampo)
Local aCampo 	:= {}
Local cRet		:= ''

//Orçamento do Contrato
aAdd(aCampo,{'GY0_NUMERO','01'})
aAdd(aCampo,{'GY0_CLIENT','02'})
aAdd(aCampo,{'GY0_LOJACL','03'})
aAdd(aCampo,{'GY0_NOMCLI','04'})
aAdd(aCampo,{'GY0_CODVD','05'})
aAdd(aCampo,{'GY0_NOMVD','06'})

//VIGENCIAS
aAdd(aCampo,{'GY0_DTINIC','01'})
aAdd(aCampo,{'GY0_UNVIGE','02'})
aAdd(aCampo,{'GY0_VIGE'	 ,'03'})
aAdd(aCampo,{'GY0_DTVIGE','04'})
aAdd(aCampo,{'GY0_UNORCV','05'})
aAdd(aCampo,{'GY0_VALORC','06'})
aAdd(aCampo,{'GY0_DTVORC','07'})
aAdd(aCampo,{'GY0_ALTLOG','08'})
aAdd(aCampo,{'GY0_ASSINA','09'})

//GERAIS
aAdd(aCampo,{'GY0_FILIAL','01'})
aAdd(aCampo,{'GY0_MOEDA','02'})
aAdd(aCampo,{'GY0_CONDPG','03'})
aAdd(aCampo,{'GY0_TPCTO','04'})
aAdd(aCampo,{'GY0_FLGREJ','05'})
aAdd(aCampo,{'GY0_FLGCAU','06'})
aAdd(aCampo,{'GY0_PCOMVD','07'})
aAdd(aCampo,{'GY0_KMFRAN','08'})
aAdd(aCampo,{'GY0_PRODUT','09'})
aAdd(aCampo,{'GY0_DSCPRD','10'})
aAdd(aCampo,{'GY0_TIPPLA','11'})
aAdd(aCampo,{'GY0_TABPRC','12'})
aAdd(aCampo,{'GY0_STATUS','13'})
aAdd(aCampo,{'GY0_CODCN9','14'})
aAdd(aCampo,{'GY0_REVISA','15'})
aAdd(aCampo,{'GY0_MOTREV','16'})
aAdd(aCampo,{'GY0_DATREV','17'})
aAdd(aCampo,{'GY0_TIPREV','18'})
aAdd(aCampo,{'GY0_JUSREV','19'})
aAdd(aCampo,{'GY0_ATIVO','20'})
aAdd(aCampo,{'GY0_NATURE','21'})
aAdd(aCampo,{'GY0_DTCANC','22'})
aAdd(aCampo,{'GY0_USUCAN','23'})
aAdd(aCampo,{'GY0_OBSCAN','24'})

//EXTRAORDINARIA
aAdd(aCampo,{'GY0_PRDEXT','01'})
aAdd(aCampo,{'GY0_PRDDSC','02'})
aAdd(aCampo,{'GY0_PRONOT','03'})
aAdd(aCampo,{'GY0_DPRDNF','04'})
aAdd(aCampo,{'GY0_VLRACO','05'})
aAdd(aCampo,{'GY0_PLCONV','06'})
aAdd(aCampo,{'GY0_IDPLCO','07'})
aAdd(aCampo,{'GY0_PREEXT','08'})

//GERLOG
aAdd(aCampo,{'GY0_ALTLOG','01'})

//Dados da Linha
aAdd(aCampo,{'GYD_NUMERO',	'01'})
aAdd(aCampo,{'GYD_SEQ',		'02'})
aAdd(aCampo,{'GYD_CLIENT',	'03'})
aAdd(aCampo,{'GYD_LOJACL',	'04'})
aAdd(aCampo,{'GYD_NOMCLI',	'05'})
aAdd(aCampo,{'GYD_RATEIO',	'06'})
aAdd(aCampo,{'GYD_CODGI2',	'07'})
aAdd(aCampo,{'GYD_SENTID',	'08'})
aAdd(aCampo,{'GYD_NUMCAR',	'09'})
aAdd(aCampo,{'GYD_ORGAO',	'10'})
aAdd(aCampo,{'GYD_DORGAO',	'11'})
aAdd(aCampo,{'GYD_PRODUT',	'12'})
aAdd(aCampo,{'GYD_DSCPRD',	'13'})
aAdd(aCampo,{'GYD_PRONOT',	'14'})
aAdd(aCampo,{'GYD_DPRDNF',	'15'})
aAdd(aCampo,{'GYD_LOCINI',	'16'})
aAdd(aCampo,{'GYD_DLOCIN',	'17'})
aAdd(aCampo,{'GYD_KMIDA',	'18'})
aAdd(aCampo,{'GYD_LOCFIM',	'19'})
aAdd(aCampo,{'GYD_DLOCFI',	'20'})
aAdd(aCampo,{'GYD_KMVOLT',	'21'})
aAdd(aCampo,{'GYD_TIPLIN',	'22'})
aAdd(aCampo,{'GYD_DTIPLI',	'23'})
aAdd(aCampo,{'GYD_KMGRRD',	'24'})
aAdd(aCampo,{'GYD_KMRDGR',	'25'})
aAdd(aCampo,{'GYD_SEG',		'26'})
aAdd(aCampo,{'GYD_TER',		'27'})
aAdd(aCampo,{'GYD_QUA',		'28'})
aAdd(aCampo,{'GYD_QUI',		'29'})
aAdd(aCampo,{'GYD_SEX',		'30'})
aAdd(aCampo,{'GYD_SAB',		'31'})
aAdd(aCampo,{'GYD_DOM',		'32'})
aAdd(aCampo,{'GYD_INIVIG',	'33'})
aAdd(aCampo,{'GYD_FINVIG',	'34'})
aAdd(aCampo,{'GYD_LOTACA',	'35'})
aAdd(aCampo,{'GYD_TPCARR',	'36'})
aAdd(aCampo,{'GYD_DESCAT',	'37'})
aAdd(aCampo,{'GYD_VIGCAR',	'38'})
aAdd(aCampo,{'GYD_ANOCAR',	'39'})
aAdd(aCampo,{'GYD_ATENDI',	'40'})
aAdd(aCampo,{'GYD_NRMOTO',	'41'})
aAdd(aCampo,{'GYD_CUSMOT',	'42'})
aAdd(aCampo,{'GYD_TPMAXC',	'43'})
aAdd(aCampo,{'GYD_PRECON',	'44'})
aAdd(aCampo,{'GYD_VLRACO',	'45'})
aAdd(aCampo,{'GYD_PLCONV',	'46'})
aAdd(aCampo,{'GYD_IDPLCO',	'47'})

If GYD->(FieldPos("GYD_VLFAT1")) > 0
	aAdd(aCampo,{'GYD_VLFAT1',	'48'})
Endif 

aAdd(aCampo,{'GYD_VLRTOT',	'48'})
aAdd(aCampo,{'GYD_PREEXT',	'49'})
aAdd(aCampo,{'GYD_VLREXT',	'50'})
aAdd(aCampo,{'GYD_PLEXTR',	'51'})
aAdd(aCampo,{'GYD_IDPLEX',	'52'})

If GYD->(FieldPos("GYD_VLFAT2")) > 0
	aAdd(aCampo,{'GYD_VLFAT2',	'53'})
Endif 

nPosCmp := aScan( aCampo , { |x| x[1] == cCampo})

If nPosCmp == 0
	cRet:='99'
Else
	cRet:=aCampo[nPosCmp][2]
EndIf

Asize(aCampo,0)

Return cRet

/*/{Protheus.doc} g900DtFim
	( Retorna data Final do Contrato ou Orçamento )
	@type  Static Function
	@author marcelo.adente
	@since 30/01/2023
	@version 1.0
	@param cCampo, String, Campo 
	@return cRet, String, Ordem associada
	@example
	(examples)
	@see (links_or_references)
/*/
Static Function G900DtFim(cTipV,dDtIni,nVig)
Local nX := 0
Local dDtFim
Local nDiaIni

If (!Empty(nVig) .Or. cTipV == "4") .And. !Empty(dDtIni)
	Do Case
		Case cTipV == "1"  //Dia
			dDtFim:= dDtIni + nVig
		Case cTipV == "2"  //Mes
			nDiaIni := Day(dDtIni) //Dia do início do contrato.
			dDtFim  := dDtIni
			For nX := 1 to nVig
				dDtFim += CalcAvanco(dDtFim,.F.,.F.,nDiaIni)
			Next
		Case cTipV == "3"  //Ano
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Valida ano bissexto                   ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If Day(dDtIni) == 29 .And. Month(dDtIni) == 2 .And. ((Year(dDtIni)+nVig) % 4 != 0)
				dDtFim := cTod("28/02/"+str(Year(dDtIni)+nVig))
			Else
				dDtFim := cTod(str(Day(dDtIni))+"/"+str(Month(dDtIni))+"/"+str(Year(dDtIni)+nVig))
			EndIf
			//segundo a legislação de contrato o primeiro dia não conta na vigencia sendo assim o dia de inicio é o mesmo dia do fim no mes final
		Case cTipV == "4"  //Indeterminada
			dDtFim := CTOD("31/12/49")//Retorna data limite do sistema
	EndCase
EndIf

Return dDtFim

/*/{Protheus.doc} G900ValIdaVolta
(Valida se Cadastro de Orçamento do Tipo 3-Ida e Volta esta de acordo com as regras)
@type  Function
@author marcelo.adente
@since 14/02/2023
@version 1.0
@param oModelOrc, object, Modelo do Orçamento
@return return_var, return_type, return_description
@example
(examples)
@see (links_or_references)
/*/
Static Function G900ValIdaVolta(oMdlGQI,oMdlGYD,nLnGYD)

	Local aValid 		:= GridToArray(oMdlGQI,{"GQI_SEQ","GQI_CODDES","GQI_CODORI","GQI_SENTID"})

	Local nFirst		:= 0
	Local nLast			:= 0
	Local nGQI 			:= 0 
	
	Local cMsgErro		:= ''
	Local cMsgSolu		:= ''

	Local aRet			:= {}

	Local lRet 			:= .T.
	//Busca a primeira linha válida: desconsiderando as linhas deletadas
	nFirst := aScan(aValid,{|x| !x[5]})
	//Busca a última Linha válida: desconsiderando as linhas deletadas
	For nLast := Len(aValid) to nFirst step -1
				
		If ( !(aValid[nLast,5]) )
			Exit
		EndIf

	Next nLast
	//Tem de ter mais de uma linha, pois é um itinerário de ida e volta 
	If ( nLast <= 1 )

		lRet := .F.

		cMsgErro := STR0158	//"Para linhas com sentido de 'Ida e Volta', "
		cMsgErro += STR0159	//"não pode existir somente uma linha no Grid de Itinerários."
		
		cMsgSolu := STR0160	//"O itinerário para sentido de '3-Ida e Volta' necessita finalizar-se "
		cMsgSolu += STR0161	//"na mesma localidade que iniciou-se."

	EndIf
	//Tem alguma linha inicial não apagada?
	If ( lRet .And. nFirst > 0 )
		
		If ( aValid[nFirst][3] != oMdlGYD:GetValue("GYD_LOCINI",nLnGYD) )
			
			lRet := .f.

			cMsgErro := STR0162	//"A localidade inicial da primeira linha do grid 'Itinerários' "
			cMsgErro += STR0163	//"precisar ser a mesma localidade inicial do grid 'Dado da Linha'."
			
			cMsgSolu := STR0164 + oMdlGYD:GetValue("GYD_LOCINI",nLnGYD) //"Utilize a localidade "
			cMsgSolu += STR0165	//" para preencher a localidade inicial, ou altere a localidade "
			cMsgSolu += STR0166	//"no grid 'Dado da Linha'."

		EndIf
		//Analisa se os sentidos dos trechos estão preenchidos
		If ( lRet )
		
			// Verifica se existem registros sem o sentido preenchido
			For nGQI := 1 To Len(aValid)
				
				If ( Empty(aValid[nGQI][4]) .And. !aValid[nGQI][5] )
					
					lRet:= .F.
					
					cMsgErro:= STR0145 //'Sentido não preenchido'
					cMsgSolu:= STR0146 //'O Tipo de Sentido da Linha é Ida e Volta, preencha o sentido do trecho'
					
					Exit
				
				EndIf

			Next nGQI

		EndIf
		//Verifica se a primeira linha do grid possui o sentido de ida
		If ( lRet .And. nFirst > 0 .And. Len(aValid) > 1 )
		
			If ( aValid[nFirst,4] != "1" )
				
				lRet := .F.	

				cMsgErro := STR0167	//"A primeira linha válida do itinerário tem de iniciar com o sentido de 'Ida' "
				
				cMsgSolu := STR0168 + cValToChar(nFirst) + ", " //"Ajusta o sentido para 'Ida', na linha "
				cMsgSolu += STR0169	//"do grid Itinirários para '1-Ida'."
			//Verifica se a última linha possui sentido de volta
			ElseIf ( aValid[nLast,4] != "2" )

				lRet := .F.

				cMsgErro := STR0170	//"A última linha válida do itinerário tem de possuir o sentido de 'Volta' "
				
				cMsgSolu := STR0171 + cValToChar(nLast) + ", " //"Ajusta o sentido para 'Volta', na linha "
				cMsgSolu += STR0172	//"do grid Itinirários para '2-Volta'."

			EndIf
			//Verifica se a última localidade destino (da última linha válida) é a mesma localidade de origem (da primeira linha válida)
			If ( lRet .And. (nLast > nFirst .And. aValid[nFirst][3] != aValid[nLast][2]) )
				
				lRet := .F.

				cMsgErro := STR0173	//"Itinerários que possuem sentidos de 'Ida e Volta' "
				cMsgErro += STR0174	//"precisam finalizar-se na localidade da partida."
				
				cMsgSolu := STR0175	//"A Localidade de destino da última linha válida "
				cMsgSolu += STR0176	//"necessita ser a mesma localidade de partida, da primeira linha válida."

			EndIf

		EndIf

	EndIf
	
	aRet:={lRet,cMsgErro,cMsgSolu}

Return aRet

//-------------------------------------------------------------------
/*/{Protheus.doc} GridToArray
Função utilizada carregar array com base no grid


@author Fernando Radu Muscalu (copia de função de mesmo nome do fonte GTPXFUNC)
@since 29/05/2023
@version 1.0
/*/
//-------------------------------------------------------------------

Static Function GridToArray(oGrid, aCampos)

	Local nQtdLin 	:= oGrid:Length()
	Local nQtdCol	:= Len(aCampos)+1

	Local aLinha	:= Array(nQtdLin,nQtdCol)

	Local nI	:= 0
	Local nJ	:= 0

	For nI := 1 To oGrid:Length()
		
		oGrid:GoLine(nI)
		
		For nJ := 1 To Len(aCampos)		
			aLinha[nI][nJ] := oGrid:GetValue(aCampos[nJ])			
		Next nJ

		aLinha[nI][nQtdCol] := oGrid:IsDeleted()

	Next nI
	
Return(aLinha)

//--------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} G900FilAg
@description Filtro da consulta GQDGYD tipos de linhas GYD_TIPLIN por orgão GYD_ORGAO. 
@param  Nenhum
@return Filtro para consulta
@author kaique.olivero
@since 19/06/2023
/*/
//--------------------------------------------------------------------------------------------------------------------
Function G900FilAg()
Local cFiltro := '@#'

cFiltro += 'GQD->GQD_CODGI0==FwFldGet("GYD_ORGAO")'

Return cFiltro+='@#'

//--------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} G900VlTpLn
@description validação do campo de tipos de linhas GYD_TIPLIN por orgão GYD_ORGAO. 
@param  Nenhum
@return Lógico
@author kaique.olivero
@since 20/06/2023
/*/
//--------------------------------------------------------------------------------------------------------------------
Function G900VlTpLn(cCodOrg,cCodTpLin)
Local lRet := .T.
Local cAliasTmp := ""
Default cCodOrg := ""
Default cCodTpLin := ""

If !Empty(cCodTpLin)
	If lRet := ExistCpo("GQC", cCodTpLin )
		If !Empty(cCodOrg)
			cAliasTmp := GetNextAlias()
			BeginSql Alias cAliasTmp
				SELECT 1
				FROM %Table:GQD% GQD
				WHERE GQD_FILIAL = %xFilial:GQD%
					AND GQD.GQD_CODGI0 = %Exp:cCodOrg%
					AND GQD.GQD_CODGQC = %Exp:cCodTpLin%
					AND GQD.%NotDel%
			EndSql
			If (cAliasTmp)->(EoF())
				lRet := .F.
				Help(,, "G900VlTpLn",,STR0180,1,0,,,,,,{STR0181}) //"O Tipo de Linha não está vinculado ao Orgão."##"Realize o vinculado no cadastro de Orgãos Concendente." 
			Endif
			(cAliasTmp)->(dbCloseArea())
		Else
			lRet := .F.
			Help(,, "G900VlTpLn",,STR0182,1,0,,,,,,{STR0183}) //"Código do Orgão em branco."##"Realize o preenchimento do código do Orgão."
		Endif
	Endif
Endif

Return lRet

//--------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} G900FilTpl
@description Filtro da consulta de categoria GYD_TPCARR por tipos de linhas GYD_TIPLIN. 
@param  Nenhum
@return Filtro para consulta
@author kaique.olivero
@since 19/06/2023
/*/
//--------------------------------------------------------------------------------------------------------------------
Function G900FilTpl()
Local cFiltro := '@#'

cFiltro += 'G5F->G5F_CODGI0==FwFldGet("GYD_ORGAO") .AND. G5F->G5F_CODGQC==FwFldGet("GYD_TIPLIN")'

Return cFiltro+='@#'

//--------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} G900VlCatg
@description validação do campo de categoria GYD_TPCARR por tipos de linhas GYD_TIPLIN. 
@param  Nenhum
@return Lógico
@author kaique.olivero
@since 20/06/2023
/*/
//--------------------------------------------------------------------------------------------------------------------
Function G900VlCatg(cCodTpLin,cCodCtg,cCodOrg)
Local lRet := .T.
Local cAliasTmp := ""
Default cCodTpLin := ""
Default cCodCtg := ""
Default cCodOrg := ""

If !Empty(cCodCtg)
	If lRet := ExistCpo("GYR", cCodCtg )
		If !Empty(cCodOrg)
			If !Empty(cCodTpLin)
				cAliasTmp := GetNextAlias()
				BeginSql Alias cAliasTmp
					SELECT 1
					FROM %Table:G5F% G5F
					WHERE G5F_FILIAL = %xFilial:G5F%
						AND G5F.G5F_CODGI0 = %Exp:cCodOrg%
						AND G5F.G5F_CODGQC = %Exp:cCodTpLin%
						AND G5F.G5F_CODGYR = %Exp:cCodCtg%
						AND G5F.%NotDel%
				EndSql
				If (cAliasTmp)->(EoF())
					lRet := .F.
					Help(,, "G900VlCatg",,STR0184,1,0,,,,,,{STR0185}) //"A Catergoria não está vinculado ao Tipo de Linha."##"Realize o vinculado no cadastro de Orgãos Concendente."
				Endif
				(cAliasTmp)->(dbCloseArea())
			Else
				lRet := .F.
				Help(,, "G900VlCatg",,STR0186,1,0,,,,,,{STR0187})//"Código do Tipo de Linha em branco."##"Realize o preenchimento do código do Tipo de Linha."
			Endif
		Else
			lRet := .F.
			Help(,, "G900VlCatg",,STR0182,1,0,,,,,,{STR0183}) //"Código do Orgão em branco."##"Realize o preenchimento do código do Orgão."	
		Endif
	Endif
Endif

Return lRet

//--------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} GA900VldCli
@description Efetua validação do cliente. Se existe cadastro e se está bloqueado 
@param  Nenhum
@return Lógico
@author kaique.olivero
@since 20/06/2023
/*/
//--------------------------------------------------------------------------------------------------------------------
Function GA900VldCli(cIdSub,oSubMdl,nLine,cMsgErro,cMsgSolu,lShowMsg)

	Local cCliente 		:= "" 
	Local cLoja			:= "" 
	Local cErroOcorrido	:= ""

	Local nInLine		:= 0
	Local nI			:= 0

	Local aBusca		:= {}
	
	Local lRet			:= .t.

	Default oSubMdl	:= Nil
	Default cIdSub	:= "GY0MASTER"
	Default nLine	:=  0
	Default cMsgErro:= ""
	Default cMsgSolu:= ""
	Default lShowMsg:= .F. 
	
	If ( ValType(oSubMdl) != "O" )
		oSubMdl := Eval({|x| x:= FwModelActive(), x:GetModel(cIdSub)})
	EndIf
	
	If ( nLine == 0 )
		nInLine := IIf(cIdSub == "GYDDETAIL", oSubMdl:GetLine(),0)
	Else
		nInLine := nLine
	EndIf

	cCliente 	:= Iif( nInLine > 0, oSubMdl:GetValue('GYD_CLIENT',nInLine), oSubMdl:GetValue('GY0_CLIENT'))
	cLoja		:= Iif( nInLine > 0, oSubMdl:GetValue('GYD_LOJACL',nInLine), oSubMdl:GetValue('GY0_LOJACL'))
	
	If (  !Empty(cCliente) .And. !Empty(cLoja) )

		If ( nInLine > 0 ) 

			cErroOcorrido += STR0195	//"O relatado problema está em "
			cErroOcorrido += "'" + STR0015 + "', "
			cErroOcorrido += STR0196	//"no item " 
			cErroOcorrido += cValToChar(nInLine) + STR0197	//", da listagem"
			cErroOcorrido += "("
			cErroOcorrido += STR0198	//"Aba "
			cErroOcorrido += STR0014 + ")."
		
		Else

			cErroOcorrido += STR0195	//"O relatado problema está em "  
			cErroOcorrido += "'" + STR0133 + "' " 
			cErroOcorrido += "("
			cErroOcorrido += STR0198	//"Aba "
			cErroOcorrido += STR0012 + ")."				
		
		EndIf

		If (Empty(AllTrim(Posicione("SA1", 1, XFILIAL("SA1") + cCliente + cLoja, "A1_NOME"))))

			
			cMsgErro := STR0132 // "Cliente Não Existe."
			cMsgErro += space(1) + cErroOcorrido // "Cliente Não Existe."
			
			cMsgSolu := STR0188	//"Utilize dados de cliente que exista cadastrado."

			lRet := .F.

		EndIf

		If ( lRet )
			
			aAdd(aBusca,{"A1_FILIAL", 	XFilial("SA1")})
			aAdd(aBusca,{"A1_COD", 		cCliente})
			aAdd(aBusca,{"A1_LOJA", 	cLoja})

			lRet := !GTPRegBloq("SA1",aBusca)

			If ( !lRet )
			
				cMsgErro := STR0189	//"O Registro pesquisado pela chave "
				
				For nI := 1 to Len(aBusca)

					cMsgErro += Alltrim(aBusca[nI,1]) + "("
					cMsgErro += Alltrim(aBusca[nI,2]) + ")"
					cMsgErro += IIf(nI < len(aBusca)," + "," ")
				
				Next nI
				
				cMsgErro += STR0190	//"se encontra bloqueado."
				cMsgErro += space(1) + cErroOcorrido	//"se encontra bloqueado."
			
				cMsgSolu := STR0193	//"Verifique se o registro buscado deveria estar bloquado. "
				cMsgSolu += STR0194	//"Procure pelo administrador do sistema."

			EndIf
		
		EndIf
		
	EndIf

	If (!lRet .And. lShowMsg)
		FwAlertHelp(cMsgErro,cMsgSolu,"GA900VldCli") 
	EndIf

Return(lRet)

//------------------------------------------------------------------------------
/* /{Protheus.doc} G903Modelo

Função que retorna objeto estático do modelo de dados GTPA903

@type Function
@author Fernando Radu Muscalu
@since 25/07/2023
@version 1.0
@param  
@return oG903Model, objeto, retorna a instância de FwFormModel
@example
(examples)
@see (links_or_references)
/*/
//------------------------------------------------------------------------------
Function G900Modelo()

Return(oG900Model)

//------------------------------------------------------------------------------
/* /{Protheus.doc} G903IsActive

Função que avalia se o modelo de dados GTPA903 está ativo

@type Function
@author Fernando Radu Muscalu
@since 25/07/2023
@version 1.0
@param  
@return lActived, lógico, .t. = ativo; .f. = não ativo ou instânciado
@example
(examples)
@see (links_or_references)
/*/
//------------------------------------------------------------------------------
Function G900IsActive()

    Local lActived := ValType(oG900Model) == "O" .And. oG900Model:IsActive()

    If ( !lActived )
        oG900Model := FwModelActive()
        lActived := oG900Model:GetId() == "GTPA900"
    EndIf

Return(lActived)

//------------------------------------------------------------------------------
/* /{Protheus.doc} G900Rateio
Função que abre a tela com as informações do Rateio de produtos, quando existe um.
@type Function
@author Fernando Radu Muscalu
@since 25/07/2023
@version 1.0
@param  oView, objeto, instância da classe FwFormView
@return nil
@example
(examples)
@see (links_or_references)
/*/
//------------------------------------------------------------------------------
Function G900Rateio(oView)
Local cCliente  := ""
Local cLoja     := ""
Local oMdlGY0   := Nil 
Local oMdlGYD   := Nil 
Local oMdl409a
Default oView := FwViewActive()

If ValType(oView) == "O" .And. VALTYPE( oView:ACURRENTSELECT ) == "A" .And. Len(oView:ACURRENTSELECT) > 0
	If oView:ACURRENTSELECT[1] == "VIEW_GY0"
		oMdlGY0   := oView:GetModel("GY0MASTER")
		If !Empty(oMdlGY0:GetValue("GY0_CLIENT")) .And. !Empty(oMdlGY0:GetValue("GY0_LOJACL"))
			If oMdlGY0:GetValue("GY0_RATEIO") == "1"
				cCliente    := oMdlGY0:GetValue("GY0_CLIENT")
				cLoja       := oMdlGY0:GetValue("GY0_LOJACL")    
			Else
				FWAlertHelp(STR0203+oMdlGY0:GetValue("GY0_CLIENT")+STR0204+oMdlGY0:GetValue("GY0_LOJACL")+STR0205,STR0208,"G900Rateio") //"Cliente: "##" e Loja: "##" não tem rateio."##"Informe um cliente que tem rateio para visualizar a consulta."
			Endif
		Else		
			FWAlertHelp(STR0207,STR0208,"G900Rateio") //"Não é possível abrir a consulta com o cliente e loja em branco."##"Informe um cliente e loja com rateio para visualizar a consulta."
		Endif

	Elseif oView:ACURRENTSELECT[1] == "VIEW_GYD"
		oMdlGYD   := oView:GetModel("GYDDETAIL")		
		If !Empty(oMdlGYD:GetValue("GYD_CLIENT")) .And. !Empty(oMdlGYD:GetValue("GYD_LOJACL"))
			If oMdlGYD:GetValue("GYD_RATEIO") == "1"
				cCliente    := oMdlGYD:GetValue("GYD_CLIENT")
				cLoja       := oMdlGYD:GetValue("GYD_LOJACL")
			Else
				FWAlertHelp(STR0203+oMdlGYD:GetValue("GYD_CLIENT")+STR0204+oMdlGYD:GetValue("GYD_LOJACL")+STR0205,STR0208,"G900Rateio") //"Cliente: "##" e Loja: "##" não tem rateio."##"Informe um cliente que tem rateio para visualizar a consulta."
			Endif
		Else
			FWAlertHelp(STR0207,STR0208,"G900Rateio") //"Não é possível abrir a consulta com o cliente e loja em branco."##"Informe um cliente e loja com rateio para visualizar a consulta."
		Endif
	Else
		FWAlertHelp(STR0209,STR0210,"G900Rateio") //"Não foi possível posicionar no cliente para abrir a consulta."##"Clique no campo de cliente antes de abrir a consulta"
	Endif

	If ( !Empty(cCliente) )
		H6A->(DbSetOrder(2)) //H6A_FILIAL+H6A_CLIENT+H6A_LOJA
		If ( H6A->(DbSeek(xFilial("H6A") + cCliente + cLoja)) )
			
			oMdl409a  := FwLoadModel("GTPA904A")
			oMdl409a:SetOperation(MODEL_OPERATION_VIEW)        
			oMdl409a:Activate()
			FwExecView(STR0199, "VIEWDEF.GTPA904A", MODEL_OPERATION_VIEW, , {|| .T. } , /*bOk*/ , /*nPercReducao*/, /*aEnableButtons*/, /*bCancel*/, /*cOperatId*/ , /*cToolBar*/ , oMdl409a)	// "Consulta de Rateio de Produtos"
		EndIf
	EndIf
Endif

Return()

/*/{Protheus.doc} WhenRateio
Função de verificação de when de rateio
@type Function
@author kaique.olivero
@since 25/07/2023
/*/
Static Function WhenRateio(cCliente,cLoja)
Default cCliente := ""
Default cLoja := ""

Return FwIsInCallStack("FieldTrigger") .Or. !RateioPrd(cCliente,cLoja)

/*/{Protheus.doc} RateioPrd
Função para vericicar se existe rateio de produtos para clientes
@type Function
@author kaique.olivero
@since 25/07/2023
/*/
Static Function RateioPrd(cCliente,cLoja)
Local lRet := .F.
Default cCliente := ""
Default cLoja := ""

If !Empty(cCliente) .And. !Empty(cLoja)
	H6A->(DbSetOrder(2)) //H6A_FILIAL+H6A_CLIENT+H6A_LOJA
	If ( H6A->(DbSeek(xFilial("H6A") + cCliente + cLoja)) )
		If AliasInDic('H6Q')
			H6Q->(DbSetOrder(3)) //H6Q_FILIAL+H6Q_CODH6A+H6Q_SEQ
			If H6Q->(DbSeek(xFilial("H6Q") + H6A->H6A_CODIGO))
				lRet := .T.
			Endif
		Endif
	Endif
Endif

Return lRet

/*/{Protheus.doc} PosVldGYD
Pos valid do grid GYD
@author kaique.olivero
@since 01/08/2023
/*/
Static Function PosVldGYD(oMdl)
Local lRet := .T.

If oMdl:GetValue("GYD_RATEIO") == "2" .And. Empty(oMdl:GetValue("GYD_PRODUT"))
	Help(,, "PosVldGYD",,STR0211,1,0,,,,,,{STR0212}) //"O código do produto está em branco."##"Iforme o código do produto."
	lRet := .F.
Endif

Return lRet

/*/{Protheus.doc} G900REL()
	Função para imprimir o contrato de Fretamento Contínua
	@author Silas Gomes
	@since 14/12/2023
/*/
Function G900REL()

	Local lRet as logical

	lRet := .T.

	If ExistBlock("GeraDoc")

		If ExecBlock("GeraDoc",.F.,.F.) 
			FWAlertSuccess("Contrato gerado com sucesso", "Gera contrato") //"Contrato gerado com sucesso" ## "Gera Contrato"
		EndIf

	Else

		FwAlertWarning("O modelo de RdMake 'GeraDoc' não compilado", "Atenção!") //"O RdMake 'GeraDoc' não compilado" ## "Atenção!"
		lRet := .F.

	EndIf
	
Return lRet
