#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "TOPCONN.CH"
#INCLUDE "TAFTICKET.CH"
#INCLUDE "TAFTCKDEF.CH"  
#INCLUDE "TAFCSS.CH" 

//DEFINIÇÕES DE LAYOUT DO ARQUIVO LAYOUT.DEF
#DEFINE Z1_LAYOUT		01
#DEFINE Z1_DESC			02
#DEFINE Z1_ADAPT		03
#DEFINE Z1_TABLE		04
#DEFINE Z1_DESTAB		05        
#DEFINE Z1_ORDER		06
#DEFINE Z1_MVCOPT		07
#DEFINE Z1_MVCMET		08
#DEFINE Z1_CHANELS		09

#DEFINE Z2_CHANEL		01
#DEFINE Z2_SUPER		02
#DEFINE Z3_RELAC		03
#DEFINE Z3_DESC			04
#DEFINE Z3_IDOUT		05
#DEFINE Z3_OCCURS		06
#DEFINE Z3_ORDER		07
#DEFINE Z3_FIELDS		08

#DEFINE Z4_SEQ			01
#DEFINE Z4_FIELD		02
#DEFINE Z4_DESC			03
#DEFINE Z4_TYPFLD		04
#DEFINE Z4_SOURCE		05
#DEFINE Z4_EXEC			06

Static lTafX3 := FindFunction( 'TafTmSx3' )
Static __oTmpFil := Nil
//----------------------------------------------------------------------
/*/{Protheus.doc} TAFTicket

Gerenciador de informações de integração e validação.

@Param		lInteg	 ->	Informa se rotina foi chamada via Job 2.
			lValid	 ->	Informa se rotina foi chamada via Job 3.
			lFirstTime -> Variavel de controle para identificar quando a
						rotina  é chamada pelo botão de parâmetros das visões
						de Integração e Validação.
@Author	Felipe C. Seolin
@Since		06/04/2015
@Version	1.0
/*/
//---------------------------------------------------------------------
Function TAFTicket( lInteg, lValid, lFirstTime, aLisFil, lChkFil)

Local aParamT		:= Array(6)
Local oCombo		:= Nil
Local oRadio		:= Nil
Local cValorCmb 	:= ""
Local lCloseDlg		:= .F.
Local lExec			:= .F.
Local aRadioItems	:= {}
Local lNewC1E		:= GetNewPar( "MV_TAFCFGE", .F. )
Local lProtData		:= FindFunction("ProtData")
Local lExecuta		:= .T.

Private aCodErro	:= TAFCodErr()
Private lMarkAll	:= .F.
Private cCadastro	:= STR0104
Private oFather
Private oTFMonitor
Private oTFVisao
Private oTableG
	
Default lInteg		:=	.F.
Default lValid		:=	.F.
Default lFirstTime 	:=  .T. 
Default lChkFil		:=  .F.
Default aLisFil		:= {}

lExecuta := Iif( lProtData, ProtData(), .T.)

If lExecuta
	If lNewC1E
		lExec := VldComplem()
	Else
		lExec := .T.
	EndIf

	If lExec

		If lFirstTime 
			aParamT[1] := FirstDate(dDataBase)		//paramDataInicio
			aParamT[2] := dDataBase					//paramDataFinal   	
			aParamT[3] := .T.						//paramMIntegracao
			aParamT[4] := .T.						//paramMValidacao
			aParamT[5] := 1							//paramVisaoTicket
			aParamT[6] := 1							//paramEvento
		Else
			If !FLoadProf(@aParamT)
				aParamT[1] := FirstDate(dDataBase)
				aParamT[2] := dDataBase
				aParamT[3] := .T.
				aParamT[4] := .T.
				aParamT[5] := 1
				aParamT[6] := 1
			EndIf
		EndIf

		aAdd( aRadioItems, STR0239 )
		aAdd( aRadioItems, STR0240 )

		Define MsDialog oDlg From 0,0 To 340,500 Pixel Title OemToAnsi(STR0104 + " - " + STR0002) //'Gerenciador de Integração - Filtros'  
			
			oFont1 := TFont():New("Tahoma",,-12,.T.)
			
			oPanel := TPanel():New(000,000,'',oDlg,,.F.,.F.,,,000,000,.F.,.F.)
			oPanel:Align := CONTROL_ALIGN_ALLCLIENT

			oGetDtDe 	:= TGet():New(12,15,{|u|If( PCount()==0,aParamT[1],aParamT[1] := u )},oPanel,065,009,"@!",,,,,,,.T.,,,,,,,.F.,.F.,,,,,,.T.,,,STR0009,1,,CLR_BLUE) //"Data De:"
			oGetDtAte 	:= TGet():New(35,15,{|u|If( PCount()==0,aParamT[2],aParamT[2] := u )},oPanel,065,009,"@!",,,,,,,.T.,,,,,,,.F.,.F.,,,,,,.T.,,,STR0010,1,,CLR_BLUE) //"Data Até:"
			
			oTSay1 	:= TSay():New(12,170,{||STR0105},oPanel,,oFont1,,,,.T.,,,100,030,,,,,,.T.) //"Método de Visualização"
			
			oTcMonIn := TCheckBox():New(027,170,STR0005,,oPanel,100,210,,,,,,,,.T.,,,) //"Monitor de Integração"
			oTcMonIn:bSetGet 	:= {|| aParamT[3] } 
			oTcMonIn:bLClicked 	:= {|| aParamT[3]:= !aParamT[3]} 
			oTcMonIn:bWhen 		:= {||.T.} 
			
			oTcMonVl := TCheckBox():New(039,170,STR0006,,oPanel,100,210,,,,,,,,.T.,,,) //"Monitor de Validação"
			oTcMonVl:bSetGet 	:= {|| aParamT[4] } 
			oTcMonVl:bLClicked 	:= {|| aParamT[4]:= !aParamT[4]} 
			oTcMonVl:bWhen 		:= {||.T.} 

			TSay():New(65,15,{||STR0241},oPanel,,oFont1,,,,.T.,,,200,030,,,,,,.T.) //"Escopo a ser apresentado"
			oRadio := TRadMenu():New(75,15,aRadioItems,,oPanel,,,,,,,,100,12,,,,.T.)
			oRadio:bSetGet := {|u|Iif (PCount()==0,aParamT[6],aParamT[6]:=u)}
			
			oTSay2 	:= TSay():New(100,15,{||STR0107},oPanel,,oFont1,,,,.T.,,,200,030,,,,,,.T.) //"Escolha abaixo a visão à ser aplicada no monitor de integração"
			
			aItems:= {STR0108,STR0109} //'Visão por cadastro do TAF'#'Visão por status de integração (Integrado / Não Integrado)'
			oCombo := TComboBox():New(110,15,{|u|if(PCount()>0,cValorCmb:=u,cValorCmb)},aItems,170,20,oPanel,,{||aParamT[5] := oCombo:nAt},,,,.T.,,,,{||aParamT[3]},,,,,'aParamT[5]')
			oCombo:Select(aParamT[5])

		Activate MsDialog oDlg Centered On Init Enchoicebar (oDlg	,{||IIf(ValParam(aParamT),(lCloseDlg := .T.,oDlg:End()),.F.)};
																			,{||IIf(lFirstTime,(oDlg:End(),lCloseDlg := .F.),(lCloseDlg := .T.,oDlg:End()) ) };
																			,,,,,.F.,.F.,.F.,.T.,.F.)  
		If lCloseDlg																	
			FWMsgRun(,{||xMonContainer( aParamT, lProtData, aLisFil, lChkFil)},STR0104,STR0111) //"Gerenciador de Integração"#	"Carregando Monitor ..."																
		EndIf																 
	Else
		MsgAlert( "Foram encontradas inconsistências no Complemento Cadastral." + Chr(13) + Chr(10) + "Acesse o <b>Wizard de Configuração</b> para efetuar o ajuste necessário." )
	EndIf

EndIf

Return Nil 

/*/{Protheus.doc} ValParam
Função para validação dos parâmetros

@type function
@author Evandro dos Santos O. Teixeira
@since 25/07/2016
@version 1.0
@param aParamT - Parametros da tela de filtro
@return lRetorno - Informa de os parâmetros são válidos ou não.
@obs Os parâmetros também podem ser identificados das Strings definidas
no Include TAFMONDEF.CH
/*/
Static Function ValParam(aParamT)

Local lRetorno  as logical
Local lProtData	as logical
Local cMsg	    as char

lProtData := FindFunction("ProtData")
lRetorno  := .F.
cMsg	  := ""
	
If Empty(AllTrim(DTOS(paramDataInicio)))
	cMsg := STR0112 //"Data Inicial não Informada."
ElseIf Empty(AllTrim(DTOS(paramDataFinal)))
	cMsg := STR0113 //"Data Final não Informada."
ElseIf paramDataInicio > paramDataFinal
	cMsg := STR0114 //"Data Inicial não pode ser maior que a Data Final."
ElseIf paramDataFinal < paramDataInicio
	cMsg := STR0115 //"Data Final não pode ser menor que a Data Inicial."
ElseIf (!paramMIntegracao .And. !paramMValidacao)
	cMsg := STR0116 //"Selecionar pelo meno 1 método de visualização."
Else
	lRetorno := .T.
EndIf

If !lRetorno
	MsgStop(cMsg)
Else
	FSalvProf(aParamT)
EndIf
	
Return lRetorno

/*/{Protheus.doc} xMonContainer
Função Principal que cria os Folders e define quais objetos
devem ser criados em cada 1 conforme parâmetros.

@type function
@author Evandro dos Santos O. Teixeira
@since 25/07/2016
@version 1.0
@param aParamT - Array de Parâmetros
@return Nil 
/*/
Static Function xMonContainer( aParamT, lProtData, aLisFil, lChkFil)

Local oSize 	   
Local aSizeDlg	
Local aFolders	
Local aFolMon		
Local cTitulo	
Local nI		
Local aSize		
Local aSizeMV	
Local aErros  	
Local cFVIndiv	
Local nFI		
Local nFV		  
Local nFil		
Local lBackPar	
Local aButtons	
Local oPanelLeft
Local oPanelRight
Local oPanelDown
Local cCodFil	
Local cCodFil2		
Local oLayer
Local oPanelOwner
Local aRetFil

Local lNewC1E	:= GetNewPar( "MV_TAFCFGE", .F. )

Private oChart01	
Private oChart02	
Private oBrowse01	
Private oBrowse02	

Private cST2Alias
Private cXERPAlias
Private aArqTemp
Private aIndTemp

