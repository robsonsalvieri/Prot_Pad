#INCLUDE "FINA095.CH"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "SIGAWIN.CH"

Static lFWCodFil := .t.
STATIC lMod2     := .t.
Static cGrpPerg  := VlgGrpPerg() //Valida grupo de preguntas FIN090A/FIN090.

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ FINA095  ³ Autor ³ Wagner Montenegro           ³ Data ³ 30.09.10 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Controle de Cheques Emitidos e Cadastro de Talonário.            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ Nenhum                                                           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ Nenhum                                                           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³                          ATUAIZACOES SOFRIDAS                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Programador  ³ Data   ³   BOPS   ³           Motivo da Alteracao             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Jonathan Glez³14/12/16 ³SERINN001-³Elimina funciones fa095ASIX con motivo    ³±±
±±³             ³        ³       486³de limpiza de SX                           ³±±
±±³Marco A. Glz ³24/03/17³  MMI-41  ³Se replica llamado (TWHERC - V11.8), Se    ³±±
±±³             ³        ³          ³agrega validacion, para que solo se susti- ³±±
±±³             ³        ³          ³tuyan cheques desde Anulacion de Ordenes de³±±
±±³             ³        ³          ³Pago. (ARG)                                ³±±
±±³Laura Medina ³24/03/17³  MMI-4145³Se replica llamado (THIMXG - V11.8), se    ³±±
±±³             ³        ³          ³corrigió la inclusión de mov a pagar, en la³±±
±±³             ³        ³          ³rutina de Movimiento Bancario, para que per³±±
±±³             ³        ³          ³mita incluir documentos con un item.       ³±±
±±³Roberto Glez ³19/06/17³ MMI-5711 ³Se agregan asignaciones para la generaqción³±±
±±³             ³        ³          ³de NF por movimientos bancarios según los  ³±±
±±³             ³        ³          ³datos informados en los parámetros.        ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function FINA095()

	Local lFiltraBco  := GetNewPar("MV_FILTBCO","2") == "1"
	Local cQuery := ""
	Local aIndFil := {}
	
	PRIVATE aButtons	:=	{}
	Private cCadastro := STR0001
	Private lInverte:=.F.
	Private lGeraLanc:=.T.
	Private aIndex		:= {}
	Private bFiltraBrw
	Private dIniDt380:= dDataBase
	Private dFimDt380:= dDataBase
	Private lIndice12 := .F.
	Private lCtrlCheq :=.T.
	Private cBco380	:=Criavar("EF_BANCO")
	Private cAge380	:=Criavar("EF_AGENCIA")
	Private cCta380	:=Criavar("EF_CONTA")
	Private cCheq380	:=Criavar("EF_NUM")
	Private cBcoDe 	:= cBco380
	Private cBcoAte	:= cBco380
	Private dDataDe 	:= dIniDt380
	Private dDataAte 	:= dFimDt380
	Private aUsoCH		:= {STR0002,STR0003}
	Private cUsoCH		:=	aUsoCH[1]
	Private cCondicao   := ""
	PRIVATE aIndices		:=	{} //Array necessario para a funcao FilBrowse
	PRIVATE bFilBrw := {|| }
	PRIVATE cFil090
	PRIVATE cFilter	:=	Nil
	PRIVATE nIndTemp:=1
	PRIVATE dDataLanc	:= dDataBase
	PRIVATE cPadrao	:= "530"
	PRIVATE cBordero	:= CriaVar("E2_NUMBOR")
	PRIVATE cPortado	:= CriaVar("E2_PORTADO")
	PRIVATE dVencIni	:= dDataBase
	PRIVATE dVencFim	:= dDataBase
	PRIVATE dBaixa		:= dDataBase
	PRIVATE nJuros		:= 0
	PRIVATE nCorrec	:= 0
	PRIVATE cCtBaixa	:= GetMv("MV_CTBAIXA")
	PRIVATE cMarca		:= GetMark()
	PRIVATE cMarcaE2	:= GetMark()
	PRIVATE cKey1, cIndexNew
	PRIVATE nAcresc     := 0
	PRIVATE nDecresc    := 0
	PRIVATE cCodDiario	:= ""
	PRIVATE cMoedBco	:= CriaVar( "E2_MOEDA" )
	PRIVATE aRecNoSE2   := {}
	Private cFilCxCtr :=Left(GetMv("MV_CXFIN"),3)+"/"+GetMv("MV_CARTEIR")+"/"+IsCxLoja()
	Private aDados050 :={}
	Private lAnular
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Verifica o n£mero do Lote   ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	PRIVATE cLote := "",lAltera	:=.F.
	PRIVATE lFa380		:= ExistBlock("F380RECO",.F.,.F.)
	
	/*
	 * Verificação do processo que está configurado para ser utilizado no Módulo Financeiro (Argentina)
	 */
	If lMod2
		If !FinModProc()
			Return()
		EndIf
	EndIf
	
	Aadd(aButtons,{STR0004,{||FINC021(),STR0005,STR0004}})
	
	Private aCampos := 	{ {STR0006,"EF_BANCO"		,"",00,00,""} ,; //"Banco"
					           {STR0007,"EF_AGENCIA"		,"",00,00,""} ,; //"Agencia"
					           {STR0008,"EF_CONTA"		,"",00,00,""} ,; //"Conta"
					           {STR0009,"EF_NUM"			,"",00,00,""} ,; //"Numero"
					           {STR0010,"EF_VALOR"		,"",00,00,""} ,; //"Valor"
					           {STR0011,"EF_DATA"			,"",00,00,""} ,; //"Emissao"
					           {STR0012,"EF_VENCTO"		,"",00,00,""} ,; //"Vencimento"
					           {STR0013,"EF_PREFIXO"		,"",00,00,""} ,; //"Prefixo"
					           {STR0014,"EF_TITULO"		,"",00,00,""} ,; //"Titulo"
					           {STR0015,"EF_PARCELA"		,"",00,00,""} ,; //"Parcela"
					           {STR0016,"EF_TIPO"			,"",00,00,""} ,; //"Tipo"
					           {STR0017,"EF_BENEF"		,"",00,00,""} }  //"Beneficente"
	
	Private cDelFunc := ".T." // Validacao para a exclusao. Pode-se utilizar ExecBlock
	Private aRotina := MenuDef()
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Carrega fun‡„o Pergunte                                      ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	SetKey (VK_F12,{|a,b| AcessaPerg(cGrpPerg,.T.)})
	Pergunte(cGrpPerg,.F.)
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Variaveis utilizadas para parƒmetros          ³
	//³ mv_par01	Mostra Lan‡ Contabil              ³
	//³ mv_par02   Aglutina Lancamentos               ³
	//³ mv_par03   Contabiliza On-Line                ³
	//³ mv_par04   Gera Cheque automaticamente        ³
	//³ mv_par05   Ctb Bordero - Total/Por Bordero    ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	
	dbSelectArea("SEF")
	SEF->(dbSetOrder(1))
	SEF->(DbGoTop())
	
	cFilterBrw := "EF_FILIAL=='" +xFilial('SEF')+ "' .AND. EF_CART=='P'"  
	
	oBrowse := FWmBrowse():New()
	oBrowse:SetAlias("SEF")
	oBrowse:SetFields(aCampos)
	
	oBrowse:AddLegend('EF_STATUS == "00" .AND. EMPTY(EF_RECONC) .AND. EF_LIBER <> "N"'	,'BR_BRANCO'	,STR0022) //"Não Usado"
	oBrowse:AddLegend('EF_STATUS == "01" .AND. EMPTY(EF_RECONC)'						,'BR_AZUL'		,STR0023) //"Em Carteira"		
	oBrowse:AddLegend('EF_STATUS == "02" .AND. EMPTY(EF_RECONC)'						,'BR_AMARELO'	,STR0024) //"Pagamento Vinculado"
	oBrowse:AddLegend('EF_STATUS == "03" .AND. EMPTY(EF_RECONC)'						,'BR_LARANJA'	,STR0025) //"Emitido"
	oBrowse:AddLegend('EF_STATUS == "04" .AND. EMPTY(EF_RECONC)'						,'BR_VERDE'		,STR0026) //"Liquidado"
	oBrowse:AddLegend('EF_STATUS == "05" .AND. EMPTY(EF_RECONC)'						,'BR_PRETO'		,STR0027) //"Anulado"		
	oBrowse:AddLegend('EF_STATUS == "06" .AND. EMPTY(EF_RECONC)'						,'BR_CINZA'		,STR0028) //"Substituído"
	oBrowse:AddLegend('EF_STATUS == "07" .AND. EMPTY(EF_RECONC)'						,'BR_VERMELHO'	,STR0029) //"Devolvido"
	oBrowse:AddLegend('EF_LIBER == "N"'													,'BR_VIOLETA'	,STR0038) //"Bloqueado"			
	oBrowse:AddLegend('EF_RECONC == "x"'												,'LIGHTBLU'		,STR0031) //"Conciliado"	
	
	If lFiltraBco
		SEF->(dbSetOrder(8))
		If A095Bco(@cFiltraBco)
			oBrowse:SetFilterDefault(cFilterBrw + " .And. " + cFiltraBco)
		EndIf
	Else
		oBrowse:SetFilterDefault(cFilterBrw)
	EndIf
	
	oBrowse:Activate()

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±
±±³Fun‡…o	 ³A095Compes³ Autor ³ Wagner Montenegro	     ³ Data ³ 30.09.10 ³±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±
±±³Descri‡…o ³ Compensar Cheques, execuntado a função fA090Aut().		   ³±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±
±±³Sintaxe	 ³ lExpL := A095Compes(cAlias,nReg,nOpcx)					   ³±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±
±±³Retorno	 ³ Lógico       											   ³±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±
±±³Uso		 ³ Localização Equador.										   ³±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function A095Compes(cAlias,nReg,nOpcx,lAutomato)
Local lRet			:= .T.
Local aAreaSFE		:= SFE->(GetArea())
Local aPergs		:= {}

Private nModo		:= 1
Private cMarca		:= GetMark()
Private cPadrao		:= "530"
Private cCtBaixa	:= GetMv("MV_CTBAIXA")
Private bFilBrw		:= {|| }

Default lAutomato 	:= .F. //para acceso por script automático

If SEF->EF_LIBER == 'N'
  IF !lAutomato 
	MSGALERT(STR0094) //"O cheque não pode ser alterado pois pertence a um talão que está bloqueado."
  Else 
	Help( " ", 1, "Help",,"El cheque no puede modificarse pues pertenece a un talonario que esta bloqueado.", 1 )
  Endif
Else
		SX5->(dbSetOrder(1))
		SX5->(dbSeek(xFilial("SX5")+"09FIN"))
		cLote := IIF(SX5->(Found()),AllTrim(SX5->(X5DESCRI())),"FIN")
EndIf


//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Carrega fun‡„o Pergunte                                      ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
SetKey (VK_F12,{|a,b| AcessaPerg(cGrpPerg,.T.)})
Pergunte(cGrpPerg,.F.)
lRet:=fA090Aut("SE2")

SetKey (VK_F12,NIL)
RestArea(aAreaSFE)
Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±
±±³Fun‡…o	 ³ A095Fluxo³ Autor ³ Wagner Montenegro	     ³ Data ³ 30.09.10 ³±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±
±±³Descri‡…o ³ Consultar a rotina de Fluxo de Caixa.					   ³±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±
±±³Sintaxe	 ³ A095Fluxo(cAlias,nReg,nOpcx)								   ³±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±
±±³Retorno	 ³ Null		       											   ³±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±
±±³Uso		 ³ Localização Equador.										   ³±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function A095Fluxo(cAlias,nReg,nOpcx)
Local lRet		:= .T.
Local aAreaSFE	:= SFE->(GetArea())

lRet := FINC021()                                  

RestArea(aAreaSFE)
Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±
±±³Fun‡…o	 ³A095Emitir³ Autor ³ Wagner Montenegro	     ³ Data ³ 30.09.10 ³±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±
±±³Descri‡…o ³ Imprimir cheques, execuntado o programa FINR480.			   ³±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±
±±³Sintaxe	 ³ A095Emitir(cAlias,nReg,nOpcx)							   ³±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±
±±³Retorno	 ³ Null       											       ³±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±
±±³Uso		 ³ Localização Equador.										   ³±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function A095Emitir(cAlias,nReg,nOpcx)
Local lRet		:= .T.
Local aAreaSFE	:=	SFE->(GetArea()) 

Private nModo	:= 1

lRet := FINR480()   
RestArea(aAreaSFE) 
Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±
±±³Fun‡…o	 ³A095Anular³ Autor ³ Wagner Montenegro	     ³ Data ³ 30.09.10 ³±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±
±±³Descri‡…o ³ Anular cheques, execuntado a função fA090Can().			   ³±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±
±±³Sintaxe	 ³ A095Anular(cAlias,nReg,nOpcx,lAnular)					   ³±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±
±±³Retorno	 ³ Null		       											   ³±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±
±±³Uso		 ³ Localização Equador.										   ³±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function A095Anular(cAlias,nReg,nOpcx,lAnular,lAutomato)
	Local aAreaSFE		:= {}
	Local aAreaSE2		:= {}
	Local cKeySEF		:= ""
	Local aPergs     	:= {}
	Local aRegs			:= {}
	Local cNumChq		:= ""
	Local cCondAux		:= ""
	Local lRet		 	:= .F.
	Local aAreaSEF 		:= SEF->(GetARea())
	Local aArea			:= GetArea()
	Local lPeAltSEF 	:= ExistBlock("F095ALTSEF")
	
	Local aAcao := {}
	
	Private nModo	 	:=	2
	Private aMotivos 	:=	{}
	
	Default lAnular 	:= .T.
	Default lAutomato 	:= .F.
	
	aDados050 :={}
	
	If lAutomato
	   cCondicao			:= ""
	Endif
	
	If Type("cCondicao") <> "U"
		cCondAux := cCondicao
	EndIf
	
 If SEF->EF_LIBER == 'N'
	  IF !lAutomato 
		MSGALERT(STR0094) //"O cheque não pode ser alterado pois pertence a um talão que está bloqueado.")
	  Else 
		Help( " ", 1, "Help",,"El cheque no puede modificarse pues pertenece a un talonario que esta bloqueado.", 1 )
	  Endif
	  Return()
  Endif
  
  If SEF->EF_RECONC == "x"
	  IF !lAutomato 
		MSGALERT(STR0119) //"O cheque não pode ser alterado pois pertence a um talão que está bloqueado."
	  Else 
		Help( " ", 1, "Help",,"El cheque fue conciliado y por eso no puede anularse", 1 )
	  Endif
	  Return()
  Endif
		
	If SEF->EF_STATUS == '04'
		IF !lAnular
	   		IF !lAutomato 
				MSGALERT(STR0120) //"O cheque está liquidado e por isso não pode ser substituido."
			Else 
				Help( " ", 1, "Help",,STR0120, 1 )
			Endif
	   		Return()
		Endif
	Endif
		
	SX5->(dbSetOrder(1))
	SX5->(dbSeek(xFilial("SX5")+"09FIN"))
	cLote := IIF(SX5->(Found()),AllTrim(SX5->(X5DESCRI())),"FIN")
	
	If SEF->EF_STATUS $ "00/01/02/03/04"
	
		//Controle de Conciliação bancária
		If cPaisLoc $ "ARG"
	
			aAdd(aRegs,{SEF->EF_PREFIXO,SEF->EF_NUM,SEF->EF_PARCELA,SEF->EF_TIPO,SEF->EF_FORNECE,SEF->EF_LOJA,SEF->EF_BANCO,SEF->EF_AGENCIA,SEF->EF_CONTA})
	
			If F472VldConc(aRegs)
				MsgAlert(STR0107)
				If FunName() == "FINA095"
					SEF->(DbGoTop())
				EndIf
				Return
			EndIf
	
		EndIf
	
		If lAnular .And. !(SEF->EF_STATUS $ "04|00|01")  .And. FUNNAME() == "FINA095"
			If Empty(SEF->EF_ORDPAGO) .OR. ALLTRIM(SEF->EF_ORIGEM) == "FINA100"
				MsgAlert(STR0101) //"O cheque foi gerado pela movimentação bancária, e só pode ser cancelado pela mesma rotina"
			Else
				MsgAlert(STR0082) //"Para anular um cheque que não tenha sido ainda compensado, você deve acessar a rotina de cancelamento da Ordem de Pago.
			EndIf
			SEF->(DbGoTop())
			Return		
		EndIf
	
		aAreaSFE	:=	SFE->(GetArea())
		aAreaSE2	:=	SE2->(GetArea())
		SX5->(DbSeek(xFilial("SX5")+"G0"))
		While !SX5->(Eof()) .and. SX5->X5_FILIAL==xFilial("SX5") .and. SX5->X5_TABELA=="G0"
			Aadd(aMotivos,Trim(SX5->X5_CHAVE)+" - "+Capital(Trim(SX5->(X5DESCRI()))))
			SX5->(DbSkip())
		Enddo
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Carrega fun‡„o Pergunte                                      ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		SetKey (VK_F12,{|a,b| AcessaPerg(cGrpPerg,.T.)})
		Pergunte(cGrpPerg,.F.)
		SE2->(DbSetOrder(1))
		If !(cPaisLoc == "BRA")
			cNumChq	:= ""
			cNumChq	:= FA95NUMTIT(SEF->EF_NUM,SEF->EF_TITULO,SEF->EF_FORNECE, SEF->EF_LOJA,!Empty(SEF->EF_ORDPAGO),SEF->EF_BANCO,SEF->EF_CONTA,SEF->EF_AGENCIA)
			If SE2->(DbSeek(xFilial("SE2")+SEF->EF_PREFIXO+cNumChq))
				lRet:=fa090Can("SE2",SE2->(Recno()),nOpcx,aMotivos,lAnular,lAutomato)
			Else
				If SEF->EF_STATUS=="00" .AND. lAnular
					lRet:=fa090Can("SE2",SE2->(Recno()),nOpcx,aMotivos,lAnular,lAutomato)
				Endif
			Endif
			IF lPeAltSEF
				aAcao := {xFilial("SEF")+cNumChq,SEF->EF_FILIAL+SEF->EF_NUM} 
				ExecBlock( "F095ALTSEF",.F.,.F.,aAcao)
			EndIf
		Else
			If SE2->(DbSeek(xFilial("SE2")+SEF->EF_PREFIXO+SEF->EF_TITULO))
				cKeySEF:=SEF->EF_BANCO+SEF->EF_AGENCIA+SEF->EF_CONTA+SEF->EF_PREFIXO+SEF->EF_NUM+SEF->EF_TIPO+SUBSTR(SEF->EF_TITULO,1,TamSX3("E2_ORDPAGO")[1])
				While !SE2->(EOF()) .AND. (SE2->E2_ORDPAGO==SUBSTR(SEF->EF_TITULO,1,TamSX3("E2_ORDPAGO")[1]))
					If cKeySEF==(SE2->E2_BCOCHQ+SE2->E2_AGECHQ+SE2->E2_CTACHQ+SE2->E2_PREFIXO+SUBSTR(SE2->E2_NUMBCO,1,TamSX3("EF_NUM")[1])+SE2->E2_TIPO+SE2->E2_ORDPAGO)
						lRet:=.T.
						Exit
					Endif
					SE2->(DbSkip())
				Enddo
				If lRet
					lRet := fa090Can("SE2",SE2->(Recno()),nOpcx,aMotivos,lAnular)
				Endif
			Else
				If SEF->EF_STATUS=="00" .AND. lAnular
					lRet := fa090Can("SE2",SE2->(Recno()),nOpcx,aMotivos,lAnular)
				Endif
			Endif
		Endif
		SetKey (VK_F12,NIL)
		RestArea(aAreaSE2)
		RestArea(aAreaSFE)
	Elseif SEF->EF_STATUS=="05"
		MSGALERT(STR0020) //"Este cheque já está cancelado!"
	Elseif SEF->EF_STATUS=="06"
		MSGALERT(STR0021) //"Este cheque foi substituido!"
	ElseIf SEF->EF_STATUS == "07"
		MSGALERT(STR0089) //"Este cheque foi devolvido!"
	Endif
	If cPaisLoc $ "EQU|DOM|ARG" .AND. FUNNAME()=="FINA095"
		If !Empty(cCondAux)
			cCondicao := cCondAux
		EndIf
	EndIf
	RestArea(aAreaSEF)
	RestArea(aArea)
	
Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±
±±³Fun‡…o	 ³fA095Legen³ Autor ³ Wagner Montenegro      ³ Data ³ 30.09.10 ³±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±
±±³Descri‡…o ³ Legenda do Controle de Cheques.							   ³±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±
±±³Sintaxe	 ³ fA095Legen(cAlias,nReg,nOpcx)							   ³±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±
±±³Retorno	 ³ Null		       											   ³±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±
±±³Uso		 ³ Localização Equador.										   ³±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function Fa095Legen(cAlias,nReg)

Local aLegenda := {	{"BR_BRANCO"	,STR0022},; //"Não Usado" 			//01 
					{"BR_AZUL"		,STR0023},; //"Em Carteira" 		//02
					{"BR_AMARELO"	,STR0024},; //"Pagamento Vinculado"	//03
					{"BR_LARANJA"	,STR0025},; //"Emitido"   			//04 
					{"BR_VERDE"		,STR0026},; //"Liquidado"   		//05 
					{"BR_PRETO"		,STR0027},; //"Anulado"   	 		//06 
					{"BR_CINZA"		,STR0028},; //"Substituído"			//07 
					{"BR_VERMELHO"	,STR0029},; //"Devolvido" 	 		//08
					{"BR_VIOLETA"	,STR0038},; //"Bloqueado"			//09					 
					{"LIGHTBLU"		,STR0031}}  //"Conciliado"	  		//10 																												
        
BrwLegenda(STR0032,STR0033,aLegenda) //"Controle de Cheques", "Legenda"

Return()

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±
±±³Fun‡…o	 ³ A095Bco	³ Autor ³ Wagner Montenegro	     ³ Data ³ 30.09.10 ³±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±
±±³Descri‡…o ³ Compensar Cheques, execuntado a função fA090Aut().		   ³±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±
±±³Sintaxe	 ³ A095Bco()												   ³±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±
±±³Retorno	 ³ Null		       											   ³±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±
±±³Uso		 ³ Localização Equador.										   ³±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function A095Bco()
Local nEspLarg	:= 0
Local nEspLin	:= 0
Local oDlg		:= Nil
Local oPanel	:= Nil
Local nOpca		:= 0
Local lRet		:= .F.
Local oBco380	:= Nil
Local oCBX		:= Nil

nEspLarg := 8
nEspLin  := 5
DEFINE MSDIALOG oDlg FROM 	143,145 TO 157,190 TITLE STR0006 //"Banco"
oDlg:lMaximized := .F.
oPanel := TPanel():New(00,00,'',oDlg,, .T., .T.,, ,00,00)
oPanel:Align := CONTROL_ALIGN_ALLCLIENT

@ 000+nEspLin,003+nEspLarg TO 073+nEspLin,163+nEspLarg OF oPanel  PIXEL
@ 011+nEspLin,010+nEspLarg SAY STR0006 SIZE 20, 7 OF oPanel PIXEL //"Banco:"
@ 009+nEspLin,045+nEspLarg MSGET cBco380 F3 "SA6" Picture "@!" ;
									Valid If((!Empty(cBco380)),CarregaSA6(@cBco380,@cAge380,@cCta380,.T.),Eval({||MsgAlert(STR0034),.F.})) ; //"Selecione o Banco."
									SIZE 17, 10 OF oPanel Hasbutton PIXEL

@ 026+nEspLin,010+nEspLarg SAY STR0007 SIZE 20, 7 OF oPanel PIXEL //"Agencia:"
@ 024+nEspLin,045+nEspLarg MSGET cAge380	Picture "@!" WHEN Empty(cBco380) .and. !Empty(cCta380) ;
									Valid If(nOpca<>0,CarregaSA6(@cBco380,@cAge380,,.T.),.T.) ;
									SIZE 32, 10 OF oPanel PIXEL
@ 026+nEspLin,085+nEspLarg SAY STR0008 SIZE 20, 7 OF oPanel PIXEL //"Conta:"
@ 024+nEspLin,105+nEspLarg MSGET cCta380	Picture PesqPict("SE8","E8_CONTA") WHEN Empty(cBco380) .and. !Empty(cAge380) ;
									Valid If(nOpca<>0,CarregaSA6(@cBco380,@cAge380,@cCta380,.T.),.T.) ;
									SIZE 47, 10 OF oPanel PIXEL

