#INCLUDE "GFEA071.ch"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"
 

// Códigos de mensagens padronizadas
#DEFINE GFEA071001 'GFEA071001'
#DEFINE GFEA071002 'GFEA071002'
#DEFINE GFEA071003 'GFEA071003'
#DEFINE GFEA071004 'GFEA071004'
#DEFINE GFEA071005 'GFEA071005'
#DEFINE GFEA071006 'GFEA071006'
#DEFINE GFEA071007 'GFEA071007'
#DEFINE GFEA071008 'GFEA071008'
#DEFINE GFEA071009 'GFEA071009'

//---------------------------------------------------------------------------------------------------
/*/{Protheus.doc} GFEA071
Auditoria de Faturas de Frete
Generico

@sample
GFEA071()

@author Felipe M.
@since 23/11/09
@version 1.0
/*///------------------------------------------------------------------------------------------------

// SONARQUBE - CA1003: Uso não permitido de chamada de API em LOOP

Static s_GFEI21   := SuperGetMV("MV_GFEI21",.F.,"3")
Static s_GFEI15   := SuperGetMV('MV_GFEI15',,'3')
Static s_VLCNPJ   := SuperGetMV('MV_VLCNPJ',,'1')
Static s_TPGERA   := SuperGetMV("MV_TPGERA",,"1")
Static s_GFEI15_2 := SuperGetMV('MV_GFEI15',,'1')
Static s_GFEPF1   := SuperGetMv("MV_GFEPF1",,'1')
Static s_GFEA0717 := ExistBlock("GFEA0717")

Function GFEA071()
	Local cFilPadrao := "GW6_SITAPR == '2'"

	If SuperGetMv("MV_ERPGFE",.F.,"2") == "1" .And. SuperGetMv("MV_FTMLA",.F.,"1") $ "2|3"
		GFEMessage(5, GFEA071001, STR0079, STR0080) // "Sistema parametrizado para realizar a aprovação de faturas de fretes através do módulo MLA." / "Acesse o módulo MLA para realizar as aprovações de faturas."
		Return Nil
	EndIf

	Private oBrowse

	oBrowse := FWMBrowse():New()
	oBrowse:SetAlias("GW6") // Alias da tabela utilizada
	oBrowse:SetMenuDef("GFEA071") // Nome do fonte onde esta a função MenuDef
	oBrowse:SetDescription(STR0001) //"Aprovação de Faturas de Frete"
	oBrowse:SetFilterDefault(cFilPadrao)

    // Início Ponto de Entrada 
 	If ExistBlock("GFEA0714")	
		oBrowse:SetFilterDefault(ExecBlock("GFEA0714",.f.,.f.,{cFilPadrao}))
	EndIf	

	oBrowse:Activate()

Return Nil

//------------------------------------------------------------------------------------------------

Static Function MenuDef()
	Local aRotina := {}

	// Adiciona botões do browse
	ADD OPTION aRotina TITLE STR0002 ACTION "VIEWDEF.GFEA071" OPERATION 2 ACCESS 0 //"Visualizar"
	ADD OPTION aRotina TITLE STR0003 ACTION "GFEA071ED()"     OPERATION 3 ACCESS 0 //"Aprovar"
	ADD OPTION aRotina TITLE STR0004 ACTION "VIEWDEF.GFEA071" OPERATION 8 ACCESS 0 //"Imprimir"

Return aRotina

//------------------------------------------------------------------------------------------------

Static Function ModelDef()
	Local oModel
	Local oStruGW3 := FWFormStruct(1, 'GW3', /*bAvalCampo*/, /*lViewUsado*/)
	Local oStruGWJ := FWFormStruct(1, 'GWJ', /*bAvalCampo*/, /*lViewUsado*/)

	// cID     Identificador do modelo
	// bPre    Code-Block de pre-edição do formulário de edição. Indica se a edição esta liberada
	// bPost   Code-Block de validação do formulário de edição
	// bCommit Code-Block de persistência do formulário de edição
	// bCancel Code-Block de cancelamento do formulário de edição
	oModel := MPFormModel():New("GFEA071", /*bPre*/, /*bPost*/,/*bCommit*/, /*bCancel*/)

	// cId          Identificador do modelo
	// cOwner       Identificador superior do modelo
	// oModelStruct Objeto com  a estrutura de dados
	// bPre         Code-Block de pré-edição do formulário de edição. Indica se a edição esta liberada
	// bPost        Code-Block de validação do formulário de edição
	// bLoad        Code-Block de carga dos dados do formulário de edição
	oModel:AddFields("GFEA071_GW6", Nil, FWFormStruct(1,"GW6"), /*bPre*/, /*bPost*/, /*bLoad*/)

	oModel:AddGrid('GFEA071_GW3', 'GFEA071_GW6', oStruGW3, /*bLinePre*/, /*bLinePost*/, /*bPre*/, /*bPost*/, /*bLoad*/)
	oModel:AddGrid('GFEA071_GWJ', 'GFEA071_GW6', oStruGWJ, /*bLinePre*/, /*bLinePost*/, /*bPre*/, /*bPost*/, /*bLoad*/)

	oModel:SetOptional('GFEA071_GW3', .T.)
	oModel:SetOptional('GFEA071_GWJ', .T.)

	oModel:SetRelation('GFEA071_GW3',{{'GW3_FILFAT','GW6_FILIAL'},{'GW3_EMIFAT','GW6_EMIFAT'},{'GW3_SERFAT','GW6_SERFAT'},{'GW3_NRFAT','GW6_NRFAT'}},'GW3_FILIAL+GW3_CDESP+GW3_EMISDF+GW3_SERDF+GW3_NRDF+DTOS(GW3_DTEMIS)')
	oModel:SetRelation('GFEA071_GWJ',{{'GWJ_FILFAT','GW6_FILIAL'},{'GWJ_EMIFAT','GW6_EMIFAT'},{'GWJ_SERFAT','GW6_SERFAT'},{'GWJ_NRFAT','GW6_NRFAT'}},'GWJ_FILIAL+GWJ_NRPF')

	oModel:SetPrimaryKey({"GW6_FILIAL", "GW6_EMIFAT", "GW6_SERFAT", "GW6_NRFAT"})

Return oModel

//------------------------------------------------------------------------------------------------

Static Function ViewDef()
	Local oModel     := FWLoadModel("GFEA071")
	Local oView      := Nil
	Local oStructGW3 := FWFormStruct(2, "GW3")
	Local oStructGWJ := FWFormStruct(2, "GWJ")

	oView := FWFormView():New()
	// Objeto do model a se associar a view.
	oView:SetModel(oModel)
	// cFormModelID - Representa o ID criado no Model que essa FormField irá representar
	// oStruct - Objeto do model a se associar a view.
	// cLinkID - Representa o ID criado no Model ,Só é necessári o caso estamos mundando o ID no View.
	oView:AddField("GFEA071_GW6", FWFormStruct(2, "GW6"), /*cLinkID*/)
	// cID		  	Id do Box a ser utilizado
	// nPercHeight  Valor da Altura do box( caso o lFixPixel seja .T. é a qtd de pixel exato)
	// cIdOwner 	Id do Box Vertical pai. Podemos fazer diversas criações uma dentro da outra.
	// lFixPixel	Determina que o valor passado no nPercHeight é na verdade a qtd de pixel a ser usada.
	// cIDFolder	Id da folder onde queremos criar o o box se passado esse valor, é necessário informar o cIDSheet
	// cIDSheet     Id da Sheet(Folha de dados) onde queremos criar o o box.

	oView:AddGrid("GFEA071_GW3", oStructGW3)
	oView:AddGrid("GFEA071_GWJ", oStructGWJ)

	oView:CreateHorizontalBox("MASTER", 60)
	oView:CreateHorizontalBox("DETAIL", 40)
	oView:CreateFolder("IDFOLDER01", "DETAIL")
	oView:CreateHorizontalBox("DETAILNETO1", 100,,, "IDFOLDER01", "IDSHEET01")
	oView:CreateHorizontalBox("DETAILNETO2", 100,,, "IDFOLDER01", "IDSHEET02")
	oView:AddSheet("IDFOLDER01", "IDSHEET01", STR0005)  //'Documentos de Frete'
	oView:AddSheet("IDFOLDER01", "IDSHEET02", STR0061)  //'Pre-Fatura'

	// Associa um View a um box
	oView:SetOwnerView("GFEA071_GW6", "MASTER")
	oView:SetOwnerView("GFEA071_GW3", "DETAILNETO1")
	oView:SetOwnerView("GFEA071_GWJ", "DETAILNETO2")

Return oView

//---------------------------------------------------------------------------------------------------
/*/{Protheus.doc} GFEA071ED()
Valida se existe Doc Frete para aprovação
Generico

@sample
GFEA071AP(oModel)

@author Felipe M.
@since 02/12/09
@version 1.0
/*///------------------------------------------------------------------------------------------------
Function GFEA071ED()
	Local nVlTotalGW3 := 0
	
	// Ponto de entrada que permite a inclusão de funcionalidades
	// adicionais na aprovação de fatura de frete
	If ExistBlock("GFEA0713")
		ExecBlock("GFEA0713",.F.,.F.)
	EndIf

	dbSelectArea("GW3")
	GW3->( dbSetOrder(8) )
	If GW3->( dbSeek(GW6->GW6_FILIAL + GW6->GW6_EMIFAT + GW6->GW6_SERFAT + GW6->GW6_NRFAT + DToS(GW6->GW6_DTEMIS)) )
	
		While !GW3->( Eof() ) .And. GW6->GW6_FILIAL + GW6->GW6_EMIFAT + GW6->GW6_SERFAT + GW6->GW6_NRFAT + DToS(GW6->GW6_DTEMIS) == ;
									GW3->GW3_FILFAT + GW3->GW3_EMIFAT + GW3->GW3_SERFAT + GW3->GW3_NRFAT + DToS(GW3->GW3_DTEMFA)
			nVlTotalGW3 := GW3->GW3_VLDF + nVlTotalGW3

			GW3->( dbSkip() )
		EndDo

		If QtdComp(nVlTotalGW3) == QtdComp(GW6->GW6_VLFATU)
			GFEA071AP()
		Else
			GFEMessage(5, GFEA071002, STR0062, STR0081) // "O Valor total da Fatura difere da soma dos Documentos de Frete" / "Verifique se estão corretos os Valores da Fatura e do Documentos de Frete antes de continuar com a aprovação."
			Return .F.
		EndIf
	Else
		GFEMessage(5, GFEA071003, STR0006, STR0082) // "Não é possível aprovar uma Fatura sem documento de Frete" / "Realize a associação da Fatura a um Documento de Frete para ser possível realizar a aprovação."
		Return .F.
	EndIf

Return .T.

//---------------------------------------------------------------------------------------------------
/*/{Protheus.doc} GFEA071AP()
Tela de Aprovação
Generico

@sample
GFEA071AP(oModel)

@author Felipe M.
@since 02/12/09
@version 1.0
/*///------------------------------------------------------------------------------------------------
Function GFEA071AP(oModel)
	Local oDlg, oPnlA
	Local nAlt := 400
	Local nLrg := 600

	Private oMemo, cMemo := GW6->GW6_MOTDES
	Private cTpImp, cAliMKB
	Private nVlFat, nVLPFat, nVLDocF, nFVLVAR, nFPCVAR, nVLDocFret, nVlImpDF, nVlImpC
	Private dDtVencM1, dDtVencC1

	aMKB := {{"GW3_SIT"  , "C", 02, 0},;
			 {"FILIAL"   , "C", Len(cFilAnt), 0},;
			 {"TIPO"     , "C", 05, 0},;
			 {"SERIE"    , "C", 05, 0},;
			 {"DOCUM"    , "C", 16, 0},;
			 {"TPCALC"   , "C", 09, 0},;
			 {"VLINFO"   , "N", 10, 2},;
			 {"VLCALC"   , "N", 10, 2},;
			 {"DIFVALOR" , "N", 10, 2},;
			 {"VLIMPINF" , "N", 10, 2},;
			 {"VLIMPCALC", "N", 10, 2},;
			 {"DIFVLIMP" , "N", 10, 2},;
			 {"EMISDF"   , "C", TamSX3("GU3_CDEMIT")[1], 0},;
			 {"DTEMIS"   , "D", 08, 0}}

	cAliMKB := GFECriaTab({aMKB, {"TIPO+DOCUM"}}) 

	Processa({|| GFEA071RA(.F.)}, STR0008, STR0009) //"Processando informações para Aprovação"###"Aguarde"

	If GW6->GW6_SITAPR == '2'

		aNewButton := {}

		Aadd(aNewButton, {"gacimg32", {|| GFEA071BT()}, STR0010, STR0010}) //"Detalhes"###"Detalhes"
		Aadd(aNewButton, {"sdurepl" , {|| GFEA071CF()}, STR0011, STR0011}) //"Conferência"###"Conferência"

		Define MsDialog oDlg Title STR0012 From 80,50 To nAlt,nLrg Of oMainWnd Color CLR_BLACK,RGB(225,225,225) Pixel //"Motivo para Aprovação"
		oDlg:lEscClose := .F.

		oPnlA := tPanel():New(00,00,,oDlg,,,,,,nAlt,nLrg,.F.,.F.)
		@ 20,10 Say STR0013   Of oPnlA COLOR CLR_BLACK Pixel  //"Motivo para Aprovação:"
		@ 30,15 GET oMemo VAR cMemo MEMO SIZE 230,70 OF oDlg PIXEL
		oMemo:bRClicked := {|| AllwaysTrue()}

		ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar(oDlg, {|| IIf(GFEA071OK(cMemo), oDlg:End(), Nil)}, {|| oDlg:End()},, aNewButton) CENTERED
	EndIf

	GFEDelTab(cAliMKB)

