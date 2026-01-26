#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH" 
#INCLUDE "MSOLE.CH"
#INCLUDE "fwcommand.ch"

Static cLastFolder

#DEFINE SITUACAO_CRIADO		'1'
#DEFINE SITUACAO_EMITIDO	'2'
#DEFINE SITUACAO_ENVIADO	'3'
#DEFINE SITUACAO_CONFIRMADO	'4'
#DEFINE SITUACAO_ENCERRADO	'5'
#DEFINE SITUACAO_CANCELADO	'6'

/*/--------------------------------------------------------------------------------------------------
{Protheus.doc} GFEA079 Contratos Transporte

Generico.

Validação dos campos de tabela de transporte e negociação pra validar

@sample
GFEA079()

@author Equipe Frete Embarcador
@since 03/04/2018
@version 1.0

--------------------------------------------------------------------------------------------------/*/
Function GFEA079()
    Local oBrowse := Nil
	Private aRotina := MenuDef()
	
	Private nVlFrtUni	:= 0
	Private nVlFrtFix	:= 0
	Private cEmails		:= ""
	Private cTitulo		:= ""
	Private cMsg		:= ""
	Private cFile		:= ""
	Private cDiretorio	:= ""
	Private lRetMail	:= .T.
	Private lUpdSit		:= .T.
	Private lUpdData	:= .T.
	
	oBrowse := FWMBrowse():New()
	oBrowse:setAlias("GXT")
	oBrowse:setMenuDef("GFEA079")
	oBrowse:setDescription("Contratos de Transporte")
	
	oBrowse:AddLegend("GXT_SIT=='1'", "WHITE" ,'Criado')    // Criado
	oBrowse:AddLegend("GXT_SIT=='2'", "YELLOW",'Emitido')   // Emitido
	oBrowse:AddLegend("GXT_SIT=='3'", "GRAY"  ,'Enviado') 	// Enviado
	oBrowse:AddLegend("GXT_SIT=='4'", "BLUE"  ,'Confirmado')// Confirmado
	oBrowse:AddLegend("GXT_SIT=='5'", "ORANGE",'Encerrado') // Encerrado
	oBrowse:AddLegend("GXT_SIT=='6'", "RED"   ,'Cancelado') // Cancelado

	// Inclusão das opções de visão
	oBrowse:SetAttach(.T.)

	oBrowse:Activate()
    
Return Nil  

//------------------------------------------------------------------------------
// Função MenuDef
//------------------------------------------------------------------------------
Static Function MenuDef()
	Local aRotina := {}

	//-------------------------------------------------------
	// Adiciona botões do browse
	//-------------------------------------------------------
	AAdd(aRotina,{"Pesquisar"				,"AxPesqui"								, 0,  1 , 0, .T. /*Habilita Menu Funcional*/})
	If GFXCP12127("GVW_CDEMIT")	
		AAdd(aRotina,{"Visualizar"				,"VIEWDEF.GFEC079"						, 0,  2 , 0, .T. /*Habilita Menu Funcional*/})
	Else
		AAdd(aRotina,{"Visualizar"				,"VIEWDEF.GFEA079"						, 0,  2 , 0, .T. /*Habilita Menu Funcional*/})
	EndIf
	AAdd(aRotina,{"Incluir"					,"VIEWDEF.GFEA079"						, 0,  3 , 0, .F. /*Habilita Menu Funcional*/})
	AAdd(aRotina,{"Alterar"					,"VIEWDEF.GFEA079"						, 0,  4 , 0, .F. /*Habilita Menu Funcional*/})
	AAdd(aRotina,{"Excluir"					,"VIEWDEF.GFEA079"						, 0,  5 , 0, .F. /*Habilita Menu Funcional*/})
	AAdd(aRotina,{"Alterar Situação"		,"GFEA79SIT()"							, 0, 11 , 0, .F. /*Habilita Menu Funcional*/})
	AAdd(aRotina,{"Gerar Tabela de Frete"	,"GFEA079A(GXT->GXT_NRCT)"				, 0, 10 , 0, .F. /*Habilita Menu Funcional*/})
	AAdd(aRotina,{"Anexos"					,"MsDocument('GXT',GXT->(RecNo()), 3)"	, 0,  4 , 0, .F. /*Habilita Menu Funcional*/})
	AAdd(aRotina,{"Emitir Contrato"		    ,"GFEA79Wrd()"							, 0, 11 , 0, .F. /*Habilita Menu Funcional*/})
	AAdd(aRotina,{"Enviar Contrato"		    ,"GFEA79Ctr()"							, 0, 11 , 0, .F. /*Habilita Menu Funcional*/})
	
Return aRotina	

//------------------------------------------------------------------------------
// Função ModelDef
//------------------------------------------------------------------------------
Static Function ModelDef()
	Local oModel
	Local oModelGXU
	Local oModelGVV
	   
	oModel := MPFormModel():New("GFEA079", /* */, { |oX| GFEA079VAL( oX ) }, /**/, /**/, /*bCancel*/)
	
	oModel:AddFields('GFEA079_GXT',Nil, FWFormStruct(1,'GXT'))
	oModel:SetPrimaryKey({"GXT_FILIAL", "GXT_NRCT"})
	
	oModel:AddGrid("GFEA079_GXU", "GFEA079_GXT",FWFormStruct(1,'GXU'))
	oModel:SetRelation("GFEA079_GXU",{{"GXU_FILIAL","xFilial('GXU')"},{"GXU_NRCT","GXT_NRCT"}},"GXU_FILIAL+GXU_NRCT")
	oModelGXU = oModel:GetModel("GFEA079_GXU")
	oModelGXU:SetDescription("Rotas do Contrato")
	
	oModel:SetOptional("GFEA079_GXU", .T. )
		
	If GFXCP12117("GVV_CODOBS")
		oModel:AddGrid("GFEA079_GVV","GFEA079_GXT", FWFormStruct(1,'GVV'))
		oModel:SetRelation("GFEA079_GVV",{{"GVV_FILIAL","xFilial('GVV')"},{"GVV_NRCT","GXT_NRCT"}},"GVV_FILIAL+GVV_NRCT")
		oModelGVV = oModel:GetModel("GFEA079_GVV")
		oModelGVV:SetUniqueLine({"GVV_CODOBS"})
		oModelGVV:SetDescription("Observações do Contrato")
	
		oModel:SetOptional("GFEA079_GVV", .T. )
	EndIf
	
	oModel:AddCalc('CALCGXU_QTDE', 'GFEA079_GXT', 'GFEA079_GXU', 'GXU_PESOT', 'TOTPESO' , 'SUM'	,,,'Peso Total', )
	oModel:AddCalc('CALCGXU_QTDE', 'GFEA079_GXT', 'GFEA079_GXU', 'GXU_QTDET', 'TOTQTDE' , 'SUM'		,,,'Quantidade Total' )
	oModel:AddCalc('CALCGXU_QTDE', 'GFEA079_GXT', 'GFEA079_GXU', 'GXU_VLFIX', 'TOTVLFIX', 'FORMULA'	,,,'Valor Total Fixo', {|oModel,nTotalAtual,xValor,lSomando| GFEA79VLFIX(oModel,nTotalAtual,xValor,lSomando)})
	oModel:AddCalc('CALCGXU_QTDE', 'GFEA079_GXT', 'GFEA079_GXU', 'GXU_VLUNI', 'TOTVLUNI', 'FORMULA'	,,,'Valor Total Unitário',{|oModel,nTotalAtual,xValor,lSomando| GFEA79VLUNI(oModel,nTotalAtual,xValor,lSomando)})
	oModel:AddCalc('CALCGXU_QTDE', 'GFEA079_GXT', 'GFEA079_GXU', 'GXU_VLUNI', 'TOTVLFRT', 'FORMULA'	,,,'Valor Total de Frete',{ || GFEA79VLFRT()})
		
	oModel:SetActivate()		
Return oModel

