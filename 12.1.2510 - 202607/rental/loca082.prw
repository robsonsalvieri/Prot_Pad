#INCLUDE "Protheus.ch"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "LOCA082.CH"

/*/{Protheus.doc} LOCA082.PRW
ITUP Business - TOTVS RENTAL
Pedido de Venda x Locação 

@type Function
@author José Eulálio
@since 16/08/2022
@version P12

/*/
Function LOCA082 
Local oBrowse

	aRotina := MenuDef() 					   
	oBrowse := FwmBrowse():NEW() 			   
	oBrowse:SetAlias("FPY")					   
	oBrowse:SetDescription(STR0001) //'Status do Equipamento x Contrato Rental'
	oBrowse:Activate() 						   

Return( NIL )
//---------------------------------------------------------------------------------------------

Static Function MenuDef()

Local aBotao := {}

ADD OPTION aBotao Title 'Visualizar' 	Action 'VIEWDEF.LOCA082' OPERATION 2 ACCESS 0
//ADD OPTION aBotao Title 'Incluir' 		Action 'VIEWDEF.LOCA081' OPERATION 3 ACCESS 0
//ADD OPTION aBotao Title 'Alterar' 	Action 'VIEWDEF.LOCA081' OPERATION 4 ACCESS 0
//ADD OPTION aBotao Title 'Excluir' 	Action 'VIEWDEF.LOCA081' OPERATION 5 ACCESS 0
ADD OPTION aBotao Title 'Imprimir' 		Action 'VIEWDEF.LOCA082' OPERATION 8 ACCESS 0
	
Return aBotao

// Preparaçao do modelo de dados
Static Function ModelDef()
Local oModel
Local oModFPZ
Local oStrFPY:= FWFormStruct(1,'FPY')	
Local oStrFPZ:= FWFormStruct(1,'FPZ')	
Local oStrSC6:= FWFormStruct(1,'SC6', {|xCampo| xCampo <> "C6_INFAD "})

oModel := MPFormModel():New('MODELFPY') 
oModel:addFields('FPYMASTER',,oStrFPY)    
oModel:addGrid('SC6DETAIL','FPYMASTER',oStrSC6)
oModel:addGrid('FPZDETAIL','SC6DETAIL',oStrFPZ)
oModel:SetDescription(STR0001)  //'Status do Equipamento x Contrato Rental'
oModel:getModel('FPYMASTER'):SetDescription(STR0001) //'Status do Equipamento x Contrato Rental'	
oModFPZ := oModel:GetModel('FPZDETAIL')
oModel:GetModel( 'SC6DETAIL' ):SetOnlyQuery ( .T. )
//oModFPZ:SetNoInsertLine(.T.)
//oModFPZ:SetNoUpdateLine(.T.)
//oModFPZ:SetNoDeleteLine(.T.)
oModel:SetRelation('SC6DETAIL', { { 'C6_FILIAL', "xFilial('SC6')" }, { 'C6_NUM', 'FPY_PEDVEN' } }, SC6->(IndexKey(1)) )
oModel:SetRelation('FPZDETAIL', { { 'FPZ_FILIAL', "xFilial('FPZ')" }, { 'FPZ_PEDVEN', 'FPY_PEDVEN' }, { 'FPZ_PROJET', 'FPY_PROJET' }, { 'FPZ_ITEM', 'C6_ITEM' }}, FPZ->(IndexKey(1)) )
oModel:SetPrimaryKey({ 'FPY_FILIAL','FPY_PEDVEN' })
//oModel:SetPrimaryKey({ 'FPZ_FILIAL','FPZ_PEDVEN','FPZ_PROJET','FPZ_ITEM' })
Return oModel