Return .T.

//---------------------------------------------------------------------------------------------------
/*/{Protheus.doc} GFEA071OK()
Botão de confirma da aprovação de fatura
Generico

@param cMemo Motivo da Aprovação

@sample
GFEA071MA(cMemo)

@author Felipe M.
@since 02/12/09
@version 1.0
/*///------------------------------------------------------------------------------------------------
Function GFEA071OK(cMemo, dDataAprov, cHRAprov, cUserAprov)
	Default cUserAprov := cUserName
	Default dDataAprov := dDataBase
	Default cHRAprov   := Time()

	If !Empty(cMemo) .And. !(STR0014 $ GW6->GW6_MOTBLO ) ; //Verifica se contém um trecho da mensagem de bloqueio da validação dos valores do Doc Frete //"Soma dos valores dos documentos de frete"
		.Or. FwIsInCallStack("GFEWSSETDATA") .And. SuperGetMv("MV_ERPGFE",.F.,"2") == "1" .And. SuperGetMv("MV_FTMLA",.F.,"1") $ "2|3" // Aprovação é feita pelo MLA e não precisa da primeira validação 
		//na aprovação, deve-se aprovar os Doc Fretes que estejam bloqueados
		dbSelectArea("GW3")
		GW3->( dbSetOrder(8) )
		GW3->( dbSeek(GW6->GW6_FILIAL + GW6->GW6_EMIFAT + GW6->GW6_SERFAT + GW6->GW6_NRFAT + DToS(GW6->GW6_DTEMIS)) )
		While !GW3->( Eof() ) .And. GW6->GW6_FILIAL + GW6->GW6_EMIFAT + GW6->GW6_SERFAT + GW6->GW6_NRFAT + DToS(GW6->GW6_DTEMIS) == ;
			                        GW3->GW3_FILFAT + GW3->GW3_EMIFAT + GW3->GW3_SERFAT + GW3->GW3_NRFAT + DToS(GW3->GW3_DTEMFA)

			If GW3->GW3_SIT == "2"
				RecLock("GW3", .F.)
					GW3->GW3_MOTAPR := cMemo
					GW3->GW3_USUAPR := cUserAprov
					GW3->GW3_SIT    := "4"
					GW3->GW3_DTAPR  := dDataAprov
				MsUnLock("GW3")

				// Geração da grade contábil para o documento de frete que foi aprovado
				GFERatDF(.F., GW3->GW3_CDESP, GW3->GW3_EMISDF, GW3->GW3_SERDF, GW3->GW3_NRDF, GW3->GW3_DTEMIS)

				If GFXTB12117("GWC")
					If s_GFEI21 == "2"                        
                        GFEA065CTP("IA")
                    EndIf
				EndIf
			EndIf

			GW3->( dbSkip() )
	    EndDo
		
  		RecLock("GW6", .F.)
  			GW6->GW6_MOTDES := cMemo
  			GW6->GW6_SITAPR := "4"
  			GW6->GW6_DTAPR  := dDataAprov
  			GW6->GW6_HRAPR  := cHRAprov
  			GW6->GW6_USUAPR := cUserAprov
  		GW6->( MsUnlock() )

		// Calcula e atualiza campo de valor do IRRF
		FatCalcIRRF()

		// Refaz a contabilização da Fatura
		If SuperGetMV("MV_TPGERA",,"1") == "1"
			GFECTBFATD(GW6->GW6_FILIAL, GW6->GW6_EMIFAT, GW6->GW6_SERFAT, GW6->GW6_NRFAT, GW6->GW6_DTEMIS)
			GFECTBFATC(GW6->GW6_FILIAL, GW6->GW6_EMIFAT, GW6->GW6_SERFAT, GW6->GW6_NRFAT, GW6->GW6_DTEMIS)
		EndIf

		MsgInfo(STR0015) //"Fatura Aprovada"

		//Integração automatica de Fatura
		If SuperGetMV('MV_GFEI16',, '1') == '2'
			GFEA070X(.T.)
		EndIf

	ElseIf STR0014 $ GW6->GW6_MOTBLO //"Soma dos valores dos documentos de frete"
		GFEMessage(5, GFEA071004, STR0016, STR0081) // "Não é permitido aprovar uma fatura com valor diferente da soma do valor dos documentos de frete" / "Verifique se estão corretos os Valores da Fatura e do Documentos de Frete antes de continuar com a aprovação."
		Return .F.
	ElseIf Empty(cMemo)
		GFEMessage(5, GFEA071005, STR0017, STR0083) // "É necessario informar o motivo para aprovação." / "Informe um motivo para continuar com a aprovação da Fatura de Frete."
		Return .F.
	EndIf

	GFEA071CON("1")

Return .T.

//---------------------------------------------------------------------------------------------------
/*/{Protheus.doc} GFEA071RA()
Rotina de Aprovação, chama outras rotinas para a aprovação da fatura
Generico

@param lFlag Indica se deverá fazer o bloqueio da fatura

@sample
GFEA071RA(lFlag)

@author Felipe M.
@since 02/12/09
@version 1.0
/*///------------------------------------------------------------------------------------------------
Function GFEA071RA(lFlag)
	Local lVCP, lVVF, lRet := .T., lVDF := .F., lDocFreteBloq := .F.
	Local cTemp
	Local nVlImpRet	:= 0
	Local nVlDif 	:= 0
	Local lDifImpRet:= .F.
	Local lAprovMLA := SuperGetMv("MV_ERPGFE",.F.,"1") == "1" .And. SuperGetMv("MV_FTMLA",.F.,"1") $ "2|3|4"
	Local nRecno 	:= 0
	Local cSitMLA 	:= ""
	Local cMotBlo 	:= ""
	Local aBlock	:= {}
	Local lDocFrtDig := .F.
	Local nTotal 	:= 0
	Local cValTom	:= ""
	Local lBloqTom 	:= .F.
	
	Private cMotBloqVVF := '', cMotBloqVDF := '', cMotBloqVCP := ''
	Private dDtVencM, dDtVencC
	Private lExcept := .F.

	If !lFlag .Or. ( lFlag .And. GetNewPar('MV_CFCONPG', 'N') $ "1S")
		lVCP := GFEA071CP(lFlag) //validação de condição de pagamento
	EndIf

	lVVF := GFEA071VF(lFlag) //validação de valor da Fatura

	If !lFlag .Or. ( lFlag .And. GetNewPar('MV_CFAGRUP', 'N') $ "1S")
		lVDF := GFEA071AG() //Validação de agrupamento de Doc Frete
	EndIf

	If lFlag .And. lRet
		// Início Ponto de Entrada Britania
		If ExistBlock("XGFEAPRF")
		   	lExecBlock := ExecBlock("XGFEAPRF",.f.,.f.,{GW6->GW6_FILIAL, GW6->GW6_EMIFAT, GW6->GW6_SERFAT, GW6->GW6_NRFAT, GW6->GW6_DTEMIS})
		   	if lExecBlock == .F.
		   		lRet := .F.
		   	EndIf
		EndIf
		// Fim Ponto de Entrada Britania	
	Endif

	nRecno := GW6->(Recno())

	If lFlag .And. lRet
		cTemp := ""

  		RecLock("GW6", .F.)
  			GW6->GW6_MOTBLO := ""
  		GW6->( MsUnlock() )

		//Verifica se há um Doc Frete bloqueado vinculado a Fatura
		dbSelectArea("GW3")
		GW3->( dbSetOrder(8) )
		GW3->( dbSeek(GW6->GW6_FILIAL + GW6->GW6_EMIFAT + GW6->GW6_SERFAT + GW6->GW6_NRFAT + DToS(GW6->GW6_DTEMIS)) )
		While !GW3->( Eof() ) .And. GW3->GW3_FILFAT + GW3->GW3_EMIFAT + GW3->GW3_SERFAT + GW3->GW3_NRFAT + DToS(GW3->GW3_DTEMFA) == ;
									GW6->GW6_FILIAL + GW6->GW6_EMIFAT + GW6->GW6_SERFAT + GW6->GW6_NRFAT + DToS(GW6->GW6_DTEMIS)
			nTotal++
			If GFXCP12137('GW3_FILTOM')
				If nTotal == 1
					If !Empty(GW3->GW3_FILTOM) .And. GW3->GW3_FILTOM != GW3->GW3_FILIAL
						cValTom := GW3->GW3_FILTOM	
					Else
						cValTom := GW3->GW3_FILIAL
					EndIf
				Else
					IF !Empty(GW3->GW3_FILTOM) 
						If cValTom != GW3->GW3_FILTOM
							lBloqTom := .T.
						EndIf
					Else
						If cValTom != GW3->GW3_FILIAL
							lBloqTom := .T.
						EndIf
					EndIf
				EndIf
			EndIf 	

			If GW3->GW3_SIT $ '2;5'
	  			lDocFreteBloq := .T.
			EndIf

			If GW3->GW3_SIT $ '1'
				lDocFrtDig := .T.
			EndIf

			If GW3->GW3_TRBIMP $ "3;7" //3=Subs Tributaria; 7=Presumido  
				nVlImpRet += GW3->GW3_IMPRET
			EndIf

	      	GW3->( dbSkip() )
	    EndDo

		If GFXCP12137('GW6_FILTOM')
			If !lBloqTom
				If cValtom != GW6->GW6_FILIAL
					RecLock ("GW6", .F.)
						GW6->GW6_FILTOM := cValTom
					GW6->(MsUnLock())
				EndIf
			Else
				RecLock("GW6", .F.)
					cTemp := GW6->GW6_MOTBLO + cMotBlo
					GW6->GW6_MOTBLO := cTemp + CRLF + STR0087
				GW6->( MsUnlock() )	
			EndIf
		EndIf

		If s_GFEA0717
		   	aBlock := ExecBlock("GFEA0717",.f.,.f.)
		   	lDocFreteBloq := aBlock[1]
		   	cMotBlo       := aBlock[2]
		EndIf	    

		If lDocFreteBloq
			RecLock("GW6", .F.)
				cTemp           := GW6->GW6_MOTBLO + cMotBlo
  				GW6->GW6_MOTBLO := cTemp + CRLF + "[" + GFEA071008 + "]" + STR0018 //"Fatura de Frete está vinculada a Doc Frete com situação 'Bloqueada'."
  			GW6->( MsUnlock() )
		EndIf

		If lDocFrtDig
			RecLock("GW6", .F.)
				cTemp           := GW6->GW6_MOTBLO + cMotBlo
  				GW6->GW6_MOTBLO := cTemp + CRLF + "[" + GFEA071009 + "]" + STR0086
  			GW6->( MsUnlock() )
		EndIf

		If (GW6->GW6_VLICRE + GW6->GW6_VLISRE)  != nVlImpRet
			lDifImpRet := .T.
			nVlDif:= (GW6->GW6_VLICRE + GW6->GW6_VLISRE) - nVlImpRet
		EndIf
		
		If !lVCP .AND. GetNewPar('MV_CFCONPG', 'N') $ "1S"
  			RecLock("GW6",.F.)
  				cTemp           := GW6->GW6_MOTBLO
  				GW6->GW6_MOTBLO := cTemp + CRLF + cMotBloqVVF
  			MsUnLock("GW6")
		EndIf

		If (!lVVF .And. GETNEWPAR('MV_CFVLFAT', 'N') $ "1S") .Or. lExcept
  			RecLock("GW6", .F.)
  				cTemp           := GW6->GW6_MOTBLO
  				GW6->GW6_MOTBLO := cTemp + CRLF + cMotBloqVCP
			GW6->( MsUnlock() )
		EndIf

		If !lVDF .And. GetNewPar('MV_CFAGRUP', 'N') $ "1S"
  			RecLock("GW6", .F.)
  				cTemp           := GW6->GW6_MOTBLO
  				GW6->GW6_MOTBLO := cTemp + CRLF + cMotBloqVDF
			GW6->( MsUnlock() )
		EndIf

		If (!lVCP .AND. GETNEWPAR('MV_CFCONPG', 'N') $ "1S") .Or. (!lVVF .And. GetNewPar('MV_CFVLFAT', 'N') $ "1S") .Or. (!lVDF .And. GetNewPar('MV_CFAGRUP', 'N') $ "1S") .Or. lDocFreteBloq .Or. lExcept .Or. lDocFrtDig .Or. lBloqTom
  			RecLock("GW6", .F.)
  				GW6->GW6_SITAPR := "2"
  				GW6->GW6_DTBLOQ := dDataBase
  				GW6->GW6_HRBLOQ := Time()
  				GW6->GW6_USUBLO := cUserName
  				GW6->GW6_DTAPR  := SToD("")
  				GW6->GW6_HRAPR  := ""
  			GW6->( MsUnlock() )
			
			If !IsInCallStack("GFEA65GFAT") .And. !IsInCallStack("GFEA116PRO") .And. !IsInCallStack("GFEA65GFF")
				If lDifImpRet
					MsgInfo(STR0019 + CRLF + GW6->GW6_MOTBLO + CRLF + CRLF + STR0071 + CRLF + CRLF + STR0072+ CRLF + STR0073 + AllTrim(str(nVlDif)) ) // "Informação da conferência:" ## "Valor total dos impostos retidos da fatura não confere com o somatório dos valores de ICMS ou ISS Retido dos conhecimentos." ## "Total da Diferença: R$ "
				Else
					MsgInfo(STR0019 + CRLF + GW6->GW6_MOTBLO) //"Fatura Bloqueada."
				Endif
			EndIf
		Else
				RecLock("GW6", .F.)
					GW6->GW6_SITAPR := "3" //APROVADA PELO SISTEMA
					GW6->GW6_DTAPR  := dDataBase
					GW6->GW6_HRAPR  := Time()
				GW6->( MsUnlock() )

			// Criação dos movimentos contábeis para a fatura
			If (GW6->GW6_SITFIN == "1" .Or. GW6->GW6_SITFIN == "3") .AND. SuperGetMv("MV_TPGERA",,"1") == "1"
				GFECTBFATC(GW6->GW6_FILIAL, GW6->GW6_EMIFAT, GW6->GW6_SERFAT, GW6->GW6_NRFAT, GW6->GW6_DTEMIS)
			EndIf

			If !IsInCallStack("GFEA65GFAT") .And. !IsInCallStack("GFEA116PRO") .And. !IsInCallStack("GFEA065GFF") //não deve apresentar a mensagem de fatura aprovada se a fatura foi gerada automaticamente
				If lDifImpRet
					MsgInfo(STR0015 + CRLF + CRLF + STR0071 + CRLF + CRLF + STR0072+ CRLF + STR0073 + AllTrim(STR(nVlDif)))//"Fatura Aprovada" ## "Informação da conferência:" ## "Valor total dos impostos retidos da fatura não confere com o somatório dos valores de ICMS ou ISS Retido dos conhecimentos." ## "Total da Diferença: R$ "
				Else
					MsgInfo(STR0015) //"Fatura Aprovada"
				EndIf
			EndIf
			
			GFEA071CON("1")
			/* Atualização automática da fatura de frete no financeiro */
			If SuperGetMV('MV_GFEI16',, '1') == '2' .And. SuperGetMv("MV_FTMLA",.F.,"1") != "4"
				GFEA070X(.T.)
			EndIf
		EndIf
	EndIf
	
	If nRecno != GW6->(Recno())
		// Reposiciona caso tenha perdido a referência
		GW6->(dbGoTo(nRecno))
	EndIf
   // Para enviar para MLA os parametros de integração do MLA devem estar marcado, 
   //    a FATURA deve possuir Pré-Fatura relacionada a fatura
	If GfeVerCmpo({"GW6_SITMLA","GW6_MOTMLA"})
		RecLock("GW6",.F.)
		If lAprovMLA
			If GW6->GW6_SITMLA == "7"
				GW6->GW6_SITMLA := "8"
			Else
				If SuperGetMv("MV_FTMLA",.F.,"1") == "4"
					If GW6->GW6_SITAPR $ "3|4" .And. GW6->GW6_SITMLA $ "5|4"
						GW6->GW6_SITMLA := "8"
					ElseIf GW6->GW6_SITAPR == "2"
						If GW6->GW6_SITMLA $ " |1|2|6"
							GW6->GW6_SITMLA := "1"
						Else
							GW6->GW6_SITMLA := "5"
						EndIf
					Else
						GW6->GW6_SITMLA := "2"
					EndIf
				Else
					If GFEA071PR()
						GW6->GW6_SITMLA := "2"
					Else
						GW6->GW6_SITMLA := "1"
					EndIf
				EndIf
			EndIf
				// Início Ponto de Entrada 
			If ExistBlock("GFEA0716")
				cSitMLA := ExecBlock("GFEA0716",.F.,.F.,{GW6->GW6_SITMLA})
				GW6->GW6_SITMLA := cSitMLA
			EndIf
		Else
			GW6->GW6_SITMLA := "6" // Não se aplica - sem integração com MLA.
		EndIf
		GW6->GW6_MOTMLA := ""
		GW6->(MsUnlock())
	EndIf

