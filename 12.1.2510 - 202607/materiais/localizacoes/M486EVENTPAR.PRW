#INCLUDE "TOTVS.CH"
#INCLUDE "FILEIO.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "M486EVENTPAR.CH"

PUBLISH MODEL REST NAME M486EVENTPAR source M486EVENTPAR RESOURCE OBJECT FsmRestModel

#DEFINE cCRLF	chr(13) + chr(10)

/*/{Protheus.doc} M486EVEN
    Ventana de mantenimiento de eventos de la factura electrónica para Paraguay
    @type  Function
    @author Rafael Parma
	@param nTDTras, integer, Tipo de documento
    @since 11/2025
/*/
Function M486EVEN(nTDTras)
Local aArea		 := GetArea()
Local lValid	 := .T.
Local aBotoes	 := {}
Local aTipos	 := {}
Local aMotivos   := {}
Local aEventos   := {}
Local bOK		 := { || oDlgEvents:End() }
Local bCancel	 := { || oDlgEvents:End() }
Local oDlgEvents := Nil 
Local oBrwEvents := Nil

Default nTDTras		:= 0

	//5=Remisión (RFN) | 7=Remisión de transferencia entre sucursales (RTS)	
	If nTDTras == 5 .Or. nTDTras == 7
		If SF2->F2_FLFTEX != "6"	//6=Autorizado SIFEN
			Help(NIL, 1, "M486EVEN1", NIL, OemToAnsi(STR0001), 1, 0)			
			lValid := .F.
		EndIf
	Else
		Help(NIL, 1, "M486EVEN2", NIL, OemToAnsi(STR0002), 1, 0)
		lValid := .F.
	EndIf

	If lValid 
		Processa({|lEnd| EVENLOAD(@aTipos,@aMotivos,@aEventos)}, OemToAnsi(STR0008)) //"Obteniendo Información"

		DEFINE MSDIALOG oDlgEvents FROM 0,0 TO 347,958 PIXEL TITLE OemToAnsi(STR0031)

		oBrwEvents := TcBrowse():New(32,5,470,130,,,,oDlgEvents,,,,,,,,,,,,.F.,,.T.,,.F.)
		oBrwEvents:AddColumn(TCColumn():New("",						{|| aEventos[oBrwEvents:nAt,1] },,,,,010,.T.,.F.,,,,,))
		oBrwEvents:AddColumn(TCColumn():New(RetTitle("AQA_SEQ"),	{|| aEventos[oBrwEvents:nAt,2] },,,,,010,.F.,.F.,,,,,))
		oBrwEvents:AddColumn(TCColumn():New(RetTitle("AQA_TIPEV"),	{|| aEventos[oBrwEvents:nAt,3] },,,,,080,.F.,.F.,,,,,))
		oBrwEvents:AddColumn(TCColumn():New(RetTitle("AQA_MOTEV"),	{|| aEventos[oBrwEvents:nAt,4] },,,,,080,.F.,.F.,,,,,))
		oBrwEvents:AddColumn(TCColumn():New(RetTitle("AQA_DATEV"),	{|| aEventos[oBrwEvents:nAt,5] },,,,,020,.F.,.F.,,,,,))
		oBrwEvents:AddColumn(TCColumn():New(RetTitle("AQA_HOREV"),	{|| aEventos[oBrwEvents:nAt,6] },,,,,020,.F.,.F.,,,,,))
		oBrwEvents:AddColumn(TCColumn():New(RetTitle("AQA_IDEV"),	{|| aEventos[oBrwEvents:nAt,7] },,,,,040,.F.,.F.,,,,,))
		oBrwEvents:SetArray(aEventos)
		oBrwEvents:Refresh()

		aAdd(aBotoes,{OemToAnsi(STR0009),{|| M486MEVT(MODEL_OPERATION_VIEW,@aTipos,@aMotivos,@aEventos,@oBrwEvents,@oDlgEvents)}   ,OemToAnsi(STR0009),OemToAnsi(STR0009)})
		aAdd(aBotoes,{OemToAnsi(STR0010),{|| M486MEVT(MODEL_OPERATION_INSERT,@aTipos,@aMotivos,@aEventos,@oBrwEvents,@oDlgEvents)} ,OemToAnsi(STR0010),OemToAnsi(STR0010)}) 
		aAdd(aBotoes,{OemToAnsi(STR0011),{|| M486MEVT(MODEL_OPERATION_UPDATE,@aTipos,@aMotivos,@aEventos,@oBrwEvents,@oDlgEvents)} ,OemToAnsi(STR0011),OemToAnsi(STR0011)}) 	
		aAdd(aBotoes,{OemToAnsi(STR0012),{|| M486MEVT(MODEL_OPERATION_DELETE,@aTipos,@aMotivos,@aEventos,@oBrwEvents,@oDlgEvents)} ,OemToAnsi(STR0012),OemToAnsi(STR0012)})
		aAdd(aBotoes,{OemToAnsi(STR0013),{|| M486TEVT(SF2->F2_FILIAL,SF2->F2_DOC,SF2->F2_SERIE,SF2->F2_CLIENTE,SF2->F2_LOJA,aEventos[oBrwEvents:nAt,2],@aTipos,@aMotivos,@aEventos,@oBrwEvents,@oDlgEvents)}, OemToAnsi(STR0013),OemToAnsi(STR0013)}) 
		aAdd(aBotoes,{OemToAnsi(STR0014),{|| M486LEVT()},OemToAnsi(STR0014),OemToAnsi(STR0014)}) 

		ACTIVATE MSDIALOG oDlgEvents CENTERED ON INIT EnChoiceBar(oDlgEvents,bOK,bCancel,.F.,aBotoes)
		
		FreeObj(oBrwEvents)
		oDlgEvents := Nil
	EndIf

	RestArea(aArea)
	FwFreeArray(aArea)
	FwFreeArray(aBotoes)
	FwFreeArray(aTipos)
	FwFreeArray(aMotivos)
	FwFreeArray(aEventos)	
	bOK := Nil
	bCancel := Nil

Return 


/*/{Protheus.doc} EVENLOAD
    Función responsable de cargar los eventos vinculados a la factura electrónica
    @type  Static Function
    @author Rafael Parma
    @since 11/2025
	@param aTipos, array, Array de tipos de eventos
	@param aMotivos, array, Array de motivos de eventos
	@param aEventos, array, Array de eventos
/*/
Static Function EVENLOAD(aTipos,aMotivos,aEventos)
Local nPos		 := 0
Local cTipo		 := ""
Local cMotivo	 := ""
Local oAprovado  := LoadBitmap(GetResources(),'BR_VERDE')
Local oPendente  := LoadBitmap(GetResources(),'BR_AMARELO')
Local oReprovado := LoadBitmap(GetResources(),'BR_VERMELHO')
Local oStatus	 := Nil

