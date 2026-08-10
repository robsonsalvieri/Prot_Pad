#INCLUDE "GFEA015.ch"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"
   
STATIC cUFs 	:= "" 

//-------------------------------------------------------------------
/*/{Protheus.doc} GFEA015
Rotina para o cadastro de Emitentes.
Uso Geral. 

@author Luiz Fernando Soares
@since 20/11/09
@version 1.0
/*/

//-------------------------------------------------------------------

Function GFEA015()
	Local oBrowse
	Private aRotina := MenuDef()

	/*-------Variavel utiliza no banco de dados para verificar se a filial esta como nao,------- 
	-------foi necessario, pois nao tinha mais espaço no when do campo transp e auton  ------- */
										
	DbSelectArea('GU3')
	/*Utiliza o comando Chkfile para abrir a Tabela com outro nome, para que na Consulta do campo GU3_CDEMFT, o resultado desposicione o registro */
	//Chkfile( 'GU3',,'GU3TRP')

	oBrowse := FWMBrowse():New()
	oBrowse:SetAlias("GU3")							// Alias da tabela utilizada
	oBrowse:SetMenuDef("GFEA015")					// Nome do fonte onde esta a função MenuDef
	oBrowse:SetDescription(STR0024)	// Descrição do browse //"Cadastro de Emitentes"
	private 	lWhenFil := GU3->GU3_EMFIL == "2"
	oBrowse:Activate()

	//GU3TRP->( dbCloseArea() )

Return(Nil)

//-------------------------------------------------------------------
Static Function MenuDef()
	Local aRotina := {}

	//-------------------------------------------------------------------
	// Adiciona botões do browse                                                               
	//-------------------------------------------------------
	ADD OPTION aRotina TITLE STR0001 ACTION "AxPesqui"        OPERATION 1 ACCESS 0 //"Pesquisar"
	ADD OPTION aRotina TITLE STR0002 ACTION "VIEWDEF.GFEA015" OPERATION 2 ACCESS 0 //"Visualizar"
	ADD OPTION aRotina TITLE STR0004 ACTION "VIEWDEF.GFEA015" OPERATION 4 ACCESS 0 //"Alterar"
	
	// Integração - Retira botão incluir, excluir e copiar quando for integrago com o ERP
	If SuperGetMv("MV_CADERP",.F.,"2N") $ "2N"
		ADD OPTION aRotina TITLE STR0003 ACTION "VIEWDEF.GFEA015" OPERATION 3 ACCESS 0 //"Incluir"
		ADD OPTION aRotina TITLE STR0005 ACTION "VIEWDEF.GFEA015" OPERATION 5 ACCESS 0 //"Excluir"
		ADD OPTION aRotina TITLE STR0006 ACTION "VIEWDEF.GFEA015" OPERATION 9 ACCESS 0 //"Copiar"
	EndIf
	// Fim - Integração

	ADD OPTION aRotina TITLE STR0007   ACTION "VIEWDEF.GFEA015" OPERATION 8 ACCESS 0 //"Imprimir"

	//Integração - Cadastra filial para possibilitar integração notas de saída
	If SuperGetMv("MV_ERPGFE",.F.,"2") == "2" .And. SuperGetMv("MV_CADERP",.F.,"2N") == "1"
		ADD OPTION aRotina TITLE 'Cadastrar Filial' ACTION 'GFEA015FIL()' OPERATION 4 ACCESS 0 //"Incluir"
	EndIf

    ADD OPTION aRotina TITLE "Anexos" ACTION "MsDocument('GU3',GU3->(RecNo()), 4)"  OPERATION 4 ACCESS 0  // "Anexo"

Return aRotina

//-------------------------------------------------------------------
Static Function ModelDef()                              
	Local oModel
	Local oStructGU3 := FWFormStruct(1,"GU3")
	Local oStructGU2 := FWFormStruct(1,"GU2")

	oStructGU2:RemoveField( "GU2_FILIAL" )
	oStructGU2:RemoveField( "GU2_CDEMIT" )
	oStructGU3:SetProperty( "GU3_ESEXIC", MODEL_FIELD_INIT , FwBuildFeature( STRUCT_FEATURE_INIPAD, "If(!Inclui,CargUF(),'')" ))

	// cID     Identificador do modelo
	// bPre    Code-Block de pre-edição do formulário de edição. Indica se a edição esta liberada
	// bPost   Code-Block de validação do formulário de edição
	// bCommit Code-Block de persistência do formulário de edição
	// bCancel Code-Block de cancelamento do formulário de edição
	oModel := MPFormModel():New("GFEA015",  /*bPre*/, {|oX|GFEA015VAL(oX)}  /*bPost*/, /*bCommit*/, /*bCancel*/)
	// cId          Identificador do modelo
	// cOwner       Identificador superior do modelo
	// oModelStruct Objeto com  a estrutura de dados
	// bPre         Code-Block de pré-edição do formulário de edição. Indica se a edição esta liberada
	// bPost        Code-Block de validação do formulário de edição
	// bLoad        Code-Block de carga dos dados do formulário de edição
	oModel:AddFields("GFEA015_GU3", Nil,oStructGU3,/*bPre*/,/*bPost*/,/*bLoad*/) 

	oModel:AddGrid("GFEA015_GU2","GFEA015_GU3",oStructGU2,/*bLinePre*/, /*{|oX|GFEA015BRW(oX)}*/ ,/*bPre*/,/*bPost*/,/*bLoad*/)
	oModel:SetRelation("GFEA015_GU2",{{"GU2_FILIAL",'xFilial("GU3")'},{"GU2_CDEMIT","GU3_CDEMIT"}},"GU2_SEQ")
	oModel:SetPrimaryKey({"GU3_FILIAL", "GU3_CDEMIT"})
	oModel:GetModel("GFEA015_GU2"):SetDelAllLine(.T.)

	oModel:SetOptional("GFEA015_GU2", .T. )

	oModel:SetActivate( {|oMod| GFEA15ACT(oMod)} )

	oModel:SetVldActivate( {|oX|GFEA015VL(oX)} )

Return oModel

