#INCLUDE "GFEC050.ch"
#INCLUDE 'PROTHEUS.CH'
#INCLUDE 'FWMVCDEF.CH'
//--------------------------------------------------------------------------------------------------- 
/*/{Protheus.doc} GFEC050
Romaneios de Carga
Generico

@sample
GFEC050()

@author Felipe M.
@since 23/11/09
@version 1.0                                                                                      
/*/
//------------------------------------------------------------------------------------------------
 
Function GFEC050()
Local oBrowse
Private aRotina := MenuDef()

oBrowse := FWMBrowse():New()
oBrowse:SetAlias('GWN')							// Alias da tabela utilizada
oBrowse:SetMenuDef('GFEC050')				    // Nome do fonte onde esta a função MenuDef
oBrowse:SetDescription("Consulta de Romaneios de Carga")	// "Romaneios de Carga"

oBrowse:AddLegend("GWN_SIT=='1'", "WHITE" , STR0010) //"Digitado"
oBrowse:AddLegend("GWN_SIT=='2'", "YELLOW", STR0011) //"Impresso"
oBrowse:AddLegend("GWN_SIT=='3'", "GREEN" , STR0012) //"Liberado"
oBrowse:AddLegend("GWN_SIT=='4'", "RED"   , STR0013) //"Encerrado"

oBrowse:Activate()

Return(Nil)

//-------------------------------------------------------------------------------------------------------    

Static Function MenuDef()
Local aRotina := {}

ADD OPTION aRotina TITLE STR0015 ACTION 'AxPesqui'        OPERATION 1  ACCESS 0 //"Pesquisar" 
ADD OPTION aRotina TITLE STR0016 ACTION 'VIEWDEF.GFEC050' OPERATION 2  ACCESS 0 //"Visualizar"
ADD OPTION aRotina TITLE STR0017 ACTION 'VIEWDEF.GFEC050' OPERATION 8  ACCESS 0 //"Imprimir"
ADD OPTION aRotina TITLE "Visualizar Anexo" ACTION "MsDocument('GWN',GWN->(RecNo()), 2)" OPERATION 2  ACCESS 0 

Return aRotina                                                                                         

//-------------------------------------------------------------------------------------------------------