Default aTipos	 := {}
Default aMotivos := {}
Default aEventos := {}
	
	If Len(aTipos)==0
		aAdd(aTipos, {"1", OemToAnsi(STR0003)}) //"Transporte"
	EndIf

	If Len(aMotivos)==0
		aAdd(aMotivos, {"1", OemToAnsi(STR0004)}) //"Lugar entrega"
		aAdd(aMotivos, {"2", OemToAnsi(STR0005)}) //"Conductor"
		aAdd(aMotivos, {"3", OemToAnsi(STR0006)}) //"Emp. Transporte"
		aAdd(aMotivos, {"4", OemToAnsi(STR0007)}) //"Vehículo"
	EndIf

	aEventos := {}
	dbSelectArea("AQA")
	AQA->(dbSetOrder(1))
	AQA->(dbGoTop())
	If AQA->(MsSeek(SF2->F2_FILIAL+SF2->F2_DOC+SF2->F2_SERIE+SF2->F2_CLIENTE+SF2->F2_LOJA))
		Do While !AQA->(EOF()) .AND. AQA->AQA_FILIAL+AQA->AQA_DOC+AQA->AQA_SERIE+AQA->AQA_CLIENT+AQA->AQA_LOJA == SF2->F2_FILIAL+SF2->F2_DOC+SF2->F2_SERIE+SF2->F2_CLIENTE+SF2->F2_LOJA
			cTipo	:= ""
			cMotivo	:= ""
			oStatus	:= Nil			
			Do Case
				Case AQA->AQA_STATUS == "2"	
					oStatus := oAprovado
				Case AQA->AQA_STATUS == "3"
					oStatus := oReprovado
				Otherwise
					oStatus := oPendente
			EndCase			
			nPos := aScan(aTipos, { |x| x[1] == AQA->AQA_TIPEV }) 
			If nPos > 0
				cTipo := aTipos[nPos][2]
			EndIf
			nPos := aScan(aMotivos, { |x| x[1] == AQA->AQA_MOTEV }) 
			If nPos > 0
				cMotivo := aMotivos[nPos][2]
			EndIf
			aAdd(aEventos,{oStatus,AQA->AQA_SEQ,cTipo,cMotivo,AQA->AQA_DATEV,AQA->AQA_HOREV,AQA->AQA_IDEV})
			AQA->(dbSkip())
		EndDo
	EndIf
	
	oStatus := Nil
	oAprovado  := Nil
	oPendente  := Nil
	oReprovado := Nil

Return 


/*/{Protheus.doc} ModelDef
    Función responsable del modelo de datos para el formulario de eventos de la factura electrónica
    @type  Static Function
    @author Rafael Parma
    @since 11/2025
/*/
Static Function ModelDef()
Local oModel  := Nil
Local oStAQA  := FWFormStruct(1,'AQA',,.F.)
Local bPost	  := {|oModel| MEAQAPOST(oModel)}

    oStAQA:SetProperty( 'AQA_FILIAL', MODEL_FIELD_INIT, {|a,b| MEAQAINI(a,b)})
    oStAQA:SetProperty( 'AQA_DOC'   , MODEL_FIELD_INIT, {|a,b| MEAQAINI(a,b)})
    oStAQA:SetProperty( 'AQA_SERIE' , MODEL_FIELD_INIT, {|a,b| MEAQAINI(a,b)})
    oStAQA:SetProperty( 'AQA_CLIENT', MODEL_FIELD_INIT, {|a,b| MEAQAINI(a,b)})
    oStAQA:SetProperty( 'AQA_LOJA'  , MODEL_FIELD_INIT, {|a,b| MEAQAINI(a,b)})
    oStAQA:SetProperty( 'AQA_ESPECI', MODEL_FIELD_INIT, {|a,b| MEAQAINI(a,b)})
    oStAQA:SetProperty( 'AQA_UUID'  , MODEL_FIELD_INIT, {|a,b| MEAQAINI(a,b)})
    oStAQA:SetProperty( 'AQA_TIPEV' , MODEL_FIELD_INIT, {|a,b| MEAQAINI(a,b)})
    oStAQA:SetProperty( 'AQA_MOTEV' , MODEL_FIELD_INIT, {|a,b| MEAQAINI(a,b)}) 
	oStAQA:SetProperty( 'AQA_STATUS', MODEL_FIELD_INIT, {|a,b| MEAQAINI(a,b)}) 

    oModel := MPFormModel():New("M486EVENTPARFORM",/*bPre*/,bPost,/*bCommit*/,/*bCancel*/) 
    oModel:AddFields("AQA_MASTER",/*cOwner*/,oStAQA, /*bPre*/,/*bPost*/,/*bLoad*/)
	oModel:SetPrimaryKey({'AQA_FILIAL','AQA_DOC','AQA_SERIE','AQA_CLIENT','AQA_LOJA','AQA_SEQ'})
    oModel:SetDescription(OemToAnsi(STR0015))
    oModel:GetModel("AQA_MASTER"):SetDescription(OemToAnsi(STR0015))

	oStAQA := Nil
	bPost  := Nil

Return oModel
  

/*/{Protheus.doc} ViewDef
    Función responsable de la interfaz del modelo de datos para el formulario de eventos de la factura electrónica
    @type  Static Function
    @author Rafael Parma
    @since 11/2025
/*/
Static Function ViewDef()
Local cAQAFlds := "AQA_DEPANT/AQA_DEPNOV/AQA_CIDANT/AQA_CIDNOV/AQA_DISANT/AQA_DISNOV/AQA_ENDANT/AQA_ENDNOV/AQA_NUMANT/AQA_NUMNOV/AQA_BAIANT/AQA_BAINOV/AQA_MOTANT/AQA_MOTNOV/AQA_TRPANT/AQA_TRPNOV/AQA_VEIANT/AQA_VEINOV"
Local oView    := Nil
Local oModel   := FWLoadModel("M486EVENTPAR")
Local oStAQA   := FWFormStruct(2,'AQA',{|cField| AllTrim(cField) $ cAQAFlds},.F.)

    oView := FWFormView():New()
    oView:SetModel(oModel)
    oView:AddField("AQA_VIEW", oStAQA, "AQA_MASTER")
    oView:CreateHorizontalBox("VIEW", 100)	
    oView:EnableTitleView('AQA_VIEW', OemToAnsi(STR0015)) 
    oView:SetCloseOnOk({||.T.})
    oView:SetOwnerView("AQA_VIEW","VIEW")

	oModel := Nil
	oStAQA := Nil