@ 042+nEspLin,010+nEspLarg SAY STR0035 SIZE 70, 07 OF oPanel PIXEL //"Selecionar Cheques : "

@ 040+nEspLin,065+nEspLarg COMBOBOX oCBX VAR cUsoCH ITEMS aUsoCH WHEN !Empty(cBco380) Valid AllwaysTrue() SIZE 50,50 OF oDlg PIXEL

@ 057+nEspLin,030+nEspLarg SAY STR0036 SIZE 20, 7 OF oPanel PIXEL //"De"
@ 056+nEspLin,045+nEspLarg MSGET dIniDt380 	Picture "99/99/99" When .T.;	//cUsoCH==aUsoCH[1] .and. !Empty(cBco380) ;
									VALID If(Empty(dFimDt380),If(Empty(dIniDt380), .F. , .T. ),If(!Empty(dIniDt380) .and. dIniDt380<=dFimDt380, .T. , .F. )) ;
									SIZE 45, 10 OF oPanel Hasbutton PIXEL

@ 058+nEspLin,095+nEspLarg SAY STR0037 SIZE 20, 7 OF oPanel PIXEL 	//"Até:"
@ 056+nEspLin,111+nEspLarg MSGET dFimDt380	Picture "99/99/99" When .T.;	//cUsoCH==aUsoCH[1] .and. !Empty(cBco380) ;
									VALID If(!Empty(dFimDt380) .and. dFimDt380 >= dIniDt380, .T. , .F.) ;
									SIZE 45, 10 OF oPanel Hasbutton PIXEL

DEFINE SBUTTON FROM 085, 120 TYPE 1 ENABLE ACTION (nOpca:=If(!Empty(cBco380),1,0),oDLg:End()) OF oPanel
DEFINE SBUTTON FROM 085, 150 TYPE 2 ENABLE ACTION oDlg:End() OF oPanel
ACTIVATE MSDIALOG oDlg CENTERED

If nOpca == 0 .Or. nOpca == 3
	oBrowse:DeleteFilter("FA095BCO")
	Return(lRet)
Endif

lRet		:=	.T.
cBcoDe		:= cBco380
cBcoAte		:= cBco380
dDataDe		:= dIniDt380
dDataAte	:= dFimDt380  

If StrZero(ASCAN(aUsoCH,cUsoCH),1) == "1"
	cCondicao := "(DTOS(EF_DATA) >= '" + DTOS(dIniDt380) + "' .AND. DTOS(EF_DATA) <= '" + DTOS(dFimDt380) + "' .AND. EF_STATUS <> '00') "
Else
	cCondicao := "(EF_STATUS == '00' .OR. (EF_STATUS == '05' .AND. EF_VALOR == 0)) "
Endif

cCondicao += ".AND. EF_BANCO == '" + cBco380 + "' "
cCondicao += ".AND. EF_AGENCIA == '" + cAge380 + "' "

cFiltroExt	:= cCondicao

If !Empty(oBrowse:cFilterDefault)
	oBrowse:DeleteFilter("FA095BCO")
	oBrowse:AddFilter(STR0058,cCondicao,.T.,.T.,"SEF",,,"FA095BCO")	
EndIf
SEF->(DbGoTop())
Return(lRet)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±
±±³Fun‡…o	 ³ A095Talao³ Autor ³ Wagner Montenegro	     ³ Data ³ 30.09.10 ³±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±
±±³Descri‡…o ³ Cadastra Novo Talonário de Cheques.						   ³±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±
±±³Sintaxe	 ³ lExpL := A095Talao(cAlias,nReg,nOpcx)					   ³±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±
±±³Retorno	 ³ Lógico       											   ³±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±
±±³Uso		 ³ Localização Equador.										   ³±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function A095Talao(lAutomato)
Local aArea         := GetArea()
Local aCbxStatus	:= {STR0038,STR0039} //"Bloqueado","Desbloqueado"
Local aCbxTipo	:= {}
Local cCbxStatus 	:= "2"
Local cCbxTipo      := "1"
Local cChFin		:= Criavar("FRE_SEQFIM")
Local cChIni		:= Criavar("FRE_SEQINI")
Local nQtd			:= 0
Local cTalao		:= "" //:= GetSX8Num("SA6","A6_TALAO",(cBco380+cAge380+cCta380))
Local cObsTalao		:= Criavar("FRE_OBSERV")
Local cPrefixo		:=	Criavar("FRE_PREFIX")
Local oBco380
Local oAge380
Local oCta380
Local oChFin
Local oChIni
Local oQtd
Local oTalao
Local oPrefixo
Local oObsTalao
Local lRet			:=	.F.
Local nOpca			:=	0
Local nX
Local cTipo := " "
Local cBco380	:=Criavar("EF_BANCO")
Local cAge380	:=Criavar("EF_AGENCIA")
Local cCta380	:=Criavar("EF_CONTA")
Local bChave	:= Nil
Private _oDlg				// Dialog Principal
DEFAULT lAutomato   := .F.

If cPaisLoc $ "ARG"
	aCbxTipo := {STR0040,STR0109,STR0042,STR0108} //"Cheque Comum","Cheque Comum Eletrônico","Cheque Diferido","Cheque Diferido Eletrônico"
Else
	aCbxTipo := {STR0040,STR0041,STR0042} 			//"Cheque Comum","Cheque Eletrônico","Cheque Diferido"
EndIf

bChave := {|| cChIni := Criavar("FRE_SEQINI"), cChFin := Criavar("FRE_SEQFIM"), .T.}

If !lAutomato

	DEFINE MSDIALOG _oDlg TITLE STR0043 FROM 264,407 TO 513,858 PIXEL //"Cadastro de Talonário de Cheques"
	
	
	@ 004,064 Say	STR0007	Size	021,008 	PIXEL	OF	_oDlg //"Agencia"
	@ 004,129 Say	STR0008	Size	017,008  PIXEL	OF _oDlg //"Conta"
	@ 005,005 Say	STR0006	Size	017,008 	PIXEL	OF _oDlg //"Banco"
	@ 020,104 Say	STR0044	Size	040,008 	PIXEL OF _oDlg //"Tipo de Cheque"
	@ 021,005 Say	STR0045	Size	030,008 	PIXEL OF _oDlg //"Talonário nº"
	@ 036,005 Say	STR0046	Size	059,008  PIXEL OF _oDlg //"Quantidade de Cheques"
	@ 036,125 Say	STR0013	Size	018,008	PIXEL OF _oDlg //"Prefixo"
	@ 052,005 Say	STR0047	Size	028,008  PIXEL OF _oDlg //"Cheque de"
	@ 052,115 Say	STR0048	Size	029,008  PIXEL OF _oDlg //"Cheque até"
	@ 067,007 Say	STR0049	Size	031,008	PIXEL OF _oDlg //"Observação"
	@ 084,006 Say	STR0050	Size	023,008  PIXEL OF _oDlg //"Situação"
	
	@ 004,028 MsGet	oBco380		Var	 cBco380	F3 "SA6" Picture "@S4"  Valid CarregaSa6(@cBco380,@cAge380,@cCta380,.F.) .and. ExistCpo("SA6",cBco380+cAge380+cCta380) When If(Empty(cTalao),.T.,Eval({||cTalao:="",RollBackSX8(),.T.}))	Size	026,009	 PIXEL	OF	_oDlg
	@ 004,092 MsGet	oAge380		Var	 cAge380	         Picture "@S5"	Valid CarregaSa6(@cBco380,@cAge380,@cCta380,.F.) .and. ExistCpo("SA6",cBco380+cAge380+cCta380) When .T.	Size	025,009	 PIXEL	OF	_oDlg
	@ 004,153 MsGet	oCta380		Var	 cCta380		     Picture "@S10" Valid CarregaSa6(@cBco380,@cAge380,@cCta380,.F.) .and. ExistCpo("SA6",cBco380+cAge380+cCta380) .and. fa095VTalao(cBco380,cAge380,cCta380,aCbxTipo,cCbxTipo,@cTalao) When Eval({||cTalao:=GetSX8Num("SA6","A6_TALAO",(LTrim(cBco380)+LTrim(cAge380)+LTrim(cCta380))),.T.})   Size	    060,009	 PIXEL	OF	_oDlg
	@ 020,044 MsGet	oTalao		Var cTalao		  	     Picture "@!"   Valid fa095VTalao(cBco380,cAge380,cCta380,aCbxTipo,cCbxTipo,cTalao) When .F.	Size	041,009  PIXEL  OF _oDlg
	
	@ 020,152 ComboBox	cCbxTipo		Items aCbxTipo		Size	071,010	PIXEL OF _oDlg;
			VALID fa095VTipo(cBco380,cAge380,cCta380,aCbxTipo,cCbxTipo,cTalao)
	
	@ 036,073 MsGet		oQtd		Var nQtd		Picture	PesqPict("FRE","FRE_QTDCHE") When (nQtd == 0) Size	040,009 PIXEL OF _oDlg  
	@ 036,151 MsGet		oPrefixo	Var cPrefixo	Picture	PesqPict("FRE","FRE_PREFIX") When (nQtd > 0) VALID IIF(Empty(cPrefixo),Eval({||MsgAlert(STR0145),.F.}),Iif(!empty(cPrefixo).and. !empty(cChIni) .and. !empty(cChFin), A095VldPrx(cPrefixo,cChIni,cChFin),.T.))	Size	060,009	PIXEL OF _oDlg

	
	@ 052,041 MsGet		oChIni		Var cChIni		Picture	PesqPict("FRE","FRE_SEQINI") When (nQtd > 0);
									VALID lCkTalao(cBco380,cAge380,cCta380,cPrefixo,nQtd,cChIni) .and. If( !Empty(cChIni), Eval({||cChIni:=StrZero( Val(cChIni), Len(FRE->FRE_SEQINI) ),cChFin:=StrZero( (Val(cChIni)+nQtd-1), Len(FRE->FRE_SEQFIM) ),.T.}),Eval({||MsgAlert(STR0053),.F.}) ) .And. Iif(A095VldPrx(cPrefixo,cChIni,cChFin),.T.,Eval(bChave));
									SIZE 070,009 PIXEL OF _oDlg
	
	@ 052,152 MsGet		oChFin		Var cChFin		When Empty(cBco380)	Size 070,009  PIXEL OF _oDlg
	
	@ 067,041 MsGet		oObsTalao	Var	cObsTalao	Size	171,009	PIXEL OF _oDlg
	
	@ 084,041 ComboBox	cCbxStatus	Items	aCbxStatus	Size	051,010	PIXEL OF _oDlg
	
	DEFINE SBUTTON FROM 102, 127 TYPE 1 ENABLE ACTION (nOpca:=If(!Empty(cBco380).and.nQtd>0,1,0),If(nQtd>0,_oDLg:End(),MsgAlert(STR0051))) //"Informe a quantidade de cheques do talonário."
	DEFINE SBUTTON FROM 102, 175 TYPE 2 ENABLE ACTION _oDlg:End()
	
	ACTIVATE MSDIALOG _oDlg CENTERED

Else  //para ejecución de script de teste
		If FindFunction("GetParAuto")
			aRetAuto 		:= GetParAuto("FINA095TESTCASE")
			cBco380 		:= aRetAuto[1]
			cAge380 		:= aRetAuto[2]
			cCta380 		:= aRetAuto[3]
			cTalao			:= aRetAuto[4]
			nQtd			:= aRetAuto[5]
			cPrefixo		:= aRetAuto[6]
			cChIni			:= aRetAuto[7]
			cChFin			:= aRetAuto[8]
			cObsTalao		:= aRetAuto[9]
			cCbxTipo		:= aRetAuto[10]
			cCbxStatus		:= aRetAuto[11]
		Endif
		fa095VTalao(cBco380,cAge380,cCta380,aCbxTipo,cCbxTipo,@cTalao,lAutomato)
		nOpca:=1	
	Endif


If nOpca == 0 .Or. nOpca == 3
	RollBackSX8()
	Return(lRet)
Endif
If nOpca == 1
	If !Empty(cBco380) .And. !Empty(cAge380) .and.!Empty(cCta380) .And. nQtd > 0 .And. !Empty (cPrefixo) .And. !Empty (cChIni)
		cTipo := StrZero(ASCAN(aCbxTipo,cCbxTipo),1)
		FRE->(dbSetOrder(1))
		If ! FRE->(dbSeek(xFilial("FRE")+cBco380+cAge380+cCta380+cTipo+cTalao))
			BEGIN TRANSACTION
			RecLock("FRE",.T.)
			FRE->FRE_FILIAL	:=	xFilial("FRE")
			FRE->FRE_BANCO	:=	cBco380
			FRE->FRE_AGENCI :=	cAge380
			FRE->FRE_CONTA	:=	cCta380
			FRE->FRE_TIPO	:=	cTipo
			FRE->FRE_TALAO	:= cTalao
			FRE->FRE_PREFIX	:=	cPrefixo
			FRE->FRE_SEQINI	:=	cChIni
			FRE->FRE_SEQFIM	:=	cChFin
			FRE->FRE_DATA	:= dDataBase
			FRE->FRE_QTDCHE	:=	nQtd
			FRE->FRE_STATUS	:=	StrZero(ASCAN(aCbxStatus,cCbxStatus),1)
			FRE->FRE_OBSERV	:= cObsTalao
			FRE->(MSUnlock())
			SA6->(DbSetOrder(1))
			SA6->(DbSeek(xFilial("SA6")+cBco380+cAge380+cCta380))
			RecLock("SA6",.F.)
			SA6->A6_TALAO	:=	cTalao
			SA6->(MSUnlock())
			For nX := Val(cChIni) to Val(cChFin)
				RecLock("SEF",.T.)
				SEF->EF_FILIAL		:=	xFilial("SEF")
				SEF->EF_BANCO		:=	FRE->FRE_BANCO
				SEF->EF_AGENCIA	:=	FRE->FRE_AGENCI
				SEF->EF_CONTA		:=	FRE->FRE_CONTA
				SEF->EF_NUM			:=	StrZero(nX,TamSX3("FRE_SEQFIM")[1])
				SEF->EF_TALAO		:=	FRE->FRE_TALAO
				SEF->EF_CART		:=	"P"
				SEF->EF_PREFIXO	:=	FRE->FRE_PREFIX
				SEF->EF_TIPO		:=	"CH"
				SEF->EF_LIBER		:=	IF(FRE->FRE_STATUS=="1","N","S")
				SEF->EF_ORIGEM		:=	"FINA095"
				SEF->EF_STATUS		:=	"00"
				SEF->EF_FILORIG		:=	cFilAnt
				SEF->(MSUnlock())
			Next nX
			ConfirmSX8()
			END TRANSACTION
		EndIf
	Else
	  If !lAutomato
		Alert(STR0102 + CRLF + STR0103) //conta, quantidade de cheques ou prefixo digitado incorretamnte
	  Else
		Help(STR0102 + " " + STR0103)
	  Endif	
		RollBackSX8()
		lRet := .F.
	EndIf
EndIf
RestArea(aArea)
Return(lRet)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±
±±³Fun‡…o	 ³ lCkTalao	³ Autor ³ Wagner Montenegro      ³ Data ³ 30.09.10 ³±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±
±±³Descri‡…o ³ Consiste prefixo e numeração de cheques existentes para o   ³±
±±³          ³ Talonário.                                                  ³±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±
±±³Sintaxe	 ³ lExpL:=A095Talao(cBco380,cCta380,cPrefixo, nSeq,nQtd,cChIni)³±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±
±±³Retorno	 ³ Lógico       											   ³±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±
±±³Uso		 ³ Localização Equador.										   ³±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function lCkTalao(cBco380,cAge380,cCta380,cPrefixo,nQtd,cChIni)
Local aAreaFRE	:=	GetArea()
Local lRet		:=	.T.
Local nDif		:=	0
FRE->(DbSetOrder(2))
IF FRE->(Dbseek(xFilial("FRE")+cBco380+cAge380+cCta380+cPrefixo))
	nDif	:=	Val(cChIni)-Val(FRE->FRE_SEQFIM)
	While !FRE->(EOF()) .and. (FRE->FRE_BANCO==cBco380 .and. FRE->FRE_AGENCI==cAge380 .and. FRE->FRE_CONTA==cCta380 .and. FRE->FRE_PREFIX==cPrefixo) .and. lRet
	   If Val(FRE->FRE_SEQFIM) >= Val(cChIni).and. cPaisLoc <> "ARG"
  			MsgAlert(STR0055) //"O numero de cheque informado já existe."
   			lRet	:=	.F.
   		Endif
   		nDif	:=	Val(cChIni)-Val(FRE->FRE_SEQFIM)
	   FRE->(DbSkip())
	Enddo
	If lRet .and. cPaisLoc <> "ARG"
		If nDif > 1
	   	MsgAlert(STR0056) //"O numero do cheque está fora da sequencia."
   	 	lRet	:=	.F.
	   Endif
	Endif
Endif
FRE->(RestArea(aAreaFRE))
Return(lRet)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±
±±³Fun‡…o	 ³A095FilSEF³ Autor ³ Wagner Montenegro	     ³ Data ³ 30.09.10 ³±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±
±±³Descri‡…o ³ Consistir o filtro de cheques usado e não usados.		   ³±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±
±±³Sintaxe	 ³ lExpL:=A095FilSEF(cCbx)									   ³±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±
±±³Retorno	 ³ Lógico       											   ³±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±
±±³Uso		 ³ Localização Equador.										   ³±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function A095FilSEF(cCbx)
Local lRet := .F.
IF EF_FILIAL==xFilial('SEF') .AND. EF_CART=='P' .AND. EF_BANCO==cBco380 .AND. EF_AGENCIA==cAge380 .AND. EF_CONTA==cCta380
	If cCbx=="1"
		If DTOS(EF_DATA) >= DTOS(dIniDt380) .AND. DTOS(EF_DATA) <= DTOS(dFimDt380) .AND. EF_STATUS<>"00"
			lRet:=.T.
		Endif
	Else
		If EF_STATUS=="00" .OR. (EF_STATUS == "05" .AND. EF_VALOR==0)
			lRet:=.T.
		Endif
	Endif
Endif
Return(lRet)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³ MenuDef()³ Autor ³ Wagner Montenegro     ³ Data ³22/11/06  ³±±
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
±±³          ³	  1 - Pesquisa e Posiciona em um Banco de Dados           ³±±
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

	Local aRotina := {}
	
	aRotina :=	{{STR0057, 'AxPesqui()'			, 0, 1 },;		//"Buscar"
				{ STR0059, 'A095Fluxo()'		, 0, 4 },; 		//"Fluxo de Caixa"
				{ STR0058, 'A095Bco()'			, 0, 3 },; 		//"Parametros"
				{ STR0064, 'A095Emitir()'		, 0, 6 },;		//"Emitir"
				{ STR0060, 'A095Compes()'		, 0, 4 },; 		//"Liquidar"
				{ STR0062, 'A095Anular(,,,.T.)'	, 0, 5 },;		//"Anular"
				{ STR0083, 'A095Anular(,,,.F.)'	, 0, 7 },;		//"Substituir"
				{ STR0100, 'fA095Devol'			, 0, 4 },;		//"Histórico do cheque"
				{ STR0080, 'A095Talao()'		, 0, 3 },;		//"Talonário"
				{ STR0090, 'fA095Bloq()'		, 0, 8, ,.F.},;	//"Bloquear/Desbloquear"
				{ STR0065, 'fA095Legen(,1)'		, 0, 6, ,.F.}}	//"Legenda"

Return (aRotina)
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ fa095VTalao³ Autor ³ Lucas               ³ Data ³ 15/12/10 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Validar a existencia do Talonario de Cheques.              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ fa095VTalao(cBco380,cAge380,cCta380,cCbxTipo,cTalao)       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Genérico                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function fa095VTalao(cBco380,cAge380,cCta380,aCbxTipo,cCbxTipo,cTalao,lAutomato)
Local aArea := GetArea()
Local cTipo := StrZero(ASCAN(aCbxTipo,cCbxTipo),1)
Local lRet  := .T.
LOcal cTalaoAnt:=cTalao
Local lExiste:=.t.

DEFAULT lAutomato   := .F.

FRE->(dbSetOrder(1))
If FRE->(dbSeek(xFilial("FRE")+cBco380+cAge380+cCta380+cTipo+cTalao))
	cTalao:=GetSX8Num("SA6","A6_TALAO",(LTrim(cBco380)+LTrim(cAge380)+LTrim(cCta380)))
	While lExiste
		If FRE->(dbSeek(xFilial("FRE")+cBco380+cAge380+cCta380+cTipo+cTalao))
			cTalao:=GetSX8Num("SA6","A6_TALAO",(LTrim(cBco380)+LTrim(cAge380)+LTrim(cCta380)))
		Else
			lExiste:=.F.
		EndIf
	EndDo	
	
EndIf
If cTalaoAnt<>cTalao
  If !lAutomato
	MsgAlert(STR0115 +cTalaoAnt + STR0116 + cTalao,STR0080)
  Else
	Conout( STR0115 +cTalaoAnt + STR0116 + cTalao) 
  Endif
EndIf
RestArea(aArea)
Return lRet

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³fa095VTipo³ Autor ³ Lucas                 ³ Data ³ 15/12/10 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Validar a existencia do Talonario de Cheques com o mesmo   ³±±
±±³          ³ Tipo.                                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³fa095VTipo(cBco380,cAge380,cCta380,aCbxTipo,cCbxTipo,cTalao)³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Genérico                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function fa095VTipo(cBco380,cAge380,cCta380,aCbxTipo,cCbxTipo,cTalao)
Local aArea := GetArea()
Local cTipo := StrZero(ASCAN(aCbxTipo,cCbxTipo),1)
Local lRet  := .T.

FRE->(dbSetOrder(1))
If FRE->(dbSeek(xFilial("FRE")+cBco380+cAge380+cCta380+cTipo+cTalao))
	MsgAlert(STR0087,STR0086)
	lRet := .F.
EndIf

RestArea(aArea)
Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³IsCxLoja  ºAutor  ³Totvs		         º Data ³  02/12/10   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Verifica Caixas                                            º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ FINA095                                                    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function IsCxLoja()
LOCAL cStringCX :=""
LOCAL cAlias := Alias()

dbSelectArea("SX5")
dbSeek(xFilial("SX5") + "23")

While !Eof() .and. X5_TABELA == "23"
	cStringCX+=Substr(X5_CHAVE,1,3)
	dbSkip()
	cStringCX+="/"
Enddo

dbSelectArea(cAlias)
Return cStringCX

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±
±±³Fun‡…o	 ³ FA095Bloq³ Autor ³ Rodrigo Gimenes        ³ Data ³ 30.09.10 ³±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±
±±³Descri‡…o ³                                                             ³±
±±³          ³                                                             ³±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±
±±³Sintaxe	 ³                                                             ³±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±
±±³Retorno	 ³              											   ³±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±
±±³Uso		 ³ Localização República Dominicana							   ³±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function FA095Bloq()

Local aArea         := GetArea()
Local oBco380
Local oAge380
Local oCta380
Local oTalao
Local aCbxStatus	:= {STR0038,STR0039} //"Bloqueado","Desbloqueado"

Local lRet			:=	.F.
Local nOpca			:=	0
Local nX
Local cTipo 	:= Criavar("FRE_TIPO")
Local cBco380	:= Criavar("FRE_BANCO")
Local cAge380	:= Criavar("FRE_AGENCIA")
Local cCta380	:= Criavar("FRE_CONTA")
Local cTalao	:= Criavar("FRE_TALAO")
Local cFreStatus:= '1'

Private cStatus := ''
Private _oDlg				// Dialog Principal

