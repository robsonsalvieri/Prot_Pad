#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "TAFA610.CH"
#INCLUDE "TOPCONN.CH"

Static lSimpl0103  := TAFLayESoc("S_01_03_00", .T., .T.)

/*/{Protheus.doc} TAFA610
     Exclusão do evento S-3500 - processo trabalhista
    @type  Function
    @author Evandro Italo / Lucas Passos
    @since 06/10/2022
    @version version 1.0
    /*/
Function TAFA610()
    	
    Private oBrw as object

	oBrw := Nil

	If TAFAtualizado( .T. ,'TAFA610' )
		oBrw := FWmBrowse():New()
		oBrw:SetDescription(STR0001)    //Exclusão de Evento - Processo Trabalhista
		oBrw:SetAlias( 'V7J')
		oBrw:SetMenuDef( 'TAFA610' )
		oBrw:SetFilterDefault( "V7J_ATIVO == '1'" )
		TafLegend(2,"V7J",@oBrw)
		
		oBrw:Activate()
		oBrw:SetCacheView( .F. )
	EndIf

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} MenuDef
Funcao generica MVC do model

@return oModel - Objeto do Modelo MVC

@author Evandro Italo / Lucas Passos
@since 10/10/2022
@version 1.0
/*/
//-------------------------------------------------------------------

Static Function MenuDef()

	Local aFuncao as array
	Local aRotina as array

	aFuncao := {}
	aRotina := {}

	Aadd( aFuncao, { "" , "TafxmlRet('TAF610Xml','3500','V7J')" , "1" } )
	Aadd( aFuncao, { "" , "TAFXmlLote( 'V7J', 'S-3500' , 'evtExclusao' , 'TAF610Xml',, oBrw )" , "5" } )
	Aadd( aFuncao, { "" , "Processa( {||TAF610Ajust(),'Processando', 'Iniciando Rotina de Ajuste' } )"  	, "6" } )
	Aadd( aFuncao, { "" , "xFunAltRec( 'V7J' )" , "10" } )

	lMenuDIf := Iif( Type( "lMenuDif" ) == "U", .F., lMenuDIf )

	aRotina	:=	xFunMnuTAF( "TAFA610" , , aFuncao)

Return aRotina

//-------------------------------------------------------------------
/*/{Protheus.doc} ModelDef
Funcao generica MVC do model

@return oModel - Objeto do Modelo MVC

@author Evandro Italo / Lucas Passos
@since 10/10/2022
@version 1.0
/*/
//-------------------------------------------------------------------

Static Function ModelDef()
	Local oStruV7J 	as Object
	Local oModel	as Object

	oStruV7J := Nil
	oModel	 := Nil

	oStruV7J	:=	FWFormStruct( 1, 'V7J' )
	oModel    	:=	MPFormModel():New( 'TAFA610',,,{|oModel| SaveModel(oModel)})

	oModel:AddFields('MODEL_V7J', /*cOwner*/, oStruV7J)
	oModel:GetModel('MODEL_V7J'):SetPrimaryKey({'V7J_FILIAL', 'V7J_ID', 'V7J_VERSAO'})

Return oModel

//-------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
Funcao generica MVC do View

@return oView - Objeto da View MVC

@author Evandro Italo / Lucas Passos
@since 10/10/2022
@version 1.0
/*/
//-------------------------------------------------------------------

Static Function ViewDef()

	Local cCmpFil		as Character
	Local cControl		as Character
	Local cProtul		as Character
	Local cCmpFol2		as Character
	Local nI        	as Numeric
	Local oModel    	as Object
	Local oStruV7J  	as Object
	Local oProtV7J		as Object
	Local oView 		as Object
	Local aCmpGrp 		as Array

	aCmpGrp 	:= {}
	cCmpFol2 := ""	
	cCmpFil		:= ""
	cControl	:= ""
	cProtul		:= ""
	nI 			:= 0
	oModel   	:= FWLoadModel( 'TAFA610' )
	oStruV7J  	:= FWFormStruct(2,"V7J")
	oProtV7J	:= FWFormStruct(2,"V7J")

	If lSimpl0103 .AND. TafColumnPos("V7J_IDESEQ")
		cCmpFil   	:= "V7J_TPEVEN|V7J_DTPEVE|V7J_NRRECI|V7J_PERAPU|V7J_CPF|V7J_PROCTR|V7J_IDESEQ|"
	Else
		cCmpFil   	:= "V7J_TPEVEN|V7J_DTPEVE|V7J_NRRECI|V7J_PERAPU|V7J_CPF|V7J_PROCTR|"
	EndIf	
	cProtul 	:= "V7J_PROTUL|"
	cControl	:= "V7J_DINSIS|V7J_DTRANS|V7J_HTRANS|V7J_DTRECP|V7J_HRRECP|"

	cCmpFol2 := cProtul + cControl

	oView     	:= FWFormView():New()

	oView:SetModel(oModel)

	oStruV7J  	:= FwFormStruct(2,"V7J",{|x| AllTrim(x) + "|" $ cCmpFil  } )
	oProtV7J 	:= FwFormStruct(2,"V7J",{|x| AllTrim(x) + "|" $ cCmpFol2 } )

	oProtV7J:AddGroup( "GRP_TRABALHADOR_01", TafNmFolder("recibo",1), "", 1 ) //Recibo da última Transmissão
	oProtV7J:AddGroup( "GRP_TRABALHADOR_02", TafNmFolder("recibo",2), "", 1 ) //Informações de Controle eSocial

	oProtV7J:SetProperty(Strtran(cProtul,"|",""),MVC_VIEW_GROUP_NUMBER,"GRP_TRABALHADOR_01")

	aCmpGrp := StrToKArr(cControl,"|")
	For nI := 1 to Len(aCmpGrp)
		oProtV7J:SetProperty(aCmpGrp[nI],MVC_VIEW_GROUP_NUMBER,"GRP_TRABALHADOR_02")
	Next nI

	oView:CreateHorizontalBox( 'PAINEL_SUPERIOR', 100 )
	oView:CreateFolder( 'FOLDER_SUPERIOR', 'PAINEL_SUPERIOR' )

	oView:CreateFolder( 'FOLDER_SUPERIOR' )
	oView:AddSheet( 'FOLDER_SUPERIOR', 'ABA01', STR0002 )
	oView:AddSheet( 'FOLDER_SUPERIOR', 'ABA02', STR0003 )
		
	oView:AddField( 'VIEW_V7J' , oStruV7J,  'MODEL_V7J' )
	oView:CreateHorizontalBox('V7J', 50,,, 'FOLDER_SUPERIOR', 'ABA01')
	oView:EnableTitleView("VIEW_V7J",STR0009) //"Exclusão de Evento - Processo Trabalhista"                                                                                                                                                                                                                                                                                                                                                                                                                                                                         
	oView:SetOwnerView("VIEW_V7J", "V7J")

	oView:AddField( 'VIEW_V7J_PROTOCOLO' , oProtV7J,  'MODEL_V7J' )
	oView:CreateHorizontalBox('V7J_PROTOCOLO', 50,,, 'FOLDER_SUPERIOR', 'ABA02')
	oView:EnableTitleView("VIEW_V7J_PROTOCOLO",STR0004)
	oView:SetOwnerView("VIEW_V7J_PROTOCOLO", "V7J_PROTOCOLO")

Return oView

//-------------------------------------------------------------------
/*/{Protheus.doc} SaveModel
Funcao de gravacao dos dados, chamada no final, no momento da
confirmacao do modelo

