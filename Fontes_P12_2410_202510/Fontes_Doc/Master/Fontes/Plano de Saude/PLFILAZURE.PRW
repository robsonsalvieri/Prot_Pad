#INCLUDE "PROTHEUS.CH"
#include "totvs.ch"
#include "FWMVCDEF.CH"
#include "PLSMGER.CH"
#INCLUDE "TOPCONN.CH"

Main Function PLAZUREFIL(lAuto,aParam)
    MsAguarde({|| loadFiles()}, "Aguarde...", "Carregando anexos...")
Return

Static Function loadFiles()

    Local cTempoIni  := Time()
    Local cTempoFim  := ""
    Local aPastas    := {}
    Local aTemp      := {}
    Local nAtual     := 0
    Local nAux       := 0
    Local nTamanho   := 0

    local cPasta     := "" // pasta raiz onde estão os anexos
    local cPastaShared := "" // pasta do banco de conhecimento onde iremos transferir os arquivos 
    local aArqInfos  := {} // array onde iremos guardar todas as informações pasta/arquivos
    local aSubArq    := {} // arquivos encontrado nas subspastas 
    local cDir       := "" // pasta com numero da guia onde estão os arquivos fisicos
    local cNumGui    := "" // numero da guia 
    local lCopy      := .f. // variavel que verifica se a copia dos arquivos foi bem-sucedido
    local lDelDir    := .t. // varivael que verifica se podemos deletar o diretorio caso der erro não excluímos nem a subpasta nem o arquivo que deu erro.
    local nErro      := 0 // quantidade de erros 
    local cAlias     := '' // define qual o alias da guia 
    local cEnv       := GetEnvServer()
    local cEmp       := AllTrim(GETPVPROFSTRING(cEnv,"EMPROBOXML","",GetADV97()))
    local cFil       := AllTrim(GETPVPROFSTRING(cEnv,"FILROBOXML","",GetADV97())) 

    if(!empty(cEmp) .and. !empty(cFil))

        PlsPtuLog("iniciando importação dos anexos hora: " + cvaltochar(cTempoIni), "PLFILAZURE.log")

        RpcSetType(3)
        RpcSetEnv(cEmp, cFil,,,'PLS',,) 

        iif(MsMultDir(), cPastaShared := MsRetPath(), cPastaShared := MsDocPath())
        cPasta := strtran(cPastaShared,"SHARED","DOCUMENTS") + '\'

        if(ExistDir(cPastaShared) .and. ExistDir(cPasta))

            //Pega as pastas da raíz
            aPastas := Directory(cPasta + "*.*", "D")

            PlsPtuLog("foram encontrados " + CVALTOCHAR(len(aPastas) - 2) + " pastas para importação" , "PLFILAZURE.log")
            
            //Percorre todas as pastas do Array (Conforme ele for sendo atualizado, volta pro laço)
            For nAtual := 1 To Len(aPastas)
                
                //Se não tiver ponto no nome, e for do tipo D (Diretório)
                If ! "." $ Alltrim(aPastas[nAtual][1]) .And. aPastas[nAtual][5] == "D"
                    
                    //Se não tiver a pasta raíz no nome, adiciona, por exemplo, "SubPasta" -> "C:\TOTVS\SubPasta"
                    If ! cPasta $ aPastas[nAtual][1]
                        aPastas[nAtual][1] := cPasta + aPastas[nAtual][1]
                    EndIf
                    
                    cDir := aPastas[nAtual][1]
                    cNumGui := SUBSTR(aPastas[nAtual][1],30,46)
                    aTemp := Directory(aPastas[nAtual][1] + "/*.*", "D")
                    
                    //Percorre as subpastas 
                    For nAux := 1 To Len(aTemp)
                        If Alltrim(aTemp[nAux][1]) != '.' .and. Alltrim(aTemp[nAux][1]) != '..'
                            aadd(aSubArq, aTemp[nAux][1])
                        endif
                    Next  

                    aadd(aArqInfos, {cDir,cNumGui,aSubArq})
                    aSubArq := {}

                endif
            Next

            PlsPtuLog("pastas varridas com sucesso, iniciando gravação", "PLFILAZURE.log")

            //Pega o tamanho das pastas
            nTamanho := Len(aArqInfos)
            
            For nAtual := 1 To nTamanho

                MsProcTxt("Importando anexos: " + CVALTOCHAR( nAtual ) + " de " + CVALTOCHAR( nTamanho ))
                cDir :=  aArqInfos[nAtual][1]
                cNumGui := aArqInfos[nAtual][2]
                aSubArq := aArqInfos[nAtual][3]
                lDelDir := .t.

                if(len(aSubArq) > 0) .and. len(cNumGui) == 18// se a pasta nao tem arquivos ou numero da guia estiver inconsistente não devemos fazer nada 

                    cAlias := tipGui(cNumGui)

                    if(!empty(cAlias))
                        for nAux := 1 to len(aSubArq)
                            cExtArq	:= subStr(aSubArq[nAux], RAT(".", aSubArq[nAux])+1)
                            cDescri := aSubArq[nAux]
                            cFileName := upper(left(substr(aSubArq[nAux], 1, RAT(".", aSubArq[nAux])-1) + strtran(Time(), ":", "_"), len( ACB->ACB_OBJETO )-5)  + "." + cExtArq)
                            lCopy := __CopyFile(cDir + "\" + cDescri , cPastaShared + "\" + cFileName,,,.t.)
                            if(lCopy)
                                fErase(cDir + "\" + cDescri) // excluimos o arquivo copiado
                                grava(cDescri,cFileName,cAlias,cNumGui)//gravamos nas tabelas ac9 acb 
                            else 
                                PlsPtuLog("Erro ao copiar anexo guia: " + cNumGui + "arquivo: "+ aSubArq[nAux] + " erro "+ cvaltochar(ferror()), "PLFILAZURE.log")
                            endif 
                        next 
                    else 
                        lDelDir := .f. // caso não encontrar a guia não excluímos o arquivo nem a subpasta
                        nErro++
                        PlsPtuLog("Guia "+ cNumGui+ " não encontrada" , "PLFILAZURE.log")
                    endif 

                    if(lDelDir) // caso nenhum arquivo da subpasta tiver dado erro na gravacao, copia ou a pasta estiver vazia excluímos a subpasta
                        DirRemove(cDir, nil)
                    endif 
                else 
                    PlsPtuLog("Numero da guia inconsistente ou pasta sem arquivos, guia: "+ cNumGui , "PLFILAZURE.log") 
                endif 
            Next

            //Finaliza o tempo, e mostra uma saída no console.log
            cTempoFim := Time()
            FWAlertSuccess("",;
                "Importação Concluída !" + CRLF + CRLF +;
                "Inicio: " + cTempoIni + CRLF +;
                "Término: " + cTempoFim + CRLF +;
                "Guias não encontradas: " + cValToChar(nErro);
            )

            PlsPtuLog("importação finalizada hora: " + cvaltochar(Time()), "PLFILAZURE.log")
        else 
            FWAlertWarning("Alerta", "Diretórios não encontrados: " + cPastaShared + " e " + cPasta)
        endif
    else 
        FWAlertWarning("Alerta", "Variaveis EMPROBOXML e FILROBOXML vazias.")
    endif

Return

static function grava(cDescri, cFileName, cAlias, cNumGui)

    default cFileName := ''
    default cDescri := ''
    default cAlias    := ''

    ACB->(dbSetOrder(1))
    AC9->(dbSetOrder(1))

    cObj := ACB->(getSXENum( "ACB", "ACB_CODOBJ" ))
    ACB->(confirmSX8())

    while ACB->( msSeek( xFilial("ACB") + cObj ) )
        cObj := ACB->(getSXENum( "ACB", "ACB_CODOBJ" ))
        ACB->(confirmSX8())
    endDo

    ACB->( RecLock( "ACB", .T. ) )
    ACB->ACB_FILIAL  := xFilial( "ACB" )
    ACB->ACB_CODOBJ := cObj
    ACB->ACB_OBJETO := cFileName
    ACB->ACB_DESCRI := cDescri
    ACB->( MsUnlock() )

    AC9->(RecLock( "AC9", .T. ))
    AC9->AC9_FILIAL := xFilial( "AC9" )
    AC9->AC9_FILENT := xFilial( cAlias )
    AC9->AC9_ENTIDA := cAlias
    AC9->AC9_CODENT := xFilial( "AC9" ) + cNumGui
    AC9->AC9_CODOBJ := cObj
    AC9->( MsUnlock() )

return 

static function tipGui(cNumGui)

    local cSql := ''
    local cCodOpe := SUBSTR( cNumGui, 1, 4)
    local cAno := SUBSTR( cNumGui, 5, 4)
    local cMes := SUBSTR( cNumGui, 9, 2)
    local cNumAut := SUBSTR( cNumGui, 11, 18)
    local lRet := .f.
    default cNumGui := ''

    cSql := " SELECT BEA_TIPGUI FROM " + RetSqlName("BEA") 
    cSql += " WHERE BEA_FILIAL = '" + xFilial( "BEA" ) + "' "
    cSql += " AND BEA_OPEMOV = '" + cCodOpe + "' "
    cSql += " AND BEA_ANOAUT = '"   + cAno + "' "
    cSql += " AND BEA_MESAUT = '"   + cMes + "' "
    cSql += " AND BEA_NUMAUT = '"   + cNumAut + "' "
    cSql += " AND D_E_L_E_T_ = ' ' "

	dbUseArea(.T.,"TOPCONN",TCGENQRY(,,cSQL),'cAlias',.F.,.T.)

	if !cAlias->(Eof())
        if(cAlias->(BEA_TIPGUI) == '01' .or. cAlias->(BEA_TIPGUI) == '02' .or. cAlias->(BEA_TIPGUI) == '13' .or. cAlias->(BEA_TIPGUI) == '03')
            cTable := 'BEA'    
        elseif(cAlias->(BEA_TIPGUI) == '11')
             cTable := 'B4Q'  
        endif
		lret   := .t. 
	endif

    cAlias->(DBCLOSEAREA())

    if(!lRet)
        cSql := " SELECT 1 FROM " + RetSqlName("B4A") 
        cSql += " WHERE B4A_FILIAL = '" + xFilial( "B4A" ) + "' "
        cSql += " AND B4A_OPEMOV = '" + cCodOpe + "' "
        cSql += " AND B4A_ANOAUT = '"   + cAno + "' "
        cSql += " AND B4A_MESAUT = '"   + cMes + "' "
        cSql += " AND B4A_NUMAUT = '"   + cNumAut + "' "
        cSql += " AND D_E_L_E_T_ = ' ' "

	    dbUseArea(.T.,"TOPCONN",TCGENQRY(,,cSQL),'cAlias',.F.,.T.)

        if !cAlias->(Eof())
            cTable := 'B4A'  
            lret   := .t. 
	    endif

         cAlias->(DBCLOSEAREA())
    endif

    
    if(!lRet)
        cSql := " SELECT 1 FROM " + RetSqlName("BEC") 
        cSql += " WHERE BEC_FILIAL = '" + xFilial( "BEC" ) + "' "
        cSql += " AND BEC_GUIPRI = '" + cNumGui + "' OR BEC_SEQUEN = '" + cNumGui + "'"
        cSql += " AND D_E_L_E_T_ = ' ' "

	    dbUseArea(.T.,"TOPCONN",TCGENQRY(,,cSQL),'cAlias',.F.,.T.)

        if !cAlias->(Eof())
            cTable := 'BEC'  
            lret   := .t.
        else
             cTable := '' 
	    endif

        cAlias->(DBCLOSEAREA())
    endif 

return cTable


