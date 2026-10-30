#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "AP5MAIL.CH"
#INCLUDE "GFEA064.CH"
 
//-------------------------------------------------------------------
/*/{Protheus.doc} GFEA064
Rotina para cadastro de Aprovação da Tabela de Frete
Uso Geral.

@author Jorge Matos Valcanaia
@since 05/04/10
@version 1.0
/*/
//-------------------------------------------------------------------

Function GFEA064()
Private oBrowse     

If !(SuperGetMV("MV_APRTAB",,"2") $ "1S")
	Help(,,'HELP',,STR0001,1,0) //"Sistema não está parametrizado para fazer controle de aprovação de Tabela de Frete"
	Return .F.
EndIf

// Quando integração com Datasul + controle de aprovação por MLA
If SuperGetMv("MV_ERPGFE",.F.,"2") == "1" .And. SuperGetMv("MV_TFMLA",.F.,"2") == "1"
	Help(,,"HELP",,STR0033,1,0) //"Esta rotina está bloqueada, pois o sistema está parametrizado para cotrole de aprovação de Tabelas de Frete por MLA (MV_TFMLA)."
	Return .F.
EndIf

oBrowse := FWMBrowse():New()
oBrowse:SetAlias("GV9")						           // Alias da tabela utilizada
oBrowse:SetMenuDef("GFEA064")				           // Nome do fonte onde esta a função MenuDef
oBrowse:SetDescription("Aprovação de Tabelas de Frete") //"Aprovação da Tabela de Frete"
oBrowse:AddLegend("GV9_SIT=='1'", "BLUE" , STR0003) //"Em Negociação"                               
oBrowse:AddLegend("GV9_SIT=='2'", "GREEN", STR0004) //"Aprovada" 

If !GFEA64PAR(.T.)
	Return .F.
EndIf 

oBrowse:Activate()

Return(Nil)

//-------------------------------------------------------------------

Static Function MenuDef()
Local aRotina := {}      

ADD OPTION aRotina TITLE STR0005 ACTION "AxPesqui"         OPERATION 1  ACCESS 0 //"Pesquisar"
ADD OPTION aRotina TITLE STR0006 ACTION "VIEWDEF.GFEA061A" OPERATION 2  ACCESS 0 //"Visualizar"
If Select('SX2') > 0 .And. CHKFILE('GV9')
	dbSelectArea('GV9')
	ADD OPTION aRotina TITLE "Consultar Comparativos" ACTION "GFEX062('1',GV9->GV9_CODCOT)" OPERATION 2 ACCESS 0	
EndIf
ADD OPTION aRotina TITLE STR0007 ACTION "GFEA64APR()"      OPERATION 0  ACCESS 0 //"Aprovar"
ADD OPTION aRotina TITLE STR0008 ACTION "GFEA64REP()"      OPERATION 0  ACCESS 0 //"Reprovar"
ADD OPTION aRotina TITLE STR0009 ACTION "GFEA64PAR(.F.)"   OPERATION 3  ACCESS 0 //"Parâmetros"
ADD OPTION aRotina TITLE STR0010 ACTION "GFEA64TBVL()"     OPERATION 3  ACCESS 0 //"Aprov Tabela Vínculo"
ADD OPTION aRotina TITLE "Tarifas" ACTION "GFEC061F(.T.)"    OPERATION 0  ACCESS 0
Return aRotina

//------------------------------------------------------------------- 

Static Function ModelDef()
Local oModel

// cID     Identificador do modelo 
// bPre    Code-Block de pre-edição do formulário de edição. Indica se a edição esta liberada
// bPost   Code-Block de validação do formulário de edição
// bCommit Code-Block de persistência do formulário de edição
// bCancel Code-Block de cancelamento do formulário de edição
oModel := MPFormModel():New("GFEA064", /*bPre*/, /*bPost*/, /*bCommit*/, /*bCancel*/)
// cId          Identificador do modelo
// cOwner       Identificador superior do modelo
// oModelStruct Objeto com  a estrutura de dados
// bPre         Code-Block de pré-edição do formulário de edição. Indica se a edição esta liberada
// bPost        Code-Block de validação do formulário de edição
// bLoad        Code-Block de carga dos dados do formulário de edição
oModel:AddFields("GFEA064_GV9", Nil, FWFormStruct(1,"GV9"),/*bPre*/,/*bPost*/,/*bLoad*/)
oModel:SetPrimaryKey({"GV9_FILIAL"})

