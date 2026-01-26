#INCLUDE "GFEA066.CH"
#INCLUDE "DBINFO.CH"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"

/*---------------------------------------------------------------------------------------------------
{Protheus.doc} GFEA066
Auditoria/Aprovação de Documento de Frete
Generico

@sample
GFEA066()

@author Felipe M.
@since 23/11/09
@version 1.0
----------------------------------------------------------------------------------------------------*/

Function GFEA066()
	Local cFilPadrao := "GW3_SIT == '2'"
	Private s_VLCNPJ  := SuperGetMV('MV_VLCNPJ',,'1')

	If SuperGetMv("MV_ERPGFE",.F.,"2") == "1" .And. SuperGetMv("MV_DFMLA",.F.,"1") $ "2|3"
		Help(,,'HELP',,"Sistema parametrizado para realizar a aprovação de documentos de fretes através do módulo MLA.",1,0)
		Return Nil
	EndIf

	Private oBrowse

	oBrowse := FWMBrowse():New()
	oBrowse:SetAlias("GW3")			// Alias da tabela utilizada
	oBrowse:SetMenuDef("GFEA066")	// Nome do fonte onde esta a função MenuDef
	oBrowse:SetDescription(STR0001)	//"Aprovação de Documento de Frete"

	oBrowse:SetFilterDefault(cFilPadrao)

	// Início Ponto de Entrada 
	If ExistBlock("GFEA0662")	
		oBrowse:SetFilterDefault(ExecBlock("GFEA0662",.f.,.f.,{cFilPadrao}))
	EndIf	

	oBrowse:Activate()
Return Nil

//------------------------------------------------------------------------------------------------ 

Static Function MenuDef()
	Local aRotina := {}

	// Adiciona botões do browse
	ADD OPTION aRotina TITLE STR0002 ACTION "VIEWDEF.GFEA066" OPERATION 2 ACCESS 0 //"Visualizar"
	ADD OPTION aRotina TITLE STR0003 ACTION "GFEA066AP(.T.)"  OPERATION 2 ACCESS 0 //"Aprovar"
	ADD OPTION aRotina TITLE STR0004 ACTION "VIEWDEF.GFEA066" OPERATION 8 ACCESS 0 //"Imprimir"

Return aRotina

//------------------------------------------------------------------------------------------------ 

Static Function ModelDef()
	Local oModel

	// cID     Identificador do modelo 
	// bPre    Code-Block de pre-edição do formulário de edição. Indica se a edição esta liberada
	// bPost   Code-Block de validação do formulário de edição
	// bCommit Code-Block de persistência do formulário de edição
	// bCancel Code-Block de cancelamento do formulário de edição
	oModel := MPFormModel():New("GFEA066", /*bPre*/, /*bPost*/,/*bCommit*/, /*bCancel*/)
	// cId          Identificador do modelo
	// cOwner       Identificador superior do modelo
	// oModelStruct Objeto com  a estrutura de dados
	// bPre         Code-Block de pré-edição do formulário de edição. Indica se a edição esta liberada
	// bPost        Code-Block de validação do formulário de edição
	// bLoad        Code-Block de carga dos dados do formulário de edição
	oModel:AddFields("GFEA066_GW3", Nil, FWFormStruct(1,"GW3"),/*bPre*/,/*bPost*/,/*bLoad*/) 

Return oModel     

//------------------------------------------------------------------------------------------------

Static Function ViewDef()
	Local oModel := FWLoadModel("GFEA066")
	Local oView  := Nil

	oView := FWFormView():New()
	// Objeto do model a se associar a view.
	oView:SetModel(oModel)
	// cFormModelID - Representa o ID criado no Model que essa FormField irá representar
	// oStruct - Objeto do model a se associar a view.
	// cLinkID - Representa o ID criado no Model ,Só é necessári o caso estamos mundando o ID no View.
	oView:AddField( "GFEA066_GW3" , FWFormStruct(2,"GW3"), /*cLinkID*/ ) //
	// cID		  	Id do Box a ser utilizado
	// nPercHeight  Valor da Altura do box( caso o lFixPixel seja .T. é a qtd de pixel exato)
	// cIdOwner 	Id do Box Vertical pai. Podemos fazer diversas criações uma dentro da outra.
	// lFixPixel	Determina que o valor passado no nPercHeight é na verdade a qtd de pixel a ser usada.
	// cIDFolder	Id da folder onde queremos criar o o box se passado esse valor, é necessário informar o cIDSheet
	// cIDSheet     Id da Sheet(Folha de dados) onde queremos criar o o box.

	oView:CreateHorizontalBox( 'MASTER' , 60 )
	oView:CreateHorizontalBox( 'DETAIL' , 40 )
	oView:CreateFolder('IDFOLDER01','DETAIL')
	oView:CreateHorizontalBox( 'DETAILNETO1' , 100,,,'IDFOLDER01','IDSHEET01'  )

	// Associa um View a um box
	oView:SetOwnerView( "GFEA066_GW3" , "MASTER" )

Return oView

/*----------------------------------------------------------------------------------------------------
{Protheus.doc} GFEA66CASE
Função genérica que retorna o CASE sql que mostra a descrição de acordo com o dicionário de dados, ao invés do valor.

@sample
GFEA66CASE(cTbl, cCmp, cAlias)

@author Octávio Augusto Felippe de Macedo
@since 27/10/2011
@version 1.0
----------------------------------------------------------------------------------------------------*/

Function GFEA66CASE(cTbl, cCmp, cAlias, cElse)

	Local cCase := ""
	Local nCount
	Local aAreaSX3 := SX3->( GetArea() )

	cCase += " (CASE " + cTbl + "." + cCmp + " "	

	For nCount := 1 To Len(StrTokArr(Posicione("SX3", 2, cCmp, "X3_CBOX"),';'))
		cCase += " 	WHEN '" + AllTrim(Str(nCount)) + "' THEN '" + PadR(GFEFldInfo(cCmp, AllTrim(Str(nCount)), 2),25) + "' "
	Next nCount

	cCase += "		ELSE " + cElse + " "
	cCase += "	END) " + cAlias

	RestArea(aAreaSX3)

Return cCase

/*----------------------------------------------------------------------------------------------------
{Protheus.doc} GFEA66STRU
Função para criar o array da estrutura da msSelect

@sample
GFEA66STRU(aCmp)

@author Octávio Augusto Felippe de Macedo
@since 27/10/2011
@version 1.0
----------------------------------------------------------------------------------------------------*/

