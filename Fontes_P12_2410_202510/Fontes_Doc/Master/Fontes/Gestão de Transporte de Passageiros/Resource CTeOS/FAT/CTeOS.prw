#INCLUDE "TOTVS.CH"                                     
#INCLUDE "SPEDNFE.ch"                                                                         
//-----------------------------------------------------------------------------
/*/{Protheus.doc} CTeOSTransmissao
Transmissão do CTeOS

@param	oReq    {"msg": {"entidade":"","ambiente":"","modalidade": "","versao":"","documento": { "nota": "", "serie":"", "cliente":"", "loja": "" }}}
@param	oResp   {"response":{"cteos":[{"id":"","xml": "","rejeicao":{"codigo":"","descricao":""},"xmlProt": null,"xmlProt": ""}]},"error":null}

@return	Retorno logico indicando se o retorno foi gerado

@author  Renato Nagib
@since   22/09/2017
@version 12.1.18

/*/
//-----------------------------------------------------------------------------
Function CTeOSTransmissao(oReq, oResp, cEvento, lAut)
    
    Local aRetorno   as array
    Local cXml       as character
	Local cURL       as character
	Local cModelo    as character
	Local cTimeZone  as character
    Local cChaveCte  as character
    Local lTransmite as logical
    Local cTipoNota  as character
    Local cJsonRet   as character
    Local cError     as character
    Local cVersao    as character

    aRetorno   := {}
    cXml       := ""
    cURL       := PadR(GetNewPar("MV_SPEDURL","http://"), 250)
    cModelo    := "67"
    cTimeZone  := ""
    cChaveCte  := ""
    lTransmite := .F.
    cTipoNota  := "1"
    cJsonRet   := ""
    cError     := ""
    cVersao    := ""

    Default cEvento := ''
    Default lAut    := .F.
    Default oReq    := Nil

    If ValType(oReq) <> "U"
        cVersao    := Substr(oReq:msg:versao,1,1)
    EndIf   
    
    Private  oWS
	
    If !lAut
        cTimeZone := getUTC(oReq:msg:entidade)
	EndIf

    oWs:= wsNFeSBra():New()
	oWs:cUserToken := "TOTVS"
    If !lAut
	    oWs:cID_ENT    := oReq:msg:entidade
    Else
        oWs:cID_ENT    := ''
    EndIf
	oWS:_URL       := AllTrim(cURL) + "/NFeSBRA.apw"
	oWs:oWsNFe:oWSNOTAS :=  NFeSBRA_ARRAYOFNFeS():New()

    cJsonRet := '{ "cteos": [{'  

	If( existBlock("CTeOS_V" + cVersao, , .T.) )

        If(!oReq:msg:versao $ "3.00|4.00")
            cError := "Nenhum RdMake compilado para versão " + oReq:msg:versao
        Else
        
            aRetorno  := ExecBlock("CTeOS_V" + cVersao, .F., .F.,; 
                                                {cTipoNota,;                    //1
                                                oReq:msg:documento:serie,;      //2
                                                oReq:msg:documento:nota,;       //3
                                                oReq:msg:documento:cliente,;    //4
                                                oReq:msg:documento:loja,;       //5                                                 
                                                oReq:msg:ambiente,;             //6
                                                oReq:msg:versao,;               //7
                                                oReq:msg:modalidade,;           //8                                                
                                                cTimeZone,;                     //9
                                                oReq:msg:modal,;				//10
                                                cEvento })                		//11
                                                            
            cXml      := aRetorno[1]
            cChaveCte := aRetorno[2]        
            
            aSize(aRetorno,0)
            aRetorno := nil
            
            lTransmite := !empty(cXml)
            
            If(!lTransmite)
                cError := "Xml Inválido para Transmissão"
            Endif
        Endif    
	Else
        cError := 'RdMake "CTeOS_V' + cVersao + '" não compilado'        
    Endif

	If(lTransmite) .or. lAut					
		oWs:oWsRemessa3EnvNotas:oWSNOTAS := NFESBRA_ARRAYOFREMESSA3ENVNOTA():new()
		aadd(oWs:oWsRemessa3EnvNotas:oWSNOTAS:oWSREMESSA3ENVNOTA, NFESBRA_REMESSA3ENVNOTA():new())
		oWs:oWsRemessa3EnvNotas:oWSNOTAS:oWSREMESSA3ENVNOTA[1]:cID     := iif(lAut, '', oReq:msg:documento:serie + oReq:msg:documento:nota)
		oWs:oWsRemessa3EnvNotas:oWSNOTAS:oWSREMESSA3ENVNOTA[1]:cMODELO := cModelo
		oWs:oWsRemessa3EnvNotas:oWSNOTAS:oWSREMESSA3ENVNOTA[1]:cXML    := cXml
	
        If( oWS:Remessa3() )
                
            cJsonRet += '"id":"' + oWS:oWSREMESSA3RESULT:oWSNotas:oWSremessa3RetNota[1]:cID + '"'        
            
            If(type("oWS:oWSREMESSA3RESULT:oWSNotas:oWSremessa3RetNota[1]:cXmlSig") <>"U" )
                cJsonRet += ',"xml": "' + encode64(oWS:oWSREMESSA3RESULT:oWSNotas:oWSremessa3RetNota[1]:cXmlSig)  + '"' 
            Endif
            
            If( type("oWS:oWSREMESSA3RESULT:oWSNotas:oWSremessa3RetNota[1]:oWSrejeicao" ) <> "U")			     
                cJsonRet += ', "rejeicao":{'
                cJsonRet += '"codigo": "'    + oWS:oWSREMESSA3RESULT:oWSNotas:oWSremessa3RetNota[1]:oWSrejeicao:cCodigo + '"'
                cJsonRet += ',"descricao":"' + encode64(oWS:oWSREMESSA3RESULT:oWSNotas:oWSremessa3RetNota[1]:oWSrejeicao:cDescricao) + '"}'                    
                cJsonRet += ',"xmlProt": null'
            Endif    
            
            If(type("oWS:oWSREMESSA3RESULT:oWSNotas:oWSremessa3RetNota[1]:cXmlProt" ) <> "U" )                                                
                cJsonRet += ',"xmlProt": "' + encode64(oWS:oWSREMESSA3RESULT:oWSNotas:oWSremessa3RetNota[1]:cXmlProt) + '"'                
            Endif
                           
        Else
            cError := "" + iif( empty(getWscError(3)), getWscError(1), getWscError(3))        
        Endif
    Endif   

    cJsonRet += '}]}'   

    freeObj(oWS)
    oWS := nil
    
    oResp := getJsonResponse(cJsonRet, cError)
    
