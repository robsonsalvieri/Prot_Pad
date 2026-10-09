#INCLUDE "TECA880.CH"
#INCLUDE "TOTVS.CH"
#INCLUDE "FWMVCDEF.CH"

#DEFINE itARMA     "1"
#DEFINE itCOLETE   "2"
#DEFINE itMUNICAO  "3"

#DEFINE eoLOCINTER   '1'
#DEFINE eoLOCATEND   '2'
#DEFINE edCLIENTE    '1'
#DEFINE edEMPRESA    '2'

#DEFINE stAGENDADA   '1'
#DEFINE stEFETIVADA  '2'
#DEFINE stANULADA    '3'

#DEFINE mtIMPLANTACAO    '1'
#DEFINE mtMANUTENCAO     '2'
#DEFINE mtDESCARTE       '3'
#DEFINE mtREFORCO        '4'
#DEFINE mtENCERRAMENTO   '5'

Static aCmpBco   := {} //Array com os locais de alocação da munição
Static _cCodTFL  := ""
Static _cProduto := ""
Static _cRetF3   := ""
Static cTab      := ""
Static _lGsOrcArm:= .F.
Static oModel    := Nil
Static oView     := Nil

//--------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} TECA880	

Cadastro de Movimentação - TFQ

@author 	Serviços
@since 		20/08/13
@version 	P11 R9
@param		cFilDefault, Caracter, código de filtro para restrição forçada da exibição dos dados na tabela/browse
/*/
//----------------------------------------------------------------------------------------------------------------------
Function TECA880(cFilDefault)
Local oBrowse	:= Nil
Local nX		:= 0
Local aCores	:= {	{ 'TFQ->TFQ_STATUS=="1"' , 'BR_AMARELO',  STR0002 },; //"Agendada"
						{ 'TFQ->TFQ_STATUS=="2"' , 'BR_VERDE',    STR0003 },; //"Efetivada"
						{ 'TFQ->TFQ_STATUS=="3"' , 'BR_VERMELHO', STR0004 } } //"Cancelada"

Default cFilDefault := ''

Private aRotina	:= MenuDef()
Private cCadastro	:= STR0001 //"Movimentação"

_lGsOrcArm := FindFunction("TecGsArma") .And. TecGsArma()
 
oBrowse := FWMBrowse():New()
oBrowse:SetAlias('TFQ')

// Adiciona as legendas.
For nX := 1 To Len(aCores)
	oBrowse:AddLegend(aCores[nX][1],aCores[nX][2],aCores[nX][3]) 
Next nX   

If !Empty(cFilDefault)
	oBrowse:SetFilterDefault(cFilDefault)
EndIf

oBrowse:SetDescription(STR0001) //"Movimentação"
oBrowse:Activate()

Return

//--------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} MenuDef

Definição do MenuDef

@author Serviços
@since 20/08/13
@version P11 R9

@return ExpO:aRotina
/*/
//--------------------------------------------------------------------------------------------------------------------
Static Function MenuDef()

LOCAL aRotina := {}

ADD OPTION aRotina TITLE STR0084 ACTION 'PesqBrw'			OPERATION 1 ACCESS 0 //"Pesquisar"
ADD OPTION aRotina TITLE STR0085 ACTION 'VIEWDEF.TECA880'	OPERATION 2 ACCESS 0 //"Visualizar"
ADD OPTION aRotina TITLE STR0086 ACTION 'VIEWDEF.TECA880'	OPERATION 3 ACCESS 0 //"Incluir"
ADD OPTION aRotina TITLE STR0087 ACTION 'VIEWDEF.TECA880'	OPERATION 4 ACCESS 0 //"Alterar"
ADD OPTION aRotina TITLE STR0088 ACTION 'VIEWDEF.TECA880'	OPERATION 5 ACCESS 0 //"Excluir"
ADD OPTION aRotina TITLE STR0106 ACTION 'TC880EST'			OPERATION 4 ACCESS 0 //"Estornar"
ADD OPTION aRotina TITLE STR0005 ACTION 'MSDOCUMENT'		OPERATION 7 ACCESS 0 //"Bco. Conhecimento"

Return aRotina

//--------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} ModelDef

Definição do Model 

@author Serviços
@since 20/08/13
@version P11 R9

@return ExpO:oModel
/*/
//--------------------------------------------------------------------------------------------------------------------
Static Function ModelDef()
	Local oStruTFOA := FWFormStruct(1, 'TFO' , {|cCampo| AT880GFLD( 'ARMAS' , cCampo)}) //Item de Movimentação - Armas
	Local oStruTFOC := FWFormStruct(1, 'TFO' , {|cCampo| AT880GFLD( 'COLETES' , cCampo)}) //Item de Movimentação - Coletes
	Local oStruTFOM := FWFormStruct(1, 'TFO' , {|cCampo| AT880GFLD( 'MUNICOES' , cCampo)}) //Item de Movimentação - Munições
	Local oStruTFQ  := FWFormStruct(1, 'TFQ' , {|cCampo| AT880GFLD( 'CABECALHO' ,cCampo)}) //Cabeçalho de Movimentação
	Local oStruTFR  := FWFormStruct(1, 'TFR' ) //Tabela de Funcionarios da ocorrencia	

	Local aAux          := {}
	Local aLoadFilter   := {}
	Local bActivate     :={|oModel|At880Active(oModel)}
	Local bCommit       :={|oModel|At880Commit(oModel)}
	Local bLnPrTFOA     :={|oModel, nLine, cAcao, cCampo, xValue, xOldValue|At880PRArm(oModel,nLine,cAcao,cCampo, xValue, xOldValue)}
	Local bLnPrTFOC     :={|oModel, nLine, cAcao, cCampo, xValue, xOldValue|At880PRCol(oModel,nLine,cAcao,cCampo, xValue, xOldValue)}
	Local bLnPrTFOM     :={|oModel, nLine, cAcao, cCampo, xValue, xOldValue|At880PRMun(oModel,nLine,cAcao,cCampo, xValue, xOldValue)}
	Local bLnPsTFOA     :={|oModel, nLine, cAcao, cCampo|At880LPArm(oModel,nLine,cAcao,cCampo)}
	Local bLnPsTFOC     :={|oModel, nLine, cAcao, cCampo|At880LPCol(oModel,nLine,cAcao,cCampo)}
	Local bLnPsTFOM     :={|oModel, nLine, cAcao, cCampo|At880LPMun(oModel,nLine,cAcao,cCampo) .And. At880VldQt(oModel:GetModel())}
	Local bLocalVld     :={||}
	Local bPosTRF       :={|oModel|At880PosTRF(oModel)}
	Local bPosValidacao :={|oModel|At880PosValid(oModel)}
	Local bPosVld       :={|oModel|At880PosTFQ(oModel)}
	Local cAtuProp      := ""

	//Criação de Gatilhos para os campos virtuais
	If _lGsOrcArm
		aAux := FwStruTrigger("TFQ_CONTRT","TFQ_CONTRT","At880Clear()",.F.,Nil,Nil,Nil)
		oStruTFQ:AddTrigger(aAux[1],aAux[2],aAux[3],aAux[4]) 

		aAux := FwStruTrigger("TFQ_CONTRT","TFQ_POSTO","",.F.,Nil,Nil,Nil)
		oStruTFQ:AddTrigger(aAux[1],aAux[2],aAux[3],aAux[4]) 

		aAux := FwStruTrigger("TFQ_ORIGEM","TFQ_ORIGEM","At880Clear()",.F.,Nil,Nil,Nil)
		oStruTFQ:AddTrigger(aAux[1],aAux[2],aAux[3],aAux[4]) 

		aAux := FwStruTrigger("TFQ_ORIGEM","TFQ_POSTO","",.F.,Nil,Nil,Nil)
		oStruTFQ:AddTrigger(aAux[1],aAux[2],aAux[3],aAux[4]) 

		aAux := FwStruTrigger("TFQ_DESTIN","TFQ_DESTIN","At880Clear()",.F.,Nil,Nil,Nil)
		oStruTFQ:AddTrigger(aAux[1],aAux[2],aAux[3],aAux[4])

		aAux := FwStruTrigger("TFQ_DESTIN","TFQ_POSTO","",.F.,Nil,Nil,Nil)
		oStruTFQ:AddTrigger(aAux[1],aAux[2],aAux[3],aAux[4]) 

		aAux := FwStruTrigger("TFQ_POSTO","TFQ_POSTO","At880Clear()",.F.,Nil,Nil,Nil)
		oStruTFQ:AddTrigger(aAux[1],aAux[2],aAux[3],aAux[4]) 
	EndIf

	aAux := FwStruTrigger("TFQ_ORIGEM","TFQ_DSCLOC","At880LDsc('ORIGEM')",.F.,Nil,Nil,Nil)
	oStruTFQ:AddTrigger(aAux[1],aAux[2],aAux[3],aAux[4]) 
	
	aAux := FwStruTrigger("TFQ_DESTIN","TFQ_DDESTI","At880LDsc('DESTINO')",.F.,Nil,Nil,Nil)
	oStruTFQ:AddTrigger(aAux[1],aAux[2],aAux[3],aAux[4])

	xAux := FwStruTrigger("TFQ_MOTIVO", "TFQ_ENTORI", "At880Mot(FwFldGet('TFQ_MOTIVO'))", .F., Nil, Nil, Nil)
	oStruTFQ:AddTrigger( xAux[1], xAux[2], xAux[3], xAux[4])

	aAux := FwStruTrigger("TFQ_RESTRA","TFQ_DRESP","At880Resp()",.F.,Nil,Nil,Nil)
	oStruTFQ:AddTrigger(aAux[1],aAux[2],aAux[3],aAux[4])

	aAux := FwStruTrigger("TFR_CODTEC","TFR_NOMTEC","At880Atend()",.F.,Nil,Nil,Nil)
	oStruTFR:AddTrigger(aAux[1],aAux[2],aAux[3],aAux[4])

	//Gatilhos para as descrições dos armamentos
	aAux := FwStruTrigger("TFO_ITCOD","TFO_DESCR","At880IniArma('"+itARMA+"',FwFldGet('TFO_ITCOD'))",.F.,Nil,Nil,Nil)
	oStruTFOA:AddTrigger(aAux[1],aAux[2],aAux[3],aAux[4])

	aAux := FwStruTrigger("TFO_ITCOD","TFO_DESCR","At880IniArma('"+itMUNICAO+"',FwFldGet('TFO_ITCOD'))",.F.,Nil,Nil,Nil)
	oStruTFOM:AddTrigger(aAux[1],aAux[2],aAux[3],aAux[4])

	aAux := FwStruTrigger("TFO_ITCOD","TFO_DESCR","At880IniArma('"+itCOLETE+"',FwFldGet('TFO_ITCOD'))",.F.,Nil,Nil,Nil)
	oStruTFOC:AddTrigger(aAux[1],aAux[2],aAux[3],aAux[4])

	If _lGsOrcArm
		// Grid Armas:
		aAux := FwStruTrigger("TFO_ITCOD","TFO_CODTXQ","at880GetTXQ(FwFldGet('TFQ_ENTORI'), FwFldGet('TFQ_ENTDES'), FwFldGet('TFQ_CONTRT'), FwFldGet('TFQ_CONREV'), FwFldGet('TFQ_FILORI'), FwFldGet('TFQ_ORIGEM'), FwFldGet('TFQ_POSTO'), FwFldGet('TFO_ITCOD'), '"+itARMA+"')",.F.,Nil,Nil,Nil)
		oStruTFOA:AddTrigger(aAux[1],aAux[2],aAux[3],aAux[4])

		// Grid Coletes:
		aAux := FwStruTrigger("TFO_ITCOD","TFO_CODTXQ","at880GetTXQ(FwFldGet('TFQ_ENTORI'), FwFldGet('TFQ_ENTDES'), FwFldGet('TFQ_CONTRT'), FwFldGet('TFQ_CONREV'), FwFldGet('TFQ_FILORI'), FwFldGet('TFQ_ORIGEM'), FwFldGet('TFQ_POSTO'), FwFldGet('TFO_ITCOD'), '"+itCOLETE+"')",.F.,Nil,Nil,Nil)
		oStruTFOC:AddTrigger(aAux[1],aAux[2],aAux[3],aAux[4])

		// Grid Munições:
		aAux := FwStruTrigger("TFO_ITCOD","TFO_CODTXQ","",.F.,Nil,Nil,Nil)
		oStruTFOM:AddTrigger(aAux[1],aAux[2],aAux[3],aAux[4])

		aAux := FwStruTrigger("TFO_ITCOD","TFO_PRODUT","At880Produto()",.F.,Nil,Nil,Nil)
		oStruTFOM:AddTrigger(aAux[1],aAux[2],aAux[3],aAux[4])

		aAux := FwStruTrigger("TFO_ITCOD","TFO_QTDE","Val('0')",.F.,Nil,Nil,Nil)
		oStruTFOM:AddTrigger(aAux[1],aAux[2],aAux[3],aAux[4])
	Endif

	oStruTFQ:SetProperty('TFQ_ENTORI', MODEL_FIELD_WHEN, {|| !FwFldGet("TFQ_MOTIVO") $ '1|5'})
	// Permitir informar campos Origem e Destino
	oStruTFQ:SetProperty('TFQ_ORIGEM',MODEL_FIELD_WHEN,{|oModel|.T.})
	oStruTFQ:SetProperty('TFQ_DESTIN',MODEL_FIELD_WHEN,{|oModel|.T.})

	// Bloqueia campo Entidade de Destino para Empresa se o motivo for implantação 
	If _lGsOrcArm
		oStruTFQ:SetProperty('TFQ_ENTDES', MODEL_FIELD_WHEN, {|| ! ( (FwFldGet("TFQ_MOTIVO") == '1') .AND. Empty(FwFldGet("TFQ_CONTRT")) ) } )
	
		// Libera o campo TFO_CODTXQ para edição caso tenha contrato na movimentação e o Destino for CONTRATO(CLIENTE):
		// Aba de Armas:
		oStruTFOA:SetProperty('TFO_CODTXQ',MODEL_FIELD_WHEN,{ || !Empty(FwFldGet("TFQ_CONTRT")) .And. FwFldGet("TFQ_ENTDES") == edCLIENTE }) 
		// Aba de Coletes:
		oStruTFOC:SetProperty('TFO_CODTXQ',MODEL_FIELD_WHEN,{ || !Empty(FwFldGet("TFQ_CONTRT")) .And. FwFldGet("TFQ_ENTDES") == edCLIENTE })
		// Aba de Munições:
		oStruTFOM:SetProperty('TFO_CODTXQ',MODEL_FIELD_WHEN,{ || !Empty(FwFldGet("TFQ_CONTRT")) .And. (FwFldGet("TFQ_ENTDES") == edCLIENTE .Or. FwFldGet("TFQ_ENTORI") == eoLOCATEND) })
		oStruTFOM:SetProperty('TFO_PRODUT',MODEL_FIELD_WHEN,{ || .F. })
	EndIf

	//Aplicar os inicializadores padrão
	oStruTFOA:SetProperty('TFO_ITMOV',MODEL_FIELD_INIT,{|| itARMA })
	oStruTFOM:SetProperty('TFO_ITMOV',MODEL_FIELD_INIT,{|| itMUNICAO })	
	oStruTFOC:SetProperty('TFO_ITMOV',MODEL_FIELD_INIT,{|| itCOLETE })

	// Pré Validação de Edição - Master
	oStruTFQ:SetProperty("TFQ_CONTRT",MODEL_FIELD_WHEN,{ || (FwFldGet("TFQ_ENTDES") == edCLIENTE .And. !Empty(FwFldGet("TFQ_DESTIN")) .Or. _lGsOrcArm) } )

	// Pós Validação de Edição - Master
	oStruTFQ:SetProperty("TFQ_ORIGEM",MODEL_FIELD_VALID,{ |oModel|At880VldOri(oModel,'TFQ_ORIGEM')})
	oStruTFQ:SetProperty("TFQ_ENTORI",MODEL_FIELD_VALID,{ |oModel|At880VlEnt(oModel,'TFQ_ENTORI') })
	oStruTFQ:SetProperty("TFQ_ENTDES",MODEL_FIELD_VALID,{ |oModel|At880VlEnt(oModel,'TFQ_ENTDES') })
	oStruTFQ:SetProperty("TFQ_MOTIVO",MODEL_FIELD_VALID,{ |oModel|At880VlEnt(oModel,'TFQ_MOTIVO') .And. At880VldTp() })
	oStruTFQ:SetProperty("TFQ_CONTRT",MODEL_FIELD_VALID,{ |oModel|At880VlCont(oModel,FwFldGet("TFQ_DESTIN"),oModel:GetValue("TFQ_CONTRT")) })
	oStruTFQ:SetProperty("TFQ_DMOVIM",MODEL_FIELD_VALID,{ |oModel|At880VDtMv(oModel) })

	// Obrigatoriedade de preenchimento - Armas
	oStruTFOA:SetProperty('TFO_LGUIA',MODEL_FIELD_OBRIGAT,.T.)

	// Pré Validação de Edição - Armas
	oStruTFOA:SetProperty('TFO_ITMOV' ,MODEL_FIELD_WHEN,{|oModel| .F.})
	oStruTFOA:SetProperty('TFO_NRGUIA',MODEL_FIELD_WHEN,{|oModel| oModel:GetValue('TFO_LGUIA') == '1'})
	oStruTFOA:SetProperty('TFO_DTRET' ,MODEL_FIELD_WHEN,{|oModel| oModel:GetValue('TFO_LRET') == '1'})
	If _lGsOrcArm
		oStruTFOA:SetProperty("TFO_CODTXQ",MODEL_FIELD_VALID,{ |oModel| at880VlTXQ(oModel,itARMA) })
		oStruTFOA:SetProperty("TFO_ITCOD",MODEL_FIELD_VALID,{ |oModel| At880VIMV(oModel) })
	EndIf
	oStruTFOA:SetProperty("TFO_LGUIA",MODEL_FIELD_VALID,{ |oModel| Pertence('12') .and. At880NGuia(oModel) })
	oStruTFOA:SetProperty("TFO_LRET" ,MODEL_FIELD_VALID,{ |oModel| Pertence('12') .and. At880DtPrv(oModel) })
	oStruTFOA:SetProperty("TFO_DTRET",MODEL_FIELD_VALID,{ |oModel| At880VDtRt(oModel) })

	// Obrigatoriedade de preenchimento - Munições
	oStruTFOM:SetProperty('TFO_LGUIA',MODEL_FIELD_OBRIGAT,.T.)
	oStruTFOM:SetProperty('TFO_QTDE' ,MODEL_FIELD_OBRIGAT,.T.)

	// Pré Validação de Edição - Munições
	oStruTFOM:SetProperty('TFO_ITMOV' ,MODEL_FIELD_WHEN,{|oModel| .F.})
	oStruTFOM:SetProperty('TFO_NRGUIA',MODEL_FIELD_WHEN,{|oModel| oModel:GetValue('TFO_LGUIA') == '1'})
	oStruTFOM:SetProperty('TFO_DTRET' ,MODEL_FIELD_WHEN,{|oModel| oModel:GetValue('TFO_LRET') == '1'}) 
	If _lGsOrcArm
		oStruTFOM:SetProperty('TFO_QTDE'  ,MODEL_FIELD_WHEN,{|oModel| !Empty(oModel:GetValue('TFO_ITCOD'))}) 
	EndIf

	// Pós Validação de Edição - Munições
	If _lGsOrcArm
		oStruTFOM:SetProperty("TFO_CODTXQ",MODEL_FIELD_VALID,{ |oModel| at880VlTXQ(oModel,itMUNICAO) })
		oStruTFOM:SetProperty("TFO_ITCOD",MODEL_FIELD_VALID,{ |oModel| At880VIMV(oModel) })
		oStruTFOM:SetProperty("TFO_QTDE" ,MODEL_FIELD_VALID,{ |oModel| At880VldSaldo(oModel) })
	EndIf
	oStruTFOM:SetProperty("TFO_LGUIA",MODEL_FIELD_VALID,{ |oModel| Pertence('12') .and. At880NGuia(oModel) })
	oStruTFOM:SetProperty("TFO_LRET" ,MODEL_FIELD_VALID,{ |oModel| Pertence('12') .and. At880DtPrv(oModel) })
	oStruTFOM:SetProperty("TFO_DTRET",MODEL_FIELD_VALID,{ |oModel| At880VDtRt(oModel) })

	// monta a validação para o campo TFO_PRODUT - Munições:
	cAtuProp := RTrim( GetSX3Cache("TFO_PRODUT","X3_VALID") )
	If !_lGsOrcArm
		cAtuProp += " .And. At880VldAloc('3')"
	EndIf
	If !Empty( Alltrim(cValUser := GetSX3Cache("TFO_PRODUT","X3_VLDUSER") ) )
		cAtuProp += " .And. " + cValUser
	EndIf
	bLocalVld := FwBuildFeature( STRUCT_FEATURE_VALID, cAtuProp )

	oStruTFOM:SetProperty("TFO_PRODUT", MODEL_FIELD_VALID, bLocalVld )

	// Obrigatoriedade de preenchimento - Coletes
	oStruTFOC:SetProperty('TFO_LGUIA',MODEL_FIELD_OBRIGAT,.T.)

	// Pré Validação de Edição - Coletes
	oStruTFOC:SetProperty('TFO_ITMOV',MODEL_FIELD_WHEN,{|oModel|.F.})
	oStruTFOC:SetProperty('TFO_DTRET',MODEL_FIELD_WHEN,{|oModel|oModel:GetValue('TFO_LRET') == '1'})
	oStruTFOC:SetProperty('TFO_NRGUIA',MODEL_FIELD_WHEN,{|oModel| oModel:GetValue('TFO_LGUIA') == '1'})

	// Pós Validação de Edição - Coletes
	If _lGsOrcArm
		oStruTFOC:SetProperty("TFO_CODTXQ",MODEL_FIELD_VALID,{ |oModel| at880VlTXQ(oModel,itCOLETE) })
		oStruTFOC:SetProperty("TFO_ITCOD",MODEL_FIELD_VALID,{ |oModel| At880VIMV(oModel) })
	EndIf
	oStruTFOC:SetProperty("TFO_LRET" ,MODEL_FIELD_VALID,{ |oModel| Pertence('12') .and. At880DtPrv(oModel) })
	oStruTFOC:SetProperty("TFO_DTRET",MODEL_FIELD_VALID,{ |oModel| At880VDtRt(oModel) })
	oStruTFOC:SetProperty("TFO_LGUIA",MODEL_FIELD_VALID,{ |oModel| Pertence('12') .and. At880NGuia(oModel) })

	//Instancia o cadastro de Ocorrencia
	oModel := MPFormModel():New('TECA880',/*bPreValidacao*/,bPosVld,bCommit,/*bCancel*/)

	//Instancia o cabeçalho da ocorrencia
	oModel:AddFields('TFQMASTER',/*cOwner*/,oStruTFQ, {|oMdlTFQ,cAction,cField,xValue| PrelinTFQ(oMdlTFQ,cAction,cField,xValue)},bPosValidacao,/*bCarga*/,/*bFieldAbp*/)

	//Instancia os Grids para cadastro de ocorrencia
	oModel:AddGrid("TFRFUNC","TFQMASTER",oStruTFR,/*bLinePre*/,/*bLinePost*/,/*bPreValidacao*/,bPosTRF,/*bLoadPrd*/)
	oModel:AddGrid("TFOARMA","TFQMASTER",oStruTFOA,bLnPrTFOA,bLnPsTFOA,/*bPreTFOA*/,/*bPosTFOA*/,/*bLoadPrd*/)
	oModel:AddGrid("TFOMUNI","TFQMASTER",oStruTFOM,bLnPrTFOM,bLnPsTFOM,/*bPreValidacao*/,/*bPosValidacao*/,/*bLoadPrd*/)
	oModel:AddGrid("TFOCOLE","TFQMASTER",oStruTFOC,bLnPrTFOC,bLnPsTFOC,/*bPreValidacao*/,/*bPosValidacao*/,/*bLoadPrd*/)

	//Realiza o relacionamento entre o cabeçalho e os grids Funcionario/Pessoas - Armas - Munições - Coletes
	oModel:SetRelation("TFRFUNC",{{"TFR_FILIAL","xFilial('TFR')"},{"TFR_CODMOV","TFQ_CODIGO"}},TFR->( IndexKey(1)))  
	oModel:SetRelation("TFOARMA",{{"TFO_FILIAL","xFilial('TFO')"},{"TFO_CDMOV","TFQ_CODIGO"}},TFO->( IndexKey(1)))  
	oModel:SetRelation("TFOMUNI",{{"TFO_FILIAL","xFilial('TFO')"},{"TFO_CDMOV","TFQ_CODIGO"}},TFO->( IndexKey(1)))  
	oModel:SetRelation("TFOCOLE",{{"TFO_FILIAL","xFilial('TFO')"},{"TFO_CDMOV","TFQ_CODIGO"}},TFO->( IndexKey(1)))  

	//Determina a obrigatoriedade de preenchimento dos Grid's
	oModel:GetModel('TFOARMA'):SetOptional(.T.)
	oModel:GetModel('TFOMUNI'):SetOptional(.T.)
	oModel:GetModel('TFOCOLE'):SetOptional(.T.)

	//Configura o Grid para não duplicar a linha
	oModel:GetModel("TFRFUNC"):SetUniqueLine({"TFR_CODTEC"})
	//Linhas unicas para Armas, Apenas 1 Código e 1 TXQ:
	oModel:GetModel("TFOARMA"):SetUniqueLine({"TFO_ITCOD"})
	If _lGsOrcArm
		//Linhas unicas para munição:
		oModel:GetModel("TFOMUNI"):SetUniqueLine({"TFO_CODTXQ"})
	EndIf
	//Linhas unicas para Coletes, Apenas 1 Código e 1 TXQ:
	oModel:GetModel("TFOCOLE"):SetUniqueLine({"TFO_ITCOD"})

	//Aplicar filtro de dados aos Grid's
	aLoadFilter := { { "TFO_ITMOV", "'"+itARMA+"'", MVC_LOADFILTER_EQUAL } }
	oModel:GetModel("TFOARMA"):SetLoadFilter( aLoadFilter, /*cLoadFilter*/ )
	aLoadFilter := { { "TFO_ITMOV", "'"+itCOLETE+"'", MVC_LOADFILTER_EQUAL } }
	oModel:GetModel("TFOCOLE"):SetLoadFilter( aLoadFilter, /*cLoadFilter*/ )
	aLoadFilter := { { "TFO_ITMOV", "'"+itMUNICAO+"'", MVC_LOADFILTER_EQUAL } }
	oModel:GetModel("TFOMUNI"):SetLoadFilter( aLoadFilter, /*cLoadFilter*/ )

	//Valida o Model para Ativa-lo
	oModel:SetVldActivate(bActivate)

	oModel:SetPrimaryKey( {} )

Return(oModel)

//--------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} ViewDef

Definição da View 

@author Serviços
@since 20/08/13
@version P11 R9

@return ExpO:oView
/*/
//--------------------------------------------------------------------------------------------------------------------
Static Function ViewDef()

Local oModel   	 := FWLoadModel('TECA880')
Local oStruTFQ	 := FWFormStruct(2,'TFQ', {|cCampo| AT880GFLD('CABECALHO',cCampo)})		//Cabeçalho de Movimentação
Local oStruTFR	 := FWFormStruct(2,'TFR')		//Tabela de Funcionarios da ocorrencia	
Local oStruTFOA	 := FWFormStruct(2,'TFO', {|cCampo| AT880GFLD('ARMAS'   , cCampo)})		//Item de Movimentação - Armas
Local oStruTFOM	 := FWFormStruct(2,'TFO', {|cCampo| AT880GFLD('MUNICOES', cCampo)})		//Item de Movimentação - Munições
Local oStruTFOC	 := FWFormStruct(2,'TFO', {|cCampo| AT880GFLD('COLETES' , cCampo)})		//Item de Movimentação - Coletes
Local lExstRev   := TFQ->(ColumnPos("TFQ_CONREV")) > 0 .And. TFQ->(ColumnPos("TFQ_POSTO")) > 0 

oView:= FWFormView():New()
oView:SetModel(oModel)

oView:AddUserButton(STR0005, 'CLIPS',{|oView|MsDocument('TFQ',TFQ->(RECNO()),oModel:GetOperation() )}) //"Bco. Conhecimento"

//Adiciona o Link para Emissão da Guia
oView:AddUserButton(STR0048,"",{|oView|At880Guia(oModel)},,,) //Guia de Trafego

oStruTFQ:RemoveField("TFQ_ULTSTA")
If _lGsOrcArm
	oStruTFQ:RemoveField("TFQ_CODTFL")
else
	oStruTFQ:RemoveField("TFQ_CONTRT")
	If lExstRev
		oStruTFQ:RemoveField("TFQ_CONREV")
		oStruTFQ:RemoveField("TFQ_POSTO")
	EndIf
Endif
oStruTFQ:RemoveField("TFQ_ENTIDA")
oStruTFR:RemoveField("TFR_CODMOV")

oView:AddField('VIEW_CAB',oStruTFQ,'TFQMASTER')
oView:AddGrid("VIEW_GRID_TFR",oStruTFR,"TFRFUNC")
oView:AddGrid("VIEW_GRID_TFOA",oStruTFOA,"TFOARMA")
oView:AddGrid("VIEW_GRID_TFOM",oStruTFOM,"TFOMUNI")
oView:AddGrid("VIEW_GRID_TFOC",oStruTFOC,"TFOCOLE")

oView:CreateHorizontalBox('SUPERIOR',65)
oView:CreateHorizontalBox('INFERIOR',35)

// Criação da pasta para conter as abas da parte inferior
oView:CreateFolder( "ABAS", "INFERIOR" )

// Criação das Abas
oView:AddSheet( "ABAS", "ABA01", STR0089 )	// 'Destinatários'
oView:AddSheet( "ABAS", "ABA02", STR0090 )			// 'Armas'
oView:AddSheet( "ABAS", "ABA03", STR0091 )			// 'Munição'
oView:AddSheet( "ABAS", "ABA04", STR0092 )			// "Coletes"

// Criação das áreas de exibição dos dados nas abas
oView:CreateHorizontalBox( "ID_ABA01", 100,,, "ABAS", "ABA01" )
oView:CreateHorizontalBox( "ID_ABA02", 100,,, "ABAS", "ABA02" )
oView:CreateHorizontalBox( "ID_ABA03", 100,,, "ABAS", "ABA03" )
oView:CreateHorizontalBox( "ID_ABA04", 100,,, "ABAS", "ABA04" )

// Relacionando o componente da interface com o componente de dados.
oView:SetOwnerView( 'VIEW_CAB', 'SUPERIOR' )			// Cabeçalho da Movimentação		
oView:SetOwnerView( 'VIEW_GRID_TFR', 'ID_ABA01' )	// Grid Destinatários 
oView:SetOwnerView( 'VIEW_GRID_TFOA', 'ID_ABA02' )	// Grid Armas
oView:SetOwnerView( 'VIEW_GRID_TFOM', 'ID_ABA03' )	// Grid Munição
oView:SetOwnerView( 'VIEW_GRID_TFOC', 'ID_ABA04' )	// Grid Coletes

// Adicionando Consulta F3
If _lGsOrcArm
	// Grid de ARMAS:
	oStruTFOA:SetProperty('TFO_ITCOD',MVC_VIEW_LOOKUP,'ARMCON')
	oStruTFOA:SetProperty('TFO_CODTXQ',MVC_VIEW_LOOKUP,'TXQARM')
	// Grid de COLETES:
	oStruTFOC:SetProperty('TFO_ITCOD',MVC_VIEW_LOOKUP,'COLCON')
	oStruTFOC:SetProperty('TFO_CODTXQ',MVC_VIEW_LOOKUP,'TXQCOL')
	// Grid de MUNIÇÕES:
	oStruTFOM:SetProperty('TFO_ITCOD',MVC_VIEW_LOOKUP,'MUNCOD')
	oStruTFOM:SetProperty('TFO_CODTXQ',MVC_VIEW_LOOKUP,'TXQMUN')
else
	oStruTFOA:SetProperty('TFO_ITCOD',MVC_VIEW_LOOKUP,'SB1ARM')
	oStruTFOC:SetProperty('TFO_ITCOD',MVC_VIEW_LOOKUP,'SB1COL')
	oStruTFOM:SetProperty('TFO_PRODUT',MVC_VIEW_LOOKUP,'SB1MUN')
Endif	

oView:AddIncrementField( 'VIEW_GRID_TFR', 'TFR_ITEM' )

// Aba Armas
oStruTFOA:SetProperty('TFO_ITMOV', MVC_VIEW_ORDEM, '01')
oStruTFOA:SetProperty('TFO_ITCOD', MVC_VIEW_ORDEM, '02')
oStruTFOA:SetProperty('TFO_DESCR', MVC_VIEW_ORDEM, '03')

//Aba Coletes
oStruTFOC:SetProperty('TFO_ITMOV', MVC_VIEW_ORDEM, '01')
oStruTFOC:SetProperty('TFO_ITCOD', MVC_VIEW_ORDEM, '02')
oStruTFOC:SetProperty('TFO_DESCR', MVC_VIEW_ORDEM, '03')

// Aba Munições
If _lGsOrcArm
	oStruTFOM:SetProperty('TFO_ITMOV' , MVC_VIEW_ORDEM, '01')
	oStruTFOM:SetProperty('TFO_ITCOD' , MVC_VIEW_ORDEM, '02')
	oStruTFOM:SetProperty('TFO_PRODUT', MVC_VIEW_ORDEM, '03')
	oStruTFOM:SetProperty('TFO_DESCR' , MVC_VIEW_ORDEM, '04')
Else
	oStruTFOM:SetProperty('TFO_ITMOV' , MVC_VIEW_ORDEM, '01')
	oStruTFOM:SetProperty('TFO_PRODUT', MVC_VIEW_ORDEM, '02')
	oStruTFOM:SetProperty('TFO_DSCMUN', MVC_VIEW_ORDEM, '03')
EndIf

oStruTFQ:SetProperty("TFQ_ORIGEM" ,MVC_VIEW_ORDEM, Soma1(oStruTFQ:GetProperty('TFQ_ENTORI' , MVC_VIEW_ORDEM)))
oStruTFQ:SetProperty("TFQ_DSCLOC" ,MVC_VIEW_ORDEM, Soma1(oStruTFQ:GetProperty('TFQ_ORIGEM' , MVC_VIEW_ORDEM)))
oStruTFQ:SetProperty('TFQ_ORIGEM', MVC_VIEW_CANCHANGE, .T.)

If _lGsOrcArm
	oStruTFQ:SetProperty('TFQ_CONTRT', MVC_VIEW_ORDEM, '04')
	If lExstRev
		oStruTFQ:SetProperty('TFQ_CONREV', MVC_VIEW_ORDEM, '05')
	EndIf

Endif

If FindFunction("TecMtFlArm")
	If TFQ->(ColumnPos("TFQ_FILORI")) > 0
		If !TecMtFlArm()
			oStruTFQ:RemoveField("TFQ_FILORI")
		Else
			oStruTFQ:SetProperty("TFQ_FILORI" ,MVC_VIEW_ORDEM, '07')
		Endif
	EndIf
	If TFQ->(ColumnPos("TFQ_FILDES")) > 0
		If !TecMtFlArm()
			oStruTFQ:RemoveField("TFQ_FILDES")
		Else
			oStruTFQ:SetProperty("TFQ_FILDES" ,MVC_VIEW_ORDEM, '10')
		Endif
	Endif
Endif
If  oModel:GetOperation() == MODEL_OPERATION_VIEW .AND. ExistBlock("Tec880ImpProt")
	oView:AddUserButton(STR0093,"",{|oModel| At800RIm(oModel ,oView)},,,) // "Reimprimir protocolo"
	
EndIf

oView:SetCloseOnOk({|| .T.} )

Return(oView)

//--------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} At880Active

Verifica se o Status da Movimentação está Efetivada ou cancelada e não permite a sua edição
@author Serviços
@since 17/10/13
@version P11 R9

@return lRet, Retorna .T. se houve sucesso
/*/
//--------------------------------------------------------------------------------------------------------------------
Static Function At880Active(oMdl)
Local nOperation 	:= oMdl:GetOperation()
Local lRet			:= .T.

If (nOperation == MODEL_OPERATION_UPDATE .Or. nOperation == MODEL_OPERATION_DELETE) .And. TFQ->TFQ_STATUS <> stAGENDADA
	Help( ,, "At880Active",, STR0007, 1, 0 )//"Movimentação",'Não é permitido alterar ou excluir a Movimentação Efetivada / Cancelada.'
	lRet := .F.
EndIf

Return(lRet)

//--------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} At880PosValid

Pos-Validação do cadastro de Movimentação
@author Serviços
@since 28/08/13
@version P11 R9

