#INCLUDE "GFEA061A.CH"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"

//CA1003: Uso não permitido de chamada de API em LOOP
Static _MVERPGFE	:= SuperGetMv("MV_ERPGFE",.F.,"2")
Static _MVTFMLA		:= SuperGetMv("MV_TFMLA",.F.,"2")
Static _MVSERVTO	:= SuperGetMV("MV_SERVTO",.F.,"2")
Static _MVCPLINT	:= SuperGetMv("MV_CPLINT",.F.,"")
Static _MVAPRTAB	:= SuperGetMv("MV_APRTAB",.F.,"2")

// SONARQUBE - CA1003: Uso não permitido de chamada de API em LOOP
Static lPEXOCSV		:= ExistBlock("XGFEOCSV")
Static lPE612		:= ExistBlock("GFEA0612")
Static lPE613		:= ExistBlock("GFEA0613")

Static _GV9DESPED	:= GFXCP12117("GV9_DESPED")

/*/--------------------------------------------------------------------------------------------------
{Protheus.doc} GFEA061A
Negociação da tabela de frete.
Uso Generico.

@sample
GFEA061A()

@author Felipe M., Felipe W.
@since 14/10/09
@version 1.0
--------------------------------------------------------------------------------------------------/*/
Function GFEA061A(lFiltGVA, cCDEMIT, cNRTAB)
	Local oBrowse
	Local cFunBkp := FunName()
	Private cTB_CDEMIT
	Private cTB_NRTAB

	Default cCDEMIT := GVA->GVA_CDEMIT
	Default cNRTAB  := GVA->GVA_NRTAB

	// Workaround para executar o MenuDef() correto.
	// Assim considera os privilégios específicos setados no SIGACFG.
	SetFunName("GFEA061A")

	//Armazena os dados da tabela de frete
	cTB_CDEMIT = cCDEMIT
	cTB_NRTAB  = cNRTAB

	dbSelectArea('GUY')
	Chkfile( 'GUY',,'GUYBF') // CRIANDO UMA COPIA DA TABELA GUY COM NOME GUYBF

	oBrowse := FWMBrowse():New()
	oBrowse:SetAlias("GV9")			// Alias da tabela utilizada
	oBrowse:SetIgnoreARotina(.T.) 	// Ignora aRotina na construção das opções de menu
	oBrowse:SetMenuDef("GFEA061A")	// Nome do fonte onde esta a função MenuDef
	oBrowse:SetDescription(STR0001)	// Descrição do browse //"Negociação da tabela de frete"

	If lFiltGVA //Filtro p/ o browser
		oBrowse:SetFilterDefault("GV9_FILIAL+GV9_CDEMIT+GV9_NRTAB == '" + xFilial("GV9")+GVA->(GVA_CDEMIT+GVA_NRTAB)+ "'")
	EndIf

	oBrowse:AddLegend("GV9_SIT == '1'", "RED"  , STR0024) //Legenda do Browser //"Em Negociação"
	oBrowse:AddLegend("GV9_SIT == '2'", "GREEN", STR0025) //"Liberado"
	oBrowse:Activate()

	(GUYBF)->(dbCloseArea())

	SetFunName(cFunBkp)
Return(Nil)

//---------------------------------------------------------------------------------------------------

Static Function MenuDef()
	Local aRotina := {}
	
	//----------------------------------------------------------------------------------------------
	// *** Ponto de Atenção! ***
	// Todas as funções colocadas no MenuDef() devem ser colocadas no GFEA061 também, usando 
	// a função oBrwNeg:AddButton.
	// Motivo: o MenuDef() mapeia as funções disponíveis no [SIGACFG -> Usuários -> Senhas -> Privilégios].
	// Se a função do MenuDef() não estiver lá, ela vai aparecer no menu, 
	// porém o sistema não encontrará a permissão, negando o acesso.
	//----------------------------------------------------------------------------------------------	

	// Adiciona botões do browse
	AAdd(aRotina, {"Incluir"                , 'GFEA061NIN()'                , 0, 3 , 0})
	AAdd(aRotina, {"Alterar"                , 'GFEA061NAL()'                , 0, 4 , 0})
	AAdd(aRotina, {"Tarifas"                , 'GFEA061NTA()'                , 0, 2 , 0})
	AAdd(aRotina, {"Visualizar"             , 'GFEA061NVI()'                , 0, 9 , 0})
	AAdd(aRotina, {STR0006                  , 'GFE61AEXC()'                 , 0, 5 , 0}) // "Excluir"
	AAdd(aRotina, {"Copiar"                 , 'GFE61ACOPY()'                , 0, 4 , 0})
	AAdd(aRotina, {STR0069                  , 'GFEA61AENV()'                , 0, 10, 0}) // "Enviar apro"
	AAdd(aRotina, {STR0002                  , 'GFE61APESQ()'                , 0, 1 , 0}) // "Pesquisar"
	AAdd(aRotina, {"Consultar Comparativos" , 'GFEX062("1",GV9->GV9_CODCOT)', 0, 2 , 0})
	If _MVERPGFE == "1" .And. _MVTFMLA == "1"
		AAdd(aRotina, {"Desatualizar MLA", 'GFEA61ADMA', 0, 10, 0})
	EndIf
	AAdd(aRotina, {"Exportar Negociação"        , 'GFEA061J(1)'                , 0, 3 , 0})
	AAdd(aRotina, {"Importar Negociação"        , 'GFEA061J(2)'                , 0, 3 , 0})
	AAdd(aRotina, {"Encerrar Vigência"          , 'GFEA61VIGE'                 , 0, 3 , 0})
	

Return aRotina

//---------------------------------------------------------------------------------------------------

Static Function ModelDef()
	Local oModel
	Local oStructGV9 	:= FWFormStruct(1,"GV9")
	Local oStructGV8 	:= FWFormStruct(1,"GV8")
	Local oStructGV7	:= FWFormStruct(1,"GV7")
	Local oStructGUC	:= FWFormStruct(1,"GUC")
	Local lTemGVQ 		:= GFXTB12117("GVQ")
	Local lGUC_NRCID	:= GFXCP2610("GUC_NRCID")
						   
	oStructGV8:AddField("Origem" ,"","GV8_CODORI","C",150,/*nDecimal*/,/*bValid*/,/*bWHen*/,/*aValues*/,/*lObrigat*/,/*bInit*/,/*lkey*/,/*lNoUpd*/,.T./*lVirtual*/,/*cValid*/)
	oStructGV8:AddField("Destino","","GV8_CODDES","C",150,/*nDecimal*/,/*bValid*/,/*bWHen*/,/*aValues*/,/*lObrigat*/,/*bInit*/,/*lkey*/,/*lNoUpd*/,.T./*lVirtual*/,/*cValid*/)
	oStructGV8:SetProperty("GV8_CODORI", MODEL_FIELD_INIT , FwBuildFeature( STRUCT_FEATURE_INIPAD, "If(!Inclui,A061GV8INI('GV8_CODORI'),'')" ))
	oStructGV8:SetProperty("GV8_CODDES", MODEL_FIELD_INIT , FwBuildFeature( STRUCT_FEATURE_INIPAD, "If(!Inclui,A061GV8INI('GV8_CODDES'),'')" ))
	oStructGV8:SetProperty("GV8_TPORIG", MODEL_FIELD_INIT , FwBuildFeature( STRUCT_FEATURE_INIPAD, "''" ))
	oStructGV8:SetProperty("GV8_TPDEST", MODEL_FIELD_INIT , FwBuildFeature( STRUCT_FEATURE_INIPAD, "''" ))
	oStructGV8:SetProperty("GV8_TPORIG", MODEL_FIELD_VALID, {|A,B,C,D| A061GV8VAL(A,B,C) })
	oStructGV8:SetProperty("GV8_TPDEST", MODEL_FIELD_VALID, {|A,B,C,D| A061GV8VAL(A,B,C) })
	
	If	GetCbSource(oStructGV7:GetProperty("GV7_DSTPVC",MODEL_FIELD_INIT)) == GetCbSource(FwBuildFeature( STRUCT_FEATURE_INIPAD, 'IF(!INCLUI,POSICIONE("GV3",1,XFILIAL("GV3")+GV7->GV7_CDTPVC,"GV3_DSTPVC") ,"")' ))
		oStructGV7:SetProperty("GV7_DSTPVC",MODEL_FIELD_INIT, FwBuildFeature( STRUCT_FEATURE_INIPAD, "GFEA061DS(GV7->GV7_CDTPVC)" ))
	EndIf
	
	oStructGV9:SetProperty("GV9_COMFXE", MODEL_FIELD_VALID, {|A,B,C,D| FWINITCPO(A,B,C), LRETORNO := GFEA61AVLC() ,FWCLOSECPO(A,B,C,LRETORNO),LRETORNO})
	
	// cID     Identificador do modelo
	// bPre    Code-Block de pre-edição do formulário de edição. Indica se a edição esta liberada
	// bPost   Code-Block de validação do formulário de edição
	// bCommit Code-Block de persistência do formulário de edição
	// bCancel Code-Block de cancelamento do formulário de edição
	oModel := MPFormModel():New("GFEA061A", /*bPre*/, {|oX|GFE61APOS(oX)},{|oModel|GFE61ACOM(oModel)}/*bCommit*/, /*bCancel*/)
	
	oModel:SetVldActivate({|oMod| GFEA61AVLD(oMod) })
	
	// cId          Identificador do modelo
	// cOwner       Identificador superior do modelo
	// oModelStruct Objeto com  a estrutura de dados
	// bPre         Code-Block de pré-edição do formulário de edição. Indica se a edição esta liberada
	// bPost        Code-Block de validação do formulário de edição
	// bLoad        Code-Block de carga dos dados do formulário de edição
	oModel:AddFields("GFEA061A_GV9", Nil, oStructGV9,{|oX,acao,campo,valor|GFEA061AVG(oX,acao,campo,valor)}/*bPre*/, /*{|oX|GFEA061APOS(oX)}*/ /* bPos */,/*bLoad*/)
	//Faixas
	oModel:AddGrid('DETAIL_GUZ', 'GFEA061A_GV9', FWFormStruct(1,"GUZ"), /*bLinePre*/                              , {|oX| GFE61FAI(oX)}, /*bPreVal*/    , /*bPosVal*/, /*BLoad*/)
	//Componentes
	oModel:AddGrid('DETAIL_GUY', 'GFEA061A_GV9', FWFormStruct(1,"GUY"), {|oX,Line,Acao,Campo,Valor| GFEA61ACOE(oX,Line,Acao,Campo,Valor)} , {|oX| GFE61COM(oX)}, /*bPreVal*/    , /*bPosVal*/, /*BLoad*/)
	//Rotas
	oModel:AddGrid('DETAIL_GV8', 'GFEA061A_GV9', oStructGV8, {|oX,Line,Acao| GFEA61AROE(oX,Line,Acao)} , {|oX| GFE61ROT(oX)}, /*bPreVal*/    , /*bPosVal*/, /*BLoad*/ )
	//Faixa/Tipo Veiculo
	oModel:AddGrid('DETAIL_GV7', 'GFEA061A_GV9', oStructGV7, {|oX,Line,Acao| GFEA61AFTE(oX,Line,Acao)} , {|oX| GFE61FTV(oX)}, /*bPreVal*/    ,/*bPosVal*/ , /*BLoad*/ )
	If lTemGVQ
		//Comparativo de Frete
		oModel:AddGrid('DETAIL_GVQ', 'GFEA061A_GV9', FWFormStruct(1,"GVQ"))
	EndIf
	// Adiconais por emitentes
	oModel:AddGrid('DETAIL_GUC', 'GFEA061A_GV9', oStructGUC)

	oModel:SetRelation('DETAIL_GUZ',{{'GUZ_FILIAL','xFilial( "GUZ" )'},{'GUZ_CDEMIT','GV9_CDEMIT'},{'GUZ_NRTAB','GV9_NRTAB'},{'GUZ_NRNEG','GV9_NRNEG'}},'GUZ_SEQFAI')
	oModel:SetRelation('DETAIL_GUY',{{'GUY_FILIAL','xFilial( "GUY" )'},{'GUY_CDEMIT','GV9_CDEMIT'},{'GUY_NRTAB','GV9_NRTAB'},{'GUY_NRNEG','GV9_NRNEG'}},'GUY_CDCOMP')
	oModel:SetRelation('DETAIL_GV8',{{'GV8_FILIAL','xFilial( "GV8" )'},{'GV8_CDEMIT','GV9_CDEMIT'},{'GV8_NRTAB','GV9_NRTAB'},{'GV8_NRNEG','GV9_NRNEG'}},'GV8_NRROTA')
	oModel:SetRelation('DETAIL_GV7',{{'GV7_FILIAL','xFilial( "GV7" )'},{'GV7_CDEMIT','GV9_CDEMIT'},{'GV7_NRTAB','GV9_NRTAB'},{'GV7_NRNEG','GV9_NRNEG'}},'GV7_CDFXTV')

	If lTemGVQ
		//O comparativo é relacionado para que seja excluído quando a GV9 também for.
		oModel:SetRelation('DETAIL_GVQ',{{'GVQ_FILIAL','xFilial( "GVQ" )'},{'GVQ_TPCOT','"1"'},{'GVQ_CODCOT','GV9_CODCOT'}})
	EndIf

	If lGUC_NRCID
		oModel:SetRelation('DETAIL_GUC',{{'GUC_FILIAL','xFilial("GUC")'},{'GUC_CDEMIT','GV9_CDEMIT'},{'GUC_NRTAB','GV9_NRTAB'},{'GUC_NRNEG','GV9_NRNEG'},{'GUC_CDFXTV',"'" + PADR("*", TamSX3("GUC_CDFXTV")[1]) + "'"},{'GUC_NRROTA',"'" + PADR("*", TamSX3("GUC_NRROTA")[1]) + "'"}},'GUC_CDCOMP+GUC_EMICOM+GUC_NRCID+GUC_NATUR')
	Else
		oModel:SetRelation('DETAIL_GUC',{{'GUC_FILIAL','xFilial("GUC")'},{'GUC_CDEMIT','GV9_CDEMIT'},{'GUC_NRTAB','GV9_NRTAB'},{'GUC_NRNEG','GV9_NRNEG'},{'GUC_CDFXTV',"'" + PADR("*", TamSX3("GUC_CDFXTV")[1]) + "'"},{'GUC_NRROTA',"'" + PADR("*", TamSX3("GUC_NRROTA")[1]) + "'"}},'GUC_CDCOMP+GUC_EMICOM')
	EndIf
			
	oModel:GetModel( 'DETAIL_GUZ' ):SetUniqueLine( { 'GUZ_SEQFAI' } )
	oModel:GetModel( 'DETAIL_GUY' ):SetUniqueLine( { 'GUY_CDCOMP' } )
	oModel:GetModel( 'DETAIL_GV8' ):SetUniqueLine( { 'GV8_NRROTA' } )
	oModel:GetModel( 'DETAIL_GV7' ):SetUniqueLine( { 'GV7_CDFXTV' } )

	If lGUC_NRCID
		oModel:GetModel( 'DETAIL_GUC' ):SetUniqueLine( { 'GUC_CDCOMP','GUC_EMICOM','GUC_NRCID','GUC_NATUR' } )
	Else
		oModel:GetModel( 'DETAIL_GUC' ):SetUniqueLine( { 'GUC_CDCOMP','GUC_EMICOM' } )
	EndIf
	
	oModel:GetModel('DETAIL_GUZ'):SetDelAllLine(.T.)
	oModel:GetModel('DETAIL_GUY'):SetDelAllLine(.T.)
	oModel:GetModel('DETAIL_GV8'):SetDelAllLine(.T.)
	oModel:GetModel('DETAIL_GV7'):SetDelAllLine(.T.)
	oModel:GetModel('DETAIL_GUC'):SetDelAllLine(.T.)

	If !IsBlind()
	 	oModel:GetModel('DETAIL_GUZ'):SetMaxLine(9999) 
		oModel:GetModel('DETAIL_GUY'):SetMaxLine(9999) 
		oModel:GetModel('DETAIL_GV8'):SetMaxLine(9999) 
		oModel:GetModel('DETAIL_GV7'):SetMaxLine(9999)
		oModel:GetModel('DETAIL_GUC'):SetMaxLine(9999)
	EndIf
	
	oModel:SetOptional('DETAIL_GUZ', .T. )
	oModel:SetOptional('DETAIL_GUY', .T. )
	oModel:SetOptional('DETAIL_GV8', .T. )
	oModel:SetOptional('DETAIL_GV7', .T. )
	If lTemGVQ
		oModel:SetOptional('DETAIL_GVQ', .T. )
	EndIf
	oModel:SetOptional('DETAIL_GUC', .T. )
	
	oModel:GetModel('GFEA061A_GV9'):SetDescription(STR0015) //'Negociação da tabela de frete'
	oModel:GetModel('DETAIL_GUZ'):SetDescription(STR0016) //'Faixa Entrega Tab. Frete'
	oModel:GetModel('DETAIL_GUY'):SetDescription(STR0026) //'Componentes Tab. Frete'
	oModel:GetModel('DETAIL_GV8'):SetDescription(STR0027)  //'Rotas Tab. Frete'
	oModel:GetModel('DETAIL_GV7'):SetDescription(STR0028)  //'Faixa/Tipo Veiculo'
	If lTemGVQ	// Neste Mostra mensagem q deve ser atualizado
		oModel:GetModel('DETAIL_GVQ'):SetDescription("Cotações de Frete")  //"Cotações de Frete"
	EndIf
	oModel:GetModel('DETAIL_GUC'):SetDescription("Adicionais por Emitente") 
	