//------------------------------------------------------------------------------
// Função ViewDef
//------------------------------------------------------------------------------
Static Function ViewDef()
	Local oModel   := FWLoadModel('GFEA079')
	Local oView    := FWFormView():New()
	Local oStruGXT := FWFormStruct(2,'GXT')
	Local oStruGXU := FWFormStruct(2,'GXU')
	Local oStruGVV
	Local oCalcGXU := FWCalcStruct( oModel:GetModel( 'CALCGXU_QTDE') )
	
	If GFXCP12117("GVV_CODOBS")
		oStruGVV := FWFormStruct(2,'GVV')
	EndIf
	
    oView:SetModel(oModel)
	oView:AddField('GFEA079_GXT', oStruGXT)
	oView:AddGrid('GFEA079_GXU', oStruGXU)
	If GFXCP12117("GVV_CODOBS")
		oView:AddGrid('GFEA079_GVV', oStruGVV)
	EndIf
	
	oView:AddField( 'VIEWCALC_GXU', oCalcGXU, 'CALCGXU_QTDE' )
	
	oView:createHorizontalBox("MASTER", 55)
	oView:createHorizontalBox("DETAIL", 35)
	oView:CreateHorizontalBox("DETAIL_GXUCALC" , 10)
	
	oView:CreateFolder("IDFOLDER","DETAIL")
	oView:AddSheet("IDFOLDER","IDSHEET01","Trechos do Contrato") //"Itens"
	If GFXCP12117("GVV_CODOBS")
		oView:AddSheet("IDFOLDER","IDSHEET02","Observações do Contrato") //"Unitizadores"
	EndIf
	
	oView:CreateHorizontalBox( "DETAIL_GXU"  , 100,,,"IDFOLDER","IDSHEET01" )
	If GFXCP12117("GVV_CODOBS")
		oView:CreateHorizontalBox( "DETAIL_GVV"  , 100,,,"IDFOLDER","IDSHEET02" )
	EndIf
		
	oView:SetOwnerView("GFEA079_GXT","MASTER")
	oView:SetOwnerView("GFEA079_GXU","DETAIL_GXU")
	If GFXCP12117("GVV_CODOBS")
		oView:SetOwnerView("GFEA079_GVV","DETAIL_GVV")
	EndIf
	oView:SetOwnerView("VIEWCALC_GXU","DETAIL_GXUCALC" )
	
	oStruGXT:RemoveField("GXT_FILIAL")
	oStruGXU:RemoveField("GXU_FILIAL")
	oStruGXU:RemoveField("GXU_NRCT")
	If GFXCP12117("GVV_CODOBS")
		oStruGVV:RemoveField("GVV_FILIAL")
		oStruGVV:RemoveField("GVV_NRCT")
	EndIf
		
	oView:AddIncrementField("GFEA079_GXU","GXU_SEQ")
	If GFXCP12117("GVV_CODOBS")
		oView:AddIncrementField("GFEA079_GVV","GVV_SEQ")	
	EndIf

Return oView

//-------------------------------------------------------------------
/*/{Protheus.doc} GFEA079VAL
Valida o Model
@author  Equipe GFE
/*/
//-------------------------------------------------------------------  
Function GFEA079VAL(oModel)
	Local oValContrato	:= GFEValidaContratoTransporte():New()
	Local nOpc        	:= (oModel:GetOperation())
	Local nX            := 0
	Local oModelGXU     := oModel:GetModel("GFEA079_GXU")
	 
	If nOpc == MODEL_OPERATION_INSERT .OR. nOpc == MODEL_OPERATION_UPDATE
		
		// "Seta" os dados necessários para execução do método de validação
		oValContrato:setCdtrp(FwFldGet('GXT_CDTRP'))
		oValContrato:setNrtab(FwFldGet('GXT_NRTAB'))
		oValContrato:setNrneg(FwFldGet('GXT_NRNEG'))
		oValContrato:setDtIRet(FwFldGet('GXT_DTIRET'))
		oValContrato:setDtFRet(FwFldGet('GXT_DTFRET'))
		If GFXCP12117("GXT_DTIENT")
			oValContrato:setDtIEnt(FwFldGet('GXT_DTIENT'))
		EndIf
		oValContrato:setDtFEnt(FwFldGet('GXT_DTFENT'))
		
 		// Executa o método de validação
		oValContrato:Validar()
		
		// Verificado a situação após a execução
		If oValContrato:getStatus() == .F.
			// Busca o retorno da execução do método
			Help( ,, 'HELP',, oValContrato:getMensagem(), 1, 0,)
			oValContrato:Destroy(oValContrato)
			Return
		EndIf
		
		For nX := 1 To oModelGXU:Length()
			oModelGXU:GoLine(nX)
			If !oModelGXU:isDeleted() .And. !Empty(oModelGXU:getValue("GXU_NRCIDO")) .And. !Empty(oModelGXU:getValue("GXU_NRCIDD"))	
				oValContrato:setVlrFixo(oModelGXU:GetValue('GXU_VLFIX'))
		 		oValContrato:setVlrUnit(oModelGXU:GetValue('GXU_VLUNI'))	
		 		If GFXCP12117("GXU_FRTPES")
		 			oValContrato:setFrtPes(oModelGXU:GetValue('GXU_FRTPES'))
		 		EndIf
		 		If GFXCP12117("GXU_UMPESO")
		 			oValContrato:setUMPeso(oModelGXU:GetValue('GXU_UMPESO'))
		 		EndIf
		 		oValContrato:setUniMed(oModelGXU:GetValue('GXU_UNIMED'))
		 		oValContrato:ValidarRotas()	
		 		// Verificado a situação após a execução
				If oValContrato:getStatus() == .F.
					// Busca o retorno da execução do método
					Help( ,, 'HELP',, oValContrato:getMensagem(), 1, 0,)
					oValContrato:Destroy(oValContrato)
					Return
				EndIf
			EndIf
			oValContrato:ClearData()
		Next
		
		oValContrato:ValidaUMPeso()
		If oValContrato:getStatus() == .F.
			// Busca o retorno da execução do método
			Help( ,, 'HELP',, oValContrato:getMensagem(), 1, 0,)
			oValContrato:Destroy(oValContrato)
			Return
		EndIf
		
 		oValContrato:Destroy(oValContrato)
	EndIf
		
Return .T.

//-------------------------------------------------------------------
/*/{Protheus.doc} GFEA079Alterar
Função responsável por alterar o Transportador, caso não esteja
relacionado na tabela de resultados. 
WHEN do campo GXT_CDTRP

@author Leonardo Ribas Jimenez Hernandez
@since 23/05/2018
@version 1.0

@param
/*/
//-------------------------------------------------------------------
Function GFEA079Trp()
	
	Local cQuery	:= ""
	
	cQuery := " SELECT GXS_FILIAL"
	cQuery += "   FROM " + RetSqlName('GXS') +" GXS "
	cQuery += "  INNER JOIN "+RetSqlName('GXT')+" GXT "
	cQuery += "     ON GXS.GXS_NRCT = GXT.GXT_NRCT "
	cQuery += "  WHERE GXS.GXS_FILCT = '" + GXT->GXT_FILIAL + "'"
	cQuery += "	 AND GXT_NRCT = '" + GXT->GXT_NRCT + "'"
	cQuery += "	 AND GXT.D_E_L_E_T_ = ' ' "
	cQuery := ChangeQuery(cQuery)
	cAliasQry := GetNextAlias()
	DbUseArea(.T.,'TOPCONN',TcGenQry(,,cQuery),cAliasQry,.F.,.T.)
	
	(cAliasQry)->( dbGoTop() )
	If (cAliasQry)->(!EoF())
		(cAliasQry)->(dbCloseArea())
		Return .F.
	EndIf
	(cAliasQry)->(dbCloseArea())
Return .T.