Return oView


/*/{Protheus.doc} M486MEVT
    Función responsable de montar la interfaz de mantenimiento de eventos de la factura electrónica
    @type  Function
    @author Rafael Parma
    @since 11/2025
	@param nOperation, integer, Operación a realizar
	@param aTipos, array, Array de tipos de eventos
	@param aMotivos, array, Array de motivos de eventos
	@param aEventos, array, Array de eventos
	@param oBrwEvents, object, Objeto de navegación de eventos
	@param oDlgEvents, object, Objeto de dialogo de eventos	
/*/
Function M486MEVT(nOperation, aTipos, aMotivos, aEventos, oBrwEvents, oDlgEvents)
Local oModel     := Nil
Local cPerg      := "MATA486L"
Local cViewName  := ""
Local nTipEvento := 0
Local nMotEvento := 0
Local lValid     := .T.

Default nOperation := 0
Default aTipos	   := {}
Default aMotivos   := {}
Default aEventos   := {}
Default oBrwEvents := Nil
Default oDlgEvents := Nil
	
	If nOperation == MODEL_OPERATION_INSERT
		If Pergunte(cPerg,.T.)
			nTipEvento := mv_par01
			nMotEvento := mv_par02
			If !M486VINC(SF2->F2_FILIAL, SF2->F2_DOC, SF2->F2_SERIE, SF2->F2_CLIENTE, SF2->F2_LOJA, nTipEvento, nMotEvento)
				Help(NIL, 1, "M486MEVT1", NIL, OemToAnsi(STR0019), 1, 0)
				lValid := .F.
			EndIf
		Else
			lValid := .F.
		EndIf
	ElseIf nOperation == MODEL_OPERATION_VIEW .Or. nOperation == MODEL_OPERATION_UPDATE .Or. nOperation == MODEL_OPERATION_DELETE 
		If Len(aEventos)>0
			dbSelectArea("AQA")
			AQA->(dbSetOrder(1))
			AQA->(dbGoTop())
			If AQA->(MsSeek(SF2->F2_FILIAL+SF2->F2_DOC+SF2->F2_SERIE+SF2->F2_CLIENTE+SF2->F2_LOJA+aEventos[oBrwEvents:nAt,2]))	
				nTipEvento := Val(AQA->AQA_TIPEV)
				nMotEvento := Val(AQA->AQA_MOTEV)
				If nOperation == MODEL_OPERATION_UPDATE .Or. nOperation == MODEL_OPERATION_DELETE 
					If AQA->AQA_STATUS == "2"
						Help(NIL, 1, "M486MEVT2", NIL, OemToAnsi(STR0016) + cCRLF + OemToAnsi(STR0017), 1, 0)
						lValid := .F.				
					EndIf
				EndIf			
			Else
				Help(NIL, 1, "M486MEVT3", NIL, OemToAnsi(STR0018), 1, 0)
				lValid := .F.			
			EndIf
		Else
			Help(NIL, 1, "M486MEVT4", NIL, OemToAnsi(STR0018), 1, 0)
			lValid := .F.
		EndIf
	EndIf

	If lValid 		
		cViewName := "M486EPART"+cValToChar(nTipEvento)+"M"+cValToChar(nMotEvento)
		oModel := FWLoadModel("M486EVENTPAR")
		oModel:SetOperation(nOperation)
		oModel:Activate()	
		FWExecView(STR0015,"VIEWDEF."+cViewName,nOperation,,,,80)	
		If oModel:IsActive()
			oModel:DeActivate()	
			oModel:Destroy()
		EndIf
		oModel := Nil
		
		If nOperation == MODEL_OPERATION_INSERT .Or. nOperation == MODEL_OPERATION_UPDATE .Or. nOperation == MODEL_OPERATION_DELETE 
			Processa({|lEnd| EVENLOAD(@aTipos,@aMotivos,@aEventos)}, OemToAnsi(STR0008)) //"Obteniendo Información"
			oBrwEvents:SetArray(aEventos)
			oBrwEvents:Refresh()
			oDlgEvents:Refresh()			
		EndIf
	EndIf

Return


/*/{Protheus.doc} M486VINC
    Función responsable de validar si ya existe un registro de evento para la factura electrónica con el mismo tipo y motivo no aprobado
    @type  Static Function
    @author Rafael Parma
    @since 11/2025
	@param  cFilDoc, string, Código de la sucursal
	@param  cNumDoc, string, Número de la factura
	@param  cSerDoc, string, Serie de la factura
	@param  cCodCli, string, Código del cliente
	@param  cLojCli, string, Código de la tienda
	@param  nTipEv, integer, Código del tipo de evento
	@param  nMotEv, integer, Código del motivo de evento
	@return lRet, boolean, true si existe un registro no aprobado
/*/
Static Function M486VINC(cFilDoc, cNumDoc, cSerDoc, cCodCli, cLojCli, nTipEv, nMotEv)
Local lRet 		:= .T.
Local oExec		:= Nil
Local cQuery	:= ""
Local nParam	:= 1
Local aStatus 	:= {'1','3'} //1=No transmitido | 3=Rechazado

Default cFilDoc := ""
Default cNumDoc := ""
Default cSerDoc := ""
Default cCodCli := ""
Default cLojCli := ""
Default nTipEv 	:= 0
Default nMotEv 	:= 0

	cQuery := " SELECT COUNT(*) NUMREG "
	cQuery += " FROM " + RetSqlName( "AQA" ) + " AQA "
	cQuery += " WHERE AQA.AQA_FILIAL = ? "
	cQuery += " AND AQA.AQA_DOC = ? "
	cQuery += " AND AQA.AQA_SERIE = ? "
	cQuery += " AND AQA.AQA_CLIENT = ? "
	cQuery += " AND AQA.AQA_LOJA = ? "
	cQuery += " AND AQA.AQA_TIPEV = ? "
	cQuery += " AND AQA.AQA_MOTEV = ? "	
	cQuery += " AND AQA.AQA_STATUS IN (?) "	
	cQuery += " AND AQA.D_E_L_E_T_ = ? "	
	
	cQuery := ChangeQuery(cQuery)
	oExec := FwExecStatement():New(cQuery)	
	oExec:SetString(nParam++,cFilDoc)
	oExec:SetString(nParam++,cNumDoc)	
	oExec:SetString(nParam++,cSerDoc)
	oExec:SetString(nParam++,cCodCli)
	oExec:SetString(nParam++,cLojCli)	
	oExec:SetString(nParam++,cValToChar(nTipEv))
	oExec:SetString(nParam++,cValToChar(nMotEv))
	oExec:SetIn(nParam++,aStatus)
	oExec:SetString(nParam++,' ')	

	If oExec:ExecScalar("NUMREG") > 0 
		lRet := .F.	
	EndIf
	oExec:Destroy()
	oExec := Nil
	FwFreeArray(aStatus)