Return lRet

//---------------------------------------------------------------------------------------------------
/*/{Protheus.doc} GFEA071PR()
Valida se existe Pre-Fatura relacionada a Fatura
- So pode enviar para Aprovacao no MLA se existir Pre-Fatura relacionada com a Fatura q esta sendo validada
@author Marcos Pedro da Silveira
@since 02/12/09
@version 1.0
/*/
//------------------------------------------------------------------------------------------------
Function GFEA071PR()
	Local lRet := .T.

	dbSelectArea("GWJ")
	GWJ->( dbSetOrder(7) )
	lRet :=  GWJ->( dbSeek(GW6->GW6_FILIAL + GW6->GW6_EMIFAT + GW6->GW6_SERFAT + GW6->GW6_NRFAT + DToS(GW6->GW6_DTEMIS)) )
	
	// Início Ponto de Entrada 
	If ExistBlock("GFEA0715")
		lRet := ExecBlock("GFEA0715",.F.,.F.)
	EndIf

Return lRet

//---------------------------------------------------------------------------------------------------
/*/{Protheus.doc} GFEA071CP()
Valida a Condição de Pagamento
Generico

@param lFlag Indica se valida a Condição de Pagamento ou apenas obtem informações para conferencia

@sample
GFEA071CP(lFlag)

@author Felipe M.
@since 02/12/09
@version 1.0
/*///------------------------------------------------------------------------------------------------
Function GFEA071CP(lFlag)
	Local lRet := .T.

	dbSelectArea("GWJ")
	GWJ->( dbSetOrder(7) )
	If GWJ->( dbSeek(GW6->GW6_FILIAL + GW6->GW6_EMIFAT + GW6->GW6_SERFAT + GW6->GW6_NRFAT + DToS(GW6->GW6_DTEMIS)) )

		//Caso existam pré-faturas relacionadas à fatura, a data de vencimento da fatura deve ser igual ou posterior à menor das datas de vencimento das pré-faturas, caso contrário deve ser bloqueada.
		While !GWJ->( Eof() ) .And. GW6->GW6_FILIAL + GW6->GW6_EMIFAT + GW6->GW6_SERFAT + GW6->GW6_NRFAT + DToS(GW6->GW6_DTEMIS) == ;
			                        GWJ->GWJ_FILFAT + GWJ->GWJ_EMIFAT + GWJ->GWJ_SERFAT + GWJ->GWJ_NRFAT + DToS(GWJ->GWJ_DTEMFA)

		    If Empty(dDtVencM)
		    	dDtVencM  := GWJ->GWJ_DTVCTO
		    	dDtVencM1 := GWJ->GWJ_DTVCTO
		    ElseIf dDtVencM > GWJ->GWJ_DTVCTO
				dDtVencM := GWJ->GWJ_DTVCTO
				dDtVencM1 := GWJ->GWJ_DTVCTO
			EndIf

		    GWJ->( dbSkip() )
		EndDo

		If lFlag .And. dDtVencM != GW6->GW6_DTVENC
			cMotBloqVVF := STR0020 + DToC(dDtVencM) + STR0021 + DToC(GW6->GW6_DTVENC) //"Data de Vencimento da Pré-Fatura: "###" é diferente da data de Vencimento da Fatura: "
			lRet := .F.
		EndIf

	Else
		dDtVencM1 := GW6->GW6_DTVENC
		dDtVencC  := GFECalcVc(GW6->GW6_DTEMIS, GW6->GW6_EMIFAT)

	    If dDtVencC != Nil
				If GW6->GW6_DTVENC < dDtVencC
	    		cMotBloqVVF := STR0023 + DTOC(dDtVencC) + STR0024 + DTOC(GW6->GW6_DTVENC) //"Data de Vencimento calculada: "###" é maior que a data de Vencimento da Fatura: "
	    		lRet := .F.
	    	EndIf
	    EndIf

	EndIf

	dDtVencC1 := If(Empty(dDtVencC), GW6->GW6_DTVENC, dDtVencC)

Return lRet

