#INCLUDE "PROTHEUS.CH"
#INCLUDE "APWIZARD.CH"
#INCLUDE "FWMVCDEF.CH"
#DEFINE NOVAPLACA "Nova Placa"
#DEFINE NOVOMOTORISTA "Novo Motorista"

//------------------------------------------------------------------- 
//Inclusão Pátios 12.1.4
/*/{Protheus.doc} GFEA522
Wizard para realizar acesso de veículos. Inicia uma movimentação no processo de pátios e portarias. 
Uso genérico.
	
@author alan.victor
@since 22/01/2014
@version 1.0		
/*/
Function GFEA522()
	Private oNo := LoadBitmap( GetResources(), "LBNO" )
	Private oOk := LoadBitmap( GetResources(), "LBTIK" )
	Private oWizard
	Private lFocusCPF := .T.
	
	//
	// Parâmetros
	//
	Private lIntOMS := SuperGetMV("MV_CADERP",,"1") == "1" .And. SuperGetMV("MV_ERPGFE",,"2") == "2" .And. SuperGetMV("MV_CADOMS",,"1") == "1"
	Private cNumEmi := SuperGetMv("MV_EMITMP",.F.,"1")	// Codigo emitente (Integração com Protheus): 0=CNPJ/CPF,1=Numeração própria
	Private lIncVei := SuperGetMv("MV_GFEPVE",.F.,"2") $ "1/S"	// Permite inclusão de veículos na portaria (1=Sim,2=Não)
	Private lIncMot := SuperGetMv("MV_GFEPMT",.F.,"2") $ "1/S"	// Permite inclusão de motoristas na portaria (1=Sim,2=Não)
	Private cCadVei := SuperGetMv("MV_GFECPL",.F.,"2")			// Codigo do veiculo: 1=Sistema, 2=Placa veiculo
	
	//
	// Dados por etapa
	//
	Private aEtapa1 
	Private aEtapa2
	Private aEtapa3 
	Private aEtapa4 := {}
	Private aEtapa5
	Private aEtapa6
	
	Private aValTGET := {}

	//
	// Objetos dos componentes de formulário das etapas
	//
	Private aoEtapa1		:= {}
	Private aoEtapa2		:= {}
	Private aoEtapa3		:= {}
	Private aoEtapa4		:= {}
	Private aoEtapa5		:= {}
	Private aoEtapa6		:= {}
	Private cBkpFilAnt := cFilAnt 

	If !GFECheckGX4()
		Return .F.
	EndIF
	
	ResetArrays()
	
	/*
	Private aEtapa1 := 	{;
							Space(8),;							// Placa
							Space(14),;							// CPF Motorista
							Space(8);							// Nr Agendamento
							}

	Private aEtapa2 := 	{;
							{},;								// Placas (Veículos da movimentação)
							0,;									// Item Selecionado do ListBox
							Space(8),;							// Placa				INDICE 2
							Space(2),;							// UF Placa			
							Space(TamSX3("GV3_CDTPVC")[1]),;	// Tipo Veículo		OBRIGATORIO
							Space(TamSX3("GU3_CDEMIT")[1]),;	// Cod Proprietário  OBRIGATORIO
							Space(TamSX3("GU3_NMEMIT")[1]),;	// Desc Proprietário
							0,;									// Tara
							0,;									// Lotação
							0,;									// PBT
							Space(TamSX3("GU8_MMOD")[1]),;		// Marca/Model
							Space(TamSX3("GU8_ANOFAB")[1]),;	// Ano Fabricação
							.F.,;								// Editando?
							.F.;								// Novo registro?
							}

	Private aEtapa3 := 	{;
							{},;									// CPF's dos motoristas da movimentação
							0,;										// Motorista selecionado
							Space(14),;							// CPF Motorista 	CHAVE 2
							Space(TamSX3("GUU_NMMTR")[1]),;		// Nome			CHAVE 3
							Space(TamSX3("GUU_PSEUD")[1]),;		// Responde por	CHAVE 4
							Space(TamSX3("GUU_RG")[1]),;		// RG
							Space(TamSX3("GUU_ORGEXP")[1]),;	// Orgão Expedidor
							.F.,;									// Editando?
							.F.;									// Novo registro?
							}

	//	Agendamentos
	Private aEtapa4 := 	{{	.T.,	// 1 Checkbox Grid
								"",		
								"",
								"",
								"",
								"",
								"",		// 7 Seq. Operacao
								"",		// 8 Operacao da Conf. de Operacao
								}};

	Private aEtapa5 := 	{;
							Space(TamSX3("GVI_CDOPER")[1]),;	// Operação
							Space(TamSX3("GVI_DSOPER")[1]),; 	// Desc Operação
							Space(TamSX3("GVI_SEQ")[1]),;		// Sequência
							Space(TamSX3("GU3_CDEMIT")[1]),;	// Emitente
							"";										// Resumo
							}
							
	Private aEtapa6 := 	{;
							"";										// Instruções							
							}
	*/
	
	cFilant := FWPesqSM0("M0_CODFIL",cEmpAnt,,,,.T.)  // Escolher a filial que deseja trabalhar
	If Empty(cFilAnt)
	    cFilant := cBkpFilAnt
	    Return
	EndIf	
	// Etapa 1
	DEFINE WIZARD oWizard TITLE "Acesso Veículos" HEADER "Informações Iniciais (1/5)" MESSAGE "Informe os dados inciciais da movimentação" TEXT "" PANEL;
	NEXT {|| E1_Next() } FINISH {|| .T. }
	
	// Etapa 2
	CREATE PANEL oWizard HEADER "Veículos (2/5)" MESSAGE "Informe os veículos da movimentação" PANEL;
	BACK {|| E2_Back() } NEXT {|| E2_Next() } EXEC {|| E2_Load() }
	
	// Etapa 3
	CREATE PANEL oWizard HEADER "Motoristas (3/5)" MESSAGE "Informe os motoristas da movimentação" PANEL;
	BACK {|| E3_Back() } NEXT {|| E3_Next() } EXEC {|| E3_Load() }
	
	// Etapa 4
	CREATE PANEL oWizard HEADER "Agendamentos (4/5)" MESSAGE "Informe os agendamentos da movimentação" PANEL;
	BACK {|| E4_Back() } NEXT {|| E4_Next() } EXEC {|| E4_Load() }
	
	// Etapa 5
	CREATE PANEL oWizard HEADER "Movimento (5/5)" MESSAGE "Complete as informações relacionadas ao movimento" PANEL;
	BACK {|| E5_Back() } NEXT {|| E5_Next() } EXEC {|| E5_Load() }
	
	// Final
	CREATE PANEL oWizard HEADER "Processo Concluído" MESSAGE "" PANEL;
	EXEC {|| E6_Load() }
	
	InitWizard()
	
	// Ativa Wizard
	ACTIVATE WIZARD oWizard CENTERED VALID {|| .T. }
Return

