#include "totvs.ch"
#include "ofia661.ch"

#define ACAO_MOVER_ARQUIVO "2"
#define ACAO_EXCLUIR_ARQUIVO "3"

static cPerg := "OFIA661" // Grupo de perguntas (SX1) 
static cTpArq := "ENVATU" // tipo do arquivo a ser processado

/* {Protheus.doc} OFIA661
Importação do arquivo ENVATU (Scania)
@type function
@autor Paulo Roberto Alves Pereira
@data 07/08/2026
*/
Function OFIA661()
    local cOrigem   := ""
    local cDestin   := ""
    local aArqs     := {}
    local cTpAcao   := ""
    local lSchedule := FWGetRunSchedule()
    local oLogger   := DMS_Logger():New()

    if !lSchedule .and. !Pergunte(cPerg, .T.)
        return
    endif
    cOrigem := AllTrim(MV_PAR01)
    if MV_PAR02 == 2
        cDestin := AllTrim(MV_PAR03)
    endif
    cTpAcao := AllTrim(Str(MV_PAR02)) // 1=Nenhuma, 2=Mover, 3=Apagar

    aArqs := Directory(cOrigem + "*.dat", "D")
    
    if Len(aArqs) == 0
        if !lSchedule            
            FMX_HELP("OFIA661ERR05", STR0001 + " " + cOrigem, STR0002) // "Não foram encontrados arquivos de envio da área de atuação das concessionárias no diretório informado:", "Favor verificar o diretório onde os arquivos devem estar."
        else
            oLogger:SimpleLogToTable(cPerg, STR0001 + " " + cOrigem) 
        endif

        Return
    endif
    
    FWMsgRun(, {|oSay| OA6610028_ProcessaArquivos(oSay, cTpArq, aArqs, cOrigem, cDestin, cTpAcao, oLogger)}, STR0003, STR0004) // "Processando", "Aguarde, processando arquivos de envio da área de atuação das concessionárias ..."

return

/*/{Protheus.doc} SchedDef
Estabelece a comunicaçã que permite a definição do Pergunte por SChedule
@type static function
@autor Paulo Roberto Alves Pereira
@data 07/08/2026
/*/
Static Function SchedDef()

	Local aParam := {}

	aadd( aParam, "P" )             // 1-Tipo: P=Processo;R=Relatório
	aadd( aParam, cPerg )           // 2-Grupo de perguntas
	aadd( aParam, "" )              // 3-Alias (apenas Relatório)
	aadd( aParam, {} )              // 4-Array de ordem (apenas Relatório)
	aadd( aParam, "" )              // 5-Título (apenas Relatório)
	aadd( aParam, "" )              // 6-Layout de impressão (apenas Relatório)
	aadd( aParam, .F. )             // 7-Permite agendamento sempre ativo
	aadd( aParam, .F. )             // 8-Permite agendamento por filiais

Return aParam

/* {Protheus.doc} OA6610018_ValidPerg
Valida os parâmetros de entrada para o processamento do arquivo ENVATU
@type function
@autor Paulo Roberto Alves Pereira
@data 07/08/2026
*/
Function OA6610018_ValidPerg()
    local lRet := .T.

    do case
    // Diretório origem
	case ReadVar() == "MV_PAR01"
        MV_PAR01 := AllTrim(MV_PAR01) 

        if empty(MV_PAR01)
			FMX_HELP("OFIA661ERR01", STR0005, STR0006) // "O diretório onde estarão os arquivos é obrigatório.", "For favor selecione um diretório válido."
			MV_PAR01 := AllTrim(cGetFile( '', '', , "SERVIDOR", .T., GETF_RETDIRECTORY, .T., .T. ))
            lRet := ExistDir(MV_PAR01, 0, .F.)

        elseif !ExistDir(MV_PAR01, 0, .F.)
			FMX_HELP("OFIA661ERR02", STR0007, STR0006) // "O diretório onde estarão os arquivos não existe.", "For favor selecione um diretório válido."
			MV_PAR01 := AllTrim(cGetFile( '', '', , "SERVIDOR", .T., GETF_RETDIRECTORY, .T., .T. ))
            lRet := ExistDir(MV_PAR01, 0, .F.)
		endif

    // Diretório destino se MV_PAR02==2 (Mover)
	case ReadVar() == "MV_PAR03" .and. MV_PAR02 == 2 //  1=Nenhuma, 2=Mover, 3=Apagar
        MV_PAR03 := AllTrim(MV_PAR03) 

        if empty(MV_PAR03)
			FMX_HELP("OFIA661ERR03", STR0008, STR0006) // "Para mover o arquivo pós-processamento, o diretório destino precisa ser definido.", "For favor selecione um diretório válido."
			MV_PAR03 := AllTrim(cGetFile( '', '', , "SERVIDOR", .T., GETF_RETDIRECTORY, .T., .T. ))
            lRet := ExistDir(MV_PAR03, 0, .F.)

        elseif !ExistDir(MV_PAR03)
			FMX_HELP("OFIA661ERR04", STR0009, STR0006) // "O diretório destino não existe.", "For favor selecione um diretório válido."
			MV_PAR03 := AllTrim(cGetFile("", "", , "SERVIDOR", .T., GETF_RETDIRECTORY, .T., .T. )) 
            lRet := ExistDir(MV_PAR03, 0, .F.)
		endif
	endcase

