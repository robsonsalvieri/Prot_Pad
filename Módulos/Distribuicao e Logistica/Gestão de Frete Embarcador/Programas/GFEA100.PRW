#INCLUDE "GFEA100.ch"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"  

Static __lLogIntP := IIF(SuperGetMv("MV_GFELPR",,'1') == '2',.F., .T.)//Indica se será gerado ou não o log da integração com o ERP Protheus

// Constante usada na função AddToLog()
#DEFINE _LOG_END   2

//-------------------------------------------------------------------
/*/{Protheus.doc} GFEA100

Geração de contratos com autônomos
 
@author Jorge Matos Valcanaia
@since 17/02/10
@version 1.0
/*/
//-------------------------------------------------------------------
Function GFEA100()
	Local oBrowse
	Private nGFEEDIL  := SuperGetMV('MV_GFEEDIL',,'1')
	Private GFELog100 := GFELog():New("Contrato_Autonomo_"+GW2->GW2_FILIAL+'_'+GW2->GW2_NRCONT, "Cálculo Impostos Autônomo", nGFEEDIL)
	Private aRotina   := MenuDef()	

	oBrowse := FWMBrowse():New()    // Criando novo browse
	oBrowse:SetAlias("GW2")			// Alias da tabela utilizada
	oBrowse:SetMenuDef("GFEA100")	// Nome do fonte onde esta a função MenuDef
	oBrowse:SetDescription(STR0001)	// Descrição do browse //"Geração de contratos com autônomos"

	oBrowse:AddLegend("GW2_SITCON=='1'", "WHITE", "Criado")     //"Criado"
	oBrowse:AddLegend("GW2_SITCON=='2'", "GREEN", "Confirmado") //"Confirmado"
	oBrowse:AddLegend("GW2_SITCON=='3'", "BLUE" , "Emitido")   //"Impresso"
	oBrowse:AddLegend("GW2_SITCON=='4'", "RED"  , "Cancelado")  //"Cancelado"

	oBrowse:Activate()
Return(Nil)

//-------------------------------------------------------------------
Static Function MenuDef()
Local aRotina := {}
//-------------------------------------------------------------------
// Adiciona botões do browse
//-------------------------------------------------------------------
ADD OPTION aRotina TITLE STR0002                       ACTION "AxPesqui"        OPERATION 1  ACCESS 0 //"Pesquisar"
ADD OPTION aRotina TITLE STR0003                       ACTION "VIEWDEF.GFEC100" OPERATION 2  ACCESS 0 //"Visualizar"
ADD OPTION aRotina TITLE STR0004                       ACTION "VIEWDEF.GFEA100" OPERATION 3  ACCESS 0 //"Incluir"
ADD OPTION aRotina TITLE STR0005                       ACTION "GFEA100VA(4)"    OPERATION 4  ACCESS 0 //"Alterar"
ADD OPTION aRotina TITLE STR0006                       ACTION "GFEA100CA"       OPERATION 10 ACCESS 0 //"Cancelar"
ADD OPTION aRotina TITLE STR0007                       ACTION "GFEA100VA(5)"    OPERATION 5  ACCESS 0 //"Excluir"
ADD OPTION aRotina TITLE STR0008                       ACTION "VIEWDEF.GFEA100" OPERATION 8  ACCESS 0 //"Imprimir"
ADD OPTION aRotina TITLE "Atualizar ERP financeiro"    ACTION 'GFEA100X("1")'   OPERATION 10 ACCESS 0 //"Atualizar ERP financeiro"
ADD OPTION aRotina TITLE "Desatualizar ERP financeiro" ACTION 'GFEA100X("4")'   OPERATION 10 ACCESS 0 //"Desatualizar ERP financeiro"
ADD OPTION aRotina TITLE STR0010                       ACTION 'GFEA100X("2")'   OPERATION 10 ACCESS 0 //"Enviar ERP HCM"
ADD OPTION aRotina TITLE STR0011                       ACTION "GFEA100IM(2)"    OPERATION 18 ACCESS 0 //"Impostos"
ADD OPTION aRotina TITLE STR0012                       ACTION "GFEA100SC()"     OPERATION 12 ACCESS 0 //"Selecionar Cálculos"
ADD OPTION aRotina TITLE "Atualizar ERP Recebimento"   ACTION 'GFEA100X("3")'   OPERATION 11 ACCESS 0 // "Apropriação Despesa"
ADD OPTION aRotina TITLE "Destualizar ERP Recebimento" ACTION 'GFEA100X("5")'   OPERATION 11 ACCESS 0 // "Apropriação Despesa"
ADD OPTION aRotina TITLE "Anexos" ACTION "MsDocument('GW2',GW2->(RecNo()), 3)"  OPERATION  4 ACCESS 0  // "Anexo"

If ExistBlock("GFEA1001")
	aRotAdic := ExecBlock("GFEA1001",.f.,.f.)
	If ValType(aRotAdic) == "A"
		AEval(aRotAdic, {|x| AAdd(aRotina ,x)})
	EndIf
EndIf	
	
Return aRotina

//-------------------------------------------------------------------
Static Function ModelDef()
	Local oModel

	Local oStructGw2 := FWFormStruct(1,"GW2")
	Local oStructGw5 := FWFormStruct(1,"GW5")
	Local oStructGw9 := FWFormStruct(1,"GW9")
	Local oStructGWH := FWFormStruct(1,"GWH")

	// Acrescenta um campo a estrutura antes a criação do model
	oStructGw2:AddField( ;                      // Ord. Tipo Desc.
	STR0085                          , ;      // [01]  C   Titulo do campo //"CGG do Proprietário"
	STR0085                          , ;      // [02]  C   ToolTip do campo //"CGG do Proprietário"
	'GW2_CGCPRO'                     , ;      // [03]  C   Id do Field
	'C'                              , ;      // [04]  C   Tipo do campo
	21                               , ;      // [05]  N   Tamanho do campo
	0                                , ;      // [06]  N   Decimal do campo
	NIL                              , ;      // [07]  B   Code-block de validação do campo
	NIL                              , ;      // [08]  B   Code-block de validação When do campo
	NIL                              , ;      // [09]  A   Lista de valores permitido do campo
	NIL                              , ;      // [10]  L   Indica se o campo tem preenchimento obrigatório
	{ || '1' }                       , ;      // [11]  B   Code-block de inicializacao do campo
	NIL                              , ;      // [12]  L   Indica se trata-se de um campo chave
	NIL                              , ;      // [13]  L   Indica se o campo pode receber valor em uma operação de update.
	.T.                              )        // [14]  L   Indica se o campo é virtual


	// Acrescenta um campo a estrutura antes a criação do model
	oStructGw2:AddField( ;                      // Ord. Tipo Desc.
	STR0086                          , ;      // [01]  C   Titulo do campo //"Frete A Pagar"
	STR0086                          , ;      // [02]  C   ToolTip do campo //"Frete A Pagar"
	'GW2_CTFRET'                     , ;      // [03]  C   Id do Field
	'C'                              , ;      // [04]  C   Tipo do campo
	20                               , ;      // [05]  N   Tamanho do campo
	0                                , ;      // [06]  N   Decimal do campo
	NIL                              , ;      // [07]  B   Code-block de validação do campo
	NIL                              , ;      // [08]  B   Code-block de validação When do campo
	NIL                              , ;      // [09]  A   Lista de valores permitido do campo
	NIL                              , ;      // [10]  L   Indica se o campo tem preenchimento obrigatório
	{ || '1' }                       , ;      // [11]  B   Code-block de inicializacao do campo
	NIL                              , ;      // [12]  L   Indica se trata-se de um campo chave
	NIL                              , ;      // [13]  L   Indica se o campo pode receber valor em uma operação de update.
	.T.                              )        // [14]  L   Indica se o campo é virtual

	// cID     Identificador do modelo
	// bPre    Code-Block de pre-edição do formulário de edição. Indica se a edição esta liberada
	// bPost   Code-Block de validação do formulário de edição
	// bCommit Code-Block de persistência do formulário de edição
	// bCancel Code-Block de cancelamento do formulário de edição
	oModel := MPFormModel():New("GFEA100", /*bPre*/,  {|oModel| GFEA100PO(oModel) }/*bPost*/,/*bCommit*/, /*bCancel*/)
	oModel:SetVldActivate ( { |oMod| GFEA100VL( oMod ) } )
	// cId          Identificador do modelo
	// cOwner       Identificador superior do modelo
	// oModelStruct Objeto com  a estrutura de dados
	// bPre         Code-Block de pré-edição do formulário de edição. Indica se a edição esta liberada
	// bPost        Code-Block de validação do formulário de edição
	// bLoad        Code-Block de carga dos dados do formulário de edição
	oModel:AddFields("GFEA100_GW2", Nil, oStructGw2,/*bPre*/,/*bPost*/,/*bLoad*/)
	oModel:SetPrimaryKey({"GW2_FILIAL", "GW2_NRCONT"})

	oModel:AddGrid("GFEA100_GW5","GFEA100_GW2", oStructGW5,/*bLinePre*/,/*{|oMod| GFE44PSGWB(oMod)}*/,/*bPre*/,/*bPost*/,/*bLoad*/)
	oModel:SetRelation("GFEA100_GW5",{{"GW5_FILIAL","xFilial('GW5')"},{"GW5_NRCONT","GW2_NRCONT"}},"GW5_FILIAL+GW5_NRCONT")
	oModelGW5 = oModel:GetModel("GFEA100_GW5")

	oModel:AddGrid( "GFEA100_GW9" , "GFEA100_GW2" , oStructGw9 ,/*bLinePre*/,/**/,/*bLinePost*/,/*bPre*/,/*bPost*/,/*bLoad*/)
	oModel:SetRelation("GFEA100_GW9",{{"GW9_FILIAL",'xFilial("GW5")'},{"GW9_NRCONT" , "GW2_NRCONT"}},"GW9_FILIAL+GW9_NRCONT")

	oModel:GetModel( "GFEA100_GW9" ):SetOptional(.T.)

	oModel:AddGrid("GFEA100_GWH","GFEA100_GW2", oStructGWH, , , /*bPreVal*/, /*bPosVal*/,  {|oMod| GFEA100GWH(oMod)} )
	oModel:GetModel("GFEA100_GWH"):SetOptional(.T.)
	oModel:GetModel("GFEA100_GWH"):SetOnlyQuery(.T.)
	oModel:GetModel("GFEA100_GWH"):SetDescription("Documentos")
	oStructGWH:RemoveField("GWH_NRCALC")

	//oModelGW5:SetPrimaryKey({"GW2_FILIAL","GW2_NRCONT"})
	oModelGW5:SetUniqueLine({"GW5_CDVLAD"})
	oModelGW5:SetDescription("GW5")

	oModel:SetOptional("GFEA100_GW5", .T. )

Return oModel

Static Function ViewDef()
	Local oModel := FWLoadModel("GFEA100")
	Local oView := Nil
	Local oStructGW2 := FWFormStruct(2,"GW2")
	Local oStructGW5 := FWFormStruct(2,"GW5")

	oView := FWFormView():New()
	oView:SetModel(oModel)
	oView:AddField( "GFEA100_GW2" , oStructGW2 )
	oStructGW2:RemoveField("GW2_VLBAIN")
	oStructGW2:RemoveField("GW2_VLADIC")

	oView:AddGrid( "GFEA100_GW5" , oStructGW5)
	oStructGW5:RemoveField("GW5_FILIAL")
	oStructGW5:RemoveField("GW5_NRCONT")

	oView:CreateHorizontalBox( "MASTER" , 70)
	oView:CreateHorizontalBox( "DETAIL" , 30 )

	oView:CreateFolder("IDFOLDER","DETAIL")
	oView:AddSheet("IDFOLDER","IDSHEET02",STR0013)    //"Valores Adicionais"

	oView:CreateHorizontalBox( "DETAIL_GW5"  , 100,,,"IDFOLDER","IDSHEET02" )

	oView:SetOwnerView( "GFEA100_GW2" , "MASTER" )
	oView:SetOwnerView( "GFEA100_GW5" , "DETAIL_GW5" )

Return oView

/*--------------------------------------------------------------------------------------------------
{Protheus.doc} GFEA100GWH
Rotina para preencher o model com a chave dos itens utilizada na integração

@sample
GFEA100GWH()

@author Felipe Mendes
@since 24/02/2011
@version 1.0
--------------------------------------------------------------------------------------------------*/
Static Function GFEA100GWH(oModel)
Local nCont  := 1
Local aStruc := {}//Array para armazenar o struct da tabela
Local aRet   := {}//Array de retorno com os regitros. Formato ##array{ #linha{#recno 1, #campos{,,,}}, #linha{#recno 2, #campos{,,,}} }
Local aCmp   := {}
Local nRec   := 1 //Número de registros

aStruc := oModel:GetStruct()//Struct da tabela

dbSelectArea("GWF")
dbSetOrder(2)      //GWF_FILIAL+GWF_NRCONT
dbSeek(xFilial("GWF")+GW2->GW2_NRCONT)
While !Eof() .And. xFilial("GWF")+GW2->GW2_NRCONT == GWF->GWF_FILIAL + GWF->GWF_NRCONT

	dbSelectArea("GWH")
    dbSetOrder(1)
    dbSeek(xFilial("GWH")+GWF->GWF_NRCALC)
    While !Eof() .And. xFilial("GWH")+GWF->GWF_NRCALC == GWH->GWH_FILIAL + GWH->GWH_NRCALC

		While nCont <= Len(aStruc:AFIELDS)

			AAdd(aCmp, &("GWH->"+aStruc:AFIELDS[nCont][3]))
			nCont++

		EndDo

		//Monta o array de acordo com a sequência de campos do struct, para ser mostrado no grid.
		AAdd(aRet,{nRec, aCmp})
		
		aCmp  := {}
		nCont := 1
		nRec++

		GWH->(dbSkip())

	EndDo

    GWF->(dbSkip())

EndDo

//Caso não encontre registros, permanece o array em branco Obs: Permanecer todas as 'vírgulas' para não ocorrer erros
If Empty(aRet)
	aRet := {{0,{,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,}}}
EndIf

dbSelectArea("GW3")

Return aRet
//-------------------------------------------------------------------
/*/{Protheus.doc} GFEA100SC

Abre uma tela para que seja incluido um vinculo entre o cálculo de frete e o contrato com autonomo.

@author Jorge Matos Valcanaia
@since 19/02/10
@version 1.0
/*/
//-------------------------------------------------------------------
Function GFEA100SC()
Local oDlg
Local nAlt := 600
Local nLrg := 1200
Local cProp
Local oCheck
Local lCheck :=.F.

If GW2->GW2_SITCON == "3"
	Help( ,, 'HELP',,STR0014, 1, 0) //"Contrato já foi impresso, não pode mais ser alterado."
	Return .F.
Endif
If  GW2->GW2_SITCON == "4"
	Help( ,, 'HELP',,STR0015, 1, 0) //"Contrato já foi cancelado, não pode mais ser alterado."
	Return .F.
Endif

If !Pergunte("GFEA100",.T.) /*Abre o grupo de perguntas para o usuario e se for cancelado o grupo fecha e não executa ação nenhuma*/
   Return Nil
Endif

Private cCadastro := STR0012 //"Selecionar Cálculos"
Private cMarca := GetMark()
private oListDoc
//----------------------------------------------
// Criacao da tabela temporaria p/ Markbrowse
//----------------------------------------------

aMKB :=    {{"OK"     ,"C",02,0},;
			{"NRCALC" ,"C",08,0},;
			{"DTCRIA" ,"D",08,0},;
			{"REMET"  ,"C",50,0},;
			{"DEST"   ,"C",50,0},;
			{"ENTRAD" ,"C",03,0},;
			{"NRROM"  ,"C",08,0},;
			{"TPOPER" ,"C",01,0},;
			{"VLFRET" ,"N",14,2},;
			{"NMMOTO" ,"C",50,0},;
			{"CDMOTO" ,"C",16,0},;
			{"VEIC1"  ,"C",14,0},;
			{"VEIC2"  ,"C",14,0},;
			{"VEIC3"  ,"C",14,0}}


aCpMKB  := {{"OK"    , NIL, ""     , ""  },;
			{"NRCALC", NIL, STR0016, "@!"},; //"Cálculo"
			{"DTCRIA", NIL, STR0017, ""  },; //"Data de Criação"
			{"REMET" , NIL, STR0018, "@!"},; //"Remetente"
			{"DEST"  , NIL, STR0019, "@!"},; //"Destinatário"
			{"ENTRAD", NIL, STR0020, "@!"},; //"Entrada?"
			{"NRROM" , NIL, STR0021, "@!"},; //"Romaneio"
			{"TPOPER", NIL, STR0022, "@!"},; //"Tipo Operação"
			{"VLFRET", NIL, STR0023, "@E 999,999,999.99"},; //"Valor Frete"
			{"NMMOTO", NIL, STR0024, "@!"},; //"Motorista"
			{"VEIC1" , NIL, STR0025, "@!"},; //"Veículo 1"
			{"VEIC2" , NIL, STR0026, "@!"},; //"Veículo 2"
			{"VEIC3" , NIL, STR0027, "@!"}} //"Veículo 3"

cAliMKB := GFECriaTab({ aMKB, {"NRCALC"}})

//----------------------------------------------
// Criacao da tabela temporaria p/ Markbrowse
//----------------------------------------------

aMKB2 :=   {{"OK"     ,"C",02,0},;
			{"NRCALC" ,"C",08,0},;
			{"DTCRIA" ,"D",08,0},;
			{"REMET"  ,"C",50,0},;
			{"DEST"   ,"C",50,0},;
			{"ENTRAD" ,"C",03,0},;
			{"NRROM"  ,"C",08,0},;
			{"TPOPER" ,"C",01,0},;
			{"VLFRET" ,"N",14,2},;
			{"NMMOTO" ,"C",50,0},;
			{"CDMOTO" ,"C",16,0},;
			{"VEIC1"  ,"C",14,0},;
			{"VEIC2"  ,"C",14,0},;
			{"VEIC3"  ,"C",14,0}}

aCpMKB2  := {{"OK"   , NIL, ""     , ""  },;
			{"NRCALC", NIL, STR0016, "@!"},; //"Cálculo"
			{"DTCRIA", NIL, STR0017, ""  },; //"Data de Criação"
			{"REMET" , NIL, STR0018, "@!"},; //"Remetente"
			{"DEST"  , NIL, STR0019, "@!"},; //"Destinatário"
			{"ENTRAD", NIL, STR0020, "@!"},; //"Entrada?"
			{"NRROM" , NIL, STR0021, "@!"},; //"Romaneio"
			{"TPOPER", NIL, STR0022, "@!"},; //"Tipo Operação"
			{"VLFRET", NIL, STR0023, "@E 999,999,999.99"},; //"Valor Frete"
			{"NMMOTO", NIL, STR0024, "@!"},; //"Motorista"
			{"VEIC1" , NIL, STR0025, "@!"},; //"Veículo 1"
			{"VEIC2" , NIL, STR0026, "@!"},; //"Veículo 2"
			{"VEIC3" , NIL, STR0027, "@!"}} //"Veículo 3"

cAliMKB2 := GFECriaTab({ aMKB2, {"NRCALC"}})

//--------------------------
// Montagem da tela
//--------------------------
Define MsDialog oDlg Title cCadastro From 00,00 To nAlt,nLrg Of oMainWnd Color CLR_BLACK,RGB(225,225,225) Pixel
oDlg:lEscClose := .F.

//----- Painel superior da tela principal, com as informacoes do romaneio -----//
oPnlA := tPanel():New(00,00,,oDlg,,,,,,10,20,.F.,.F.)
	oPnlA:Align := CONTROL_ALIGN_TOP