Return oResp <> nil
//-----------------------------------------------------------------------------------------------
/*/{Protheus.doc} CTeOSCancelamento
Transmite um cancelamento de CTeOS para o TSS

@param	oReq    {{"msg":{"entidade": "","canc":[{"chaveCTe":"","protocolo":"","justificativa":""}]} }
@param	oResp   {"response":{"motivo": "Cancelamento Transmitido com Sucesso","idEvento":[{"id": ""}]}, "error":null}

@return	Retorno logico indicando se o retorno foi gerado

@author  Renato Nagib
@since   30/09/2017
@version 12.1.18

/*/
//-----------------------------------------------------------------------------------------------
function CTeOSCancelamento(oReq, oResp, lAut)

    Local cURL        := PadR(GetNewPar("MV_SPEDURL","http://"),250)  
    Local cJsonRet    := ""
    Local cXml        := ""
    Local cError      := ""   
    Local oWs         := Nil
    Local nNotas      := 0

    Default lAut := .F.

    oWs:= WsNFeSBra():New()
	oWs:cUserToken := "TOTVS"
    if !lAut
	    oWs:cID_ENT    := oReq:msg:entidade
    Else
        oWs:cID_ENT    := ''
    EndIf
	oWS:_URL       := AllTrim(cURL) + "/NFeSBRA.apw"
	oWs:oWsNFe:oWsNotas :=  NFESBRA_ARRAYOFNFES():New()
	
    if !lAut
        for nNotas := 1 to len(oReq:msg:notas)

            cXml += '<cancelamento Id="' + oReq:msg:notas[nNotas]:chave + '">'
            cXml += '<xJust>' + oReq:msg:notas[nNotas]:justificativa + '</xJust>
            cXml += '</cancelamento>'

            aadd(oWs:oWsNFe:oWsNotas:oWSNFES,NFESBRA_NFES():New())	
            oWs:oWsNFe:oWsNotas:oWSNFES[nNotas]:cID := oReq:msg:notas[nNotas]:id
	        oWs:oWsNFe:oWsNotas:oWSNFES[nNotas]:cXML:= cXml
        next
    EndIf

    if(oWS:cancelanotas()) 
    
        cJsonRet := '{ "motivo": "Cancelamento Transmitido com Sucesso", "id": ['  
        
        for nNotas := 1 to len(oWS:oWSCANCELANOTASRESULT:oWSID:cSTRING)        
            cJsonRet += '{"id": "' + oWS:oWSCANCELANOTASRESULT:oWSID:cSTRING[nNotas] + '"}'
        next
        
        cJsonRet += ']}'
        
        //Atualização do Status da GZH
        G001MStatus('GZH_STATUS',"7")  
    
    endif    
    
    freeObj(oWs)
    oWS := nil

    oResp :=  getJsonResponse(cJsonRet, cError) 
    
return (oResp <> nil)
//-----------------------------------------------------------------------------------------------
/*/{Protheus.doc} CTeOSConsEvento
Consulta Status dos Eventos do CTe

@param	oReq    { "msg": {"entidade": "", "canc": [ {"chaveCTe": "", "protocolo": "","justificativa": ""}]} }
@param	oResp   {"status": 1,"details": "","autorizacao":{"protocolo": ""},"rejeicao": {"codigo": "", "motivo": ""}}

@return	Retorno logico indicando se o retorno foi gerado

@author  Renato Nagib
@since   24/09/2017
@version 12.1.18

/*/
//------------------------------------------------------------------------------------------------
function CTeOSConsEvento(oReq, oResp, lAut)
    
    Local oWS       := Nil
    Local cURL      := PadR(GetNewPar("MV_SPEDURL","http://"),250)  
    Local cStatEven := ""
    Local cMotEven  := ""
    Local cProtocolo:= ""    
    Local cJsonRet  := ""
    Local cError    := ""

    Default lAut := .F.

    oWS  := wsNFeSBra():new()
    oWS:_URL       := AllTrim(cURL) + "/NFeSBRA.apw"
    oWS:cUserToken := "TOTVS"
    oWS:cID_ENT     := iif(lAut, '', oReq:msg:entidade)
    oWS:cEvento     := iif(lAut, '', oReq:msg:codEvento)
    oWS:cChvInicial := iif(lAut, '', oReq:msg:chaveCTe)
    oWS:cChvFinal   := iif(lAut, '', oReq:msg:chaveCTe)
 
    if(oWS:nfeMonitorLoteEvento()) .or. lAut
        nLote := len(oWS:oWSNFEMONITORLOTEEVENTORESULT:oWSNFEMONITOREVENTO)
        if ( nLote > 0 ) 
	        cStatEven := str(oWS:oWSNFEMONITORLOTEEVENTORESULT:oWSNFEMONITOREVENTO[nLote]:nCStatEven, 3)
	        cMotEven  := alltrim(oWS:oWSNFEMONITORLOTEEVENTORESULT:oWSNFEMONITOREVENTO[nLote]:cCMotEven)
	        
	        if( oWS:oWSNFEMONITORLOTEEVENTORESULT:oWSNFEMONITOREVENTO[nLote]:nCStatEven == 0 )            
	        
	            cJsonRet :='{"status": 1, "details": "Aguardando Processamento.", '
	            cJsonRet += '"autorizacao":{"protocolo": ""}, '
	            cJsonRet += '"rejeicao": {"codigo": "", "motivo": ""} }' 
	        
	        elseif(oWS:oWSNFEMONITORLOTEEVENTORESULT:oWSNFEMONITOREVENTO[nLote]:nProtocolo > 0 )
	
	            cProtocolo:= alltrim(str(oWS:oWSNFEMONITORLOTEEVENTORESULT:oWSNFEMONITOREVENTO[nLote]:nProtocolo))
	            cJsonRet := '{"status": 2, "details": "Evento Autorizado.", '
	            cJsonRet += '"autorizacao":{"protocolo": "' + cProtocolo + '"}, '
	            cJsonRet += '"rejeicao": {"codigo": "", "motivo": ""} }'
	            
	        else
	            cJsonRet := '{"status": 3, "details": "Evento Rejeitado.", '
	            cJsonRet += '"autorizacao":{"protocolo": "" }, "rejeicao": '
	            cJsonRet += '{ "codigo": "' + cStatEven +'", "motivo":"' + cMotEven + '"}}' 
	
	        endif
		else
			cError := "Documento não possui evento."	  
		endif        
    else
        cError := iif( empty( getWscError(3)), getWscError(1), getWscError(3))
    endif
    
    oResp := getJsonResponse(cJsonRet, cError)
    
