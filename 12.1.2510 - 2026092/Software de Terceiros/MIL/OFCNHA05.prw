#INCLUDE 'TOTVS.CH'
#INCLUDE 'OFCNHA05.CH'
#include 'fileio.ch'

#DEFINE PATHCNH '/CNH/'

static cPrimDir := ""

/*/{Protheus.doc} OFCNHA05
Obter arquivos para processmento
@type function
@version 1.0  
@author Rodrigo
@since 14/06/2025
/*/
Function OFCNHA05( lSendReceive )
    Local aArea     := FWGetArea() As Array
    Local aAreaVBE  := VBE->(FWGetArea()) As Array
    Local aAreaSC7  := SC7->(FWGetArea()) As Array
    
    Local oPrimCfg  := OFCNHPrimConfig():New(.T.) As Object
    Local oFiles    := OFCNHA08():New() As Object
    Local cDirOut
    Local aArqs
    Local cSemaforo := 'PRIMSCHED_' + cFilAnt

    PRIVATE cDealer As Char
    PRIVATE cDirIn As Char
    PRIVATE cDirOk As char

    default lSendReceive := .T.

    if ! LockByName( cSemaforo, .T., .T. )
        FWLogMsg('INFO', /*cTransactionId*/, cSemaforo, /*cCategory*/, /*cStep*/, /*cMsgId*/, STR0001, /*nMensure*/, /*nElapseTime*/, /*aMessage*/)
        QOUT( STR0001 + ": " + cSemaforo )
        return nil
    endIF 

    cPrimDir := PATHCNH + oPrimCfg:cDealerCode + oPrimCfg:oConfig:DIR_IN

    cDealer := oPrimCfg:cDealerCode
    cDirIn  := PATHCNH+cDealer+oPrimCfg:oConfig:DIR_IN
    cDirOut := PATHCNH+cDealer+oPrimCfg:oConfig:DIR_OUT
    cDirOk  := PATHCNH+cDealer+oPrimCfg:oConfig:DIR_LIDOS

    if lSendReceive
        aArqs := Directory( cDirOut + '*.dat',, NIL, .T.)
        if len( aArqs ) > 0
            oFiles:sendFiles()
            oFiles:oWSDL          := tWSDLManager():New()
            oFiles:oWSDL:lVerbose := .T.
        else
            cAgroup := "PRIM"
            cTipo   := "UPLOAD FILES"
            cDados  := "Dealer: " + cDealer + CRLF + STR0012 + CRLF //"N�o h� arquivos para serem enviados"
            OA060004C_log( cAgroup, cTipo, cDados )
        endif

        oFiles:GetFiles()
    endif

    ReadFiles()

    UnLockByName( cSemaforo, .T., .T. )

    FWRestArea(aAreaSC7)
    FWRestArea(aAreaVBE)
    FWRestArea(aArea)

    FWFreeArray(aAreaSC7)
    FWFreeArray(aAreaVBE)
    FWFreeArray(aArea)

    FWFreeObj(oPrimCfg)
    FWFreeObj(oFiles)
Return

/*/{Protheus.doc} ReadFiles
Leitura de arquivos no diretorio de entrada
@type function
@version 1.0  
@author Rodrigo
@since 16/06/2025
/*/
Static Function ReadFiles()
Local aFiles    := {} As Array
Local aTamFiles := {} As Array
Local aDtFiles  := {} As Array
Local aHrFiles  := {} As Array
Local aAtributos:= {} As Array
Local aDados    := {} As Array

Local lChangeCase   := .T. As Logical 
Local lRicec150     := NIL As Logical

Local nFiles := 0 As Numeric

Local cFileID       := NIL As Char
Local cPrim2Path    := NIL As Char

Local oImport   := NIL As Object
Local oLog      := DMS_Logger():New(cFilAnt + '_OFCNHA05_' + DTOS(dDatabase) + '.log') As Object
private cMsgRICEC := ""

    aDir(cDirIn + '*', aFiles, aTamFiles, aDtFiles, aHrFiles, aAtributos, lChangeCase)

    aSort( aFiles,,, {|a,b| OFCNHA0502_OrdenaPorTipo(a) < OFCNHA0502_OrdenaPorTipo(b) } )

    For nFiles := 1 To Len(aFiles)

        cFileID := OFCNHA0501_GetFileId(aFiles[nFiles])
        cMsgRICEC := "File: " + aFiles[nFiles] + CRLF
        cMsgRICEC += "FileID: " + cFileID + CRLF

        IF 'ricec150' $ Lower(aFiles[nFiles]) .OR. 'ricec151' $ Lower(aFiles[nFiles])
            lRicec150   := 'ricec150' $ Lower(aFiles[nFiles])
            oImport     := OFCNHPrimRicec():New(cDirIn+aFiles[nFiles], lRicec150)
		    if oImport:Processa(oLog, cFileID)
                cMsgRICEC += oImport:cMsgLog
                cMsgRICEC += STR0009 + CRLF             // "Arquivo processado com sucesso"
                IF __CopyFile(cDirIn+aFiles[nFiles], cDirOk+aFiles[nFiles])
                    IF FErase(cDirIn+aFiles[nFiles]) != 0
                        cMsgRICEC += STR0006 + STR0007 + cValTochar(FError()) + CRLF        // "Arquivo n�o exclu�do do diret�rio LIDOS"    "- Error:"
                    EndIF
                ELSE
                    cMsgRICEC += STR0008 + CRLF     // "Arquivo n�o movido para diret�rio LIDOS"
                EndIF
            else
                cMsgRICEC += oImport:cMsgLog + CRLF