Return oModel

//-------------------------------------------------------------------
Static Function ViewDef()

Local oModel := FWLoadModel("GFEA064")
Local oView  := Nil

oView := FWFormView():New()
// Objeto do model a se associar a view.
oView:SetModel(oModel)
// cFormModelID - Representa o ID criado no Model que essa FormField irá representar
// oStruct - Objeto do model a se associar a view.
// cLinkID - Representa o ID criado no Model ,Só é necessári o caso estamos mundando o ID no View.
oView:AddField( "GFEA064_GV9" , FWFormStruct(2,"GV9"), /*cLinkID*/ )	//
// cID		  	Id do Box a ser utilizado 
// nPercHeight  Valor da Altura do box( caso o lFixPixel seja .T. é a qtd de pixel exato)
// cIdOwner 	Id do Box Vertical pai. Podemos fazer diversas criações uma dentro da outra.
// lFixPixel	Determina que o valor passado no nPercHeight é na verdade a qtd de pixel a ser usada.
// cIDFolder	Id da folder onde queremos criar o o box se passado esse valor, é necessário informar o cIDSheet
// cIDSheet     Id da Sheet(Folha de dados) onde queremos criar o o box.
oView:CreateHorizontalBox( "MASTER" , 100,/*cIDOwner*/,/*lFixPixel*/,/*cIDFolder*/,/*cIDSheet*/ )
// Associa um View a um box
oView:SetOwnerView( "GFEA064_GV9" , "MASTER" )

Return oView    

//-------------------------------------------------------------------
/*/{Protheus.doc} GFEA64APR
Função que trata a aprovação da Tabela de Frete
Uso Geral.

@author Jorge Matos Valcanaia
@since 20/04/10
@version 1.0
/*/
//-------------------------------------------------------------------                      
Function GFEA64APR()
Local lRet := .T.     
Local dDataApro := DDATABASE
Local cTime 
Local cEnvTabCon := SuperGetMv("MV_INTTAB",.F.,"1") 

If SuperGetMV("MV_APRTAB",,"2") $ "1S"
	cTime := TIME()
	
	dbSelectArea("GUX")            
	dbSetOrder(1)
	If !dbSeek(xFilial("GUX")+RetCodUsr())          
		Help( ,, 'HELP',, STR0011, 1, 0) //"Usuário não está cadastrado como aprovador de Tabela de Frete."
		lRet := .F.
	Endif
	
	If lRet .And. (GVA->GVA_TPTAB == "1" .And. GVA->GVA_SITVIN == "2")
	   	Help( ,, 'HELP',, STR0012, 1, 0) //"Negociação Já foi Aprovada."
	   	lRet := .F.
	EndIf

	If lRet
		dbSelectArea("GV6")
		GV6->( dbSetOrder(1) )
		If GV6->( dbSeek(xFilial("GV6")+GV9->GV9_CDEMIT+GV9->GV9_NRTAB+GV9->GV9_NRNEG) )
			RecLock("GV9",.F.)
				GV9->GV9_SIT    := "2"         
				GV9->GV9_DTAPR  := dDataApro
				GV9->GV9_HRAPR  := cTime
				GV9->GV9_USUAPR := cUserName
				If GFXCP12116("GV9","GV9_SITCON") .And. GFXCP12116("GV9","GV9_MOTCON") .And. cEnvTabCon == "2" .And. GV9->GV9_SITCON != "1" .And. GVA->GVA_TPTAB == "1"
					GV9->GV9_SITCON := "2"
					GV9->GV9_MOTCON := ""
				EndIf
			MsUnLock("GV9")
			
			MsgInfo(STR0014,STR0013) //"A negociação foi aprovada com sucesso." ### "Aprovação"
		Else         
			Help( ,, 'HELP',, STR0015, 1, 0) //"A negociação não possui tarifas, portanto, não poderá ser aprovada."
			lRet := .F.	
		EndIf
				
	Endif  