//-------------------------------------------------------------------
// Montagem da interface
Static Function ViewDef()
Local oView
Local oModel := ModelDef()		
Local oStrFPY:= FWFormStruct(2, 'FPY')    
Local oStrSC6:= FWFormStruct(2, 'SC6', {|xCampo| xCampo <> "C6_INFAD "})
Local oStrFPZ:= FWFormStruct(2, 'FPZ' , { |x| !(ALLTRIM(x) $ 'FPZ_PEDVEN|FPZ_PROJET') } )    
oView := FWFormView():New()		
oView:SetModel(oModel)			 
oView:AddField('VIEWFPY' , oStrFPY,'FPYMASTER' )  
// Cria a estrutura das grids em formato de árvore
oView:AddGrid('VIEWSC6'  , oStrSC6,'SC6DETAIL' )
oView:AddGrid('VIEWFPZ'  , oStrFPZ,'FPZDETAIL' )

oView:CreateHorizontalBox( 'TELA', 25)
oView:CreateHorizontalBox( 'GRID1', 25)
oView:CreateHorizontalBox( 'GRID2', 50)


oView:SetOwnerView('VIEWFPY','TELA')
oView:SetOwnerView("VIEWSC6",'GRID1')
oView:SetOwnerView("VIEWFPZ",'GRID2')

// ISSUE: DSERLOCA-10930 - Lui Pazini - 22/02/2026 - Botao de alteracao controlada de datas
// A logica de permissao e validacao esta isolada em LOCA082AD()
oView:AddUserButton(STR0002, STR0002, {|oView| LOCA082AD(oView)}) //STR0002 //"Alterar Datas de Locacao"

// ISSUE: DSERLOCA-10931 - Lui Pazini - 23/02/2026 - Botao para criar FPZ quando nao existir
// A logica de existencia e criacao esta isolada em LOCA082GF()
oView:AddUserButton(STR0003, STR0003, {|oView| LOCA082GF(oView)}) //STR0003 //"Gerar FPZ"

// ISSUE: DSERLOCA-11428 - Dennis Calabrez - 23/03/2026 - Botao para limpar o conteúdo do campo FPy_APROV
oView:AddUserButton(STR0004, STR0004, {|oView| LOCA082RP(oView)}) //STR0004 //"Reenviar para Produção"

Return oView

/*/{Protheus.doc} LOCxPed
ITUP Business - TOTVS RENTAL
ExecView da Rotina

@type Function
@author José Eulálio
@since 09/08/2022
@version P12

/*/
Function LOCA0821(cNumPed)
Local cStatus	:= ""
Local nOperLoc	:= MODEL_OPERATION_VIEW
Local aAreaFPY	:= FPY->(GetArea())
Local aButtons	:= {{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.T.,Nil},{.T.,Nil},{.T.,"Salvar"},{.T.,"Cancelar"},{.F.,Nil},{.T.,Nil},{.F.,Nil},{.T.,Nil},{.T.,Nil},{.T.,Nil}} 
Local aSize     := FWGetDialogSize(oMainWnd)

Default cNumPed	:= ""

	If !Empty(cNumPed)
		FPY->(DbSetOrder(1)) //
		If FPY->(DbSeek(xFilial("FPY") + cNumPed))
			SC6->(DbSeek(xFilial("SC6") + cNumPed))
			/*If ALTERA
				nOperLoc	:= MODEL_OPERATION_UPDATE
			EndIf*/
			//FWExecView(STR0001,'LOCA082', nOperLoc	, , { || .T. }, ,100 ,aButtons )
			FWExecView(STR0001, 'LOCA082', nOperLoc, , { || .T. }, , , aButtons, , , , , , , aSize[4] * 0.85) //"Pedido de Venda x Locação "
		EndIf
	EndIf

	//restaura a área e limpa array
	RestArea(aAreaFPY)
	aAreaFPY := Nil


Return cStatus

/*/{Protheus.doc} LOCxPed
ITUP Business - TOTVS RENTAL
Rotina automática

@type Function
@author José Eulálio
@since 09/08/2022
@version P12

/*/
Function LOCA0822(aCab, aItens, lRemessa)
Local nX		:= 0
Local nY		:= 0

DEFAULT lRemessa := .T.

//prepara cabeçalho
RecLock("FPY", .T.)
For nX := 1 To Len(aCab)
	FPY->(FieldPut( FieldPos( aCab[nX][1]) , aCab[nX][2]))
