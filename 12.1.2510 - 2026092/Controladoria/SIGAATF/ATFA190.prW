#INCLUDE "protheus.ch"
#INCLUDE "TCBROWSE.CH"
#INCLUDE "ATFA190.CH"
#INCLUDE "FWMBROWSE.CH"

STATIC _oATFA1901

// 17/08/2009 - Ajuste para filiais com mais de 2 caracteres.

/*                                 
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ATFA190   ºAutor  ³Marcos S. Lobo      º Data ³  11/13/03   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Manutencao da amarracao Ativo (N1) x Pessoas (R0)	          º±±
±±º          ³Associacao cria Responsaveis pelos Bens (SND)               º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function ATFA190(nPosArotina,lAutomato)

Local cArqMain		:= "SND"
Local aAreaATF90	:= GetArea()

Private cCadastro	:= STR0001 /// "Responsáveis pelos Bens"

//-- Central de automação
Default lAutomato  := .F.
Default nPosArotina :=  0

dbSelectArea("SX2")
dbSetOrder(1)
If dbSeek(cArqMain)
	cCadastro	:= X2Nome()
Endif

Private aRotina := MenuDef()

SetKey(VK_F12,{|| Pergunte("AFA190",.T.) })

dbSelectArea(cArqMain)

If !lAutomato
	MsSeek(xFilial(cArqMain))
	if hasSmartX()  //Função para validar se o ambiente esta preparado para SmartX
		setSmartX() //Seta o SmartX no MBrowse
	endif
	mBrowse( 6, 1,22,75,cArqMain,,,,,,)
Else//-- Central de automação
	If nPosArotina  == 8  //limpa Historico via automacao
		bBlock := &( "{ ||" + aRotina[ nPosArotina,2 ] + " }" )
		Eval( bBlock )
	Else
		bBlock := &( "{ |a,b,c,d| " + aRotina[ nPosArotina,2 ] + "(a,b,c,d) }" )
		Eval( bBlock, Alias(), (Alias())->(Recno()),nPosArotina,lAutomato)
	EndIf
EndIF

SET KEY VK_F12 TO

RestArea(aAreaATF90)
Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³AF190Vis  ºAutor  ³Marcos S. Lobo      º Data ³  13/11/03   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Visualização da Amarração Responsáveis x Bens (SND)         º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP - SIGAATF                                               º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function AF190Vis(cAlias,nReg,nOpc)

If Empty(cAlias)
	cAlias := Alias()
Endif

If Empty(nReg)
	nReg := (cAlias)->(Recno())
Endif

AxVisual(cAlias,nReg,nOpc)

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³AF190Inc  ºAutor  ³Marcos S. Lobo      º Data ³  13/11/03   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Inclusão  da Amarração Responsáveis x Bens (SND)            º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP - SIGAATF                                               º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/                            
Function AF190Inc(cAlias,nReg,nOpc,lAutomato)

Default lAutomato := .F.

If Empty(cAlias)
	cAlias := Alias()
Endif

If Empty(nReg)
	nReg := (cAlias)->(Recno())
Endif

If Empty(mv_par01) .or. ValType(mv_par01) <> "N"
	Pergunte("AFA190",.F.)
Endif

If Empty(mv_par02) .or. ValType(mv_par02) <> "N"
	Pergunte("AFA190",.F.)
Endif

PUBLIC cNDCODRESP := ""
If mv_par01 == 1 						/// SE ESTA CONFIGURADO PARA REPETIR O ULTIMO RESPONSAVEL
	If !SND->(Eof())						/// SE JA FOI FEITA INCLUSAO ESTARÁ POSICIONADO NO ÚLTIMO
		cNDCODRESP := SND->ND_CODRESP			/// ENTAO CARREGA O INICIALIZADOR PADRAO
	Endif
Endif

PUBLIC cNDCBASE	:= ""
PUBLIC cNDITEM	:= ""
If mv_par02 == 1						/// SE ESTA CONFIGURADO PARA REPETIR O ULTIMO BEM
	dbSetOrder(2)
	If !SND->(Eof())	.AND. MsSeek(xFilial("SND")+SND->ND_CBASE+SND->ND_ITEM)					/// PROCURA O MAIS PROXIMO					/// SE JA FOI FEITA INCLUSAO ESTARÁ POSICIONADO NO ÚLTIMO
		cNDCBASE := SND->ND_CBASE				/// ENTAO CARREGA OS INICIALIZADORES PADRAO
		cNDITEM	 := SND->ND_ITEM
	Endif
Endif

If !lAutomato
	If AxInclui(cAlias,nReg,nOpc,,,,"Af190TOk()",,,,,,.T.) == 1
		Af190PEGRV(nOpc)
		RecLock("SND",.F.)
		Field->ND_SEQUENC := NextSNDSEQ(SND->ND_CBASE,SND->ND_ITEM)
		SND->(MsUnlock())
	Endif
Else//--Central de automação
	If FindFunction("GetParAuto")
		aRetAuto  := GetParAuto("ATFA190TestCase")
		
	 If AxInclui(cAlias,nReg,nOpc,,,,"Af190TOk()",,,,{},aRetAuto) == 1
		Af190PEGRV(nOpc)
		RecLock("SND",.F.)
		Field->ND_SEQUENC := NextSNDSEQ(SND->ND_CBASE,SND->ND_ITEM)
		SND->(MsUnlock())
	 EndIf
	EndIf
EndIf		
		
If mv_par01 != 1
	cNDCODRESP := ""
Endif
If mv_par02 != 1
	cNDCBASE := ""
	cNDITEM := ""
Endif

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³AF190Alt  ºAutor  ³Marcos S. Lobo      º Data ³  13/11/03   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Alteração da Amarração Responsáveis x Bens (SND)            º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP - SIGAATF                                               º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function AF190Alt(cAlias,nReg,nOpc,lAutomato)

Local aAlter := {"ND_CODRESP", "ND_STATUS", "ND_DTINI", "ND_DTFIM", "ND_ITEM"}
Default lAutomato := .F.

If Empty(cAlias)
	cAlias := Alias()
Endif

If Empty(nReg)
	nReg := (cAlias)->(Recno())
Endif
//Verificar se tem campos de usuarios a adicionar ao array aAlter
Atf190VUsu(aAlter)

If !lAutomato
	If SND->ND_STATUS == '3' //Se Transferido
		HELP("",1,"NOALTTRF",,STR0043,1,0)    //"O cadastro de Amarração Responsáveis x Bens está com status igual a Transferido. Não serão permitidas alterações."	
	ElseIf AxAltera(cAlias,nReg,nOpc,,aAlter,,,,,,,,,.T.) == 1
		Af190PEGRV(nOpc)
		// CONFIRMOU A ALTERACAO
	Endif
Else//--Central de automação
	If FindFunction("GetParAuto")
		aRetAuto  := GetParAuto("ATFA190TestCase")
	
		If SND->ND_STATUS == '3' //Se Transferido
			HELP("",1,"NOALTTRF",,STR0043,1,0)    //"O cadastro de Amarração Responsáveis x Bens está com status igual a Transferido. Não serão permitidas alterações."				
		ElseIf AxAltera(cAlias,nReg,4,,/*aAlter*/,,,,,,,{},aRetAuto) == 1
			Af190PEGRV(nOpc)
			// CONFIRMOU A ALTERACAO
		EndIf
	EndIf 
