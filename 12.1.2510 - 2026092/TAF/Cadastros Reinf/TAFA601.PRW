#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "TAFA601.CH"

//-------------------------------------------------------------------
/*/{Protheus.doc} TAFA601
Cadastro MVC - Tabela de Cadastros do SCP (R-1050)

@author Wesley Matos
@since 17/02/2022

@version 1.0
/*/
//-------------------------------------------------------------------
Function TAFA601()

If TAFAlsInDic( "V82" )
	BrowseDef()
Else
    MsgInfo("Prezado cliente, esta rotina estará disponível após a liberação da REINF 2.0","Aviso - REINF")
endif

Return()

//-------------------------------------------------------------------
/*/{Protheus.doc} MenuDef
Funcao generica MVC com as opcoes de menu

@author Wesley Matos
@since 17/02/2022

@version 1.0
/*/
//-------------------------------------------------------------------
Static Function MenuDef()

Local aFuncao	as array
Local aRotina	as array
Local lReinf20  as array

aFuncao	:=	{}
aRotina	:=	{}

lMenuDif := Iif( Type( "lMenuDif" ) == "U", .F., lMenuDif )
lReinf20 := AllTrim(StrTran(SuperGetMV('MV_TAFVLRE',.F.,''),'_','')) >= '20101'

If lReinf20
    aAdd( aFuncao, { "", "TAF601Xml", "1" } )	
    aAdd( aFuncao, { "", "TAFXmlLote( 'V82', 'R-1050', 'TabLig', 'TAF601Xml', 5, oBrowse)", "5" } )
    aAdd( aFuncao, { "", "TAF601Exc()", "6" } )
    aAdd( aFuncao, { "", "TAF601Exc(.t.)", "9" } )

    If lMenuDif
        ADD OPTION aRotina TITLE STR0001 ACTION "VIEWDEF.TAFA601" OPERATION 2 ACCESS 0 //"Visualizar"
        ADD OPTION aRotina TITLE 'incluir' ACTION "VIEWDEF.TAFA601" OPERATION 3 ACCESS 0 //"incluir"
    Else
        aRotina := TAFMenuReinf( "TAFA601", aFuncao )
    endif
else
    ADD OPTION aRotina Title STR0007 Action 'VIEWDEF.TAFA546' OPERATION 2 ACCESS 0
endif

Return( aRotina )

//-------------------------------------------------------------------
/*/{Protheus.doc} ModelDef
Funcao generica MVC do model

@return oModel - Objeto do Modelo MVC

@author Wesley Matos
@since 17/02/2022

@version 1.0
/*/
//-------------------------------------------------------------------
Static Function ModelDef()
    Local oStruV82 	  as object
    Local oModel 	  as object

    oStruV82 	:= FWFormStruct( 1, 'V82' )
	oModel		:= MPFormModel():New( 'TAFA601' , , , {|oModel| SaveModel( oModel ) })

	oModel:AddFields('MODEL_V82', /*cOwner*/, oStruV82)
	oModel:GetModel('MODEL_V82'):SetPrimaryKey({'V82_FILIAL', 'V82_ID', 'V82_VERSAO'})

Return oModel

//-------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
Funcao generica MVC do View

@return oView - Objeto da View MVC

@author Wesley Matos
@since 17/02/2022

@version 1.0
/*/
//-------------------------------------------------------------------
Static Function ViewDef()
    Local 	oModel 		:= FWLoadModel( 'TAFA601' )
    Local 	oView 		:= FWFormView():New()
    Local 	oStruV82 	:= Nil
    Local 	oStruV82b 	:= Nil

    oView:SetModel( oModel )

    cCmpFil  := "V82_EVENTO|V82_ATIVO|V82_TPAMB|V82_TPENTL|V82_CNPJ|V82_INIPER|V82_FINPER|V82_XMLID|"
    oStruV82  := FwFormStruct( 2, "V82", {|x| AllTrim(x) + "|" $ cCmpFil } )

    cCmpFil  := 'V82_PROTUL|V82_PROTPN|'
    oStruV82b := FwFormStruct( 2, "V82", {|x| AllTrim(x) + "|" $ cCmpFil } )

    oView:AddField("VIEW_V82A",oStruV82, 'MODEL_V82')
    oView:AddField("VIEW_V82B",oStruV82b,'MODEL_V82')

    oView:CreateHorizontalBox("PAINEL_PRINCIPAL",100)
    oView:CreateFolder( "FOLDER_SUPERIOR", "PAINEL_PRINCIPAL" )
    oView:AddSheet( "FOLDER_SUPERIOR", "ABA01", STR0002 )
    oView:AddSheet( "FOLDER_SUPERIOR", "ABA02", STR0006 )

    oView:CreateHorizontalBox( "V82_BOX_A", 50,,, "FOLDER_SUPERIOR", "ABA01" )
    oView:CreateHorizontalBox( "V82_BOX_B", 50,,, "FOLDER_SUPERIOR", "ABA02" )
    
    oView:SetOwnerView( 'VIEW_V82A', 'V82_BOX_A' )
    oView:SetOwnerView( 'VIEW_V82B', 'V82_BOX_B' )

    oStruV82b:RemoveField('V82_PROTPN')
    oStruV82:RemoveField('V82_XMLID')
    oStruV82:RemoveField('V82_ATIVO')
    oStruV82:RemoveField('V82_EVENTO')

Return oView 

//-------------------------------------------------------------------
/*/{Protheus.doc} BrowseDef
Browse definition