Next nX
MsUnlock()
//prepara itens
For nX := 1 To Len(aItens)
	RecLock("FPZ", .T.)
	For nY := 1 To Len(aItens[nX])
        if FPZ->(FieldPos(aItens[nX][ny][1])) > 0
		    FPZ->(FieldPut( FieldPos(aItens[nX][ny][1]), aItens[nX][ny][2]))
        endif
	Next nY

	// Reforço lógico para garantir a gravação do pedido de vendas - ISSUE 10384 - Frank 23/01/2026
	FPZ->FPZ_PEDVEN := FPY->FPY_PEDVEN

	FPZ->(MsUnlock())
	// Verificar se existe FH2 para atualizar
	if lRemessa .and. !Empty(FPZ->FPZ_FROTA) 
		If FindFunction( "LOCA224B1" )
        	If LOCA224B1("FH2_FILIAL", "FH2")
				FH2->(dbSetOrder(1))
				if FH2->(dbSeek(xFilial("FH2")+FPZ->FPZ_AS+FPZ->FPZ_FROTA))
					RecLock("FH2",.F.)
					FH2->FH2_PEDIDO := FPZ->FPZ_PEDVEN
					FH2->FH2_ITEMPV := FPZ->FPZ_ITEM
					MsUnlock()
				EndIf
			EndIf
		EndIf
	endif
Next nX

Return

// Passagem do advpr
Function LOCA082C
Return .T.

//---------------------------------------------------------------------------------------------
/*/{Protheus.doc} LOCA082AD
Exibe dialogo modal para alteracao controlada dos campos:
  FPZ_DTINI  - Data inicial do periodo de locacao
  FPZ_DTFIM  - Data final do periodo de locacao
  FPZ_PERLOC - Descricao do periodo de locacao

Fluxo:
  1. Valida permissao do usuario via LOCA082VP() -> FQ1
  2. Valida situacao do registro via LOCA082VS(oView)
  3. Exibe dialogo com os tres campos editaveis
  4. Valida FPZ_DTINI <= FPZ_DTFIM antes de gravar
  5. Grava diretamente no registro FPZ via RecLock

Nao altera o fluxo MVC principal do LOCA082.

@type   Static Function
@author Lui Pazini
@since  22/02/2026
@version 1
@param  oView, Object, Referencia da FWFormView ativa
@return Logical, .T. se a alteracao foi realizada com sucesso
/*/
Static Function LOCA082AD(oView)

