#INCLUDE 'Protheus.ch'
#INCLUDE "TBICONN.CH"
#INCLUDE "POSCSS.CH" 
#INCLUDE "STPOS.CH" 
#INCLUDE "FILEIO.CH"
#INCLUDE "STFMOBWIZARD.CH"


Static oStepWiz 		:= Nil	//Objto tipo Wizard
Static oNewPag		:= Nil	//Objeto que adiciona nova pagina no wizard
Static oDlg 			:= Nil //Dialog bkg
Static oPanelBkg		:= Nil	//Panel de BackGround
Static oListImp 		:= Nil //List para impressoras
Static oListTef 		:= Nil //List TEFs
Static lImpWifi 		:= .T. //Indica se e impressora Wifi
Static lImpBlu 		:= .F. //Indica se e impressora Wifi
Static lTefAtivo 		:= .F. //Indica se TEF esta ativo
Static lFimWizard 	:= .F.	//Controla se pode finalizar do Wizard

Static aSLG   		:= {}	//Array que guarda os dados do cadastro de estacao
Static aMDG   		:= {}	//Array que guarda os dados do cadastro de estacao TEF

Static cLG_CODIGO		:= ""	//Codigo da estacao
Static cLG_PDV		:= ""	//Numero do PDV
Static cLG_SERIE 		:= ""	//Serie para estacao atual
Static cMV_CODREG    := "" 	//Regime tributario para NFC-E 
Static cMV_NFCEIDT   := "" 	//Token do sefaz 
Static cMV_LJEMPCK   := "" 	//Codigo da empresa cadastrado no daruma Migrate
Static cMV_LJFILIN   := "" 	//Codigo da Filial do Servidor
Static cLG_WSSRV 		:= ""	//endereço ws do servidor

Static cLG_IMPFISC 	:= ""	//Modelo da Impressora 
Static cLG_TSCPORT 	:= ""	//porta para impressora de Rede | Wifi . Se Bluetooth sera gravado o timeout
Static cLG_TSCSRV		:= ""	//Porta IP da impressora | Se Bluetooth nome do equipamento Case-Sensitive
Static cLG_PORTIF		:= ""	//Porta da impressora | Se Bluetooth sera gravado 'BLU'


Static cMDG_TEFATV	:= ""	//Ativa o TEF
Static cMDG_CARPAY	:= ""	//Usa TEF PAYGO

Static cImpAnterior   := ""  //Armazena impressora anterior configurada para controle de mudanca

Static oImg         	:= Nil	//Obejeto de imagem

//-------------------------------------------------------------------	
/*/{Protheus.doc} STFMobWizard
Cria wizard de Configurações para mobile

@param 
@author  Varejo
@version P11.8
@since   27/05/2015
@return  .T.
@obs     
@sample
/*/
//-------------------------------------------------------------------	
Function STFMobWizard()

//Instancia a classe FWWizard
oStepWiz:= FWWizardControl():New(,)// Define o tamanho do wizard  ex: {600,800}
oStepWiz:ActiveUISteps()


// 01 ------------------------------ "Primeiros passos"
oNewPag := oStepWiz:AddStep("1")//Adiciona a primeira tela do wizard
oNewPag:SetStepDescription(STR0001) //Altera a descrição do step  //"Primeiros passos"
oNewPag:SetConstruction({|Panel|cria_pg1(Panel)}) //Define o bloco de construção
oNewPag:SetNextAction({||valida_pg1()})//Define o bloco ao clicar no botão Próximo
oNewPag:SetCancelAction({||FWAlertInfo(STR0002), .F.})//Valida acao cancelar, nao deixa sair do wizard //"Wizard não pode ser cancelado!"


// 02 ------------------------------ "Impressora"
oNewPag := oStepWiz:AddStep("2", {|Panel|cria_pg2(Panel)})
oNewPag:SetStepDescription(STR0003)//"Impressora"
oNewPag:SetNextAction({||valida_pg2()})
oNewPag:SetCancelWhen({||.F.})


// 03 ------------------------------ "TEF"
oNewPag := oStepWiz:AddStep("3", {|Panel|cria_pn3(Panel)})
oNewPag:SetStepDescription(STR0004)//"TEF"
oNewPag:SetNextAction({||valida_pg3()})
oNewPag:SetCancelWhen({||.F.})


// 04 ------------------------------ "Leitor via Câmera"
oNewPag := oStepWiz:AddStep("4", {|Panel|cria_pn4(Panel)})
oNewPag:SetStepDescription(STR0005)//"Leitor via Câmera"
oNewPag:SetNextAction({||valida_pg4()})
oNewPag:SetCancelWhen({||.F.})


// 05 ------------------------------ "Marca da Empresa"
oNewPag := oStepWiz:AddStep("5", {|Panel|cria_pn5(Panel)})
oNewPag:SetStepDescription(STR0006)//"Marca da Empresa"
oNewPag:SetNextAction({|| lFimWizard := FimWizard(), lFimWizard })
oNewPag:SetCancelWhen({||.F.})


//Ativa Wizard
oStepWiz:Activate()

//Desativa Wizard
oStepWiz:Destroy()


Return .T.


