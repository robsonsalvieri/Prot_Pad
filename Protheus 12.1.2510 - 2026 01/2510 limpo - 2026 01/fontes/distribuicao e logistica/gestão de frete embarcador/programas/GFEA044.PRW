#INCLUDE "GFEA044.CH"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "XMLXFUN.CH"

#DEFINE DUPLAS Chr( 34 )

Static cSerieGFE

/*/-------------------------------------------------------------------------------------------------- 
{Protheus.doc} GFEA044
Digitação de Documentos de Carga
Uso Generico.

@sample
GFEA044()

@author Israel A. Possoli 
@since 13/11/09
@version 1.0
--------------------------------------------------------------------------------------------------/*/

Function GFEA044()
	Local oBrowse

	Private lCopy := .F.
	Private cTreEsc := "01"

	oBrowse := FWMBrowse():New()
	oBrowse:SetAlias("GW1")			// Alias da tabela utilizada
	oBrowse:SetMenuDef("GFEA044")	// Nome do fonte onde esta a função MenuDef
	oBrowse:SetDescription(STR0001) // Descrição do browse //"Documentos de Carga"

	oBrowse:AddLegend("GW1_SIT=='1'", "WHITE" ,STR0032) //"Digitado "
	oBrowse:AddLegend("GW1_SIT=='2'", "YELLOW",STR0033) //"Bloqueado"
	oBrowse:AddLegend("GW1_SIT=='3'", "GRAY"  ,STR0034) //"Liberado "
	oBrowse:AddLegend("GW1_SIT=='4'", "BLUE"  ,STR0035) //"Embarcado"
	oBrowse:AddLegend("GW1_SIT=='5'", "GREEN" ,STR0036) //"Entregue "
	oBrowse:AddLegend("GW1_SIT=='6'", "ORANGE",STR0037) //"Retornado"
	oBrowse:AddLegend("GW1_SIT=='7'", "RED"   ,STR0038) //"Cancelado"
	oBrowse:AddLegend("GW1_SIT=='8'", "BLACK" ,"Sinistrado") //"Sinistrado"

	oBrowse:Activate()
Return Nil

//-------------------------------------------------------------------
Static Function MenuDef()
	Local aRotina 	:= {}
	Local lPE442	:= ExistBlock("GFEA0442")

	//-------------------------------------------------------
	// Adiciona botões do browse
	//-------------------------------------------------------
	ADD OPTION aRotina TITLE STR0002 ACTION "AxPesqui"        	OPERATION 1  ACCESS 0  	//"Pesquisar"
	ADD OPTION aRotina TITLE STR0003 ACTION "VIEWDEF.GFEC040" 	OPERATION 2  ACCESS 0  	//"Visualizar"
	ADD OPTION aRotina TITLE STR0004 ACTION "VIEWDEF.GFEA044" 	OPERATION 3  ACCESS 0  	//"Incluir"
	ADD OPTION aRotina TITLE STR0005 ACTION "FwExecView('Alterar','GFEA044',4,,{||.T.})" 	OPERATION 4  ACCESS 0  	//"Alterar"
	ADD OPTION aRotina TITLE STR0006 ACTION "VIEWDEF.GFEA044" 	OPERATION 5  ACCESS 0  	//"Excluir"
	ADD OPTION aRotina TITLE STR0007 ACTION "GFEA44COPY()"  	OPERATION 6  ACCESS 0  	//"Copiar"
	ADD OPTION aRotina TITLE STR0008 ACTION "VIEWDEF.GFEA044" 	OPERATION 8  ACCESS 0   //"Imprimir"
	ADD OPTION aRotina TITLE STR0009 ACTION "GFEA44Sit('3')" 	OPERATION 13 ACCESS 0	//"Liberar"
	ADD OPTION aRotina TITLE STR0010 ACTION "GFEA44Sit('7')" 	OPERATION 10 ACCESS 0  	//"Cancelar"
	ADD OPTION aRotina TITLE STR0011 ACTION "GFEA44Sit('2')" 	OPERATION 11 ACCESS 0  	//"Bloquear"
	ADD OPTION aRotina TITLE STR0030 ACTION "GFEA44IRO()"      	OPERATION 12 ACCESS 0  	//"Romaneio"
	ADD OPTION aRotina TITLE "Ocorrência" ACTION "GFEA044OCO()" OPERATION 10 ACCESS 0   //"Ocorrência"

	ADD OPTION aRotina TITLE "Doc Frete" ACTION "GFEA065B()" OPERATION 10 ACCESS 0 	

	If lPE442
		aRotAdic := ExecBlock("GFEA0442",.F.,.F.)
		If ValType(aRotAdic) == "A"
			AEval(aRotAdic, {|x| AAdd(aRotina ,x)})
		EndIf
	EndIf

Return aRotina

//-------------------------------------------------------------------
Static Function ModelDef()
	Local oModel
	Local oStructGXP
	Local oStructGW1 := FWFormStruct(1, "GW1")
	Local oStructGW8 := FWFormStruct(1, "GW8")
	Local oStructGWB := FWFormStruct(1, "GWB")
	Local oStructGWU := FWFormStruct(1, "GWU")
	
	// Habilita o campo do tipo de operação quando integração com o Datasul.
	If (GetNewPar("MV_CADERP", "2") == "1") .And. FWIsInCallStack("GFEX101") 
		oStructGW1:SetProperty('GW1_ROMTO' , MODEL_FIELD_VALID , {|A,B,C,D| FWINITCPO(A,B,C), LRETORNO := GFEExistC("GV4",,M->GW1_ROMTO,"GV4->GV4_SIT=='1'") .OR. VAZIO(),FWCLOSECPO(A,B,C,LRETORNO),LRETORNO} )
	EndIf

	If GFXTB12117("GXP")
		oStructGXP := FWFormStruct(1, "GXP")
	EndIf

	// cID     Identificador do modelo
	// bPre    Code-Block de pre-edição do formulário de edição. Indica se a edição esta liberada
	// bPost   Code-Block de validação do formulário de edição
	// bCommit Code-Block de persistência do formulário de edição
	// bCancel Code-Block de cancelamento do formulário de edição

	oModel := MPFormModel():New("GFEA044", /*bPre*/,{|oMod| GFE44Post(oMod)}, /*bCommit*/{|oModel| GFEA044CMT(oModel)}, /*bCancel*/)
	oModel:SetVldActivate ( { |oMod| GFEA044VL( oMod ) } )

	// cId          Identificador do modelo
	// cOwner       Identificador superior do modelo
	// oModelStruct Objeto com  a estrutura de dados
	// bPre         Code-Block de pré-edição do formulário de edição. Indica se a edição esta liberada
	// bPost        Code-Block de validação do formulário de edição
	// bLoad        Code-Block de carga dos dados do formulário de edição
	oModel:AddFields("GFEA044_GW1", Nil, oStructGW1, /*bPre*/ ,/**/,/*bLoad*/)
	oModel:SetPrimaryKey({"GW1_FILIAL" , "GW1_CDTPDC" , "GW1_EMISDC" , "GW1_SERDC" , "GW1_NRDC" })

	oModel:AddGrid("GFEA044_GW8","GFEA044_GW1", oStructGW8,/*bLinePre*/,{|oMod| If(IsInCallStack("GFEA044"),If(lCopy,.T.,GF44_GW8PS(oMod)),GF44_GW8PS(oMod))},,/*bPre*/,/*bPost*/,/*bLoad*/)
	oModel:SetRelation("GFEA044_GW8",{{"GW8_FILIAL","xFilial('GW8')"},{"GW8_CDTPDC","GW1_CDTPDC"},{"GW8_EMISDC","GW1_EMISDC"},{"GW8_SERDC","GW1_SERDC"},{"GW8_NRDC","GW1_NRDC"}},"GW8_FILIAL+GW8_CDTPDC+GW8_EMISDC+GW8_SERDC+GW8_NRDC+GW8_SEQ")
	oModelGW8 = oModel:GetModel("GFEA044_GW8")
	oModelGW8:SetUniqueLine({"GW8_SEQ"})
	oModelGW8:SetDescription(STR0079) //"dos itens do documento de carga "

	oModel:AddGrid("GFEA044_GWB","GFEA044_GW1", oStructGWB,/*bLinePre*/,/*{|oMod| GFE44PSGWB(oMod)}*/,/*bPre*/,/*bPost*/,/*bLoad*/)
	oModel:SetRelation("GFEA044_GWB",{{"GWB_FILIAL","xFilial('GWB')"},{"GWB_CDTPDC","GW1_CDTPDC"},{"GWB_EMISDC","GW1_EMISDC"},{"GWB_SERDC","GW1_SERDC"},{"GWB_NRDC","GW1_NRDC"}},"GWB_FILIAL+GWB_CDTPDC+GWB_EMISDC+GWB_SERDC+GWB_NRDC")
	oModelGWB = oModel:GetModel("GFEA044_GWB")
	oModelGWB:SetUniqueLine({"GWB_CDUNIT"})
	oModelGWB:SetDescription("GWB")
	oModelGWB:SetDelAllLine(.T.)

	oModel:SetOptional("GFEA044_GWB", .T. )

	oModel:AddGrid("GFEA044_GWU","GFEA044_GW1", oStructGWU, ,{|oMod| If(IsInCallStack("GFEA044"), If(lCopy,.T.,GF44_GWUPS(oMod)), GF44_GWUPS(oMod))},/*bPre*/,/*bPost*/,/*bLoad*/)
	oModel:SetRelation("GFEA044_GWU",{{"GWU_FILIAL","xFilial('GWU')"},{"GWU_CDTPDC","GW1_CDTPDC"},{"GWU_EMISDC","GW1_EMISDC"},{"GWU_SERDC","GW1_SERDC"},{"GWU_NRDC","GW1_NRDC"}},"GWU_FILIAL+GWU_CDTPDC+GWU_EMISDC+GWU_SERDC+GWU_NRDC")
	oModelGWU = oModel:GetModel("GFEA044_GWU")
	oModelGWU:SetUniqueLine({"GWU_SEQ"})
	oModelGWU:SetDescription(STR0080) //"dos trechos do documento de carga "
	oModelGWU:cOrderBy := "GWU_FILIAL+GWU_CDTPDC+GWU_EMISDC+GWU_SERDC+GWU_NRDC+GWU_SEQ"

	If GFXTB12117("GXP")
		oModel:AddGrid("GFEA044_GXP","GFEA044_GW1", oStructGXP,/*bLinePre*/,/*{|oMod| GFE44PSGWB(oMod)}*/,/*bPre*/,/*bPost*/,/*bLoad*/)
		oModel:SetRelation("GFEA044_GXP",{{"GXP_FILIAL","xFilial('GXP')"},{"GXP_CDTPDC","GW1_CDTPDC"},{"GXP_EMISDC","GW1_EMISDC"},{"GXP_SERDC","GW1_SERDC"},{"GXP_NRDC","GW1_NRDC"}},GXP->(IndexKey(1)))
		oModelGXP = oModel:GetModel("GFEA044_GXP")
		oModelGXP:SetUniqueLine({"GXP_FILORI","GXP_EMIORI","GXP_SERORI","GXP_DOCORI"})
		oModelGXP:SetDescription("GXP")
		oModelGXP:SetDelAllLine(.T.)

		oModel:SetOptional("GFEA044_GXP", .T. )
	EndIf

	oModel:SetActivate({|oMod| GF44_GW8ACT(oMod)})

Return oModel

//---------------------------------------------------
Static Function ViewDef()
	Local nX
	Local nPosBase
	Local cPosBase
	Local cCampos
	Local oModel 		:= FWLoadModel("GFEA044")
	Local oView 		:= Nil
	Local oStructGW1	:= FWFormStruct(2,"GW1")
	Local oStructGW8 	:= FWFormStruct(2,"GW8")
	Local oStructGWB 	:= FWFormStruct(2,"GWB")
	Local oStructGWU 	:= FWFormStruct(2,"GWU")
	Local oStructGXP
	Local lPEINCGW		:= ExistBlock("XINCGW1") 

	if GFXTB12117("GXP")
		oStructGXP := FWFormStruct(2,"GXP")
	EndIf
	oStructGW1:AddGroup("GrpId" , STR0091, "1", 2) // "Identificação"
	oStructGW1:AddGroup("GrpMov", STR0092, "1", 2) // "Movimentação"
	oStructGW1:AddGroup("GrpCtl", STR0093, "1", 2) // "Controle"

	oStructGW1:AddGroup("GrpCar", STR0094, "2", 2) // "Carga"
	oStructGW1:AddGroup("GrpEnd", STR0095, "2", 2) // "Endereço Entrega"
	oStructGW1:AddGroup("GrpCtr", STR0096, "2", 2) // "Controle"
	oStructGW1:AddGroup("GrpCal", "Cálculo Automático", "2", 2)
	oStructGW1:AddGroup("GrpInt", "Integrações", "2", 2)
	oStructGW1:SetProperty("GW1_CDTPDC", MVC_VIEW_GROUP_NUMBER, "GrpId")
	oStructGW1:SetProperty("GW1_EMISDC", MVC_VIEW_GROUP_NUMBER, "GrpId")
	oStructGW1:SetProperty("GW1_NMEMIS", MVC_VIEW_GROUP_NUMBER, "GrpId")
	oStructGW1:SetProperty("GW1_DTEMIS", MVC_VIEW_GROUP_NUMBER, "GrpId")
	oStructGW1:SetProperty("GW1_SERDC" , MVC_VIEW_GROUP_NUMBER, "GrpId")
	oStructGW1:SetProperty("GW1_NRDC"  , MVC_VIEW_GROUP_NUMBER, "GrpId")
	oStructGW1:SetProperty("GW1_ORIGEM", MVC_VIEW_GROUP_NUMBER, "GrpId")
	oStructGW1:SetProperty("GW1_SIT"   , MVC_VIEW_GROUP_NUMBER, "GrpId")
	oStructGW1:SetProperty("GW1_AUTSEF", MVC_VIEW_GROUP_NUMBER, "GrpId")
	oStructGW1:SetProperty("GW1_DANFE" , MVC_VIEW_GROUP_NUMBER, "GrpId")

	// Habilita o campo do tipo de operação quando integração com o Datasul.
	If (GetNewPar("MV_CADERP", "2") == "1") .And. FWIsInCallStack("GFEX101") 
		oStructGW1:SetProperty('GW1_ROMTO'   ,MVC_VIEW_CANCHANGE,.T.) 
		oStructGW1:SetProperty('GW1_ROMTO'   ,MVC_VIEW_LOOKUP,"GV4") 
	EndIf

	//Ponto de entrada Harley Davidson
	If lPEINCGW
		ExecBlock("XINCGW1",.f.,.f.,{oStructGW1, "GrpId", oStructGW1:GetProperty("GW1_ORIGEM" , MVC_VIEW_ORDEM) , oStructGW1:GetProperty("GW1_SIT" , MVC_VIEW_ORDEM) })
	EndIf 	
	//Fim ponto de entrada Harley Davidson

	oStructGW1:SetProperty("GW1_CDREM" , MVC_VIEW_GROUP_NUMBER, "GrpMov")
	oStructGW1:SetProperty("GW1_NMREM" , MVC_VIEW_GROUP_NUMBER, "GrpMov")
	oStructGW1:SetProperty("GW1_NRROM" , MVC_VIEW_GROUP_NUMBER, "GrpMov")
	oStructGW1:SetProperty("GW1_CDDEST", MVC_VIEW_GROUP_NUMBER, "GrpMov")
	oStructGW1:SetProperty("GW1_NMDEST", MVC_VIEW_GROUP_NUMBER, "GrpMov")
	oStructGW1:SetProperty("GW1_TPFRET", MVC_VIEW_GROUP_NUMBER, "GrpMov")
	If GFXCP1212210('GW1_FILROM') .And. AScan(oStructGW1:aFields,{|x| x[1] == "GW1_FILROM"}) != 0
		oStructGW1:SetProperty("GW1_FILROM", MVC_VIEW_GROUP_NUMBER, "GrpMov")
	EndIf
	
	oStructGW1:SetProperty("GW1_DTIMPL", MVC_VIEW_GROUP_NUMBER, "GrpCtl")
	oStructGW1:SetProperty("GW1_HRIMPL", MVC_VIEW_GROUP_NUMBER, "GrpCtl")
	oStructGW1:SetProperty("GW1_ENVEDI", MVC_VIEW_GROUP_NUMBER, "GrpCtl")
	oStructGW1:SetProperty("GW1_USO"   , MVC_VIEW_GROUP_NUMBER, "GrpCtl")

	oStructGW1:SetProperty("GW1_DSESP" , MVC_VIEW_GROUP_NUMBER, "GrpCar")
	oStructGW1:SetProperty("GW1_QTVOL" , MVC_VIEW_GROUP_NUMBER, "GrpCar")
	oStructGW1:SetProperty("GW1_CARREG", MVC_VIEW_GROUP_NUMBER, "GrpCar")
	oStructGW1:SetProperty("GW1_REGCOM", MVC_VIEW_GROUP_NUMBER, "GrpCar")
	oStructGW1:SetProperty("GW1_REPRES", MVC_VIEW_GROUP_NUMBER, "GrpCar")
	oStructGW1:SetProperty("GW1_ICMSDC", MVC_VIEW_GROUP_NUMBER, "GrpCar")
	oStructGW1:SetProperty("GW1_ORINR" , MVC_VIEW_GROUP_NUMBER, "GrpCar")
	oStructGW1:SetProperty("GW1_ORISER", MVC_VIEW_GROUP_NUMBER, "GrpCar")

	oStructGW1:SetProperty("GW1_ENTEND", MVC_VIEW_GROUP_NUMBER, "GrpEnd")
	oStructGW1:SetProperty("GW1_ENTBAI", MVC_VIEW_GROUP_NUMBER, "GrpEnd")
	oStructGW1:SetProperty("GW1_ENTCEP", MVC_VIEW_GROUP_NUMBER, "GrpEnd")
	oStructGW1:SetProperty("GW1_ENTNRC", MVC_VIEW_GROUP_NUMBER, "GrpEnd")
	oStructGW1:SetProperty("GW1_ENTCID", MVC_VIEW_GROUP_NUMBER, "GrpEnd")
	oStructGW1:SetProperty("GW1_ENTUF" , MVC_VIEW_GROUP_NUMBER, "GrpEnd")
	If AScan(oStructGW1:aFields,{|x| x[1] == "GW1_NRREG"}) != 0
		oStructGW1:SetProperty('GW1_NRREG', MVC_VIEW_FOLDER_NUMBER, '2')
		oStructGW1:SetProperty("GW1_NRREG", MVC_VIEW_GROUP_NUMBER, "GrpEnd")
	EndIf

	oStructGW1:SetProperty("GW1_USUIMP", MVC_VIEW_GROUP_NUMBER, "GrpCtr")
	oStructGW1:SetProperty("GW1_DTLIB" , MVC_VIEW_GROUP_NUMBER, "GrpCtr")
	oStructGW1:SetProperty("GW1_HRLIB" , MVC_VIEW_GROUP_NUMBER, "GrpCtr")
	oStructGW1:SetProperty("GW1_DTPSAI", MVC_VIEW_GROUP_NUMBER, "GrpCtr")
	oStructGW1:SetProperty("GW1_HRPSAI", MVC_VIEW_GROUP_NUMBER, "GrpCtr")
	oStructGW1:SetProperty("GW1_DTSAI" , MVC_VIEW_GROUP_NUMBER, "GrpCtr")
	oStructGW1:SetProperty("GW1_HRSAI" , MVC_VIEW_GROUP_NUMBER, "GrpCtr")
	oStructGW1:SetProperty("GW1_DTPENT", MVC_VIEW_GROUP_NUMBER, "GrpCtr")
	oStructGW1:SetProperty("GW1_HRPENT", MVC_VIEW_GROUP_NUMBER, "GrpCtr")
	oStructGW1:SetProperty("GW1_DTALT" , MVC_VIEW_GROUP_NUMBER, "GrpCtr")
	oStructGW1:SetProperty("GW1_HRALT" , MVC_VIEW_GROUP_NUMBER, "GrpCtr")
	oStructGW1:SetProperty("GW1_USUALT", MVC_VIEW_GROUP_NUMBER, "GrpCtr")
	oStructGW1:SetProperty("GW1_DTCAN" , MVC_VIEW_GROUP_NUMBER, "GrpCtr")
	oStructGW1:SetProperty("GW1_HRCAN" , MVC_VIEW_GROUP_NUMBER, "GrpCtr")
	oStructGW1:SetProperty("GW1_USUCAN", MVC_VIEW_GROUP_NUMBER, "GrpCtr")
	oStructGW1:SetProperty("GW1_HRPENT", MVC_VIEW_GROUP_NUMBER, "GrpCtr")

	If AScan(oStructGW1:aFields,{|x| x[1] == "GW1_SITFT"}) != 0
		oStructGW1:SetProperty("GW1_SITFT" , MVC_VIEW_GROUP_NUMBER, "GrpInt")
		oStructGW1:SetProperty("GW1_MOTFT" , MVC_VIEW_GROUP_NUMBER, "GrpInt")
	EndIf

	If AScan(oStructGW1:aFields,{|x| x[1] == "GW1_CALCAT"}) != 0
		oStructGW1:SetProperty("GW1_CALCAT" , MVC_VIEW_GROUP_NUMBER,  "GrpCtr")
	EndIf

	If AScan(oStructGW1:aFields,{|x| x[1] == "GW1_ROMTV"}) != 0
		oStructGW1:SetProperty("GW1_ROMTV", MVC_VIEW_GROUP_NUMBER, "GrpCal")
		oStructGW1:SetProperty("GW1_ROMCF", MVC_VIEW_GROUP_NUMBER, "GrpCal")
		oStructGW1:SetProperty("GW1_ROMTO", MVC_VIEW_GROUP_NUMBER, "GrpCal")
	EndIf

	oView := FWFormView():New()
	oView:SetModel(oModel)
	oView:AddField( "GFEA044_GW1" , oStructGW1 )

	/* Integração - Protheus
	Verifica se o sistema está integrado com ERP e se a origem é o Protheus,
	de outra forma remove o campo GW6_ATUATF */
	If GetNewPar("MV_CADERP", "2") == "2" .OR. GetNewPar("MV_ERPGFE", "0") != "2"
		oStructGW8:RemoveField("GW8_ATUATF")
	EndIf

	oView:AddGrid( "GFEA044_GW8" , oStructGW8)
	oStructGW8:RemoveField("GW8_FILIAL")
	oStructGW8:RemoveField("GW8_CDTPDC")
	oStructGW8:RemoveField("GW8_EMISDC")
	oStructGW8:RemoveField("GW8_SERDC")
	oStructGW8:RemoveField("GW8_NRDC")

	oView:AddIncrementField("GFEA044_GW8","GW8_SEQ")

	oView:AddGrid( "GFEA044_GWB" , oStructGWB)
	oStructGWB:RemoveField("GWB_FILIAL")
	oStructGWB:RemoveField("GWB_CDTPDC")
	oStructGWB:RemoveField("GWB_EMISDC")
	oStructGWB:RemoveField("GWB_SERDC")
	oStructGWB:RemoveField("GWB_NRDC")

	oView:AddGrid( "GFEA044_GWU" , oStructGWU)
	oStructGWU:RemoveField("GWU_FILIAL")
	oStructGWU:RemoveField("GWU_CDTPDC")
	oStructGWU:RemoveField("GWU_EMISDC")
	oStructGWU:RemoveField("GWU_SERDC")
	oStructGWU:RemoveField("GWU_NRDC")

	If GFXTB12117("GXP")
		nPosBase := aScan(oStructGWU:aFields,{|x|x[1] == "GWU_NRCIDD"})
		cPosBase := oStructGWU:aFields[nPosBase,2]
		cCampos  := "GWU_NRCIDOGWU_NMCIDOGWU_UFOGWU_CEPOGWU_CEPDGWU_CDCLFRGWU_DSCLFRGWU_CDTPOPGWU_DSTPOP"

		For nX := nPosBase To Len(oStructGWU:aFields)
			If !(oStructGWU:aFields[nX,1] $ cCampos )
				oStructGWU:SetProperty(oStructGWU:aFields[nX,1],MVC_VIEW_ORDEM,NTOC(CTON(oStructGWU:aFields[nX,2],36) + 4,36,2))
			EndIf
		Next nX

		oStructGWU:SetProperty("GWU_NRCIDO", MVC_VIEW_ORDEM, NTOC(CTON(cPosBase,36)  ,36,2))
		oStructGWU:SetProperty("GWU_NMCIDO", MVC_VIEW_ORDEM, NTOC(CTON(cPosBase,36)+1,36,2))
		oStructGWU:SetProperty("GWU_UFO"   , MVC_VIEW_ORDEM, NTOC(CTON(cPosBase,36)+2,36,2))
		oStructGWU:SetProperty("GWU_CEPO"  , MVC_VIEW_ORDEM, NTOC(CTON(cPosBase,36)+3,36,2))

		nPosBase := aScan(oStructGWU:aFields,{|x|x[1] == "GWU_CDTPVC"})
		cPosBase := oStructGWU:aFields[nPosBase,2]

		For nX := nPosBase To Len(oStructGWU:aFields)
			If !(oStructGWU:aFields[nX,1] $ cCampos )
				oStructGWU:SetProperty(oStructGWU:aFields[nX,1],MVC_VIEW_ORDEM,NTOC(CTON(oStructGWU:aFields[nX,2],36) + 4,36,2))
			EndIf
		Next nX

		oStructGWU:SetProperty("GWU_CEPD", MVC_VIEW_ORDEM, NTOC(CTON(cPosBase,36) ,36,2))

		nPosBase := aScan(oStructGWU:aFields,{|x|x[1] == "GWU_PAGAR"})
		cPosBase := oStructGWU:aFields[nPosBase,2]

		For nX := nPosBase To Len(oStructGWU:aFields)
			If !(oStructGWU:aFields[nX,1] $ cCampos )
				oStructGWU:SetProperty(oStructGWU:aFields[nX,1],MVC_VIEW_ORDEM,NTOC(CTON(oStructGWU:aFields[nX,2],36) + 4,36,2))
			EndIf
		Next nX

		oStructGWU:SetProperty("GWU_CDCLFR", MVC_VIEW_ORDEM, NTOC(CTON(cPosBase,36)  ,36,2))
		oStructGWU:SetProperty("GWU_DSCLFR", MVC_VIEW_ORDEM, NTOC(CTON(cPosBase,36)+1,36,2))
		oStructGWU:SetProperty("GWU_CDTPOP", MVC_VIEW_ORDEM, NTOC(CTON(cPosBase,36)+2,36,2))
		oStructGWU:SetProperty("GWU_DSTPOP", MVC_VIEW_ORDEM, NTOC(CTON(cPosBase,36)+3,36,2))

		oStructGXP:RemoveField("GXP_CDTPDC")
		oStructGXP:RemoveField("GXP_EMISDC")
		oStructGXP:RemoveField("GXP_SERDC" )
		oStructGXP:RemoveField("GXP_NRDC"  )

		oView:AddGrid( "GFEA044_GXP" , oStructGXP)
	EndIf

	oView:CreateHorizontalBox( "MASTER" , 55)
	oView:CreateHorizontalBox( "DETAIL" , 45)

	oView:CreateFolder("IDFOLDER","DETAIL")
	oView:AddSheet("IDFOLDER","IDSHEET01",STR0039) //"Itens"
	oView:AddSheet("IDFOLDER","IDSHEET02",STR0040) //"Unitizadores"
	oView:AddSheet("IDFOLDER","IDSHEET03",STR0041) //"Trechos"
	If GFXTB12117("GXP")
		oView:AddSheet("IDFOLDER","IDSHEET04","Documentos de Origem")
	EndIf

	oView:CreateHorizontalBox( "DETAIL_GW8"  , 100,,,"IDFOLDER","IDSHEET01" )
	oView:CreateHorizontalBox( "DETAIL_GWB"  , 100,,,"IDFOLDER","IDSHEET02" )
	oView:CreateHorizontalBox( "DETAIL_GWU"  , 100,,,"IDFOLDER","IDSHEET03" )
	If GFXTB12117('GXP')
		oView:CreateHorizontalBox( "DETAIL_GXP"  , 100,,,"IDFOLDER","IDSHEET04" )
	EndIf

	oView:SetOwnerView( "GFEA044_GW1" , "MASTER" )
	oView:SetOwnerView( "GFEA044_GW8" , "DETAIL_GW8" )
	oView:SetOwnerView( "GFEA044_GWB" , "DETAIL_GWB" )
	oView:SetOwnerView( "GFEA044_GWU" , "DETAIL_GWU" )
	If GFXTB12117('GXP')
		oView:SetOwnerView( "GFEA044_GXP" , "DETAIL_GXP" )
	EndIf

	oView:AddIncrementField("GFEA044_GWU","GWU_SEQ")