Else
	Help(,,'HELP',, STR0016,1,0) //"Sistema não está parametrizado para fazer controle de aprovação de Tabela de Frete"
	lRet := .F.
EndIf	
	
Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} GFEA64REP
Função que trata a reprovação da Tabela de Frete
Uso Geral.

@author Jorge Matos Valcanaia
@since 21/04/10
@version 1.0
/*/
//------------------------------------------------------------------- 
Function GFEA64REP()     
Local lRet := .T.
Local oDlg
Local oGet
Local cMovRep

If SuperGetMV("MV_APRTAB",,"2") $ "1S"
	If !Empty(GV9->GV9_MTVRPR) .And. GV9->GV9_ENVAPR == "2"
		Help( ,, 'HELP',, STR0017, 1, 0) //"A Negociação já foi reprovada, ela deve ser alterada para poder ser reprovada novamente."
		lRet := .F.
	EndIf
	
	If lRet
		dbSelectArea("GUX")
		dbSetOrder(1)
		If !dbSeek(xFilial("GUX")+RetCodUsr())
			Help( ,, 'HELP',, STR0018, 1, 0) //"Usuário não está cadastrado como aprovador de Tabela de Frete."
			lRet := .F.
		EndIf
	EndIf

	If lRet .And. (GVA->GVA_TPTAB == "1" .AND. GVA->GVA_SITVIN == "2")
	   	Help( ,, 'HELP',, STR0019, 1, 0) //"Negociação Já foi Aprovada."
	   	lRet := .F.
	EndIf

	If lRet
		DEFINE MSDIALOG oDlg TITLE STR0020 From 4,0 To 16,60 OF oMainWnd //"Reprovação Tabela de Frete"
		@ 4, 006  SAY STR0021 SIZE 70,7 PIXEL OF oDlg //"Motivo da Reprovação:"

		oTMultiget1 := TMultiget():New(13,06,{|u|if(Pcount()>0,cMovRep:=u,cMovRep)},oDlg,225,60,,,,,,.T.)     
		oTMultiget1:EnableVScroll( .T. )
		oTMultiget1:GoEnd()
		
		oButtonOK :=tButton():New(75,5,'OK',oDlg,{|| if(GFEA64OK(cMovRep),oDlg:End(),NIL)},25,10,,,,.T.)
		oButtonCanc :=tButton():New(75,35, STR0022,oDlg,{||(oDlg:End())},25,10,,,,.T.) //Cancelar
		
		ACTIVATE MSDIALOG oDlg CENTERED	
	EndIf   	
Else
	Help(,,'HELP',, STR0023,1,0) //"Sistema não está parametrizado para fazer controle de aprovação de Tabela de Frete"
	lRet := .F.
EndIf	

Return lRet
  
//-------------------------------------------------------------------
/*/{Protheus.doc} GFEA64OK
Função que faz as validações do botão OK da tela de motivo do reprovamento
Uso Geral.

@author Jorge Matos Valcanaia
@since 21/04/10
@version 1.0
/*/
//------------------------------------------------------------------- 

Function GFEA64OK(cMovRep)
Local lRet       := .T.
Local cAssunto   := STR0024 //"Negociação não aprovada"                                                          
Local cMensagem  := STR0025 + GV9->GV9_NRTAB + STR0026 + GV9->GV9_NRTAB + STR0027 + GV9->GV9_CDEMIT + STR0028 + cUserName //"A Negociação " ### " da Tabela de Frete" ### ", do Transportador " ### " não foi aprovada pelo usuário "

	If !Empty(cMovRep)
		If GFEEnvMail(GFEA064USR(),cAssunto,cMensagem,.F.)	
			RecLock("GV9",.F.)
				GV9->GV9_SIT    := "1"
				GV9->GV9_ENVAPR := "2"
				GV9->GV9_MTVRPR := cMovRep
			MsUnLock("GV9")
			
			MsgInfo(STR0029,"") //"A negociação foi reprovada com sucesso."
		Else
			Help( ,, 'HELP',, STR0030, 1, 0) //"O e-mail não pode ser enviado. A negociação não será reprovada."
			lRet := .F.
		EndIf
	Else
		Help( ,, 'HELP',, STR0031, 1, 0) //"Informe um motivo para o cancelamento"
		lRet := .F.
	EndIf
Return lRet      

//-------------------------------------------------------------------
/*/{Protheus.doc} GFEA64PAR
Função que trata o botão de parâmetros da aprovação da Tabela de Frete
Uso Geral.