EndIf
Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³AF190Del  ºAutor  ³Marcos S. Lobo      º Data ³  13/11/03   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Exclusão da Amarração Responsáveis x Bens (SND)             º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP - SIGAATF                                               º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function AF190Del(cAlias,nReg,nOpc,lAutomato)

Local aAreaND     := {}
Default lAutomato := .F.

If Empty(cAlias)
	cAlias := Alias()
Endif

If Empty(nReg)
	nReg := (cAlias)->(Recno())
Endif

dbSelectArea(cAlias)
dbGoTo(nReg)
aAreaND := GetArea()

If !lAutomato
	If SND->ND_STATUS == "1"
		If AxVisual(cAlias,nReg,nOpc) == 1
			Af190PEGRV(nOpc)
			RecLock(cAlias,.F.)
			(cAlias)->(dbDelete())
			(cAlias)->(MsUnLock())
		Endif
	Else
		HELP("",1,"SNDSTAT23")
	Endif
Else //--Central de automação 
	If SND->ND_STATUS == "1"
		If AxDeleta(cAlias,nReg,nOpc,,,,,,,,,) == 1
			Af190PEGRV(nOpc)
		Endif
	Else
		HELP("",1,"SNDSTAT23")
	Endif
EndIf
Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³AF190Vld  ºAutor  ³Marcos S. Lobo      º Data ³  11/14/03   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Validações disparadas dos campos do cadastro                º±±
±±º          ³ da Amarração Responsáveis x Bens (SND)                     º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºSintaxe   ³ cCpo = NOME DO CAMPO                                       º±±
±±º		     ³ cConteud = Conteudo a ser validado                         º±±
±±º		     ³ lPodeBr = Indica se o conteudo pode ser branco			  º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function Af190Vld(cCpo,cConteud,lPodeBr,nOpc)

Local lVldOk	:= .T.
Local nOrdSND	:= 1
Local nRecSND 	:= 1
Local aAreaVld	:= {}

aAreaVld := GetArea()
dbSelectArea("SND")
nOrdSND := IndexOrd()
nRecSND := Recno()

DEFAULT lPodeBr := .F.

If Empty(cConteud)
	If lPodeBr
		Return(.T.)
	Else
		Help("",1,"VAZIO")
		Return(.F.)
	Endif
Endif

DO CASE
	CASE cCpo == "ND_CODRESP"									/// VALIDACAO DO CODIGO DO RESPONSAVEL
		dbSelectArea("RD0")
		dbSetOrder(1)
		If !MsSeek(xFilial("RD0")+cConteud,.F.)					/// VALIDA SE EXISTE NO CADASTRO DE PESSOAS (RD0)
			HELP("",1,"ND_CODIGO",,STR0041,1,0)    // Código do responsavel invalido.
			lVldOk := .F.
		Endif
		M->ND_NMRESP := RD0->RD0_NOME							/// SE EXISTIR ATUALIZA O CAMPO NOME (VIRTUAL)

	CASE cCpo == "ND_CBASE"										/// VALIDACAO DO CODIGO BASE DO BEM
		dbSelectArea("SN1")
		dbSetOrder(1)
		If SN1->N1_CBASE <> cConteud							/// SE NAO ESTIVER POSICIONADO NO BEM
			MsSeek(xFilial("SN1")+cConteud,.T.)					/// PROCURA O MAIS PROXIMO
			M->ND_CBASE := SN1->N1_CBASE						/// E SUGERE O ENCONTRADO
		Endif
		M->ND_ITEM := SN1->N1_ITEM
		M->ND_DESCBEM := SN1->N1_DESCRIC						/// ATUALIZA A DESCRICAO DO CAMPO DESCRICAO DO BEM (VIRTUAL)
	CASE cCpo == "ND_ITEM"										/// VALIDACAO DO ITEM BASE DO BEM
		dbSelectArea("SN1")
		dbSetOrder(1)
		If !MsSeek(xFilial("SN1")+cConteud,.F.)					/// VALIDA SE EXISTE A CHAVE COD.BASE+ITEM NO ATIVO
			HELP("",1,"ND_CBASE")
			lVldOk := .F.
		Endif
		M->ND_DESCBEM := SN1->N1_DESCRIC						/// SE ESTIVER VALIDO ATUALIZA O CAMPO DESCRICAO DO BEM (VIRTUAL)
	CASE cCpo == "ND_DTFIM"         							/// VALIDACAO DA DATA FINAL
		If M->ND_DTFIM < M->ND_DTINI							/// NAO PODE SER MENOR QUE A DATA INICIAL
			HELP("",1,"ND_DTFIM")
			lVldOk := .F.
		Endif
	CASE cCpo == "ND_STATUS"									/// VALIDACAO DO STATUS
		If nOpc == 4                                 			/// NA ALTERACAO
			If !cConteud $ "12"										/// USUARIO SO PODE INATIVAR/MANTER ATIVO
				HELP("",1,"AF190STATUS",,STR0009,1,0)					/// TRANSFERIR SOMENTE PELA TRANSFERÊNCIA
				lVldOk := .F.
			Endif
			If lVldOk .and. M->ND_STATUS == "2" .and. Empty(M->ND_DTFIM)
				M->ND_DTFIM := dDataBase							/// SE FOI INATIVADO GRAVA DATA DE BAIXA
			Endif
		ElseIf cConteud == "3"										/// SO INCLUI RESPONSAVEL ATIVO
			HELP("",1,"AF190STATUS",,STR0009,1,0)						/// TRANSFERIR SOMENTE PELA TRANSFERÊNCIA
			lVldOk := .F.
		Endif
ENDCASE

dbSelectArea("SND")
dbSetOrder(nOrdSND)
MsGoTo(nRecSND)
RestArea(aAreaVld)

Return(lVldOk)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³Af190TOk  ºAutor  ³Marcos S. Lobo      º Data ³  11/14/03   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Validação TudoOk  da Amarração Responsáveis x Bens (SND)    º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function Af190TOk()

Local lTOk		:= .T.
Local nOrdSND	:= 1
Local nRecSND	:= 1
Local aAreaSND	:= {}
Local aAreaRD0	:= {}

aAreaSND := GetArea()
aAreaRD0 := RD0->(GetArea())
dbSelectArea("SND")
nOrdSND := IndexOrd()
nRecSND	:= Recno()

SND->(dbSetOrder(1))
If MsSeek(xFilial("SND")+M->(ND_CODRESP+ND_CBASE+ND_ITEM)+"1",.F.)		/// SE ENCONTRAR RESPONSAVEL ATIVO
	HELP("",1,"EXISTCHAV")													/// BLOQUEIA COM HELP
	lTOk := .F.
Endif

dbSelectArea("RD0")
RD0->(dbSetOrder(1))
If RD0->(MsSeek(FWxFilial("RD0")+M->(ND_CODRESP),.F.)) .And. RD0->RD0_MSBLQL == "1"	/// SE ENCONTRAR RESPONSAVEL ATIVO
	HELP("",1,"AF190INATIVA",,STR0044,1,0)					/// TRANSFERIR SOMENTE PELA TRANSFERÊNCIA
	lTOk := .F.
