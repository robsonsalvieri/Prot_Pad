#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "GFEA517.CH"

//------------------------------------------------------------------- 
//Ínclusão Pátios Release 12.1.4
/*/{Protheus.doc} GFEA517

Agendamento de entradas e saídas

@author Jorge Matos Valcanaia
@since 28/09/10
@version 1.0
/*/
//-------------------------------------------------------------------
Static lEscolheDoc := .T.

Function GFEA517()
	Private oBrowse
	Private lCpoSrGWW := GfeVerCmpo({"GWW_SDOC"})

	If !GFECheckGX4()
		Return .F.
	EndIF

	If !GFEA510COMP()
		MsgStop( "Necessário aplicar o update U_GFE11I20 para utilizar o processo de pátios e portarias." )
		Return .F.
	EndIf

	oBrowse := FWMBrowse():New()
	oBrowse:SetAlias("GWV")			// Alias da tabela utilizada
	oBrowse:SetMenuDef("GFEA517")	// Nome do fonte onde esta a função MenuDef
	oBrowse:SetDescription(STR0001)	// "Agendamento de entradas e saídas"

	oBrowse:AddLegend("GWV_SIT=='1'", "GREEN" , "Aberto")
	oBrowse:AddLegend("GWV_SIT=='2'", "BLACK" , "Concluído")
	oBrowse:AddLegend("GWV_SIT=='3'", "RED"   , "Cancelado")

	oBrowse:Activate()

Return(Nil)

//-------------------------------------------------------------------
Static Function MenuDef()
	Local aRotina		:= {}
	Local aRotAdic 	:= {}
	
	//-------------------------------------------------------
	// Adiciona botões do browse
	//-------------------------------------------------------
	ADD OPTION aRotina TITLE STR0002 ACTION "AxPesqui"        OPERATION 1 ACCESS 0 //"Pesquisar"
	ADD OPTION aRotina TITLE STR0003 ACTION "VIEWDEF.GFEA517" OPERATION 2 ACCESS 0 //"Visualizar"
	ADD OPTION aRotina TITLE STR0004 ACTION "VIEWDEF.GFEA517" OPERATION 3 ACCESS 0 //"Incluir"
	ADD OPTION aRotina TITLE STR0005 ACTION "VIEWDEF.GFEA517" OPERATION 4 ACCESS 0 //"Alterar"
	ADD OPTION aRotina TITLE STR0006 ACTION "GFEA517ENV()"	  OPERATION 4 ACCESS 0 //"Enviar Email"
	ADD OPTION aRotina TITLE STR0007 ACTION "GFEA517CAN()"    OPERATION 6 ACCESS 0 //"Cancelar"
	ADD OPTION aRotina TITLE STR0008 ACTION "GFEA517EXC()"	  OPERATION 5 ACCESS 0 //"Excluir"
	ADD OPTION aRotina TITLE STR0009 ACTION "GFEA517PAR()"    OPERATION 3 ACCESS 0 //"Parâmetros"
	ADD OPTION aRotina TITLE "Confirmar" ACTION "GFEA517CON()" OPERATION 10 ACCESS 0 //"Confirmar"
	
	If ExistBlock("GFEA5171")
		aRotAdic := ExecBlock("GFEA5171",.F.,.F.)
		If ValType(aRotAdic) == "A"
			AEval(aRotAdic, {|x| AAdd(aRotina ,x)})
		EndIf
	EndIf
	
Return aRotina

//-------------------------------------------------------------------
Static Function ModelDef()
	Local oModel     := Nil
	Local oStructGWV := FWFormStruct(1,"GWV")
	Local oStructGWW := FWFormStruct(1,"GWW")
	Local oStructGWX := FWFormStruct(1,"GWX")
	Local oStructGX1 := FWFormStruct(1,"GX1")
	Local oStructGWZ := FWFormStruct(1,"GWZ")
	Local oStructGWY := FWFormStruct(1,"GWY")

	// cID     Identificador do modelo
	// bPre    Code-Block de pre-edição do formulário de edição. Indica se a edição esta liberada
	// bPost   Code-Block de validação do formulário de edição
	// bCommit Code-Block de persistência do formulário de edição
	// bCancel Code-Block de cancelamento do formulário de edição
	oModel := MPFormModel():New("GFEA517", /*bPre*/, {|oModel| GFEA517POS(oModel)}, /*bCommit*/, /*bCancel*/)
	// cId          Identificador do modelo
	// cOwner       Identificador superior do modelo
	// oModelStruct Objeto com  a estrutura de dados
	// bPre         Code-Block de pré-edição do formulário de edição. Indica se a edição esta liberada
	// bPost        Code-Block de validação do formulário de edição
	// bLoad        Code-Block de carga dos dados do formulário de edição
	oModel:AddFields("GFEA517_GWV", Nil, oStructGWV,/*bPre*/,/*bPost*/,/*bLoad*/)

	oModel:AddGrid("GFEA517_GWW","GFEA517_GWV",oStructGWW,/*bLinePre*/,{|oModel| GFE517PreT(oModel), GFEA517GWW(oModel)},/*bLinePost*/,/*bPre*/,/*bPost*/,/*bLoad*/)
	oModel:SetRelation("GFEA517_GWW",{{"GWW_FILIAL",'xFilial("GWW")'},{"GWW_NRAGEN","GWV_NRAGEN"}},"GWW_FILIAL+GWW_NRAGEN")
	oModel:SetPrimaryKey({"GWV_FILIAL","GWV_NRAGEN"})
	oModel:GetModel("GFEA517_GWW"):SetDelAllLine(.T.)
	oModel:GetModel("GFEA517_GWW"):SetUniqueLine({"GWW_FILIAL","GWW_NRAGEN","GWW_NRDC","GWW_CDTPDC","GWW_EMISDC","GWW_SERDC"})

	oModel:AddGrid("GFEA517_GWX","GFEA517_GWV",oStructGWX,/*bLinePre*/,/*bLinePost*/,/*bPre*/,/*bPost*/,/*bLoad*/)
	oModel:SetRelation("GFEA517_GWX",{{"GWX_FILIAL",'xFilial("GWX")'},{"GWX_NRAGEN","GWV_NRAGEN"}},"GWX_FILIAL+GWX_NRAGEN")
	oModel:SetPrimaryKey({"GWV_FILIAL","GWV_NRAGEN"})
	oModel:GetModel("GFEA517_GWX"):SetDelAllLine(.T.)
	oModel:GetModel("GFEA517_GWX"):SetUniqueLine({"GWX_FILIAL","GWX_NRAGEN","GWX_CDENDE"})

	oModel:AddGrid("GFEA517_GX1","GFEA517_GWV",oStructGX1,/*bLinePre*/,/*bLinePost*/,/*bPre*/,/*bPost*/,/*bLoad*/)
	oModel:SetRelation("GFEA517_GX1",{{"GX1_FILIAL",'xFilial("GX1")'},{"GX1_NRAGEN","GWV_NRAGEN"}},"GX1_FILIAL+GX1_NRAGEN")
	oModel:SetPrimaryKey({"GWV_FILIAL","GWV_NRAGEN"})
	oModel:GetModel("GFEA517_GX1"):SetDelAllLine(.T.)
	oModel:GetModel("GFEA517_GX1"):SetUniqueLine({"GX1_FILIAL","GX1_NRAGEN","GX1_CDMTR"})

	oModel:AddGrid("GFEA517_GWZ","GFEA517_GWV",oStructGWZ,/*bLinePre*/,/*bLinePost*/,/*bPre*/,/*bPost*/,/*bLoad*/)
	oModel:SetRelation("GFEA517_GWZ",{{"GWZ_FILIAL",'xFilial("GWZ")'},{"GWZ_NRAGEN","GWV_NRAGEN"}},"GWZ_FILIAL+GWZ_NRAGEN")
	oModel:SetPrimaryKey({"GWV_FILIAL","GWV_NRAGEN"})
	oModel:GetModel("GFEA517_GWZ"):SetDelAllLine(.T.)
	oModel:GetModel("GFEA517_GWZ"):SetUniqueLine({"GWZ_FILIAL","GWZ_NRAGEN","GWZ_CDVISI"})

	oModel:AddGrid("GFEA517_GWY","GFEA517_GWV",oStructGWY,/*bLinePre*/,/*bLinePost*/,/*bPre*/,/*bPost*/,/*bLoad*/)
	oModel:SetRelation("GFEA517_GWY",{{"GWY_FILIAL",'xFilial("GWY")'},{"GWY_NRAGEN","GWV_NRAGEN"}},"GWY_FILIAL+GWY_NRAGEN")
	oModel:SetPrimaryKey({"GWV_FILIAL","GWV_NRAGEN"})
	oModel:GetModel("GFEA517_GWY"):SetDelAllLine(.T.)
	oModel:GetModel("GFEA517_GWY"):SetUniqueLine({"GWY_FILIAL","GWY_NRAGEN","GWY_CDTPVC"})

	oModel:SetOptional("GFEA517_GWW", .T. )
	oModel:SetOptional("GFEA517_GWX", .T. )
	oModel:SetOptional("GFEA517_GX1", .T. )
	oModel:SetOptional("GFEA517_GWZ", .T. )
	oModel:SetOptional("GFEA517_GWY", .T. )

	oModel:setVldActivate({|oModel| GFEA517VLD(oModel)})

