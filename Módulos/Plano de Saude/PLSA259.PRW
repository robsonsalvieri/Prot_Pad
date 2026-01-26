#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "TOPCONN.CH"

Static aDadosAnt := {}
		
/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณPLSA259   บAutor  Roberto Barbosa       บ Data ณ  17/07/18  บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Rotina para altera็ใo do Hist๓rico de Bloqueio             บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿*/ 
Function PLSA259()
Local oBrowse

oBrowse := FWmBrowse():New()
oBrowse:SetAlias( "BA1" )
oBrowse:SetDescription( Fundesc() )	
oBrowse:SetMenuDef( "PLSA259" )
oBrowse:aOnlyFields := {"BA1_CODINT","BA1_CODEMP", "BA1_NOMUSR", "BA1_MATRIC","BA1_TIPREG", "BA1_INFSIB"}

oBrowse:Activate()

Return            

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณPLSA259   บAutor  ณRoberto Barbosa      บ Data ณ  17/07/18  บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณDefinicao de menu PLSA259								  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑณ Uso      ณ TOTVS - SIGAPLS                                            ณฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/             
Static Function MenuDef()
Private aRotina := {}
  
  aAdd( aRotina, { "Pesquisar"  , 				"PesqBrw"         , 0, 1, 0, .T. } )//"Pesquisar"
  aAdd( aRotina, { "Visualizar"  , 			   	"VIEWDEF.PLSA259", 0, 2, 0, NIL } ) //"Visualizar"
  aAdd( aRotina, { "Alterar"  , 				"VIEWDEF.PLSA259", 0, 4, 0, NIL } )//"Alterar"

Return aRotina
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณPLSA259   บAutor  ณRoberto Barbosa      บ Data ณ  17/07/18  บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณDefinicao do modelo MVC PLSA259							  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑณ Uso      ณ TOTVS - SIGAPLS                                            ณฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/              
Static Function ModelDef()											
	Static oModelB	
	Local oStruBA1 := FWFormStruct( 1, "BA1", { |cCampo| AllTrim(cCampo) $ "BA1_CODINT|BA1_CODEMP|BA1_MATRIC|BA1_TIPREG|BA1_NOMUSR|BA1_DIGITO|BA1_INFSIB" } )
	Local oStruBCA := FWFormStruct( 1, "BCA" )

	// Cria o objeto do Modelo de Dados	 
	oModelB := MPFormModel():New("PLSA259",,{ |oModelB| ConfirmaAlt(oModelB) } )
		
	// Adiciona ao modelo uma estrutura de formulแrio de edi็ใo por campo
	oModelB:AddFields( "BA1MASTER",NIL, oStruBA1 )
	oModelB:SetPrimaryKey({})

	//Faz relaciomaneto entre os compomentes do model
	oModelB:AddGrid( "BCADETAIL", "BA1MASTER", oStruBCA) 
	oModelB:GetModel( "BCADETAIL" ):SetMaxLine(999999999)

	oModelB:SetRelation( "BCADETAIL", { { "BCA_FILIAL", "xFilial( 'BCA' )" }, { "BCA_MATRIC", "BA1->(BA1_CODINT + BA1_CODEMP + BA1_MATRIC)" }, { "BCA_TIPREG", "BA1->BA1_TIPREG" } } )								
	
	//Adiciona a descricao do Modelo de Dados
	oModelB:SetDescription( FunDesc() )	

	//Adiciona a descricao do Componente do Modelo de Dados
	oModelB:GetModel( "BA1MASTER" ):SetDescription( "Beneficiario" )	
	oModelB:GetModel( "BCADETAIL" ):SetDescription( "Hist๓rico de Bloqueio" )	

	oModelB:GetModel( "BA1MASTER" ):SetOnlyQuery(.T.)
	oModelB:GetModel( "BA1MASTER" ):SetOnlyView(.T.)	

	oStruBCA:setProperty( "BCA_DATA"  , MODEL_FIELD_VALID, { |oModelGrid| PlAlteraLinha(oModelB)} )	
	oStruBCA:setProperty( "BCA_MOTBLO", MODEL_FIELD_VALID, { |oModelGrid| PlAlteraLinha(oModelB)} )	
	oStruBCA:setProperty( "BCA_DESBLO", MODEL_FIELD_TAMANHO, 30 )	

	oModelB:GetModel("BCADETAIL"):Activate()

	//////////////////////////////////////////////////////////////////////////////////////////////
	//Guarda os dados iniciais do grid para ser utilizado na validacao de alteracao
	aDadosAnt := aClone(oModelB:GetModel("BCADETAIL"):aDataModel)