//----- Splitter para permitir ao usuario movimentar os paineis dos browses -----//
oSplitter := tSplitter():New( 0,0,oDLG,100,100,1 )
	oSplitter:Align := CONTROL_ALIGN_ALLCLIENT

	//----- Painel superior da tela, para o browse de documentos de cargas -----//
	oPanelB := TPanel():New(01,01,,oSplitter,,,,,,0,0,.F.,.T.)
		oPanelB:Align := CONTROL_ALIGN_TOP

			//----- Painel lateral do browse de documentos relacionados, para adicionar botoes -----//
		oPnlBtn1:=TPanel():New(00,00,,oPanelB,,,,,RGB(67,70,87),15,15,.F.,.F.)
			oPnlBtn1:Align := CONTROL_ALIGN_LEFT

			    //------ Botao para adicionar relacionamento do Documento de carga com o romaneio -----//

				oBtnAdd  := TBtnBmp():NewBar("DOWN","DOWN",,,,{||GFEA100CK()},,oPnlBtn1,,,"",,,,,"")
				oBtnAdd:cToolTip := STR0029 //"Adicionar"
				oBtnAdd:Align    := CONTROL_ALIGN_TOP

				//------ Botao para Filtro do Documento de carga com o romaneio -----//
				oBtnFiltro			:= TBtnBmp():NewBar("brw_filtro","brw_filtro",,,,{||GFE100FIL()},,oPnlBtn1,,,"",,,,,"")
				oBtnFiltro:cToolTip := STR0030 //"Filtrar"
				oBtnFiltro:Align    := CONTROL_ALIGN_TOP

		//----- Painel superior do browse de documentos de carga, para colocar o titulo -----//
		oPnlBtn:=TPanel():New(00,00,,oPanelB,,,,,RGB(67,70,87),12,12,.F.,.F.)
			oPnlBtn:Align := CONTROL_ALIGN_TOP
			oFont12B := TFont():New('Arial',,-12,,.T.)
    		@ 03,14  Say STR0031 Of oPnlBtn COLOR CLR_WHITE Pixel font oFont12B  //"Selecione os Cálculos"
	//---------------- Fim do painel superior da tela ------------------//


	//----- Painel inferior da tela, para o browse de documentos relacionados -----//
	oPanelC := TPanel():New(01,01,,oSplitter,,,,,,0,0,.F.,.T.)
		oPanelC:Align := CONTROL_ALIGN_BOTTOM

		//----- Painel lateral do browse de documentos relacionados, para adicionar botoes -----//
		oPnlBtn2:=TPanel():New(00,00,,oPanelC,,,,,RGB(67,70,87),15,15,.F.,.F.)
			oPnlBtn2:Align := CONTROL_ALIGN_LEFT

			    //------ Botao para excluir relacionamento do Documento de carga com o romaneio -----//
				oBtnDel  := TBtnBmp():NewBar("UP","UP",,,,{||GFE100DLC()},,oPnlBtn2,,,"",,,,,"")
				oBtnDel:cToolTip := STR0007 //"Excluir"
				oBtnDel:Align    := CONTROL_ALIGN_TOP

		//----- Painel superior do browse de documentos relacionados, para colocar o titulo -----//
		oPnlBtn3:=TPanel():New(00,00,,oPanelC,,,,,RGB(67,70,87),12,12,.F.,.F.)
			oPnlBtn3:Align := CONTROL_ALIGN_TOP
			oFont12B := TFont():New('Arial',,-12,,.T.)
    		@ 03,14  Say STR0032 Of oPnlBtn3 COLOR CLR_WHITE Pixel font oFont12B 	 //"Cálculos Relacionados ao Contrato "
    		oCheck:= tCheckBox():New(01,180,STR0033,{|u|if( pcount()>0,lCheck:=u,lCheck)},oPnlBtn3,160,12,,,oFont12B,,RGB( 255, 255, 255 ),,,.T.) //"Atualizar Veículos e Motoristas no Contrato?"
	//--------------- Fim do painel inferior da tela principal-----------------------//

	// ----- Criacao dos fields referente ao romaneio no painel superior da tela principal -----//
	cProp := posicione("GU3",1,xFilial("GU3")+GW2->GW2_CDPROP,"GU3_NMEMIT")
	@ 07,10  Say STR0034 Of oPnlA COLOR CLR_BLACK Pixel //"Contrato: "
   	@ 05,33  MSGET GW2->GW2_NRCONT Picture "@!" Of oPnlA When .F.   Pixel

	@ 07,90  Say STR0035 Of oPnlA COLOR CLR_BLACK Pixel //"Proprietário: "
   	@ 05,120 MSGET GW2->GW2_CDPROP Picture "@!" Of oPnlA When .F.   Pixel
  	@ 05,175 MSGET cProp Picture "@!" Of oPnlA When .F.   Pixel

	//---------Fim da criacao dos fields ----------//

		//--1----- Seleciona a temp-table de Documentos de cargas que nao foram relacionados ao romaneio e cria o browse -----//
		dbSelectArea(cAliMKB)
		dbSetOrder(1)
		dbGoTop()
		oMark := MsSelect():New(cAliMKB,"OK",,aCpMKB,,@cMarca,{0,0,0,0},,,oPanelB)
		oMark:oBrowse:cToolTip := STR0036 //"Cálculos de Frete"
		oMark:oBrowse:Align := CONTROL_ALIGN_ALLCLIENT
		//--------------Fim 1 -- criado o browse---------------//
		//--2----- Seleciona a temp-table de Documentos de cargas que ja foram relacionados ao romaneio e cria o browse -----//
		dbSelectArea(cAliMKB2)
		dbSetOrder(1)
		dbGoTop()
		@ 0,0 Listbox oListDoc Fields (cAliMKB2)->NRCALC ,;
		                              (cAliMKB2)->DTCRIA ,;
									  (cAliMKB2)->REMET  ,;
								      (cAliMKB2)->DEST   ,;
				                      (cAliMKB2)->ENTRAD ,;
				                      (cAliMKB2)->NRROM  ,;
									  (cAliMKB2)->TPOPER ,;
									  (cAliMKB2)->VLFRET ,;
									  (cAliMKB2)->NMMOTO ,;
  									  (cAliMKB2)->VEIC1  ,;
  									  (cAliMKB2)->VEIC2  ,;
  									  (cAliMKB2)->VEIC3   ;
									  FieldSizes 50,50,135,135,45,50,45,66,45,66,66,66;
				                      Size 140,290 Pixel Of oPanelC   ;
				                      HEADERS STR0016        ,; //"Cálculo"
				                              STR0037   ,; //"Data Criação"
				                              STR0018      ,; //"Remetente"
				                              STR0019   ,; //"Destinatário"
				                              STR0020       ,; //"Entrada?"
				                              STR0021       ,; //"Romaneio"
				                              STR0022  ,; //"Tipo Operação"
				                              STR0023    ,; //"Valor Frete"
				                              STR0038 ,; //"Nome Motorista"
				                              STR0025      ,; //"Veículo 1"
				                              STR0026      ,; //"Veículo 2"
				                              STR0027    //"Veículo 3"


		oListDoc:Align := CONTROL_ALIGN_ALLCLIENT
		//--------------Fim 2--------------------//

	//----- Processa os registros e carrega os browses -----//
	Processa({|lEnd| GFE100MKB()},STR0039,STR0040) //"Processando informações"###"Aguarde"
	CursorArrow()

	ACTIVATE MSDIALOG oDlg ON INIT(EnchoiceBar(ODlg,{|| IF(GFEa100OK(lCheck),ODlg:End(),NIL)},{||ODlg:End()},),,oMark:oBrowse:Gotop()) CENTERED

//------ Limpa as tabelas temporarias -----//
GFEDelTab(cAliMKB)
GFEDelTab(cAliMKB2)
//-----------------------------------------//

//Depois de limpar as temp-table é necessário selecionar uma tabela, para que não ocorra erros//
dbSelectArea("GW2")
Return

//-------------------------------------------------------------------
/*/{Protheus.doc} GFE100MKB
Acrescenta os registros na tabela temporaria para que eles sejam exibidos na tela

@author Jorge Matos Valcanaia
@since 19/02/10
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function GFE100MKB()
	Local cNmMoto 	:= ""
	Local cVei1   	:= ""
	Local cVei2   	:= ""
	Local cVei3   	:= ""
	Local cAliasGWF := ""
	Local cCodMoto	:= ""
	Local cEmiRem	:= ""
	Local cEmiDes	:= ""
	Local nVlFret	:= ""
	Local cEntrada	:= ""
	Local dDtCria

	dbSelectArea(cAliMKB)
	ZAP
	dbSelectArea(cAliMKB2)
	ZAP

	dbSelectArea(cAliMKB)

	cAliasGWF := GetNextAlias()

	BeginSQL Alias cAliasGWF
		SELECT GWF_FILIAL, GWF_FINCAL, GWF_TRANSP, GWF_NRROM, GWF_NRCALC, GWF_DTCRIA, GWF_TPCALC, GWF_EMIREM, GWF_EMIDES
		FROM %Table:GWF% GWF
		WHERE GWF.GWF_FILIAL = %xFilial:GWF%
		AND GWF.GWF_DTCRIA BETWEEN %Exp:MV_PAR01% AND %Exp:MV_PAR02%
		AND GWF.GWF_NRCONT = ''
		AND GWF.%NotDel%
	EndSQL

	(cAliasGWF)->( dbGoTop() )
	Do While (cAliasGWF)->(!Eof())
		If (cAliasGWF)->GWF_FINCAL == "3" // Contrato
			If (cAliasGWF)->GWF_TRANSP <> GW2->GW2_CDPROP
				(cAliasGWF)->(DbSkip())
				Loop
			Endif
			GWN->(dbSetOrder(1))
			If GWN->(dbSeek(xFilial("GWN")+(cAliasGWF)->GWF_NRROM))
				If GWN->GWN_SIT != "3" .And. GWN->GWN_SIT != "4"
					(cAliasGWF)->(DbSkip())
					Loop
				EndIf
				cCodMoto	:= GWN->GWN_CDMTR
				cVei1		:= GWN->GWN_PLACAD
				cVei2   	:= GWN->GWN_PLACAT
				cVei3		:= GWN->GWN_PLACAM
			EndIf

			GU3->(dbSetOrder(1))
			If GU3->(dbSeek(xFilial("GU3")+(cAliasGWF)->GWF_TRANSP))
				GWH->(dbSetOrder(1))
				GWH->(dbSeek(xFilial("GWH")+(cAliasGWF)->GWF_NRCALC))
				While !Eof() .And. xFilial("GWF") == (cAliasGWF)->GWF_FILIAL .And. GWH->GWH_NRCALC == (cAliasGWF)->GWF_NRCALC
					GW1->(dbSetOrder(1))
					GW1->(dbSeek(xFilial("GW1")+GWH->GWH_CDTPDC+GWH->GWH_EMISDC+GWH->GWH_SERDC+GWH->GWH_NRDC))
					While !Eof() .And. xFilial("GW1") == GW1->GW1_FILIAL .And. GW1->GW1_CDTPDC == GWH->GWH_CDTPDC .And. GW1->GW1_EMISDC == GWH->GWH_EMISDC .And. GW1->GW1_SERDC == GWH->GWH_SERDC .And. GW1->GW1_NRDC == GWH->GWH_NRDC
						If GU3->GU3_AUTON == "1"
							If GU3->GU3_ENTOBR == "1"
								GWU->(dbSetOrder(1))
								GWU->(dbSeek(xFilial("GWU")+GW1->GW1_CDTPDC+GW1->GW1_EMISDC+GW1->GW1_SERDC+GW1->GW1_NRDC))
								While !Eof() .And. xFilial("GWU") == GWU->GWU_FILIAL .And. GWU->GWU_CDTPDC == GW1->GW1_CDTPDC;
									.And. GWU->GWU_EMISDC == GW1->GW1_EMISDC .And. GWU->GWU_SERDC == GW1->GW1_SERDC .And. GWU->GWU_NRDC == GW1->GW1_NRDC
									If GWU->GWU_CDTRP == GW2->GW2_CDPROP
										If !Empty(GWU->GWU_DTENT)
											GV5->(dbSetOrder(1))
											If GV5->(dbSeek(xFilial("GV5")+GW1->GW1_CDTPDC))
												If MV_PAR03 == 1 .And. GV5->GV5_SENTID == "1"
													cEntrada := "Sim
												ElseIf MV_PAR03 == 2 .And. GV5->GV5_SENTID <> "1"
													cEntrada := "Não
												EndIf
												If !Empty(cEntrada)
													cEmiRem := Posicione("GU3",1,xFilial("GU3")+(cAliasGWF)->GWF_EMIREM,"GU3_NMEMIT")
													cEmiDes := Posicione("GU3",1,xFilial("GU3")+(cAliasGWF)->GWF_EMIDES,"GU3_NMEMIT")
													nVlFret := VLTOTFRET((cAliasGWF)->GWF_FILIAL,(cAliasGWF)->GWF_NRCALC)
													cNmMoto := Posicione("GUU",1,xFilial("GUU")+cCodMoto,"GUU_NMMTR")
													dDtCria	:= StoD((cAliasGWF)->GWF_DTCRIA)

													RecLock(cAliMKB,.T.)
														(cAliMKB)->NRCALC := (cAliasGWF)->GWF_NRCALC
														(cAliMKB)->DTCRIA := dDtCria
														(cAliMKB)->REMET  := cEmiRem
														(cAliMKB)->DEST   := cEmiDes
														(cAliMKB)->ENTRAD := cEntrada
														(cAliMKB)->NRROM  := (cAliasGWF)->GWF_NRROM
														(cAliMKB)->TPOPER := (cAliasGWF)->GWF_TPCALC
														(cAliMKB)->VLFRET := nVlFret
														(cAliMKB)->NMMOTO := cNmMoto
														(cAliMKB)->VEIC1  := cVei1
														(cAliMKB)->VEIC2  := cVei2
														(cAliMKB)->VEIC3  := cVei3
													MsUnLock(cAliMKB)
												EndIf
											EndIf
										EndIf
									EndIf
									GWU->(dbSkip())
								EndDo
							Else
								GV5->(dbSetOrder(1))
								If GV5->(dbSeek(xFilial("GV5")+GW1->GW1_CDTPDC))
									If MV_PAR03 == 1 .And. GV5->GV5_SENTID == "1"
										cEntrada := "Sim"
									ElseIf MV_PAR03 == 2 .And. GV5->GV5_SENTID <> "1"
										cEntrada := "Não"
									EndIf
									If !Empty(cEntrada)
										cEmiRem := Posicione("GU3",1,xFilial("GU3")+(cAliasGWF)->GWF_EMIREM,"GU3_NMEMIT")
										cEmiDes := Posicione("GU3",1,xFilial("GU3")+(cAliasGWF)->GWF_EMIDES,"GU3_NMEMIT")
										nVlFret := VLTOTFRET((cAliasGWF)->GWF_FILIAL,(cAliasGWF)->GWF_NRCALC)
										cNmMoto := Posicione("GUU",1,xFilial("GUU")+cCodMoto,"GUU_NMMTR")
										dDtCria	:= StoD((cAliasGWF)->GWF_DTCRIA)

										RecLock(cAliMKB,.T.)
											(cAliMKB)->NRCALC := (cAliasGWF)->GWF_NRCALC
											(cAliMKB)->DTCRIA := dDtCria
											(cAliMKB)->REMET  := cEmiRem
											(cAliMKB)->DEST   := cEmiDes
											(cAliMKB)->ENTRAD := cEntrada
											(cAliMKB)->NRROM  := (cAliasGWF)->GWF_NRROM
											(cAliMKB)->TPOPER := (cAliasGWF)->GWF_TPCALC
											(cAliMKB)->VLFRET := nVlFret
											(cAliMKB)->NMMOTO := cNmMoto
											(cAliMKB)->VEIC1  := cVei1
											(cAliMKB)->VEIC2  := cVei2
											(cAliMKB)->VEIC3  := cVei3
										MsUnLock(cAliMKB)
									EndIf
								EndIf
							EndIf
						EndIf
						GW1->(dbSkip())
					EndDo
					GWH->(dbSkip())
				EndDo
			EndIf
		EndIf
		(cAliasGWF)->(dbSkip())
	EndDo

	(cAliasGWF)->(dbCloseArea())

	cAliasGWF := GetNextAlias()
	
	BeginSQL Alias cAliasGWF
		SELECT GWF_FILIAL, GWF_NRROM, GWF_NRCALC, GWF_EMIREM, GWF_EMIDES, GWF_DTCRIA, GWF_TPCALC
		FROM %Table:GWF% GWF
		WHERE GWF.GWF_FILIAL = %xFilial:GWF%
		AND GWF.GWF_NRCONT = %Exp:GW2->GW2_NRCONT%
		AND GWF.%NotDel%
	EndSQL

	(cAliasGWF)->( dbGoTop() )
	Do While (cAliasGWF)->(!Eof())
		GWN->(dbSetOrder(1))
		If GWN->(dbSeek(xFilial("GWN")+(cAliasGWF)->GWF_NRROM))
			cCodMoto	:= GWN->GWN_CDMTR
			cVei1		:= GWN->GWN_PLACAD
			cVei2   	:= GWN->GWN_PLACAT
			cVei3		:= GWN->GWN_PLACAM
		EndIf

		GWH->(dbSetOrder(1))
		If GWH->(dbSeek(xFilial("GWH")+(cAliasGWF)->GWF_NRCALC))

			GW1->(dbSetOrder(1))
			GW1->(dbSeek(xFilial("GW1")+GWH->GWH_CDTPDC+GWH->GWH_EMISDC+GWH->GWH_SERDC+GWH->GWH_NRDC))
			
			GV5->(dbSetOrder(1))
			If GV5->(dbSeek(xFilial("GV5")+GWH->GWH_CDTPDC))
				If GV5->GV5_SENTID == "1"
					cEntrada := "Sim"
				Else
					cEntrada := "Não"
				EndIf					
					cSitRec := IntSITREC("1",GV5->GV5_FRCTB,GW1->GW1_USO)	
					RecLock("GW2", .F.)
						GW2->GW2_SITREC := cSitRec
					GW2->( MsUnlock() )

					cEmiRem := Posicione("GU3",1,xFilial("GU3")+(cAliasGWF)->GWF_EMIREM,"GU3_NMEMIT")
					cEmiDes := Posicione("GU3",1,xFilial("GU3")+(cAliasGWF)->GWF_EMIDES,"GU3_NMEMIT")
					nVlFret := VLTOTFRET((cAliasGWF)->GWF_FILIAL,(cAliasGWF)->GWF_NRCALC)
					cNmMoto := Posicione("GUU",1,xFilial("GUU")+cCodMoto,"GUU_NMMTR")
					dDtCria	:= StoD((cAliasGWF)->GWF_DTCRIA)

					RecLock(cAliMKB2,.T.)
						(cAliMKB2)->NRCALC := (cAliasGWF)->GWF_NRCALC
						(cAliMKB2)->DTCRIA := dDtCria
						(cAliMKB2)->REMET  := cEmiRem
						(cAliMKB2)->DEST   := cEmiDes
						(cAliMKB2)->ENTRAD := cEntrada
						(cAliMKB2)->NRROM  := (cAliasGWF)->GWF_NRROM
						(cAliMKB2)->TPOPER := (cAliasGWF)->GWF_TPCALC
						(cAliMKB2)->VLFRET := nVlFret
						(cAliMKB2)->NMMOTO := cNmMoto
						(cAliMKB2)->CDMOTO := cCodMoto
						(cAliMKB2)->VEIC1  := cVei1
						(cAliMKB2)->VEIC2  := cVei2
						(cAliMKB2)->VEIC3  := cVei3
					MsUnLock(cAliMKB2)
			EndIf
		EndIf
		(cAliasGWF)->(dbSkip())
	EndDo

	(cAliasGWF)->(dbCloseArea())

	(cAliMKB)->( dbGoTop() )
	oMark:oBrowse:Refresh()

	(cAliMKB2)->( dbGoTop() )
	oListDoc:Refresh()
Return

//-------------------------------------------------------------------
/*/{Protheus.doc} GFEA100CK
Salva o número do contrato no Cálculo de Frete

@author Jorge Matos Valcanaia
@since 19/02/10
@version 1.0
/*/
//-------------------------------------------------------------------
Function GFEA100CK()
	dbSelectARea("GWF")
	dbSetOrder(2)
	dbSeek(xFilial("GWF")+GW2->GW2_NRCONT)
	While !Eof() .And. xFilial("GWF") == GWF->GWF_FILIAL .And. GWF->GWF_NRCONT == GW2->GW2_NRCONT
		dbSelectArea("GWH")
		dbSetOrder(1)
		dbSeek(xFilial("GWH")+GWF->GWF_NRCALC)
		While !Eof() .And. xFilial("GWF") == GWF->GWF_FILIAL .And. GWH->GWH_NRCALC == GWF->GWF_NRCALC
			dbSelectArea("GW1")
			dbSetOrder(1)
			dbSeek(xFilial("GW1")+GWH->GWH_CDTPDC+GWH->GWH_EMISDC+GWH->GWH_SERDC+GWH->GWH_NRDC) /*Posiciona no primeiro Documento de Carga a partir de um Registro da tabela de vinculo*/
			While !Eof() .And. xFilial("GW1") == GW1->GW1_FILIAL .And. GW1->GW1_CDTPDC == GWH->GWH_CDTPDC .And. GW1->GW1_EMISDC == GWH->GWH_EMISDC .And. GW1->GW1_SERDC == GWH->GWH_SERDC .And. GW1->GW1_NRDC == GWH->GWH_NRDC/*Continua no While enquanto a filial,código do tipo do documento, emissor do documento e a série seja a mesma do registro passado no dbSeek*/
				dbSelectArea("GV5")
				dbSetOrder(1)
				If dbSeek(xFilial("GV5")+GW1->GW1_CDTPDC)
					If MV_PAR03 == 1 // Permitir documentos de entrada
						If GV5->GV5_SENTID <> "1" // Mas somente se não houver documentos de saída
							Help( ,, 'HELP',,STR0041, 1, 0) //"O Contrato já possui Cálculos de saída vinculados."
							Return .F.
						Endif
					Elseif MV_PAR03 == 2 // Permite somente documentos de saída
						If GV5->GV5_SENTID == "1"	// Mas somente se não houver documentos de entrada
							Help( ,, 'HELP',,STR0042, 1, 0) //"O Contrato já possui Cálculos de entrada vinculados."
							Return .F.
						Endif
					Endif
				Endif
				dbSelectArea("GW1")
				dbSkip()
			EndDo
			dbSelectArea("GWH")
			dbSkip()
		EndDo
		dbSelectArea("GWF")
		dbSkip()
	EndDo

	dbSelectArea(cAliMKB)
	dbSetOrder(1)
	dbgotop()
	While !Eof()
		If IsMark('OK',cMarca)  // Verifica se o Registro foi selecionado
			dbSelectArea("GWF")
			dbSetOrder(1)
			If dbSeek(xFilial("GWF")+(cAliMKB)->NRCALC)
				RecLock("GWF",.F.)
				GWF->GWF_NRCONT := GW2->GW2_NRCONT
				MsUnLock("GWF")

				RecLock("GW2",.F.)
				GW2->GW2_VLISS += GWF->GWF_VLISS
				MsUnLock("GW2")
			Endif
		EndIf
		dbSelectArea(cAliMKB)
		dbskip()
	EndDo
	/*Atualiza a tela principal*/
	Processa({|lEnd| GFE100MKB()},STR0039,STR0040)  //"Processando informações"###"Aguarde"