Return oModel

Static Function ViewDef()
Local oModel 		:= FWLoadModel("GFEA061A")
Local oView  		:= Nil
Local oStructGV9	:= FWFormStruct(2,'GV9')
Local oStructGUY 	:= FWFormStruct(2, "GUY")
Local oStructGV8 	:= FWFormStruct(2, "GV8")
Local oStructGV7 	:= FWFormStruct(2, "GV7")
Local oStructGUC 	:= FWFormStruct(2, "GUC")
Local nCount

oStructGV9:AddFolder("3","Outros")
oStructGV9:SetNoGroups()

For nCount := 1 To Len(oStructGV9:aFields)
	If Empty(oStructGV9:aFields[nCount,11])
		oStructGV9:aFields[nCount,11] := "3"
	EndIf
Next nCount

oStructGV9:AddGroup("TABEL","Tabela","1",2)
oStructGV9:AddGroup("IDENT","Identificação","1",2)
oStructGV9:AddGroup("CRITE","Critérios","1",2)
oStructGV9:AddGroup("VIGEN","Vigência","1",2)
oStructGV9:AddGroup("COMPL","Dados Complementares","1",2)

oStructGV9:AddGroup("FRTMI","Frete Mínimo","3",2)
oStructGV9:AddGroup("CRIPE","Critérios Pedágio","3",2)
oStructGV9:AddGroup("FRTVI","Frete Viagem","3",2)
oStructGV9:AddGroup("ADENT","Adicional por Entregas","3",2)
oStructGV9:AddGroup("VEICD","Veículos Dedicados","3",2)
oStructGV9:AddGroup("TIPSE","Tipo de Serviço","3",2)
oStructGV9:AddGroup("CONTR","Controle","3",2)

oStructGV9:SetProperty("GV9_CDEMIT", MVC_VIEW_GROUP_NUMBER,"TABEL")
oStructGV9:SetProperty("GV9_NMEMIT", MVC_VIEW_GROUP_NUMBER,"TABEL")
oStructGV9:SetProperty("GV9_NRTAB", MVC_VIEW_GROUP_NUMBER,"TABEL")
oStructGV9:SetProperty("GV9_DSTAB", MVC_VIEW_GROUP_NUMBER,"TABEL")

oStructGV9:SetProperty("GV9_NRNEG", MVC_VIEW_GROUP_NUMBER,"IDENT")
oStructGV9:SetProperty("GV9_SIT", MVC_VIEW_GROUP_NUMBER,"IDENT")

oStructGV9:SetProperty("GV9_CDTPOP", MVC_VIEW_GROUP_NUMBER,"CRITE")
oStructGV9:SetProperty("GV9_DSTPOP", MVC_VIEW_GROUP_NUMBER,"CRITE")
oStructGV9:SetProperty("GV9_CDCLFR", MVC_VIEW_GROUP_NUMBER,"CRITE")
oStructGV9:SetProperty("GV9_DSCLFR", MVC_VIEW_GROUP_NUMBER,"CRITE")

oStructGV9:SetProperty("GV9_DTVALI", MVC_VIEW_GROUP_NUMBER,"VIGEN")
oStructGV9:SetProperty("GV9_DTVALF", MVC_VIEW_GROUP_NUMBER,"VIGEN")

oStructGV9:SetProperty("GV9_TPLOTA", MVC_VIEW_GROUP_NUMBER,"COMPL")
oStructGV9:SetProperty("GV9_QTKGM3", MVC_VIEW_GROUP_NUMBER,"COMPL") 
oStructGV9:SetProperty("GV9_UNIFAI", MVC_VIEW_GROUP_NUMBER,"COMPL")
oStructGV9:SetProperty("GV9_ATRFAI", MVC_VIEW_GROUP_NUMBER,"COMPL")

oStructGV9:SetProperty("GV9_COMMIN", MVC_VIEW_GROUP_NUMBER,"FRTMI")
oStructGV9:SetProperty("GV9_DSCOMN", MVC_VIEW_GROUP_NUMBER,"FRTMI")
oStructGV9:SetProperty("GV9_DIFMIN", MVC_VIEW_GROUP_NUMBER,"FRTMI")
oStructGV9:SetProperty("GV9_FREROM", MVC_VIEW_GROUP_NUMBER,"FRTMI")

oStructGV9:SetProperty("GV9_PEDROM", MVC_VIEW_GROUP_NUMBER,"CRIPE")
oStructGV9:SetProperty("GV9_PESPED", MVC_VIEW_GROUP_NUMBER,"CRIPE")

If GFXCP12127("GV9_ACVPED") 
	oStructGV9:SetProperty("GV9_ACVPED", MVC_VIEW_GROUP_NUMBER,"CRIPE")
EndIF

If _GV9DESPED
	oStructGV9:SetProperty("GV9_DESPED", MVC_VIEW_GROUP_NUMBER,"CRIPE")
EndIf

oStructGV9:SetProperty("GV9_FREVIA", MVC_VIEW_GROUP_NUMBER,"FRTVI")
oStructGV9:SetProperty("GV9_TIPVAL", MVC_VIEW_GROUP_NUMBER,"FRTVI")
oStructGV9:SetProperty("GV9_QTDCAL", MVC_VIEW_GROUP_NUMBER,"FRTVI")

oStructGV9:SetProperty("GV9_COMFXE", MVC_VIEW_GROUP_NUMBER,"ADENT")
oStructGV9:SetProperty("GV9_DSCOFX", MVC_VIEW_GROUP_NUMBER,"ADENT")
oStructGV9:SetProperty("GV9_AGRSE", MVC_VIEW_GROUP_NUMBER,"TIPSE")
oStructGV9:SetProperty("GV9_CDTPSE", MVC_VIEW_GROUP_NUMBER,"TIPSE")
oStructGV9:SetProperty("GV9_DSTPSE", MVC_VIEW_GROUP_NUMBER,"TIPSE")
oStructGV9:SetProperty("GV9_TPIMP", MVC_VIEW_GROUP_NUMBER,"TIPSE")

oStructGV9:SetProperty("GV9_DTCRIA", MVC_VIEW_GROUP_NUMBER,"CONTR")
oStructGV9:SetProperty("GV9_HRCRIA", MVC_VIEW_GROUP_NUMBER,"CONTR")
oStructGV9:SetProperty("GV9_USUCRI", MVC_VIEW_GROUP_NUMBER,"CONTR")
oStructGV9:SetProperty("GV9_ENVAPR", MVC_VIEW_GROUP_NUMBER,"CONTR")
oStructGV9:SetProperty("GV9_DTAPR",  MVC_VIEW_GROUP_NUMBER,"CONTR")
oStructGV9:SetProperty("GV9_HRAPR",  MVC_VIEW_GROUP_NUMBER,"CONTR")
oStructGV9:SetProperty("GV9_USUAPR", MVC_VIEW_GROUP_NUMBER,"CONTR")
oStructGV9:SetProperty("GV9_MTVRPR", MVC_VIEW_GROUP_NUMBER,"CONTR")

If AScan(oStructGV9:aFields,{|x| x[1] == "GV9_CFCOTA"}) != 0	
	oStructGV9:SetProperty("GV9_CFCOTA", MVC_VIEW_GROUP_NUMBER,"VEICD") 
	oStructGV9:SetProperty("GV9_CFALUG", MVC_VIEW_GROUP_NUMBER,"VEICD")
	oStructGV9:SetProperty("GV9_CFEXCD", MVC_VIEW_GROUP_NUMBER,"VEICD")	
EndIf

If oStructGV9:HasField("GV9_CODCOT")
	oStructGV9:RemoveField("GV9_CODCOT")
	oStructGV9:RemoveField("GV9_SEQCOT")
EndIf

oStructGUY:RemoveField("GUY_CDEMIT")
oStructGUY:RemoveField("GUY_NMEMIT")
oStructGUY:RemoveField("GUY_NRTAB")
oStructGUY:RemoveField("GUY_DSTAB")
oStructGUY:RemoveField("GUY_NRNEG")

oStructGV8:RemoveField("GV8_CDEMIT")
oStructGV8:RemoveField("GV8_NMEMIT")
oStructGV8:RemoveField("GV8_NRTAB")
oStructGV8:RemoveField("GV8_DSTAB")
oStructGV8:RemoveField("GV8_NRNEG")

// Campos de origem/destino
oStructGV8:AddField("GV8_CODORI","2","Origem","Origem",,"C","",/*BPICTVAR*/,,.F./*LCANCHANGE*/,/*CFOLDER*/,/*CGROUP*/,/*ACOMBOVALUES*/,/*NMAXLENCOMBO*/,/*CINIBROW*/,.T./*LVIRTUAL*/,/*CPICTVAR*/,/*LINSERTLINE*/)
oStructGV8:AddField("GV8_CODDES","3","Destino","Destino",,"C","",/*BPICTVAR*/,,.F./*LCANCHANGE*/,/*CFOLDER*/,/*CGROUP*/,/*ACOMBOVALUES*/,/*NMAXLENCOMBO*/,/*CINIBROW*/,.T./*LVIRTUAL*/,/*CPICTVAR*/,/*LINSERTLINE*/)

oStructGV8:RemoveField("GV8_NRCIOR")
oStructGV8:RemoveField("GV8_DSCIOR")
oStructGV8:RemoveField("GV8_DSTORI")
oStructGV8:RemoveField("GV8_DSTORF")
oStructGV8:RemoveField("GV8_NRREOR")
oStructGV8:RemoveField("GV8_DSREOR")
oStructGV8:RemoveField("GV8_CDPAOR")
oStructGV8:RemoveField("GV8_DSPAOR")
oStructGV8:RemoveField("GV8_CDUFOR")
oStructGV8:RemoveField("GV8_CDFIOR")
oStructGV8:RemoveField("GV8_NRCIDS")
oStructGV8:RemoveField("GV8_DSCIDS")
oStructGV8:RemoveField("GV8_DSTDEI")
oStructGV8:RemoveField("GV8_NRREDS")
oStructGV8:RemoveField("GV8_DSREDS")
oStructGV8:RemoveField("GV8_DSTDEF")
oStructGV8:RemoveField("GV8_NRREDS")
oStructGV8:RemoveField("GV8_CDPADS")
oStructGV8:RemoveField("GV8_DSPADS")
oStructGV8:RemoveField("GV8_CDUFDS")
oStructGV8:RemoveField("GV8_CDFIDS")
oStructGV8:RemoveField("GV8_CDREM")
oStructGV8:RemoveField("GV8_NMREM")
oStructGV8:RemoveField("GV8_CDDEST")
oStructGV8:RemoveField("GV8_NMDEST")
// ---------

oStructGV7:RemoveField("GV7_CDEMIT")
oStructGV7:RemoveField("GV7_NMEMIT")
oStructGV7:RemoveField("GV7_NRTAB")
oStructGV7:RemoveField("GV7_DSTAB")
oStructGV7:RemoveField("GV7_NRNEG")

// ----------
oStructGUC:RemoveField("GUC_CDEMIT")
oStructGUC:RemoveField("GUC_NMEMIT")
oStructGUC:RemoveField("GUC_NRTAB")
oStructGUC:RemoveField("GUC_DSTAB")
oStructGUC:RemoveField("GUC_NRNEG")
oStructGUC:RemoveField("GUC_CDFXTV")
oStructGUC:RemoveField("GUC_NRROTA")

oView := FWFormView():New()
// Objeto do model a se associar a view.
oView:SetModel(oModel)

// cFormModelID - Representa o ID criado no Model que essa FormField irá representar
// oStruct - Objeto do model a se associar a view.
// cLinkID - Representa o ID criado no Model ,Só é necessári o caso estamos mundando o ID no View.
oView:AddField('GFEA061A_GV9',oStructGV9,'GFEA061A_GV9')
oView:AddGrid('VIEW_GUZ',FWFormStruct(2,'GUZ'),'DETAIL_GUZ')
oView:AddGrid('VIEW_GUY',oStructGUY,'DETAIL_GUY')
oView:AddGrid('VIEW_GV8',oStructGV8,'DETAIL_GV8')
oView:AddGrid('VIEW_GV7',oStructGV7,'DETAIL_GV7')
oView:AddGrid('VIEW_GUC',oStructGUC,'DETAIL_GUC')
// cID		  	Id do Box a ser utilizado
// nPercHeight  Valor da Altura do box( caso o lFixPixel seja .T. é a qtd de pixel exato)
// cIdOwner 	Id do Box Vertical pai. Podemos fazer diversas criações uma dentro da outra.
// lFixPixel	Determina que o valor passado no nPercHeight é na verdade a qtd de pixel a ser usada.
// cIDFolder	Id da folder onde queremos criar o o box se passado esse valor, é necessário informar o cIDSheet
// cIDSheet     Id da Sheet(Folha de dados) onde queremos criar o o box.

oView:CreateHorizontalBox( "MASTER" , 55,/*cIDOwner*/,/*lFixPixel*/,/*cIDFolder*/,/*cIDSheet*/ )
oView:CreateHorizontalBox( "DETAIL" , 45,/*cIDOwner*/,/*lFixPixel*/,/*cIDFolder*/,/*cIDSheet*/ )
oView:CreateHorizontalBox( "DETAILCOM" , 100,,,"IDFOLDER","IDSHEET01" )
oView:CreateHorizontalBox( "DETAILROT" , 100,,,"IDFOLDER","IDSHEET02" )
oView:CreateHorizontalBox( "DETAILFTV" , 100,,,"IDFOLDER","IDSHEET03" )
oView:CreateHorizontalBox( "DETAILFAI" , 100,,,"IDFOLDER","IDSHEET04" )
oView:CreateHorizontalBox( "DETAILAEM" , 100,,,"IDFOLDER","IDSHEET05" )

oView:CreateFolder("IDFOLDER","DETAIL")
oView:AddSheet("IDFOLDER","IDSHEET01",STR0029)  //"Componente de Frete"
oView:AddSheet("IDFOLDER","IDSHEET02",STR0010) //"Rotas"
oView:AddSheet("IDFOLDER","IDSHEET03",STR0030) //"Faixa/Tipo Veiculo"
oView:AddSheet("IDFOLDER","IDSHEET04",STR0017) //"Faixa de Entrega"
oView:AddSheet("IDFOLDER","IDSHEET05","Adicionais por Emitentes") //"Faixa de Entrega"

// Associa um View a um box
oView:SetOwnerView("GFEA061A_GV9","MASTER")
oView:SetOwnerView("VIEW_GUZ","DETAILFAI")

oView:SetOwnerView("VIEW_GUY","DETAILCOM")
oView:SetOwnerView("VIEW_GV8","DETAILROT")
oView:SetOwnerView("VIEW_GV7","DETAILFTV")
oView:SetOwnerView("VIEW_GUC","DETAILAEM")

oView:AddIncrementField('VIEW_GUZ','GUZ_SEQFAI')
oView:AddIncrementField('VIEW_GV8','GV8_NRROTA')
oView:AddIncrementField('VIEW_GV7','GV7_CDFXTV')
oView:AddIncrementField('VIEW_GUC','GUC_CDCOMP')

Return oView

/*/--------------------------------------------------------------------------------------------------
{Protheus.doc} GFE61APOS2
Validacao de Inclusao e Alteracao.
Uso GFEA061B.

@param oModel Objeto modelo

@sample
GFE61APOS()

RetCdEmit()

@author Felipe M., Felipe W.
@since 14/10/09
@version 1.0
--------------------------------------------------------------------------------------------------/*/

Function GFE61CdEmi()
	Local cRet

	If IsInCallStack("GFEA061") .OR. IsInCallStack("GFEC061")
		cRet := GVA->GVA_CDEMIT
	Else
		If Type("cTB_CDEMIT") == "U"
			cRet := GVA->GVA_CDEMIT
		Else
			cRet := cTB_CDEMIT  // Mantido por compatibilidade
		EndIf
	EndIf
	
Return cRet

//---------------------------------------------------------------------------------------------------

Function GFE61NrTab()
	Local cRet

	If IsInCallStack("GFEA061") .OR. IsInCallStack("GFEC061")
		cRet := GVA->GVA_NRTAB
	Else
		If Type("cTB_NRTAB") == "U"
			cRet := GVA->GVA_NRTAB
		Else
			cRet := cTB_NRTAB  // Mantido por compatibilidade
		EndIf
	EndIf
Return cRet

/*/--------------------------------------------------------------------------------------------------
{Protheus.doc} GFE61APOS
Validacao de Inclusao e Alteracao.
Uso GFEA061B.

@param oModel        Objeto modelo

@sample
GFE61APOS()

@author Felipe M., Felipe W.
@since 14/10/09
@version 1.0
--------------------------------------------------------------------------------------------------/*/