Static Function GFEA66STRU(cCmp, nOp)
	Local aStru := {}
	Local oStructX3	:= GFESeekSX():New()

	//Cria array com campos que serão mostrados em tela
	If cCmp == 1 	
		If nOp == 1
			oStructX3:SeekX3("GWL_FILDC")	
			Aadd(aStru,  {"GWL_FILDC"	,"C",oStructX3:getX3Tamanho(),oStructX3:getX3Decimal()})
			oStructX3:SeekX3("GWL_NRDC")	
			Aadd(aStru,  {"GWL_NRDC" 	,"C",oStructX3:getX3Tamanho(),oStructX3:getX3Decimal()})
			oStructX3:SeekX3("GWL_EMITDC")	
			Aadd(aStru,  {"GWL_EMITDC"	,"C",oStructX3:getX3Tamanho(),oStructX3:getX3Decimal()})
			oStructX3:SeekX3("GU3_NMEMIT")	
			Aadd(aStru,  {"GU3_NMEMIT"	,"C",oStructX3:getX3Tamanho(),oStructX3:getX3Decimal()})
			oStructX3:SeekX3("GWL_SERDC")	
			Aadd(aStru,  {"GWL_SERDC"	,"C",oStructX3:getX3Tamanho(),oStructX3:getX3Decimal()})
			oStructX3:SeekX3("GWL_TPDC")	
			Aadd(aStru,  {"GWL_TPDC"	,"C",oStructX3:getX3Tamanho(),oStructX3:getX3Decimal()})
			oStructX3:SeekX3("GWD_FILIAL")	
			Aadd(aStru,  {"GWD_FILIAL"	,"C",oStructX3:getX3Tamanho(),oStructX3:getX3Decimal()})
			oStructX3:SeekX3("GWD_NROCO")	
			Aadd(aStru,  {"GWD_NROCO"	,"C",oStructX3:getX3Tamanho(),oStructX3:getX3Decimal()})
			oStructX3:SeekX3("GWD_DSOCOR")	
			Aadd(aStru,  {"GWD_DSOCOR"	,"M",oStructX3:getX3Tamanho(),oStructX3:getX3Decimal()})
			oStructX3:SeekX3("GWD_CDTIPO")	
			Aadd(aStru,  {"GWD_CDTIPO"	,"C",oStructX3:getX3Tamanho(),oStructX3:getX3Decimal()})
			oStructX3:SeekX3("GU5_DESC")	
			Aadd(aStru,  {"GU5_DESC"	,"C",oStructX3:getX3Tamanho(),oStructX3:getX3Decimal()})
			oStructX3:SeekX3("GWD_CDMOT")	
			Aadd(aStru,  {"GWD_CDMOT"	,"C",oStructX3:getX3Tamanho(),oStructX3:getX3Decimal()})
			oStructX3:SeekX3("GU6_DESC")	
			Aadd(aStru,  {"GU6_DESC"	,"C",oStructX3:getX3Tamanho(),oStructX3:getX3Decimal()})			
			AAdd(aStru, {"GU5_ACAODF", "C", 25, 0})			
			AAdd(aStru, {"GU5_BLQ", "C", 1, 0})					
		ElseIf nOp == 2			
			oStructX3:SeekX3("GWL_FILDC")	
			AAdd(aStru, {"GWL_FILDC"	, Nil, oStructX3:getX3Titulo(),oStructX3:getX3Picture()})
			oStructX3:SeekX3("GWL_NRDC")	
			AAdd(aStru, {"GWL_NRDC"		, Nil, oStructX3:getX3Titulo(),oStructX3:getX3Picture()})
			oStructX3:SeekX3("GWL_EMITDC")	
			AAdd(aStru, {"GWL_EMITDC"	, Nil, oStructX3:getX3Titulo(),oStructX3:getX3Picture()})
			oStructX3:SeekX3("GU3_NMEMIT")	
			AAdd(aStru, {"GU3_NMEMIT"	, Nil, oStructX3:getX3Titulo(),oStructX3:getX3Picture()})
			oStructX3:SeekX3("GWL_SERDC")	
			AAdd(aStru, {"GWL_SERDC"	, Nil, oStructX3:getX3Titulo(),oStructX3:getX3Picture()})
			oStructX3:SeekX3("GWL_TPDC")	
			AAdd(aStru, {"GWL_TPDC"		, Nil, oStructX3:getX3Titulo(),oStructX3:getX3Picture()})
			oStructX3:SeekX3("GWD_FILIAL")	
			AAdd(aStru, {"GWD_FILIAL"	, Nil, oStructX3:getX3Titulo(),oStructX3:getX3Picture()})
			oStructX3:SeekX3("GWD_NROCO")	
			AAdd(aStru, {"GWD_NROCO"	, Nil, oStructX3:getX3Titulo(),oStructX3:getX3Picture()})
			oStructX3:SeekX3("GWD_DSOCOR")	
			AAdd(aStru, {"GWD_DSOCOR"	, Nil, oStructX3:getX3Titulo(),oStructX3:getX3Picture()})
			oStructX3:SeekX3("GWD_CDTIPO")	
			AAdd(aStru, {"GWD_CDTIPO"	, Nil, oStructX3:getX3Titulo(),oStructX3:getX3Picture()})
			oStructX3:SeekX3("GU5_DESC")	
			AAdd(aStru, {"GU5_DESC"		, Nil, oStructX3:getX3Titulo(),oStructX3:getX3Picture()})
			oStructX3:SeekX3("GWD_CDMOT")	
			AAdd(aStru, {"GWD_CDMOT"	, Nil, oStructX3:getX3Titulo(),oStructX3:getX3Picture()})
			oStructX3:SeekX3("GU6_DESC")	
			AAdd(aStru, {"GU6_DESC"		, Nil, oStructX3:getX3Titulo(),oStructX3:getX3Picture()})
			oStructX3:SeekX3("GU5_ACAODF")	
			AAdd(aStru, {"GU5_ACAODF"	, Nil, oStructX3:getX3Titulo(),oStructX3:getX3Picture()})

			AAdd(aStru, {"GU5_BLQ"		, Nil, "Observação",})		
		EndIf
	ElseIf cCmp == 2 	
		If nOp == 1
			oStructX3:SeekX3("GWH_FILIAL")	
			Aadd(aStru,  {"GWH_FILIAL"	,"C",oStructX3:getX3Tamanho(),oStructX3:getX3Decimal()})
			oStructX3:SeekX3("GWH_NRDC")	
			Aadd(aStru,  {"GWH_NRDC" 	,"C",oStructX3:getX3Tamanho(),oStructX3:getX3Decimal()})
			oStructX3:SeekX3("GWH_EMISDC")	
			Aadd(aStru,  {"GWH_EMISDC"	,"C",oStructX3:getX3Tamanho(),oStructX3:getX3Decimal()})
			oStructX3:SeekX3("GU3_NMEMIT")	
			Aadd(aStru,  {"GU3_NMEMIT"	,"C",oStructX3:getX3Tamanho(),oStructX3:getX3Decimal()})
			oStructX3:SeekX3("GWH_SERDC")	
			Aadd(aStru,  {"GWH_SERDC"	,"C",oStructX3:getX3Tamanho(),oStructX3:getX3Decimal()})
			oStructX3:SeekX3("GWH_CDTPDC")	
			Aadd(aStru,  {"GWH_CDTPDC"	,"C",oStructX3:getX3Tamanho(),oStructX3:getX3Decimal()})
		ElseIf nOp == 2			
			oStructX3:SeekX3("GWH_FILIAL")	
			AAdd(aStru, {"GWH_FILIAL"	, Nil, oStructX3:getX3Titulo(),oStructX3:getX3Picture()})
			oStructX3:SeekX3("GWH_NRDC")	
			AAdd(aStru, {"GWH_NRDC"		, Nil, oStructX3:getX3Titulo(),oStructX3:getX3Picture()})
			oStructX3:SeekX3("GWH_EMISDC")	
			AAdd(aStru, {"GWH_EMISDC"	, Nil, oStructX3:getX3Titulo(),oStructX3:getX3Picture()})
			oStructX3:SeekX3("GU3_NMEMIT")	
			AAdd(aStru, {"GU3_NMEMIT"	, Nil, oStructX3:getX3Titulo(),oStructX3:getX3Picture()})
			oStructX3:SeekX3("GWH_SERDC")	
			AAdd(aStru, {"GWH_SERDC"	, Nil, oStructX3:getX3Titulo(),oStructX3:getX3Picture()})
			oStructX3:SeekX3("GWH_CDTPDC")	
			AAdd(aStru, {"GWH_CDTPDC"	, Nil, oStructX3:getX3Titulo(),oStructX3:getX3Picture()})			
		EndIf	
	ElseIf cCmp == 3	
		If nOp == 1
			oStructX3:SeekX3("GW4_FILIAL")	
			Aadd(aStru,  {"GW4_FILIAL"	,"C",oStructX3:getX3Tamanho(),oStructX3:getX3Decimal()})
			oStructX3:SeekX3("GW4_NRDC")	
			Aadd(aStru,  {"GW4_NRDC" 	,"C",oStructX3:getX3Tamanho(),oStructX3:getX3Decimal()})
			oStructX3:SeekX3("GW4_EMISDC")	
			Aadd(aStru,  {"GW4_EMISDC"	,"C",oStructX3:getX3Tamanho(),oStructX3:getX3Decimal()})
			oStructX3:SeekX3("GU3_NMEMIT")	
			Aadd(aStru,  {"GU3_NMEMIT"	,"C",oStructX3:getX3Tamanho(),oStructX3:getX3Decimal()})
			oStructX3:SeekX3("GW4_SERDC")	
			Aadd(aStru,  {"GW4_SERDC"	,"C",oStructX3:getX3Tamanho(),oStructX3:getX3Decimal()})
			oStructX3:SeekX3("GW4_TPDC")	
			Aadd(aStru,  {"GW4_TPDC"	,"C",oStructX3:getX3Tamanho(),oStructX3:getX3Decimal()})
		ElseIf nOp == 2			
			oStructX3:SeekX3("GW4_FILIAL")	
			AAdd(aStru, {"GW4_FILIAL"	, Nil, oStructX3:getX3Titulo(),oStructX3:getX3Picture()})
			oStructX3:SeekX3("GW4_NRDC")	
			AAdd(aStru, {"GW4_NRDC"		, Nil, oStructX3:getX3Titulo(),oStructX3:getX3Picture()})
			oStructX3:SeekX3("GW4_EMISDC")	
			AAdd(aStru, {"GW4_EMISDC"	, Nil, oStructX3:getX3Titulo(),oStructX3:getX3Picture()})
			oStructX3:SeekX3("GU3_NMEMIT")	
			AAdd(aStru, {"GU3_NMEMIT"	, Nil, oStructX3:getX3Titulo(),oStructX3:getX3Picture()})
			oStructX3:SeekX3("GW4_SERDC")	
			AAdd(aStru, {"GW4_SERDC"	, Nil, oStructX3:getX3Titulo(),oStructX3:getX3Picture()})
			oStructX3:SeekX3("GW4_TPDC")	
			AAdd(aStru, {"GW4_TPDC"		, Nil, oStructX3:getX3Titulo(),oStructX3:getX3Picture()})			
		EndIf	
	ElseIf cCmp == 4 	
		If nOp == 1
			oStructX3:SeekX3("GWF_FILIAL")	
			Aadd(aStru,  {"GWF_FILIAL"	,"C",oStructX3:getX3Tamanho(),oStructX3:getX3Decimal()})
			oStructX3:SeekX3("GWF_NRCALC")	
			Aadd(aStru,  {"GWF_NRCALC" 	,"C",oStructX3:getX3Tamanho(),oStructX3:getX3Decimal()})
			oStructX3:SeekX3("GWI_VLFRET")	
			Aadd(aStru,  {"GWI_VLFRET"	,"N",oStructX3:getX3Tamanho(),oStructX3:getX3Decimal()})
			oStructX3:SeekX3("GWF_TPCALC")	
			Aadd(aStru,  {"GWF_TPCALC"	,"C",oStructX3:getX3Tamanho(),oStructX3:getX3Decimal()})
			oStructX3:SeekX3("GWF_ORIGEM")	
			Aadd(aStru,  {"GWF_ORIGEM"	,"C",oStructX3:getX3Tamanho(),oStructX3:getX3Decimal()})
			oStructX3:SeekX3("GWF_FINCAL")	
			Aadd(aStru,  {"GWF_FINCAL"	,"C",oStructX3:getX3Tamanho(),oStructX3:getX3Decimal()})
			oStructX3:SeekX3("GWF_NRROM")	
			Aadd(aStru,  {"GWF_NRROM"	,"C",oStructX3:getX3Tamanho(),oStructX3:getX3Decimal()})
			oStructX3:SeekX3("GWF_TPTRIB")	
			Aadd(aStru,  {"GWF_TPTRIB"	,"C",oStructX3:getX3Tamanho(),oStructX3:getX3Decimal()})
			oStructX3:SeekX3("GWF_IMPOST")	
			Aadd(aStru,  {"GWF_IMPOST"	,"C",oStructX3:getX3Tamanho(),oStructX3:getX3Decimal()})
			oStructX3:SeekX3("GWF_VLISS")	
			Aadd(aStru,  {"GWF_VLISS"	,"N",oStructX3:getX3Tamanho(),oStructX3:getX3Decimal()})
			oStructX3:SeekX3("GWF_VLICMS")	
			Aadd(aStru,  {"GWF_VLICMS"	,"N",oStructX3:getX3Tamanho(),oStructX3:getX3Decimal()})				
		ElseIf nOp == 2			
			oStructX3:SeekX3("GWF_FILIAL")	
			AAdd(aStru, {"GWF_FILIAL"	, Nil, oStructX3:getX3Titulo(),oStructX3:getX3Picture()})
			oStructX3:SeekX3("GWF_NRCALC")	
			AAdd(aStru, {"GWF_NRCALC"	, Nil, oStructX3:getX3Titulo(),oStructX3:getX3Picture()})
			oStructX3:SeekX3("GWI_VLFRET")	
			AAdd(aStru, {"GWI_VLFRET"	, Nil, oStructX3:getX3Titulo(),oStructX3:getX3Picture()})
			oStructX3:SeekX3("GWF_TPCALC")	
			AAdd(aStru, {"GWF_TPCALC"	, Nil, oStructX3:getX3Titulo(),oStructX3:getX3Picture()})
			oStructX3:SeekX3("GWF_ORIGEM")	
			AAdd(aStru, {"GWF_ORIGEM"	, Nil, oStructX3:getX3Titulo(),oStructX3:getX3Picture()})
			oStructX3:SeekX3("GWF_FINCAL")	
			AAdd(aStru, {"GWF_FINCAL"	, Nil, oStructX3:getX3Titulo(),oStructX3:getX3Picture()})
			oStructX3:SeekX3("GWF_NRROM")	
			AAdd(aStru, {"GWF_NRROM"	, Nil, oStructX3:getX3Titulo(),oStructX3:getX3Picture()})
			oStructX3:SeekX3("GWF_TPTRIB")	
			AAdd(aStru, {"GWF_TPTRIB"	, Nil, oStructX3:getX3Titulo(),oStructX3:getX3Picture()})
			oStructX3:SeekX3("GWF_IMPOST")	
			AAdd(aStru, {"GWF_IMPOST"	, Nil, oStructX3:getX3Titulo(),oStructX3:getX3Picture()})
			oStructX3:SeekX3("GWF_VLISS")	
			AAdd(aStru, {"GWF_VLISS"	, Nil, oStructX3:getX3Titulo(),oStructX3:getX3Picture()})
			oStructX3:SeekX3("GWF_VLICMS")	
			AAdd(aStru, {"GWF_VLICMS"	, Nil, oStructX3:getX3Titulo(),oStructX3:getX3Picture()})
		EndIf			
	EndIf	
	oStructX3:Destroy(oStructX3)


Return aStru

//----------------------------------------------------------------------------------------------------

Static Function GFEA66CPYD(cAliDe, cAliPara, aCmp)
	Local nCount	

	dbSelectArea(cAliDe)
	(cAliDe)->( dbGoTop() )
	While !(cAliDe)->( Eof() )
		RecLock(cAliPara, .T.)

		For nCount := 1 To Len(aCmp)

			(cAliPara)->&(aCmp[nCount]) := (cAliDe)->&(aCmp[nCount])

		Next nCount
		(cAliPara)->(MsUnLock())

		dbSelectArea(cAliDe)
		(cAliDe)->( dbSkip() )
	EndDo

	dbSelectArea(cAliPara)
	(cAliPara)->( dbGoTop() )

	GFEDelTab(cAliDe)

Return

//----------------------------------------------------------------------------------------------------

Static Function GFEA66DCBK()
	Local aAreaDCDF := (cDCDF)->( GetArea() )

	dbSelectArea(cDCDF)
	(cDCDF)->( dbSetOrder(1) )
	If !(cDCDF)->( dbSeek(xFilial("GWF") + (cDCCL)->GWH_EMISDC + (cDCCL)->GWH_CDTPDC + (cDCCL)->GWH_SERDC + (cDCCL)->GWH_NRDC ) )
		RestArea(aAreaDCDF)
		Return .T.
	EndIf 

	RestArea(aAreaDCDF)	

Return .F.

/*----------------------------------------------------------------------------------------------------
{Protheus.doc} GFEA066AP
Mostra uma tela com as diferenças dos valores do Documento de Frete com opção para aprovar os valores 
informando o motivo

@sample
GFEA066AP(.T.)

@param lMotivo	Mostra o campo motivo para aprovar os valores mostrados

@author Israel A. Possoli
@since 03/07/2010
@version 1.0
----------------------------------------------------------------------------------------------------*/