@Param  oModel -> Modelo de dados

@Return .T.

@Author Evandro Italo / Lucas Passos
@Since 18/10/2022
@Version 1.0
/*/
//-------------------------------------------------------------------

Static Function SaveModel( oModel as Object )

	Local aOrder		as Array
	Local aTafRotn		as Array
	Local cChave		as Character  
	Local cEvento	 	as Character 
	Local cAlias		as Character
	Local cNmFun		as Character
	Local cInd			as Character
	Local cSelect   	as Character
	Local cFrom   		as Character
	Local cWhere   		as Character
	Local cAliasQry		as Character
	Local cLogOpeAnt    as Character
	Local cQuery		as Character
	Local lOk   		as Logical
	Local nOperation 	as Numeric

	Default oModel	:= Nil

	aOrder		:= {}
	cChave		:= ""  
	cEvento	 	:= "" 
	cAlias		:= ""
	cNmFun		:= ""
	cInd		:= ""
	cSelect   	:= ""
	cFrom   	:= ""
	cWhere   	:= ""
	cAliasQry	:= ""
	cLogOpeAnt  := ""
	cQuery		:= ""
	nOperation 	:= oModel:GetOperation()
	lOk   		:= .T.
	aTafRotn	:= {}

	Begin Transaction

		If nOperation == MODEL_OPERATION_INSERT
			
			TafAjustID("V7J", oModel)
			
			oModel:LoadValue( 'MODEL_V7J', 'V7J_VERSAO', xFunGetVer() )

			TAFAltMan( 3 , 'Save' , oModel, 'MODEL_V7J', 'V7J_LOGOPE' , '2', '' )

			FwFormCommit( oModel )
			
			cEvento := Posicione("C8E",1,xFilial("C8E") + V7J->V7J_TPEVEN,"C8E_CODIGO")
			Gerar3500(cEvento, V7J->V7J_NRRECI, .T.)
			
		ElseIf nOperation == MODEL_OPERATION_UPDATE

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Seek para posicionar no registro antes de realizar as validacoes,³
			//³visto que quando nao esta pocisionado nao eh possivel analisar   ³
			//³os campos nao usados como _STATUS                                ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			V7J->( DbSetOrder( 1 ) )
			If V7J->( MsSeek( xFilial( 'V7J' ) + V7J->V7J_ID + V7J->V7J_VERSAO ) )

				If V7J->V7J_STATUS $ ( "4" )
					MsgAlert(xValStrEr("000749"))
					lOk := .F.
				EndIf

				If lOk
					cLogOpeAnt := V7J->V7J_LOGOPE

					TAFAltMan( 4 , 'Save' , oModel, 'MODEL_V7J', 'V7J_LOGOPE' , '' , cLogOpeAnt )
					
					FwFormCommit( oModel )
					TAFAltStat( 'V7J', " " )
				EndIf
			EndIf
			
		ElseIf nOperation == MODEL_OPERATION_DELETE
			
				oModel:DeActivate()
				oModel:SetOperation( 5 )
				oModel:Activate()
				FwFormCommit( oModel )
				
				//Restaura o registro que havia sido excluido
				cEvento  := Posicione("C8E",1,xFilial("C8E") + V7J->V7J_TPEVEN,"C8E_CODIGO")
				aTafRotn := TAFRotinas( cEvento ,4,.F.,2)
				
				If !Empty(aTafRotn)
					cAlias	 := aTafRotn[3]
					cNmFun	 := aTafRotn[1]
					cInd	 := aTafRotn[13]
				
					If TAFAlsInDic( cAlias )
							//Se a exclusão for pelo savemodel
							cSelect  	:= ""
							cAliasQry	:= GetNextAlias()
							

							cSelect := cAlias + "_ID ID," + cAlias + "_VERSAO VERSAO"

							cFrom	:= RetSqlName(cAlias)
							cWhere	+= cAlias + "_ATIVO = '1' "
							cWhere	+= " AND " + cAlias + "_STATUS = '6' "
							cWhere	+= " AND " + cAlias + "_PROTPN = '" + V7J->V7J_NRRECI + "' "
							cWhere	+= " AND D_E_L_E_T_= '' "
							
							cSelect  := "%" + cSelect  + "%"
							cFrom    := "%" + cFrom    + "%"
							cWhere   := "%" + cWhere   + "%"
							
							BeginSql Alias cAliasQry
								SELECT
									%Exp:cSelect%
								FROM
									%Exp:cFrom%
								WHERE
									%EXP:cWhere%
							EndSql

							aOrder := ChangeOrder(cAlias)

							(cAlias)->(DbSetOrder(aOrder[1]))

							cQuery := xFilial(cAlias) + (cAliasQry)->ID + '1' + (cAliasQry)->VERSAO 

							(cAlias)->(MsSeek(cQuery))

							cChave := (cAlias)->&(cAlias + "_ID") + (cAlias)->&(cAlias + "_VERANT")
							oModel := FWLoadModel(cNmFun)

							oModel:SetOperation(5)
							oModel:Activate()
							FwFormCommit(oModel)
							TAFRastro(cAlias, aOrder[2], cChave, .T.,, Iif(Type("oBrw") == "U", Nil, oBrw))							
							
						EndIf
					EndIf											
		EndIf
		
	End Transaction 

Return (.T.)

//-------------------------------------------------------------------
/*/{Protheus.doc} ChangeOrder
Altera o índice de acordo com o Alias informado

