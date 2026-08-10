#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "VEIA010.CH"

//-------------------------------------------------------------------
/*/{Protheus.doc} VEIA010()
Cadastro de Envio automatico de Emails

@author Andre Luis Almeida
@since 19/10/2018
@version 1.0
@return NIL
/*/
//-------------------------------------------------------------------
Function VEIA010()
Local aSizeAut := MsAdvSize(.t.)  // Tamanho Maximo da Janela (.t.=TOOLBAR,.f.=SEM TOOLBAR)    
Private oModel
Private aTipos := {}
Private aEvent := {}
Private cCodEve := "" // Evento selecionado
Private cDesEve := "" // Descrição do Evento selecionado
Private cObsMEMO := "" // Observacao MEMO

VA0100091_Tipos() // Carregar aTipos

DEFINE MSDIALOG oVEIA010 TITLE (STR0001+" - "+FWFilialName()) From aSizeAut[7],000 to aSizeAut[6],aSizeAut[5] of oMainWnd PIXEL //Envio de E-mails automaticos

	oPanTop := TPanel():New(0,0,"",oVEIA010,NIL,.T.,.F.,NIL,NIL,100,80,.T.,.F.)
	oPanTop:Align := CONTROL_ALIGN_TOP
	oPanTip := TPanel():New(0,0,"",oPanTop,NIL,.F.,.F.,NIL,NIL,220,80,.T.,.F.)
	oPanTip:Align := CONTROL_ALIGN_LEFT
	oPanEve := TPanel():New(0,0,"",oPanTop,NIL,.T.,.F.,NIL,NIL,200,80,.T.,.F.)
	oPanEve:Align := CONTROL_ALIGN_ALLCLIENT
	oPanObs := TPanel():New(0,0,"",oPanTop,NIL,.F.,.F.,NIL,NIL,120,80,.T.,.F.)
	oPanObs:Align := CONTROL_ALIGN_RIGHT

	oPanBrw := TPanel():New(0,0,"",oVEIA010,NIL,.T.,.F.,NIL,NIL,200,200,.T.,.F.)
	oPanBrw:Align := CONTROL_ALIGN_ALLCLIENT
		
	oBrwVEU := FWMBrowse():New()
	oBrwVEU:SetOwner(oPanBrw)
	oBrwVEU:SetAlias("VEU")
	oBrwVEU:SetMenuDef("")
	oBrwVEU:AddButton(STR0010,{|| VA0100041_Manutencao(4) , VA0100021_FiltraBrowse() },,2,2) // Manutenção
	oBrwVEU:AddButton(STR0002,{|| VA0100041_Manutencao(2) },,2,2) // Visualizar
	oBrwVEU:SetDescription(STR0001) // Envio de E-mails automaticos
	oBrwVEU:SetFilterDefault("@ VEU_FILIAL='"+xFilial("VEU")+"'")
	oBrwVEU:DisableDetails()
	oBrwVEU:DisableLocate()
	oBrwVEU:SetAmbiente(.F.)
	oBrwVEU:SetWalkthru(.F.)
	oBrwVEU:SetInsert(.f.)
	oBrwVEU:SetUseFilter(.f.)
	oBrwVEU:lOptionReport := .f.
	oBrwVEU:Activate()
	oBrwVEU:oBrowse:Align := CONTROL_ALIGN_ALLCLIENT

	oTipos := TWBrowse():New(00,00,80,80,,,,oPanTip,,,,,,,,,,,,.F.,,.T.,,.F.,,,)
	oTipos:AddColumn( TCColumn():New( STR0011 , { || aTipos[oTipos:nAT,1]+" - "+aTipos[oTipos:nAT,2] } ,,,,"LEFT"  ,100,.F.,.F.,,,,.F.,) ) // Tipo
	oTipos:nAt := 1
	oTipos:SetArray(aTipos)
	oTipos:bChange := { || VA0100101_Eventos() , VA0100031_Observacao() , VA0100021_FiltraBrowse() }
	oTipos:Align := CONTROL_ALIGN_ALLCLIENT

	oEvent := TWBrowse():New(00,00,80,80,,,,oPanEve,,,,,,,,,,,,.F.,,.T.,,.F.,,,)
	oEvent:AddColumn( TCColumn():New( STR0012 , { || aEvent[oEvent:nAT,1]+" - "+aEvent[oEvent:nAT,2] } ,,,,"LEFT"  ,100,.F.,.F.,,,,.F.,) ) // Eventos
	oEvent:nAt := 1
	oEvent:SetArray(aEvent)
	oEvent:bChange := { || VA0100031_Observacao() , VA0100021_FiltraBrowse() }
	oEvent:Align := CONTROL_ALIGN_ALLCLIENT

	@ 00,00 GET oObsMEMO VAR cObsMEMO OF oPanObs MEMO SIZE 80,80 PIXEL READONLY MEMO
	oObsMEMO:Align := CONTROL_ALIGN_ALLCLIENT