Function GFEA066AP(lMotivo)
	Local aNewButton := {{"",{|| GFEA066CCa() },"Cons. Cálculo"},{"",{|| GFEA066Ta() },"Cons. Taxas"}}	
	Local aMKB
	Local aCpMKB
	Local aCpOcor
	Local aTmp 
	Local cQuery := ""
	Local oPnlCnt
	Local oSize
	Local aPos
	Local lExecFilt := .F.
	Local s_GFEA0663 := ExistBlock("GFEA0663")
	Local aCombo := {"1=Sim","2=Não"}
	Local oCombo

	Private cAliMKB
	Private cAliTaxa
	Private cAliCalc
	Private cAliDCDF
	Private cAliDCCL
	Private cAliOcor
	Private cCalc
	Private cDCDF
	Private cDCCL
	Private cOcor
	Private cMemo      	:= ''
	Private oFolder	   	:= Nil
	Private oDlgGFEA66 	:= Nil
	Private cMarca     	:= GetMark()
	Private aCalc 		:= {"GWF_FILIAL", "GWF_NRCALC", "GWI_VLFRET", "GWF_TPCALC", "GWF_ORIGEM", "GWF_FINCAL", "GWF_NRROM", "GWF_TPTRIB", "GWF_IMPOST","GWF_VLISS", "GWF_VLICMS"}
	Private aDCDF 		:= {"GW4_FILIAL", "GW4_NRDC", "GW4_EMISDC", "GU3_NMEMIT", "GW4_SERDC", "GW4_TPDC"}
	Private aDCCL 		:= {"GWH_FILIAL", "GWH_NRDC", "GWH_EMISDC", "GU3_NMEMIT", "GWH_SERDC", "GWH_CDTPDC"}
	Private aOcor 		:= {"GWL_FILDC", "GWL_NRDC", "GWL_EMITDC", "GU3_NMEMIT", "GWL_SERDC", "GWL_TPDC", "GWD_FILIAL", "GWD_NROCO", "GWD_DSOCOR", "GWD_CDTIPO", "GU5_DESC", "GWD_CDMOT", "GU6_DESC", "GU5_ACAODF", "GU5_BLQ"}

	Private lLoadDocRelac := .F.
	Private cSitTab := SuperGetMV("MV_GFEDCFA", .F., "2")

	aTmp := Array(Len(aOcor)-1)

	CursorWait()

	//------CONFERÊNCIA

	aMKB :=    {{"OBRIGAT" ,"C",01,0},;
	{"CAMPO"   ,"C",35,0},;
	{"VALOR1"  ,"N",18,8},;
	{"VALOR2"  ,"N",18,8},;
	{"DIF"     ,"N",18,8}}

	aCpMKB  := {{"OBRIGAT" ,NIL,"O",""},;
	{"CAMPO"   ,NIL,STR0005,""},; //"Campo"
	{"VALOR1"  ,NIL,"Informado","@E 999,999,999.99999999"},; //"Informado"
	{"VALOR2"  ,NIL,"Calculado","@E 999,999,999.99999999"},; //"Calculado"
	{"DIF"     ,NIL,STR0008,"@E 999,999,999.99999999"}} //"Diferença"

	cAliMKB := GFECriaTab({ aMKB,{"OBRIGAT"} })
	cOcor := GFECriaTab( {GFEA66STRU(1, 1), {"GWD_FILIAL+GWL_FILDC+GWL_NRDC+GWL_EMITDC+GWL_SERDC+GWL_TPDC"}})


	//------OCORRÊNCIAS
	ACopy(aOcor, aTmp, 1, Len(aOcor)-1)

	aCpOcor := GFEA66STRU(1,2)

	cAliOcor := GetNextAlias()

	cQuery := "SELECT GWL.GWL_FILDC, GWL.GWL_NRDC, GWL.GWL_EMITDC, "
	cQuery += "		(SELECT GU3.GU3_NMEMIT FROM " + RetSQLName("GU3") + " GU3 "
	cQuery += "			WHERE GU3.GU3_FILIAL = '" + xFilial("GU3") + "' AND GU3.GU3_CDEMIT = GWL.GWL_EMITDC AND GU3.D_E_L_E_T_ = ' ' "
	cQuery += "		) GU3_NMEMIT, "
	If TcGetDb() == 'ORACLE'
		cQuery += "		GWL.GWL_SERDC, GWL." + SerieNfId("GWL",3,"GWL_SERDC") + ", GWL.GWL_TPDC, GWD.GWD_FILIAL, GWD.GWD_NROCO, UTL_RAW.CAST_TO_VARCHAR2(DBMS_LOB.SUBSTR(GWD.GWD_DSOCOR, 3200,0))  AS GWD_DSOCOR,GWD.GWD_CDTIPO, "
	ElseIf TcGetDb() == 'POSTGRES'
		cQuery += "		GWL.GWL_SERDC, GWL." + SerieNfId("GWL",3,"GWL_SERDC") + ", GWL.GWL_TPDC, GWD.GWD_FILIAL, GWD.GWD_NROCO, CAST(GWD.GWD_DSOCOR AS VARCHAR)  AS  GWD_DSOCOR ,GWD.GWD_CDTIPO, " 
	Else
		cQuery += "		GWL.GWL_SERDC, GWL." + SerieNfId("GWL",3,"GWL_SERDC") + ", GWL.GWL_TPDC, GWD.GWD_FILIAL, GWD.GWD_NROCO, ISNULL(CONVERT(VARCHAR(2047), CONVERT(VARBINARY(2047), GWD.GWD_DSOCOR)),'') AS GWD_DSOCOR,GWD.GWD_CDTIPO, "
	EndIf
	cQuery += "		GU5.GU5_DESC, GWD.GWD_CDMOT, GU6.GU6_DESC, GU5.GU5_ACAODF GU5_BLQ, "
	cQuery += 		GFEA66CASE("GU5", "GU5_ACAODF", "GU5_ACAODF", "'Nenhum'") + " "
	cQuery += "FROM " + RetSQLName("GWL") + " GWL "
	cQuery += "		INNER JOIN " + RetSQLName("GWD") + " GWD ON GWD.GWD_FILIAL = GWL.GWL_FILIAL AND GWD.GWD_NROCO = GWL.GWL_NROCO "
	cQuery += "		INNER JOIN " + RetSQLName("GU5") + " GU5 ON GU5.GU5_CDTIPO = GWD.GWD_CDTIPO "
	cQuery += "		INNER JOIN " + RetSQLName("GU6") + " GU6 ON GU6.GU6_CDMOT = GWD.GWD_CDMOT "
	cQuery += "WHERE "	
	cQuery += "		GWL.GWL_FILDC || GWL.GWL_NRDC || GWL.GWL_EMITDC || GWL.GWL_SERDC || GWL.GWL_TPDC IN "
	cQuery += "		(SELECT (GW4.GW4_FILIAL || GW4.GW4_NRDC || GW4.GW4_EMISDC || GW4.GW4_SERDC || GW4.GW4_TPDC)  as CHAVE "
	cQuery += "		 FROM " + RetSQLName("GW4") + " GW4 "
	cQuery += "		 WHERE GW4.GW4_FILIAL = '" + xFilial("GW4") + "' AND GW4.GW4_CDESP = '" + GW3->GW3_CDESP + "'" 
	cQuery += "         AND GW4.GW4_EMISDF = '" + GW3->GW3_EMISDF + "' AND GW4.GW4_SERDF = '" + GW3->GW3_SERDF + "'"
	cQuery += "         AND GW4.GW4_NRDF = '" + GW3->GW3_NRDF + "' AND GW4.GW4_DTEMIS = '" + DTOS(GW3->GW3_DTEMIS) + "'" 
	cQuery += "		   	AND GW4.D_E_L_E_T_ = ' ' "
	cQuery += "		) "
	cQuery += "		AND GWL.D_E_L_E_T_ = ' ' AND GWD.D_E_L_E_T_ = ' ' "
	cQuery += "ORDER BY GWL.GWL_FILDC, GWL.GWL_NRDC "

	cQuery := ChangeQuery(cQuery)
	dbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery), cAliOcor, .F., .T.)

	//-----------------
	oSize := FWDefSize():New(.T.)
	oSize:AddObject( "ENCHOICE", 100, 60, .T., .T. ) // Adiciona enchoice
	oSize:SetWindowSize({000, 000, 520,900})
	oSize:lLateral     := .F.  // Calculo vertical	
	oSize:Process() //executa os calculos

	//Array com as posições dinamicas se quiser alterar o tamnho da tela é so alterar o tamanho do SetWindowSize
	aPos := {oSize:GetDimension("ENCHOICE","LININI"),; 
	oSize:GetDimension("ENCHOICE","COLINI"),;
	oSize:GetDimension("ENCHOICE","XSIZE"),;
	oSize:GetDimension("ENCHOICE","YSIZE")}

	//"Aprovação de Documento de Frete"	
	DEFINE MSDIALOG oDlgGFEA66 TITLE STR0001 ;
	FROM oSize:aWindSize[1],oSize:aWindSize[2] ;
	TO oSize:aWindSize[3],oSize:aWindSize[4] ; 
	Of oMainWnd COLORS 0, 16777215 PIXEL
	oDlgGFEA66:lEscClose := .F.

	oPnlCnt := tPanel():New(aPos[1],aPos[2],,oDlgGFEA66,,,,,,aPos[3],aPos[4],.F.,.F.)

	oPnlA := tPanel():New(00,00,,oPnlCnt,,,,,,10,20,.F.,.F.)
	oPnlA:Align := CONTROL_ALIGN_TOP

	/* Folders */
	If lMotivo
		oFolder := TFolder():New(0,0,{STR0010, "Documentos", "Ocorrências", STR0011},{"HEADER 1", "HEADER 2", "HEADER 3", "HEADER 4"},oPnlCnt,,,,.T.,,10,10,) //"Diferenças"###"Observações"
	Else
		oFolder := TFolder():New(0,0,{STR0010, "Documentos", "Ocorrências"},{"HEADER 1", "HEADER 2", "HEADER 3"},oPnlCnt,,,,.T.,,10,10,) //"Diferenças"###"Observações"
	EndIf

	oFolder:bSetOption := {|nFolSel| IIF(nFolSel==2, LoadDocRelac(), Nil ) }   

	oFolder:Align := CONTROL_ALIGN_ALLCLIENT

	oPanelB := TPanel():New(01,01,,oFolder:ADialogs[1],,,,,,0,0,.F.,.T.)
	oPanelB:Align := CONTROL_ALIGN_ALLCLIENT

	If lMotivo
		oPanelD := TPanel():New(01,01,,oFolder:ADialogs[4],,,,,,0,0,.F.,.T.)
		oPanelD:Align := CONTROL_ALIGN_ALLCLIENT
	EndIf

	// ----- Criacao dos fields referente ao romaneio no painel superior da tela principal -----//
	cDSTRAN := posicione("GU3",1,xFilial("GU3")+GW3->GW3_EMISDF,"GU3_NMEMIT")
	@ 07,10  Say STR0012 Of oPnlA COLOR CLR_BLACK Pixel //"Filial: "
	@ 05,25  MSGET GW3->GW3_FILIAL Picture "@!" Of oPnlA When .F. SIZE 40,10  Pixel

	@ 07,72  Say STR0013 Of oPnlA COLOR CLR_BLACK Pixel //"Espécie: "                        
	@ 05,96 MSGET GW3->GW3_CDESP Picture "@!" Of oPnlA When .F.  SIZE 55,10  Pixel

	@ 07,167 Say STR0014            Of oPnlA COLOR CLR_BLACK Pixel //"Emissor: "
	@ 05,190 MSGET GW3->GW3_EMISDF  Picture "@!" Of oPnlA When .F.   SIZE 80,10 Pixel
	@ 05,270 MSGET cDSTRAN Picture "@!" Of oPnlA When .F. SIZE 150,10 Pixel

	// Início Ponto de Entrada
	If s_GFEA0663
		ExecBlock("GFEA0663",.f.,.f.,{oPnlA,oPanelB})
	EndIf
	// Fim Ponto de Entrada	


	//---------Fim da criacao dos fields ----------//	

	//--1----- Seleciona a temp-table de Documentos de cargas que nao foram relacionados ao romaneio e cria o browse -----// 	
	dbSelectArea(cAliMKB)
	dbSetOrder(01)
	dbGoTop()
	oMark := MsSelect():New(cAliMKB,"",,aCpMKB,,@cMarca,{0,0,0,0},,,oPanelB)
	oMark:oBrowse:cToolTip := STR0015 //"Documentos de Carga"
	oMark:oBrowse:Align := CONTROL_ALIGN_ALLCLIENT
	oMark:oBrowse:SetBlkBackColor({|| if(AbaixoTol(),RGB(255,128,128),RGB(254,254,254))})

	//--------------Fim 1 -- criado o browse---------------//

	//----OCORRÊNCIAS

	oPanelG := TPanel():New(01,01,,oFolder:aDialogs[3],,,,,,30,30,.F.,.T.)
	oPanelG:Align := CONTROL_ALIGN_ALLCLIENT

	dbSelectArea(cOcor)
	(cOcor)->( dbSetOrder(1) )
	(cOcor)->( dbGoTop() )
	cGrdOcor := MsSelect():New(cOcor,"",,aCpOcor,,/*@cMarcaF*/,{0,0,0,0},,,oPanelG)
	cGrdOcor:oBrowse:cToolTip := "Ocorrências dos Documentos de Carga dos Documentos de Frete." //
	cGrdOcor:oBrowse:Align := CONTROL_ALIGN_ALLCLIENT
	cGrdOcor:oBrowse:SetBlkBackColor({|| IIf((cOcor)->GU5_BLQ == "3",RGB(255,128,128),)})

	cGrdOcor:oBrowse:lVisibleControl := .T.
	cGrdOcor:oBrowse:lVisible := .T.
	//cGrdOcor:oBrowse:nHeight  := 251
	cGrdOcor:oBrowse:nRight   := 80
	cGrdOcor:oBrowse:nWidth   := 80

	//----*FIM* OCORRÊNCIAS

	//----Observações---- 

	If lMotivo

		If GFXCP12127("GW3_SITDIV")
			@ 20,15 Say "Controla Compensação de Divergências"   Of oPanelD COLOR CLR_BLACK Pixel  
			@ 30,15 COMBOBOX oCombo VAR cSitTab ITEMS aCombo SIZE 070, 010 OF oPanelD PIXEL		
		Endif

		@ 45,15 Say STR0016   Of oPanelD COLOR CLR_BLACK Pixel  //"Motivo para Aprovação:"
		@ 55,15 GET oMemo VAR cMemo MEMO SIZE 230,70 OF oPanelD PIXEL 
		oMemo:bRClicked := {||AllwaysTrue()}

	EndIf

	//----- Processa os registros e carrega os browses -----//
	Processa({|lEnd| GFE066MKB()},STR0017,STR0018) //"Processando informações"###"Aguarde"
	CursorArrow()

	dbSelectArea(cAliMKB)
	dbGoTOp()

	oMark:oBrowse:nAtCol(2,.F.)

	ACTIVATE MSDIALOG oDlgGFEA66 ON INIT (EnchoiceBar(oDlgGFEA66,{||Iif(GFEA066OK(lMotivo),(lExecFilt := .T.,oDlgGFEA66:End()),NIL)},;
	{||oDlgGFEA66:End()},,aNewButton),oMark:oBrowse:Gotop()) CENTERED

	GFEDelTab(cAliMKB)
	GFEDelTab(cOcor)

	If lLoadDocRelac
		GFEDelTab(cDCDF)
		GFEDelTab(cDCCL)
		GFEDelTab(cCalc)
	EndIf

Return .T.