Return lRet


/*/{Protheus.doc} M486LEVT
    Función responsable de montar la interfaz de leyenda de eventos de la factura electrónica
    @type  Function
    @author Rafael Parma
    @since 11/2025
/*/
Function M486LEVT()
Local oLegenda := FwLegend():New()

	oLegenda:Add( "", "BR_AMARELO"	, OemToAnsi(STR0020))	//"No transmitido"
	oLegenda:Add( "", "BR_VERDE"	, OemToAnsi(STR0021))	//"Aprobado"
	oLegenda:Add( "", "BR_VERMELHO"	, OemToAnsi(STR0022))	//"Rechazado"
	oLegenda:View()

	oLegenda := Nil

Return


/*/{Protheus.doc} MEAQAINI
    Función responsable de cargar el contenido de inicialización de los campos del formulario de eventos de la factura electrónica
    @type  Function
    @author Rafael Parma
    @since 11/2025
	@param oModel, object, Modelo del formulario
	@param cField, string, Nombre del campo
	@return cRet, string, Contenido del campo
/*/
Function MEAQAINI(oModel,cField)
Local aArea := GetArea()
Local cPerg := "MATA486L"
Local cRet  := ""

Default oModel := Nil
Default cField := ""

	If oModel != Nil .and. !Empty(cField)		
		Pergunte(cPerg,.F.)	
		Do Case
			Case Alltrim(cField) == "AQA_FILIAL"
				cRet := SF2->F2_FILIAL
			Case Alltrim(cField) == "AQA_DOC"
				cRet := SF2->F2_DOC
			Case Alltrim(cField) == "AQA_SERIE"
				cRet := SF2->F2_SERIE
			Case Alltrim(cField) == "AQA_CLIENT"
				cRet := SF2->F2_CLIENTE
			Case Alltrim(cField) == "AQA_LOJA"
				cRet := SF2->F2_LOJA
			Case Alltrim(cField) == "AQA_ESPECI"
				cRet := SF2->F2_ESPECIE
			Case Alltrim(cField) == "AQA_UUID"
				cRet := SF2->F2_UUID
			Case Alltrim(cField) == "AQA_TIPEV"
				cRet := cValToChar(mv_par01)
			Case Alltrim(cField) == "AQA_MOTEV"
				cRet := cValToChar(mv_par02)
			Case Alltrim(cField) == "AQA_STATUS"
				cRet := "1"	//1=No transmitido
			Otherwise
				Do Case
					//Transporte & Lugar de entrega
					Case mv_par01 == 1 .AND. mv_par02 == 1	
						dbSelectArea("AQA")
						AQA->(dbSetOrder(1))
						AQA->(dbGoTop())
						If AQA->(MsSeek(SF2->F2_FILIAL+SF2->F2_DOC+SF2->F2_SERIE+SF2->F2_CLIENTE+SF2->F2_LOJA))
							Do While !AQA->(EOF()) .AND. AQA->AQA_FILIAL+AQA->AQA_DOC+AQA->AQA_SERIE+AQA->AQA_CLIENT+AQA->AQA_LOJA == SF2->F2_FILIAL+SF2->F2_DOC+SF2->F2_SERIE+SF2->F2_CLIENTE+SF2->F2_LOJA
								If AQA->AQA_TIPEV == "1" .AND. AQA->AQA_MOTEV == "1"
									Do Case
										Case Alltrim(cField) == "AQA_DEPANT"
											cRet := AQA->AQA_DEPNOV
										Case Alltrim(cField) == "AQA_CIDANT"
											cRet := AQA->AQA_CIDNOV
										Case Alltrim(cField) == "AQA_DISANT"
											cRet := AQA->AQA_DISNOV
										Case Alltrim(cField) == "AQA_ENDANT"
											cRet := AQA->AQA_ENDNOV
										Case Alltrim(cField) == "AQA_NUMANT"
											cRet := AQA->AQA_NUMNOV
										Case Alltrim(cField) == "AQA_BAIANT"
											cRet := AQA->AQA_BAINOV
									EndCase
								EndIf
								AQA->(dbSkip())
							EndDo
						EndIf
						If Empty(cRet)
							If ALLTRIM(SF2->F2_ESPECIE) == "RFN"	//Remisión
								dbSelectArea("SA1")
								SA1->(dbSetOrder(1))
								SA1->(dbGoTop())
								If SA1->(MsSeek(xFilial("SA1")+SF2->F2_CLIENTE+SF2->F2_LOJA))
									Do Case
										Case Alltrim(cField) == "AQA_DEPANT"
											cRet := SA1->A1_DEPTO
										Case Alltrim(cField) == "AQA_CIDANT"
											cRet := SA1->A1_CIUDAD
										Case Alltrim(cField) == "AQA_DISANT"
											cRet := SA1->A1_DISTR
										Case Alltrim(cField) == "AQA_ENDANT"
											cRet := SA1->A1_END
										Case Alltrim(cField) == "AQA_NUMANT"
											cRet := SA1->A1_NUM
										Case Alltrim(cField) == "AQA_BAIANT"
											cRet := SA1->A1_BAIRRO
									EndCase
								EndIf
							Else	//Remisión entre sucursales
								dbSelectArea("SA2")
								SA2->(dbSetOrder(1))
								SA2->(dbGoTop())
								If SA2->(MsSeek(xFilial("SA2")+SF2->F2_CLIENTE+SF2->F2_LOJA))
									Do Case
										Case Alltrim(cField) == "AQA_DEPANT"
											cRet := SA2->A2_DEPTO
										Case Alltrim(cField) == "AQA_CIDANT"
											cRet := SA2->A2_CIUDAD
										Case Alltrim(cField) == "AQA_DISANT"
											cRet := SA2->A2_DISTR
										Case Alltrim(cField) == "AQA_ENDANT"
											cRet := SA2->A2_END
										Case Alltrim(cField) == "AQA_NUMANT"
											cRet := SA2->A2_NUM
										Case Alltrim(cField) == "AQA_BAIANT"
											cRet := SA2->A2_BAIRRO
									EndCase
								EndIf							
							EndIf					
						EndIf				

					//Transporte & Conductor 
					Case mv_par01 == 1 .AND. mv_par02 == 2	
						dbSelectArea("AQA")
						AQA->(dbSetOrder(1))
						AQA->(dbGoTop())
						If AQA->(MsSeek(SF2->F2_FILIAL+SF2->F2_DOC+SF2->F2_SERIE+SF2->F2_CLIENTE+SF2->F2_LOJA))
							Do While !AQA->(EOF()) .AND. AQA->AQA_FILIAL+AQA->AQA_DOC+AQA->AQA_SERIE+AQA->AQA_CLIENT+AQA->AQA_LOJA == SF2->F2_FILIAL+SF2->F2_DOC+SF2->F2_SERIE+SF2->F2_CLIENTE+SF2->F2_LOJA
								If AQA->AQA_TIPEV == "1" .AND. AQA->AQA_MOTEV == "2"
									cRet := AQA->AQA_MOTNOV
								EndIf
								AQA->(dbSkip())
							EndDo
						EndIf
						If Empty(cRet)
							cRet := SF2->F2_TRANSP
						EndIf	

					//Transporte & Empresa de transporte 
					Case mv_par01 == 1 .AND. mv_par02 == 3	
						dbSelectArea("AQA")
						AQA->(dbSetOrder(1))
						AQA->(dbGoTop())
						If AQA->(MsSeek(SF2->F2_FILIAL+SF2->F2_DOC+SF2->F2_SERIE+SF2->F2_CLIENTE+SF2->F2_LOJA))
							Do While !AQA->(EOF()) .AND. AQA->AQA_FILIAL+AQA->AQA_DOC+AQA->AQA_SERIE+AQA->AQA_CLIENT+AQA->AQA_LOJA == SF2->F2_FILIAL+SF2->F2_DOC+SF2->F2_SERIE+SF2->F2_CLIENTE+SF2->F2_LOJA
								If AQA->AQA_TIPEV == "1" .AND. AQA->AQA_MOTEV == "3"
									cRet := AQA->AQA_TRPNOV
								EndIf
								AQA->(dbSkip())
							EndDo
						EndIf
						If Empty(cRet)
							cRet := SF2->F2_TRANSP
						EndIf						

					//Transporte & Vehículo 	
					Case mv_par01 == 1 .AND. mv_par02 == 4					
						dbSelectArea("AQA")
						AQA->(dbSetOrder(1))
						AQA->(dbGoTop())
						If AQA->(MsSeek(SF2->F2_FILIAL+SF2->F2_DOC+SF2->F2_SERIE+SF2->F2_CLIENTE+SF2->F2_LOJA))
							Do While !AQA->(EOF()) .AND. AQA->AQA_FILIAL+AQA->AQA_DOC+AQA->AQA_SERIE+AQA->AQA_CLIENT+AQA->AQA_LOJA == SF2->F2_FILIAL+SF2->F2_DOC+SF2->F2_SERIE+SF2->F2_CLIENTE+SF2->F2_LOJA
								If AQA->AQA_TIPEV == "1" .AND. AQA->AQA_MOTEV == "4"
									cRet := AQA->AQA_VEINOV
								EndIf
								AQA->(dbSkip())
							EndDo
						EndIf	
						If Empty(cRet)
							cRet := SF2->F2_VEICULO
						EndIf									
				EndCase
		EndCase
	EndIf
	
	If !Empty(cField) .AND. Empty(cRet)
		cRet := Space(TAMSX3(cField)[1])
	EndIf

	RestArea(aArea)
	FwFreeArray(aArea)