Endif

dbSelectArea("SND")
dbSetOrder(nOrdSND)
MsGoTo(nRecSND)
RestArea(aAreaRD0)
RestArea(aAreaSND)

Return(lTOk)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³Af190N1xR0ºAutor  ³Marcos S. Lobo      º Data ³  11/13/03   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Manutenção de responsaveis chamada pelo Cadastro do Ativo   º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP - Chamada pelo ATFA012 (Cadastro de Bens) p/ Botão Enchoº±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function Af190N1xR0(cBaseCpy, cItemCpy)
Local aAreaN1R0	:= GetArea()
Local oModel	:= FWModelActive()
Local cNDCBASE	:= oModel:GetValue("SN1MASTER","N1_CBASE")
Local cNDITEM	:= oModel:GetValue("SN1MASTER","N1_ITEM")
Local nOpc		:= oModel:GetOperation()
Local nOrdSX3	:= SX3->(IndexOrd())
Local nRecSX3	:= SX3->(Recno())
Local nOrdSN1	:= 1
Local nRecSN1	:= 1
Local cPesq		:= GetNewPar("MV_AF190CP",SPACE(60))	/// CONTEUDO INICIAL DO CAMPO DE PESQUISA DO CAD. PESSOAS
Local cOrdP		:= GetNewPar("MV_AF190OP","1")			/// ORDEM INICIAL DE PESQUISA NO CAD. PESSOAS
Local aOrdP		:= {}
Local cFileTRB	:= ""
Local lOpcVisual:= nOpc <= 2
Local cX3Titulo	:= ""
Local nSTRB		:= 1
Local oSND     := oModel:GetModel( 'SNDDETAIL' )
Local oView := FWViewActive()
Local aAreaSND := GetArea()
Local lAlterado := .F.
Local lCopy	  := IsInCallStack("AF012CPY")
Local cExpFiltro := "RD0->RD0_MSBLQL == '2' " //Filtra apenas ativos

Default cBaseCpy := cNDCBASE
Default cItemCpy := cNDITEM  

If Empty(cPesq)
	cPesq := SPACE(60)
EndIf

dbSelectArea("SN1")
nOrdSN1 := SN1->(IndexOrd())
nRecSN1 := SN1->(Recno())

//// VARIAVEIS CRIADAS PARA POSSIBILIDADE DE MANIPULAÇÃO VIA PE
Private aCpoRD0 := {"RD0_CODIGO","RD0_NOME"} 			  /// CAMPOS PARA O BROWSE DE PESSOAS
Private aCpoSND := {"ND_CODRESP","ND_NMRESP"/*,"ND_STATUS"*/} /// CAMPOS PARA O BROWSE DE RESPONSAVEIS (TRBSND)

SET KEY VK_F4 TO										/// ZERA O F4 PARA NAO CHAMAR TELA DUPLICADA

dbSelectArea("SIX")										/// BUSCA INDICES DE PESQUISA NO SINDEX (CAD. PESSOAS)
dbSetOrder(1)
MsSeek("RD0",.T.)
While !Eof() .and. SIX->INDICE == "RD0"
	cDescSIX := SixDescricao()

	aAdd(aOrdP,SIX->ORDEM+" "+cDescSIX)
	If SIX->ORDEM == cOrdP
		cOrdP := SIX->ORDEM+" "+cDescSIX
	Endif
	dbSkip()
EndDo
If Len(aOrdP) == 0					/// SE NÃO ENCONTROU NO SINDEX
	aAdd(aOrdP,"1 "+STR0020)		/// USA INDICE PADRAO PELO CODIGO
Endif

If Select("TRBSND") <= 0												//// SE O ALIAS NAO ESTIVER ABERTO

	Af190Trb(aCpoSND)	

	If _oATFA1901 == Nil
		MsgAlert(STR0019)	//"Erro criando temporario ! Tente novamente depois..."
		Return
	Endif	

	If lCopy
		Af190TrbLd(cBaseCpy, cItemCpy)
	Else
		Af190TrbLd(cNDCBASE,cNDITEM)//// CARREGA COM OS DADOS DO CADASTRO (SND) / O ALIAS É FECHADO NA GRAVACAO
	EndIf
							
Endif																	

dbSelectArea("TRBSND")
dbSetOrder(1)

DEFINE MSDIALOG oDlgSND TITLE OemToAnsi(STR0001) FROM 00,00 TO 425,650 OF oMainWnd PIXEL	//"Responsáveis pelos Bens"
/// PESQUISA
@ 01,05 COMBOBOX oOrdP VAR cOrdP ITEMS aOrdP SIZE 140,06 PIXEL OF oDlgSND // FONT oDlg:oFont
oOrdP:cToolTip  := STR0010	//"Ordens de Pesquisa"
@ 12,05 GET oPesq VAR cPesq SIZE 120,08 OF oDlgSND PIXEL
oPesq:cF3 := "RD0"
oPesq:cToolTip	:= STR0011	//"Texto para Pesquisa"
@ 12,115 BUTTON STR0002 SIZE 30,10 ACTION {|| Af190Find(cPesq,"RD0",Val(Left(cOrdP,2))) } OF oDlgSND PIXEL //"Pesquisar"

/// BROWSES DO CADASTRO DE PESSOAS RD0
@ 25,05 SAY STR0012 OF oDlgSND PIXEL //"Pessoas Cadastradas"
@ 35,05 BROWSE oBrwRD0 ALIAS "RD0" SIZE 140,160 OF oDlgSND PIXEL

If !lOpcVisual				/// SE NAO FOR VISUALIZACAO
	@ 45,250 BTNBMP oIncRD0 RESOURCE "BMPINCLUIR" SIZE 20,20 DESIGN ACTION Apda020Mnt("RD0",RD0->(Recno()),3) OF oDlgSND MESSAGE STR0004//"Incluir"
Endif
//@ 45,270 BTNBMP oVisRD0 RESOURCE "PESQUISA" SIZE 20,20 DESIGN ACTION Apda020Mnt("RD0",RD0->(Recno()),2) OF oDlgSND MESSAGE STR0003//"Visualizar"
@ 45,270 BTNBMP oVisRD0 RESOURCE "PESQUISA" SIZE 20,20 DESIGN ACTION AxVisual("RD0",RD0->(Recno()),2) OF oDlgSND MESSAGE STR0003//"Visualizar"

DbSelectArea("RD0") // Forca abertura do RD0
nAlias := Select("RD0")
dbSelectArea("SX3")
dbSetOrder(2)
For nSTRB := 1 to Len(aCpoRD0)
	If MsSeek(aCpoRD0[nSTRB],.F.)
		cX3Titulo := alltrim(RetTitle(SX3->X3_CAMPO))
		oBrwRD0:AddColumn( TCColumn():New( cX3Titulo, FieldWBlock( x3_campo, nAlias ),AllTrim(X3_PICTURE),,, if(X3_TIPO=="N","RIGHT","LEFT"), If(X3_TAMANHO>Len(cX3Titulo),3+(X3_TAMANHO*3.7),3+(LEN(cX3Titulo)*3.7)), .F., .F.,,,, .F., ) )
	Endif