// ISSUE: DSERLOCA-10930 - Lui Pazini - 23/02/2026
// aAreaAtiva: salva o alias corrente do MVC antes de qualquer movimentacao
// Garantia 1: o alias ativo do MVC e restaurado em todos os pontos de saida
// oFPZMdl: modelo da grid FPZDETAIL usado para leitura confiavel em contexto MVC
// Leitura direta de FPZ-> antes da validacao retornava valores invalidos (alias em EOF)
Local aAreaAtiva := GetArea()
Local oFPZMdl    := oView:GetModel():GetModel("FPZDETAIL")
Local lRet       := .F.
Local dDtIni     := CtoD("")
Local dDtFim     := CtoD("")
Local cPerLoc    := ""
Local dDtIniOld  := CtoD("")
Local dDtFimOld  := CtoD("")
Local cPerLocOld := ""
Local oTela      := Nil
Local oDtIni      := Nil
Local oDtFim      := Nil
Local oPerLoc    := Nil
Local lConfirm   := .F.
Local aAreaFPZ   := FPZ->(GetArea())
Local cPedVen    := ""
Local cProjet    := ""
Local cItem      := ""

    // --- Bloco 1: Permissao de usuario ---
    If !LOCA082VP()
        MsgAlert( "Seu usuario nao possui permissao para executar esta operacao."  + Chr(13) + ;
                  "Solicite cadastro na tabela FQ1 com FQ1_NOMPRO = 'LOCA082'."   , ;
                  "Acesso Negado" )
        RestArea(aAreaFPZ)
        RestArea(aAreaAtiva)
        Return .F.
    EndIf


    // --- Bloco 3: Posiciona FPZ pelo modelo e le valores atuais ---
    // GetValue garante leitura da linha selecionada na grid independente do alias
    cPedVen    := oFPZMdl:GetValue("FPZ_PEDVEN")
    cProjet    := oFPZMdl:GetValue("FPZ_PROJET")
    cItem      := oFPZMdl:GetValue("FPZ_ITEM")
    FPZ->(dbSetOrder(1))
    FPZ->(dbSeek(xFilial("FPZ") + cPedVen + cProjet + cItem))
    dDtIni     := FPZ->FPZ_DTINI
    dDtFim     := FPZ->FPZ_DTFIM
    cPerLoc    := FPZ->FPZ_PERLOC
    dDtIniOld  := FPZ->FPZ_DTINI
    dDtFimOld  := FPZ->FPZ_DTFIM
    cPerLocOld := FPZ->FPZ_PERLOC

    // --- Bloco 4: Dialogo de edicao ---
    // Apenas os tres campos autorizados sao expostos; demais campos da FPZ
    // permanecem intocados e o browse principal nao e afetado.
    Define MSDialog oTela                                         ;
        Title "Alterar Datas de Locacao"                          ;
        From  000, 000 To 220, 440 PIXEL

    @ 012, 010 Say "Data Inicial (FPZ_DTINI):"        Size 120, 010 Of oTela PIXEL
    @ 012, 135 MSGet oDtIni  Var dDtIni  Size 080, 010 Of oTela PIXEL F3 Nil Valid (!Empty(dDtIni))

    @ 032, 010 Say "Data Final   (FPZ_DTFIM):"        Size 120, 010 Of oTela PIXEL
    @ 032, 135 MSGet oDtFim  Var dDtFim  Size 080, 010 Of oTela PIXEL F3 Nil Valid (!Empty(dDtFim))

    @ 052, 010 Say "Periodo Loc. (FPZ_PERLOC):"       Size 120, 010 Of oTela PIXEL
    @ 052, 135 MSGet oPerLoc Var cPerLoc              Size 080, 010 Of oTela PIXEL F3 Nil

    @ 080, 010 Button "Confirmar" Size 060, 015 Of oTela PIXEL ;
               Action (lConfirm := .T., oTela:End())
    @ 080, 135 Button "Cancelar"  Size 060, 015 Of oTela PIXEL ;
               Action oTela:End()

    Activate MSDialog oTela Centered



    // --- Bloco 4: Processamento pos-dialogo ---
    If lConfirm

        // Regra 5: Data inicial nao pode ser posterior a data final
        If dDtIni > dDtFim
            MsgAlert( "A Data Inicial nao pode ser maior que a Data Final." + Chr(13) + ;
                      "Corrija os valores e tente novamente."                , ;
                      "Validacao de Datas" )
            RestArea(aAreaFPZ)
            RestArea(aAreaAtiva)
            Return .F.
        EndIf

        // Grava somente os tres campos autorizados via funcao isolada
        // Garantias 2, 3, 4, 5, 7, 8: GetArea/RestArea internos, tipos corretos,
        // sem NIL, sem SetValue do modelo, sem quebrar buffer do RMS
        fAlteraDatasFPZ(cPedVen, cProjet, cItem, dDtIni, dDtFim, cPerLoc)

        // ISSUE: DSERLOCA-10930 - Lui Pazini - 22/02/2026 - Registra historico no FPY_HIST somente se houve alteracao real
        LOCA082GH(dDtIniOld, dDtFimOld, cPerLocOld, dDtIni, dDtFim, cPerLoc)

        MsgInfo("Datas de locacao atualizadas com sucesso!", "Informacao")

        // Garantia 6: forca a grid FPZDETAIL a reler os valores do banco
        // sem usar SetValue do modelo — oView:Refresh() descarta o buffer obsoleto
        oView:Refresh()

        lRet := .T.

    EndIf

    RestArea(aAreaFPZ)
    RestArea(aAreaAtiva)

Return lRet