Return lRet


/* {Protheus.doc} OA6610028_ProcessaArquivos
Processa os arquivos ENVATU no diretório de origem
@type static function
@autor Paulo Roberto Alves Pereira
@data 13/08/2026
*/
Static Function OA6610028_ProcessaArquivos(oSay, cTpArq, aArqs, cOrigem, cDestin, cTpAcao, oLogger)
    Local aLinha    := {}
    Local oArquivo  := Nil
    Local cJson     := ""
    Local oJson     := JsonObject():New()
    Local nCont     := 1
    Local cNmArq    := ""
    Local lProcessa := .T.
    private nArqOK  := 0
    private nArqErr := 0
    private nQtdOK  := 0
    private nQNoFil := 0    
    private nQNoCid := 0

    for nCont := 1 to len(aArqs)
        if !IsBlind()
            oSay:SetText(STR0010) // "Processando arquivos de envio da área de atuação das concessionárias ..."
        endif
        oArquivo := FWFileReader():New(cOrigem + aArqs[nCont, 1])
        lProcessa := .T.
        cJson := ""
        
        if (oArquivo:Open())
            if !(oArquivo:Eof())
                while (oArquivo:HasLine())
                    aLinha := OA6610038_TiraAspas(StrTokArr(oArquivo:GetLine(), ",")) // Tipo de Linha (UNH, BGM, ESI ou UNT)
                    if len(aLinha) < 3 .or. ( aLinha[1] == "UNH" .and. aLinha[3] != cTpArq )
                        lProcessa := .F.
                        exit
                    endif

                    if len(aLinha) >= 5 .and. aLinha[1] == "ESI" 
                        if !empty(cJson)
                            cJson += "," + CRLF
                        endif                            
                        cJson += '{' + CRLF
                        cJson += '  "CODIGOCONC":"' + aLinha[2] + '", ' + CRLF // Código Concessionaria
                        cJson += '  "UF":"'         + aLinha[3] + '", ' + CRLF // UF
                        cJson += '  "CODIGOIBGE":"' + aLinha[4] + '", ' + CRLF // Código do IBGE
                        cJson += '  "MUNICIPIO":"' + aLinha[5] + '"' + CRLF // Nome Municipio
                        cJson += '}'
                    endif
                enddo
                if !empty( cJson )
                    cJson := "[" + cJson + "]"
                endif
            endif

            oArquivo:Close()
        endif

        if lProcessa
            cRet := oJson:FromJson(cJson)
            if !IsBlind()
                oSay:SetText(STR0011) // "Gravando dados importados..."
            endif
            if OA6610048_GravaDados(oJson)
                nArqOK++
                cNmArq := ExtractFile(oArquivo:cFileName)
                if cTpAcao == "2"
                    if !IsBlind()
                        oSay:SetText(STR0012) // "Movendo arquivo processado..."
                    endif
                    OA6610058_MoveDeletaArquivo(cTpAcao, cOrigem + cNmArq, cDestin + cNmArq, oLogger) // Move o arquivo processado, conforme o parâmetro MV_PAR02
                elseif cTpAcao == "3"
                    if !IsBlind()
                        oSay:SetText(STR0013) // "Apagando arquivo processado..."
                    endif
                    OA6610058_MoveDeletaArquivo(cTpAcao, cOrigem + cNmArq, "", oLogger) // Apaga o arquivo processado, conforme o parâmetro MV_PAR02
                endif
                if !IsBlind()
                    oSay:SetText(STR0014) // "Processamento finalizado com sucesso!"
                endif
            else
                nArqErr++
                if !IsBlind()
                    oSay:SetText(STR0015) // "Erro ao processar dados importados!"
                endif
            endif
        endif
    next

    cMsg := STR0023 + " " + ltrim(str(nArqOK)) + " " + STR0024 + " " + ltrim(str(nArqErr)) + CRLF // "Arquivos Processados:" + ... + "Rejeitados:"
    cMsg += STR0025 + " " + ltrim(str(nQtdOK)) + CRLF // "Registros atualizados:"
    cMsg += STR0026 + " " + ltrim(str(nQNoFil)) + " " + STR0027 + CRLF // "Filial não encontrada:" + ... + "(para o código da concessionária informado no parâmetro MV_MIL0005)"
    cMsg += STR0028 + " " + ltrim(str(nQNoCid)) // "Cidade não encontrada:"
    
    FWAlertInfo(STR0016 + CRLF + CRLF + cMsg, STR0017) // "Processamento finalizado!", "Atenção"
    oLogger:SimpleLogToTable(cPerg, StrTran(cMsg, CRLF, " "))