Return oView

/*/{Protheus.doc} GFEA44Sit
//TODO Descrição auto-gerada.
@author SQUAD GFE - Controle de Frete
@since 14/03/2018
@version 1.0
@param cTpSit, characters, Tipo de Situação a ser realizada 
3 = Liberar 
7 = Cancelar 
2 = Bloquear
@type function
/*/
Function GFEA44Sit(cTpSit)
	Local aRetSit := {}
	Local cGFE001 := IIF(Empty(SuperGetMv("MV_GFE001",.F.,"1")),"1",SuperGetMv("MV_GFE001",.F.,"1"))

	Do Case
		Case cTpSit == "2"
		aRetSit := GFE44BloquearDC(,,,,,2,.T.,.T.)
		Case cTpSit == "3"
		aRetSit := GFE44LiberarDC( ,,,,,2,.T.,.T.)
		Case cTpSit == "7"
		aRetSit := GFE44CancelarDC(,,,,,2,.T.,IIf ( cGFE001 == "1",.T.,.F.) )
	Endcase

	If aRetSit[1] == .F.
		GFEHelp(aRetSit[2])
	EndIf
Return

/*/{Protheus.doc} GFE44BloquearDC
//TODO Verifica a possibilidade e realiza o Bloqueio do Documento de Carga
@author SQUAD GFE - Controle de Frete
@since 14/03/2018
@version 1.0
@return ${return}, ${Pode Executar a operação, mensagem de motivo de naõ permitir a operação}
@param cGW1FILIAL, characters, Filial do Documento de Carga
@param cGW1EMISDC, characters, Emissor do Documento de Carga
@param cGW1CDTPDC, characters, Tipo de Documento de Carga
@param cGW1SERDC, characters, Série do Documento de Carga
@param cGW1NRDC, characters, Número do Documento de Carga
@param cTpOperacao, characters, Tipo de operação a ser realizada 
1 = Somente Verificação/Validação se pode Bloquear
2 = Verificação/Validação e execução do Bloqueio
@param lPergOperacao, logical, Apos as validações pergunta se quer realmente executar o procedimento
@param lVerOrig, logical, Indica se será considerada a validação da origem do documento.
.T. - Executa a validação da origem
.F. - Não executa a validação da origem
@type function
/*/
Function GFE44BloquearDC(cGW1FILIAL, cGW1CDTPDC, cGW1EMISDC, cGW1SERDC, cGW1NRDC, cTpOperacao, lPergOperacao, lVerOrig)
	Local lPE444	    := ExistBlock("GFEA0444")
	Default cGW1FILIAL	:= '' 
	Default cGW1EMISDC	:= '' 
	Default cGW1CDTPDC	:= '' 
	Default cGW1SERDC	:= '' 
	Default cGW1NRDC	:= ''
	// Como a função é executada pela própria rotina, o registro já está posicionado.
	// quando a função for chamada externamente, deverá posicionar no registro para depois executar a ação.
	If !Empty(cGW1EMISDC) .AND. !Empty(cGW1CDTPDC) .AND. !Empty(cGW1NRDC)
		GW1->(dbSetOrder(1))
		If !GW1->(dbSeek(cGW1FILIAL + cGW1CDTPDC + cGW1EMISDC + cGW1SERDC + cGW1NRDC))
			Return {.F., "Documento de Carga informado não existe na base de dados! Verifique os dados informados. Filial:("+ cGW1FILIAL +") Emissor:("+ cGW1EMISDC +") Tipo Documento:("+ cGW1CDTPDC +") Série:("+ cGW1SERDC +") Número:("+ cGW1NRDC +") "}
		EndIf
	EndIf

	If lPE444
		ExecBlock("GFEA0444",.F.,.F.)
	EndIf

Return GFE44Situacao("2", cTpOperacao, lPergOperacao, lVerOrig)

/*/{Protheus.doc} GFE44LiberarDC
//TODO Verifica a possibilidade e realiza a Liberação do Documento de Carga
@author SQUAD GFE - Controle de Frete
@since 14/03/2018
@version 1.0
@return ${return}, ${Pode Executar a operação, mensagem de motivo de naõ permitir a operação}
@param cGW1FILIAL, characters, Filial do Documento de Carga
@param cGW1EMISDC, characters, Emissor do Documento de Carga
@param cGW1CDTPDC, characters, Tipo de Documento de Carga
@param cGW1SERDC, characters, Série do Documento de Carga
@param cGW1NRDC, characters, Número do Documento de Carga
@param cTpOperacao, characters, Tipo de operação a ser realizada 
1 = Somente Verificação/Validação se pode Bloquear
2 = Verificação/Validação e execução da Liberação
@param lPergOperacao, logical, Apos as validações pergunta se quer realmente executar o procedimento
@param lVerOrig, logical, Indica se será considerada a validação da origem do documento.
.T. - Executa a validação da origem
.F. - Não executa a validação da origem
@type function
/*/
Function GFE44LiberarDC(cGW1FILIAL, cGW1CDTPDC, cGW1EMISDC, cGW1SERDC, cGW1NRDC, cTpOperacao, lPergOperacao, lVerOrig)
	Default cGW1FILIAL	:= '' 
	Default cGW1EMISDC	:= '' 
	Default cGW1CDTPDC	:= '' 
	Default cGW1SERDC	:= '' 
	Default cGW1NRDC	:= ''

	// Como a função é executada pela própria rotina, o registro já está posicionado.
	// quando a função for chamada externamente, deverá posicionar no registro para depois executar a ação.
	If !Empty(cGW1EMISDC) .AND. !Empty(cGW1CDTPDC) .AND. !Empty(cGW1NRDC)
		GW1->(dbSetOrder(1))
		If !GW1->(dbSeek(cGW1FILIAL + cGW1CDTPDC + cGW1EMISDC + cGW1SERDC + cGW1NRDC))
			Return {.F., "Documento de Carga informado não existe na base de dados! Verifique os dados informados. Filial:("+ cGW1FILIAL +") Emissor:("+ cGW1EMISDC +") Tipo Documento:("+ cGW1CDTPDC +") Série:("+ cGW1SERDC +") Número:("+ cGW1NRDC +") "}
		EndIf
	EndIf
Return GFE44Situacao("3", cTpOperacao, lPergOperacao, lVerOrig)

/*/{Protheus.doc} GFE44CancelarDC
//TODO Verifica a possibilidade e realiza o Cancelamento do Documento de Carga
@author SQUAD GFE - Controle de Frete
@since 14/03/2018
@version 1.0
@return ${return}, ${Pode Executar a operação, mensagem de motivo de naõ permitir a operação}
@param cGW1FILIAL, characters, Filial do Documento de Carga
@param cGW1EMISDC, characters, Emissor do Documento de Carga
@param cGW1CDTPDC, characters, Tipo de Documento de Carga
@param cGW1SERDC, characters, Série do Documento de Carga
@param cGW1NRDC, characters, Número do Documento de Carga
@param cTpOperacao, characters, Tipo de operação a ser realizada 
1 = Somente Verificação/Validação se pode Cancelar
2 = Verificação/Validação e execução do Cancelamento
@param lPergOperacao, logical, Apos as validações pergunta se quer realmente executar o procedimento
@param lVerOrig, logical, Indica se será considerada a validação da origem do documento.
.T. - Executa a validação da origem
.F. - Não executa a validação da origem
@type function
/*/
Function GFE44CancelarDC(cGW1FILIAL, cGW1CDTPDC, cGW1EMISDC, cGW1SERDC, cGW1NRDC, cTpOperacao, lPergOperacao, lVerOrig)
	Local lPE445	    := ExistBlock("GFEA0445")
	Default cGW1FILIAL	:= '' 
	Default cGW1EMISDC	:= '' 
	Default cGW1CDTPDC	:= '' 
	Default cGW1SERDC	:= '' 
	Default cGW1NRDC	:= ''

	// Como a função é executada pela própria rotina, o registro já está posicionado.
	// quando a função for chamada externamente, deverá posicionar no registro para depois executar a ação.
	If !Empty(cGW1EMISDC) .AND. !Empty(cGW1CDTPDC) .AND. !Empty(cGW1NRDC)
		GW1->(dbSetOrder(1))
		If !GW1->(dbSeek(cGW1FILIAL + cGW1CDTPDC + cGW1EMISDC + cGW1SERDC + cGW1NRDC))
			Return {.F., "Documento de Carga informado nao existe na base de dados. Verifique os dados informados. Filial:("+ cGW1FILIAL +") Emissor:("+ cGW1EMISDC +") Tipo Documento:("+ cGW1CDTPDC +") Serie:("+ cGW1SERDC +") Numero:("+ cGW1NRDC +") "}
		EndIf
	EndIf

	If lPE445
		ExecBlock("GFEA0445",.F.,.F.)
	EndIf

Return GFE44Situacao("7", cTpOperacao, lPergOperacao, lVerOrig)

//-----------------------------------------------------------------

/*/{Protheus.doc} GFE44Situacao
//TODO Verifica a possibilidade e realiza as opções de Cancelar, liberar e Bloquear o Documento de Carga 
@author SQUAD GFE - Controle de Frete
@since 14/03/2018
@version 1.0
@return ${return}, ${return_description}
@param cTpSit, characters, Tipo de Situação a ser realizada 
3 = Liberar 
7 = Cancelar 
2 = Bloquear
@param lPerg, logical, Realiza pergunta se deseja executar a opeção
@param lVerOrig, logical, Indica se será considerada a validação da origem do documento.
.T. - Executa a validação da origem
.F. - Não executa a validação da origem
@param cTpOp, characters, Tipo de operação a ser realizada 
1 = Somente Verificação/Validação 
2 = Verificação/Validação e execução da operação solicitada
@type function
/*/
Function GFE44Situacao(cTpSit, cTpOp, lPerg, lVerOrig)
	Local aRetCalcAt := {}
	Local cDescSit
	Local cSit := GW1->GW1_SIT
	Local cOrigem := GW1->GW1_ORIGEM //1=Usuario;2=ERP;3=SIGATMS;9=Outros
	Local lRetPerg := .T.
	Local cMsgPadrao := "Documento de Carga (SIGAGFE). " 

	Default lPerg		:= .F.
	Default cTpOp		:= 2
	Default lVerOrig	:= .T.

	// Só permite liberar documentos Digitados (1) ou Bloqueados (2), cadastrados no GFE
	If cTpSit == "3"
		If cSit != "1" .And. cSit != "2"
			Return {.F., cMsgPadrao + STR0012 } //'Só é possível liberar documentos digitados ou bloqueados'
		EndIf 
		//Não permite liberar documentos com origem ERO e integrados com o Datasul
		IF SuperGetMv("MV_ERPGFE",.F.,"2") == "1" .and. (cOrigem == "2" .AND. lVerOrig)  .and. cSit == "2"
			Return {.F., cMsgPadrao + "Nao foi possivel liberar o documento. Executar a rotina GFEX101 (Painel de Documento de Carga) para liberar o documento de carga.'" }
		EndIF		
	EndIf

	// Só permite bloquear documentos Digitados (1) ou Liberados/Pendentes (3)
	If cTpSit == "2" .And. cSit != "1" .And. cSit != "3"
		Return {.F., cMsgPadrao + STR0013 } //'Só é possível bloquear documentos digitados ou liberados'
	EndIf

	//Não permite cancelar um Documento de Carga vinculado a um romaneio que esteja Liberado ou Encerrado
	If cTpSit == "7"

		// Se a situação atual do documento é igual a situação solicitada, não precisa executar o procedimento
		If cTpSit == GW1->GW1_SIT
			Return {.F., cMsgPadrao + "O Documento de Carga ja encontra-se cancelado."}
		EndIf
		If (cOrigem == "2" .AND. lVerOrig)
			// Verifica se o documento de carga é de origem ERP, caso seja não permite o cancelamento
			Return {.F., cMsgPadrao + "Nao foi possivel cancelar Documento de Carga com origem ERP."}
		EndIf

		GWN->(dbSetOrder(1))
		If GWN->(dbSeek(xFilial("GWN") + GW1->GW1_NRROM)) .And. GWN->GWN_SIT $ "3;4"
			Return {.F., cMsgPadrao + "Nao foi possivel cancelar Documentos de Carga vinculados a Romaneio de Carga Liberado ou Encerrado." }
		EndIf

		If !GFEA44DELC(.F., .F.)
			Return {.F., cMsgPadrao + "Nao foi possivel eliminar os Calculos vinculados a esse Documento de Carga, portanto, nao sera efetuado o cancelamento."}
		EndIf
	EndIf

	// Foi solicitado para validar e executar o procedimento
	if cTpOp == 2
		Do Case
			Case cTpSit == "3"
			cDescSit := STR0009 //"liberar"
			Case cTpSit == "7"
			cDescSit := STR0010 //"cancelar"
			Case cTpSit == "2"
			cDescSit := STR0011 //"bloquear"
		Endcase

		// se estiver sendo executada sem interface com usuário ou não foi solicitado para executar a perguntar 
		if IsBlind() .OR. lPerg = .F.
			lRetPerg := .T.
		Else
			lRetPerg := MsgYesNo(STR0043 + cDescSit + STR0044, Capital(cDescSit) + "?") //"Deseja "###" o documento de carga selecionado?"
		EndIf

		If lRetPerg
			RecLock("GW1", .F.)
			GW1->GW1_SIT := cTpSit
			GW1->(MsUnlock())

			Do Case
				Case cTpSit == "3" // Liberar/Pendente
					RecLock("GW1", .F.)
					GW1->GW1_DTLIB := DATE()
					GW1->GW1_HRLIB := SubStr(TIME(), 1, 5)
					GW1->(MsUnlock())
				Case cTpSit == "7" // Cancelar
					RecLock("GW1", .F.)
					GW1->GW1_DTCAN  := dDataBase
					GW1->GW1_ENVEDI := "2"
					GW1->GW1_HRCAN  := SubStr(TIME(), 1, 5)
					GW1->GW1_USUCAN := cUserName
					GW1->(MsUnlock())
				Case cTpSit == "2" // Bloquear
					cDescSit := STR0011 //"bloquear"
			EndCase

			If cTpSit == "3" // Somente se a situação for liberado
				GWU->(dbSetOrder(1))
				If GWU->(dbSeek(GW1->GW1_FILIAL + GW1->GW1_CDTPDC + GW1->GW1_EMISDC + GW1->GW1_SERDC + GW1->GW1_NRDC) .And. !Empty(GWU->GWU_CDTRP))
					aRetCalcAt := GFECalCAut()
				EndIf
			EndIf

			If cTpSit == "7"
				GWN->(dbSetOrder(1) )
				If GWN->(dbSeek(xFilial('GWN') + GW1->GW1_NRROM) )

					If GWN->GWN_CALC != "2"
						RecLock("GWN", .F.)
						GWN->GWN_CALC   := "4"
						GWN->GWN_MTCALC := "Um Documento de Carga relacionado ao Romaneio foi cancelado."
						GWN->GWN_DTCALC := CToD("  /  /    ")
						GWN->GWN_HRCALC := ""
						GWN->( MsUnlock() )
					EndIf

					If !Empty(GWN->GWN_VIAGEM) 
						GFE58ATVG(GWN->GWN_VIAGEM,'4',"Um Documento de Carga relacionado ao Romaneio " + GWN->GWN_NRROM + " foi cancelado.",CToD("  /  /    "),"",GWN->GWN_FILIAL,GWN->GWN_NRROM,.T.)
					EndIf
				EndIf
			EndIf
		EndIf
	EndIf
Return {.T.,""}

//--------------------------------------------------------------

/* Validação do emitente para Destinatário e remetente */
Function GFEA044Emi(cCampo)
	Local lReturn := .T.
	Local cCDTPDC :=  If(IsInCallStack("TMSFUNLVGE"),FwFldGet('GW1_CDTPDC'),M->GW1_CDTPDC)
	Local cTpDcSent := Posicione("GV5", 1, xFilial("GV5") + cCDTPDC, "GV5_SENTID") 
	Local lFilialRem
	Local lFilialDes

	Default cCampo := ReadVar()

	// Documento SAÍDA - Remetente
	If "GW1_CDREM" $ cCampo
		lFilialRem := Posicione("GU3", 1, xFilial("GU3") + M->GW1_CDREM, "GU3_EMFIL") // Atribuir o valor de cCampo

		// Se o sentido do  tipo de documento for SAÍDA (2), o remetente deve ser do tipo filial
		If cTpDcSent == "2".AND.lFilialRem == "2"
			Help( ,, 'HELP',, STR0014, 1, 0) //'Se o sentido do documento é saída, o remetente deve ser filial'
			lReturn := .F.
		Endif
	Endif

	// Documento ENTRADA - Destinatário
	If lReturn.AND."GW1_CDDEST" $ cCampo
		lFilialDes := Posicione("GU3", 1, xFilial("GU3") + M->GW1_CDDEST, "GU3_EMFIL") // Atribuir o valor de cCampo

		// Se o sentido do  tipo de documento for ENTRADA (1), o destinatário deve ser do tipo filial
		If cTpDcSent == "1".AND.lFilialDes == "2"
			Help( ,, 'HELP',, STR0015, 1, 0) //'Se o sentido do documento é entrada, o destinatário deve ser filial'
			lReturn := .F.
		Endif
	Endif

	// Documento EXTERNO - Remetente
	If lReturn.AND."GW1_CDREM" $ cCampo
		lFilialRem  := Posicione("GU3", 1, xFilial("GU3") + M->GW1_CDREM, "GU3_EMFIL") // Atribuir o valor de cCampo

		// Se o sentido do  tipo de documento for EXTERNO (3), o remetente e o destinatário não devem ser do tipo filial
		If cTpDcSent == "3".AND.lFilialRem == "1"
			Help( ,, 'HELP',, STR0016, 1, 0) //'Se o sentido do documento é externo, o remetente e o destinarário não devem ser filial'
			lReturn := .F.
		Endif
	Endif

	// Documento EXTERNO - Destinatário
	If lReturn.AND."GW1_CDDEST" $ cCampo
		lFilialDes 	:= Posicione("GU3", 1, xFilial("GU3") + M->GW1_CDDEST, "GU3_EMFIL") // Atribuir o valor de cCampo

		// Se o sentido do  tipo de documento for EXTERNO (3), o remetente e o destinatário não devem ser do tipo filial
		If cTpDcSent == "3".AND.lFilialDes == "1"
			Help( ,, 'HELP',, STR0016, 1, 0) //'Se o sentido do documento é externo, o remetente e o destinarário não devem ser filial'
			lReturn := .F.
		Endif
	Endif

	// Documento INTERNO - Remetente
	If lReturn.AND."GW1_CDREM" $ cCampo
		lFilialRem  := Posicione("GU3", 1, xFilial("GU3") + M->GW1_CDREM, "GU3_EMFIL") // Atribuir o valor de cCampo

		// Se o sentido do  tipo de documento for INTERNO (4), o remetente deve ser do tipo filial
		If cTpDcSent == "4".AND.lFilialRem != "1"
			Help( ,, 'HELP',, STR0017, 1, 0) //'Se o sentido do documento é interno, o remetente e o destinarário devem ser filial'
			lReturn := .F.
		Endif
	Endif

	// Documento INTERNO - Destinatário
	If lReturn.AND."GW1_CDDEST" $ cCampo
		lFilialDes 	:= Posicione("GU3", 1, xFilial("GU3") + M->GW1_CDDEST, "GU3_EMFIL") // Atribuir o valor de cCampo

		// Se o sentido do  tipo de documento for INTERNO (4), o destinatário não devem ser do tipo filial
		If cTpDcSent == "4".AND.lFilialDes != "1"
			Help( ,, 'HELP',, STR0017, 1, 0) //'Se o sentido do documento é interno, o remetente e o destinarário devem ser filial'
			lReturn := .F.
		Endif
	Endif

Return lReturn

//----------------------------------------------------
Function GF44_GW8PS(oModel)
	Local lRet := .T.
	Local nLine := oModel:getLine()

	If FwFldGet("GW8_PESOR",nLine) == 0 .And. FwFldGet("GW8_PESOC",nLine) == 0 .And. FwFldGet("GW8_VALOR",nLine) == 0 .And. ;
	FwFldGet("GW8_QTDE",nLine) == 0 .And. FwFldGet("GW8_QTDALT",nLine) == 0
		Help( ,, 'HELP',, "Informe pelo menos um valor para estes itens: Peso, Peso Cubado, Valor, Quantidade ou Quantidade/Peso Alternativo.", 1, 0,) //'Informe pelo menos um valor para estes itens: Peso, Peso Cubado, valor ou Quantidade'
		lRet := .F.
	EndIf

Return lRet