ACTIVATE MSDIALOG oVEIA010 

Return NIL

/*/{Protheus.doc} ModelDef
Definição do modelo de Dados

@author Andre Luis Almeida
@since 25/06/2025
@version 1.0
@Return oModel
/*/
Static Function ModelDef()

Local oStrCAB := FWFormStruct( 1, "VEU", { |cCampo|  ALLTRIM(cCampo) == "VEU_EVENTO" } )
Local oStrVEU := FWFormStruct( 1, "VEU")

oStrCAB:SetProperty('VEU_EVENTO', MODEL_FIELD_OBRIGAT, .f.)
oStrVEU:SetProperty('VEU_EVENTO', MODEL_FIELD_OBRIGAT, .f.)
oStrVEU:SetProperty('VEU_FILIAL', MODEL_FIELD_INIT , FwBuildFeature(STRUCT_FEATURE_INIPAD, 'xFilial("VEU")')) // Inicializador Padrão
oStrVEU:SetProperty('VEU_CODIGO', MODEL_FIELD_INIT , FwBuildFeature(STRUCT_FEATURE_INIPAD, 'GETSXENUM("VEU","VEU_CODIGO")')) // Inicializador Padrão
oStrVEU:SetProperty('VEU_EMAIL' , MODEL_FIELD_VALID, FwBuildFeature(STRUCT_FEATURE_VALID , "IsEmail( FwFldGet('VEU_EMAIL') )")) // Valid
oStrVEU:SetProperty('VEU_EMAIL' , MODEL_FIELD_WHEN , { || Empty(FwFldGet('VEU_FUNCAO')) })
oStrVEU:SetProperty('VEU_FUNCAO', MODEL_FIELD_WHEN , { || Empty(FwFldGet('VEU_EMAIL')) })

oModel := MPFormModel():New("VEIA010", /* bPre */ , {|| VA0100051_TudoOK() } /* bPost */ , /* bCommit */ , /* bCancel */ )
oModel:AddFields( 'VEUMASTER', /*cOwner*/, oStrCAB, /* <bPre> */ , /* <bPost> */ , /* <bLoad>  { |oModel| loadCab(oModel) }*/ )
oModel:AddGrid( 'VEUDETAIL', 'VEUMASTER', oStrVEU)
oModel:GetModel('VEUMASTER'):SetOnlyQuery( .T. ) // Comando para NÃO SALVAR

oModel:SetDescription(STR0001) // Envio de E-mails automaticos
oModel:GetModel("VEUDETAIL"):SetUniqueLine({"VEU_EMAIL","VEU_FUNCAO"})
oModel:GetModel('VEUDETAIL'):SetOptional( .T. ) // Deixar passar em branco

oModel:SetRelation('VEUDETAIL', { { 'VEU_FILIAL' , 'xFilial("VEU")' } , { 'VEU_EVENTO' , 'VEU_EVENTO' } } )
oModel:SetPrimaryKey( { "VEU_FILIAL", "VEU_CODIGO" } )

oModel:InstallEvent("VEIA010", /*cOwner*/, VEIA010EVDEF():New() )

Return oModel

/*/{Protheus.doc} ViewDef
Definição do interface

@author Andre Luis Almeida
@since 25/06/2025
@version 1.0
@Return oView
/*/
Static Function ViewDef()
Local oView
Local oModel := ModelDef()
Local oStrVEU := FWFormStruct(2, "VEU", { |cCampo| !ALLTRIM(cCampo) $ "VEU_FILIAL/VEU_CODIGO/VEU_EVENTO/" } )
//
oView := FWFormView():New()
oView:SetModel(oModel)
oView:SetCloseOnOk({||.T.})
oView:CreateHorizontalBox( 'TELAVEU' , 100 )
oView:AddGrid( 'VIEW_VEU', oStrVEU, 'VEUDETAIL' )
oView:SetOwnerView( "VIEW_VEU" , "TELAVEU" )
//
Return oView