@param cTable - Alias a ser posicionado

@author Evandro Italo / Lucas Passos
@since 25/10/2022
@version 1.0		

@return aOrder - Retornar um array de índices
/*/
//-------------------------------------------------------------------

Static Function ChangeOrder(cTable as Character)

	Local aOrder 	as Array

	Default cTable	:= ""
	
	aOrder 			:= {2, 1}
						
	If cTable $ "V9U|V7C"
		
		aOrder := {1, 2}

	EndIf

Return aOrder

//-------------------------------------------------------------------	
/*/{Protheus.doc} TAF610Xml
@author Evandro Italo / Lucas Passos
@since 20/10/2022
@version 1.0
		
@Param:
lJob   - Informa se foi chamado por Job
nOpc   - Opcao a ser realizada ( 3 = Inclusao, 4 = Alteracao, 5 = Exclusao )
lRemEmp - Exclusivo do Evento S-1000
cSeqXml - Numero sequencial para composição da chave ID do XML

@return
cXml - Estrutura do Xml do Layout S-3500 
/*/
//-------------------------------------------------------------------

Function TAF610Xml(cAlias as Character, nRecno as Numeric, nOpc as Numeric, lJob as Logical, lRemEmp as Logical, cSeqXml as Character)

    Local cXml      	as Character
    Local cLayout   	as Character 
    Local cReg      	as Character 
    Local cPerApu   	as Character 
    Local cTpEvent  	as Character
	Local cVerSchema 	as Character
    Local lXmlVLd   	as Logical
    Local lRestArea 	as Logical
    Local aAreaV7J  	as Array

    Default cAlias  := "V7J"
    Default nRecno  := 0
    Default nOpc    := 1
    Default lJob    := .F.
    Default cSeqXml := ""

    cXml        := ""
    cLayout     := "3500"
    cReg        := "ExcProcTrab"
    cPerApu     := ""
    lXmlVLd     := TafXmlVLD('TAF610XML')
    cTpEvent    := Posicione("C8E", 1, xFilial("C8E") + V7J->V7J_TPEVEN, "C8E_CODIGO")
	cVerSchema	:= SuperGetMv('MV_TAFVLES',.F.,"S_01_00_00")
    aAreaV7J    := {}
    lRestArea   := .F.

    If lXmlVLd
        
        If !Empty(V7J->V7J_PERAPU)
            If Len(Alltrim(V7J->V7J_PERAPU)) > 4
                cPerApu := SubStr(V7J->V7J_PERAPU, 1, 4) + '-' + SubStr(V7J->V7J_PERAPU, 5, 7)
            EndIf
        Else
            cPerApu := V7J->V7J_PERAPU
        EndIf

        cXml :=     "<infoExclusao>"
        cXml +=         xTafTag("tpEvento", cTpEvent)
        cXml +=         xTafTag("nrRecEvt",V7J->V7J_NRRECI)

		If cVerSchema == "S_01_03_00" .AND. TafColumnPos("V7J_IDESEQ")

			xTafTagGroup("ideProcTrab"  ,{  {"nrProcTrab"   ,V7J->V7J_PROCTR,,.F.}  ,;
											{"cpfTrab"      ,V7J->V7J_CPF   ,,.T.}  ,;
											{"perApurPgto"  ,cPerApu        ,,.T.}  ,;
											{"ideSeqProc"   ,V7J->V7J_IDESEQ,,.T.}  };
											, @cXml)
		Else

			xTafTagGroup("ideProcTrab"  ,{  {"nrProcTrab"   ,V7J->V7J_PROCTR,,.F.}  ,;
                                        {"cpfTrab"      ,V7J->V7J_CPF   ,,.T.}  ,;
                                        {"perApurPgto"  ,cPerApu        ,,.T.}};
                                        , @cXml)
		EndIf

        cXml +=     "</infoExclusao>"
        cXml := xTafCabXml(cXml,"V7J",cLayout,cReg,,cSeqXml)

        If !lJob
            xTafGerXml(cXml,cLayout)
        EndIf

    EndIf

Return(cXml)

//-------------------------------------------------------------------
/*/{Protheus.doc} TAF610Grv
@author Evandro Italo / Lucas Passos
@since 20/10/2022
@version 1.0
		
@param
cLayout	- Nome do Layout que esta sendo enviado, existem situacoes onde o mesmo fonte
				alimenta mais de um regsitro do E-Social, para estes casos serao necessarios
		   		tratamentos de acordo com o layout que esta sendo enviado.
nOpc  		- Opcao a ser realizada ( 3 = Inclusao, 4 = Alteracao, 5 = Exclusao )
cFilEv 		- Filial do ERP para onde as informacoes deverao ser importadas
oXML   		- Objeto com as informacoes a serem manutenidas ( Outras Integracoes )  
cTAFKEY 	- Chave do registro que está sendo excluído.

@Return    
lRet    - Variavel que indica se a importacao foi realizada, ou seja, se as 
		  informacoes foram gravadas no banco de dados