//-------------------------------------------------------------------
Static Function ViewDef()
	Local oModel     := FWLoadModel("GFEA015")
	Local oView      := Nil
	Local oStruct    := FWFormStruct(2,"GU3")
	Local oStructGU2 := FWFormStruct(2,"GU2")

	oStruct:RemoveField("GU3_ICMPRE")
	oStruct:RemoveField("GU3_SBTRIB")
	oStruct:RemoveField("GU3_MVTERC")
	If GFXCP12123("GU2_NMEMIT")
		oStructGU2:RemoveField( "GU2_NMEMIT" )
	EndIf

	oStruct:AddGroup("GeralIdent"  , "Identificação", "1", 2)
	oStruct:AddGroup("GeralCarac"  , "Caracterização", "1", 2)
	oStruct:AddGroup("GeralGrEmit" , "Grupos de Emitentes", "1", 2)
	oStruct:AddGroup("GeralControl", "Controle", "1", 2)

	oStruct:AddGroup("GrpGer"	 , "Geral", "5", 2)
	oStruct:AddGroup("GrpTrb"	 , STR0027, "5", 2)
	oStruct:AddGroup("GrpDCF"	 , STR0028, "5", 2)
	oStruct:AddGroup("GrpPrF"	 , "Pré-Fatura - Geral", "5", 2)
	oStruct:AddGroup("GrpPrFAgr" , "Pré-Fatura - Agrupamento dos cálculos", "5", 2)
	oStruct:AddGroup("GrpPrFVenc", "Pré-Fatura/Fatura Avulsa - Data de vencimento", "5", 2)
	oStruct:AddGroup("GrpFat"	 , STR0030, "5", 2)
	oStruct:AddGroup("GrpAut"	 , "Autônomo", "5", 2)
	oStruct:AddGroup("GrpEdi"	 , "EDI", "5", 2)
	oStruct:AddGroup("GrpOco"	 , "Ocorrências", "5", 2)

	/* Pasta Geral*/
	oStruct:SetProperty("GU3_CDEMIT", MVC_VIEW_GROUP_NUMBER, "GeralIdent")
	oStruct:SetProperty("GU3_NMEMIT", MVC_VIEW_GROUP_NUMBER, "GeralIdent")
	oStruct:SetProperty("GU3_NMFAN" , MVC_VIEW_GROUP_NUMBER, "GeralIdent")
	oStruct:SetProperty("GU3_NMABRV", MVC_VIEW_GROUP_NUMBER, "GeralIdent")
	oStruct:SetProperty("GU3_DTNASC", MVC_VIEW_GROUP_NUMBER, "GeralIdent")

	If AScan(oStruct:aFields,{|x| x[1] == "GU3_CDERP"}) != 0
		oStruct:SetProperty("GU3_CDERP" , MVC_VIEW_GROUP_NUMBER, "GeralIdent")
		oStruct:SetProperty("GU3_CDCERP", MVC_VIEW_GROUP_NUMBER, "GeralIdent")
	EndIf

	oStruct:SetProperty("GU3_NATUR" , MVC_VIEW_GROUP_NUMBER, "GeralCarac")
	oStruct:SetProperty("GU3_EMFIL" , MVC_VIEW_GROUP_NUMBER, "GeralCarac")
	oStruct:SetProperty("GU3_TRANSP", MVC_VIEW_GROUP_NUMBER, "GeralCarac")
	oStruct:SetProperty("GU3_CLIEN" , MVC_VIEW_GROUP_NUMBER, "GeralCarac")
	oStruct:SetProperty("GU3_FORN"  , MVC_VIEW_GROUP_NUMBER, "GeralCarac")
	oStruct:SetProperty("GU3_AUTON" , MVC_VIEW_GROUP_NUMBER, "GeralCarac")
	
	oStruct:SetProperty("GU3_CDGREM", MVC_VIEW_GROUP_NUMBER, "GeralGrEmit")
	oStruct:SetProperty("GU3_CDGRED", MVC_VIEW_GROUP_NUMBER, "GeralGrEmit")
	oStruct:SetProperty("GU3_CDGRGL", MVC_VIEW_GROUP_NUMBER, "GeralGrEmit")
	
	oStruct:SetProperty("GU3_ORIGEM", MVC_VIEW_GROUP_NUMBER, "GeralControl")
	oStruct:SetProperty("GU3_DTIMPL", MVC_VIEW_GROUP_NUMBER, "GeralControl")
	oStruct:SetProperty("GU3_SIT"   , MVC_VIEW_GROUP_NUMBER, "GeralControl")
	
	/* Pasta Transportador */
	oStruct:SetProperty("GU3_CATTRP", MVC_VIEW_GROUP_NUMBER, "GrpGer")
	oStruct:SetProperty("GU3_MODAL" , MVC_VIEW_GROUP_NUMBER, "GrpGer")
	oStruct:SetProperty("GU3_FRCOMB", MVC_VIEW_GROUP_NUMBER, "GrpGer")
	oStruct:SetProperty("GU3_ANTT"  , MVC_VIEW_GROUP_NUMBER, "GrpGer")
	oStruct:SetProperty("GU3_REDESP", MVC_VIEW_GROUP_NUMBER, "GrpGer")
		
	If AScan(oStruct:aFields,{|x| x[1] == "GU3_CDTERP"}) != 0
		oStruct:SetProperty("GU3_CDTERP", MVC_VIEW_GROUP_NUMBER, "GrpGer")
	EndIf
	
	If AScan(oStruct:aFields,{|x| x[1] == "GU3_DEDIC"}) != 0
		oStruct:SetProperty("GU3_DEDIC", MVC_VIEW_GROUP_NUMBER, "GrpGer")
	EndIf
	
	oStruct:SetProperty("GU3_APUICM", MVC_VIEW_GROUP_NUMBER, "GrpTrb")
	oStruct:SetProperty("GU3_APUISS", MVC_VIEW_GROUP_NUMBER, "GrpTrb")

	If GFXCP1212410("GU3_APISSO")
		oStruct:SetProperty("GU3_APISSO", MVC_VIEW_GROUP_NUMBER, "GrpTrb")
	EndIf

	If AScan(oStruct:aFields,{|x| x[1] == "GU3_VALEP"}) != 0
		oStruct:SetProperty("GU3_VALEP", MVC_VIEW_GROUP_NUMBER, "GrpTrb")
	EndIf
	oStruct:SetProperty("GU3_MAXDOC", MVC_VIEW_GROUP_NUMBER, "GrpDCF")
	oStruct:SetProperty("GU3_AGRDOC", MVC_VIEW_GROUP_NUMBER, "GrpDCF")
	oStruct:SetProperty("GU3_ACOCO" , MVC_VIEW_GROUP_NUMBER, "GrpDCF")
	oStruct:SetProperty("GU3_ENTOBR", MVC_VIEW_GROUP_NUMBER, "GrpDCF")
	oStruct:SetProperty("GU3_CTE"   , MVC_VIEW_GROUP_NUMBER, "GrpDCF")
	oStruct:SetProperty("GU3_FATAUT", MVC_VIEW_GROUP_NUMBER, "GrpDCF")
	
	If GFXCP12130("GU3_AGRDC")
		oStruct:SetProperty("GU3_AGRDC" , MVC_VIEW_GROUP_NUMBER, "GrpDCF")
	EndIF
	
	If GFXPR12127("GU3_SUBCON")
		oStruct:SetProperty("GU3_SUBCON", MVC_VIEW_GROUP_NUMBER, "GrpDCF")
	EndIf

	oStruct:SetProperty("GU3_CAUTPF", MVC_VIEW_GROUP_NUMBER, "GrpPrF")
	oStruct:SetProperty("GU3_PFCALC", MVC_VIEW_GROUP_NUMBER, "GrpPrFAgr")
	oStruct:SetProperty("GU3_PFFIL" , MVC_VIEW_GROUP_NUMBER, "GrpPrFAgr")
	oStruct:SetProperty("GU3_PFUF"  , MVC_VIEW_GROUP_NUMBER, "GrpPrFAgr")
	oStruct:SetProperty("GU3_PFCLAS", MVC_VIEW_GROUP_NUMBER, "GrpPrFAgr")
	oStruct:SetProperty("GU3_PFTPFR", MVC_VIEW_GROUP_NUMBER, "GrpPrFAgr")
	oStruct:SetProperty("GU3_PFTPSE", MVC_VIEW_GROUP_NUMBER, "GrpPrFAgr")
	oStruct:SetProperty("GU3_PFNORM", MVC_VIEW_GROUP_NUMBER, "GrpPrFAgr")
	oStruct:SetProperty("GU3_PFCPVL", MVC_VIEW_GROUP_NUMBER, "GrpPrFAgr")
	oStruct:SetProperty("GU3_PFCPIC", MVC_VIEW_GROUP_NUMBER, "GrpPrFAgr")
	oStruct:SetProperty("GU3_PFDEV" , MVC_VIEW_GROUP_NUMBER, "GrpPrFAgr")
	oStruct:SetProperty("GU3_PFREDE", MVC_VIEW_GROUP_NUMBER, "GrpPrFAgr")
	oStruct:SetProperty("GU3_PFREEN", MVC_VIEW_GROUP_NUMBER, "GrpPrFAgr")
	oStruct:SetProperty("GU3_PFSERV", MVC_VIEW_GROUP_NUMBER, "GrpPrFAgr")
	oStruct:SetProperty("GU3_CALCVC", MVC_VIEW_GROUP_NUMBER, "GrpPrFVenc")
	oStruct:SetProperty("GU3_PRAZO" , MVC_VIEW_GROUP_NUMBER, "GrpPrFVenc")
	oStruct:SetProperty("GU3_ACAOVC", MVC_VIEW_GROUP_NUMBER, "GrpPrFVenc")
	oStruct:SetProperty("GU3_TPFREQ", MVC_VIEW_GROUP_NUMBER, "GrpPrFVenc")
	oStruct:SetProperty("GU3_DBAS1" , MVC_VIEW_GROUP_NUMBER, "GrpPrFVenc")
	oStruct:SetProperty("GU3_DBAS2" , MVC_VIEW_GROUP_NUMBER, "GrpPrFVenc")
	oStruct:SetProperty("GU3_DBAS3" , MVC_VIEW_GROUP_NUMBER, "GrpPrFVenc")
	oStruct:SetProperty("GU3_DBAS4" , MVC_VIEW_GROUP_NUMBER, "GrpPrFVenc")
	oStruct:SetProperty("GU3_DBAS5" , MVC_VIEW_GROUP_NUMBER, "GrpPrFVenc")
	oStruct:SetProperty("GU3_SEGUN" , MVC_VIEW_GROUP_NUMBER, "GrpPrFVenc")
	oStruct:SetProperty("GU3_TERCA" , MVC_VIEW_GROUP_NUMBER, "GrpPrFVenc")
	oStruct:SetProperty("GU3_QUARTA", MVC_VIEW_GROUP_NUMBER, "GrpPrFVenc")
	oStruct:SetProperty("GU3_QUINTA", MVC_VIEW_GROUP_NUMBER, "GrpPrFVenc")
	oStruct:SetProperty("GU3_SEXTA" , MVC_VIEW_GROUP_NUMBER, "GrpPrFVenc")
	
	oStruct:SetProperty("GU3_CXEDI", MVC_VIEW_GROUP_NUMBER, "GrpEdi")
	oStruct:SetProperty("GU3_EDICTE", MVC_VIEW_GROUP_NUMBER, "GrpEdi")
	If AScan(oStruct:aFields,{|x| x[1] == "GU3_OCORET"}) != 0
		oStruct:SetProperty("GU3_OCORET", MVC_VIEW_GROUP_NUMBER, "GrpOco")
	EndIf
	
	oStruct:SetProperty("GU3_CDEMFT", MVC_VIEW_GROUP_NUMBER, "GrpFat")
	oStruct:SetProperty("GU3_NMEMFT", MVC_VIEW_GROUP_NUMBER, "GrpFat")
	
	oStruct:SetProperty("GU3_INSS" , MVC_VIEW_GROUP_NUMBER, "GrpAut")
	oStruct:SetProperty("GU3_NRDEP", MVC_VIEW_GROUP_NUMBER, "GrpAut")
	
	// Integração - Desabilita campos
	If SuperGetMV('MV_CADERP',,'1') $ "1S"
		oStruct:SetProperty("GU3_CDEMIT" , MVC_VIEW_CANCHANGE ,.F.)
		oStruct:SetProperty("GU3_NMEMIT" , MVC_VIEW_CANCHANGE ,.F.)
		oStruct:SetProperty("GU3_NMFAN"  , MVC_VIEW_CANCHANGE ,.F.)
		oStruct:SetProperty("GU3_NMABRV" , MVC_VIEW_CANCHANGE ,.F.)
		oStruct:SetProperty("GU3_NATUR"  , MVC_VIEW_CANCHANGE ,.F.)
		oStruct:SetProperty("GU3_DTNASC" , MVC_VIEW_CANCHANGE ,.F.)
		oStruct:SetProperty("GU3_DTIMPL" , MVC_VIEW_CANCHANGE ,.F.)
		oStruct:SetProperty("GU3_ORIGEM" , MVC_VIEW_CANCHANGE ,.F.)
		oStruct:SetProperty("GU3_CLIEN"  , MVC_VIEW_CANCHANGE ,.F.)
		oStruct:SetProperty("GU3_FORN"   , MVC_VIEW_CANCHANGE ,.F.)
		oStruct:SetProperty("GU3_ENDER"  , MVC_VIEW_CANCHANGE ,.F.)
		oStruct:SetProperty("GU3_COMPL"  , MVC_VIEW_CANCHANGE ,.F.)
		oStruct:SetProperty("GU3_BAIRRO" , MVC_VIEW_CANCHANGE ,.F.)
		oStruct:SetProperty("GU3_CEP"    , MVC_VIEW_CANCHANGE ,.F.)
		oStruct:SetProperty("GU3_NRCID"  , MVC_VIEW_CANCHANGE ,.F.)
		oStruct:SetProperty("GU3_NMCID"  , MVC_VIEW_CANCHANGE ,.F.)
		oStruct:SetProperty("GU3_UF"     , MVC_VIEW_CANCHANGE ,.F.)
		oStruct:SetProperty("GU3_IDFED"  , MVC_VIEW_CANCHANGE ,.F.)
		oStruct:SetProperty("GU3_IE"     , MVC_VIEW_CANCHANGE ,.F.)
		oStruct:SetProperty("GU3_IM"     , MVC_VIEW_CANCHANGE ,.F.)
		oStruct:SetProperty("GU3_CXPOS"  , MVC_VIEW_CANCHANGE ,.F.)
		oStruct:SetProperty("GU3_EMAIL"  , MVC_VIEW_CANCHANGE ,.F.)
		oStruct:SetProperty("GU3_FONE1"  , MVC_VIEW_CANCHANGE ,.F.)
		oStruct:SetProperty("GU3_RAMAL1" , MVC_VIEW_CANCHANGE ,.F.)
		oStruct:SetProperty("GU3_FONE2"  , MVC_VIEW_CANCHANGE ,.F.)
		oStruct:SetProperty("GU3_RAMAL2" , MVC_VIEW_CANCHANGE ,.F.)
		oStruct:SetProperty("GU3_FAX"    , MVC_VIEW_CANCHANGE ,.F.)
		oStruct:SetProperty("GU3_RAMALF" , MVC_VIEW_CANCHANGE ,.F.)
		oStruct:SetProperty("GU3_WSITE"  , MVC_VIEW_CANCHANGE ,.F.)
		oStruct:SetProperty("GU3_SIT"    , MVC_VIEW_CANCHANGE ,.F.)		
	EndIf
	// FIM - Integração

	//Pasta Transportador
	oStruct:SetProperty("GU3_PFTPSE", 	MVC_VIEW_ORDEM, '58')

	//Pasta Fiscal.
	oStruct:SetProperty("GU3_ESEXIC", 	MVC_VIEW_ORDEM, '27')

	oView := FWFormView():New()
	oView:SetModel(oModel)
	// cFormModelID - Representa o ID criado no Model que essa FormField irá representar
	// oStruct - Objeto do model a se associar a view.
	// cLinkID - Representa o ID criado no Model ,Só é necessári o caso estamos mundando o ID no View.
	oView:AddField( "GFEA015_GU3" , oStruct, /*cLinkID*/ )	//
	oStructGU2:RemoveField("GU2_CDEMIT")
	oView:AddGrid( "GFEA015_GU2" , oStructGU2 )
	// cID		  	Id do BFWFormStruct(2,"GU3") utilizado
	// nPercHeight  Valor da Altura do box( caso o lFixPixel seja .T. é a qtd de pixel exato)
	// cIdOwner 	Id do Box Vertical pai. Podemos fazer diversas criações uma dentro da outra.
	// lFixPixel	Determina que o valor passado no nPercHeight é na verdade a qtd de pixel a ser usada.
	// cIDFolder	Id da folder onde queremos criar o o box se passado esse valor, é necessário informar o cIDSheet
	// cIDSheet     Id da Sheet(Folha de dados) onde queremos criar o o box.
	oView:CreateHorizontalBox( "MASTER" , 65,/*cIDOwner*/,/*lFixPixel*/,/*cIDFolder*/,/*cIDSheet*/ )
	oView:CreateHorizontalBox( "DETAIL" , 35 )
	
	oView:CreateFolder("IDFOLDER","DETAIL")
	oView:AddSheet("IDFOLDER","IDSHEET01",STR0008) //"Contatos"
	
	oView:CreateHorizontalBox( "DETAILCONT" , 100,,,"IDFOLDER","IDSHEET01" )
	// Associa um View a um box
	oView:SetOwnerView( "GFEA015_GU3" , "MASTER" )
	oView:SetOwnerView( "GFEA015_GU2" , "DETAILCONT" )
	
	oView:AddIncrementField('GFEA015_GU2','GU2_SEQ')

