//Bibliotecas
#Include "Totvs.ch"
#Include "FWMVCDef.ch"
#include "LOCA248.CH" 
#include "LOCA248G.CH" 
 
/*/{Protheus.doc} User Function LOCA248G
MarkBrowse para Mudar Situação em Lote
@author Dennis Calabrez
@since 07/10/2025
@version 1.0
@type function
/*/
Function LOCA248G()
Local aArea  := FWGetArea()
Local aPergs := {}
Local xPar0  := Space(TamSX3('FQK_PROJET')[1])
Local xPar1  := StrTran(xPar0, ' ', 'Z')
Local nTipo  := 1
     
    //Adicionando os parametros do ParamBox
    aAdd(aPergs, {1, STR0001,  xPar0,  "", ".T.", "FP0", ".T.", 80,  .F.}) //"Projeto De"
    aAdd(aPergs, {1, STR0002, xPar1,  "", ".T.", "FP0", ".T.", 80,  .T.}) //"Projeto Até"
    aAdd(aPergs, {2, STR0005,    nTipo,  {STR0003,STR0004,STR0007,STR0006},  100, ".T.", .F.}) //"1=Digitado" //"2=Em aprovação" //"Situação" //"6=Cancelado" //"5=Não aprovado"
     
    //Se a pergunta for confirma, chama a tela
    If ParamBox(aPergs, STR0008, /*aRet*/, /*bOk*/, /*aButtons*/, /*lCentered*/, /*nPosx*/, /*nPosy*/, /*oDlgWizard*/, /*cLoad*/, .F., .F.) //'Informe os parâmetros'
        fMontaTela()
    EndIf
     
    FWRestArea(aArea)
Return
 
/*/{Protheus.doc} fMontaTela
Monta a tela com a marcação de dados
@author Dennis Calabrez
@since 07/10/2025
@version 1.0
@type function
/*/ 
Static Function fMontaTela()
Local aArea        := GetArea()
Local aCampos      := {}
Local oTempTable   := Nil
Local aColunas     := {}
Local cFontPad     := 'Tahoma'
Local oFontGrid    := TFont():New(cFontPad, /*uPar2*/, -14)
Local bBlocoOk     := {|| lOk := .T., oDlgBrow:End()}
Local bBlocoCan    := {|| lOk := .F., oDlgBrow:End()}
Local aOutrasAc    := {}
Local bBlocoIni
Private lOk        := .F.
    //Janela e componentes