//-------------------------------------------------------------------
/*/{Protheus.doc} GFEA79SIT
Altera a situação do contrato
@author  Equipe do GFE
/*/
//-------------------------------------------------------------------
Function GFEA79SIT()
	Local oGFESituation := GFESituation():New()
	Local aStructSX	:= FWFormStruct(3,'GXT')[1] //Todos os Campos
	Local oValContrato
	Local nPos := aScan(aStructSX, { |x| 'GXT_SIT' == x[3] } )
	Local cMotivoCancel := ''
	Local cCodUsu := ''
	Local cUsuario := ''
	
	oGFESituation:setTitleWindow("Contrato de Transporte")
	oGFESituation:setTitleCombo("Situação")
	oGFESituation:setListSituation(aStructSX[nPos][09])
	oGFESituation:setCurrentSituation(GXT->GXT_SIT)
	oGFESituation:setNumberContract(GXT->GXT_NRCT)
	oGFESituation:setCondicaoEncerramento(GXT->GXT_ENCERR)
	
	If oGFESituation:choiceSituation()
		
		oGFESituation:setNewSituation(oGFESituation:getSituation())
		oGFESituation:validSituation()
		If !oGFESituation:getStatus()
			GFEHelp(oGFESituation:getMensagem(),'Informe uma Situação Válida','Alteração Situação Contrato Transporte')
			oGFESituation:Destroy(oGFESituation)
			aStructSX := aSize(aStructSX, 0)
			Return
		EndIf

		oValContrato:= GFEValidaContratoTransporte():New()
		oValContrato:setGXTFilial(GXT->GXT_FILIAL)
		oValContrato:setGXTNrCt(GXT->GXT_NRCT)
		oValContrato:setGXTSit(oGFESituation:getSituation())

		Do Case
			Case oGFESituation:getNewSituation() == SITUACAO_ENVIADO
				oValContrato:setDataEnvio(Date())
			Case oGFESituation:getNewSituation() == SITUACAO_CONFIRMADO
				oValContrato:setDataConfirmacao(Date())
			Case oGFESituation:getNewSituation() == SITUACAO_ENCERRADO
				oValContrato:setDataEncerramento(Date())
			Case oGFESituation:getNewSituation() == SITUACAO_CANCELADO
				cCodUsu := RetCodUsr()
				cUsuario := UsrRetName(cCodUsu)					
				cMotivoCancel := ;
					'Usuário: ' + cUsuario + CRLF + ; 
					'Data: ' + DToC(Date()) + CRLF + ;
					'Motivo: ' + oGFESituation:getJustificativa()
				oValContrato:setMotivoCancelamento(cMotivoCancel)
		EndCase		
	
		oValContrato:saveGXT()
		If oValContrato:getStatus()
			MsgInfo("Situação alterada com sucesso!")
		Else
			GFEHelp(oValContrato:getMensagem(),'Informe um Contrato Válido','Alteração Situação Contrato Transporte')
		EndIf
		
		oValContrato:Destroy(oValContrato)
	EndIf

	aStructSX := aSize(aStructSX, 0)
	oGFESituation:Destroy(oGFESituation)
	
Return