/*/{Protheus.doc} InitWizard
Cria os componentes das etapas do Wizard.
Uso Exclusivo.
	
@author Alan Victor Lamb
@since 14/01/2014
@version 1.0
/*/
Static Function InitWizard()
	Local aUFs 	:= GetUFS() // UF's
	Local aTpVc 	:= GetTPVC() // Tipos de Veículo
	Local oFont 	:= TFont():New('Courier new',,-16,.T.)
	Local oSay, oGet, oLst, oBtn, oMulti, oFolder
	Local aTitulos
	
	//
	// Etapa 1
	//
		oSay := TSay():New( 20, 15,{||"*"}, oWizard:oMPanel[1],,oFont,,,,.T.,CLR_RED)
		aAdd(aoEtapa1, oSay)
		oSay := TSay():New( 20, 21,{||"Informe a placa do veículo: "}, oWizard:oMPanel[1],,,,,,.T.)
		oGet := TGet():New( 20, 90,bSETGET(aEtapa1[1]),oWizard:oMPanel[1],30,009,PesqPict('GU8','GU8_PLACA'),,,,,,,.T.,,,,,,,.F.,.F.,,"aEtapa1[1]",,,,.F.)
		oGet:SetFocus()
		aAdd(aoEtapa1, oSay)
		aAdd(aoEtapa1, oGet)

		oSay := TSay():New( 40, 15,{||"*"}, oWizard:oMPanel[1],,oFont,,,,.T.,CLR_RED)
		aAdd(aoEtapa1, oSay)
		oSay := TSay():New( 40, 21,{||"CPF do motorista: "}, oWizard:oMPanel[1],,,,,,.T.)
		oGet := TGet():New( 40, 90,bSETGET(aEtapa1[2]),oWizard:oMPanel[1],45,009,"@R 999.999.999-99", {|| Empty(aEtapa1[2]) .Or. CGC(RemChrEsp(aEtapa1[2])) } ,,,,,,.T.,,,,,,,.F.,.F.,,"aEtapa1[2]",,,,.F.)		
		aAdd(aoEtapa1, oSay)
		aAdd(aoEtapa1, oGet)

		oSay := TSay():New( 60, 15,{||"Número do agendamento: "}, oWizard:oMPanel[1],,,,,,.T.)
		oGet := TGet():New( 60, 90,bSETGET(aEtapa1[3]),oWizard:oMPanel[1],30,000,"99999999",,0,,,,,.T.,,,,,,,.F.,.F.,,"aEtapa1[3]",,,,.F.)	
		aAdd(aoEtapa1, oSay)
		aAdd(aoEtapa1, oGet)

	//
	// Etapa 2
	//
		oGrp := TGroup():New(00,10,140,140,'Veículos da movimentação',oWizard:oMPanel[2],,,.T.)
		oLst := TListBox():New( 08, 15, bSETGET(aEtapa2[2]),aEtapa2[1], 120, 116, {|oLb| E2_LBChange(oLb) }, oWizard:oMPanel[2],,,,.T.)
		aAdd(aoEtapa2, oGrp)
		aAdd(aoEtapa2, oLst)//E2_LBChange(aoEtapa2[2])
		
		oBtn := TButton():New( 128, 015, "Adicionar", oWizard:oMPanel[2],{|| E2_BtnAdicionar() }, 48, 10,,,,.T.)
		aAdd(aoEtapa2, oBtn)
		
		oBtn := TButton():New( 128, 105, "Excluir", oWizard:oMPanel[2],{|| E2_BtnExcluir() }, 30, 10,,,,.T.)
		aAdd(aoEtapa2, oBtn)

		oFolder := TFolder():New( 0,155,{'Cadastro de veículos'},,oWizard:oMPanel[2],,,,.T.,,140,140 )
		aAdd(aoEtapa2, oFolder)
		
		oSay			:= TSay():New( 01, 02,{||"Placa do veículo"},oFolder:aDialogs[1],,,,,,.T.)
		oGet 			:= TGet():New( 09,02,bSETGET(aEtapa2[3]),oFolder:aDialogs[1],44,09,PesqPict('GU8','GU8_PLACA'),,0,,,,,.T.,,,,,,,.F.,.F.,,"aEtapa2[3]",,,,.T.)
		oGet:bValid 	:= {|| E2_Valid() }
		oGet:bWhen		:= {|| E2_When('aEtapa2[3]') }
		oGet:cF3 		:= "GU8PLC"
		oGet:SetHasButton(.T.)
		aAdd(aoEtapa2, oSay)
		aAdd(aoEtapa2, oGet)//aoEtapa2[7]

		oSay 			:= TSay():New( 01, 98,{||"UF Placa"},oFolder:aDialogs[1],,,,,,.T.)
		oCmb 			:= TComboBox():New(09,98,bSETGET(aEtapa2[4]),aUFs,34,20,oFolder:aDialogs[1],,,,,,.T.,,,,,,,,,'aEtapa2[4]')
		oCmb:bValid	:= {|| E2_Valid() }
		oCmb:bWhen 	:= {|| E2_When('aEtapa2[4]') }
		aAdd(aoEtapa2, oSay)
		aAdd(aoEtapa2, oCmb)
		
		oSay 			:= TSay():New( 25, 02,{||"Marca / Modelo"},oFolder:aDialogs[1],,,,,,.T.)
		oGet 			:= TGet():New(33,02,bSETGET(aEtapa2[11]),oFolder:aDialogs[1],094,09,"@!",,0,,,.F.,,.T.,,.F.,,.F.,.F.,,.F.,.F.,,"aEtapa2[11]",,,,)
		oGet:bValid 	:= {|| E2_Valid() }
		oGet:bWhen		:= {|| E2_When('aEtapa2[11]') }
		aAdd(aoEtapa2, oSay)
		aAdd(aoEtapa2, oGet)

		oSay 			:= TSay():New( 25, 98,{||"Ano Fabricação"},oFolder:aDialogs[1],,,,,,.T.)
		oGet 			:= TGet():New(33, 98,bSETGET(aEtapa2[12]),oFolder:aDialogs[1],034,09,"9999",,0,,,.F.,,.T.,,.F.,,.F.,.F.,,.F.,.F.,,"aEtapa2[12]",,,,)
		oGet:bValid 	:= {|| E2_Valid() }
		oGet:bWhen		:= {|| E2_When('aEtapa2[12]') }
		aAdd(aoEtapa2, oSay)
		aAdd(aoEtapa2, oGet)

		oSay 			:= TSay():New( 45, 02,{||"Tipo Veículo"},oFolder:aDialogs[1],,,,,,.T.)
		oCmb 			:= TComboBox():New(53,02,bSETGET(aEtapa2[5]),aTpVc,100,20,oFolder:aDialogs[1],,{|oCmb| E2_TpVcChange(oCmb) },,,,.T.,,,,{|| aEtapa2[14] },,,,,'aEtapa2[5]')
		oCmb:bValid 	:= {|| E2_Valid() }
		oCmb:bWhen 	:= {|| E2_When('aEtapa2[5]') }
		aAdd(aoEtapa2, oSay)
		aAdd(aoEtapa2, oCmb)
		
		oSay 			:= TSay():New( 69, 02,{||"Proprietário"},oFolder:aDialogs[1],,,,,,.T.)
		oGet 			:= TGet():New( 77,02,bSETGET(aEtapa2[6]),oFolder:aDialogs[1],62,09,"@!",,0,,,,,.T.,,,,,,,.F.,.F.,,"aEtapa2[6]",,,,.T.)
		oGet:bValid 	:= {|| E2_Valid() }
		oGet:bWhen 	:= {|| E2_When('aEtapa2[6]') }
		oGet:cF3 		:= "GU3TRP"
		oGet:SetHasButton(.T.)
		aAdd(aoEtapa2, oSay)
		aAdd(aoEtapa2, oGet)

		oGet 			:= TGet():New( 77,64,bSETGET(aEtapa2[7]),oFolder:aDialogs[1],68	,09,"@!",,0,,,.F.,,.T.,,.F.,,.F.,.F.,,.F.,.F.,,"aEtapa2[7]",,,,)
		oGet:bValid 	:= {|| E2_Valid() }
		oGet:bWhen		:= {|| .F. }
		aAdd(aoEtapa2, oGet)
		
		oSay 			:= TSay():New( 89, 02,{||"Tara (kg)"},oFolder:aDialogs[1],,,,,,.T.)
		oGet 			:= TGet():New( 97,02,bSETGET(aEtapa2[8]),oFolder:aDialogs[1],42,09,"@E 9,999,999.99",,0,,,.F.,,.T.,,.F.,,.F.,.F.,{|| aEtapa2[10] := aEtapa2[8] + aEtapa2[9]},.F.,.F.,,"aEtapa2[8]",,,,,.T.)
		oGet:bValid 	:= {|| E2_Valid() }
		oGet:bWhen		:= {|| E2_When('aEtapa2[8]') }
		aAdd(aoEtapa2, oSay)
		aAdd(aoEtapa2, oGet)
				
		oSay 			:= TSay():New( 89, 46,{||"Lotação (kg)"},oFolder:aDialogs[1],,,,,,.T.)
		oGet			:= TGet():New( 97,46,bSETGET(aEtapa2[9]),oFolder:aDialogs[1],42,09,"@E 999,999.99",,0,,,.F.,,.T.,,.F.,,.F.,.F.,{|| aEtapa2[10] := aEtapa2[8] + aEtapa2[9]},.F.,.F.,,"aEtapa2[9]",,,,,.T.)
		oGet:bValid 	:= {|| E2_Valid() }
		oGet:bWhen		:= {|| E2_When('aEtapa2[9]') }
		aAdd(aoEtapa2, oSay)
		aAdd(aoEtapa2, oGet)
			
		oSay 			:= TSay():New( 89, 90,{||"PBT (kg)"},oFolder:aDialogs[1],,,,,,.T.)
		oGet 			:= TGet():New( 97,90,bSETGET(aEtapa2[10]),oFolder:aDialogs[1],42,09,"@E 9,999,999.99",,0,,,.F.,,.T.,,.F.,,.F.,.F.,,.F.,.F.,,"aEtapa2[10]",,,,,.T.)
		oGet:bValid 	:= {|| E2_Valid() }
		oGet:bWhen		:= {|| .F. }
		aAdd(aoEtapa2, oSay)
		aAdd(aoEtapa2, oGet)
		
		oBtn 			:= TButton():New( 128,157,"Salvar",oWizard:oMPanel[2],{|| E2_BtnSalvar() },30,10,,,.F.,.T.,.F.,,.F.,,,.F. )
		oBtn:bWhen		:= {|| E2_When("btnSalvar") }
		aAdd(aoEtapa2, oBtn)

		oBtn 			:= TButton():New( 128,223,"Cadastro completo",oWizard:oMPanel[2],{|| E2_BtnCadComp() },70,10,,,.F.,.T.,.F.,,.F.,,,.F. )
		oBtn:bWhen		:= {|| !E2_When('aEtapa2[5]') } // O contrário do Tipo Veiculo
		aAdd(aoEtapa2, oBtn)

	//
	// Etapa 3
	//
		oGrp := TGroup():New(00,010,140,140,'Motoristas da movimentação',oWizard:oMPanel[3],,,.T.)
		oLst := TListBox():New( 08, 15, bSETGET(aEtapa3[2]),aEtapa3[1], 120, 116, {|oLb| E3_LBChange(oLb)}, oWizard:oMPanel[3],,,,.T.)
		
		aAdd(aoEtapa3, oGrp)
		aAdd(aoEtapa3, oLst)
		
		oBtn := TButton():New( 128, 015, "Adicionar", oWizard:oMPanel[3],{|| E3_BtnAdicionar() }, 48, 10,,,,.T.)
		aAdd(aoEtapa3, oBtn)
		
		oBtn := TButton():New( 128, 105, "Excluir", oWizard:oMPanel[3],{|| E3_BtnExcluir() }, 30, 10,,,,.T.)
		aAdd(aoEtapa3, oBtn)
		
		oFolder := TFolder():New( 00,155,{'Cadastro de motoristas'},,oWizard:oMPanel[3],,,,.T.,,140,140 )
		aAdd(aoEtapa3, oFolder)

		oSay := TSay():New( 01, 02,{||"CPF"},oFolder:aDialogs[1],,,,,,.T.)
		//{|u| If(PCount()>0,P3_Set('cTGMotCPF',u),cTGMotCPF) }
		//oGet := TGet():New( 09,02,bSETGET(aEtapa3[3]),oFolder:aDialogs[1],65,09,"@R 999.999.999-99",{|| CGC() },0,,,,,.T.,,,,,,,.F.,.F.,,'aEtapa3[3]',,,,.T.)
		oGet := TGet():New( 09,02,bSETGET(aEtapa3[3]),oFolder:aDialogs[1],65,09,"@!", {|| Empty(aEtapa3[3]) .Or. CGC(aEtapa3[3]) } ,0,,,,,.T.,,,,,,,.F.,.F.,,'aEtapa3[3]',,,,.T.)
		oGet:bValid 	:= {|| E3_Valid() }
		oGet:bWhen		:= {|| E3_When('aEtapa3[3]') }
		oGet:cF3 		:= "GUUMT2"
		oGet:SetHasButton(.T.)
		aAdd(aoEtapa3, oSay)
		aAdd(aoEtapa3, oGet)

		oSay := TSay():New( 23, 02,{||"Nome"},oFolder:aDialogs[1],,,,,,.T.)
		oGet := TGet():New( 31,02,bSETGET(aEtapa3[4]),oFolder:aDialogs[1],80,09,"@!",,0,,,.F.,,.T.,,.F.,,.F.,.F.,,.F.,.F.,,"aEtapa3[4]",,,,)
		oGet:bValid 	:= {|| E3_Valid() }
		oGet:bWhen		:= {|| E3_When('aEtapa3[4]') }
		aAdd(aoEtapa3, oSay)
		aAdd(aoEtapa3, oGet)
		
		oSay := TSay():New( 45, 02,{||"Responde por"},oFolder:aDialogs[1],,,,,,.T.)
		oGet := TGet():New( 53,02,bSETGET(aEtapa3[5]),oFolder:aDialogs[1],80,09,"@!",,0,,,.F.,,.T.,,.F.,,.F.,.F.,,.F.,.F.,,"aEtapa3[5]",,,,)
		oGet:bValid 	:= {|| E3_Valid() }
		oGet:bWhen		:= {|| E3_When('aEtapa3[5]') }
		aAdd(aoEtapa3, oSay)
		aAdd(aoEtapa3, oGet)
		
		oSay := TSay():New( 67, 02,{||"RG"},oFolder:aDialogs[1],,,,,,.T.)
		oGet := TGet():New( 75,02,bSETGET(aEtapa3[6]),oFolder:aDialogs[1],80,09,"@!",,0,,,.F.,,.T.,,.F.,,.F.,.F.,,.F.,.F.,,"aEtapa3[6]",,,,)
		oGet:bValid 	:= {|| E3_Valid() }
		oGet:bWhen		:= {|| E3_When('aEtapa3[6]') }
		aAdd(aoEtapa3, oSay)
		aAdd(aoEtapa3, oGet)
		
		oSay := TSay():New( 67, 90,{||"Órgão Expedidor"},oFolder:aDialogs[1],,,,,,.T.)
		oGet := TGet():New( 75, 90,bSETGET(aEtapa3[7]),oFolder:aDialogs[1],45,09,"@!",,0,,,.F.,,.T.,,.F.,,.F.,.F.,,.F.,.F.,,"aEtapa3[7]",,,,)
		oGet:bValid 	:= {|| E3_Valid() }
		oGet:bWhen		:= {|| E3_When('aEtapa3[7]') }
		aAdd(aoEtapa3, oSay)
		aAdd(aoEtapa3, oGet)
		
		oBtn 			:= TButton():New( 128,157,"Salvar",oWizard:oMPanel[3],{|| E3_BtnSalvar() },30,10,,,.F.,.T.,.F.,,.F.,,,.F. )
		oBtn:bWhen		:= {|| E3_When("btnSalvar") }
		aAdd(aoEtapa3, oBtn)

		oBtn 			:= TButton():New( 128,223,"Cadastro completo",oWizard:oMPanel[3],{|| E3_BtnCadComp() },70,10,,,.F.,.T.,.F.,,.F.,,,.F. )
		oBtn:bWhen		:= {|| !E3_When('aEtapa3[4]') }
		aAdd(aoEtapa3, oBtn)

	//
	// Etapa 4
	//
		oGrp := TGroup():New(00,010,140,295,'Escolha os agendamentos',oWizard:oMPanel[4],,,.T.)
		aAdd(aoEtapa4, oGrp)
		
		aTitulos := {"","Agendamento","Data","Hora","Operação","Emitente"}
		oLst := TWBrowse():New( 20, 15, 275, 115,, aTitulos ,{10,45,35,18,60,22},oWizard:oMPanel[4] ,,,,,,,,,,,,,,.T.)
	   	oLst:SetArray(aEtapa4)
		oLst:bLine	  		:= {|| If(Len(aEtapa4) == 0, {.T.,"","","","","","",""}, { If(aEtapa4[oLst:nAt,1],oOK,oNO),aEtapa4[oLst:nAt,2],aEtapa4[oLst:nAt,3],aEtapa4[oLst:nAt,4],aEtapa4[oLst:nAt,5],aEtapa4[oLst:nAt,6]}) }
		oLst:bRClicked	:= {|| aEval(aEtapa4,{|x|x[1]:=!x[1]}),oLst:Refresh(.F.) }
		oLst:bLDblClick	:= {|| E4_VerifOper() }
		aAdd(aoEtapa4, oLst)
		oLst:Refresh()

		oBtn := TButton():New( 07,230, "Desmarcar todos", oWizard:oMPanel[4],{|| Aeval(aEtapa4,{|x,y| x[1] := .F.}) }, 60,10,,,,.T.,,,,,,)		
		aAdd(aoEtapa4, oBtn)

	//
	// Etapa 5
	//
		oGrp := TGroup():New(000,010,027,295,'Dados complementares',oWizard:oMPanel[5],,,.T.)
		aAdd(aoEtapa5, oGrp)
		
		oGrp := TGroup():New(030,010,140,295,'Resumo movimentação',oWizard:oMPanel[5],,,.T.)
		aAdd(aoEtapa5, oGrp)
		
		// OPERACAO
		oSay := TSay():New( 12, 15,{||"Operação"},oWizard:oMPanel[5],,,,,,.T.)
		oGet := TGet():New( 10,41,bSETGET(aEtapa5[1]),oWizard:oMPanel[5],57,09,"@!",,0,,,,,.T.,,,,,,,.F.,.F.,,'aEtapa5[1]',,,,.T.)
		oGet:cF3 := "GVIOPS"
		oGet:bValid := {|| E5_Valid() }
		
		aAdd(aoEtapa5, oSay)
		aAdd(aoEtapa5, oGet)
		
		// SEQUENCIA	
		oGet := TGet():New( 10,097,bSETGET(aEtapa5[3]),oWizard:oMPanel[5],10,09,"@!",,0,,,,,.T.,,,,.F.,.F.,,.F.,.F.,,'aEtapa5[3]')
		oGet:bValid := {|| E5_Valid() }
		aAdd(aoEtapa5, oGet)

		// DESC OPERACAO
		oGet := TGet():New( 10,119,bSETGET(aEtapa5[2]),oWizard:oMPanel[5],70,09,"@!",,0,,,.F.,,.T.,,.F.,{|| .F. },.F.,.F.,,.F.,.F.,,'aEtapa5[2]')
		aAdd(aoEtapa5, oGet)	
		
		// EMITENTE
		oSay := TSay():New( 12,192,{||"Emitente"},oWizard:oMPanel[5],,,,,,.T.)
		oGet := TGet():New( 10,215,bSETGET(aEtapa5[4]),oWizard:oMPanel[5],80,09,"@!",,0,,,,,.T.,,,,,,,.F.,.F.,,'aEtapa5[4]',,,,.T.)
		oGet:cF3 := "GU3TRP"
		oGet:SetHasButton(.T.)
		aAdd(aoEtapa5, oSay)
		aAdd(aoEtapa5, oGet)

		// RESUMO
		oMulti := TMultiGet():New( 40, 015, bSETGET(aEtapa5[5]), oWizard:oMPanel[5], 275, 095, /*<oFont>*/, .T. /*<.hscroll.>*/, CLR_BLACK/*<nClrFore>*/, /*<nClrBack>*/, /*<oCursor>*/, .T./*<.pixel.>*/, /*<cMsg>*/, /*<.update.>*/,, /*<.lCenter.>*/, /*<.lRight.>*/, .T./*<.readonly.>*/, /*<{uValid}>*/, /*[\{|nKey, nFlags, Self| <uChange>\}]*/, /*<.lDesign.>*/, .F./*[<.lNoBorder.>]*/, .F./*[<.lNoVScroll.>]*/ )
		aAdd(aoEtapa5, oMulti)

	//
	// Final
	//
		oSay := TSay():New( 12, 12,{||"Movimentação cadastrada com sucesso!"},oWizard:oMPanel[6],,,,,,.T.)
		oGrp := TGroup():New(25,010,121,295,'Instruções',oWizard:oMPanel[6],,,.T.)
		aAdd(aoEtapa6, oSay)
		aAdd(aoEtapa6, oGrp)
			
		oMulti	:= TMultiGet():New( 33, 015,bSETGET(aEtapa6[1]), oWizard:oMPanel[6], 275, 085, /*<oFont>*/, .T. /*<.hscroll.>*/, CLR_BLACK/*<nClrFore>*/, /*<nClrBack>*/, /*<oCursor>*/, .T./*<.pixel.>*/, /*<cMsg>*/, /*<.update.>*/,, /*<.lCenter.>*/, /*<.lRight.>*/, .T./*<.readonly.>*/, /*<{uValid}>*/, /*[\{|nKey, nFlags, Self| <uChange>\}]*/, /*<.lDesign.>*/, .f./*[<.lNoBorder.>]*/, .F./*[<.lNoVScroll.>]*/ )
		aAdd(aoEtapa6, oMulti)
		
		oBtn := TButton():New( 125, 090, "Nova Entrada", oWizard:oMPanel[6],{|| E6_NewEntrance() },50,12,,,.F.,.T.,.F.,,.F.,,,.F. )
		aAdd(aoEtapa6, oBtn)
		
		oBtn := TButton():New( 125, 160, "Fechar", 		oWizard:oMPanel[6],{|| EF_Fechar() /*oWizard:oDlg:lEscClose := .T.*/ },50,12,,,.F.,.T.,.F.,,.F.,,,.F. )
		aAdd(aoEtapa6, oBtn)

	   /* Ponto de entrada Sementes Goias
	      Permite editar o conjunto de objetos de cada uma das etapas no Mágico
	      Ticket Zendesk: 873634 
	   */		
	   aRet := {}
	   IF ExistBlock("GFEA5222")
	   		aRet := ExecBlock("GFEA5222",.F.,.F.,{aoEtapa1, aoEtapa2, aoEtapa3, aoEtapa4, aoEtapa5, aoEtapa6})
		    aoEtapa1 := aRet[1]  
		    aoEtapa2 := aRet[2]
		    aoEtapa3 := aRet[3]
		    aoEtapa4 := aRet[4]
		    aoEtapa5 := aRet[5]
		    aoEtapa6 := aRet[6]	
		    
	   EndIf		