Function GFE61APOS(oModel)
Local aArea     := GetArea()
Local aAreaGV9  := GV9->( GetArea() )
Local aTpVcGV7 := {}
Local nOp  := (oModel:getOperation())
Local lRet := .T.
Local cSeek, cChave
Local oModelPai := FWMODELACTIVE()
Local oModelGUY := oModelPai:GetModel('DETAIL_GUY')
Local oModelGUZ := oModelPai:GetModel("DETAIL_GUZ")
Local oModelGV7 := oModelPai:GetModel('DETAIL_GV7')
Local oModelGV8 := oModelPai:GetModel('DETAIL_GV8')
Local nFxQtde   := oModelGUZ:Length()
Local nLine     := oModelGUZ:GetLine()
Local nCont
Local lEmpty    := .T.
Local nI, lCompMinimo := .F. , lCompImposto := .F., lCompCota := .F., lCompExced := .F., lCompLoca := .F., lCompFEX := .F., lCompPed := .F., lCatPed := .F.
Local lExistServ := .F.
Local lValCompSV := .T.			// Verifica se só permite um componente de serviço por negociação
Local lVerCota := GFEVerCmpo({"GV9_TPLOTA"}) .And. FwFldGet("GV9_TPLOTA") == "3" // Verificar informações de componentes para cotas e franquias

	If nOp == MODEL_OPERATION_INSERT .OR. nOp == MODEL_OPERATION_UPDATE// Se for inclusao ou alteração
	
	 	//armazena conteudo de campos em variaveis
	 	cChave := oModel:GetValue( 'GFEA061A_GV9', 'GV9_CDEMIT' )
	 	cChave += oModel:GetValue( 'GFEA061A_GV9', 'GV9_NRTAB' )
	 	cChave += oModel:GetValue( 'GFEA061A_GV9', 'GV9_NRNEG' )
	
		cSeek := oModel:GetValue( 'GFEA061A_GV9', 'GV9_CDCLFR' )
		cSeek += Dtos(oModel:GetValue( 'GFEA061A_GV9', 'GV9_DTVALI' ))
		cSeek += oModel:GetValue( 'GFEA061A_GV9', 'GV9_CDTPOP' )
	
	   dbSelectArea("GV9")  // seleciona a tabela
		dbSetOrder(01)       // seta o indice
		dbSeek(xFilial('GV9')+cChave) // posiciona no primeiro registro
		While !Eof().AND.GV9->GV9_CDEMIT == oModel:GetValue( 'GFEA061A_GV9', 'GV9_CDEMIT' ) .AND.GV9->GV9_NRTAB  == oModel:GetValue( 'GFEA061A_GV9', 'GV9_NRTAB' )
			If nOp == MODEL_OPERATION_INSERT .AND. (GV9->GV9_CDEMIT + GV9->GV9_NRTAB + GV9->GV9_NRNEG == cChave)
	    		Help( ,, 'Help',, STR0019, 1, 0 ) //"Já existe registro com chaves informadas"
				lRet := .F.
				Exit
			Else
	    		If (GV9->GV9_CDCLFR + DTOS(GV9->GV9_DTVALI) + GV9->GV9_CDTPOP == cSeek) .AND. GV9->GV9_NRNEG != oModel:GetValue( 'GFEA061A_GV9', 'GV9_NRNEG' )
		    		Help( ,, 'Help',, STR0018, 1, 0 ) //"Já existe campo com as mesmas 'Class Frete','Tipo Oper.' e 'Vigencia De' informados"
					lRet := .F.
					Exit
				EndIf
			EndIf
	
			GV9->( dbSkip(1) )
		EndDo
	
		GV9->(DbSetOrder(2))
		If GV9->(DbSeek(xFilial('GV9')+oModel:GetValue('GFEA061A_GV9','GV9_CDEMIT')+oModel:GetValue('GFEA061A_GV9','GV9_NRTAB')+oModel:GetValue('GFEA061A_GV9','GV9_CDCLFR')+oModel:GetValue('GFEA061A_GV9','GV9_CDTPOP')+DtoS(oModel:GetValue('GFEA061A_GV9','GV9_DTVALI')))) .And. GV9->GV9_NRNEG != oModel:GetValue('GFEA061A_GV9','GV9_NRNEG')
			Help( ,, 'Help',, 'Não é possível incluir um novo registro com os mesmos atributos e data de vigência inicial de uma negociação já existente para a tabela de frete. Altere a data de vigência inicial da negociação.', 1, 0 ) 
			lRet := .F.
		EndIf
	
		If !Empty(oModel:GetValue( 'GFEA061A_GV9', 'GV9_DTVALF' )) .And.;
		   (oModel:GetValue('GFEA061A_GV9','GV9_DTVALF') < oModel:GetValue('GFEA061A_GV9','GV9_DTVALI'))
	   		Help( ,, 'Help',, STR0020, 1, 0 ) //"Data de vigência final menor que data inicial"
			lRet := .F.
	    EndIf
	
	    If oModel:GetValue( 'GFEA061A_GV9', 'GV9_TPLOTA' ) == "1" .AND. ALLTRIM(oModel:GetValue( 'GFEA061A_GV9', 'GV9_UNIFAI' )) == ""
	   		Help( ,, 'Help',, STR0023, 1, 0 ) //"Tipo de Locação foi definida como Fracionada, Unidade de Faixa deve ser Informada"
			lRet := .F.
	    EndIf
	    
	    // Valor mínimo de reentrega não pode ser maior que o valor máximo
	    For nI := 1 To oModelGV8:GetQtdLine()
			oModelGV8:GoLine( nI )
			If !oModelGV8:IsDeleted()
			
		        If FwFldGet("GV8_VLMXRE",nI) <= 0 
		        
		        	Help( ,, 'Help',, "Valor Máximo de Reentrega não pode ser zero", 1, 0 ) 
					lRet := .F.
					Exit
		        	
		        EndIf     		
			
		       If GfeVerCmpo({"GV8_VLMINR"})
		        	If(FwFldGet("GV8_VLMXRE",nI) < FwFldGet("GV8_VLMINR",nI))
		        		Help( ,, 'Help',, "Valor Mínimo de Reentrega maior que o Valor Máximo", 1, 0 ) 
						lRet := .F.
						Exit
		        	EndIf
		        EndIf        
		 	EndIf
	    Next nI    
		
		 //Componente minimo, imposto e adicional de frete especificados na negociação deve estar cadastrado na tabela de componentes
	    For nI := 1 To oModelGUY:GetQtdLine()
			oModelGUY:GoLine( nI )
			If !oModelGUY:IsDeleted()
				If oModel:GetValue('GFEA061A_GV9','GV9_COMMIN') == FwFldGet("GUY_CDCOMP",nI)
					lCompMinimo := .T.
				EndIf
				If oModel:GetValue('GFEA061A_GV9','GV9_COMFXE') == FwFldGet("GUY_CDCOMP",nI)
					lCompFEX := .T.
				EndIf	
				If oModel:GetValue('GFEA061A_GV9','GV9_COMIMP') == FwFldGet("GUY_CDCOMP",nI)
					lCompImposto := .T.
				EndIf
				If _GV9DESPED
					If oModel:GetValue('GFEA061A_GV9','GV9_DESPED') == FwFldGet("GUY_CDCOMP",nI)
						lCompPed := .T.
				   	EndIf
				EndIf
				If lVerCota
					If oModel:GetValue('GFEA061A_GV9','GV9_CFCOTA') == FwFldGet("GUY_CDCOMP",nI)
						lCompCota := .T.
					EndIf
					If oModel:GetValue('GFEA061A_GV9','GV9_CFALUG') == FwFldGet("GUY_CDCOMP",nI)
						lCompLoca := .T.
					EndIf
					If oModel:GetValue('GFEA061A_GV9','GV9_CFEXCD') == FwFldGet("GUY_CDCOMP",nI)
						lCompExced := .T.
					EndIf
				EndIf	        
			EndIf
	    Next nI
	
	    If !lCompMinimo
	    	Help( ,, 'Help',, STR0044+ALLTRIM(oModel:GetValue('GFEA061A_GV9','GV9_COMMIN'))+STR0045, 1, 0 ) //"Componente Mínimo "+###+" deve estar informado na tabela de componentes."
			lRet := .F.
	    EndIf
	    
		 If !lCompFEX .And. !Empty(oModel:GetValue('GFEA061A_GV9','GV9_COMFXE'))
			Help( ,, 'Help',, "Componente Faixa Entrega "+ALLTRIM(oModel:GetValue('GFEA061A_GV9','GV9_COMFXE'))+" deve estar relacionado na tabela de componentes.", 1, 0 ) 
			lRet := .F.
	    EndIf
	
	    If !lCompImposto .AND. oModel:GetValue('GFEA061A_GV9','GV9_RATIMP') == '2'
	    	Help( ,, 'Help',, STR0046+ALLTRIM(oModel:GetValue('GFEA061A_GV9','GV9_COMIMP'))+STR0047, 1, 0 ) //"Componente Imposto "+###+" deve estar informado na tabela de componentes."
			lRet := .F.
	    EndIf

		If _GV9DESPED
			GV2->( dbSetOrder(1) )
			If GV2->(dbSeek(xFilial("GV2") + oModel:GetValue('GFEA061A_GV9','GV9_DESPED')))
				If GV2->GV2_CATVAL == "4"
					lCatPed := .T.
				EndIf
			EndIf
			
			IF lCatPed .And. oModel:GetValue('GFEA061A_GV9','GV9_ACVPED') != '2'
				Help( ,, 'Help',, "Componente para desconto de pedágio não pode ser categoria 4-Pedágio: " + AllTrim(oModel:GetValue('GFEA061A_GV9','GV9_DESPED'))+ ".", 1, 0 )
				lRet := .F.
			EndIf 
			
			If !lCompPed .And. !Empty(oModel:GetValue('GFEA061A_GV9','GV9_DESPED'))
				Help( ,, 'Help',, "Componente para desconto de pedágio não foi informado nos Componentes de Frete: " + AllTrim(oModel:GetValue('GFEA061A_GV9','GV9_DESPED'))+ ".", 1, 0 )
				lRet := .F.
			EndIf
		EndIf	   
	
		/* ****************************************************************************************************
		 * Ponto de entrada para permitir usar mais de um componente de serviço para a tabela de frete.
		 * Se o ponto existir, desconsidera a validação que impede de ter mais de um componente do tipo serviço
		 * Usado na ocorrência de cálculo adicional, deverá ser tratado no PE qual componente será usado para criar o cálculo
		 * Verificar funções: GFEVlServ e GFECalcMan
		 **************************************************************************************************** */
		lValCompSV := .T.
	
		If lPEXOCSV
			lValCompSV := .F.
		EndIf
		
		// Não realiza a validação caso o parâmetro "Serviço por tipo de Ocorrência" estiver marcado
		if _MVSERVTO != "1" 
	
			If lValCompSV
		    For nI := 1 To oModelGUY:GetQtdLine()
				oModelGUY:GoLine( nI )
				If !oModelGUY:IsDeleted()
		
					GV2->(dbSetOrder(1))
					GV2->(dbSeek(xFilial("GV2")+FwFldGet("GUY_CDCOMP",nI)))
					While !GV2->( EoF() ) .AND. GV2->GV2_CDCOMP == FwFldGet("GUY_CDCOMP",nI)
						If GV2->GV2_SERVI == "1"
							If lExistServ == .T.
								Help( ,, 'Help',, STR0085, 1, 0 ) //"Negociação deve possuir apenas um componente com o tipo serviço"
								lRet := .F.
							Else
								lExistServ := .T.
							EndIf
						EndIf
						dbSelectArea("GV2")
						dbSkip(1)
					EndDo
				EndIf
			Next
			EndIf 
		Endif
	
		If nOp == MODEL_OPERATION_UPDATE
		    GFEALPMTV(oModel:GetValue( 'GFEA061A_GV9', 'GV9_CDEMIT' ),oModel:GetValue( 'GFEA061A_GV9', 'GV9_NRTAB' ))
	    EndIf
	
	    //Processo p/ verificar se o campo de componente de faixa de entrega
	    //está preenchido, possibilitando informar registros no grid de faixa de entrega
	    For nCont := 1 To nFxQtde
	    	oModelGUZ:GoLine(nCont)
	    	If !oModelGUZ:IsDeleted() .And. (FwFldGet("GUZ_VLFXFI",nCont) != 0 .Or. FwFldGet("GUZ_PCENTR",nCont) != 0 .Or. FwFldGet("GUZ_VLENTR",nCont) != 0)
	    		lEmpty := .F.
	    		Exit
	    	EndIf
	    Next nCont
	
		oModelGUZ:GoLine(nLine)
	
		If Empty(FwFldGet("GV9_COMFXE")) .And. !lEmpty
			Help( ,, 'Help',, STR0084, 1, 0 ) //"O campo 'Comp Fx Entr', na aba 'Outros', deve ser informado para preencher o formulário de 'Faixa de Entrega'."
			lRet := .F.
		EndIf
		//-----------------------------------------------------------------------
		If lRet .And. FwFldGet("GV9_TPLOTA") $ '2;3'
			For nI := 1 to oModelGV7:Length()
				If !oModelGV7:IsDeleted(nI) .And. lVerCota
					If Empty(FwFldGet("GV9_CFCOTA")) .And. FWFldGet("GV7_QTCOTA",nI) > 0
						lRet := .F.
						Help(,,"HELP",, "Componente para Cota Mínima deve estar preenchida quando a Cota Mínima na Faixa de Tipo de Veículo estiver informada",1,0)
						Exit
					EndIf
					If Empty(FwFldGet("GV9_CFALUG")) .And. FWFldGet("GV7_VLALUG",nI) > 0
						lRet := .F.
						Help(,,"HELP",, "Componente para Locação deve estar preenchido quando o Valor da Locação na Faixa de Tipo de Veículo estiver informado",1,0)
						Exit
					EndIf
					If Empty(FwFldGet("GV9_CFEXCD")) .And. FWFldGet("GV7_VLKMEX",nI) > 0
						lRet := .F.
						Help(,,"HELP",, "Componente para Excedente deve estar preenchido quando o Valor do Km Excedente na Faixa de Tipo de Veículo estiver informado",1,0)
						Exit
					EndIf
					If GFXCP12123("GV7_ESCOKM") 
						If  FWFldGet("GV7_QTCDED",nI) == "1" .And. FWFldGet("GV7_ESCOKM",nI) == "2"
							lRet := .F.
							Help(,,"HELP",, "Quando Qtde Cálculo for igual a: 1-por Período, Escopo Franquia não pode ser igual a: 2-Romaneio.",1,0)
							Exit
						EndIf
					EndIf
				EndIf
				If FwFldGet("GV9_TPLOTA") $ '2;3' .And. !oModelGV7:IsDeleted(nI)
					If aScan(aTpVcGV7,{|x| x == FWFldGet("GV7_CDTPVC",nI)}) == 0
						aAdd(aTpVcGV7,FWFldGet("GV7_CDTPVC",nI))
					Else
						Help(,,'HELP',, "Tipo de Veículo duplicado na Seq Faixa " + FWFldGet("GV7_CDFXTV",nI),1,0)
						lRet := .F.
						Exit
					EndIf
				EndIf
			Next nI		
		EndIf
		
		 If lVerCota .And. lRet
	    	If !lCompCota .And. !Empty(FwFldGet("GV9_CFCOTA"))
	    		 Help (,, 'Help',, "Componente Cota Miníma "+AllTrim(oModel:GetValue('GFEA061A_GV9','GV9_CFCOTA'))+" deve estar informado na tabela de componentes.",1,0)
	    		 lRet := .F.
	    	EndIf
	    	If !lCompLoca .And. !Empty(FwFldGet("GV9_CFALUG"))
	    		 Help (,, 'Help',, "Componente Locação "+AllTrim(oModel:GetValue('GFEA061A_GV9','GV9_CFALUG'))+" deve estar informado na tabela de componentes.",1,0)
	    		 lRet := .F.
	    	EndIf
	    	If !lCompExced .And. !Empty(FwFldGet("GV9_CFEXCD"))
	    		 Help (,, 'Help',, "Componente para Excedente "+AllTrim(oModel:GetValue('GFEA061A_GV9','GV9_CFEXCD'))+" deve estar informado na tabela de componentes.",1,0)
	    		 lRet := .F.
	    	EndIf
	    EndIf 
		
		//Valida se o componente de adicional de entrega está informado nos componentes de tarifa da negociação
		GV1->(dbSetOrder(01))
		GV1->(dbSeek(xFilial('GV9')+cChave))
		While !GV1->(Eof()) .And. GV1->GV1_CDEMIT == oModel:GetValue( 'GFEA061A_GV9', 'GV9_CDEMIT' ) .AND. GV1->GV1_NRTAB  == oModel:GetValue( 'GFEA061A_GV9', 'GV9_NRTAB' ) .AND. GV1->GV1_NRNEG  == oModel:GetValue( 'GFEA061A_GV9', 'GV9_NRNEG' ) 
			If GV1->GV1_CDCOMP ==  oModel:GetValue('GFEA061A_GV9','GV9_COMFXE') 
				Help( ,, 'Help',, "Componente Faixa Entrega "+ALLTRIM(oModel:GetValue('GFEA061A_GV9','GV9_COMFXE'))+" já informado nos componentes da tarifa da negociação.", 1, 0 ) 
				lRet := .F.
				Exit
			EndIf
	
			GV1->( dbSkip(1) )
		EndDo
	
		//Valida se o componente de adicional de entrega está informado nos componentes adicionais do emitente da negociação
		GUC->(dbSetOrder(01))
		GUC->(dbSeek(xFilial('GV9')+cChave))
		While !GUC->(Eof()) .And. GUC->GUC_CDEMIT == oModel:GetValue( 'GFEA061A_GV9', 'GV9_CDEMIT' ) .AND. GUC->GUC_NRTAB  == oModel:GetValue( 'GFEA061A_GV9', 'GV9_NRTAB' ) .AND. GUC->GUC_NRNEG  == oModel:GetValue( 'GFEA061A_GV9', 'GV9_NRNEG' ) 
			If GUC->GUC_CDCOMP ==  oModel:GetValue('GFEA061A_GV9','GV9_COMFXE') 
				Help( ,, 'Help',, "Componente Faixa Entrega "+ALLTRIM(oModel:GetValue('GFEA061A_GV9','GV9_COMFXE'))+" já informado nos componentes adicionais do emitente da negociação.", 1, 0 ) 
				lRet := .F.
				Exit
			EndIf
	
			GUC->( dbSkip(1) )
		EndDo
		
	ElseIf nOp == MODEL_OPERATION_DELETE
		
	   	If !(_MVAPRTAB $ "1S")
			GV6->(dbSetOrder(1))
			If GV6->(DbSeek(xFilial('GV6')+oModel:GetValue('GFEA061A_GV9','GV9_CDEMIT')+oModel:GetValue('GFEA061A_GV9','GV9_NRTAB')+oModel:GetValue('GFEA061A_GV9','GV9_NRNEG')))
		       	Help( ,, 'Help',, STR0048, 1, 0 )//"Não é possivel eliminar uma negociação com tarifas relacionadas."
				lRet := .F.
		    EndIf
		Else
			GWG->(dbSetOrder(2))
			If GWG->(dbSeek(xFilial("GWG")+GV9->GV9_CDEMIT+GV9->GV9_NRTAB+GV9->GV9_NRNEG))
				Help( ,, 'Help',, STR0049, 1, 0 )//"Não foi possível eliminar negociação a mesma já esta vinculada a um cálculo de frete."
				lRet := .F.
			Else
				GV6->(dbSetOrder(1))
				If GV6->(dbSeek(xFilial("GV6")+GV9->GV9_CDEMIT+GV9->GV9_NRTAB+GV9->GV9_NRNEG))
					While !GV6->(Eof()) .And. xFilial("GV6") == GV6->GV6_FILIAL .And. GV6->GV6_CDEMIT == GV9->GV9_CDEMIT .And. GV6->GV6_NRTAB == GV9->GV9_NRTAB .And. GV6->GV6_NRNEG == GV9->GV9_NRNEG
	
						GV1->(dbSetOrder(1))
				        GV1->(dbSeek(xFilial("GV1")+GV6->GV6_CDEMIT+GV6->GV6_NRTAB+GV6->GV6_NRNEG+GV6->GV6_CDFXTV+GV6->GV6_NRROTA))
						While !GV1->(Eof()) .And. xFilial("GV1")+GV6->GV6_CDEMIT+GV6->GV6_NRTAB+GV6->GV6_NRNEG+GV6->GV6_CDFXTV+GV6->GV6_NRROTA == GV1->GV1_FILIAL+GV1->GV1_CDEMIT+GV1->GV1_NRTAB+GV1->GV1_NRNEG+GV1->GV1_CDFXTV+GV1->GV1_NRROTA
							RecLock("GV1",.F.)
							dbDelete()
							MsUnLock("GV1")
							GV1->(dbSkip())
						EndDo
	
						GUC->(dbSetOrder(1))
				        GUC->(dbSeek(xFilial("GUC")+GV6->GV6_CDEMIT+GV6->GV6_NRTAB+GV6->GV6_NRNEG+GV6->GV6_CDFXTV+GV6->GV6_NRROTA))
						While !GUC->(Eof()) .And. xFilial("GUC")+GV6->GV6_CDEMIT+GV6->GV6_NRTAB+GV6->GV6_NRNEG+GV6->GV6_CDFXTV+GV6->GV6_NRROTA == GUC->GUC_FILIAL+GUC->GUC_CDEMIT+GUC->GUC_NRTAB+GUC->GUC_NRNEG+GUC->GUC_CDFXTV+GUC->GUC_NRROTA
							RecLock("GUC",.F.)
							dbDelete()
							MsUnLock("GUC")
							GUC->(dbSkip())
						EndDo
	
						RecLock("GV6",.F.)
						dbDelete()
						MsUnLock("GV6")
						GV6->(dbSkip())
					EndDo
				EndIf
			EndIf
		EndIf
	    if oModel:GetValue('GFEA061A_GV9','GV9_SITCON') == "4" 
	        Help( ,, 'Help',, "Não é possível eliminar negociação atualizada com a Consulta ERP.", 1, 0 )
			 lRet := .F.		    
		EndIf
	EndIf
	
	If nOp == MODEL_OPERATION_INSERT .Or. nOp == MODEL_OPERATION_UPDATE
	   If oModel:GetValue('GFEA061A_GV9','GV9_AGRSE') == '2' .And. Empty(oModel:GetValue('GFEA061A_GV9','GV9_CDTPSE'))  
	       Help(,,'HELP',,"Agrupar serviço está marcado como: 2 - Agrupar Todos. Necessário informar um tipo de serviço.", 1, 0)
	       lRet := .F.  
	   EndIf
	EndIf
	
	RestArea(aAreaGV9)
	RestArea(aArea)