DEFINE MSDIALOG _oDlg FROM	31,15 TO 240,300 TITLE  STR0092 PIXEL OF oMainWnd //  ""Bloquear/Desbloquear Talão"
@ 01, 002 TO 102, 142 LABEL  STR0091 OF _oDlg  PIXEL // ""Dados do Talão"
@ 012, 007 SAY  STR0045		SIZE 30,07 OF _oDlg PIXEL //"Fornec."
@ 010, 050 MSGET oTalao		Var	cTalao	F3 "FRE" Picture "@S8"  Size	041,009  PIXEL  OF _oDlg
@ 024, 007 SAY  STR0006		SIZE 40,07 OF _oDlg PIXEL //"Banco"
@ 022, 050 MSGET oBco380	Var	cBco380	Picture "@S4"  Valid CarregaSa6(@cBco380,@cAge380,@cCta380,.F.) .and. ExistCpo("SA6",cBco380+cAge380+cCta380)  When .F.SIZE 22,10 OF _oDlg PIXEL
@ 036, 007 SAY  STR0007		  	SIZE 39,07 OF _oDlg PIXEL //"Agˆncia"
@ 034, 050 MSGET oAge380 Var	cAge380	         Picture "@S5"	Valid CarregaSa6(@cBco380,@cAge380,@cCta380,.F.) .and. ExistCpo("SA6",cBco380+cAge380+cCta380) When .F.	SIZE 35,10 OF _oDlg PIXEL
@ 048, 007 SAY  STR0008			SIZE 41,07 OF _oDlg PIXEL //"Conta"
@ 046, 050 MSGET oCta380 Var	cCta380 Picture "@S10" Valid CarregaSa6(@cBco380,@cAge380,@cCta380,.F.) .and. ExistCpo("SA6",cBco380+cAge380+cCta380) When .F.	SIZE 66,10 OF _oDlg PIXEL
@ 750, 750 MSGET oTipo Var	cTipo Picture "@!" SIZE 66,10 OF _oDlg PIXEL
@ 060, 007 SAY  STR0050		SIZE 41,07 OF _oDlg PIXEL //"Situação"
@ 058, 050 ComboBox	cStatus	Items	aCbxStatus	Size	051,010	PIXEL OF _oDlg


DEFINE SBUTTON FROM 85, 75 TYPE 1 ENABLE OF _oDlg ACTION (nOpca:=If(!Empty(cBco380),1,0),_oDLg:End())
DEFINE SBUTTON FROM 85, 105 TYPE 2 ENABLE OF _oDlg ACTION _oDlg:End()
ACTIVATE MSDIALOG _oDlg CENTERED

If nOpca == 0 .Or. nOpca == 3
	Return(lRet)
Endif
If nOpca == 1
	cFreStatus := StrZero(ASCAN(aCbxStatus,cStatus),1)
	FRE->(dbSetOrder(1))
	If FRE->(dbSeek(xFilial("FRE")+cBco380+cAge380+cCta380+cTipo+cTalao))
		If cFreStatus == '1' .And. fA095ChUsa(cBco380,cAge380,cCta380,cTalao,cFreStatus)
			MSGALERT(STR0093) // "O Talão não pode ser bloqueado pois existem cheques já utilizados."  
		ElseIf cFreStatus == '2' .And. fA095ChUsa(cBco380,cAge380,cCta380,cTalao,cFreStatus)
			MSGALERT(STR0110) // "O Talão selecionado já está desbloqueado."
		Else
			BEGIN TRANSACTION
			RecLock("FRE",.F.)
			FRE->FRE_STATUS	:= 	cFreStatus
			FRE->(MSUnlock())
			DbSelectArea("SEF")
			SEF->(dbSetOrder(10))
			If SEF->(dbSeek(xFilial("SEF")+cBco380+cAge380+cCta380+cTalao))
				While !SEF->(EOF()) .AND. (SEF->EF_BANCO+SEF->EF_AGENCIA+SEF->EF_CONTA+SEF->EF_TALAO == cBco380+cAge380+cCta380+cTalao)
					RecLock("SEF",.F.)
					SEF->EF_LIBER :=	IF(cFreStatus == '1',"N","S")
					SEF->(MSUnlock())
					SEF->(DbSkip())
				EndDo
			EndIf
			MSGALERT(STR0045 + " " + cTalao + " " + IF(cFreStatus == '1',STR0038,STR0039)) // "Talão " + cTalao + Bloqueado\Desbloqueado
			END TRANSACTION
		EndIf
	EndIf
EndIf
RestArea(aArea)
Return(lRet)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±
±±³Fun‡…o	 ³fA095ChUsa³ Autor ³ Rodrigo Gimenes 	     ³ Data ³ 05.07.11 ³±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±
±±³Descri‡…o ³ Verifica se existe algum cheque utilizado para o talão      ³±
±±³          ³                                                             ³±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±
±±³Sintaxe	 ³ lExpL:=fA095ChUsa(cBco,cAge,cCta,cTalao)                    ³±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±
±±³Retorno	 ³ Lógico       											   ³±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±
±±³Uso		 ³ Localização Equador\República Dominicana.				   ³±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function fA095ChUsa(cBco,cAge,cCta,cTalao)
Local aArea	:= GetArea()
Local lRet	:= .F.
Local cChaveFRE     := "" 

SEF->(dbSetOrder(10))          
If SEF->(dbSeek(xFilial("SEF")+cBco+cAge+cCta+cTalao))
	cChaveFRE:=(xFilial("SEF")+cBco+cAge+cCta+cTalao)
	While !SEF->(EOF()) .and. cChaveFRE== xFilial("SEF")+SEF->EF_BANCO+SEF->EF_AGENCIA+SEF->EF_CONTA+SEF->EF_TALAO
		If Alltrim(cStatus) $ "Bloqueado"
			If SEF->EF_STATUS != "00"
				lRet := .T.
				Exit
			EndIf
		Else
			If SEF->EF_LIBER == "S" .And. SEF->EF_STATUS == "00" 
				lRet := .T.
				Exit
			EndIf		
		EndIf	
		SEF->(DbSkip())
	EndDo
EndIf
RestArea(aArea)

Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±
±±³Fun‡…o	 ³fA095Devol| Autor ³ Rodrigo Gimenes        ³ Data ³ 30.09.10 ³±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±
±±³Descri‡…o ³                                                             ³±
±±³          ³                                                             ³±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±
±±³Sintaxe	 ³                                                             ³±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±
±±³Retorno	 ³              											   ³±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±
±±³Uso		 ³ Localização República Dominicana							   ³±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function fA095Devol()

Local aArea         := GetArea()
Local aDevolu	:= {}
Local nPosicao	:= 1
Local oDlg				// Dialog Principal
Local oListBox
Local oPanel
Local nTamFRF:=TamSX3("FRF_NUM")[1]

	dbSelectArea("FRF")
	FRF->(dbSetOrder(1))
	FRF->(dbSeek(xFilial("FRF")+SEF->EF_BANCO+SEF->EF_AGENCIA+SEF->EF_CONTA+SEF->EF_PREFIXO+Subs(SEF->EF_NUM,1,nTamFRF)   ))

	While !FRF->(Eof()) .And. xFilial("FRF")  == FRF->FRF_FILIAL .And. FRF->FRF_BANCO == SEF->EF_BANCO .And. FRF->FRF_AGENCIA == SEF->EF_AGENCIA;
	  				.And. FRF->FRF_CONTA == SEF->EF_CONTA ;
	  				.And. FRF->FRF_NUM == Subs(SEF->EF_NUM,1,nTamFRF)

		aAdd(aDevolu,{FRF->FRF_NUM,FRF->FRF_DATDEV,FRF->FRF_DATPAG,FRF->FRF_MOTIVO,Lower(FRF->FRF_DESCRI),If(EMPTY(FRF->FRF_FORNEC),SEF->EF_FORNECE,FRF->FRF_FORNEC),If(EMPTY(FRF->FRF_LOJA),SEF->EF_LOJA,FRF->FRF_LOJA),FRF->FRF_ESPDOC,FRF->FRF_SERDOC,If(EMPTY(FRF->FRF_NUMDOC),SEF->EF_TITULO,FRF->FRF_NUMDOC),FRF->FRF_ITDOC,FRF->(Recno())})

		dbSelectArea("FRF")
		FRF->(dbSkip())
	EndDo

	If Len( aDevolu ) == 0
		Aviso( "",STR0099 , {"Ok"} ) //"Não existem dados a consultar"
		Return
	Endif

	Asort(aDevolu,,,{|x,y| x[12]<y[12]})

	DEFINE MSDIALOG oDlg FROM 0, 0 TO 300,750 PIXEL TITLE OemToAnsi(STR0095) //"Histórico de Compensações e Devoluções"
	oPanel := TPanel():New(0,0,'',oDlg,, .T., .T.,, ,370,80,.T.,.T. )
	oPanel:Align := CONTROL_ALIGN_BOTTOM
	oPanel:nHeight := 30
	oListBox := TCBrowse():New(0,0,10,10,,,,oDlg,,,,,,,,,,,,,,.T.,,,,.T.,)
	oListBox:AddColumn(TCColumn():New(STR0069,{||aDevolu[oListBox:nAt,1]},,,,,030,.F.,.F.,,,,,))
	oListBox:AddColumn(TCColumn():New(STR0096,{||If(!Empty(aDevolu[oListBox:nAt,2]),aDevolu[oListBox:nAt,2],"")},,,,,030,.F.,.F.,,,,,))
	oListBox:AddColumn(TCColumn():New(STR0097,{||If(!Empty(aDevolu[oListBox:nAt,3]),aDevolu[oListBox:nAt,3],"")},,,,,030,.F.,.F.,,,,,))
	oListBox:AddColumn(TCColumn():New(STR0068,{||aDevolu[oListBox:nAt,4]},,,,,015,.F.,.F.,,,,,))
	oListBox:AddColumn(TCColumn():New(STR0098,{||aDevolu[oListBox:nAt,5]},,,,,020,.F.,.F.,,,,,))
	oListBox:AddColumn(TCColumn():New(AllTrim(SF1->(RetTitle("F1_FORNECE"))),{||aDevolu[oListBox:nAt,6]},,,,,020,.F.,.F.,,,,,))
	oListBox:AddColumn(TCColumn():New(AllTrim(SF1->(RetTitle("F1_LOJA"))),{||aDevolu[oListBox:nAt,7]},,,,,020,.F.,.F.,,,,,))
	oListBox:AddColumn(TCColumn():New(AllTrim(SF1->(RetTitle("F1_DOC"))),{|| If(!Empty(aDevolu[oListBox:nAt,10]),AllTrim(aDevolu[oListBox:nAt,8]) + "  -  " + AllTrim(aDevolu[oListBox:nAt,9]) + " / " + AllTrim(aDevolu[oListBox:nAt,10]) + " - " + AllTrim(aDevolu[oListBox:nAt,11]),"")},,,,,030,.F.,.F.,,,,,))
	oListBox:SetArray( aDevolu)
	oListBox:Align := CONTROL_ALIGN_ALLCLIENT
	DEFINE SBUTTON FROM 02,330 PIXEL TYPE 1 ACTION oDLg:End() ENABLE OF oPanel
	ACTIVATE MSDIALOG oDlg CENTERED

	lRet := .T.

RestArea(aArea)
Return(lRet)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³FINA095   ºAutor  ³Microsiga           ºFecha ³ 10/12/2012  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Monta o cabecalho e o gride de itens da nota de debito com º±±
±±º          ³ os dados do fornecedor e dos cheques.                      º±±
±±º          ³ Esta funcao e chamada na montagem da tela pela LOCXNF,     º±±
±±º          ³ montando-se um bloco de codigo como mostrado abaixo:       º±±
±±º          ³ bFunAuto := {|| A095DadosND(SEF->EF_FORNECE,SEF->EF_LOJA,  º±±
±±º          ³ ,{SEF->(Recno())},"SEF","EF_VALOR",.T.,.T.)}               º±±
±±º          ³ Esta variavel deve ser inicializada antes da chamada a     º±±
±±º          ³ Parametros:                                                º±±
±±º          ³ cFornece		codigo do fornecedor                          º±±
±±º          ³ cLoja    	filial do fornecedor                          º±±
±±º          ³ aItens     	lista dos registros a serem considerados para º±±
±±º          ³            	a nd                                          º±±
±±º          ³ cAlias      	tabela da lista de registros                  º±±
±±º          ³ cCpoVal     	nome do campo que contem o valor do item      º±±
±±º          ³ lLinhas		indica se poderao ser incluidos outros itens  º±±
±±º          ³             	na nd                                         º±±
±±º          ³ lTitulo		indica se os TES para os itens deverao gerar  º±±
±±º          ³          	titulos no financeiro                         º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ FINA095 - geracao de notas de debito para fornecedores     º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function A095DadosND(cFornece,cLoja,aItens,cAlias,cCpoVal,lLinhas,lTitulo,lVldImpFor)
Local nItem			:= 0
Local nPosQtd		:= 0
Local nPosVlrUn		:= 0
Local nPosTotal		:= 0
Local nPosTES		:= 0
Local cValidacao	:= ""
Local bValid		:= {|| }
Local cParCOD := PADR(GETMV("MV_FINPDGB", , "RG498"), GetSx3Cache('B1_COD', 'X3_TAMANHO'))
Local cParTES := GETMV("MV_FINTEGB", , "498")
Local nPosCOD := 0
Local nParUM := ""
Local nParLoc := ""
Local nParCFO := ""
Local nMoedBco := 01
Local nParCont := 0
Local nParCC := 0  
Local nParItmCC := 0   
Local nParClvl := 0 
Local lF100detus := Existblock("F100DETUSR")
Local aF100detus := {}
Local nF100detus := 0
 
Default cFornece	:= ""
Default cLoja		:= ""
Default aItens		:= {}
Default cAlias		:= "SEF"
Default cCpoVal		:= "EF_VALOR"
Default lTitulo		:= .T.
Default lLinhas		:= .T.
Default lVldImpFor	:= .F.

If !Empty(aItens)
	/* inicializa os dados do cebecalho da nota */
	M->F1_FORNECE := cFornece
	M->F1_LOJA := cLoja
	IF cPaisLoc == "ARG" .and. Funname() == "FINA100"
		nMoedBco := Posicione("SA6",1,xfilial("SA6") + SE5->E5_BANCO + SE5->E5_AGENCIA + SE5->E5_CONTA ,"A6_MOEDA") 
		M->F1_MOEDA		:= nMoedBco
		M->F1_TXMOEDA	:= IIF(SE5->E5_TXMOEDA > 0,IIF(nMoedBco > 1 ,SE5->E5_TXMOEDA,1), RecMoeda(dDataBase,nMoedBco))
		M->F1_NATUREZ 	:= SE5->E5_NATUREZ
		nMoedaNF		:=	nMoedBco
		nTaxa			:=	M->F1_TXMOEDA
		nMoedaCor		:=	nMoedaNF
	EndIf

	/* impede a edicao do fornecedor */
	If Type("__aoGets")!= "U" .And. ValType(__aoGets)=="A"
		nItem := Ascan(__aoGets,{|aget| AllTrim(Upper(aget:cReadVar)) == "M->F1_FORNECE"})
		If nItem > 0
			__aoGets[nItem]:bWhen := {|| .F.}
		Endif
		nItem := Ascan(__aoGets,{|aget| AllTrim(Upper(aget:cReadVar)) == "M->F1_LOJA"})
		If nItem > 0
			__aoGets[nItem]:bWhen := {|| .F.}
		Endif
	Endif
	/*
	inicializa os dados dos itens */
	nPosCOD   := Ascan(aHeader,{|cpo| AllTrim(cpo[2]) == "D1_COD"})
	nParUM    := Ascan(aHeader,{|cpo| AllTrim(cpo[2]) == "D1_UM"})
	nParLoc   := Ascan(aHeader,{|cpo| AllTrim(cpo[2]) == "D1_LOCAL"})
	nPosQtd   := Ascan(aHeader,{|cpo| AllTrim(cpo[2]) == "D1_QUANT"})
	nPosVlrUn := Ascan(aHeader,{|cpo| AllTrim(cpo[2]) == "D1_VUNIT"})
	nPosTotal := Ascan(aHeader,{|cpo| AllTrim(cpo[2]) == "D1_TOTAL"})
	nPosTES   := Ascan(aHeader,{|cpo| AllTrim(cpo[2]) == "D1_TES"})
	nParCFO   := Ascan(aHeader,{|cpo| AllTrim(cpo[2]) == "D1_CF"})
	nParCont  := Ascan(aHeader,{|cpo| AllTrim(cpo[2]) == "D1_CONTA"})	
	nParItmCC := Ascan(aHeader,{|cpo| AllTrim(cpo[2]) == "D1_ITEMCTA"})	
	nParCC    := Ascan(aHeader,{|cpo| AllTrim(cpo[2]) == "D1_CC"})	
	nParClvl  := Ascan(aHeader,{|cpo| AllTrim(cpo[2]) == "D1_CLVL"})	

	aCols := {}
	For nItem := 1 To Len(aItens)
		If aItens[nItem] > 0
			(cAlias)->(DbGoTo(aItens[nItem]))
			oGetDados:AddLine()
			aCols[nItem,nPosQtd] := 1
			If FunName() == "FINA100"
				SB1->(DbSetOrder(RetOrder("SB1","B1_FILIAL+B1_COD")))
				SB1->(MsSeek(xFilial("SB1") + cParCOD))
				aCols[nItem,nPosCOD] := cParCOD
				aCols[nItem,nParUM] := SB1->B1_UM
				aCols[nItem,nParLoc] := SB1->B1_LOCPAD
				aCols[nItem,nParCont] := SB1->B1_CONTA
				aCols[nItem,nParItmCC] := SB1->B1_ITEMCC
				aCols[nItem,nParCC] := SB1->B1_CC
				aCols[nItem,nParClvl] := SB1->B1_CLVL
				
				SF4->(DbSetOrder(RetOrder("SF4","F4_FILIAL+F4_CODIGO")))
				SF4->(MsSeek(xFilial("SF4") + cParTES))
				aCols[nItem,nPosTES] := cParTES
				aCols[nItem,nParCFO] := SF4->F4_CF
			EndIf
			aCols[nItem,nPosVlrUn] := (cAlias)->&cCpoVal
			aCols[nItem,nPosTotal] := (cAlias)->&cCpoVal
		Endif
	Next
	// El punto de entrada permite la inclusión de valores en el arreglo aCols.
	If lF100detus .and. Funname() == "FINA100" 
		ExecBlock("F100DETUSR", .F., .F.) 
	EndIf 

	nItem--		//contem a quantidade de documentos devolvidos
	cValidacao := "(n>=" + AllTrim(Str(nItem)) + ")"
	/*
	altera a validacao da quantidade para nao permitir sua alteracao quando o item for um documento devolvido */
	If Empty(aHeader[nPosQtd,6])
		aHeader[nPosQtd,6] := cValidacao
	Else
		aHeader[nPosQtd,6] := cValidacao + " .And. " + aHeader[nPosQtd,6]
	Endif
	/*
	altera a validacao do valor para nao permitir sua alteracao quando o item for um documento devolvido */
	If Empty(aHeader[nPosVlrUn,6])
		aHeader[nPosVlrUn,6] := cValidacao
	Else
		aHeader[nPosVlrUn,6] := cValidacao + " .And. " + aHeader[nPosVlrUn,6]
	Endif
	/*
	altera a validacao do valor para nao permitir sua alteracao quando o item for um documento devolvido */
	If Empty(aHeader[nPosTotal,6])
		aHeader[nPosTotal,6] := cValidacao
	Else
		aHeader[nPosTotal,6] := cValidacao + " .And. " + aHeader[nPosTotal,6]
	Endif
	/*
	nao permite TES que atualizem estoque e/ou que nao gerem titulos*/
	If Empty(aHeader[nPosTES,6])
		aHeader[nPosTES,6] := "A095NDTES(M->D1_TES," + If(lTitulo,".T.",".F.") + "," + If(lVldImpFor,".T.",".F.") + ")"
	Else
		aHeader[nPosTES,6] := "A095NDTES(M->D1_TES," + If(lTitulo,".T.",".F.") + "," + If(lVldImpFor,".T.",".F.") + ") .And. " + aHeader[nPosTES,6]
	Endif
	/*-*/
	If Empty(oGetDados:cLinhaOK)
		If lLinhas
			oGetDados:cLinhaOK := "A095NDTES(," + If(lTitulo,".T.",".F.") + "," + If(lVldImpFor,".T.",".F.") + ")"
		Else
			oGetDados:cLinhaOK := "A095NDTES(," + If(lTitulo,".T.",".F.") + "," + If(lVldImpFor,".T.",".F.") + ") .And. " + cValidacao
		Endif
	Else
		If lLinhas
			oGetDados:cLinhaOK := "A095NDTES(," + If(lTitulo,".T.",".F.") + "," + If(lVldImpFor,".T.",".F.") + ") .And. " + oGetDados:cLinhaOK
		Else
			oGetDados:cLinhaOK := "(A095NDTES(," + If(lTitulo,".T.",".F.") + "," + If(lVldImpFor,".T.",".F.") + ") .And. " + cValidacao + ") .And. " + oGetDados:cLinhaOK
		Endif
	Endif
	If Empty(oGetDados:cTudoOK)
		oGetDados:cTudoOK := "A095NDTES(," + If(lTitulo,".T.",".F.") + "," + If(lVldImpFor,".T.",".F.") + ")"
	Else
		oGetDados:cTudoOK := "A095NDTES(," + If(lTitulo,".T.",".F.") + "," + If(lVldImpFor,".T.",".F.") + ") .And. " + oGetDados:cTudoOK
	Endif
	/*
	nao pemite a exclusao dos itens referentes aos documentos devolvidos */
	If Empty(oGetDados:cSuperDel)
		oGetDados:cSuperDel := cValidacao
	Else
		oGetDados:cSuperDel := cValidacao + ".And. " + oGetDados:cSuperDel
	Endif
	If Empty(oGetDados:cDelOk)
		oGetDados:cDelOk := cValidacao
	Else
		oGetDados:cDelOk := cValidacao + ".And. " + oGetDados:cDelOk
	Endif
	/*
	define uma funcao para ser executada ao final da edicao da nota de debito para capturar os dados na nd gerada */
	oGetDados:oWnd:bValid := {|| A095NDGer(),.T.}
	/*-*/
	oGetDados:lNewLine := .F.
	/*-*/
	MaFisClear()
	MaColsToFis(aHeader,aCols,,"MT100",.T.)
	If !lLinhas
		oGetDados:nMax := nItem
	Endif
	oGetDados:oBrowse:nAt := 1
	oGetDados:oBrowse:Refresh()
Endif
Return()

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³FINA096   ºAutor  ³Microsiga           ºFecha ³ 12/12/2012  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Recupera os dados da nota de debito gerada para serem      º±±
±±º          ³ incluidos nos cheques devolvidos.                          º±±
±±º          ³ Atribui os valores as variaveis declaradas como PRIVATE    º±±
±±º          ³ pela rotina que executou a funcao da locxnf.               º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ FINA096 - geracao de notas de debito para fornecedores     º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function A095NDTES(cTes,lTitulo,lVldImpFor)
Local aAreaSFC	:= SFC->(GetArea())
Local lRet		:= .T.
Local nPosTES	:= 0
Local oModel    := FWModelActive()
Local oModelSD1 := Nil
Local lModelAct := ValType(oModel) == "O"  .And. oModel:IsActive()

Default cTes		:= ""
Default lTitulo		:= .T.
Default lVldImpFor	:= .F.

If lModelAct
	oModelSD1 := oModel:GetModel("SD1_DETAIL")
EndIf

If Empty(cTes)
	If ValType(oModelSD1) == "O" .And. oModelSD1:HasField("D1_TES")
		cTes := oModelSD1:GetValue("D1_TES")
	Else
		nPosTES := Ascan(aHeader,{|cpo| AllTrim(cpo[2]) == "D1_TES"})
		If nPosTES <> 0
			cTes := aCols[n,nPosTES]
		Endif
	EndIf
Endif

If !Empty(cTes)
	If SF4->(DbSeek(xFilial("SF4") + cTes))
		/* para despesas, o TES nao deve atualizar estoque e deve gerar titulos no financeiro */
		If SF4->F4_ESTOQUE == "S" .Or. If(lTitulo,SF4->F4_DUPLIC <> "S",SF4->F4_DUPLIC == "S")
			If lTitulo
				If lModelAct
					oModel:SetErrorMessage("",,oModel:GetId(),"","A095NDTES",STR0117) // "Para incluir Gastos utilice una TES que no actualice Stock y que genere títulos financieros."
				Else
					MsgAlert(STR0117) // "Para incluir Gastos utilice una TES que no actualice Stock y que genere títulos financieros."
				EndIf
			ElseIf lModelAct
					oModel:SetErrorMessage("",,oModel:GetId(),"","A095NDTES",STR0118) // "Para incluir Gastos utilice una TES que no actualice Stock y que no genere títulos financieros."
			Else
				MsgAlert(STR0118) // "Para incluir Gastos utilice una TES que no actualice Stock y que no genere títulos financieros."
			Endif
			lRet := .F.
		Endif

		If lRet .And. cPaisLoc == "ARG" .And. lVldImpFor
			SFC->(DbSetOrder(1)) //FC_FILIAL+FC_TES+FC_SEQ+FC_IMPOSTO
			If SF4->F4_DUPLIC <> "S" .And. SFC->(DbSeek(XFilial("SFC")+SF4->F4_CODIGO))
				lRet := .F.
				If lModelAct
					oModel:SetErrorMessage("",,oModel:GetId(),"","A095NDTES",STR0106) //"Para notas de troca de valor, utilize TES que gere duplicata e não possua configuração de impostos."
				Else
					MsgAlert(STR0106) //"Para notas de troca de valor, utilize TES que gere duplicata e não possua configuração de impostos."
				EndIf
			EndIf
		EndIf

	Endif