Private oBrowseLay
Private oBrowseKey 
Private oBrowseHis 
Private oHashLay
Default lProtData := .F.
Default aLisFil := { }
Default lChkFil := .F. 

oSize 	   	:= FwDefSize():New(.F.)
aSizeDlg	:= {}
aFolders	:= {}
aFolMon		:= {}
cTitulo		:= ""
nI			:= 0
aSize		:= {}
aSizeMV		:= {}
aErros  	:= {}
cFVIndiv	:= ""
cCodFil2	:= ""
nFI			:= 0
nFV		  	:= 0
nFil		:= 0
lBackPar	:= .F.
aButtons	:= {}
oPanelLeft	:= Nil 
oPanelRight	:= Nil 
oPanelDown	:= Nil
oPanelOwner	:= Nil

oChart01	:=	Nil
oChart02	:=	Nil
oBrowse01	:=	Nil
oBrowse02	:=	Nil

cST2Alias	:=	GetNextAlias()
cXERPAlias	:=	GetNextAlias()
aArqTemp	:=	{}
aIndTemp	:=	{}	

oBrowseLay 	:= Nil
oBrowseKey	:= Nil 
oBrowseHis	:= Nil 
oHashLay	:= Nil 
oLayer		:= Nil

if !lChkFil
	If findFunction("TAFGetFil")
		aRetFil := TAFGetFil(.F., .T.,"C20")
		aLisFil := {}
		For nFil := 1 to Len(aRetFil)
			Aadd(aLisFil, {.T., aRetFil[nFil] })
		Next nFil
	Else	
		aLisFil := MatFilCalc(.T.)
	EndIf
	
EndIf

cCodFil 	:= TafC1EFil(aLisFil, @cCodFil2)

If Select(cST2Alias) == 0
	xTAFCriaTB(,,"TAFST2" ,cST2Alias,,,,,,,,@aErros )
EndIf
If Select(cXERPAlias) == 0
	xTAFCriaTB(,,"TAFXERP",cXERPAlias,,,,,,,,@aErros )
EndIf

If !Empty( aErros )
	Aviso( STR0012, aErros[1,6], { STR0013 }, 3 ) //##"Erro Encontrado" ##"Ok"
Else	

	Define MsDialog oDlgMon Title STR0104 From oSize:aWindSize[1],oSize:aWindSize[2] To oSize:aWindSize[3],oSize:aWindSize[4]  Pixel STYLE nOR(WS_VISIBLE,WS_POPUP) //"Gerenciador de Integração"
	oDlgMon:lMaximized	:=	.T.
	
	If paramMIntegracao .And. paramMValidacao
		aFolMon	:= {STR0005,STR0006} //"Monitor de Integração"#"Monitor de Validação"
		nFI	:= 1
		nFV	:= 2
	ElseIf paramMIntegracao
		aFolMon	:= {STR0005} //"Monitor de Integração"
		nFI	:= 1
	ElseIf paramMValidacao
		aFolMon	:= {STR0006} //"Monitor de Validação"
		nFV	:= 1
	EndIf
	
	oTFMonitor := TFolder():New( 0,0,aFolMon,,oDlgMon,,,,.T.,,oSize:aWindSize[4]/2,oSize:aWindSize[3]/2)
	oTFMonitor:Align := CONTROL_ALIGN_ALLCLIENT
	
	If paramMIntegracao
	
		oFather := oTFMonitor:aDialogs[1]
	
		//*Folder Monitor de Integração
		aFolders := {STR0117,STR0118} //"Visão por lote"#"Visão individualizada"
		oTFVisao := TFolder():New( 0,0,aFolders,,oFather,,,,.T.,,oSize:aWindSize[4]/2,oSize:aWindSize[3]/2)
		oTFVisao:Align := CONTROL_ALIGN_ALLCLIENT
		
		//**Sub Folder Visão Por Lote
		TafMonVLote(.T.,.F.,oTFVisao:aDialogs[1],aParamT,oDlgMon,@lBackPar,cCodFil, cCodFil2)
		//**Sub Folder Visão Individualizada (pode ser por cadastro ou status, depende da parametrização)
		
		If lNewC1E .And. aParamT[6] == 1
			oLayer := FWLayer():New()
			oLayer:Init( oTFVisao:aDialogs[2] )
			oLayer:AddLine( "LINE01", 85 )
			oLayer:AddLine( "LINE02", 10 )

			oPanelOwner := oLayer:GetLinePanel("LINE01")
			FPanelMSG( oLayer:GetLinePanel("LINE02") )
		Else
			cFVIndiv 		:= IIf(paramVisaoTicket == 1,STR0119,STR0120) //"Por Cadastro"#"Por Status"
			oTFVisaoI 		:= TFolder():New( 0,0,{cFVIndiv},,oTFVisao:aDialogs[2],,,,.T.,,oSize:aWindSize[4]/2,oSize:aWindSize[3]/2)
			oTFVisaoI:Align := CONTROL_ALIGN_ALLCLIENT
			oPanelOwner		:= oTFVisaoI:aDialogs[1]
		EndIf

		//Panel da Visâo Individualizada
		aSize := FWGetDialogSize( oTFMonitor:aDialogs[1] )
		oPanVInd := TPanel():New(00,00,"",oPanelOwner,,.F.,.F.,,,0,0,.F.,.F.) 
		oPanVInd:Align = CONTROL_ALIGN_ALLCLIENT
		TafMonVInd(oPanVInd,aParamT,@lBackPar,oDlgMon,@oPanelLeft,@oPanelRight,@oPanelDown,cCodFil)  
		
	EndIf
	
	If paramMValidacao
		//*Folder Monitor de Validação
		TafMonVLote(.F.,.T.,oTFMonitor:aDialogs[nFV],aParamT,oDlgMon,@lBackPar,cCodFil, cCodFil2)
	EndIf
	
	Aadd( aButtons, {"",{||IIf(nFV == 1 .Or. (Len(aFolMon) == 2 .And. oTFMonitor:nOption == 2),Processa( { || FUpdPanel( ,,, .T.,aParamT,cCodFil), STR0007, STR0020 } )/*Atualização Monitor de Validação"*/; 
						 	, IIf(oTFVisao:nOption == 2,/*Atualização Monitor de Integração */; 
								(FWMsgRun(oPanelLeft ,{||oBrowseLay:RefazDadosTrb()},,STR0121); //"Atualizando Browse..."
								,FWMsgRun(oPanelRight,{||oBrowseKey:RefazDadosTrb()},,STR0121); //"Atualizando Browse..."
								,FWMsgRun(oPanelDown ,{||oBrowseHis::RefazDadosTrb()},,STR0121)); //"Atualizando Browse..."
								,Processa( { || FUpdPanel( ,, .T.,,aParamT,cCodFil), STR0007, STR0020 } )))},STR0121,STR0019, {||.T.}} ) //"Atualizando Browse..."#"Atualizar"
	
	Aadd( aButtons, {"",{||oDlgMon:End(),lBackPar := .T.},,STR0122, {||.T.}} ) //"Parâmetros"
	Aadd( aButtons,	{"",{|| TAFRINTEG()},,STR0211, {||.T.}} ) //"Exportar Tickets"
   	
	
	Activate MsDialog oDlgMon Centered	On Init EnchoiceBar (oDlgMon,,{||oDlgMon:End()},,@aButtons,,,.F.,.F.,.F.,.F.,.F.)  
	                                                                     
	
	
	(cST2Alias)->(dBCloseArea())
	(cXERPAlias)->(dBCloseArea())
	
	//----------------------------
	// Apaga arquivos temporários
	//----------------------------
	For nI := 1 to Len( aArqTemp )
		If Select(aArqTemp[nI][3]) > 0
			(aArqTemp[nI][3])->(dBCloseArea())
		EndIf
		If aArqTemp[nI][2] != Nil 
			aArqTemp[nI][2]:Delete() 
		EndIf
	Next nI
	
	TAFEncArr(@aSize)
	TAFEncArr(@aErros)
	TAFEncArr(@aArqTemp)
	TAFEncArr(@aIndTemp) 
	
	If paramMIntegracao
		oBrowseLay:LimpaTrb()
		oBrowseKey:LimpaTrb()
		oBrowseHis:LimpaTrb()
	EndIf
	
	If lBackPar .AND. lProtData
		If ProtData()
			TAFTicket(,,.F.)
		EndIf
	EndIf
EndIf

//Limpa temporária das filiais	
TafDelTmpFil()

//limpa query escalar das C1E
If FindFunction("TafDelScalar")
	TafDelScalar()
EndIf
Return Nil

//---------------------------------------------------------------------
/*/{Protheus.doc} TAFGTicket

Geração do código do Ticket.

@Return	cTicket	->	Código do Ticket

@Author	Felipe C. Seolin
@Since		19/03/2015
@Version	1.0
/*/
//---------------------------------------------------------------------
Function TAFGTicket()

Local cTicket as char

cTicket	:=	FWUUID( "TICKET" )

Return( cTicket ) 

//---------------------------------------------------------------------
/*/{Protheus.doc} TAFCodErr

Identifica os códigos e descrições de erro para integração.

@Return	aCodErro	->	Array com código e descrição de erro para integração.

@Author	Felipe C. Seolin
@Since		15/04/2015
@Version	1.0

@Altered By Luccas Curcio
 - 22/05/2017
 	Criação da posição [3] no array de retorno desta função, que contém as flags
 		'Q' - Indica que esta ocorrência de erro na integração é passível de retorno do registro para
 		a fila de integração.
 		'R' - Indica que esta ocorrência de erro na integração não é passível de retorno do registro para
 		a fila de integração, ou seja, o registro deve ser rejeitado imediatamente.
/*/
//---------------------------------------------------------------------
Function TAFCodErr()

Local aCodErro as array

aCodErro := {}