@return lRet, Retorna .T. se houve sucesso
/*/
//--------------------------------------------------------------------------------------------------------------------
Static Function At880PosValid(oMdl)
	Local cMotivo      := ""
	Local lAT880VldMun := ExistBlock("AT880VLDMUN")
	Local lRet         := .T.
	Local lSoma        := .F.
	Local lSomaMun     := .F.
	Local lSubtrai     := .F.
	Local nA           := 0
	local nMaxArma     := 0
	local nMaxMuni     := 0
	local nMinMuni     := 0
	Local nQtdAPO      := 0
	Local nQtdArma     := 0
	Local nQtdCol      := 0
	Local nQtdMuni     := 0
	Local nQtdTXQ      := 0
	local nQtmov       := 0
	Local oMdlArma     := Nil
	Local oMdlCol      := Nil
	Local oMdlMuni     := Nil

	Begin Transaction

		// Validação os campos da manutenção. 
		If lRet 
			lRet := At880MntCmp()
		EndIf

		If lRet
			// Grid de Armas
			oMdlArma := oMdl:GetModel():GetModel('TFOARMA')
			// Grid de Munições		
			oMdlMuni := oMdl:GetModel():GetModel('TFOMUNI') 
			// Grid de Coletes
			oMdlCol := oMdl:GetModel():GetModel('TFOCOLE')

			// Verifica a quantidade de itens válidos
			nQtdArma += At880SumIt(oMdlArma) 
			nQtdMuni += At880SumIt(oMdlMuni)
			nQtdCol += At880SumIt(oMdlCol)

			If lRet .And. ((nQtdArma+nQtdMuni+nQtdCol) == 0)
				Help( ,, "At880PosValid",, STR0063, 1, 0 ) //'Alocação''Nenhum item de armamento foi selecionado!'
				lRet := .F.
			EndIf

			If lRet .And. nQtdArma > 0
				//Verifica as datas de Retorno e da movimentação
				lRet := At880Status(oMdlArma)
			EndIf	
			If lRet .And. nQtdMuni > 0
				//Verifica as datas de Retorno e da movimentação	
				lRet := At880Status(oMdlMuni,.T.)	
			EndIf
			If lRet
				//Verifica as datas de Retorno e da movimentação
				lRet := At880Status(oMdlCol)
			EndIf
			If lRet  .And. nQtdArma > 0
				//Verifica se foi preenchido o Numero da Guia
				lRet := At880VldGuia(oMdlArma)
			EndIf
			If lRet .And. nQtdMuni > 0
				//Verifica se foi preenchido o Numero da Guia
				lRet := At880VldGuia(oMdlMuni)
			EndIf

			// Lógica de Contabilização na TXQ_QTDAPO:
			If lRet .And. _lGsOrcArm .And. FwFldGet("TFQ_STATUS") == stEFETIVADA

				cContrato := FwFldGet("TFQ_CONTRT") // Contrato - Onde o armamento está
				cEntOri   := FwFldGet("TFQ_ENTORI") // Entidade de Origem - 1=Local Interno;2=Local de Atendimento
				cEntDest  := FwFldGet("TFQ_ENTDES") // Endidade de Destino - 1=Cliente;2=Empresa
				cMotivo   := FwFldGet("TFQ_MOTIVO") // Motivo - 1=Agendada;2=Efetivada;3=Cancelada

				// Cofre para Cofre (interna)
				lMovInterna :=  Empty(cContrato) .And. cEntOri == eoLOCINTER .And. cEntDest == edEMPRESA 
				// Cofre para Contrato
				lMovCofre   := !Empty(cContrato) .And. cEntOri == eoLOCINTER .And. cEntDest == edCLIENTE
				// Contrato para Cofre
				lMovContr 	:= !Empty(cContrato) .And. cEntOri == eoLOCATEND .And. cEntDest == edEMPRESA

				If lMovCofre
					If cMotivo == mtIMPLANTACAO //.Or. cMotivo == mtREFORCO não contabiliza reforço por ser EXCEDENTE para Armas e Coletes
						lSoma := .T. // Soma a quantidade no TXQ_QTDAPO
					EndIf
					If cMotivo == mtIMPLANTACAO .Or. cMotivo == mtREFORCO // Soma para munições
						lSomaMun := .T. // Soma a quantidade no TXQ_QTDAPO
					EndIf
				ElseIf lMovContr
					If cMotivo == mtMANUTENCAO .Or. cMotivo == mtDESCARTE .Or. cMotivo == mtENCERRAMENTO
						lSubtrai := .T. // Subtrai a quantidade no TXQ_QTDAPO
					EndIf
				EndIf

				// Lógica para Armas:
				If lRet .And. nQtdArma > 0 .And. (lSoma .Or. lSubtrai)
					TE0->(DbSetorder(1))
					For nA := 1 to oMdlArma:Length()
						oMdlArma:Goline(nA)
						If !oMdlArma:Isdeleted()
							If !Empty(oMdlArma:GetValue("TFO_ITCOD")) .And. !Empty(oMdlArma:GetValue("TFO_CODTXQ"))
								If TE0->(MsSeek( FwXFilial("TE0") + oMdlArma:GetValue("TFO_ITCOD")))     
									If TXQ->(MsSeek(xFilial("TXQ")+oMdlArma:GetValue("TFO_CODTXQ")))
										If lSoma
											If (TE0->TE0_SITUA == '1') // Arma ATIVA:
												nQtdTXQ := TXQ->TXQ_QTDVEN
												nMaxArma := TXQ->TXQ_QTDAPO + 1
												If nMaxArma <= nQtdTXQ
													RecLock("TXQ",.F.) 
														TXQ->TXQ_QTDAPO := TXQ->TXQ_QTDAPO + 1
													TXQ->(MsUnlock())
												Else
													DisarmTransaction()
													lRet := .F.
													Help(,,"At880Posvalid",, STR0097+" "+STR0098, 1, 0,,,,,,{"O problema ocorreu na linha "+cValtoChar(nA)+" da aba de Armas. Código da arma: "+oMdlArma:GetValue("TFO_ITCOD")}) // //"Quantidade excedida para movimentação A quantidade de armas foi excedida. Verifique o contrato" ## "O problema ocorreu na linha X da grid de Armas."
													Exit
												Endif	
											Else
												DisarmTransaction()
												lRet := .F.
												Help(,,"At880Posvalid",, "A Arma não está ativa para implantação ou reforço.", 1, 0,,,,,,{"O problema ocorreu na linha "+cValtoChar(nA)+" da aba de Armas. Código da arma: "+oMdlArma:GetValue("TFO_ITCOD")}) // "A Arma não está ativa para implantação ou reforço." ## "O problema ocorreu na linha X da grid de Armas."
												Exit
											EndIf	
										ElseIf lSubtrai
											If (TE0->TE0_SITUA == '2') // Implantada
												If !isReforco(oMdl, TE0->TE0_COD, itARMA) //Verifica se a implantação dessa arma é REFORÇO
													RecLock("TXQ",.F.)
														TXQ->TXQ_QTDAPO := TXQ->TXQ_QTDAPO - 1
													TXQ->(MsUnlock())
												EndIf
											Else
												DisarmTransaction()
												lRet := .F.
												Help(,,"At880Posvalid",, "A Arma não está implantada.", 1, 0,,,,,,{"O problema ocorreu na linha "+cValtoChar(nA)+" da aba de Armas. Código da arma: "+oMdlArma:GetValue("TFO_ITCOD")}) // "A Arma não está ativa para implantação ou reforço." ## "O problema ocorreu na linha X da grid de Armas."
												Exit
											EndIf
										EndIf		
									Endif
								Endif	
							Else
								DisarmTransaction()
								lRet := .F.
								Help(,,"At880Posvalid",, "Código (TFO_ITCOD) ou Destino (TFO_CODTXQ) não preenchido.", 1, 0,,,,,,{"O problema ocorreu na linha "+cValtoChar(nA)+" da aba de Armas."}) // "Código (TFO_ITCOD) ou Destino (TFO_CODTXQ) não preenchido." ## "O problema ocorreu na linha X da grid de Armas."
								Exit
							Endif
						EndIf
					Next nA
				EndIf

				// Lógica parO Coletes:
				If lRet .And. nQtdCol > 0 .And. (lSoma .Or. lSubtrai)
					TE1->(DbSetorder(1))
					For nA := 1 to oMdlCol:Length()
						oMdlCol:Goline(nA)
						If !oMdlCol:Isdeleted()
							If !Empty(oMdlCol:GetValue("TFO_ITCOD")) .And. !Empty(oMdlCol:GetValue("TFO_CODTXQ"))
								If TE1->(MsSeek( FwXFilial("TE1") + oMdlCol:GetValue("TFO_ITCOD")))     
									If TXQ->(MsSeek(xFilial("TXQ")+oMdlCol:GetValue("TFO_CODTXQ")))
										If lSoma
											If (TE1->TE1_SITUA == '1') // Arma ATIVA:
												nQtdTXQ := TXQ->TXQ_QTDVEN
												nMaxArma := TXQ->TXQ_QTDAPO + 1
												If nMaxArma <= nQtdTXQ
													RecLock("TXQ",.F.) 
														TXQ->TXQ_QTDAPO := TXQ->TXQ_QTDAPO + 1
													TXQ->(MsUnlock())
												Else
													DisarmTransaction()
													lRet := .F.
													Help(,,"At880Posvalid",, STR0097+" "+STR0098, 1, 0,,,,,,{"O problema ocorreu na linha "+cValtoChar(nA)+" da aba de Coletes. Código do colete: "+oMdlCol:GetValue("TFO_ITCOD")}) // //"Quantidade excedida para movimentação A quantidade de armas foi excedida. Verifique o contrato" ## "O problema ocorreu na linha X da grid de Armas."
													Exit
												Endif	
											Else
												DisarmTransaction()
												lRet := .F.
												Help(,,"At880Posvalid",, "O Colete não está ativa para implantação ou reforço.", 1, 0,,,,,,{"O problema ocorreu na linha "+cValtoChar(nA)+" da aba de Coletes. Código do colete: "+oMdlCol:GetValue("TFO_ITCOD")}) // "O Colete não está ativa para implantação ou reforço." ## "O problema ocorreu na linha X da grid de Armas."
												Exit
											EndIf	
										ElseIf lSubtrai
											If (TE1->TE1_SITUA == '2') // Implantada
												If !isReforco(oMdl, TE1->TE1_CODCOL, itCOLETE) //Verifica se a implantação desse Colete é REFORÇO
													RecLock("TXQ",.F.)
														TXQ->TXQ_QTDAPO := TXQ->TXQ_QTDAPO - 1
													TXQ->(MsUnlock())
												EndIf
											Else
												DisarmTransaction()
												lRet := .F.
												Help(,,"At880Posvalid",, "O Colete não está implantada.", 1, 0,,,,,,{"O problema ocorreu na linha "+cValtoChar(nA)+" da aba de Coletes. Código do colete: "+oMdlCol:GetValue("TFO_ITCOD")}) // "O Colete não está ativa para implantação ou reforço." ## "O problema ocorreu na linha X da grid de Armas."
												Exit
											EndIf
										EndIf		
									Endif
								Endif	
							Else
								DisarmTransaction()
								lRet := .F.
								Help(,,"At880Posvalid",, "Código (TFO_ITCOD) ou Destino (TFO_CODTXQ) não preenchido.", 1, 0,,,,,,{"O problema ocorreu na linha "+cValtoChar(nA)+" da aba de Armas."}) // "Código (TFO_ITCOD) ou Destino (TFO_CODTXQ) não preenchido." ## "O problema ocorreu na linha X da grid de Armas."
								Exit
							Endif	
						EndIf
					Next nA
				EndIf

				// Lógica para Munições:
				If lRet .And. nQtdMuni > 0 .And. (lSomaMun .Or. lSubtrai)
					TE2->(DbSetorder(1))
					For nA := 1 to oMdlMuni:Length()
						oMdlMuni:Goline(nA)
						If !oMdlMuni:Isdeleted()
							If !Empty(oMdlMuni:GetValue("TFO_ITCOD")) .And. !Empty(oMdlMuni:GetValue("TFO_CODTXQ"))
								If TE2->(MsSeek( FwXFilial("TE2") + oMdlMuni:GetValue("TFO_ITCOD")))     
									If TXQ->(MsSeek(xFilial("TXQ")+oMdlMuni:GetValue("TFO_CODTXQ")))
										If lSomaMun
											nQtdTXQ  := TXQ->TXQ_QTDVEN
											nQtmov   := oMdlMuni:GetValue("TFO_QTDE") //Quantidade solicitada
											nMaxMuni := TXQ->TXQ_QTDAPO + nQtmov
											If	nMaxMuni <= nQtdTXQ
												RecLock("TXQ",.F.) 
													TXQ->TXQ_QTDAPO := TXQ->TXQ_QTDAPO +  nQtmov
												TXQ->(MsUnlock())
											Else
												DisarmTransaction()
												lRet := .F.
												Help(,,"At880Posvalid",, STR0097+" "+STR0098, 1, 0,,,,,,{"O problema ocorreu na linha "+cValtoChar(nA)+" da aba de Munções. Código da munição: "+oMdlMuni:GetValue("TFO_ITCOD")}) // //"Quantidade excedida para movimentação A quantidade de armas foi excedida. Verifique o contrato" ## "O problema ocorreu na linha X da grid de Armas."
												Exit
											Endif		
										ElseIf lSubtrai
											nQtdTXQ  := TXQ->TXQ_QTDVEN 			  	// Quantidade do Orçamento
											nQtmov   := oMdlMuni:GetValue("TFO_QTDE") 	// Quantidade solicitada na movimentaçaõ
											nQtdAPO  := TXQ->TXQ_QTDAPO 				// Quantidade consumuda no orçamento
											nMinMuni := nQtdAPO - nQtmov				// Quantidade apontada - quantidade solicitada 
											If nQtdAPO >= nQtmov
												If nMinMuni <= nQtdTXQ
													RecLock("TXQ",.F.) 
														TXQ->TXQ_QTDAPO := TXQ->TXQ_QTDAPO - nQtmov
													TXQ->(MsUnlock())
												EndIf
											EndIf
										Endif	
									Endif
								Endif	
							Else
								DisarmTransaction()
								lRet := .F.
								Help(,,"At880Posvalid",, "Código (TFO_ITCOD) ou Destino (TFO_CODTXQ) não preenchido.", 1, 0,,,,,,{"O problema ocorreu na linha "+cValtoChar(nA)+" da aba de Munições."}) // "Código (TFO_ITCOD) ou Destino (TFO_CODTXQ) não preenchido." ## "O problema ocorreu na linha X da grid de Armas."
								Exit
							EndIf
						EndIf
					Next nA
				EndIf
			EndIf

		EndIf
		
		// PE com prazo de validade para permitir validação personalizadas
		If lRet .And. lAT880VldMun .And. !_lGsOrcArm .And. dDataBase <= SToD("31/12/2023")
			lRet := ExecBlock("AT880VLDMUN", .F., .F.)
		EndIf

		If !lRet
			DisarmTransaction()
		EndIf
		
	End Transaction
	
Return( lRet )

//--------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} At880LPArm
	Pos-Validação da linha do cadastro de Movimentação - Grid Armas

@param oModel,object,Objeto Master do formulário de movimentação
@param nLine,numerico,Linha da grade na edição atual

@sample At880LPArm(oMdl,nLine)

@author Serviços
@since 01/06/2015
@version P12

@return lRet, Retorna .T. se houve sucesso
/*/
//--------------------------------------------------------------------------------------------------------------------
Static Function At880LPArm(oMdl,nLine,cAcao,cCampo) 
Local lRet        := .T.
Local nOperation  := oMdl:GetOperation()
Local lArmMultFil := TecMtFlArm()
Local oMdlTFQ     := oMdl:GetModel():GetModel('TFQMASTER')
Local oStruTFQ    := Nil

If nOperation == MODEL_OPERATION_UPDATE .Or. nOperation == MODEL_OPERATION_INSERT

	If Empty(oMdl:GetValue('TFO_ITCOD'))
		Help( ,, "At880LPArm",, STR0102, 1, 0 ) //"O campo Armamento não esta preenchido. Verifique e tente novamente"
		lRet := .F.
	Endif

	If _lGsOrcArm .And. Empty(oMdl:GetValue('TFO_CODTXQ')) .And. (!Empty( oMdlTFQ:GetValue('TFQ_CONTRT')) .And. oMdlTFQ:GetValue('TFQ_ENTDES') == "1" )
		Help( ,, "At880LPArm",, STR0128, 1, 0 ) //"Para movimentações para o cliente é necessário preencher o campo TFO_CODTXQ do armamento."
		lRet := .F.
	Endif

	If oMdl:GetValue('TFO_LGUIA') == '1' .AND. Empty(oMdl:GetValue('TFO_NRGUIA'))
		Help( ,, "At880LPArm",, STR0012, 1, 0 ) //"Preencha o Numero da Guia"
		lRet := .F.
	EndIf
	
	If lRet .And. _lGsOrcArm .And. lArmMultFil
		oStruTFQ := oMdlTFQ:GetStruct()
		If Empty( oMdlTFQ:GetValue('TFQ_CONTRT') )
			oStruTFQ:SetProperty( 'TFQ_CONTRT', MODEL_FIELD_OBRIGAT, .F. )
		Else
			If !oStruTFQ:GetProperty( 'TFQ_CONTRT', MODEL_FIELD_OBRIGAT )
				oStruTFQ:SetProperty( 'TFQ_CONTRT', MODEL_FIELD_OBRIGAT, .T. )
			EndIf
		EndIf
	EndIf

EndIf

Return lRet

//--------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} At880LPCol
	Pos-Validação da linha do cadastro de Movimentação - Grid Coletes

@param oModel,object,Objeto Master do formulário de movimentação
@param nLine,numerico,Linha da grade na edição atual

@sample At880LPCol(oMdl,nLine,cAcao,cCampo)

@author Serviços
@since 06/03/2023
@version P12

@return lRet, Retorna .T. se houve sucesso
/*/
//--------------------------------------------------------------------------------------------------------------------
Static Function At880LPCol(oMdl,nLine,cAcao,cCampo) 
	Local lArmMultFil := TecMtFlArm()
	Local lRet        := .T.
	Local nOperation  := oMdl:GetOperation()
	Local oMdlTFQ     := oMdl:GetModel():GetModel( 'TFQMASTER' )
	Local oStruTFQ    := Nil

	If nOperation == MODEL_OPERATION_UPDATE .Or. nOperation == MODEL_OPERATION_INSERT

		If oMdl:GetValue('TFO_LGUIA') == '1' .AND. Empty(oMdl:GetValue('TFO_NRGUIA'))
			Help( ,, "At880LPCol",, STR0012, 1, 0 ) //"Preencha o Numero da Guia"
			lRet := .F.
		EndIf

		If Empty(oMdl:GetValue('TFO_ITCOD')) .OR. ( _lGsOrcArm .And. Empty(oMdl:GetValue('TFO_CODTXQ')) .And. IIf( !Empty( oMdlTFQ:GetValue('TFQ_CONTRT') ), .T., !lArmMultFil ) )
			Help( ,, "At880LPCol",, STR0103, 1, 0 ) //"O campo Armamento(Colete) não esta preenchido. Verifique e tente novamente"
			lRet := .F.
		Endif

		If lRet .And. _lGsOrcArm .And. lArmMultFil
			oStruTFQ := oMdlTFQ:GetStruct()
			If Empty( oMdlTFQ:GetValue('TFQ_CONTRT') )
				oStruTFQ:SetProperty( 'TFQ_CONTRT', MODEL_FIELD_OBRIGAT, .F. )
			Else
				If !oStruTFQ:GetProperty( 'TFQ_CONTRT', MODEL_FIELD_OBRIGAT )
					oStruTFQ:SetProperty( 'TFQ_CONTRT', MODEL_FIELD_OBRIGAT, .T. )
				EndIf
			EndIf
		EndIf

	EndIf

Return lRet

//--------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} At880LPMun
	Pos-Validação da linha do cadastro de Movimentação - Grid Munições

@param oModel,object,Objeto Master do formulário de movimentação
@param nLine,numerico,Linha da grade na edição atual

@sample At880LPMun(oMdl,nLine,cAcao,cCampo)

@author Serviços
@since 08/07/2015
@version P12

@return lRet, Retorna .T. se houve sucesso
/*/
//--------------------------------------------------------------------------------------------------------------------
Static Function At880LPMun(oMdl,nLine,cAcao,cCampo)
Local lRet := .T.
Local nOperation := oMdl:GetOperation()
Local lAT880VldMun := ExistBlock("AT880VLDMUN")
Local lRetPE := .F.
Local lArmMultFil := TecMtFlArm()
Local oMdlTFQ := oMdl:GetModel():GetModel('TFQMASTER')
Local oStruTFQ := Nil

If nOperation == MODEL_OPERATION_UPDATE .Or. nOperation == MODEL_OPERATION_INSERT

	If oMdl:GetValue('TFO_LGUIA') == '1' .AND. Empty(oMdl:GetValue('TFO_NRGUIA'))
		Help( ,, "At880LPMun",, STR0012, 1, 0 ) //'Alocação','Preencha o Numero da Guia!'
		lRet := .F.
	EndIf

	// PE com prazo de validade para permitir validação personalizadas
	If lAT880VldMun .And. !_lGsOrcArm .And. dDataBase <= SToD("31/12/2023")
		lRetPE := ExecBlock("AT880VLDMUN", .F., .F.)
	EndIf

	If !lRetPE .And. (Empty(oMdl:GetValue('TFO_PRODUT')) .OR. ( _lGsOrcArm .And. Empty(oMdl:GetValue('TFO_CODTXQ'))) .And. IIf( !Empty( oMdlTFQ:GetValue('TFQ_CONTRT') ), .T., !lArmMultFil ) )
		Help( ,, "At880LPMun",, STR0104, 1, 0 ) //"O Codigo do produto nao esta preenchido."
		lRet := .F.
	EndIf

	If oMdl:GetValue('TFO_QTDE') <= 0
		Help( ,, "At880LPMun",, STR0105, 1, 0 ) //"Quantidade nao esta preenchida."
		lRet := .F.
	EndIf

	If lRet .And. _lGsOrcArm .And. lArmMultFil
		oStruTFQ := oMdlTFQ:GetStruct()
		If Empty( oMdlTFQ:GetValue('TFQ_CONTRT') )
			oStruTFQ:SetProperty( 'TFQ_CONTRT', MODEL_FIELD_OBRIGAT, .F. )
		Else
			If !oStruTFQ:GetProperty( 'TFQ_CONTRT', MODEL_FIELD_OBRIGAT )
				oStruTFQ:SetProperty( 'TFQ_CONTRT', MODEL_FIELD_OBRIGAT, .T. )
			EndIf
		EndIf
	EndIf

EndIf

Return lRet

//--------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} At880PosTRF

Pos-Validação do cadastro de Movimentação - Grid Reponsaveis
@author Serviços
@since 28/08/13
@version P11 R9

@return lRet, Retorna .T. se houve sucesso
/*/
//--------------------------------------------------------------------------------------------------------------------
Static Function At880PosTRF(oModel)
Local lRet			:= .T.
Local nI			:= 0
Local aArea		:= GetArea()

For nI := 1 to oModel:Length()
	oModel:GoLine(nI)
	//Verifica se o campo CNV está preenchido
	If (oModel:IsUpdated() .Or. oModel:IsInserted())
		DbSelectArea("AA1")
		AA1->(DbSetOrder(1))
		
		If AA1->(DbSeek(xFilial("AA1") + FwFldGet("TFR_CODTEC")))
			If Empty(AA1->AA1_CNV)
				Help( ,, "At880PosTRF",, STR0058 + cValToChar(nI) + STR0059, 1, 0 )//"O Atendente selecionado na linha: "##" não está com a CNV preenchida"
				lRet:= .F.	
			EndIf
		EndIf
	EndIf
	
Next nI

RestArea(aArea)

Return(lRet)


//--------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} At880PosTFQ

Pos-Validação do cadastro de Movimentação - Geral

@author 	Serviços
@since 		28/08/13
@version 	P11 R9

@return 	lRet, Retorna .T. se houve sucesso
/*/
//--------------------------------------------------------------------------------------------------------------------
Static Function At880PosTFQ(oModel)

Local lRet			:= .T.
Local aArea		:= GetArea()
Local nI 			:= 0
Local oTFOMuni		:= oModel:GetModel('TFOMUNI')
Local aRows 		:= FwSaveRows()

If Empty(FwFldGet("TFQ_CONTRT")) .And. FwFldGet("TFQ_ENTDES") == edCLIENTE 
	lRet := At680Perm( Nil, __cUserId, "007" ) // Pode movimentar armamento fora do contrato?
	If !lRet
		Help( ,, 'AT880ACE',, STR0060, 1, 0) // "Usuário sem permissão para movimentação fora do contrato!"		
	EndIf
EndIf

If lRet 
	For nI := 1 To oTFOMuni:Length()		
		oTFOMuni:GoLine(nI)
		If !oTFOMuni:IsDeleted() .And. !Empty(oTFOMuni:GetValue('TFO_PRODUT'))
			lRet := At880VldQt(oModel)
			If !lRet
				Exit
			EndIf	
		EndIf	
	Next nI	
EndIf

RestArea(aArea)
FwRestRows( aRows )
Return(lRet)


//--------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} At880PRArm
Pre-Validação da linha do cadastro de Movimentação - Grid Armas
@author flavio.vicco
@since 01/08/2023
@return	lRet, Retorna .T. se houve sucesso
/*/
//--------------------------------------------------------------------------------------------------------------------
Static Function At880PRArm(oMdl, nLine, cAcao, cCampo, xValue, xOldValue)
	Local lOk := .T.

	If _lGsOrcArm
		If cAcao == "UNDELETE"
			If oMdl:SeekLine({{"TFO_ITCOD",oMdl:getvalue("TFO_ITCOD")}},.F.,.F.)
				Help(,,"At880PPRMun",,"Não é possível restaurar a linha pois irá repetir o código de uma arma na movimentação de Armas.",1,0)
				lOk := .F.
			EndIf
		EndIf
	EndIf

Return lOk

//--------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} At880PRCol
Pre-Validação da linha do cadastro de Movimentação - Grid Coletes
@author flavio.vicco
@since 01/08/2023
@return	lRet, Retorna .T. se houve sucesso
/*/
//--------------------------------------------------------------------------------------------------------------------
Static Function At880PRCol(oMdl, nLine, cAcao, cCampo, xValue, xOldValue)
	Local lOk := .T.

	If _lGsOrcArm
		If cAcao == "UNDELETE"
			If oMdl:SeekLine({{"TFO_ITCOD",oMdl:getvalue("TFO_ITCOD")}},.F.,.F.)
				Help(,,"At880PRCol",,"Não é possível restaurar a linha pois irá repetir o código de uma arma na movimentação de Coletes.",1,0)
				lOk := .F.
			EndIf
		EndIf
	EndIf

Return lOk

//--------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} At880PRMun
Pre-Validação da linha do cadastro de Movimentação - Grid Muniçoes
@author flavio.vicco
@since 01/08/2023
@return	lRet, Retorna .T. se houve sucesso
/*/
//--------------------------------------------------------------------------------------------------------------------
Static Function At880PRMun(oMdl, nLine, cAcao, cCampo, xValue, xOldValue)
Local lOk := .T.
Return lOk

//--------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} At880Cmt23

Realiza a gravação da movimentação e alteração de Status dos armamentos (versão 23 ou superior)
@author Serviços
@since 18/12/2018
@version P11 R9

@return lRet, Retorna .T. se houve sucesso
/*/
//--------------------------------------------------------------------------------------------------------------------
Function At880Cmt23(oMdl)

	Local cItArma    := ''
	Local cTpArma    := ''
	Local dRetorno   := CToD( '' )
	Local lRet       := .T.
	Local nI         := 0
	Local nOperation := oMdl:GetOperation()
	Local oMdlAux    := Nil

	If nOperation == MODEL_OPERATION_INSERT .Or. nOperation == MODEL_OPERATION_UPDATE

		Begin Transaction
			Do Case
				Case FwFldGet("TFQ_MOTIVO") == mtIMPLANTACAO  .Or. FwFldGet("TFQ_MOTIVO") == mtREFORCO //Implantação ou Reforço

					//Verifica se os campos de manutenção estão preenchidos, senão realiza a sua limpeza
					If !(Empty(FwFldGet("TFQ_CDRESP"))) .Or. !(Empty(FwFldGet("TFQ_TPMNT"))) .Or. !(Empty(FwFldGet("TFQ_MOTMNT")))
						At880MntClean()
					EndIf

					//Altera a situação do Armamento		
					If FwFldGet("TFQ_STATUS") == stEFETIVADA

						// Instancia Grid Armas			
						oMdlAux	:= oMdl:GetModel('TFOARMA')
						cTpArma := itARMA
						If	!( oMdlAux:IsEmpty() )
							For nI := 1 To oMdlAux:Length()
								oMdlAux:GoLine(nI)
								cItArma  := oMdlAux:getValue('TFO_ITCOD')
								dRetorno := oMdlAux:GetValue('TFO_DTRET')
								If !oMdlAux:IsDeleted() .AND. !Empty(cItArma)
									At880SitArma(cTpArma,cItArma,dRetorno)	//Altera o Status da Arma para Implantada
								EndIf
							Next nI
						EndIf

						// Instancia Grid Coletes
						oMdlAux	:= oMdl:GetModel('TFOCOLE')
						cTpArma := itCOLETE
						If	!( oMdlAux:IsEmpty() )
							For nI := 1 To oMdlAux:Length()
								oMdlAux:GoLine(nI)
								cItArma  := oMdlAux:getValue('TFO_ITCOD')
								dRetorno := oMdlAux:GetValue('TFO_DTRET')
								If !oMdlAux:IsDeleted() .AND. !Empty(cItArma)
									At880SitArma(cTpArma,cItArma,dRetorno)	//Altera o Status da Arma para Implantada
								EndIf
							Next nI
						EndIf

						// Instancia Grid Munição
						oMdlAux	:= oMdl:GetModel('TFOMUNI')
						cTpArma	:= itMUNICAO
						If	!( oMdlAux:IsEmpty() )
							For nI := 1 To oMdlAux:Length()
								oMdlAux:GoLine(nI)
								//cItArma:= oMdlAux:getValue('TFO_ITCOD')
								cItArma:= oMdlAux:getValue('TFO_PRODUT')
								nQtd	:= oMdlAux:GetValue('TFO_QTDE')
								If !oMdlAux:IsDeleted() .AND. !Empty(cItArma)
									At880IncTFP(cItArma,nQtd)				//Altera o Saldo da Munição
									At880SitArma(cTpArma,cItArma,dRetorno)	//Altera o Status da Municao para Implantada
								EndIf
							Next nI
						EndIf
					EndIf

				Case FwFldGet("TFQ_MOTIVO") == mtMANUTENCAO //Manutenção

					If FwFldGet("TFQ_STATUS") == stEFETIVADA

						// Instancia Grid Armas			
						oMdlAux	:= oMdl:GetModel('TFOARMA')
						cTpArma := itARMA
						If	!( oMdlAux:IsEmpty() )
							For nI := 1 To oMdlAux:Length()
								oMdlAux:GoLine(nI)
								cItArma  := oMdlAux:getValue('TFO_ITCOD')
								dRetorno := oMdlAux:GetValue('TFO_DTRET')
								If !oMdlAux:IsDeleted() .AND. !Empty(cItArma)
									At880SitArma(cTpArma,cItArma,dRetorno)	//Altera o Status da Arma para Ativa
									//Gera o registro de manutenção
									At880IncManut(oMdl,cTpArma,cItArma)
								EndIf
							Next nI
						EndIf

						// Instancia Grid Coletes
						oMdlAux	:= oMdl:GetModel('TFOCOLE')
						cTpArma := itCOLETE
						If	!( oMdlAux:IsEmpty() )
							For nI := 1 To oMdlAux:Length()
								oMdlAux:GoLine(nI)
								cItArma  := oMdlAux:getValue('TFO_ITCOD')
								dRetorno := oMdlAux:GetValue('TFO_DTRET')
								If !oMdlAux:IsDeleted() .AND. !Empty(cItArma)
									At880SitArma(cTpArma,cItArma,dRetorno)	//Altera o Status da Arma para Ativa
									//Gera o registro de manutenção
									If !(lRet := At880IncManut(oMdl,cTpArma,cItArma))
										Exit
									EndIf
								EndIf
							Next nI
						EndIf

						// Instancia Grid Munição
						oMdlAux	:= oMdl:GetModel('TFOMUNI')
						cTpArma	:= itMUNICAO
						If	!( oMdlAux:IsEmpty() )
							For nI := 1 To oMdlAux:Length()
								oMdlAux:GoLine(nI)
								cItArma:= oMdlAux:getValue('TFO_PRODUT')
								nQtd	:= oMdlAux:GetValue('TFO_QTDE')
								If !oMdlAux:IsDeleted() .AND. !Empty(cItArma)
									At880IncTFP(cItArma,nQtd)				//Altera o Saldo da Munição
								EndIf
							Next nI
						EndIf

						If lRet
							ApMsgInfo( STR0041, STR0042 ) //'Manutenção incluida com sucesso.','ATENÇÃO'
						EndIf
					EndIf

				Case FwFldGet("TFQ_MOTIVO") == mtDESCARTE //Descarte

					If FwFldGet("TFQ_STATUS") == stEFETIVADA

						// Instancia Grid Armas			
						oMdlAux	:= oMdl:GetModel('TFOARMA')
						cTpArma := itARMA
						If	!( oMdlAux:IsEmpty() )
							For nI := 1 To oMdlAux:Length()
								oMdlAux:GoLine(nI)
								cItArma  := oMdlAux:getValue('TFO_ITCOD')
								dRetorno := oMdlAux:GetValue('TFO_DTRET')
								If !oMdlAux:IsDeleted() .AND. !Empty(cItArma)
									At880SitArma(cTpArma,cItArma,dRetorno)	//Altera o Status da Arma para Ativa
								EndIf
							Next nI
						EndIf

						// Instancia Grid Coletes
						oMdlAux	:= oMdl:GetModel('TFOCOLE')
						cTpArma := itCOLETE
						If	!( oMdlAux:IsEmpty() )
							For nI := 1 To oMdlAux:Length()
								oMdlAux:GoLine(nI)
								cItArma  := oMdlAux:getValue('TFO_ITCOD')
								dRetorno := oMdlAux:GetValue('TFO_DTRET')
								If !oMdlAux:IsDeleted() .AND. !Empty(cItArma)
									At880SitArma(cTpArma,cItArma,dRetorno)	//Altera o Status da Arma para Ativa
								EndIf
							Next nI
						EndIf

						// Instancia Grid Munição
						oMdlAux	:= oMdl:GetModel('TFOMUNI')
						cTpArma	:= itMUNICAO
						If	!( oMdlAux:IsEmpty() )
							For nI := 1 To oMdlAux:Length()
								oMdlAux:GoLine(nI)
								cItArma:= oMdlAux:getValue('TFO_PRODUT')
								nQtd	:= oMdlAux:GetValue('TFO_QTDE')
								If !oMdlAux:IsDeleted() .AND. !Empty(cItArma)
									At880IncTFP(cItArma,nQtd)				//Altera o Saldo da Munição
								EndIf
							Next nI
						EndIf
					Endif

				Case FwFldGet("TFQ_MOTIVO") == mtENCERRAMENTO //	Encerramento

					//	Verifica se os campos de manutenção estão preenchidos, senão realiza a sua limpeza
					If !(Empty(FwFldGet("TFQ_CDRESP"))) .Or. !(Empty(FwFldGet("TFQ_TPMNT"))) .Or. !(Empty(FwFldGet("TFQ_MOTMNT")))
						At880MntClean()
					EndIf

					//	Altera a situação do Armamento		
					If FwFldGet("TFQ_STATUS") == stEFETIVADA 

						//	Instancia Grid Armas
						oMdlAux := oMdl:GetModel('TFOARMA')
						If	!(oMdlAux:IsEmpty())
							cTpArma := itARMA
							For nI  := 1 To oMdlAux:Length()
								oMdlAux:GoLine(nI)
								cItArma  := oMdlAux:GetValue('TFO_ITCOD')
								dRetorno := oMdlAux:GetValue('TFO_DTRET')
								If !oMdlAux:IsDeleted() .And. !Empty(cItArma)
									At880SitArma(cTpArma, cItArma, dRetorno)	//	Altera o Status da Arma para Implantada
								EndIf
							Next
						EndIf

						//	Instancia Grid Coletes
						oMdlAux := oMdl:GetModel('TFOCOLE')
						If	!(oMdlAux:IsEmpty())
							cTpArma := itCOLETE
							For nI  := 1 To oMdlAux:Length()
								oMdlAux:GoLine(nI)
								cItArma  := oMdlAux:GetValue('TFO_ITCOD')
								dRetorno := oMdlAux:GetValue('TFO_DTRET')
								If !oMdlAux:IsDeleted() .And. !Empty(cItArma)
									At880SitArma(cTpArma, cItArma, dRetorno)	//	Altera o Status da Arma para Implantada
								EndIf
							Next
						EndIf

						//	Instancia Grid Munição
						oMdlAux := oMdl:GetModel('TFOMUNI')
						If	!(oMdlAux:IsEmpty())
							cTpArma := itMUNICAO
							For nI  := 1 To oMdlAux:Length()
								oMdlAux:GoLine(nI)
								cItArma := oMdlAux:GetValue('TFO_PRODUT')
								nQtd    := oMdlAux:GetValue('TFO_QTDE')
								If !oMdlAux:IsDeleted() .And. !Empty(cItArma)
									At880IncTFP(cItArma, nQtd)                 //	Altera o Saldo da Munição
									At880SitArma(cTpArma, cItArma, dRetorno)   //	Altera o Status da Municao para Implantada
								EndIf
							Next
						EndIf
					EndIf
			EndCase

			// Zera o campo de contrato quando a movimentação for interna
			If FwFldGet("TFQ_ENTDES") == edEMPRESA .And. !_lGsOrcArm
				oMdl:LoadValue( "TFQMASTER", "TFQ_CONTRT",  "" )
				If TFQ->(ColumnPos("TFQ_CONREV")) > 0
					oMdl:LoadValue( "TFQMASTER", "TFQ_CONREV",  "" )
				EndIf
			EndIf

		End Transaction

	EndIf

	//Imprime o Protocolo
	At880ImpPr(oMdl)

	FWModelActive( oMdl )
	FWFormCommit( oMdl )
