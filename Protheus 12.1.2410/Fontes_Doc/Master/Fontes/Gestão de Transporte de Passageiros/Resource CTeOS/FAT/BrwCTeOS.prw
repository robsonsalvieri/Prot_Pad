#INCLUDE "PROTHEUS.CH"
#INCLUDE "TOTVS.CH"
#INCLUDE "APWIZARD.CH"
#INCLUDE "RPTDEF.CH"
#INCLUDE "FWPrintSetup.ch"
#INCLUDE "SPEDNFE.ch"
#INCLUDE "TOPCONN.CH"
#INCLUDE "TBICONN.CH"
#INCLUDE "FILEIO.CH"
#INCLUDE "FWBROWSE.CH"
#INCLUDE "BRWCTEOS.CH"
//-------------------------------------------------------------------
/*/{Protheus.doc} GZHRemessa
Wizard de transmissão do CTeOS

@param	cAlias  Alias do Browse
@param  cReq    Recno do Alias
@param  nOpc    Opção do Browse

@return	nil

@author  Renato Nagib
@since   22/09/2017
@version 12.1.18

/*/
//-------------------------------------------------------------------
function GZHRemessa(cAlias, nRec, nOpc,cEvento, lAut)

    local cSerie
    local cNota
    local cCliente
    local cLoja
	local cError	   := ""
	Local cEntidade    := ""
	Local cAmbiente    := ""
	local cModelo      := "67"
	Local lOk          := .F.
	local cVersaoTSS   := ""
	Local cModalidade  := ""
	Local cVersaoCTeOS := ""
    local nTempo       := 0
	Local cMsg         := ""
	Local oWizard
    local cRetorno     := ""
    local aCfgVerao    := {}
    local cHorario     := ""
    local cHrVerao     := ""
    local aRetorno     := {"", ""}
    local lAutorizado  := .F.
    local cXmlProt     := ""
    local cXml         := ""
    local cMsgPrint    := ""
    local oFont
    local oSay
    local cBtmStatus  := "qmt_no.png"
    local cLbStatus   := ""
    local cReq        := ""
    local cModal        := ""
    local oReq
    local oResp
    
    Default cEvento := ''
    Default lAut    := .F.
    
    cSerie   := GZH->GZH_SERIE
    cNota    := GZH->GZH_NOTA
    cCliente := GZH->GZH_CLIENT
    cLoja    := GZH->GZH_LOJA
    cModal  := iif(GZH->(FieldPos("GZH_MODAL")) > 0, alltrim(GZH->GZH_MODAL), "01" )

    if(!isConnTSS(@cError) )
        cError := "Falha de comunicação com TSS. Realize a configuração."
        aviso("CTeOS", cError, {STR0004}, 3)
        if !isBlind()
            spedNFeCfg()
        endif
        cError := iif( empty( getWscError(3)), getWscError(1), getWscError(3))
    endif

    lOk := Iif(lAut,lAut,empty(cError))

    if(lOk)
        cEntidade := getCfgEntidade(@cError)
        lOk := Iif(lAut,lAut,empty(cError))
    endif


    if(lOk)
        lOk := Iif(lAut,lAut,isCFGReady(cEntidade, @cError))
    endif

    if(lOk)
        lOk := Iif(lAut,lAut,isValidCert(cEntidade, @cError))
    endif

    if(lOk)
        cAmbiente := getCfgAmbiente(@cError, cEntidade, cModelo)
    endif

    if(empty(cError))
        cModalidade := PADR(getCfgModalidade(@cError, cEntidade, cModelo), 30)
    endif

    if(empty(cError))
        cVersaoCTeOS := getCfgVersao(@cError, cEntidade, '67')
    endif

    if(empty(cError))
        aCfgVerao :=  getCfgEpecCte(@cError)
        If Valtype(aCfgVerao) == "A" .And. Len(aCfgVerao) >= 12 .And. aCfgVerao[11] != nil .And. aCfgVerao[12] != nil
            cHrVerao := substr(aCfgVerao[12], 3)
            cHorario := substr(aCfgVerao[11], 3)
        Endif
    endif

    if(empty(cError))
        nTempo := getCfgEspera(@cError, cEntidade)
    endif

    if(lOk)
	    cVersaoTSS := getVersaoTSS(@cError)
		lOk := Iif(lAut,lAut,empty(cError))
	endif

    //String da Requisição
	cReq := '{ "msg": {'
    cReq += '"entidade":"' + cEntidade + '", '
    cReq += '"ambiente":"' + substr(cAmbiente, 1, 1) +'", '
    cReq += '"modalidade": "' + substr(cModalidade, 1, 1) + '", '
    cReq += '"versao":"' + cVersaoCTeOS + '", '
    cReq += '"modal":"' + cModal + '", '
    cReq += '"documento": { "nota": "'+ alltrim(cNota) + '", "serie":"' + alltrim(cSerie) +'", "cliente":"' + cCliente + '", "loja": "' + cLoja +'" }}}'
    
    if(!fwJsonDeserialize(cReq, @oReq) )
        lOk := .F.
        cError := "Requisição Invalida. " + CRLF + cReq
    endif

    if (!lOk)
		 aviso("CTe OS", cError, {STR0004}, 3)
    else

        cMsg := "Esta rotina tem como objetivo auxiliá-lo na transmissão do CTe de passageiros para o serviço TSS. "
        cMsg += "Neste momento o TSS está operando com o serviço CTeOS com a seguinte configuração:" + CRLF + CRLF
        cMsg += "Ambiente: " + substr(cAmbiente, 3) + CRLF + CRLF
        cMsg += "Modalidade de emissão: " + substr(cModalidade, 3) + CRLF	+ CRLF
        cMsg += "Horário: "  + cHorario + CRLF + CRLF
        cMsg += "Horario de Verão: " + cHrVerao + CRLF	+ CRLF
        cMsg += "Tempo de espera para entrada em Contingência: " + alltrim(str(nTempo)) + CRLF	+ CRLF
        cMsg += "Versão CTe OS: " + cVersaoCTeOS + CRLF + CRLF
        cMsg += "Release TSS: " + cVersaoTSS + CRLF + CRLF

        cMsgPrint := "Imprimir DACTe OS?" + CRLF + CRLF
        cMsgPrint += "A impressão poderá ser feita a qualquer momento através da opcão 'Imprimir DACTE-OS'."

        DEFINE FONT oFont NAME "Arial" SIZE 0, -13 BOLD

    endif

    if(lOk) .And. !lAut

        /*---------------------------------------------------------------------
                                WIZARD DE TRANSMISSAO
        ----------------------------------------------------------------------*/
        oWizard := APWizard():new( STR0003,; // Atenção
            "Certifique-se das configurações antes da trasmissão do documento",;
            "Assitente de Transmissão de CTe OS",;
            cMsg,;
            {|| processa({||CTeOSTransmissao(oReq, @oResp, cEvento)}),;
                            procRetRemessa(oResp, @lAutorizado, @cRetorno, "1", cSerie, cNota, cCliente, cLoja, cEvento),;
                            if(lAutorizado, (cLbStatus := "Documento Autorizado!", oImgStatus:setBmp("qmt_ok.png")),;
                            (cLbStatus := "Documento Não autorizado.", oImgStatus:setBmp("qmt_no.png"))),;
                            oImgStatus:refresh(), .T. })

        @ 010,010 GET cMsg MEMO SIZE 280, 125 READONLY PIXEL OF oWizard:oMPanel[1]

        CREATE PANEL oWizard ;
            HEADER "Finalizada Transmissão para  o TSS";
            MESSAGE "";
            BACK {|| .F. };
            FINISH {|| if(lAutorizado .and. msgYesNo(cMsgPrint, "Impressão do DACTe OS"),;
                         GZHimpressao(Alias(), recno(), 4), .T. ), .T. } ;
            PANEL

        oImgStatus := TBitmap():New(010,010,260,184,,cBtmStatus,.T.,oWizard:oMPanel[2], {||},,.F.,.F.,,,.F.,,.T.,,.F.)
        @012,025 SAY oSay PROMPT cLbStatus OF  oWizard:oMPanel[2] PIXEL FONT oFont SIZE 150, 015
        @032,010 GET cRetorno MEMO SIZE 290, 115 READONLY PIXEL OF oWizard:oMPanel[2]

        ACTIVATE WIZARD oWizard CENTERED

    endif