aIncons - Array com as inconsistencias encontradas durante a importacao 
/*/
//-------------------------------------------------------------------
Function TAF610Grv(	cLayout as Character, nOpc as Numeric, cFilEv as Character, oXML as Object, cOwner as Character, cFilTran as Character,;
					cPredeces as Character, nTafRecno as Numeric, cComplem as Character, cGrpTran as Character, cEmpOriGrp as Character,;
					cFilOriGrp as Character, cXmlID as Character, cEvtOri as Character, lMigrador as Logical, lDepGPE as Logical, cKey as Character,;
					cMatrC9V as Character, lLaySmpTot as Logical, lExclV7J as Logical )

	Local cCmpsNoUpd 		as Character
	Local cCabec     		as Character
	Local cLogOpeAnt		as Character
	Local cLaysOK			as Character
					
	Local cValChv 			as Character
	Local cValorXml  		as Character
	Local cChave	   		as Character
	Local cRecChv	   		as Character
	Local cFldsIndex 		as Character
	Local cAlias	   		as Character
	Local cTpOper	   		as Character
	Local cIdEvento  		as Character
	Local cVersaoEvt	 	as Character
	Local cInconMsg  		as Character
	Local cQry				as Character
	Local cAliasTafKey	   	as Character
	Local cAliasQry		    as Character
	Local cCmpTrab		    as Character
	Local cStatus	   		as Character
	Local cTAFKEY			as Character
	Local cCodEvent  		as Character
	Local cEvento			as Character
	Local cBanco	 		as Character
	Local cEvtExclu			as Character
	Local cChaveEvt		 	as Character
	Local cV7Jstatus		as Character

	Local nIndChv    		as Numeric
	Local nIndIDVer  		as Numeric
	Local nI         		as Numeric
	Local nSeqErrGrv		as Numeric
	Local nIndExc	  		as Numeric
	Local nIndProt		    as Numeric
	Local nIndApp	   		as Numeric
	Local nTamCmp			as Numeric
	Local nPosChave			as Numeric
	Local nTamCampo			as Numeric

	Local lRet       		as Logical
	Local lTafKey			as Logical
	Local lRecibo			as Logical
	Local lPadProtu		    as Logical 

	Local aIncons    		as Array
	Local aRules     		as Array
	Local aChave     		as Array
	Local aFldsIndex 		as Array
	Local aArea      		as Array
	Local aTafRotn   		as Array

	Local oModel     		as Object

	Private oDados   		as Object
	Private lVldModel		as Logical

	Default cLayout 		:= ""
	Default nOpc     		:= 1
	Default cFilEv   		:= ""
	Default oXML     		:= Nil
	Default cOwner			:= ""
	Default cFilTran		:=	""
	Default cPredeces		:=	""
	Default nTafRecno		:=	0
	Default cComplem		:=	""
	Default cGrpTran		:=	""
	Default cEmpOriGrp		:=	""
	Default cFilOriGrp		:=	""
	Default cXmlID			:=	""
	Default cEvtOri			:=  ""
	Default lMigrador		:=	.F.
	Default lDepGPE			:=	.F.
	Default cKey			:=	""
	Default cMatrC9V		:=	""
	Default lLaySmpTot		:= .F.
	Default lExclV7J		:= .F.

	cCmpsNoUpd 				:= "|V7J_FILIAL|V7J_ID|V7J_VERSAO|V7J_VERANT|V7J_PROTUL|V7J_PROTPN|V7J_EVENTO|V7J_STATUS|V7J_ATIVO|"
	cCabec     				:= "/eSocial/evtExcProcTrab/infoExclusao"
	cLogOpeAnt				:= ""

	//Layouts que podem ser excluídos através desse evento.
	cLaysOK					:= "S-2500|S-2501|S-2555"
					
	cValChv 				:= ""
	cValorXml  				:= ""
	cChave	   				:= ""
	cRecChv	   				:= ""
	cFldsIndex 				:= ""
	cAlias	   				:= ""
	cTpOper	   				:= ""
	cIdEvento  				:= ""
	cVersaoEvt	 			:= ""
	cInconMsg  				:= ""
	cQry					:= ""
	cAliasTafKey			:= ""
	cAliasQry				:= GetNextAlias()
	cCmpTrab				:= ""
	cStatus	   				:= ""
	cTAFKEY					:= ""
	cCodEvent  				:= ""
	cEvento					:= ""
	cBanco	 				:= Upper(TcGetDb())

	nIndChv    				:= 2
	nIndIDVer  				:= 1
	nI         				:= 0
	nSeqErrGrv				:= 0
	nIndExc	  				:= 0
	nIndProt				:= 0
	nIndApp	   				:= 0
	nTamCmp					:= 0
	nPosChave				:= 1
	nTamCampo				:= 0

	lRet       				:= .F.
	lTafKey					:= .F.
	lRecibo					:= .F.
	lPadProtu				:= .T. 

	aIncons    				:= {}
	aRules     				:= {}
	aChave     				:= {}
	aFldsIndex 				:= {}
	aArea      				:= GetArea()
	aTafRotn   				:= {}
	cEvtExclu				:= ""
	cChaveEvt				:= ""
	cV7Jstatus				:= ""

	oModel     				:= Nil

	oDados   				:= oXML
	lVldModel				:= .T. //Caso a chamada seja via integracao seto a variavel de controle de validacao como .T.

	cTpOper		:= TAFIdNfe(oDados:Save2String(),"tpOper") 
	cEvento  	:= FTafGetVal( cCabec + "/tpEvento", "C", .F., @aIncons, .F. )
	aTafRotn 	:= TAFRotinas( cEvento,4,.F.,2)
	cCodEvent  	:= Posicione("C8E",2,xFilial("C8E")+"S-"+cLayout,"C8E->C8E_ID")

	//A informação enviada em nrRecEvt pode ser o protocolo do registro que deseja excluir ou
	//a chave do registro ( alternativa de integração do TAF com o ERP de origem não tem o protocolo )
	cRecChv := oDados:XPathGetNodeValue( cCabec + "/nrRecEvt")

	If !Empty(AllTrim(cRecChv))
		
		If !Empty(aTafRotn)
			
			cAlias		:= aTafRotn[ 3 ]
			cNmFun		:= aTafRotn[ 1 ]
			nIndProt	:= aTafRotn[ 13 ]
			nIndApp		:= aTafRotn[ 10 ]
			cCmpTrab	:= aTafRotn[ 11 ]
			
			//Primeiro tentar encontrar o registro pelo indice e chave de protocolo.
			( cAlias )->( dbSetOrder( nIndProt ) )
			
			If ( cAlias )->( MsSeek( xFilial( cAlias ) +Padr( cRecChv, TamSx3( cAlias + "_PROTUL" )[1] )  + '1' ) )
				
				cIdEvento	:= ( cAlias )->&( cAlias + "_ID" )
				cVersaoEvt 	:= ( cAlias )->&( cAlias + "_VERSAO" )
				cStatus		:= ( cAlias )->&( cAlias + "_STATUS" )
				nIndExc		:= nIndProt
				lRecibo		:= .T.
			
			//Se não encontrou com o protocolo, tenta encontrar pelo indice e chave de negocio ( alternativa de integração do TAF com o ERP de origem não tem o protocolo )
			Else
		
				If oDados:xPathHasNode(cCabec+"/tpEvento")
					cEvtExclu := AllTrim(oDados:XPathGetNodeValue(cCabec+"/tpEvento"))
				EndIf
			
				( cAlias )->( dbSetOrder( nIndApp ) )
			
				cFldsIndex := ( cAlias )->( IndexKey() )
				cFldsIndex := StrTran( cFldsIndex	, "DTOS("		, "" )
				cFldsIndex := StrTran( cFldsIndex	, "STR("		, "" )
				cFldsIndex := StrTran( cFldsIndex	, "DESCEND("	, "" )
				cFldsIndex := StrTran( cFldsIndex	, ")"			, "" )
				aFldsIndex := Str2Arr( cFldsIndex 	, "+" )
					
				For nI:= 1 To Len( aFldsIndex )

					If !(aFldsIndex[nI] == (cAlias+"_FILIAL") .Or. aFldsIndex[nI] == (cAlias+"_ATIVO"))

						nTamCampo := GetSx3Cache(aFldsIndex[nI],"X3_TAMANHO")
						cChaveEvt += Substr(cRecChv,nPosChave,nTamCampo)
						nPosChave += nTamCampo

					EndIf 
					
					If !aFldsIndex[ nI ] == cAlias + "_PROTUL"
						lPadProtu := .F.
					EndIf
				Next
				
				If Empty(cIdEvento) //Caso seja enviado o TAFKEY na tag de recibo(nrRecEvt)
					
					cTAFKEY := FTafGetVal( cCabec + "/nrRecEvt", "C", .F., @aIncons, .F. )
					
					cQry += "SELECT TAFALIAS, TAFRECNO FROM TAFXERP TAFXERP "
					cQry += "	WHERE TAFALIAS = '" + cAlias + "'"

					If cBanco == "ORACLE"
						cQry += "   AND TAFXERP.TAFKEY IN ( '" + Padr(cTAFKEY, 100) + "' ) "
					Else
						cQry += "   AND TAFXERP.TAFKEY IN ( '" + cTAFKEY + "' ) "
					EndIf

					cQry += "   AND TAFXERP.TAFRECNO <> '0' "
					cQry += "   AND TAFXERP.D_E_L_E_T_ = '' "
					cQry += "   ORDER BY R_E_C_N_O_ DESC"
					
					cQry := ChangeQuery(cQry)
					
					dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQry ) , cAliasQry, .F., .T. )

					If !Empty((cAliasQry)->TAFALIAS)
						cAliasTafKey := (cAliasQry)->TAFALIAS
									
						(cAliasTafKey)->(dbGoTo((cAliasQry)->TAFRECNO))
						
						cIdEvento	:= ( cAliasTafKey )->&( cAliasTafKey + "_ID" )
						cVersaoEvt  := ( cAliasTafKey )->&( cAliasTafKey + "_VERSAO" )
						cStatus		:= ( cAliasTafKey )->&( cAliasTafKey + "_STATUS" )
						cRecChv		:= ( cAliasTafKey )->&( cAliasTafKey + "_PROTUL" )
						nIndExc	    := nIndApp
						lTafKey		:= .T.
						
						If Empty(cRecChv) //Se protocolo estiver vazio
							For nI:= 1 To Len( aFldsIndex )
								If aFldsIndex[nI] == (cAliasTafKey + "_ID")
									cRecChv := Padr( ( cAliasTafKey) -> &( aFldsIndex[nI] ), TamSx3(aFldsIndex[nI])[1] )
								EndIf
							Next nI
						EndIf
					
					EndIf
									
				EndIf

			EndIf
		
		EndIf
		
		If !Empty( cIdEvento )

			cValChv := FGetIdInt( "tpEvento" , , cCabec + "/tpEvento" , , , , @cInconMsg , @nSeqErrGrv )

			If ( cEvento $ cLaysOK ) .And. ( nOpc <> 5 )
			
				//Quando o Evento que deseja excluir estiver com status diferente de '2' = Aguardando Retorno, '4' = Transmitido '6' = Pendente Transmissão S-3500 e 
				//'7' = Transmissão S-3000 com sucesso, devo realizar uma exclusão direta
				If !( cStatus $ '4|2|6|7' )
					
					//Utilizo a variável aIncons para fazer o controle de retorno para TAFPrepInt. Apesar de não se tratar de uma inconsistência ou erro
					// essa variável auxilia no processo de exclusão direta de registros no TAF através do Evento S-3000.
					//Através dela consigo identificar essa operação e setar o Status '5' na TAFXERP ( exclusão direta via S-3000 )
					Gerar3500( cEvento , cRecChv ,  , @aIncons , nIndExc , lPadProtu, @lExclV7J )

				Else
					/*----------------------------
					CAMPOS DA CHAVE
					-----------------------------*/
					If !Empty( cValChv )
						Aadd( aChave, { "C", "V7J_TPEVEN", cValChv, .T. } )
						cChave	+= Padr( cValChv, Tamsx3( aChave[ 1, 2 ])[1] )
						nIndChv := 2
					EndIf
					
					cValChv := FTafGetVal( cCabec + "/nrRecEvt", "C", .F., @aIncons, .F. )

					If !Empty( cRecChv )
						Aadd( aChave, { "C", "V7J_NRRECI", cRecChv, .T.} )
						cChave += Padr( cRecChv, Tamsx3( aChave[ 2, 2 ])[1] )
						nIndChv := 2
					EndIf
					
					("V7J")->( DbSetOrder( 2 ) )
					If ("V7J")->( MsSeek( xFilial("V7J") + cChave + "1" ) )
						cV7Jstatus := V7J->V7J_STATUS
						If cV7Jstatus $ '4|2'
							aAdd( aIncons , STR0008 ) // "Recibo/Chave que deseja excluir já se escontra excluído ou aguardando retorno do governo"
						Else
							nOpc := 4
						EndIf
					EndIf

					RestArea(aArea)
					
					cAliasEvent := TafSelecEvt("U",cAlias,cIdEvento,cVersaoEvt)
								
					Begin Transaction
						
						//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
						//³Funcao para validar se a operacao desejada pode ser realizada³
						//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
						If FTafVldOpe( "V7J", nIndChv, @nOpc, cFilEv, @aIncons, aChave, @oModel, "TAFA610", cCmpsNoUpd, nIndIDVer, .F.)

							cLogOpeAnt := V7J->V7J_LOGOPE

							//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
							//³Quando se tratar de uma Exclusao direta apenas preciso realizar ³
							//³o Commit(), nao eh necessaria nenhuma manutencao nas informacoes³
							//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
							If nOpc <> 5

								If (cAliasEvent)->(!Eof())

									//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
									//³Carrego array com os campos De/Para de gravacao das informacoes³
									//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
									aRules := TAF610Rul(nOpc, cCodEvent, cOwner, cAlias, nIndProt, cRecChv)
									oModel:LoadValue( "MODEL_V7J", "V7J_FILIAL", xFilial("V7J"))
									oModel:LoadValue( "MODEL_V7J", "V7J_XMLID", cXmlID )
		
									While (cAliasEvent)->(!EOF())
										//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
										//³Rodo o aRules para gravar as informacoes³
										//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
										For nI := 1 To Len( aRules )

											If aRules[ nI, 01 ] == "V7J_NRRECI"
												cValorXml := (cAliasEvent)->(RECIBO)
											Else
												cValorXml := FTafGetVal( aRules[ nI, 02 ], aRules[nI, 03], aRules[nI, 04], @aIncons, .F., , aRules[ nI, 01 ] )
											EndIf

											oModel:LoadValue("MODEL_V7J", aRules[ nI, 01 ], cValorXml)

										Next

										(cAliasEvent)->(dbSkip())

									Enddo

									If nOpc == 3
										TAFAltMan( nOpc , 'Grv' , oModel, 'MODEL_V7J', 'V7J_LOGOPE' , '1', '' )
									ElseIf nOpc == 4
										TAFAltMan( nOpc , 'Grv' , oModel, 'MODEL_V7J', 'V7J_LOGOPE' , '', cLogOpeAnt )
									EndIf

								EndIf

							EndIf
							
							//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
							//³Efetiva a operacao desejada³
							//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ	
							If Empty(cInconMsg) .And. Empty(aIncons)
								
								If TafFormCommit( oModel )
									Aadd(aIncons, "ERRO19")
								Else
									lRet  := .T.
								EndIf
								
							Else
								Aadd(aIncons, cInconMsg)
								DisarmTransaction()
							EndIf
			
						//Não gera registro de exclusão no evento
							If nOpc == 3 .AND.Len(aIncons) == 0
								
								If lTafKey
									Gerar3500(cEvento, cRecChv,,,nIndProt)
								Else
									Gerar3500(cEvento, cRecChv, lRecibo)
								EndIf
								
							EndIf
							
							oModel:DeActivate()

							TafClearModel(oModel)

						EndIf
					
					End Transaction
					(cAliasEvent)->(DbCloseArea())
					
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³Zerando os arrays e os Objetos utilizados no processamento³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					aSize( aRules, 0 )
					aRules:= Nil
					
					aSize( aChave, 0 )
					aChave := Nil
				EndIf
			EndIf
		Else
			lRet := .F.
			aAdd( aIncons , STR0010 + cEvento) //'Recibo/chave  não encontrado(a) no cadastro do evento '
		EndIf
	Else
		lRet := .F.
		aAdd( aIncons , STR0011)//'Para eventos S-3500 é obrigatório o envio da tag  nrRecEvt contendo o numero do recibo ou a chave do registro a ser excluido'
	EndIf
			