Return oModel

Static Function ViewDef()
	Local oModel 		:= FWLoadModel("GFEA517")
	Local oView
	Local oStructGWV 	:= FWFormStruct(2,"GWV")
	Local oStructGWW 	:= FWFormStruct(2,"GWW")
	Local oStructGWX 	:= FWFormStruct(2,"GWX")
	Local oStructGX1 	:= FWFormStruct(2,"GX1")
	Local oStructGWZ 	:= FWFormStruct(2,"GWZ")
	Local oStructGWY 	:= FWFormStruct(2,"GWY")
	Local cGFE012		:= "2"

	oStructGWW:RemoveField( "GWW_FILIAL" )
	oStructGWW:RemoveField( "GWW_NRAGEN" )

	oStructGWX:RemoveField( "GWX_FILIAL" )
	oStructGWX:RemoveField( "GWX_NRAGEN" )

	oStructGX1:RemoveField( "GX1_FILIAL" )
	oStructGX1:RemoveField( "GX1_NRAGEN" )

	oStructGWZ:RemoveField( "GWZ_FILIAL" )
	oStructGWZ:RemoveField( "GWZ_NRAGEN" )

	oStructGWY:RemoveField( "GWY_FILIAL" )
	oStructGWY:RemoveField( "GWY_NRAGEN" )

	oView := FWFormView():New()
	oView:SetModel(oModel)
	oView:AddField( "GFEA517_GWV" ,oStructGWV )
	oView:AddGrid(  "GFEA517_GWW" ,oStructGWW )
	oView:AddGrid(  "GFEA517_GWX" ,oStructGWX )
	oView:AddGrid(  "GFEA517_GX1" ,oStructGX1 )
	oView:AddGrid(  "GFEA517_GWZ" ,oStructGWZ )
	oView:AddGrid(  "GFEA517_GWY" ,oStructGWY )
	If GFXPR12118("MV_GFE012")
		cGFE012 := SuperGetMv("MV_GFE012",.F.,"2")
	EndIf
	oView:CreateHorizontalBox( "MASTER" , 50 )
	oView:CreateHorizontalBox( "DETAIL" , 50 )

	oView:CreateFolder("IDFOLDER","DETAIL")
	oView:AddSheet("IDFOLDER","IDSHEET01",STR0010) //"Documentos de Carga"
	oView:AddSheet("IDFOLDER","IDSHEET02",STR0011) //"Endereços"
	oView:AddSheet("IDFOLDER","IDSHEET03",STR0012) //"Motoristas/Ajudantes"
	oView:AddSheet("IDFOLDER","IDSHEET04",STR0013) //"Visitantes"
	oView:AddSheet("IDFOLDER","IDSHEET05",STR0014) //"Tipos Veículos"

	oView:CreateHorizontalBox( "DETAILEND"  , 100,,,"IDFOLDER","IDSHEET02" )
	oView:CreateHorizontalBox( "DETAILMOT"  , 100,,,"IDFOLDER","IDSHEET03" )
	oView:CreateHorizontalBox( "DETAILVIS"  , 100,,,"IDFOLDER","IDSHEET04" )
	oView:CreateHorizontalBox( "DETAILTPV"  , 100,,,"IDFOLDER","IDSHEET05" )

	oView:CreateVerticalBox( "EMBAIXOESQ", 90,,,"IDFOLDER","IDSHEET01"   )
	oView:CreateVerticalBox( "EMBAIXODIR", 10,,,"IDFOLDER","IDSHEET01"  )

	oView:SetOwnerView( "GFEA517_GWV" , "MASTER" )
	oView:SetOwnerView( "GFEA517_GWW" , "EMBAIXOESQ")
	oView:SetOwnerView( "GFEA517_GWX" , "DETAILEND" )
	oView:SetOwnerView( "GFEA517_GX1" , "DETAILMOT" )
	oView:SetOwnerView( "GFEA517_GWZ" , "DETAILVIS" )
	oView:SetOwnerView( "GFEA517_GWY" , "DETAILTPV" )

	oView:AddOtherObject("OTHER_PANEL", {|oPanel,oModel| GFEA517DOC(oPanel,oModel)})
	oView:SetOwnerView("OTHER_PANEL","EMBAIXODIR")

Return oView

Function GFEA517CAN()
	Local oDlg
	Local oGet
	Local cMovCan

	If GWV->GWV_SIT == "3"
		Help( ,, 'HELP',,"Agendamento já cancelado!", 1, 0)
		Return .F.
	EndIf

	DEFINE MSDIALOG oDlg TITLE STR0015 From 4,0 To 18,61 OF oMainWnd //"Motivo Cancelamento"
	@ 08,08  SAY STR0016 SIZE 70,7 PIXEL OF oDlg //"Agendamento:"
   	@ 05,52  MSGET GWV->GWV_NRAGEN When .F. Picture "@!" Of oDlg Pixel

	    oTMultiget1 := TMultiget():New(22,09,{|u| If(Pcount()>0,cMovCan:=u,cMovCan)},;
	                           oDlg,225,60,,,,,,.T.)

		oButtonOK   := tButton():New(89,9,'OK',oDlg,{|| if(GFEA517OK(cMovCan),oDlg:End(),NIL)},30,10,,,,.T.)
		oButtonCanc := tButton():New(89,45,STR0017,oDlg,{||(oDlg:End())},30,10,,,,.T.) //"Cancelar"

	ACTIVATE MSDIALOG oDlg

Return .T.