Return oView                         

//-------------------------------------------------------------------
/*/{Protheus.doc} GFEA015VAL
Rotina para realizar as validacoes.
Uso Geral.

@param 	oModel	    Recebi o oMOdel principal

@author Luiz Fernando Soares
@since 20/11/09
@version 1.0
/*/
//-------------------------------------------------------------------
Function GFEA015VAL(oModel)
	Local nI, nX, nZ
	Local aAreaGU3
	Local nContCod    := 0
	Local cCdEmitCod  := ""
	Local lRet        := .T.
	Local nOpc        := (oModel:GetOperation())
	Local nOp         := oModel:GetOperation()
	Local cEstados    := FwFldGet("GU3_ESEXIC")
	Local aEstados    := StrTokArr(cEstados, ";")
	Local cValidNRCID := AllTrim(FwFldGet("GU3_NRCID"))

	If nOp == MODEL_OPERATION_UPDATE
		DbSelectArea("GU3")
		GU3->( dbSetOrder(1) )
		If GU3->( dbSeek(xFilial("GU3") + FwFldGet("GU3_CDEMIT")) )
			aAreaGU3 := GU3->(GetArea())
		EndIf
	EndIf

	If nOpc == MODEL_OPERATION_INSERT .Or. nOpc == MODEL_OPERATION_UPDATE

		For nI := 1 to Len( aEstados )
			If !Empty(aEstados[nI])
				dbSelectArea("SX5")
				dbSetOrder(1)
				If !msseek(xFilial("SX5")+"12"+aEstados[nI])
					Help( ,, 'HELP', '', 'O valor ' + aEstados[nI] + ' não corresponde a uma UF válida.', 1, 0)
					Return .F.
				EndIf
			EndIf
		next nI
		
		For nX := 1 to Len( aEstados )
			If !Empty(aEstados[nX])
				For nZ := nX + 1 to Len( aEstados )
					If Alltrim(aEstados[nX]) == Alltrim(aEstados[nZ])
						Help( ,, 'HELP', '', 'A UF ' + aEstados[nX] + ' já existe na lista. ', 1, 0)
						Return .F.
					EndIf
				next nZ
			EndIf
		next nX
		
		If cValidNRCID != "0"
			cValidNRCID := RIGHT(AllTrim(FwFldGet("GU3_NRCID")),len(AllTrim(FwFldGet("GU3_NRCID"))) - 2)
		EndIf
		
		// Integração - Atribui o código da cidade, quando não for informado, pelo nome e uf da cidade
		If cValidNRCID == "0" .Or. Empty(cValidNRCID)
			dbSelectArea("GU7")
			dbSetOrder(3)
			dbGoTop()
			
			If dbSeek(XFILIAL("GU7")+PADR(UPPER(FwFldGet("GU3_NMCID")),50, " "))             
				oModel:LoadValue( 'GFEA015_GU3', 'GU3_NRCID', GU7->GU7_NRCID)
				oModel:LoadValue( 'GFEA015_GU3', 'GU3_NMCID', GU7->GU7_NMCID)
				oModel:LoadValue( 'GFEA015_GU3', 'GU3_UF', GU7->GU7_CDUF)
			Else
				oModel:LoadValue( 'GFEA015_GU3', 'GU3_NRCID', "0")
				oModel:LoadValue( 'GFEA015_GU3', 'GU3_NMCID', "")
				oModel:LoadValue( 'GFEA015_GU3', 'GU3_UF', "")
			EndIf
		EndIf
		// FIM - Integração
		
		// Validação para integração, garante que o CEP não tenha espaços
		oModel:LoadValue( 'GFEA015_GU3', 'GU3_CEP' , ALLTRIM(FwFldGet("GU3_CEP")))
		
		If nOpc == MODEL_OPERATION_INSERT
			If AllTrim(FwFldGet("GU3_NRCID")) == "0".OR.Empty(FWFldGet( 'GU3_NRCID' ))
				Help( ,, 'HELP',, STR0025, 1, 0,) //"Cidade deve ser informada"
				lRet := .F.
			Endif
		Endif       	
		
		//Não é permitido um emitente Transportador e pessoa fisica ou autonomo e pessoa juridica ou Autonomo e Transportador 
		If lRet .And. FwFldGet("GU3_TRANSP") == '1' .And. FwFldGet("GU3_AUTON") == '1'
			Help(,,'HELP',,STR0010,1,0)  //"Não é possível criar um emitente Transportador e Autônomo, apenas uma opção deve ser escolhida"
			lRet := .F.
		EndIf
		
		//Não é permitido um emitente Transportador pessoa Fisica
		If lRet .And. FwFldGet("GU3_TRANSP") == '1' .And. FwFldGet("GU3_NATUR") == 'F'
			Help(,,'HELP',,STR0012,1,0)  //"O emitente Transportador deve ser Pessoa Jurídica"
			lRet := .F.
		EndIf
		
		If lRet .And. FwFldGet("GU3_NATUR") == "F"
			oModel:LoadValue( 'GFEA015_GU3', 'GU3_TRANSP', "2")
		EndIf
		
		// Quando a origem do cadastro é ERP, a regra que prevalece é a preenchida no ERP
		If lRet .And. FwFldGet("GU3_ORIGEM") != '2' .And. (FwFldGet("GU3_NATUR") == "J" .OR. FwFldGet("GU3_NATUR") == "F") 
			If Empty(FwFldGet("GU3_IDFED"))
				Help( ,, 'Help',, STR0031, 1, 0 ) //"Informe CNPJ ou CPF."
				lRet := .F.
			EndIf
		EndIf

		If lRet
			If FwFldGet("GU3_AUTON") == "1"
				If FwFldGet("GU3_INSS") == " "
					PutHelp("PFRM010A",{STR0013},{STR0013},{STR0013}) //"Emitente Autônomo"###"Emitente Autônomo"###"Emitente Autônomo"
					PutHelp("SFRM010A",{STR0014},{STR0014},{STR0014}) //"Informar número de inscrição no INSS"###"Informar número de inscrição no INSS"###"Informar número de inscrição no INSS"
					HELP(" ",1,"FRM010A","FRM010A" )
					lRet := .F.
				Else
					If FwFldGet("GU3_ANTT") == " "
						PutHelp("PFRM010B",{STR0013},{STR0013},{STR0013}) //"Emitente Autônomo"###"Emitente Autônomo"###"Emitente Autônomo"
						PutHelp("SFRM010B",{STR0015},{STR0015},{STR0015}) //"Informar número de inscrição no ANTT"###"Informar número de inscrição no ANTT"###"Informar número de inscrição no ANTT"
						HELP(" ",1,"FRM010B","FRM010B" )
						lRet := .F.
					EndIf
				EndIf
			EndIf

			If !Empty(FwFldGet("GU3_CDGREM"))
				dbSelectArea("GU1")
				dbSetOrder(1)

				If GU1->( dbSeek( xFilial( 'GU1' ) + FwFldGet( 'GU3_CDGREM' ) ) ) .AND. GU1->GU1_SIT == "2"
					Help( ,, 'Help',, STR0032, 1, 0 ) //"Grupo com a situação Inativa"
					lRet := .F.
				EndIf		
			EndIf
			
			If !Empty(FwFldGet("GU3_NRCID"))
				dbSelectArea("GU7")
				dbSetOrder(1)
				
				If GU7->( dbSeek( xFilial( 'GU7' ) + FwFldGet( 'GU3_NRCID' ) ) ) .AND. GU7->GU7_SIT == "2"
					Help( ,, 'Help',, STR0033, 1, 0 ) //"Cidade com a situação Inativa"
					lRet := .F.
				EndIf		
			EndIf
			
			If !Empty(FwFldGet("GU3_CDEMFT")) .And. FwFldGet("GU3_CDEMFT") != FwFldGet("GU3_CDEMIT")
				
				dbSelectArea("GU3")
				dbSetOrder(1)			
				If GU3->( dbSeek(xFilial('GU3') + FwFldGet('GU3_CDEMFT')) )
				
					If GU3->GU3_SIT == "2"
						Help( ,, 'Help',, STR0034, 1, 0 ) //"Transportador de faturamento com a situação Inativa"
						lRet := .F.
					EndIf
					If  GU3->GU3_TRANSP == "2"
						Help( ,, 'Help',, STR0035, 1, 0 ) //"Transportador de faturamento não é um transportador"
						lRet := .F.
					EndIf
				Else
					Help( ,, 'Help',, STR0039, 1, 0 ) //"O campo do transportador de faturamento deve estar em branco, ou ser o mesmo que o emitente ou outro já cadastrado."
					lRet := .F.
				EndIf		
			EndIf	
		EndIf
		
		If FwFldGet("GU3_TPFREQ") == "1"
			If FwFldGet("GU3_DBAS1") == 0 .AND. FwFldGet("GU3_DBAS2") == 0 .AND. FwFldGet("GU3_DBAS3") == 0 .AND. FwFldGet("GU3_DBAS4") == 0 .AND. FwFldGet("GU3_DBAS5") == 0
				Help( ,, 'Help',, STR0036, 1, 0 ) //"Pelo menos um Dia Base deve ser Informado"
				lRet := .F.		
			EndIf	
		EndIf
		
		If FwFldGet("GU3_TPFREQ") == "2"
			If FwFldGet("GU3_SEGUN") == "2" .AND. FwFldGet("GU3_TERCA") == "2" .AND. FwFldGet("GU3_QUARTA") == "2" .AND. FwFldGet("GU3_QUINTA") == "2" .AND. FwFldGet("GU3_SEXTA") == "2"
				Help( ,, 'Help',, STR0037, 1, 0 ) //"Pelo menos um Dia da Semana deve ser Informado como 'Sim'"
				lRet := .F.		
			EndIf	
		EndIf 
		
		//Validação para permitir apenas que exista uma pessoa juridica filial
		If lRet .And. FwFldGet("GU3_ORIGEM") != "2" .And. FwFldGet("GU3_NATUR") != 'J' .And. FwFldGet("GU3_EMFIL") == '1' 
			Help( ,, 'Help',, STR0038, 1, 0 ) //"Só é possivel incluir um emitente Filial com natureza Jurídica."
			lRet := .F.			
		EndIf
		
		If lRet
		
			If nOp == MODEL_OPERATION_INSERT .And. FwFldGet("GU3_ORIGEM") == "2" ;
				.And. SuperGetMv("MV_EMITMP",.F.,"1") == "1" .And. SuperGetMv("MV_ERPGFE") == "2"

				cCdEmitCod := GETSXENUM('GU3','GU3_CDEMIT')
				ConfirmSX8()
				nContCod   := Len(Alltrim(cCdEmitCod)) - 8
				If nContCod > 0
					cCdEmitCod := SubStr(cCdEmitCod,nContCod,TamSx3("GU3_CDEMIT")[1])
				Else
					cCdEmitCod := StrZero(Val(Alltrim(cCdEmitCod)), 9) 
				EndIf
				nContCod   := 0
					
				dbSelectArea("GU3")
				GU3->( dbSetOrder(1) )
				While GU3->( dbSeek( xFilial("GU3") + cCdEmitCod ) )
					cCdEmitCod := GETSXENUM('GU3','GU3_CDEMIT')
					ConfirmSX8()
					nContCod   := Len(Alltrim(cCdEmitCod)) - 8
					If nContCod > 0
						cCdEmitCod := SubStr(cCdEmitCod,nContCod,TamSx3("GU3_CDEMIT")[1])
					Else
						cCdEmitCod := StrZero(Val(Alltrim(cCdEmitCod)), 9) 
					EndIf
					nContCod   := 0
					
					GU3->( dbSkip() )
				EndDo
				
				oModel:LoadValue("GFEA015_GU3", "GU3_CDEMIT", cCdEmitCod )
			EndIf
			
			If FwFldGet("GU3_TRANSP") == "2"
				oModel:LoadValue("GFEA015_GU3", "GU3_CDEMFT",CriaVar('GU3_CDEMFT',.F.))
				oModel:LoadValue("GFEA015_GU3", "GU3_NMEMFT",CriaVar('GU3_NMEMFT',.F.))
				oModel:LoadValue("GFEA015_GU3", "GU3_MAXDOC",CriaVar('GU3_MAXDOC',.F.))
				oModel:LoadValue("GFEA015_GU3", "GU3_AGRDOC","2")
				oModel:LoadValue("GFEA015_GU3", "GU3_ACOCO" ,"1")
				oModel:LoadValue("GFEA015_GU3", "GU3_PFFIL" ,"2")
				oModel:LoadValue("GFEA015_GU3", "GU3_PFUF"  ,"2")
				oModel:LoadValue("GFEA015_GU3", "GU3_PFCLAS","2")
				oModel:LoadValue("GFEA015_GU3", "GU3_PFTPFR","2")
				oModel:LoadValue("GFEA015_GU3", "GU3_PFTPSE","2")
				
				oModel:LoadValue("GFEA015_GU3", "GU3_PFNORM" ,1  )
				oModel:LoadValue("GFEA015_GU3", "GU3_PFCPVL" ,1  )
				oModel:LoadValue("GFEA015_GU3", "GU3_PFCPIC" ,1  )
				oModel:LoadValue("GFEA015_GU3", "GU3_PFDEV"  ,1  )
				oModel:LoadValue("GFEA015_GU3", "GU3_PFREDE" ,1  )
				oModel:LoadValue("GFEA015_GU3", "GU3_PFREEN" ,1  )
				oModel:LoadValue("GFEA015_GU3", "GU3_PFSERV" ,1  )
				oModel:LoadValue("GFEA015_GU3", "GU3_CALCVC" ,"2")
				oModel:LoadValue("GFEA015_GU3", "GU3_PRAZO"  ,0  )
				oModel:LoadValue("GFEA015_GU3", "GU3_ACAOVC" ,"2")
				oModel:LoadValue("GFEA015_GU3", "GU3_TPFREQ" ,"0")
				oModel:LoadValue("GFEA015_GU3", "GU3_DBAS1"  ,0  )
				oModel:LoadValue("GFEA015_GU3", "GU3_DBAS2"  ,0  )
				oModel:LoadValue("GFEA015_GU3", "GU3_DBAS3"  ,0  )
				
				oModel:LoadValue("GFEA015_GU3", "GU3_DBAS4"  ,0  )
				oModel:LoadValue("GFEA015_GU3", "GU3_DBAS5"  ,0  )
				oModel:LoadValue("GFEA015_GU3", "GU3_SEGUN"  ,"2")
				oModel:LoadValue("GFEA015_GU3", "GU3_TERCA"  ,"2")
				oModel:LoadValue("GFEA015_GU3", "GU3_QUARTA" ,"2")
				oModel:LoadValue("GFEA015_GU3", "GU3_QUINTA" ,"2")
				oModel:LoadValue("GFEA015_GU3", "GU3_SEXTA"  ,"2")
				oModel:LoadValue("GFEA015_GU3", "GU3_CTE"    ,"2")
				
				If FwFldGet("GU3_AUTON") == "2"
					oModel:LoadValue("GFEA015_GU3", "GU3_CATTRP", "8")
					oModel:LoadValue("GFEA015_GU3", "GU3_MODAL" , "1")
				EndIf
			EndIf
			
			If FwFldGet("GU3_AUTON") == "2"
				oModel:LoadValue("GFEA015_GU3", "GU3_MVTERC", "2")
				oModel:LoadValue("GFEA015_GU3", "GU3_INSS"  , " ")
				oModel:LoadValue("GFEA015_GU3", "GU3_NRDEP" , 0  )
			
				If FwFldGet("GU3_TRANSP") == "2"
					oModel:LoadValue("GFEA015_GU3", "GU3_CATTRP", "8")
					oModel:LoadValue("GFEA015_GU3", "GU3_MODAL" , "1")
				EndIf
			EndIf
		EndIf
	Endif

	If nOp == MODEL_OPERATION_UPDATE
		If ValType(aAreaGU3) <> "U"
			RestArea(aAreaGU3)
		EndIf
	EndIf