return

//-------------------------------------------------------------------
/*/{Protheus.doc} GFE100DLC
Remove o número do contrato no Cálculo de Frete

@author Jorge Matos Valcanaia
@since 19/02/10
@version 1.0
/*/
//-------------------------------------------------------------------
Function GFE100DLC()
	dbSelectArea("GWF") /*Posiciona na Tabela de Cálculo de Frete*/
	dbSetOrder(1)
	If dbSeek(xFilial("GWF")+(cAliMKB2)->NRCALC) /*Posiciona no cálculo que foi salvo na tabela temporaria*/
		RecLock("GWF",.F.) /*Trava a tabela de Cálculo para que ela possa ser alterada*/
		GWF->GWF_NRCONT  := "" /*Limpa do cálculo de frete o número do contrato*/
		MsUnLock("GWF") /*Libera a tabela de Cálculo*/
	endif

	Processa({|lEnd| GFE100MKB()},STR0039,STR0040) /*Executa a função novamente e altualizando a tela principal*/ //"Processando informações"###"Aguarde"

	dbSelectArea(cAliMKB2) /*Seta a tabela temporaria do 2 Grid*/
	dbGoTOp() /*Posiciona no primeiro registro da tabela*/

return

//-------------------------------------------------------------------
/*/{Protheus.doc} GFE100FIL
Permite o filtro do browse superior

@author Jorge Matos Valcanaia
@since 19/02/10
@version 1.0
/*/
//-------------------------------------------------------------------
Function GFE100FIL()
	If !Pergunte("GFEA100",.T.) /*Abre o grupo de perguntas para o usuario e se for cancelado o grupo fecha e não executa ação nenhuma*/
   		Return Nil
	Endif
	Processa({|lEnd| GFE100MKB()},STR0039,STR0040) /*Executa a função novamente e altualizando a tela principal*/ //"Processando informações"###"Aguarde"
	oMark:oBrowse:Refresh()
return

//-------------------------------------------------------------------
/*/{Protheus.doc} GFEa100OK
Se o lCkeck estiver marcado como .T. salva o motorista e os veiculos no Contrato

@author Jorge Matos Valcanaia
@since 19/02/10
@version 1.0
/*/
//-------------------------------------------------------------------
Function GFEa100OK(lCheck)
	If lCheck /*Testa o que veio de parametro no lCheck*/
		dbSelectArea(cAliMKB2) /*Posiciona na tabela temporaria do 2 Grid*/
		dbGoTop() /*Posiciona no primeiro registro do Grid*/
		RecLock("GW2",.F.) /*Trava a tabela do contrato para que ela seja alterada*/
		GW2->GW2_CDMTR  := (cAliMKB2)->CDMOTO /*Grava no campo CDMTR o número do motorista*/
		GW2->GW2_CDVEI1 := posicione("GU8",2,xFilial("GU8")+(cAliMKB2)->VEIC1,"GU8_CDVEIC") /*Grava no campo CDVEI1 o código do veiculo 1*/
		GW2->GW2_CDVEI2 := posicione("GU8",2,xFilial("GU8")+(cAliMKB2)->VEIC2,"GU8_CDVEIC") /*Grava no campo CDVEI2 o código do veiculo 2*/
		GW2->GW2_CDVEI3 := posicione("GU8",2,xFilial("GU8")+(cAliMKB2)->VEIC3,"GU8_CDVEIC") /*Grava no campo CDVEI3 o código do veiculo 3*/
        GW2->GW2_SITCON := "1"
        MsUnLock("GW2") /*Libera a tabela*/
    else
        dbSelectArea(cAliMKB2) /*Posiciona na tabela temporaria do 2 Grid*/
        dbGoTop() /*Posiciona no primeiro registro do Grid*/
        RecLock("GW2",.F.) /*Trava a tabela do contrato para que ela seja alterada*/
		GW2->GW2_SITCON := "1"
		MsUnLock("GW2") /*Libera a tabela*/
	Endif
Return .T.

//-------------------------------------------------------------------
/*/{Protheus.doc} GFE100IM
Validações antes de chamar a tela de impostos do contrato

@param nOpc Indica a opção de uso que será passada para a tela de impostos.

@author Luiz Fernando Soares
@since 30/11/09
@version 1.0
/*/
//-------------------------------------------------------------------
Function GFEA100IM(nOpc)

	dbSelectArea("GWF")
	dbSetOrder(2)
	If dbSeek(xFilial("GWF")+GW2->GW2_NRCONT) .Or. nOpc == 1
		If GW2->GW2_SITCON == "4"
			Help( ,, 'HELP',, STR0089, 1, 0) //"O Contrato está com situação 'Cancelado', portanto, não poderá ser visualizada a tela de impostos."
			Return .F.
		EndIf
		/*Se existir algum cálculo vinculado ao contrato já executa a função da tela de impostos*/
		GFEA100I(nOpc)	/*Função da tela de impostos*/
	Else
		/*Se não existir nenhum cálculo vinculado ainda exibe uma mensagem de erro*/
		Help( ,, 'HELP',,STR0043, 1, 0) //"Não existem cálculos informados para o contrato"
		Return .F.
	Endif

Return .T.

//-------------------------------------------------------------------
/*/{Protheus.doc} GFEA100I

Função da tela de impostos

@param nOpc 1-Consulta, 2-Atualização

@author Jorge Matos Valcanaia
@since 10/11/09
@version 1.0
/*/
//-------------------------------------------------------------------
Function GFEA100I(nOpc)

	/*nOpc recebe como parametro a opção generica de operação que pode ser 1 ou 2
	ela recebe 1 quando a chamada dela é feita no programa GFEC100 que é a consulta do contrato
	e recebe 2 quando a chamada é feita neste mesmo programa, ela também é ultilizada na função
	GFEAOK100 desde fonte aonde verifica se será feita a gravação no botão OK ou não e nesta função
	GFEA100I aodne verifica se é ou não habilitado os campos de nInssOutEmp e nBaseReIr*/

	Local oDlg
	Local nAlt   := 500
	Local nLrg   := 700
	Private nBaseInss := 0
	Private nMV_BASINS 	:= GetMv('MV_BASINS')
	Private nInssOutEmp := GW2->GW2_VLINOE // Inss Outras Empresas
	Private nInssPer    := 0  // Inss Período
	Private nBaseReIr   := 0 // Recolher Base Ir
	Private nDescBaseIr  := 0 // Recolher Base Ir
	Private nFretCont    := 0 // Frete contratado com componentes que fazem parte da base de imposto.
	Private nFretContImp := 0 // Frete contratado com componentes que NÃO fazem parte da base de imposto.
	Private nVlTotFret   := 0 // Total do frete:  nFretCont + nFretContImp
	Private nAdicionais := 0 // Adicionais
	Private nDescontos  := 0 // Descontos
	Private nSestSenat  := 0 // SEST/SENAT
	Private nIss        := 0 // ISS
	Private nInssAuto   := 0 // INSS Autonomo
	Private nIrrf       := 0 // IRRF
	Private nVlLiqui    := 0 // Valor Liquido
	Private nVlDep      := 0 // Valor Dependente
	Private oButton
	Private nImpostos
	Private nInssAuto2  := 0
	Private nInssOtEmp
	Private cRecno      := GW2->(Recno())
	Public  nVlIrrf     := 0
	Private nVlInem
	
	Private cCodProp     := Nil
	Public dDataDeCont  := Nil
	Public dDataAteCont := Nil


	Private cCadastro := "Impostos sobre adicionais"

	If nInssOutEmp == 0
		cCodProp     := GW2->GW2_CDPROP
		dDataDeCont  := DTOS(CtoD(STR(01) + "/" + STR(MONTH(GW2->GW2_DTCRIA)) + "/" + STR(YEAR(GW2->GW2_DTCRIA))))
		dDataAteCont := DTOS( CtoD(STR(Last_Day(GW2->GW2_DTCRIA)) + "/" + STR(MONTH(GW2->GW2_DTCRIA)) + "/" + STR(YEAR(GW2->GW2_DTCRIA))))

		ListContratos()
		nInssPer := 0 // Zerando a variavel pois nesse ponto ela ainda nao deve ser trabalhada e função ListContratos que altera seu valor precisa ser executada para carregar o valor do INSSOutEmp
	EndIf

	//----------------------------------------------
	// Criacao da tabela temporaria p/ Markbrowse
	//----------------------------------------------
	aMKB :=    {{"NRCONT", "C", 16, 0},;
				{"CDVLAD", "C", 20, 0},;
				{"VALOR" , "N", 12, 2},;
				{"BASIRR", "C", 10, 0},;
				{"BASINS", "C", 10, 0},;
				{"BASISS", "C", 10, 0},;
				{"BASEST", "C", 10, 0},;
				{"OPERAC", "C", 20, 0}}

	aCpMKB  := {{"CDVLAD", NIL, STR0044, "@!"},; //"Identificador Valor Adicional"
				{"VALOR" , NIL, STR0088, "@E 999,999,999.99"},; //"Valor"
				{"BASIRR", NIL, STR0045, "@!"},; //"Base IRRF?"
				{"BASINS", NIL, STR0046, "@!"},; //"Base INSS?"
				{"BASISS", NIL, STR0047, "@!"},; //"Base ISS?"
				{"BASEST", NIL, STR0048, "@!"},; //"Base SEST/SENAT?"
				{"OPERAC", NIL, STR0049, "@!"}} //"Operação"

	cAliMKB := GFECriaTab({aMKB,{"NRCONT"}})

	//--------------------------
	// Montagem da tela
	//--------------------------
	Define MsDialog oDlg Title "Impostos" From 00,00 To nAlt,nLrg Of oMainWnd Color CLR_BLACK,RGB(225,225,225) Pixel
	oDlg:lEscClose := .F.

	oPnlA := tPanel():New(00,00,,oDlg,,,,,,150,120,.F.,.F.)
	oPnlA:Align := CONTROL_ALIGN_TOP

	oPnlB := tPanel():New(00,00,,oDlg,,,,,,30,40,.F.,.F.)
	oPnlB:Align := CONTROL_ALIGN_ALLCLIENT
	oFont12c := TFont():New('Arial',,-12,,.T.)

	@ 07,34 Say STR0087  Of oPnlA COLOR CLR_BLACK Pixel //"Base INSS: "
	@ 05,63 MSGET nBaseInss   Picture "@E 999,999,999.99" Of oPnlA When .F.   Pixel HasButton

	@ 21,15 Say STR0050 Of oPnlA COLOR CLR_BLACK Pixel //"INSS Outras Empr: "
	If (GW2->GW2_SITCON == "1" .Or. GW2->GW2_SITCON == "2") .And. nOpc <> 1
		@ 19,63 MSGET nInssOutEmp Picture '@E 999,999,999.99' Of oPnlA When .T.   Pixel ON CHANGE GFEA100AT(1) HasButton
	Elseif GW2->GW2_SITCON == "3" .Or. nOpc == 1
		@ 19,63 MSGET nInssOutEmp Picture '@E 999,999,999.99' Of oPnlA When .F.   Pixel HasButton
   	Endif

	@ 35,27  Say STR0051              Of oPnlA COLOR CLR_BLACK Pixel //"INSS Período: "
	@ 33,63 MSGET nInssPer Picture "@E 999,999,999.99" Of oPnlA When .F.   Pixel HasButton

	@ 49,18  Say STR0052              Of oPnlA COLOR CLR_BLACK Pixel //"Redução Base IR: "
   	If (GW2->GW2_SITCON == "1" .Or. GW2->GW2_SITCON == "2") .And. nOpc <> 1
		@ 47,63 MSGET nBaseReIr Picture '@E 999,999,999.99' Of oPnlA When .T.   Pixel ON CHANGE GFEA100AT(2) HasButton
	Elseif GW2->GW2_SITCON == "3" .Or. nOpc == 1
		@ 47,63 MSGET nBaseReIr Picture '@E 999,999,999.99' Of oPnlA When .F.   Pixel HasButton
	Endif

	@ 63,17  Say "Desconto Base IR: " /*STR0052*/ Of oPnlA COLOR CLR_BLACK Pixel //"Desconto Base IR: "
	@ 61,63 MSGET nDescBaseIr Picture '@E 999,999,999.99' When .F. Pixel Of oPnlA HasButton


	@ 07,175 Say STR0053  Of oPnlA COLOR CLR_BLACK Pixel //"Frete Contratado: "
	@ 05,220 MSGET nVlTotFret   Picture "@E 999,999,999.99" Of oPnlA When .F.   Pixel HasButton

	@ 21,193 Say STR0054  Of oPnlA COLOR CLR_BLACK Pixel //"Adicionais: "
	@ 19,220 MSGET nAdicionais Picture "@E 999,999,999.99" Of oPnlA When .F.   Pixel HasButton

	@ 35,192 Say STR0055  Of oPnlA COLOR CLR_BLACK Pixel //"Descontos: "
	@ 33,220 MSGET nDescontos Picture "@E 999,999,999.99" Of oPnlA When .F.   Pixel HasButton

	@ 49,184 Say STR0056  Of oPnlA COLOR CLR_BLACK Pixel //"SEST/SENAT: "
	@ 47,220 MSGET nSestSenat  Picture "@E 999,999,999.99" Of oPnlA When .F.   Pixel HasButton

	@ 63,208 Say STR0057  Of oPnlA COLOR CLR_BLACK Pixel //"ISS: "
	@ 61,220 MSGET nIss   Picture "@E 999,999,999.99" Of oPnlA When .F.   Pixel HasButton

	@ 77,179 Say STR0058  Of oPnlA COLOR CLR_BLACK Pixel //"INSS Autônomo: "
	@ 75,220 MSGET nInssAuto Picture "@E 999,999,999.99" Of oPnlA When .F.   Pixel HasButton

	@ 91,204 Say STR0059  Of oPnlA COLOR CLR_BLACK Pixel //"IRRF: "
	@ 89,220 MSGET nIrrf   Picture "@E 999,999,999.99" Of oPnlA When .F.   Pixel HasButton

	@ 105,187 Say STR0060  Of oPnlA COLOR CLR_BLACK Pixel //"Valor liquido: "
	@ 103,220 MSGET nVlLiqui  Picture "@E 999,999,999.99" Of oPnlA When .F.   Pixel HasButton

	dbSelectArea(cAliMKB)
	dbSetOrder(01)
	dbGoTop()
	oMark := MsSelect():New(cAliMKB,,,aCpMKB,,,{0,0,0,0},,,oPnlB)
	oMark:oBrowse:cToolTip := STR0061 //"Visualização"
	oMark:oBrowse:Align := CONTROL_ALIGN_ALLCLIENT

	CursorArrow()

	If (GW2->GW2_SITCON == "1" .Or. GW2->GW2_SITCON == "2") .And. (GW2->GW2_SITFIN == "1" .OR. GW2->GW2_SITFIN == "3" .OR. GW2->GW2_SITFIN == "5")
		Processa({|lEnd| GFEA100CR()},STR0039,STR0040) //"Processando informações"###"Aguarde"
		ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar(ODlg,{||If(GFEAOK100(nOpc),ODlg:End(),NIL)},{||,ODlg:End(),},,) CENTERED
	Elseif GW2->GW2_SITCON == "3"
		Processa({|lEnd| GFEA100VIM()},STR0039,STR0040) //"Processando informações"###"Aguarde"
		ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar(ODlg,{||                  ,ODlg:End()     },{||,ODlg:End(),},,) CENTERED
	Endif

	//Deletando tabela temporaria
	GFEDelTab(cAliMKB)
Return


/*Função que atribui os valores da base de dados para os campos exibidos em tela
executada no modo de visualização dos dados de imposto.
 */
Function GFEA100VIM()
	
	nBaseInss    := GW2->GW2_VLBAIN  // Base INSS
	nInssOutEmp  := GW2->GW2_VLINOE // Inss Outras Empresas
	nInssPer     := GW2->GW2_INSSPE // Inss Período
	nVlTotFret   := GW2->GW2_VLFRET // Total do frete:  nFretCont + nFretContImp
	nAdicionais  := GW2->GW2_VLADIC // Adicionais
	nDescontos   := GW2->GW2_VLDESC // Descontos
	nSestSenat   := GW2->GW2_VLSEST // SEST/SENAT
	nIss         := GW2->GW2_VLISS // ISS
	nInssAuto    := GW2->GW2_VLINSS // INSS Autonomo
	nIrrf        := GW2->GW2_VLIRRF // IRRF
	nVlLiqui     := GW2->GW2_VLLIQ  // Valor Liquido
	nVlDep       := GW2->GW2_VLDEDP //Valor Dependente

Return 