return nil
//-----------------------------------------------------------------------------------------------
/*/{Protheus.doc} ProcRetRemessa
Processa Retorno da Remessa para atualização da GZH e view do Browser

@param oResp        Retorno da Transmissão do CTeOS
@param lAutorizado  Indica se o CteOS foi autorizado
@param cRetorno     Referencia para retorno da String para apresentação da view da transmissão
@cGZHStatus         status para atualização da GZH

@return	nil

@author  Renato Nagib
@since   30/09/2017
@version 12.1.18

/*/
//------------------------------------------------------------------------------------------------
function ProcRetRemessa(oResp, lAutorizado, cRetorno, cTpRet, cSerie, cNota, cCliente, cLoja, cEvento, lAut)

    local oXml
    local cErro  := ""
    local cAviso := ""
    local cXml   := ""
    local cChaveCte := ""
    local cXmlSig   := ""
    local cXmlProt  := ""
    local cProtocolo := ""
    local cStat := ''
    Default cEvento := ''
    Default lAut    := .F.

    if !lAut
        if(oResp:error <> nil)
            cRetorno := decode64(oResp:error)
        elseif(!empty(oResp:response:cteos) )

            cRetorno := "Id: " + oResp:response:cteos[1]:id + CRLF

            if(!empty(oResp:response:cteos[1]:xmlProt) )

                lAutorizado := .T.
                cXmlSig := decode64(oResp:response:cteos[1]:xml)
                cXmlProt := decode64(oResp:response:cteos[1]:xmlProt)

                //Monta Xml de distribuição do CTeOS
                cXml := retProtCte(cXmlSig, cXmlProt, "3.00")
                oXml := XmlParser(cXmlProt, "_", @cErro, @cAviso)

                if(oXml <> nil)
                    cChaveCTe := oXml:_protCTe:_infProt:_chCTe:text
                    cProtocolo := oXml:_protCTe:_infProt:_nProt:text
                    cRetorno  += "Status: "       + oXml:_protCTe:_infProt:_cStat:text + "-" + oXml:_protCTe:_infProt:_xMotivo:text + CRLF
                    cRetorno  += "Chave do CTe: " + oXml:_protCTe:_infProt:_chCTe:text + CRLF
                    cRetorno  += "Recebimento: "  + oXml:_protCTe:_infProt:_dhRecbto:text + CRLF
                    cRetorno  += "Protocolo: "    + oXml:_protCTe:_infProt:_nProt:text + CRLF
                    cStat := oXml:_protCTe:_infProt:_cStat:text

                endif

            else

                if(oResp:response:cteos[1]:rejeicao <> nil)
                    cRetorno += "Rejeição: " + oResp:response:cteos[1]:rejeicao:codigo + CRLF
                    cRetorno += decode64(oResp:response:cteos[1]:rejeicao:descricao)
                else
                    cRetorno += "Verifique legenda ou Retransmita o Documento"
                endif

            endif

            //Atualizacao da tabela GZH
            G001GetRet(cTpRet, cXml, lAutorizado, cRetorno, cChaveCte,cProtocolo, cSerie, cNota, cCliente, cLoja, cEvento,cStat)

        endif
    endif

return nil
//-----------------------------------------------------------------------------------------------
/*/{Protheus.doc} GZHConsulta
Verifica se a Nota esta autorizada no TSS

@param nil


@return	nil

@author  Renato Nagib
@since   24/09/2017
@version 12.1.18

/*/
//------------------------------------------------------------------------------------------------
function GZHConsulta(cAlias, nReg, nOpc)

    local cError      := ""
    local cEntidade   := getCfgEntidade(@cError)
    local cReq
    local oReq
    local oResp
    local cRetorno    := ""
    local lAutorizado := .F.
    local cTpRet := "2"

    cReq := '{ "msg": { "entidade": "' + cEntidade + '", "cteos": [ {"id":"' + GZH->GZH_SERIE + GZH->GZH_NOTA +'" }]}}'

    if(!fwJsonDeserialize(cReq, @oReq))
        cRetorno := "Falha na requisição:" + CRLF + cReq
    else

        //Retorno do XML do CTeOS e XML PRotocolo
        CTeOSRetorno(oReq, @oResp )

        //Atualiza status da GZH e monta mensagem de Retorno para a Dialog
        procRetRemessa(oResp, @lAutorizado, @cRetorno, "2", GZH->GZH_SERIE, GZH->GZH_NOTA, GZH->GZH_CLIENT, GZH->GZH_LOJA)

   endif

return {lAutorizado, cRetorno}
//-----------------------------------------------------------------------------------------------
/*/{Protheus.doc} GZHCTeOSStatus
Monitoramento e atualização do Status do CTeOS

@param nil

@return	nil

@author  Renato Nagib
@since   24/09/2017
@version 12.1.18

/*/
//------------------------------------------------------------------------------------------------
function GZHCTeOSStatus(lAut, nAut)

    local cError :=  ""
    local cReq := ""
    local lAutorizado := .F.
    local oReq
    //local oResp
    local cRetorno := ""

    private oResp1

    DEFAULT lAut := .F.
    DEFAULT nAut := 0

    cEntidade := getCfgEntidade(@cError)

    cReq := '{ "msg":{'
    cReq += ' "entidade": "' + cEntidade + '"'
    cReq += ', "modelo": "67"'
    cReq += ', "id": "' + alltrim(GZH->GZH_SERIE) + alltrim(GZH->GZH_NOTA) + '"'
    cReq += ', "serie": "'+ GZH->GZH_SERIE + '"'
    cReq += ', "nota": "'+ GZH->GZH_NOTA + '" }}'

    if(!fwJsonDeserialize(cReq, @oReq) )
        cRetorno := "Requisição inválida:" + CRLF + cReq
    endif

   if(oReq <> nil) .OR. lAut

        CTeOSMonitor(oReq, @oResp1)

        if(oResp1:error == nil) .OR. lAut
            If !lAut
                cRetorno := "Id: "           + oResp1:response:id + CRLF
                cRetorno += "Protocolo: "    + oResp1:response:protocolo + CRLF
                cRetorno += "Situação: "     + oResp1:response:situacao + CRLF
                cRetorno += "Status Sefaz: " + oResp1:response:statusSef
                cRetorno += " - "            + oResp1:response:descSef + CRLF
                cRetorno += "Chave Eletrônica: " + oResp1:response:chaveeletronica + CRLF
            Else
                oResp1 := getJsonResponse('{ "id": "001", "protocolo": "000000000000000000000", "situacao": "ok", "statusSef": "100", "descSef": "mensagem", "status": "' +cvaltochar(nAut) + '", "chave eletronica": ""}', '')
            EndIf

            if (lAut .AND. nAut == 2) .OR. (oResp1:response:status == "2")

                if(GZH->GZH_STATUS < "5")
                    GTPTSTATUS("3")
                endif

            elseif (lAut .AND. nAut == 3) .OR. (oResp1:response:status == "3")

                GTPTSTATUS("8")

            elseif (lAut .AND. nAut == 4) .OR. (oResp1:response:status == "4")

                if(GZH->GZH_STATUS < "6")
                    GTPTSTATUS("4")
                else
                    GTPTSTATUS("9")
                endif

            endif

        else
            cRetorno := decode64(oResp1:error)
        endif
    endif

    //----------------------------------------------------
    // Realizo validacao para quando nao estiver retorno
    // no objeto, seja exibido Pendente de Transmissao
    //----------------------------------------------------
    if ( type("oResp1:response:status") == "U" .and. type("oResp1:response:descSef") == "U" )
      	viewCTeOS("1", "", cRetorno)	//Pendente de Transmissao
    else
    	viewCTeOS(oResp1:response:status, oResp1:response:descSef, cRetorno)
    endif

return nil
//-----------------------------------------------------------------------------------------------
/*/{Protheus.doc} GZHExporta
Exportação do Xml de distribuição do CTeOS

@param nil

@return	nil

@author  Renato Nagib
@since   24/09/2017
@version 12.1.18

/*/
//-----------------------------------------------------------------------------------------------
function GZHExporta(cPath,lPos,cMsgRet, lAut)
    
    local cFile := ""
    local cXml  := ""
    local nHdl
    local lSave    := .T.
    local cRetorno := ""
    Local cStatus	:= GZH->GZH_STATUS
    
    Default lAut := .F.

   
	cFile := GZH->GZH_CLIENT  + "-" + alltrim(GZH->GZH_LOJA) + "-" + alltrim(GZH->GZH_SERIE) + "-" + GZH->GZH_NOTA + ".xml"

    cXml := alltrim(GZH->GZH_XMLCTE)

    nHdl := fCreate(AllTrim(cPath + cFile))

     if lAut
        cXml := 'Automação'
    endif

    if(!empty(cPath))

        if(nHdl < 0)
            lSave := .F.
            cRetorno := STR0005 + CRLF + cPath + cFile + CRLF                //"Falha ao Criar arquivo: "
        elseif(empty(cXml))
            lSave := .F.
            cRetorno := STR0006 + CRLF + cXml + CRLF  //"Xml Inválido para Distribuição:"
        else
            if( !fwrite(nHdl, cXml) )
                cRetorno := STR0007 + CRLF + str(FError()) + CRLF  //"Erro de gravação: "
            else
                IF lPos            
                    cRetorno := STR0008       // "Arquivo Salvo com sucesso!"
                EndIf
                fClose(nHdl)
            endif

        endIf
        
        If lPos
            Aviso(STR0009, cRetorno, {STR0004}, 3)        //"CTeOS - Exportação de CTeOS"
        Else
            cMsgRet += cRetorno
        EndIF    


    endif