//-----------------------------------------------
Function GFEA044VL(oModel)
	Local nOpc 		:= oModel:GetOperation()
	Local cGFE001 	:= IIF(Empty(SuperGetMv("MV_GFE001",.F.,"1")),"1",SuperGetMv("MV_GFE001",.F.,"1")) 

	/* --- Alteração --- */
	// Só é possível alterar, documentos com situação Digitado ou Liberado que não foram calculados

	If nOpc == MODEL_OPERATION_UPDATE .And. GW1->GW1_SIT != "1" .And. GW1->GW1_SIT != "3" .And. IIf(IsBlind(), GW1->GW1_SIT != "4", .T.)		 
		If IsBlind()
			Help( ,, 'HELP',, "Não é permitido alterar Documentos de Carga com a situação Bloqueado, Cancelado na integração.", 1, 0,) //"Não é permitido alterar Documentos de Carga com a situação Bloqueado, Cancelado na integração."
			Return .F.
		Else    
			If GW1->GW1_ORIGEM != "3" .Or. !("TMS" $ FunName())
				Help( ,, 'HELP',, STR0018, 1, 0,) //'Não é permitido alterar documentos com a situação Bloqueado, Cancelado ou Embarcado.'
				Return .F.
			EndIf	
		EndIf
	EndIf

	/* --- Eliminação  --- */
	If nOpc == MODEL_OPERATION_DELETE
		// Caso a exclusão seja acionada pelo ERP
		If !IsInCallStack("MATA521ENF")
			If !IsInCallStack("ExclDocGFE")
				// Não excluir quando Origem for ERP (2)
				If GW1->GW1_ORIGEM == "2" .And. !IsBlind() .And. cGFE001 != "3"
					Help( ,, 'HELP',, STR0019, 1, 0,) //'Não é possível excluir documentos de origem ERP'
					Return .F.
				EndIf
			EndIf
		EndIf

		//'Só é possível excluir documentos com situação Digitado, Liberado ou Bloqueado'
		If GW1->GW1_SIT != "1" .And. GW1->GW1_SIT != "2" .And. GW1->GW1_SIT != "3" .And. GW1->GW1_SIT != "4"
			Help( ,, 'HELP',, "Só é possível excluir documentos com situação Digitado, Liberado, Bloqueado ou Embarcado.", 1, 0,) //"Só é possível excluir documentos com situação Digitado, Liberado, Bloqueado ou Embarcado."
			Return .F.
		EndIf

		If !Empty(GW1->GW1_DTSAI)
			Help(,, 'HELP',, "Não é possível excluir Documentos de Carga com Data de Saída informada.", 1, 0)  //"Não é possível excluir Documentos de Carga vinculados a Romaneios de Carga com situação 'Liberado' ou 'Encerrado'."
			Return .F.
		ElseIf !GFEA44DELC(.T., .T.)
			Help( ,,'HELP',, "Não Foi possível eliminar os Cálculos vinculados a esse Documento de Carga, portanto, não será efetuada a exclusão.", 1, 0,) // "Não Foi possível eliminar os Cálculos vinculados a esse Documento de Carga, portanto, não será efetuada a exclusão."
			Return .F.
		EndIf
	EndIf

Return .T.

//------------------------------------------------
Function GF44_GWUPS(oModel)
	Local lRet := .T.
	Local nI
	Local nLine := oModel:getLine()
	Local nFirstLine := 0
	Local cTpDcSent
	Local dGWU_DTPENT := FwFldGet('GWU_DTPENT',nLine)
	Local dPrevEntAnt := CriaVar('GWU_DTPENT',.F.), dPrevEntPos := CriaVar('GWU_DTPENT',.F.)
	Local aSaveLines := FWSaveRows()

	For nI := 1 To oModel:Length()
		oModel:GoLine( nI )

		/* Data de Entrega e Previsão de Entrega devem ser maiores que a data de Emissão do documento */
		If !oModel:IsDeleted()

			// Data Entrega
			//.Or. FwFldGet("GWU_DTENT",nI) < FwFldGet("GW1_DTIMPL")) Retirada validação com a data de implantação
			If !Empty(FwFldGet("GWU_DTENT",nI)) .AND. FwFldGet("GWU_DTENT",nI) < FwFldGet("GW1_DTEMIS")
				Help( ,, 'HELP',, StrTran(STR0045,"[reg]",Str(nI)), 1, 0,) //'A Data de Entrega do trecho, no registro [reg] deve ser maior que a Data de Emissão do documento'
				lRet := .F.
				Exit
			EndIf

			// Data Previsão Entrega
			// .Or. FwFldGet("GWU_DTPENT",nI) < FwFldGet("GW1_DTIMPL")) Retirada validação com a data de implantação
			If !Empty(FwFldGet("GWU_DTPENT",nI)) .AND. FwFldGet("GWU_DTPENT",nI) < FwFldGet("GW1_DTEMIS")
				Help( ,, 'HELP',, StrTran(STR0046,"[reg]",Str(nI)), 1, 0,) //'A Data de Previsão do trecho, no registro [reg] deve ser maior que a Data de Emissão do documento.'
				lRet := .F.
				Exit
			EndIf

			//Hora de previsão de entrega não pode ser menor que a anterior, se for a mesma data.
			If nI > 1 .And. Val(StrTran(FwFldGet("GWU_HRPENT",nI),":","")) < Val(StrTran(FwFldGet("GWU_HRPENT",(nI-1)),":","")) .And. FwFldGet("GWU_DTPENT",nI) == FwFldGet("GWU_DTPENT",(nI-1))
				Help( ,, 'HELP',, StrTran(StrTran(STR0078,"[reg]",Str(nI)),"[hr_ant]",  If( ":" $ FwFldGet("GWU_HRPENT",(nI-1)), FwFldGet("GWU_HRPENT",(nI-1)), Stuff(FwFldGet("GWU_HRPENT",(nI-1)),3,0,":"))), 1, 0,) //'A hora de previsão de entrega no registro [reg] deve ser maior que [hr_ant].'
				lRet := .F.
				Exit
			EndIf

			//Armazenando o valor das previsão das datas de entrega
			If !Empty(FwFldGet('GWU_DTPENT',nI))

				If nI < nLine .And. nLine > 1
					dPrevEntAnt := FwFldGet('GWU_DTPENT',nI)
				EndIf
				If Empty(dPrevEntPos) .And. nI > nLine .And. nI <= oModel:Length()
					dPrevEntPos := FwFldGet('GWU_DTPENT',nI)
				EndIf
			EndIf
		EndIf

		/* Busca a primeira Linha */
		If nFirstLine == 0.AND.!oModel:IsDeleted()
			nFirstLine := nI
		EndIf
	Next nI

	//não permitir informar o campo de data de previsão de entrega de um trecho menor que a data do trecho anterior na pasta Trechos
	If dGWU_DTPENT < dPrevEntAnt .And. !Empty(dGWU_DTPENT) .And. !Empty(dPrevEntAnt)
		Help( ,, 'HELP',, STR0047 +Transform(dPrevEntAnt, '99/99/9999'), 1, 0,)  //"A data de previsão de entrega deve ser maior ou igual que "
		lRet := .F.
		//não permitir informar o campo de data de previsão de entrega de um trecho menor que a data do trecho anterior na pasta Trechos
	ElseIf dGWU_DTPENT > dPrevEntPos .And. !Empty(dGWU_DTPENT) .And. !Empty(dPrevEntPos)
		Help( ,, 'HELP',, STR0048 +Transform(dPrevEntPos, '99/99/9999'), 1, 0,)	  //"A data de previsão de entrega deve ser menor ou igual que "
		lRet := .F.
	EndIf

	If lRet.AND.nLine > nFirstLine
		// Só permite incluir mais de um trecho se o frete for CIF c/ Redespacho (2), FOB c/ Redespacho (4), Consi c/ Redespacho (6)
		If FwFldGet("GW1_TPFRET") != "2".AND.FwFldGet("GW1_TPFRET") != "4".AND.FwFldGet("GW1_TPFRET") != "6"
			Help( ,, 'HELP',, STR0022, 1, 0,)	  //'Só é permitido incluir mais de um trecho quando o tipo de frete for CIF com Redespacho, FOB com Redespacho ou Consignado com Redespacho'
			lRet := .F.
		EndIf
	EndIf

	If lRet.AND.nLine != nFirstLine.AND.FwFldGet("GWU_PAGAR",nLine) == "1"
		If Posicione("GU3", 1, xFilial("GU3") + FwFldGet("GWU_CDTRP",nLine), "GU3_AUTON") == "1"
			Help( ,, 'HELP',, STR0023, 1, 0,) //'Só é permitido incluir proprietário autônomo em trecho pago, quando for o primeiro trecho'
			lRet := .F.
		EndIf
	EndIf

	If lRet
		cTpDcSent := Posicione("GV5", 1, xFilial("GV5") + FwFldGet("GW1_CDTPDC"), "GV5_SENTID")

		// Quando o Tipo do Documento for Entrada (1):
		//  - Tipo de Frete CIF, Pagar = Não (2)
		//  - Tipo de Frete FOB, Pagar = Sim (1)
		If cTpDcSent == "1"
			// CIF (1), Pagar deverá ser NÃO (1)
			If FwFldGet("GW1_TPFRET") == "1".AND.FwFldGet("GWU_PAGAR", nLine) != "2"
				Help( ,, 'HELP',, STR0024, 1, 0,)	  //'Para Tipo de Documentos no sentido Entrada e Frete CIF, o trecho não deve ser pago'
				lRet := .F.
			EndIf

			// FOB (3), Pagar deverá ser SIM (1)
			If FwFldGet("GW1_TPFRET") == "3".AND.FwFldGet("GWU_PAGAR", nLine) != "1"
				Help( ,, 'HELP',, STR0025, 1, 0,)	  //'Para Tipo de Documentos no sentido Entrada e Frete FOB, o trecho deve ser pago'
				lRet := .F.
			EndIf
		EndIf

		// Quando o Tipo do Documento for Saida (2):
		//  - Tipo de Frete CIF, Pagar = Sim (1)
		//  - Tipo de Frete FOB, Pagar = Não (2)
		If cTpDcSent == "2"
			// CIF (1), Pagar deverá ser SIM (1)
			If FwFldGet("GW1_TPFRET") == "1".AND.FwFldGet("GWU_PAGAR", nLine) != "1"
				Help( ,, 'HELP',, STR0026, 1, 0,) //'Para Tipo de Documentos no sentido Saída e Frete CIF, o trecho deve ser pago'
				lRet := .F.
			EndIf

			// FOB (3), Pagar deverá ser NÃO (2)
			If FwFldGet("GW1_TPFRET") == "3".AND.FwFldGet("GWU_PAGAR", nLine) != "2"
				Help( ,, 'HELP',, STR0027, 1, 0,) //'Para Tipo de Documentos no sentido Saída e Frete FOB, o trecho não deve ser pago'
				lRet := .F.
			EndIf
		EndIf
	EndIf

	If lRet
		If FwFldGet("GW1_ORIGEM") != "2" .And. Empty(FwFldGet("GWU_CDTRP"))
			Help( ,, 'HELP',, "Deve-se informar o Transportador do Trecho", 1, 0,) //Deve-se informar o Transportador do Trecho.
			lRet := .F.
		EndIf
	EndIf

	If lRet
		oModel:GoLine(nLine)
	EndIf

	FWRestRows( aSaveLines )

Return(lRet)

//------------------------------------------------------

Function GFE44EMIS()
	Local lRet := ""

	dbSelectArea("GU3")
	dbSetOrder(11)
	If dbSeek(SM0->M0_CGC)
		lRet := GU3->GU3_CDEMIT + GU3->GU3_NMEMIT
	EndIf

	dbSelectArea("GU3")
	dbSetOrder(1)
Return(lRet)

//-------------------------------------------------------

