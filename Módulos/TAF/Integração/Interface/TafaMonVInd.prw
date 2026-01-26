#Include "PROTHEUS.CH"
#INCLUDE "TAFTCKDEF.CH"  
#INCLUDE "TAFCSS.CH"
#INCLUDE "TOPCONN.CH"
#INCLUDE "TAFTICKET.CH"

/*/{Protheus.doc} TafMonVInd
Cria Visão Indivualizada do Monitor
Esta visão utiliza as classes do fonte TAFCLASSMONTICKET.PRW
toda a lógica da visão esta no mesmo.

@type function
@author Evandro dos Santos O. Teixeira
@since 25/07/2016
@version 1.0
@param oParent		- Objeto Pai
@param aParamT		- Parâmetros de Filtro
@param lBackPar		- Indica se a tela de parâmetros foi chamada pelo monitor
@param oDlgMon		- Dialog do Container (xMonContainer)
@param oPanelLeft		- Painel para Criação do Browse posicionado ao topo-esquerda
@param oPanelRight	- Painel para Criação do Browse posicionado ao topo-direita
@param oPanelDown		- Painel para Criação do Browse posicionado na parte inferior da tela
@return Nil 
/*/
Function TafMonVInd(oParent,aParamT,lBackPar,oDlgMon,oPanelLeft,oPanelRight,oPanelDown,cCodFil)

	Local aCoors   as array
	Local oFWLayer as object
	
	aCoors := FWGetDialogSize( oMainWnd )
	
	oPanelL  := TPanel():New(00,00,"",oParent,,.F.,.F.,,,00,00,.F.,.F.)
	oPanelL:Align := CONTROL_ALIGN_ALLCLIENT
	If Val(GetVersao(.F.)) > 10 .And. Val(GetVersao(.F.)) < 12  
		oPanelL:setCSS(QLABEL_AZUL_A_FONTE)
	EndIf
	
	oFWLayer := FWLayer():New()
	oFWLayer:Init( oPanelL, .F., .T. )
	
	oFWLayer:AddLine("LINHA_REGISTROS", 050, .F. )
	oFWLayer:AddCollumn("COLUNA_LAYOUT_STATUS",050,.T.,"LINHA_REGISTROS")
	oFWLayer:AddCollumn("COLUNA_TAFKEY",050,.T.,"LINHA_REGISTROS")
	
	oFWLayer:AddLine("LINHA_HISTORICO",050,.F.)
	oFWLayer:AddCollumn("COLUNA_HISTORICO"	,100,.T.,"LINHA_HISTORICO")
	
	oPanelLeft 	:= 	oFWLayer:GetColPanel( "COLUNA_LAYOUT_STATUS" 	, "LINHA_REGISTROS" ) 
	oPanelRight := 	oFWLayer:GetColPanel( "COLUNA_TAFKEY"			, "LINHA_REGISTROS" )
	oPanelDown	:= 	oFWLayer:GetColPanel( "COLUNA_HISTORICO"		, "LINHA_HISTORICO" ) 
	
	If paramVisaoTicket == 1
		oBrowseLay:= TafTBrwLayout():New(,,{paramDataInicio,paramDataFinal,paramVisaoTicket,cCodFil},"oBrowseLay",aParamT)
		oBrowseLay:SetOwner( oPanelLeft )
		oBrowseLay:Activate()
	Else 
		oBrowseLay:= TafTBrwStatus():New(,,{paramDataInicio,paramDataFinal,paramVisaoTicket,cCodFil},"oBrowseLay",aParamT)
		oBrowseLay:SetOwner( oPanelLeft )
		oBrowseLay:Activate()
	EndIf
		
	oBrowseKey:= TafTBrwTafKey():New(,,{paramDataInicio,paramDataFinal,paramVisaoTicket,cCodFil},"oBrowseKey",aParamT)
	oBrowseHis:= TafTBrwHist():New(,.T.,{cCodFil,paramDataInicio,paramDataFinal},"oBrowseHis",aParamT)
	
	oBrowseKey:SetOwner(oPanelRight) 
	oBrowseKey:AddButton(STR0125,{||FWMsgRun(oPanelRight,{||oBrowseKey:CreateQry(),oBrowseKey:RefazDadosTrb()},"",STR0153)}) //"Remover Filtro Avançado"#"Limpando Filtro"
	oBrowseKey:AddButton(STR0124,{||FiltroAvanc(@oPanelRight)})	//"Filtro Avançado"
	oBrowseKey:AddButton(STR0021,{||oBrowseHis:RefazDadosTrb( .F. , .T. ), oBrowseKey:visualizarRegistro(oBrowseHis)}) //"Visualizar"
	oBrowseKey:AddButton(STR0174,{||oBrowseKey:alterarRegistro(oBrowseHis)}) //"Alterar"
	oBrowseKey:AddButton(STR0175,{||oBrowseKey:excluirRegistro(oBrowseHis,oBrowseLay)}) //"Excluir"
	oBrowseKey:Activate()
	
	oBrowseHis:SetOwner( oPanelDown )
	oBrowseHis:AddButton(STR0126,{||FWMsgRun(,{||IIf(oBrowseHis:apagaHistorico(),oBrowseHis:Refresh(),MsgStop(STR0127 + oBrowseHis:cErro)) },STR0128,STR0129)}) //"Limpar Histórico"#"Não foi possível apagar os registros. "#"Histórico"#"Excluindo Histórico ..."
	oBrowseHis:AddButton( STR0185 , { || FWMsgRun( , { ||oBrowseHis:RefazDadosTrb( .F. , .T. ) } , STR0185 , STR0186 ) } ) //"Atualizar" ## "Atualizando..."
	oBrowseHis:Activate()
	
	If paramVisaoTicket == 1
		oRelacLay := FWBrwRelation():New()
		oRelacLay:AddRelation( oBrowseLay:oBrowse , oBrowseKey:oBrowse , {{'LAYOUT','LAYOUT'}},(oBrowseKey:cAliasTrb)->(IndexKey(2)))
		oRelacLay:Activate() 
	Else
		oRelacLay := FWBrwRelation():New()
		oRelacLay:AddRelation( oBrowseLay:oBrowse , oBrowseKey:oBrowse , {{'TAFSTATUS', 'TAFSTATUS'}},(oBrowseKey:cAliasTrb)->(IndexKey(2)))
		oRelacLay:Activate()
	EndIf
	
	oRelacTck := FWBrwRelation():New()
	oRelacTck:AddRelation( oBrowseKey:oBrowse , oBrowseHis:oBrowse , {{'LAYOUT', 'LAYOUT'},{'TAFKEY','TAFKEY'}},(oBrowseKey:cAliasTrb)->(IndexKey(3)))
	oRelacTck:Activate() 
	