//-------------------------------------------------------------------
/*/{Protheus.doc} GFEA79Wrd
Emitir Contrato
@author  Equipe GFE
/*/
//-------------------------------------------------------------------
Function GFEA79Wrd()

	// ------------------------------------------------------------------------//
	// Area de declaração de variaveis                                         //
	//-------------------------------------------------------------------------//
 
	Local cCadastro	:= OemtoAnsi("Integração com MS-Word")
	Local aMensagem	:={}
	Local aBotoes   :={}
	Local nOpca		:= 0
	Local nPos		:= 0
	Local oValContrato
 
	Private cPerg   := Padr("GFEA79WRD",10)
 
	//-------------------------------------------------------------------
	// Cria/Verifica as perguntas selecionadas
	//-------------------------------------------------------------------
 
	Pergunte(cPerg,.F.)
	 
	AADD(aMensagem,OemToAnsi("Esta rotina irá imprimir um contrato, clique no botão PARAM para informar o PC a") )
	AADD(aMensagem,OemToAnsi("ser impressa e os demais parametros.") )
 
	AADD(aBotoes, { 5,.T.,{||  Pergunte(cPerg,.T. )}})
	AADD(aBotoes, { 6,.T.,{|o| nOpca := 1,FechaBatch()}})
	AADD(aBotoes, { 2,.T.,{|o| FechaBatch() }} )
 
	FormBatch( cCadastro, aMensagem, aBotoes )
 
	/*
	+--------------------------------------------------------------------+
	| Variaveis utilizadas para parametros								 |
	+--------------------------------------------------------------------+
	| Variaveis utilizadas para parâmetros								 |				
	| mv_par01		// Arquivo Modelo									 |
	| mv_par02		// Pasta de destino do documento					 |	
	| mv_par03		// Método de saida 1=Impressora 2=Apenas Arquivo	 | 
	+--------------------------------------------------------------------+
	*/
	If nOpca == 1
		PRIVATE hWord	 	:= OLE_CreateLink()
		PRIVATE cArquivo 	:= Alltrim(mv_par01) 
		PRIVATE cPath    	:= AllTrim(mv_par02) 
		PRIVATE nImpress	:= mv_par03 

		nPos := Rat("\",cPath)
		If nPos = 0
			cPath := cPath + "\"
		EndIF
 
		If(!File(cArquivo))
			Alert("Arquivo modelo não existe!")
			Return
		EndIf
 
		If  Upper( Subst( AllTrim( cArquivo ), - 3 ) ) != Upper( AllTrim( "DOT" ) ) .AND.;
			Upper( Subst( AllTrim( cArquivo ), - 4 ) ) != Upper( AllTrim( "DOTM" ) ) .AND.;
			Upper( Subst( AllTrim( cArquivo ), - 4 ) ) != Upper( AllTrim( "DOCM" ) ) .AND.;
			Upper( Subst( AllTrim( cArquivo ), - 4 ) ) != Upper( AllTrim( "DOTX" ) ) 
	    	MsgAlert( "Arquivo Inválido!" + CRLF + "Extensões permitidas: DOT ou DOTM ou DOCM ou DOTX" )
	    	Return
	    EndIf
 
		If (hWord != "0")
			Alert("MS-WORD não encontrado nessa máquina!")
			Return
		EndIf
 
		Processa({|| Imprimir() },"Aguarde...")
		
		oValContrato:= GFEValidaContratoTransporte():New()
		oValContrato:setGXTFilial(GXT->GXT_FILIAL)
		oValContrato:setGXTNrCt(GXT->GXT_NRCT)
		oValContrato:setGXTSit("2")
		oValContrato:saveGXT()
		if !oValContrato:getStatus()
			GFEHelp(oValContrato:getMensagem(),'Informe um Contrato Válido','Alteração Situação Contrato Transporte')
		EndIf
		oValContrato:Destroy(oValContrato)
	EndIf 
Return

//-------------------------------------------------------------------
/*/{Protheus.doc} GFEA79VLFIX
Valor total fixo
@author  Equipe GFE
/*/
//-------------------------------------------------------------------
Static Function GFEA79VLFIX(oModel,nTotalAtual,xValor,lSomando)
	Local oModelGXU := oModel:GetModel("GFEA079_GXU")
	
	nVlFrtFix := nTotalAtual
	
	If lSomando
		nVlFrtFix += oModelGXU:GetValue("GXU_VLFIX") 
	Else
		nVlFrtFix -= oModelGXU:GetValue("GXU_VLFIX")
	EndIf
Return nVlFrtFix

//-------------------------------------------------------------------
/*/{Protheus.doc} GFEA79VLUNI
Valor Total Unitário
@author  Equipe GFE
/*/
//-------------------------------------------------------------------
Static Function GFEA79VLUNI(oModel,nTotalAtual,xValor,lSomando)
	Local oModelGXU := oModel:GetModel("GFEA079_GXU")
	
	nVlFrtUni := nTotalAtual
	
	If lSomando
		If GFXCP12117("GXU_FRTPES") .And. !Empty(oModelGXU:GetValue("GXU_FRTPES"))
			nVlFrtUni += oModelGXU:GetValue("GXU_FRTPES") * oModelGXU:GetValue("GXU_PESOT") 
		ElseIf !Empty(oModelGXU:GetValue("GXU_VLUNI"))
			nVlFrtUni += oModelGXU:GetValue("GXU_VLUNI") * oModelGXU:GetValue("GXU_QTDET")
		EndIf
	Else
		If GFXCP12117("GXU_FRTPES") .And. !Empty(oModelGXU:GetValue("GXU_FRTPES"))
			nVlFrtUni -= oModelGXU:GetValue("GXU_FRTPES") * oModelGXU:GetValue("GXU_PESOT")
		ElseIf !Empty(oModelGXU:GetValue("GXU_VLUNI"))
			nVlFrtUni -= oModelGXU:GetValue("GXU_VLUNI") * oModelGXU:GetValue("GXU_QTDET")
		EndIf
	EndIf
Return nVlFrtUni

//-------------------------------------------------------------------
/*/{Protheus.doc} GFEA79VLFRT
Valor Total de Frete
@author  Equipe GFE
/*/
//-------------------------------------------------------------------
Static Function GFEA79VLFRT()
	Local nVlTotFrt := 0
	
	nVlTotFrt := nVlFrtUni + nVlFrtFix
Return nVlTotFrt

//-------------------------------------------------------------------
/*/{Protheus.doc} GFEA79TpObs
Observação
@author  Equipe GFE
/*/
//-------------------------------------------------------------------
Function GFEA79TpObs()
	Local cTxtTpObs	:= ""
	Local aTpObs	:= {}
	
	aTpObs	:= RetSX3Box(Posicione('SX3',2,'GUO_TPOBS','X3CBox()'),,,1)
			
	If !Empty(M->GVV_CODOBS)
		cTxtTpObs	:= aTpObs[Val(M->GVV_CODOBS),3]
	EndIf
Return cTxtTpObs

//-------------------------------------------------------------------
/*/{Protheus.doc} GFEA79BrTpObs
Observação
@author  Equipe GFE
/*/
//-------------------------------------------------------------------
Function GFEA79BrTpObs()
	Local cTxtTpObs	:= ""
	Local aTpObs	:= {}
	
	aTpObs	:= RetSX3Box(Posicione('SX3',2,'GUO_TPOBS','X3CBox()'),,,1)
			
	If !Empty(GVV->GVV_CODOBS)
		cTxtTpObs	:= aTpObs[Val(GVV->GVV_CODOBS),3]
	EndIf
Return cTxtTpObs

//-------------------------------------------------------------------
/*/{Protheus.doc} Imprimir
Imprime o contrato após emiti-lo
@author  Equipe GFE
/*/
//------------------------------------------------------------------- 
Static Function Imprimir()
	// ------------------------------------------------------------------------//
	// Area de declaração de variaveis                                         //
	//-------------------------------------------------------------------------//  
	Local nReg
	Local cGXUMemo
	Local aTmpImp 		:= {}
	Local nX  
	Local cNrCidEmit
	Local GFE_CRTNOME  // Razão social do Contratante
	Local GFE_CRTEND   // Endereço do Contratante
	Local GFE_CRTMUN   // Município do Contratante
	Local GFE_CRTUF    // UF do Contratante
	Local GFE_CRTIE    // IE do Contratante	
	Local GFE_CRTCNPJ  // CNPJ do Contratante
	Local GFE_DSCTNOME  // Razão social do Contratante
	Local GFE_DSCTEND   // Endereço do Contratante
	Local GFE_DSCTMUN   // Município do Contratante
	Local GFE_DSCTUF    // UF do Contratante
	Local GFE_DSCTIE    // IE do Contratante	
	Local GFE_DSCTCNPJ  // CNPJ do Contratante
	Local GFE_CTRNUM    := AllTrim(GXT->GXT_NRCT)  // Número do Contrato 
	Local GFE_CTRDATA   := GXT->GXT_DTCT           // Dia Contrato 
	Local GFE_CTRDIA    := Day2Str(GFE_CTRDATA)    // Mês Contrato     
	Local GFE_CTRMES    := Month2Str(GFE_CTRDATA)   
	Local GFE_CTRMEXT   := MesExtenso(GFE_CTRDATA) // Mês Contrato (por extenso)
	Local GFE_CTRANO    := Year2Str(GFE_CTRDATA)   // Ano Contrato
	Local GFE_TRPNOME   := AllTrim(POSICIONE("GU3",1,XFILIAL("GU3")+GXT->GXT_CDTRP,"GU3_NMEMIT")) // Razão Transportador  
	Local GFE_TRPEND    := AllTrim(POSICIONE("GU3",1,XFILIAL("GU3")+GXT->GXT_CDTRP,"GU3_ENDER"))  // Endereço Transportador 
	Local cNrCidTrp     := AllTrim(POSICIONE("GU3",1,XFILIAL("GU3")+GXT->GXT_CDTRP,"GU3_NRCID"))  // Código Cidade Transportador
	Local GFE_TRPMUN    := AllTrim(POSICIONE("GU7",1,XFILIAL("GU7")+cNrCidTrp,"GU7_NMCID")) 		// Cidade do Transportador
	Local GFE_TRPUF	  	:= AllTrim(POSICIONE("GU7",1,XFILIAL("GU7")+cNrCidTrp,"GU7_CDUF"))  		// UF do Transportador
	Local GFE_TRPCNPJ   := AllTrim(POSICIONE("GU3",1,XFILIAL("GU3")+GXT->GXT_CDTRP,"GU3_IDFED"))  // CNPJ do Transportador
	Local GFE_TRPIE     := AllTrim(POSICIONE("GU3",1,XFILIAL("GU3")+GXT->GXT_CDTRP,"GU3_IE"))		// IE do Transportador
	Local cNrClfr  	  	:= Iif(!Empty(GXT->GXT_CDCLFR), AllTrim(POSICIONE("GUB",1,XFILIAL("GUB")+GXT->GXT_CDCLFR,"GUB_CDCLFR")),"")// Classif Frete
	Local GFE_CLASDES   := Iif(!Empty(cNrClfr), AllTrim(POSICIONE("GUB",1,XFILIAL("GUB")+cNrClfr,"GUB_DSCLFR")), " - ")	 // Classif Frete
	Local cNrOper  	  	:= AllTrim(POSICIONE("GV4",1,XFILIAL("GV4")+GXT->GXT_CDTPOP,"GV4_CDTPOP"))  // Tipo Operação
	Local GFE_TPOPDES   := AllTrim(POSICIONE("GV4",1,XFILIAL("GV4")+cNrOper,"GV4_DSTPOP"))	 	  // Tipo Operação
	Local GFE_TOTPESO   := 0	// Peso Total Contrato
	Local GFE_TOTQTDE   := 0	// Quantidade Total Contrato
	Local GFE_RETDTINI  := Iif(!Empty(GXT->GXT_DTIRET),cValToChar(GXT->GXT_DTIRET)," / / ") // Data Início Retirada
	Local GFE_RETDTFIM  := Iif(!Empty(GXT->GXT_DTFRET),cValToChar(GXT->GXT_DTFRET)," / / ") // Data Final Retirada
	Local GFE_ENTDTINI  := Iif(!Empty(GXT->GXT_DTIENT),cValToChar(GXT->GXT_DTIENT)," / / ") // Data Final Entrega
	Local GFE_ENTDTFIM  := Iif(!Empty(GXT->GXT_DTFENT),cValToChar(GXT->GXT_DTFENT)," / / ") // Data Final Entrega
	Local GFE_CLAUSCGA  := Iif(!Empty(GXT->GXT_OBSCGA),GXT->GXT_OBSCGA," - ")	// Obs gerais sobre a carga da mercadoria
	Local GFE_CLAUSDGA  := Iif(!Empty(GXT->GXT_OBSDGA),GXT->GXT_OBSDGA," - ")	// Obs gerais sobre a descarga da mercadoria
	Local GFE_CLAUSPAG  := Iif(!Empty(GXT->GXT_OBSPAG),GXT->GXT_OBSPAG," - ")	// Obs gerais sobre condições de pagamento do contrato
	Local GFE_CLAUSGER  := Iif(!Empty(GXT->GXT_OBSCLA),GXT->GXT_OBSCLA," - ")	// Obs gerais sobre as cláusulas contratuais
	Local GFE_ROTASEQ   // Rota
	Local GFE_ORIGMUN   // Município da Origem
	Local GFE_ORIGUF    // UF da Origem
	Local GFE_DESTMUN   // Município do Destino
	Local GFE_DESTUF    // UF do Destino
	Local GFE_ROTAPESO  // Peso
	Local GFE_ROTAQTDE  // Quantidade
	Local GFE_ROTAUM 	  // Unidade de Medida
	Local GFE_FRETEPESO // Tarifa Frete Peso
	Local GFE_FRETEPERC // Tarifa Frete Percentual
	Local GFE_FRETEFIXO // Tarifa Frete Fixo
	Local GFE_FTUNIEXT  // Tarifa Frete Peso por extenso
	Local GFE_FTPEREXT  // Tarifa Frete Perc por extenso
	Local GFE_FTFIXEXT  // Tarifa Frete Fixo por extenso
	Local GFE_FRETEIMP  // Tarifa com Imposto?
	
	Local GFE_OBSPAG
	Local GFE_OBSGER
	Local GFE_OBSOUT
	
	Local GFE_TOTFRT
	Local GFE_UMPESO
	Local GFE_UMQTDE
	
	Local cQuery
	Local cAliGXU	:= GetNextAlias()
	Local cAliGVV	:= GetNextAlias()
	
	Private aExp  	:= {}    // Array enviado para o P.E. com as variáveis do modelo
	Private aExp2 	:= {}    // Array enviado para o P.E. com as variáveis das Rotas do modelo
	Private aImp  	:= {}    // Array retornado do P.E. com as variáveis do modelo
	Private aImp2 	:= {}    // Array retornado do P.E. com as variáveis das Rotas do modelo
	Private aGXU  	:= {}    // Array retornado de fGXUTab() com os dados das rotas
	
	GU3->(dbSetOrder(1)) // GU3_FILIAL + GU3_IDFED
	If GU3->(dbSeek(xFilial("GU3") + GXT->GXT_CODCTR))
		GFE_CRTNOME := AllTrim(GU3->GU3_NMEMIT)
		GFE_CRTCNPJ := AllTrim(GU3->GU3_IDFED)
		GFE_CRTEND 	:= AllTrim(GU3->GU3_ENDER)
		cNrCidEmit  := AllTrim(GU3->GU3_NRCID)				
		GFE_CRTMUN 	:= AllTrim(POSICIONE("GU7",1,XFILIAL("GU7")+cNrCidEmit,"GU7_NMCID"))				
		GFE_CRTUF  	:= AllTrim(POSICIONE("GU7",1,XFILIAL("GU7")+cNrCidEmit,"GU7_CDUF")) 
		GFE_CRTIE  	:= Iif(!Empty(GU3->GU3_IE), AllTrim(GU3->GU3_IE), "ISENTO")
	EndIf
	
	GU3->(dbSetOrder(1)) // GU3_FILIAL + GU3_IDFED
	If GU3->(dbSeek(xFilial("GU3") + GXT->GXT_CODCLI))
		GFE_DSCTNOME := AllTrim(GU3->GU3_NMEMIT)
		GFE_DSCTCNPJ := AllTrim(GU3->GU3_IDFED)
		GFE_DSCTEND 	:= AllTrim(GU3->GU3_ENDER)
		cNrCidEmit  := AllTrim(GU3->GU3_NRCID)				
		GFE_DSCTMUN 	:= AllTrim(POSICIONE("GU7",1,XFILIAL("GU7")+cNrCidEmit,"GU7_NMCID"))				
		GFE_DSCTUF  	:= AllTrim(POSICIONE("GU7",1,XFILIAL("GU7")+cNrCidEmit,"GU7_CDUF")) 
		GFE_DSCTIE  	:= Iif(!Empty(GU3->GU3_IE), AllTrim(GU3->GU3_IE), "ISENTO")
	EndIf
	
	GFE_TOTPESO := 0
	GFE_TOTQTDE := 0
	GFE_TOTFRT	:= 0
	GFE_UMPESO	:= ""
	GFE_UMQTDE	:= ""
	
	cQuery := "SELECT GXU.GXU_PESOT, GXU.GXU_QTDET, GXU.GXU_UNIMED, GXU.GXU_VLFIX,"
	cQuery += " GXU.GXU_VLUNI, GXU.GXU_UMPESO, GXU.GXU_FRTPES FROM " + RetSQLName("GXU") + " GXU"
	cQuery += " WHERE GXU.GXU_FILIAL = '" + GXT->GXT_FILIAL + "'"
	cQuery += " AND GXU.GXU_NRCT = '" + GXT->GXT_NRCT + "'"
	cQuery += " AND GXU.D_E_L_E_T_ = ''"
	
	cQuery := ChangeQuery(cQuery)
	
	dbUseArea(.T.,'TOPCONN',TcGenQry(,,cQuery),cAliGXU,.T.,.T.)
	
	(cAliGXU)->(dbGoTop())
	While !((cAliGXU)->(Eof()))
		GFE_TOTPESO	+= (cAliGXU)->GXU_PESOT
		GFE_TOTQTDE += (cAliGXU)->GXU_QTDET
		If Empty(GFE_UMPESO)
			GFE_UMPESO := (cAliGXU)->GXU_UMPESO
		EndIf
		If Empty(GFE_UMQTDE)
			GFE_UMQTDE := (cAliGXU)->GXU_UNIMED
		EndIf
		If !Empty((cAliGXU)->GXU_FRTPES)
			GFE_TOTFRT += (cAliGXU)->GXU_FRTPES * (cAliGXU)->GXU_PESOT 
		ElseIf !Empty((cAliGXU)->GXU_VLUNI)
			GFE_TOTFRT += (cAliGXU)->GXU_VLUNI * (cAliGXU)->GXU_QTDET
		EndIf
		If !Empty((cAliGXU)->GXU_VLFIX)
			GFE_TOTFRT += (cAliGXU)->GXU_VLFIX
		EndIf 
		(cAliGXU)->(dbSkip())
	EndDo
	
	GFE_OBSPAG := ""
	GFE_OBSGER := ""
	GFE_OBSOUT := ""
	
	If TcGetDB() == 'ORACLE'
		cQuery := "SELECT UTL_RAW.CAST_TO_VARCHAR2(DBMS_LOB.SUBSTR(GUO.GUO_TXTOBS, 3200,1)) AS GUO_TXTOBS"
	Else
		cQuery := "SELECT ISNULL(CONVERT(VARCHAR(1024),CONVERT(VARBINARY(1024),GUO.GUO_TXTOBS)),'') AS GUO_TXTOBS"
	EndIf
	cQuery += " , GUO.GUO_TPOBS FROM " + RetSQLName("GVV") + " GVV"
	cQuery += " INNER JOIN " + RetSQLName("GUO") + " GUO"
	cQuery += " ON GUO.GUO_FILIAL = '" + xFilial("GUO") + "'"
	cQuery += " AND GUO.GUO_CODOBS = GVV.GVV_CODOBS"
	cQuery += " WHERE GVV.GVV_FILIAL = '" + GXT->GXT_FILIAL + "'"
	cQuery += " AND GVV.GVV_NRCT = '" + GXT->GXT_NRCT + "'"
	cQuery += " AND GVV.D_E_L_E_T_ = ''"
	cQuery += " AND GUO.D_E_L_E_T_ = ''"
	
	cQuery := ChangeQuery(cQuery)
	
	dbUseArea(.T.,'TOPCONN',TcGenQry(,,cQuery),cAliGVV,.T.,.T.)
	
	(cAliGVV)->(dbGoTop())
	While !((cAliGVV)->(Eof()))
		Do Case
			Case (cAliGVV)->GUO_TPOBS == "1"
				GFE_OBSPAG	+= (cAliGVV)->GUO_TXTOBS
			Case (cAliGVV)->GUO_TPOBS == "2"
				GFE_OBSGER	+= (cAliGVV)->GUO_TXTOBS
			Case (cAliGVV)->GUO_TPOBS == "3"
				GFE_OBSOUT	+= (cAliGVV)->GUO_TXTOBS
		End Case
		(cAliGVV)->(dbSkip())
	EndDo
	
	// Array contendo as variáveis cadastradas	
	// VARIAVEL WORD, VARIAVEL IMPRESSAO, VARIAVEL PICTURE, DESCRIÇÃO 
	aAdd( aExp, {'GFE_CTRNUM'    	, Alltrim(GFE_CTRNUM)    	, "@!"  , "Número do Contrato" })
	aAdd( aExp, {'GFE_CRTNOME'  	, Alltrim(GFE_CRTNOME)  	, "@!"  , "Razão Social da Contratante" })
	aAdd( aExp, {'GFE_CRTEND'   	, Alltrim(GFE_CRTEND)   	, "@!"  , "Endereço da Contratante" })
	aAdd( aExp, {'GFE_CRTMUN'   	, Alltrim(GFE_CRTMUN)   	, "@!"  , "Município da Contratante" })
	aAdd( aExp, {'GFE_CRTUF'    	, Alltrim(GFE_CRTUF)    	, "@!"  , "UF da Contratante" })
	aAdd( aExp, {'GFE_CRTCNPJ'  	, Alltrim(GFE_CRTCNPJ)  	, "@!"  , "CNPJ da Contratante" })
	aAdd( aExp, {'GFE_CRTIE'    	, Alltrim(GFE_CRTIE)    	, "@!"  , "IE da Contratante" })
	aAdd( aExp, {'GFE_DSCTNOME'  	, Alltrim(GFE_DSCTNOME)  	, "@!"  , "Razão Social do Destinatário" })
	aAdd( aExp, {'GFE_DSCTEND'   	, Alltrim(GFE_DSCTEND)   	, "@!"  , "Endereço do Destinatário" })
	aAdd( aExp, {'GFE_DSCTMUN'   	, Alltrim(GFE_DSCTMUN)   	, "@!"  , "Município do Destinatário" })
	aAdd( aExp, {'GFE_DSCTUF'    	, Alltrim(GFE_DSCTUF)    	, "@!"  , "UF do Destinatário" })
	aAdd( aExp, {'GFE_DSCTCNPJ'  	, Alltrim(GFE_DSCTCNPJ)  	, "@!"  , "CNPJ do Destinatário" })
	aAdd( aExp, {'GFE_DSCTIE'    	, Alltrim(GFE_DSCTIE)    	, "@!"  , "IE do Destinatário" })
	aAdd( aExp, {'GFE_CTRDATA'   	, GFE_CTRDATA   		  	, "@!"  , "Data Registro do Contrato" })
	aAdd( aExp, {'GFE_CTRDIA' 	 	, GFE_CTRDIA    		  	, "@!"  , "Dia Registro do Contrato" })
	aAdd( aExp, {'GFE_CTRMES'	 	, GFE_CTRMES	  		  	, "@!"  , "Mês Registro do Contrato" })
	aAdd( aExp, {'GFE_CTRMEXT'   	, Alltrim(GFE_CTRMEXT)   	, "@!"  , "Mês por ext Registro do Contrato" })
	aAdd( aExp, {'GFE_CTRANO'    	, Alltrim(GFE_CTRANO)    	, "@!"  , "Ano Registro do Contrato" })
	aAdd( aExp, {'GFE_TRPNOME'   	, Alltrim(GFE_TRPNOME)   	, "@!"  , "Razão Social do Contratado" })
	aAdd( aExp, {'GFE_TRPEND' 	 	, Alltrim(GFE_TRPEND)    	, "@!"  , "Endereço Completo do Transportador" })
	aAdd( aExp, {'GFE_TRPMUN'    	, Alltrim(GFE_TRPMUN)    	, "@!"  , "Município do Transportador" })
	aAdd( aExp, {'GFE_TRPUF'	 	, Alltrim(GFE_TRPUF)	  	, "@!"  , "UF do Transportador" })
	aAdd( aExp, {'GFE_TRPCNPJ'   	, Alltrim(GFE_TRPCNPJ)   	, "@!"  , "CNPJ do Transportador" })
	aAdd( aExp, {'GFE_TRPIE'     	, Alltrim(GFE_TRPIE)     	, "@!"  , "IE do Transportador" })
	aAdd( aExp, {'GFE_CLASDES'   	, Alltrim(GFE_CLASDES)   	, "@!"  , "Classificação de Frete" })
	aAdd( aExp, {'GFE_TPOPDES'   	, Alltrim(GFE_TPOPDES)   	, "@!"  , "Tipo de Operação" })
	aAdd( aExp, {'GFE_TOTPESO'   	, GFE_TOTPESO   		  	, "@!"  , "Peso Total Contrato" })
	aAdd( aExp, {'GFE_TOTQTDE'   	, GFE_TOTQTDE   		  	, "@!"  , "Quantidade Total Contrato" })
	aAdd( aExp, {'GFE_RETDTINI'  	, GFE_RETDTINI  		 	, "@!"  , "Data Início Retirada" })
	aAdd( aExp, {'GFE_RETDTFIM'  	, GFE_RETDTFIM  		  	, "@!"  , "Data Final Retirada" })
	aAdd( aExp, {'GFE_ENTDTINI'  	, GFE_ENTDTINI  		  	, "@!"  , "Data Inicial Entrega" })
	aAdd( aExp, {'GFE_ENTDTFIM'  	, GFE_ENTDTFIM  		  	, "@!"  , "Data Final Entrega" })
	aAdd( aExp, {'GFE_CLAUSCGA'  	, Alltrim(GFE_CLAUSCGA)  	, "@!"  , "Observações de Carregamento" })
	aAdd( aExp, {'GFE_CLAUSDGA'  	, Alltrim(GFE_CLAUSDGA)  	, "@!"  , "Observações de Descarregamento" })
	aAdd( aExp, {'GFE_CLAUSPAG'  	, Alltrim(GFE_CLAUSPAG)  	, "@!"  , "Condições de Pagamento" })
	aAdd( aExp, {'GFE_CLAUSGER'  	, Alltrim(GFE_CLAUSGER)		, "@!"  , "Cláusulas Contratuais Gerais" })
	aAdd( aExp, {'GFE_OBSPAG'		, Alltrim(GFE_OBSPAG)		, "@!"	, "Observações de Pagamento"})	
	aAdd( aExp, {'GFE_OBSGER'		, Alltrim(GFE_OBSGER)		, "@!"	, "Observações Gerais"})
	aAdd( aExp, {'GFE_OBSOUT'		, Alltrim(GFE_OBSOUT)		, "@!"	, "Observações Outros"})
	aAdd( aExp, {'GFE_UMPESO'		, Alltrim(GFE_UMPESO)		, "@!"	, "Unidade de Medida Peso"})
	aAdd( aExp, {'GFE_UMQTDE'		, Alltrim(GFE_UMQTDE)		, "@!"	, "Unidade de Medida Quantidade"})
	aAdd( aExp, {'GFE_TOTFRT'		, GFE_TOTFRT				, "@!"	, "Total de Frete do Contrato"})
	
	aAdd( aExp2, {'GFE_ROTASEQ'	  	, Alltrim(GFE_ROTASEQ)   	, "@!"  , "Rota" })
	aAdd( aExp2, {'GFE_ORIGMUN'	  	, Alltrim(GFE_ORIGMUN)   	, "@!"  , "Município da Origem" })
	aAdd( aExp2, {'GFE_ORIGUF'	  	, Alltrim(GFE_ORIGUF)	   	, "@!"  , "UF da Origem" })
	aAdd( aExp2, {'GFE_DESTMUN'	  	, Alltrim(GFE_DESTMUN)   	, "@!"  , "Município do Destino" })
	aAdd( aExp2, {'GFE_DESTUF'	  	, Alltrim(GFE_DESTUF)	   	, "@!"  , "UF do Destino" })
	aAdd( aExp2, {'GFE_ROTAPESO'  	, Alltrim(GFE_ROTAPESO)  	, "@!"  , "Peso" })
	aAdd( aExp2, {'GFE_ROTAQTDE'  	, Alltrim(GFE_ROTAQTDE)  	, "@!"  , "Quantidade" })
	aAdd( aExp2, {'GFE_ROTAUM'	  	, Alltrim(GFE_ROTAUM)    	, "@!"  , "Unidade de Medida" })
	aAdd( aExp2, {'GFE_FRETEPESO' 	, GFE_FRETEPESO 		   	, "@!"  , "Tarifa Frete Peso" })
	aAdd( aExp2, {'GFE_FRETEPERC' 	, GFE_FRETEPERC 			, "@!"  , "Tarifa Frete Percentual" })
	aAdd( aExp2, {'GFE_FRETEFIXO' 	, GFE_FRETEFIXO 			, "@!"  , "Tarifa Frete Fixo" })
	aAdd( aExp2, {'GFE_FTUNIEXT'  	, Alltrim(GFE_FTUNIEXT)		, "@!"  , "Tarifa Frete Peso por ext" })
	aAdd( aExp2, {'GFE_FTFIXEXT'  	, Alltrim(GFE_FTFIXEXT)		, "@!"  , "Tarifa Frete Perc por ext" })
	aAdd( aExp2, {'GFE_FTPEREXT'  	, Alltrim(GFE_FTPEREXT)		, "@!"  , "Tarifa Frete Fixo por ext" })
	aAdd( aExp2, {'GFE_FRETEIMP'  	, Alltrim(GFE_FRETEIMP)		, "@!"  , "Imposto?" })
	
	aImp  := aExp
	aImp2 := aExp2
	
	aGXU := fGXUTab()
	
	// Ponto de Entrada para manipulação das variáveis de impressão 
	If ExistBlock("GFEA0791") 
		aTmpImp := ExecBlock("GFEA0791",.F.,.F.,{aExp, aExp2})
		If ValType(aTmpImp[1]) == "A" .And. Len(aTmpImp[1]) > 0 
			aImp  := aTmpImp[1]
		EndIf
			
		If  ValType(aTmpImp[2]) == "A" //.And. Len(aTmpImp[2]) > 0 
			aImp2 := aTmpImp[2]
		EndIf
	EndIf

	// ------------------------------------------------------------------------//
	// Abre as tabelas para consulta                                           //
	//-------------------------------------------------------------------------//
 	set softseek off
	
	// Inicializa o Ole com o MS-Word
	BeginMsOle()
		If (hWord == "0")
			IncProc("Processando documento...")
			OLE_CloseLink(hWord) //fecha o Link com o Word

			hWord := OLE_CreateLink()
			OLE_NewFile(hWord,cArquivo)
					
			If nImpress==1
				OLE_SetProperty( hWord, oleWdVisible,   .F. )
				OLE_SetProperty( hWord, oleWdPrintBack, .T. )
			Else
				OLE_SetProperty( hWord, oleWdVisible,   .T. )
				OLE_SetProperty( hWord, oleWdPrintBack, .F. )
			EndIf

			For nX := 1 To Len(aImp)
				// Envia no docmento, VARIÁVEL DO MODELO, VALOR DA VARIÁVEL
				OLE_SetDocumentVar(hword, aImp[nX][1]  ,aImp[nX][2] ) 
			Next nX

			cGXUMemo := ""
			If (Len(aImp2) > 0)
				For nReg := 1 To Len(aImp2)
					cGXUMemo += aImp2[nReg][2] + "#*" // Rota
				Next nReg	                 
				
				// Parâmetros da macro
				OLE_SetDocumentVar(hword, "cRotas", cGXUMemo) 	  // Envia para a variavel do modelo o conteudo completo da tabela
				OLE_SetDocumentVar(hword, "nReg", AllTrim(Str(Len(aGXU)))) // Envia para a variavel do modelo a qtd de linhas da tabela
				OLE_ExecuteMacro(hWord , "rotasentregas") 		  // Executa macro do Word que cria a tabela e insere o conteudo do cMemo

			Else
				OLE_SetDocumentVar(hWord , "cRotas" , "") // Limpa variável
				OLE_SetDocumentVar(hWord , "nReg"   , "") // Limpa variável
			EndIf

			OLE_UpDateFields(hWord) // Atualiza as variáveis
			OLE_SaveAsFile(hWord, cPath + "Contrato" + aImp[1][2] + ".doc")
 
			// Para impressão do documento
			If nImpress==1 
				OLE_SetProperty( hWord, '208', .F. )
				OLE_PrintFile( hWord, "ALL",,, 1 )
				OLE_CloseLink( hWord ) // Fecha o Link com o Word
			Else
				Aviso("Atenção", "Alterne para o programa do Ms-Word para visualizar o contrato contrato" + aImp[1][2] + ".doc ou clique no botao para fechar.", {"Fechar"})
				OLE_SaveAsFile(hWord, cPath + "Contrato" + aImp[1][2] + ".doc")
			EndIf
		EndIf
		
	EndMsOle()
	OLE_CloseLink( hWord ) // Fecha o Link com o Word 
Return

/*/ {Protheus.doc} fGXUTab
Macro Word - Tabela GXU - Dados Rotas
@author: Gabriela Lima
@since: 04/12/2018
/*/ 
Static Function fGXUTab()
	Local aReturn := {}

	GXU->(dbSetOrder(1)) // GXU_FILIAL + GXU_NRCT + GXU_SEQ
	If GXU->(dbSeek(xFilial("GXU")+ GXT->GXT_NRCT)) //+ GXU->GXU_SEQ))
		While !GXU->(Eof()) .AND. GXU->GXU_FILIAL = xFilial("GXU") .AND. GXU->GXU_NRCT = GXT->GXT_NRCT			
			
			aImp2[1][2] := AllTrim(GXU->GXU_SEQ)													 // Rota
			aImp2[2][2] := AllTrim(POSICIONE("GU7",1,XFILIAL("GU7") + GXU->GXU_NRCIDO,"GU7_NMCID"))  // Município da Origem
			aImp2[3][2] := AllTrim(POSICIONE("GU7",1,XFILIAL("GU7") + GXU->GXU_NRCIDO,"GU7_CDUF"))   // UF da Origem
			aImp2[4][2] := AllTrim(POSICIONE("GU7",1,XFILIAL("GU7") + GXU->GXU_NRCIDD,"GU7_NMCID"))  // Município do Destino
			aImp2[5][2] := AllTrim(POSICIONE("GU7",1,XFILIAL("GU7") + GXU->GXU_NRCIDD,"GU7_CDUF"))   // UF do Destino
			aImp2[6][2] := Iif(!Empty(GXU->GXU_PESOT),cValToChar(GXU->GXU_PESOT)," - ")				 // Peso
			aImp2[7][2] := Iif(!Empty(GXU->GXU_QTDET),cValToChar(GXU->GXU_QTDET)," - ") 			 // Quantidade
			aImp2[8][2] := Iif(!Empty(GXU->GXU_UNIMED),GXU->GXU_UNIMED," - ")		   				 // Unidade de Medida
			aImp2[9][2] := Iif(!Empty(GXU->GXU_VLUNI),cValToChar(GXU->GXU_VLUNI)," - ") 			 // Tarifa Frete Peso
			aImp2[10][2] := " - " 			 // Tarifa Frete Percentual
			aImp2[11][2] := Iif(GXU->GXU_VLFIX<>0,cValToChar(GXU->GXU_VLFIX)," - ") 				 // Tarifa Frete Fixo
			aImp2[12][2] := Iif(!Empty(GXU->GXU_VLUNI),AllTrim(Extenso(GXU->GXU_VLUNI))," - ")		 // Tarifa Frete Peso por ext
			aImp2[13][2] := Iif(GXU->GXU_VLFIX<>0,AllTrim(Extenso(GXU->GXU_VLFIX))," - ")			 // Tarifa Frete Percentual por ext
			aImp2[14][2] := " - "		 // Tarifa Frete Fixo por ext
			aImp2[15][2] := Iif(cValToChar(GXU->GXU_IMPINC) == "1", "Incluído", "Não incluído")		 // Imposto?
			
			aAdd(aReturn ,{ Alltrim(aImp2[1][2]),;   // Rota
							Alltrim(aImp2[2][2]),;   // Município da Origem
							Alltrim(aImp2[3][2]),;   // UF da Origem
							Alltrim(aImp2[4][2]),;   // Município do Destino
							Alltrim(aImp2[5][2]),;   // UF do Destino
							Alltrim(aImp2[6][2]),;   // Peso
							Alltrim(aImp2[7][2]),;   // Quantidade
							Alltrim(aImp2[8][2]),;   // Unidade de Medida
							Alltrim(aImp2[9][2]),;   // Tarifa Frete Peso
							Alltrim(aImp2[10][2]),;  // Tarifa Frete Percentual
							Alltrim(aImp2[11][2]),;  // Tarifa Frete Fixo
							Alltrim(aImp2[12][2]),;  // Tarifa Frete Peso por ext
							Alltrim(aImp2[13][2]),;  // Tarifa Frete Percentual por ext
							Alltrim(aImp2[14][2]),;  // Tarifa Frete Fixo por ext
							Alltrim(aImp2[15][2]) }) // Imposto?

			GXU->(dbSkip())
		EndDo
	Else 
		aReturn := {}
	EndIf 	

Return aReturn


//-------------------------------------------------------------------
/*/{Protheus.doc} GFEA79Ctr
Função responsável por busca do arquivo, de emails e 
validações do contrato após envio do e-mail

@author Leonardo Ribas Jimenez Hernandez
@since 18/03/2019
@version 1.0

@param
/*/
//-------------------------------------------------------------------
Function GFEA79Ctr()
	Local oValContrato
	Local cFilCtr := ""
	Local cNrCt := ""
	
	If GFXCP12123("GU2_RECCTR")
		lUpdSit		:= .T.
		lUpdData	:= .T.
		cFilCtr	:= GXT->GXT_FILIAL
		cNrCt	:= GXT->GXT_NRCT

		If lEnvia := GFE79Regra(GXT->GXT_SIT)

			cEmails := ""

			cTitulo := "Contrato de Transporte"

			cFile := cGetFile( "Arquivos separados por Ponto-e-Virgula (*) |*|","Escolher arquivo",,cLastFolder,.T.,,.F.)	

			If(!File(cFile))
				Alert("Arquivo não selecionado!")
				Return
			EndIf

			GU2->(dbSetOrder(1))
			If GU2->(dbSeek(xFilial("GU2") + GXT->GXT_CDTRP))
				While !GU2->(Eof()) .And. xFilial("GU2") + GXT->GXT_CDTRP == GU2->GU2_FILIAL + GU2->GU2_CDEMIT
					If GU2->GU2_RECCTR == "1" .And. GU2->GU2_SIT == '1'
						If Empty(cEmails)
							cEmails := GU2->GU2_EMAIL
						Else
							cEmails := cEmails + ";" + GU2->GU2_EMAIL
						EndIf
					EndIf
					cEmails := AllTrim(cEmails)
					GU2->(dbSkip())
				EndDo 
			EndIf
			
			If Empty(cEmails)
				GU3->(dbSetOrder(1))
				If GU3->(dbSeek(xFilial("GU3") + GXT->GXT_CDTRP))
					cEmails := GU3->GU3_EMAIL
				EndIf
			EndIf

			If ExistBlock("GFEA0792")
				cMsg := ExecBlock("GFEA0792",.F.,.F.,{cFilCtr, cNrCt}) 
			Elseif Empty(cMsg)
				cMsg := "Segue em anexo o arquivo de contrato da filial: " + cFilCtr + " Número: " + cNrCt + "."
			EndIf				
			cMsg += " " + CRLF
			cMsg += " " + CRLF

			Processa({|| GFE79Enviar() },"Enviando Contrato...")

			If lRetMail	
				oValContrato:= GFEValidaContratoTransporte():New()
				oValContrato:setGXTFilial(cFilCtr)
				oValContrato:setGXTNrCt(cNrCt)
				If lUpdSit
					oValContrato:setGXTSit("3")
				EndIf
				If lUpdData
					oValContrato:setDataEnvio(Date())
				EndIf
				oValContrato:saveGXT()
				if !oValContrato:getStatus()
					GFEHelp(oValContrato:getMensagem(),'Informe um Contrato Válido','Alteração Situação Contrato Transporte')
				EndIf
				oValContrato:Destroy(oValContrato)
			EndIf
		EndIf
	Else
		GFEHelp("Funcionalidade ainda não disponível.")	
	EndIf
Return

//-------------------------------------------------------------------
/*/{Protheus.doc} GFE79Regra
Regras para envio do e-mail

@author Leonardo Ribas Jimenez Hernandez
@since 25/03/2019
@version 1.0

@param
/*/
//-------------------------------------------------------------------
Function GFE79Regra(cSit)
	Local lRetPerg := .T.
	Do Case
		Case cSit == SITUACAO_ENVIADO
			lRetPerg := MsgYesNo("Contrato já foi enviado, deseja enviar novamente? Obs: a data de envio será alterada.")
			lUpdSit := .F.
		Case cSit == SITUACAO_CONFIRMADO
			lRetPerg := MsgYesNo("Situação do contrato já está como confirmado, deseja enviar por e-mail mesmo assim?") 
			lUpdData	:= .F.
			lUpdSit		:= .F.
		Case cSit == SITUACAO_ENCERRADO
			lRetPerg := MsgYesNo("Situação do contrato já está como encerrado, deseja enviar por e-mail mesmo assim?") 
			lUpdData	:= .F.
			lUpdSit		:= .F.
		Case cSit == SITUACAO_CANCELADO
			lRetPerg := MsgYesNo("Situação do contrato já está como cancelado, deseja enviar por e-mail mesmo assim?") 
			lUpdData	:= .F.
			lUpdSit		:= .F.
	EndCase		

Return lRetPerg

//-------------------------------------------------------------------
/*/{Protheus.doc} GFE79Enviar
Função responsável por enviar contrato anexado por e-mail.

@author Leonardo Ribas Jimenez Hernandez
@since 18/03/2019
@version 1.0

@param
/*/
//-------------------------------------------------------------------
Function GFE79Enviar()
	Local cNewFile := ""
	Local cDrive, cDir, cNome, cExt
	Local cPasta := ""
	lRetMail	:= .T.
	
	//Variável para indicar o RootPath, assim para jogar o arquivo a ser enviado por e-mail no rootpath padrão
	cPasta := "\"
	
	If !Empty(cFile)
		SplitPath( cFile, @cDrive, @cDir, @cNome, @cExt )
	EndIf
	
	If CpyT2S( cFile, cPasta, .F. )
		cNewFile := cPasta + cNome + cExt
	
		aRet := GFEMail(cEmails, cTitulo, cMsg, .F.,{cNewFile})
		If !aRet[1]
			cMsgErro := aRet[2]
			GFEMsgErro(cMsgErro)
			lRetMail := .F.
		EndIf
	
		FERASE(cNewFile) 
	Else
		GFEMsgErro("Falha ao copiar o arquivo do diretório: " + cFile + " para o RootPath.")
	EndIf
  
Return