Endif

RestArea(aAreaSFC)

Return(lRet)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³FINA095   ºAutor  ³Microsiga           ºFecha ³ 11/12/2012  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Recupera os dados da nota de debito gerada para serem      º±±
±±º          ³ incluidos nos cheques devolvidos.                          º±±
±±º          ³ Atribui os valores as variaveis declaradas como PRIVATE    º±±
±±º          ³ pela rotina que executou a funcao da locxnf.               º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ FINA095 - geracao de notas de debito para fornecedores     º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function A095NDGer()
Local nItem
Local oModel    := FWModelActive()
Local lModelAct := ValType(oModel) == "O"  .And. oModel:IsActive()
Local oModelSF1	:= Nil

If lModelAct
	oModelSF1 := oModel:GetModel("SF1_MASTER")

	If ValType(oModelSF1) == "O"
		cNumNota := oModelSF1:GetValue("F1_DOC")
		cSerNota := oModelSF1:GetValue("F1_SERIE")
		cEspNota := oModelSF1:GetValue("F1_ESPECIE")
		nValBrut := oModelSF1:GetValue("F1_VALBRUT")

		Return(.T.)
	EndIf
EndIf

If oGetDados:oWnd:nResult == 0
	If Type("__aoGets")!= "U" .And. ValType(__aoGets)=="A"
		nItem := Ascan(__aoGets,{|aget| AllTrim(Upper(aget:cReadVar)) == "M->F1_DOC"})
		If nItem > 0
			cNumNota := __aoGets[nItem]:cText
		Endif
		nItem := Ascan(__aoGets,{|aget| AllTrim(Upper(aget:cReadVar)) == "M->F1_SERIE"})
		If nItem > 0
			cSerNota := __aoGets[nItem]:cText
		Endif
		nItem := Ascan(__aoGets,{|aget| AllTrim(Upper(aget:cReadVar)) == "M->F1_ESPECIE"})
		If nItem > 0
			cEspNota := __aoGets[nItem]:cText
		Endif
		nItem := Ascan(__aoGets,{|aget| AllTrim(Upper(aget:cReadVar)) == "M->F1_VALBRUT"})
		If nItem > 0
			nValBrut := __aoGets[nItem]:cText
		Endif
	Endif
Endif
Return(.T.)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³FINA095   ºAutor  ³Microsiga           º Data ³  02/23/12   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function A095VldPrx(cPrefix,cChqDe,cChqAte)

Local lReturn 	:= .T.
Local aAreaFRE 	:= FRE->(GetArea())

DEFAULT cPrefix	:= ""
DEFAULT cChqDe	:= ""
DEFAULT cChqaTE	:= ""

If !Empty(cPrefix) .And. Empty(cChqDe) .And. Empty(cChqAte)
	dbSelectArea("FRE")
	If !Empty(IndexKey(4))
		FRE->(dbSetOrder(4))

		If FRE->(dbSeek(xFilial("FRE")+cPrefix))						
			MsgAlert(STR0105)	
			lReturn := .F.
		EndIf
	EndIf
ElseIf !Empty(cPrefix) .And. !Empty(cChqDe) .And. !Empty(cChqAte)
	dbSelectArea("FRE")
	If !Empty(IndexKey(4))
		FRE->(dbSetOrder(4))

		If FRE->(dbSeek(xFilial("FRE")+cPrefix))
			While !FRE->(Eof()) .And. FRE->FRE_FILIAL == xFilial("FRE") .And. FRE->FRE_PREFIX == cPrefix
				//garantir que a numeração dos cheques não esteja sendo utilizada em outro talão
				If (cChqDe >= FRE->FRE_SEQINI .AND. cChqDe <= FRE->FRE_SEQFIM) .OR. (cChqAte >= FRE->FRE_SEQINI .AND. cChqAte <= FRE->FRE_SEQFIM)
					lReturn := .F.
					MsgAlert(STR0105)
					Exit
				EndIf
				FRE->(dbSkip())
			EndDo
		EndIf
	EndIf
Else
	lReturn := .F.
	MsgAlert(STR0052)
EndIf

FRE->(RestArea(aAreaFRE))

Return lReturn

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³FA95NUMTITºAutor  ³Microsiga           º Data ³  02/23/12   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function FA95NUMTIT(cNumChq,cTitulo,cFornec,cLoja,lOP,cBanco,cConta,cAgencia)
	
	Local aArea 	:= GetArea()
	Local aAreaSEF 	:= {}
	Local cQuery	:= ""
	Local cAlias	:= ""
	Local cChqOrg 	:= ""
	
	DbSelectArea("SEF")
	aAreaSEF 	:= SEF->(GetArea())
	
	cChqOrg := ""
	
	#IFDEF TOP
		cChqOrg := ""
		cQuery 	:=  "SELECT SE2.E2_NUM FROM "+RetSqlName("SEF")+" SEF "
		cQuery  +=  " INNER JOIN " + RetSqlName("SE2") + " SE2 ON(SE2.E2_NUMBCO = '" +  cNumChq + "' And SE2.E2_PREFIXO = SEF.EF_PREFIXO) "
		cQuery	+=	" WHERE EF_FILIAL = '"+xFilial("SEF")+"' AND "
		cQuery	+=	" EF_TITULO = '" + cTitulo +"' AND SE2.E2_NUMBCO = '" + cNumChq + "' AND "
		cQuery	+=	" EF_FORNECE  = '"+ cFornec +"' AND  EF_LOJA  = '"+ cLoja +"' AND "
		cQuery	+=	" E2_BCOCHQ  = '" + cBanco + "' AND  E2_CTACHQ  = '" + cConta + "' AND "
		cQuery	+=	" E2_AGECHQ  = '" + cAgencia + "' AND "
		cQuery	+=	" SEF.D_E_L_E_T_ = ''"
		If lOP
			cQuery	+= " AND SE2.E2_ORDPAGO = SEF.EF_TITULO"
		EndIf
		cQuery 	:= 	ChangeQuery(cQuery)
		cAlias	:=	GetNextAlias()
		dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAlias,.F.,.T.)
		If (cAlias)->(!Eof())
			cChqOrg := (cAlias)->(E2_NUM)
		EndIf
		DbCloseArea()
	#ELSE
		cChqOrg := ""
		dbSelectArea("SEF")
		SEF->(dbSetOrder(2)) //EF_FILIAL+EF_PREFIXO+EF_TITULO+EF_PARCELA+EF_TIPO+EF_NUM+EF_SEQUENC
		SEF->(dbGoTop())
		If SEF->(dbSeek(xFilial("SEF")+" "+cTitulo))
			While !Eof() .And. Empty(cChqOrg)
				If SEF->EF_TITULO == cTitulo .And. SEF->(EF_FORNECE + EF_LOJA) == Fornec .And. SEF->EF_SUBCHE == cNumChq
					If Len(ALLTRIM(SEF->EF_TITULO)) == Len(ALLTRIM(SEF->EF_NUM))
						cChqOrg := SEF->EF_TITULO
					EndIf
				EndIf
			SEF->(dbSkip())
			Enddo
		EndIf
	#ENDIF
	
	If Empty(cChqOrg)
		cChqOrg := cNumChq
	EndIf
	
	RestArea(aAreaSEF)
	RestArea(aArea)