//-------------------------------------------------------------------
/*/{Protheus.doc} GFEA100CR

Acrescenta os registros na tabela temporaria para que eles sejam
exibidos na tela do romaneio

@author Jorge Matos Valcanaia
@since 10/11/09
@version 1.0
/*/
//-------------------------------------------------------------------
Function GFEA100CR()
Local aDSDTRE := {"1=Data Corrente","2=Data Criação","3=Informada Usuário","4=Financeiro"}
Local aDSDTAP := {"1=Data Corrente","2=Data Criação","3=Informada Usuário"}
Local cAliasGWF
Local cQuery 	:= " " 

	GFEA100AL(" ***********************","")
	GFEA100AL("        PARAMETROS      ","")
	GFEA100AL(" ***********************","")
	GFEA100AL("% Base INSS-MV_BASINS: ",cValToChar(SuperGetMv('MV_BASINS',, 100)))
	GFEA100AL("% INSS Autônomo-MV_PCINAU: ", cValToChar(SuperGetMv('MV_PCINAU',, 0)))
	GFEA100AL("Valor Máximo de INSS-MV_VLMXRE: ",cValToChar(SuperGetMv('MV_VLMXRE',, 999999)))
	GFEA100AL("% Base IRRF-MV_VLMXRE: ", cValToChar(SuperGetMv('MV_BASIRF',, 100)))
	GFEA100AL("SEST Base IRRF-MV_DEDSES: ", IIF(SuperGetMv('MV_DEDSES',,'1') $"1S","1=Descontar","2=Manter"))
	GFEA100AL("INSS Base IRRF-MV_DEDINS: ", IIF(SuperGetMv('MV_DEDINS',,'1') $"1S","1=Descontar","2=Manter"))
	GFEA100AL("Valor Mínimo IRRF-MV_MINIRF: ", cValToChar(SuperGetMv('MV_MINIRF',, 0)))
	GFEA100AL("% SEST-MV_PCSEST: ", cValToChar(SuperGetMv('MV_PCSEST',, 0)))
	GFEA100AL("% SENAT-MV_PCSENA: ", cValToChar(SuperGetMv('MV_PCSENA',, 0)))
	GFEA100AL("Data Integração Financeiro-MV_DSDTAP: ", IIF(Empty(SuperGetMV('MV_DSDTAP',,'1')),"Nao definido",aDSDTAP[val(SuperGetMV('MV_DSDTAP',,'1'))]))
	GFEA100AL("Data Integração Recebimento-MV_DSDTRE: ", IIF(Empty(SuperGetMV('MV_DSDTRE',,'1')),"Nao definido",aDSDTRE[val(SuperGetMV('MV_DSDTRE',,'1'))]))
	GFEA100AL("Integracao com o TOTVS GFE-MV_INTGFE: ", IIF(SuperGetMv('MV_INTGFE',.F.,.F.)==.T.,"Sim","Não"))
	GFEA100AL("Integracao Direta com TOTVS GFE-MV_INTGFE2: ", IIF(SuperGetMv('MV_INTGFE2',.F.,'2') =="1","Sim","Não"))
	GFEA100AL("Data do Último Fechamento-MV_DTULFE: ", cValToChar(SuperGetMv('MV_DTULFE',,'20000101')))
	GFEA100AL("","")

	dbSelectArea(cAliMKB)
	ZAP

	cRecno  := GW2->(Recno()) /*Quarda o recno do registro para que ele possa ser gravado depois*/

	dbSelectArea("GW5") /*Posiciona na tabela de Adicionais de contrato com autonomos */
	dbSetOrder(1)
	dbSeek(xFilial("GW5")+GW2->GW2_NRCONT) /*Posiciona no primeiro registro que esteja vinculado ao contrato*/
	While !Eof() .And. xFilial("GW5") == GW5->GW5_FILIAL .And. GW5->GW5_NRCONT == GW2->GW2_NRCONT /*Executa o While enquanto a filial e o número do contrato for o mesmo do contrato posicionado*/
		RecLock(cAliMKB,.T.) /*Trava a tabela temporaria para que seja criado um novo registro para a tabela temporaria que sera exibido no Grid*/
	    If GW5->GW5_BASIRR == "1" /*Verifica se o campo BASIRR(IRRF) esá setado como 1*/
	   		(cAliMKB)->BASIRR := STR0062 /*Se estiver como 1 recebe sim*/ //"Sim"
	    Else
	    	(cAliMKB)->BASIRR := STR0063 /*Se estiver como 2 recebe não*/ //"Não"
	    Endif
	    If GW5->GW5_BASINS == "1" /*Verifica se o campo BASINS(INSS) esá setado como 1*/
		    (cAliMKB)->BASINS := STR0062 /*Se estiver como 1 recebe sim*/ //"Sim"
	    Else
		    (cAliMKB)->BASINS := STR0063 /*Se estiver como 2 recebe não*/ //"Não"
	    Endif
	    If GW5->GW5_BASISS == "1" /*Verifica se o campo BASISS(ISS) esá setado como 1*/
	    	(cAliMKB)->BASISS := STR0062 /*Se estiver como 1 recebe sim*/                                          //"Sim"
	    Else
	    	(cAliMKB)->BASISS := STR0063 /*Se estiver como 2 recebe não*/ //"Não"
	    Endif
	    If GW5->GW5_BASEST == "1" /*Verifica se o campo BASEST(SEST/SENAT) esá setado como 1*/
    		(cAliMKB)->BASEST := STR0062 /*Se estiver como 1 recebe sim*/ //"Sim"
	    Else
    		(cAliMKB)->BASEST := STR0063 /*Se estiver como 2 recebe não*/ //"Não"
	    Endif
	    If GW5->GW5_OPERAC == "1" /*Verifica qual é a operação que está sendo feita*/
    		(cAliMKB)->OPERAC := STR0064 /*Se estiver como 1 então ela é adicional*/ //"Adicional"
	    Else
    		(cAliMKB)->OPERAC := STR0065  /*Se estiver como 2 então ela é desconto*/   //"Desconto"
	    Endif

		(cAliMKB)->CDVLAD := GW5->GW5_CDVLAD
		(cAliMKB)->VALOR  := GW5->GW5_VALOR

		MsUnLock(cAliMKB) /*Libera a tabela temporaria*/

		dbSelectArea("GW5")
		dbSkip()
	EndDo
	
	cAliasGWF := GetNextAlias()
	cQuery := " SELECT GWF.GWF_FILIAL, GWF.GWF_NRCALC FROM "+RetSQLName("GWF")+" GWF "
	cQuery += " WHERE GWF.D_E_L_E_T_ = ' ' "
	cQuery += "  AND GWF.GWF_FILIAL = '" + GW2->GW2_FILIAL + "'" 
	cQuery += "  AND GWF.GWF_NRCONT = '" + GW2->GW2_NRCONT + "'" 
	cQuery += " ORDER BY GWF.GWF_FILIAL,GWF.GWF_NRCALC  "
	
	cQuery := ChangeQuery(cQuery)
	dbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery),cAliasGWF, .F., .T.)

	(cAliasGWF)->( dbGoTop() )		

	While !(cAliasGWF)->( Eof() )		
		nFretCont    := nFretCont + TOTFRTIMP((cAliasGWF)->GWF_FILIAL,(cAliasGWF)->GWF_NRCALC) // Somatório do valor do frete apenas considerando os componentes que fazem parte da base de imposto.
		FretContImp := nFretContImp + ((VLTOTFRET((cAliasGWF)->GWF_FILIAL,(cAliasGWF)->GWF_NRCALC) - TOTFRTIMP((cAliasGWF)->GWF_FILIAL,(cAliasGWF)->GWF_NRCALC))) // Somatório do valor do frete apenas considerando os componentes que NÃO fazem parte da base de imposto.
		(cAliasGWF)->( dbSkip() )
	EndDo
	(cAliasGWF)->( dbCloseArea() )

	nVlTotFret := nFretCont + nFretContImp

	dbSelectArea(cAliMKB) /*Posiciona na tabela temporaria do Grid de impostos*/
	dbSetOrder(1)
	dbGoTop()
	While !Eof()
		If Alltrim((cAliMKB)->OPERAC) == STR0064 /*Verifica se a operação que está sendo feita na tabela temporaria é de adição*/ //"Adicional"
			nAdicionais := nAdicionais + (cAliMKB)->VALOR  /*Se for nAdicionais rebece ela mesma mais o valor do campo da tabela temporaria*/
			If Alltrim((cAliMKB)->BASIRR) == STR0062 /*Verifica se o campo (cAliMKB)->BASIRR estiver como sim entao nIrrf recebe ele mesmo mais (cAliMKB)->VALOR*/ //"Sim"
				nIrrf := Round( nIrrf + (cAliMKB)->VALOR,2)
			Endif
			If Alltrim((cAliMKB)->BASINS) == STR0062 /*Verifica se o campo (cAliMKB)->BASIINS estiver como sim entao nInssAuto recebe ele mesmo mais (cAliMKB)->VALOR*/ //"Sim"
				nInssAuto :=  round(nInssAuto + (cAliMKB)->VALOR,2)
			Endif
			If Alltrim((cAliMKB)->BASISS) == STR0062 /*Verifica se o campo (cAliMKB)->BASINS estiver como sim entao nInssAuto recebe ele mesmo mais (cAliMKB)->VALOR*/		 //"Sim"
				nIss := round(nIss + (cAliMKB)->VALOR,2)
			Endif
			If Alltrim((cAliMKB)->BASEST) == STR0062 /*Verifica se o campo (cAliMKB)->BASEST estiver como sim entao nSestSenat recebe ele mesmo mais (cAliMKB)->VALOR*/ //"Sim"
				nSestSenat := round(nSestSenat + (cAliMKB)->VALOR,2)
			Endif
		ElseIf Alltrim((cAliMKB)->OPERAC) == STR0065 /*Verifica se a operação que está sendo feita na tabela temporaria é de subtração*/ //"Desconto"
			nDescontos :=  round(nDescontos + (cAliMKB)->VALOR,2) /*Se for nDescontos rebece ela mesma mais o valor do campo da tabela temporaria*/
			If Alltrim((cAliMKB)->BASIRR) == STR0062 /*Verifica se o campo (cAliMKB)->BASIRR estiver como sim entao nIrrf recebe ele mesmo mais (cAliMKB)->VALOR*/ //"Sim"
				nIrrf := Round( nIrrf - (cAliMKB)->VALOR,2)
			Endif
			If Alltrim((cAliMKB)->BASINS) == STR0062 /*Verifica se o campo (cAliMKB)->BASIINS estiver como sim entao nInssAuto recebe ele mesmo mais (cAliMKB)->VALOR*/ //"Sim"
				nInssAuto :=  round(nInssAuto - (cAliMKB)->VALOR,2)
			Endif
			If Alltrim((cAliMKB)->BASISS) == STR0062 /*Verifica se o campo (cAliMKB)->BASINS estiver como sim entao nInssAuto recebe ele mesmo mais (cAliMKB)->VALOR*/		 //"Sim"
				nIss := round(nIss - (cAliMKB)->VALOR,2)
			Endif
			If Alltrim((cAliMKB)->BASEST) == STR0062 /*Verifica se o campo (cAliMKB)->BASEST estiver como sim entao nSestSenat recebe ele mesmo mais (cAliMKB)->VALOR*/ //"Sim"
				nSestSenat := round(nSestSenat - (cAliMKB)->VALOR,2)
			Endif
		Endif
		dbSelectArea(cAliMKB)
 		dbSkip()
	EndDo
	
	nBaseInss := (nFretCont + nInssAuto) * (nMV_BASINS/100)

	GFEA100GC()

	dbSelectArea("GW5")
	dbGoTop()
	dbSelectArea("GW2")
	dbGoTo(cRecno)
	dbSelectArea(cAliMKB)
	dbGoTOp()
  	oMark:oBrowse:Refresh()
  	GFELog100:EndLog()

Return .T.

//-------------------------------------------------------------------
/*/{Protheus.doc} GFEA100AT

Função para que sejam feitos alguns cálculos para serem atribuidos nas variaveis que estaram sendo exibidas em tela

@author Jorge Matos Valcanaia
@since 19/02/10
@version 1.0
/*/
//-------------------------------------------------------------------
Function GFEA100AT(nOper)
	Local cVlinssrest /*Valor INSS Restante*/
	Local cVlinssprev /*Valor INSS Previsto*/
	Local nMvPcInau //Percentual sobre a base de cálculo de INSS, parte autônomo.
	Local nMvBasins //Percentual sobre o percentual que define a base de cálculo do INSS, parte autônomo.
	Local nMvPcInem //Percentual sobre a base de cálculo de INSS, parte autônomo.
	
	nMvBasins := (SuperGetMv("MV_BASINS",, 100) / 100 )

	If nMvBasins > 0
		nMvPcInem := ((SuperGetMv("MV_PCINEM",, 0) / 100) * nMvBasins)
	Else
		nMvPcInem := (SuperGetMv("MV_PCINEM",, 0) / 100)
	Endif

	nVlInem := (nFretCont + nInssAuto2) * (nMvPcInem)

	If nOper == 1
		GFEA100IR()

		If nMvBasins > 0
			nMvPcInau := ((SuperGetMv("MV_PCINAU",, 0) / 100) * nMvBasins)
		Else
			nMvPcInau := (SuperGetMv("MV_PCINAU",, 0) / 100)
		Endif

		cVlinssrest := SuperGetMv("MV_VLMXRE",, 999999) - (nInssOutEmp + nInssPer) /*cVlinssrest recebe uma conta do parametro MV_VLMXRE(Valor máximo de INSS) menos a soma das variaveis nInssOutEmp + nInssPer*/
		cVlinssprev := (nFretCont + nInssAuto2) * (nMvPcInau) /*cVlinssprev Recebe o frete contratado mais os adicionas e multiplica pelo resultado do parametro MV_PCINAU(Percentual sobre a base de cálculo de INSS) dividido por 100*/

		IF nInssOutEmp + nInssPer >= SuperGetMv("MV_VLMXRE",, 999999) /*Se a soma das variaveis nInssOutEmp com nInssPer for maior ou igual que MV_VLMXRE(Valor máximo de INSS)*/
			nInssAuto := 0 /*Então nInssAuto recebe 0 */
		Else
			If cVlinssprev > cVlinssrest /*Se cVlinssprev for maior que cVlinssrest*/
				nInssAuto := round(cVlinssrest,2) /*Então nInssAuto recebe o cVlinssrest*/
			Else
				nInssAuto := round(cVlinssprev,2) /*Se for menor então nInssAuto recebe cVlinssprev*/
			Endif
		Endif
		/*Valor liquido do frete recebe a soma do frete contratado com os adicionais que depois deste valor é subtraido a soma dos decontos com Sest/Senat mais Iss mais Inss autonomo mais o IRRF*/
		/*nSestSenat := nIss := nInssAuto := nIrrf := 0 */

		nVlLiqui  := (nVlTotFret + nAdicionais) - (nDescontos + nSestSenat + nIss + nInssAuto + nIrrf)
		nImpostos := nSestSenat + nIss + nInssAuto + nIrrf

		If nVlLiqui < 0
			nVlLiqui := 0
		Endif
	Else
		GFEA100IR()
		
		dbSelectArea(cAliMKB) /*Posiciona na tabela temporaria do Grid de impostos*/
		dbSetOrder(1)
		dbGoTop()
		While !Eof()
			If Alltrim((cAliMKB)->OPERAC) == STR0064 /*Verifica se a operação que está sendo feita na tabela temporaria é de adição*/	                                                                                                                             //"Adicional"
				If Alltrim((cAliMKB)->BASINS) == STR0062 /*Verifica se o campo (cAliMKB)->BASIINS estiver como sim entao nInssAuto recebe ele mesmo mais (cAliMKB)->VALOR*/ //"Sim"
					nInssAuto := round(nInssAuto + (cAliMKB)->VALOR,2)
				Endif
			Endif
			dbSelectArea(cAliMKB)
			dbSkip()
		EndDo

	    If nIrrf < SuperGetMv("MV_MINIRF",, 0)
    		nIrrf := 0
		Endif

		cVlinssrest := SuperGetMv("MV_VLMXRE",, 999999) - (nInssOutEmp + nInssPer) /*cVlinssrest recebe uma conta do parametro MV_VLMXRE(Valor máximo de INSS) menos a soma das variaveis nInssOutEmp + nInssPer*/
		cVlinssprev := (nFretCont + nInssAuto2) * (SuperGetMv("MV_PCINAU",, 0) / 100) /*cVlinssprev Recebe o frete contratado mais os adicionas e multiplica pelo resultado do parametro MV_PCINAU(Percentual sobre a base de cálculo de INSS) dividido por 100*/

		IF nInssOutEmp + nInssPer >= SuperGetMv("MV_VLMXRE",, 999999) /*Se a soma das variaveis nInssOutEmp com nInssPer for maior ou igual que MV_VLMXRE(Valor máximo de INSS)*/
			nInssAuto := 0 /*Então nInssAuto recebe 0 */
		Else
			If cVlinssprev > cVlinssrest /*Se cVlinssprev for maior que cVlinssrest*/
				nInssAuto := round(cVlinssrest,2) /*Então nInssAuto recebe o cVlinssrest*/
			Else
				nInssAuto := round(cVlinssprev,2) /*Se for menor então nInssAuto recebe cVlinssprev*/
			Endif
		EndIf
		/*Valor liquido do frete recebe a soma do frete contratado com os adicionais que depois deste valor é subtraido a soma dos decontos com Sest/Senat mais Iss mais Inss autonomo mais o IRRF*/
  		nVlLiqui  := (nVlTotFret + nAdicionais) - (nDescontos + nSestSenat + nIss + nInssAuto + nIrrf)
		nImpostos := nSestSenat + nIss + nInssAuto + nIrrf
	EndIf
	
	If IsInCallStack("GFEA100CR")
		GFEA100AL("","")
		GFEA100AL(" *********************** ", "")
		GFEA100AL("   VALORES CALCULADOS    ", "")
		GFEA100AL(" *********************** ", "")
		GFEA100AL("Valor Total de Frete (+): ",PadL(AllTrim(Transform(nVlTotFret,  "@E 999,999,999.99")), 14) + " (+)")
		GFEA100AL("  Valores Adicionais (+): ",PadL(AllTrim(Transform(nAdicionais, "@E 999,999,999.99")), 14) + " (+)")
		GFEA100AL("     Valor Descontos (-): ",PadL(AllTrim(Transform(nDescontos,  "@E 999,999,999.99")), 14) + " (-)")
		GFEA100AL("    Valor SEST/SENAT (-): ",PadL(AllTrim(Transform(nSestSenat,  "@E 999,999,999.99")), 14) + " (-)")
		GFEA100AL("           Valor ISS (-): ",PadL(AllTrim(Transform(nIss,        "@E 999,999,999.99")), 14) + " (-)")
		GFEA100AL("  Valor ISS Autonomo (-): ",PadL(AllTrim(Transform(nInssAuto,   "@E 999,999,999.99")), 14) + " (-)")
		GFEA100AL("          Valor IRRF (-): ",PadL(AllTrim(Transform(nIrrf,       "@E 999,999,999.99")), 14) + " (-)")
		GFEA100AL("       Valor Líquido (=): ",PadL(AllTrim(Transform(nVlLiqui,    "@E 999,999,999.99")), 14) + " (=)")
	Endif
Return

//-------------------------------------------------------------------
/*/{Protheus.doc} GFEAOK100

Botão OK da tela de impostos

@author Jorge Matos Valcanaia
@since 19/02/10
@version 1.0
/*/
//-------------------------------------------------------------------

Function GFEAOK100(nOpc)
Local lRet := .T.

	If nOpc <> 1
		If nInssOutEmp < nInssOtEmp
			Help( ,, 'HELP',,STR0066, 1, 0) //"INSS Outras Empresas informado deve ser maior ou igual ao valor do período para o proprietário."
			Return .F.
		Endif

		dbSelectArea("GW2")
		dbGoTo(cRecno)
		RecLock("GW2",.F.) /*Trava tabela do contrato para alteração*/
		GW2->GW2_VLBAIN := nBaseInss    // Base INSS
	 	GW2->GW2_INSSPE := nInssPer      // Grava o INSS do periodo
		GW2->GW2_SITCON := "2"           // Liberado
		GW2->GW2_VLFRET := nVlTotFret    // Grava o Valor do Frete
		GW2->GW2_VLADIC := nAdicionais   // Grava o Valor dos Adicionais
		GW2->GW2_VLDESC := nDescontos    // Grava o Valor dos Descontos
		GW2->GW2_VLSEST := nSestSenat    // Grava o Valor do Sest/Senat
		GW2->GW2_VLISS  := nIss          // Grava o Valor do ISS
		GW2->GW2_VLINSS := nInssAuto     // Grava o Valor do INSS do Autonomo
		GW2->GW2_VLIRRF := nIrrf         // Grava o Valor do IRRF
		GW2->GW2_VLDEDP := nVlDep        // Grava o Valor Dependentes
		GW2->GW2_VLLIQ  := nVlLiqui      // Grava o Valor liquido do contrato
		GW2->GW2_VLIMP  := nImpostos     // Grava a Soma dos impostos
		GW2->GW2_VLINOE := nInssOutEmp   // Grava o Valor do inss empresa
		GW2->GW2_VLINEM := nVlInem
		GW2->GW2_MOTFIN := ""
		GW2->GW2_MOTREC := ""
		GW2->GW2_MOTRH  := ""
		MsUnLock("GW2")/*Destrava tabela*/
	Endif

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} GFEA100IR

Cálcula o total de IR