Function GFE44Post(oModel)
	Local lRet 			:= .T.
	Local nI
	Local nCont
	Local nSeq 			:= 0
	Local oModelGW8 	:= oModel:GetModel("GFEA044_GW8")
	Local oModelGWU 	:= oModel:GetModel("GFEA044_GWU")
	Local oModelGWB 	:= oModel:GetModel("GFEA044_GWB")
	Local oModelGXP
	Local oModelGW1 	:= oModel:GetModel("GFEA044_GW1")
	local oStructGW1	:= oModelGW1:GetStruct()
	Local nFirstLine, nLine
	Local nQTDE_GWB
	Local nOpc      	:= oModel:GetOperation()
	Local cCidDest  	:= If(Empty(FwFldGet("GW1_ENTNRC")), Posicione("GU3", 1, xFilial('GU3') + oModel:GetValue('GFEA044_GW1', 'GW1_CDDEST'), 'GU3_NRCID'), oModel:GetValue('GFEA044_GW1', 'GW1_ENTNRC'))
	Local lCidDest  	:= .F. 	// variavel responsavel por verificar se há o trecho da cidade do destinatario (cCidDest)
	Local nCidDest 				// variavel responsavel em armazenar a linha aonde está o trecho da cidade do destinatario
	Local cGW1_SENTID
	Local lCIFSaida 	:= .F.	//Valida a existencia de um trecho pago em um Doc Carga Saida CIF
	Local lFOBSaida 	:= .T.	//Valida a existencia de um trecho pago em um Doc Carga Saida FOB
	Local lCIFEnt   	:= .T.	//Valida a existencia de um trecho pago em um Doc Carga Entrada CIF
	Local lFOBEnt   	:= .F.	//Valida a existencia de um trecho pago em um Doc Carga Entrada FOB
	Local aSaveLines 	:= FWSaveRows()
	Local cRat 			:= SuperGetMv("MV_CRIRAT",.F.,"0")
	Local lValRat 		:= SuperGetMv("MV_CRIVAL",.F.,.F.) .And. cRat $ '1234'
	Local lTemItemRat 	:= .F.
	Local ntTValor 		:= 0
	Local cEmitPF 		:= "1"
	Local nRetPE  		:= 0
	Local cRegiao 		:= ""
	Local cCidade 		:= "", cUF := "", cCEP := ""
	Local nY
	Local cQuery
	Local cAlQuery
	Local lChavUnic 	:= TamSx3("GW1_SERDC")[1] == 14
	Local cEspGFE		:= "GFE"
	Local lPE441		:= ExistBlock("GFEA0441")
	Local lMV_GFE017 	:= SuperGetMv("MV_GFE017",.F., .T.)		// Indica se o Documento de Origem (GXP) pode estar relacionado a somente um Documento de Carga (GW1)
	Local oQry

	Private lRejeita 	:= .F., lBloqueia := .F., lLibera := .F.
	Private cMotReject 	:= ""

	If GFXTB12117('GXP')
		oModelGXP 	:= oModel:GetModel("GFEA044_GXP")
	EndIf

	GV5->(DbSetOrder(1))
	If GV5->(DbSeek(xFilial("GV5") + FwFldGet("GW1_CDTPDC")))
		cGW1_SENTID := GV5->GV5_SENTID
		cEmitPF     := GV5->GV5_EMITPF
	EndIf 

	If nOpc == MODEL_OPERATION_DELETE

		GFEA44DELC(.F., .T.)

		GWN->( dbSetOrder(1) )
		If GWN->( dbSeek(GW1->GW1_FILIAL + GW1->GW1_NRROM) )

			If GWN->GWN_CALC != "2"
				RecLock("GWN", .F.)
				GWN->GWN_CALC   := "4" // Romaneio necessita recálculo
				GWN->GWN_MTCALC := "Um Documento de Carga relacionado ao Romaneio foi excluído."
				GWN->GWN_DTCALC := CToD("  /  /    ")
				GWN->GWN_HRCALC := ""
				GWN->( MsUnlock() )
			EndIf

			If !Empty(GWN->GWN_VIAGEM) 
				GFE58ATVG(GWN->GWN_VIAGEM,'4',"Um Documento de Carga relacionado ao Romaneio " + GWN->GWN_NRROM + " foi excluído.",CToD("  /  /    "),"",GWN->GWN_FILIAL,GWN->GWN_NRROM,.T.)
			EndIf
		EndIf
	EndIf

	If nOpc == MODEL_OPERATION_INSERT .Or. nOpc == MODEL_OPERATION_UPDATE

		// Integração - Atribui o código da cidade na GWU, quando não for informado, pelo nome e uf da cidade
		For nI := 1 To oModelGWU:Length()
			oModelGWU:GoLine( nI )

			// Integração - Atribui o código da cidade, quando não for informado, pelo nome e uf da cidade
			If AllTrim(FwFldGet("GWU_NRCIDD",nI)) == "0".OR.Empty(FwFldGet("GWU_NRCIDD",nI))
				dbSelectArea("GU7")
				GU7->( dbSetOrder(3) )
				If GU7->( dbSeek(xFilial("GU7") + PadR(Upper(FwFldGet("GWU_NMCIDD",nI)),50, " ") + PADR(UPPER(FwFldGet("GWU_UFD",nI)),2, " ")) )
					oModel:LoadValue( 'GFEA044_GWU', 'GWU_NRCIDD', GU7->GU7_NRCID)
				Else
					oModel:LoadValue('GFEA044_GWU', 'GWU_NRCIDD', "0")
					oModel:LoadValue('GFEA044_GWU', 'GWU_NMCIDD', "")
					oModel:LoadValue('GFEA044_GWU', 'GWU_UFD'   , "")
				EndIf
			EndIf
		Next nI

		// Integração Protheus
		// Atribui o Uso do Documento de Carga como Ativo caso exista pelo menos um item como ativo
		If GetNewPar("MV_CADERP", "2") == "1" .AND. GetNewPar("MV_ERPGFE", "0") == "2"
			For nI := 1 To oModelGW8:Length()
				oModelGW8:GoLine( nI )

				If AllTrim(FwFldGet("GW8_ATUATF",nI)) == "S"
					oModel:LoadValue( 'GFEA044_GW1', 'GW1_USO', "3")
					Exit
				EndIf
			Next nI
		EndIf
		// FIM - Integração

		//Atribui automaticamente o valor do campo GW1_QTVOL com a totalização do campo GWB_QTDE,
		nQTDE_GWB := 0

		nLine := oModelGWB:GetLine()
		For nI := 1 To oModelGWB:GetQtdLine()
			oModelGWB:GoLine( nI )
			If !(oModelGWB:IsDeleted())
				nQTDE_GWB += FwFldGet("GWB_QTDE",nI)
			EndIf
		Next nI
		oModelGWB:GoLine( nLine )

		//Se não houver nenhum GWB então o campo deve receber a totalização do campo GW8_QTDE dos registros da GW8 relacionados ao GW1
		nLine := oModelGW8:GetLine()
		If nQTDE_GWB = 0
			For nI := 1 To oModelGW8:GetQtdLine()
				oModelGW8:GoLine( nI )
				If !oModelGW8:IsDeleted()
					nQTDE_GWB := nQTDE_GWB  + FwFldGet("GW8_QTDE",nI)
				EndIf
			Next nI
		EndIf
		oModelGW8:GoLine( nLine )

		// Ponto de entrada para permitir a manipulação da quantidade de
		// volumes do documento de carga
		If lPE441
			nRetPE := ExecBlock("GFEA0441",.F.,.F.,{nQTDE_GWB})
			If ValType(nRetPE) == "N"
				nQTDE_GWB := nRetPE
			EndIf
		EndIf

		oModel:LoadValue( 'GFEA044_GW1', 'GW1_QTVOL', IF(nQTDE_GWB - noround(nQTDE_GWB,0) > 0 , noround(nQTDE_GWB,0)  + 1 , nQTDE_GWB ) )
		//FIM - Atribui automaticamente o valor do campo GW1_QTVOL com a totalização do campo GWB_QTDE

		//Validação de Filtro de Documentos de Carga
		GFEA044BLO("GW1")
		nI := 0
		For nCont := 1 To oModelGW8:Length()
			oModelGW8:GoLine( nI )
			GFEA044BLO("GW8")
			nI := nI + 1
			//Validação para o critério de rateio
			//Possuindo um valor maior que zero já está válido 
			If lValRat .And. ntTValor <= 0 
				lTemItemRat := .T.
				If cRat == "1"
					ntTValor := FwFldGet("GW8_PESOR",nI) + FwFldGet("GW8_PESOC",nI)
				EndIf
				If cRat == "2"
					ntTValor := FwFldGet("GW8_VALOR",nI)
				EndIf
				If cRat == "3"
					ntTValor := FwFldGet("GW8_QTDE",nI)
				EndIf
				If cRat == "4"
					ntTValor := FwFldGet("GW8_VOLUME",nI)
				EndIf
			EndIf
		Next nCont

		If lValRat
			If ntTValor <= 0 .And. FwFldGet("GW8_RATEIO",nI) == "1"
				If cRat == "1"
					cRat := "peso"
				EndIf
				If cRat == "2"
					cRat := "valor"
				EndIf
				If cRat == "3"
					cRat := "quantidade"
				EndIf
				If cRat == "4"
					cRat := "volume"
				EndIf
				Help( ,, 'HELP',,"Conforme o parâmetro MV_CRIVAL, não é possível atualizar o documento de carga sem informar o " + cRat + " dos itens.",1,0)
				lRet := .F.
			EndIf				
		EndIf

		For nI := 1 To oModelGWU:Length()
			oModelGWU:GoLine( nI )
			GFEA044BLO("GWU")
		Next nI

		If lRet
			If lRejeita //lRejeita
				//"REGREJEITA" - Utilizado na integração das Notas Fiscais de Entrada e Saída
				Help( ,, 'HELP',"REGREJEITA", "Existe um filtro de rejeição cadastrado para o documento de carga. Filtro: " + cMotReject, 1, 0,)  //"Registro foi Rejeitado."
				lRet := .F.
			ElseIf lBloqueia
				Help( ,, 'HELP',, STR0082, 1, 0,)  //"Registro foi Bloqueado."
				oModel:LoadValue( 'GFEA044_GW1', 'GW1_SIT', "2")
			ElseIf lLibera
				if oModel:GetValue('GFEA044_GW1', 'GW1_SIT') != "4" // quando a situação já é embarcada, não precisa voltar para liberada.
					oModel:LoadValue( 'GFEA044_GW1', 'GW1_SIT', "3")
				EndIf
			EndIf
		EndIf
		// FIM - Validação de Filtro de Documentos de Carga
	EndIf

	If nOpc == MODEL_OPERATION_UPDATE .And. lChavUnic
		cSerieGFE := FwFldGet("GW1_SERDC")
	EndIf

	If nOpc == MODEL_OPERATION_INSERT
		GW1->( dbSetOrder(01) )
		If lChavUnic .And. Len(AllTrim(FwFldGet("GW1_SERDC"))) <= 3
			cSerieGFE := SerieNfId("GW1",4,"GW1_SERDC",FwFldGet("GW1_DTEMIS"),cEspGFE,substr(FwFldGet("GW1_SERDC"),1,3))
		Else
			cSerieGFE := FwFldGet("GW1_SERDC")
		EndIf

		If GW1->( dbSeek(xFilial("GW1") + FwFldGet("GW1_CDTPDC")+ FwFldGet("GW1_EMISDC")+ cSerieGFE + FwFldGet("GW1_NRDC")))
			//"EXISTGFE" - Utilizado na integração das Notas Fiscais de Entrada e Saída
			Help( ,, 'HELP',"EXISTGFE", "Já existe Documento de Carga cadastrado com a chave informada na Filial " + xFilial("GW1"), 1, 0) //"Já existe Documento de Carga cadastrado com a chave informada na Filial "
			lRet := .F.
		EndIf

		//Inclusão por integração
		If lRet .And. !Empty(oModel:GetValue('GFEA044_GW1', 'GW1_NRROM'))

			dbSelectArea("GWN")
			GWN->( dbSetOrder(1) )
			If GWN->( dbSeek(xFilial("GWN") + oModel:GetValue('GFEA044_GW1', 'GW1_NRROM')) ) 
				If GWN->GWN_CALC != "2"
					RecLock("GWN", .F.)
					GWN->GWN_CALC   := "4" // Romaneio necessita recálculo
					GWN->GWN_MTCALC := "Um Documento de Carga foi vinculado ao Romaneio via integração."
					GWN->GWN_DTCALC := CToD("  /  /    ")
					GWN->GWN_HRCALC := ""
					GWN->(MsUnlock())
				EndIf

				If GWN->GWN_ORI == "2" .And. cEmitPF == "2" //Se a origem do romaneio é ERP e o tipo de documento de carga não emite pré-fatura
					RecLock("GWN", .F.)
					GWN->GWN_BLOQPF := "1" //Bloqueia emissão de pré-fatura
					GWN->(MsUnlock())
				EndIf

				If !Empty(GWN->GWN_VIAGEM)
					GFE58ATVG(GWN->GWN_VIAGEM,"4","Um Documento de Carga foi vinculado ao Romaneio " + GWN->GWN_NRROM + " via integração.",CToD("  /  /    "),"",GWN->GWN_FILIAL,GWN->GWN_NRROM,.T.)
				EndIf
			EndIf
		EndIf
	EndIf

	If nOpc != MODEL_OPERATION_DELETE
		/* Deve informar pelo menos um Item de carga */
		For nI := 1 To oModelGW8:Length() 	// Busca o primeiro registro válido
			If !oModelGW8:IsDeleted()
				nFirstLine := nI
				Exit
			EndIf
		Next

		If Empty(FwFldGet("GW8_ITEM", nFirstLine))
			Help( ,, 'HELP',, STR0028, 1, 0,) //'Deve ser informado pelo menos um Item de Documento de Carga'
			lRet := .F.
		EndIf

		/* Ordena a sequencia dos Trechos de Transporte */
		For nI := 1 To oModelGWU:Length()
			oModelGWU:GoLine( nI )
			If !oModelGWU:IsDeleted()
				//verifica se o trecho é da cidade do destinatario
				If cCidDest == FwFldGet('GWU_NRCIDD', nI)
					lCidDest := .T.
					nCidDest := nI
				EndIf

				nSeq++

				oModel:LoadValue( 'GFEA044_GWU', 'GWU_SEQ', StrZero(nSeq, 2))
				//não permitir informar o campo de hora de previsão de entrega dos trechos menor que a hora de implantação ao incluir e alterar um documento de carga.
				If FwFldGet("GWU_DTPENT", nI) < oModel:GetValue('GFEA044_GW1','GW1_DTIMPL') .And. !Empty(DtoS(FwFldGet("GWU_DTPENT", nI)))
					Help( ,, 'HELP',,STR0049+FwFldGet("GWU_SEQ", nI) +STR0050+ Transform(oModel:GetValue('GFEA044_GW1','GW1_DTIMPL'), '99/99/9999'), 1, 0,)  //'A data de previsão de entrega do trecho '###' deve ser maior que '
					lRet := .F.
				EndIf

				// Hora Previsão Entrega
				If FwFldGet("GWU_DTPENT",nI) == oModel:GetValue('GFEA044_GW1','GW1_DTIMPL') .AND. FwFldGet("GWU_HRPENT",nI) < STRTRAN(oModel:GetValue('GFEA044_GW1','GW1_HRIMPL'),':',"") .And. !Empty(FwFldGet("GWU_HRPENT",nI))
					Help( ,, 'HELP',,STR0051+FwFldGet("GWU_SEQ", nI) +STR0050+ Transform(oModel:GetValue('GFEA044_GW1','GW1_HRIMPL'), '99:99'), 1, 0,)  //'A hora de previsão de entrega do trecho '###' deve ser maior que '
					lRet := .F.
				EndIf

				If cGW1_SENTID == '2' // Doc Carga com sentido Saida
					//Doc Carga Sentido Saida e CIF deve conter ao menos 1 trecho pago
					If oModel:GetValue('GFEA044_GW1','GW1_TPFRET') $ '12' .And. FwFldGet("GWU_PAGAR", nI) == '1'
						lCIFSaida := .T.
						//Doc Carga Sentido Saida e FOB não deve ter trechos pagos
					ElseIf oModel:GetValue('GFEA044_GW1','GW1_TPFRET') $ '34' .And. FwFldGet("GWU_PAGAR", nI) == '1'
						lFOBSaida := .F.
					EndIf
				ElseIf cGW1_SENTID == '1' // Doc Carga com sentido Entrada
					// Doc Carga com sentido Entrada e CIF não deve ter trechos pagos
					If oModel:GetValue('GFEA044_GW1','GW1_TPFRET') $ '12' .And. FwFldGet("GWU_PAGAR", nI) == '1'
						lCIFEnt := .F.
						// Doc Carga com sentido Entrada e FOB deve conter ao menos 1 trecho pago
					ElseIf oModel:GetValue('GFEA044_GW1','GW1_TPFRET') $ '34' .And. FwFldGet("GWU_PAGAR", nI) == '1'
						lFOBEnt := .T.
					EndIf
				EndIf
			EndIf
		Next nI

		If FwFldGet('GW1_ORIGEM') != '3'
			If !Empty(FwFldGet('GWU_CDTRP'))
				//Mensagens de erro referentes a validação do tipo de Doc Carga e os trechos
				If !lCIFSaida .And. oModel:GetValue('GFEA044_GW1','GW1_TPFRET') $ '12' .And. cGW1_SENTID == '2'
					Help( ,, 'HELP',, STR0052, 1, 0,) //'Deve haver, pelo menos um, trecho com Pagar "Sim" quando o Tipo do Frete for "CIF" ou "CIF Redesp" e o sentido do documento for "Saida".'
					lRet := .F.
				ElseIf !lFOBSaida .And. oModel:GetValue('GFEA044_GW1','GW1_TPFRET') $ '34' .And. cGW1_SENTID == '2'
					Help( ,, 'HELP',, STR0053, 1, 0,) //'Não pode haver trechos com Pagar "Sim" quando o Tipo do Frete for "FOB" ou "FOB Redesp" e o sentido do documento for "Saida".'
					lRet := .F.
				ElseIf !lCIFEnt .And. oModel:GetValue('GFEA044_GW1','GW1_TPFRET') $ '12'  .And. cGW1_SENTID == '1'
					Help( ,, 'HELP',, STR0054, 1, 0,) //'Não pode haver trechos com Pagar "Sim" quando o Tipo do Frete for "CIF" ou "CIF Redesp" e o sentido do documento for "Entrada".'
					lRet := .F.
				ElseIf !lFOBEnt  .And. oModel:GetValue('GFEA044_GW1','GW1_TPFRET') $ '34' .And. cGW1_SENTID == '1'
					Help( ,, 'HELP',, STR0055, 1, 0,) //'Deve haver, pelo menos um, trecho com Pagar "Sim" quando o Tipo do Frete for "FOB" ou "FOB Redesp" e o sentido do documento for "Entrada".'
					lRet := .F.
				EndIf
			EndIf

			If !lCidDest //Se não encontrou a cidade do destinatario no grid de trechos
				Help( ,, 'HELP',, STR0056+ POSICIONE("GU7",1,XFILIAL("GU7")+cCidDest,"GU7_NMCID"), 1, 0,)  //'É obrigatorio o cadastro de um trecho com a cidade: '
				lRet := .F.
			ElseIf lCidDest .And. nCidDest != oModelGWU:Length()
				// se encontrou a cidade mas não é o ultimo trecho do grid
				nI := oModelGWU:Length()
				While nI != 1 .And. lRet
					oModelGWU:GoLine( nI )
					If!oModelGWU:IsDeleted()
						If cCidDest != FwFldGet('GWU_NRCIDD', nI)
							Help( ,, 'HELP',, STR0057+POSICIONE("GU7",1,XFILIAL("GU7")+cCidDest,"GU7_NMCID") + STR0058, 1, 0,) //'O trecho com a cidade '###' deve ser o último trecho.'
							lRet := .F.
						EndIf
					EndIf
					nI := nI - 1
				EndDo
			EndIf

			If nSeq <= 1 .And. (FwFldGet("GW1_TPFRET") == "2" .Or. FwFldGet("GW1_TPFRET") == "4" .Or. FwFldGet("GW1_TPFRET") == "6")
				Help( ,, 'HELP',, STR0029, 1, 0,) //'Deve ser informado mais de um trecho para tipo de frete CIF com Redespacho, FOB com Redespacho ou Consignado com Redespacho'
				lRet := .F.
			EndIf

			// Só permite incluir mais de um trecho se o frete for CIF c/ Redespacho (2), FOB c/ Redespacho (4), Consi c/ Redespacho (6)
			If lRet.AND.nSeq > 1
				If FwFldGet("GW1_TPFRET") != "2" .And. FwFldGet("GW1_TPFRET") != "4" .And. FwFldGet("GW1_TPFRET") != "6"
					Help( ,, 'HELP',, STR0022, 1, 0,) //'Só é permitido incluir mais de um trecho quando o tipo de frete for CIF com Redespacho, FOB com Redespacho ou Consignado com Redespacho'
					lRet := .F.
				EndIf
			EndIf
		EndIf
	EndIf

	If lMV_GFE017
		If lRet .And. nOpc != MODEL_OPERATION_DELETE .And. GFXTB12117("GXP") == .T.
			For nI := 1 to oModelGXP:Length()
				If !oModelGXP:IsDeleted(nI) .And. !Empty(oModelGXP:GetValue("GXP_FILORI",nI)+oModelGXP:GetValue("GXP_EMIORI",nI)+oModelGXP:GetValue("GXP_SERORI",nI)+oModelGXP:GetValue("GXP_DOCORI",nI))
					
					cAlQuery := GetNextAlias()

					cQuery := "SELECT GXP_FILIAL,GXP_CDTPDC,GXP_EMISDC,GXP_SERDC,GXP_NRDC"
					cQuery += " FROM " +  RetSqlName("GXP")
					cQuery += " WHERE D_E_L_E_T_ = ' '"
					cQuery += " AND GXP_FILORI = ?"
					cQuery += " AND GXP_EMIORI = ?"
					cQuery += " AND GXP_SERORI = ?"
					cQuery += " AND GXP_DOCORI = ?"

					cQuery := ChangeQuery(cQuery)
					oQry := FWExecStatement():New(cQuery)

					oQry:SetString(1, oModelGXP:GetValue("GXP_FILORI",nI))
					oQry:SetString(2, oModelGXP:GetValue("GXP_EMIORI",nI))
					oQry:SetString(3, oModelGXP:GetValue("GXP_SERORI",nI))
					oQry:SetString(4, oModelGXP:GetValue("GXP_DOCORI",nI))
				
					If nOpc == MODEL_OPERATION_UPDATE
					
						cQuery += " AND (GXP_FILIAL <> ?"
						cQuery += " OR   GXP_CDTPDC <> ?"
						cQuery += " OR   GXP_EMISDC <> ?"
						cQuery += " OR   GXP_SERDC  <> ?"
						cQuery += " OR   GXP_NRDC   <> ? )"

						cQuery := ChangeQuery(cQuery)
						oQry := FWExecStatement():New(cQuery)

						oQry:SetString(1, oModelGXP:GetValue("GXP_FILORI",nI))
						oQry:SetString(2, oModelGXP:GetValue("GXP_EMIORI",nI))
						oQry:SetString(3, oModelGXP:GetValue("GXP_SERORI",nI))
						oQry:SetString(4, oModelGXP:GetValue("GXP_DOCORI",nI))
						oQry:SetString(5, FwFldGet("GW1_FILIAL"))
						oQry:SetString(6, FwFldGet("GW1_CDTPDC"))
						oQry:SetString(7, FwFldGet("GW1_EMISDC"))
						oQry:SetString(8, FwFldGet("GW1_SERDC" ))
						oQry:SetString(9,FwFldGet("GW1_NRDC"  ))
					EndIf
					
					cAlQuery := oQry:OpenAlias()
					If !(cAlQuery)->(Eof())
						Help( ,, 'HELP',, "Linha " + cValToChar(nI) + " : documento de origem " + oModelGXP:GetValue("GXP_SERORI",nI) + "/" + oModelGXP:GetValue("GXP_DOCORI",nI) + " já está relacionado ao documento de carga " + Transform((cAlQuery)->GXP_SERDC,"!!!") + "/" + (cAlQuery)->GXP_NRDC , 1, 0,)
						lRet := .F.
						(cAlQuery)->(dbCloseArea())
						Exit
					EndIf
					(cAlQuery)->(dbCloseArea())
				EndIf
			Next nI
		EndIf
	End If

	If lRet .And. nOpc == MODEL_OPERATION_UPDATE
		oModel:LoadValue('GFEA044_GW1', 'GW1_DTALT', DATE())
		oModel:LoadValue('GFEA044_GW1', 'GW1_HRALT', SUBSTR(Time(), 1, 5))

		If (oModel:IsFieldUpdated('GFEA044_GW1', 'GW1_SIT') .And. oModel:GetValue('GFEA044_GW1', 'GW1_SIT') == "7");
			.Or. (oModel:GetValue('GFEA044_GW1', 'GW1_SIT') == "4" .And. oModel:GetValue('GFEA044_GW1', 'GW1_ORIGEM') == "3")

			//Só encontrará o Romaneio do Documento de Carga numa alteração quando for via integração.
			dbSelectArea("GWN")
			GWN->( dbSetOrder(1) )
			If GWN->( dbSeek(xFilial("GWN") + oModel:GetValue('GFEA044_GW1', 'GW1_NRROM')) )

				If GWN->GWN_SIT == "3" .And. oModel:GetValue('GFEA044_GW1', 'GW1_SIT') == "7"
					Help(,, 'HELP',, "O Romaneio vinculado ao Documento de Carga está Liberado, portanto, não poderá ser cancelado.", 1, 0,)//
					lRet := .F.
				ElseIf GWN->GWN_SIT == "4" .And. oModel:GetValue('GFEA044_GW1', 'GW1_SIT') == "7"
					Help(,, 'HELP',, "O Romaneio vinculado ao Documento de Carga está Encerrado, portanto, não poderá ser cancelado.", 1, 0,)//
					lRet := .F.
				ElseIf oModel:GetValue('GFEA044_GW1', 'GW1_SIT') == "7" .And. !GFEA44DELC(.F., .F.)
					Help( ,,'HELP',,"Não Foi possível eliminar os Cálculos vinculados a esse Documento de Carga, portanto, não será efetuado o cancelamento.", 1, 0,) //""
					lRet := .F.
				Else
					If GWN->GWN_CALC != "2"
						RecLock("GWN", .F.)
						GWN->GWN_CALC := "4" // Romaneio necessita recálculo
						If oModel:GetValue('GFEA044_GW1', 'GW1_SIT') == "7"
							GWN->GWN_MTCALC := "Um Documento de Carga relacionado ao Romaneio foi cancelado via integração."
						Else
							GWN->GWN_MTCALC := "Um Documento de Carga relacionado ao Romaneio foi alterado."
						EndIf
						GWN->GWN_DTCALC := CToD("  /  /    ")
						GWN->GWN_HRCALC := ""
						GWN->( MsUnlock() )
					EndIf

					aAreaGWN := GWN->(GetArea())
					If !Empty(GWN->GWN_VIAGEM) 
						GFE58ATVG(GWN->GWN_VIAGEM,'4',GWN->GWN_MTCALC,CToD("  /  /    "),"",GWN->GWN_FILIAL,GWN->GWN_NRROM,.T.)
					EndIf
				EndIf
			EndIf
		EndIf
	EndIf

	If lRet .And. (nOpc == MODEL_OPERATION_UPDATE .OR. nOpc == MODEL_OPERATION_INSERT)
		If SuperGetMv("MV_TIPREG",.F.,"2") == "2"
			cCidade := oModel:GetValue('GFEA044_GW1','GW1_ENTNRC') 
			If Empty(cCidade)
				cCidade := Posicione("GU3", 1, xFilial("GU3") + M->GW1_CDDEST, "GU3_NRCID")
			EndIf

			cUF := oModel:GetValue('GFEA044_GW1','GW1_ENTUF') 
			If Empty(cUF)
				cUF := Posicione("GU7", 1, xFilial("GU7") + cCidade, "GU7_CDUF")
			EndIf

			cCEP := oModel:GetValue('GFEA044_GW1','GW1_ENTCEP') 
			If Empty(cCEP)
				cCEP := Posicione("GU3", 1, xFilial("GU3") + M->GW1_CDDEST, "GU3_CEP")
			EndIf

			cRegiao := SetRegGW1(cCidade,cUF,cCEP)
		EndIf

		If AScan(oStructGW1:aFields,{|x| x[3] == "GW1_NRREG"}) != 0
			oModel:LoadValue('GFEA044_GW1', 'GW1_NRREG', cRegiao)
		EndIf

		If GFXCP12117("GWU_NRCIDO")
			If lRet //Atribuição cidade de origem
				nFirstLine := 0
				For nI := 1 To oModelGWU:Length()
					If !oModelGWU:IsDeleted(nI)
						If nFirstLine == 0
							nFirstLine := nI
						EndIf

						If Empty(oModelGWU:GetValue("GWU_NRCIDO",nI))
							If oModelGWU:GetValue("GWU_SEQ",nI) == StrZero(1,Len(GWU->GWU_SEQ)) .Or. nI == nFirstLine //Primeiro trecho não excluído 
								oModelGWU:GoLine(nI)
								oModelGWU:LoadValue("GWU_NRCIDO",Posicione("GU3",1,xFilial("GU3") + FwFldGet("GW1_CDREM"),"GU3_NRCID"))
							Else
								For nY := nI To 2 Step -1 //Procura o primeiro trechos acima do corrente que não esteja deletado
									If !oModelGWU:IsDeleted(nY-1)
										oModelGWU:GoLine(nI)
										oModelGWU:LoadValue("GWU_NRCIDO",oModelGWU:GetValue("GWU_NRCIDD",nY-1))
										Exit
									EndIf
								Next nY
							EndIf
						EndIf
					EndIf
				Next nI
			EndIf
		EndIf
	EndIf

	FWRestRows( aSaveLines )
Return lRet


/*/{Protheus.doc} GFEA044CMT(oModel)

Realiza a gravação fisica do documento de carga e realiza o cálculo automático, se necessário

@author Siegklenes.Beulke
@since 03/08/2013
@version 1.0
/*/
Static Function GFEA044CMT(oModel)
	Local cEspecie
	Local cSerie
	Local aRetCalc 	 := {}
	Local nOpc 	 	 := oModel:GetOperation()
	Local lChavUnic  := TamSx3("GW1_SERDC")[1] == 14

	Private nQtdTrch  := 0
	Private nRecNew   := 0
	Private nRecCount := 0

	// Verifica se houve alteração na quantidade de trechos
	/*cAliasGWU := GetNextAlias()
	
	cQuery := "SELECT GWU_SEQ, GWU_CDTRP, GWU_DTENT"
	cQuery += " FROM "+RetSqlName("GWU") + " GWU"
	cQuery += " WHERE GWU.GWU_FILIAL = ?"
	cQuery += " AND GWU.GWU_CDTPDC = ?"
	cQuery += " AND GWU.GWU_EMISDC = ?"
	cQuery += " AND GWU.GWU_SERDC = ?"
	cQuery += " AND GWU.GWU_NRDC = ?"
	cQuery += "	AND GWU.D_E_L_E_T_ = ''"

	cQuery := ChangeQuery(cQuery)
	oQry := FWExecStatement():New(cQuery)

	oQry:SetString(1, cGW1FILIAL)
	oQry:SetString(2, cGW1CDTPDC)
	oQry:SetString(3, cGW1EMISDC)
	oQry:SetString(4, cGW1SERDC)
	oQry:SetString(5, cGW1NRDC)

	cAliasGWU := oQry:OpenAlias()

	If (cAliasGWU)->(!EoF())
		Count To nRecCount		// Quantidade de trechos antes do commit
	EndIf
	(cAliasGWU)->(dbCloseArea())*/


	lRet:= FwFormCommit(oModel)

	//Tratamento nova série documento de carga
	If nOpc != MODEL_OPERATION_DELETE .And. lChavUnic .And. !Empty(cSerieGFE)
		cSerie := Left(cSerieGFE, 3)
		cEspecie := SubStr(cSerieGFE,10)

		//Série de relacionamento
		GrvSerId("GWU",,"GWU_FILIAL+GWU_CDTPDC+GWU_EMISDC+GWU_SERDC+GWU_NRDC","GWU_SERDC","GW1",,,GW1->GW1_DTEMIS,cSerie,cEspecie)
		GrvSerId("GWB",2,"GWB_FILIAL+GWB_CDTPDC+GWB_EMISDC+GWB_SERDC+GWB_NRDC","GWB_SERDC","GW1",,,GW1->GW1_DTEMIS,cSerie,cEspecie)
		GrvSerId("GW8",,"GW8_FILIAL+GW8_CDTPDC+GW8_EMISDC+GW8_SERDC+GW8_NRDC","GW8_SERDC","GW1",,,GW1->GW1_DTEMIS,cSerie,cEspecie)

		GW8->(dbSkip(-1))
		If GFXTB12117("GXP") == .T.
			GXP->(dbSetOrder(1))
			If GXP->(dbSeek(GW1->(GW1_FILIAL+GW1_CDTPDC+GW1_EMISDC+GW1_SERDC+GW1_NRDC))) // Atualização chave única
				While GXP->(!Eof()) .And. GW1->(GW1_FILIAL+GW1_CDTPDC+GW1_EMISDC+GW1_SERDC+GW1_NRDC) == GXP->(GXP_FILIAL+GXP_CDTPDC+GXP_EMISDC+GXP_SERDC+GXP_NRDC)
					RecLock("GXP",.F.)
					If GFXCP12117("GXP_SERDC") == .T. 
						GXP->GXP_SERDC := GW8->GW8_SERDC
					EndIf
					If GFXCP12117("GXP_SDOC") == .T.
						GXP->GXP_SDOC  := GW8->GW8_SDOCDC
					EndIf
					GXP->(MsUnlock())

					GXP->(dbSkip())
				EndDo
			EndIf
		EndIf

		RecLock("GW1",.F.)

		// Campo série
		SerieNfId("GW1",1,"GW1_SERDC",GW1->GW1_DTEMIS,cEspecie,cSerie)

		// Campo série de origem
		cSerie   := Left(GW1->GW1_ORISER, 3)
		cEspecie := SubStr(GW1->GW1_ORISER,10)

		SerieNfId("GW1",1,"GW1_ORISER",GW1->GW1_DTEMIS,cEspecie,cSerie)
		GW1->(MsUnlock())
	EndIf

	If oModel:getOperation() != MODEL_OPERATION_DELETE
		dbSelectArea("GWU")
		dbSetOrder(1)
		If dbSeek(GW1->GW1_FILIAL + GW1->GW1_CDTPDC + GW1->GW1_EMISDC + GW1->GW1_SERDC + GW1->GW1_NRDC) .And. !Empty(GWU->GWU_CDTRP)			
			aRetCalc := GFECalcAut()

			// Realiza a inserção da data e hora da liberação do documento
			If aRetCalc[1] == .T.
				RecLock("GW1",.F.)
				GW1->GW1_DTLIB := DATE()
				GW1->GW1_HRLIB := SubStr(Time(), 1, 5)
				GW1->(MsUnlock())
			EndIf	

			//Data de entrada automática
			GFE44DtAut()
		EndIf
	EndIf

	// Gravação de dados para relatorio de Movimentação de Carga
	/*If lRet .And. GFXTB1212210("GX0")
    	LoadMovtoGW1(oModel)
	EndIf*/

	cSerieGFE := ""
Return .T.

//-------------------------------------------------------------------
/*/{Protheus.doc} GFEA44IRO

Cria o vinculo entre o Documento de Carga e um Romaneio

@author Jorge Matos Valcanaia
@since 10/11/09
@version 1.0
/*/
//-------------------------------------------------------------------
Function GFEA44IRO()
	Local oDlg
	Local nAlt    := (GetScreenRes()[2])
	Local nLrg    := (GetScreenRes()[1]-100)
	Local cDSTPDC

	//Trata a altura da janela de acordo com a resolução
	If nAlt > 1000
		nAlt -= (nAlt - 900) * 80/100
	ElseIf nAlt < 900
		nAlt += (900 - nAlt) * 90/100
	EndIf

	If !(Empty(GW1->GW1_NRROM) .Or. AllTrim(GW1->GW1_NRROM) == "0")
		msgInfo(STR0059,STR0060) //"Já existe um Romaneio Vinculado a este Documento de carga"###"Aviso"
		Return .F.
	EndIf

	If GW1->GW1_SIT <> "3"
		msgInfo(STR0061,STR0060) //"Somente pode-se ser vinculado um Romaneio com Documento de Carga que tenha Situação como Liberado"###"Aviso"
		Return .F.
	EndIf

	dbSelectArea("GWU")
	dbSetOrder(1)
	If dbSeek(GW1->GW1_FILIAL + GW1->GW1_CDTPDC + GW1->GW1_EMISDC + GW1->GW1_SERDC + GW1->GW1_NRDC)
		If (Empty(GWU->GWU_CDTRP))
			msgInfo("É necessário informar o transportador no trecho do Documento de Carga.", STR0060) // "Aviso"
			Return .F.
		EndIf
	Else
		msgInfo("O Documento de Carga não possui trecho", STR0060) // "Aviso"
		Return .F.
	EndIf

	dbSelectArea("GW4")
	GW4->( dbSetOrder(02) )
	If GW4->( dbSeek(GW1->GW1_FILIAL+GW1->GW1_EMISDC+GW1->GW1_SERDC+GW1->GW1_NRDC+GW1->GW1_CDTPDC) )
		MsgInfo("Não é possível vincular um Documento de Carga a um Romaneio se o mesmo já está vinculado a um Documento de Frete")
		Return .F.
	EndIf


	aNewButton := {}
	Aadd(aNewButton,{"novacelula" ,{||GFEA44BRN()},STR0062,STR0062}) //"Novo Romaneio"###"Novo Romaneio"

	Private cCadastro := STR0030 //"Romaneio"
	Private cMarca := GetMark()

	//----------------------------------------------
	// Criacao da tabela temporaria p/ Markbrowse
	//----------------------------------------------
	aMKB :=    {{"OK"       ,"C",02,0},;  
				{"ROMANEIO" ,"C",TamSx3("GWN_NRROM")[1],0},;  
				{"DTCRIACAO","D",TamSx3("GWN_DTIMPL")[1],0},;  
				{"HORA"     ,"C",TamSx3("GWN_HRIMPL")[1],0},;  
				{"TPOPER"   ,"C",TamSx3("GWN_CDTPOP")[1],0},;  
				{"CLSFRETE" ,"C",TamSx3("GWN_CDCLFR")[1],0},;  
				{"TPVEI"    ,"C",TamSx3("GWN_CDTPVC")[1],0}}   

	aCpMKB  := {{"OK"        ,NIL,"",""},;
				{"ROMANEIO"  ,NIL,STR0030,"@!"},; 	// "Romaneio"
				{"DTCRIACAO" ,NIL,STR0063,""},; 	// "Data de Criação"
				{"HORA"      ,NIL,STR0064,"@R"},; 	// "Hora"
				{"TPOPER"    ,NIL,STR0085,""},; 	// "Tipo de Operação"
				{"CLSFRETE"  ,NIL,STR0086,""},; 	// "Class. Frete"
				{"TPVEI"     ,NIL,STR0065,"@!"}} 	// "Tipo de Veículo"

	cAliMKB := GFECriaTab({aMKB,{"ROMANEIO"}})

	CursorWait()

	//--------------------------
	// Montagem da tela
	//--------------------------
	Define MsDialog oDlg Title cCadastro From 500,120 To nAlt,nLrg Of oMainWnd Pixel
	oDlg:lEscClose := .F.

	oPnlA := tPanel():New(00,00,,oDlg,,,,,,30,35,.F.,.F.)
	oPnlA:Align := CONTROL_ALIGN_TOP

	oPnlB := tPanel():New(00,00,,oDlg,,,,,,30,40,.F.,.F.)
	oPnlB:Align := CONTROL_ALIGN_ALLCLIENT

	cDSTPDC := posicione("GV5",1,xFilial("GV5")+GW1->GW1_CDTPDC,"GV5_DSTPDC")

	@ 07,10  Say STR0067 Of oPnlA Pixel //"Documento de Carga: "
	@ 05,63  MSGET GW1->GW1_NRDC   Picture "@!" Of oPnlA When .F. Pixel

	@ 07,162 Say STR0068 Of oPnlA Pixel //"Série: "
	@ 05,177 MSGET GW1->GW1_SERDC  Picture "!!!" Of oPnlA When .F. Pixel

	@ 21,15  Say STR0069 Of oPnlA Pixel //"Tipo de Documento: "
	@ 19,63  MSGET cDSTPDC         Picture "@!" Of oPnlA When .F. Pixel
	dbSelectArea(cAliMKB)
	dbSetOrder(01)
	dbGoTop()

	oMark := MsSelect():New(cAliMKB,"OK",,aCpMKB,,@cMarca,{0,0,0,0},,,oPnlB)
	oMark:oBrowse:bLDblClick := { || GFEA44CHK() }
	oMark:oBrowse:cToolTip := STR0070 //"Visualização"
	oMark:oBrowse:Align := CONTROL_ALIGN_ALLCLIENT

	Processa({|lEnd| GFEA44CRG()},STR0071,STR0072) //"Processando informações"###"Aguarde"

	CursorArrow()

	ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar(ODlg,{||If(GFEA44OK(),ODlg:End(),NIL)},;
		{||If(APMSGYESNO(STR0073),ODlg:End(),)},,aNewButton) CENTERED  //"Deseja cancelar esse processo?"

	GFEDelTab(cAliMKB)