Next
oBrwRD0:Refresh()

/// BROWSE DOS RESPONSAVEIS ASSOCIADOS (TRB) SND
@ 25,175 SAY STR0013+ALLTRIM(cNDCBASE)+" - "+ALLTRIM(cNDITEM) OF oDlgSND PIXEL //"Responsaveis do Bem "
@ 35,175 BROWSE oBrwSND ALIAS "TRBSND" SIZE 140,160 OF oDlgSND PIXEL

nAlias := Select("TRBSND")
dbSelectArea("SX3")
dbSetOrder(2)
For nSTRB := 1 to Len(aCpoSND)
	If MsSeek(aCpoSND[nSTRB],.F.)
		cX3Titulo := alltrim(RetTitle(SX3->X3_CAMPO))
		oBrwSND:AddColumn( TCColumn():New( cX3Titulo, FieldWBlock( x3_campo, nAlias ),AllTrim(X3_PICTURE),,, if(X3_TIPO=="N","RIGHT","LEFT"), If(X3_TAMANHO>Len(cX3Titulo),3+(X3_TAMANHO*3.7),3+(LEN(cX3Titulo)*3.7)), .F., .F.,,,, .F., ) )
	Endif
Next
dbSelectArea("TRBSND")
oBrwSnd:Refresh()

/// BOTOES
If !lOpcVisual				/// SE NAO FOR VISUALIZACAO
	@ 065,150 BUTTON oAdd		PROMPT ">"		SIZE 20,12 ACTION {|| Af190TrbAdd() } OF oDlgSND MESSAGE STR0014 PIXEL	//"Adiciona" /// ADICIONA POSICIONADO
	@ 080,150 BUTTON oDel		PROMPT "<"   	SIZE 20,12 ACTION {|| Af190TrbDel() } OF oDlgSND MESSAGE STR0015 PIXEL	//"Remove"   /// DELETA POSICIONADO
Endif

@ 200,005 BUTTON oOk		PROMPT STR0016 SIZE 40,10 ACTION {|| /*nOpcSND := 1,*/oDlgSND:End() } OF oDlgSND MESSAGE STR0016+" (ALT+F4)" PIXEL //"Fechar"	/// GRAVA SOMENTE APOS SN1

If !lOpcVisual				/// SE NAO FOR VISUALIZACAO
	@ 105,150 BUTTON oAddAll	PROMPT "> >"	SIZE 20,12 ACTION {|| Af190AddAll() } OF oDlgSND MESSAGE STR0017 PIXEL	//"Adiciona Todos"/// ADICIONA TODOS
	@ 120,150 BUTTON oDelAll	PROMPT "< <" 	SIZE 20,12 ACTION {|| Af190DelAll() } OF oDlgSND MESSAGE STR0018 PIXEL	//"Remove Todos"  /// DELETA TODOS
	oBrwRD0:bLDblClick:= {|| Af190TrbAdd() }						/// DUPLO CLIQUE NO CAD. PESSOAS ADICIONA
	oBrwSND:bLDblClick:= {|| Af190TrbDel() }						/// DUPLO CLIQUE NOS RESP. ASSOCIADOS REMOVE
Endif

oOrdP:bLostFocus:= {|| RD0->(dbSetOrder(Val(Left(cOrdP,2)))), RD0->(MsSeek("",.T.)) , oBrwRD0:Refresh() }

dbSelectArea("RD0")
dbSetOrder(Val(Left(cOrdP,2)))
RD0->(dbSetFilter({|| &cExpFiltro },cExpFiltro))
oBrwRD0:Refresh()
MsSeek("",.T.)

dbSelectArea("TRBSND")
dbSetOrder(1)
MsSeek("",.T.)

ACTIVATE MSDIALOG oDlgSND CENTERED

SetKey( VK_F4, {|| Af190N1xR0(nOpc,M->N1_CBASE,M->N1_ITEM)} )

Af190PEGRV(nOpc)

SX3->(dbSetOrder(nOrdSX3))
SX3->(MsGoTo(nRecSX3))
SN1->(dbSetOrder(nOrdSN1))
SN1->(MsGoTo(nRecSN1))
RestArea(aAreaN1R0)

dbSelectArea("TRBSND")
If nOpc <= 2												/// SE A GRAVACAO NÃO FOI CONFIRMADA OU FOR VISUAL
	dbCloseArea()															/// SO FECHA O ALIAS
	
	// Apaga a tabela temporaria no banco de dados
	If _oATFA1901 <> Nil
		_oATFA1901:Delete()
		_oATFA1901 := Nil
	Endif	

	RestArea(aAreaSND)
	Return
Endif

dbSelectArea("TRBSND")
dbSetOrder(1)
SET DELETED OFF												/// E REMOVER DO TRB DIVERSAS VEZES E DEVE MANTER A ULTIMA
MsSeek("",.T.)												/// POSICAO QUE O USUÁRIO DEIXOU
While !TRBSND->(Eof())

	If nOpc == 5  	/// SE FOR EXCLUSÃO DO BEM
		If oSND:SeekLine( { {"ND_CODRESP", TRBSND->ND_CODRESP } } ) // SE O REGISTRO DE RESPONSAVEL ATIVO EXISTE
			oSND:DeleteLine() // DELETA A AMARRAÇÃO
			lAlterado := .T.
		Endif
	Else													/// SE FOR INCLUSÃO/ALTERAÇÃO
		If oSND:SeekLine( { {"ND_CODRESP", TRBSND->ND_CODRESP } } )								/// SE EXISTE REGISTRO ATIVO
			If TRBSND->(Deleted()) 									/// SE ESTÁ DELETADO DO TMP
				oSND:LoadValue("ND_STATUS", '2' )
				oSND:LoadValue("ND_DTFIM", dDataBase)
				lAlterado := .T.
			Endif
		ElseIf !TRBSND->(Deleted())							/// SE NÃO ENCONTROU E NÃO ESTA DELETADO
			if !oSND:IsEmpty() 
				oSND:AddLine()
				oSND:GoLine(oSND:Length())
			EndIf
			oSND:SetValue("ND_CODRESP", TRBSND->ND_CODRESP)
			oSND:LoadValue("ND_CBASE", cNDCBASE)
			oSND:LoadValue("ND_ITEM", cNDITEM)
			oSND:LoadValue("ND_STATUS", "1")
			oSND:SetValue("ND_DTINI", dDataBase)
			oSND:SetValue("ND_SEQUENC", NextSNDSEQ(cNDCBASE,cNDITEM))
			lAlterado := .T.
		Endif
	Endif
	
	dbSelectArea("TRBSND")
	TRBSND->(dbSkip())
Enddo
SET DELETED ON
dbSelectArea("TRBSND")
dbCloseArea()	// SO FECHA O ALIAS

// Apaga a tabela temporaria no banco de dados
If _oATFA1901 <> Nil
	_oATFA1901:Delete()
	_oATFA1901 := Nil
Endif

RestArea(aAreaSND)