//-------------------------------------------------------------------	
/*/{Protheus.doc} cria_pg1
Cria wizard de Configurações para mobile pg1

@param  oPanel - Panel de Fundo
@author  Varejo
@version P11.8
@since   27/05/2015
@return  Nil
@obs     
@sample
/*/
//-------------------------------------------------------------------	
Static Function cria_pg1(oPanel)


Local oSayPdv				:= Nil	//Numero da estacao PDV
Local oTGetPDV			:= Nil	//Numero da estacao PDV
Local oSaySerie			:= Nil	//Serie da estacao
Local oTGetSerie			:= Nil	//Serie da estacao
Local oSayEndWs			:= Nil	//Endereco do WebService
Local oTGetEndWs			:= Nil	//Endereco do WebService
Local oCbxRegTrib       	:= Nil //Regime tributario para NFC-E 
Local aCbxRegTrib       	:= {} 	//Regime tributario para NFC-E 
Local oSayRegTrib			:= Nil	//Regime de tributacao
Local oSayToken			:= Nil	//Token SEFAZ
Local oTGetToken			:= Nil	//Token SEFAZ
Local oSayFilServer		:= Nil	//Filial do servidor
Local oSayExEndWs			:= Nil	//Say de exemplo de end WS
Local oTGetFilServer		:= Nil	//Filial do servidor

Default oPanel 			:= Nil // Panel Bkg


//---------- Codigo da estacao e numero do PDV

cLG_PDV := PADR(STFGetStation("PDV"),TamSx3("LG_PDV")[1])

oSayPdv:= TSay():New(05,10,{|| STR0007 },oPanel,,,,,,.T.,,,100,25) //"Código do PDV"
oSayPdv:SetCSS( POSCSS (GetClassName(oSayPdv), CSS_LABEL_NORMAL )) 

oTGetPDV := TGet():New(15,10,{|u| if( PCount() > 0, cLG_PDV := u, cLG_PDV ) } ,oPanel,130,025, "@E " + Replicate("9",TamSx3("LG_PDV")[1] ) ,,0,,,.F.,,.T.,,.F.,,.F.,.F.,,.F.,.F.,,cLG_PDV,,,, )
oTGetPDV:SetCSS( POSCSS (GetClassName(oTGetPDV), CSS_GET_NORMAL ))


//---------- Serie do PDV
cLG_SERIE := PADR(STFGetStation("SERIE"),TamSx3("LG_SERIE")[1])
oSaySerie:= TSay():New(05,150,{||STR0008},oPanel,,,,,,.T.,,,300,25) //"Série do PDV"
oSaySerie:SetCSS( POSCSS (GetClassName(oSaySerie), CSS_LABEL_NORMAL )) 

oTGetSerie := TGet():New( 15,150,{|u| if( PCount() > 0, cLG_SERIE := u, cLG_SERIE ) },oPanel,80,025,"@E " + Replicate("9",TamSx3("LG_SERIE")[1] ),,0,,,.F.,,.T.,,.F.,,.F.,.F.,,.F.,.F.,,cLG_SERIE,,,, )
oTGetSerie:SetCSS( POSCSS (GetClassName(oTGetSerie), CSS_GET_NORMAL ))


//---------- Regime Tributario para NFC-E
aCbxRegTrib := {	STR0009 ,; //"1 - Simples Nacional"
					STR0010 ,; //"2 - Simples Nacional - Excesso de sub-limite de receita bruta"
					STR0011 }   //"3 - Regime Nacional"

cMV_CODREG := AllTrim(SuperGetMV( "MV_CODREG", .F., ""))
IIF(cMV_CODREG $ "123",cMV_CODREG := aCbxRegTrib[Val(cMV_CODREG)],"")
oSayRegTrib:= TSay():New(45,10,{|| STR0012 },oPanel,,,,,,.T.,,,100,25)//"Regime Tributário" 
oSayRegTrib:SetCSS( POSCSS (GetClassName(oSayRegTrib), CSS_LABEL_NORMAL )) 

oCbxRegTrib := TComboBox():Create(	oPanel, {|u| if( Pcount( )>0, cMV_CODREG := u, cMV_CODREG) },  55, 10, ;
										aCbxRegTrib, 285, 25,,,,,,.T.,,,,,,,,,cMV_CODREG)
oCbxRegTrib:SetCSS( POSCSS (GetClassName(oCbxRegTrib), CSS_COMBOBOX)) 


//---------- Token SEFAZ  
cMV_NFCEIDT := PADR(SuperGetMV( "MV_NFCEIDT", .F., ""),100)
oSayToken:= TSay():New(85,10,{||STR0013},oPanel,,,,,,.T.,,,100,25) //"Token SEFAZ"
oSayToken:SetCSS( POSCSS (GetClassName(oSayToken), CSS_LABEL_NORMAL )) 

oTGetToken := TGet():New( 95,10,{|u| if( PCount() > 0, cMV_NFCEIDT := u, cMV_NFCEIDT ) },oPanel,130,025,,,0,,,.F.,,.T.,,.F.,,.F.,.F.,,.F.,.F.,,cMV_NFCEIDT,,,, )
oTGetToken:SetCSS( POSCSS (GetClassName(oTGetToken), CSS_GET_NORMAL ))


