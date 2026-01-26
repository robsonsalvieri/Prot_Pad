#INCLUDE "GFEA085.ch"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"

Static _MVGFEAJDF	:= SuperGetMv("MV_GFEAJDF",,'1')

Static _GWONROCO	:= GFXCP12118("GWO_NROCO")

Static _lPE851		:= ExistBlock("GFEA0851")

//-------------------------------------------------------------------
/*/{Protheus.doc} GFEA085

Aprovação Ajuste de Frete

@author Jorge Matos Valcanaia
@since 10/05/10
@version 1.0

/*/

//-------------------------------------------------------------------

Function GFEA085()
	Local cFiltro
	Local cHoraDe := ""
	Local cHoraAte := ""
	Local cCond := ""
	Private oBrowse

	if !Pergunte("GFEA085",.T.)
		Return nil
	endif

	oBrowse := FWMBrowse():New()
	oBrowse:SetAlias("GWO")				// Alias da tabela utilizada
	oBrowse:SetMenuDef("GFEA085")		// Nome do fonte onde esta a função MenuDef
	oBrowse:SetDescription("Aprovação de Ajustes de Cálculos de Frete")	    // Descrição do browse //"Aprovação Ajuste de Frete"

	cHoraDe := MV_PAR06
	cHoraAte := MV_PAR07

	cHoraDe := SubStr(cHoraDe, 1, 2) + ":" + SubStr(cHoraDe, 3, 4)
	cHoraAte := SubStr(cHoraAte, 1, 2) + ":" + SubStr(cHoraAte, 3, 4)

	cFiltro := " GWO_NRROM >= '" + MV_PAR01 + "' .AND. GWO_NRROM <= '" + MV_PAR02 + "'"
	cFiltro += " .AND. GWO_DTAJUS >= STOD('" + DToS(MV_PAR04)  + "') .AND. GWO_DTAJUS <= STOD('" + DToS(MV_PAR05) + "')"
	cFiltro += " .AND. GWO_HRAJUS >= '" + cHoraDe + "' .AND. GWO_HRAJUS <= '" + cHoraAte + "'"

	If MV_PAR08 == 1
		cCond := "1"
	Elseif MV_PAR08 == 2
		cCond := "2"
	Elseif MV_PAR08 == 3
		cCond := "3"
	Elseif MV_PAR08 == 4
		cCond := "123"
	EndIf

	cFiltro += " .AND. GWO_SITAJU $ '"+cCond+"'"

	If !Empty(MV_PAR03)
		cFiltro += " .And. Lower(GWO_USRAJU) == '"+Lower(MV_PAR03)+"'"
	Endif

	//Chama a função responsável por abrir o pergunte dentro da página(F12)
	SetKey(VK_F12, {||GFEA085PAR()()})

	oBrowse:SetFilterDefault(cFiltro)

	oBrowse:Activate()

Return(Nil)

//-------------------------------------------------------------------
Static Function MenuDef()
	Local aRotina := {}
	//-------------------------------------------------------
	// Adiciona botões do browse
	//-------------------------------------------------------
	ADD OPTION aRotina TITLE STR0002  ACTION "AxPesqui"        OPERATION 1  ACCESS 0 //"Pesquisar"
	ADD OPTION aRotina TITLE STR0003  ACTION "VIEWDEF.GFEA085" OPERATION 2  ACCESS 0 //"Visualizar"
	ADD OPTION aRotina TITLE STR0004  ACTION "GFEA085APR()"    OPERATION 10 ACCESS 0 //"Aprovar"
	ADD OPTION aRotina TITLE STR0005  ACTION "GFEA085REP()"    OPERATION 11 ACCESS 0 //"Reprovar"

Return aRotina