Static Function LoadDocRelac()
	Local aCpCalc
	Local aCpDCDF
	Local aCpDCCL
	Local lExistCamp:= GFXCP12116("GWF","GWF_CDESP") .And. (SuperGetMV("MV_DPSERV", .F., "1") == "1") .And. GFEA065VFIX()

	If lLoadDocRelac
		Return
	EndIf

	oFolder:aDialogs[2]:cTitle := "Carregando..."
	oFolder:aDialogs[2]:Refresh()

	CursorWait()

	ProcessMessage()

	cDCDF := GFECriaTab( {GFEA66STRU(3, 1), {"GW4_FILIAL+GW4_EMISDC+GW4_TPDC+GW4_SERDC+GW4_NRDC"}})
	cDCCL := GFECriaTab( {GFEA66STRU(2, 1), {"GWH_FILIAL+GWH_EMISDC+GWH_CDTPDC+GWH_SERDC+GWH_NRDC"}})
	cCalc := GFECriaTab( {GFEA66STRU(4, 1), {"GWF_FILIAL+GWF_NRCALC"}})

	aCpCalc := GFEA66STRU(4,2)

	cAliCalc := GetNextAlias()

	If lExistCamp // Utiliza o novo índice para pesquisar o cálculo
		cQuery := " SELECT GWF.GWF_FILIAL, 
		cQuery += "        GWF.GWF_NRCALC, " 
		cQuery += "	 	 (SELECT SUM(GWI_VLFRET) 
		cQuery += "          FROM " + RetSQLName("GWI") + " GWI "
		cQuery += "	 	   WHERE GWI.GWI_FILIAL = '" + xFilial("GWI") + "'"
		cQuery += "           AND GWI.GWI_NRCALC = GWF.GWF_NRCALC 
		cQuery += "           AND GWI.GWI_TOTFRE = '1' "
		cQuery += "           AND GWI.D_E_L_E_T_ = ' ' "
		cQuery += "	 	   GROUP BY GWI.GWI_NRCALC "
		cQuery += "         ) + GWF.GWF_VLAJUS AS GWI_VLFRET, "	
		cQuery += 	 	GFEA66CASE("GWF", "GWF_TPCALC", "GWF_TPCALC", "'Nenhum'") + ", "
		cQuery += 	 	GFEA66CASE("GWF", "GWF_ORIGEM", "GWF_ORIGEM", "'Nenhum'") + ", "
		cQuery += 	 	GFEA66CASE("GWF", "GWF_FINCAL", "GWF_FINCAL", "'Nenhum'") + ", "
		cQuery += 	"      GWF.GWF_NRROM, "
		cQuery += 	 	GFEA66CASE("GWF", "GWF_TPTRIB", "GWF_TPTRIB", "'Nenhum'") + ", "
		cQuery += 	 	GFEA66CASE("GWF", "GWF_IMPOST", "GWF_IMPOST", "'Nenhum'") + ", "
		cQuery += "        GWF.GWF_VLISS,
		cQuery += "        GWF.GWF_VLICMS "
		cQuery += "   FROM " + RetSQLName("GWF") + " GWF "
		cQuery += "  WHERE GWF.GWF_FILIAL = '"+xFilial('GWF')+"'"
		cQuery += "    AND GWF.GWF_CDESP  = '"+GW3->GW3_CDESP+"'"
		cQuery += "    AND GWF.GWF_EMISDF = '"+GW3->GW3_EMISDF+"'"
		cQuery += "    AND GWF.GWF_SERDF  = '"+GW3->GW3_SERDF+"'"
		cQuery += "    AND GWF.GWF_NRDF   = '"+GW3->GW3_NRDF+"'"
		cQuery += "    AND GWF.GWF_DTEMDF = '"+DTOS(GW3->GW3_DTEMIS)+"'"
		cQuery += "    AND GWF.D_E_L_E_T_ = ' '"
		cQuery += "  ORDER BY GWF.GWF_NRCALC "
	Else	
		cQuery := "SELECT DISTINCT GWF.GWF_FILIAL, GWF.GWF_NRCALC, " 
		cQuery += "		(SELECT SUM(GWI_VLFRET) FROM " + RetSQLName("GWI") + " GWI "
		cQuery += "			WHERE GWI.GWI_FILIAL = '" + xFilial("GWI") + "' AND GWI.GWI_NRCALC = GWF.GWF_NRCALC AND GWI.GWI_TOTFRE = '1' "
		cQuery += "         AND GWI.D_E_L_E_T_ = ' ' "
		cQuery += "			GROUP BY GWI.GWI_NRCALC "
		cQuery += "     ) + GWF.GWF_VLAJUS AS GWI_VLFRET, "	
		cQuery += 		GFEA66CASE("GWF", "GWF_TPCALC", "GWF_TPCALC", "'Nenhum'") + ", "
		cQuery += 		GFEA66CASE("GWF", "GWF_ORIGEM", "GWF_ORIGEM", "'Nenhum'") + ", "
		cQuery += 		GFEA66CASE("GWF", "GWF_FINCAL", "GWF_FINCAL", "'Nenhum'") + ", "
		cQuery += 		"GWF.GWF_NRROM, "
		cQuery += 		GFEA66CASE("GWF", "GWF_TPTRIB", "GWF_TPTRIB", "'Nenhum'") + ", "
		cQuery += 		GFEA66CASE("GWF", "GWF_IMPOST", "GWF_IMPOST", "'Nenhum'") + ", "
		cQuery += 		"GWF.GWF_VLISS, GWF.GWF_VLICMS "
		cQuery += "FROM " + RetSQLName("GWF") + " GWF "
		cQuery += "		INNER JOIN " + RetSQLName("GWH") + " GWH ON GWH.GWH_FILIAL = '" + xFilial("GWH") + "' AND GWH.GWH_NRCALC = GWF.GWF_NRCALC "	
		cQuery += "		INNER JOIN " + RetSQLName("GW4") + " GW4 ON GW4.GW4_FILIAL = '" + xFilial("GW4") + "' AND GW4.GW4_TPDC = GWH.GWH_CDTPDC AND GW4.GW4_EMISDC = GWH.GWH_EMISDC "
		cQuery += "											 AND GW4.GW4_SERDC = GWH.GWH_SERDC AND GW4.GW4_NRDC = GWH.GWH_NRDC "
		cQuery += "WHERE GW4.GW4_FILIAL = '" + xFilial("GW4") + "' AND GW4.GW4_CDESP = '" + GW3->GW3_CDESP + "' AND GW4.GW4_EMISDF = '" + GW3->GW3_EMISDF + "' AND GW4.GW4_SERDF = '" + GW3->GW3_SERDF + "' AND GW4.GW4_NRDF = '" + GW3->GW3_NRDF + "' AND GW4.GW4_DTEMIS = '" + DTOS(GW3->GW3_DTEMIS) + "'" 
		cQuery += "		 AND GWF.GWF_FILIAL = '" + xFilial("GWF") + "' AND  GWF.GWF_TPCALC = '" + GW3->GW3_TPDF + "' "
		cQuery += "		 AND GWF.D_E_L_E_T_ = ' ' AND GWH.D_E_L_E_T_ = ' ' AND GW4.D_E_L_E_T_ = ' ' "
		cQuery += "ORDER BY GWF.GWF_NRCALC "
	EndIf
	cQuery := ChangeQuery(cQuery)
	dbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery), cAliCalc, .F., .T.)

	//----- DC'S DO DOCUMENTO DE FRETE

	aCpDCDF := GFEA66STRU(3,2)

	cAliDCDF := GetNextAlias()

	cQuery := "SELECT GW4.GW4_FILIAL, GW4.GW4_NRDC, GW4.GW4_EMISDC, "
	cQuery += "		(SELECT GU3.GU3_NMEMIT FROM " + RetSQLName("GU3") + " GU3 "
	cQuery += " 		WHERE GU3.GU3_FILIAL = '" + xFilial("GU3") + "' AND GU3.GU3_CDEMIT = GW4.GW4_EMISDC AND GU3.D_E_L_E_T_ = ' ' "
	cQuery += "		) GU3_NMEMIT, "
	cQuery += "		GW4.GW4_SERDC, GW4." + SerieNfId("GW4",3,"GW4_SERDC") + ", GW4.GW4_TPDC "
	cQuery += "FROM " + RetSQLName("GW4") + " GW4 "
	cQuery += "WHERE GW4.GW4_FILIAL = '" + xFilial("GW4") + "' AND GW4.GW4_CDESP = '" + GW3->GW3_CDESP + "' AND GW4.GW4_EMISDF = '" + GW3->GW3_EMISDF + "' AND GW4.GW4_SERDF = '" + GW3->GW3_SERDF + "' AND GW4.GW4_NRDF = '" + GW3->GW3_NRDF + "' AND GW4.GW4_DTEMIS = '" + DTOS(GW3->GW3_DTEMIS) + "'"
	cQuery += "		AND GW4.D_E_L_E_T_ = ' ' AND GW4.GW4_FILIAL = '" + xFilial("GW4") + "' "
	cQuery += "ORDER BY GW4.GW4_FILIAL, GW4.GW4_NRDC "

	cQuery := ChangeQuery(cQuery)
	dbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery), cAliDCDF, .F., .T.)

	//----- DC'S DO CáLCULO DE FRETE

	aCpDCCL := GFEA66STRU(2,2)

	cAliDCCL := GetNextAlias()

	If lExistCamp // Utiliza o novo índice para pesquisar o cálculo
		cQuery := " SELECT DISTINCT GWH.GWH_FILIAL," 
		cQuery += "        GWH.GWH_NRDC," 
		cQuery += "        GWH.GWH_EMISDC,"
		cQuery += "		 (SELECT GU3.GU3_NMEMIT" 
		cQuery += " 	  	    FROM "+RetSQLName("GU3")+" GU3"
		cQuery += "		   WHERE GU3.GU3_FILIAL = '"+xFilial("GU3")+"'"
		cQuery += "           AND GU3.GU3_CDEMIT = GWH.GWH_EMISDC"
		cQuery += "           AND GU3.D_E_L_E_T_ = ' '"
		cQuery += "		  )GU3_NMEMIT,"
		cQuery += "		  GWH.GWH_SERDC, GWH." + SerieNfId("GWH",3,"GWH_SERDC") + "," 
		cQuery += "  		  GWH.GWH_CDTPDC"
		cQuery += "   FROM "+RetSQLName("GWH")+" GWH"
		cQuery += "  WHERE GWH.D_E_L_E_T_ = ' ' 
		cQuery += "    AND GWH.GWH_FILIAL = '"+xFilial("GWH")+"'"
		cQuery += "    AND GWH.GWH_NRCALC IN"
		cQuery += "		  ("
		cQuery += "         SELECT GWF.GWF_NRCALC"
		cQuery += "           FROM "+RetSqlName('GWF')+" GWF" 
		cQuery += "          WHERE GWF.GWF_FILIAL = '"+xFilial('GWF')+"'"
		cQuery += "            AND GWF.GWF_CDESP  = '"+GW3->GW3_CDESP+"'"
		cQuery += "            AND GWF.GWF_EMISDF = '"+GW3->GW3_EMISDF+"'"
		cQuery += "            AND GWF.GWF_SERDF  = '"+GW3->GW3_SERDF+"'"
		cQuery += "            AND GWF.GWF_NRDF   = '"+GW3->GW3_NRDF+"'"
		cQuery += "            AND GWF.GWF_DTEMDF = '"+DTOS(GW3->GW3_DTEMIS)+"'"
		cQuery += "            AND GWF.D_E_L_E_T_ = ' '"
		cQuery += "		   )"
		cQuery += "  ORDER BY GWH.GWH_FILIAL, GWH.GWH_NRDC"
	Else 
		cQuery := "SELECT GWH.GWH_FILIAL, GWH.GWH_NRDC, GWH.GWH_EMISDC, "
		cQuery += "		(SELECT GU3.GU3_NMEMIT FROM " + RetSQLName("GU3") + " GU3 "
		cQuery += "			WHERE GU3.GU3_FILIAL = '" + xFilial("GU3") + "' AND GU3.GU3_CDEMIT = GWH.GWH_EMISDC AND GU3.D_E_L_E_T_ = ' ' "
		cQuery += "		) GU3_NMEMIT, "
		cQuery += "		GWH.GWH_SERDC, GWH." + SerieNfId("GWH",3,"GWH_SERDC") + ", GWH.GWH_CDTPDC "
		cQuery += "FROM " + RetSQLName("GWH") + " GWH "
		cQuery += "WHERE GWH.D_E_L_E_T_ = ' ' AND GWH.GWH_FILIAL = '" + xFilial("GWH") + "' AND GWH.GWH_NRCALC IN "
		cQuery += "		 (SELECT DISTINCT GWF.GWF_NRCALC "
		cQuery += "		  FROM " + RetSQLName("GWF") + " GWF "
		cQuery += "			INNER JOIN " + RetSQLName("GWH") + " GWHSUB ON GWHSUB.GWH_FILIAL = '" + xFilial("GWH") + "' AND GWHSUB.GWH_NRCALC = GWF.GWF_NRCALC "
		cQuery += "			INNER JOIN " + RetSQLName("GW4") + " GW4 ON GW4.GW4_FILIAL = '" + xFilial("GW4") + "' AND GW4.GW4_TPDC = GWHSUB.GWH_CDTPDC "
		cQuery += " 													   AND GW4.GW4_EMISDC = GWHSUB.GWH_EMISDC AND GW4.GW4_SERDC = GWHSUB.GWH_SERDC
		cQuery += "									     				   AND GW4.GW4_NRDC = GWHSUB.GWH_NRDC "
		cQuery += "		  WHERE GW4.GW4_FILIAL = '" + xFilial("GW4") + "' AND GW4.GW4_CDESP = '" + GW3->GW3_CDESP + "' AND GW4.GW4_EMISDF = '" + GW3->GW3_EMISDF + "' AND GW4.GW4_SERDF = '" + GW3->GW3_SERDF + "' AND GW4.GW4_NRDF = '" + GW3->GW3_NRDF + "' AND GW4.GW4_DTEMIS = '" + DTOS(GW3->GW3_DTEMIS) + "'"
		cQuery += "             AND GWF.GWF_TPCALC = '" + GW3->GW3_TPDF + "' AND GWF.GWF_FILIAL = '" + xFilial("GWF") + "' "
		cQuery += "		    	AND GWF.D_E_L_E_T_ = ' ' AND GWHSUB.D_E_L_E_T_ = ' ' AND GW4.D_E_L_E_T_ = ' ' "
		cQuery += "		 ) "
		cQuery += "ORDER BY GWH.GWH_FILIAL, GWH.GWH_NRDC "
	EndIf
	cQuery := ChangeQuery(cQuery)
	dbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery), cAliDCCL, .F., .T.)

	//-------------

	oSplitter := tSplitter():New( 0,0,oFolder:ADialogs[2],50,50,1 )
	oSplitter:Align := CONTROL_ALIGN_ALLCLIENT

	oPanelE := TPanel():New(01,01,,oSplitter,,,,,,30,30,.F.,.T.)
	oPanelE:Align := CONTROL_ALIGN_TOP		

	oPanelF := TPanel():New(0,0,,oSplitter,,,,,,30,30,.F.,.T.)
	oPanelF:Align := CONTROL_ALIGN_BOTTOM

	oFolderA := TFolder():New(0,0,{"Documentos de Carga do Documento de Frete"},{"HEADER 1"},oPanelF,,,,.T.,,oPanelF:oWnd:nWidth/4,200,)
	oButton := tButton():New(519,1 ,"Totais Por Classificação Doc Frete", oFolderA,{|| MontaArrDC(1)},14,8)
	oButton:Create(oFolderA ,519 ,16,"Totais Por Classificação Doc Carga",{|| MontaArrDC(2)},14,8)
	
	oFolderA:Align := CONTROL_ALIGN_LEFT

	oFolderB := TFolder():New(0,0,{"Documentos de Carga do Cálculo de Frete"},{"HEADER 1"},oPanelF,,,,.T.,,0,0,)
	oFolderB:Align := CONTROL_ALIGN_ALLCLIENT

	GFEA66CPYD(cAliCalc, cCalc, aCalc)
	GFEA66CPYD(cAliDCDF, cDCDF, aDCDF)
	GFEA66CPYD(cAliDCCL, cDCCL, aDCCL)	

	dbSelectArea(cCalc)
	(cCalc)->( dbGoTop() )


	cGrdCalc := MsSelect():New(cCalc,"",,aCpCalc,,,{0,0,0,0},,,oPanelE)
	cGrdCalc:oBrowse:cToolTip := "Cálculos de Frete dos Documentos de Carga" //
	cGrdCalc:oBrowse:Align := CONTROL_ALIGN_ALLCLIENT
	cGrdCalc:oBrowse:lAdjustColSize := .T.

	cGrdCalc:oBrowse:lVisibleControl := .T.
	cGrdCalc:oBrowse:lVisible := .T.
	cGrdCalc:oBrowse:nHeight  := 251
	cGrdCalc:oBrowse:nRight   := 90
	cGrdCalc:oBrowse:nWidth   := 90

	dbSelectArea(cDCDF)
	(cDCDF)->( dbSetOrder(1) )
	(cDCDF)->( dbGoTop() )
	cGrdDCDF := MsSelect():New(cDCDF,"",,aCpDCDF,,,{0,0,0,0},,,oFolderA:aDialogs[1])
	cGrdDCDF:oBrowse:cToolTip := "Documentos de Carga do Documento de Frete" //
	cGrdDCDF:oBrowse:Align := CONTROL_ALIGN_ALLCLIENT
	cGrdDCDF:oBrowse:lAdjustColSize := .T.	

	cGrdDCDF:oBrowse:lVisibleControl := .T.
	cGrdDCDF:oBrowse:lVisible := .T.
	cGrdDCDF:oBrowse:nHeight  := 251
	cGrdDCDF:oBrowse:nRight   := 80
	cGrdDCDF:oBrowse:nWidth   := 80

	dbSelectArea(cDCCL)
	(cDCCL)->( dbSetOrder(1) )
	(cDCCL)->( dbGoTop() )
	cGrdDCCL := MsSelect():New(cDCCL,"",,aCpDCCL,,,{0,0,0,0},,,oFolderB:aDialogs[1])
	cGrdDCCL:oBrowse:cToolTip := "Documentos de Carga dos Cálculos de Frete" //
	cGrdDCCL:oBrowse:Align := CONTROL_ALIGN_ALLCLIENT
	cGrdDCCL:oBrowse:SetBlkBackColor({|| IIf(GFEA66DCBK(),RGB(255,128,128),)})

	cGrdDCCL:oBrowse:lVisibleControl := .T.
	cGrdDCCL:oBrowse:lVisible := .T.
	cGrdDCCL:oBrowse:nHeight  := 251
	cGrdDCCL:oBrowse:nRight   := 80
	cGrdDCCL:oBrowse:nWidth   := 80

	cGrdCalc:oBrowse:Refresh()
	cGrdDCDF:oBrowse:Refresh()
	cGrdDCCL:oBrowse:Refresh()

	lLoadDocRelac := .T.

	CursorArrow()
	oFolder:aDialogs[2]:cTitle := "Documentos"