//---------- Codigo da empresa cadastrado no daruma Migrate
cMV_LJEMPCK := PADR(SuperGetMV( "MV_LJEMPCK", .F., ""),100)
oSayToken:= TSay():New(85,150,{||STR0014},oPanel,,,,,,.T.,,,150,25) //"Código Empresa Daruma Migrate"
oSayToken:SetCSS( POSCSS (GetClassName(oSayToken), CSS_LABEL_NORMAL )) 

oTGetToken := TGet():New( 95,150,{|u| if( PCount() > 0, cMV_LJEMPCK := u, cMV_LJEMPCK ) },oPanel,130,025,,,0,,,.F.,,.T.,,.F.,,.F.,.F.,,.F.,.F.,,cMV_LJEMPCK,,,, )
oTGetToken:SetCSS( POSCSS (GetClassName(oTGetToken), CSS_GET_NORMAL ))


//---------- Codigo da Filial da integracao
 
cMV_LJFILIN := PADR(SuperGetMV( "MV_LJFILIN", .F., ""),100)
oSayFilServer:= TSay():New(125,10,{||STR0015},oPanel,,,,,,.T.,,,150,25) //"Filial Servidor"
oSayFilServer:SetCSS( POSCSS (GetClassName(oSayFilServer), CSS_LABEL_NORMAL )) 

oTGetFilServer := TGet():New( 135,10,{|u| if( PCount() > 0, cMV_LJFILIN := u, cMV_LJFILIN ) },oPanel,130,025,,,0,,,.F.,,.T.,,.F.,,.F.,.F.,,.F.,.F.,,cMV_LJFILIN,,,, )
oTGetFilServer:SetCSS( POSCSS (GetClassName(oTGetFilServer), CSS_GET_NORMAL ))


//---------- Endereco Ws do servidor
cLG_WSSRV := AllTrim(STFGetStation("WSSRV"))

If !Empty(cLG_WSSRV) 

	While  "/WSPDV" $  UPPER(cLG_WSSRV)
		cLG_WSSRV := 	SUBSTR(cLG_WSSRV, 1, Len(cLG_WSSRV) - 6 )
	End
			
EndIf

cLG_WSSRV := PADR( cLG_WSSRV ,TamSx3("LG_WSSRV")[1])

oSayEndWs:= TSay():New(165,10,{||STR0016},oPanel,,,,,,.T.,,,300,25) //"End. e Porta WebService Servidor"
oSayEndWs:SetCSS( POSCSS (GetClassName(oSayEndWs), CSS_LABEL_NORMAL )) 

oSayExEndWs:= TSay():New(185,145,{||"ex: 172.16.70.110:190"},oPanel,,,,,,.T.,,,300,25) //"ex: 172.16.70.110:190"
oSayExEndWs:SetCSS( POSCSS (GetClassName(oSayExEndWs), CSS_LABEL_FOCAL )) 

oTGetEndWs := TGet():New( 175,10,{|u| if( PCount() > 0, cLG_WSSRV := u, cLG_WSSRV ) } ,oPanel,130,25,"@!",,0,,,.F.,,.T.,,.F.,,.F.,.F.,,.F.,.F.,,cLG_WSSRV,,,, )
oTGetEndWs:SetCSS( POSCSS (GetClassName(oTGetEndWs), CSS_GET_NORMAL ))


Return Nil


//-------------------------------------------------------------------	
/*/{Protheus.doc} valida_pg1
Cria Validacao do wizard de Configurações para mobile pg1

@param 
@author  Varejo
@version P11.8
@since   27/05/2015
@return  Nil
@obs     
@sample
/*/
//-------------------------------------------------------------------	
Static Function valida_pg1()

Local lRet := .T.		//Retorno da validacao

IIf(lRet					, lRet := !Empty(cLG_PDV) 			,)
IIf(lRet 					, lRet := !Empty(cLG_SERIE) 			,)
IIf(lRet					, lRet := !Empty(cMV_CODREG) 			,)
IIf(lRet 					, lRet := !Empty(cMV_NFCEIDT) 			,)
IIf(lRet					, lRet := !Empty(cMV_LJEMPCK) 			,)
IIf(lRet 					, lRet := !Empty(cLG_WSSRV) 			,)

If !lRet
	MsgWzValid()//Mensagem validacao
EndIf	

Return lRet


//-------------------------------------------------------------------	
/*/{Protheus.doc} cria_pg2
Cria wizard de Configurações para mobile pg2

@param  oPanel - Panel de Fundo
@author  Varejo
@version P11.8
@since   27/05/2015
@return  Nil
@obs     
@sample
/*/
//-------------------------------------------------------------------	
Static Function cria_pg2(oPanel)

