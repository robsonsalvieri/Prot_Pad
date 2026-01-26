#INCLUDE "GFEA051.ch"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"

#DEFINE GFEA051001 'GFEA051001'
#DEFINE GFEA051002 'GFEA051002'
#DEFINE GFEA051003 'GFEA051003'
#DEFINE GFEA051004 'GFEA051004'
#DEFINE GFEA051005 'GFEA051005'
#DEFINE GFEA051006 'GFEA051006'
#DEFINE GFEA051007 'GFEA051007'
#DEFINE GFEA051008 'GFEA051008'

Static s_RENTNP := SuperGetMV("MV_RENTNP",.F.,"1")


//--------------------------------------------------------------------------------------------------- 
/*/{Protheus.doc} GFEA051
Confirmação de Entrega
Generico

@sample
GFEA051()

@author Felipe M.
@since 14/10/09
@version 1.0
/*/
//------------------------------------------------------------------------------------------------
Function GFEA051()
	Local oBrowse

	oBrowse := FWMBrowse():New()
	oBrowse:SetAlias("GWU")                        // Alias da tabela utilizada
	oBrowse:SetMenuDef("GFEA051")                  // Nome do fonte onde esta a função MenuDef
	oBrowse:SetDescription("Registro de Entregas") // Descrição do browse    //"Trechos do Documento de Carga"
	//Filtro de Trechos do Documento de Carga a pagar
	If !(s_RENTNP == "2")
		oBrowse:SetFilterDefault("GWU_PAGAR == '1' ")
	EndIf
	oBrowse:Activate()
Return(Nil)

//------------------------------------------------------------------------------------------------
Static Function MenuDef()
	Local aRotina := {}
	Local lPEXA051 := ExistBlock("GFEA0516")

	// Adiciona botões do browse
	ADD OPTION aRotina TITLE STR0002 ACTION "AxPesqui"        OPERATION 1 ACCESS 0 //"Pesquisar"
	ADD OPTION aRotina TITLE STR0003 ACTION "VIEWDEF.GFEA051" OPERATION 2 ACCESS 0 //"Visualizar"
	ADD OPTION aRotina TITLE STR0004 ACTION "GFEA051A(.T.)"   OPERATION 2 ACCESS 0 //"Documento"
	ADD OPTION aRotina TITLE STR0005 ACTION "GFEA051TL()"     OPERATION 4 ACCESS 0 //"Entrega"
	ADD OPTION aRotina TITLE STR0006 ACTION "GFEA051CL()"     OPERATION 4 ACCESS 0 //"Cancelar Entrega"
	ADD OPTION aRotina TITLE STR0007 ACTION "VIEWDEF.GFEA051" OPERATION 8 ACCESS 0 //"Imprimir"
	
	If lPEXA051
		aRotAdic := ExecBlock("GFEA0516",.F.,.F.)
		If ValType(aRotAdic) == "A"
			AEval(aRotAdic, {|x| AAdd(aRotina ,x)})
		EndIf
	EndIf

Return aRotina

//------------------------------------------------------------------------------------------------
Static Function ModelDef()
	Local oModel := Nil

	// cID     Identificador do modelo 
	// bPre    Code-Block de pre-edição do formulário de edição. Indica se a edição esta liberada
	// bPost   Code-Block de validação do formulário de edição
	// bCommit Code-Block de persistência do formulário de edição
	// bCancel Code-Block de cancelamento do formulário de edição
	oModel := MPFormModel():New("GFEA051", /*bPre*/,/*bPost*/,/*{|oModel|GFEA051C(oModel)} /*bCommit*/, /*bCancel*/)
	// cId          Identificador do modelo
	// cOwner       Identificador superior do modelo
	// oModelStruct Objeto com  a estrutura de dados
	// bPre         Code-Block de pré-edição do formulário de edição. Indica se a edição esta liberada
	// bPost        Code-Block de validação do formulário de edição
	// bLoad        Code-Block de carga dos dados do formulário de edição
	oModel:AddFields("GFEA051_GWU", Nil, FWFormStruct(1,"GWU"),/*bPre*/,/*bPost*/,/*bLoad*/)
	oModel:SetPrimaryKey({"GWU_FILIAL", "GWU_CDTPDC", "GWU_EMISDC", "GWU_SERDC", "GWU_NRDC", "GWU_SEQ"}) 
	oModel:SetDescription("Registro de Entregas")
Return oModel

///------------------------------------------------------------------------------------------------

Static Function ViewDef()
	Local oModel := FWLoadModel("GFEA051")
	Local oView  := Nil

	oView := FWFormView():New()
	// Objeto do model a se associar a view.
	oView:SetModel(oModel)
	// cFormModelID - Representa o ID criado no Model que essa FormField irá representar
	// oStruct - Objeto do model a se associar a view.
	// cLinkID - Representa o ID criado no Model ,Só é necessári o caso estamos mundando o ID no View.
	oView:AddField( "GFEA051_GWU", FWFormStruct(2, "GWU"), /*cLinkID*/ )	//
	// cID		  	Id do Box a ser utilizado 
	// nPercHeight  Valor da Altura do box( caso o lFixPixel seja .T. é a qtd de pixel exato)
	// cIdOwner 	Id do Box Vertical pai. Podemos fazer diversas criações uma dentro da outra.
	// lFixPixel	Determina que o valor passado no nPercHeight é na verdade a qtd de pixel a ser usada.
	// cIDFolder	Id da folder onde queremos criar o o box se passado esse valor, é necessário informar o cIDSheet
	// cIDSheet     Id da Sheet(Folha de dados) onde queremos criar o o box.
	oView:CreateHorizontalBox("MASTER" , 100,/*cIDOwner*/,/*lFixPixel*/,/*cIDFolder*/,/*cIDSheet*/ )
	// Associa um View a um box
	oView:SetOwnerView("GFEA051_GWU", "MASTER")
Return oView