return oResp <> nil
//-----------------------------------------------------------------------------------------------
/*/{Protheus.doc} CTeOSRetorno
Retorna dados do CTeOS

@param	oReq        { "msg": { "entidade": "", "cteos": [ {"id":"" }]}}
@param	oResp       {"xml": "","xmlProt": "","id": "","protocolo": "","rejeicao": null}

@return	Retorno logico indicando se o retorno foi gerado

@author  Renato Nagib
@since   24/09/2017
@version 12.1.18

/*/
//------------------------------------------------------------------------------------------------
function CTeOSRetorno(oReq, oResp, lAut)

    local oWS    
    local nCTeOS
    Local cURL     := PadR(GetNewPar("MV_SPEDURL","http://"),250)  
    local cError
    local cJsonRet
    Default lAut := .F.

    oWS := wsNFeSBra():new()    
    oWS:oWSNFEID := NFESBRA_NFES2():New()
    oWS:oWSNFEID:oWSNOTAS := NFESBRA_ARRAYOFNFESID2():new()
    oWS:_URL := allTrim(cURL)+"/NFeSBRA.apw"			
    oWS:nDIASPARAEXCLUSAO := 0
    oWS:cUserToken := "TOTVS"
    if !lAut
        oWS:cID_ENT := oReq:msg:entidade

        for nCTeOS := 1 to len(oReq:msg:cteos)
            aadd(oWS:oWSNFEID:oWSNOTAS:oWSNFESID2, NFESBRA_NFESID2():new() )
            oWS:oWSNFEID:oWSNOTAS:oWSNFESID2[nCTeOS]:cID := oReq:msg:cteos[nCTeOS]:id
        next    
    Else
        oWs:cID_ENT    := ''
    EndIf
    
    if( oWS:retornaNotas() )
        
        cJsonRet := '{ "cteos":['
        
        for nCTeOS := 1 to len(oWS:oWSRETORNANOTASRESULT:oWSNotas:oWSNFES3)            
            
            if( nCTeOS > 1)
                cJsonRet += ","
            endif
            
            cJsonRet += '{'
            cJsonRet += '"xml": "' + encode64(oWS:oWSRETORNANOTASRESULT:oWSNotas:oWSNFES3[nCTeOS]:oWSNfe:cXml)+ '"'
            cJsonRet += ',"xmlProt": "' + encode64(oWS:oWSRETORNANOTASRESULT:oWSNotas:oWSNFES3[nCTeOS]:oWSNfe:cXmlProt) + '"'
            cJsonRet += ',"id": "' + alltrim(oWS:oWSRETORNANOTASRESULT:oWSNotas:oWSNFES3[nCTeOS]:cId) + '"'
            cJsonRet += ',"protocolo": "' + oWS:oWSRETORNANOTASRESULT:oWSNotas:oWSNFES3[nCTeOS]:oWSNfe:cProtocolo + '"'
            cJsonRet += ',"rejeicao": null'
            cJsonRet += '}'

        next
    
        cJsonRet += ']}'
    
    else
        cError := iif( empty( getWscError(3)), getWscError(1), getWscError(3))    
    endif
    
    freeObj(oWS)
    oWs := nil
    
    oResp := getJsonResponse(cJsonRet, cError)