Private oDlgBrow
Private oFWBrowse
Private cAliasTmp   := GetNextAlias()
Private aRotina     := {}
Private cFiltro     := Space(100)
Private oGetFiltro
//Tamanho da janela
Private aTamanho    := MsAdvSize()
Private nJanLarg    := aTamanho[5]
Private nJanAltu    := aTamanho[6]
 
    //Opções no Outras Ações
    aAdd(aOutrasAc, {'BMP', {|| fMarkTod()}, STR0009}) //'* (Des) Marcar todos registros'
    aAdd(aOutrasAc, {'BMP', {|| fPesquisar()}, STR0010}) //'Pesquisar'
      
    //Adiciona as colunas que serão criadas na temporária
    aAdd(aCampos, { 'FLAG_OK',   'L', 1, 0}) //Flag para marcação
    aAdd(aCampos, { 'FQK_PROJET','C', TamSX3('FQK_PROJET')[1], 0}) //Projeto
    aAdd(aCampos, { 'FQK_OBRA',  'C', TamSX3('FQK_OBRA')[1], 0}) //Obra
    aAdd(aCampos, { 'FQK_COD',   'C', TamSX3('FQK_COD')[1], 0}) //Cliente
    aAdd(aCampos, { 'FQK_CLIENT','C', TamSX3('FQK_CLIENT')[1], 0}) //Loja
    aAdd(aCampos, { 'RECNUM',    'N', 16, 0}) //RecNo da FQK
 
    //Cria a tabela temporária
    oTempTable:= FWTemporaryTable():New(cAliasTmp)
    oTempTable:SetFields( aCampos )
    oTempTable:Create()  
 
    //Popula a tabela temporária
    Processa({|| fPopula()}, STR0011) //'Processando...'
 
    //Adiciona as colunas que serão exibidas no browse
    aColunas := fCriaCols()
      
    //Criando a janela
    oDlgBrow := TDialog():New(0, 0, nJanAltu, nJanLarg, STR0012, , , , , , /*nCorFundo*/, , , .T.) //'Mudança de Situação em Lote'
          
    //Dados
    oFWBrowse := FWBrowse():New()
    oFWBrowse:DisableFilter()
    oFWBrowse:DisableConfig()
    oFWBrowse:DisableReport()
    oFWBrowse:DisableSeek()
    oFWBrowse:DisableSaveConfig()
    oFWBrowse:SetFontBrowse(oFontGrid)
    oFWBrowse:SetAlias(cAliasTmp)
    oFWBrowse:SetDataTable()
    oFWBrowse:SetEditCell(.T., {|| .T.}) 
    oFWBrowse:lHeaderClick := .T.
    oFWBrowse:AddMarkColumns(;
        {|| Iif((cAliasTmp)->FLAG_OK, 'LBOK', 'LBNO') },;
        {|| (cAliasTmp)->FLAG_OK := ! (cAliasTmp)->FLAG_OK},;
        {|| fMarkTod()};
    )
         
    //Define as colunas, vincula ao painel e exibe
    oFWBrowse:SetColumns(aColunas)
    oFWBrowse:SetOwner(oDlgBrow)
    oFWBrowse:Activate()
         
    bBlocoIni := {|| EnchoiceBar(oDlgBrow, bBlocoOk, bBlocoCan, , aOutrasAc)}
    oDlgBrow:Activate(, , , .T., , , bBlocoIni)
 
    //Se usuário clicou no botão confirmar
    If lOk
        fConfirmou()
    EndIf
     
    //Deleta a temporária e desativa a tela de marcação
    oTempTable:Delete()
    oFWBrowse:DeActivate()
     
    RestArea(aArea)
Return
  
/*/{Protheus.doc} fPopula
Executa a query SQL e popula essa informação na tabela temporária usada no browse
@author Dennis Calabrez
@since 07/10/2025
@version 1.0
@type function

/*/
Static Function fPopula()
Local cQuery     := ''
Local nTotal     := 0
Local nAtual     := 0
Local aBindParam := {}
 
    //Monta a consulta
    cQuery += "SELECT FQK_PROJET, FQK_OBRA, FQK_COD, FQK_CLIENT, FQK.R_E_C_N_O_ AS FQKREC "
    cQuery += " FROM "+RETSQLNAME("FQK")  +" FQK "
    cQuery += "WHERE FQK_FILIAL='"+xFilial('FQK')+"' AND FQK_PROJET BETWEEN ? AND ? "
    cQuery += "AND FQK.D_E_L_E_T_ = ' ' AND FQK_SITUAC <> '6' " 
    cQuery += "ORDER BY FQK_COD" 
    aadd(aBindParam,MV_PAR01)
    aadd(aBindParam,MV_PAR02)
	cQuery := CHANGEQUERY(cQuery)
    MPSysOpenQuery(cQuery,'QRYDADTMP',,,aBindParam)    
 
    //Definindo o tamanho da régua
    DbSelectArea('QRYDADTMP')
    Count to nTotal
    ProcRegua(nTotal)
    QRYDADTMP->(DbGoTop())
 
    //Enquanto houver registros, adiciona na temporária
    While ! QRYDADTMP->(EoF())
        nAtual++
        IncProc(STR0013 + cValToChar(nAtual) + STR0014 + cValToChar(nTotal) + '...') //'Analisando registro ' //' de '
 
        RecLock(cAliasTmp, .T.)
        (cAliasTmp)->FLAG_OK    := .F.
        (cAliasTmp)->FQK_PROJET := QRYDADTMP->FQK_PROJET
        (cAliasTmp)->FQK_OBRA   := QRYDADTMP->FQK_OBRA
        (cAliasTmp)->FQK_COD    := QRYDADTMP->FQK_COD
        (cAliasTmp)->FQK_CLIENT := QRYDADTMP->FQK_CLIENT
        (cAliasTmp)->RECNUM     := QRYDADTMP->FQKREC
        (cAliasTmp)->(MsUnlock())
 
        QRYDADTMP->(DbSkip())
    EndDo
    QRYDADTMP->(DbCloseArea())
    (cAliasTmp)->(DbGoTop())