Return { lRet, aIncons }    

//-------------------------------------------------------------------
/*/{Protheus.doc} TAF269Rul           
Regras para gravacao das informacoes do registro S-3500

@param nOpc - Número da operação

@Return	
aRull  - Regras para a gravacao das informacoes

@author Evandro Italo / Lucas Passos
@since 20/10/2022
@version 1.0

/*/                        	
//-------------------------------------------------------------------

Static Function TAF610Rul( nOpc as Numeric, cCodEvent as Character, cOwner as Character, cAliasExc as Character, nIndExc as Numeric, cRecChv as Character )	

	Local aArea     	as Array
	Local aIncons		as Array 
	Local cCabec		as Character
	Local cPerApu		as Character
	Local cApu			as Character
	Local cChvSeek  	as Character
	Local nRegRef   	as Numeric
	Local aRull			as Numeric

	Default nOpc 		:= 1
	Default cCodEvent	:= ""
	Default cOwner		:= ""
	Default cAliasExc   := ""
	Default nIndExc     := 0
	Default cRecChv     := ""

	aArea     			:= GetArea()
	cCabec				:= "/eSocial/evtExcProcTrab/infoExclusao"
	cPerApu				:= ""
	cApu				:= ""
	nRegRef   			:= 0
	aRull				:= {}
	aIncons				:= {} 
	cChvSeek  			:= ""

	If TafXNode( oDados, cCodEvent, cOwner, (cCabec + "/ideProcTrab/perApurPgto"))
		cPerApu	:= FTafGetVal( cCabec + "/ideProcTrab/perApurPgto", 'C', .F., @aIncons, .F.)
	EndIf

	IF !Empty(cPerApu)
		cApu := SubStr(cPerApu, 1, 4) + SubStr(cPerApu, 6, 7)
	End

	If nOpc == 3
		If TafXNode( oDados, cCodEvent, cOwner, (cCabec + "/nrRecEvt"))
			aAdd( aRull,{ "V7J_NRRECI" , cCabec + "/nrRecEvt", "C", .F. } )	
		EndIf
		
		If TafXNode( oDados, cCodEvent, cOwner, (cCabec + "/tpEvento"))
			aAdd( aRull,{ "V7J_TPEVEN" , FGetIdInt( "tpEvento", ,cCabec + "/tpEvento",,,,), "C", .T. } ) 	
		EndIf
	EndIf

	If TafXNode( oDados, cCodEvent, cOwner, (cCabec + "/ideProcTrab/cpfTrab"))
		aAdd( aRull,{ "V7J_CPF"    , cCabec + "/ideProcTrab/cpfTrab", "C", .F. } ) 	
	EndIf

	If TafXNode( oDados, cCodEvent, cOwner, (cCabec + "/ideProcTrab/nrProcTrab"))
		aAdd( aRull,{ "V7J_PROCTR"    , cCabec + "/ideProcTrab/nrProcTrab", "C", .F. } ) 	
	EndIf

	If lSimpl0103 .AND. TafColumnPos("V7J_IDESEQ") 
		If TafXNode( oDados, cCodEvent, cOwner, (cCabec + "/ideProcTrab/ideSeqProc"))
			aAdd( aRull,{ "V7J_IDESEQ"    , cCabec + "/ideProcTrab/ideSeqProc", "C", .F. } ) 	
		EndIf
	EndIf

	aAdd( aRull,{ "V7J_PERAPU" , cApu   , "C", .T. } )

	If !Empty(cAliasExc) .And. nIndExc > 0
		
		DbselectArea(cAliasExc)
		(cAliasExc)->( DbSetOrder( nIndExc ) )
		
		cChvSeek := xFilial( cAliasExc ) + Padr( cRecChv, TamSx3( cAliasExc + "_PROTUL" )[1]) + "1"
	
		If (cAliasExc)->( MsSeek( cChvSeek ) )
			nRegRef := (cAliasExc)->(Recno())			
		EndIf
		
	EndIf

	aAdd( aRull,{ "V7J_REGREF" , nRegRef, "N", .T. } )  // Registro Referência

	RestArea( aArea )
			 