Return Nil 

/*/{Protheus.doc} FiltroAvanc
Interface para a Filtro Avançado
@type function
@author Evandro dos Santos O. Teixeira
@since 25/07/2016
@version 1.0
@param oPanelRight - Painel para execução da função FWMsgRun
@return Nil 
/*/
Static Function FiltroAvanc(oPanelRight)

	Local oFont1    as object   
	Local oDialog   as object
	Local cPesquisa as char
	
	cPesquisa  := Space(100)
	
	oFont1 := TFont():New(,,14,,.F.) 
	
	oDialog := MSDialog():New(0, 0, 150, 400, OemToAnsi(STR0124),,,,,,CLR_WHITE,,,.T.,,,) //"Filtro Avançado"      
	
	TSay():New(007,004,{||STR0130},,,oFont1,,,,.T.) //"Realiza uma busca dentro da mensagem (campo TAFMSG)"
	
	TGroup():New(020,004,043,197,STR0131,oDialog,,,.T.) //"Pesquisa "
	oGet := TGet():New(027,008,{|u|If( PCount()==0,cPesquisa,cPesquisa := u )},oDialog,180,010,,,,,,,,.T.)
	oGet:cPlaceHold := STR0132 //"Digite uma palavra para busca"                                      
	
	SButton():New(060, 140, 1, {||FWMsgRun(oPanelRight,{||oBrowseKey:CreateQry(cPesquisa),oBrowseKey:FiltroAvancado(),oDialog:End() },"",STR0133)} ) //"Realizando Filtro" - Botão Ok                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                
	SButton():New(060, 170, 2, {||oDialog:End()})  //Botão Cancela
	
	Activate Dialog oDialog Centered

Return Nil