Function GFEA517OK(cMovCan)
Local cNrAgen := ""
Local aRetRom    := Nil
Local lMV_AGRORI  := SuperGetMv("MV_AGRORI",.F.,.T.) 
Local lMV_SIGAAGR := SuperGetMv("MV_SIGAAGR",.F.,.T.)

	If SuperGetMv("MV_MOTCAN",,"1") $ "1;S" .And. Empty(cMovCan)
		Help( ,, 'HELP',,STR0018, 1, 0) //"Motivo para o cancelamento deve ser informado."
		Return .F.
	EndIf

	RecLock("GWV",.F.)
		GWV->GWV_SIT    := "3"
		GWV->GWV_MOTCAN := cMovCan
		GWV->GWV_USUCAN := cUserName
	MsUnLock("GWV")
	//Busca o numero do romaneio AGRO a partir do agendamento GFE
	//aRetRom[1] = Numero do romaneio
	//aRetRom[2] = Codigo Tipo de operação AGRO	
	cNrAgen := GWV->GWV_NRAGEN
	If lMV_AGRORI == .T. .And. lMV_SIGAAGR == .T.
		If FindFunction("AGRRomDoAg")
			aRetRom := AGRRomDoAg(cNrAgen)
		EndIf
	EndIf
	
    If empty(aRetRom)
    	GFECAEMAIL(cMovCan)
    EndIf
Return .T.

Function GFEA517PAR()
	Local cFiltro
	Local cAgen := ""
	Local aArea := GWV->( GetArea() )

	If !Pergunte("GFEA517",.T.)
		Return .F.
	Else
		GWV->( dbSetOrder(1) )
		GWV->( dbSeek(xFilial("GWV")) )
		While !GWV->( Eof() ) .And. GWV->GWV_FILIAL == xFilial("GWV")

			If	(GWV->GWV_NRAGEN >= MV_PAR01 .And. GWV->GWV_NRAGEN <= MV_PAR02) .And.;
				(GWV->GWV_CDEMIT >= MV_PAR03 .And. GWV->GWV_CDEMIT <= MV_PAR04) .And.;
				(GWV->GWV_CDOPER >= MV_PAR05 .And. GWV->GWV_CDOPER <= MV_PAR06) .And.;
				(GWV->GWV_DTAGEN >= MV_PAR07 .And. GWV->GWV_DTAGEN <= MV_PAR08) .And.;
				(GWV->GWV_HRAGEN >= MV_PAR09 .And. GWV->GWV_HRAGEN <= MV_PAR10)

				GWW->( dbSetOrder(1) )
				If GWW->( dbSeek(xFilial("GWW") + GWV->GWV_NRAGEN) )
					While !GWW->( Eof() ) .And. GWW->GWW_FILIAL == xFilial("GWW") .And. GWW->GWW_NRAGEN == GWV->GWV_NRAGEN
						If If(!Empty(MV_PAR11), 	GWW->GWW_NRDC >= MV_PAR11, .T.) .And. If(!Empty(MV_PAR12), GWW->GWW_NRDC <= MV_PAR12, .T.)
							If !(GWV->GWV_NRAGEN $ cAgen)
								cAgen += GWV->GWV_NRAGEN+";"
							EndIf
						EndIf

						GWW->( dbSkip() )
					EndDo
				Else
					If Empty(MV_PAR11)
						If !(GWV->GWV_NRAGEN $ cAgen )
							cAgen += GWV->GWV_NRAGEN+";"
						EndIf
					EndIf
				EndIf

			EndIf

			GWV->( dbSkip() )
		EndDo

		RestArea(aArea)

		cFiltro := " GWV_NRAGEN $ '" + cAgen + "'"

		oBrowse:SetFilterDefault(cFiltro)
		oBrowse:Refresh()
	EndIf

Return .T.

Function GFEA517EXC()
	lRet := .T.

	If GWV->GWV_SIT == "1"
		FWExecView("",'GFEA517',5,,{||.T.})
	Else
		Help( ,, 'HELP',,STR0019, 1, 0) //"Apenas agendamentos com o status aberto podem ser excluídos."
		lRet := .F.
	Endif
Return lRet

Function GFEA517TP()
	Local cRetorno := "1"
	GU3->(dbSetOrder(1))
	If GU3->(dbSeek(xFilial("GU3")+FwFldGet("GWV_CDEMIT")))
		If GU3->GU3_TRANSP == "1"
			cRetorno := "1"
		ElseIf GU3->GU3_CLIEN == "1"
			cRetorno := "2"
		ElseIf GU3->GU3_FORN == "1"
			cRetorno := "3"
		ElseIf GU3->GU3_AUTON == "1"
			cRetorno := "4"
		EndIf
	EndIf

Return cRetorno

Function GFEA517GWW(oModel)
	Local lRet 	  := .T.
	Local nLine 	  := oModel:getLine()
	Local aAreaGWW  := GWW->( GetArea() )
	Local aAreaGW1  := GW1->( GetArea() )
	Local aAreaGWV  := GWV->( GetArea() )
	Local lRoman 	  := SuperGetMv("MV_GFEPP04",.F.,.T.)
	Local cNRROM	  := ""
	Local nI		  := 0
	Local aAreaGXA  := GXA->( GetArea() )
	Local aAreaGX3  := GX3->( GetArea() )
	Local cChaveGWW := FwFldGet("GWW_CDTPDC",nLine)+FwFldGet("GWW_EMISDC",nLine)+FwFldGet("GWW_SERDC",nLine)+FwFldGet("GWW_NRDC",nLine)
	Local cTpDc	  	:= FwFldGet("GWW_CDTPDC",nLine)
	Local cEmiDc	:= FwFldGet("GWW_EMISDC",nLine)
	Local cSerDc	:= FwFldGet("GWW_SERDC",nLine)
	Local cNrDc	  	:= FwFldGet("GWW_NRDC",nLine)
	Local cChaveGWW := cTpDc + cEmiDc + cSerDc + cNrDc
	Local cGFE012	:= "2"

	If GFXPR12118("MV_GFE012")
		cGFE012 := SuperGetMv("MV_GFE012",.F.,"2")
	EndIf
	 
  //Valida se o Número do Documento de Carga é valido na troca de linha
	GW1->(dbSetOrder(8))
	If !GW1->(dbSeek(xFilial("GW1")+cNrDc))
		Help( ,, 'HELP',, STR0020, 1, 0) //"Número do Documento de Carga inexistente"
		lRet :=  .F.
	Endif

	If lRet
		//Valida se o Tipo de Documento para o Documento de Carga é valido na troca de linha
		GV5->(dbSetOrder(1))
		If !GV5->(dbSeek(xFilial("GV5")+cTpDc))
			Help( ,, 'HELP',, STR0021, 1, 0) //"Tipo de Documento de Carga Invalido"
			lRet := .F.
		EndIf
	EndIf

	If lRet
		//Valida se o Emissor do Documento de Carga é valido na troca de linha
		GU3->(dbSetOrder(1))
		If !GU3->(dbSeek(xFilial("GU3")+cEmiDc))
			Help( ,, 'HELP',, STR0022, 1, 0) //"Emitente Informando não existe"
			lRet := .F.
		EndIf
	EndIf

	If lRet		
		GW1->(dbSetOrder(1))
		If !GW1->(dbSeek(xFilial("GW1")+cTpDc+cEmiDc+cSerDc+cNrDc))
			Help( ,, 'HELP',, STR0023, 1, 0) //"Série do Documento de Carga não existe"
			lRet := .F.
		Elseif cGFE012 != "0"
			If Empty(GW1->GW1_NRROM) 
				Help( ,, 'HELP',, STR0024, 1, 0) //"Documento de Carga não está vinculado a um romaneio"
				lRet := .F.
			Else				
				GWN->(  dbSetOrder(1) )
				If GWN->( dbSeek(xFilial("GWN")+GW1->GW1_NRROM) )
					cNRROM := GW1->GW1_NRROM
					If !(GWN->GWN_SIT $ '3;4') .and. cGFE012 == "2"
						Help( ,, 'HELP',, "Documento de carga deve estar vinculado a um romaneio que esteja 'Liberado' ou 'Encerrado'.", 1, 0) 
						lRet := .F.
					Endif
				Else					
					Help( ,, 'HELP',, "Romaneio do documento de carga não existe.", 1, 0)
					lRet := .F.				
				Endif
			Endif
		EndIf
	EndIf

	If lRet
		GWW->( dbSetOrder(2) )
		If GWW->( dbSeek(xFilial("GWW")+cTpDc+cEmiDc+cSerDc+cNrDc) )
			GWV->( dbSetOrder(1) )
			If GWV->( dbSeek(xFilial("GWV") + GWW->GWW_NRAGEN) )
				If GWV->GWV_SIT != "3"
					Help( ,, 'HELP',, STR0026, 1, 0) //"Documento de carga já esta vinculado a outro agendamento"
					RestArea(aAreaGWV)
					lRet := .F.
				EndIf
			EndIf
		EndIf
	EndIf

	GXA->( dbSetOrder(2) )
	GX3->( dbSetOrder(1) )
	If GXA->(dbSeek(xFilial("GXA")+cChaveGWW))
		While !GXA->(Eof()) .And. xFilial("GXA")+cChaveGWW == GXA->(GXA_FILIAL+GXA_CDTPDC+GXA_EMISDC+GXA_SERDC+GXA_NRDC) .And. GX3->(dbSeek(GXA->(GXA_FILIAL+GXA_NRMOV)))
			If GX3->GX3_SIT != "5"
				Help( ,, 'HELP',, "Documento de carga já esta vinculado a outra movimentação", 1, 0)
				RestArea(aAreaGXA)
				RestArea(aAreaGX3)
				lRet := .F.
			EndIf
			GXA->(dbSkip())
		EndDo
	EndIf

	// valida o parâmetro "Permite relacionar mais de 1 romaneio nas movimentações" - .
	If lRet .And. !lRoman
		If oModel:GetQtdLine() > 1
			For nI := 1 To oModel:GetQtdLine()
				oModel:GoLine( nI )

				If !oModel:IsDeleted()
					GW1->( dbSetOrder(1) )
					If GW1->( dbSeek(xFilial("GW1")+FwFldGet("GWW_CDTPDC")+FwFldGet("GWW_EMISDC")+FwFldGet("GWW_SERDC")+FwFldGet("GWW_NRDC")) )
						If GW1->GW1_NRROM != cNRROM
							// mais de 1 romaneio
							Help( ,, 'HELP',, "Não podem ser informados documentos de carga de diferentes romaneios.", 1, 0)
							lRet := .F.
						EndIf
					EndIf
				EndIf
			Next nI
			oModel:GoLine( nLine )
		EndIf
	EndIf

	RestArea(aAreaGWV)
	RestArea(aAreaGW1)
	RestArea(aAreaGWW)
	RestArea(aAreaGXA)
	RestArea(aAreaGX3)