@author Jorge Matos Valcanaia
@since 19/02/10
@version 1.0
/*/
//-------------------------------------------------------------------
Function GFEA100IR()
	Local deVlTotalContrato := 0
	Local deVlCalcFrete     := 0
	Local deVlTotalIR       := 0
	Local dDataIni
	Local dDataFim
	Local dDataBase			:= SToD("")
	Local cVlDep            := 0
	Local nDescSimp         := 0
	Local nVlDeOut          := 0
	Local cInival
	Local nSestPe           := 0
	Local nINSSPe           := 0
	Local nVlAdicIR 		:= 0
	Local cAPUIRF			:= SuperGetMV("MV_APUIRF", .F., "2")
	Local cGFE016			:= SuperGetMV("MV_GFE016", .F., "1")
	Local cAliasQry			:= GetNextAlias()
	Local cQuery			:= ""
	Local nMINIRF			:= SuperGetMv("MV_MINIRF",, 0)

	Private dBaseIR         := 0
	Default nVlDep          := 0
	Default nSestSenat      := 0
	Default nDescBaseIr     := 0


	nMvBasins := (SuperGetMv("MV_BASINS",, 100) / 100 )

	If nMvBasins > 0
		nMvPcInau := ((SuperGetMv("MV_PCINAU",, 0) / 100) * nMvBasins)
	Else
		nMvPcInau := (SuperGetMv("MV_PCINAU",, 0) / 100)
	Endif

	GFEA100AL(" ***********************","")
	GFEA100AL("    CALCULANDO IRRF     ","")
	GFEA100AL(" ***********************","")


	cVlinssrest := SuperGetMv("MV_VLMXRE",, 999999) - (nInssOutEmp + nInssPer) /*cVlinssrest recebe uma conta do parametro MV_VLMXRE(Valor máximo de INSS) menos a soma das variaveis nInssOutEmp + nInssPer*/
	cVlinssprev := (nFretCont + nInssAuto) * (nMvPcInau) /*cVlinssprev Recebe o frete contratado mais os adicionas e multiplica pelo resultado do parametro MV_PCINAU(Percentual sobre a base de cálculo de INSS) dividido por 100*/

	IF nInssOutEmp + nInssPer >= SuperGetMv("MV_VLMXRE",, 999999) /*Se a soma das variaveis nInssOutEmp com nInssPer for maior ou igual que MV_VLMXRE(Valor máximo de INSS)*/
		GFEA100AL("INSS Autonomo: ", "0 - INSS Outras Empresas + INSS Periodo Maior que valor Parametrizado")
		GFEA100AL(": ", cValtoChar(nInssOutEmp) + '+' + cValToChar(nInssPer) + '>' + cValToChar(SuperGetMv("MV_VLMXRE",, 999999)))
		nInssAuto := 0 /*Então nInssAuto recebe 0 */
	Else
		If cVlinssprev > cVlinssrest /*Se cVlinssprev for maior que cVlinssrest*/
			nInssAuto := round(cVlinssrest,2) /*Então nInssAuto recebe o cVlinssrest*/
		Else
			nInssAuto := round(cVlinssprev,2) /*Se for menor então nInssAuto recebe cVlinssprev*/
		Endif
		GFEA100AL("INSS Autonomo: ", PadL(AllTrim(Transform(nInssAuto,  "@E 999,999,999.99")), 14))
	Endif
	/*Valor liquido do frete recebe a soma do frete contratado com os adicionais que depois deste valor é subtraido a soma dos decontos com Sest/Senat mais Iss mais Inss autonomo mais o IRRF*/

	If cGFE016 == "1"
	 	dDataBase := dGw2DtCria
	 	dDataIni  := DTOS(CtoD(STR(01) + "/" + STR(MONTH(dGw2DtCria)) + "/" + STR(YEAR(dGw2DtCria))))  /*Recebe a data de Inicio*/
		dDataFim  := DTOS( CtoD(STR(Last_Day(dGw2DtCria)) + "/" + STR(MONTH(dGw2DtCria)) + "/" + STR(YEAR(dGw2DtCria)))) /*Recebe a data final    */
	Else
		dDataBase := dGw2DtVenc
		dDataIni  := DTOS(CtoD(STR(01) + "/" + STR(MONTH(dGw2DtVenc)) + "/" + STR(YEAR(dGw2DtVenc))))  /*Recebe a data de Inicio*/
		dDataFim  := DTOS( CtoD(STR(Last_Day(dGw2DtVenc)) + "/" + STR(MONTH(dGw2DtVenc)) + "/" + STR(YEAR(dGw2DtVenc)))) /*Recebe a data final    */
	EndIf

	GFEA100AL("BUSCA TABELA IR: ", "Periodo entre " + Dtoc(Stod(dDataIni)) + ' / '+ Dtoc(Stod(dDataFim)))

   	dbSelectArea("GUP") /*Acessa a tabela de IR*/
	dbSetOrder(1)
	dbSeek(xFilial("GUP"))
	While !Eof() .And. xFilial("GUP") == GUP->GUP_FILIAL  /*Percorre um While enquanto a filial for a mesma do sistema */
		If dDataBase >= GUP->GUP_INIVAL .And. (dDataBase <= GUP->GUP_FINVAL .OR. dDataBase <= CtoD('01/01/2999')) /*Compara se a data de criação é maior e ao mesmo tempo menor que a final e se o proprietario é o mesmo*/
			cInival   := GUP->GUP_INIVAL /*Variavel recebe a data inicial para pesquisa da GUI*/
			cVlDep    := GUP->GUP_VLDEP
			If GFXCP1212210('GUP_DESSIM')
				nDescSimp := GUP->GUP_DESSIM
			EndIf
		Endif
		
		dbSelectArea("GUP")
		dbSkip()
	EndDo

	If Empty(cInival)
		GFEA100AL("BUSCA TABELA IR: ", "Não localizada. Calculo IRRF finalizada")
		Return .F.
	Endif

	GFEA100AL(" : ", "Contratos do período")
	GFEA100AL("Período : ", Dtoc(Stod(dDataIni)) + ' / '+ Dtoc(Stod(dDataFim)))

	cQuery := "SELECT * FROM " + RetSqlName("GW2") + " GW2 "
	If cGFE016 == "1"
		cQuery += "WHERE GW2.GW2_DTCRIA >= '" + alltrim(dDataIni) + "' AND GW2.GW2_DTCRIA <= '" + alltrim(dDataFim) + "' "
	Else
		cQuery += "WHERE GW2.GW2_DTVENC >= '" + alltrim(dDataIni) + "' AND GW2.GW2_DTVENC <= '" + alltrim(dDataFim) + "' " 
	EndIf
	If cAPUIRF == "2"
		cQuery += "AND GW2.GW2_FILIAL = '" + xFilial("GW2") + "' "
	EndIf
	cQuery += "AND GW2.GW2_CDPROP = '" + cCodProp + "' "
	cQuery += "AND GW2.GW2_SITCON <> '4' "
	cQuery += "AND GW2.GW2_NRCONT <> '" + cNrCont + "' "
	cQuery += "AND GW2.D_E_L_E_T_ = '' "
	cQuery := ChangeQuery(cQuery)
	
	DbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasQry,.F.,.T.)
	
	While (cAliasQry)->(!Eof())
		deVlTotalContrato 	:= deVlTotalContrato + (cAliasQry)->GW2_VLFRET
		deVlTotalIR 		:= deVlTotalIR + (cAliasQry)->GW2_VLIRRF
		nSestPe     		:= nSestPe + (cAliasQry)->GW2_VLSEST
		nINSSPe 			:= nINSSPe + (cAliasQry)->GW2_VLINSS
		nVlDeOut            := nVlDeOut  + (cAliasQry)->GW2_VLDEDP
		nVlAdicIR 			:= 0
				
		GW5->(dbSetOrder(1))
		GW5->(dbSeek(xFilial("GW5")+(cAliasQry)->GW2_NRCONT))
		Do While !Eof() .And. xFilial("GW5") == GW5->GW5_FILIAL .And. GW5->GW5_NRCONT == (cAliasQry)->GW2_NRCONT
			If GW5->GW5_BASIRR == "1"
				deVlTotalContrato 	:= deVlTotalContrato + GW5->GW5_VALOR
				nVlAdicIR 			:= nVlAdicIR + GW5->GW5_VALOR
			EndIf
			GW5->(dbSkip())
		EndDo

		GFEA100AL("       Contrato : ", (cAliasQry)->GW2_NRCONT +" - " +;
	  		      " Frete: "+PadL(AllTrim(Transform((cAliasQry)->GW2_VLFRET, "@E 999,999,999.99")), 14) + ;
				  " IRRF: "+PadL(AllTrim(Transform((cAliasQry)->GW2_VLIRRF, "@E 999,999,999.99")), 14) + ;
				  " SEST/SENAT: "+PadL(AllTrim(Transform((cAliasQry)->GW2_VLSEST, "@E 999,999,999.99")), 14) + ;
				  " Comp. Adicionais IRRF: "+PadL(AllTrim(Transform(nVlAdicIR, "@E 999,999,999.99")), 14))
		
		(cAliasQry)->(dbSkip())
	EndDo
		
	(cAliasQry)->(DbCloseArea())
	
	deVlTotalContrato := deVlTotalContrato + nFretCont

	GFEA100AL(" *********************** ", "")
	GFEA100AL("  GERANDO BASE DO IRRF   ", "")
	GFEA100AL(" *********************** ", "")

    dBaseIR       := SuperGetMv("MV_BASIRF",, 100) /*Recebe a base do IR do parametro*/
    deVlCalcFrete := ((deVlTotalContrato + nVlIrrf) * (dBaseIR / 100 )) - nBaseReIr /*Recebe o valor do Cálculo do Frete atras do cálculo executado*/

	GFEA100AL("       Valor dos contratos(=): ", PadL(AllTrim(Transform(deVlTotalContrato, "@E 999,999,999.99")), 14) + " (=)")
	GFEA100AL("   Valor de IRRF calculado(+): ", PadL(AllTrim(Transform(nVlIrrf,           "@E 999,999,999.99")), 14) + " (+)")
	GFEA100AL("        Percentual da base(*): ", PadL(AllTrim(Transform(dBaseIR,           "@E 999,999,999.99")), 14) + " (*)")
	GFEA100AL("           Redução da base(-): ", PadL(AllTrim(Transform(nBaseReIr,         "@E 999,999,999.99")), 14) + " (-)")

    /* Deduz o valor do SEST/SENAT da base de calculo do IR */
    If SuperGetMv("MV_DEDSES",,"1") $ "1S" /*1 - indica que sera descontado*/
		GFEA100AL("    SEST/SENAT - MV_DEDSES(-): ", PadL(AllTrim(Transform(nSestSenat + nSestPe, "@E 999,999,999.99")), 14) + " (-)")
		nDescBaseIr += nSestSenat + nSestPe
	Endif

	cVlinssrest := SuperGetMv("MV_VLMXRE",, 999999) - (nInssOutEmp + nInssPe) /*cVlinssrest recebe uma conta do parametro MV_VLMXRE(Valor máximo de INSS) menos a soma das variaveis nInssOutEmp + nInssPer*/
	
	If nInssAuto > cVlinssrest
		nInssAut := round(cVlinssrest,2) /*Então nInssAuto recebe o cVlinssrest*/
	Else
		nInssAut := round(nInssAuto,2)
	EndIf
	 	
    If SuperGetMv("MV_DEDINS",,"1") $ "1S"
    	If nInssAut == nInssPe
			nInssPe1 := 0
		Else
			nInssPe1 := nInssPe
		Endif 
		
		GFEA100AL("          INSS - MV_DEDINS(-): ", PadL(AllTrim(Transform(nInssAut + nINSSPe1, "@E 999,999,999.99")), 14) + " (-)")
		GFEA100AL("     Desconto Simplificado(-): ", PadL(AllTrim(Transform(nDescSimp,           "@E 999,999,999.99")), 14) + " (-)")
		nDescBaseIr += nInssAut + nInssPe1 /*Valor do frete recebe ela mesma menos a soma do INSS do autonomo com o INSS do Periodo retido */
	Endif

    deVlIR       := 0
    deVlDeduzir  := 0
    dePcAliquota := 0

	If (nQtDeIR * cVlDep) > nVlDeOut
		nVlDep   := nQtDeIR * cVlDep
		nDescBaseIr += nQtDeIR * cVlDep
	Else
		nDescBaseIr += nVlDeOut
	EndIf

    If nDescBaseIr < nDescSimp
		nDescBaseIr := nDescSimp
	EndIf

	deVlCalcFrete := deVlCalcFrete - nDescBaseIr
	GFEA100AL("          Desconto da base(-): ", PadL(AllTrim(Transform(nDescBaseIr,       "@E 999,999,999.99")), 14) + " (-)")

  	dbSelectArea("GUI") /*Acessa a tabela de Faixas*/
   	dbSetOrder(1)
   	dbSeek(xFilial("GUI")+DTOS(cInival))
   	While !Eof() .And. xFilial("GUI") == GUI->GUI_FILIAL .And. GUI->GUI_INIVAL == cInival /*Percorre um while enquanto a data inicial da GUI for a mesma da variavel que contem uma data da GUP*/
   		If deVlCalcFrete >= GUI->GUI_BAIRIN .And. deVlCalcFrete <= GUI->GUI_BAIRFN /*Verifica se as datas antendem os parametros*/
			deVlDeduzir  := GUI->GUI_VLDEDZ /*Recebe o valor a deduzir*/
			dePcAliquota := GUI->GUI_PCALIR /*Recebe o percentual da aliquota*/
   		Endif
   		dbSelectArea("GUI")
   		dbSkip()
   	EndDo

	deVlIR := (deVlCalcFrete * (dePcAliquota / 100)) - deVlDeduzir

	GFEA100AL("      Dedução Dependentes(-): ", PadL(AllTrim(Transform(MAX(nVlDep,nVlDeOut), "@E 999,999,999.99")), 14) + " (-)")
	GFEA100AL("          Base de Cálculo(=): ", PadL(AllTrim(Transform(deVlCalcFrete, "@E 999,999,999.99")), 14) + " (=)")
	GFEA100AL("                 Alíquota(*): ", PadL(AllTrim(Transform(dePcAliquota,  "@E 999,999,999.99")), 14) + " (*)")
	GFEA100AL("          Valor a deduzir(-): ", PadL(AllTrim(Transform(deVlDeduzir,   "@E 999,999,999.99")), 14) + " (-)")
	GFEA100AL("                Calculado(=): ", PadL(AllTrim(Transform(deVlIR,        "@E 999,999,999.99")), 14) + " (=)")
	GFEA100AL(" Valor a outros contratos(-): ", PadL(AllTrim(Transform(deVlTotalIR,   "@E 999,999,999.99")), 14) + " (-)")
	
	deVlIR := deVlIR - deVlTotalIR

	GFEA100AL("     Novo Valor Calculado(=): ", PadL(AllTrim(Transform(deVlIR,        "@E 999,999,999.99")), 14) + " (=)")
	
    If deVlIR < 0
        deVlIR := 0
	Endif

    If deVlIR < nMINIRF .And. deVlTotalIR < nMINIRF
    	nIrrf := 0
    	GFEA100AL("Valor IRRF menor que parâmetro: ", "Calculado-> " + cValToChar(deVlIR) + " - Parâmetro MV_MINIRF -> " + cValToChar(SuperGetMv("MV_MINIRF",, 0)))
    Else
	    nIrrf := round(deVlIR,2) 
    Endif
Return

//-------------------------------------------------------------------
/*/{Protheus.doc} GFEA100CA

Função do botão de cancelamento do contrato.

@author Jorge Matos Valcanaia
@since 19/02/10
@version 1.0
/*/
//-------------------------------------------------------------------

Function GFEA100CA()
	Local lRet 	  := .T.
	Local cTpDoc  := '3'

	If GW2->GW2_SITFIN == "2"
		Help( ,, 'HELP',, "O Contrato está Pendente no Financeiro, portanto, não poderá ser cancelado.", 1, 0) //"Contrato está pendente no Financeiro, o mesmo não pode ser cancelado."
		Return .F.
	EndIf

	If GW2->GW2_SITFIN == "4"
		Help( ,, 'HELP',, "O Contrato está Atualizado no Financeiro. Primeiramente o Contrato deve ser desatualizado para então poder ser cancelado.", 1, 0)
		Return .F.
	EndIf

	If GW2->GW2_SITFIN == "5"
		Help( ,, 'HELP',, "O Contrato está Pendende de Desatualização no Financeiro, é necessário aguardar o retorno.", 1, 0)
		Return .F.
	EndIf

	If GW2->GW2_SITRH == "2"
		Help( ,, 'HELP',, "O Contrato está Pendente no Recursos Humanos, portanto, não poderá ser cancelado.", 1, 0)
		Return .F.
	EndIf

	If GW2->GW2_SITRH == "4"
		Help( ,, 'HELP',, "O Contrato está Atualizado no Recursos Humanos. Primeiramente o Contrato deve ser desatualizado para então poder ser cancelado.", 1, 0)
		Return .F.
	EndIf

	If GW2->GW2_SITRH == "5"
		Help( ,, 'HELP',, "O Contrato está Pendende de Desatualização no Recursos Humanos, é necessário aguardar retorno.", 1, 0)
		Return .F.
	EndIf

	If GW2->GW2_SITREC == "2"
		Help( ,, 'HELP',, "O Contrato está Pendente no Recebimento, portanto, não poderá ser cancelado.", 1, 0)
		Return .F.
	EndIf

	If GW2->GW2_SITREC == "4"
		Help( ,, 'HELP',, "O Contrato está Atualizado no Recebimento. Primeiramente o Contrato deve ser desatualizado para então poder ser cancelado.", 1, 0)
		Return .F.
	EndIf

	If GW2->GW2_SITREC == "5"
		Help( ,, 'HELP',, "O Contrato está Pendende de Desatualização no Recebimento, é necessário aguardar retorno.", 1, 0)
		Return .F.
	EndIf

	If APMSGYESNO(STR0067) //"Deseja Cancelar o Contrato ?"

		If ExistBlock("GFEA1002")
			lRet := ExecBlock("GFEA1002",.f.,.f.,{10})
			If lRet == .F. 
				Return lRet
			EndIf
		EndIf

		cAlias := GetNextAlias()
	
		cAliasGWF := GetNextAlias()
		cQuery := " SELECT GWF.* FROM "+RetSQLName("GWF")+" GWF "
		cQuery += " INNER JOIN "+RetSQLName("GW2")+" GW2 ON GW2.GW2_FILIAL = '"+xFilial("GW2")+"' AND GW2.GW2_NRCONT = GWF.GWF_NRCONT "		
		cQuery += " WHERE GWF.D_E_L_E_T_ = ' ' "
		cQuery += " ORDER BY GWF.GWF_FILIAL, GWF.GWF_NRCONT, GWF.GWF_NRCALC  "
		
		cQuery := ChangeQuery(cQuery)
		GFEConout("INFO",cQuery)
		dbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery),cAlias, .F., .T.)
	
		dbSelectArea((cAlias))
		(cAlias)->( dbGoTop() )

		While !(cAlias)->( Eof() )	

			dbSelectArea("GWF")
			GWF->( dbSetOrder(2) )
			GWF->( dbSeek(xFilial("GWF") +GW2->GW2_NRCONT) ) 
			If (cAlias)->GWF_NRCALC == GWF->GWF_NRCALC
				
				// Busca o rateio do contrato para exclusão
				cAliasGWM := GetNextAlias()
				BeginSql Alias cAliasGWM
					SELECT  GWM_NRDOC
					FROM %Table:GWM% GWM
					INNER JOIN %Table:GW2% GW2
					ON GW2.GW2_FILIAL	 = GWM.GWM_FILIAL
					AND GW2.GW2_NRCONT 	 = GWM.GWM_NRDOC
					WHERE GWM.GWM_FILIAL = %Exp:(cAlias)->GWF_FILIAL%
					AND GWM.GWM_NRDOC    = %Exp:(cAlias)->GWF_NRCONT%
					AND GWM.GWM_TPDOC	 = '3'
					AND GWM.%NotDel%
				EndSql
	
				dbSelectArea("GWM")
				GWM->( dbSetOrder(1) )
				GWM->(dbSeek(xFilial("GWM")+cTpDoc+PadR("",5)+(cAlias)->GWF_TRANSP+PadR("",5)+(cAlias)->GWF_NRCONT))
				While !GWM->(Eof()) .AND. GWM->GWM_NRDOC == (cAliasGWM)->GWM_NRDOC 
					RecLock("GWM",.F.)
						GWM->(dbDelete())
					GWM->(MsUnLock())
					GWM->(dbSkip())
				EndDo
				(cAliasGWM)->(dbCloseArea())

				RecLock("GWF",.F.) //Trava o registro do cálculo		
					GWF->GWF_NRCONT := "" // Limpa o campo que contém o número do contrato no cálculo
				MsUnLock() //Destrava tabela
				
				GFERatCal(.F., GWF->GWF_NRCALC)
				dbSelectArea(cAlias)
				dbSkip()
		 	Else 
				dbSelectArea(cAlias)
				dbSkip()
			Endif
		EndDo
		(cAlias)->( dbCloseArea() )

		RecLock("GW2", .F.)	/*Trava o contrato para ser alterado*/
			GW2->GW2_USUCAN := cUserName /*Grava o usuario que fez o cancelamento*/
			GW2->GW2_DTCANC := DDATABASE /*Grava a data do cancelamento*/
			GW2->GW2_SITCON := "4" /*Passa a situação do contrato de criado para cancelado*/
		MsUnLock("GW2") /*Destrava tabela*/
	EndIf
Return

//-------------------------------------------------------------------
/*/{Protheus.doc} GFEA100VA
Validação de alteração
Função que verifica antes de ser aberta a tela de alteração se o contrato já foi cancelado ou imprisso.

@author Jorge Matos Valcanaia
@since 19/02/10
@version 1.0
/*/
//-------------------------------------------------------------------
Function GFEA100VA(nOpc)    
	Local lRet := .T.
	
    If nOpc == MODEL_OPERATION_UPDATE
		If GW2->GW2_SITFIN == "2".OR.GW2->GW2_SITFIN == "4"
			Help( ,, 'HELP',, STR0077 + " no Financeiro", 1, 0,) //"Não é possível alterar um Documento Pendente ou Atualizado"
			Return .F.
		Endif

		If GW2->GW2_SITCON == "3" /*Se a situação do contrato estiver como 3(Impresso) ele não pode permitir que o mesmo seja alterado mostrando então uma mansagem de erro*/
			Help( ,, 'HELP',,STR0014, 1, 0) //"Contrato já foi impresso, não pode mais ser alterado."
			Return .F.
		Endif
		If GW2->GW2_SITCON == "4" /*Se a situação do contrato estiver como 4(Cancelado) ele não pode permitir que o mesmo seja alterado mostrando então uma mensagem de erro*/
			Help( ,, 'HELP',,STR0015, 1, 0) //"Contrato já foi cancelado, não pode mais ser alterado."
			Return .F.
		Endif
		FWExecView("","GFEA100",4,,{||.T.})/*Se a situação do contrato for 1(Criado) então abre a tela de alteração normal*/
	Endif
	If nOpc == 5
		If GW2->GW2_SITCON <> "1"
			Help( ,, 'HELP',,STR0068, 1, 0) //"Apenas contratos com situação igual a 'Criado' podem ser excluidos."
			Return .F.
		Else
			
			If ExistBlock("GFEA1002")
				lRet := ExecBlock("GFEA1002",.f.,.f.,{nOpc})
				If lRet == .F. 
					Return lRet
				EndIf
			EndIf
		
			FWExecView("","GFEA100",5,,{||.T.})
		Endif
	Endif

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} GFEA100PO(oModel)

Validação de bPost aonde qualquer alteração no contrato altera o mesmo de Liberado para Criado.