//---------------------------------------------------------------------------------------------------
/*/{Protheus.doc} GFEA071VF()
Valida o Valor da Fatura
Generico

@param lFlag Indica se valida a Condição de Pagamento ou apenas obtem informações para conferencia

@sample
GFEA071VF(lFlag)

@author Felipe M.
@since 02/12/09
@version 1.0
/*///------------------------------------------------------------------------------------------------
Function GFEA071VF(lFlag)
	Local lExistCamp := GWF->(FieldPos("GWF_CDESP")) > 0 .And. GWF->(FieldPos("GWF_EMISDF")) > 0 .And. GWF->(FieldPos("GWF_SERDF")) > 0 .And. GWF->(FieldPos("GWF_NRDF")) > 0 .And. GWF->(FieldPos("GWF_DTEMDF")) > 0 .And. (FindFunction("GFEA065VFIX") .And. GFEA065VFIX())
	Local lRet       := .T.
	Local lExit      := .F.
	Local cQuery     := ""
	Local cAliasQry  := ""

	//Iniciação de Variaveis--
	nVlFat  := GW6->GW6_VLFATU  //valor total da fatura
	nVLPFat := 0                //valor total de cada pré-fatura associada à fatura.
	nVLDocF	:= 0                //valor total de cada Doc Frete associado à fatura.
	nFVLVAR := GetNewPar("MV_CFVLVAR",0)
	nFPCVAR := GetNewPar("MV_CFPCVAR",0)
	nVlImpDF:= 0
	nVlImpC := 0
	nVLDocFret := 0
	nPFObrig := SuperGetMV('MV_PFOBRIG',,'2')

	//------------------------

	If lFlag //Se é para verifica e provar a fatura

		If GetNewPar('MV_CFVLFAT', 'N') $ "1S"
		
			//Chamado TSKTG9
			//GFEVINCPFC(GW6->GW6_FILIAL, GW6->GW6_EMIFAT, GW6->GW6_SERFAT, GW6->GW6_NRFAT, GW6->GW6_DTEMIS,,.F.)
			
			//Continuação TSKTG9
			If nPFObrig == "1"
			
				//Utiliza novo indice entre GW3 X GWF para consultar pré-faturas para validações
				//Fatura > Docto Frete > Cálculo > Pre-fatura 
				If lExistCamp 
					cQuery := " SELECT GWJ.GWJ_NRPF,GWJ.GWJ_SIT,GWJ.GWJ_SITFIN,GWJ.GWJ_CDTRP,GWJ.GWJ_NRFAT,GWJ.GWJ_EMIFAT,GWF.GWF_TPCALC,GWF.GWF_NRCALC,GW3.GW3_TPDF" 
					cQuery += "   FROM "+RetSqlName('GW3')+" GW3"
					cQuery += "   LEFT JOIN "+RetSqlName('GWF')+" GWF"
					cQuery += "     ON GWF.GWF_FILIAL = GW3.GW3_FILIAL"
					cQuery += "    AND GWF.GWF_CDESP  = GW3.GW3_CDESP"
					cQuery += "    AND GWF.GWF_EMISDF = GW3.GW3_EMISDF"
					cQuery += "    AND GWF.GWF_SERDF  = GW3.GW3_SERDF"
					cQuery += "    AND GWF.GWF_NRDF   = GW3.GW3_NRDF"
					cQuery += "    AND GWF.GWF_DTEMDF = GW3.GW3_DTEMIS"
					cQuery += "    AND GWF.D_E_L_E_T_ = ' '"
					cQuery += "   LEFT JOIN "+RetSqlName('GWJ')+" GWJ"
					cQuery += "     ON GWJ.GWJ_FILIAL = GWF.GWF_FILIAL"
					cQuery += "    AND GWJ.GWJ_NRPF   = GWF.GWF_NRPREF"
					cQuery += "	   AND " + IIf( SuperGetMv("MV_GFEPF1",,'1') == '1', "GWJ.GWJ_SIT = '3'", "GWJ.GWJ_SIT IN ('2','3')" )
					
					If SuperGetMV('MV_GFEI15',,'3') != "3"
						cQuery += "    AND GWJ.GWJ_SITFIN = '4'"
					EndIf
					
					cQuery += "    AND GWJ.D_E_L_E_T_ = ' '"
					cQuery += "  WHERE GW3.GW3_FILFAT = '"+GW6->GW6_FILIAL+"'"
					cQuery += "    AND GW3.GW3_EMIFAT = '"+GW6->GW6_EMIFAT+"'"
					cQuery += "    AND GW3.GW3_SERFAT = '"+GW6->GW6_SERFAT+"'"
					cQuery += "    AND GW3.GW3_NRFAT  = '"+GW6->GW6_NRFAT+"'" 
					cQuery += "    AND GW3.GW3_DTEMFA = '"+DtoS(GW6->GW6_DTEMIS)+"'"
					cQuery += "    AND GW3.D_E_L_E_T_ = ' '"
					cQuery := ChangeQuery(cQuery)
					cAliasQry := GetNextAlias()
					dbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery), cAliasQry, .F., .T.)
					
					While (cAliasQry)->(!EoF())
						
						If Empty((cAliasQry)->GWF_NRCALC)
							//Caso não haja cálculo. - Chamado TTDDF2
							lRet := .F.
							cMotBloqVCP := STR0074 //"Não existem cálculos vinculados ao documento de frete. (Parâmetro PF Obrigatória habilitado)"
							lExit := .T.
							Exit															
						EndIf
						
						If Empty((cAliasQry)->GWJ_NRPF)
							lRet := .F.
							cMotBloqVCP := STR0075 //"Existem pré-faturas que não foram geradas. (Parâmetro PF Obrigatória habilitado)"
							lExit := .T.
							Exit
						Else 
							If s_GFEI15 != "3"  .And. ;
							   ((cAliasQry)->GWJ_CDTRP == GW6->GW6_EMIFAT .Or. (s_VLCNPJ == "2" .And. SubStr(Posicione("GU3",1,xFilial("GU3")+(cAliasQry)->GWJ_CDTRP,"GU3->GU3_IDFED"),1,8) == SubStr(Posicione("GU3",1,xFilial("GU3")+GW6->GW6_EMIFAT,"GU3->GU3_IDFED"),1,8)))
							
								If Empty((cAliasQry)->GWJ_EMIFAT) .And. Empty((cAliasQry)->GWJ_NRFAT) .And. (cAliasQry)->GWF_TPCALC == (cAliasQry)->GW3_TPDF
									lRet := .F.
									cMotBloqVCP := STR0076 //"Existem pré-faturas que não foram vinculadas a fatura."
								EndIf
							EndIf
						EndIf
						
						(cAliasQry)->(dbSkip())
					EndDo
					(cAliasQry)->(dbCloseArea())		
				Else 
					//Utiliza indice antigo para consultar pré-faturas para validações
					//Fatura > Docto Frete > Docto Carga Docto Frete > Cálculo > Pre-fatura 
					cQuery := " SELECT DISTINCT GWJ.GWJ_NRPF,GWJ.GWJ_CDTRP,GWJ.GWJ_NRFAT,GWJ.GWJ_EMIFAT,GWF.GWF_NRCALC,GWH.GWH_NRCALC"
					cQuery += "   FROM "+RetSqlName('GW3')+" GW3"
					cQuery += "  INNER JOIN "+RetSqlName('GW4')+" GW4"
					cQuery += " 	  ON GW4.GW4_FILIAL = GW3.GW3_FILIAL"
					cQuery += "    AND GW4.GW4_EMISDF = GW3.GW3_EMISDF"
					cQuery += "    AND GW4.GW4_CDESP  = GW3.GW3_CDESP"
					cQuery += "    AND GW4.GW4_SERDF  = GW3.GW3_SERDF"
					cQuery += "    AND GW4.GW4_NRDF   = GW3.GW3_NRDF"
					cQuery += "    AND GW4.D_E_L_E_T_ = ' '"
					cQuery += "   LEFT JOIN "+RetSqlName('GWH')+" GWH"
					cQuery += "     ON GWH.GWH_FILIAL = GW4.GW4_FILIAL"
					cQuery += "    AND GWH.GWH_CDTPDC = GW4.GW4_TPDC"
					cQuery += "    AND GWH.GWH_EMISDC = GW4.GW4_EMISDC"
					cQuery += "    AND GWH.GWH_SERDC  = GW4.GW4_SERDC" 
					cQuery += "    AND GWH.GWH_NRDC   = GW4.GW4_NRDC"
					cQuery += "    AND GWH.D_E_L_E_T_ = ' '"
					cQuery += "   LEFT JOIN "+RetSqlName('GWF')+" GWF"
					cQuery += " 	  ON GWF.GWF_FILIAL = GWH.GWH_FILIAL"
					cQuery += "    AND GWF.GWF_NRCALC = GWH.GWH_NRCALC"
					cQuery += "    AND GWF.GWF_TPCALC = GW3.GW3_TPDF"
					cQuery += "    AND GWF.D_E_L_E_T_ = ' '"
					cQuery += "   LEFT JOIN "+RetSqlName('GWJ')+" GWJ"
					cQuery += "     ON GWJ.GWJ_FILIAL = GWF.GWF_FILIAL"
					cQuery += "    AND GWJ.GWJ_NRPF   = GWF.GWF_NRPREF"
					cQuery += "	   AND " + IIf( SuperGetMv("MV_GFEPF1",,'1') == '1', "GWJ.GWJ_SIT = '3'", "GWJ.GWJ_SIT IN ('2','3')" )
					
					If SuperGetMV('MV_GFEI15',,'3') != "3"
						cQuery += "    AND GWJ.GWJ_SITFIN = '4'"
					EndIf
					cQuery += "    AND GWJ.D_E_L_E_T_ = ''"
					cQuery += "  WHERE GW3.GW3_FILFAT = '"+GW6->GW6_FILIAL+"'" 
					cQuery += "    AND GW3.GW3_EMIFAT = '"+GW6->GW6_EMIFAT+"'" 
					cQuery += "    AND GW3.GW3_SERFAT = '"+GW6->GW6_SERFAT+"'"
					cQuery += "    AND GW3.GW3_NRFAT  = '"+GW6->GW6_NRFAT+"'" 
					cQuery += "    AND GW3.GW3_DTEMFA = '"+DtoS(GW6->GW6_DTEMIS)+"'" 
					cQuery += "    AND GW3.D_E_L_E_T_ = ' '"
					cQuery := ChangeQuery(cQuery)
					cAliasQry := GetNextAlias()
					dbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery), cAliasQry, .F., .T.)
					
					While (cAliasQry)->(!EoF())
						
						If Empty((cAliasQry)->GWH_NRCALC) 
							//Caso não haja cálculo. - Chamado TTDDF2
							lRet := .F.
							cMotBloqVCP := STR0077 //"Existem cálculos que não foram gerados. (Parâmetro PF Obrigatória habilitado)"
							lExit := .T.
							Exit
						EndIf
						
						If Empty((cAliasQry)->GWF_NRCALC)
							//Caso não haja cálculo. - Chamado TTDDF2
							lRet := .F.
							cMotBloqVCP := STR0078 //"Não existem cálculos do mesmo tipo do Documento de Frete gerados. (Parâmetro PF Obrigatória habilitado)"
							lExit := .T.
							Exit																
						EndIf
						
						If Empty((cAliasQry)->GWJ_NRPF)
							lRet := .F.
							cMotBloqVCP := STR0075 //"Existem pré-faturas que não foram geradas. (Parâmetro PF Obrigatória habilitado)"
							lExit := .T.
							Exit
						Else 
							If s_GFEI15 != "3"  .And. ;
							   ((cAliasQry)->GWJ_CDTRP == GW6->GW6_EMIFAT .Or. (s_VLCNPJ == "2" .And. SubStr(Posicione("GU3",1,xFilial("GU3")+(cAliasQry)->GWJ_CDTRP,"GU3->GU3_IDFED"),1,8) == SubStr(Posicione("GU3",1,xFilial("GU3")+GW6->GW6_EMIFAT,"GU3->GU3_IDFED"),1,8)))
							
								If Empty((cAliasQry)->GWJ_EMIFAT) .And. Empty((cAliasQry)->GWJ_NRFAT) .And. (cAliasQry)->GWF_TPCALC == (cAliasQry)->GW3_TPDF
									lRet := .F.
									cMotBloqVCP := STR0076 //"Existem pré-faturas que não foram vinculadas a fatura."
								EndIf
							
							EndIf
						EndIf
																		
						(cAliasQry)->(dbSkip())
					EndDo
					(cAliasQry)->(dbCloseArea())			
				EndIf
			EndIf

			//No caso de ocorrer algum bloqueio:
			If lExit
				Return lRet
			EndIf

			dbSelectArea("GWJ")
			GWJ->( dbSetOrder(7) )
			If GWJ->( dbSeek(GW6->GW6_FILIAL + GW6->GW6_EMIFAT + GW6->GW6_SERFAT + GW6->GW6_NRFAT + DToS(GW6->GW6_DTEMIS)) ) //GWJ_FILIAL+GWJ_FILFAT+GWJ_EMIFAT+GWJ_SERFAT+GWJ_NRFAT+DToS(GW6->GW6_DTEMIS)

				GFEA071PF()

				If ( nVlFat > (nVLPFat + nFVLVAR) ) .And. ( nVlFat >(nVLPFat + ((nVLPFat * nFPCVAR) / 100) ) )
					lRet := .F.
					cMotBloqVCP := STR0025 //"Valor da fatura é superior a Soma dos valores das Pré-Faturas"
				ElseIf (nVlFat < (nVLPFat - nFVLVAR) ) .And. (nVlFat < (nVLPFat - ((nVLPFat * nFPCVAR) / 100) )  )
					lRet := .F.
					cMotBloqVCP := STR0026 //"Valor da fatura é inferior a Soma dos valores das Pré-Faturas"
				EndIf

			EndIf

		EndIf

		GFEA071DF(lFlag)
		
		nVLDocFret := Round(nVLDocFret,2)
		nVlFat := Round(nVlFat,2)
		If (nVLDocFret > nVlFat)
			lRet     := .F.
			lExcept  := .T.
			cMotBloqVCP := STR0027 //"Soma dos valores dos documentos de frete é superior ao valor da fatura"
		ElseIf (nVLDocFret < nVlFat)
			lRet     := .F.
			lExcept  := .T.
			cMotBloqVCP := STR0028 //"Soma dos valores dos documentos de frete é inferior ao valor da fatura"
		EndIf

	Else // Ou apenas obter as informações para conferencia

		GFEA071PF()

		GFEA071DF()
	EndIf