Return cRet


/*/{Protheus.doc} MEAQAPOST
    Función responsable de la validación del formulario de eventos de la factura electrónica.
    @type  Static Function
    @author Rafael Parma
    @since 11/2025
	@param oModel, object, Modelo del formulario
	@return lRet, boolean, retorno de la validación de los datos
/*/
Static Function MEAQAPOST(oModel)     
Local lRet       := .T.
Local aArea      := GetArea()
Local cPerg      := "MATA486L"
Local cMsgError  := STR0028
Local cCpoError  := ""
Local oModelAQA  := oModel:GetModel("AQA_MASTER")
Local nOperation := oModel:GetOperation()

	//Validaciones de campos obligatorios en la transmisión de los eventos	
	If nOperation == MODEL_OPERATION_INSERT .OR. nOperation == MODEL_OPERATION_UPDATE		
		Pergunte(cPerg,.F.)
		Do Case
			//Transporte & Conductor 
			Case (nOperation == MODEL_OPERATION_INSERT .AND. mv_par01 == 1 .AND. mv_par02 == 2) .OR. (nOperation != MODEL_OPERATION_INSERT .AND. AQA->AQA_TIPEV == "1" .AND. AQA->AQA_MOTEV == "2") 	
				If oModelAQA:GetValue("AQA_MOTNOV") == oModelAQA:GetValue("AQA_MOTANT")
					cMsgError := STR0029
					cCpoError += ALLTRIM(RetTitle("AQA_MOTNOV"))					
				Else
					DbSelectArea('SA4')
					SA4->(DbSetOrder(1)) //A4_FILIAL+A4_COD
					If SA4->(MsSeek(xFilial('SA4') + oModelAQA:GetValue("AQA_MOTNOV")))
						If Empty(SA4->A4_NOME)
							cCpoError += ALLTRIM(RetTitle("A4_NOME"))
						EndIf
						If Empty(SA4->A4_CGC)
							If !Empty(cCpoError)
								cCpoError += ", "
							EndIf					
							cCpoError += ALLTRIM(RetTitle("A4_CGC"))
						EndIf
					EndIf	
				EndIf						
			//Transporte & Empresa de transporte 
			Case (nOperation == MODEL_OPERATION_INSERT .AND. mv_par01 == 1 .AND. mv_par02 == 3) .OR. (nOperation != MODEL_OPERATION_INSERT .AND. AQA->AQA_TIPEV == "1" .AND. AQA->AQA_MOTEV == "3") 	
				If oModelAQA:GetValue("AQA_TRPNOV") == oModelAQA:GetValue("AQA_TRPANT")
					cMsgError := STR0029
					cCpoError += ALLTRIM(RetTitle("AQA_TRPNOV"))					
				Else				
					DbSelectArea('SA4')
					SA4->(DbSetOrder(1)) //A4_FILIAL+A4_COD
					If SA4->(MsSeek(xFilial('SA4') + oModelAQA:GetValue("AQA_TRPNOV")))
						If Empty(SA4->A4_NOME)					
							cCpoError += ALLTRIM(RetTitle("A4_NOME"))
						EndIf
						If Empty(SA4->A4_CGC)
							If !Empty(cCpoError)
								cCpoError += ", "
							EndIf					
							cCpoError += ALLTRIM(RetTitle("A4_CGC"))
						EndIf
						If Empty(SA4->A4_TIPCON)
							If !Empty(cCpoError)
								cCpoError += ", "
							EndIf					
							cCpoError += ALLTRIM(RetTitle("A4_TIPCON"))
						ElseIf AllTrim(SA4->A4_TIPCON) != "1"
							If Empty(SA4->A4_TIPID)
								If !Empty(cCpoError)
									cCpoError += ", "
								EndIf						
								cCpoError += ALLTRIM(RetTitle("A4_TIPID"))
							EndIf
						EndIf
					EndIf
				EndIf
			//Transporte & Vehículo 
			Case (nOperation == MODEL_OPERATION_INSERT .AND. mv_par01 == 1 .AND. mv_par02 == 4) .OR. (nOperation != MODEL_OPERATION_INSERT .AND. AQA->AQA_TIPEV == "1" .AND. AQA->AQA_MOTEV == "4")	
				If oModelAQA:GetValue("AQA_VEINOV") == oModelAQA:GetValue("AQA_VEIANT")
					cMsgError := STR0029
					cCpoError += ALLTRIM(RetTitle("AQA_VEINOV"))					
				Else				
					DbSelectArea("DA3")
					DA3->(DbSetOrder(1)) //DA3_FILIAL+DA3_COD
					If DA3->(MsSeek(xFilial("DA3") + oModelAQA:GetValue("AQA_VEINOV")))
						If Empty(DA3->DA3_FROVEI)					
							cCpoError += ALLTRIM(RetTitle("DA3_FROVEI"))
						EndIf
						If Empty(DA3->DA3_TIPTR2)
							If !Empty(cCpoError)
								cCpoError += ", "
							EndIf					
							cCpoError += ALLTRIM(RetTitle("DA3_TIPTR2"))
						EndIf
						If Empty(DA3->DA3_DESC)
							If !Empty(cCpoError)
								cCpoError += ", "
							EndIf					
							cCpoError += ALLTRIM(RetTitle("DA3_DESC"))
						EndIf	
						If Empty(DA3->DA3_TIPID)
							If !Empty(cCpoError)
								cCpoError += ", "
							EndIf					
							cCpoError += ALLTRIM(RetTitle("DA3_TIPID"))
						Else
							If AllTrim(DA3->DA3_TIPID) == "1"
								If Empty(DA3->DA3_CHASSI)
									If !Empty(cCpoError)
										cCpoError += ", "
									EndIf					
									cCpoError += ALLTRIM(RetTitle("DA3_CHASSI"))
								EndIf						
							Else
								If Empty(DA3->DA3_PLACA)
									If !Empty(cCpoError)
										cCpoError += ", "
									EndIf					
									cCpoError += ALLTRIM(RetTitle("DA3_PLACA"))
								EndIf						
							EndIf
						EndIf									
					EndIf
				EndIf
		EndCase
		If !Empty(cCpoError)			
			If cMsgError == STR0029
				Help(NIL, 1, 'AQAPOST1', NIL, OemToAnsi(cMsgError) + cCRLF + OemToAnsi(cCpoError), 1, 0)
			Else
				Help(NIL, 1, 'AQAPOST2', NIL, OemToAnsi(cMsgError) + cCRLF + OemToAnsi(cCpoError), 1, 0, NIL, NIL, NIL, NIL, NIL, {OemToAnsi(STR0030)})
			EndIf
			lRet := .F.
		EndIf

		If lRet
			If nOperation == MODEL_OPERATION_INSERT
				oModelAQA:SetValue("AQA_SEQ",MEAQASEQ(SF2->F2_FILIAL, SF2->F2_DOC, SF2->F2_SERIE, SF2->F2_CLIENTE, SF2->F2_LOJA))
			EndIf			
			oModelAQA:SetValue("AQA_DATEV",Date())
			oModelAQA:SetValue("AQA_HOREV",SubStr(Time(),1,TamSX3("AQA_HOREV")[1]))	
		EndIf
	EndIf

	oModelAQA := Nil
	RestArea(aArea)
	FwFreeArray(aArea)