aAdd( aCodErro, { "000001", STR0043 , 'R' } ) //"Erro de estrutura, favor verificar o Layout TAF."
aAdd( aCodErro, { "000002", STR0044 , 'R' } ) //"Filial não cadastrada no Cadastro de Complemento de Empresa do TAF."
aAdd( aCodErro, { "000003", STR0045 , 'R' } ) //"Erro na exclusão do registro."
aAdd( aCodErro, { "000004", STR0046 , 'R' } ) //"Erro de integridade, registro não pode ser excluído."
aAdd( aCodErro, { "000005", STR0053 , 'R' } ) //"Erro de duplicidade de registro. Clique em Depurar para mais informações!"
aAdd( aCodErro, { "000006", STR0232 , 'R' } ) //"O arquivo importado está em desacordo com o cenário."
aAdd( aCodErro, { "000007", STR0058 , 'Q' } ) //"A operação solicitada no XML está em desacordo com o cenário do registro na base do TAF"
aAdd( aCodErro, { "000008", STR0059 , 'R' } ) //"Existem TAG´s do XML com informações duplicadas, a integração não será realizada"
aAdd( aCodErro, { "000009", STR0089 , 'R' } ) //"Registro não integrado. Duplo clique para mais informações!"
aAdd( aCodErro, { "000010", STR0061 , 'Q' } ) //'Para a integração dos eventos de alteração S-2205 ou S-2206, é necessário que exista o evento S-2100 ou S-2200 correspondente ao evento de alteração do trabalhador.'
aAdd( aCodErro, { "000011", STR0062 , 'Q' } ) //'Para a integração do evento de alteração S-2305 ou término S-2399, é necessário que exista o evento S-2300 correspondente ao evento de alteração ou término do trabalhador sem vínculo.'
aAdd( aCodErro, { "000012", STR0063 , 'R' } ) //'O evento de alteração do trabalhador integrado, S-2205 ou S-2206, possui um evento pai S-2100 ou S-2200 rejeitado pelo Governo.'
aAdd( aCodErro, { "000013", STR0064 , 'R' } ) //'O evento de alteração ou término do trabalhador sem vínculo integrado, S-2305 (Trabalhador Sem Vínculo - Alteração Contratual) ou S-2399 (Trabalhador Sem Vínculo - Término), possui o evento pai S-2300 (Trabalhador Sem Vínculo - Início) rejeitado pelo Governo.'
aAdd( aCodErro, { "000014", STR0060 , 'R' } ) //'Existe um registro com essa mesma chave e com data término em branco'
aAdd( aCodErro, { "000015", STR0097 , 'R' } ) //"Existem campos da chave que não foram enviados na mensagem, não foi possível realizar a integração deste registro"                                                                                                                                                                                                                                                                                                                                                                                                 
aAdd( aCodErro, { "000016", STR0098 , 'Q' } ) //'Ocorreu um erro interno do sistema durante a integração deste registro, tente novamente'
aAdd( aCodErro, { "000017", STR0100 , 'R' } ) //'Não é possível integrar um evento de Alteração quando houver uma Finalização ativa.'
aAdd( aCodErro, { "000018", STR0101 , 'R' } ) //'Não é possível integrar este evento, pois existe um 'Cancelamento' ativo para este Afastamento.'
aAdd( aCodErro, { "000019", STR0095 , 'Q' } ) //'Não é permitido a integração deste evento, enquanto houver outra alteração pendente de transmissão'
aAdd( aCodErro, { "000020", STR0099 , 'R' } ) //'Não é possível integrar um evento de retificação, referente ao Início do Afastamento, quando houver uma Alteração ou Finalização ativa'
aAdd( aCodErro, { "000021", STR0154 , 'Q' } ) //"Erro de Concorrência - Não foi possível realizar a gravação do registro pois estava reservado por outro usuário'   
aAdd( aCodErro, { "000022", STR0165 , 'R' } ) //'Erro de chave duplicada, favor verificar as informações que estão sendo integradas.'
aAdd( aCodErro, { "000023", STR0183 , 'Q' } ) //'O evento de alteração ou término do trabalhador sem vínculo integrado, S-2305 ou S-2399, possui o evento pai S-2300 aguardando retorno do Governo.' 
aAdd( aCodErro, { "000024", STR0184 , 'Q' } ) //'O evento de alteração do trabalhador integrado, S-2205 ou S-2206, possui um evento pai S-2100 ou S-2200 aguardando retorno do Governo.'
aAdd( aCodErro, { "000025", STR0189 , 'Q' } ) //'Não é permitido a integração deste evento, enquanto outro estiver pendente de transmissão.' 
aAdd( aCodErro, { "000026", STR0195 , 'R' } ) //'Exclusão direta de Evento no TAF - A chave do evento enviado no S-3000 não estava transmitida ao Governo.'
aAdd( aCodErro, { "000027", STR0197 , 'R' } ) //"Para a integração do evento de término S-2399 (Trabalhador Sem Vínculo - Término), é necessário que exista o evento S-2300 (Trabalhador Sem Vínculo - Início) correspondente ao evento de término do trabalhador sem vínculo." 
aAdd( aCodErro, { "000028", STR0198 , 'R' } ) //"O evento S-2399 (Trabalhador Sem Vínculo - Término), possui o evento pai S-2300 (Trabalhador Sem Vínculo - Início) rejeitado pelo Governo."
aAdd( aCodErro, { "000029", STR0199 , 'R' } ) //"O evento S-2399 (Trabalhador Sem Vínculo - Término), possui o evento pai S-2300 (Trabalhador Sem Vínculo - Início) não se encontra válido ou transmitido com sucesso ao RET." 
aAdd( aCodErro, { "000030", STR0227 , 'Q' } ) //"Registro não integrado devido erro de Predecessão. Duplo clique para mais informações!" 
aAdd( aCodErro, { "000031", STR0230 , 'Q' } ) //"Registro em desacordo com as regras do evento afastamento (S-2230). Duplo clique para mais informações!" 
aAdd( aCodErro, { "000032", STR0243 , 'R' } ) //"Mensagem com encoding incorreto ou conteúdo vazio. " 

Return( aCodErro )

//---------------------------------------------------------------------
/*/{Protheus.doc} TafGrvTick

Executa a gravação de dados na tabela TAFXERP.

@Param		cXERPAlias	->	Alias referente à tabela TAFXERP 
			cOper		->	Indica a operação à ser realizada
			cKey		->	Código da Chave
			cTicket	->	Código do Ticket
			cAlias		->	Alias referente ao cadastro do TAF
			nRecno		->	Registro referente ao Alias do cadastro do TAF
			cStatus	->	Informa o status do registro
			cCodErro	->	Indica o código de erro para registros inconsistentes
			cErro		->	Mensagem de erro referente a falha na integração

@Author	Felipe C. Seolin
@Since		20/03/2015
@Version	1.0
/*/
//---------------------------------------------------------------------
Function TafGrvTick( cXERPAlias as character, cOper as character, cKey as character, cTicket as character, cAlias as character,;
					 nRecno as numeric, cStatus as character, cCodErro as character, cErro as character, cCodAlt as character,;
					 lDel as logical, lExclCMJ as logical )

	Local lLock         as logical
	Local lGrvHFila     as logical
	Local lXERPAliasDef as logical
	Local nTamTicket    as numeric
	Local nTamKey       as numeric

	Default cCodAlt    := ""
	Default lDel       := .F.
	Default lExclCMJ   := .F.

	nTamTicket    := 0
	nTamKey       := 0
	lGrvHFila     := .F.
	lXERPAliasDef := .F.


	If Empty(cXERPAlias) .Or. Select(cXERPAlias) <= 0
		cXERPAlias := GetNextAlias()
		xTAFCriaTB(,, "TAFXERP", cXERPAlias)
		lXERPAliasDef := .T.
	EndIf

	// Se for uma exclusão de não transmitido, zero o recno para não referenciar
	// o registro errado na TAFXERP
	If (cAlias == "CMJ" .Or. cAlias == "V7J")  .AND. cOper == '1' .AND. lExclCMJ
		nRecno := 0
		cStatus:= "3"
	EndIf 

	lGrvHFila := SuperGetMv('MV_TAFHFIL',.F.,.F.) .Or. IsBlind()

	If lGrvHFila .And. cStatus == "4" 

		nTamTicket := Len((cXERPAlias)->TAFTICKET)
		nTamKey := Len((cXERPAlias)->TAFKEY) 

		(cXERPAlias)->(dBSetOrder(1))
		If (cXERPAlias)->(MsSeek(PADR(cTicket,nTamTicket)+PADR(cKey,nTamKey)))
			lLock := .F. 
			cOper := "2"
		Else
			lLock := .T. 
		EndIf 

	Else
		lLock	:=	Iif( cOper == "1", .T., .F. )
	EndIf

	if !empty(cCodAlt)
		cStatus := cCodAlt
	endif

	//Inclusão
	If cOper == "1"

		//tratamento para gravar o ticket correto no key da C20 apos exclusao
		if cAlias == "C20" .And. lDel
			cStatus := '1'
		endif

		If RecLock( cXERPAlias, lLock )

			( cXERPAlias )->TAFDATA		:=	Date()
			//Caso seja uma integração nativa eu gravo a hora 00:00:00 para manter um único ticket para todas as integrações na mesma data.
			( cXERPAlias )->TAFHORA		:=	If(Type('lIntTAF') == 'L' .and. lIntTAF,"00:00:00",Time()) 
			( cXERPAlias )->TAFKEY		:=	cKey
			( cXERPAlias )->TAFTICKET	:=	cTicket
			( cXERPAlias )->TAFALIAS	:=	cAlias
			( cXERPAlias )->TAFRECNO	:=	nRecno
			( cXERPAlias )->TAFSTATUS	:=	cStatus
			( cXERPAlias )->TAFCODERR	:=	cCodErro
			( cXERPAlias )->TAFERR		:=	cErro

			( cXERPAlias )->( MsUnLock() )

		EndIf

	//Alteração
	ElseIf cOper == "2"

		If RecLock( cXERPAlias, lLock )
			//Quando for Fila só faço update da data e hora.
			If cStatus == "4" 
				( cXERPAlias )->TAFDATA		:=	Date()
				( cXERPAlias )->TAFHORA		:=	Time()
			Else 
				( cXERPAlias )->TAFSTATUS	:=	cStatus
			EndIf 
			( cXERPAlias )->( MsUnLock() )
			
			//Volto para o Indice Definido na TAFAINTEG
			(cXERPAlias)->(dBSetOrder(2))
		EndIf

	EndIf

	If lXERPAliasDef == .T.
		(cXERPAlias)->(dbCloseArea())
	EndIf

Return()

//---------------------------------------------------------------------
/*/{Protheus.doc} TAFExcKey

Rotina para verificar existência de registro na base de dados e excluí-lo.

@Param		cXERPAlias	->	Alias referente à tabela TAFXERP
			cLayout	->	Indica qual o Layout referente ao registro
			aLayDef	->	Array com a estrutura do arquivo Layout.def

@Return	lDel		->	Indica se a exclusão foi realizada com sucesso

@Author	Felipe C. Seolin
@Since		22/04/2015
@Version	1.0
/*/
//---------------------------------------------------------------------
Function TAFExcKey( cXERPAlias, cLayout, aLayDef, cTafFil )

Local cAlias	as char
Local cEscopo	as char
Local cAntKey	as char
Local nRecno	as numeric  
Local nLstRec	as numeric
Local nTamKey	as numeric
Local aArea		as array
Local aRegExc	as array 
Local aCU0		as array 
Local lDel		as logical
Local lExc      as logical