Return lRet

Function GFEA517GWX()

	GVD->(DbSetOrder(1))
	If GVD->(DbSeek(xFilial("GVD")+M->GWX_CDENDE))
		If GVD->GVD_SIT <> "1"
			Help( ,, 'HELP',, STR0027, 1, 0) // "O endereço informado está com situação igual a 'Inativo'"
			Return .F.
		EndIf
	EndIf
	
Return .T.

//----------------------------------------------------

Function GFEA517Cpo(nTpEmit)
	Local cCampo  := ReadVar()
	Local cCdEmit := PadR(&cCampo,TamSX3("GVM_CDEMIT")[1])
	Local cTpEmit := AllTrim(Str(nTpEmit))
	Local cMsg    := ""

	// O Emitente deve ser Transportador ou Autônomo
	If nTpEmit == 1
		GU3->(DbSetOrder(1))
		If GU3->(DbSeek(xFilial('GU3')+cCdEmit))
			If GU3->GU3_SIT != "1"
				Help( ,, 'HELP',, "Emitente não está ativo.", 1, 0)
				Return .F.
			ElseIf GU3->GU3_TRANSP == "2" .And. GU3->GU3_AUTON == "2"
				Help( ,, 'HELP',, "Emitente não é transportador.", 1, 0)
				Return .F.
			EndIf
		EndIf
	EndIf

	// Verifica se existe algum tipo de restrição cadastrado para o emitente
	GVM->(DbSetOrder(1))
	If GVM->(DbSeek(xFilial("GVM")+cTpEmit+cCdEmit)) .And.;
	   dDataBase >= GVM->GVM_DTINRE .And. Iif(!Empty(GVM->GVM_DTFIRE), dDataBase <= GVM->GVM_DTFIRE , .T.)

		If GVM->GVM_IDBLOQ == "1"
			// Emitente#Motorista/Ajudante#Visitante está bloqueado no cadastro de restrições,
			// portanto, não pode ser incluído em Agendamentos ou Movimentações.
			// Motivo:
			// ##########
			cMsg := Iif(nTpEmit==1,STR0049,Iif(nTpEmit==2,STR0028,STR0051)) + CRLF + CRLF
			cMsg += STR0056 + CRLF
			cMsg += AllTrim(GVM->GVM_RESTRI)
			Help(,,"HELP",,cMsg,1,0)
			Return .F.
		Else
			// Emitente#Motorista/Ajudante#Visitante está cadastrado no programa de restrições.
			// Motivo:
			// ##########
			cMsg := Iif(nTpEmit==1,STR0050,Iif(nTpEmit==2,STR0029,STR0052)) + CRLF + CRLF
			cMsg += STR0056 + CRLF
			cMsg += AllTrim(GVM->GVM_RESTRI)
			MsgAlert(cMsg,STR0030)
		EndIf

	EndIf

Return .T.

Function GFEA517CON()
	Local dData := dDataBase
	Local cHora := Space(TamSX3("GWV_HRCONF")[1])

	If GWV->GWV_IDENVI == '1' // Se enviou o e-mail
		If AllTrim(cValToChar(GWV->GWV_DTCONF)) == "//" .Or. AllTrim(GWV->GWV_HRCONF) == ""
			DEFINE MSDIALOG oDlg TITLE "Confirmar" From 4,0 To 09,36 OF oMainWnd

				@ 5, 16 Say "Data" OF oDlg Pixel
				@ 5, 76 Say "Hora" OF oDlg Pixel

				oData := TGet():New(04,30,bSETGET(dData),oDlg,45,09,"",,0,,,.F.,,.T.,,.F.,,.F.,.F.,,.F.,.F.,,'dData',,,,.T.)
				oHora := TGet():New(04,90,bSETGET(cHora),oDlg,10,09,"@R 99:99",,0,,,.F.,,.T.,,.F.,,.F.,.F.,,.F.,.F.,,'cHora',,,,)

				oButtonOK   := tButton():New(19,30,'OK',oDlg,{|| GFEA517CDT(dData,cHora) },40,10,,,,.T.)
				oButtonCanc := tButton():New(19,75,STR0007,oDlg,{||(oDlg:End())},40,10,,,,.T.)

			ACTIVATE MSDIALOG oDlg
		Else
			MsgAlert('Este agendamento já foi confirmado.','Atenção')
		EndIf
	Else
		MsgAlert('Necessário enviar e-mail para poder confirmar um agendamento.','Atenção')
	EndIf

Return