//                FErase(cDirIn+aFiles[nFiles])             // em caso de falha no PC, n�o excluir
            endif

            OA060004C_log( STR0002 /*cAgroup*/ , STR0003 + " " + cFileID /*cTipo*/, cMsgRICEC /*cDados*/, .T. )    // "PRIM"   "RICEC"

        elseIF 'prim01' $ Lower(aFiles[nFiles])
			oImport    := OFCNHPrim():New()
            aDados     := oImport:ProcessaPrim1(,cDirIn+aFiles[nFiles])
			cPrim2Path := OFCNHA0101_Processo(aDados)  

            cMsgRICEC += STR0009 + CRLF             // "Arquivo processado com sucesso"

            IF __CopyFile(cDirIn+aFiles[nFiles], cDirOk+aFiles[nFiles])
                IF FErase(cDirIn+aFiles[nFiles]) != 0
                    cMsgRICEC += STR0006 + STR0007 + cValTochar(FError()) + CRLF        // "Arquivo n�o exclu�do do diret�rio LIDOS"    "- Error:"
                EndIF
            ELSE
                cMsgRICEC += STR0008 + CRLF     // "Arquivo n�o movido para diret�rio LIDOS"
            EndIF
            OA060004C_log( STR0002 /*cAgroup*/ , STR0003 + " " + cFileID /*cTipo*/, cMsgRICEC /*cDados*/, .T. )    // "PRIM"   "RICEC"

        else
            cMsgRICEC += STR0011 + CRLF         // "Arquivo fora do padrao, sera excluido"
            if FErase(cDirIn+aFiles[nFiles]) != 0
                cMsgRICEC += STR0006 + STR0007 + cValTochar(FError()) + CRLF        // "Arquivo n�o exclu�do do diret�rio LIDOS"    "- Error:"
            endif
		EndIF
    Next
Return

/*/{Protheus.doc} SchedDef
Defini��o default de execu��o do schedule
@type function
@version 1.0  
@author Rodrigo
@since 14/06/2025
@return array, retorno padrao
/*/
Static Function SchedDef() As Array
    Local aParam    As Array
    Local aOrd      As Array /*04 - Array de ordens*/

    Local cTipo     As Char /*01 - Tipo R para relatorio P para processo*/
    Local cPerg     As Char /*02 - Pergunte do relatorio, caso nao use passar ParamDef*/
    Local cTable    As Char /*03 - Alias*/
    Local cTitulo   As Char /*05 - Titulo*/
    Local cReport   As Char /*06 - Nome do relat�rio (parametro 1 do metodo new da classe TReport)*/

    aParam  := {}
    aOrd    := {}

    cTipo   := 'P'
    cPerg   := 'ParamDef'
    cTable  := 'VBE'
    cTitulo := STR0002
    cReport := STR0002

    aAdd(aParam, cTipo)
    aAdd(aParam, cPerg) 
    aAdd(aParam, cTable) 
    aAdd(aParam, aOrd) 
    aAdd(aParam, cTitulo) 
    aAdd(aParam, cReport)
    aAdd(aParam, .F.)
    aAdd(aParam, .T.)
Return aParam

/*/{Protheus.doc} OFCNHA0501_GetFileId
	Criado para pegar o id do arquivo cnh, esse id n�o usado para definir a ordem de importa��o
	
	@type function
	@author Vinicius Gati
	@since 12/04/2018
/*/
function OFCNHA0501_GetFileId(cFileName As Char) As Array
local oHelper := DMS_StringHelper():New() As Object
local aDados  := oHelper:StrToKarr2(cFileName, '_') As Array
local cFileID := aTail( aDados )
local nPos    := RAT( ".", cFileID )

    if nPos > 0
        cFileID := left( cFileID, nPos-1 )
    endif

	FWFreeObj(oHelper)
return cFileID


/*/{Protheus.doc} OFCNHA0502_OrdenaPorTipo
retorna o nome do arquivo com prefixo para ordenar a carga: RICEC151, RICEC150 e PRIM01
@type function
@author Cristiam Rossi
@since 23/01/2026
/*/
function OFCNHA0502_OrdenaPorTipo(cFileName As Char) As Char
local cTipo as Char

    cFileName := lower( cFileName )

    if     "ricec151" $ cFileName
        cTipo := "0"
    elseif "ricec150" $ cFileName
        cTipo := "1"
    else
        cTipo := "2"
    endif

return cTipo + cFileName