Return ( aRull ) 

//---------------------------------------------------------------------
/*/{Protheus.doc} TAF269Ajust
Rotina para ajuste de Status dos registros Excluidos.
Issue:
DSERTAF1-3419
* Retirar essa rotina quando expedir o release 12.1.21

@Author		Evandro Italo / Lucas Passos
@Since		20/10/2022
@Version	1.0
/*/
//---------------------------------------------------------------------
Function TAF610Ajust()

	Local aEvtEsocial 	as Array
	Local cQuery 		as Character 
	Local cTipEvt 		as Character 
	Local cAliasEvt 	as Character
	Local cAliasQry 	as Character
	Local cLayout 		as Character
	Local cMsg 			as Character
	Local nQtdAjus 		as Numeric
	Local nX 			as Numeric

	aEvtEsocial 		:= {}
	nX 					:= 0
	cQuery 				:= ""
	cTipEvt 			:= ""
	cAliasEvt 			:= ""
	cAliasQry 			:= ""
	cLayout 			:= ""
	cMsg 				:= ""
	nQtdAjus 			:= 0

	//aEvtEsocial := TAFRotinas(,,.T.,2)

	aadd(aEvtEsocial,{"E","V7C","S-2501"})
	aadd(aEvtEsocial,{"E","V9U","S-2500"})

	ProcRegua(Len(aEvtEsocial))

	BEGIN TRANSACTION

		For nX := 1 To Len(aEvtEsocial)

			cTipEvt   := aEvtEsocial[nX][1]
			cAliasEvt := aEvtEsocial[nX][2]
			cLayout   := aEvtEsocial[nX][3]

			IncProc("Analisando/Ajustando Evento " + cLayout)

			If cTipEvt $ "EM"

				If !Empty(cLayout) .And. cAliasEvt != "V7J" .And. TafColumnPos(cAliasEvt + "_FILIAL")

					cAliasQry := GetNextAlias()

					cQuery := " SELECT V7J_NRRECI "
					cQuery += ", " + cAliasEvt + "_PROTPN "
					cQuery += ", " + cAliasEvt + "_FILIAL "
					cQuery += ", " + cAliasEvt + "_ID "
					cQuery += ", " + cAliasEvt + "_VERSAO "
					cQuery += ", " + cAliasEvt + "_STATUS "
					cQuery += ", " + cAliasEvt + "_ATIVO "
					cQuery += ", " + cAliasEvt + ".R_E_C_N_O_ RECNO"

					cQuery += " FROM " + RetSqlName("V7J") + " V7J "
					cQuery += " LEFT JOIN " + RetSqlName(cAliasEvt) + " " + cAliasEvt
					cQuery += " ON V7J_NRRECI = " + cAliasEvt + "_PROTPN AND " + cAliasEvt + "_PROTPN != ' ' "
					cQuery += " WHERE " + cAliasEvt + ".D_E_L_E_T_ = ' ' AND V7J.D_E_L_E_T_ = ' ' "
					cQuery += " AND V7J.V7J_STATUS = '4' "

					TcQuery cQuery New Alias (cAliasQry)

					While (cAliasQry)->(!Eof())

						(cAliasEvt)->(dbGoto((cAliasQry)->RECNO))

						If (cAliasEvt)->&(cAliasEvt + "_STATUS") != '7' .OR. (cAliasEvt)->&(cAliasEvt + "_ATIVO") == '1'

							TAFConOut("Correção Status Exclusao- Found " + cAliasEvt + " - Recno: " + AllTrim(Str((cAliasQry)->RECNO)))

							RecLock(cAliasEvt,.F.)

							(cAliasEvt)->&(cAliasEvt + "_STATUS") := '7'
							(cAliasEvt)->&(cAliasEvt + "_ATIVO")  := '2'

							(cAliasEvt)->(MsUnlock())

							nQtdAjus++

						EndIf						

						(cAliasQry)->(dbSkip())
					EndDo

					(cAliasQry)->(dbCloseArea())
				EndIf
			EndIf

		Next nX

	END TRANSACTION

	If nQtdAjus > 0
		cMsg := "Realizado ajuste em " + AllTrim(Str(nQtdAjus)) + " Registro(os)."
	Else
		cMsg := "Não foram encontrados registos com Status Incorretos."
	EndIf

	MsgInfo(cMsg)