Return

//---------------------------------------------------

Function GFEA066OK(lMotivo, dtAprov, cHrAprov, cUserAprov, cMotAprov)
	Local lRet 			:= .T.
	Local lGFEA0664 	:= ExistBlock("GFEA0664")
	Local aRetRateio	:= {}

	Default cHrAprov   := Time()
	Default cMotAprov  := cMemo
	Default cUserAprov := cUserName
	Default dtAprov    := DDATABASE

	// Início Ponto de Entrada
	If lGFEA0664
		lRet := ExecBlock("GFEA0664",.f.,.f.,{GW3->GW3_FILIAL, GW3->GW3_CDESP, GW3->GW3_EMISDF, GW3->GW3_SERDF, GW3->GW3_NRDF, GW3->GW3_DTEMIS})	
	EndIf
	// Fim Ponto de Entrada	

	/* Caso a tela de aprovação não tiver a opção de informar Motivo, retorna e apenas sai da tela*/
	If lRet .And. !lMotivo
		Return .T.
	EndIf

	If lRet
		If !Empty(cMotAprov)
			If SuperGetMv("MV_TPGERA",,"1") == "1" // OnLine
				aRetRateio := GFERatDF(.F., GW3->GW3_CDESP, GW3->GW3_EMISDF, GW3->GW3_SERDF, GW3->GW3_NRDF, GW3->GW3_DTEMIS)

				If aRetRateio[1] == .F. .And. GW3->GW3_TPDF != "3"
					Help( ,, 'HELP',, aRetRateio[2], 1, 0)
					RecLock("GW3",.F.)
					GW3->GW3_USUBLQ := cUserName
					GW3->GW3_MOTBLQ := aRetRateio[2]
					GW3->GW3_SIT := "2"
					GW3->(MsUnLock())

					Return .F.
				Else
					RecLock("GW3",.F.)
					GW3->GW3_USUBLQ := ""
					GW3->( msUnlock() )
				EndIf
			Else
				// Geração do Rateio simplificado (sem contas contábeis)
				GFERatDFSimp({GW3->GW3_FILIAL, GW3->GW3_CDESP, GW3->GW3_EMISDF, GW3->GW3_SERDF, GW3->GW3_NRDF, GW3->GW3_DTEMIS})
			EndIf

			RecLock("GW3",.F.)
			GW3->GW3_MOTAPR := cMotAprov
			GW3->GW3_USUAPR := cUserAprov
			GW3->GW3_SIT    := "4"
			GW3->GW3_DTAPR  := dtAprov
			If GfeVerCmpo({"GW3_HRAPR"})
				GW3->GW3_HRAPR  := cHrAprov
			EndIf

			If GFXCP12127("GW3_SITDIV")
				GW3->GW3_SITDIV := cSitTab
			Endif

			GW3->(MsUnLock())

			//cria integração de custo de frete com SIGATMS caso esteja assim parametrizado
			GFEA065CTP('IA')

			//Teste integração Automatica
			If SuperGetMV('MV_GFEI13',,'1') == "2" .AND. ( GW3->GW3_SITFIS == "1" .Or. GW3->GW3_SITFIS == "3" ) // Fiscal
				GFEA065XF(.T.)
			EndIf

			If SuperGetMV('MV_GFEI14',,'1') == "2" .AND. ( GW3->GW3_SITREC == "1" .Or. GW3->GW3_SITREC == "3" ) // Recebimento
				GFEA065XC(.T.)
			EndIf
			
			GFEA65GFAT(.F.) // Gera a fatura automaticamente

			MsgInfo(STR0019) //"Documento de Frete Aprovado"

			If GFXCP12117("GW1_SITFRE") .And. SuperGetMV('MV_INTFRE',.F.,'1') == '2'
				GFEA066VF()
			EndIf
			// Início Ponto de Entrada
			If ExistBlock("GFEA0661")
				ExecBlock("GFEA0661",.f.,.f.)
			EndIf
			// Fim Ponto de Entrada
		Else
			Help( ,, 'Help',, STR0020, 1, 0 )   //"É necessário informar o motivo para aprovação"
			lRet := .F.
		EndIf
	EndIf
Return(lRet)

//--------------------------------------------------------
Function GFEA066VF() //Gerar Pendencia de Integração dos Valores de Frete com o ERP

	GW4->( dbSetOrder(1) )
	GW4->( dbSeek(xFilial("GW4")+GW3->GW3_EMISDF+GW3->GW3_CDESP+GW3->GW3_SERDF+GW3->GW3_NRDF+DTOS(GW3->GW3_DTEMIS)) )

	While !GW4->( Eof() ) .And. GW4->GW4_FILIAL+GW4->GW4_EMISDF+GW4->GW4_CDESP+GW4->GW4_SERDF+GW4->GW4_NRDF+DTOS(GW4->GW4_DTEMIS) == ;
	xFilial("GW4")+GW3->GW3_EMISDF+GW3->GW3_CDESP+GW3->GW3_SERDF+GW3->GW3_NRDF+DTOS(GW3->GW3_DTEMIS)  

		GW1->( dbSetOrder(1) )
		If (GW1->( dbSeek(xFilial("GW1")+GW4->GW4_TPDC+GW4->GW4_EMISDC+GW4->GW4_SERDC+GW4->GW4_NRDC)))
			If GW1->GW1_SITFRE != '6' .And. GW1->GW1_ORIGEM == '2' 
				RecLock("GW1", .F.)
				GW1->GW1_SITFRE := "2"
				GW1->GW1_MOTFRE := "GFEA066 - Aprovaçao de Frete"
				GW1->GW1_DTFRE := Date()    			
				GW1->( Msunlock() )			
			EndIf
		EndIf
		GW4->(dbSkip())
	Enddo

Return .T.
//--------------------------------------------------------

