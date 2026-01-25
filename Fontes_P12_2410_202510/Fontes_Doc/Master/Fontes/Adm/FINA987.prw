#INCLUDE 'PROTHEUS.CH'
#INCLUDE 'FWMVCDEF.CH'
#INCLUDE 'FINA987.CH'

STATIC __lFlag := NIL

//-------------------------------------------------------------------
/*/{Protheus.doc} FINA987
Tela de revisão da mensagem de exclusão enviada ao TAF

@author Karen Honda
@since 14/09/2016
@version P11
/*/
//-------------------------------------------------------------------
Function FINA987()
Local oBrowse

If AliasInDic("FKH")
	DbSelectArea("FKH")
	oBrowse := FWMBrowse():New()
	oBrowse:SetAlias('FKH')
	oBrowse:SetDescription(STR0001)//'Revisão de exclusão TAF'

	oBrowse:Activate()
Else
	MsgStop(STR0010)	//"Tabela FKH não existe. Necessário atualizar o ambiente"
EndIf
Return NIL

//-------------------------------------------------------------------
Static Function MenuDef()
Local aRotina := {}

ADD OPTION aRotina TITLE STR0003 ACTION 'F987Rev' OPERATION 9 ACCESS 0 //'Criar nova Revisão'
ADD OPTION aRotina TITLE STR0004 ACTION 'VIEWDEF.FINA987' OPERATION 2 ACCESS 0 //'Visualizar'
ADD OPTION aRotina TITLE STR0005 ACTION 'VIEWDEF.FINA987' OPERATION 5 ACCESS 0 //'Excluir'

Return aRotina


//-------------------------------------------------------------------
Static Function ModelDef()
// Cria a estrutura a ser usada no Modelo de Dados
Local oStruFKH := FWFormStruct( 1, 'FKH', /*bAvalCampo*/,/*lViewUsado*/ )
Local oModel

oStruFKH:SetProperty("FKH_REVISA",MODEL_FIELD_INIT, {|| MaxSeq() })
oStruFKH:SetProperty("FKH_LAYOUT",MODEL_FIELD_INIT, {|| FKH->FKH_LAYOUT })
oStruFKH:SetProperty("FKH_ID",MODEL_FIELD_INIT, {|| FKH->FKH_ID })

// Cria o objeto do Modelo de Dados
oModel := MPFormModel():New('FINA987', /*bPreValidacao*/, /*bPosValidacao*/, /*bCommit*/, /*bCancel*/ )

// Adiciona ao modelo uma estrutura de formulário de edição por campo
oModel:AddFields( 'FKHMASTER', /*cOwner*/, oStruFKH, /*bPreValidacao*/, /*bPosValidacao*/, /*bCarga*/ )

oModel:SetPrimaryKey({'FKH_FILIAL','FKH_LAYOUT','FKH_REVISA'})

// Adiciona a descricao do Modelo de Dados
oModel:SetDescription( STR0006 )//'Revisão da mensagem de exclusão ao TAF'


Return oModel


//-------------------------------------------------------------------
Static Function ViewDef()
// Cria um objeto de Modelo de Dados baseado no ModelDef do fonte informado
Local oModel   := FWLoadModel( 'FINA987' )
// Cria a estrutura a ser usada na View
Local oStruFKH := FWFormStruct( 2, 'FKH' )
Local oView

oStruFKH:SetProperty("FKH_ID",MVC_VIEW_CANCHANGE, .F.)
oStruFKH:SetProperty("FKH_REVISA",MVC_VIEW_CANCHANGE, .F.)
// Cria o objeto de View
oView := FWFormView():New()

// Define qual o Modelo de dados será utilizado
oView:SetModel( oModel )

//Adiciona no nosso View um controle do tipo FormFields(antiga enchoice)
oView:AddField( 'VIEW_FKH', oStruFKH, 'FKHMASTER' )

// Criar um "box" horizontal para receber algum elemento da view
oView:CreateHorizontalBox( 'TELA' , 100 )

// Relaciona o ID da View com o "box" para exibicao
oView:SetOwnerView( 'VIEW_FKH', 'TELA' )

oView:EnableControlBar(.F.)