Return
 
/*/{Protheus.doc} fCriaCols
Função que gera as colunas usadas no browse (similar ao antigo aHeader)
@author Dennis Calabrez
@since 07/10/2025
@version 1.0
@type function
/*/
Static Function fCriaCols()
Local nAtual   := 0 
Local aColunas := {}
Local aEstrut  := {}
Local oColumn
     
    //Adicionando campos que serão mostrados na tela
    //[1] - Campo da Temporaria
    //[2] - Titulo
    //[3] - Tipo
    //[4] - Tamanho
    //[5] - Decimais
    //[6] - Máscara
    //[7] - Editável? .T. = sim, .F. = não
    aAdd(aEstrut, { 'FQK_PROJET',STR0015, 'C', TamSX3('FQK_PROJET')[1], 0, '', .F.}) //'Projeto'
    aAdd(aEstrut, { 'FQK_OBRA',  STR0016, 'C', TamSX3('FQK_OBRA')[1], 0, '', .F.}) //'Obra'
    aAdd(aEstrut, { 'FQK_COD',   STR0017, 'C', TamSX3('FQK_COD')[1], 0, '', .F.}) //'Cod. Medição'
    aAdd(aEstrut, { 'FQK_CLIENT',STR0018, 'C', TamSX3('FQK_CLIENT')[1], 0, '', .F.}) //'Cliente'
 
    //Percorrendo todos os campos da estrutura
    For nAtual := 1 To Len(aEstrut)
        //Cria a coluna
        oColumn := FWBrwColumn():New()
        oColumn:SetData(&('{|| ' + cAliasTmp + '->' + aEstrut[nAtual][1] +'}'))
        oColumn:SetTitle(aEstrut[nAtual][2])
        oColumn:SetType(aEstrut[nAtual][3])
        oColumn:SetSize(aEstrut[nAtual][4])
        oColumn:SetDecimal(aEstrut[nAtual][5])
        oColumn:SetPicture(aEstrut[nAtual][6])
        /*
        //Se for ser possível ter o duplo clique
        If aEstrut[nAtual][7]
            oColumn:SetEdit(.T.)
            oColumn:SetReadVar(aEstrut[nAtual][1])
        EndIf
        */
        //Adiciona a coluna
        aAdd(aColunas, oColumn)
    Next
Return aColunas
 
/*/{Protheus.doc} fConfirmou
Função acionada após fechar a tela se o usuário confirmou
@author Dennis Calabrez
@since 07/10/2025
@version 1.0
@type function
/*/
Static Function fConfirmou()
    Processa({|| fProcessa()}, STR0011) //'Processando...'
Return
 