Return .T.

//-------------------------------------------------------------------
/*/{Protheus.doc} xSelecEvent()          
Seleciona os registros a serem excluídos
 
@param cTpOper - Tipo de Operação de Exclusão
				   T = Todo Histórico
				   U = Ultimo Registro
				   
@param cAlias - Alias da Tabela do Evento que deve ser excluído
@param cIdEvento - Id do evento que deve ser excluído

@Return	

@author Evandro Italo / Lucas Passos
@since 20/10/2022
@version 1.0

/*/                        	
//-------------------------------------------------------------------

Static Function TafSelecEvt( cTpOper as Character, cAlias as Character, cIdEvento as Character, cVersaoEvt as Character)

	Local cSelect  	as Character
	Local cAliasQry	as Character

	Default cTpOper		:= "U"
	Default cAlias		:= ""
	Default cIdEvento	:= ""

	cSelect  			:= ""
	cAliasQry			:= GetNextAlias()

	cSelect:= cAlias + "_PROTUL RECIBO"
	cFrom	:= RetSqlName(cAlias)
	cWhere	:= cAlias + "_FILIAL = '" +  xFilial(cAlias) + "'"
	cWhere  += " AND " + cAlias + "_ID = '" 		+ cIdEvento  + "'"
	cWhere  += " AND " + cAlias +  "_VERSAO = '" 	+ cVersaoEvt + "'"  

	cWhere  += " AND D_E_L_E_T_='' "

	cSelect  := "%" + cSelect  + "%"
	cFrom    := "%" + cFrom    + "%"
	cWhere   := "%" + cWhere   + "%"

	BeginSql Alias cAliasQry
	SELECT
		%Exp:cSelect%
	FROM
		%Exp:cFrom%
	WHERE
		%EXP:cWhere%
	EndSql