/*/{Protheus.doc} VA0100011_LevantaEmails
	Retorna todos os E-mails de um determinado Evento
	
	@author Andre Luis Almeida
	@since 19/10/2018
/*/
Function VA0100011_LevantaEmails( cEvento , cFilEvent )
Local cEmails := ""
Local cQAlSQL := "SQLVEU"
Local cQuery  := ""
Local cFilVEU := VA0100081_FilialVEU( cFilEvent ) // Filial a ser utilizada
cQuery := "SELECT VEU_EMAIL , VEU_FUNCAO "
cQuery += "  FROM "+RetSqlName("VEU")
cQuery += " WHERE VEU_FILIAL='"+cFilVEU+"'"
cQuery += "   AND VEU_EVENTO='"+Alltrim(cEvento)+"'"
cQuery += "   AND D_E_L_E_T_=' '"
dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery ), cQAlSQL , .F., .T. )
While !( cQAlSQL )->( Eof() )
	If !Empty(( cQAlSQL )->( VEU_EMAIL ))
		cEmails += Alltrim(( cQAlSQL )->( VEU_EMAIL ))+";"
	Else
		cEmails += &(Alltrim(( cQAlSQL )->( VEU_FUNCAO )))+";"
	EndIf
	( cQAlSQL )->( DbSkip() )
EndDo
( cQAlSQL )->( DbCloseArea() )
DbSelectArea("VEU")
If !Empty(cEmails)
	cEmails := left(cEmails,len(cEmails)-1) // Retirar ultimo ;
EndIf
Return lower(cEmails)

/*/{Protheus.doc} VA0100021_FiltraBrowse
	Filtra Browse e carrega variaveis utilizadas no SX3
	
	@author Andre Luis Almeida
	@since 24/06/2025
/*/
Static Function VA0100021_FiltraBrowse()
	cCodEve := aEvent[oEvent:nAT,1] // Evento selecionado
	cDesEve := aTipos[oTipos:nAT,2]+" - "+aEvent[oEvent:nAT,2] // Descrição do Evento selecionado
	oBrwVEU:DeleteFilter("EVENTO")
	oBrwVEU:AddFilter(aEvent[oEvent:nAT,2],"@ VEU_EVENTO='"+cCodEve+"'",.f.,.t.,,,,"EVENTO")
	oBrwVEU:ExecuteFilter(.t.)
	oBrwVEU:Refresh()
	oBrwVEU:GoTop()
Return

/*/{Protheus.doc} VA0100031_Observacao
	Monta a Observação dos Eventos
	
	@author Andre Luis Almeida
	@since 24/06/2025
/*/
Static Function VA0100031_Observacao()
cObsMEMO := "<< "+aEvent[oEvent:nAT,2]+" >>"+CHR(13)+CHR(10)
cObsMEMO += aEvent[oEvent:nAT,3]
oObsMEMO:Refresh()
Return

/*/{Protheus.doc} VA0100041_Manutencao()
Manutenção no Cadastro dos E-mails automaticos

@author Andre Luis Almeida
@since 25/06/2025
@version 1.0
@return NIL
/*/
Static Function VA0100041_Manutencao(nOpc)
Local oView
Private oModel
Private cCadastro := cDesEve
oView := FWViewExec():New()
oView:setSource("VEIA010")
oView:setModal(.F.)
oView:setTitle(cCadastro)
If nOpc == 4
	oView:setOperation( MODEL_OPERATION_UPDATE ) // Manutenção: Sempre altera para gravar o Filho VEU
Else
	oView:setOperation( MODEL_OPERATION_VIEW ) // Visualizar
EndIf
oView:setReduction(20) // Redução de 20% da tela
oView:openView(.F.)
oView:DeActivate()
//
Return

/*/{Protheus.doc} VA0100051_TudoOK
	Tudo OK da Tela de Cadastro
	
	@author Andre Luis Almeida
	@since 25/06/2025
/*/
Static Function VA0100051_TudoOK()
Local lRet := .t.
Local nCntFor := 0
If oModel:GetOperation() == MODEL_OPERATION_INSERT .Or. oModel:GetOperation() == MODEL_OPERATION_UPDATE
	oModVEU := oModel:GetModel("VEUDETAIL")
	For nCntFor := 1 to oModVEU:Length()
		oModVEU:GoLine(nCntFor)
		If Empty(oModVEU:GetValue("VEU_EMAIL")) .and. Empty(oModVEU:GetValue("VEU_FUNCAO")) 
			Help(" ",1,"OBRIGAT2",,"'"+RetTitle("VEU_EMAIL")+"' "+STR0009+" '"+RetTitle("VEU_FUNCAO")+"'",4,1) // ou
			lRet := .f.
			Exit
		EndIf
	Next