Return (lRet)

//-------------------------------------------------------------------
/*/{Protheus.doc} GFEA015VL
Rotina para realizar as validacoes no momento da exclusao.
Uso Geral.

@param 	oModel	    Recebi o oModel principal

@author Luiz Fernando Soares
@since 20/11/09
@version 1.0
/*/
//-------------------------------------------------------------------
Function GFEA015VL(oModel)  
	Local lRet := .T.
	Local nOpc := oModel:GetOperation()

   	If nOpc == 3
   		lWhenFil := .T.
   	ElseIf nOpc == 4
   		lWhenFil := GU3->GU3_EMFIL == "2"  	
   	EndIf

	If nOpc == MODEL_OPERATION_DELETE

		// Verificação para integridade do emitente nas seguintes tabelas: gw1, gwu, gw3, gw6, gva
		nTotal := TotalRecords("GW1", { {"GW1_EMISDC","'"+GU3->GU3_CDEMIT+"'",,"OR"},;
										{"GW1_CDREM","'"+GU3->GU3_CDEMIT+"'",,"OR"},;
										{"GW1_CDDEST","'"+GU3->GU3_CDEMIT+"'"} })
		
		If nTotal > 0
			Help( ,, 'HELP',,"O Emitente já está relacionado a um documento de carga e não pode ser excluído.", 1, 0)
			lRet := .F.
		EndIf
		
		If lRet
			nTotal := TotalRecords("GWU", { {"GWU_CDTRP","'"+GU3->GU3_CDEMIT+"'"} })
			
			If nTotal > 0
				Help( ,, 'HELP',,"O Emitente já está relacionado a um documento de carga e não pode ser excluído.", 1, 0)
				lRet := .F.
			EndIf
		EndIf
		
		If lRet
			nTotal := TotalRecords("GVA", { {"GVA_CDEMIT","'"+GU3->GU3_CDEMIT+"'"} })
			
			If nTotal > 0
				Help( ,, 'HELP',,"O Emitente já está relacionado a uma tabela de frete e não pode ser excluído.", 1, 0)
				lRet := .F.
			EndIf
		EndIf
		
		If lRet
			nTotal := TotalRecords("GW3", { {"GW3_EMISDF","'"+GU3->GU3_CDEMIT+"'"} })
			
			If nTotal > 0
				Help( ,, 'HELP',,"O Emitente já está relacionado a um documento de frete e não pode ser excluído.", 1, 0)
				lRet := .F.
			EndIf
		EndIf
		
		If lRet
			nTotal := TotalRecords("GW6", { {"GW6_EMIFAT","'"+GU3->GU3_CDEMIT+"'"} })
			
			If nTotal > 0
				Help( ,, 'HELP',,"O Emitente já está relacionado a uma fatura de frete e não pode ser excluído.", 1, 0)
				lRet := .F.
			EndIf
		EndIf
		
		If lRet
			nTotal := TotalRecords("GX3", { {"GX3_CDEMIT","'"+GU3->GU3_CDEMIT+"'"} })
			
			If nTotal > 0
				Help( ,, 'HELP',,"O Emitente já está relacionado a uma movimentação de pátio e não pode ser excluído.", 1, 0)
				lRet := .F.
			EndIf
		EndIf
		
		dbSelectArea("GW2")
		GW2->( dbSetOrder(2) )
		GW2->( dbSeek(xFilial("GW2") + GU3->GU3_CDEMIT) )
		If !GW2->( Eof() )
			Help( ,, 'HELP',,STR0026, 1, 0) //"O emitente está relacionado a um contrato com autônomo, portanto, não poderá ser excluído."
			lRet := .F.
		EndIf
	EndIf	
	