@author Wesley Matos
@since 18/02/2022
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function BrowseDef()

	Private oBrowse	as object 

	oBrowse	:=	FWMBrowse():New()

	oBrowse:SetDescription( STR0002 )
	oBrowse:SetAlias( "V82" )
	oBrowse:SetMenuDef( "TAFA601" )
	oBrowse:SetFilterDefault( "V82_ATIVO == '1'" )

	oBrowse:AddLegend( "V82_EVENTO == 'I' ", "GREEN"	, STR0003 ) //"Registro Incluído"
	oBrowse:AddLegend( "V82_EVENTO == 'A' ", "YELLOW"	, STR0004 ) //"Registro Alterado"
	oBrowse:AddLegend( "V82_EVENTO == 'E' ", "RED"		, STR0005 ) //"Registro Excluído"

    oBrowse:Activate()

Return( oBrowse )


//-------------------------------------------------------------------
/*/{Protheus.doc} SaveModel
Funcao para validação de gravação do modelo

@Param  oModel -> Modelo de dados

@Return .T.

@Author Wesley Matos
@Since 17/02/2022
@Version 1.0
/*/
//-------------------------------------------------------------------
Static Function SaveModel( oModel )

	Local nOperation 	as numeric
	Local lRetorno		as logical

	nOperation 			:= oModel:GetOperation()
	lRetorno			:= .T.
	
	FWFormCommit( oModel )

Return( lRetorno )


//-------------------------------------------------------------------
/*/{Protheus.doc} TAFA601Xml
Funcao de geracao do XML para atender o registro R-1050
Quando a rotina for chamada o registro deve estar posicionado

@Return:cXml
cXml - Estrutura do Xml do Layout R-1050

@author Jose Felipe|Verônica Almeida
@since 09/11/2022

@version 1.0

/*/
//-------------------------------------------------------------------
Function TAF601Xml(cAlias,nRecno,nOpc,lJob)

Local cXml        as character
Local cLayout     as character         
Local cEvento     as character         
Local cReg        as character 
Local cDtIni      as character  
Local cDtFin      as character
Local cDtIniAtu   as character
Local cDtFinAtu   as character
Local cId 	      as character 
Local cVerAnt	  as character  
Local cNameXSD	  as character
Local cAliasTemp  as character
Local cQuery      as character

Local oStatV82    as object


cXml       	:= ""
cLayout    	:= "1050"
cEvento    	:= "exclusao"
cReg		:= "TabLig"
cDtIni     	:= ""    
cDtFin     	:= ""	  
cDtIniAtu  	:= "" 
cDtFinAtu  	:= "" 
cId 	    := ""
cVerAnt	 	:= ""
cNameXSD	:= "1050TabLig"
cAliasTemp  := GetNextAlias()

cDtIniAtu	:= Iif(!Empty(V82->V82_INIPER),Substr(V82->V82_INIPER,1,4) + "-" + Substr(V82->V82_INIPER,5,6),"") //Faço o IIf pois se a data estiver vazia a string recebia '  -  -   '
cDtFinAtu	:= Iif(!Empty(V82->V82_FINPER),Substr(V82->V82_FINPER,1,4) + "-" + Substr(V82->V82_FINPER,5,6),"")
cQuery      := ""