Static Function ModelDef()
	Local oModel
	Local oStruGW1 := FWFormStruct( 1, 'GW1', /*bAvalCampo*/, /*lViewUsado*/ )
	Local oStruGWU := FWFormStruct( 1, 'GWU', /*bAvalCampo*/, /*lViewUsado*/ )
	Local oStruGWB := FWFormStruct( 1, 'GWB', /*bAvalCampo*/, /*lViewUsado*/ )
	Local oStruGW8 := FWFormStruct( 1, 'GW8', /*bAvalCampo*/, /*lViewUsado*/ )
	Local oStruGWF := FWFormStruct( 1, 'GWF', /*bAvalCampo*/, /*lViewUsado*/ )
	Local oStruGWJ := FWFormStruct( 1, 'GWJ', /*bAvalCampo*/, /*lViewUsado*/ )
	Local oStruGWO := FWFormStruct( 1, 'GWO', /*bAvalCampo*/, /*lViewUsado*/ )
 
	oStruGWF:AddField(STR0008, STR0009, "GWF_VALFRT", "N", 9, 2/*nDECIMAL*/, /*bVALID*/, /*bWHEN*/, /*{"1","2"}*/, /*lOBRIGAT*/, {|| GFEC050CLC(GWF->GWF_NRCALC)}, /*lKEY*/, /*lNOUPD*/, /*lVIRTUAL*/)

	oModel := MPFormModel():New('GFEC050', /*bPre*/, /*bPost*/, /*bCommit*/, /*bCancel*/)

	//Define que o model ira carregar os dados sob demanda...
	oModel:SetOnDemand()

	oModel:AddFields('GFEC050_GWN', Nil, FWFormStruct(1,'GWN'), /*bPre*/, /*bPost*/, /*bLoad*/)//Romaneio  

	oModel:AddGrid('GFEC050_GW1', 'GFEC050_GWN', oStruGW1, /*bLinePre*/,, /*bLinePost*/, /*bPre*/, /*bPost*/, /*bLoad*/) //notas fiscais
	oModel:AddGrid('GFEC050_GWU', 'GFEC050_GW1', oStruGWU, /*bLinePre*/,, /*bLinePost*/, /*bPre*/, /*bPost*/, /*bLoad*/) //trechos
	oModel:AddGrid('GFEC050_GWB', 'GFEC050_GW1', oStruGWB, /*bLinePre*/,, /*bLinePost*/, /*bPre*/, /*bPost*/, /*bLoad*/) //unitizadores do documento de carga
	oModel:AddGrid('GFEC050_GW8', 'GFEC050_GW1', oStruGW8, /*bLinePre*/,, /*bLinePost*/, /*bPre*/, /*bPost*/, /*bLoad*/) //itens do documento de carga

	oModel:AddGrid('GFEC050_GWF', 'GFEC050_GWN', oStruGWF, /*bLinePre*/, /*bLinePost*/, /*bPre*/, /*bPost*/, /*{|oMod| GFEC050VLFR(oMod)}/*bLoad*/) //cálculos
	oModel:AddGrid('GFEC050_GWJ', 'GFEC050_GWF', oStruGWJ, /*bLinePre*/,, /*bLinePost*/, /*bPre*/, /*bPost*/, /*bLoad*/) //pré-fatura
	oModel:AddGrid('GFEC050_GWO', 'GFEC050_GWF', oStruGWO, /*bLinePre*/,, /*bLinePost*/, /*bPre*/, /*bPost*/, /*bLoad*/) //ajustes

	If GFXCP1212210('GW1_FILROM')
		oModel:SetRelation('GFEC050_GW1',{{'GW1_FILROM','GWN_FILIAL'},{'GW1_NRROM' ,'GWN_NRROM' }},'GW1_FILIAL+GW1_CDTPDC+GW1_EMISDC+GW1_SERDC+GW1_NRDC')
			
		oModel:SetRelation('GFEC050_GWF',{{'GWF_FILROM','GWN_FILIAL'},{'GWF_NRROM' ,'GWN_NRROM' }},'GWF_FILIAL+GWF_NRCALC')
	Else
		oModel:SetRelation('GFEC050_GW1',{{'GW1_FILIAL','xFilial("GW1")'},{'GW1_NRROM' ,'GWN_NRROM' }},'GW1_FILIAL+GW1_CDTPDC+GW1_EMISDC+GW1_SERDC+GW1_NRDC')
			
		oModel:SetRelation('GFEC050_GWF',{{'GWF_FILIAL','xFilial("GWF")'},{'GWF_NRROM' ,'GWN_NRROM' }},'GWF_FILIAL+GWF_NRCALC')
	EndIf
	oModel:SetRelation('GFEC050_GWU',{{'GWU_FILIAL','GW1_FILIAL'},{'GWU_CDTPDC','GW1_CDTPDC'},{'GWU_EMISDC','GW1_EMISDC'},{'GWU_SERDC','GW1_SERDC'},{'GWU_NRDC','GW1_NRDC'}},'GWU_FILIAL+GWU_CDTPDC+GWU_EMISDC+GWU_SERDC+GWU_NRDC+GWU_SEQ')
	oModel:SetRelation('GFEC050_GWB',{{'GWB_FILIAL','GW1_FILIAL'},{'GWB_CDTPDC','GW1_CDTPDC'},{'GWB_EMISDC','GW1_EMISDC'},{'GWB_SERDC','GW1_SERDC'},{'GWB_NRDC','GW1_NRDC'}},'GWB_FILIAL+GWB_NRDC')
	oModel:SetRelation('GFEC050_GW8',{{'GW8_FILIAL','GW1_FILIAL'},{'GW8_CDTPDC','GW1_CDTPDC'},{'GW8_EMISDC','GW1_EMISDC'},{'GW8_SERDC','GW1_SERDC'},{'GW8_NRDC','GW1_NRDC'}},'GW8_FILIAL+GW8_CDTPDC+GW8_EMISDC+GW8_SERDC+GW8_NRDC+GW8_SEQ')

	oModel:SetRelation('GFEC050_GWJ',{{'GWJ_FILIAL','GWF_FILPRE'    },{'GWJ_NRPF'  ,'GWF_NRPREF'}},'GWJ_FILIAL+GWJ_NRPF'  )
	oModel:SetRelation('GFEC050_GWO',{{'GWO_FILIAL','xFilial("GWO")'},{'GWO_NRCALC','GWF_NRCALC'}},'GWO_FILIAL+GWO_NRCALC+DTOS(GWO_DTAJUS)+GWO_HRAJUS' )

	oModel:SetOptional("GFEC050_GWJ", .T. )
	oModel:SetOptional("GFEC050_GWO", .T. ) 

