#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "TOPCONN.CH"
#INCLUDE "TAFA630.CH"


/*/{Protheus.doc} 
	Dummy function - Debito tecnico
*/
Function TAFA630()
	
Return Nil

//---------------------------------------------------------------------
/*/{Protheus.doc} TAF630Grv
@type			function
@description	Função de integração dos dados para o evento S-5503.
@author		    Alexandre de Lima Santos
@since			30/10/2024
@version		1.0
@param cLayout   - Evento integrado
@param nOpc      - Numero de operação que será realizada
@param cFilEv    - Filial de envio do evento 
@param oXML      - Objeto que contem o arquivo com parse do xml realizado
@param cOwner    - Nome do erp que está realizando a integração 
@param cFilTran  - Caso seja um registro de tranferencia 
@param cPredeces - Evento predecessor
@param nTafRecno - Caso seja afastamento, recno para posicionar no predecessor
@param cComplem  - Caso seja uma folha com multiplos vinculos 
@param cGrpTran  - variavel para tranferencias entre grupos de empresa
@param cEmpOriGrp - Empresa para tranferencia entre grupos 
@param cFilOriGrp - Filial para tranferencia entre grupos
@param cXmlID     - Id do xml na integração
@param cEvtOri    - Evento de origem
@param lMigrador  - Caso a integração esteja sendo realizada pelo migrador
@param lDepGPE    - variavel de controle se evento for do gpe
@param cKey       - Variavel com valor do tafkey do registro
@param MatrC9V   - Matricula do registro na  tabela C9V
@param lLaySmpTot - Simplificação eSocial
@param lExclCMJ   - Se o evento é de exclusão
@param oTransf    - Caso evento seja de tranferencia
@param cXml       - Xml do evento
@param cAliEvtOri - alias do evento de origem
@param nRecEvtOri - recno do evento deo rigem
@param cFilPrev   - Filial do evento
@return		    lRet	-	Variável que indica se a importação foi realizada
@return		    aIncons	-	Array com as inconsistências encontradas durante a importação
/*/
//---------------------------------------------------------------------
Function TAF630Grv( cLayout as character, nOpc as Numeric, cFilEv as character, oXML as object, cOwner as character, cFilTran as character, cPredeces as character,; 
                        nTafRecno as numeric, cComplem as character, cGrpTran as character, cEmpOriGrp as character, cFilOriGrp as character, cXmlID as character, cEvtOri as character,;
                        lMigrador as logical, lDepGPE as logical, cKey as character, cMatrC9V as character, lLaySmpTot as logical, lExclCMJ as logical, oTransf as object, cXml as character, cAliEvtOri as character,;
                        nRecEvtOri as numeric, cFilPrev as character )

	Local aT8N			as array
	Local aT8O          as array
	Local aT8P          as array
	Local aT8Nvalue     as array
	Local aT8Ovalue     as array
	Local aT8Pvalue     as array
	Local aIncons		as array
    Local aChave		as array
	Local aRules		as array
	Local cNrProc       as character
	Local cMatCat       as character
	Local cCabec		as character
	Local cId           as character
	Local cSTABPAG      as character
	Local cFil          as character
	Local cCPF          as character 
	Local cVersao       as character
	Local cCmpsNoUpd    as character
	Local cPerApu       as character
	Local cProtul       as character
	Local lRet			as logical
	Local nCount        as numeric
	Local nCount1       as numeric 
    Local oModel		as object
	Local oBulkT8N      as object
	Local oBulkT8O      as object
	Local oBulkT8P      as object
	Local oResView      as object
	Local oResMatCat    as object
	Local oReStabPag    as object
	   
    Default cLayout		:= ""
	Default cXml        := ""
    Default cAliEvtOri  := ""
	Default cOwner		:= ""
    Default cFilTran	:= ""
    Default cPredeces	:= ""
    Default cComplem	:= ""
    Default cXmlID		:= ""
    Default cGrpTran	:= ""
    Default cEmpOriGrp	:= ""
    Default cFilOriGrp	:= ""
	Default cEvtOri     := ""
	Default cKey        := ""
    Default cMatrC9V    := ""
	Default cFilPrev    := ""
	Default cFilEv		:= ""
	Default lMigrador   := .F.
    Default lDepGPE     := .F.
    Default lLaySmpTot  := .F.
    Default lExclCMJ    := .F.
    Default nRecEvtOri  := 0
	Default nTafRecno	:= 0
	Default nOpc		:= 1
    Private oDados		:= Nil
    Default oXML		:= Nil
    Default oTransf     := Nil
    
	aIncons       := {}
	aT8N		  := {}
	aT8O          := {}
	aT8Nvalue     := {}
	aT8Ovalue     := {}
	aT8Pvalue     := {}
	aChave        := {}
	aRules        := {}
	cCmpsNoUpd    := "|T8N_FILIAL|T8N_ID|T8N_VERSAO|T8N_EVENTO|T8N_ATIVO|"
    cCabec		  := "/eSocial/evtFGTSProcTrab/"
    cNrProc       := ""
	cMatCat       := ""
	cId           := ""
	cSTABPAG      := ""
	cFil          := ""
	cCPF          := "" 
	cVersao       := ""
	cProtul       := ""
	lRet          := .F.
    nCount        := 0
	nCount1       := 0 
    oModel		  := Nil
	oBulkT8N      := Nil
	oBulkT8O      := Nil
	oBulkT8P      := Nil
	oResView      := JsonObject():new()
	oResMatCat    := Nil 
	oReStabPag    := Nil
    oDados := oXML

	If !TafColumnPos("T8N_FILIAL")
		Aadd(aIncons, STR0001)
		lRet := .F.
	Else

        cNrProc   := FTafGetVal(  cCabec + "ideProc/nrProcTrab", "C", .F., @aIncons, .F. )
        cCPF      := FTafGetVal(  cCabec + "ideTrabalhador/cpfTrab", "C", .F., @aIncons, .F. )
		
		T8N->( DBSetOrder(2) )
		If T8N->( DBSeek( xFilial("T8N") + PadR( cNrProc, TamSX3("T8N_NRPROC")[1] )  + cCPF + "1" ))   
			cVersao := T8N->T8N_VERSAO                                                                                                               
			TafDelTot( "T8N", xFilial("T8N"), T8N->T8N_ID, T8N->T8N_VERSAO,  {"T8N","T8O","T8P"} )
		EndIf

		aT8N := {{"T8N_FILIAL"},;
				{"T8N_ID"     },;
				{"T8N_VERSAO" },;
				{"T8N_LAYOUT" },;
				{"T8N_DTRECP" },;
				{"T8N_HRRECP" },;
				{"T8N_LOGOPE" },;
				{"T8N_NRPROC" },;
				{"T8N_CPF" 	  },;
				{"T8N_NOME"   },;
				{"T8N_PERAPU" },;
				{"T8N_XMLGRV" },;
				{"T8N_ATIVO"  },;
				{"T8N_PROTUL" },;
				{"T8N_VIEW"   }}
		
		aT8O := {{"T8O_FILIAL"},;
				{"T8O_ID"     },;
				{"T8O_VERSAO" },;
				{"T8O_SEQUEN" },;
				{"T8O_MATCAT" }}

		aT8P := {{"T8P_FILIAL"},;
				{"T8P_ID"    },;
				{"T8P_VERSAO"},;
				{"T8P_CHAVE" },;
				{"T8P_SEQUEN"},;
				{ "T8P_STABPA"}}

		oBulkT8N := FwBulk():New(RetSQLName("T8N"))
		oBulkT8O := FwBulk():New(RetSQLName("T8O"))
		oBulkT8P := FwBulk():New(RetSQLName("T8P"))
			
		oBulkT8N:SetFields(aT8N)
		oBulkT8O:SetFields(aT8O)
		oBulkT8P:SetFields(aT8P)

		cFil    := xFilial("T8N")
		cId     := TAFGeraID("TAF")
		cVersao := xFunGetVer()
		cPerApu := StrTran( FTafGetVal( cCabec + "ideEvento/perApur", "C", .F., @aIncons, .F. ) , "-", "" ) 
		cProtul := FTafGetVal( cCabec + "ideEvento/nrRecArqBase", "C", .F., @aIncons, .F. )

		cNome := TAFGetNT1U( FTafGetVal( cCabec + "ideTrabalhador/cpfTrab", "C", .F., @aIncons, .F. ) )
		
		If Empty(cNome)

			cNome := Posicione("C9V",3, xFilial("C9V") + FTafGetVal( cCabec + "ideTrabalhador/cpfTrab", "C", .F., @aIncons, .F. ) + "1","C9V_NOME")
			
			If Empty(cNome)
				cNome := Substr( Posicione("V9U",5, xFilial("V9U") + FTafGetVal( cCabec + "ideTrabalhador/cpfTrab", "C", .F., @aIncons, .F. ) + "1","V9U_NMTRAB"), 1, 70 )
			EndIf
		
		EndIf

		aT8Nvalue := {}
		aadd( aT8Nvalue /*"T8N_FILIAL"*/, cFil )
		aadd( aT8Nvalue /*"T8N_ID"*/	, cId )
		aadd( aT8Nvalue /*"T8N_VERSAO"*/, cVersao )
		aadd( aT8Nvalue /*"T8N_LAYOUT"*/, cLayNmSpac := TafNameEspace(cXML) )
		aadd( aT8Nvalue /*"T8N_DTRECP"*/, DATE() )
		aadd( aT8Nvalue /*"T8N_HRRECP"*/, TIME() )
		aadd( aT8Nvalue /*"T8N_LOGOPE"*/, '1' )
		aadd( aT8Nvalue /*"T8N_NRPROC"*/, cNrProc )
		aadd( aT8Nvalue /*"T8N_CPF"*/	, cCPF )
		aadd( aT8Nvalue /*"T8N_NOME"*/	, cNome )
		aadd( aT8Nvalue /*"T8N_NOME"*/	, cPerApu )
		aadd( aT8Nvalue /*"T8N_XMLGRV"*/, cXml )
		aadd( aT8Nvalue /*"T8N_ATIVO"*/, '1' )
		aadd( aT8Nvalue /*"T8N_PROTUL"*/, cProtul )

		oResView	:= JsonObject():New()
		oResView["id"] 				:= cFil + "|" + cId + "|" + cVersao
		oResView["period"] 			:= FTafGetVal( cCabec + "ideEvento/perApur", "C", .F., @aIncons, .F. )
		oResView["cpf"] 	 		:= cCPF  
		oResView["name"] 	 		:= cNome 
		oResView["receipt"]  		:= FTafGetVal( cCabec + "ideEvento/nrRecArqBase", "C", .F., @aIncons, .F. )
		oResView["processNumber"]	:= cNrProc

		aadd( aT8Nvalue /*"T8N_VIEW"*/, oResView:toJSON( ) )		
			
		nCount := 1
		cMatCat := cCabec + "infoTrabFGTS[" + cValToChar( nCount ) + "]"

		While oDados:xPathHasNode( cMatCat )
			
			aT8Ovalue := {}
			oResMatCat	:= JsonObject():New()
			oResMatCat["id"] 		    		:= cFil + "|" + cId + "|" + cVersao + "|" + strzero(nCount,2)
			oResMatCat["registration"] 			:= FTafGetVal( cMatCat + "/matricula", "C", .F., @aIncons, .F. )
			oResMatCat["category"] 				:= FTafGetVal( cMatCat + "/codCateg", "C", .F., @aIncons, .F. )
			oResMatCat["originCategory"] 		:= FTafGetVal( cMatCat + "/categOrig", "C", .F., @aIncons, .F. )
			oResMatCat["fgtsTot"] 	 			:= FTafGetVal( cMatCat + "/infoFGTSProcTrab/totalFGTS", "C", .F., @aIncons, .F. )
			oResMatCat["typeOfInscription"] 	:= FTafGetVal( cMatCat + "/infoFGTSProcTrab[1]/ideEstab[1]/tpInsc", "C",  .F., @aIncons, .F. )
			oResMatCat["registrationNumber"] 	:= FTafGetVal( cMatCat + "/infoFGTSProcTrab[1]/ideEstab[1]/nrInsc", "C",  .F., @aIncons, .F. )
			
			nCount1 := 1
			cSTABPAG := cMatCat + "/infoFGTSProcTrab[1]/ideEstab[1]/basePerRef[" + cValToChar( nCount1 ) + "]"

			While oDados:xPathHasNode( cSTABPAG )
				
				aT8Pvalue := {}

				oReStabPag	:= JsonObject():New()
				oReStabPag["id"] 		    			:= cFil + "|" + cId + "|" + cVersao + "|" + strzero(nCount,2) + "|" + strzero(nCount1,7)
				oReStabPag["referencePeriod"] 			:= FTafGetVal( cSTABPAG + "/perRef", 	      "C",  .F., @aIncons, .F. )
				oReStabPag["category"] 	 				:= FTafGetVal( cSTABPAG + "/codCateg", 		  "C",  .F., @aIncons, .F. )
				oReStabPag["typeOfLaborProcessValue"] 	:= FTafGetVal( cSTABPAG + "/tpValorProcTrab", "C",  .F., @aIncons, .F. )
				oReStabPag["remFGTSProcTrab"] 	 		:= FTafGetVal( cSTABPAG + "/remFGTSProcTrab", "C",  .F., @aIncons, .F. )
				oReStabPag["dpsFGTSProcTrab"] 	 		:= FTafGetVal( cSTABPAG + "/dpsFGTSProcTrab", "C",  .F., @aIncons, .F. )
				oReStabPag["remFGTSSefip"] 	 			:= FTafGetVal( cSTABPAG + "/remFGTSSefip", 	  "C",  .F., @aIncons, .F. )
				oReStabPag["dpsFGTSSefip"] 	 			:= FTafGetVal( cSTABPAG + "/dpsFGTSSefip", 	  "C",  .F., @aIncons, .F. )
				oReStabPag["remFGTSDecAnt"] 	 		:= FTafGetVal( cSTABPAG + "/remFGTSDecAnt",	  "C",  .F., @aIncons, .F. )
				oReStabPag["dpsFGTSDecAnt"] 	 		:= FTafGetVal( cSTABPAG + "/dpsFGTSDecAnt",   "C",  .F., @aIncons, .F. )

				aadd( aT8Pvalue /*"T8P_FILIAL"*/, cFil )
				aadd( aT8Pvalue /*"T8P_ID"*/	, cId )
				aadd( aT8Pvalue /*"T8P_VERSAO"*/, cVersao )
				aadd( aT8Pvalue /*"T8P_CHAVE"*/ , strzero(nCount,2) )
				aadd( aT8Pvalue /*"T8P_SEQUEN"*/, strzero(nCount1,7) )
				aadd( aT8Pvalue /*"T8P_STABPA"*/, oReStabPag:toJSON( ) )
				oBulkT8P:AddData(aT8Pvalue)
				
				nCount1 ++
				cSTABPAG := cMatCat + "/infoFGTSProcTrab[1]/ideEstab[1]/basePerRef[" + cValToChar( nCount1 ) + "]"

			EndDo

			aadd( aT8Ovalue /*"T8N_FILIAL"*/, cFil )
			aadd( aT8Ovalue /*"T8N_ID"*/	, cId )
			aadd( aT8Ovalue /*"T8N_VERSAO"*/, cVersao )
			aadd( aT8Ovalue /*"T8O_SEQUEN"*/, strzero(nCount,2) )
			aadd( aT8Ovalue /*"T8O_MATCAT"*/, oResMatCat:toJSON( ) )
			oBulkT8O:AddData(aT8Ovalue)

			nCount ++
			cMatCat := cCabec + "infoTrabFGTS[" + cValToChar( nCount ) + "]"

		EndDo

		If !Empty(aT8Nvalue)
			oBulkT8N:AddData(aT8Nvalue)
			oBulkT8N:Flush()
			oBulkT8N:Close()
			oBulkT8N:Destroy()
			oBulkT8N := nil
		EndIf
		
		If !Empty(aT8Ovalue)
			oBulkT8O:Flush()
			oBulkT8O:Close()
			oBulkT8O:Destroy()
			oBulkT8O := nil
		EndIf

		If !Empty(aT8Pvalue)
			oBulkT8P:Flush()
			oBulkT8P:Close()
			oBulkT8P:Destroy()
			oBulkT8P := nil
		EndIf
		
		If Empty( aIncons )
			lRet := .T.
		EndIf
		
	EndIf