Return cChqOrg

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o	 ³ fa090Can ³ Autor ³ Wagner Xavier 		³ Data ³ 07/06/01 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Rotina de Cancelamento de Baixa a pagar					  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe	 ³ fa090can(ExpC1,ExpN1,ExpN1)								  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso		 ³ FINA090													  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function fa090Can(cAlias,nReg,nOpcx,aMotivos,lAnular,lAutomato)

	LOCAL oDlg
	LOCAL lOk       := .F.
	LOCAL lDigita   := IIF(mv_par01==1,.T.,.F.)
	LOCAL nHdlPrv   := 0
	LOCAL nTotal    := 0
	LOCAL lPadraoBx :=.F.
	LOCAL nOrdem
	LOCAL lPadraoVd
	LOCAL cArquivo
	LOCAL nSalvRec  := 0
	LOCAL cParcela
	LOCAL cNum
	LOCAL cPrefixo
	LOCAL dBaixa
	LOCAL cAgencia	:= CriaVar("E1_AGEDEP")
	LOCAL cCheque	:= CriaVar("EF_NUM")
	LOCAL cFornece
	LOCAL cMoeda
	LOCAL cTitAnt
	LOCAL cDescrMo	:= " "
	LOCAL aBaixa 	:= {}
	LOCAL nOpBaixa  := 1
	LOCAL cTipo
	LOCAL nJuros 	:= 0
	LOCAL nMulta 	:= 0
	LOCAL nCorrec 	:= 0
	LOCAL nDescont  := 0
	LOCAL dDataAnt
	LOCAL lBaixaAbat	:= .F.
	LOCAL cSequencia 	:= Space( TamSX3("E5_SEQ")[1] )
	LOCAL nRegB
	LOCAL lVend 		:= .F.
	LOCAL nRegV
	LOCAL lCheque 		:= .F.
	LOCAL cBenef 		:= ""
	LOCAL lContabilizou := .F.
	LOCAL cNumCheq	    := CRIAVAR("EF_NUM")
	LOCAL lEstorna
	LOCAL nTotAdto 	 := 0
	LOCAL cSeqSe5    := Space( TamSX3("E5_SEQ")[1] )
	LOCAL nTxMoeda   := 0
	LOCAL aAux       := {}
	LOCAL nI         := 0
	LOCAL nRecDelSef := 0
	LOCAL nRecSe5   := 0
	Local lRet      := .T.
	Local lFa080Own := ExistBlock("FA080OWN")
	Local aMotBx    := ReadMotBx()
	Local cPadrao
	Local cTitOriV  := CRIAVAR("E2_TITORIG")
	Local lBaixaOk	:= .T.
	Local nOrdSa6, nRecSa6
	Local nDifCambio := 0
	Local nImpSubst  := 0
	Local nOtrga     := 0
	Local nAtraso 	 := 0
	lOCAL cRef	     := ""
	Local lUsaFlag	 := SuperGetMV( "MV_CTBFLAG" , .T. /*lHelp*/, .F. /*cPadrao*/)
	Local aFlagCTB   := {}
	Local cFilOr	 := ""
	Local cSeqFRF
	Local cChqSub	 :=	CriaVar("EF_NUM")
	Local cChqOrig	 :=	CriaVar("EF_NUM")
	Local cPrxSub	 :=	CriaVar("EF_PREFIXO")
	Local lCheckSub	 :=	.F.
	Local lCheckNul	 :=	If(FUNNAME()=="FINA095" .and. SEF->EF_STATUS=="00",.T.,.F.)
	Local nRegChSub	 :=0
	Local dDtVctoSub :=	dDataBase
	Local cEfBenef,cHistOP,cEfLiber,cEfLA,cEfSeq,cEfParc
	Local cEfLoja,cEfFornec,cEfTitulo,cEfTipo,nEfValor
	Local cEfOrdPg := ""
	Local cNumBor
	Local oGrp1
	Local oRadio
	Local nRadio
	Local nL
	Local cChave        := ""
	Local lAtuForn      := SuperGetMv("MV_ATUFORN",.F.,.T.)
	/*
	notas de debito */
	Local oEspecie
	Local cEspecie		:= Criavar("F1_ESPECIE")
	Local aNDs			:= {{"NDP","",9},{"NCI","",8}}
	Local aRegSEF		:= {}
	Local nTipoND		:= 0
	Local aEspecies		:= {}
	Local lF080EST 		:= EXISTBLOCK("F080EST")
	Local lAtuSldBco    := SuperGetMv("MV_ATUSLBC",.F.,.T.)
	Local aAreaSEF		:={}
	Local nValEstrang	:= 0
	Local nPosSEF		:= SEF->(RECNO())
	Local nVA := 0
	Local oModelMov := Nil
	Local oModelBx  := Nil
	Local oSubFKA   := Nil
	Local oSubFK5   := Nil
	Local oNomeFor		:= NIL
	Local lA6Moedap		:= SA6->( FieldPos("A6_MOEDAP") > 0 )
	Local nLinMais		:= 0	
	Local nLinBut		:= 0
	Local cEfOrigem		:= ""
	Local cEfFilChq		:= ""

	Private lMsErroAuto := .F.
	Private oCBXMotiv
	Private oChkBoxNul
	Private oChkBoxSub
	Private oBcoSub
	Private oAgeSub
	Private oCtaSub
	Private oChqSub
	Private oDtVctoSub
	Private lNoE2bx		:=	.F.
	Private cChStatus		:=	If( FUNNAME()=="FINA095",SEF->EF_STATUS,"")
	Private nChvLbx		:=	0
	Private cChvLbx		:=	""
	Private cMotivo		:=	""
	Private nRecChqSub   :=	0
	Private nRegChOri		:=If(cPaisloc != "BRA" .and. FUNNAME()=="FINA095",SEF->(Recno()),0)
	Private aBaixaSE5 := {}
	Private lTOk		:=	.F.
	/*dados da nota de debito */
	Private cNumNota	:= ""
	Private cSerNota	:= ""
	Private cEspNota	:= ""

	Private cBcoSub   :=  Iif(cPaisLoc=="BRA",CriaVar("A6_COD"),CriaVar("EF_BANCO"))
	Private cAgeSub   :=  Iif(cPaisLoc=="BRA",CriaVar("A6_AGENCIA"),CriaVar("EF_AGENCIA"))
	Private cCtaSub   :=  Iif(cPaisLoc=="BRA",CriaVar("A6_CONTA"),CriaVar("EF_CONTA"))

	Private cTipoTalao := "1"

	Private cNumTalao	:= Criavar("FRE_TALAO"), oTalao
	Private cTipTalao	:= Criavar("FRE_TIPO"), oTipTalao
	Private cNumCHQ		:= ""
	Private nTalCHQ		:= 0
	Private cPreCHQ		:= ""
	Private lTipo		:= .T.
	Default aMotivos	:=	{}
	Default lAutomato	:= .F.
	Default lAnular		:= .T.

	If cPaisLoc != "BRA" .and. FUNNAME()=="FINA095"
		/*	seleciona os tipo de notas de debito */
		If cPaisLoc == "ARG"
			aAdd(aNDs, {"NF","",10})
		EndIf
		aEspecies := {}
		For nL := 1 To Len(aNDs)
			If SX5->(DbSeek(xFilial("SX5") + "42" + PadR(aNDs[nL,1],Len(SX5->X5_CHAVE))))
				aNDs[nL,2] := AllTrim(Lower(X5Descri()))
				Aadd(aEspecies,AllTrim(aNDs[nL,1]) + "=" + aNDs[nL,2])
			EndIf
		Next
	EndIf
	/*ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	 *³Verifica se o Titulo nao sofreu nenhuma baixa  ³
	 *ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
	IF Empty(SE2->E2_BAIXA)
		If (!(cPaisLoc != "BRA") .or. (cPaisLoc != "BRA" .and. FUNNAME()<>"FINA095") .or. (cPaisLoc != "BRA" .and. FUNNAME()=="FINA095" .and. !cChStatus $ "00/01/02/03/07"))
			If	!(cPaisLoc != "BRA" .and. FUNNAME()$"FINA086|FINA847" .And. (SEF->EF_STATUS $ "00/01/02/03/07"))
				Help(" ",1,"TITNAOXADO")
			EndIf
			Return
		Else
			lNoE2bx	:=	.T.
		EndIf
	EndIF

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Verifica se data do movimento n„o ‚ menor que data limite de ³
	//³ movimentacao no financeiro                                   ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If !lNoE2bx .and. !DtMovFin(SE2->E2_BAIXA,,"1")
		Return
	Endif


	/*ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	 *³Verifica se ‚ um registro Principal ³
	 *ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
	IF SE2->E2_TIPO $ MVABATIM
		Help(" ",1,"NAOPRINCIP")
		Return
	Endif

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Verifica se o documento e para reposicao de um caixinha e se ³
	//³ esse caixinha possui saldo suficiente para a operacao.		 ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If cPaisLoc<>"BRA"
		If Upper(Left(SE2->E2_NUMBCO,5))=="CJCC_"
			If !Fa550CJCC(Substr(SE2->E2_NUMBCO,6),"S")
				MsgAlert(STR0118) //"Este documento foi gerado para a reposicao de uma caixinha. E este caixinha nao possui saldo suficiente para esta operacao."
				Return
			Endif
		Endif
	Endif

	dbSelectArea("SE2")
	nOrdem := IndexOrd()
	dbSetOrder(1)

	cMoeda		:= IIf(Empty(SE2->E2_MOEDA),"1",AllTrim(Str(SE2->E2_MOEDA,2)))
	nSalvRec	:= SE2->( RecNO() )
	cNum		:= SE2->E2_NUM
	cPrefixo	:= SE2->E2_PREFIXO
	cParcela	:= SE2->E2_PARCELA
	cFornece	:= SE2->E2_FORNECE
	cTipo		:= SE2->E2_TIPO
	cLoja		:= SE2->E2_LOJA
	nTotAbat	:= 0
	nValPgto	:= SE2->E2_VALLIQ
	dBaixa		:= SE2->E2_BAIXA
	nTotAbat	:= SumAbatPag( cPrefixo, cNum, cParcela, cFornece, SE2->E2_MOEDA,"V",dBaixa,cLoja )
	If cPaisLoc == "CHI"
		nOtrga		:= SE2->E2_OTRGA
		nDifCambio	:= SE2->E2_CAMBIO
		nImpSubst	:= SE2->E2_IMPSUBS
	EndIf
	SE2->( dbGoTo( nSalvRec ) )

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Procura pelas baixas deste titulo ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If !lNoE2bx
		aBaixa := Sel080Baixa( "VL /BA /CP /",cPrefixo, cNum, cParcela,cTipo,@nTotAdto,@lBaixaAbat,cFornece,cLoja)
	Else //APENAS EQUADOR QDO CHAMADO DE FINA095
		Aadd(aBaixaSE5,{ ,,,,,,,,,,SEF->EF_BANCO,SEF->EF_AGENCIA,SEF->EF_CONTA,,,,,,,})
	Endif
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Escolhe Baixa a ser cancelada  ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If Len(aBaixa) > 1
		cListBox := aBaixa[1]
		nOpbaixa := 1
		DEFINE MSDIALOG oDlg FROM 5, 5 TO 14, 50 TITLE  STR0121 //"Escolha A Baixa"

		@	.5, 2 LISTBOX nOpBaixa ITEMS aBaixa SIZE 150 , 40 Font oDlg:oFont
		DEFINE SBUTTON FROM 055,112	TYPE 1 ACTION (lOk := .T.,oDlg:End()) ENABLE OF oDlg
		DEFINE SBUTTON FROM 055,139.1 TYPE 2 ACTION (lOk := .F.,oDlg:End()) ENABLE OF oDlg

		ACTIVATE MSDIALOG oDlg CENTERED
		If !lOk
			Return Nil
		Endif
	EndIF

	If Len(aBaixa) == 0 .AND. !lNoE2bx //"EQU"
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Procura pelas compensa‡”es ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

		If SE5->(dbSeek(xFilial("SE5")+"CP"+cPrefixo+cNum+cParcela+cTipo))
			Help(" ",1,"TITULOADT")
		ElseIf SE2->E2_TIPO $ MVPAGANT+"/"+MV_CPNEG .and. !lBaixaAbat
			Help(" ",1,"TITULOADT")
		Elseif Empty( SE2 -> E2_FATURA )
			Help(" ",1,"BAIXTITINC")
		Else
			Help(" ",1,"TITFATURAD")
		EndIF
		Return
	EndIF

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Pega os Valores da Baixa Escolhida ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If !lNoE2bx
		dBaixa		:= aBaixaSE5[nOpBaixa,07]
		cSequencia 	:= aBaixaSE5[nOpBaixa,09]
		cChave := SE2->E2_PREFIXO+SE2->E2_NUM+SE2->E2_PARCELA+SE2->E2_TIPO+Dtos(dBaixa)+cFornece+cLoja+cSequencia
	Else
		dBaixa:=	SEF->EF_DATA
		cRef	:=	SEF->EF_NUM
		If cPaisLoc == "ARG"
			dDtVctoSub := SEF->EF_VENCTO
		EndIf
	Endif
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Verifica se data do cancelamento ‚ menor que a data da baixa ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If dBaixa > dDataBase
		Help(" ",1,"DTBAIXA")
		Return
	Endif

	If !lNoE2bx //Se Pais = "EQU" e houve baixa no E5 ou Pais<> "EQU" entra no IF. (Para situações sem Bx no E5 não executa o IF, condição exclusiva EQUADOR)
		dbSelectArea("SE5")
		SE5->(dbSetOrder(2))
		cTipoDoc := "CM/CX/DC/MT/JR/BA/VL/VA"
		IIf(cPaisloc == "CHI",cTipoDoc += "IS/",.T.)
		For nI := 1 to len( cTipoDoc) Step 3
			IF SE5->( dbSeek(xFilial("SE5")+substr(cTipoDoc,nI,2)+cChave) )
				If substr(cTipoDoc,nI,2 ) $ "CM/CX"
					If cPaisloc <> "CHI"
						nCorrec		:= SE5->E5_VALOR
					Else
						nDifcambio	:=SE5->E5_VALOR
					EndIf
				ElseIf substr(cTipoDoc,nI,2 ) $ "DC"
					nDescont:= SE5->E5_VALOR
				ElseIf substr(cTipoDoc,nI,2 ) $ "MT"
					nMulta	:= SE5->E5_VALOR
				ElseIf substr(cTipoDoc,nI,2 ) $ "JR"
					If cPaisloc <> "CHI"
						nJuros	:= SE5->E5_VALOR
					Else
						nOtrga	:= SE5->E5_VALOR
					EndIf
				ElseIf substr(cTipoDoc,nI,2 ) $ "VA"
					nVA		:= SE5->E5_VALOR
				ElseIf substr(cTipoDoc,nI,2 ) $ "BA/VL"
					If cPaisLoc <> "BRA" .And. !Empty(SE5->E5_BANCO)
						SA6->(DbSetOrder(1))
						SA6->(dbSeek(xFilial()+SE5->E5_BANCO+SE5->E5_AGENCIA+SE5->E5_CONTA))
						nValPgto := xMoeda(SE5->E5_VALOR,Max(IIf(lA6Moedap,SA6->A6_MOEDA,SA6->A6_MOEDAP),1),Val(SE5->E5_MOEDA),SE5->E5_DATA)
					Else
						nValPgto := SE5->E5_VALOR
					Endif
					cHist070 := SE5->E5_HISTOR
					cMotBx   := SE5->E5_MOTBX
					cNumBor  := SubStr(SE5->E5_DOCUMEN,1,6)
					cLoteFin := SE5->E5_LOTE
					nRecSe5  := SE5->(RecNo())
					nValestrang := SE5->E5_VLMOED2
				ElseIf substr(cTipoDoc,nI,2 ) $ "IS" 	//Localizacao Chile
					nImpsubst	:= SE5->E5_VALOR
				EndIF
			EndIF
		Next
	Endif
	lEstorna 	 := Iif(Empty(cNumBor),.F.,.T.)
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Verifica se foi utilizada taxa contratada para moeda > 1          ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If !lNoE2bx
		dbGoTo(nRecSe5)		//volta para o registro principal

		If SE2->E2_MOEDA > 1 .and. Round(NoRound(xMoeda(nValpgto,1,SE2->E2_MOEDA,dBaixa,3),3),2) != SE5->E5_VLMOED2
			nTxMoeda := Noround((SE5->E5_VALOR / SE5->E5_VLMOED2),5)
		Else
			nTxMoeda := RecMoeda(dBaixa,SE2->E2_MOEDA)
		Endif
	Endif
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Caso moeda ==1 a funcao RecMoeda iguala nTxMoeda = 0. Iguala-se    ³
	//³nTxMoeda = 1 p/ evitar problema c/ calculos de abatimento e outros.³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	nTxMoeda := IIF(nTxMoeda == 0 , 1 , nTxMoeda)

	If !lNoE2bx
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Verifica se foi ja foi gerado cheque para esta baixa; se o cheque ³
		//³ ja foi gerado nao permite o cancelamento                         ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		aAreaSEF:=SEF->(GetArea())
		dbSelectArea("SEF")
		dbSetOrder(3)
		If !(SE5->E5_TIPO $ MVPAGANT)
			If SEF->(dbSeek(xFilial()+SE5->E5_PREFIXO+SE5->E5_NUMERO+SE5->E5_PARCELA+SE5->E5_TIPO+SUBSTR(SE5->E5_NUMCHEQ,1,TamSX3("EF_NUM")[1])))
				cSeqSe5 := SE5->E5_SEQ

				While SEF->( !Eof()) .and. EF_FILIAL == xFilial() 		.and. ;
				EF_TITULO == SE5->E5_NUMERO	.and. ;
				EF_PARCELA== SE5->E5_PARCELA .and. ;
				EF_PREFIXO== SE5->E5_PREFIXO .and. ;
				EF_TIPO   == SE5->E5_TIPO		.and. ;
				EF_NUM    == SUBSTR(SE5->E5_NUMCHEQ,1,TamSX3("EF_NUM")[1])

					If SEF->EF_SEQUENC == cSeqSe5 .and. SE5->E5_CLIFOR == SEF->EF_FORNECE
						nRecDelSef := SEF->( RecNo() )
						lEstorna := .F.  //achou cheque para esta baixa
						// Permite a baixa se houver cheque cancelado.
						IF SEF->EF_IMPRESS # "C"
							lCheque := .T.
							cNumCheq:= SEF->EF_NUM
							cBenef  := SEF->EF_BENEF
							If cPaisLoc != "BRA" .and. FUNNAME()=="FINA095"
								cRef	:= SEF->EF_NUM
							Else
								cRef	:= SEF->EF_TITULO
							Endif
						Endif
						Exit
					Endif
					SEF->( dbSkip() )
				Enddo
			Endif
		EndIf
		SEF->(dbSetOrder(1))
		SEF->(RestArea(aAreaSEF))
		lContabilizou:= IIf(Alltrim(SE5->E5_LA) == "S", .T., .F.)

		nValPadrao	:= nValPgto-(nJuros+nVA+nMulta+Iif(SE2->E2_MOEDA>1,nCorrec,0)-nDescont)
		nSalDup		:= SE2->E2_SALDO-nValPadrao

		cBanco  := aBaixaSE5[nOpbaixa,11]+aBaixaSE5[nOpBaixa,12]+aBaixaSE5[nOpBaixa,13]

		If (lCheque .and. !Empty(cNumcheq) .AND. !(cPaisloc != "BRA")) .Or. (!Empty(SE2->E2_NUMBCO) .and. !Empty(SEF->EF_IMPRESS) .and. !SE2->E2_TIPO $ MVPAGANT .AND. !(cPaisloc != "BRA"))
			Help(" " , 1 , "FA080TEMCH")
			dbSelectArea("SE2")
			Return
		Endif

		If ( lCheque .And. !GetMv("MV_CTBAIXA") $ "BA" )
			lContabilizou := .F.
		EndIf

		dbSelectArea("SE5")
		dbGoTo(nRecSe5)		//volta para o registro principal

		nI :=  Ascan(aMotBx, {|x| Substr(x,1,3) == Upper(cMotbx) })
		cDescrMo := if( nI > 0,Substr(aMotBx[nI],07,10),"" )

	Endif
	SA2->( dbseek( xFilial("SA2")+SE2->E2_FORNECE+SE2->E2_LOJA))
	dbSelectArea("SE2")
	If !(cPaisloc != "BRA") .or. (cPaisloc != "BRA" .and. FUNNAME()=="FINA095" .and. SEF->EF_STATUS<>"00" )
		RecLock("SE2")
	Endif
	cNomeFor := SE2->E2_FORNECE + " " + SA2->A2_NOME
	cTitulo	:= SE2->E2_PREFIXO + " " + SE2->E2_NUM
	nPagtoParcial := SE2->E2_VALOR-SE2->E2_SALDO
	cTexto	 :=  STR0042 + SubStr(GetMV("MV_SIMB"+cMoeda),1,3)  //"Valor Original "

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Recebe os dados do t¡tulo a ser baixado ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	nOpc1 := 0
	IF SE2->E2_MOEDA > 1
		nLinMais := 13
		nLinBut	 := 7	
	EndIf
	If FUNNAME()=="FINA095"
		If cChStatus=="00"
			DEFINE MSDIALOG oDlg FROM	31,15 TO 256,554 TITLE  STR0067 PIXEL OF oMainWnd //  "CANCELAMENTO DE CHEQUES"
			@ 01, 002 TO 108, 265 LABEL  STR0122 OF oDlg  PIXEL // "Datos del Cheque"
		Else
			If lAnular
				If cPaisLoc == "ARG"
					DEFINE MSDIALOG oDlg FROM	31,15 TO 320+nLinMais,540 TITLE  STR0067 PIXEL OF oMainWnd //  "CANCELAMENTO DE CHEQUES"
					@ 01, 002 TO 125+nLinMais, 263 LABEL  STR0122 OF oDlg  PIXEL // "Datos del Cheque" 
				Else
					DEFINE MSDIALOG oDlg FROM	31,15 TO 290+nLinMais,540 TITLE  STR0067 PIXEL OF oMainWnd //  "CANCELAMENTO DE CHEQUES"
					@ 01, 002 TO 107+nLinMais, 263 LABEL  STR0122 OF oDlg  PIXEL // "Datos del Cheque" 
				EndIf		
			Else
				If cPaisLoc == "ARG"
					If cChStatus $ "01|04"
						DEFINE MSDIALOG oDlg FROM	31,15 TO 420+nLinMais,555 TITLE  STR0123 PIXEL OF oMainWnd //  "SUBSTITUIÇÃO DE CHEQUES"
						@ 01, 002 TO 172+nLinMais, 268 LABEL  STR0122 OF oDlg  PIXEL // "Datos del Cheque"
					Else
						DEFINE MSDIALOG oDlg FROM	31,15 TO 395+nLinBut,555 TITLE  STR0123 PIXEL OF oMainWnd //  "SUBSTITUIÇÃO DE CHEQUES"
						@ 01, 002 TO 155+nLinMais, 267 LABEL  STR0122 OF oDlg  PIXEL // "Datos del Cheque"
					EndIf
				Else
					DEFINE MSDIALOG oDlg FROM	35,15 TO 405+nLinMais,555 TITLE  STR0123 PIXEL OF oMainWnd //  "SUBSTITUIÇÃO DE CHEQUES"					
					@ 01, 002 TO 162+nLinMais, 268 LABEL  STR0122 OF oDlg  PIXEL // "Datos del Cheque"					
				EndIf
			EndIf
		Endif
	Else
		DEFINE MSDIALOG oDlg FROM	31,15 TO 256,554 TITLE  STR0124 PIXEL OF oMainWnd //  "Cancelamento de Baixas a Pagar"
		@ 01, 002 TO 108, 268 LABEL  STR0122 OF oDlg  PIXEL // "Datos del Cheque"
	Endif

	@ 012, 007 SAY  STR0125			SIZE 30,07 OF oDlg PIXEL //"Fornec."
	@ 010, 050 MSGET oNomeFor VAR cNomeFor SIZE 211,9 OF oDlg PIXEL When .F. OBFUSCATED RetGlbLGPD('A2_NOME')
	@ 024, 007 SAY  STR0006			SIZE 40,07 OF oDlg PIXEL //"Banco"
	@ 022, 050 MSGET aBaixaSE5[nOpBaixa,11]	SIZE 22,10 OF oDlg PIXEL When .F.
	@ 037, 007 SAY  STR0007		  	SIZE 39,07 OF oDlg PIXEL //"Agˆncia"
	@ 035, 050 MSGET aBaixaSE5[nOpBaixa,12]	SIZE 35,10 OF oDlg PIXEL When .F.
	@ 050, 007 SAY  STR0008			SIZE 41,07 OF oDlg PIXEL //"Conta"
	@ 048, 050 MSGET aBaixaSE5[nOpBaixa,13]	SIZE 66,10 OF oDlg PIXEL When .F.
	@ 063, 007 SAY  STR0126	  		SIZE 40,07 OF oDlg PIXEL //"Referencia"
	@ 061, 050 MSGET cRef			SIZE 66,10 OF oGrp1 PIXEL When .F.	
	@ 076, 007 SAY  STR0127  		SIZE 53,07 OF oDlg PIXEL //"Valor Original"
	@ 074, 050 MSGET SE2->E2_VALOR  SIZE 66,10 OF oGrp1 PIXEL When .F. Picture PesqPict("SE2","E2_VALOR")
	IF SE2->E2_MOEDA > 1		
		@ 076, 125 SAY  STR0010  + SubStr(GetMV("MV_SIMB"+cMoeda),1,3)    SIZE 53,07 OF oDlg PIXEL //"Valor "
		@ 074, 160 MSGET nValEstrang			SIZE 66,10 OF oDlg PIXEL When .F. Picture PesqPict("SE5","E5_VLMOED2")

		If cPaisLoc <> "CHI"
			@ 089, 007 SAY  STR0128	SIZE 53,07 OF oDlg PIXEL //"+ Corr.Monet ria" 
			@ 087, 050 MSGET nCorrec			SIZE 66,10 OF oDlg PIXEL When .F. Picture PesqPict("SE2","E2_CORREC")
		Else
			@ 089, 007 SAY  STR0129 	SIZE 53,07 OF oDlg PIXEL //"+/- Dif. Cambio"
			@ 087, 050 MSGET nDifCambio		  	SIZE 66,10 OF oDlg PIXEL When .F. Picture PesqPict("SE2","E2_VALOR")
		EndIf
	ENDIF

	If cPaisloc != "BRA" .and. FUNNAME()=="FINA095"
		If cChStatus=="00"
			lCheckNul:=.T.
		Else
			cTipoTalao := FA090TPCH(SEF->(EF_BANCO+EF_AGENCIA+EF_CONTA+EF_TALAO))
			cPrxSub := SEF->EF_PREFIXO
			cChqSub := SEF->EF_NUM
			lCheckNul := lAnular
			lCheckSub := !lAnular
			If cChStatus $ "01|04"  //Só mostra o combo de motivos se o cheque estiver liquidado
				If cPaisLoc == "ARG" 
					If !lAnular
						@ 152+nLinMais,007 SAY STR0068 PIXEL SIZE 80,10 Of oDlg
						@ 149+nLinMais,050 COMBOBOX oCBXMotiv VAR cMotivo ITEMS aMotivos SIZE 150,60 OF oDlg PIXEL ON CHANGE (Eval({||cMotivo:=Substr(aMotivos[oCBXMotiv:nAt],1,2)}))
					Else
						@ 89+nLinMais,007 SAY STR0068 PIXEL SIZE 80,10 Of oDlg 
						@ 87+nLinMais,050 COMBOBOX oCBXMotiv VAR cMotivo ITEMS aMotivos SIZE 150,60 OF oDlg PIXEL ON CHANGE (Eval({||cMotivo:=Substr(aMotivos[oCBXMotiv:nAt],1,2)}))
					EndIf
				Else
					@ Iif(lAnular,89,137)+nLinMais,007 SAY STR0068 PIXEL SIZE 80,10 Of oDlg
					@ Iif(lAnular,87,134)+nLinMais,050 COMBOBOX oCBXMotiv VAR cMotivo ITEMS aMotivos SIZE 150,60 OF oDlg PIXEL ON CHANGE (Eval({||cMotivo:=Substr(aMotivos[oCBXMotiv:nAt],1,2)}))
				EndIf		
				If cPaisLoc == "ARG"
					If lAnular
						nTipoND := aNDs[1,3] // Inicializa posición del combobox
						@105+nLinMais,007 SAY STR0130 PIXEL SIZE 80,10 Of oDlg			//"Docto a generar" 
						@104+nLinMais,050 COMBOBOX oEspecie VAR cEspecie ITEMS aEspecies WHEN cMotivo <> "11" .and. cMotivo <> "15" SIZE 211,60 OF oDlg PIXEL ON CHANGE (nTipoND := aNDs[oEspecie:nAt,3])
					Endif
				Endif
			EndIf
			If !lAnular
				If cPaisLoc == "ARG"
					If cChStatus $ "01|04"
						@ 088+nLinMais,004 GROUP oGrp1 TO 170+nLinMais, 265 LABEL STR0131 OF oDlg  PIXEL //"Dados para Substituição"
					Else
						@ 90+nLinMais,004 GROUP oGrp1 TO 152+nLinMais, 265 LABEL STR0131 OF oDlg  PIXEL //"Dados para Substituição" 
					EndIf
					@ 102+nLinMais,009 SAY STR0006 PIXEL SIZE 80,10 Of oGrp1  //"Banco "
					@ 100+nLinMais,050 MSGET oBcoSub Var cBcoSub	F3 "SA6" Picture PesqPict("SA6","A6_COD")		 	WHEN !lCheckNul Valid If(Empty(cBcoSub),.T.,CarregaSa6(@cBcoSub,@cAgeSub,@cCtaSub,.F.) .and.(ExistCpo("SA6",cBcoSub+cAgeSub+cCtaSub ).Or.Empty(cBcoSub )) .And. F090VLDMOE(aBaixaSE5[nOpBaixa,11]	,aBaixaSE5[nOpBaixa,12],aBaixaSE5[nOpBaixa,13],@cBcoSub,@cAgeSub,@cCtaSub) .And. If(CCBLOCKED(cBcoSub,cAgeSub,cCtaSub),.F.,.T.))  .AND. (FA090VldCH(@cBcoSub,@cAgeSub,@cCtaSub,@cPrxSub,@cChqSub,@nRecChqSub,@lCheckSub,@nRegChSub,cTipoTalao)) SIZE 12,10	PIXEL	HASBUTTON Of oDlg
					@ 100+nLinMais,085 MSGET oAgeSub Var cAgeSub				Picture PesqPict("SA6","A6_AGENCIA")	WHEN !Empty(cBcoSub) Valid CarregaSa6(@cBcoSub,@cAgeSub,@cCtaSub,.F.)	.And. (ExistCpo("SA6",cBcoSub+cAgeSub+cCtaSub ).Or.Empty(cAgeSub )) .And. If(CCBLOCKED(cBcoSub,cAgeSub,cCtaSub),.F.,.T.)	SIZE 20,10	PIXEL Of oDlg
					@ 100+nLinMais,115 MSGET oCtaSub	Var cCtaSub				Picture PesqPict("SA6","A6_CONTA") 		WHEN !Empty(cAgeSub) Valid CarregaSa6(@cBcoSub,@cAgeSub,@cCtaSub,.F.)	.And. (ExistCpo("SA6",cBcoSub+cAgeSub+cCtaSub ).Or.Empty(cCtaSub )) .And. If(CCBLOCKED(cBcoSub,cAgeSub,cCtaSub),.F.,.T.)	SIZE 45,10	PIXEL Of oDlg

					@ 120+nLinMais,009 SAY RetTitle("FRE_TALAO") 	PIXEL SIZE 80,10 Of oDlg //"Cheque"
					@ 117+nLinMais,050 MSGET oTalao VAR cNumTalao F3 "FRE090" PICTURE PesqPict("FRE","FRE_TALAO") SIZE 45,10 PIXEL OF oDlg WHEN .T. VALID f090Talao(@cBcoSub,@cAgeSub,@cCtaSub,@cChqSub,@cPrxSub,@nRegChSub)
					@ 117+nLinMais,100 MSGET oTipTalao VAR cTipTalao PICTURE PesqPict("FRE","FRE_TIPO") SIZE 55,10 PIXEL OF oDlg WHEN .F.

					@ 120+nLinMais,163 SAY STR0069 	PIXEL SIZE 80,10 Of oDlg //"Cheque"
					@ 117+nLinMais,192 MSGET oPrxSub	Var cPrxSub	Picture PesqPict("SEF","EF_PREFIXO") 	WHEN .F. SIZE 20,10	PIXEL Of oDlg
					@ 117+nLinMais,215 MSGET oChqSub	Var cChqSub	Picture PesqPict("SEF","EF_NUM")			WHEN .F. SIZE 45,10	PIXEL Of oDlg

					@ 138+nLinMais,008 SAY STR0071 PIXEL SIZE 40, 10 OF oDlg //"Vencimento:"
					If cTipoTalao == "1"
						dDtVctoSub = Ddatabase
						@ 135+nLinMais,050 MSGET oDtVctoSub Var dDtVctoSub	Picture "99/99/9999" When .F. ;
						SIZE 50, 10 Pixel Hasbutton
					ElseIf  cTipoTalao == "3"
						dDtVctoSub = Ddatabase + 1
						@ 135+nLinMais,050 MSGET oDtVctoSub Var dDtVctoSub	Picture "99/99/9999" When .T. ;
						VALID If(Empty(dDtVctoSub),Eval({||MsgAlert(STR0098, STR0072),.F.}),    If(dDtVctoSub <= dBaixa,    Eval({||MsgAlert(STR0140, STR0072),.F.}),Eval({||DtValVcto(dDtVctoSub),lTipo})));   //"Informe uma data para vencimento do cheque." //"A data de vencimento deve ser maior ou igual a data atual."
						SIZE 50, 10 Pixel Hasbutton
					Else
						@ 135+nLinMais,050 MSGET oDtVctoSub Var dDtVctoSub	Picture "99/99/9999" When .T. ;
						VALID If(Empty(dDtVctoSub),Eval({||MsgAlert(STR0098, STR0072),.F.}),If(dDtVctoSub <= dBaixa,Eval({||MsgAlert(STR0140, STR0072),.F.}),.T.));   //"Informe uma data para vencimento do cheque." //"A data de vencimento deve ser maior ou igual a data atual."
						SIZE 50, 10 Pixel Hasbutton
					EndIf
					@ 136+nLinMais,110 SAY STR0132	PIXEL SIZE 80,20 Of oDlg //"Cheque Anterior" 
					If cChStatus $ "02"
						@ 134+nLinMais, 160 RADIO oRadio VAR nRadio ITEMS STR0133,STR0134 SIZE 100,100 PIXEL OF oDlg   //"Inutilizar","Disponibilizar para Uso"
					Else
						@ 134+nLinMais, 160 RADIO oRadio VAR nRadio ITEMS STR0133 SIZE 100,100 PIXEL OF oDlg//"Inutilizar"
					EndIf
				Else					
					//@ 090+nLinMais,004 GROUP oGrp1 TO 157, 265 LABEL STR0121 OF oDlg  PIXEL //"Dados para Substituição" 
					@ 090+nLinMais,004 GROUP oGrp1 TO 157+nLinMais, 265 LABEL STR0131 OF oDlg  PIXEL //"Dados para Substituição" 
					@ 102+nLinMais,009 SAY STR0006 PIXEL SIZE 80,10 Of oGrp1  //"Banco "
					@ 102+nLinMais,050 MSGET oBcoSub Var cBcoSub	F3 "SA6" Picture PesqPict("SA6","A6_COD")		 	WHEN !lCheckNul Valid If(Empty(cBcoSub),.T.,CarregaSa6(@cBcoSub,@cAgeSub,@cCtaSub,.F.) 	.And.	(ExistCpo("SA6",cBcoSub+cAgeSub+cCtaSub ).Or.Empty(cBcoSub )) .And. If(CCBLOCKED(cBcoSub,cAgeSub,cCtaSub),.F.,.T.))  .AND. (FA090VldCH(@cBcoSub,@cAgeSub,@cCtaSub,@cPrxSub,@cChqSub,@nRecChqSub,@lCheckSub,@nRegChSub,cTipoTalao)) SIZE 12,10	PIXEL	HASBUTTON Of oDlg
					@ 102+nLinMais,085 MSGET oAgeSub Var cAgeSub				Picture PesqPict("SA6","A6_AGENCIA")	WHEN !Empty(cBcoSub) Valid CarregaSa6(@cBcoSub,@cAgeSub,@cCtaSub,.F.)	.And. (ExistCpo("SA6",cBcoSub+cAgeSub+cCtaSub ).Or.Empty(cAgeSub )) .And. If(CCBLOCKED(cBcoSub,cAgeSub,cCtaSub),.F.,.T.)	SIZE 20,10	PIXEL Of oDlg
					@ 102+nLinMais,115 MSGET oCtaSub	Var cCtaSub				Picture PesqPict("SA6","A6_CONTA") 		WHEN !Empty(cAgeSub) Valid CarregaSa6(@cBcoSub,@cAgeSub,@cCtaSub,.F.)	.And. (ExistCpo("SA6",cBcoSub+cAgeSub+cCtaSub ).Or.Empty(cCtaSub )) .And. If(CCBLOCKED(cBcoSub,cAgeSub,cCtaSub),.F.,.T.)	SIZE 45,10	PIXEL Of oDlg
					@ 104+nLinMais,163 SAY STR0069 	PIXEL SIZE 80,10 Of oDlg //"Cheque"
					@ 102+nLinMais,192 MSGET oPrxSub	Var cPrxSub	Picture PesqPict("SEF","EF_PREFIXO") 	WHEN .F. SIZE 20,10	PIXEL Of oDlg
					@ 102+nLinMais,215 MSGET oChqSub	Var cChqSub	Picture PesqPict("SEF","EF_NUM")			WHEN .F. SIZE 45,10	PIXEL Of oDlg
					@ 122+nLinMais,008 SAY STR0071 PIXEL SIZE 40, 10 OF oDlg //"Vencimento:"
					@ 119+nLinMais,050 MSGET oDtVctoSub Var dDtVctoSub	Picture "99/99/9999" When !lCheckNul .and. !Empty(cBcoSub) ;
					VALID If(Empty(dDtVctoSub),Eval({||MsgAlert(STR0098, STR0072),.F.}),If(dDtVctoSub < dDataBase,Eval({||MsgAlert(STR0099, STR0072),.F.}),.T.));   //"Informe uma data para vencimento do cheque." //"A data de vencimento deve ser maior ou igual a data atual."
					SIZE 45, 10 Pixel Hasbutton
					@ 122+nLinMais,110 SAY STR0132	PIXEL SIZE 80,20 Of oDlg //"Cheque Anterior"
					If cChStatus$ "02"
						@ 122+nLinMais, 160 RADIO oRadio VAR nRadio ITEMS STR0133,STR0134 SIZE 100,100 PIXEL OF oDlg   //"Inutilizar","Disponibilizar para Uso"
					Else
						@ 120+nLinMais, 160 RADIO oRadio VAR nRadio ITEMS STR0133 SIZE 100,100 PIXEL OF oDlg//"Inutilizar"
					EndIf
				EndIf
			EndIf
		Endif
		If cChStatus<>"00"
			If oCBXMotiv != Nil
				If cPaisLoc == "ARG"
					If !lAnular .And. cChStatus $ "01|04"
						DEFINE SBUTTON FROM 180+nLinBut, 200 TYPE 1 ENABLE OF oDlg ACTION ( nOpc1 := 1,Eval({||oCBXMotiv:Refresh(),cChvLbx:= Substr(aMotivos[oCBXMotiv:nAt],1,2), nChvLbx:=oCBXMotiv:nAt}),oDlg:End())
					Else
						DEFINE SBUTTON FROM IIf(!lAnular,167,127+nLinMais), 200 TYPE 1 ENABLE OF oDlg ACTION ( nOpc1 := 1,Eval({||oCBXMotiv:Refresh(),cChvLbx:= Substr(aMotivos[oCBXMotiv:nAt],1,2), nChvLbx:=oCBXMotiv:nAt}),oDlg:End()) 
					EndIf
				Else
					DEFINE SBUTTON FROM IIf(!lAnular,169+nLinBut,109+nLinMais) , 202 TYPE 1 ENABLE OF oDlg ACTION ( nOpc1 := 1,Eval({||oCBXMotiv:Refresh(),cChvLbx:= Substr(aMotivos[oCBXMotiv:nAt],1,2), nChvLbx:=oCBXMotiv:nAt}),If(FA090VldMt(nRegChOri),oDlg:End(),nOpc1 := 0) )
				Endif
			Else
				If cPaisLoc == "ARG"
					DEFINE SBUTTON FROM IIf(!lAnular,165+nLinBut,127+nLinMais) , 200 TYPE 1 ENABLE OF oDlg  ACTION ( nOpc1 := 1,If(FA090VldMt(nRegChOri,lAnular),oDlg:End(),nOpc1 := 0) ) 
				Else
					DEFINE SBUTTON FROM IIf(!lAnular,169+nLinBut,109+nLinMais) , 200 TYPE 1 ENABLE OF oDlg  ACTION ( nOpc1 := 1,If(FA090VldMt(nRegChOri,lAnular),oDlg:End(),nOpc1 := 0) ) 
				EndIf	
			EndIf
			If cPaisLoc == "ARG"
				If !lAnular .And. cChStatus $ "01|04"
					DEFINE SBUTTON FROM 180+nLinBut, 240 TYPE 2 ENABLE OF oDlg ACTION oDlg:End()
				Else
					DEFINE SBUTTON FROM IIf(!lAnular,165+nLinBut,127+nLinMais), IIf(!lAnular,240,235) TYPE 2 ENABLE OF oDlg ACTION oDlg:End() 
				EndIf
			Else
				DEFINE SBUTTON FROM IIf(!lAnular,169+nLinBut,109+nLinMais), IIf(!lAnular,240,235) TYPE 2 ENABLE OF oDlg ACTION oDlg:End()
			Endif
			If !lAutomato
			   ACTIVATE MSDIALOG oDlg CENTERED ON INIT (FA090IniOb(cChStatus))
			Else
				If FindFunction("GetParAuto")
						aRetAuto 		:= GetParAuto("FINA095TESTCASE")
						cBcoSub 		:= aRetAuto[1]
			            cAgeSub 		:= aRetAuto[2]
		            	cCtASub 		:= aRetAuto[3]
						cPrxSub	    	:= aRetAuto[4]
						cChqSub     	:= aRetAuto[5]
						cNumTalao     	:= aRetAuto[6]
				Endif
				If (SEF->(DbSeek(xFilial("SEF") + cBcoSub + cAgeSub + cCtASub + cChqSub)))
				nRegChSub	:=	SEF->(Recno())
				Endif
				nOpc1 := 1
			Endif
		Else
			DEFINE SBUTTON FROM 54, 230 TYPE 1 ENABLE OF oDlg ACTION ( nOpc1 := 1,oDlg:End() )
			DEFINE SBUTTON FROM 68, 230 TYPE 2 ENABLE OF oDlg ACTION oDlg:End()
			If !lAutomato
				ACTIVATE MSDIALOG oDlg CENTERED
			Else
				If FindFunction("GetParAuto")
						aRetAuto 		:= GetParAuto("FINA095TESTCASE")
						cBcoSub 		:= aRetAuto[1]
			            cAgeSub 		:= aRetAuto[2]
		            	cCtASub 		:= aRetAuto[3]
						cChqSub     	:= aRetAuto[4]
				Endif
				If (SEF->(DbSeek(xFilial("SEF") + cBcoSub + cAgeSub + cCtASub + cChqSub)))
				nRegChSub	:=	SEF->(Recno())
				Endif
				nOpc1 := 1
			Endif
		Endif
	Else
		DEFINE SBUTTON FROM 54, 230 TYPE 1 ENABLE OF oDlg ACTION ( nOpc1 := 1,oDlg:End() )
		DEFINE SBUTTON FROM 68, 230 TYPE 2 ENABLE OF oDlg ACTION oDlg:End()

		ACTIVATE MSDIALOG oDlg CENTERED
	Endif

	MsUnlock("SE2")

	//PONTO DE ENTRADA P/ PERMISSAO DE CANCELAMENTO DE BAIXA DE TITULO
	If lFa080Own
		lRet :=	ExecBlock('FA080OWN',.F.,.F.)
	Endif

	If !lRet
		Return
	EndIf

	IF nOpc1 == 1

		If (cPaisloc != "BRA" .and. FUNNAME() == "FINA095")
			If lCheckSub  .And. (Empty(cBcoSub) .Or. Empty(cChqSub) .Or. Empty(cAgeSub) .Or. Empty(cCtASub))
				MsgAlert(STR0124) // "O Cheque não será substituido, pois não foi selecionado o banco e conta para o cheque substituto."
				lRet := .F.
			ElseIf !(cChStatus $ "01|04")  .And. !lCheckSub  .And.  !lCheckNul
				MsgAlert(STR0131) // "Informe o que deve ser feito com o cheque anterior selecionando a opção correspondente."
				lRet := .F.
			ElseIf cPaisLoc == "ARG"
				If Empty(cNumTalao) .AND. !lAnular
					MsgAlert(STR0141) // "O Cheque não será substituido, pois não foi selecionado o banco e conta para o cheque substituto."
					lRet := .F.
				EndIf
			EndIf
			If !lRet
				Return
			EndIf
		EndIf

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Inicio da protecao via TTS	³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		nOrdSa6 := SA6->(INDEXORD())
		nRecSa6 := SA6->(RECNO())
		Begin Transaction
			SED->( dbSeek(cFilial+SE2->E2_NATUREZ))
			SA6->( DbSetOrder(1) )
			SA6->( DbSeek(xFilial("SA6")+SE5->(E5_BANCO+E5_AGENCIA+E5_CONTA) ) )

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Apaga Titulo de Vendor Gerado  ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			lBaixaOk := .T.
			IF (!lNoE2bx .and. !lCheckNul) .AND. TrazCodMot(cMotBx) == "VEN"
				dbSelectArea("SE2")
				cTitOriV := SE2->E2_TITORIG
				If dbSeek(cFilial+SE2->E2_TITORIG)
					If SE2->E2_SALDO == SE2->E2_VALOR
						Reclock("SE2",.F.,.T.)
						dbDelete()
					Else
						Help(" ",1,"BXVENDOR",,Subs(cTitOriV,1,3)+" "+Subs(cTitOriV,4,6)+;
						" "+Subs(cTitOriV,10,1)+" "+Subs(cTitOriV,11,3),5,1)
						lBaixaOk := .F.
					Endif
				Endif
				If lBaixaOk
					dbGoto(nReg)
					RecLock("SE2",.F.)
					Replace SE2->E2_TITORIG With TamSx3("E2_TITORIG")[1]
				Endif
			Endif

			If lBaixaOk
				If !(cPaisLoc $ "ARG|DOM|EQU") .or. (cPaisLoc $ "ARG|DOM|EQU" .and. FUNNAME()=="FINA095" .and. !lNoE2bx ) .or.;
			    (cPaisLoc $ "ARG|DOM|EQU" .and. FUNNAME()<>"FINA095")

					If (cPaisLoc <> "ARG") .or. (cPaisLoc == "ARG" .and. FUNNAME() <> "FINA095") .or. (cPaisLoc == "ARG" .and. FUNNAME() == "FINA095" .and. cChvLbx == "11" .OR. cChvLbx == "15")
						//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
						//³Gravar valores no SE2 ³
						//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
						Reclock("SE2")
						SE2->E2_VALLIQ := nValPgto
						If cPaisloc <> "CHI"
							SE2->E2_JUROS	:= nJuros
							SE2->E2_CORREC	:= nCorrec
						Else
							SE2->E2_JUROS	:= nOtrga + nImpsubst
							SE2->E2_CORREC	:= nDifCambio
							SE2->E2_OTRGA	:= nOtrga
							SE2->E2_CAMBIO	:= nDifCambio
							SE2->E2_IMPSUBS	:= nImpSubst
						EndIf
						SE2->E2_MULTA	:= nMulta
						SE2->E2_DESCONT	:= nDescont
					EndIf
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³Gera lancamento contabil de estorno ³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					cPadrao		:= "531"    //cancelamento de baixa
					lPadraoBx	:= (VerPadrao(cPadrao) .and. lContabilizou)
					nRegB		:= SE2->( Recno() )

					dbSelectArea("SE2")
					If SE2->( dbSeek(cFilial+SE2->E2_TITORIG) )
						lVend := .T.
						nRegV := SE2->( Recno() )
					Endif
					lPadraoVd := VerPadrao("519") //cancelamento de baixa vendor
					dbSelectArea( "SE2" )
					dbGoto(nRegB)

					If lVend
						lPadraoBx := VerPadrao( "531" ) //cancelamento
					Endif

					ABATIMENTO := nTotAbat

					IF (lPadraoBx .or. lPadraoVd ) .and. lContabilizou
						//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
						//³ Inicializa Lancamento Contabil                                   ³
						//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
						nHdlPrv := HeadProva( cLote,;
						"FINA090" /*cPrograma*/,;
						Substr( cUsuario, 7, 6 ),;
						@cArquivo )
					Endif
					IF lPadraoBx .and. lContabilizou
						//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
						//³ Prepara Lancamento Contabil                                      ³
						//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
						If lUsaFlag  // Armazena em aFlagCTB para atualizar no modulo Contabil
							aAdd( aFlagCTB, {"E2_LA", "S", "SE2", SE2->( Recno() ), 0, 0, 0} )
						Endif
						nTotal += DetProva( nHdlPrv,;
						cPadrao,;
						"FINA090" /*cPrograma*/,;
						cLote,;
						/*nLinha*/,;
						/*lExecuta*/,;
						/*cCriterio*/,;
						/*lRateio*/,;
						/*cChaveBusca*/,;
						/*aCT5*/,;
						/*lPosiciona*/,;
						@aFlagCTB,;
						/*aTabRecOri*/,;
						/*aDadosProva*/ )
					Endif
					IF lPadraoVd .and. lContabilizou
						IF lVend
							dbSelectArea( "SE2" )
							SE2->( dbGoto(nRegV) )
							//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
							//³ Prepara Lancamento Contabil                                      ³
							//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
							If lUsaFlag  // Armazena em aFlagCTB para atualizar no modulo Contabil
								aAdd( aFlagCTB, {"E2_LA", "S", "SE2", SE2->( Recno() ), 0, 0, 0} )
							Endif
							nTotal += DetProva( nHdlPrv,;
							"519" /*cPadrao*/,;
							"FINA090" /*cPrograma*/,;
							cLote,;
							/*nLinha*/,;
							/*lExecuta*/,;
							/*cCriterio*/,;
							/*lRateio*/,;
							/*cChaveBusca*/,;
							/*aCT5*/,;
							/*lPosiciona*/,;
							@aFlagCTB,;
							/*aTabRecOri*/,;
							/*aDadosProva*/ )
						Endif
					Endif

					SE2->( dbGoto(nRegB) )
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³Volta titulo para carteira ³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					Reclock("SE2")
					nTotAbat := IIf(SE2->E2_SALDO != 0, 0, NoRound((nTotAbat * nTxMoeda), 3))
					dDataAnt := IIf(nOpBaixa == Len(aBaixa), IIf(Len(aBaixa) == 1, CtoD(""), aBaixaSE5[Len(aBaixa) - 1]), E2_BAIXA)

					IF SE2->E2_MOEDA == 1
						nValor := SE2->E2_SALDO + (nValPgto - nJuros - nVA - nMulta + nDescont + nTotAbat)
					Else
						nValor := SE2->E2_SALDO + ((nValPgto - nJuros - nCorrec - nMulta + nDescont + nTotAbat) / NoRound(nTxMoeda, 5))
					Endif

					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³Volta valor original do titulo se cancelamento final das baixas ³
					//³ e n„o houverem compensa‡oes.                                   ³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					If Len(aBaixa) == 1 .and. nTotAdto == 0 .and. !SE2->E2_TIPO $ MVPAGANT + "/" + MV_CPNEG
						nValor := SE2->E2_VALOR
					EndIf

					If FUNNAME() <> "FINA095" .Or. ((FUNNAME() == "FINA095" .and. cChvLbx == "11" .OR. cChvLbx == "15") .Or. lAnular)
						SE2->E2_SALDO	:= IIf( nValor < 0 , 0 , nValor )
						SE2->E2_BAIXA	:= IIf( Str(E2_SALDO, 17, 2) == Str(E2_VALOR, 17, 2), CtoD(""), E2_BAIXA )
						SE2->E2_DESCONT	:= 0
						SE2->E2_MULTA	:= 0
						SE2->E2_JUROS	:= 0
						SE2->E2_CORREC	:= 0
						SE2->E2_VALLIQ	:= 0
						SE2->E2_LOTE 	:= Space(Len(SE2->E2_LOTE))
						SE2->E2_IMPCHEQ	:= ""
						SE2->E2_BCOPAG	:= ""
						SE2->E2_MOVIMEN	:= IIf(Str(E2_SALDO, 17, 2) == Str(E2_VALOR, 17, 2), CtoD(""), E2_BAIXA )
						If cPaisLoc == "BRA"
							SE2->E2_NUMBCO := Space(Len(SE2->E2_NUMBCO))
						Else
							If Upper(Left(SE2->E2_NUMBCO,5)) != "CJCC_"  .and. (!(cPaisLoc $ "ARG|DOM|EQU") .or. cPaisLoc $ "ARG|DOM|EQU" .and. FUNNAME()<>"FINA095").and.!SE2->E2_ORIGEM$"FINA085A|FINA850"
								SE2->E2_NUMBCO	:=	Space(Len(SE2->E2_NUMBCO))
							Endif
						Endif
						If cPaisLoc == "CHI"
							SE2->E2_OTRGA	:= 0
							SE2->E2_CAMBIO	:= 0
							SE2->E2_IMPSUBS	:= 0
							SE2->E2_TXMOEDA	:= 0
						EndIf
					Endif
					/*
					* Atualização dos saldos do fluxo de caixa por natureza financeira
					*/
					// Atualiza o saldo da natureza. O valor jah esth liquido dos abatimentos, desta forma nao precisa atualizar na baixa dos abatimentos
					AtuSldNat(SE2->E2_NATUREZ, SE2->E2_BAIXA, SE2->E2_MOEDA, "3", "P", nValor, xMoeda(nValor,SE2->E2_MOEDA,1,SE2->E2_BAIXA,,,If(cPaisLoc=="BRA",SE2->E2_TXMOEDA,0)), If(SE2->E2_TIPO $ MVPAGANT+"/"+MV_CPNEG,"+","-"),,FunName(),"SE2",SE2->(Recno()),0)
					//Caso exista solicitacao de NCP eh necessario atualizar o campo CU_DTBAIXA...
					If cPaisLoc <> "BRA"
						A055AtuDtBx("2",SE2->E2_FORNECE,SE2->E2_LOJA,SE2->E2_NUM,SE2->E2_PREFIXO,SE2->E2_BAIXA)
						If Upper(Left(SE2->E2_NUMBCO,5))=="CJCC_" .and. (!(cPaisloc != "BRA") .or. cPaisloc != "BRA" .and. FUNNAME()<>"FINA095")
							Fa550CJCC(Substr(SE2->E2_NUMBCO,6),"C")
						Endif
					EndIf

					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³Verifica se h  abatimentos para voltar a carteira ³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					If SE2->(dbSeek(cFilial+SE2->E2_PREFIXO+SE2->E2_NUM+SE2->E2_PARCELA))
						cTitAnt := (SE2->E2_FILIAL+SE2->E2_PREFIXO+SE2->E2_NUM+SE2->E2_PARCELA)
						While !SE2->(Eof()) .and. cTitAnt == (SE2->E2_FILIAL+SE2->E2_PREFIXO+SE2->E2_NUM+SE2->E2_PARCELA)
							IF !SE2->E2_TIPO $ MVABATIM
								SE2->(dbSkip())
								Loop
							EndIF
							IF SE2->E2_FORNECE+SE2->E2_LOJA != cFornece+cLoja
								SE2->(dbSkip())
								Loop
							EndIF
							//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
							//³Volta titulo para carteira³
							//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
							Reclock("SE2")
							SE2->E2_BAIXA	:= dDataAnt
							SE2->E2_SALDO	:= E2_VALOR
							SE2->E2_DESCONT	:= 0
							SE2->E2_JUROS	:= 0
							SE2->E2_MULTA	:= 0
							SE2->E2_CORREC	:= 0
							SE2->E2_VARURV	:= 0
							SE2->E2_LOTE	:= Space(Len(E2_LOTE))
							SE2->E2_VALLIQ	:= 0
							SE2->E2_NUMBCO	:= Space(Len(SE2->E2_NUMBCO))
							If cPaisLoc == "CHI"
								SE2->E2_OTRGA := 0
								SE2->E2_CAMBIO := 0
								SE2->E2_IMPSUBS := 0
								SE2->E2_TXMOEDA := 0
							EndIf
							SE2->(dbSkip())
						Enddo
					Endif

					SE2->( dbGoTo( nSalvRec ) )

					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³ PONTOS DE ENTRADA  ³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					If ExistTemplate("FA080CAN")
						ExecTemplate('FA080CAN',.F.,.F.)
					Endif

					If ExistBlock("FA080CAN")
						ExecBlock('FA080CAN',.F.,.F.)
					Endif

					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³LOCALiza na movimenta‡„o banc ria, os registros referentes a baixa³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					dbSelectArea("SE5")
					dbSetOrder(2)

					aAux := { "VL","CM","CX","DC","MT","JR","BA"}
					IIf(cPaisloc == "CHI",AADD(aAux,"IS"),.T.)

					For nI := 1 to len(aAux)
						If SE5->( MsSeek(xFilial("SE5")+aAux[ni]+cChave))
							cBanco		:= SE5->E5_BANCO
							cAgencia	:= SE5->E5_AGENCIA
							cConta		:= SE5->E5_CONTA
							cTitulo		:= SE5->E5_NUMERO
							cCheque		:= SE5->E5_NUMCHEQ
							cFilOr		:= SE5->E5_FILORIG
							cMoeda		:= SE5->E5_MOEDA
							cTxMoeda	:= SE5->E5_TXMOEDA

							If nOpcx == 6 .OR. (cPaisLoc<>"BRA" .And. (GetNewPar("MV_ESTCHOP","N") == "S" ))

								If SE5->E5_TIPODOC $ "VL|BA"

									//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
									//³Cancela as baixas gerando um lancamento de estorno no SE5         ³
									//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
									If !Empty( cLotefin ) // baixa por lote
										cHistCan091 :=  STR0135+" "+cLotefin // Canc. Baixa Lote
									Else
										cHistCan091 :=  STR0136 //"Cancelamento de baixa"
									EndIf

									If aAux[nI] $ "VL"
										//Reestruturacao SE5
										nOperFK2 := 2	//Altera E5_TIPODOC da SE5 para 'ES' e gera estorno na FK5
									Else
										//Reestruturacao SE5
										nOperFK2 := 1	//Altera E5_SITUACA da SE5 para 'C' e gera estorno na FK5
									EndIf

									//Posiciona a FK5 para mandar a operação de alteração com base no registro posicionado da SE5
									aAreaAnt := GetArea()
									oModelBx  := FWLoadModel("FINM020")
									oModelBx:SetOperation(MODEL_OPERATION_UPDATE) //Alteração
									oModelBx:Activate()
									oModelBx:SetValue( "MASTER", "E5_GRV", .T. ) //Habilita gravação SE5
									oSubFKA := oModelBx:GetModel( "FKADETAIL" )
									oSubFKA:SeekLine( { {"FKA_IDORIG", SE5->E5_IDORIG } } )

									//E5_OPERACAO 1 = Altera E5_SITUACA da SE5 para 'C' e gera estorno na FK5
									//E5_OPERACAO 2 = Altera E5_TIPODOC da SE5 para 'ES' e gera estorno na FK5
									//E5_OPERACAO 3 = Deleta da SE5 e gera estorno na FK5
									oModelBx:SetValue( "MASTER", "E5_OPERACAO", nOperFK2 )
									oModelBx:SetValue( "MASTER", "E5_LA", IIF(lContabilizou,"S","N") )
									oModelBx:SetValue( "MASTER", "HISTMOV"    , cHistCan091 )
									
									//Para registros tipo 'VL' se crea registro en FK5
									If aAux[nI] $ "VL"
										oSubFK5 := oModelBx:GetModel( "FK5DETAIL" )
										oSubFKA:AddLine()
										oSubFKA:GoLine(oSubFKA:Length())
										oSubFKA:SetValue( "FKA_IDORIG", FWUUIDV4() )
										oSubFKA:SetValue( "FKA_TABORI", "FK5" )
										oSubFKA:SetValue( "FKA_IDFKA" , FWUUIDV4() )
									EndIf

									If oModelBx:VldData()
										oModelBx:CommitData()
										If !(cPaisLoc == "BOL" .and. IsInCallStack("FINA090")) .AND. !(cPaisLoc=="ARG".AND.cChvLbx=="11".AND.FunName()=="FINA095")
											oModelMov := FWLoadModel("FINM030")
											oModelMov:Activate()
											nRecSE5 := oModelMov:GetValue("MASTER","E5_RECNO")
											SE5->(dbGoTo(nRecSE5))
											oModelMov:DeActivate()
											oModelMov:Destroy()
											oModelMov := Nil
										EndIf
									Else
										lRet := .F.
										cLog := cValToChar(oModelBx:GetErrorMessage()[4]) + ' - '
										cLog += cValToChar(oModelBx:GetErrorMessage()[5]) + ' - '
										cLog += cValToChar(oModelBx:GetErrorMessage()[6])
										Help( ,,"M020VLDE1",,cLog, 1, 0 )
									Endif

									oModelBx:DeActivate()
									oModelBx:Destroy()
									oModelBx := Nil
									RestArea(aAreaAnt)

									//Agroindustria
									If FindFunction("OGXUtlOrig") //Encontra a função
										If OGXUtlOrig()
											If FindFunction("OGX105")
												OGX105()
											Endif
										EndIf
									EndIf
									//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
									//³ PONTO DE ENTRADA F080EST                            ³
									//³ PE para grava‡oes complementares do cancelamento    ³
									//³ da baixa                                            ³
									//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
									IF nOperFK2 == 2 .and. lF080EST
										ExecBlock("F080EST",.F.,.F.)
									Endif

								Else
									//Cancelo os registros de valores acessoriso (Multas, Juros etc)
									RecLock("SE5")
									SE5->E5_SITUACA := "C"
									MsUnLock()
								Endif
							Else
								If SE5->E5_TIPODOC $ "VL|BA"

									aAreaAnt := GetArea()
									oModelBx  := FWLoadModel("FINM020")
									oModelBx:SetOperation(MODEL_OPERATION_UPDATE) //Alteração
									If cPaisLoc$"ARG|BOL|CHI|PAR|URU"
										oModelBx:GetModel( 'FKADETAIL' ):SetLoadFilter(," FKA_IDPROC !='' ")
									EndIf
									oModelBx:Activate()
									oModelBx:SetValue( "MASTER", "E5_GRV", .T. ) //Habilita gravação SE5
									oSubFKA := oModelBx:GetModel( "FKADETAIL" )
									oSubFKA:SeekLine( { {"FKA_IDORIG", SE5->E5_IDORIG } } )

									//E5_OPERACAO 1 = Altera E5_SITUACA da SE5 para 'C' e gera estorno na FK5
									//E5_OPERACAO 2 = Altera E5_TIPODOC da SE5 para 'ES' e gera estorno na FK5
									//E5_OPERACAO 3 = Deleta da SE5 e gera estorno na FK5
									oModelBx:SetValue( "MASTER", "E5_OPERACAO", 3 )

									If oModelBx:VldData()
										oModelBx:CommitData()

									Else
										lRet := .F.
										cLog := cValToChar(oModelBx:GetErrorMessage()[4]) + ' - '
										cLog += cValToChar(oModelBx:GetErrorMessage()[5]) + ' - '
										cLog += cValToChar(oModelBx:GetErrorMessage()[6])
										Help( ,,"M020VLDE3",,cLog, 1, 0 )

									Endif
									oModelBx:DeActivate()
									oModelBx:Destroy()
									oModelBx := Nil
									RestArea(aAreaAnt)
								Else
									//Cancelo os registros de valores acessoriso (Multas, Juros etc)
									RecLock("SE5")
									dbDelete()
									MsUnLock()
								Endif
							EndIf
						Endif
					Next

					dbSetOrder(1)
					dbGoTo(nRecSe5)		//volta para o registro principal

					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³ Deleta Cheque gerado pela baixa	³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					nRecNo := 0
					nValor := 0
					If !(cPaisloc != "BRA")
						dbSelectArea("SEF")
						If nRecDelSef > 0
							dbGoto( nRecDelSef )
							If SEF->EF_IMPRESS != "C"
								nValor := SEF->EF_VALOR
							Endif
						Endif
						dbSetOrder(1)
						nRecNo := 0
						nValor := 0

						//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
						//³ Atualiza o totalizador  ³
						//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
						If SubStr(cCheque,1,1) = "*" .And. nRecNo != 0
							dbGoTo( nRecNo )
							Reclock("SEF")
							SEF->EF_VALOR -= nValor
							IF SEF->EF_VALOR == 0
								If cPaisloc != "BRA"	//Não apagar o Cheque, anular com o codigo de Status
									Reclock("SEF",.F.,.T.)
									EF_STATUS := "06"	//Anulado pela Ordem de Pago
									MsUnLock()
								Else
									Reclock("SEF",.F.,.T.)
									SEF->(dbDelete())
									MsUnlock()
								EndIf
							Endif
						Endif
					Endif

					If lAtuForn
						//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
						//³ Atualiza o Cadastro de Fornecedores ³
						//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
						dbSelectArea("SA2")
						If !Eof()
							RecLock( "SA2" )
							SA2->A2_SALDUP		:= A2_SALDUP + nValPadrao
							SA2->A2_SALDUPM	+= xMoeda(nValPadrao,1,Val(GetMv("MV_MCUSTO")),SE2->E2_EMISSAO)

							nAtraso:=dBaixa-SE2->E2_VENCTO
							If nAtraso > 1
								IF Dow(SE2->E2_VENCTO) == 1 .Or. Dow(SE2->E2_VENCTO) == 7
									IF Dow(dBaixa) == 2 .and. nAtraso <= 2
										nAtraso := 0
									EndIF
								EndIF
								nAtraso:=IIF(nAtraso<0,0,nAtraso)
								If SA2->A2_MATR < nAtraso
									Replace A2_MATR With nAtraso
								EndIf
							Endif
						Endif
					Endif

					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³	Atualiza saldos banc rios.                                       ³
					//³	No cancelamento de baixa de adiantamento, o saldo do caixa/banco ³
					//³	deve diminuir, pois o capital saiu do caixa e voltou a quem      ³
					//³	solicitou o PA.                                                  ³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					dbSelectArea("SE2")
					SE2->( dbGoto(nReg) )

					If lAtuSldBco
						IF SE2->E2_TIPO $ MVPAGANT
							AtuSalBco(aBaixaSE5[nOpBaixa,11],aBaixaSE5[nOpBaixa,12],aBaixaSE5[nOpBaixa,13],dDataBase,nValPgto,"-")
						Endif
					EndIf
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³	Caixa ou Bordero sem Cheque ou Debto.CC                           ³
					//³	Quando for Debito em C.Corrente tem que estornar o saldo Bancario ³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³ Verifica o modulo para definir o tratamento do Caixa ³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					If (lEstorna .and. MovBcoBx(cMotBx, .T.) .and. SE5->E5_TIPODOC <>"BA") .or. TrazCodMot(cMotBx) $ "DEB" .or. ;
						Left(aBaixaSE5[nOpBaixa,11],TamSX3("A6_COD")[1]) == Left(GetMv("MV_CXFIN"),TamSX3("A6_COD")[1]) .or. aBaixaSE5[nOpBaixa,11] $ GetMv("MV_CARTEIR")
						If lAtuSldBco
							AtuSalBco(aBaixaSE5[nOpBaixa,11],aBaixaSE5[nOpBaixa,12],aBaixaSE5[nOpBaixa,13],dDataBase,nValPgto,"+")
						EndIf
						If lPadraoVd .and. lContabilizou
							If FinProcITF( SE5->( Recno() ),1 )
								FinProcITF( SE5->( Recno() ),5,, .F.,{nHdlPrv,cPadrao,"FINA090","FINA090",cLoteFin} ,  )
							EndIf
						Else
							If FinProcITF( SE5->( Recno() ),1 )
								FinProcITF( SE5->( Recno() ),5,, .F.,{} ,  )
							EndIf
						EndIf
					ElseIf cPaisLoc	<>	"BRA" .And. SE5->E5_TIPODOC=="VL"
						If lAtuSldBco
							AtuSalBco(SE5->E5_BANCO,SE5->E5_AGENCIA,SE5->E5_CONTA,SE5->E5_DATA,SE5->E5_VALOR,"+")
						EndIf
						If (lPadraoVd .and. lContabilizou) .OR. Iif(cPaisLoc == "BOL" .and. IsInCallStack("FINA090"), Iif(lPadraoBx .and. lContabilizou,.T.,.F.),.F.)
							If FinProcITF( SE5->( Recno() ),1 )
								FinProcITF( SE5->( Recno() ),5,, .F.,{nHdlPrv,cPadrao,"FINA090","FINA090",cLotefin} ,  )
							EndIf
						Else
							If FinProcITF( SE5->( Recno() ),1 )
								FinProcITF( SE5->( Recno() ),5,, .F.,{} ,  )
							EndIf

						EndIf
					EndIf

					If GetMv("MV_CANBORP") == "S"
						//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
						//³ Apaga registro do titulo no SEA retirando-o do bordero		 	 ³
						//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
						If !Empty(SE2->E2_NUMBOR)
							dbSelectArea("SEA")
							If dbseek(xFilial()+SE2->(E2_NUMBOR+E2_PREFIXO+E2_NUM+E2_PARCELA+E2_TIPO+E2_FORNECE+E2_LOJA))
								While !Eof() .and. SEA->(EA_NUMBOR+EA_PREFIXO+EA_NUM+EA_PARCELA+EA_TIPO+EA_FORNECE+EA_LOJA) == ;
								SE2->(E2_NUMBOR+E2_PREFIXO+E2_NUM+E2_PARCELA+E2_TIPO+E2_FORNECE+E2_LOJA)
									If SEA->EA_CART == "P"
										Reclock("SEA",.F.,.T.)
										dbDelete()
										Exit
									Endif
									DbSkip()
								Enddo
							Endif
						Endif
						RecLock("SE2",.F.)
						SE2->E2_NUMBOR := Space(Len(SE2->E2_NUMBOR))
					Endif
					// Gera lançamento contábil de estorno
					IF (lPadraoBx .Or. lPadraoVd) .and. lContabilizou
						//----------------------------------------
						// Efetiva Lançamento Contabil
						//----------------------------------------
						lDigita := If( mv_par01 == 1, .T., .F. )
						cA100Incl( cArquivo,;
						nHdlPrv,;
						3 /*nOpcx*/,;
						cLote,;
						lDigita,;
						.F. /*lAglut*/,;
						/*cOnLine*/,;
						/*dData*/,;
						/*dReproc*/,;
						@aFlagCTB,;
						/*aDadosProva*/,;
						/*aDiario*/ )
						aFlagCTB := {}  // Limpa o coteudo apos a efetivacao do lancamento
					Endif
				Endif
				If cPaisLoc $ "ARG|DOM|EQU" .and. FUNNAME()=="FINA095"
					cPrefCh:= SEF->EF_PREFIXO
				   	cParcCh:= SEF->EF_PARCELA
				   	dVenctoCh:=dDtVctoSub
					cBancoSEF:=SEF->EF_BANCO
					cAgencSEF:=SEF->EF_AGENCIA
					cContaSEF:=SEF->EF_CONTA
					cTalaoSEF:=SEF->EF_TALAO

					SEF->(DbGoTo(nRegChOri))
					IF SEF->EF_STATUS == "01"
						lAnul := .T.
					EndIF
					RecLock("SEF")
					SEF->EF_STATUS	:= If(!lCheckSub,If(lCheckNul,If(cChvLbx$"11","01",If(cChvLbx="12","07","05")),"05"),"06")
					SEF->EF_RECONC	:=	""
					If SEF->EF_STATUS == "05" .and. Alltrim(SEF->EF_ORIGEM) == "FINA850" .and. cChvLbx == "15"
						SEF->EF_STATUS := "03"
						SEF->EF_REFTIP := ""
						SEF->EF_DATAPAG := Ctod("")
					EndIf
					If SEF->EF_STATUS == "05" .and. AllTrim(SEF->EF_ORIGEM) == "FINA550" .and. cChvLbx=="15"
						MsgAlert(STR0142) //"El cheque no puede ser cancelado debido a que se generó a través de la rutina de Caja Chica."
						SEF->EF_STATUS := "04"
					EndIf
					cEfFilChq	:=  SEF->EF_FILCHQ
					If SEF->EF_STATUS $ "00|01"
						SEF->EF_FILCHQ := ""
					EndIf
					cEfBenef	:=	SEF->EF_BENEF
					cHistOP		:=	SEF->EF_HIST
					cEfLiber	:=	SEF->EF_LIBER
					cEfLA		:=	SEF->EF_LA
					cEfSeq		:=	SEF->EF_SEQUENC
					cEfParc		:=	SEF->EF_PARCELA
					cEfLoja		:=	SEF->EF_LOJA
					cEfFornec	:=	SEF->EF_FORNECE
					cEfTitulo	:=	SEF->EF_TITULO
					cEfTipo		:=	SEF->EF_TIPO
					nEfValor	:=	SEF->EF_VALOR
					cEfOrdPg	:=  SEF->EF_ORDPAGO
					cEfOrigem	:=  SEF->EF_ORIGEM
					RecLock("SEF",.F.)

					If !Empty(cEfOrdPg) .And. !Empty(cChqSub) .And. lCheckSub
						aAreaSEK:=SEK->(GetArea())
						SEK->(DbSetOrder(1))
						IF SEK->(DbSeek(xFilial("SEK")+SEF->EF_ORDPAGO+"CP"+SEF->EF_PREFIXO+SEF->EF_NUM+SEF->EF_PARCELA+SEF->EF_TIPO))

							cSekFil:= SEK->EK_FILIAL

							cSekTip:=SEK->EK_TIPO
							cSekFor:=SEK->EK_FORNECE
							cSekLoj:=SEK->EK_LOJA

							nSekVlr:=SEK->EK_VALOR
							nSekVl1:=SEK->EK_VLMOED1
							cSekMoe:=SEK->EK_MOEDA
							cSekOrd:=SEK->EK_ORDPAGO

							cSekFoP:= SEK->EK_FORNEPG
							cSekLoP:=SEK->EK_LOJAPG

							If cPaisLoc <> "BRA"
								cSekNat:=SEK->EK_NATUREZ
							Endif
							If cPaisLoc == "ARG"
								lSekPgc:=SEK->EK_PGCBU
								cSekPgt:=SEK->EK_PGTOELT
								cSekMod:=SEK->EK_MODPAGO
							Endif
							cSekPre:=SEK->EK_PREFIXO

							RecLock("SEK",.F.)
							Replace SEK->EK_CANCEL With .T.
							Replace SEK->EK_OBSBCO WITH "Subs:" +cChqSub + "BCO:"+cBancoSEF+"AG:" + cAgencSEF
							MsUnLock()

							RecLock("SEK",.T.)
							SEK->EK_PREFIXO  := cPrefCh
							SEK->EK_NUM      := cChqSub
							SEK->EK_PARCELA  := cParcCh
							SEK->EK_FILIAL	:= cSekFil
							SEK->EK_TIPODOC	:= "CP"     //CHEQUE PROPIO
							SEK->EK_TIPO := cSekTip
							SEK->EK_FORNECE	:= cSekFor
							SEK->EK_LOJA   	:= cSekLoj
							SEK->EK_EMISSAO	:= dDataBase
							SEK->EK_VENCTO 	:= dVenctoCh
							SEK->EK_VALOR  	:= nSekVlr
							SEK->EK_VLMOED1	:= nSekVl1
							SEK->EK_MOEDA 	:= cSekMoe
							SEK->EK_BANCO 	:= cBancoSEF
							SEK->EK_AGENCIA	:= cAgencSEF
							SEK->EK_CONTA 	:= cContaSEF
							SEK->EK_ORDPAGO	:= cSekOrd
							SEK->EK_DTDIGIT	:= dDataBase
							SEK->EK_FORNEPG := cSekFoP
							SEK->EK_LOJAPG  := cSekLoP

							If cPaisLoc <> "BRA"
								SEK->EK_TALAO	:= cTalaoSEF
								SEK->EK_NATUREZ := cSekNat
							Endif
							If cPaisLoc == "ARG"
								SEK->EK_PGCBU := lSekPgc
								SEK->EK_PGTOELT := cSekPgt
								SEK->EK_MODPAGO := cSekMod
							Endif
							SEK->(MsUnLock())
						//Colocar rotina automatica
							cNumLiq:=Soma1(GetMv("MV_NUMLIQ"),6)
							aArray := { {"E2_PREFIXO",cPrefCh   , NIL },;
							{ "E2_NUM",cChqSub  , NIL },;
							{ "E2_TIPO",cSekTip  , NIL },;
							{ "E2_NATUREZ",cSekNat  , NIL },;
							{ "E2_FORNECE",cSekFor  , NIL },;
							{ "E2_LOJA",cSekLoj  , NIL },;
							{ "E2_EMISSAO",dDatabase  , NIL },;
							{ "E2_EMIS1",dDatabase  , NIL },;
							{ "E2_VENCTO",dVenctoCh  , NIL },;
							{ "E2_VENCREA",DataValida(dVenctoCh,.T.)  , NIL },;
							{ "E2_VALOR",nSekVlr  , NIL },;
							{ "E2_VENCORI",DataValida(dVenctoCh,.T.)  , NIL },;
							{ "E2_PARCELA",cParcCh  , NIL },;
							{ "E2_SALDO",nSekVlr  , NIL },;
							{ "E2_VLCRUZ",nSekVl1  , NIL },;
							{ "E2_SITUACA","0"  , NIL },;
							{ "E2_PORTADO",cBancoSEF  , NIL },;
							{ "E2_BCOCHQ",cBancoSEF  , NIL },;
							{ "E2_AGECHQ",cAgencSEF  , NIL },;
							{ "E2_CTACHQ",cContaSEF  , NIL },;
							{ "E2_ORDPAGO",cSekOrd  , NIL },;
							{ "E2_MOEDA",Val(cSekMoe)  , NIL },;
							{ "E2_NUMBCO",cChqSub  , NIL },;
							{ "E2_NUMLIQ",cNumLiq  , NIL },;
							{ "E2_DATALIB",dDatabase  , NIL },;
							{ "E2_ORIGEM","FINA850"  , NIL }}
							MsExecAuto( { |x,y,z| FINA050(x,y,z)}, aArray,, 3)  // 3 - Inclusao, 4 - Alteração, 5 - Exclusão
							If lMsErroAuto
								MostraErro()
							Else
								RecLock("SE2",.F.)
								SE2->E2_NUMBCO := cChqSub
								SE2->(MsUnLock())
							Endif
						EndIf
					EndIf

					RecLock("SEF",.F.)
					cChavePesq:= SEF->EF_PREFIXO+SEF->EF_NUM+SEF->EF_PARCELA+SEF->EF_TIPO+SEF->EF_FORNECE+SEF->EF_LOJA

					If lCheckSub .And. nRadio == 1 //Anular o cheque substituido
						SEF->EF_SUBSCHE	:=	cChqSub
					ElseIf (lCheckSub .And. nRadio == 2) //Disponibilizar para uso
						SEF->EF_STATUS		:= "00"
						SEF->EF_BENEF		:= ""
						SEF->EF_VENCTO		:= Ctod("")
						SEF->EF_DATA		:= Ctod("")
						SEF->EF_DATAPAG		:= Ctod("")
						SEF->EF_HIST 		:= ""
						SEF->EF_REFTIP 		:= ""
						SEF->EF_LIBER 		:= "S"
						SEF->EF_FORNECE		:= ""
						SEF->EF_LOJA		:= ""
						SEF->EF_LA     		:= ""
						SEF->EF_SEQUENC		:= ""
						SEF->EF_PARCELA		:= ""
						SEF->EF_TITULO  	:=	""
						SEF->EF_TIPO    	:=	"CH"
						SEF->EF_IMPRESS    	:=	""
						SEF->EF_VALOR		:=	0
						SEF->EF_FILCHQ		:= ""
					Endif
					SEF->(MSUnlock())
					DbSelectArea("FRF")
					If !lCheckSub .or. (lCheckSub .AND. cChStatus $ "01|04")
						If (!Alltrim(SEF->EF_ORIGEM)=="FINA550" .and. cChvLbx=="15")
							If cChvLbx == "15"
								cSeqFRF := GetSx8Num("FRF","FRF_SEQ")
		            			RecLock("FRF",.T.)
	    	         			FRF->FRF_FILIAL		:= xFilial("FRF")
	        	      			FRF->FRF_BANCO		:= SEF->EF_BANCO
	            	   			FRF->FRF_AGENCIA	:= SEF->EF_AGENCIA
		            			FRF->FRF_CONTA		:= SEF->EF_CONTA
	    	         			FRF->FRF_NUM		:= SEF->EF_NUM
	        	      			FRF->FRF_PREFIX		:= SEF->EF_PREFIXO
	            	   			FRF->FRF_CART		:= "P"
	    	         			FRF->FRF_DATPAG		:= SEF->EF_DATAPAG
		            			FRF->FRF_DATDEV		:= dDataBase
	        	      			FRF->FRF_MOTIVO		:= "15"
	            	   			FRF->FRF_DESCRI		:= "REVIERTE LIQUIDACION"
		            			FRF->FRF_SEQ		:= cSeqFRF
		            			FRF->FRF_FORNEC		:= SEF->EF_FORNECE
	   				   			FRF->FRF_LOJA		:= SEF->EF_LOJA
	   				   			FRF->FRF_NUMDOC		:= SEF->EF_ORDPAGO
	    	         			FRF->(MsUnLock())
	        	    			ConfirmSX8()
							Else
								cSeqFRF := GetSx8Num("FRF","FRF_SEQ")
			            		RecLock("FRF",.T.)
			            		FRF->FRF_FILIAL		:= xFilial("FRF")
		    	        		FRF->FRF_BANCO		:= SEF->EF_BANCO
		        	    		FRF->FRF_AGENCIA	:= SEF->EF_AGENCIA
		            			FRF->FRF_CONTA		:= SEF->EF_CONTA
			            		FRF->FRF_NUM		:= SEF->EF_NUM
			            		FRF->FRF_PREFIX		:= SEF->EF_PREFIXO
		    	        		FRF->FRF_CART		:= "P"
		        	    		FRF->FRF_DATPAG		:= SEF->EF_DATAPAG
		            			FRF->FRF_DATDEV		:= dDataBase
			            		FRF->FRF_MOTIVO		:= If(!lCheckNul,cChvLbx,"96")
			            		FRF->FRF_DESCRI		:= If(!lCheckNul,Substr(aMotivos[nChvLbx],(TamSX3("X5_TABELA")[1]+4),Len(FRF->FRF_DESCRI)),"CHEQUE ANULADO" )
		    	        		FRF->FRF_SEQ		:= cSeqFRF
		    	        		FRF->FRF_FORNEC		:= SEF->EF_FORNECE
	   					  		FRF->FRF_LOJA			:= SEF->EF_LOJA
	   					  		FRF->FRF_NUMDOC			:= SEF->EF_ORDPAGO
		        	    		FRF->(MsUnLock())
		            			ConfirmSX8()
			            		SEK->(DbSetOrder(1))
			            	EndIf
						EndIf
					Endif
					If !lCheckSub .or. (lCheckSub .AND. cChStatus $ "01|04|02|03")
						//EXCLUIR SE2 CHEQUE ORIGINAL

						If cChStatus $ "02|03"
							aAreaAt:=GetArea()
							aAreaSE2:=SE2->(GetArea())
							dbSelectArea("SE2")
							dbSetOrder(1)
							If SE2->(DbSeek(xfilial("SE2")+cChavePesq))
								RecLock("SE2",.F.)
								SE2->E2_ORDPAGO:=" "
								SE2->(MsUnLock())
								RestArea(aAreaAt)
								aArray := { {"E2_PREFIXO",SEF->EF_PREFIXO  , NIL },;
								{ "E2_NUM",SEF->EF_NUM, NIL },;
								{ "E2_TIPO",SEF->EF_TIPO  , NIL },;
								{ "E2_FORNECE",SEF->EF_FORNECE  , NIL },;
								{ "E2_LOJA",SEF->EF_LOJA  , NIL }}
								MsExecAuto( { |x,y,z| FINA050(x,y,z)}, aArray,, 5)  // 3 - Inclusao, 4 - Alteração, 5 - Exclusão
								If lMsErroAuto
									MostraErro()
								Endif
								SE2->(RestArea(aAreaSE2))
							EndIf
						EndIf
					Endif
					If cChStatus !="00"
						RecLock("SE2",.F.)
						SE2->E2_NUMBOR := Space(Len(SE2->E2_NUMBOR))
					EndIf
				Endif
				If cPaisLoc $ "ARG|DOM|EQU" .and. FUNNAME()=="FINA095" .and. lCheckSub	.and. !Empty(cChqSub)
					If cPaisLoc == "ARG"
						SEF->(DbGoTo(NREGCHORI))
					EndIf
					cSeqFRF  := GetSx8Num("FRF","FRF_SEQ")
	            	cChqOrig := SEF->EF_NUM
	            	RecLock("FRF",.T.)
    	        	FRF->FRF_FILIAL		:= xFilial("FRF")
        	    	FRF->FRF_BANCO		:= SEF->EF_BANCO
            		FRF->FRF_AGENCIA	:= SEF->EF_AGENCIA
	            	FRF->FRF_CONTA		:= SEF->EF_CONTA
    	        	FRF->FRF_NUM		:= SEF->EF_NUM
        	    	FRF->FRF_PREFIX		:= SEF->EF_PREFIXO
            		FRF->FRF_CART		:= "P"
    	        	FRF->FRF_DATPAG		:= SEF->EF_DATAPAG
	            	FRF->FRF_DATDEV		:= dDataBase
        	    	FRF->FRF_MOTIVO		:= "97"
            		If nChvLbx>0 .and. Len(aMotivos)>0
				   		FRF->FRF_DESCRI		:= If(!lCheckNul,Substr(aMotivos[nChvLbx],(TamSX3("X5_TABELA")[1]+4),Len(FRF->FRF_DESCRI)),STR0114 )
					Else
				   		FRF->FRF_DESCRI		:= STR0143 + CNUMCHQ // "Cheque Sustituido por: "
			    	EndIF
	            	FRF->FRF_SEQ		:= cSeqFRF
	            	FRF->FRF_FORNEC		:= SEF->EF_FORNECE
   				  	FRF->FRF_LOJA		:= SEF->EF_LOJA
   				  	FRF->FRF_NUMDOC		:= SEF->EF_ORDPAGO
    	        	FRF->(MsUnLock())
        	    	ConfirmSX8()

					SEF->(DbGoTo(nRegChSub))
					RecLock("SEF")
					SEF->EF_STATUS		:= "02"
					SEF->EF_BENEF		:= cEfBenef
					SEF->EF_VENCTO		:= dDtVctoSub
					SEF->EF_DATA		:= dDataBase
					SEF->EF_HIST 		:= cHistOP
					SEF->EF_LIBER 		:= cEfLiber
					SEF->EF_FORNECE		:= cEfFornec
					SEF->EF_LOJA		:= cEfLoja
					SEF->EF_LA     		:= cEfLa
					SEF->EF_SEQUENC		:= cEfSeq
					SEF->EF_PARCELA		:= cEfParc
					SEF->EF_TITULO  	:= cEfTitulo
					SEF->EF_ORDPAGO		:= cEfOrdPg
					SEF->EF_TIPO    	:= cEfTipo
					SEF->EF_VALOR		:= nEfValor
					SEF->EF_ORIGEM		:= cEfOrigem
					SEF->EF_FILCHQ		:= cEfFilChq
					If Empty(SEF->EF_IDSEF)
						SEF->EF_IDSEF	:= FWUUIDV4()
					EndIf
					SEF->(MsUnlock())
					SEK->(DbSetOrder(1))
					If SEK->(DbSeek(xFilial("SEK")+ALLTRIM(cEfTitulo)+"CP"))
						If SEK->EK_TIPO==SEF->EF_TIPO
							RecLock("SEK")
							SEK->EK_BANCO	:=SEF->EF_BANCO
							SEK->EK_AGENCIA	:=SEF->EF_AGENCIA
							SEK->EK_CONTA	:=SEF->EF_CONTA
							SEK->(MsUnlock())
						Endif
					Endif

					//Gera o registro de histório de amarração do cheque que foi substituído
					cSeqFRF := GetSx8Num("FRF","FRF_SEQ")
	            	RecLock("FRF",.T.)
    	        	FRF->FRF_FILIAL		:= xFilial("FRF")
        	    	FRF->FRF_BANCO		:= SEF->EF_BANCO
            		FRF->FRF_AGENCIA	:= SEF->EF_AGENCIA
	            	FRF->FRF_CONTA		:= SEF->EF_CONTA
    	        	FRF->FRF_NUM		:= SEF->EF_NUM
        	    	FRF->FRF_PREFIX		:= SEF->EF_PREFIXO
            		FRF->FRF_CART		:= "P"
    	        	FRF->FRF_DATPAG		:= SEF->EF_DATAPAG
	            	FRF->FRF_DATDEV		:= dDataBase
        	    	FRF->FRF_MOTIVO		:= "99"
            		FRF->FRF_DESCRI		:= STR0144 + cChqOrig // "En substitucion del cheque: "
	            	FRF->FRF_SEQ		:= cSeqFRF
	            	FRF->FRF_FORNEC		:= SEF->EF_FORNECE
   				  	FRF->FRF_LOJA		:= SEF->EF_LOJA
   				  	FRF->FRF_NUMDOC		:= SEF->EF_ORDPAGO
    	        	FRF->(MsUnLock())
        	    	ConfirmSX8()

					SE2->(DbGoTo(nReg))
					RecLock("SE2")
					SE2->E2_NUM		:= SEF->EF_NUM
					SE2->E2_NUMBCO	:= SEF->EF_NUM
					SE2->E2_BCOCHQ	:= SEF->EF_BANCO
					SE2->E2_AGECHQ	:= SEF->EF_AGENCIA
					SE2->E2_CTACHQ	:= SEF->EF_CONTA
					SE2->E2_PORTADO	:= SEF->EF_BANCO
					SE2->E2_PREFIXO	:= SEF->EF_PREFIXO
					SE2->E2_VENCTO 	:= dDtVctoSub
					SE2->E2_VENCREA	:= DataValida(dDtVctoSub,.T.)
					SE2->E2_VENCORI	:= DataValida(dDtVctoSub,.T.)
					SE2->E2_EMISSAO	:= dDataBase
					SE2->E2_EMIS1	:= dDataBase
					SE2->E2_DATALIB := dDataBase
					SE2->E2_ORIGEM	:= "FINA090"
					SE2->(MsUnlock())
				Endif
			Endif
			If cPaisLoc=="ARG" .and. FUNNAME()=="FINA095" .and. cChvLbx<>"11" .and. cChvLbx<>"15" .and. lAnular
				aRegSEF := {SEF->(Recno())}
				/*se for movimento bancario, anulo o movimento gerado pela fina100*/
				If Upper(AllTrim(SEF->EF_ORIGEM)) == "FINA100"
					SE5->(DbSetOrder(11))
					If SE5->(DbSeek(xFilial("SE5") + SEF->EF_BANCO + SEF->EF_AGENCIA + SEF->EF_CONTA  + SEF->EF_NUM))
						aRegSE5 := {}
						While  Len(aRegSE5) == 0
							If SE5->E5_TALAO == SEF->EF_TALAO
								AADD(aRegSE5,{"E5_DATA",SE5->E5_DATA,Nil})
								Fina100(0,aRegSE5,6)
							EndIf
							SE5->(DbSkip())
						EndDo
					Endif
				Endif
				/*
				Antes de se chamar funcao da locxnf - mata466 - deve-se inicializar a variavel abaixo com um bloco de codigo que sera usado para
				preencher os dados da nota automaticamente. Este bloco de codigo e executado logo apos a criacao da tela de digitacao da nota e
				alem de inicializar as variaveis, define o bloco de validacao executado apos a digitacao da ND. O bloco de validacao e responsavel
				por recuperar os dados da ND digitada. */
				SE5->(DbGoTo(aRegSEF[1]))
				bFunAuto := {|| A095DadosND(SEF->EF_FORNECE,SEF->EF_LOJA,aRegSEF)}
				/*
				As variaveis com os dados da nota sao declaradas como private para estarem disponiveis para o bloco de validacao preenche-las apos a
				finalizacao da digitacao da ND. */
				cNumNota	:= ""
				cSerNota	:= ""
				cEspNota	:= ""
				If !Empty(SEF->EF_DATA)
					ExecViewMVC(SEF->EF_FORNECE,SEF->EF_LOJA,aRegSEF,nTipoND)
					Mata101n(,,,,3,nTipoND)
					If Empty(cNumNota)
						DisarmTransaction()
						Break
					EndIf
				EndIf
  				If cChvLbx=="12" // .and. lAnular
	  				RecLock("SEF",.F.)
	  				SEF->EF_STATUS="07"
	  				SEF->(MsUnLock())
	  			ElseIf Empty(cChvLbx)
	  				RecLock("SEF",.F.)
	  				SEF->EF_STATUS="05"
	  				SEF->(MsUnLock())
  				EndIf
				For nI := 1 To Len(aRegSEF)
					SEF->(DbGoTo(aRegSEF[nI]))
					If SEF->EF_VALOR > 0
						/*
						registra a criacao da ND no historico do documento*/
						cSeqFRF := GetSx8Num("FRF","FRF_SEQ")
						RecLock("FRF",.T.)
						Replace FRF->FRF_FILIAL		With xFilial("FRF")
						Replace FRF->FRF_BANCO		With SEF->EF_BANCO
						Replace FRF->FRF_AGENCIA	With SEF->EF_AGENCIA
						Replace FRF->FRF_CONTA		With SEF->EF_CONTA
						Replace FRF->FRF_NUM		With SEF->EF_NUM
						Replace FRF->FRF_PREFIX		With SEF->EF_PREFIXO
						Replace FRF->FRF_CART		With "P"
						Replace FRF->FRF_DATPAG		With SEF->EF_DATAPAG
						Replace FRF->FRF_DATDEV		With dDataBase
						Replace FRF->FRF_MOTIVO		With "80"
						Replace FRF->FRF_DESCRI		With STR0139//"Documento de débito (proveedor)"
						Replace FRF->FRF_SEQ		With cSeqFRF
						Replace FRF->FRF_FORNEC		With SEF->EF_FORNECE
						Replace FRF->FRF_LOJA		With SEF->EF_LOJA
						Replace FRF->FRF_NUMDOC		With cNumNota
						SerieNFID("FRF",1,"FRF_SERDOC",dDataBase,cEspNota,cSerNota)
						Replace FRF->FRF_ITDOC		With AllTrim(StrZero(nI,TamSX3("D1_ITEM")[1]))
						Replace FRF->FRF_ESPDOC		With cEspNota
						FRF->(MsUnLock())
						ConfirmSX8()
					EndIf
				Next
			ElseIf !(cPaisLoc=="BRA") .and. FUNNAME()=="FINA095" .and. ( cChvLbx=="11" .Or. Empty(cChvLbx))  .and. lAnular  //paulo
	  			
				if cPaisLoc $ "ARG|CHI|URU|PAR"
					aRegSEF := {SEF->(Recno())}
					For nI := 1 To Len(aRegSEF)
					SEF->(DbGoTo(aRegSEF[nI]))
						If SEF->EF_VALOR > 0
							//Realiza na FRF o registro da anulação do cheque com o motivo 11
							cSeqFRF := GetSx8Num("FRF","FRF_SEQ")
							RecLock("FRF",.T.)
							Replace FRF->FRF_FILIAL		With xFilial("FRF")
							Replace FRF->FRF_BANCO		With SEF->EF_BANCO
							Replace FRF->FRF_AGENCIA	With SEF->EF_AGENCIA
							Replace FRF->FRF_CONTA		With SEF->EF_CONTA
							Replace FRF->FRF_NUM		With SEF->EF_NUM
							Replace FRF->FRF_PREFIX		With SEF->EF_PREFIXO
							Replace FRF->FRF_CART		With "P"
							Replace FRF->FRF_DATDEV		With dDataBase
							Replace FRF->FRF_MOTIVO		With cChvLbx
							Replace FRF->FRF_DESCRI		With "Devolución con Nueva Presentación"
							Replace FRF->FRF_SEQ		With cSeqFRF
							Replace FRF->FRF_FORNEC		With SEF->EF_FORNECE
							Replace FRF->FRF_LOJA		With SEF->EF_LOJA
							Replace FRF->FRF_NUMDOC		With SEF->EF_ORDPAGO
							
							FRF->(MsUnLock())
							ConfirmSX8()
						EndIf
					Next 
				endif 				  
				  
				SEF->(dbGoTo(nPosSEF ))
	  			RecLock("SEF",.F.)
	  				SEF->EF_STATUS="03"
	  			SEF->(MsUnLock())
			Endif
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Final da prote‡„o via TTS						³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		End Transaction

		// Ponto de Entrada para el reemplazo de cheques
		If cPaisloc <> "BRA" .AND. ExistBlock('FA090RCH')
			Execblock( 'FA090RCH', .F., .F. )
		EndIf

		//Envio de e-mail pela rotina de checklist de documentos obrigatorios
		If GetNewPar("MV_FINVDOC","2")=="1"
			CN062ValDocs("03",.F.,.T.)
		EndIf

		SA6->(DbSetOrder(nOrdSa6), DbGoto(nRecSa6))
	Endif

	dbSelectArea(cAlias)
	If nSalvRec > 0
		dbGoTo(nSalvRec)
	EndIf
	dbSetOrder(nOrdem)
Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³FA090VldCH  ºAutor ³ Wagner Montenegro º Data ³ 30/09/2010 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Validação de Substituição de Cheque                       º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±³ Uso      ³ Equador/Rep. Dominicana/Argentina                         ³±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function FA090VldCH(cBcoSub,cAgeSub,cCtaSub,cPrxSub,cChqSub,nRecChqSub,lCheckSub,nRegChSub,cTipoTalao)
	Local cTMPSEF
	Local nXrec
	Local cQrySEF
	Local lLckSEF	:= .F.
	If !lCheckSub .and. !Empty(cChqSub)
		MsgAlert(STR0101) //"O cheque reservado para substituição será liberado!"
		cBcoSub:=Space(TamSX3("A6_COD")[1])
		cAgeSub:=Space(TamSX3("A6_AGENCIA")[1])
		cCtaSub:=Space(TamSX3("A6_CONTA")[1])
		cPrxSub:=Space(TamSX3("EF_PREFIXO")[1])
		cChqSub:=Space(TamSX3("EF_NUM")[1])
		SEF->(MsUnlock())
		If !cChStatus$"01/02/03/07"
			If oCBXMotiv != Nil
				oCBXMotiv:Enable()
			EndIf
		Endif
		lLckSEF := .T.
	Else
		cTMPSEF	:=	Alias()
		If Select("TMPSEF")>0
			TMPSEF->(DbCloseArea())
		Endif
		cQrySEF	:="SELECT EF_CART,EF_TALAO,EF_PREFIXO,EF_NUM,EF_STATUS,EF_LIBER,FRE_TIPO,FRE_PREFIX,"+RETSQLNAME("SEF")+".R_E_C_N_O_ "
		cQrySEF	+="FROM "+RETSQLNAME("SEF")+" INNER JOIN " + RETSQLNAME("FRE")
		cQrySEF	+=" ON  EF_TALAO = FRE_TALAO AND EF_BANCO = FRE_BANCO AND EF_AGENCIA = FRE_AGENCI AND EF_CONTA = FRE_CONTA"
		cQrySEF 	+=" WHERE EF_FILIAL='"+xFILIAL("SEF")+"' AND EF_CART='P' AND "
		cQrySEF	+=" EF_BANCO='"+cBcoSub+"' AND EF_AGENCIA='"+cAgeSub+"' AND EF_CONTA='"+cCtaSub+"' AND EF_STATUS='00' AND EF_LIBER='S' "
		cQrySEF	+=" AND FRE_TIPO = '"+cTipoTalao+"' "
		cQrySEF	+=" AND "+RETSQLNAME("SEF")+ ".D_E_L_E_T_ = ' ' ORDER BY EF_CART,EF_TALAO,EF_PREFIXO,EF_NUM "
		cQrySEF	:= ChangeQuery(cQrySEF)

		dbUseArea(.T., "TOPCONN", TCGenQry(,,cQrySEF), "TMPSEF", .T., .T.)
		DbSelectArea("TMPSEF")
		TMPSEF->(DbGoTop())
		nXrec := 0
		While !TMPSEF->(EOF())
			nRecChqSub	:=	TMPSEF->R_E_C_N_O_
			SEF->(DbGoTo(nRecChqSub))
			If !EMPTY(SEF->EF_TALAO) .and. !EMPTY(SEF->EF_NUM) .and. SEF->EF_STATUS=="00" .and. SEF->EF_LIBER=="S" .and. SEF->(DbRlock(nRecChqSub))
				cPrxSub:=IIf(Empty(SEF->EF_PREFIXO),TMPSEF->FRE_PREFIX,SEF->EF_PREFIXO)
				cChqSub:=SEF->EF_NUM
				nRegChSub	:=	SEF->(Recno())
				If cChStatus$"01|04"
					If oCBXMotiv != Nil
						oCBXMotiv:Enable()
					EndIf
				Else
					If oCBXMotiv != Nil
						oCBXMotiv:Disable()
					EndIf
				Endif
				lLckSEF := .T.
				Exit
			Endif
			TMPSEF->(DbSkip())
		Enddo
		If !lLckSEF
			SEF->(MsUnlock())
			MsgAlert(STR0137) //"Não foi encontrado cheque disponivel para substituição!"
			lCheckSub:=.F.
			If !cChStatus$"01/02/03/07"
				If oCBXMotiv != Nil
					oCBXMotiv:Enable()
				EndIf
			Endif
			TMPSEF->(DbCloseArea())
		Endif
		DbSelectArea(cTMPSEF)
	Endif

	If oBcoSub != Nil
		oBcoSub:Refresh()
	EndIf
	If oAgeSub != Nil
		oAgeSub:Refresh()
	EndIf
	If oCtaSub != Nil
		oCtaSub:Refresh()
	EndIf
	If oPrxSub != Nil
		oPrxSub:Refresh()
	EndIf
	If oChqSub != Nil
		oChqSub:Refresh()
	EndIf
	If oChkBoxSub != Nil
		oChkBoxSub:Refresh()
	EndIf
	If oChkBoxNul != Nil
		oChkBoxNul:Refresh()
	EndIf
	If oDtVctoSub != Nil
		oDtVctoSub:Refresh()
	EndIf
	If oCBXMotiv != Nil
		oCBXMotiv:Refresh()
	EndIf