return nil
//-----------------------------------------------------------------------------------------------
/*/{Protheus.doc} viewCTeOS
Visualização do Resultado da consulta

@param	lAutorizado Indica se o CTeOS está autorizado
@param	cRetorno    String com os dados para apresentação da View

@return	nil

@author  Renato Nagib
@since   24/09/2017
@version 12.1.18

/*/
//------------------------------------------------------------------------------------------------
function viewCTeOS(cStatusProc, cLbStatus, cRetorno)

    local oDlg
    local oImgStatus
    local cImgStatus
    local oLbStatus
    local oBtExit

    Default lAut := .F.

    if(cStatusProc == "1")
        cImgStatus := "qmt_cond.png"
    elseif(cStatusProc $ "2|3")
        cImgStatus := "qmt_ok.png"
    elseif(cStatusProc == "4")
        cImgStatus := "qmt_no.png"
    else
        cImgStatus := "qmt_no.png"
    endif

    cLbStatus := iif(empty(cLbStatus), "Documento não Processado", cLbStatus)

    if !isBlind()
        DEFINE FONT oFont NAME "Arial" SIZE 0, -13 BOLD
        oDlg := TDialog():New(150,150,450,690,'',,,,,,,,,.T.)
        oImgStatus := TBitmap():New(010,010,260,184,,cImgStatus,.T.,oDlg, {||},,.F.,.F.,,,.F.,,.T.,,.F.)
        @012,025 SAY oLbStatus PROMPT cLbStatus OF  oDlg PIXEL FONT oFont SIZE 200, 015
        @032,010 GET cRetorno MEMO SIZE 254, 095 READONLY PIXEL OF oDlg
        oBtExit := TBtnBmp2():New( 265,473,60,25,'s4wb018n.png',,,,{|| oDlg:end() }, oDlg, "Sair", ,.T. )

        ACTIVATE MSDIALOG oDlg
    EndIf

return nil
//-----------------------------------------------------------------------------------------------
/*/{Protheus.doc} CTeOSimpressao
Impressão do CTeOS

@param	cAlias  Alias do Browse
@param	nReg    Recno do Registro
@param	nOpc    Opcao da operção

@return	nil

@author  Renato Nagib
@since   24/09/2017
@version 12.1.18

/*/
//------------------------------------------------------------------------------------------------
Function GZHimpressao(cAlias, nReg, nOpc, lAut)

    local cError      := ""
    local cXml        := ""
    local cXmlCTe     :=  ""
    local cXmlProt    := ""
    local cErro       := ""
    local cAviso      := ""
    local oSetup
    local cFilePrint  := ""
    local lFrentVers  := .F.
    local lAuto       := .F.
    local cPrinter    := ""
    local cPathPDF    := ""
    local cEntidade   := getCfgEntidade(@cError)
    local cIdCteOS    := ""
    local oReq
    local oResp
    local aXmlDacteOS := {}
    private oXml
    Default lAut := .F.

    cFilePrint  := "DACTEOS_" + cEntidade + dtos( MSDate() ) + strTran( time(), ":", "") +".pdf"

    cIdCteOS := GZH->GZH_SERIE + GZH->GZH_NOTA

    //Busca XML da Base do ERP
    cXml := alltrim(GZH->GZH_XMLCTE)

    if(!empty(cXml))

        oXml := XmlParser(cXml, "_", @cErro, @cAviso)

        if( type("oXml:_cteProc:_CTeOS") == "O" )
            cXmlCTe := XMLSaveStr(oXml:_cteProc:_CTeOS,.F.)
        elseif( type("oXml:_cteOSProc:_CTeOS") == "O" )
            cXmlCTe := XMLSaveStr(oXml:_cteOSProc:_CTeOS,.F.)
        endif

        if( type("oXml:_cteProc:_protCTe") == "O")
            cXMLProt := XMLSaveStr(oXml:_cteProc:_protCTe,.F.)
        elseif(type("oXml:_cteOSProc:_protCTe") == "O")
            cXMLProt := XMLSaveStr(oXml:_cteOSProc:_protCTe,.F.)
        endif

        if(valtype(oXml) == "O")
            freeObj(oXml)
            oXml := nil
        endif

    endif


    //Busca XML no TSS caso nao tenha encontrado no ERP
    if(empty(cXmlCTe) .or. empty(cXMLProt))

        cReq := '{ "msg": { "entidade": "' + cEntidade + '", "cteos": [ {"id":"' + alltrim(GZH->GZH_SERIE) + alltrim(GZH->GZH_NOTA) +'" }]}}'

        if(!fwJsonDeserialize(cReq, @oReq))
            aviso("CTeOS - Impressão", "Requisição Inválida" + cReq, {STR0004}, 3)
        else
            if( CTeOSRetorno(oReq, @oResp)) 
                if !lAut
                    if( len(oResp:response:cteos) > 0 )
                        aXmlDacteOS := { {decode64(oResp:response:cteos[1]:xml), decode64(oResp:response:cteos[1]:xmlProt)} }                
                    else
                        aviso("CTeOS - Impressão", "Documento não localizado no TSS.", {STR0004}, 3)    
                    endif
                endif    
            else
                aviso("CTeOS - Impressão", decode64(oResp:error), {STR0004}, 3)
            endif
        endif

    else
        aXmlDacteOS := { {cXmlCTe, cXmlProt} }
    endif

    if(!empty(aXmlDacteOS))

        //Setup de configuração
        oSetup := setupCTOS()

        //Impressao
        if( oSetup:Activate() == PD_OK )
        
            if(oSetup:GetProperty(PD_PRINTTYPE) == IMP_SPOOL)
                cPrinter := oSetup:aOptions[PD_VALUETYPE]
            ElseIf oSetup:GetProperty(PD_PRINTTYPE) == IMP_PDF
                cPathPDF := oSetup:aOptions[PD_VALUETYPE]
            Endif    

            fwWriteProfString( GetPrinterSession(), "LOCAL"      , If(oSetup:GetProperty(PD_DESTINATION)==1 ,"SERVER"    ,"CLIENT"    ), .T. )
	        fwWriteProfString( GetPrinterSession(), "PRINTTYPE"  , If(oSetup:GetProperty(PD_PRINTTYPE)==2   ,"SPOOL"     ,"PDF"       ), .T. )
	        fwWriteProfString( GetPrinterSession(), "ORIENTATION", If(oSetup:GetProperty(PD_ORIENTATION)==1 ,"PORTRAIT"  ,"LANDSCAPE" ), .T. )

            if( existBlock("DacteOS", , .T.) )
                aRetorno  := ExecBlock("DacteOS", .F., .F., {aXmlDacteOS, cPathPDF, cPrinter, lFrentVers, val(oSetup:cQtdCopia),;
                            lAuto, cFilePrint, oSetup:GetProperty(PD_PRINTTYPE), oSetup:GetProperty(PD_DESTINATION)==AMB_SERVER})
            endif

            //Definição do Status do CTeOS
            //G001MStatus("GZH_STATUS", "5")
            GTPTSTATUS("5")

        endif
    endif

return nil
//-----------------------------------------------------------------------------------------------
/*/{Protheus.doc} GZHCancelamento
Impressão do CTeOS

@param	cAlias  Alias do Browse
@param	nReg    Recno do Registro
@param	nOpc    Opcao da operção

@return	nil

@author  Renato Nagib
@since   24/09/2017
@version 12.1.18

/*/
//------------------------------------------------------------------------------------------------
function GZHCancelamento(cAlias, nReg, nOpc) 

    local cError         := ""
    local cEntidade      := getCfgEntidade(@cError)
    local lContinua      := .T.
    local oCTeOS
    local oProtCteOS
    local cChaveCte
    local cProtocolo
    local cTipoEvento    := "110111"
    local oFont
    local oWizard
    local cLbStatus      := ""
    local oImgStatus
    local cJustificativa := ""
    local cBtmStatus     := ""
    local cRetorno       := ""
    local oSay
    local cId

    private oCteOS

    lContinua := !empty(cEntidade)

    if(lContinua)

        cChaveCte := getChaveCteOS()
        cId       := (alltrim(GZH->GZH_SERIE) + alltrim(GZH_NOTA))

        cTexto := "A seguir, Informe a Justificativa para o cancelamento do CTeOS"

        DEFINE FONT oFont NAME "Arial" SIZE 0, -13 BOLD

        oWizard := APWizard():new( "Evento de Cancelamento","Assistente para transmissão",;
                                   "CTeOS - Cancelamento " + CRLF,cTexto,,,,,,.F.)

        oWizard:NewPanel ( "Justificativa do Cancelamento" ,"" , {||.T.} ,;
            {|| processa({|| procCanc(cEntidade, cId, cChaveCTe, cJustificativa, @cLbStatus, @oImgStatus, @cRetorno) }), .T.} , {|| .T.})

        @000,000 GET cJustificativa MEMO SIZE 299, 138 PIXEL OF oWizard:oMPanel[2]

        oWizard:NewPanel ( "Finalizado Processo de Cancelamento" , cRetorno , {|| .T.} , {|| .T.} , {|| .T.})

        oImgStatus := TBitmap():New(010,010,260,184,,cBtmStatus,.T.,oWizard:oMPanel[3], {||},,.F.,.F.,,,.F.,,.T.,,.F.)
        @012,025 SAY oSay PROMPT cLbStatus OF  oWizard:oMPanel[3] PIXEL FONT oFont SIZE 150, 015
        @032,010 GET cRetorno MEMO SIZE 290, 115 READONLY PIXEL OF oWizard:oMPanel[3]

        ACTIVATE WIZARD oWizard CENTERED
    else
        aviso("CTeOS - Cancelamento", cError, {STR0004}, 3)
    endif