Return lRet

/*/--------------------------------------------------------------------------------------------------
{Protheus.doc} GFE61GV7
Validacao do campo GV9_TPLOTA do dicionario.
Uso GFEA061A.

@sample
GFE61GV7(cCampo)

@author Felipe W.
@since 16/11/09
@version 1.0
--------------------------------------------------------------------------------------------------/*/

Function GFE61GV7()
Local lRet      := .T.
Local oModel    := FWMODELACTIVE()
Local oModelGV7 := oModel:GetModel('DETAIL_GV7')
Local nLine     := oModelGV7:GetLine()
Local nI

If oModel:GetValue( 'GFEA061A_GV9', 'GV9_TPLOTA' ) == '1'
	//Faixa da tabela de frete não pode estar cadastrada com código do emitente, número da tabela de frete, número da negociação
	// e valor final da faixa informados quando tipo de lotação da negociação for Carga Fracionada.
	For nI := 1 To oModelGV7:GetQtdLine()
		oModelGV7:GoLine( nI )

		If !Empty(FwFldGet("GV7_CDTPVC",nI))
			Help( ,, 'Help',, STR0031, 1, 0 )  //"Não é possivel mudar a negociação para 'Carga Fracionada', pois há faixas cadastradas com 'Tipo de veiculo'."
			lRet := .F.
		EndIf
	End

ElseIf oModel:GetValue( 'GFEA061A_GV9', 'GV9_TPLOTA' ) $ '2;3'
	//Faixa da tabela de frete não pode estar cadastrada com código do emitente, número da tabela de frete,
    // número da negociação e tipo de veículo informados, quando tipo de lotação da negociação for Carga Fechada.
	For nI := 1 To oModelGV7:GetQtdLine()
		oModelGV7:GoLine( nI )

		If FwFldGet("GV7_QTFXFI",nI) != 0 .OR. !Empty(FwFldGet("GV7_UNICAL",nI)) .OR. !Empty(FwFldGet("GV7_FXSOMA",nI))
			Help( ,, 'Help',, STR0032, 1, 0 )  //"Não é possivel mudar a negociação para 'Carga Fechada', pois há faixas cadastradas com 'Quantidade Final Faixa', 'Unidade Medida Calculo' ou 'Faixa a Somar'."
			lRet := .F.
		EndIf
	End
EndIf

oModelGV7:GoLine( nLine )

Return lRet

/*/--------------------------------------------------------------------------------------------------
{Protheus.doc} GFEA61AVL
Validacao dos campos GV9_DTVALI e GV9_DTVALF do dicionario.
Uso GFEA061A.

@param  cCampo        Campo para validacao, não obrigatório

@sample
GFEA61AVL(cCampo)

@author Felipe W.
@since 16/11/09
@version 1.0
--------------------------------------------------------------------------------------------------/*/

Function GFEA61AVL(cCampo)

Local aArea := GetArea()
Local lRet  := .T.

Default cCampo := ReadVar()

If "GV9_DTVALI" $ cCampo
	dbSelectArea("GV9")
	If !Empty(M->GV9_DTVALF)
		If M->GV9_DTVALF < M->GV9_DTVALI
			Help(,,'HELP',,STR0021,1,0)  //"Data Vigência De deve ser menor ou igual à Data Vigência Até."
			lRet := .F.
		EndIf
	EndIf
ElseIf "GV9_DTVALF" $ cCampo
	dbSelectArea("GV9")
	If !Empty(M->GV9_DTVALI)
		If M->GV9_DTVALF < M->GV9_DTVALI
			Help(,,'HELP',,STR0022,1,0)  //"Data Vigência Até deve ser maior ou igual à Data Vigência De."
			lRet := .F.
		EndIf
	EndIf

EndIf

RestArea(aArea)

Return lRet

/*/--------------------------------------------------------------------------------------------------
{Protheus.doc} GFE61FAI
Validacao de leave de linha do grid de Faixa Entrega Tab. Frete.
Uso GFEA061A.

@param  oModel        Objeto modelo

@sample
GFE61FAI(oModel)

@author Felipe M., Felipe W.
@since 14/10/09
@version 1.0
--------------------------------------------------------------------------------------------------/*/

Function GFE61FAI(oModel)
Local lRet := .T.
Local nI
Local nLine := oModel:getLine()
Local lFlag := .F.

For nI := 1 To oModel:Length()
	oModel:GoLine( nI )

	If oModel:getLine() ==  (nLine + 1) // Se a linha eh a posterior

		While oModel:IsDeleted()
			If (oModel:getLine() + 1) > oModel:Length()
				lFlag = .T.
				Exit
			Else
				oModel:GoLine(oModel:getLine()+1)
			EndIf
		EndDo

		If !lFlag
			If FwFldGet("GUZ_VLFXFI",nLine) >= FwFldGet("GUZ_VLFXFI",oModel:getLine())
				Help(,,'HELP',,STR0013,1,0) //"Valor da Faixa deve ser menor que o valor da faixa posterior"
				lRet := .F.
			EndIf

		EndIf

	ElseIf oModel:getLine() ==  (nLine - 1)  // Se a linha eh a anterior

		While oModel:IsDeleted()
			If (oModel:getLine() - 1) < 0
				lFlag = .T.
				Exit
			Else
				oModel:GoLine(oModel:getLine()-1)
			EndIf
		EndDo

		If !lFlag
			If FwFldGet("GUZ_VLFXFI",nLine) <= FwFldGet("GUZ_VLFXFI",oModel:getLine())
				Help(,,'HELP',,STR0014,1,0) //"Valor da Faixa deve ser maior que o valor da faixa anterior"
				lRet := .F.
			EndIf
		EndIf
	EndIf

	oModel:GoLine( nI )
Next nI

oModel:GoLine( nLine )

Return lRet

/*/--------------------------------------------------------------------------------------------------
{Protheus.doc} GFE61COM
Validacao de leave de linha do grid de Componentes.
Uso GFEA061A.

@param  oModel        Objeto modelo

@sample
GFE61COM(oModel)

@author Felipe M.
@since 14/03/10
@version 1.0
--------------------------------------------------------------------------------------------------/*/

Function GFE61COM(oModel)
Local nLine       := oModel:getLine()
Local nI
Local lRet        := .T.
Local cGUY_CDCOMP := FwFldGet("GUY_CDCOMP",nLine)
Local oModelPai   := FWMODELACTIVE()
Local lVlDir      := .F. //Variavel que indica se a negociação já possui um valor diario informado para ela.
Local cVlADir
Local cTpComp
Local lAddCpMin := .F.
Local oModelGV9 := oModelPai:GetModel("GFEA061A_GV9")

dbSelectArea("GV2")
GV2->( dbSetOrder(1) )
If GV2->( dbSeek(xFilial("GV2")+FwFldGet("GUY_CDCOMP",nLine)) )
	cTpComp := GV2->GV2_TABSUF
EndIf

For nI := 1 To oModel:GetQtdLine()
	oModel:GoLine( nI )
	If !oModel:IsDeleted()
		
		//Validação de chave duplicada
		If FwFldGet("GUY_CDCOMP",nI) == cGUY_CDCOMP .AND. nLine != nI
			Help( ,, 'Help',, STR0033, 1, 0 )  //"O componente já está cadastrado."
			lRet := .F.
		EndIf
		//Componente da tabela de frete que não faça parte do total do frete, não pode fazer parte de base de calculo de imposto ou ser usado para comparação com frete mínimo.
		If FwFldGet("GUY_TOTFRE",nI) == '2' .AND. (FwFldGet("GUY_BASIMP",nI) == '1' .OR. FwFldGet("GUY_BAPICO",nI) == '1' .OR. FwFldGet("GUY_FREMIN",nI) == '1' )
			Help( ,, 'Help',, STR0034, 1, 0 )  //"Registro não será utilizado para o total de frete. Os campos 'Base Imposto', 'Base PIS/COF' e 'Frete Minimo' devem estar como 'Não'."
			lRet := .F.
		EndIf
		//Componente deve estar cadastrado na tabela de componente de frete
		If !ExistCpo("GV2",FwFldGet("GUY_CDCOMP",nI))
			Help( ,, 'Help',, STR0035, 1, 0 )  //"Componente não está cadastrado na rotina de Componentes de Frete."
			lRet := .F.
		EndIf

		dbSelectArea("GV2")
		GV2->( dbSetOrder(1) )
		If GV2->( dbSeek(xFilial("GV2")+FwFldGet("GUY_CDCOMP",nI)) )
			If GV2->GV2_TABSUF $ "23" .And. cTpComp $ "23" .And. nLine != nI
				Help( ,, 'Help',, STR0067, 1, 0 )  //"Componente para taxa Suframa não pode possuir outro já relacionado."
				lRet := .F.
			EndIf
		EndIf

		cVlADir := Posicione("GV2",1,xFilial("GV2")+FwFldGet("GUY_CDCOMP",nI),"GV2_VLDIAR")

		If lVlDir == .T. .And. cVlADir == "1"
			Help( ,, 'Help',, STR0043, 1, 0 )  //"Já existe um componente com valor diário informado para está negociação."
			lRet := .F.
		EndIf

		If cVlADir == "1"
			lVlDir := .T.
		EndIf
		
		If !lAddCpMin .And. lRet
			If Empty(oModelGV9:GetValue("GV9_COMMIN"))
				oModelGV9:SetValue("GV9_COMMIN",FwFldGet("GUY_CDCOMP",nI))
			EndIf			
			lAddCpMin := .T.
		EndIf
	EndIf
End

//Salva os campos 'GV7_CDEMIT','GV7_NRTAB', 'GV7_NRNEG' com as informações da negociação
If lRet
	oModel:LoadValue('GUY_CDEMIT',GVA->GVA_CDEMIT)

	oModel:LoadValue('GUY_NRTAB',GVA->GVA_NRTAB)

	oModel:LoadValue('GUY_NRNEG',oModelPai:GetValue( 'GFEA061A_GV9', 'GV9_NRNEG' ))

EndIf
Return lRet

/*/--------------------------------------------------------------------------------------------------
{Protheus.doc} GFE61COE
Validacao de exclusão do grid de Componentes.
Uso GFEA061A.

@sample
GFE61COE(oX,Line,Acao)

@author Felipe M.
@since 14/03/10
@version 1.0
--------------------------------------------------------------------------------------------------/*/

Function GFEA61ACOE(oX,Line,Acao,Campo,Valor)
Local lRet := .T.
Local cCdComp := ""
Local cCdAnt
Local nX
Local oModel := FwModelActive()
Local oModelGV9 := oModel:GetModel('GFEA061A_GV9')

If Acao == 'DELETE'