Return oModelB

//-------------------------------------------------------------------
Static Function ViewDef()  
	
	local oStruBA1 := FWFormStruct( 2, "BA1", { |cCampo| AllTrim(cCampo) $ "BA1_CODINT|BA1_CODEMP|BA1_MATRIC|BA1_TIPREG|BA1_DIGITO|BA1_NOMUSR|BA1_INFSIB" } )
	Local oStruBCA := FWFormStruct( 2, "BCA", { |cCampo| AllTrim(cCampo) $ "BCA_TIPREG|BCA_TIPO|BCA_DATA|BCA_MOTBLO|BCA_DESBLO|BCA_OBS|BCA_USUOPE|BCA_BLOFAT|BCA_DATPED|BCA_DATLAN|BCA_HORLAN|BCA_SOL412|BCA_ID" } )
	Local oModelB  := FWLoadModel( "PLSA259" )

	oView := FWFormView():New()
	oView:SetModel( oModelB )

	oView:AddField( "VIEW_BA1", oStruBA1, "BA1MASTER" )
	oView:AddGrid(  "VIEW_BCA", oStruBCA, "BCADETAIL" )

	oView:CreateHorizontalBox( "SUPERIOR", 25 )
	oView:CreateHorizontalBox( "INFERIOR", 75 )
	
	oView:EnableTitleView("VIEW_BCA","Hist๓rico de Bloqueio")
	
	oView:SetOwnerView( "VIEW_BA1", "SUPERIOR"  )
	oView:SetOwnerView( "VIEW_BCA", "INFERIOR" )

	oView:addUserButton("Documentacao", "MAGIC_BMP", {|| ShellExecute("open", "https://tdn.totvs.com/pages/releaseview.action?pageId=910665757", "", "", 1)}, /*cToolTip*/, /*nShortCut*/, /*aOptions*/, /*lShowBar*/)
	
	/*Nใo permito adicionar linhas no Grid*/
	oModelB:GetModel( "BCADETAIL" ):SetNoInsertLine( .T. )
	oModelB:GetModel( "BCADETAIL" ):SetNoDeleteLine( .T. )
	
	/*Nใo permito altera็ใo nos campos*/
	oStruBCA:SetProperty( "BCA_TIPREG",MVC_VIEW_CANCHANGE,.F.)	
	oStruBCA:SetProperty( "BCA_TIPO",  MVC_VIEW_CANCHANGE,.F.)	
	oStruBCA:SetProperty( "BCA_DESBLO",MVC_VIEW_CANCHANGE,.F.)
	oStruBCA:SetProperty( "BCA_USUOPE",MVC_VIEW_CANCHANGE,.F.)
	oStruBCA:SetProperty( "BCA_BLOFAT",MVC_VIEW_CANCHANGE,.F.)
	oStruBCA:SetProperty( "BCA_DATPED",MVC_VIEW_CANCHANGE,.F.)
	oStruBCA:SetProperty( "BCA_DATLAN",MVC_VIEW_CANCHANGE,.F.)
	oStruBCA:SetProperty( "BCA_HORLAN",MVC_VIEW_CANCHANGE,.F.)	
	oStruBCA:SetProperty( "BCA_SOL412",MVC_VIEW_CANCHANGE,.F.)
	oStruBCA:setProperty( "BCA_MOTBLO", MVC_VIEW_LOOKUP, { || "BCAPLS"} )	
	oStruBA1:SetNoFolder()
	