Return lRet

/*/{Protheus.doc} TotalRecords
@author alan.victor
@since 22/05/2014
@version 1.0
@param 	cTabela	Tabela do dicionário para ser realizada a consulta
@param 	aWhere	array com filtro

@example
nTotal := TotalRecords("GW1", {{"GW1_DTEMIS", "20120101"}, {"GW1_CDREM", "00001"}})
nTotal := TotalRecords("GW1", {{"GW1_DTEMIS", DTOS(DDATABASE), "<="}})
/*/
Static Function TotalRecords(cTabela, aWhere)
	Local nTotal 	:= 0
	Local cQuery 	:= ""
	Local cTmp 		:= ""
	Local nCount	:= 0
	Local lOu		:= .F.
	Local cOpLogAtu
	Local cOpLogAnt

	Default aWhere	:= {}
	
	cQuery := "SELECT COUNT(*) TOTAL "
	cQuery += "  FROM " + RetSQLName(cTabela)
	cQuery += " WHERE D_E_L_E_T_ = '' " 
	
	For nCount := 1 To Len(aWhere)
		lOu := .F.
		
		cOpLogAtu := "AND"  // Operador lógico atual
		cOpLogAnt := "AND"	// Operador lógico anterior
		
		/* Verifica operador utilizado na condição anterior */
		If nCount > 1 
			If Len(aWhere[nCount-1]) > 3 .And. !Empty(aWhere[nCount-1][4])
				cOpLogAnt := AllTrim(aWhere[nCount-1][4])
			Else 
				cOpLogAnt := "AND"
			EndIf
		EndIf
		/*----------------------------------------------*/
		
		/* Verifica operador utilizado na condição atual */
		If Len(aWhere[nCount]) > 3 .And. !Empty(aWhere[nCount][4])
			cOpLogAtu := AllTrim(aWhere[nCount][4])
		EndIf
		/*----------------------------------------------*/
		
		If cOpLogAnt == "AND" .And. cOpLogAtu == "AND"
			cQuery += " AND "
		ElseIf cOpLogAnt == "AND" .And. cOpLogAtu == "OR"
			cQuery += " AND ( "
		ElseIf cOpLogAnt == "OR" .And. cOpLogAtu == "OR"
			cQuery += " OR "
		ElseIf cOpLogAnt == "OR" .And. cOpLogAtu == "AND"
			cQuery += " OR "
		EndIf
		
		/* Campo+CONDIÇÃO+Valor */
		cQuery += aWhere[nCount][1]
		
		If Len(aWhere[nCount]) > 2 .And. !Empty(aWhere[nCount][3])
			cQuery += aWhere[nCount][3]
		Else
			cQuery += "="
		EndIf
		
		cQuery += aWhere[nCount][2]		
		/*----------------------------------------------*/
		
		If cOpLogAnt == "OR" .And. cOpLogAtu == "AND"
			cQuery += " ) "
		EndIf
	Next nCount
	
	cTmp := GetNextAlias()
	cQuery := ChangeQuery(cQuery)
	dbUseArea(.T., "TOPCONN", TCGENQRY(,,cQuery), cTmp, .F., .T.)
	dbSelectArea(cTmp)
	(cTmp)->(dbGoTop())
	
	If (cTmp)->(Recno()) > 0
		nTotal := (cTmp)->TOTAL
	EndIf
	  
	(cTmp)->(dbCloseArea())
Return nTotal

//-------------------------------------------------------------------
/*/{Protheus.doc} GFEA015VERFIL
Rotina para realizar o carregamento da variavel lWhenFil
Uso Geral.

@author Luiz Fernando Soares
@since 21/11/09
@version 1.0
/*/
//-------------------------------------------------------------------
Function GFE15VERF()
	//------Funcao chamada pelo banco de dados para buscar o valor da variavel lWhenFil -----//
	//------que verifica se a filial esta == 2 											-----//
	lWhenFil := M->GU3_EMFIL == "2"
return (.T.)
  
//-------------------------------------------------------------------
/*/{Protheus.doc} GFEA015CTT
Rotina para realizar Validações no dicionario de GU2
Uso Geral.

@author Felipe Rafael Mendes
@since 07/04/10
@version 1.0
/*/
//-------------------------------------------------------------------
Function GFEA015CTT()
	Local nLine
	Local oModel
	Local oModelPai
	Local lRet      := .T.  
	Local cCampo    := ReadVar()     

	If IsInCallStack("GFEA015")
		oModelPai := FWMODELACTIVE()
		oModel := oModelPai:GetModel("GFEA015_GU2") 
		nLine := oModel:GetLine()

		//Validação do campo nome do contato
		If "GU2_NOME" $ cCampo .And. Empty(FwFldGet("GU2_NOME",nLine))
			Help( ,, 'Help',, STR0020, 1, 0 )  //"É necessário informar o nome do contato."
			lRet := .F. 
		EndIf

		//Validação no campo de e-mail para que não se cadastre um contato com email em branco ou invalido
		If "GU2_EMAIL" $ cCampo 
			If Empty(FwFldGet("GU2_EMAIL",nLine))
				Help( ,, 'Help',, STR0021, 1, 0 )  //"É necessário informar um e-mail."
				lRet := .F. 
			ElseIf !('@' $ FwFldGet("GU2_EMAIL",nLine)) .Or. !( '.' $ FwFldGet("GU2_EMAIL",nLine))  
				Help( ,, 'Help',, STR0022, 1, 0 )  //"O e-mail informado não é válido, favor informar um e-mail válido. Exemplo: abc@xyz.com"
				lRet := .F.
			EndIf
		EndIf

		//Validação no campo de telefone
		If ("GU2_FONE1" $ cCampo .Or. "GU2_FONE2" $ cCampo) .And. Empty(FwFldGet("GU2_FONE1",nLine)) .And. Empty(FwFldGet("GU2_FONE2",nLine))
			Help( ,, 'Help',, STR0023, 1, 0 )  //"É necessário informar um telefone de contato"
			lRet := .F.
		EndIf
	EndIf
Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} GFE015AUT
Rotina para realizar Validações de habilitação do campo GU3_TRANSP, GU3_AUTON
Uso Geral.