Return .T.


//
// Etapa 1 - Informações Iniciais
//

Static Function E1_Next()
	Local lRet 		:= .T.
	Local lRetMoto	:= .T.
	Local cPlaca 	:= aEtapa1[1]
	Local cCPF		:= aEtapa1[2]
	
	If Empty(cPlaca)
		MsgStop("Informe a Placa do veículo.", "Atenção")
		aoEtapa1[3]:SetFocus()
		lRet := .F.
	EndIf
	
	// Se não permite incluir veículos na portaria, deve-se informar um veículo existente
	If lRet .And. (!lIncVei)
		If Empty(Posicione("GU8",2,xFilial("GU8") + cPlaca, "GU8_CDVEIC"))
			MsgStop("Veículo não cadastrado." + CRLF + "O veículo deve ser cadastrado no programa de manutenção de veículos.",'Atenção')
			aoEtapa1[3]:SetFocus()
			lRet := .F.
		EndIf
	EndIf
	
	If lRet .And. Empty(cCPF)
		MsgStop("Informe o CPF do motorista.", "Atenção")
		aoEtapa1[6]:SetFocus()
		lRet := .F.
	EndIf
	
	// Se não permite incluir motoristas na portaria, deve-se informar um motorista existente
	If lRet .And. (!lIncMot)
		If Empty(Posicione("GUU",2,xFilial("GUU") + cCPF, "GUU_CDMTR"))
			MsgStop("Motorista não cadastrado." + CRLF + "O motorista deve ser cadastrado no programa de manutenção de motoristas.",'Atenção')
			aoEtapa1[6]:SetFocus()
			lRet := .F.
		EndIf
	EndIf
	
	GUU->( dbSetOrder(2) )
	If GUU->( dbSeek( xFilial("GUU") + cCPF ) )
		lRetMoto := .F.
		While GUU->(!Eof()) .And. GUU->GUU_FILIAL == xFilial("GUU") .And. GUU->GUU_IDFED == cCPF			
			If GUU->GUU_SIT == "1"	
				lRetMoto := .T.
			EndIf
			GUU->( dbSkip() )
		EndDo
		If !lRetMoto
			MsgStop("Informe o CPF de um motorista com a situação ativa .", "Atenção")
			aoEtapa1[6]:SetFocus()
			lRet := .F.
		EndIf
	EndIf	
	/*Ponto de entrada Sementes Goias
      Permite aplicar regras de validações com base nas respostas dos campos.
      Também define a oredem dos campos na tela.
    */
	If ExistBlock("GFEA5223") .AND. lRet
		lRet := ExecBlock("GFEA5223", .F., .F., {aEtapa1}) 
	EndIF
	
Return lRet

//
// Etapa 2 - Veículos
//
Static Function E2_LstPlacas()
	Local aItens 	:= aEtapa2[1]
	Local aRet		:= {}
	Local nCount	:= 0
	
	For nCount := 1 To Len(aItens)
		aAdd(aRet, aItens[nCount][1])
	Next nCount
Return aRet

Static Function E2_GetPlaca(cPlaca)
	Local aItens 	:= aEtapa2[1]
	Local aRet		:= {}
	Local nItem	:= 0
	
	nItem := aScan(aItens, {|x| StrTran(x[1],"-") == StrTran(cPlaca,"-") })
	
	If nItem > 0
		aRet := aItens[nItem]
	EndIf
Return aRet

Static Function E2_AddPlaca(cPlaca)
	Local aItem := E2_PlacaItem(cPlaca)
	aAdd(aEtapa2[1], aItem)	
Return Nil

Static Function E2_PlacaItem(cPlaca, cChave)
	Local aItem		:= {}
	Default cChave 	:= cPlaca
	
	cPlaca	:=  AllTrim(cPlaca) //cPlaca := StrTran(cPlaca, "-")

	aItem	:= {;
					cChave/*Chave no Listbox*/,;
					{;
						cPlaca/*PLACA*/,;
						Space(2)/*UFPLACA*/,;
						Space(TamSX3("GV3_CDTPVC")[1])/*CDTPVC*/,;
						Space(TamSX3("GU3_CDEMIT")[1])/*PROP*/,;
						Space(TamSX3("GU3_NMEMIT")[1])/*NMPROP*/,;
						0/*TARA*/,;
						0/*CARGUT*/,;
						0/*PBT*/,;
						Space(TamSX3("GU8_MMOD")[1])/*MMOD*/,;
						Space(TamSX3("GU8_ANOFAB")[1])/*ANOFAB*/;
					},;
					.F., /* lEditado  */;
					.T.  /* Nova Placa*/;
				}

	If !Empty(cPlaca)
		dbSelectArea("GU8")
		GU8->( dbSetOrder(2) )
		If GU8->( dbSeek(xFilial("GU8") + cPlaca))
			aItem[2][2] 	:= GU8->GU8_UFPLAC
			aItem[2][3] 	:= GU8->GU8_CDTPVC
			aItem[2][4] 	:= GU8->GU8_CDPROP
			aItem[2][5] 	:= Posicione("GU3",1,xFilial("GU3")+GU8->GU8_CDPROP,"GU3_NMEMIT")
			aItem[2][6] 	:= GU8->GU8_TARA
			aItem[2][7] 	:= GU8->GU8_CARGUT
		 	aItem[2][8] 	:= GU8->GU8_CARGUT + GU8->GU8_TARA 
			aItem[2][9] 	:= GU8->GU8_MMOD
			aItem[2][10] 	:= GU8->GU8_ANOFAB
			aItem[4] 		:= .F.
		EndIf
	EndIf
	
Return aItem

Static Function E2_DelPlaca(cPlaca)
	Local nCount	:= 0
	Local nPos 	:= 0
	
	For nCount := 1 To Len(aEtapa2[1])
		If AllTrim(StrTran(aEtapa2[1][nCount][1],"-")) == AllTrim(StrTran(cPlaca,"-"))
			nPos := nCount
			Exit
		EndIf
	Next nCount
	
	If nPos > 0
		aDel(aEtapa2[1], nPos)
		aSize(aEtapa2[1], Len(aEtapa2[1]) - 1)
	EndIf
Return Nil

Static Function E2_ChangePlaca(cChave, cPlaca)
	Local nCount
	Local oLst := aoEtapa2[2]
	Local nAt
	For nCount := 1 To Len(aEtapa2[1])
		
		If AllTrim(StrTran(aEtapa2[1][nCount][1],"-")) == AllTrim(StrTran(cChave,"-"))
			If AllTrim(StrTran(aEtapa2[1][nCount][2][1],"-")) != AllTrim(StrTran(cPlaca,"-"))
				aEtapa2[1][nCount] := E2_PlacaItem(cPlaca)
				nAt := oLst:nAt
				oLst:SetItems(E2_LstPlacas())
				oLst:Select(nAt)
				aEtapa2[3] := cPlaca
			EndIf

			Exit
		EndIf
			
	Next nCount
Return Nil

Static Function E2_EdtPlaca(cPlaca, cCampo, xVal)
	Local nCount
	Local aCampos :=	{; 
							{'aEtapa2[3]', 1},;
							{'aEtapa2[4]', 2},;
							{'aEtapa2[5]', 3},;
							{'aEtapa2[6]', 4},;
							{'aEtapa2[7]', 5},;
							{'aEtapa2[8]', 6},;
							{'aEtapa2[9]', 7},;
							{'aEtapa2[10]', 8},;
							{'aEtapa2[11]', 9},;
							{'aEtapa2[12]', 10};
						}
	Local nPos
	
	For nCount := 1 To Len(aEtapa2[1])
		If AllTrim(StrTran(aEtapa2[1][nCount][1],"-")) == AllTrim(StrTran(cPlaca,"-"))
			nPos := aScan(aCampos, {|x| Upper(x[1]) == Upper(cCampo) })		
			
			If nPos > 0 .And. aEtapa2[1][nCount][2][nPos] != xVal
				aEtapa2[1][nCount][2][nPos] := xVal
				aEtapa2[1][nCount][3] 		:= .T.
			EndIf
			
			Exit
		EndIf
	Next nCount
Return Nil

Static Function E2_SavPlaca(cPlaca)
	Local lRet 	:= .T.
	Local aRet  := {}
	Local aPlaca 	:= E2_GetPlaca(cPlaca)
	Local oModel
	Local cModel
	Local aCampos
	Local nCount
	Local cCod
	Local nOp
	Local nAlt, nLar, nCom, nVol
	
	// Pré-validação dos dados do formulário
	
	If Empty(aPlaca[2][1]) .Or. AllTrim(aPlaca[2][1]) == AllTrim(NOVAPLACA)
		MsgStop("Informe a placa do veículo.", "Atenção")
		lRet := .F.
	EndIf
	
	If lRet .And. Empty(aPlaca[2][3])
		MsgStop("Informe o tipo de veículo.", "Atenção")
		lRet := .F.
	EndIf
	
	If lRet
		If !aPlaca[4] // Edição
			If lIntOMS
				cCod := Posicione("DA3",3,xFilial("DA3")+aPlaca[2][1],"DA3_COD")
			Else
				cCod := Posicione("GU8",2,xFilial("GU8")+aPlaca[2][1],"GU8_CDTPVC")
			EndIf
		Else // Inserção
			//Codigo do veiculo: 1=Sistema,2=Placa veiculo
			If cCadVei == "1"
				If lIntOMS
					cCod := GetSXENum("DA3", "DA3_COD")
				Else
					cCod := GetSXENum("GU8", "GU8_CDTPVC")
				EndIf
				
				ConfirmSX8()
			Else
				cCod := aPlaca[2][1]
			EndIf
		EndIf
		
		If Empty(cCod)
			MsgStop("Não foi possível encontrar o código do veículo da placa " + aPlaca[2][1] + ".","Atenção")
			lRet := .F.
		EndIf
	EndIf

	If lRet
		If lIntOMS
			cModel := "OMSA060"

			// Busca Altura/Largura/Comprimento/Volume da tabela de Tipo de Veiculo
			dbSelectArea("GV3")
			GV3->( dbSetOrder(1) )
			If GV3->( dbSeek( xFilial("GV3") + Substr( aPlaca[2][3] ,0,2 ) ) )
			 	nAlt := GV3->GV3_ALTURA
			 	nLar := GV3->GV3_LARGUR
			 	nCom := GV3->GV3_COMPRI
			 	nVol := GV3->GV3_VOLUT
			EndIf

			aCampos :=	{;
							{"OMSA060_DA3", "DA3_COD"	, cCod},;
							{"OMSA060_DA3", "DA3_TIPVEI", Substr( aPlaca[2][3] ,0,TamSX3("DA3_TIPVEI")[1])},;
							{"OMSA060_DA3", "DA3_PLACA"	, aPlaca[2][1]},;
							{"OMSA060_DA3", "DA3_ESTPLA", aPlaca[2][2]},;
							{"OMSA060_DA3", "DA3_CODFOR", GetTrpOMS( aPlaca[2][4] )},;		// PROPRIETÁRIO=TRANSP OMS
							{"OMSA060_DA3", "DA3_CAPACM", aPlaca[2][7]},;
							{"OMSA060_DA3", "DA3_TARA"	, aPlaca[2][6]},;
							{"OMSA060_DA3", "DA3_DESC"	, Substr( aPlaca[2][9] ,0,30 )},;	// Tamanho CHARACTER | 30
							{"OMSA060_DA3", "DA3_ANOFAB", aPlaca[2][10]},;
							{"OMSA060_DA3", "DA3_ALTEXT", nAlt},;
							{"OMSA060_DA3", "DA3_LAREXT", nLar},;
							{"OMSA060_DA3", "DA3_COMEXT", nCom},;
							{"OMSA060_DA3", "DA3_VOLMAX", nVol};
						}
		Else
			cModel := "GFEA046"

			aCampos :=	{;
							{"GFEA046_GU8", "GU8_CDVEIC", cCod},;				//iSeq := GetSXENum("GU8", "GU8_CDVEIC")
							{"GFEA046_GU8", "GU8_CDTPVC", aPlaca[2][3]},;		
							{"GFEA046_GU8", "GU8_PLACA"	, aPlaca[2][1]},;		
							{"GFEA046_GU8", "GU8_UFPLAC", aPlaca[2][2]},;		
							{"GFEA046_GU8", "GU8_CDPROP", aPlaca[2][4]},;		
							{"GFEA046_GU8", "GU8_CARGUT", aPlaca[2][7]},;		// Tamanho CHARACTER | 09
							{"GFEA046_GU8", "GU8_TARA"	, aPlaca[2][6]},;		// Tamanho CHARACTER | 10
							{"GFEA046_GU8", "GU8_MMOD"	, aPlaca[2][9]},;		// Tamanho CHARACTER | 30
							{"GFEA046_GU8", "GU8_ANOFAB", aPlaca[2][10]};		// Tamanho CHARACTER | 04	
						}
		EndIf
		
		/*Ponto de entrada Sementes Goias
	      Permite aplicar regras de validações com base nas respostas dos campos.
	      Também define a oredem dos campos na tela.
	    */
		If ExistBlock("GFEA5224")
			aRet    := ExecBlock("GFEA5224", .F., .F., {aEtapa2, aCampos}) 
			lRet    := aRet[1]
			aEtapa2 := aRet[2]
			aCampos := aRet[3]
			
			If !lRet
				aEtapa2[1] := {}
				Return Nil
			EndIf
		EndIF
		
		nOp := If(aPlaca[4], MODEL_OPERATION_INSERT, MODEL_OPERATION_UPDATE)
		
		If nOp == MODEL_OPERATION_UPDATE
			//Posicionar no registro
			If lIntOMS
				dbSelectArea("DA3")
				DA3->( dbSetOrder(3) )	// Filial + Placa
				DA3->( dbSeek( xFilial("DA3") + aPlaca[2][1] ) )
			Else
				dbSelectArea("GU8")
				GU8->( dbSetOrder(2) )	// Filial + Placa
				GU8->( dbSeek( xFilial("GU8") + aPlaca[2][1]  ) )
			EndIf
		EndIf
		
		oModel := FWLoadModel( cModel )
		oModel:SetOperation( nOp )
		oModel:Activate()
		
		For nCount := 1 To Len(aCampos)
			If oModel:GetModel( aCampos[nCount][1] ):GetStruct():HasField( aCampos[nCount][2] )
				If nOp == MODEL_OPERATION_INSERT .Or. (nOp == MODEL_OPERATION_UPDATE .And. !(aCampos[nCount][2] $ "GU8_CDVEIC;DA3_COD"))
					If !oModel:SetValue(aCampos[nCount][1], aCampos[nCount][2], aCampos[nCount][3])
						lRet := .F.
						Exit
					Else
						&("M->" + aCampos[nCount][2]) := aCampos[nCount][3]
					EndIf
				EndIf
			EndIf
		Next nCount
		
		If lRet .And. oModel:VldData()
			oModel:CommitData()
		Else
			aErro := oModel:GetErrorMessage()
			
			MsgStop(AllToChar(aErro[6]) + CRLF +;
					 AllToChar(aErro[7]) + CRLF + CRLF +;
					 "Campo: " + AllToChar(aErro[2]) + CRLF +;
					 "Valor: " + AllToChar(aErro[9]),;
					 'Atenção')
			
			lRet := .F. 
		EndIf
		
		oModel:DeActivate()
	EndIf
	
	If lRet
		// Se salvar não está mais "em edição" ou como "novo registro"
		For nCount := 1 To Len(aEtapa2[1])
			If AllTrim(StrTran(aEtapa2[1][nCount][1],"-")) == AllTrim(StrTran(cPlaca,"-"))
				aEtapa2[1][nCount][3] := .F.
				aEtapa2[1][nCount][4] := .F.
				Exit
			EndIf
		Next nCount
	EndIf