//---------------------------------------------------------------------------------------------
/*/{Protheus.doc} LOCA082VP
Consulta a tabela FQ1 para verificar se o usuario logado possui
acesso cadastrado para o programa LOCA082.

Chave de busca (indice 1 da FQ1):
  xFilial("FQ1") + FQ1_CODUSR + FQ1_NOMPRO

O codigo do usuario e obtido via RETCODUSR, padrao adotado em LOCA053.

@type   Static Function
@author Lui Pazini
@since  22/02/2026
@version 1
@return Logical, .T. se o usuario possui permissao cadastrada na FQ1
/*/
Static Function LOCA082VP() 

// ISSUE: DSERLOCA-10930 - Lui Pazini - 22/02/2026

// Padrao de obtencao do usuario conforme LOCA053 (linha 17)
Local cCodUsr    := RetCodUsr()
Local lPermitido := .F.
Local aAreaFQ1   := FQ1->(GetArea())

    FQ1->(DbSetOrder(1))
    // Softseek (.T.) para nao travar em tabelas sem o registro
    lPermitido := FQ1->(DbSeek(xFilial("FQ1") + cCodUsr + "LOCA082", .T.))

    // Confirma que o seek nao caiu em outro programa/usuario (softseek pode avançar)
    If lPermitido
        lPermitido := ( ALLTRIM(FQ1->FQ1_CODUSR) == cCodUsr .And. ;
                        ALLTRIM(FQ1->FQ1_NOMPRO) == "LOCA082" )
    EndIf

    RestArea(aAreaFQ1)

Return lPermitido


//---------------------------------------------------------------------------------------------
/*/{Protheus.doc} LOCA082GH
Registra entrada de historico no campo memo FPY_HIST apos alteracao
controlada das datas de locacao.

Regras:
  - Apenas concatena ao final do conteudo existente (nunca sobrescreve)
  - Nao grava se nenhum campo foi efetivamente alterado
  - Padrao de construcao conforme LOCW043 / LOCW044 do projeto

Formato da mensagem (minusculo):
  alteracao de datas -
  data inicio: xx/xx/xxxx -> yy/yy/yyyy
  data final : xx/xx/xxxx -> yy/yy/yyyy
  periodo    : xx -> yy
  usuario    : xxxxx
  data/hora  : dd/mm/yyyy hh:mm
  ----------------------------------------

@type   Static Function
@author Lui Pazini
@since  22/02/2026
@param  dDtIniOld,  Date,   Valor anterior de FPZ_DTINI
@param  dDtFimOld,  Date,   Valor anterior de FPZ_DTFIM
@param  cPerLocOld, Char,   Valor anterior de FPZ_PERLOC
@param  dDtIniNew,  Date,   Valor novo de FPZ_DTINI
@param  dDtFimNew,  Date,   Valor novo de FPZ_DTFIM
@param  cPerLocNew, Char,   Valor novo de FPZ_PERLOC
@version 1
@return Logical, .T. se o historico foi gravado, .F. se nao houve alteracao
/*/
Static Function LOCA082GH(dDtIniOld, dDtFimOld, cPerLocOld, dDtIniNew, dDtFimNew, cPerLocNew)

// ISSUE: DSERLOCA-10930 - Lui Pazini - 22/02/2026