Return oModel

//-------------------------------------------------------------------------------------------------------

Static Function ViewDef()

	Local oModel := FWLoadModel('GFEC050')
	Local oView  := Nil
	Local oStructGWN := FWFormStruct(2, 'GWN')
	Local oStructGW1 := FWFormStruct(2, 'GW1')
	Local oStructGWU := FWFormStruct(2, 'GWU')
	Local oStructGWB := FWFormStruct(2, 'GWB')
	Local oStructGW8 := FWFormStruct(2, 'GW8')
	Local oStructGWF := FWFormStruct(2, 'GWF')
	Local oStructGWJ := FWFormStruct(2, 'GWJ')
	Local oStructGWO := FWFormStruct(2, 'GWO')
	Local nPosBase
	Local cPosBase
	Local cCampos 
	Local nX
	
	oStructGWF:AddField("GWF_VALFRT", "", STR0008, "", {STR0018}, "GET", "@E 999,999,999.99", /*bPICTVAR*/, /*cLOOKUP*/, .F., /*"1"*/, /*cGRUP*/, /*aListaCombo*/, /*nMAXLENCOMBO*/, /*"1"*/, /*lVIRTUAL*/, /*cPICTVAR*/, /*lINSERTLIN*/) //"Valor da soma dos componentes de cálculo."
	
	oStructGWN:AddGroup("GrpId" , "Identificação"        , "", 2) // "Identificação"
	oStructGWN:AddGroup("GrpClc", "Cálculo de Frete"     , "", 2) // "Cálculo de Frete"
	oStructGWN:AddGroup("GrpMot", "Motoristas e Veículos", "", 2) // "Motoristas e Veículos"
	oStructGWN:AddGroup("GrpVig", "Viagem"               , "", 2) // "Viagem"
	oStructGWN:AddGroup("GrpViag", "Consolidação de carga", "", 2)
	oStructGWN:AddGroup("GrpObs", "Observações"          , "", 2) // "Observações"
	oStructGWN:AddGroup("GrpRea", "Reabertura"           , "", 2) // "Reabertura"
	oStructGWN:AddGroup("GrpCtr", "Controle"             , "", 2) // "Controle"
	
	oStructGWN:SetProperty("GWN_NRROM", MVC_VIEW_GROUP_NUMBER, "GrpId")
	oStructGWN:SetProperty("GWN_CDTRP", MVC_VIEW_GROUP_NUMBER, "GrpId")
	oStructGWN:SetProperty("GWN_DSTRP", MVC_VIEW_GROUP_NUMBER, "GrpId")
	
	If oStructGWN:HasField("GWN_TOTALT")
		// Mostra os campos totalizadores somente se for configurado como browse
		If GetSx3Cache("GWN_TOTVOL","X3_BROWSE") == "N"
			oStructGWN:RemoveField("GWN_TOTVOL")
		EndIf
		If GetSx3Cache("GWN_TOTPER","X3_BROWSE") == "N"
			oStructGWN:RemoveField("GWN_TOTPER")
		EndIf
		If GetSx3Cache("GWN_TOTPEC","X3_BROWSE") == "N"
			oStructGWN:RemoveField("GWN_TOTPEC")
		EndIf
		If GetSx3Cache("GWN_TQTVOL","X3_BROWSE") == "N"
			oStructGWN:RemoveField("GWN_TQTVOL")
		EndIf
		If GetSx3Cache("GWN_TOTALT","X3_BROWSE") == "N"
			oStructGWN:RemoveField("GWN_TOTALT")
		EndIf
	EndIf
	
	If AScan(oStructGWN:aFields,{|x| x[1] == "GWN_MOTREA"}) != 0
		oStructGWN:SetProperty("GWN_MOTREA", MVC_VIEW_GROUP_NUMBER, "GrpRea")
		oStructGWN:SetProperty("GWN_DTREAB", MVC_VIEW_GROUP_NUMBER, "GrpRea")
		oStructGWN:SetProperty("GWN_HRREAB", MVC_VIEW_GROUP_NUMBER, "GrpRea")
		oStructGWN:SetProperty("GWN_USUREA", MVC_VIEW_GROUP_NUMBER, "GrpRea")
	EndIf
	
	oStructGWN:SetProperty("GWN_CDTPOP", MVC_VIEW_GROUP_NUMBER, "GrpClc")
	oStructGWN:SetProperty("GWN_CDCLFR", MVC_VIEW_GROUP_NUMBER, "GrpClc")
	oStructGWN:SetProperty("GWN_DSCLFR", MVC_VIEW_GROUP_NUMBER, "GrpClc")
	oStructGWN:SetProperty("GWN_CDTPVC", MVC_VIEW_GROUP_NUMBER, "GrpClc")
	
	oStructGWN:SetProperty("GWN_CDMTR" , MVC_VIEW_GROUP_NUMBER, "GrpMot")
	oStructGWN:SetProperty("GWN_NMMTR" , MVC_VIEW_GROUP_NUMBER, "GrpMot")
	oStructGWN:SetProperty("GWN_CDMTR2", MVC_VIEW_GROUP_NUMBER, "GrpMot")
	oStructGWN:SetProperty("GWN_NMMTR2", MVC_VIEW_GROUP_NUMBER, "GrpMot")
	oStructGWN:SetProperty("GWN_PLACAD", MVC_VIEW_GROUP_NUMBER, "GrpMot")
	oStructGWN:SetProperty("GWN_PLACAM", MVC_VIEW_GROUP_NUMBER, "GrpMot")
	oStructGWN:SetProperty("GWN_PLACAT", MVC_VIEW_GROUP_NUMBER, "GrpMot")
	oStructGWN:SetProperty("GWN_LACRE", MVC_VIEW_GROUP_NUMBER,  "GrpMot")	
	oStructGWN:SetProperty("GWN_PRIOR" , MVC_VIEW_GROUP_NUMBER, "GrpVig")
	oStructGWN:SetProperty("GWN_DISTAN", MVC_VIEW_GROUP_NUMBER, "GrpVig")
	oStructGWN:SetProperty("GWN_CEPD"  , MVC_VIEW_GROUP_NUMBER, "GrpVig")
	oStructGWN:SetProperty("GWN_NRCIDD", MVC_VIEW_GROUP_NUMBER, "GrpVig")
	oStructGWN:SetProperty("GWN_NMCIDD", MVC_VIEW_GROUP_NUMBER, "GrpVig")
	oStructGWN:SetProperty("GWN_RASTR" , MVC_VIEW_GROUP_NUMBER, "GrpVig")
	
	If AScan(oStructGWN:aFields,{|x| x[1] == "GWN_NRCIDO"}) != 0
		oStructGWN:SetProperty("GWN_CEPO", MVC_VIEW_GROUP_NUMBER, "GrpVig")
		oStructGWN:SetProperty("GWN_NRCIDO", MVC_VIEW_GROUP_NUMBER, "GrpVig")
		oStructGWN:SetProperty("GWN_NMCIDO", MVC_VIEW_GROUP_NUMBER, "GrpVig")
	EndIf
	
	oStructGWN:SetProperty("GWN_DTIMPL", MVC_VIEW_GROUP_NUMBER, "GrpCtr")
	oStructGWN:SetProperty("GWN_HRIMPL", MVC_VIEW_GROUP_NUMBER, "GrpCtr")
	oStructGWN:SetProperty("GWN_SIT"   , MVC_VIEW_GROUP_NUMBER, "GrpCtr")
	oStructGWN:SetProperty("GWN_DTSAI" , MVC_VIEW_GROUP_NUMBER, "GrpCtr")
	oStructGWN:SetProperty("GWN_HRSAI" , MVC_VIEW_GROUP_NUMBER, "GrpCtr")
	oStructGWN:SetProperty("GWN_CALC"  , MVC_VIEW_GROUP_NUMBER, "GrpCtr")
	oStructGWN:SetProperty("GWN_MTCALC", MVC_VIEW_GROUP_NUMBER, "GrpCtr")
	oStructGWN:SetProperty("GWN_DTCALC", MVC_VIEW_GROUP_NUMBER, "GrpCtr")
	oStructGWN:SetProperty("GWN_HRCALC", MVC_VIEW_GROUP_NUMBER, "GrpCtr")
	
	
	If AScan(oStructGWN:aFields,{|x| x[1] == "GWN_AGRUP"}) != 0
		oStructGWN:SetProperty("GWN_AGRUP", MVC_VIEW_GROUP_NUMBER, "GrpCtr")
	EndIf
	
	If AScan(oStructGWN:aFields,{|x| x[1] == "GWN_VPVAL"}) != 0
		oStructGWN:SetProperty("GWN_VPVAL", MVC_VIEW_GROUP_NUMBER, "GrpVig")
		oStructGWN:SetProperty("GWN_VPNUM", MVC_VIEW_GROUP_NUMBER, "GrpVig")
		oStructGWN:SetProperty("GWN_VPCDOP", MVC_VIEW_GROUP_NUMBER, "GrpVig")
		oStructGWN:SetProperty("GWN_VPNMOP", MVC_VIEW_GROUP_NUMBER, "GrpVig")
		oStructGWN:SetProperty("GWN_VALEP", MVC_VIEW_GROUP_NUMBER, "GrpCtr")
	EndIf
	
	If AScan(oStructGWN:aFields,{|x| x[1] == "GWN_DSREAL"}) != 0
		oStructGWN:SetProperty("GWN_HODRET", MVC_VIEW_GROUP_NUMBER, "GrpVig")
		oStructGWN:SetProperty("GWN_HODSAI", MVC_VIEW_GROUP_NUMBER, "GrpVig")
		oStructGWN:SetProperty("GWN_DSREAL", MVC_VIEW_GROUP_NUMBER, "GrpVig")
		oStructGWN:SetProperty("GWN_DTRET", MVC_VIEW_GROUP_NUMBER, "GrpCtr")
		oStructGWN:SetProperty("GWN_HRRET", MVC_VIEW_GROUP_NUMBER, "GrpCtr")
		oStructGWN:SetProperty("GWN_FECHAM", MVC_VIEW_GROUP_NUMBER, "GrpCtr")
		oStructGWN:SetProperty("GWN_DTFECH", MVC_VIEW_GROUP_NUMBER, "GrpCtr")
	EndIf
	
	oStructGWN:SetProperty("GWN_BLOQPF", MVC_VIEW_GROUP_NUMBER, "GrpCtr")
	oStructGWN:SetProperty("GWN_ORI"   , MVC_VIEW_GROUP_NUMBER, "GrpCtr")
	oStructGWN:SetProperty("GWN_USUIMP", MVC_VIEW_GROUP_NUMBER, "GrpCtr")
	
	oStructGWN:SetProperty("GWN_OBS", MVC_VIEW_GROUP_NUMBER, "GrpObs")
	
	If oStructGWN:HasField("GWN_VIAGEM")
		oStructGWN:SetProperty("GWN_VIAGEM", MVC_VIEW_GROUP_NUMBER, "GrpViag")
	EndIf
	
	If oStructGWN:HasField("GWN_CPESO")
	 	oStructGWN:SetProperty("GWN_CPESO", MVC_VIEW_GROUP_NUMBER, "GrpViag")
	EndIf 	
	
	If oStructGWN:HasField("GWN_CVOL")
		oStructGWN:SetProperty("GWN_CVOL", MVC_VIEW_GROUP_NUMBER, "GrpViag")
	EndIf
	
	If oStructGWN:HasField("GWN_CVAL")
		oStructGWN:SetProperty("GWN_CVAL", MVC_VIEW_GROUP_NUMBER, "GrpViag")
	EndIf
	
	If oStructGWN:HasField("GWN_CQTDE")
		oStructGWN:SetProperty("GWN_CQTDE", MVC_VIEW_GROUP_NUMBER, "GrpViag")
	EndIf
	if GFXCP12117("GWU_NRCIDO")
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
	EndIf

	oView := FWFormView():New()
	oView:SetModel(oModel)
	
	oView:AddField('GFEC050_GWN', oStructGWN, /*cLinkID*/ )
	oView:AddGrid('GFEC050_GW1', oStructGW1)
	oView:AddGrid('GFEC050_GWU', oStructGWU)
	oView:AddGrid('GFEC050_GWB', oStructGWB)
	oView:AddGrid('GFEC050_GW8', oStructGW8)
	oView:AddGrid('GFEC050_GWF', oStructGWF)
	oView:AddGrid('GFEC050_GWJ', oStructGWJ)
	oView:AddGrid('GFEC050_GWO', oStructGWO)
	
	oView:CreateHorizontalBox( 'MASTER', 45 ) 
	oView:CreateHorizontalBox( 'DETAIL', 55 ) 
	
	oView:CreateFolder('IDFOLDER', 'DETAIL') 
	oView:AddSheet('IDFOLDER', 'IDSHEET01', STR0004) //Documentos de Carga
	oView:AddSheet('IDFOLDER', 'IDSHEET02', STR0005) //Cálculos 
	
	//--------------FOLDER DA NF 
	oView:CreateHorizontalBox('DATAILDC' , 50,,, 'IDFOLDER', 'IDSHEET01')
	oView:CreateHorizontalBox('DETAILDC2', 50,,, 'IDFOLDER', 'IDSHEET01')
	
	oView:CreateFolder('IDFOLDER01', 'DETAILDC2') 
	oView:AddSheet('IDFOLDER01', 'IDSHEET03', STR0001)  //'Trechos do Documento de Carga'
	oView:AddSheet('IDFOLDER01', 'IDSHEET04', STR0002)  //'Unitizadores dos Documentos de Carga'
	oView:AddSheet('IDFOLDER01', 'IDSHEET05', STR0003)  //'Itens dos Documentos de Carga'

	oView:CreateHorizontalBox('DETAILDC3', 100,,, 'IDFOLDER01', 'IDSHEET03' )
	oView:CreateHorizontalBox('DETAILDC4', 100,,, 'IDFOLDER01', 'IDSHEET04' )
	oView:CreateHorizontalBox('DETAILDC5', 100,,, 'IDFOLDER01', 'IDSHEET05' )
	
	//-------------FOLDER DE CÁLCULOS        
	
	oView:CreateHorizontalBox('DETAILCAL' , 50,,, 'IDFOLDER', 'IDSHEET02' )
	oView:CreateHorizontalBox('DATAILCAL2', 50,,, 'IDFOLDER', 'IDSHEET02' )
	
	oView:CreateFolder('IDFOLDER02','DATAILCAL2') 
	oView:AddSheet('IDFOLDER02','IDSHEET04',STR0006) //Pré-Faturas
	oView:AddSheet('IDFOLDER02','IDSHEET05',STR0007) //Ajustes
	
	oView:CreateHorizontalBox('DETAILPREF', 100,,, 'IDFOLDER02', 'IDSHEET04' )
	oView:CreateHorizontalBox('DETAILAJU' , 100,,, 'IDFOLDER02', 'IDSHEET05' )
	
	//-------------------------------
	
	oView:SetOwnerView('GFEC050_GWN', 'MASTER'   )
	oView:SetOwnerView('GFEC050_GW1', 'DATAILDC' )   
	oView:SetOwnerView('GFEC050_GWU', 'DETAILDC3')   
	oView:SetOwnerView('GFEC050_GWB', 'DETAILDC4')   
	oView:SetOwnerView('GFEC050_GW8', 'DETAILDC5')  
	
	oView:SetOwnerView('GFEC050_GWF', 'DETAILCAL' )   
	oView:SetOwnerView('GFEC050_GWJ', 'DETAILPREF')   
	oView:SetOwnerView('GFEC050_GWO', 'DETAILAJU' ) 
	
	oView:AddUserButton("Cons. Doc. Carga", "MAGIC_BMP", {|oView| GFEC050CDC(oView)}, ) //""
	oView:AddUserButton("Cons. Cálculo"   , "MAGIC_BMP", {|oView| GFEC050CCL(oView)}, ) //""
	