Return(lRet)

//--------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} FA880F3

Chama a Consulta Padrão conforme o que foi selecionado no campo TFQ_ITMOV
@author Serviços
@since 20/08/13
@version P11 R9

@return ExpL:Retorna .T. quando houve sucesso na operação
/*/
//--------------------------------------------------------------------------------------------------------------------
Function FA880F3(cTpArma)
Local lRet			:= .T.
Local aArea		:= GetArea()
Local oMdl		:= FwModelActive()
Default cTpArma	:= "" 

If Empty(cTpArma)  
	cTpArma := oMdl:GetValue("TFOARMA","TFO_ITMOV")
EndIf

SaveInter()
Do Case
	Case cTpArma == "1"
		lRet := Conpad1( NIL,NIL,NIL,"TE0")
		
	Case cTpArma == "2"
		lRet := ConPad1(Nil,Nil,Nil,"TE1")
		
	Case cTpArma == "3"
		lRet := ConPad1(Nil,Nil,Nil,"TE2")
									
EndCase
RestInter()
RestArea(aArea)
Return (lRet)

//--------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} At880DscArma

Realiza o preenchimento da descrição do Armamento
@author Serviços
@since 20/08/13
@version P11 R9

@return ExpL:Retorna .T. quando houve sucesso na operação
/*/
//--------------------------------------------------------------------------------------------------------------------
Function At880DscArma()
Local cDesc		:= ""
Local cLocal		:= ""
Local cDscLocal	:= ""
Local aArea		:= GetArea()
Local cArma		:= ""

Do Case
 	Case FwFldGet("TFO_ITMOV") == "1"
		
		DbSelectArea("TE0")
		TE0->(DbSetOrder(1))
		
		If TE0->(DbSeek(xFilial("TE0") + FwFldGet("TFO_ITCOD")))		
			cArma := TE0->TE0_CODPRO
			cDesc := Posicione("SB1",1,xFilial("SB1") + cArma,"SB1->B1_DESC")
			cLocal		:= TE0->TE0_LOCAL
			cDscLocal	:= TE0->TE0_CLIDES
			
			//Atribiu o valor para os campos de origem
			At880DscOrigem(cLocal,cDscLocal)
			
	 	EndIf
	 Case FwFldGet("TFO_ITMOV") == "2"
		
		DbSelectArea("TE1")
		TE1->(DbSetOrder(1))
		
		If TE1->(DbSeek(xFilial("TE1") + FwFldGet("TFO_ITCOD")))		
			cArma := TE1->TE1_CODPRO
			cDesc := Posicione("SB1",1,xFilial("SB1") + cArma,"SB1->B1_DESC")
			cLocal		:= TE1->TE1_LOCAL
			cDscLocal	:= TE1->TE1_CLIDES
			
			//Atribiu o valor para os campos de origem
			At880DscOrigem(cLocal,cDscLocal)
	 	EndIf
	
	Case FwFldGet("TFO_ITMOV") == "3"
		
		DbSelectArea("TE2")
		TE2->(DbSetOrder(1))
		
		If TE2->(DbSeek(xFilial("TE2") + FwFldGet("TFO_PRODUT") ))		
			cArma := TE2->TE2_CODPRO
			cDesc := Posicione("SB1",1,xFilial("SB1") + cArma,"SB1->B1_DESC")
			cLote		:= TE2->TE2_LOTE
			
			//Atribiu o valor para o campo de Lote
			At880DscOrigem(Nil,Nil,cLote)
	 	EndIf		
EndCase
RestArea(aArea)
Return(cDesc)

//--------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} At880DscOrigem

Seta os valores para os campos de Origem e descrição da Origem
@author Serviços
@since 28/08/13
@version P11 R9

@return lRet, Retorna .T. se houve sucesso
/*/
//--------------------------------------------------------------------------------------------------------------------
Static Function At880DscOrigem(cLocal,cDesc,cLote)
Local oModel	:= FWModelActive()

Default cLocal	:= ""
Default cDesc		:= ""
Default cLote		:= ""

If !Empty(cLocal)
	oModel:SetValue("TFQMASTER","TFQ_ORIGEM", cLocal)
EndIf

If !Empty(cDesc)
	oModel:SetValue("TFQMASTER","TFQ_DSCLOC", cDesc)	
EndIf

If !Empty(cLote)
	oModel:SetValue("TFQMASTER","TFO_LOTE", cLote)
EndIf

Return(.T.)

//--------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} At880Agend

Verifica se a arma escolhida possui Movimentação Agendada

@param cItMov,caractere,Tipo de Armamento
@param cItCod,caractere,Código do Armamento
@sample At880Agend(cItMov,cItCod)
@author Serviços
@since 28/08/13
@version P11 R9

@return lRet, Retorna .T. se houve sucesso
/*/
//--------------------------------------------------------------------------------------------------------------------
Static Function At880Agend(cItMov,cItCod)
	Local aArea      := GetArea()
	Local cAliasQry  := ""
	Local cStatus    := stAGENDADA
	Local cTabTMP    := ""
	Local lRet       := .T.
	Local nNum       := 1
	Local oStatement := Nil

	cTabTMP := "SELECT COUNT(TFO.TFO_ITCOD) AS NCONT "
    cTabTMP +=        "FROM ? TFQ "
    cTabTMP +=             "INNER JOIN ? TFO "
    cTabTMP +=                     "ON TFO.TFO_FILIAL = TFQ.TFQ_FILIAL "
    cTabTMP +=                        "AND TFO.TFO_CDMOV = TFQ.TFQ_CODIGO "
    cTabTMP +=                        "AND TFO.D_E_L_E_T_ = ' ' "
    cTabTMP += "WHERE  TFQ.TFQ_FILIAL = ? "
    cTabTMP +=        "AND TFO.TFO_ITMOV = ? "
    cTabTMP +=        "AND TFO.TFO_ITCOD = ? "
    cTabTMP +=        "AND TFQ.TFQ_STATUS = ? "
    cTabTMP +=        "AND TFQ.D_E_L_E_T_ = ' ' "

    nNum := 1
    cTabTMP := ChangeQuery(cTabTMP)
    oStatement  := FwExecStatement():New(cTabTMP)

	oStatement:SetUnsafe( nNum++, RetSqlName( "TFQ" ) )
	oStatement:SetUnsafe( nNum++, RetSqlName( "TFO" ) )
	oStatement:SetString( nNum++, FwxFilial( "TFQ" ) )
	oStatement:SetString( nNum++, cItMov )
	oStatement:SetString( nNum++, cItCod )
	oStatement:SetString( nNum++, cStatus )

	cAliasQry := oStatement:OpenAlias()
	oStatement:Destroy()
	FwFreeObj(oStatement)

	While (cAliasQry)->(!Eof())
		lRet := (cAliasQry)->NCONT > 0
		(cAliasQry)->(dbSkip())
	EndDo

	(cAliasQry)->(dbCloseArea())
	RestArea(aArea)

Return(lRet)
//--------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} At880VldAloc

Verifica se a arma escolhida possui alocação na origem

@param cItMov,caractere,Item de Armamento
@param cItCod,caractere,Código do armamento

@sample At880VldAloc(cItMov,cItCod)
@author Serviços
@since 28/08/13
@version P11 R9

@return lRet, Retorna .T. se houve sucesso
/*/
//--------------------------------------------------------------------------------------------------------------------
Function At880VldAloc(cItMov,cItCod,lVldLaXLo)
	Local lRet		:= .T.
	Local aArea	:= GetArea()	
	Local cTab		:= ''
	Local cEnt		:= ''
	Local cCdEnt	:= '' 	
	Local lMultFil	:= TFQ->(ColumnPos("TFQ_FILORI")) .And. TFQ->(ColumnPos("TFQ_FILDES")) .And. FindFunction("TecMtFlArm") .And. TecMtFlArm() .And. !isBlind()
	Local cFilLoc	:= ""

	Default cItMov	:= ''
	Default cItCod	:= ''
	Default lVldLaXLo	:= .F.

	Do Case
		Case cItMov == itARMA
			cTab := "TE0"
		Case cItMov == itCOLETE
			cTab := "TE1"
		Case cItMov == itMUNICAO
			cTab := "TE2"
	EndCase

	If cTab $ "TE0;TE1"
		DbSelectArea(cTab)
		(cTab)->(DbSetOrder(1))
				
		If (cTab)->(DbSeek(xFilial(cTab) + cItCod))
			cEnt	:= (cTab)->&(cTab + '_ENTIDA')
			cEnt	:= If( cEnt == 'TER', '1' , '2' )
			cCdEnt	:= (cTab)->&(cTab + '_LOCAL')
			If lMultFil
				cFilLoc	:= (cTab)->&(cTab + '_FILLOC')			
			Endif					
			If Empty(cCdEnt)
					lRet := .F.
			ElseIf lVldLaXLo
				If lMultFil
					lRet := (cEnt == FWFLDGET('TFQ_ENTORI')) .and. (cCdEnt == FWFLDGET('TFQ_ORIGEM')) .and. (cFilLoc == FWFLDGET('TFQ_FILORI'))
				Else
					lRet := (cEnt == FWFLDGET('TFQ_ENTORI')) .and. (cCdEnt == FWFLDGET('TFQ_ORIGEM')) 
				EndIf
			EndIf
		EndIf

	ElseIf cTab == "TE2"
		
		DbSelectArea("TFP")	// HISTORICO MOVIMENTACAO MUNICAO
		If FwFldGet("TFQ_ENTORI") == "1"
			TFP->(DbSetOrder(7)) //TFP_FILIAL+TFP_ENTIDA+TFP_CODINT+TFP_PRODUT+TFP_FILLOC
		Else
			TFP->(DbSetOrder(8)) //TFP_FILIAL+TFP_ENTIDA+TFP_CODLOC+TFP_PRODUT+TFP_FILLOC
		EndIf

		If !TFP->(DbSeek(xFilial("TFP") + FwFldGet("TFQ_ENTORI") + FwFldGet("TFQ_ORIGEM") + FwFldGet('TFO_PRODUT')+ Iif(lMultFil,FwFldGet('TFQ_FILORI'),"")))
			lRet := .F.
		EndIf
		
	EndIf

RestArea(aArea)
	 
Return(lRet)

//--------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} At880VldGuia

Verifica se o Numero da Guia ou a justificativa foram preenchidas
@author Serviços
@since 28/08/13
@version P11 R9

@return lRet, Retorna .T. se houve sucesso
/*/
//--------------------------------------------------------------------------------------------------------------------
Static Function At880VldGuia(oMdl)
	Local lRet	:= .T.
	Local nI := 0

	Default oMdl := nil

	If !Empty(oMdl)
		For nI := 1 To oMdl:Length()
			oMdl:GoLine(nI)

			//Verifica se o campo Numero da Guia está preenchido
			If		!oMdl:IsDeleted() .and. oMdl:GetValue('TFO_LGUIA') == '1' .and. Empty(oMdl:GetValue('TFO_NRGUIA'))
				Help( ,, "At880VldGuia",, STR0012, 1, 0 ) //'Alocação','Preencha o Numero da Guia'
				lRet	:= .F.
				//Verifica se o ocampo Justificativa está preenchido
			ElseIf	!oMdl:IsDeleted() .and. oMdl:GetValue('TFO_LGUIA') == '2' .and. Empty(FwFldGet("TFQ_JUSTIF"))
				Help( ,, "At880VldGuia",, STR0013, 1, 0 ) //'Alocação','Preencha a Justificativa'
				lRet	:= .F.
			EndIf
		
			// Havendo um caso, abandona.
			If !lRet
				Exit	
			EndIf	
		Next nI
	EndIf
			
Return(lRet)

//--------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} At880VldStat

Verifica o Status da Arma ou Colete e verifica se é possivel a sua movimentação

@param cItMov,caractere,Tipo do Armamento
@param cItCod,caractere,Codigo do armamento
@param cMotivo,caractere,Motivo da movimentação

@sample At880VldStat(cItMov,cItCod,cMotivo)

@author Serviços
@since 28/08/13
@version P11 R9

@return lRet, Retorna .T. se houve sucesso
/*/
//--------------------------------------------------------------------------------------------------------------------
Static Function At880VldStat(cItMov, cItCod, cMotivo)
Local lRet  := .F.
Local aArea := GetArea()

Default cItCod := FwFldGet("TFQ_ITARMA")

If Empty(cMotivo)
	Help( ,, "At880VldStat",, STR0064, 1, 0 ) //'Alocação','Informe o Motivo para a Movimentação!'

Else
	Do Case
		Case cItMov == itARMA
			DbSelectArea("TE0")
			TE0->(DbSetOrder(1))
			If TE0->(DbSeek(xFilial("TE0") + cItCod))

				//Verifica o tipo do motivo e verifica o Status		
				If cMotivo $ mtIMPLANTACAO + mtMANUTENCAO + mtREFORCO + mtENCERRAMENTO
					lRet := TE0->TE0_SITUA $ "1,2,8"
				ElseIf cMotivo == mtDESCARTE
					lRet := TE0->TE0_SITUA $ "1,2,8,9"
				EndIf
				If !lRet
					Help( ,, "At880VldStat",, STR0014, 1, 0 ) //'Alocação','O Status do Armamento não permite movimentação!'
				EndIf
			EndIf

		Case cItMov == itCOLETE
			DbSelectArea("TE1")
			TE1->(DbSetOrder(1))
			If TE1->(DbSeek(xFilial("TE1") + cItCod))

				//Verifica o tipo do motivo e verifica o Status		
				If cMotivo $ mtIMPLANTACAO + mtMANUTENCAO + mtREFORCO + mtENCERRAMENTO
					lRet := TE1->TE1_SITUA $ "1,2,8"
				ElseIf cMotivo == mtDESCARTE
					lRet := TE1->TE1_SITUA $ "1,2,8,9"
				EndIf
				If !lRet
					Help( ,, "At880VldStat",, STR0014, 1, 0 )//'Alocação','O Status do Armamento não permite movimentação!'
				EndIf
			EndIf

		Case cItMov == itMUNICAO
			DbSelectArea("TE2")
			TE2->(DbSetOrder(1))
			lRet := TE2->(DbSeek(xFilial("TE2") + cItCod))
	EndCase
EndIf
RestArea(aArea)

Return(lRet)

//--------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} At880VldSaldo
	Verifica o Saldo do local de origem informado
@param oMdl,objeto,Objeto de dados sendo editado.

@sample At880VldSaldo(oMdl)
@author Serviços
@since 28/08/13
@version P11 R9

@return lRet, Retorna .T. se houve sucesso
/*/
//--------------------------------------------------------------------------------------------------------------------
Static Function At880VldSaldo(oMdl)

	Local aArea  := GetArea()
	Local cItCod := oMdl:GetValue( 'TFO_ITCOD' )
	Local lRet   := .T.
	Local nQtde  := oMdl:GetValue( 'TFO_QTDE' )

	DbSelectArea("TFP")	// HISTORICO MOVIMENTACAO MUNICAO
	If FwFldGet("TFQ_ENTORI") == "1"
		TFP->(DbSetOrder(7)) //TFP_FILIAL+TFP_ENTIDA+TFP_CODINT+TFP_PRODUT+TFP_FILLOC
	Else
		TFP->(DbSetOrder(8)) //TFP_FILIAL+TFP_ENTIDA+TFP_CODLOC+TFP_PRODUT+TFP_FILLOC
	EndIf

	//Verifica se a quantidade informada é maior que o saldo do blister	
	If TE2->(DbSeek(xFilial("TE2") + cItCod))	
		If TFP->(DbSeek(xFilial("TFP") + FwFldGet("TFQ_ENTORI") + FwFldGet("TFQ_ORIGEM") + FwFldGet("TFO_PRODUT") + FwFldGet('TFQ_FILORI')))
			If TFP->TFP_SALDO < nQtde
				Help( ,, "At880VldSaldo",, STR0018, 1, 0 )//'Alocação',"A quantidade informada é maior do que está alocado ou é superior ao saldo disponivel para movimentação no Blister relacionado."
				lRet := .F.
			EndIf
		EndIf
	EndIf

	If lRet .And. _lGsOrcArm
		// Verfica a TXQ também pois posso alterar quantidade com ela já preenchida:
		lRet := at880VlTXQ(oMdl,itMUNICAO)
	EndIf

	RestArea(aArea)			

Return(lRet)

//--------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} AtVldLocMun

Valida se o local informado realmente existe para a munição informada
@sample AtVldLocMun(cCodigo) 
@author Serviços
@since 28/08/13
@version P11 R9
@Param cCodigo, Codigo do Local informado no campo TFQ_ORIMUN

@return lRet, Retorna .T. se houve sucesso
/*/
//--------------------------------------------------------------------------------------------------------------------
Function AtVldLocMun(cCodigo)
Local lRet		:= .T.
Local nY		:= 0
Local aArea	:= GetArea()

aCmpBco := At880QryLoc()
	
If FwFldGet("TFQ_ENTORI") == "1"
		//Faz a Busca para Locais Internos
	nY := aScan(aCmpBco,{|x| AllTrim(x[3]) == Alltrim(cCodigo)})
		
	If nY == 0
		Help( ,, "AtVldLocMun",, STR0020, 1, 0 )//"Codigo",'O codigo informado não está relacionado'
		lRet := .F.
	EndIf
Else
		//Faz a Busca para Locais de Atendimento
	nY := aScan(aCmpBco,{|x| AllTrim(x[4]) == Alltrim(cCodigo)})
		
	If nY == 0
		Help( ,, "AtVldLocMun",, STR0020, 1, 0 )//"Codigo",'O codigo informado não está relacionado'
		lRet := .F.
	EndIf
		
EndIf

RestArea(aArea)

Return(lRet)
//--------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} At880VldLoc

Verifica se o local de destino não é igual ao de origem
@author Matheus.Gonçalves
@since 12/02/2021
@version P12 

@return lRet Retorna .F. se houver inconsistência 
/*/
//--------------------------------------------------------------------------------------------------------------------
Function At880VldLoc()
	Local lMultFil  := TFQ->(ColumnPos("TFQ_FILORI")) .And. TFQ->(ColumnPos("TFQ_FILDES")) .And. FindFunction("TecMtFlArm") .And. TecMtFlArm()
	Local lRet      := .T.
	Local lVldEnt   := .T.
	Local oMdl := FWModelActive()
	Local oMdlTFQ := oMdl:GetModel('TFQMASTER')
	
	lVldEnt  := Alltrim(oMdlTFQ:GetValue("TFQ_ENTORI")) == "1" .And. Alltrim(oMdlTFQ:GetValue("TFQ_ENTDES")) == "1" .Or.;
				Alltrim(oMdlTFQ:GetValue("TFQ_ENTORI")) == "2" .And. Alltrim(oMdlTFQ:GetValue("TFQ_ENTDES")) == "2"

	If !lVldEnt
		If lMultFil 
			If Alltrim(oMdlTFQ:GetValue("TFQ_FILDES")) == Alltrim(oMdlTFQ:GetValue("TFQ_FILORI")) .And.; 
			Alltrim(oMdlTFQ:GetValue("TFQ_DESTIN")) == Alltrim(oMdlTFQ:GetValue("TFQ_ORIGEM")) 
				Help( ,, "At880VldLoc",, STR0021, 1, 0 )//'Alocação','Local de Origem é o mesmo de Destino'
				lRet := .F.	
			EndIf	
		Else
			If Alltrim(oMdlTFQ:GetValue("TFQ_DESTIN")) == Alltrim(oMdlTFQ:GetValue("TFQ_ORIGEM")) 
				Help( ,, "At880VldLoc",, STR0021, 1, 0 )//'Alocação','Local de Origem é o mesmo de Destino'
				lRet := .F.
			EndIf	
		EndIf
	EndIf                         

Return(lRet)

//--------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} At880VldCons

Validação do campo de codigo das Armas conforme o que foi selecionado no campo TEU_TPARMA
@sample 	At880VldCons() 
@since		11/09/2013 
@version P11 R9
     
@return 	lRet, Retorno do ExistCPO de acordo com o que foi selecionado no campo TEU_TPARMA
/*/
//--------------------------------------------------------------------------------------------------------------------
Function At880VldCons()
Local lRet	:= .F.
Do Case
	Case FwFldGet("TFO_ITMOV") == "1"
		lRet := ExistCpo("TE0")

	Case FwFldGet("TFO_ITMOV") == "2"
		lRet := ExistCpo("TE1")
		
	Case FwFldGet("TFO_ITMOV") == "3"
		lRet := ExistCpo("TE2")
	
EndCase
Return(lRet)

//--------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} FA880ENT

Chama a Consulta Padrão conforme o que foi selecionado no campo TFQ_ENTDES
@author Serviços
@since 20/08/13
@version P11 R9

@return ExpL:Retorna .T. quando houve sucesso na operação
/*/
//--------------------------------------------------------------------------------------------------------------------
Function FA880ENT(cChave)
	Local oModel     := FwModelActive()
	Local oModelTFQ  := oModel:GetModel( 'TFQMASTER' )
	Local cTpEntOri  := oModelTFQ:GetValue("TFQ_ENTORI")
	Local cTpEntDes  := oModelTFQ:GetValue("TFQ_ENTDES")
	Local lRet       := .T.
	Local aArea      := GetArea()
	Local lMultFil   := TFQ->(ColumnPos("TFQ_FILORI")) .And. TFQ->(ColumnPos("TFQ_FILDES")) .And. FindFunction("TecMtFlArm") .And. TecMtFlArm()
	Local cFilBkp    := cFilAnt
	Default cChave   := ""

	SaveInter()

	If cChave == 'ORIGEM'
		If lMultFil .And. oModelTFQ:GetValue("TFQ_FILORI") <> cFilAnt
			cFilAnt := oModelTFQ:GetValue("TFQ_FILORI")
		Endif
		If cTpEntOri == eoLOCATEND
			If _lGsOrcArm
				lRet := At880F3Arma("CONTRLOCAL",oModelTFQ)
				oModelTFQ:LoadValue("TFQ_CODTFL", _cCodTFL)
			else
				lRet := Conpad1( NIL,NIL,NIL,"ABS")			
			Endif	
		ElseIf cTpEntOri == eoLOCINTER
			lRet := ConPad1(Nil,Nil,Nil,"TER")
		EndIf
	ElseIF cChave == 'ARMA' 
		lRet := At880F3Arma("ARMA",oModelTFQ)
	ElseIF cChave == 'COLETE' 
		lRet := At880F3Arma("COLETE",oModelTFQ)
	ElseIF cChave == 'MUNI'
		lRet := At880F3Arma("MUNI", oModelTFQ)
		//oModelTFQ:GetModel():GetModel("TFOMUNI"):LoadValue("TFO_PRODUT", _cProduto)
	ElseIF cChave == 'TXQARM'
		lRet := At880F3Arma("TXQARM", oModelTFQ)
	ElseIF cChave == 'TXQCOL'
		lRet := At880F3Arma("TXQCOL", oModelTFQ)
	ElseIF cChave == 'TXQMUN'
		lRet := At880F3Arma("TXQMUN", oModelTFQ)
	Else // 'DESTINO'
		If lMultFil .And. oModelTFQ:GetValue("TFQ_FILDES") <> cFilAnt
			cFilAnt := oModelTFQ:GetValue("TFQ_FILDES")
		Endif
		If cTpEntDes == edCLIENTE
			If	_lGsOrcArm
				lRet := At880F3Arma("CONTRLOCAL",oModelTFQ)
				oModelTFQ:LoadValue("TFQ_CODTFL", _cCodTFL)
			else
				lRet := Conpad1( NIL,NIL,NIL,"ABS")
			Endif	
		ElseIf	cTpEntDes == edEMPRESA	
			lRet := ConPad1(Nil,Nil,Nil,"TER")
		EndIf
	EndIf
	If lMultFil .And. cFilBkp <> cFilAnt
		cFilAnt := cFilBkp
	Endif

	RestInter()
	RestArea(aArea)
Return (lRet)

//--------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} At880RetEnt

Retorna a variavel da memoria do model, para a consulta especifica
@sample 	At880RetEnt() 
@since		11/09/2013
@version P11 R9
     
@return 	cCodigo, CHARACTER, codigo do Armamento.
/*/
//--------------------------------------------------------------------------------------------------------------------
Function At880RetEnt(cChave)

	Local oModel	 := FwModelActive()
	Local oModelTFQ	 := oModel:GetModel('TFQMASTER')
	Local cCodigo    := ""
	Local cTpEntDes  := oModelTFQ:GetValue("TFQ_ENTDES")
	Local cTpEntOri  := oModelTFQ:GetValue("TFQ_ENTORI")

	Default cChave	:= ""

	If cChave == 'ORIGEM'
		If cTpEntOri == eoLOCATEND 
			cCodigo := _cRetF3
		ElseIf	cTpEntOri == eoLOCINTER	
			cCodigo := TER->TER_CODIGO
		EndIf
	ElseIf cChave $ "|ARMA|COLETE|MUNI|TXQARM|TXQCOL|TXQMUN"
		cCodigo := _cRetF3
	Else //'DESTINO'
		If cTpEntDes == edCLIENTE  
			cCodigo := _cRetF3
		ElseIf	cTpEntDes == edEMPRESA	
			cCodigo := TER->TER_CODIGO
		EndIf
	EndIf

Return(cCodigo)

//--------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} At880Ret

Preencher a variavel para atualizar a consulta padrao
Author - Vitor kwon
@since 03/02/2022
@version P12
@return Nil
/*/
//--------------------------------------------------------------------------------------------------------------------
// DESCONTINUADO !
Function At880Ret(cRetArm,cDest,cCodTFL,cCodMuni)

Return

//--------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} At880LDsc

Realiza o preenchimento da descrição do Local

@param	cLocal,caractere,Tipo do Local de Atendimento

@sample At880LDsc(cLocal)
@author Serviços
@since 20/08/13
@version P11 R9
@return cRet,caractere,Retorna a descrição do Local selecionado
/*/
//--------------------------------------------------------------------------------------------------------------------
Function At880LDsc(cLocal)
Local cRet		:= ""
Local aArea		:= GetArea()
Local cCampo	:= ''
Local lMultFil 	:= TFQ->(ColumnPos("TFQ_FILORI")) .And. TFQ->(ColumnPos("TFQ_FILDES")) .And. FindFunction("TecMtFlArm") .And. TecMtFlArm()
Local cFilBkp	:= cFilAnt
Local oMdl		:= FWModelActive()

Default cLocal:= ""

If cLocal == 'ORIGEM'
	If lMultFil .And. oMdl:GetValue("TFQMASTER","TFQ_FILORI") <> cFilAnt
		cFilAnt := oMdl:GetValue("TFQMASTER","TFQ_FILORI")
	Endif
	cCampo	:= 'TFQ_ORIGEM'
	If FwFldGet('TFQ_ENTORI') == "1"
		cTab := 'TER'	// Locais Internos - Empresa
	ElseIf	FwFldGet('TFQ_ENTORI') == "2"
		cTab := 'ABS'	// Locais de Atendimento - Cliente
	EndIf
Else
	If lMultFil .And. oMdl:GetValue("TFQMASTER","TFQ_FILDES") <> cFilAnt
		cFilAnt := oMdl:GetValue("TFQMASTER","TFQ_FILDES")
	Endif
	cCampo	:= 'TFQ_DESTIN'
	If FwFldGet('TFQ_ENTDES') == "1"
		cTab := 'ABS'	// Locais de Atendimento - Cliente
	ElseIf	FwFldGet('TFQ_ENTDES') == "2"
		cTab := 'TER'	// Locais Internos - Empresa
	EndIf
EndIf
cRet := Alltrim(Posicione(cTab,1,xFilial(cTab)+FwFldGet(cCampo),cTab+"_DESCRI"))
If lMultFil .And. cFilBkp <> cFilAnt
	cFilAnt := cFilBkp
Endif

RestArea(aArea)
Return(cRet)
		
//--------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} At880VldOri
	 
Validação do campo de codigo de origem
@sample 	At880VldOri() 
@since		08/07/2015 
@version P11 R9
		
@return 	lRet, Retorno do ExistCPO de acordo com a configuração do campo TFQ_ENTORI e com o código informado no TFQ_ORIGEM
/*/
//--------------------------------------------------------------------------------------------------------------------
Function At880VldOri(oMdl,cIdCall)
Local lRet	:= .F.
Local lMultFil 	:= TFQ->(ColumnPos("TFQ_FILORI")) .And. FindFunction("TecMtFlArm") .And. TecMtFlArm()
Local cFilBkp	:= cFilAnt

If lMultFil .And. oMdl:GetValue("TFQ_FILORI") <> cFilAnt
	cFilAnt := oMdl:GetValue("TFQ_FILORI")
Endif

Do Case
	Case FwFldGet("TFQ_ENTORI") == eoLOCINTER
		lRet := ExistCpo("TER",oMdl:GetValue(cIdCall))

	Case FwFldGet("TFQ_ENTORI") == eoLOCATEND
		lRet := ExistCpo("ABS",oMdl:GetValue(cIdCall))

EndCase

If lMultFil .And. cFilBkp <> cFilAnt
	cFilAnt := cFilBkp
Endif
Return(lRet)

//--------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} At880VldEnt

Validação do campo de codigo de destino
@sample 	At780VldEnt() 
@since		11/09/2013 
@version P11 R9
     
@return 	lRet, Retorno do ExistCPO de acordo com o que foi selecionado no campo TEU_TPARMA
/*/
//--------------------------------------------------------------------------------------------------------------------
Function At880VldEnt()
	Local cFilBkp  := cFilAnt
	Local lMultFil := TFQ->(ColumnPos("TFQ_FILDES")) .And. FindFunction("TecMtFlArm") .And. TecMtFlArm()
	Local lRet     := .F.
	Local oMdl := FWModelActive()
	Local oMdlTFQ := oMdl:GetModel('TFQMASTER')


	If lMultFil .And. oMdlTFQ:GetValue("TFQ_FILDES") <> cFilAnt
		cFilAnt := oMdlTFQ:GetValue("TFQ_FILDES")
	Endif
	Do Case
		Case oMdlTFQ:GetValue("TFQ_ENTDES") == edCLIENTE
			lRet := ExistCpo("ABS")

		Case oMdlTFQ:GetValue("TFQ_ENTDES") == edEMPRESA
			lRet := ExistCpo("TER")
		
	EndCase
	If lMultFil .And. cFilBkp <> cFilAnt
		cFilAnt := cFilBkp
	Endif
Return(lRet)

//--------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} At880Resp

Realiza o preenchimento da descrição do Responsavel
@author Serviços
@since 20/08/13
@version P11 R9

@return ExpL:Retorna .T. quando houve sucesso na operação
/*/
//--------------------------------------------------------------------------------------------------------------------
Function At880Resp()
Local cDesc		:= ""
Local aArea		:= GetArea()

cDesc := Alltrim(Posicione("AA1",1,xFilial("AA1")+FwFldGet("TFQ_RESTRA"),"AA1_NOMTEC"))

RestArea(aArea)

Return(cDesc)

//--------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} At880Atend

Realiza o preenchimento do nome e dados do atendente responsavel pelo armamento
@author Serviços
@since 20/08/13
@version P11 R9

@return ExpL:Retorna .T. quando houve sucesso na operação
/*/
//--------------------------------------------------------------------------------------------------------------------
Function At880Atend()
Local cDesc		:= ""
Local aArea		:= GetArea()
Local oModel		:= Nil

DbSelectArea("AA1")
AA1->(DbSetOrder(1))

If AA1->(DbSeek(xFilial("AA1")+FwFldGet("TFR_CODTEC")))
	oModel := FWModelActive()

	oModel:setValue("TFRFUNC","TFR_FUNCAO" 	,Posicione("SRJ",1,xFilial("SRJ")+AA1->AA1_FUNCAO,"RJ_DESC"))
	oModel:setValue("TFRFUNC","TFR_CDFUNC"	,AA1->AA1_CDFUNC)
	oModel:setValue("TFRFUNC","TFR_TURNO"	,AA1->AA1_TURNO)

	cDesc := AA1->AA1_NOMTEC
	
EndIf

RestArea(aArea)

Return(cDesc)

Function At880Produto()
Local cReturn := ""

If !Empty(FwFldGet('TFO_ITCOD'))
	cReturn := _cProduto
EndIf
Return cReturn

//--------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} At880IniArma 

Realiza a Inicialização padrão do armamento
@author Serviços
@since 20/08/13
@version P11 R9

@return ExpC:Retorna a descrição da Arma
/*/
//--------------------------------------------------------------------------------------------------------------------
Function At880IniArma(cItem,cArma)
Local aArea := GetArea()
Local cProd := ""
Local cDesc := ""
Local nTamD := FwTamSx3("TFO_DESCR")[1]

Default cItem := ""
Default cArma := ""

If !Empty(cItem) .And. !Empty(cArma)
	Do Case
		Case cItem == "1"
			// Arma
			cProd := Posicione("TE0",1,xFilial("TE0") + cArma ,"TE0->TE0_CODPRO")	
			cDesc := Posicione("SB1",1,xFilial("SB1") + cProd ,"SB1->B1_DESC")
		Case cItem == "2"
			// Colete
			cProd := Posicione("TE1",1,xFilial("TE1") + cArma ,"TE1->TE1_CODPRO")
			cDesc := Posicione("SB1",1,xFilial("SB1") + cProd ,"SB1->B1_DESC")
		Case cItem == "3"
			// Municao
			cProd := Posicione("TE2",1,xFilial("TE2") + cArma ,"TE2->TE2_CODPRO")
			cDesc := Posicione("SB1",1,xFilial("SB1") + cProd ,"SB1->B1_DESC")
	EndCase
	cDesc := Padr(cDesc,nTamD)
EndIf

RestArea(aArea)
Return(cDesc)

//--------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} At880IniDscLoc 

Realiza a Inicialização padrão da descrição do local 
@author Serviços
@since 20/08/13
@version P11 R9

@return ExpC:Retorna a descrição do local de origem
/*/
//--------------------------------------------------------------------------------------------------------------------
Function At880IniDscLoc(cEntida,cLocal)
Local cDesc		:= ""
Local aArea		:= GetArea()
Local lModoInc	:= .F.
Local lMultFil 	:= TFQ->(ColumnPos("TFQ_FILORI")) .And. TFQ->(ColumnPos("TFQ_FILDES")) .And. FindFunction("TecMtFlArm") .And. TecMtFlArm()
Local cFilBkp	:= cFilAnt

Default cEntida		:= ""
Default cLocal		:= ""

If Type('INCLUI') == 'L'
	lModoInc := INCLUI
EndIf 

If !lModoInc .And. !Empty(cEntida) .And. !Empty(cLocal)
	If lMultFil .And. TFQ->TFQ_FILORI <> cFilAnt
		cFilAnt := TFQ->TFQ_FILORI
	Endif
	Do Case
		Case cEntida == eoLOCINTER
			cDesc := Alltrim(Posicione("TER",1,xFilial("TER")+ cLocal ,"TER_DESCRI"))

		Case cEntida == eoLOCATEND
			cDesc := Alltrim(Posicione("ABS",1,xFilial("ABS")+ cLocal ,"ABS_DESCRI"))
	
	EndCase
	If lMultFil .And. cFilBkp <> cFilAnt
		cFilAnt := cFilBkp
	Endif
EndIf

RestArea(aArea)

Return(cDesc)

//--------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} At880IniEnt 

Realiza a Inicialização padrão da descrição do local destino
@author Serviços
@since 20/08/13
@version P11 R9

@return ExpC:Retorna a descrição do Local de destino
/*/
//--------------------------------------------------------------------------------------------------------------------
Function At880IniEnt(cEntida,cLocal)
Local cDesc		:= ""
Local aArea		:= GetArea()
Local lModoInc	:= .F.
Local lMultFil 	:= TFQ->(ColumnPos("TFQ_FILORI")) .And. TFQ->(ColumnPos("TFQ_FILDES")) .And. FindFunction("TecMtFlArm") .And. TecMtFlArm()
Local cFilBkp	:= cFilAnt

Default cEntida		:= ""
Default cLocal		:= ""

If Type('INCLUI') == 'L'
	lModoInc := INCLUI