Local lAlterou  := .F.
Local cHist     := ""
Local cNovoLog  := ""
Local cCodUsr    := RetCodUsr()
Local cUsuario  := Alltrim( UsrFullName(cCodUsr) )
Local cDataHora := DTOC(DATE()) + " " + SUBSTR(TIME(), 1, 5)  // dd/mm/yyyy hh:mm
Local aAreaFPY  := FPY->(GetArea())

    // --- Verificacao de alteracao real (regra de disparo) ---
    lAlterou := ( dDtIniNew  != dDtIniOld              ) .Or. ;
                ( dDtFimNew  != dDtFimOld              ) .Or. ;
                ( ALLTRIM(cPerLocNew) != ALLTRIM(cPerLocOld) )

    // --- Monta mensagem de historico (minusculo, padrao LOCW043/LOCW044) ---
    cNovoLog := "alteracao de datas -"                                          + Chr(13) + Chr(10)
    cNovoLog += "data inicio: " + DTOC(dDtIniOld) + " -> " + DTOC(dDtIniNew)  + Chr(13) + Chr(10)
    cNovoLog += "data final : " + DTOC(dDtFimOld) + " -> " + DTOC(dDtFimNew)  + Chr(13) + Chr(10)
    cNovoLog += "periodo    : " + ALLTRIM(cPerLocOld) + " -> " + ALLTRIM(cPerLocNew) + Chr(13) + Chr(10)
    cNovoLog += "usuario    : " + cUsuario                                      + Chr(13) + Chr(10)
    cNovoLog += "data/hora  : " + cDataHora                                     + Chr(13) + Chr(10)
    cNovoLog += "----------------------------------------"                      + Chr(13) + Chr(10)

    // --- Concatena ao final do historico existente (nunca substitui) ---
    // Padrao identico ao adotado em LOCW043 (linha 147) e LOCW044 (linha 103)
    cHist := FPY->FPY_HIST
    If !Empty(cHist)
        // Garante separacao visual entre entradas anteriores e a nova
        cHist += Chr(13) + Chr(10)
    EndIf
    cHist += cNovoLog

    // --- Grava apenas FPY_HIST; demais campos do FPY ficam intactos ---
    RecLock("FPY", .F.)
        FPY->FPY_HIST := cHist
    MsUnlock()

    RestArea(aAreaFPY)

Return .T.

//---------------------------------------------------------------------------------------------
/*/{Protheus.doc} fAlteraDatasFPZ
Grava diretamente nos campos de data e periodo do registro FPZ
sem passar pelo fluxo MVC, preservando o alias ativo e o buffer
do modelo.

Observacoes sobre o contexto MVC:
  O LOCA082 sempre abre em MODEL_OPERATION_VIEW (somente leitura).
  Nao ha CommitData() pendente, portanto o RecLock direto e seguro —
  o MVC nao tem buffer de escrita ativo que possa sobrescrever os campos.
  O alias FPZ pode estar em EOF durante execucao MVC — por isso o
  posicionamento via DbSetOrder+DbSeek e feito explicitamente aqui.
  GetArea/RestArea garantem que o alias ativo da view nao seja
  alterado apos o retorno desta funcao.
  Apos a gravacao, o chamador (LOCA082AD) tenta oView:Refresh() para
  atualizar a grid visualmente. Se o refresh nao surtir efeito, o
  usuario pode fechar e reabrir o registro — os dados ja estao gravados.

@type   Static Function
@author Lui Pazini
@since  23/02/2026
@version 1
@param  cPedVen,  Character, Pedido de venda (FPZ_PEDVEN)
@param  cProjet,  Character, Projeto (FPZ_PROJET)
@param  cItem,    Character, Item (FPZ_ITEM)
@param  dDtIni,   Date,      Data inicial de locacao (FPZ_DTINI)
@param  dDtFim,   Date,      Data final de locacao (FPZ_DTFIM)
@param  cPerLoc,  Character, Periodo de locacao (FPZ_PERLOC)
@return Logical,  .T. se a gravacao foi realizada com sucesso
/*/
Static Function fAlteraDatasFPZ(cPedVen, cProjet, cItem, dDtIni, dDtFim, cPerLoc)

// ISSUE: DSERLOCA-10930 - Lui Pazini - 23/02/2026