//---------------------------------------------------------------------------------------------------
/*/{Protheus.doc} GFEA051TL
Cria a tela de cadastro
Generico

@param  oModel OBJETO MODELO

@sample
GFEA051TL(oModel)

@author Felipe M.
@since 14/10/09
@version 1.0
/*///------------------------------------------------------------------------------------------------ 
Function GFEA051TL()
	Local lContinua  := .T.
	Local oChk       := Nil
	Local oGet       := Nil
	Local oSize      := Nil
	Local cX3Rel     := Nil
	Local oDlgEnt    := Nil
	Local cAliasGW1  := Nil
	Local cGWU_DTENT := GWU->GWU_DTENT
	Local cGWU_HRENT := GWU->GWU_HRENT
	Local cGWU_EVENT := ""
	Local lChkEntr   := .F.
	Local cFilDc     := GWU->GWU_FILIAL
	Local cCDTPDC    := GWU->GWU_CDTPDC
	Local cEMISDC    := GWU->GWU_EMISDC
	Local cSERDC     := GWU->GWU_SERDC
	Local cNRDC      := GWU->GWU_NRDC
	Local aRetorno   := {}
	Local lRet       := .T.
	Local aRet       := {}

	Private cCadastro := "Registro de Entrega"

	If GFXCP12130("GWU_EVENTR")
		cGWU_EVENT := GWU->GWU_EVENTR
	EndIf

	If Empty(cGWU_HRENT)
		cX3Rel := &(GetSx3Cache("GWU_HRENT", "X3_RELACAO"))
		If !Empty(cX3Rel)
			cGWU_HRENT := cX3Rel
		EndIf
	EndIf
	
	If !Empty(GWU->GWU_DTENT)
		cAliasGW1 := GetNextAlias()
		BeginSql Alias cAliasGW1
			SELECT 1
			FROM %Table:GW1% GW1
			WHERE GW1.GW1_FILIAL = %xFilial:GWU%
			AND GW1.GW1_CDTPDC = %Exp:GWU->GWU_CDTPDC%
			AND GW1.GW1_EMISDC = %Exp:GWU->GWU_EMISDC%
			AND GW1.GW1_SERDC = %Exp:GWU->GWU_SERDC%
			AND GW1.GW1_NRDC = %Exp:GWU->GWU_NRDC%
			AND GW1.GW1_SIT = '6'
			AND GW1.%NotDel%
		EndSql
		If (cAliasGW1)->(!Eof())
			If !MsgYesNo(STR0022)	// "Este registro já contém data/hora de entrega e pertence a um documento retornado.Deseja atualizar a data/hora de entrega?"
				lContinua := .F.
			EndIf
		Else
			Alert(STR0008) //"Este registro já contém data de entrega"
			lContinua := .F.
		EndIf
		(cAliasGW1)->(dbCloseArea())
	EndIf
	If lContinua
		//Ponto de Entrada Vicunha
		If ExistBlock( "GFEA0514" )
			If !ExecBlock( "GFEA0514",.F.,.F.)
				lContinua := .F.
			EndIf
		EndIf
	EndIf

	If lContinua
		// Montagem da tela
		oSize := FWDefSize():New(.T.)
		oSize:AddObject( "ENCHOICE", 100, 20, .T., .T. ) // Adiciona enchoice
		
		oSize:SetWindowSize({000, 000, 230, 720})
		
		oSize:lLateral := .F.  // Calculo vertical	
		oSize:Process() //executa os calculos

		DEFINE MSDIALOG oDlgEnt TITLE cCadastro ;
								FROM oSize:aWindSize[1],oSize:aWindSize[2] ;
								TO oSize:aWindSize[3],oSize:aWindSize[4] ; 
								PIXEL
		oDlgEnt:lEscClose := .F.

		// ----- Criacao dos fields referente ao romaneio no painel superior da tela principal -----//
		@ 47,130 Say STR0010 COLOR CLR_BLACK Pixel Of oDlgEnt //"Data Entrega: "
		@ 45,175 MSGET cGWU_DTENT Picture "@!" When .T. /*Valid ValidDic()*/ Pixel Of oDlgEnt hasbutton 

		@ 63,130 Say STR0011 COLOR CLR_BLACK Pixel Of oDlgEnt //"Hora Entrega: "
		@ 61,175 MSGET cGWU_HRENT Picture "99:99" When .T. Valid GFE51VLDHR(cGWU_HRENT) Pixel Of oDlgEnt

		If GFXCP12130("GWU_EVENTR") .And. GFXCP12130("GWU_FLGENT")
			@ 80,108 Say "Comprovante Entrega:" COLOR CLR_BLACK Pixel Of oDlgEnt
			@ 080,175 Checkbox oChk Var lChkEntr Prompt "" Size 059,009 On Change (oDlgEnt:Refresh()) pixel Of oDlgEnt

			@ 096,110 Say "Evidencia de Entrega:" COLOR CLR_BLACK Pixel Of oDlgEnt
			@ 093,175 Get oGet Var cGWU_EVENT When lChkEntr Size 120,010 Pixel Of oDlgEnt
			@ 093,300 Button "Selecionar" Size 030,013 Pixel Of oDlgEnt Action (cGWU_EVENT := Alltrim(cGetFile("Arquivos *.*|*.*","Comprovante de Entrega")))
		EndIf

		// Fim da criacao dos fields
		// Processa os registros e carrega os browses

		ACTIVATE MSDIALOG oDlgEnt ON INIT EnchoiceBar(oDlgEnt,{|| aRet := GFEA051PV(cGWU_DTENT,cGWU_HRENT,cGWU_EVENT,lChkEntr), If(aRet[1],oDlgEnt:End(),.F.) , lContinua := .F.},;
			{||If(APMSGYESNO(STR0012),oDlgEnt:End(),), lContinua := .F.},,) CENTERED  // Deseja cancelar esse processo?
	EndIf

	If lContinua
		GFE050AUDIT(cFilDc, cCDTPDC,cEMISDC,cSERDC,cNRDC)	// Chamada de função para validação e execução de auditoria de Documento de Frete apos entrega
	EndIf

	//Ponto de Entrada
	If ExistBlock( "GFEA0517" )
		ExecBlock( "GFEA0517",.F.,.F.)
	EndIf

Return Nil

//---------------------------------------------------------------------------------------------------
/*/{Protheus.doc} GFEA051PV
Validação para registro da date de entrega
Generico

@param  cGWU_DTENT, caracter, Data de entrega
@param  cGWU_HRENT, caracter, Hora de entrega
@param  cGWU_EVENT, caracter, Evento
@param  lChkEntr, logical, .T. Indica que checa entrega - .F. Indica que não fará checagem

@sample
GFEA051PV(cGWU_DTENT,cGWU_HRENT)

@author Felipe M.
@since 14/10/09
@version 1.0
/*/
//------------------------------------------------------------------------------------------------      
Function GFEA051PV(cGWU_DTENT,cGWU_HRENT,cGWU_EVENT,lChkEntr)
	Local lRet      := .T.
	Local aAreaGWU  := GWU->(GetArea())
	Local cMensagem := ""
	Local cRet := " "
	
	Private cSeqTre := GWU->GWU_SEQ

	If cGWU_DTENT > Date()
		if isblind()
			cRet := STR0023				
		else
			GFEMessage(5,GFEA051001,STR0023,STR0024)	// "A data informada não pode ser maior que hoje." // "Informe a data novamente para prosseguir com o registro de entrega."
		endif
		lRet := .F.
	ElseIf cGWU_DTENT == Date() .And. SubStr(cGWU_HRENT, 1, 2) > SubStr(Time(), 1, 2)
		if isblind()
			cRet := STR0025
		else	
			GFEMessage(5,GFEA051002,STR0025,STR0026)	// "A hora informada não pode ser maior que a hora atual." // "Informe o horario novamente para prosseguir com o registro de entrega."
		endif
		lRet := .F.
	ElseIf cGWU_DTENT == Date() .And. SubStr(cGWU_HRENT, 1, 2) == SubStr(Time(), 1, 2) .And. SubStr(cGWU_HRENT, 4, 2) > SubStr(Time(), 4, 2)
		if isblind()
			cRet := STR0025
		else		
			GFEMessage(5,GFEA051003,STR0025,STR0026)	// "A hora informada não pode ser maior que a hora atual." // "Informe o horario novamente para prosseguir com o registro de entrega."
		Endif
		lRet := .F.
	EndIf

	If lRet .And. Empty(cGWU_HRENT)
		if isblind()
			cRet := STR0027
		else			
			GFEMessage(5,GFEA051004,STR0027,STR0026)	// "A hora de entrega é obrigatória." // "Informe o horario novamente para prosseguir com o registro de entrega."
		Endif			
		lRet := .F.
	EndIf	

	If lRet .And. !GFEA051VDE(cGWU_DTENT, cGWU_HRENT, cGWU_EVENT,lChkEntr,@cMensagem)
		if isblind()
			cRet := cMensagem
		else		
			Help(,,'HELP',,cMensagem,1,0)
		endif
		lRet := .F.
	EndIf
	
	If lRet
		if !isblind()
			// Grava o recebimento para demais entregas do mesmo calculo
			GFEA51ENTD(.T.,cGWU_DTENT,cGWU_HRENT,cGWU_EVENT,lChkEntr)
		endif
		
		// Atualiza trecho e documento de carga corrente
		GFEA51STED(cGWU_DTENT,cGWU_HRENT,cGWU_EVENT,lChkEntr)
		
		// Realiza a busca de documentos de fretes bloqueados para reauditar
		GFE051AUDIT(GWU->GWU_FILIAL, GWU->GWU_NRDC)
		
		if isblind()
			cRet := STR0028
		else		
			GFEMessage(0,GFEA051005,STR0028)	// "Registro de entrega realizado"
		Endif
	EndIf
	RestArea(aAreaGWU)