//-------------------------------------------------------------------
Static Function ModelDef()

	Local oModel

	// cID     Identificador do modelo
	// bPre    Code-Block de pre-edição do formulário de edição. Indica se a edição esta liberada
	// bPost   Code-Block de validação do formulário de edição
	// bCommit Code-Block de persistência do formulário de edição
	// bCancel Code-Block de cancelamento do formulário de edição
	oModel := MPFormModel():New("GFEA085", /*bPre*/, /*bPost*/, /*bCommit*/, /*bCancel*/)
	// cId          Identificador do modelo
	// cOwner       Identificador superior do modelo
	// oModelStruct Objeto com  a estrutura de dados
	// bPre         Code-Block de pré-edição do formulário de edição. Indica se a edição esta liberada
	// bPost        Code-Block de validação do formulário de edição
	// bLoad        Code-Block de carga dos dados do formulário de edição
	oModel:AddFields("GFEA085_GWO", Nil, FWFormStruct(1,"GWO"),/*bPre*/,/*bPost*/,/*bLoad*/)
	oModel:SetPrimaryKey({"GWO_FILIAL", "GWO_TPITEM"})

Return oModel

Static Function ViewDef()

	Local oModel := FWLoadModel("GFEA085")
	Local oView  := Nil

	oView := FWFormView():New()
	// Objeto do model a se associar a view.
	oView:SetModel(oModel)
	// cFormModelID - Representa o ID criado no Model que essa FormField irá representar
	// oStruct - Objeto do model a se associar a view.
	// cLinkID - Representa o ID criado no Model ,Só é necessári o caso estamos mundando o ID no View.
	oView:AddField( "GFEA085_GWO" , FWFormStruct(2,"GWO"), /*cLinkID*/ )	//
	// cID		  	Id do Box a ser utilizado
	// nPercHeight  Valor da Altura do box( caso o lFixPixel seja .T. é a qtd de pixel exato)
	// cIdOwner 	Id do Box Vertical pai. Podemos fazer diversas criações uma dentro da outra.
	// lFixPixel	Determina que o valor passado no nPercHeight é na verdade a qtd de pixel a ser usada.
	// cIDFolder	Id da folder onde queremos criar o o box se passado esse valor, é necessário informar o cIDSheet
	// cIDSheet     Id da Sheet(Folha de dados) onde queremos criar o o box.
	oView:CreateHorizontalBox( "MASTER" , 100,/*cIDOwner*/,/*lFixPixel*/,/*cIDFolder*/,/*cIDSheet*/ )
	// Associa um View a um box
	oView:SetOwnerView( "GFEA085_GWO" , "MASTER" )

	oView:AddUserButton("Consultar ocorrência","MAGIC_BMP",{|oView|ConsOco(oView)})

Return oView

Static Function ConsOco(oView)
	Local oModel := oView:GetModel()
	Local oModelGWO := oModel:GetModel("GFEA085_GWO")
	Local cNrOco := oModelGWO:GetValue("GWO_NROCO")

	If Empty(cNrOco)
		Help( ,, 'HELP',, "Não há ocorrência relacionada.", 1, 0)
	Else
		GWD->(dbSetOrder(1))
		If GWD->(dbSeek(xFilial('GWD') + cNrOco))
			FwExecView(,'GFEC032')
		Else
			Help( ,, 'HELP',, "Ocorrência " + cNrOco + " não localizada.", 1, 0)
		EndIf
	EndIf
Return