Return oView

	
//////////////////////////////////////////////////////////////////////////////////////////////
/*/{Protheus.doc} ConfirmaAlt
description: Fun็ใo responsแvel por confirmar a altera็ใo realizada no hist๓rico de bloqueio

@param oMdAtivo, Objeto, Modelo ativo da rotina
/*/
Function ConfirmaAlt(oMdAtivo)

	Local oMdGrid  	 := oMdAtivo:GetModel("BCADETAIL")
	Local oMdBenef 	 := oMdAtivo:GetModel("BA1MASTER")
	Local dDataAnte  := aDadosAnt[oMdGrid:Length()][1][1][aScan(oMdGrid:aHeader,{|x|x[2] == "BCA_DATA"   })]
	Local cMotAnte   := aDadosAnt[oMdGrid:Length()][1][1][aScan(oMdGrid:aHeader,{|x|x[2] == "BCA_MOTBLO" })]
	Local cMatricBen := ""
	Local cChvB3x    := ""
	Local cChvB4w    := ""

	Begin Transaction

		oMdGrid:GoLine(oMdGrid:Length())
		cMatricBen := oMdGrid:GetValue("BCA_MATRIC") + oMdBenef:GetValue("BA1_TIPREG") + oMdBenef:GetValue("BA1_DIGITO")

		If oMdBenef:GetValue("BA1_INFSIB") == "1"/*SIM*/
			
			cChvB3x := PADR(oMdGrid:GetValue("BCA_MATRIC") + oMdGrid:GetValue("BCA_TIPREG") + oMdBenef:GetValue("BA1_DIGITO"),tamSX3("B3X_IDEORI")[1]) +;
						    oMdGrid:GetValue("BCA_ID") + DTOS(dDataAnte) + "4"
			
			//////////////////////////////////////////////////////
			//Atualiza a tabela B3X da central de obrigacoes
			AtuRegB3X(cChvB3x, oMdGrid:GetValue("BCA_DATA"), cUserName)

			//////////////////////////////////////////////////////
			//Atualiza a tabela B4W da central de obrigacoes
			cChvB4w := PADR(cMatricBen, tamSX3("B4W_MATRIC")[1]) + oMdGrid:GetValue("BCA_ID") + DTOS(dDataAnte) + "0"
			AtuHistB4W(cChvB4w, oMdGrid:GetValue("BCA_DATA"), oMdGrid:GetValue("BCA_MOTBLO"))
		EndIf
		
		oMdGrid:GoLine(oMdGrid:Length())

		//////////////////////////////////////////////////////////
		//atualiza a data de bloqueio no cadastro do beneficiario
		AtlBloBen(cMatricBen, oMdGrid:GetValue("BCA_DATA"), oMdGrid:GetValue("BCA_MOTBLO"), oMdGrid:GetValue("BCA_TIPO"))
		
		////////////////////////////////////////////////////////////////////////////////////
		//atualiza a data de bloqueio no cadastro da familia para os casos de bloqueio
		//do titular onde nao possui dependente na familia
		AtlBloFam(oMdGrid:GetValue("BCA_MATRIC"), oMdGrid:GetValue("BCA_DATA"), ;
				  oMdGrid:GetValue("BCA_MOTBLO"), oMdGrid:GetValue("BCA_ID")  , ;
				  oMdGrid:GetValue("BCA_TIPO")  , dDataAnte)

		////////////////////////////////////////////////////////////////////////////////////
		//Gera um historico das alteracoes no historico de bloqueio
		GrvAltHis(oMdAtivo, dDataAnte, cMotAnte)
	End Transaction
return .T.

/*ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ_aDados()   บAutor  ณRoberto Barbosa   บ Data ณ  23/07/18บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Carrego a informa็ใo antes da altera็ใo em tela  		  บฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿*/
Static Function _aDados(oModelB)  
	Local oBCA
	Local aDados :=  {}
	Local lDad   := .T.
		
	oModelB := FWLoadModel( "PLSA259" )		
	lDad := oModelB:Activate()		

	If lDad
		oBCA   := oModelB:GetModel("BCADETAIL")
		aDados := aClone(oBCA:aDataModel)
	EndIf
			
Return aDados