@author Jorge Matos Valcanaia
@since 19/02/10
@version 1.0
/*/
//-------------------------------------------------------------------
Function GFEA100PO(oModel)
	Local lRet     := .T.
	Local nOpc     := (oModel:GetOperation())
	Local cTpProp  := ""
	Local cCodVei1 := ""
	Local cCodVei2 := ""
	Local cCodVei3 := ""
	Local cSitProp := ""
	Local cSitMot  := ""
	Local aRet     := {.T.,"",""}


    If IsInCallStack("GFEA100In")
    	If nOpc == MODEL_OPERATION_UPDATE

    		If FWFldGet("GW2_SITFIN") $ "25" //"Atualizar Financeiro ERP"
				GFEA100IPG("1",FWFldGet("GW2_SITFIN"),oModel,@aRet,FWFldGet("GW2_NRCONT") )

				If !Empty(aRet[2])
					If !aRet[1] //retorno falso
						oModel:SetValue( 'GFEA100_GW2', 'GW2_SITFIN', "3")
						oModel:SetValue( 'GFEA100_GW2', 'GW2_MOTFIN', AllTrim(aRet[3]) )

					Else //retorno verdadeiro
						oModel:SetValue( 'GFEA100_GW2', 'GW2_SITFIN', "4")
						oModel:SetValue( 'GFEA100_GW2', 'GW2_MOTFIN', " ")
					EndIf
				EndIf

			EndIf

			If FWFldGet("GW2_SITREC") $ "25" //"Atualizar Recebimento ERP"
				GFEA100IPG("2",FWFldGet("GW2_SITREC"),oModel,@aRet,FWFldGet("GW2_NRCONT"))

				If !Empty(aRet[2])
					If !aRet[1] //retorno falso
						oModel:SetValue( 'GFEA100_GW2', 'GW2_SITREC', "3")
						oModel:SetValue( 'GFEA100_GW2', 'GW2_MOTREC', AllTrim(aRet[3]) )
						
					Else //retorno verdadeiro
						oModel:SetValue( 'GFEA100_GW2', 'GW2_SITREC', "4")
						oModel:SetValue( 'GFEA100_GW2', 'GW2_MOTREC', " ")
					EndIf
				EndIf

			EndIf

    	EndIf

    	Return .T.
    EndIf

	/*Executa a validação para que não possa ser incluso um valor como desconto
	e que tenha todos os valores de base como sim, quando é clicado no botão OK
	em tela ele contem a descrição de base como "Sim" mas no banco de dados ele
	vai salvar como não, fazendo está confirmação basta entrar no registro e
	conferir que o mesmo foi salvo como "Não"*/
	if nOpc == MODEL_OPERATION_INSERT .Or. nOpc == MODEL_OPERATION_UPDATE
		dbSelectArea("GWF")
		dbSetOrder(2)
		If dbSeek(xFilial("GWF")+FwFldGet("GW2_NRCONT")/*GW2->GW2_NRCONT*/)
			If GW2->GW2_CDPROP <> FwFldGet("GW2_CDPROP")
				Help( ,, 'HELP',,STR0069, 1, 0) //"O proprietário não pode ser alterado pois já foram vinculados cálculos ao contrato."
				Return .F.
			Endif
		Endif

		If FwFldGet("GW2_DTVENC") < DDATABASE
			Help( ,, 'HELP',,STR0070, 1, 0) //"Data de vencimento deve ser maior que a data corrente."
			Return .F.
		Endif

		cTpProp := posicione("GU3",1,xFilial("GU3")+FwFldGet("GW2_CDPROP"),"GU3_AUTON")
		If cTpProp == "2"
			Help( ,, 'HELP',,STR0071, 1, 0) //"Proprietário informado para o contrato não é autônomo."
			Return .F.
		Endif

		cSitProp := posicione("GU3",1,xFilial("GU3")+FwFldGet("GW2_CDPROP"),"GU3_SIT")
		If cSitProp == "2"
			Help( ,, 'HELP',,STR0072, 1, 0) //"Proprietário informado está com situação igual inativo."
			Return .F.
		Endif

		cSitMot := posicione("GUU",1,xFilial("GUU")+FwFldGet("GW2_CDMTR"),"GUU_SIT")
		If cSitMot == "2"
			Help( ,, 'HELP',,STR0073, 1, 0) //"Motorista informado está com situação igual inativo."
			Return .F.
		Endif

		cCodVei1 := posicione("GU8",1,xFilial("GU8")+FwFldGet("GW2_CDVEI1"),"GU8_CDPROP")
		If FwFldGet("GW2_CDPROP") <> cCodVei1 .And. !Empty(FwFldGet("GW2_CDVEI1"))
			Help( ,, 'HELP',,STR0074, 1, 0) //"O proprietário do primeiro veículo é diferente do proprietário informado para o contrato."
			Return .F.
		Endif

		cCodVei2 := posicione("GU8",1,xFilial("GU8")+FwFldGet("GW2_CDVEI2"),"GU8_CDPROP")
		If FwFldGet("GW2_CDPROP") <> cCodVei2 .And. !Empty(FwFldGet("GW2_CDVEI2"))
			Help( ,, 'HELP',,STR0075, 1, 0) //"O proprietário do segundo veículo é diferente do proprietário informado para o contrato."
			Return .F.
		Endif

		cCodVei3 := posicione("GU8",1,xFilial("GU8")+FwFldGet("GW2_CDVEI3"),"GU8_CDPROP")
		If FwFldGet("GW2_CDPROP") <> cCodVei3 .And. !Empty(FwFldGet("GW2_CDVEI3"))
			Help( ,, 'HELP',,STR0076, 1, 0) //"O proprietário do terceiro veículo é diferente do proprietário informado para o contrato."
			Return .F.
		Endif
	Endif

	If nOpc == MODEL_OPERATION_UPDATE
		oModel:SetValue("GFEA100_GW2","GW2_SITCON","1")
	Endif

	If nOpc == MODEL_OPERATION_DELETE
		dbSelectArea("GWF")
		dbSetOrder(2)
		dbSeek(xFilial("GWF")+GW2->GW2_NRCONT)
		While !Eof() .And. xFilial("GWF") == GWF->GWF_FILIAL
			IF  GWF->GWF_NRCONT == GW2->GW2_NRCONT
				RecLock("GWF",.F.)
				GWF->GWF_NRCONT := ""
				MsUnLock("GWF")
			ENDIF
			dbSelectArea("GWF")
			dbSkip()
		EndDo
	Endif

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} GFEA100GC()

Função que cálcula os Impostos referentes ao Contrato

@author Jorge Matos Valcanaia
@since 19/02/10
@version 1.0
/*/
//-------------------------------------------------------------------
Function GFEA100GC()

	Local nPnIss
	Local cPesFis      /*Pessoa fisica*/
	Local nSestAux  := 0
	Local nSenatAux := 0
	
	Public dDataDeCont
	Public dDataAteCont
	Public cCodProp
	Public dGw2DtCria := GW2->GW2_DTCRIA
	Public dGw2DtVenc := GW2->GW2_DTVENC
	Public cNrCont    := GW2->GW2_NRCONT
	Public nQtDeIR	  := GW2->GW2_QTDEIR

	/*
	Quando a função for chamada através do programa de geração de contrato em lote
	as variaveis Private, não foram declaradas, necessitando assim a inicialização de nVlTotFret
	*/
	If (IsInCallStack("GFEA101"))
		nVlTotFret   := 0 // Total do frete:  nFretCont + nFretContImp
	EndIf
	
	nVlIrrf :=  nIrrf

	GFEA100AL(" ***********************", "")
	GFEA100AL("        CALCULO ISS     ","")
	GFEA100AL(" ***********************", "")
	If GW2->GW2_CIDORI == GW2->GW2_CIDDES .And. !Empty(GW2->GW2_CIDORI) /*Verifica se o campo da GW2_CIDORI é o mesmo da GW2_CIDDES e se ele tambem esta diferente de branco*/
		If empty(POSICIONE("GU3",1,XFILIAL("GU3")+GW2->GW2_CDPROP,"GU3_PCISS"))
			nPnIss := posicione("GU7",1,xFilial("GU7")+GW2->GW2_CIDORI,"GU7_PCISS")	/*Se for o mesmo posiciona na tabela de cidades e retorna o ISS da cidade cadastrada*/
		Else 
			nPnIss := (POSICIONE("GU3",1,XFILIAL("GU3")+GW2->GW2_CDPROP,"GU3_PCISS"))
		Endif 
		nIss   := round((nIss + nFretCont) * (nPnIss / 100),2) /*nIss recebe ela mesmo mais o valor do total do frete contratado vezes a porcentagem do nPnIss dividido por 100*/
		
		GFEA100AL("BASE ISS: ", cValToChar((nIss + nFretCont)))
		GFEA100AL("Percetual ISS: ", cValToChar((nPnIss / 100)))
		GFEA100AL("Valor ISS: ", cValToChar(nIss))
	Else
		nIss := 0 /*Se não for a mesma cidade então nIss recebe 0*/
		GFEA100AL("Calculo ISS: ","NAO CALCULADO - CIDADES DIFERENTES")
	Endif

	cCodProp     := GW2->GW2_CDPROP /*Recebe o codigo do proprietario*/

 	dDataDeCont := DTOS(CtoD(STR(01) + "/" + STR(MONTH(GW2->GW2_DTCRIA)) + "/" + STR(YEAR(GW2->GW2_DTCRIA))))  /*Recebe a data de Inicio*/
	dDataAteCont  := DTOS( CtoD(STR(Last_Day(GW2->GW2_DTCRIA)) + "/" + STR(MONTH(GW2->GW2_DTCRIA)) + "/" + STR(YEAR(GW2->GW2_DTCRIA)))) /*Recebe a data final    */
	
	nInssAuto2   := nInssAuto

	cPesFis := posicione("GU3",1,xFilial("GU3")+GW2->GW2_CDPROP,"GU3_NATUR")

	If cPesFis == "F"
		GFEA100AL("Proprietário: ", GW2->GW2_CDPROP + 'Pessoa Fisica - Realizando cálculo de IRRF')
 		nSestAux  := NoRound(((nSestAux + nFretCont + nSestSenat) * ( SuperGetMv("MV_BASINS",, 100) / 100)) * (SuperGetMv("MV_PCSEST ",, 0) / 100),2) /*nSestAux recebe ela mesma mais o valor do total do frete contratado vezes a porcentagem do parametro do SEST dividido por 100*/
		nSenatAux := NoRound(((nSenatAux + nFretCont + nSestSenat) * ( SuperGetMv("MV_BASINS",, 100) / 100)) * (SuperGetMv("MV_PCSENA ",, 0) / 100),2) /*nSenatAux recebe ela mesma mais o valor do total do frete contratado vezes a porcentagem do parametro do SENAT dividido por 100*/

		nSestSenat := nSestAux + nSenatAux
		//GFEA100IR() Retirado por diferença no calculo do IRRF de autônomos.
	Endif
	
	/*Verifica se o codigo do proprietario gravado na variavel é o mesmo na tabela e verifica se a data esta dentro das datas gravadas e se esta com situação diferente de Cancelado*/
	listContratos()

	nInssOtEmp := nInssOutEmp

	GFEA100AT(1)/*Executa a função para que sejam feitos os cálculos e sejam atualizadas as variaveis*/
Return

//---------------------------------------------------------------------------------------------------
/*/{Protheus.doc} GFEA100VL()
Validações
Generico

@sample
GFEA070X()

@author Israel Possoli
@since 11/04/2010
@version 1.0
/*///------------------------------------------------------------------------------------------------

Function GFEA100VL(oModel)
	Local lRet    := .T.
	local nOpc    := (oModel:GetOperation())

	/* --- Eliminação  --- */
	If nOpc == MODEL_OPERATION_DELETE.AND.(GW2->GW2_SITFIN == "2".OR.GW2->GW2_SITFIN == "4")
		Help( ,, 'HELP',, STR0078, 1, 0,) //"Não é possível eliminar um Documento Pendente ou Atualizado"
		lRet := .F.
	EndIf

Return lRet

//---------------------------------------------------------------------------------------------------
/*/{Protheus.doc} GFEA100VD()
Integração com EMS
Generico

@sample
GFEA070X()

@author Israel Possoli
@since 08/04/2010
@version 1.0
/*///------------------------------------------------------------------------------------------------
Function GFEA100X(cAcao, lAutom)
	Local lRet       := .F.
	Local xRet 		 := .T.
	Local aRet
	Local dData      := Iif(IsBlind(),Date(),dDataBase)
	Local lOk        := .T.
	Local cParData   := SuperGetMV('MV_DSDTAP',,'1') // Parametro Int Origem Data de Integração
	Local cParDataRe := SuperGetMV('MV_DSDTRE',,'1') // Parametro Int Origem Data de Integração
	Local lIntGFE 	 := SuperGetMv("MV_INTGFE",.F.,.F.)
	Local cIntGFE2 	 := SuperGetMv("MV_INTGFE2",.F.,"2")
	
	Private lAutom2  := lAutom
	
	Default lAutom   := .F.

	If AllTrim(cAcao) == "1" // Atualizar financeiro

		If GW2->GW2_SITFIN == "1" .OR. GW2->GW2_SITFIN == "3"

			If GW2->GW2_SITCON == "3" // Impresso
			
				If ExistBlock("GFEA1003")
					xRet := ExecBlock("GFEA1003",.f.,.f.)
					If xRet == .F. 
						Return xRet
					EndIf
				EndIf
			
				If SuperGetMV("MV_ERPGFE",,"2") == '2' //quando o ERP for Protheus a data de integração/transação será atribuída pelo sistema com a data corrente
					dData := DDATABASE
				Else
					If cParData == "3" //Informada Usuário

						DEFINE DIALOG oDlg TITLE STR0079 FROM 180,180 TO 350,460 PIXEL //"Seleciona a Data"
						    // Cria objeto
							oMsCalend := MsCalend():New(01,01,oDlg,.F.)

						    // Define o dia a ser exibido no calendário
						    oMsCalend:dDiaAtu := dData

						    // Code-Block para mudança de Dia
						    //oMsCalend:bChange := {|| Alert('Dia Selecionado: ' + dtoc(oMsCalend:dDiaAtu)) }
						    oMsCalend:bChange := {|| dData := oMsCalend:dDiaAtu}

						    // Code-Block para mudança de mes
						    //oMsCalend:bChangeMes := {|| alert('Mes alterado') }

				    		oTButton1 := TButton():New( 070, 30, STR0080,oDlg,{||lOk := .T.,oDlg:End()}, 40,10,,,.F.,.T.,.F.,,.F.,,,.F. ) //"Ok"
				    		oTButton1 := TButton():New( 070, 75, STR0006,oDlg,{||lOk := .F.,oDlg:End()}, 40,10,,,.F.,.T.,.F.,,.F.,,,.F. ) //"Cancelar"

						ACTIVATE DIALOG oDlg CENTERED

					ElseIf cParData == "1" 		//Data Corrente
					 	dData := DDATABASE
					ElseIf cParData == "2" 		//Data Criação
						dData := GW2->GW2_DTCRIA
					EndIf

				EndIf

				If dData < GW2->GW2_DTCRIA

					If lAutom2
						GFEContLog:AddDetail("Contrato: " + GW2->GW2_NRCONT + ". A data de transação deve ser maior que a data de emissão.")
					Else		
						Help( ,, 'Help',, STR0081, 1, 0 )  //"A data de transação deve ser maior que a data de emissão"
					EndIf
					lOk := .F.

				EndIf

				If lOk
					aRet := GFEA100In("2", dData, cAcao)

					If !(lIntGFE == .T. .And. cIntGFE2 $ "1S")
						If aRet[1]
							If lAutom2
								GFEContLog:AddDetail("Contrato: " + GW2->GW2_NRCONT + " enviado para atualização no " + {"Financeiro", "RH", "Recebimento"}[Val(cAcao)] + ".")
							Else
								MsgInfo("Contrato enviado para atualização no " + {"Financeiro", "RH", "Recebimento"}[Val(cAcao)] + ".")
							EndIf
						Else
							If lAutom2
								GFEContLog:AddDetail("Contrato: " + GW2->GW2_NRCONT + " não foi enviado para atualização no " + {"Financeiro", "RH", "Recebimento"}[Val(cAcao)] + " por causa do seguinte erro: " + aRet[2][6])
							Else
								Alert("Contrato não foi enviado para atualização no " + {"Financeiro", "RH", "Recebimento"}[Val(cAcao)] + " por causa do seguinte erro: " + aRet[2][6])
							EndIf
						EndIf
					EndIf
				EndIf
			Else
				If lAutom2
					GFEContLog:AddDetail("Contrato: " + GW2->GW2_NRCONT + ". Documento ainda não foi impresso, não é possível atualizar o Financeiro.")
				Else
					Help( ,, 'Help',, STR0082, 1, 0 ) //"Documento ainda não foi impresso"
				EndIf
			EndIf

		Else
			If lAutom2
				GFEContLog:AddDetail("Contrato: " + GW2->GW2_NRCONT + ". Documento Pendente ou já Atualizado no Financeiro.")
			Else
				Help( ,, 'Help',, STR0083, 1, 0 ) //"Documento Pendente ou já Atualizado"
			EndIf
		EndIf

	ElseIf AllTrim(cAcao) == "2" //Atualizar RH

		If GW2->GW2_SITRH == "6"
			If lAutom2
				GFEContLog:AddDetail("Contrato: " + GW2->GW2_NRCONT + ". Atualização com HCM não se aplica quando ERP integrado for Protheus.")
			Else
				Help( ,, 'Help',, "Atualização com HCM não se aplica quando ERP integrado for Protheus.", 1, 0 )
			EndIf
			Return
		EndIf
		
		If GW2->GW2_SITRH == "2" .Or. GW2->GW2_SITRH == "4"
			If lAutom2
				GFEContLog:AddDetail("Contrato: " + GW2->GW2_NRCONT + ". Documento Pendente ou já Atualizado no RH.")
			Else
				Help( ,, 'Help',, STR0083, 1, 0 ) //"Documento Pendente ou já Atualizado"
			EndIf
			Return
		EndIf
		
		If GW2->GW2_SITFIN != "4" // Atualizado
			If lAutom2
				GFEContLog:AddDetail("Contrato: " + GW2->GW2_NRCONT + ". A situação do financeiro não está atualizado.")
			Else
				Help( ,, 'Help',, STR0084, 1, 0 ) //"A situação do financeiro não está atualizado"
			EndIf
			Return
		EndIf
		
		aRet := GFEA100In("2", dData, cAcao)
		
		If aRet[1]
			If lAutom2
				GFEContLog:AddDetail("Contrato: " + GW2->GW2_NRCONT + " enviado para atualização no " + {"Financeiro", "RH", "Recebimento"}[Val(cAcao)] + ".")
			Else
				MsgInfo("Contrato enviado para atualização no " + {"Financeiro", "RH", "Recebimento"}[Val(cAcao)] + ".")
			EndIf
		Else
			If lAutom2
				GFEContLog:AddDetail("Contrato: " + GW2->GW2_NRCONT + " não foi enviado para atualização no " + {"Financeiro", "RH", "Recebimento"}[Val(cAcao)] + " por causa do seguinte erro: " + aRet[2][6])
			Else
				Alert("Contrato não foi enviado para atualização no " + {"Financeiro", "RH", "Recebimento"}[Val(cAcao)] + " por causa do seguinte erro: " + aRet[2][6])
			EndIf
		EndIf

	ElseIf AllTrim(cAcao) == "3" //Atualizar Recebimento

		If GW2->GW2_SITCON != "3"
			If lAutom2
				GFEContLog:AddDetail("Contrato: " + GW2->GW2_NRCONT + ". O Contrato não foi Impresso para ser enviado para o Recebimento.")
			Else
				Help( ,, 'Help',, "O Contrato não foi Impresso para ser enviado para o Recebimento.", 1, 0 )
			EndIf
			Return
		EndIf

		If GW2->GW2_SITREC != "1".AND.GW2->GW2_SITREC != "3" // Não-Enviado ou Rejeitado
			If lAutom2
				GFEContLog:AddDetail("Contrato: " + GW2->GW2_NRCONT + ". Somente Contratos Não-Enviados ou Rejeitados podem ser integrados.")
			Else
				Help( ,, 'Help',, "Somente Contratos Não-Enviados ou Rejeitados podem ser integrados", 1, 0 ) //"Somente Documentos de Frete Não-Enviado ou Rejeitado podem ser integrados"
			EndIf
			Return
		EndIf

		If cParDataRe == "3" //Informada Usuário
			dData := GFEA065DT()
		ElseIf cParDataRe == "1" //Data Corrente
		 	dData := DDATABASE
		ElseIf cParDataRe == "2" //Data Entrada
			dData := GW3->GW3_DTENT
		EndIf

		If Empty(dData)
			Return
		EndIf

		If dData <= SuperGetMv("MV_DTULFE",,"20000101")
			If lAutom2
				GFEContLog:AddDetail("Contrato: " + GW2->GW2_NRCONT + ". Data de transação deve ser posterior a data do último fechamento: " + DTOC(SuperGetMv("MV_DTULFE",,"20000101")))
			Else
				Help( ,, 'Help',, "Data de transação deve ser posterior a data do último fechamento: " + DTOC(SuperGetMv("MV_DTULFE",,"20000101")) + STR0076, 1, 0 ) //"Data de transação deve ser posterior a data do último fechamento: "###" (Parâmetro MV_DTULFE)"
			EndIf
			Return
		EndIf

		aRet := GFEA100In("2", dData, cAcao)

		If !(lIntGFE == .T. .And. cIntGFE2 $ "1S")
			If aRet[1]
				If lAutom2
					GFEContLog:AddDetail("Contrato: " + GW2->GW2_NRCONT + " enviado para atualização no " + {"Financeiro", "RH", "Recebimento"}[Val(cAcao)] + ".")
				Else
					MsgInfo("Contrato enviado para atualização no " + {"Financeiro", "RH", "Recebimento"}[Val(cAcao)] + ".")
				EndIf
			Else
				If lAutom2
					GFEContLog:AddDetail("Contrato: " + GW2->GW2_NRCONT + " não foi enviado para atualização no " + {"Financeiro", "RH", "Recebimento"}[Val(cAcao)] + " por causa do seguinte erro: " + aRet[2][6])
				Else
					Alert("Contrato não foi enviado para atualização no " + {"Financeiro", "RH", "Recebimento"}[Val(cAcao)] + " por causa do seguinte erro: " + aRet[2][6])
				EndIf
			EndIf
		EndIf

	ElseIf AllTrim(cAcao) == "4" //Desatualizar Financeiro

		If GW2->GW2_SITFIN == "4"
			aRet := GFEA100In("5", dData, cAcao)

			If !(lIntGFE == .T. .And. cIntGFE2 $ "1S")
				If !aRet[1]
					Alert("Contrato não foi enviado para desatualização no Financeiro por causa do seguinte erro: " + aRet[2][6])
				EndIf
			EndIf
		Else
			Help( ,, 'Help',, "Documento não está atualizado ou rejeitado no financeiro.", 1, 0 )
		EndIf

	ElseIf AllTrim(cAcao) == "5" //Desatualizar Recebimento

		If GW2->GW2_SITREC == "4"
			aRet := GFEA100In("5", dData, cAcao)

			If !(lIntGFE == .T. .And. cIntGFE2 $ "1S")
				If !aRet[1]
					Alert("Contrato não foi enviado para desatualização no Recebimento por causa do seguinte erro: " + aRet[2][6])
				EndIf
			EndIf

		Else
			Help( ,, 'Help',, "Documento não está atualizado ou rejeitado no Recebimento.", 1, 0 )
		EndIf

	EndIf