Return lRet

Static Function E2_Load()
	Local cPlaca 	:= PadR(aEtapa1[1], 8)
	Local oLst		:= aoEtapa2[2]
	Local aVeic	:= E2_LstPlacas()
	Local nCount	:= 0
	Local cLstVei := ""
	
	// Adiciona placa da etapa 1
	If Len(aVeic) == 0
		E2_AddPlaca(cPlaca)
		oLst:SetArray(E2_LstPlacas())
	Else
		For nCount := 1 To Len(aVeic)
			cLstVei += ";" + StrTran( aVeic[nCount] ,"-","") 
		Next nCount		
		
		If !(cPlaca $ cLstVei)
			E2_AddPlaca(cPlaca)
			oLst:SetArray(E2_LstPlacas())
		EndIf
	EndIf
	
	If oLst:Len() > 0
		oLst:Select(oLst:Len())
	EndIf
	
	If Empty(aEtapa2[3])
		aEtapa2[3] := cPlaca
	EndIf
	
	aoEtapa2[7]:CtrlRefresh()
	aoEtapa2[7]:Refresh()
	E2_LBChange(aoEtapa2[2])
	aoEtapa2[7]:SetFocus()
Return .T.

Static Function E2_Next()
	Local aPlacas := aEtapa2[1]
	Local oLst		:= aoEtapa2[2]
	Local nCount	:= 0
	Local lRet 	:= .T.
	Local aEdit	:= {}
	Local cPlacas	:= ""
	
	// Verificar se tem placas com alterações a serem salvas
	For nCount := Len(aPlacas) To 1 Step -1 
		If aPlacas[nCount][3]
			aAdd(aEdit, aPlacas[nCount][1])
			If Empty(cPlacas)
				cPlacas += AllTrim(aPlacas[nCount][1]) + "?" + CRLF
			Else
				cPlacas := AllTrim(aPlacas[nCount][1]) + "," + CRLF + cPlacas
			EndIf
		EndIf
	Next nCount
	
	If !Empty(cPlacas)
		If MsgYesNo("Deseja salvar as alterações realizadas nas seguintes placas:" + CRLF + cPlacas + "Placas sem alterações salvas serão excluídas da movimentação.")
			For nCount := 1 To Len(aEdit)
				lRet := E2_SavPlaca(aEdit[nCount])
				
				If !lRet
					Exit
				EndIf
			Next nCount
		Else
			// Caso as placas informadas não estejam cadastradas
			If Len(aEdit) == Len(aPlacas)
				MsgStop("Deve ser informada pelo menos uma placa na movimentação.", "Atenção")
				lRet := .F.
			Else
				// Excluir da movimentação placas não salvas
				For nCount := 1 To Len(aEdit)
					E2_DelPlaca(aEdit[nCount])
				Next nCount
				
				oLst:SetArray( E2_LstPlacas() )
			EndIf
		EndIf
	ElseIf Len(aPlacas) == 0
		MsgStop("Deve ser informada pelo menos uma placa na movimentação.", "Atenção")
		lRet := .F.
	EndIf

	For nCount := 1 To Len(aEtapa2[1])
		If lRet .And. AllTrim(aEtapa2[1][nCount][2][3]) == ""
			cPlacas := aEtapa2[1][nCount][2][1]
			If AllTrim(cPlacas) <> AllTrim(NOVAPLACA)
				cPlacas := Substr( AllTrim(aEtapa2[1][nCount][2][1]) ,1,3) +"-"+ Substr( AllTrim(aEtapa2[1][nCount][2][1]) ,4,4)
			EndIf
			
			MsgStop("Devem ser informados os dados do veículo com a Placa: "+ cPlacas + ".", "Atenção")
			lRet := .F.
		EndIf
	Next nCount
	
Return lRet

Static Function E2_Back()
Return .T.

Static Function E2_LBChange(oLB)
	E2_FrmReset()
Return Nil

Static Function E2_BtnAdicionar()
	Local oLst		:= aoEtapa2[2]
	Local aVeic	:= E2_LstPlacas()
	Local cNova	:= NOVAPLACA
	
	If aScan(aVeic, cNova) == 0
		E2_AddPlaca(cNova)
		aVeic := E2_LstPlacas()
		oLst:SetArray( aVeic )
	EndIf
	
	oLst:Select(aScan(aVeic, cNova))
Return Nil

Static Function E2_BtnExcluir()
	Local oLst		:= aoEtapa2[2]
	Local aVeic	:= aEtapa2[1]
	Local cPlaca 	:= oLst:GetSelText()
	
	If !Empty(cPlaca)
		E2_DelPlaca(cPlaca)
		
		aVeic := E2_LstPlacas()
		oLst:SetArray( E2_LstPlacas() )
		If Len(aVeic) > 0
			oLst:Select(1)
			E2_FrmReset()
		EndIf
	EndIf
Return Nil

Static Function E2_BtnSalvar()
	Local oLst		:= aoEtapa2[2]
	Local cPlaca 	:= oLst:GetSelText()
	E2_SavPlaca(cPlaca)
Return Nil

Static Function E2_BtnCadComp()
	Local oLst	:= aoEtapa2[2]

	dbSelectArea("GU8")
	GU8->(dbSetOrder(2))
	If GU8->(dbSeek(xFilial("GU8") + oLst:GetSelText())) //StrTran(oLst:GetSelText(), "-") ))
		If lIncVei
			// Desabilitado esta funcao abaixo para deixar campos específicos desabilitados
			// FWExecView("",'GFEA046',MODEL_OPERATION_UPDATE,,{||.T.})
			If lIntOMS	// Se integrado com o OMS, somente visualização
				FWExecView("",'GFEA046',MODEL_OPERATION_VIEW,,{||.T.})
			Else
				E2_CadCompleto()
			EndIf
		Else
			FWExecView("",'GFEA046',MODEL_OPERATION_VIEW,,{||.T.})
		EndIf
	EndIf

Return Nil


// Acessa nova tela deixando campos específicos desabilitados
Static Function E2_CadCompleto()
	Local aCoors
	Local oView  := FWLoadView("GFEA046")
	Local oModel := FWLoadModel("GFEA046")
	Local oFWMVCWindow

	aCoors := FWGetDialogSize(oMainWnd)

	oView:SetModel(oModel)
	oView:EnableControlBar(.T.)
	oView:SetOperation(MODEL_OPERATION_UPDATE)
	oView:SetUseCursor(.F.)
	oView:SetCloseOnOk( {|| .T.} )

	oView:GetViewStruct("GFEA046_GU8"):SetProperty("GU8_PLACA", 	MVC_VIEW_CANCHANGE, .F.)
	oView:GetViewStruct("GFEA046_GU8"):SetProperty("GU8_UFPLAC", 	MVC_VIEW_CANCHANGE, .F.)
	oView:GetViewStruct("GFEA046_GU8"):SetProperty("GU8_CDTPVC", 	MVC_VIEW_CANCHANGE, .F.)
	oView:GetViewStruct("GFEA046_GU8"):SetProperty("GU8_CDPROP", 	MVC_VIEW_CANCHANGE, .F.)
	oView:GetViewStruct("GFEA046_GU8"):SetProperty("GU8_TARA", 		MVC_VIEW_CANCHANGE, .F.)
	oView:GetViewStruct("GFEA046_GU8"):SetProperty("GU8_CARGUT", 	MVC_VIEW_CANCHANGE, .F.)
	oView:GetViewStruct("GFEA046_GU8"):SetProperty("GU8_MMOD", 		MVC_VIEW_CANCHANGE, .F.)
	oView:GetViewStruct("GFEA046_GU8"):SetProperty("GU8_ANOFAB", 	MVC_VIEW_CANCHANGE, .F.)
	
	oFWMVCWindow := FWMVCWindow():New()
	oFWMVCWindow:SetUseControlBar(.T.)
	oFWMVCWindow:SetView(oView)
	oFWMVCWindow:SetCentered(.T.)
	oFWMVCWindow:SetPos(aCoors[1],aCoors[2])
	oFWMVCWindow:SetSize(aCoors[3],aCoors[4])
	oFWMVCWindow:SetTitle("Cadastro Veículos")
	oFWMVCWindow:Activate()
	
Return


Static Function E2_FrmReset()
	Local oLst		:= aoEtapa2[2]
	Local cPlaca 	:= oLst:GetSelText()
	Local aPlaca	
	
	E2_LimpaFrm(.T.)
	
	If !Empty(cPlaca)
		aPlaca := E2_GetPlaca(cPlaca)
		
		If !Empty(aPlaca)
			If aPlaca[2][1] != NOVAPLACA
				aEtapa2[3] := aPlaca[1] //StrTran(aPlaca[2][1], "-")
			EndIf
			
			E2_Valid(.T.)
		EndIf
	EndIf
	
	aoEtapa2[7]:SetFocus()
Return Nil

Static Function E2_Valid(lLoad, cReadVar)
	Local lRet 		:= .T.
	Local oLst 		:= aoEtapa2[2]
	Local cPlaca
	Local aPlaca
	Local nCount
	
	Default lLoad	:= .F.
	Default cReadVar	:= ReadVar()
	
	Do Case
		Case lLoad
			aPlaca := E2_GetPlaca(oLst:GetSelText())
			
			E2_LimpaFrm()

			If !Empty(aPlaca)
				aEtapa2[4] := aPlaca[2][2]
				aEtapa2[5] := aPlaca[2][3]
				aEtapa2[6] := aPlaca[2][4]
				aEtapa2[7] := aPlaca[2][5]
				aEtapa2[8] := aPlaca[2][6]
				aEtapa2[9] := aPlaca[2][7]
				aEtapa2[10] := aPlaca[2][8]
				aEtapa2[11] := aPlaca[2][9]
				aEtapa2[12] := aPlaca[2][10]
			EndIf
			
		Case Upper(cReadVar) == Upper("aEtapa2[3]") .And. !lLoad // Placa
			aPlaca := E2_GetPlaca(oLst:GetSelText())
			cPlaca := aEtapa2[3] //StrTran(aEtapa2[3], "-")
			
			If lRet
				For nCount := 1 To Len(oLst:aItems)
					If nCount != oLst:nAt
						If AllTrim(cPlaca) == AllTrim(StrTran(oLst:aItems[nCount],"-")) 
							MsgStop("Placa já incluída neste acesso."+CRLF+" Informe outra placa.", "Atenção")
							lRet := .F.
						EndIf
					EndIf
				Next nCount
			EndIf

			If lRet .And. !Empty(cPlaca) .And. !lIncVei 
				If !ExistCpo("GU8", PadR(cPlaca, TamSX3("GU8_PLACA")[1]), 2)
					lRet := .F.
				EndIf
			EndIf
			
			If lRet
				If Empty(cPlaca)
					E2_LimpaFrm()
				Else
					E2_ChangePlaca(oLst:GetSelText(), cPlaca)
					aPlaca := E2_GetPlaca(cPlaca)
					
					If !Empty(aPlaca)
						aEtapa2[4]  := aPlaca[2][2]
						aEtapa2[5]  := aPlaca[2][3]
						aEtapa2[6]  := aPlaca[2][4]
						aEtapa2[7]  := aPlaca[2][5]
						aEtapa2[8]  := aPlaca[2][6]
						aEtapa2[9]  := aPlaca[2][7]
						aEtapa2[10] := aPlaca[2][8]
						aEtapa2[11] := aPlaca[2][9]
						aEtapa2[12] := aPlaca[2][10]
					Else
						E2_LimpaFrm()
					EndIf
				EndIf
			EndIf

		Case Upper(cReadVar) == Upper("aEtapa2[6]") // Proprietário
			If !Empty(aEtapa2[6]) .And. !ExistCpo("GU3", PadR(aEtapa2[6], TamSX3("GU3_NMEMIT")[1]), 1)
				lRet := .F.
			Else
				aEtapa2[7] := Posicione("GU3",1,xFilial("GU3")+aEtapa2[6],"GU3_NMEMIT")
			EndIf
			
		Case Upper(cReadVar) == Upper("aEtapa2[12]") // Ano Fabricação
			If Val(&(cReadVar)) < 0 .Or. Val(&(cReadVar)) > Year(DDATABASE)
				MsgAlert("Ano de Fabricação informado está incorreto.",'Atenção')
				lRet := .F.
			EndIf
	EndCase

	// Quando alterar um valor do formulário
	If lRet .And. !Empty(cReadVar) .And. Upper(cReadVar) != Upper("aEtapa2[3]") .And. !lLoad
		E2_EdtPlaca(oLst:GetSelText(),cReadVar,&(cReadVar))
	
		If Upper(cReadVar) != Upper("aEtapa2[6]")
			E2_EdtPlaca(oLst:GetSelText(),"aEtapa2[7]",aEtapa2[7])	
		EndIf
	EndIf
		
Return lRet

Static Function E2_LimpaFrm(lPlaca)
	Default lPlaca := .F.
	
	If lPlaca
		aEtapa2[3] := Space(8)
	EndIf
	
	aEtapa2[4] := Space(2)
	aEtapa2[5] := Space(TamSX3("GV3_CDTPVC")[1])
	aEtapa2[6] := Space(TamSX3("GU3_CDEMIT")[1])
	aEtapa2[7] := Space(TamSX3("GU3_NMEMIT")[1])
	aEtapa2[8] := 0
	aEtapa2[9] := 0
 	aEtapa2[10] := 0
	aEtapa2[11] := Space(TamSX3("GU8_MMOD")[1])
	aEtapa2[12] := Space(TamSX3("GU8_ANOFAB")[1])
Return Nil