EndIf 

If !lModoInc .And. !Empty(cEntida) .And. !Empty(cLocal)
	If lMultFil .And. TFQ->TFQ_FILDES <> cFilAnt
		cFilAnt := TFQ->TFQ_FILDES
	Endif
	Do Case
		Case cEntida == edCLIENTE
			cDesc := Alltrim(Posicione("ABS",1,xFilial("ABS")+ cLocal ,"ABS_DESCRI"))

		Case cEntida == edEMPRESA
			cDesc := Alltrim(Posicione("TER",1,xFilial("TER")+ cLocal ,"TER_DESCRI"))
	
	EndCase
	If lMultFil .And. cFilBkp <> cFilAnt
		cFilAnt := cFilBkp
	Endif
EndIf
RestArea(aArea)
Return(cDesc)

//--------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} At880WMnt

Habilita ou desabilita os campos de manutenção 
@sample 	At880WMnt() 
@since		11/09/2013 
@version P11 R9
     
@return lRet, Retorna .T. se houve sucesso
/*/
//--------------------------------------------------------------------------------------------------------------------
Function At880WMnt()                                                   
Local lRet := .F.

If INCLUI .and. (FwFldGet('TFQ_MOTIVO') == mtMANUTENCAO)
	lRet := .T.
EndIf

Return(lRet)

//--------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} At880ConsLoc

Realiza a Consulta especifica para os Locais de origem da Munição
@author Serviços
@since 20/08/13
@version P11 R9

@return ExpL:Retorna .T. quando houve sucesso na operação
/*/
//--------------------------------------------------------------------------------------------------------------------
Function At880ConsLoc()
Local lRet			:= .T.
Local cCodigo		:= ""
Local cEntida		:= ""
Local cLocal		:= ""
Local lOk			:= .F.
Local aArea		:= GetArea()

Local oModel				//Modelo atual
Local oDlgCmp				//Dialog
Local oPanel 				//Objeto Panel
Local oFooter				//Rodapé
Local oListBox			//Grid campos
Local oOk					//Objeto Confirma 
Local oCancel				//Objeto Cancel

aCmpBco := At880QryLoc()

If !Empty(aCmpBco)

	//	Cria a tela para a pesquisa dos campos e define a area a ser utilizada na tela 
	Define MsDialog oDlgCmp FROM 000, 000 To 350, 550 Pixel
			
	// Cria o panel principal
	@ 000, 000 MsPanel oPanel Of oDlgCmp Size 250, 340 // Coordenada para o panel
	oPanel:Align := CONTROL_ALIGN_ALLCLIENT //Indica o preenchimento e alinhamento do panel (nao necessita das coordenadas)
		
	// Criação do grid para o panel	
	oListBox := TWBrowse():New( 40,05,204,100,,{STR0019,STR0022,STR0023,STR0024,STR0025,STR0026,STR0027},,oPanel,,,,,,,,,,,,.F.,,.T.,,.F.,,,) // "Codigo","Entidade","Codigo Interno","Codigo do Local", "Movimentação", "Saldo", "Lote"
	oListBox:SetArray(aCmpBco) // Atrela os dados do grid com a matriz
	oListBox:bLine := { ||{aCmpBco[oListBox:nAT][1],aCmpBco[oListBox:nAT][2],aCmpBco[oListBox:nAT][3],aCmpBco[oListBox:nAT][4],aCmpBco[oListBox:nAT][5],aCmpBco[oListBox:nAT][6],aCmpBco[oListBox:nAT][7]}} // Indica as linhas do grid
	oListBox:bLDblClick := { ||Eval(oOk:bAction), oDlgCmp:End()} // Duplo clique executa a ação do objeto indicado
	oListBox:Align := CONTROL_ALIGN_ALLCLIENT //Indica o preenchimento e alinhamento do browse
		
	// Cria o panel para os botoes	
	@ 000, 000 MsPanel oFooter Of oDlgCmp Size 000, 010 // Corrdenada para o panel dos botoes (size)
	oFooter:Align   := CONTROL_ALIGN_BOTTOM //Indica o preenchimento e alinhamento do panel (nao necessita das coordenadas)
			
	// Botoes para o grid auxiliar	
	@ 000, 000 Button oCancel Prompt STR0028  Of oFooter Size 030, 000 Pixel //Cancelar
	oCancel:bAction := { || lOk := .F., oDlgCmp:End() }
	oCancel:Align   := CONTROL_ALIGN_RIGHT
		
	@ 000, 000 Button oOk     Prompt STR0029 Of oFooter Size 030, 000 Pixel //Confirmar
	oOk:bAction     := { || lOk := .T.,cCodigo:=aCmpBco[oListBox:nAT][3],cEntida:=aCmpBco[oListBox:nAT][2],cLocal:=aCmpBco[oListBox:nAT][4],oDlgCmp:End() } // Acao ao clicar no botao
	oOk:Align       := CONTROL_ALIGN_RIGHT // Alinhamento do botao referente ao panel
		
		// Ativa a tela exibindo conforme a coordenada
	Activate MsDialog oDlgCmp Centered
			
	//Utilizar o modelo ativo para substituir os valores das variaves de memoria		
	oModel	:= FWModelActive()
		
	If lOk
		If cEntida == "1"
			cTab	:= "TER"
			oModel:SetValue("TFQMASTER","TFQ_ENTIDA", cEntida)
			oModel:SetValue("TFQMASTER","TFQ_ORIMUN", cCodigo)
		ElseIf cEntida == "2"
			cTab := "ABS"
			oModel:SetValue("TFQMASTER","TFQ_ENTIDA", cEntida)
			oModel:SetValue("TFQMASTER","TFQ_ORIMUN", cLocal)
		EndIf
	EndIf
Else
	Help( ,, "At880ConsLoc",, STR0030, 1, 0 )//"Alocação,'Não há alocação para essa munição, selecione outro lote'
EndIf

RestArea(aArea)

Return(lRet)

//--------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} AT880RetLoc

Retorna a variavel da memoria do model, para a consulta especifica
@sample 	AT840RetLoc() 
@since		11/09/2013
@version P11 R9
     
@return 	cCodigo, CHARACTER, conteudo da variavel de memoria.
/*/
//--------------------------------------------------------------------------------------------------------------------
Function At880RetLoc()
Return (FwFldGet("TFQ_ORIMUN"))

//--------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} At880QryLoc

Realiza a Query para a consulta especifica do Local de Alocação da Munição
@sample 	At780Query() 
@since		11/09/2013 
@version P11 R9
     
@return 	aRet, Array com os Responsaveis
/*/
//--------------------------------------------------------------------------------------------------------------------
Static Function At880QryLoc(cCond, cEntida)
	Local aRet       := {}
	Local cQuery     := ""
	Local cAliasQry  := ""
	Local cMovim     := "" //1=Saldo Cofre,2=Saldo no Cliente(Local de Atendimento)	
	Local nNum       := 1
	Local oStatement := Nil

	Default cCond    := FwFldGet("TFQ_ITARMA") //Codigo do Armamento
	Default cEntida  := FwFldGet("TFQ_ENTORI") //1=Local Interno, 2=Local de Atendimento

	If Select("cAlias") > 0 
		(cAlias)->(DbCloseArea())
	Endif

	If !Empty(cEntida)
		
		If cEntida == "1"
			cMovim := "1"
		ElseIf cEntida == "2"
			cMovim := "2"
		EndIf
			
		cQuery := "SELECT TFP.TFP_CODIGO, "
		cQuery +=        "TFP.TFP_ENTIDA, " 
		cQuery +=        "TFP.TFP_CODINT, " 
		cQuery +=        "TFP.TFP_CODLOC, " 
		cQuery +=        "TFP.TFP_MOVIM, " 
		cQuery +=        "TFP.TFP_SALDO, " 
		cQuery +=        "TFP.TFP_LOTE " 
		cQuery += "FROM ? TFP "
		cQuery += "WHERE TFP.TFP_FILIAL = ? "
		cQuery +=       "AND TFP.TFP_ENTIDA = ? "
		cQuery +=       "AND TFP.TFP_MOVIM = ? "
		cQuery +=       "AND TFP.TFP_SALDO > 0 "
		cQuery +=       "AND TFP.TFP_CODMUN = ? "
		cQuery +=       "AND TFP.D_E_L_E_T_ = ' ' "

		nNum := 1
		cQuery := ChangeQuery(cQuery)
		oStatement  := FwExecStatement():New(cQuery)

		oStatement:SetUnsafe( nNum++, RetSqlName( "TFP" ) )
		oStatement:SetString( nNum++, FwxFilial( "TFP" ) )
		oStatement:SetString( nNum++, cEntida )
		oStatement:SetString( nNum++, cMovim )
		oStatement:SetString( nNum++, cCond )

		cAliasQry := oStatement:OpenAlias()
		oStatement:Destroy() 	
		FwFreeObj(oStatement)
		
		While (cAliasQry)->(!Eof())
		
			AAdd( aRet, { 	(cAliasQry)->TFP_CODIGO,;
								(cAliasQry)->TFP_ENTIDA,;
								(cAliasQry)->TFP_CODINT,;
								(cAliasQry)->TFP_CODLOC,;
								(cAliasQry)->TFP_MOVIM,;
								(cAliasQry)->TFP_SALDO,;
								(cAliasQry)->TFP_LOTE } )
			
			(cAliasQry)->(DbSkip())
			
		EndDo
		(cAliasQry)->(DbCloseArea())
	EndIf

Return(aRet)

//--------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} At880LocMun

Realiza o preenchimento da descrição do Local
@author Serviços
@since 20/08/13
@version P11 R9

@return ExpL:Retorna .T. quando houve sucesso na operação
/*/
//--------------------------------------------------------------------------------------------------------------------
Function At880LocMun()
Local cDescLoc 	:= ""
Local aArea		:= GetArea()

If FwFldGet("TFQ_ENTORI") == eoLOCINTER
	
	cDescLoc	:= Posicione("TER",1,xFilial("TER") + FwFldGet("TFQ_ORIMUN"),"TER->TER_DESCRI")
	
ElseIf FwFldGet("TFQ_ENTORI") == eoLOCATEND
	
	cDescLoc	:= Posicione("ABS",1,xFilial("ABS") + FwFldGet("TFQ_ORIMUN"),"ABS->ABS_DESCRI")
	
EndIf

RestArea(aArea)

Return(cDescLoc)

//--------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} At880VldMov

Limpa os campos de descrição codigo dependendo da seleção do campo TFQ_ITMOV
@author Serviços
@since 20/08/13
@version P11 R9

@return ExpL:Retorna .T. quando houve sucesso na operação
/*/
//--------------------------------------------------------------------------------------------------------------------
Function At880VldMov()
Local lRet			:= .T.
Local oModel		:= FWModelActive()

If 	FwFldGet("TFQ_ITMOV") == itARMA .Or. FwFldGet("TFQ_ITMOV") == itCOLETE
	
	//Limpa o codigo da arma quando ela for alterada
	If !Empty(FwFldGet("TFQ_ITARMA"))
		oModel:LoadValue("TFQMASTER","TFQ_ITARMA", "")
		oModel:LoadValue("TFQMASTER","TFQ_DITEM", "")
	EndIf
	
	//Limpa a Origem da Arma
	If !Empty(FwFldGet("TFQ_ORIGEM")) .OR. !Empty(FwFldGet("TFQ_DSCLOC"))
		oModel:LoadValue("TFQMASTER","TFQ_ORIGEM", "")
		oModel:LoadValue("TFQMASTER","TFQ_DSCLOC", "")
	EndIf
	
	//Tira o valor do campo lote quando for selecionado Arma ou colete
	If !Empty(FwFldGet("TFQ_LOTE"))
		oModel:SetValue("TFQMASTER","TFQ_LOTE", "")
	EndIf
	
	If !Empty(FwFldGet("TFQ_ENTORI"))
		oModel:SetValue("TFQMASTER","TFQ_ENTORI", "")
	EndIf
	
	If !Empty(FwFldGet("TFQ_ORIMUN"))
		oModel:SetValue("TFQMASTER","TFQ_ORIMUN", "")
	EndIf
	
	If !Empty(FwFldGet("TFQ_DSCMUN"))
		oModel:LoadValue("TFQMASTER","TFQ_DSCMUN", "")
	EndIf
	
	If !Empty(FwFldGet("TFQ_QTDMUN"))
		oModel:LoadValue("TFQMASTER","TFQ_QTDMUN", 0)
	EndIf
	
ElseIf	FwFldGet("TFQ_ITMOV") == itMUNICAO 
	
	//Limpa o codigo da arma quando ela for alterada
	If !Empty(FwFldGet("TFQ_ITARMA"))
		oModel:LoadValue("TFQMASTER","TFQ_ITARMA", "")
		oModel:LoadValue("TFQMASTER","TFQ_DITEM", "")
	EndIf
	
	//Limpa a Origem da Arma
	If !Empty(FwFldGet("TFQ_ORIGEM")) .OR. !Empty(FwFldGet("TFQ_DSCLOC"))
		oModel:LoadValue("TFQMASTER","TFQ_ORIGEM", "")
		oModel:LoadValue("TFQMASTER","TFQ_DSCLOC", "")
	EndIf
	
	//Tira o valor do campo Origem e descrição da origem quando for selecionado munição
	If !Empty(FwFldGet("TFQ_ORIGEM"))
		oModel:SetValue("TFQMASTER","TFQ_ORIGEM", "")
	EndIf
	
	If !Empty(FwFldGet("TFQ_DSCLOC"))
		oModel:SetValue("TFQMASTER","TFQ_DSCLOC", "")
	EndIf	
		
EndIf
	
Return(lRet)

//--------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} At880CleanEnt

Limpa os campos de descrição codigo dependendo da seleção do campo TFQ_ENTDES
@author Serviços
@since 20/08/13
@version P11 R9

@return ExpL:Retorna .T. quando houve sucesso na operação
/*/
//--------------------------------------------------------------------------------------------------------------------
Function At880CleanEnt()
Local lRet			:= .T.
Local oModel		:= FWModelActive()

//Antes de Limpar verifica se é manutenção, onde só será permitida
//a movimentação para a empresa
If FwFldGet("TFQ_ENTDES") == edCLIENTE .And. (FwFldGet("TFQ_MOTIVO") == mtMANUTENCAO .Or. FwFldGet("TFQ_MOTIVO") == mtDESCARTE .Or. FwFldGet("TFQ_MOTIVO") == mtENCERRAMENTO)
	Help( ,, "At880CleanEnt",, STR0031, 1, 0 )//'Para movimentação de Manutenção, Descarte e Encerramento, só será possivel selecionar a Empresa'
	lRet := .F.	
EndIf

If 	lRet .And. (FwFldGet("TFQ_ENTDES") == edCLIENTE .Or. FwFldGet("TFQ_ENTDES") == edEMPRESA)
	
	//Limpa o codigo de destino e sua descrição	
	If !Empty(FwFldGet("TFQ_DESTIN"))
		oModel:LoadValue("TFQMASTER","TFQ_DESTIN", "")
		oModel:LoadValue("TFQMASTER","TFQ_DDESTI", "")
	EndIf
			
EndIf
	
Return(lRet)

//--------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} At880ClnOri

Limpa os campos de descrição codigo dependendo da seleção do campo TFQ_ENTORI
@author Serviços
@since 20/08/13
@version P11 R9

@return ExpL:Retorna .T. quando houve sucesso na operação
/*/
//--------------------------------------------------------------------------------------------------------------------
Function At880ClnOri()
Local lRet		:= .T.
Local oModel	:= FWModelActive()

If (FwFldGet("TFQ_ENTORI") == eoLOCINTER .Or. FwFldGet("TFQ_ENTORI") == eoLOCATEND)
	
	//Limpa o codigo de Origem e sua descrição	
	If !Empty(FwFldGet("TFQ_ORIMUN"))
		oModel:LoadValue("TFQMASTER","TFQ_ORIMUN", "")
		oModel:LoadValue("TFQMASTER","TFQ_DSCMUN", "")
	EndIf
			
EndIf
	
Return(lRet)

//--------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} At880MntClean

Limpa os campos de descrição codigo dependendo da seleção do campo TFQ_ENTDES
@author Serviços
@since 20/08/13
@version P11 R9

@return ExpL:Retorna .T. quando houve sucesso na operação
/*/
//--------------------------------------------------------------------------------------------------------------------
Static Function At880MntClean()
Local lRet			:= .T.
Local oModel		:= FWModelActive()

oModel:LoadValue("TFQMASTER","TFQ_CDRESP", "")
oModel:LoadValue("TFQMASTER","TFQ_TPMNT" , "")
oModel:LoadValue("TFQMASTER","TFQ_MOTMNT", "")

Return(lRet)

//--------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} At880SumIt
	Efetua uma contagem dos itens não deletados da grade.
	
@author Serviços
@param oMdl,objeto,Grade de Armamentos
@sample	At880SumIt(oMdl)
@since 20/08/13
@version P11 R9
@return nRet,numerico,A quantidade de itens não deletados.
/*/
//--------------------------------------------------------------------------------------------------------------------
Function At880SumIt(oMdl)
Local nRet	:= 0
Local nI	:= 0
Local cField := ""

If oMdl:HasField('TFO_ITCOD')
	cField := 'TFO_ITCOD'
ElseIf oMdl:HasField('TFO_PRODUT')
	cField := 'TFO_PRODUT'
EndIf

If !Empty(oMdl) .And. !Empty(cField)
	If	!( oMdl:IsEmpty() )
		For nI := 1 To oMdl:Length()
			oMdl:GoLine( nI )
			If !oMdl:IsDeleted() .and. !Empty(oMdl:GetValue(cField))
				nRet++
			EndIf

		Next nI
	EndIf
EndIf


Return nRet

//--------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} At880Status

Verifica a Data de movimentação para realizar a efetivação da movimentação
@author Serviços
@since 20/08/13
@version P11 R9

@return ExpL:Retorna .T. quando houve sucesso na operação
/*/
//--------------------------------------------------------------------------------------------------------------------
Function At880Status(oMdl,lMuni)
Local lRet	:= .T.
Local nI := 0

Default oMdl := nil
Default lMuni := .F.

If FwFldGet("TFQ_STATUS") == stAGENDADA
	//Verifica se a data de movimentação é menor ou igual a database
	If FwFldGet("TFQ_DMOVIM") < DDataBase
		Help( ,, "At880Status",, STR0033, 1, 0 )//'Não é possivel agendar uma movimentação com data menor que a database'
		lRet := .F.
	EndIf
EndIf

If FwFldGet("TFQ_STATUS") == stEFETIVADA
	//Verifica se a data de movimentação é menor ou igual a database
	If FwFldGet("TFQ_DMOVIM") > DDataBase
		Help( ,, "At880Status",, STR0034, 1, 0 )//'A data de movimentação não pode ser maior que a database para ser efetivada'
		lRet := .F.
	EndIf	
EndIf

If lRet .and. !Empty(oMdl)
	For nI := 1 To oMdl:Length()

		oMdl:GoLine( nI )
		
		If !oMdl:IsDeleted()
			//Valida se a data de retorno foi preenchida quando foi selecionado previsão de retorno
			If oMdl:GetValue("TFO_LRET") == "1" .and. Empty(oMdl:GetValue("TFO_DTRET")) 
				Help( ,, "At880Status",, STR0035, 1, 0 ) //'Informe uma data de retorno'
				lRet := .F.	
			EndIf

			// Verifica a Data de Validade dos Armamentos
			If lRet .And. !lMuni
				lRet := At880VlArm(oMdl:GetValue("TFO_ITMOV"),oMdl:GetValue("TFO_ITCOD"),FwFldGet("TFQ_ENTORI"),FwFldGet("TFQ_ENTDES"))
			EndIf
		EndIf
				
		If !lRet
			Exit	// Havendo um caso, abandona.
		EndIf
		
	Next nI
EndIf

Return(lRet)

//--------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} At880DtMovim

Valida a data de retorno e de movimentação
@author Serviços
@since 20/08/13
@version P11 R9

@return ExpL:Retorna .T. quando houve sucesso na operação
/*/
//--------------------------------------------------------------------------------------------------------------------
Function At880DtMovim()
Local lRet	:= .T.

If !Empty(FwFldGet("TFQ_DTRETO"))
	If !FwFldGet("TFQ_DTRETO") > dDataBase
		Help( ,, "At880DtMovim",, STR0036, 1, 0 )
		lRet := .F.	
	EndIf
EndIf

Return(lRet)

//--------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} At880SitArma

Função para alterar o Status das Armas
@sample 	At780SitArma() 
@since		11/09/2013 
@version P11 R9

@Param lIniciada,lFinalizado,Indica se o Status voltará ao antigo ou par Em Manutenção
     
@return lRet, Retorna .T. se houve sucesso
/*/
//--------------------------------------------------------------------------------------------------------------------
Static Function At880SitArma(cTpArma,cItArma,dRetorno)
Local aArea		:= GetArea()
Local cSubLoc		:= ""			//Codigo do SubLocal
Local cDscSub		:= ""			//Descrição do SubLocal
Local cStatus		:= ""			//Status de Armamento
Local oMdl			:= FwModelActive()
Local lMultFil 		:= TFQ->(ColumnPos("TFQ_FILORI")) .And. TFQ->(ColumnPos("TFQ_FILDES")) .And. FindFunction("TecMtFlArm") .And. TecMtFlArm()

Default cTpArma	:= FwFldGet("TFQ_ITMOV")
Default cItArma	:= FwFldGet("TFQ_ITARMA")
Default dRetorno	:= FwFldGet("TFQ_DTRETO")  

Do Case	
	Case oMdl:GetId() == "TECA880" .AND. cTpArma == itARMA
		
		DbSelectArea("TE0")
		TE0->(DbSetOrder(1))
							
		If TE0->(DbSeek(xFilial("TE0")+ cItArma))
			
			//Altera o Status para Implantado	
			RecLock("TE0",.F.)
			
			If FwFldGet("TFQ_ENTDES") == edCLIENTE
				REPLACE TE0_SITUA WITH "2"
			
				//Altera o local de alocação
				If lMultFil
					REPLACE TE0_FILLOC 	With FwFldGet("TFQ_FILDES")					
				Endif
				REPLACE TE0_LOCAL 	WITH FwFldGet("TFQ_DESTIN")
				REPLACE TE0_CLIDES 	WITH FwFldGet("TFQ_DDESTI")
					
				//Verifica se a origem é sublocal e grava o local
				cSubLoc := At880SubLoc(FwFldGet("TFQ_DESTIN"),@cDscSub)
				
				If !Empty(cSubLoc)
					REPLACE TE0_POSTAL 	WITH cSubLoc
					REPLACE TE0_DSCPOS	WITH cDscSub
				Else
					REPLACE TE0_POSTAL 	WITH ""
					REPLACE TE0_DSCPOS	WITH ""
				EndIf	
				
				REPLACE TE0_ENTIDA WITH "ABS"
				REPLACE TE0_DTALOC WITH FwFldGet("TFQ_DMOVIM")
				REPLACE TE0_PRVRET WITH dRetorno
				REPLACE TE0_CODMOV 	With FwFldGet("TFQ_CODIGO")
				
				//Grava o registro de Alteração do FREAR
				At880Hist(cItArma,Nil,.T.,.F.,"2")
				
			ElseIf FwFldGet("TFQ_ENTDES") == edEMPRESA
				
				If FwFldGet("TFQ_MOTIVO") == mtDESCARTE //Descarte
					//Retorna para Ativo
					REPLACE TE0_SITUA WITH "A"
					cStatus := "A"							
				Else
					//Retorna para Ativo
					REPLACE TE0_SITUA WITH "1"
					cStatus := "1"	
				EndIf
				
				//Altera o local de alocação
				If lMultFil
					REPLACE TE0_FILLOC 	With FwFldGet("TFQ_FILDES")					
				Endif
				REPLACE TE0_LOCAL 	WITH FwFldGet("TFQ_DESTIN")
				REPLACE TE0_CLIDES 	WITH FwFldGet("TFQ_DDESTI")
				REPLACE TE0_POSTAL 	WITH ""
				REPLACE TE0_DSCPOS	WITH ""	
				REPLACE TE0_ENTIDA WITH "TER"
				REPLACE TE0_DTALOC WITH FwFldGet("TFQ_DMOVIM")
				REPLACE TE0_PRVRET	WITH dRetorno
				REPLACE TE0_CODMOV 	With FwFldGet("TFQ_CODIGO")
				
				//Grava o registro de Alteração do FREAR
				At880Hist(cItArma,Nil,.T.,.F.,cStatus)
				
			EndIf
			
			MsUnLock()	
					
		EndIf
	Case oMdl:GetId() == "TECA880" .AND. cTpArma == itCOLETE
	
		DbSelectArea("TE1")
		TE1->(DbSetOrder(1))
							
		If TE1->(DbSeek(xFilial("TE1")+cItArma))
			
			//Altera o Status para Implantado	
			RecLock("TE1",.F.)
			
			If FwFldGet("TFQ_ENTDES") == edCLIENTE
				REPLACE TE1_SITUA WITH "2"
				
				//Altera o local de alocação
				If lMultFil
					REPLACE TE1_FILLOC 	With FwFldGet("TFQ_FILDES")					
				Endif
				REPLACE TE1_LOCAL 	WITH FwFldGet("TFQ_DESTIN")
				REPLACE TE1_CLIDES 	WITH FwFldGet("TFQ_DDESTI")
						
				//Verifica se a origem é sublocal e grava o local
				cSubLoc := At880SubLoc(FwFldGet("TFQ_DESTIN"),@cDscSub)
					
				If !Empty(cSubLoc)
					REPLACE TE1_POSTAL 	WITH cSubLoc
					REPLACE TE1_DSCPOS	WITH cDscSub
				Else
					REPLACE TE1_POSTAL 	WITH ""
					REPLACE TE1_DSCPOS	WITH ""
				EndIf	
					
				REPLACE TE1_ENTIDA WITH "ABS"
				REPLACE TE1_DTALOC WITH FwFldGet("TFQ_DMOVIM")
				REPLACE TE1_PRVRET WITH dRetorno
				REPLACE TE1_CODMOV 	With FwFldGet("TFQ_CODIGO")
				//Grava o registro de Alteração do FREAR
				At880Hist(Nil,cItArma,.F.,.T.,"2")
					
			ElseIf FwFldGet("TFQ_ENTDES") == edEMPRESA
					
				If FwFldGet("TFQ_MOTIVO") == mtDESCARTE //Descarte
					//Retorna para Ativo
					REPLACE TE1_SITUA WITH "A"
					cStatus := "A"							
				Else
					//Retorna para Ativo
					REPLACE TE1_SITUA WITH "1"
					cStatus := "1"	
				EndIf
				
				//Altera o local de alocação
				If lMultFil
					REPLACE TE1_FILLOC 	With FwFldGet("TFQ_FILDES")					
				Endif
				REPLACE TE1_LOCAL 	WITH FwFldGet("TFQ_DESTIN")
				REPLACE TE1_CLIDES 	WITH FwFldGet("TFQ_DDESTI")
				REPLACE TE1_POSTAL 	WITH ""
				REPLACE TE1_DSCPOS	WITH ""	
				REPLACE TE1_ENTIDA WITH "TER"
				REPLACE TE1_DTALOC WITH FwFldGet("TFQ_DMOVIM")
				REPLACE TE1_PRVRET	WITH dRetorno
				REPLACE TE1_CODMOV 	With FwFldGet("TFQ_CODIGO")
					
				//Grava o registro de Alteração do FREAR
				At880Hist(Nil,cItArma,.F.,.T.,cStatus)
				
			EndIf
				
			MsUnLock()	
						
		EndIf
	
	Case cTpArma == itMUNICAO
		//Atualiza o cadastro da munição
		RecLock("TE2",.F.)
		TE2->TE2_LOCAL 	:= oMdl:GetValue("TFQMASTER","TFQ_DESTIN")
		TE2->TE2_CLIDES := oMdl:GetValue("TFQMASTER","TFQ_DDESTI")
		MsUnlock()
					
EndCase
RestArea(aArea)
Return(.T.)

//--------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} At880Hist

Atualiza a Tabela TIO para armazenar toda troca de Status dos Armamentos

@author Serviços
@since 20/08/13
@version P11 R9

@param cArma,Codigo da Arma
@Param cColete,Codigo do Colete
@Param lArma,Indica se deve Atualizar a Arma
@Param lColete,Indica se deve atualizar o Colete
@Param cStatus,Indica o Status que foi alterado

@return ExpL:Retorna .T. 
/*/
//--------------------------------------------------------------------------------------------------------------------
Static Function At880Hist(cArma, cColete, lArma, lColete, cStatus)
	Local aArea   := GetArea()
	Local cMotivo := ""
	Local cNum    := ""

	Default cArma	:= ""
	Default cColete	:= ""
	Default lArma	:= .F.	
	Default lColete	:= .F.
	Default cStatus	:= ""

	If cStatus == "2"
		//Concatena o Movimentação mais o codigo
		cMotivo	:= STR0037 + FwFldGet("TFQ_CODIGO") //"Movimentação para implantação, Codigo: "
	ElseIf cStatus == "1" .Or. cStatus == "A"
		//Concatena Retorno mais o codigo
		cMotivo	:= STR0038 + FwFldGet("TFQ_CODIGO") //"Retorno para Empresa, Codigo: "		
	EndIf

	cNum := GSGetNum("TIO", "TIO_CODIGO", 2)

	RecLock("TIO",.T.)
		REPLACE TIO_FILIAL 	With xFilial("TIO")
		REPLACE TIO_CODIGO 	With cNum
		REPLACE TIO_CODMOV 	With FwFldGet("TFQ_CODIGO")
		REPLACE TIO_DTALT 	With dDataBase		
		If lArma
			REPLACE TIO_ARMA 	With cArma
			REPLACE TIO_MOTIVO 	With cMotivo
			REPLACE TIO_FREAR	With cStatus 
		ElseIf lColete
			REPLACE TIO_COLETE 	With cColete
			REPLACE TIO_MOTIVO 	With cMotivo
			REPLACE TIO_FREAR	With cStatus
		EndIf
		REPLACE TIO_CODUSU 	With __cUserId
	TIO->(MsUnlock())

	RestArea(aArea)
		
Return(.T.)

//--------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} At880SubLoc

Verifica se o destino possui sublocal para preencher
@sample 	At880SubLoc() 
@since		11/09/2013 
@version P11 R9

@Param cLocal, Codigo do Local de Atendimento
     
@return cCodLoc, Codigo do SubLocal
/*/
//--------------------------------------------------------------------------------------------------------------------
Static Function At880SubLoc(cLocal,cDesc)
Local cCodLoc	:= ""
Local aArea	:= GetArea()

DbSelectArea("ABS")
ABS->(DbSetOrder(1))
				
If ABS->(DbSeek(xFilial("ABS") + cLocal))
	If !Empty(ABS->ABS_LOCPAI)
		cCodLoc	:= ABS->ABS_LOCPAI
		If ABS->(DbSeek(xFilial("ABS") + cCodLoc))
			cDesc		:= ABS->ABS_DESCRI	
		EndIf	
	EndIf
EndIf

RestArea(aArea)

Return(cCodLoc)

//--------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} At880IncManut

Realiza a Inclusão da manutenção
@sample 	At880IncManut() 
@since		11/09/2013 
@version P11 R9

@Param cArma, Codigo do Armamento
     
@return lRet, Retorna .T. se houve sucesso
/*/
//--------------------------------------------------------------------------------------------------------------------
Static Function At880IncManut(oMdl,cTpArma,cItArma,nQtd)
	Local lRet      := .T.
	Local aCampos   := {}
	Local cCDRESP   := oMdl:GetModel( 'TFQMASTER' ):GetValue("TFQ_CDRESP")
	Local dDMOVIM   := oMdl:GetModel( 'TFQMASTER' ):GetValue("TFQ_DMOVIM")
	Local cTPMNT    := oMdl:GetModel( 'TFQMASTER' ):GetValue("TFQ_TPMNT")
	Local cMOTMNT   := oMdl:GetModel( 'TFQMASTER' ):GetValue("TFQ_MOTMNT")
	Local aArea     := GetArea()
	Local cMotivo   := TFQ->TFQ_MOTIVO
	
	Default cTpArma := ""
	Default cItArma := ""
	Default nQtd    := 0

	Private lMsHelpAuto := .T.			// Variavel de controle interno do ExecAuto
	Private lMsErroAuto := .F.	

	If !Empty(cTpArma) .AND. !Empty(cItArma)

		If (cTpArma == "1" .OR. cTpArma == "2") .AND. cMotivo == '2' // 2 = Manutenção
			//Monta o Array para inclusão da manutenção de Arma == 1 ou Colete == 2
			aCampos:= 	{{"TEU_CODIGO"		    ,GSGetNum("TEU","TEU_CODIGO",1)			,NIL},; //Codigo
						{"TEU_TPARMA"     	    ,cTpArma     							,NIL},; //Tipo da Arma
						{"TEU_CDARM"      	    ,cItArma					     		,NIL},; //Codigo da Arma
						{"TEU_TPRESP"           ,"I" 				                    ,NIL},;  //Manutenção Interna
						{"TEU_CDRESP"			,cCDRESP					      		,NIL},; //Responsavel
						{"TEU_RESPON"			,At780DescRes(cCDRESP)					,NIL},; //Nome do Responsavel
						{"TEU_DTABER"			,dDMOVIM				        		,NIL},; //Data de Abertura
						{"TEU_TPMNT"			,cTPMNT				         			,NIL},; //Tipo de Manutenção
						{"TEU_LOCAL" 			,"2"         							,NIL},; //Manutenção no Local, 2 = Não
						{"TEU_MOTIVO"    		,cMOTMNT 								,NIL},;  //Motivo da Manutenção
						{"TEU_ORIGEM"    		,"TECA880" 								,NIL}}  //Origem da Manutenção
		EndIf				
		
		If !Empty(aCampos)
			Processa( { || TECA780(aCampos,3) },STR0039,STR0040,.F.) //'Aguarde','Processando...'
				
			If lMsErroAuto
				If !isBlind()
					MostraErro()
				EndIf
				DisarmTransaction()
				lRet := .F.
			EndIf
				
			ConfirmSX8()
		EndIf
		
	EndIf

	RestArea(aArea)
Return(lRet)

//--------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} At880MntCmp

Verifica se os campos de Manutenção estão preenchidos
@sample 	At880MntCmp() 
@since		11/09/2013 
@version P11 R9

@Param cArma, Codigo do Armamento
     
@return cCodLoc, Codigo do SubLocal
/*/
//--------------------------------------------------------------------------------------------------------------------
Static Function At880MntCmp()
Local lRet	:= .T.

// Se a movimentação é de manutenção...
If FwFldGet("TFQ_MOTIVO") == mtMANUTENCAO
 
	//Verifica se o campo de responsavel está preenchido
	If Empty(FwFldGet("TFQ_CDRESP"))
		Help( ,, "At880MntCmp",, STR0043, 1, 0 ) //'O campo de responsavel pela manutenção não está preenchido'
		lRet := .F.
	EndIf
	
	//Verifica se o campo tipo da manutenção está preenchido
	If lRet .And. Empty(FwFldGet("TFQ_TPMNT"))
		Help( ,, "At880MntCmp",, STR0044, 1, 0 ) //'O campo tipo da manutenção não está preenchido'
		lRet := .F.
	EndIf
	
	//Verifica se o campo de motivo da manutenção está preenchido
	If lRet .And. Empty(FwFldGet("TFQ_MOTMNT"))
		Help( ,, "At880MntCmp",, STR0045, 1, 0 )//'O campo motivo da manutenção não está preenchido'
		lRet := .F.
	EndIf

EndIf

Return(lRet)

//--------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} At880MntAbe

Verifica se a arma selecionada possui alguma manutenção em aberto
@sample 	At880MntAbe() 
@since		11/09/2013 
@version P11 R9

@Param cArma, Codigo do Armamento
     
@return cCodLoc, Codigo do SubLocal
/*/
//--------------------------------------------------------------------------------------------------------------------
Static Function At880MntAbe(cITMov,cCDMov)
	Local aRet       := {}
	Local cAlias     := ""
	Local cAliasQry  := ""
	Local cArma      := cCDMov
	Local cStatus    := "1"
	Local cTipo      := cITMov
	Local lRet       := .T.
	Local nNum       := 1
	Local oStatement := Nil

	If Select("cAlias") > 0 
		(cAlias)->(DbCloseArea())
	Endif

	cAlias := "SELECT TEU.TEU_CODIGO, "
	cAlias +=        "TEU.TEU_CDARM "
	cAlias += "FROM   ? TEU "
	cAlias += "WHERE  TEU.TEU_FILIAL =  ? "
	cAlias +=        "AND TEU.TEU_TPARMA = ? "
	cAlias +=        "AND TEU.TEU_CDARM = ? "
	cAlias +=        "AND TEU.TEU_STATUS = ? "
	cAlias +=        "AND TEU.D_E_L_E_T_ = ' ' "

	nNum := 1
	cAlias := ChangeQuery(cAlias)
	oStatement  := FwExecStatement():New(cAlias)

	oStatement:SetUnsafe( nNum++, RetSqlName( "TEU" ) )
	oStatement:SetString( nNum++, FwxFilial( "TEU" ) )
	oStatement:SetString( nNum++, cTipo )
	oStatement:SetString( nNum++, cArma )
	oStatement:SetString( nNum++, cStatus )

	cAliasQry := oStatement:OpenAlias()
	oStatement:Destroy()
	FwFreeObj(oStatement)

	While (cAliasQry)->(!Eof())

		AAdd( aRet, { 	(cAliasQry)->TEU_CODIGO,;
							(cAliasQry)->TEU_CDARM } )
		
		(cAliasQry)->(DbSkip())
		
	EndDo

	(cAliasQry)->(DbCloseArea())

	If Len(aRet) > 0
		Help( ,, "At880MntAbe",, STR0046, 1, 0 )	//'A Arma selecionada possui uma manutenção em aberto, Exclua ou encerre a manutenção'
		lRet := .F.
	EndIf