//Componente da tabela de frete não pode estar em uso em tarifas da tabela de frete.

	cAliasQry := GetNextAlias()
	cQuery := " SELECT COUNT(*) AS QTD FROM "+RetSQLName("GV1")
	cQuery += " WHERE GV1_CDEMIT = '"+FwFldGet("GUY_CDEMIT",Line)+"'"
	cQuery += " AND GV1_NRTAB = '"+FwFldGet("GUY_NRTAB",Line)+"'"
	cQuery += " AND GV1_NRNEG = '"+FwFldGet("GUY_NRNEG",Line)+"'"
	cQuery += " AND GV1_CDCOMP = '"+FwFldGet("GUY_CDCOMP",Line)+"'"
	cQuery += " AND D_E_L_E_T_ = ' '"

	cQuery := ChangeQuery(cQuery)
	dbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery),cAliasQry, .F., .T.)

	If (cAliasQry)->QTD > 0
		Help(,,'HELP',,STR0051,1,0) //"O componente selecionado está em uso como componente da tarifa de frete."
		lRet := .F.
	EndIf

	(cAliasQry)->(dbCloseArea())
	If lRet
		For nX := 1 To oX:GetQtdLine()
			If nX != Line .And. !oX:IsDeleted(nX)
				cCdComp := oX:GetValue("GUY_CDCOMP",nX)
				If !Empty(cCdComp) .And. oModelGV9:GetValue("GV9_COMMIN") == oX:GetValue("GUY_CDCOMP",Line)
					oModelGV9:SetValue("GV9_COMMIN",cCdComp)
					Exit
				EndIf
			EndIf
		Next nX
		If Empty(cCdComp)
			oModelGV9:ClearField("GV9_COMMIN")
			oModelGV9:ClearField("GV9_DSCOMN")
		EndIf
	EndIf
ElseIf Acao == 'SETVALUE' .Or. Acao == 'UNDELETE'
	
	If Campo == 'GUY_CDCOMP' .Or. Acao == 'UNDELETE'
		
		cCdAnt := oModelGV9:GetValue("GV9_COMMIN")
		
		For nX := 1 To oX:GetQtdLine()
			If (!oX:IsDeleted(nX) .And. nX != Line) .Or. (Acao == 'UNDELETE' .And. nX == Line)
				cCdComp := oX:GetValue("GUY_CDCOMP",nX)
				If cCdAnt == cCdComp
					Exit
				EndIf
			EndIf
		Next nX
		
		If cCdAnt != cCdComp .And. !Empty(cCdComp)
			oModelGV9:SetValue("GV9_COMMIN",cCdComp)
		ElseIf (Empty(cCdAnt) .And. Empty(cCdComp)) .Or. cCdAnt != cCdComp 
			oModelGV9:SetValue("GV9_COMMIN",Valor)
		ElseIf Empty(cCdComp)
			oModelGV9:ClearField("GV9_COMMIN")
			oModelGV9:ClearField("GV9_DSCOMN")
		EndIf

	EndIf

EndIf

Return lRet

/*/--------------------------------------------------------------------------------------------------
{Protheus.doc} GFE61ROT
Validacao de leave de linha do grid de rotas.
Uso GFEA061A.

@param  oModel        Objeto modelo

@sample
GFE61ROT(oModel)

@author Felipe M.
@since 14/03/10
@version 1.0
--------------------------------------------------------------------------------------------------/*/

Function GFE61ROT(oModel)
Local lRet := .T.
Local nLine := oModel:getLine()
Local nI
Local cGV8_TPORIG := FwFldGet("GV8_TPORIG",nLine)
Local cGV8_TPDEST := FwFldGet("GV8_TPDEST",nLine)
Local cGV8_NRCIOR := FwFldGet("GV8_NRCIOR",nLine)
Local cGV8_DSTORI := FwFldGet("GV8_DSTORI",nLine)
Local cGV8_DSTORF := FwFldGet("GV8_DSTORF",nLine)
Local cGV8_NRREOR := FwFldGet("GV8_NRREOR",nLine)
Local cGV8_CDPAOR := FwFldGet("GV8_CDPAOR",nLine)
Local cGV8_CDUFOR := FwFldGet("GV8_CDUFOR",nLine)
Local cGV8_CDREM  := FwFldGet("GV8_CDREM" ,nLine)
Local cGV8_NRCIDS := FwFldGet("GV8_NRCIDS",nLine)
Local cGV8_DSTDEI := FwFldGet("GV8_DSTDEI",nLine)
Local cGV8_DSTDEF := FwFldGet("GV8_DSTDEF",nLine)
Local cGV8_NRREDS := FwFldGet("GV8_NRREDS",nLine)
Local cGV8_CDPADS := FwFldGet("GV8_CDPADS",nLine)
Local cGV8_CDUFDS := FwFldGet("GV8_CDUFDS",nLine)
Local cGV8_CDDEST := FwFldGet("GV8_CDDEST",nLine)

//Verifica o tipo de origem e se o campo correspondente está em branco
If FwFldGet("GV8_TPORIG",nLine) == '1' .AND. Empty(FwFldGet("GV8_NRCIOR",nLine))
	Help(,,'HELP',,STR0052,1,0) //"O campo Cidade Origem está em branco."
	Return .F.
ElseIf FwFldGet("GV8_TPORIG",nLine) == '2' .AND. FwFldGet('GV8_DSTORI',nLine) > FwFldGet('GV8_DSTORF',nLine)
	//Distância Origem Inicial deve ser menor ou igual à Distância Origem Final.
	Help(,,'HELP',,STR0053,1,0)//"Distância Origem Inicial deve ser menor ou igual à Distância Origem Final."
	Return .F.
ElseIf FwFldGet("GV8_TPORIG",nLine) == '3' .AND. Empty(FwFldGet("GV8_NRREOR",nLine))
	Help(,,'HELP',,STR0054,1,0)//  "O campo Regiao Origem está em branco."
	Return .F.
ElseIf FwFldGet("GV8_TPORIG",nLine) == '4' .AND. (Empty(FwFldGet("GV8_CDPAOR",nLine)) .OR. Empty(FwFldGet("GV8_CDUFOR",nLine)))
	Help(,,'HELP',,STR0055,1,0)//"O campo Codigo Pais Origem ou Estado (UF) Origem está em branco."
	Return .F.
ElseIf FwFldGet("GV8_TPORIG",nLine) == '5' .AND. Empty(FwFldGet("GV8_CDREM",nLine))
	Help(,,'HELP',,STR0086,1,0) //"O campo Código Remetente está em branco"
	Return .F.
EndIf

//Verifica o tipo de destino e se o campo correspondente está em branco
If FwFldGet("GV8_TPDEST",nLine) == '1' .AND. Empty(FwFldGet("GV8_NRCIDS",nLine)) .AND. FwFldGet("GV8_TPORIG",nLine) != '2'
	Help(,,'HELP',,STR0057,1,0)//"O campo Cidade Destino está em branco."
	Return .F.
ElseIf FwFldGet("GV8_TPDEST",nLine) == '2' .AND. FwFldGet('GV8_DSTDEI',nLine) > FwFldGet('GV8_DSTDEF',nLine)
	//Distância Destino Inicial deve ser menor ou igual à Distância Destino Final
	Help(,,'HELP',,STR0058,1,0)//"Distância Destino Inicial deve ser menor ou igual à Distância Destino Final."
	Return .F.
ElseIf FwFldGet("GV8_TPDEST",nLine) == '3' .AND. Empty(FwFldGet("GV8_NRREDS",nLine)) .AND. FwFldGet("GV8_TPORIG",nLine) != '2'
	Help(,,'HELP',,STR0059,1,0) //"O campo Regiao Destino está em branco."
	Return .F.
ElseIf FwFldGet("GV8_TPDEST",nLine) == '4' .AND. (Empty(FwFldGet("GV8_CDPADS",nLine)) .OR. Empty(FwFldGet("GV8_CDUFDS",nLine))) .AND. FwFldGet("GV8_TPORIG",nLine) != '2'
	Help(,,'HELP',,STR0060,1,0)//"O campo Codigo Pais Destino ou Estado (UF) Destino está em branco."
	Return .F.
ElseIf FwFldGet("GV8_TPDEST",nLine) == '5' .AND. Empty(FwFldGet("GV8_CDDEST",nLine)) .AND. FwFldGet("GV8_TPORIG",nLine) != '2'
	Help(,,'HELP',,STR0087,1,0) //"O campo Código Destinatario está em branco"
	Return .F.
EndIf

//varre o grid na busca de um registro duplicado
For nI := 1 To oModel:GetQtdLine()
	
	oModel:GoLine( nI )
	//Verifica se os registros possuem o mesmos tipo de origem , destino e a linha é diferente
	If FwFldGet("GV8_TPORIG",nI) == cGV8_TPORIG .AND. FwFldGet("GV8_TPDEST",nI) == cGV8_TPDEST .AND. nLine != nI .And. !oModel:IsDeleted()
	

		If cGV8_NRCIOR == FwFldGet("GV8_NRCIOR",nI) .AND. ; //verifica se os dados da origem são iguais
			cGV8_DSTORI == FwFldGet("GV8_DSTORI",nI) .AND.   ;
			cGV8_DSTORF == FwFldGet("GV8_DSTORF",nI) .AND.   ;
			cGV8_NRREOR == FwFldGet("GV8_NRREOR",nI) .AND.   ;
			cGV8_CDPAOR == FwFldGet("GV8_CDPAOR",nI) .AND.   ;
			cGV8_CDUFOR == FwFldGet("GV8_CDUFOR",nI) .AND.   ;
			cGV8_CDREM  == FwFldGet("GV8_CDREM" ,nI) .AND.   ;
			cGV8_NRCIDS == FwFldGet("GV8_NRCIDS",nI) .AND.   ; //verifica se os dados do destino são iguais
			cGV8_DSTDEI == FwFldGet("GV8_DSTDEI",nI) .AND.   ;
			cGV8_DSTDEF == FwFldGet("GV8_DSTDEF",nI) .AND.   ;
			cGV8_NRREDS == FwFldGet("GV8_NRREDS",nI) .AND.   ;
			cGV8_CDPADS == FwFldGet("GV8_CDPADS",nI) .AND.   ;
			cGV8_CDUFDS == FwFldGet("GV8_CDUFDS",nI) .AND.   ;
			cGV8_CDDEST == FwFldGet("GV8_CDDEST",nI)
			
			Help(,,'HELP',,STR0062,1,0) //"Rota já cadastrada"
			Return .F.
		EndIf
	
	EndIf
Next nI

oModel:GoLine( nLine ) //Posiciona na mesma linha novamente

Return lRet

/*/--------------------------------------------------------------------------------------------------
{Protheus.doc} GFE61ROW
Validacao de dicionario dos campos descritos abaixo.
Uso GFEA061A.

Validação do When do dicionario. Segue os campos da validação:

GV8_NRCIOR, GV8_DSTORI, GV8_DSTORF, GV8_NRREOR, GV8_CDPAOR, GV8_CDUFOR, GV8_CDREM,
GV8_NRCIDS, GV8_DSTDEI, GV8_DSTDEF, GV8_NRREDS, GV8_CDPADS, GV8_CDUFDS, GV8_CDDEST

@sample
GFE61ROW()

@author Felipe M.
@since 14/03/10
@version 1.0
--------------------------------------------------------------------------------------------------/*/

Function GFE61ROW()
Local lRet := .F.
Local cCampo := ReadVar()

//Verifica a habilitação do campo dependendo do tipo de origem e destino
If "GV8_NRCIOR" $ cCampo .AND. FwFldGet("GV8_TPORIG") == '1'
	lRet := .T.
ElseIf "GV8_DSTORI" $ cCampo .AND. FwFldGet("GV8_TPORIG") == '2'
	lRet := .T.
ElseIf "GV8_DSTORF" $ cCampo .AND. FwFldGet("GV8_TPORIG") == '2'
	lRet := .T.
ElseIf "GV8_NRREOR" $ cCampo .AND. FwFldGet("GV8_TPORIG") == '3'
	lRet := .T.
ElseIf "GV8_CDPAOR" $ cCampo .AND. FwFldGet("GV8_TPORIG") == '4'
	lRet := .T.
ElseIf "GV8_CDUFOR" $ cCampo .AND. FwFldGet("GV8_TPORIG") == '4'
	lRet := .T.
ElseIf "GV8_CDREM"  $ cCampo .AND. FwFldGet("GV8_TPORIG") == '5'
	lRet := .T.
ElseIf "GV8_NRCIDS" $ cCampo .AND. FwFldGet("GV8_TPORIG") <> '2' .AND. FwFldGet("GV8_TPDEST") == '1'
	lRet := .T.
ElseIf "GV8_DSTDEI" $ cCampo .AND. FwFldGet("GV8_TPORIG") <> '2' .AND. FwFldGet("GV8_TPDEST") == '2'
	lRet := .T.
ElseIf "GV8_DSTDEF" $ cCampo .AND. FwFldGet("GV8_TPORIG") <> '2' .AND. FwFldGet("GV8_TPDEST") == '2'
	lRet := .T.
ElseIf "GV8_NRREDS" $ cCampo .AND. FwFldGet("GV8_TPORIG") <> '2' .AND. FwFldGet("GV8_TPDEST") == '3'
	lRet := .T.
ElseIf "GV8_CDPADS" $ cCampo .AND. FwFldGet("GV8_TPORIG") <> '2' .AND. FwFldGet("GV8_TPDEST") == '4'
	lRet := .T.
ElseIf "GV8_CDUFDS" $ cCampo .AND. FwFldGet("GV8_TPORIG") <> '2' .AND. FwFldGet("GV8_TPDEST") == '4'
	lRet := .T.
ElseIf "GV8_CDDEST" $ cCampo .AND. FwFldGet("GV8_TPORIG") <> '2' .AND. FwFldGet("GV8_TPDEST") == '5'
	lRet := .T.
EndIf

Return lRet

/*/--------------------------------------------------------------------------------------------------
{Protheus.doc} GFE61ROTO
Validação do Tipo de origem e Tipo Destino no Dic (GV8_TPORIG e GV8_TPDEST).
Uso GFEA061A.

@sample
GFE61ROTO()

@author Felipe M.
@since 14/03/10
@version 1.0
--------------------------------------------------------------------------------------------------/*/

Function GFE61ROTO()
Local lRet := .T.
Local oModel := FWMODELACTIVE()
Local oModelGV8 := oModel:GetModel('DETAIL_GV8')
Local cCampo := ReadVar()

If "GV8_TPORIG" $ cCampo

	//Limpa os campos quando o usuario muda de opção
	//Cidade Origem
	oModelGV8:ClearField('GV8_NRCIOR')
	//Descrição Cidade Origem
	oModelGV8:ClearField('GV8_DSCIOR')
	//Distancia Origem Inicial
	oModelGV8:ClearField('GV8_DSTORI')
	//Distancia Origem Final
	oModelGV8:ClearField('GV8_DSTORF')
	//Regiao Origem
	oModelGV8:ClearField('GV8_NRREOR')
	//Descrição Regiao Origem
	oModelGV8:ClearField('GV8_DSREOR')
	//Codigo Pais Origem
	oModelGV8:ClearField('GV8_CDPAOR')
	//Descrição Pais Origem
	oModelGV8:ClearField('GV8_DSPAOR')
	//Estado (UF) Origem
	oModelGV8:ClearField('GV8_CDUFOR')
	//Filial Origem
	oModelGV8:ClearField('GV8_CDREM')

	If FwFldGet("GV8_TPORIG") == '2' .And. FwFldGet("GV8_TPDEST") != '2'
		oModelGV8:SetValue("GV8_TPDEST", "2")
	EndIf

ElseIf "GV8_TPDEST" $ cCampo .AND. FwFldGet("GV8_TPORIG") <> '2'

	//Limpa os campos quando o usuario muda de opção
	//Cidade Destino
	oModelGV8:ClearField('GV8_NRCIDS')
	//Descrição Cidade Destino
	oModelGV8:ClearField('GV8_DSCIDS')
	//Distancia Destino Inicial
	oModelGV8:ClearField('GV8_DSTDEI')
	//Distancia Destino Final
	oModelGV8:ClearField('GV8_DSTDEF')
	//Regiao Destino
	oModelGV8:ClearField('GV8_NRREDS')
	//Descrição Regiao Destino
	oModelGV8:ClearField('GV8_DSREDS')
	//Codigo Pais Destino
	oModelGV8:ClearField('GV8_CDPADS')
	//Descrição Pais Destino
	oModelGV8:ClearField('GV8_DSPADS')
	//Estado (UF) Destino
	oModelGV8:ClearField('GV8_CDUFDS')
	//Filial Destino
	oModelGV8:ClearField('GV8_CDDEST')

ElseIf "GV8_TPDEST" $ cCampo .AND. FwFldGet("GV8_TPORIG") == '2'
	lRet := .F.
EndIf

Return lRet

/*/--------------------------------------------------------------------------------------------------
{Protheus.doc} GFE61FTE
Validacao de exclusão do grid de Faixa\Tipo de veiculo.
Uso GFEA061A.

@param  oModel        Objeto modelo

@sample
GFE61FTE(oX,Line,Acao)

@author Felipe M.
@since 14/03/10
@version 1.0
--------------------------------------------------------------------------------------------------/*/

Function GFEA61AFTE(oX,Line,Acao)