return oResp <> nil
//-----------------------------------------------------------------------------------------------
/*/{Protheus.doc} CTeOSMonitor
Retorna dados do CTeOS

@param	oReq        {"msg":{"entidade": "","modelo": "67","id": ""}}
@param	oResp       {"id": "", "protocolo": "", "situacao": "","statusSef": "","descSef": "", "status": boolean}'

@return	Retorno logico indicando se o retorno foi gerado

@author  Renato Nagib
@since   24/09/2017
@version 12.1.18

/*/
//------------------------------------------------------------------------------------------------
function CTeOSMonitor(oReq, oResp)
    
    local oWS
    local cError
    local cEntidade := getCfgEntidade(@cError)
    local cJsonRet
    local lSend       := .F.
    local nLote
    local cStatusSef  := ""
    local cDescSef    := "Documento não Processado"
    Local cURL        := PadR(GetNewPar("MV_SPEDURL","http://"),250)  
    local cStatusProc := "1"
    local aRetorno      := {}
    local nX            := 0
    
    if(!empty(cEntidade))
        oWS := wsNFeSBra():new()    
        oWS:_URL := allTrim(cURL) + "/NFeSBRA.apw"
        oWS:cUserToken := "TOTVS"
        oWS:cID_ENT    := oReq:msg:entidade
        oWS:cIdInicial := oReq:msg:id
        oWS:cIdFinal   := oReq:msg:id
        oWS:cModelo    := "67"
        
        lSend := oWS:monitorFaixa()
        
    endif
    
    if(lSend)
        
        if(!empty(oWs:oWSMonitorFaixaResult:oWSMonitorNFE))
            
            nLote := len(oWs:oWSMonitorFaixaResult:oWSMonitorNFE[1]:oWSErro:oWSLoteNFe)                
            cStatusSef := oWs:oWSMonitorFaixaResult:oWSMonitorNFE[1]:oWSErro:oWSLoteNFe[nLote]:cCodRetNFe
            cDescSef   := oWs:oWSMonitorFaixaResult:oWSMonitorNFE[1]:oWSErro:oWSLoteNFe[nLote]:cMsgRetNFe
            
            if( left(cStatusSef, 1) == "1" )            
                //Autorizado
                if( cStatusSef $ "100|134|135|136")
                    cStatusProc := "2"                
                //Cancelado
                elseif( cStatusSef $ "101|102")
                    cStatusProc := "3"                  
                //lote nao encontrado/Uso denegado
                elseif( cStatusSef $ "106|110")
                    cStatusProc := "4"
                //Não processado
                else
                    cStatusProc := "1"
                endif    
            //Rejeitado
            else
                cStatusProc := "4"
            endif
            
                     
            cJsonRet := '{'  
            cJsonRet += ' "id": "' + oWs:oWSMonitorFaixaResult:oWSMONITORNFE[1]:cId + '"'
            cJsonRet += ', "protocolo": "' + oWs:oWSMonitorFaixaResult:oWSMonitorNFE[1]:cProtocolo + '"'
            cJsonRet += ', "situacao": "' + oWs:oWSMonitorFaixaResult:oWSMonitorNFE[1]:cRecomendacao + '"'
            cJsonRet += ', "statusSef": "' + cStatusSef + '"'
            cJsonRet += ', "descSef": "' + cDescSef + '"'
            cJsonRet += ', "status": "' + cStatusProc + '"'

            //-------------------------------------------------------------
            // Chave Eletronica
            // Realizado ajuste para gravar nas tabelas SF3 e SFT, e com 
            // isso, trouxe para ser exibido no Browse.
            // @Douglas Parreja
            // @Date: 20/03/2018
            //-------------------------------------------------------------
            if (  (valtype(oWs:oWSMonitorFaixaResult:oWSMONITORNFE[1]:cId) <> "U") .and.;
                     (valtype(oWs:oWSMonitorFaixaResult:oWSMonitorNFE[1]:cProtocolo) <> "U") .and.;
                         (valtype(oWs:oWSMonitorFaixaResult:oWSMonitorNFE[1]:cRecomendacao) <> "U") .and.;
                            (valtype(cStatusSef) <> "U") .and.;
                                (valtype(cDescSef) <> "U") .and.;
                                    (valtype(cStatusProc) <> "U") .and.;
                                        (valtype(oReq:msg:serie) <> "U") .and.;
                                            (valtype(oReq:msg:Nota) <> "U") )


                aAdd( aRetorno, {   oWs:oWSMonitorFaixaResult:oWSMONITORNFE[1]:cId              ,;  // 1-Id
                                    oWs:oWSMonitorFaixaResult:oWSMonitorNFE[1]:cProtocolo       ,;  // 2-Protocolo
                                    oWs:oWSMonitorFaixaResult:oWSMonitorNFE[1]:cRecomendacao    ,;  // 3-Situacao
                                    cStatusSef                                                  ,;  // 4-Status Sefaz
                                    cDescSef                                                    ,;  // 5-Descricao Sefaz
                                    cStatusProc                                                 ,;  // 6-Status Processamento
                                    oReq:msg:serie                                              ,;  // 7-Serie
                                    oReq:msg:Nota                                               ;   // 8-Nota
                                })
             
                if len( aRetorno ) > 0                                   
                    if getXMLNFE( oReq:msg:entidade, @aRetorno )
                        if (len( aRetorno ) > 0)
                            monitorUpd( oReq:msg:entidade, aRetorno )
                        endif
                    endif
                endif                
			endif

            //-------------------------------------------------------------
            // Sera exibido no Browse a chave
            //-------------------------------------------------------------
            if len(aRetorno) > 0
                for nX := 1 to len(aRetorno)
                    if valtype(aRetorno[nX][9]) <> "U"
                        if len(aRetorno[nX][9]) > 0
                            cJsonRet += ', "chave eletronica": "' + SubStr(NfeIdSPED(aRetorno[nX][9],"Id"),4)     
                        endif
                    endif
                next nX
            endif
            cJsonRet +=    + '"}'

            FreeObj( oWs )
	        oWs	:= nil

        else
            cError := "Documento não transmitido para o TSS"
        endif
    else
        cError := iif( empty( getWscError(3)), getWscError(1), getWscError(3))
    endif

    oResp := getJsonResponse(cJsonRet, cError)
    
return oResp <> nil
//-----------------------------------------------------------------------------------------------
/*/{Protheus.doc} CTeOSCCe
Transmite uma Carta de Correção de CTeOS para o TSS

@param	cEntidade       Codigo da Entidade
@param	cChaveCTe       Chave do CTeOS 
@param	cProtocolo      Protocolo do CTeOS
@param  cJustificativa  Justificativa do cancelamento
@param  cRetorno        String com Retorno da Transmissão

@return	Retorno logico indicando se o retorno foi gerado

@author  Renato Nagib
@since   30/09/2017
@version 12.1.18

/*/
//-----------------------------------------------------------------------------------------------
function CTeOSCCe(oReq, oResp, lAut)
    
    Local cXml      := ""
    Local cError    := ""
    Local lSend     := .F.
    Local aIds      := {}
    Local cJsonRet  := ""
    Local nItens    := 0

    Default lAut := .F.

    if !lAut
        cXml := xmlEvtCCe(oReq:msg:cteos[1]:chaveCte,;
            oReq:msg:ambiente, oReq:msg:cteos[1]:correcoes)
        
        lSend := transmiteEvento(oReq:msg:entidade, cXml, @aIds, @cError)
        
        if(lSend)        
            cJsonRet := '{ "motivo": "Carta de Correcao Transmitida com Sucesso", "idEvento": ['  
            
            for nItens := 1 to len(aIds)            
                cJsonRet += '{"id": "' + aIds[nItens] + '"}'
            next
            
            cJsonRet += ']}'
        
        endif    

        oResp :=  getJsonResponse(cJsonRet, cError) 
    endif