Function GFEA517CDT(dData,cHora)
	If AllTrim(cValToChar(dData)) == "//" .Or. AllTrim(cHora) == ""
		MsgAlert('Campo Data e Hora devem ser informados.','Atenção')
	Else
		RecLock("GWV",.F.)
			GWV->GWV_DTCONF := dData
			GWV->GWV_HRCONF := cHora
			GWV->GWV_IDCONF := "1"
		MsUnlock("GWV")

		oDlg:End()

		MsgAlert('Confirmação realizada com sucesso.','Aviso')
	EndIf
Return

//----------------------------------------------------

Function GFEA517POS(oModel)
	Local nI        := 0
	Local nLineaUX  := 0
	Local nPesoIten := 0
	Local nPesoVeic := 0
	Local lIten     := .F.
	Local lVeic     := .F.
	Local nOpc      := (oModel:GetOperation())

	If nOpc == MODEL_OPERATION_UPDATE
		If FwFldGet("GWV_IDCONF") == "1"
			If Empty(FwFldGet("GWV_DTCONF")) .Or. Empty(FwFldGet("GWV_HRCONF"))
				Help( ,, 'HELP',, STR0031, 1, 0) //"Deve-se ser informados a Data e a Hora da confirmação."
				Return .F.
			Endif
		Endif
	Endif

	If nOpc == MODEL_OPERATION_DELETE
		DelTabFilho("GWW", oModel)
		DelTabFilho("GWX", oModel)
		DelTabFilho("GX1", oModel)
		DelTabFilho("GWZ", oModel)
		DelTabFilho("GWY", oModel)
	Else
		oModelGWW := oModel:GetModel( "GFEA517_GWW" )
		nLineaUX  := oModelGWW:nLine
		For nI := 1 To oModelGWW:GetQtdLine()
			oModelGWW:GoLine( nI )

			If !oModelGWW:IsDeleted()
				GW1->( dbSetOrder(1) )
				If GW1->( dbSeek(xFilial("GW1")+FwFldGet("GWW_CDTPDC")+FwFldGet("GWW_EMISDC")+FwFldGet("GWW_SERDC")+FwFldGet("GWW_NRDC")) )
					GW8->( dbSetOrder(1) )
					GW8->( dbSeek(xFilial("GW8")+GW1->GW1_CDTPDC+GW1->GW1_EMISDC+GW1->GW1_SERDC+GW1->GW1_NRDC) )
					While GW8->( !Eof() )  .And. xFilial("GW8") == GW8->GW8_FILIAL .And. GW8->GW8_CDTPDC == GW1->GW1_CDTPDC .And. GW8->GW8_EMISDC == GW1->GW1_EMISDC .And. GW8->GW8_SERDC == GW1->GW1_SERDC .And. GW8->GW8_NRDC == GW1->GW1_NRDC
						If GW8->GW8_PESOR >= GW8->GW8_PESOC
							nPesoIten += GW8->GW8_PESOR
						ElseIf GW8->GW8_PESOR <= GW8->GW8_PESOC
							nPesoIten += GW8->GW8_PESOC
						Endif
						lIten := .T.

						GW8->( dbSkip() )
					EndDo
				EndIf
			EndIf

		Next
		oModelGWW:GoLine( nLineaUX )

		oModelGWY := oModel:GetModel( "GFEA517_GWY" )
		nLineaUX  := oModelGWY:nLine
		For nI := 1 To oModelGWY:GetQtdLine()
			oModelGWY:GoLine( nI )

			If !oModelGWY:IsDeleted()
				If !Empty(FwFldGet("GWY_CDTPVC"))
					GV3->(dbSetOrder(1))
					If GV3->(dbSeek(xFilial("GV3")+FwFldGet("GWY_CDTPVC")))
						nPesoVeic += GV3->GV3_CARGUT
						lVeic     := .T.
					EndIf
				EndIf
			EndIf

		Next
		oModelGWY:GoLine( nLineaUX )

		If lIten .And. lVeic
			If nPesoIten > nPesoVeic
				Help( ,, 'HELP',, STR0032 + Alltrim(STR(nPesoIten)) + STR0033 + AllTrim(STR(nPesoVeic)) + "", 1, 0) //"O peso dos itens somados ultrapassou a capacidade do veiculo informado. Peso Itens: " ###	" <> Carga Util Veiculo : "
				Return .F.
			EndIf
		Endif

		If AllTrim(Posicione("GVI",1,xFilial("GVI") + FwFldGet("GWV_CDOPER") + FwFldGet("GWV_SEQ"),"GVI_CDOPER")) == ""
			Help( ,, 'HELP',, "Configuração da Operação não cadastrada.", 1, 0)
			Return .F.
		EndIf

	EndIf

Return .T.

Function GFEA517ENV()
	If isblind()
		GFEENEMAIL()
	Else
		Processa({|lEnd| GFEENEMAIL()},"Enviando e-mail...","Aguarde")
	EndIf
Return .T.

Function GFEENEMAIL()
	Local cPara
	Local cAssunto
	Local cMensagem
	Local dData
	Local cHora
	Local aRetMail  	:= {}
	Local s_GFEA5172 	:= ExistBlock("GFEA5172")
	Local lreenviar := .F.
	If GWV->GWV_SIT $ "2;3"
		MsgAlert('Envio de E-mail não pode ser realizado, agendamento deve estar aberto.','Aviso')
		Return .F. 
	Endif
	
	If GWV->GWV_IDENVI == "1"  .and. MsgYesNo("Solicitação de confirmação de agendamento já foi enviada, deseja reenviar?")
		lreenviar := .T. 
	Endif
	
	If GWV->GWV_IDENVI <> "1" .or. lreenviar
		dData := Substring(DTOS(GWV->GWV_DTAGEN),7,2)
		dData += "/" + Substring(DTOS(GWV->GWV_DTAGEN),5,2)
		dData += "/" + Substring(DTOS(GWV->GWV_DTAGEN),1,4)
		 
		cHora := Substring(GWV->GWV_HRAGEN,1,2)
		cHora += ":" + Substring(GWV->GWV_HRAGEN,3,2)
		
		If GFXCP12123("GWV_EMAIL") .And. GFXCP12123("GU2_RECAGE")
			cPara := GWV->GWV_EMAIL 
		Else
			cPara := Posicione("GU3",1,xFilial("GU3")+GWV->GWV_CDEMIT,"GU3_EMAIL") 
		EndIf

		If Empty(cPara)
			Help( ,, 'HELP',, STR0034 + Alltrim(GWV->GWV_CDEMIT) + STR0035, 1, 0) //"Emitente " ### " não possui email cadastrado"
			Return .F.   		
		Endif
		
		cAssunto  := STR0036 //"Confirmação de Agendamento"
		cMensagem := STR0037 + GWV->GWV_NRAGEN + STR0038 + GWV->GWV_CDEMIT + STR0039 + GWV->GWV_CDOPER + " " //"O Agendamento nr " ### ", do Emitente " ### ", da operação "
		cMensagem += StrTran(STR0040,"[id_type]",{STR0053, STR0054}[Val(GWV->GWV_IDTIPO)]) + dData + STR0041 + cHora + STR0042 //"Tipo [id_tipo], para o dia " ### "Esporádico" ### "Recorrente" ###" às " ### " está programado para ser realizado. "
		cMensagem += STR0043 + CRLF + CRLF + CRLF //"Favor confirmar esta operação. Caso haja algum problema ou divergência, favor entrar em contato."
		cMensagem += STR0044 //"Obrigado"
			
		If s_GFEA5172
			aRetMail := ExecBlock("GFEA5172", .F., .F., { GWV->GWV_FILIAL, GWV->GWV_NRAGEN, cPara, cMensagem, cAssunto, GWV->GWV_SIT})
			If ValType(aRetMail) == "A" .and. len(aRetMail) > 0 
				cPara 	  := aRetMail[1,1]
				cMensagem := aRetMail[1,2]
				cAssunto  := aRetMail[1,3]
			EndIf
		EndIf

		If GFEEnvMail(cPara,cAssunto,cMensagem, .T.)
			RecLock("GWV",.F.)
			GWV_IDENVI := "1"
			GWV_DTENVI := DDATABASE
			GWV_HRENVI := TIME()
			MsUnLock("GWV")
			MsgAlert('Envio de E-mail realizado com sucesso.','Aviso')
		EndIf
	EndIf