Return {lRet, cRet}
//---------------------------------------------------------------------------------------------------
/*/{Protheus.doc} GFEA051A
Visualisar Documentos de Carga
Generico

@sample
GFEA051A(lFlag)

@author Felipe M.
@since 14/10/09
@version 1.0
/*/
//------------------------------------------------------------------------------------------------       
Function GFEA051A(lFlag)
	Local cAliasGW1 := Nil
	Local aAreaGW1  := GW1->(GetArea())

	If lFlag
		cAliasGW1 := GetNextAlias()
		BeginSql Alias cAliasGW1
			SELECT GW1.R_E_C_N_O_ RECNOGW1
			FROM %Table:GW1% GW1
			WHERE GW1.GW1_FILIAL = %xFilial:GWU%
			AND GW1.GW1_CDTPDC = %Exp:GWU->GWU_CDTPDC%
			AND GW1.GW1_EMISDC = %Exp:GWU->GWU_EMISDC%
			AND GW1.GW1_SERDC = %Exp:GWU->GWU_SERDC%
			AND GW1.GW1_NRDC = %Exp:GWU->GWU_NRDC%
			AND GW1.%NotDel%
		EndSql
		If (cAliasGW1)->(!Eof())
			GW1->(dbGoTo((cAliasGW1)->RECNOGW1))
			FWExecView("",'GFEA044',1,,{||.T.})
		EndIf
		(cAliasGW1)->(dbCloseArea())
	EndIf
	RestArea(aAreaGW1)
Return .T.

/*------------------------------------------------------------------------------
{Protheus.doc} GFEA051CL
Cancelar entrega
Generico

@sample
GFEA051CL()

@author Felipe M.
@since 14/10/09
@version 1.0
------------------------------------------------------------------------------*/
Function GFEA051CL()
	Local lRet      := .T.
	Local aAreaGWU  := GWL->(GetArea())
	Local cMensagem := ""

	If MsgNoYes("Deseja cancelar a entrega deste trecho?", "Cancelamento")
		cAliasGV5 := GetNextAlias()
		BeginSql Alias cAliasGV5
			SELECT 1
			FROM %Table:GV5% GV5
			WHERE GV5.GV5_FILIAL = %xFilial:GV5%
			AND GV5.GV5_CDTPDC = %Exp:GWU->GWU_CDTPDC%
			AND GV5.%NotDel%
		EndSql
		If (cAliasGV5)->(!Eof())
			If Empty(GWU->GWU_DTENT) .And. Empty(GWU->GWU_HRENT)
				GFEMessage(5,GFEA051006,STR0019,STR0029) // "Registro não contém Data de Entrega cadastrado." // "Selecione um trecho com data de entrega cadastrada."
				lRet := .F.
			EndIf

			If lRet .And. !GFEA051VDC(@cMensagem)
				Help(,,'HELP',,cMensagem,1,0)
				lRet := .F.
			EndIf
			If lRet
				// Grava o recebimento/Cancelamento para demais entregas do mesmo calculo
				if !isblind()
					GFEA51ENTD(.F.)
				Endif
				GFEA51STEN()
			EndIf
		EndIf
		(cAliasGV5)->(dbCloseArea())

		If lRet
			GFE051AUDIT(GWU->GWU_FILIAL, GWU->GWU_NRDC)
			GFEMessage(0,GFEA051007,STR0020) //"Registro de Entrega cancelado."
		EndIf
	EndIf

	//Ponto de Entrada
	If lRet
		If ExistBlock( "GFEA0518" )
			ExecBlock( "GFEA0518",.F.,.F.)
		EndIf
	EndIf

	RestArea(aAreaGWU)
Return lRet

// Utiliza o documento de carga posicionado como referencia.
Function GFE51IENT()
	Local aAreaGWU  := GWU->(GetArea())
	Local cChaveGW1 := GW1->GW1_FILIAL + GW1->GW1_CDTPDC + GW1->GW1_EMISDC + GW1->GW1_SERDC + GW1->GW1_NRDC
	Local aAreaSX5  := SX5->(GetArea())
	Local dDtEntr   := CTOD("  /  /    ")
	Local cFilAtu   := cFilAnt
	Local cDtIntFat := SuperGetMV("MV_GFEI20", .F., "2")
	Local cNrDc     := ""
	Local cAliasQry := ""
	Local cQuery    := ""
	Local aCliSF2   := {}
	Local nX        := 0
	Local cStrOr    := ""

	GV5->(DbsetOrder(1))
	GV5->(DbSeek(xFilial("GV5") + GW1->GW1_CDTPDC))

	cFilAnt := GW1->GW1_FILIAL
	
	If GW1->GW1_SIT $ "4;5;6"/*Embarcado, entregue ou retornado*/;
		.And. GW1->GW1_ORIGEM = "2"/*origem erp*/;
		.And. GV5->GV5_SENTID $ "0;2;3"/*Indiferente; saída ou externo*/;
		.And. SuperGetMv("MV_INTGFE",.F.,.F.)/*Integração com GFE*/;
		.And. SuperGetMv("MV_INTGFE2",.F.,"2") == "1" .And. SuperGetMv("MV_ERPGFE",.F.,"1") == "2"/*Integração direta com protheus*/;
		.And. SuperGetMv("MV_GFEIDTE",.F.,.F.)
		
		// Ultimo Trecho Pago
		If GW1->GW1_SIT $ "5;6"
			GWU->(DbSetOrder(1))
			GWU->(DbSeek(cChaveGW1))
			While !GWU->(Eof()) .And. GWU->GWU_FILIAL + GWU->GWU_CDTPDC + GWU->GWU_EMISDC + GWU->GWU_SERDC + GWU->GWU_NRDC == cChaveGW1
				If GWU->GWU_PAGAR == "1" 
					dDtEntr := GWU->GWU_DTENT //último trecho pago
				EndIf 
				GWU->(dbSkip())
			EndDo
		EndIf
		
		cNrDc := PadR(GW1->GW1_NRDC,TamSx3("F2_DOC")[1])
		cSrDc := PadR(GW1->GW1_SERDC,TamSx3("F2_SERIE")[1])

		// quando for Numeração própria, o código está no cadastro da GU3
		If SuperGetMv("MV_EMITMP",.F.,"1") == "1" 
			GU3->(DbSetOrder(1))
			GU3->(dbSeek(xFilial("GU3") + GW1->GW1_CDDEST))
			Aadd(aCliSF2,{GU3->GU3_CDERP,GU3->GU3_CDCERP})
		Else
			// LOCALIZA O REGISTRO PELO DANFE
			cAliasQry := GetNextAlias()
			cQuery := " SELECT F2_FILIAL, F2_CLIENTE, F2_LOJA, R_E_C_N_O_ "
			cQuery += " FROM " + RetSqlName('SF2') + " SF2 "
			cQuery += " WHERE SF2.F2_FILIAL = '" + xFilial("SF2") + "'" 
			cQuery += " AND SF2.F2_CHVNFE  = '" + GW1->GW1_DANFE + "'"
			cQuery += " AND SF2.D_E_L_E_T_  = ' ' "
			cQuery := ChangeQuery( cQuery )
			dbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery),cAliasQry, .F., .T.)
			
			If !Empty(GW1->GW1_DANFE) .AND. (cAliasQry)->(!Eof())
				Aadd(aCliSF2,{(cAliasQry)->F2_CLIENTE, (cAliasQry)->F2_LOJA})
				(cAliasQry)->( dbCloseArea() )
			Else
				(cAliasQry)->( dbCloseArea() )
				
				GU3->(DbSetOrder(1))
				GU3->(dbSeek(xFilial("GU3") + GW1->GW1_CDDEST))

				SA1->(DbSetOrder(3)) // Filial + cgc
				SA1->(dbSeek(xFilial("SA1") + GU3->GU3_IDFED))
				If !SA1->(Eof())
					Aadd(aCliSF2,{SA1->A1_COD, SA1->A1_LOJA})
				EndIf
				SA2->(DbSetOrder(3)) // Filial + cgc
				SA2->(dbSeek(xFilial("SA2") + GU3->GU3_IDFED))
				If !SA2->(Eof())
					Aadd(aCliSF2,{SA2->A2_COD, SA2->A2_LOJA})
				EndIf
			EndIf
		EndIf

		cStrOr := ''
		cAliasQry := GetNextAlias()
		cQuery := " SELECT R_E_C_N_O_ "
		cQuery += " FROM " + RetSqlName('SF2') + " SF2 "
		cQuery += " WHERE SF2.F2_FILIAL = '" + xFilial("SF2") + "'"
		cQuery += " AND SF2.F2_EMISSAO = '" + DtoS(GW1->GW1_DTEMIS) + "'"
		cQuery += " AND ( "
		for nX:= 1 to Len(aCliSF2)
			cQuery += cStrOr + " ( SF2.F2_DOC       = '" + cNrDc + "'"
			cQuery += " AND SF2.F2_SERIE   = '" + cSrDc + "'"
			cQuery += " AND SF2.F2_CLIENTE = '" + aCliSF2[nX,1] + "'"
			cQuery += " AND SF2.F2_LOJA    = '" + aCliSF2[nX,2] + "'"
			cQuery += " ) " 
			cStrOr := ' OR '
		next
		cQuery += " )"
		cQuery += " AND SF2.D_E_L_E_T_ = ' ' "

		cQuery := ChangeQuery( cQuery )
		dbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery),cAliasQry, .F., .T.)
		
		while ((cAliasQry)->(!Eof()))
			SF2->(dbGoTo((cAliasQry)->R_E_C_N_O_))
			//Garante que outro processo já não tenha gravado a informação
			If (GW1->GW1_SIT $ "5;6" .And. Empty(SF2->F2_DTENTR)) .Or.  (GW1->GW1_SIT == "4" .And. !Empty(SF2->F2_DTENTR))
				RecLock("SF2",.F.)
					SF2->F2_DTENTR := dDtEntr
				SF2->(MsUnlock())
				Exit
			EndIf
			(cAliasQry)->(DbSkip())
		EndDo
		(cAliasQry)->(DbCloseArea())

	EndIf
	
	// SAMSUNG - INI
	// Atualizar o campo GW1_SITFT2 para '2=pendente' quando o último trecho do itinerário receber a data de entrega
	If SuperGetMv("MV_ERPGFE",.F.,"1") == "1" 

		If GW1->GW1_SIT $ "5;6" /*entregue ou retornado*/
					
			// Na criação do registro da GW1 - Atribui ao campo GW1_SITFT2 o valor 1 (Não enviado)
			If cDtIntFat == '1'
				If GFEVerCmpo({"GW1_SITFT2"})
					RecLock("GW1",.F.)
						GW1->GW1_SITFT2 := '2'	/* Pendente */ // FWFldGet("MV_GFEI20") = '1=Automática': 2 (Pendente) Quando ocorrer o registro de entrega para o último trecho e a situação do documento de carga for alterada para 'Entregue' (GW1_SIT = 5) - Atribui ao campo GW1_SITFT2 o valor 2 (Pendente)
					GW1->(MsUnlock())
					// GW1_SITFT2 = (1=Nao Enviado;2=Pendente;3=Rejeitado;4=Atualizado;5=Pendente Desatualizacao;6=Nao se Aplica)
				EndIf
			ElseIf cDtIntFat == '2'
				If GFEVerCmpo({"GW1_SITFT2"})
					RecLock("GW1",.F.) 
						GW1->GW1_SITFT2 := '6'	/* Não se aplica */ // FWFldGet("MV_GFEI20") = '2=Não integrar': Atribui ao campo GW1_SITFT2 o valor 6 (Não se aplica). 
					GW1->(MsUnlock())
				EndIf
			EndIf
		Else	
			If cDtIntFat == '1' 	// No cancelamento da ocorrência de entrega, GW1_SITFT2 = '5=Pendente Desatualização' para que ocorra a eliminação da data na nota fiscal do faturamento.
				If GFEVerCmpo({"GW1_SITFT2"})
			     	RecLock("GW1",.F.) 
				 		GW1->GW1_SITFT2 := '5' // Pendente de Desatualização
				 	GW1->(MsUnlock())
			  	EndIf
			Else
			  	If GFEVerCmpo({"GW1_SITFT2"})
					RecLock("GW1",.F.) 
				 		GW1->GW1_SITFT2 := '6'	/* Não se aplica */ // FWFldGet("MV_GFEI20") = '2=Não integrar': Atribui ao campo GW1_SITFT2 o valor 6 (Não se aplica). 
				 	GW1->(MsUnlock())
			  	EndIf
			EndIf
		EndIf
	EndIf
	// SAMSUNG - FIM
	
	RestArea(aAreaGWU)
	RestArea(aAreaSX5)
	cFilAnt := cFilAtu