return (oResp <> nil)
//-------------------------------------------------------------------
/*/{Protheus.doc} CTeOSConfig
Configuração do CTeOS

@param	nil

@return	nil

@author  Renato Nagib
@since   22/09/2017
@version 12.1.18

/*/
//-------------------------------------------------------------------
function CTeOSConfig()
    
    Local lPSW         := .F.
    Local lAdminNfe    := getNewPar("MV_ADMNFE",.T.)
    Local lOk          := .F.        
    Local cError       := ""
    Local cEntidade    := ""
    Local cAmbiente    := ""
    Local cModalidade  := ""    
    Local cHrVerao     := "2"
    Local cHorario     := "2"
    Local nTempo       := 0
    Local aCfgVerao    := {}
    Local aAmbiente    := {STR0031, STR0032}    
    Local aModalidade  := {STR0033}
    Local aHrVerao     := {"1-Sim", "2-Nao"}
    Local aHorario     := {"1-Fernando de Noronha", "2-Brasilia", "3-Manaus", "4-Acre"}    
    Local cModelo      := "67"
    Local aPerg        := {}    
	Local cVersao      := ""
    Local aVersao      := {"3.00", "4.00"}		
    Local aParam       := {"", "", "", "", "", 0}
    Local CTeOSPar     := "CTEOS" + SM0->M0_CODIGO + SM0->M0_CODFIL
    
	
    lPSW := pswAdmin( /*cUser*/, /*cPsw*/, retCodUsr()) == 0 
    
    if( !lAdminNfe .or. lPSW )
        
        lOk := isConnTSS(@cError)
        
        if(lOk)
            cEntidade := getCfgEntidade(@cError)
            lOk := empty(@cError)
        endif    

        if(lOk)
            cAmbiente := getCfgAmbiente(@cError, cEntidade, cModelo)				        
        endif                
        
        if(empty(cError))
            cModalidade := PADR(getCfgModalidade(@cError, cEntidade, cModelo), 30)				
        endif
        
        if(empty(cError))
            cVersao := getCfgVersao(@cError, cEntidade, '67')	
        endif
        
        if(empty(cError))
            nTempo := getCfgEspera(@cError, cEntidade)				
        endif
        
        if(empty(cError))
            aCfgVerao := getCfgEpecCte(@cError)
            cHrVerao := aCfgVerao[12]
            cHorario := aCfgVerao[11]
        endif
        

        if(!empty(cError))
            Aviso("CTeOS", cError, {STR0114}, 3)
        else
        
            aadd(aPerg, {2, STR0035, cAmbiente, aAmbiente, 120, ".T.", .T., ".T." })
            aadd(aPerg, {2, STR0036, cModalidade, aModalidade, 120, ".T.", .T., ".T."})
            aadd(aPerg, {2, STR0037 + " CTe", cVersao, aVersao, 120, ".T.", .T., ".T."})        
            aadd(aPerg, {2, STR0369, cHrVerao, aHrVerao, 120, ".T.", .T., ".T."})                    
            aadd(aPerg, {2, "Horario", cHorario, aHorario, 120, ".T.", .T., ".T."})                    
            aadd(aPerg, {1, STR0071, nTempo, "99", ".T.", "", ".T.", 30, .F.})
        
            aParam := { subStr(cAmbiente, 1, 1), subStr(cModalidade, 1, 1),;
                        cVersao, cHrVerao, cHorario, nTempo}


            /*----------------------------------------------------------------------------------
                                    Atualiza configurações do TSS  
            ----------------------------------------------------------------------------------*/											
            if( paramBox(aPerg, "Parametros - CTeOS", aParam, , , , , , , CTeOSPar, .T., .F.) )

                if( aParam[1] <> cAmbiente)
                    cAmbiente := getCfgAmbiente(@cError, cEntidade, cModelo, aParam[1])				
                endif

                if( aParam[2] <> cModalidade)
                    cModalidade := PADR(getCfgModalidade(@cError, cEntidade, cModelo, aParam[2]),30)
                endif

                if( aParam[3] <> cVersao)
                    cVersao := getCfgVersaoCTe(@cError, cEntidade, "67", aParam[3])
                endif
                
                if( aParam[4] <> cHrVerao .or. aParam[5] <> cHorario)        
                     aCfgVerao :=  getCfgEpecCte(@cError, cEntidade, "4.00",;
                                                 "4.00", "4.00", "4.00", "4.00",;
                                                 "4.00", "4.00", "4.00", , aParam[4],;
                                                 aParam[5], "4.00", "4.00")
                     cHrVerao := aCfgVerao[12]
                     cHorario := aCfgVerao[11]
                endif   

                if( aParam[6] <> nTempo )
                    nTempo := getCfgEspera(@cError, cEntidade, aParam[6])
                endif   

            endIf
        
        endif
    elseif(!lPSW)
        help( "", 1, "SEMPERM" )
    endif	