Default cLayout := " "
Default aLayDef := {}
Default cTafFil	:= " "

cAlias		:=	""
cEscopo		:=	""
cAntKey		:=  ""
nRecno		:=	0
nLstRec 	:=  0
nTamKey		:=  0
aArea		:=	( cXERPAlias )->( GetArea() )
aRegExc		:=	{}
aCU0		:=	{}
lDel		:=	.F.
lExc        :=  .F.
	
//Tratamento para posicionar corretamente no ticket da TafXERP, caso a nota seja excluida manualmente no TAF.
if cLayout == 'T013'
	nTamKey := Len( (cXERPAlias)->TAFKEY ) 
	cAntKey := ( cXERPAlias )->TAFKEY

	if Upper(AllTrim((cXERPAlias)->(IndexKey(IndexOrd())))) <> "TAFKEY"
		(cXERPAlias)->(dBSetOrder(2))
	endif

	(cXERPAlias)->(DbGoTop())
	If (cXERPAlias)->( DbSeek( PADR( cAntKey , nTamKey ) ) )
		While ( cXERPAlias )->(!EOF()) .And. ( cXERPAlias )->TAFKEY == cAntKey
			nLstRec := ( cXERPAlias )->(recno())
			( cXERPAlias )->(DbSkip())
		EndDo
	EndIf

	if nLstRec > 0 //Mantenho posicionado no ultimo key valido da TafXERP
		( cXERPAlias )->( DbGoTo(nLstRec) )
		If ( cXERPAlias )->TAFALIAS == "C20" .And. ( cXERPAlias )->TAFSTATUS $ "1|2"
			lExc := .T. 
		endif
	endif

	//caso nao localize o registro esperado restauro com o checkpoint e sigo o fluxo
	if !lExc
		RestArea( aArea )  
	endif
endif
 
If ( cXERPAlias )->TAFSTATUS $ "1|2" .Or. lExc

	cAlias := ( cXERPAlias )->TAFALIAS
	nRecno := ( cXERPAlias )->TAFRECNO
 
	cEscopo := TAFRotinas( cAlias, 3, .F., 0 )[5]

	aAdd( aRegExc, { cLayout, cAlias, nRecno, cEscopo } )

	TAFExcReg( ,, aRegExc, aLayDef, .T., cTafFil, @lDel )
	if lDel
		TafGrvTick( cXERPAlias, "2",,,,, "3" )

		aAdd( aCU0, { cAlias, nRecno } )
		GravaCU0( 3, aCU0 )
	endif

EndIf

RestArea( aArea )

TAFEncArr( @aArea )
TAFEncArr( @aRegExc )
TAFEncArr( @aCU0 )

Return( lDel )

/*/{Protheus.doc} FSalvProf
Grava os Parâmentros em um arquivo de profile
@author evandro.oliveira
@since 07/04/2016
@version 1.0
@return ${boolean}, ${A função MemoWrite Retorna True ou False}
/*/
Static Function FSalvProf(aParamT)

Local 	nX			as numeric
Local 	cWrite		as char
Local	cBarra		as char
Local	lRet		as logical	    
Local	cUserName	as char
Local   cNomeProf 	as char