@author Felipe Rafael Mendes
@since 07/04/10
@version 1.0
/*/
//------------------------------------------------------------------- 
Function GFE015AUT()
	Local lRet := .T.
	Local cCampo := ReadVar()

	If "GU3_TRANSP" $ cCampo .Or. "GU3_AUTON" $ cCampo 
		//desabilitar os campos Transp? e Autônomo? da pasta Geral na inclusão de emitentes FORNECEDOR Natureza Outros com cidade estrangeira.
		If M->GU3_NATUR == 'X' 
			dbSelectArea('GU7')
			dbSetOrder(01)
			If dbSeek(xFilial('GU7')+M->GU3_NRCID)
				If GU7->GU7_CDPAIS != '105'
					lRet := .F.
				EndIf
			EndIf
		EndIf 
	EndIf

	// O campo Transp somente deve ficar desabilitado para alteração quando seu valor for Sim. Qdo for Não, poderão ser alterados.
	If "GU3_TRANSP" $ cCampo .AND. GU3->GU3_TRANSP == "1" 
		dbSelectArea("GVA")
		dbSetOrder(1)
		If dbSeek(xFilial("GVA")+FwFldGet("GU3_CDEMIT"))
			lRet := .F.
		EndIf
	EndIf   

	// Os campos Autonomo somente deve ficar desabilitado para alteração quando seu valor for Sim e houver uma tabela com seu codigo. Qdo for Não, poderão ser alterados.
	If "GU3_AUTON" $ cCampo .AND. GU3->GU3_AUTON  == "1"
		dbSelectArea("GVA")
		dbSetOrder(1)
		If dbSeek(xFilial("GVA")+FwFldGet("GU3_CDEMIT"))
			lRet := .F.
		EndIf
	EndIf
Return lRet 

//-------------------------------------------------------------------
/*/{Protheus.doc} GFE015AU
Rotina para zerar os valores dos campos GU3_TRANSP e GU3_AUTON quando forem desabilitados
Uso Geral.

@author Felipe Rafael Mendes
@since 17/04/10
@version 1.0
/*/
//-------------------------------------------------------------------   
Function GFE015AU()  
	Local oModel := FWMODELACTIVE()
	
	If FwFldGet("GU3_NATUR") == 'X' .And. GETADVFVAL("GU7","GU7_CDPAIS","xFilial('GU7')+FwFldGet('GU3_NRCID')",1,"") != '105' 
		oModel:LoadValue("GFEA015_GU3","GU3_TRANSP","2")
		oModel:LoadValue("GFEA015_GU3","GU3_AUTON","2")
	EndIf

Return .T. 

//-------------------------------------------------------------------
/*/{Protheus.doc} GFE015TR
Devido a uma limitação do framework que não consegue desabilitar a aba transportador, esta
Rotina foi criada para colocar o valor padrão em todos os campos da aba transportador quando o mesmo for "Não".
Segue a lista dos campos: 
GU3_CDEMFT, GU3_NMEMFT, GU3_MAXDOC, GU3_AGRDOC, GU3_ACOCO, GU3_PFFIL, GU3_PFUF, GU3_PFCLAS, 
GU3_PFTPFR, GU3_PFNORM, GU3_PFCPVL , GU3_PFCPIC, 
GU3_PFDEV, GU3_PFREDE, GU3_PFREEN, GU3_PFSERV, GU3_ENTOBR, 
GU3_CALCVC, GU3_PRAZO, GU3_ACAOVC, GU3_TPFREQ, GU3_DBAS1, GU3_DBAS2, GU3_DBAS3, 
GU3_DBAS4, GU3_DBAS5, GU3_SEGUN, GU3_TERCA, GU3_QUARTA, GU3_QUINTA, GU3_SEXTA, GU3_ICMPRE, GU3_SBTRIB, GU3_CTE, 

Uso Geral.

@author Felipe Rafael Mendes
@since 17/05/10
@version 1.0
/*/
//-------------------------------------------------------------------   
Function GFE015TR()  
	Local oModel    := FWLoadModel("GFEA015")
	Local oModelGU3 
	
	oModel:SetOperation( 1 )
	oModel:Activate()
 	oModelGU3 := oModel:GetModel("GFEA015_GU3")
 
 	If FwFldGet("GU3_TRANSP") == "1"
  		If FwFldGet("GU3_AUTON") == "2"
   			oModelGU3:LoadValue("GU3_CATTRP", "1")
   			oModelGU3:LoadValue("GU3_MODAL" , "2")
  		EndIf
 	EndIf
 	oModel:Deactivate()

Return .T.

//-------------------------------------------------------------------
/*/{Protheus.doc} GFE015ATN
Rotina para zerar os valores dos campos da aba Autonomo quando forem desabilitados
Uso Geral.

@author Felipe Rafael Mendes
@since 17/04/10
@version 1.0
/*/
//-------------------------------------------------------------------   

Function GFE015ATN()  
	Local oModel    := FWLoadModel("GFEA015")
	Local oModelGU3 
	
	oModel:SetOperation( 1 )
	oModel:Activate()
 	oModelGU3 := oModel:GetModel("GFEA015_GU3")
 
	If FwFldGet("GU3_AUTON") == "1"
		oModelGU3:LoadValue("GU3_CATTRP", "2")
		oModelGU3:LoadValue("GU3_MODAL" , "2")
	EndIf
	
	oModel:Deactivate()

Return .T.

//-------------------------------------------------------------------

Function GFEA15ACT(oModel)
	Local nOp := oModel:GetOperation()
	
	If nOp == MODEL_OPERATION_INSERT //Cópia também é reconhecida como inserção
		
		oModel:SetValue("GFEA015_GU3", "GU3_DTIMPL", DDATABASE)
		
	EndIf
Return

//-------------------------------------------------------------------

Function GFEA015ANT()
	
	If (M->GU3_AUTON == "1" .Or. M->GU3_TRANSP == "1") .And. M->GU3_MODAL $ "1;2;7"
		Return .T.
	EndIf
	
Return .F.


//-------------------------------------------------------------------
/*/{Protheus.doc} GFE015WPFG
Rotina do When dos campos dos grupos de agrupamento por Tipo de Frete
Efeito nos campos:
	GU3_PFNORM
	GU3_PFCPVL
	GU3_PFCPIC
	GU3_PFDEV
	GU3_PFREDE
	GU3_PFREEN
	GU3_PFSERV
Uso Geral.

@author Israel A. Possoli
@since 26/11/2012
@version 1.0
/*/
//-------------------------------------------------------------------
Function GFE015WPFG()
	// Se não for transportador, deixa desabilitado
	If (M->GU3_TRANSP == "2")
		Return .F.
	EndIf
	
	// Desabilita o campo se o tipo de agrupamento for por cálculo
	If (M->GU3_PFCALC == "1")
		Return .F.
	EndIf
	
	// Desabilita o campo se o tipo de Frete não estiver parametrizado
	If (M->GU3_PFTPFR == "2")
		Return .F.
	EndIf
	
Return .T.

Function GetGu3Num()
	Local cCdEmitCod := ""
	//Local nTam := TamSx3("GU3_CDEMIT")[1]
	
	cCdEmitCod := GETSXENUM('GU3','GU3_CDEMIT')
	ConfirmSX8()
	nContCod   := Len(Alltrim(cCdEmitCod)) - 8
	If nContCod > 0
		cCdEmitCod := SubStr(cCdEmitCod,nContCod,TamSx3("GU3_CDEMIT")[1])
	Else
		cCdEmitCod := StrZero(Val(Alltrim(cCdEmitCod)), 9) 
	EndIf
	nContCod   := 0
	
	dbSelectArea("GU3")
	GU3->( dbSetOrder(1) )
	While GU3->( dbSeek( xFilial("GU3") + cCdEmitCod ) )
		cCdEmitCod := GETSXENUM('GU3','GU3_CDEMIT')
		ConfirmSX8()
		nContCod   := Len(Alltrim(cCdEmitCod)) - 8
		If nContCod > 0
			cCdEmitCod := SubStr(cCdEmitCod,nContCod,TamSx3("GU3_CDEMIT")[1])
		Else
			cCdEmitCod := StrZero(Val(Alltrim(cCdEmitCod)), 9) 
		EndIf
		nContCod   := 0
		
		GU3->( dbSkip() )
	EndDo
Return cCdEmitCod

//-------------------------------------------------------------------
/*/{Protheus.doc} GFE015ISS
Rotina do When do campo do grupo de fiscal para habilitar e desabilitar o campo
Efeito nos campos:
	GU3_PCISS 
Uso Geral.

@author Ana Claudia da Silva
@since 25/11/2014
@version 1.0
/*/
//-------------------------------------------------------------------
Function GFE015ISS()
	//Só perfmitir informar uma aliquota de ISS no cadastro de Emitente, 
	//quando este estiver parametrizado como regime tributário = "Simplificado" E Contribuinte ISS = sim
	If (M->GU3_TPTRIB == "2") .AND. (M->GU3_CONISS == "1") 
		Return .T.
	EndIf

Return .F.

//-------------------------------------------------------------------

/*/{Protheus.doc} GFEA015FIL
Permite o cadastro de filiais quando o ERP integrado for o Protheus