Return

//-------------------------------------------------------------------
/*/{Protheus.doc} GFEA44CRG

Acrescenta os registros na tabela temporaria para que eles sejam
exibidos na tela do romaneio

@author Jorge Matos Valcanaia
@since 10/11/09
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function GFEA44CRG(cRom)
	Local nRecno
	Local cQuery    := ''
	Local cAliasQry := GetNextAlias()
	Local cSentido  := Posicione('GV5',1,xFilial('GV5')+GW1->GW1_CDTPDC,'GV5_SENTID')
	Local oQry

	Default cRom := ''

	DbSelectArea(cAliMKB)
	ZAP

	cQuery := "SELECT GWN.GWN_NRROM, GWN.GWN_DTIMPL, GWN.GWN_HRIMPL, GWN.GWN_CDTPVC, GV4.GV4_DSTPOP,"
	cQuery +=       " CASE WHEN GUB.GUB_DSCLFR IS NULL THEN ' ' ELSE GUB.GUB_DSCLFR END GUB_DSCLFR"
	cQuery += " FROM "+RetSqlName('GWN')+" GWN"
	cQuery +=   " INNER JOIN "+RetSqlName('GV4')+" GV4"
	cQuery +=      " ON GWN.GWN_CDTPOP  = GV4.GV4_CDTPOP"
	cQuery +=    " AND GV4.GV4_FILIAL   = '"+xFilial('GV4')+"'"
	cQuery +=    " AND ( GV4.GV4_SENTID = '0' OR GV4.GV4_SENTID = ? )"
	cQuery +=    " AND GV4.D_E_L_E_T_   = ' '"
	cQuery +=   " LEFT JOIN "+RetSqlName('GUB')+" GUB"
	cQuery +=      " ON GWN.GWN_CDCLFR = GUB_CDCLFR"
	cQuery +=    " AND GUB.D_E_L_E_T_  = ' '"
	cQuery += " WHERE GWN.GWN_FILIAL = '"+xFilial('GWN')+"'"
	cQuery +=   " AND GWN.GWN_SIT    = '1'" //Situação digitado
	cQuery +=   " AND GWN.GWN_ORI   <> '2'" //Origem diferente de ERP
	cQuery +=   " AND GWN.D_E_L_E_T_ = ' '"
	cQuery +=   " AND GWN.GWN_CDTRP  = ( SELECT GWUA.GWU_CDTRP"
	cQuery +=                           " FROM "+RetSqlName('GWU')+" GWUA"
	cQuery +=                           " WHERE GWUA.GWU_FILIAL  = '"+ xFilial('GWU')+ "'"
	cQuery +=                               " AND GWUA.GWU_CDTPDC = ?"
	cQuery +=                               " AND GWUA.GWU_EMISDC = ?"
	cQuery +=                               " AND GWUA.GWU_SERDC  = ?"
	cQuery +=                               " AND GWUA.GWU_NRDC   = ?"
	cQuery +=                               " AND GWUA.D_E_L_E_T_ = ' '"
	cQuery +=                               " AND GWUA.GWU_SEQ = ( SELECT MIN(GWUB.GWU_SEQ)"
	cQuery +=                                                    " FROM "+RetSqlName('GWU')+" GWUB"
	cQuery +=                                                    " WHERE GWUB.GWU_FILIAL = '"+ xFilial('GWU')+ "'"
	cQuery +=                                                      " AND GWUB.GWU_CDTPDC   = ?"
	cQuery +=                                                      " AND GWUB.GWU_EMISDC   = ?"
	cQuery +=                                                      " AND GWUB.GWU_SERDC    = ?"
	cQuery +=                                                      " AND GWUB.GWU_NRDC     = ?"
	cQuery +=                                                      " AND GWUB.D_E_L_E_T_ = ' '))"
	cQuery += " ORDER BY GWN.GWN_NRROM"

	cQuery := ChangeQuery(cQuery)
	oQry := FWExecStatement():New(cQuery)

	oQry:SetString(1, cSentido)
	oQry:SetString(2, GW1->GW1_CDTPDC)
	oQry:SetString(3, GW1->GW1_EMISDC)
	oQry:SetString(4, GW1->GW1_SERDC)
	oQry:SetString(5, GW1->GW1_NRDC)
	oQry:SetString(6, GW1->GW1_CDTPDC)
	oQry:SetString(7, GW1->GW1_EMISDC)
	oQry:SetString(8, GW1->GW1_SERDC)
	oQry:SetString(9, GW1->GW1_NRDC)

	cAliasQry := oQry:OpenAlias()

	While (cAliasQry)->(!Eof())

		RecLock((cAliMKB),.T.)
		(cAliMKB)->ROMANEIO  := (cAliasQry)->GWN_NRROM
		(cAliMKB)->TPOPER    := (cAliasQry)->GV4_DSTPOP
		(cAliMKB)->CLSFRETE  := (cAliasQry)->GUB_DSCLFR
		(cAliMKB)->TPVEI     := (cAliasQry)->GWN_CDTPVC
		(cAliMKB)->HORA      := (cAliasQry)->GWN_HRIMPL
		(cAliMKB)->DTCRIACAO := StoD((cAliasQry)->GWN_DTIMPL)
		If cRom == (cAliasQry)->GWN_NRROM
			(cAliMKB)->OK    := cMarca
		EndIf
		(cAliMKB)->(MsUnlock())

		If cRom == (cAliasQry)->GWN_NRROM
			nRecno := (cAliMKB)->(RecNo())
		EndIf

		(cAliasQry)->(DbSkip())
	EndDo

	(cAliasQry)->(DbCloseArea())

	If !Empty(nRecno)
		(cAliMKB)->(DbGoTo(nRecno))
	Else
		(cAliMKB)->(DbGoTop())
	EndIf

	oMark:oBrowse:Refresh()

Return .T.

//-------------------------------------------------------------------
/*/{Protheus.doc} GFEA44NVR

Cria um novo romaneio

@author Jorge Matos Valcanaia
@since 10/11/09
@version 1.0

@return
[01] .T./.F. Criou novo romaneio
[02] Numero do romaneio criado
[03] Array de  erros, se [01] == .F.
/*/
//-------------------------------------------------------------------
Function GFEA44NVR(cBloqPf)
	Local cNewCod
	Local oDlg
	Local oSay
	Local oCbx
	Local oQry
	Local cCbxSel
	Local oBtn
	Local nCont
	Local cAlias
	Local oContratoRomaneio
	Local cTpOper 	 			:= ""
	Local lCalcAuto  			:= .F.
	Local lRet 	 	 			:= .T.
	Local aTpOp 	 			:= {}
	Local aNeg       			:= {}
	Local aErrosCalc 			:= {}
	Local cNrCt      			:= ""
	Local cQuery 	 			:= ""
	Local cMtNrErp   			:= GetNewPar("MV_MTNRERP", "2")
	Local cMVAGRORI	 			:= SuperGetMV("MV_AGRORI",.F.,.F.)
	Local cMVSIGAAGR 			:= SuperGetMV("MV_SIGAAGR",.F.,.F.)
	Local cAliasGXS	 			:= GetNextAlias()
	Local lPE443	 			:= ExistBlock("GFEA0443")
	Local cCodTrp    			:= Posicione("GWU", 1, xFilial("GWU") + GW1->GW1_CDTPDC + GW1->GW1_EMISDC + GW1->GW1_SERDC + GW1->GW1_NRDC, "GWU_CDTRP")
	Local cMVCDTPOP				:= SuperGetMV("MV_CDTPOP",,'')

	Private p_ERPInt := SuperGetMV("MV_ERPGFE",,'') //Verifica qual o ERP da integração. 
	Private p_TpOper := SuperGetMV("MV_TPOPEMB",,'') //Busca o Tipo de Operação Padrão. 
	
	Default cBloqPf := "2"

	If cMtNrErp = "1" .And. !Empty(GW1->GW1_CARREG) .And. Posicione("GV5",1,xFilial("GV5")+GW1->GW1_CDTPDC,"GV5_SENTID") == "2"
		cNewCod := GW1->GW1_CARREG
		
		// Verifica se ja existe romaneio com essa numeração, Se existir faz amarração do DC com esse existente
		If ChkExistRom(cNewCod, cCodTrp)
			cNewCod := GFE50NRROM()
		EndIf
	Else 
		cNewCod := GFE50NRROM()
	EndIf

	//Verifica se o Romaneio será gerado para um cálculo automático 
	If  GFEVerCmpo( {"GV5_CALC","GW1_CALCAT"}) .And. (GW1->GW1_CALCAT == "1" .Or. Empty(GW1->GW1_CALCAT)) .And. Posicione("GV5",1,xFilial("GV5")+GW1->GW1_CDTPDC,"GV5_CALC") == "2"
		lCalcAuto := .T.
	EndIf

	If GFXCP12123("GXR_PEDCOM") .and. GFXFU12123("AXCTRFRT") .And. cMVAGRORI .And. cMVSIGAAGR
		cQuery := "SELECT GXS.GXS_NRCT"
		cQuery += " FROM "+ RetSqlName( "GXS" ) +" GXS"
		cQuery += " INNER JOIN " +  RetSqlName( "GXR" ) + " GXR"
		cQuery += " ON GXS.GXS_FILIAL = GXR.GXR_FILIAL"
		cQuery += " AND GXS.GXS_IDREQ = GXS.GXS_IDREQ"
		cQuery += " WHERE GXR.GXR_TPIDEN = '2'"
		cQuery += " AND GXR.GXR_PEDCOM = ?"
		cQuery += " AND GXR.GXR_FDADE = '2' "
		cQuery += " AND GXS.GXS_MRKBR = 'T'"
		cQuery += " AND GXS.GXS_NRCT != ''"
		cQuery += " AND GXR.D_E_L_E_T_ = ''"
		cQuery += " AND GXS.D_E_L_E_T_ = ''"

		cQuery := ChangeQuery(cQuery)
		oQry := FWExecStatement():New(cQuery)

		oQry:SetString( 1 , "GW1->GW1_PEDCLI" )

		cAliasGXS := oQry:OpenAlias()

		If !((cAliasGXS)->(EoF()))
			cNrCt := (cAliasGXS)->GXS_NRCT
		EndIf

		If Empty(cNrCt)
			oContratoRomaneio := GFEContratoRomaneio():New()

			oContratoRomaneio:setFilNF(GW1->GW1_FILIAL)
			oContratoRomaneio:setNumNF(GW1->GW1_NRDC)	
			oContratoRomaneio:setSerNF(GW1->GW1_SERDC)

			oContratoRomaneio:BuscaContrato()

			cNrCt := oContratoRomaneio:getNrCt()

			oContratoRomaneio:ClearData()

			oContratoRomaneio:Destroy(oContratoRomaneio)		
		EndIf
	EndIf

	RecLock("GWN",.T.)
	GWN->GWN_FILIAL := xFilial("GWN")
	GWN->GWN_NRROM  := cNewCod
	GWN->GWN_CDTPVC := posicione("GWU",1,xFilial("GWU")+GW1->GW1_CDTPDC+GW1->GW1_EMISDC+GW1->GW1_SERDC+GW1->GW1_NRDC,"GWU_CDTPVC")
	GWN->GWN_CDTRP  := posicione("GWU",1,xFilial("GWU")+GW1->GW1_CDTPDC+GW1->GW1_EMISDC+GW1->GW1_SERDC+GW1->GW1_NRDC,"GWU_CDTRP")
	GWN->GWN_DTIMPL := DATE()
	GWN->GWN_HRIMPL := SubStr(TIME(), 1, 5)
	GWN->GWN_CALC   := "2"
	GWN->GWN_ORI    := "4"
	GWN->GWN_SIT    := "1"
	GWN->GWN_USUIMP := cUserName
	GWN->GWN_BLOQPF := cBloqPf
	If GFXCP12117("GWN_NRCT")	
		GWN->GWN_NRCT 	:= cNrCt
	EndIf
	GWN->(MsUnlock())

	If lPE443
		ExecBlock("GFEA0443",.F.,.F.,{GWN->GWN_FILIAL,GWN->GWN_NRROM,GW1->GW1_CDTPDC,GW1->GW1_EMISDC,GW1->GW1_SERDC,GW1->GW1_NRDC})
	EndIf

	//Processo para selecionar o tipo de operação do romaneio
	cAlias := GetNextAlias()

	cQuery := " SELECT DISTINCT GV9_FILIAL, GV9_SIT, GV9_CDTPOP, GV9_CDEMIT, GV9_NRTAB, GV9_NRNEG, GV9_DTVALI, GV9_DTVALF "
	cQuery += " FROM " + RetSQLName("GV9") + " GV9 "
	cQuery += " INNER JOIN " + RetSQLName("GV4") + " GV4 ON GV4.GV4_FILIAL = '"+ xFilial("GV4") + "'"
	cQuery += " AND GV4.GV4_CDTPOP = GV9.GV9_CDTPOP"
	cQuery += " WHERE GV9_FILIAL = '"+ xFilial("GV9") + "' AND GV9_CDEMIT = ?"
	cQuery += " AND (GV9_DTVALF = '' OR GV9_DTVALF >= ?)"
	cQuery += " AND GV9_SIT = '2' AND GV4.GV4_SIT = '1'"
	cQuery += " AND GV9_DTVALI <= ? AND GV9.D_E_L_E_T_ = ' ' AND GV4.D_E_L_E_T_ = ' '"
	cQuery += " ORDER BY GV9_CDEMIT, GV9_DTVALI DESC "

	cQuery := ChangeQuery(cQuery)
	oQry := FWExecStatement():New(cQuery)

	oQry:SetString(1 ,  "GWN->GWN_CDTRP" )
	oQry:SetString(2 ,  "DToS(DDATABASE)" )
	oQry:SetString(3 ,  "DToS(DDATABASE)" )

	cAlias := oQry:OpenAlias()

	(cAlias)->( dbGoTop() )
	While !(cAlias)->( Eof() )
		If aScan(aNeg, {|x| x == (cAlias)->GV9_NRTAB}) == 0 .And. aScan(aTpOp, {|x| x == (cAlias)->GV9_CDTPOP}) == 0 .And. ;
			Posicione("GV5",1,xFilial('GV5')+GW1->GW1_CDTPDC,"GV5_SENTID") == Posicione("GV4",1,xFilial('GV4')+(cAlias)->GV9_CDTPOP,"GV4_SENTID")

			AAdd(aTpOp, (cAlias)->GV9_CDTPOP)
			AAdd(aNeg, (cAlias)->GV9_NRTAB)
		EndIf

		(cAlias)->( dbSkip() )
	EndDo

	If Len(aTpOp) > 1 .And. lCalcAuto == .F. //Não exibe tela de seleção de tipo de operação se for calculo automatico
		For nCont := 1 To Len(aTpOp)
			aTpOp[nCont] := AllTrim(aTpOp[nCont])+"="+Posicione("GV4",1,xFilial("GV4")+aTpOp[nCont],"GV4_DSTPOP")
		Next nCont

		oDlg := MSDialog():New(10, 10, 125, 250, STR0087,,,,,CLR_BLACK,CLR_WHITE,,,.T.) //"Tipo de Operação"

		oSay:= tSay():New(10,10,{|| STR0089},oDlg,,,,; //"Selecione o Tipo de Operação para o novo Romaneio:"
			,,.T.,CLR_BLACK,CLR_WHITE,100,20)

		oCbx := tComboBox():New(28,10,{|u| If(PCount()>0,cCbxSel:=u,cCbxSel)},aTpOp,100,20,oDlg,,{|| },,,,.T.,,,,,,,,,'cCbxSel')

		oBtn := tButton():New(43,40,STR0088,oDlg,{||cTpOper:=cCbxSel,oDlg:End()},40,10,,,,.T.) //"Selecionar"

		oDlg:Activate()

	ElseIf Len(aTpOp) > 1 .And. lCalcAuto == .T.
		If p_ERPInt == '1' .And. GW1->GW1_ORIGEM == '2' // caso tiver mais de uma opção, for automático e tiver ingetração com ERP Datasul, pega Tipo de Operação Padrão 
			cTpOper := p_TpOper
		Else
			cTpOper := aTpOp[1] // caso tiver mais de uma opção e for automático, pega a primeira operação
		EndIf

	ElseIf Len(aTpOp) == 1
		cTpOper := aTpOp[1]
	Else
		If p_ERPInt == '1' .And. GW1->GW1_ORIGEM == '2'
			cTpOper := p_TpOper
		ElseIf p_ERPInt == '2' .And. GW1->GW1_ORIGEM == '2'
			cTpOper	:= cMVCDTPOP
		Else
			GV4->(dbSetOrder(01))
			GV4->(dbSeek(xFilial('GV4')))
			While GV4->(!Eof()) .AND. xFilial('GV4') == GV4->GV4_FILIAL .And. Empty(cTpOper)
				If (Posicione("GV5",1,xFilial('GV5')+GW1->GW1_CDTPDC,"GV5_SENTID") == GV4->GV4_SENTID .And. GV4->GV4_SIT == "1") .Or. (GV4->GV4_SENTID == "0" .And. GV4->GV4_SIT == "1")
					cTpOper := GV4->GV4_CDTPOP
				EndIf	
				GV4->(dbSkip())
			EndDo
		EndIf
	EndIf

	If	GFEVerCmpo( {"GW1_ROMCF","GW1_ROMTV","GW1_ROMTO"})
		RecLock("GWN", .F.)
		If !Empty(GW1->GW1_ROMCF)
			GWN->GWN_CDCLFR := GW1->GW1_ROMCF
		EndIf

		If !Empty(GW1->GW1_ROMTV)
			GWN->GWN_CDTPVC := GW1->GW1_ROMTV
		EndIf

		If !Empty(GW1->GW1_ROMTO)
			cTpOper := GW1->GW1_ROMTO
		EndIf
		GWN->(MsUnlock())		
	EndIf

	If Empty(cTpOper)
		If GFXFU12123("RollBackSXE")
			RollBackSXE()
		EndIf

		RecLock("GWN", .F.)
		dbDelete()
		GWN->(MsUnlock())

		aAdd(aErrosCalc,"Não foi encontrado Tipo de Operação válido, o Romaneio não será criado.")	
	Else
		RecLock("GWN", .F.)
		GWN->GWN_CDTPOP	:= PadR(AllTrim(cTpOper),10)
		GWN->(MsUnlock())

		ConfirmSX8()
	EndIf

	If Len(aErrosCalc)>0
		lRet:= .F.
		cNewCod := ""
	EndIf 

	(cAlias)->(dbCloseArea())

Return {lRet,cNewCod,aErrosCalc}

//-------------------------------------------------------------------
/*/{Protheus.doc} GFEA44BRN

Cria novo Romaneio e atualiza resultado em tela

@author Siegklenes.Beulke
@since 16/08/2013
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function GFEA44BRN()
	/*
	[01] .T./.F. Criou novo romaneio
	[02] Numero do romaneio criado
	[03] Array de  erros, se [01] == .F.
	*/
	Local aRetNVR
	Local nCont := 1
	Local cMsgErr := ""

	GV5->(dbSetOrder(1))
	GV5->(dbSeek(xFilial("GV5") + GW1->GW1_CDTPDC))
	aRetNVR := GFEA44NVR(If( (GV5->GV5_EMITPF == "1" .Or. Empty(GV5->GV5_EMITPF)), "2", "1"))

	If aRetNVR[1] == .F.
		For nCont := 1 To Len(aRetNVR[3])
			cMsgErr +=  aRetNVR[3][nCont] + CRLF 
		Next
		MsgInfo(cMsgErr,STR0075)// "Criação de Romaneio"
	Else
		MsgInfo(STR0074 + aRetNVR[2],STR0075) //"Foi criado o Romaneio de número: "###" Criação de Romaneio"
		Processa({|lEnd| GFEA44CRG( aRetNVR[2])},STR0071,STR0072) //"Processando informações"###"Aguarde"
		oMark:oBrowse:Refresh()
	EndIf

Return 


//-------------------------------------------------------------------
/*/{Protheus.doc} GFEA44CHK

Verifica se já existe um registro marcado

@author Jorge Matos Valcanaia
@since 10/11/09
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function GFEA44CHK()
	Local lMArk := .T.
	Local nREc  := (cAliMKB)->(RecNo())

	If (cAliMKB)->(BOF()) .And. (cAliMKB)->(EOF())
		Return
	EndIf

	(cAliMKB)->(dbSetOrder(01))
	If !IsMark('OK',cMarca)
		(cAliMKB)->(dbGoTop())
		While !Eof()
			If IsMark('OK',cMarca)
				msgInfo(STR0076,STR0060) //"Já existe um registro selecionado"###"Aviso"
				lMark := .F.
				Exit
			EndIf
			(cAliMKB)->(dbSkip())
		EndDo
	EndIf

	(cAliMKB)->(dbGoTo(nRec))
	If lMArk
		RecLock(cAliMKB,.F.)
		(cAliMKB)->OK := If(IsMark('OK',cMarca),"  ",cMarca)
		(cAliMKB)->(MsUnLock())
	EndIf

	oMark:oBrowse:Refresh()
Return

//-------------------------------------------------------------------
/*/{Protheus.doc} GFEA44OK

Salva o numero do romaneio selecionado no documento de carga corrente