Return lAlterado

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³Af190Find ºAutor  ³Marcos S. Lobo      º Data ³  11/17/03   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Localiza Pessoa no Browse do Cad. de Pessoas da tela de     º±±
±±º          ³amarração disparada pelo cadastro de Bens                   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function Af190Find(cPesq,cF2Seek,nOrd)
If !Empty(cPesq) .and. !Empty(cF2Seek)
	dbSelectArea(cF2Seek)
	dbSetOrder(nOrd)
	MsSeek(xFilial(cF2Seek)+ALLTRIM(cPesq),.T.)
	oBrwRD0:Refresh()
	oBrwRD0:SetFocus()
Endif
Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³Af190Trb  ºAutor  ³Marcos S. Lobo      º Data ³  11/17/03   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Cria o arquivo temporário com os Responsáveis pelo Bem      º±±
±±º          ³disparada da da tela de manutenção do cadastro de Bens	  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function Af190Trb(aCpoTela)

Local aStruTRB := {}
Local nSt      := 1

dbSelectArea("SX3")
dbSetOrder(2)
For nSt := 1 to Len(aCpoTela)
	If MsSeek(aCpoTela[nSt],.F.) .and. X3Uso(SX3->X3_USADO)
		aAdd(aStruTRB,{SX3->X3_CAMPO, SX3->X3_TIPO, SX3->X3_TAMANHO, SX3->X3_DECIMAL })
	Endif
Next

If Len(aStruTRB) <= 0
	Return
Endif

If Select("TRBSND") > 0
	dbSelectArea("TRBSND")
	dbCloseArea()
Endif

If _oATFA1901 <> Nil
	_oATFA1901:Delete()
	_oATFA1901 := Nil
Endif

_oATFA1901 := FWTemporaryTable():New( "TRBSND" )  
_oATFA1901:SetFields(aStruTRB) 
_oATFA1901:AddIndex("1", {"ND_CODRESP"})

//------------------
//Criação da tabela temporaria
//------------------
_oATFA1901:Create()  

Return()

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³Af190TrbLdºAutor  ³Marcos S. Lobo      º Data ³  11/17/03   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Carrega os responsáveis pelo Bem (SND) para o arquivo       º±±
±±º          ³de trabalho para mostrar no Browse                          º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function Af190TrbLd(cNDCBASE,cNDITEM)

Local cKeySND	:= xFilial("SND")+cNDCBASE+cNDITEM
Local aSTRB		:= TRBSND->(dbStruct())
Local nSTRB     := 1
Local cVirtSND	:= ""

dbSelectArea("SX3")
dbSetOrder(2)
For nSTRB := 1 to Len(aSTRB)
	If MsSeek(aSTRB[nSTRB,1],.F.) .and. SX3->X3_CONTEXT == "V"
		cVirtSND	+= "/"+ALLTRIM(SX3->X3_CAMPO)
	Endif
Next

dbSelectArea("SND")
dbSetOrder(2)
If MsSeek(cKeySND,.F.)
	While !SND->(Eof()) .and. cKeySND == SND->(ND_FILIAL+ND_CBASE+ND_ITEM)
		/// USAR SOMENTE RESPONSAVEIS ATIVOS
		If SND->ND_STATUS == "1"
			RegToMemory("SND",.F.,.T.)
			RecLock("TRBSND",.T.)
			For nSTRB := 1 to Len(aSTRB)
				If ALLTRIM(aSTRB[nSTRB,1])$cVirtSND					/// SE FOR CAMPO VIRTUAL
					&("Field->"+aSTRB[nSTRB,1]) := CriaVar(aSTRB[nSTRB,1])
				Else
					&("Field->"+aSTRB[nSTRB,1]) := &("SND->"+aSTRB[nSTRB,1])
				Endif
			Next
			TRBSND->(MsUnlock())
		Endif
		dbSelectArea("SND")
		SND->(dbSkip())
	EndDo
Endif

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³Af190TrbAdºAutor  ³Marcos S. Lobo      º Data ³  11/17/03   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Adiciona a pessoa posicionada no Browse de pessoas (RD0)    º±±
±±º          ³no arquivo temporário com os responsáveis pelo Bem          º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function Af190TrbAdd()

Local cKeyTRB 	:= ""

dbSelectArea("RD0")
cKeyTRB := RD0->RD0_CODIGO
dbSelectArea("TRBSND")
If !MsSeek(cKeyTRB,.F.)							/// SE NAO ESTA NO TRB
	RecLock("TRBSND",.T.)						/// ADICIONA COMO RESPONSAVEL ATIVO NO SND (TEMPORARIO)
	Field->ND_CODRESP := RD0->RD0_CODIGO
	Field->ND_NMRESP  := RD0->RD0_NOME
	
	TRBSND->(MsUnlock())
	oBrwSND:Refresh()
	If !Eof()							/// PASSA PARA O PROXIMO AUTOMATICAMENTE
		dbSelectArea("RD0")
		dbSkip()
		oBrwRD0:Refresh()
	Endif
Else											/// SE JA ESTA NO TRB
	Help("",1,"EXISTCHAV")					/// RETORNA HELP CHAVE JÁ EXISTE
	oBrwSND:Refresh()
	//Endif
Endif

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³Af190TrbDeºAutor  ³Marcos S. Lobo      º Data ³  11/17/03   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Exclui o responsável pelo Bem do arquivo temporário         º±±
±±º          ³e do browse na tela de manutenção chamada pelo ATFA010      º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function Af190TrbDel()

dbSelectArea("TRBSND")
If !Eof()
	RecLock("TRBSND",.F.)
	TRBSND->(dbDelete())
	TRBSND->(MsUnlock())
	//MsgInfo("Retirado: "+ALLTRIM(TRBSND->ND_NMRESP))
	oBrwSND:Refresh()
Else
	HELP("",1,"ARQVAZIO")
	oBrwSND:Refresh()
Endif

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³Af190DelAlºAutor  ³Marcos S. Lobo      º Data ³  11/17/03   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Deleta todos os responsáveis pelo bem do temporario no Brwseº±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function Af190DelAll()

Local nDelCnt := 0
Local cMsgDelAll := ""

dbSelectArea("TRBSND")
dbGoTop()
If !Eof()
	If MsgYesNo(STR0024)//"Deseja realmente excluir todos ?"
		While !TRBSND->(Eof())
			RecLock("TRBSND",.F.)
			TRBSND->(dbDelete())
			TRBSND->(MsUnlock())
			nDelCnt++
			dbSkip()
		Enddo
		oBrwSND:Refresh()
		If nDelCnt > 1
			cMsgDelAll := STR0025+ALLTRIM(STR(nDelCnt))+STR0026
		Else
			cMsgDelAll := STR0027
		Endif
		MsgInfo(cMsgDelAll)
	Endif
Else
	HELP("",1,"ARQVAZIO")
	oBrwSND:Refresh()
Endif

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³Af190AddAlºAutor  ³Marcos S. Lobo      º Data ³  11/19/03   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Adiciona todos as pessoas do cadastro como responsáveis peloº±±
±±º          ³Bem (grava no temporário).                                  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function Af190AddAll()

Local cKeyTRB	:= ""
Local nCount	:= 0