Local nPnlHeight		:= 40 	//Altura  panel de botoes
Local nPlnWidth		:= 40 	//Largura panel de botoes
Local nBtnPosHoriz	:= 0	//Posicao horizontal dos Botoes
Local aItems 			:= {} //Impressoras disponiveis
Local oPanelBtn 		:= TPanel():New(0,0,"",oPanel,,,,,,nPlnWidth,nPnlHeight)//Panel de botoes
Local oBtnBlu 		:= Nil	//Botao Bluetooth
Local oBtnWifi 		:= Nil	//Botao Wifi
Local oSayCab	 		:= Nil	//Say de Inforcao de cabecalho
Local oSayIPName	 	:= Nil	//Say de IP(Wifi) | ou nome da impressora(Bluetooth)
Local oSayPort 		:= Nil	//Say de porta da impressora
Local oGetIPName 		:= Nil	//Get de IP(Wifi) | ou nome da impressora(Bluetooth)
Local oGetPort 		:= Nil	//Get de porta da impressora
Local nPosImp			:= 0	//Posicao da impressora

Default oPanel := Nil 		// Panel Bkg

aItems 			:= {'DARUMA DR700 V02.10.01','DATECS DPP-350 BT'}

//valida se impressora Bluetooth ou wifi
cLG_PORTIF := STFGetStation("PORTIF") //Porta da impressora | Se Bluetooth sera gravado 'BLU'
If UPPER(AllTrim(cLG_PORTIF)) == "BLU" //Impressora Bluetooth
	lImpblu 	:= .T.
	lImpWifi 	:= .F.
EndIf

oPanelBtn:SetCss((POSCSS (GetClassName(oPanelBtn), CSS_PANEL_WIZARD, .T. )))
oPanelBtn:Align := CONTROL_ALIGN_TOP

oSayCab:= TSay():New(017,010,{||STR0017},oPanelBtn,,,,,,.T.,,,200,25)//"CONECTAR IMPRESSORA" 
oSayCab:SetCSS( POSCSS (GetClassName(oSayCab), CSS_LABEL_HEADER )) 


//---------- Botao Bluetooth
nBtnPosHoriz := ((oPanel:nClientWidth/2) - 200 )//Calcula posicao horizontal
oBtnBlu := TButton():New( 010, nBtnPosHoriz, STR0018,oPanelBtn,; //"Bluetooth"
								{||oBtnBlu:SetCSS( POSCSS (GetClassName(oBtnBlu), CSS_BTN_ATIVO )) 	,;
								oBtnWifi:SetCSS( POSCSS (GetClassName(oBtnWifi), CSS_BTN_NORMAL )) 	,;
								lImpWifi := .F. , lImpBlu := .T. 										 	,;
								cLG_TSCSRV  := PADR("",TamSx3("LG_TSCSRV")[1]) 							,;
								cLG_TSCPORT := PADR("",TamSx3("LG_TSCPORT")[1])							},;
								LARGBTN,ALTURABTN,,,.F.,.T.,.F.,,.F.,,,.F. )
oBtnBlu:SetCSS( POSCSS (GetClassName(oBtnBlu), IIF(lImpblu,CSS_BTN_ATIVO,CSS_BTN_NORMAL) )) 


//---------- Botao Wifi
nBtnPosHoriz := ((oPanel:nClientWidth/2) - 100 )//Calcula posicao horizontal
oBtnWifi := TButton():New( 010, nBtnPosHoriz, STR0019 ,oPanelBtn, ; //"Rede Sem Fio (Wi-Fi)"
								{||oBtnBlu:SetCSS( POSCSS (GetClassName(oBtnBlu), CSS_BTN_NORMAL )) 	,;
								oBtnWifi:SetCSS( POSCSS (GetClassName(oBtnWifi), CSS_BTN_ATIVO ))   	,;
								lImpWifi := .T. , lImpBlu := .F. 										 	,;
								cLG_TSCSRV  := PADR("",TamSx3("LG_TSCSRV")[1]) 							,;
								cLG_TSCPORT := PADR("",TamSx3("LG_TSCPORT")[1])							},;								
								LARGBTN,ALTURABTN,,,.F.,.T.,.F.,,.F.,,,.F. )
oBtnWifi:SetCSS( POSCSS (GetClassName(oBtnWifi), IIF(lImpWifi,CSS_BTN_ATIVO,CSS_BTN_NORMAL) )) 


//---------- ListBox das Impressoras
oListImp := TListBox():Create(oPanel,nPnlHeight+1,0,,aItems,oPanel:nClientWidth,100,,,,,.T.)
oListImp:SetCSS( POSCSS (GetClassName(oListImp),CSS_LISTBOX )) 

cLG_IMPFISC   := AllTrim(STFGetStation("IMPFISC"))
cImpAnterior  := cLG_IMPFISC //Armazena impressora configurada
nPosImp := ASCAN(aItems, cLG_IMPFISC )

//Posiciona na impressora cadastrada
If nPosImp > 0
	oListImp:Select(nPosImp)
Else
	oListImp:GoTop()//Posiciona no item 1
EndIf	


//---------- IP ou Nome da impressora
oSayIPName:= TSay():New(nPnlHeight+115,010,{||IIf(lImpWifi,STR0020,STR0021)},oPanel,,,,,,.T.,,,300,25) //"Endereço IP da impressora na rede:" ### "Nome da Impressora BlueTooth. Case-sensitive"
oSayIPName:SetCSS( POSCSS (GetClassName(oSayIPName), CSS_LABEL_NORMAL  )) 