nX			:=	0
cWrite		:= 	""
cBarra		:= 	If ( IsSrvUnix () , "/" , "\" )
lRet		:=	.F.	    
cUserName	:= __cUserID
cNomeProf 	:= ""

If !ExistDir ( cBarra + "PROFILE" + cBarra )
	MakeDir ( cBarra + "PROFILE" + cBarra )
EndIf

For nX := 1 to Len(aParamT)
	cWrite 	+= 	"{"+FConvType(aParamT[nX]) + ",'" + ValType(aParamT[nX]) + "'}" + CRLF
Next

cNomeProf	:=	FunName() +"_" +cUserName
	
Return (MemoWrite ( cBarra + "PROFILE" + cBarra + Alltrim ( cNomeProf ) + ".PRB" , cWrite ))

/*/{Protheus.doc} FConvType
Verifica o Tipo de dado do parâmetro e o retorna 
em uma String.
@author evandro.oliveira
@since 07/04/2016
@version 1.0
@param cPar, character, (Valor do Parâmetro)
@return ${string}, ${string com o tipo de dado}
/*/
Static Function FConvType(cPar)

Local cString as char

cString := ""

If ValType(cPar) == "L"
	cString := IIf(cPar,'.T.','.F.')
ElseIf ValType(cPar) == "D"
	cString := "'" + DTOC(cPar)	+ "'"
ElseIf ValType(cPar) == "N"
	cString := AllTrim(Str(cPar))
ElseIf ValType(cPar) == "C"
	cString := cPar
Else
	MsgInfo(STR0123) //"Problemas na tentativa de gravar o profile dos parâmetros."
EndIf
	
Return cString

/*/{Protheus.doc} FLoadProf
Lê o arquivo de profile e "alimenta" os parâmetros
@author evandro.oliveira
@since 07/04/2016
@version 1.0
@return ${lRetorno}, ${Informa se a rotina foi executada com sucesso}
/*/
Static Function FLoadProf(aParamT)

Local nJ		:=	0
Local cBarra 	:= 	Iif ( IsSrvUnix() , "/" , "\" )
Local cUserName	:= __cUserID
Local cNomeProf := ""
Local aParLoad	:= {}
Local lRetorno	:= .F.

Private cLinha	:=	""

If !ExistDir ( cBarra + "PROFILE" + cBarra )
	Makedir ( cBarra + "PROFILE" + cBarra )
EndIf

cNomeProf	:=	FunName() +"_" +cUserName
If File ( cBarra + "PROFILE" + cBarra + Alltrim ( cNomeProf ) + ".PRB" )

	If FT_FUse ( cBarra + "PROFILE" + cBarra + Alltrim ( cNomeProf ) + ".PRB" ) <> -1

		FT_FGoTop ()
		While ( !FT_FEof () )
			cLinha := FT_FReadLn () 
			aAdd(aParLoad,&(cLinha))
			FT_FSkip ()
		Enddo		
		If FT_FUse() != -1
			lRetorno := .T.
		EndIf
		
		If Len(aParLoad) == Len(aParamT)
			For nJ := 1 To Len(aParLoad)		
				If aParLoad[nJ][2] == "D"
					aParamT[nJ] := CTOD(aParLoad[nJ][1])
				Else
					aParamT[nJ] := aParLoad[nJ][1]
				EndIf	
			Next nJ
		Else
			lRetorno := .F.
		EndIf
	EndIf
EndIf
Return (lRetorno)

/*/{Protheus.doc} TafC1EFil
Retorna o codigo das filiais cadastradas no complemento de empresa
@author evandro.oliveira
@since 05/06/2016
@version 1.0
@return ${cCodFil}, ${String contendo os codigos das filiais separados
por vígula}
/*/
Static Function TafC1EFil(aLisFil, cCodFil2)

	Local cCodFil		as character
	Local nX			as numeric
	Local nTemp			as numeric
	Local aCodFil		as array
	Local cBkpFilAnt	as character	
	Local nTamFil		as numeric
	Local nTamEmp		as numeric
	Local nLimTmp		as numeric
	Local cTmpFil		as character
	Local cInsertValue  as character
	Local cInsert		as character
	Local cTable		as character
	Local nAfil			as numeric
	Local aStruTmp		as array
	Local naListFil		as numeric

	default aLisFil	:=	{}
	default cCodFil2 := ""
	
	cCodFil		:=	""
	cBkpFilAnt	:=	cFilAnt
	nX			:=	0
	nTemp		:=	0
	aCodFil		:=	{}
	nLimTmp 	:= 50
	naListFil   := len(aLisFil)

	if naListFil > 0
		for nX := 1 to naListFil
			if aLisFil[nX][1]	
				cFilAnt := aLisFil[nX][2]
				aFiltemp :=	TAFCodFilErp()
				for nTemp := 1 to  len(aFiltemp )
					aadd(aCodFil,{aFiltemp[nTemp],aLisFil[nX][2]})
				next
				nTemp 		:= 0
				aFiltemp	:=	{} 
			endif
		next
	else
		aFiltemp :=	TAFCodFilErp()
		If Len(aFiltemp) > 0
			aadd(aCodFil,{aFiltemp[1],cFilAnt})
		EndIf	
	endif

	If Len( aCodFil ) == 0
		TAFConout( ProcName() + " - " + STR0082,3,.T.,"INTEG" ) //"Tabela C1E sem cadastro de filiais."
		//Tratamento para evitar erro na Clausula IN ( SQL )
		cCodFil := Iif( Empty( AllTrim( cCodFil ) ), "''", cCodFil )
	Else

		nAfil := Len(aCodFil)	
		If nAfil <= nLimTmp	
			//Atribuo as filiais ( TAFFIL ) relacionadas a empresa que executou
			//o Job a uma string que será utilizada na cláusula WHERE
			For nX := 1 to Len( aCodFil )
				cCodFil += "'" + AllTrim( aCodFil[nX][1] ) + "', "
				cCodFil2 += "'" + AllTrim( aCodFil[nX][2] ) + "', "
			Next nX

			//Retiro os dois últimos caracteres ", "
			cCodFil := SubStr( cCodFil, 1, Len( cCodFil ) - 2 )
			cCodFil2 := SubStr( cCodFil2, 1, Len( cCodFil2 ) - 2 )
		Else

			cTmpFil := GetNextAlias()
			nTamFil := Len(xFilial("C1E"))
			nTamEmp := Len(cEmpAnt)
			cTable := ""
			aStruTmp := {}

			If __oTmpFil <> Nil 
				__oTmpFil:Delete()
				__oTmpFil := Nil
			Endif

			aAdd( aStruTmp, {'TMPFIL','C',nTamFil+nTamEmp,0} )
			aAdd( aStruTmp, {'TMPFIL2','C',nTamFil,0} )
					
			__oTmpFil := FwTemporaryTable():New( cTmpFil )
			__oTmpFil:SetFields( aStruTmp )
			__oTmpFil:AddIndex( '01', {'TMPFIL'} )
			__oTmpFil:AddIndex( '02', {'TMPFIL2'} )
			__oTmpFil:Create()


			cTable	:= __oTmpFil:GetRealName()
						
			cInsert := " INSERT INTO " + cTable  + "  (TMPFIL, TMPFIL2)  "
			For nX := 1 to Len(aCodFil)
				cInsertValue := " VALUES ('" + AllTrim( aCodFil[nX][1] ) + "','" + aCodFil[nX][2] + "')  "
				TcSqlExec( cInsert + cInsertValue)
			Next nX                      

			( cTmpFil )->(DbGoTop())

			If Upper(TcGetDb()) $ "MSSQL7"
				cTable := StrTran (cTable,'dbo.') 
			EndIf

			cCodFil := " SELECT TMPFIL FROM " + cTable + " "
			cCodFil2 := " SELECT TMPFIL2 FROM " + cTable + " "
		EndIf
		aSize(aCodFil,0)
		
	EndIf
	
	if  !empty(cBkpFilAnt) .and. cBkpFilAnt <> cFilAnt
		cFilAnt := cBkpFilAnt
	endif	

Return cCodFil

//-------------------------------------------------------------------
/*/{Protheus.doc} TafDelTmpFil()

Limpa a tabela temporária criada para seleção de filiais

@author Karen
@since 07/06/2021
@version 1.0

/*/ 
//-------------------------------------------------------------------
Static Function TafDelTmpFil() As Character
	If __oTmpFil <> Nil
		__oTmpFil:Delete()
		__oTmpFil := Nil
	Endif
Return
//-------------------------------------------------------------------
//---------------------------------------------------------------------
/*/{Protheus.doc} FGetDuplic

Interpreta a mensagem de integração e analisa linhas duplicadas.

@Param		oBrowse		-> Browse em execução
			lPosiciona		-> Indica se deve realizar o posicionamento na tabela TAFST2, se .F. já esta posicionado
			lShowAllMsg	-> Indica se deve retornar todas as linhas duplicadas na mensagem
			aDadosST2		-> Array com as informações populadas
			lTafErrorLog	-> Variável de controle do erro utilizada na TAFPROCMT

@Return	cMensagem		->	Mensagem interpretada de linhas duplicadas

@Author	Felipe C. Seolin
@Since		15/03/2016
@Version	1.0
/*/
//---------------------------------------------------------------------
Function FGetDuplic( oBrowse, lPosiciona, lShowAllMsg, aDadosST2, lTafErrorLog, aLayout, aTamSx3 )

Local oHash			as object
Local cAlias		as character
Local cRegistro		as character
Local cLine			as character
Local cEnter		as character
Local cChannel		as character
Local cCpoAlias		as character
Local cUniqueKey	as character
Local cFldsIndex	as character
Local cType			as character
Local cKey			as character
Local cMensagem		as character
Local cChave		as character
Local nRecno		as numeric
Local nI			as numeric
Local nJ			as numeric
Local nK			as numeric
Local nChannel		as numeric
Local nSeq			as numeric
Local nTmSX3		as numeric
Local aFldsIndex	as array
Local aLines		as array
Local aDuplicate	as array
Local aMensagem		as array
Local aArea			as array
Local aSource		as array
Local aRet			as array
Local aX2Unico		as array

Local bTafError		as codeblock

Default lPosiciona	 := .T.
Default lShowAllMsg	 := .T.
Default aDadosST2	 := {}
Default lTafErrorLog := .F.
Default aLayout		 := {}
Default aTamSx3		 := {}

oHash		:=	Nil
cAlias		:=	""
cRegistro	:=	""
cLine		:=	""
cEnter		:=	Chr( 13 ) + Chr( 10 )
cChannel	:=	""
cCpoAlias	:=	""
cUniqueKey	:=	""
cFldsIndex	:=	""
cType		:=	""
cKey		:=	""
cMensagem	:=	""
cChave		:=	""
nRecno		:=	0
nI			:=	0
nJ			:=	0
nK			:=	0
nChannel	:=	0
nSeq		:=	0
nTmSX3 		:=  0
aFldsIndex	:=	{}
aLines		:=	{}
aDuplicate	:=	{}
aMensagem	:=	{}
aArea		:=	{}
aSource		:=	{}
aRet		:=	{}
aX2Unico	:=	{}
bTafError	:=	ErrorBlock( { |Obj| FErrorTaf( Obj, @lTafErrorLog ) } ) //Tratamento para error log

If lPosiciona

	cAlias		:=	oBrowse:Alias()
	aDadosST2	:=	{}
	aArea		:=	( cST2Alias )->( GetArea() )
	nRecno		:=	( cAlias )->RECNOST2
	( cST2Alias )->( DBGoTo( nRecno ) )
	cChave		:=	( cST2Alias )->TAFKEY
	( cST2Alias )->( DBSetOrder( 3 ) )
	( cST2Alias )->( MsSeek( TAFSTATUS + TAFCODMSG + TAFKEY + "001" ) ) //Posiciona na primeira seqüência para correr para as demais

	While ( cST2Alias )->TAFKEY == cChave
		// -----------------------------------------------
		// Quebra a mensagem completa em linhas e colunas
		// -----------------------------------------------
		cRegistro := Upper( ( cST2Alias )->TAFMSG )
	
		While .T.
			If SubStr( cRegistro, 1, 1 ) = "|"
				cRegistro := SubStr( cRegistro, 2 )
			EndIf
	
			If At( cEnter, cRegistro ) > 0
				cLine := SubStr( cRegistro, 1, At( cEnter, cRegistro ) - 1 )
			Else
				cLine := cRegistro
			EndIf
	
			aAdd( aDadosST2, Str2Arr( cLine, "|" ) )
			aAdd( aMensagem, cLine )
	
			cRegistro := SubStr( cRegistro, Len( cLine ) + 3 )
	
			If Empty( cRegistro )
				Exit
			EndIf
		EndDo
		( cST2Alias )->(DBSkip())
	EndDo

EndIf

// ----------------------------------------------------------------------
// Processa as linhas, identificando as colunas que fazem parte da chave
// ----------------------------------------------------------------------
For nI := 1 to Len( aDadosST2 )

	nSeq += 1 //Identifica a linha da mensagem

	cChannel := iif(aDadosST2[nI,1] = 'T999',aDadosST2[nI,2],aDadosST2[nI,1]) 

	//Carrega o respectivo layout, verificando se já não está em memória
	If nI == 1
		If Empty( aLayout ) .or. ( AllTrim( SubStr( aLayout[1,Z1_DESC], 1, At( "-", aLayout[1,Z1_DESC] ) - 1 ) ) <> cChannel .and. lPosiciona )
			aLayout := TAFLoadLay( cChannel )
		EndIf
		nFather := aScan( aLayout, { |x| AllTrim( SubStr( x[Z1_DESC], 1, At( "-", x[Z1_DESC] ) - 1 ) ) == cChannel } )
	EndIf

	nChannel := aScan( aLayout[nFather][Z1_CHANELS], { |x| AllTrim( x[Z2_CHANEL] ) == cChannel } )

	If nChannel > 0
		cCpoAlias := SubStr( aLayout[nFather][Z1_CHANELS][nChannel][Z3_FIELDS][1][Z4_FIELD], 1, 3 )
		cKey := ""

		aX2Unico := FwSX2Util():GetSX2data(cCpoAlias, {'X2_UNICO'})
		if len(aX2Unico) > 0
			cUniqueKey := alltrim( aX2Unico[1][2] )
			aX2Unico := {}
		endif	

		cFldsIndex := cUniqueKey
		cFldsIndex := StrTran( cFldsIndex, "DTOS(", "" )
		cFldsIndex := StrTran( cFldsIndex, "STR(", "" )
		cFldsIndex := StrTran( cFldsIndex, ")", "" )
	
		aFldsIndex := Str2Arr( cFldsIndex, "+" )
	
		//Laço para interpretar as informações que fazem parte da chave
		For nJ := 1 to Len( aFldsIndex )
	
			//Tratamento para retirar possíveis "vírgulas" deixadas pela função Str
			aFldsIndex[nJ] := IIf( ( nPosAux := At( ",", aFldsIndex[nJ] ) ) > 0, SubStr( aFldsIndex[nJ], 1, nPosAux - 1 ), aFldsIndex[nJ] )
	
			nFoundCpo := aScan( aLayout[nFather][Z1_CHANELS][nChannel][Z3_FIELDS], { |x| AllTrim( x[Z4_FIELD] ) == AllTrim( aFldsIndex[nJ] ) } )
	
			If nFoundCpo > 0

				If At( ";", aLayout[nFather][Z1_CHANELS][nChannel][Z3_FIELDS][nFoundCpo][Z4_SOURCE] ) > 0
					cAuxKey := ""
					aSource := Str2Arr( aLayout[nFather][Z1_CHANELS][nChannel][Z3_FIELDS][nFoundCpo][Z4_SOURCE], ";" )
					For nK := 1 to Len( aSource )
						//Tratamento para quando o campo seja numérico e faça parte da chave, seja alterado
						//o valor de "," para ".", para que o Seek não falhe, duplicando as informações.
						If aLayout[nFather][Z1_CHANELS][nChannel][Z3_FIELDS][nFoundCpo][Z4_TYPFLD] == "N"
							If Len( aDadosST2[nI] ) >= Val( aSource[nK] )
								cAuxKey += StrTran( aDadosST2[nI][Val( aSource[nK] )], ",", "." )
							EndIf
						Else
							If Len( aDadosST2[nI] ) >= Val( aSource[nK] )
								cAuxKey += aDadosST2[nI][Val( aSource[nK] )]
							EndIf
						EndIf
					Next nK

					If !Empty( cAuxKey )
						if lTafX3
							nTmSX3 := TafTmSx3( alltrim(aLayout[nFather][Z1_CHANELS][nChannel][Z3_FIELDS][nFoundCpo][Z4_FIELD]), aTamSx3 )
						else
							nTmSX3 := TamSX3( aLayout[nFather][Z1_CHANELS][nChannel][Z3_FIELDS][nFoundCpo][Z4_FIELD] )[1]
						endif
						If Len( cAuxKey ) < nTmSX3
							cKey += PadR( cAuxKey, nTmSX3 )
						Else
							cKey += cAuxKey
						EndIf
					EndIf
				Else
					//Tratamento para campo numérico e parte da chave.
					//Será alterado o valor de "," para ".", para que o Seek não falhe, duplicando as informações.
					cAuxKey := ""
					If aLayout[nFather][Z1_CHANELS][nChannel][Z3_FIELDS][nFoundCpo][Z4_TYPFLD] == "N"
						If Len( aDadosST2[nI] ) >= Val( aLayout[nFather][Z1_CHANELS][nChannel][Z3_FIELDS][nFoundCpo][Z4_SOURCE] )
							cAuxKey := StrTran( aDadosST2[nI][Val( aLayout[nFather][Z1_CHANELS][nChannel][Z3_FIELDS][nFoundCpo][Z4_SOURCE] )], ",", "." )
						EndIf
					Else
						If Len( aDadosST2[nI] ) >= Val( aLayout[nFather][Z1_CHANELS][nChannel][Z3_FIELDS][nFoundCpo][Z4_SOURCE] )
							cAuxKey := aDadosST2[nI][Val( aLayout[nFather][Z1_CHANELS][nChannel][Z3_FIELDS][nFoundCpo][Z4_SOURCE] )]
						EndIf
					EndIf

					If !Empty( cAuxKey )
						if lTafX3
							nTmSX3 := TafTmSx3( alltrim( aLayout[nFather][Z1_CHANELS][nChannel][Z3_FIELDS][nFoundCpo][Z4_FIELD] ), aTamSx3 )
						else
							nTmSX3 := TamSX3( aLayout[nFather][Z1_CHANELS][nChannel][Z3_FIELDS][nFoundCpo][Z4_FIELD] )[1]
						endif
						If Len( cAuxKey ) < nTmSX3
							cKey += PadR( cAuxKey, nTmSX3 )
						Else
							cKey += cAuxKey
						EndIf
					EndIf
				EndIf
			EndIf
		Next nJ
	Endif

	//Estrutura lógica para identificação de mudança na posição hierárquica do registro
	If nI > 1 .and. aLines[nI - 1,2] <> cChannel
		cType := AllTrim( Str( Val( cType ) + 1 ) )
	EndIf
	
	aAdd( aLines, { nSeq, cChannel, cType + cKey } )

Next nI

// --------------------------------------------------------------------
// Compara todas as linhas verificando existência de chaves duplicadas
// --------------------------------------------------------------------

oHash := AToHM( aLines, 3, 0 )

For nI := 1 to Len( aLines )
	If aLines[nI][2] <> "T082AC" .and. aLines[nI][2] <> "T156AB" .and. aLines[nI][2] <> "T156AC" .and. aLines[nI][2] <> "T020AA" 
		
		cKey := aLines[nI,3]

		If HMGet( oHash, cKey, @aRet ) .and. Len( aRet ) > 1 
			aAdd( aDuplicate, nI )
		EndIf
		
	EndIf
Next nI

If lShowAllMsg
	// -------------------------------------------------------------------------
	// Monta a mensagem a ser exibida com a identificação das linhas duplicadas
	// -------------------------------------------------------------------------
	For nI := 1 to Len( aMensagem )
		If aScan( aDuplicate, { |x| x == nI } ) > 0
			cMensagem += STR0086 + " -> |" + aMensagem[nI] + cEnter //"Linha duplicada"
		Else
			cMensagem += "                              |" + aMensagem[nI] + cEnter
		EndIf
	Next nI

	TAFEncArr( @aDadosST2 )
Else
	If Len( aDuplicate ) > 0
		cMensagem := "Chave Duplicada no TAFKEY "
	EndIf
EndIf

If !Empty( aArea )
	RestArea( aArea )
EndIf

TAFEncArr( @aFldsIndex )
TAFEncArr( @aLines )
TAFEncArr( @aDuplicate )
TAFEncArr( @aMensagem )
TAFEncArr( @aArea )

ErrorBlock( bTafError )

Return( cMensagem )

//-------------------------------------------------------------------
/*/{Protheus.doc} TAF433SXB

Função para execução das Consultas Especificas do Evento Tributário.

@Param		cTitle		- Título da Tela de Consulta Específica
			cAlias		- Alias da Tabela Temporária criada
			cReadVar	- Campo em memória que receberá o retorno da Consulta Específica
			cChave		- Campo(s) a serem gravados no campo em memória
			aColuns	- Colunas que serão utilizadas na Consulta Específica
			aSeek		- Índice de pesquisas serão utilizadas na Consulta Específica
			lMult		- Indica se a tela permitirá seleção de múltiplos registros

@Author	Felipe C. Seolin
@Since		12/08/2015
@Version	1.0
/*/                                                                                                                                          
//-------------------------------------------------------------------
Function TAFTICSXB( cTitle, cAlias, cReadVar, cChave, aColumns, aSeek )

Local oDlg		as object
Local oBrowse	as object
Local nTop		as numeric
Local nLeft		as numeric
Local aSize		as array
Local bConfirm	as codeblock
Local bClose	as codeblock

Default aSeek	:=	{}

oDlg		:=	Nil
oMrkBrowse	:=	Nil
nTop		:=	0
nLeft		:=	0
aSize		:=	FWGetDialogSize( oMainWnd )
bConfirm	:=	{ || FConfirm( oBrowse, cReadVar, cChave ), oDlg:End() }
bClose		:=	{ || oDlg:End() }

nTop	:=	( aSize[1] + aSize[3] ) / 5
nLeft	:=	( aSize[2] + aSize[4] ) / 5

If ( cAlias )->( !Eof() )

	oDlg := MsDialog():New( nTop, nLeft, aSize[3], aSize[4], cTitle,,,,,,,,, .T.,,,, .F. )

	oBrowse := FWMBrowse():New()

	oBrowse:SetOwner( oDlg )

	//Tipo de dados
	oBrowse:SetTemporary()
	oBrowse:SetAlias( cAlias )

	//Configuração de colunas
	oBrowse:SetColumns( aColumns )

	//Configuração de opções
	oBrowse:SetMenuDef( "" )
	oBrowse:DisableReport()
	oBrowse:DisableConfig()
	oBrowse:SetDoubleClick(bConfirm)
	oBrowse:SetWalkThru( .F. )
	oBrowse:SetAmbiente( .F. )

	If !Empty( aSeek )
		oBrowse:SetSeek( .T., aSeek )
	Else
		oBrowse:SetSeek()
	EndIf

	oBrowse:AddButton( "Sair", bClose ) //"Sair"
	oBrowse:AddButton( "Confirmar", bConfirm ) //"Confirmar"

	oBrowse:Activate()

	oDlg:Activate()

Else
	Help( " ", 1, "RECNO" )
EndIf

Return()


//---------------------------------------------------------------------
/*/{Protheus.doc} ConsCDER
Consulta Específica para Exibir Códigos de Erros do Taf no reltáorio de erros TAFRINTEG
@Return	.T.
@Author	Wagner Soares
@Since		12/04/2018
@Version	1.0

/*/
//---------------------------------------------------------------------
Function ConsCDER()

Local cTempTab	as character
Local cCampos	as character
Local cChave	as character
Local cTitle	as character
Local cReadVar	as character
Local nPos		as numeric
Local nI		as numeric
Local aStruct	as array
Local aColumns	as array
Local aAux		as array
Local aIndex	as array
Local aSeek		as array
Local aCodigo	as array
Local aDescri	as array
Local oTmpTab	as object

cTempTab	:=	""
cCampos		:=	"TMP_CODIGO|TMP_DESCRI"
cChave		:=	"TMP_CODIGO"
cTitle		:=	"Códigos de Erro TAF"
cReadVar	:=	ReadVar()
cCombo		:=	""
cSelect		:=	""
cFrom		:=	""
cWhere		:=	""
cOrderBy	:=	""
nPos		:=	0
nI			:=	0
aStruct		:=	{}
aColumns	:=	{}
aAux		:=	{}
aIndex		:=	{}
aSeek		:=	{}
aCombo		:=	{}
aCodigo		:= {"C",006,0}
aDescri	    := {"C",254,0}
oTmpTab		:= Nil

//------------------------------------
// Monta array com a estrutura de campos da tabela temporaria
//------------------------------------
aStruct  := { {'TMP_CODIGO', aCodigo[1], aCodigo[2] ,aCodigo[3] },;
			  {'TMP_DESCRI', aDescri[1], aDescri[2], aDescri[3] } }

cTempTab := getNextAlias()

//------------------------------------
// Instancia o objeto Temporary Table 
//------------------------------------
oTmpTab	 := FWTemporaryTable():New(cTempTab, aStruct)

oTmpTab:AddIndex("1", {"TMP_CODIGO"} )
oTmpTab:AddIndex("2", {"TMP_DESCRI"} )
oTmpTab:Create()

DbSelectArea(cTempTab)
(cTempTab)->(DbSetOrder(1))
(cTempTab)->(DBGoTop())

//------------------------------------
// Popula arquivo de dados temporário
//------------------------------------
For nI := 1 to Len(aCodErro)
	If RecLock( ( cTempTab ), .T. )
		( cTempTab )->TMP_CODIGO	:= aCodErro[nI,1]	
		( cTempTab )->TMP_DESCRI	:= aCodErro[nI,2]
		( cTempTab )->( MsUnLock() )
	Endif
Next nI

//---------------------------
// Cria estrutura de colunas
//---------------------------
For nI := 1 to Len( aStruct )
	If aStruct[nI,1] $ cCampos
		nPos++
		cDescCMP := Iif(aStruct[nI,1]=="TMP_CODIGO","Codigo","Descrição")
		aAdd( aColumns, FWBrwColumn():New() )
		aColumns[nPos]:SetData( &( "{ || " + aStruct[nI,1] + " }" ) )
		aColumns[nPos]:SetTitle( cDescCMP )
		aColumns[nPos]:SetDecimal( aStruct[nI,4] )
		aColumns[nPos]:SetPicture( "@!" )
		aColumns[nPos]:SetType( aStruct[nI,2] )
		aColumns[nPos]:SetAlign( Iif( aStruct[nI,2] == "N", 2, 1 ) )
		//----------------------------
		// Cria estrutura de pesquisa
		//----------------------------
		aAdd( aIndex, aStruct[nI,1] )
		aAdd( aSeek, { cDescCMP, { { "", aStruct[nI,2], aStruct[nI,3], aStruct[nI,4], cDescCMP, "@!"} } } )
	EndIf
Next nI

//---------------------------------
// Executa a montagem da interface
//---------------------------------
TAFTICSXB( cTitle, cTempTab, cReadVar, cChave, aColumns, aSeek )

//---------------------------------
//Exclui a tabela e fecha o alias
//---------------------------------
oTmpTab:Delete()

Return( .T. )

//---------------------------------------------------------------------
/*/{Protheus.doc} ConsCDTP
Consulta Específica para Exibir os Tipos de Registros do Taf no reltáorio de erros TAFRINTEG
@Return	.T.
@Author	Wagner Soares
@Since		12/04/2018
@Version	1.0

/*/
//---------------------------------------------------------------------
Function ConsCDTP()

Local cTempTab	as character
Local cCampos	as character
Local cChave	as character
Local cTitle	as character
Local cReadVar	as character
Local nPos		as numeric
Local nPosIni	as numeric
Local nPosFim	as numeric
Local nI		as numeric
Local aStruct	as array
Local aColumns	as array
Local aAux		as array
Local aIndex	as array
Local aSeek		as array
Local aCodigo	as array
Local aDescri	as array
Local aErros	as array
Local oTbTemp	as object

cAliasQry := GetNextAlias()
cTempTab  := ""
cCampos	  := "TMP_CODIGO|TMP_DESCRI"
cChave	  := "TMP_CODIGO"
cTitle	  := "Códigos de Registros TAF"
cReadVar  := ReadVar()
cCombo	  := ""
cSelect	  := ""
cFrom	  := ""
cWhere	  := ""
cOrderBy  := ""
nPos	  := 0
nI		  := 0
aStruct	  := {}
aColumns  := {}
aAux	  := {}
aIndex	  := {}
aSeek	  := {}
aCombo	  := {}
aCodigo	  := {"C",006,0}
aDescri	  := {"C",254,0}
aErros    := {}
oTbTemp	  := Nil

if FindFunction( "GetLayout" )
	aErros := GetLayout()
endif
//------------------------------------
// Monta array com a estrutura de campos da tabela temporaria
//------------------------------------
aAdd( aStruct, { "TMP_CODIGO"	, aCodigo[1]	, aCodigo[2]	, aCodigo[3]	} )
aAdd( aStruct, { "TMP_DESCRI"	, aDescri[1]	, aDescri[2]	, aDescri[3]	} )

cTempTab := getNextAlias()

//------------------------------------
// Instancia o objeto Temporary Table 
//------------------------------------
oTbTemp	:= FWTemporaryTable():New(cTempTab, aStruct)

//------------------------------------
// Cria indices da tabela.
//------------------------------------
oTbTemp:AddIndex("1", {"TMP_CODIGO"})
oTbTemp:AddIndex("2", {"TMP_DESCRI"})
oTbTemp:Create()

//------------------------------------
// Popula arquivo de dados temporário
//------------------------------------
DbSelectArea(cTempTab)
( cTempTab )->( DbSetOrder(1) )
( cTempTab )->( DBGoTop() )

For nI := 1 to Len(aErros)
	If SubStr(aErros[nI],1,1)=="["
		If ( cTempTab )->(RecLock( ( cTempTab ), .T. ))
			( cTempTab )->TMP_CODIGO := SubStr(aErros[nI], 2, At( "-", aErros[nI] ) - 2)
			nPosIni := At( "-", aErros[nI] ) + 2
			nPosFim := (At( "]", aErros[nI] ) - 1) - (At( "-", aErros[nI] ) + 2)
			( cTempTab )->TMP_DESCRI := SubStr(aErros[nI], nPosIni , nPosFim)
			( cTempTab )->( MsUnLock() )
		Endif
	Endif
Next nI

//---------------------------
// Cria estrutura de colunas
//---------------------------
For nI := 1 to Len( aStruct )
	If aStruct[nI,1] $ cCampos
		nPos++
		cDescCMP := Iif(aStruct[nI,1]=="TMP_CODIGO","Codigo","Descrição")
		aAdd( aColumns, FWBrwColumn():New() )
		aColumns[nPos]:SetData( &( "{ || " + aStruct[nI,1] + " }" ) )
		aColumns[nPos]:SetTitle( cDescCMP )
		aColumns[nPos]:SetDecimal( aStruct[nI,4] )
		aColumns[nPos]:SetPicture( "@!" )
		aColumns[nPos]:SetType( aStruct[nI,2] )
		aColumns[nPos]:SetAlign( Iif( aStruct[nI,2] == "N", 2, 1 ) )
		//----------------------------
		// Cria estrutura de pesquisa
		//----------------------------
		aAdd( aIndex, aStruct[nI,1] )
		aAdd( aSeek, { cDescCMP, { { "", aStruct[nI,2], aStruct[nI,3], aStruct[nI,4], cDescCMP, "@!" } } } )
	EndIf
Next nI

//---------------------------------
// Executa a montagem da interface
//---------------------------------
TAFTICSXB( cTitle, cTempTab, cReadVar, cChave, aColumns, aSeek )

//---------------------------------
//Exclui a tabela e fecha o alias
//---------------------------------
oTbTemp:delete()

Return( .T. )

//---------------------------------------------------------------------
/*/{Protheus.doc} ConsCDST
Consulta Específica para Exibir Códigos de Status do Taf no reltáorio de erros TAFRINTEG
@Return	.T.
@Author	Wagner Soares
@Since		12/04/2018
@Version	1.0

/*/
//---------------------------------------------------------------------
Function ConsCDST()

Local cTempTab	as character
Local cCampos	as character
Local cChave	as character
Local cTitle	as character
Local cReadVar	as character
Local nPos		as numeric
Local nI		as numeric
Local aStruct	as array
Local aColumns	as array
Local aAux		as array
Local aIndex	as array
Local aSeek		as array
Local aCodigo	as array
Local aDescri	as array
Local aStatus	as array
Local oTmpTab	as object

cTempTab := ""
cCampos	 := "TMP_CODIGO|TMP_DESCRI"
cChave	 := "TMP_CODIGO"
cTitle	 := "Códigos de Status TAF"
cReadVar := ReadVar()
cCombo	 := ""
cSelect	 := ""
cFrom	 := ""
cWhere	 := ""
cOrderBy := ""
nPos	 := 0
nI		 := 0
aStruct	 :=	{}
aColumns :=	{}
aAux	 :=	{}
aIndex	 :=	{}
aSeek	 :=	{}
aCombo	 :=	{}
aCodigo	 :=	{"C",006,0}
aDescri	 :=	{"C",254,0}
aStatus  := LoadSTTaf()
oTmpTab	 := Nil

//------------------------------------
// Monta array com a estrutura de campos da tabela temporaria
//------------------------------------
aStruct  := { {'TMP_CODIGO', aCodigo[1], aCodigo[2] ,aCodigo[3] },;
			  {'TMP_DESCRI', aDescri[1], aDescri[2], aDescri[3] } }

cTempTab := getNextAlias()

//---------------------------------
// Instancia o objeto Temporary Table 
//---------------------------------
oTmpTab	 := FWTemporaryTable():New(cTempTab, aStruct)

oTmpTab:AddIndex("1", {"TMP_CODIGO"} )
oTmpTab:AddIndex("2", {"TMP_DESCRI"} )
oTmpTab:Create()

DbSelectArea(cTempTab)
(cTempTab)->(DbSetOrder(1))
(cTempTab)->(DBGoTop())

//------------------------------------
// Popula arquivo de dados temporário
//------------------------------------
For nI := 1 to Len(aStatus)
	If RecLock( ( cTempTab ), .T. )
		( cTempTab )->TMP_CODIGO	:= aStatus[nI,1]	
		( cTempTab )->TMP_DESCRI	:= aStatus[nI,2]
		( cTempTab )->( MsUnLock() )
	EndIf
Next nI

//---------------------------
// Cria estrutura de colunas
//---------------------------
For nI := 1 to Len( aStruct )
	If aStruct[nI,1] $ cCampos
		nPos++
		cDescCMP := Iif(aStruct[nI,1]=="TMP_CODIGO","Codigo","Descrição")
		aAdd( aColumns, FWBrwColumn():New() )
		aColumns[nPos]:SetData( &( "{ || " + aStruct[nI,1] + " }" ) )
		aColumns[nPos]:SetTitle( cDescCMP )
		aColumns[nPos]:SetDecimal( aStruct[nI,4] )
		aColumns[nPos]:SetPicture( "@!" )
		aColumns[nPos]:SetType( aStruct[nI,2] )
		aColumns[nPos]:SetAlign( Iif( aStruct[nI,2] == "N", 2, 1 ) )
		//----------------------------
		// Cria estrutura de pesquisa
		//----------------------------
		aAdd( aIndex, aStruct[nI,1] )
		aAdd( aSeek, { cDescCMP, { { "", aStruct[nI,2], aStruct[nI,3], aStruct[nI,4], cDescCMP, "@!" } } } )
	EndIf
Next nI

//---------------------------------
// Executa a montagem da interface
//---------------------------------
TAFTICSXB( cTitle, cTempTab, cReadVar, cChave, aColumns, aSeek )

//---------------------------------
//Exclui a tabela e fecha o alias
//---------------------------------
oTmpTab:Delete()

Return( .T. )

//---------------------------------------------------------------------
/*/{Protheus.doc} FConfirm

Executa a gravação do retorno da Consulta Específica.

@Param		oBrowse	- Objeto da Browse
			cReadVar	- Campo de retorno da Consulta Específica
			cChave		- Campo(s) a serem gravados no retorno da Consulta Específica
			lMult		- Indica se a tela permitirá seleção de múltiplos registros

@Author	Wagner Soares
@Since		12/04/2018
@Version	1.0
/*/
//---------------------------------------------------------------------
Static Function FConfirm( oBrowse, cReadVar, cChave)

Local cAlias	as character
Local nRecno	as numeric

cAlias	:=	oBrowse:Alias()
nRecno	:=	( cAlias )->( Recno() )

SetMemVar( cReadVar, ( cAlias )->&( cChave ) )
SysRefresh( .T. )
( cAlias )->( DBGoTo( nRecno ) )

oBrowse:Refresh()

Return()

//---------------------------------------------------------------------
/*/{Protheus.doc} TAFRINTEG
Gera Planilha

@Author	Eduardo Sukeda
@Since		22/03/2018
@Version	1.0
@Altered By Wagner Soares - 12/04/18 - Ajustes para padronização
/*/
//---------------------------------------------------------------------
Static Function TAFRINTEG()

Local cTxtHlp   := STR0226
Local aPergunte := {}
Local oObjRel 	:= Nil

Private oReport := Nil
Private oSecCab := Nil
Private oBreak  := Nil

oObjRel := FWSX1Util():New()
oObjRel:AddGroup("RTAFR01")
oObjRel:SearchGroup()
aPergunte := oObjRel:GetGroup("RTAFR01")

if len( aPergunte ) > 1
	If FindFunction("TRepInUse") .And. TRepInUse()
		ReportDef()
		oReport:PrintDialog()
	EndIf
else	
	Help(" ",1,"TAFRINTEG",,cTxtHlp ,1,0) //"Você não está com os dicionários do TAF Atualizados, Por favor atualie para o pacote com data maior ou igual a 30/04/2018 disponivel no portal do cliente."
EndIf

Return Nil

Static Function ReportDef()

oReport := TReport():New("RTAFR01",STR0212,"RTAFR01",{|oReport| PrintReport(oReport)},STR0213) ////#"Integrações" # "Relatório de Integrações"
oReport:SetLandscape(.T.)

oSecCab := TRSection():New( oReport , STR0212, {""},,,,,,,,)//#"Integrações"

TRCell():New( oSecCab, "DATA", "",STR0215,,20) // #"Data"
TRCell():New( oSecCab, "TICKET", "",STR0216,,36) //# "Ticket"
TRCell():New( oSecCab, "CHAVE", "",STR0217,,80)//# "Chave"
TRCell():New( oSecCab, "TIPO_REGISTRO", "",STR0218,,15) //# "Tipo Reg."
TRCell():New( oSecCab, "MENSAGEM", "",STR0219,,120)//# "Mensagem"
TRCell():New( oSecCab, "ERRO", "",STR0220,,120) //# "Erro"
TRCell():New( oSecCab, "STATUS" , "",STR0221,,10) //# "Status"
TRCell():New( oSecCab, "COD_ERRO", "",STR0222,,120)//# "Cod. Erro"

oReport:OnPageBreak({||.F.})

oBreak := TRBreak():New(oSecCab,oSecCab:Cell("DATA"),,.F.)

TRFunction():New(oSecCab:Cell("DATA"),,"COUNT",,STR0214,,,,,,oSecCab)//#"Quantidade de Registros"

Return Nil

Static Function PrintReport(oReport)

Local oSecCab   := oReport:Section(1)
Local cSelect   := ""
Local cWhere    := ""
Local cFrom     := ""
Local cQry      := ""
Local aArea	    := GetArea()
Local cAliasQry := GetNextAlias()
Local cMsg      := ""
Local cErro     := ""
Local cCodErro  := ""
Local nPosErro  := 0  
Local nTotReg   := 0

Pergunte("RTAFR01",.f.)

aAreaST2	:=	( cST2Alias )->( GetArea() )
aAreaXERP	:=	( cXERPAlias )->( GetArea() )

cSelect += " ERP.TAFDATA AS DATA, ERP.TAFKEY AS CHAVE, TAFTPREG AS TIPO_REGISTRO,"
cSelect += " ST2.TAFSTATUS AS STATUS, ERP.TAFCODERR AS COD_ERRO, ST2.TAFTICKET AS TICKET, "
cSelect += " ST2.R_E_C_N_O_ AS RECST2, ERP.R_E_C_N_O_ AS RECXERP     "
cFrom += " TAFST2 ST2 "
cWhere += " ST2.TAFTPREG BETWEEN '" + AllTrim(MV_PAR01)+ "' AND '" + AllTrim(MV_PAR02) + "' "
cWhere += " AND ERP.TAFDATA BETWEEN '" + Dtos(MV_PAR03) + "' AND '" + Dtos(MV_PAR04) + "'"
cWhere += " AND ERP.TAFSTATUS BETWEEN '" + AllTrim(MV_PAR05) + "' AND '" + AllTrim(MV_PAR06) + "'"
cWhere += " AND ERP.TAFCODERR BETWEEN '" + AllTrim(MV_PAR07) + "' AND '" + AllTrim(MV_PAR08) + "'"
cWhere += " AND ST2.D_E_L_E_T_ = ' ' "
cWhere += " AND ERP.D_E_L_E_T_ = ' ' "

IF MV_PAR09 == 1
	cWhere += " and ST2.R_E_C_N_O_ in ( select MAX(ST21.R_E_C_N_O_) FROM TAFST2 ST21 WHERE ST2.TAFKEY=ST21.TAFKEY AND ST21.D_E_L_E_T_ = ' ')
ENDIF

cQry += "SELECT " + cSelect + " FROM " + cFrom + " INNER JOIN  TAFXERP ERP ON (ERP.TAFKEY = ST2.TAFKEY) WHERE " + cWhere
cQry := ChangeQuery(cQry)

DbUseArea(.T., "TOPCONN", TcGenQry(,, cQry), cAliasQry, .F., .T.)

(cAliasQry)->(dbEval({|| nTotReg++ },,{||!EOF()}))

TCSetField( cAliasQry, "DATA", "D" )

Dbselectarea(cAliasQry)
(cAliasQry)->(dbGoTop())

oReport:SetMeter(nTotReg)

oSecCab:Init()

While (cAliasQry)->(!Eof())
	oReport:IncMeter()
	( cST2Alias )->( DbGoTo( (cAliasQry)->RECST2 ) )
	cMsg := Alltrim((cST2Alias)->TAFMSG )

	( cXERPAlias )->( DbGoTo( (cAliasQry)->RECXERP ) )
	cErro := Alltrim(( cXERPAlias)->TAFERR )
	nPosErro := aScan(aCodErro,{ |x| x[1] == (cAliasQry)->COD_ERRO})
	if nPosErro > 0
		cCodErro := (cAliasQry)->COD_ERRO + " - " + aCodErro[nPosErro,2] 
	else
		cCodErro := (cAliasQry)->COD_ERRO
	endif

	oSecCab:Cell("DATA"):SetValue((cAliasQry)->DATA)
	oSecCab:Cell("TICKET"):SetValue((cAliasQry)->TICKET)
	oSecCab:Cell("CHAVE"):SetValue((cAliasQry)->CHAVE)
	oSecCab:Cell("TIPO_REGISTRO"):SetValue((cAliasQry)->TIPO_REGISTRO)
	oSecCab:Cell("MENSAGEM"):SetValue(cMsg)
	oSecCab:Cell("ERRO"):SetValue(cErro)
	oSecCab:Cell("STATUS"):SetValue((cAliasQry)->STATUS)
	oSecCab:Cell("COD_ERRO"):SetValue(cCodErro)
	oSecCab:Printline()
	
	(cAliasQry)->(dbSkip())
EndDo

oSecCab:Finish()

(cAliasQry)->(DbClosearea())

If !Empty( aAreaST2 )
	RestArea( aAreaST2 )
EndIf

If !Empty( aAreaXERP )
	RestArea( aAreaXERP )
EndIf
RestArea(aArea)

Return Nil

//---------------------------------------------------------------------
/*/{Protheus.doc} TAFVLDREG
Validar codigo do Registro informado no relatório TAFRINTEG
@Return	lRet - Variável Lógica que permite ou não a digitação do parametro - TAFRINTEG
@Author	Wagner Soares
@Since		16/04/2018
@Version	1.0

/*/
//---------------------------------------------------------------------

function TAFVLDREG()
Local lRet := .T.
If mv_par02 < mv_par01
	Aviso("PARAMOBRIGAT",STR0223,{STR0169},1) //#"O código de Registro Até deve ser maior ou igual ao código de Registro De !!" #Fechar
	lRet := .F.
Endif                                                 
Return lRet

//---------------------------------------------------------------------
/*/{Protheus.doc} TAFVLDSTA
Validar codigo do Status informado no relatório TAFRINTEG
@Return	lRet - Variável Lógica que permite ou não a digitação do parametro - TAFRINTEG
@Author	Wagner Soares
@Since		16/04/2018
@Version	1.0

/*/
//---------------------------------------------------------------------

function TAFVLDSTA()
Local lRet := .T.
If mv_par06 < mv_par05
	Aviso("PARAMOBRIGAT",STR0224,{STR0169},1) //#"O código de Status Até deve ser maior ou igual ao código de Status De !!" #Fechar
	lRet := .F.
Endif                                                 
Return lRet


//---------------------------------------------------------------------
/*/{Protheus.doc} TAFVLDERR
Validar codigo do Erro informado no relatório TAFRINTEG
@Return	lRet - Variável Lógica que permite ou não a digitação do parametro - TAFRINTEG
@Author	Wagner Soares
@Since		16/04/2018
@Version	1.0

/*/
//---------------------------------------------------------------------

function TAFVLDERR()
Local lRet := .T.
If mv_par08 < mv_par07
	Aviso("PARAMOBRIGAT",STR0225,{STR0169},1) //#"O código de Erro Até deve ser maior ou igual ao código de Erro De !!" #Fechar
	lRet := .F.
Endif                                                 
Return lRet

//---------------------------------------------------------------------
/*/{Protheus.doc} LoadSTTaf
Retornar códigos de Status do Taf no relatório de erros TAFRINTEG
@Return	aST - Array com os códigos de Status usados na consulta especifica ConsCDST - TAFRINTEG
@Author	Wagner Soares
@Since		16/04/2018
@Version	1.0

/*/
//---------------------------------------------------------------------
Static Function LoadSTTaf()
Local aSt := {}

aAdd(aSt,{'1',Upper('Inclusão')})
aAdd(aSt,{'2',Upper('Alteração')})
aAdd(aSt,{'3',Upper('Exclusão')})
aAdd(aSt,{'4',Upper('Fila de Integração')})
aAdd(aSt,{'5',Upper('Exclusão direta (eSocial)')})
aAdd(aSt,{'7',Upper('Erro de Predecessão')})
aAdd(aSt,{'8',Upper('Erro na validação do Complemento de empresa')})
aAdd(aSt,{'9',Upper('Inconsistencia')})

Return aSt

//-------------------------------------------------------------------
/*/{Protheus.doc} VldComplem
Valida a estrutura da amarração 1:1e 1:N
@author  Victor A. Barbosa
@since   07/02/2019
@version 1
/*/
//-------------------------------------------------------------------
Static Function VldComplem()

Local cNextAlias 	:= GetNextAlias()
Local lRet		 	:= .T.

If Select(cNextAlias) > 0
	(cNextAlias)->( dbCloseArea() )
EndIf

// Se possuir mais de um registro na C1E para o mesmo código com status ativo, então está errado
// Se possuir mais de um registro na CR9 para o mesmo código com status ativo, então está errado 
BeginSQL Alias cNextAlias	
	SELECT C1E_CODFIL CODFIL
	FROM %table:C1E% C1E 
	WHERE C1E_FILIAL = %xFilial:C1E% 
	AND C1E_ATIVO = '1' 
	AND C1E.%notdel% 
	GROUP BY C1E_CODFIL 
	HAVING COUNT(C1E_CODFIL) > 1
			
	UNION ALL

	SELECT CR9_CODFIL CODFIL
	FROM %table:CR9% CR9
	INNER JOIN %table:C1E% C1E
	ON CR9_FILIAL = C1E_FILIAL AND CR9_ID = C1E_ID AND C1E_ATIVO = '1'
	WHERE CR9_FILIAL = %xFilial:CR9%
	AND	CR9_ATIVO = '1'
	AND	CR9.%notdel% 
	AND C1E.%notdel% 
	GROUP BY CR9_CODFIL
	HAVING COUNT(CR9_CODFIL) > 1
EndSQL

If (cNextAlias)->( !Eof() )
	lRet := .F.
EndIf

Return(lRet)