return nil
//-----------------------------------------------------------------------------------------------
/*/{Protheus.doc} procCanc
Processa Cancelamento(Transmissão e consulta)

@param	cEntidade       Codigo da Entidade cadastrada no TSS
@param	cChaCTe         Serie do CTeOS
@param	cProtocolo      Protocolo do CTe OS
@param	cJustificativa  Justificativa do cancelamento
@param	cLbStatus          Lable para Status do Processamento
@param	oImgStatus        Imagem para indicação do Status do processamento
@param	cError          Referencia para retorno de erro
@param	cRetorno        Referencia para Retorno

@return	oResp           Objeto com resposta do Processamento

@author  Renato Nagib
@since   22/09/2017
@version 12.1.18

/*/
//------------------------------------------------------------------------------------------------
function procCanc(cEntidade, cID, cChave, cJustificativa, cLbStatus, oImgStatus, cRetorno, lAut, nAut)

    local oReq
    local oResp
    local cReq
    local lValid

    DEFAULT lAut := .F.
    DEFAULT nAut := 0

    lValid := validaJustificativa(cJustificativa)

    if(lValid)

        cReq := '{ "msg": {"entidade": "' + cEntidade +'", "notas": ['
        cReq += '{"id": "' + cID + '", "chave":"' + cChave + '","justificativa": "' + cJustificativa + '"} ] } }'

        if(fwJsonDeserialize(cReq, @oReq) ) .OR. lAut

            CTeOSCancelamento(oReq, @oResp)

            if(oResp:error == nil) .OR. lAut

                cReq := '{ "msg":{'
                cReq += ' "entidade": "' + cEntidade + '"'
                cReq += ', "modelo": "67"'
                cReq += ', "id": "' + cID + '"'
                cReq += ', "serie": "'+ GZH->GZH_SERIE + '"'
                cReq += ', "nota": "'+ GZH->GZH_NOTA + '" }}'

                if(fwJsonDeserialize(cReq, @oReq))  .OR. lAut

                    CTeOSMonitor(oReq, @oResp)

                    if(oResp:error == nil) .OR. lAut
                        If !lAut
                            cRetorno := "Id: "           + oResp:response:id + CRLF
                            cRetorno += "Protocolo: "    + oResp:response:protocolo + CRLF
                            cRetorno += "Situação: "     + oResp:response:situacao + CRLF
                            cRetorno += "Status Sefaz: " + oResp:response:statusSef
                            cRetorno += " - "            + oResp:response:descSef + CRLF
                        Else
                            oResp := getJsonResponse('{ "id": "001", "protocolo": "000000000000000000000", "situacao": "ok", "statusSef": "100", "descSef": "mensagem", "status": "'+cvaltochar(nAut)+'", "chave eletronica": ""}', '')
                        EndIf

                        if (lAut .AND. nAut == 3) .OR. (oResp:response:status == "3")
                            
                            GTPTSTATUS("8")
                            If !lAut
                                oImgStatus:setBmp("qmt_ok.png")
                            EndIf
                        elseif(oResp:response:status $ "1|2")
                            oImgStatus:setBmp("qmt_cond.png")
                            cLbStatus := "Cancelamento não Processado"
                        elseif (lAut .AND. nAut == 4) .OR. (oResp:response:status == "4")
                            If !lAut
                                oImgStatus:setBmp("qmt_no.png")
                            EndIf
                            
                            GTPTSTATUS("9")

                        endif

                        cLbStatus := oResp:response:descSef

                    else
                        cRetorno := decode64(oResp:error)
                        oImgStatus:setBmp("qmt_no.png")
                        cLbStatus := "Falha na Consulta do Cancelamento."
                    endif

                else
                    cRetorno  := "Requisicao inválida:" +CRLF + cReq
                    oImgStatus:setBmp("qmt_no.png")
                    cLbStatus := "Falha na Consulta do Cancelamento."

                endif

            else
                cRetorno := decode64(oResp:error)
                oImgStatus:setBmp("qmt_no.png")
                cLbStatus := "Falha na Transmissão do Cancelamento"

            endif
        else
            oImgStatus:setBmp("qmt_no.png")
            cLbStatus := "Falha na Transmissão do Cancelamento."
            cRetorno := "Requisicao inválida:" +CRLF + cReq
        endif
        If !lAut
            oImgStatus:refresh()
        EndIf
    endif

return lValid
//-----------------------------------------------------------------------------------------------
/*/{Protheus.doc} GZHConsEvento
Função de Menu para Consulta de Eventos

@param	cAlias  Alias do Browse
@param	nReg    Recno do Registro
@param	nOpc    Opcao da operção

@return	nil

@author  Renato Nagib
@since   24/09/2017
@version 12.1.18

/*/
//------------------------------------------------------------------------------------------------
function GZHConsEvento(cAlias, nReg, nOpc)

    local cError   := ""
    local oCTeOS
    local oProtCTeOS
    local cRetorno :=  ""
    local aEventos := {"110110","110111"}
    local nEventos
    local cChaveCTe :=  ""
    local cEntidade := getCfgEntidade(@cError)
    local oCteOS
    local cReq
    local oReq
    local oResp

    If GZH->GZH_STATUS <> '8'
    
	    if(empty(cError))
	
	        if(getCTeOS(@oCTeOS, @oProtCTeOS, @cError))
	
	            if(oProtCteOS <> nil)
	                cChaveCTe := oProtCteOS:_infProt:_chCTe:text
	            elseif(oCteOS <> nil)
	                cChaveCTe := substr(oCTeOS:_infCte:_id:text, 4)
	            endif
	
	            for nEventos := 1 to len(aEventos)
	
	            	  if(!empty(cRetorno) )
	                   cRetorno += CRLF + replicate("*", 105) + CRLF + CRLF
	            	  endif
	
	                cReq := '{"msg": {"entidade": "' + cEntidade + '", "codEvento": "' + aEventos[nEventos] + '", "chaveCTe": "' + cChaveCTe + '"}}'
	
	                if(fwJsonDeserialize(cReq, @oReq))
	
	                    CTeOSConsEvento(oReq, @oResp)
	
	                    if( oResp:error == nil )
	
	                        if( oResp:response:status == 1 )
	                            cRetorno += "Evento: " + aEventos[nEventos] + " - " + getDescEvento(aEventos[nEventos]) + CRLF
	                            cRetorno += "Não Processado" + CRLF
	                            cRetorno += "Chave:" + cChaveCte
	
	                        elseif( oResp:response:status == 2 )
	                            cRetorno += "Evento: " + aEventos[nEventos] + " - " + getDescEvento(aEventos[nEventos]) + CRLF
	                            cRetorno += "Autorizado!" + CRLF
	                            cRetorno += "Protocolo: " + oResp:response:autorizacao:protocolo +CRLF
	                            cRetorno += "Chave:" + cChaveCte
	                            if aEventos[nEventos] == "110111"
	                            	G001MStatus('GZH_STATUS', "8")
	                            endif
	
	                        elseif( oResp:response:status == 3 )
	                            cRetorno += "Evento: " + aEventos[nEventos] + " - " + getDescEvento(aEventos[nEventos]) + CRLF
	                            cRetorno += "Rejeição: " + oResp:response:rejeicao:codigo + CRLF
	                            cRetorno += oResp:response:rejeicao:motivo + CRLF
	                            cRetorno += "Chave:" + cChaveCte
	
	                        endif
	
	                    elseif("003 - Faixa de Chave Invalida" $ decode64(oResp:error) ) //.or. (!empty(cRetorno) .and. ("Documento não possui evento." $ decode64(oResp:error)) ) )
	                        cError := ""
	                    else
	                    		cRetorno += "Evento: " + aEventos[nEventos] + " - " + getDescEvento(aEventos[nEventos]) + CRLF
	                        cRetorno += decode64(oResp:error)
	                    endif
	                endif
	            next
	
	            freeObj(oCteOS)
	            oCteOS := nil
	
	            if(oReq <> nil)
	                freeObj(oReq)
	                oReq := nil
	            endif
	
	        endif
	
	    endif
	
	    cRetorno += cError
	
	    if(empty(cRetorno))
	        cRetorno :=  STR0001 //"Nenhum Evento Emitido para o CTeOS Informado"
	    endif
	
	    aviso("CTeOS - Eventos", cRetorno, {STR0004}, 3)
    Else
    	Alert(STR0002) //'Cancelamento já autorizado.'
    
    endif