oStatV82 := Nil
cXml +=	"<infoLig>"
If V82->V82_EVENTO == "A"
    cEvento := "alteracao"

    cId := V82->V82_ID 
    cVerAnt := V82->V82_VERANT
    

    If oStatV82 == Nil

        cQuery := " SELECT "
        cQuery += "		V82.V82_INIPER INIPER, "
        cQuery += " 	V82.V82_FINPER FINPER "
        cQuery += " FROM " + RetSqlName("V82") + " V82 " 
        cQuery += " WHERE V82.V82_FILIAL= ? "
        cQuery += "     AND V82.V82_ID = ? "
        cQuery += "     AND V82.V82_VERSAO = ? "
        cQuery += "     AND V82.D_E_L_E_T_ = ? "

        oStatV82 	:= FWPreparedStatement():New()
        oStatV82:SetQuery(cQuery)

    endif
        
    oStatV82:SetString(1,xFilial('V82'))
    oStatV82:SetString(2,cId)
    oStatV82:SetString(3,cVerAnt)
    oStatV82:SetString(4,' ')

    dbUseArea(.T., "TOPCONN", TCGenQry(, , oStatV82:GetFixQuery()), cAliasTemp, .F., .T.)

    cDtIni := Iif(!Empty((cAliasTemp)->INIPER),Substr((cAliasTemp)->INIPER,1,4) + "-" + Substr((cAliasTemp)->INIPER,5,6),"")
    cDtFin := Iif(!Empty((cAliasTemp)->FINPER),Substr((cAliasTemp)->FINPER,1,4) + "-" + Substr((cAliasTemp)->FINPER,5,6),"")

    (cAliasTemp)->( DbCloseArea() )
Else
    If V82->V82_EVENTO == "I"
        cEvento := "inclusao"
    endif
    cDtIni  := Iif(!Empty(V82->V82_INIPER),Substr(V82->V82_INIPER,1,4) + "-" + Substr(V82->V82_INIPER,5,6),"") //Faço o IIf pois se a data estiver vazia a string recebia '  -  -   '
    cDtFin  := Iif(!Empty(V82->V82_FINPER),Substr(V82->V82_FINPER,1,4) + "-" + Substr(V82->V82_FINPER,5,6),"")
endif

cXml +=				"<" + cEvento + ">"
            
xTafTagGroup("ideEntLig",{	{"tpEntLig"	,V82->V82_TPENTL ,,.F.},;
                            {"cnpjLig"	,V82->V82_CNPJ	 ,,.F.},;
                            {"iniValid"	,cDtIni 		 ,,.F.},;
                            {"fimValid"	,cDtFin 		 ,,.T.}},;
                            @cXml)

If V82->V82_EVENTO == "A"
    If TAFAtDtVld( "V82", V82->V82_ID, V82->V82_INIPER, V82->V82_FINPER, V82->V82_VERANT, .T. )
        cXml += 		"<novaValidade>"
        cXml +=	            xTafTag("iniValid",cDtIniAtu)
        cXml +=	            xTafTag("fimValid",cDtFinAtu,,.T.)
        cXml += 		"</novaValidade>"
    endif
endif

cXml +=				"</" + cEvento + ">"
cXml +=			"</infoLig>"

cXml := TAFXmlReinf( cXml, "V82", cLayout, cReg, ,, cNameXSD)

If !lJob
    xTafGerXml( cXml, cLayout,,,,,,"R-" )        
endif

Return(cXml)
//-------------------------------------------------------------------
/*/{Protheus.doc} TAF601Exc
Funcao que gera a exclusão do evento

@Return .T.

@author Vogas
@since 14/08/2024
@Version 1.0
/*/
//-------------------------------------------------------------------
Function TAF601Exc(lDesfaz)

Local oModel	    as object
Local oModelV82     as object
Local aGrava     	as array
Local nlI   		as numeric
Local nlY	    	as numeric
Local nRecno 		as numeric
Local cAlias        as character
Local cVersao       as character
Local cVerAnt    	as character
Local cProtocolo 	as character
Local cEvento	 	as character
Local cProcId		as character
Local lAuto			as logical

Default lDesfaz := .f.

oModel		:= FWLoadModel( 'TAFA601' ) 
oModelV82 	:= Nil
nlI			:= 0
nlY   		:= 0
cVersao   	:= ""
cVerAnt   	:= ""
cProtocolo	:= ""
cEvento	    := ""
nRecno 	    := recno()
aGrava    	:= {}
cAlias		:= alias()
cProcId		:= ( cAlias )->&( cAlias + "_PROCID" ) 
lAuto		:= IsBlind()