Static Function E2_When(cCampo)
	Local lRet 	:= .T.
	Local oLst		:= aoEtapa2[2]
	Local aPlaca	:= E2_GetPlaca(oLst:GetSelText())
	
	If oLst:nAt > 0 .And. !Empty(aPlaca)
		Do Case
			Case cCampo == "btnSalvar"
				lRet := aPlaca[3]
			Case cCampo == "aEtapa2[5]" // Tipo de veículo
				lRet := aPlaca[4]	
		EndCase
	Else
		lRet := .F.
	EndIf
Return lRet

Static Function E2_TpVcChange()
	Local cCdTpVc := PadR(aEtapa2[5], TamSX3("GV3_CDTPVC")[1])
	
	dbSelectArea("GV3")
	GV3->( dbSetOrder(1) )
	If GV3->( dbSeek(xFilial("GU8") + cCdTpVc ) )
		aEtapa2[8] 	:= GV3->GV3_TARA
		aEtapa2[9] 	:= GV3->GV3_CARGUT
	 	aEtapa2[10] 	:= GV3->GV3_CARGUT + GV3->GV3_TARA
	 	E2_Valid(.F., 'aEtapa2[8]')
	 	E2_Valid(.F., 'aEtapa2[9]')
	 	E2_Valid(.F., 'aEtapa2[10]')
	EndIf
Return Nil

//
// Etapa 3 - Motoristas
//
Static Function E3_SavMot(cCPF)
	Local lRet 	:= .T.
	Local aCPF 	:= E3_GetMotora(cCPF)
	Local oModel
	Local cModel
	Local aCampos
	Local nCount
	Local cCod
	Local nOp
	
	Local aRet := {}
	Private cCodPOnto := ""	
	// Pré-validação dos dados do formulário
	If Empty(aCPF[2][1]) .Or. AllTrim(aCPF[2][1]) == NOVOMOTORISTA
		MsgStop("Informe o CPF do Motorista.", "Atenção")
		lRet := .F.
	EndIf

	If lRet .And. Empty(aCPF[2][2])
		MsgStop("Informe o Nome do Motorista.", "Atenção")
		lRet := .F.
	EndIf
	
	If lRet .And. Empty(aCPF[2][3])
		MsgStop("Informe o Apelido do Motorista.", "Atenção")
		lRet := .F.
	EndIf

	If lRet
		If !aCPF[4] // Edição
			If lIntOMS
				cCod := Posicione("DA4",3,xFilial("DA4")+aCPF[2][1],"DA4_COD")
			Else
				cCod := Posicione("GUU",2,xFilial("GUU")+aCPF[2][1],"GUU_CDMTR")
			EndIf		
		Else // Inserção
			If lIntOMS
				cCod := GetSXENum("DA4", "DA4_COD")
			Else
				cCod := GetSXENum("GUU", "GUU_CDMTR")
			EndIf
			
			ConfirmSX8()
		EndIf
		
		If Empty(cCod)
			MsgStop("Não foi possível encontrar o código do motorista " + aCPF[2][1] + ".","Atenção")
			lRet := .F.
		EndIf
	EndIf
	
	If lRet
		If lIntOMS
			cModel := "OMSA040"

			aCampos :=	{;
							{"OMSA040_DA4", "DA4_COD", 		cCod},;							// Tamanho CHARACTER | 6
							{"OMSA040_DA4", "DA4_CGC", 		aCPF[2][1]},;						// Tamanho CHARACTER | 14
							{"OMSA040_DA4", "DA4_NOME", 	Substr( aCPF[2][2] ,0,40 ) },;	// Tamanho CHARACTER | 40
							{"OMSA040_DA4", "DA4_NREDUZ", 	Substr( aCPF[2][3] ,0,15 ) },;	// Tamanho CHARACTER | 15
							{"OMSA040_DA4", "DA4_RG", 		aCPF[2][4]},;						// Tamanho CHARACTER | 15
							{"OMSA040_DA4", "DA4_RGORG", 	Substr( aCPF[2][5] ,0,3 ) };	// Tamanho CHARACTER | 3
						}
		Else
			cModel := "GFEA012"

			aCampos :=	{;
							{"GFEA012_GUU", "GUU_CDMTR", 	cCod},;		//iSeq := GetSXENum("GU8", "GU8_CDVEIC") - Tamanho CHARACTER | 6
							{"GFEA012_GUU", "GUU_IDFED", 	aCPF[2][1]},;	// Tamanho CHARACTER | 14
							{"GFEA012_GUU", "GUU_NMMTR", 	aCPF[2][2]},;	// Tamanho CHARACTER | 50
							{"GFEA012_GUU", "GUU_PSEUD", 	aCPF[2][3]},;	// Tamanho CHARACTER | 20
							{"GFEA012_GUU", "GUU_RG", 	 	aCPF[2][4]},;	// Tamanho CHARACTER | 15
							{"GFEA012_GUU", "GUU_ORGEXP",	aCPF[2][5]},;	// Tamanho CHARACTER | 6
							{"GFEA012_GUU", "GUU_TPMTR", 	"1"};			// Tipo Motorista Fixo valor 1
						}
		EndIf

		/*Ponto de entrada Sementes Goias
	      Permite aplicar regras de validações com base nas respostas dos campos.
	      Também define a oredem dos campos na tela.
	    */
	    If ExistBlock("GFEA5225")
	   		cCodPOnto :=  cCod
			aRet    := ExecBlock("GFEA5225", .F., .F., {aEtapa3, aCampos})
			lRet    := aRet[1]
			aEtapa3 := aRet[2]
			aCampos := aRet[3]
			
			If !lRet
				aEtapa3[1] := {}
				Return Nil
			EndIf
			 
		EndIF
			
		nOp := If(aCPF[4], MODEL_OPERATION_INSERT, MODEL_OPERATION_UPDATE)

		If nOp == MODEL_OPERATION_UPDATE
			//Posicionar no registro
			If lIntOMS
				dbSelectArea("DA4")
				DA4->( dbSetOrder(1) )
				DA4->( dbSeek( xFilial("DA4") + cCod ) )
			Else
				dbSelectArea("GUU")
				GUU->( dbSetOrder(1) )
				GUU->( dbSeek( xFilial("GUU") + cCod ) )
			EndIf
		EndIf

		oModel := FWLoadModel( cModel )
		oModel:SetOperation( nOp )
		oModel:Activate()
		
		For nCount := 1 To Len(aCampos)
			If oModel:GetModel( aCampos[nCount][1] ):GetStruct():HasField( aCampos[nCount][2] )
				If nOp == MODEL_OPERATION_INSERT .Or. (nOp == MODEL_OPERATION_UPDATE .And. !(aCampos[nCount][2] $ "GUU_CDMTR;DA4_COD"))
					If !oModel:SetValue(aCampos[nCount][1], aCampos[nCount][2], aCampos[nCount][3])
						lRet := .F.
						Exit
					Else
						&("M->" + aCampos[nCount][2]) := aCampos[nCount][3]
					EndIf
				EndIf
			EndIf
		Next nCount
		
		If lRet .And. oModel:VldData()
			oModel:CommitData()			
		Else
			aErro := oModel:GetErrorMessage()
			
			MsgStop(AllToChar(aErro[6]) + CRLF +;
					 AllToChar(aErro[7]) + CRLF + CRLF +;
					 "Campo: " + AllToChar(aErro[2]) + CRLF +;
					 "Valor: " + AllToChar(aErro[9]),;
 					 'Atenção')
			lRet := .F. 
		EndIf
		
		oModel:DeActivate()
	EndIf

	If lRet
		// Se salvar não está mais "em edição" ou como "novo registro"
		For nCount := 1 To Len(aEtapa3[1])
			// CPF Formatado
			// If AllTrim( StrTran(StrTran(aEtapa3[1][nCount][1],"."),"-") ) == AllTrim( StrTran(StrTran(cCPF,"."),"-") )
			If AllTrim( aEtapa3[1][nCount][1] ) == AllTrim( cCPF )
				aEtapa3[1][nCount][3] := .F.
				aEtapa3[1][nCount][4] := .F.
				Exit
			EndIf
		Next nCount
	EndIf
Return .T.

// Deixa campo em edição ou não
Static Function E3_When(cCampo)
	Local lRet	:= .T.
	Local oLst	:= aoEtapa3[2]
	Local aCPF	:= E3_GetMotora(oLst:GetSelText())
	
	If oLst:nAt > 0 .And. !Empty(aCPF)
		Do Case
			Case cCampo == "btnSalvar"
				lRet := aCPF[3]
			Case cCampo == "aEtapa3[4]" // Nome
				lRet := aCPF[4]	// Retorno True ou False de acordo com o STATUS do Array
		EndCase
	Else
		lRet := .F.
	EndIf
Return lRet

Static Function E3_BtnAdicionar()
	Local oLst		:= aoEtapa3[2]
	Local aMotora	:= E3_LstMotora()

	If aScan(aMotora, NOVOMOTORISTA) == 0
		E3_AddMotora(NOVOMOTORISTA)
		aMotora := E3_LstMotora()
		oLst:SetArray( aMotora )
	EndIf
	
	oLst:Select(aScan(aMotora, NOVOMOTORISTA))
Return Nil

Static Function E3_LBChange()
	E3_FrmReset()
Return Nil

Static Function E3_FrmReset()
	Local oLst	:= aoEtapa3[2]
	Local cCPF	:= oLst:GetSelText()
	Local aMotora

	E3_LimpaFrm(.T.)

	If !Empty(cCPF)
		aMotora := E3_GetMotora(cCPF)

		If !Empty(aMotora)
			If aMotora[2][1] != NOVOMOTORISTA
				// Add CPF Formatado
				//aEtapa3[3] := StrTran(StrTran(aMotora[2][1], "."), "-")
				aEtapa3[3] := aMotora[2][1]
			EndIf

			E3_Valid(.T.)
		EndIf
	EndIf
	If lFocusCPF
		aoEtapa3[7]:SetFocus()
	EndIf
Return Nil

Static Function E3_GetMotora(cCPF)
	Local aItens	:= aEtapa3[1]
	Local aRet		:= {}
	Local nItem	:= 0

	// CPF Formatado
	//cCPF := AllTrim(StrTran(StrTran(cCPF, "."), "-"))
	cCPF := AllTrim(cCPF)

	// CPF Formatado
	//nItem := aScan( aItens, {|x| AllTrim(StrTran(StrTran(x[1], "."),"-")) == cCPF } )
	nItem := aScan( aItens, {|x| AllTrim(x[1]) == cCPF } )

	If nItem > 0
		aRet := aItens[nItem]
	EndIf
Return aRet

Static Function E3_AddMotora(cCPF)
	Local aItem := E3_MotoraItem(cCPF)
	aAdd(aEtapa3[1], aItem)
Return Nil

Static Function E3_MotoraItem(cCPF, cChave)
	Local aItem		:= {}
	Local lRetMoto	:= .T.
	Default cChave	:= cCPF

	// CPF Formatado
	//cCPF	:= AllTrim(StrTran(StrTran(cCPF, "."), "-"))
	cCPF	:= AllTrim(cCPF)

	aItem	:= {;
					cChave,;	// Chave no Listbox
					{;
						cCPF,;									// CPF
						Space(TamSX3("GUU_NMMTR")[1]),;		// Nome
						Space(TamSX3("GUU_PSEUD")[1]),;		// Responde por
						Space(TamSX3("GUU_RG")[1]),;		// RG
						Space(TamSX3("GUU_ORGEXP")[1]);		// Orgão Expedidor
					},;
					.F.,;	// lEditado
					.T.;  	// Novo Motora
				}
	If !Empty(cCPF)
		dbSelectArea("GUU")
		GUU->( dbSetOrder(2) )
		If GUU->( dbSeek(xFilial("GUU") + cCPF ) )
			lRetMoto := .F.
			While GUU->(!Eof()) .And. GUU->GUU_FILIAL == xFilial("GUU") .And. AllTrim(GUU->GUU_IDFED) == cCPF
					
				If GUU->GUU_SIT == "1"	
					lRetMoto := .T.
					aItem[2][1]		:= GUU->GUU_IDFED
					aItem[2][2] 	:= GUU->GUU_NMMTR
					aItem[2][3] 	:= GUU->GUU_PSEUD
					aItem[2][4] 	:= GUU->GUU_RG
					aItem[2][5] 	:= GUU->GUU_ORGEXP
					aItem[4] 		:= .F.
				EndIf
				GUU->( dbSkip() )
			EndDo		
		EndIf
	EndIf

Return aItem

Static Function E3_LstMotora()
	Local aItens	:= aEtapa3[1]
	Local aRet		:= {}
	Local nCount	:= 0
	Local cCPF

	For nCount := 1 To Len(aItens)
		cCPF := aItens[nCount][1]
		
		// CPF Formatado
		aAdd(aRet, If(aItens[nCount][1] != NOVOMOTORISTA, cCPF , cCPF ) )

	Next nCount

Return aRet

Static Function E3_ChangeMotora(cChave, cCPF)
	Local nCount
	Local oLst := aoEtapa3[2]
	lFocusCPF := .F.
	For nCount := 1 To Len(aEtapa3[1])
		// CPF Formatado
		
		If AllTrim( StrTran(StrTran(aEtapa3[1][nCount][1],"."),"-") ) == AllTrim( StrTran(StrTran(cChave,"."),"-") )
			If AllTrim( StrTran(StrTran(aEtapa3[1][nCount][2][1],"."),"-") ) != AllTrim( StrTran(StrTran(cCPF,"."),"-") )
				aEtapa3[1][nCount] := E3_MotoraItem(cCPF)
				//oLst:Modify(cPlaca, oLst:nAt)
				oLst:Modify(Substr(cCPF, 1,3) + "." + Substr(cCPF, 4,3) + "." + Substr(cCPF, 7,3) + "-" + Substr(cCPF, 10,2),oLst:nAt)
				oLst:Select(aScan(oLst:aItems,{|x| AllTrim(StrTran(StrTran(x,"."),"-")) == AllTrim(StrTran(StrTran(cCPF,"."),"-"))}))
			EndIf

			Exit
		EndIf
		
		
		If AllTrim( aEtapa3[1][nCount][1] ) == AllTrim( cChave )
			If AllTrim( aEtapa3[1][nCount][2][1] ) != AllTrim( cCPF )
				aEtapa3[1][nCount] := E3_MotoraItem(cCPF)
				nAt := oLst:nAt
				oLst:SetItems(E3_LstMotora())
				oLst:Select(nAt)
				aEtapa3[3] := cCPF
			EndIf
			
			Exit
		EndIf
		
	Next nCount
	lFocusCPF := .T.
Return Nil

Static Function E3_LimpaFrm(lCPF)
	Default lCPF := .F.
	
	If lCPF
		aEtapa3[3] := Space(14)
	EndIf
	
	aEtapa3[4] := Space(TamSX3("GUU_NMMTR")[1])	// Nome
	aEtapa3[5] := Space(TamSX3("GUU_PSEUD")[1])	// Responde por
	aEtapa3[6] := Space(TamSX3("GUU_RG")[1])		// RG
	aEtapa3[7] := Space(TamSX3("GUU_ORGEXP")[1])	// Orgão Expedidor