//oView:SetViewAction( 'BUTTONOK'    , { |o| Help(,,'HELP',,'Ação de Confirmar ' + o:ClassName(),1,0) } )
//oView:SetViewAction( 'BUTTONCANCEL', { |o| Help(,,'HELP',,'Ação de Cancelar '  + o:ClassName(),1,0) } )
Return oView


//-------------------------------------------------------------------
/*/{Protheus.doc} F987Rev 
Opção Criar nova Revisão, para altera a mensagem a ser enviada ao TAF

@author Karen Honda
@since 28/07/2016
@version P11
/*/
//-------------------------------------------------------------------
Function F987Rev()
Local aEnableButtons := {{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.T.,Nil},{.T.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil}} //"Confirmar"###"Fechar"

FWExecView( STR0007,"FINA987", 9,/**/,{||.T.}/*bCloseOnOk*/,{||EnviaMsgTAF()},,aEnableButtons,/*bCancel*/,/**/,/*cToolBar*/ )//'Gerar nova revisão'

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} MaxSeq 
Função para pegar a ultima revisão para incrementar a proxima

@author Karen Honda
@since 28/07/2016
@version P11
/*/
//-------------------------------------------------------------------
Static Function MaxSeq()
Local cQuery := ""
Local cAliasQry := GetNextAlias()
Local cSeq := "000001"

DbSelectarea("FKH")

cQuery := " SELECT MAX(FKH_REVISA) REVISA FROM " + RetSqlName("FKH")
cQuery += " WHERE FKH_FILIAL = '" + xFilial("FKH") + "' " 
cQuery += " AND FKH_LAYOUT = '" + FKH->FKH_LAYOUT + "' "
cQuery += " AND FKH_ID = '" + FKH->FKH_ID + "' "
cQuery += " AND D_E_L_E_T_ = ' '"
  
dbUseArea(.T., "TOPCONN", TCGenQry(,,cQuery), cAliasQry, .F., .T.)
	
If !(cAliasQry)->(Eof())
	cSeq := Soma1((cAliasQry)->REVISA)
EndIf

(cAliasQry)->(DBCloseArea())

Return cSeq

//-------------------------------------------------------------------
/*/{Protheus.doc} F987Incl 
Função para incluir a primeira revisao. Utilizada nas rotinas de contas a pagar/receber
ao excluir o titulo.

@param cLayout Codigo do layout do TAF. Ex T999
@param cChave Chave do registro a ser exluido
@return lRet  retorna .T. se gravou corretamente 

@author Karen Honda
@since 28/07/2016
@version P11
/*/
//-------------------------------------------------------------------
Function F987Incl(cLayout, cChave, cIdMov, cTabOri)

	Local oModel
	Local lRet	 := .T.
	Local cLog := ""

	DEFAULT cLayOut := ""
	DEFAULT cChave := ""
	DEFAULT cIdMov := ""
	DEFAULT cTabOri := ""

	oModel := FwLoadModel("FINA987")
	oModel:SetOperation(MODEL_OPERATION_INSERT)
	oModel:Activate()

	oModel:SetValue("FKHMASTER","FKH_ID", FINFKSID('FKH', 'FKH_ID'))
	oModel:SetValue("FKHMASTER","FKH_LAYOUT",cLayout)
	oModel:SetValue("FKHMASTER","FKH_REVISA","000001")
	oModel:SetValue("FKHMASTER","FKH_MSGTAF",cChave)
	oModel:SetValue("FKHMASTER","FKH_IDMOV",cIdMov)
	oModel:SetValue("FKHMASTER","FKH_TABORI",cTabOri)

	If oModel:VldData()
		FwFormCommit(oModel)
	Else
		lRet := .F.
		cLog := cValToChar(oModel:GetErrorMessage()[4]) + ' - '
		cLog += cValToChar(oModel:GetErrorMessage()[5]) + ' - '
		cLog += cValToChar(oModel:GetErrorMessage()[6])        	
		Help( ,,"FINA987",,cLog, 1, 0 )
	Endif
		
	oModel:Deactivate()
	oModel:Destroy()
	oModel:= Nil

	Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} EnviaMsgTAF 
Ao confirmar a tela, será gravado a nova revisão e gerado a mensagem para a TAFST1

@return retorna .t. se enviou a mensagem para o TAF

@author Karen Honda
@since 28/07/2016
@version P11
/*/
//-------------------------------------------------------------------
Static Function EnviaMsgTAF()
Local oModel	:= FwModelActive()
Local cChave	:= ""
Local cReg		:= ""
Local aRegs		:= {}
Local lOpenST1	:= .T.
Local lRet		:= .T.