cLG_TSCSRV := PADR(STFGetStation("TSCSRV",,.F.),TamSx3("LG_TSCSRV")[1])
oGetIPName := TGet():New( nPnlHeight+125,10,{|u| if( PCount() > 0, cLG_TSCSRV := u, cLG_TSCSRV ) } ,oPanel,120,25,"",,0,,,.F.,,.T.,,.F.,,.F.,.F.,,.F.,.F.,,cLG_TSCSRV,,,, )
oGetIPName:SetCSS( POSCSS (GetClassName(oGetIPName), CSS_GET_NORMAL )) 


//---------- Porta da impressora
oSayPort:= TSay():New(nPnlHeight+115,150,{||IIf(lImpWifi,STR0022,"")},oPanel,,,,,,.T.,,,300,25) //"Porta da impressora:"
oSayPort:SetCSS( POSCSS (GetClassName(oSayPort), CSS_LABEL_NORMAL  ))

cLG_TSCPORT := PADR(IIf(lImpblu,"",STFGetStation("TSCPORT")),TamSx3("LG_TSCPORT")[1])
oGetPort := TGet():New( nPnlHeight+125,150,{|u| if( PCount() > 0, cLG_TSCPORT := u, cLG_TSCPORT ) } ,oPanel,40,25,"@!",,0,,,.F.,,.T.,,.F.,,.F.,.F.,,.F.,.F.,,cLG_TSCPORT,,,, )
oGetPort:SetCSS( POSCSS (GetClassName(oGetPort), CSS_GET_NORMAL ))
oGetPort:bWhen := {|| lImpWifi }


Return Nil

//-------------------------------------------------------------------	
/*/{Protheus.doc} valida_pg2
Cria Validacao do wizard de Configurações para mobile pg2

@param 
@author  Varejo
@version P11.8
@since   27/05/2015
@return  lRet - Retorno da validacao
@obs     
@sample
/*/
//-------------------------------------------------------------------	
Static Function valida_pg2()

Local lRet := .T.		//Retorno da validacao

IIf(lRet					, lRet := oListImp:GetPos() > 0 		,)//impressora selecionada
IIf(lRet					, lRet := !Empty(cLG_TSCSRV) 			,)//IP ou Nome informado
IIf(lRet .AND. lImpWifi	, lRet := !Empty(cLG_TSCPORT) 			,)//Porta informada apenas Wifi Rede

If !lRet
	MsgWzValid()//Mensagem validacao
EndIf	

Return lRet


//-------------------------------------------------------------------	
/*/{Protheus.doc} cria_pn3
Cria wizard de Configurações para mobile pn3

@param  oPanel - Panel de Fundo
@author  Varejo
@version P11.8
@since   27/05/2015
@return  Nil
@obs     
@sample
/*/
//-------------------------------------------------------------------	
Static Function cria_pn3(oPanel)

Local nPnlHeight		:= 40 	//Altura  panel 
Local nPlnWidth		:= 40 	//Largura panel 
Local aItems 			:= {} 	//TEFs disponiveis
Local oPanelSup 		:= TPanel():New(0,0,"",oPanel,,,,,,nPlnWidth,nPnlHeight)//Panel Superior
Local oSayCab	 		:= Nil	//Say de Inforcao de cabecalho
Local oSayAtvTEF	 	:= Nil	//Say de Ativa TEF
Local nBtnAtiva 		:= Nil	//Botao Ativa/Desativa TEF
Local nPosTEF			:= 0	//Posicao do TEF

Default oPanel := Nil 		// Panel Bkg


oPanelSup:SetCss((POSCSS (GetClassName(oPanelSup), CSS_PANEL_WIZARD, .T. )))
oPanelSup:Align := CONTROL_ALIGN_TOP

oSayCab:= TSay():New(017,010,{||STR0023},oPanelSup,,,,,,.T.,,,200,25) //"ATIVA TRANSAÇÕES TEF" 
oSayCab:SetCSS( POSCSS (GetClassName(oSayCab), CSS_LABEL_HEADER )) 

//---------- ListBox dos TEFs
aItems 			:= {"PAYGO"}
oListTEF := TListBox():Create(oPanel,nPnlHeight+1,0,,aItems,oPanel:nClientWidth,100,,,,,.T.)
oListTEF:SetCSS( POSCSS (GetClassName(oListTEF),CSS_LISTBOX )) 

cMDG_CARPAY   := AllTrim(STFGetStation("CARPAY",.T.))
nPosTEF := IIF(cMDG_CARPAY == "1",1,0)

//Posiciona no TEF cadastrado
If nPosTEF > 0
	oListTEF:Select(nPosTEF)
Else
	oListTEF:GoTop()//Posiciona no item 1
EndIf	


//---------- Ativa TEF
cMDG_TEFATV   := AllTrim(STFGetStation("TEFATV",.T.))
lTefAtivo := cMDG_TEFATV == "1"
nBtnAtiva := TButton():New( nPnlHeight+125,10, STR0024,oPanel, ; //"Ativa / Desativa TEF"
								{||,;								
								IIF( lTefAtivo , lTefAtivo := .F. , lTefAtivo := .T. )					,;
								nBtnAtiva:SetCSS( POSCSS (GetClassName(nBtnAtiva), IIF(lTefAtivo,CSS_BTN_ATIVO,CSS_BTN_NORMAL) )) ,;
								cMDG_TEFATV := IIF( lTefAtivo , "1" , "2" )},;								
								LARGBTN,ALTURABTN,,,.F.,.T.,.F.,,.F.,,,.F. )