Function GFE066MKB()
	// Dados dos Documentos (MV_DCOUT)
	Local iQT_VOL		:= 0	// Quantidade de Volumes
	Local iPESO_REAL	:= 0   // Peso Real
	Local iPESO_CUBA	:= 0   // Peso Cubado
	Local iVOLUME		:= 0   // Volume
	Local iVALOR		:= 0   // Valor dos Itens

	// Valores Detalhados (MV_DCABE)
	Local iFRET_UNID	:= 0	// Frete Unidade
	Local iFRET_VAL	:= 0	// Frete Valor
	Local iTAXAS		:= 0	// Taxas
	Local iVAL_PEDA	:= 0	// Valor do Pedágio	

	// Valor Total (MV_DCTOT)
	Local iVAL_FRETE	:= 0   // Valor do Frete
	Local iALIQUOTA	:= 0	// Alíquota
	Local iVAL_IMPO	:= 0	// Valor do Imposto (ICMS ou ISS)	

	//Valor de ajuste
	Local iVAL_VLAJUS	:= 0

	Local lUnitiz		:= .F. // Possui Unitizador (GWB)
	Local lObrigat	:= ""	// Grupo de Valores Obrigatórios
	Local lExistCamp:= GFXCP12116("GWF","GWF_CDESP") .And. (SuperGetMV("MV_DPSERV", .F., "1") == "1") .And. GFEA065VFIX()
	Local lRet := .T.
	Local cQuery

	Local aArea		:= GetArea()
	Local aAreaGW1	:= GW1->( GetArea() )
	Local aAreaGW4	:= GW4->( GetArea() )
	Local aAreaGWB	:= GWB->( GetArea() )
	Local aAreaGW8	:= GW8->( GetArea() )
	Local aAreaGUG	:= GUG->( GetArea() )
	Local aAreaGWH	:= GWH->( GetArea() )
	Local aAreaGWI	:= GWI->( GetArea() )
	Local aAreaGWF	:= GWF->( GetArea() )
	Local aAreaGV2	:= GV2->( GetArea() )
	Local nAliqISS 
	Local aCalcRel   := {}
	Local lPE665 := ExistBlock("GFEA0665")
	Local s_VLCNPJ  := SuperGetMV('MV_VLCNPJ',,'1')	
	Local s_DCTOT   := SuperGetMV('MV_DCTOT',,'2')
	Local s_DMIMP   := SuperGetMV('MV_DMIMP',,'2')

	nAliqISS := 0 

	GFEA66CPYD(cAliOcor, cOcor, aOcor)

	//Verifica se o documento de frete possui algum cálculo vinculado
	If lExistCamp
		dbSelectArea('GWF')
		GWF->(DbOrderNickName("DOCFRETE"))//Indice 6: GWF_FILIAL+GWF_CDESP+GWF_EMISDF+GWF_SERDF+GWF_NRDF+DTOS(GWF_DTEMDF)

		If !dbSeek(xFilial("GWF")+GW3->GW3_CDESP+GW3->GW3_EMISDF+GW3->GW3_SERDF+GW3->GW3_NRDF+DTOS(GW3->GW3_DTEMIS))
			lRet := .F.
		EndIF
	EndIf

	dbSelectArea("GW4")
	dbSetOrder(1)
	dbSeek(xFilial("GW4")+GW3->GW3_EMISDF+GW3->GW3_CDESP+GW3->GW3_SERDF+GW3->GW3_NRDF+DTOS(GW3->GW3_DTEMIS))
	While !GW4->( Eof() ) .And. GW4->GW4_FILIAL+GW4->GW4_EMISDF+GW4->GW4_CDESP+GW4->GW4_SERDF+GW4->GW4_NRDF+DTOS(GW4->GW4_DTEMIS) == ;
	xFilial("GW4")+GW3->GW3_EMISDF+GW3->GW3_CDESP+GW3->GW3_SERDF+GW3->GW3_NRDF+DTOS(GW3->GW3_DTEMIS) .And. lRet == .T. 

		/* GW1 */
		dbSelectArea("GW1")
		dbSetOrder(1)
		If dbSeek(xFilial("GW1")+GW4->GW4_TPDC+GW4->GW4_EMISDC+GW4->GW4_SERDC+GW4->GW4_NRDC)
			/* GWB */
			dbSelectArea("GWB")
			dbSetOrder(2)
			dbSeek(xFilial("GWB")+GW1->GW1_CDTPDC+GW1->GW1_EMISDC+GW1->GW1_SERDC+GW1->GW1_NRDC)
			While !GWB->( Eof() ) .And. GWB->GWB_FILIAL+GWB->GWB_CDTPDC+GWB->GWB_EMISDC+GWB->GWB_SERDC+GWB->GWB_NRDC == ;
			xFilial("GWB")+GW1->GW1_CDTPDC+GW1->GW1_EMISDC+GW1->GW1_SERDC+GW1->GW1_NRDC 

				lUnitiz := .T.

				iQT_VOL := iQT_VOL + GWB->GWB_QTDE

				dbSelectArea("GUG")
				dbSetOrder(1)
				If dbSeek(xFilial("GUG")+GWB->GWB_CDUNIT)
					iVOLUME    := iVOLUME    + GUG->GUG_VOLUME*GWB->GWB_QTDE
				EndIf

				dbSelectArea("GWB")	
				dbSkip()
			EndDo
		EndIf	

		If lExistCamp //Utiliza novo índice para procurar os cálculos do documento de frete
			dbSelectArea('GWF')
			GWF->(DbOrderNickName("DOCFRETE"))// Indice 6: GWF_FILIAL+GWF_CDESP+GWF_EMISDF+GWF_SERDF+GWF_NRDF+DTOS(GWF_DTEMDF)

			dbSeek(xFilial("GWF")+GW3->GW3_CDESP+GW3->GW3_EMISDF+GW3->GW3_SERDF+GW3->GW3_NRDF+DTOS(GW3->GW3_DTEMIS))
			While !GWF->(Eof()) .And. xFilial("GWF")+GWF->(GWF_CDESP+GWF_EMISDF+GWF_SERDF+GWF_NRDF+DTOS(GWF_DTEMDF)) == GW3->(GW3_FILIAL+GW3_CDESP+GW3_EMISDF+GW3_SERDF+GW3_NRDF+DTOS(GW3_DTEMIS))

				If AScan(aCalcRel, {|x| x == GWF->GWF_NRCALC}) > 0
					dbSelectArea("GWF")	
					GWF->( dbSkip() )
					Loop
				EndIf

				GFEA066CF(@aCalcRel,@iVAL_VLAJUS,@iVAL_FRETE,@iFRET_UNID,@iFRET_VAL,@iTAXAS,@iVAL_PEDA,@iALIQUOTA,@iVAL_IMPO,GWF->GWF_NRCALC)

				GWF->(dbSkip())
			EndDo	
		Else	
			/* GWH */
			dbSelectArea("GWH")
			dbSetOrder(2)
			dbSeek(xFilial("GWH")+GW1->GW1_CDTPDC+GW1->GW1_EMISDC+GW1->GW1_SERDC+GW1->GW1_NRDC)
			While !GWH->( Eof() ) .And. xFilial("GWH")+GW1->GW1_CDTPDC+GW1->GW1_EMISDC+GW1->GW1_SERDC+GW1->GW1_NRDC == ;
			GWH->GWH_FILIAL+GWH->GWH_CDTPDC+GWH->GWH_EMISDC+GWH->GWH_SERDC+GWH->GWH_NRDC

				If AScan(aCalcRel, {|x| x == GWH->GWH_NRCALC}) > 0
					dbSelectArea("GWH")	
					GWH->( dbSkip() )
					Loop
				EndIf

				dbSelectArea("GWF")
				GWF->( dbSetOrder(1) )
				If (GWF->( dbSeek(xFilial("GWF") + GWH->GWH_NRCALC) ) .And. GW3->GW3_EMISDF == GWF->GWF_TRANSP .And. GW3->GW3_TPDF == GWF->GWF_TPCALC);
				.or. (s_VLCNPJ == "2" .AND. SubStr(Posicione("GU3", 1, xFilial("GU3") +GW3->GW3_EMISDF, "GU3->GU3_IDFED"), 1, 8) == SubStr(Posicione("GU3", 1, xFilial("GU3") + GWF->GWF_TRANSP, "GU3->GU3_IDFED"), 1, 8) .And. GW3->GW3_TPDF == GWF->GWF_TPCALC )

					GFEA066CF(@aCalcRel,@iVAL_VLAJUS,@iVAL_FRETE,@iFRET_UNID,@iFRET_VAL,@iTAXAS,@iVAL_PEDA,@iALIQUOTA,@iVAL_IMPO,GWF->GWF_NRCALC)

				EndIf

				dbSelectArea("GWH")
				GWH->( dbSkip() )
			EndDo
		EndIf

		dbSelectArea("GW4")
		GW4->( dbSkip() )
	EndDo

	cAliTotGW8 := GetNextAlias()


	cQuery := "SELECT SUM(GW8_PESOR) AS TOT_PESOR, SUM(GW8_PESOC) AS TOT_PESOC, SUM(GW8_VALOR) AS TOT_VALOR "
	If !lUnitiz
		cQuery += ", SUM(GW8_QTDE) AS TOT_QTDE, SUM(GW8_VOLUME) AS TOT_VOLUME "
	EndIf
	cQuery += "FROM " + RetSQLName("GW4") + " GW4 "
	cQuery += "INNER JOIN " + RetSQLName("GW8") + " GW8 ON "
	cQuery += "GW8_FILIAL = GW4_FILIAL AND  "
	cQuery += "GW8_CDTPDC = GW4_TPDC   AND "
	cQuery += "GW8_EMISDC = GW4_EMISDC AND "
	cQuery += "GW8_SERDC  = GW4_SERDC  AND "
	cQuery += "GW8_NRDC   = GW4_NRDC   AND "
	cQuery += "GW8.D_E_L_E_T_ = '' "
	cQuery += "WHERE "
	cQuery += "GW4_FILIAL = '" 	+ GW3->GW3_FILIAL		+ "' AND "
	cQuery += "GW4_EMISDF = '" 	+ GW3->GW3_EMISDF		+ "' AND "
	cQuery += "GW4_CDESP = '" 	+ GW3->GW3_CDESP		+ "' AND "
	cQuery += "GW4_SERDF = '" 	+ GW3->GW3_SERDF		+ "' AND "
	cQuery += "GW4_NRDF	= '" 	+ GW3->GW3_NRDF			+ "' AND "
	cQuery += "GW4_DTEMIS = '" 	+ DTOS(GW3->GW3_DTEMIS)	+ "' AND "
	cQuery += "GW4.D_E_L_E_T_ = '' "

	cQuery := ChangeQuery(cQuery)
	dbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery), cAliTotGW8, .F., .T.)

	dbSelectArea(cAliTotGW8)
	(cAliTotGW8)->( dbGoTop() )
	If !(cAliTotGW8)->(Eof()) .And. lRet
		If !lUnitiz
			iQT_VOL := iQT_VOL    + (cAliTotGW8)->TOT_QTDE
			iVOLUME := iVOLUME 	 + (cAliTotGW8)->TOT_VOLUME
		EndIf

		iPESO_REAL := (cAliTotGW8)->TOT_PESOR
		iPESO_CUBA := (cAliTotGW8)->TOT_PESOC
		iVALOR     := (cAliTotGW8)->TOT_VALOR
	EndIf

	dbSelectArea(cAliMKB)
	ZAP

	// *** Dados dos Documentos	*******************************

	If GetNewPar('MV_DCOUT','N') $ "1S"
		lObrigat := "X"
	EndIf

	/* Quantidade de Volumes  */
	RecLock((cAliMKB),.T.)
	(cAliMKB)->OBRIGAT 	 := lObrigat
	(cAliMKB)->CAMPO  	 := STR0021 //"Quantidade de Volumes"
	(cAliMKB)->VALOR1  	 := GW3->GW3_QTVOL
	(cAliMKB)->VALOR2  	 := iQT_VOL
	CalcDif(GW3->GW3_QTVOL, iQT_VOL)
	(cAliMKB)->(MsUnLock())

	/* Peso Real  */
	RecLock((cAliMKB),.T.)
	(cAliMKB)->OBRIGAT 	 := lObrigat
	(cAliMKB)->CAMPO  	 := STR0022 //"Peso Real"
	(cAliMKB)->VALOR1  	 := GW3->GW3_PESOR
	(cAliMKB)->VALOR2  	 := iPESO_REAL
	CalcDif(GW3->GW3_PESOR, iPESO_REAL)
	(cAliMKB)->(MsUnLock())

	/* Peso Cubado  */
	RecLock((cAliMKB),.T.)
	(cAliMKB)->OBRIGAT 	 := lObrigat
	(cAliMKB)->CAMPO  	 := STR0023 //"Peso Cubado"
	(cAliMKB)->VALOR1  	 := GW3->GW3_PESOC
	(cAliMKB)->VALOR2  	 := iPESO_CUBA
	CalcDif(GW3->GW3_PESOC, iPESO_CUBA)
	(cAliMKB)->(MsUnLock())

	/* Volume  */
	RecLock((cAliMKB),.T.)
	(cAliMKB)->OBRIGAT 	 := lObrigat
	(cAliMKB)->CAMPO  	 := STR0024 //"Volume"
	(cAliMKB)->VALOR1  	 := GW3->GW3_VOLUM
	(cAliMKB)->VALOR2  	 := iVOLUME
	CalcDif(GW3->GW3_VOLUM, iVOLUME)
	(cAliMKB)->(MsUnLock())

	/* Valor dos Itens  */
	RecLock((cAliMKB),.T.)
	(cAliMKB)->OBRIGAT 	 := lObrigat
	(cAliMKB)->CAMPO  	 := STR0025 //"Valor dos Itens"
	(cAliMKB)->VALOR1  	 := GW3->GW3_VLCARG
	(cAliMKB)->VALOR2  	 := iVALOR
	CalcDif(GW3->GW3_VLCARG, iVALOR)
	(cAliMKB)->(MsUnLock())

	// *** Valores Detalhados	*******************************
	lObrigat := ""	
	If GetNewPAr('MV_DCABE','N') $ "1S"
		lObrigat := "X"
	EndIf

	/* Frete Unidade  */
	RecLock((cAliMKB),.T.)
	(cAliMKB)->OBRIGAT 	 := lObrigat
	(cAliMKB)->CAMPO  	 := STR0026 //"Frete Unidade"
	(cAliMKB)->VALOR1  	 := GW3->GW3_FRPESO
	(cAliMKB)->VALOR2  	 := iFRET_UNID
	CalcDif(GW3->GW3_FRPESO, iFRET_UNID)
	(cAliMKB)->(MsUnLock())

	If lPE665
		ExecBlock("GFEA0665",.F.,.F.,{"1"})
	EndIf

	/* Frete Valor  */
	RecLock((cAliMKB),.T.)
	(cAliMKB)->OBRIGAT 	 := lObrigat
	(cAliMKB)->CAMPO  	 := STR0027 //"Frete Valor"
	(cAliMKB)->VALOR1  	 := GW3->GW3_FRVAL
	(cAliMKB)->VALOR2  	 := iFRET_VAL
	CalcDif(GW3->GW3_FRVAL, iFRET_VAL)
	(cAliMKB)->(MsUnLock())

	If lPE665
		ExecBlock("GFEA0665",.F.,.F.,{"2"})
	EndIf

	/* Taxas */
	RecLock((cAliMKB),.T.)
	(cAliMKB)->OBRIGAT 	 := lObrigat
	(cAliMKB)->CAMPO  	 := STR0028 //"Taxas"
	(cAliMKB)->VALOR1  	 := GW3->GW3_TAXAS
	(cAliMKB)->VALOR2  	 := iTAXAS
	CalcDif(GW3->GW3_TAXAS, iTAXAS)
	(cAliMKB)->(MsUnLock())

	If lPE665
		ExecBlock("GFEA0665",.F.,.F.,{"3"})
	EndIf

	/* Valor do Pedágio */
	RecLock((cAliMKB),.T.)
	(cAliMKB)->OBRIGAT 	 := lObrigat
	(cAliMKB)->CAMPO  	 := STR0029 //"Valor do Pedágio"
	(cAliMKB)->VALOR1  	 := GW3->GW3_PEDAG
	(cAliMKB)->VALOR2  	 := iVAL_PEDA
	CalcDif(GW3->GW3_PEDAG, iVAL_PEDA)
	(cAliMKB)->(MsUnLock())

	If lPE665
		ExecBlock("GFEA0665",.F.,.F.,{"4"})
	EndIf

	/* Valor de ajuste de frete */
	RecLock((cAliMKB),.T.)
	(cAliMKB)->OBRIGAT 	 := lObrigat
	(cAliMKB)->CAMPO  	 := "Valor do Ajuste" //"Valor do Ajuste"
	(cAliMKB)->VALOR1  	 := IIf(GW3->GW3_ORIGEM == '4',iVAL_VLAJUS,0)
	(cAliMKB)->VALOR2  	 := iVAL_VLAJUS
	(cAliMKB)->DIF 		 := 0
	(cAliMKB)->(MsUnLock())
	
	// *** Valores Total 		*******************************
	lObrigat := ""
	If s_DCTOT $ "1S"
		lObrigat := "X"
	EndIf

	/* Valor Total do Frete */
	RecLock((cAliMKB),.T.)
	(cAliMKB)->OBRIGAT 	 := lObrigat
	(cAliMKB)->CAMPO  	 := STR0030 //"Valor total do Frete"
	(cAliMKB)->VALOR1  	 := GW3->GW3_VLDF
	(cAliMKB)->VALOR2  	 := iVAL_FRETE
	CalcDif(GW3->GW3_VLDF, iVAL_FRETE)
	(cAliMKB)->(MsUnLock())

	// *** Valores Impostos		*******************************

	/* Alíquota */
	lObrigat := ""
	If s_DMIMP $ "1S"
		lObrigat := "X"
	EndIf
	RecLock((cAliMKB),.T.)
	(cAliMKB)->OBRIGAT 	 := lObrigat
	(cAliMKB)->CAMPO  	 := STR0031 //"Alíquota"
	(cAliMKB)->VALOR1  	 := GW3->GW3_PCIMP
	(cAliMKB)->VALOR2  	 := iALIQUOTA
	CalcDif(GW3->GW3_PCIMP, iALIQUOTA)
	(cAliMKB)->(MsUnLock())

	/* Valor do Imposto */
	lObrigat := ""
	If s_DMIMP $ "1S"
		lObrigat := "X"
	EndIf
	RecLock((cAliMKB),.T.)
	(cAliMKB)->OBRIGAT 	 := lObrigat
	(cAliMKB)->CAMPO  	 := STR0032 //"Valor do Imposto"
	(cAliMKB)->VALOR1  	 := GW3->GW3_VLIMP
	(cAliMKB)->VALOR2  	 := iVAL_IMPO
	CalcDif(GW3->GW3_VLIMP, iVAL_IMPO)
	(cAliMKB)->(MsUnLock())


	RestArea(aAreaGW1)
	RestArea(aAreaGW4)
	RestArea(aAreaGWB)
	RestArea(aAreaGW8)
	RestArea(aAreaGUG)
	RestArea(aAreaGWH)
	RestArea(aAreaGWI)
	RestArea(aAreaGWF)
	RestArea(aAreaGV2)
	RestArea(aArea)