Return

/*
{Protheus.doc}
GFEVLDHR()

Função para validar a hora informada em valid de campos, pois, cria mensagem de help.

Parâmetros: Recebe uma hora no formato "08:30" ou "0830"

@author Octávio Augusto Felippe de Macedo
@since 21/02/2011
@version 1.0
*/
Function GFE51VLDHR(cHr)
	Local lRet := .T.

	If At(":", cHr) > 0
		cHr := AllTrim(StrTran(cHr, ":", ""))
	EndIf
	
	If !Empty(cHr)
		If (!(SubStr(cHr,1,2) <= "23" .And. SubStr(cHr,1,2) >= "00" .And. SubStr(cHr,3,2) <= "59" .And. SubStr(cHr,3,2) >= "00") .Or. ;
			Len(AllTrim(cHr)) < 4 .Or. Len(AllTrim(SubStr(cHr,1,2))) != 2 .Or. Len(AllTrim(SubStr(cHr,3,2))) != 2)
			
			GFEMessage(5,GFEA051008,STR0030,STR0031) // "Hora inválida". // "Informe uma hora válida para continuar."
			lRet := .F.
		EndIf
	EndIf
Return lRet

//---------------------------------------------------------------------------------------------------
Function GFEA51ANT(cDtEnt, cHrEnt, cMensagem)
	Local lRet      := .T.
	Local cAliasGWU := Nil

	cMensagem := ""
	cAliasGWU := GetNextAlias()
	BeginSql Alias cAliasGWU
		SELECT GWU.GWU_SEQ,
				GWU.GWU_DTENT,
				GWU.GWU_HRENT
		FROM %Table:GWU% GWU
		WHERE GWU.GWU_FILIAL = %xFilial:GWU%
		AND GWU.GWU_CDTPDC = %Exp:GWU->GWU_CDTPDC%
		AND GWU.GWU_EMISDC = %Exp:GWU->GWU_EMISDC%
		AND GWU.GWU_SERDC = %Exp:GWU->GWU_SERDC%
		AND GWU.GWU_NRDC = %Exp:GWU->GWU_NRDC%
		AND GWU.%NotDel%
	EndSql
	Do While lRet .And. (cAliasGWU)->(!Eof())
		If !Empty((cAliasGWU)->GWU_DTENT) .And. (cAliasGWU)->GWU_SEQ > GWU->GWU_SEQ
			If (cAliasGWU)->GWU_DTENT < cDtEnt
				cMensagem := "A data/hora deve ser menor que a data/hora do Trecho Anterior."
				lRet := .F.
			ElseIf (cAliasGWU)->GWU_DTENT == cDtEnt .And. (cAliasGWU)->GWU_HRENT < cHrEnt
				cMensagem := "A data/hora deve ser menor que a data/hora do Trecho Anterior."
				lRet := .F.
			EndIf
		ElseIf !Empty((cAliasGWU)->GWU_DTENT) .And. (cAliasGWU)->GWU_SEQ < GWU->GWU_SEQ
			If (cAliasGWU)->GWU_DTENT > cDtEnt
				cMensagem := "A data/hora deve ser maior que a data/hora do Trecho Anterior."
				lRet := .F.
			ElseIf (cAliasGWU)->GWU_DTENT == cDtEnt .And. (cAliasGWU)->GWU_HRENT > cHrEnt
				cMensagem := "A data/hora deve ser maior que a data/hora do Trecho Anterior."
				lRet := .F.
			EndIf
		EndIf
		(cAliasGWU)->( dbSkip() )
	EndDo
	(cAliasGWU)->(dbCloseArea())