nBtnAtiva:SetCSS( POSCSS (GetClassName(nBtnAtiva), IIF(lTefAtivo,CSS_BTN_ATIVO,CSS_BTN_NORMAL) )) 

oSayAtvTEF:= TSay():New(nPnlHeight+135,100,{|| IIF(lTefAtivo,STR0025,STR0026)},oPanel,,,,,,.T.,,,100,25) //"TEF Ativado!" ### "TEF Desativado!" 
oSayAtvTEF:SetCSS( POSCSS (GetClassName(oSayAtvTEF), CSS_LABEL_NORMAL  )) 


Return Nil


//-------------------------------------------------------------------	
/*/{Protheus.doc} valida_pg3
Cria Validacao do wizard de Configurações para mobile pg3

@param 
@author  Varejo
@version P11.8
@since   27/05/2015
@return  lRet - Retorno da validacao
@obs     
@sample
/*/
//-------------------------------------------------------------------	
Static Function valida_pg3()

Local lRet := .T.		//Retorno da validacao // essa pag nao precisa validar

Return lRet


//-------------------------------------------------------------------	
/*/{Protheus.doc} cria_pn4
Cria wizard de Configurações para mobile pn4

@param  oPanel - Panel de Fundo
@author  Varejo
@version P11.8
@since   27/05/2015
@return  Nil
@obs     
@sample
/*/
//-------------------------------------------------------------------	
Static Function cria_pn4(oPanel)

Local nPnlHeight		:= 40 	//Altura  panel 
Local nPlnWidth		:= 40 	//Largura panel 
Local oPanelSup 		:= TPanel():New(0,0,"",oPanel,,,,,,nPlnWidth,nPnlHeight)//Panel Superior
Local oSayCab	 		:= Nil	//Say de Inforcao de cabecalho
Local oSayCodBar		:= Nil	//Say do código de barras	
Local oSayBCodBar		:= Nil	//Say do botao código de barras	
Local oBtnCam			:= Nil	//Botao da Camera

Default oPanel := Nil

oPanelSup:SetCss((POSCSS (GetClassName(oPanelSup), CSS_PANEL_WIZARD, .T. )))
oPanelSup:Align := CONTROL_ALIGN_TOP

oSayCab:= TSay():New(017,010,{||STR0027},oPanelSup,,,,,,.T.,,,200,25) //"LEITOR VIA CÂMERA"
oSayCab:SetCSS( POSCSS (GetClassName(oSayCab), CSS_LABEL_HEADER )) 


oSayCodBar:= TSay():New(nPnlHeight+5,10,{||STR0028 + chr(13)+chr(10) + ; //"Você pode escanear os códigos de barras de seus produtos"
											  STR0029 },oPanel,,,,,,.T.,,,300,50) //"usando a câmera do seu dispositivo"
oSayCodBar:SetCSS( POSCSS (GetClassName(oSayCodBar), CSS_LABEL_HEADER )) 
											  
//"Botao teste da camera"
oBtnCam	:= TButton():New(	nPnlHeight+35,10,"",oPanel,{|| TesteCam() },40,ALTURABTN,,,,.T.,,,,)
oBtnCam:SetCSS( POSCSS (GetClassName(oBtnCam), CSS_BTN_BARCODE ))
												  
oSayBCodBar:= TSay():New(nPnlHeight+65,10,{||STR0030 },oPanel,,,,,,.T.,,,300,50)//"Pressione o Botão e teste"											  
oSayBCodBar:SetCSS( POSCSS (GetClassName(oSayBCodBar), CSS_LABEL_NORMAL )) 


Return Nil


//-------------------------------------------------------------------	
/*/{Protheus.doc} valida_pg4
Cria Validacao do wizard de Configurações para mobile pg4

@param 
@author  Varejo
@version P11.8
@since   27/05/2015
@return  lRet - Retorno da validacao
@obs     
@sample
/*/
//-------------------------------------------------------------------	
Static Function valida_pg4()
Local lRet := .F. //Retorno

lRet := .T.

Return lRet



//-------------------------------------------------------------------
/*/{Protheus.doc} TesteCam
Teste de camera dso dispositivos mobiles

@param  
@author  Varejo
@version P11.8
@since   02/06/2015
@return  cRet	- retorna o codigo lido
@obs
@sample
/*/
//-------------------------------------------------------------------
Static Function TesteCam()

Local oMbl				:= Nil		//Objeto Barcode
Local cBarType			:= ""		//Define os Tipos de Barcode lidos
Local aBarResult		:= {}		//Array de resultados
Local cRet				:= ""		//retorna o codigo lido

oMbl:= TMobile():New()

aBarResult:= oMbl:BarCode(cBarType)
If aBarResult[2] = ""
	cRet := ""
Else
	cRet := aBarResult[2] 
EndIf

Return cRet 