Return oView

//--------------------------------------------

Function GFEC050CDC(oView)
	
	Local oModel    := oView:GetModel()
	Local oModelGW1 := oModel:GetModel("GFEC050_GW1")
	Local nLine     := oModelGW1:GetLine()
	
	dbSelectArea("GW1")
	GW1->( dbSetOrder(1) )
	If GW1->( dbSeek(xFilial("GW1") + FWFldGet("GW1_CDTPDC", nLine) + FWFldGet("GW1_EMISDC", nLine) + ;
				     FWFldGet("GW1_SERDC", nLine) + FWFldGet("GW1_NRDC", nLine)) )
				  
		FWExecView("Visualiza", "GFEC040", 1,,{|| .T.})
		
	EndIf
	
Return
     
//--------------------------------------------

Function GFEC050CCL(oView)
	Local oModel    := oView:GetModel()
	Local oModelGWF := oModel:GetModel("GFEC050_GWF")
	Local nLine     := oModelGWF:GetLine()
	Local cFilGWF   := FWFldGet("GWF_FILIAL", nLine)
	Local cNrGWF    := FWFldGet("GWF_NRCALC", nLine)

	dbSelectArea("GWF")
	GWF->( dbSetOrder(1) )
	If GWF->( dbSeek(cFilGWF + cNrGWF) )	  
		FWExecView("Visualiza", "GFEC080", 1,,{|| .T.})
	Else 
		Help( ,, 'HELP',, "Romaneio não possui cálculo." , 1, 0,)
	EndIf
	
Return

//--------------------------------------------

Function GFEC050CLC(cNrCalc)
	Local nVlTotal := 0
	
	dbSelectArea("GWI")
	GWI->( dbSetOrder(1) )
	GWI->( dbSeek(GWF->GWF_FILIAL + cNrCalc) )
	While !GWI->( Eof() ) .And. GWI->GWI_FILIAL == GWF->GWF_FILIAL .And. GWI->GWI_NRCALC == cNrCalc
		
		If GWI->GWI_TOTFRE == "1"
			nVlTotal += GWI->GWI_VLFRET
		EndIf
		
		GWI->( dbSkip() )
	EndDo
	
	nVltotal += GWF->GWF_VLAJUS
	
Return nVltotal