Return lRet

// Função para efetivar/cancelar o registro de entrega dos demais documentos relacionados ao documento selecionado
Function GFEA51ENTD(lConfirma,cGWU_DTENT,cGWU_HRENT,cGWU_EVENT,lChkEntr)
	Local lRet         := .T.
	Local lContinua    := .T.
	Local aAreaGWU     := GWU->(GetArea())
	Local cMensagem    := ""
	Local cGWUAlias    := GetNextAlias()

	Default lConfirma  := .T.
	Default cGWU_DTENT := CToD(" / / ")
	Default cGWU_HRENT := ""
	Default cGWU_EVENT := ""
	Default lChkEntr   := .F.

	// Verificva se existe outros documentos com mesmo calculo
	BeginSql Alias cGWUAlias
		SELECT GWU.R_E_C_N_O_ RECNOGWU
		FROM %Table:GWH% GWH
		INNER JOIN %Table:GWF% GWF
		ON GWF.GWF_FILIAL = %xFilial:GWF%
		AND GWF.GWF_NRCALC = GWH.GWH_NRCALC
		AND GWF.GWF_TPCALC = '1'
		AND GWF.%NotDel%
		INNER JOIN %Table:GWU% GWU
		ON GWU.GWU_FILIAL = %xFilial:GWU%
		AND GWU.GWU_CDTPDC = GWH.GWH_CDTPDC
		AND GWU.GWU_EMISDC = GWH.GWH_EMISDC
		AND GWU.GWU_SERDC = GWH.GWH_SERDC
		AND GWU.GWU_NRDC = GWH.GWH_NRDC
		AND GWU.GWU_SEQ = GWH.GWH_TRECHO
		AND GWU.GWU_CDTRP = %Exp:GWU->GWU_CDTRP%
		AND GWU.%NotDel%
		WHERE GWH.GWH_FILIAL = %xFilial:GWH%
		AND EXISTS( SELECT 1
					FROM %Table:GWH% GWH1
					WHERE GWH1.GWH_FILIAL = %xFilial:GWH%
					AND GWH1.GWH_CDTPDC = %Exp:GWU->GWU_CDTPDC%
					AND GWH1.GWH_EMISDC = %Exp:GWU->GWU_EMISDC%
					AND GWH1.GWH_SERDC = %Exp:GWU->GWU_SERDC%
					AND GWH1.GWH_NRDC = %Exp:GWU->GWU_NRDC%
					AND GWH1.GWH_TRECHO = %Exp:GWU->GWU_SEQ%
					AND GWH1.GWH_NRCALC = GWH.GWH_NRCALC
					AND GWH1.D_E_L_E_T_ = ' ')
		AND (GWH.GWH_CDTPDC <> %Exp:GWU->GWU_CDTPDC%
			OR GWH.GWH_EMISDC <> %Exp:GWU->GWU_EMISDC%
			OR GWH.GWH_SERDC <> %Exp:GWU->GWU_SERDC%
			OR GWH.GWH_NRDC <> %Exp:GWU->GWU_NRDC%
			OR GWH.GWH_TRECHO <> %Exp:GWU->GWU_SEQ%)
		AND GWH.%NotDel%
	EndSql
	TcSetField(cGWUAlias,"GWU_DTENT","D",8,0)
	If (cGWUAlias)->(!Eof())
		lContinua := GFEA051BW(cGWUAlias,lConfirma,cGWU_DTENT, cGWU_HRENT, cGWU_EVENT,lChkEntr)
		If lContinua
			(cGWUAlias)->(dbGoTop())
			Do While (cGWUAlias)->(!Eof())
				GWU->(dbGoTo((cGWUAlias)->RECNOGWU))
				If lConfirma
					If GFEA051VDE(cGWU_DTENT, cGWU_HRENT, cGWU_EVENT,lChkEntr,@cMensagem)
						// Atualiza trecho e documento de carga corrente
						GFEA51STED(cGWU_DTENT,cGWU_HRENT,cGWU_EVENT,lChkEntr)
					EndIf
				Else
					If GFEA051VDC(@cMensagem)
						// Atualiza trecho e documento de carga corrente
						GFEA51STEN()
					EndIf
				EndIf
				(cGWUAlias)->(dbSkip())
			EndDo
			// Verifica se há Documentos de Frete bloqueados relacionados e executa a rotina de auditoria de frete
			If lConfirma
				GFE051AUDIT(GWU->GWU_FILIAL, GWU->GWU_NRDC)
			EndIf
		EndIf
	EndIf

	(cGWUAlias)->(dbCloseArea())
	RestArea(aAreaGWU)
RETURN lRet

//---------------------------------------------------------------------------------------------------
/*/{Protheus.doc} GFEA51STEN
Atualiza dados do documento de carga, trecho e romaneio no cancelamento da entrega
@type  Function
@Squad GFE
@since 27/05/2020
@version 1.0
/*/
//---------------------------------------------------------------------------------------------------
Function GFEA51STEN()
	Local cRecPrz := SuperGetMV("MV_RECPRZ", .F., "0")
	Local dDtAnt  := GWU->GWU_DTENT
	Local cHrAnt  := GWU->GWU_HRENT

	RecLock ("GWU", .F.)
		GWU->GWU_DTENT  := CToD(" / / ")
		GWU->GWU_HRENT  := ""
		If GFXCP12130("GWU_EVENTR") .And. GFXCP12130("GWU_FLGENT")
			GWU->GWU_EVENTR := ""
			GWU->GWU_FLGENT := .F.
		EndIf
	GWU->(MsUnlock())

	If cRecPrz == "1"
		If GWU->GWU_DTPENT < dDtAnt .Or. (GWU->GWU_DTPENT == dDtAnt .And. GWU->GWU_HRPENT < cHrAnt)
			RecPrzTrec( GWU->(Recno()), GWU->GWU_DTPENT, GWU->GWU_HRPENT)
		ENDIF
	ElseIf cRecPrz == "2"
		RecPrzTrec( GWU->(Recno()), GWU->GWU_DTPENT, GWU->GWU_HRPENT)
	EndIf

	//Ponto de Entrada
	If ExistBlock( "GFEA0512" )
		ExecBlock( "GFEA0512",.F.,.F.)
	EndIf
	//Ponto de Entrada
	If ExistBlock( "GFEA0515" )
		ExecBlock( "GFEA0515",.F.,.F.,{1})
	EndIf
	dbSelectArea("GW1")
	GW1->( dbSetOrder(1) )
	If GW1->( dbSeek(GWU->GWU_FILIAL + GWU->GWU_CDTPDC + GWU->GWU_EMISDC + GWU->GWU_SERDC + GWU->GWU_NRDC) )
		If GW1->GW1_SIT == "5"
			RecLock ("GW1", .F.)
				If !EMPTY( GW1->GW1_NRROM ) 
					GW1->GW1_SIT := "4"
				Else
					GW1->GW1_SIT := "1"
				EndIf
			GW1->(MsUnlock())
			GFE51IENT() // Integra a data de entrega do último trecho pago com a nota de saída do protheus.
			GWN->( dbSetOrder(1) )
			If GWN->( dbSeek(GW1->GW1_FILIAL + GW1->GW1_NRROM) )
				If GWN->GWN_SIT == "4"
					RecLock("GWN", .F.)
						GWN->GWN_SIT := "3"
					GWN->(MsUnlock())
				EndIf
			EndIf
		EndIf
	EndIf
Return Nil