Return( { lRet, aIncons } )

//-------------------------------------------------------------------
/*/{Protheus.doc} TafDelTot()

Deleta as tabelas para recriá-las novamente.
@author Alexandre Santos
@since 03/04/2024
@param cTable  - tabela principaal do evento 
@param cfil    -Filial do registro
@para  cId     - Id do registro
@param cVersao - Versao do registro  
@param aTableEve - Array com os nomes ds tabelas a serem deletadas
@version 1.0

/*/ 
//-------------------------------------------------------------------
Static Function TafDelTot( cTable as Character, cfil as Character, cId as Character, cVersao as Character, aTableEve as array )

	Local cDel    as character
	Local nI      as numeric

	Default aTableEve := {}
	Default cTable    := ""
	Default cFil      := ""
	Default cId       := ""
	Default cVersao   := ""

	cDel := ""
	nI   := 0

	For nI := 1 to Len(aTableEve)

		cDel := " DELETE FROM " + RetSqlName( aTableEve[nI] ) + " "
		cDel += " WHERE " + aTableEve[nI] + "_FILIAL = '" + cfil + "' "
		cDel += "  AND " + aTableEve[nI] + "_ID = '" + cId + "' "
		cDel += "  AND " + aTableEve[nI] + "_VERSAO = '" + cVersao + "' "

		TCSQLExec( cDel )

		Tafconout("---deleção da tabela " + aTableEve[nI] + "----")

	Next nI

Return ( Nil )
