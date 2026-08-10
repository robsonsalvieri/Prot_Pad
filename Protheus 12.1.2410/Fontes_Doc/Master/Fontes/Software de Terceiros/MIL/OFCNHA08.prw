#include "TOTVS.CH"
#include "OFCNHA07.ch"

class OFCNHA08
    method new() constructor
    method getfiles()
    method sendfiles()
endClass

method new() class OFCNHA08
return self


/*/{Protheus.doc} getFiles
Rotina que realiza o download dos arquivos da CNH
@type function
@author Cristiam Rossi
@since 12/02/2025
/*/
method getFiles() class OFCNHA08
local   oWsDir      := OFCNHPrimWsDir():new()
local   oFile       := OFCNHPrimWsFile():New()
local   cPastaIN
local   nI
local   nFiles
local   cArquivo
local   lOk
local   cMsg
Local   cLib As Char
Local   nRemote     := GetRemoteType(@cLib) As Numeric

private oConfig     := OFCNHPrimConfig():New()
Private oCfgAtu     := oConfig:GetConfig()
private cMsgLog     := ""
private lDebug      := alltrim(oConfig:oConfig["LOGS"]) == "1"

    cDealerCode := alltrim( oConfig:cDealerCode )
    cPastaIN    := lower( "/CNH/" + cDealerCode + alltrim( oCfgAtu['DIR_IN'] ) )

    if lDebug
		cMsgLog += "--------------------" + CRLF
		cMsgLog += "    "+STR0011 + CRLF       //#Dados
		cMsgLog += "--------------------" + CRLF
        cMsgLog += STR0012 + cDealerCode + CRLF     //#"Dealer code: "
        cMsgLog += STR0013 + cPastaIN + CRLF + CRLF       //#"Pasta entrada: "
    endif

    if ! oWsDir:login()
        cMsg := STR0014    //#"Falha login na API"
        IF nRemote == -1
            QOUT(cMsg + STR0015)
        ELSEIF (nRemote == 1 .OR. nRemote == 2)
            msgStop( cMsg, STR0015)    // #"Download Files"
        EndIF
    else
        if oWsDir:Dir()
            if lDebug
                cMsgLog += STR0019 + cValToChar( len(oWsDir:aFiles) ) + CRLF      //#"Arquivos a serem baixados: "
            endif

            cMsg := cValToChar( len(oWsDir:aFiles) ) + STR0020 + CRLF        //#" arquivo(s) a ser(em) baixado(s)"
            for nI := 1 to len( oWsDir:aFiles )

                cMsg += "#" + cValToChar(nI) + " " + oWsDir:aFiles[nI]:cFileName + " "
                oFile:cFileId       := oWsDir:aFiles[nI]:cFileId
                oFile:cCompress     := oWsDir:aFiles[nI]:cCompress
                oFile:cSize         := oWsDir:aFiles[nI]:cSize
                oFile:cFullFilePath := cPastaIN

	            lOk := ! empty( cArquivo := oWsDir:Download(oFile) )
                if ! empty( cArquivo )
                    nFiles ++
                    cMsg += STR0021       //#" baixado e "
                	lOk := oWsDir:Commit(oFile)
                    cMsg := iif( ! lOK, STR0022, STR0023 ) + CRLF      //#" não Commitado da CNH"        #" commitado com sucesso"
                endif
            next
        endif
    endif

	oWsDir:Logout()

	cAgroup := "PRIM"
	cTipo   := STR0016     // #"DOWNLOAD FILES"
	cDados  := cMsgLog + STR0017 + CRLF + cMsg      //#"Retorno:"
	OA060004C_log( cAgroup, cTipo, cDados )
return nFiles


/*/{Protheus.doc} sendFiles
Envia arquivos pendentes
@type function
@author Cristiam Rossi
@since 13/02/2025
/*/
method sendFiles() class OFCNHA08
local   oWsDir      := OFCNHPrimWsDir():new()
local   cPastaOUT
local   aArqs       := {}
local   cFullPath
local   cFileName
local   nI
local   nSent       := 0
local   cMsg
local   cDealerCode := ""
Local   cLib As Char
Local   nRemote     := GetRemoteType(@cLib) As Numeric

private oConfig     := OFCNHPrimConfig():New()
Private oCfgAtu     := oConfig:GetConfig()
private cMsgLog     := ""
private lDebug      := alltrim(oConfig:oConfig["LOGS"]) == "1"

    cDealerCode := alltrim( oConfig:cDealerCode )
    cPastaOUT   := lower( "/CNH/" + cDealerCode + alltrim( oCfgAtu['DIR_OUT'] ) )

	aArqs := Directory( cPastaOUT + "*.dat",,nil, .T.)
    makeDir( cPastaOUT + "enviados" )

    cFullPath := lower( GetSrvProfString("Rootpath","") ) + strTran( cPastaOUT, "/", "\" )

    if lDebug
		cMsgLog += "--------------------" + CRLF
		cMsgLog += "    "+STR0011 + CRLF       //#Dados
		cMsgLog += "--------------------" + CRLF
        cMsgLog += STR0012 + cDealerCode + CRLF     //#"Dealer code: "
        cMsgLog += STR0025 + cPastaOUT + CRLF       //#"Pasta saída: "
        cMsgLog += STR0026 + cFullPath + CRLF       //#"Caminho completo: "
        cMsgLog += STR0027 + cValToChar(len(aArqs)) + CRLF + CRLF      //#"Nº arquivos a serem enviados: "
    endif

	if len(aArqs)  == 0
        cMsg := STR0028      //#"Não há arquivos a serem enviados"
        IF nRemote == -1
            QOUT(cMsg + STR0029)
        ELSEIF (nRemote == 1 .OR. nRemote == 2)
            msgInfo( cMsg, STR0029 )       //#"Upload arquivos p/ CNH"
        EndIF

        if lDebug
            cMsg := cMsgLog + cMsg
        endif
	else

		for nI := 1 to len( aArqs )
            cFileName := lower( aArqs[nI][1] )

            if lDebug
                cMsgLog += "          #" + cValToChar(nI) + "-" + cFileName + CRLF
            endif

			if oWsDir:Upload( cPastaOUT , cFileName )
                nSent++
                __CopyFile( cFullPath + cFileName, cFullPath + "enviados\" + cFileName,,,.F.)
                fErase( cFullPath + cFileName )

                if lDebug
                    cMsgLog += "          " +STR0030 + CRLF + CRLF       //#"arquivo enviado!"
                endif
			endif
		next
        cMsg := iif( nSent == 0, STR0031+CRLF+oWsDir:cError, STR0032 +cValToChar(nSent)+STR0033 )     //#"Ocorreu erro no envio:"      #"Foi(ram) enviado(s) "     #" arquivo(s)"
        IF nRemote == -1
            QOUT(cMsg + STR0029)
         ELSEIF (nRemote == 1 .OR. nRemote == 2)
            msgInfo( cMsg, STR0029 )   //#"Upload arquivos p/ CNH"
        EndIF
	endif

	oWsDir:Logout()

    if lDebug
        cMsg := cMsgLog + cMsg + CRLF
    endif

	cAgroup := "PRIM"
	cTipo   := STR0034       //#"UPLOAD FILES"
	cDados  := cMsg
	OA060004C_log( cAgroup, cTipo, cDados )

    oWsDir := nil
return nil
