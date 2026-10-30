#include "totvs.ch"
#include "ofia663.ch"

#define ACAO_MOVER_ARQUIVO "2"
#define ACAO_EXCLUIR_ARQUIVO "3"

static cPerg := "OFIA663" // Grupo de perguntas (SX1) 
static cTpArq := "ENVARP" // tipo do arquivo a ser processado

/* {Protheus.doc} OFIA663
Importação do arquivo da Recompra Scania [ENVARP]
@type function
@autor Paulo Roberto Alves Pereira
@data 17/08/2026
*/
Function OFIA663()
    local lOk       := .F.
    local cOrigem   := ""
    local cDestin   := ""
    local aArqs     := {}
    local cTpAcao   := ""
    local lSchedule := FWGetRunSchedule()
    local oLogger   := DMS_Logger():New()

    if !lSchedule 
        while ! lOk .and. pergunte( cPerg, .T. )
            lOk := .T.
            if !OA6630018_ValidPerg("MV_PAR01", .T.)
                lOk := .F.
                exit
            endif
            if !OA6630018_ValidPerg("MV_PAR03", .T.)
                lOk := .F.
                exit
            endif
        endDo
        if ! lOk
            return nil
        endif
    endif
    cOrigem := AllTrim(MV_PAR01)
    if MV_PAR02 == 2
        cDestin := AllTrim(MV_PAR03)
    endif
    cTpAcao := AllTrim(Str(MV_PAR02)) // 1=Nenhuma, 2=Mover, 3=Apagar

    aArqs := Directory(cOrigem + "*.*")
    
    if Len(aArqs) == 0
        if !lSchedule            
            FMX_HELP("OFIA663ERR01", STR0001 + CRLF + CRLF + cOrigem, STR0002) // "Não foram encontrados arquivos de Importação da Recompra Scania no diretório informado:", "Favor verificar o diretório onde os arquivos devem estar." 
        else
            oLogger:SimpleLogToTable(cPerg, STR0001 + " " + cOrigem) 
        endif

        Return
    endif
    
    FWMsgRun(, {|oSay| OA6630028_ProcessaArquivos(oSay, cTpArq, aArqs, cOrigem, cDestin, cTpAcao, oLogger)}, STR0003, STR0004) // "Processando", "Aguarde, processando arquivos de Importação da Recompra Scania ..."

return

/*/{Protheus.doc} SchedDef
Estabelece a comunicaçã que permite a definição do Pergunte por SChedule
@type static function
@autor Paulo Roberto Alves Pereira
@data 17/08/2026
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

/* {Protheus.doc} OA6630018_ValidPerg
Valida os parâmetros de entrada para o processamento do arquivo ENVARP
@type function
@autor Paulo Roberto Alves Pereira
@data 17/08/2026
*/
Function OA6630018_ValidPerg(cParam, lDirVazio)
    local lRet := .T.
    default cParam := ReadVar()
    default lDirVazio := .F.

    do case
    // Diretório origem
	case cParam == "MV_PAR01"
        MV_PAR01 := AllTrim(MV_PAR01) 

        if empty(MV_PAR01) .and. lDirVazio
			FMX_HELP("OFIA663ERR02", STR0005, STR0006) // "O diretório onde estarão os arquivos é obrigatório.", "For favor selecione um diretório válido."
            lRet := .F.
        endif
        if !empty(MV_PAR01) .and. !ExistDir(MV_PAR01, 0, .F.)
			FMX_HELP("OFIA663ERR03", STR0007, STR0006) // "O diretório onde estarão os arquivos não existe.", "For favor selecione um diretório válido."
            MV_PAR01 := ""
            lRet := .F.
		endif

    // Diretório destino se MV_PAR02==2 (Mover)
	case cParam == "MV_PAR03" .and. MV_PAR02 == 2 //  1=Nenhuma, 2=Mover, 3=Apagar
        MV_PAR03 := AllTrim(MV_PAR03) 

        if empty(MV_PAR03) .and. lDirVazio
			FMX_HELP("OFIA663ERR04", STR0008, STR0006) // "Para mover o arquivo pós-processamento, o diretório destino precisa ser definido.", "For favor selecione um diretório válido."
            lRet := .F.
        endif
        if !empty(MV_PAR03) .and. !ExistDir(MV_PAR03)
			FMX_HELP("OFIA663ERR05", STR0009, STR0006) // "O diretório destino não existe.", "For favor selecione um diretório válido."
            MV_PAR03 := ""
            lRet := .F.
		endif
	endcase