Return (cAliasQry)


//-------------------------------------------------------------------
/*/{Protheus.doc} Gerar3500()          
Function que gera o registro de exclusão para um determinado evento
 
@param cEvento - Tipo de evento a ser excluido
@param cRecChv - Chave que pode ser o protocolo ou a chave do evento
@param lSaveModel - 
@param aIncons - Array auxiliar de inconsistencias
@param nIndex - Indice para busca do registro
@Return 

@author Evandro Italo / Lucas Passos
@since 19/10/2022
@version 1.0

/*/                         
//-------------------------------------------------------------------

Function Gerar3500( cEvento as Character, cRecChv as Character, lSaveModel as Logical,;
					aIncons as Array, nIndex as Numeric, lPadProtu as Logical,;
					lExclV7J as Logical )

    Local aTafRotn as Array
    Local cAlias   as Character
    Local cNmFun   as Character
    Local nInd     as Numeric

	Private nRecno as Numeric

    Default cEvento    := ""
    Default cRecChv    := ""
    Default lSaveModel := .F.
    Default aIncons    := {}
    Default nIndex     := 0
    Default lPadProtu  := .T.
    Default lExclV7J   := .F.

    cAlias             := ""
    cNmFun             := ""
    nInd               := 0
    aTafRotn           := TAFRotinas( cEvento ,4,.F.,2)
	nRecno             := 0

    If !Empty(aTafRotn)
        cAlias   := aTafRotn[3]
        cNmFun   := aTafRotn[1]
        
        //tratamento para quando o índice é enviado na chamada da função e não precisa ser pesquisado no TAFRotinas()
        If nIndex > 0
            nInd     := nIndex
        Else 
            nInd     := IIf ( lSaveModel , aTafRotn[ 13 ] , aTafRotn[ 10 ] )
        EndIf
        
        (cAlias)->( DbSetOrder( nInd ) )
        If  (cAlias)->( MsSeek( xFilial( cAlias ) + Iif(lSaveModel,Padr( cRecChv, TamSx3( cAlias + "_PROTUL" )[1] ),cRecChv) + '1' ) )
            
            nRecno := (cAlias)->(Recno())   
            oModel := FWLoadModel(cNmFun)
            
            If ( cAlias )->&( cAlias + "_STATUS" ) == '4'

                oModel:SetOperation( 4 )
                oModel:Activate()

                &( "StaticCall( " + cNmFun + ", GerarEvtExc , oModel, nRecno ,.T. )" )
                
            Else
                oModel:SetOperation(5)
                oModel:Activate()
                FwFormCommit(oModel)

                lExclV7J := .T.

                TAFRastro(cAlias, nInd, cRecChv, .T., .F.,  IIf(Type("oBrw") == "U", Nil, oBrw))
            EndIf
            
            oModel:DeActivate()

            If FindFunction('TafClearModel')
                TafClearModel(oModel)
            EndIf
        EndIf

    EndIf                           
             
Return (.T.)

//-------------------------------------------------------------------
/*/{Protheus.doc} TAFEvt3500
Verifica se o Evento pertence aos Eventos permitido pelo S-3000.

@Param		cEvento	-	Evento a ser verificado

@Return		lRet	-	Indica se o Evento é permitido ao S-3000

@Author		Evandro Italo / Lucas Passos
@Since		20/10/2022
@Version	1.0
/*/
//---------------------------------------------------------------------

Function TAFEvt3500( cEvento as Character)

	Local cAllowed	as Character
	Local lRet		as Logical

	Default cEvento	:=	""

	cAllowed	:=	"S-2500|S-2501|S-2555|"
	lRet		:=	.F.

	lRet := Posicione( "C8E", 1, xFilial( "C8E" ) + cEvento, "C8E_CODIGO" ) $ cAllowed

Return( lRet )