@author Jorge Matos Valcanaia
@since 10/11/09
@version 1.0
/*/
//-------------------------------------------------------------------
Function GFEA44OK()
	Local cNrrom
	Local cSit
	Local aAreaGW1
	Local cAliasGWU := Nil
	Local cCDCLFR   := Nil
	Local cCDTPOP   := Nil
	Local cFilAux   := Nil
	Local cFilGWN   := Nil
	Local cAliasGX0 := Nil
	Local s_MULFIL	:= SuperGetMV("MV_MULFIL",.F.,"2")

	Local cQuery := ""
	Local oQry

	Private dDataCalc //Variavel necessaria para calculo de frete

	dbSelectArea(cAliMKB)
	(cAliMKB)->( dbSetOrder(1) )
	(cAliMKB)->( dbGoTop() )

	While !(cAliMKB)->( Eof() )
		If IsMark('OK',cMarca)
			cNrrom := (cAliMKB)->ROMANEIO
			cSit   := "4"
		EndIf

		dbSelectArea(cAliMKB)
		(cAliMKB)->( dbSkip() )
	EndDo

	GW1->(dbSetOrder(1))
	RecLock("GW1",.F.)
	GW1->GW1_NRROM := cNrrom
	GW1->GW1_SIT   := cSit
	If GFXCP1212210('GW1_FILROM')
		GW1->GW1_FILROM := GWN->GWN_FILIAL
	EndIF
	GW1->(MsUnlock())

	If s_MULFIL == "1" .And. GFXCP1212210('GW1_FILROM') 
		cFilAux := GW1->GW1_FILROM
	Else
		cFilAux := GW1->GW1_FILIAL
	EndIf

	GWN->(dbSetOrder(1))
	If GWN->(dbSeek(cFilAux + GW1->GW1_NRROM))
		cFilGWN := GWN->GWN_FILIAL
		If !Empty(GWN->GWN_VIAGEM)
			If !GFEA058RVG(GW1->(RecNo()))
				GfeMsgErro("Não é possível vincular documento de carga com frete combinado/simulação com origem erp em romaneio com viagem")
				Return .F.
			EndIf
		EndIf

		//Verificação para quando estiver vinculando um documento de carga que bloqueia pré fatura a um romaneio que não bloqueia pré-fatura.
		If GWN->GWN_BLOQPF == "2"
			dbSelectArea("GV5")
			GV5->(dbSetOrder(1))
			GV5->(dbSeek(xFilial("GV5") + GW1->GW1_CDTPDC))
			If( (GV5->GV5_EMITPF == "2" .Or. Empty(GV5->GV5_EMITPF)))
				MsgInfo("Você está vinculando um Documento de Carga cujo seu tipo bloqueia a emissão de pré-fatura a um Romaneio que não bloqueia a emissão de pré-fatura. Desta forma, o Romaneio será bloqueado para emissão de pré-fatura.")
				RecLock("GWN",.F.)
				GWN->GWN_BLOQPF := "1"
				MsUnlock("GWN")	
			EndIf
		Endif

		GFE50LbRom() // verifica e libera o romaneio vinculado

		/*Quando um novo documento de carga é vinculado ao romaneio calculado através da opção Romaneio,
		este evento gera um questionamento ao usuário solicitando recálculo do romaneio.*/
		If GWN->GWN_CALC != "2"
			RecLock("GWN",.F.)
			GWN->GWN_CALC   := "4"
			GWN->GWN_MTCALC := "Um novo Documento de Carga foi vinculado ao Romaneio."
			GWN->GWN_DTCALC := CToD("  /  /    ")
			GWN->GWN_HRCALC := ""
			MsUnlocK("GWN")

			If !Empty(GWN->GWN_VIAGEM) 
				GFE58ATVG(GWN->GWN_VIAGEM,'4',"Um novo Documento de Carga foi vinculado ao Romaneio " + GWN->GWN_NRROM + ".",CToD("  /  /    "),'',GWN->GWN_FILIAL,GWN->GWN_NRROM,.T.)
			EndIf

			If MsgYesNo(STR0083, STR0084) //"Deseja recalcular este romaneio?"###"Romaneio"
				GFE050CALC()
			EndIf

			aAreaGW1:= GW1->(GetArea())
			GFEA050ALI(xFilial("GW1")+GWN->GWN_NRROM) // Verifica se o cálculo do documento pode ser liberado
			RestArea(aAreaGW1)

		ElseIf !Empty(GWN->GWN_VIAGEM) 
			GFE58ATVG(GWN->GWN_VIAGEM,'4',"Um novo Documento de Carga foi vinculado ao Romaneio " + GWN->GWN_NRROM + ".",CToD("  /  /    "),'',GWN->GWN_FILIAL,GWN->GWN_NRROM,.T.)
		EndIf

		// Gravação de dados para relatorio de Movimentação de Carga
		/*If GFXTB1212210("GX0")
			cCDCLFR := Posicione("GWN", 1, xFilial("GWN")+cNrrom, "GWN_CDCLFR")
			cCDTPOP := Posicione("GWN", 1, xFilial("GWN")+cNrrom, "GWN_CDTPOP")

			oMovDocto := GFEMovtoCarga():New()
			oMovDocto:setBranch(GW1->GW1_FILIAL)
			oMovDocto:setTipoNF(GW1->GW1_CDTPDC)
			oMovDocto:setEmissorNF(GW1->GW1_EMISDC)
			oMovDocto:setSerieNF(GW1->GW1_SERDC)
			oMovDocto:setNumeroNF(GW1->GW1_NRDC)
			oMovDocto:setFilRomaneio(cFilGWN)
			oMovDocto:setNumRomaneio(cNrrom)
			oMovDocto:setClassFrete(cCDCLFR)
			oMovDocto:setDescClassFrete(Posicione("GUB", 1, xFilial("GUB")+cCDCLFR, "GUB_DSCLFR"))
			oMovDocto:setTipoOper(cCDTPOP)
			oMovDocto:setDescTipoOperacao(Posicione("GV4", 1, xFilial("GV4")+cCDTPOP, "GV4_DSTPOP"))

			cAliasGX0 := oMovDocto:SearchByDC()
			If (cAliasGX0)->(!EoF())
				While (cAliasGX0)->(!EoF()) .And. (cAliasGX0)->GX0_FILIAL == GW1->GW1_FILIAL ;
											.And. (cAliasGX0)->GX0_CDTPDC == GW1->GW1_CDTPDC ;
											.And. (cAliasGX0)->GX0_EMISDC == GW1->GW1_EMISDC ;
											.And. (cAliasGX0)->GX0_SERDC == GW1->GW1_SERDC ;
											.And. (cAliasGX0)->GX0_NRDC == GW1->GW1_NRDC
					
					GX0->(dbGoTo( (cAliasGX0)->RECNUM ))
					cAliasGWU := GetNextAlias()

					cQuery := "SELECT GWU_SEQ, GWU_CDTRP, GWU_DTENT"
					cQuery += " FROM " + RetSqlName("GWU") + " GWU"
					cQuery += " WHERE GWU.GWU_FILIAL = ?"
					cQuery += " AND GWU.GWU_CDTPDC = ?"
					cQuery += " AND GWU.GWU_EMISDC = ?"
					cQuery += " AND GWU.GWU_SERDC = ?"
					cQuery += " AND GWU.GWU_NRDC = ?"
					cQuery += "	AND GWU.D_E_L_E_T_ = ''"

					cQuery := ChangeQuery(cQuery)
					oQry := FWExecStatement():New(cQuery)
					
					oQry:SetString(1, GW1->GW1_FILIAL)
					oQry:SetString(2, GW1->GW1_CDTPDC)
					oQry:SetString(3, GW1->GW1_EMISDC)
					oQry:SetString(4, GW1->GW1_SERDC)
					oQry:SetString(5, GW1->GW1_NRDC)

					cAliasGWU := oQry:OpenAlias()

					While (cAliasGWU)->(!EoF())
						oMovDocto:setSeqTrecho((cAliasGWU)->GWU_SEQ)
						oMovDocto:UpdateRomaneio()		// Alteração de numero do Romaneio nos registros da tabela GX0

						(cAliasGWU)->(dbSkip())
					EndDo
					(cAliasGWU)->(dbCloseArea())

					(cAliasGX0)->(dbSkip())
				EndDo
			EndIf
			(cAliasGX0)->(dbCloseArea())

			oMovDocto:Destroy( oMovDocto )
		EndIf*/
	EndIf

Return .T.

//-------------------------------------------------------------------
/* GFE044CLF
Função que retorna a classificação para o Item (GATILHO)
Uso Restrito do Dicionario.

@sample GFE044CLF()

@author Felipe rafael Mendes
@since 14/09/10
@version 1.0
*/
//-------------------------------------------------------------------
Function GFE044CLF()
	Local cRet := ''

	If !Empty(POSICIONE("GUK",1,XFILIAL("GUK")+FwFldGet('GW8_ITEM'),"GUK_CDCLFR"))
		cRet := POSICIONE("GUK",1,XFILIAL("GUK")+FwFldGet('GW8_ITEM'),"GUK_CDCLFR")
	Else
		cRet := GetNewPar('MV_CDCLFR','')
	EndIf

Return cRet

//-------------------------------------------------------------------
/*/{Protheus.doc} GFE044ITEM
Função que retorna a Tipo para o Item (GATILHO)
Uso Restrito do Dicionario.

@sample GFE044ITEM()

@author Felipe rafael Mendes
@since 14/09/10
@version 1.0
/*/
//-------------------------------------------------------------------
Function GFE044ITEM()
	Local cRet := ''

	If !Empty(POSICIONE("GUK",1,XFILIAL("GUK")+FwFldGet('GW8_ITEM'),"GUK_TPITEM"))
		cRet := POSICIONE("GUK",1,XFILIAL("GUK")+FwFldGet('GW8_ITEM'),"GUK_TPITEM")
	EndIf

Return cRet

//-------------------------------------------------------------------
/*/{Protheus.doc} GFE044ITEM
Função que retorna a Descrição para o Item
Uso Restrito do Dicionario.

@sample GFE044DESC()

@author Jorge Matos Valcanaia
@since 11/05/11
@version 1.0
/*/
//-------------------------------------------------------------------
Function GFE044DESC()
	Local lRet    := POSICIONE("GUK",1,XFILIAL("GUK")+FwFldGet('GW8_ITEM'),"GUK_DSITEM")
	Local DescGW8 := FwFldGet("GW8_DSITEM")

	If !Empty(lRet)
		Return lRet
	Else
		Return DescGW8
	Endif

//-------------------------------------------------------------------
/*/{Protheus.doc} GFEA044BLO
Função que verifica se o documento deve ser bloqueado ou rejeitado
Uso Restrito do Dicionario.

@sample GFEA044BLO(cAlias)

@author Felipe rafael Mendes
@since 14/09/10
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function GFEA044BLO(cAlias)
	Local nA
	Local nX 	  := 1
	Local cEval   := ""
	Local aCampos := {}
	Local oModel  := FWModelActive()
	Local cFilGUJ := xFilial("GW1")

	Private oModelGW1 := oModel

	dbSelectArea("GUJ")
	GUJ->( dbSetOrder(2) )

	If GUJ->( dbSeek(Space(FwSizeFilial()) + cAlias) )
		cFilGUJ := Space(FwSizeFilial())
	ElseIf GUJ->( dbSeek(cFilGUJ + cAlias) ) 
		cFilGUJ := xFilial("GW1")
	EndIf

	While !GUJ->( Eof() ) .AND. ;
	GUJ->GUJ_FILIAL == cFilGUJ .AND. ;
	AllTrim(GUJ->GUJ_TABELA) == AllTrim(cAlias) .AND. !lRejeita;

		/* --- CAMPO ------------------------------------------------------------- */
		If AllTrim(Upper(GUJ->GUJ_CAMPO)) != "EXPRESSAO"
			If ValType(FwFldGet(GUJ->GUJ_CAMPO)) == "N"
				If Alltrim(STR( FwFldGet(GUJ->GUJ_CAMPO))) == Alltrim(GUJ->GUJ_VALOR)
					If GUJ_ACAO == '1'
						lRejeita := .T.
						cMotReject := GUJ->GUJ_CAMPO + " igual a " + GUJ->GUJ_VALOR
					ElseIf GUJ_ACAO == '2'
						lBloqueia := .T.
					ElseIf GUJ_ACAO == '3'
						lLibera := .T.
					EndIf
				EndIf

			ElseIf ValType(FwFldGet(GUJ->GUJ_CAMPO)) == "D"
				If Alltrim(DtoS(FwFldGet(GUJ->GUJ_CAMPO))) == Alltrim(DToS(CToD(GUJ->GUJ_VALOR)))
					If GUJ_ACAO == '1'
						lRejeita := .T.
						cMotReject := GUJ->GUJ_CAMPO + " igual a " + GUJ->GUJ_VALOR
					ElseIf GUJ_ACAO == '2'
						lBloqueia := .T.
					ElseIf GUJ_ACAO == '3'
						lLibera := .T.
					EndIf
				EndIf

			ElseIf ValType(FwFldGet(GUJ->GUJ_CAMPO)) == "C"
				If Upper(Alltrim(FwFldGet(GUJ->GUJ_CAMPO))) == Upper(Alltrim(GUJ->GUJ_VALOR))
					If GUJ_ACAO == '1'
						lRejeita := .T.
						cMotReject := GUJ->GUJ_CAMPO + " igual a " + GUJ->GUJ_VALOR
					ElseIf GUJ_ACAO == '2'
						lBloqueia := .T.
					ElseIf GUJ_ACAO == '3'
						lLibera := .T.
					EndIf
				EndIf
			EndIf

		Else
			/* --- EXPRESSÃO --------------------------------------------------------- */
			// Carrega os campos para variavel de memória para poderem ser testados
			If cAlias != "GW1" 
				aCampos:= oModel:GetModel("GFEA044_"+cAlias):GetStruct():GetFields()
				For nX := 1 to Len(aCampos)
					M->&(aCampos[nX][3]):= oModel:GetModel("GFEA044_"+cAlias):GetValue(aCampos[nX][3])
				Next nx
			EndIf

			If cAlias == "GW1"
				/* -- Conversão para GetValue ------------------------------------------------------
				Quando não há interface, os campos com o campo When == .T. ficam sem referência 
				direta (GW1_TPFRET ou M->GW1_TPFRET), sendo necessário buscar os valores 
				diretamente pelo Model.
				GW1_TPFRET => oModelGW1:GetValue('GFEA044_GW1', 'GW1_TPFRET')
				---------------------------------------------------------------------------------
				*/
				cEval := StrTran(GUJ->GUJ_VALOR, cAlias + "_", "oModelGW1:GetValue('GFEA044_" + cAlias + "', '" + cAlias + "_")

				aExp := STRTOKARR(cEval,'.')

				cEval := ""

				For nA := 1 To Len(aExp)
					aExp[nA] := AllTrim(aExp[nA])
					If AT("$", aExp[nA]) != 0
						If SUBSTR(aExp[nA], 1, 1) == "!"
							If AT("AllTrim", aExp[nA]) != 0
								//aExp[nA] := aExp[nA] + ")"
								aExp[nA] := StrTran(aExp[nA], ") $", "')) $ ")
							Else
								If SUBSTR(aExp[nA], -1, 2) != "')"
									aExp[nA] := SUBSTR(aExp[nA], 1, len(aExp[nA]) - 1)
									aExp[nA] := aExp[nA]+ "')"
									aExp[nA] := aExp[nA] + ")"
								EndIf
							EndIf
						Else
							If AT("AllTrim", aExp[nA]) != 0
								//aExp[nA] := aExp[nA] + ")"
								aExp[nA] := StrTran(aExp[nA], ") $", "')) $ ")
							Else
								If SUBSTR(aExp[nA], -1, 2) != "')"
									aExp[nA] := aExp[nA]+ "')"									
								EndIf
							EndIf
						EndIf													
					ElseIf aExp[nA] == "AND"
						aExp[nA] := ".AND."
					ElseIf aExp[nA] == "OR"
						aExp[nA] := ".OR."
					Else					
						aExp[nA] := StrTran(aExp[nA], "==", "') == ")
						aExp[nA] := StrTran(aExp[nA], "!=", "') != ")
						If AT("<", aExp[nA]) != 0 .OR. AT(">", aExp[nA]) != 0
							If AT("<=", aExp[nA]) != 0 
								aExp[nA] := StrTran(aExp[nA], "<=", "') <= ")
							ElseIf AT("<", aExp[nA]) != 0
								aExp[nA] := StrTran(aExp[nA], "<", "') < ")
							EndIf

							If AT(">=", aExp[nA]) != 0
								aExp[nA] := StrTran(aExp[nA], ">=", "') >= ")						
							ElseIf AT(">", aExp[nA]) != 0
								aExp[nA] := StrTran(aExp[nA], ">", "') > ")
							EndIf
						EndIf
					EndIf
					cEval := cEval + aExp[nA] + " "
				Next nA

			Else
				cEval:= AllTrim(StrTran(GUJ->GUJ_VALOR, cAlias + "_", "M->" + cAlias+"_"))
			EndIf

			If &(cEval)
				If GUJ->GUJ_ACAO == '1'
					lRejeita := .T.
					cMotReject := StrTran(StrTran(StrTran(StrTran(GUJ->GUJ_VALOR,"" + DUPLAS," "),".OR.","ou"),".AND.","e"), "==", " igual a ")
				ElseIf GUJ->GUJ_ACAO == '2'
					lBloqueia := .T.
				ElseIf GUJ->GUJ_ACAO == '3'
					lLibera := .T.
				EndIf
			EndIf
		EndIf
		GUJ->( dbSkip() )
	EndDo

Return Nil

//---------------------------------------------

Static Function GF44_GW8ACT(oModel)
	Local nI 		 := 0
	Local nOperation := oModel:GetOperation()
	Local oModelGWU  := oModel:GetModel("GFEA044_GWU")
	Local aFields    := oModelGWU:GetStruct():GetFields()
	Local oModelGW1  := oModel:GetModel("GFEA044_GW1")
	Local aFieldGW1  := oModel:GetModel("GFEA044_GW1"):GetStruct():GetFields()
	Local oModelGW8  := oModel:GetModel("GFEA044_GW8")
	Local aFieldGW8  := oModel:GetModel("GFEA044_GW8"):GetStruct():GetFields()
	Local oModelGWB  := oModel:GetModel("GFEA044_GWB")
	Local aFieldGWB  := oModel:GetModel("GFEA044_GWB"):GetStruct():GetFields()
	Local lFirst     := .T.
	Local aCmpGW1    := {"GW1_CDTPDC","GW1_EMISDC","GW1_SERDC","GW1_DTEMIS", "GW1_CDREM", "GW1_CDDEST", "GW1_TPFRET", "GW1_NRREG", "GW1_USO", "GW1_DSESP", "GW1_QTVOL", ;
						 "GW1_CARREG", "GW1_REGCOM", "GW1_REPRES", "GW1_ENTBAI", "GW1_ENTEND", "GW1_ENTCEP", "GW1_ENTNRC", "GW1_ENTCID", "GW1_ENTUF", "GW1_ICMSDC"}

	If nOperation == MODEL_OPERATION_INSERT
		oModelGW1:SetValue("GW1_USUIMP", cUserName)
	ElseIf nOperation == MODEL_OPERATION_UPDATE
		oModelGW1:SetValue("GW1_USUALT", cUserName)
		oModel:lModify := .F.
	EndIf

	If IsInCallStack("GFEA044") .And. lCopy
		For nI := 1 To Len(aFieldGW1)
			If aFieldGW1[nI][3] == "GW1_ORIGEM" .And. !Empty(&("GW1->"+aFieldGW1[nI][3]))
				oModelGW1:SetValue(aFieldGW1[nI][3], "1")
			ElseIf aFieldGW1[nI][3] == "GW1_SIT" .And. !Empty(&("GW1->"+aFieldGW1[nI][3]))
				oModelGW1:SetValue(aFieldGW1[nI][3], "1")
			ElseIf aFieldGW1[nI][3] == "GW1_DTIMPL".And. !Empty(&("GW1->"+aFieldGW1[nI][3]))
				oModelGW1:SetValue(aFieldGW1[nI][3], DDATABASE)
			ElseIf aFieldGW1[nI][3] == "GW1_HRIMPL".And. !Empty(&("GW1->"+aFieldGW1[nI][3]))
				oModelGW1:SetValue(aFieldGW1[nI][3], SubStr(TIME(),1,5))
			ElseIf aFieldGW1[nI][3] == "GW1_USUIMP" .And. !Empty(&("GW1->"+aFieldGW1[nI][3]))
				oModelGW1:SetValue(aFieldGW1[nI][3], cUserName)
			ElseIf aFieldGW1[nI][3] == "GW1_DTPSAI"
				If GW1->GW1_DTPSAI > DDATABASE .And. !Empty(&("GW1->"+aFieldGW1[nI][3]))
					oModelGW1:SetValue(aFieldGW1[nI][3], &("GW1->"+aFieldGW1[nI][3]))
				EndIf
			ElseIf aFieldGW1[nI][3] == "GW1_HRPSAI"
				If GW1->GW1_DTPSAI > DDATABASE .And. StrTran(GW1->GW1_HRPSAI,":","") > SubStr(StrTran(TIME(),":",""),1,4) .And. !Empty(&("GW1->"+aFieldGW1[nI][3]))
					oModelGW1:SetValue(aFieldGW1[nI][3], &("GW1->"+aFieldGW1[nI][3]))
				EndIf
			ElseIf aFieldGW1[nI][3] == "GW1_ENVEDI"
				oModelGW1:SetValue(aFieldGW1[nI][3], "2")
			ElseIf aFieldGW1[nI][3] == "GW1_DTPENT"
				If GW1_DTPENT > DDATABASE .And. !Empty(&("GW1->"+aFieldGW1[nI][3]))
					oModelGW1:SetValue(aFieldGW1[nI][3], &("GW1->"+aFieldGW1[nI][3]))
				EndIf
			ElseIf aFieldGW1[nI][14] .Or. aFieldGW1[nI][3] == "GW1_NRREG"//não pode copiar
				Loop
			ElseIf aScan( aCmpGW1, { |x| x == aFieldGW1[nI][3] } ) > 0 .And. !Empty(&("GW1->"+aFieldGW1[nI][3]))
				oModelGW1:SetValue(aFieldGW1[nI][3], &("GW1->"+aFieldGW1[nI][3]))
			Else
				oModel:ClearField("GFEA044_GW1",aFieldGW1[nI][3])
			EndIf
		Next nI

		dbSelectArea("GW8")
		GW8->( dbSetOrder(1) )
		GW8->( dbSeek(xFilial("GW8") + GW1->GW1_CDTPDC + GW1->GW1_EMISDC + GW1->GW1_SERDC +GW1->GW1_NRDC ) )
		While !GW8->( Eof() ) .And. GW8->GW8_FILIAL == xFilial("GW8") .And. GW8->GW8_CDTPDC == GW1->GW1_CDTPDC .And. GW8->GW8_EMISDC == GW1->GW1_EMISDC ;
							  .And. GW8->GW8_SERDC == GW1->GW1_SERDC .And. GW8->GW8_NRDC == GW1->GW1_NRDC

			If lFirst
				lFirst := .F.
				oModelGW8:GoLine(1)
			Else
				oModelGW8:AddLine()
			EndIf

			For nI := 1 To Len(aFieldGW8)
				If !aFieldGW8[nI][14] .And. !Empty(&("GW8->"+aFieldGW8[nI][3]))
					oModelGW8:SetValue(aFieldGW8[nI][3], &("GW8->"+aFieldGW8[nI][3]))
				EndIf
			Next nI

			dbSelectArea("GW8")
			GW8->( dbSkip() )
		EndDo

		lFirst := .T.

		dbSelectArea("GWB")
		GWB->( dbSetOrder(2) )
		GWB->( dbSeek(xFilial("GWB") + GW1->GW1_CDTPDC + GW1->GW1_EMISDC + GW1->GW1_SERDC +GW1->GW1_NRDC ) )
		While !GWB->( Eof() ) .And. GWB->GWB_FILIAL == xFilial("GWB") .And. GWB->GWB_CDTPDC == GW1->GW1_CDTPDC .And. GWB->GWB_EMISDC == GW1->GW1_EMISDC ;
							  .And. GWB->GWB_SERDC == GW1->GW1_SERDC .And. GWB->GWB_NRDC == GW1->GW1_NRDC

			If lFirst
				lFirst := .F.
				oModelGWB:GoLine(1)
			Else
				oModelGWB:AddLine()
			EndIf

			For nI := 1 To Len(aFieldGWB)
				If !aFieldGWB[nI][14] .And. !Empty(&("GWB->"+aFieldGWB[nI][3]))
					oModelGWB:SetValue(aFieldGWB[nI][3], &("GWB->"+aFieldGWB[nI][3]))
				EndIf
			Next nI

			dbSelectArea("GWB")
			GWB->( dbSkip() )
		EndDo

		lFirst := .T.

		dbSelectArea("GWU")
		GWU->( dbSetOrder(1) )
		GWU->( dbSeek(xFilial("GWU") + GW1->GW1_CDTPDC + GW1->GW1_EMISDC + GW1->GW1_SERDC +GW1->GW1_NRDC ) )
		While !GWU->( Eof() ) .And. GWU->GWU_FILIAL == xFilial("GWU") .And. GWU->GWU_CDTPDC == GW1->GW1_CDTPDC .And. GWU->GWU_EMISDC == GW1->GW1_EMISDC ;
							  .And. GWU->GWU_SERDC == GW1->GW1_SERDC .And. GWU->GWU_NRDC == GW1->GW1_NRDC

			If lFirst
				lFirst := .F.
				oModelGWU:GoLine(1)
			Else
				oModelGWU:AddLine()
			EndIf

			For nI := 1 To Len(aFields)
				If !aFields[nI][14]
					If aFields[nI][3] $ "GWU_DTPENT;GWU_HRPENT"
						If GWU->GWU_DTPENT > DDATABASE .And. StrTran(GWU->GWU_HRPENT,":","") > SubStr(StrTran(TIME(),":",""),1,4) .And. !Empty(&("GWU->"+aFields[nI][3]))
							oModelGWU:SetValue(aFields[nI][3], &("GWU->"+aFields[nI][3]))
						Else
							oModel:ClearField("GFEA044_GWU",aFields[nI][3])
						EndIf
					ElseIf aFields[nI][3] $ "GWU_DTENT;GWU_HRENT"
						oModel:ClearField("GFEA044_GWU",aFields[nI][3])
					Else
						If !Empty(&("GWU->"+aFields[nI][3]))
							oModelGWU:SetValue(aFields[nI][3], &("GWU->"+aFields[nI][3]))
						EndIf
					EndIf
				EndIf
			Next nI

			dbSelectArea("GWU")
			GWU->( dbSkip() )
		EndDo

		lCopy := .F.
	EndIf
	/* Ajusta informações de campos data */
	If (nOperation == MODEL_OPERATION_UPDATE .Or. nOperation == MODEL_OPERATION_INSERT)	
		If !Empty(oModelGW1:GetValue("GW1_HRIMPL")) .And. SubStr(oModelGW1:GetValue("GW1_HRIMPL"),3,1) != ":" 
			oModelGW1:SetValue("GW1_HRIMPL", SubStr(oModelGW1:GetValue('GW1_HRIMPL'),1,2) + ":" + SubStr(oModelGW1:GetValue("GW1_HRIMPL"),3,2) )
		Endif
	Endif