Private cTpSaida 	:= "2" // utilizado na FConcTxt para definir se integração será banco a banco ou txt
Private lGeraST2TAF := .F.
Private aDadosST1	:= {} //utilizado pelas funcoes do TAF na gravacao dos dados na ST1
Private cInc 		:= "000001" // utilizado pela funcao do taf

If MsgYesNo(STR0008)	//"Será enviado uma nova mensagem ao TAF. Deseja continuar?"
	
	If Select("TAFST1") == 0
		dbUseArea( .T.,"TOPCONN","TAFST1","TAFST1",.T.,.F.) //Abre Exclusivo
		
		lOpenST1 := Select("TAFST1") > 0
		
		If !lOpenST1
			MsgAlert(STR0009)//" Não foi encontrada e/ou não foi possivel a abertura Exclusiva da tabela TAFST1 no mesmo Ambiente de ERP!" 
			lRet := .F.
		Endif
	EndIf
	If lRet
		cReg := Alltrim(oModel:GetValue("FKHMASTER","FKH_LAYOUT"))
		cChave:= Alltrim(oModel:GetValue("FKHMASTER","FKH_MSGTAF"))
		Aadd( aRegs, {  ;
				cReg,; 				// TIPO REGISTRO
				cChave})				// Chave
									
		FConcTxt( aRegs)
		
		FConcST1()
		
		If lOpenST1
			TAFST1->(DbCloseArea())
		EndIf	
	Endif
Else
	lRet := .F.	
EndIf
Return lRet