Return Nil

Static Function E3_Valid(lLoad, cReadVar)
	Local lRet 	:= .T.
	Local oLst 	:= aoEtapa3[2]
	Local cCPF
	Local aMotora
	Local nCount
	
	Default lLoad	:= .F.
	Default cReadVar := ReadVar()
	
	Do Case
		Case lLoad
			aMotora := E3_GetMotora(oLst:GetSelText())

			E3_LimpaFrm()

			If !Empty(aMotora)
				aEtapa3[4]  := aMotora[2][2]
				aEtapa3[5]  := aMotora[2][3]
				aEtapa3[6]  := aMotora[2][4]
				aEtapa3[7]  := aMotora[2][5]
			EndIf

		Case Upper(cReadVar) == Upper("aEtapa3[3]") .And. !lLoad // CPF
			aMotora := E3_GetMotora(oLst:GetSelText())
			// CPF Formatado
			//cCPF := AllTrim(StrTran(StrTran(aEtapa3[3], "."), "-"))
			cCPF := AllTrim(aEtapa3[3])

			If lRet .And. !Empty(cCPF) .And. Len(cCPF) < 11
				MsgStop("Informe o CPF corretamente.", "Atenção")
				lRet := .F.
			EndIf

			If lRet
				For nCount := 1 To Len(oLst:aItems)
					If nCount != oLst:nAt
						// CPF Formatado
						// If cCPF == AllTrim( StrTran(StrTran(oLst:aItems[nCount],"."),"-") )
						If cCPF == AllTrim( oLst:aItems[nCount] ) 
							MsgStop("CPF já incluído neste acesso."+CRLF+" Informe outro CPF.", "Atenção")
							lRet := .F.
						EndIf
					EndIf
				Next nCount
			EndIf

			If lRet
				If cCPF <> ""
					dbSelectArea("GUU")
					GUU->( dbSetOrder(2) )
					If !GUU->( dbSeek(xFilial("GUU")+ cCPF ) ) .And. !lIncMot // Nao permite cadastrar motoristas na portaria
						MsgStop("CPF do Motorista não cadastrado." + CRLF + "O motorista deve ser cadastrado no programa de manutenção de motoristas.",'Atenção')
						lRet := .F.
					EndIf
				EndIf
			EndIf

			If lRet .And. !Empty(cCPF) .And. !lIncMot 
				If !ExistCpo("GUU", PadR(cCPF, TamSX3("GUU_IDFED")[1]), 2)
					lRet := .F.
				EndIf
			EndIf

			If lRet
				If Empty(cCPF)
					E3_LimpaFrm()
				Else
					E3_ChangeMotora(oLst:GetSelText(), cCPF)
					aMotora := E3_GetMotora(cCPF)

					If !Empty(aMotora)
						aEtapa3[4] := aMotora[2][2]
						aEtapa3[5] := aMotora[2][3]
						aEtapa3[6] := aMotora[2][4]
						aEtapa3[7] := aMotora[2][5]
					Else
						E3_LimpaFrm()
					EndIf
				EndIf
			EndIf
	EndCase
	
	// Quando alterar um valor do formulário
	If lRet .And. !Empty(cReadVar) .And. Upper(cReadVar) != Upper("aEtapa3[3]") .And. !lLoad
		E3_EdtMotora(oLst:GetSelText(),cReadVar,&(cReadVar))
	EndIf

Return lRet

Static Function E3_EdtMotora(cCPF, cCampo, xVal)
	Local nCount
	Local aCampos :=	{;
							{'aEtapa3[3]', 1},;
							{'aEtapa3[4]', 2},;
							{'aEtapa3[5]', 3},;
							{'aEtapa3[6]', 4},;
							{'aEtapa3[7]', 5};
						}
	Local nPos

	For nCount := 1 To Len(aEtapa3[1])
		// CPF Formatado
		//If AllTrim( StrTran(StrTran(aEtapa3[1][nCount][1],"."),"-") ) == AllTrim( StrTran(StrTran(cCPF,"."),"-") )
		If AllTrim( aEtapa3[1][nCount][1] ) == AllTrim( cCPF )
			nPos := aScan(aCampos, {|x| Upper(x[1]) == Upper(cCampo) })		
			
			If nPos > 0 .And. aEtapa3[1][nCount][2][nPos] != xVal
				aEtapa3[1][nCount][2][nPos] := xVal
				aEtapa3[1][nCount][3] 		:= .T.
			EndIf
			
			Exit
		EndIf
	Next nCount
Return Nil

Static Function E3_BtnExcluir()
	Local oLst		:= aoEtapa3[2]
	Local aMotora	:= aEtapa3[1]
	Local cCPF 	:= oLst:GetSelText()

	If !Empty(cCPF)
		E3_DelMotora(cCPF)

		aMotora := E3_LstMotora()
		oLst:SetArray( E3_LstMotora() )
		If Len(aMotora) > 0
			oLst:Select(1)
			E3_LBChange(oLst)
		EndIf
	EndIf
Return Nil

Static Function E3_Load()
	Local cCPF		:= AllTrim(aEtapa1[2])
	Local oLst		:= aoEtapa3[2]
	Local aMotora	:= E3_LstMotora()
	Local nCount	:= 0
	Local cLstMot := ""

	// Adiciona placa da etapa 1
	If Len(aMotora) == 0
		E3_AddMotora(cCPF)
		oLst:SetArray(E3_LstMotora())
	Else
		For nCount := 1 To Len(aMotora)
			// CPF Formatado
			//cLstMot += ";" + StrTran( StrTran(aMotora[nCount],"-","") ,".","")
			cLstMot += ";" + AllTrim( aMotora[nCount] )
		Next nCount		
		
		If !(cCPF $ cLstMot)
			E3_AddMotora(cCPF)
			oLst:SetArray(E3_LstMotora())
		EndIf
	EndIf
	
	If oLst:Len() > 0
		oLst:Select(oLst:Len())
	EndIf
	
	If Empty(aEtapa3[3])
		aEtapa3[3] := cCPF
	EndIf
	
	aoEtapa3[7]:CtrlRefresh()
	aoEtapa3[7]:Refresh()
	E3_LBChange(aoEtapa3[2])
	aoEtapa3[7]:SetFocus()
Return .T.

Static Function E3_Next()
	Local aCPFs 	:= aEtapa3[1]
	Local oLst		:= aoEtapa3[2]
	Local nCount	:= 0
	Local lRet 	:= .T.
	Local aEdit	:= {}
	Local cCPF		:= ""
	Local cAux		:= ""
	
	// Verificar se tem motoristas com alterações a serem salvas
	For nCount := Len(aCPFs) To 1 Step -1
		If aCPFs[nCount][3]
			aAdd(aEdit, aCPFs[nCount][1])
			cAux := aCPFs[nCount][1]
			If Empty(cCPF)
				cCPF += cAux + "?" + CRLF
			Else
				cCPF := cAux + "," + CRLF + cCPF
			EndIf
		EndIf
		
		If lRet .And.  Posicione("GUU",2,xFilial("GUU") + aCPFs[nCount][1], "GUU_SIT") == "3"
		   MsgStop("Situação do Motorista " + aCPFs[nCount][1] + " está como Entrada Proibida. Ajuste a situação para continuar o cadastro do acesso.", "Atenção")
		   lRet := .F.
		EndIf	
	Next nCount
	
	
	If !Empty(cCPF)
		If MsgYesNo("Deseja salvar as informações dos motoristas:" + CRLF + cCPF + "Motoristas sem alterações salvas serão excluídos da movimentação.")
			For nCount := 1 To Len(aEdit)
				lRet := E3_SavMot(aEdit[nCount])
				
				If !lRet
					Exit
				EndIf
			Next nCount
		Else
			// Caso os CPFs informados não forem cadastrados
			If Len(aEdit) == Len(aCPFs)
				MsgStop("Deve ser informado ao menos um motorista na movimentação.", "Atenção")
				lRet := .F.
			Else
				// Excluir da movimentação placas não salvas
				For nCount := 1 To Len(aEdit)
					E3_DelMotora(aEdit[nCount])
				Next nCount
				
				oLst:SetArray( E3_LstMotora() )
			EndIf
		EndIf
	ElseIf Len(aCPFs) == 0
		MsgStop("Deve ser informado ao menos um motorista na movimentação.", "Atenção")
		lRet := .F.
	EndIf

	For nCount := 1 To Len(aEtapa3[1])
		If lRet .And. AllTrim(aEtapa3[1][nCount][2][2]) == ""
			cCPF := aEtapa3[1][nCount][2][1]
			If AllTrim(cCPF) <> AllTrim(NOVOMOTORISTA)			
				cCPF := Substr(cCPF, 1,3) + "." + Substr(cCPF, 4,3) + "." + Substr(cCPF, 7,3) + "-" + Substr(cCPF, 10,2)
			EndIf
			MsgStop("Deve ser informado o nome do motorista com o CPF: "+ cCPF + ".", "Atenção")
			lRet := .F.
		EndIf
	Next nCount
	
Return lRet

Static Function E3_DelMotora(cCPF)
	Local nCount	:= 0
	Local nPos 	:= 0
	
	For nCount := 1 To Len(aEtapa3[1])
		// CPF Formatado
		//If AllTrim( StrTran(StrTran(aEtapa3[1][nCount][1],"."),"-") ) == AllTrim( StrTran(StrTran(cCPF,"."),"-") )
		If AllTrim( aEtapa3[1][nCount][1] ) == AllTrim( cCPF )
			nPos := nCount
			Exit
		EndIf
	Next nCount

	If nPos > 0
		aDel(aEtapa3[1], nPos)
		aSize(aEtapa3[1], Len(aEtapa3[1]) - 1)
	EndIf
Return Nil

Static Function E3_BtnSalvar()
	Local oLst	:= aoEtapa3[2]
	Local cCPF	:= oLst:GetSelText()
	E3_SavMot(cCPF)
Return Nil

Static Function E3_BtnCadComp()
	Local oLst	:= aoEtapa3[2]

	dbSelectArea("GUU")
	GUU->( dbSetOrder(2) )
	If GUU->( dbSeek( xFilial("GUU") + oLst:GetSelText() ) )
		If lIncMot
			// Desabilitado esta funcao abaixo para deixar campos específicos desabilitados
			//FWExecView("",'GFEA012',MODEL_OPERATION_UPDATE,,{||.T.})

			If lIntOMS	// Se integrado com o OMS, somente visualização
				FWExecView("",'GFEA012',MODEL_OPERATION_VIEW,,{||.T.})
			Else
				E3_CadCompleto()
			EndIf
		Else
			FWExecView("",'GFEA012',MODEL_OPERATION_VIEW,,{||.T.})
		EndIf
	EndIf

Return Nil

// Acessa nova tela deixando campos específicos desabilitados
Static Function E3_CadCompleto()
	Local aCoors
	Local oView  := FWLoadView("GFEA012")
	Local oModel := FWLoadModel("GFEA012")
	Local oFWMVCWindow
	
	aCoors := FWGetDialogSize(oMainWnd)
				
	oView:SetModel(oModel)
	oView:EnableControlBar(.T.)
	oView:SetOperation(MODEL_OPERATION_UPDATE)
	oView:SetUseCursor(.F.)
	oView:SetCloseOnOk({|| .T.})
	
	oView:GetViewStruct("GFEA012_GUU"):SetProperty("GUU_CDMTR", MVC_VIEW_CANCHANGE, .F.)
	oView:GetViewStruct("GFEA012_GUU"):SetProperty("GUU_NMMTR", MVC_VIEW_CANCHANGE, .F.)
	oView:GetViewStruct("GFEA012_GUU"):SetProperty("GUU_PSEUD", MVC_VIEW_CANCHANGE, .F.)
	oView:GetViewStruct("GFEA012_GUU"):SetProperty("GUU_TPMTR", MVC_VIEW_CANCHANGE, .F.)
	oView:GetViewStruct("GFEA012_GUU"):SetProperty("GUU_IDFED", MVC_VIEW_CANCHANGE, .F.)
	oView:GetViewStruct("GFEA012_GUU"):SetProperty("GUU_RG",    MVC_VIEW_CANCHANGE, .F.)
	oView:GetViewStruct("GFEA012_GUU"):SetProperty("GUU_ORGEXP",MVC_VIEW_CANCHANGE, .F.)
	
	oFWMVCWindow := FWMVCWindow():New()
	oFWMVCWindow:SetUseControlBar(.T.)
	oFWMVCWindow:SetView(oView)
	oFWMVCWindow:SetCentered(.T.)
	oFWMVCWindow:SetPos(aCoors[1],aCoors[2])
	oFWMVCWindow:SetSize(aCoors[3],aCoors[4])
	oFWMVCWindow:SetTitle("Cadastro Motorista")
	oFWMVCWindow:Activate()
Return

Static Function E3_Back()
Return .T.

//
// Etapa 4 - Agendamentos
//

Static Function E4_Load()
	Local cAgenda	:= aEtapa1[3]
	Local oLst 	:= aoEtapa4[2]
	Local lEntra 	:= .T.
	Local cHora 	:= "", cDescOper := "", cDescTrans := Space(15)
	Local aRet      := {}
	Local s_GFEA5226 := ExistBlock("GFEA5226")
	Static cEntRet := .T.
	
	If IsInCallStack("GFEA523")
		cEntRet := .T.
	EndIf
	
	If cEntRet 
		aEtapa4 = {}
		// busca agendamentos
		dbSelectArea("GWV")
		GWV->( dbSetOrder(6) )
		If GWV->( dbSeek( xFilial("GWV") + '1' + DTOS(DDATABASE) ) )
			While GWV->( !Eof() ) .And. GWV->GWV_SIT == '1' .And. GWV->GWV_DTAGEN == DDATABASE
				cHora := Substring(GWV->GWV_HRAGEN,1,2)
				cHora += ":" + Substring(GWV->GWV_HRAGEN,3,2)
				cDescOper 	:= AllTrim( Substring( Posicione("GVI",1,xFilial("GVI")+GWV->GWV_CDOPER+GWV->GWV_SEQ,"GVI_DSCONF"), 0, 16 ) )
				cDescTrans	:= AllTrim( Posicione("GU3",1,xFilial("GU3")+GWV->GWV_CDEMIT,"GU3_NMEMIT") )
	
				If GWV->GWV_NRAGEN == AllTrim(cAgenda)
					aAdd(aEtapa4,	{.T.,GWV->GWV_NRAGEN,GWV->GWV_DTAGEN,cHora,AllTrim(GWV->GWV_CDOPER) +" ("+ cDescOper +")" ,AllTrim(GWV->GWV_CDEMIT) +" - "+ cDescTrans +" - "+ GWV->GWV_SEQ, GWV->GWV_SEQ, GWV->GWV_CDOPER } )
					
					lEntra := .F.
				Else
					aAdd(aEtapa4,	{.F.,GWV->GWV_NRAGEN,GWV->GWV_DTAGEN,cHora,AllTrim(GWV->GWV_CDOPER) +" ("+ cDescOper +")" ,AllTrim(GWV->GWV_CDEMIT) +" - "+ cDescTrans +" - "+ GWV->GWV_SEQ, GWV->GWV_SEQ, GWV->GWV_CDOPER } )
				EndIf
	
				/*Ponto de entrada Sementes Goias
			      Permite aplicar regras de validações com base nas respostas dos campos.
			      Também define a oredem dos campos na tela.
			    */
				If s_GFEA5226
					aRet := ExecBlock("GFEA5226", .F., .F., {aEtapa4})
					aEtapa4[Len(aEtapa4)] := Nil
					aEtapa4 := aRet
				EndIF
	
				GWV->( dbSkip() )
			EndDo
		EndIf
	EndIf

	If lEntra .And. !Empty(aEtapa4)
		cEntRet 		:= .F.
	EndIf

   	E4_LstRefresh()