/*ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma   บAutor  ณRoberto Barbosa   บ Data ณ  08/08/18บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Fun็ใo responsแvel por gravar hist๓rico de Altera็๕es 		บฑฑ
			   Na tabela BCA
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿*/
Static Function GrvAltHis(oModelB,dData,cMBloAnt)
	
	Local oBCA	  := oModelB:GetModel("BCADETAIL")
	Local oBA1	  := oModelB:GetModel("BA1MASTER")	
	Local dDatAtu := CTOD(" ") //Data ap๓s a altera็ใo
	Local cUsuOpe := UsrFullName(RetCodUsr()) 	
	Local cMatric := ""
	Local cDigito := ""
	Local cObs    := ""
	Local cLog    := ""
	Local cTipo   := ""	
	Local cTipReg := ""

	if oModelB <> nil
			
		dDatAtu := oBCA:GetValue("BCA_DATA")
		cMatric := oBCA:GetValue("BCA_MATRIC") + oBCA:GetValue("BCA_TIPREG")
		cDigito	:= oBA1:GetValue("BA1_DIGITO")
		cObs    := oBCA:GetValue("BCA_OBS")
		cTipo   := oBCA:GetValue("BCA_TIPO")
		cTipReg := oBCA:GetValue("BCA_TIPREG")
		
		BH4->(RecLock("BH4",.T.))
			BH4->BH4_FILIAL := xFilial("BH4")
			BH4->BH4_MATRIC := cMatric + cDigito 
			BH4->BH4_DIGITO := cDigito
			BH4->BH4_DATA	:= Date() //Data da altera็ใo
			BH4->BH4_HORA	:= Time() //Hora da Altera็ใo
			BH4->BH4_DTANT	:= dData
			BH4->BH4_DTATU	:= dDatAtu
			BH4->BH4_MOTBLO := cMBloAnt
			BH4->BH4_OBS 	:= cObs
			BH4->BH4_USUOPE	:= cUsuOpe
			BH4->BH4_TIPO	:= cTipo
			BH4->BH4_TIPREG	:= cTipReg		
		BH4->(MsUnlock())	
		
		cLog += "Altera็๕es no Hist๓rico de Bloqueios gravado com sucesso!" + CRLF
		FWLogMsg("WARN",, "SIGAPLS", funName(), "", "01", "Altera็ใo no Hist๓rico de bloqueio/desbloqueio gravado com sucesso!" + CRLF , 0, 0, {})
	EndIf
		
Return Nil

//////////////////////////////////////////////////////////////////////////////////////////////////////////
/*/{Protheus.doc} AtlBloBen
description: atualiza a data de bloqueio no cadastro do beneficiario

@param cBA1Chv, Caracter, chave da tabela BA1
@param dDtBloq, Data    , data de bloqueio
@param cMtBloq, Caracter, motivo do bloqueio
/*/
Static Function AtlBloBen(cBA1Chv, dDtBloq, cMtBloq, cTipo)
	
	Default cBA1Chv := ""
	Default dDtBloq := CTOD("")
	Default cMtBloq := ""
	Default cTipo 	:= ""

	BA1->(DbSetOrder(2))

	If BA1->(MsSeek(xFilial("BA1") + cBA1Chv))
		BA1->(RecLock("BA1",.F.))
		if cTipo == "0"
			BA1->BA1_DATBLO := dDtBloq
			BA1->BA1_MOTBLO := cMtBloq
		elseif cTipo == "1"
			BA1->BA1_DATBLO := ctod("")
			BA1->BA1_MOTBLO := ""
		endif
		BA1->(MsUnlock())
	EndIf
Return

//////////////////////////////////////////////////////////////////////////////////////////////////////////
/*/{Protheus.doc} AtlBloBen
description: atualiza a data de bloqueio no cadastro da familia e no historico de bloqueio da familia

@param cBA3Chv , Caracter, chave da tabela BA3
@param dBloq   , Data    , data de bloqueio
@param cMtvo   , Caracter, motivo do bloqueio
@param cIdTbBCA, Caracter, id da tabela BCA
/*/
Static Function AtlBloFam(cBA3Chv, dBloq, cMtvo, cIdTbBCA, cTpBlq, dDtAntBlq)
	
	Default cBA3Chv   := ""
	Default dBloq     := CTOD("")
	Default cMtvo     := ""
	Default	cIdTbBCA  := ""
	Default	cTpBlq    := ""
	Default	dDtAntBlq := STOD("")
	
	BA3->(DbSetOrder(1))
	If BA3->(MsSeek(xFilial("BA3") + cBA3Chv))
		
		If !Empty(BA3->BA3_DATBLO)
		
			BA3->(RecLock("BA3",.F.))
				BA3->BA3_DATBLO := dBloq
				BA3->BA3_MOTBLO := cMtvo
			BA3->(MsUnlock())

			BC3->(DbSetOrder(3))
			If BC3->(MsSeek(xFilial("BC3") + cBA3Chv + cIdTbBCA + cTpBlq + DTOS(dDtAntBlq)))
				BC3->(RecLock("BC3",.F.))
					BC3->BC3_DATA   := dBloq
					BC3->BC3_MOTBLO := cMtvo
				BC3->(MsUnlock())
			EndIf
		EndIf
	EndIf