Return    

Static Function GFEA517DOC(oPanel,oView)
	Local lOk := .F.

	//@ nLinha,nColuna BUTTON cTexto SIZE nLargura,nAltura UNIDADE OF oObjetoRef ACTION AÇÃO
	@ 10, 10 Button STR0046 Size 36, 13 Message STR0047 Pixel Action GFEA517CRG(FwFldGet("GWW_CDTPDC",1),FwFldGet("GWW_EMISDC",1),FwFldGet("GWW_SERDC",1),FwFldGet("GWW_NRDC",1)) of oPanel //"Doc.Relac." ### "Documentos Relacionados"

Return .T.

Static Function GFEA517CRG(cCdTpDc,cEmisDc,cSerDc,nNrdoc)
	Local aAreaGW1
	Local oModelGWV := FWMODELACTIVE()
	Local oModelGWW := oModelGWV:GetModel("GFEA517_GWW")
	Local nI        := 0
	Local nLineaUX  := 0
	Local oView     := FWViewActive()
	Local lExist    := .F.
	Local nLine 	  := oModelGWW:nLine


	If AllTrim( FwFldGet("GWV_NRROM") ) == ""

		GW1->( dbSetOrder(1) )
		If GW1->( dbSeek(xFilial("GW1")+cCdTpDc+cEmisDc+cSerDc+nNrdoc) )
			GWN->( dbSetOrder(1) )
			If GWN->( dbSeek(xFilial("GWN")+GW1->GW1_NRROM))

				aAreaGW1 := GW1->(GetArea())
					GW1->( dbSetOrder(9) )
					GW1->( dbSeek(xFilial("GW1")+GWN->GWN_NRROM))
					While GW1->( !Eof() ) .And. xFilial("GW1") == GW1->GW1_FILIAL .And. GW1->GW1_NRROM == GWN->GWN_NRROM
						lExist := .F.

						nLineaUX := oModelGWW:nLine
						For nI := 1 To oModelGWW:GetQtdLine()
							oModelGWW:GoLine(nI)
							If !oModelGWW:IsDeleted()
								If FwFldGet("GWW_CDTPDC") == GW1->GW1_CDTPDC .And. FwFldGet("GWW_EMISDC") == GW1->GW1_EMISDC .And. FwFldGet("GWW_SERDC") == GW1->GW1_SERDC .And. FwFldGet("GWW_NRDC") == GW1->GW1_NRDC
									lExist := .T.
									Exit
							   	EndIf
							EndIf
						Next
						oModelGWW:GoLine( nLineaUX )

						If !lExist
							If !oModelGWW:IsEmpty()
								oModelGWW:AddLine()
							EndIf
							oModelGWW:SetValue('GWW_CDTPDC',	GW1->GW1_CDTPDC)
							oModelGWW:SetValue('GWW_EMISDC',	GW1->GW1_EMISDC)
							oModelGWW:SetValue('GWW_SERDC',		GW1->GW1_SERDC)
							oModelGWW:SetValue('GWW_NRDC',		GW1->GW1_NRDC)

							If lCpoSrGWW
								oModelGWW:SetValue('GWW_SDOC',	GW1->GW1_SDOC)
							EndIf

							If !oModelGWW:VldLineData()
								Help(,,'HELP',,GW1->GW1_NRDC + ": " + oModelGWV:Geterrormessage(.T.)[6],1,0)
								Exit
							EndIf
						EndIf

						GW1->( dbSkip() )
					EndDo

				RestArea(aAreaGW1)

			EndIf
		EndIf

	Else

		// Busca de Romaneios
		GW1->( dbSetOrder(9) )
		GW1->( dbSeek( xFilial("GW1") + FwFldGet("GWV_NRROM") ) )
		While GW1->( !Eof() ) .And. xFilial("GW1") == GW1->GW1_FILIAL .And. GW1->GW1_NRROM == FwFldGet("GWV_NRROM")

			lExist := .F.

			nLineaUX := oModelGWW:nLine
			For nI := 1 To oModelGWW:GetQtdLine()
				oModelGWW:GoLine(nI)
				If !oModelGWW:IsDeleted()
					If FwFldGet("GWW_CDTPDC") == GW1->GW1_CDTPDC .And. FwFldGet("GWW_EMISDC") == GW1->GW1_EMISDC .And. FwFldGet("GWW_SERDC") == GW1->GW1_SERDC .And. FwFldGet("GWW_NRDC") == GW1->GW1_NRDC
						lExist := .T.
						Exit
				   	EndIf
				EndIf
			Next
			oModelGWW:GoLine( nLineaUX )

			If !lExist
				If !oModelGWW:IsEmpty()
					oModelGWW:AddLine()
				EndIf
				oModelGWW:SetValue('GWW_CDTPDC',	GW1->GW1_CDTPDC)
				oModelGWW:SetValue('GWW_EMISDC',	GW1->GW1_EMISDC)
				oModelGWW:SetValue('GWW_SERDC',		GW1->GW1_SERDC)
				oModelGWW:SetValue('GWW_NRDC',		GW1->GW1_NRDC)

				If lCpoSrGWW
					oModelGWW:SetValue('GWW_SDOC',	GW1->GW1_SDOC)
				EndIf

				If !oModelGWW:VldLineData()
					Help(,,'HELP',,GW1->GW1_NRDC + ": " + oModelGWV:GetErrorMessage(.T.)[6],1,0)
					Exit
				EndIf
			EndIf

			GW1->( dbSkip() )
		EndDo

	EndIf

	oModelGWW:GoLine( nLine )

	oView:Refresh()

Return .T.

//------------------------------------

Function GFEA517VLD(oModel)
	Local nOp := oModel:GetOperation()

	If nOp == MODEL_OPERATION_UPDATE
		If GWV->GWV_SIT $ "2;3"
			Help( ,, 'HELP',, STR0055, 1, 0) //"Só pode ser alterado um agendamento com status 'Aberto'."
			Return .F.
		EndIf
	EndIf

Return .T.

// Prepara campos para chamar tela de escolha de Doc. Carga, caso exista mais de um com as seguintes chaves em parâmetro
Static Function GFE517PreT(oModel)
	Local nLine 		:= oModel:getLine()
	Local oModelGWV 	:= FWMODELACTIVE()
	Local oModelGWW 	:= oModelGWV:GetModel("GFEA517_GWW")
	Local oView     	:= FWViewActive()
	Local cTpDc		:= FwFldGet("GWW_CDTPDC",nLine)
	Local cEmiDc		:= FwFldGet("GWW_EMISDC",nLine)
	Local cSerDc		:= FwFldGet("GWW_SERDC",nLine)
	Local cNrDc		:= FwFldGet("GWW_NRDC",nLine)
	Local aRet			:= {}

	If TamSx3("GWW_SERDC")[1] == 14
		aRet := GFE517TLDC( cNrDc , cTpDc , cEmiDc , cSerDc )

		If Len(aRet) > 0
			If !oModelGWW:IsDeleted()
				oModelGWW:GoLine( nLine )

				oModelGWW:SetValue('GWW_CDTPDC',	aRet[6])
				oModelGWW:SetValue('GWW_EMISDC',	aRet[2])
				oModelGWW:SetValue('GWW_SERDC',		aRet[4])
				oModelGWW:SetValue('GWW_NRDC',		aRet[5])
			EndIf

			oView:Refresh()
		EndIf
	EndIf