Return .T.

Static Function E4_LstRefresh()
	Local oLst := aoEtapa4[2]
	
	oLst:SetArray(aEtapa4)
	oLst:bLine	  		:= {|| If(Len(aEtapa4) == 0, {.T.,"","","","","","",""}, { If(aEtapa4[oLst:nAt,1],oOK,oNO),aEtapa4[oLst:nAt,2],aEtapa4[oLst:nAt,3],aEtapa4[oLst:nAt,4],aEtapa4[oLst:nAt,5],aEtapa4[oLst:nAt,6]}) }
	oLst:bRClicked	:= {|| aEval(aEtapa4,{|x|x[1]:=!x[1]}),oLst:Refresh(.F.) }
	oLst:bLDblClick	:= {|| E4_VerifOper() }
	
	/*Ponto de entrada Sementes Goias
	  Permite aplicar regras de validações com base nas respostas dos campos.
	  Também define a oredem dos campos na tela.
	*/
	IF ExistBlock("GFEA5222")
		aRet := ExecBlock("GFEA5222",.F.,.F.,{,,,aoEtapa4,,})
		aoEtapa4 := aRet[4]
	EndIf
	
	oLst:Refresh()
Return

Static Function E4_VerifOper()
	Local oLst		 := aoEtapa4[2] 
	//Local cOper	 := ""
	Local cConfOp1 := ""
	Local cConfOp2 := ""
	Local nCount

	If !Empty(aEtapa4)
		aEtapa4[oLst:nAt][1] := !aEtapa4[oLst:nAt][1]

		For nCount := 1 To Len(aEtapa4)
		    If aEtapa4[nCount,1] == .T.
		    	//If cOper == ""
		    	If cConfOp1 == ""
		    		//cOper := aEtapa4[nCount,8]
		    		cConfOp1 := Posicione("GVI",1,xFilial("GVI")+ aEtapa4[nCount,8] + aEtapa4[nCount,7],"GVI_DSCONF")
		    	Else
		    		cConfOp2 := Posicione("GVI",1,xFilial("GVI")+ aEtapa4[nCount,8] + aEtapa4[nCount,7],"GVI_DSCONF")
		    		//If cOper <> aEtapa4[nCount,8]		// Compara Operação
		    		If cConfOp1 <> cConfOp2		// Compara Configuração de Operação
		    			MsgStop("Selecione agendamentos com Configurações de Operação iguais.",'Atenção')
		    			aEtapa4[oLst:nAt][1] := !aEtapa4[oLst:nAt][1]
		    		EndIf
		    	EndIf
		    EndIf
		Next
	EndIf

Return oLst:DrawSelect()

Static Function E4_Next()
Return .T.

Static Function E4_Back()
Return .T.

//
// Etapa 5 - Inform. Complementares
//

Static Function E5_Load()
	Local nCount
	Local x := ""
	Local nTamCDOPER := 16

	aEtapa5[5] := "-----------------------"+ CRLF +"Veículos:"+ CRLF
	For nCount := 1 To Len(aEtapa2[1])
		aEtapa5[5] += aEtapa2[1][nCount][1] + CRLF
	Next

	aEtapa5[5] += "-----------------------"+ CRLF +"Motoristas / Ajudantes:"+ CRLF
	For nCount := 1 To Len(aEtapa3[1])
		aEtapa5[5] += aEtapa3[1][nCount][1] + CRLF
	Next

	aEtapa5[5] += "-----------------------"+ CRLF +"Agendamentos:"+ CRLF

	For nCount := 1 To Len(aEtapa4)
	    If aEtapa4[nCount][1]
			// Agendamento
			If aEtapa4[nCount][2] <> ""
				aEtapa5[5] += aEtapa4[nCount][2] + CRLF

				x := aEtapa4[nCount][5]
				aEtapa5[1] := PadR(Substr(x, 1, At("(",x)-2),nTamCDOPER) // Atribui OPERACAO, mantém a variável com o espaçamento correto
				x := aEtapa4[nCount][6]
				aEtapa5[4] := Substr(x, 1, At("-",x)-1) // Atribui EMITENTE				
			EndIf

			If AllTrim(aEtapa4[nCount][5]) <> ""
				x := AllTrim( aEtapa4[nCount][5] )
				x := AllTrim( Substr(x, 1, At("(",x)-2) )

				aEtapa5[2]	:= Posicione("GVC",1,xFilial("GVC") + x,"GVC_DSOPER")
				//aEtapa5[3]	:= Posicione("GVI",1,xFilial("GVI") + x,"GVI_SEQ")
				aEtapa5[3]	:= aEtapa4[nCount][7]
			EndIf
	    EndIf
	Next

Return .T.

Static Function E5_Next()
	Local oModel
	Local aCamposGX3	:= {}
	Local lRet 			:= .T.
	Local nI   			:= 0
	Local cAux 			:= ""
	Local cCdVeic 		:= ""
	Local cErroGrava	:= ""
	Local cSoluGrava	:= ""
	Local lCdVeic		:= .F.
	Local lIsRomAGR		:= FindFunction("AX500AGPRM")
	Local lUsaUBA		:= .F.
	Local aRet 			:= {}
	Local cIncMot 		:=""
	Local lRetMoto		:= .T.
	Local cMV_GFEMVPE	:= SuperGetMV("MV_GFEMVPE",.T.,"1")
		
	If lRet
		If AllTrim(aEtapa5[1]) == "" .Or. AllTrim(aEtapa5[3]) == ""
			MsgStop("Obrigatório informar a Configuração de Operação.",'Atenção')
			lRet := .F.
		Else
			// GVI = Config. Operacao
			// GVC = Operacao

			// verifica se Config Operacao nao e a mesma do Agendamentos
			For nI := 1 To Len(aEtapa4)
				If aEtapa4[nI][1] == .T.
					// Agendamento
					If aEtapa4[nI][2] <> ""
						GWV->( dbSetOrder(1) )
						If GWV->( dbSeek( xFilial("GWV") + aEtapa4[nI][2] ) )
							While GWV->( !Eof() ) .And. GWV->GWV_FILIAL == xFilial("GWV") .And. GWV->GWV_NRAGEN == aEtapa4[nI][2]
								If GWV->GWV_CDOPER <> aEtapa5[1]
									MsgStop("Operação informada é diferente da"+ CRLF +"Operação do Agendamento selecionado.",'Atenção')
									lRet := .F.
								EndIf
								GWV->( dbSkip() )
							EndDo
						EndIf
					EndIf
				EndIf
			Next nI
			If lRet
				dbSelectArea("GVI")
				GVI->( dbSetOrder(1) )
			   	If GVI->( dbSeek( xFilial("GVI") + aEtapa5[1] + aEtapa5[3] ) )
					If GVI->GVI_IDOBAG == "1" .And. aScan(aEtapa4, {|x| x[1] == .T. }) == 0
						MsgStop("Obrigatório informar um Agendamento ou"+ CRLF +" selecione outra Configuração de Operação.",'Atenção')
						lRet := .F.
					EndIf
				Else
					MsgStop("Configuração de Operação não cadastrada.",'Atenção')
					lRet := .F.					
				EndIf
			EndIf
		EndIf
	EndIf	
	
	If lRet
		If AllTrim(aEtapa5[4]) == ""
			MsgStop("Obrigatório informar o Emitente.",'Atenção')
			lRet := .F.
		Else
			// GVM_IDBLOQ 	1=Bloquear   	2=Alertar
			If Posicione("GVM",1,xFilial("GVM") + "1" + AllTrim(aEtapa5[4]),"GVM_IDBLOQ") == "1"
				MsgStop("Emitente está bloqueado no cadastro de restrições, portanto, não poderá ser incluído na Movimentação.",'Atenção')
				lRet := .F.
			EndIf
		EndIf
	EndIf

   	// grava na base os movimentos e os filhos (veiculos/motoristas/agendamentos)
	If lRet
	
		If ExistBlock("GFEA5221")
			lExecProg := ExecBlock("GFEA5221",.F.,.F.,{})
			If lExecProg == .F.
				Help( ,, 'Help',, 'Você não tem permissão gravar o movimento', 1, 0 )
				Return .F.
			EndIf
		EndIf
	
	
		// Nao precisa gerar, pois e garado automaticamente o Nro do Movimento
		//cNRMOV := GetSXENum("GX3","GX3_NRMOV")
		//aAdd( aCamposGX3, { 'GX3_NRMOV',	cNRMOV } )
		aAdd( aCamposGX3, { 'GX3_FILIAL',	cFilAnt } )
		aAdd( aCamposGX3, { 'GX3_CDOPER',	AllTrim(aEtapa5[1]) } )
		aAdd( aCamposGX3, { 'GX3_SEQ',   	aEtapa5[3] } )
		aAdd( aCamposGX3, { 'GX3_CDEMIT',	AllTrim(aEtapa5[4]) } )
		
		/*Ponto de entrada Sementes Goias
	      Permite aplicar regras de validações com base nas respostas dos campos.
	      Também define a oredem dos campos na tela.
	    */
		If ExistBlock("GFEA5227")
			aRet       := ExecBlock("GFEA5227", .F., .F., {aEtapa5, aCamposGX3})
			lRet       := aRet[1]
			aEtapa5    := aRet[2]
			aCamposGX3 := aRet[3]
		EndIF

		If !GravaMov( @oModel, 'GX3', aCamposGX3, 'GFEA519', .F. )
			oModel:VldData()
			aErro := oModel:GetErrorMessage()
			
			cErroGrava := AllToChar( aErro[6] )
			cSoluGrava := AllToChar( aErro[7] )

			MsgStop(cErroGrava + CRLF + cSoluGrava,'Atenção')

			lRet := .F.
		EndIf

		// ########## VEICULOS
		dbSelectArea("GU8")
		GU8->(dbSetOrder(1))
		
		oModelGX6 := oModel:GetModel('GFEA519_GX6')
		For nI := 1 To Len(aEtapa2[1])
			oModelGX6:GoLine(oModelGX6:Length())
			cAux := AllTrim(aEtapa2[1][nI][1]) //StrTran(aEtapa2[1][nI][1],"-")

			oModelGX6:SetValue('GX6_FILIAL', cFilAnt)

			cCdVeic := GetCodVeic(cAux)
			
			If lRet .and. cMV_GFEMVPE <> "1"
				lCdVeic := GFEVldGX6(cCdVeic)
				
				If lCdVeic 
					Return .F.
				EndIf
			EndIf
			If !Empty(cCdVeic)
				oModelGX6:SetValue('GX6_CDVEIC', cCdVeic)
			EndIf		
			
			If lRet .And. !oModelGX6:VldLineData()
				aErro := oModel:GetErrorMessage()

				cErroGrava := AllToChar( aErro[6] )
				cSoluGrava := AllToChar( aErro[7] )
				
           	MsgStop(cErroGrava + CRLF + cSoluGrava,'Atenção')
              lRet := .F.

              Exit
			EndIf
			oModelGX6:AddLine(.T.)
		Next nI

		// ########## MOTORISTAS
		oModelGX8 := oModel:GetModel('GFEA519_GX8')
		For nI := 1 To Len(aEtapa3[1])
			oModelGX8:GoLine(oModelGX8:Length())
			cAux := StrTran(StrTran(aEtapa3[1][nI][1],"."),"-")

			dbSelectArea("GUU")
			GUU->( dbSetOrder(2) )
			If GUU->( dbSeek( xFilial("GUU") + cAux ) )
				lRetMoto := .F.
				While GUU->(!Eof()) .And. GUU->GUU_FILIAL == xFilial("GUU") .And. AllTrim(GUU->GUU_IDFED) == AllTrim(cAux)			
					If GUU->GUU_SIT == "1"	
						lRetMoto := .T.
						GUU->( dbSetOrder(1)) // Retorna para o indice 1 para ser utilizado na função existCpo() do valid do campo GX8_CDMTR  
						oModelGX8:SetValue('GX8_CDMTR', GUU->GUU_CDMTR )
					EndIf
					GUU->( dbSkip() )
				EndDo
			EndIf

			If lRet .And. !oModelGX8:VldLineData()
				aErro := oModel:GetErrorMessage()

				cErroGrava := AllToChar( aErro[6] )
				cSoluGrava := AllToChar( aErro[7] )
				
           	MsgStop(cErroGrava + CRLF + cSoluGrava,'Atenção')
              lRet := .F.

              Exit
			EndIf
			oModelGX8:AddLine(.T.)
		Next nI

		// ########## AGENDAMENTO
		oModelGWV := oModel:GetModel('GFEA519_GWV')
		For nI := 1 To Len(aEtapa4)
			If aEtapa4[nI][1] == .T.
				oModelGWV:GoLine(oModelGWV:Length())
				oModelGWV:SetValue('GWV_NRAGEN', aEtapa4[nI][2] )
				
				If lRet .And. !oModelGWV:VldLineData()
					aErro := oModel:GetErrorMessage()
	
					cErroGrava := AllToChar( aErro[6] )
					cSoluGrava := AllToChar( aErro[7] )
					
	           	MsgStop(cErroGrava + CRLF + cSoluGrava,'Atenção')
	              lRet := .F.
	              Exit
				EndIf
				oModelGWV:AddLine(.T.)
			EndIf
		Next nI

		If lRet .And. !oModel:VldData()
			aErro := oModel:GetErrorMessage()
	
			cErroGrava := AllToChar( aErro[6] )
			cSoluGrava := AllToChar( aErro[7] )

			MsgStop(cErroGrava + CRLF + cSoluGrava,'Atenção')
			
			lRet := .F.
		Else
			// Comita todos
			oModel:CommitData()
		EndIf

		// ******************************************* //
		//	 /****** CHAMADA AGROINDÚSTRIA *******/	   //
		// ******************************************* //
		If GFXPR12117("MV_AGRUBA") .and. lIsRomAGR
			lUsaUBA		:= SuperGetMv("MV_AGRUBA",.F.,.F.)	
			if lUsaUBA .AND. lRet
				AX500AGPRM()
			EndIf
		EndIf
		oModel:DeActivate()
	EndIf

