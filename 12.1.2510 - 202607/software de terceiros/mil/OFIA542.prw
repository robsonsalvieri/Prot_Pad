#Include "TOTVS.CH"
#Include "FWMVCDEF.CH"
#Include "OFIA542.ch"

Static cBKPFil := cFilAnt

/*/{Protheus.doc} OFIA542 --------------------------------------------------------------------------
@type    function
@author  Lucas Brustolin
@since   30/09/2025
@version 1.0
@desc    Executa o processamento da importação de arquivos ESPPED para pedidos Scania.
         Carrega os parâmetros da Pergunte "OFIA542" com ou sem interface, valida os dados e
         dispara o processamento caso os dados estejam corretos.
@return  Logical (.T. se parâmetros validados e processamento disparado com sucesso)
---------------------------------------------------------------------------------------------------*/
Function OFIA542()

Local aArea    := FWGetArea()
Local lTela    := .F.
Local lOK      := .F.
Local aErros   := {}
Local cList    := ""
Local cMsg     := ""
Local nI       := 0

Private lSchedule := .F.
Private aMVPAR   := {}

Default MV_PAR01 := ""   // Diretório origem ESPPED (obrig.)
Default MV_PAR02 := ""   // Fornecedor Scania (obrig.)
Default MV_PAR03 := ""   // Loja do Fornecedor (obrig.)
Default MV_PAR04 := ""   // Condição de Pagamento (obrig.)
Default MV_PAR05 := ""   // Fórmula de Preço (obrig.)
Default MV_PAR06 := ""   // TES Inteligente (opcional)
Default MV_PAR07 := 1    // Ação pós-processo: 1=Nenhuma, 2=Mover, 3=Apagar
Default MV_PAR08 := ""   // Diretório destino (se MV_PAR07=2)


   // Chamada via Schedule
   lSchedule   := FWGetRunSchedule()
   lTela       := !IsBlind() // Tem Interface

   // Exibe Pergunte somente quando
   If ( !lSchedule .And. lTela)
      If !Pergunte("OFIA542", lTela /*Exibe Pergunta*/)
         FWRestArea(aArea)
         Return .F.
      EndIf
   EndIf 

   // Normalizações
   MV_PAR01 := AllTrim(MV_PAR01)
   MV_PAR08 := AllTrim(MV_PAR08)
   
   If !Empty(MV_PAR01) .and. !( Right(MV_PAR01,1) $ "\/" )
      MV_PAR01 += "\"
   EndIf

   If !Empty(MV_PAR08) .and. !( Right(MV_PAR08,1) $ "\/" )
      MV_PAR08 += "\"
   EndIf
   
   If ValType(MV_PAR07) == "C"
      MV_PAR07 := Val(MV_PAR07)
   EndIf


   If Empty(MV_PAR01)  ; aAdd(aErros, STR0001) ; EndIf // "- Diretório ESPPED (origem) é obrigatório."
   If !Empty(MV_PAR01) .and. !ExistDir(MV_PAR01) ; aAdd(aErros, STR0002 + MV_PAR01) ; EndIf // "- Diretório de origem não existe: "
   If Empty(MV_PAR02)  ; aAdd(aErros, STR0003) ; EndIf // "- Código do Fornecedor Scania é obrigatório."
   If Empty(MV_PAR03)  ; aAdd(aErros, STR0004) ; EndIf // "- Loja do Fornecedor Scania é obrigatória."
   If Empty(MV_PAR04)  ; aAdd(aErros, STR0005) ; EndIf // "- Condição de Pagamento é obrigatória."
   If Empty(MV_PAR05)  ; aAdd(aErros, STR0006) ; EndIf // "- Fórmula Preço de Reposição é obrigatória."

   Do Case
      Case MV_PAR07 == 1  // Nenhuma ação
         // ok
      Case MV_PAR07 == 2  // Mover

         If Empty(MV_PAR08)
            aAdd(aErros, STR0007) // "- Diretório de destino é obrigatório quando a ação for 'Mover Arquivo'."
         ElseIf !ExistDir(MV_PAR08)
            aAdd(aErros, STR0008 + MV_PAR08) // "- Diretório de destino não existe: "
         EndIf
      
      Case MV_PAR07 == 3  // Apagar
         // ok
      Otherwise
         aAdd(aErros, STR0009) // "- Ação pós-processamento inválida (use 1=Nenhuma, 2=Mover, 3=Apagar)."
   EndCase

   If Len(aErros) > 0
      // Monta lista amigável
      
      For nI := 1 To Len(aErros)
         cList += aErros[nI] + CRLF
      Next
      
      cMsg := STR0010 + CRLF + CRLF + STR0011 + CRLF + cList // "Validação de parâmetros – Importação ESPPED" # "Ajuste os itens abaixo antes de continuar:"
      FMX_HELP("OFIA542", cMsg, STR0012) // "Informe os campos obrigatórios e verifique os diretórios informados. Ação 2 (Mover): preencha um diretório de destino válido em 'Mover Para'."
      FWRestArea(aArea)
      Return .F.
   EndIf

   aMVPAR := { MV_PAR01, MV_PAR02, MV_PAR03, MV_PAR04, MV_PAR05, MV_PAR06, MV_PAR07, MV_PAR08 }

   If lSchedule
      Processa({|| lOK := OA542001N_ProcessaESPPED() }, STR0013) // "Processando importação ESPPED..."
   Else
      lOK := OA542001N_ProcessaESPPED()
   EndIf

   If !lOK
      FMX_HELP("OFIA542", STR0014, STR0015) // "Importação ESPPED finalizada com falhas." # "Consulte o log de processamento e corrija os arquivos inválidos."
   EndIf

FWRestArea(aArea)

Return( lOK )

/*/{Protheus.doc} SchedDef -------------------------------------------------------------------------
@type    static function
@author  Lucas Brustolin
@since   07/10/2025
@version 1.0
@desc    Define os parâmetros padrão utilizados pelo Scheduler (Job) para execução da rotina
         OFIA542 de forma automática (sem interface).
@return  Array com parâmetros esperados pelo agendamento (Pergunte, usuário, empresa, etc.)
---------------------------------------------------------------------------------------------------*/
Static Function SchedDef()
Local aParam := {;
	"P",;
	"OFIA542",;
	"",;
	"",;
	"" ;
	}
Return aParam

/*/{Protheus.doc} OC542002N_ValidPerg --------------------------------------------------------------
@type    function
@author  Lucas Brustolin
@since   07/10/2025
@version 1.0
@desc    Valida, em tempo de preenchimento, os parâmetros definidos na Pergunte "OFIA542".
         Realiza checagem da existência de diretórios e corrige automaticamente os caminhos
         informados quando inválidos.
@return  Logical (.T. se validações executadas com sucesso)
---------------------------------------------------------------------------------------------------*/
Function OC542002N_ValidPerg()

	Local lRet 		:= .T.

	If ReadVar() == 'MV_PAR01'

      MV_PAR01 := AllTrim(MV_PAR01) // Retira espaços vazios

		If !ExistDir(Alltrim(MV_PAR01),0,.F.)
			FMX_HELP("OC542002N", STR0002 , STR0001) // "- Diretório de origem não existe:" # "- Diretório ESPPED (origem) é obrigatório."
			MV_PAR01 := Alltrim(cGetFile( '', '', , "SERVIDOR", .T., GETF_RETDIRECTORY, .T., .T. )) // "- Diretório ESPPED (origem) é obrigatório."
		Endif
	EndIf

   // Diretório destino (se MV_PAR07=2)
	If ReadVar() == 'MV_PAR08' .and. MV_PAR07 == 2 //  1=Nenhuma, 2=Mover, 3=Apagar

      MV_PAR08 := AllTrim(MV_PAR08) // Retira espaços vazios

		If !ExistDir(Alltrim(MV_PAR08))
			FMX_HELP("OC542002N", STR0008, STR0007) // "- Diretório de destino não existe: " # "- Diretório de destino é obrigatório quando a ação for 'Mover Arquivo'."
			MV_PAR08 := Alltrim(cGetFile( '', '', , "SERVIDOR", .T., GETF_RETDIRECTORY, .T., .T. )) // 
		EndIF
	
	EndIf