@author Amanda Rosa Vieira
@since 18/02/2015
@version 1.0
/*/
//-------------------------------------------------------------------

Function GFEA015FIL() 
	Local oDlg
	Local nOpc    := 1
	Local bOk     := {|| If(!Empty(ArmazPos), oDlg:End(),) }
	Local bCancel := {|| nOpc := 0, oDlg:End() }
	Local cTitulo := "Selecionar Filial"
	Local nI
	Local oModel := FWLoadModel('GFEA015')
	Local oView := FWLoadView('GFEA015')
	Local oOK := LoadBitmap(GetResources(),'NGRADIOOK.PNG')
	Local oNO := LoadBitmap(GetResources(),'NGRADIONO.PNG')  
	Local oFWMVCWindow, aCoors
	
	//Local cNrCid
	Local aAreaGU3 := GU3->(GetArea())
	//Local oModAtv := FwModelActive()
	Private ArmazPos  //Armazena posição da linha clicada
	Private aBrowse := {} //aBrowse -> {Marcação,Filial,Status(Já cadastrado ou não), Cód. Filial, Código}  Armazena informações do filial clicada
	
	dbSelectArea("SM0") 
	SM0->(dbGoTop())
	dbSelectArea("GU3") // Emitentes
	GU3->(dbSetOrder(11)) // Filial + CPNJ
	
	If MsgYesNo( "As filiais do sistema devem ser cadastradas como clientes e/ou fornecedores no ERP." + CRLF + CRLF + "Esta ação deve ser usada somente se o processo da empresa não permitir este cadastro para alguma situação específica" + CRLF + CRLF + "Deseja continuar?","Frete Embarcador - Cadastro de Filial")
		
   		DEFINE DIALOG oDlg TITLE cTitulo FROM 180,180 TO 550,700 PIXEL

		oBrowse := TWBrowse():New( 01 , 01, 260,184,,{'','Filial',''},{60,60},;  //Colunas da tabela                           
		oDlg,,,,,{||},,,,,,,.F.,,.T.,,.F.,,, )    
		oBrowse:Align := CONTROL_ALIGN_ALLCLIENT 
		
		While !SM0->(Eof())
			nI := aScan(aBrowse,{|x| x[4] == SM0->M0_CODFIL })
			If nI == 0
				If GU3->(dbSeek (xFilial("GU3")+SM0->M0_CGC))  // Verifica se a filial já foi cadastrada
					aAdd(aBrowse,{.F., "" + SM0->M0_CODFIL + "-" + SM0->M0_FILIAL ,"Filial Já Cadastrada",SM0->M0_CODFIL,SM0->M0_CODIGO})  	
				Else
					aAdd(aBrowse,{.F., "" + SM0->M0_CODFIL + "-" + SM0->M0_FILIAL ,"  ",SM0->M0_CODFIL,SM0->M0_CODIGO})
				EndIf
			EndIf	 
			SM0->(DbSkip()) 
		EndDo
	
		oBrowse:SetArray(aBrowse)    
		oBrowse:bLine := {||{If(aBrowse[oBrowse:nAt,01],oOK,oNO), aBrowse[oBrowse:nAt,02],aBrowse[oBrowse:nAt,03] } }    
		// Troca a imagem no duplo click do mouse 
		oBrowse:bLDblClick := {|| ArmazPos := oBrowse:nAt, MarcaBrowse(ArmazPos), oBrowse:Refresh()}
		
		ACTIVATE DIALOG oDlg On Init EnchoiceBar(oDlg,bOk,bCancel) CENTERED
		
		
		If nOpc == 1
		
			aCoors := FWGetDialogSize(oMainWnd)  
			
       	oView:SetModel(oModel)
			oView:EnableControlBar(.T.)
			oView:SetOperation(MODEL_OPERATION_INSERT)
			oView:SetUseCursor(.F.)
			oView:SetCloseOnOk({|| .T.})
			
			oView:oModel:SetActivate({|oModel|AbreCadastro(oModel,oView,ArmazPos)}) 

			oModel:GetModel('GFEA015_GU3'):GetStruct():SetProperty("GU3_EMFIL", MODEL_FIELD_WHEN,{||.F.})
			oModel:GetModel('GFEA015_GU3'):GetStruct():SetProperty("GU3_TRANSP", MODEL_FIELD_WHEN,{||.F.})
			oModel:GetModel('GFEA015_GU3'):GetStruct():SetProperty("GU3_AUTON", MODEL_FIELD_WHEN,{||.F.})
			oModel:GetModel('GFEA015_GU3'):GetStruct():SetProperty("GU3_TPTRIB", MODEL_FIELD_WHEN,{||.F.})
			oModel:GetModel('GFEA015_GU3'):GetStruct():SetProperty("GU3_ENTOBR", MODEL_FIELD_WHEN,{||.F.})

			oFWMVCWindow := FWMVCWindow():New()
			oFWMVCWindow:SetUseControlBar(.T.)
			oFWMVCWindow:SetView(oView)
			oFWMVCWindow:SetCentered(.T.)
			oFWMVCWindow:SetPos(aCoors[1],aCoors[2])
			oFWMVCWindow:SetSize(aCoors[3],aCoors[4])
			oFWMVCWindow:SetTitle("Cadastro de Emitente") 
			oFWMVCWindow:Activate(,,Nil,{|| lRet := .F., .T.})
			
		EndIf
	EndIf
	RestArea(aAreaGU3)
	aSize(aBrowse,0)
Return 

// Ação Acionada com o duplo clique
Static Function MarcaBrowse(nAt)
	Local nI
	
	If aBrowse[nAt][3] != "Filial Já Cadastrada" // Valida se a filial já não foi cadastrada
		aBrowse[nAt][1] := .T.
	EndIf
	
	If aBrowse[nAt][1] != .F.
		For nI := 1 To Len(aBrowse)
			If nAt != nI
				aBrowse[nI][1] := .F.
			EndIf
		Next nI
	EndIf
	
Return

Static Function AbreCadastro(oModel, oView, nAt)
	Local lNumProp := SuperGetMv("MV_EMITMP",.F.,'1') == "1" .And. SuperGetMv("MV_INTGFE2",.F.,"2") == "1"
	//Local aCodeBloc := {}

	dbSelectArea("SM0") // Emitentes
	SM0->(dbSetOrder(1)) // CÓDIGO + Cod. Filial

	If aBrowse[nAt][1] == .T. 

		SM0->(dbSeek(aBrowse[nAt][5] + aBrowse[nAt][4]))  // Pesquisa com Código + Cód. Filial selecionado.

		If lNumProp
			oModel:LoadValue('GFEA015_GU3', 'GU3_CDEMIT', 'ZZZZZZZZZ' )
       Else
			oModel:SetValue('GFEA015_GU3', 'GU3_CDEMIT', SM0->M0_CGC ) 
       EndIf
		
		oModel:LoadValue('GFEA015_GU3', 'GU3_ORIGEM', '2' )  
		
		oModel:SetValue('GFEA015_GU3', 'GU3_NATUR' , 'J')
		oModel:SetValue('GFEA015_GU3', 'GU3_NMEMIT', SM0->M0_NOMECOM)	// Antes estava com "SM0->M0_NOME"
		oModel:SetValue('GFEA015_GU3', 'GU3_IDFED' , SM0->M0_CGC)
		oModel:SetValue('GFEA015_GU3', 'GU3_IE'    , SM0->M0_INSC)
		oModel:SetValue('GFEA015_GU3', 'GU3_FONE1' , SM0->M0_TEL)
		
		cNrCid := POSICIONE("GU7",3,xFILIAL("GU7")+ UPPER(PADR(SM0->M0_CIDENT,TamSX3("GU7_NMCID")[1]))+UPPER(SM0->M0_ESTENT),"GU7_NRCID")
		GU7->(dbSetOrder(1))
		
		oModel:SetValue('GFEA015_GU3', 'GU3_NRCID',	cNrCid)
		oModel:SetValue('GFEA015_GU3', 'GU3_ENDER',	SM0->M0_ENDENT)
		oModel:SetValue('GFEA015_GU3', 'GU3_CEP', 	SM0->M0_CEPENT)
		oModel:SetValue('GFEA015_GU3', 'GU3_UF', 		SM0->M0_ESTENT)
		oModel:SetValue('GFEA015_GU3', 'GU3_BAIRRO',	SM0->M0_BAIRENT)
		oModel:LoadValue('GFEA015_GU3', 'GU3_EMFIL',	'1')
		oModel:SetValue('GFEA015_GU3', 'GU3_TRANSP',	'2')
		oModel:SetValue('GFEA015_GU3', 'GU3_AUTON',	'2')
		oModel:SetValue('GFEA015_GU3', 'GU3_CLIEN',	'2')
		oModel:SetValue('GFEA015_GU3', 'GU3_FORN',	'2')
		oModel:LoadValue('GFEA015_GU3', 'GU3_FAX',		AllTrim(SM0->M0_FAX))
		oModel:LoadValue('GFEA015_GU3', 'GU3_COMPL',	AllTrim(SM0->M0_COMPENT))
		oModel:LoadValue('GFEA015_GU3', 'GU3_NMFAN',	AllTrim(SM0->M0_FILIAL))
		oModel:LoadValue('GFEA015_GU3', 'GU3_IM',		AllTrim(SM0->M0_INSCM))

	EndIf
	
Return

Function GFEA015VEV(cUF)
	Local cEstados := cUFs
	Local aEstados := StrTokArr(cEstados, ";")
	Local nPos
	
	nPos := aScan(aEstados, cUF)
	If nPos != 0 .And. !Empty(cEstados)
		Help( ,, 'HELP', '', 'UF ' + cUF + ' já se encontra na lista!.', 1, 0)
		Return .F.
	EndIf

Return .T.

Function FiltroF3(cTitulo,cQuery,nTamCpo,cAlias,cCodigo,cCpoChave,cTitCampo,cMascara,cRetCpo,nColuna)
	Local nLista  
	Local cCampos 	:= ""
	Local bCampo	:= {}
	Local nCont		:= 0
	//Local bTitulos	:= {}
	Local aCampos 	:= {}
	Local cTabela 
	Local cCSSGet	:= "QLineEdit{ border: 1px solid gray;border-radius: 3px;background-color: #ffffff;selection-background-color: #3366cc;selection-color: #ffffff;padding-left:1px;}"
	Local cCSSButton:= "QPushButton{background-repeat: none; margin: 2px;background-color: #ffffff;border-style: outset;border-width: 2px;border: 1px solid #C0C0C0;border-radius: 5px;border-color: #C0C0C0;font: bold 12px Arial;padding: 6px;QPushButton:pressed {background-color: #ffffff;border-style: inset;}"
	//Local cCSSButF3	:= "QPushButton {background-color: #ffffff;margin: 2px;border-style: outset;border-width: 2px;border: 1px solid #C0C0C0;border-radius: 3px; border-color: #C0C0C0;font: Normal 10px Arial;padding: 3px;} QPushButton:pressed {background-color: #e6e6f9;border-style: inset;}"
	Local nX

	Private _oLista	:= nil
	Private _oDlg 	:= nil
	Private _oCodigo
	Private _cCodigo 	
	Private _aDados := {}
	Private _nColuna:= 0

	_nColuna	:= nColuna

	If Empty(cAlias) .OR. Empty(cCpoChave) .OR. Empty(cRetCpo) .OR. Empty(cQuery)
		MsgStop("Os parametro cQuery, cCpoChave, cRetCpo e cAlias são obrigatórios!","Erro")
		Return
	Endif

	_cCodigo := cEstados

	cTabela := GetNextAlias()
	DbUseArea(.T.,"TOPCONN", TCGENQRY(,,cQuery),cTabela, .F., .T.)
     
	(cTabela)->(DbGoTop())
	If (cTabela)->(Eof())
		MsgStop("Não há registros para serem exibidos!","Atenção")
		Return
	Endif
   
	Do While (cTabela)->(!Eof())
		/*Cria o array conforme a quantidade de campos existentes na consulta SQL*/
		cCampos	:= ""
		aCampos 	:= {}
		For nX := 1 TO FCount()
			bCampo := {|nX| Field(nX) }
			If ValType((cTabela)->&(EVAL(bCampo,nX)) ) <> "M" .OR. ValType((cTabela)->&(EVAL(bCampo,nX)) ) <> "U"
				If ValType((cTabela)->&(EVAL(bCampo,nX)) )=="C"
					cCampos += "'" + (cTabela)->&(EVAL(bCampo,nX)) + "',"
				ElseIf ValType((cTabela)->&(EVAL(bCampo,nX)) )=="D"
					cCampos +=  DTOC((cTabela)->&(EVAL(bCampo,nX))) + ","
				Else
					cCampos +=  (cTabela)->&(EVAL(bCampo,nX)) + ","
				Endif
					
				aadd(aCampos,{EVAL(bCampo,nX),Alltrim(RetTitle(EVAL(bCampo,nX))),"LEFT",30})
			Endif
		Next
     
     	If !Empty(cCampos) 
     		cCampos 	:= Substr(cCampos,1,len(cCampos)-1)
     		aAdd( _aDados,&("{"+cCampos+"}"))
     	Endif
     	
		(cTabela)->(DbSkip())     
	Enddo
	
	aCampos[1,2] := "UF"
   
	(cTabela)->( DbCloseArea() )
	
	If Len(_aDados) == 0
		MsgInfo("Não há dados para exibir!","Aviso")
		Return
	Endif
   
	nLista := aScan(_aDados, {|x| alltrim(x[1]) == alltrim(_cCodigo)})
     
	iif(nLista = 0,nLista := 1,nLista)
     
	Define MsDialog _oDlg Title "Consulta Padrão" + IIF(!Empty(cTitulo)," - " + cTitulo,"") From 0,0 To 280, 500 Of oMainWnd Pixel
	
	oCodigo := TGet():New( 003, 005,{|u| if(PCount()>0,_cCodigo:=u,_cCodigo)},_oDlg,205, 010,cMascara,{|| /*Processa({|| FiltroF3P(M->_cCodigo)},"Aguarde...")*/ },0,,,.F.,,.T.,,.F.,,.F.,.F.,,.T.,.F.,"",_cCodigo,,,,,,,cTitCampo + ": ",1 )
	oCodigo:SetCss(cCSSGet)
	oButton1 := TButton():New(010, 212," Limpar ",_oDlg,{|| Processa({|| GFE15CLEAR() },"Aguarde...") },037,013,,,.F.,.T.,.F.,,.F.,,,.F. )
	oButton1:SetCss(cCSSButton)		
	    
	_oLista:= TCBrowse():New(26,05,245,90,,,,_oDlg,,,,,{|| _oLista:Refresh()},,,,,,,.F.,,.T.,,.F.,,,.f.)
	nCont := 1
    
    //Para ficar dinâmico a criação das colunas, eu uso macro substituição "&"
	For nX := 1 to len(aCampos)
		cColuna := &('_oLista:AddColumn(TCColumn():New("'+aCampos[nX,2]+'", {|| _aDados[_oLista:nAt,'+StrZero(nCont,2)+']},PesqPict("'+cAlias+'","'+aCampos[nX,1]+'"),,,"'+aCampos[nX,3]+'", '+StrZero(aCampos[nX,4],3)+',.F.,.F.,,{|| .F. },,.F., ) )')
		nCont++
	Next
	_oLista:SetArray(_aDados)
	_oLista:bWhen 		 := { || Len(_aDados) > 0 }
	_oLista:bLDblClick  := { || FiltroF3Add(_oLista:nAt, _aDados, cRetCpo)  }
	_oLista:Refresh()

	oButton2 := TButton():New(122, 005," OK "			,_oDlg,{|| Processa({|| FiltroF3R(_oLista:nAt, _aDados, cRetCpo) },"Aguarde...") },037,012,,,.F.,.T.,.F.,,.F.,,,.F. )
	oButton2:SetCss(cCSSButton)	
	oButton3 := TButton():New(122, 047," Cancelar "	,_oDlg,{|| _oDlg:End() },037,012,,,.F.,.T.,.F.,,.F.,,,.F. )
	oButton3:SetCss(cCSSButton)	

	Activate MSDialog _oDlg Centered	
