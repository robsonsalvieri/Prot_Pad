#INCLUDE 'TOTVS.CH'
#INCLUDE 'OFCNHA05.CH'

#DEFINE PATHCNH '/CNH/'

/*/{Protheus.doc} OFCNHA05
Obter arquivos para processmento
@type function
@version 1.0  
@author Rodrigo
@since 14/06/2025
/*/
Function OFCNHA05()
    Local aArea     := FWGetArea() As Array
    Local aAreaVBE  := VBE->(FWGetArea()) As Array
    Local aAreaSC7  := SC7->(FWGetArea()) As Array
    
    Local oPrimCfg  := OFCNHPrimConfig():New(.T.) As Object
    Local oFiles    := OFCNHA08():New() As Object

    Local lEmpresa  := .T. As Logical
    Local lFilial   := .F. As Logical

    PRIVATE cDealer As Char
    PRIVATE cDirIn As Char
    PRIVATE cDirOk As Char    

    IF !LockByName('PRIMSCHED', lEmpresa, lFilial)
        FWLogMsg('INFO', /*cTransactionId*/, 'PRIMSCHED', /*cCategory*/, /*cStep*/, /*cMsgId*/, STR0001, /*nMensure*/, /*nElapseTime*/, /*aMessage*/)
        Return
    EndIF

    cDealer := oPrimCfg:cDealerCode
    cDirIn  := PATHCNH+cDealer+oPrimCfg:oConfig:DIR_IN
    cDirOk  := PATHCNH+cDealer+oPrimCfg:oConfig:DIR_LIDOS

    IF oFiles:GetFiles() > 0
        ReadFiles()
    ELSE
        ReadFiles()
    EndIF

    UnLockByName('PRIMSCHED', lEmpresa, lFilial)

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

    aDir(cDirIn + '*', aFiles, aTamFiles, aDtFiles, aHrFiles, aAtributos, lChangeCase)

    For nFiles := 1 To Len(aFiles)
        
        cFileID       := OFCNHA0501_GetFileId(aFiles[nFiles])

        IF 'ricec150' $ Lower(aFiles[nFiles]) .OR. 'ricec151' $ Lower(aFiles[nFiles])
            lRicec150   := 'ricec150' $ Lower(aFiles[nFiles])
            oImport     := OFCNHPrimRicec():New(cDirIn+aFiles[nFiles], lRicec150)
		    oImport:Processa(oLog, cFileID)
            IF __CopyFile(cDirIn+aFiles[nFiles], cDirOk+aFiles[nFiles])
                OA060004C_log( STR0002 /*cAgroup*/ , STR0003 /*cTipo*/, STR0004 /*cDados*/, .F. )
                IF FErase(cDirIn+aFiles[nFiles]) == 0
                    OA060004C_log( STR0002 /*cAgroup*/ , STR0003 /*cTipo*/, STR0005 /*cDados*/, .F. )
                ELSE
                    OA060004C_log( STR0002 /*cAgroup*/ , STR0003 /*cTipo*/, STR0006 + STR0007 + cValTochar(FError()) /*cDados*/, .F. )
                EndIF
            ELSE
                OA060004C_log( STR0002 /*cAgroup*/ , STR0003 /*cTipo*/, STR0008 /*cDados*/, .F. )
            EndIF
        EndIF

        IF 'prim01' $ Lower(aFiles[nFiles])
			oImport     := OFCNHPrim():New()
            aDados      := oImport:ProcessaPrim1(,cDirIn+aFiles[nFiles])
			cPrim2Path  := OFCNHA0101_Processo(aDados)  
            IF __CopyFile(cDirIn+aFiles[nFiles], cDirOk+aFiles[nFiles])
                OA060004C_log( STR0002 /*cAgroup*/ , STR0003 /*cTipo*/, STR0004 /*cDados*/, .F. )
                IF FErase(cDirIn+aFiles[nFiles]) == 0
                    OA060004C_log( STR0002 /*cAgroup*/ , STR0003 /*cTipo*/, STR0005 /*cDados*/, .F. )
                ELSE
                    OA060004C_log( STR0002 /*cAgroup*/ , STR0003 /*cTipo*/, STR0006 + STR0007 + cValTochar(FError()) /*cDados*/, .F. )
                EndIF
            ELSE
                OA060004C_log( STR0002 /*cAgroup*/ , STR0003 /*cTipo*/, STR0008 /*cDados*/, .F. )
            EndIF
		EndIF

    Next
Return

/*/{Protheus.doc} SchedDef
Definição default de execução do schedule
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
    Local cReport   As Char /*06 - Nome do relatório (parametro 1 do metodo new da classe TReport)*/

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
Return aParam

/*/{Protheus.doc} OFCNHA0501_GetFileId
	Criado para pegar o id do arquivo cnh, esse id não usado para definir a ordem de importação
	
	@type function
	@author Vinicius Gati
	@since 12/04/2018
/*/
function OFCNHA0501_GetFileId(cFileName As Char) As Array
	local oHelper := DMS_StringHelper():New() As Object
	local aDados  := oHelper:StrToKarr2(cFileName, '_') As Array
	FWFreeObj(oHelper)
return aDados[Len(aDados)]