Return lRet

//---------------------------------------------------------------------------------------------------
/*{Protheus.doc} GFEA071AG()
Validação de agrupamento
Generico

@sample
GFEA071AG()

@author Felipe M.
@since 23/11/09
@version 1.0
/*///------------------------------------------------------------------------------------------------
Function GFEA071AG()
	Local cFil, cUFDest, cCDCLFR , cGrupoA ,cGrupoB
	Local lRet := .T.
	Local aAreaGU3

	dbSelectArea("GU3")
	GU3->( dbSetOrder(1) )
	If GU3->( dbSeek(xFilial('GU3') + GW6->GW6_EMIFAT) )

		dbSelectArea("GW3")
		GW3->( dbSetOrder(8) )
		GW3->( dbSeek(GW6->GW6_FILIAL + GW6->GW6_EMIFAT + GW6->GW6_SERFAT + GW6->GW6_NRFAT + DToS(GW6->GW6_DTEMIS)) )
		While !GW3->( Eof() ) .And. GW3->GW3_FILFAT + GW3->GW3_EMIFAT + GW3->GW3_SERFAT + GW3->GW3_NRFAT + DToS(GW3->GW3_DTEMFA) == ;
		   							GW6->GW6_FILIAL + GW6->GW6_EMIFAT + GW6->GW6_SERFAT + GW6->GW6_NRFAT + DToS(GW6->GW6_DTEMIS)

			If GU3->GU3_PFFIL =='1' //"	Quando marcada a opção filial, será verificado se todos os Documentos de Frete possuem o mesmo código de filial.
				If Empty(cFil)
					cFil := GW3->GW3_FILIAL
			    ElseIf cFil != GW3->GW3_FILIAL
			        lRet := .F.
			        cMotBloqVDF := cMotBloqVDF + STR0029 //"Documentos de Frete não possuem a mesma Filial informado no cadastro do Transportador.  "
			        Exit
			    EndIf
		    EndIf

  		    If GU3->GU3_PFUF == '1'   //"Quando marcada a opção UF Destino, será verificado se todos os Documentos de Frete possuem a mesma UF de destino.

			    aAreaGU3   := GU3->( GetArea() )
			    dbSelectArea("GU3")
				GU3->( dbSetOrder(1) )
				If GU3->( dbSeek(xFilial('GU3') + GW3->GW3_CDDEST) )
				    If Empty(cUFDest)
						cUFDest  := POSICIONE("GU7",1,XFILIAL("GU7")+GU3->GU3_NRCID,"GU7_CDUF")
				    ElseIf cUFDest != POSICIONE("GU7",1,XFILIAL("GU7")+GU3->GU3_NRCID,"GU7_CDUF")
				        lRet := .F.
				        cMotBloqVDF := cMotBloqVDF + STR0030 //"Documentos de Frete não possuem a mesma UF informado no cadastro do Transportador.  "
			        	Exit
				    EndIf
			    EndIf

		    	RestArea(aAreaGU3)
		    EndIf

		    If GU3->GU3_PFCLAS == '1'  //"	Quando marcada a opção Classificação de Frete, será verificado se a classificação de frete do romaneio dos documentos de carga relacionados aos documentos de frete da fatura são iguais.

	        	dbSelectArea("GW4")
				GW4->( dbSetOrder(1) )
				GW4->( dbSeek(GW3->GW3_FILIAL + GW3->GW3_CDESP + GW3->GW3_EMISDF + GW3->GW3_SERDF + GW3->GW3_NRDF + DToS(GW3->GW3_DTEMIS)) )
				While !Eof() .And. GW4->GW4_FILIAL + GW4->GW4_CDESP + GW4->GW4_EMISDF + GW4->GW4_SERDF + GW4->GW4_NRDF + DtoS(GW4->GW4_DTEMIS) == ;
				   				   GW3->GW3_FILIAL + GW3->GW3_CDESP + GW3->GW3_EMISDF + GW3->GW3_SERDF + GW3->GW3_NRDF + DToS(GW3->GW3_DTEMIS)

					dbSelectArea("GW1")
					GW1->( dbSetOrder(1) )
					GW1->( dbSeek(GW4->GW4_FILIAL + GW4->GW4_TPDC + GW4->GW4_EMISDC + GW4->GW4_SERDC + GW4->GW4_NRDC) )
					While !GW1->( Eof() ) .And. GW1->GW1_CDTPDC + GW1->GW1_EMISDC + GW1->GW1_SERDC + GW1->GW1_NRDC == ;
						  						GW4->GW4_TPDC + GW4->GW4_EMISDC + GW4->GW4_SERDC + GW4->GW4_NRDC

						dbSelectArea("GWN")
						GWN->( dbSetOrder(1) )
						If GWN->( dbSeek(GW1->GW1_FILIAL + GW1->GW1_NRROM) )
					        If Empty(cCDCLFR)
								cCDCLFR  := GWN->GWN_CDCLFR
						    ElseIf cCDCLFR != GWN->GWN_CDCLFR
						        cMotBloqVDF := cMotBloqVDF + STR0031 //"Documentos de Frete não possuem a mesma Classificação de Frete informado no cadastro do Transportador.  "
	           					Exit
						    EndIf

						Else // Se não houver classificação de frete no Romaneio, verificar os itens do doc carga

						    dbSelectArea("GW8")
							GW8->( dbSetOrder(1) )
					    	If dbseek(GW1->GW1_FILIAL + GW1->GW1_CDTPDC + GW1->GW1_EMISDC + GW1->GW1_SERDC + GW1->GW1_NRDC)
						    	If Empty(cCDCLFR)
									cCDCLFR  := GW8->GW8_CDCLFR
							    ElseIf cCDCLFR != GW8->GW8_CDCLFR
							        cMotBloqVDF := cMotBloqVDF + STR0031 //"Documentos de Frete não possuem a mesma Classificação de Frete informado no cadastro do Transportador.  "
	           						Exit
							    EndIf
					    	EndIf
					    EndIf

			    		GW1->( dbSkip() )
				    EndDo

		    		GW4->( dbSkip() )
		    	EndDo

		    EndIf

  		    // será verificado o agrupamento em relação ao tipo de cálculo. A fatura de frete deve ser bloqueada caso haja algum tipo de cálculo de frete
  		    // nos documentos de carga dos documentos de frete fora dos grupos definidos no cadastro de emitentes.
		    If GU3->GU3_PFTPFR == '1'
		    	If GW3->GW3_TPDF == "1"
		    		If Empty(cGrupoA)
				   		cGrupoA := ALLTRIM(STR(GU3->GU3_PFNORM))
				   	Else
				   		cGrupoB := ALLTRIM(STR(GU3->GU3_PFNORM))
				   	EndIf

				ElseIf GW3->GW3_TPDF == "2"
					If Empty(cGrupoA)
				   		cGrupoA := ALLTRIM(STR(GU3->GU3_PFCPVL))
				   	Else
				   		cGrupoB := ALLTRIM(STR(GU3->GU3_PFCPVL))
				   	EndIf

				ElseIf GW3->GW3_TPDF == "3"
					If Empty(cGrupoA)
				   		cGrupoA := ALLTRIM(STR(GU3->GU3_PFCPIC))
				   	Else
				   		cGrupoB := ALLTRIM(STR(GU3->GU3_PFCPIC))
				   	EndIf

				ElseIf GW3->GW3_TPDF == "4"
					If Empty(cGrupoA)
				   		cGrupoA := ALLTRIM(STR(GU3->GU3_PFDEV))
				   	Else
				   		cGrupoB := ALLTRIM(STR(GU3->GU3_PFDEV))
				   	EndIf

				ElseIf GW3->GW3_TPDF == "5"
					If Empty(cGrupoA)
				   		cGrupoA := ALLTRIM(STR(GU3->GU3_PFREDE))
				   	Else
				   		cGrupoB := ALLTRIM(STR(GU3->GU3_PFREDE))
				   	EndIf

				ElseIf GW3->GW3_TPDF == "6"
					If Empty(cGrupoA)
				   		cGrupoA := ALLTRIM(STR(GU3->GU3_PFREEN))
				    Else
				   		cGrupoB := ALLTRIM(STR(GU3->GU3_PFREEN))
				   	EndIf

				ElseIf GW3->GW3_TPDF == "7"
					If Empty(cGrupoA)
				   		cGrupoA := ALLTRIM(STR(GU3->GU3_PFSERV))
				   	Else
				   		cGrupoB := ALLTRIM(STR(GU3->GU3_PFSERV))
				   	EndIf
				Endif

				If cGrupoA != cGrupoB .AND. !Empty(cGrupoA) .AND. !Empty(cGrupoB)
					lRet := .F.
					cMotBloqVDF := cMotBloqVDF + STR0032 //"Documentos de Frete não possuem o mesmo Agrupamento de Tipo de Calculo informado no cadastro do Transportador.  "
			        Exit
				EndIf

		    EndIf

	        GW3->( dbSkip() )
	    EndDo

	EndIf

Return lRet

//---------------------------------------------------------------------------------------------------
/*{Protheus.doc} GFEA071BT()
Validação de entrada de função
Generico

@sample
GFEA071BT()

@author Felipe M.
@since 23/11/09
@version 1.0
/*///------------------------------------------------------------------------------------------------
Function GFEA071BT()
	FWExecView("", 'GFEA071', 1,,{|| .T.})
Return .T.