//-------------------------------------------------------------------	
/*/{Protheus.doc} cria_pn5
Cria wizard de Configurações para mobile pn5

@param  oPanel - Panel de Fundo
@author  Varejo
@version P11.8
@since   27/05/2015
@return  Nil
@obs     
@sample
/*/
//-------------------------------------------------------------------	
Static Function cria_pn5(oPanel)

Local nPnlHeight		:= 0 	//Altura  panel 
Local nPlnWidth		:= 0 	//Largura panel 
Local oPanelL 		:= Nil //Panel Esquerdo
Local oPanelR 		:= Nil //Panel direito
Local oSayCab	 		:= Nil	//Say de Inforcao de cabecalho
Local oSayFormato		:= Nil	//Say Formato das imagens
Local oImgExemplo		:= Nil	//Imagen de exemplo da direita
Local oSayInfo1		:= Nil	//Say de Inforcao da imagem tela Esquerda
Local oSayInfo2		:= Nil	//Say de Inforcao da imagem tela Superior Direita
Local oSayInfo3		:= Nil	//Say de Inforcao da imagem tela Inferior Direita
Local oBtnAltImg		:= Nil	//Botao alterar imagem
Local bTrocaImg		:= {||}//Bloco de codigo para troca da imagem
Local cImgName		:= PADR("LOGOPOS",20)	//Nome da imagem para troca 
Local lIncluiuImg		:= .F.  //controla se conseguiu incluir a imagem

Default oPanel := Nil

nPnlHeight := (oPanel:nClientHeight/2) /2
nPlnWidth  := (oPanel:nClientWidth/2) /2


//---------- Lado esquerdo ----------
//----------------------------------
//----------------------------------
oPanelL 		:= TPanel():New(0,0,"",oPanel,,,,,,nPlnWidth,nPnlHeight)//Panel Esquerdo
oPanelL:SetCss((POSCSS (GetClassName(oPanelL), CSS_PANEL_WIZARD, .T. )))
oPanelL:Align := CONTROL_ALIGN_LEFT

oSayCab:= TSay():New(010,010,{||STR0031},oPanelL,,,,,,.T.,,,200,25) //"MARCA DA EMPRESA"
oSayCab:SetCSS( POSCSS (GetClassName(oSayCab), CSS_LABEL_HEADER )) 

//----Imagem do Repositorio
@ 030,010 REPOSITORY oImg OF oPanelL SIZE 130,65 PIXEL
If !oImg:LoadBMP(cImgName) 
	//Verifica se nao tem o arquivo sem os espacos
	oImg:LoadBMP(AllTrim(cImgName)) 
EndIf
oImg:lStretch := .T.

//---- Says
oSayFormato:= TSay():New(100,010,{||STR0032 + chr(13)+chr(10) + "LOGOPOS.JPG"},oPanelL,,,,,,.T.,,,200,25) //"Formato:"
oSayFormato:SetCSS( POSCSS (GetClassName(oSayFormato), CSS_LABEL_FOCAL )) 

oSayInfo1:= TSay():New(130,010,{||"* " + STR0033},oPanelL,,,,,,.T.,,,200,25) //"Utilizar imagem com fundo branco"
oSayInfo1:SetCSS( POSCSS (GetClassName(oSayInfo1), CSS_LABEL_FOCAL )) 

//"Botao Trocar Imagem"
bTrocaImg := {||  TrocaImg(oImg ,cImgName )  }
	
oBtnAltImg	:= TButton():New(	150,010,STR0034,oPanel, bTrocaImg ,LARGBTN,ALTURABTN,,,,.T.,,,,)//"Trocar imagem" //Refresh na Dialog para alteração da imagem
oBtnAltImg:SetCSS( POSCSS (GetClassName(oBtnAltImg), CSS_BTN_NORMAL ))


//---------- Lado Direito ----------
//----------------------------------
//----------------------------------
oPanelR 		:= TPanel():New(0,0,"",oPanel,,,,,,nPlnWidth,nPnlHeight)//Panel direito
oPanelR:Align := CONTROL_ALIGN_RIGHT

oSayInfo2:= TSay():New(010,010,{||STR0035 + chr(13)+chr(10) + STR0036},oPanelR,,,,,,.T.,,,200,25) //"Aplicação da marca da" ### "empresa no aplicativo"
oSayInfo2:SetCSS( POSCSS (GetClassName(oSayInfo2), CSS_LABEL_FOCAL )) 


//----Imagem do Repositorio
@ 030,010 REPOSITORY oImgExemplo OF oPanelR NOBORDER SIZE 130,100 PIXEL
oImgExemplo:Load("posmarca") 
oImgExemplo:lStretch := .T.

oSayInfo3:= TSay():New(135,010,{|| STR0037 + chr(13)+chr(10) +;  //"A marca da empresa irá aparecer na tela"
										STR0038 + chr(13)+chr(10) +;  //"do aplicaativo, na parte superior esquerda," 
										STR0039 },oPanelR,,,,,,.T.,,,200,25) //"conforme imagem acima"
oSayInfo3:SetCSS( POSCSS (GetClassName(oSayInfo3), CSS_LABEL_FOCAL )) 


Return Nil