Return lRet


/*/{Protheus.doc} MEAQASEQ
    Función responsable de retornar el próximo número secuencial del evento de la factura electrónica
    @type  Static Function
    @author Rafael Parma
    @since 11/2025
	@param  cFilDoc, string, Código de la sucursal
	@param  cNumDoc, string, Número de la factura
	@param  cSerDoc, string, Serie de la factura
	@param  cCliDoc, string, Código del cliente
	@param  cLojDoc, string, Código de la tienda
	@return cRet, string, Número secuencial del evento de la factura electrónica
/*/
Static Function MEAQASEQ(cFilDoc, cNumDoc, cSerDoc, cCliDoc, cLojDoc)
Local oExec		:= Nil
Local cQuery	:= ""
Local cRet  	:= ""
Local cSeq  	:= ""
Local nSeq  	:= 0
Local nParam	:= 1

Default cFilDoc := ""
Default cNumDoc := ""
Default cSerDoc := ""
Default cCliDoc := ""
Default cLojDoc := ""

	cQuery := " SELECT MAX(AQA.AQA_SEQ) SEQ "
	cQuery += " FROM " + RetSqlName( "AQA" ) + " AQA "
	cQuery += " WHERE AQA.AQA_FILIAL = ? "
	cQuery += " AND AQA.AQA_DOC = ? "
	cQuery += " AND AQA.AQA_SERIE = ? "
	cQuery += " AND AQA.AQA_CLIENT = ? "
	cQuery += " AND AQA.AQA_LOJA = ? "
	cQuery += " AND AQA.D_E_L_E_T_ = ? "	
	
	cQuery := ChangeQuery(cQuery)
	oExec := FwExecStatement():New(cQuery)	
	oExec:SetString(nParam++,cFilDoc)
	oExec:SetString(nParam++,cNumDoc)	
	oExec:SetString(nParam++,cSerDoc)
	oExec:SetString(nParam++,cCliDoc)
	oExec:SetString(nParam++,cLojDoc)	
	oExec:SetString(nParam++,' ')	

	cSeq := oExec:ExecScalar("SEQ") 
	If !Empty(cSeq)
		nSeq := Val(cSeq)
	EndIf
	oExec:Destroy()
	oExec := Nil

	cRet := StrZero(nSeq+1,TAMSX3("AQA_SEQ")[1])