return
//-----------------------------------------------------------------------------------------------
/*/{Protheus.doc} retProtCte
Monta XML de deistribuição do CTe

@param cXmlCte      XML assinado 
@param cXmlProt     XML Protocolo
@param cVersao      Vesao do CTeOS

@return	cXml        Xml de Distribuição

@author  Renato Nagib
@since   24/09/2017
@version 12.1.18

/*/
//------------------------------------------------------------------------------------------------
function retProtCte(cXMLCte, cXMLProt, cVersao)

    Local nAt       := 0      
    Local cXml      := ""

    nAt := At("?>",cXmlProt)

    if nAt > 0
        nAt += 2
    else
        nAt := 1
    endIf

    if !Empty(cXMLCte)
        cXml := '<?xml version="1.0" encoding="UTF-8"?>'
        cXml += '<cteOSProc xmlns="http://www.portalfiscal.inf.br/cte" versao="' + cVersao + '">'
        cXml += cXMLCte
    endif
    
    do case
        case "retConsSitCTe" $ cXmlProt				
            if("protCTe" $ cXmlProt)
                nAt := At("<protCTe",cXmlProt)
                cXml += StrTran(SubStr(cXmlProt,nAt),"</retConsSitCTe>","")
            else	
                cXml += StrTran(SubStr(cXmlProt,nAt),"retConsSitCTe","protCTe")
            endif
        case "retCancCTe" $ cXmlProt
            cXml += cXmlProt
        case "retInutCTe" $ cXmlProt
            cXml += cXmlProt
        case "protCTe" $ cXmlProt
            cXml += cXmlProt
        otherWise

            cXml += "<protCTe>"
            cXml += cXmlProt
            cXml += "</protCTe>"
    endCase
    
    if( !empty(cXMLCte) )
        cXml += '</cteOSProc>
    endif	

return(allTrim(cXml))
//-----------------------------------------------------------------------------------------------
/*/{Protheus.doc} xmlEvtCCe
Montagem do Xml de carta de correção

@param	cChaveCTe       Chave do CTeOS
@param  cAmbiente       Ambiente para transmissão do Evento
@param  aCorrecao       Informações das correções aCorrecao[x][1] = Grupo;  aCorrecao[x][2] = campo;aCorrecao[x][3] = valor

@return cXml            String com Xml do Evento

@author  Renato Nagib
@since   30/09/2017
@version 12.1.18

/*/
//-----------------------------------------------------------------------------------------------
static function xmlEvtCCe(cChaveCTe, cAmbiente, aCorrecao)
    
    Local cXml := ""
    Local nCorrecao
    Local cTipoEvento := "110110"

    cXml +='<envEvento>'
    cXml +='<eventos>'
    cXml +='<detEvento>'
    cXml +='<tpEvento>' + cTipoEvento + '</tpEvento>'
    cXml +='<chnfe>' + cChaveCTe + '</chnfe>'
    cXml +='<ambiente>' + cAmbiente + '</ambiente>'      	
    for nCorrecao := 1 to len(aCorrecao)    
        cXml +='<Correcao>'
        cXml +='<grupo>'+ aCorrecao[nCorrecao]:grupo+ '</grupo>'
        cXml +='<campo>'+ aCorrecao[nCorrecao]:campo + '</campo>'
        cXml +='<valor>'+ aCorrecao[nCorrecao]:valor + '</valor>'
        cXml +='</Correcao>'
    next
    
    cXml +='</detEvento>'
    cXml +='</eventos>'
    cXml +='</envEvento>'

return cXml
//-----------------------------------------------------------------------------------------------
/*/{Protheus.doc} transmiteEvento
Transmissão dos Eventos

@param	cEntidade       Codigo da Entidade
@param	cXml            Xml do Evento
@param  aIds            Referencia para retorno dos Ids dos eventos transmitidos
@param  cError          Referencia para retorno de erro na execução

@return lSend           Indica se o Evento foi Transmitido

@author  Renato Nagib
@since   30/09/2017
@version 12.1.18

/*/
//-----------------------------------------------------------------------------------------------
static function transmiteEvento(cEntidade, cXml, aIds, cError)

    Local oWS       := Nil
    Local cURL      := PadR(GetNewPar("MV_SPEDURL","http://"),250)  
    Local lSend     := .F.
    Local nEventos  := 0

    Default cEntidade := ''
    Default cXml      := ''

    oWS := wsNFeSBra():new()
    oWS:_URL := allTrim(cURL) + "/NFeSBRA.apw"			
    oWs:cUserToken := "TOTVS"
    oWS:cID_ENT    := cEntidade    
    oWS:cXml_lote  := cXml 

    if( oWS:remessaEvento() )
        
        for nEventos := 1 to len(oWS:oWSREMESSAEVENTORESULT:cString)
            aadd(aIds, oWS:oWSREMESSAEVENTORESULT:cString[nEventos])
        next    
        
        lSend := !empty(aIds)

    else
        cError := iif( empty( getWscError(3)), getWscError(1), getWscError(3))
    endif

return lSend
//-----------------------------------------------------------------------------------------------
/*/{Protheus.doc} getUTC
Calcula Hoario UTC

@param cEntidade      Codgo da Entidade

@return	cRet        UTC

@author  Renato Nagib
@since   24/09/2017
@version 12.1.18

/*/
//------------------------------------------------------------------------------------------------
Static Function getUTC(cEntidade)

    Local cError  := ""
    Local cRet 	  := ""
    Local aCfgCTe := getCfgEpecCte(@cError, cEntidade)
        
    if(empty(cError) )
        
        //Horario de Verão 
        if(left(aCfgCTe[12],1) == "1") 
            //Fernando de Noronha
            if(left(aCfgCTe[11], 1) == "1")		
                cRet := "-01:00"
            //Brasilia
            elseif(substr(aCfgCTe[11], 1, 1) == "2")	
                cRet := "-02:00"
            //Acre
            elseif(substr(aCfgCTe[11], 1, 1) == "4")	
                cRet := "-04:00"
            //Manaus
            else
                cRet := "-03:00"
            endif
        else
            //Fernando de Noronha
            if Substr(aCfgCTe[11], 1, 1) == "1"		
                cRet := "-02:00"
            //Brasilia
            elseIf Substr(aCfgCTe[11], 1, 1) == "2"	
                cRet := "-03:00"
            //Acre
            elseif	Substr(aCfgCTe[11], 1, 1) == "4"	
                cRet := "-05:00"
            //Manaus
            else
                cRet := "-04:00"						
            endif
        endif
    endif   