If Acao == 'DELETE'

	cAliasQry := GetNextAlias()
	cQuery := " SELECT COUNT(*) AS QTD FROM "+RetSQLName("GWG")
	cQuery += " WHERE GWG_CDEMIT = '"+FwFldGet("GV7_CDEMIT",Line)+"'"
	cQuery += " AND GWG_NRTAB    = '"+FwFldGet("GV7_NRTAB",Line)+"'"
	cQuery += " AND GWG_NRNEG    = '"+FwFldGet("GV7_NRNEG",Line)+"'"
	cQuery += " AND GWG_CDFXTV   = '"+FwFldGet("GV7_CDFXTV",Line)+"'"
	cQuery += " AND D_E_L_E_T_ = ' '"

	cQuery := ChangeQuery(cQuery)
	dbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery),cAliasQry, .F., .T.)

	If (cAliasQry)->QTD > 0
		Help(,,'HELP',,STR0063,1,0)//"A Faixa selecionada está em uso em um pré-cálculo"
		(cAliasQry)->(dbCloseArea())
		Return .F.
	EndIf

	(cAliasQry)->(dbCloseArea())

	dbSelectArea("GV6")
	GV6->( dbSetOrder(1) )
	GV6->( dbSeek(xFilial("GV6") + FwFldGet("GV7_CDEMIT",Line) + FwFldGet("GV7_NRTAB",Line) + FwFldGet("GV7_NRNEG",Line)) )
	While !GV6->( Eof() ) .And. GV6->GV6_FILIAL == xFilial("GV6") .And. GV6->GV6_CDEMIT == FwFldGet("GV7_CDEMIT",Line) ;
		  .And. GV6->GV6_NRTAB == FwFldGet("GV7_NRTAB",Line) .And. GV6->GV6_NRNEG == FwFldGet("GV7_NRNEG",Line)

		If GV6->GV6_CDFXTV == FwFldGet("GV7_CDFXTV",Line)
			Help(,,'HELP',,"A Faixa por Tipo de Veículo está relacionada à uma Tarifa, portanto, não poderá ser excluída.",1,0) //"A Faixa por Tipo de Veículo está relacionada à uma Tarifa, portanto, não poderá ser excluída."
			Return .F.
		EndIf

		dbSelectArea("GV6")
		GV6->( dbSkip() )
	EndDo

EndIf

Return .T.

/*/--------------------------------------------------------------------------------------------------
{Protheus.doc} GFE61ROE
Validacao de exclusão do grid de Rotas.
Uso GFEA061A.

@sample
GFE61ROE(oX,Line,Acao)

@author Felipe M.
@since 14/03/10
@version 1.0
--------------------------------------------------------------------------------------------------/*/

Function GFEA61AROE(oX,Line,Acao)

If Acao == 'DELETE'

	cAliasQry := GetNextAlias()
	cQuery := " SELECT COUNT(*) AS QTD FROM "+RetSQLName("GWG")
	cQuery += " WHERE GWG_CDEMIT = '"+FwFldGet("GV8_CDEMIT",Line)+"'"
	cQuery += " AND GWG_NRTAB    = '"+FwFldGet("GV8_NRTAB",Line)+"'"
	cQuery += " AND GWG_NRNEG    = '"+FwFldGet("GV8_NRNEG",Line)+"'"
	cQuery += " AND GWG_NRROTA   = '"+FwFldGet("GV8_NRROTA",Line)+"'"
	cQuery += " AND D_E_L_E_T_ = ' '"

	cQuery := ChangeQuery(cQuery)
	dbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery),cAliasQry, .F., .T.)

	If (cAliasQry)->QTD > 0
		Help(,,'HELP',,STR0064,1,0)//"A Rota selecionada está em uso em um pré-cálculo"
		(cAliasQry)->(dbCloseArea())
		Return .F.
	EndIf

	(cAliasQry)->(dbCloseArea())

	dbSelectArea("GV6")
	GV6->( dbSetOrder(1) )
	GV6->( dbSeek(xFilial("GV6") + FwFldGet("GV8_CDEMIT",Line) + FwFldGet("GV8_NRTAB",Line) + FwFldGet("GV8_NRNEG",Line)) )
	While !GV6->( Eof() ) .And. GV6->GV6_FILIAL == xFilial("GV6") .And. GV6->GV6_CDEMIT == FwFldGet("GV8_CDEMIT",Line) ;
		  .And. GV6->GV6_NRTAB == FwFldGet("GV8_NRTAB",Line) .And. GV6->GV6_NRNEG == FwFldGet("GV8_NRNEG",Line)

		If GV6->GV6_NRROTA == FwFldGet("GV8_NRROTA",Line)
			Help(,,'HELP',,"A Rota está relacionada à uma Tarifa, portanto, não poderá ser excluída.",1,0) //"A Rota está relacionada à uma Tarifa, portanto, não poderá ser excluída."
			Return .F.
		EndIf

		dbSelectArea("GV6")
		GV6->( dbSkip() )
	EndDo

EndIf

Return .T.

/*/--------------------------------------------------------------------------------------------------
{Protheus.doc} GFE61FTV
Validacao de leave de linha do grid de Faixa\Tipo de veiculo.
Uso GFEA061A.

@param  oModel        Objeto modelo

@sample
GFE61FT(oModel)

@author Felipe M.
@since 14/03/10
@version 1.0
--------------------------------------------------------------------------------------------------/*/

Function GFE61FTV(oModel)
Local lRet  := .T.,	lFxSoma := .F.
Local nLine := oModel:getLine()
Local nFXSOMA, nQTFXFI, nI := oModel:GetQtdLine(), nCont
Local oModelPai := FWMODELACTIVE()
Local aSaveLines := FWSaveRows()

If oModelPai:GetValue( 'GFEA061A_GV9', 'GV9_TPLOTA' ) $ '2;3'
	//Tipo de veículo, quando informado, deve estar cadastrado na tabela de tipo de veículo
	If !Empty(FwFldGet("GV7_CDTPVC",nLine))
		If !ExistCpo("GV3",FwFldGet("GV7_CDTPVC",nLine))
			Help( ,, 'Help',, STR0036, 1, 0 ) //"O veículo informado não está cadastrado no sistema."
			lRet := .F.
		EndIf
	EndIf

ElseIf oModelPai:GetValue( 'GFEA061A_GV9', 'GV9_TPLOTA' ) == '1'

	// valida se o campo quantidade final é menor que o posterior e maior q o anterior
	nQTFXFI := FwFldGet("GV7_QTFXFI",nLine)
	For nCont := 1 To oModel:GetQtdLine()
		oModel:GoLine(nCont)

		If !oModel:IsDeleted()
			//Quantidade Final Faixa não deve ser menor que a anterior
			If (nCont == nLine - 1 .And. nLine > 1) .And. nQTFXFI <= FwFldGet("GV7_QTFXFI",nCont)
				Help( ,, 'Help',, STR0037, 1, 0 ) //"Quantidade Final Faixa deve ser maior que a anterior"
				lRet := .F.
			EndIf
			If (nCont == nLine + 1 .And. nLine < oModel:GetQtdLine() ) .And. nQTFXFI >= FwFldGet("GV7_QTFXFI",nCont)
				Help( ,, 'Help',, STR0038, 1, 0 ) //"Quantidade Final Faixa deve ser menor que a posterior"
				lRet := .F.
			EndIf
		EndIf
	End

	//Unidade de medida para cálculo deve estar cadastrada no cadastro de unidades de medida.
	If !ExistCpo("SAH",FwFldGet("GV7_UNICAL",nLine))
		Help( ,, 'Help',, STR0039, 1, 0 ) //"A unidade de medida não foi informado."
		lRet := .F.
	EndIf

	//O registro da Faixa Soma não deve ser a mesma da Seq Faixa
	If VAL(FwFldGet("GV7_FXSOMA",nLine)) == VAL(FwFldGet("GV7_CDFXTV",nLine))
		Help( ,, 'Help',, STR0040, 1, 0 ) //"O registro da Faixa Soma não deve ser a mesma da Seq Faixa"
		lRet := .F.
	//O registro da Faixa Soma não deve ser maior que a Seq Faixa
	ElseIf VAL(FwFldGet("GV7_FXSOMA",nLine)) > VAL(FwFldGet("GV7_CDFXTV",nLine))
		Help( ,, 'Help',, STR0041, 1, 0 ) //"O registro da Faixa Soma não deve ser maior que a Seq Faixa"
		lRet := .F.

	ElseIf nLine != 1
	//Faixa para soma informada deve estar cadastrada entre as faixas da negociação da tabela de frete.
		nFXSOMA := FwFldGet("GV7_FXSOMA",nLine)
		While nI > 0
			oModel:GoLine( nI )

			//Faz a verificação caso a faixa soma do registro atual (nFXSOMA) não seja vazia
			If !Empty(nFXSOMA)
				lFxSoma := If(FwFldGet("GV7_CDFXTV",nI) == nFXSOMA ,.T.,lFxSoma)
			EndIf

			nI := nI -1
		EndDo
		//Caso a Flag lFxSoma for falsa (o que indica que não encontrou o registro referenciado) e o campo Faixa soma do registro atual não for nulo
		If !lFxSoma .And. !Empty(nFXSOMA)
			Help( ,, 'Help',, STR0042, 1, 0 ) //"Faixa soma inexistente"
			lRet := .F.
		EndIf

		oModel:GoLine( nLine )

	EndIf
EndIf

//Salva os campos 'GV7_CDEMIT','GV7_NRTAB', 'GV7_NRNEG' com as informações da negociação
If lRet
	oModel:LoadValue('GV7_CDEMIT',GVA->GVA_CDEMIT)

	oModel:LoadValue('GV7_NRTAB',GVA->GVA_NRTAB)

	oModel:LoadValue('GV7_NRNEG',oModelPai:GetValue( 'GFEA061A_GV9', 'GV9_NRNEG' ))

EndIf

FWRestRows( aSaveLines )

Return lRet

//----------------------------------------------------------------------------------------------------------------------------------------------------

Function GFEGV7F3(cCampo)

//Adicionar validação caso haja necessidade
GFEGV7Fld(cCampo)

Return( .T. )

//------------------------------------------------------------------------------------------------------------ */

Function GFEGV7Fld(cCampo)

Local aAreaGV7 := GV7->( GetArea() )
Local aRet     := {}
Local cTitulo  := ''
Local lRet     := .F.
Local nItem    := 0
Local cChave

cChave := GV7->GV7_CDEMIT
cChave += GV7->GV7_NRTAB
cChave += GV7->GV7_NRNEG
cChave += GV7->GV7_CDFXTV

Default cCampo := ReadVar()

dbSelectArea("GV7")
dbGoTop()
While !Eof()

	If 'FXSOMA' $ Upper( cCampo ) .AND. (GV7->GV7_CDEMIT + GV7->GV7_NRTAB + GV7->GV7_NRNEG + GV7->GV7_CDFXTV != cChave)

		lRet := .T.
		AAdd( aRet, {GV7->GV7_CDEMIT, GV7->GV7_NRTAB, GV7->GV7_NRNEG, GV7->GV7_CDFXTV, GV7->GV7_QTFXFI })

	EndIf
	GV7->(dbSkip())
EndDo

//-- Apresenta a tela para selecao do item.
If lRet
	nItem := TmsF3Array( {STR0088,STR0089,STR0090,STR0091,STR0073}, aRet, cTitulo ) //"Emitente" ### "Tabela" ### "Negociação" ### "Seq Faixa" ### "Qtde. Final"
	//"Emitente"##"Tabela"##"Negociação"##"Seq Faixa"##"Qtde. Final"
	If nItem > 0
		//-- VAR_IXB eh utilizada como retorno da consulta F3 DLC.
		VAR_IXB := aRet[ nItem, 4 ]
	EndIf
EndIf

RestArea(aAreaGV7)
Return .T.

//-----------------------------------------------

Function GFEALPMTV(cCdEmit,nNrTab)
Local aAreaGV9 := GV9->( GetArea() )

	dbSelectArea("GV9")
	dbSetOrder(1)
	dbSeek(xFilial("GV9")+cCdEmit+nNrTab)
	While !Eof() .And. xFilial("GV9") == GV9->GV9_FILIAL .And. GV9->GV9_CDEMIT == cCdEmit .And. GV9->GV9_NRTAB == nNrTab
		dbSelectArea("GVA")
		dbSetOrder(1)
		If dbSeek(xFilial("GVA")+GV9->GV9_CDEMIT+GV9->GV9_NRTAB)
			RecLock("GVA",.F.)
			GVA->GVA_MTVRPR := ""
			MsUnLock("GVA")
		EndIf
		RecLock("GV9",.F.)
		GV9->GV9_MTVRPR := ""
		MsUnLock("GV9")
		dbSelectArea("GV9")
		dbSkip()
	EndDo

RestArea(aAreaGV9)

Return .T.

/*/--------------------------------------------------------------------------------------------------
{Protheus.doc} RetCdEmit
Retorna o Código do Emitente do programa chamador (GFEA064 ou GFEA061)

@author ?
@since 12/08/10
@version 1.0
@version 1.1 - Israel A. Possoli
Movido do programa GFEA064 para o GFEA061A
--------------------------------------------------------------------------------------------------/*/

Function GFEA61ACEM() //Antiga: RetCdEmit
Local lRet := ""

	If IsInCallStack("GFEA064") .Or. IsInCallStack("GFEC061")
		lRet := GV9->GV9_CDEMIT
	Else
		// Busca na Tabela de Frete o Código do Emitente
		lRet := GFE61CdEmi()
	EndIf

Return lRet

/*/--------------------------------------------------------------------------------------------------
{Protheus.doc} RetDsEmit
Retorna a Descrição do Emitente do programa chamador (GFEA064 ou GFEA061)

@author ?
@since 12/08/10
@version 1.0
@version 1.1 - Israel A. Possoli
Movido do programa GFEA064 para o GFEA061A
--------------------------------------------------------------------------------------------------/*/

Function GFEA61ANEM() //Antiga: RetDsEmit
Local lRet := ""

	If IsInCallStack("GFEA064") .Or. IsInCallStack("GFEC061")
		lRet := POSICIONE("GU3",1,XFILIAL("GU3")+GV9->GV9_CDEMIT,"GU3_NMEMIT")
	Else
		lRet := POSICIONE("GU3",1,XFILIAL("GU3")+GFE61CdEmi(),"GU3_NMEMIT")
	EndIf

Return lRet

/*/--------------------------------------------------------------------------------------------------
{Protheus.doc} RetCdNrtb
Retorna a Descrição do Emitente do programa chamador (GFEA064 ou GFEA061)

@author ?
@since 12/08/10
@version 1.0
@version 1.1 - Israel A. Possoli
Movido do programa GFEA064 para o GFEA061A
--------------------------------------------------------------------------------------------------/*/

Function GFEA61ANTB() //Antiga: RetCdNrtb
Local lRet := ""

	If IsInCallStack("GFEA064") .Or. IsInCallStack("GFEC061")
		lRet := GV9->GV9_NRTAB
	Else
		lRet := GFE61NrTab()
	EndIf

Return lRet

/*/--------------------------------------------------------------------------------------------------
{Protheus.doc} RetDsNrtb
Retorna a Descrição do Emitente do programa chamador (GFEA064 ou GFEA061)

@author ?
@since 12/08/10
@version 1.0
@version 1.1 - Israel A. Possoli
Movido do programa GFEA064 para o GFEA061A
--------------------------------------------------------------------------------------------------/*/

Function GFEA61ADTB() //Antiga: RetDsNrtb
Local lRet := ""

	If IsInCallStack("GFEA064") .Or. IsInCallStack("GFEC061")
		lRet := POSICIONE("GVA",1,XFILIAL("GVA")+GV9->GV9_CDEMIT+GV9->GV9_NRTAB,"GVA_DSTAB")
	Else
		lRet := POSICIONE("GVA",1,XFILIAL("GVA")+GFE61CdEmi()+GFE61NrTab(),"GVA_DSTAB")
	EndIf

Return lRet

/*---------------------------------------------------------------------------------------------------
{Protheus.doc} GFEA061A
Função para verificar o componente de entrega se já não consta nas tarifas relacionadas.

@sample
GFEA061A()

@author Octávio Augusto Felippe de Macedo
@since 18/01/2011
@version 1.0
----------------------------------------------------------------------------------------------------*/

Static Function GFEA61AVLC()

If !( ExistCpo("GV2",M->GV9_COMFXE) .Or. Empty(M->GV9_COMFXE) )
	Help( ,, 'Help',, STR0035, 1, 0 )
	Return .F.
EndIf

Return .T.