Return Nil


Function GFEA517SDC(NrDoc, TpDc, Emiss, Serie, cFilGW1)
	Local lRet      := .T.
	Local aDoc      := {}
	Local cAliasGW1 := GetNextAlias()
	Local cWhere    := ""

	Default cFilGW1 := xFilial("GW1")
	
	cWhere :=   ""
	If !Empty(cFilGW1)
		cWhere += " AND GW1.GW1_FILIAL = '"+cFilGW1+"'"
	EndIf
	If !Empty(TpDc)
		cWhere += " AND GW1.GW1_CDTPDC = '"+TpDc+"'"
	EndIf
	If !Empty(Emiss)
		cWhere += " AND GW1.GW1_EMISDC = '"+Emiss+"'"
	EndIf
	cWhere := "%"+cWhere+"%"
	
	BeginSql Alias cAliasGW1
		SELECT GW1.GW1_EMISDC,
				GU3.GU3_NMEMIT,
				GW1.GW1_SERDC,
				GW1.GW1_NRDC,
				GW1.GW1_CDTPDC,
				GW1.GW1_DTEMIS,
				GW1.R_E_C_N_O_ RECNOGW1
		FROM %Table:GW1% GW1
		INNER JOIN %Table:GU3% GU3
		ON GU3.GU3_FILIAL = %xFilial:GU3%
		AND GU3.GU3_CDEMIT = GW1.GW1_EMISDC
		AND GU3.%NotDel%
		WHERE GW1.GW1_SDOC = %Exp:Substr(Serie,1,3)%  // caso problemas com SDOC em branco, é erro da conversão do materiais
		AND GW1.GW1_NRDC = %Exp:NrDoc%
		AND %Exp:cWhere%
		AND GW1.%NotDel%
		ORDER BY GW1.GW1_DTEMIS DESC
	EndSql
	If (cAliasGW1)->(!Eof())
		lRet := .T.
		Do While (cAliasGW1)->(!Eof())
			AAdd(aDoc, { .F.,;
						(cAliasGW1)->GW1_EMISDC,;
						(cAliasGW1)->GU3_NMEMIT,;
						(cAliasGW1)->GW1_SERDC,;
						(cAliasGW1)->GW1_NRDC,;
						(cAliasGW1)->GW1_CDTPDC,;
						(cAliasGW1)->GW1_DTEMIS,;
						(cAliasGW1)->GW1_RECNO})
			(cAliasGW1)->(dbSkip())
		EndDo
	EndIf
	(cAliasGW1)->(dbCloseArea())
Return aDoc

/*
{Protheus.doc} GFE517TLDC
Escolhe Doc. Carga caso exista mais de um Doc. Carga com a SERIE e Nr Documento

@author Helder Fuckner dos Santos
@since 20/05/2015
*/
Function GFE517TLDC(NrDoc, TpDc, Emiss, Serie)
	Local oDlg
	Local oButton, oPanel, oPnl
	Local oSize
	Local cNmEmit
	Local lRet
	Private oNo		:= LoadBitmap(GetResources(), "LBNO")
	Private oOk 		:= LoadBitmap(GetResources(), "LBTIK")
	Private aDoctos	:= {}
	Private aRetDoc	:= {}
	Private oBrwDc
	
	If Empty(NrDoc) .Or. Empty(TpDc) .Or. Empty(Emiss) .Or. Empty(Serie)
		Return aRetDoc
			EndIf

	If lEscolheDoc .And. TamSX3("GW1_SERDC")[1] == 14 

		aDoctos := GFEA517SDC(NrDoc, TpDc, Emiss, Serie)

		If Len(aDoctos) > 1
			// INI - Tela
			oSize := FWDefSize():New(.T.)
			oSize:AddObject( "ENCHOICE", 100, 60, .T., .T. ) // Adiciona enchoice
			oSize:SetWindowSize({000, 000, 300, 700})
			oSize:lLateral := .F.  // Calculo vertical
			oSize:Process() //executa os calculos

			DEFINE MSDIALOG oDlg TITLE "Escolha do Documento de Carga" ;
									FROM oSize:aWindSize[1],oSize:aWindSize[2] ;
									TO oSize:aWindSize[3],oSize:aWindSize[4] ;
									COLORS 0, 16777215 PIXEL

				// Adicionado FWLayer para adicionar rolagem ao formulário caso saia dos limites da resolução/tela
				oFWLayer := FWLayer():New()
				oFWLayer:Init(oDlg,.F.)
				oFWLayer:AddLine('LINET',002,.F.)
				oFWLayer:AddLine('LINE',096,.F.)
				oFWLayer:AddLine('LINEB',002,.F.)
				oFWLayer:AddCollumn('COLL',002,.T.,'LINE')
				oFWLayer:AddCollumn('COL',096,.T.,'LINE')
				oFWLayer:AddCollumn('COLR',002,.T.,'LINE')
				oPanel := oFWLayer:GetColPanel('COL','LINE')

				nTop := 79

				oPnl := TPanel():New(nTop,0,,oPanel,,,,,,100,15,.F.,.F.)
				oPnl:Align := CONTROL_ALIGN_TOP

				TSay():New(005,000,{|| "Selecione um Documento de Carga" },oPnl,,,,,,.T.,,,100,10,)

				nTop += 15

				oPnl := TPanel():New(nTop,0,,oPanel,,,,,,100,120,.F.,.F.)
				oPnl:Align := CONTROL_ALIGN_TOP

																// “Emissor”, “Série”, “Número”, “Tipo Doc Carga”, “Data de Emissão”
				oBrwDc := TWBrowse():New(010,000,200,90,,	{'','Emissor','Nome Emissor','Série','Nr Documento', 'Tipo Doc Carga','Dt. Emissão'},;
																{20,40,80,30,50,50,40},oPnl,,,,,{||},,,,,,,.F.,,.T.,,.F.,,,)
				oBrwDc:lHScroll := .F.
				oBrwDc:lVScroll := .T.
				oBrwDc:lDisablePaint := .F.
				oBrwDc:Align := CONTROL_ALIGN_TOP
				oBrwDc:SetArray(aDoctos)
				oBrwDc:bLine := {|oObj| GFE570BrLn(oObj) }
				oBrwDc:bLDblClick := {|| aDoctos[oBrwDc:nAt][1] := !aDoctos[oBrwDc:nAt][1],oBrwDc:DrawSelect()}

			oDLG:Activate(,,,.T.,,,{|| EnchoiceBar(oDlg, {|| If(GFE570VlFr(),oDlg:End(),nil)}, {||oDlg:End()},,)})
			// FIM - Tela

		Else
			// Atribui dados do Doc Carga GW1 na tabela GWW
			GFE570ATRI()
		EndIf

	EndIf

Return aRetDoc

//--------- Seleciona CheckBox
Function GFE570BrLn(oObj)
	Local aLine := { If(oObj:aArray[oObj:nAt,01],oOK,oNO), oObj:aArray[oObj:nAt,02], oObj:aArray[oObj:nAt,03],;
						Transform(oObj:aArray[oObj:nAt,04], "!!!"), oObj:aArray[oObj:nAt,05], oObj:aArray[oObj:nAt,06], oObj:aArray[oObj:nAt,07] }