Return NIL

/*--------------------------------------------------------------------------------------------------
{Protheus.doc} GFEA44COPY
Rotina que executa a view quando for cópia do Documentos de Carga

@sample
GFEA44COPY()

@author Octávio Augusto Felippe de Macedo
@since 24/02/2011
@version 1.0
--------------------------------------------------------------------------------------------------*/
Function GFEA44COPY()
	lCopy := .T.

	FWExecView(STR0090,"GFEA044",3,,{|| .T.}) //"Cópia"
Return

/*--------------------------------------------------------------------------------------------------
{Protheus.doc} GFE44REC
Rotina que cria um novo item caso o Doc Carga incluido já exista

@sample
GFE44REC(oModel,cXML)
oModel - Model do programa
cXML   - Variavel contendo o XML

@author Felipe Mendes
@since 24/04/2011
@version 1.0
--------------------------------------------------------------------------------------------------*/
Function GFE44REC(oModel, cXML)
	Local aItens
	Local cCidDest
	Local cChaveModel
	Local nCont 	:= 1
	Local cError    := ""
	Local cWarning  := ""
	Local oXmlGFE   := XmlParser(cXML, '_', @cError, @cWarning)
	Local nOp       := oModel:GetOperation()
	Local oModelGWU := oModel:GetModel("GFEA044_GWU")

	If nOp == MODEL_OPERATION_DELETE
		Return .T.
	EndIf

	cChaveModel := oModel:GetValue('GFEA044_GW1', 'GW1_CDTPDC') + ;
	oModel:GetValue('GFEA044_GW1', 'GW1_EMISDC') + ;
	oModel:GetValue('GFEA044_GW1', 'GW1_SERDC')  + ;
	oModel:GetValue('GFEA044_GW1', 'GW1_NRDC')

	//Verifica se o romaneio do Documento de Carga que veio pela integração, existe na base, caso não exista o campo será apagado.
	If !Empty(oModel:GetValue('GFEA044_GW1', 'GW1_NRROM'))

		dbSelectArea("GWN")
		GWN->( dbSetOrder(1) )
		If !GWN->( dbSeek(xFilial("GWN") + oModel:GetValue('GFEA044_GW1', 'GW1_NRROM')) )
			oModel:ClearField('GFEA044_GW1', 'GW1_NRROM')
			oModel:SetValue('GFEA044_GW1', 'GW1_SIT', '3')
		ElseIf oModel:GetValue('GFEA044_GW1', 'GW1_SIT') == "3"
			oModel:SetValue('GFEA044_GW1', 'GW1_SIT', '4')
		EndIf
	EndIf

	If nOp == MODEL_OPERATION_INSERT
		If oModelGWU:IsEmpty()
			cCidDest := IIf(Empty(oModel:GetValue('GFEA044_GW1', 'GW1_ENTNRC')), Posicione("GU3", 1, xFilial("GU3") + oModel:GetValue('GFEA044_GW1', 'GW1_CDDEST'), "GU3_NRCID"), oModel:GetValue('GFEA044_GW1', 'GW1_ENTNRC'))

			oModelGWU:GoLine(1)

			oModelGWU:LoadValue("GWU_SEQ", StrZero(1, TamSX3("GWU_SEQ")[1]))
			oModelGWU:LoadValue("GWU_NRCIDD", cCidDest)
			oModelGWU:LoadValue("GWU_UFD", Posicione("GU7", 1, xFilial("GU7") + cCidDest,"GU7_CDUF") )

		Else
			oModelGWU:GoLine(1)

			// Se a cidade do primeiro trecho estiver zerada, tenta buscar com os dados da cidade de entrega ou destinatário
			If AllTrim(FwFldGet("GWU_NRCIDD", 1)) == "0" .OR. Empty(FwFldGet("GWU_NRCIDD", 1))

				cCidDest := IIf(Empty(oModel:GetValue('GFEA044_GW1', 'GW1_ENTNRC')), Posicione("GU3", 1, xFilial("GU3") + oModel:GetValue('GFEA044_GW1', 'GW1_CDDEST'), "GU3_NRCID"), oModel:GetValue('GFEA044_GW1', 'GW1_ENTNRC'))
				oModelGWU:LoadValue("GWU_NRCIDD", cCidDest)
				oModelGWU:LoadValue("GWU_UFD", Posicione("GU7", 1, xFilial("GU7") + cCidDest,"GU7_CDUF") )
			EndIf
		EndIf

		If oModelGWU:Length() > 1
			If oModel:GetValue('GFEA044_GW1', 'GW1_TPFRET') == "1"
				oModel:SetValue('GFEA044_GW1', 'GW1_TPFRET', "2")
			ElseIf oModel:GetValue('GFEA044_GW1', 'GW1_TPFRET') == "3"
				oModel:SetValue('GFEA044_GW1', 'GW1_TPFRET', "4")
			EndIf
		EndIf
	EndIf

	dbSelectArea("GV5")
	GV5->( dbSetOrder(1) )
	If GV5->( dbSeek(xFilial("GV5") + oModel:GetValue('GFEA044_GW1', 'GW1_CDTPDC')) )
		If nOp == MODEL_OPERATION_INSERT
			If (GV5->GV5_SENTID == "2" .And. oModel:GetValue('GFEA044_GW1', 'GW1_TPFRET') $ "3;4") .Or. ;//Saída e FOB
			(GV5->GV5_SENTID == "1" .And. oModel:GetValue('GFEA044_GW1', 'GW1_TPFRET') $ "1;2") //Entrada e CIF
				oModelGWU:LoadValue("GWU_PAGAR", "2")
			EndIf
		EndIf

		If GV5->GV5_SENTID == "2" .And. nOp == MODEL_OPERATION_UPDATE //SAíDA
			oModel:SetErrorMessage(,,,,,"Documento de Carga já existente.")
			Return .F.
		ElseIf nOp == MODEL_OPERATION_INSERT .And. GV5->GV5_SENTID == "1" //ENTRADA

			If VALTYPE(oXmlGFE:_GFEA044:_GFEA044_GW1:_GFEA044_GW8:_ITEMS:_ITEM) == "O"
				XmlNode2Arr( oXmlGFE:_GFEA044:_GFEA044_GW1:_GFEA044_GW8:_ITEMS:_ITEM  , "_ITEM" )
			EndIf

			oItem := oXmlGFE:_GFEA044:_GFEA044_GW1:_GFEA044_GW8:_ITEMS:_ITEM[1]

			dbSelectArea("GW8")
			GW8->( dbSetOrder(1) )
			GW8->( dbSeek(xFilial("GW8") + cChaveModel) )

			While !GW8->( Eof() ) .And. GW8->GW8_FILIAL + GW8->GW8_CDTPDC + GW8->GW8_EMISDC + GW8->GW8_SERDC + GW8->GW8_NRDC == xFilial("GW8") + cChaveModel
				If Alltrim(GW8->GW8_INFO1) == Alltrim(XmlChildEx(oItem:_GW8_INFO1 ,"TEXT"))
					oModel:SetErrorMessage(,,,,,"Documento de Carga já cadastrado")
					Return .F.
				EndIf

				GW8->( dbSkip() )
			EndDo

			//verifica se há um registro com mesma base, caso haja, muda a operação
			dbSelectArea("GW1")
			GW1->( dbSetOrder(1) )
			If GW1->( dbSeek(xFilial("GW1") + cChaveModel) ) .And. nOp == MODEL_OPERATION_INSERT
				oModel:DeActivate(.T.)
				oModel:SetOperation(MODEL_OPERATION_UPDATE)
				oModel:Activate()
			Else
				Return .T.
			EndIf

			//Limpando o Grid para que seja mescladas as informações da tabela com as do XML
			oModel:GetModel("GFEA044_GW8"):DeActivate(.T.)
			oModel:GetModel("GFEA044_GW8"):Activate()

			//verifica se o nó _ITEMS é um Array ou um Objeto (caso seja um Array significa que o nó tem mais de um filho, se for um objeto significa que tem apenas um filho)
			If ValType(oXmlGFE:_GFEA044:_GFEA044_GW1:_GFEA044_GW8:_ITEMS:_ITEM) == "O"
				XmlNode2Arr( oXmlGFE:_GFEA044:_GFEA044_GW1:_GFEA044_GW8:_ITEMS:_ITEM  , "_ITEM" )
			EndIf

			aItens := oXmlGFE:_GFEA044:_GFEA044_GW1:_GFEA044_GW8:_ITEMS:_ITEM

			For nCont := 1 to len(aItens)
				//Valida se conseguiu abrir uma nova linha
				If (oModel:GetModel("GFEA044_GW8"):AddLine() <> 1 + oModel:GetModel("GFEA044_GW8"):Length())

					aError := oModel:GetErrorMessage()
				EndIf

				oItem := oXmlGFE:_GFEA044:_GFEA044_GW1:_GFEA044_GW8:_ITEMS:_ITEM[nCont]

				If XmlChildEx(oItem,"_GW8_CDTPDC") <> NIL .And. XmlChildEx(oItem:_GW8_CDTPDC ,"TEXT") <> ""
					oModel:GetModel("GFEA044_GW8"):SetValue('GW8_CDTPDC',oXmlGFE:_GFEA044:_GFEA044_GW1:_GFEA044_GW8:_ITEMS:_ITEM[nCont]:_GW8_CDTPDC:TEXT)
				EndIf
				If XmlChildEx(oItem,"_GW8_EMISDC") <> NIL .And. XmlChildEx(oItem:_GW8_EMISDC ,"TEXT")  <> ""
					oModel:GetModel("GFEA044_GW8"):SetValue('GW8_EMISDC',oXmlGFE:_GFEA044:_GFEA044_GW1:_GFEA044_GW8:_ITEMS:_ITEM[nCont]:_GW8_EMISDC:TEXT)
				EndIf
				If XmlChildEx(oItem,"_GW8_SERDC") <> NIL .And. XmlChildEx(oItem:_GW8_SERDC ,"TEXT")  <> ""
					oModel:GetModel("GFEA044_GW8"):SetValue('GW8_SERDC',oXmlGFE:_GFEA044:_GFEA044_GW1:_GFEA044_GW8:_ITEMS:_ITEM[nCont]:_GW8_SERDC:TEXT)
				EndIf
				If XmlChildEx(oItem,"_GW8_NRDC") <> NIL .And. XmlChildEx(oItem:_GW8_NRDC ,"TEXT")  <> ""
					oModel:GetModel("GFEA044_GW8"):SetValue('GW8_NRDC',oXmlGFE:_GFEA044:_GFEA044_GW1:_GFEA044_GW8:_ITEMS:_ITEM[nCont]:_GW8_NRDC:TEXT)
				EndIf
				If XmlChildEx(oItem,"_GW8_SEQ") <> NIL .And. XmlChildEx(oItem:_GW8_SEQ ,"TEXT")  <> ""
					oModel:GetModel("GFEA044_GW8"):SetValue('GW8_SEQ',GETSXENUM("GW8","GW8_SEQ"))
					ConfirmSx8()
				EndIf
				If XmlChildEx(oItem,"_GW8_ITEM") <> NIL .And. XmlChildEx(oItem:_GW8_ITEM ,"TEXT")  <> ""
					oModel:GetModel("GFEA044_GW8"):SetValue('GW8_ITEM',UPPER(oXmlGFE:_GFEA044:_GFEA044_GW1:_GFEA044_GW8:_ITEMS:_ITEM[nCont]:_GW8_ITEM:TEXT))
				EndIf
				If XmlChildEx(oItem,"_GW8_DSITEM") <> NIL .And. XmlChildEx(oItem:_GW8_DSITEM ,"TEXT")  <> ""
					oModel:GetModel("GFEA044_GW8"):SetValue('GW8_DSITEM',oXmlGFE:_GFEA044:_GFEA044_GW1:_GFEA044_GW8:_ITEMS:_ITEM[nCont]:_GW8_DSITEM:TEXT)
				EndIf
				If XmlChildEx(oItem,"_GW8_CDCLFR") <> NIL .And. XmlChildEx(oItem:_GW8_CDCLFR ,"TEXT")  <> ""
					oModel:GetModel("GFEA044_GW8"):SetValue('GW8_CDCLFR',oXmlGFE:_GFEA044:_GFEA044_GW1:_GFEA044_GW8:_ITEMS:_ITEM[nCont]:_GW8_CDCLFR:TEXT)
				Else
					oModel:GetModel("GFEA044_GW8"):SetValue('GW8_CDCLFR',GFE044CLF(oXmlGFE:_GFEA044:_GFEA044_GW1:_GFEA044_GW8:_ITEMS:_ITEM[nCont]:_GW8_ITEM:TEXT))
				EndIf
				If XmlChildEx(oItem,"_GW8_QTDE") <> NIL .And. XmlChildEx(oItem:_GW8_QTDE ,"TEXT")  <> ""
					oModel:GetModel("GFEA044_GW8"):SetValue('GW8_QTDE',VAL(oXmlGFE:_GFEA044:_GFEA044_GW1:_GFEA044_GW8:_ITEMS:_ITEM[nCont]:_GW8_QTDE:TEXT))
				EndIf
				If XmlChildEx(oItem,"_GW8_VALOR") <> NIL .And. XmlChildEx(oItem:_GW8_VALOR ,"TEXT")  <> ""
					oModel:GetModel("GFEA044_GW8"):SetValue('GW8_VALOR',VAL(oXmlGFE:_GFEA044:_GFEA044_GW1:_GFEA044_GW8:_ITEMS:_ITEM[nCont]:_GW8_VALOR:TEXT))
				EndIf
				If XmlChildEx(oItem,"_GW8_VOLUME") <> NIL .And. XmlChildEx(oItem:_GW8_VOLUME ,"TEXT")  <> ""
					oModel:GetModel("GFEA044_GW8"):SetValue('GW8_VOLUME',VAL(oXmlGFE:_GFEA044:_GFEA044_GW1:_GFEA044_GW8:_ITEMS:_ITEM[nCont]:_GW8_VOLUME:TEXT))
				EndIf
				If XmlChildEx(oItem,"_GW8_PESOR") <> NIL .And. XmlChildEx(oItem:_GW8_PESOR ,"TEXT")  <> ""
					oModel:GetModel("GFEA044_GW8"):SetValue('GW8_PESOR',VAL(oXmlGFE:_GFEA044:_GFEA044_GW1:_GFEA044_GW8:_ITEMS:_ITEM[nCont]:_GW8_PESOR:TEXT))
				EndIf
				If XmlChildEx(oItem,"_GW8_PESOC") <> NIL .And. XmlChildEx(oItem:_GW8_PESOC ,"TEXT")  <> ""
					oModel:GetModel("GFEA044_GW8"):SetValue('GW8_PESOC',VAL(oXmlGFE:_GFEA044:_GFEA044_GW1:_GFEA044_GW8:_ITEMS:_ITEM[nCont]:_GW8_PESOC:TEXT))
				EndIf
				If XmlChildEx(oItem,"_GW8_INFO1") <> NIL .And. XmlChildEx(oItem:_GW8_INFO1 ,"TEXT")  <> ""
					oModel:GetModel("GFEA044_GW8"):SetValue('GW8_INFO1',oXmlGFE:_GFEA044:_GFEA044_GW1:_GFEA044_GW8:_ITEMS:_ITEM[nCont]:_GW8_INFO1:TEXT)
				EndIf
				If XmlChildEx(oItem,"_GW8_INFO2") <> NIL .And. XmlChildEx(oItem:_GW8_INFO2 ,"TEXT")  <> ""
					oModel:GetModel("GFEA044_GW8"):SetValue('GW8_INFO2',oXmlGFE:_GFEA044:_GFEA044_GW1:_GFEA044_GW8:_ITEMS:_ITEM[nCont]:_GW8_INFO2:TEXT)
				EndIf
				If XmlChildEx(oItem,"_GW8_INFO3") <> NIL .And. XmlChildEx(oItem:_GW8_INFO3 ,"TEXT")  <> ""
					oModel:GetModel("GFEA044_GW8"):SetValue('GW8_INFO3',oXmlGFE:_GFEA044:_GFEA044_GW1:_GFEA044_GW8:_ITEMS:_ITEM[nCont]:_GW8_INFO3:TEXT)
				EndIf
				If XmlChildEx(oItem,"_GW8_INFO4") <> NIL .And. XmlChildEx(oItem:_GW8_INFO4 ,"TEXT")  <> ""
					oModel:GetModel("GFEA044_GW8"):SetValue('GW8_INFO4',oXmlGFE:_GFEA044:_GFEA044_GW1:_GFEA044_GW8:_ITEMS:_ITEM[nCont]:_GW8_INFO4:TEXT)
				EndIf
				If XmlChildEx(oItem,"_GW8_INFO5") <> NIL .And. XmlChildEx(oItem:_GW8_INFO5 ,"TEXT")  <> ""
					oModel:GetModel("GFEA044_GW8"):SetValue('GW8_INFO5',oXmlGFE:_GFEA044:_GFEA044_GW1:_GFEA044_GW8:_ITEMS:_ITEM[nCont]:_GW8_INFO5:TEXT)
				EndIf
				If XmlChildEx(oItem,"_GW8_RATEIO") <> NIL .And. XmlChildEx(oItem:_GW8_RATEIO ,"TEXT")  <> ""
					oModel:GetModel("GFEA044_GW8"):SetValue('GW8_RATEIO',oXmlGFE:_GFEA044:_GFEA044_GW1:_GFEA044_GW8:_ITEMS:_ITEM[nCont]:_GW8_RATEIO:TEXT)
				EndIf
				If XmlChildEx(oItem,"_GW8_TPITEM") <> NIL .And. XmlChildEx(oItem:_GW8_TPITEM ,"TEXT")  <> ""
					oModel:GetModel("GFEA044_GW8"):SetValue('GW8_TPITEM',oXmlGFE:_GFEA044:_GFEA044_GW1:_GFEA044_GW8:_ITEMS:_ITEM[nCont]:_GW8_TPITEM:TEXT)
				EndIf
				If XmlChildEx(oItem,"_GW8_TRIBP") <> NIL .And. XmlChildEx(oItem:_GW8_TRIBP ,"TEXT")  <> ""
					oModel:GetModel("GFEA044_GW8"):SetValue('GW8_TRIBP',oXmlGFE:_GFEA044:_GFEA044_GW1:_GFEA044_GW8:_ITEMS:_ITEM[nCont]:_GW8_TRIBP:TEXT)
				EndIf
				If XmlChildEx(oItem,"_GW8_UNINEG") <> NIL .And. XmlChildEx(oItem:_GW8_UNINEG ,"TEXT")  <> ""
					oModel:GetModel("GFEA044_GW8"):SetValue('GW8_UNINEG',oXmlGFE:_GFEA044:_GFEA044_GW1:_GFEA044_GW8:_ITEMS:_ITEM[nCont]:_GW8_UNINEG:TEXT)
				EndIf
			Next nCont
		EndIf
	EndIf

Return .T.

/*--------------------------------------
Função para eliminar os Cálculos
do Documento de Carga

Requere que o Documento de Carga já esteja posicionado(GW1).

--------------------------------------*/
Function GFEA44DELC(lValid, lOcor)
	Local nI
	Local aCalcs     := {}
	Local lRet       := .T.
	Local lApagaCalc := .T.
	Local aAreaGW1   := GW1->( GetArea() )
	Local aAreaGWH   := GWH->( GetArea() )
	Local aAreaGWF   := GWF->( GetArea() )

	Default lValid := .F. //Indica se apaga os cálculos ou somente valida.
	Default lOcor  := .F. //Indica se verifica as ocorrências vinculadas.

	If lOcor
		dbSelectArea("GWL")
		GWL->( dbSetOrder(2) )
		If GWL->( dbSeek(xFilial("GWL") + GW1->GW1_NRDC + GW1->GW1_FILIAL + GW1->GW1_EMISDC + GW1->GW1_SERDC + GW1->GW1_CDTPDC) )
			lRet :=  .F.
		EndIf
	EndIf

	If lRet
		dbSelectArea("GWH")
		GWH->( dbSetOrder(2) )
		GWH->( dbSeek(xFilial("GWH") + GW1->GW1_CDTPDC + GW1->GW1_EMISDC + GW1->GW1_SERDC + GW1->GW1_NRDC) )
		While !GWH->( Eof() ) .And. GWH->GWH_FILIAL == xFilial("GWH") .And. GWH->GWH_EMISDC == GW1->GW1_EMISDC ;
							  .And. GWH->GWH_SERDC == GW1->GW1_SERDC .And. GWH->GWH_NRDC == GW1->GW1_NRDC

			dbSelectArea("GWF")
			GWF->( dbSetOrder(1) )
			If GWF->( dbSeek(xFilial("GWF") + GWH->GWH_NRCALC) )
				If aScan(aCalcs, {|cNrCalc| cNrCalc == GWH->GWH_NRCALC}) == 0 .And. (GWF->GWF_TPCALC $ "1;6;8") // 1-Normal, 6-Redespacho, 8-Provisao
					aAdd(aCalcs, GWH->GWH_NRCALC)
				EndIf
			EndIf

			GWH->( dbSkip() )
		EndDo

		If !Empty(aCalcs)
			For nI := 1 to len(aCalcs)
				lApagaCalc := .T.

				// Valida o cálculo de frete existente em relacao aos Lote de Provisão
				If !GFEVldLotProvisao(aCalcs[nI])
					lApagaCalc := .F.
				EndIf

				// Valida o cálculo de frete existente em relacao aos documentos de frete
				If !GFEVldDocFrete(aCalcs[nI])
					lApagaCalc := .F.
				EndIf

				// Valida o cálculo de frete existente em relacao a pre-fatura
				If !GFEVldPreFat(aCalcs[nI])
					lApagaCalc := .F.
				EndIf

				// Valida o cálculo de frete em relacao a contrato com terceiros
				If !GFEVldContr(aCalcs[nI])
					lApagaCalc := .F.
				EndIf

				// Se não for possível eliminar o cálculo, não permitir a retirada do mesmo
				If !lApagaCalc
					lRet := .F.
				ElseIf !lValid
					// Apaga o calculo de frete e seus relacionamentos, incluindo movimentos contábeis
					GFEDelCalc(aCalcs[nI])
				EndIf
			Next
		EndIf
	EndIf

	RestArea( aAreaGW1 )
	RestArea( aAreaGWH )
	RestArea( aAreaGWF )
Return lRet