If !MsgYesNo(STR0028+chr(10)+STR0029)//"Se houver responsavel pelo bem inativo o mesmo será ativado !"#"Adiciona todos os responsáveis ?"
	Return
Endif

dbSelectArea("RD0")
dbSetOrder(1)
MsSeek(xFilial("RD0"),.T.)
While !RD0->(Eof())
	cKeyTRB := RD0->RD0_CODIGO
	dbSelectArea("TRBSND")
	dbSetOrder(1)
	If !MsSeek(cKeyTRB,.F.)					/// SE NAO ESTA NO TRB
		RecLock("TRBSND",.T.)						/// ADICIONA COMO RESPONSAVEL ATIVO NO SND (TEMPORARIO)
		Field->ND_CODRESP := RD0->RD0_CODIGO
		Field->ND_NMRESP  := RD0->RD0_NOME
		TRBSND->(MsUnlock())
		nCount++
	Endif
	dbSelectArea("RD0")
	RD0->(dbSkip())
EndDo
oBrwSND:Refresh()
If nCount == 1
	MsgInfo(STR0030)//"Responsavel Adicionado "
Else
	MsgInfo(STR0031+ALLTRIM(STR(nCount))+STR0026) /// "Adicionados"#" responsaveis "
Endif

dbSelectArea("TRBSND")
MsSeek("",.T.)
oBrwSND:SetFocus()

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³AF190GrvSnºAutor  ³Marcos S. Lobo      º Data ³  11/19/03   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Gravação do arquivo de Amarração Pessoas x Bens (SND)       º±±
±±º          ³a partir do arquivo temporario criado.                      º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function Af190GrvSND(nOpc,nOpca,cNDCBASE,cNDITEM)

Local aAreaSND := GetArea()
Local cFilSND  := xFilial("SND")
Local cKeySND  := ""

DEFAULT cNDCBASE := SN1->N1_CBASE
DEFAULT cNDITEM	 := SN1->N1_ITEM

If Select("TRBSND") <= 0
	Return
Endif

dbSelectArea("TRBSND")
If nOpca <> 1 .or. nOpc <= 2												/// SE A GRAVACAO NÃO FOI CONFIRMADA OU FOR VISUAL
	dbCloseArea()															/// SO FECHA O ALIAS
	/// FALTA FAZER O FERASE() PARA APAGAR O TRB E O INDICE TEMPORARIOS
	RestArea(aAreaSND)
	Return
Endif

dbSetOrder(1)												/// USA ORDEM DE RECNO POIS O USUÁRIO PODE ADICIONAR
SET DELETE OFF												/// E REMOVER DO TRB DIVERSAS VEZES E DEVE MANTER A ULTIMA
MsSeek("",.T.)												/// POSICAO QUE O USUÁRIO DEIXOU
While !TRBSND->(Eof())
	dbSelectArea("SND")
	dbSetOrder(1)
	SET DELETE ON
	cKeySND := cFilSND+TRBSND->ND_CODRESP+cNDCBASE+cNDITEM
	If nOpc == 5											/// SE FOR EXCLUSÃO DO BEM
		If MsSeek(cKeySND+"1",.F.)								/// SE O REGISTRO DE RESPONSAVEL ATIVO EXISTE
			RecLock("SND",.F.)
			SND->(dbDelete())									/// DELETA A AMARRAÇÃO
			SND->(MsUnlock())
		Endif
	Else													/// SE FOR INCLUSÃO/ALTERAÇÃO
		If MsSeek(cKeySND+"1",.F.)								/// SE EXISTE REGISTRO ATIVO
			If TRBSND->(Deleted()) 									/// SE ESTÁ DELETADO DO TMP
				RecLock("SND",.F.)
				Field->ND_STATUS := "2"								/// GRAVA COMO INATIVO PARA HISTORICO
				Field->ND_DTFIM  := dDataBase
				SND->(MsUnlock())
			Endif
		ElseIf !TRBSND->(Deleted())							/// SE NÃO ENCONTROU E NÃO ESTA DELETADO
			RecLock("SND",.T.)									/// CRIA REGISTRO COMO ATIVO
			Field->ND_FILIAL := cFilSND
			Field->ND_CODRESP:= TRBSND->ND_CODRESP
			Field->ND_CBASE	 := cNDCBASE
			Field->ND_ITEM	 := cNDITEM
			Field->ND_STATUS := "1"
			Field->ND_DTINI  := dDataBase
			Field->ND_SEQUENC := NextSNDSEQ(cNDCBASE,cNDITEM)
			SND->(MsUnlock())
		Endif
	Endif
	
	dbSelectArea("TRBSND")
	SET DELETE OFF
	TRBSND->(dbSkip())
Enddo

dbSelectArea("TRBSND")
SET DELETE ON
dbCloseArea()

RestArea(aAreaSND)

Return


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³NextSNDSEQºAutor  ³Marcos S. Lobo      º Data ³  11/20/03   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Obtem o próximo número de sequência para o responsável      º±±
±±º          ³na Chave COD.BASE + ITEM                                    º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function NextSNDSEQ(cNDCBASE,cNDITEM)///// NAO ESTA EM USO

Local aAreaOri  := GetArea()
Local cAliasOri := Alias()
Local cNDSEQUENC := ""
Local cQuerySND := ""


If cAliasOri == "SN1"
	If Empty(cNDCBASE)
		cNDCBASE := M->N1_CBASE
	Endif
	If Empty(cNDITEM)
		cNDITEM	:= M->N1_ITEM
	Endif
ElseIf cAliasOri == "SND"
	If Empty(cNDCBASE)
		cNDCBASE := M->ND_CBASE
	Endif
	If Empty(cNDITEM)
		cNDITEM := M->ND_ITEM
	Endif
Endif

dbSelectArea("SND")

cQuerySND := " SELECT MAX(ND_SEQUENC) ND_SEQUENC "
cQuerySND += " FROM "+RetSqlName("SND")
cQuerySND += " WHERE ND_FILIAL = '"+xFilial("SND")+"' "
cQuerySND += " AND ND_CBASE = '"+cNDCBASE+"' "
cQuerySND += " AND ND_ITEM = '"+cNDITEM+"' "
cQuerySND += " AND D_E_L_E_T_ = '' "
cQuerySND := ChangeQuery(cQuerySND)

If Select("MAXSND") > 0
	dbSelectArea("MAXSND")
	dbCloseArea()
Endif

dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuerySND),"MAXSND")	
dbSelectArea("MAXSND")
dbGoTop()

If Empty(MAXSND->ND_SEQUENC)
	cNDSEQUENC := STRZERO(1,LEN(SND->ND_SEQUENC))	
Else
	cNDSEQUENC := Soma1(MAXSND->ND_SEQUENC)
Endif

RestArea(aAreaOri)

Return(cNDSEQUENC)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ATFA190   ºAutor  ³Microsiga           º Data ³  11/20/03   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Efetua a transferência de responsaveis do Bem, chamada pela º±±
±±º          ³tela de transferência (atfa060) e cad. SN1 x RD0 (atfa190). º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function Af190Trans(nTpTrans,cArqOri)