//-------------------------------------------------------------------
/*/{Protheus.doc} FinGrvFKH 
Função para gerar informações para incluir a primeira revisao. 
Utilizada nas rotinas de contas a pagar/receber ao excluir o titulo.

@param cTabOri, Char, Tabela de Origem do movimento. Ex "SE2" ou "FK2"
@param cIdMov, Char, Id do movimento (Inclusão: FK7_IDDOC, Baixa: FK2_IDFK2
@param cIdFK2Est, Char, ID da FK2 do registro de estorno (especifico para est. baixa pagar)
@param oModel, Object, Modelo de dados da baixa (especifico para est. baixa pagar)
@param dData, Date, Data da baixa (especifico para est. baixa pagar)
@param cSeq, Char, Sequencia da baixa (especifico para est. baixa pagar)
@param cNatRen, Char, Natureza de rendimento (uso exclusivo para geração do T162)

@return lRet  retorna .T. se gravou corretamente 

@author Mauricio Pequim Jr
@since 27/08/2019
@version P12
/*/
//-------------------------------------------------------------------
 Function FinGrvFKH(cTabOri As Char, cIdMov As Char, cIdFK2Est As Char, oModel As Object, dData As Date, cSeq As Char, cNatRen As Char) 

	Local cLayout As Char
	Local cChave As Char
	Local cChaveAux As Char
	Local cChave162 As Char
	Local lRet As Logical
	Local lInclui As Logical
	Local lBloco20 As Logical

	DEFAULT cTabOri := ""
	DEFAULT cIdMov	:= ""
	DEFAULT cIdFK2Est := ""
	DEFAULT oModel := NIL
	DEFAULT dData := CTOD("  /  /    ")
	DEFAULT cSeq := ""
	DEFAULT cNatRen := ""

	cLayout	  := "T999"
	lRet	  := .F.
	lInclui	  := .F.
	cChave	  := ""
	cChaveAux := ""
	cChave162 := ""
	lBloco20  := .F.

	If __lFlag == NIL
		__lFlag := FKH->(ColumnPos("FKH_REINF")) > 0
	EndIf
	
	If __lFlag
		DO CASE
			
			CASE cTabOri == "SE1"
				If lBloco20 := (!EMPTY(FKF->FKF_TPSERV) .Or. !EMPTY(FKF->FKF_TPREPA) .Or. SE1->E1_ORIGEM $ "MATA461|MATA460") .And. ((SA1->A1_RECINSS == "S" .And. SED->ED_CALCINS == "S") .Or. SE1->E1_INSS > 0)
					cChaveAux += SE1->E1_NUM + If(Empty(SE1->E1_PARCELA),"", "-" + SE1->E1_PARCELA) + "|"
					cChaveAux += SE1->E1_PREFIXO +"|"                 //Série
					cChaveAux += "C"+SE1->(E1_CLIENTE+E1_LOJA) + "|"  //Código do Participante
					cChaveAux += DTOS(SE1->E1_EMISSAO) + "|"          //Emissão
					cChaveAux += "1"                                  //Natureza da fatura/recibo --> 0 = Pagar; 1 = Receber
				EndIf

				If FTemFKW(cIdMov, .T.) .And. !Empty(cNatRen)
					cChave162 += SE1->E1_PREFIXO + SE1->E1_NUM + "|"	//Codigo do documento (Prefixo + NUmero)
					cChave162 += cNatRen  +"|"							//Natureza de Rendimento
					cChave162 += DTOS(SE1->E1_EMISSAO) + "|"			//Emissão
					cChave162 += "|"									//Vlr Liquido
					cChave162 += "|"									//Vlr Reajustado
					cChave162 += "|"									//Vlr IRRF
					cChave162 += "|"									//Descrição
					cChave162 += "|"									//Base IRRF
					cChave162 += "1" + "|"								//Natureza da fatura/recibo --> 0 = Pagar; 1 = Receber
					cChave162 += "C"+SE1->(E1_CLIENTE+E1_LOJA)			//Participante
				EndIf

				lInclui := .T.

			CASE cTabOri == "SE2"
				cChaveAux += SE2->E2_NUM + If(Empty(SE2->E2_PARCELA),"", "-" + SE2->E2_PARCELA) + "|"
				cChaveAux += SE2->E2_PREFIXO +"|"                 //Série
				cChaveAux += "F"+SE2->(E2_FORNECE+E2_LOJA) + "|"  //Código do Participante
				cChaveAux += DTOS(SE2->E2_EMISSAO) + "|"          //Emissão
				cChaveAux += "0"                                  //Natureza da fatura/recibo --> 0 = Pagar; 1 = Receber
				lInclui := .T.

			CASE cTabOri == "FK2" 
				cChaveAux += SE2->E2_NUM + "|"					  //Numero
				cChaveAux += SE2->E2_PREFIXO +"|"                 //Série
				cChaveAux += "F"+SE2->(E2_FORNECE+E2_LOJA) + "|"  //Código do Participante
				cChaveAux += DTOS(SE2->E2_EMISSAO) + "|"          //Emissão
				cChaveAux += "0"  + "|"                           //Natureza da fatura/recibo --> 0 = Pagar; 1 = Receber
			cChaveAux += SE2->E2_PARCELA  + "|" 			  //Parcela do documento
				cChaveAux += Dtos(dData)  + "|" 				  //Data do pagamento
				cChaveAux += cSeq								  //Sequencial da baixa
				lInclui := .F.			
		END CASE

		If !Empty(cIdMov) .and. !Empty(cTabOri)
			If lInclui
				If (cTabOri == "SE2" .Or. lBloco20) .And. !Empty(cChaveAux)
					cChave := "T154|" + cChaveAux
					lRet := F987Incl(cLayout, cChave, cIdMov, cTabOri)
				EndIf
				If cTabOri == "SE1" .And. !Empty(cChave162)
					cChave := "T162|" +cChave162
					lRet := F987Incl(cLayout, cChave, cIdMov, cTabOri)
				EndIf
			ElseIf !lInclui .And. cTabOri == "FK2" .And. !Empty(cChaveAux)
				cChave := "T158|" +cChaveAux
				cIdMov := cIdFK2Est
				lRet := F987Incl(cLayout, cChave, cIdMov, cTabOri)
			Endif
		EndIf
	Endif

	If oModel != NIL
		FWModelActive(oModel)
	Endif
			
Return lRet