Return .T.

//-------------------------------------------------------------------

Static Function CalcDif(iValor1, iValor2)
	(cAliMKB)->DIF := iValor1 - iValor2
Return

// Verifica se a diferença da linha está abaixo da tolerância permitida
Static Function AbaixoTol()
	Local lRet := .T.
	Local nPorc
	Local n_DMVAL   := SuperGetMv('MV_DMVAL',,0)
	Local n_DMPERC  := SuperGetMv('MV_DMPERC',,0)

	//Caso o campo não seja obrigatório, não cria background vermelho no record do grid
	If AllTrim( (cAliMKB)->OBRIGAT ) != "X"
		Return .F.
	EndIf         

	If (cAliMKB)->DIF == 0
		Return .F.
	EndIf   

	//Apenas os campos "Frete Unidade\Frete Valor\Taxas\Valor do Pedágio\Valor total do Frete\Valor do Imposto" são utilizados a tolerancia
	If AllTrim((cAliMKB)->CAMPO)$ "Frete Unidade\Frete Valor\Taxas\Valor do Pedágio\Valor total do Frete\Valor do Imposto"
		//  Verifica se paramtro MV_DCNEG esta setado como "Sim" e variavel nInfo menor que o valor do calculo então Indica que os valores 
		// 	dos documentos de frete menores que os valores calculados pelo sistema não serão considerados como divergência na conferência 
		//	se estiver como "Não" cai na condição Else
		If GETNEWPAR('MV_DCNEG',"N") $ "1S" .And. (cAliMKB)->VALOR1 < (cAliMKB)->VALOR2
			lRet := .F.
		Else
			If (cAliMKB)->VALOR1 >= (cAliMKB)->VALOR2
				If !Empty(SuperGetMv('MV_DCVAL',,0)) .And. !Empty(SuperGetMv('MV_DCPERC',,0)) /*Faz uma verificação para os parametros MV_DCVAL e MV_DCPERC para verificar se eles estejam em branco*/
					nPorc := (SuperGetMv('MV_DCPERC',,0) / 100) * (cAliMKB)->VALOR2 /*Faz o calculo para achar o percentual aonde ele Divide o parametro MV_DCPERC por 100 e logo após multiplica ele pelo Valor do Calculo*/
					If (abs((cAliMKB)->DIF) <= nPorc ) .And. abs((cAliMKB)->DIF) <= SuperGetMv('MV_DCVAL',,0) /*Verifica se a difença é menor que o percentual e ao mesmo tempo se ela é menor que o parametro MV_DCVAL*/
						lRet := .F.
					Endif
				Endif
			Else
				If n_DMPERC > 0 .And. n_DMVAL > 0
					nPorc := (n_DMPERC / 100) * (cAliMKB)->VALOR2
					If abs((cAliMKB)->DIF) < nPorc .And. abs((cAliMKB)->DIF) < n_DMVAL
						lRet := .F.
					EndIf
				EndIf
			EndIf
		EndIf
	EndIf
Return lRet

Static Function MontaArrDC(nMod)
	Local aDc := {}// array para Documentos de carga onde será feito a totalização por classificação
	Local aAreaGW4 := GetArea(/*"GWN"*/ "GW4")

	If nMod == 1

		dbSelectArea("GW4")

		GW4->( dbSetOrder(1))
		GW4->( dbSeek(GW3->GW3_FILIAL+GW3->GW3_EMISDF+GW3->GW3_CDESP+GW3->GW3_SERDF+GW3->GW3_NRDF+DTOS(GW3->GW3_DTEMIS)) )

		While !GW4->(Eof())	.And. GW3->GW3_FILIAL == GW4->GW4_FILIAL .And. GW3->GW3_EMISDF == GW4->GW4_EMISDF;
		.And. GW3->GW3_CDESP  == GW4->GW4_CDESP  .And. GW3->GW3_SERDF  == GW4->GW4_SERDF;
		.And. GW3->GW3_NRDF   == GW4->GW4_NRDF   .And. DTOS(GW3->GW3_DTEMIS) == DTOS(GW4->GW4_DTEMIS)


			Aadd(aDc,GW4->GW4_FILIAL+GW4->GW4_TPDC+GW4->GW4_EMISDC+GW4->GW4_SERDC+GW4->GW4_NRDC)

			GW4->(dbSkip())

		EndDo
	Else
		aDc := {(cDCDF)->GW4_FILIAL+(cDCDF)->GW4_TPDC+(cDCDF)->GW4_EMISDC+(cDCDF)->GW4_SERDC+(cDCDF)->GW4_NRDC}
	EndIf

	GFEC040A(aDc)
	RestArea(aAreaGW4)

Return 

/*----------------------------------------------------------------------------------------------------
{Protheus.doc} GFEA066CCa
Exibir os cálculos do documento de frete com pendência de aprovação.

@sample
GFEA066CCa()


@author Wander Horongoso
@since 09/10/2015
@version 1.0
----------------------------------------------------------------------------------------------------*/

Function GFEA066CCa

	dbSelectArea("GWF")
	GWF->( dbSetOrder(1) )
	If Empty(cCalc)
		Help( ,, 'Help',, 'Selecione a aba Documentos para carregamento dos cálculos.', 1, 0 )
	Else	
		If dbSeek( (cCalc)->(GWF_FILIAL+GWF_NRCALC) )				  
			FWExecView("Visualiza", "GFEC080", 1,,{|| .T.})
		EndIf
	EndIf

Return

/*----------------------------------------------------------------------------------------------------
{Protheus.doc} GFEA066CF
Soma valores do cálculo de frete.

@sample
GFEA066CF()

@author Amanda Rosa Vieira
@since 13/07/2016
@version 1.0
------------------------------------------------------------------------------------------------------*/
Function GFEA066CF(aCalcRel,iVAL_VLAJUS,iVAL_FRETE,iFRET_UNID,iFRET_VAL,iTAXAS,iVAL_PEDA,iALIQUOTA,iVAL_IMPO,nNrCalc)

	AAdd(aCalcRel, GWF->GWF_NRCALC)
	iVAL_VLAJUS += GWF->GWF_VLAJUS
	iVAL_FRETE  += GWF->GWF_VLAJUS

	dbSelectArea("GWI")
	dbSetOrder(1)

	//GWI_FILIAL+GWI_NRCALC+GWI_CDCLFR+GWI_CDTPOP+GWI_CDCOMP
	dbSeek(xFilial("GWI")+nNrCalc)
	While !GWI->( Eof() ) .And. xFilial("GWI")+nNrCalc == GWI->GWI_FILIAL+GWI->GWI_NRCALC

		// GV2 - Componente de Frete
		dbSelectArea("GV2")
		dbSetOrder(1)
		dbSeek(xFilial("GV2")+GWI->GWI_CDCOMP)
		If GWI->GWI_TOTFRE == "1"
			// Valor Total do Frete
			iVAL_FRETE := iVAL_FRETE + GWI->GWI_VLFRET

			//1=Frete Unidade;2=Frete Valor;3=Taxas;4=Valor do Pedagio
			Do Case
				Case GV2->GV2_CATVAL == "1"  // Frete Unidade
				iFRET_UNID := iFRET_UNID + GWI->GWI_VLFRET

				Case GV2->GV2_CATVAL == "2"  // Frete Valor
				iFRET_VAL  := iFRET_VAL  + GWI->GWI_VLFRET

				Case GV2->GV2_CATVAL == "3"  // Taxas
				iTAXAS     := iTAXAS     + GWI->GWI_VLFRET

				Case GV2->GV2_CATVAL == "4"  // Valor do Pedagio
				iVAL_PEDA  := iVAL_PEDA  + GWI->GWI_VLFRET	
			EndCase
		EndIf

		dbSelectArea("GWI")
		GWI->( dbSkip() )
	EndDo

	//Cidade de origem e destino é a mesma, então o calculo é de ISS
	//Grava os valores de Aliquota e de imposto
	If GWF->GWF_IMPOST == "2"
		/*ISS*/
		iALIQUOTA := GWF->GWF_PCISS
		iVAL_IMPO += GWF->GWF_VLISS
	Else 
		/*ICMS*/
		iALIQUOTA := GWF->GWF_PCICMS
		iVAL_IMPO += GWF->GWF_VLICMS
	EndIf

Return

/*----------------------------------------------------------------------------------------------------
{Protheus.doc} GFEA066Ta
Exibir as taxas do documento de frete

@sample
GFEA066Ta()

----------------------------------------------------------------------------------------------------*/