return cRetorno
//-----------------------------------------------------------------------------------------------
/*/{Protheus.doc} GZHCCe
Carta de correção do CTeOS

@param	cAlias  Alias do Browse
@param	nReg    Recno do Registro
@param	nOpc    Opcao da operção

@return	nil

@author  Renato Nagib
@since   24/09/2017
@version 12.1.18

/*/
//------------------------------------------------------------------------------------------------
function GZHCCe(cAlias, nReg, nOpc)

    local cError         := ""
    local cEntidade      := getCfgEntidade(@cError)
    local lContinua      := .T.
    local oCTeOS
    local oProtCteOS
    local cChaveCte
    local cProtocolo
    local cTipoEvento    := "110110"
    local oFont
    local oWizard
    local cLbStatus      := ""
    local oImgStatus
    local cCorrecao   := ""
    local cBtmStatus     := ""
    local cRetorno       := ""
    local oSay
    Local aItensAju := {}

    private oCteOS

    if(empty(cEntidade))
        lContinua := .F.
    endif

    cAmbiente :=  left(getCfgAmbiente(@cError), 1)

    if(empty(cAmbiente))
        lContinua := .F.
    endif
    if(lContinua)
        if(getCTeOS(@oCTeOS, @oProtCTeOS, @cError) .and.  oProtCTeOS <> nil )
            cChaveCte  := oProtCTeOS:_infProt:_chCTe:text
            cProtocolo := oProtCTeOS:_infProt:_nProt:text
        else
            lContinua := .F.
        endif
    endif

    if(lContinua)
        FwMsgRun( ,{||GTPA712LOA()},,"Carregando tabela de tags CT-e OS...")
        DEFINE FONT oFont NAME "Arial" SIZE 0, -13 BOLD
        cTexto := 'Informe os dados para correção.' + CRLF
        cTexto += 'As correções deverão ser informadas da seguinte forma:' + CRLF +CRLF
        cTexto += 'Grupo:Campo:Valor;Grupo:Campo:Valor' + CRLF +CRLF 
        cTexto += 'IMPORTANTE:' + CRLF 
        cTexto += 'No conteúdo a ser alterado, não poderá conter o caracter de dois pontos (:) '

        oWizard := APWizard():new( "Evento de Carta de Correção","Assistente para transmissão ","CTeOS - Carta de Correção "+CRLF,cTexto,,,,,,.F.)

        oWizard:NewPanel('Montagem','Atribuições',{||.T.},{|| cCorrecao:=MontaStr(aItensAju),.T. },{||.T.},.T.,{||MontaTAG(oWizard:oMPanel[2],aItensAju)})                           

        oWizard:NewPanel ( "Dados para Correção" ,"" , {||.T.} ,;
            {|| processa({|| procCCe(cEntidade, cAmbiente ,cChaveCte, cProtocolo, cCorrecao, @cLbStatus, @oImgStatus, @cRetorno) }), .T.} , {|| .T.})

        @000,000 GET cCorrecao MEMO SIZE 299, 138 PIXEL OF oWizard:oMPanel[3] //2

        oWizard:NewPanel ( "Finalizado Processo de Carta de Correção" , cRetorno , {|| .T.} , {|| .T.} , {|| .T.})

        oImgStatus := TBitmap():New(010,010,260,184,,cBtmStatus,.T.,oWizard:oMPanel[4], {||},,.F.,.F.,,,.F.,,.T.,,.F.)  //3
        @012,025 SAY oSay PROMPT cLbStatus OF  oWizard:oMPanel[4] PIXEL FONT oFont SIZE 150, 015                        //3
        @032,010 GET cRetorno MEMO SIZE 290, 115 READONLY PIXEL OF oWizard:oMPanel[4]                                   //3

        ACTIVATE WIZARD oWizard CENTERED

        freeObj(oCteOS)
        oCteOS := nil
    else
        aviso("CTeOS - Carta de Correção", cError, {STR0004}, 3)
    endif

 

return cRetorno
//-----------------------------------------------------------------------------------------------
/*/{Protheus.doc} procCCe
Processa correção do CTeOS

@param	cAlias  Alias do Browse
@param	nReg    Recno do Registro
@param	nOpc    Opcao da operção

@return	nil

@author  Renato Nagib
@since   24/09/2017
@version 12.1.18

/*/
//------------------------------------------------------------------------------------------------
function procCCe(cEntidade, cAmbiente, cChaveCte, cProtocolo, cCorrecao, cLbStatus, oImgStatus, cRetorno, lAut)

    local oReq
    local oResp
    local cReq
    local lValid
    local aCorrecao := {}
    local nC
    Default lAut := .F.

    lValid := validaCCeCTeOS(@cCorrecao, @cRetorno)

    if(lValid)
        cReq := '{ "msg": {"entidade": "' + cEntidade +'", "ambiente": "' + cAmbiente +'"'
        cReq += ', "cteos": [ {"chaveCTe": "' + cChaveCTe + '", "protocolo": "' + cProtocolo +  '",'
        cReq += cCorrecao + '}]}}'

        if(fwJsonDeserialize(cReq, @oReq) )

            CTeOSCCe(oReq, @oResp)

            if(oResp:error == nil)

                cReq := '{"msg": {"entidade": "' + cEntidade + '", "codEvento": "110110", "chaveCTe": "' + cChaveCte + '"}}'

                if(fwJsonDeserialize(cReq, @oReq))

                    CTeOSConsEvento(oReq, @oResp)

                    if(oResp:error == nil)
                        if(oResp:response:status == 1)
                            oImgStatus:setBmp("qmt_cond.png")
                            cLbStatus := "Carta de Correção não Processada!"
                            cRetorno += "Acompanhe o Status de Processamento atraves da opção 'Consultar Eventos'"
                        elseif(oResp:response:status == 2)
                            oImgStatus:setBmp("qmt_ok.png")
                            cLbStatus := "Carta de Correção Autorizada!"
                            cRetorno := oResp:response:details + CRLF + "Protocolo: " + oResp:response:autorizacao:protocolo

                        elseif(oResp:response:status == 3)
                            oImgStatus:setBmp("qmt_no.png")
                            cLbStatus := "Carta de Correção Rejeitada"
                            cRetorno := "Rejeição: " + oResp:RESPONSE:rejeicao:codigo
                            cRetorno += oResp:RESPONSE:rejeicao:motivo

                        endif

                    else
                        oImgStatus:setBmp("qmt_cond.png")
                        cLbStatus := "Carta de Correção não Autorizada."
                        cRetorno := decode64(oResp:error)
                    endif

                else
                    oImgStatus:setBmp("qmt_cond.png")
                    cLbStatus := "Carta de Correção não transmitido."
                    cRetorno := "Requisicao inválida:" +CRLF + cReq
                endif

            else
                oImgStatus:setBmp("qmt_cond.png")
                cLbStatus := "Carta de Correção não transmitido"
                cRetorno := decode64(oResp:error)
            endif
        else
            if !lAut
                oImgStatus:setBmp("qmt_no.png")
                cLbStatus := "Carta de Correção não transmitida."
                cRetorno := "Requisicao inválida:" +CRLF + cReq
            endif
        endif

        if !lAut
            oImgStatus:refresh()
        endif
    endif

return lvalid
//-----------------------------------------------------------------------------------------------
/*/{Protheus.doc} getCTeOS
Retorna objeto Xml do CTeOS gravado na tabela GZH

@param	oRetorno    Referencia para retorno do Objeto
@param	cChaveCTe   Referencia para retorno de error na execução

@return	lGet        Indica se o Objeto foi criado

@author  Renato Nagib
@since   30/09/2017
@version 12.1.18

/*/
//-----------------------------------------------------------------------------------------------
static function getCTeOS(oCTeOS, oProtCTeOS, cError)

    local cErro  := ""
    local cAviso := ""
    Local lOk   := .F.
    private oXml

    if(empty(GZH->GZH_XMLCTE))
        cError := "Protocolo não localizado"
    else
        oXml := XmlParser(GZH->GZH_XMLCTE, "_", @cErro, @cAviso)

        if(oXml <> nil)

            if( type("oXml:_cteProc:_protCTe:_infProt") <> "U")
                oProtCTeOS := oXml:_cteProc:_protCTe
                lOk := .T.
            elseif( type("oXml:_cteOsProc:_protCTe:_infProt") <> "U")
                oProtCTeOS := oXml:_cteOsProc:_protCTe
                lOk := .T.
            endif

            if( type("oXml:_cteProc:_CTEOS:_infCte") <> "U")
                oCTeOS := oXml:_cteProc:_CTEOS
                lOk := .T.
            elseif( type("oXml:_cteOsProc:_CTEOS:_infCte") <> "U")
                oCTeOS := oXml:_cteOsProc:_CTEOS
                lOk := .T.
            endif

        else
            cError := cErro + cAviso
        endif
    endif 