/*/{Protheus.doc} fProcessa
Função que percorre os registros da tela
@author Dennis Calabrez
@since 07/10/2025
@version 1.0
@type function
/*/ 
Static Function fProcessa()
Local aArea     := FWGetArea()
Local nAtual    := 0
Local nTotal    := 0
Local nTotMarc  := 0
Local aAreaFQK  := FQK->(GetArea())
Local aAreaFQL  := FQL->(GetArea())
Local cMedSeqx
Local cProjetx
Local cCod      := ""
Local cMedSeq   := ""
Local cGRPMD    := ""
     
    //Define o tamanho da régua
    DbSelectArea(cAliasTmp)
    (cAliasTmp)->(DbGoTop())
    Count To nTotal
    ProcRegua(nTotal)
     
    //Percorrendo os registros
    (cAliasTmp)->(DbGoTop())
    While ! (cAliasTmp)->(EoF())
        nAtual++
        IncProc(STR0013 + cValToChar(nAtual) + STR0014 + cValToChar(nTotal) + STR0032) //'Analisando registro ' //'...'
     
        //Caso esteja marcado
        If (cAliasTmp)->FLAG_OK
            nTotMarc++
             
            //Posiciona no registro original
            DbSelectArea("FQK")
            FQK->(DbGoTo((cAliasTmp)->RECNUM))
		    cMedSeqx := FQK->FQK_MEDSEQ
		    cProjetx := FQK->FQK_PROJET
            cGRPMD   := FQK->FQK_GRPMD

            //if !(FQK->FQK_SITUAC $ "1/2/5")
            //    Help( ,, "LOCA248G-fProcessa",, STR0022 + cValToChar(nAtual) + STR0019+FQK->FQK_PROJET + STR0020, 1, 0,,,,,,{STR0021}) //"Projeto: " //" não pode mudar de situação, somente medições DIGITADA, ou CONFIRMADA." //"Inconsistência nos dados" //'registro '
		    //    FQK->(RestArea(aAreaFQK))
		    //    FQL->(RestArea(aAreaFQL))                
            //EndIf  

	        // Só pode ser cancelada a última medição ativa.
	        // Este controle tem haver com o retorno da numeração do bem.
            If ValType(MV_PAR03) == "C"
                If MV_PAR03 == "6"
                    FQK->(dbSetOrder(6)) 
                    FQK->(dbSeek(xFilial("FQK")+cProjetx+cGRPMD))
                    While !FQK->(Eof()) .and. FQK->FQK_FILIAL == xFilial("FQK") .and. FQK->FQK_PROJET == cProjetx .and. FQK->FQK_GRPMD == cGRPMD
                        If FQK->FQK_MEDSEQ > cMedSeqx .and. FQK->FQK_SITUAC <> "6"
                            FQK->(RestArea(aAreaFQK))
                            FQL->(RestArea(aAreaFQL))
                            Help( ,, "LOCA248G-fProcessa",, STR0002, 1, 0,,,,,,{STR0117}) //"Inconsistência nos dados."###"A data final não pode ser editada, pois existe uma medição posterior."
                            Return .F.
                        EndIF
                    FQK->(dbSkip())
                EndDo
                FQK->(RestArea(aAreaFQK))
                FQL->(RestArea(aAreaFQL))            
                EndIF 
            EndIf            
            //Grava a alteração
            if (FQK->FQK_SITUAC $ "1/2/5")
                RecLock("FQK", .F.)
                //Tratamento no MV_PAR03, pois quando é selecionado o primeiro item do combo 
                //ele está vindo como numérico e da error.log
                If ValType(MV_PAR03) == "C"
                    FQK->FQK_SITUAC :=  MV_PAR03
                Else
                    FQK->FQK_SITUAC :=  ALLTRIM(str(MV_PAR03))  
                EndIf  
                If ValType(MV_PAR03) == "C"  
                    If MV_PAR03 == "6"
                        FQK->FQK_VALTOT := 0
                        FQK->FQK_VALSER := 0
                        cCod := FQK->FQK_COD
                        cMedSeq := FQK->FQK_MEDSEQ
                        FQK->FQK_MEDSEQ := SPACE(LEN(FQK->FQK_MEDSEQ))
                    EndIf  
                EndIf          
                FQK->(MsUnlock())
            EndIf
        EndIf
          
        (cAliasTmp)->(DbSkip())
    EndDo
     
    //Mostra a mensagem de término e caso queria fechar a dialog, basta usar o método End()
    FWAlertInfo(STR0023 + cValToChar(nTotal) + STR0024 + cValToChar(nTotMarc) + STR0026, STR0025) //'Dos [' //'] registros, foram processados [' //'Atenção' //'] registros'
 
    FWRestArea(aArea)
Return
 
/*/{Protheus.doc} fMarkTod
Marca/Desmarca todos os registros
@author Dennis Calabrez
@since 07/10/2025
@version 1.0
@type function
/*/
Static Function fMarkTod()
    //Percorre todos os registros
    DbSelectArea(cAliasTmp)
    (cAliasTmp)->(DbGoTop())
    While ! (cAliasTmp)->(EoF())
        //Atualiza o registro atual
        RecLock(cAliasTmp, .F.)
        (cAliasTmp)->FLAG_OK := ! (cAliasTmp)->FLAG_OK
        (cAliasTmp)->(MsUnlock())
 
        (cAliasTmp)->(DbSkip())
    EndDo
 
    //Volta pro topo, e atualiza a tela
    (cAliasTmp)->(DbGoTop())
    oFWBrowse:Refresh()
Return