Return(lLckSEF)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³FA090IniOb  ºAutor ³ Wagner Montenegro º Data ³ 30/09/2010 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Inicialização de objetos - Controle de Cheques Equador    º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±³ Uso      ³ Equador/Rep. Dominicana/Argentina                         ³±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function FA090IniOb(cChStatus)
	If cChStatus	$	"01/02/03/07"
		If oChkBoxNul != Nil
			oChkBoxNul:Refresh()
		EndIf
		If oCBXMotiv != Nil
			oCBXMotiv:Disable()
			oCBXMotiv:Refresh()
		EndIf
	Else
		If oChkBoxNul != Nil
			oChkBoxNul:Disable()
			oChkBoxNul:Refresh()
		EndIf
	Endif
Return

//-------------------------------------------------------
/*/ F090VLDMOE

@author Totvs
@since 30/07/2018
@version P12
*/
//-------------------------------------------------------
Static Function F090VLDMOE(cBcoOr,cAgOri,cCCOri,cBcoDe,cAgDe,cCCDe)

Local aAlias:=GetArea()
Local aAliasSA6:=SA6->(GetArea())
Local nMoedaOri:=0
Local lret:=.T.

SA6->(DbSetOrder(1))
SA6->(DbSeek(xFilial("SA6")+cBcoOr+cAgOri+cCCOri))
nMoedaOri:=SA6->A6_MOEDA
SA6->(DbSeek(xFilial("SA6")+cBcoDe+cAgDe+cCCDe))