Return cRet


/*/{Protheus.doc} M486TEVT
    Función responsable de la transmisión del evento de la factura electrónica
    @type  Function
    @author Rafael Parma
    @since 11/2025	
	@param  cFilDoc, string, Código de la sucursal
	@param  cNumDoc, string, Número de la factura
	@param  cSerDoc, string, Serie de la factura
	@param  cCliDoc, string, Código del cliente
	@param  cLojDoc, string, Código de la tienda
	@param  cSeqDoc, string, Número secuencial del evento de la factura electrónica
	@param aTipos, array, Array de tipos de eventos
	@param aMotivos, array, Array de motivos de eventos
	@param aEventos, array, Array de eventos
	@param oBrwEvents, object, Objeto de navegación de eventos
	@param oDlgEvents, object, Objeto de dialogo de eventos	
	@return lRet, boolean, true si la transmisión del evento de la factura electrónica es ok	
/*/
Function M486TEVT(cFilDoc, cNumDoc, cSerDoc, cCliDoc, cLojDoc, cSeqDoc, aTipos, aMotivos, aEventos, oBrwEvents, oDlgEvents)
Local aArea		:= GetArea()
Local lRet  	:= .F.
Local aFact 	:= {}
Local aError 	:= {}
Local aTrans	:= {}
Local cMsgLog 	:= ""
Local cTipoTran := "EFE"

Default cFilDoc    := "" 
Default cNumDoc    := "" 
Default cSerDoc    := "" 
Default cCliDoc    := "" 
Default cLojDoc    := "" 
Default cSeqDoc    := ""
Default aTipos     := {}
Default aMotivos   := {}
Default aEventos   := {} 
Default oBrwEvents := Nil
Default oDlgEvents := Nil

	If !Empty(cFilDoc) .AND. !Empty(cNumDoc) .AND. !Empty(cSerDoc) .AND. !Empty(cCliDoc) .AND. !Empty(cLojDoc) .AND. !Empty(cSeqDoc)
		dbSelectArea("AQA")
		AQA->(dbSetOrder(1))
		AQA->(dbGoTop())
		If AQA->(MsSeek(cFilDoc+cNumDoc+cSerDoc+cCliDoc+cLojDoc+cSeqDoc))	
			If AQA->AQA_STATUS $ "1/3"			
				If SoftLock("AQA")
					CURSORWAIT()
					Processa({|lEnd| lRet := M486XMLE(SF2->F2_DOC, SF2->F2_SERIE, SF2->F2_ESPECIE, @aError)}, OemToAnsi(STR0023))
					If lRet
						aAdd(aFact,{SF2->F2_SERIE,SF2->F2_DOC,SF2->F2_CLIENTE,SF2->F2_LOJA,SF2->F2_EMISSAO,SF2->F2_FILIAL,.F.,"",SF2->F2_SERIE2,SF2->F2_ESPECIE,SF2->F2_UUID,AQA->AQA_SEQ})
						Processa({|lEnd| lRet := M486FPAREN(aFact, cTipoTran, @aError, @aTrans)}, OemToAnsi(STR0024))					
						If Len(aError) != Len(aTrans)
							lRet := .F.
							cMsgLog := OemToAnsi(STR0025) + cCRLF + OemToAnsi(STR0027)						
						Else
							cMsgLog := OemToAnsi(STR0026) + cCRLF + OemToAnsi(STR0027)						
						EndIf											
						If MsgYESNO(cMsgLog)
							M486GENLOG(aError,Len(aFact),Len(aTrans))
						EndIf				
					Else
						AQA->(MsUnLock())
					EndIf
					CURSORARROW()
					Processa({|lEnd| EVENLOAD(@aTipos,@aMotivos,@aEventos)}, OemToAnsi(STR0008)) //"Obteniendo Información"
					oBrwEvents:SetArray(aEventos)
					oBrwEvents:Refresh()
					oDlgEvents:Refresh()
				EndIf
			Else
				Help(NIL, 1, "M486TEVT1", NIL, OemToAnsi(STR0016), 1, 0)
			EndIf
		Else
			Help(NIL, 1, "M486TEVT2", NIL, OemToAnsi(STR0018), 1, 0)
		EndIf			
	Else
		Help(NIL, 1, "M486TEVT3", NIL, OemToAnsi(STR0018), 1, 0)
	EndIf

	RestArea(aArea)
	FwFreeArray(aArea)	

Return lRet

/*/{Protheus.doc} M486XMLE
    Función responsable de la creación del archivo XML del evento de la factura electrónica
    @type  Static Function
    @author Rafael Parma
    @since 11/2025	
	@param  cNumDoc, string, Número de la factura
	@param  cSerDoc, string, Serie de la factura
	@param  cEspDoc, string, Especie de la factura
	@param  aError, array, Arreglo de errores
	@return lRet, boolean, true si la creación del archivo XML está ok
/*/
Static Function M486XMLE(cNumDoc, cSerDoc, cEspDoc, aError)
Local lRet  	:= .T.
Local aArea 	:= GetArea()
Local cRuta		:= &(SuperGetMV("MV_CFDDOCS",,""))
Local cXML		:= ""
Local cXMLFile	:= ""