Return lRet

Static Function E5_Valid(lLoad, cReadVar)
	Default lLoad	:= .F.
	Default cReadVar	:= ReadVar()

	If Upper(cReadVar) == Upper("aEtapa5[1]") .Or. Upper(cReadVar) == Upper("aEtapa5[3]")	//Operação ou Sequencia 
		aEtapa5[2] := Posicione("GVI", 1, xFilial("GVI") + aEtapa5[1] + aEtapa5[3], "GVI_DSCONF")		
	EndIf
	 
Return .T.			

Static Function E5_Back()
Return .T.

Static Function E6_Load()
	Local cAux := ""

	// GVJ - Pontos de Controle da tabela de Conf. Operacao
	dbSelectArea("GVJ")
	GVJ->(dbSetOrder(1))
	If GVJ->( dbSeek( xFilial("GVJ") + aEtapa5[1] + aEtapa5[3] ))
		// GVF - Ponto de Controle 	CODIGO="GVF_CDPTCT"  DESCRICAO="GVF_DSPTCT"
		cAux := Posicione("GVF",1,xFilial("GVF") + GVJ->GVJ_CDPTCT,"GVF_DSPTCT")
	EndIf
	
	aEtapa6[1] := "Encaminhe o veículo para: " + cAux

	oWizard:oBack:Hide()
	oWizard:oBack:Refresh()
	oWizard:oFinish:Hide()
	oWizard:oFinish:Refresh()
	oWizard:oCancel:Hide()
	oWizard:oCancel:Refresh()
	oWizard:oNext:Hide()
	oWizard:oNext:Refresh()
	cFilant := cBkpFilAnt
Return .T.

Static Function E6_NewEntrance()

	cFilAnt := FWPesqSM0("M0_CODFIL",cEmpAnt)  // Escolher a filial que deseja trabalhar
	
	If Empty(cFilAnt)
	    cFilAnt := cBkpFilAnt
	    Return
	EndIf

	cEntRet := .T.
	oWizard:oBack:Show()
	oWizard:oBack:Refresh()
	oWizard:oFinish:Show()
	oWizard:oFinish:Refresh()
	oWizard:oNext:Show()
	oWizard:oNext:Refresh()
	oWizard:oCancel:Show()
	oWizard:oCancel:Refresh()
	oWizard:SetPanel(1)
	ResetArrays()

	aoEtapa1[3]:SetFocus()
	aoEtapa1[3]:Refresh()
	
If IsInCallStack("GFEA523")
	oWizard:oBack:Hide()
	oWizard:oBack:Refresh()
	oWizard:oFinish:Hide()
	oWizard:oFinish:Refresh()
	oWizard:oCancel:Hide()
	oWizard:oCancel:Refresh()
	oWizard:oNext:Hide()
	oWizard:oNext:Refresh()
	cFilant := cBkpFilAnt
	EF_Fechar()
	GFEA522()	
Endif
	



Return

Static Function ResetArrays()

	aEtapa1 :={;
					Space(8),;								// Placa
					Space(14),;							// CPF Motorista
					Space(8);								// Nr Agendamento
				}

	aEtapa2 :={;
					{},;									// Placas (Veículos da movimentação)
					0,;										// Item Selecionado do ListBox
					Space(8),;								// Placa				INDICE 2
					Space(2),;								// UF Placa			
					Space(TamSX3("GV3_CDTPVC")[1]),;	// Tipo Veículo		OBRIGATORIO
					Space(TamSX3("GU3_CDEMIT")[1]),;	// Cod Proprietário  OBRIGATORIO
					Space(TamSX3("GU3_NMEMIT")[1]),;	// Desc Proprietário
					0,;										// Tara
					0,;										// Lotação
					0,;										// PBT
					Space(TamSX3("GU8_MMOD")[1]),;		// Marca/Model
					Space(TamSX3("GU8_ANOFAB")[1]),;	// Ano Fabricação
					.F.,;									// Editando?
					.F.;									// Novo registro?
				}
	
	aEtapa3 :={;
					{},;									// CPF's dos motoristas da movimentação
					0,;										// Motorista selecionado
					Space(14),;							// CPF Motorista 	CHAVE 2
					Space(TamSX3("GUU_NMMTR")[1]),;		// Nome			CHAVE 3
					Space(TamSX3("GUU_PSEUD")[1]),;		// Responde por	CHAVE 4
					Space(TamSX3("GUU_RG")[1]),;		// RG
					Space(TamSX3("GUU_ORGEXP")[1]),;	// Orgão Expedidor
					.F.,;									// Editando?
					.F.;									// Novo registro?
				}

	// Agendamentos
	aEtapa4 :={;
				  {	.T.,;
					"",;
					"",;
					"",;
					"",;
					"",;
					"",;	// 7 Seq. Operacao
					"",;	// 8 Operacao da Conf. de Operacao
				  };
				}

	aEtapa5 :={;
					Space(TamSX3("GVI_CDOPER")[1]),;	// Operação
					Space(TamSX3("GVI_DSOPER")[1]),; 	// Desc Operação
					Space(TamSX3("GVI_SEQ")[1]),;		// Sequência
					Space(TamSX3("GU3_CDEMIT")[1]),;	// Emitente
					"";										// Resumo
				}
							
	aEtapa6 :={;
				"";											// Instruções							
			   }
	If !Empty(aoEtapa4)
		E4_LstRefresh()
	EndIf
	
Return

/*/{Protheus.doc} GetUFS
Retorna array com UF's.

Uso Exclusivo.
	
@author Alan Victor Lamb
@since 14/01/2014
@version 1.0		

@return aUFS, Array contendo as UF's 
/*/
Static Function GetUFS()
	Local aUFs 		:= { "" }
	Local a522UFS 	:= { "" }
	Local cChave	:= ""
	Local nI        := 0	

	// Carrega UFS
	a522UFS := FWGetSX5("12")
	For nI := 1 To 28
		cChave := a522UFS[nI,3]
		aAdd(aUFs, AllTrim(cChave) )
	Next nI	
	
Return aUFs

/*/{Protheus.doc} GetTPVC
Retorna lista indexada de tipos de veículo. 
Se tiver integração com OMS estiver habilitada, retorna da tabela DUT, senão GV3.

Uso Exclusivo.
	
@author Alan Victor Lamb
@since 14/01/2014
@version 1.0

@return aTpVc, Lista indexada com tipos de veículo
/*/
Static Function GetTPVC()
	Local aTpVc := { "" }
	
	If lIntOMS
		dbSelectArea("DUT")
		DUT->(dbSetOrder(1))
		DUT->(dbGoTop())
		While DUT->(!Eof())
			aAdd(aTpVc, AllTrim(DUT->DUT_TIPVEI) + "=" + DUT->DUT_DESCRI)				
			DUT->( dbSkip() )
		EndDo
	Else
		dbSelectArea("GV3")
		GV3->(dbSetOrder(3))
		If GV3->(dbSeek( xFilial("GV3") + '1' ))
			While GV3->(!Eof()) .And. GV3->GV3_FILIAL == xFilial("GV3") .And. GV3->GV3_SIT == "1"		
				aAdd(aTpVc, AllTrim(GV3->GV3_CDTPVC) + "=" + GV3->GV3_DSTPVC)
				GV3->( dbSkip() )
			EndDo
		EndIf
	EndIf
Return aTpVc

/*/{Protheus.doc} GetTrpOMS
Busca código da transportadora no OMS
	
@author alan.victor
@since 22/01/2014
@version 1.0
		
@param cCdEmit, character, Código do emitente no GFE

@return cCod, código da transportadora no OMS
/*/
Static Function GetTrpOMS(cCdEmit)
	Local cCod := ""
	
	If !Empty(cCdEmit)
		dbSelectArea("GU3")
		GU3->( dbSetOrder( 1 ) )
		If GU3->( dbSeek(xFilial("GU3") + cCdEmit ) )
			If cNumEmi == "0" // Procura po CPF/CNPJ
				cCod := Posicione("SA2",3,xFilial("SA2")+GU3->GU3_IDFED,"A2_COD")
			Else
				cCod := Posicione("SA2",1,xFilial("SA2")+GU3->GU3_CDERP+GU3->GU3_CDCERP,"A2_COD")
			EndIf
		EndIf
	EndIf
Return cCod

/*/{Protheus.doc} GravaMov
Grava registros OMS
	
@author helder.santos
@since 13/02/2014
@version 1.0
		
@param objeto Model, alias, campos, string model, existe ou não

@return NIL
/*/
Static Function GravaMov( oModelGX3, cAlias, aCampos, cModel, lExiste )
	Local oAux, oStruct
	Local nI 	:= 0
	Local nPos	:= 0
	Local lRet	:= .T.
	Local aAux	:= {}
	Local lAux
	
	dbSelectArea( cAlias )
	(cAlias)->( dbSetOrder( 1 ) ) // 1=GX3_NRMOV
	// instancia do modelo de dados (Model)
	oModelGX3 := FWLoadModel( cModel )
	// OPERACAO >>> 3-Inclusao / 4–Alteracao / 5-Exclusao
	oModelGX3:SetOperation( If (lExiste , 4, 3) )
	// Antes de atribuirmos os valores dos campos temos que ativar o modelo
	oModelGX3:Activate()
	// Instanciamos apenas referentes aos dados
	oAux := oModelGX3:GetModel( cModel +"_"+ cAlias )
	// Obtemos a estrutura de dados
	oStruct := oAux:GetStruct()
	aAux := oStruct:GetFields()

	For nI := 1 To Len( aCampos )
		// Verifica se os campos passados existem na estrutura do modelo
		If ( nPos := aScan(aAux,{|x| AllTrim( x[3] )== AllTrim(aCampos[nI][1]) } ) ) > 0
			// feita a atribuição do dado ao campo do Model
			If !( lAux := oModelGX3:SetValue( cModel +"_"+ cAlias , aCampos[nI][1], aCampos[nI][2] ) )
				// Caso a atribuição não possa ser feita, por algum motivo (validação, por AdvPl utilizando MVC – 85 exemplo)
				lRet := .F.
				Exit
			EndIf
		EndIf
	Next nI

Return lRet

Static Function GetCodVeic(cPlaca)
	Local cRet := '' 
	Local aAreaGU8
	
	dbSelectArea("GU8")
	aAreaGU8 := GU8->(GetArea())
	
	GU8->(dbSetOrder(2))
	If GU8->(dbSeek(xFilial("GU8")+cPlaca))
		cRet := GU8->GU8_CDVEIC
	EndIf
	
	RestArea(aAreaGU8)
	
Return cRet


Function EF_Fechar()
	 oWizard:oModal:oOwner:End()
Return
 
Static Function RemChrEsp(cCPF)
	Local nCount := 1
 	Local cRet := ""
 	
 	While nCount <=  Len(cCPF)
 		If IsDigit(Substr(cCPF,nCount,1))
 			cRet += Substr(cCPF,nCount,1)
 		EndIf  	
		nCount++
 	EndDo
 	 
Return cRet

Function GFEVldGX6(cPlaca)
	Local cQuery	:= ""
	Local aRet		:= {}
	Local cMsg		:= ""
	Local cIncMot	:= ""
	Local cAliasGX6 := GetNextAlias()
	Local lRet5228	:= .T.
	Local lMostra 	:= .F.
	Local lRet	 	:= .F.
	
	If ExistBlock("GFEA5228")
		lRet5228    := ExecBlock("GFEA5228", .F., .F., {aEtapa2}) 
	EndIF
	If lRet5228
		If GFXPR12117("MV_GFEMVPE") 
			cIncMot := SuperGetMV("MV_GFEMVPE",.T.,"1")		
		EndIF	
	
		
		cQuery := " SELECT DISTINCT GX6_NRMOV, GX6_FILIAL "
		cQuery += " FROM "+RetSqlName("GX6")+" GX6 "
		cQuery += " INNER JOIN "+RetSqlName("GX3")+" GX3 ON GX3.D_E_L_E_T_ = ' ' AND GX3_NRMOV = GX6_NRMOV "
		cQuery += " INNER JOIN "+RetSqlName('GVC')+" GVC ON GVC.D_E_L_E_T_ = ' ' AND GVC_CDOPER = GX3_CDOPER"  
		cQuery += " WHERE GX6.D_E_L_E_T_ = ' ' "
		cQuery += " AND RTRIM(GX6_CDVEIC) = '"+Alltrim(cPlaca)+"' "
		cQuery += " AND GX3_SIT NOT IN ('3','4','5','6') "
		cQuery += " AND GX6_DTSAI = ' ' "
	
	
		cQuery := ChangeQuery(cQuery)
		dbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery),cAliasGX6, .F., .T.)	
	
		(cAliasGX6)->( dbGoTop() )
		cMsg += "Veículo "  + Alltrim(cPlaca) + " possui um ou mais movimentos em andamento. O sistema está configurado para [Alertar/Bloquear] o início de uma nova movimentação nessa condição."+ CRLF + CRLF	
		While (cAliasGX6)->( !Eof() )
			cMsg += "Filial/Movimento: " + (cAliasGX6)->GX6_FILIAL + CRLF
			cMsg += "Nr. Movimento...: " + (cAliasGX6)->GX6_NRMOV + CRLF
			
			GX3->(dbSetOrder(1))
			GX3->(dbSeek((cAliasGX6)->GX6_FILIAL + (cAliasGX6)->GX6_NRMOV))
			GVC->(dbSetOrder(01))
			GVC->(dbSeek(xFilial("GVC")+ GX3->GX3_CDOPER))
			cMsg += "Operação..........: " + GX3->GX3_CDOPER + " - " + GVC->GVC_DSOPER + CRLF

			GX4->(dbSetOrder(1))
			GX4->(dbSeek( (cAliasGX6)->GX6_FILIAL + (cAliasGX6)->GX6_NRMOV ) )					
			GVI->( dbSetOrder(1) )
			GVI->( dbSeek(xFilial("GVI") + GX3->GX3_CDOPER + GX4->GX4_SEQ) )						
			cMsg += "Conf. Operação.: " + GVI->GVI_SEQ + " - " + GVI->GVI_DSCONF + CRLF
					
			GVF->(dbSetOrder(1))
			GVF->(dbSeek(xFilial("GVF") + GX4->GX4_CDPTCT))
			cMsg += "Pto Controle......: " + GX4->GX4_CDPTCT + " - " + GVF->GVF_DSPTCT + CRLF + CRLF
			lMostra := .T.	
			(cAliasGX6)->(dbSkip())
		EndDo
	
		If cIncMot == "2" .and. lMostra // Alertar
			MsgAlert(cMsg)
		ElseIf cIncMot == "3" .and. lMostra // Bloquear
			MsgAlert(cMsg)
			lRet := .T.
		EndIf
		
		(cAliasGX6)->(DbCloseArea())
	EndIF
Return lRet