Return lRet

/*/{Protheus.doc} OA542001N_ProcessaESPPED ---------------------------------------------------------
@type    static function
@author  Lucas Brustolin
@since   03/10/2025
@version 1.1
@desc    Controla o fluxo principal da importação ESPPED. Localiza arquivos no diretório
         informado, registra logs via DMS_Logger e dispara o processamento individual de cada
         arquivo por OA542002N_ProcessarArquivo().
@return  Logical (.T. se todos os arquivos foram processados com sucesso)
---------------------------------------------------------------------------------------------------*/
Static Function OA542001N_ProcessaESPPED()
   Local lOkProc    := .T.
   Local cDirOrig   := aMVPAR[1]          // diretório origem (ESPPED)
   Local cDirDest   := aMVPAR[8]          // diretório destino (quando mover)
   Local aFiles     := {}
   Local oLogger    := Nil
   Local cTblLogCod := ""

   /*-----------------------------------------------------------------------------------------------
      EXEMPLO DE LOG GERADO (TABELA VQL / COLUNA VQL_DADOS)
      Rotina: OFIA542 – Importação de Arquivos ESPPED (Pedidos Scania)
      Fonte: OA542001N_ProcessaESPPED / OA542002N_ProcessarArquivo
      Logger: DMS_Logger():LogToTable()

      A rotina registra cada etapa da execução na tabela de log (VQL), permitindo auditoria completa
      do processamento de arquivos ESPPED. Abaixo um exemplo real de saída capturada:

      ???????????????????????????????????????????????????????????????????????????????????????????????
      ? Iniciando importação ESPPED...                                                              ?
      ? Início: 24/10/2025 01:36:59 | Empresa: 99 | Filial: 01 | Usuário: 000000 | Modo: MENU       ?
      ? 1 de 3 = ARQUIVO1_ESPPED_02190103134501501.DAT -> Iniciando Leitura do arquivo.             ?
      ? Step 1.1 - Quantidade de Pedidos identificado no Arquivo: 1                                 ?
      ? Step 1.2 - Processando pedido | Filial=01 | PedidoScania=825528 | Emissao=20241231          ?
      ?             | Qtdade de Itens=4                                                             ?
      ? Step 2.0 - Pedido Scania:: 825528 incluído com sucesso | Gerou Pedido Compra: 987092        ?
      ? Step 3.0 - Pedido gerado foi vinculado na tabela VEI | Filial=01 | Marca=SC                 ?
      ?             | PedCompra=987092 | PedScania=825528                                           ?
      ? Step 4.0 - Processamento do arquivo foi concluído. Arquivo foi movido para:                 ?
      ?             \esspedido\ARQUIVO1_ESPPED_02190103134501501.DAT                                ?
      ?                                                                                             ?
      ? 2 de 3 = ARQUIVO2_ESPPED_02190103134501501.DAT -> Iniciando Leitura do arquivo.             ?
      ? Step 1.1 - Quantidade de Pedidos identificado no Arquivo: 1                                 ?
      ? Step 1.2 - Processando pedido | Filial=01 | PedidoScania=825529 | Emissao=20251031          ?
      ? Step 2.0 - Pedido Scania:: 825529 incluído com sucesso | Gerou Pedido Compra: 987093        ?
      ? Step 3.0 - Pedido gerado foi vinculado na tabela VEI | Filial=01 | Marca=SC                 ?
      ?             | PedCompra=987093 | PedScania=825529                                           ?
      ? Step 4.0 - Processamento do arquivo foi concluído. Arquivo foi movido para:                 ?
      ?             \esspedido\ARQUIVO2_ESPPED_02190103134501501.DAT                                ?
      ?                                                                                             ?
      ? 3 de 3 = ESPPED_02190103134501501.DAT -> Iniciando Leitura do arquivo.                      ?
      ? Step 1.1 - Quantidade de Pedidos identificado no Arquivo: 1                                 ?
      ? Step 1.2 - Processando pedido | Filial=01 | PedidoScania=825529 | Emissao=20251031          ?
      ? Step 2.0 - Pedido Scania já existente (VEI/SC7): 825529 -> SC7 987093                       ?
      ? Step 4.0 - Processamento do arquivo foi concluído. Arquivo foi movido para:                 ?
      ?             \esspedido\ESPPED_02190103134501501.DAT                                         ?
      ?                                                                                             ?
      ? Processamento finalizado com sucesso!                                                       ?
      ???????????????????????????????????????????????????????????????????????????????????????????????

      ?? Observações:
      - Todos os logs são gravados via oLogger:LogToTable() com o grupo "OFIA542".
      - Tipos de mensagem utilizados: INFO, WARN, ERRO, INI, FIM.
      - Os passos (Step 1.1 ? 4.0) refletem o ciclo completo:
         1. Leitura do arquivo (E01/E02)
         2. Inclusão de pedidos SC7 via ExecAuto (MATA120)
         3. Gravação de vínculo VEI?SC7
         4. Aplicação da pós-ação (Mover/Apagar)
      - O log final “Processamento finalizado com sucesso” é emitido após o fechamento do log pai.
   ------------------------------------------------------------------------------------------------*/
   // --- Logger principal desta execução ---
   oLogger    := DMS_Logger():New()
   cTblLogCod := oLogger:LogToTable({ ;
      {'VQL_AGROUP','OFIA542'}, ;
      {'VQL_TIPO'  ,'INI'    }, ;
      {'VQL_DADOS' ,'Iniciando importação ESPPED...'} ;
   })

   // --- Coleta de arquivos ---
   aFiles := Directory( AllTrim(cDirOrig) + IIf( Right(AllTrim(cDirOrig),1) $ "\/", "", "\" ) + "*.dat" )

   If Empty(aFiles)
      
      oLogger:LogToTable({ {'VQL_AGROUP'  ,'OFIA542'},;
                           {'VQL_TIPO'    ,'WARN'},;
                           {'VQL_DADOS'   ,'Nenhum arquivo .dat foi encontrado no diretório de origem: ' + cDirOrig },;
                           {'VQL_CODVQL'  , cTblLogCod} })


      FMX_HELP("OFIA542",  STR0016, ; // "Nenhum arquivo encontrado no diretório de origem.",
                           STR0017  ) // "Verifique o diretório informado na Pergunte e a disponibilidade de arquivos .dat"

   else

      // --- Processamento (com barra se houver interface) ---
      If !IsBlind()
         Processa({|| lOkProc := OA542002N_ProcessarArquivo(aFiles, oLogger, cTblLogCod, cDirOrig, cDirDest)},STR0018 )// "Processando arquivos ESPPED..."
      Else
         lOkProc := OA542002N_ProcessarArquivo(aFiles, oLogger, cTblLogCod, cDirOrig, cDirDest)
      EndIf

      OA542090K_RestauraFilial()

   endif

   // --- Encerramento do log principal ---
   oLogger:LogToTable({ {'VQL_AGROUP'  ,'OFIA542'},;
                        {'VQL_TIPO'    ,'FIM'},;
                        {'VQL_DADOS'   ,'Processamento finalizado com ' + IIF(lOkProc,'sucesso!.','erro!') },;
                        {'VQL_CODVQL'  , cTblLogCod} })

   oLogger:CloseOpened(cTblLogCod)

Return lOkProc

/*/{Protheus.doc} OA542002N_ProcessarArquivo -------------------------------------------------------
@type    static function
@author  Lucas Brustolin
@since   04/10/2025
@version 1.0
@desc    Processa uma lista de arquivos ESPPED (.DAT) executando as etapas:
         - Leitura do arquivo (E01/E02)
         - Criação/verificação de vínculo VEI?SC7
         - Inclusão do pedido de compra via MSExecAuto (MATA120)
            -- Chama rotina para realizar o vinculo do pedido com a tabela VEI
         - Aplicação de pós-ação (mover/apagar)
@param   aFiles     Array   - Lista de arquivos obtidos via Directory()
@param   oLogger    Object  - Instância de DMS_Logger()
@param   cTblLogCod Char    - Código de log principal (VQL)
@param   cDirOrig   Char    - Diretório origem dos arquivos
@param   cDirDest   Char    - Diretório destino (quando ação = mover)
@return  Logical (.T. se processamento concluído com sucesso)
---------------------------------------------------------------------------------------------------*/
Static Function OA542002N_ProcessarArquivo(aFiles, oLogger, cTblLogCod, cDirOrig, cDirDest)
   Local aArea     := GetArea()
   Local nI        := 0
   Local cFullPath := ""
   Local cName     := ""
   Local lTela     := !IsBlind()
   Local lOk       := .T.
   Local cSepOrig  := IIf( Right(AllTrim(cDirOrig),1) $ "\/", "", Chr(92) )
   Local aDoc      := {}
   Local aDocs     := {}
   Local nDoc      := 0
   Local cFilDoc   := ""
   Local cPedScania   := ""
   Local dEmiDoc   := Ctod("")
   Local aItensDoc := {}
   Local aChk      := {}
   Local lJaExiste := .F.
   Local cC7Num    := ""
   Local lSkip     := .F.
   Local cModo     := ""
   Local aRet      := {}
   Local lOkEA     := .F.
   
   Private nTotFiles  := 0
   Private nFileProc  := 0 

   If ( lTela )
      ProcRegua(Len(aFiles))
   EndIf

   // Contexto de execução (útil para auditoria de parsing)
   cModo := IIf(FWGetRunSchedule(), "AUTOMÁTICO (Schedule)", "MENU")
   cModo := ( "Início: " + DToC(Date()) + " " + Time() + ;
            " | Empresa: " + FWcodEmp() + ;
            " | Filial: " + FWxFilial("SC7") + ;
            " | Usuário: " + __cUserID + ;
            " | Modo: " + cModo )

   oLogger:LogToTable({ {'VQL_AGROUP'  ,'OFIA542'},;
                        {'VQL_TIPO'    ,'INFO'},;
                        {'VQL_DADOS'   , cModo},;
                        {'VQL_CODVQL'  , cTblLogCod} })

   nTotFiles := Len(aFiles)

   For nI := 1 To nTotFiles
      cName     := aFiles[nI][1]
      cFullPath := AllTrim(cDirOrig) + cSepOrig + cName
      nFileProc := nI

      If ( lTela )
         IncProc(STR0019 + cName + " | " + cValToChar(nFileProc) +  STR0020 + cValToChar(nTotFiles) ) // "Lendo arquivo: " # " de "
      EndIf

      // Flag para evitar LOOP dentro do SEQUENCE
      lSkip := .F.

      // ------------------------------------------------------------------
      // 1) Leitura e parsing do ESPPED (.DAT) 
      //    [Próxima entrega] Implementar parser conforme Layout_ESPPED.xls
      //    -> carregar filial, data, itens, quantidades, num. pedido Scania
      // ? aDocs = { { cFil, cPedScania, dEmissao, aItens }, ... }
      // ------------------------------------------------------------------
      aDocs := OA542010N_LerEInterpretarESPPED(cFullPath, oLogger, cTblLogCod)

      If Empty(aDocs)
         lOk   := .F.
         lSkip := .T.
         oLogger:LogToTable({ {'VQL_AGROUP'  , 'OFIA542'},;
                              {'VQL_TIPO'    , 'WARN'},;
                              {'VQL_DADOS'   , 'Step 1.1 - Leitura do arquivo não retornou pedidos: ' + cName},;
                              {'VQL_CODVQL'  , cTblLogCod} })

      EndIf

      // Loga resumo de CADA pedido identificado no arquivo
      For nDoc := 1 To Len(aDocs)

         aDoc        := aDocs[nDoc]
         cFilDoc     := aDoc[1]
         cPedScania  := aDoc[2]
         dEmiDoc     := aDoc[3]
         aItensDoc   := aDoc[4]

         OA542080K_SetaFilialProcessamento(cFilDoc)

         If ValType(aItensDoc) != "A" .or. Len(aItensDoc) == 0
            oLogger:LogToTable({ {'VQL_AGROUP','OFIA542'},;
                                 {'VQL_TIPO'  ,'WARN'},;
                                 {'VQL_DADOS' , 'Step 1.2 - Pedido ignorado (sem itens) | PedScania=' + cPedScania + ' | Arquivo=' + cName},;
                                 {'VQL_CODVQL', cTblLogCod} })
            Loop 
         EndIf 


         oLogger:LogToTable({ ;
            {'VQL_AGROUP','OFIA542'}, ;
            {'VQL_TIPO'  ,'INFO'   }, ;
            {'VQL_DADOS' , 'Step 1.2 - Processando pedido' +;
                           ' | Filial=' + IIf(Empty(cFilDoc), FWxFilial('SC7'), cFilDoc) + ;
                           ' | PedidoScania=' + cPedScania + ;
                           ' | Emissao=' + IIf(Empty(dEmiDoc), '', DToS(dEmiDoc)) + ;
                           ' | Qtdade de Itens=' + cValToChar(Len(aItensDoc)) }, ;
            {'VQL_CODVQL', cTblLogCod} ;
         })

         // ------------------------------------------------------------------
         // 2) Verificação se já existe VEI?SC7 p/ o pedido do arquivo
         //    [Próxima entrega] Checar em VEI a relação com SC7
         // ------------------------------------------------------------------
         aChk      := OA542030N_ExistePedidoVEI(cPedScania, IIf(Empty(cFilDoc), FWxFilial('SC7'), cFilDoc))
         lJaExiste := aChk[1]
         cC7Num    := aChk[2]

         If lJaExiste
            oLogger:LogToTable({ ;
               {'VQL_AGROUP'  , 'OFIA542'}, ;
               {'VQL_TIPO'    , 'WARN'   }, ;
               {'VQL_DADOS'   , 'Step 2 - Pedido Scania ja existente (VEI/SC7): ' + cPedScania + ' -> SC7 ' + cC7Num }, ;
               {'VQL_CODVQL'  , cTblLogCod} ;
            })

         Else
            // ------------------------------------------------------------------
            // 3) Se não existir, montar aCab/aItem e chamar MSExecAuto (MATA120)
            //    [Próxima entrega] Usar MV_PAR02..MV_PAR06 e dados do arquivo
            // ------------------------------------------------------------------
            aRet   := OA542040N_CriarPedidoSC7(aDoc, oLogger, cTblLogCod)
            lOkEA  := aRet[1]
            cC7Num := aRet[2]

            // Opcional: considerar como já existente para decisões subsequentes
            If lOkEA
               lJaExiste := .T.
            EndIf            
         EndIf
      Next
      // ------------------------------------------------------------------
      // 4) Pós-ação (conforme MV_PAR07): 1=Nada, 2=Mover (cDirDest), 3=Apagar
      //     Aplica a ação uma única vez por ARQUIVO processado
      //     (somente se não houve BREAK por parsing vazio)
      // ------------------------------------------------------------------
      If !lSkip
         Do Case
            Case aMVPAR[7] == 2   // Mover para cDirDest
               OA542050N_PosAcaoArquivo(cFullPath, cDirDest, 2, oLogger, cTblLogCod)

            Case aMVPAR[7] == 3   // Apagar arquivo
               OA542050N_PosAcaoArquivo(cFullPath, "", 3, oLogger, cTblLogCod)

         EndCase
      EndIf

      // Se foi marcado para pular, apenas segue ao próximo arquivo
      If lSkip
         // noop
      EndIf
   Next

RestArea(aArea)
Return lOk

/*/{Protheus.doc} OA542010N_LerEInterpretarESPPED --------------------------------------------------
@type    static function
@author  Lucas Brustolin
@since   08/10/2025
@version 1.3
@desc    Lê e interpreta o conteúdo do arquivo ESPPED (.DAT) utilizando FWFileReader.
         Realiza tokenização de segmentos (E01/E02), monta estrutura de documentos e retorna
         array contendo os pedidos identificados.
@param   cFullPath   Char   - Caminho completo do arquivo .DAT
@param   oLogger     Object - Instância DMS_Logger() para registro de log
@param   cTblLogCod  Char   - Código VQL do log principal
@return  Array { { cFil, cPedScania, dEmissao, aItens } }
---------------------------------------------------------------------------------------------------*/
Static Function OA542010N_LerEInterpretarESPPED(cFullPath, oLogger, cTblLogCod)
   Local aDocs       := {}
   Local cFil        := ""
   Local cPedScania  := ""
   Local dEmissao    := Ctod("")
   Local aItens      := {}
   Local cLine       := ""
   Local nLin        := 0
   Local aTok        := {}
   Local cSeg        := ""
   Local lTemDoc     := .F.
   Local cNomeArq    := OA542051N_GetFileName(cFullPath)
   Local oFile       := FWFileReader():New(cFullPath)  
   Local cCompPed    := iif( GetNewPar("MV_PEDANO","N") == "S", "/" + Right(Alltrim(Str(Year(DDATABASE),4)),2), "" )

      oLogger:LogToTable({    {'VQL_AGROUP'  , 'OFIA542'},;
                              {'VQL_TIPO'    , 'INFO'},;
                              {'VQL_DADOS'   , cValToChar(nFileProc) +  STR0020 + cValToChar(nTotFiles) + ' = ' + cNomeArq + STR0021 },; // " de " ### ' -> Iniciando Leitura do aquivo.' 
                              {'VQL_CODVQL'  , cTblLogCod} })

      If oFile:Open()
         While oFile:HasLine()
            cLine := AllTrim(oFile:GetLine())
            nLin++
            If Empty(cLine)
               Loop
            EndIf

            // Tokenização padrão (CSV por vírgula). Ajustável se necessário.
            aTok := StrTokArr(cLine, ",")
            AEval(aTok, {|x,i| aTok[i] := OA542023N_TrimUnquote(AllTrim(x)) })            
            If Len(aTok) > 0 

               cSeg := Upper(AllTrim(aTok[1]))

               Do Case
               Case cSeg == "UNH" .OR. cSeg == "BGM" .OR. cSeg == "UNT"
                  // Segmentos de controle — ignorados

               Case cSeg == "E01"
                  // Se já havia um documento em construção, fecha e adiciona ao array
                  If lTemDoc
                     AAdd(aDocs, { cFil, cPedScania, dEmissao, aItens })
                  EndIf
                  // Inicia novo documento
                  cFil        := ""
                  cPedScania  := ""
                  dEmissao    := Ctod("")
                  aItens      := {}
                  lTemDoc     := .T.
                  // Parse do cabeçalho
                  OA542011N_ParseHeader_E01(aTok, @cFil, @cPedScania, @dEmissao, oLogger, cCompPed)

               Case cSeg == "E02"
                  // Adiciona item ao documento atual (se houver E01 iniciado)
                  If lTemDoc
                     AAdd(aItens, OA542012N_ParseItem_E02(aTok))
                  Else
                     // E02 sem E01: loga aviso e ignora
                     oLogger:LogToTable({ {'VQL_AGROUP'  , 'OFIA542'},;
                                          {'VQL_TIPO'    , 'WARN'},;
                                          {'VQL_DADOS'   , 'Step 1.1 - E02 sem E01 (ignorado) na linha ' + cValToChar(nLin)},;
                                          {'VQL_CODVQL'  , cTblLogCod} })

                  EndIf

               Otherwise
                  // Segmento desconhecido — registra e segue
                  oLogger:LogToTable({ {'VQL_AGROUP'  , 'OFIA542'},;
                                       {'VQL_TIPO'    , 'WARN'},;
                                       {'VQL_DADOS'   , 'Step 1.1 - Linha ' + cValToChar(nLin) + ' ignorada: segmento ' + cSeg},;
                                       {'VQL_CODVQL'  , cTblLogCod} })
               EndCase
            Endif 
         EndDo
      Else 
         oLogger:LogToTable({ {'VQL_AGROUP'  , 'OFIA542'},;
                              {'VQL_TIPO'    , 'ERRO'},;
                              {'VQL_DADOS'   , 'ERROR Step 1.1 - Falha na tentar abrir arquivo arquivo: ' + cNomeArq },;
                              {'VQL_CODVQL'  , cTblLogCod} })
      EndIf 
      oFile:Close()

      // Fecha o último documento, se houver
      If lTemDoc
         AAdd(aDocs, { cFil, cPedScania, dEmissao, aItens })
      EndIf

      oLogger:LogToTable({ {'VQL_AGROUP'  , 'OFIA542'},;
                           {'VQL_TIPO'    , 'INFO'},;
                           {'VQL_DADOS'   , 'Step 1.1 - Quantidade de Pedidos identificado no Arquivo: '+ cValToChar(Len(aDocs))  },;
                           {'VQL_CODVQL'  , cTblLogCod} })

Return aDocs

/*/{Protheus.doc} OA542011N_ParseHeader_E01 --------------------------------------------------------
@type    static function
@author  Lucas Brustolin
@since   08/10/2025
@version 1.2
@desc    Interpreta o segmento E01 (cabeçalho do pedido) e preenche variáveis de
         filial, pedido Scania e data de emissão.
@param   aTok     Array   - Tokens do segmento E01
@param   cFilRef  ByRef   - Retorna filial do pedido
@param   cPedRef  ByRef   - Retorna número do pedido Scania
@param   dEmisRef ByRef   - Retorna data de emissão
@param   oLogger  Object  - Instância DMS_Logger()
@return  Nil
---------------------------------------------------------------------------------------------------*/
Static Function OA542011N_ParseHeader_E01(aTok, cFilRef, cPedRef, dEmisRef, oLogger, cCompPed)

   Local cCodConc := IIf(Len(aTok)>=2, aTok[2], "")
   Local cNumPed  := IIf(Len(aTok)>=3, aTok[3], "")
   Local cData    := IIf(Len(aTok)>=5, aTok[5], "")

   Local cFil   := OA542019N_DeParaFilialPorConcess(cCodConc)
   Local dEmiss := OA542020N_ParseDataDDMMAAAA(cData)

   cPedRef  := iif( ! empty( cNumPed ), cNumPed + cCompPed, cNumPed )
   cFilRef  := cFil
   dEmisRef := dEmiss

Return()

/*/{Protheus.doc} OA542012N_ParseItem_E02 ----------------------------------------------------------
@type    static function
@author  Lucas Brustolin
@since   08/10/2025
@version 1.0
@desc    Interpreta o segmento E02 (item do pedido) retornando o código do item e a
         quantidade solicitada.
@param   aTok Array - Tokens do segmento E02
@return  Array { cB1CodIte, nQtd }
---------------------------------------------------------------------------------------------------*/
Static Function OA542012N_ParseItem_E02(aTok)

   Local cB1CodIte := IIf(Len(aTok)>=2, aTok[2], "")
   Local cQtd      := IIf(Len(aTok)>=3, aTok[3], "")
   Local nQtd      := OA542021N_ToNum(cQtd)

Return { cB1CodIte, nQtd }

/*/{Protheus.doc} OA542019N_DeParaFilialPorConcess -------------------------------------------------
@type    function
@author  Lucas Brustolin
@since   09/10/2025
@version 1.1
@desc    Retorna a filial SC7 correspondente a um código de concessionária (VE4_CODCON),
         buscando em VE4. Caso não encontrado, retorna FWxFilial('SC7').
@param   cCodConc Char - Código da concessionária (VE4_CODCON)
@return  Char - Código da filial resultante
---------------------------------------------------------------------------------------------------*/
Function OA542019N_DeParaFilialPorConcess(cCodConc)

   Local cRet        := FWxFilial("SC7")
   Local lAchou      := .F.
   Local oDMS_FilialHelper := DMS_FilialHelper():New()

   If Empty(cCodConc)
      Return cRet
   Else 
      cCodConc := AllTrim(cCodConc) 
   EndIf

   If !Empty(cRet := oDMS_FilialHelper:ObterFilialPorConcessionaria(cCodConc))
      lAchou := .T.
   Endif
   

Return IIf(lAchou, cRet, FWxFilial("SC7"))

/*/{Protheus.doc} OA542020N_ParseDataDDMMAAAA ------------------------------------------------------
@type    static function
@author  Lucas Brustolin
@since   08/10/2025
@version 1.0
@desc    Converte uma string no formato DDMMAAAA em data AdvPL.
@param   cData Char - Data no formato DDMMAAAA
@return  Date - Valor convertido ou Ctod("") se inválido
---------------------------------------------------------------------------------------------------*/
Static Function OA542020N_ParseDataDDMMAAAA(cData)
   
   Local cTxt := AllTrim(cData)
   Local cY := "", cM := "", cD := ""

   If Len(cTxt) >= 8
      cD := SubStr(cTxt, 1, 2)
      cM := SubStr(cTxt, 3, 2)
      cY := SubStr(cTxt, 5, 4)
      Return StoD(cY + cM + cD)
   EndIf

Return Ctod("")

/*/{Protheus.doc} OA542021N_ToNum ------------------------------------------------------------------
@type    static function
@author  Lucas Brustolin
@since   08/10/2025
@version 1.0
@desc    Converte string numérica para número, tratando formatos mistos
         (ex.: '1.234,56', '1234,56', '1234.56').
@param   cNum Char - Valor numérico em texto
@return  Numeric - Valor convertido
---------------------------------------------------------------------------------------------------*/
Static Function OA542021N_ToNum(cNum)

   Local cTxt := AllTrim(cNum)

   If ( "," $ cTxt ) .AND. ( "." $ cTxt )
      cTxt := StrTran(cTxt, ".", "")
      cTxt := StrTran(cTxt, ",", ".")
   ElseIf ( "," $ cTxt )
      cTxt := StrTran(cTxt, ",", ".")
   EndIf
   If Empty(cTxt)
      Return 0
   EndIf

Return Val(cTxt)

/*/{Protheus.doc} OA542023N_TrimUnquote ------------------------------------------------------------
@type    static function
@author  Lucas Brustolin
@since   08/10/2025
@version 1.0
@desc    Remove aspas simples ou duplas e espaços laterais de uma string.
@param   cTxt Char - Texto de entrada
@return  Char - Valor tratado (sem aspas e trimado)
---------------------------------------------------------------------------------------------------*/
Static Function OA542023N_TrimUnquote(cTxt)

   Local cVal := AllTrim(cTxt)

   If Len(cVal) >= 2
      If ( SubStr(cVal, 1, 1) $ ( "'" + Chr(34) ) ) .AND. ;
         ( SubStr(cVal, Len(cVal), 1) $ ( "'" + Chr(34) ) )
         cVal := SubStr(cVal, 2, Len(cVal) - 2)
      EndIf
   EndIf

Return AllTrim(cVal)

/*/{Protheus.doc} OA542030N_ExistePedidoVEI --------------------------------------------------------
@type    static function
@author  Lucas Brustolin
@since   09/10/2025
@version 1.0
@desc    Verifica se o pedido Scania (VEI_PEDFAB) já está vinculado a algum SC7
         na tabela VEI (índice 2 = VEI_FILIAL+VEI_CODMAR+VEI_PEDFAB).
@param   cPedScania Char - Nº do pedido Scania (arquivo)
@param   cFilDoc    Char - Filial do pedido
@return  Array { lExiste, cSC7 } - Verdadeiro se o vínculo existir
---------------------------------------------------------------------------------------------------*/
Static Function OA542030N_ExistePedidoVEI(cPedScania, cFilDoc)
   
   Local aArea    := GetArea()
   Local nLenMar  := TamSX3("VEI_CODMAR")[1]
   Local nLenPed  := TamSX3("VEI_PEDFAB")[1] 
   Local cPed     := PADR(cPedScania, nLenPed)
   Local cMar     := PADR(OC540009K_CodMarcaVEI(), nLenMar)
   Local cKey     := ""
   Local lVinc    := .F.
   Local cSC7     := ""

   If Empty(cPed)
      Return { .F., "" }
   EndIf

   // VEI: ORDEM 2 = VEI_FILIAL+VEI_CODMAR+VEI_PEDFAB
   dbSelectArea("VEI")
   dbSetOrder(2)

   cKey  := cFilDoc + cMar + PADR(cPed, nLenPed)
   lVinc :=  VEI->( DbSeek(cKey) )
     
   If  ( lVinc )
      cSC7 := VEI->VEI_NUM
   EndIf

   VEI->(dbCloseArea())


RestArea(aArea)

Return { lVinc, cSC7 }

/*/{Protheus.doc} OA542040N_CriarPedidoSC7 ---------------------------------------------------------
@type    static function
@author  Lucas Brustolin
@since   10/10/2025
@version 1.0
@desc    Cria um pedido de compra (SC7) via MSExecAuto (MATA120) com base nos dados
         do arquivo ESPPED (E01/E02). Após inclusão, grava vínculo correspondente
         na tabela VEI.
@param   aDoc       Array  - Documento no formato { cFil, cPedScania, dEmissao, aItens }
@param   oLogger    Object - Instância DMS_Logger()
@param   cTblLogCod Char   - Código de log principal
@return  Array { lOk, cNumC7, lVEIOk, cPedScania }
---------------------------------------------------------------------------------------------------*/
Static Function OA542040N_CriarPedidoSC7(aDoc, oLogger, cTblLogCod)
   Local aArea       := GetArea()
   Local cFilDoc     := aDoc[1]
   Local cPedScania     := aDoc[2]
   Local dEmiDoc     := aDoc[3]
   Local aItensDoc   := aDoc[4]
   Local cFilEA      := IIf( Empty(cFilDoc), FWxFilial("SC7"), cFilDoc )
   Local aCabEA      := {}
   Local aItensEA    := {}
   Local aItEA       := {}
   Local nIt         := 0
   Local nQtdade     := 0
   Local cNumC7      := ""
   Local dEmisEA     := IIf( Empty(dEmiDoc), Date(), dEmiDoc )
	Local aLogAuto	   := {} 
   Local nLog		   := 0  
   Local cLogAuto		:= ""  
   local cItem       := StrZero(0,FWTamSX3("C7_ITEM")[1])
   Local cTes        := ""
   Local cFornecedor := ""
   Local cLojaForn   := ""
   Local lSC7Ok      := .F.
   Local lVEIOk      := .F.
   Local cErrorVEI   := "" 
   Local aRet        := {}

	Private lMSHelpAuto     := .T.
	Private lAutoErrNoFile  := .F.
	Private lMsErroAuto     := .F.

   // ------------------------------------------------------------------------
   // FAZ INCLUSAO DO PEDIDO DE COMPRA A PARTIR DO(s) ARQUIVO(s) .DAT (SCANIA)
   // ------------------------------------------------------------------------
   Pergunte("OFIA542", .F. )
   cFornecedor := PadR( aMVPAR[2], TamSx3("A2_COD")[1] )
   cLojaForn   := PadR( aMVPAR[3], TamSx3("A2_LOJA")[1] )

   cFornecedor := Posicione("SA2", 1, xFilial("SA2") + cFornecedor + cLojaForn , "A2_COD" )
   cLojaForn   := SA2->A2_LOJA

   // --- Cabeçalho SC7 ---
   AAdd(aCabEA, { "C7_FILIAL" , cFilEA                , Nil }) // Filial Pedido
   AAdd(aCabEA, { "C7_TIPO"   , "N"                   , Nil }) // Tipo pedido N Normal
   AAdd(aCabEA, { "C7_EMISSAO", dEmisEA               , Nil }) // Emissão do pedido
   AAdd(aCabEA, { "C7_FORNECE", cFornecedor           , Nil }) // Fornecedor
   AAdd(aCabEA, { "C7_LOJA"   , cLojaForn             , Nil }) // Loja
   AAdd(aCabEA, { "C7_COND"   , aMVPAR[4]             , Nil }) // Condição Pagto
   AAdd(aCabEA, { "C7_ORIGEM" , "OFIA542"             , Nil }) // Rotina Geradora 
   AAdd(aCabEA, { "C7_PEDFAB" , cPedScania            , Nil }) // Pedido Fabrica  Scania
   
   For nIt := 1 To Len(aItensDoc)
      aItEA := {}
      cItem := Soma1(cItem)
      
      cProduto := OA542070N_GetB1CodByCodIte( aItensDoc[nIt][1] )
      SB1->(DBSetOrder(1))
      SB1->(DBSeek(xFilial("SB1")+ cProduto))
      SB5->(DBSetOrder(1))
      SB5->(DBSeek(xFilial("SB5")+ SB1->B1_COD))

      nQtdade  := aItensDoc[nIt][2]
      
      AAdd(aItEA, { "C7_ITEM"    , cItem                    , Nil }) // Unidade de medida
      AAdd(aItEA, { "C7_PRODUTO" , cProduto                 , Nil }) // B1_CODITE
      AAdd(aItEA, { "C7_UM"      , SB1->B1_UM               , Nil }) // B1_UM
      AAdd(aItEA, { "C7_QUANT"   , nQtdade                  , Nil }) // Quantidade item
      AAdd(aItEA, { "C7_PRECO"   , FG_FORMULA(aMVPAR[5])    , Nil }) // Preço 
      AAdd(aItEA, { "C7_DATPRF"  , dDatabase                , Nil }) // Data Entrega

      // TES Inteligente (opcional)
      If !Empty(aMVPAR[6])
         cTes     := MaTesInt(1,AllTrim(aMVPAR[6]),cFornecedor,cLojaForn,"F",cProduto)
         If !Empty(cTes)
            AAdd(aItEA, { "C7_TES", cTes                       , Nil  })
         EndIf 
      EndIf

      AAdd(aItEA, { "C7_FLUXO"   , "S"                                     , Nil }) // Fluxo de Caixa (S/N)
      AAdd(aItEA, { "C7_LOCAL"   , FM_PRODSBZ(cProduto,"SB1->B1_LOCPAD")   , Nil }) // Local estoque
      AAdd(aItEA, { "C7_PENDEN"  , "N"                                     , Nil }) // Pendente (S/N)

      AAdd(aItensEA, aItEA)
   Next

   lMsErroAuto := .F.
	nModulo     := 2 // compras
	SetFunName("OFIA542")   

   Begin Transaction

   // --- ExecAuto: MATA120 ---
   MSExecAuto({|v,x,y,z| MATA120(v,x,y,z)},1,aCabEA,aItensEA,3)

   // nº do SC7 (por segurança, obtém pelo C7_PEDCLI)
   If lMsErroAuto
      
		aLogAuto := GetAutoGRLog()
		For nLog := 1 To Len(aLogAuto)
			cLogAuto += aLogAuto[nLog] + CRLF
		Next
      AutoGRLog(cLogAuto)
      MostraErro()

   Else
      lSC7Ok := .T.
      cNumC7 := SC7->C7_NUM

      // ------------------------------------------------------------------------
      // VINCULA PEDIDO COMPRA A TABELA VEI - Arquivo Pedido de Peça Complemento
      // ------------------------------------------------------------------------
      aRet  := OA542060N_GravaOuAtualizaVEI( cFilEA, cNumC7, cPedScania, oLogger, cTblLogCod )
      lVEIOk      := aRet[1]
      cErrorVEI   := aRet[2]

      If ( !lVEIOk )
         DisarmTransacion()
      EndIf 
   EndIf

   End Transaction

   If ( lSC7Ok ) 
      // ------------------------------------------------
      // LOG SUCESSO INCLUSAO SC7 PEDIDO DE COMPRA
      // ------------------------------------------------
      If ValType(oLogger) == "O"
         oLogger:LogToTable({ ;
         {'VQL_AGROUP'  , 'OFIA542'}, ;
         {'VQL_TIPO'    , 'INFO'   }, ;
         {'VQL_DADOS'   , 'Step 2.0 - Pedido Scania:: '+  cPedScania + ' incluído com sucesso | Gerou Pedido Compra: ' + cNumC7 }, ;
         {'VQL_CODVQL'  , cTblLogCod} })
      EndIf 

      // ------------------------------------------------------------
      // LOG SUCESSO INCLUSAO VEI VINCULO PED. COMPRA X PEDIDO SCANIA
      // -------------------------------------------------------------
      If ( lVEIOk )
         oLogger:LogToTable({ ;
            {'VQL_AGROUP','OFIA542'}, ;
            {'VQL_TIPO'  ,'INFO'}, ;
            {'VQL_DADOS' , 'Step 3.0 - Pedido gerado foi vinculado na tabela VEI' + ;
                           ' | Filial=' + AllTrim(cFilEA) + ;
                           ' | Marca=SC' + ;
                           ' | PedCompra=' + AllTrim(cNumC7) + ;
                           ' | PedScania=' + AllTrim(cPedScania)}, ;
            {'VQL_CODVQL', cTblLogCod} ;
         })
      Else 
         // ------------------------------------------------
         // LOG ERROR AO VINULAR PEDIDO SC7 X VEI 
         // ------------------------------------------------      
         oLogger:LogToTable({ ;
            {'VQL_AGROUP','OFIA542'}, ;
            {'VQL_TIPO'  ,'ERRO'}, ;
            {'VQL_DADOS' , 'Step 3.0 - Falha na gravação do vínculo do pedido de compra com a tabela VEI. | Detalhe em VQL_MSGLOG ' }, ;
            {'VQL_MSGLOG', cErrorVEI }, ;
            {'VQL_CODVQL', cTblLogCod} ;
         })      

         oLogger:LogToTable({ ;
            {'VQL_AGROUP','OFIA542'}, ;
            {'VQL_TIPO'  ,'WARN'}, ;
            {'VQL_DADOS' , 'Step 3.1 - Rollback > Pedido Compra ' + cNumC7 + ' descartado (Cancelado) pela falha ocorrida ao gravar o vínculo com a VEI.' }, ;
            {'VQL_MSGLOG', cErrorVEI }, ;
            {'VQL_CODVQL', cTblLogCod} ;
         })  

      EndIf 

   Else 
      // ------------------------------------------------
      // LOG ERROR AO INCLIUIR SC7 PEDIDO DE COMPRA
      // ------------------------------------------------
      If ValType(oLogger) == "O"
         oLogger:LogToTable({ ;
            {'VQL_AGROUP','OFIA542'}, ;
            {'VQL_TIPO'  ,'ERRO'   }, ;
            {'VQL_DADOS' , 'ERRO Step 2.0 - Falha ao criar Pedido Scania: '+ cPedScania +' via MSExecAuto. | Detalhe em VQL_MSGLOG  ' }, ;
            {'VQL_MSGLOG', cLogAuto }, ;
            {'VQL_CODVQL', cTblLogCod} ;
         })
      EndIf
   EndIf 

RestArea(aArea)

Return { lSC7Ok, cNumC7, lVEIOk, cPedScania }

/*/{Protheus.doc} OA542050N_PosAcaoArquivo ---------------------------------------------------------
@type    static function
@author  Lucas Brustolin
@since   11/10/2025
@version 1.0
@desc    Aplica a ação de pós-processamento por arquivo:
         - 2=Mover para diretório destino
         - 3=Apagar arquivo de origem
         Registra logs de sucesso ou erro via DMS_Logger().
@param   cSrc       Char   - Caminho completo do arquivo origem
@param   cDirDest   Char   - Diretório destino (quando ação = mover)
@param   nAcao      Numeric- Código da ação (2=Mover, 3=Apagar)
@param   oLogger    Object - Instância DMS_Logger()
@param   cTblLogCod Char   - Código de log principal (VQL)
@return  Logical (.T. se a ação foi executada com sucesso)
---------------------------------------------------------------------------------------------------*/
Static Function OA542050N_PosAcaoArquivo(cSrc, cDirDest, nAcao, oLogger, cTblLogCod)
   Local lOK      := .T.
   Local cDest    := ""
   Local cNome    := ""
   Local cSep     := IIf(Right(AllTrim(cDirDest),1) $ "\/", "", Chr(92))

   cNome := OA542051N_GetFileName(cSrc)

   Do Case
   Case nAcao == 2  // Mover
      If Empty(AllTrim(cDirDest)) .or. !ExistDir(cDirDest)
         lOK := .F.

         oLogger:LogToTable({ ;
            {'VQL_AGROUP','OFIA542'}, ;
            {'VQL_TIPO'  ,'ERRO'   }, ;
            {'VQL_DADOS' , 'ERROR Step 4.0 - Diretório de destino sem permissão de escrita: ' + AllTrim(cDirDest) }, ; // "Diretório de destino sem permissão de escrita: "
            {'VQL_CODVQL', cTblLogCod} ;
         })

      Else
         cDest := AllTrim(cDirDest) + cSep + cNome
         // Move = copia + apaga origem (compatível entre volumes)
         If !__CopyFile(cSrc, cDest)
            lOK := .F.

            oLogger:LogToTable({ ;
               {'VQL_AGROUP','OFIA542'}, ;
               {'VQL_TIPO'  ,'ERRO'   }, ;
               {'VQL_DADOS' , "ERROR Step 4.0 - Falha ao copiar arquivo para: " + cDest }, ;
               {'VQL_CODVQL', cTblLogCod} ;
            })

         Else
            // tenta remover a origem após copiar
            If File(cSrc)
               FErase(cSrc)
            EndIf

            If File(cSrc)
               lOK := .F.
               oLogger:LogToTable({ ;
                  {'VQL_AGROUP','OFIA542'}, ;
                  {'VQL_TIPO'  ,'ERRO'   }, ;
                  {'VQL_DADOS' , "ERROR Step 4.0 - Falha ao remover arquivo de origem após copiar: " + cSrc }, ;
                  {'VQL_CODVQL', cTblLogCod} ;
               })
               
            Else
               oLogger:LogToTable({ ;
                  {'VQL_AGROUP','OFIA542'}, ;
                  {'VQL_TIPO'  ,'INFO'   }, ;
                  {'VQL_DADOS' , 'Step 4.0 - Processamento do arquivo foi concluído. Arquivo foi movido para: ' + cDest }, ;  // "Pós-processamento aplicado: mover arquivo." / "Arquivo movido para: "
                  {'VQL_CODVQL', cTblLogCod} ;
               })
               
            EndIf
         EndIf
      EndIf

   Case nAcao == 3  // Apagar
      If File(cSrc)
         FErase(cSrc)
      EndIf

      If File(cSrc)
         lOK := .F.
         oLogger:LogToTable({ ;
            {'VQL_AGROUP','OFIA542'}, ;
            {'VQL_TIPO'  ,'ERRO'   }, ;
            {'VQL_DADOS' , "ERROR Step 4.0 - Falha ao apagar arquivo: " + cSrc }, ;
            {'VQL_CODVQL', cTblLogCod} ;
         })

      Else
         oLogger:LogToTable({ ;
            {'VQL_AGROUP','OFIA542'}, ;
            {'VQL_TIPO'  ,'INFO'   }, ;
            {'VQL_DADOS' , 'Step 4.0 - Processamento do arquivo foi concluído. Arquivo foi apagado da origem. ' + cSrc }, ; // "Pós-processamento aplicado: apagar arquivo." / "Arquivo removido: "
            {'VQL_CODVQL', cTblLogCod} ;
         })
      EndIf

   Otherwise
      // Nenhuma ação
   EndCase

Return lOK

/*/{Protheus.doc} OA542051N_GetFileName ------------------------------------------------------------
@type    static function
@author  Lucas Brustolin
@since   11/10/2025
@version 1.0
@desc    Retorna apenas o nome do arquivo a partir de um caminho completo,
         aceitando separadores "\" e "/".
@param   cPath Char - Caminho completo do arquivo
@return  Char - Nome do arquivo extraído
@example  OA542051N_GetFileName('C:\\pasta\\arquivo.dat') => 'arquivo.dat'
@example  OA542051N_GetFileName('/var/tmp/arquivo.dat')   => 'arquivo.dat'
---------------------------------------------------------------------------------------------------*/
Static Function OA542051N_GetFileName(cPath)
   Local cTxt  := AllTrim(cPath)
   Local nB    := Rat(Chr(92), cTxt)   // última "\"
   Local nS    := Rat("/", cTxt)       // última "/"
   Local nPos  := IIf(nB > nS, nB, nS)

   If Empty(cTxt)
      Return ""
   EndIf

   If nPos <= 0
      Return cTxt
   EndIf

Return SubStr(cTxt, nPos + 1)

/*/{Protheus.doc} OA542060N_GravaOuAtualizaVEI -----------------------------------------------------
@type    static function
@author  Lucas Brustolin
@since   12/10/2025
@version 1.0
@desc    Cria ou atualiza o vínculo VEI?SC7 na tabela VEI.
         Utiliza o índice 1 (VEI_FILIAL+VEI_CODMAR+VEI_NUM) e grava
         o carimbo VEI_DATSC7/VEI_HORSC7.
@param   cFil       Char   - Filial SC7
@param   cNumC7     Char   - Nº do pedido SC7
@param   cPedFab    Char   - Nº do pedido Scania (fábrica)
@param   oLogger    Object - DMS_Logger() [opcional]
@param   cTblLogCod Char   - Código de log pai [opcional]
@param   cTipPed    Char   - Tipo de pedido [opcional]
@param   cViaTra    Char   - Via de transporte [opcional]
@param   cTransp    Char   - Transportadora [opcional]
@param   cPgt48h    Char   - Pagamento em 48h [opcional]
@param   cNumOSV    Char   - Nº OSV [opcional]
@param   cChaInt    Char   - Chave integração [opcional]
@return  Array { lOk, cErro } - Resultado da gravação e mensagem de erro
---------------------------------------------------------------------------------------------------*/
Static Function OA542060N_GravaOuAtualizaVEI( cFil, cNumC7, cPedFab, ;
                                              oLogger, cTblLogCod, ;
                                              cTipPed, cViaTra, cTransp, ;
                                              cPgt48h, cNumOSV, cChaInt )
   Local aArea   := GetArea()
   Local lNovo   := .F.
   Local cMar    := OC540009K_CodMarcaVEI()

   Local nLenFil := TamSX3("VEI_FILIAL")[1]
   Local nLenMar := TamSX3("VEI_CODMAR")[1]
   Local nLenNum := TamSX3("VEI_NUM")[1]
   Local nLenPed := TamSX3("VEI_PEDFAB")[1]

   Local bBlock   := ErrorBlock()
   Local bErro    := ErrorBlock( { |e| ChekBug(e) } )

   Private lOKTabVEI    := .T.
   Private cErrorTabVei := ""

   // Normalizações/padding
   cFil    := PADR(AllTrim(cFil)   , nLenFil)
   cMar    := PADR(cMar            , nLenMar)
   cNumC7  := PADR(AllTrim(cNumC7) , nLenNum)
   cPedFab := PADR(AllTrim(cPedFab), nLenPed)

   // Validações mínimas
   If Empty(AllTrim(cFil)) .or. Empty(AllTrim(cNumC7)) .or. Empty(AllTrim(cPedFab))
      RestArea(aArea)
      Return .F.
   EndIf

   BEGIN SEQUENCE
      dbSelectArea("VEI")
      dbSetOrder(1) // VEI_FILIAL+VEI_CODMAR+VEI_NUM

      Pergunte("MT297A", .F.)

      If ! VEI->( dbSeek( cFil + cMar + cNumC7 ) )
         RecLock("VEI", .T.)
         lNovo := .T.
         // chaves (somente inclusão)
         VEI->VEI_FILIAL := cFil
         VEI->VEI_CODMAR := cMar
         VEI->VEI_NUM    := cNumC7
         VEI->VEI_VIATRA := Str( MV_PAR01, 1 )
         VEI->VEI_PGT48H := Str( MV_PAR03, 1 )
      Else
         RecLock("VEI", .F.)
      EndIf

      // Sempre atualizar:
      VEI->VEI_PEDFAB := cPedFab
      If !Empty(cTipPed) ; VEI->VEI_TIPPED := cTipPed ; EndIf
      If !Empty(cViaTra) ; VEI->VEI_VIATRA := cViaTra ; EndIf
      If !Empty(cTransp) ; VEI->VEI_TRANSP := cTransp ; EndIf
      If !Empty(cPgt48h) ; VEI->VEI_PGT48H := cPgt48h ; EndIf
      If !Empty(cNumOSV) ; VEI->VEI_NUMOSV := cNumOSV ; EndIf
      If !Empty(cChaInt) ; VEI->VEI_CHAINT := cChaInt ; EndIf

      // Carimbo de vínculo SC7
      VEI->VEI_DATSC7 := dDatabase
      VEI->VEI_HORSC7 := Val( SubStr(Time(),1,2) + SubStr(Time(),4,2) )

      VEI->( MsUnlock() )

   END SEQUENCE

   ErrorBlock(bBlock)

RestArea(aArea)

Return( { lOKTabVEI, cErrorTabVei} )

/*/{Protheus.doc} OA542070N_GetB1CodByCodIte -------------------------------------------------------
@type    static function
@author  Lucas Brustolin
@since   13/10/2025
@version 1.0
@desc    Retorna o código SB1.B1_COD a partir de B1_CODITE (código do item Scania).
         Em caso de duplicidade, retorna o primeiro produto encontrado (menor B1_COD).
@param   cCodItem Char - Valor de B1_CODITE
@return  Char - Código SB1.B1_COD correspondente
---------------------------------------------------------------------------------------------------*/
Static Function OA542070N_GetB1CodByCodIte( cCodItem )

Local aArea       := GetArea() 
Local oStatement  := FWPreparedStatement():New()
Local cAliasSB1   := "TMPSB1COD"
Local cQuery      := ""
Local cCodProduto := ""

	If Select(cAliasSB1) > 0
		( cAliasSB1 )->( DbCloseArea() )
	EndIf

	cQuery := "SELECT SB1.B1_COD "
	cQuery += "FROM "+RetSqlName( "SB1" ) + " SB1 "
	cQuery += "WHERE "
	cQuery += "SB1.B1_FILIAL ='"+ xFilial("SB1")+ "' AND "
	cQuery += "SB1.B1_CODITE = ? AND "
	cQuery += "SB1.D_E_L_E_T_ =' ' ORDER BY B1_COD "

	//Define a consulta e os parâmetros
	oStatement:SetQuery(cQuery)
	oStatement:SetString(1,cCodItem)
	cQuery := oStatement:GetFixQuery()
   cAliasSB1 := MPSysOpenQuery(cQuery)

   If (cAliasSB1)->(!EoF())
      cCodProduto := AllTrim((cAliasSB1)->B1_COD)
   EndIf
   (cAliasSB1)->(DbCloseArea())

RestArea( aArea )

return( cCodProduto )

/*/{Protheus.doc} Chekbug --------------------------------------------------------------------------
@type    static function
@author  Lucas Brustolin
@since   23/10/2025
@version 1.0
@desc    Função de desvio de erro utilizada na gravação da tabela VEI.
         Intercepta exceções durante operações RecLock() e registra
         descrição do erro global para auditoria.
@param   e Object - Objeto de erro (ErrorBlock)
@return  Nil
---------------------------------------------------------------------------------------------------*/
Static Function Chekbug(e)
If e:gencode > 0
    lOKTabVEI := .F.
    cErrorTabVei := e:Description
Endif
Return

/*/{Protheus.doc} OA542080K_SetaFilialProcessamento
   Função para trocar a filial durante o processamento,
   visto que o arquivo pode ser referente a distintas filiais
   @type  Static Function
   @author Lucas Oliveira
   @since 17/01/2026
   @version version
   @param param_name, param_type, param_descr
   @return return_var, return_type, return_description
   @example
   (examples)
   @see (links_or_references)
/*/
Static Function OA542080K_SetaFilialProcessamento(cFilialESPPED)

   Default cFilialESPPED := ""

   If !Empty(cFilialESPPED) .and. cFilialESPPED <> cFilAnt
      cFilAnt := cFilialESPPED
   EndIf

Return .T.

/*/{Protheus.doc} OA542080K_RestauraFilial
   Funcao para restarurar a variavel cFilAnt
   com base na filial original acessada 
   @type  Static Function
   @author Lucas Oliveira
   @since 17/01/2026
   @version version
   @param param_name, param_type, param_descr
   @return return_var, return_type, return_description
   @example
   (examples)
   @see (links_or_references)
/*/
Static Function OA542090K_RestauraFilial()
   cFilAnt := cBKPFil
Return .T.