Return(bRet)

Function GFE15CLEAR()

	_cCodigo := ""
	cUfs := ""
	oCodigo:CtrlRefresh()

Return

Function FiltroF3R(nLinha,aDados,cRetCpo)
	
	bRet := .T.
	_oDlg:End()    

Return .T.

Function FiltroF3Add(nLinha,aDados,cRetCpo)

	cCodigo := aDados[nLinha,_nColuna]
	If GFEA015VEV(Alltrim(cCodigo))
		cUFs := cUFs + Alltrim(cCodigo) + ";"
		_cCodigo := cUFs
		oCodigo:CtrlRefresh()
	EndIf
	   
Return

Function UFF3()
	Local cTitulo	:= "UF"
	Local cQuery	:= "" 							//obrigatorio
	Local cAlias	:= "X5"							//obrigatorio
	Local cCpoChave	:= "X5_CHAVE" 					//obrigatorio
	Local cTitCampo	:= "UFs"			//obrigatorio
	Local cMascara	:= PesqPict(cAlias,cCpoChave)	//obrigatorio
	Local nTamCpo	:= TamSx3(cCpoChave)[1]		
	Local cRetCpo	:= "GFEUFRET()"					//obrigatorio
	Local nColuna	:= 1	
	Local cCodigo	//:= GFEUFRET()		//pego o conteudo e levo para minha consulta padrão			
 	Private bRet 	:= .F.
 	Private cEstados := Alltrim(M->GU3_ESEXIC)
 	
 	cUFs := Alltrim(M->GU3_ESEXIC)

   	//Monto minha consulta, neste caso quero retornar apenas uma coluna, mas poderia inserir outros campos para compor outras colunas no grid, lembrando que não posso utilizar um alias para o nome do campo, deixar o nome real.
   	//Posso fazer qualquer tipo de consulta, usando INNER, GROUPY BY, UNION's etc..., desde que mantenha o nome dos campos no SELECT.
   	cQuery := " SELECT DISTINCT X5_CHAVE, X5_DESCRI "
	cQuery += " FROM " + RetSQLName("SX5") + " SX5 " //WITH (NOLOCK)
	cQuery += " WHERE X5_FILIAL  = '" + xFilial("SX5") + "' "
	cQuery += " AND X5_TABELA = '12' "
	cQuery += " AND SX5.D_E_L_E_T_ = ' ' "
	cQuery += " ORDER BY X5_CHAVE "

 	bRet := FiltroF3(cTitulo,ChangeQuery(cQuery),nTamCpo,cAlias,cCodigo,cCpoChave,cTitCampo,cMascara,cRetCpo,nColuna)

Return(bRet)

Function GFEUFRET()	
Return cUFs
/*
=========================================================================================================
// {Protheus.doc} IntegDef
// TODO Chamada da Rotina de Integração de Mensagem Unica 
@author Ana Claudia 
@since 03/08/2017
@version 1.000
@param cXml     : Xml definido de acordo com o XSD da mensagem de envio/recebimento.
@param nType    : numeric / Informa o tipo de Mensagem tratada: 0=Response;1=Envio;
@param cTypeMsg : Informa qual o tipo de mensagem que será processada se é uma: Business Message, Receipt Message, WhoIs Message 
@type function
// Função tem que ser statica segundo documentação
=========================================================================================================
*/
Static Function IntegDef(cXml,nType,cTypeMsg)
	Local  aResult := {}

    aResult := GFEI015(cXml,nType,cTypeMsg)
Return aResult

//-------------------------------------------------------------------
/*/{Protheus.doc} GFE015CDGR
Rotina do When do campo do código do grupo para habilitar e desabilitar o campo
Efeito nos campos:
	GU3_CDGREM
Uso Geral.

@author João Leonardo Schmidt
@since 25/10/2018
@version 1.0
/*/
//-------------------------------------------------------------------
Function GFE015CDGR()
	Local lRet := .T.
	
	If SuperGetMV('MV_CADERP',,'1') $ "1S" .And. GU3->GU3_CLIEN == "1" //DLOGGFE-11040
		lRet := .F.
	EndIf
Return lRet