//---------------------------------------------------------------------------------------------------
/*/{Protheus.doc} GFEA51STED
Atualiza dados do documento de carga, trecho e romaneio na confirmação da entrega
@type  Function
@Squad GFE
@since 27/05/2020
@version 1.0
@param cGWU_DTENT, caracter, Data Entrega
@param cGWU_HRENT, caracter, Hora Entrega
@param cGWU_EVENT, caracter, Evento da entrega
@param lChkEntr, logical, Indica se necessita de confirmação de entrega

/*/
//---------------------------------------------------------------------------------------------------
Function GFEA51STED(cGWU_DTENT,cGWU_HRENT,cGWU_EVENT,lChkEntr)
	Local cWhere    := " AND GWU.D_E_L_E_T_=' '"
	Local aAreaGWU  := GWU->(GetArea())
	Local cAliasGWN := Nil
	Local cAliasGW1 := Nil
	Local cNrRom    := Posicione("GW1",1,GWU->(GWu_FILIAL+GWU_CDTPDC+GWU_EMISDC+GWU_SERDC+GWU_NRDC),"GW1_NRROM")
	Local cRecPrz	:= SuperGetMV("MV_RECPRZ", .F., "0")

	// Atualiza os dados da entrega
	RecLock ("GWU", .F.)
		GWU->GWU_DTENT  := cGWU_DTENT
		GWU->GWU_HRENT  := cGWU_HRENT
		If GFXCP12130("GWU_EVENTR") .And. GFXCP12130("GWU_FLGENT")
			GWU->GWU_EVENTR := cGWU_EVENT
			GWU->GWU_FLGENT := lChkEntr
		EndIf
	GWU->(MsUnlock())

	// -----------------------------------------------------------------------------------------
	// Verifica se existe mais de 1 trecho para atualizar prazo de entrega dos demais trechos
	// -----------------------------------------------------------------------------------------
	If GWU->GWU_DTPENT <> cGWU_DTENT .Or. GWU->GWU_HRPENT <> cGWU_HRENT
		If cRecPrz == "1"
			If GWU->GWU_DTPENT < cGWU_DTENT .Or. (GWU->GWU_DTPENT == cGWU_DTENT .And. GWU->GWU_HRPENT < cGWU_HRENT)
				RecPrzTrec( GWU->(Recno()), cGWU_DTENT, cGWU_HRENT)
			EndIf
		ElseIf cRecPrz == "2"
			RecPrzTrec( GWU->(Recno()), cGWU_DTENT, cGWU_HRENT)
		EndIf
	EndIf

	//Ponto de Entrada
	If ExistBlock( "GFEA0511" )
		ExecBlock( "GFEA0511",.F.,.F.)
	EndIf
	//Ponto de Entrada Vicunha
	If ExistBlock( "GFEA0513" )
		ExecBlock( "GFEA0513",.F.,.F.,{cGWU_DTENT,cGWU_HRENT,1})
	EndIf

	If Alltrim(s_RENTNP) == "1"
		cWhere := " AND GWU.GWU_PAGAR = '1'" + cWhere
	EndIf
	cWhere := "%" + cWhere + "%"

	//Se for o ultimo trecho, documento ficara setado com "entregue"
	cAliasGW1 := GetNextAlias()
	BeginSql Alias cAliasGW1
		SELECT GW1.R_E_C_N_O_ RECNOGW1
		FROM %Table:GW1% GW1
		WHERE GW1.GW1_FILIAL = %xFilial:GW1%
		AND GW1.GW1_CDTPDC = %Exp:GWU->GWU_CDTPDC%
		AND GW1.GW1_EMISDC = %Exp:GWU->GWU_EMISDC%
		AND GW1.GW1_SERDC = %Exp:GWU->GWU_SERDC%
		AND GW1.GW1_NRDC = %Exp:GWU->GWU_NRDC%
		AND GW1.GW1_SIT <> '6'
		AND NOT EXISTS( SELECT 1
						FROM %Table:GWU% GWU
						WHERE GWU.GWU_FILIAL = %xFilial:GWU%
						AND GWU.GWU_CDTPDC = GW1.GW1_CDTPDC
						AND GWU.GWU_EMISDC = GW1.GW1_EMISDC
						AND GWU.GWU_SERDC = GW1.GW1_SERDC
						AND GWU.GWU_NRDC = GW1.GW1_NRDC
						AND GWU.GWU_DTENT = ' '
						%Exp:cWhere%
						)
		AND GW1.%NotDel%
	EndSql
	If (cAliasGW1)->(!Eof())
		// Atualiza status do documento de carga
		GW1->(dbGoTo((cAliasGW1)->RECNOGW1))
		RecLock ("GW1", .F.)
			GW1->GW1_SIT := '5'
		GW1->(MsUnlock())
		// Integra a data de entrega do último trecho pago com a nota de saída do protheus.
		GFE51IENT()
	EndIf
	(cAliasGW1)->(dbCloseArea())
	// Atualiza status do romaneio de carga
	cAliasGWN := GetNextAlias()
	BeginSql Alias cAliasGWN
		SELECT GWN.R_E_C_N_O_ RECNOGWN
		FROM %Table:GWN% GWN
		WHERE GWN.GWN_FILIAL = %xFilial:GWN%
		AND GWN.GWN_NRROM = %Exp:cNrRom%
		AND NOT EXISTS( SELECT 1
						FROM %Table:GW1% GW1
						WHERE GW1.GW1_FILIAL = %xFilial:GW1%
						AND GW1.GW1_NRROM = GWN.GWN_NRROM
						AND GW1.GW1_SIT NOT IN ('5','6')
						AND GW1.%NotDel%)
		AND GWN.%NotDel%
	EndSql
	If (cAliasGWN)->(!Eof())
		GWN->(dbGoTo((cAliasGWN)->RECNOGWN))
		RecLock("GWN", .F.)
			GWN->GWN_SIT := '4'
		GWN->(MsUnlock())
	EndIf
	(cAliasGWN)->(dbCloseArea())
	RestArea(aAreaGWU)
Return Nil

/* Função para verificar se há Documento(s) de Frete relacionado(s) ao Documento de Carga 
na situação bloqueado e, se houver, executar a rotina de auditoria de frete */
Function GFE051AUDIT(cFilDC, nNrDC, lmsg)
	Local cRet      := ""
	Local aAreaGW3  := GW3->(GetArea())
	Local aAreaGW1  := GW1->(GetArea())
	Local cAliasQry := GetNextAlias()

	Default lmsg := .T.

	BeginSql Alias cAliasQry
		SELECT GW3.R_E_C_N_O_ RECNOGW3
		FROM %Table:GW1% GW1
		INNER JOIN %Table:GW4% GW4
		ON GW4.GW4_FILIAL = GW1.GW1_FILIAL
		AND GW4.GW4_EMISDC = GW1.GW1_EMISDC
		AND GW4.GW4_SERDC = GW1.GW1_SERDC
		AND GW4.GW4_NRDC = GW1.GW1_NRDC
		AND GW4.GW4_TPDC = GW1.GW1_CDTPDC
		AND GW4.%NotDel%
		INNER JOIN %Table:GW3% GW3
		ON GW3.GW3_FILIAL = GW4.GW4_FILIAL
		AND GW3.GW3_CDESP = GW4.GW4_CDESP
		AND GW3.GW3_EMISDF = GW4.GW4_EMISDF
		AND GW3.GW3_SERDF = GW4.GW4_SERDF
		AND GW3.GW3_NRDF = GW4.GW4_NRDF
		AND GW3.GW3_DTEMIS = GW4.GW4_DTEMIS
		AND GW3.GW3_TPDF IN ('1','4','5','6','7')
		AND GW3.%NotDel%
		WHERE GW4.GW4_FILIAL = %Exp:cFilDC%
		AND GW4.GW4_NRDC = %Exp:nNrDC%
		AND GW4.%NotDel%
		ORDER BY %Order:GW3%
	EndSql
	Do While (cAliasQry)->(!Eof())
		GW3->( dbGoTo( (cAliasQry)->RECNOGW3 ) )
		cRet := GFE50DFCONF(lmsg)
		(cAliasQry)->(dbSkip())
	EndDo
	(cAliasQry)->(dbCloseArea())

	RestArea(aAreaGW3)
	RestArea(aAreaGW1)
Return cRet