Return

//////////////////////////////////////////////////////////////////////////////////////////////
/*/{Protheus.doc} AtuRegB3X
description: Funcao criada para atualizar a tabela B3X da central de obrigacoes de acordo com a rotina de
alteracao de historico de bloqueio PSLA259

@param cChaveBCA, Caracter, chave da tabela BCA
@param dDataNova, Data    , data de bloqueio atualizada
@param cUsrSist , Caracter, usuario do sistema
/*/
Function AtuRegB3X(cChaveBCA, dDataNova, cUsrSist)

	Default cChaveBCA   := ""

	B3X->(DbSetOrder(6))

	If B3X->(MsSeek(xFilial("B3X") + cChaveBCA))
		B3X->(RecLock("B3X",.F.))
			B3X->B3X_DATA   := dDataNova
			B3X->B3X_DATOPE := dDataBase
			B3X->B3X_USUARI := cUsrSist
			B3X->B3X_STATUS := "2" /*valido*/
		B3X->(MsUnlock())
				
		CnBlReaPdte(B3X->(Recno()))
	EndIf

Return

//////////////////////////////////////////////////////////////////////////////////////////////
/*/{Protheus.doc} AtuHistB4W

Funcao criada para atualizar a tabela de historico de bloqueio(B4W) na central de obrigacoes

@param cBCAChave, Caracter, chave da tabela BCA
@param dDtBlqAtu, Data    , data de bloqueio atualizada
@param cMotBloq , Caracter, motivo do bloqueio
/*/
Function AtuHistB4W(cBCAChave, dDtBlqAtu, cMotBloq)
	
	Default cBCAChave :=""
	
	B4W->(DbSetOrder(3))
	If B4W->(MsSeek(xFilial("B4W") + cBCAChave))
		B4W->(RecLock("B4W",.F.))
			B4W->B4W_DATA	:= dDtBlqAtu
			B4W->B4W_MOTBLO	:= If(!Empty(cMotBloq), cMotBloq, "")
			B4W->B4W_STATUS := "1" /*ativa o registro*/
		B4W->(MsUnlock())
	EndIf
Return