Return(lRet)

//--------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} At880RetResp

Retorna os responsaveis pela alocação
@sample 	At880RetResp() 
@since		11/09/2013 
@version P11 R9
     
@return aARet, Array com o retorno
/*/
//--------------------------------------------------------------------------------------------------------------------
Function At880RetResp()
Local aRet			:= {}
Local oModel 		:= FWModelActive()
Local oModelTFR	:= oModel:GetModel('TFRFUNC')	//Model do Grid Pai
Local nX			:= 0

For nX := 1 To oModelTFR:Length()
	oModelTFR:GoLine(nX)
	AAdd( aRet, FwFldGet("TFR_NOMTEC") )
Next nX
Return(aRet)

//--------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} At880Guia

Realiza a abertura do Link para verificação do C.A do Fornecedor
@author Serviços
@since 20/08/13
@version P11 R9

@Param oModel,Model do Cadastro
/*/
//--------------------------------------------------------------------------------------------------------------------
Function At880Guia(oModel)
Local oDlg		:= Nil
Local aAdvSize	:=	{}
Local cUrl		:= SuperGetMV("MV_TECGUIA",,"")
Local oWebEngine := NIl
Local oWebChannel := Nil
Local nPort		 := 00000

aAdvSize	:=	MsAdvSize()

oMainWnd:CoorsUpdate() // Atualiza as corrdenadas da Janela MAIN
nMyWidth  := oMainWnd:nClientWidth  - 10
nMyHeight := oMainWnd:nClientHeight - 30

oWebChannel := TWebChannel():New()
nPort       := oWebChannel:connect() // Efetua conexão e retorna a porta do WebSocket

DEFINE DIALOG oDlg TITLE STR0047 From aAdvSize[7],00 To nMyHeight,nMyWidth PIXEL //"Movimentação"
	
// Cria componente
oWebEngine := TWebEngine():New(oDlg, 05, 05, nMyHeight-250, nMyWidth-820, cUrl, nPort)
oWebEngine:navigate(cUrl)
oWebEngine:Align := CONTROL_ALIGN_ALLCLIENT

ACTIVATE DIALOG oDlg CENTERED


Return

//--------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} At880IncTFP

Atualiza a Tabela TFP e registra a movimentação

@param cItArma,caractere,Código do Armamento
@param nQtd,numerico,Quantidade movimentada

@author Serviços
@since 20/08/13
@version P11 R9

@return ExpL:Retorna .T. 
/*/
//--------------------------------------------------------------------------------------------------------------------
Static Function At880IncTFP(cItArma,nQtd)
	Local lRet		:= .T.
	Local lContinua	:= .F.
	Local aAreaTFP	:= TFP->(GetArea())
	Local aAreaTE2	:= TE2->(GetArea())
	Local cLote		:= ""
	Local cEntDes	:= "" 		//Variavel com a Entidade de Destino
	Local cCodMun	:= ""
	Local lMultFil 	:= TFQ->(ColumnPos("TFQ_FILORI")) .And. TFQ->(ColumnPos("TFQ_FILDES")) .And. FindFunction("TecMtFlArm") .And. TecMtFlArm()

	Default cItArma	:= FwFldGet("TFQ_ITARMA")
	Default nQtd	:= FwFldGet("TFQ_QTDMUN")

	Do Case
		Case FwFldGet("TFQ_ENTDES") == edCLIENTE // <- Indo para o cofre
			If FwFldGet("TFQ_ENTORI") == "1"
				//Atualiza o Saldo do Local Interno Selecionada para a Movimentação
				DbSelectArea("TFP")
				TFP->(DbSetOrder(7))
				
			Else
				//Atualiza o Saldo do Local de Alocação Selecionada para a Movimentação
				DbSelectArea("TFP")
				
				TFP->(DbSetOrder(8))
				
			EndIf
			
			DbSelectArea("TE2")
			
			TE2->(DbSetOrder(4)) //TFP_FILIAL+TFP_ENTIDA+TFP_CODLOC+TFP_LOTE                                                                                                                       
			
			If TE2->(DbSeek(xFilial("TE2") + cItArma))
			
				If TFP->(DbSeek(xFilial("TFP") + FwFldGet("TFQ_ENTORI") + FwFldGet("TFQ_ORIGEM") + cItArma +IIF(lMultFil,FwFldGet("TFQ_FILORI"),cFilAnt)))
					cLote	:= TFP->TFP_LOTE
					cCodMun := TFP->TFP_CODMUN
					
					RecLock("TFP",.F.)
						REPLACE TFP_SALDO	WITH (TFP->TFP_SALDO - nQtd)
					MsUnlock()
		
					lContinua	:= .T.	
				EndIf
			EndIf
			
			//Inclui local de alocação da munição
			If lContinua
				If FwFldGet("TFQ_ENTDES") == edEMPRESA
					//Atualiza o Saldo do Local Interno Selecionada para a Movimentação
					
					TFP->(DbSetOrder(7))
					
					cEntDes := "1"
				Else
					//Atualiza o Saldo do Local de Alocação Selecionada para a Movimentação
					TFP->(DbSetOrder(8))
				
					cEntDes := "2"
				EndIf
					
				//Se Local de Destino já existe Atualiza os dados e soma o saldo
				If TFP->(DbSeek(xFilial("TFP") + cEntDes + FwFldGet("TFQ_DESTIN") + cItArma +IIF(lMultFil,FwFldGet("TFQ_FILDES") ,cFilAnt)))
					RecLock("TFP",.F.)
					REPLACE TFP_SALDO		With (TFP->TFP_SALDO + nQtd)
				Else
					RecLock("TFP",.T.)
					REPLACE TFP_SALDO		With nQtd
				Endif
						
				REPLACE TFP_FILIAL 	With xFilial("TFP")
				REPLACE TFP_CODIGO 	With GSGetNum("TFP","TFP_CODIGO",1)
				REPLACE TFP_ENTIDA 	With "2" 								//1=Empresa, 2= Cliente
				If lMultFil
					REPLACE TFP_FILLOC 	With FwFldGet("TFQ_FILDES")
				Else
					REPLACE TFP_FILLOC 	With cFilAnt
				Endif
				REPLACE TFP_CODLOC 	With FwFldGet("TFQ_DESTIN")		
				REPLACE TFP_MOVIM 	With "2"								//Saldo Cliente
				REPLACE TFP_CODMUN	With cCodMun
				REPLACE TFP_LOTE	With cLote
				REPLACE TFP_STATUS	With "1"								//Efetivada
				REPLACE TFP_DTHIST	With FwFldGet("TFQ_DMOVIM")
				REPLACE TFP_CODMOV	With FwFldGet("TFQ_CODIGO")
				REPLACE TFP_PRODUT	With cItArma
				MsUnlock()
			EndIf
		
		Case FwFldGet("TFQ_ENTDES") == edEMPRESA // -> Indo para o Cliente (contrato)
			
			Do Case
				Case FwFldGet("TFQ_MOTIVO") == mtIMPLANTACAO
					If FwFldGet("TFQ_ENTORI") == "1"
						//Atualiza o Saldo do Local Interno Selecionada para a Movimentação
						DbSelectArea("TFP")
						
						TFP->(DbSetOrder(7))
						
					Else
						//Atualiza o Saldo do Local de Alocação Selecionada para a Movimentação
						DbSelectArea("TFP")
						
						TFP->(DbSetOrder(8))
						
					EndIf
					
					DbSelectArea("TE2")
					
					TE2->(DbSetOrder(4))
					
					If TE2->(DbSeek(xFilial("TE2") + cItArma))
					
						If TFP->(DbSeek(xFilial("TFP") + FwFldGet("TFQ_ENTORI") + FwFldGet("TFQ_ORIGEM") + cItArma +IIF(lMultFil,FwFldGet("TFQ_FILORI") ,cFilAnt)))
							cLote	:= TFP->TFP_LOTE
							cCodMun := TFP->TFP_CODMUN
							RecLock("TFP",.F.)
							REPLACE TFP_SALDO		With (TFP->TFP_SALDO - nQtd)
							MsUnlock()
							lContinua	:= .T.	
						EndIf
					EndIf
					
					//Inclui local de alocação da munição
					If lContinua
						If FwFldGet("TFQ_ENTDES") == edEMPRESA
							//Atualiza o Saldo do Local Interno Selecionada para a Movimentação
							
							TFP->(DbSetOrder(7))
							
							cEntDes := "1"
						Else
							//Atualiza o Saldo do Local de Alocação Selecionada para a Movimentação
							
							TFP->(DbSetOrder(8))
							
							cEntDes := "2"
						EndIf
							
						//Se Local de Destino já existe Atualiza os dados e soma o saldo
						If TFP->(DbSeek(xFilial("TFP") + cEntDes + FwFldGet("TFQ_DESTIN") + cItArma +IIF(lMultFil,FwFldGet("TFQ_FILDES"),cFilAnt)))
							RecLock("TFP",.F.)
							REPLACE TFP_SALDO		With (TFP->TFP_SALDO + nQtd)
						Else
							RecLock("TFP",.T.)
							REPLACE TFP_SALDO		With nQtd
						EndIf	
									
						REPLACE TFP_FILIAL 	With xFilial("TFP")
						REPLACE TFP_CODIGO 	With GSGetNum("TFP","TFP_CODIGO",1)
						REPLACE TFP_ENTIDA 	With "1" 								//1=Empresa, 2= Cliente
						If lMultFil
							REPLACE TFP_FILLOC 	With FwFldGet("TFQ_FILDES")
						Else		
							REPLACE TFP_FILLOC 	With cFilAnt	
						Endif
						REPLACE TFP_CODINT 	With FwFldGet("TFQ_DESTIN")		
						REPLACE TFP_MOVIM 	With "1"								//Saldo Empresa					
						REPLACE TFP_CODMUN	With cCodMun
						REPLACE TFP_LOTE	With cLote
						REPLACE TFP_STATUS	With "1"								//Efetivada
						REPLACE TFP_DTHIST	With FwFldGet("TFQ_DMOVIM")
						REPLACE TFP_CODMOV	With FwFldGet("TFQ_CODIGO")
						REPLACE TFP_PRODUT	With cItArma		
						MsUnlock()
					EndIf
				
				Case FwFldGet("TFQ_MOTIVO") == mtDESCARTE //Descarte
					If FwFldGet("TFQ_ENTORI") == "1"
						//Atualiza o Saldo do Local Interno Selecionada para a Movimentação
						DbSelectArea("TFP")
						
						TFP->(DbSetOrder(7))
						
					Else
						//Atualiza o Saldo do Local de Alocação Selecionada para a Movimentação
						DbSelectArea("TFP")
						
						TFP->(DbSetOrder(8))
						
					EndIf
					
					DbSelectArea("TE2")
					
					TE2->(DbSetOrder(4))
					
					If TE2->(DbSeek(xFilial("TE2") + cItArma))
						If TFP->(DbSeek(xFilial("TFP") + FwFldGet("TFQ_ENTORI") + FwFldGet("TFQ_ORIGEM") + cItArma +IIF(lMultFil,FwFldGet("TFQ_FILORI"),cFilAnt)))
							cLote	:= TFP->TFP_LOTE
							cCodMun := TFP->TFP_CODMUN
							RecLock("TFP",.F.)
							REPLACE TFP_SALDO With (TFP->TFP_SALDO - nQtd)
							MsUnlock()
							lContinua	:= .T.	
						EndIf
					EndIf
					
					//Inclui local de alocação da munição
					If lContinua
						//Atualiza o Saldo do Local Interno Selecionada para a Movimentação
						TFP->(DbSetOrder(2))
						cEntDes := "1"
							
						RecLock("TFP",.T.)
							
						REPLACE TFP_FILIAL 	With xFilial("TFP")
						REPLACE TFP_CODIGO 	With GSGetNum("TFP","TFP_CODIGO",1)
						REPLACE TFP_ENTIDA 	With "1" 								//1=Empresa, 2= Cliente
						If lMultFil
							REPLACE TFP_FILLOC 	With FwFldGet("TFQ_FILDES")
						Else			
							REPLACE TFP_FILLOC 	With cFilAnt		
						Endif
						REPLACE TFP_CODINT 	With FwFldGet("TFQ_DESTIN")		
						REPLACE TFP_MOVIM 	With "8"								//Saldo Empresa		
						REPLACE TFP_SALDO	With nQtd					
						REPLACE TFP_CODMUN	With cCodMun					
						REPLACE TFP_LOTE	With cLote
						REPLACE TFP_STATUS	With "1"								//Efetivada
						REPLACE TFP_DTHIST	With FwFldGet("TFQ_DMOVIM")
						REPLACE TFP_CODMOV	With FwFldGet("TFQ_CODIGO")	
						REPLACE TFP_PRODUT	With cItArma
						MsUnlock()
					EndIf	
				Case FwFldGet("TFQ_MOTIVO") == mtENCERRAMENTO //Encerramento
					If FwFldGet("TFQ_ENTORI") == "1"
						//Atualiza o Saldo do Local Interno Selecionada para a Movimentação
						DbSelectArea("TFP")
					
						TFP->(DbSetOrder(7))
						
					Else
						//Atualiza o Saldo do Local de Alocação Selecionada para a Movimentação
						DbSelectArea("TFP")
						
						TFP->(DbSetOrder(8))
						
					EndIf
					
					DbSelectArea("TE2")
					
					TE2->(DbSetOrder(4))
					
					If TE2->(DbSeek(xFilial("TE2") + cItArma))
					
						If TFP->(DbSeek(xFilial("TFP") + FwFldGet("TFQ_ENTORI") + FwFldGet("TFQ_ORIGEM") + cItArma +IIF(lMultFil,FwFldGet("TFQ_FILORI"),cFilAnt)))
							cLote	:= TFP->TFP_LOTE
							cCodMun := TFP->TFP_CODMUN
							RecLock("TFP",.F.)
							REPLACE TFP_SALDO		With (TFP->TFP_SALDO - nQtd)
							MsUnlock()
							lContinua	:= .T.	
						EndIf
					EndIf
		
					//Inclui local de alocação da munição
					If lContinua
						//Atualiza o Saldo do Local Interno Selecionada para a Movimentação
			
						TFP->(DbSetOrder(7))
						
						cEntDes := "1"
							
						//Se Local de Destino já existe Atualiza os dados e soma o saldo
						If aT730PosTFP(xFilial("TFP"),cEntDes,FwFldGet("TFQ_DESTIN"),cItArma,Iif(lMultFil,FwFldGet("TFQ_FILDES"),cFilAnt))
							RecLock("TFP",.F.)
							REPLACE TFP_SALDO		With (TFP->TFP_SALDO + nQtd)
						Else
							RecLock("TFP",.T.)
							REPLACE TFP_SALDO		With nQtd
						EndIf	
			
						REPLACE TFP_FILIAL 	With xFilial("TFP")
						REPLACE TFP_CODIGO 	With GSGetNum("TFP","TFP_CODIGO",1)
						REPLACE TFP_ENTIDA 	With "1" 								//1=Empresa, 2= Cliente
						If lMultFil
							REPLACE TFP_FILLOC 	With FwFldGet("TFQ_FILDES")
						Else				
							REPLACE TFP_FILLOC 	With cFilAnt		
						Endif
						REPLACE TFP_CODINT 	With FwFldGet("TFQ_DESTIN")		
						REPLACE TFP_MOVIM 	With "1"								//Saldo Empresa		
						REPLACE TFP_CODMUN	With cCodMun
						REPLACE TFP_LOTE	With cLote
						REPLACE TFP_STATUS	With "1"								//Efetivada
						REPLACE TFP_DTHIST	With FwFldGet("TFQ_DMOVIM")
						REPLACE TFP_CODMOV	With FwFldGet("TFQ_CODIGO")
						REPLACE TFP_PRODUT	With cItArma
						MsUnlock()
					EndIf	
			EndCase				
	EndCase
	RestArea(aAreaTFP)
	RestArea(aAreaTE2)
Return(lRet)

//--------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} At880IniPad

Inicializador do local de origem da munição

@author Serviços
@since 20/08/13
@version P11 R9

@return ExpC:Descrição do Local de origem
/*/
//--------------------------------------------------------------------------------------------------------------------
Function At880IniPad(cEntOri,cOriMun)
Local cDesc 	:= ""
Local aArea	:= GetArea()
Local lModoInc	:= .F.

If Type('INCLUI') == 'L'
	lModoInc := INCLUI
EndIf 

If !lModoInc .And. !Empty(cENTORI) .And. !Empty(cORIMUN)
	Do Case
		Case cEntOri == "2"
			cDesc := Alltrim(Posicione("ABS",1,xFilial("ABS")+ cOriMun ,"ABS_DESCRI"))

		Case cEntOri == "1"
			cDesc := Alltrim(Posicione("TER",1,xFilial("TER")+ cOriMun ,"TER_DESCRI"))
	
	EndCase
EndIf
RestArea(aArea)
Return(cDesc)

//--------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} At880IniLote

Inicializador do Lote da munição

@author Serviços
@since 20/08/13
@version P11 R9

@return ExpC:Descrição do Lote
/*/
//--------------------------------------------------------------------------------------------------------------------
Function At880IniLote(cITMOV,cCdARMA)
Local cDesc 	:= ""
Local aArea	:= GetArea()

If !Inclui .And. !Empty(cITMOV) .And. !Empty(cCdARMA)
	If cITMOV == itMUNICAO
		cDesc := Posicione("TE2",1,xFilial("TE2") + cCdARMA ,"TE2->TE2_LOTE") 
	EndIf	
EndIf
RestArea(aArea)
Return(cDesc)

//----------------------------------------------------------
/*/{Protheus.doc} At880VlCont
Efetua a validação do campo de contrato

@Return 	lRet,, define se bloqueia ou nao

@author 	Serviços
@since 		28/04/2014
/*/
//----------------------------------------------------------
Function At880VlCont( oModel, cLocal, cContrato )
	Local lRet       := (FwFldGet("TFQ_ENTDES") == edEMPRESA)
	Local cRevisao	 := ""

	If !lRet
		If Empty(cContrato)
			lRet := At680Perm( Nil, __cUserId, "007" ) // Pode movimentar armamento fora do contrato?		
			If !lRet
				oModel:GetModel():SetErrorMessage(oModel:GetId(),"TFQ_CONTRT",oModel:GetModel():GetId(),"TFQ_CONTRT",'AT880ACE',; 
					STR0060, "" ) // "Usuário sem permissão para movimentação fora do contrato!"			
			EndIf
		Else 
			IF _lGsOrcArm
				// Verifica se é um contrato ATIVO válido:
				lRet := !Empty(Posicione("CN9",7,xFilial('CN9')+cContrato+"05","CN9_NUMERO")) // INDICE 7 - CN9_FILIAL+CN9_NUMERO+CN9_SITUAC

				If lRet
					cRevisao := Posicione("CN9",7,xFilial('CN9')+cContrato+"05","CN9_REVISA") // INDICE 7 - CN9_FILIAL+CN9_NUMERO+CN9_SITUAC
					// Verifica se o contrato possui armamento:
					lRet := at880VlCN9( oModel, cContrato, cRevisao )
					If !lRet
						oModel:GetModel():SetErrorMessage(oModel:GetId(),"TFQ_CONTRT",oModel:GetModel():GetId(),"TFQ_CONTRT",'AT880VLCONT',; 
							STR0126, "" ) // "Não existe contrato ativo com esse código digitado."
					EndIf
				Else
					oModel:GetModel():SetErrorMessage(oModel:GetId(),"TFQ_CONTRT",oModel:GetModel():GetId(),"TFQ_CONTRT",'AT880VLCONT',; 
						STR0127, "" ) // "Não existe contrato ativo com esse código digitado."
				EndIf
			Else	
				lRet := At880FilCont( cLocal, cContrato )
				If !lRet
					oModel:GetModel():SetErrorMessage(oModel:GetId(),"TFQ_CONTRT",oModel:GetModel():GetId(),"TFQ_CONTRT",'AT880ACE2',; 
						STR0061, "" ) // "Contrato invalido para o local escolhido!"	
				EndIf 
			Endif	
		EndIf
	EndIf

Return(lRet)

//----------------------------------------------------------
/*/{Protheus.doc} At880FilCont
Efetua o filtro dos contratos do local

@param 		oModel

@Return 	lRet,, define se bloqueia ou nao

@author 	Serviços
@since 		28/04/2014
/*/
//----------------------------------------------------------
Function At880FilCont(cCodLocal, cContrato, cRevisao )

Local aArea:= GetArea()
Local lRet := .F.

Default cRevisao := ""

If CN9->CN9_SITUAC == "05"
	DbSelectArea("TFL")
	TFL->(dbSetOrder(3)) //TFL_FILIAL+TFL_LOCAL
	If TFL->( dbSeek( xFilial("TFL") + cCodLocal ) )
		While TFL->(!Eof()) .And. TFL->TFL_LOCAL == cCodLocal		
			If cContrato == TFL->TFL_CONTRT .And. ;
			   (Empty(cRevisao) .Or. cRevisao == TFL->TFL_CONREV)
				lRet := .T.
				Exit
			EndIf			
			TFL->(dbSkip())		
		EndDo
	EndIf
EndIf
RestArea(aArea)
Return lRet

//----------------------------------------------------------
/*/{Protheus.doc} AT880GFLD
	Realiza a classificação de campos baseado num determinado contexto 

@param 		cTipo,caractere,Constante que determina se a estrutura a ser construida: ARMAS - MUNICOES - COLETES
@param		cCampo,caractere,Nome do campo para validação de apresentação na interface.

@sample	AT880GFLD(cTipo, cCampo)
@return 	lRet,, define se apresenta ou nao

@author 	Serviços
@since 		02/06/2015
/*/
//----------------------------------------------------------
Function AT880GFLD(cTipo, cCampo)
	Local cHeader    := ''
	Local lRet       := .F.

	cHeader += 'TFQ_FILIAL;TFQ_CODIGO;TFQ_ORIGEM;TFQ_DSCLOC;TFQ_ENTORI;TFQ_MOTIVO;TFQ_ENTDES;TFQ_DESTIN;'
	cHeader += 'TFQ_DDESTI;TFQ_JUSTIF;TFQ_DMOVIM;TFQ_RESTRA;TFQ_DRESP;TFQ_STATUS;TFQ_USUAR;TFQ_DATA;TFQ_HORA;'
	If _lGsOrcArm
		cHeader += 'TFQ_ENTIDA;TFQ_ULTSTA;TFQ_CDRESP;TFQ_TPMNT;TFQ_MOTMNT;TFQ_CONTRT;TFQ_FILORI;TFQ_FILDES;TFQ_CODTFL'
	else
		cHeader += 'TFQ_ENTIDA;TFQ_ULTSTA;TFQ_CDRESP;TFQ_TPMNT;TFQ_MOTMNT;TFQ_CONTRT;TFQ_FILORI;TFQ_FILDES'	
	Endif
		If TFQ->(ColumnPos("TFQ_CONREV")) > 0 .And. TFQ->(ColumnPos("TFQ_POSTO")) > 0
			cHeader += ';TFQ_CONREV;TFQ_POSTO'
		EndIf
	cCampo := AllTrim(cCampo)

	If cTipo == 'CABECALHO'
		lRet := cCampo $ cHeader
	ElseIf	cTipo == 'ARMAS'
		If _lGsOrcArm
			lRet := cCampo $ 'TFO_ITCOD;TFO_ITMOV;TFO_DESCR;TFO_LGUIA;TFO_NRGUIA;TFO_LRET;TFO_DTRET;TFO_CODTXQ'
		Else
			lRet := cCampo $ 'TFO_ITCOD;TFO_ITMOV;TFO_DESCR;TFO_LGUIA;TFO_NRGUIA;TFO_LRET;TFO_DTRET'
		Endif
	ElseIf	cTipo == 'MUNICOES'
		If _lGsOrcArm
			lRet := cCampo $ 'TFO_PRODUT;TFO_ITMOV;TFO_DESCR;TFO_LOTE;TFO_QTDE;TFO_LGUIA;TFO_NRGUIA;TFO_LRET;TFO_DTRET;TFO_CODTXQ;TFO_ITCOD' //TFO_CARGA;
		else
			lRet := cCampo $ 'TFO_PRODUT;TFO_ITMOV;TFO_DSCMUN;TFO_LOTE;TFO_QTDE;TFO_LGUIA;TFO_NRGUIA;TFO_LRET;TFO_DTRET' //TFO_CARGA;
		Endif
	ElseIf	cTipo == 'COLETES'
		If _lGsOrcArm
			lRet := cCampo $ 'TFO_ITCOD;TFO_ITMOV;TFO_DESCR;TFO_LGUIA;TFO_NRGUIA;TFO_LRET;TFO_DTRET;TFO_CODTXQ'
		else
			lRet := cCampo $ 'TFO_ITCOD;TFO_ITMOV;TFO_DESCR;TFO_LGUIA;TFO_NRGUIA;TFO_LRET;TFO_DTRET'	
		EndIf
	Endif

Return lRet

//----------------------------------------------------------
/*/{Protheus.doc} At880NGuia
	Realiza consistência no preenchimento do Nr da Guia.  
@Param		oMdl.objeto,Modelo de dados em edição

@sample	At880NGuia(oMdl)
@return 	lRet,, Define se valida a edição

@author 	Serviços
@since 		02/06/2015
/*/
//----------------------------------------------------------
Function At880NGuia(oMdl)
Local lRet := .T.
Local nOperation := oMdl:GetOperation()

If nOperation == MODEL_OPERATION_UPDATE .Or. nOperation == MODEL_OPERATION_INSERT
	If oMdl:GetValue('TFO_LGUIA') == '2' .AND. !Empty(oMdl:GetValue('TFO_NRGUIA'))
		oMdl:LoadValue('TFO_NRGUIA',Space(TamSX3('TFO_NRGUIA')[1]))
	EndIf
EndIf
Return lRet

//----------------------------------------------------------
/*/{Protheus.doc} At880VDtMv
	Realiza a validação da data do movimento versus a data de retorno do armamento.  

@param		oMdl,OObjeto,Modelo de dados Master
@sample	At880VDtMv(oMdl)
@return 	lRet,logico,Determina a validação da edição

@author 	Serviços
@since 		02/06/2015
/*/
//----------------------------------------------------------
Function At880VDtMv(oMdl)
Local lRet			:= .T.
Local oMdlTFO		:= nil
Local dMov			:= oMdl:GetValue('TFQ_DMOVIM')
Local dRet			:= CToD('')
Local nJ			:= 0
Local nI			:= 0

For nI := 1 To 3
	If		nI == 1 
		//Verifica as datas de retorno do grupo armas
		oMdlTFO	:= oMdl:GetModel():GetModel('TFOARMA')
	ElseIf nI == 2
		//Verifica as datas de retorno do grupo Munições
		oMdlTFO	:= oMdl:GetModel():GetModel('TFOMUNI')
	ElseIf nI == 3
		//Verifica as datas de retorno do grupo Coletes
		oMdlTFO	:= oMdl:GetModel():GetModel('TFOCOLE')
	EndIf
	
	For nJ := 1 To oMdlTFO:Length()
		oMdlTFO:GoLine(nJ)
		If !oMdlTFO:IsDeleted()
			dRet := oMdlTFO:GetValue('TFO_DTRET')
			If !Empty(dMov) .and. !Empty(dRet)
				If !(lRet := dRet >= dMov)
					Exit		
				EndIf
			EndIf		
		EndIf
	Next nJ
	
	If !lRet
		Help( ,, "AT880VLDTRT",, STR0065, 1, 0) // "Data de retorno deve ser maior ou igual que a data da movimentação!"
		Exit
	EndIf
Next nI
Return lRet

//----------------------------------------------------------
/*/{Protheus.doc} At880VlArm
	Realiza a validação da data de validade do armamento.  

@param		cItMov,caractere,Tipo do armamento
@param		cItCod,caractere,Código do armamento

@sample	At880VlArm(cItMov,cItCod)
@return 	lRet,logico,Determina a data de validade é igual ou superior à data da movimentação

@author 	Serviços
@since 		02/06/2015
/*/
//----------------------------------------------------------
Function At880VlArm(cItMov,cItCod,cOri,cDes)
Local lRet		:= .T.
Local aArea		:= GetArea()
Local dMov		:= FwFldGet('TFQ_DMOVIM')
Local dValida	:= CToD('')

Default cItMov := ""
Default cItCod := ""
Default cOri := ""
Default cDes := ""

//Valida apenas se o destino nao for igual a 2: Empresa
//Movimentacoes com destino igual a empresa podem acontecer mesmo quando o armamento esta vencido por conta de operacoes de descarte
If alltrim(cDes) != "2"
If !Empty(cItMov) .and. !Empty(cItCod)
	Do Case
		Case cItMov == itARMA
			DbSelectArea("TE0");	TE0->(DbSetOrder(1))
			If TE0->(DbSeek(xFilial("TE0") + cItCod))
				dValida := TE0->TE0_VALIDA
			EndIf
		Case cItMov == itCOLETE
			DbSelectArea("TE1");TE1->(DbSetOrder(1))
			If TE1->(DbSeek(xFilial("TE1") + cItCod))
				dValida := TE1->TE1_VALIDA
			EndIf
	EndCase
	If !Empty(dValida)
		lRet := dValida >= dMov
	EndIf
	If !lRet
		Help( ,, "At880VlArm",, STR0066, 1, 0) // "Data de Validade do Armamento expirou!"
	EndIf
EndIf
EndIf

RestArea(aArea)
Return lRet

//----------------------------------------------------------
/*/{Protheus.doc} At880VDtRt
	Realiza a validação da data prevista de retorno do armamento.  

@param		oMdl,OObjeto,Modelo de dados em edição
@sample	At880VDtRt(oMdl)
@return 	lRet,logico,Determina a validação da edição

@author 	Serviços
@since 		02/06/2015
/*/
//----------------------------------------------------------
Function At880VDtRt(oMdl)
Local lRet	:= .T.
Local dRet	:= oMdl:GetValue('TFO_DTRET')
Local dMov	:= FwFldGet('TFQ_DMOVIM')

If !Empty(dRet) .and. !Empty(dMov)
	If dRet < dMov
		Help( ,, "AT880VLDTRT",, STR0067, 1, 0) // "Data de retorno deve ser maior ou igual que a data da movimentação!"
		lRet := .F.		
	EndIf
EndIf
Return lRet

//----------------------------------------------------------
/*/{Protheus.doc} At880DtPrv
	Realiza consistência no preenchimento da Previsão de retorno do armamento.  

@param		oMdl,OObjeto,Modelo de dados em edição
@sample	At880DtPrv(oMdl)
@return 	lRet,Logico,Define se valida a edição

@author 	Serviços
@since 		02/06/2015
/*/
//----------------------------------------------------------
Function At880DtPrv(oMdl)
Local lRet := .T.

If oMdl:GetValue('TFO_LRET') == '2' .AND. !Empty(oMdl:GetValue('TFO_DTRET'))
	oMdl:LoadValue('TFO_DTRET',CToD(''))
EndIf
Return lRet

//----------------------------------------------------------
/*/{Protheus.doc} At880VlEnt
	Valida as entidades de Origem e Destino da Movimentação bem como o motivo para a movimentação entre elas.  
@param		oModel,object,Objeto de dados Movimentação de Armamentos
@param		cIdCall,caractere,Identificação do campo que está sendo editado
@sample	At880VlEnt(oMdlcIdCall)
@return 	lRet,, Determina se os critérios para movimentação entre as entidades foram cumpridos ou não

@author 	Serviços
@since 		02/06/2015
/*/
//----------------------------------------------------------
Function At880VlEnt(oMdl,cIdCall)
	Local cEntDest := oMdl:GetValue( 'TFQ_ENTDES' )
	Local cMotivo  := oMdl:GetValue( 'TFQ_MOTIVO' )
	Local lRet     := .T.

	If lRet
		// Limpa os campos dependentes do tipo de entidade: Origem ou Destino
		If		cIdCall == 'TFQ_ENTORI'
			oMdl:LoadValue('TFQ_ORIGEM',Space(TAMSX3('TFQ_ORIGEM')[1]))
			oMdl:LoadValue('TFQ_DSCLOC',Space(TAMSX3('TFQ_DSCLOC')[1]))
		ElseIf	cIdCall == 'TFQ_ENTDES'
			oMdl:LoadValue('TFQ_DESTIN',Space(TAMSX3('TFQ_DESTIN')[1]))
			oMdl:LoadValue('TFQ_DDESTI',Space(TAMSX3('TFQ_DDESTI')[1]))
		EndIf
	EndIf 

	// Valida o motivo da movimentação versus o destino
	// 1-Implantações tem sempre como destino o Local de Atendimento de Cliente.
	// 2-Manutenções  tem sempre como destino a Empresa prestadora do serviço.
	// 3-Descartes    tem sempre como destino a Empresa prestadora do serviço.
	// 4-Reforço      tem sempre como destino o Local de Atendimento de Cliente. 

	If lRet .and. cEntDest == edCLIENTE .And. (cMotivo == mtMANUTENCAO .Or. cMotivo == mtDESCARTE .Or. cMotivo == mtENCERRAMENTO)
		Help( ,, "At880VlEnt",, STR0031, 1, 0 )//'Para movimentação de Manutenção, Descarte e Encerramento, só será possivel selecionar a Empresa como destino'
		lRet := .F.	
	EndIf

	//Para a movimentação de reforco só será possivel selecionar o cliente
	If lRet .and. cEntDest == edEMPRESA .And. cMotivo == mtREFORCO
		Help( ,, "At880VlEnt",, STR0032, 1, 0 )//'Para movimentação de Reforço ou Implantação, só será possivel selecionar o cliente como destino'
		lRet := .F.	
	EndIf
Return lRet

//----------------------------------------------------------
/*/{Protheus.doc} At880VMXA
	verifica se a arma vinculada à municação está relacionada no Grid de Armas.  
@param		oModel,object,Objeto de dados Movimentação de Armamentos
@sample	At880VMXA(oMdl)
@return 	lRet,logico,determinando se tem um cadastro respectivo ou não.

@author 	Serviços
@since 		02/06/2015
/*/
//----------------------------------------------------------
Function At880VMXA(oMdl)
Local lRet			:= .F.
Local oMdlArma	:= oModel:GetModel('TFOARMA')
Local cCdArma		:= oMdl:GetValue('TFO_ARMA')
Local nI			:= 0

If !Empty(cCdArma)
	For nI := 1 to oMdlArma:Length()
		oMdlArma:GoLine(nI)
		If !oMdlArma:IsDeleted()
			If lRet := oMdlArma:GetValue('TFO_ITCOD') == cCdArma
				Exit
			EndIf
		EndIf
	Next nI
Else
	lRet := .T.
EndIf

If !lRet
	Help( ,, "At880VMXA",,STR0069, 1, 0 )//'Não há registro com este código na Aba de Armas!'
EndIf

Return lRet

//----------------------------------------------------------
/*/{Protheus.doc} At880PosGA
	  
@param		oMdl,object,Objeto Master do formulário de movimentação
@param		nLine,numerico,Linha da grade na edição atual
@param		cAcao,caractere,Mode de Edição: ISENABLE,CANSETVALUE,SETVALUE,ADDLINE,DELETE,UNDELETE, etc.
@param		cCampo,caractere,Identificador do campo com foco de edição

@sample	At880PosGA(oMdl,nLine,cAcao,cCampo)
@return 	lRet,logico,

@author 	Serviços
@since 		02/06/2015
/*/
//----------------------------------------------------------
Function At880PosGA(oMdl,nLine,cAcao,cCampo)
Local lRet := .T.
Return lRet

//----------------------------------------------------------
/*/{Protheus.doc} At880VIMV
	Validação dos Itens de Movimentação
	  
@param		oModel,object,Objeto relativo a Armamento

@sample	At880VIMV(oMdl)
@return 	lRet,logico,Determina se o item pode ser movimentado.