Return aLine

//--------- Valida Frame
Function GFE570VlFr()
	Local lRet := .T.
	Local nCont:= 0
	Local nInd

	If lRet .And. aScan(aDoctos, {|x| x[1] == .T. }) == 0
	 	MsgStop("Você deve selecionar pelo menos um Documento de Carga.", "Atenção")
	 	lRet := .F.
	EndIf

	// INI - Valida se mais de um marcado
	For nInd := 1 To Len(aDoctos)
		If aDoctos[nInd][1] == .T.
			nCont += 1
		EndIf
	Next nInd

	If nCont > 1
	 	MsgStop("Você deve selecionar somente um Documento de Carga.", "Atenção")
	 	lRet := .F.
	EndIf
	// FIM - Valida se mais de um marcado

	If lRet
		GFE570ATRI()
	EndIf

Return lRet
//--------------------------------------------------------------------

Function GFE570ATRI()
	Local nPos

	nPos := aScan(aDoctos, {|x| x[1] == .T. })

	If Len(aDoctos) > 0
		If nPos > 0
			aRetDoc := aDoctos[nPos]
		Else
			aRetDoc := aDoctos[1]
		EndIf
	EndIf

Return Nil
/*/{Protheus.doc} GFEA517SVW
@author siegklenes.beulke
@since 30/09/2016
@version undefined
@param lMostra, logical, Indica se realiza a seleção
@example
(examples)
@see (links_or_references)
/*/
Function GFEA517SVW(lMostra)
	lEscolheDoc := lMostra
Return lMostra == lEscolheDoc

Static Function DelTabFilho(cTab, oModel)
	dbSelectArea(cTab)
	dbSetOrder(1)
	dbSeek(xFilial(cTab)+oModel:getValue("GFEA517_GWV","GWV_NRAGEN"))
	While !Eof().AND.;
		&(cTab + "->" + cTab + "_FILIAL") == xFilial("GWV").AND.;
		&(cTab + "->" + cTab + "_NRAGEN") == oModel:getValue("GFEA517_GWV","GWV_NRAGEN")
		RecLock(cTab,.F.)
			dbDelete()
		MsUnlock(cTab)
	
		dbSelectArea(cTab)
		dbSkip()
	EndDo

Return .T.

/*--------------------------------------------------------------------------------------
{Protheus.doc} FiltGW1RID

Query usada para melhorar a performance do filtro consulta padrão GW1RID

@since 08/02/2017
---------------------------------------------------------------------------------------*/

Function FiltGW1GFE()
	Local cFiltro := " "
	Local cGFE012 := "2"
	If GFXPR12118("MV_GFE012")
		cGFE012 := SuperGetMv("MV_GFE012",.F.,"2")
	EndIf	

	If cGFE012 != "0"
		cFiltro := "@EXISTS(SELECT GWN_SIT FROM " + RetSqlName('GWN')+ " GWN "
		cFiltro += " WHERE GWN.GWN_FILIAL = GW1_FILIAL " 
		cFiltro += " AND GWN.GWN_NRROM = GW1_NRROM "
		If cGFE012 == "2"
			cFiltro += " AND GWN.GWN_SIT IN ('3','4') "
		EndIf
		cFiltro += " AND D_E_L_E_T_ = ' ')"  
	EndIf
	
Return cFiltro


Function GFECAEMAIL(cMovCan)
	Local cPara
	Local cAssunto
	Local cMensagem
	Local dData
	Local cHora
	Local aRetMail  	:= {}
	Local s_GFEA5172 	:= ExistBlock("GFEA5172")

	If GWV->GWV_SIT == "3" .and. GWV->GWV_IDENVI == "1" 
		dData := Substring(DTOS(GWV->GWV_DTAGEN),7,2)
		dData += "/" + Substring(DTOS(GWV->GWV_DTAGEN),5,2)
		dData += "/" + Substring(DTOS(GWV->GWV_DTAGEN),1,4)
		 
		cHora := Substring(GWV->GWV_HRAGEN,1,2)
		cHora += ":" + Substring(GWV->GWV_HRAGEN,3,2)
		
		If GFXCP12123("GWV_EMAIL") .And. GFXCP12123("GU2_RECAGE")
			cPara := GWV->GWV_EMAIL 
		Else
			cPara := Posicione("GU3",1,xFilial("GU3")+GWV->GWV_CDEMIT,"GU3_EMAIL") 
		EndIf

		If Empty(cPara)
			Help( ,, 'HELP',, STR0034 + Alltrim(GWV->GWV_CDEMIT) + STR0035, 1, 0) //"Emitente " ### " não possui email cadastrado"
			Return .F.   		
		Endif
		
		cAssunto  := "** Agendamento Cancelado **"
		cMensagem := "O Agendamento nr: " + GWV->GWV_NRAGEN + ", do Emitente " + GWV->GWV_CDEMIT + ", da operação " + GWV->GWV_CDOPER + ", foi cancelado." + CRLF
		cMensagem += "Justificativa: " + cMovCan +  CRLF + CRLF + CRLF
		cMensagem += "Obrigado" 


		If s_GFEA5172
			aRetMail := ExecBlock("GFEA5172", .F., .F., { GWV->GWV_FILIAL, GWV->GWV_NRAGEN, cPara, cMensagem, cAssunto, GWV->GWV_SIT})
			If ValType(aRetMail) == "A" .and. len(aRetMail) > 0 
				cPara 	  := aRetMail[1,1]
				cMensagem := aRetMail[1,2]
				cAssunto  := aRetMail[1,3]
			EndIf
		EndIf		
			
		If GFEEnvMail(cPara,cAssunto,cMensagem, .T.)
			RecLock("GWV",.F.)
			GWV_IDENVI := "2"
			GWV_DTENVI := DDATABASE
			GWV_HRENVI := TIME()
			MsUnLock("GWV")
			MsgAlert('Envio de E-mail cancelamento realizado com sucesso.','Aviso')
		EndIf
	EndIf

Return  

/*--------------------------------------------------------------------------------------
{Protheus.doc} GFEA517MAIL

Função de gatilho do campo GWV_CDEMIT para preencher o campo GWV_EMAIL

@since 26/02/2019
---------------------------------------------------------------------------------------*/
Function GFEA517MAIL()
	Local cEmails := ""

	If GFXCP12123("GWV_EMAIL") .And. GFXCP12123("GU2_RECAGE")
		GU2->(dbSetOrder(1))
		If GU2->(dbSeek(xFilial("GU2") + M->GWV_CDEMIT))
			While !GU2->(Eof()) .And. xFilial("GU2") + M->GWV_CDEMIT == GU2->GU2_FILIAL + GU2->GU2_CDEMIT
				If GU2->GU2_RECAGE == "1" .And. GU2->GU2_SIT == '1'
					If Empty(cEmails)
						cEmails := GU2->GU2_EMAIL
					Else
						cEmails := cEmails + ";" + GU2->GU2_EMAIL
					EndIf
				EndIf
				cEmails := AllTrim(cEmails)
				GU2->(dbSkip())
			EndDo 
		EndIf
		
		If Empty(cEmails)
			GU3->(dbSetOrder(1))
			If GU3->(dbSeek(xFilial("GU3") + M->GWV_CDEMIT))
				cEmails := GU3->GU3_EMAIL
			EndIf
		EndIf
	EndIf
Return cEmails