DEFAULT cArqOri := Alias()
If FunName() $ "ATFA060/ATFA190"			/// CAD.RESPONSAVEL X BEM (BROWSE SND) ou CAD. ATIVO (BROWSE SN1)
	DEFAULT nTpTrans := 1					/// 1=POR BEM (UM a UM) / 2=POR RESPONSAVEL
Else
	DEFAULT nTpTrans := 2					/// 1=POR BEM (UM a UM) / 2=POR RESPONSAVEL
Endif

If nTpTrans == 1
	If cArqOri $ "SN1/SN2/SN3"
		If Pergunte("AF1901",.T.)				//// PERGUNTA RESPONSAVEL ORIGEM E DESTINO
			If cArqOri == "SN3
				cCBASE := SN3->N3_CBASE
				cITEM  := SN3->N3_ITEM
			ElseIf cArqOri == "SN2"
				cCBASE := SN3->N3_CBASE
				cITEM  := SN3->N3_ITEM
			Else
				cCBASE := SN1->N1_CBASE
				cITEM  := SN1->N1_ITEM
			Endif
			If Af190GrTrans(cCBASE,cITEM,mv_par01,mv_par02)
				MsgInfo(STR0034)//"Transferência de responsável efetuada."
			Endif
		Endif
	ElseIf cArqOri == "SND"
		If Pergunte("AF1902",.T.)				//// PERGUNTA SOMENTE O RESPONSAVEL DESTINO
			If Af190GrTrans(SND->ND_CBASE,SND->ND_ITEM,SND->ND_CODRESP,mv_par01)
				MsgInfo(STR0034)//"Transferência de responsável efetuada."
			Endif
		Endif
	Endif
Endif

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³Af190GrTraºAutor  ³Marcos S. Lobo      º Data ³  11/20/03   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Efetua a gravação da transferência de responsaveis do Bem   º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function Af190GrTrans(cNDCBASE,cNDITEM,cRESPORI,cRESPDES)

Local lGravou	:= .F.
Local lRet := .T.
Local nSNDRecORI:= ""
Local aArea := GetArea()

If Empty(cNDCBASE)
	HELP("",1,"ND_CBASE")
	lRet := .F.
ElseIf Empty(cNDITEM)
	HELP("",1,"ND_ITEM")
	lRet := .F.
ElseIf Empty(cRESPORI)
	If Alias() == "SND"
		cRESPORI := SND->ND_CODRESP
		If Empty(cRESPORI)
			lRet := .F.
		Endif
	Else
		HELP("",1,"ND_RESPDES") //"Responsável destino inválido/não informado."
		lRet := .F.
	Endif
ElseIf Empty(cRESPDES) .OR. Empty(cRESPORI) 
	HELP("",1,"ND_RESPDES") //"Responsável destino inválido/não informado."
	lRet := .F.
ElseIf cRESPORI == cRESPDES
	HELP("",1,"SNDORI=DES") //"O responsável destino está igual ao responsável origem."
	lRet := .F.
EndIf	

If lRet
	RD0->(DbSetOrder(1))//RD0_FILIAL+RD0_CODIGO
	If !RD0->(MsSeek(xFilial("RD0") + cRESPDES )) .Or. !RD0->(MsSeek(xFilial("RD0") + cRESPORI ))
		Help("  ",1,"AF190NORD0") //"Código do responsavel invalido."
		lRet := .F.
	EndIf

	If RD0->(MsSeek(FWxFilial("RD0") + cRESPDES )) .And. RD0->RD0_MSBLQL == "1"	/// SE ENCONTRAR RESPONSAVEL INATIVO
		HELP("",1,"AF190INATIVA",,STR0044,1,0)					/// Não pode transferir pessoa inativa
		lRet := .F.
	Endif

Endif


If lRet
	dbSelectArea("SND")
	dbSetOrder(2)
	cKeySND := xFilial("SND")+cNDCBASE+cNDITEM
	If lRet .And. SND->(!MsSeek(cKeySND+cRESPORI))					/// SE O RESPONSAVEL ORIGEM NAO FOR ENCONTRADO
		HELP("",1,"SNDNOTFORI")
		lRet := .F.									/// RETORNA ERRO - POIS TEM QUE HAVER ORIGEM
	Endif												/// SE ENCONTROU O RESPONSAVEL ORIGEM CONTINUA
	
	If lRet .And. SND->ND_STATUS <> "1"  							/// SE O STATUS DO RESPONSAVEL NAO ESTA ATIVO
		HELP("",1,"SNDSTAT23")							// RETORNA ERRO POIS NAO ALTERAR STATUS DA ORIGEM
		lRet := .F.
	Endif												/// SE FOR STATUS ATIVO CONTINUA
	
	If lRet
		nSNDRecORI := SND->(Recno())
		
		If SND->(!MsSeek(cKeySND+cRESPDES+"1")	)			/// PROCURA PARA VERIFICAR SE JA EXISTE RESPONSAVEL DEST. ATIVO
			BEGIN TRANSACTION
			RecLock("SND",.T.)								/// GRAVA NOVO REGISTRO PARA O RESP. DESTINO COMO ATIVO
			SND->ND_FILIAL  := xFilial("SND")
			SND->ND_CBASE   := cNDCBASE
			SND->ND_ITEM	  := cNDITEM
			SND->ND_CODRESP := cRESPDES
			SND->ND_STATUS  := "1"
			SND->ND_DTINI	  := dDataBase
			SND->ND_SEQUENC := NextSNDSEQ(cNDCBASE,cNDITEM)
			SND->(MsUnlock())
			
			SND->(MsGoTo(nSNDRecORI))
			RecLock("SND",.F.)
			SND->ND_STATUS  := "3"							/// GRAVA ORIGEM COMO TRANSFERIDO
			SND->ND_DTFIM	  := dDataBase
			SND->ND_RESPDES := cRESPDES
			SND->(MsUnlock())
			END TRANSACTION
			lGravou := .T.
			
		ElseIf MsgYesNo(STR0035+CHR(10)+STR0036)//"Responsavel destino já associado a este Bem !"#"Baixa responsavel origem para Inativo ?"
			RecLock("SND",.F.)
			SND->ND_STATUS  := "2"							/// GRAVA RESP. ORIGEM COMO INATIVO
			SND->ND_DTFIM	  := dDataBase
			SND->(MsUnlock())
			lGravou := .T.
		Endif
	EndIf
EndIf

RestArea(aArea)
Return(lGravou)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³Af190ClearºAutor  ³Marcos S. Lobo      º Data ³  11/21/03   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Executa a limpeza das amarrações Inativas/Transferidas.     º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function Af190Clear(cRespINI,cRespFIM,cCBaseINI,cItemINI,cCBaseFIM,cItemFIM,cTipo)

Local lShowMsg  := .F.
Local lBlind    := IsBlind() 

