#INCLUDE 'JURA096.CH'
#INCLUDE 'PROTHEUS.CH'
#INCLUDE 'PARMTYPE.CH'
#INCLUDE 'FWMVCDEF.CH'
#INCLUDE 'FWMBROWSE.CH'

Static aCpoBotoes := NIL
Static aCpoInBot  := NIL
Static cUser      := ''
Static lCtrlMsg   := .T.
Static lCtlCndFat := .T.
Static aArmzNT0   := {}

Static _J70GrpCli
Static _J70CodCli
Static _J70LojCli
Static _aCnt096   := {}
Static _aPreFtVld := {}
Static _cNumClien := SuperGetMV("MV_JCASO1",, "1") // Seqüência da numeração do caso (1 - Por cliente / 2 - Independente)
Static _aSitCasos := {}

// Vetor aCpoBotoes
Static CTPHON := 0
Static BOTAO  := 0
Static CONFIG := 0

// Posicao 3 tem os campos e atributos
Static CAMPO  := 0
Static INICIA := 0
Static VISIV  := 0
Static OBRIGA := 0

// Numero dos botoes da Tela
Static BOTAOCDF := 0
Static BOTAOFXA := 0

//-------------------------------------------------------------------
/*/{Protheus.doc} J096SetSta()
Set de valores iniciais das variavéis Static
Essa função foi desenvolvida para ser chamado na criação do modelo,
assim os valores definidos aqui ficam no modelo quando é chamado por
um serviço (Rest, automação e etc...).
@author bruno.ritter
@since 02/06/2017
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function J096SetSta()
aCpoBotoes := NIL
aCpoInBot  := NIL
cUser      := '1' //1 = Alterações do usuário, 2 = Alterações so sistema (para permitir manipulação de parcelas automáticas)
lCtrlMsg   := .T. //Controlar as mensagens STR0132 exibida na Condição de Faturamento.
lCtlCndFat := .T. //Para controlar o botão de "Parcelar" e o "Confirmar"
aArmzNT0   := {}

_aCnt096   := {} //salva os valores especificados na função J096CPYCnt()

// Vetor aCpoBotoes
CTPHON := 1
BOTAO  := 2
CONFIG := 3
// Posicao 3 tem os campo e atributos
CAMPO  := 1
INICIA := 2
VISIV  := 3
OBRIGA := 4
// Numero dos botoes da Tela
BOTAOCDF := 1
BOTAOFXA := 2

Return NIL

//-------------------------------------------------------------------
/*/{Protheus.doc} JURA096
Contratos do Faturamento

@author David Gonçalves Fernandes
@since 26/05/09
@version 1.0
/*/
//-------------------------------------------------------------------
Function JURA096(cCliente, cLoja, cCaso)
Local cLojaAuto  := SuperGetMv( "MV_JLOJAUT", .F., "2", ) //Indica se a Loja do Caso deve ser preenchida automaticamente. (1-Sim; 2-Não)
Private oBrowse  := Nil

Default cCliente := ''
Default cLoja    := ''
Default cCaso    := ''

INCLUI := .F.
ALTERA := .F.

oBrowse := FWMBrowse():New()
oBrowse:SetDescription( STR0007 )
oBrowse:SetAlias( "NT0" )
Iif(cLojaAuto == "1", JurBrwRev(oBrowse, "NT0", {"NT0_CLOJA"}), )
oBrowse:SetLocate()

If !Empty( cCliente ) .And. !Empty( cLoja ) .And. !Empty( cCaso )
	oBrowse:SetFilterDefault( "NT0_CCLIEN == '" + cCliente + "' .AND. NT0_CLOJA == '" + cLoja + "'" )
	oBrowse:AddFilter("Contrato", "NUT_CCLIEN = '" + cCliente + "' AND NUT_CLOJA = '" + cLoja + "' AND NUT_CCASO = '" + cCaso + "' AND D_E_L_E_T_ = ' '", .T., .T., "NUT")
EndIf

oBrowse:SetMenuDef( 'JURA096' )
JurSetLeg( oBrowse, "NT0" )
JurSetBSize( oBrowse )
J096Filter(oBrowse, cLojaAuto) // Adiciona filtros padrões no browse

oBrowse:Activate()

Return NIL

//-------------------------------------------------------------------
/*/{Protheus.doc} J096Filter
Adiciona filtros padrões no browse

@param  oBrowse, objeto, browse da rotina

@author Reginaldo Borges / Cristina Cintra
@since  08/08/2022
/*/
//-------------------------------------------------------------------
Static Function J096Filter(oBrowse, cLojaAuto)
Local aFilNT01 := {}
Local aFilNT02 := {}
Local aFilNT03 := {}

	J96AddFilPar("NT0_CTPHON", "==", "%NT0_CTPHON0%", @aFilNT01)
	oBrowse:AddFilter(STR0259, 'NT0_CTPHON == "%NT0_CTPHON0%"', .F., .F., , .T., aFilNT01, STR0259) // "Tipo de Honorários"

	J96AddFilPar("NT0_CPART1", "==", "%NT0_CPART10%", @aFilNT02)
	oBrowse:AddFilter(STR0260, 'NT0_CPART1 == "%NT0_CPART10%"', .F., .F., , .T., aFilNT02, STR0260) // "Sócio Responsável"

	If cLojaAuto == "2"
		J96AddFilPar("NT0_CCLIEN", "==", "%NT0_CCLIEN0%", @aFilNT03)
		J96AddFilPar("NT0_CLOJA", "==", "%NT0_CLOJA0%", @aFilNT03)
		oBrowse:AddFilter(STR0261, 'NT0_CCLIEN == "%NT0_CCLIEN0%" .AND. NT0_CLOJA == "%NT0_CLOJA0%"', .F., .F., , .T., aFilNT03, STR0261) // "Cliente"
	Else
		J96AddFilPar("NT0_CCLIEN", "==", "%NT0_CCLIEN0%", @aFilNT03)
		oBrowse:AddFilter(STR0261, 'NT0_CCLIEN == "%NT0_CCLIEN0%"', .F., .F., , .T., aFilNT03, STR0261) // "Cliente"
	EndIf

Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} MenuDef
Menu Funcional

@return aRotina - Estrutura
[n,1] Nome a aparecer no cabecalho
[n,2] Nome da Rotina associada
[n,3] Reservado
[n,4] Tipo de Transação a ser efetuada:
1 - Pesquisa e Posiciona em um Banco de Dados
2 - Simplesmente Mostra os Campos
3 - Inclui registros no Bancos de Dados
4 - Altera o registro corrente
5 - Remove o registro corrente do Banco de Dados
6 - Alteração sem inclusão de registros
7 - Cópia
8 - Imprimir
[n,5] Nivel de acesso
[n,6] Habilita Menu Funcional

@author David Gonçalves Fernandes
@since 26/05/09
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function MenuDef()
Local aRotina := {}
Local aPesq   := {}

aAdd( aRotina, { STR0001, aPesq                   , 0, 1, 0, .T. } ) //"Pesquisar"
aAdd( aPesq,   { STR0001, 'PesqBrw'               , 0, 1, 0, .T. } ) //"Pesquisar"
aAdd( aPesq,   { STR0160, 'JFiltraCaso( oBrowse )', 0, 1, 0, .T. } ) //"Filtro por Caso"
If JA162AcRst('10')
	aAdd( aRotina, { STR0002, 'VIEWDEF.JURA096', 0, 2, 0, NIL } ) //"Visualizar"
EndIf
If JA162AcRst('10', 3)
	aAdd( aRotina, { STR0003, 'VIEWDEF.JURA096', 0, 3, 0, NIL } ) //"Incluir"
EndIf
If JA162AcRst('10', 4)
	aAdd( aRotina, { STR0004, 'VIEWDEF.JURA096', 0, 4, 0, NIL } ) //"Alterar"
EndIf
If JA162AcRst('10', 5)
	aAdd( aRotina, { STR0005, 'VIEWDEF.JURA096', 0, 5, 0, NIL } ) //"Excluir"
EndIf
If !IsInCallStack( 'JURA162' )
	aAdd( aRotina, { STR0006, 'VIEWDEF.JURA096', 0, 8, 0, NIL } ) //"Imprimir"
	aAdd( aRotina, { STR0088, 'JA096REVAL(NT0->NT0_COD)', 0, 8, 0, NIL } ) //"Revalorizar TSs"
	aAdd( aRotina, { STR0077, 'JA096REPLI()', 0, 3, 0, NIL } ) //Replicar
EndIf

Return aRotina

//-------------------------------------------------------------------
/*/{Protheus.doc} ViewDef()
View de dados de Contratos do Faturamento

@author David Gonçalves Fernandes
@since 26/05/09
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function ViewDef()
	Local oView      := Nil
	Local oModel     := FWLoadModel( 'JURA096' )
	Local oStruct    := FWFormStruct( 2, 'NT0', { |cCampo| cAux := cCampo, aScan( aCpoInBot, { |x| Alltrim(cAux) == Alltrim(x[CAMPO]) } ) == 0 } )
	Local oStructNTK := FWFormStruct( 2, 'NTK' )
	Local oStructNTJ := FWFormStruct( 2, 'NTJ' )
	Local oStructNUT := FWFormStruct( 2, 'NUT' )
	Local oStructNVN := FWFormStruct( 2, 'NVN' )
	Local oStructNW3 := FWFormStruct( 2, 'NW3' )
	Local oStructNT5 := FWFormStruct( 2, 'NT5' )
	Local oStructNXP := FWFormStruct( 2, 'NXP' )
	Local cLojaAuto  := SuperGetMv( "MV_JLOJAUT", .F., "2", ) //Indica se a Loja do Caso deve ser preenchida automaticamente. (1-Sim; 2-Não)
	Local cParam     := AllTrim( SuperGetMv('MV_JDOCUME',, '1'))
	Local lIntegraLD := SuperGetMV("MV_JFSINC", .F., '2') == '1' // Indica se utiliza a integração com o Legal Desk

oStruct:RemoveField( 'NT0_CPART1' )
oStruct:RemoveField( 'NT0_QTPARC' )
oStruct:RemoveField( 'NT0_DTENC' )
oStruct:RemoveField( 'NT0_TPCORR' )
oStruct:RemoveField( 'NT0_CINDIC' )
oStruct:RemoveField( 'NT0_DINDIC' )
oStruct:RemoveField( 'NT0_PARCE' )
oStruct:RemoveField( 'NT0_DISPON' )
oStruct:RemoveField( 'NT0_DESPAR' )
oStruct:RemoveField( 'NT0_DECPAR' )
oStruct:RemoveField( 'NT0_CFXCVL' )
oStruct:RemoveField( 'NT0_CTBCVL' )
oStruct:RemoveField( 'NT0_CFACVL' )
oStruct:RemoveField( 'NT0_CEXCVL' )
oStruct:RemoveField( 'NT0_CTIPOF' )
oStruct:RemoveField( 'NT0_DTIPOF' )

If !lIntegraLD .And. ( NT0->(ColumnPos( "NT0_CASMAE" )) > 0 .And. NT0->(ColumnPos( "NT0_CCLICM" )) > 0 )
	oStruct:RemoveField( 'NT0_CASMAE' )
	oStruct:RemoveField( 'NT0_CCLICM' )
	oStruct:RemoveField( 'NT0_CLOJCM' )
	oStruct:RemoveField( 'NT0_CCASCM' )
EndIf

If !lIntegraLD .And. NT0->(ColumnPos( "NT0_FIXREV" )) > 0
	oStruct:RemoveField( 'NT0_FIXREV' )
EndIf

If (cLojaAuto == "1")
	oStruct:RemoveField( "NT0_CLOJA" )
	oStructNUT:RemoveField( "NUT_CLOJA" )
	If NT0->(ColumnPos( "NT0_CLOJCM" )) > 0
		oStruct:RemoveField( 'NT0_CLOJCM' )
	EndIf
EndIf

oStructNUT:RemoveField( 'NUT_CCONTR' )
oStructNUT:RemoveField( 'NUT_DCONTR' )
oStructNUT:RemoveField( 'NUT_CPART1' )

oStructNTK:RemoveField( 'NTK_CCONTR' )
oStructNTK:RemoveField( 'NTK_DCONTR' )

oStructNTJ:RemoveField( 'NTJ_CCONTR' )
oStructNTJ:RemoveField( 'NTJ_DCONTR' )

oStructNVN:RemoveField( 'NVN_CCONTR' )
oStructNVN:RemoveField( 'NVN_CFATAD' )

oStructNT5:RemoveField( "NT5_COD"    )
oStructNT5:RemoveField( "NT5_CCONTR" )

oStructNXP:RemoveField( "NXP_COD"    )
oStructNXP:RemoveField( "NXP_CJCONT" )
oStructNXP:RemoveField( "NXP_CCONTR" )

oStructNVN:RemoveField( "NVN_CJCONT" )
oStructNVN:RemoveField( "NVN_CCONTR" )
oStructNVN:RemoveField( "NVN_CLIPG"  )
oStructNVN:RemoveField( "NVN_LOJPG"  )
oStructNVN:RemoveField( "NVN_CPREFT"  )
If NVN->(ColumnPos("NVN_CFIXO")) > 0 //Proteção
	oStructNVN:RemoveField( 'NVN_CFIXO' )
EndIf
If NVN->(ColumnPos("NVN_CFILA")) > 0 //Proteção
	oStructNVN:RemoveField( 'NVN_CFILA' )
	oStructNVN:RemoveField( 'NVN_CESCR' )
	oStructNVN:RemoveField( 'NVN_CFATUR' )
EndIf

oView := FWFormView():New()
oView:SetModel( oModel )

oView:AddField( 'JURA096_VIEW'   , oStruct   , 'NT0MASTER' )
oView:AddGrid(  'JURA096_GRIDNUT', oStructNUT, 'NUTDETAIL' )
oView:AddGrid(  'JURA096_GRIDNTK', oStructNTK, 'NTKDETAIL' )
oView:AddGrid(  'JURA096_GRIDNTJ', oStructNTJ, 'NTJDETAIL' )
oView:AddGrid(  'JURA096_GRIDNVN', oStructNVN, 'NVNDETAIL' )
oView:AddGrid(  'JURA096_GRIDNW3', oStructNW3, 'NW3DETAIL' )
oView:AddGrid(  'JURA096_GRIDNT5', oStructNT5, 'NT5DETAIL' )
oView:AddGrid(  'JURA096_GRIDNXP', oStructNXP, 'NXPDETAIL' )

oView:CreateFolder('FOLDER_01')
oView:AddSheet('FOLDER_01', 'ABA_01', STR0007 ) //"Contratos do Faturamento"
oView:AddSheet('FOLDER_01', 'ABA_02', STR0008 ) //"Despesas não cobráveis"
oView:AddSheet('FOLDER_01', 'ABA_03', STR0009 ) //"Atividades não cobráveis"
oView:AddSheet('FOLDER_01', 'ABA_05', STR0081 ) //"Contratos Vinculados"
oView:AddSheet('FOLDER_01', 'ABA_06', STR0087 ) //"Título do Contrato por Idioma"
oView:AddSheet('FOLDER_01', 'ABA_07', STR0118 ) //"Pagadores do Contrato"

oView:CreateHorizontalBox('BOX_A01_F01',  50,,, 'FOLDER_01', 'ABA_01')
oView:CreateHorizontalBox('BOX_A01_F02',  50,,, 'FOLDER_01', 'ABA_01')
oView:CreateHorizontalBox('BOX_A02_F01', 100,,, 'FOLDER_01', 'ABA_02')
oView:CreateHorizontalBox('BOX_A03_F01', 100,,, 'FOLDER_01', 'ABA_03')
oView:CreateHorizontalBox('BOX_A05_F01', 100,,, 'FOLDER_01', 'ABA_05')
oView:CreateHorizontalBox('BOX_A06_F01', 100,,, 'FOLDER_01', 'ABA_06')
oView:CreateHorizontalBox('BOX_A07_F01',  50,,, 'FOLDER_01', 'ABA_07')
oView:CreateHorizontalBox('BOX_A07_F02',  50,,, 'FOLDER_01', 'ABA_07')

oView:CreateFolder('FOLDER_02','BOX_A01_F02')
oView:AddSheet('FOLDER_02','ABA_01_01', STR0012 )  //Contrato X Casos
oView:CreateHorizontalBox('BOX_A01_F02_01',100,,,'FOLDER_02','ABA_01_01')
oView:CreateHorizontalBox('BOX_A01_F02_02',100,,,'FOLDER_02','ABA_01_02')

oView:CreateFolder('FOLDER_03','BOX_A07_F02')
oView:AddSheet('FOLDER_03','ABA_07_01', STR0080 )  //"Encaminhamento de fatura"
oView:CreateHorizontalBox('BOX_A07_F02_01',100,,,'FOLDER_03','ABA_07_01')
oView:CreateHorizontalBox('BOX_A07_F02_02',100,,,'FOLDER_03','ABA_07_02')

oView:SetOwnerView( 'JURA096_VIEW'   , 'BOX_A01_F01' )
oView:SetOwnerView( 'JURA096_GRIDNUT', 'BOX_A01_F02_01' )
oView:SetOwnerView( 'JURA096_GRIDNTK', 'BOX_A02_F01' )
oView:SetOwnerView( 'JURA096_GRIDNTJ', 'BOX_A03_F01' )
oView:SetOwnerView( 'JURA096_GRIDNW3', 'BOX_A05_F01' )
oView:SetOwnerView( 'JURA096_GRIDNT5', 'BOX_A06_F01' )
oView:SetOwnerView( 'JURA096_GRIDNXP', 'BOX_A07_F01' )
oView:SetOwnerView( 'JURA096_GRIDNVN', 'BOX_A07_F02_01' )

If IsInCallStack("JURA070")
	oView:SetNoInsertLine( 'JURA096_GRIDNUT' )
	oView:SetNoUpdateLine( 'JURA096_GRIDNUT' )
	oView:SetNoDeleteLine( 'JURA096_GRIDNUT' )
EndIf

oView:SetNoInsertLine( 'JURA096_GRIDNW3' )
oView:SetNoUpdateLine( 'JURA096_GRIDNW3' )
oView:SetNoDeleteLine( 'JURA096_GRIDNW3' )

oView:AddUserButton( STR0013, 'MENURUN', { | oView | JURA96CDF( oView ) } ) // "Cond.Fat.Fixo"
oView:AddUserButton( STR0014, 'LJPRECO', { | oView | JURA96FXA( oView ) } ) // "Fx.Val."

If !(cParam $ '1|4' .AND. IsPlugin())  // 1=Worksite / 4=iManage
	oView:AddUserButton( STR0035, "CLIPS", { | oView | J096RetRecno("NT0_COD"), JURANEXDOC("NT0", "NT0MASTER", "", "NT0_COD", , , , , , , , , , .T.) } )
EndIf

If FwAliasInDic('OI4')
	oView:AddUserButton(STR0265, 'MENURUN', { | oV | JURA302( oV:GetModel('NT0MASTER'):GetValue('NT0_FILIAL'),oV:GetModel('NT0MASTER'):GetValue('NT0_COD') ) },,,{MODEL_OPERATION_UPDATE} ) // "Faixa Ocor."
Endif

oView:AddIncrementField( 'NVNDETAIL', 'NVN_COD' )

oView:SetDescription( STR0007 ) //"Contratos do Faturamento"
oView:EnableControlBar( .T. )

oView:SetProgressBar(.T.)

oView:SetCloseOnOk({||.F.})

Return oView

//-------------------------------------------------------------------
/*/{Protheus.doc} ModelDef
Modelo de dados de Contratos do Faturamento

@author David Gonçalves Fernandes
@since 26/05/09
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function Modeldef()
	Local oModel     := NIL
	Local lShowVirt  := !JurIsRest() // Inclui os campos virtuais nos structs somente se não for REST (Necessário já que os inicializadores dos campos virtuais são executados sempre, mesmo sem o uso do header FIELDVIRTUAL = TRUE)
	Local oStruct    := FWFormStruct( 1, 'NT0',,, lShowVirt )  //Contratos
	Local oStructNT1 := FWFormStruct( 1, 'NT1',,, lShowVirt )  //Vencimentos
	Local oStructNTR := FWFormStruct( 1, 'NTR',,, lShowVirt )  //Faixas
	Local oStructNUT := FWFormStruct( 1, 'NUT',,, lShowVirt )  //Casos do Contrato
	Local oStructNTK := FWFormStruct( 1, 'NTK',,, lShowVirt )  //Tipos de Despesas Nao Cobraveis
	Local oStructNTJ := FWFormStruct( 1, 'NTJ',,, lShowVirt )  //Tipos de Atividade Nao Cobravel
	Local oStructNVN := FWFormStruct( 1, 'NVN',,, lShowVirt )  //Cópia da fatura
	Local oStructNW3 := FWFormStruct( 1, 'NW3',,, lShowVirt )  //Contratos Vinculados
	Local oStrcNW3_  := FWFormStruct( 1, 'NW3',,, lShowVirt )  //Contratos Vinculados (Auxiliar)
	Local oStructNT5 := FWFormStruct( 1, 'NT5',,, lShowVirt )  //Título do Contrato por Idioma
	Local oStructNXP := FWFormStruct( 1, 'NXP',,, lShowVirt )  //Pagadores do Contrato
	Local oStructNWE := FWFormStruct( 1, 'NWE',,, lShowVirt )  //Fixo Faturamento
	Local oCommit    := JA096COMMIT():New()	
	Local lIntegraLD := SuperGetMV( "MV_JFSINC", .F., '2') == '1' // Indica se utiliza a integração com o Legal Desk
	Local lJURA162   := FWIsInCallStack("JURA162")

If !lShowVirt
	// Adiciona os campos virtuais "SIGLA" novamente nas estruturas, pois foi retirado via lShowVirt,
	// mas precisa existir para execução das operações nos lançamentos via REST
	AddCampo(1, "NT0_SIGLA1", @oStruct)
	AddCampo(1, "NUT_SIGLA" , @oStructNUT)
EndIf

//Aplicar valores de default nas váriaveis estática, de forma que quando for chamado o modelo, essas váriaves existam com os valores iniciais.
J096SetSta()

If Empty(aCpoBotoes)
	aCpoBotoes := {}
	aCpoInBot  := {}
	JUR096CPO()
EndIf

oStructNT1:RemoveField( 'NT1_DCONTR' )    //campos virtuais utilizados na tela de emissão de fatura ( JURA203 )
oStructNT1:RemoveField( 'NT1_CCLIEN' )    //campos virtuais utilizados na tela de emissão de fatura ( JURA203 )
oStructNT1:RemoveField( 'NT1_CLOJA' )     //campos virtuais utilizados na tela de emissão de fatura ( JURA203 )
oStructNT1:RemoveField( 'NT1_DCLIEN' )    //campos virtuais utilizados na tela de emissão de fatura ( JURA203 )
oStructNT1:RemoveField( 'NT1_CTPHON' )    //campos virtuais utilizados na tela de emissão de fatura ( JURA203 )
oStructNT1:RemoveField( 'NT1_DTPHON' )    //campos virtuais utilizados na tela de emissão de fatura ( JURA203 )

//Libera edição apenas de faturamentos pendentes e não deletados
oStructNT1:setProperty("*"         , MODEL_FIELD_WHEN, {|model| !model:isDeleted() .and. model:GetValue("NT1_SITUAC")=="1" } )
oStructNT1:setProperty("NT1_DESCRI", MODEL_FIELD_WHEN, {|model| !model:isDeleted() }) // Será possível alterar somente a descrição

IIf(lShowVirt, oStructNUT:setProperty("NUT_DCONTR", MODEL_FIELD_INIT, Nil), Nil) // Campo removido do view não precisa executar o inicializador padrão

oModel:= MPFormModel():New( 'JURA096', /*Pre-Validacao*/, {|oX| JUR96TUDOK(oX)}/*Pos-Validacao*/, /*Commit*/,/*Cancel*/)
oModel:AddFields( 'NT0MASTER', NIL, oStruct, /*Pre-Validacao*/,  /*Pos-Validacao*/ )

oModel:AddGrid( 'NT1DETAIL', 'NT0MASTER' /*cOwner*/, oStructNT1, { |oSubModel,nLinha,cAction,cCampo,xComp,xValue| JA096VE(oSubModel,nLinha,cAction,cCampo,xComp,xValue) }/*bLinePre*/, /*bLinePost*/, /*bPre*/, /*bPost*/, {|oGrid| JLoadGrid(oGrid,"NT1_SEQUEN",oModel)})
oModel:AddGrid( 'NTRDETAIL', 'NT0MASTER' /*cOwner*/, oStructNTR, /*bLinePre*/,  /*bLinePost*/,/*bPre*/, { || JA125VLFX( oModel:GetModel('NTRDETAIL') , 'NTRDETAIL' ) }/*bPost*/ )

If lJURA162 // Rotina de Pesquisa de processo JURA162
	oModel:AddGrid('NUTDETAIL', 'NT0MASTER' /*cOwner*/, oStructNUT, /*bLinePre*/, /*bLinePost*/,/*bPre*/, /*bPost*/, {|oModelGrid,lLoad| JA096NUT(oModelGrid,lLoad)})
Else
	oModel:AddGrid('NUTDETAIL', 'NT0MASTER' /*cOwner*/, oStructNUT, /*bLinePre*/, /*bLinePost*/,/*bPre*/, /*bPost*/, {|oModelGrid, lLoad| JA96NUTLoad(oModelGrid, lLoad)})
EndIf

oModel:AddGrid( 'NTKDETAIL', 'NT0MASTER' /*cOwner*/, oStructNTK, /*bLinePre*/, /*bLinePost*/,/*bPre*/, /*bPost*/ )
oModel:AddGrid( 'NTJDETAIL', 'NT0MASTER' /*cOwner*/, oStructNTJ, /*bLinePre*/, /*bLinePost*/,/*bPre*/, /*bPost*/ )
oModel:AddGrid( 'NW3_DETAIL','NT0MASTER' /*cOwner*/, oStrcNW3_ , /*bLinePre*/, /*bLinePost*/,/*bPre*/, /*bPost*/ )
oModel:AddGrid( 'NW3DETAIL', 'NW3_DETAIL'/*cOwner*/, oStructNW3, /*bLinePre*/, /*bLinePost*/,/*bPre*/, /*bPost*/ )
oModel:AddGrid( 'NT5DETAIL', 'NT0MASTER' /*cOwner*/, oStructNT5, /*bLinePre*/, /*bLinePost*/,/*bPre*/, /*bPost*/ )
oModel:AddGrid( 'NWEDETAIL', 'NT1DETAIL' /*cOwner*/, oStructNWE, /*bLinePre*/, /*bLinePost*/,/*bPre*/, /*bPost*/ )
oModel:AddGrid( 'NXPDETAIL', 'NT0MASTER' /*cOwner*/, oStructNXP, /*bLinePre*/, /*bLinePost*/,/*bPre*/, /*bPost*/ )
oModel:AddGrid( 'NVNDETAIL', 'NXPDETAIL' /*cOwner*/, oStructNVN, /*bLinePre*/, /*bLinePost*/,/*bPre*/, /*bPost*/ )

oModel:SetDescription( STR0015 ) //"Modelo de Dados de Contratos do Faturamento"
oModel:GetModel( 'NT0MASTER' ):SetDescription( STR0016 ) //"Dados de Contratos do Faturamento"

oModel:GetModel( 'NT1DETAIL' ):SetUniqueLine( { 'NT1_PARC'   } )
oModel:GetModel( 'NTRDETAIL' ):SetUniqueLine( { 'NTR_COD'    } )
oModel:GetModel( 'NUTDETAIL' ):SetUniqueLine( { 'NUT_CCLIEN', 'NUT_CLOJA', 'NUT_CCASO'  } )
oModel:GetModel( 'NTKDETAIL' ):SetUniqueLine( { 'NTK_CTPDSP' } )
oModel:GetModel( 'NTJDETAIL' ):SetUniqueLine( { 'NTJ_CTPATV' } )
oModel:GetModel( 'NW3_DETAIL'):SetUniqueLine( { 'NW3_CJCONT','NW3_CCONTR' } )
oModel:GetModel( 'NW3DETAIL' ):SetUniqueLine( { 'NW3_CJCONT','NW3_CCONTR' } )
oModel:GetModel( 'NT5DETAIL' ):SetUniqueLine( { 'NT5_CIDIOM' } )
oModel:GetModel( 'NWEDETAIL' ):SetUniqueLine( { 'NWE_CFIXO','NWE_CWO','NWE_CFATUR','NWE_CESCR','NWE_PRECNF' } )
oModel:GetModel( 'NXPDETAIL' ):SetUniqueLine( { 'NXP_CLIPG', 'NXP_LOJAPG' } )
oModel:GetModel( 'NVNDETAIL' ):SetUniqueLine( { 'NVN_CCONT'} )

oModel:SetRelation( 'NT1DETAIL', { { 'NT1_FILIAL', "XFILIAL('NT1')" }, { 'NT1_CCONTR', 'NT0_COD'   }}, NT1->( IndexKey( 1 ) ) )
oModel:SetRelation( 'NTRDETAIL', { { 'NTR_FILIAL', "XFILIAL('NTR')" }, { 'NTR_CCONTR', 'NT0_COD'   }}, NTR->( IndexKey( 1 ) ) )
oModel:SetRelation( 'NUTDETAIL', { { 'NUT_FILIAL', "XFILIAL('NUT')" }, { 'NUT_CCONTR', 'NT0_COD'   }}, NUT->( IndexKey( 1 ) ) )
oModel:SetRelation( 'NTKDETAIL', { { 'NTK_FILIAL', "XFILIAL('NTK')" }, { 'NTK_CCONTR', 'NT0_COD'   }}, NTK->( IndexKey( 1 ) ) )
oModel:SetRelation( 'NTJDETAIL', { { 'NTJ_FILIAL', "XFILIAL('NTJ')" }, { 'NTJ_CCONTR', 'NT0_COD'   }}, NTJ->( IndexKey( 1 ) ) )
oModel:SetRelation( 'NW3_DETAIL',{ { 'NW3_FILIAL', "XFILIAL('NW3')" }, { 'NW3_CCONTR', 'NT0_COD'   }}, NW3->( IndexKey( 3 ) ) )
oModel:SetRelation( 'NW3DETAIL', { { 'NW3_FILIAL', "XFILIAL('NW3')" }, { 'NW3_CJCONT', 'NW3_CJCONT'}}, NW3->( IndexKey( 1 ) ) )
oModel:SetRelation( 'NT5DETAIL', { { 'NT5_FILIAL', "XFILIAL('NT5')" }, { 'NT5_CCONTR', 'NT0_COD'   }}, NT5->( IndexKey( 2 ) ) )
oModel:SetRelation( 'NWEDETAIL', { { 'NWE_FILIAL', "XFILIAL('NWE')" }, { 'NWE_CFIXO',  'NT1_SEQUEN' } }, "R_E_C_N_O_" )
oModel:SetRelation( 'NXPDETAIL', { { 'NXP_FILIAL', "XFILIAL('NXP')" }, { 'NXP_CCONTR', 'NT0_COD'   }}, NXP->( IndexKey( 2 ) ) )
oModel:SetRelation( 'NVNDETAIL', { { 'NVN_FILIAL', "XFILIAL('NVN')" }, { 'NVN_CCONTR', 'NT0_COD'   }, { 'NVN_CLIPG', 'NXP_CLIPG' }, { 'NVN_LOJPG', 'NXP_LOJAPG' } }, NVN->( IndexKey( 5 ) ) )

oModel:GetModel( 'NT1DETAIL' ):SetDelAllLine( .T. )
oModel:GetModel( "NUTDETAIL" ):SetDelAllLine( .T. )
oModel:GetModel( "NTKDETAIL" ):SetDelAllLine( .T. )
oModel:GetModel( "NTJDETAIL" ):SetDelAllLine( .T. )
oModel:GetModel( "NTRDETAIL" ):SetDelAllLine( .T. )
oModel:GetModel( "NT5DETAIL" ):SetDelAllLine( .T. )
oModel:GetModel( "NWEDETAIL" ):SetDelAllLine( .T. )
oModel:GetModel( "NXPDETAIL" ):SetDelAllLine( .T. )
oModel:GetModel( "NVNDETAIL" ):SetDelAllLine( .T. )
oModel:GetModel( "NW3DETAIL" ):SetOnlyView( .T. )

oModel:SetOptional("NT1DETAIL", .T. )
oModel:SetOptional("NUTDETAIL", .T. )
oModel:SetOptional("NTKDETAIL", .T. )
oModel:SetOptional("NTJDETAIL", .T. )
oModel:SetOptional("NTRDETAIL", .T. )
oModel:SetOptional("NW3DETAIL", .T. )
oModel:SetOptional("NT5DETAIL", .T. )
oModel:SetOptional("NTRDETAIL", .T. )
oModel:SetOptional("NW3_DETAIL",.T. )
oModel:SetOptional("NWEDETAIL", .T. )
oModel:SetOptional("NXPDETAIL", .T. )
oModel:SetOptional("NVNDETAIL", .T. )

// Retirar esta linha se houver algum erro de TOP relacionado a tabela NT1 ou NWE.
oModel:GetModel('NWEDETAIL'):SetOnlyView ( .T. )

oStructNT1:SetProperty( 'NT1_CCONTR' , MODEL_FIELD_NOUPD, .T. )
oStructNT1:SetProperty( 'NT1_PARC'   , MODEL_FIELD_NOUPD, .T. )
oStructNT1:SetProperty( 'NT1_SEQUEN' , MODEL_FIELD_NOUPD, .T. )
oStructNT1:SetProperty( 'NT1_SITUAC' , MODEL_FIELD_NOUPD, .T. )
oStructNT1:SetProperty( 'NT1_CPREFT' , MODEL_FIELD_NOUPD, .T. )
oStructNT1:SetProperty( 'NT1_COTAC1' , MODEL_FIELD_NOUPD, .T. )
oStructNT1:SetProperty( 'NT1_COTAC2' , MODEL_FIELD_NOUPD, .T. )
If NT1->(ColumnPos("NT1_ACAOLD")) > 0
	oStructNT1:SetProperty( 'NT1_ACAOLD', MODEL_FIELD_NOUPD, .T. )
	oStructNT1:SetProperty( 'NT1_INSREV', MODEL_FIELD_NOUPD, .T. )
	oStructNT1:SetProperty( 'NT1_REVISA', MODEL_FIELD_NOUPD, .T. )
EndIf
If !lIntegraLD .And. NT0->(ColumnPos("NT0_FIXREV")) > 0
	oStruct:SetProperty( 'NT0_FIXREV', MODEL_FIELD_NOUPD, .T. )
EndIf

//Aumenta a capacidade de linhas no grid
oModel:GetModel( "NUTDETAIL" ):SetMaxLine(999999)
oModel:GetModel( "NT1DETAIL" ):SetMaxLine(999999)

oModel:InstallEvent("JA096COMMIT", /*cOwner*/, oCommit)

JurSetRules( oModel, 'NT0MASTER',, 'NT0' )
JurSetRules( oModel, 'NT1DETAIL',, 'NT1' )
JurSetRules( oModel, 'NTRDETAIL',, 'NTR' )
JurSetRules( oModel, 'NUTDETAIL',, 'NUT' )
JurSetRules( oModel, 'NTKDETAIL',, 'NTK' )
JurSetRules( oModel, 'NTJDETAIL',, 'NTJ' )
JurSetRules( oModel, 'NW3DETAIL',, 'NW3' )
JurSetRules( oModel, 'NT5DETAIL',, 'NT5' )
JurSetRules( oModel, 'NWEDETAIL',, 'NWE' )
JurSetRules( oModel, 'NXPDETAIL',, 'NXP' )
JurSetRules( oModel, 'NVNDETAIL',, 'NVN' )

oModel:SetVldActivate( {|oModel| J096VldTpH(oModel)} )

oModel:SetActivate( {|oModel| J096Active(oModel)} )

oModel:SetOnDemand()

Return oModel

//-------------------------------------------------------------------
/*/{Protheus.doc} JURA96CDF
SubView de Condições de Faturamento de Fixo

@author David Gonçalves Fernandes
@since 26/05/09
@version 1.0
/*/
//-------------------------------------------------------------------
Function JURA96CDF( oViewPai )
Local oView        := Nil
Local oExecView    := Nil
Local oStruct      := Nil
Local oStructNT1   := Nil
Local nAt          := 0
Local nI           := 0
Local lSubView     := .T.
Local bOk          := { |oModel| JUR96BOK( oModel, lSubView, BOTAOCDF, 'NT1DETAIL' ) }
Local oModel       := oViewPai:GetModel()
Local oModelNT1    := oModel:GetModel('NT1DETAIL')
Local lParcPend    := .F.
Local cTpHon       := FwFldGet('NT0_CTPHON')
Local cTitulo      := FwFldGet('NT0_DTPHON')
Local lRet         := .T.
Local nBotaoAtv    := BOTAOCDF //1 = Condições de Faturamento de Fixo

If (nAt := J096TemCpo(BOTAOCDF)) == 0
	lRet := .F.
EndIf

If lRet .AND. J096ObrgOk(oModel, aCpoBotoes[nAt][CONFIG], STR0013) // "Cond.Fat.Fixo"

	oStruct    := FWFormStruct(2, 'NT0', { |cCampo| Jur96Exibe( cCampo, aCpoBotoes[nAt][CONFIG] ) })
	oStructNT1 := FWFormStruct(2, 'NT1')
	oStructNWE := FWFormStruct(2, 'NWE')

	oStructNT1:RemoveField('NT1_CCONTR')
	oStructNT1:RemoveField('NT1_SEQUEN')
	oStructNT1:RemoveField('NT1_TKRET' )
	oStructNT1:RemoveField('NT1_DCONTR')    //campos virtuais utilizados na tela de emissão de fatura ( JURA203 )
	oStructNT1:RemoveField('NT1_CCLIEN')    //campos virtuais utilizados na tela de emissão de fatura ( JURA203 )
	oStructNT1:RemoveField('NT1_CLOJA' )    //campos virtuais utilizados na tela de emissão de fatura ( JURA203 )
	oStructNT1:RemoveField('NT1_DCLIEN')    //campos virtuais utilizados na tela de emissão de fatura ( JURA203 )
	oStructNT1:RemoveField('NT1_CTPHON')    //campos virtuais utilizados na tela de emissão de fatura ( JURA203 )
	oStructNT1:RemoveField('NT1_DTPHON')    //campos virtuais utilizados na tela de emissão de fatura ( JURA203 )
	If NT1->(ColumnPos('NT1_COTAC')) > 0 //Proteção
		oStructNT1:RemoveField('NT1_COTAC')
		oStructNWE:RemoveField('NWE_COTAC')
	EndIf
	If NT1->(ColumnPos("NT1_ACAOLD")) > 0
		oStructNT1:RemoveField('NT1_ACAOLD')
		oStructNT1:RemoveField('NT1_INSREV')
		oStructNT1:RemoveField('NT1_REVISA')	
	EndIf
	oStructNT1:RemoveField('NT1_OK'    )
	oStructNWE:RemoveField('NWE_CFIXO' )
	oStructNT1:SetProperty('NT1_QTDADE', MVC_VIEW_CANCHANGE, .F. )

	oView := FWFormView():New(oViewPai)
	oView:SetModel(oModel)

	oView:AddField( 'JURA96CDF_VIEW', oStruct, 'NT0MASTER' )

	If JUR96TPFIX(cTpHon) .And. !(JUR96FAIXA(cTpHon))  //Verificar o Tipo de Honorários para exibir ou não o Grid NT1

		oView:AddGrid('JURA096_GRIDNT1', oStructNT1, 'NT1DETAIL')
		oView:AddGrid('JURA096_GRIDNWE', oStructNWE, 'NWEDETAIL')

		oView:CreateHorizontalBox('FORMFIELD', 50)
		oView:CreateHorizontalBox('FORMGRID', 50)

		oView:CreateFolder('FOLDER_01', 'FORMGRID')
		oView:AddSheet('FOLDER_01', 'ABA_01', STR0163) // "Parcelas"
		oView:AddSheet('FOLDER_01', 'ABA_02', STR0164) // "Faturamento"
		oView:CreateHorizontalBox('BOX_A01_F01',100,,,'FOLDER_01','ABA_01')
		oView:CreateHorizontalBox('BOX_A02_F01',100,,,'FOLDER_01','ABA_02')

		oView:SetOwnerView('JURA96CDF_VIEW' , 'FORMFIELD')
		oView:SetOwnerView('JURA096_GRIDNT1', 'BOX_A01_F01')
		oView:SetOwnerView('JURA096_GRIDNWE', 'BOX_A02_F01')
		oView:AddIncrementField('NT1DETAIL' , 'NT1_PARC')

		oView:SetNoDeleteLine('JURA096_GRIDNWE')
		oView:SetNoInsertLine('JURA096_GRIDNWE')
		oView:SetNoUpdateLine('JURA096_GRIDNWE')

		//Verifica se geração de parcelas é automática
		If J96TPHPAut(cTpHon)
			oView:SetNoDeleteLine('JURA096_GRIDNT1')
			oView:SetNoInsertLine('JURA096_GRIDNT1')

			//Verifica a existência de parcelas pendentes
			lParcPend := .F.

			If !oModelNT1:IsEmpty()
				For nI := 1 To oModelNT1:GetQtdLine()
					If !oModelNT1:IsDeleted(nI) .And. oModelNT1:GetValue("NT1_SITUAC", nI) == "1"
						lParcPend := .T.
						Exit
					EndIf
				Next
			Else
				J096SetNo(oModelNT1, .T.)
			EndIf

			If lParcPend
				If JUR96TPFIX(oModel:GetValue('NT0MASTER','NT0_CTPHON'))
					oStruct:SetProperty("NT0_DTBASE",  MVC_VIEW_CANCHANGE, .T.)
					oStruct:SetProperty("NT0_CMOEF" ,  MVC_VIEW_CANCHANGE, .T.)
					oStruct:SetProperty("NT0_VLRBAS",  MVC_VIEW_CANCHANGE, .T.)
					oStruct:SetProperty("NT0_TPCORR",  MVC_VIEW_CANCHANGE, .T.)
					oStruct:SetProperty("NT0_CINDIC",  MVC_VIEW_CANCHANGE, .T.)
					oStruct:SetProperty("NT0_PERCOR",  MVC_VIEW_CANCHANGE, .T.)
					oStruct:SetProperty("NT0_DESPAR",  MVC_VIEW_CANCHANGE, .T.)
					If Val(JURGETDADOS('NTH', 1, xFilial('NTH') + cTpHon + "NT0_PERFIX", "NTH_VISIV")) == 1 //Verifica se o campo está visível
						oStruct:SetProperty("NT0_PERFIX", MVC_VIEW_CANCHANGE, .T.)
					EndIf
					If Val(JURGETDADOS('NTH', 1, xFilial('NTH') + cTpHon + "NT0_PEREX", "NTH_VISIV")) == 1 //Verifica se o campo está visível
						oStruct:SetProperty("NT0_PEREX", MVC_VIEW_CANCHANGE, .T.)
					EndIf
					If Val(JURGETDADOS('NTH', 1, xFilial('NTH') + cTpHon + "NT0_TPCEXC", "NTH_VISIV")) == 1
						oStruct:SetProperty("NT0_TPCEXC", MVC_VIEW_CANCHANGE, .T.)
					EndIf
					If Val(JURGETDADOS('NTH', 1, xFilial('NTH') + cTpHon + "NT0_LIMEXH", "NTH_VISIV")) == 1
						oStruct:SetProperty("NT0_LIMEXH", MVC_VIEW_CANCHANGE, .T.)
					EndIf
					If Val(JURGETDADOS('NTH', 1, xFilial('NTH') + cTpHon + "NT0_PERCD", "NTH_VISIV")) == 1
						oStruct:SetProperty("NT0_PERCD", MVC_VIEW_CANCHANGE, .T.)
					EndIf

				Else
					oStruct:SetProperty("*", MVC_VIEW_CANCHANGE, .F.)
				EndIf

				J096EdtNT1(oModel) //Libera NT1 para edição de acordo com Tipo de Hono

			EndIf
		Else
			J096EdtNT1(oModel) //Libera NT1 para edição de acordo com Tipo de Hono
		EndIf

	Else
		oView:CreateHorizontalBox( 'FORMFIELD', 100 )
		oView:SetOwnerView( 'JURA96CDF_VIEW', 'FORMFIELD' )
	EndIf
	oView:SetDescription( STR0019 ) // "Condições de Faturamento"
	oView:SetOperation( oModel:GetOperation() )

	If (JUR96TPFIX(cTpHon)) .And. !(JUR96FAIXA(cTpHon))
		oView:AddUserButton( STR0112, 'MENURUN', { |oView| J96CorrCDF(oView:GetModel()) } ) //"Corrigir Valor"
		oView:AddUserButton( STR0114, 'NOCHECKED', { |oView| J96WOFixo(oView) } ) //"WO"
		If !(AllTrim(JURGETDADOS('NTH', 1, xFilial('NTH') + cTpHon + "NT0_PARCE", "NTH_VLPAD")) == "2" .And. ;
		     AllTrim(JURGETDADOS('NTH', 1, xFilial('NTH') + cTpHon + "NT0_PARFIX", "NTH_VLPAD")) == "2")
			oView:AddUserButton( STR0126, 'MENURUN', { |oModel| J096Parcela(oModel, nBotaoAtv) } )//"Parcelas"
		EndIf
	EndIf

	J96DtRef() // Sugere a data de referencia inicial da paracela de fixo com base no caso mais antigo

	aArmzNT0 := J096ArmzNT0(oModel, nBotaoAtv)//Armazena Valores do NT0

	oView:SetCloseOnOk({|| .T.})

	oExecView:= FwViewExec():New()
	oExecView:setView(oView)
	oExecView:setReduction(30)
	oExecView:setTitle(cTitulo)
	oExecView:setOk(bOK)
	oExecView:openView(.F.)
EndIf

Return NIL

//-------------------------------------------------------------------
/*/{Protheus.doc} JURA96FXA
SubView de Faixa de Valores

@author David Gonçalves Fernandes
@since 26/05/09
@version 1.0
/*/
//-------------------------------------------------------------------
Function JURA96FXA( oViewPai )
Local oView      := Nil
Local oExecView  := Nil
Local oStruct    := Nil
Local oStructNTR := Nil
Local oStructNT1 := Nil
Local oStructNWE := Nil
Local lSubView   := .T.
Local nAt        := 0
Local lFixo      := .F.
Local oModel     := oViewPai:GetModel()
Local bOk        := { |oModel| J96BOKNTR( oModel, lSubView, BOTAOFXA, 'NTRDETAIL') }
Local oModelNT0  := oModel:GetModel('NT0MASTER')
Local cTitulo    := oModelNT0:GetValue('NT0_DTPHON')
Local cTpHon     := oModelNT0:GetValue('NT0_CTPHON')
Local nBotaoAtv  := BOTAOFXA // 2 = Faixa de Valores

If (nAt := J096TemCpo(BOTAOFXA)) == 0

	Return NIL

ElseIf J096ObrgOk(oModel, aCpoBotoes[nAt][CONFIG], STR0014) // "Fx.Val."

	oStruct    := FWFormStruct( 2, 'NT0', { |cCampo| Jur96Exibe( cCampo, aCpoBotoes[nAt][CONFIG] ) } )
	oStructNTR := FWFormStruct( 2, 'NTR' )
	If JUR96TPFIX(cTpHon) .And. JUR96FAIXA(cTpHon) //Verifica se o tipo de honorários cobra Fixo e se o campo “NT0_FXABM" ou o “NT0_FXENCM” estão visíveis (NTH_VISIV = “1”) (Quantidade de Casos).
		oStructNT1 := FWFormStruct( 2, 'NT1' )
		oStructNWE := FWFormStruct( 2, 'NWE' )
		lFixo := .T.
	EndIf

	oStructNTR:RemoveField( 'NTR_CCONTR' )
	oStructNTR:RemoveField( 'NTR_COD' )

	If lFixo
		oStructNT1:RemoveField('NT1_CCONTR')
		oStructNT1:RemoveField('NT1_SEQUEN')
		oStructNT1:RemoveField('NT1_TKRET' )
		oStructNT1:RemoveField('NT1_DCONTR')    //campos virtuais utilizados na tela de emissão de fatura ( JURA203 )
		oStructNT1:RemoveField('NT1_CCLIEN')    //campos virtuais utilizados na tela de emissão de fatura ( JURA203 )
		oStructNT1:RemoveField('NT1_CLOJA' )    //campos virtuais utilizados na tela de emissão de fatura ( JURA203 )
		oStructNT1:RemoveField('NT1_DCLIEN')    //campos virtuais utilizados na tela de emissão de fatura ( JURA203 )
		oStructNT1:RemoveField('NT1_CTPHON')    //campos virtuais utilizados na tela de emissão de fatura ( JURA203 )
		oStructNT1:RemoveField('NT1_DTPHON')    //campos virtuais utilizados na tela de emissão de fatura ( JURA203 )
		oStructNT1:RemoveField('NT1_OK'    )
		oStructNWE:RemoveField('NWE_CFIXO' )
		If NT1->(ColumnPos("NT1_ACAOLD")) > 0
			oStructNT1:RemoveField('NT1_ACAOLD')
			oStructNT1:RemoveField('NT1_INSREV')
			oStructNT1:RemoveField('NT1_REVISA')	
		EndIf
		// Tratamento para permitir a digitação da quantidade de casos manualmente
		oStructNT1:SetProperty('NT1_QTDADE', MVC_VIEW_CANCHANGE, SuperGetMV("MV_JQTDAUT", .F., "1") == "2")
	EndIf

	JurSetAgrp( 'NT0',, oStruct )
	JurSetAgrp( 'NT0',, oStruct )
	JurSetAgrp( 'NT0',, oStruct )

	oView := FWFormView():New( oViewPai )
	oView:SetModel( oModel )

	oView:AddField( 'JURA96FXA_VIEW' , oStruct   , 'NT0MASTER' )
	oView:AddGrid(  'JURA096_GRIDNTR', oStructNTR, 'NTRDETAIL' )
	If lFixo
		oView:AddGrid( 'JURA096_GRIDNT1', oStructNT1, 'NT1DETAIL' )
		oView:AddIncrementField('NT1DETAIL', 'NT1_PARC')

		oView:AddGrid( 'JURA096_GRIDNWE', oStructNWE, 'NWEDETAIL' )
		oView:SetNoDeleteLine('JURA096_GRIDNWE')
		oView:SetNoInsertLine('JURA096_GRIDNWE')
		oView:SetNoUpdateLine('JURA096_GRIDNWE')
	EndIf

	oView:CreateHorizontalBox( "BOX_A01_F01", 30 )
	oView:CreateHorizontalBox( "BOX_A01_F02", 70 )

	oView:CreateFolder('FOLDER_02','BOX_A01_F02')

	oView:AddSheet('FOLDER_02','ABA_01_01', STR0020 )  //"Faixa de Valores"
	If lFixo
		oView:AddSheet('FOLDER_02','ABA_01_02', STR0163 )  //"Parcelas"
		oView:AddSheet('FOLDER_02','ABA_01_03', STR0164 )  //"Faturamento"
	EndIf

	oView:CreateHorizontalBox('BOX_A01_F02_01',100,,,'FOLDER_02','ABA_01_01')
	oView:CreateHorizontalBox('BOX_A01_F02_02',100,,,'FOLDER_02','ABA_01_02')
	oView:CreateHorizontalBox('BOX_A01_F02_03',100,,,'FOLDER_02','ABA_01_03')

	oView:SetOwnerView( 'JURA96FXA_VIEW' , 'BOX_A01_F01' )
	oView:SetOwnerView( 'JURA096_GRIDNTR', 'BOX_A01_F02_01' )
	If lFixo
		oView:SetOwnerView( 'JURA096_GRIDNT1', 'BOX_A01_F02_02' )
		oView:SetOwnerView( 'JURA096_GRIDNWE', 'BOX_A01_F02_03' )
	EndIf

	oView:SetDescription( STR0020 ) // "Faixa de Valores"

	oView:SetOperation( oModel:GetOperation() )

	If lFixo
		oView:AddUserButton( STR0112, 'MENURUN',   { |oView| J96CorrCDF(oView:GetModel()) } ) //"Corrigir Valor"
		oView:AddUserButton( STR0113, 'MENURUN',   { |oView| J96CalcCDF(oView:GetModel()) } ) //"Calcular"
		oView:AddUserButton( STR0114, 'NOCHECKED', { |oView| J96WOFixo(oView) } ) //"WO"
		oView:AddUserButton( STR0126, 'MENURUN',   { |oModel| J096Parcela(oModel, nBotaoAtv) } )//"Parcelar"
		J096EdtNT1(oModel)
	EndIf

	oView:SetCloseOnOk({|| .T.})

	oExecView:= FwViewExec():New()
	oExecView:setView(oView)
	oExecView:setReduction(30)
	oExecView:setTitle(cTitulo)
	oExecView:setOk(bOK)
	oExecView:openView(.F.)

EndIf

Return NIL

//-------------------------------------------------------------------
/*/{Protheus.doc} JUR96BOK
TudoOk dos botoes com SubView

@obs Função chamada na Automação.

@author David Gonçalves Fernandes
@since 26/05/09
@version 1.0
/*/
//-------------------------------------------------------------------
Function JUR96BOK( oModel, lSubView, nBotao, cId )
Local aArea       := GetArea()
Local aAreaNTH    := NTH->( GetArea() )
Local aErro       := {}
Local lRet        := .T.
Local nI          := 0
Local oModelNT0   := oModel:GetModel('NT0MASTER')
Local cCTPHON     := oModelNT0:GetValue('NT0_CTPHON' )
Local cTpCalc     := oModelNT0:GetValue('NT0_CALFX' )
Local nAt         := aScan( aCpoBotoes, { |x| x[CTPHON] == cCTPHON .AND. X[BOTAO] == nBotao} )
Local cCampo      := ""
Local cMsg        := ""
Local oModelNT1   := oModel:GetModel('NT1DETAIL')
Local nQtdLines   := oModelNT1:GetQtdLine()
Local oModelNTR   := Nil
Local lDt         := .T.
Local dDataNT0    := oModelNT0:GetValue('NT0_DTBASE')
Local cTpCorr     := oModelNT0:GetValue('NT0_TPCORR')
Local lQtdCas     := Iif(JUR96FAIXA(cCTPHON), .T., .F.)
Local nLinhaAtu   := 0
Local lParcAut    := J96TPHPAut(cCTPHON)
Local lParcDef    := !lParcAut .And. JurGetDados("NTH", 1, xFilial("NTH") + cCTPHON + "NT0_QTPARC", "NTH_VISIV") == "1"
Local lSmartUI    := FindFunction("JurIsSmartUI") .And. JurIsSmartUI() // Proteção @12.1.2410

cUser := '2'  // Alterações feitas pelo sistema, deve permitir a manipulação automática das parcelas

lRet := J096VlDtNT1(oModel) //Valida Datas do Grid NT1

If lRet  // Quando o campo 'NT0_DTBASE' não for obrigatório, mas o campo NT0_TPCORR for diferente de '1', obrigar a digitaçõa do campo: NT0_DTBASE.
	NTH->(DbSetOrder(1)) // NTH_FILIAL+NTH_CTPHON+NTH_CAMPO
	If NTH->(DbSeek(xFilial("NTH") + cCTPHON + "NT0_DTBASE")) .And. NTH->NTH_OBRIGA <> "1"
		If Empty(dDataNT0) .And. AllTrim(cTpCorr) <> "1"
			lRet := .F.
			ApMsgInfo(STR0185) // "O campo 'Data Base' deve ser preenchido."
		EndIf
	EndIf

EndIf

If lRet
	For nI := 1 To Len( aCpoBotoes[nAt][CONFIG] )
		cCampo := AllTrim( aCpoBotoes[nAt][CONFIG][nI][CAMPO] )
		If aCpoBotoes[nAt][CONFIG][nI][OBRIGA] .And. Empty( FwFldGet( cCampo ) )
			lRet := .F.
			Do Case
			Case nBotao == BOTAOCDF
				// #"Botão Cond. Fat.: " ##"O campo " ###") não foi preenchido"
				JurMsgErro( STR0214+CRLF+STR0098 + AllTrim( RetTitle( cCampo ) ) + " (" + cCampo + STR0022 )
			Case nBotao == BOTAOFXA
				JurMsgErro( STR0082 + AllTrim( RetTitle( cCampo ) ) + " (" + cCampo + STR0022 )
			End Case
			Exit
		EndIf
		If (cCampo == 'NT0_DTREFI' .Or. cCampo == 'NT0_DTVENC') .And. aCpoBotoes[nAt][CONFIG][nI][VISIV] == .F. //Analisa se os campos de Data está visível
			lDt := .F.
		EndIf
	Next
EndIf

// Valida a situação do contrato, se o cliente for provisorio o contrato tambem deve ser
Iif(lRet, lRet := J096VldDef(), )

If lRet .And. cId = 'NT1DETAIL' .And. cTpCorr == "2" .And. Empty(oModelNT0:GetValue("NT0_CINDIC"))
	lRet := JurMsgErro( STR0097 )// "É preciso preencher o indice!"
EndIf

If lRet
	lRet := oModel:VldData( cId )
	If !lRet
		aErro := oModel:GetErrorMessage()
		JurMsgErro( aErro[6] )
	EndIf
EndIf

If lRet .And. cId = 'NTRDETAIL'

	oModelNTR := oModel:GetModel('NTRDETAIL')

	If J096TemCpo(BOTAOFXA, .F.) > 0

		If !oModelNTR:IsEmpty()
			If !JA125VLFX(oModelNTR, cId)
				lRet := .F.
			EndIf

			If lRet
				If !JA125VLTP( oModelNTR, cId, cTpCalc )
					lRet := .F.
				EndIf
			EndIf
		Else
			lRet := JurMsgErro( STR0083 ) // "A faixa de faturamento deve ser preenchida."
		EndIf

		// Valida se há faixa iniciada em 0 e uma terminada em 99999.
		If lRet .And. !JVldPerFx(oModelNTR, "NTR_VLINI", "NTR_VLFIM", lQtdCas )
			lRet := .F.
		EndIf

		// Valida se há lacunas entre as faixas
		If lRet .And. !JVldLacFx(oModelNTR, "NTR_VLINI", "NTR_VLFIM", lQtdCas )
			lRet := .F.
		EndIf

	EndIf

EndIf

If lRet .And. cId = 'NT1DETAIL'
	nLinhaAtu := oModelNT1:GetLine()
	For nI := 1 To nQtdLines

		If oModelNT1:IsDeleted(nI)
			Loop
		EndIf
		If !Empty(oModelNT1:GetValue("NT1_DATAIN", nI)) .Or. !Empty(oModelNT1:GetValue("NT1_DATAFI", nI)) .Or. !Empty(oModelNT1:GetValue("NT1_VALORB", nI)) .Or. ;
		   !Empty(oModelNT1:GetValue("NT1_DATAVE", nI)) .Or. !Empty(oModelNT1:GetValue("NT1_DESCRI", nI)) .Or. !Empty(oModelNT1:GetValue("NT1_CMOEDA", nI))
			Do Case
			Case (lParcAut .Or. lParcDef) .And. Empty(oModelNT1:GetValue("NT1_DATAIN", nI))
				lRet := JurMsgErro(STR0133 + oModelNT1:GetValue("NT1_PARC", nI) + ". " + STR0198 ) // Erro na Parcela ### "O campo 'Data Referencia Inicial' deve ser preenchido."
			Case (lParcAut .Or. lParcDef) .And. Empty(oModelNT1:GetValue("NT1_DATAFI", nI))
				lRet := JurMsgErro(STR0133 + oModelNT1:GetValue("NT1_PARC", nI) + ". " + STR0199) // Erro na Parcela ### "O campo 'Data Referencia Final' deve ser preenchido."
			Case (lParcAut .Or. lParcDef) .And. Empty(oModelNT1:GetValue("NT1_VALORB", nI))
				lRet := JurMsgErro(STR0133 + oModelNT1:GetValue("NT1_PARC", nI) + ". " + STR0200) // Erro na Parcela ### "O campo 'Valor Base' deve ser preenchido."
			Case (lParcAut .Or. lParcDef) .And. Empty(oModelNT1:GetValue("NT1_DATAVE", nI))
				lRet := JurMsgErro(STR0133 + oModelNT1:GetValue("NT1_PARC", nI) + ". " + STR0201) // Erro na Parcela ### "O campo 'Data de Vencimento' deve ser preenchido."
			Case Empty(oModelNT1:GetValue("NT1_DESCRI", nI))
				lRet := JurMsgErro(STR0133 + oModelNT1:GetValue("NT1_PARC", nI) + ". " + STR0202) // Erro na Parcela ### "O campo 'Descricao' deve ser preenchido."
			Case (lParcAut .Or. lParcDef) .And. Empty(oModelNT1:GetValue("NT1_CMOEDA", nI))
				lRet := JurMsgErro(STR0133 + oModelNT1:GetValue("NT1_PARC", nI) + ". " + STR0203) // Erro na Parcela ### "O campo 'Codigo Moeda Fatura' deve ser preenchido."
			EndCase
		EndIf

		If lRet
			lRet := J96VerPreFat(oModel, nI, /*lCanPreFat*/, /*lSmartUI*/, /*cMsgPrefat*/, @cMsg)
		EndIf

		If !lRet
			Exit
		EndIf
	Next nI

	If !Empty(cMsg) .And. !lSmartUI .And. !FwIsInCallStack("JUR96TUDOK") .And. !IsBlind()
		JurErrLog(cMsg, STR0150) // Atenção
	EndIf

	oModelNT1:GoLine(nLinhaAtu)
EndIf

// lSubView: na Tela de Contrato não é informada, só é informado no botão Confirmar da tela "Cond de Faturamente" e "Faixa Faturamento"
If lRet .And. lSubView .And. JUR96TPFIX(cCTPHON)
	J096ConfPa(oModel, nBotao)
EndIf

If lRet .And. lSubView
	lCtlCndFat:= .T.
EndIf

cUser := '1' // Retorna a alterações do usuário

RestArea( aAreaNTH )
RestArea( aArea )

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} JUR096CPO
Carga dos campos configuraveis

@author David Gonçalves Fernandes
@since 26/05/09
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function JUR096CPO()
Local aArea     := GetArea()
Local aAreaNTH  := NTH->( GetArea() )
Local cFilNTH   := xFilial( 'NTH' )
Local nAt       := 0
Local cConcat   := ""

NTH->( dbSetOrder( 1 ) )
NTH->( DbSeek( cFilNTH ) )

While !NTH->( EOF() )

	If ( nAt := aScan( aCpoBotoes, { |x| x[CTPHON] == NTH->NTH_CTPHON .AND. X[BOTAO] == NTH->NTH_BOTAO } ) ) == 0
		aAdd( aCpoBotoes, { NTH->NTH_CTPHON, NTH->NTH_BOTAO, {} } )
		nAt := Len( aCpoBotoes )
	EndIf

	If GetSx3Cache(NTH->NTH_CAMPO, 'X3_TIPO') == 'C'
		cConcat := "'"
	Else
		cConcat := ""
	EndIf

	aAdd( aCpoBotoes[nAt][CONFIG], { NTH->NTH_CAMPO, &( '{|| ' +cConcat+ AllTrim( NTH->NTH_VLPAD ) +cConcat+ ' }' ), ( NTH->NTH_VISIV == '1' ), ( NTH->NTH_OBRIGA == '1' ) } )

	If aScan( aCpoInBot, { |x| x[1] == NTH->NTH_CAMPO } ) == 0
		aAdd( aCpoInBot, { NTH->NTH_CAMPO, } )
	EndIf

	NTH->( dbSkip() )
EndDo

NTH->(RestArea( aAreaNTH ))
RestArea( aArea )

Return NIL

//-------------------------------------------------------------------
/*/{Protheus.doc} JUR96INI
Inicializacao dos campos configuraveis na troca do tipo

@author David Gonçalves Fernandes
@since 26/05/09
@version 1.0
/*/
//-------------------------------------------------------------------
Function JUR96INI()
Local cCTPHON := FwFldGet( 'NT0_CTPHON' )
Local lRet    := cCTPHON
Local nI      := 0
Local nJ      := 0
Local oModel  := FwModelActive()
Local aErro   := {}
Local cMsg    := ''
Local cCampo  := ''
Local lErro   := .F.

For nI := 1 To Len( aCpoBotoes )

	If aCpoBotoes[nI][CTPHON] == cCTPHON

		For nJ := 1 To Len( aCpoBotoes[nI][CONFIG] )
			cCampo := AllTrim( aCpoBotoes[nI][CONFIG][nJ][CAMPO]  )

			If !oModel:LoadValue( FwFindId( cCampo ), cCampo, Eval( aCpoBotoes[nI][CONFIG][nJ][INICIA] ) )

				aErro := oModel:GetErrorMessage()

				cMsg  := STR0024 + cCampo + ; // "Não foi possível inicializar o campo "
				STR0025  +  GetCbSource( aCpoBotoes[nI][CONFIG][nJ][INICIA] ) + CRLF + aErro[6] //" com o conteúdo "

				JurMsgErro( cMsg )

				Alert( cMsg )

				lErro := .T.

				Exit

			EndIf

			If lErro
				Exit
			EndIf

		Next

	EndIf

Next

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} JUR96EXIBE
Verificacao dos campos a serem exibidos na SubView

@author David Gonçalves Fernandes
@since 26/05/09
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function JUR96EXIBE( pCampo, paCampos )
Local lRet      := .F.
Local vPosicao  := 0

vPosicao := aScan( paCampos, { |x| PadR( x[CAMPO], 10 ) == PadR( pCampo, 10 ) } )

lRet := ( vPosicao > 0 .AND. paCampos[vPosicao][VISIV] )

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} JUR96TPFIX
Verifica se o Tipo de Honorários é Fixo

@author Fabio Crespo Arruda
@since 22/08/09
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function JUR96TPFIX(cTpHon)
Local lCobraFix := .F.

lCobraFix := JurGetDados("NRA", 1, xFilial("NRA") + cTpHon, "NRA_COBRAF") == "1"

Return lCobraFix

//-------------------------------------------------------------------
/*/{Protheus.doc} JUR96FAIXA
Verifica se o campo “NT0_FXABM" ou o “NT0_FXENCM” estão visíveis
(NTH_VISIV = “1”) na configuração de Tipo de Honorários, o que
caracteriza os tipos de honorários por Faixa - Quantidade de Casos.

@author Cristina Cintra
@since 10/02/2014
@version 1.0
/*/
//-------------------------------------------------------------------
Function JUR96FAIXA( cTpHon )
Local lRet      := .F.
Local aArea     := GetArea()
Local aAreaNTH  := NTH->( GetArea() )

Default cTpHon  := FwFldGet('NT0_CTPHON')

If !Empty(cTpHon)
	NTH->( dbSetOrder( 1 ) ) //NTH_FILIAL+NTH_CTPHON+NTH_CAMPO
	If NTH->( dbSeek( xFilial('NTH') + cTpHon + 'NT0_FXABM' ) )
		lRet := NTH->NTH_VISIV == '1'
		If !lRet
			If NTH->( dbSeek( xFilial('NTH') + cTpHon + 'NT0_FXENCM' ) )
				lRet := NTH->NTH_VISIV == '1'
			EndIf
		EndIf
	EndIf
EndIf

NTH->(RestArea( aAreaNTH ))
RestArea( aArea )

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} JUR96TUDOK
Valida os campos na hora de salvar

@author Fabio Crespo Arruda
@since 22/08/09
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function JUR96TUDOK(oModel)
	Local lRet       := .T.
	Local lSubView   := .F.
	Local lCasMaeNUT := .F.
	Local aArea      := GetArea()
	Local aQtTD      := 0
	Local aTpAti     := {}
	Local aTpDsp     := {}
	Local aNTJAti    := {}
	Local aNTKDsp    := {}
	Local aCodPre    := {}
	Local oModelNT0  := oModel:GetModel('NT0MASTER')
	Local oModelNUT  := oModel:GetModel('NUTDETAIL')
	Local oModelNTK  := oModel:GetModel('NTKDETAIL')
	Local oModelNTJ  := oModel:GetModel('NTJDETAIL')
	Local nQtdNUT    := oModelNUT:GetQtdLine()
	Local nI         := 0
	Local nLinNTJ    := oModelNTJ:GetLine()
	Local nLinNTK    := oModelNTK:GetLine()
	Local nLinNUT    := oModelNUT:GetLine()
	Local nPosAti    := 0
	Local nPosDsp    := 0
	Local nQtdDel    := 0
	Local nFor       := 0
	Local nLenCod    := 0
	Local cQuery     := ""
	Local cMsgErr    := ""
	Local cCodCtr    := oModelNT0:GetValue("NT0_COD")
	Local cLojaAuto  := ""
	Local cTpHon     := ""
	Local lCobraH    := .T.
	Local lSmartUI   := FindFunction("JurIsSmartUI") .And. JurIsSmartUI() // Proteção @12.1.2410

If oModel:GetOperation() == OP_INCLUIR .Or. oModel:GetOperation() == OP_ALTERAR

	If !JUR96TPHAT(oModel)
		lRet := JurMsgErro(STR0028) //"Não é possível utilizar este tipo de honorários, pois não está ativo"
	EndIf

	If lRet .And. (oModel:GetOperation() == OP_INCLUIR .Or. oModel:IsFieldUpdated("NT0MASTER", "NT0_DTVIGI") .Or. oModel:IsFieldUpdated("NT0MASTER", "NT0_DTVIGF"))
		lRet := J096VigPar(oModel) // Valida as parcelas com a data de vigência
	EndIf

	If lRet .And. (oModelNT0:GetValue("NT0_DISCAS") = "2" .And. Empty(oModelNT0:GetValue("NT0_TITFAT")) )
		lRet := JurMsgErro(STR0029) // "É necessário preencher o Título de Faturamento quando este não discriminado na fatura"
	EndIf

	If lRet .And. oModelNT0:GetValue("NT0_ATIVO") == '1' // Indica que o contrato está ativo
		nQtdDel := 0
		For nI := 1 To nQtdNUT
			If oModelNUT:IsDeleted(nI)
				nQtdDel += 1
			EndIf

			If Empty(oModelNUT:GetValue('NUT_CCASO', nI)) .And. !oModelNUT:IsDeleted(nI) .And. !IsInCallStack("JURA070")
				lRet := JurMsgErro( STR0137 ) // "É obrigatório informar o número do caso!"
				Exit
			EndIf
		Next nI
	EndIf

	If lRet .And. nQtdDel == nQtdNUT .And. !IsInCallStack("JURA070") .And. oModelNT0:GetValue("NT0_ATIVO") == '1' // Indica que o contrato está ativo
		lRet := JurMsgErro( STR0108 ) // "É obrigatório vincular pelo menos um caso "
	EndIf

	If lRet
		If !JUR96BOK( oModel, lSubView, BOTAOFXA, 'NTRDETAIL' ) .Or. ;
			!JUR96BOK( oModel, lSubView, BOTAOCDF, 'NT1DETAIL' )
			lRet := .F.
		Endif
	EndIf

	If lRet .AND. oModelNT0:GetValue("NT0_SIT") == '2'   //Obriga os preenchimeo para contr. definitivo
		If Empty(oModelNT0:GetValue("NT0_CPART1"))
			lRet := JurMsgErro(I18N(STR0208, {RetTitle("NT0_SIGLA1")} ) ) //"O campo '#1' deve ser preenchido quando o contrato for definitivo. Verifique!"
		EndIf
		If lRet .AND.  Empty(oModelNT0:GetValue("NT0_CESCR"))
			lRet := JurMsgErro(STR0098 + Alltrim(RetTitle('NT0_CESCR')) + " (NT0_CESCR)" +  STR0099) //O campo "" deve ser preenchido quando o contrato for definitivo
		EndIf
	EndIf

	If lRet
		lRet := JurVldPag(oModel) //Validação de pagadores
	EndIf

	//Verifica o preenchimento do Cliente/Loja/Caso mãe e se ele faz parte da NUT
	If lRet .And. NT0->(ColumnPos( "NT0_CASMAE" )) > 0 .And. oModelNT0:GetValue("NT0_CASMAE") == '1'
		If (Empty(oModelNT0:GetValue("NT0_CCLICM")) .Or. Empty(oModelNT0:GetValue("NT0_CLOJCM")) .Or. Empty(oModelNT0:GetValue("NT0_CCASCM")))
			lRet := .F.
			cLojaAuto := SuperGetMv( "MV_JLOJAUT", .F., "2", ) //Indica se a Loja do Caso deve ser preenchida automaticamente. (1-Sim; 2-Não)
			// STR0222="Para utilizar o conceito de Alocação Unificada/Caso Mãe é necessário o preenchimento das informações do Cliente/Caso no Contrato." STR0223="Verifique o preenchimento dos seguintes campos:"
			If cLojaAuto == "2"
				JurMsgErro( STR0222,, STR0223 + CRLF + Alltrim(RetTitle('NT0_CASMAE')) + CRLF + Alltrim(RetTitle('NT0_CCLICM')) + CRLF + Alltrim(RetTitle('NT0_CLOJCM')) + CRLF + Alltrim(RetTitle('NT0_CCASCM ')) )
			Else
				JurMsgErro( STR0222,, STR0223 + CRLF + Alltrim(RetTitle('NT0_CASMAE')) + CRLF + Alltrim(RetTitle('NT0_CCLICM')) + CRLF + Alltrim(RetTitle('NT0_CCASCM ')) )
			EndIf
		Else
			For nI := 1 To nQtdNUT
				oModelNUT:GoLine( nI )
				If !oModelNUT:IsDeleted(nI) .And. (oModelNT0:GetValue("NT0_CCLICM") == oModelNUT:GetValue("NUT_CCLIEN")) .And. (oModelNT0:GetValue("NT0_CLOJCM") == oModelNUT:GetValue("NUT_CLOJA")) ;
				   .And. (oModelNT0:GetValue("NT0_CCASCM") == oModelNUT:GetValue("NUT_CCASO"))
					lCasMaeNUT := .T.
					Exit
				EndIf
			Next nI
			oModelNUT:GoLine( nLinNUT )
			If !lCasMaeNUT
				lRet := JurMsgErro(STR0224,, STR0225) //"Necessário que o Caso Mãe esteja relacionado a este Contrato!" "Verifique os casos vinculados a este contrato adicionando o caso mãe, ou troque o caso mãe para um vinculado a este contrato."
			EndIf
		EndIf
	EndIf

	If lRet .And. Empty(oModelNT0:GetValue("NT0_DTVIGI")) .And. !Empty(oModelNT0:GetValue("NT0_DTVIGF"))
		lRet := JurMsgErro(STR0228) //'Data inicial de vigência não está preenchida'
	ElseIf lRet .And. !Empty(oModelNT0:GetValue("NT0_DTVIGI")) .And. Empty(oModelNT0:GetValue("NT0_DTVIGF"))
		lRet := oModelNT0:SetValue("NT0_DTVIGF", CToD('31/12/9999'))
	EndIf

	If lRet // Valida Situação do Contrato x Situação do Cliente/Caso
		lRet := JA096VlSit(oModel)
	EndIf

	If lRet 
		// Valida se o contrato tem casos vinculados a outros contratos com vigência
		lRet := J096VldVig(oModel)
	EndIf

	If lRet .And. Empty(oModelNT0:GetValue("NT0_DTVIGI")) .And. Empty(oModelNT0:GetValue("NT0_DTVIGF"))
		// Valida se tem mais de um contrato com cobrança de hora, despesa e tabelado para o mesmo caso
		// Essa validação é feita somente quando os contratos não possuem vigência. Já que usando vigência
		// é possível ter vários contratos vinculados a um caso com mesmo tipo de cobrança.
		lRet := J096VldCob(oModel)
	EndIf

EndIf

If lRet .And. (oModel:IsFieldUpdated("NT0MASTER", "NT0_TITFAT") .Or. oModel:IsFieldUpdated("NT0MASTER", "NT0_NOME"))
	J96ATUNT5(oModel:GetModel("NT5DETAIL"))
EndIf

If lRet .And. oModel:GetOperation() == OP_INCLUIR
	// Verifica se existe Tipo de Atividade não cobrável no contrato
	If oModelNTJ:IsEmpty()
		aTpAti := J096QTDE('NUB', '2', oModelNT0:GetValue("NT0_CCLIEN"), oModelNT0:GetValue("NT0_CLOJA"))
		For nI := 1 To Len(aTpAti)
			If oModelNTJ:GetQtdLine() == 1 .And. Empty(oModelNTJ:GetValue("NTJ_CTPATV"))
				oModelNTJ:GoLine( 1 )
			Else
				oModelNTJ:AddLine()
			EndIf
			oModel:SetValue("NTJDETAIL", "NTJ_CTPATV", aTpAti[nI])
		Next

	Else
		aTpAti := J096QTDE('NUB', '2', oModelNT0:GetValue("NT0_CCLIEN"), oModelNT0:GetValue("NT0_CLOJA"))
		For nI := 1 To oModelNTJ:GetQtdLine()
			oModelNTJ:GoLine( nI )
			If !oModelNTJ:IsDeleted( nI )
				aadd(aNTJAti, oModelNTJ:GetValue("NTJ_CTPATV") )
			EndIf
		Next
		aSort(aTpAti)
		aSort(aNTJAti)
		If Len(aTpAti) == Len(aNTJAti)
			For nI := 1 To Len(aTpAti)
				If aTpAti[nI] == aNTJAti[nI]
					nPosAti := 1
				Else
					nPosAti := 0
					Exit
				EndIf
			Next
		Else
			nPosAti := 0
		EndIf
		If nPosAti = 0 .And. !lSmartUI // Caso esteja sendo executado pelo Smart UI ignora a atualização no cadastro do cliente
			If ApMsgYesNo( STR0104 )  //"O cadastro de tipo de atividade não cobrável do contrato está diferente do cadastro de cliente. Deseja atualizar com o cadastro do cliente?"
				For nI := 1 To oModelNTJ:GetQtdLine()
					oModelNTJ:GoLine( nI )
					If !oModelNTJ:IsDeleted( nI )
						oModelNTJ:DeleteLine()
					EndIf
				Next

				For nI := 1 To Len(aTpAti)
					oModelNTJ:AddLine()
					oModel:SetValue("NTJDETAIL", "NTJ_CTPATV", aTpAti[nI])
				Next
			EndIf
		EndIf
		oModelNTJ:GoLine( nLinNTJ )
	EndIf

	// Verifica se existe Tipo de Despesa não cobrável no contrato
	If oModelNTK:IsEmpty()

		aTpDsp := J096QTDE('NUC', '2', oModelNT0:GetValue("NT0_CCLIEN"), oModelNT0:GetValue("NT0_CLOJA"))
		For nI := 1 To Len(aTpDsp)
			If oModelNTK:GetQtdLine() == 1 .And. Empty(oModelNTK:GetValue("NTK_CTPDSP"))
				oModelNTK:GoLine( 1 )
			Else
				oModelNTK:AddLine()
			EndIf
			oModel:SetValue("NTKDETAIL", "NTK_CTPDSP", aTpDsp[nI])
		Next

	Else
		aTpDsp := J096QTDE('NUC', '2', oModelNT0:GetValue("NT0_CCLIEN"), oModelNT0:GetValue("NT0_CLOJA"))
		For nI := 1 To oModelNTK:GetQtdLine()
			oModelNTK:GoLine( nI )
			If !oModelNTK:IsDeleted( nI )
				aAdd(aNTKDsp, oModelNTK:GetValue("NTK_CTPDSP") )
			EndIf
		Next
		aSort(aTpDsp)
		aSort(aNTKDsp)
		If Len(aTpDsp) == Len(aNTKDsp)
			For nI := 1 To Len(aTpDsp)
				If aTpDsp[nI] == aNTKDsp[nI]
					nPosDsp := 1
				Else
					nPosDsp := 0
					Exit
				EndIf
			Next
		Else
			nPosDsp := 0
		EndIf
		If nPosDsp = 0 .And. !lSmartUI // Caso esteja sendo executado pelo Smart UI ignora a atualização no cadastro do cliente
			If ApMsgYesNo( STR0105 ) // "O cadastro de tipo de despesa não cobrável do contrato está diferente do cadastro de cliente. Deseja atualizar com o cadastro do cliente?"
				For nI := 1 To oModelNTK:GetQtdLine()
					oModelNTK:GoLine( nI )
					If !oModelNTK:IsDeleted( nI )
						oModelNTK:DeleteLine()
					EndIf
				Next

				For nI := 1 To Len(aTpDsp)
					oModelNTK:AddLine()
					oModel:SetValue("NTKDETAIL", "NTK_CTPDSP", aTpDsp[nI])
				Next
			EndIf
		EndIf
		oModelNTK:GoLine( nLinNTK )
	EndIf
EndIf

If lRet .And. !IsInCallStack("JURA070") .And. oModelNT0:GetValue("NT0_ATIVO") == "1"
	cTpHon  := oModelNT0:GetValue("NT0_CTPHON")
	lCobraH := J096CHon(cTpHon) // Indica se o contrato cobra honorários
	For nI := 1 To nQtdNUT
		If !oModelNUT:IsDeleted(nI) .And. oModelNUT:IsUpdated(nI)
			oModelNUT:GoLine(nI)
			lRet := J96VldCaso(cTpHon, lCobraH)
			If !lRet
				Exit
			EndIf
		EndIf
	Next
	oModelNUT:GoLine(nLinNUT)
EndIf

If lRet .And. oModel:GetOperation() == OP_ALTERAR

	If J96AltCtr(oModel)

		cQuery := " select distinct NX0.NX0_COD "
		cQuery += " from " + RetSqlName("NX8") + " NX8 "
		cQuery += " Inner Join " + RetSqlName("NX0") + " NX0 "
		cQuery +=         " on( NX0.NX0_FILIAL = '" + xFilial("NX0") + "'"
		cQuery +=             " and NX0.NX0_COD = NX8.NX8_CPREFT "
		cQuery +=             " and NX0.NX0_SITUAC IN ('2','3','4','5','6','7','9','A','B') "
		cQuery +=             " and NX0.D_E_L_E_T_ = ' ') "
		cQuery += " where NX8.NX8_FILIAL = '" + xFilial("NX8") + "' "
		cQuery +=   " and NX8.NX8_CCONTR = '" + cCodCtr + "' "
		cQuery +=   " and NX8.D_E_L_E_T_ = ' ' "
		cQuery +=   " order by NX0.NX0_COD "

		aCodPre := JurSQL(cQuery, "*")
		nLenCod := Len(aCodPre)

		If nLenCod > 0 .And. Empty(_aPreFtVld) .And. !FwIsInCallStack("JA095NCaso") // Se não for inclusão de caso no contrato através do SIGAJURI
			cMsgErr := STR0151 // "Atenção: as alterações feitas não refletirão na(s) pré-fatura(s) em aberto: "
			For nFor := 1 To nLenCod
				cMsgErr += aCodPre[nFor][1] + IIf(nFor < nLenCod, ", ", ".")
			Next nFor
			MsgAlert(cMsgErr, STR0150) //"Atenção"
		EndIf

	EndIf
EndIf

If oModel:GetOperation() == OP_EXCLUIR

	cQuery := "SELECT NW3.NW3_CJCONT FROM " + RetSqlName("NW3") + " NW3 "
	cQuery += " Where NW3.NW3_FILIAL = '" + xFilial("NW3") + "' "
	cQuery += " AND EXISTS (SELECT NT0.R_E_C_N_O_ FROM " + RetSqlName("NT0") + " NT0 "
	cQuery += " WHERE NT0.NT0_FILIAL = '" + xFilial("NT0") + "' "
	cQuery += " AND NT0.D_E_L_E_T_ = ' ' "
	cQuery += " AND NT0.NT0_COD = NW3.NW3_CCONTR "
	cQuery += " AND NW3.NW3_CCONTR = '" + cCodCtr +"') "
	cQuery += " AND NW3.D_E_L_E_T_ = ' ' "

	aQtTD := JurSQL(cQuery, "NW3_CJCONT")

	If Len(aQtTD) > 0
		lRet := JurMsgErro( STR0153 + aQtTD[1][1] + "." ) // "O contrato não pode ser excluido pois pertence a junção "
	EndIf

	If lRet .and. FwAliasInDic('OI4')
		J302Delete( xFilial('OI4'), cCodCtr )
	Endif

EndIf

If lRet .And. FindFunction("JurVldPIX") // Proteção
	lRet := JurVldPIX() //Validação do banco e cliente para pagamentos PIX
EndIf

RestArea( aArea )

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} JUR96TPHAT
Verifica se o Tipo de honorários esta ativo

@author Fabio Crespo Arruda
@since 22/08/09
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function JUR96TPHAT(oModel)
Local lRet   := .T.
Local aArea  := GetArea()
Local cAtivo := ''

If !Empty( oModel:GetValue('NT0MASTER', 'NT0_CTPHON') )
	cAtivo := JURGETDADOS('NRA', 1, xFilial('NRA') + oModel:GetValue('NT0MASTER', 'NT0_CTPHON'), 'NRA_ATIVO')
	lRet   := cAtivo == '1'
EndIf

RestArea( aArea )

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} JA96TIT
Preenche o Título do Contrato do campo de descrição
Uso Geral.

@Return cRet Retorna o título do caso

@author Fabio Crespo ARruda
@since 01/10/09
@version 1.0
/*/
//-------------------------------------------------------------------
Function JA96TIT(cCliente, cLoja, cCaso)
Local cRet       := ""

Default cCliente := ""
Default cLoja    := ""
Default cCaso    := ""

If IsInCallStack('JURA096') .Or. IsInCallStack('JURA056') .Or. IsInCallStack('JURA109')
	If !IsInCallStack('JURA096') .Or. NT0->NT0_COD == NUT->NUT_CCONTR
		If _cNumClien == "1"
			IIF(NVE->(IndexOrd()) <> 1, NVE->(DbSetOrder(1)), Nil)
			NVE->(MsSeek(xFilial('NVE') + cCliente + cLoja + cCaso))
		Else
			IIF(NVE->(IndexOrd()) <> 3, NVE->(DbSetOrder(3)), Nil)
			NVE->(MsSeek(xFilial("NVE") + cCaso))
		EndIf
		cRet := NVE->NVE_TITULO
	EndIf
EndIf

Return cRet

//-------------------------------------------------------------------
/*/{Protheus.doc} J96SA1NT0()
Criação da validação na consulta padrão de cliente para filtrar de acordo com o
grupo ou de acordo com o cliente do contrato

Uso Geral.
@Return nRet	         	Cliente e Loja
@sample
@author Fabio Crespo ARruda
@since 01/10/09
@version 1.0
/*/
//-------------------------------------------------------------------
Function J96SA1NT0()
Local oModel := FwModelActive()
Local cRet   := "@#@#"
Local cCampo := AllTrim(ReadVar())

If IsInCallStack('J203FilUsr')
	If !Empty(oGrClien:GetValue())
		cRet := "@#SA1->A1_GRPVEN == '" + oGrClien:GetValue() + "'@#"
	EndIf
Else
	If oModel:GetId() == 'JURA096'
		If !Empty(FwFldGet("NT0_CGRPCL"))
			//cRet := "@#SA1->A1_GRPVEN == '"+oModel:GetValue('NT0MASTER','NT0_CGRPCL')+"'@#"
		Else
			Do Case
				Case "NT0_" $ cCampo
					cRet := "@#@#"
				Case "NUT_" $ cCampo
					cRet := "@#SA1->A1_COD == '" + FwFldGet("NT0_CCLIEN") + "' .And. SA1->A1_LOJA == '" + FwFldGet("NT0_CLOJA") + "'@#"
			End Case
		EndIf
	EndIf
EndIf

Return cRet

//-------------------------------------------------------------------
/*/{Protheus.doc} Jur096VFim
Validação do valor Final no cadastro de faixa de valors do contrato

@Return lRet	.T./.F. As informações são válidas ou não

@author Claudio Donizete de Souza
@since 01/11/09
@version 1.0
/*/
//-------------------------------------------------------------------
Function Jur096VFim
Local lRet := M->&("NTR_VLFIM") >= FwFldGet("NTR_VLINI")

	If !lRet
		JurMsgErro(STR0115) //"Valor final deve ser maior ou igual ao valor inicial"
	EndIf

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} Jur096VIni
Validação do valor inicial no cadastro de faixa de valors do contrato

@Return lRet  .T./.F. As informações são válidas ou não

@author Claudio Donizete de Souza
@since 01/11/09
@version 1.0
/*/
//-------------------------------------------------------------------
Function Jur096VIni
Local lRet := M->&("NTR_VLINI") <= FwFldGet("NTR_VLFIM") .Or. FwFldGet("NTR_VLFIM") == 0

	If !lRet
		JurMsgErro(STR0116) //"Valor inicial deve ser menor ou igual ao valor final"
	EndIf

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} JA096CMBEF
Funções pré-Commit

@Return lRet	.T./.F. As informações são válidas ou não

@author Evaldo V. Batista
@since 17/11/2009
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function JA096CMBEF(oModel)
Local aArea      := GetArea()
Local oModelNVN  := oModel:GetModel("NVNDETAIL")
Local nQtdLines  := oModelNVN:GetQtdLine()
Local cContrato  := oModel:GetValue("NT0MASTER", "NT0_COD")
Local cFilAc8    := xFilial('AC8')
Local cFilEnt    := xFilial('NVN')
Local nX         := 0
Local cContato   := ""
Local cCodEnt    := ""
Local lRet       := .T.

If !oModelNVN:IsEmpty()

	For nX := 1 To nQtdLines
		cContato := oModelNVN:GetValue('NVN_CCONT', nX )
		cCodEnt  := oModelNVN:GetValue('NVN_COD'  , nX )
		
		// Relacao de Contatos x Entidade
		AC8->( dbSetOrder( 2 ) ) //AC8_FILIAL+AC8_ENTIDA+AC8_FILENT+AC8_CODENT+AC8_CODCON
		If AC8->( dbSeek( cFilAc8 + 'NVN' + cFilEnt + PadR(cContrato + cCodEnt, TamSx3('AC8_CODENT')[1] ), .T.) )
			If oModelNVN:IsDeleted( nX )
				RecLock('AC8', .F.)
				AC8->( dbDelete() )
				AC8->( MsUnLock() )
			ElseIf oModelNVN:IsUpdated()
				RecLock('AC8',.F.)
				AC8->AC8_FILIAL := cFilAc8
				AC8->AC8_ENTIDA := 'NVN'
				AC8->AC8_FILENT := cFilEnt
				AC8->AC8_CODENT := PadR(cContrato + cCodEnt, TamSx3('AC8_CODENT')[1] )
				AC8->AC8_CODCON := cContato
				AC8->( MsUnLock() )
			EndIf
		ElseIf !oModelNVN:IsDeleted( nX ) //Gravar Novo
			RecLock('AC8',.T.)
			AC8->AC8_FILIAL := cFilAc8
			AC8->AC8_ENTIDA := 'NVN'
			AC8->AC8_FILENT := cFilEnt
			AC8->AC8_CODENT := PadR(cContrato + cCodEnt, TamSx3('AC8_CODENT')[1] )
			AC8->AC8_CODCON := cContato
			AC8->( MsUnLock() )
		EndIf

	Next nX

EndIf

RestArea( aArea )

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} JA096CMAFT
Funções pós-Commit

@author Evaldo V. Batista
@since 17/11/2009
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function JA096CMAFT( oModel )
Local cContrato  := oModel:GetValue("NT0MASTER", "NT0_COD")
Local oModelNUT  := oModel:GetModel("NUTDETAIL")
Local nNUT       := 1
Local aNUT       := {}
Local lRet       := .T.
Local cFilNVE    := xFilial("NVE")
Local nX         := 0
Local cMsgSitCas := ""
Local aCasosAlt  := {}

If Len(_aSitCasos) == 2

	cMsgSitCas := _aSitCasos[1] // Mensagem com os casos que serão e os que não serão alterados
	aCasosAlt  := _aSitCasos[2] // Vetor com dados dos casos que terão a situação alterada

	If !Empty(cMsgSitCas)
		JurErrLog(cMsgSitCas, STR0150) // "Atenção"
	EndIf

	If !Empty(aCasosAlt)
		NVE->(DbSetOrder(1)) // NVE_FILIAL + NVE_CCLIEN + NVE_LCLIEN + NVE_NUMCAS + NVE_SITUAC
		
		For nX := 1 To Len(aCasosAlt)
			If NVE->(DbSeek(xFilial("NVE") + aCasosAlt[nX][1] + aCasosAlt[nX][2] + aCasosAlt[nX][3]))
				RecLock("NVE", .F.)
				NVE->NVE_SITCAD := "2"
				If NVE->(ColumnPos("NVE_DTEFT")) > 0 //Proteção 12/05/2023
					NVE->NVE_DTEFT := Date()
				EndIf
				NVE->(MsUnLock())
				J170GRAVA("NVE", cFilNVE + NVE->NVE_CCLIEN + NVE->NVE_LCLIEN + NVE->NVE_NUMCAS, "4")
			EndIf
		Next nX
	EndIf

	JurFreeArr(@aCasosAlt)
	JurFreeArr(@_aSitCasos)

EndIf

If !oModel:GetOperation() == OP_INCLUIR

	NT0->( DbSetOrder(1) ) // recolocado pois estava desposicionando no commit da alteração
	NT0->( DbSeek( xFilial('NT0') + cContrato ) )

	If oModel:GetOperation() == 4
		If oModel:IsFieldUpdated("NT0MASTER", "NT0_DESPAD") .Or. oModel:IsFieldUpdated("NT0MASTER", "NT0_TPERCD")
			lRet := J096DesCs(oModel)

		ElseIf !Empty(oModel:GetValue("NT0MASTER", "NT0_DESPAD"))
			For nNUT := 1 To oModelNUT:GetQtdLine()
				If !oModelNUT:IsDeleted(nNUT) .And. (oModelNUT:IsInserted(nNUT) .Or. oModelNUT:IsUpdated(nNUT))
					aAdd(aNUT, nNUT)
				EndIf
			Next nNUT

			If !Empty(aNUT)
				lRet := J096DesCs(oModel, aNUT)
			EndIf

		EndIf
	EndIf

	If !lRet
		JurMsgErro( STR0134 ) //"Não foi possivel alterar o desconto em pelo menos um dos casos do contrato!"
	EndIf

Else

	NT0->( DbSetOrder(1) ) // recolocado pois estava deposicionando no commit da alteração
	NT0->( DbSeek( xFilial('NT0') + cContrato ) )

	If lRet .And. oModel:GetOperation() != 5
		If !Empty(oModel:GetValue("NT0MASTER", "NT0_DESPAD"))
			lRet := J096DesCs(oModel)
		EndIf
	EndIf

	If !lRet
		JurMsgErro( STR0134 ) //"Não foi possivel alterar o desconto em pelo menos um dos casos do contrato!"
	EndIf

EndIf

If lRet
	J096CPYCnt( oModel ) //atualiza o conteudo do array _aCnt096
EndIf

Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} J96SA1NT0V
Validacao da amarração de clientes e casos x contrato.

@author Evaldo V. Batista
@since 17/11/2009
@version 1.0
/*/
//-------------------------------------------------------------------
Function J96SA1NT0V()
Local lRet     := .T.
Local oModel   := FwModelActive()
Local cGrupo   := ""
Local cClien   := ""
Local cLoja    := ""
Local lSmartUI := FindFunction("JurIsSmartUI") .And. JurIsSmartUI() // Proteção @12.1.2410

If IsInCallStack( 'JURA096' )  .Or. lSmartUI

	cGrupo := oModel:GetValue("NT0MASTER", "NT0_CGRPCL")
	cClien := oModel:GetValue("NT0MASTER", "NT0_CCLIEN")
	cLoja  := oModel:GetValue("NT0MASTER", "NT0_CLOJA")

	// Para o código do cliente
	If __ReadVar $ "M->NT0_CCLIEN"
		lRet := JurVldCli(cGrupo, cClien, cLoja,,, "CLI")

	//<-Para validar se a sigla do revisor não esta bloqueada e se a mesma é válida ->
	//<- FindFunction("J33RgBloq") --> Verifica se a função esta presente no RPO para evidar erroLog ->
	ElseIf __ReadVar $ "M->NT0_SIGLA1" .And. FindFunction("J33RgBloq")
		// Valida se o registro esta bloqueado atraves de ???_MSBLQL
		If !J33RgBloq('NT0_SIGLA1', 9)
			lRet := .F.
		EndIf

	// Para o código do grupo do cliente
	ElseIf __ReadVar $ "M->NT0_CGRPCL"
		lRet := JurVldCli(cGrupo, cClien, cLoja,,, "GRP")

	ElseIf lRet .And. __ReadVar $ "M->NT0_CCLIEN|M->NT0_CLOJA"
		lRet := JurVldCli(cGrupo, cClien, cLoja,,, "LOJ")
		
		If lRet .And. !Empty(cClien) .And. !Empty(cLoja)
			J096SUGVIC()
		EndIf
	EndIf

EndIf

If __ReadVar $ "M->NXP_CLIPG"
	If !Empty(FwFldGet("NXP_CLIPG")) .And. Empty(FwFldGet("NXP_LOJAPG"))
		lRet := ExistCpo('SA1', FwFldGet("NXP_CLIPG"))
	EndIf

ElseIf __ReadVar $ "M->NXP_LOJAPG"
	If !Empty(FwFldGet("NXP_CLIPG")) .And. !Empty(FwFldGet("NXP_LOJAPG"))
		lRet := ExistCpo( "SA1", FwFldGet("NXP_CLIPG") + FwFldGet("NXP_LOJAPG"), 1 )
		If lRet
			If Empty(JurGetDados('NUH', 1, xFilial('NUH') + FwFldGet("NXP_CLIPG") + FwFldGet("NXP_LOJAPG"), 'NUH_COD'))
				lRet := JurMsgErro(STR0092) // "O Cliente/Loja inválido"
			EndIf
		EndIf
	EndIf

ElseIf __ReadVar $ "M->NXG_CLIPG"
	If !Empty(FwFldGet("NXG_CLIPG")) .And. Empty(FwFldGet("NXG_LOJAPG"))
		lRet := ExistCpo('SA1', FwFldGet("NXG_CLIPG"))
	EndIf

ElseIf __ReadVar $ "M->NXG_LOJAPG"
	If !Empty(FwFldGet("NXG_CLIPG")) .And. !Empty(FwFldGet("NXG_LOJAPG"))
		lRet := ExistCpo( "SA1", FwFldGet("NXG_CLIPG") + FwFldGet("NXG_LOJAPG"), 1 )
		If lRet
			If Empty(JurGetDados('NUH', 1, xFilial('NUH') + FwFldGet("NXG_CLIPG") + FwFldGet("NXG_LOJAPG"), 'NUH_COD'))
				lRet := JurMsgErro(STR0092) // "O Cliente/Loja inválido"
			EndIf
		EndIf
	EndIf
EndIf

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} J96VldCaso
Função utilizada para validar o caso da tabela NUT

@param cTpHon , Tipo de honorário
@param lCobraH, Indica se o tipo de honorário cobra hora

@Return lRet   .T./.F. As informações são válidas ou não

@author Felipe Bonvicini Conti
@since  02/02/10
/*/
//-------------------------------------------------------------------
Function J96VldCaso(cTpHon, lCobraH)
Local lRet      := .T.
Local oModel    := FwModelActive()
Local oModelNUT := Nil
Local oModelNT0 := Nil
Local aArea     := GetArea()
Local aAreaNVE  := NVE->( GetArea() )
Local cCobravel := ""
Local cClient   := ""
Local cLoja     := ""
Local cContr    := ""
Local dDtVigI   := ""
Local dDtVigF   := ""
Local cAtivo    := ""
Local aCliLoj   := {}
Local cCaso     := ""

Default cTpHon  := ""
Default lCobraH := .F.

Chkfile('NVE')

If oModel:GetId() == 'JURA096'
	oModelNUT := oModel:GetModel('NUTDETAIL')

	If !Empty(oModelNUT:GetValue('NUT_CCASO'))

		If _cNumClien == "1"
			If Empty(oModelNUT:GetValue('NUT_CCLIEN')) .Or. Empty(oModelNUT:GetValue('NUT_CLOJA'))
				lRet := .F.
			Else
				cClient := oModelNUT:GetValue('NUT_CCLIEN')
				cLoja   := oModelNUT:GetValue('NUT_CLOJA')
				cCaso   := oModelNUT:GetValue('NUT_CCASO')

				NVE->(DbSetOrder(1)) // NVE_FILIAL+NVE_CCLIEN+NVE_LCLIEN+NVE_NUMCAS+NVE_SITUAC
				If NVE->(DbSeek(xFilial("NVE") + cClient + cLoja + cCaso))
					cCobravel := NVE->NVE_COBRAV
				Else
					lRet := JurMsgErro(STR0196) //"Cliente, loja e caso inválidos."
				EndIf
			EndIf

		ElseIf _cNumClien == "2"
			cCaso   := oModelNUT:GetValue('NUT_CCASO')

			NVE->(dbSetOrder(3)) //NVE_FILIAL+NVE_NUMCAS+NVE_SITUAC
			If NVE->(dbSeek(xFilial('NVE') + cCaso))
				cCobravel := NVE->NVE_COBRAV
				aCliLoj   := JCasoAtual(cCaso)
				If !Empty(aCliLoj)
					cClient := aCliLoj[1][1]
					cLoja   := aCliLoj[1][2]
				EndIf
			Else
				lRet := JurMsgErro(STR0197) //"Caso inválido."
			EndIf
		EndIf

		If lRet .And. cCobravel == "1"
			oModelNT0 := oModel:GetModel('NT0MASTER')
			cContr    := oModelNT0:GetValue("NT0_COD")
			cAtivo    := oModelNT0:GetValue("NT0_ATIVO")
			dDtVigI   := oModelNT0:GetValue("NT0_DTVIGI")
			dDtVigF   := oModelNT0:GetValue("NT0_DTVIGF")

			If oModel:GetOperation() <> OP_EXCLUIR
				If Empty(cTpHon) // cTpHon vem vazio quando a função é chamada pelo Valid do campo NUT_CCASO
					cTpHon  := oModelNT0:GetValue("NT0_CTPHON")
					lCobraH := J096CHon(cTpHon) // Indica se o tipo de honorário cobra hora
				EndIf

				If lCobraH .And. cAtivo == "1"
					lRet := J096VlTpHo(oModel, cCaso, cContr, cClient, cLoja, cTpHon, dDtVigI, dDtVigF)
				EndIf

				If lRet
					lRet := J096VDespTab(cClient, cLoja, cCaso, cContr, cAtivo, dDtVigI, dDtVigF)
				EndIf
			EndIf

		EndIf

	EndIf

EndIf

RestArea(aAreaNVE)
RestArea(aArea)

Return lRet

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³J096VTpHonºAutor  ³Evaldo V. Batista   º Data ³  20/11/2009 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³-Funcao para validar os tipos de honorarios ja informados e º±±
±±º          ³apagar as informacoes geradas pelo usuario caso ele mude o  º±±
±±º          ³tipo de honorario                                           º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function J096VTpHon(oModel, lSmartUI, cMsgParc, cMsgFaixa)
Local lRet        := .T.
Local nA          := 0
Local oModelNT0   := Nil
Local oModelNT1   := Nil
Local oModelNTR   := Nil
Local cTipHon     := ""
Local cCodCtr     := ""
Local nQtdLine    := 0
Local cOldTipHon  :=""
Local nLineActive := 0
Local nSavNT1     := 0
Local nSavNTR     := 0
Local cParcela    := ""
Local cPreFat     := ""
Local cSituacao   := ""
Local cParcMsg    := ""
Local cParcBlq    := ""
Local cMsgErro    := ""

Default oModel    := FWModelActive()
Default lSmartUI  := FindFunction("JurIsSmartUI") .And. JurIsSmartUI() // Proteção @12.1.2410
Default cMsgParc  := ""
Default cMsgFaixa := ""

If lSmartUI
	oModelNT0 := oModel:GetModel('NT0MASTER')
	oModelNT1 := oModel:GetModel('NT1DETAIL')
	oModelNTR := oModel:GetModel('NTRDETAIL')
	cTipHon   := oModelNT0:GetValue('NT0_CTPHON')
	cCodCtr   := oModelNT0:GetValue('NT0_COD') // Codigo do contrato
	nQtdLine  := oModelNT1:GetQtdLine()
Else
	oModelNT0   := oModel:GetModel('NT0MASTER')
	oModelNT1   := oModel:GetModel('NT1DETAIL')
	oModelNTR   := oModel:GetModel('NTRDETAIL')
	cTipHon     := oModelNT0:GetValue('NT0_CTPHON')
	cCodCtr     := oModelNT0:GetValue('NT0_COD') // Codigo do contrato
	nQtdLine    := oModelNT1:GetQtdLine()
EndIf

cOldTipHon := JurGetDados('NT0', 1, xFilial('NT0') + cCodCtr, 'NT0_CTPHON')
cUser      := '2'

If !oModelNT1:IsEmpty()

	J096SetNo(oModelNT1, .F.)
	nSavNT1 := oModelNT1:GetLine()
	For nA := 1 To nQtdLine
		oModelNT1:GoLine(nA)
		If !oModelNT1:IsDeleted(nA)
			nLineActive++
			If Empty(oModelNT1:GetValue("NT1_SEQUEN"))
				oModelNT1:SetValue( "NT1_SEQUEN", JurGetNum("NT1", "NT1_SEQUEN"))
			EndIf

			cParcela := oModelNT1:GetValue("NT1_PARC")
			cPreFat  := oModelNT1:GetValue('NT1_CPREFT')
			If !Empty(cPreFat)
				cSituacao := JurGetDados("NX0", 1, xFilial("NX0") + cPreFat, "NX0_SITUAC")
				If cSituacao $ "2|3|D|E" // Situações que permitem cancelamento
					cParcMsg += IIf(Empty(cParcMsg), cParcela, ", " + cParcela)
					AAdd(_aPreFtVld, cPreFat)
				ElseIf cSituacao $ "4|5|6|7|9|A|B|C|F" // Situações que NÃO permitem cancelamento
					cParcBlq += IIf(Empty(cParcBlq), cParcela, ", " + cParcela)
				EndIf
			EndIf
		EndIf
	Next nA

	If !Empty(cParcBlq)
		_aPreFtVld := {} // Limpa o array pois não permitirá a alteração do tipo do honorário
		If lSmartUI
			cMsgParc := I18N(STR0248, {cParcBlq})
			lRet := .F.
		Else
			lRet := JurMsgErro(I18N(STR0248, {cParcBlq}),, STR0249) // "Não é possível alterar o tipo de honorário, pois a(s) parcela(s) '#1' estão vinculadas a pré-fatura(s) que não permitem cancelamento e não serão alterada(s)!" - "Cancele a(s) pré-fatura(s) para realizar a alteração do tipo de honorário."
		EndIf
	EndIf

	If lRet
		If JUR96TPFIX(cOldTipHon) .Or. JUR96TPFIX(cTipHon)
			If nLineActive > 0 .And. !J096VldNWE(cCodCtr)
				If Empty(cParcMsg)
					If lSmartUI
						cMsgParc := (STR0036 + CRLF + STR0037)
					Else
						lRet := ApMsgYesNo( STR0036 + STR0037, STR0038 ) // "Esta operação ira excluir todas as parcelas pendentes do formulário de parcelas,"###" confirma a exclusão das parcelas geradas e/ou digitadas?"###"Exclusão Automática"
						cMsgErro := STR0072 // "Para alterar o tipo de honorários as parcelas pendentes devem ser excluídas."
					EndIF
				Else
					If lSmartUI
						cMsgParc := I18N(I18N(STR0250, {cParcMsg}) + CRLF + STR0251)
					Else
						lRet := ApMsgYesNo( I18N(STR0250, {cParcMsg}) + CRLF + STR0251 , STR0038) // "A(s) parcela(s) '#1' estão vinculadas a pré-faturas. Esta operação irá excluir todas as parcelas pendentes e cancelar as pré-faturas." - "Confirma a exclusão das parcelas geradas e/ou digitadas e o cancelamento das pré-faturas?" - "Exclusão Automática"
						cMsgErro := STR0252 // "Para alterar o tipo de honorários as parcelas devem ser excluídas e as pré-faturas canceladas."
					EndIf
				EndIf
			EndIf
			If !lSmartUI
				If lRet
					For nA := 1 To nQtdLine
						oModelNT1:GoLine( nA )
						If !oModelNT1:IsDeleted( nA ) .And. ((oModelNT1:GetValue("NT1_SITUAC") == '1') .Or. Empty(oModelNT1:GetValue("NT1_SITUAC")))
							If oModelNT1:GetValue("NT1_SITUAC") == '1' .And. !oModel:GetModel('NWEDETAIL'):IsEmpty()
								cMsgErro := STR0284 // "Para alterar o tipo de honorário é preciso fazer WO ou faturar parcelas que que já tenham passado por alguma movimentação."
								lRet := JurMsgErro(STR0285,, cMsgErro) // "Não é possível alterar o tipo de honorários, pois existem parcela(s) pendente(s) que já tiveram movimentações (pré-fatura, fatura e/ou WO)."
								Exit
							Else
								If !oModelNT1:CanDeleteLine()
									oModelNT1:SetNoDeleteLine(.F.)
									oModelNT1:DeleteLine()
									oModelNT1:SetNoDeleteLine(.T.)
								Else
									oModelNT1:DeleteLine()
								EndIf
							EndIf
						EndIf
					Next nA
				Else
					JurMsgErro(STR0253,, cMsgErro) // "Não é possível alterar o tipo de honorários."
				EndIf
			EndIf
		EndIf

		If J96TPHPAut(cTipHon) .And. !lSmartUI
			J096SetNo(oModelNT1, .T.)
		EndIf
	EndIf
	oModelNT1:Goline(nSavNT1)
EndIf

If lRet

	nLineActive := 0
	nQtdLine    := oModelNTR:GetQtdLine()
	nSavNTR     := oModelNTR:GetLine()

	If !oModelNTR:IsEmpty()

		For nA := 1 To nQtdLine
			If !oModelNTR:IsDeleted( nA ) .And. !Empty( oModelNTR:GetValue("NTR_VLFIM") )
				nLineActive++
			EndIf
		Next nA

		If nLineActive > 0
			If lSmartUI
				cMsgFaixa := STR0070 + CRLF + STR0071
			Else
				lRet := ApMsgYesNo( STR0070 + CRLF + STR0071, STR0038 )  //"Esta operação ira excluir todas as Faixas de faturamento do formulário de faixas,"###" confirma a exclusão das Faixas?"###"Exclusão Automática"
			EndIf
		EndIf
		If !lSmartUI
			If lRet
				For nA := 1 To nQtdLine
					oModelNTR:GoLine( nA )
					If !oModelNTR:IsDeleted( nA )
						If JUR96FAIXA(cTipHon )
							oModelNTR:SetValue( 'NTR_VLINI', Int( oModelNTR:GetValue( 'NTR_VLINI' ) ) )
							oModelNTR:SetValue( 'NTR_VLFIM', Int( oModelNTR:GetValue( 'NTR_VLFIM' ) ) )
						EndIf
						oModelNTR:DeleteLine()
					EndIf
				Next nA
			Else
				JurMsgErro(STR0073)
			EndIf
		EndIf

		oModelNTR:GoLine(nSavNTR)
	EndIf
EndIf

cUser := '1'

If lRet .And. !lSmartUI
	If JUR96TPHAT(oModel)
		JUR096CPO()
	Else
		lRet := .F.
	EndIf
EndIf

Return lRet

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³J096VldDefºAutor  ³Evaldo V. Batista   º Data ³  25/11/2009 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³-Funcao validar a situacao do contrato, se o tipo de        º±±
±±º          ³Contrato for definitivo o principal cliente do contrato     º±±
±±º          ³tambem deve ser definitivo                                  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function J096VldDef(cCodCli, cLojCli, cTipSit)
Local lRet      := .T.
Local aArea     := GetArea()
Local oModel    := FwModelActive()

Default cTipSit := FwFldGet('NT0_SIT')
Default cCodCli := FwFldGet('NT0_CCLIEN')
Default cLojCli := FwFldGet('NT0_CLOJA')

	If oModel:GetOperation() == OP_INCLUIR .Or. oModel:GetOperation() == OP_ALTERAR

		NUH->( dbSetOrder( 1 ) ) //NUH_FILIAL+NUH_COD+NUH_LOJA
		If NUH->( dbSeek( xFilial('NUH') + cCodCli + cLojCli, .F. ) )
			If NUH->NUH_SITCAD == '1' // Provisório
				If cTipSit == '2' // Definitivo
					lRet := JurMsgErro(STR0042,, STR0043) // "Não é permitido alterar a situação do contrato, pois o cliente é provisório." # "Ajuste a situação do cadastro no cliente para definitivo ou mantenha o contrato como provisório."
				EndIf
			EndIf
		Else
			lRet := JurMsgErro(STR0044,, STR0045) // "Cadastro do cliente incompleto!" # "Preencha os dados complementares no cadastro do cliente."
		EndIf

	EndIf

RestArea(aArea)

Return( lRet )

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³J096VldDesºAutor  ³Evaldo V. Batista   º Data ³  26/11/2009 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³-Valida se o tipo de despesa nao cobravel esta ativa ou nao º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function J096VldDes(cCodDesp)
Local lRet       := .T.
Local aArea      := GetArea()

Default cCodDesp := FwFldGet('NTK_CTPDSP')

NRH->( dbSetOrder( 1 ) ) //NRH_FILIAL+NRH_COD
If NRH->( dbSeek( xFilial('NRH') + cCodDesp, .F. ) )
	If !NRH->NRH_ATIVO == '1'
		lRet := JurMsgErro( STR0046 ) //'Esta despesa não pode ser utilizada pois está desabilitada'
	EndIf
Else
	lRet := JurMsgErro( STR0047 ) //'Despesa Não Cadastrada...'
EndIf

RestArea(aArea)

Return( lRet )

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³J096VldAtvºAutor  ³Evaldo V. Batista   º Data ³  26/11/2009 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³-Valida se o tipo de atividade e cobravel                   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function J096VldAtv(cCodAtv)
Local lRet      := .T.
Local aArea     := GetArea()

Default cCodAtv := FwFldGet('NTJ_CTPATV')

NRC->( dbSetOrder( 1 ) )
If NRC->( dbSeek( xFilial('NRC') + cCodAtv, .F. ) )
	If NRC->NRC_ATIVO ==  "2"
		lRet := JurMsgErro( STR0124 ) // "Atividade inativa"
	EndIf
Else
	lRet := JurMsgErro( STR0049 ) // "Atividade Não Cadastrada"
EndIf

RestArea(aArea)

Return( lRet )

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³J096VldRelºAutor  ³Evaldo V. Batista   º Data ³  26/11/2009 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³-Validacao para impedir que seja informado um relatorio     º±±
±±º          ³ desabilitado para este usuario                             º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function J096VldRel(cTabela)
Local lRet    := .T.
Local aArea   := GetArea()
Local cCodRel := ""
Local cCodCli := ""
Local cLojCli := ""

	Do Case
	Case cTabela == "NXA"
		cCodRel := FwFldGet('NXA_TPREL')
		cCodCli := FwFldGet('NXA_CCLIEN')
		cLojCli := FwFldGet('NXA_CLOJA')
	Case cTabela == "NXG"
		cCodRel := FwFldGet('NXG_CRELAT')
		cCodCli := FwFldGet('NXG_CLIPG')
		cLojCli := FwFldGet('NXG_LOJAPG')
	Case cTabela == "NXP"
		cCodRel := FwFldGet('NXP_CRELAT')
		cCodCli := FwFldGet('NXP_CLIPG')
		cLojCli := FwFldGet('NXP_LOJAPG')
	End Case

	NUA->( dbSetOrder( 1 ) ) //NUA_FILIAL+NUA_CCLIEN+NUA_CLOJA+NUA_CTPREL
	If NUA->( dbSeek( xFilial('NUA') + cCodCli + cLojCli + cCodRel ) )
		lRet := JurMsgErro( STR0050 ) //'Este Relatório está desabilitado para este cliente, informe um relatório que não esteja desabilitado'
	EndIf

	NRJ->( dbSetOrder( 1 ) ) //NRJ_FILIAL+NRJ_COD
	If NRJ->( dbSeek( xFilial('NRJ') + cCodRel ) )
		If NRJ->NRJ_ATIVO == "2"
			lRet := JurMsgErro( STR0125 ) //"Este Relatório está inativo, informe um relatório que esteja ativo!"
		EndIf
	EndIf

	RestArea(aArea)

Return( lRet )

//-------------------------------------------------------------------
/*/{Protheus.doc} J096FilRel
Filtro para não permitir exibir relatorios que estejam desabilitados 
para o cliente do contrato.

@param cCodRel, Código do Tipo de Relatório
@param cCodRel, Código do Tipo de Relatório
@param cCodRel, Código do Tipo de Relatório

@obs   Utilizado na consulta padrão NRJCTR

@author Evaldo V. Batista
@since  26/11/2009
/*/
//-------------------------------------------------------------------
Function J096FilRel(cCodRel, cCodCli, cLojCli)
Local lRet      := .T.
Local aArea     := GetArea()

Default cCodRel := NRJ->NRJ_COD

If IsInCallStack("JURA202") .Or. IsInCallStack("JURA033") .Or. IsInCallStack("JURA203")
	Default cCodCli := FwFldGet('NXG_CLIPG')
	Default cLojCli := FwFldGet('NXG_LOJAPG')
ElseIf IsInCallStack("JURA204")
	Default cCodCli := FwFldGet('NXA_CLIPG')
	Default cLojCli := FwFldGet('NXA_LOJPG')
Else
	Default cCodCli := FwFldGet('NXP_CLIPG')
	Default cLojCli := FwFldGet('NXP_LOJAPG')
EndIf

NUA->( dbSetOrder( 1 ) ) //NUA_FILIAL+NUA_CCLIEN+NUA_CLOJA+NUA_CTPREL
If NUA->( dbSeek( xFilial('NUA') + cCodCli + cLojCli + cCodRel ) )
	lRet := .F.
EndIf

RestArea(aArea)

Return ( lRet )

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³j096WhenCsºAutor  ³Evaldo V. Batista   º Data ³  26/11/2009 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³-Permite a digitacao ou nao do campo de caso de acordo com  º±±
±±º          ³o paramatro MV_JCASO1                                       º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function J096WhenCs(cCodCli, cLojCli, cCodCaso)
Local lRet     := .T.
Local cMvJCaso := GetMv('MV_JCASO1', .F., '1') //Determina se o caso é por cliente (1) ou independente de cliente (2)

If 'JURA096' $ Upper( FunName() )

	Default cCodCli  := FwFldGet('NUT_CCLIEN')
	Default cLojCli  := FwFldGet('NUT_CLOJA')
	Default cCodCaso := FwFldGet('NUT_CCASO')

	If cMvJCaso == '1' .And. ( Empty(cCodCli) .Or. Empty(cLojCli) )
		lRet := .F.
	EndIf

EndIf

Return( lRet )

//-------------------------------------------------------------------
/*/{Protheus.doc} J096VlTpHo()
Validação de Caso x Tipo de honorário

Impede que seja informado casos amarrados a contratos de cobranca por 
hora em outro contrato com cobranca por hora

@param oModel     , Modelo de dados de Contratos
@param cCodCaso   , Código do Caso
@param cContr     , Código do Contrato
@param cCodCli    , Código do Cliente
@param cLojCli    , Loja do Cliente
@param cTipHon    , Código do Tipo de honorário
@param dDtVigI    , Data Inicial da vigência
@param dDtVigF    , Data Final da vigência
@param aInfoApi   , Array com informações vindas do Smart UI
       aInfoApi[1] - Código do Caso
       aInfoApi[2] - Código do Contrato
       aInfoApi[3] - Código do Cliente
       aInfoApi[4] - Loja do Cliente
       aInfoApi[5] - Tipo de honorário
       aInfoApi[6] - Data de vigência inicial
       aInfoApi[7] - Data de vigência final
@param cMsgErro   , Mensagem de erro retornada para o SmartUI
@param cMsgSolucao, Mensagem de solução retornada para o SmartUI

@return lRet      , Indica se o caso pode ser adicionado ao contrato

@author Evaldo V. Batista
@since  30/11/2009
/*/
//-------------------------------------------------------------------
Function J096VlTpHo(oModel, cCodCaso, cContr, cCodCli, cLojCli, cTipHon, dDtVigI, dDtVigF, aInfoApi, cMsgErro, cMsgSolucao)
Local aArea    := GetArea()
Local lRet     := .T.
Local cQuery   := ''
Local cErroVig := ''
Local cMsgErr  := ''
Local ocQuery  := Nil
Local cAlias   := GetNextAlias()
Local nParam   := 0

Default cCodCaso    := ''
Default cCodCli     := ''
Default cLojCli     := ''
Default cTipHon     := IIf(Len(aInfoApi) > 0, '', oModel:GetModel('NT0MASTER'):GetValue("NT0_CTPHON"))
Default dDtVigI     := CToD( '  /  /  ' )
Default dDtVigF     := CToD( '  /  /  ' )
Default aInfoApi    := {}
Default cMsgErro    := ''
Default cMsgSolucao := ''

	If Len(aInfoApi) > 0
		cContr   := aInfoApi[1]
		cCodCli  := aInfoApi[2]
		cLojCli  := aInfoApi[3]
		cCodCaso := aInfoApi[4]
		dDtVigI  := IIf(Empty(aInfoApi[5]), CToD('  /  /  '), CToD(aInfoApi[5]))
		dDtVigF  := IIf(Empty(aInfoApi[6]), CToD('  /  /  '), CToD(aInfoApi[6]))
	EndIf

	cQuery := " SELECT NT0.NT0_COD, NUT.NUT_CCASO, NT0_DTVIGI, NT0_DTVIGF"
	cQuery +=   " FROM " + RetSqlName('NUT') + " NUT "
	cQuery +=  " INNER JOIN " + RetSqlName('NT0') + " NT0 "
	cQuery +=     " ON NT0.D_E_L_E_T_ = ' ' "
	cQuery +=    " AND NT0.NT0_FILIAL = ? "
	cQuery +=    " AND NT0.NT0_COD = NUT.NUT_CCONTR "
	cQuery +=    " AND NT0.NT0_COD <> ? "
	cQuery +=    " AND NT0.NT0_ATIVO = ? "
	cQuery +=  " INNER JOIN " + RetSqlName('NRA') + " NRA "
	cQuery +=     " ON NRA.D_E_L_E_T_ = ' ' "
	cQuery +=    " AND NRA.NRA_FILIAL = ? "
	cQuery +=    " AND NRA.NRA_COD    = NT0_CTPHON "
	cQuery +=    " AND NRA.NRA_COBRAH = ? "
	cQuery +=  " WHERE NUT.D_E_L_E_T_ = ' ' "
	cQuery +=    " AND NUT.NUT_FILIAL = ? "
	cQuery +=    " AND NUT.NUT_CCLIEN = ? "
	cQuery +=    " AND NUT.NUT_CLOJA  = ? "
	cQuery +=    " AND NUT.NUT_CCASO  = ? "

	ocQuery := FwpreparedStatement():New(cQuery)

	ocQuery:SetString(++nParam, xFilial("NT0")) // Filial do Contrato
	ocQuery:SetString(++nParam, cContr)         // Código do Contrato
	ocQuery:SetString(++nParam, '1')            // Contrato Ativo
	ocQuery:SetString(++nParam, xFilial("NRA")) // Filial do Tipo de honorário
	ocQuery:SetString(++nParam, '1')            // Tipo de honorário cobra hora
	ocQuery:SetString(++nParam, xFilial("NUT")) // Filial de Casos x Contratos
	ocQuery:SetString(++nParam, cCodCli)        // Código do Cliente
	ocQuery:SetString(++nParam, cLojCli)        // Loja do Cliente
	ocQuery:SetString(++nParam, cCodCaso)       // Código co Caso

	cQuery := ocQuery:GetFixQuery()
	MpSysOpenQuery(cQuery, cAlias)

	While !(cAlias)->( Eof() )

		cErroVig := J096VldPer(cAlias, dDtVigI, dDtVigF)

		If !Empty(cErroVig)
			lRet        := .F.
			cMsgErro    := cMsgErr := cErroVig
			cMsgSolucao := cMsgSol := (STR0230) //'Verifique o período de vigência no contrato.'
		ElseIf Empty(dDtVigI) .And. Empty(dDtVigF)
			lRet        := .F.
			cMsgErro    := cMsgErr := STR0060 + AllTrim(cCodCaso) + STR0061 + AllTrim(cContr) + STR0062 + CRLF + STR0063 + (cAlias)->NT0_COD + cMsgErr  //'O caso '###' não pode ser vinculado ao contrato '###' porque já faz parte de outros(s) contrato(s) com faturamento por Hora! '###'Contrato(s) Vinculado(s) ao caso: '
			cMsgSolucao := cMsgSol := STR0231 // 'Verifique o período de vigência no contrato.'
		EndIf

		If !lRet
			JurMsgErro( cMsgErr, 'J096VlTpHo', cMsgSol )
			Exit
		EndIf

		(cAlias)->( dbSkip() )
	EndDo
	(cAlias)->( dbCloseArea() )

	RestArea( aArea )

Return( lRet )

//-------------------------------------------------------------------
/*/{Protheus.doc} J096VDespTab
Função utilizada para validar se o caso já esta associado a algum
 outro contrato que cobre Despesa ou Tabelado

@param cCliente   , Código do Cliente
@param cLoja      , Loja do Cliente
@param cCaso      , Código do Caso
@param cContrato  , Código do Contrato
@param cAtivo     , Se o Contrato está Ativo (1=Sim/2=Não)
@param dDtVigI    , Data Inicial da vigência
@param dDtVigF    , Data Final da vigência
@param aInfoApi   , Array com informações vindas do Smart UI
       aInfoApi[1] - Código do Cliente
       aInfoApi[2] - Loja do Cliente
       aInfoApi[3] - Código do Caso
       aInfoApi[4] - Código do Contrato
       aInfoApi[5] - Se o Contrato está Ativo (1=Sim/2=Não)
       aInfoApi[6] - Se o Contrato cobra Tabelado (1=Sim/2=Não)
       aInfoApi[7] - Se o Contrato cobra Despesa (1=Sim/2=Não)
       aInfoApi[8] - Data de vigência inicial
       aInfoApi[9] - Data de vigência final
@param cMsgErro   , Mensagem de erro retornada para o SmartUI
@param cMsgSolucao, Mensagem de solução retornada para o SmartUI

@Return lRet      ,  .T./.F. As se informações são válidas ou não

@author Felipe Bonvicini Conti
@since 01/02/10
@version 1.0
/*/
//-------------------------------------------------------------------
Function J096VDespTab(cCliente, cLoja, cCaso, cContrato, cAtivo, dDtVigI, dDtVigF, aInfoApi, cMsgErro, cMsgSolucao)
Local aArea     := GetArea()
Local cAlias    := GetNextAlias()
Local cQuery    := ""
Local cErroVig  := ""
Local oModel    := Nil
Local oModelNT0 := Nil
Local cCobTab   := ""
Local cCobDes   := ""
Local lRet      := .T.
Local oQuery    := Nil
Local nParam    := 0

Default cCliente    := ''
Default cLoja       := ''
Default cCaso       := ''
Default cContrato   := ''
Default cAtivo      := ''
Default dDtVigI     := CToD( '  /  /  ' )
Default dDtVigF     := CToD( '  /  /  ' )
Default aInfoApi    := {} 
Default cMsgErro    := '' 
Default cMsgSolucao := ''

	If Len(aInfoApi) > 0
		cCliente  := aInfoApi[1]
		cLoja     := aInfoApi[2]
		cCaso     := aInfoApi[3]
		cContrato := aInfoApi[4]
		cAtivo    := aInfoApi[5]
		cCobTab   := aInfoApi[6]
		cCobDes   := aInfoApi[7]
		dDtVigI   := IIf(Empty(aInfoApi[8]), CToD('  /  /  '), CToD(aInfoApi[8]))
		dDtVigF   := IIf(Empty(aInfoApi[9]), CToD('  /  /  '), CToD(aInfoApi[9]))
	Else 
		oModel    := FwModelActive()
		oModelNT0 := oModel:GetModel('NT0MASTER')
		cCobTab   := oModelNT0:GetValue("NT0_SERTAB")
		cCobDes   := oModelNT0:GetValue("NT0_DESPES")
	EndIf

	If cAtivo == '1' .And. (cCobTab == '1' .Or. cCobDes == '1')
		cQuery := "SELECT NT0.NT0_COD, NUT.NUT_CCASO, NT0.NT0_DESPES, NT0.NT0_SERTAB, NT0_DTVIGI, NT0_DTVIGF"
		cQuery += " FROM "+RetSqlName('NUT')+" NUT "
		cQuery += " INNER JOIN "+RetSqlName('NT0')+" NT0 "
		cQuery +=    " ON NT0.NT0_FILIAL = ?"
		cQuery +=    " AND NT0.D_E_L_E_T_ = ' ' "
		cQuery +=    " AND NT0.NT0_COD = NUT.NUT_CCONTR "
		cQuery +=    " AND NT0.NT0_COD <> ?"
		cQuery +=    " AND NT0.NT0_ATIVO = ?"

		If cCobTab == '1' .And. cCobDes == '1'
			cQuery += " AND (NT0.NT0_SERTAB = ? OR NT0.NT0_DESPES = ?) "
		ElseIf cCobTab == '1' .And. cCobDes == '2'
			cQuery += " AND NT0.NT0_SERTAB = ?"
		ElseIf cCobTab == '2' .And. cCobDes == '1'
			cQuery += " AND NT0.NT0_DESPES = ?"
		EndIf
		cQuery += " WHERE NUT.NUT_FILIAL = ?"
		cQuery +=    " AND NUT.D_E_L_E_T_ = ' ' "
		cQuery +=    " AND NUT.NUT_CCLIEN = ?"
		cQuery +=    " AND NUT.NUT_CLOJA = ?"
		cQuery +=    " AND NUT.NUT_CCASO = ?"

		oQuery := FwpreparedStatement():New(cQuery)

		oQuery:SetString(++nParam, xFilial('NT0')) // Filial do Contrato
		oQuery:SetString(++nParam, cContrato)      // Código do Contrato
		oQuery:SetString(++nParam, '1')            // Se o Contrato está ativo
		If cCobTab == '1' .And. cCobDes == '1'
			oQuery:SetString(++nParam, '1')            // Se cobra Tabelado ou
			oQuery:SetString(++nParam, '1')            // Se cobra Despesa
		ElseIf cCobTab == '1' .And. cCobDes == '2'
			oQuery:SetString(++nParam, '1')            // Se cobra somente Tabelado
		ElseIf cCobTab == '2' .And. cCobDes == '1'
			oQuery:SetString(++nParam, '1')            // Se cobra somente Despesa
		EndIf
		oQuery:SetString(++nParam, xFilial('NUT')) // Filial do vínculo de Casos x Contratos
		oQuery:SetString(++nParam, cCliente)       // Código do Cliente
		oQuery:SetString(++nParam, cLoja)          // Código da Loja
		oQuery:SetString(++nParam, cCaso)          // Código do Caso

		cQuery := oQuery:GetFixQuery()
		MpSysOpenQuery(cQuery, cAlias)

		While !(cAlias)->( Eof() )

			cErroVig := J096VldPer(cAlias, dDtVigI, dDtVigF)

			If (cAlias)->NT0_SERTAB == "1" .And. cCobTab == "1"
				If !Empty(cErroVig)
					lRet        := .F.
					cMsgSolucao := cMsgSol := STR0230 //'Verifique o período de vigência no contrato.'
				ElseIf Empty(dDtVigI) .And. Empty(dDtVigF)
					lRet        := .F.
					cMsgErro    := cErroVig := STR0060+AllTrim(cCaso)+STR0061+AllTrim(cContrato)+STR0076+CRLF+STR0063+(cAlias)->NT0_COD //'O caso '###' não pode ser vinculado ao contrato '###' porque já faz parte de outros(s) contrato(s) quem cobrem despesa! '###'Contrato(s) Vinculado(s) ao caso: '
					cMsgSolucao := cMsgSol := STR0231 // "Verifique a forma de cobrança do contrato."
				EndIf
			EndIf

			If (cAlias)->NT0_DESPES == "1" .And. cCobDes == "1"
				If !Empty(cErroVig)
					lRet        := .F.
					cMsgSolucao := cMsgSol := STR0230 // 'Verifique o período de vigência no contrato.'
				ElseIf Empty(dDtVigI) .And. Empty(dDtVigF)
					lRet        := .F.
					cMsgErro    := cErroVig := STR0060+AllTrim(cCaso)+STR0061+AllTrim(cContrato)+STR0075+CRLF+STR0063+(cAlias)->NT0_COD //'O caso '###' não pode ser vinculado ao contrato 	'###' porque já faz parte de outros(s) contrato(s) quem cobrem tabelado! '###'Contrato(s) Vinculado(s) ao caso: '
					cMsgSolucao := cMsgSol  := STR0231 // "Verifique a forma de cobrança do contrato."
				EndIf
			EndIf

			If !lRet
				Exit
			EndIf

			(cAlias)->( dbSkip() )

		EndDo
		(cAlias)->( dbCloseArea() )

		If !lRet .And. !Empty(cErroVig) .And. !Empty(cMsgSol)
			lRet := JurMsgErro(cErroVig, 'J096VDespTab', cMsgSol)
		EndIf

	EndIf

	RestArea( aArea )

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} J96TPHPAut
Função utilizada para verificar se o tipo de honorários gera parcelas automáticas

@Return lRet	 	.T./.F. As informações são válidas ou não

@author Felipe Bonvicini Conti
@since 19/02/10
@version 1.0
/*/
//-------------------------------------------------------------------
Function J96TPHPAut(cTpHonor)
Local lRet   := .F.
Local aArea  := GetArea()

Default cTpHonor := FwFldGet('NT0_CTPHON')

lRet := JurGetDados('NRA', 1, xFilial('NRA') + cTpHonor, 'NRA_PARCAT') == "1"

RestArea( aArea )

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} J96CalcCDF
Função utilizada para calcular o valor base da parcela fixa quando o
tipo de faixa de faturamento for Quantidade de Casos (Partido, Ocorrência e
Pré-definido).
Usada também na JURA203C para recálculo do valor base no momento da inserção
da parcela fixa na fila de emissão.

@param  oModel  , Objeto do modelo de contratos
@param  cSequen , Código da sequênca da parcela
@param  lSmartUI, Se verdadeiro indica que a chamada é do SmartUI
@param  cMsg    , Variável para armazenar as mensagens de validação
                  quando a chamada for do SmartUI

@Return nValor, Valor atualizado da parcela

@author Felipe Bonvicini Conti
@since  19/02/10
@obs    Função também Chamada no Gatilho (SX7) do campo NT1_QTDADE
/*/
//-------------------------------------------------------------------
Function J96CalcCDF(oModel, cSequen, lSmartUI, cMsg)
Local oModelNT0   := Nil
Local oModelNUT   := Nil
Local oModelNT1   := Nil
Local oModelNTR   := Nil
Local nQtdNTR     := Nil
Local nQtdNUT     := Nil
Local nLnOldNT1   := Nil
Local nQtdLnNUT   := Nil
Local nLnOldNUT   := Nil
Local nLnOldNTR   := Nil
Local oStructNT1  := Nil
Local nValor      := 0
Local nDif        := 0
Local nI          := 0
Local nQtdCasPro  := 0
Local nQtdNT1     := 0
Local aValores    := {}
Local cNT1Descri  := ""
Local lCanDelNT1  := Nil
Local lCanUptNT1  := Nil
Local lCanInsNT1  := Nil
Local cQtdCsAut   := SuperGetMV("MV_JQTDAUT",, "1") // Indica se a quantidade de casos / processos será indicada na parcela de forma automática (1) ou manual (2)
Local cDescriPar  := ""
Local nPosDesc 	  := ""
Local cNumExtDes  := ""
Local nX 		  := 1
Local cNumPos 	  := ""

Default oModel    := FWModelActive()
Default cSequen   := ""
Default lSmartUI  := .F.
Default cMsg      := ""

oModelNT0   := oModel:GetModel('NT0MASTER')
oModelNUT   := oModel:GetModel('NUTDETAIL') // Relacionamento Caso x Contrato
oModelNT1   := oModel:GetModel('NT1DETAIL') // Vencimentos
oModelNTR   := oModel:GetModel('NTRDETAIL') // Faixa de valores
nQtdNTR     := oModelNTR:GetQtdLine()
nQtdNUT     := oModelNUT:GetQtdLine()
nLnOldNT1   := oModelNT1:GetLine()
nQtdLnNUT   := nQtdNUT
nLnOldNUT   := oModelNUT:GetLine()
nLnOldNTR   := oModelNTR:GetLine()
oStructNT1  := oModelNT1:GetStruct()
lCanDelNT1  := oModelNT1:CanDeleteLine()
lCanUptNT1  := oModelNT1:CanUpdateLine()
lCanInsNT1  := oModelNT1:CanInsertLine()

If JUR96FAIXA(oModelNT0:GetValue('NT0_CTPHON')) .And. !oModelNUT:IsEmpty() .And. oModelNT1:Length(.T.) > 0 .And. oModelNT1:GetValue("NT1_SITUAC") == "1"

	If !Empty(cSequen)
		nQtdNT1   := oModelNT1:GetQtdLine()
		For nI := 1 To nQtdNT1
			If oModelNT1:IsDeleted(nI)
				Loop
			EndIf
			If oModelNT1:GetValue("NT1_SEQUEN", nI) == cSequen
				oModelNT1:GoLine(nI)
				Exit
			EndIf
		Next nI
	EndIf

	If cQtdCsAut == "2" // Quantidade de casos / processos será indicada manualmente
		nQtdCasPro := oModelNT1:GetValue('NT1_QTDADE')
	Else
		If NT0->(ColumnPos( "NT0_CASPRO" )) > 0 .And. oModelNT0:GetValue('NT0_CASPRO') == "2" // Processos - Utiliza função do SIGAJURI que retorna o número de processos
			nQtdCasPro := JurQtdProc(oModelNT1:GetValue('NT1_DATAIN'), oModelNT1:GetValue('NT1_DATAFI'), .T. /*Em andamento*/, oModelNT0:GetValue('NT0_FXABM') == "1", oModelNT0:GetValue('NT0_FXENCM') == "1", oModelNT0:GetValue('NT0_COD'))
		Else // Casos
			For nI := 1 To nQtdLnNUT
				If oModelNUT:IsDeleted(nI) .Or. ;
					!J96ConsCaso(oModelNUT:GetValue("NUT_CCLIEN",nI),oModelNUT:GetValue("NUT_CLOJA",nI),oModelNUT:GetValue("NUT_CCASO",nI))
					nQtdNUT--
				EndIf
			Next nI
			nQtdCasPro := nQtdNUT
		EndIf
	EndIf

	If nQtdCasPro > 0
		Do Case
		Case oModelNT0:GetValue("NT0_TPFX") == "1" // Estática
			aValores := JFindMdlM(oModelNTR, ;
				"FwFldGet('NTR_VLINI') <= "+AllTrim(STR(nQtdCasPro))+" .And. FwFldGet('NTR_VLFIM') >= "+AllTrim(STR(nQtdCasPro)), ;
				{"NTR_VALOR","NTR_TPVL"})
			If !Empty(aValores)
				nValor := aValores[1]
				If aValores[2] == "2"
					nValor := nValor * nQtdCasPro
				EndIf
			EndIf

		Case oModelNT0:GetValue("NT0_TPFX") == "2" // Progressiva
			For nI := 1 To nQtdNTR
				Iif(nI > 1, nDif := 1, nDif := 0)
				If !oModelNTR:IsDeleted(nI)
					If oModelNTR:GetValue('NTR_VLINI',nI) <= oModelNTR:GetValue('NTR_VLFIM',nI) .And. oModelNTR:GetValue('NTR_VLINI',nI) <= nQtdCasPro
						If oModelNTR:GetValue("NTR_TPVL",nI) == "2" //Valor Unitário
							If nQtdCasPro <= oModelNTR:GetValue('NTR_VLFIM',nI)
								nValor += ((nQtdCasPro - (oModelNTR:GetValue('NTR_VLINI',nI) - nDif)) * oModelNTR:GetValue("NTR_VALOR",nI))
							Else
								nValor += ((oModelNTR:GetValue('NTR_VLFIM',nI) - (oModelNTR:GetValue('NTR_VLINI',nI) - nDif)) * oModelNTR:GetValue("NTR_VALOR",nI))
							EndIf
						Else
							nValor += oModelNTR:GetValue("NTR_VALOR",nI) //Valor Fixo
						EndIf
					EndIf
				EndIf
			Next
		End Case
	EndIf

	// Gravação dos valores
	If !lSmartUI
		J096SetNo(oModelNT1, .F.)
		oStructNT1:setProperty("NT1_VALORB", MODEL_FIELD_WHEN, {|model| !model:isDeleted() .and. model:GetValue("NT1_SITUAC")=="1" })
		oStructNT1:setProperty("NT1_VALORA", MODEL_FIELD_WHEN, {|model| !model:isDeleted() .and. model:GetValue("NT1_SITUAC")=="1" })
		oModelNT1:SetValue("NT1_VALORB", nValor)
	EndIf
	If NT1->(ColumnPos("NT1_QTDADE")) > 0
		oModelNT1:SetValue("NT1_QTDADE", nQtdCasPro)
	EndIf
	cNT1Descri := Iif(NT0->(ColumnPos("NT0_CASPRO")) > 0 .And. oModelNT0:GetValue('NT0_CASPRO') == "1", STR0220, STR0221) //"Quantidade de casos: ", "Quantidade de processos:"
	If !(Upper(cNT1Descri + Alltrim(STR(nQtdCasPro))) $ Upper(oModelNT1:GetValue("NT1_DESCRI")))

		cDescriPar := oModelNT1:GetValue("NT1_DESCRI")
		nPosDesc   := At(cNT1Descri, cDescriPar)

		If nPosDesc > 0
			// Extrai o número antigo para substituir
			cNumPos := Substr(cDescriPar, nPosDesc + Len(cNT1Descri))
			
			// Pega só os dígitos do número antigo
			While nX <= Len(cNumPos) .And. Substr(cNumPos, nX, 1) >= "0" .And. Substr(cNumPos, nX, 1) <= "9"
				cNumExtDes += Substr(cNumPos, nX, 1)
				nX++
			EndDo
			
			// Substitui o número antigo pelo valor da variável nQtdCasPro
			cDescriPar := StrTran(cDescriPar, cNT1Descri + cNumExtDes, cNT1Descri + Alltrim(Str(nQtdCasPro)))
		Else
			// Se não existir, adiciona o texto com o valor de nQtdCasPro
			cDescriPar += CRLF + cNT1Descri + Alltrim(Str(nQtdCasPro))
		EndIf

		// Atualiza o valor da Descrição
		oModelNT1:SetValue("NT1_DESCRI", cDescriPar)
	EndIf

	If Empty(nValor)
		IIF(lSmartUI, cMsg := STR0170, Alert(STR0170)) // "Não foi possível calcular o valor da parcela. Verifique se há faixas cadastradas e/ou casos/processos para o período da parcela."
	EndIf

Else
	IIF(lSmartUI, cMsg := STR0084, Alert(STR0084)) // "Só é possivel calcular parcelas pendentes!"
EndIf

If !lSmartUI
	oModelNT1:GoLine(nLnOldNT1)
	oModelNUT:GoLine(nLnOldNUT)
	oModelNTR:GoLine(nLnOldNTR)
EndIf

// Retorna os valores padrões
If !lSmartUI
	oModelNT1:SetNoDeleteLine(!lCanDelNT1)
	oModelNT1:SetNoInsertLine(!lCanInsNT1)
	oModelNT1:SetNoUpdateLine(!lCanUptNT1)
EndIf

Return nValor

//-------------------------------------------------------------------
/*/{Protheus.doc} J96ConsCaso
Função utilizada para verificar se o caso deve entrar ou não no cálculo
de Quantidade de Casos, considerando sua data de entrada/encerramento.

@Param  cCliente  Cliente do Caso a ser consultado
@Param  cLoja     Loja do Caso a ser consultado
@Param  cCaso     Caso a ser consultado

@Return lRet      .T./.F. Considera ou não

@author Cristina Cintra
@since 13/07/2017
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function J96ConsCaso(cCliente, cLoja, cCaso)
Local lRet      := .T.
Local aArea     := GetArea()
Local aAreaNVE  := NVE->(GetArea())
Local lFxAber   := FwFldGet("NT0_FXABM")  == '1' //Considera casos abertos no mês de referência
Local lFxEnce   := FwFldGet("NT0_FXENCM") == '1' //Considera casos encerrados no mês de referência
Local dDTRefIni := FwFldGet("NT1_DATAIN")
Local dDTRefFim := FwFldGet("NT1_DATAFI")

If Empty(dDTRefIni) .Or. Empty(dDTRefFim)
	lRet := .F.
EndIf

If lRet
	NVE->(dbSetOrder(1))
	If NVE->(dbSeek(xFilial('NVE')+cCliente+cLoja+cCaso)) .And. (NVE->NVE_ENCHON = '2')
		If NVE->NVE_SITUAC == "1" // Andamento
			If lFxAber
				lRet := NVE->NVE_DTENTR < dDTRefFim+1
			Else
				lRet := NVE->NVE_DTENTR < dDTRefIni
			EndIf
		Else // Encerrado
			If lFxAber
				If lFxEnce
					lRet := NVE->NVE_DTENTR < dDTRefFim+1 .AND. NVE->NVE_DTENCE > dDTRefIni-1
				Else
					lRet := NVE->NVE_DTENTR < dDTRefFim+1 .AND. NVE->NVE_DTENCE > dDTRefFim
				EndIf
			Else
				If lFxEnce
					lRet := NVE->NVE_DTENTR < dDTRefIni .AND. NVE->NVE_DTENCE > dDTRefIni-1
				Else
					lRet := NVE->NVE_DTENTR < dDTRefIni .AND. NVE->NVE_DTENCE > dDTRefFim
				EndIf
			EndIf
		EndIf
	Else
		lRet := .F.
	EndIf
EndIf

NVE->(RestArea(aAreaNVE))
RestArea(aArea)

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} J096TemCpo
Função utilizada para validar se o contrato terá faixa de faturamento

@Param  nBotao Botão a ser validado como base para a validação (Faixa de Valores ou Condições de Faturamento)
@Param  lShowMsg  Exibe ou não mensagem quanto ao tipo de honorário

@Return nAt	 	.T./.F. As informações são válidas ou não

@author Felipe Bonvicini Conti
@since 25/02/10
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function J096TemCpo(nBotao, lShowMsg)
Local lTemCpo := .F.
Local nAt     := 0
Local nI      := 0

Default lShowMsg := .T.

If ( nAt := aScan( aCpoBotoes, { |x| x[CTPHON] == FwFldGet('NT0_CTPHON') .AND. X[BOTAO] == nBotao } ) ) == 0
	ApMsgStop( STR0017 + FwFldGet('NT0_CTPHON') + STR0018 ) //### //"Não existe configuração de relacionamento de campos para o tipo de contrato "###" e este botão ou o tipo não foi informado."
	Return 0
EndIf

For nI := 1 To Len( aCpoBotoes[nAt][CONFIG] )
	If ( lTemCpo := Iif( aCpoBotoes[nAt][CONFIG][nI][VISIV], .T.,  lTemCpo ) )
		Exit
	EndIf
Next

If !lTemCpo
	Iif(lShowMsg, ApMsgStop( STR0027 ), ) //"Não há campos a serem utilizados para este tipo de honorários"
	Return 0
EndIf

Return nAt

//-------------------------------------------------------------------
/*/ { Protheus.doc } J70ATUNT5
Rotina para Atualizar o valor do campo revisado da tabela NT5

@author Felipe Bonvicini Conti
@since 02/03/10
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function J96ATUNT5(oModelNT5)
Local nQtd     := oModelNT5:GetQtdLine()
Local nLineOld := oModelNT5:nLine
Local nI       := 0

If !oModelNT5:IsEmpty()
	For nI:=1 To nQtd
		oModelNT5:GoLine(nI)
		If !oModelNT5:IsDeleted()
			oModelNT5:SetValue("NT5_REV", "2")
		EndIf
	Next
EndIf

oModelNT5:GoLine(nLineOld)

Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} JA144REVAL
Revaloriza os Time-Sheets dos casos do contrato

@Param cCodCont			Código do Contrato

@author Jacques Alves Xavier
@since 08/02/2010
@version 1.0
/*/
//-------------------------------------------------------------------
Function JA096REVAL(cCodCont)
Local lRet := .F.
	MsgRun(STR0209, , {|| lRet := JA096REVTS(cCodCont) } ) //"Revalorizando TS"
Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} JA096REVTS
Revaloriza os Time-Sheets dos casos do contrato

@Param cCodCont    , Código do Contrato
@param lAutomato   , Execução via automação
@param lSmartUI    , Execução vis Smart UI
@param lCancSmartUI, Se cancela a pré-fatura vincula ao contrato
@param cStatus     , Código da mensagem a ser retornada para o front
@param cMensagem   , Mensagem a ser retornada para o front conforme status

@author Jacques Alves Xavier
@since 08/02/2010
/*/
//-------------------------------------------------------------------
Function JA096REVTS(cCodCont, lAutomato, lSmartUI, lCancSmartUI, cStatus, cMensagem)
Local aArea       := GetArea()
Local aAreaNUE    := NUE->(GetArea())
Local cQuery      := ""
Local cQueryRes   := ""
Local cCodPre     := ""
Local cPrefCanc   := ""
Local oModel      := FwModelActive(, .T.)
Local lOk         := .T.
Local lRet        := .T.
Local lLock       := .F.
Local lTsVincPre  := .F.
Local cMsg        := ""
Local cMsgCancel  := ""
Local aResult     := {}
Local aTimeSheets := {}
Local aTsOk       := {}
Local lTodosTSBloq:= .T.
Local nI          := 0
Local cCodTS      := ""
Local cCodTSPre   := ""
Local lLiberaTudo := .F.
Local lLibAltera  := .F.
Local lLibParam   := .T.
Local aRetBlqTS   := {}
Local cUsuario    := JurUsuario(__CUSERID)
Local lLCPRE      := JurGetDados("NUR", 1, xFilial("NUR") + cUsuario, "NUR_LCPRE") == "1"
Local lAltHr      := NUE->(ColumnPos('NUE_ALTHR')) > 0
Local lTemPreft   := .F.
Local lTemMinuta  := .F.
Local lCancela    := .T.

Default lAutomato   := .F.
Default lSmartUI    := .F.
Default lCancSmartUI := .F.
Default cStatus     := ""
Default cMensagem   := ""

If lAutomato .Or. ApMsgYesNo(STR0089) //"Deseja revalorizar os Time-Sheets dos casos do contrato selecionado?"
	lLock := LockByName("SIGAPFS_CONTR_" + cCodCont + "_TIMESHEET", .T., .T., /*lMayIUseDisk*/)

	If lLock
		// Time Sheets não vinculados a pré-faturas ou minutas
		cQuery    := " SELECT NUE_CPREFT, NUE.R_E_C_N_O_  NUERECNO, NUE_DATATS, NUE_COD, '2' TEMMINUTA "
		cQuery    +=   " FROM " + RetSqlName("NUE") + " NUE "
		cQuery    +=  " WHERE NUE.D_E_L_E_T_ = ' ' "
		cQuery    +=    " AND NUE.NUE_FILIAL = '" + xFilial( "NT0" ) +"' "
		cQuery    +=    " AND NUE.NUE_SITUAC = '1' "
		cQuery    +=    " AND NUE.NUE_CPREFT = '" + Space(TamSx3('NUE_CPREFT')[1]) + "' "
		cQuery    +=    " AND EXISTS ( SELECT NUT.R_E_C_N_O_ "
		cQuery    +=                   " FROM " + RetSqlName("NUT") + " NUT "
		cQuery    +=                  " WHERE NUT.D_E_L_E_T_ = ' ' "
		cQuery    +=                    " AND NUT.NUT_FILIAL = '" + xFilial( "NT0" ) +"' "
		cQuery    +=                    " AND NUT.NUT_CCONTR = '" + cCodCont + "' "
		cQuery    +=                    " AND NUT.NUT_CCLIEN = NUE.NUE_CCLIEN "
		cQuery    +=                    " AND NUT.NUT_CLOJA  = NUE.NUE_CLOJA "
		cQuery    +=                    " AND NUT.NUT_CCASO  = NUE.NUE_CCASO ) "
		cQuery    +=  " UNION "
		// Time Sheets vinculados somente a pré-faturas
		cQuery    += " SELECT NUE_CPREFT, NUE.R_E_C_N_O_  NUERECNO, NUE_DATATS, NUE_COD, '2' TEMMINUTA "
		cQuery    +=   " FROM " + RetSqlName("NUE") + " NUE "
		cQuery    +=  " WHERE NUE.D_E_L_E_T_ = ' ' "
		cQuery    +=    " AND NUE.NUE_FILIAL = '" + xFilial( "NT0" ) +"' "
		cQuery    +=    " AND NUE.NUE_SITUAC = '1' "
		cQuery    +=    " AND NUE.NUE_CPREFT > '" + Space(TamSx3('NUE_CPREFT')[1]) + "' "
		cQuery    +=    " AND EXISTS ( SELECT NUT.R_E_C_N_O_ "
		cQuery    +=                   " FROM " + RetSqlName("NUT") + " NUT "
		cQuery    +=                  " WHERE NUT.D_E_L_E_T_ = ' ' "
		cQuery    +=                    " AND NUT.NUT_FILIAL = '" + xFilial( "NT0" ) +"' "
		cQuery    +=                    " AND NUT.NUT_CCONTR = '" + cCodCont + "' "
		cQuery    +=                    " AND NUT.NUT_CCLIEN = NUE.NUE_CCLIEN "
		cQuery    +=                    " AND NUT.NUT_CLOJA  = NUE.NUE_CLOJA "
		cQuery    +=                    " AND NUT.NUT_CCASO  = NUE.NUE_CCASO ) "
		cQuery    +=                    " AND NOT EXISTS (SELECT 1 "
		cQuery    +=                                      " FROM " + RetSqlName("NXA") + " NXA "
		cQuery    +=                                     " WHERE NXA.NXA_FILIAL = NUE.NUE_FILIAL"
		cQuery    +=                                       " AND NXA.NXA_CPREFT = NUE.NUE_CPREFT"
		cQuery    +=                                       " AND NXA.NXA_SITUAC = '1'"
		cQuery    +=                                       " AND NXA.NXA_TIPO IN ('MP', 'MS', 'MF')"
		cQuery    +=                                       " AND NXA.D_E_L_E_T_ = ' ')"
		cQuery    +=  " UNION "
		// Time Sheets vinculados a minutas de pré-faturas e minutas sócio
		cQuery    += " SELECT NUE_CPREFT, NUE.R_E_C_N_O_  NUERECNO, NUE_DATATS, NUE_COD, '1' TEMMINUTA "
		cQuery    +=   " FROM " + RetSqlName("NUE") + " NUE "
		cQuery    +=  " WHERE NUE.D_E_L_E_T_ = ' ' "
		cQuery    +=    " AND NUE.NUE_FILIAL = '" + xFilial( "NT0" ) +"' "
		cQuery    +=    " AND NUE.NUE_SITUAC = '1' "
		cQuery    +=    " AND NUE.NUE_CPREFT > '" + Space(TamSx3('NUE_CPREFT')[1]) + "' "
		cQuery    +=    " AND EXISTS  (SELECT NUT.R_E_C_N_O_ "
		cQuery    +=                   " FROM " + RetSqlName("NUT") + " NUT "
		cQuery    +=                  " WHERE NUT.D_E_L_E_T_ = ' ' "
		cQuery    +=                    " AND NUT.NUT_FILIAL = '" + xFilial( "NT0" ) +"' "
		cQuery    +=                    " AND NUT.NUT_CCONTR = '" + cCodCont + "' "
		cQuery    +=                    " AND NUT.NUT_CCLIEN = NUE.NUE_CCLIEN "
		cQuery    +=                    " AND NUT.NUT_CLOJA  = NUE.NUE_CLOJA "
		cQuery    +=                    " AND NUT.NUT_CCASO  = NUE.NUE_CCASO) "
		cQuery    +=                    " AND EXISTS (SELECT 1 "
		cQuery    +=                                  " FROM " + RetSqlName("NXA") + " NXA "
		cQuery    +=                                 " WHERE NXA.NXA_FILIAL = NUE.NUE_FILIAL"
		cQuery    +=                                   " AND NXA.NXA_CPREFT = NUE.NUE_CPREFT"
		cQuery    +=                                   " AND NXA.NXA_SITUAC = '1'"
		cQuery    +=                                   " AND NXA.NXA_TIPO IN ('MP', 'MS')"
		cQuery    +=                                   " AND NXA.D_E_L_E_T_ = ' ')"
		cQuery    +=  " ORDER BY TEMMINUTA"

		cQueryRes := GetNextAlias()
		dbUseArea(.T., "TOPCONN", TcGenQry(,, cQuery), cQueryRes, .T., .T.)

		TcSetField((cQueryRes), "NUE_DATATS", "D", 8, 0)
		
		lTemMinuta := (cQueryRes)->TEMMINUTA == '1'
		
		While !(cQueryRes)->(EOF())
			
			Aadd(aTimeSheets, {(cQueryRes)->NUE_DATATS, (cQueryRes)->NUE_CPREFT, (cQueryRes)->NUE_COD, (cQueryRes)->NUERECNO})
             //                      1                              2                       3                4
			(cQueryRes)->(DbSkip())
		EndDo

		(cQueryRes)->(DbCloseArea())

		aEVal(aTimeSheets, {|x| cCodPre += x[2]})
		lTemPreft  := !Empty(cCodPre)
		 //STR0085 -> "Existe(m) pré-fatura(s) para este contrato. Ao efetivar a revalorização as pré-fatura(s) terão o status atualizados para situação 'Alterada'. Deseja continuar? Caso seja selecionada a opção 'Não', serão revalorizados apenas time sheets que não possuem vínculos com pré-faturas."
		 //STR0266 -> "Existe(m) minuta(s) e pré-fatura(s) para este contrato. Ao efetivar a revalorização, a(s) minuta(s) será(ão) cancelada(s) e as pré-fatura(s) terá(ão) o status atualizado para situação 'Alterada'. Deseja continuar? Caso seja selecionada a opção 'Não', serão revalorizados apenas time sheets que não possuem vínculos com pré-faturas/minutas."
		cMsgCancel := IIf(lTemMinuta, STR0266, STR0085)
		If lOk
			If lTemPreft .And. !lAutomato .And. !lSmartUI
				lCancela := ApMsgYesNo(cMsgCancel)
			ElseIf lSmartUI
				lCancela := lCancSmartUI
			EndIf
			For nI := 1 To Len(aTimeSheets)
				lOk := .F.
				lTsVincPre := !Empty(Alltrim(aTimeSheets[nI, 2]))
				If lLibParam
					aRetBlqTS := JBlqTSheet(aTimeSheets[nI, 1]) // Parâmetro da função: Data do Timesheet
				EndIf
				lLiberaTudo   := aRetBlqTS[1]
				lLibAltera    := aRetBlqTS[3]
				lLibParam     := aRetBlqTS[5]
				If lLiberaTudo .And. lLibAltera .And. lLibParam
					lTodosTSBloq := .F.
					lOk          := .T.
				ElseIf !lLibParam
					lRet := .F.
					Exit
				EndIf

				If lOk .And. lTsVincPre
					lOk := !(JurGetDados("NX0", 1, xFilial("NX0") + aTimeSheets[nI, 2], "NX0_SITUAC") $ "4|C|F") // Emitir Fatura | Em Revisão | Aguardando Sincronização
					If !lOk
						cCodTSPre +=  aTimeSheets[nI, 3] + CRLF
					EndIf
				ElseIf !lOk
					cCodTS +=  aTimeSheets[nI, 3] + CRLF  // Código dos times sheets que não há permissão para alterar.
				EndIf

				If lOk
					If lTsVincPre // Time Sheet vinculado a Pré-fatura
						If lLCPRE .And. lCancela
							If lTemMinuta .And. cPrefCanc <> aTimeSheets[nI, 2]
								lOk := J202CanMin(aTimeSheets[nI, 2], STR0267) // "Revalorização dos TimeSheets - JURA096"
							EndIf
							If lOk
								If cPrefCanc <> aTimeSheets[nI, 2] // Muda situação das pré-faturas que não tem minutas vinculados aos timesheets.
									J144AltPre(aTimeSheets[nI, 2], STR0267, .T., .T.) // "Revalorização dos TimeSheets - JURA096"
								EndIf
								cPrefCanc := aTimeSheets[nI, 2]
								NUE->(DBGoTo(aTimeSheets[nI, 4]))
								RecLock( 'NUE', .F. )
								NUE->NUE_CUSERA := cUsuario
								NUE->NUE_ALTDT  := Date()
								If lAltHr
									NUE->NUE_ALTHR := Time()
								EndIf
								NUE->(MsUnlock())
								//Grava na fila de sincronização a alteração
								J170GRAVA("NUE", xFilial("NUE") + NUE->NUE_COD, "4")
								Aadd(aTsOk, aTimeSheets[nI, 4])
							EndIf
						EndIf
					Else
						Aadd(aTsOk, aTimeSheets[nI, 4])
					EndIf
				EndIf
			Next
		Endif

		If lTodosTSBloq .And. Len(aTimeSheets) > 0 .And. lLibParam
			If lSmartUI
				cStatus := IIf(cStatus <> "1", "6", cStatus)
				cMensagem := STR0206
			Else 
				cMsg := STR0206 + CRLF + cCodTS // "Você não tem permissão para alterar os seguintes Time Sheets: "
			EndIf
		ElseIf lLibParam
			dbSelectarea('NUE')

			For nI := 1 To Len(aTsOk)
				NUE->(DbGoTo(aTsOk[nI]))
				If NUE->NUE_SITUAC == '1'
					FWMonitorMsg("JA096REVTS: Reval TS - " + NUE->NUE_COD )
					// Revaloriza TS - não considera o parâmetro
					aResult := JURA200(NUE->NUE_COD, NUE->NUE_CPART2, NUE->NUE_CCLIEN, NUE->NUE_CLOJA, NUE->NUE_CCASO, NUE->NUE_ANOMES,, NUE->NUE_CATIVI)

					If Empty(aResult[1])
						lRet    := .F.
						cCodTS  += NUE->NUE_COD + CRLF //JurMsgErro( STR0025 ) // Erro na valorização do Time Sheet
						cStatus := "1"
					Else
						If (oModel == NIL) .OR. (oModel != NIL .AND. (oModel:GetOperation() == 3 .OR. oModel:GetOperation() == 4 ))
							RecLock("NUE", .F.)
							NUE->NUE_CMOEDA := aResult[1]
							NUE->NUE_VALORH := aResult[2]
							NUE->NUE_VALOR  := aResult[2] * NUE->NUE_TEMPOR
							NUE->NUE_CUSERA := JurUsuario(__CUSERID)
							NUE->NUE_ALTDT  := Date()
							If lAltHr
								NUE->NUE_ALTHR  := Time()
							EndIf
							NUE->(MsUnlock())
							//Grava na fila de sincronização a alteração
							J170GRAVA("NUE", xFilial("NUE") + NUE->NUE_COD, "4")
						EndIf
					EndIf
				EndIf
			Next
		EndIf
		FWMonitorMsg("JA096REVTS: Reval TS - OK")
		lRet := UnLockByName("SIGAPFS_CONTR_" + cCodCont + "_TIMESHEET", .T., .T., /*lMayIUseDisk*/)
	EndIf

	If !Empty(cCodTSPre)
		If lSmartUI
			cStatus := IIf(cStatus <> "1", "4", cStatus)
			cMensagem := STR0226
		Else 
			MsgAlert(STR0226 + CRLF + cCodTSPre) // "Os seguintes Time Sheets não foram revalorizados pois estão vinculados a pré-fatura em processo de revisão: "
		EndIf
	EndIf

	If !lTodosTSBloq .And. lLibParam
		If !Empty(cCodTS)
			If lSmartUI
				cStatus := IIf(cStatus <> "1", "5", cStatus)
				cMensagem := STR0207
			Else 
				JurErrLog(STR0207 + CRLF + cCodTS) // "Alguns Time Sheets não foram revalorizados. Você não tem permissão para alterar os seguintes Time Sheets: "
			EndIf
		EndIf
	ElseIf lLibParam
		If lSmartUI
			cStatus := Iif(cStatus <> "1", "7", cStatus)
			cMensagem := STR0156
		Else 
			JurErrLog(cMsg, STR0156) // "Os Time Sheets não foram revalorizados"
		EndIf
	EndIf

	If (!lAutomato .Or. lSmartUI) .And. lRet .And. !lTodosTSBloq .And. Empty(cCodTSPre) .And. Len(aTsOk) > 0
		If lSmartUI
			cStatus := IIf(cStatus <> "1" .And. cStatus <> "2", "3", cStatus)
			cMensagem := STR0117
		Else 
			MsgInfo(STR0117) // "Time Sheet revalorizado"
		EndIf
	ElseIf (!lAutomato .Or. lSmartUI) .And. lRet .And. !lTodosTSBloq .And. Empty(cCodTSPre) .And. Len(aTsOk) == 0
		If lSmartUI
			cStatus := IIf(cStatus <> "1", "2", cStatus)
			cMensagem := STR0268
		Else 
			MsgInfo(STR0268) // "Não há Time Sheets pendentes para serem revalorizados."
		EndIf
	EndIf

EndIf

RestArea( aAreaNUE )
RestArea(aArea)

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} J96CorrCDF
Função utilizada para corrigir o valor.

@param oModel      Modelo de dados do cadastro de contratos
@param lCanPrefat  Se cancela pré-fatura vinculada ao contrato
                   (utilizado pelo SmartUI)
@param lSmartUI    Se está vindo do Smart UI 
@param cMsg        Variável para armazenar as mensagens de validação
                   quando a chamada for do SmartUI

@Obs     Ao realizar manutenção da rotina, verificar a rotina original J201ECorrF

@author Felipe Bonvicini Conti
@since 09/04/2010
@version 1.0
/*/
//-------------------------------------------------------------------
Function J96CorrCDF(oModel, lSmartUI, cMsg)
Local oModelNT0  := oModel:GetModel('NT0MASTER')
Local oModelNT1  := oModel:GetModel('NT1DETAIL') // Parcelas fixas
Local cTpHon     := oModelNT0:GetValue('NT0_CTPHON')
Local nQtdNT1    := oModelNT1:GetQtdLine()
Local nLineNT1   := 0
Local lAutomatic := J96TPHPAut(cTpHon) //Indica se a geração das parcelas é automática ou manual
Local lTudoOK    := FwIsInCallStack("JUR96TUDOK")
Local lBOK       := FwIsInCallStack("JUR96BOK")
Local cMsgLog    := ""
Local cMoedaNac  := SuperGetMv('MV_JMOENAC',, '01')

Default cMsg     := ""
Default lSmartUI := .F.

If !lSmartUI
	/* Quando o tipo for geração automática será atualizado o valor no contrato e em todas as parcelas pendentes considerando o seu período.
	Já quando for manual, será atualizada apenas a parcela em que o usuário estiver posicionado e o valor atual no contrato.
	*/
	If lAutomatic
		cTabela := "NT0"
		For nLineNT1 := oModelNT1:GetLine() To nQtdNT1
			If J96VerPreFat(oModel, nLineNT1, /*lCancSmartUI*/, /*lSmartUI*/, /*cMsgPrefat*/, @cMsg)
				J96Corrige(oModelNT0, oModelNT1, nLineNT1, lSmartUI, lAutomatic, @cMsg, cMoedaNac)
			EndIf

			If !Empty(cMsg)
				cMsgLog += cMsg + CRLF + Replicate("-", 106) + CRLF
				cMsg    := ""
			EndIf
		Next nI
	Else
		cTabela := "NT1"
		If J96VerPreFat(oModel, oModelNT1:GetLine(), /*lCancSmartUI*/, /*lSmartUI*/, /*cMsgPrefat*/, @cMsg)
			J96Corrige(oModelNT0, oModelNT1, nLineNT1, lSmartUI, lAutomatic, @cMsg, cMoedaNac)
		EndIf
	EndIf
	If !Empty(cMsgLog) .And. !lSmartUI .And. !lTudoOK .And. !lBOK .And. !IsBlind()
		JurErrLog(cMsgLog, STR0150) // Atenção
	EndIf
EndIf

Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} J96Corrige
Efetua a correção monetária das parcelas fixas com base em um
índice.

@param oModelNT0  SubModelo de dados principal do cadastro de contratos
@param oModelNT1  SubModelo de dados das parcelas fixas
@param nLineNT1   Linha corrente na NT1 (parcela fixa)
@param lSmartUI   Se está vindo do Smart UI
@param lAutomatic Se o tipo de honorário fixo é parcela automática
@param cMsg       Variável para armazenar as mensagens de validação
                  quando a chamada for do SmartUI
@param cMoedaNac  Código da moeda nacional

@author Abner Fogaça
@since 17/07/2024
/*/
//-------------------------------------------------------------------
Function J96Corrige(oModelNT0, oModelNT1, nLineNT1, lSmartUI, lAutomatic, cMsg, cMoedaNac)
Local cTabela    := IIf(lAutomatic == .T., "NT0", "NT1")
Local nValorBase := 0
Local nValorAtu  := 0

If !oModelNT1:IsEmpty() .And. !oModelNT0:GetValue("NT0_TPCORR") == "1"

	If lAutomatic
		nValorBase := oModelNT0:GetValue("NT0_VLRBAS")
	Else
		If !oModelNT1:IsDeleted() .And. oModelNT1:GetValue("NT1_SITUAC") == "1" //Parcela Pendente
			nValorBase := oModelNT1:GetValue("NT1_VALORB")
		Else
			IIf(lSmartUI, cMsg := STR0090, ApMsgStop(STR0090)) // "Só é possivel corrigir parcelas pendentes!"
		EndIf
	EndIf

	If !Empty(cTabela)

		If lAutomatic

			aResult := JFindMdl(oModelNT1, "NT1_SITUAC", "1", {"POSICAO"})
			If !Empty(aResult)
				oModelNT1:GoLine(nLineNT1)
			Else
				IIf(lSmartUI, cMsg := STR0100, ApMsgStop(STR0100)) // "Não foi possivel encontrar parcela pendente."
				Return Nil
			EndIf

			J096SetNo(oModelNT1, .F.)

			If !oModelNT1:IsDeleted(nLineNT1) .And. oModelNT1:GetValue("NT1_SITUAC", nLineNT1) == '1'

				nValorAtu := 0

				If Iif(Empty(oModelNT1:GetValue("NT1_CMOEDA", nLineNT1)), oModelNT0:GetValue("NT0_CMOEF"), oModelNT1:GetValue("NT1_CMOEDA", nLineNT1)) == cMoedaNac  //Só Faz a correção da parcela se o valor for em moeda nacional.

					nValorAtu := JCorrIndic(nValorBase, ;
											oModelNT0:GetValue("NT0_DTBASE"), ;
											oModelNT1:GetValue("NT1_DATAVE", nLineNT1), ;
											oModelNT0:GetValue("NT0_PERCOR"), ;
											oModelNT0:GetValue("NT0_CINDIC"), ;
											"V",;
											/*lShowErro*/,;
											"",;  // cCompl
											.F.,; // lAutomato
											lSmartUI,;
											@cMsg)
				Else
					nValorAtu := oModelNT1:GetValue("NT1_VALORB", nLineNT1)
				EndIf

			EndIf

			// Ajusta o valor da parcela quando se tratar de Misto
			If oModelNT0:GetValue('NT0_FIXEXC') == '2' .And. !Empty(oModelNT0:GetValue('NT0_PEREX')) .And. !Empty(oModelNT0:GetValue('NT0_PERFIX'))
				nValorAtu := nValorAtu / (oModelNT0:GetValue('NT0_PEREX') / oModelNT0:GetValue('NT0_PERFIX'))
			EndIf
			If !Empty(oModelNT0:GetValue('NT0_PERCD'))
				nValorAtu := nValorAtu - ( nValorAtu * ( oModelNT0:GetValue('NT0_PERCD') / 100 ) )
			EndIf

			If !Empty(nValorAtu)
				oModelNT1:LoadValue("NT1_VALORA", nValorAtu)
				oModelNT1:LoadValue("NT1_DATAAT", Date())
			EndIf

			// Preenche o valor base atualizado do contrato
			nValorAtu := JCorrIndic(nValorBase,   ;
									oModelNT0:GetValue("NT0_DTBASE"), ;
									Nil, ;
									oModelNT0:GetValue("NT0_PERCOR"), ;
									oModelNT0:GetValue("NT0_CINDIC"), ;
									"V",;
									/*lShowErro*/,;
									"",;  // cCompl
									.F.,; // lAutomato
									lSmartUI,;
									@cMsg)

			If !Empty(nValorAtu)
				oModelNT0:LoadValue( "NT0_VALORA", nValorAtu )
				oModelNT0:LoadValue( "NT0_DATAAT", Date() )
			EndIf

		Else // Correção monetaria de uma unica parcela

			If !oModelNT1:IsDeleted() .And. oModelNT1:GetValue("NT1_SITUAC") == '1'

				If Iif(Empty(oModelNT1:GetValue("NT1_CMOEDA")), oModelNT0:GetValue("NT0_CMOEF"), oModelNT1:GetValue("NT1_CMOEDA")) == cMoedaNac  //Só Faz a correção da parcela se o valor for em moeda nacional.

					nValorAtu := JCorrIndic(nValorBase,;
											oModelNT0:GetValue("NT0_DTBASE"), ;
											oModelNT1:GetValue("NT1_DATAVE"), ;
											oModelNT0:GetValue("NT0_PERCOR"), ;
											oModelNT0:GetValue("NT0_CINDIC"), ;
											"V",;
											/*lShowErro*/,;
											"",;  // cCompl
											.F.,; // lAutomato
											lSmartUI,;
											@cMsg)

					If !Empty(nValorAtu)
						oModelNT1:LoadValue( "NT1_VALORA", nValorAtu )
						oModelNT1:LoadValue( "NT1_DATAAT", Date() )

						// Preenche o valor base atualizado do contrato
						nValorAtu := JCorrIndic(oModelNT0:GetValue("NT0_VLRBAS"),   ;
												oModelNT0:GetValue("NT0_DTBASE"), ;
												Nil, ;
												oModelNT0:GetValue("NT0_PERCOR"), ;
												oModelNT0:GetValue("NT0_CINDIC"), ;
												"V",;
												/*lShowErro*/,;
												"",;  // cCompl
												.F.,; // lAutomato
												lSmartUI,;
												@cMsg)
					Else
						nValorAtu := oModelNT1:GetValue("NT1_VALORB", nLineNT1)
					EndIf

					If !Empty(nValorAtu)
						oModelNT0:LoadValue( "NT0_VALORA", nValorAtu )
						oModelNT0:LoadValue( "NT0_DATAAT", Date() )
					EndIf

				EndIf

			EndIf

			oModelNT1:GoLine(nLineNT1)

			If lAutomatic
				J096SetNo(oModelNT1, .T.)
			EndIf

		EndIf

	EndIf

EndIf

Return Nil
//-------------------------------------------------------------------
/*/{Protheus.doc} J096VLDCP
Função para validar os campos do contrato pelo dicionário

@author David G. Fernandes
@since 05/05/2010
@version 1.0
/*/
//-------------------------------------------------------------------
Function J096VLDCP(cCampo)
Local lRet      := .T.
Local cCliente  := ""
Local cLoja     := ""
Local cSitContr := ""
Local cMsg      := ""
Local oModel    := Nil

Do Case
Case cCampo == "NT0_DIAEMI"
	lRet := FwFldGet("NT0_DIAEMI") >= 0 .And. FwFldGet("NT0_DIAEMI") <= 31
	cMsg := STR0091 //"O dia deve estar entre 0 e 31"

Case cCampo == "NUT_CLOJA"
	cCliente  := FwFldGet("NUT_CCLIEN")
	cLoja     := FwFldGet("NUT_CLOJA")
	cSitContr := FwFldGet("NT0_SIT")
	If !Empty(cCliente) .And. !Empty(cLoja)
		aDadosCli := JurGetDados('NUH', 1, xFilial('NUH') + cCliente + cLoja, {"NUH_COD", "NUH_SITCAD"})
		If Len(aDadosCli) == 2 .And. !Empty(aDadosCli[1]) // Código do cliente na NUH
			If Empty(cCliente) .Or. !JAEXECPLAN("NUTDETAIL", "", "NUT_CCLIEN", "NUT_CLOJA", "NUT_CCASO", "NUT_CLOJA")
				lRet := .F.
				cMsg := STR0092 // "O Cliente/Loja inválido"
			ElseIf cSitContr == "2" .And. aDadosCli[2] == "1" // Contrato Definitivo cliente provisório
				lRet := .F.
				cMsg := STR0258 // "Não é permitido o uso de cliente com situação 'Provisória' em contratos definitivos!"
			EndIf
		Else
			lRet := .F.
			cMsg := STR0092 // "O Cliente/Loja inválido"
		EndIf
	EndIf

Case cCampo == "NT0_TPCEXC"
	oModel := FwModelActive()

	If FwFldGet("NT0_TPCEXC") == "1"
		oModel:LoadValue("NT0MASTER", "NT0_PERCD", 0)
	Else
		oModel:LoadValue("NT0MASTER", "NT0_LIMEXH", 0)
	EndIf
End Case

If !lRet
	JurMsgErro(cMsg,, STR0255) // "Ajuste o cadastro."
EndIf

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} J96VldDTE
Função utilizada para validar o intervalo de datas.

@author Felipe Bonvicini Conti
@since 13/05/2010
@version 1.0
/*/
//-------------------------------------------------------------------
Function J96VldDTE(dDataIni, dDataFim, cParcela)
Local lRet := .T.

If dDataIni >= dDataFim
	lRet := JurMsgErro(STR0095) //"A data final deve ser maior que a data inicial."
Else
	lRet := J096VldData(dDataIni, dDataFim, cParcela)
EndIf

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} JA096RELA
Função para inicializador padrão

@author Jacques Alves Xavier
@since 13/05/2010
@version 1.0
/*/
//-------------------------------------------------------------------
Function JA096RELA(cCampo)
Local cRet   := ""
Local oModel := FWModelActive()
Local aArea  := GetArea()

	If oModel:GetID() == 'JURA096'
		Do Case
			Case cCampo == "NUT_DCLIEN"
			cRet := JurGetDados("SA1", 1, xFilial("SA1") + NUT->NUT_CCLIEN + NUT->NUT_CLOJA, "A1_NOME")
		End Case
	EndIf

RestArea( aArea )

Return cRet

//-------------------------------------------------------------------
/*/{Protheus.doc} J96VldDTE
Função para inicializador padrão

@author Jacques Alves Xavier
@since 14/05/2010
@version 1.0
/*/
//-------------------------------------------------------------------
Function JA096VLENC()
Local lRet := .T.

If FwFldGet("NT0_DTENC") < FwFldGet("NT0_DTINC")
	lRet := JurMsgErro(STR0096) // "A data de encerramento deve ser maior ou igual a data de inclusão."
EndIf

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} J096SetNo
Função utilizada para bloquar o grid.

@author Felipe Bonvicini Conti
@since 18/05/2010
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function J096SetNo(oModel, lLiga)
	oModel:SetNoDeleteLine(lLiga)
	oModel:SetNoInsertLine(lLiga)
	oModel:SetNoUpdateLine(lLiga)
Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} JA096NUT
Verifica os casos vinculados a serem carregados na tela, a partir da
tela de processo

@param  	oModelGrid  	Model do Grid
@param 		lLoad           Indica se irá carregar
@return 	aRet			Array de linhas do grid

@author Juliana Iwayama Velho
@since 26/05/2010
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function JA096NUT(oModelGrid, lLoad)
Local aRet    := {}
Local aRet2   := {}
Local oStruct := Nil
Local aFields := {}
Local nPos    := 0
Local nI      := 0

	aRet  := FormLoadGrid(oModelGrid, lLoad)
	aRet2 := aClone( aRet )
	oStruct := oModelGrid:GetStruct()
	aFields := oStruct:GetFields()

	nPos := aScan(aFields, {|aX| aX[MODEL_FIELD_IDFIELD] == 'NUT_CCASO' } )

	If nPos > 0
		aRet2 := {}
		For nI := 1 To Len(aRet)
			If aRet[nI][2][nPos] == NSZ->NSZ_NUMCAS
				aAdd(aRet2, aClone(aRet[nI]))
			EndIf
		Next
	EndIf

Return aRet2

//-------------------------------------------------------------------
/*/{Protheus.doc} JA096VACY
Preenche o nome do grupo de clientes

@return 	cRet	Nome do grupo

@author Juliana Iwayama Velho
@since 26/05/2010
@version 1.0
/*/
//-------------------------------------------------------------------
Function JA096VACY()
Local aArea  := GetArea()
Local cRet   := ''

If IsInCallStack('JURA162') .Or. (!IsInCallStack('JURA162') .And. !INCLUI)
	cRet:= JurGetDados("ACY", 1, xFilial("ACY") + FwFldGet("NT0_CGRPCL"), "ACY_DESCRI")
EndIf

RestArea( aArea )

Return cRet

//-------------------------------------------------------------------
/*/{Protheus.doc} JA096VSA1
Preenche o nome do cliente

@return 	cRet	Nome do cliente

@author Juliana Iwayama Velho
@since 26/05/2010
@version 1.0
/*/
//-------------------------------------------------------------------
Function JA096VSA1()
Local aArea := GetArea()
Local cRet  := ''

If IsInCallStack('JURA162') .Or. (!IsInCallStack('JURA162') .And. !INCLUI)
	cRet := JurGetDados("SA1", 1, xFilial("SA1") + FwFldGet("NT0_CCLIEN") + FwFldGet("NT0_CLOJA"), "A1_NOME")
EndIf

RestArea( aArea )

Return cRet

//-------------------------------------------------------------------
/*/{Protheus.doc} JA096SGCAS
Verifica se os campos  de casos vinculados ao contrato devem ser
preenchidos ao entrar na tela. Utilização
desta rotina ao invés de inicializador padrão em cada campo

@param 	oModel  	Model a ser verificado

@author Juliana Iwayama Velho
@since 23/06/10
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function JA096SGCAS(oModel)
Local aArea   := {}
Local nOpc    := oModel:GetOperation()

If nOpc == 3
	If IsInCallStack('JURA162')
		oModel:SetValue("NUTDETAIL", 'NUT_CCLIEN',NSZ->NSZ_CCLIEN)
		oModel:SetValue("NUTDETAIL", 'NUT_CLOJA' ,NSZ->NSZ_LCLIEN)
		oModel:SetValue("NUTDETAIL", 'NUT_CCASO' ,NSZ->NSZ_NUMCAS)
	ElseIf IsInCallStack('JA096REPLI')//Rotina de replicação de contrato
		aArea := GetArea()
		JA096SGNT0(NT0->NT0_COD, oModel)
		RestArea(aArea)
	EndIf
EndIf

Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} JA096REPLI
Botão para replicar as informações do contrato

@author Juliana Iwayama Velho
@since 24/06/10
@version 1.0
/*/
//-------------------------------------------------------------------
Function JA096REPLI()
Local aArea  := GetArea()

If ApMsgYesNo(STR0078)
	FWExecView(STR0003, 'JURA096', 3,, {||.T.})
EndIf

RestArea(aArea)

Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} JA096SGNT0(cContr, oModel)
Rotina para sugerir as informações do contrato selecionado para a
replicação

@param  oModel  Model a ser verificado
@param  cContr  Código do contrato

@author Luciano Pereira dos Santos
@since 24/05/18
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function JA096SGNT0(cContr, oModel)
Local aArea      := GetArea()
Local aAreaNT0   := NT0->(GetArea())
Local aAreaNXP   := NXP->(GetArea())
Local aAreaNVN   := NVN->(GetArea())
Local aAreaNT5   := NT5->(GetArea())
Local aAreaNTK   := NTK->(GetArea())
Local aAreaNTJ   := NTJ->(GetArea())
Local oModelNT0  := oModel:GetModel('NT0MASTER')
Local oModelNXP  := oModel:GetModel('NXPDETAIL')
Local oModelNVN  := oModel:GetModel('NVNDETAIL')
Local oModelNT5  := oModel:GetModel('NT5DETAIL')
Local oModelNTK  := oModel:GetModel('NTKDETAIL')
Local oModelNTJ  := oModel:GetModel('NTJDETAIL')
Local aNT0       := {}
Local aNXP       := {}
Local aNVN       := {}
Local aNT5       := {}
Local aNTK       := {}
Local aNTJ       := {}
Local nI         := 0
Local nY         := 0
Local aStruct    := {}
Local aStruct2   := {}
Local aLinha     := {}
Local nTamCOD    := TamSX3('NVN_COD')[1]

aStruct := J096RmvRelat('NT0', oModelNT0, {'NT0_FILIAL', 'NT0_COD'}) //Remove os campos do SetRelation e adicionais que não devem ser preenchidos
NT0->(DbSetOrder(1))
If NT0->( DbSeek( xFilial('NT0') + cContr ) )
	J096GetLin('NT0', aStruct, @aNT0, .F.)
EndIf

aStruct2 := J096RmvRelat('NXP', oModelNXP) //Remove os campos do SetRelation e adicionais que não devem ser preenchidos
aStruct  := J096RmvRelat('NVN', oModelNVN) //Remove os campos do SetRelation e adicionais que não devem ser preenchidos
NVN->(DbSetOrder(5)) //NVN_FILIAL+NVN_CCONTR+NVN_CLIPG+NVN_LOJPG
NXP->(DbSetOrder(2)) //NXP_FILIAL+NXP_CCONTR+NXP_CLIPG+NXP_LOJAPG
If NXP->(DbSeek( xFilial('NXP') + cContr))
	While !NXP->(Eof()) .And. (xFilial('NXP') + NXP->NXP_CCONTR == xFilial('NXP') + cContr)

		If NVN->(DbSeek( xFilial('NVN') + NXP->NXP_CCONTR + NXP->NXP_CLIPG + NXP->NXP_LOJAPG))
			nY := 1
			While !NVN->(Eof()) .And. (xFilial('NVN') + NVN->NVN_CCONTR + NVN->NVN_CLIPG + NVN->NVN_LOJPG == xFilial('NVN') + NXP->NXP_CCONTR + NXP->NXP_CLIPG + NXP->NXP_LOJAPG)
				J096GetLin('NVN', aStruct, @aNVN, .T., {{'NVN_COD', StrZero(nY, nTamCOD)}}) //O campo NVN_COD é incrementado via view
				nY++
				NVN->(DbSkip())
			EndDo
		EndIf

		J096GetLin('NXP', aStruct2, @aLinha, .F.)
		Aadd(aNXP, {aLinha, aNVN})
		aLinha := {}
		aNVN   := {}

		NXP->(DbSkip())
	EndDo
EndIf

aStruct := J096RmvRelat('NT5', oModelNT5, {'NT5_COD'}) //Remove os campos do SetRelation e adicionais que não devem ser preenchidos
NT5->(DbSetOrder(2)) //NT5_FILIAL + NT5_CCONTR
If NT5->(DbSeek(xFilial('NT5') + cContr))
	While !NT5->(Eof()) .And. (xFilial('NT5') + NT5->NT5_CCONTR == xFilial('NT5') + cContr)
		J096GetLin('NT5', aStruct, @aNT5)
		NT5->(DbSkip())
	EndDo
EndIf

aStruct := J096RmvRelat('NTK', oModelNTK) //Remove os campos do SetRelation e adicionais que não devem ser preenchidos
NTK->(DbSetOrder(1)) //NTK_FILIAL + NTK_CCONTR + NTK_CTPDSP
If NTK->(DbSeek( xFilial('NTK') + cContr))
	While !NTK->(Eof()) .And. xFilial('NTK') + NTK->NTK_CCONTR == xFilial('NTK') + cContr
		J096GetLin('NTK', aStruct, @aNTK)
		NTK->(DbSkip())
	EndDo
EndIf

aStruct := J096RmvRelat('NTJ', oModelNTJ) //Remove os campos do SetRelation e adicionais que não devem ser preenchidos
NTJ->(DbSetOrder(1)) //NTJ_FILIAL + NTJ_CCONTR + NTJ_CTPATV
If NTJ->( dbSeek( xFilial('NTJ') + cContr ) )
	While !NTJ->(Eof()) .And. xFilial('NTJ') + NTJ->NTJ_CCONTR == xFilial('NTJ') + cContr
		J096GetLin('NTJ', aStruct, @aNTJ)
		NTJ->(DbSkip())
	EndDo
EndIf

If lRet := J096GrvMdl(@oModelNT0, aNT0) //grava o cabeçalho
	For nI := 1 To Len(aNXP)
		If lRet := J096GrvMdl(@oModelNXP, aNXP[nI][1]) //grava a linha do grid do pagador
			lRet := J096GrvGrid(@oModelNVN, aNXP[nI][2]) //grava as linhas do grid dos contatos de encaminhamento de fatura
		EndIf
		If lRet
			Iif(nI < Len(aNXP), oModelNXP:AddLine(), Nil)
		Else
			Exit
		EndIf
	Next nI
EndIf

lRet := lRet .And. J096GrvGrid(@oModelNT5, aNT5)
lRet := lRet .And. J096GrvGrid(@oModelNTK, aNTK)
lRet := lRet .And. J096GrvGrid(@oModelNTJ, aNTJ)

RestArea( aAreaNT0 )
RestArea( aAreaNXP )
RestArea( aAreaNVN )
RestArea( aAreaNT5 )
RestArea( aAreaNTK )
RestArea( aAreaNTJ )
RestArea(aArea)

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} J096RmvRelat(cTable, oModel)
Rotina para remover os campos de relacionamento de modelo da estrutura da tabela

@Param  cTable   Nome da Tabela Ex: NXP
@Param  oModel   Parte do modelo pertecente a tabela Ex: oModelNXP
@Param  aCampos  Array com campos adicionais para serem removidos Ex: ['NXP_CLIPG','NXP_LOJAPG']

@Return aRet     Array da estrutura da tabela com os campos removidos

@author Luciano Pereira dos Santos
@since 23/05/18
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function J096RmvRelat(cTable, oModel, aCampos)
Local aRet      := {}
Local aStruct   := (cTable)->(DbStruct())
Local aRelation := oModel:GetRelation()[1]
Local nI        := 0

Default aCampos := {}

For nI := 1 to Len(aStruct)
	If (Ascan(aRelation, {|aX| aX[1] == aStruct[nI][1]}) == 0) .And.;
		(Ascan(aCampos, {|aY| aY == aStruct[nI][1]}) == 0)
		aAdd(aRet, aStruct[nI])
	EndIf
Next nI

Return aRet

//-------------------------------------------------------------------
/*/{Protheus.doc} J096GrvGrid(oModel, aData, lShowErro)
Rotina para gravar um grid de dados

@Param  oModel           Objeto do Modelo
@Param  aData[n]         Linha do Array multidimencional contendo contentdo os dados a serem gravados
         aData[n][n][1]  Nome do campo da linha
         aData[n][n][2]  Inf a ser gravada no campo

@Return lRet

@author Luciano Pereira dos Santos
@since 23/05/18
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function J096GrvGrid(oModel, aData, lShowErro)
Local lRet   := .T.
Local nLinha := 0

Default lShowErro := .T.

For nLinha := 1 To Len(aData)
	aLinha := aData[nLinha]
	If !J096GrvMdl(oModel, aLinha, lShowErro)
		Exit
	Else
		IIf(nLinha < Len(aData), oModel:AddLine(), Nil)
	EndIf
Next nLinha

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} J096GrvMdl(oModel, aData, lShowErro)
Rotina para gravar um grid de dados

@Param  oModel        Objeto do Modelo
@Param  aData         Array multidimencional contendo contentdo os dados a serem gravados
         aData[n][1]  Nome do campo do modelo
         aData[n][2]  Inf a ser gravada no campo do modelo

@Return lRet

@author Luciano Pereira dos Santos
@since 23/05/18
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function J096GrvMdl(oModel, aData, lShowErro)
Local lRet    := .T.
Local nCampo  := 0

Default lShowErro := .T.

For nCampo := 1 To Len(aData)
	If oModel:CanSetValue(aData[nCampo][1])
		If !(lRet := oModel:SetValue(aData[nCampo][1], aData[nCampo][2])) .And. lShowErro
			JurMsgErro(STR0079 + aData[nCampo][1] + STR0101 + AllToChar(aData[nCampo][2]))
			Exit
		EndIf
	EndIf
Next nCampo

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} J096GetLin(cTable, aStruct, aData, lGrid, aCampos)
Recupera dos dados de um registro posisiconado conforme os campos da estrutura

@Param  cTable           Nome da Tabela posicionada Ex: 'NXP'
@Param  aStruct          Array com a estrutura dos campos da tabela
         aStruct[n][1]   Campo da estrutura (Obrigatorio)
@Param  aData[*]         Linha do Array multidimencional contendo contentdo os dados a serem gravados
         aData[*][n][1]  Nome do campo da linha
         aData[*][n][2]  Informação a ser gravada no campo

@Param  lGrid            Se .T. altera da dimensão do array para linhas, permitindo passar aData por referência

@Param  aCampos[n]      Array de campos da estrutura para gravar com conteudo diferenciado do registro
         aCampos[n][1]  Nome do campo
         aCampos[n][2]  Informação diferenciada

@Return aData

@Obs *Se lGrid for .T.  o array aData pode ser passado por referencia acumulando varias linhas de registros

@author Luciano Pereira dos Santos
@since 23/05/18
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function J096GetLin(cTable, aStruct, aData, lGrid, aCampos)
Local nCampo    := 0
Local aLinha    := {}
Local xValor    := Nil

Default aData   := {}
Default aCampos := {}
Default lGrid   := .T.

For nCampo := 1 to Len(aStruct)

	If (nPos := Ascan(aCampos, {|aY| aY[1] == aStruct[nCampo][1]})) == 0
		xValor := (cTable)->(FieldGet(FieldPos(aStruct[nCampo][1])))
	Else
		xValor := aCampos[nPos][2]
	EndIf

	aAdd(aLinha, {aStruct[nCampo][1], xValor})
Next nCampo

If lGrid
	Aadd(aData, aLinha)
Else
	aData := aLinha
EndIf

Return aData

//-------------------------------------------------------------------
/*/{Protheus.doc} J096QTDE
Rotina para retornar a qtde ou os registros de Tipo de Despesas ou
Tipo de Atividades não cobráveis do cliente/loja do contrato

@Param 	cTabela  	Tabela que será feita a query (NUB / NUC)
@Param  cTipo     Tipo de Retorno (1 = Qtde / 2 = tipos não cobráveis
                  cadastrados no cliente)
@Param  cCliente  Cliente do contrato
@Param  cLoja     Loja do contrato
@Return aRet      Retorna um Array com a qtde ou com os tipos
                  cadastrados no cliente (dependendo do parametro cTipo)

@author Jacques Alves Xavier
@since 13/08/10
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function J096QTDE(cTabela, cTipo, cCliente, cLoja)
Local aArea   := GetArea()
Local cAlias  := GetNextAlias()
Local cQuery  := ''
Local aRet    := {}

If cTabela = 'NUB'
	// Tipo de Atividade não cobravel no cliente
	If cTipo == '1'
		cQuery := "SELECT COUNT(NUB.R_E_C_N_O_) QTDE " + CRLF
	Else
		cQuery := "SELECT NUB.NUB_CTPATI CODIGO" + CRLF
	EndIf
	cQuery += "  FROM " + RetSqlName('NUB') + " NUB " + CRLF
	cQuery += " WHERE NUB.NUB_FILIAL = '" + xFilial('NUB') + "' " + CRLF
	cQuery += "   AND NUB.D_E_L_E_T_ = ' ' " + CRLF
	cQuery += "   AND NUB.NUB_CCLIEN = '" + cCliente + "' " + CRLF
	cQuery += "   AND NUB.NUB_CLOJA = '" + cLoja + "' "

Else
	// Tipo de despesa não cobravel no cliente
	If cTipo == '1'
		cQuery := "SELECT COUNT(NUC.R_E_C_N_O_) QTDE " + CRLF
	Else
		cQuery := "SELECT NUC.NUC_CTPDES CODIGO" + CRLF
	EndIf
	cQuery += "  FROM " + RetSqlName('NUC') + " NUC " + CRLF
	cQuery += " WHERE NUC.NUC_FILIAL = '" + xFilial('NUC') + "' " + CRLF
	cQuery += "   AND NUC.D_E_L_E_T_ = ' ' " + CRLF
	cQuery += "   AND NUC.NUC_CCLIEN = '" + cCliente + "' " + CRLF
	cQuery += "   AND NUC.NUC_CLOJA = '" + cLoja + "' "

EndIf

dbUseArea(.T., 'TOPCONN', TcGenQry(,, cQuery), cAlias, .T., .T. )

If cTipo == '1'
	aadd(aRet, (cAlias)->QTDE)
Else
	While !(cAlias)->( Eof() )
		aadd(aRet, (cAlias)->CODIGO )
		(cAlias)->( dbSkip() )
	EndDo
EndIf

(cAlias)->( dbCloseArea() )

RestArea( aArea )

Return( aRet )

//-------------------------------------------------------------------
/*/{Protheus.doc} J096SUGVIC
Sugere as informações de cliente no casos vinculados

@author Clóvis Eduardo Teixeira
@since 18/10/2010
@version 1.0
/*/
//-------------------------------------------------------------------
Function J096SUGVIC()
Local oModel     := FwModelActive()
Local oModelGrid := oModel:GetModel("NUTDETAIL" )
Local cClien     := oModel:GetValue("NT0MASTER", "NT0_CCLIEN")
Local cLoja      := oModel:GetValue("NT0MASTER", "NT0_CLOJA")
Local nOpc       := oModel:GetOperation()
Local lRet       := .T.

//Preenchimento dos campos cliente e loja da tabela NUT
If nOpc == 3 .And. !Empty(cClien) .And. !Empty(cLoja) .And. ( oModelGrid:IsEmpty() .Or. Empty(oModel:GetValue("NUTDETAIL", "NUT_CCASO")) ) ;
   .And. !IsInCallStack("JURA070")
	lRet := oModel:SetValue( "NUTDETAIL", "NUT_CCLIEN", cClien)
	lRet := oModel:SetValue( "NUTDETAIL", "NUT_CLOJA", cLoja)
EndIf

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} JA96DPART1
Nome do Revisor na Aba de Caso

@param nTipo , Tipo de execução (1=Inicializador Padrão;2=Gatilho)
@param cCampo, Campo de origem da informação

@return cRet , Valor que será preenchido no campo virtual

@author Clóvis Eduardo Teixeira
@since 18/10/2010
@version 1.0
/*/
//-------------------------------------------------------------------
Function JA96DPART1(nTipo, cCampo)
Local cChave   := ""
Local cRet     := ""
Local cValor   := ""

Default nTipo  := 1
Default cCampo := "RD0_NOME"

	If nTipo == 1
		If Empty(M->NT0_COD) .Or. M->NT0_COD == NUT->NUT_CCONTR
			cChave := xFilial("NVE") + NUT->(NUT_CCLIEN + NUT_CLOJA + NUT_CCASO)

			If !Empty(cChave)
				If NVE->NVE_FILIAL + NVE->NVE_CCLIEN + NVE->NVE_LCLIEN + NVE->NVE_NUMCAS == cChave
					cValor := NVE->NVE_CPART1
				Else
					cValor := Posicione("NVE", 1, cChave, "NVE_CPART1")
				EndIf
			EndIf
		EndIf
	
	ElseIf nTipo == 2
		cChave := xFilial("NVE") + FwFldGet('NUT_CCLIEN') + FwFldGet('NUT_CLOJA') + FwFldGet('NUT_CCASO')
	
		If !Empty(cChave)
			If NVE->NVE_FILIAL + NVE->NVE_CCLIEN + NVE->NVE_LCLIEN + NVE->NVE_NUMCAS == cChave
				cValor := NVE->NVE_CPART1
			Else
				cValor := Posicione("NVE", 1, cChave, "NVE_CPART1")
			EndIf
		EndIf
	EndIf
	
	If !Empty(cValor)
		cRet := Posicione("RD0", 1, xFilial("RD0") + cValor, cCampo)
	EndIf

Return cRet

//-------------------------------------------------------------------
/*/{Protheus.doc} JA96VALCON
Validação do contato por cliente/loja pagador

@author Clóvis Eduardo Teixeira
@since 18/10/2010
@version 1.0
/*/
//-------------------------------------------------------------------
Function JA96VALCON()
Return JURCONTOK('SA1', FwFldGet("NXP_CCONT"), xFilial("SA1") + FwFldGet("NXP_CLIPG") + FwFldGet("NXP_LOJAPG"), "SU5->U5_ATIVO == '1'")

//-------------------------------------------------------------------
/*/{Protheus.doc} J96WOFixo
Função para efetuar WO na parcela de Fixo

@param oView      , Visão de dados dos Contratos
@Param aObs       , Array com a Observação e Código do Motivo de WO
           aObs[1] - Observação com motivo do WO
           aObs[2] - Código do WO
@param aInfoApi   , Array com informações vindas do Smart UI
       aInfoApi[1] - Código do Contrato
       aInfoApi[2] - Código Seq da Parcela
       aInfoApi[3] - Situação da parcela
       aInfoApi[4] - Código da Pré-fatura
@param cMsgErro   , Mensagem de erro retornada para o SmartUI
@param cMsgSolucao, Mensagem de solução retornada para o SmartUI

@author Jacques Alves Xavier
@since 16/11/2010
@version 1.0
/*/
//-------------------------------------------------------------------
Function J96WOFixo(oView, aObs, aInfoApi, aNovaNT1, lSmartUI, lWoValido)
Local aArea     := GetArea()
Local aAreaWO   := NT1->( GetArea() )
Local oModel    := Nil
Local oModelNT1 := Nil
Local ncountWO  := 0
Local nI        := 0
Local nOpc      := 0
Local cContrato := ''
Local cParcela  := ''
Local cPrefat   := ''
Local cSituac   := ''
Local cWoCodig  := ''
Local aParcela  := {}
Local aQtde     := {}
Local cSQL      := ''
Local lTela     := .T.
Local lRet      := .T.
local lIsJ202   := IsJura202()

Default aObs      := {}
Default aInfoApi  := {}
Default aNovaNT1  := {}
Default lSmartUI  :=  .F.
Default lWoValido :=  .F.

If Len(aInfoApi) > 0
	cContrato  := aInfoApi[1]
	cParcela   := aInfoApi[2]
	cSituac    := aInfoApi[3]
	cPrefat    := aInfoApi[4]
Else
	oModel     := oView:GetModel()
	oModelNT1  := oModel:GetModel('NT1DETAIL')
	nOpc       := oModel:GetOperation()
	cContrato  := FwFldGet('NT1_CCONTR')
	cParcela   := FwFldGet('NT1_SEQUEN')
	cPrefat    := FwFldGet('NT1_CPREFT')
	cSituac    := FwFldGet('NT1_SITUAC')
EndIf


If nOpc == 4  .Or. lSmartUI

	If !lSmartUI .And. oModelNT1:IsEmpty()
		ApMsgStop(STR0194) // "Não existem dados para realização do WO."
		lRet := .F.
	EndIf

	If lRet .And. !lSmartUI .And. oModel:lModify .And. !lIsJ202 .And. Empty(aObs)
		If ApMsgYesNo(STR0175, STR0150) //# "Ao realizar esta operação o sistema salvará todas as alterações feitas na tela!" ## "ATENÇÃO"
			If lRet := oModel:VldData()
				lRet := FWFormCommit(oModel)
			Else
				JurShowErro( oModel:GetModel():GetErrormessage() )
			EndIf
		Else
			lRet := .F.
		EndIf
	EndIf

	If lRet

		If cSituac == '1'

			cSQL := "SELECT COUNT(NUT.R_E_C_N_O_) QTDE "
			cSQL +=  " FROM " + RetSqlName('NUT') + " NUT "
			cSQL +=  " WHERE NUT.NUT_FILIAL = '" + xFilial('NUT') + "' "
			cSQL +=   " AND NUT.D_E_L_E_T_ = ' ' "
			cSQL +=   " AND NUT.NUT_CCONTR = '" + cContrato + "' "

			aQtde := JurSQL(cSQL, "QTDE")

			If aQtde[1][1] > 0

				BEGIN TRANSACTION

					cSQL := "SELECT DISTINCT NUT.NUT_CCLIEN CLIENTE, NUT_CLOJA LOJA, NUT_CCASO CASO, NT0.NT0_CMOEF MOEDA, NT1.NT1_VALORA / " + alltrim(str(aQtde[1][1])) + " VAL_PARC "
					cSQL +=  " FROM " + RetSqlName('NT1') + " NT1 INNER JOIN " + RetSqlName('NUT') + " NUT "
					cSQL +=                                     " ON NT1.NT1_FILIAL = NUT.NUT_FILIAL AND NT1.NT1_CCONTR = NUT.NUT_CCONTR "
					cSQL +=                                     " INNER JOIN " + RetSqlName('NT0') + " NT0 "
					cSQL +=                                     " ON NT1.NT1_FILIAL = NT0.NT0_FILIAL AND NT1.NT1_CCONTR = NT0.NT0_COD "
					cSQL += " WHERE NT1.NT1_FILIAL = '" + xFilial('NT1') + "' "
					cSQL +=    " AND NT1.D_E_L_E_T_ = ' ' "
					cSQL +=    " AND NUT.D_E_L_E_T_ = ' ' "
					cSQL +=    " AND NT0.D_E_L_E_T_ = ' ' "
					cSQL +=    " AND NT1.NT1_CCONTR = '" + cContrato + "' "
					cSQL +=    " AND NT1.NT1_SEQUEN = '" + cParcela + "' "

					aParcela := JurSQL(cSQL, {"CLIENTE", "LOJA", "CASO", "MOEDA", "VAL_PARC"})

					If lTela := Empty(aObs)
						aObs := JurMotWO('NUF_OBSEMI', STR0135, STR0136, "5") // "WO - Parcela de Fixo" - "Observação - WO"
					EndIf

					If !Empty(aObs)

						cWoCodig := JAWOInclui(aObs)

						lRet := J96WOLanc(cPrefat, cParcela, cWoCodig, lTela, cContrato, lSmartUI, lWoValido) //Faz os ajustes de WO na parcela

						If lRet
							For nI := 1 To Len(aParcela)
								JAWOCasInc(cWoCodig, aParcela[nI][1], aParcela[nI][2], aParcela[nI][3], aParcela[nI][4], 0)  // Não preencher o valor do campo valor (NUG_VALOR) na tabela NUG.
							Next
						EndIf

						J203NParc(cContrato, Nil, Nil, @aNovaNT1, lSmartUI) //Cria uma nova parcela conforme o tipo de honorário e condições do contrato.

						ncountWO := 1

						If lTela
							If lRet  // Esta mensagem só pode ser exibida se o WO for efetivado.
								ApMsgInfo(STR0110) // "WO realizado com sucesso!"
							EndIf
						EndIf

					EndIf

					If lRet
						While GetSX8Len()>0
							ConfirmSX8()
						EndDo
					Else
						While GetSx8Len() > 0
							RollBackSX8()
						EndDo
						DisarmTransaction()
					EndIf

				END TRANSACTION

			Else
				If !IsInCallStack("JURA070")
					ApMsgStop(STR0108) // "É obrigatório vincular pelo menos um caso "
				EndIf
			EndIf
		Else
			ApMsgStop(STR0109) // "Só será possível efetuar WO em parcelas pendentes."
		EndIf

		If !lIsJ202
			IIf(!lSmartUI, oModel:Deactivate(), Nil)
			NT0->( DbSetOrder(1) ) // recolocado pois estava deposicionando no commit da alteração
			NT0->( DbSeek( xFilial('NT0') + cContrato ) )
			aArea := GetArea()
			IIf(!lSmartUI, oModel:Activate(), Nil)
		EndIf

	EndIf

EndIf

RestArea( aAreaWO )
RestArea( aArea )

Return ncountWO

//-------------------------------------------------------------------
/*/{Protheus.doc} J96WOLanc
Efetua as alterações WO na parcela de Fixo

@param cParcela   Parcela de fixo
@param cPrefat    Número da Pré-fatura
@param cWoCodig   Código do WO
@param lTela      Exibir mensagens na tela (.T./.F.)
@param cContrato  Código do Contrato
@param lSmartUI   Se está vindo do Smart UI 
@param lWoValido  Se o usuário via Smart UI optou por manter o WO na parcela
@param cMsgErro   Mensagem que será envia para a tela via Smart UI 
@param cImpedeWO  Retorna um "false/true" para o Smart UI impeditivo para WO

@Return lRet

@author Luciano Pereira dos Santos
@since 14/03/2014
@version 1.0
/*/
//-------------------------------------------------------------------
Function J96WOLanc(cPrefat, cParcela, cWoCodig, lTela, cContrato, lSmartUI, lWoValido, cMsgErro, cImpedeWO)
Local lRet        := .T.
Local aArea       := GetArea()
Local aAreaNT1    := NT1->(GetArea())
Local aAreaNX0    := NX0->(GetArea())
local lIsJ202     := IsJura202()
Local lHaMaisLanc := .F.
Local lJVINCTS    := GetMV("MV_JVINCTS",, .F.)
Local cClien      := ""
Local cLoja       := ""
Local dDataIni
Local dDataFim
Local aOrd        := SaveOrd({"NRA", "NX0", "NX1", "NT0", "NT1", "NUE"})
Local aIncLanc    := {}
Local cNx0SitAnt  := ''
Local cPartLog    := JurUsuario(__CUSERID)
Local lAltHr      := NUE->(ColumnPos('NUE_ALTHR')) > 0
Local cTpLanc     := STR0246 // "Parcela fixa"

Default lSmartUI  := .F.
Default lWoValido := .F.
Default cWoValido := ""
Default cMsgErro  := ""

If !Empty(cPrefat)
	If NX0->(dbSeek(xFilial('NX0') + cPreFat) )
		If NX0->NX0_SITUAC $ '2|3'  //Pré-Fatura alterável
			NT0->(DbSetOrder(1))
			NT0->(DbSeek(xFilial('NT0') + cContrato))
			cClien := NT0->NT0_CCLIEN
			cLoja  := NT0->NT0_CLOJA

			NRA->(DbSetOrder(1))
			NRA->(DbSeek(xFilial("NRA") + NT0->NT0_CTPHON))
			If NRA->NRA_COBRAF = "1" .And. NRA->NRA_COBRAH == "2"
				lHaMaisLanc := (JurLancPre(cPrefat, .F.) > 0)
			ElseIf NRA->NRA_COBRAF = "1" .And. NRA->NRA_COBRAH == "1"
				lHaMaisLanc := (JurLancPre(cPrefat, .T.) > 0)
			EndIf

			If lHaMaisLanc
				If !lWoValido .And. lSmartUI
					cMsgErro := (STR0180 + AllTrim(cParcela) + STR0181 + AllTrim(cPrefat) + STR0182 + AllTrim(JurSitGet(NX0->NX0_SITUAC)) + STR0187)
				Endif
				If lWoValido .Or. (!lSmartUI .And. ApMsgYesNo(STR0180 + AllTrim(cParcela) + STR0181 + AllTrim(cPrefat) + STR0182 + AllTrim(JurSitGet(NX0->NX0_SITUAC)) + STR0187)) // "A parcela '" ### "' está vinculada a pré-fatura '" ### "' com a situação '" ### "', a situação da pré-fatura ficará como alterada! Deseja continuar?”
					cNx0SitAnt := NX0->NX0_SITUAC
					RecLock("NX0", .F.)
					NX0->NX0_SITUAC := '3'
					NX0->NX0_USRALT := JurUsuario(__CUSERID)
					NX0->NX0_DTALT  := date()
					NX0->(MsUnlock())
					NX0->(DbCommit())

					If cNx0SitAnt != '3'
						J202HIST('99', NX0->NX0_COD, cPartLog, I18N(STR0227, {cParcela, cContrato})) // "Efetuado WO da parcela '#1' no contrato '#2'."
					EndIf
					
					If lJVINCTS
						aIncLanc := {}
						NT1->( dbSetOrder( 1 ) ) //NT1_FILIAL+NT1_SEQUEN
						If NT1->( dbSeek( xFilial('NT1') + cParcela ) )
							dDataIni := NT1->NT1_DATAIN
							dDataFim := NT1->NT1_DATAFI
							Aadd(aIncLanc, NT1->NT1_CMOEDA)
							NT1->(RecLock('NT1', .F.))
							NT1->NT1_SITUAC := "2"
							NT1->NT1_CPREFT := ""
							NT1->(MsUnLock())
							NT1->(DbCommit())
							//Grava na fila de sincronização a alteração
							J170GRAVA("NT0", xFilial("NT0") + NT1->NT1_CCONTR, "4")
						EndIf

						NX1->(DbSetOrder(3)) // NX1_FILIAL+NX1_CPREFT+NX1_CCONTR+NX1_CCLIEN+NX1_CLOJA+NX1_CCASO
						NX1->(DbSeek(xFilial("NX1") + cPrefat + cContrato + cClien + cLoja))

						NUE->(DbSetOrder(2)) // NUE_FILIAL+NUE_CCLIEN+NUE_CLOJA+NUE_CCASO+NUE_CPREFT
						NUE->(DbSeek(xFilial("NUE") + NX1->(NX1_CCLIEN + NX1_CLOJA + NX1_CCASO )))
						Do While ! NUE->(Eof()) .And. NUE->(NUE_FILIAL + NUE_CCLIEN + NUE_CLOJA + NUE_CCASO) == xFilial("NUE") + NX1->(NX1_CCLIEN + NX1_CLOJA + NX1_CCASO )
							If dDataIni >= NUE->NUE_DATATS .And. dDataFim >= NUE->NUE_DATATS
								NUE->(RecLock('NUE', .F.))
								NUE->NUE_CPREFT := ""
								NUE->NUE_CUSERA := JurUsuario(__CUSERID)
								NUE->NUE_ALTDT  := Date()
								If lAltHr
									NUE->NUE_ALTHR  := Time()
								EndIf
								NUE->(MsUnLock())
								NUE->(DbCommit())
								//Grava na fila de sincronização a alteração
								J170GRAVA("NUE", xFilial("NUE") + NUE->NUE_COD, "4")
							EndIf

							NUE->(DbSkip())
						EndDo

						JACanVinc("FX", cPrefat, cParcela ) // Cancela o vínculo da parcela com a pré-fatura
						JACanVinc("TS", cPrefat, cParcela ) // Cancela o vínculo da parcela com TimeSheet

						JAUSALANC('NT1', cParcela, '3', cWoCodig, __CUSERID, aIncLanc) // Cria o histórico de WO de Fixo
					EndIf
					lRet := .T.
				Else
					lRet := .F.
				EndIf
			Else
				If !lWoValido .And. lSmartUI
					cMsgErro := (STR0180 + AllTrim(cParcela) + STR0181 + AllTrim(cPrefat) + STR0182 + AllTrim(JurSitGet(NX0->NX0_SITUAC)) + STR0188)
				EndIf
				If lWoValido .Or. (!lSmartUI .And.  ApMsgYesNo(STR0180 + AllTrim(cParcela) + STR0181 + AllTrim(cPrefat) + STR0182 + AllTrim(JurSitGet(NX0->NX0_SITUAC)) + STR0188)) // "A parcela '" ### "' está vinculada a pré-fatura '" ### "' com a situação '" ### "', a situação da pré-fatura ficará como alterada! Deseja continuar?”
					aIncLanc := {}
					NT1->( dbSetOrder( 1 ) ) //NT1_FILIAL+NT1_SEQUEN
					If NT1->( dbseek( xFilial('NT1') + cParcela ) )
						Aadd(aIncLanc, NT1->NT1_CMOEDA)
						RecLock('NT1', .F.)
						NT1->NT1_SITUAC := "2"
						NT1->NT1_CPREFT := ""
						NT1->(MsUnLock())
						NT1->(DbCommit())
						// Grava na fila de sincronização a alteração
						J170GRAVA("NT0", xFilial("NT0") + NT1->NT1_CCONTR, "4")
					EndIf

					If JA202CANPF(cPrefat)
						J202HIST('5', cPrefat, JurUsuario(__CUSERID)) // Insere o Histórico na pré-fatura
					EndIf

					If lTela
						ApMsgStop( I18N(STR0178, {cPrefat}) ) // # "A pré-fatura #1 foi cancelada por não conter mais lançamentos."
					EndIf

					JACanVinc("FX", cPrefat, cParcela ) // Cancela o vínculo da parcela com a pré-fatura

					JAUSALANC('NT1', cParcela, '3', cWoCodig, __CUSERID, aIncLanc) // Cria o histórico de WO de Fixo
					lRet := .T.
				Else
					lRet := .F.
				EndIf
			EndIf
			
			If lRet
				// Cancela as minutas da pré-fatura
				J202CanMin(cPrefat, I18N(STR0247, {cTpLanc} )) //#"Inclusão de WO - #1. "
			EndIf

		ElseIf NX0->NX0_SITUAC $ '4|5|6|7|9|A|B' //Emitir Minuta | Minuta Emitida | Minuta Cancelada | Minuta Sócio | Minuta Sócio Emitida | Minuta Sócio Cancelada

			If !lWoValido .And. lSmartUI
				cMsgErro  := I18N(STR0177 + CRLF, {cParcela, cPrefat, JurSitGet(NX0->NX0_SITUAC)})
				cImpedeWO := "false"
			Else
				If !lSmartUI .And. lTela
					ApMsgStop( I18N(STR0177 + CRLF, {cParcela, cPrefat, JurSitGet(NX0->NX0_SITUAC)}) ) //# "A parcela '#1' está vinculada a pré-fatura '#2' com a situação '#3' e não poderá realizar o WO!
				EndIf
			EndIf

			lRet := .F.

		EndIf
	EndIf
ElseIf !lIsJ202
	aIncLanc := {}

	If !Empty(cWoCodig)
		NT1->( dbSetOrder( 1 ) ) //NT1_FILIAL+NT1_SEQUEN
		If NT1->( dbseek( xFilial('NT1') + cParcela ) )
			Aadd(aIncLanc, NT1->NT1_CMOEDA)
			RecLock('NT1', .F.)
			NT1->NT1_SITUAC := "2"
			NT1->NT1_CPREFT := ""
			NT1->(MsUnLock())
			NT1->(DbCommit())
			// Grava na fila de sincronização a alteração
			J170GRAVA("NT0", xFilial("NT0") + NT1->NT1_CCONTR, "4")
		EndIf

		lRet := JAUSALANC('NT1', cParcela, '3', cWoCodig, __CUSERID, aIncLanc) //cria o histórico de WO de Fixo
	EndIf

EndIf

RestArea(aAreaNT1)
RestArea(aAreaNX0)
RestArea(aArea)
RestOrd(aOrd)

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} JA096SDLIM
Retorna o saldo disponivel do valor limite

@Return nSaldo

@author Jacques Alves Xavier
@since 03/03/2011
@version 1.0
/*/
//-------------------------------------------------------------------
Function JA096SDLIM()
Local aArea    := GetArea()
Local nSaldo   := 0

	If !Empty(FwFldGet('NT0_CMOELI')) .And. !Empty(FwFldGet('NT0_VLRLI'))
		nSaldo := J201GSldLm(FwFldGet('NT0_COD'), '2', , .T.)
	EndIf

RestArea(aArea)

Return nSaldo

//-------------------------------------------------------------------
/*/{Protheus.doc} J096ValDiv
Função utilizada para validar o valor informado do campo NT0_VALDIV

@Return lRet	 	.T./.F. As informações são válidas ou não

@author Paulo Borges
@since 23-03-11
@version 1.0
/*/
//-------------------------------------------------------------------
Function J096ValDiv()
Local lRet  := .T.

If FwFldGet("NXP_PERCEN") > 100
	lRet := JurMsgErro(STR0111) // "O valor de percentual não pode ser maior que 100%"
EndIf

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} J096GerNT1
Permite ou nao a inclusao de nova parcela na NT1 sob certas condicoes

@Return lRet	 	.T. -> Permite   -  .F. -> Nao permite

@author Ricardo Camargo
@since 25-04-11
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function J096GerNT1( cCodHon, cNT0Parce, cEncCobH )
Local lRet  := .T.
Local aArea := GetArea()

// Verifica se foi encerrado a cobranca de honorarios no contrato
If cEncCobH == "1"

	// Verifica se tipo de honorarios e fixo
	If JUR96TPFIX( cCodHon )

		// Verifica se Gera parcela automatica
		NRA->( dbSetOrder( 1 ) )
		If NRA->(dbSeek(xFilial('NRA')+cCodHon)) .And. NRA->NRA_PARCAT == '1'
			// Verifica a config. PARCELAR
			If cNT0Parce == "2"
				lRet := .F.
			EndIf
		EndIf

	EndIf

EndIf

RestArea( aArea )

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} JA096DePar
Funcao utilizada para retornar a descricao da parcela conforme o
idioma informado

@Return cRet

@author Daniel Magalhaes
@since 26/04/2011
@version 1.0
/*/
//-------------------------------------------------------------------
Function JA096DePar(cCodNXK, cIdioma)
Local aArea := GetArea()
Local cRet  := ""

Default cCodNXK := ""
Default cIdioma := ""

cRet := Alltrim(JurGetDados("NXL", 3, xFilial("NXL") + cCodNXK + cIdioma, "NXL_DESC"))

RestArea( aArea )

Return cRet

//-------------------------------------------------------------------
/*/{Protheus.doc} J096Active
Funcao executada na ativacao do modelo

@Return Nil

@sample oModel:SetActivate( {|oModel| J070Active(oModel)} )

@author Daniel Magalhaes
@since 12/08/2011
@version 1.0
/*/
//-------------------------------------------------------------------
Function J096Active( oModel )
Local lRet := .T.

Default oModel := FWModelActive()

JA096SGCAS( oModel )

J96GetCli( oModel )

J096CPYCnt( oModel ) //atualiza o conteudo do array _aCnt096

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} J96GetCli
Preenche os campos de Grupo de Clientes, Cod Cliente e Loja
quando chamado a partir da rotina JURA070 (Cad Contratos)

@Return Nil

@sample J96GetCli( oModel )

@author Daniel Magalhaes
@since 12/08/2011
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function J96GetCli( oModel )
Local oModelNT0  := Nil
Local nOperation := 0

Default oModel := FWModelActive()

nOperation := oModel:GetOperation()

If nOperation == OP_INCLUIR .Or. nOperation == OP_ALTERAR
	oModelNT0 := oModel:GetModel("NT0MASTER")
	
	If IsInCallStack("JURA070")
		If !Empty(_J70GrpCli)
			oModelNT0:SetValue("NT0_CGRPCL", _J70GrpCli)
		EndIf

		If !Empty(_J70CodCli) .And. !Empty(_J70LojCli)
			oModelNT0:SetValue("NT0_CCLIEN", _J70CodCli)
			oModelNT0:SetValue("NT0_CLOJA", _J70LojCli)
		EndIf
	EndIf

EndIf

Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} J96SetVar
Configura as variaveis estaticas passadas por parametro

@Return Nil

@sample J96SetVar("_J70GrpCli","000011")

@author Daniel Magalhaes
@since 12/08/2011
@version 1.0
/*/
//-------------------------------------------------------------------
Function J96SetVar(cNomVar,xValue)

&(cNomVar) := xValue

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} J096When
Configura o modo de edicao dos campos (X3_WHEN)

@Return Nil

@sample J096When("NT0_CGRPCL")

@author Daniel Magalhaes
@since 12/08/2011
@version 1.0
/*/
//-------------------------------------------------------------------
Function J096When( cCampo )
Local lRet := .T.

cCampo := AllTrim(cCampo)

Do Case
Case cCampo == "NT0_CGRPCL"
	lRet := !IsInCallStack("JURA070") .Or. IsInCallStack("J96GETCLI")
Case cCampo == "NT0_CCLIEN"
	lRet := !IsInCallStack("JURA070") .Or. IsInCallStack("J96GETCLI")
Case cCampo == "NT0_CLOJA"
	lRet := !IsInCallStack("JURA070") .Or. IsInCallStack("J96GETCLI")
Case cCampo == "NT0_DESPAD"
	lRet := J096CHon()
Otherwise
	lRet := .T.
EndCase

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} J096Parcela(oModel, nBotaoAtv)
Rotina para gerar parcela na Cond. Faturamento

@param nBotaoAtv = Referente ao campo NTH_BOTAO
                     1 = Condições de Faturamento de Fixo
                     2 = Faixa de Valores

@Return lRet

@obs Função chamada na Automação.

@author Tiago Martins
@since 22/09/2011
@version 1.0
/*/
//-------------------------------------------------------------------
Function J096Parcela(oModel, nBotaoAtv, aInfoApi, cMsgSmUi, aParcNT1)
Local lRet       := .T.
Local oModelNT1  := Nil
Local oModelNT0  := Nil
Local aSaveLn    := {}
Local lGeraParc  := .F.
Local lNewLine   := .F.
Local nI         := 0
Local nA         := 0
Local cCTPHON    := ''
Local nAt        := 0
Local cNT0Parce  := ''
Local cNT0Ench   := ''
Local nQtdLine   := 0
Local aCpoGrd    := {}
Local nNumParc   := 0
Local nParcMax   := 0
Local nNT0QtPar  := ''
Local nPerFix    := ''
Local cDescPar   := ''
Local lFimDtRef  := .T. //Controle do while na geração de parcelas
Local dDataIni   := CToD(' / / ') //Data de referencia inicial para geração de parcelas
Local dDataFim   := CToD(' / / ') //Data de referencia final para geração de parcelas
Local dDataVenc  := CToD(' / / ') //Data de vencimento das parcelas
Local lDt        := .T.
Local lDesc      := .F. //Verifica se há desconto para os tipos de excedente Valor dos tipos de honorários Mínimo e Misto
Local cCodTpFat  := ""
Local cMoeFixo   := ""
Local lParNT1    := .F.
Local dNT1Data   := CToD(' / / ')
Local dDtVenc    := CToD(' / / ')
Local nVlrbase   := 0
Local cCampo     := ""
Local oView      := Nil
Local nTamParc   := TamSX3("NT1_PARC")[1]
Local lParcDel   := .F.
Local cCodDscPrc := ""
Local cIdiomPFT  := ""
Local lEmptyNT1  := .F.
Local lSmartUI   := .F. // Se a chamada da função vier pela API

Default oModel   := Nil
Default aInfoApi := {}
Default aParcNT1 := {}
Default cMsgSmUi := ""

Private CINSTANC := ""

lSmartUI := Len(aInfoApi) > 0 // Se a chamada da função vier pela API

If lSmartUI
	cCTPHON    := aInfoApi[01]       // NT0_CTPHON
	cNT0Ench   := aInfoApi[02]       // NT0_ENCH
	nNT0QtPar  := Val(aInfoApi[03])  // NT0_QTPARC
	nPerFix    := Val(aInfoApi[04])  // NT0_PERFIX
	nPercD     := Val(aInfoApi[05])  // NT0_PERCD
	nPeriodExc := Val(aInfoApi[06])  // NT0_PEREX
	nVlrbase   := Val(aInfoApi[07])  // NT0_VLRBAS
	cFixoExc   := aInfoApi[08]       // NT0_FIXEXC
	cMoeFixo   := aInfoApi[09]       // NT0_CMOEF
	dDtRefIni  := SToD(aInfoApi[10]) // NT0_DTREFI
	cCodDscPrc := aInfoApi[11]       // NT0_DESPAR
	cIdiomPFT  := aInfoApi[12]       // NT0_CIDIO
	dDataVenc  := SToD(aInfoApi[13]) // NT0_DTVENC
	dDtVigI    := SToD(aInfoApi[14]) // NT0_DTVIGI
	dDtVigF    := SToD(aInfoApi[15]) // NT0_DTVIGF
	aParcApi   := aInfoApi[16]       // Campos da NT1
	nQtdLine   := Len(aInfoApi[16])
	lEmptyNT1  := nQtdLine < 1

Else
	oModelNT1  := oModel:GetModel('NT1DETAIL')
	oModelNT0  := oModel:GetModel('NT0MASTER')
	cCTPHON    := oModelNT0:GetValue('NT0_CTPHON')
	cNT0Ench   := oModelNT0:GetValue('NT0_ENCH')
	nNT0QtPar  := oModelNT0:GetValue('NT0_QTPARC')
	nPerFix    := oModelNT0:GetValue('NT0_PERFIX')
	nPercD     := oModelNT0:GetValue('NT0_PERCD')
	nPeriodExc := oModelNT0:GetValue('NT0_PEREX')
	nVlrbase   := oModelNT0:GetValue('NT0_VLRBAS')
	cFixoExc   := oModelNT0:GetValue('NT0_FIXEXC')
	cMoeFixo   := oModelNT0:GetValue('NT0_CMOEF')
	dDtRefIni  := oModelNT0:GetValue( "NT0_DTREFI" )
	cCodDscPrc := oModelNT0:GetValue( "NT0_DESPAR" )
	cIdiomPFT  := oModelNT0:GetValue( "NT0_CIDIO" )
	dDataVenc  := oModelNT0:GetValue( "NT0_DTVENC" )
	nQtdLine   := oModelNT1:GetQtdLine()
	lEmptyNT1  := oModelNT1:IsEmpty()
	aSaveLn    := FWSaveRows()
	oView      := FwViewActive()
EndIf

//Aplicar valores de default nas váriaveis estática, de forma que quando for chamado via API, essas váriaves existam com os valores iniciais.
J096SetSta()
If Empty(aCpoBotoes)
	aCpoBotoes := {}
	aCpoInBot  := {}
	JUR096CPO()
EndIf

nAt := aScan( aCpoBotoes, { |x| x[CTPHON] == cCTPHON .AND. X[BOTAO] == nBotaoAtv} )

If lRet
	For nI := 1 To Len( aCpoBotoes[nAt][CONFIG] )

		cCampo := AllTrim( aCpoBotoes[nAt][CONFIG][nI][CAMPO] )

		If cCampo == 'NT0_PERCD' .And. aCpoBotoes[nAt][CONFIG][nI][VISIV]
			Iif(nPercD <> 0, lDesc := .T., lDesc := .F. )
		EndIf

		If (cCampo == 'NT0_DTREFI' .Or. cCampo == 'NT0_DTVENC') .And. !aCpoBotoes[nAt][CONFIG][nI][VISIV] //Analisa se os campos de Data estão visíveis
			lDt := .F.
		EndIf

		IIF(cCampo == 'NT0_PARCE', cNT0Parce := Eval(aCpoBotoes[nAt][CONFIG][nI][INICIA]), "")//Obtenho o "PARCELAR?" Sim ou Não

		If cCampo == 'NT0_PERFIX' .And. aCpoBotoes[nAt][CONFIG][nI][VISIV] //Se campo é Visivel entro com dados da tela (evitar erro com criação de datas)
			If nPerFix == 0
				If lSmartUI
					cMsgSmUi := STR0171 //"Informe a periodicidade das parcelas."
				Else
					MsgInfo(STR0171) //"Informe a periodicidade das parcelas."
				EndIf

				lRet:= .F.
				Exit
			EndIf
		EndIf 

		If cCampo == 'NT0_PEREX' .And. aCpoBotoes[nAt][CONFIG][nI][OBRIGA]
			If nPeriodExc == 0
				If lSmartUI
					cMsgSmUi := STR0193 //"A periodicidade de excedente deve ser preenchida. Verifique!"
				Else
					MsgInfo(STR0193) //"A periodicidade de excedente deve ser preenchida. Verifique!"
				EndIf

				lRet := .F.
				Exit
			ElseIf !Empty(nPerFix) .And. (nPerFix > nPeriodExc)
				If lSmartUI
					cMsgSmUi := STR0192  //"A periodicidade de cobrança não pode ser maior do que a periodicidade de excedente. Verifique!"
				Else
					MsgInfo(STR0192) //"A periodicidade de cobrança não pode ser maior do que a periodicidade de excedente. Verifique!"
				EndIf
				
				lRet := .F.
				Exit
			EndIf
		EndIf

		
		If cCampo == 'NT0_QTPARC' .And. aCpoBotoes[nAt][CONFIG][nI][OBRIGA] //Se campo é Visivel entro com dados da tela (evitar erro com criação de datas)
			If nNT0QtPar == 0
				If lSmartUI
					cMsgSmUi := STR0172 //"Informe a quantidade de parcelas."
				Else
					MsgInfo(STR0172) //"Informe a quantidade de parcelas."
				EndIf

				lRet := .F.
				Exit
			EndIf
		EndIf

		If cCampo == 'NT0_VLRBAS' .And. aCpoBotoes[nAt][CONFIG][nI][VISIV]
			If nVlrbase == 0
				If lSmartUI
					cMsgSmUi := STR0173 //"Informe o valor base da parcela."
				Else
					MsgInfo(STR0173) //"Informe o valor base da parcela."
				EndIf

				lRet := .F.
				Exit
			ElseIf cFixoExc == '2' .And. !Empty(nPeriodExc) .And. !Empty(nPerFix) //Para cálculo do valor da parcela de Misto
				nVlrbase := nVlrbase / NoRound((nPeriodExc / nPerFix), 0)
			EndIf
			If lDesc
				nVlrbase := nVlrbase - ( nVlrbase * ( nPercD / 100 ) )
			EndIf
		EndIf

		If cCampo == 'NT0_CMOEF' .And. aCpoBotoes[nAt][CONFIG][nI][OBRIGA]
			If Empty(cMoeFixo)
				If lSmartUI
					cMsgSmUi := STR0174 //"Informe o valor base da parcela."
				Else
					MsgInfo(STR0174) //"Informe o valor base da parcela."
				EndIf

				lRet:=.F.
				Exit
			EndIf
		EndIf
	Next

EndIf

// Verifica se o tipo de honorários é fixo e automático
If  lRet .And. JUR96TPFIX(cCTPHON)
	//Utilizado para criar o item de parcela automatica no formulario

	//Verifica a existência de parcelas pendentes
	lGeraParc := .T.
	lNewLine  := .F.

	If nQtdLine > 0 .And. !lEmptyNT1

		If lSmartUI
			NT1->( dbSetOrder( 1 ) ) //NT1_FILIAL+NT1_SEQUEN
			NT1->( dbseek( xFilial('NT1') + aParcApi[nQtdLine][06] ) )
			cCodTpFat := NT1->NT1_CTPFTU
		Else
			oModelNT1:GoLine(nQtdLine)
			cCodTpFat := oModelNT1:GetValue("NT1_CTPFTU")
		EndIf
		
		For nI := 1 To nQtdLine
			If lSmartUI
				lParcDel := .F.
				cParcSit   := aParcApi[nI][01] // NT1_SITUAC
				cCdTpFtPrc := aParcApi[nI][02] // NT1_CTPFTU
				nNumParc   := Iif(Valtype(aParcApi[nI][03]) == "C", Val(aParcApi[nI][03]), 0) // NT1_PARC
			Else
				lParcDel   := oModelNT1:IsDeleted(nI)
				cParcSit   := oModelNT1:GetValue("NT1_SITUAC", nI)
				cCdTpFtPrc := oModelNT1:GetValue("NT1_CTPFTU", nI)
				nNumParc   := Val(oModelNT1:GetValue("NT1_PARC", nI))
			EndIf

			If !lParcDel

				If cParcSit == "1"
					lGeraParc := .F.
					Exit
				Else
					lParNT1  := .T.
				EndIf

				If cCodTpFat != cCdTpFtPrc
					cCodTpFat := ""
				EndIf

				
				If nParcMax < nNumParc
					nParcMax := nNumParc
					//Verifica a data da maior Parcela
					If lSmartUI
						dNT1Data := aParcApi[nI][04] // NT1_DATAIN
						dDtVenc  := aParcApi[nI][05] // NT1_DATAVE
					Else
						dNT1Data := oModelNT1:GetValue("NT1_DATAIN", nI)
						dDtVenc  := oModelNT1:GetValue( "NT1_DATAVE", nI )
					EndIf
				EndIf
			EndIf
		Next

	Else
		lNewLine := .T.
	EndIf

	If J96TPHPAut(cCTPHON) .And. cNT0Parce == '2'  //Se for parcelas Automática e Tipo Hono for Parcelar?=2(Não), considerar 1 parcela
		nNT0QtPar := 1
	EndIf

	//Se não existirem parcelas pendentes, gera parcela automática
	If lGeraParc .and. J096GerNT1( cCTPHON, cNT0Parce, cNT0Ench )

		//Condição para saida do loop abaixo
		lFimDtRef := .T.

		nNumParc := Strzero( nParcMax, nTamParc )

		//Start das datas de referencia e vencimento
		If lDt
			//Caso existam parcelas já concluídas
			If lParNT1
				If lSmartUI
					dDataIni  := SToD(JurDtAdd(dNT1Data, 'M', 1 ))
					dDataFim  := lastday(SToD( JurDtAdd(dDataIni , "M", 0 ) ))
					dDataVenc := SToD(JurDtAdd(dDtVenc, 'M', 1 ))
				Else 
					dDataIni  := SToD(JurDtAdd(DToS(dNT1Data), 'M', 1 ))
					dDataFim  := lastday(SToD( JurDtAdd( DTOS(dDataIni) , "M", 0 ) ))
					dDataVenc := SToD(JurDtAdd(DToS(dDtVenc), 'M', 1 ))
				EndIf
			Else

				dDataIni := ctod( "01/" + strzero( month( dDtRefIni ), 2 ) + "/" +  ;
							substr( str( year( dDtRefIni ), 4 ), 3, 2 ) )
				
				If !Empty(dDataIni)
					dDataFim  := lastday(stod( JurDtAdd( dDataIni , "M", nPerFix-1 ) ))
				EndIf

			Endif

			If dDataVenc < dDtRefIni
				If lSmartUI
					cMsgSmUi := STR0189 // " A primeira data de vencimento deve ser a partir da data de referência inicial. "
				Else
					ApMsgInfo(STR0189) // " A primeira data de vencimento deve ser a partir da data de referência inicial. "
				EndIf
				lRet:=.F.
			EndIf
		Else
			dDataIni := dDataFim := dDataVenc := CToD(' / / ')
		EndIf

		//Geração das parcelas na tabela NT1
		If lRet
			For nA := 1 To nNT0QtPar
				
				If lSmartUI
					lRet := J096VldData(dDataIni, dDataFim, Strzero( nA, nTamParc ), lSmartUI, dDtVigI, dDtVigF, @cMsgSmUi)
				Else
					lRet := J096VldData(dDataIni, dDataFim, Strzero( nA, nTamParc ))
				EndIf

				If !lRet
					If !lSmartUI
						oView:Refresh('NT1DETAIL')
					EndIf
					Exit
				EndIf

				//Verifica se a proxima data de referencia final ultrapassa a data de referencia digitada  OU  se deve gerar apenas uma parcela

				//Força liberação de edição no modelo NT1
				If !lSmartUI
					J096SetNo( oModelNT1, .F. )
				EndIf

				//Controle de numercação das parcelas
				nNumParc := Soma1(nNumParc)

				If !Empty(cCodDscPrc) .And. !Empty(cIdiomPFT)
					cDescPar := JA096DePar(cCodDscPrc, cIdiomPFT)
				Else
					cDescPar := STR0041 + nNumParc //Parcela XXXX
				EndIf

				//Adiciona um novo registro
				If ! lNewLine
					If !lSmartUI
						oModelNT1:AddLine()
					EndIf
				EndIf
				If lSmartUI
					aAdd( aParcNT1, { nNumParc,;                                                       // 01 - NT1_PARC
										Space(TamSx3('NT1_CTPFTU')[1]),;                               // 02 - NT1_CTPFTU
										DtoS(dDataIni),;                                               // 03 - NT1_DATAIN
										DtoS(dDataFim),;                                               // 04 - NT1_DATAFI
										cValToChar(nVlrbase),;                                         // 05 - NT1_VALORB
										cValToChar(nVlrbase),;                                         // 06 - NT1_VALORA
										DtoS(Date()),;                                                 // 07 - NT1_DATAAT
										DtoS(dDataVenc),;                                              // 08 - NT1_DATAVE
										cDescPar,;                                                     // 09 - NT1_DESCRI
										cMoeFixo,;                                                     // 10 - NT1_CMOEDA
										'1',;                                                          // 11 - NT1_SITUAC
										JurGetDados("CTO", 1, xFilial("CTO") + cMoeFixo, "CTO_SIMB" ); // 13 - NT1_DMOEDA
									})
				Else
					aCpoGrd := {}

					aAdd( aCpoGrd, { 'NT1_PARC'  , nNumParc  } )
					aAdd( aCpoGrd, { 'NT1_CTPFTU', Space(TamSx3('NT1_CTPFTU')[1])})
					aAdd( aCpoGrd, { 'NT1_DATAIN', dDataIni  } )
					aAdd( aCpoGrd, { 'NT1_DATAFI', dDataFim  } )
					aAdd( aCpoGrd, { 'NT1_VALORB', nVlrbase  } )
					aAdd( aCpoGrd, { 'NT1_VALORA', nVlrbase  } )
					aAdd( aCpoGrd, { 'NT1_DATAAT', Date()    } )
					aAdd( aCpoGrd, { 'NT1_DATAVE', dDataVenc } )
					aAdd( aCpoGrd, { 'NT1_DESCRI', cDescPar  } )
					aAdd( aCpoGrd, { 'NT1_CMOEDA', cMoeFixo  } )
					aAdd( aCpoGrd, { 'NT1_DMOEDA', JurGetDados("CTO", 1, xFilial("CTO") + cMoeFixo, "CTO_SIMB" )  } )
					aAdd( aCpoGrd, { 'NT1_SITUAC', '1'  } )

					//Grava conteudos nos campos
					For nI := 1 To Len( aCpoGrd )
						If !(lRet := JurLoadValue(oModelNT1, aCpoGrd[nI,1], , aCpoGrd[nI,2] ))
							Exit
						EndIf
					Next nI

					If lRet .And. Empty(oModelNT1:GetValue("NT1_SEQUEN"))
							lRet := JurLoadValue(oModelNT1, "NT1_SEQUEN", , JurGetNum("NT1","NT1_SEQUEN") )
					EndIf


					If !lRet .or. !oModelNT1:VldData()
						JurShowErro( oModel:GetModel():GetErrormessage() )
						Return lRet
					EndIf
					//Forca o bloqueio de edicao no modelo NT1
					oModelNT1:SetNoUpdateLine(.F.)
				EndIf

				//Acrescenta novos periodos as datas de referencia inicial e final
				If lDt

					dDataIni := ctod( "01/" + strzero( month( stod( JurDtAdd( dDataFim, 'M', 1 ) ) ), 2 ) + "/" +  ;
								substr( str( year( stod( JurDtAdd( dDataFim, 'M', 1 ) ) ), 4 ), 3, 2 ) )
					dDataVenc := stod( JurDtAdd( dDataVenc, 'M', nPerFix ) )

					dDataFim := lastday(stod( JurDtAdd( dDataIni , "M", nPerFix-1 ) ))

				Else
					dDataIni := dDataFim := dDataVenc := CToD(' / / ')
				EndIf

				//Permite a insercao de novas linhas na NT1
				lNewLine := .F.

			Next nA
		EndIf

	Else
		If lSmartUI
			cMsgSmUi := I18N(STR0176, {STR0126}) //# "Existem parcelas pendentes cadastradas, a opção '#1' não pode mais ser usada."
		Else
			ApMsgInfo( I18N(STR0176, {STR0126}) ) //# "Existem parcelas pendentes cadastradas, a opção '#1' não pode mais ser usada."
		EndIf
	Endif

Endif

lCtlCndFat := .F.

If !lSmartUI
	FWRestRows( aSaveLn )
EndIf

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} J096ConfPa(oModel, nBotaoAtv)
Rotina para validar e chama rotina para gerar parcela na Cond. Faturamento através do botão de Confirmar

@param nBotaoAtv = Referente ao campo NTH_BOTAO
                     1 = Condições de Faturamento de Fixo
                     2 = Faixa de Valores

@Return Nil

@author Tiago Martins
@since 30/09/2011
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function J096ConfPa(oModel, nBotaoAtv)
Local aSaveLn    := FWSaveRows()
Local oModelNT1  := oModel:GetModel('NT1DETAIL')
Local oModelNT0  := oModel:GetModel('NT0MASTER')
Local cCTPHON    := oModelNT0:GetValue('NT0_CTPHON')
Local nQtdLine   := oModelNT1:GetQtdLine()
Local nQtPendent := 0
Local nI         := 0
Local lAut       := .T. //gera automático

If !oModelNT1:IsEmpty()
	For nI := 1 To nQtdLine
		If !oModelNT1:isDeleted(nI) .And. oModelNT1:GetValue("NT1_SITUAC", nI) == "1" //conta se há algum pendente
			nQtPendent += 1
		EndIf
	Next
EndIf

If nQtPendent > 0 .And. lCtlCndFat .And. J096VldVlr(oModel, nBotaoAtv)
	If MsgYesNo(STR0129)   //"Houve alteração na tela. Deseja salvar a alteração?"
		J096Parcela(oModel, nBotaoAtv)
		lAut := .F.
	EndIf
EndIf

If lAut //Gera Automático
	If oModelNT1:IsEmpty() .And. J96TPHPAut(cCTPHON)
		J096Parcela(oModel, nBotaoAtv)
	EndIf
EndIf

FWRestRows(aSaveLn)

Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} J096VldNT1(oModel)
Verifica se os campos Obrigatórios na NT1 estão preenchidos de 
acordo com Tipo Honorário

@param oModel, Modelo de dados de Contratos
@param nLine , Linha posicionada no grid de parcelas fixas (NT1)

@return lRet , Indica se os valores são válidos

@author Tiago Martins
@since  05/10/2011
/*/
//-------------------------------------------------------------------
Static Function J096VldNT1(oModel, nLine)
Local lRet      := .T.
Local cMsgErro  := ''
Local cMsg      := ''
Local oModelNT1 := oModel:GetModel('NT1DETAIL')
Local dDataIni  := oModelNT1:GetValue('NT1_DATAIN', nLine)
Local dDataFim  := oModelNT1:GetValue('NT1_DATAFI', nLine)
Local dDataVenc := oModelNT1:GetValue('NT1_DATAVE', nLine)

	If oModelNT1:GetValue("NT1_SITUAC", nLine) == "1"
		If lRet .And. !Empty(dDataIni) .And. (dDataFim < dDataIni)
			cMsgErro += "-" + STR0095 + CRLF // "A data final deve ser maior que a data inicial."
			lRet := .F.
		EndIf

		If lRet .And. !Empty(dDataIni) .And. !Empty(dDataVenc) .And. (dDataVenc < dDataIni)
			cMsgErro += "-" + STR0189 + CRLF // "A primeira data de vencimento deve ser a partir da data de referência inicial. " // STR0130 + CRLF	 // "A primeira data de vencimento deve ser a partir do mês seguinte ao da Data de Referência Final"
			lRet := .F.
		EndIf
	EndIf

	If !Empty(cMsgErro)
		cMsg += STR0133 + oModelNT1:GetValue('NT1_PARC', nLine) + ":" + CRLF + cMsgErro // "Erro na parcela "
		JurMsgErro(cMsg)
	EndIf

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} J096EdtNT1(oModel)
Verifica se Tipo Hono é Parcelas Automáticas, se Sim habilita Edição do Grid NT1

@author Tiago Martins
@since 18/10/2011
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function J096EdtNT1(oModel)
Local oModelNT1  := oModel:GetModel('NT1DETAIL')
Local oStructNT1 := oModelNT1:GetStruct()
Local cTpHon     := oModel:GetValue('NT0MASTER', 'NT0_CTPHON')

oStructNT1:setProperty("*", MODEL_FIELD_WHEN, {|| .F.}) //Bloqueia todas colunas

oStructNT1:setProperty("NT1_CCONTR", MODEL_FIELD_WHEN, {|model| !model:isDeleted() .and. model:GetValue("NT1_SITUAC")=="1" })
oStructNT1:setProperty("NT1_CTPFTU", MODEL_FIELD_WHEN, {|model| !model:isDeleted() .and. model:GetValue("NT1_SITUAC")=="1" })
oStructNT1:setProperty("NT1_DTPFTU", MODEL_FIELD_WHEN, {|model| !model:isDeleted() .and. model:GetValue("NT1_SITUAC")=="1" })
oStructNT1:setProperty("NT1_DATAIN", MODEL_FIELD_WHEN, {|model| !model:isDeleted() .and. model:GetValue("NT1_SITUAC")=="1" })
oStructNT1:setProperty("NT1_DATAFI", MODEL_FIELD_WHEN, {|model| !model:isDeleted() .and. model:GetValue("NT1_SITUAC")=="1" })
oStructNT1:setProperty("NT1_DATAVE", MODEL_FIELD_WHEN, {|model| !model:isDeleted() .and. model:GetValue("NT1_SITUAC")=="1" })
oStructNT1:setProperty("NT1_DESCRI", MODEL_FIELD_WHEN, {|model| !model:isDeleted() })

If !J96TPHPAut(cTpHon)//verifica se é Parc. Automática
	oStructNT1:setProperty("NT1_VALORB", MODEL_FIELD_WHEN, {|model| !model:isDeleted() .and. model:GetValue("NT1_SITUAC")=="1" })
	oStructNT1:setProperty("NT1_VALORA", MODEL_FIELD_WHEN, {|model| !model:isDeleted() .and. model:GetValue("NT1_SITUAC")=="1" }) //Se desabilitar pelo When não poderá gatilhar.
	oModelNT1:SetNoUpdateLine(.F.)
Else
	oModelNT1:SetNoUpdateLine(.F.)
EndIF

J96AltParc(oModel) //Habilita alteração manual da parcela de fixo.

Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} J096ArmzNT0(oModel)
Armazena dados da tela Cond Faturamento NT0 em Array

@param nBotaoAtv = Referente ao campo NTH_BOTAO
                     1 = Condições de Faturamento de Fixo
                     2 = Faixa de Valores

@author Tiago Martins
@since 04/11/2011
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function J096ArmzNT0(oModel, nBotaoAtv)
Local oModelNT0 := oModel:GetModel("NT0MASTER")
Local cCTPHON   := oModelNT0:GetValue('NT0_CTPHON')
Local nAt       := aScan( aCpoBotoes, { |x| x[CTPHON] == cCTPHON .AND. X[BOTAO] == nBotaoAtv} )
Local aCpoGrd   := {}
Local nI        := 0

For nI := 1 to Len(aCpoBotoes[nAt][CONFIG])
	If aCpoBotoes[nAt][CONFIG][nI][VISIV]
		aAdd( aCpoGrd, {aCpoBotoes[nAt][CONFIG][nI][CAMPO], FwFldGet( aCpoBotoes[nAt][CONFIG][nI][CAMPO] ) } ) //[CampoNT0, Valor]
	EndIf
Next

Return aCpoGrd

//-------------------------------------------------------------------
/*/{Protheus.doc} J096VldVlr(oModel, nBotaoAtv)
Valida os Valores do NT1 para confirmar se houve alteração do Grid NT1

@param nBotaoAtv = Referente ao campo NTH_BOTAO
                     1 = Condições de Faturamento de Fixo
                     2 = Faixa de Valores
@Return lRet		Se .T. é que houve alteração no campo NT0 da Cond. Faturamento

@author Tiago Martins
@since 04/11/2011
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function J096VldVlr(oModel, nBotaoAtv)
Local lRet      := .F.
Local oModelNT0 := oModel:GetModel("NT0MASTER")
Local cCTPHON   := oModelNT0:GetValue('NT0_CTPHON')
Local nAt       := aScan( aCpoBotoes, { |x| x[CTPHON] == cCTPHON .AND. X[BOTAO] == nBotaoAtv} )
Local nI        := 0
Local nA        := 0

For nI := 1 To Len(aCpoBotoes[nAt][CONFIG])
	If aCpoBotoes[nAt][CONFIG][nI][VISIV]
		For nA:=1 To Len(aArmzNT0)
			If aCpoBotoes[nAt][CONFIG][nI][CAMPO] ==  aArmzNT0[nA][1];
					.And. FwFldGet( aCpoBotoes[nAt][CONFIG][nI][CAMPO] ) != aArmzNT0[nA][2] //Campara os Campos & os Valores
				lRet = .T.
				Exit
			EndIf
		Next
		If lRet
			Exit
		EndIf
	EndIf
Next

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} J096VlDtNT1(oModel)
Valida as Datas do NT1 para confirmar se houve alteração do Grid NT1

@Return lRet		Se .T. é que houve alteração no campo NT0 da Cond. Faturamento

@author Tiago Martins
@since 04/11/2011
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function J096VlDtNT1(oModel)
Local lRet      := .T.
Local nLine     := 0
Local oModelNT1 := oModel:GetModel('NT1DETAIL')
Local cTpHon    := oModel:GetModel('NT0MASTER'):GetValue('NT0_CTPHON')
Local nQtdLine  := oModelNT1:GetQtdLine()

If JUR96TPFIX(cTpHon) .And. !J96TPHPAut(cTpHon) // Se tiver fixo, valida se os campos estão preenchidos
	For nLine := 1 To nQtdLine
		If !oModelNT1:IsDeleted(nLine)
			lRet := J096VldNT1(oModel, nLine) // Verifica se os campos Obrigatórios na NT1 estão preenchidos de acordo com Tipo Honorário
			If !lRet
				Exit
			EndIf
		EndIf
	Next
EndIf

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} J096DesCs()
Aplica o desconto nos casos do contrato

@Return lRet	.T. se  efetuado as alterações nos casos do contrato

@author Luciano Pereira dos Santos
@since 21/12/2011
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function J096DesCs(oModel, aNUT)
Local lRet       := .T.
Local aArea      := GetArea()
Local oModelNT0  := oModel:GetModel('NT0MASTER')
Local nDesPad    := oModelNT0:GetValue("NT0_DESPAD")
Local oModelNUT  := oModel:GetModel('NUTDETAIL')
Local nLine      := oModelNUT:GetLine()
Local nQtdNUT    := oModelNUT:GetQtdLine()
Local cClient    := ""
Local cLoja      := ""
Local cCaso      := ""
Local nI         := 0
Local cMemoCab   := (STR0146 + CRLF + CRLF) //"O desconto não pode ser alterado no(s) caso(s): "
Local cMemoErr   := ""

Default aNUT     := {}

If Len(aNUT) == 0
	For nI := 1 To nQtdNUT
		If !oModelNUT:IsDeleted(nI) .And. !Empty(oModelNUT:GetValue("NUT_CCASO", nI ))
			cClient := oModelNUT:GetValue("NUT_CCLIEN", nI )
			cLoja   := oModelNUT:GetValue("NUT_CLOJA", nI )
			cCaso   := oModelNUT:GetValue("NUT_CCASO", nI )

			cMemoErr += J096GrDCas(cClient, cLoja, cCaso, nDesPad, .F.)
		EndIf
	Next nI

Else
	For nI := 1 To Len(aNUT)
		If !oModelNUT:IsDeleted(aNUT[nI])
			cClient := oModelNUT:GetValue("NUT_CCLIEN", aNUT[nI] )
			cLoja   := oModelNUT:GetValue("NUT_CLOJA", aNUT[nI] )
			cCaso   := oModelNUT:GetValue("NUT_CCASO", aNUT[nI] )

			cMemoErr += J096GrDCas(cClient, cLoja, cCaso, nDesPad, .F.)
		EndIf
	Next nI

EndIf

oModelNUT:GoLine(nLine)

RestArea( aArea )

If !Empty(cMemoErr)
	JurErrLog(cMemoCab + cMemoErr, STR0146) //"Alteração de desconto"
EndIf

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} JA096VLIM()
Validação do valor limite

@Return lRet	.T. se  o valor e maior ou igual ao valor faturado

@author Luciano Pereira dos Santos
@since 30/01/2012
@version 1.0
/*/
//-------------------------------------------------------------------
Function JA096VLIM()
Local lRet      := .T.
Local nValorLim := 0
Local nSaldoIni := 0
Local lSmartUI  := FindFunction("JurIsSmartUI") .And. JurIsSmartUI() // Proteção @12.1.2410

If IsInCallStack( 'JURA096' )  .Or. lSmartUI
	nValorLim := FwFldGet('NT0_VLRLI')
	nSaldoIni := FwFldGet('NT0_SALDOI')
	If nValorLim < nSaldoIni
		lRet := JurMsgErro(STR0138) // "O Valor Limite do contrato não pode ser menor que o saldo inicial!"
	EndIf
EndIf

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} J096NVENUT
Consulta padrão de casos do contrato filtrando pelo cliente, loja ou
grupo do contrato

@Return lRet	 	.T./.F. As informações são válidas ou não

@author Juliana Iwayama Velho
@since 27/01/2012
@version 1.0
/*/
//-------------------------------------------------------------------
Function J096NVENUT()
Local xRet      := Nil
Local lOldSXB   := GetSx3Cache('NUT_CCASO', 'X3_F3') == 'NVENUT'
Local aArea     := GetArea()
Local aFiltro   := {}
Local aSearch   := {}
Local aCampos   := {}

J70SetVar( "_J96GrpCli", FwFldGet("NT0_CGRPCL") )
J70SetVar( "_J96CodCli", FwFldGet("NT0_CCLIEN") )
J70SetVar( "_J96LojCli", FwFldGet("NT0_CLOJA")  )

If lOldSXB //Proteção 12.1.14
	/* Filtro
	[1] Condição para adicionar o filtro ou não
	[2] Tipo = A(Comando ADVPL) / S(Comando SQL)
	[3] Titulo do filtro
	[4] Comando
	[5] Tabela para filtro relacional (apenas para comando SQL)
	*/
	aSearch := {{'NVE_CCLIEN',1},{'NVE_NUMCAS',3},{'NVE_TITULO',4}} //Campos para pesquisa e indice
	aCampos := {'NVE_NUMCAS','NVE_TITULO'}  //Campos de colunas

	aAdd( aFiltro, {_cNumClien == "1" .And. !Empty(FwFldGet('NUT_CCLIEN')) .And. !Empty(FwFldGet('NUT_CLOJA')), 'A', STR0140,;
					"NVE_CCLIEN == '"+ FwFldGet('NUT_CCLIEN') +"' .AND. NVE_LCLIEN == '" + FwFldGet('NUT_CLOJA') + "' .AND. NVE_COBRAV == '1'"} )
	aAdd( aFiltro, {_cNumClien == "2" .And. !Empty(FwFldGet('NT0_CGRPCL')), 'A', STR0142, "NVE_COBRAV == '1'"} )

	xRet := .F.
	If JurF3Tab( aSearch, 'NVE', aFiltro, aCampos, 'JURA070' )
		xRet := .T.
	EndIf
Else
	 xRet  := ".T."
	If !Empty(FwFldGet('NUT_CCLIEN'))
		xRet  += " .AND. NVE_CCLIEN == '" + FwFldGet('NUT_CCLIEN') + "'"
	EndIf

	If !Empty(FwFldGet('NUT_CLOJA'))
		xRet  += " .AND. NVE_LCLIEN == '" + FwFldGet('NUT_CLOJA') + "'"
	EndIf
	RestArea( aArea )
EndIf

Return xRet

//-------------------------------------------------------------------
/*/{Protheus.doc} J096VerCli
Verifica se o campo de cliente do contrato está preenchido para habilitar
campos de casos

@author Juliana Iwayama Vrlho
@since 01/02/2012
@version 1.0
/*/
//-------------------------------------------------------------------
Function J096VerCli()
Local lRet      := .T.
Local oModel    := FwModelActive()
Local oModelNT0 := oModel:GetModel("NT0MASTER")

	If IsInCallStack('JURA096')
		If lRet .And. (oModel:GetOperation() == 3 .Or. oModel:GetOperation() == 4)
			 If Empty(oModelNT0:GetValue("NT0_CCLIEN")) .Or. Empty(oModelNT0:GetValue("NT0_CLOJA"))
				lRet := .F.
			EndIf
		Endif
	EndIf

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} J096RetRecno
Retorna o Recno para que seja feita a rotina de anexos

@author Jorge Luis Branco Martins Junior
@since 22/02/2012
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function J096RetRecno(cCod)

JURGETDADOS('NT0', 1, xFilial('NT0') + FwfldGet(cCod), 'NT0_COD')

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} J096CHon()
Verifica se o contrato cobra honorarios

@param cTipHon , Tipo de honorário

@Return lRet	.T. se o tipo de honorarios cobrar hora

@author Luciano Pereira dos Santos
@since 28/02/2012
@version 1.0
/*/
//-------------------------------------------------------------------
Function J096CHon(cTipHon)
Local lRet      := .T.
Local aArea     := GetArea()

Default cTipHon := M->NT0_CTPHON

If !Empty(cTipHon)
	NRA->(dbSetOrder(1))
	NRA->(dbSeek(xFilial('NRA') + cTipHon))
	lRet := NRA->NRA_COBRAH == '1'
EndIf

RestArea( aArea )

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} J096CPYCnt(oModel)
Rotina para guardar as informações dos campos do contrato.

@param  oModel  Modelo de dados

@return Nil

@author Luciano Pereira dos Santos
@since 28/02/2012
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function J096CPYCnt( oModel )
Local oModelNT0   := oModel:GetModel("NT0MASTER")
Local aStrucNT0   := oModelNT0:oFormModelStruct:GetFields()

_aCnt096 := {} //private da rotina JURA096

AEval(aStrucNT0, {|aCpo| Aadd(_aCnt096, {aCpo[MODEL_FIELD_IDFIELD], oModelNT0:GetValue(aCpo[MODEL_FIELD_IDFIELD])}) })

Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} J096CntVl()
Retorna o valor do campo guardado no array de _aCnt096

@author Luciano Pereira dos Santos
@since 29/02/2012
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function J096CntVl(cCampo)
Local aSaveLines := FWSaveRows()
Local oModel     := FwModelActive()
Local oModelNT0  := oModel:GetModel("NT0MASTER")
Local nPos       := 0
Local uValor     := Nil

If oModel:GetOperation() != OP_INCLUIR
	nPos := aScan( _aCnt096, { |x| x[1] == cCampo} )
	uValor := _aCnt096[nPos][2]
Else
	uValor := oModelNT0:GetValue(cCampo)
EndIf

FWRestRows( aSaveLines )

Return uValor

//-------------------------------------------------------------------
/*/{Protheus.doc} J096GrDCas()
Grava o valor do desconto na tabela de casos

@author Luciano Pereira dos Santos
@since 29/02/2012
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function J096GrDCas(cClient, cLoja, cCaso, nDesPad, lNewCaso)
Local cRet      := ""
Local lRet      := .T.
Local aArea     := GetArea()
Local lGravDif  := .T.
Local lGravIgl  := .T.

Default lNewCaso := .F.

NVE->( dbSetOrder( 1 ) ) //NVE_FILIAL+NVE_CCLIEN+NVE_LCLIEN+NVE_NUMCAS
If NVE->( dbSeek( xFilial('NVE') + cClient + cLoja + cCaso ) )

	lGravDif := (NVE->NVE_DESPAD != J096CntVl("NT0_DESPAD")) .And. (NVE->NVE_DESPAD != nDesPad)
	lGravIgl := (NVE->NVE_DESPAD == J096CntVl("NT0_DESPAD")) .And. (NVE->NVE_DESPAD != nDesPad) .Or. lNewCaso

	If lGravDif .And. lNewCaso // se o desconto for diferente e for um casso novo
		If MsgYesNo(STR0060 + (NVE->NVE_NUMCAS) + STR0143 + Transform(NVE->NVE_DESPAD, "@E 999.99999999") + STR0144) //'O caso ' ## " esta com o desconto de " ## ". Deseja substituir o desconto?"
			RecLock("NVE", .F.)
			NVE->NVE_DESPAD := nDesPad
			NVE->(MsUnlock())
			NVE->(DbCommit())
			//Grava na fila de sincronização a alteração
			J170GRAVA("NVE", xFilial("NVE") + NVE->NVE_CCLIEN + NVE->NVE_LCLIEN + NVE->NVE_NUMCAS, "4")
		EndIf
	ElseIf lGravIgl  //se for um desconto igual ao do contrato replica a alteração
		RecLock("NVE", .F.)
		NVE->NVE_DESPAD := nDesPad
		NVE->(MsUnlock())
		NVE->(DbCommit())
		//Grava na fila de sincronização a alteração
		J170GRAVA("NVE", xFilial("NVE") + NVE->NVE_CCLIEN + NVE->NVE_LCLIEN + NVE->NVE_NUMCAS, "4")
	EndIf
Else
	lRet := .F.
EndIf

If !lRet
	cRet +=( STR0147 + cClient            )+ CRLF //"Cliente : "
	cRet +=( STR0148 + cLoja              )+ CRLF //"Loja ...: "
	cRet +=( STR0149 + cCaso              )+ CRLF //"Caso ...: "
	cRet +=( Replicate('-', LEN(STR0146)) )+ CRLF+CRLF  //"O desconto não pôde ser alterado no(s) caso(s): "
EndIf

RestArea( aArea )

Return cRet

//-------------------------------------------------------------------
/*/{Protheus.doc} J96VldDsc()
Grava o valor do desconto no caso (validação do campo NUT_CCASO)

@author Luciano Pereira dos Santos
@since 29/02/2012
@version 1.0
/*/
//-------------------------------------------------------------------
Function J96VldDsc()
Local lRet      := .T.
Local cClient   := ''
Local cLoja     := ''
Local cCaso     := ''
Local nDesPad   := 0
Local aCliLoj   := {}
Local cRet      := ''

If IsInCallStack("JURA096")

	cCaso := FwFldGet("NUT_CCASO")

	If _cNumClien == "1"
		cClient := FwFldGet("NUT_CCLIEN")
		cLoja   := FwFldGet("NUT_CLOJA")
	ElseIf _cNumClien == "2"
		aCliLoj := JCasoAtual(cCaso)
		If !Empty(aCliLoj)
			cClient := aCliLoj[1][1]
			cLoja   := aCliLoj[1][2]
		EndIf
	EndIf

	If !Empty(cClient) .And. !Empty(cLoja) .And. !Empty(cCaso)
		nDesPad := M->NT0_DESPAD
		cRet := J096GrDCas(cClient, cLoja, cCaso, nDesPad, .T.)
		J96DtRef()
		If !Empty(cRet)
			ApMsgInfo(cRet)
		EndIf
	Else
		cRet := RetTitle("NUT_CCLIEN") + ", " + RetTitle("NUT_CLOJA") + STR0191 + RetTitle("NUT_CCASO") //" e "

		lRet := JurMsgErro(I18N(STR0190, {Iif(_cNumClien == "1", cRet, RetTitle("NUT_CCASO"))})) //#Informe #1.
	EndIf

EndIf

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} J96DtRef(oModel)
Rotina para sugestão de preenchimento do campo NT0_DTREFI
"Dt Referência inicial"

@author Luciano Pereira dos Santos
@since 20/04/2012
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function J96DtRef()
Local lRet       := .T.
Local oModel     := FwModelActive()
Local oModelNT0  := oModel:GetModel("NT0MASTER")
Local oModelNUT  := Nil
Local dDtRefIni  := CtoD("  /  /     ")
Local dDtCaso    := Date()
Local dDtTroca   := Date()
Local nPos       := 0
Local cClient    := ""
Local cLoja      := ""
Local cCaso      := ""
Local cQuery     := ""
Local aRetDate   := {}

	If JUR96TPFIX(oModelNT0:GetValue("NT0_CTPHON"))

		nPos := aScan(_aCnt096, {|x| x[1] == "NT0_DTREFI"})
		dDtRefIni := IIF(nPos > 0, _aCnt096[nPos][2], oModelNT0:GetValue("NT0_DTREFI"))

		If Empty(dDtRefIni) .And. !oModel:GetModel('NT1DETAIL'):IsEmpty()
			If oModel:GetOperation() == MODEL_OPERATION_UPDATE
				cQuery := "SELECT MIN(NVE_DTENTR) DTENTRCASO "
				cQuery +=   "FROM " + RetSQLName("NUT") + " NUT, " + RetSqlName("NVE") + " NVE "
				cQuery +=  "WHERE NUT_CCONTR = '" + oModelNT0:GetValue("NT0_COD") + "' "
				cQuery +=    "AND NUT.NUT_FILIAL = '" + xFilial("NUT") + "' "
				cQuery +=    "AND NUT.D_E_L_E_T_ = ' ' "
				cQuery +=    "AND NUT.NUT_FILIAL = NVE.NVE_FILIAL "
				cQuery +=    "AND NUT.NUT_CCLIEN = NVE.NVE_CCLIEN "
				cQuery +=    "AND NUT.NUT_CLOJA = NVE.NVE_LCLIEN "
				cQuery +=    "AND NUT.NUT_CCASO = NVE.NVE_NUMCAS "
				cQuery +=    "AND NVE.D_E_L_E_T_ = ' ' "

				aRetDate := JurSQL(cQuery, "*")
				dDtTroca := IIF(Len(aRetDate) > 0, StoD(aRetDate[1][1]), dDtTroca)
			EndIf

			oModelNUT := oModel:GetModel('NUTDETAIL')
			If !oModelNUT:IsDeleted() .And. oModelNUT:IsUpdated()
				cClient := oModelNUT:GetValue("NUT_CCLIEN")
				cLoja   := oModelNUT:GetValue("NUT_CLOJA")
				cCaso   := oModelNUT:GetValue("NUT_CCASO")

				dDtCaso := Posicione("NVE", 1, xFilial('NVE') + cClient + cLoja + cCaso, "NVE_DTENTR")
			EndIf

			If dDtCaso < dDtTroca
				dDtTroca := dDtCaso
			EndIf

			lRet := oModel:LoadValue("NT0MASTER", "NT0_DTREFI", dDtTroca)
		EndIf
	EndIf

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} J96AltCtr
Verifica alteracao dos campos que afetam a geracao das pre-faturas

@author Daniel Magalhaes
@since 24/09/2012
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function J96AltCtr(oModel)
Local aArea   := GetArea()
Local aAux    := {}
Local cCpos   := "NT0_CMOE,NT0_CIDIO,NT0_CTPHON,NT0_DESPES,NT0_SERTAB,NT0_DESPAD,NT0_ENCH,NT0_ENCD,NT0_ENCT"
Local cGrids  := "NUTDETAIL,NTJDETAIL,NTKDETAIL,NXPDETAIL"
Local nFor    := 0
Local nQtdMdl := 0
Local lRet    := .F.
Local oMdlAux

aAux := StrTokArr(cCpos, ", ")

For nFor := 1 To Len(aAux)

	If lRet := oModel:IsFieldUpdated( "NT0MASTER", aAux[nFor] )
		Exit
	EndIf

Next nFor

If !lRet
	aAux := StrTokArr(cGrids,",")

	For nFor := 1 To Len(aAux)
		oMdlAux := oModel:GetModel(aAux[nFor])

		nQtdMdl := oMdlAux:GetQtdLine()

		If lRet := ( Len(oMdlAux:GetLinesChanged()) > 0 )
			Exit
		EndIf

	Next nFor

EndIf

RestArea(aArea)

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} JA096VE
Valida se na exclusão de uma parcela de fixo não exista registro de faturamento vinculado

@author Jacques Alves Xavier
@since 24/04/2013
@version 1.0
/*/
//-------------------------------------------------------------------
Function JA096VE(oSubModel, nLinha, cAction, cCampo, xComp, xValue, cMsg, lSmartUI)
Local lRet      := .T.
Local aArea     := GetArea()
Local oModel    := FwModelActive()
Local oModelNT0 := oModel:GetModel('NT0MASTER')
Local oModelNT1 := oModel:GetModel('NT1DETAIL')
Local oModelNWE := Nil
Local cCTPHON   := oModelNT0:GetValue('NT0_CTPHON')
Local oStrucNT1 := oModelNT1:GetStruct()
Local cMoeda    := ""
Local cPrefat   := ""
Local cSituac   := ""
Local cMsgSoluc := ""
Local nValBas   := 0
Local nI        := 0
Local lShowMsg  := .T.
Local lCanc     := .F.

Default cMsg     := ""
Default lSmartUI := .F.

If cAction != "CANSETVALUE"
	If cAction == "SETVALUE" .And. cCampo == "NT1_DESCRI" // Sempre permitir alterar o campo de descrição da parcela
		lRet := .T.
	ElseIf !J96TPHPAut(cCTPHON) // Verifica se geração de parcelas NÃO é automática
		oModelNWE := oModel:GetModel('NWEDETAIL')
		If !oModelNWE:IsEmpty()
			For nI := 1 To oModelNWE:GetQtdLine()

				lCanc   := oModelNWE:GetValue("NWE_CANC", nI) == "1"
				cPrefat := oModelNWE:GetValue("NWE_PRECNF", nI)

				If !lCanc .Or. cAction == "DELETE" // Caso o faturamento da parcela não esteja cancelado ou tente excluir o lançamento
					// Existe pré-fatura válida em situação que não permite alteração
					If !Empty(cPrefat) .And. JurGetDados("NX0", 1, xFilial("NX0") + cPrefat, "NX0_SITUAC") $ "4|5|7|9|A|B|C|F"
						lRet := .F.
						cMsgSoluc := STR0314 // "Existe pré-fatura válida em situação que não permite alteração. Por questão de rastreabilidade o registro não pode ser alterado/excluído."
						Exit

					// Existem faturas válidas
					ElseIf !Empty(oModelNWE:GetValue("NWE_CFATUR", nI))
						lRet := .F.
						cMsgSoluc :=  STR0315 // "Existe fatura emitida para a parcela. Por questão de rastreabilidade o registro não pode ser alterado/excluído."
						Exit

					// Existem WOs válidas
					ElseIf !Empty(oModelNWE:GetValue("NWE_CWO", nI))
						lRet := .F.
						cMsgSoluc := STR0316 // "Existe WO válido relacionado a parcela. Por questão de rastreabilidade o registro não pode ser alterado/excluído."
						Exit
					EndIf
				EndIf
			Next
		EndIf
	EndIf
ElseIf cAction == "CANSETVALUE" .And. cCampo == "NT1_VALORB" .And. oModelNT1:GetValue("NT1_QTDADE") > 0 .And. JUR96FAIXA(cCTPHON) .And. SuperGetMV("MV_JQTDAUT", .F., "1") == "2"
	lRet     := .F.
	lShowMsg := .F.
EndIf

If lRet
	// Validar e carregar automaticamente no grid a moeda e o simbolo.
	cPrefat := oModelNT1:GetValue("NT1_CPREFT")
	cSituac := JurGetDados("NX0", 1, xFilial("NX0") + cPrefat, "NX0_SITUAC")

	If oModelNT1:GetValue("NT1_SITUAC") == "2" .Or. !Empty(cPrefat) .And. cSituac $ "4|5|7|9|A|B|C|F"
		oStrucNT1:SetProperty( '*'        , MODEL_FIELD_WHEN, {|| .F.} ) // Não permitir a alteração de campos quando uma parcela estiver liquidada.
		oStrucNT1:SetProperty("NT1_DESCRI", MODEL_FIELD_WHEN, {|| .T.} ) // Será possível alterar somente a descrição
		If "DELETE" == cAction
			lRet := .F.
			cMsgSoluc := STR0180 + AllTrim(oModelNT1:GetValue("NT1_PARC")) + STR0181 + cPreFat + STR0182 + Tabela("JS", cSituac, .F.) + STR0184 // "A parcela '" ### "' está vinculada a pré-fatura '" ### "' com a situação '" ### "' e não poderá ser alterada!"
		EndIf
	Else
		If "CANSETVALUE" <> cAction .And. "SETVALUE" <> cAction
			cMoeda  := oModelNT0:GetValue("NT0_CMOEF")
			nValBas := oModelNT0:GetValue("NT0_VLRBAS")

			If !Empty(cMoeda)
				If Empty(oModelNT1:GetValue("NT1_CMOEDA"))  // Alterar a moeda apenas se estiver vazia.
						oModelNT1:SetValue("NT1_CMOEDA", cMoeda )
				EndIf
			EndIf

			If !Empty(nValBas) .And. Empty(oModelNT1:GetValue("NT1_VALORB"))
				oModelNT1:LoadValue("NT1_VALORB", nValBas )
			EndIf

		EndIf

		oStrucNT1:SetProperty( '*' , MODEL_FIELD_WHEN, {|| .T.} ) // Habilita a edição dos campos, caso tenham sido bloqueados e a parcela não estiver concluida.
	EndIf
EndIf

If !lRet .And. lShowMsg
	If lSmartUI
		cMsg := cMsgSoluc
	Else
		JurMsgErro(STR0195,, cMsgSoluc) // "Operação de Alteração/Exclusão cancelada!"
	EndIf
EndIf

RestArea(aArea)

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} JA096DESC
Retorna as descrições para os campos virtuais utilizados na rotina

@author Cristina Cintra Santos
@since 29/08/13
@version 1.0
/*/
//-------------------------------------------------------------------
Function JA096DESC( cCampo )
Local oModel := FwModelActive()
Local cRet   := ""

	Do Case
		Case  "NTK_DTPDSP" $ cCampo
			cRet :=  JurGetDados("NRH", 1, xFilial("NRH") + oModel:GetValue("NTKDETAIL", "NTK_CTPDSP"), "NRH_DESC")

		Case "NXP_DIDIO2" $ cCampo
			cRet :=  JurGetDados("NR1", 1, xFilial("NR1") + oModel:GetValue("NXPDETAIL", "NXP_CIDIO2"), "NR1_DESC")

		Case "NXP_DCARTA" $ cCampo
			cRet :=  JurGetDados("NRG", 1, xFilial("NRG") + oModel:GetValue("NXPDETAIL", "NXP_CCARTA"), "NRG_DESC")

 		Case "NXP_DIDIO" $ cCampo
			cRet :=  JurGetDados("NR1", 1, xFilial("NR1") + oModel:GetValue("NXPDETAIL", "NXP_CIDIO"), "NR1_DESC")

 		Case "NXP_DRELAT" $ cCampo
			cRet :=  JurGetDados("NRJ", 1, xFilial("NRJ") + oModel:GetValue("NXPDETAIL", "NXP_CRELAT"), "NRJ_DESC")

 		Case "NXP_DMOE" $ cCampo
			cRet :=  JurGetDados("CTO", 1, xFilial("CTO") + oModel:GetValue("NXPDETAIL", "NXP_CMOE"), "CTO_SIMB")

 		Case "NXP_DAGENC" $ cCampo
			cRet :=  JurGetDados("SA6", 1, xFilial("SA6") + oModel:GetValue("NXPDETAIL", "NXP_CBANCO") + oModel:GetValue("NXPDETAIL", "NXP_CAGENC") + oModel:GetValue("NXPDETAIL", "NXP_CCONTA"), "A6_NOMEAGE")

 		Case "NXP_DBANCO" $ cCampo
			cRet :=  JurGetDados("SA6", 1, xFilial("SA6") + oModel:GetValue("NXPDETAIL", "NXP_CBANCO") + oModel:GetValue("NXPDETAIL", "NXP_CAGENC") + oModel:GetValue("NXPDETAIL", "NXP_CCONTA"), "A6_NOME")

 		Case "NXP_DCDPGT" $ cCampo
			cRet :=  JurGetDados("SE4", 1, xFilial("SE4") + oModel:GetValue("NXPDETAIL", "NXP_CCDPGT"), "E4_DESCRI")

 		Case "NXP_DCONT" $ cCampo
			cRet :=  JurGetDados("SU5", 1, xFilial("SU5") + oModel:GetValue("NXPDETAIL", "NXP_CCONT"), "U5_CONTAT")

 		Case "NXP_DCLIPG" $ cCampo
			cRet :=  JurGetDados("SA1", 1, xFilial("SA1") + oModel:GetValue("NXPDETAIL", "NXP_CLIPG") + oModel:GetValue("NXPDETAIL", "NXP_LOJAPG"), "A1_NOME")

		Case  "NVN_DCONT" $ cCampo
			cRet :=  JurGetDados("SU5", 1, xFilial("SU5") + oModel:GetValue("NVNDETAIL", "NVN_CCONT"), "U5_CONTAT")

		Case  "NT5_DIDIOM" $ cCampo
			cRet :=  JurGetDados("NR1", 1, xFilial("NR1") + oModel:GetValue("NT5DETAIL", "NT5_CIDIOM"), "NR1_DESC")

		Case  "NTJ_DTPATV" $ cCampo
			cRet :=  JurGetDados("NRC", 1, xFilial("NRC") + oModel:GetValue("NTJDETAIL", "NTJ_CTPATV"), "NRC_DESC")

		Otherwise
			cRet :=  ""
	EndCase

Return cRet

//-------------------------------------------------------------------
/*/{Protheus.doc} J96VldTpVl
Validação do campo “Tipo Valor” (NTR_TPVL) do cadastro de Faixa de
Faturamento.

@author Cristina Cintra Santos
@since 03/02/2014
@version 1.0
/*/
//-------------------------------------------------------------------
Function J96VldTpVl()
Local lRet      := .T.
Local cTpHon    := FwFldGet('NT0_CTPHON')
Local oModel    := FWModelActive()
Local cCalFX    := FwFldGet('NT0_CALFX')
Local cTpVl     := FwFldGet('NTR_TPVL')

If !Empty(cCalFX) .Or. (JUR96TPFIX(cTpHon) .And. JUR96FAIXA(cTpHon))
	If cCalFX == '1' .And. ( cTpVl == '2' .Or. cTpVl == '4' )
		lRet := JurMsgErro(STR0165) //Quando utilizado o Cálculo de Faixa 'Valor' só serão permitidos os Tipos 1=Valor Fixo e 3=% a Cobrar. Corrija o campo 'Calc Faixa' ou escolha outra opção no 'Tipo Valor'.
	ElseIf cCalFX == '2' .And. ( cTpVl == '2' )
		lRet := JurMsgErro(STR0166) //Quando utilizado o Cálculo de Faixa 'Hora' só serão permitidos os Tipos 1=Valor Fixo, 3=% a Cobrar e 4=Tab Honorários. Corrija o campo 'Calc Faixa' ou escolha outra opção no 'Tipo Valor'.
	ElseIf (JUR96TPFIX(cTpHon) .And. JUR96FAIXA(cTpHon)) .And. ( cTpVl == '3' .Or. cTpVl == '4' )
		lRet := JurMsgErro(STR0167) //Quando utilizado o tipo de Faixa 'Quantidade de Casos' só serão permitidos os Tipos 1=Valor Fixo e 2=Valor Unitário.
	EndIf
Else
	lRet := JurMsgErro(STR0168) //"Preencha o campo de Cálculo de Faixa antes de preencher o Tipo de Valor."
EndIf

//Efetua a limpeza dos campos de tabela de honorários / valor util de faixas, de acordo com o conteúdo do Tipo de Valor
If lRet .And. !Empty(cTpVl)
	If cTpVl <> '4' .And. !Empty(FwFldGet("NTR_CTABH"))
		oModel:ClearField("NTRDETAIL", "NTR_CTABH")
		oModel:ClearField("NTRDETAIL", "NTR_DTABH")
	EndIf

	If cTpVl == '4' .And. !Empty(FwFldGet("NTR_VALOR"))
		oModel:ClearField("NTRDETAIL", "NTR_VALOR")
	EndIf
EndIf

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} JVldCalFx
Validação do campo “Calc Faixa” (NT0_CALFX) do cadastro de Faixa de
Faturamento.

@author Cristina Cintra Santos
@since 11/02/2014
@version 1.0
/*/
//-------------------------------------------------------------------
Function JVldCalFx()
Local lRet      := .T.
Local oModel    := FWModelActive()
Local oModelNTR := oModel:GetModel('NTRDETAIL')
Local lSmartUI  := FindFunction("JurIsSmartUI") .And. JurIsSmartUI() // Proteção @12.1.2410

	If !lSmartUI .And. ((oModelNTR:GetQtdLine() > 1 .And. !oModelNTR:IsDeleted()) .Or. (!oModelNTR:IsEmpty() .And. !Empty(oModelNTR:GetValue("NTR_TPVL")) .And. !oModelNTR:IsDeleted()))
		lRet := JurMsgErro(STR0169) //"Só é possível alterar o Cálculo da Faixa quando não houverem registros na grid de Faixas de Valores."
	EndIf

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} J96AltParc(oModel)
Rotina para permitir a alteração do grid de parcelas de fixo de
forma manual quando no tipo de honorários, a parcela não for automática
e a cobrança de honorários não estiver encerrada.

@Return	lRet	.T. quando permite inclusão/alteração manual está permitida.

@author Luciano Pereira dos Santos
@since 21/11/2014
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function J96AltParc(oModel)
Local aArea     := GetArea()
Local lRet      := .T.
Local oModelNT0 := oModel:GetModel('NT0MASTER')
Local oModelNT1 := oModel:GetModel('NT1DETAIL')
Local lParcAut  := .F.
Local lEncHon   := .F.

//Verifica se a cobranca honorarios está encerrada no contrato
lEncHon := oModelNT0:GetValue('NT0_ENCH') == '1'

//Verifica se o tipo de honorario é parcela automatica
lParcAut := JurGetDados("NRA", 1, xFilial("NRA") + oModelNT0:GetValue('NT0_CTPHON'), "NRA_PARCAT" ) == '1'

If lParcAut .Or. lEncHon
	oModelNT1:SetNoDeleteLine(.T.)
	oModelNT1:SetNoInsertLine(.T.)
	lRet := .F.
Else
	oModelNT1:SetNoDeleteLine(.F.)
	oModelNT1:SetNoInsertLine(.F.)
	lRet := .T.
EndIf

RestArea( aArea )

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} J96VerPreFat
Esta função refere-se ao Requisito 003232 - Roadmap 2014  e tem por
objetivo validar e definir tratamentos para a alteração das parcelas
das condições de faturamento, com base na situação de uma pré-fatura,
caso exista.

@param oModel    , Modelo de Dados
@param nLineNT1  , Linha corrente na NT1 (parcela fixa)
@param lCanPreFat, Se cancela pré-fatura vinculada ao contrato
                   (enviado pelo SmartUI)
@param lSmartUI  , Execução vis Smart UI
@param cMsgPrefat, Variável para armazenar a mensagen de validação
                   se deseja cancelar a pré-fatura (utilizado no SmartUI)
@param cMsg      , Variável para armazenar as mensagens de informativas
                   quando a chamada for do SmartUI
@param aMsgParc  , Tratamento de mensagens para ser demonstrado no SmartUI
@return lRet     , Indica se o contrato foi ajustado e está válido

@author Julio de Paula Paz
@since  26/03/2014 
/*/
//-------------------------------------------------------------------
Function J96VerPreFat(oModel, nLineNT1, lCanPreFat, lSmartUI, cMsgPrefat, cMsg, aMsgParc)
Local lRet      := .T.
Local lCanNWE   := .F.
Local oModelNT1 := oModel:Getmodel('NT1DETAIL')
Local lBOK      := FwIsInCallStack("JUR96BOK")
Local lBtnCorr  := FwIsInCallStack("J96CorrCDF")
Local lParcAuto := J96TPHPAut(oModel:GetValue("NT0MASTER", 'NT0_CTPHON'))
Local cPreFat   := oModelNT1:GetValue('NT1_CPREFT', nLineNT1)
Local cParcela  := oModelNT1:GetValue('NT1_PARC'  , nLineNT1)
Local cParcSit  := oModelNT1:GetValue('NT1_SITUAC', nLineNT1)
Local cDtRefIni := oModelNT1:GetValue('NT1_DATAIN', nLineNT1)
Local cDtRefFim := oModelNT1:GetValue('NT1_DATAFI', nLineNT1)
Local aArea     := {}
Local aAreaNX0  := {}
Local cSituacao := ""
Local nPos      := 0

Default lCanPreFat := .F.
Default lSmartUI   := FindFunction("JurIsSmartUI") .And. JurIsSmartUI() // Proteção @12.1.2410
Default cMsgPrefat := ""
Default cMsg       := ""
Default aMsgParc   := {}

NX0->(DbSetOrder(1)) // NX0_FILIAL+NX0_COD+NX0_SITUAC

If oModelNT1:IsUpdated() .Or. lParcAuto
	aArea     := GetArea()
	aAreaNX0  := NX0->(GetArea())
	If lBOK .Or. lBtnCorr .Or. lSmartUI
		If lBOK
			// Quando a J96VerPreFat é chamada pela JUR96BOK, o grid não está posicionado,
			// e é necessário posicionar para a execução da função abaixo (J96VerAltM)
			oModelNT1:GoLine(nLineNT1)
		EndIf
		If cParcSit == '1' .And. NX0->(DbSeek(xFilial("NX0") + cPreFat))
			cSituacao := tabela("JS", NX0->NX0_SITUAC, .F.)

			// Análise, Alterada, Minuta cancelada, Minuta sócio Cancelada
			// Revisada e Revisada com Restrições
			If AllTrim(NX0->NX0_SITUAC) $ "2|3|7|B|D|E"
				If (cDtRefIni < NX0->NX0_DINIFX .OR. cDtRefFim > NX0->NX0_DFIMFX)
					//"O período da parcela #1 se encontra fora do período da pré-fatura #2 ( Data inicial: #3 e Data final: #4 ),
					//confirmando a alteraçao a pré-fatura será cancelada. Deseja continuar?"
					If lSmartUI
						cMsgPrefat := I18n(STR0269, {AllTrim(cParcela), cPreFat, DTOC(NX0->NX0_DINIFX), DTOC(NX0->NX0_DFIMFX)})
					EndIf
					If (lSmartUI .And. lCanPreFat) .Or. (!lSmartUI .And. ApMsgYesNo(I18n(STR0269, { AllTrim(cParcela), cPreFat, DTOC(NX0->NX0_DINIFX), DTOC(NX0->NX0_DFIMFX) })))
						If JA202CANPF(cPreFat)
							J202HIST('5', cPreFat, JurUsuario(__CUSERID), I18n(STR0271, { AllTrim(cParcela) } ), '7') //Insere o Histórico na pré-fatura
							lCanNWE := .T.
						EndIf
					Else
						lRet := .F.
					EndIf
				EndIf
				If AllTrim(NX0->NX0_SITUAC) $ "2|7|B|D|E"
					// "A parcela #1 está vinculada à pré-fatura #2 que ficará com a situação 'Alterada'. 
					//  Para que os ajustes sejam refletidos nela, utilize a opção 'Refazer' na tela de Operações de Pré-fatura."
					cMsg := I18N(STR0270, {AllTrim(cParcela), cPreFat})
					aAdd(aMsgParc, JSonObject():New())
					nPos := Len(aMsgParc)
					aMsgParc[nPos]["legenda"]       := "3" // Sucesso
					aMsgParc[nPos]["status"]        := "1" // Código da mensagem a ser retornada para o front (utilizado como agrupador)
					aMsgParc[nPos]["codPreFatura"]  := cPreFat
					aMsgParc[nPos]["situacao"]      := I18n(STR0272, {AllTrim(cSituacao)}) // "Parcelas que estão vinculadas a pré-faturas com situação #1 ficarão com a situação 'Alterada'. Para que os ajustes sejam refletidos nela(s), utilize a opção 'Refazer' na tela de Operações de Pré-fatura."
					aMsgParc[nPos]["msgParcela"]    := cMsg
					aMsgParc[nPos]["numeroParcela"] := cParcela
					UpdPreFat('3')
				EndIf
			ElseIf AllTrim(NX0->NX0_SITUAC) == '6' // Minuta Emitida
				lRet := J96VerAltM(oModelNT1)
				If (!lRet)
					cMsg := STR0180 + AllTrim(cParcela) + STR0181 + cPreFat + STR0182 + AllTrim(cSituacao) + STR0184
					aAdd(aMsgParc, JSonObject():New())
					nPos := Len(aMsgParc)
					aMsgParc[nPos]["legenda"]       := "2" // Informação
					aMsgParc[nPos]["status"]        := "2"
					aMsgParc[nPos]["codPreFatura"]  := cPreFat
					aMsgParc[nPos]["situacao"]      := I18n(STR0273, {AllTrim(cSituacao)}) // "Parcelas que estão vinculadas a pré-faturas com situação #1 não poderá ser alterada."
					aMsgParc[nPos]["msgParcela"]    := cMsg
					aMsgParc[nPos]["numeroParcela"] := cParcela
				EndIf
			ElseIf AllTrim(NX0->NX0_SITUAC) $ "4|5|9|A|C|F" .And. !J96VerAltM(oModelNT1) // Emitir Fatura - Emitir Minuta - Minuta Cancelada - Minuta Sócio - Minuta Sócio Emitida - Minuta Sócio Cancelada - Em Revisão - Aguardando Sincronização e houve alteração na NT1
				cMsg := STR0180 + AllTrim(cParcela) + STR0181 + cPreFat + STR0182 + AllTrim(cSituacao) + STR0184
				aAdd(aMsgParc, JSonObject():New())
				nPos := Len(aMsgParc)
				aMsgParc[nPos]["legenda"]       := "2" // Informação
				aMsgParc[nPos]["codPreFatura"]  := cPreFat
				aMsgParc[nPos]["status"]        := "3"
				aMsgParc[nPos]["msgAgrupada"]   := I18n(STR0273, {AllTrim(cSituacao)}) // "Parcelas que estão vinculadas a pré-faturas com situação #1 não poderá ser alterada."
				aMsgParc[nPos]["msgParcela"]    := cMsg
				aMsgParc[nPos]["numeroParcela"] := cParcela
				lRet := .F.
			EndIf

			If lCanNWE
				J096CanNWE(oModel, cPreFat) // Cancela linhas na NWE
			EndIf

		EndIf
	EndIf
	
	RestArea(aAreaNX0)
	RestArea(aArea)

EndIf

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} UpdPreFat(cNovaSit)
Atualiza o Status da Pré-Fatura

@param cNovaSit - Nova situação

@author Willian Kazahaya
@since 27/10/2023
/*/
//-------------------------------------------------------------------
Static Function UpdPreFat(cNovaSit)
Local cJurUser   := JurUsuario(__CUSERID)

	RecLock( "NX0", .F. )
	NX0->NX0_SITUAC := cNovaSit
	NX0->NX0_USRALT := cJurUser
	NX0->NX0_DTALT  := Date()

	NX0->(MsUnLock())
	NX0->(DbCommit())
Return 

//-------------------------------------------------------------------
/*/{Protheus.doc} J96VerAltM(oModelNT1)
Verifica os campos que foram alterados

@param oModelNT1 - Modelo do Contrato Fixo

@author Willian Kazahaya
@since 26/01/2022
/*/
//-------------------------------------------------------------------
Static Function J96VerAltM(oModelNT1)
Return JVldAltMdl(oModelNT1, 1, {"NT1_DESCRI"}, .T.)

//-------------------------------------------------------------------
/*/{Protheus.doc} J096CanNWE()
Cancela linhas de faturamento das parcelas de fixo (NWE)

@param oModel,  Modelo de dados do Contrato
@param cPreFat, Código da Pré-Fatura

@author Abner Oliveira, Jorge Martins, Victor Hayashi
@since  06/10/2020
/*/
//-------------------------------------------------------------------
Static Function J096CanNWE(oModel, cPreFat)
	Local oModelNWE := oModel:GetModel("NWEDETAIL")
	Local nLine     := 0
	Local nI        := 0

	If !oModelNWE:IsEmpty()
		nLine := oModelNWE:GetLine()
		For nI := 1 To oModelNWE:Length()
			If oModelNWE:GetValue('NWE_PRECNF', nI) == cPreFat
				oModelNWE:GoLine(nI)
				J096SetNo(oModelNWE, .F.)
				oModelNWE:LoadValue("NWE_CANC", "1")
				J096SetNo(oModelNWE, .T.)
			EndIf
		Next nI
		oModelNWE:Goline(nLine)
	EndIf

Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} J96PICTPFX()
Verifica se o tipo de honorários é por faixa de faturamento usando
Quantidade de Casos ou Hora/Valor. Quando se tratar de Quantidade de
Casos, a picture deverá ser alterada para formato sem decimais.
Usado no X3_PICTVAR dos campos NTR_VLINI e NTR_VLFIM.
Caso seja feita alteração nas casas decimais, necessário ajustar a
função JVldPerFx.

@Return cRet	Máscara para os campos NTR_VLINI e NTR_VLFIM

@author Cristina Cintra Santos
@since 26/03/2014
@version 1.0
/*/
//-------------------------------------------------------------------
Function J96PICTPFX()
Local cRet := AllTrim(X3Picture('NTR_VLINI'))

If JUR96FAIXA() // Quantidade de Casos
	cRet := SubStr(cRet, 1, At(".", cRet) - 1)
EndIf

Return cRet

//-------------------------------------------------------------------
/*/{Protheus.doc} J096VldTpH
Executa a inclusão do cadastro de Contrato apenas se existir algum tipo
de honorário cadastrado, pois ele que determina quais campos serão
mostrados no botão. Caso não exista tipo de honorários, propõe a carga
inicial.
Sem esta verificação, quando não há tipo de honorários, os campos de Fixo,
Faixa e Limite são exibidos na tela principal.

@param oModel   Modelo de Dados de Contrato

@return lRet    Indica se o modelo pode ser aberto

@author Cristina Cintra santos
@since 06/08/2014
@version 1.0
/*/
//-------------------------------------------------------------------
Function J096VldTpH(oModel)
Local aArea     := GetArea()
Local aAreaNTH  := NTH->( GetArea() )
Local lRet      := .T.
Local nOpc      := oModel:GetOperation()

If nOpc == 3
	NTH->(DbSetOrder(1)) // NTH_FILIAL+NTH_CTPHON+NTH_CAMPO
	If !(NTH->(DbSeek(xFilial("NTH"))))
		lRet := JurMsgErro(STR0204,,STR0245) //"Não existem tipos de honorários cadastrados, desta forma, não é permitida a manipulação de contratos." - "Efetue a carga inicial."
	EndIf
EndIf

RestArea( aAreaNTH )
RestArea( aArea )

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} J96BOKNTR
Chama a validação para a tabela NTR e verificar se o tipo de honorário informado faz manutenção na tabela NT1.
Caso haja dados na tabela NT1, roda as validações da tabela NT1.

@param nBotao = Referente ao campo NTH_BOTAO
                  1 = Condições de Faturamento de Fixo
                  2 = Faixa de Valores

@author Julio de Paula Paz
@since 09/09/2014
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function J96BOKNTR( oModel, lSubView, nBotao, cId)
Local lRet      := .T.
Local oModelNT1 := oModel:GetModel('NT1DETAIL')

Begin Sequence
	lRet := JUR96BOK( oModel, lSubView, nBotao, cId)

	If !oModelNT1:IsEmpty()
		lRet := JUR96BOK( oModel, lSubView, nBotao, 'NT1DETAIL')
	EndIf

End Sequence

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} J096ObrgOk
Rotina para verificar se todos os campos obrigatorios do modelo MASTER foram
preenchidos antes de abrir a mini view do contrato.

@param oModel     Modelo da dados da tela de contrato
@param aCpoView   Array com os campos da miniViwe
@param cButon     Descrição do Botão da Mini View

@author Luciano Pereira dos Santos
@since 02/09/2014
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function J096ObrgOk(oModel, aCpoView, cButon)
Local lRet      := .T.
Local aArea     := GetArea()
Local oModelNT0 := oModel:GetModel('NT0MASTER')
Local aCampos   := {}
Local nI        := 0
Local cCampo    := ''

aCampos  := JurCpoObrig("NT0")

For nI := 1 To Len(aCampos)

	cCampo := Alltrim(aCampos[nI])

	If !Jur96Exibe( cCampo, aCpoView ) //Se o campo for obrigatório e não está na MiniView

		If Empty( oModelNT0:GetValue(cCampo ) )
			lRet := .F.
			ApMsgStop(I18N(STR0205, {cButon, AVSX3(cCampo)[5] })) // "Antes de clicar em '#1', preencha a informação do campo '#2'."
			Exit
		EndIf

	EndIf

Next nI

RestArea( aArea )

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} J096ClxGr()
Rotina para verificar se o cliente/loja pertence ao grupo.
Usado nos gatilhos de Grupo

@Return - lRet  .T. quando o cliente PERTENCE ao grupo informado OU
                .F. quando o cliente NÃO pertence ao grupo informado

@author Bruno Ritter
@since 04/01/2016
@version 1.0
/*/
//-------------------------------------------------------------------
Function J096ClxGr()
Local lRet     := .F.
Local oModel   := FwModelActive()
Local cGrupo   := ""
Local cClien   := ""
Local cLoja    := ""
Local lSmartUI := FindFunction("JurIsSmartUI") .And. JurIsSmartUI() // Proteção @12.1.2410

If IsInCallStack( 'JURA096' ) .Or. lSmartUI
	cGrupo  :=  oModel:GetValue("NT0MASTER", "NT0_CGRPCL")
	cClien  :=  oModel:GetValue("NT0MASTER", "NT0_CCLIEN")
	cLoja   :=  oModel:GetValue("NT0MASTER", "NT0_CLOJA")

	lRet := JurClxGr(cClien, cLoja, cGrupo)
EndIf

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} J096ClxCa()
Rotina para verificar se o cliente/loja pertece ao caso.
Utilizado para condição de gatilho

@param lNT0     Indica se a chamada é de um campo da NT0. Usado para os
				gatilhos de Caso Mãe

@Return - lRet  .T. quando o cliente PERTENCE ao caso informado OU
                .F. quando o cliente NÃO pertence ao caso informado

@author Bruno Ritter
@since 30/12/2016
@version 1.0
/*/
//-------------------------------------------------------------------
Function J096ClxCa(lNT0)
Local lRet     := .T.
Local oModel   := FwModelActive()
Local cCaso    := ""
Local cClien   := ""
Local cLoja    := ""
Local lSmartUI := FindFunction("JurIsSmartUI") .And. JurIsSmartUI() // Proteção @12.1.2410

Default lNT0  := .F.

If lNT0
	cCaso   :=  oModel:GetValue("NT0MASTER", "NT0_CCLICM")
	cClien  :=  oModel:GetValue("NT0MASTER", "NT0_CLOJCM")
	cLoja   :=  oModel:GetValue("NT0MASTER", "NT0_CCASCM")
ElseIf IsInCallStack( 'JURA096' ) .Or. lSmartUI
	cCaso   :=  oModel:GetValue("NUTDETAIL", "NUT_CCASO")
	cClien  :=  oModel:GetValue("NUTDETAIL", "NUT_CCLIEN")
	cLoja   :=  oModel:GetValue("NUTDETAIL", "NUT_CLOJA")
EndIf

If !Empty(cCaso) .Or. !Empty(cClien) .Or. !Empty(cLoja)
	lRet := JurClxCa(cClien, cLoja, cCaso)
EndIf

Return lRet

//-------------------------------------------------------------------
/*/ { Protheus.doc } JA096COMMIT
Classe interna implementando o FWModelEvent, para execução de função
durante o commit.

@author Cristina Cintra Santos
@since 21/08/2017
@version 1.0
/*/
//-------------------------------------------------------------------
Class JA096COMMIT FROM FWModelEvent
	Method New()
	Method GridLinePosVld()
	Method BeforeTTS()
	Method InTTS()
End Class

Method New() Class JA096COMMIT
Return

Method BeforeTTS(oSubModel, cModelId) Class JA096COMMIT
	JA096CMBEF(oSubModel:GetModel())
Return

//-------------------------------------------------------------------
/*/{Protheus.doc} GridLinePosVld()
Metodo de pos-validação do Grid.

@Param oSubModel, Modelo de dados
@Param cModelID , Id do Modelo de dados

@author Jorge Martins
@since  16/01/2025
/*/
//-------------------------------------------------------------------
Method GridLinePosVld(oSubModel, cModelID) Class JA096COMMIT
Local lRet      := .T.
Local oModel    := Nil
Local oModelNT0 := Nil
Local cContr    := ""
Local lAtivo    := .F.
Local lCobHon   := .F.
Local lCobDsp   := .F.
Local lCobTab   := .F.

Do Case
	Case cModelID == "NUTDETAIL"
		
		oModel    := oSubModel:GetModel()
		oModelNT0 := oModel:GetModel("NT0MASTER")
		lAtivo    := oModelNT0:GetValue("NT0_ATIVO") == "1"

		// A validação da vigencia deve ser feita mesmo com o contrato inativo.
		// Se alterar NUT - Faz a validação nas linhas alteradas (Roda a query p/ as linhas do GetLinesChange)
		lRet := J096VigNUT(oModelNT0, oSubModel, {oSubModel:GetLine()}, .T.) // Faz a validação de vigência nas linhas alteradas (Roda a query p/ as linhas do GetLinesChange)
		
		If lRet .And. (Empty(oModelNT0:GetValue("NT0_DTVIGI")) .And. Empty(oModelNT0:GetValue("NT0_DTVIGF")))
			cContr  := oModelNT0:GetValue("NT0_COD")
			lCobHon := JurGetDados("NRA", 1, xFilial("NRA") + oModelNT0:GetValue("NT0_CTPHON"), "NRA_COBRAH") == "1"
			lCobDsp := oModelNT0:GetValue("NT0_DESPES") == "1"
			lCobTab := oModelNT0:GetValue("NT0_SERTAB") == "1"

			If lAtivo .And. (lCobHon .Or. lCobDsp .Or. lCobTab)
				cMensagem := J096CobNUT(oSubModel, {oSubModel:GetLine()}, cContr, lCobHon, lCobDsp, lCobTab) // Faz a validação da forma de cobrança nas linhas alteradas (Roda a query p/ as linhas do GetLinesChange)

				If !Empty(cMensagem)
					lRet := JurMsgErro( STR0308 + CRLF + CRLF + cMensagem, ,; // "Não é possível vincular esse caso pois o mesmo já está vinculado a um contrato com a mesma forma de cobrança, conforme detalhe abaixo:"
					                   STR0309 ) // "Remova o vínculo do(s) caso(s) citado(s) ou altere a(s) forma(s) de cobrança do contrato."
				EndIf
			EndIf
		EndIf
EndCase

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} InTTS
Método que é chamado pelo MVC quando ocorrer as ações do commit após 
as gravações porém antes do final da transação.

@param oModel   - Modelo de dados de Contrato.
@param cModelId - Identificador do modelo.

@author  Abner Fogaça
@since   26/02/2021
/*/
//-------------------------------------------------------------------
Method InTTS(oModel, cModelId) Class JA096COMMIT
Local cPreFat   := ""
Local cCodContr := ""
Local nPreFat   := 0
Local nOpc      := oModel:GetOperation()

	JA096CMAFT(oModel)
	If !Empty(_aPreFtVld)
		For nPreFat := 1 To Len(_aPreFtVld)
			cPreFat := _aPreFtVld[nPreFat]
			If JA202CANPF(cPreFat) // Cancela Pré-Fatura
				J202HIST('5', cPreFat, JurUsuario(__CUSERID)) // Insere o Histórico na pré-fatura
				J096CanNWE(oModel, cPreFat) // Cancela linhas na NWE (Faturamento do Fixo)
			EndIf
		Next
	EndIf
	
	JFILASINC(oModel, "NT0", "NT0MASTER", "NT0_COD") // Grava na fila de sincronização - Integração LegalDesk

	If nOpc == MODEL_OPERATION_DELETE .And. FindFunction("JExcAnxSinc")
		cCodContr := oModel:GetValue("NT0MASTER", "NT0_COD")
		JExcAnxSinc("NT0", cCodContr) // Exclui os anexos vinculados ao contrato e registra na fila de sincronização
	EndIf

Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} J096VldData()
Valida o período de referência da parcela de fixo em relação ao período de vigência do contrato

@param dDataIni Data de referência inicial da parcela de fixo
@param dDataFim Data de referência final da parcela de fixo

@Return lRet	.T./.F. As informações são válidas ou não

@author Abner Fogaça de Oliveira / Queizy.nascimento
@since 31/10/2018
@version 1.0
/*/
//-------------------------------------------------------------------
Function J096VldData(dDataIni, dDataFim, cParcela, lSmartUI, dDtVigI, dDtVigF, cMsgSmUi)
Local lRet       := .T.
Local oModel     := Nil
Local oModelNT0  := Nil

Default lSmartUI := .F.
Default dDtVigI  := CToD( '  /  /  ' ) 
Default dDtVigF  := CToD( '  /  /  ' ) 
Default dDataIni := CToD( '  /  /  ' )
Default dDataFim := CToD( '  /  /  ' )
Default cMsgSmUi := ""

	If !lSmartUI
		oModel     := FWModelActive()
		oModelNT0  := oModel:GetModel('NT0MASTER')
		dDtVigI    := oModelNT0:GetValue("NT0_DTVIGI")
		dDtVigF    := oModelNT0:GetValue("NT0_DTVIGF")
	EndIf

	If !Empty(dDtVigI) .And. !Empty(dDtVigF) .And. Empty(dDataIni) .And. Empty(dDataFim)
		If dDtVigI > dDtVigF
			If lSmartUI
				cMsgSmUi := STR0239
			Else
				lRet := JurMsgErro(STR0239,, STR0244) // "A data inicial da vigência não pode ser superior que a data final." "Verifique a data de vigência no contrato"
			EndIf
		EndIf
	ElseIf !Empty(dDataIni) .And. !Empty(dDataFim) .And. !Empty(dDtVigI) .And. !Empty(dDtVigF)
		If dDataIni < dDtVigI 
			If lSmartUI
				cMsgSmUi := I18N(STR0242, {cParcela, dDataIni})
			Else
				lRet := JurMsgErro(I18N(STR0242, {cParcela, dDataIni}),, STR0244) // "A parcela '#1' esta com a data inicial '#2' fora do periodo de vigência." "Verifique a data de vigência no contrato"
			EndIf
		ElseIf dDataFim > dDtVigF
			If lSmartUI
				cMsgSmUi := I18N(STR0243, {cParcela, dDataFim})
			Else
				lRet := JurMsgErro(I18N(STR0243, {cParcela, dDataFim}),, STR0244)// "A parcela '#1' esta com a data final '#2' fora do periodo de vigência." "Verifique a data de vigência no contrato"
			EndIf
		EndIf
	EndIf

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} J096VldPer(cAlias,dDtVigI, dDtVigF)
Valida sobreposição do período de vigência do contrato

@param cAlias   alias da tabela NT0 chamada das funções J096VDespTab / J096VlTpHo
@param dDtVigI  Data da vigência inicial
@param dDtVigF  Data da vigência final

@Return aRet    aRet[1] lógico,    Não há período sobrepostos de vigência
                aRet[2] caractere, Mensagem de erro quando houver período sobrepostos

@author Abner Fogaça de Oliveira / Queizy.nascimento
@since 01/11/2018
@version 1.0
/*/
//-------------------------------------------------------------------
Function J096VldPer(cAlias,dDtVigI, dDtVigF)
Local cMsgErro   := ""
Local dDtContIni := IIf(ValType((cAlias)->NT0_DTVIGI) == "C", SToD((cAlias)->NT0_DTVIGI), (cAlias)->NT0_DTVIGI) // Vigência inicial em outro contrato
Local dDtContFim := IIf(ValType((cAlias)->NT0_DTVIGF) == "C", SToD((cAlias)->NT0_DTVIGF), (cAlias)->NT0_DTVIGF) // Vigência final em outro contrato

	//Verifica se a vigência inicial é maior ou igual a alguma vigência final de período posterior
	If (dDtContIni <= dDtVigI) .And. (dDtContFim >= dDtVigI) .And. (dDtContIni != dDtContFim)
		cMsgErro := I18N(STR0234 + CRLF +; // "Períodos sobrepostos na vigência."
						STR0235,; // "A vigência inicial '#1' está sobrepondo a vigência do contrato '#2'."
						{dDtVigI, (cAlias)->NT0_COD}) // "Verifique o período de vigência no contrato."
	EndIf

	//Verifica se a vigência final é maior ou igual a alguma vigência inicial de período posterior
	If (dDtContIni >= dDtVigI) .And. (dDtContIni <=  dDtVigF) .And. (dDtContIni != dDtContFim)
		cMsgErro := I18N(STR0234 + CRLF +; // "Períodos sobrepostos na vigência."
						STR0236,; // "A vigência final '#1' está sobrepondo a vigência do contrato '#2'."
						{dDtVigF,(cAlias)->NT0_COD}) // "Verifique o período de vigência no contrato."
	EndIf

	If Empty(dDtContIni) .And.  Empty(dDtContFim) .And. !Empty(dDtVigI) .And. !Empty(dDtVigF)
		cMsgErro := I18N(STR0237,; // Não é permitido vincular o caso '#1' a um contrato com vigência, pois o mesmo está vinculado ao contrato '#2' que não possui vigência preenchida.
						{(cAlias)->NUT_CCASO,(cAlias)->NT0_COD}) 
	EndIf

	If Empty(dDtVigI) .And.  Empty(dDtVigF) .And. !Empty(dDtContIni) .And. !Empty(dDtContFim)
		cMsgErro := I18N(STR0238,; // Não é permitido vincular o caso '#1' a um contrato sem vigência, pois o mesmo está vinculado ao contrato '#2' que possui vigência preenchida.
						{(cAlias)->NUT_CCASO,(cAlias)->NT0_COD})
	EndIf

Return cMsgErro

//-------------------------------------------------------------------
/*/{Protheus.doc} J096VigPar
Percorre as parcelas para validar a data de vigência do contrato

@param oModel, Modelo do contrato

@Return lRet,  Se está tudo ok

@author Bruno Ritter
@since 09/11/2018
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function J096VigPar(oModel)
	Local lRet      := .T.
	Local lCobFixo  := JUR96TPFIX(oModel:GetValue('NT0MASTER','NT0_CTPHON'))
	Local oModelNT1 := oModel:GetModel('NT1DETAIL')
	Local nTotalLn  := oModelNT1:GetQTDLine()
	Local nLn       := 0

	If lCobFixo
		For nLn := 1 To nTotalLn
			If !J096VldData(oModelNT1:GetValue("NT1_DATAIN", nLn),;
			                oModelNT1:GetValue("NT1_DATAFI", nLn),;
			                oModelNT1:GetValue("NT1_PARC", nLn) )
				lRet := .F.
				Exit
			EndIf
		Next nLn
	EndIf

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} J096NT1Whn()
Rotina de modo de edição (When) da tabela de parcela de fixo.

@author Luciano Pereira dos Santos
@since 20/02/2019
/*/
//-------------------------------------------------------------------
Function J096NT1Whn()
Local lRet    := .F.
Local cCampo  := Alltrim(StrTran(ReadVar(), 'M->', ''))
Local oModel  := FwModelActive()

If oModel:GetID() == 'JURA096'
	If cCampo == "NT1_DESCRI"
		lRet := oModel:GetValue("NT1DETAIL", "NT1_SITUAC") == "1" 
	ElseIf cCampo == "NT1_TKRET"
		lRet := !Empty(oModel:GetValue("NT1DETAIL", "NT1_CPREFT")) 
	EndIf

ElseIf oModel:GetID() == 'JURA202'
	If cCampo $ "NT1_INSREV|NT1_REVISA|NT1_DESCRI|NT1_CTPFTU"
		lRet := Iif(FindFunction("JurIsRest"), JurIsRest(), .F.)
	EndIf
EndIf

Return lRet

//------------------------------------------------------------------------------
/*/{Protheus.doc} JA96NUTLoad
Função para carregar o grid de casos através de query.

@param  oModelGrid, Objeto com a estrutura do modelo de dados
@param  lLoad     , Indica se irá carregar

@author Jonatas Martins
@since  18/01/2021
/*/
//------------------------------------------------------------------------------
Static Function JA96NUTLoad(oModelGrid, lLoad)
Local aArea     := GetArea()
Local cQueryNUT := ""
Local aValues   := {}
Local aData     := {}
Local aStruTmp  := {}
Local aRelacao  := {}
Local cAlsTmp   := GetNextAlias()
Local cCampos   := J96GetCpo(oModelGrid, @aRelacao)
Local xValor    := Nil
Local nPosRel   := 0
Local nCpo      := 0
Local nOpc      := 0

	cQueryNUT := "SELECT " + cCampos + ", NUT.R_E_C_N_O_ RECNO"
	cQueryNUT +=  " FROM " + RetSqlName("NUT") + " NUT"
	cQueryNUT += " INNER JOIN " + RetSqlName("SA1") + " SA1"
	cQueryNUT +=    " ON SA1.A1_FILIAL = '" + xFilial("SA1") + "'"
	cQueryNUT +=   " AND SA1.A1_COD = NUT.NUT_CCLIEN"
	cQueryNUT +=   " AND SA1.A1_LOJA = NUT.NUT_CLOJA"
	cQueryNUT +=   " AND SA1.D_E_L_E_T_ = ' ' "
	cQueryNUT += " INNER JOIN " + RetSqlName("NVE") + " NVE"
	cQueryNUT +=    " ON NVE.NVE_FILIAL = '" + xFilial("NVE") + "'"
	cQueryNUT +=   " AND NVE.NVE_CCLIEN = NUT.NUT_CCLIEN"
	cQueryNUT +=   " AND NVE.NVE_LCLIEN = NUT.NUT_CLOJA"
	cQueryNUT +=   " AND NVE.NVE_NUMCAS = NUT.NUT_CCASO"
	cQueryNUT +=   " AND NVE.D_E_L_E_T_ = ' '"
	cQueryNUT +=  " LEFT JOIN " + RetSqlName("RD0") + " RD0"
	cQueryNUT +=    " ON RD0.RD0_FILIAL = '" + xFilial("RD0") + "'"
	cQueryNUT +=   " AND RD0.RD0_CODIGO = NVE.NVE_CPART1 "
	cQueryNUT +=   " AND RD0.D_E_L_E_T_ = ' ' "
	cQueryNUT += " WHERE NUT_FILIAL = '" + xFilial("NUT") + "'"
	cQueryNUT +=   " AND NUT.NUT_CCONTR = '" + NT0->NT0_COD + "'"
	cQueryNUT +=   " AND NUT.D_E_L_E_T_ = ' '"

	DbUseArea(.T., "TOPCONN", TcGenQry(,, cQueryNUT), cAlsTmp, .T., .T.)

	If Empty(aRelacao)
		aData := FwLoadByAlias(oModelGrid, cAlsTmp, "NUT")
	Else
		aStruTmp := (cAlsTmp)->(DbStruct())
		NUT->(DbSetOrder(1))

		// Necessário para situações onde existam campos customizados
		// e seja uma operação via REST (LegalDesk)
		If Type("INCLUI") == "U" .Or. Type("ALTERA") == "U"
			nOpc   := oModelGrid:GetModel():GetOperation()
			INCLUI := nOpc == MODEL_OPERATION_INSERT
			ALTERA := nOpc == MODEL_OPERATION_UPDATE
		EndIf

		While (cAlsTmp)->(! EOF())

			For nCpo := 1 To Len(aStruTmp)
				cCampo  := aStruTmp[nCpo][1]
				
				If cCampo != "RECNO"
					nPosRel := aScan(aRelacao, {|x| x[1] == cCampo})
					
					If nPosRel
						NUT->(DbGoTo((cAlsTmp)->RECNO))
						xValor := &(aRelacao[nPosRel][2])
					Else
						xValor := (cAlsTmp)->(FieldGet(FieldPos(cCampo)))
					EndIf
				
					Aadd(aValues, xValor)
				EndIf
			Next nCpo

			Aadd(aData, {(cAlsTmp)->RECNO, aValues})
			aValues := {}

			(cAlsTmp)->(DbSkip())
		EndDo
	EndIf

	(cAlsTmp)->(DbCloseArea())

	JurFreeArr(@aRelacao)

	RestArea(aArea)

Return (aData)

//------------------------------------------------------------------------------
/*/{Protheus.doc} J96GetCpo
Monta string de campos para query de load do grid de casos NUT

@param      oModelGrid, Objeto com a estrutura do modelo de dados
@return     aRelacao  , Array com inicializador padrão dos campos virtuais

@author     Jonatas Martins
@since      18/01/2021
@obs        Sempre que criar um novo campo virtual necessário atualizar o de para nessa função
/*/
//------------------------------------------------------------------------------
Static Function J96GetCpo(oModelGrid, aRelacao)
	Local oStructGrid := oModelGrid:GetStruct()
	Local aFieldsGrid := oStructGrid:GetFields()
	Local cField      := ""
	Local cCampos     := ""
	Local nCpo        := 0

	For nCpo := 1 To Len(aFieldsGrid)
		cField := aFieldsGrid[nCpo][MODEL_FIELD_IDFIELD]
		
		Do Case
			Case cField == "NUT_DCLIEN"
				cCampos += "SA1.A1_NOME " + cField

			Case cField == "NUT_DCASO"
				cCampos += "NVE.NVE_TITULO " + cField

			Case cField == "NUT_SIGLA"
				cCampos += "RD0.RD0_SIGLA " + cField

			Case cField == "NUT_CPART1"
				cCampos += "RD0.RD0_CODIGO " + cField

			Case cField == "NUT_DPART1"
				cCampos += "RD0.RD0_NOME " + cField

			Case aFieldsGrid[nCpo][MODEL_FIELD_VIRTUAL]
				cCampos += "' ' " + cField

				If GetSx3Cache(cField, "X3_PROPRI") == "U" // Campo virtual de usuário
					Aadd(aRelacao, {cField, GetSx3Cache(cField, "X3_RELACAO")})
				EndIf

			OtherWise
				cCampos += cField
		End Case
		
		cCampos += ", "

	Next nCpo

	cCampos := SubStr(cCampos, 1, Len(cCampos) - 2)

Return (cCampos)

//-------------------------------------------------------------------
/*/{Protheus.doc} JA096VlSit
Valida a situacao do Cliente/Caso x Situacao do contrato 

@param oModel, objeto, Estrutura do modelo de dados de contrato

@author Jonatas Martins / Jorge Martins
@since  26/01/2021
/*/
//-------------------------------------------------------------------
Static Function JA096VlSit(oModel)
Local aArea      := GetArea()
Local aAreaNVE   := NVE->( GetArea() )
Local oModelNUT  := Nil
Local lRet       := .T.
Local lLojaAuto  := .F.
Local aRet       := {}
Local cMsgSitCas := ""
Local cCliProv   := ""
Local cCasos     := ""
Local cTxt       := ""
Local cTitCpos   := ""
Local nLine      := 0
Local nQtdLines  := 0
Local lAltSit    := .T.
Local cSituac    := AllTrim(NT0->NT0_SIT)
Local cFilNUH    := ""

	If Empty(cSituac) .And. oModel:GetOperation() == 4
		NT0->(DbGoTo(oModel:GetModel("NT0MASTER"):GetDataId()))
		cSituac := NT0->NT0_SIT
	EndIf

	lAltSit := oModel:GetOperation() == 3 .Or. (oModel:GetOperation() == 4 .And. oModel:GetValue("NT0MASTER", "NT0_SIT") <> cSituac)

	If NVE->(ColumnPos("NVE_SITCAD")) > 0 .And. oModel:GetValue("NT0MASTER", "NT0_SIT") == "2"
		// Atualiza os casos provisórios para definitivo
		oModelNUT := oModel:GetModel("NUTDETAIL")
		nQtdLines := oModelNUT:GetQtdLine()
		lLojaAuto := SuperGetMv( "MV_JLOJAUT", .F., "2", ) == "1" // Indica se a Loja do Caso deve ser preenchida automaticamente. (1-Sim; 2-Não)
		cFilNUH   := xFilial("NUH")

		For nLine := 1 To nQtdLines
			// Se a linha não estiver deletada E (houve alteração da situação do contrato OU inclusão/alteração da linha)
			If !oModelNUT:IsDeleted(nLine) .And. (lAltSit .Or. (oModelNUT:IsInserted(nLine) .Or. oModelNUT:IsUpdated(nLine)))
				cCliente := oModelNUT:GetValue("NUT_CCLIEN", nLine)
				cLoja    := oModelNUT:GetValue("NUT_CLOJA" , nLine)
				cCaso    := oModelNUT:GetValue("NUT_CCASO" , nLine)

				If NUH->NUH_COD == cCliente .And. NUH->NUH_LOJA == cLoja
					cSitCli := NUH->NUH_SITCAD
				Else
					cSitCli := Posicione("NUH", 1, cFilNUH + cCliente + cLoja, "NUH_SITCAD")
				EndIf

				If cSitCli == "1" // Cliente Provisório
					cTxt := cCliente + IIf(lLojaAuto, "", " - " + cLoja)
					If !(cTxt $ cCliProv)
						cCliProv += cTxt + CRLF
					EndIf
				ElseIf Empty(cCliProv) .And. Posicione("NVE", 1, cFilNUH + cCliente + cLoja + cCaso, "NVE_SITCAD") == "1" // Caso Provisório
					Aadd(aRet, {cCliente, cLoja, cCaso, cSitCli})
					cCasos  += cCliente + IIf(lLojaAuto, "", " - " + cLoja) + " - " + cCaso + CRLF
				EndIf
			EndIf
		Next nLine
		
		If !Empty(cCliProv) // Clientes provisórios que impedem a confirmação do cadastro
			lRet := JurMsgErro(STR0256,, STR0257 + CRLF + cCliProv) // "Não é permitido o uso de clientes com situação provisória em contrato definitivo." # "Ajuste a situação no cadastro do(s) cliente(s) abaixo: " 
		ElseIf !Empty(cCasos) // Casos que serão alterados
			cTitCpos   := RetTitle("NUT_CCLIEN") + " - " + RetTitle("NUT_CLOJA") + " - " + RetTitle("NUT_CCASO")
			cMsgSitCas := STR0254 + CRLF + CRLF + cTitCpos + CRLF + cCasos // "A situação dos casos abaixo será alterada para definitiva."
			_aSitCasos := {cMsgSitCas, aRet}
		EndIf

	EndIf

	RestArea( aAreaNVE )
	RestArea( aArea )

Return lRet


//-------------------------------------------------------------------
/*/{Protheus.doc} JF3NT0
Consulta padrão de contratos

@param aFields   , array, Array de campos
@param lShow     , boolean, Indica se o formulário deve ser exibido
@param lInsert   , boolean, Indica se o usuário pode incluir novo registro
@param cFilter   , string, Filtro de pesquisa
@param lPreload  , boolean, Indica se o grid deve ser pré-carregado

@return lRet     , boolean, Indica se houve sucesso na consulta

@since  14/03/2022
/*/
//-------------------------------------------------------------------
Function JF3NT0(aFields, lShow, lInsert, cFilter, lPreload)
Local   lRet     := .F.
Default cFilter  := ""
Default lInsert  :=.F.
Default lShow    :=.T.
Default lPreload :=.T.
Default aFields  := {"NT0_COD", "NT0_NOME", "NT0_CGRPCL", "NT0_CCLIEN", "NT0_CLOJA"}

	If IsInCallStack('JURA033')
		cFilter  := "@#JA033F3NT0()"
	ElseIf ReadVar() == "M->NW2_CCONSU"
		If !Empty(FWFldGet("NW2_CGRUPO"))
			cFilter +=     " NT0.NT0_CGRPCL = '" + FWFldGet("NW2_CGRUPO") + "' "
		ElseIf !Empty(FWFldGet("NW2_CCLIEN")) .And. !Empty(FWFldGet("NW2_CLOJA"))
			cFilter +=     " NT0.NT0_CCLIEN = '" + FWFldGet("NW2_CCLIEN") + "' "
			cFilter += " AND NT0.NT0_CLOJA = '" + FWFldGet("NW2_CLOJA") + "' "
		EndIf
	ElseIf ReadVar() == "M->NW3_CCONTR"
		cFilter :=     " NOT EXISTS ( SELECT NW3a.R_E_C_N_O_ "
		cFilter +=                       " FROM " + RetSqlName("NW3") + " NW3a "
		cFilter +=                       " WHERE NW3a.D_E_L_E_T_ = ' ' "
		cFilter +=                         " AND NW3a.NW3_FILIAL = '" + xFilial( "NW3" ) + "' "
		cFilter +=                         " AND NW3a.NW3_CCONTR = NT0.NT0_COD )"
	Else
		cFilter  := "@#JURNT0()"
	EndIf
	lRet := JURSXB("NT0", "J96NT0", aFields, lShow, lInsert , cFilter, "JURA096", lPreload)

Return lRet
//-------------------------------------------------------------------
/*/{Protheus.doc} JA096VlCon
Busca despesas pendentes relacionadas a todos os casos relacionados ao contrato

@author Carolina Neiva
@since  25/08/2022
/*/
//-------------------------------------------------------------------
Function JA096VlCon()
Local lAviso    := .F.
Local cQuery    := ''
Local cResQRY   := ''
Local oModel    := FWModelActive()
Local oModelNT0 := oModel:GetModel("NT0MASTER" )
Local oModelNUT := oModel:GetModel("NUTDETAIL" )
Local nQtdLines := oModelNUT:GetQtdLine()
Local cAviso    := STR0263 // "Existem despesas pendentes relacionadas a casos deste contrato. Caso deseje cancelar o encerramento de despesas, retorne o campo para '2-Não'."
Local nI        := 0
Local cTitle    := STR0264 // "Despesas Pendentes"

	If ( oModelNT0:GetValue("NT0_ENCD") == '1' ) 

		For nI := 1 To nQtdLines

			If !oModelNUT:IsDeleted(nI)

				cCliente := oModelNUT:GetValue("NUT_CCLIEN", nI)
				cLoja    := oModelNUT:GetValue("NUT_CLOJA", nI)
				cCaso    := oModelNUT:GetValue("NUT_CCASO", nI)

			
				cQuery := " SELECT COUNT(NVY.NVY_CCASO) COUNTDES "
				cQuery +=   " FROM " + RetSqlName( "NVY" ) + " NVY "
				cQuery +=  " WHERE NVY.D_E_L_E_T_ = ' '
				cQuery +=    " AND NVY.NVY_FILIAL = '" + xFilial( "NT0" ) + "' "
				cQuery +=    " AND NVY.NVY_CCLIEN = '" + cCliente + "' "
				cQuery +=    " AND NVY.NVY_CLOJA  = '" + cLoja + "' "
				cQuery +=    " AND NVY.NVY_CCASO  = '" + cCaso + "' "
				cQuery +=    " AND NVY.NVY_SITUAC = '1' "

				cQuery := ChangeQuery(cQuery)

				cResQRY := GetNextAlias()
				dbUseArea(.T., "TOPCONN", TcGenQry(,, cQuery), cResQRY, .T., .T.)

				lAviso := (cResQRY)->COUNTDES > 0
				(cResQRY)->(dbCloseArea())

				If lAviso
					Exit
				EndIf

			EndIf

		Next

		If lAviso 
			ApMsgAlert(cAviso,cTitle)
		EndIf

	EndIf

Return .T.

//-------------------------------------------------------------------
/*/{Protheus.doc} J096VldVig
Função que valida se os casos vinculados no contrato não estão em 
mais de um contrato com a mesma vigência

@param oModel, Modelo do Contrato (NT0)

@return lRet , Indica se a validação de vigência teve sucesso

@author Jorge Martins
@since  15/01/2025
/*/
//-------------------------------------------------------------------
Static Function J096VldVig(oModel)
Local lRet       := .T.
Local oModelNT0  := oModel:GetModel("NT0MASTER")
Local oModelNUT  := oModel:GetModel("NUTDETAIL")
Local lInclusao  := oModel:GetOperation() == MODEL_OPERATION_INSERT
Local aLinAlt    := oModelNUT:GetLinesChange()
Local lAtivo     := oModelNT0:GetValue("NT0_ATIVO") == "1" // Contrato ativo
Local lAltAtivo  := oModelNT0:IsFieldUpdated("NT0_ATIVO") .And. lAtivo // Contrato estava inativo e foi alterado pra ativo
Local lAltVigIni := (lInclusao .Or. lAltAtivo .Or. oModelNT0:IsFieldUpdated("NT0_DTVIGI")) // Contrato estava inativo e foi alterado para ativo ou foi alterada vigência inicial
Local lAltVigFim := (lInclusao .Or. lAltAtivo .Or. oModelNT0:IsFieldUpdated("NT0_DTVIGF")) // Contrato estava inativo e foi alterado para ativo ou foi alterada vigência final
Local lNT0Alt    := lAtivo .And. (lAltVigIni .Or. lAltVigFim) // Indica que houve alteração nos campos chave da NT0
Local lNUTAlt    := lAtivo .And. Len(aLinAlt) > 0 // Indica que houve alteração da NUT

	If lNT0Alt
		// Se alterar NT0 - Faz a validação dos registros via banco ignorando os registros das linhas alteradas
		lRet := J096VigNT0(oModelNT0, oModelNUT, aLinAlt)
	EndIf

	If lRet .And. lNUTAlt
		// Se alterar NUT - Faz a validação nas linhas alteradas (Roda a query p/ as linhas do GetLinesChange)
		lRet := J096VigNUT(oModelNT0, oModelNUT, aLinAlt, .F.)
	EndIf

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} J096VigNT0
Faz a validação da vigência digitada para os casos que já estão
cadastrados (registros que já estão no banco de dados), 
ignorando os registros das linhas alteradas

@param oModelNT0, Modelo do Contrato (NT0)
@param oModelNUT, Modelo de Casos do Contrato (NUT)
@param aLinAlt  , Linhas de Casos do Contrato que foram alteradas

@return lRet , Indica se a validação de vigência teve sucesso

@author Jorge Martins
@since  15/01/2025
/*/
//-------------------------------------------------------------------
Static Function J096VigNT0(oModelNT0, oModelNUT, aLinAlt)
Local lRet       := .T.
Local oQryVldVig := Nil
Local cAliasQry  := GetNextAlias()
Local cContr     := oModelNT0:GetValue("NT0_COD")
Local cDtVigI    := DtoS(oModelNT0:GetValue("NT0_DTVIGI"))
Local cDtVigF    := DtoS(oModelNT0:GetValue("NT0_DTVIGF"))
Local lUpdAtivo  := oModelNT0:IsFieldUpdated("NT0_ATIVO") .And. oModelNT0:GetValue("NT0_ATIVO") == "1"
Local lUpdVig    := oModelNT0:IsFieldUpdated("NT0_DTVIGI") .Or. oModelNT0:IsFieldUpdated("NT0_DTVIGF")
Local nQtdLinAlt := Len(aLinAlt)
Local cQryVig    := ""
Local cDtContIni := ""
Local cDtContFim := ""
Local cContrVig  := ""
Local cCasoVig   := ""
Local nParam     := 0
Local nLin       := 0
Local nQtdRecAlt := 0
Local nRecnoNUT  := 0
Local aRecnoAlt  := {}

	If nQtdLinAlt > 0
		For nLin := 1 To nQtdLinAlt
			nRecnoNUT := oModelNUT:GetDataID(aLinAlt[nLin])
			If nRecnoNUT > 0
				aAdd(aRecnoAlt, nRecnoNUT)
			EndIf
		Next
		nQtdRecAlt := Len(aRecnoAlt)
	EndIf

	cQryVig := " SELECT NT02.NT0_DTVIGI, NT02.NT0_DTVIGF, NUT2.NUT_CCASO, NUT2.NUT_CCONTR"
	cQryVig +=   " FROM " + RetSqlName("NT0") + " NT0"
	cQryVig +=  " INNER JOIN " + RetSqlName("NUT") + " NUT1"
	cQryVig +=     " ON NUT1.NUT_FILIAL = NT0.NT0_FILIAL"
	cQryVig +=    " AND NUT1.NUT_CCONTR = NT0.NT0_COD"
	If nQtdRecAlt > 0
		cQryVig += " AND NUT1.R_E_C_N_O_ NOT IN (?)"
	EndIf
	cQryVig +=    " AND NUT1.D_E_L_E_T_ = ?"
	cQryVig +=  " INNER JOIN " + RetSqlName("NUT") + " NUT2"
	cQryVig +=     " ON NUT2.NUT_FILIAL = NUT1.NUT_FILIAL"
	cQryVig +=    " AND NUT2.NUT_CCLIEN = NUT1.NUT_CCLIEN"
	cQryVig +=    " AND NUT2.NUT_CLOJA = NUT1.NUT_CLOJA"
	cQryVig +=    " AND NUT2.NUT_CCASO = NUT1.NUT_CCASO"
	cQryVig +=    " AND NUT2.D_E_L_E_T_ = ?"
	cQryVig +=  " INNER JOIN " + RetSqlName("NT0") + " NT02"
	cQryVig +=     " ON NT02.NT0_FILIAL = NUT2.NUT_FILIAL"
	cQryVig +=    " AND NT02.NT0_COD = NUT2.NUT_CCONTR"
	cQryVig +=    " AND NT02.NT0_ATIVO = ?"
	cQryVig +=    " AND NT02.NT0_COD <> ?"
	cQryVig +=    " AND NT02.D_E_L_E_T_ = ?"
	cQryVig +=  " WHERE NT0.NT0_FILIAL = ?"
	cQryVig +=    " AND NT0.NT0_COD = ?"
	cQryVig +=    " AND NT0.D_E_L_E_T_ = ?"

	oQryVldVig := FWPreparedStatement():New(cQryVig)

	// Seta os parametros
	nParam := 0
	If nQtdRecAlt > 0
		oQryVldVig:SetIn(++nParam, aRecnoAlt)
	EndIf
	oQryVldVig:SetString(++nParam, Space(1))
	oQryVldVig:SetString(++nParam, Space(1))
	oQryVldVig:SetString(++nParam, "1")
	oQryVldVig:SetString(++nParam, cContr)
	oQryVldVig:SetString(++nParam, Space(1))
	oQryVldVig:SetString(++nParam, xFilial("NT0"))
	oQryVldVig:SetString(++nParam, cContr)
	oQryVldVig:SetString(++nParam, Space(1))

	cQryVig := oQryVldVig:GetFixQuery()
	MpSysOpenQuery(cQryVig, cAliasQry)

	While !(cAliasQry)->(Eof())
		cDtContIni := (cAliasQry)->NT0_DTVIGI
		cDtContFim := (cAliasQry)->NT0_DTVIGF
		cContrVig  := (cAliasQry)->NUT_CCONTR
		cCasoVig   := (cAliasQry)->NUT_CCASO

		If !J096MsgVig(cDtVigI, cDtVigF, cContr, cDtContIni, cDtContFim, cContrVig, .F., cCasoVig, lUpdAtivo, lUpdVig)
			lRet := .F.
			Exit
		EndIf

		(cAliasQry)->(dbSkip())
	EndDo

	(cAliasQry)->(dbCloseArea())

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} J096VigNUT
Faz a validação da vigência digitada para os casos das linhas que
foram incluídas ou alteradas

@param oModelNT0  , Modelo do Contrato (NT0)
@param oModelNUT  , Modelo de Casos do Contrato (NUT)
@param aLinAlt    , Linhas de Casos do Contrato que foram alteradas
@param lPosVldLine, Indica que a chamada foi no GridLinePosVld

@return lRet , Indica se a validação de vigência teve sucesso

@author Jorge Martins
@since  15/01/2025
/*/
//-------------------------------------------------------------------
Static Function J096VigNUT(oModelNT0, oModelNUT, aLinAlt, lPosVldLine)
Local oQryVldVig := Nil
Local cContr     := oModelNT0:GetValue("NT0_COD")
Local cDtVigI    := DtoS(oModelNT0:GetValue("NT0_DTVIGI"))
Local cDtVigF    := DtoS(oModelNT0:GetValue("NT0_DTVIGF"))
Local cAliasQry  := ""
Local cQryVig    := ""
Local cDtContIni := ""
Local cDtContFim := ""
Local cContrVig  := ""
Local cCasoVig   := ""
Local nParam     := 0
Local nLine      := 0
Local lUpdAtivo  := oModelNT0:IsFieldUpdated("NT0_ATIVO") .And. oModelNT0:GetValue("NT0_ATIVO") == "1"
Local lUpdVig    := oModelNT0:IsFieldUpdated("NT0_DTVIGI") .Or. oModelNT0:IsFieldUpdated("NT0_DTVIGF")
Local lRet       := .T.

	cQryVig := "SELECT NT0.NT0_DTVIGI, NT0.NT0_DTVIGF, NUT.NUT_CCASO, NUT.NUT_CCONTR"
	cQryVig +=  " FROM " + RetSqlName("NUT") + " NUT"
	cQryVig += " INNER JOIN " + RetSqlName("NT0") + " NT0"
	cQryVig +=     " ON NT0.NT0_FILIAL = NUT.NUT_FILIAL"
	cQryVig +=    " AND NT0.NT0_COD = NUT.NUT_CCONTR"
	cQryVig +=    " AND NT0.NT0_ATIVO  = ?"
	cQryVig +=    " AND NT0.D_E_L_E_T_ = ?"
	cQryVig +=  " WHERE NUT.NUT_FILIAL = ?"
	cQryVig +=    " AND NUT.NUT_CCLIEN = ?"
	cQryVig +=    " AND NUT.NUT_CLOJA  = ?"
	cQryVig +=    " AND NUT.NUT_CCASO  = ?"
	cQryVig +=    " AND NUT.NUT_CCONTR <> ?"
	cQryVig +=    " AND NUT.D_E_L_E_T_ = ?"
	
	oQryVldVig := FWPreparedStatement():New(cQryVig)

	For nLine := 1 To Len(aLinAlt)

		If !oModelNUT:IsDeleted(aLinAlt[nLine])
	
			// Seta os parametros
			nParam := 0
			oQryVldVig:SetString(++nParam, "1")
			oQryVldVig:SetString(++nParam, Space(1))
			oQryVldVig:SetString(++nParam, xFilial("NUT"))
			oQryVldVig:SetString(++nParam, oModelNUT:GetValue("NUT_CCLIEN", aLinAlt[nLine]))
			oQryVldVig:SetString(++nParam, oModelNUT:GetValue("NUT_CLOJA" , aLinAlt[nLine]))
			oQryVldVig:SetString(++nParam, oModelNUT:GetValue("NUT_CCASO" , aLinAlt[nLine]))
			oQryVldVig:SetString(++nParam, cContr)
			oQryVldVig:SetString(++nParam, Space(1))

			cAliasQry := GetNextAlias()

			MpSysOpenQuery(oQryVldVig:GetFixQuery(), cAliasQry)

			While !(cAliasQry)->(Eof())
				cDtContIni := (cAliasQry)->NT0_DTVIGI
				cDtContFim := (cAliasQry)->NT0_DTVIGF
				cContrVig  := (cAliasQry)->NUT_CCONTR
				cCasoVig   := (cAliasQry)->NUT_CCASO

				If !J096MsgVig(cDtVigI, cDtVigF, cContr, cDtContIni, cDtContFim, cContrVig, lPosVldLine, cCasoVig, lUpdAtivo, lUpdVig)
					lRet := .F.
					Exit
				EndIf

				(cAliasQry)->(dbSkip())
			EndDo

			(cAliasQry)->(dbCloseArea())

			If !lRet
				Exit
			EndIf

		EndIf

	Next

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} J096MsgVig
Faz o tratamento das mensagens de validação de vigência do contrato

@param cDtVigI    , Vigência inicial digitada no contrato
@param cDtVigF    , Vigência final digitada no contrato
@param cContr     , Código do contrato atual (que está sendo editado)
@param cDtContIni , Vigência inicial do contrato que está conflitando com o contrato que está sendo editado
@param cDtContFim , Vigência final do contrato que está conflitando com o contrato que está sendo editado
@param cContrVig  , Código do contrato que está conflitando com o contrato que está sendo editado
@param lPosVldNUT , Indica se a mensagem veio da validação de linha do grid de casos (GridLinePosVld)
@param lUpdAtivo  , Indica se o campo NT0_ATIVO foi atualizado para '1 - Sim'
@param cCasoVig   , Codigo do caso que está conflitando com o contrato que esta sendo editado
@param lUpdVig    , Indica se o campo foi atualizado
@return lRet      , Indica se será exibida mensagem de validação da vigência

@author Jorge Martins
@since  15/01/2025
/*/
//-------------------------------------------------------------------
Static Function J096MsgVig(cDtVigI, cDtVigF, cContr, cDtContIni, cDtContFim, cContrVig, lPosVldNUT, cCasoVig, lUpdAtivo, lUpdVig)
Local cProblema := ""
Local cSolucao  := ""
Local lRet      := .T.

Default lPosVldNUT := .F. // Indica se a mensagem veio da validação de linha do grid de casos (GridLinePosVld)

	// Verifica se a vigência inicial está entre as datas inicial e final da vigência de outro contrato
	If !Empty(cDtVigI) .And. !Empty(cDtVigF) .And. (cDtVigI >= cDtContIni) .And. (cDtVigI <= cDtContFim)
		cProblema := I18N(STR0234 + CRLF +; // "Períodos sobrepostos na vigência."
		                  STR0297,; // "A vigência inicial '#1' está contida na vigência do contrato '#2'."
		                  {SToD(cDtVigI), cContrVig})
		cSolucao  := I18N(STR0298, {SToD(cDtContIni), SToD(cDtContFim)}) // "Verifique a data de vigência inicial. Ela não pode estar no período entre #1 e #2."
		lRet := .F.
	EndIf

	// Verifica se a vigência final está entre as datas inicial e final da vigência de outro contrato
	If lRet .And. !Empty(cDtVigI) .And. !Empty(cDtVigF) .And. (cDtVigF >= cDtContIni) .And. (cDtVigF <= cDtContFim)
		cProblema := I18N(STR0234 + CRLF +; // "Períodos sobrepostos na vigência."
		                  STR0299,; // "A vigência final '#1' está contida na vigência do contrato '#2'."
		                  {SToD(cDtVigF), cContrVig})
		cSolucao  := I18N(STR0300, {SToD(cDtContIni), SToD(cDtContFim)}) // "Verifique a data de vigência final. Ela não pode estar no período entre #1 e #2."
		lRet := .F.
	EndIf

	// Verifica se a vigência está sobrepondo a vigência de outro contrato
	If lRet .And. !Empty(cDtVigI) .And. !Empty(cDtVigF) .And. (cDtVigI <= cDtContIni) .And. (cDtVigF >= cDtContFim)
		cProblema := I18N(STR0234 + CRLF +; 
		                  STR0301,; // "A vigência de '#1' a '#2' está sobrepondo a vigência do contrato '#3'."
		                  {SToD(cDtVigI), SToD(cDtVigF), cContrVig}) // "Verifique o período de vigência no contrato."
		cSolucao  := I18N(STR0302, {SToD(cDtContIni), SToD(cDtContFim)}) // "Verifique a data inicial e final da vigência. Ela não pode sobrepor o período de #1 a #2."
		lRet := .F.
	EndIf

	If lRet .And. Empty(cDtContIni) .And. Empty(cDtContFim) .And. !Empty(cDtVigI) .And. !Empty(cDtVigF)
		If lPosVldNUT
			cProblema := STR0303 // "Não é possível vincular este caso ao contrato, pois o mesmo está vinculado a contratos que possuem vigência."
			cSolucao  := STR0304 // "Verifique a data inicial e final da vigência e deixe os campos em branco para vincular este caso."
		ElseIf lUpdVig // Mensagem na validação de alteração no contrato (campos de vigência)
			cProblema := I18N(STR0286, {cContr}) // "Não é possível incluir data de vigência no contrato '#1', pois o mesmo possui casos vinculados a contratos que não possuem vigência."
			cSolucao  := STR0305 // "Verifique a data inicial e final da vigência e deixe os campos em branco."
		ElseIf lUpdAtivo
			cProblema := I18N(STR0310, {cContr, cCasoVig, cContrVig}) // "Não é permitido ativar o contrato '#1', pois o caso '#2' possui vínculo com o contrato '#3' que não possui período de vigência."
			cSolucao  := I18N(STR0311, {cContr, cContrVig}) // "Verifique a data inicial e final da vigência dos contratos '#1' e '#2'"
		EndIf
		lRet := .F.
	EndIf

	If lRet .And. Empty(cDtVigI) .And. Empty(cDtVigF) .And. !Empty(cDtContIni) .And. !Empty(cDtContFim)
		If lPosVldNUT
			cProblema := STR0303 // "Não é possível vincular este caso ao contrato, pois o mesmo está vinculado a contratos que possuem vigência."
			cSolucao  := STR0306 // "Verifique a data inicial e final da vigência e preencha com uma vigência válida para vincular este caso."
		ElseIf lUpdVig // Mensagem na validação de alteração no contrato (campos de vigência)
			cProblema := I18N(STR0287, {cContr}) // "Não é permitido limpar a vigência do contrato '#1', pois o mesmo possui casos vinculados a contratos que possuem vigência."
			cSolucao  := STR0307 // "Verifique a data inicial e final da vigência e preencha com uma vigência válida."
		ElseIf lUpdAtivo
			cProblema := I18N(STR0312, {cContr, cCasoVig, cContrVig}) // "Não é permitido ativar o contrato '#1', pois o caso '#2' possui vínculo com o contrato '#3' que possui período de vigência."
			cSolucao  := I18N(STR0311, {cContr, cContrVig}) // "Verifique a data inicial e final da vigência dos contratos '#1' e '#2'"
		EndIf
		lRet := .F.
	EndIf

	If !lRet
		JurMsgErro(cProblema,, cSolucao)
	EndIf

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} J096VldCob
Função que valida se os casos vinculados no contrato não estão em 
mais de um contrato que cobram hora, despesa ou tabelado.

@param oModel, Modelo do Contrato (NT0)

@return lRet , Indica se a validação dos tipos de cobranças teve sucesso

@author Victor Hayashi
@since  14/10/2024
/*/
//-------------------------------------------------------------------
Static Function J096VldCob(oModel)
Local lRet       := .T.
Local oModelNT0  := oModel:GetModel("NT0MASTER")
Local oModelNUT  := oModel:GetModel("NUTDETAIL")
Local lInclusao  := oModel:GetOperation() == MODEL_OPERATION_INSERT
Local cContr     := oModelNT0:GetValue("NT0_COD")
Local aLinAlt    := oModelNUT:GetLinesChange()
Local lAtivo     := oModelNT0:GetValue("NT0_ATIVO") == "1" // Contrato ativo
Local lAltAtivo  := oModelNT0:IsFieldUpdated("NT0_ATIVO") .And. lAtivo // Contrato estava inativo e foi alterado pra ativo
Local lCobHon    := JurGetDados("NRA", 1, xFilial("NRA") + oModelNT0:GetValue("NT0_CTPHON"), "NRA_COBRAH") == "1" // Indica que o contrato cobra hora
Local lCobDsp    := oModelNT0:GetValue("NT0_DESPES") == "1" // Indica que o contrato cobra despesa
Local lCobTab    := oModelNT0:GetValue("NT0_SERTAB") == "1" // Indica que o contrato cobra tabelado
Local lAltHon    := (lInclusao .Or. lAltAtivo .Or. oModelNT0:IsFieldUpdated("NT0_CTPHON")) .And. lCobHon // Contrato estava inativo e foi alterado para ativo ou foi alterado para cobrar hora
Local lAltDsp    := (lInclusao .Or. lAltAtivo .Or. oModelNT0:IsFieldUpdated("NT0_DESPES")) .And. lCobDsp // Contrato estava inativo e foi alterado para ativo ou foi alterado para cobrar despesa
Local lAltTab    := (lInclusao .Or. lAltAtivo .Or. oModelNT0:IsFieldUpdated("NT0_SERTAB")) .And. lCobTab // Contrato estava inativo e foi alterado para ativo ou foi alterado para cobrar tabelado
Local lNT0Alt    := lAtivo .And. (lAltHon .Or. lAltDsp .Or. lAltTab) // Indica que houve alteração nos campos chave da NT0
Local lNUTAlt    := lAtivo .And. Len(aLinAlt) > 0 .And. (lCobHon .Or. lCobDsp .Or. lCobTab) // Indica que houve alteração da NUT
Local cMensagem  := ""
Local cSolucao   := ""

	If lNT0Alt
		// Se alterar NT0 - Faz a validação dos registros via banco ignorando os registros das linhas alteradas
		cMensagem += J096CobNT0(oModelNT0, oModelNUT, aLinAlt, cContr, lAltHon, lAltDsp, lAltTab)
	EndIf

	If lNUTAlt
		// Se alterar NUT - Faz a validação nas linhas alteradas (Roda a query p/ as linhas do GetLinesChange)
		cMensagem += J096CobNUT(oModelNUT, aLinAlt, cContr, lCobHon, lCobDsp, lCobTab)
	EndIf

	If !Empty(cMensagem)
		lRet := .F.
		cSolucao := STR0296 // "Remova o vínculo do(s) caso(s) citado(s) ou altere a(s) forma(s) de cobrança do contrato."
		oModel:SetErrorMessage(,, oModel:GetId(),, "J096VldCob", STR0282 + CRLF + cMensagem, cSolucao,, ) // "Não será possível manipular os desdobramentos do Contas Pagar, pois o usuário não está vinculado a um participante." "Associe seu usuário a um participante para ter acesso a operação.
	EndIf

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} J096CobNT0
Valida se os casos vinculados no contrato não estão em 
mais de um contrato que cobram hora, despesa ou tabelado.

Faz essa validação para os casos que já estão cadastrados 
(registros que já estão no banco de dados), ignorando os registros 
das linhas alteradas.

@param oModelNT0, Modelo do Contrato (NT0)
@param oModelNUT, Modelo de Casos do Contrato (NUT)
@param aLinAlt  , Linhas de Casos do Contrato que foram alteradas
@param cContr   , Código do contrato que está sendo editado
@param lCobHon  , Foi alterada a forma de cobrança para cobrar hora
@param lCobDsp  , Foi alterada a forma de cobrança para cobrar despesa
@param lCobTab  , Foi alterada a forma de cobrança para cobrar tabelado

@return lRet    , Indica se a validação de vigência teve sucesso

@author Jorge Martins
@since  15/01/2025
/*/
//-------------------------------------------------------------------
Static Function J096CobNT0(oModelNT0, oModelNUT, aLinAlt, cContr, lCobHon, lCobDsp, lCobTab)
Local oQryVldCob := Nil
Local cAliasQry  := GetNextAlias()
Local cQryCob    := ""
Local cMensagem  := ""
Local nParam     := 0
Local nQtdLinAlt := Len(aLinAlt)
Local nRecnoNUT  := 0
Local nLin       := 0
Local nQtdRecAlt := 0
Local aRecnoAlt  := {}

	If nQtdLinAlt > 0
		For nLin := 1 To nQtdLinAlt
			nRecnoNUT := oModelNUT:GetDataID(aLinAlt[nLin])
			If nRecnoNUT > 0
				aAdd(aRecnoAlt, nRecnoNUT)
			EndIf
		Next
		nQtdRecAlt := Len(aRecnoAlt)
	EndIf

	cQryCob := "SELECT NUT_CCLIEN, NUT_CLOJA, NUT_CCASO, NUT_CCONTR, MIN(COBRAHON) COBRAHON, MIN(COBRADP) COBRADP, MIN(COBRALT) COBRALT"
	cQryCob +=  " FROM ("

	// =========================
	// VALIDA COBRANÇA POR HORA
	// =========================
	If lCobHon
		cQryCob +=  " SELECT NUTFORA.NUT_CCLIEN, NUTFORA.NUT_CLOJA, NUTFORA.NUT_CCASO, NUTFORA.NUT_CCONTR, '1' COBRAHON, '2' COBRADP, '2' COBRALT"
		cQryCob +=    " FROM " + RetSqlName("NT0") + " NT0"
		cQryCob +=   " INNER JOIN " + RetSqlName("NUT") + " NUT"
		cQryCob +=      " ON NUT.NUT_FILIAL = NT0.NT0_FILIAL"
		cQryCob +=     " AND NUT.NUT_CCONTR = NT0.NT0_COD"
		If nQtdRecAlt > 0
			cQryCob += " AND NUT.R_E_C_N_O_ NOT IN (?)" // #1
		EndIf
		cQryCob +=     " AND NUT.D_E_L_E_T_ = ?" // #2
		cQryCob +=   " INNER JOIN " + RetSqlName("NUT") + " NUTFORA"
		cQryCob +=      " ON NUTFORA.NUT_FILIAL = NUT.NUT_FILIAL"
		cQryCob +=     " AND NUTFORA.NUT_CCLIEN = NUT.NUT_CCLIEN"
		cQryCob +=     " AND NUTFORA.NUT_CLOJA  = NUT.NUT_CLOJA"
		cQryCob +=     " AND NUTFORA.NUT_CCASO  = NUT.NUT_CCASO"
		cQryCob +=     " AND NUTFORA.D_E_L_E_T_ = ?" // #3
		cQryCob +=   " INNER JOIN " + RetSqlName("NT0") + " NT0FORA"
		cQryCob +=      " ON NT0FORA.NT0_FILIAL = NUTFORA.NUT_FILIAL"
		cQryCob +=     " AND NT0FORA.NT0_COD = NUTFORA.NUT_CCONTR"
		cQryCob +=     " AND NT0FORA.NT0_ATIVO = '1'"
		cQryCob +=     " AND NT0FORA.D_E_L_E_T_ = ?" // #4
		cQryCob +=     " AND NT0FORA.NT0_COD <> ?" // #5
		cQryCob +=   " INNER JOIN " + RetSqlName("NRA") + " NRAFORA"
		cQryCob +=      " ON NRAFORA.NRA_FILIAL = ?" // #6
		cQryCob +=     " AND NRAFORA.NRA_COD = NT0FORA.NT0_CTPHON"
		cQryCob +=     " AND NRAFORA.NRA_COBRAH = '1'"
		cQryCob +=     " AND NRAFORA.D_E_L_E_T_ = ?" // #7
		cQryCob +=   " WHERE NT0.NT0_FILIAL = ?" // #8
		cQryCob +=     " AND NT0.NT0_COD = ?" // #9
		cQryCob +=     " AND NT0.D_E_L_E_T_ = ?" // #10

		If lCobDsp .Or. lCobTab
			cQryCob += " UNION ALL "
		EndIf
	
	EndIf

	// ===========================
	// VALIDA COBRANÇA DE DESPESA
	// ===========================
	If lCobDsp
		cQryCob +=  " SELECT NUTFORA.NUT_CCLIEN, NUTFORA.NUT_CLOJA, NUTFORA.NUT_CCASO, NUTFORA.NUT_CCONTR, '2' COBRAHON, '1' COBRADP, '2' COBRALT"
		cQryCob +=    " FROM " + RetSqlName("NT0") + " NT0"
		cQryCob +=   " INNER JOIN " + RetSqlName("NUT") + " NUT"
		cQryCob +=      " ON NUT.NUT_FILIAL = NT0.NT0_FILIAL"
		cQryCob +=     " AND NUT.NUT_CCONTR = NT0.NT0_COD"
		If nQtdRecAlt > 0
			cQryCob += " AND NUT.R_E_C_N_O_ NOT IN (?)" // #1
		EndIf
		cQryCob +=     " AND NUT.D_E_L_E_T_ = ?" // #2
		cQryCob +=   " INNER JOIN " + RetSqlName("NUT") + " NUTFORA"
		cQryCob +=      " ON NUTFORA.NUT_FILIAL = NUT.NUT_FILIAL"
		cQryCob +=     " AND NUTFORA.NUT_CCLIEN = NUT.NUT_CCLIEN"
		cQryCob +=     " AND NUTFORA.NUT_CLOJA  = NUT.NUT_CLOJA"
		cQryCob +=     " AND NUTFORA.NUT_CCASO  = NUT.NUT_CCASO"
		cQryCob +=     " AND NUTFORA.D_E_L_E_T_ = ?" // #3
		cQryCob +=   " INNER JOIN " + RetSqlName("NT0") + " NT0FORA"
		cQryCob +=      " ON NT0FORA.NT0_FILIAL = NUTFORA.NUT_FILIAL"
		cQryCob +=     " AND NT0FORA.NT0_COD = NUTFORA.NUT_CCONTR"
		cQryCob +=     " AND NT0FORA.NT0_ATIVO = '1'"
		cQryCob +=     " AND NT0FORA.NT0_DESPES = '1'"
		cQryCob +=     " AND NT0FORA.D_E_L_E_T_ = ?" // #4
		cQryCob +=     " AND NT0FORA.NT0_COD <> ?" // #5
		cQryCob +=   " WHERE NT0.NT0_FILIAL = ?" // #6
		cQryCob +=     " AND NT0.NT0_COD = ?" // #7
		cQryCob +=     " AND NT0.D_E_L_E_T_ = ?" // #8

		If lCobTab
			cQryCob += " UNION ALL "
		EndIf
	
	EndIf

	// ===========================
	// VALIDA COBRANÇA DE TABELADO
	// ===========================
	If lCobTab
		cQryCob +=  " SELECT NUTFORA.NUT_CCLIEN, NUTFORA.NUT_CLOJA, NUTFORA.NUT_CCASO, NUTFORA.NUT_CCONTR, '2' COBRAHON, '2' COBRADP, '1' COBRALT"
		cQryCob +=    " FROM " + RetSqlName("NT0") + " NT0"
		cQryCob +=   " INNER JOIN " + RetSqlName("NUT") + " NUT"
		cQryCob +=      " ON NUT.NUT_FILIAL = NT0.NT0_FILIAL"
		cQryCob +=     " AND NUT.NUT_CCONTR = NT0.NT0_COD"
		If nQtdRecAlt > 0
			cQryCob += " AND NUT.R_E_C_N_O_ NOT IN (?)" // #1
		EndIf
		cQryCob +=     " AND NUT.D_E_L_E_T_ = ?" // #2
		cQryCob +=   " INNER JOIN " + RetSqlName("NUT") + " NUTFORA"
		cQryCob +=      " ON NUTFORA.NUT_FILIAL = NUT.NUT_FILIAL"
		cQryCob +=     " AND NUTFORA.NUT_CCLIEN = NUT.NUT_CCLIEN"
		cQryCob +=     " AND NUTFORA.NUT_CLOJA  = NUT.NUT_CLOJA"
		cQryCob +=     " AND NUTFORA.NUT_CCASO  = NUT.NUT_CCASO"
		cQryCob +=     " AND NUTFORA.D_E_L_E_T_ = ?" // #3
		cQryCob +=   " INNER JOIN " + RetSqlName("NT0") + " NT0FORA"
		cQryCob +=      " ON NT0FORA.NT0_FILIAL = NUTFORA.NUT_FILIAL"
		cQryCob +=     " AND NT0FORA.NT0_COD = NUTFORA.NUT_CCONTR"
		cQryCob +=     " AND NT0FORA.NT0_ATIVO = '1'"
		cQryCob +=     " AND NT0FORA.NT0_SERTAB = '1'"
		cQryCob +=     " AND NT0FORA.D_E_L_E_T_ = ?" // #4
		cQryCob +=     " AND NT0FORA.NT0_COD <> ?" // #5
		cQryCob +=   " WHERE NT0.NT0_FILIAL = ?" // #6
		cQryCob +=     " AND NT0.NT0_COD = ?" // #7
		cQryCob +=     " AND NT0.D_E_L_E_T_ = ?" // #8
	
	EndIf

	cQryCob +=       " ) A"
	cQryCob += " GROUP BY A.NUT_CCLIEN, A.NUT_CLOJA, A.NUT_CCASO, A.NUT_CCONTR"

	oQryVldCob := FWPreparedStatement():New(cQryCob)

	If lCobHon
		If nQtdRecAlt > 0
			oQryVldCob:SetIn(++nParam, aRecnoAlt)      // #1
		EndIf
		oQryVldCob:SetString(++nParam, Space(1))       // #2
		oQryVldCob:SetString(++nParam, Space(1))       // #3
		oQryVldCob:SetString(++nParam, Space(1))       // #4
		oQryVldCob:SetString(++nParam, cContr)         // #5
		oQryVldCob:SetString(++nParam, xFilial("NRA")) // #6
		oQryVldCob:SetString(++nParam, Space(1))       // #7
		oQryVldCob:SetString(++nParam, xFilial("NT0")) // #8
		oQryVldCob:SetString(++nParam, cContr)         // #9
		oQryVldCob:SetString(++nParam, Space(1))       // #10
	EndIf

	If lCobDsp
		If nQtdRecAlt > 0
			oQryVldCob:SetIn(++nParam, aRecnoAlt)      // #1
		EndIf
		oQryVldCob:SetString(++nParam, Space(1))       // #2
		oQryVldCob:SetString(++nParam, Space(1))       // #3
		oQryVldCob:SetString(++nParam, Space(1))       // #4
		oQryVldCob:SetString(++nParam, cContr)         // #5
		oQryVldCob:SetString(++nParam, xFilial("NT0")) // #6
		oQryVldCob:SetString(++nParam, cContr)         // #7
		oQryVldCob:SetString(++nParam, Space(1))       // #8
	EndIf

	If lCobTab
		If nQtdRecAlt > 0
			oQryVldCob:SetIn(++nParam, aRecnoAlt)      // #1
		EndIf
		oQryVldCob:SetString(++nParam, Space(1))       // #2
		oQryVldCob:SetString(++nParam, Space(1))       // #3
		oQryVldCob:SetString(++nParam, Space(1))       // #4
		oQryVldCob:SetString(++nParam, cContr)         // #5
		oQryVldCob:SetString(++nParam, xFilial("NT0")) // #6
		oQryVldCob:SetString(++nParam, cContr)         // #7
		oQryVldCob:SetString(++nParam, Space(1))       // #8
	EndIf

	cQryCob := oQryVldCob:GetFixQuery()
	MpSysOpenQuery(cQryCob, cAliasQry)

	While !(cAliasQry)->(Eof())

		cMensagem += J096MsgCob(cAliasQry)

		(cAliasQry)->(dbSkip())
	EndDo

	(cAliasQry)->(dbCloseArea())

Return cMensagem

//-------------------------------------------------------------------
/*/{Protheus.doc} J096CobNUT
Valida se os casos vinculados no contrato não estão em 
mais de um contrato que cobram hora, despesa ou tabelado.

Faz essa validação para os casos das linhas alteradas na NUT.

@param oModelNT0, Modelo do Contrato (NT0)
@param oModelNUT, Modelo de Casos do Contrato (NUT)
@param aLinAlt  , Linhas de Casos do Contrato que foram alteradas
@param cContr   , Código do contrato que está sendo editado
@param lCobHon  , Foi alterada a forma de cobrança para cobrar hora
@param lCobDsp  , Foi alterada a forma de cobrança para cobrar despesa
@param lCobTab  , Foi alterada a forma de cobrança para cobrar tabelado

@return cMensagem, Mensagem com os problemas de validação

@author Jorge Martins
@since  15/01/2025
/*/
//-------------------------------------------------------------------
Static Function J096CobNUT(oModelNUT, aLinAlt, cContr, lCobHon, lCobDsp, lCobTab)
Local oQryVldCob := Nil
Local cAliasQry  := ""
Local cQryCob    := ""
Local cMensagem  := ""
Local nParam     := 0
Local nLine      := 0

	cQryCob := "SELECT NUT_CCLIEN, NUT_CLOJA, NUT_CCASO, NUT_CCONTR, MIN(COBRAHON) COBRAHON, MIN(COBRADP) COBRADP, MIN(COBRALT) COBRALT"
	cQryCob +=  " FROM ("

	// =========================
	// VALIDA COBRANÇA POR HORA
	// =========================
	If lCobHon

		cQryCob +=  " SELECT NUT.NUT_CCLIEN, NUT.NUT_CLOJA, NUT.NUT_CCASO, NUT.NUT_CCONTR, '1' COBRAHON, '2' COBRADP, '2' COBRALT"
		cQryCob +=    " FROM " + RetSqlName("NUT") + " NUT"
		cQryCob +=   " INNER JOIN " + RetSqlName("NT0") + " NT0"
		cQryCob +=      " ON NT0.NT0_FILIAL = NUT.NUT_FILIAL"
		cQryCob +=     " AND NT0.NT0_COD = NUT.NUT_CCONTR"
		cQryCob +=     " AND NT0.NT0_ATIVO = '1'"
		cQryCob +=     " AND NT0.D_E_L_E_T_ = ?" // #1
		cQryCob +=     " AND NT0.NT0_COD <> ?" // #2
		cQryCob +=   " INNER JOIN " + RetSqlName("NRA") + " NRA"
		cQryCob +=      " ON NRA.NRA_FILIAL = ?" // #3
		cQryCob +=     " AND NRA.NRA_COD = NT0.NT0_CTPHON"
		cQryCob +=     " AND NRA.NRA_COBRAH = '1'"
		cQryCob +=     " AND NRA.D_E_L_E_T_ = ?" // #4
		cQryCob +=   " WHERE NUT.NUT_FILIAL = ?" // #5
		cQryCob +=     " AND NUT.NUT_CCLIEN = ?" // #6
		cQryCob +=     " AND NUT.NUT_CLOJA  = ?" // #7
		cQryCob +=     " AND NUT.NUT_CCASO  = ?" // #8
		cQryCob +=     " AND NUT.D_E_L_E_T_ = ?" // #9

		If lCobDsp .Or. lCobTab
			cQryCob += " UNION ALL "
		EndIf
	
	EndIf

	// ===========================
	// VALIDA COBRANÇA DE DESPESA
	// ===========================
	If lCobDsp
		
		cQryCob +=  " SELECT NUT.NUT_CCLIEN, NUT.NUT_CLOJA, NUT.NUT_CCASO, NUT.NUT_CCONTR, '2' COBRAHON, '1' COBRADP, '2' COBRALT"
		cQryCob +=    " FROM " + RetSqlName("NUT") + " NUT"
		cQryCob +=   " INNER JOIN " + RetSqlName("NT0") + " NT0"
		cQryCob +=      " ON NT0.NT0_FILIAL = NUT.NUT_FILIAL"
		cQryCob +=     " AND NT0.NT0_COD = NUT.NUT_CCONTR"
		cQryCob +=     " AND NT0.NT0_ATIVO = '1'"
		cQryCob +=     " AND NT0.NT0_DESPES = '1'"
		cQryCob +=     " AND NT0.D_E_L_E_T_ = ?" // #1
		cQryCob +=     " AND NT0.NT0_COD <> ?" // #2
		cQryCob +=   " WHERE NUT.NUT_FILIAL = ?" // #3
		cQryCob +=     " AND NUT.NUT_CCLIEN = ?" // #4
		cQryCob +=     " AND NUT.NUT_CLOJA  = ?" // #5
		cQryCob +=     " AND NUT.NUT_CCASO  = ?" // #6
		cQryCob +=     " AND NUT.D_E_L_E_T_ = ?" // #7

		If lCobTab
			cQryCob += " UNION ALL "
		EndIf
	
	EndIf

	// ===========================
	// VALIDA COBRANÇA DE TABELADO
	// ===========================
	If lCobTab
		cQryCob +=  " SELECT NUT.NUT_CCLIEN, NUT.NUT_CLOJA, NUT.NUT_CCASO, NUT.NUT_CCONTR, '2' COBRAHON, '2' COBRADP, '1' COBRALT"
		cQryCob +=    " FROM " + RetSqlName("NUT") + " NUT"
		cQryCob +=   " INNER JOIN " + RetSqlName("NT0") + " NT0"
		cQryCob +=      " ON NT0.NT0_FILIAL = NUT.NUT_FILIAL"
		cQryCob +=     " AND NT0.NT0_COD = NUT.NUT_CCONTR"
		cQryCob +=     " AND NT0.NT0_ATIVO = '1'"
		cQryCob +=     " AND NT0.NT0_SERTAB = '1'"
		cQryCob +=     " AND NT0.D_E_L_E_T_ = ?" // #1
		cQryCob +=     " AND NT0.NT0_COD <> ?" // #2
		cQryCob +=   " WHERE NUT.NUT_FILIAL = ?" // #3
		cQryCob +=     " AND NUT.NUT_CCLIEN = ?" // #4
		cQryCob +=     " AND NUT.NUT_CLOJA  = ?" // #5
		cQryCob +=     " AND NUT.NUT_CCASO  = ?" // #6
		cQryCob +=     " AND NUT.D_E_L_E_T_ = ?" // #7
	
	EndIf

	cQryCob +=       " ) A"
	cQryCob += " GROUP BY A.NUT_CCLIEN, A.NUT_CLOJA, A.NUT_CCASO, A.NUT_CCONTR"

	oQryVldCob := FWPreparedStatement():New(cQryCob)

	For nLine := 1 To Len(aLinAlt)

		If !oModelNUT:IsDeleted(aLinAlt[nLine])
	
			// Seta os parametros
			nParam := 0
	
			If lCobHon
				oQryVldCob:SetString(++nParam, Space(1))                                         // #1
				oQryVldCob:SetString(++nParam, cContr)                                           // #2
				oQryVldCob:SetString(++nParam, xFilial("NRA"))                                   // #3
				oQryVldCob:SetString(++nParam, Space(1))                                         // #4
				oQryVldCob:SetString(++nParam, xFilial("NUT"))                                   // #5
				oQryVldCob:SetString(++nParam, oModelNUT:GetValue("NUT_CCLIEN", aLinAlt[nLine])) // #6
				oQryVldCob:SetString(++nParam, oModelNUT:GetValue("NUT_CLOJA" , aLinAlt[nLine])) // #7
				oQryVldCob:SetString(++nParam, oModelNUT:GetValue("NUT_CCASO" , aLinAlt[nLine])) // #8
				oQryVldCob:SetString(++nParam, Space(1))                                         // #9
			EndIf

			If lCobDsp
				oQryVldCob:SetString(++nParam, Space(1))                                         // #1
				oQryVldCob:SetString(++nParam, cContr)                                           // #2
				oQryVldCob:SetString(++nParam, xFilial("NUT"))                                   // #3
				oQryVldCob:SetString(++nParam, oModelNUT:GetValue("NUT_CCLIEN", aLinAlt[nLine])) // #4
				oQryVldCob:SetString(++nParam, oModelNUT:GetValue("NUT_CLOJA" , aLinAlt[nLine])) // #5
				oQryVldCob:SetString(++nParam, oModelNUT:GetValue("NUT_CCASO" , aLinAlt[nLine])) // #6
				oQryVldCob:SetString(++nParam, Space(1))                                         // #7
			EndIf

			If lCobTab
				oQryVldCob:SetString(++nParam, Space(1))                                         // #1
				oQryVldCob:SetString(++nParam, cContr)                                           // #2
				oQryVldCob:SetString(++nParam, xFilial("NUT"))                                   // #3
				oQryVldCob:SetString(++nParam, oModelNUT:GetValue("NUT_CCLIEN", aLinAlt[nLine])) // #4
				oQryVldCob:SetString(++nParam, oModelNUT:GetValue("NUT_CLOJA" , aLinAlt[nLine])) // #5
				oQryVldCob:SetString(++nParam, oModelNUT:GetValue("NUT_CCASO" , aLinAlt[nLine])) // #6
				oQryVldCob:SetString(++nParam, Space(1))                                         // #7
			EndIf

			cAliasQry := GetNextAlias()

			cQryCob := oQryVldCob:GetFixQuery()
			MpSysOpenQuery(cQryCob, cAliasQry)

			While !(cAliasQry)->(Eof())

				cMensagem += J096MsgCob(cAliasQry)

				(cAliasQry)->(dbSkip())
			EndDo

			(cAliasQry)->(dbCloseArea())
		EndIf

	Next

Return cMensagem

//-------------------------------------------------------------------
/*/{Protheus.doc} J096MsgCob
Faz o tratamento das mensagens de validação de forma de cobrança do contrato

@param cAliasQry, Alias da query com casos e contratos para mensagem

@return cMensagem, Mensagem com os casos e contratos que invalidam a alteração

@author Jorge Martins
@since  15/01/2025
/*/
//-------------------------------------------------------------------
Static Function J096MsgCob(cAliasQry)
Local lLojaAuto  := SuperGetMv( "MV_JLOJAUT", .F., "2", ) == "1"
Local cQryCli    := (cAliasQry)->NUT_CCLIEN
Local cQryLoja   := (cAliasQry)->NUT_CLOJA
Local cQryCliLoj := cQryCli + IIf(lLojaAuto, "" , "/" + cQryLoja)
Local cQryCaso   := (cAliasQry)->NUT_CCASO
Local cQryContr  := (cAliasQry)->NUT_CCONTR
Local lQryCobH   := (cAliasQry)->COBRAHON == "1" // Cobra honorário
Local lQryCobDP  := (cAliasQry)->COBRADP  == "1" // Cobra despesa
Local lQryCobLT  := (cAliasQry)->COBRALT  == "1" // Cobra tabelado

	If lQryCobH .And. lQryCobDP .And. lQryCobLT
		cMsgTipoCob := STR0289 // "cobra hora, despesas e lançamentos tabelados"
	ElseIf lQryCobH .And. lQryCobDP .And. !lQryCobLT
		cMsgTipoCob := STR0290 // "cobra hora e despesas"
	ElseIf lQryCobH .And. !lQryCobDP .And. lQryCobLT
		cMsgTipoCob := STR0291 // "cobra hora e lançamentos tabelados"
	ElseIf lQryCobH .And. !lQryCobDP .And. !lQryCobLT
		cMsgTipoCob := STR0292 // "cobra hora"
	ElseIf !lQryCobH .And. lQryCobDP .And. lQryCobLT
		cMsgTipoCob := STR0293 // "cobra despesas e lançamentos tabelados"
	ElseIf !lQryCobH .And. lQryCobDP .And. !lQryCobLT
		cMsgTipoCob := STR0294 // "cobra despesas"
	ElseIf !lQryCobH .And. !lQryCobDP .And. lQryCobLT
		cMsgTipoCob := STR0295 // "cobra lançamentos tabelados"
	EndIf
		
	cMensagem := CRLF + I18n(STR0288, {cQryCliLoj, cQryCaso, cQryContr, cMsgTipoCob}) // "Cliente '#1' - Caso '#2' está vinculado ao contrato #3 que #4."

Return cMensagem


//-------------------------------------------------------------------
/*/{Protheus.doc} J096AddFilPar
Realiza a proteção para avaliar se chamará a função antiga (SAddFilPar) ou a nossa função nova (JurAddFilPar).

@param cField      Campo que será utilizado no filtro
@param cOper       Operador que será aplicado no filtro (Ex: '==', '$')
@param xExpression Expressão do filtro (Ex: %NV4_CCLIEN0%)
@param aFilParser  Parser do filtro
       [n,1] String contendo o campo, operador ou expressão do filtro
       [n,2] Indica o tipo do parser (FIELD=Campo,OPERATOR=Operador e EXPRESSION=Expressão)

@return Nil

@author Leandro Sabino
@since  24/01/2025
/*/
//-------------------------------------------------------------------
Static Function J96AddFilPar(cField,cOper,xExpression,aFilParser)

	If FindFunction("JurAddFilPar") // proteção por que a função esta no JURXFUNC
		JurAddFilPar(cField,cOper,xExpression,aFilParser)
	ElseIf FindFunction("SAddFilPar") // proteção para evitar errorlog
		SAddFilPar(cField,cOper,xExpression,aFilParser)
	Else
		JurLogMsg(STR0313)//"Não existem as funções SAddFilPar e JurAddFilPar para realizar o filtro"
	EndIf

Return NIL

//-------------------------------------------------------------------
/*/{Protheus.doc} J096VldNWE
Valida se as parcelas pendentes possuem movimentações.

@param cCodCtr    Codigo do Contrato

@return lRet       Indica se o contrato possui parcelas pendentes com movimentações

@author Victor Hayashi
@since  31/03/2025
/*/
//-------------------------------------------------------------------
Static Function J096VldNWE(cCodCtr)
Local oQuery    := Nil // Objeto de Query do caso
Local cQuery    := ""  // String da Query
Local cAliasQry := GetNextAlias() // Alias para a query
Local nParam    := 0   // Contador para o Bind Parameters
Local lRet      := .F. // Retorno da função

	cQuery := "SELECT COUNT(*) AS QTD
	cQuery +=  " FROM " + RetSqlName("NT1") + " NT1"
	cQuery += " INNER JOIN " + RetSqlName("NWE") + " NWE"
	cQuery +=    " ON NWE.NWE_FILIAL = NT1.NT1_FILIAL"
	cQuery +=   " AND NWE.NWE_CFIXO = NT1.NT1_SEQUEN"
	cQuery +=   " AND NWE.D_E_L_E_T_ = ?"
	cQuery += " WHERE NT1.NT1_FILIAL = ?"
	cQuery +=   " AND NT1.NT1_CCONTR = ?"
	cQuery +=   " AND NT1.NT1_SITUAC = ?"
	cQuery +=   " AND NT1.D_E_L_E_T_ = ?"

	oQuery := FWPreparedStatement():New(cQuery)
	oQuery:SetString(++nParam, Space(1))       // NWE.D_E_L_E_T_
	oQuery:SetString(++nParam, xFilial("NT1")) // NT1_FILIAL
	oQuery:SetString(++nParam, cCodCtr)        // NT1_CCONTR
	oQuery:SetString(++nParam, '1')            // NT1_SITUAC
	oQuery:SetString(++nParam, Space(1))       // NT1.D_E_L_E_T_
	cQuery := oQuery:GetFixQuery()
	MpSysOpenQuery(cQuery, cAliasQry)

	lRet := ((cAliasQry)->QTD > 0)

	oQuery:Destroy(0)
	(cAliasQry)->(dbCloseArea())

Return lRet