//-------------------------------------------------------------------
/*/{Protheus.doc} GFEA085APR

Função que trata a aprovação do Ajuste feito para o cálculo

@author Jorge Matos Valcanaia
@since 11/05/10
@version 1.0
/*/
//-------------------------------------------------------------------
Function GFEA085APR(lAjusteMenor)
	Local lRet := .T.
	Local lCalCDoc := .F.  // Calculo com documento de frete
	Local lEncontrou := .F.
	Local lBloqueiou := .F.

	Private cMotBloq := "" //Variavel será utilizada no GFEA065C
	Default lAjusteMenor := .F. 

	If _GWONROCO .And. !Empty(GWO->GWO_NROCO) .And. !lAjusteMenor
		Help( ,, 'HELP',, "O ajuste de frete está relacionado à ocorrência " + GWO->GWO_NROCO + ". Para aprová-lo, aprove a ocorrência.", 1, 0)
		lRet := .F.
	EndIf

	If _MVGFEAJDF == '1'
		GW1->( dbSetOrder(9) )
		GW1->( dbSeek(xFilial("GW1") + AllTrim(GWO->GWO_NRROM)) )
		While !GW1->( Eof() ) .AND. GW1->GW1_FILIAL == xFilial("GW1") .AND. GW1->GW1_NRROM == AllTrim(GWO->GWO_NRROM)

			GW4->( dbSetOrder(2) )
			If GW4->( dbSeek(xFilial("GW4") + GW1->GW1_EMISDC + GW1->GW1_SERDC + GW1->GW1_NRDC + GW1->GW1_CDTPDC) )

				GW3->( dbSetOrder(9) )
				If GW3->( dbSeek(xFilial("GW3") + GW4->GW4_SERDF + GW4->GW4_NRDF) )
					If GW3->GW3_SIT == "3" .Or. GW3->GW3_SIT == "4"
						GFEHelp("Existem documentos de frete com a situação "+ IF((GW3->GW3_SIT == "3"), '"Aprovado pelo Sistema"', '"Aprovado pelo Usuário"') +" relacionados a esse documento de carga, portanto, o ajuste não pode ser aprovado.","Desvincular o documento carga deste(s) documento(s) de frete.","Help")
						Return .F.
					EndIf
				EndIf
			EndIf
			GW1->( dbSkip() )
		EndDo

		If !GFEVldLotProvisao(GWO->GWO_NRCALC)
			GFEHelp("Cálculo já relacionado à Lote de Provisão.","Realize a exclusão do Lote de Provisão.","Help")
			Return .F.
		EndIf
	EndIf

	// Início Ponto de Entrada
	If _lPE851
		lRet :=	ExecBlock("GFEA0851",.F.,.F.)
	EndIf
	// Fim Ponto de Entrada
	//Se estiver com situação diferente de 1 que é Solicitado apresenta mensagem de erro
	If GWO->GWO_SITAJU <> "1"
		Help( ,, 'HELP',, STR0009, 1, 0) //"Ajuste de Frete já foi Aprovado/Reprovado"
		lRet := .F.
	ElseIf lRet

		lCalCDoc := GFEA050CAL(GWO->GWO_NRCALC,@lEncontrou,,@lBloqueiou)


		If lBloqueiou
			Return .F.
		EndIf

		If lCalCDoc .And. _MVGFEAJDF == '1'
			Return .F.
		EndIf

		//Se estiver com situação 1 Altera o Registro de Solicitado para Aprovado
		RecLock("GWO",.F.)
		GWO->GWO_DTAPRP := DDATABASE
		GWO->GWO_HRAPRP := TIME()
		GWO->GWO_SITAJU	:= "2"
		GWO->GWO_USAPRP	:= cUserName
		MsUnLock("GWO")

		//Chama a função para Atualização de Cálculo/Movimentos do Cálculo/Rateio do Cálculo
		GFEA85ATAJ(GWO->GWO_NRCALC,GWO->GWO_VLAJUS)

		If lEncontrou
			Conferencia() //parametro igual a 2
		EndIf

	Endif

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} GFEA085REP

Função que trata a Reprovação do Ajuste feito para o cálculo