Function GFEA066Ta

	Local oPnlCnt
	Local oSize
	Local aPos
	local aMKBTx := {}
	local aCpMKBtx := {}
	Local oFolderTX
	Local lOk := .T.
	Private oDlgTaxa
	Private cMarca := GetMark()
	Private cAliTaxa	
	Private cCalc
	Private oBrwTaxa

	CursorWait()

	aMKBtx :=    {{"OBRIGAT" ,"C",01,0},;
	{"CAMPO"   ,"C",35,0},;
	{"VALOR1"  ,"N",18,8},;
	{"VALOR2"  ,"N",18,8},;
	{"DIF"     ,"N",18,8}}

	aCpMKBtx  := {{"OBRIGAT" ,NIL,"O",""},;
	{"CAMPO"   ,NIL,STR0005,""},; //"Campo"
	{"VALOR1"  ,NIL,"Informado","@E 999,999,999.99999999"},; //"Informado"
	{"VALOR2"  ,NIL,"Calculado","@E 999,999,999.99999999"},; //"Calculado"
	{"DIF"     ,NIL,STR0008,"@E 999,999,999.99999999"}} //"Diferença"

	cAliTaxa := GFECriaTab({ aMKBtx,{"OBRIGAT"} })	

	//-----------------
	oSize := FWDefSize():New(.T.)
	oSize:AddObject( "ENCHOICE", 100, 60, .T., .T. ) // Adiciona enchoice
	oSize:SetWindowSize({000, 000, 400,700})
	oSize:lLateral     := .F.  // Calculo vertical	
	oSize:Process() //executa os calculos

	//Array com as posições dinamicas se quiser alterar o tamnho da tela é so alterar o tamanho do SetWindowSize
	aPos := {oSize:GetDimension("ENCHOICE","LININI"),; 
	oSize:GetDimension("ENCHOICE","COLINI"),;
	oSize:GetDimension("ENCHOICE","XSIZE"),;
	oSize:GetDimension("ENCHOICE","YSIZE")}

	DEFINE MSDIALOG oDlgTaxa TITLE "Taxas do Documento de Frete" ;
	FROM oSize:aWindSize[1],oSize:aWindSize[2] ;
	TO oSize:aWindSize[3],oSize:aWindSize[4] ; 
	Of oMainWnd COLORS 0, 16777215 PIXEL
	oDlgTaxa:lEscClose := .F.

	oPnlCnt := tPanel():New(aPos[1],aPos[2],,oDlgTaxa,,,,,,aPos[3],aPos[4],.F.,.F.)

	oPnlA := tPanel():New(00,00,,oPnlCnt,,,,,,10,20,.F.,.F.)
	oPnlA:Align := CONTROL_ALIGN_TOP

	oFolderTX := TFolder():New(0,0,{"Taxas"},{"HEADER 1"},oPnlCnt,,,,.T.,,10,10,) 

	oFolderTX:Align := CONTROL_ALIGN_ALLCLIENT

	oPanelB := TPanel():New(01,01,,oFolderTX:ADialogs[1],,,,,,0,0,.F.,.T.)
	oPanelB:Align := CONTROL_ALIGN_ALLCLIENT

	// ----- Criacao dos fields referente ao romaneio no painel superior da tela principal -----//
	cDSTRAN := posicione("GU3",1,xFilial("GU3")+GW3->GW3_EMISDF,"GU3_NMEMIT")
	@ 07,06  Say STR0012 Of oPnlA COLOR CLR_BLACK Pixel //"Filial: "
	@ 05,21  MSGET GW3->GW3_FILIAL Picture "@!" Of oPnlA When .F. SIZE 35,10  Pixel

	@ 07,64  Say STR0013 Of oPnlA COLOR CLR_BLACK Pixel //"Espécie: "                        
	@ 05,85 MSGET GW3->GW3_CDESP Picture "@!" Of oPnlA When .F.  SIZE 45,10  Pixel

	@ 07,139 Say STR0014            Of oPnlA COLOR CLR_BLACK Pixel //"Emissor: "
	@ 05,160 MSGET GW3->GW3_EMISDF  Picture "@!" Of oPnlA When .F.   SIZE 65,10 Pixel
	@ 05,226 MSGET cDSTRAN Picture "@!" Of oPnlA When .F. SIZE 120,10 Pixel

	dbSelectArea(cAliTaxa)
	dbSetOrder(01)
	dbGoTop()

	oMarkTx := MsSelect():New(cAliTaxa,"",,aCpMKBtx,,@cMarca,{0,0,0,0},,,oPanelB)
	oMarkTx:oBrowse:cToolTip := STR0015 //"Documentos de Carga"
	oMarkTx:oBrowse:Align := CONTROL_ALIGN_ALLCLIENT	

	if GFXCP12131("GZZ_NRDF")
		//----- Processa os registros e carrega o browse -----//
		Processa({|lEnd| GFE66Taxa()},STR0017,STR0018) //"Processando informações"###"Aguarde"
	EndIF
	CursorArrow()

	dbSelectArea(cAliTaxa)
	dbGoTOp()

	oMarkTx:oBrowse:nAtCol(2,.F.)

	ACTIVATE MSDIALOG oDlgTaxa ON INIT (EnchoiceBar(oDlgTaxa,{||lOk:=.T.,oDlgTaxa:End()},;	
	{||oDlgTaxa:End()},,),oMarkTx:oBrowse:Gotop()) CENTERED

	GFEDelTab(cAliTaxa)

Return

Function GFE66Taxa()

	Local lExistCamp:= GFXCP12116("GWF","GWF_CDESP") .And. (SuperGetMV("MV_DPSERV", .F., "1") == "1") .And. GFEA065VFIX()
	Local lRet := .T.
	Local aTaxas := {}
	Local cAliasGZZ 
	Local aCalcRel   := {}
	Local s_VLCNPJ  := SuperGetMV('MV_VLCNPJ',,'1')	
	Local n1 := 0

	dbSelectArea("GW4")
	dbSetOrder(1)
	dbSeek(xFilial("GW4")+GW3->GW3_EMISDF+GW3->GW3_CDESP+GW3->GW3_SERDF+GW3->GW3_NRDF+DTOS(GW3->GW3_DTEMIS))
	While !GW4->( Eof() ) .And. GW4->GW4_FILIAL+GW4->GW4_EMISDF+GW4->GW4_CDESP+GW4->GW4_SERDF+GW4->GW4_NRDF+DTOS(GW4->GW4_DTEMIS) == ;
	xFilial("GW4")+GW3->GW3_EMISDF+GW3->GW3_CDESP+GW3->GW3_SERDF+GW3->GW3_NRDF+DTOS(GW3->GW3_DTEMIS) .And. lRet == .T. 

		If lExistCamp //Utiliza novo índice para procurar os cálculos do documento de frete
			dbSelectArea('GWF')
			GWF->(DbOrderNickName("DOCFRETE"))// Indice 6: GWF_FILIAL+GWF_CDESP+GWF_EMISDF+GWF_SERDF+GWF_NRDF+DTOS(GWF_DTEMDF)

			dbSeek(xFilial("GWF")+GW3->GW3_CDESP+GW3->GW3_EMISDF+GW3->GW3_SERDF+GW3->GW3_NRDF+DTOS(GW3->GW3_DTEMIS))
			While !GWF->(Eof()) .And. xFilial("GWF")+GWF->(GWF_CDESP+GWF_EMISDF+GWF_SERDF+GWF_NRDF+DTOS(GWF_DTEMDF)) == GW3->(GW3_FILIAL+GW3_CDESP+GW3_EMISDF+GW3_SERDF+GW3_NRDF+DTOS(GW3_DTEMIS))

				If AScan(aCalcRel, {|x| x == GWF->GWF_NRCALC}) > 0
					dbSelectArea("GWF")	
					GWF->( dbSkip() )
					Loop
				EndIf
				dbSelectArea("GWI")
				dbSetOrder(1)

				//GWI_FILIAL+GWI_NRCALC+GWI_CDCLFR+GWI_CDTPOP+GWI_CDCOMP
				dbSeek(xFilial("GWI")+GWF->GWF_NRCALC)
				While !GWI->( Eof() ) .And. xFilial("GWI")+GWF->GWF_NRCALC == GWI->GWI_FILIAL+GWI->GWI_NRCALC

					// GV2 - Componente de Frete
					dbSelectArea("GV2")
					dbSetOrder(1)
					dbSeek(xFilial("GV2")+GWI->GWI_CDCOMP)
					// GV2->GV2_CATVAL  1=Frete Unidade;2=Frete Valor;3=Taxas;4=Valor do Pedagio
					If GWI->GWI_TOTFRE == "1" .and. GV2->GV2_CATVAL == "3"

						aAdd(aTaxas,{GWI->GWI_CDCOMP,GWI->GWI_VLFRET})

					EndIf

					dbSelectArea("GWI")
					GWI->( dbSkip() )
				EndDo				

				GWF->(dbSkip())
			EndDo	
		Else	
			/* GWH */
			dbSelectArea("GWH")
			dbSetOrder(2)			
			dbSeek(xFilial("GWH")+GW4->GW4_TPDC+GW4->GW4_EMISDC+GW4->GW4_SERDC+GW4->GW4_NRDC)
			While !GWH->( Eof() ) .And. xFilial("GWH")+GW4->GW4_TPDC+GW4->GW4_EMISDC+GW4->GW4_SERDC+GW4->GW4_NRDC == ;
			GWH->GWH_FILIAL+GWH->GWH_CDTPDC+GWH->GWH_EMISDC+GWH->GWH_SERDC+GWH->GWH_NRDC

				If AScan(aCalcRel, {|x| x == GWH->GWH_NRCALC}) > 0
					dbSelectArea("GWH")	
					GWH->( dbSkip() )
					Loop
				EndIf

				dbSelectArea("GWF")
				GWF->( dbSetOrder(1) )
				If (GWF->( dbSeek(xFilial("GWF") + GWH->GWH_NRCALC) ) .And. GW3->GW3_EMISDF == GWF->GWF_TRANSP .And. GW3->GW3_TPDF == GWF->GWF_TPCALC);
				.or. (s_VLCNPJ == "2" .AND. SubStr(Posicione("GU3", 1, xFilial("GU3") +GW3->GW3_EMISDF, "GU3->GU3_IDFED"), 1, 8) == SubStr(Posicione("GU3", 1, xFilial("GU3") + GWF->GWF_TRANSP, "GU3->GU3_IDFED"), 1, 8) .And. GW3->GW3_TPDF == GWF->GWF_TPCALC )

					dbSelectArea("GWI")
					dbSetOrder(1)

					//GWI_FILIAL+GWI_NRCALC+GWI_CDCLFR+GWI_CDTPOP+GWI_CDCOMP
					dbSeek(xFilial("GWI")+GWF->GWF_NRCALC)
					While !GWI->( Eof() ) .And. xFilial("GWI")+GWF->GWF_NRCALC == GWI->GWI_FILIAL+GWI->GWI_NRCALC

						If GWI->GWI_TOTFRE == "1"
							// GV2 - Componente de Frete

							dbSelectArea("GV2")
							GV2->(dbSetOrder(1))
							IF GV2->(dbSeek(xFilial("GV2")+GWI->GWI_CDCOMP))

								If GV2->GV2_CATVAL == "3"

									AADD(aTaxas,{GWI->GWI_CDCOMP,GWI->GWI_VLFRET})

								EndIf
							EndIF

						EndIF

						dbSelectArea("GWI")
						GWI->( dbSkip() )
					EndDo				
				EndIf

				dbSelectArea("GWH")
				GWH->( dbSkip() )
			EndDo
		EndIf

		dbSelectArea("GW4")
		GW4->( dbSkip() )
	EndDo

	dbSelectArea(cAliTaxa)
	ZAP

	cAliasGZZ := GetNextAlias()
	BeginSql Alias cAliasGZZ
		SELECT * FROM %Table:GZZ% GZZ
		WHERE GZZ.GZZ_FILIAL = %Exp:GW3->GW3_FILIAL%
		  AND GZZ.GZZ_EMISDF = %Exp:GW3->GW3_EMISDF%
		  AND GZZ.GZZ_CDESP  = %Exp:GW3->GW3_CDESP%
		  AND GZZ.GZZ_SERDF  = %Exp:GW3->GW3_SERDF%
		  AND GZZ.GZZ_NRDF   = %Exp:GW3->GW3_NRDF%
		  AND GZZ.GZZ_DTEMIS = %Exp:GW3->GW3_DTEMIS%
		  AND GZZ.%NotDel%
	EndSql
	Do While (cAliasGZZ)->(!Eof())

		iTaxas := 0
		For n1 := 1 to len(aTaxas)

			if PADR(alltrim(aTaxas[n1][1]),TamSx3("GZZ_TAXA")[1]) == PADR(alltrim((cAliasGZZ)->GZZ_TAXA),TamSx3("GZZ_TAXA")[1])
				iTaxas := aTaxas[n1][2]
			endif
		Next n1

		/* Taxas */
		RecLock((cAliTaxa),.T.)
		(cAliTaxa)->OBRIGAT 	 := ""
		(cAliTaxa)->CAMPO  	     := (cAliasGZZ)->GZZ_TAXA
		(cAliTaxa)->VALOR1  	 := (cAliasGZZ)->GZZ_VALOR
		(cAliTaxa)->VALOR2  	 := iTaxas
		(cAliTaxa)->DIF  	     := (cAliasGZZ)->GZZ_VALOR - iTaxas
		(cAliTaxa)->(MsUnLock())			

		(cAliasGZZ)->(dbSkip())
	EndDo

	(cAliasGZZ)->(dbCloseArea())	

	For n1 := 1 to len(aTaxas)

		lRet := .F.
		dbSelectArea(cAliTaxa)
		(cAliTaxa)->( dbSetOrder(1) )		
		(cAliTaxa)->( DBGOTOP() )	
		While !(cAliTaxa)->( Eof() )

			if PADR(alltrim(aTaxas[n1][1]),TamSx3("GZZ_TAXA")[1]) == PADR(alltrim((cAliTaxa)->CAMPO),TamSx3("GZZ_TAXA")[1])
				lRet := .T.
			Endif
			
			(cAliTaxa)->( dbSkip() )
		EndDo	

		if !lRet
			/* Taxas */
			RecLock((cAliTaxa),.T.)
			(cAliTaxa)->OBRIGAT 	 := ""
			(cAliTaxa)->CAMPO  	     := alltrim(aTaxas[n1][1])
			(cAliTaxa)->VALOR1  	 := 0
			(cAliTaxa)->VALOR2  	 := aTaxas[n1][2]
			(cAliTaxa)->DIF  	     := 0 - aTaxas[n1][2]
			(cAliTaxa)->(MsUnLock())				

		Endif	

	NEXT N1
Return .T.