Return lRet

//---------------------------------------------------------------------------------------------------
/*/{Protheus.doc} GFEA100In()
Função utilizada em Integração.
Generico

@sample
GFEA100In()

@author Israel Possoli
@since 14/04/2010
@version 1.0
/*///------------------------------------------------------------------------------------------------
Function GFEA100In(cSituacao, dData, cAcao)
	Local oModel 	:= FWLoadModel("GFEA100")
	Local aRet   	:= {.T., {}}
	Local cInt   	:= ""
	Local aRetAux := {.T.,"",""}
	
	
	If cSituacao == "5"
		If cAcao == "4"
			cAcao := "1"
			cInt := "1" //Financeiro

		ElseIf cAcao == "5"
			cAcao := "3"
			cInt := "2" //Recebimento

		EndIf

		//Desatualização do Contrato no Protheus. Nova integração.
		//Uso do RecLock pelo confronto do retorno de erro do MsExecAuto com o model
		GFEA100IPG(cInt,"5",oModel,@aRetAux,GW2->GW2_NRCONT)

		If !Empty(aRetAux[2])

			If aRetAux[1]

				RecLock("GW2", .F.)
					If cInt == "1" //Financeiro
						GW2->GW2_SITFIN := "1"
						GW2->GW2_MOTFIN := ""
						GW2->GW2_DTFIN  := dData
						GW2->GW2_HRFIN  := SubStr(Time(), 1, 5)
					ElseIf cInt == "2" //Recebimento
						GW2->GW2_SITREC := "1"
						GW2->GW2_MOTREC := ""
						GW2->GW2_DTREC  := dData
						GW2->GW2_HRREC  := SubStr(Time(), 1, 5)
					EndIf
				GW2->( MsUnlock() )

				Return {.T., {}}

			Else

				RecLock("GW2", .F.)
					If cInt == "1" //Financeiro
						GW2->GW2_SITFIN := "4"
						GW2->GW2_MOTFIN := aRetAux[3]
					ElseIf cInt == "2" //Recebimento
						GW2->GW2_SITREC := "4"
						GW2->GW2_MOTREC := aRetAux[3]
					EndIf
				GW2->( MsUnlock() )

				Return {.F., {,,,,,aRetAux[3]}}

			EndIf

		EndIf

	EndIf

	oModel:SetOperation( 4 )
	oModel:Activate()

	If AllTrim(cAcao) == "1"

		oModel:SetValue( 'GFEA100_GW2', 'GW2_SITFIN', AllTrim(cSituacao))	 	// SITUAÇÃO NO FINANCEIRO

		If cSituacao != "5"
			oModel:SetValue('GFEA100_GW2', 'GW2_DTFIN', dData)					// DATA ENVIO AO FINANCEIRO -à Data informada pelo usuário
			oModel:SetValue('GFEA100_GW2', 'GW2_HRFIN', SubStr(Time(), 1, 5))		// HORA ENVIO AO FINANCEIRO
		EndIf

		If cSituacao == "2"
			oModel:ClearField('GFEA100_GW2', 'GW2_MOTFIN')
		EndIf

		oModel:SetValue( 'GFEA100_GW2', 'GW2_USUFIN', cUserName) // USUARIO ENVIO FINANCEIRO

	EndIf

	If AllTrim(cAcao) == "2"

		oModel:SetValue( 'GFEA100_GW2', 'GW2_SITRH', AllTrim(cSituacao))	 	// SITUAÇÃO NO RH

		If cSituacao != "5"
			oModel:SetValue( 'GFEA100_GW2', 'GW2_DTRH', dData)						// DATA ENVIO AO RH -à Data informada pelo usuário
			oModel:SetValue( 'GFEA100_GW2', 'GW2_HRRH',  SubStr(Time(), 1, 5))		// HORA ENVIO AO RH
		EndIf

		If cSituacao == "2"
			oModel:ClearField('GFEA100_GW2', 'GW2_MOTRH')
		EndIf

		oModel:SetValue( 'GFEA100_GW2', 'GW2_USURH', cUserName) // USUARIO ENVIO RH
		
	EndIf

	If AllTrim(cAcao) == "3"

		oModel:SetValue( 'GFEA100_GW2', 'GW2_SITREC', AllTrim(cSituacao))	 	// SITUAÇÃO NO RECEBIMENTO

		If cSituacao != "5"
			oModel:SetValue( 'GFEA100_GW2', 'GW2_DTREC', dData)					// DATA ENVIO AO RECEBIMENTO -à Data informada pelo usuário
			oModel:SetValue( 'GFEA100_GW2', 'GW2_HRREC',  SubStr(Time(), 1, 5))	// HORA ENVIO AO RECEBIMENTO
		EndIf

		If cSituacao == "2"
			oModel:ClearField('GFEA100_GW2', 'GW2_MOTREC')
		EndIf

		oModel:SetValue( 'GFEA100_GW2', 'GW2_USUREC', cUserName) // USUARIO ENVIO RECEBIMENTO

	EndIf

	oModel:SetValue( 'GFEA100_GW2', 'GW2_ACINT',  AllTrim(cAcao))

	// Busca código do proprietário
	oModel:SetValue( 'GFEA100_GW2', 'GW2_CGCPRO', AllTrim(Posicione("GU3",1,xFilial("GU3")+GW2->GW2_CDPROP, "GU3_IDFED" )) )
	// Busca a conta de frete da filial
	oModel:SetValue( 'GFEA100_GW2', 'GW2_CTFRET', AllTrim(Posicione("GUS",1,xFilial("GUS")+GW2->GW2_FILIAL, "GUS_CTFRET")) )

	If oModel:VldData()
		oModel:CommitData()
	Else
		aRet := {.F., oModel:GetErrorMessage()}
	EndIf

	oModel:Deactivate()

Return aRet
//-----------------------------------------------------
/*/ Integração de Contratos como Título a Pagar
@author Felipe Machado de Oliveira
@version P11
@since 30/05/2013
/*/
//------------------------------------------------------
Function GFEA100IPG(cInt,cSituacao,oModel, aRet, cNrCount)
	Local cMsg 	:= ""
	Local lIntGFE := SuperGetMv("MV_INTGFE",.F.,.F.)
	Local cIntGFE2:= SuperGetMv("MV_INTGFE2",.F.,"2")
	Local cERPGFE := SuperGetMV("MV_ERPGFE",,"2")

	Private _oGFEXFBFL := GFEXFBFLog():New()
	
	If lIntGFE == .T. .And. cIntGFE2 $ "1S" .And. cERPGFE == "2"
	
		_oGFEXFBFL:setSaveLog(__lLogIntP)
		_oGFEXFBFL:setAgrFrt(cNrCount)
		
		Do Case
			Case cSituacao == "2"
				If cInt == "1" // Financeiro
					If !AtuContrFin(oModel,@cMsg)
						aRet := {.F.,"2",cMsg}
					Else
						aRet := {.T.,"2",""}
					EndIf
				ElseIf cInt == "2" // Recebimento
					If !AtuContrRec(oModel,@cMsg)
						aRet := {.F.,"2",cMsg}
					Else
						aRet := {.T.,"2",""}
					EndIf
				EndIf

			Case cSituacao == "5"
				If cInt == "1" // Financeiro
					If !DesAtuFin(oModel,@cMsg)
						aRet := {.F.,"5",cMsg}
					Else
						aRet := {.T.,"5",""}
					EndIf
				ElseIf cInt == "2" //Recebimento
					If !DesAtuRec(oModel,@cMsg)
						aRet := {.F.,"5",cMsg}
					Else
						aRet := {.T.,"5",""}
					EndIf
				EndIf

			Otherwise
				Return

		EndCase
		
		_oGFEXFBFL:SaveLog()

	EndIf

Return
//-----------------------------------------------------
/*/	Atualização do documento de frete no Financeiro
@author Felipe Machado de Oliveira
@version P11
@since 30/05/2013
/*/
//------------------------------------------------------
Static Function AtuContrFin(oModel,cMsg)
Local lErro       := .F.
Local lParISS     := SuperGetMv("MV_GFEISS",.F.,"")
Local lParIRRF    := SuperGetMv("MV_GFEIRRF",.F.,"")
Local lParINSS    := SuperGetMv("MV_GFEINSS",.F.,"")
Local lGFEA098    := IsInCallStack("GFEA098")
Local aErro       := {}
Local aContrato   := {}
Local aRatCont    := {}
Local aRatAll     := {}
Local aForLoj     := GFEA055GFL(GW2->GW2_CDPROP)
Local oModelGW9   := oModel:GetModel("GFEA100_GW9")
Local cE2_NATUREZ := SuperGetMv("MV_NTFGFE",.F.,"")
Local nVlrISS     := GW2->GW2_VLISS
Local nVlrIRRF    := GW2->GW2_VLIRRF
Local nVlrINSS    := GW2->GW2_VLINSS
Local nVlrSEST    := GW2->GW2_VLSEST
Local nVlFrete    := (GW2->GW2_VLFRET + GW2->GW2_VLADIC - GW2->GW2_VLDESC)
Local nI          := 0
Local nX          := 0
Local nPercent	  := 0
Local nAcPercent  := 0

Default cMsg      := ""

Private lMsHelpAuto    := .T.
Private lAutoErrNoFile := .T.
Private lMsErroAuto    := .F.

	If Empty(aForLoj[1])
		cMsg := "Fornecedor não cadastrado no Protheus."
		lErro := .T.
	EndIf
	If !lErro
		aForLoj[2] := IIF( Empty(aForLoj[2]),"01",aForLoj[2] )

		If lParISS == "2"
			nVlrISS := 0
		EndIf

		If lParIRRF == "2"
			nVlrIRRF := 0
		EndIf

		If lParINSS == "2"
			nVlrINSS := 0
			nVlrSEST := 0
		EndIf
		//Dados do conhecimento
		aContrato :=  { {"E2_PREFIXO" , ""              , Nil },;
						{"E2_NUM"     , GW2->GW2_NRCONT , Nil },;
						{"E2_PARCELA" , "1"             , Nil },;
						{"E2_TIPO"    , "RPA"           , Nil },;
						{"E2_NATUREZ" , cE2_NATUREZ     , Nil },;
						{"E2_EMISSAO" , GW2->GW2_DTCRIA , Nil },;
						{"E2_VENCTO"  , GW2->GW2_DTVENC , Nil },;
						{"E2_VENCREA" , GW2->GW2_DTVENC , Nil },;
						{"E2_VALOR"   , nVlFrete        , Nil },;
						{"E2_VLCRUZ"  , nVlFrete        , Nil },;
						{"E2_FORNECE" , aForLoj[1]      , Nil },;
						{"E2_LOJA"    , aForLoj[2]      , Nil },;
						{"E2_ISS"     , nVlrISS         , Nil },;
						{"E2_INSS"    , nVlrINSS        , Nil },;
						{"E2_IRRF"    , nVlrIRRF        , Nil },;
						{"E2_SEST"    , nVlrSEST        , Nil },;
						{"E2_ORIGEM"  , "TOTVSGFE"      , Nil }}

		nX := oModelGW9:Length()
		For nI := 1 To nX
			If nI != 1
				oModelGW9:GoLine( nI )
			EndIf

			If Empty(FWFldGet("GW9_CTACTB"))
				Exit
			EndIf

			If nI == 1
				Aadd(aContrato, {"E2_RATEIO", "S", Nil} )
			EndIf

			If FWFldGet("GW9_LANCTO") != "1"
				loop
			Endif

			If nI == nX
				nPercent := 100 - nAcPercent
			Else
				nPercent := (100 * FWFldGet("GW9_VLMOV")) / nVlFrete
				nAcPercent += nPercent
			EndIf
			//Dados dos rateios
			aRatCont :=   { {"CTJ_DEBITO" , FWFldGet("GW9_CTACTB") , Nil },;
							{"CTJ_PERCEN" , nPercent , Nil },;
							{"CTJ_VALOR"  , FWFldGet("GW9_VLMOV")  , Nil },;
							{"CTJ_CCD"    , FWFldGet("GW9_CCUSTO") , Nil } }

			Aadd(aRatAll, aRatCont)

		Next nI

		_oGFEXFBFL:NovoLogInP("FINA050") //Log de integração com ERP Protheus
		AddToLog("LOG DE INTEGRAÇÃO FINA050 - Iniciado em " + DTOC(DATE()) + " às " + TIME() + CRLF + CRLF) //"LOG DE INTEGRAÇÃO FINA050 - Iniciado em "###", as "
		AddToLog('Atualização' + CRLF + CRLF)
		AddToLog('Contrato' + CRLF)
		nX := Len(aContrato)
		For nI := 1 To nX
			AddToLog(aContrato[nx,1] + " - " + cValToChar(aContrato[nx,2]) + CRLF)
		Next nI
		
		If !Empty(aRatAll)
			AddToLog(CRLF + 'Dados dos Rateios' + CRLF)
			nX := Len(aRatAll[1])
			For nI := 1 To nX
				AddToLog(aRatAll[1,nI,1] + " - " + cValToChar(aRatAll[1,nI,2]) + CRLF)
			Next nI
		EndIf
		
		//Execução da operação de inclusão no FINA050
		MsExecAuto({ |a,b,c| FINA050(a,,b,,,,,c)}, aContrato,3,aRatAll )
		If lMsErroAuto
			aErro := GetAutoGrLog()
			cMsg := ""
			nX := Len(aErro)
			For nI := 1 To nX
				cMsg += aErro[nI] + CRLF
			Next nI

			lErro := .T.
			
			AddToLog(CRLF + "Integração não realizada." + CRLF + CRLF)
			AddToLog(cMsg + CRLF) 
		Else
			AddToLog(CRLF + "Integração realizada com sucesso!" + CRLF)
		EndIf
		
		AddToLog("LOG DE INTEGRAÇÃO FINA050 - Finalizado em " + DTOC(DATE()) + " às " + TIME()) //"LOG DE INTEGRAÇÃO FINA050 - Finalizado em "###", as "
	EndIf

	If lErro
		If !lGFEA098
			If lAutom2
				GFEContLog:AddDetail("Contrato: " + GW2->GW2_NRCONT + " não enviado para atualização. Verificar motivo no campo 'Mot Rej Fin'.")
			Else
				MsgInfo("Contrato não enviada para atualização. Verificar motivo no campo 'Mot Rej Fin'.")
			EndIf
		EndIf
	Else
		If !lGFEA098
			If lAutom2
				GFEContLog:AddDetail("Contrato: " + GW2->GW2_NRCONT + " atualizado no Financeiro.")
			Else
				MsgInfo("Contrato atualizado no Financeiro.")
			EndIf
		EndIf
	EndIf
Return !lErro
//-----------------------------------------------------
/*/	Atualização do documento de frete no Recebimento
@author Felipe Machado de Oliveira
@version P11
@since 30/05/2013
/*/
//------------------------------------------------------
Static Function AtuContrRec(oModel,cMsg)
	Local aContrato := {}
	Local aNotasAll := {}
	Local aForLojGW2 := GFEA055GFL(GW2->GW2_CDPROP)
	Local lErro := .F.
	Local aErro := {}
	Local nX := 0

	Default cMsg := ""

	Private lMsHelpAuto := .T.
	Private lAutoErrNoFile := .T.
	Private lMsErroAuto := .F.

	If Empty(aForLojGW2[1])
		cMsg := "Fornecedor não cadastrado no Protheus."
		lErro := .T.
	EndIf
	
	If !lErro
		aForLojGW2[2] := IIF( Empty(aForLojGW2[2]),"01",aForLojGW2[2] )

		//Dados dos parâmetros e do cabeçalho do conhecimento
		ParamMt116( 2,@aContrato,aForLojGW2 )

		//Documento selecionados
		ItenAutono( @aNotasAll,aForLojGW2 )
		
		If !Empty(aNotasAll)
			
			_oGFEXFBFL:NovoLogInP("MATA116") //Log de integração com ERP Protheus
					                    
			AddToLog("LOG DE INTEGRAÇÃO MATA116 - Iniciado em " + DTOC(DATE()) + " às " + TIME() + CRLF + CRLF) //"LOG DE INTEGRAÇÃO MATA116 - Iniciado em "###", as "
			AddToLog('Atualização' + CRLF + CRLF)
			AddToLog('Contrato' + CRLF)
	
			For nX := 1 To Len(aContrato)
				AddToLog(aContrato[nx,1] + " - " + cValToChar(aContrato[nx,2]) + CRLF)						
			Next nX
			
			If !Empty(aNotasAll)
			
				AddToLog(CRLF + 'Documentos' + CRLF)
				 
				For nX := 1 To Len(aNotasAll[1])
					AddToLog(aNotasAll[1,nX,1] + " - " + cValToChar(aNotasAll[1,nX,2]) + CRLF)
			    next nX
			EndIf
			
			//Execução da operação de exclusão no MATA116
			MsExecAuto({ |a,b| MATA116(a,b)}, aContrato,aNotasAll )
			
			If lMsErroAuto
				aErro := GetAutoGrLog()
				cMsg := ""
	
				For nX := 1 To Len(aErro)
					cMsg += aErro[nX] + CRLF
				Next nX
	
				lErro := .T.
				
				AddToLog(CRLF + "Integração não realizada." + CRLF + CRLF)
				AddToLog(cMsg + CRLF)  
			Else
				AddToLog(CRLF + "Integração realizada com sucesso!" + CRLF)
			EndIf

			AddToLog("LOG DE INTEGRAÇÃO MATA116 - Finalizado em " + DTOC(DATE()) + " às " + TIME()) //"LOG DE INTEGRAÇÃO MATA116 - Finalizado em "###", as "
		Else
			lErro := .T.
			cMsg := "Notas Fiscais não selecionadas."
		EndIf
	EndIf

	If lErro
		If !IsInCallStack("GFEA098")
			If lAutom2
				GFEContLog:AddDetail("Contrato: " + GW2->GW2_NRCONT + " não enviado para atualização. Verificar motivo no campo 'Mot Rej Rec'.")
			Else
				MsgInfo("Contrato não enviada para atualização. Verificar motivo no campo 'Mot Rej Rec'.")
			EndIf
		EndIf
	Else
		If !IsInCallStack("GFEA098")
			If lAutom2
				GFEContLog:AddDetail("Contrato: " + GW2->GW2_NRCONT + " atualizado no Recebimento.")
			Else
				MsgInfo("Contrato atualizado no Recebimento.")
			EndIf
		EndIf
	EndIf

Return !lErro