EndIf
Return lRet

/*/{Protheus.doc} VA0100061_EnviarEmail
	Enviar E-mail pelo Evento
	
	@author Andre Luis Almeida
	@since 26/06/2025
/*/
Function VA0100061_EnviarEmail(cFilEvent,cEvento,cTitEmail,cMsgEmail,cDefEmail)
Local oEmailHlp   := DMS_EmailHelper():New()
Local cEmails     := ""
Local cFilVEU     := VA0100081_FilialVEU( cFilEvent ) // Filial a ser utilizada
Default cTitEmail := "DMS"
Default cMsgEmail := ""
Default cDefEmail := ""
cEmails := VA0100011_LevantaEmails( cEvento , cFilVEU ) // E-mail's destinatarios
If !Empty(cDefEmail)
	cEmails += IIf(!Empty(cEmails),";","")+lower(cDefEmail)
EndIf
If !Empty(cEmails)
	oEmailHlp:Send({{'assunto' , cTitEmail },;
					{'mensagem', cMsgEmail },;
					{'destino' , cEmails   }})
EndIf
Return

/*/{Protheus.doc} VA0100071_ExisteEmail
	Verifica se existe Email cadastrado para o Evento
	
	@author Andre Luis Almeida
	@since 27/06/2025
/*/
Function VA0100071_ExisteEmail(cFilEvent,cEvento)
Local cQuery      := ""
Local cFilVEU     := VA0100081_FilialVEU( cFilEvent ) // Filial a ser utilizada
cQuery := "SELECT R_E_C_N_O_ "
cQuery += "  FROM "+RetSqlName("VEU")
cQuery += " WHERE VEU_FILIAL='"+cFilVEU+"'"
cQuery += "   AND VEU_EVENTO='"+Alltrim(cEvento)+"'"
cQuery += "   AND D_E_L_E_T_=' '"
Return ( FM_SQL(cQuery) > 0 )

/*/{Protheus.doc} VA0100081_FilialVEU
	Retorna a Filial a ser utilizada na tabela 
	
	@author Andre Luis Almeida
	@since 30/06/2025
/*/
Static Function VA0100081_FilialVEU( cFilEvent )
Local cFilVEU     := xFilial("VEU") // Filial LOGADA
Default cFilEvent := cFilVEU // Default: Filial LOGADA
// Verifica se a tabela VEU esta com o mesmo compartilhamento da tabela referente Filial enviada para a função (cFilEvent)
If cFilVEU <> cFilEvent .and. len(Alltrim(cFilVEU)) == len(Alltrim(cFilEvent))
	cFilVEU := cFilEvent // Utilize a Filial enviada para a função (cFilEvent)
EndIf
Return cFilVEU

/*/{Protheus.doc} VA0100091_Tipos
	Tipos dos Eventos
	
	@author Andre Luis Almeida
	@since 24/06/2025
/*/
Static Function VA0100091_Tipos()
aTipos := {}
// Primeiro - Padrão DMS
aAdd(aTipos,{"001",STR0014}) // Atendimento de Veículos/Máquinas
aAdd(aTipos,{"002",STR0015}) // Pedido de Solicitação de Transferência de Peças
// Por ultimo - CUSTOMIZADO
If ExistBlock("VEIA010E") // Se existir Ponto de Entrada VEIA010E para customizar os Eventos
	aAdd(aTipos,{"USR",STR0013}) // Eventos Customizados
EndIf
Return()