//////////////////////////////////////////////////////////////////////////////////////////////
/*/{Protheus.doc} PlAlteraLinha
description: Verifica se a linha que esta sendo alterada ้ a ultima linha do grid

@param oMdPrincipal, Objeto, Modelo principal da rotina
/*/
Function PlAlteraLinha(oMdPrincipal, aDadosCall)

	Local oMdBCA   := NIL
	Local oMdBA1   := NIL
 	Local lRetAlt  := .T.
	Local dDatAnt  := CTOD("")
	
	Default oMdPrincipal  := NIL
	Default aDadosCall := {}

	oMdBCA := oMdPrincipal:GetModel("BCADETAIL")
	oMdBA1 := oMdPrincipal:GetModel("BA1MASTER")
	
	oMdBCA:GoLine(oMdBCA:GetLine())

	if Len(aDadosCall) > 0
		aDadosAnt := aDadosCall
	endif

	dDatAnt := aDadosAnt[oMdBCA:Length()][1][1][aScan(oMdBCA:aHeader,{|x|x[2] == "BCA_DATA" })]

	//////////////////////////////////////////////////////////////////////////////////////////////
	//Verifica se a linha que esta sendo alterada ้ a ultima linha do grid
	If oMdBCA:GetLine() < oMdBCA:Length()
		lRetAlt := .F.
		oMdPrincipal:SetErrorMessage("BCADETAIL", "" , "BCADETAIL" , "" , "Aten็ใo",;
								     "Nใo ้ permitido alterar datas de " + iif(oMdBCA:GetValue("BCA_TIPO")=="0", "bloqueio", "desbloqueio") + " que jแ tenham expirado",;
									 "A altera็ใo da data serแ permitida apenas para o ๚ltimo " + iif(oMdBCA:GetValue("BCA_TIPO")=="0", "bloqueio", "desbloqueio") + ", desde que ainda esteja vigente")      
	
	//////////////////////////////////////////////////////////////////////////////////////////////
	//Verifica se a linha que esta sendo alterada ้ um registro de desbloqueio
	// ElseIf oMdBCA:GetValue("BCA_TIPO") == "1" //desbloqueio
	// 	lRetAlt := .F.
	// 	oMdPrincipal:SetErrorMessage("BCADETAIL", "" , "BCADETAIL" , "" , "Aten็ใo",;
	// 							     "Nใo ้ permitido alterar datas de desbloqueio")

	//////////////////////////////////////////////////////////////////////////////////////////////
	//Verifica se o Historico de bloqueio do beneficiario pode ser alterado
	//respeitando as regras da Central de Obrigacoes
	ElseIf !PlsVldHist(dDatAnt, oMdPrincipal)	
		lRetAlt := .F.
	
	ElseIf oMdBCA:Length() > 1
		if lRetAlt
			if aDadosAnt[oMdBCA:Length()-1][1][1][aScan(oMdBCA:aHeader,{|x|x[2] == "BCA_NIVBLQ" })] == "U"
				//////////////////////////////////////////////////////////////////////////////////////////////
				//pega a data da ๚ltima opera็ใo
				dDataLimite := aDadosAnt[oMdBCA:Length()-1][1][1][aScan(oMdBCA:aHeader,{|x|x[2] == "BCA_DATA" })]
				
				//////////////////////////////////////////////////////////////////////////////////////////////
				//Verifica se a data da opera็ใo atual ้ anterior a data da ๚ltima opera็ใo
				If oMdBCA:GetValue("BCA_DATA") < dDataLimite 
					lRetAlt := .F.
					oMdPrincipal:SetErrorMessage("BCADETAIL", "" , "BCADETAIL" , "" , "Aten็ใo",;
												"A nova data de " + iif(oMdBCA:GetValue("BCA_TIPO")=="0", "bloqueio", "desbloqueio") + " nใo pode ser anterior a ๚ltima data de " + iif(oMdBCA:GetValue("BCA_TIPO")=="0", "desbloqueio", "bloqueio") + "",;
												"Insira uma data para um perํodo posterior a ๚ltima data de " + iif(oMdBCA:GetValue("BCA_TIPO")=="0", "desbloqueio", "bloqueio") + "")
				EndIf
			endif
		endif
	EndIf

Return lRetAlt

//////////////////////////////////////////////////////////////////////////////////////////////
/*/{Protheus.doc} VerifDic
Com o fonte atualizado, ้ necessario que todos os campos e indices estejam criados no ambiente
caso contrario nao sera possivel utilizar a rotina

Rotina temporaria (podera ser descontinuada no proximo release) 

/*/
Function VerifDic()
Return VerifCampos() .AND. VerifIndices() .AND. VersaoFontes()

//////////////////////////////////////////////////////////////////////////////////////////////
/*/{Protheus.doc} VerifCampos
Verifica se os campos necessarios para utilizar as novas implementacoes na rotina foram criados

Rotina temporaria (podera ser descontinuada no proximo release)

@return lVerOk, Retorna .T. se os campos estiverem criados, .F. caso contrario
/*/
Static Function VerifCampos()
	
	Local cCampoId  := ""
	Local lVerOk    := .T.
	Local nOpcAviso := 0

	If     BCA->(FieldPos("BCA_ID"))    == 0
		cCampoId := "BCA_ID"
		lVerOk := .F.
	
	ElseIf BC3->(FieldPos("BC3_IDBCA")) == 0
		cCampoId := "BC3_IDBCA"
		lVerOk := .F.
	
	ElseIf B3X->(FieldPos("B3X_IDBCA")) == 0
		cCampoId := "B3X_IDBCA"
		lVerOk := .F.
	
	ElseIf B4W->(FieldPos("B4W_IDBCA")) == 0
		cCampoId := "B4W_IDBCA"
		lVerOk := .F.
	
	ElseIf BH4->(FieldPos("BH4_IDBCA")) == 0
		cCampoId := "BH4_IDBCA"
		lVerOk := .F.
	EndIf

	If !lVerOk
		nOpcAviso := Aviso( "Entre em Contato Com o Administrador do Sistema",;
							"O campo " + cCampoId +" precisa ser criado para a correta utiliza็ใo da rotina." + CHR(13)+CHR(10)+CHR(13)+CHR(10) +;
							"Clique no botใo de documenta็ใo, copie o link que serแ exibido no navegador e envie para o administrador.",;
							{"OK", "Documenta็ใo"},;
							3,;
					  	  )

		If nOpcAviso == 2 //Exibe documentacao

			ShellExecute("Open", "https://tdn.totvs.com/pages/releaseview.action?pageId=910665757", "", "", 1)
		EndIf
	EndIf