//-----------------------------------------------------
/*/	Desatualização do documento de frete no Financeiro
@author Felipe Machado de Oliveira
@version P11
@since 30/05/2013
/*/
//------------------------------------------------------
Static Function DesAtuFin(oModel,cMsg)
	Local aContrato := {}
	Local aForLoj := GFEA055GFL(GW2->GW2_CDPROP)
	Local lErro := .F.
	Local aErro := {}
	Local nX := 0

	Default cMsg := ""

	Private lMsHelpAuto := .T.
	Private lAutoErrNoFile := .T.
	Private lMsErroAuto := .F.

	If Empty(aForLoj[1])
		cMsg := "Fornecedor não cadastrado no Protheus."
		lErro := .T.
	EndIf

	If !lErro
		aForLoj[2] := IIF( Empty(aForLoj[2]),"01",aForLoj[2] )

		//Dados do conhecimento
		aContrato := {	{"E2_PREFIXO" , Space( TamSX3("E2_PREFIXO")[1] )                                                                 , Nil },;
						{"E2_NUM"     , AllTrim(GW2->GW2_NRCONT)+Space( (TamSX3("E2_NUM")[1])-(Len( AllTrim(GW2->GW2_NRCONT) )) ), Nil },;
						{"E2_PARCELA" , AllTrim("1")+Space( (TamSX3("E2_PARCELA")[1])-(Len( AllTrim("1") )) )                       , Nil },;
						{"E2_TIPO"    , AllTrim("RPA")+Space( (TamSX3("E2_TIPO")[1])-(Len( AllTrim("RPA") )) )                      , Nil },;
						{"E2_FORNECE" , aForLoj[1]                                                                                          , Nil },;
						{"E2_LOJA"    , aForLoj[2]                                                                                          , Nil } }

		_oGFEXFBFL:NovoLogInP("FINA050") //Log de integração com ERP Protheus
					                    
		AddToLog("LOG DE INTEGRAÇÃO FINA050 - Iniciado em " + DTOC(DATE()) + " às " + TIME() + CRLF + CRLF) //"LOG DE INTEGRAÇÃO FINA050 - Iniciado em "###", as "
		AddToLog('Desatualização' + CRLF + CRLF)
		AddToLog('Contrato' + CRLF)

		For nX := 1 To Len(aContrato)
			AddToLog(aContrato[nx,1] + " - " + cValToChar(aContrato[nx,2]) + CRLF)						
		Next nX
		
		//Execução da operação de exclusão no FINA050
		MsExecAuto({ |a,b| FINA050(a,,b)}, aContrato,5 )

		If lMsErroAuto
			aErro := GetAutoGrLog()
			cMsg := ""
	
			For nX := 1 To Len(aErro)
				cMsg += aErro[nX] + CRLF
			Next nX
	
			lErro := .T.
			
			AddToLog(CRLF + "Integração não realizada." + CRLF + CRLF)
			AddToLog(cMsg + CRLF)  
		Else
			AddToLog(CRLF + "Integração realizada com sucesso!" + CRLF)
		EndIf

		AddToLog("LOG DE INTEGRAÇÃO FINA050 - Finalizado em " + DTOC(DATE()) + " às " + TIME()) //"LOG DE INTEGRAÇÃO FINA050 - Finalizado em "###", as "
	EndIf

	If lErro
		If !IsInCallStack("GFEA098")
			If lAutom2
				GFEContLog:AddDetail("Contrato: " + GW2->GW2_NRCONT + " não enviado para desatualização. Verificar motivo no campo 'Mot Rej Fin'.")
			Else
				MsgInfo("Contrato não enviada para desatualização. Verificar motivo no campo 'Mot Rej Fin'.")
			EndIf
		EndIf
	Else
		If !IsInCallStack("GFEA098")
			If lAutom2
				GFEContLog:AddDetail("Contrato: " + GW2->GW2_NRCONT + " desatualizado no Financeiro.")
			Else
				MsgInfo("Contrato desatualizado no Financeiro.")
			EndIf
		EndIf
	EndIf

Return !lErro

//-----------------------------------------------------
/*/	Desatualização do documento de frete no Recebimento
@author Felipe Machado de Oliveira
@version P11
@since 30/05/2013
/*/
//------------------------------------------------------
Static Function DesAtuRec(oModel,cMsg)
	Local aContrato := {}
	Local aForLojGW2 := GFEA055GFL(GW2->GW2_CDPROP)
	Local aNotasAll := {}
	Local lErro := .F.
	Local aErro := {}
	Local nX := 0

	Default cMsg := ""

	Private lMsHelpAuto := .T.
	Private lAutoErrNoFile := .T.
	Private lMsErroAuto := .F.

	If Empty(aForLojGW2[1])
		cMsg := "Fornecedor não cadastrado no Protheus."
		lErro := .T.
	EndIf

	If !lErro
		aForLojGW2[2] := IIF( Empty(aForLojGW2[2]),"01",aForLojGW2[2] )

		//Dados dos parâmetros e do cabeçalho do conhecimento
		ParamMt116( 1,@aContrato,aForLojGW2 )

		//Documento selecionados
		ItenAutono( @aNotasAll,aForLojGW2 )

		If !Empty(aNotasAll)

			_oGFEXFBFL:NovoLogInP("MATA116") //Log de integração com ERP Protheus
					                    
			AddToLog("LOG DE INTEGRAÇÃO MATA116 - Iniciado em " + DTOC(DATE()) + " às " + TIME() + CRLF + CRLF) //"LOG DE INTEGRAÇÃO MATA116 - Iniciado em "###", as "
			AddToLog('Desatualização' + CRLF + CRLF)
			AddToLog('Contrato' + CRLF)
	
			For nX := 1 To Len(aContrato)
				AddToLog(aContrato[nx,1] + " - " + cValToChar(aContrato[nx,2]) + CRLF)						
			Next nX
			
			If !Empty(aNotasAll)
			
				AddToLog(CRLF + 'Documentos' + CRLF)
				 
				For nX := 1 To Len(aNotasAll[1])
					AddToLog(aNotasAll[1,nX,1] + " - " + cValToChar(aNotasAll[1,nX,2]) + CRLF)
			    next nX
			EndIf
			
			//Execução da operação de inclusão no MATA116
			MsExecAuto({ |a,b| MATA116(a,b)}, aContrato,aNotasAll )

			If lMsErroAuto
				aErro := GetAutoGrLog()
				cMsg := ""
	
				For nX := 1 To Len(aErro)
					cMsg += aErro[nX] + CRLF
				Next nX
	
				lErro := .T.
				
				AddToLog(CRLF + "Integração não realizada." + CRLF + CRLF)
				AddToLog(cMsg + CRLF)  
			Else
				AddToLog(CRLF + "Integração realizada com sucesso!" + CRLF)
			EndIf

			AddToLog("LOG DE INTEGRAÇÃO MATA116 - Finalizado em " + DTOC(DATE()) + " às " + TIME()) //"LOG DE INTEGRAÇÃO MATA116 - Finalizado em "###", as "
		Else
			lErro := .T.
			cMsg := "Notas Fiscais não selecionadas."
		EndIf


	EndIf

	If lErro
		If !IsInCallStack("GFEA098")
			If lAutom2
				GFEContLog:AddDetail("Contrato: " + GW2->GW2_NRCONT + " não enviado para desatualização. Verificar motivo no campo 'Mot Rej Rec'.")
			Else
				MsgInfo("Contrato não enviada para desatualização. Verificar motivo no campo 'Mot Rej Rec'.")
			EndIf
		EndIf
	Else
		If !IsInCallStack("GFEA098")
			If lAutom2
				GFEContLog:AddDetail("Contrato: " + GW2->GW2_NRCONT + " desatualizado no Recebimento.")
			Else
				MsgInfo("Contrato desatualizado no Recebimento.")
			EndIf
		EndIf
	EndIf

Return !lErro
//-----------------------------------------------------
/*/Seleciona os documentos vinculados ao contrato do autonomo
@author Felipe Machado de Oliveira
@version P11
@since 30/05/2013
/*/
//------------------------------------------------------
Static Function ItenAutono(aNotasAll,aForLojGW2)
	Local aAreaGWF := GWF->( GetArea() )
	Local aAreaGWH := GWH->( GetArea() )
	Local aAreaGW1 := GW1->( GetArea() )
	Local aAreaSF1 := SF1->( GetArea() )
	Local aForLojGW1 := {}
	Local cNrDc := ""
	Local cSerDc := ""

	dbSelectArea("GWF")
	GWF->( dbSetOrder(2) )
	GWF->( dbSeek( xFilial("GWF")+GW2->GW2_NRCONT ) )
	While !GWF->( Eof() ) .And. GWF->GWF_FILIAL == xFilial("GWF");
							.And. AllTrim(GWF->GWF_NRCONT) == AllTrim(GW2->GW2_NRCONT)

		dbSelectArea("GWH")
		GWH->( dbSetOrder(1) )
		GWH->( dbSeek( xFilial("GWH")+GWF->GWF_NRCALC ) )
		While !GWH->( Eof() ) .And. GWH->GWH_FILIAL == xFilial("GWH");
								.And. AllTrim(GWH->GWH_NRCALC) == AllTrim(GWF->GWF_NRCALC)

			dbSelectArea("GW1")
			GW1->( dbSetOrder(1) )
			GW1->( dbSeek(xFilial("GW1")+GWH->GWH_CDTPDC+GWH->GWH_EMISDC+GWH->GWH_SERDC+GWH->GWH_NRDC ) )
			If !GW1->( Eof() ) .And. GW1->GW1_FILIAL == xFilial("GW1");
								 .And. AllTrim(GW1->GW1_CDTPDC) == AllTrim(GWH->GWH_CDTPDC);
								 .And. AllTrim(GW1->GW1_EMISDC) == AllTrim(GWH->GWH_EMISDC);
								 .And. AllTrim(GW1->GW1_SERDC) == AllTrim(GWH->GWH_SERDC);
								 .And. AllTrim(GW1->GW1_NRDC) == AllTrim(GWH->GWH_NRDC)

				aForLojGW1 := GFEA055GFL( GW1->GW1_EMISDC )
				aForLojGW1[2] := IIF( Empty(aForLojGW1[2]),"01",aForLojGW1[2] )

				cNrDc := AllTrim(GW1->GW1_NRDC)+Space( (TamSX3("F1_DOC")[1])-(Len( AllTrim(GW1->GW1_NRDC) )) )
				cSerDc := AllTrim(GW1->GW1_SERDC)+Space( (TamSX3("F1_SERIE")[1])-(Len( AllTrim(GW1->GW1_SERDC) )) )

				dbSelectArea("SF1")
				SF1->( dbSetOrder(1) )
				SF1->( dbSeek( xFilial("SF1")+cNrDc+cSerDc+aForLojGW1[1]+aForLojGW1[2] ) )
				If !SF1->( EOF() ) .And. SF1->F1_FILIAL == xFilial("SF1") ;
									 .And. AllTrim(SF1->F1_DOC) == AllTrim(cNrDc) ;
									 .And. AllTrim(SF1->F1_SERIE) == AllTrim(cSerDc) ;
									 .And. AllTrim(SF1->F1_FORNECE) == AllTrim(aForLojGW1[1]) ;
									 .And. Alltrim(SF1->F1_LOJA) == AllTrim(aForLojGW1[2])

					aAdd(aNotasAll,{ {"PRIMARYKEY",cNrDc+cSerDc+aForLojGW1[1]+aForLojGW1[2],Nil} })
				EndIf

			EndIf

			GWH->( dbSkip() )

		EndDo

		GWF->( dbSkip() )

	EndDo
	
	RestArea(aAreaSF1)
	RestArea(aAreaGW1)
	RestArea(aAreaGWH)
	RestArea(aAreaGWF)

Return
//-----------------------------------------------------
/*/ Cria Vetor do Cabecalho da NF para o MATA116 (Conhecimento de Frete)
@author Felipe Machado de Oliveira
@param 2 - Inclusão
		1 - Exclusão
@version P11
@since 25/06/2013
/*/
//------------------------------------------------------
Static Function ParamMt116( nOpc,aContrato,aForLojGW2 )
	Local cTes := Posicione("SFM",1,xFilial("SFM")+"TT","FM_TE")

	aAdd(aContrato,{"MV_PAR11"  ,dDataBase-99999 ,nil}) // Data inicial para filtro das notas //
	aAdd(aContrato,{"MV_PAR12"  ,dDataBase       ,nil}) // Data final para filtro das notas //dDataBase
	aAdd(aContrato,{"MV_PAR13"  ,nOpc            ,nil}) // 2-Inclusao ; 1=Exclusao
	aAdd(aContrato,{"MV_PAR14"  ,Space( TamSx3("F1_FORNECE")[1] ) ,nil}) // Rementente das notas contidas no conhecimento
	aAdd(aContrato,{"MV_PAR15"  ,Space( TamSx3("F1_LOJA")[1] )    ,nil}) // Loja do remetente das notas contidas no conhecimento
	aAdd(aContrato,{"MV_PAR16"  ,1               ,nil}) // Tipo das notas contidas no conhecimento: 1=Normal ; 2=Devol/Benef
	aAdd(aContrato,{"MV_PAR17"  ,2               ,nil}) // 1=Aglutina itens ; 2=Nao aglutina itens
	aAdd(aContrato,{"MV_PAR18"  ,Space( TamSx3("F1_EST")[1] )     ,nil}) // UF das notas contidas no conhecimento
	aAdd(aContrato,{"MV_PAR21"  ,GW2->GW2_VLFRET ,nil}) // Valor do conhecimento
	aAdd(aContrato,{"MV_PAR22"  ,1               ,nil}) // Formulario Proprio 2=Sim 1=Nao
	aAdd(aContrato,{"MV_PAR23"  ,GW2->GW2_NRCONT ,nil}) // Numero da nota de conhecimento
	aAdd(aContrato,{"MV_PAR24"  ,Space( TamSx3("F1_SERIE")[1])    ,nil}) // Serie da nota de conhecimento
	aAdd(aContrato,{"MV_PAR25"  ,aForLojGW2[1]   ,nil}) // Fornecedor da nota de conhecimento
	aAdd(aContrato,{"MV_PAR26"  ,aForLojGW2[2]   ,nil}) // Loja do fornecedor da nota de conhecimento
	aAdd(aContrato,{"MV_PAR27"  ,cTes            ,nil}) // TES a ser utilizada nos itens do conhecimento
	aAdd(aContrato,{"MV_PAR28"  ,0               ,nil}) // Valor da base de calculo do ICMS retido
	aAdd(aContrato,{"MV_PAR29"  ,0               ,nil}) // Valor do ICMS retido
	aAdd(aContrato,{"MV_PAR31"  ,SuperGetMv("MV_CPDGFE",.F.,"") ,nil}) // Condicao de pagamento
	aAdd(aContrato,{"Emissao"   ,GW2->GW2_DTCRIA ,nil}) // Data de emissao do conhecimento
	aAdd(aContrato,{"F1_ESPECIE","CTR"           ,nil}) // Especie do documento
	
Return
Static Function GFEA100AL(cMsg, cVal )
	if nGFEEDIL <> "1"
		GFELog100:Add(PADL(cMsg,50)+cVal)
	EndIf
Return
/* . */

/*/{Protheus.doc} AddToLog
Registra o texto de log recebido na variável de log
Caso a variável exceda o limite estabelecido, o conteúdo é gravado em arquivo
@author silvana.torres
@since 15/04/2019
@version 1.0
@return ${return}, ${return_description}
@param cTexto, characters, descricao
@param nPosicao, numeric, descricao
@param lTime, logical, descricao
@type function
/*/
Static Function AddToLog(cTexto, nPosicao, lTime)
	Default lTime	:= .T.
	Default nPosicao := _LOG_END

	If !__lLogIntP
		Return
	EndIf
	
	_oGFEXFBFL:setPosicao(nPosicao)
	_oGFEXFBFL:setTime(lTime)
	_oGFEXFBFL:setSaveLog(__lLogIntP)
	_oGFEXFBFL:setTexto(cTexto)
Return NIL


/*/{Protheus.doc} AddToLog
SITRH:  Quando o ERP não for Datasul, o campo deve ficar como 6-Não se Aplica; 
Quando for Datasul deve validar o parâmetro que indica se Integra com o 
RH  MV_GFEI19 se não integrar deve ficar 6 tbem, todos outros casos como 1-Não Enviado.  
GW2_SITRH -  1=Nao Enviado;2=Pendente;3=Rejeitado;4=Atualizado;5=Pendente Desatualização ;6=Não se Aplica 
@author timegfe
@since 07/11/2019
@version 1.0

/*/
Function IntSITRH()
	Local s_GFEI19  := SuperGetMV('MV_GFEI19',,'1') // 	"1=sob Demanda","2=Automática","3=Não integrar"  
	Local s_CADERP	:= SuperGetMV("MV_CADERP",,"1")	// 	"1=ERP", "2=GFE"
	Local s_ERPGFE	:= SuperGetMV("MV_ERPGFE",,"2")	// 	"1=Datasul","2=Protheus","3=RM","4=Logix","5=Outro"
	Local cSITRH	:= "" 							//	"1=Nao Enviado", "6=Não se Aplica"

	If (s_CADERP == "1" .and. s_ERPGFE != "1") .or. (s_CADERP == "2")
		cSITRH	:= "6"		
	ElseIf (s_CADERP == "1" .and. s_ERPGFE == "1")
		If s_GFEI19 == "3"
			cSITRH	:= "6"	
		Else 
			cSITRH	:= "1"	
		EndIf
	EndIf

Return cSITRH

/*/{Protheus.doc} AddToLog
SITFIN:  seguir o que está no no parâmetro MV_GFEI16 (1ou2 fica como 1-Não Enviado, 3 fica como 6-Não se Aplica);
GW2_SITFIN - 1=Nao Enviado;2=Pendente;3=Rejeitado;4=Atualizado;5=Pendente Cancelamento; 6-Não se Aplica   
@author timegfe
@since 07/11/2019
@version 1.0

/*/
Function IntSITFIN()
	Local sGFEI16  	:= SuperGetMV('MV_GFEI16',,'1') // 	"1=sob Demanda","2=Automática","3=Não integrar"  
	Local cSITFIN	:= "" 							//	"1=Nao Enviado", "6=Não se Aplica"

	If sGFEI16 == "3"
		cSITFIN	:= "6"	
	Else 
		cSITFIN	:= "1"	
	EndIf

Return cSITFIN

/*/{Protheus.doc} AddToLog
SITREC:  o mesmo deve ser gravado apos relacionar o calculo pois precisa das notas (pode ser na confirmação das notas); 
Verificar o tipo de documento de carga da nota relacionada aos cálculos;
Notas de Saída sempre ficarão como 6-Não se Aplica;
Para notas de entrada, se o tipo de Contabilização estiver como 2- Custo então o SITREC fica 1-Não Enviado. 
Se o tipo de contabilização for 1-Despesa OU (o tipo for 4-Uso Doc Carga E o uso da nota gw1_uso for 2-UsoConsumo ou 3-Ativo) 
então o SITREC fica como 6-Não se Aplica;
GW2_SITREC - 1=Nao Enviado;2=Pendente;3=Rejeitado;4=Atualizado;5=Pendente Desatualização;6=Não se Aplica

@author timegfe
@since 07/11/2019
@version 1.0

/*/
Function IntSITREC(cSentido,cTpCont,cUso)
	Local cSITREC	:= "" 			

	If cSentido == "2"
		cSITREC := "6"
	Elseif cSentido == "1"
		If cTpCont == "2"
			cSITREC := "1"
		Elseif cTpCont == "1" .or. (cTpCont == "4" .and. cUso $ "23" )
			cSITREC := "6"
		EndIf
	EndIf

Return cSITREC

Static Function ListContratos()
	Local cWhere	:= ""
	Local cMVAPUR	:= SuperGetMV("MV_APUIRF", .F., "2")
	Local cAliasGW2 := GetNextAlias()

	cWhere := "AND GW2.GW2_SITCON <> '4' "
	If cMVAPUR == "2"
		cWhere += "AND GW2.GW2_FILIAL = '" + xFilial("GW2") + "' " 
	EndIf
	cWhere := "%" + cWhere + "%"

	BeginSQL Alias cAliasGW2
		SELECT GW2_VLINSS, GW2_VLINOE, GW2_DTCRIA, GW2.R_E_C_N_O_ RECNOGW2
		FROM %Table:GW2% GW2
		WHERE GW2.GW2_CDPROP = %Exp:cCodProp%
		AND GW2.%NotDel%
		%Exp:cWhere%
	EndSQL
	While !((cAliasGW2)->(Eof()))
		If (cAliasGW2)->GW2_DTCRIA >= alltrim(dDataDeCont) .And.;
		   (cAliasGW2)->GW2_DTCRIA <= alltrim(dDataAteCont) .And.;
		   (cAliasGW2)->RECNOGW2 <> GW2->(RECNO())
		
		    nInssPer    := nInssPer + (cAliasGW2)->GW2_VLINSS /*nInssPer recebe ela mesma mais o valor do inss retido para aquele proprietario*/
			nInssOtEmp  := (cAliasGW2)->GW2_VLINOE
			If nInssOtEmp > nInssOutEmp
				nInssOutEmp := (cAliasGW2)->GW2_VLINOE
			EndIf
		EndIf
		
		(cAliasGW2)->(dbSkip())
	EndDo

	(cAliasGW2)->(dbCloseArea())
Return