/*/{Protheus.doc} VA0100101_Eventos
	Eventos de Envio de E-mail
	
	@author Andre Luis Almeida
	@since 24/06/2025
/*/
Static Function VA0100101_Eventos()
Local nEveCust := 0
Local aEveCust := {}
Local cTipo    := aTipos[oTipos:nAT,1]
aEvent := {}
Do Case

	Case cTipo == "001" // Atendimento de Veículos/Máquinas
		// Codigos 1 a 6 é legado. NAO alterar os codigos.
		aAdd(aEvent,{"1",STR0016,STR0017}) // Pendente Aprovação / Envio de e-mail quando o Atendimento de Veículos/Máquinas ficar Pendente Aprovação.
		aAdd(aEvent,{"2",STR0018,STR0019}) // Pre-Aprovação / Envio de e-mail quando o Atendimento de Veículos/Máquinas for Pré-Aprovado.
		aAdd(aEvent,{"3",STR0020,STR0021}) // Aprovação / Envio de e-mail quando o Atendimento de Veículos/Máquinas for Aprovado.
		aAdd(aEvent,{"4",STR0022,STR0023}) // Reprovação / Envio de e-mail quando o Atendimento de Veículos/Máquinas for Reprovado.
		aAdd(aEvent,{"5",STR0024,STR0025}) // Finalização / Envio de e-mail quando o Atendimento de Veículos/Máquinas for Finalizado.
		aAdd(aEvent,{"6",STR0026,STR0027}) // Cancelamento / Envio de e-mail quando o Atendimento de Veículos/Máquinas for Cancelado.

	Case cTipo == "002" // Pedido de Solicitação de Transferência de Peças
		aAdd(aEvent,{"002001",STR0028,STR0029}) // Incluir / Envio de e-mail para esta Filial quando for incluido um Pedido de Transferência solicitado por outra Filial.
		aAdd(aEvent,{"002002",STR0030,STR0031}) // Aceitar / Envio de e-mail quando a Solicitação de Pedido de Transferência desta Filial for Aceita.
		aAdd(aEvent,{"002003",STR0032,STR0033}) // Rejeitar / Envio de e-mail quando a Solicitação de Pedido de Transferência desta Filial for Rejeitada.

	Case cTipo == "USR" // Eventos Customizados
		/*
			VEIA010E - Ponto de Entrada utilizado para Customizar Eventos
				Podem ser customizados Eventos de "000" ... "ZZZ" ( código do Evento tamanho 3 )
				Retorno do Ponto de Entrada (vetor aEveCust):
					aadd(aEveCust,{"001","Evento 1","Observacao 1"})
					aadd(aEveCust,{"002","Evento 2","Observacao 2"})
					aadd(aEveCust,{"003","Evento 3","Observacao 3"})
					aadd(aEveCust,{"004","Evento 4","Observacao 4"})
					aadd(aEveCust,{"005","Evento 5","Observacao 5"})
		
			Função do DMS para verificar se existe algum e-mail a ser enviado para o Evento:
				VA0100071_ExisteEmail( FILIAL , "USR" + CODIGO_EVENTO )

			Função do DMS para enviar e-mail através do Evento:
				VA0100061_EnviarEmail( FILIAL , "USR" + CODIGO_EVENTO , TITULO_EMAIL , MENSAGEM_EMAIL , EMAIL_DEFAULT )
				
			Exemplo de chamadas:
				VA0100061_EnviarEmail( "0101" , "USR002" , "TITULO 222" , "MENSAGEM (CORPO) DO EMAIL 22222222" , "vendedor@empresa.com.br" )
				VA0100061_EnviarEmail( "0101" , "USR005" , "TITULO 555" , "MENSAGEM (CORPO) DO EMAIL 55555555" , "vendedor@empresa.com.br" )

			Configurações:
				MV_EMCONTA = Usuário/e-mail de envio
				MV_EMSENHA = Senha e-mail de envio
				MV_RELSERV = Server de envio
				MV_RELAUTH = Determina se o Servidor de E-mail necessita de Autenticação
				MV_RELAUSR = Usuário para Autenticação no Servidor de E-mail
				MV_RELAPSW = Senha para Autenticação no Servidor de E-mail
		*/
		If ExistBlock("VEIA010E") // Existe o Ponto de Entrada VEIA010E para customizar os Eventos
			aEveCust := ExecBlock("VEIA010E",.f.,.f.)
			If ( ValType(aEveCust) == "A" )
				For nEveCust := 1 to len(aEveCust)
					If len(aEveCust[nEveCust,1]) <= 3 .and. len(aEveCust[nEveCust]) == 3
						aadd(aEvent,{"USR"+aEveCust[nEveCust,1],aEveCust[nEveCust,2],aEveCust[nEveCust,3]})
					EndIf
				Next
			EndIf
		EndIf
EndCase
oEvent:nAt := 1
oEvent:SetArray(aEvent)
oEvent:Refresh()
Return()