Return lRet


/* {Protheus.doc} OA6630028_ProcessaArquivos
Processa os arquivos ENVARP no diretório de origem
@type static function
@autor Paulo Roberto Alves Pereira
@data 17/08/2026
*/
Static Function OA6630028_ProcessaArquivos(oSay, cTpArq, aArqs, cOrigem, cDestin, cTpAcao, oLogger)
    Local aLinha    := {}
    Local lProcessa := .T.
    Local oArquivo  := Nil
    Local oJson     := JsonObject():New()    
    Local cJson, cJsonEPB, cJsonEPC, cJsonEPD, cJsonEPE
    Local nCont, cNomeArq, cMesAno, cPedido, cMsg, cDataBGM, cHoraBGM
    Private nQtdInc := 0
    Private nQtdAtu := 0
    Private nArqOK  := 0
    Private nArqErr := 0

    for nCont := 1 to len(aArqs)
        if !IsBlind()
            oSay:SetText(STR0010) // "Processando arquivos de Importação da Recompra Scania ..."
        endif
        oArquivo := FWFileReader():New(cOrigem + aArqs[nCont, 1])
        lProcessa := .T.        
        cJsonEPB  := ""
        cJsonEPC  := ""
        cJsonEPD  := ""
        cJsonEPE  := ""
        cMesAno   := ""
        cPedido   := ""
        cDataBGM  := ""
        cHoraBGM  := ""
        
        if (oArquivo:Open())
            if !(oArquivo:Eof())
                while (oArquivo:HasLine())
                    aLinha := OA6630038_TiraAspas(StrTokArr(oArquivo:GetLine(), ",")) // Tipo de Linha (UNH, BGM, ESI ou UNT)
                    if len(aLinha) > 0
                        if aLinha[1] == "UNH" .and. len(aLinha) >= 3 .and. aLinha[3] != cTpArq 
                            lProcessa := .F.
                            exit
                        endif

                        if aLinha[1] == "BGM" .and. len(aLinha) >= 3
                            cDataBGM := substr(str(year(date()),4), 1, 2) + substr(aLinha[3], 1, 6)
                            cHoraBGM := substr(aLinha[3], 7)
                        endif                        

                        if aLinha[1] == "EPB" .and. len(aLinha) >= 9
                            cMesAno  := aLinha[8]
                            cPedido  := aLinha[9]

                            if !empty(cJsonEPB)
                                cJsonEPB += "," + CRLF
                            endif                            
                            cJsonEPB += '{' + CRLF
                            cJsonEPB += ' "MESANO":"'   + cMesAno + '", ' + CRLF 
                            cJsonEPB += ' "PEDIDO":"'   + cPedido + '", ' + CRLF                             
                            cJsonEPB += ' "DATGER":"'   + cDataBGM + '", ' + CRLF 
                            cJsonEPB += ' "HORGER":"'   + cHoraBGM + '" ' + CRLF 
                            // cJsonEPB += ' "DATGER":"'   + aLinha[2] + '", ' + CRLF 
                            // cJsonEPB += ' "HORGER":"'   + aLinha[3] + '" ' + CRLF 
                            cJsonEPB += '}'
                        endif

                        if aLinha[1] == "EPC" .and. len(aLinha) >= 5 .and. !empty(cMesAno) .and. !empty(cPedido)
                            if !empty(cJsonEPC)
                                cJsonEPC += "," + CRLF
                            endif                            
                            cJsonEPC += '{' + CRLF
                            cJsonEPC += ' "MESANO":"'   + cMesAno + '", ' + CRLF 
                            cJsonEPC += ' "PEDIDO":"'   + cPedido + '", ' + CRLF 
                            cJsonEPC += ' "CABESP1":"'   + aLinha[2] + '", ' + CRLF // Cabeçalho Especial 1
                            cJsonEPC += ' "CABESP2":"'   + aLinha[3] + '", ' + CRLF // Cabeçalho Especial 2
                            //cJsonEPC += ' "CABESP3":""'  + aLinha[4] + '", ' + CRLF // Cabeçalho Especial 3
                            cJsonEPC += ' "CABESP4":"'   + aLinha[5] + '" ' + CRLF // Cabeçalho Especial 5
                            cJsonEPC += '}'
                        endif

                        if aLinha[1] == "EPD" .and. len(aLinha) >= 9 .and. !empty(cMesAno) .and. !empty(cPedido)
                            if !empty(cJsonEPD)
                                cJsonEPD += "," + CRLF
                            endif                            
                            cJsonEPD += '{' + CRLF
                            cJsonEPD += ' "MESANO":"'   + cMesAno + '", ' + CRLF 
                            cJsonEPD += ' "PEDIDO":"'   + cPedido + '", ' + CRLF 
                            cJsonEPD += ' "SEQITEM":"'   + aLinha[2] + '", ' + CRLF // Sequencia do Item
                            cJsonEPD += ' "NUMITEM":"'   + aLinha[3] + '", ' + CRLF // Número do Item
                            cJsonEPD += ' "DESCRICAO":"' + aLinha[4] + '", ' + CRLF // Descricao da Peça
                            cJsonEPD += ' "PESOLIQ":"'   + aLinha[5] + '", ' + CRLF // Peso Liquido
                            cJsonEPD += ' "CABESP":"'    + aLinha[6] + '", ' + CRLF // Peso Liquido
                            cJsonEPD += ' "QUANT":"'     + aLinha[7] + '", ' + CRLF // Quantidade
                            cJsonEPD += ' "PRECOUNIT":"' + aLinha[8] + '", ' + CRLF // Preco Dealer Unitário
                            cJsonEPD += ' "PERCICMS":"'  + aLinha[9] + '"'    + CRLF // % ICMS
                            cJsonEPD += '}'
                        endif

                        if aLinha[1] == "EPE" .and. len(aLinha) >= 5 .and. !empty(cMesAno) .and. !empty(cPedido)
                            if !empty(cJsonEPE)
                                cJsonEPE += "," + CRLF
                            endif                            
                            cJsonEPE += '{' + CRLF
                            cJsonEPE += ' "MESANO":"'   + cMesAno + '", ' + CRLF 
                            cJsonEPE += ' "PEDIDO":"'   + cPedido + '", ' + CRLF 
                            cJsonEPE += ' "TOTAL":"'    + aLinha[3] + '", ' + CRLF 
                            cJsonEPE += ' "PERCICMS":"' + aLinha[5] + '" ' + CRLF
                            cJsonEPE += '}'
                        endif
                    endif
                enddo
                if !empty( cJsonEPB )
                    cJsonEPB := "[" + cJsonEPB + "]"
                endif                  
                if !empty( cJsonEPC )
                    cJsonEPC := "[" + cJsonEPC + "]"
                endif                
                if !empty( cJsonEPD )
                    cJsonEPD := "[" + cJsonEPD + "]"
                endif
                if !empty( cJsonEPE )
                    cJsonEPE := "[" + cJsonEPE + "]"
                endif                
            endif
            oArquivo:Close()
        endif

        if lProcessa            
            cJson := ""
            if !empty(cJsonEPB)
                cJson += ' "EPB" : ' + cJsonEPB
            endif
            if !empty(cJsonEPC)
                if !empty(cJson)
                    cJson += ',' + CRLF
                endif
                cJson += ' "EPC" : ' + cJsonEPC
            endif
            if !empty(cJsonEPD)
                if !empty(cJson)
                    cJson += ',' + CRLF
                endif
                cJson += ' "EPD" : ' + cJsonEPD
            endif
            if !empty(cJsonEPE)
                if !empty(cJson)
                    cJson += ',' + CRLF
                endif            
                cJson += ' "EPE" : ' + cJsonEPE
            endif    
            if !empty(cJson)
                cJson := '{' + CRLF + cJson + CRLF + '}'
            endif                    

            cRet := oJson:FromJson(cJson)
            if !IsBlind()
                oSay:SetText(STR0011) // "Gravando dados importados..."
            endif
            cNomeArq := ExtractFile(oArquivo:cFileName)
            
            if empty(cRet) .and. ValType(oJson) == "J" .and. OA6630048_GravaDados(oJson)
                nArqOK++
                if cTpAcao == "2"
                    if !IsBlind()
                        oSay:SetText(STR0012)  // "Movendo arquivo processado..."
                    endif
                    OA6630058_MoveDeletaArquivo(cTpAcao, cOrigem + cNomeArq, cDestin + cNomeArq, oLogger) // Move o arquivo processado, conforme o parâmetro MV_PAR02
                elseif cTpAcao == "3"
                    if !IsBlind()
                        oSay:SetText(STR0013) // "Apagando arquivo processado..."
                    endif
                    OA6630058_MoveDeletaArquivo(cTpAcao, cOrigem + cNomeArq, "", oLogger) // Apaga o arquivo processado, conforme o parâmetro MV_PAR02
                endif
                if !IsBlind()
                    oSay:SetText(STR0014) // "Processamento finalizado com sucesso!"
                endif
            else
                nArqErr++
                oLogger:SimpleLogToTable(cPerg, STR0015 + cNomeArq) // "Arquivo não importado: "
                if !IsBlind()
                    oSay:SetText(STR0016) // "Erro ao processar dados importados!"
                endif
            endif
        endif
    next

    cMsg := STR0017 + ltrim(str(nArqOK)) + CRLF // "Arquivos processados: "
    cMsg += STR0018 + ltrim(str(nArqErr)) + CRLF // "Arquivos rejeitados: "
    cMsg += STR0019 + ltrim(str(nQtdInc)) + CRLF // "Itens adicionados: "
    cMsg += STR0020 + ltrim(str(nQtdAtu)) // "Itens atualizados: "
    
    FWAlertInfo(STR0021 + CRLF + CRLF + cMsg, STR0022) // "Processamento finalizado!",  "Atenção"
    oLogger:SimpleLogToTable(cPerg, StrTran(cMsg, CRLF, " "))