//-------------------------------------------------------------------	
/*/{Protheus.doc} TrocaImg
Troca imagem de logo do PDV

@param  oImage - Objeto de imagem
@param  cImgName - Nome da imagem
@author  Varejo
@version P11.8
@since   27/05/2015
@return  Nil
@obs     
@sample
/*/
//-------------------------------------------------------------------	
Static Function TrocaImg(oImage, cImgName)

Local nMaskDef		:= 2 							// Mascara JPEG como default
Local cDirAtu			:= ""                       // Diretoria atual
Local cFile 			:= ""							// path + arquivo
Local lInsertImage	:= .T.							// Foi concluida a insercao da imagem?
Local lRet 	 		:= .T.							// Retorno da funcao
Local cDrive			:= Space(255)					// Drive onde esta o arquivo
Local cDir	 	    	:= Space(255)					// Diretorio onde esta o arquivo
Local cMask 			:=  STR0032 + " JPEG" + "(*.JPG) |*.jpg|"	// "Formato" "JPEG" + "(*.JPG) |*.jpg|"

Default oImage 	:= Nil 
Default cImgName 	:= "" 

cFile := cGetFile( cMask, STR0040 + " LOGOPOS.JPG...", @nMaskDef, GetSrvProfString("RootPath",""), .F. )		// "Selecione o arquivo"

If Empty(cFile) .OR. Empty(cImgName)
	lRet := .F.
Else

	If Upper(RIGHT(AllTrim(cFile),11)	)  == "LOGOPOS.JPG"
		cFile := UPPER(cFile)
		
		If ( File( cFile) )
	   		oImage:DeleteBmp(cImgName)
			cFile := oImage:InsertBmp(cFile,cImgName,.T.)
			oImage:LoadBmp(cImgName)
			oImage:Refresh()
		EndIf
	Else		
		FWAlertError( STR0041 + " LOGOPOS.JPG") //"Imagem Inválida. A imagem deve estar no formato .JPG e com o nome"	
	EndIf	
	
EndIf

Return lRet


//-------------------------------------------------------------------	
/*/{Protheus.doc} MsgWzValid
Mensagem validacao padrao wizard

@param 
@author  Varejo
@version P11.8
@since   27/05/2015
@return  Nil
@obs     
@sample
/*/
//-------------------------------------------------------------------	
Static Function MsgWzValid()
	FWAlertError(STR0042)//"Campos obrigatórios não informados!"
Return Nil


//-------------------------------------------------------------------	
/*/{Protheus.doc} FimWizard
Finaliza wizard de Configurações.

@param 
@author  Varejo
@version P11.8
@since   27/05/2015
@return  Nil
@obs     
@sample
/*/
//-------------------------------------------------------------------	
Static Function FimWizard()

Local lRet := .T. 	//Retorno


aSLG   		:= {}	//Array que guarda os dados do cadastro de estacao
aMDG   		:= {}	//Array que guarda os dados do cadastro de estacao TEF


//---------- Informacoes da pag 1

//Parametros
PutMV("MV_CODREG"		, LEFT(AllTrim(cMV_CODREG),1)	)//Regime tributario para NFC-E 
PutMV("MV_NFCEIDT"	, AllTrim(cMV_NFCEIDT)	)//Token do sefaz
PutMV("MV_LJEMPCK"	, AllTrim(cMV_LJEMPCK)	)//Codigo da empresa cadastrado no daruma Migrate
PutMV("MV_LJFILIN"	, AllTrim(cMV_LJFILIN)	)//Codigo da Filial da integracao


//Cadastro de Estacao
Aadd( aSLG , { "PDV"			, cLG_PDV			} )//Numero do PDV
Aadd( aSLG , { "SERIE"		, cLG_SERIE		} )
cLG_WSSRV := AllTrim(cLG_WSSRV) + "/wspdv" 		//Exemplo de como fica "127.0.0.1:190/wspdv"	
Aadd( aSLG , { "WSSRV"		, cLG_WSSRV 		} )



//---------- Informacoes da pag 2
cLG_IMPFISC 	:= oListImp:GetSelText() 			//Modelo da Impressora 
cLG_TSCPORT   := IIf(lImpWifi,cLG_TSCPORT,"500")	//porta para impressora de Rede, Wifi . Se Bluetooth sera gravado o timeout 500 default
cLG_PORTIF 	:= IIf(lImpBlu,"BLU",cLG_PORTIF)	//Porta da impressora | Se Bluetooth sera gravado 'BLU'

Aadd( aSLG , { "IMPFISC"		, cLG_IMPFISC		} )
Aadd( aSLG , { "TSCSRV"		, cLG_TSCSRV		} )
Aadd( aSLG , { "TSCPORT"		, cLG_TSCPORT		} )
Aadd( aSLG , { "PORTIF"		, cLG_PORTIF		} )

lRet := STFSetStat( aSLG )


//---------- Informacoes da pag 3
Aadd( aMDG , { "TEFATV"		, cMDG_TEFATV		} )//Ativa o TEF
Aadd( aMDG , { "CARPAY"		, cMDG_CARPAY		} )//Usa TEF PAYGO
lRet := STFSetTefStat( aMDG )

FWAlertSuccess(STR0043)//"Wizard Configurado com sucesso!"

// funções não compiladas - retirado o bloc de codigo

Return .T.


            