// Salva a area ativa corrente antes de qualquer movimentacao
// Garantia 1: o alias ativo do MVC e restaurado ao sair desta funcao
Local aAreaAtiva := GetArea()
Local aAreaFPZ   := FPZ->(GetArea())
Local lGravou    := .F.

    // --- Garantias 3, 4 e 5: defesa de tipos — nunca gravar NIL ---
    // ValType verifica o tipo real da variavel; fallback para vazio do tipo correto
    If ValType(dDtIni)  != "D" ; dDtIni  := CtoD("") ; EndIf
    If ValType(dDtFim)  != "D" ; dDtFim  := CtoD("") ; EndIf
    If ValType(cPerLoc) != "C" ; cPerLoc := ""        ; EndIf

    // --- Posiciona FPZ pelo indice 1: FILIAL + PEDVEN + PROJET + ITEM ---
    // Em contexto MVC o FPZ pode estar em EOF; posicionamento explicito e obrigatorio
    FPZ->(DbSetOrder(1))
    If FPZ->(DbSeek(xFilial("FPZ") + cPedVen + cProjet + cItem))

        // Confirma chave completa — DbSeek sem softseek pode avancar para outro registro
        If ALLTRIM(FPZ->FPZ_PEDVEN) == ALLTRIM(cPedVen) .And. ;
           ALLTRIM(FPZ->FPZ_PROJET) == ALLTRIM(cProjet) .And. ;
           ALLTRIM(FPZ->FPZ_ITEM)   == ALLTRIM(cItem)

            // --- Garantia 8: toca apenas os campos nao gerenciados pelo buffer MVC ---
            // Garantia 7: SetValue do modelo NAO e usado — acesso direto ao registro
            RecLock("FPZ", .F.)
                FPZ->FPZ_DTINI  := dDtIni
                FPZ->FPZ_DTFIM  := dDtFim
                FPZ->FPZ_PERLOC := cPerLoc
            MsUnlock()

            lGravou := .T.

        EndIf

    EndIf

    // --- Restaura areas na ordem inversa da captura ---
    // Garantia 2: MVC encontra FPZ e alias ativo no estado original
    RestArea(aAreaFPZ)
    RestArea(aAreaAtiva)

Return lGravou

//---------------------------------------------------------------------------------------------
/*/{Protheus.doc} LOCA082GF
Verifica existencia de registro FPZ para o item SC6 selecionado e,
caso nao exista, cria novo registro com os dados basicos do item.

Em contexto MVC os aliases SC6 e FPY podem estar em EOF mesmo com
registros visiveis nas grids. Por isso a leitura dos campos-chave e
feita via modelo (oSC6Mdl / oFPYMdl), com posicionamento explicito
do alias SC6 apenas antes da leitura de campos adicionais (C6_CC etc).

Regras:
  - Se FPZ ja existir: bloqueia e exibe mensagem
  - Se FPZ nao existir: cria registro com campos basicos
  - Nao altera, sobrescreve ou exclui registros existentes
  - Permite datas em branco (vinculo estrutural)

Chave de existencia (Index 1 da FPZ - mesma logica do LOCA021):
  FPZ_FILIAL + FPZ_PEDVEN + FPZ_PROJET + FPZ_ITEM

@type   Static Function
@author Lui Pazini
@since  23/02/2026
@version 1
@param  oView, Object, Referencia da FWFormView ativa
@return Logical, .T. se o registro foi criado com sucesso
/*/
Static Function LOCA082GF(oView)