@author Jorge Matos Valcanaia
@since 21/04/10
@version 1.0
/*/
//------------------------------------------------------------------- 
Function GFEA64PAR(lExec)
Local cFiltro

If !Pergunte("GFEA064",.T.)
	Return .F.
Else
	cFiltro := " GV9_CDEMIT >= '" + MV_PAR01 + "' .And. GV9_CDEMIT <= '" + MV_PAR02 + "'"
	cFiltro += " .And. GV9_NRTAB  >= '" + MV_PAR03 + "' .And. GV9_NRTAB  <= '" + MV_PAR04 + "'"
	cFiltro += " .And. GV9_NRNEG  >= '" + MV_PAR05 + "' .And. GV9_NRNEG  <= '" + MV_PAR06 + "'"
	cFiltro += " .And. GV9_DTVALI >= '" + DTOS(MV_PAR07) + "' .And. GV9_DTVALI <= '" + DTOS(MV_PAR08) + "' "
	cFiltro += " .And. GV9_CDCLFR >= '" + MV_PAR09 + "' .And. GV9_CDCLFR <= '" + MV_PAR10 + "'"
	cFiltro += " .And. GV9_ENVAPR == '1'"
	
	oBrowse:SetFilterDefault(cFiltro)
	If !lExec 
		oBrowse:Refresh()
	EndIf
EndIf

Return .T.

//-------------------------------------------------------------------
/*/{Protheus.doc} GFEA064USR

Função que acessa a tabela de Usuarios de Aprovação da tabela de frete para que seja enviados os emails, cPara retorna todos os emails dos usuarios.

@author Jorge Matos Valcanaia
@since 21/04/10
@version 1.0
/*/
//------------------------------------------------------------------- 
Function GFEA064USR()
Local cPara := "" 

dbSelectArea("GUX")
dbSetOrder(1)
dbSeek(xFilial("GUX"))
While !Eof() .And. xFilial("GUX") == GUX->GUX_FILIAL
	If !Empty(GUX->GUX_EMAUSR)                      
		If Empty(cPara)
			cPara := Alltrim(GUX->GUX_EMAUSR)
		Else
			cPara += ";" + Alltrim(GUX->GUX_EMAUSR)
		Endif
	Endif
	dbSelectArea("GUX")
	dbSkip()
EndDo           

Return cPara      

//--------------------------------------------------------------------
/*/{Protheus.doc} GFEA064USR

Função que chama a tela de aprovação de tabela de frete de vínculo.

@author Octávio Augusto Felippe de Macedo
@since 19/01/2011
@version 1.0
/*/

Function GFEA64TBVL()

dbSelectArea("GVA") 
GVA->( dbSetOrder(1) )     
GVA->( dbSetFilter({|| GVA->GVA_FILIAL == xFilial("GVA") .And. GVA->GVA_TPTAB == "2"},"") )   
GVA->( dbGoTop() )                                                                  

If !GVA->( Eof() ) 
	GVA->( dbClearFilter() )
	GFEA064A(MV_PAR01, MV_PAR02, MV_PAR03, MV_PAR04)
Else
	Help( ,, 'HELP',, STR0032, 1, 0) //"Não há tabelas de vínculo para serem aprovadas."
EndIf	

Return