return


/* {Protheus.doc} OA6630038_TiraAspas
Retira as aspas de cada elemento do array
@type static function
@autor Paulo Roberto Alves Pereira
@data 17/08/2026
*/
static function OA6630038_TiraAspas(aLinha)
    Local aTmp := {}
    Local nCont := 0

    For nCont := 1 To Len(aLinha)
        aAdd(aTmp, StrTran(aLinha[nCont], '"', ''))
    Next

return aTmp

/* {Protheus.doc} OA6630048_GravaDados
Grava tabela VWN E VWO a partir do JSON criado com os dados de um arquivo ENVARP
@type static function
@autor Paulo Roberto Alves Pereira
@data 17/08/2026
*/
static function OA6630048_GravaDados(oJson)
    local nCont, lExiste
    local lRet := .F.   

    if oJson:HasProperty("EPB") .and. len(oJson["EPB"]) > 0
        lRet := .T.
        DbSelectArea("VWN")
        for nCont := 1 to len(oJson["EPB"])        
            lExiste := VWN->(Dbseek(xfilial("VWN") + oJson["EPB"][nCont]["MESANO"] + oJson["EPB"][nCont]["PEDIDO"]))
            RecLock("VWN", !lExiste)
            if lExiste
                nQtdAtu++
            else
                nQtdInc++
                VWN->VWN_FILIAL  := xFILIAL("VWN")
                VWN->VWN_MESANO	:= oJson["EPB"][nCont]["MESANO"]
                VWN->VWN_PEDIDO  := oJson["EPB"][nCont]["PEDIDO"]
            endif
            VWN->VWN_DATGER	:= oJson["EPB"][nCont]["DATGER"]
            VWN->VWN_HORGER	:= oJson["EPB"][nCont]["HORGER"]
            VWN->(MsUnLock())
        next
    endif

    if oJson:HasProperty("EPC") .and. len(oJson["EPC"]) > 0
        lRet := .T.
        DbSelectArea("VWN")
        for nCont := 1 to len(oJson["EPC"])        
            lExiste := VWN->(Dbseek(xfilial("VWN") + oJson["EPC"][nCont]["MESANO"] + oJson["EPC"][nCont]["PEDIDO"]))
            RecLock("VWN", !lExiste)
            if lExiste
                nQtdAtu++
            else
                nQtdInc++
                VWN->VWN_FILIAL  := xFILIAL("VWN")
                VWN->VWN_MESANO	:= oJson["EPC"][nCont]["MESANO"]
                VWN->VWN_PEDIDO  := oJson["EPC"][nCont]["PEDIDO"]
            endif
            VWN->VWN_CBESP1  := oJson["EPC"][nCont]["CABESP1"]
            VWN->VWN_CBESP2  := oJson["EPC"][nCont]["CABESP2"]
            VWN->VWN_CBESP3  := ""
            VWN->VWN_CBESP4  := oJson["EPC"][nCont]["CABESP4"]
            VWN->(MsUnLock())
        next
    endif

    if oJson:HasProperty("EPD") .and. len(oJson["EPD"]) > 0
        lRet := .T.
        DbSelectArea("VWO")
        VWO->(DbSetOrder(1)) 
        for nCont := 1 to len(oJson["EPD"])
            lExiste := VWO->(Dbseek(xfilial("VWO") + oJson["EPD"][nCont]["MESANO"] + oJson["EPD"][nCont]["PEDIDO"] + oJson["EPD"][nCont]["NUMITEM"]))            
            RecLock("VWO", !lExiste)
            if lExiste
                nQtdAtu++
            else
                nQtdInc++
                VWO->VWO_FILIAL := xFILIAL("VWO")
                VWO->VWO_MESANO := oJson["EPD"][nCont]["MESANO"]
                VWO->VWO_PEDIDO := oJson["EPD"][nCont]["PEDIDO"]
    			VWO->VWO_SEQUEN  := oJson["EPD"][nCont]["SEQITEM"]
	    		VWO->VWO_CODITE  := oJson["EPD"][nCont]["NUMITEM"]
            endif
			VWO->VWO_DESCRI  := oJson["EPD"][nCont]["DESCRICAO"]
			VWO->VWO_PESOLQ  := Val(oJson["EPD"][nCont]["PESOLIQ"])
			VWO->VWO_CABESP  := oJson["EPD"][nCont]["CABESP"]
			VWO->VWO_QUANTI  := Val(oJson["EPD"][nCont]["QUANT"])
			VWO->VWO_PRECO   := Val(oJson["EPD"][nCont]["PRECOUNIT"])/100
			VWO->VWO_PERICM  := Val(Right(oJson["EPD"][nCont]["PERCICMS"],6))/100
            VWO->(MsUnLock())
        next
    endif

    if oJson:HasProperty("EPE") .and. len(oJson["EPE"]) > 0
        lRet := .T.
        DbSelectArea("VWN")
        for nCont := 1 to len(oJson["EPE"])        
            lExiste := VWN->(Dbseek(xfilial("VWN") + oJson["EPE"][nCont]["MESANO"] + oJson["EPE"][nCont]["PEDIDO"]))
            RecLock("VWN", !lExiste)
            if lExiste
                nQtdAtu++
            else
                nQtdInc++
                VWN->VWN_FILIAL  := xFILIAL("VWN")
                VWN->VWN_MESANO	:= oJson["EPE"][nCont]["MESANO"]
                VWN->VWN_PEDIDO  := oJson["EPE"][nCont]["PEDIDO"]
            endif
            VWN->VWN_VTOTAL  := Val(oJson["EPE"][nCont]["TOTAL"])/100
            VWN->VWN_PERICM  := Val(oJson["EPE"][nCont]["PERCICMS"])
            VWN->(MsUnLock())
        next
    endif    