Default cNumDoc := SF2->F2_DOC
Default cSerDoc := SF2->F2_SERIE
Default cEspDoc := SF2->F2_ESPECIE
Default aError  := {}

	cXMLFile := AllTrim(cSerDoc) + AllTrim(cNumDoc) + AllTrim(cEspDoc) + AllTrim(AQA->AQA_SEQ)

	cXML += '							<gGroupTiEvt>' + cCRLF
	cXML += '								<rGeVeTr>' + cCRLF
	cXML += '									<Id>'+AQA->AQA_UUID+'</Id>' + cCRLF

	Do Case
		//Transporte & Lugar de entrega
		Case AQA->AQA_TIPEV == "1" .AND. AQA->AQA_MOTEV == "1"
			cXML += '									<dMotEv>' + AQA->AQA_MOTEV + '</dMotEv>' + cCRLF
			cXML += '									<cDepEnt>' + AllTrim(AQA->AQA_DEPNOV) + '</cDepEnt>' + cCRLF
			cXML += '									<dDesDepEnt>' + Alltrim(ObtColSAT('S003',AQA->AQA_DEPNOV, 1, 2, 3,28)) + '</dDesDepEnt>' + cCRLF
			If !Empty(AQA->AQA_DISNOV)
				cXML += '									<cDisEnt>' + AllTrim(AQA->AQA_DISNOV) + '</cDisEnt>' + cCRLF
				cXML += '									<dDesDisEnt>' + AllTrim(ObtColSAT('S031',AQA->AQA_DISNOV, 1, 3, 4,30)) + '</dDesDisEnt>' + cCRLF
			EndIf
			cXML += '									<cCiuEnt>' + AllTrim(AQA->AQA_CIDNOV) + '</cCiuEnt>' + cCRLF
			cXML += '									<dDesCiuEnt>' + AllTrim(ObtColSAT('S012',AQA->AQA_CIDNOV, 48, 4, 52,30)) + '</dDesCiuEnt>' + cCRLF
			cXML += '									<dDirEnt>' + AllTrim(AQA->AQA_ENDNOV) + '</dDirEnt>' + cCRLF
			cXML += '									<dNumCas>' + AllTrim(AQA->AQA_NUMNOV) + '</dNumCas>' + cCRLF
			If !Empty(AQA->AQA_BAINOV)
				cXML += '									<dCompDir1>' + AllTrim(AQA->AQA_BAINOV) + '</dCompDir1>' + cCRLF
			EndIf

		//Transporte & Conductor 
		Case AQA->AQA_TIPEV == "1" .AND. AQA->AQA_MOTEV == "2"
			cXML += '									<dMotEv>' + AQA->AQA_MOTEV + '</dMotEv>' + cCRLF
			DbSelectArea('SA4')
			SA4->(DbSetOrder(1)) //A4_FILIAL+A4_COD
			If SA4->(MsSeek(xFilial('SA4') + AQA->AQA_MOTNOV))
				cXML += '									<dNomChof>' + AllTrim(SA4->A4_NOME) + '</dNomChof>' + cCRLF		
				cXML += '									<dNumIDChof>' + AllTrim(SA4->A4_CGC) + '</dNumIDChof>' + cCRLF		
			EndIf
				
		//Transporte & Empresa de transporte 
		Case AQA->AQA_TIPEV == "1" .AND. AQA->AQA_MOTEV == "3"
			cXML += '									<dMotEv>' + AQA->AQA_MOTEV + '</dMotEv>' + cCRLF
			DbSelectArea('SA4')
			SA4->(DbSetOrder(1)) //A4_FILIAL+A4_COD
			If SA4->(MsSeek(xFilial('SA4') + AQA->AQA_TRPNOV))
				cXML += '									<iNatTrans>' + AllTrim(SA4->A4_TIPCON) + '</iNatTrans>' + cCRLF
				If AllTrim(SA4->A4_TIPCON) == "1"
					cXML += '									<dRucTrans>' + SUBSTR(SA4->A4_CGC,1,RAT("-",SA4->A4_CGC)-1) + '</dRucTrans>' + cCRLF
					cXML += '									<dDVTrans>' + SUBSTR(SA4->A4_CGC,RAT("-",SA4->A4_CGC)+ 1,1) + '</dDVTrans>' + cCRLF
					cXML += '									<dNomTrans>' + AllTrim(SA4->A4_NOME) + '</dNomTrans>' + cCRLF
				Else
					cXML += '									<dNomTrans>' + AllTrim(SA4->A4_NOME) + '</dNomTrans>' + cCRLF
					cXML += '									<iTipIDTrans>' + Alltrim(SA4->A4_TIPID) + '</iTipIDTrans>' + cCRLF
					cXML += '									<dDTipIDTrans>' +  Alltrim(ObtColSAT("S018", ALLTRIM(SA4->A4_TIPID), 1, 1, 2,41))  + '</dDTipIDTrans>' + cCRLF
					cXML += '									<dNumIDTrans>' + AllTrim(SA4->A4_CGC) + '</dNumIDTrans>' + cCRLF
				EndIf

			EndIf

		//Transporte & Vehículo 	
		Case AQA->AQA_TIPEV == "1" .AND. AQA->AQA_MOTEV == "4"	
			cXML += '									<dMotEv>' + AQA->AQA_MOTEV + '</dMotEv>' + cCRLF
			DbSelectArea("DA3")
			DA3->(DbSetOrder(1)) //DA3_FILIAL+DA3_COD
			If DA3->(MsSeek(xFilial("DA3") + AQA->AQA_VEINOV))
				cXML += '									<iTipTrans>' + AllTrim(DA3->DA3_FROVEI) + '</iTipTrans>' + cCRLF
				If AllTrim(AllTrim(DA3->DA3_FROVEI)) == "1"
					cXML += '									<dDesTipTrans>Propio</dDesTipTrans>' + cCRLF
				Else
					cXML += '									<dDesTipTrans>Tercero</dDesTipTrans>' + cCRLF
				EndIf
				cXML += '									<iModTrans>' + AllTrim(DA3->DA3_TIPTR2) + '</iModTrans>' + cCRLF
				cXML += '									<dDesModTrans>' + AllTrim(ObtColSAT("S026", AllTrim(DA3->DA3_TIPTR2), 1, 1, 2,10)) + '</dDesModTrans>' + cCRLF
				cXML += '									<dTiVehTras>' + Alltrim(ObtColSAT("S026", AllTrim(DA3->DA3_TIPTR2), 1, 1, 2,10)) + '</dTiVehTras>' + cCRLF
				cXML += '									<dMarVeh>' + AllTrim(DA3->DA3_DESC) + '</dMarVeh>' +cCRLF
				cXML += '									<dTipIdenVeh>' + AllTrim(DA3->DA3_TIPID) + '</dTipIdenVeh>' + cCRLF
				If AllTrim(DA3->DA3_TIPID) == "1"
					cXML += '									<dNroIDVeh>' + AllTrim(DA3->DA3_CHASSI) + '</dNroIDVeh>' + cCRLF
				Else
					cXML += '									<dNroMatVeh>' + AllTrim(DA3->DA3_PLACA) + '</dNroMatVeh>' + cCRLF
				EndIf
			EndIf
	EndCase

	cXML += '								</rGeVeTr>' + cCRLF
	cXML += '							</gGroupTiEvt>' + cCRLF

	cXML := ENCODEUTF8(cXML)
	fWriteLocal(cXML, cRuta, cXMLFile + ".xml", 1)

	If !File(cRuta+cXMLFile+".xml")
		lRet := .F.
	EndIf

	RestArea(aArea)
	FwFreeArray(aArea)

Return lRet