//---------------------------------------------------------------------------------------------------
/*/{Protheus.doc} GFEA071CF()
Tela de Conferencia
Generico

@sample
GFEA071CF()

@author Felipe M.
@since 02/12/09
@version 1.0
/*///------------------------------------------------------------------------------------------------
Function GFEA071CF()
	Local oDlg
	Local oPnlA
	Local oFOLDER
	Local oPnlB
	Local oPnl1
	Local lRet := .T.
	Local nAlt := 600, nLrg := 900, nIcms, nIcms2, nIss, nIss2, nQtdTotDoc
	Local cEMIFAT, cDESEMIT, cSERFAT, cNRFAT, cSITAPR
	Local aButtons := {}

	//--------------------------
	// Montagem da tela
	//--------------------------

	Define MsDialog oDlg Title STR0012 From 80,50 To nAlt,nLrg Of oMainWnd Color CLR_BLACK,RGB(225,225,225) Pixel //"Motivo para Aprovação"
	oDlg:lEscClose := .F.

	oPnlA := tPanel():New(00,00,,oDlg,,,,,,600,80,.F.,.F.)
	oPnlA:Align := CONTROL_ALIGN_NONE

	oPnlB := tPanel():New(00,00,,oDlg,,,,,,600,180,.F.,.F.)
	oPnlB:Align := CONTROL_ALIGN_BOTTOM
	//-----------------------------------------------------------------------------------------
	//Header
	cEMIFAT  := GW6->GW6_EMIFAT
	cDESEMIT := Posicione("GU3", 1, xFilial("GU3") + GW6->GW6_EMIFAT, "GU3_NMEMIT")
	cSERFAT  := GW6->GW6_SERFAT
	cNRFAT   := GW6->GW6_NRFAT
	dDTEMIS  := DToC(GW6->GW6_DTEMIS)
	cSITAPR  := SubStr(StrTokArr(Posicione("SX3",2,"GW6_SITAPR","X3_CBOX"),';')[Val(GW6->GW6_SITAPR)],3,15)
	nVlDesc  := GW6->GW6_VLDESC
	nDinden  := GW6->GW6_DINDEN
	nTotDesc := GW6->GW6_VLDESC + GW6->GW6_DINDEN

	//Folder 01
	//linha, coluna----------------------------------------------------------------------------
	@ 38,20 Say STR0033    Of oPnlA COLOR CLR_BLACK 			   Pixel   //"Transportadora:"
	@ 35,60  MSGET cEMIFAT  Picture "@!" Of oPnlA Valid /*ValidDic()*/ When .F. Pixel
	@ 35,145 MSGET cDESEMIT Picture "@!" Of oPnlA Valid /*ValidDic()*/ When .F. Size 270,10   Pixel

	@ 53,44 Say 'Série:'                 Of oPnlA COLOR CLR_BLACK 			   Pixel   //"Serie:"
	@ 50,60  MSGET cSERFAT  Picture "@!" Of oPnlA Valid /*ValidDic()*/ When .F.   Pixel

	@ 53,161 Say STR0035           Of oPnlA COLOR CLR_BLACK 			   Pixel   //"Dt Emissão:"
	@ 50,190 MSGET dDTEMIS  Picture "@!" Of oPnlA Valid /*ValidDic()*/ When .F.   Pixel

	@ 68,35 Say STR0036             Of oPnlA COLOR CLR_BLACK 			   Pixel   //"Nr Fatura:"
	@ 65,60  MSGET cNRFAT   Picture "@!" Of oPnlA Valid /*ValidDic()*/ When .F.   Pixel

	@ 68,166 Say STR0037             Of oPnlA COLOR CLR_BLACK 			   Pixel   //"Situação:"
	@ 65,190 MSGET cSITAPR  Picture "@!" Of oPnlA Valid /*ValidDic()*/ When .F.   Pixel

	//-----------------------------------------------------------------------------------------

	oFOLDER := TFOLDER():New(11,0,{STR0038, STR0039},{"HEADER 1", "HEADER 2"}, oPnlB,,,, .T.,, 10, 10,) //"Diferenças"###"Documentos"
	oFOLDER:Align := CONTROL_ALIGN_ALLCLIENT

	oPnl1 := tPanel():New(00,00,,oFolder:ADialogs[1],,,,,,60,60,.F.,.F.)
	oPnl1:Align := CONTROL_ALIGN_ALLCLIENT

	//-----------------------------------------------------------------------------------------

	oGroup:= TGroup():New(5,15,30,400, STR0063,oPnl1,,,.T.) //"Condição Pagamento"

	@ 15,24  Say STR0040         Of oGroup COLOR CLR_BLACK 			   Pixel   //"Data de Venc:"
	TGet():New( 13, 59, bSETGET(dDtVencM1),oGroup, 50, 10, "@!", , /*[ nClrFore ]*/, /*[ nClrBack ]*/, /*[ oFont ]*/, , , .T., , , , , , , .T., , , "dDtVencM1", , , , .T., .F., , , , , , )

	@ 15,161  Say STR0041    Of oGroup COLOR CLR_BLACK 			    Pixel   //"Data de Venc Calc:"
	TGet():New( 13, 209, bSETGET(dDtVencC1),oGroup, 50, 10, "@!", , /*[ nClrFore ]*/, /*[ nClrBack ]*/, /*[ oFont ]*/, , , .T., , , , , , , .T., , , "dDtVencC1", , , , .T., .F., , , , , , )

	oGroup03:= TGroup():New(33,15,85,400, STR0064,oPnl1,,,.T.) //"Valores Fatura"

	oGroup04:= TGroup():New(88,15,140,400, STR0065,oPnl1,,,.T.) //"Valores Documentos"

	//coluna 1
	@ 45,41  Say STR0042               Of oGroup03 COLOR CLR_BLACK 			  Pixel   //"Fatura:"
	TGet():New( 43, 59, bSETGET(nVlFat),oGroup03, 50, 10, "@E 999,999,999.99", , /*[ nClrFore ]*/, /*[ nClrBack ]*/, /*[ oFont ]*/, , , .T., , , , , , , .T., , , "nVlFat", , , , .F., .T., , , , , , )
	@ 59,25  Say STR0043         Of oGroup03 COLOR CLR_BLACK 			  Pixel   //"Doctos Frete:"
	TGet():New( 57, 59, bSETGET(nVLDocFret),oGroup03, 50, 10, "@E 999,999,999.99", , /*[ nClrFore ]*/, /*[ nClrBack ]*/, /*[ oFont ]*/, , , .T., , , , , , , .T., , , "nVLDocFret", , , , .F., .T., , , , , , )
	@ 73,31  Say STR0044           Of oGroup03 COLOR CLR_BLACK 			  Pixel   //"Pré-Fatura:"
	TGet():New( 71, 59, bSETGET(nVLPFat),oGroup03, 50, 10, "@E 999,999,999.99", , /*[ nClrFore ]*/, /*[ nClrBack ]*/, /*[ oFont ]*/, , , .T., , , , , , , .T., , , "nVLPFat", , , , .F., .T., , , , , , )
	@ 100,25 Say STR0043         Of oGroup04 COLOR CLR_BLACK 			    Pixel   //"Doctos Frete:"
	TGet():New( 98, 59, bSETGET(nVLDocFret),oGroup04, 50, 10, "@E 999,999,999.99", , /*[ nClrFore ]*/, /*[ nClrBack ]*/, /*[ oFont ]*/, , , .T., , , , , , , .T., , , "nVLDocFret", , , , .F., .T., , , , , , )
	@ 114,39  Say STR0045              Of oGroup04 COLOR CLR_BLACK 			    Pixel   //"Cálculo:"
	TGet():New( 112, 59, bSETGET(nVLDocF),oGroup04, 50, 10, "@E 999,999,999.99", , /*[ nClrFore ]*/, /*[ nClrBack ]*/, /*[ oFont ]*/, , , .T., , , , , , , .T., , , "nVLDocF", , , , .F., .T., , , , , , )
	nDif := (nVLDocFret-nVLDocF)
	@ 128,33  Say STR0046    		  Of oGroup04 COLOR CLR_BLACK 			    Pixel   //"Diferença:"
	TGet():New( 126, 59, bSETGET(nDif),oGroup04, 50, 10, "@E 999,999,999.99", , /*[ nClrFore ]*/, /*[ nClrBack ]*/, /*[ oFont ]*/, , , .T., , , , , , , .T., , , "nDif", , , , .F., .T., , , , , , )
	// coluna 2
	If cTpImp == "1"
		nIcms := nVlImpDF
		nIcms2 := nVlImpC
		nIss  := 0
		nIss2 := 0
	ElseIf cTpImp == "2"
 		nIss := nVlImpDF
		nIss2 := nVlImpC
		nIcms  := 0
		nIcms2 := 0
	EndIf

	@ 43,300  Say 'Desconto:'    		   Of oGroup03 COLOR CLR_BLACK 			   Pixel   //"Variação :"
	TGet():New( 41, 331, bSETGET(nVlDesc),oGroup03, 50, 10, "@E 999,999,999.99", , /*[ nClrFore ]*/, /*[ nClrBack ]*/, /*[ oFont ]*/, , , .T., , , , , , , .T., , , "nVar", , , , .F., .T., , , , , , )
	@ 57,300  Say 'Indenização:'    	   Of oGroup03 COLOR CLR_BLACK 			   Pixel   //"Variação :"
	TGet():New( 55, 331, bSETGET(nDinden),oGroup03, 50, 10, "@E 999,999,999.99", , /*[ nClrFore ]*/, /*[ nClrBack ]*/, /*[ oFont ]*/, , , .T., , , , , , , .T., , , "nVar", , , , .F., .T., , , , , , )		
	@ 71,300  Say 'Total Desc:'    		   Of oGroup03 COLOR CLR_BLACK 			   Pixel   //"Variação :"
	TGet():New( 69, 331, bSETGET(nTotDesc),oGroup03, 50, 10, "@E 999,999,999.99", , /*[ nClrFore ]*/, /*[ nClrBack ]*/, /*[ oFont ]*/, , , .T., , , , , , , .T., , , "nVar", , , , .F., .T., , , , , , )
	nVar:= (nVlFat-nVLDocFret)
	@ 57,185  Say 'Variação:'    		   Of oGroup03 COLOR CLR_BLACK 			   Pixel   //"Variação :"
	TGet():New( 55, 209, bSETGET(nVar),oGroup03, 50, 10, "@E 999,999,999.99", , /*[ nClrFore ]*/, /*[ nClrBack ]*/, /*[ oFont ]*/, , , .T., , , , , , , .T., , , "nVar", , , , .F., .T., , , , , , )
	nVar2 := (nVlFat-nVLPFat)
	@ 71,185  Say 'Variação:'    		   Of oGroup03 COLOR CLR_BLACK 			   Pixel   //"Variação :"
	TGet():New( 69, 209, bSETGET(nVar2),oGroup03, 50, 10, "@E 999,999,999.99", , /*[ nClrFore ]*/, /*[ nClrBack ]*/, /*[ oFont ]*/, , , .T., , , , , , , .T., , , "nVar2", , , , .F., .T., , , , , , )
	@ 98,195  Say STR0048    			   Of oGroup04 COLOR CLR_BLACK 			    Pixel   //"Icms:"
	TGet():New( 96,209, bSETGET(nIcms),oGroup04, 50, 10, "@E 999,999,999.99", , /*[ nClrFore ]*/, /*[ nClrBack ]*/, /*[ oFont ]*/, , , .T., , , , , , , .T., , , "nIcms", , , , .F., .T., , , , , , )
	@ 112,195  Say STR0048    			   Of oGroup04 COLOR CLR_BLACK 			    Pixel   //"Icms:"
	TGet():New( 110,209, bSETGET(nIcms2),oGroup04, 50, 10, "@E 999,999,999.99", , /*[ nClrFore ]*/, /*[ nClrBack ]*/, /*[ oFont ]*/, , , .T., , , , , , , .T., , , "nIcms2", , , , .F., .T., , , , , , )
	nDif2 := (nIcms-nIcms2)
	@ 126,183  Say STR0046            Of oGroup04 COLOR CLR_BLACK 			    Pixel   //"Diferença:"
	TGet():New( 124, 209, bSETGET(nDif2),oGroup04, 50, 10, "@E 999,999,999.99", , /*[ nClrFore ]*/, /*[ nClrBack ]*/, /*[ oFont ]*/, , , .T., , , , , , , .T., , , "nDif2", , , , .F., .T., , , , , , )
	// coluna 3

	@ 98,319  Say STR0049                  Of oGroup04 COLOR CLR_BLACK 			    Pixel   //"Iss:"
	TGet():New( 96,329, bSETGET(nIss),oGroup04, 50, 10, "@E 999,999,999.99", , /*[ nClrFore ]*/, /*[ nClrBack ]*/, /*[ oFont ]*/, , , .T., , , , , , , .T., , , "nIss", , , , .F., .T., , , , , , )
	@ 112,319  Say STR0049                  Of oGroup04 COLOR CLR_BLACK 			    Pixel   //"Iss:"
	TGet():New( 110,329, bSETGET(nIss2),oGroup04, 50, 10, "@E 999,999,999.99", , /*[ nClrFore ]*/, /*[ nClrBack ]*/, /*[ oFont ]*/, , , .T., , , , , , , .T., , , "nIss2", , , , .F., .T., , , , , , )
	nDif3:=(nIss-nIss2)
	@ 126,303  Say STR0046            Of oGroup04 COLOR CLR_BLACK 			    Pixel   //"Diferença:"
	TGet():New( 124,329, bSETGET(nDif3),oGroup04, 50, 10, "@E 999,999,999.99", , /*[ nClrFore ]*/, /*[ nClrBack ]*/, /*[ oFont ]*/, , , .T., , , , , , , .T., , , "nDif3", , , , .F., .T., , , , , , )
	///-----------------------------------------------------------------------------------------
	//Folder 02 DOCUMENTOS

	oPnl2 := tPanel():New(00,00,,oFolder:ADialogs[2],,,,,,60,60,.F.,.F.)
	oPnl2:Align := CONTROL_ALIGN_ALLCLIENT

	oPnl21 := tPanel():New(00,00,,oPnl2,,,,,,01,01,.F.,.F.)
	oPnl21:Align := CONTROL_ALIGN_ALLCLIENT
	dbSelectArea(cAliMKB)
	(cAliMKB)->( dbSetOrder(1) )
	(cAliMKB)->( dbGoTop() )
 	@ 0,0 Listbox oListDoc Fields GFELoadBmp((cAliMKB)->GW3_SIT),;
 								  (cAliMKB)->FILIAL,;
 								  (cAliMKB)->TIPO  ,;
								  (cAliMKB)->SERIE ,;
							      (cAliMKB)->DOCUM ,;
							      GFEA071TpC((cAliMKB)->TPCALC),;
							      Transform((cAliMKB)->VLINFO   , "@E 999,999,999.99") ,;
							      Transform((cAliMKB)->VLCALC   , "@E 999,999,999.99") ,;
							      Transform((cAliMKB)->DIFVALOR , "@E 999,999,999.99") ,;
							      Transform((cAliMKB)->VLIMPINF , "@E 999,999,999.99") ,;
							      Transform((cAliMKB)->VLIMPCALC, "@E 999,999,999.99") ,;
							      Transform((cAliMKB)->DIFVLIMP , "@E 999,999,999.99")  ;
					      FieldSizes 10,20,20,20,50,40,40,40,40,50,50;
	                      Size 140, 290 Pixel Of oPnl21 ;
	                      HEADERS STR0067 ,; // "Situação"
	                      		  STR0066 ,; //"Filial"
	                      		  STR0050 ,; //"Tipo"
					    	   	  STR0051 ,; //"Série"
								  STR0052 ,; //"Documento"
								  STR0068 ,; //"Tipo Doc Frete"
								  STR0054 ,; //"Vl Informado"
								  STR0055 ,; //"Vl Cálculo"
								  STR0056 ,; //"Dif Valor"
								  STR0069 ,; //"Vl Imposto Inf"
								  STR0058 ,; //"Vl Imposto Calc"
								  STR0059  //"Dif Vl Imposto"

	oListDoc:Align := CONTROL_ALIGN_ALLCLIENT

	oPnl22 := tPanel():New(00,00,,oPnl2,,,,,,0,22,.F.,.F.)
	oPnl22:Align := CONTROL_ALIGN_BOTTOM

	oTButton1 := TButton():New( 002, 002, STR0060,oPnl22,{|| GFE071VIS((cAliMKB)->FILIAL, (cAliMKB)->TIPO, (cAliMKB)->SERIE, (cAliMKB)->DOCUM, (cAliMKB)->EMISDF, (cAliMKB)->DTEMIS)},; //"Detalhar"###"Detalhar"
               40,15,,,.F.,.T.,.F.,,.F.,,,.F. )
	oTButton2 := TButton():New( 002, 042, STR0038,oPnl22,{|| GFE071DIF((cAliMKB)->FILIAL, (cAliMKB)->TIPO, (cAliMKB)->SERIE, (cAliMKB)->DOCUM, (cAliMKB)->EMISDF, (cAliMKB)->DTEMIS)},; //"Diferenças"###"Diferenças"
               40,15,,,.F.,.T.,.F.,,.F.,,,.F. )            
    oTButton3 := TButton():New( 002, 082, STR0070,oPnl22,{|| GFEShowLeg()},; //"Legenda"###"Legenda"
               40,15,,,.F.,.T.,.F.,,.F.,,,.F. )

	// Ponto de entrada que permite um cálculo diferente do total de documentos da fatura
	If ExistBlock("GFEA0712")
		nQtdTotDoc := ExecBlock("GFEA0712",.F.,.F.)
	Else
		nQtdTotDoc := (cAliMKB)->(RecCount())			
	EndIf		

	@ 008,303  Say "Qtde Total Documentos:"            Of oPnl22 COLOR CLR_BLACK 			    Pixel   
	@ 006,362  MSGET nQtdTotDoc  Picture "@E 999999999" Of oPnl22 Valid /*ValidDic()*/ When .F.  Size 50,10 Pixel

 	//--------------------------
	// Fim da montagem da tela
	//--------------------------

	// Ponto de entrada que permite a inclusão de novas opções no menu
	// Outras Ações da tela de conferência das faturas de frete
	If ExistBlock("GFEA0711")
		aButtons := ExecBlock("GFEA0711",.F.,.F.)
		If ValType(aButtons) != 'A'
			aButtons := {}
		EndIf
	EndIf

	ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar(oDlg, {|| oDlg:End()}, {|| oDlg:End()}, /*lMsgDel*/, aButtons) CENTERED

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} GFE071VIS
Permite a visualização do documento de frete na tela de Detalhe Conf.