return cRet
//-----------------------------------------------------------------------------------------------
/*/{Protheus.doc} getJsonResponse
MOnta Resposta padrão Json 

@param cJsonRet     Objeto de retorno
@param cError       Mensagem de Error

@return	cJsonResp   Objeto de resposta

@author  Renato Nagib
@since   30/09/2017
@version 12.1.18

/*/
//------------------------------------------------------------------------------------------------
function getJsonResponse(cJsonRet, cError)

    Local oResp        
    
    Default cError   := 'null'
    Default cJsonRet := 'null'
    
    if( empty(cError) )
        cError := 'null'
    endif    

    if( cJsonRet <> 'null' .and. !fwJsonDeserialize(cJsonRet, @oResp))        
        cError := "invalid JSON Message: " + cJsonRet        
    endif

    if(cError <> 'null')
        cError := '"' + encode64(cError) + '"'    
        cJsonRet := 'null'
    endif    
    
    fwJsonDeserialize('{ "error": ' + cError + ',"response":  ' + cJsonRet + '}', @oResp)

return oResp

//-------------------------------------------------------------------
/*/{Protheus.doc} getXMLNFE
executa e Retorna dados do metodo retornaNotas

@param  cIdEnt			Entidade no TSS
        aDados			array de retorno do monitorFaixa
        cModelo			Modelo do documento
        lReprocesso	    Reprocesso de documentos nao retornados 

@return	aDados          aDados[1] - Protocolo
                        aDados[2] - Xml do CTEOs
                        aDados[3] - Data hora Recebimento

@author  Douglas Parreja
@since   20/03/2018
@version 12
/*/
//-------------------------------------------------------------------
static Function getXMLNFE( cIdEnt, aDados )

	Local cURL				:= PadR(GetNewPar("MV_SPEDURL","http://Localhost:8080/sped"),250)
	Local cProtocolo		:= ""
	Local cXml				:= ""
	Local cDHRecbto		    := ""
	Local cDtHrRec   		:= ""
	Local cDtHrRec1		    := "" 
	Local dDtRecib			:=	CToD("")
	Local nDtHrRec1		    := 0
    Local nX                := 0
	Local oWS	
    
	Private oDHRecbto

    Default cIdEnt  := ""
    Default aDados  := {}
	
    if ( !empty(cIdEnt) .and. (len(aDados) > 0) )

        oWS:= WSNFeSBRA():New()
        oWS:cUSERTOKEN        := "TOTVS"
        oWS:cID_ENT           := cIdEnt
        oWS:oWSNFEID          := NFESBRA_NFES2():New()
        oWS:oWSNFEID:oWSNotas := NFESBRA_ARRAYOFNFESID2():New()
        oWS:nDIASPARAEXCLUSAO := 0
        oWS:_URL := AllTrim(cURL)+"/NFeSBRA.apw"


        for nX := 1 to len( aDados )
            //---------------------------------------------------------------
            // Como a rotina de CTEOs nao tem a opcao de Range monitor,
            // neste caso estou adicionando unico registro.
            //---------------------------------------------------------------
            aadd(oWS:oWSNFEID:oWSNotas:oWSNFESID2,NFESBRA_NFESID2():New())
            Atail(oWS:oWSNFEID:oWSNotas:oWSNFESID2):cID := alltrim( aDados[nX][1] ) 

            if len(oWS:oWSNFEID:oWSNotas:oWSNFESID2) > 0
                
                if oWS:RETORNANOTASNX() 

                    if len(oWs:oWSRETORNANOTASNXRESULT:OWSNOTAS:OWSNFES5) > 0 
                        
                        nPosId := aScan(oWs:oWSRETORNANOTASNXRESULT:OWSNOTAS:OWSNFES5,{|X| alltrim(X:cID) == alltrim( aDados[nX][1] ) }) 
                        
                        if nPosId > 0
                            //---------------------------------------------------------------
                            // Modalidade Normal
                            //---------------------------------------------------------------
                            cProtocolo	:= oWs:oWSRETORNANOTASNXRESULT:OWSNOTAS:OWSNFES5[nPosId]:oWSNFE:CPROTOCOLO
                            cXml		:= oWs:oWSRETORNANOTASNXRESULT:OWSNOTAS:OWSNFES5[nPosId]:oWSNFE:CXML
                            cDHRecbto	:= oWs:oWSRETORNANOTASNXRESULT:OWSNOTAS:OWSNFES5[nPosId]:oWSNFE:CXMLPROT
                        
                            
                            //---------------------------------------------------------------
                            //Tratamento para gravar a hora da transmissao da NFe
                            //---------------------------------------------------------------
                            If !empty(cProtocolo)
                                oDHRecbto		:= XmlParser(cDHRecbto,"","","")
                                cDtHrRec		:= IIf(Type("oDHRecbto:_ProtNFE:_INFPROT:_DHRECBTO:TEXT")<>"U",oDHRecbto:_ProtNFE:_INFPROT:_DHRECBTO:TEXT,"")
                                oDHRecbto		:= NIL
                                nDtHrRec1		:= RAT("T",cDtHrRec)
                                
                                If nDtHrRec1 <> 0
                                    cDtHrRec1	:=	SubStr(cDtHrRec,nDtHrRec1+1)
                                    dDtRecib	:=	SToD(StrTran(SubStr(cDtHrRec,1,AT("T",cDtHrRec)-1),"-",""))
                                EndIf
                
                            EndIf
                            //---------------------------------------------------------------
                            // Atribuindo valores no array
                            //---------------------------------------------------------------                            
                            aAdd( aDados[nX], cXml      ) // 9-Xml
                            aAdd( aDados[nX], cDHRecbto ) // 10-Hora Recebimento 										
                            aAdd( aDados[nX], cDtHrRec1 ) // 11-Hora Recebimento
                            aAdd( aDados[nX], dDtRecib  ) // 12-Data Recebimento                        												
                        
                        endif            
                    endif
                else
                    Aviso("CTEOS",IIf(Empty(GetWscError(3)),GetWscError(1),GetWscError(3)),{"OK"},3)
                endif
            endif
        next nX
        
        FreeObj( oWS )
        oWs	:=	nil
    
    endif
	