/*---------------------------------------------------------------------------------------------------
{Protheus.doc} GFEA61AENV
Função para enviar a negociação para aprovação.

@sample
GFEA61AENV()

@author Octávio Augusto Felippe de Macedo
@since 24/01/2011
@version 1.0
----------------------------------------------------------------------------------------------------*/
Function GFEA61AENV()
	Local cAssunto := STR0074
	Local cMensagem
	Local aRetMail
	Local lEmail := .F.
	// Quando realiza integração com Datasul + aprovação da tabela de frete por MLA
	Local lMLA := _MVERPGFE == "1" .And. _MVTFMLA == "1"

	If GV9->GV9_ENVAPR == "1"
		Help( ,, 'Help',, STR0070, 1, 0 ) //"A negociação já foi enviada para aprovação."
		Return .F.
	Else
		If !(_MVAPRTAB $ "1S")
			Help( ,, 'Help',, STR0083, 1, 0 ) //"O sistema não está parametrizado para fazer controle do envio de negociações para aprovação."
			Return .F.
		ElseIf GV9->GV9_SIT == "2"
			Help( ,, 'Help',, STR0071, 1, 0 ) //"A negociação já foi liberada."
			Return .F.
		Else
			GV6->( dbSetOrder(1) )
			If !GV6->( dbSeek(xFilial("GV6")+GV9->GV9_CDEMIT+GV9->GV9_NRTAB+GV9->GV9_NRNEG) )
				Help( ,, 'Help',, STR0082, 1, 0 ) //"A negociação não possui tarifas, portanto, não poderá ser enviada para aprovação."
				Return .F.
			EndIf
		
			If lMLA
				// Quanto utiliza MLA, o e-mail fica como pendência do MLA
				lEmail := .T.
			Else
      			cMensagem := STR0075+GV9->GV9_NRNEG+STR0076+GV9->GV9_NRTAB+STR0077+GV9->GV9_CDEMIT+STR0078+cUserName+STR0079
  
      			//Ponto de Entrada Britania
		  		If lPE612
		  			cRet := ExecBlock("GFEA0612",.f.,.f.,{cAssunto,cMensagem})
		  			If ValType(cRet) == 'A'
		    			cAssunto  := cRet[1]
		  				cMensagem := cRet[2]
		  			EndIf
	  			EndIf
	  			//Fim Ponto de Entrada Britania

				aRetMail  := GFEMail(GFEA064USR(),cAssunto,cMensagem,.F.)
				lEmail    := aRetMail[1]
			EndIf
		
			If lEmail
				RecLock("GV9",.F.)
					GV9->GV9_ENVAPR := "1" // Sim
					GV9->GV9_MTVRPR := ""
					If GfeVerCmpo({"GV9_SITMLA"}) .And. lMLA
						GV9->GV9_SITMLA := "2" // Situação MLA Pendente
						GV9->GV9_MOTMLA := ""
					EndIf
				GV9->(MsUnLock())

				If !Empty(GV9->(GV9_CODCOT+GV9_SEQCOT))
					GVQ->(dbSetOrder(1))
					If GVQ->(dbSeek( xFilial("GVQ")+"1"+GV9->(GV9_CODCOT+GV9_SEQCOT) ))
						RecLock("GVQ",.F.)
							GVQ->GVQ_ENVCOP := "1" // Cotação enviada
						GVQ->(MsUnlock())
					EndIf
				EndIf
			
				MsgInfo(STR0072, "")
			Else
				MsgAlert(STR0080 + CRLF + aRetMail[2])
				Return .F.
			EndIf	
		EndIf
	EndIf

Return .T.

/*---------------------------------------------------------------------------------------------------
{Protheus.doc} GFEA61AVLD
Função de validação ao inicializar o model.

@sample
GFEA61AVLD(oMod)

@author Octávio Augusto Felippe de Macedo
@since 28/01/2011
@version 1.0
----------------------------------------------------------------------------------------------------*/

Static Function GFEA61AVLD(oMod)

	Local nOpc := oMod:GetOperation()
	Local lAprovMLA := _MVERPGFE == "1" .And. _MVTFMLA == "1"
	Local lExecValid := .T.

	If nOpc == MODEL_OPERATION_INSERT .AND. Posicione("GVA",1,xFilial("GVA")+GFE61CdEmi()+GFE61NrTab(),"GVA_TPTAB") == "2"
		Help( ,, 'Help',, 'Não é permitido incluir negociações para tabelas de vínculo.', 1, 0)
		Return .F.
	EndIf

	If lPE613
		lExecValid := ExecBlock("GFEA0613",.f.,.f.,{nOpc})
	EndIf	
	If lExecValid .and. (GV9->GV9_SIT == "2" .And. (nOpc == MODEL_OPERATION_UPDATE .Or. nOpc == MODEL_OPERATION_DELETE) .And. _MVAPRTAB $ "1S")
		Help( ,, 'Help',, STR0081, 1, 0 ) //"Não é permitido alterar ou excluir uma negociação que esteja liberada."
		Return .F.
	EndIf
	
	If GfeVerCmpo({"GV9_SITMLA"})
		If nOpc == MODEL_OPERATION_DELETE .And. lAprovMLA .And. !(GV9->GV9_SITMLA $ "1|6" .Or. Empty(GV9->GV9_SITMLA))
			Help(,,'HELP',,"Negociação está integrada ao MLA ou pendente de integração, realize a desatualização para esta operação.",1,0)
			Return .F.
		EndIf
	EndIf

Return .T.

/*---------------------------------------------------------------------------------------------------
{Protheus.doc} A061GV8INI
Inicialização dos campos virtuais de Origem e Destino

@sample
A061GV8INI("GV8_CODORI")

@author Alan Victor Lamb
@since 29/07/2013
@version 1.0
----------------------------------------------------------------------------------------------------*/
Function A061GV8INI(cCampo)
	Local lRet := ""

	If Type("GV8->GV8_TPORIG") == "C"
		If cCampo == "GV8_CODORI"
			Do Case
				Case GV8->GV8_TPORIG == '0' 
					lRet := "Todas as rotas"
				Case GV8->GV8_TPORIG == '1' //Cidade
					lRet := GV8->GV8_NRCIOR+"-"+Posicione("GU7",1,xFilial("GU7")+GV8->GV8_NRCIOR,"GU7_NMCID")
				Case GV8->GV8_TPORIG == '2' //Distancia
					lRet := AllTrim(Transform(GV8->GV8_DSTORI, PESQPICT("GV8", "GV8_DSTORI")))+";"+AllTrim(Transform(GV8->GV8_DSTORF, PESQPICT("GV8", "GV8_DSTORF")))
				Case GV8->GV8_TPORIG == '3' //Região
					lRet := GV8->GV8_NRREOR+"-"+AllTrim(Posicione("GU9",1,xFilial("GU9")+GV8->GV8_NRREOR,"GU9_NMREG"))
				Case GV8->GV8_TPORIG == '4' //País/Uf
					If !Empty(GV8->GV8_CDPAOR)
						lRet := GV8->GV8_CDPAOR+"-"+AllTrim(Posicione("SYA",1,xFilial("SYA")+GV8->GV8_CDPAOR,"YA_DESCR"))
					EndIf

					If !Empty(GV8->GV8_CDUFOR)
						If !Empty(lRet)
							lRet += "/"
						EndIf
						lRet += GV8->GV8_CDUFOR
					EndIf

				Case GV8->GV8_TPORIG == '5' //Remetente
					lRet := AllTrim(GV8->GV8_CDREM)+"-"+AllTrim(Posicione("GU3",1,xFilial("GU3")+GV8->GV8_CDREM,"GU3_NMEMIT"))
			EndCase
		ElseIf cCampo == "GV8_CODDES"
			Do Case
				Case GV8->GV8_TPDEST == '0' 
					lRet := "Todas as rotas"
				Case GV8->GV8_TPDEST == '1' //Cidade
					lRet := GV8->GV8_NRCIDS+"-"+Posicione("GU7",1,xFilial("GU7")+GV8->GV8_NRCIDS,"GU7_NMCID")
				Case GV8->GV8_TPDEST == '2' //Distancia
					If !Empty(GV8->GV8_DSTDEI) .AND. !Empty(GV8->GV8_DSTDEF)
						lRet := AllTrim(Transform(GV8->GV8_DSTDEI, PESQPICT("GV8", "GV8_DSTDEI")))+";"+AllTrim(Transform(GV8->GV8_DSTDEF, PESQPICT("GV8", "GV8_DSTDEF")))
					EndIf
				Case GV8->GV8_TPDEST == '3' //Região
					lRet := GV8->GV8_NRREDS+"-"+AllTrim(Posicione("GU9",1,xFilial("GU9")+GV8->GV8_NRREDS,"GU9_NMREG"))
				Case GV8->GV8_TPDEST == '4' //País/Uf
					If !Empty(GV8->GV8_CDPADS)
						lRet := GV8->GV8_CDPADS+"-"+AllTrim(Posicione("SYA",1,xFilial("SYA")+GV8->GV8_CDPADS,"YA_DESCR"))
					EndIf

					If !Empty(GV8->GV8_CDUFDS)
						If !Empty(lRet)
							lRet += "/"
						EndIf

						lRet += GV8->GV8_CDUFDS
					EndIf
				Case GV8->GV8_TPDEST == '5' //Remetente
					lRet := AllTrim(GV8->GV8_CDDEST)+"-"+AllTrim(Posicione("GU3",1,xFilial("GU3")+GV8->GV8_CDDEST,"GU3_NMEMIT"))
			EndCase
		EndIf
	EndIf
Return lRet

/*---------------------------------------------------------------------------------------------------
{Protheus.doc} PesqF3

//
// aCpo1 (aCpo2) {
//		Titulo
//		Descrição
//		F3
//		AliasDescricao
//		NomeCampo
//		Default
// }
//

@sample
PesqF3({},{})

@author Alan Victor Lamb
@since 29/07/2013
@version 1.0
----------------------------------------------------------------------------------------------------*/
Static Function PesqF3(aCpo1, aCpo2)
	Local aRet 		:= {,}
	Local cPict 	:= "@!"
	local aPosEnch
	Local oDlg
	Local oSize

	Private cVal1	 := If(!Empty(aCpo1[5]), Space(tamsx3("GV8_CDREM")[1]), 0)
	Private cVal2 	 := If(!Empty(aCpo2) .AND. !Empty(aCpo2[5]), Space(tamsx3("GV8_CDREM")[1]), 0)
	Private cDesVal1 := Space(80)
	Private cDesVal2 := Space(80)
	
	oSize := FWDefSize():New(.T.)
	oSize:AddObject( "ENCHOICE", 100, 60, .T., .T. ) // Adiciona enchoice
	oSize:SetWindowSize({000,000, Iif(!Empty(aCpo2) .AND. !Empty(aCpo2[1]), 190, 150), 370})
	oSize:lLateral     := .F.  // Calculo vertical	
	oSize:Process() //executa os calculos
	
	aPosEnch := {oSize:GetDimension("ENCHOICE","LININI"),;
                 oSize:GetDimension("ENCHOICE","COLINI"),;
                 oSize:GetDimension("ENCHOICE","LINEND"),;
                 oSize:GetDimension("ENCHOICE","COLEND")}
                 
	DEFINE MSDIALOG oDlg TITLE "Tabelas de Frete" ;
							FROM oSize:aWindSize[1],oSize:aWindSize[2] ;
							TO oSize:aWindSize[3],oSize:aWindSize[4] PIXEL;
	
		// Campo descrição
		If Empty(aCpo1[2])
    		cPict := "@E 999,999,999.99999"
	    EndIf

		@ aPosEnch[1]+005, aPosEnch[2]+010 SAY   oSay PROMPT aCpo1[1] SIZE 062, 010 OF oDlg PIXEL
		@ aPosEnch[1]+015, aPosEnch[2]+010 MSGET oGet VAR cVal1	SIZE 062, 010 OF oDlg PICTURE cPict F3 aCpo1[3] Valid {|| cDesVal1 := If(!Empty(aCpo1[2]),Posicione(aCpo1[4],1,xFilial(aCpo1[4])+cVal1,aCpo1[5]),""),VldRota(cDesVal1,aCpo1[2],cVal1)} PIXEL HasButton

    	If !Empty(aCpo1[2])
			@ aPosEnch[1]+005, aPosEnch[2]+075 SAY	 oSay PROMPT aCpo1[2]  SIZE 075, 010 OF oDlg PIXEL
	    	@ aPosEnch[1]+015, aPosEnch[2]+075 MSGET oGet VAR cDesVal1 SIZE 075, 010 OF oDlg PICTURE cPict READONLY PIXEL
		EndIf

    	If Len(aCpo1) > 5 .AND. !Empty(aCpo1[6])
    		cVal1 := aCpo1[6]
    	EndIf

    	If !Empty(aCpo2) .AND. !Empty(aCpo2[1])
        	@ aPosEnch[1]+030, aPosEnch[2]+010 SAY   oSay PROMPT aCpo2[1] SIZE 062, 010 OF oDlg PIXEL
    		@ aPosEnch[1]+040, aPosEnch[2]+010 MSGET oGet VAR cVal2	SIZE 062, 010 OF oDlg PICTURE cPict F3 aCpo2[3] Valid {||If(!Empty(aCpo2[4]),ExistCpo(aCpo2[4],"12"+cVal2),.T.)} PIXEL HasButton
		EndIf

	ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar(oDlg,{|| aRet:={cVal1,cVal2,cDesVal1,cDesVal2},oDlg:End() },{||oDlg:End()},,) CENTERED
	MBrChgLoop( .f. )
	
Return aRet

Static Function VldRota(a,b,c)
	Local lRet := .T.
	If VALTYPE(c) == "N" 
		lRet := c >= 0
	Else
		lRet := !Empty(a) .Or. (Empty(b) .AND. !Empty(c))
		
	EndIf
	
Return lRet


/*---------------------------------------------------------------------------------------------------
{Protheus.doc} ResetOrDes
Limpa os campos de origem ou destino das rotas

@sample
ResetOrDes(a,b,c)

@author Alan Victor Lamb
@since 29/07/2013
@version 1.0
----------------------------------------------------------------------------------------------------*/
Static Function ResetOrDes(oFW, b, c)
	Local lOrigem

	lOrigem := b == "GV8_TPORIG"

	If lOrigem
		oFW:GetModel():GetModel("DETAIL_GV8"):ClearField("GV8_NRCIOR")
		oFW:GetModel():GetModel("DETAIL_GV8"):ClearField("GV8_DSTORI")
		oFW:GetModel():GetModel("DETAIL_GV8"):ClearField("GV8_DSTORF")
		oFW:GetModel():GetModel("DETAIL_GV8"):ClearField("GV8_NRREOR")
		oFW:GetModel():GetModel("DETAIL_GV8"):ClearField("GV8_CDPAOR")
		oFW:GetModel():GetModel("DETAIL_GV8"):ClearField("GV8_CDUFOR")
		oFW:GetModel():GetModel("DETAIL_GV8"):ClearField("GV8_CDREM")
		oFW:GetModel():GetModel("DETAIL_GV8"):ClearField("GV8_CODORI")
	Else
		oFW:GetModel():GetModel("DETAIL_GV8"):ClearField("GV8_NRCIDS")
		oFW:GetModel():GetModel("DETAIL_GV8"):ClearField("GV8_DSTDEI")
		oFW:GetModel():GetModel("DETAIL_GV8"):ClearField("GV8_DSTDEF")
		oFW:GetModel():GetModel("DETAIL_GV8"):ClearField("GV8_NRREDS")
		oFW:GetModel():GetModel("DETAIL_GV8"):ClearField("GV8_CDPADS")
		oFW:GetModel():GetModel("DETAIL_GV8"):ClearField("GV8_CDUFDS")
		oFW:GetModel():GetModel("DETAIL_GV8"):ClearField("GV8_CDDEST")
		oFW:GetModel():GetModel("DETAIL_GV8"):ClearField("GV8_CODDES")
	EndIf
Return Nil