//---------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} GFEA051VDE
Validações quando registro de data de entrega
@type  Function
@author Squad GFE
@since 28/05/2020
@version 1.0
@param cGWU_DTENT, caracter, data de entrega informada
@param cGWU_HRENT, caracter, hora de entrega informada
@param cGWU_DTENT, caracter, data de entrega informada
@param cGWU_EVENT, caracter, Evento da entrega
@param lChkEntr, logical, Indica se necessita de confirmação de entrega
@param cMensagem, caracter, Recebe a mensagem de erro quando ocorrer
@return lRet, logical, .T. com sucesso - .F. houve problema
@example
(examples)
@see (links_or_references)
/*/
//---------------------------------------------------------------------------------------------------------
Function GFEA051VDE(cGWU_DTENT, cGWU_HRENT, cGWU_EVENT,lChkEntr,cMensagem)
	Local lRet      := .T.
	Local cAliasGW1 := Nil

	Default lconfirma := .T.

	cMensagem := ""
	// Validações para quando registrar
	If !GFEA51ANT(DToS(cGWU_DTENT),cGWU_HRENT,@cMensagem)
		lRet := .F.
	EndIf
	
	If lRet
		cAliasGW1 := GetNextAlias()
		BeginSql Alias cAliasGW1
			SELECT GW1.GW1_NRROM,
					GW1.GW1_SIT,
					GW1.GW1_CDTPDC,
					GW1.GW1_DTEMIS,
					GW1.GW1_DTSAI,
					GW1.GW1_HRSAI,
					GV5.GV5_SENTID
			FROM %Table:GW1% GW1
			INNER JOIN %Table:GV5% GV5
			ON GV5.GV5_FILIAL = %xFilial:GV5%
			AND GV5.GV5_CDTPDC = GW1.GW1_CDTPDC
			WHERE GW1.GW1_FILIAL = %xFilial:GW1%
			AND GW1.GW1_CDTPDC = %Exp:GWU->GWU_CDTPDC%
			AND GW1.GW1_EMISDC = %Exp:GWU->GWU_EMISDC%
			AND GW1.GW1_SERDC = %Exp:GWU->GWU_SERDC%
			AND GW1.GW1_NRDC = %Exp:GWU->GWU_NRDC%
			AND GW1.%NotDel%
		EndSql
		TcSetField(cAliasGW1,"GW1_DTEMIS","D",8,0)
		TcSetField(cAliasGW1,"GW1_DTSAI","D",8,0)
		If (cAliasGW1)->(!Eof())
			If (cAliasGW1)->GW1_SIT == "8"
				cMensagem := STR0015 // Não é permitido atribuir entrega a trechos relacionados a documentos de carga na situação Sinistrado
				lRet := .F.
			EndIf
			// Permitir informar os dados da confirmação de entrega apenas para Documentos de Carga de tipos de documento com sentido "Saída" ou "Externo" 
			If lRet .And. (cAliasGW1)->GV5_SENTID $ "4"
				cMensagem := "informar os dados da confirmação de entrega apenas para Documentos de Carga de tipos de documento com sentido 'Indiferente', 'Saída' ou 'Externo'"
				lRet := .F.
			EndIf
			// Permitir informar apenas uma data/hora maior que a data/hora de emissão do Documento de Carga do trecho
			If lRet .And. cGWU_DTENT < (cAliasGW1)->GW1_DTEMIS
				cMensagem := "A data deve ser maior ou igual que a data de emissão do Documento de Carga do trecho" // A data deve ser maior que a data de emissão do Documento de Carga do trecho
				lRet := .F.
			EndIf
			
			// Permitir informar apenas uma data/hora maior que a data/hora de liberação do Romaneio de Cargas do trecho quando o Documento de Cargas estiver relacionado a um Romaneio.
			If lRet
				If Empty((cAliasGW1)->GW1_DTSAI) .And. Empty((cAliasGW1)->GW1_HRSAI)
					cMensagem := STR0021 // Não há data de saída no Documento de Carga deste trecho. Verifique se o Documento de Carga possui Romaneio com situação 'liberado'.
					lRet := .F.
				ElseIf (cGWU_DTENT < (cAliasGW1)->GW1_DTSAI) .Or. ((cGWU_DTENT == (cAliasGW1)->GW1_DTSAI .And. cGWU_HRENT <= (cAliasGW1)->GW1_HRSAI))
					cMensagem := STR0018 // A data e hora informadas devem ser maior que a data/hora de saída do documento de carga.
					lRet := .F.
				EndIf
			EndIf
		EndIf
		(cAliasGW1)->(dbCloseArea())
	EndIf
Return lRet

//---------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} GFEA051VDC
Validações quando cancelamento de entrega
@type  Function
@author Squad GFE
@since 28/05/2020
@version 1.0
@return lRet, logical, .T. com sucesso - .F. houve problema
@example
(examples)
@see (links_or_references)
/*/
//---------------------------------------------------------------------------------------------------------
Function GFEA051VDC(cMensagem)
	Local lRet      := .T.
	Local cAliasGWD := Nil

	cMensagem := ""
	//Verifica se há alguma ocorrência de registro de entrega para a mesma transportadora
	cAliasGWD := GetNextAlias()
	BeginSql Alias cAliasGWD
		SELECT GWD.GWD_NROCO,
				GU5.GU5_EVENTO,
				GU5.GU5_TPCALC,
				GU5.GU5_DEVTOT
		FROM %Table:GWL% GWL
		INNER JOIN %Table:GWD% GWD
		ON GWD.GWD_FILIAL = GWL.GWL_FILIAL
		AND GWD.GWD_NROCO = GWL.GWL_NROCO
		AND GWD.GWD_CDTRP = %Exp:GWU->GWU_CDTRP%
		AND GWD.%NotDel%
		LEFT JOIN %Table:GU5% GU5
		ON GU5.GU5_FILIAL = %xFilial:GU5%
		AND GU5.GU5_CDTIPO = GWD.GWD_CDTIPO
		AND GU5.%NotDel%
		WHERE GWL.GWL_FILDC = %Exp:GWU->GWU_FILIAL%
		AND GWL.GWL_EMITDC = %Exp:GWU->GWU_EMISDC%
		AND GWL.GWL_TPDC = %Exp:GWU->GWU_CDTPDC%
		AND GWL.GWL_SERDC = %Exp:GWU->GWU_SERDC%
		AND GWL.GWL_NRDC = %Exp:GWU->GWU_NRDC%
		AND GWL.%NotDel%
	EndSql
	Do While (cAliasGWD)->(!Eof())
		If (cAliasGWD)->GU5_EVENTO == '4'
			cMensagem := "O registro possui a ocorrência de entrega : " + (cAliasGWD)->GWD_NROCO + ", portanto a entrega não pode ser cancelada."
			lRet := .F.
		EndIf
		If lRet .And. (cAliasGWD)->GU5_EVENTO == "1" .And. (cAliasGWD)->GU5_TPCALC == "2" .And. (cAliasGWD)->GU5_DEVTOT == "1"
			cMensagem := "O registro possui a ocorrência de retorno com devolução total : " + (cAliasGWD)->GWD_NROCO + ", portanto a entrega não pode ser cancelada."
			lRet := .F.
		EndIf
		(cAliasGWD)->(dbSkip())
	EndDo
	(cAliasGWD)->(dbCloseArea())
Return lRet