If Empty(cRespINI+cRespFIM+cCBaseINI+cItemINI+cCBaseFIM+cItemFIM)
	lShowMsg := !lBlind //.T.
	If !Pergunte("AF190L", !lBlind )   //.T.
		Return
	Endif
	cRespINI	:= PadR( mv_par01, Len(SND->ND_CODRESP) )
	cRespFIM	:= PadR( If(Empty(mv_par02),mv_par01,mv_par02), Len(SND->ND_CODRESP) )			/// FINAL EM BRANCO INICIALIZA COM O INICIAL
	cCBaseINI	:= PadR( mv_par03, Len(SND->ND_CBASE) )
	cItemINI	:= PadR( mv_par04, Len(SND->ND_ITEM) )
	cCBaseFIM	:= PadR( If(Empty(mv_par05),mv_par03,mv_par05), Len(SND->ND_CBASE) )			/// FINAL EM BRANCO INICIALIZA COM O INICIAL
	cItemFIM	:= PadR( If(Empty(mv_par06),mv_par04,mv_par06), Len(SND->ND_ITEM) )			/// FINAL EM BRANCO INICIALIZA COM O INICIAL
	cTipo		:= If(Empty(mv_par07),"1",alltrim(str(mv_par07)))					/// TIPO É 1=TODOS/2=INATIVOS/3=TRANSFERENCIAS
Endif

If lShowMsg
	MsAguarde({|| Af190ClExe(cRespINI,cRespFIM,cCBaseINI,cItemINI,cCBaseFIM,cItemFIM,cTipo,.T.) },STR0037)//"Limpeza de histórico de responsáveis..."
Else
	Af190ClExe(cRespINI,cRespFIM,cCBaseINI,cItemINI,cCBaseFIM,cItemFIM,cTipo,.F.)
Endif

Return


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ATFA190   ºAutor  ³Microsiga           º Data ³  01/14/04   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³                                                            º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function Af190ClExe(cRespINI,cRespFIM,cCBaseINI,cItemINI,cCBaseFIM,cItemFIM,cTipo,lShowMsg)

Local nRegSND	 := 0
Local cSNDFIM	:= ""
Local aArea     := GetArea()
Local aAreaSND  := SND->(GetArea())

DEFAULT lShowMsg := .F.

dbSelectArea("SND")
dbSetOrder(2)
MsSeek(xFilial("SND")+cCBaseINI+cItemINI,.T.)
cSNDFIM := xFilial("SND")+cCBaseFim+cItemFIM
While !SND->(Eof()) .and. SND->(ND_FILIAL+ND_CBASE+ND_ITEM) <= cSNDFIM
	If SND->( ND_CODRESP < cRespINI .OR. ND_CODRESP > cRespFIM )
		SND->(dbSkip())
		Loop
	EndIf
	If lShowMsg
		MsProcTxt(STR0038+ALLTRIM(STR(nRegSND))+STR0039)//"Apagando histórico..."#" registros eliminados."
	Endif
	If cTipo == "1"
		If SND->ND_STATUS <> "1"
			RecLock("SND",.F.)
			SND->(dbDelete())
			SND->(MsUnlock())
			nRegSND++
		Endif
	Else
		If SND->ND_STATUS == cTipo
			RecLock("SND",.F.)
			SND->(dbDelete())
			SND->(MsUnlock())
			nRegSND++
		Endif
	Endif
	SND->(dbSkip())
Enddo

If lShowMsg
	MsgInfo(STR0040)
Endif

RestArea(aAreaSND)
RestArea(aArea)

Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³MenuDef   ³ Autor ³ Ana Paula N. Silva     ³ Data ³29/11/06 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Utilizacao de menu Funcional                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³Array com opcoes da rotina.                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³Parametros do array a Rotina:                               ³±±
±±³          ³1. Nome a aparecer no cabecalho                             ³±±
±±³          ³2. Nome da Rotina associada                                 ³±±
±±³          ³3. Reservado                                                ³±±
±±³          ³4. Tipo de Transa‡„o a ser efetuada:                        ³±±
±±³          ³		1 - Pesquisa e Posiciona em um Banco de Dados     ³±±
±±³          ³    2 - Simplesmente Mostra os Campos                       ³±±
±±³          ³    3 - Inclui registros no Bancos de Dados                 ³±±
±±³          ³    4 - Altera o registro corrente                          ³±±
±±³          ³    5 - Remove o registro corrente do Banco de Dados        ³±±
±±³          ³5. Nivel de acesso                                          ³±±
±±³          ³6. Habilita Menu Funcional                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³   DATA   ³ Programador   ³Manutencao efetuada                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³          ³               ³                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function MenuDef()

Local aRotina 		as array
Local lPageAction 	as logical

aRotina 	:= {}
lPageAction := .T.

aAdd(aRotina,{ STR0002	, "AxPesqui"  						, 0, 1 , ,.F.})			  //"Pesquisar"
aAdd(aRotina,{ STR0003	, "AF190Vis"						, 0, 2})				  //"Visualizar"
aAdd(aRotina,{ STR0004	, "AF190Inc"						, 0, 3})				  //"Incluir"
aAdd(aRotina,{ STR0005	, "AF190Alt"						, 0, 4})				  //"Alterar"
aAdd(aRotina,{ STR0006	, "AF190Del"						, 0, 5})				  //"Excluir"
aAdd(aRotina,{ STR0007	, 'Pergunte("AFA190",.T.)'			, 0, 6,,,,,,lPageAction}) //"Opcoes"
aAdd(aRotina,{ STR0032	, "Af190Trans(1)"					, 0, 7})				  //"Transferir"
aAdd(aRotina,{ STR0033	, 'Af190Clear("","","","","","")'	, 0, 7,,,,,,lPageAction}) //"Limpa Histórico"

Return(aRotina)




/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³Af190PE   ºAutor  ³Eduardo F. Lima     º Data ³  01/09/11   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Localiza Pessoa no Browse do Cad. de Pessoas da tela de     º±±
±±º          ³amarração disparada pelo cadastro de Bens                   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function Af190PEGRV(nOpc)
If (ExistBlock("At190Grv"))
	ExecBlock ("At190Grv",.F.,.F.,{nOpc})
EndIf
Return



//-------------------------------------------------------------------
/*/{Protheus.doc} AF190When
Função para vericiar o WHEN de determinados campos da tabela SND

@author Mauricio Pequim Jr
@since 03/06/2013
@version MP11
/*/
//-------------------------------------------------------------------

Function AF190When(nOpc)

Local lRet := .T.

//Se status diferente de ativo e for alteração
//Não permite a alteracao dos campos
If M->ND_STATUS != '1' .and. nOpc == 4
	lRet := .F.
Endif

Return lRet



//-------------------------------------------------------------------
/*/{Protheus.doc} Atf190VUsu
Função para verificar se tem campos de usuarios e acrescentar no array aAlter

@author Totvs
@since 17/11/2022
@version P12
/*/
//-------------------------------------------------------------------
Static Function Atf190VUsu(aAlter)
Local aArea := GetArea()
Local aStruSND      := SND->( dbStruct() )
Local cCampo
Local nI

//verifica estrutura da tabela SND
For nI := 1 to Len(aStruSND)

	cCampo := AllTrim(aStruSND[nI,1])
	//acrescenta no array aAlter os campos de usuarios
	If GetSX3Cache(cCampo, "X3_PROPRI")== "U" .And. GetSX3Cache(cCampo, "X3_CONTEXT") != "V" .And. GetSX3Cache(cCampo,"X3_TIPO") <> 'M' 
		aAdd( aAlter, cCampo)
	EndIf
	
Next nI

RestArea(aArea)

Return