@author 	Serviços
@since 		02/06/2015
/*/
//----------------------------------------------------------
Function At880VIMV(oMdl)
	Local cItCod     := oMdl:GetValue( 'TFO_ITCOD' )
	Local cItMov     := oMdl:GetValue( 'TFO_ITMOV' )
	Local cMotivo    := FwFldGet( 'TFQ_MOTIVO' )
	Local lRet       := .T.
	Local nOperation := oMdl:GetOperation()

	If !Empty(cItCod)

		If lRet .And. oMdl:GetValue("TFO_ITMOV") == itARMA .And. !tecExistCPO("TE0", xFilial("TE0")+cItCod)
			Help( ,, "At880VIMV",, "Código de Arma não cadastrado.", 1, 0 )// "Código de Arma não cadastrado."
			lRet := .F.	
		Endif

		If lRet .And. oMdl:GetValue("TFO_ITMOV") == itCOLETE .And. !tecExistCPO("TE1", xFilial("TE1")+cItCod)
			Help( ,, "At880VIMV",, "Código de Colete não cadastrado", 1, 0 )// "Código de Colete não cadastrado"
			lRet := .F.	
		Endif

		// Verifica se a arma ou colete DIGITADO no campo é válido:
		If lRet .And. !(vldArmCod(oMdl, cItCod, cItMov))
			Help( ,, "At880VIMV",, "Esse armamento não existe ou não está no Local de Origem/Posto informado.", 1, 0 )// "Esse armamento não existe ou não está no Local de Origem/Posto informado."
			lRet := .F.	
		EndIf

		//Verifico se já existe um agendamento para o armamento selecionado
		If lRet .And. cItMov == itARMA .And. nOperation == MODEL_OPERATION_INSERT .And. At880Agend(cItMov,cItCod)
			Help( ,, "At880VIMV",, STR0009, 1, 0 )//'Alocação','Já existe um agendamento para esse armamento'
			lRet := .F.	
		EndIf

		If lRet .And. cItMov == itCOLETE .And. nOperation == MODEL_OPERATION_INSERT .And. At880Agend(cItMov,cItCod)
			Help( ,, "At880VIMV",, STR0009, 1, 0 )//'Alocação','Já existe um agendamento para esse armamento'
			lRet := .F.	
		EndIf

		//Verificar se o local de origem está preenchido
		If lRet .And. Empty(FwFldGet('TFQ_ORIGEM'))
			Help( ,, "At880VIMV",, STR0071, 1, 0 )//'Alocação','A Origem da Movimentação deve ser informada!'
			lRet := .F.
		EndIf

		If lRet .And. cItMov <> itMUNICAO
			//Verifica o Status das armas baseado do motivo
			lRet := At880VldStat(cItMov,cItCod,cMotivo)
		EndIf

		//Verifica se a arma selecionada possui manutenção em aberto
		If lRet
			lRet := At880MntAbe(cItMov,cItCod)
		EndIf

		//Verifica a Data de Validade do armamento
		If lRet .And. FwFldGet("TFQ_ENTDES") == edCLIENTE
			lRet := At880VlArm(cItMov,cItCod,FwFldGet("TFQ_ENTORI"),FwFldGet("TFQ_ENTDES"))
		EndIf

	EndIf

	//Verifica se a arma esta desativada e indo para um cliente
	If lRet .And. FwFldGet("TFQ_ENTDES") == edCLIENTE .And. oMdl:GetValue("TFO_ITMOV") == itARMA
		If  alltrim(upper(Posicione("TE0",1,xFilial('TE0') + oMdl:GetValue('TFO_ITCOD'),"TE0_SITUA"))) == "9" .or. ;
			alltrim(upper(Posicione("TE0",1,xFilial('TE0') + oMdl:GetValue('TFO_ITCOD'),"TE0_SITUA"))) == "A"
			lRet := .F.
			Help( ,,,STR0074,STR0075, 1, 0 ) //"Arma Descartada ou Desativada" //"O armamento escolhido tem situação igual a Desativada ou Descartada"
		EndIf
	EndIf

	//Verifica se o colete esta desativado e indo para um cliente
	If lRet .And. FwFldGet("TFQ_ENTDES") == edCLIENTE .And. oMdl:GetValue("TFO_ITMOV") == itCOLETE
		If  alltrim(upper(Posicione("TE1",1,xFilial('TE1') + oMdl:GetValue('TFO_ITCOD'),"TE1_SITUA"))) == "9" .or. ;
			alltrim(upper(Posicione("TE1",1,xFilial('TE1') + oMdl:GetValue('TFO_ITCOD'),"TE1_SITUA"))) == "A"
			lRet := .F.
			Help( ,,,STR0076,STR0077, 1, 0 ) //"Colete Descartado ou Desativado" //"O colete escolhido tem situação igual a Desativado ou Descartado"
		EndIf
	EndIf

Return lRet

//--------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} At880GtSld

Valida a quantidade de saldo de um local para movimentação
@param cCodPro, Código do produto
@param cEntida, Código da entidade	
@param cLocal,  Código do local origem

@since 18/10/2017
@version P12
@return nSaldo,Número com o saldo disponível no local para movimentação

/*/
//--------------------------------------------------------------------------------------------------------------------
Function At880GtSld(cCodPro, cEntida, cLocal)
	Local cQuery   := ""
	Local cTemp    := ""
	Local lMultFil := TFQ->(ColumnPos("TFQ_FILORI")) .And. TFQ->(ColumnPos("TFQ_FILDES")) .And. TecMtFlArm() .And. !isBlind()
	Local nOrdem   := 1
	Local nSaldo   := 0
	Local oMdl     := FWModelActive()
	Local oQuery   := NIL

	cQuery := " SELECT TFP_SALDO"
	cQuery += " FROM ? TFP"	
	cQuery += " WHERE TFP.TFP_FILIAL = ?"
	cQuery +=       " AND TFP.TFP_PRODUT = ?"
	If cEntida == '1'
		cQuery +=       " AND TFP.TFP_CODINT = ?"
		cQuery +=       " AND TFP.TFP_MOVIM = ?"
	ElseIf cEntida == '2'
		cQuery +=       " AND TFP.TFP_CODLOC = ?"
		cQuery +=       " AND TFP.TFP_MOVIM = ?"
	EndIf
	If lMultFil
		cQuery +=       " AND TFP.TFP_FILLOC = ?"
	EndIf
	cQuery +=       " AND TFP.D_E_L_E_T_ = ' ' "
	
	oQuery := FwExecStatement():New( cQuery )
	oQuery:SetUnsafe(nOrdem++, RetSQLName("TFP"))
	oQuery:SetString(nOrdem++, xFilial("TFP"))
	oQuery:SetString(nOrdem++, cCodPro)
	oQuery:SetString(nOrdem++, cLocal)
	oQuery:SetString(nOrdem++, cEntida)
	If lMultFil
		oQuery:SetString(nOrdem++, oMdl:GetValue("TFQMASTER","TFQ_FILORI") )
	EndIf

	cTemp := oQuery:OpenAlias()
	oQuery:Destroy()
	FwFreeObj(oQuery)

	nSaldo := ( cTemp )->( TFP_SALDO ) 
	
	(cTemp)->(DbCloseArea())
	
Return nSaldo 

//--------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} At880VldQt

Valida a quantidade da munição

@since 18/10/2017
@version P12
@return Nil
/*/
//--------------------------------------------------------------------------------------------------------------------
Function At880VldQt(oModel) 
Local lRet := .T.
Local oTFQMaster := oModel:GetModel('TFQMASTER')
Local oTFODetail := oModel:GetModel('TFOMUNI')
Local nQtd 		:= oTFODetail:GetValue('TFO_QTDE')
Local cCodPro	:=	 oTFODetail:GetValue('TFO_PRODUT')
Local cEntida	:= oTFQMaster:GetValue('TFQ_ENTORI')
Local cLocal	:= oTFQMaster:GetValue('TFQ_ORIGEM')

If !Empty(cEntida) .And. !Empty(cLocal) .And. !Empty(cCodPro)
	lRet := At880GtSld(cCodPro,cEntida,cLocal) >= nQtd
EndIf	  

If !lRet
	Help( ,, "At880Qtd",, STR0081 + Alltrim(cCodPro) + STR0082, 1, 0 ) //"Saldo do produto "###" indisponível para movimentação"
EndIf

Return lRet


//--------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} At880VldTp

Valida o tipo de movimentação

@since 18/10/2017
@version P12
@return Nil
/*/
//--------------------------------------------------------------------------------------------------------------------
Function At880VldTp()
Local oModel 		:= FwModelActive()
Local oTFQMaster 	:= oModel:GetModel('TFQMASTER')
Local oTFODetail 	:= oModel:GetModel('TFOMUNI')
Local lRet 			:= .T.
Local aRows 		:= FwSaveRows()
Local nI    		:= 0

If oTFQMaster:GetValue('TFQ_MOTIVO') == mtMANUTENCAO
	If !oTFODetail:IsEmpty()
		For nI := 1 To oTFODetail:Length()
			oTFODetail:GoLine(nI)
			oTFODetail:DeleteLine()
		Next nI 
		
	EndIf
	
	oTFODetail:SetNoDeleteLine(.T.)
	oTFODetail:SetNoInsertLine(.T.)
	oTFODetail:SetNoUpdateLine(.T.)
Else
	oTFODetail:SetNoDeleteLine(.F.)
	oTFODetail:SetNoInsertLine(.F.)
	oTFODetail:SetNoUpdateLine(.F.)
EndIf

FwRestRows( aRows )

Return lRet

//--------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} At800RIm

Reimpressão de protocolo de recebimento de arma

@since 18/10/2017
@version P12
@return Nil
/*/
//--------------------------------------------------------------------------------------------------------------------
Static Function At800RIm(oModel, oView)
Local oMdlAux := NIL
Local aFolder :=  {{STR0090, "TFOARMA" }, {STR0091, "TFOMUNI"}, {STR0092, "TFOCOLE"}} //"Armas"##"Munição"##"Coletes"
Local nPos := 0
Local aFldSel := {}
Local cCampoGet := "TFO_ITCOD"
local nQtde := 0
	
If (FwFldGet("TFQ_STATUS") == stEFETIVADA .And. FwFldGet("TFQ_ENTDES") == edCLIENTE) .OR.;
	FwFldGet("TFQ_STATUS") == stAGENDADA
	
	aFldSel :=  oView:GetFolderActive("ABAS", 2)
	
	If Len(aFldSel) >= 2 .AND. !Empty(aFldSel[2])
		nPos := aScan(aFolder,  {|l| l[1] == aFldSel[2]})
	EndIf

	If nPos > 0
		oMdlAux := oModel:GetModel(aFolder[nPos, 2])
		If !oMdlAux:IsEmpty() .AND. !oMdlAux:IsDeleted() 
			If aFolder[nPos, 2] == "TFOMUNI" 
				cCampoGet := "TFO_PRODUT"
				nQtde := oMdlAux:GetValue("TFO_QTDE")
			EndIf
								
			If !Empty(oMdlAux:getValue(cCampoGet))
				ExecBlock("Tec880ImpProt", .F., .F., {FwFldGet("TFQ_CODIGO"),oMdlAux:GetValue("TFO_ITMOV"),oMdlAux:GetValue(cCampoGet),FwFldGet("TFQ_DRESP"),nQtde,FwFldGet("TFQ_DDESTI")})
			EndIf
			
		EndIf
	Else
		Help( ,, "At800ImpPr",, STR0094, 1, 0 ) //"Para reimpressão de protocolo que selecione um item do grid de Armas, Coletes ou Munição"
	EndIf

Else
	Help( ,, "At800ImpPr",, STR0095, 1, 0 ) //"Movimentação não permite reimpressao de protocolo"
EndIf

Return



//--------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} At880ImpPr

Impressão de protocolo de recebimento de arma

@since 18/10/2017
@version P12
@return Nil
/*/
//--------------------------------------------------------------------------------------------------------------------
Static Function At880ImpPr(oMdl)

Local oMdlAux 	:= NIL //Models das armas
Local cCampoGet := "TFO_ITCOD" //Campo do Codigo do armamento/prod. munição
Local aModels 	:= {"TFOARMA", "TFOMUNI", "TFOCOLE"} //Models das armas
Local nI 		:= 0 //Contador de Linhas do Grid
Local nC 		:= 0 //Contador de Models
Local nQtde 	:= 0 //Quantidade
Local lProtocolo := ExistBlock("Tec880ImpProt") //RdMake de Protocolo Impresso


If lProtocolo .AND. ;
	((FwFldGet("TFQ_STATUS") == stEFETIVADA .And. FwFldGet("TFQ_ENTDES") == edCLIENTE) .OR.;
	(FwFldGet("TFQ_STATUS") == stAGENDADA .AND. MsgYesNo(STR0011)) )	//"Deseja Imprimir o Protocolo de Entrega?"
	
	For nC := 1 to len(aModels)
		oMdlAux := oMdl:GetModel(aModels[nC])
		cCampoGet := "TFO_ITCOD"
		nQtde := 0
	
		If aModels[nC] == "TFOMUNI"
			cCampoGet := "TFO_PRODUT"		
		EndIf
		// Instancia Grid Armas/Coletes ou Munições			
		oMdlAux	:= oMdl:GetModel(aModels[nC])
		If	! oMdlAux:IsEmpty()
			For nI := 1 To oMdlAux:Length()
				oMdlAux:GoLine(nI)
				If aModels[nC] == "TFOMUNI"
					nQtde := oMdlAux:GetValue("TFO_QTDE")
				EndIf
				If !oMdlAux:IsDeleted() .AND. !Empty(oMdlAux:GetValue(cCampoGet))
					ExecBlock("Tec880ImpProt", .F., .F., {FwFldGet("TFQ_CODIGO"),oMdlAux:GetValue("TFO_ITMOV"),oMdlAux:GetValue(cCampoGet),FwFldGet("TFQ_DRESP"),nQtde,FwFldGet("TFQ_DDESTI")})
				EndIf
			Next nI
		EndIf
	
	Next nC

EndIf

Return 

//------------------------------------------------------------------------------
/*/{Protheus.doc} PrelinTFQ

Função de Prevalidacao dos fields de alocação TFQ

@author Vitor kwon
@since 03/02/2023
/*/
//------------------------------------------------------------------------------

Function PrelinTFQ(oMdlTFQ, cAction, cField, xValue)

	Local lRet		:= .T.

	If VALTYPE(oMdlTFQ) == 'O' .AND. oMdlTFQ:GetId() == "TFQMASTER"

		If cAction == "SETVALUE"
			If cField $ "|TFQ_CONTRT|"  
				iF Empty(xValue) .or. (oMdlTFQ:GetValue("TFQ_CONTRT") <> xValue)
					oMdlTFQ:LoadValue("TFQ_ORIGEM", "")
					oMdlTFQ:LoadValue("TFQ_DESTIN", "")
					oMdlTFQ:LoadValue("TFQ_DDESTI", "")
					oMdlTFQ:LoadValue("TFQ_DSCLOC", "")
					oMdlTFQ:LoadValue("TFQ_RESTRA", "")
					oMdlTFQ:LoadValue("TFQ_ENTORI", "")
					oMdlTFQ:LoadValue("TFQ_MOTIVO", "")
					oMdlTFQ:LoadValue("TFQ_ENTDES", "")
					oMdlTFQ:LoadValue("TFQ_STATUS", "")
					oMdlTFQ:LoadValue("TFQ_DRESP", "")
					oMdlTFQ:LoadValue("TFQ_JUSTIF", "")
				Endif	
			Endif
			If cField $ "|TFQ_MOTIVO|"  
				iF Empty(xValue) .or. (oMdlTFQ:GetValue("TFQ_MOTIVO") <> xValue) 
					oMdlTFQ:LoadValue("TFQ_ORIGEM", "")
					oMdlTFQ:LoadValue("TFQ_DESTIN", "")
					oMdlTFQ:LoadValue("TFQ_DDESTI", "")
					oMdlTFQ:LoadValue("TFQ_DSCLOC", "")
					oMdlTFQ:LoadValue("TFQ_RESTRA", "")
					oMdlTFQ:LoadValue("TFQ_ENTORI", "")
					oMdlTFQ:LoadValue("TFQ_ENTDES", "")
					oMdlTFQ:LoadValue("TFQ_STATUS", "")
					oMdlTFQ:LoadValue("TFQ_DRESP", "")
					oMdlTFQ:LoadValue("TFQ_JUSTIF", "")
				Endif
				// Se for Implantação ('1') e não houver contrato, força Entidade de Destino para Empresa ('2')
				If xValue == '1' .And. Empty(oMdlTFQ:GetValue("TFQ_CONTRT"))
					oMdlTFQ:LoadValue("TFQ_ENTDES", '2')
				EndIf
			Endif
			If cField $ "|TFQ_DESTIN|TFQ_ORIGEM|" .And. _lGsOrcArm
				If cField $ "|TFQ_DESTIN|"
					If !Empty(xValue)
						lRet := vldLocal(oMdlTFQ, xValue, "TFQ_DESTIN", FwFldGet("TFQ_ENTDES"))
					Endif
				Endif
				If cField $ "|TFQ_ORIGEM|"
					If !Empty(xValue)
						lRet := vldLocal(oMdlTFQ, xValue, "TFQ_ORIGEM", FwFldGet("TFQ_ENTORI"))			
					Endif
				EndIf
				If !lRet
					Help(" ", 1, "PrelinTFQ", Nil, STR0099, 1) //"Este local nao pertence a este contrato. Verifique o numero do contrato"
				EndIf
			EndIf
		Endif
	Endif

Return lRet

//--------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} TC880EST
	Estorna movimentações canceladas/efetivadas
	@author Roberto Santiago
	@since 06/08/2024
	@return
/*/
//--------------------------------------------------------------------------------------------------------------------
Function TC880EST()

	FWMsgRun(Nil, {|| T880EProc()}, "Aguarde...", "Estornando movimentação...")

Return Nil

//--------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} T880EProc
	Estorna movimentações canceladas/efetivadas
	@author Roberto Santiago
	@since 06/08/2024
	@return
/*/
//--------------------------------------------------------------------------------------------------------------------
Static Function T880EProc()

	Local cTabArma     := "TE0"
	Local cTabColete   := "TE1"
	Local cTabMunicao  := "TE2"
	Local cCodigo      := TFQ->TFQ_CODIGO
	Local aCdArmamento := Array(0)
	Local nArmamento   := 0
	Local cTabela      := ""
	Local aUltDados    := Array(0)
	Local aCurDados    := Array(0)
	Local nSaldo       := 0

	Begin Transaction
		DBSelectArea("TFO")
		TFO->(DBGoTop())
		While TFO->(!EoF())
			If TFO->TFO_CDMOV == cCodigo
				aAdd(aCdArmamento,;
						{;
							cCodigo,;
							TFO->TFO_ITCOD,;
							IIF(TFO->TFO_ITMOV == "1", cTabArma, IIF(TFO->TFO_ITMOV == "2", cTabColete, cTabMunicao)),;
							TFQ->TFQ_MOTIVO,;
							TFO->TFO_CODTXQ,;
							IIF(TFO->TFO_QTDE == 0, 1, TFO->TFO_QTDE);
						})
				RecLock("TFO", .F.)
					TFO->(DBDelete())
				TFO->(MsUnlock())
			EndIf
			TFO->(DBSkip())
		EndDo

		DBSelectArea("TFR")
		TFR->(DBGoTop())
		While TFR->(!EoF())
			If TFR->TFR_CODMOV == cCodigo
				RecLock("TFR", .F.)
					TFR->(DBDelete())
				TFR->(MsUnlock())
			EndIf
			TFR->(DBSkip())
		EndDo

		DBSelectArea("TIO")
		TIO->(DBGoTop())
		While TIO->(!EoF())
			If TIO->TIO_CODMOV == cCodigo
				RecLock("TIO", .F.)
					TIO->(DBDelete())
				TIO->(MsUnlock())
			EndIf
			TIO->(DBSkip())
		EndDo

		For nArmamento := 1 To Len(aCdArmamento)
			cTabela := aCdArmamento[nArmamento][3]

			DBSelectArea("TXQ")
			TXQ->(DBSetOrder(1)) //TXQ_FILIAL+TXQ_CODIGO
			If TXQ->(DBSeek(xFilial("TXQ") + aCdArmamento[nArmamento][5]))
				RecLock("TXQ", .F.)
					TXQ->TXQ_QTDAPO := (TXQ->TXQ_QTDAPO - aCdArmamento[nArmamento][6])
				TXQ->(MsUnlock())
			EndIf

			DBSelectArea(cTabela)	
			(cTabela)->(DBSetOrder(1))
			(cTabela)->(DBSeek(xFilial() + aCdArmamento[nArmamento][2]))
			If cTabela $ "TE0.TE1"
				RecLock(cTabela, .F.)
					(cTabela)->&(cTabela + "_SITUA")  := "1" //disponivel para movimentação
					(cTabela)->&(cTabela + "_LOCAL")  := TFQ->TFQ_ORIGEM
					(cTabela)->&(cTabela + "_CLIDES") := AT880INIDSCLOC(TFQ->TFQ_ENTORI,TFQ->TFQ_ORIGEM)
					(cTabela)->&(cTabela + "_FILLOC") := TFQ->TFQ_FILORI
					(cTabela)->&(cTabela + "_ENTIDA") := "TER"
					(cTabela)->&(cTabela + "_CODMOV") := ""
				(cTabela)->(MsUnlock())
			ElseIf cTabela == "TE2"

				aUltDados := GLstRecTFP(aCdArmamento[nArmamento][2],cCodigo)
				//Deleta linha da TFP que está sendo estornada
				If Len(aUltDados) == 2
					DBSelectArea("TFP")
					TFP->(DBGoTo(aUltDados[2]))
					nSaldo := aUltDados[1]
					RecLock("TFP", .F.)
						TFP->(DBDelete())
					TFP->(MsUnlock())

					//Atualiza saldo da TFP anterior
					aCurDados := GLstRecTFP(aCdArmamento[nArmamento][2])
					If Len(aCurDados) == 2
						TFP->(DBGoTo(aCurDados[2]))
						RecLock("TFP", .F.)
							TFP->TFP_SALDO += aUltDados[1]
						TFP->(MsUnlock())
					EndIf
					
				EndIf
			EndIf

			// >>> Exclusão da Manutenção do TECA780
			DBSelectArea("TEU")
			TEU->(DBSetOrder(1)) 
			While !TEU->(EoF())
			    If AllTrim(TEU->TEU_ORIGEM) == "TECA880" .AND. ACDARMAMENTO[1][2] == TEU->TEU_CDARM  // Comparação da arma para exclusão.
			        RecLock("TEU", .F.)
			            TEU->(DBDelete())
			        TEU->(MsUnlock())
			    EndIf
			    TEU->(DbSkip())
			EndDo

		Next nArmamento

		RecLock("TFQ", .F.)
			TFQ->(DBDelete())
		TFQ->(MsUnlock())
	End Transaction

Return Nil

//--------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} GLstRecTFP
	Retorna saldo das movimentações de munições
	@param cCdArmamento, código do armamento
	@param cCodMovim, código da movimentação (opcional)
	@author Roberto Santiago
	@since 06/08/2024
	@return
/*/
//--------------------------------------------------------------------------------------------------------------------
Static Function GLstRecTFP(cCdArmamento, cCodMovim)

	Local aLastDados := Array(0)
	Local cAliasTFP  := ""
	Local cQueryTFP  := ""
	Local oQuery     := Nil

	Default cCodMovim := ""

	cQueryTFP := " SELECT TFP.TFP_SALDO,"
	cQueryTFP +=        " TFP.R_E_C_N_O_ RECNO"
	cQueryTFP += " FROM ?"
	cQueryTFP += " WHERE 1 = 1"
	cQueryTFP +=       " AND ?"
	cQueryTFP +=       " AND TFP.TFP_CODMUN = ?"
	cQueryTFP +=       " AND TFP.TFP_CODMOV = ?"
	
	cQueryTFP += " ORDER BY TFP.TFP_CODIGO DESC"

	oQuery := FwExecStatement():New(cQueryTFP)
	oQuery:SetUnsafe(1, RetSQLTab("TFP"))
	oQuery:SetUnsafe(2, RetSQLCond("TFP"))
	oQuery:SetString(3, cCdArmamento)
	oQuery:SetString(4, cCodMovim)

	cAliasTFP := oQuery:OpenAlias()

	(cAliasTFP)->(DBGoTop())

	If (cAliasTFP)->(!EoF())
		aLastDados := {(cAliasTFP)->TFP_SALDO , (cAliasTFP)->RECNO}
	EndIf

	(cAliasTFP)->(DBCloseArea())
	oQuery:Destroy()
	FwFreeObj(oQuery)

Return aLastDados

//--------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} At880Clear

Limpa o grid de armamento ao mudar a origem da movimentação
@author jack junior
@since 07/10/2024
@Param 
@return	
/*/
//--------------------------------------------------------------------------------------------------------------------
Function At880Clear()
Local oModel	:= FwModelActive()
Local oMdlArma	:= oModel:GetModel('TFOARMA')
Local oMdlColete:= oModel:GetModel('TFOCOLE')
Local oMdlMuni	:= oModel:GetModel('TFOMUNI')
Local oView 	:= FwViewActive()

If oModel:GetOperation() == MODEL_OPERATION_INSERT
	If oMdlArma:CanClearData()
		oMdlArma:ClearData(.T.,.T.)
		oView:Refresh( "VIEW_GRID_TFOA" )
	EndIf
	If oMdlColete:CanClearData()
		oMdlColete:ClearData(.T.,.T.)
		oView:Refresh( "VIEW_GRID_TFOM" )
	EndIf
	If oMdlMuni:CanClearData()
		oMdlMuni:ClearData(.T.,.T.)
		oView:Refresh( "VIEW_GRID_TFOC" )
	EndIf
EndIf

Return

//--------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} At880Mot

TRIGGER Controla WHEN do campo TFQ_ENTORI
@author Roberto Santiago
@since 02/01/2025
@Param cMotivo - Motivo da Movimentação (TFQ)
	   cCampo - 'TFQ_MOVIVO
@return	TFQ_ENTORI
/*/
//--------------------------------------------------------------------------------------------------------------------
Function At880Mot(cMotivo) as character
Return IIF(cMotivo == '1', '1', IIF(cMotivo == '5', '2', ''))

//--------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} At880Posto

Controla WHEN do campo TFQ_POSTO
@author Breno.gomes
@since 27/03/2025
@return	.T. / .F.
/*/
//--------------------------------------------------------------------------------------------------------------------
Function At880Posto() as logical
return (!EMPTY(FwFldGet("TFQ_CONTRT")) .And. (!EMPTY(FwFldGet("TFQ_ORIGEM")) .Or. !EMPTY(FwFldGet("TFQ_DESTIN"))))

/*/{Protheus.doc} At880VlTFF
Validação TFQ_POSTO
	Valida Posto
	Criado para validar inclusões em vigências futuras com a permissão 076
@author felipe.mcamargo
@since 10/29/2025
@return lRet permite/não permite
/*/
Function At880VlTFF()
	Local cAlias  := ''
	Local cConRev := FwFldGet( 'TFQ_CONREV' )
	Local cContra := FwFldGet( 'TFQ_CONTRT' )
	Local cPosto  := FwFldGet( 'TFQ_POSTO' )
	Local cFilDes := FwFldGet( 'TFQ_FILDES' )
	Local cQuery  := ''
	Local lRet    := .T.
	Local nNum    := 1
	Local oExec   := Nil
	
	If !At680Perm( Nil, __cUserId, "076" ) .and. !Empty( cPosto ) // "Armamentos: Permite movimentação em vigência futura?"
		cQuery := "SELECT TFF.TFF_PERINI "
		cQuery += "FROM ? TFF "
		cQuery += "WHERE TFF.TFF_FILIAL = ? "
		cQuery +=     "AND TFF.TFF_CONTRT = ? "
		cQuery +=     "AND TFF.TFF_CONREV = ? "
		cQuery +=     "AND TFF.TFF_COD = ? "
		cQuery +=     "AND TFF.D_E_L_E_T_ = ' ' "

		cQuery := ChangeQuery(cQuery)
		oExec  := FwExecStatement():New(cQuery)

		oExec:SetUnsafe( nNum++, RetSQLName("TFF") )
		oExec:SetString( nNum++, cFilDes )
		oExec:SetString( nNum++, cContra )
		oExec:SetString( nNum++, cConRev )
		oExec:SetString( nNum++, cPosto )

		cAlias := oExec:OpenAlias()
		oExec:Destroy()
		FwFreeObj(oExec)

		If !(cAlias)->(Eof()) .and. (cAlias)->TFF_PERINI > DToS(dDataBase)
			Help( ,, "At880VlTFF",, STR0107, 1, 0 ) // "Usuário não possui permisão para movimentar armas em postos com vigência futura."
			lRet := .F.
		EndIf

		(cAlias)->(DbCloseArea())
	EndIf

Return lRet

/*/{Protheus.doc} At880VlTFL
Validação TFQ_DESTIN
	Valida Local de Atendimento
	Criado para validar inclusões em vigências futuras com a permissão 076
@author felipe.mcamargo
@since 10/29/2025
@return lRet permite/não permite
/*/
Function At880VlTFL()
	Local cAlias  := ''
	Local cConRev := ''
	Local cContra := ''
	Local cFilDes := ''
	Local cQuery  := ''
	Local lRet    := .T.
	Local nNum    := 1
	Local oExec   := Nil
	Local oMdl    := FWModelActive()
	Local oMdlTFQ := oMdl:GetModel('TFQMASTER')
	Local cLocal  := oMdlTFQ:GetValue( 'TFQ_DESTIN' )

	lRet := At880VldEnt() .and. At880VldLoc() // validação original de existência e destino diferente do fim

	// Verifica a seguinte permisão => "Armamentos: Permite movimentação em vigência futura?"
	If lRet .and. !At680Perm( Nil, __cUserId, "076" ) .and. !Empty( cLocal )
		cContra := oMdlTFQ:GetValue( 'TFQ_CONTRT' )
		cConRev := oMdlTFQ:GetValue( 'TFQ_CONREV' )
		cFilDes := oMdlTFQ:GetValue( 'TFQ_FILDES' )

		cQuery := "SELECT TFL.TFL_DTINI "
		cQuery += "FROM ? TFL "
		cQuery += "WHERE TFL.TFL_FILIAL = ? "
		cQuery +=     "AND TFL.TFL_CONTRT = ? "
		cQuery +=     "AND TFL.TFL_CONREV = ? "
		cQuery +=     "AND TFL.TFL_LOCAL = ? "
		cQuery +=     "AND TFL.D_E_L_E_T_ = ' ' "

		cQuery := ChangeQuery(cQuery)
		oExec  := FwExecStatement():New(cQuery)

		oExec:SetUnsafe( nNum++, RetSQLName("TFL") )
		oExec:SetString( nNum++, cFilDes )
		oExec:SetString( nNum++, cContra )
		oExec:SetString( nNum++, cConRev )
		oExec:SetString( nNum++, cLocal )

		cAlias := oExec:OpenAlias()
		oExec:Destroy()
		FwFreeObj(oExec)

		If !(cAlias)->(Eof()) .and. SToD( (cAlias)->TFL_DTINI ) > dDataBase
			Help( ,, "At880VlTFL",, STR0107, 1, 0 ) // "Usuário não possui permisão para movimentar armas em postos com vigência futura."
			lRet := .F.
		EndIf
	EndIf

Return lRet

//--------------------------------------------------------------------------------
/*/{Protheus.doc} At880F3Arma
Faz a Consulta Específica da Rotina

@param cTipo, Tipo da Consulta: "ARMA"; 
								"COLETE";
								"MUNI"; 
								"CONTRLOCAL"; 
								"TXQARM";
								"TXQCOL";
								"TXQMUN";

@param oModelTFQ, Modelo TFQ (cabeçalho da rotina)

@author Breno Gomes
@since 11/11/2025
/*/
//--------------------------------------------------------------------------------
Static Function At880F3Arma(cTipo, oModelTFQ)
	Local aArea       := GetArea()
	Local aColumns    := {}
	Local aIndex      := {}
	Local aSeek       := {}
	Local cCampoReg   := ""
	Local cDescArm    := ""
	Local cDescricao  := ""
	Local cEntDest    := oModelTFQ:GetValue("TFQ_ENTDES")
	Local cEntOri     := oModelTFQ:GetValue("TFQ_ENTORI")
	Local cItMov      := ""
	Local cMotivo     := ""
	Local cQry        := ""
	Local cStatus     := ""
	Local cTitle      := ""
	Local lMovCofre   := !Empty(FwFldGet("TFQ_CONTRT")) .And. cEntOri == "1" .And. cEntDest == "1" // Cofre x Cliente
	Local lMovContr   := !Empty(FwFldGet("TFQ_CONTRT")) .And. cEntOri == "2" .And. cEntDest == "2" // Cliente x Cofre
	Local lMovInterna := Empty(FwFldGet("TFQ_CONTRT")) .And. cEntOri == "1" .And. cEntDest == "2" // Cofre x Cofre:
	Local lOK         := .F.
	Local nPos        := 1
	Local oQry        := Nil

	// Não pode existir movimentação entre Contrato X Contrato (clientes)!
	If lMovInterna .Or. lMovCofre .Or. lMovContr .Or. cTipo $ "|CONTRLOCAL|"
		lOK := .T.

		// Faz a Query para a Consulta Específica:
		If cTipo $ "|ARMA|"

			cTitle     := STR0090 // "Armas"
			cDescricao := STR0108 // "Armamentos x Orçamento"
			cDescArm   := "Código da Arma"
			cCampoCod  := "TE0_COD"
			cCampoReg  := "TE0_NUMREG"

			Aadd( aSeek, { cTitle, {{"","C",TamSX3(cCampoCod)[1] ,0 ,cTitle ,,cCampoCod }} } ) // "Armas"

			oQry := qryArmCol(oModelTFQ, itARMA)
			cQry := oQry:GetFixQuery()

		ElseIf cTipo $ "|COLETE|"
		
			cTitle     := STR0092 // "Coletes"
			cDescricao := STR0110 // "Coletes x Orçamento"
			cDescArm   := "Cód. Colete"
			cCampoCod  := "TE1_CODCOL"
			cCampoReg  := "TE1_NUMSER"

			Aadd( aSeek, { cTitle, {{"","C",TamSX3(cCampoCod)[1] ,0 ,cTitle ,,cCampoCod }} } ) // "Coletes"

			oQry := qryArmCol(oModelTFQ, itCOLETE)
			cQry := oQry:GetFixQuery()

		ElseIf cTipo $ "|MUNI|"

			cTitle     := STR0091 //"Munições"
			cDescricao := STR0111 //"Munições x Orçamento"
			cDescArm   := "Cód. Munição"
			cCampoCod  := "TE2_CODMUN"

			Aadd( aSeek, { cTitle, {{"","C",TamSX3(cCampoCod)[1] ,0 ,cTitle ,,cCampoCod }} } ) // "Munições"

			oQry := qryMunicao(oModelTFQ)
			cQry := oQry:GetFixQuery()

		Elseif cTipo $ "|CONTRLOCAL|"

			cTitle     := STR0112 //"Local de Atendimento"
			cDescricao := STR0112 //"Local de Atendimento"
			cMotivo:= oModelTFQ:getValue("TFQ_MOTIVO")
			cStatus:= oModelTFQ:getValue("TFQ_STATUS")
			cCampoCod := "TFL_LOCAL"

			Aadd( aSeek, { STR0113, {{"","C",TamSX3(cCampoCod)[1] ,0 ,STR0113 ,,cCampoCod }} } ) //"Local"
			Aadd( aSeek, { STR0114, {{"","C",TamSX3("ABS_DESCRI")[1],0 ,STR0114 ,, "ABS_DESCRI"}} } ) //"Descrição"

			oQry := qryLocal(oModelTFQ)
			cQry := oQry:GetFixQuery()

		ElseIf cTipo $ "|TXQARM|TXQCOL|TXQMUN|"
			
			If cTipo $ "|TXQARM|"
				cTitle		:= STR0090 //"Armas"
				cDescricao	:= STR0108 //"Armamentos x Orçamento"
				cItMov 		:= itARMA
			ElseIf cTipo $ "|TXQCOL|"
				cTitle		:= STR0092 //"Coletes"
				cDescricao 	:= STR0110 //"Coletes x Orçamento"
				cItMov 		:= itCOLETE
			ElseIf cTipo $ "|TXQMUN|"
				cTitle		:= STR0091 //"Munições"
				cDescricao	:= STR0111 //"Munições x Orçamento"
				cItMov 		:= itMUNICAO
			EndIf
					
			cCampoCod := "TXQ_CODIGO"

			Aadd( aSeek, {cCampoCod,{{"","C",TamSX3(cCampoCod)[1],0,cCampoCod,,cCampoCod}}} ) // "TXQ_CODIGO"

			oQry := qryTXQ(oModelTFQ, cItMov)
			cQry := oQry:GetFixQuery()

		EndIf

		// Monta as Colunas da Consulta Específica:
		If (cTipo $ "|ARMA|MUNI|COLETE|")

			AAdd(aColumns,FWBrwColumn():New())
			aColumns[nPos]:SetData( &("{||" + cCampoCod + "}") )
			aColumns[nPos]:SetTitle(cDescArm) // "Código da Arma/Colete/Munição"
			aColumns[nPos]:SetSize(TamSX3(cCampoCod)[1])	
			nPos++

			AAdd(aColumns,FWBrwColumn():New())
			aColumns[nPos]:SetData( &("{|| B1_COD}") )
			aColumns[nPos]:SetTitle("Código do Produto") // "Código do Produto"
			aColumns[nPos]:SetSize(TamSX3("B1_COD")[1])	
			nPos++

			AAdd(aColumns,FWBrwColumn():New())
			aColumns[nPos]:SetData( &("{|| B1_DESC }") )
			aColumns[nPos]:SetTitle(STR0123) // "Descrição"
			aColumns[nPos]:SetSize(TamSX3("B1_DESC")[1])	
			nPos++

			If (cTipo $ "|ARMA|COLETE|") 
				AAdd(aColumns,FWBrwColumn():New())
				aColumns[nPos]:SetData( &("{|| "+ cCampoReg +" }") )
				aColumns[nPos]:SetTitle("Num. Registro") // "Num. Registro"
				aColumns[nPos]:SetSize(TamSX3(cCampoReg)[1])	
				nPos++
			EndIf
			If (cTipo $ "|MUNI|") 
				AAdd(aColumns,FWBrwColumn():New())
				aColumns[nPos]:SetData( &("{|| TFP_SALDO }") )
				aColumns[nPos]:SetTitle("Saldo") // " Saldo"
				aColumns[nPos]:SetSize(TamSX3("TFP_SALDO")[1])	
				nPos++
			EndIf

		ElseIf (cTipo $ "|CONTRLOCAL|")

			AAdd(aColumns,FWBrwColumn():New())
			aColumns[nPos]:SetData( &("{|| "+cCampoCod+" }") )
			aColumns[nPos]:SetTitle("Cód. Local") // "Cód. Local"
			aColumns[nPos]:SetSize(TamSX3(cCampoCod)[1])	
			nPos++

			AAdd(aColumns,FWBrwColumn():New())
			aColumns[nPos]:SetData( &("{|| ABS_DESCRI }") )
			aColumns[nPos]:SetTitle(STR0123) // "Descrição"
			aColumns[nPos]:SetSize(TamSX3("ABS_DESCRI")[1])	
			nPos++

			AAdd(aColumns,FWBrwColumn():New())
			aColumns[nPos]:SetData( &("{|| TFL_CODIGO }") )
			aColumns[nPos]:SetTitle("Cód. local orc") // "Cód. local orc"
			aColumns[nPos]:SetSize(TamSX3("TFL_CODIGO")[1])	
			nPos++

		ElseIf (cTipo $ "|TXQARM|TXQCOL|TXQMUN|")
			AAdd(aColumns,FWBrwColumn():New())
			aColumns[nPos]:SetData( &("{|| TXQ_CODIGO }") )
			aColumns[nPos]:SetTitle("Cod Arm Orc")
			aColumns[nPos]:SetSize(TamSX3("TXQ_CODIGO")[1])	
			nPos++

			AAdd(aColumns,FWBrwColumn():New())
			aColumns[nPos]:SetData( &("{|| TFF_COD }") )
			aColumns[nPos]:SetTitle(STR0125) // "Código Posto"
			aColumns[nPos]:SetSize(TamSX3("TFF_COD")[1])
			nPos++

			AAdd(aColumns,FWBrwColumn():New())
			aColumns[nPos]:SetData( &("{|| TXQ_QTDVEN }") )
			aColumns[nPos]:SetTitle("Qtd. Vendida") // "Qtd Vendida"
			aColumns[nPos]:SetSize(TamSX3("TXQ_QTDVEN")[1])
			nPos++

			AAdd(aColumns,FWBrwColumn():New())
			aColumns[nPos]:SetData( &("{|| TXQ_QTDAPO }") )
			aColumns[nPos]:SetTitle("Qtd. Apontada") // "Qtd Apontada"
			aColumns[nPos]:SetSize(TamSX3("TXQ_QTDAPO")[1])
			nPos++

		EndIf

		Aadd( aIndex, cCampoCod )

		// Constrói a DIALOG da Consulta Específica:
		lOk := at880ConF3(cTipo, cTitle, cDescricao, aColumns, cQry, aIndex, aSeek, cCampoCod)

		If ValType(oQry) == "O"
			oQry:Destroy()
			FwFreeObj(oQry)
		EndIf
	EndIf

	RestArea(aArea)