Return lVerOk

//////////////////////////////////////////////////////////////////////////////////////////////
/*/{Protheus.doc} VerifIndices
Verifica se os indices necessarios para utilizar as novas implementacoes na rotina foram criados

Rotina temporaria (podera ser descontinuada no proximo release)

@return lIndOk, Retorna .T. se os indices estiverem criados, .F. caso contrario
/*/
Static Function VerifIndices()
	
	Local cIndice   := ""
	Local cTabela   := ""
	Local nSelAviso := 0
	Local lIndOk	:= .T.

	If     Empty(BCA->(IndexKey(3)))
		cIndice := "3"
		cTabela := "BCA"
		lIndOk := .F.

	ElseIf Empty(BC3->(IndexKey(3)))
		cIndice := "3"
		cTabela := "BC3"
		lIndOk := .F.

	ElseIf Empty(B4W->(IndexKey(3)))
		cIndice := "3"
		cTabela := "B4W"
		lIndOk := .F.

	ElseIf !("B3X_IDBCA" $ B3X->(IndexKey(6)))
		cIndice := "6"
		cTabela := "B3X"
		lIndOk := .F.
	EndIf

	If !lIndOk
		nSelAviso := Aviso( "Entre em Contato Com o Administrador do Sistema",;
							"O ํndice " + cIndice +" da tabela " + cTabela + " precisa ser criado ou atualizado para a correta utiliza็ใo da rotina." + CHR(13)+CHR(10)+CHR(13)+CHR(10) +;
							"Clique no botใo de documenta็ใo, copie o link que serแ exibido no navegador e envie para o administrador.",;
							{"OK", "Documenta็ใo"},;
							3,;
					  	  )

		If nSelAviso == 2 //Exibe documentacao
			ShellExecute("Open", "https://tdn.totvs.com/pages/releaseview.action?pageId=910665757", "", "", 1)
		EndIf
	EndIf
Return lIndOk

//////////////////////////////////////////////////////////////////////////////////////////////
/*/{Protheus.doc} VersaoFontes
Verifica se os fontes principais da rotina estใo atualizados

Rotina temporaria (podera ser descontinuada no proximo release)

@return lRetVer, Retorna .T. se os fontes estiverem atualizados, .F. caso contrario
/*/
Static Function VersaoFontes()
	
	Local cFonte  := ""
	Local lRetVer := .T.
	Local nOpcSel := 0

	If     GetApoInfo("PLSA260.PRW")[4] < sToD("20250129")
		cFonte := "PLSA260.PRW"
		lRetVer := .F.
	
	ElseIf GetApoInfo("PLSMVCBENE.PRW")[4] < sToD("20250129")
		cFonte := "PLSMVCBENE.PRW"
		lRetVer := .F.
	EndIf

	If !lRetVer

		nOpcSel := Aviso( "Entre em Contato Com o Administrador do Sistema",;
						  "O fonte " + cFonte + " estแ desatualizado, entre em contato com o administrador do sistema para atualiza็ใo." + CHR(13)+CHR(10)+CHR(13)+CHR(10) +;
						  "Clique no botใo de documenta็ใo, copie o link que serแ exibido no navegador e envie para o administrador.",;
						  {"OK", "Documenta็ใo"},;
						  3,;
			            )

		If nOpcSel == 2 //Exibe documentacao
			ShellExecute("Open", "https://tdn.totvs.com/pages/releaseview.action?pageId=910665757", "", "", 1)
		EndIf

	EndIf
Return lRetVer