If nMoedaOri<>SA6->A6_MOEDA
	MsGStop(STR0138)
	lret:=.F.
EndIf

SA6->(RestArea(aAliasSA6))
RestArea(aAlias)

Return(lRet)

/*/{Protheus.doc} VlgGrpPerg
	Verifica si existe el grupo de preguntas FIN090A
	@type  Function
	@author luis.samaniego
	@since 20/06/2023
	@return cPerg, Character, Nombre del grupo de preguntas (FIN090A/FIN090)
	/*/
Static Function VlgGrpPerg()
Local cPerg    := "FIN090A"
Local oGrpPerg := FWSX1Util():New()

	oGrpPerg:AddGroup("FIN090A")
	oGrpPerg:SearchGroup()
	If Len(oGrpPerg:GetGroup("FIN090A")[2]) == 0
		cPerg := "FIN090"
	EndIf
Return cPerg

//---------------------------------------------------------------
/*/{Protheus.doc} AtuSldCC
	Realiza a atualização do Saldo e do Status da Caja Chica de maneira
	automática ao liquidar o cheque associado a reposição.
	@type  Function
	@author santos.rafael
	@since 09/08/2023
	/*/

Function AtuSldCC(cNumero, dbaixa)

Local aAreaSEU := {}
Local aAreaSET := {}
Local cQry := GetNextAlias()