return lOk
//-----------------------------------------------------------------------------------------------
/*/{Protheus.doc} setupCTOS
Setup de configuração da Impressão

@param	nil

@return	nil

@author  Renato Nagib
@since   24/09/2017
@version 12.1.18

/*/
//------------------------------------------------------------------------------------------------
static function setupCTOS(lAut)

    local nFlags       := PD_ISTOTVSPRINTER + PD_DISABLEPAPERSIZE + PD_DISABLEPREVIEW + PD_DISABLEMARGIN
    local aDevice      := {"DISCO", "SPOOL", "EMAIL", "EXCEL", "HTML", "PDF"}
    Local cSession     := GetPrinterSession()
    local nLocal       := If(fwGetProfString(cSession,"LOCAL","SERVER",.T.)=="SERVER",1,2 )
    local nOrientation := If(fwGetProfString(cSession,"ORIENTATION","PORTRAIT",.T.)=="PORTRAIT",1,2)
    local cDevice      := If(Empty(fwGetProfString(cSession,"PRINTTYPE","SPOOL",.T.)),"PDF",fwGetProfString(cSession,"PRINTTYPE","SPOOL",.T.))
    local nPrintType   := aScan(aDevice,{|x| x == cDevice })
    Default lAut       := .F.

    if !lAut
        oSetup := FWPrintSetup():New(nFlags, "Setup para impressao DacteOS")

        oSetup:SetPropert(PD_DESTINATION , nLocal)
        oSetup:SetPropert(PD_PRINTTYPE   , nPrintType)
        oSetup:SetPropert(PD_ORIENTATION , nOrientation)
        oSetup:SetPropert(PD_PAPERSIZE   , 2)
        oSetup:SetPropert(PD_MARGIN      , {60,60,60,60})
    else
        return
    endif
return oSetup

//-----------------------------------------------------------------------------------------------
/*/{Protheus.doc} validaJustificativa
Valida Justificativa

@param cJustificativa  texto da Justificativa

@return	lValid          Indica se o texto esta válido

@author  Renato Nagib
@since   30/09/2017
@version 12.1.18

/*/
//------------------------------------------------------------------------------------------------

static function  validaJustificativa(cJustificativa)

    local lValid := .T.
    local cRetorno := ""

    cJustificativa := Alltrim(cJustificativa)
    cJustificativa := StrTran(cJustificativa,Chr(10),"")
    cJustificativa := StrTran(cJustificativa,Chr(13),"")
    cJustificativa := StrTran(cJustificativa,Chr(135),"&Amp;")
    cJustificativa := StrTran(cJustificativa,Chr(198),"&atilde;")

    if( Len(cJustificativa) < 15 )
        lValid := .F.
        cJustificativa := "A Correção deve ter o mínimo de 15 caracteres"
    elseif(len(cJustificativa) > 255)
        cJustificativa := "A Correção deve ter o máximo de 255 caracteres"
        lValid := .F.
    endif

    if(!lValid)
        aviso("CTeOS - Cancelamento", cJustificativa, {STR0004}, 3) //ok
    endif
return lValid
//-----------------------------------------------------------------------------------------------
/*/{Protheus.doc} validaCCeCTeOS
Valida e monta Mensagem da correção

@param cCorreção    Referencia com String com os dados para a correção

@return	nil

@author  Renato Nagib
@since   30/09/2017
@version 12.1.18

/*/
//------------------------------------------------------------------------------------------------
static function validaCCeCTeOS(cCorrecao, cRetorno)

	local lValid := .T.
	local nC
	local cJustificativa := ""
	
	private aValor
	
	cCorrecao := Alltrim(cCorrecao)
	cCorrecao := StrTran(cCorrecao,Chr(10),"")
	cCorrecao := StrTran(cCorrecao,Chr(13),"")
	cCorrecao := StrTran(cCorrecao,Chr(135),"&Amp;")
	cCorrecao := StrTran(cCorrecao,Chr(198),"&atilde;")

    aCorrecao := Strtokarr2( cCorrecao, ";", .F.)

    if(!empty(aCorrecao))

        cCorrecao := '"correcoes": ['

        for nC :=  1 to len(aCorrecao)

			aValor := Strtokarr2(aCorrecao[nC], ":", .T.)
			
			aRet := validDados( aValor )
	
			//----------------------------------
			// Processo executado com sucesso
			//----------------------------------
            
			if aRet[1]
				
				//cCorrecao := '"correcoes": ['
				if Len(aValor) >= 3
				    if(nC > 1)
				        cCorrecao += ','
				    endif
				
				    cCorrecao += '{"grupo":"' + aValor[1] +'", "campo": "' + aValor[2] + '", "valor": "' + aValor[3] + '"}'
				
			    endif
			   // cCorrecao += ']'
			//----------------------------------
			// Processo falhou
			//----------------------------------    
			else
				if Len(aRet) >= 2 
					if( len(aRet[2]) > 0 )
						lValid		:= aRet[1]
						cCorrecao := aRet[2]
					endif
				endif
			endif
        next
        
        cCorrecao += ']'  
         
        if(empty(cCorrecao))
            lValid := .F.
            cCorrecao := "Estrutura invalida" + cCorrecao
        endif
    else
        cCorrecao := "Estrutura invalida" + cCorrecao
    endif

	if(!lValid)
	    aviso("CTeOS - Carta de Correção", cCorrecao, {STR0004}, 3)
	endif
    
return lValid
//-----------------------------------------------------------------------------------------------
/*/{Protheus.doc} getDescEvento
Retorna a Descrição do Evento de acordo com o codigo

@param cTipoEvento     COdigo do Evento

@return	cRet        UTC

@author  Renato Nagib
@since   24/09/2017
@version 12.1.18

/*/
//------------------------------------------------------------------------------------------------
static function getDescEvento(cTipoEvento)

    local cEvento := ""

    do case
        case cTipoEvento == "110110"
            cEvento := "Carta de Correção"
        case cTipoEvento == "110111"
            cEvento := "Cancelamento"
    endcase

return cEvento
//-----------------------------------------------------------------------------------------------
/*/{Protheus.doc} getChaveCteOS
Retorna Cahave para o documetno

@param cAutorizado  Indica se o CTe foi autorizado
@param cRetorno     String com Retorno da Transmissão
@param cXmlProt     XML Prot de Distribuição do CTe

@return	nil

@author  Renato Nagib
@since   30/09/2017
@version 12.1.18

/*/
//------------------------------------------------------------------------------------------------
function getChaveCteOS()

    local cChaCTe := ""
    local oCteOS
    local oProtCTeOS
    local cError := ""

    if(!getCTeOS(@oCTeOS, @oProtCTeOS, @cError))

        cChaCTe += getUFCode(SM0->M0_ESTCOB)
        cChaCTe += substr(dtos(date()), 3, 2)
        cChaCTe += substr(dtos(date()), 5, 2)
        cChaCTe += SM0->M0_CGC
        cChaCTe += "67"
        cChaCTe += strZero(val(GZH->GZH_SERIE), 3)
        cChaCTe += strZero(val(GZH->GZH_NOTA), 9)
        cChaCTe += "1"
        cChaCTe += strZero(val(GZH->GZH_NOTA), 8)
        cChaveCTe := cChaCTe + modulo11(cChaCTe)

    else
        cChaveCte  := oProtCTeOS:_infProt:_chCTe:text

    endif

return cChaveCTe


Static Function GetUFCode(cUF,lForceUF)

Local nX         := 0
Local cRetorno   := ""
Local aUF        := {}
DEFAULT lForceUF := .F.

aadd(aUF,{"RO","11"})
aadd(aUF,{"AC","12"})
aadd(aUF,{"AM","13"})
aadd(aUF,{"RR","14"})
aadd(aUF,{"PA","15"})
aadd(aUF,{"AP","16"})
aadd(aUF,{"TO","17"})
aadd(aUF,{"MA","21"})
aadd(aUF,{"PI","22"})
aadd(aUF,{"CE","23"})
aadd(aUF,{"RN","24"})
aadd(aUF,{"PB","25"})
aadd(aUF,{"PE","26"})
aadd(aUF,{"AL","27"})
aadd(aUF,{"SE","28"})
aadd(aUF,{"BA","29"})
aadd(aUF,{"MG","31"})
aadd(aUF,{"ES","32"})
aadd(aUF,{"RJ","33"})
aadd(aUF,{"SP","35"})
aadd(aUF,{"PR","41"})
aadd(aUF,{"SC","42"})
aadd(aUF,{"RS","43"})
aadd(aUF,{"MS","50"})
aadd(aUF,{"MT","51"})
aadd(aUF,{"GO","52"})
aadd(aUF,{"DF","53"})

