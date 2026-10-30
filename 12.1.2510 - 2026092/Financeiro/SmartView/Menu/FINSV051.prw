#Include 'totvs.ch'
#include 'fwlibversion.ch'
#include 'FINSV051.ch'

/*/{Protheus.doc} FINSV051
	Chamada do Smart View no menu - ReplyOfBankCommunication - Retorno de Comunicação Bancária

	Antes de abrir o Smart View, permite ao usuário selecionar o arquivo de retorno
	CNAB e o arquivo de layout/configuração (Opcional) na sua estação e copia (upload) ambos
	para o servidor (Protheus_Data). Os caminhos já resolvidos no servidor são
	enviados ao objeto de negócio pelos parâmetros MV_PAR01 (arquivo de entrada) que é bloquado 
    para edição e MV_PAR02 (arquivo de config). Isso contorna a restrição
	do Smart View web/cloud, que não acessa o disco da estação cliente.

@author matheus.monteiro@totvs.com.br
@since 22/08/2026
@version 12.1.2510
@see 
*/

Function FINSV051()

    local lSuccess  As Logical
    local cError    As Character
    local cCnabFile As Character
    local cCfgFile  As Character
    local cSrvCnab  As Character
    local cSrvCfg   As Character
    local jParams   As Json
    Local cNomeRot  As Character

    Private lBarra  As Logical
    Private cSep As Character

    cNomeRot := "FINSV051"
    lSuccess  := .F.
    cError    := "" 
    cCnabFile := "" 
    cCfgFile  := "" 
    cSrvCnab  := "" 
    cSrvCfg   := "" 
    jParams   := Nil

    lBarra  := isSrvUnix()
    cSep    := Iif(lBarra,"/","\")

    if GetRpoRelease() > '12.1.2210' 
        if !FS051Sel(@cCnabFile, @cCfgFile)
            return
        endIf

        cSrvCnab := FS051Upl(cCnabFile)
        cSrvCfg  := FS051Upl(cCfgFile)

        if Empty(cSrvCnab) 
            FwLogMsg("WARN",, cNomeRot,,,, STR0010) //"Falha ao copiar o(s) arquivo(s) para o servidor."
            MsgAlert(STR0004, STR0005)
            return
        endIf

        jParams := FS051Prm(cSrvCnab, cSrvCfg)

        lSuccess := totvs.framework.treports.callTReports("backoffice.sv.fin.replyofbankcommunication",,,, jParams, .F.,, .T., @cError)

        // Limpeza dos arquivos temporarios copiados ao servidor
        FS051Del(cSrvCnab)
        FS051Del(cSrvCfg)
    endIf

    if !lSuccess
        FwLogMsg("WARN",, cNomeRot,,,, "backoffice.sv.fin.replyofbankcommunication - " + STR0011) //"backoffice.sv.fin.replyofbankcommunication - rotina não disponivel."
    endIf

return

/*/{Protheus.doc} FS051Sel
Exibe uma janela com dois campos e dois botões "..." para o usuário selecionar
o arquivo CNAB e o arquivo de layout. 

@param cCnab character, referência - recebe o caminho do arquivo CNAB
@param cCfg  character, referência - recebe o caminho do arquivo de layout
@return logical, .T. se confirmou; .F. se cancelou
@author matheus.monteiro@totvs.com.br
@since 22/08/2026
@version 12.1.2510
*/
Static Function FS051Sel(cCnab as character, cCfg as character)

    local oDlg     As Object
    local oGetCnab As Object
    local oGetCfg  As Object
    local lRet     As Logical

    lRet := .F.

    Private cVCnab := Space(250)
    Private cVCfg  := Space(250)

    DEFINE MSDIALOG oDlg TITLE STR0005 FROM 000,000 TO 250,550 PIXEL

    @ 035,010 SAY STR0006 SIZE 250,009 OF oDlg PIXEL
    @ 047,010 MSGET oGetCnab VAR cVCnab SIZE 230,012 OF oDlg PIXEL WHEN .F.
    @ 047,244 BUTTON "..." SIZE 020,012 OF oDlg PIXEL ACTION FS051BtC(oGetCnab)

    @ 068,010 SAY STR0007 SIZE 250,009 OF oDlg PIXEL
    @ 080,010 MSGET oGetCfg VAR cVCfg SIZE 230,012 OF oDlg PIXEL WHEN .T.
    @ 080,244 BUTTON "..." SIZE 020,012 OF oDlg PIXEL ACTION FS051BtL(oGetCfg)

    @ 102, 010 SAY STR0009 SIZE 250, 040 OF oDlg PIXEL 

    ACTIVATE MSDIALOG oDlg CENTERED ON INIT EnchoiceBar(oDlg, {|| FS051Ok(oDlg) }, {|| cVCnab := "", cVCfg := "", oDlg:End() })

    if !Empty(AllTrim(cVCnab))
        cCnab := AllTrim(cVCnab)
        cCfg  := AllTrim(cVCfg)
        lRet  := .T.
    endIf

return lRet

/*/{Protheus.doc} FS051BtC
Ação do botão "..." do arquivo CNAB. Abre tFileDialog e atualiza o TGet.

@param oGet object, TGet do campo CNAB
@author matheus.monteiro@totvs.com.br
@since 22/08/2026
@version 12.1.2510
*/
Static Function FS051BtC(oGet as object)

    local cFile As Character

    cFile := ""

    cFile := tFileDialog(STR0003, STR0001,,, .F.)

    if ValType(cFile) == "C" .And. !Empty(cFile)
        cVCnab := cFile
        oGet:Refresh()
    endIf

return

/*/{Protheus.doc} FS051BtL
Ação do botão "..." do arquivo de layout. Abre tFileDialog e atualiza o TGet.

@param oGet object, TGet do campo de layout
@author matheus.monteiro@totvs.com.br
@since 22/08/2026
@version 12.1.2510
*/
Static Function FS051BtL(oGet as object)

    local cFile As Character

    cFile := ""

    cFile := tFileDialog(STR0003, STR0002,,, .F.)

    if ValType(cFile) == "C" .And. !Empty(cFile)
        cVCfg := cFile
        oGet:Refresh()
    endIf

return

/*/{Protheus.doc} FS051Ok
Validação do botão Confirmar. Só encerra se o arquivo de retorno for selecionados.

@param oDlg object, diálogo
@author matheus.monteiro@totvs.com.br
@since 21/08/2025
@version 12.1.2510
*/
Static Function FS051Ok(oDlg as object)

    if Empty(AllTrim(cVCnab))
        MsgAlert(STR0008, STR0005)
    else
        oDlg:End()
    endIf

return

/*/{Protheus.doc} FS051Upl
Copia um arquivo da estação para uma pasta única no servidor.

@param cClientFile character, caminho do arquivo na estação
@return character, caminho no servidor (relativo ao rootpath) ou "" em caso de falha
@author matheus.monteiro@totvs.com.br
@since 22/08/2026
@version 12.1.2510
*/
Static Function FS051Upl(cClientFile as character)

    local cSrvPath As Character
    local cDestDir As Character
    local aFiles   As Array

    cSrvPath := ""
    cDestDir := ""
    aFiles   := {}

    cDestDir := cSep + "smartview" + cSep + "finsv051" + cSep + "" + FS051Uid() + "" + cSep 

    FS051MkD(cDestDir)

    if !Empty(cClientFile)
        if CpyT2S(AllTrim(cClientFile), cDestDir, .F.)
            aFiles := Directory(cDestDir + "*.*")
            if !Empty(aFiles)
                cSrvPath := cDestDir + aFiles[1][1]
            endIf
        endIf
    endIf

return cSrvPath

/*/{Protheus.doc} FS051Prm
Monta o JSON de parâmetros bloqueando MV_PAR01/MV_PAR02.

@param cSrvCnab character, caminho do CNAB no servidor
@param cSrvCfg  character, caminho do layout no servidor
@return json
@author matheus.monteiro@totvs.com.br
@since 22/08/2026
@version 12.1.2510
*/
Static Function FS051Prm(cSrvCnab as character, cSrvCfg as character)

    local jParams := JsonObject():New() As Json
    local jPar01  := JsonObject():New() As Json
    local jPar02  := JsonObject():New() As Json

    jParams["force"]      := .T.
    jParams["parameters"] := {}

    jPar01["name"]       := "MV_PAR01"
    jPar01["value"]      := cSrvCnab
    jPar01["visibility"] := "Disabled"
    aAdd(jParams["parameters"], jPar01)

    jPar02["name"]       := "MV_PAR02"
    jPar02["value"]      := cSrvCfg
    aAdd(jParams["parameters"], jPar02)

return jParams

/*/{Protheus.doc} FS051Del
Deleta o arquivo informado e remove o diretorio-pai (pasta <uid> exclusiva
daquela execucao). O diretorio \smartview\finsv051\ e mantido (compartilhado).
DirRemove so remove pasta vazia; se falhar (outro arquivo presente), encerra
sem erro.

@param cFilePath character, caminho completo do arquivo no servidor (relativo ao rootpath)
@author guilhermed.santos@totvs.com.br
@since 21/08/2026
@version 12.1.2410
*/
Static Function FS051Del(cFilePath as character)

    Local cDir As Character
    Local nPos As Numeric

    cDir := ""
    nPos := 0 

    // Deleta o arquivo
    FErase(cFilePath)

    nPos := RAt(cSep, cFilePath)

    If nPos > 0
        cDir := Left(cFilePath, nPos - 1)
    EndIf

    If !Empty(cDir)
        DirRemove(cDir)
    EndIf

Return
/*/{Protheus.doc} FS051MkD
Cria um diretorio recursivamente nivel a nivel 

@param cPath character, caminho completo a ser criado (relativo ao rootpath)
@author matheus.monteiro@totvs.com.br
@since 22/08/2026
@version 12.1.2510
*/
Static Function FS051MkD(cPath as character)

    local cAux    As Character
    local aParts  As Array
    local nI      As Numeric

    cAux    := "" 
    aParts  := {} 
    nI      := 0  

    if Right(cPath, 1) == cSep
        cPath := Left(cPath, Len(cPath) - 1)
    endIf

    aParts := StrTokArr(cPath, cSep)

    for nI := 1 To Len(aParts)
        if !Empty(aParts[nI])
            if Empty(cAux)
                cAux := cSep + aParts[nI]
            else
                cAux := cAux + cSep + aParts[nI]
            endIf

            if !ExistDir(cAux)
                MakeDir(cAux)
            endIf
        endIf
    next nI

return

/*/{Protheus.doc} FS051Uid
Gera identificador único para a subpasta de destino do upload.

@return character
@author matheus.monteiro@totvs.com.br
@since 22/08/2026
@version 12.1.2510
*/
Static Function FS051Uid()

    local cUid As Character

    cUid := ""

    cUid := DtoS(Date()) + StrTran(Time(), ":", "") + StrZero(Randomize(0, 99999), 5)

return cUid