// ISSUE: DSERLOCA-10931 - Lui Pazini - 23/02/2026
// aAreaAtiva: salva o alias corrente do MVC antes de qualquer movimentacao
// oSC6Mdl / oFPYMdl: modelos usados para leitura confiavel em contexto MVC
// Leitura direta de SC6-> e FPY-> retornava EOF mesmo com registro visivel na grid
Local aAreaAtiva := GetArea()
Local oMdl       := oView:GetModel()
Local oSC6Mdl    := oMdl:GetModel("SC6DETAIL")
Local oFPYMdl    := oMdl:GetModel("FPYMASTER")
Local aAreaFPZ   := FPZ->(GetArea())
Local aAreaSC6   := SC6->(GetArea())
Local cPedVen  := ""
Local cProjet  := ""
Local cItem    := ""
Local lRet     := .F.

    cPedVen := ALLTRIM(oFPYMdl:GetValue("FPY_PEDVEN"))
    cProjet := ALLTRIM(oFPYMdl:GetValue("FPY_PROJET"))
    cItem   := ALLTRIM(oSC6Mdl:GetValue("C6_ITEM"))

    // Valida se ha item SC6 posicionado via modelo (alias pode estar em EOF em MVC)
    If Empty(cPedVen) .Or. Empty(cItem)
        MsgAlert( "Nenhum item selecionado na grid."    + Chr(13) + ;
                  "Posicione o cursor em um item SC6 e tente novamente." , ;
                  "Operacao Nao Permitida" )
        RestArea(aAreaFPZ)
        RestArea(aAreaSC6)
        RestArea(aAreaAtiva)
        Return .F.
    EndIf

    // Verifica existencia de FPZ pela mesma chave do LOCA021 (Index 1)
    // FPZ_FILIAL + FPZ_PEDVEN + FPZ_PROJET + FPZ_ITEM
    FPZ->(dbSetOrder(1))
    If FPZ->(dbSeek(xFilial("FPZ") + PadR(cPedVen, TamSx3("FPZ_PEDVEN")[1]);
                                   + PadR(cProjet, TamSx3("FPZ_PROJET")[1]);
                                   + PadR(cItem,   TamSx3("FPZ_ITEM")[1])))

        MsgAlert( "Registro FPZ ja existente para este item. Operacao nao permitida." , ;
                  "Operacao Nao Permitida" )
        RestArea(aAreaFPZ)
        RestArea(aAreaSC6)
        RestArea(aAreaAtiva)
        Return .F.
    Else

        // Posiciona SC6 explicitamente para leitura de campos adicionais
        SC6->(dbSetOrder(1))
        SC6->(dbSeek(xFilial("SC6") + cPedVen + cItem))

        // Cria registro FPZ com dados basicos do item SC6
        RecLock("FPZ", .T.)
            FPZ->FPZ_FILIAL  := xFilial("FPZ")
            FPZ->FPZ_PEDVEN  := cPedVen
            FPZ->FPZ_PROJET  := cProjet
            FPZ->FPZ_AS      := POSICIONE("FPA" , 1 , XFILIAL("FPA")+cProjet , "FPA_AS")
            FPZ->FPZ_OBRA    := POSICIONE("FPA" , 1 , XFILIAL("FPA")+cProjet , "FPA_OBRA")
            FPZ->FPZ_VIAGEM  := POSICIONE("FPA" , 1 , XFILIAL("FPA")+cProjet , "FPA_VIAGEM")
            FPZ->FPZ_TES     := SC6->C6_TES
            FPZ->FPZ_VALUNI  := SC6->C6_PRCVEN
            FPZ->FPZ_TOTAL   := SC6->C6_VALOR
            FPZ->FPZ_ITEM    := cItem
            FPZ->FPZ_DTPED   := dDataBase
            FPZ->FPZ_EXTRA   := "N"
            FPZ->FPZ_DTINI   := CtoD("")
            FPZ->FPZ_DTFIM   := CtoD("")
            FPZ->FPZ_PERLOC  := ""
            FPZ->FPZ_CCUSTO  := SC6->C6_CC
            If FPZ->(FieldPos("FPZ_PROD")) > 0
                FPZ->FPZ_PROD := SC6->C6_PRODUTO
            EndIf
            If FPZ->(FieldPos("FPZ_ITMFPZ")) > 0
                FPZ->FPZ_ITMFPZ := cItem
            EndIf
            If FPZ->(FieldPos("FPZ_QUANT")) > 0
                FPZ->FPZ_QUANT := SC6->C6_QTDVEN
            EndIf
        MsUnlock()

        MsgInfo( "Registro FPZ gerado com sucesso!" , "Informacao" )
        lRet := .T.
    EndIf
    RestArea(aAreaFPZ)
    RestArea(aAreaSC6)
    RestArea(aAreaAtiva)
    oView:Refresh()
Return lRet

/*/{Protheus.doc} 
ITUP Business - TOTVS RENTAL
Reenviar para Produção

@type Function
@author Dennis Calabrez
@since 23/03/2026
@version P12
/*/
Static Function LOCA082RP(oView)

    RecLock("FPY", .F.)
    FPY->FPY_APROV  := ""
    MsUnlock()

    FWAlertSuccess(STR0006, STR0005) //"LOCA082"
Return
