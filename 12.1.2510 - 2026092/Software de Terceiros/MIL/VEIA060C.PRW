#INCLUDE "TOTVS.CH"
#INCLUDE "FWMVCDEF.CH"

#INCLUDE "VEIA060C.CH"

/*/{Protheus.doc} VEIA060
Alteração de Pedido de Veículo Parcialmente Faturado
Optamos por criar outro fonte para não carregar nenhum imposto

@author Luiz Pereira
@since 24/06/2026
@version 1.0
@return ${return}, ${return_description}

@type function
/*/

Function VEIA060C()

	lRetorno := VA060C001G_AlteraPedido()

Return


Function VA060C001G_AlteraPedido()

	Local oModel  := FWLoadModel("VEIA060C")
	Local oView   := FWLoadView("VEIA060C")
	Local oExecView

	oExecView := FWViewExec():New()
	oExecView:setModel(oModel)
	oExecView:setView(oView)
	oExecView:SetCloseOnOk( {||.T.} ) //Não mostrar o botão "Salvar e Criar novo"
	oExecView:setOperation(MODEL_OPERATION_UPDATE)
	oExecView:openView(.T.)
	

Return


/*/{Protheus.doc} ModelDef
Modelo de Dados
@author Luiz Pereira
@since 01/07/2026
@version 1.0

@type function
/*/
Static Function ModelDef()

	Local oStruVRJ := FWFormStruct( 1, 'VRJ' )
	Local oStruVRK := FWFormStruct( 1, 'VRK' )
	Local oModel
	
    oModel := MPFormModel():New('VEIA060C',,, )
    oModel:AddFields('MODEL_VRJ', /*cOwner*/, oStruVRJ       , /* <bPre > */ , /* <bPost > */ , )
	oModel:AddGrid(  'MODEL_VRK', 'MODEL_VRJ',oStruVRK, /* <bLinePre > */ , /* <bLinePost > */ , /* <bPre > */ , /* <bLinePost > */,  )
		
	oModel:SetDescription(STR0001) // "Alteração de Pedido Parcial"
	oModel:GetModel( 'MODEL_VRJ' ):SetDescription(STR0002) // 'Dados de Pedido de Venda de Montadora'
	oModel:GetModel( 'MODEL_VRK' ):SetDescription(STR0003) // 'Dados de Itens do Pedido de Venda de Montadora'
	
	oModel:SetRelation('MODEL_VRK', { { 'VRK_FILIAL' , 'xFilial("VRK")' } , { 'VRK_PEDIDO' , 'VRJ_PEDIDO' } } , 'VRK_FILIAL+VRK_PEDIDO' )
	
	oModel:SetPrimaryKey( { "VRJ_FILIAL", "VRJ_PEDIDO" } )

	oStruVRK:AddField(;
		STR0004,; // cTitulo - 'Legenda'
		'',; // cTooltip
		'LEGENDA',; // cIdField
		'C',; // cTipo
		30,; // nTamanho
		0,; // nDecimal
		,; // bValid
		,; // bWhen
		{},; // aValues
		.F.,; // lObrigat
		FWBuildFeature( STRUCT_FEATURE_INIPAD, "VA0600373_LegendaItemPedido()"),; // bInit
		.F.,; // lKey
		.F.,; // lNoUpd
		.T.,; // lVirtual
		) // cValid


    oModel:InstallEvent("PADRAO",, VEIA060CEVDEF():New())

Return oModel


Static Function ViewDef()

	Local oModel   := FWLoadModel('VEIA060C')
	Local oStruVRJ := FWFormStruct( 2, 'VRJ' )
	Local oStruVRK := FWFormStruct( 2, 'VRK' )
	Local oView    := Nil

    Local cCpo_J_Nao := ""
    Local cCpo_K_Nao := ""

    cCpo_J_Nao := "VRJ_TIPVEN/VRJ_FORPAG/VRJ_CODCLI/VRJ_LOJA/VRJ_TIPOCL/VRJ_INDPRE/VRJ_CLIENT/VRJ_LOJENT/VRJ_CODTRA/VRJ_TPFRET/VRJ_PESOL/VRJ_PBRUTO/"
    cCpo_J_Nao += "VRJ_DESACE/VRJ_VOLUME/VRJ_ESPECI/VRJ_CLIRET/VRJ_LOJRET/VRJ_CLIALI/VRJ_LOJALI/VRJ_CLIREM/VRJ_LOJREM"

    VA060C002G_NaoPodeAlterar(oStruVRJ, cCpo_J_Nao)

    cCpo_K_Nao := "VRK_CODMAR/VRK_GRUMOD/VRK_MODVEI/VRK_SEGMOD/VRK_CORINT/VRK_COREXT/VRK_OPCION/VRK_FABMOD/VRK_CHASSI/VRK_CHAINT/VRK_CODTES/VRK_VALPRE/"
    cCpo_K_Nao += "VRK_VALMOV/VRK_VALDES/VRK_COMIS/VRK_PERDED/VRK_DEDCOM/VRK_VALSUG/VRK_COMISV/VRK_OPER"

    VA060C002G_NaoPodeAlterar(oStruVRK, cCpo_K_Nao)

    oStruVRK:AddField( 'LEGENDA','01',' ',STR0004,, 'Get' ,'@BMP',,,.F.,,,,,,.T.,, ) // "Legenda"

    oStruVRJ:RemoveField('VRJ_LOGVX0')
	oStruVRJ:RemoveField('VRJ_CODVRL')
	oStruVRJ:RemoveField('VRJ_TOTENT')
	oStruVRJ:RemoveField('VRJ_VALNEG')

	oView := FWFormView():New()
	oView:SetModel( oModel )
	oView:AddField('VIEW_VRJ', oStruVRJ, 'MODEL_VRJ' )
	oView:AddGrid( 'VIEW_VRK', oStruVRK, 'MODEL_VRK' )
	
	oView:CreateFolder( 'TELA_FOLDER_PRINCIPAL')
	oView:AddSheet('TELA_FOLDER_PRINCIPAL' , 'ABA_PRINCIPAL' , STR0005) // 'Pedido'
	oView:AddSheet('TELA_FOLDER_PRINCIPAL' , 'ABA_VEICULOS'  , STR0006) // 'Veículos'
	
	oView:CreateHorizontalBox( 'TELA_VRJ'    , 100 , , , 'TELA_FOLDER_PRINCIPAL', 'ABA_PRINCIPAL')
	
	oView:CreateHorizontalBox( 'TELA_VRK' , 100, , , 'TELA_FOLDER_PRINCIPAL', 'ABA_VEICULOS')
	
	oView:SetOwnerView( 'VIEW_VRJ', 'TELA_VRJ' )
	oView:SetOwnerView( 'VIEW_VRK', 'TELA_VRK' )

    oView:SetNoInsertLine('VIEW_VRK')
	oView:SetNoDeleteLine('VIEW_VRK')
    	
	oView:EnableTitleView('VIEW_VRK', STR0007) // 'Modelos/Veículos do pedido'

Return oView


/*/{Protheus.doc} VA060C002G_NaoPodeAlterar
Define quais campos não podem ser alterados no pedido
@author Luiz Pereira
@since 14/07/2026
@version 1.0

@type function
/*/
Static Function VA060C002G_NaoPodeAlterar(oStru, cCpoNao)
    
    Local nFor := 0
    Local aCpoNao := StrTokArr(cCpoNao, "/")

    For nFor := 1 To Len(aCpoNao)
        oStru:SetProperty( aCpoNao[nFor], MVC_VIEW_CANCHANGE , .F. )
    Next

Return()