//--------------------------------------------------------------------------------------
/*/{Protheus.doc} GFEA051STR
Monta strutura da tabela temporária
@type  Function
@author Squad GFE
@since 02/06/2020
@version 1.0
@return aCampos, array, array de campos e indices
@example
(examples)
@see (links_or_references)
/*/
//--------------------------------------------------------------------------------------
Function GFEA051STR()
	Local aCampos  := {}
	Local aColsSX3 := {}

	// Definição de campos
	Aadd(aCampos,{"SITPRS","C",1,0})

	GFEFindSx3("GWU_CDTPDC",aColsSX3)
	Aadd(aCampos,{"CDTPDC",aColsSX3[5],aColsSX3[2],aColsSX3[3]})

	GFEFindSx3("GWU_EMISDC",aColsSX3)
	Aadd(aCampos,{"EMISDC",aColsSX3[5],aColsSX3[2],aColsSX3[3]})

	GFEFindSx3("GWU_SERDC",aColsSX3)
	Aadd(aCampos,{"SERDC",aColsSX3[5],aColsSX3[2],aColsSX3[3]})

	GFEFindSx3("GWU_NRDC",aColsSX3)
	Aadd(aCampos,{"NRDC",aColsSX3[5],aColsSX3[2],aColsSX3[3]})

	GFEFindSx3("GWU_SEQ",aColsSX3)
	Aadd(aCampos,{"SEQ",aColsSX3[5],aColsSX3[2],aColsSX3[3]})

	GFEFindSx3("GWU_DTENT",aColsSX3)
	Aadd(aCampos,{"DTENT",aColsSX3[5],aColsSX3[2],aColsSX3[3]})

	GFEFindSx3("GWU_HRENT",aColsSX3)
	Aadd(aCampos,{"HRENT",aColsSX3[5],aColsSX3[2],aColsSX3[3]})

	GFEFindSx3("GWU_DTENT",aColsSX3)
	Aadd(aCampos,{"DTATU",aColsSX3[5],aColsSX3[2],aColsSX3[3]})

	GFEFindSx3("GWU_HRENT",aColsSX3)
	Aadd(aCampos,{"HRATU",aColsSX3[5],aColsSX3[2],aColsSX3[3]})

	Aadd(aCampos,{"DETPRS","C",200,0})

Return {aCampos,{"CDTPDC+EMISDC+SERDC+NRDC+SEQ"}}

//-------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} GFEA051BW
Apresenta os demais documentos de carga do romaneio
@type  Function
@author Squad GFE
@since 02/06/2020
@version 1.0
@param cAliasGWU, caracter, Alias dos documentos de carga
@param lConfirma, logical, .T. Indica que é um registro de entrega - .F. Indica que é cancelamento
@param cGWU_DTENT, caracter, data de entrega informada
@param cGWU_HRENT, caracter, hora de entrega informada
@param cGWU_DTENT, caracter, data de entrega informada
@param cGWU_EVENT, caracter, Evento da entrega
@param lChkEntr, logical, Indica se necessita de confirmação de entrega
@return lRet, logical, .T. com sucesso - .F. houve problema
@example
(examples)
@see (links_or_references)
/*/
//-------------------------------------------------------------------------------------------------------
Function GFEA051BW(cAliasGWU,lConfirma,cGWU_DTENT, cGWU_HRENT, cGWU_EVENT,lChkEntr)
	Local lContinua := .F.
	Local aCoors    := {}
	Local aColsSX3  := {}
	Local aFields   := {}
	Local oBrowse   := Nil
	Local cDetPrs   := ""
	Local cSitPrs   := ""
	Local cTitulo   := ""

	Default lConfirma := .T.

	Private cAliasQry := Nil

	aCoors := FWGetDialogSize(oMainWnd)
	// Cria tabela temporária
	cAliasQry := GFECriaTab(GFEA051STR())
	Do While (cAliasGWU)->(!Eof())
		GWU->(dbGoTo((cAliasGWU)->RECNOGWU))
		If lConfirma
			cSitPrs := IIf(GFEA051VDE(cGWU_DTENT, cGWU_HRENT, cGWU_EVENT,lChkEntr,@cDetPrs),"1","2")
		Else
			cSitPrs := IIf(GFEA051VDC(@cDetPrs),"1","2")
		EndIf
		RecLock(cAliasQry,.T.)
			(cAliasQry)->SITPRS := cSitPrs
			(cAliasQry)->CDTPDC := GWU->GWU_CDTPDC
			(cAliasQry)->EMISDC := GWU->GWU_EMISDC
			(cAliasQry)->SERDC  := GWU->GWU_SERDC
			(cAliasQry)->NRDC   := GWU->GWU_NRDC
			(cAliasQry)->SEQ    := GWU->GWU_SEQ
			(cAliasQry)->DTENT  := GWU->GWU_DTENT
			(cAliasQry)->HRENT  := GWU->GWU_HRENT
			(cAliasQry)->DTATU  := cGWU_DTENT
			(cAliasQry)->HRATU  := cGWU_HRENT
			(cAliasQry)->DETPRS := cDetPrs
		(cAliasQry)->(MsUnLock())

		(cAliasGWU)->(dbSkip())
	EndDo

	cTitulo := IIf(lConfirma,"Registrar a Data de Entrega dos Demais Documentos de Carga do Romaneio","Cancelar a Data de Entrega dos Demais Documentos de Carga do Romaneio")
	Define MsDialog oDlgEnt Title cTitulo From aCoors[1],aCoors[2] To aCoors[3] ,aCoors[4] Pixel // Documentos de Carga do Romaneio
		// Campos do browse
		Aadd(aFields,{GFEFindSx3("GWU_CDTPDC",aColsSX3),"CDTPDC",aColsSX3[5] ,aColsSX3[2],aColsSX3[3],aColsSX3[4]})
		Aadd(aFields,{GFEFindSx3("GWU_EMISDC",aColsSX3),"EMISDC",aColsSX3[5] ,aColsSX3[2],aColsSX3[3],aColsSX3[4]})
		Aadd(aFields,{GFEFindSx3("GWU_SERDC" ,aColsSX3),"SERDC" ,aColsSX3[5] ,aColsSX3[2],aColsSX3[3],aColsSX3[4]})
		Aadd(aFields,{GFEFindSx3("GWU_NRDC"  ,aColsSX3),"NRDC"  ,aColsSX3[5] ,aColsSX3[2],aColsSX3[3],aColsSX3[4]})
		Aadd(aFields,{GFEFindSx3("GWU_SEQ"   ,aColsSX3),"SEQ"   ,aColsSX3[5] ,aColsSX3[2],aColsSX3[3],aColsSX3[4]})
		Aadd(aFields,{GFEFindSx3("GWU_DTENT" ,aColsSX3),"DTENT" ,aColsSX3[5] ,aColsSX3[2],aColsSX3[3],aColsSX3[4]})
		Aadd(aFields,{GFEFindSx3("GWU_HRENT" ,aColsSX3),"HRENT" ,aColsSX3[5] ,aColsSX3[2],aColsSX3[3],aColsSX3[4]})
		Aadd(aFields,{GFEFindSx3("GWU_DTENT" ,aColsSX3,"Dt. Entr. Atualizada"),"DTATU" ,aColsSX3[5] ,aColsSX3[2],aColsSX3[3],aColsSX3[4]})
		Aadd(aFields,{GFEFindSx3("GWU_HRENT" ,aColsSX3,"Hr. Entr. Atualizada"),"HRATU" ,aColsSX3[5] ,aColsSX3[2],aColsSX3[3],aColsSX3[4]})
		Aadd(aFields,{"Detalhamento","DETPRS","C" ,50,0,"@!"})

		oBrowse := FWMBrowse():New(oDlgEnt)
		oBrowse:SetOwner(oDlgEnt)
		oBrowse:SetAlias(cAliasQry)
		oBrowse:SetTemporary(.T.)
		oBrowse:SetFields(aFields)
		oBrowse:SetMenuDef("")
		oBrowse:ForceQuitButton()
		oBrowse:DisableDetails()
		oBrowse:AddLegend("(cAliasQry)->SITPRS == '1'", "GREEN", "Permite registrar data de entrega")
		oBrowse:AddLegend("(cAliasQry)->SITPRS == '2'", "RED", "Não permite registra data de entrega")
		oBrowse:AddButton("Confirmar", {|| lContinua := .T.,oDlgEnt:End()},,2) //Confirmar
		oBrowse:AddButton("Cancelar" , {|| oDlgEnt:End()},,2) //Cancelar
		oBrowse:SetDescription("Documentos de Carga do Romaneio")
		oBrowse:ActiVate()
	Activate MsDialog oDlgEnt Center
	delTabTmp(cAliasQry)
Return lContinua