/*---------------------------------------------------------------------------------------------------
{Protheus.doc} A061GV8VAL
Valid dos campos de "Tipo Origem" e "Tipo Destino".
Faz a consulta dos dados pelo tipo de origem ou destino.

@sample
A061GV8VAL(a,b,c)

@author Alan Victor Lamb
@since 29/07/2013
@version 1.0
----------------------------------------------------------------------------------------------------*/
Function A061GV8VAL(oFW,b,c)
	Local lRet 		:= .T.
	Local aCampos
	Local cTmpCampo 	:= ""
	Local cPict		:= "@E 999,999,999.99999"

	Do Case
		Case FwFldGet(b, oFW:GetLine()) == '0'
			cTmpCampo := If(b=="GV8_TPORIG","GV8_CODORI","GV8_CODDES")
			oFW:GetModel():GetModel("DETAIL_GV8"):SetValue(cTmpCampo,"Todas as rotas")
		Case FwFldGet(b, oFW:GetLine()) == '1' // Cidades
			If IsInCallStack("GFEA061")
				aCampos := PesqF3({"Cod Cidade","Cidade",X3F3("GV8_NRCIOR"),"GU7","GU7_NMCID"})
		
				If !Empty(aCampos[1])
					cTmpCampo := If(b=="GV8_TPORIG","GV8_NRCIOR","GV8_NRCIDS")
					oFW:GetModel():GetModel("DETAIL_GV8"):SetValue(cTmpCampo,Substr(aCampos[1],1,TamSX3("GV8_NRCIOR")[1]),.T.)
					cTmpCampo := If(b=="GV8_TPORIG","GV8_CODORI","GV8_CODDES")
					oFW:GetModel():GetModel("DETAIL_GV8"):SetValue(cTmpCampo,AllTrim(aCampos[1]) + "-" + AllTrim(aCampos[3]),.T.)
				Else
					ResetOrDes(oFW,b,c)
				EndIf
			EndIf
		Case FwFldGet(b, oFW:GetLine()) == '2' // Distancia
			If b == "GV8_TPORIG"
				aCampos := PesqF3({"Dst. Origem Inicial",,,,},{"Dst. Origem Final",,,,})
			Else
				If Type("M->GV8_TPORIG") != "U" .AND. M->GV8_TPORIG == "2"/*"GV8_TPORIG" $ ReadVar() .AND. &(ReadVar()) == "2"*/
					aCampos := {0,0}
				Else
					aCampos := PesqF3({"Dst. Destino Inicial",,,,},{"Dst. Destino Final",,,,})
				EndIf
			EndIf

			If !Empty(aCampos[1]) .AND. !Empty(aCampos[2])
				cTmpCampo := If(b=="GV8_TPORIG","GV8_DSTORI","GV8_DSTDEI")
				oFW:GetModel():GetModel("DETAIL_GV8"):SetValue(cTmpCampo,aCampos[1],.T.)

				cTmpCampo := If(b=="GV8_TPORIG","GV8_DSTORF","GV8_DSTDEF")
				oFW:GetModel():GetModel("DETAIL_GV8"):SetValue(cTmpCampo,aCampos[2],.T.)

				cTmpCampo := If(b=="GV8_TPORIG","GV8_CODORI","GV8_CODDES")
				oFW:GetModel():GetModel("DETAIL_GV8"):SetValue(cTmpCampo,AllTrim(Transform(aCampos[1],cPict)) + ";" + AllTrim(Transform(aCampos[2],cPict)),.T.)
			Else
				ResetOrDes(oFW,b,c)
			EndIf

		Case FwFldGet(b, oFW:GetLine()) == '3' // Região
			aCampos := PesqF3({"Cod Região","Região",X3F3("GV8_NRREOR"),"GU9","GU9_NMREG"})

			If !Empty(aCampos[1])
				cTmpCampo := If(b=="GV8_TPORIG","GV8_NRREOR","GV8_NRREDS")
				oFW:GetModel():GetModel("DETAIL_GV8"):SetValue(cTmpCampo,Substr(aCampos[1],1,TamSX3("GV8_NRREOR")[1]),.T.)
				cTmpCampo := If(b=="GV8_TPORIG","GV8_CODORI","GV8_CODDES")
				oFW:GetModel():GetModel("DETAIL_GV8"):SetValue(cTmpCampo,AllTrim(aCampos[1]) + "-" + AllTrim(aCampos[3]),.T.)
			Else
				ResetOrDes(oFW,b,c)
			EndIf

		Case FwFldGet(b, oFW:GetLine()) == '4' // País/UF
			aCampos := PesqF3({"Cod País", "País",X3F3("GV8_CDPAOR"),"SYA","YA_DESCR", "105"},;
							 	{"UF",,X3F3("GV8_CDUFOR"),"SX5","GV8_CDUFOR"})

			If Empty(aCampos[1]) .AND. Empty(aCampos[2])
				ResetOrDes(oFW,b,c)
			Else
				If !Empty(aCampos[1])
					cTmpCampo := If(b=="GV8_TPORIG","GV8_CDPAOR","GV8_CDPADS")
					oFW:GetModel():GetModel("DETAIL_GV8"):SetValue(cTmpCampo,Substr(aCampos[1],1,TamSX3("GV8_CDPAOR")[1]),.T.)
					cTmpCampo := If(b=="GV8_TPORIG","GV8_CODORI","GV8_CODDES")
					oFW:GetModel():GetModel("DETAIL_GV8"):SetValue(cTmpCampo,AllTrim(aCampos[1]) + "-" + AllTrim(aCampos[3]),.T.)
				EndIf

				If !Empty(aCampos[2])
					cTmpCampo := If(b=="GV8_TPORIG","GV8_CDUFOR","GV8_CDUFDS")
					oFW:GetModel():GetModel("DETAIL_GV8"):SetValue(cTmpCampo,Substr(aCampos[2],1,TamSX3("GV8_CDUFOR")[1]),.T.)
					cTmpCampo := If(b=="GV8_TPORIG","GV8_CODORI","GV8_CODDES")
					oFW:GetModel():GetModel("DETAIL_GV8"):SetValue(cTmpCampo,AllTrim(aCampos[2]),.T.)
				EndIf

				If !Empty(aCampos[1]) .AND. !Empty(aCampos[2])
					cTmpCampo := If(b=="GV8_TPORIG","GV8_CODORI","GV8_CODDES")
					oFW:GetModel():GetModel("DETAIL_GV8"):SetValue(cTmpCampo,AllTrim(aCampos[1]) + "-" + AllTrim(aCampos[3]) + "/" + AllTrim(aCampos[2]),.T.)
				EndIf
			EndIf

		Case FwFldGet(b, oFW:GetLine()) == '5' // Remetente / Destinatário
			aCampos := PesqF3({"Código","Nome",X3F3("GV8_CDREM"),"GU3","GU3_NMEMIT"})

			If !Empty(aCampos[1])
				cTmpCampo := If(b=="GV8_TPORIG","GV8_CDREM","GV8_CDDEST")
				oFW:GetModel():GetModel("DETAIL_GV8"):SetValue(cTmpCampo,Substr(aCampos[1],1,TamSX3("GV8_CDDEST")[1]),.T.)
				cTmpCampo := If(b=="GV8_TPORIG","GV8_CODORI","GV8_CODDES")
				oFW:GetModel():GetModel("DETAIL_GV8"):SetValue(cTmpCampo,Substr(AllTrim(aCampos[1]) + "-" + AllTrim(aCampos[3]),1,150),.T.)
			Else
				ResetOrDes(oFW,b,c)
			EndIf
	EndCase
Return lRet

//Verifica se o emitente de transporte permite utilização de veículo dedicado
Function GFE61GU3()
	Local oModel    := FWMODELACTIVE()
	Local lRet := .T.
	Local cTemp
	If GfeVerCmpo({"GU3_DEDIC"}) .And. oModel:GetValue( 'GFEA061A_GV9', 'GV9_TPLOTA' ) == '3'
		dbSelectArea("GU3")
		cTemp := Posicione("GU3",1, xFilial("GU3") + oModel:GetValue( 'GFEA061A_GV9', 'GV9_CDEMIT' ), "GU3_DEDIC")
		If cTemp != "1"
			lRet := .F.
			Help(,,'HELP',,"Não é possível utilizar o Tipo de Lotação Dedicado quando o Emitente de Transporte não possui Frota Dedicada",1,0)
		EndIf
	EndIf
Return lRet

/*---------------------------------------------------------------------------------------------------
{Protheus.doc} GFE61GV7WH                                               
x3_when dos campos GV7_QTCOTA,GV7_VLALUG, GV7_FRQKM ,GV7_VLKMEX
@sample
GFE61GV7WH(1)

@author Siegklenes.Beulke
@since 22/10/2013
@version 1.0
----------------------------------------------------------------------------------------------------*/

Function GFE61GV7WH(nOp)
	Local oModel := FwModelActive()
	Local oModelGV7 := oModel:GetModel('DETAIL_GV7')
	Local nLine := oModelGV7:GetLine()
	If FWFldGet("GV9_TPLOTA") == "3"
		If nOp == 1
			Return FWFldGet("GV7_VLALUG",nLine) == 0 .And. FWFldGet("GV7_FRQKM",nLine) == 0 .And. FWFldGet("GV7_VLKMEX",nLine) == 0
		Else
			Return FWFldGet("GV7_QTCOTA",nLine) == 0			
		EndIf
	EndIf	
Return FWFldGet("GV9_TPLOTA") == "3"


	
/*--------------------------------------------------------------------------------------------------
{Protheus.doc} GFE61ACOPY
Rotina que executa a view quando for cópia do negociação da tabela

@sample
GFE61ACOPY()

@author Ana Claudia da Silva
@since 08/06/2015
@version 1.0
--------------------------------------------------------------------------------------------------*/

Function GFE61ACOPY()


	Help(,,'HELP',,"Por favor para fazer a cópia da negociação, utilize o programa de Cópia e Reajuste da Tabela de Frete. ",1,0)

Return        

Function GFE61AEXC()
	
	//VIEWDEF.GFEA061A
	FWExecView("EXCLUIR",'GFEA061A', MODEL_OPERATION_DELETE, , {|| .T. },{|| .T.},,,{|| .T.})
Return        

Function GFE61APESQ()
	
	//VIEWDEF.GFEA061A
	AxPesqui()
Return

Function GFE61ACOM(oModel)
	Local nOp := oModel:GetOperation()
	Local lRet := .T.
	If nOp == MODEL_OPERATION_DELETE
		lRet := FwFormCommit(oModel)
	Else
		lRet := FWFormCommit(oModel, /*[ bBefore ]*/,/* [ bAfter ]*/, /*[ bAfterSTTS ]*/,{|oModel| GFE61ATDP(oModel:GetValue( 'GFEA061A_GV9', 'GV9_CDEMIT' ) + oModel:GetValue( 'GFEA061A_GV9', 'GV9_NRTAB' ))}, /*[ bABeforeTTS ]*/, /*<bIntegEAI >*/)
	EndIf
Return lRet

//Atualiza dependências
Function GFE61ATDP(cChave)
	Local cSeek
	Local cAlt := ""
	Local aAreaGVA := GVA->(getArea())
	
	If !GFE61EXCPL()
		Return .T.
	EndIf
		
	dbSelectArea("GVA")
	GVA->(dbSetorder(1))
	cSeek := xFilial("GVA") + cChave
	
	If GVA->( dbSeek( cSeek ) )
		RecLock("GVA",.F.)
		If _MVCPLINT == "1"
			If GVA->GVA_CPLSIT $ "2;3;5"
				GVA->GVA_CPLSIT := "4" //Necessita reenvio
				cAlt := "4"
			ElseIf !(GVA->GVA_CPLSIT $ "4;5") //Necessita reenvio/Integrada
				GVA->GVA_CPLSIT := "1" //Não enviada
				cAlt := "1"
			EndIf
		Else
			cAlt := "0"
			GVA->GVA_CPLSIT := "0" //Não se aplica
		EndIf
		MsUnLock()
	EndIf
	
	If !Empty(cAlt)
		//Tabelas vínculo
		GVA->(dbSetorder(2))
		GVA->( dbSeek( cSeek ) )
		While !GVA->(Eof()) .And. GVA->(GVA_FILIAL+GVA_EMIVIN+GVA_TABVIN) == cSeek

			RecLock("GVA",.F.)
			GVA->GVA_CPLSIT := cAlt
			MsUnLock()
			
			GVA->(dbSkip())
		EndDo
	EndIf
	
	RestArea(aAreaGVA)
Return .T.
//--------------------------------------------------------
/*/{Protheus.doc} GFEA61ADMA
Desatualização da negociação no MLA
@author felipe.m
@since 11/05/2016
@version 1.0
@return ${return}, ${return_description}
@example
(examples)
@see (links_or_references)
/*/
//--------------------------------------------------------
Function GFEA61ADMA()
Local lRet := .T.
Local nRecnoGV9 := GV9->(Recno())
	
	If !(GV9->GV9_SITMLA $ "3|4|7") // 3=Rejeitado ou 4=Atualizado ou 7-Enviado/aguardando.
		Help(,,'HELP',,"Negociação ainda não foi integrada ao MLA.",1,0)
		lRet := .F.
	EndIf
	
	If lRet .And. MsgNoYes("Deseja desatualizar a Negociação no MLA?", "Aviso")
		GV9->(dbGoto(nRecnoGV9))
		RecLock("GV9",.F.)
		GV9->GV9_SITMLA := "5"
		MsUnlock("GV9")
		
		MsgInfo("Negociação enviada para desatualização no MLA.")
	EndIf
Return lRet

Function GFEA061AVG(oX,acao,campo,valor)
	Local oModel
	Local oModelGV7
	Local nX
	
	oModel := oX:GetModel()

	If acao == "SETVALUE" .And. campo == "GV9_TPLOTA"
		oModelGV7 := oModel:GetModel("DETAIL_GV7")
		For nX := 1 To oModelGV7:Length()
			If Empty(oModelGV7:GetValue("GV7_CDTPVC",nX))
				oModelGV7:SetValue("GV7_DSTPVC",GFEA061DS("",,valor))
				Exit
			EndIf
		Next nX
	EndIf
Return .T.

Function GFEA61FRQ(nOpc)
	Local oModel := FWModelActive()
	Default nOpc := 0
	
	If GFXCP12123("GV7_FRQKM")
		Do Case
			Case nOpc == 1
				If oModel:GetValue("DETAIL_GV7","GV7_FRQKM") > 0 
					Return .T.
				EndIf
			Case nOpc == 2
				If oModel:GetValue("DETAIL_GV7","GV7_FRQKM") > 0 .And. oModel:GetValue("DETAIL_GV7","GV7_QTCDED") == "2"
					Return .T.
				EndIf
		EndCase
	EndIf
Return .F.

//--------------------------------------------------------
/*/{Protheus.doc} A61DSCLFR
Inic. Browse do campo GV9_DSCLFR
@author GFE
@since 05/11/2019
@version 1.0
/*/
//--------------------------------------------------------
Function A61DSCLFR(cCDCLFR)
	Local cRet := ""

	Default cCDCLFR := ""

	If !Empty(cCDCLFR)
		cRet := Posicione("GUB",1,xFilial("GUB")+cCDCLFR,"GUB_DSCLFR")
	EndIf
Return cRet

//--------------------------------------------------------
/*/{Protheus.doc} A61DSTPOP
Inic. Browse do campo GV9_DSTPOP
@author GFE
@since 05/11/2019
@version 1.0
/*/
//--------------------------------------------------------
Function A61DSTPOP(cCDTPOP)
	Local cRet := ""

	Default cCDTPOP := ""

	If !Empty(cCDTPOP)
		cRet := Posicione("GV4",1,xFilial("GV4")+cCDTPOP,"GV4_DSTPOP")
	EndIf
Return cRet
//--------------------------------------------------------
/*/{Protheus.doc} GFEA61VIGE
Encerra Vigência 
@author Matheus de Souza
@since 11/07/2023
@version 1.0
/*/
//--------------------------------------------------------
Function GFEA61VIGE() 
	Local dDataVig := Date()
	Local dDataExt := GV9->GV9_DTVALF

	If Empty(dDataExt)
	 
		DEFINE MSDIALOG oDlgRet TITLE "Encerrar Vigência " From 4,0 To 10,34 OF oMainWnd 

		@  4, 006  SAY "Termino da Vigência:" SIZE 70,7 PIXEL OF oDlgRet
		@  3, 60  MSGET dDataVig  When .T. PICTURE "99/99/9999" SIZE 50,7 PIXEL OF oDlgRet hasbutton Valid GFEVLDATE(dDataVig)

		TButton():New( 30, 5, "OK", oDlgRet,{||If (GFE61GRAVR(dDataVig),oDlgRet:End(),Nil)},;
		25, 10,,,.F.,.T.,.F.,,.F.,,,.F. )

		TButton():New( 30, 35, "Cancelar", oDlgRet,{||oDlgRet:End()},25, 10,,,.F.,.T.,.F.,,.F.,,,.F. )

		ACTIVATE MSDIALOG oDlgRet CENTERED
	Else
		GFEMessage(0,,STR0092) //A negociação já possui data de termino informada.
		Return .F.
	EndIF
Return
//--------------------------------------------------------
/*/{Protheus.doc} GFE61GRAVR
Valida e grava a Vigência informada
@author Matheus de Souza
@since 11/07/2023
@version 1.0
/*/
//--------------------------------------------------------
Function GFE61GRAVR(dDataVig)
	Local lRet  := .T.
	Local dDataAtual := Date()

	If !Empty(dDataVig)
		If dDataVig < dDataAtual
			GFEMessage(0,,STR0093 + DTOC(dDataVig),STR0094 + DTOC(dDataAtual)) // Data informada: / deve ser maior ou igual a data atual: 
			lRet := .F.
		EndIf 
	EndIf 

	If lRet
		Reclock("GV9",.F.)
			GV9->GV9_DTVALF := dDataVig
		GV9->(MsUnlock())

		GFEMessage(0,,STR0095) //Informações gravadas com sucesso!
	EndIf
Return lRet
//--------------------------------------------------------
/*/{Protheus.doc} GFEVLDATE
Valida a data informada
@author Matheus de Souza
@since 11/07/2023
@version 1.0
/*/
//--------------------------------------------------------
Static Function GFEVLDATE(dData)
	Local lRet := .T.

	If Empty(dData)
		lRet := .F.
		GFEMessage(0,,STR0096,STR0097) //Data inválida./ Informe uma data valida para continuar.
	EndIf
Return lRet

/*/--------------------------------------------------------------------------------------------------
{Protheus.doc} GFEGUYGV9

Função para montar o filtro da consulta padrão que permite selecionar o componente para os adicionais por emitente

@author João Leonardo Schmidt
@since 13/08/2025
@version 1.0
--------------------------------------------------------------------------------------------------/*/
Function GFEGUYGV9() 
	Local cRet := ""
		
	If M->GV9_NRTAB != Nil
		cRet := "GUY->GUY_CDEMIT==M->GV9_CDEMIT .AND. GUY->GUY_NRTAB==M->GV9_NRTAB .AND. GUY->GUY_NRNEG==M->GV9_NRNEG"
	Else
		cRet := "GUY->GUY_CDEMIT==GV9->GV9_CDEMIT .AND. GUY->GUY_NRTAB==GV9->GV9_NRTAB .AND. GUY->GUY_NRNEG==GV9->GV9_NRNEG"
	EndIf
Return cRet