Return lOK

//--------------------------------------------------------------------
/*/{Protheus.doc} at880VlTXQ
	Validação do Código da TXQ informada na movimentação de Armas
	Validação da Quantidade Apontada de armamento
	  
@param		oModel, object, Objeto relativo a Armamento
			cType, String, Tipo do armamento:
					"1" - Arma
					"2" - Colete
					"3" - Munição

@sample		at880VlTXQ(oMdl,cType)
@return 	lRet,logico,Determina se o código da TXQ pode ser inserido.

@author 	jack.junior
@since 		06/03/2026
/*/
//--------------------------------------------------------------------
Function at880VlTXQ(oMdl,cType)

	Local oModelTFQ := oMdl:GetModel():GetModel("TFQMASTER")
	Local cItCod    := oMdl:GetValue( 'TFO_CODTXQ' )
    Local cFilTXQ   := ""
	Local lMovCofre := .F.
	Local lRet      := .T.
	Local nQtdApo   := 0
	Local nQtdVen   := 0
	Local nQtdMun	:= 0

	If !Empty(cItCod)
		// Valida se o código TXQ existe no local:
		lRet := vldTXQCod(oMdl, cItCod, cType)

		If lRet
            // Movimentação Cofre para Contrato:
            lMovCofre := !Empty(oModelTFQ:GetValue("TFQ_CONTRT")) .And. oModelTFQ:GetValue("TFQ_ENTORI") == eoLOCINTER .And. oModelTFQ:GetValue("TFQ_ENTDES") == edCLIENTE
			// Movimentação Contrato para Cofre
			lMovContr := !Empty(oModelTFQ:GetValue("TFQ_CONTRT")) .And. oModelTFQ:GetValue("TFQ_ENTORI") == eoLOCATEND .And. oModelTFQ:GetValue("TFQ_ENTDES") == edEMPRESA

			// Valida as quantidades apontadas: Apenas IMPLANTAÇÃO (Obs Reforço pode ir tranquilo e não muda a TXQ_QTDAPO para armas e coletes)
			If oModelTFQ:GetValue("TFQ_MOTIVO") == mtIMPLANTACAO .And. lMovCofre

                cFilTXQ := xFilial("TXQ", oModelTFQ:GetValue("TFQ_FILDES"))

				If lRet
                    // TXQ_FILIAL+TXQ_CODIGO
					nQtdVen := Posicione("TXQ", 1, cFilTXQ+cItCod, "TXQ_QTDVEN")
					nQtdApo := Posicione("TXQ", 1, cFilTXQ+cItCod, "TXQ_QTDAPO")

					If cType == itMUNICAO
						nQtdMun := oMdl:GetValue("TFO_QTDE")
						If nQtdVen <= nQtdApo .Or. (nQtdApo+nQtdMun > nQtdVen)
							lRet := .F.
							oMdl:GetModel():SetErrorMessage(oMdl:GetId(),"TFO_CODTXQ",oMdl:GetModel():GetId(),"TFO_CODTXQ",'at880VlTXQ',; 
												STR0119+CRLF+;	// "Essa TXQ atingiu ou exedeu o limite de armamentos apontados. "
												STR0120+cValtoChar(nQtdVen)+CRLF+;	// "Quantidade de armamentos vendidos: "
												STR0121+cValtoChar(nQtdApo)+CRLF+CRLF+; // "Quantidade de armamentos apontados: "
												"Essa TXQ aceita implantar até "+cValToChar(nQtdVen-nQtdApo)+" munições.", "" ) // "Essa TXQ aceita implantar até "+x+" munições."
						EndIf
					Else
						If nQtdVen <= nQtdApo
							lRet := .F.
							oMdl:GetModel():SetErrorMessage(oMdl:GetId(),"TFO_CODTXQ",oMdl:GetModel():GetId(),"TFO_CODTXQ",'at880VlTXQ',; 
												STR0119+CRLF+;	// "Essa TXQ atingiu ou exedeu o limite de armamentos apontados. "
												STR0120+cValtoChar(nQtdVen)+CRLF+;	// "Quantidade de armamentos vendidos: "
												STR0121+cValtoChar(nQtdApo), "" )	// "Quantidade de armamentos apontados: "
						EndIf
					EndIf
				EndIf
			EndIf

			If lMovContr .And. ;
				cType == itMUNICAO .And. ;
				(oModelTFQ:GetValue("TFQ_MOTIVO") == mtDESCARTE .Or. ;
				oModelTFQ:GetValue("TFQ_MOTIVO") == mtENCERRAMENTO .Or. ;
				oModelTFQ:GetValue("TFQ_MOTIVO") == mtMANUTENCAO)

				cFilTXQ := xFilial("TXQ", oModelTFQ:GetValue("TFQ_FILORI"))

				// TXQ_FILIAL+TXQ_CODIGO
				nQtdVen := Posicione("TXQ", 1, cFilTXQ+cItCod, "TXQ_QTDVEN")
				nQtdApo := Posicione("TXQ", 1, cFilTXQ+cItCod, "TXQ_QTDAPO")
				nQtdMun := oMdl:GetValue("TFO_QTDE")

				If nQtdMun > nQtdApo
					lRet := .F.
					oMdl:GetModel():SetErrorMessage(oMdl:GetId(),"TFO_CODTXQ",oMdl:GetModel():GetId(),"TFO_CODTXQ",'at880VlTXQ',; 
										"O máximo a ser retornado dessa TXQ é: "+cValToChar(nQtdApo)+" quantidades.", "" ) // "O máximo a ser retornado dessa TXQ é: "+cValToChar(nQtdApo)
				EndIf
			EndIf
		Else
			oMdl:GetModel():SetErrorMessage(oMdl:GetId(),"TFO_CODTXQ",oMdl:GetModel():GetId(),"TFO_CODTXQ",'at880VlTXQ',; 
				STR0117, STR0118 ) // "Esse código de TXQ não pertence à nenhum Posto do Local de destino"##"Escolha um código de TXQ da consulta padrão (F3)."
		EndIf
	EndIf

Return lRet

//--------------------------------------------------------------------
/*/{Protheus.doc} at880VlCN9
	Verifica se o Contrato possui venda de armamento (tabela TXQ)
	  
@param		oModel, object, Objeto relativo a Armamento
			cContrato, string, numero do contrato
			cRevisao, string, numero da revisão do contrato

@sample		at880VlCN9(oModel, cContrato, cRevisao)
@return 	lRet, logico

@author 	jack.junior
@since 		13/03/2026
/*/
//--------------------------------------------------------------------
Function at880VlCN9(oModel, cContrato, cRevisao)
	Local cAliasTXQ := ""
	Local lRet      := .F.
	Local oQry      := Nil

	If !Empty(cContrato)
		cQry := " SELECT 1 "
		cQry += " FROM ? TXQ "
		cQry +=   " WHERE "
		cQry +=		" TXQ.TXQ_FILIAL = ? AND "
		cQry +=		" TXQ.TXQ_CONTRT = ? AND "
		cQry +=		" TXQ.TXQ_CONREV = ? AND "
		cQry +=		" TXQ.D_E_L_E_T_ = ' ' "

		cQry := ChangeQuery(cQry)
		oQry := FwExecStatement():New(cQry)
		oQry:SetUnsafe( 1, RetSqlName("TXQ") )
		oQry:SetString( 2, xFilial("TXQ") )
		oQry:SetString( 3, cContrato )
		oQry:SetString( 4, cRevisao )
			
		cAliasTXQ := oQry:OpenAlias()

		If !(cAliasTXQ)->(EOF()) 
			lRet := .T.
		EndIf

		oQry:Destroy()
		FwFreeObj(oQry)
	EndIf
Return lRet

//--------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} At880Commit

Realiza a gravação da movimentação e alteração de Status dos armamentos
@author Serviços
@since 28/08/13
@version P11 R9

@return lRet, Retorna .T. se houve sucesso
/*/
//--------------------------------------------------------------------------------------------------------------------
Static Function At880Commit(oMdl)
Local lRet := .T.

lRet := At880Cmt23(oMdl)

Return lRet

//--------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} at880GetTXQ

Gatilho da TXQ que a arma ou colete está implantada para o campo TFO_CODTXQ.
Apenas quando é movimentação saindo do CONTRATO.

@author jack.junior
@since 21/04/2026
@version P12.2510

@return lRet
/*/
//--------------------------------------------------------------------------------------------------------------------
Function at880GetTXQ(cEntOri, cEntDes, cContrato, cRevisao, cFilOri, cABSOri, cPosto, cItCod, cItMov)
	Local cAlias      := ""
	Local cAliasArm   := ""
	Local cCodigo     := ""
	Local cCodTXQ     := ""
	Local cPrefixo    := ""
	Local cQry        := ""
	Local lArmMultFil := .F.
	Local nOrdem      := 1
	Local oQry        := Nil

	// Não faz pra munição !
	If cItMov <> "3" 
		// Verifica se é retorno do contrato: Contrato -> Empresa (local interno)
		If cEntOri == "2" .And. cEntDes == "2" .And. !Empty(cContrato)
			If !Empty(cItCod)
				lArmMultFil := TecMtFlArm()

				If cItMov == "1" // Arma
					cAlias := "TE0" 
					cCodigo := "TE0.TE0_COD"
				ElseIf cItMov == "2" // Colete
					cAlias := "TE1" 
					cCodigo := "TE1.TE1_CODCOL"
				EndIf

				cPrefixo := cAlias+"."+cAlias

				If !Empty(cCodigo)

					cQry := " SELECT TFO.TFO_CODTXQ "
					cQry += " FROM ? "+cAlias+" "
					// Movimentações TFQ:
					cQry += " INNER JOIN ? TFQ ON "
					If !lArmMultFil
						cQry += 	" TFQ.TFQ_FILIAL = ? "
					Else
						cQry += 	" ? "
					EndIf
					cQry += 		" AND TFQ.TFQ_CODIGO = "+cPrefixo+"_CODMOV "
					cQry += 		" AND TFQ.TFQ_FILDES = "+cPrefixo+"_FILLOC "
					cQry += 		" AND TFQ.TFQ_DESTIN = "+cPrefixo+"_LOCAL "
					cQry += 		" AND TFQ.D_E_L_E_T_ = ' ' "
					// Itens da Movimentação TFO: TFO_FILIAL+TFO_CDMOV+TFO_ITMOV+TFO_ITCOD+TFO_CODIGO
					cQry += " INNER JOIN ? TFO ON  "
					If !lArmMultFil
						cQry += 	" TFO.TFO_FILIAL = ? "
					Else
						cQry += 	" ? "
					EndIf
					cQry += 		" AND TFO.TFO_CDMOV = TFQ.TFQ_CODIGO "
					cQry += 		" AND TFO.TFO_ITMOV = ? " // 1- Armas/ 2-Coletes/ 3-Munições
					cQry += 		" AND TFO.TFO_ITCOD = "+cCodigo+" "
					cQry += 		" AND TFO.D_E_L_E_T_ = ' ' "
					If !Empty(cPosto)
						cQry += " INNER JOIN ? TXQ ON "
						If !lArmMultFil
							cQry += " TXQ.TXQ_FILIAL = ? "
						Else
							cQry += " ? "
						EndIf
						cQry +=		" AND TXQ.TXQ_CODIGO = TFO.TFO_CODTXQ "
						cQry +=		" AND TXQ.D_E_L_E_T_ = ' ' "
						cQry +=		" INNER JOIN ? TFF ON "
						If !lArmMultFil
							cQry += " TFF.TFF_FILIAL = ? "
						Else
							cQry += " ? "
						EndIf
						cQry +=		" AND TFF.TFF_COD = TXQ.TXQ_CODTFF "
						cQry +=		" AND TFF.D_E_L_E_T_ = ' ' "
					EndIf
					cQry += " WHERE "
					If !lArmMultFil
						cQry +=	" "+cPrefixo+"_FILIAL = ? AND "
					EndIf
					cQry += 	" "+cPrefixo+"_FILLOC = ? "
					cQry += 	" AND "+cCodigo+" = ? "
					cQry += 	" AND "+cPrefixo+"_LOCAL = ? "
					cQry += 	" AND TFQ.TFQ_CONTRT = ? "
					cQry += 	" AND TFQ.TFQ_CONREV = ? "
					If !Empty(cPosto)
						cQry += " AND TFF.TFF_COD = ? "
					EndIf
					cQry += 	" AND "+cAlias+".D_E_L_E_T_ = ' ' "

					cQry := ChangeQuery( cQry )
					oQry := FwExecStatement():New(cQry)		

					oQry:SetUnsafe( nOrdem++, RetSqlName(cAlias) )
					oQry:SetUnsafe( nOrdem++, RetSqlName("TFQ") )
					If !lArmMultFil
						oQry:SetString( nOrdem++, xFilial("TFQ") )
					Else
						oQry:SetUnsafe( nOrdem++, FWJoinFilial(cAlias,"TFQ",cAlias,"TFQ",.T.))
					EndIf

					oQry:SetUnsafe( nOrdem++, RetSqlName("TFO") )
					If !lArmMultFil
						oQry:SetString( nOrdem++, xFilial("TFO") )
					Else
						oQry:SetUnsafe( nOrdem++, FWJoinFilial("TFQ","TFO","TFQ","TFO",.T.))
					EndIf					
					oQry:SetUnsafe( nOrdem++, cItMov )
					If !Empty(cPosto)
						oQry:SetUnsafe( nOrdem++, RetSqlName("TXQ") )
						If !lArmMultFil
							oQry:SetString( nOrdem++, xFilial("TXQ") )
						Else
							oQry:SetUnsafe( nOrdem++, FWJoinFilial("TFO","TXQ","TFO","TXQ",.T.))
						EndIf
						oQry:SetUnsafe( nOrdem++, RetSqlName("TFF") )
						If !lArmMultFil
							oQry:SetString( nOrdem++, xFilial("TFF") )
						Else
							oQry:SetUnsafe( nOrdem++, FWJoinFilial("TXQ","TFF","TXQ","TFF",.T.))
						EndIf
					EndIf
					// Where
					If !lArmMultFil
						oQry:SetString( nOrdem++, xFilial(cAlias) )
					EndIf
					oQry:SetString( nOrdem++, cFilOri )
					oQry:SetString( nOrdem++, cItCod )
					oQry:SetString( nOrdem++, cABSOri )
					oQry:SetString( nOrdem++, cContrato )
					oQry:SetString( nOrdem++, cRevisao )
					If !Empty(cPosto)
						oQry:SetString( nOrdem++, cPosto )
					EndIf
				
					cAliasArm := oQry:OpenAlias()
					If (cAliasArm)->(!EOF())
						cCodTXQ := (cAliasArm)->TFO_CODTXQ
					EndIf

					(cAliasArm)->(dbCloseArea())
					oQry:Destroy()
					oQry := Nil
				EndIf
			EndIf
		EndIf
	EndIf

Return cCodTXQ

//--------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} qryArmCol

Monta a query da Arma ou Colete, a depender do tipo da movimentação.
Essa função também é utilizada para validar caso o código seja digitado no campo.

@author jack.junior
@since 21/04/2026
@version P12.2510

@return lRet
/*/
//--------------------------------------------------------------------------------------------------------------------
Static Function qryArmCol(oModelTFQ, cItMov)
	Local cABSDes     := ""
	Local cABSOri     := ""
	Local cAlias      := ""
	Local cCodigo     := ""
	Local cCodigoTFL  := ""
	Local cContrato   := ""
	Local cEntDest    := ""
	Local cEntOri     := ""
	Local cFilDes     := ""
	Local cFilOri     := ""
	Local cPosto      := ""
	Local cPrefixo    := ""
	Local cQry        := ""
	Local cRevisao    := ""
	Local lArmMultFil := .F.
	Local lMovCofre   := .F.
	Local lMovContr   := .F.
	Local lMovInterna := .F.
	Local nOrdem      := 1
	Local oQry        := Nil

	If ValType(oModelTFQ) == "O" .And. oModelTFQ <> Nil
	
		If cItMov == itARMA
			cCodigo := "TE0.TE0_COD"
			cAlias  := "TE0"
		ElseIf cItMov == itCOLETE
			cCodigo := "TE1.TE1_CODCOL"
			cAlias  := "TE1"
		EndIf

		cPrefixo := cAlias+"."+cAlias

		// Coleta as informações necessárias do Modelo por referencia @:
		modelInfo(oModelTFQ, @cContrato, @cRevisao, @cPosto, @cEntOri, @cFilOri, @cABSOri, @cEntDest, @cFilDes, @cABSDes, @lMovInterna, @lMovCofre, @lMovContr, @lArmMultFil, @cCodigoTFL)
		
		If lMovInterna

			cQry := "SELECT "+cCodigo+", SB1.B1_COD, SB1.B1_DESC"
			If cItMov == itARMA
				cQry += " , TE0.TE0_NUMREG "
			ElseIf cItMov == itCOLETE
				cQry += " , TE1.TE1_NUMSER "
			EndIf
			// Armas
			cQry += " FROM ? "+cAlias+" "
			// Produtos
			cQry += " INNER JOIN ? SB1 ON "
			If !lArmMultFil
				cQry += " SB1.B1_FILIAL = ? "
			Else
				cQry += " ? "
			EndIf
			cQry +=     " AND SB1.B1_COD = "+cAlias+"_CODPRO "
			cQry +=     " AND SB1.D_E_L_E_T_ = ' ' "
			// Armas (Where)
			cQry +=   " WHERE "
			If !lArmMultFil
				cQry += " "+cPrefixo+"_FILIAL = ? AND "
			EndIf
			cQry += 	" "+cPrefixo+"_FILLOC = ? AND "
			cQry +=    " "+cPrefixo+"_LOCAL = ? AND "
			cQry +=    " "+cPrefixo+"_SITUA = '1' AND "    // 1=Ativa
			cQry +=    " "+cPrefixo+"_ENTIDA = 'TER' AND " // Cofre
			cQry +=    " "+cAlias+".D_E_L_E_T_ = ' ' "
			// Ordem por Codigo de Arma
			cQry += " ORDER BY "+cCodigo+" "

			cQry := ChangeQuery( cQry )
			oQry := FwExecStatement():New(cQry)		
			oQry:SetUnsafe( nOrdem++, RetSqlName(cAlias) )
			oQry:SetUnsafe( nOrdem++, RetSqlName("SB1") )
			If !lArmMultFil
				oQry:SetString( nOrdem++, xFilial("SB1") )
			Else
				oQry:SetUnsafe( nOrdem++, FWJoinFilial(cAlias,"SB1",cAlias,"SB1",.T.))
			EndIf
			If !lArmMultFil
				oQry:SetString( nOrdem++, xFilial(cAlias) )
			EndIf
			oQry:SetString( nOrdem++, cFilOri )
			oQry:SetString( nOrdem++, cABSOri )

		ElseIf lMovCofre

			cQry := "SELECT DISTINCT "+cCodigo+", SB1.B1_COD, SB1.B1_DESC "
			If cItMov == itARMA
				cQry += " , TE0.TE0_NUMREG "
			ElseIf cItMov == itCOLETE
				cQry += " , TE1.TE1_NUMSER "
			EndIf
			// Armas
			cQry += " FROM ? "+cAlias+" "
			// Produtos
			cQry += " INNER JOIN ? SB1 ON "
			If !lArmMultFil
				cQry += " SB1.B1_FILIAL = ? "
			Else
				cQry += " ? "
			EndIf
			cQry +=     " AND SB1.B1_COD = "+cPrefixo+"_CODPRO "
			cQry +=     " AND SB1.D_E_L_E_T_ = ' ' "
			// Armas (Where)
			cQry +=   " WHERE "
			If !lArmMultFil
				cQry += " "+cPrefixo+"_FILIAL = ? AND "
			EndIf
			cQry +=    " "+cPrefixo+"_FILLOC = ? AND "
			cQry +=    " "+cPrefixo+"_LOCAL = ? AND "
			cQry +=    " "+cPrefixo+"_SITUA = '1' AND "    // 1=Ativa
			cQry +=    " "+cPrefixo+"_ENTIDA = 'TER' AND " // Cofre
			cQry +=    " "+cAlias+".D_E_L_E_T_ = ' ' "
			// Verifica os itens vendidos TXQ:
			cQry += " AND EXISTS ( "
			cQry += 	" SELECT 1 "
			cQry += 	" FROM ? TFL "
			// Postos de Trabalho:
			cQry += 	" INNER JOIN ? TFF ON "
			If !lArmMultFil
				cQry += 	" TFF.TFF_FILIAL = ? "
			Else
				cQry += 	" ? "
			EndIf
			cQry +=         " AND TFF.TFF_CODPAI = TFL.TFL_CODIGO "
			cQry +=         " AND TFF.D_E_L_E_T_ = ' ' "
			// Armamentos - Armas:
			cQry += 	" INNER JOIN ? TXQ ON "
			If !lArmMultFil
				cQry += 	" TXQ.TXQ_FILIAL = ? "
			Else
				cQry += 	" ? "
			EndIf
			cQry +=         " AND TXQ.TXQ_CODTFF = TFF.TFF_COD"
			cQry +=         " AND TXQ.TXQ_CODPRD = "+cPrefixo+"_CODPRO "
			cQry +=         " AND TXQ.TXQ_ITEARM = "+cItMov+" " // 1 = Armas / 2 = Coletes
			cQry +=         " AND TXQ.D_E_L_E_T_ = ' ' "
			// Locais de Atendimento:
			cQry +=     " WHERE TFL.TFL_FILIAL = ? " 
			cQry +=     	" AND TFL.TFL_CODIGO = ? "
			cQry +=         " AND TFL.D_E_L_E_T_ = ' ' "
			If !Empty(cPosto)
				cQry +=     " AND TFF.TFF_COD = ? "
			EndIf
			cQry += " ) " // Fecha Exists
			// Ordem por Codigo de Arma
			cQry += " ORDER BY "+cCodigo+" "

			cQry := ChangeQuery( cQry )
			oQry := FwExecStatement():New(cQry)		
			oQry:SetUnsafe( nOrdem++, RetSqlName(cAlias) )
			oQry:SetUnsafe( nOrdem++, RetSqlName("SB1") )
			If !lArmMultFil
				oQry:SetString( nOrdem++, xFilial("SB1") )
			Else
				oQry:SetUnsafe( nOrdem++, FWJoinFilial(cAlias,"SB1",cAlias,"SB1",.T.))
			EndIf
			If !lArmMultFil
				oQry:SetString( nOrdem++, xFilial(cAlias) )
			EndIf
			oQry:SetString( nOrdem++, cFilOri )
			oQry:SetString( nOrdem++, cABSOri )
			oQry:SetUnsafe( nOrdem++, RetSqlName("TFL") )
			oQry:SetUnsafe( nOrdem++, RetSqlName("TFF") )
			If !lArmMultFil
				oQry:SetString( nOrdem++, xFilial("TFF") )
			Else
				oQry:SetUnsafe( nOrdem++, FWJoinFilial("TFL","TFF","TFL","TFF",.T.))
			EndIf
			oQry:SetUnsafe( nOrdem++, RetSqlName("TXQ") )
			If !lArmMultFil
				oQry:SetString( nOrdem++, xFilial("TXQ") )
			Else
				oQry:SetUnsafe( nOrdem++, FWJoinFilial("TFF","TXQ","TFF","TXQ",.T.))
			EndIf
			If !lArmMultFil
				oQry:SetString( nOrdem++, xFilial("TFL") )
			Else
				oQry:SetString( nOrdem++, cFilDes)
			EndIf
			oQry:SetString( nOrdem++, cCodigoTFL )
			If !Empty(cPosto)
				oQry:SetString( nOrdem++, cPosto )
			EndIf

		ElseIf lMovContr

			cQry := " SELECT DISTINCT "+cCodigo+", "
			cQry += 		" SB1.B1_COD, "
			cQry += 		" SB1.B1_DESC "
			If cItMov == itARMA
				cQry += " , TE0.TE0_NUMREG "
			ElseIf cItMov == itCOLETE
				cQry += " , TE1.TE1_NUMSER "
			EndIf
			cQry += " FROM ? "+cAlias+" "
			// Produtos:
			cQry += " INNER JOIN ? SB1 ON "
			If !lArmMultFil
				cQry += 	" SB1.B1_FILIAL = ? "
			Else
				cQry += 	" ? "
			EndIf
			cQry += 		" AND SB1.B1_COD = "+cPrefixo+"_CODPRO "
			cQry += 		" AND SB1.D_E_L_E_T_ = ' ' "
			// Itens da Movimentação TFO:
			cQry += " INNER JOIN ? TFO ON  "
			If !lArmMultFil
				cQry += 	" TFO.TFO_FILIAL = ? "
			Else
				cQry += 	" ? "
			EndIf
			cQry += 		" AND TFO.TFO_ITCOD = "+cCodigo+" "
			cQry += 		" AND TFO.TFO_CDMOV = "+cPrefixo+"_CODMOV "
			cQry += 		" AND TFO.TFO_ITMOV = "+cItMov+" " // 1= Arma / 2= Colete
			cQry += 		" AND TFO.D_E_L_E_T_ = ' ' "
			cQry += " INNER JOIN ? TXQ ON "
			If !lArmMultFil
				cQry += " TXQ.TXQ_FILIAL = ? "
			Else
				cQry += " ? "
			EndIf
			cQry +=		" AND TXQ.TXQ_CODIGO = TFO.TFO_CODTXQ "
			cQry +=		" AND TXQ.D_E_L_E_T_ = ' ' "
			cQry +=		" INNER JOIN ? TFF ON "
			If !lArmMultFil
				cQry += " TFF.TFF_FILIAL = ? "
			Else
				cQry += " ? "
			EndIf
			cQry +=		" AND TFF.TFF_COD = TXQ.TXQ_CODTFF "
			cQry +=		" AND TFF.D_E_L_E_T_ = ' ' "
			cQry +=		" INNER JOIN ? TFL ON "
			If !lArmMultFil
				cQry += " TFL.TFL_FILIAL = ? "
			Else
				cQry += " ? "
			EndIf
			cQry +=		" AND TFL.TFL_CODIGO = TFF.TFF_CODPAI "
			cQry +=		" AND TFL.D_E_L_E_T_ = ' ' "
			cQry += " WHERE "
			If !lArmMultFil
				cQry +=	" "+cPrefixo+"_FILIAL = ? AND "
			EndIf
			cQry += 	" "+cPrefixo+"_FILLOC = ? "
			cQry += 	" AND "+cPrefixo+"_LOCAL = ? "
			cQry += 	" AND "+cPrefixo+"_SITUA = '2' " // Implantada.
			cQry += 	" AND TFL.TFL_CODIGO = ? "
			If !Empty(cPosto)
				cQry += " AND TFF.TFF_COD = ? "
			EndIf
			cQry += 	" AND "+cAlias+".D_E_L_E_T_ = ' ' "
			cQry += " ORDER BY "+cCodigo+" "

			cQry := ChangeQuery( cQry )
			oQry := FwExecStatement():New(cQry)		
			// Armas:
			oQry:SetUnsafe( nOrdem++, RetSqlName(cAlias) )
			// Produtos:
			oQry:SetUnsafe( nOrdem++, RetSqlName("SB1") )
			If !lArmMultFil
				oQry:SetString( nOrdem++, xFilial("SB1") )
			Else
				oQry:SetUnsafe( nOrdem++, FWJoinFilial(cAlias,"SB1",cAlias,"SB1",.T.))
			EndIf
			// Itens da Movimentação TFO:
			oQry:SetUnsafe( nOrdem++, RetSqlName("TFO") )
			If !lArmMultFil
				oQry:SetString( nOrdem++, xFilial("TFO") )
			Else
				oQry:SetUnsafe( nOrdem++, FWJoinFilial(cAlias,"TFO",cAlias,"TFO",.T.))
			EndIf
			oQry:SetUnsafe( nOrdem++, RetSqlName("TXQ") )
			If !lArmMultFil
				oQry:SetString( nOrdem++, xFilial("TXQ") )
			Else
				oQry:SetUnsafe( nOrdem++, FWJoinFilial("TFO","TXQ","TFO","TXQ",.T.))
			EndIf
			oQry:SetUnsafe( nOrdem++, RetSqlName("TFF") )
			If !lArmMultFil
				oQry:SetString( nOrdem++, xFilial("TFF") )
			Else
				oQry:SetUnsafe( nOrdem++, FWJoinFilial("TXQ","TFF","TXQ","TFF",.T.))
			EndIf
			oQry:SetUnsafe( nOrdem++, RetSqlName("TFL") )
			If !lArmMultFil
				oQry:SetString( nOrdem++, xFilial("TFL") )
			Else
				oQry:SetUnsafe( nOrdem++, FWJoinFilial("TFF","TFL","TFF","TFL",.T.))
			EndIf
			// Where
			If !lArmMultFil
				oQry:SetString( nOrdem++, xFilial(cAlias) )
			EndIf
			oQry:SetString( nOrdem++, cFilOri )
			oQry:SetString( nOrdem++, cABSOri )
			oQry:SetString( nOrdem++, cCodigoTFL )
			If !Empty(cPosto)
				oQry:SetString( nOrdem++, cPosto )
			EndIf
		EndIf
	EndIf

Return oQry

//--------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} qryMunicao

Monta a query da Munição, a depender do tipo da movimentação.
Essa função também é utilizada para validar caso o código seja digitado no campo.

@author jack.junior
@since 21/04/2026
@version P12.2510

@return lRet
/*/
//--------------------------------------------------------------------------------------------------------------------
Static Function qryMunicao(oModelTFQ)
	Local cABSDes     := ""
	Local cABSOri     := ""
	Local cContrato   := ""
	Local cEntDest    := ""
	Local cEntOri     := ""
	Local cFilDes     := ""
	Local cFilOri     := ""
	Local cPosto      := ""
	Local cQry        := ""
	Local cRevisao    := ""
	Local lArmMultFil := .F.
	Local lMovCofre   := .F.
	Local lMovContr   := .F.
	Local lMovInterna := .F.
	Local nOrdem      := 1
	Local oQry        := Nil
	Local cCodigoTFL := ""

	If ValType(oModelTFQ) == "O" .And. oModelTFQ <> Nil

		// Coleta as informações necessárias do Modelo por referencia @:
		modelInfo(oModelTFQ, @cContrato, @cRevisao, @cPosto, @cEntOri, @cFilOri, @cABSOri, @cEntDest, @cFilDes, @cABSDes, @lMovInterna, @lMovCofre, @lMovContr, @lArmMultFil, @cCodigoTFL)

		If lMovInterna

			cQry := " SELECT DISTINCT TE2.TE2_CODMUN, TE2.TE2_CODPRO, SB1.B1_COD, SB1.B1_DESC, TFP.TFP_SALDO "
			// Munições:
			cQry += " FROM ? TE2 "
			// Produtos:
			cQry += " INNER JOIN ? SB1 ON "
			If !lArmMultFil
				cQry += 	" SB1.B1_FILIAL = ? "
			Else
				cQry += 	" ? "
			EndIf
			cQry +=			" AND SB1.B1_COD = TE2.TE2_CODPRO "
			cQry +=			" AND SB1.D_E_L_E_T_ = ' ' "
			// Historico Movimentação Munições:
			cQry += " INNER JOIN ? TFP ON "
			If !lArmMultFil
				cQry +=		" TFP.TFP_FILIAL = ?"
			Else
				cQry +=		" ? "
			EndIf
			cQry +=			" AND TFP.TFP_ENTIDA = '1' "
			cQry +=			" AND TFP.TFP_CODINT = ? " 
			cQry +=			" AND TFP.TFP_PRODUT = TE2.TE2_CODPRO "
			cQry +=			" AND TFP.TFP_FILLOC = ? "
			cQry +=			" AND TFP.TFP_CODMUN = TE2.TE2_CODMUN "
			cQry +=   		" AND TFP.TFP_SALDO > 0 "
			cQry +=			" AND TFP.TFP_MOVIM = '1' "
			cQry +=   		" AND TFP.TFP_STATUS = '1' "
			cQry +=			" AND TFP.D_E_L_E_T_ = ' ' "
			// Munições: (Where)
			cQry +=   " WHERE "
			If !lArmMultFil
				cQry += 	" TE2.TE2_FILIAL = ? AND "
			EndIf
			cQry +=         " TE2.D_E_L_E_T_ = ' ' "
			// Ordem por Codigo do Colete
			cQry += " ORDER BY TE2.TE2_CODMUN"

			oQry := FwExecStatement():New(cQry)
			oQry:SetUnsafe( nOrdem++, RetSqlName("TE2") )
			oQry:SetUnsafe( nOrdem++, RetSqlName("SB1") )
			If !lArmMultFil
				oQry:SetString( nOrdem++, xFilial("SB1") )
			Else
				oQry:SetUnsafe( nOrdem++, FWJoinFilial("TE2","SB1","TE2","SB1",.T.))
			EndIf
			oQry:SetUnsafe( nOrdem++, RetSqlName("TFP") )
			If !lArmMultFil
				oQry:SetString( nOrdem++, xFilial("TFP") )
			Else
				oQry:SetUnsafe( nOrdem++, FWJoinFilial("TE2","TFP","TE2","TFP",.T.))
			EndIf
			oQry:SetString( nOrdem++, cABSOri )
			oQry:SetString( nOrdem++, cFilOri )
			If !lArmMultFil
				oQry:SetString( nOrdem++, xFilial("TE2") )
			EndIf

		ElseIf lMovCofre

			cQry := " SELECT DISTINCT TE2.TE2_CODMUN, TE2.TE2_CODPRO, SB1.B1_COD, SB1.B1_DESC, TFP.TFP_SALDO "
			// Munições:
			cQry += " FROM ? TE2 "
			// Produtos:
			cQry += " INNER JOIN ? SB1 ON "
			If !lArmMultFil
				cQry += 	" SB1.B1_FILIAL = ? "
			Else
				cQry += 	" ? "
			EndIf
			cQry +=			" AND SB1.B1_COD = TE2.TE2_CODPRO "
			cQry +=			" AND SB1.D_E_L_E_T_ = ' ' "
			// Historico Movimentação Munições:
			cQry += " INNER JOIN ? TFP ON "
			If !lArmMultFil
				cQry +=		" TFP.TFP_FILIAL = ?"
			Else
				cQry +=		" ? "
			EndIf
			cQry +=			" AND TFP.TFP_ENTIDA = '1' "
			cQry +=			" AND TFP.TFP_CODINT = ? " 
			cQry +=			" AND TFP.TFP_PRODUT = TE2.TE2_CODPRO "
			cQry +=			" AND TFP.TFP_FILLOC = ? "
			cQry +=			" AND TFP.TFP_CODMUN = TE2.TE2_CODMUN "
			cQry +=   		" AND TFP.TFP_SALDO > 0 "
			cQry +=   		" AND TFP.TFP_STATUS = '1' "
			cQry +=			" AND TFP.TFP_MOVIM = '1' "
			cQry +=			" AND TFP.D_E_L_E_T_ = ' ' "
			// Munições: (Where)
			cQry +=   " WHERE "
			If !lArmMultFil
				cQry += 	" TE2.TE2_FILIAL = ? AND "
			EndIf
			cQry +=         " TE2.D_E_L_E_T_ = ' ' "
			// Verifica os itens vendidos TXQ:
			cQry += " AND EXISTS ( "
			cQry += 	" SELECT 1 "
			cQry += 	" FROM ? TFL "
			// Postos de Trabalho:
			cQry += 	" INNER JOIN ? TFF ON "
			If !lArmMultFil
				cQry += 	" TFF.TFF_FILIAL = ? "
			Else
				cQry += 	" ? "
			EndIf
			cQry +=         " AND TFF.TFF_CODPAI = TFL.TFL_CODIGO "
			cQry +=         " AND TFF.D_E_L_E_T_ = ' ' "
			// Armamentos - Armas:
			cQry += 	" INNER JOIN ? TXQ ON "
			If !lArmMultFil
				cQry += 	" TXQ.TXQ_FILIAL = ? "
			Else
				cQry += 	" ? "
			EndIf
			cQry +=         " AND TXQ.TXQ_CODTFF = TFF.TFF_COD"
			cQry +=         " AND TXQ.TXQ_CODPRD = TE2.TE2_CODPRO "
			cQry +=         " AND TXQ.TXQ_ITEARM = '3' " // 3 = Munição
			cQry +=         " AND TXQ.D_E_L_E_T_ = ' ' "
			// Locais de Atendimento:
			cQry +=     " WHERE TFL.TFL_FILIAL = ? " 
			cQry +=         " AND TFL.TFL_CONTRT = ? "
			cQry +=     	" AND TFL.TFL_CONREV = ? "
			cQry +=     	" AND TFL.TFL_LOCAL = ? "
			cQry +=         " AND TFL.D_E_L_E_T_ = ' ' "
			If !Empty(cPosto)
				cQry +=     " AND TFF.TFF_COD = ? "
			EndIf
			cQry += " ) " // Fecha Exists
			// Ordem por Codigo de Colete
			cQry += " ORDER BY TE2_CODMUN "

			oQry := FwExecStatement():New(cQry)
			oQry:SetUnsafe( nOrdem++, RetSqlName("TE2") )
			oQry:SetUnsafe( nOrdem++, RetSqlName("SB1") )
			If !lArmMultFil
				oQry:SetString( nOrdem++, xFilial("SB1") )
			Else
				oQry:SetUnsafe( nOrdem++, FWJoinFilial("TE2","SB1","TE2","SB1",.T.))
			EndIf
			oQry:SetUnsafe( nOrdem++, RetSqlName("TFP") )
			If !lArmMultFil
				oQry:SetString( nOrdem++, xFilial("TFP") )
			Else
				oQry:SetUnsafe( nOrdem++, FWJoinFilial("TE2","TFP","TE2","TFP",.T.))
			EndIf
			oQry:SetString( nOrdem++, cABSOri )
			oQry:SetString( nOrdem++, cFilOri )
			If !lArmMultFil
				oQry:SetString( nOrdem++, xFilial("TE2") )
			EndIf
			// Exists
			oQry:SetUnsafe( nOrdem++, RetSqlName("TFL") )
			oQry:SetUnsafe( nOrdem++, RetSqlName("TFF") )
			If !lArmMultFil
				oQry:SetString( nOrdem++, xFilial("TFF") )
			Else
				oQry:SetUnsafe( nOrdem++, FWJoinFilial("TFL","TFF","TFL","TFF",.T.))
			EndIf
			oQry:SetUnsafe( nOrdem++, RetSqlName("TXQ") )
			If !lArmMultFil
				oQry:SetString( nOrdem++, xFilial("TXQ") )
			Else
				oQry:SetUnsafe( nOrdem++, FWJoinFilial("TFF","TXQ","TFF","TXQ",.T.))
			EndIf
			If !lArmMultFil
				oQry:SetString( nOrdem++, xFilial("TFL") )
			Else
				oQry:SetString( nOrdem++, cFilDes )
			EndIf
			oQry:SetString( nOrdem++, cContrato )
			oQry:SetString( nOrdem++, cRevisao )
			oQry:SetString( nOrdem++, cAbsDes )
			If !Empty(cPosto)
				oQry:SetString( nOrdem++, cPosto )
			EndIf

		ElseIf lMovContr

			cQry := " SELECT DISTINCT TE2.TE2_CODMUN, SB1.B1_COD, SB1.B1_DESC, TE2.TE2_CODPRO, TFP.TFP_SALDO "
			// Munições:
			cQry += " FROM ? TE2 "
			// Produtos:
			cQry += " INNER JOIN ? SB1 ON "
			If !lArmMultFil
				cQry += 	" SB1.B1_FILIAL = ? "
			Else
				cQry += 	" ? "
			EndIf
			cQry +=			" AND SB1.B1_COD = TE2.TE2_CODPRO "
			cQry +=			" AND SB1.D_E_L_E_T_ = ' ' "
			// Historico Movimentação Munições:
			cQry += " INNER JOIN ? TFP ON "
			If !lArmMultFil
				cQry +=		" TFP.TFP_FILIAL = ? "
			Else
				cQry +=		" ? "
			EndIf
			cQry +=			" AND TFP.TFP_ENTIDA = '2' "
			cQry +=			" AND TFP.TFP_CODLOC = ? " 
			cQry +=			" AND TFP.TFP_PRODUT = TE2.TE2_CODPRO "
			cQry +=			" AND TFP.TFP_FILLOC = ? "
			cQry +=			" AND TFP.TFP_CODMUN = TE2.TE2_CODMUN "
			cQry +=   		" AND TFP.TFP_SALDO > 0 "
			cQry +=   		" AND TFP.TFP_STATUS = '1' "
			cQry +=			" AND TFP.TFP_MOVIM = '2' "
			cQry +=			" AND TFP.D_E_L_E_T_ = ' ' "
			cQry += " INNER JOIN ? TFL ON "
			cQry +=			" TFL.TFL_FILIAL = ? AND " // XFILIAL OU TFP_FILLOC
			cQry +=			" TFL.TFL_CODIGO = ? "
			cQry +=			" AND TFL.D_E_L_E_T_ = ' ' "
			cQry += " INNER JOIN ? TFF ON "
			If !lArmMultFil
				cQry +=		" TFF.TFF_FILIAL = ? "
			Else
				cQry +=		" ? "
			EndIf
			cQry +=         " AND TFF.TFF_CODPAI = TFL.TFL_CODIGO "
			cQry +=         " AND TFF.D_E_L_E_T_ = ' ' "
			cQry += " INNER JOIN ? TXQ ON "
			If !lArmMultFil
				cQry +=		" TXQ.TXQ_FILIAL = ? "
			Else
				cQry +=		" ? "
			EndIf
			cQry +=         " AND TXQ.TXQ_CODTFF = TFF.TFF_COD "
			cQry +=         " AND TXQ.TXQ_ITEARM = '3' "
			cQry +=         " AND TXQ.TXQ_QTDAPO > 0 "
			cQry +=         " AND TXQ.D_E_L_E_T_ = ' ' "
			// Munições: (Where)
			cQry +=   " WHERE "
			If !lArmMultFil
				cQry += 	" TE2.TE2_FILIAL = ? AND "
			EndIf
			cQry +=         " TE2.D_E_L_E_T_ = ' ' "
			// Ordem por Codigo do Colete
			cQry += " ORDER BY TE2.TE2_CODMUN"

			oQry := FwExecStatement():New(cQry)
			oQry:SetUnsafe( nOrdem++, RetSqlName("TE2") )		
			oQry:SetUnsafe( nOrdem++, RetSqlName("SB1") )
			If !lArmMultFil
				oQry:SetString( nOrdem++, xFilial("SB1") )
			Else
				oQry:SetUnsafe( nOrdem++, FWJoinFilial("TE2","SB1","TE2","SB1",.T.))
			EndIf
			oQry:SetUnsafe( nOrdem++, RetSqlName("TFP") )
			If !lArmMultFil
				oQry:SetString( nOrdem++, xFilial("TFP") )
			Else
				oQry:SetUnsafe( nOrdem++, FWJoinFilial("TE2","TFP","TE2","TFP",.T.))
			EndIf
			oQry:SetString( nOrdem++, cABSOri )
			oQry:SetString( nOrdem++, cFilOri )
			oQry:SetUnsafe( nOrdem++, RetSqlName("TFL") )			
			If !lArmMultFil
				oQry:SetString( nOrdem++, xFilial("TFL") )
			Else
				oQry:SetString( nOrdem++, cFilOri)
			EndIf
			oQry:SetString( nOrdem++, cCodigoTFL)
			oQry:SetUnsafe( nOrdem++, RetSqlName("TFF") )	
			If !lArmMultFil
				oQry:SetString( nOrdem++, xFilial("TFF") )
			Else
				oQry:SetUnsafe( nOrdem++, FWJoinFilial("TFL","TFF","TFL","TFF",.T.))
			EndIf
			oQry:SetUnsafe( nOrdem++, RetSqlName("TXQ") )	
			If !lArmMultFil
				oQry:SetString( nOrdem++, xFilial("TXQ") )
			Else
				oQry:SetUnsafe( nOrdem++, FWJoinFilial("TFF","TXQ","TFF","TXQ",.T.))
			EndIf
			If !lArmMultFil
				oQry:SetString( nOrdem++, xFilial("TE2") )
			EndIf
		EndIf
	EndIf