return lRet

/* {Protheus.doc} OA6630058_MoveDeletaArquivo
Trata o arquivo de garantia após o processamento, movendo-o para outro diretório ou apagando-o, conforme o parâmetro MV_PAR02
@type static function
@autor Paulo Roberto Alves Pereira
@data 17/08/2026
*/
static function OA6630058_MoveDeletaArquivo(cTpAcao, cOrigem, cDestin, oLogger)

    if cTpAcao == ACAO_MOVER_ARQUIVO 
        if !(FRename(cOrigem, cDestin) == 0)
            if !IsBlind()
                FMX_HELP("OFIA663ERR06", STR0023 + CRLF + cOrigem, STR0024) // "Erro ao mover o arquivo de Importação da Recompra Scania:", "Verifique se o diretório de destino existe e se você tem permissão para gravar arquivos nele ou se já existe um arquivo com o mesmo nome no diretório."
            endif
            oLogger:SimpleLogToTable(cPerg, STR0023 + " " + cOrigem + "  " + STR0025 + " " + cValToChar(FError())) // "Erro ao mover o arquivo de Importação da Recompra Scania:", "Erro:"
        endif

    elseif cTpAcao == ACAO_EXCLUIR_ARQUIVO
        if !(FErase(cOrigem) == 0)
            If !IsBlind()
                FMX_HELP("OFIA663ERR07", STR0026 + CRLF + CRLF + cOrigem, "Verifique se você tem permissão para apagar arquivos neste diretório.") // "Erro ao apagar o arquivo de Importação da Recompra Scania:"
            endif
            oLogger:SimpleLogToTable(cPerg, STR0026 + " " + cOrigem + "  " + STR0025 + " " + cValToChar(FError())) // "Erro ao apagar o arquivo de Importação da Recompra Scania:", "Erro:"
        endif
    endif

return