Default cNumero := ""
Default dbaixa := dDatabase


BeginSql alias cQry
SELECT SEU.EU_CAIXA, SEU.EU_VALOR, SEU.R_E_C_N_O_ RECNOSEU
FROM %table:SEU% SEU
WHERE SEU.EU_TITULO = %Exp:cNumero% AND SEU.EU_FILIAL = %Exp:(xFilial("SEU"))% AND SEU.%notdel%
Endsql


DBSelectArea("SEU")
aAreaSEU := SEU->(GetArea())
DBGoto((cQry)->(RECNOSEU))

RecLock("SEU")
SEU->EU_BAIXA := dbaixa 
MsUnlock()

dbSelectArea("SET")
aAreaSET := SET->(GetArea())
dbSetOrder(1)  // filial + caixa

If dbSeek(xFilial("SET")+(cQry)->EU_CAIXA)
	RecLock("SET",.F.)
	SET->ET_SALANT := SET->ET_SALDO	
	SET->ET_SALDO  := SET->ET_SALDO + (cQry)->EU_VALOR
	MsUnlock()
ENDIF


(cQry)->(DBCloseArea())
SEU->(DBCloseArea())
SET->(DBCloseArea())
RestArea( aAreaSEU )
RestArea( aAreaSET )

Return

/*/{Protheus.doc} ExecViewMVC
realiza la verificación de si se seguirá el proceso a partir de los nuevos modelos
y las nuevas rutinas en MVC, o si debe considerar la funcionalidad actual del sistema
@type function
@version 12.1.2510
@author pedro.candido
@since 5/22/2026
@param cFornece, character, código del proveedor
@param cLoja, character, código de la tienda
@param aItens, array, lista de ítems (es el recno de la tabla SEF)
@param nTipoND, numeric, tipo del documento (NF, NDP o NCI)
@param cAlias, character, tabla de la lista de registros
@param cCpoVal, character, nombre del campo que contiene el valor del ítem
@param lLinhas, logical, indica si se podrán incluir otros ítems en la ND
@param lTitulo, logical, indica si los TES de los ítems deberán generar títulos en el financiero
@param lVldImpFor, logical, indica que el TES no debe tener impuesto en el proveedor
@return variant, Nil
/*/
Function ExecViewMVC(cFornece,cLoja,aItens,nTipoND,cAlias,cCpoVal,lLinhas,lTitulo,lVldImpFor)
Local aArea        := GetArea()
Local nItem        := 0
Local aSF1Val      := {}
Local aSD1Val      := {} 
Local aSD1Aux      := {{}} 
Local aLockCampos  := {}
Local aValLine     := {}
Local aValTudoOK   := {}
Local aValCampo    := {}
Local aValPE       := {}
Local cTitulo      := ".F."
Local cVldImpFor   := ".F."
Local cPVArg       := ""
Local cTipoND      := ""
Local cParCOD      := PADR(SuperGetMV("MV_FINPDGB", .F., "RG498"), GetSx3Cache('B1_COD', 'X3_TAMANHO'))
Local cParTES      := SuperGetMV("MV_FINTEGB", .F., "498")
Local lF100Arg     :=  cPaisLoc == "ARG" .And. FunName() == "FINA100"
Local nMoedBco     := 0
Local lF100detus   := Existblock("F100DETUSR")
 
Default cFornece   := ""
Default cLoja	   := ""
Default aItens	   := {}
Default nTipoND	   := 10
Default cAlias	   := "SEF"
Default cCpoVal	   := "EF_VALOR"
Default lTitulo	   := .T.
Default lLinhas	   := .T.
Default lVldImpFor := .F.

	If FindFunction("LxExecMod") .And. LxExecMod() .And. FindFunction("LxArrayMVC")

		cTipoND := StrZero(nTipoND,2)

		If cTipoND $ "08" .And. Pergunte("PVXARG",.T.)
			cPVArg := MV_PAR01
		EndIf
		If !Empty(cPVArg)
			aAdd(aSF1Val,{"F1_PV",cPVArg})
		EndIf
		aAdd(aSF1Val,{"F1_FORNECE",cFornece})
		aAdd(aSF1Val,{"F1_LOJA",cLoja})

		If lF100Arg
			nMoedBco := Posicione("SA6",1,xfilial("SA6") + SE5->E5_BANCO + SE5->E5_AGENCIA + SE5->E5_CONTA ,"A6_MOEDA")
			aAdd(aSF1Val,{"F1_MOEDA",nMoedBco})
			If SE5->E5_TXMOEDA > 0
				If nMoedBco > 1
					aAdd(aSF1Val,{"F1_TXMOEDA",SE5->E5_TXMOEDA})
				Else
					aAdd(aSF1Val,{"F1_TXMOEDA",1})
				EndIf
			Else
				aAdd(aSF1Val,{"F1_TXMOEDA",RecMoeda(dDataBase,nMoedBco)})
			EndIf
			aAdd(aSF1Val,{"F1_NATUREZ",SE5->E5_NATUREZ})
		EndIf

		aAdd(aLockCampos,"F1_FORNECE")
		aAdd(aLockCampos,"F1_LOJA")

		For nItem := 1 To Len(aItens)
			If aItens[nItem] > 0
				(cAlias)->(DbGoTo(aItens[nItem]))
				If lF100Arg
					aSD1Aux := {}
					SB1->(DbSetOrder(RetOrder("SB1","B1_FILIAL+B1_COD")))
					SB1->(MsSeek(xFilial("SB1") + cParCOD))
					SF4->(DbSetOrder(RetOrder("SF4","F4_FILIAL+F4_CODIGO")))
					SF4->(MsSeek(xFilial("SF4") + cParTES))

					aAdd(aSD1Aux,;
					{;
						{"D1_COD"     , cParCOD            },;
						{"D1_UM"      , SB1->B1_UM         },;
						{"D1_LOCAL"   , SB1->B1_LOCPAD     },;
						{"D1_CONTA"   , SB1->B1_CONTA      },;
						{"D1_ITEMCTA" , SB1->B1_ITEMCC     },;
						{"D1_CC"      , SB1->B1_CC         },;
						{"D1_CLVL"    , SB1->B1_CLVL       },;
						{"D1_TES"     , cParTES            },;
						{"D1_CF"      , SF4->F4_CF         };
					})
				EndIf
				aAdd(aSD1Aux[1],{"D1_QUANT",1})
				aAdd(aSD1Aux[1],{"D1_VUNIT",(cAlias)->&cCpoVal})
				aAdd(aSD1Aux[1],{"D1_TOTAL",(cAlias)->&cCpoVal})

				aAdd(aSD1Val,aClone(aSD1Aux[1]))
				aSD1Aux := {{}}
			EndIf
		Next

		// El punto de entrada permite la inclusión de valores en el arreglo aCols.
		If lF100detus .and. Funname() == "FINA100"
			aAdd(aValPE,{"F100DETUSR",.F., .F.})
		EndIf 

		If lTitulo
			cTitulo := ".T."
		EndIf
		If lVldImpFor
			cVldImpFor := ".T."
		EndIf

		aAdd(aValLine, {|| A095NDTES("", lTitulo, lVldImpFor)})
		
		aAdd(aValTudoOK, {|| A095NDTES("", lTitulo, lVldImpFor) .And. A095NDGer()})

		aAdd(aValCampo, {"D1_TES", "A095NDTES(," + cTitulo + "," + cVldImpFor + ")"})
		
		LxArrayMVC(aSF1Val, aSD1Val, aLockCampos, aValLine, aValTudoOK, aValCampo, aValPE)

		FwFreeArray(aSF1Val)
		FwFreeArray(aSD1Val)
		FwFreeArray(aSD1Aux)
		FwFreeArray(aLockCampos)
		FwFreeArray(aValLine)
		FwFreeArray(aValTudoOK)
		FwFreeArray(aValCampo)
		FwFreeArray(aValPE)
		RestArea(aArea)
		FwFreeArray(aArea)

	EndIf

Return()