return


/* {Protheus.doc} OA6610038_TiraAspas
Retira as aspas de cada elemento do array
@type static function
@autor Paulo Roberto Alves Pereira
@data 13/08/2026
*/
static function OA6610038_TiraAspas(aLinha)
    Local aTmp := {}
    Local nCont := 0

    For nCont := 1 To Len(aLinha)
        aAdd(aTmp, StrTran(aLinha[nCont], '"', ''))
    Next

return aTmp

/* {Protheus.doc} OA6610048_GravaDados
Grava tabela VAM a partir do JSON criado com os dados de um arquivo ENVATU
@type static function
@autor Paulo Roberto Alves Pereira
@data 13/08/2026
*/
static function OA6610048_GravaDados(oJson)
    local oFilHl   := DMS_FilialHelper():New()
    local cCodConc := "" 
    local cFil     := "" 
    local lRet     := .F.
    local nCont

    if len(oJson) > 0 
        lRet := .T.
        DbSelectArea("VAM")
        VAM->(DbSetOrder(1)) // VAM_FILIAL+VAM_IBGE
        for nCont := 1 to len(oJson)
            if cCodConc != oJson[nCont]['CODIGOCONC']
                cCodConc := oJson[nCont]['CODIGOCONC']
                cFil := oFilHl:ObterFilialPorConcessionaria(cCodConc)
            endif
            if VAM->(DbSeek( xFilial("VAM") + oJson[nCont]["CODIGOIBGE"]))
                if empty(cFil)
                    nQNoFil++
                else
                    RecLock("VAM", .F.)
                    nQtdOK++
                    VAM->VAM_EMPATE := cEmpAnt
                    VAM->VAM_FILATE := cFil
                    VAM->(MsUnLock())
                endif
            else
                nQNoCid++
            endif
        next
    endif

return lRet

/* {Protheus.doc} OA6610058_MoveDeletaArquivo
Trata o arquivo de garantia após o processamento, movendo-o para outro diretório ou apagando-o, conforme o parâmetro MV_PAR02
@type static function
@autor Paulo Roberto Alves Pereira
@data 13/08/2026
*/
static function OA6610058_MoveDeletaArquivo(cTpAcao, cOrigem, cDestin, oLogger)

    if cTpAcao == ACAO_MOVER_ARQUIVO 
        if !(FRename(cOrigem, cDestin) == 0)
            if !IsBlind()
                FMX_HELP("OFIA661ERR06", STR0018 + " " + cOrigem, STR0019) // "Erro ao mover o arquivo de envio da área de atuação das concessionárias:", "Verifique se o diretório de destino existe e se você tem permissão para gravar arquivos nele."
            else
                oLogger:SimpleLogToTable(cPerg, STR0018 + " " + cOrigem + "  " + STR0020 + " " + cValToChar(FError())) 
            endif
        endif

    elseif cTpAcao == ACAO_EXCLUIR_ARQUIVO
        if !(FErase(cOrigem) == 0)
            If !IsBlind()
                FMX_HELP("OFIA661ERR07", STR0021 + " " + cOrigem, STR0022) // "Erro ao apagar o arquivo de envio da área de atuação das concessionárias:", "Verifique se você tem permissão para apagar arquivos neste diretório."
            else
                oLogger:SimpleLogToTable(cPerg, STR0021 + " " + cOrigem + "  " + STR0020 + " " + cValToChar(FError())) 
            endif
        endif
    endif

return