If !Empty(cUF)
	nX := aScan(aUF,{|x| x[1] == cUF})
	If nX == 0
		nX := aScan(aUF,{|x| x[2] == cUF})
		If nX <> 0
			cRetorno := aUF[nX][1]
		EndIf
	Else
		cRetorno := aUF[nX][IIF(!lForceUF,2,1)]
	EndIf
Else
	cRetorno := aUF
EndIf
Return(cRetorno)
//-----------------------------------------------------------------------------------------------
/*/{Protheus.doc} getDescEvento
Retorna a Descrição do Evento de acordo com o codigo

@param cAutorizado  Indica se o CTe foi autorizado
@param cRetorno     String com Retorno da Transmissão
@param cXmlProt     XML Prot de Distribuição do CTe

@return	nil

@author  Renato Nagib
@since   30/09/2017
@version 12.1.18

/*/
//------------------------------------------------------------------------------------------------
/*
user function TXMLViewer(lAutorizado, cRetorno, cXmlProt)

    local oDlg
    local ofileXML
    local cTempPath := getTempPath(.T.)
    local cFile     :=  cTempPath + 'teste.xml'
    local cXml      := ""
    local oBtn
    local cLbStatus := "CTeOS Autorizado!"
    local oDlg
    local cImgStatus   := "qmt_ok.png"

    default cXmlProt:= ''
   default lAutorizado := .T.
   default cRetorno := ""

    cXmlProt :=  '<protCTe xmlns="http://www.portalfiscal.inf.br/cte" versao="3.00">'
    cXmlProt +=  '<infProt Id="CTe143170000716017">'
    cXmlProt +=  '<tpAmb>2</tpAmb>'
    cXmlProt +=  '<verAplic>RS20170829094659</verAplic>'
    cXmlProt +=  '<chCTe>43171053113791000122673670000000431000000439</chCTe>'
    cXmlProt +=  '<dhRecbto>2017-10-06T00:06:23-03:00</dhRecbto>'
    cXmlProt +=  '<nProt>143170000716017</nProt>'
    cXmlProt +=  '<digVal>9RtN3dyV06KYsTdKvzoJmT50MZU=</digVal>'
    cXmlProt +=  '<cStat>100</cStat>'
    cXmlProt +=  '<xMotivo>Autorizado o uso do CT-e</xMotivo>'
    cXmlProt +=  '</infProt>'
  cXmlProt +=  '</protCTe> '

    oDlg := TDialog():New(150,150,450,690,'',,,,,,,,,.T.)

    if(lAutorizado)

        ofileXML := FCREATE(cFile)

        if( ofileXML > 0 )

            fwrite(ofileXML, cXmlProt)
            fClose(ofileXML)

            oXml := TXMLViewer():New(30, 10, oDlg , cFile, 250, 090, .T. )

            oXml:setXML(cFile)
            oxml:blclicked := {|| alert("beleza"), .T.}
            oxml:bldblclick := {|| alert("beleza"), .T.}
            oxml:brclicked := {|| alert("beleza"), .T.}
        else
            @ 030,010 GET cXmlProt MEMO SIZE 255, 090 READONLY PIXEL OF oDlg
        endif

        oBtn := TBtnBmp2():New( 250,415,26,26,'PMSPRINT',,,,{|| CTeOSimpressao() },oDlg,"Imprimir CTeOS",,.T. )
       // @ 136,195 SAY "DacteOS" SIZE 255,010 PIXEL OF oDlg

    else
        cLbStatus := "CTeOS Rejeitado."
        cImgStatus := "qmt_no"
        @ 030,010 GET cRetorno MEMO SIZE 252, 090 READONLY PIXEL OF oDlg
    endif


    oBtn := TBtnBmp2():New( 010,260,400,50,'FWHC_TOTVS',,,,{|| oDlg:end() },oDlg,,,.T. )
    oBtn := TBtnBmp2():New( 250,490,30,30,'cancel',,,,{|| oDlg:end() },oDlg,"Sair",,.T. )
    @ 013,030 SAY cLbStatus SIZE 270,010 PIXEL OF oDlg
    //@ 136,246 SAY "Sair" SIZE 255,010 PIXEL OF oDlg

    oDlg:Activate()

return
*/

//-------------------------------------------------------------------
/*/{Protheus.doc} validDados
Funcao responsavel por validar os dados recebidos.

@param 	aValid
		[1]cGrupo			Grupo do Xml
		[2]cTag			Tag a ser alterada
		[3]cConteudo		Conteudo a ser alterado

@return	lValid			Retorna processo executado com sucesso.
		cDescricao		Descricao do resultado.

@author  Douglas Parreja
@since   20/08/2018
@version 12
/*/
//-------------------------------------------------------------------
static function validDados( aValid )

	local aRet		:= {}
	default aValid 	:= {}
	private aDados 	:= aValid
	
	if( type("aDados[1]") <> "U" .and. type("aDados[2]") <> "U" .and. type("aDados[3]") <> "U" )
		aRet := validLen( aDados[1], aDados[2], aDados[3] )
	else
		aRet := { .F., "Estrutura invalida" }
	endif				

return aRet

//-------------------------------------------------------------------
/*/{Protheus.doc} validLen
Funcao responsavel por validar o tamanho do conteudo.

@param 	cGrupo		Grupo do Xml
		cTag			Tag a ser alterada
		cConteudo		Conteudo a ser alterado
        
@author  Douglas Parreja
@since   20/08/2018
@version 12
/*/
//-------------------------------------------------------------------
static function validLen( cGrupo, cTag, cConteudo )
	
	local lValid		:= .T.
	local cRet		:= ""
	
	default cGrupo	:= ""
	default cTag		:= ""
	default cConteudo	:= ""
			
	if ( !(empty(cGrupo)) .and. !(empty(cTag)) .and. !(empty(cConteudo)) )
		//---------------------------------------
		// Grupo IDE
		//---------------------------------------
		if alltrim(upper(cGrupo)) == "IDE"
			//---------------------------------------
			// Tag somente com 1 conteudo
			//---------------------------------------
			if( upper(cTag) $ "TPIMP|TPEMIS|CDV|TPAMB|TPCTE|PROCEMI|TPSERV|INDIETOMA" )
				if len(alltrim(cConteudo)) <> 1
					lValid 	:= .F.									
					cRet 	:= "A correção para a tag " + alltrim(cTag) + " deve ter o máximo de 1 caracter."
				endif
			endif
		//---------------------------------------
		// Grupo COMPLEMENTOS
		//---------------------------------------
		elseif alltrim(upper(cGrupo)) == "COMPL"
			if( len(alltrim(cConteudo)) < 15 ) 
				lValid	:= .F.
				cRet		:= "A Correção para a tag " + alltrim(cTag) + " deve ter o mínimo de 15 caracteres."
			elseif( len(alltrim(cConteudo)) > 255)
			    lValid 	:= .F.
			    cRet		:= "A Correção para a tag " + alltrim(cTag) + " deve ter o máximo de 255 caracteres."
			endif
		//---------------------------------------
		// Grupo EMITENTE
		//---------------------------------------
		elseif alltrim(upper(cGrupo)) == "EMIT"
			//---------------------------------------
			// Tag no minimo 1 conteudo
			//---------------------------------------
			if upper(cTag) $ "NRO"
				if len(alltrim(cConteudo)) == 0
					lValid := .F.									
					cRet := "A correção para a tag " + alltrim(cTag) + "  deve ter o mínimo de 1 caracter."
				endif
			endif
		//---------------------------------------
		// Grupo TOMADOR
		//---------------------------------------
		elseif alltrim(upper(cGrupo)) == "TOMA"
			//---------------------------------------
			// Tag no minimo 1 conteudo
			//---------------------------------------
			if upper(cTag) $ "NRO"
				if len(alltrim(cConteudo)) == 0
					lValid := .F.									
					cRet := "A correção deve ter o mínimo de 1 caracter"
				endif
			endif
		//---------------------------------------
		// Grupo IMPOSTOS
		//---------------------------------------
		elseif alltrim(upper(cGrupo)) == "IMP"
			//---------------------------------------
			// Valores nao podem serem alterados
			//---------------------------------------
			lValid := .F.									
			cRet := "A correção para a tag " + alltrim(cTag) + " não pode ser realizada, devido que é preciso informar o nível abaixo do grupo de Imposto."
		endif
	endif
								
return { lValid, cRet }