Return oQry

//--------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} qryTXQ

Monta a query da TXQ, a depender do tipo de de armamento (arma, colete ou munição) e do tipo da movimentação.
Essa função também é utilizada para validar caso o código seja digitado no campo.

@author jack.junior
@since 21/04/2026
@version P12.2510

@return lRet
/*/
//--------------------------------------------------------------------------------------------------------------------
Static Function qryTXQ(oModelTFQ, cTipo)
	Local cABSDes     := ""
	Local cABSOri     := ""
	Local cCodigoTFL  := ""
	Local cCodProd    := ""
	Local cCodTipo    := ""
	Local cContrato   := ""
	Local cEntDest    := ""
	Local cEntOri     := ""
	Local cFilDes     := ""
	Local cFilLocal   := ""
	Local cFilOri     := ""
	Local cLocal      := ""
	Local cPosto      := ""
	Local cQry        := ""
	Local cRevisao    := ""
	Local lArmMultFil := .F.
	Local lMovCofre   := .F.
	Local lMovContr   := .F.
	Local lMovInterna := .F.
	Local nOrdem      := 1
	Local oQry        := Nil

	If ValType(oModelTFQ) == "O" .And. oModelTFQ <> Nil

		// Coleta as informações necessárias do Modelo por referencia @:
		modelInfo(oModelTFQ, @cContrato, @cRevisao, @cPosto, @cEntOri, @cFilOri, @cABSOri, @cEntDest, @cFilDes, @cABSDes, @lMovInterna, @lMovCofre, @lMovContr, @lArmMultFil, @cCodigoTFL)
		
		If cTipo == itARMA
			cCodProd   := Posicione('TE0',1,xFilial('TE0')+oModelTFQ:GetModel():GetModel("TFOARMA"):GetValue("TFO_ITCOD"),'TE0_CODPRO')
			cCodTipo   := "1"
		ElseIf cTipo == itCOLETE
			cCodProd   := Posicione('TE1',1,xFilial('TE1')+oModelTFQ:GetModel():GetModel("TFOCOLE"):GetValue("TFO_ITCOD"),'TE1_CODPRO')
			cCodTipo   := "2"
		ElseIf cTipo == itMUNICAO
			cCodProd   := Posicione('TE2',1,xFilial('TE2')+oModelTFQ:GetModel():GetModel("TFOMUNI"):GetValue("TFO_ITCOD"),'TE2_CODPRO')
			cCodTipo   := "3"
		EndIf

		If lMovCofre // Cofre -> Contrato (Local do contrato é o Destino)
			cFilLocal := cFilDes
			cLocal    := cABSDes
		ElseIf lMovContr // Contrato -> Cofre (Local do contrato é a Origem)
			cFilLocal := cFilOri
			cLocal    := cABSOri
		EndIf

		If lMovCofre .Or. lMovContr
			cQry := " SELECT TXQ.TXQ_CODIGO, TFF.TFF_COD, TXQ.TXQ_CODPRD, TXQ.TXQ_QTDVEN, TXQ.TXQ_QTDAPO "
			// Armamentos
			cQry += " FROM ? TXQ "
			cQry += 	" INNER JOIN ? TFF ON "
			If !lArmMultFil
				cQry += 	" TFF.TFF_FILIAL = ? "
			Else
				cQry += 	" ? "
			EndIf
			cQry +=			" AND TFF.TFF_COD = TXQ.TXQ_CODTFF "
			cQry +=         " AND TFF.D_E_L_E_T_ = ' ' "
			cQry += 	" INNER JOIN ? TFL ON "
			cQry += 		" TFL.TFL_FILIAL = ? "
			cQry +=         " AND TFL.TFL_CODIGO = TFF.TFF_CODPAI "
			cQry +=         " AND TFL.D_E_L_E_T_ = ' ' "
			cQry +=   " WHERE "
			If !lArmMultFil
				cQry += 	" TXQ.TXQ_FILIAL = ? AND "
			EndIf
			cQry +=     " TXQ.TXQ_CODPRD = ? AND "
			cQry +=     " TXQ.TXQ_ITEARM = ? AND " // '1' = Armas '2' = Coletes '3' = Munições
			cQry +=     " TXQ.D_E_L_E_T_ = ' ' AND "
			cQry +=		" TFL.TFL_CODIGO = ? "
			If !Empty(cPosto)
				cQry +=	" AND TFF.TFF_COD = ? "
			EndIf
			cQry += " ORDER BY TXQ.TXQ_CODIGO"

			cQry := ChangeQuery( cQry )
			oQry := FwExecStatement():New(cQry)		
			oQry:SetUnsafe( nOrdem++, RetSqlName("TXQ") )
			oQry:SetUnsafe( nOrdem++, RetSqlName("TFF") )
			If !lArmMultFil
				oQry:SetString( nOrdem++, xFilial("TFF") )
			Else
				oQry:SetUnsafe( nOrdem++, FWJoinFilial("TXQ","TFF","TXQ","TFF",.T.))
			EndIf
			oQry:SetUnsafe( nOrdem++, RetSqlName("TFL") )
			If !lArmMultFil
				oQry:SetString( nOrdem++, xFilial("TFL") )
			Else
				oQry:SetString( nOrdem++, cFilLocal )
			EndIf
			If !lArmMultFil
				oQry:SetString( nOrdem++, xFilial("TXQ") )
			EndIf		
			oQry:SetString( nOrdem++, cCodProd )
			oQry:SetString( nOrdem++, cCodTipo )
			oQry:SetString( nOrdem++, cCodigoTFL )
			If !Empty(cPosto)
				oQry:SetString( nOrdem++, cPosto )
			EndIf
		EndIf
	EndIf

Return oQry

//--------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} qryLocal

Monta a query do Local, origem ou destino, quando é o local do Contrato, a depender do tipo de movimentação.
Essa função também é utilizada para validar caso o código seja digitado no campo.

@author jack.junior
@since 21/04/2026
@version P12.2510

@return lRet
/*/
//--------------------------------------------------------------------------------------------------------------------
Static Function qryLocal(oModelTFQ)
	
	Local cMotivo := ""
	Local cQry    := ""
	Local cStatus := ""
	Local nOrdem  := 1
	Local oQry    := Nil

	If ValType(oModelTFQ) == "O" .And. oModelTFQ <> Nil

		cMotivo := oModelTFQ:getValue("TFQ_MOTIVO")
		cStatus:= oModelTFQ:getValue("TFQ_STATUS")

		cQry := " SELECT DISTINCT TFL_LOCAL,ABS_DESCRI,TFL_CODIGO "
		cQry += " FROM ? TFF "
		cQry +=      " INNER JOIN ? TFJ "
		cQry +=              " ON TFJ.TFJ_FILIAL = ? "
		cQry +=                 " AND TFJ.TFJ_CONTRT = ? "
		cQry +=                 " AND TFJ.TFJ_CONREV = ? "
		cQry +=                 " AND TFJ.TFJ_STATUS='1' "
		cQry +=                 " AND TFJ.D_E_L_E_T_ = ' ' "
		cQry +=      " INNER JOIN ? TFL "
		cQry +=              " ON TFL.TFL_FILIAL = ? "
		cQry +=                 " AND TFL.TFL_CODIGO = TFF.TFF_CODPAI "
		cQry +=                 " AND TFL.D_E_L_E_T_ = ' ' "
		cQry +=      " INNER JOIN ? ABS "
		cQry +=              " ON ABS.ABS_FILIAL = ? "
		cQry +=                 " AND ABS.ABS_LOCAL = TFL.TFL_LOCAL "
		cQry +=                 "  AND ABS.D_E_L_E_T_ = ' ' "
		cQry +=      " INNER JOIN ? TXQ"
		cQry +=              " ON TXQ.TXQ_FILIAL = ?"
		cQry +=                 " AND TXQ.TXQ_CODTFF = TFF.TFF_COD"
		cQry +=                 " AND TXQ.D_E_L_E_T_ = ' ' "
		cQry += " WHERE TFF.TFF_FILIAL = ?"
		cQry +=       " AND TFL.TFL_CODPAI = TFJ.TFJ_CODIGO "
		If cMotivo == '1' .And. cStatus == '1'
			cQry +=   " AND TFF.TFF_ENCE <> '1'"
			cQry +=   " AND ? < TFF.TFF_PERFIM"
		ElseIf cMotivo == '5'
			cQry +=   " AND (TFF.TFF_ENCE <> '1' OR TFF.TFF_ENCE = '1')"
		Else
			cQry +=   " AND (TFF.TFF_ENCE <> '1' OR (TFF.TFF_ENCE = '1' AND TFF.TFF_DTENCE >= ?))"
			If !At680Perm( Nil, __cUserId, "076" )
				cQry +=   " AND ? BETWEEN TFF.TFF_PERINI AND TFF.TFF_PERFIM "
			EndIf
		EndIf
		cQry +=       " AND TFF.D_E_L_E_T_ = ' ' "
		cQry += " ORDER BY TFL_LOCAL "

		cQry := ChangeQuery(cQry)
		oQry := FwExecStatement():New(cQry)
		oQry:SetUnsafe( nOrdem++, RetSqlName("TFF") )
		oQry:SetUnsafe( nOrdem++, RetSqlName("TFJ") )
		oQry:SetString( nOrdem++, xFilial("TFJ") )
		oQry:SetString( nOrdem++, oModelTFQ:getValue("TFQ_CONTRT") )
		oQry:SetString( nOrdem++, oModelTFQ:getValue("TFQ_CONREV") )

		oQry:SetUnsafe( nOrdem++, RetSqlName("TFL") )
		oQry:SetString( nOrdem++, xFilial("TFL") )

		oQry:SetUnsafe( nOrdem++, RetSqlName("ABS") )
		oQry:SetString( nOrdem++, xFilial("ABS") )

		oQry:SetUnsafe( nOrdem++, RetSqlName("TXQ") )
		oQry:SetString( nOrdem++, xFilial("TXQ") )

		oQry:SetString( nOrdem++, xFilial("TFF") )
		If cMotivo == '1' .And. cStatus == '1'
			oQry:SetDate( nOrdem++, dDataBase )
		ElseIf cMotivo != '5' 
			oQry:SetDate( nOrdem++, dDataBase )
			If !At680Perm( Nil, __cUserId, "076" )
				oQry:SetDate( nOrdem++, dDataBase )
			EndIf
		EndIf
	EndIf

Return oQry

//--------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} vldArmCod

Valida o código escolhido para o campo de TFO_ITCOD de acordo com o tipo de movimentação.
@author jack.junior
@since 21/04/2026
@version P12.2510

@return lRet
/*/
//--------------------------------------------------------------------------------------------------------------------
Static Function vldArmCod(oMdlTFO, cItCod, cItMov)
	Local cAliasArm := ""
	Local lRet      := .F.
	Local oModelTFQ := oMdlTFO:GetModel():GetModel("TFQMASTER")
	Local oQry      := Nil

	If cItMov == itARMA .Or. cItMov == itCOLETE
		oQry := qryArmCol(oModelTFQ, cItMov)
	ElseIf cItMov == itMUNICAO
		oQry := qryMunicao(oModelTFQ)
	EndIf

	cAliasArm := oQry:OpenAlias()

	While (cAliasArm)->(!Eof())
		If cItMov == itARMA
			If AllTrim((cAliasArm)->TE0_COD) == AllTrim(cItCod)
				lRet := .T.
				EXIT
			EndIf
		ElseIf cItMov == itCOLETE
			If AllTrim((cAliasArm)->TE1_CODCOL) == AllTrim(cItCod)
				lRet := .T.
				EXIT
			EndIf
		ElseIf cItMov == itMUNICAO
			If AllTrim((cAliasArm)->TE2_CODMUN) == AllTrim(cItCod)
				lRet := .T.
				EXIT
			EndIf
		EndIf
		(cAliasArm)->(dbSkip())
	EndDo

	(cAliasArm)->(dbCloseArea())
	oQry:Destroy()
	FwFreeObj(oQry)
Return lRet

//--------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} vldTXQCod

Valida o código escolhido para o campo de TFO_CODTXQ de acordo com o tipo de movimentação.
@author jack.junior
@since 21/04/2026
@version P12.2510

@return lRet
/*/
//--------------------------------------------------------------------------------------------------------------------
Static Function vldTXQCod(oMdlTFO, cItCod, cItMov)
	Local cAliasTXQ := ""
	Local lRet      := .F.
	Local oModelTFQ := oMdlTFO:GetModel():GetModel("TFQMASTER")
	Local oQry      := Nil

	oQry := qryTXQ(oModelTFQ, cItMov)

	cAliasTXQ := oQry:OpenAlias()

	While (cAliasTXQ)->(!Eof())
		If AllTrim((cAliasTXQ)->TXQ_CODIGO) == AllTrim(cItCod)
			lRet := .T.
			EXIT
		EndIf
		(cAliasTXQ)->(dbSkip())
	EndDo

	(cAliasTXQ)->(dbCloseArea())
	oQry:Destroy()
	FwFreeObj(oQry)
Return lRet

//--------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} vldLocal

Valida o código escolhido para o campo de ORIGEM ou DESTINO, a depender da entidade (TFL ou TER)
@author jack.junior
@since 21/04/2026
@version P12.2510

@return lRet
/*/
//--------------------------------------------------------------------------------------------------------------------
Static Function vldLocal(oMdlTFO, cCodigo, cChave, cEntidade)
	Local cAliasTFL := ""
	Local cFil      := ""
	Local lRet      := .F.
	Local oModelTFQ := Nil
	Local oQry      := Nil

	oModelTFQ := oMdlTFO:GetModel():GetModel("TFQMASTER")

	If (cChave == "TFQ_ORIGEM" .And. cEntidade == eoLOCATEND) .Or. (cChave == "TFQ_DESTIN" .And. cEntidade == edCLIENTE)
		oQry := qryLocal(oModelTFQ)

		cAliasTFL := oQry:OpenAlias()

		While (cAliasTFL)->(!Eof())
			If AllTrim((cAliasTFL)->TFL_LOCAL) == AllTrim(cCodigo)
				lRet := .T.
				EXIT
			EndIf
			(cAliasTFL)->(dbSkip())
		EndDo

		(cAliasTFL)->(dbCloseArea())
		oQry:Destroy()
		FwFreeObj(oQry)
	Else
		If cChave == "TFQ_ORIGEM"
			cFil := oModelTFQ:GetValue("TFQ_FILORI")
		ElseIf cChave == "TFQ_DESTIN"
			cFil := oModelTFQ:GetValue("TFQ_FILDES")
		EndIf
		lRet := tecExistCPO("TER", xFilial("TER",cFil)+cCodigo)
	EndIf
Return lRet

//--------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} modelInfo

Acessa os conteúdos do modelo TFQ. É possível pegar o conteúdo das variáveis por referencia.
@author jack.junior
@since 21/04/2026
@version P12.2510

@return lRet
/*/
//--------------------------------------------------------------------------------------------------------------------
Static Function modelInfo(oModelTFQ, cContrato, cRevisao, cPosto, cEntOri, cFilOri, cABSOri, cEntDest, cFilDes, cABSDes, lMovInterna, lMovCofre, lMovContr, lArmMultFil, cCodigoTFL)

	cContrato := oModelTFQ:GetValue("TFQ_CONTRT") // Contrato - Onde o armamento está
	cRevisao  := oModelTFQ:GetValue("TFQ_CONREV") // Revisão do contrato
	cPosto    := oModelTFQ:GetValue("TFQ_POSTO")  // Posto
	cEntOri   := oModelTFQ:GetValue("TFQ_ENTORI") // Entidade de Origem - 1=Local Interno;2=Local de Atendimento
	cFilOri   := oModelTFQ:GetValue("TFQ_FILORI") // Filial do Local origem
	cABSOri   := oModelTFQ:GetValue("TFQ_ORIGEM") // Local do armamento origem
	cEntDest  := oModelTFQ:GetValue("TFQ_ENTDES") // Endidade de Destino - 1=Cliente;2=Empresa
	cFilDes   := oModelTFQ:GetValue("TFQ_FILDES") // Filial do Local destino
	cABSDes   := oModelTFQ:GetValue("TFQ_DESTIN") // Local do armamento destino
	cCodigoTFL:= oModelTFQ:GetValue("TFQ_CODTFL") // Código da TFL escolhida no F3 de Local

	// Cofre para Cofre (interna)
	lMovInterna :=  Empty(cContrato) .And. cEntOri == eoLOCINTER .And. cEntDest == edEMPRESA 
	// Cofre para Contrato
	lMovCofre   := !Empty(cContrato) .And. cEntOri == eoLOCINTER .And. cEntDest == edCLIENTE
	// Contrato para Cofre
	lMovContr 	:= !Empty(cContrato) .And. cEntOri == eoLOCATEND .And. cEntDest == edEMPRESA

	// Verifica se ambiente está configurado para MultiFilial:
	lArmMultFil := TecMtFlArm()

Return

//--------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} isReforco

Verifica se a Arma ou Colete implantado é um Reforço ao contrato (Para não contabilizar na TXQ_QTDAPO)
@author jack.junior
@since 21/04/2026
@version P12.2510

@return lRet
/*/
//--------------------------------------------------------------------------------------------------------------------
Static Function isReforco(oModelTFQ, cItCod, cItMov)
	Local aArea       := GetArea()
	Local cABSDes     := ""
	Local cABSOri     := ""
	Local cAlias      := ""
	Local cAliasQry   := ""
	Local cCodigo     := ""
	Local cCodigoTFL  := ""
	Local cContrato   := ""
	Local cEntDest    := ""
	Local cEntOri     := ""
	Local cFilDes     := ""
	Local cFilOri     := ""
	Local cPosto      := ""
	Local cPrefixo    := ""
	Local cQry        := ""
	Local cRevisao    := ""
	Local lArmMultFil := .F.
	Local lMovCofre   := .F.
	Local lMovContr   := .F.
	Local lMovInterna := .F.
	Local lRet        := .F.
	Local nOrdem      := 1
	Local oQry        := Nil

	If cItMov == itARMA
		cCodigo := "TE0.TE0_COD"
		cAlias  := "TE0"
	ElseIf cItMov == itCOLETE
		cCodigo := "TE1.TE1_CODCOL"
		cAlias  := "TE1"
	EndIf

	cPrefixo := cAlias+"."+cAlias

	If !Empty(cCodigo)

		modelInfo(oModelTFQ, @cContrato, @cRevisao, @cPosto, @cEntOri, @cFilOri, @cABSOri, @cEntDest, @cFilDes, @cABSDes, @lMovInterna, @lMovCofre, @lMovContr, @lArmMultFil, @cCodigoTFL)

		cQry := " SELECT TFQ.TFQ_MOTIVO "
		cQry += " FROM ? "+cAlias+" "
		// Movimentações TFQ:
		cQry += " INNER JOIN ? TFQ ON "
		If !lArmMultFil
			cQry += 	" TFQ.TFQ_FILIAL = ? "
		Else
			cQry += 	" ? "
		EndIf
		cQry += 		" AND TFQ.TFQ_CODIGO = "+cPrefixo+"_CODMOV "
		cQry += 		" AND TFQ.TFQ_FILDES = "+cPrefixo+"_FILLOC "
		cQry += 		" AND TFQ.TFQ_DESTIN = "+cPrefixo+"_LOCAL "
		cQry += 		" AND TFQ.D_E_L_E_T_ = ' ' "
		// Itens da Movimentação TFO: TFO_FILIAL+TFO_CDMOV+TFO_ITMOV+TFO_ITCOD+TFO_CODIGO
		cQry += " INNER JOIN ? TFO ON  "
		If !lArmMultFil
			cQry += 	" TFO.TFO_FILIAL = ? "
		Else
			cQry += 	" ? "
		EndIf
		cQry += 		" AND TFO.TFO_CDMOV = TFQ.TFQ_CODIGO "
		cQry += 		" AND TFO.TFO_ITMOV = "+cItMov+" " // 1- Armas/ 2-Coletes/ 3-Munições
		cQry += 		" AND TFO.TFO_ITCOD = "+cCodigo+" "
		cQry += 		" AND TFO.D_E_L_E_T_ = ' ' "
		cQry += " WHERE "
		If !lArmMultFil
			cQry +=	" "+cPrefixo+"_FILIAL = ? AND "
		EndIf
		cQry += 	" "+cPrefixo+"_FILLOC = ? "
		cQry += 	" AND "+cCodigo+" = ? "
		cQry += 	" AND "+cPrefixo+"_LOCAL = ? "
		cQry += 	" AND TFQ.TFQ_CODTFL = ? "
		If !Empty(cPosto)
			cQry += " AND TFQ.TFQ_POSTO = ? "
		EndIf
		cQry += 	" AND "+cAlias+".D_E_L_E_T_ = ' ' "

		cQry := ChangeQuery( cQry )
		oQry := FwExecStatement():New(cQry)		
		// Armas:
		oQry:SetUnsafe( nOrdem++, RetSqlName(cAlias) )
		// Movimentações TFQ:
		oQry:SetUnsafe( nOrdem++, RetSqlName("TFQ") )
		If !lArmMultFil
			oQry:SetString( nOrdem++, xFilial("TFQ") )
		Else
			oQry:SetUnsafe( nOrdem++, FWJoinFilial(cAlias,"TFQ",cAlias,"TFQ",.T.))
		EndIf
		// Itens da Movimentação TFO:
		oQry:SetUnsafe( nOrdem++, RetSqlName("TFO") )
		If !lArmMultFil
			oQry:SetString( nOrdem++, xFilial("TFO") )
		Else
			oQry:SetUnsafe( nOrdem++, FWJoinFilial("TFQ","TFO","TFQ","TFO",.T.))
		EndIf
		// Where
		If !lArmMultFil
			oQry:SetString( nOrdem++, xFilial(cAlias) )
		EndIf
		oQry:SetString( nOrdem++, cFilOri )
		oQry:SetString( nOrdem++, cItCod )
		oQry:SetString( nOrdem++, cABSOri )
		oQry:SetString( nOrdem++, cCodigoTFL )
		If !Empty(cPosto)
			oQry:SetString( nOrdem++, cPosto )
		EndIf

		cAliasQry := oQry:OpenAlias()

		While (cAliasQry)->(!Eof())
			If (cAliasQry)->TFQ_MOTIVO == mtREFORCO // Tipo '4' - Reforço
				lRet := .T.
			EndIf
			(cAliasQry)->(dbSkip())
		EndDo

		(cAliasQry)->(dbCloseArea())
		oQry:Destroy()
		FwFreeObj(oQry)
	EndIf

	RestArea(aArea)	

Return lRet

//--------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} at880ConF3

Monta a DIALOG de Consulta Específica da rotina
@author jack.junior
@since 21/04/2026
@version P12.2510

@return lRet
/*/
//--------------------------------------------------------------------------------------------------------------------
Static Function at880ConF3( cTipo, cTitulo, cDescricao, aColumns, cQry, aIndex, aSeek, cCampoCod)
	Local aArea     := GetArea()
	Local bConfirm  := Nil
	Local cAlias    := GetNextAlias()
	Local cCampoTFL := ""
	Local cCampoMun := ""
	Local cRetorno  := ""
	Local lRet      := .F.
	Local nDireita  := GetScreenRes()[1] * 0.8
	Local nInferior := GetScreenRes()[2] * 0.6
	Local oBrowse   := Nil
	Local oDialog   := Nil

	Default aColumns   := {}
	Default aIndex     := {}
	Default aSeek      := {}
	Default cDescricao := ""
	Default cTitle     := ""

	If !Empty(cQry)

		DEFINE MSDIALOG oDialog TITLE OemToAnsi(cTitulo) FROM 0, 0 TO nInferior,nDireita PIXEL

			oBrowse := FWFormBrowse():New()
			oBrowse:SetOwner(oDialog)
			oBrowse:SetDataQuery(.T.)
			oBrowse:SetAlias(cAlias)
			oBrowse:SetQueryIndex(aIndex)
			oBrowse:SetQuery(cQry)
			oBrowse:SetSeek(,aSeek)
			oBrowse:SetDescription(cDescricao) 
			oBrowse:SetMenuDef("")
			TECSetFlt(aSeek, @oBrowse)
			oBrowse:DisableDetails()
			oBrowse:SetUseFilter(.T.)
			oBrowse:SetProfileID(cAlias)

			If cTipo $ "|CONTRLOCAL|"
				bConfirm := {|| cRetorno := (oBrowse:Alias())->&( cCampoCod ), ;
								cCampoTFL := (oBrowse:Alias())->&( "TFL_CODIGO" ), ;
								lRet := .T., ;
								oDialog:End()}
			ElseIf cTipo $ "|MUNI|"
				bConfirm := {|| cRetorno := (oBrowse:Alias())->&( cCampoCod ), ;
								cCampoMun := (oBrowse:Alias())->&( "TE2_CODPRO" ), ;
								lRet := .T., ;
								oDialog:End()}
			Else
				bConfirm := {|| cRetorno := (oBrowse:Alias())->&( cCampoCod ), ;
								lRet := .T., ;
								oDialog:End()}
			EndIf

			// Regras de duplo clique:
			oBrowse:SetDoubleClick(bConfirm)
			// Botões do Browse:
			oBrowse:AddButton( OemTOAnsi("Confirmar"), bConfirm, ,2 ) //"Confirmar"
			oBrowse:AddButton( OemTOAnsi("Cancelar"), {|| lRet := .F., oDialog:End() } ,, 2 ) //"Cancelar"
			oBrowse:DisableDetails()

			oBrowse:SetColumns(aColumns)

			oBrowse:Activate()

		ACTIVATE MSDIALOG oDialog CENTERED

		If lRet .And. !Empty(cRetorno)
			// Popula a variavel estatica de retorno da Consulta Específica:
			_cRetF3  := cRetorno
			
			// Para consulta do local retornar o Código da TFL também:
			If cTipo $ "|CONTRLOCAL|"
				_cCodTFL := cCampoTFL
			EndIf

			// Para consulta de Munições retornar o Código do Produto:
			If cTipo $ "|MUNI|"
				_cProduto := cCampoMun
			EndIf
		EndIf

	EndIf

	RestArea(aArea)

Return lRet