Begin Transaction

    if !lDesfaz
        if 	( cAlias )->&( cAlias + '_EVENTO' ) == 'E'
           	MsGinfo(STR0008) //Para o evento selecionado use a opçao 'Desfazer Exclusão'.
        elseIf ( cAlias )->&( cAlias + "_STATUS" ) == "4" .and.  ( cAlias )->&( cAlias + "_EVENTO" ) <> "E"
            If lauto .or. ApMsgNoYes(STR0009) //O Evento a ser excluído está transmitido ao governo  e autorizado, o mesmo será desativado e será gerado um novo registro de Exclusão que deverá ser transmitido. Deseja prosseguir?

				oModel:SetOperation( 4 )
				oModel:Activate()				
				("V82")->( DBGoTo( nRecno ) )			
				oModelV82 := oModel:GetModel( 'MODEL_V82' )

				//³Busco a versao anterior do registro para gravacao do rastro³
				cVerAnt    	:= oModelV82:GetValue( "V82_VERSAO" )
				cProtocolo 	:= oModelV82:GetValue( "V82_PROTUL" )
				cEvento		:= oModelV82:GetValue( "V82_EVENTO" )
				cIdT9CC1G	:= oModelV82:GetValue( "V82_ID" ) 
			
				/*------------------------------------------------------------------
				| Neste momento eu gravo as informacoes que foram carregadas       |
				| na tela, pois neste momento o usuario ja fez as modificacoes que |
				| precisava e as mesmas estao armazenadas em memoria, ou seja,     |
				| nao devem ser consideradas neste momento                         |
				------------------------------------------------------------------*/
				
			    For nlI := 1 To 1
					For nlY := 1 To Len( oModelV82:aDataModel[ nlI ] )
						Aadd( aGrava, { oModelV82:aDataModel[ nlI, nlY, 1 ], oModelV82:aDataModel[ nlI, nlY, 2 ] } )
					Next
				Next

				/*-----------------------------------------------------------
				|Seto o campo como Inativo e gravo a versao do novo registro|
				|no registro anterior                                       |
				|                                                           |
				|ATENCAO -> A alteracao destes campos deve sempre estar     |
				|abaixo do Loop do For, pois devem substituir as informacoes|
				|que foram armazenadas no Loop acima                        |
				-----------------------------------------------------------*/
				FAltRegAnt( 'V82', '2' )
				
				/*----------------------------------------------------
				| Neste momento eu preciso setar a operacao do model |
				| como Inclusao                                      |
				----------------------------------------------------*/
				oModel:DeActivate()
				oModel:SetOperation( 3 )
				oModel:Activate()
				
				/*-------------------------------------------------------
				|Neste momento eu realizo a inclusao do novo registro ja|
				|contemplando as informacoes alteradas pelo usuario     |
				-------------------------------------------------------*/
				For nlI := 1 To Len( aGrava )
					oModel:LoadValue( 'MODEL_V82', aGrava[ nlI, 1 ], aGrava[ nlI, 2 ] )
				Next
			
				//Busco a versao que sera gravada
				cVersao := xFunGetVer()
			
				/*-------------------------------------------------------------
				| ATENCAO -> A alteracao destes campos deve sempre estar      |
				| abaixo do Loop do For, pois devem substituir as informacoes |
				| que foram armazenadas no Loop acima                         |
				-------------------------------------------------------------*/
				oModel:LoadValue( 'MODEL_V82', 'V82_VERSAO', cVersao )
				oModel:LoadValue( 'MODEL_V82', 'V82_VERANT', cVerAnt )
				oModel:LoadValue( 'MODEL_V82', 'V82_PROTPN', cProtocolo )
				oModel:LoadValue( 'MODEL_V82', 'V82_PROTUL', "" )
			
				/*----------------------------------------------------------------
				| Tratamento para que caso o Evento Anterior fosse de exclusão   |
				| seta-se o novo evento como uma "nova inclusão", caso contrário |
                | o evento passar a ser uma alteração                            |
				----------------------------------------------------------------*/
				oModel:LoadValue( "MODEL_V82", "V82_EVENTO", "E" )
				oModel:LoadValue( "MODEL_V82", "V82_ATIVO" , "1" )
				oModel:LoadValue( "MODEL_V82", "V82_STATUS", " " )
				oModel:LoadValue( "MODEL_V82", "V82_XMLID", " " )
							
				//Gravo
				FwFormCommit( oModel )				
				//Gravo o mesmo _PROCID do registro inativado
				TafEndGRV( "V82","V82_PROCID", cProcId, V82->(Recno())  )
            endif
		elseIf ( cAlias )->&( cAlias + "_EVENTO" ) == "I"
			if ( cAlias )->&( cAlias + "_STATUS" ) $ "2|6"
				Aviso( STR0018, STR0010, { STR0019 }, 2 ) //Atenção##"Não é possivel realizar a exclusão de um evento que está aguardando o retorno do RET." ##"Fechar"
			else
				if lauto .or. ApMsgNoYes(STR0011)//O Evento a ser excluído ainda não foi transmitido ao governo, o mesmo será apagado permanentemente da base. Deseja prosseguir?
					cIdDel := V82->V82_PROCID
					oModel:SetOperation( MODEL_OPERATION_DELETE ) 
					oModel:Activate()					 
					cQryExc := "SELECT R_E_C_N_O_, C1G_ID FROM "+RetSqlName("C1G")+ " WHERE D_E_L_E_T_ = ' ' AND C1G_PROCID ='"+cIdDel+"'"
					aIdDel := TafQryarr( cQryExc )					
					For nlI := 1 To Len( aIdDel )
						TafEndGRV( "C1G","C1G_PROCID", "", aIdDel[nlI][01]  )
					Next
					FwFormCommit( oModel ) 
				endif
			endif	
		elseIf ( cAlias )->&( cAlias + "_EVENTO" ) == "A"
			if ( cAlias )->&( cAlias + "_STATUS" ) $ "2|6"
				Aviso( STR0018, STR0010, { STR0019 }, 2 ) //Atenção##"Não é possivel realizar a exclusão de um evento que está aguardando o retorno do RET." ##"Fechar"
			else
				if lauto .or. ApMsgNoYes(STR0012)	// O Evento a ser excluído é um evendo de alteração ainda não transmitido ao governo, o mesmo sera deletado e o registro anterios restaurado. Deseja prosseguir? 
					cIdDel := V82->V82_PROCID
					oModelV82 := oModel:GetModel( 'MODEL_V82' )
					oModel:SetOperation( MODEL_OPERATION_DELETE )
					oModel:Activate()
					if V82->(MsSeek(xFilial('V82')+ oModelV82:GetValue( "V82_ID" ) + oModelV82:GetValue( "V82_VERANT" )))
						FAltRegAnt( 'V82', '1' )
						MsGinfo(STR0013) //Registro restaurado!
					endif					
					cQryExc := "SELECT R_E_C_N_O_, C1G_ID FROM "+RetSqlName("C1G")+ " WHERE D_E_L_E_T_ = ' ' AND C1G_PROCID ='"+cIdDel+"'"
					aIdDel := TafQryarr( cQryExc )					
					For nlI := 1 To Len( aIdDel )
						TafEndGRV( "C1G","C1G_PROCID", "", aIdDel[nlI][01]  ) 
					Next
					FwFormCommit( oModel )					
				endif	
			endif	
		endif
	else
		if ( cAlias )->&( cAlias + "_EVENTO" ) == "E" .and. ( cAlias )->&( cAlias + "_STATUS" ) $ ' |0|1|3'
			if lauto .or. ApMsgNoYes(STR0014) //O Evento a ser excluído é um evento de exclusão ainda não transmitido ao governo, o mesmo será apagado da base e o registro anterior restaurado. Deseja prosseguir?
				oModelV82 := oModel:GetModel( 'MODEL_V82' )
				oModel:SetOperation( MODEL_OPERATION_DELETE )
				oModel:Activate()	
				FwFormCommit( oModel )
				
				if V82->(MsSeek(xFilial('V82')+ oModelV82:GetValue( "V82_ID" ) + oModelV82:GetValue( "V82_VERANT" )))
					FAltRegAnt( 'V82', '1' )
					MsGinfo(STR0013) //Registro restaurado!
				endif
			endif
		elseIf ( cAlias )->&( cAlias + "_EVENTO" ) == "E" .and. ( cAlias )->&( cAlias + "_STATUS" ) $ '6'
			MsGinfo(STR0015) //O Evento a ser excluído é um evento de exclusão já transmitido, porém ainda não autorizado, a operação desejada não poderá ser concluída até que o retorno do governo esteja OK.
		elseIf ( cAlias )->&( cAlias + "_EVENTO" ) == "E" .and. ( cAlias )->&( cAlias + "_STATUS" ) $ '7|4'
			MsGinfo(STR0016) //"O Evento a ser excluído é um evento de exclusão transmitido e autorizado, a operação desejada não poderá ser concluída."
		else
			MsGinfo(STR0017) //Essa opcao deve ser usada somente para eventos de exclusao.
		endif	
	endif	
End Transaction
Return