@author Jorge Matos Valcanaia
@since 11/05/10
@version 1.0
/*/
//-------------------------------------------------------------------
Function GFEA085REP()
	Local oDlg
	Local cMovRep
	If _GWONROCO .And. !Empty(GWO->GWO_NROCO) .And. FunName() != "GFEA032"
		Help( ,, 'HELP',, "O ajuste de frete está relacionado à ocorrência " + GWO->GWO_NROCO + ". Para reprová-lo, exclua ou reprove a ocorrência.", 1, 0)
		Return .F.
	EndIf
	//Se o Ajuste estiver com situação diferente de Solicitado apresenta mensagem de erro
	If GWO->GWO_SITAJU <> "1"
		Help( ,, 'HELP',, STR0009, 1, 0) //"Ajuste de Frete já foi Aprovado/Reprovado"
		Return .F.
	Else
		//Se a situação estiver como Solicitado então abre a tela para se informar o motivo da reprovação
		DEFINE MSDIALOG oDlg TITLE STR0010 From 4,0 To 16,60 OF oMainWnd //"Reprovamento Ajuste de Frete"
		@ 4, 006  SAY STR0011 SIZE 70,7 PIXEL OF oDlg //"Motivo da Reprovação:"

		oTMultiget1 := TMultiget():New(13,06,{|u|if(Pcount()>0,cMovRep:=u,cMovRep)},oDlg,225,60,,,,,,.T.)
		oTMultiget1:EnableVScroll( .T. )
		oTMultiget1:GoEnd()

		oButtonOK :=tButton():New(75,5,'OK',oDlg,{|| if(GFEA085ROK(cMovRep),oDlg:End(),NIL)},25,10,,,,.T.)
		oButtonCanc :=tButton():New(75, 35, STR0013, oDlg, {||(oDlg:End())},25,10,,,,.T.) //"Cancelar"

		ACTIVATE MSDIALOG oDlg CENTERED
	Endif
	Return

	//-------------------------------------------------------------------
	/*/{Protheus.doc} GFEA085ROK(cMovRep)

	Função do botão de OK da tela do motivo da reprovação

	@Param cMovRep -> Recebe o Motivo do Reprovamento

	@author Jorge Matos Valcanaia
	@since 11/05/10
	@version 1.0
	/*/
//-------------------------------------------------------------------
Function GFEA085ROK(cMovRep)
	//Faz validação para que se o motivo da reprovação não tenha sido informado apresente mensagem de erro
	If Empty(cMovRep)
		Help( ,, 'HELP',, STR0012, 1, 0) //"Motivo da Reprovação deve ser informado"
		Return .F.
	Else
		//Se estiver com Motivo da Reprovação então Grava os campos abaixo
		RecLock("GWO",.F.)
		GWO->GWO_DTAPRP := DDATABASE
		GWO->GWO_HRAPRP := TIME()
		GWO->GWO_SITAJU := "3"
		GWO->GWO_USAPRP := cUserName
		GWO->GWO_MOTREP := cMovRep
		MsUnLock("GWO")
	Endif
Return .T.

//-------------------------------------------------------------------
/*/{Protheus.doc} GFEA085PAR

Função do botão de parametros da tela principal do programa

@Param cMovRep -> Recebe o Motivo do Reprovamento

@author Jorge Matos Valcanaia
@since 11/05/10
@version 1.0
/*/
//-------------------------------------------------------------------
Function GFEA085PAR()
	Local cCond := ""
	Local cFiltro := ""

	//Abre o grupo de perguntas
	If !Pergunte("GFEA085",.T.)
		return
	Else
		//Utiliza os valores do pergunte para configurar o filtro.
		cHoraDe := MV_PAR06
		cHoraAte := MV_PAR07

		cHoraDe := SubStr(cHoraDe, 1, 2) + ":" + SubStr(cHoraDe, 3, 4)
		cHoraAte := SubStr(cHoraAte, 1, 2) + ":" + SubStr(cHoraAte, 3, 4)

		cFiltro := " GWO_NRROM >= '" + MV_PAR01 + "' .AND. GWO_NRROM <= '" + MV_PAR02 + "'"
		cFiltro += " .AND. GWO_DTAJUS >= STOD('" + DToS(MV_PAR04)  + "') .AND. GWO_DTAJUS <= STOD('" + DToS(MV_PAR05) + "')"
		cFiltro += " .AND. GWO_HRAJUS >= '" + cHoraDe + "' .AND. GWO_HRAJUS <= '" + cHoraAte + "'"

		If MV_PAR08 == 1
			cCond := "1"
		Elseif MV_PAR08 == 2
			cCond := "2"
		Elseif MV_PAR08 == 3
			cCond := "3"
		Elseif MV_PAR08 == 4
			cCond := "123"
		EndIf

		cFiltro += " .AND. GWO_SITAJU $ '"+cCond+"'"

		If !Empty(MV_PAR03)
			cFiltro += " .And. Lower(GWO_USRAJU) == '"+Lower(MV_PAR03)+"'"
		Endif

		//Carrega as informações do filtro no oBrowse
		oBrowse:SetFilterDefault(cFiltro)

		//Acessa a Tabela novamente e posiciona no primeiro registro
		dbSelectArea("GWO")
		dbGoTop()
	Endif
	Return

//-------------------------------------------------------------------
/*/{Protheus.doc} GFEA85ATAJ(nNrCalc,nVlAjust,nVlFret)