@author Fabiane
@since 20/07/2010
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function GFE071VIS(cFil, cEsp, cSer, cDoc, cEmis, cDtEmis)

	If (cAliMKB) -> (RecCount()) <> 0
		dbSelectArea("GW3")
		GW3->( dbSetOrder(1) )
		If GW3->( dbSeek(cFil + cEsp + cEmis + cSer + cDoc + DToS(cDtEmis)) )
			FWExecView("", 'GFEA065', 1,, {|| .T.})
		EndIf
	Else
		GFEMessage(5, GFEA071006, STR0085, STR0084) // "Não há nenhum documento para visualizar." / "Verifique se existe Documento de Frete associado a Fatura que esta sendo realizado a conferência."
	Endif

Return .T.

//-------------------------------------------------------------------
/*/{Protheus.doc} GFE071DIF
Permite a visualização da diferença relacionada ao Documento de Frete

@author Fabiane
@since 20/07/2010
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function GFE071DIF(cFil, cEsp, cSer, cDoc, cEmis, cDtEmis)

	If (cAliMKB) -> (RecCount()) <> 0
		dbSelectArea("GW3")
		dbSetOrder(1)
		If GW3->( dbSeek(cFil + cEsp + cEmis + cSer + cDoc + DToS(cDtEmis)) )
			GFEA066AP()
		EndIf
	Else
		GFEMessage(5, GFEA071007, STR0085, STR0084) // "Não há nenhum documento para visualizar." / "Verifique se existe Documento de Frete associado a Fatura que esta sendo realizado a conferência."
	Endif

Return .T.

//---------------------------------------------------------------------------------------------------
/*/{Protheus.doc} GFE071CD()
Calculos do Documentos de Frete
Generico

@sample
GFE071AB()

@author Felipe M.
@since 02/12/09
@version 1.0
/*///------------------------------------------------------------------------------------------------
Function GFE071CD()
	Local nPos := 0

	RecLock(cAliMKB, .T.)
		(cAliMKB)->GW3_SIT	 := GW3->GW3_SIT					//Situação CT-e
		(cAliMKB)->FILIAL    := GW3->GW3_FILIAL   				// Filial
		(cAliMKB)->TIPO      := GW3->GW3_CDESP   				// Tipo
		(cAliMKB)->SERIE     := GW3->GW3_SERDF  				// Serie
		(cAliMKB)->DOCUM     := GW3->GW3_NRDF   				// Documento
		(cAliMKB)->TPCALC    := GW3->GW3_TPDF   				// Tipo doc Frete
		(cAliMKB)->VLINFO    := GW3->GW3_VLDF   				// Valor Informado
		
		If nVLFRET == 0 
			nPos := aScan( aCalc , { |x| x[1] ==  cCalcComp } )
			If nPos > 0 
				(cAliMKB)->VLCALC    := aCalc[nPos][2] // Quando se usa 1 romaneio com 1 calculo somente para 2 Doc Frete 
				(cAliMKB)->DIFVALOR  := GW3->GW3_VLDF - aCalc[nPos][2]	// Diferença de valor
				(cAliMKB)->VLIMPCALC := aCalc[nPos][3] + aCalc[nPos][4] // valor do Imposto calculado(um sempre vai ser zero)
				(cAliMKB)->DIFVLIMP  := GW3->GW3_VLIMP - (aCalc[nPos][3] + aCalc[nPos][4]) // Diferença de Valor do Imposto
			EndIf
		Else 
			(cAliMKB)->VLCALC    := nVLFRET // Valor calculado
			(cAliMKB)->DIFVALOR  := GW3->GW3_VLDF - nVLFRET // Diferença de valor
			(cAliMKB)->VLIMPCALC := nVLISS + nVLICMS // valor do Imposto calculado(um sempre vai ser zero)
			(cAliMKB)->DIFVLIMP  := GW3->GW3_VLIMP - (nVLISS + nVLICMS) // Diferença de Valor do Imposto
		Endif
		
		(cAliMKB)->VLIMPINF  := GW3->GW3_VLIMP // valor do Imposto Informado
		(cAliMKB)->EMISDF    := GW3->GW3_EMISDF
		(cAliMKB)->DTEMIS    := GW3->GW3_DTEMIS
		
	(cAliMKB)->( MsUnlock() )

Return .T.

//---------------------------------------------------------------------------------------------------
/*/{Protheus.doc} GFEA071PF()
Valida a Condição de Pagamento da Pré-Fatura
Generico

@sample
GFEA071PF()

@author Felipe M.
@since 02/12/09
@version 1.0
/*///------------------------------------------------------------------------------------------------
Function GFEA071PF(cFilPar,cEmiFat,cSerFat,cNrFat,dDtEmFa)
	Local aAreaAnt 	:= {}
	Local cQuery 	:= ""
	Local cAliasQry := ""

	Default cFilPar := GW6->GW6_FILIAL
	Default cEmiFat := GW6->GW6_EMIFAT
	Default cSerFat := GW6->GW6_SERFAT
	Default cNrFat  := GW6->GW6_NRFAT
	Default dDtEmFa := GW6->GW6_DTEMIS

	aAreaAnt := GetArea()

	// GWJ_FILFAT+GWJ_EMIFAT+GWJ_SERFAT+GWJ_NRFAT+DTOS(GWJ_DTEMFA) <- indice 7
	// GWF_FILPRE+GWF_NRPREF <- indice 3

	cQuery := " SELECT GWJ.GWJ_FILIAL,"
	cQuery +=        " GWF.R_E_C_N_O_ RECNOGWF"
	cQuery +=   " FROM " + RetSqlName("GWJ") + " GWJ"
	cQuery +=  " INNER JOIN " + RetSqlName("GWF") + " GWF"
	cQuery +=     " ON GWF.GWF_FILPRE = GWJ.GWJ_FILIAL"
	cQuery +=    " AND GWF.GWF_NRPREF = GWJ.GWJ_NRPF"
	cQuery +=  " WHERE GWJ.GWJ_FILFAT = '" + cFilPar + "'"
	cQuery +=    " AND GWJ.GWJ_EMIFAT = '" + cEmiFat + "'"
	cQuery +=    " AND GWJ.GWJ_SERFAT = '" + cSerFat + "'"
	cQuery +=    " AND GWJ.GWJ_NRFAT  = '" + cNrFat  + "'"
	cQuery +=    " AND GWJ.GWJ_DTEMFA = '" + DtoS(dDtEmFa) + "'"
	cQuery +=    " AND GWJ.D_E_L_E_T_ = ' '"
	cQuery +=    " AND GWF.D_E_L_E_T_ = ' '"
	cQuery := ChangeQuery(cQuery)
	
	cAliasQry := GetNextAlias()
	dbSelectArea("GWF")
	dbUseArea( .T., "TOPCONN", TcGenQry(,,cQuery), cAliasQry, .T., .F. )
	Do While (cAliasQry)->(!Eof())

		GWF->(dbGoTo( (cAliasQry)->RECNOGWF ))
		If (cAliasQry)->GWJ_FILIAL == GWF->GWF_FILIAL
			nVLPFat += VLTOTFRET()
		EndIf

		(cAliasQry)->(dbSkip())
	EndDo
	(cAliasQry)->(dbCloseArea())

	RestArea(aAreaAnt)
Return .T.

//---------------------------------------------------------------------------------------------------
/*/{Protheus.doc} GFEA071DF()
Valida a Condição de Pagamento da Documento de Frete
Generico

@sample
GFEA071DF()