/*------------------------------------------------------------
Função para incluir uma ocorrência com as informações do
Documento de Carga selecionado
------------------------------------------------------------*/
Function GFEA044OCO()
	Local oPanel1
	Local oPanel2
	Local oDlg
	Local aTbl
	Local cAliTre
	Local cCidAnt
	Local cCidOri
	Local cCidDest := IIf(Empty(GW1->GW1_ENTNRC), Posicione("GU3", 1, xFilial("GU3") + GW1->GW1_CDDEST, "GU3_NRCID"), GW1->GW1_ENTNRC)
	//Variáveis dos campos de descrição do DC
	Local cGet1 := GW1->GW1_NRDC
	Local cGet2 := AllTrim(GW1->GW1_EMISDC) + " - " + Posicione("GU3", 1, xFilial("GU3") + GW1->GW1_EMISDC, "GU3_NMEMIT")
	Local cGet3 := GW1->GW1_CDTPDC
	Local cGet4 := GW1->GW1_SERDC
	Local oGet1
	Local oGet2
	Local oGet3
	Local oGet4
	Local oSay1
	Local oSay2
	Local oSay3
	Local oSay4
	Local cFunBkp := FunName()

	Private cAliGWU

	CursorWait()

	dbSelectArea("GWU")
	GWU->( dbSetOrder(1) )
	If GWU->( dbSeek(xFilial("GWU") + GW1->GW1_CDTPDC + GW1->GW1_EMISDC + GW1->GW1_SERDC + GW1->GW1_NRDC + "02") )

		aTbl := {{"TRECHO", "C", 2, 0},;
				 {"TRANSP", "C", TamSX3("GU3_CDEMIT")[1] + TamSX3("GU3_NMEMIT")[1], 0},;
				 {"CIDORI", "C", TamSX3("GU7_NRCID")[1] + TamSX3("GU7_NMCID")[1], 0},;
				 {"CIDDES", "C", TamSX3("GU7_NRCID")[1] + TamSX3("GU7_NMCID")[1], 0}}

		//Alias da tabela temporária de Trechos
		cAliTre := GFECriaTab({aTbl,{"TRECHO+TRANSP"}})
		DEFINE MSDIALOG oDlg TITLE "Incluir Ocorrência" FROM 000, 000  TO 340, 480 PIXEL
		//Painel superior
		oPanel1 := tPanel():New(0,0,,oDlg,,,,,/*Color*/,0,26,.F.,.F.)
		oPanel1:Align := CONTROL_ALIGN_TOP

		@ 002, 003 SAY oSay1 PROMPT "Número"  SIZE 025, 007 OF oPanel1 PIXEL
		@ 002, 053 SAY oSay2 PROMPT "Emissor" SIZE 025, 007 OF oPanel1 PIXEL
		@ 002, 181 SAY oSay3 PROMPT "Tipo"    SIZE 025, 007 OF oPanel1 PIXEL
		@ 002, 211 SAY oSay4 PROMPT "Série"   SIZE 025, 007 OF oPanel1 PIXEL
		@ 011, 003 MSGET oGet1 VAR cGet1 SIZE 050, 010 OF oPanel1 PIXEL WHEN .F.
		@ 011, 053 MSGET oGet2 VAR cGet2 SIZE 128, 010 OF oPanel1 PIXEL WHEN .F.
		@ 011, 181 MSGET oGet3 VAR cGet3 SIZE 025, 010 OF oPanel1 PIXEL WHEN .F.
		@ 011, 211 MSGET oGet4 VAR cGet4 SIZE 025, 010 OF oPanel1 PIXEL WHEN .F.

		//Painel central
		oPanel2 := tPanel():New(0,0,,oDlg,,,,,,0,0,.F.,.F.)
		oPanel2:Align := CONTROL_ALIGN_ALLCLIENT

		//Grid com os trechos para selecionar
		oGrdTre := TCBrowse():New(0, 0, 0, 0,,;
		{"Trecho", "Transportador", "Cidade Origem", "Cidade Destino"},{50, 50, 50, 50},;
		oPanel2,,,,,{||},,,,,,,.F., cAliTre,.T.,,.F.,,, ) //"Trecho"###"Transportador"###"Cidade Origem"###"Cidade Destino"
		oGrdTre:Align := CONTROL_ALIGN_ALLCLIENT
		oGrdTre:bLDblClick := {|| GFEA044IOC(cAliTre), oDlg:End()}

		//--------------------Carregando trechos
		dbSelectArea("GWU")
		GWU->( dbSetOrder(1) )
		GWU->( dbSeek(xFilial("GWU") + GW1->GW1_CDTPDC + GW1->GW1_EMISDC + GW1->GW1_SERDC + GW1->GW1_NRDC) )
		While !GWU->( Eof() ) .And. GWU->GWU_FILIAL == xFilial("GWU") .And. GWU->GWU_CDTPDC == GW1->GW1_CDTPDC ;
							  .And. GWU->GWU_SERDC == GW1->GW1_SERDC .And. GWU->GWU_NRDC == GW1->GW1_NRDC

			If GWU->GWU_SEQ == "01"
				cCidOri := Posicione("GU3", 1, xFilial("GU3") + GW1->GW1_CDREM, "GU3_NRCID")
				cCidAnt := GWU->GWU_NRCIDD
			Else
				cCidOri := cCidAnt
				cCidAnt := GWU->GWU_NRCIDD
			EndIf

			RecLock(cAliTre, .T.)
			(cAliTre)->TRECHO := GWU->GWU_SEQ
			(cAliTre)->TRANSP := AllTrim(GWU->GWU_CDTRP) + " - " + Posicione("GU3", 1, xFilial("GU3") + GWU->GWU_CDTRP, "GU3_NMEMIT")
			(cAliTre)->CIDORI := AllTrim(cCidOri) + " - " + Posicione("GU7", 1, xFilial("GU7") + cCidOri, "GU7_NMCID")
			(cAliTre)->CIDDES := AllTrim(GWU->GWU_NRCIDD) + " - " + Posicione("GU7", 1, xFilial("GU7") + GWU->GWU_NRCIDD, "GU7_NMCID")
			(cAliTre)->(MsUnlock())

			GWU->( dbSkip() )
		EndDo

		GWU->( dbSkip(-1) )

		RecLock("GWU", .F.)
		(cAliTre)->CIDDES := AllTrim(cCidDest) + " - " + Posicione("GU7", 1, xFilial("GU7") + cCidDest, "GU7_NMCID")
		GWU->(MsUnlock())
		//-------------------Fim carga dos dados

		oGrdTre:bLine := {|| {(cAliTre)->TRECHO, (cAliTre)->TRANSP, (cAliTre)->CIDORI, (cAliTre)->CIDDES}}
		oGrdTre:GoTop()

		CursorArrow()

		ACTIVATE MSDIALOG oDlg CENTERED ON INIT EnchoiceBar(ODlg, {|| GFEA044IOC(cAliTre), oDlg:End()}, {|| oDlg:End()},, {/*botões*/})

		GFEDelTab(cAliTre)

	Else
		CursorArrow()

		dbSelectArea("GWU")
		GWU->( dbSetOrder(1) )
		If GWU->( dbSeek(xFilial("GWU") + GW1->GW1_CDTPDC + GW1->GW1_EMISDC + GW1->GW1_SERDC + GW1->GW1_NRDC + "01") )
			SetFunName("GFEA032")	
	
			If !MPUserHasAccess('GFEA032',1,RetCodUsr(),.T.)
				SetFunName(cFunBkp)
				Return .F.
			EndIf
			
			FWExecView("Incluir", "GFEA032", MODEL_OPERATION_INSERT,, {|| .T.})
		EndIf
	EndIf

	If !Empty(Select(cAliGWU))
		GFEDelTab(cAliGWU)
	EndIf

	SetFunName(cFunBkp)
Return

//------------------------------------------------------

Function GFEA044IOC(cAliTre)

	dbSelectArea("GWU")
	GWU->( dbSetOrder(1) )
	If GWU->( dbSeek(xFilial("GWU") + GW1->GW1_CDTPDC + GW1->GW1_EMISDC + GW1->GW1_SERDC + GW1->GW1_NRDC + (cAliTre)->TRECHO) )
		cTreEsc := (cAliTre)->TRECHO
		FWExecView("Incluir", "GFEA032", MODEL_OPERATION_INSERT,, {|| .T.})
	EndIf

Return	
/*
Function que realiza a entrada e entrega automática para documento posicionado no sentido entrada
*/
Function GFE44DtAut()
	Local lRet := .F.
	Local aAreaGWU := GWU->(GetArea())
	Local aAreaGV5 := GV5->(GetArea())
	Local aAreaGW1 := GW1->(GetArea())
	Local cChaveGW1 := GW1->GW1_FILIAL + GW1->GW1_CDTPDC + GW1->GW1_EMISDC + GW1->GW1_SERDC + GW1->GW1_NRDC
	Local cNrRom := GW1->GW1_FILIAL + GW1->GW1_NRROM
	Local lEncerra := .T.

	dbSelectArea("GV5")
	dbSetOrder(1)
	GV5->(dbSeek(xFilial("GV5")+ GW1->GW1_CDTPDC))
	//Verificar a chamada de Data de entrada automática
	If GFEVerCmpo({"GV5_DTENAT"}) .And. GV5->GV5_DTENAT == "1" .And. GV5->GV5_SENTID == "1" .And. !Empty(GW1->GW1_NRROM)
		dbSelectArea("GWU")
		GWU->(dbSetOrder(1))
		GWU->(dbSeek(cChaveGW1))

		//Trechos devem possuir data de entrega igual a data de criação do documento
		While !GWU->(Eof()) .And. cChaveGW1 == GWU->GWU_FILIAL + GWU->GWU_CDTPDC + GWU->GWU_EMISDC + GWU->GWU_SERDC + GWU->GWU_NRDC
				
				RecLock("GWU", .F.)
				GWU->GWU_DTENT := GW1->GW1_DTIMPL
				GWU->GWU_HRENT := GW1->GW1_HRIMPL
				GWU->(MsUnlock())			
			GWU->(dbSkip())
		EndDo

			RecLock("GW1",.F.)
			GW1->GW1_SIT := "5" // tudo entregue, situação entregue
			GW1->(MsUnlock())	

			//verifica os Dc relacionados, se todos estiverem entregues, encerra o romaneio
			dbSelectArea("GW1")
			GW1->( dbSetOrder(9))
			GW1->(dbSeek(cNrRom))
			While !GW1->( Eof() ) .And. GW1->GW1_FILIAL + GW1->GW1_NRROM == cNrRom
				If GW1->GW1_SIT != "5"
					lEncerra := .F.
					Exit
				EndIf

				dbSelectArea("GW1")
				GW1->( dbSkip() )
			EndDo

			If lEncerra
				dbSelectArea("GWN")
				GWN->( dbSetOrder(1) )
				If GWN->( dbSeek(cNrRom) )
					RecLock("GWN", .F.)
					GWN->GWN_SIT := "4"
					MSUnlock()
				EndIf		
			EndIf

		lRet := .T.
	EndIf

	RestArea(aAreaGWU)
	RestArea(aAreaGV5)
	RestArea(aAreaGW1)
Return lRet

/*/{Protheus.doc} GrvSerId
Função genérica que grava a série dos registros filhos
@author siegklenes.beulke
@since 06/10/2014
@version 1.0
@param cTabFilho, character, Tabela em que será gravado o campo de série
@param nIndex, numérico, Indice de ligação com a tabela pai, padrão 1
@param cKeyFilho, character, Nome dos campos de ligação, default cTabFilho->(indexkey())
@param cCampoSer, character, Campo de série da tabela filho
@param cTabPai, character, Tabela 'Pai'
@param nIndexPai, numérico, Indice de ligação , padrão 1
@param cKeyPai, character, Nome dos campos de ligação, default cTabFilho->(indexkey())
@param dDtEmis, data, Data de emissão do documento
@param cSerieGFE, character, campo série
/*/
Function GrvSerId(cTabFilho,nIndex,cKeyFilho,cCampoSer,cTabPai,nIndexPai,cKeyPai,dDtEmis,cSerieGFE,cEsp)
	Default nIndex := 1
	Default nIndexPai := 1

	dbSelectArea(cTabFilho)
	(cTabFilho)->(dbSetOrder(nIndex))
	(cTabPai)->(dbSetOrder(nIndexPai))

	If Empty(cKeyFilho)
		cKeyFilho	:= (cTabFilho)->(IndexKey())
	EndIf

	If Empty(cKeyPai)
		cKeyPai	:= (cTabPai)->(IndexKey())
	EndIf

	If (cTabFilho)->(dbSeek((cTabPai)->(&(cKeyPai))))
		While (cTabFilho)->(!Eof()) .And. (cTabPai)->(&(cKeyPai)) == (cTabFilho)->(&(cKeyFilho))
			RecLock(cTabFilho,.F.)
			SerieNfId(cTabFilho,1,cCampoSer,dDtEmis,cEsp,cSerieGFE)
			(cTabFilho)->(MsUnlock())

			(cTabFilho)->(dbSkip())
		EndDo
	EndIf
Return

/*/{Protheus.doc} SetRegGW1
Função genérica que grava retorna o código da região de acordo com CEP/Cidade/UF
@author marcos.wagner
@since 20/09/2016
@version 1.0
@param cCidade, character, Código da Cidade
@param cUF, character, Código da Unidade Federativa
@param cCEP, character, CEP
/*/
Function SetRegGW1(cCidade,cUF,cCEP)
	Local aOldArea := GetArea()
	Local cRegiao := ""
	Local oQry
	Local cQuery
	Local cAliasGUL
	
	//Busca por CEP
	cAliasGUL := GetNextAlias()
	cQuery := "SELECT GUL_NRREG"
	cQuery += " FROM " + RetSQLName("GUL")
	cQuery += " WHERE GUL_FILIAL =  '"+xFilial("GUL")+"'"
	cQuery += " AND GUL_CEPINI <= ?"
	cQuery += " AND GUL_CEPFIM >= ?"
	cQuery += " AND D_E_L_E_T_ = ' ' "

	cQuery := ChangeQuery(cQuery)
	oQry := FWExecStatement():New(cQuery)

	oQry:SetString(1, cCEP)
	oQry:SetString(2, cCEP)

	cAliasGUL := oQry:OpenAlias()

	dbSelectArea(cAliasGUL)
	(cAliasGUL)->(dbGoTop())
	If (cAliasGUL)->(!Eof())
		cRegiao := (cAliasGUL)->GUL_NRREG
	End
	(cAliasGUL)->(dbCloseArea())

	If Empty(cRegiao)
		//Busca por Cidade
		dbSelectArea("GUA")
		dbSetOrder(2)
		If dbSeek(xFilial("GUA")+cCidade)
			cRegiao := GUA->GUA_NRREG
		EndIf

		If Empty(cRegiao)
			//Busca por UF
			dbSelectArea("GU9")
			dbSetOrder(3)
			If dbSeek(xFilial("GU9")+cUF)
				While GU9->(!Eof()) .AND. GU9->GU9_FILIAL == xFilial("GU9") .AND. GU9->GU9_CDUF == cUF
					If GU9->GU9_DEMCID == "1"
						cRegiao := GU9->GU9_NRREG
						Exit
					EndIf

					GU9->(dbSkip())			
				End 
			EndIf
		EndIf
	EndIf

	RestArea(aOldArea)
Return cRegiao

Static Function IntegDef(cXml,nType,cTypeMsg)
	Local aResult := {}

	Private GFELog044 := GFELog():New("GFEA044", "Integração EAI - Documento de Carga", SuperGetMV('MV_GFEEDIL',,'1'))

	GFELog044:Add('INICIANDO PROCESSAMENTO DA INTEGRAÇÃO GFEA044 VIA EAI...')
	aResult := GFEI044(cXml,nType,cTypeMsg,GFELog044)
Return aResult

Static Function ChkExistRom(cNrGWN, cTranspGWN)
	Local lRet      := .F.
	Local cAliasGWN := GetNextAlias()
	Local cQuery
	Local oQry
	
	cQuery := "SELECT GWN.R_E_C_N_O_"
	cQuery += " FROM " + RetSqlName("GWN") + " GWN"
	cQuery += " WHERE GWN.GWN_FILIAL = '"+  xFilial("GWN") +"'"
	cQuery += "	AND GWN.GWN_NRROM = ?"
	cQuery += "	AND GWN.GWN_CDTRP = ?"
	cQuery += "	AND D_E_L_E_T_ = ''"

	cQuery := ChangeQuery(cQuery)
	oQry := FWExecStatement():New(cQuery)

	oQry:SetString(1, cNrGWN)
	oQry:SetString(2, cTranspGWN)

	cAliasGWN := oQry:OpenAlias()

	If (cAliasGWN)->(!Eof())
		lRet := .T.
	EndIf
	(cAliasGWN)->(dbCloseArea())
Return lRet

// Função para gravação dos dados do Documento de Carga na tabela de registros de Movto de Carga
Function LoadMovtoGW1(oModel)
	Local cAliasGX0 := Nil
	Local cAliasGWU := Nil
	Local cAliasGW8 := Nil
	Local cNomeDest := Nil
   	Local cCidDest  := Nil
   	Local cUFDest	:= Nil
	Local cNomeRem  := Nil
  	Local cCidRem   := Nil
   	Local cUFRem	:= Nil
	Local cFilAux   := Nil
	Local nOpc      := oModel:GetOperation()
   	Local oMovDocto := GFEMovtoCarga():New()
	Local s_MULFIL	:= SuperGetMV("MV_MULFIL",.F.,"2")
	Local cQuery
	Local oQry

	If nOpc == MODEL_OPERATION_INSERT .Or. nOpc == MODEL_OPERATION_UPDATE
		cNomeDest := Alltrim(Posicione("GU3", 1, xFilial("GU3")+GW1->GW1_CDDEST, "GU3_NMEMIT"))
		cCidDest  := Posicione("GU3", 1, xFilial("GU3")+GW1->GW1_CDDEST, "GU3_NRCID")
		cUFDest   := Posicione("GU7", 1, xFilial("GU7")+cCidDest, "GU7_CDUF")
		cNomeRem  := Alltrim(Posicione("GU3", 1, xFilial("GU3")+GW1->GW1_CDREM, "GU3_NMEMIT"))
		cCidRem	  := Posicione("GU3", 1, xFilial("GU3")+GW1->GW1_CDREM, "GU3_NRCID")
		cUFRem	  := Posicione("GU7", 1, xFilial("GU7")+cCidDest, "GU7_CDUF")

		// Atribuição de dados GW1
		oMovDocto:setBranch(GW1->GW1_FILIAL)
		oMovDocto:setDataNF(GW1->GW1_DTEMIS)
		oMovDocto:setTipoNF(GW1->GW1_CDTPDC)
		oMovDocto:setEmissorNF(GW1->GW1_EMISDC)
		oMovDocto:setNomeEmitente(Posicione("GU3", 1, xFilial("GU3")+GW1->GW1_EMISDC, "GU3_NMEMIT"))
		oMovDocto:setSerieNF(GW1->GW1_SERDC)
		oMovDocto:setNumeroNF(GW1->GW1_NRDC)
		oMovDocto:setDestinatarioNF(GW1->GW1_CDDEST)
		oMovDocto:setNomeDestinat(cNomeDest)
		oMovDocto:setCidDestinat(cCidDest)
		oMovDocto:setUFDestinat(cUFDest)
		oMovDocto:setDataSaida(GW1->GW1_DTSAI)
		oMovDocto:setRepresentante(GW1->GW1_REPRES)
		oMovDocto:setRemetente(GW1->GW1_CDREM)
		oMovDocto:setNomeRemetente(cNomeRem)
		oMovDocto:setCidRemetente(cCidRem)
		oMovDocto:setUFRemetente(cUFRem)
		oMovDocto:setRegComercial(GW1->GW1_REGCOM)

		// Verifica se ja existe registro na GX0 para esse documento de Carga
		If nOpc == MODEL_OPERATION_UPDATE .And. (IsInCallStack("GFEX101APR") .Or. IsInCallStack("GFEX101REG"))
			cAliasGX0 := oMovDocto:SearchByDC()
			If (cAliasGX0)->(Eof())
    			nOpc := 3
			EndIf
		EndIf

		// Se tiver Romaneio associado envia esses dados
		If !Empty(GW1->GW1_NRROM)
			If s_MULFIL == "1" .And. GFXCP1212210('GW1_FILROM') 
				cFilAux := GW1->GW1_FILROM
			Else
				cFilAux := GW1->GW1_FILIAL
			EndIf

			GWN->( dbSetOrder(1) )
			If GWN->( dbSeek(cFilAux + GW1->GW1_NRROM) )
				oMovDocto:setFilRomaneio(cFilAux)
				oMovDocto:setNumRomaneio(GWN->GWN_NRROM)
				oMovDocto:setClassFrete(GWN->GWN_CDCLFR)
				oMovDocto:setDescClassFrete(Posicione("GUB", 1, xFilial("GUB")+GWN->GWN_CDCLFR, "GUB_DSCLFR"))
				oMovDocto:setTipoOper(GWN->GWN_CDTPOP)
				oMovDocto:setDescTipoOperacao(Posicione("GV4", 1, xFilial("GV4")+GWN->GWN_CDTPOP, "GV4_DSTPOP"))
			EndIf
		EndIf

		// Atribuição de dados GW8
		cAliasGW8 := GetNextAlias()

		cQuery := "SELECT GW8.GW8_FILIAL,"
		cQuery += " CASE WHEN COUNT(DISTINCT GW8.GW8_UNINEG) > 1 THEN ' ' ELSE MAX(GW8.GW8_UNINEG) END GW8_UNINEG,"
		cQuery += " SUM(ROUND(GW8.GW8_VALOR, 2)) GW8_VALOR,"
		cQuery += " SUM(ROUND(GW8.GW8_PESOR, 2)) GW8_PESOR,"
		cQuery += " SUM(ROUND(GW8.GW8_VOLUME, 2)) GW8_VOLUME,"
		cQuery += " SUM(ROUND(GW8.GW8_PESOC, 2)) GW8_PESOC"	
		cQuery += " FROM " + RetSQLName("GW8") + " GW8"
		cQuery += " WHERE GW8.GW8_FILIAL = ?"
		cQuery += "	AND GW8.GW8_CDTPDC = ?"
		cQuery += "	AND GW8.GW8_EMISDC = ?"
		cQuery += "	AND GW8.GW8_SERDC = ?"
		cQuery += "	AND GW8.GW8_NRDC = ?"
		cQuery += "	AND D_E_L_E_T_ = ''"
		cQuery += "	GROUP BY GW8.GW8_FILIAL"
		
		cQuery := ChangeQuery(cQuery)
		oQry := FWExecStatement():New(cQuery)

		oQry:SetString(1, GW1->GW1_FILIAL)
		oQry:SetString(2, GW1->GW1_CDTPDC)
		oQry:SetString(3, GW1->GW1_EMISDC)
		oQry:SetString(4, GW1->GW1_SERDC)
		oQry:SetString(5, GW1->GW1_NRDC)

		cAliasGW8 := oQry:OpenAlias()

		If (cAliasGW8)->(!EoF())
			oMovDocto:setValorNF((cAliasGW8)->GW8_VALOR)
			oMovDocto:setPesoNF((cAliasGW8)->GW8_PESOR)
			oMovDocto:setVolumeNF((cAliasGW8)->GW8_VOLUME)
			oMovDocto:setPesoCubado((cAliasGW8)->GW8_PESOC)
			oMovDocto:setUnidNegocio((cAliasGW8)->GW8_UNINEG)
		EndIf
		(cAliasGW8)->(dbCloseArea())
   			
		// Atribuição de dados GWU
		cAliasGWU := GetNextAlias()

		cQuery := "SELECT GWU_SEQ, GWU_CDTRP, GWU_DTENT"
		cQuery += " FROM "+RetSqlName("GWU")+ " GWU"
		cQuery += " WHERE GWU.GWU_FILIAL = ?"
		cQuery += "	AND GWU.GWU_CDTPDC = ?"
		cQuery += "	AND GWU.GWU_EMISDC= ?"
		cQuery += "	AND GWU.GWU_SERDC= ?"
		cQuery += "	AND GWU.GWU_NRDC= ?"
		cQuery += "	AND D_E_L_E_T_ = ''"
		cQuery += "	ORDER BY GWU_SEQ"
		
		cQuery := ChangeQuery(cQuery)
		oQry := FWExecStatement():New(cQuery)
			
		oQry:SetString(1, GW1->GW1_FILIAL)
		oQry:SetString(2, GW1->GW1_CDTPDC)
		oQry:SetString(3, GW1->GW1_EMISDC)
		oQry:SetString(4, GW1->GW1_SERDC)
		oQry:SetString(5, GW1->GW1_NRDC)

		cAliasGWU := oQry:OpenAlias()

		Count To nRecNew		// Quantidade de Trechos apos commit
		(cAliasGWU)->(DbGotoP())
		While (cAliasGWU)->(!EoF())
			oMovDocto:setSeqTrecho((cAliasGWU)->GWU_SEQ)
			oMovDocto:setTransportador((cAliasGWU)->GWU_CDTRP)
			oMovDocto:setNomeTransport(Posicione("GU3", 1, xFilial("GU3")+(cAliasGWU)->GWU_CDTRP, "GU3_NMEMIT"))
			oMovDocto:setDataEntrega(StoD((cAliasGWU)->GWU_DTENT))

			nQtdTrch += 1

			If nOpc == MODEL_OPERATION_UPDATE .And. nQtdTrch <= nRecCount
				oMovDocto:UpdateMovtoDC()		// Alteração de Registros na tabela GX0
			Else
				oMovDocto:IncludeMovtoDC()		// Inclusão de Registros na tabela GX0
			EndIf

			(cAliasGWU)->(dbSkip())
		EndDo
		(cAliasGWU)->(dbCloseArea())

	ElseIf nOpc == MODEL_OPERATION_DELETE
		oMovDocto:setBranch(GW1->GW1_FILIAL)
		oMovDocto:setTipoNF(GW1->GW1_CDTPDC)
		oMovDocto:setEmissorNF(GW1->GW1_EMISDC)
		oMovDocto:setSerieNF(GW1->GW1_SERDC)
		oMovDocto:setNumeroNF(GW1->GW1_NRDC)

		oMovDocto:DeleteMovtoDC()		// Exclusão de Registros na tabela GX0
	EndIf

	oMovDocto:Destroy( oMovDocto )
Return