/*/{Protheus.doc} fPesquisar
Função para pesquisar dados no grid
@author Dennis Calabrez
@since 07/10/2025
@version 1.0
@type function
/*/
Static Function fPesquisar()
Local cPesquisa  := Space(100)
Local lAchou     := .F.
Static nRecnoIni := 0

    //Solicita o termo a ser pesquisado
    If !ParamBox({;
        {1, STR0010, cPesquisa, "", "", "", "", 80, .F.}},; //'Pesquisar'
        STR0010,; //'Pesquisar'
        /*aRet*/,;
        /*bOk*/,;
        /*aButtons*/,;
        /*lCentered*/,;
        /*nPosx*/,;
        /*nPosy*/,;
        /*oDlgWizard*/,;
        /*cLoad*/,;
        .F.,;
        .F.)
        Return
    EndIf
    
    cPesquisa := AllTrim(Upper(MV_PAR01))
    
    If Empty(cPesquisa)
        FWAlertInfo(STR0027, STR0025) //"Digite um termo para pesquisar!"
        Return
    EndIf
    
    //Executa a pesquisa
    lAchou := fExecutaPesquisa(cPesquisa, @nRecnoIni)
    
Return

/*/{Protheus.doc} fExecutaPesquisa
Executa a pesquisa no grid
@author Dennis Calabrez
@since 07/10/2025
@version 1.0
@type function
/*/
Static Function fExecutaPesquisa(cPesquisa, nRecnoIni)
Local lAchou       := .F.
Local nRecAtual    := 0
Local lPrimeiraVez := (nRecnoIni == 0)
Local cProjet      := ""
Local cObra        := ""
Local cCod         := ""
Local cSituac      := ""

    DbSelectArea(cAliasTmp)
    
    //Se é a primeira pesquisa, começa do topo
    If lPrimeiraVez
        (cAliasTmp)->(DbGoTop())
        nRecnoIni := (cAliasTmp)->(Recno())
    Else
        //Senão, vai para o próximo registro
        (cAliasTmp)->(DbSkip())
        If (cAliasTmp)->(Eof())
            (cAliasTmp)->(DbGoTop())
        EndIf
    EndIf
    
    nRecAtual := (cAliasTmp)->(Recno())
    
    //Percorre os registros procurando o termo em qualquer campo
    While !(cAliasTmp)->(Eof())
        //Protege contra campos vazios/nulos
        cProjet := AllTrim(Upper(If(Empty((cAliasTmp)->FQK_PROJET), "", (cAliasTmp)->FQK_PROJET)))
        cObra   := AllTrim(Upper(If(Empty((cAliasTmp)->FQK_OBRA), "", (cAliasTmp)->FQK_OBRA)))
        cCod    := AllTrim(Upper(If(Empty((cAliasTmp)->FQK_COD), "", (cAliasTmp)->FQK_COD)))
        cSituac := AllTrim(Upper(If(Empty((cAliasTmp)->FQK_CLIENT), "", (cAliasTmp)->FQK_CLIENT)))
        
        If cPesquisa $ cProjet .Or. ;
           cPesquisa $ cObra .Or. ;
           cPesquisa $ cCod .Or. ;
           cPesquisa $ cSituac
            
            lAchou := .T.
            nRecnoIni := (cAliasTmp)->(Recno())
            Exit
        EndIf
        
        (cAliasTmp)->(DbSkip())
        
        //Se voltou ao registro inicial e não achou, para
        If (cAliasTmp)->(Recno()) == nRecAtual .And. !lPrimeiraVez
            Exit
        EndIf
        
        //Se chegou no fim, volta pro início
        If (cAliasTmp)->(Eof())
            (cAliasTmp)->(DbGoTop())
            Exit
        EndIf
    EndDo
    
    If lAchou
        oFWBrowse:Refresh(.T.)
        oFWBrowse:GoTo(nRecnoIni, .T.)
        FWAlertSuccess(STR0029, STR0028) //"Pesquisa"
    Else
        If lPrimeiraVez
            FWAlertInfo(STR0030, STR0028) //"Pesquisa"
        Else
            FWAlertInfo(STR0031, STR0028) //"Não há mais registros! Pesquisa reiniciada."
            nRecnoIni := 0
        EndIf
    EndIf
    
Return lAchou


// Passagem no advpr
Function LOCA248F5
Return .T.