@author Felipe M.
@since 02/12/09
@version 1.0
/*///------------------------------------------------------------------------------------------------
Function GFEA071DF(lFlag)
	Local lExistCamp := GFXCP12116("GWF","GWF_CDESP") .And. (SuperGetMV("MV_DPSERV", .F., "1") == "1")  .And. (FindFunction("GFEA065VFIX") .And. GFEA065VFIX())
	Local cQuery     := ""
	Local cAliasQry  := ""

	Private cCalcComp := ""
	Private nVLFRET   := 0, nVLISS := 0, nVLICMS := 0
	Private aCalc 	  := {}

	GW3->( dbSetOrder(8) )
	GW3->( dbSeek(GW6->GW6_FILIAL + GW6->GW6_EMIFAT + GW6->GW6_SERFAT + GW6->GW6_NRFAT + DToS(GW6->GW6_DTEMIS)) )
	While !GW3->( Eof() ) .And. GW3->GW3_FILFAT == GW6->GW6_FILIAL .And. GW3->GW3_EMIFAT == GW6->GW6_EMIFAT .And. ;
		  					    GW3->GW3_SERFAT == GW6->GW6_SERFAT .And. GW3->GW3_NRFAT == GW6->GW6_NRFAT .And. DToS(GW3->GW3_DTEMFA) == DToS(GW6->GW6_DTEMIS)

		nVLFRET := 0
		nVLISS  := 0
		nVLICMS := 0

		nVLDocFret := nVLDocFret + GW3->GW3_VLDF

		cTpImp := Posicione("GVT", 1, xFilial("GVT") + GW3->GW3_CDESP, "GVT_TPIMP")

		nVlImpDF := nVlImpDF + GW3->GW3_VLIMP

		If lExistCamp //Utiliza novo indice entre GWF x GW3 para buscar valor do frete
			cQuery := " SELECT GWF_NRCALC,GWF_VLICMS,GWF_VLISS,SUM(GWI_VLFRET) GWI_VLFRET, GWF_VLAJUS"
			cQuery += "   FROM "+RetSqlName('GWF')+" GWF" 
			cQuery += "  INNER JOIN "+RetSqlName('GWI')+" GWI" 
			cQuery += "     ON GWI.GWI_FILIAL = GWF.GWF_FILIAL"
			cQuery += "    AND GWI.GWI_NRCALC = GWF.GWF_NRCALC"
			cQuery += "    AND GWI.GWI_TOTFRE = '1'"
			cQuery += "    AND GWI.D_E_L_E_T_ = ' '"
			cQuery += "  WHERE GWF_FILIAL     = '"+GW3->GW3_FILIAL+"'"
			cQuery += "    AND GWF.GWF_CDESP  = '"+GW3->GW3_CDESP +"'"
			cQuery += "    AND GWF.GWF_EMISDF = '"+GW3->GW3_EMISDF+"'"
			cQuery += "    AND GWF.GWF_SERDF  = '"+GW3->GW3_SERDF+"'"
			cQuery += "    AND GWF.GWF_NRDF   = '"+GW3->GW3_NRDF+"'" 
			cQuery += "    AND GWF.GWF_DTEMDF = '"+DToS(GW3->GW3_DTEMIS)+"'"
			cQuery += "    AND GWF.D_E_L_E_T_ = ' '"
			cQuery += "  GROUP BY GWF_NRCALC,GWF_VLICMS,GWF_VLISS,GWF_VLAJUS"
			cQuery := ChangeQuery(cQuery)
			cAliasQry := GetNextAlias()
			dbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery), cAliasQry, .F., .T.)
			
			While (cAliasQry)->(!EoF())
		
				nVlImpC += (cAliasQry)->GWF_VLICMS + (cAliasQry)->GWF_VLISS
				nVLDocF := nVLDocF + (cAliasQry)->GWI_VLFRET + (cAliasQry)->GWF_VLAJUS
	
				If !lFlag
					nVLFRET += (cAliasQry)->GWI_VLFRET
					nVLISS   += (cAliasQry)->GWF_VLISS
					nVLICMS  += (cAliasQry)->GWF_VLICMS					
				EndIf
			
				(cAliasQry)->(dbSkip())
			EndDo
			(cAliasQry)->(dbCloseArea())
		Else

			GW4->( dbSetOrder(1) )
			GW4->( dbSeek(GW3->GW3_FILIAL + GW3->GW3_EMISDF + GW3->GW3_CDESP + GW3->GW3_SERDF + GW3->GW3_NRDF + DToS(GW3->GW3_DTEMIS)) )
			While !GW4->( Eof() ) .And. GW3->GW3_FILIAL == GW4->GW4_FILIAL .And. GW4->GW4_CDESP == GW3->GW3_CDESP;
						 		  .And. GW4->GW4_EMISDF == GW3->GW3_EMISDF .And. GW4->GW4_SERDF == GW3->GW3_SERDF;
						 		  .And. GW4->GW4_NRDF   == GW3->GW3_NRDF .And. DtoS(GW4->GW4_DTEMIS) == DToS(GW3->GW3_DTEMIS)
	
				GWH->( dbSetOrder(2) )
				GWH->( dbSeek(GW4->GW4_FILIAL + GW4->GW4_TPDC + GW4->GW4_EMISDC + GW4->GW4_SERDC + GW4->GW4_NRDC) )
				While !GWH->( Eof() ) .And. GW4->GW4_FILIAL == GWH->GWH_FILIAL .And. GWH->GWH_CDTPDC == GW4->GW4_TPDC;
				             		  .And. GWH->GWH_EMISDC == GW4->GW4_EMISDC .And. GWH->GWH_SERDC == GW4->GW4_SERDC;
				             		  .And. GWH->GWH_NRDC == GW4->GW4_NRDC 
	
					GWF->( dbSetOrder(1) )
					If GWF->( dbSeek(GWH->GWH_FILIAL + GWH->GWH_NRCALC) ) 
						If GW3->GW3_TPDF == GWF->GWF_TPCALC
							If (GWF->GWF_TPCALC != GW3->GW3_TPDF .And. GWF->GWF_TRANSP != GW3->GW3_EMISDF;
									.or. (s_VLCNPJ == "2" .and. SubStr(Posicione("GU3", 1, xFilial("GU3") +GW3->GW3_EMISDF, "GU3->GU3_IDFED"), 1, 8) != SubStr(Posicione("GU3", 1, xFilial("GU3") + GWF->GWF_TRANSP, "GU3->GU3_IDFED"), 1, 8)));
									.Or. aScan(aCalc,{|x| x[1] == GWF->GWF_NRCALC}) > 0
							
								cCalcComp := GWF->GWF_NRCALC
					   			GWH->( dbSkip() )
								Loop
							EndIf

							nVlImpC += GWF->GWF_VLICMS + GWF->GWF_VLISS

							GWI->( dbSetOrder(1) )
							GWI->( dbSeek(GWF->GWF_FILIAL + GWF->GWF_NRCALC) )
							While !GWI->( Eof() ) .And. GWI->GWI_FILIAL == GWF->GWF_FILIAL .And. GWI->GWI_NRCALC ==GWF->GWF_NRCALC .AND. GW3->GW3_TPDF == GWF->GWF_TPCALC

								If GWI->GWI_TOTFRE == "1"
									nVLDocF := nVLDocF + GWI->GWI_VLFRET
									If !lFlag
										nVLFRET += GWI->GWI_VLFRET
									EndIf
								EndIf
	
								GWI->( dbSkip() )
							EndDo
							nVLDocF := nVLDocF + GWF->GWF_VLAJUS
							
							If !lFlag
								nVLISS  += GWF->GWF_VLISS
								nVLICMS += GWF->GWF_VLICMS				
							EndIf
							
							aAdd(aCalc, {GWF->GWF_NRCALC, nVLFRET, nVLISS, nVLICMS})	
						EndIf
					EndIf
        	
					GWH->( dbSkip() )
				EndDo
	 
				GW4->( dbSkip() )
		    EndDo
	    EndIf

		If !lFlag
			GFE071CD()
		EndIf

		GW3->( dbSkip() )
	EndDo

Return .T.

//---------------------------------------------------------------------------------------------------
/*/{Protheus.doc} GFEA071TpC()
Legenda para o Tipo do documento de Frete
@sample
GFEA071TpC()

@author Ana Claudia da Silva
@since 10/02/15
@version 1.0
/*///------------------------------------------------------------------------------------------------
Function GFEA071TpC(cDTipo)
	Local cTpCalc := cDTipo

	If alltrim(cDTipo) == "1"
		cTpCalc := "Normal"
	ElseIf alltrim(cDTipo) == "2"
		cTpCalc := "Complementar Valor"
	ElseIf alltrim(cDTipo) == "3"
		cTpCalc := "Complementar Imposto"
	ElseIf alltrim(cDTipo) == "4"
		cTpCalc := "Reentrega"
	ElseIf alltrim(cDTipo) == "5"
		cTpCalc := "Devolução"
	ElseIf alltrim(cDTipo) == "6"
		cTpCalc := "Redespacho"
	ElseIf alltrim(cDTipo) == "7"
		cTpCalc := "Serviço"
	EndIf

Return cTpCalc

/*/{Protheus.doc} GFELoadBmp()
Legenda para a situação do Documento de Frete.
@sample
GFELoadBmp()

@author Hercilio Henning Neto
@since 10/10/2016
@version 1.0
/*///------------------------------------------------------------------------------------------------
Static Function GFELoadBmp(cValue)
	Local oImg

	If AllTrim(cValue) == '1'
		oImg := LoadBitmap(GetResources(),'BR_PRETO')
	ElseIf AllTrim(cValue) == '2'
		oImg := LoadBitmap( GetResources(), 'BR_VERMELHO')
	ElseIf AllTrim(cValue) == '3'
		oImg := LoadBitmap( GetResources(), 'BR_VERDE')
	ElseIf AllTrim(cValue) == '4'
		oImg := LoadBitmap( GetResources(), 'BR_AZUL')	
	ElseIf AllTrim(cValue) == '5'
		oImg := LoadBitmap( GetResources(), 'BR_AMARELO')	
	EndIf

Return oImg

/*/{Protheus.doc} GFEShowLeg()
Legenda para a situação do Documento de Frete.
@sample
GFELoadBmp()

@author Hercilio Henning Neto
@since 10/10/2016
@version 1.0
/*///------------------------------------------------------------------------------------------------
Function GFEShowLeg()
	Local aLegenda := {}

	AADD(aLegenda,{"BR_PRETO" 	, "Digitado" })
	AADD(aLegenda,{"BR_VERMELHO", "Bloqueado" })
	AADD(aLegenda,{"BR_VERDE"   , "Aprovado pelo Sistema" })
	AADD(aLegenda,{"BR_AZUL"    , "Aprovado pelo Usuário" })
	AADD(aLegenda,{"BR_AMARELO" , "Bloqueado por Entrega" })

	BrwLegenda("Situação CT-e", "Legenda", aLegenda)

Return Nil


/*/{Protheus.doc} GFEA071CON
	Função (cópia da GFEA057CON) responsável por validar todas pré-faturas relacionadas à fatura de frete 
@author marcos.wagner
@since 23/09/2016
@version 1.0
/*/
Function GFEA071CON(cValue)
	Local aOldArea := GetArea()

	dbSelectArea("GWJ")
	dbSetOrder(7)
	If dbSeek(GW6->GW6_FILIAL+GW6->GW6_EMIFAT+GW6->GW6_SERFAT+GW6->GW6_NRFAT+DTOS(GW6->GW6_DTEMIS))
		While !GWJ->(Eof()) .AND. GWJ->GWJ_FILIAL == GW6->GW6_FILIAL .AND. GWJ->GWJ_EMIFAT == GW6->GW6_EMIFAT .AND.;
								  GWJ->GWJ_SERFAT == GW6->GW6_SERFAT .AND. GWJ->GWJ_NRFAT  == GW6->GW6_NRFAT .AND.;
								  GWJ->GWJ_DTEMFA == GW6->GW6_DTEMIS

			If cValue == "1" .And. GWJ->GWJ_SIT == "2" //Se situacao da pré-fatura for enviada                                                                                   
				RecLock('GWJ')
				GWJ->GWJ_SIT    := "3"
				GWJ->GWJ_DTAPR  := DDATABASE
				GWJ->GWJ_HRAPR  := TIME()
				GWJ->GWJ_USUAPR := cUserName
				GWJ->( MsUnLock() )
	
				If s_TPGERA == "1"
					GFEACTBPRE( GWJ->GWJ_FILIAL , GWJ->GWJ_NRPF )
				EndIf
	
				If s_GFEI15_2 == '2' //Integração automatica Financeiro
					oModelIn := FWLoadModel("GFEA055")
					GFEA055X(.T.,oModelIn)
					oModelIn:DeActivate()
					oModelIn:Destroy()
				EndIf
			Elseif cValue == "2" .And. s_GFEPF1 == '2' .And. GWJ->GWJ_SIT == "3" .And.;
		       		(GWJ->GWJ_SITFIN == "1" .or. GWJ->GWJ_SITFIN == "3")    //Voltar a situação para Enviada
    	      		      
		      	RecLock('GWJ')
		      	GWJ->GWJ_SIT    := "2"
		      	GWJ->GWJ_DTAPR  := CtoD(" / / ")                                                                                                       
		      	GWJ->GWJ_HRAPR  := ""                                              		
		      	GWJ->GWJ_USUAPR := ""
		      	GWJ->( MsUnLock() )
	
		      	// Eliminação dos movimentos contábeis
		      	GFEA057EMC(GWJ->GWJ_FILIAL, GWJ->GWJ_NRPF)      
			Endif

			GWJ->(dbSkip())
		EndDo
	EndIf

	RestArea(aOldArea)
Return
 