//-------------------------------------------------------------------
/*/{Protheus.doc} MontaTAG
Funcao responsavel por .

@param 	cGrupo		Grupo do Xml
		cTag			Tag a ser alterada
		cConteudo		Conteudo a ser alterado
        
@author  GTP
@since   27/05/2019
@version 12
/*/
//-------------------------------------------------------------------
Static Function MontaTAG(oPanel,aItensAju)
Local aTagCpo := GrpCpo() 
Local aItens1 := iif(!IsBlind(),TagGrpCTE(@aTagCpo),{})
Local cGrupo  := iif(!IsBlind(),aItens1[1],'')
Local aItens2 := iif(!IsBlind(),TagGrpCPO(aTagCpo,cGrupo),{})
Local cCampo  := iif(!IsBlind(),aItens2[1],'')
Local oCboGrupo := Nil
Local oCboCampo := Nil
Local oTGetSeq := Nil
Local oSayDesc := Nil
Local cSeq := "1"
Local oGetSeq := Nil
Local oGetText := Nil
Local cTexto := SPACE(250)
Local oButInsere := Nil
Local oButExclui := Nil
Local oGrid := Nil

if !isBlind()
    oPanelGrid:= tPanel():New(045,005,,oPanel,,,,,,270,085)


   TSay():New(005,000,{||'Grupo'},oPanel,,,,,,.T.)

   oCboGrupo := TComboBox():New(000,020,{|u|if(PCount()>0,cGrupo:=u,cGrupo)},;
             aItens1,100,20,oPanel,,{|| oCboCampo:aItems:=TagGrpCPO(aTagCpo,cGrupo)  };
            ,,,,.T.,,,,,,,,,'cGrupo')

    TSay():New(005,130,{||'Campo'},oPanel,,,,,,.T.)
    
    oCboCampo := TComboBox():New(000,150,{|u|if(PCount()>0,cCampo:=u,cCampo)},;
             aItens2,100,20,oPanel,,{||oSayDesc:SetText( TagDescri(aTagCpo,cGrupo,cCampo) )  };
            ,,,,.T.,,,,,,,,,'cCampo')
    
    
    //oGetSeq := TGet():New( 000,255, { | u | If( PCount() == 0, cSeq, cSeq := u ) },oPanel,020,012, "!@",, 0, 16777215,,.F.,,.T.,,.F.,,.F.,.F.,,.F.,.F. ,,"cSeq",,,,  )


    oSayDesc := TSay():New(020,020,{||TagDescri(aTagCpo,cGrupo,cCampo)},oPanel,,,,,,.T.)       

    oGetText := TGet():New( 030,020, { | u | If( PCount() == 0, cTexto, cTexto := u ) },oPanel,230,010, "!@",, 0, 16777215,,.F.,,.T.,,.F.,,.F.,.F.,,.F.,.F. ,,"cTexto",,,,  )

    oButInsere := TButton():Create( oPanel,030,255,"Adiciona",{||  SetaGrid(oGrid,aItensAju,cGrupo, cCampo,'1',cTexto)  }, 30,12,,,,.T.,,,,,,)

    oButExclui := TBtnBmp2():New( 120,560,26,26,'EXCLUIR',,,,{||  ExcluiItem(oGrid,aItensAju)  },oPanel,,,.T. )


    DEFINE FWBROWSE oGrid DATA ARRAY ARRAY aItensAju NO CONFIG  NO REPORT NO LOCATE OF oPanelGrid
        ADD COLUMN oColumn DATA { || aItensAju[oGrid:At(),1] } TITLE "Grupo" SIZE 070  OF oGrid
        ADD COLUMN oColumn DATA { || aItensAju[oGrid:At(),2] } TITLE "Campo" SIZE 070 OF oGrid
    // ADD COLUMN oColumn DATA { || aItensAju[oGrid:At(),3] } TITLE "Seq" SIZE 020  OF oGrid
        ADD COLUMN oColumn DATA { || aItensAju[oGrid:At(),3] } TITLE "Texto" SIZE 250  OF oGrid
        oGrid:ACOLUMNS[1]:NALIGN := 1 //Alinhamento 
        oGrid:ACOLUMNS[2]:NALIGN := 1 //Alinhamento 
        oGrid:ACOLUMNS[3]:NALIGN := 1 //Alinhamento  
        oGrid:SetLineHeight(25) //Altura de cada linha
    ACTIVATE FWBROWSE oGrid
EndIf

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} GrpCpo
Funcao responsavel por .

@param 	cGrupo		Grupo do Xml
		cTag			Tag a ser alterada
		cConteudo		Conteudo a ser alterado
        
@author  GTP
@since   27/05/2019
@version 12
/*/
//-------------------------------------------------------------------
Static Function GrpCpo()
Local aTagCPO := {}

dbSelectArea('G53')
G53->(DbSetOrder(1))
G53->(DbGoTop())

While G53->(!Eof())
    AADD(aTagCPO,{G53->G53_GRUPO,G53->G53_CAMPO,G53->G53_DESCCP})
    G53->(dbSkip())
END

Return aTagCPO

//-------------------------------------------------------------------
/*/{Protheus.doc} TagGrpCTE
Funcao responsavel por .

@param 	cGrupo		Grupo do Xml
		cTag			Tag a ser alterada
		cConteudo		Conteudo a ser alterado
        
@author  GTP
@since   27/05/2019
@version 12
/*/
//-------------------------------------------------------------------
Static Function TagGrpCTE(aTagCpo)
Local aGrupo := {}
Local cGrupo := ''
Local nX := 0

For nX := 1 to Len(aTagCpo)
    If cGrupo <> AllTrim(aTagCpo[nX][1])
        AADD(aGrupo, AllTrim( aTagCpo[nX][1] ) )
        cGrupo := AllTrim( aTagCpo[nX][1] )       
    EndIf
Next nX

Return aGrupo

//-------------------------------------------------------------------
/*/{Protheus.doc} TagGrpCPO
Funcao responsavel por .

@param 	cGrupo		Grupo do Xml
		cTag			Tag a ser alterada
		cConteudo		Conteudo a ser alterado
        
@author  GTP
@since   27/05/2019
@version 12
/*/
//-------------------------------------------------------------------
Static Function TagGrpCPO(aTagCpo,cGrupo)
Local aCampos := {}
Local nX := 0

For nX := 1 to Len(aTagCpo)
    If cGrupo == AllTrim(aTagCpo[nX][1])
        AADD(aCampos, AllTrim( aTagCpo[nX][2] ))             
    EndIf
Next nX

Return aCampos

//-------------------------------------------------------------------
/*/{Protheus.doc} TagDescri
Funcao responsavel por .

@param 	cGrupo		Grupo do Xml
		cTag			Tag a ser alterada
		cConteudo		Conteudo a ser alterado
        
@author  GTP
@since   27/05/2019
@version 12
/*/
//-------------------------------------------------------------------
Static Function TagDescri(aTagCpo,cGrupo,cCampo)
Local cDescricao := ''
Local nX := 0

For nX := 1 to Len(aTagCpo)
    If cGrupo == AllTrim(aTagCpo[nX][1]) .AND. cCampo == AllTrim(aTagCpo[nX][2]) 
        cDescricao := AllTrim(aTagCpo[nX][3] )       
    EndIf
Next nX

Return cDescricao

//-------------------------------------------------------------------
/*/{Protheus.doc} SetaGrid
Funcao responsavel por .

@param 	cGrupo		Grupo do Xml
		cTag			Tag a ser alterada
		cConteudo		Conteudo a ser alterado
        
@author  GTP
@since   27/05/2019
@version 12
/*/
//-------------------------------------------------------------------
Static Function SetaGrid(oGrid,aItensAju,cGrupo, cCampo,cSeq,cTexto) 
Local nX := 0

If Len(aItensAju) < 19
    If aScan( aItensAju,{|x| x[1] == AllTrim(cGrupo) .AND. x[2] == AllTrim(cCampo) /*.AND. x[3] == AllTrim(cSeq)*/ }) == 0

        AADD( aItensAju ,{ cGrupo, cCampo/*,cSeq*/,Alltrim(cTexto) } )
        oGrid:SetArray(aItensAju)
        oGrid:Refresh()     

    EndIf
Else
    Alert('A limitaç?o de itens a serem corrigidos é de 20 itens')
EndIf        

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} ExcluiItem
Funcao responsavel por .

@param 	cGrupo		Grupo do Xml
		cTag			Tag a ser alterada
		cConteudo		Conteudo a ser alterado
        
@author  GTP
@since   27/05/2019
@version 12
/*/
//-------------------------------------------------------------------
Static Function ExcluiItem(oGrid,aItensAju) 
Local nX := oGrid:nAt

IF !Empty(aItensAju)
    ADel(  aItensAju, nX )
    ASize( aItensAju, Len(aItensAju)-1 )
    oGrid:SetArray(aItensAju)
    oGrid:Refresh()    
EndIf

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} MontaStr
Funcao responsavel por .

@param 	cGrupo		Grupo do Xml
		cTag			Tag a ser alterada
		cConteudo		Conteudo a ser alterado
        
@author  GTP
@since   27/05/2019
@version 12
/*/
//-------------------------------------------------------------------
Static Function MontaStr(aItensAju) 
Local nX := 0
Local Strtag := ''

For nX := 1 To Len(aItensAju)
    Strtag += aItensAju[nX][1]+':'+aItensAju[nX][2]+':'+aItensAju[nX][3]+';'
Next nX

Return Strtag