Função que trata o Ajuste do cálculo/movimento do cálculo/rateio do cálculo

@Param nNrCalc  ->Número do cálculo
@Param nVlAjust ->Valor Ajuste
@Param nVlFret  ->Valor Frete

@author Jorge Matos Valcanaia
@since 11/05/10
@version 1.0
/*/
//-------------------------------------------------------------------

Function GFEA85ATAJ(nNrCalc,nVlAjust)
	Local nNovoVlAjust  := 0 	// Novo Valor Ajuste
	Local nValorImp     := 0	// Valor do Imposto
	Local nPcApli       := 0    // Percentual Aplicado Valor Frete
	Local nPcApliImp    := 0 	// Percentual Aplicado Imposto
	Local nPcApliPISCOF := 0 	// Percentual Aplicado Imposto
	Local nVlFret	    := 0
	Local lAddImp	    := .F.	// Adiciona ICMS/ISS ao valor do frete
	Local lGWF		    := .T.

	//TQRCES
	nVlFrete 	 := 0
	nVlTotAj 	 := 0
	nImpValor	 := 0
	cJustIfi     := ""
	lImpEmbutido := .F.


	GWF->(dbSetOrder(1))
	If GWF->(dbSeek(xFilial("GWF") + nNrCalc))
		IF GWF->GWF_ADICIS == "1"
			lAddImp := .T.

			If GWF->GWF_IMPOST == "1"
				nValorImp := GWF->GWF_PCICMS
			ElseIf GWF->GWF_IMPOST == "2"
				nValorImp := GWF->GWF_PCISS
			EndIf
		EndIf

		If lAddImp
			nNovoVlAjust := nVlAjust / (1 - nValorImp /100)
		Else
			nNovoVlAjust := nVlAjust
		EndIf

		nVlFret := VLTOTFRET(nNrCalc)
		nPcApli	:= (nVlFret + nNovoVlAjust) / nVlFret

		RecLock("GWF", .F.)
		// ICMS/ISS
		If _GWONROCO
			// Não altera os campos dos impostos quando gera por ocorrência pois não há como restaurar os valores de impostos quando estes tornam-se 0.
			If !Empty(GWO->GWO_NROCO) 
				lGWF := .F.
			EndIf
		EndIf
		if lGWF 
			If GWF->GWF_IMPOST == "1"
				if GWF->GWF_VLICMS != 0
					nPcApliImp 		:= (GWF->GWF_BASICM + nNovoVlAjust) / GWF->GWF_BASICM
					GWF->GWF_VLICMS *= nPcApliImp
				EndIf
				GWF->GWF_BASICM += nNovoVlAjust
			ElseIf GWF->GWF_IMPOST == "2"
				If GWF->GWF_VLISS != 0
					nPcApliImp 		:= (GWF->GWF_BASISS + nNovoVlAjust) / GWF->GWF_BASISS
					GWF->GWF_VLISS *= nPcApliImp
				EndIf
				GWF->GWF_BASISS += nNovoVlAjust
			EndIf

			// PIS/COFINS
			nPcApliPISCOF	:= (GWF->GWF_BAPICO + nNovoVlAjust) / GWF->GWF_BAPICO

			If GWF->GWF_BAPICO != 0
				GWF->GWF_BAPICO += nNovoVlAjust
			EndIf

			If GWF->GWF_VLPIS != 0
				GWF->GWF_VLPIS  *= nPcApliPISCOF
			EndIf

			If GWF->GWF_VLCOFI != 0
				GWF->GWF_VLCOFI *= nPcApliPISCOF
			EndIf
		EndIf

		// Valor do Ajutes		
		GWF->GWF_VLAJUS += nNovoVlAjust
		MsUnLock("GWF")

		GFERatCal(.F.,GWF->GWF_NRCALC)
	Endif

Return