return ( iif( len(aDados)>0, .T., .F.) )

//-------------------------------------------------------------------
/*/{Protheus.doc} monitorUpd
Funcao responsavel por atualizar os livros fiscais.

@param  cIdEnt			Entidade no TSS
        aDados			array de retorno do monitorFaixa
        
@author  Douglas Parreja
@since   20/03/2018
@version 12
/*/
//-------------------------------------------------------------------
static function monitorUpd(cIdEnt, aDados, lAut)

	Local cId			:= ""
	Local cProtocolo	:= ""
	Local cSituacao		:= ""
	Local cStatusSef	:= ""
	Local cDescSef		:= ""
	Local cStatusProc	:= ""
	Local cXml 		    := ""
    Local cSerie        := ""
    Local cNota 	    := ""
	Local cDHRecbto		:= ""
	Local cDtHrRec1	    := ""
	Local dDtRecib		:= date()
    Local nX            := 0

    Default aDados      := {}
    Default lAut        := .F.
	
    for nX := 1 to len( aDados )
								
        cId				:= iif( valtype(aDados[nX][1])<>"U" ,  aDados[nX][1], cId           ) // 1-Id
		cProtocolo		:= iif( valtype(aDados[nX][2])<>"U" ,  aDados[nX][2], cProtocolo    ) // 2-Protocolo		
		cSituacao		:= iif( valtype(aDados[nX][3])<>"U" ,  aDados[nX][3], cSituacao     ) // 3-Situacao 		
		cStatusSef		:= iif( valtype(aDados[nX][4])<>"U" ,  aDados[nX][4], cStatusSef    ) // 4-Status Sefaz		
		cDescSef		:= iif( valtype(aDados[nX][5])<>"U" ,  aDados[nX][5], cDescSef      ) // 5-Descricao Sefaz
		cStatusProc		:= iif( valtype(aDados[nX][6])<>"U" ,  aDados[nX][6], cStatusProc   ) // 6-Status Processamento
		cSerie 		    := iif( valtype(aDados[nX][7])<>"U" ,  aDados[nX][7], cSerie         ) // 7-Serie
        cNota 		    := iif( valtype(aDados[nX][8])<>"U" ,  aDados[nX][8], cNota         ) // 8-Numero da Nota
        cXml 		    := iif( valtype(aDados[nX][9])<>"U" ,  aDados[nX][9], cXml          ) // 9-Xml
        cDHRecbto		:= iif( valtype(aDados[nX][10])<>"U" ,  aDados[nX][10], cDHRecbto   ) // 10-Hora Recebimento 
		cDtHrRec1	    := iif( valtype(aDados[nX][11])<>"U" ,  aDados[nX][11], cDtHrRec1   ) // 11-Hora Recebimento					 		
		dDtRecib		:= iif( valtype(aDados[nX][12])<>"U",  aDados[nX][12], dDtRecib     ) // 12-Data Recebimento 
		
        dbSelectArea("SF3")
        SF3->(dbSetOrder(5))
		if lAut .or. SF3->(dbSeek(xFilial("SF3")+ cSerie + cNota) ) 
            if ( (SF3->(ColumnPos("F3_CHVNFE") > 0)) .and. (SF3->(ColumnPos("F3_CODRSEF")) > 0) .and.  (SF3->(ColumnPos("F3_PROTOC")) > 0) .and. (SF3->(ColumnPos("F3_DESCRET")) > 0) ) 
                SF3->(reclock("SF3",.F.))
                SF3->F3_PROTOC  := cProtocolo  
                SF3->F3_CODRSEF := cStatusSef  
                SF3->F3_DESCRET := cDescSef  
                SF3->F3_CHVNFE  := SubStr(NfeIdSPED(cXml,"Id"),4)
                SF3->(MsUnLock())
            endif
            if( SFT->(ColumnPos("FT_CHVNFE") > 0) ) 
                SFT->(reclock("SFT",.F.))
                SFT->FT_CHVNFE  := SubStr(NfeIdSPED(cXml,"Id"),4)
                SFT->(MsUnLock())
            endif
        endif                
		
	next nX
	
return

//-----------------------------------------------------------------------------------------------
/*/{Protheus.doc} CTeOSInut
Veriifca a versão CTeOs para não inutilizar

@param	oReq    {{"msg":{"entidade": "","canc":[{"chaveCTe":"","protocolo":"","justificativa":""}]} }
@param	oResp   {"response":{"motivo": "Cancelamento Transmitido com Sucesso","idEvento":[{"id": ""}]}, "error":null}

@return	Retorno character indicando a versão CTeOs configurada na SPEDNFE

@author  Karyna Morato
@since   31/06/2023
@version 12

/*/
//-----------------------------------------------------------------------------------------------
Function CTeOSInut()

Local lPSW         := .F.
Local lAdminNfe    := getNewPar("MV_ADMNFE",.T.)
Local lOk          := .F.        
Local cError       := ""
Local cEntidade    := ""  
Local cVersao      := ""

lPSW := pswAdmin( /*cUser*/, /*cPsw*/, retCodUsr()) == 0 

If( !lAdminNfe .or. lPSW )

    lOk := isConnTSS(@cError)

    If lOk

        cEntidade := getCfgEntidade(@cError)    

        If Empty(cError) 

            cVersao := getCfgVersao(@cError, cEntidade, '67')	

        Endif       

    Endif  
    
EndIf

Return cVersao
