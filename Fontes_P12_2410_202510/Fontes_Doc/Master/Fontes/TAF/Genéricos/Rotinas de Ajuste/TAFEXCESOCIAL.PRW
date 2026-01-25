#Include "PROTHEUS.CH"
#Include "RWMAKE.CH"
#INCLUDE "TOPCONN.CH"
#INCLUDE "FILEIO.CH"   
#INCLUDE "FWMVCDEF.CH"

Static lLaySimplif	:= TafLayESoc("S_01_00_00")
Static __lTempInDb  := Val(GetVersao(.F.)) > 11 .And. AllTrim(GetRpoRelease()) >= "12.1.005"
Static __aModels    := Nil 
 
//-------------------------------------------------------------------
/*/{Protheus.doc} TafExceSocial
Função criada para que sejam excluídos os eventos do eSocial da base do TAF 
quando necessário e também gerado o evento S-3000 em lote quando necessário.

@author Rodrigo Aguilar
@since 28/12/2018
@version 1.0
/*/
//-------------------------------------------------------------------
Function tafExceSocial() 

    Local lTabela   := .F.
    Local lNper     := .F.
    Local lPer      := .T.

    Local lExcTrans := .F.
    Local lExcRej   := .F.
    Local lExcPen   := .F.

    Local aFiliais := {}

    Local oStepWiz, oNewPag, oPanelBkg, oPanEvt := Nil
    Local cAliasEvts := GetNextAlias()
    Local oTempEvts := Nil 
    Local cErroSQL := ""

    Local dDtIni := cTod( '  /  /  ' )
    Local dDtFim := cTod( '  /  /  ' )
    Local aItensExc := {}
    Local lExecute := .F.
    Local lLogGrv := .F.
    Local lCheck := .F.

    If FWIsAdmin( __cUserID )

        oStepWiz:= FWWizardControl():New()

            oStepWiz:ActiveUISteps()

            //----------------------------------------
            // Pagina 1  - Boas Vindas
            //----------------------------------------
            oNewPag := oStepWiz:AddStep( "1" )
            oNewPag:SetStepDescription("Introdução a Rotina")
            oNewPag:SetConstruction( { | Panel | TafBVindas( Panel, @lCheck ) } )
            oNewPag:SetCancelAction({||.T.})
            oNewPag:SetNextAction( {||lCheck})

            //----------------------------------------
            // Pagina 2  - Selecione o grupo de eventos
            //----------------------------------------
            /*
            oNewPag := oStepWiz:AddStep( "2" )
            oNewPag:SetStepDescription( "Grupo de Eventos" )
            oNewPag:SetConstruction( { | Panel | TafGrpEvt( Panel, @lTabela, @lNper, @lPer ) } )
            oNewPag:SetCancelAction({||.T.})
            */
            //-------------------------------------------
            // Pagina 3  - Refine os Parâmetros e filtros
            //-------------------------------------------
            oNewPag := oStepWiz:AddStep( "2", { | Panel | TafParFil( Panel, @lExcTrans, @lExcRej, @lExcPen,@dDtIni,@dDtFim) } )
            oNewPag:SetStepDescription( "Parâmetros e Filtros" )
            oNewPag:SetCancelAction({||.T.})
            oNewPag:SetNextAction( {||validEventos(lExcTrans,lExcRej,lExcPen,dDtIni,dDtFim)})

            //----------------------------------
            // Pagina 4  - Selecione os Eventos
            //----------------------------------
            oNewPag := oStepWiz:AddStep( "3", {|Panel|loadFils(oStepWiz,@aFiliais,Panel,@lExcTrans,@lExcRej,@lExcPen,cAliasEvts,@oTempEvts) })   
            oNewPag:SetStepDescription( "Eventos do eSocial" )
            oNewPag:SetCancelAction({||.T.})
            oNewPag:SetPrevAction({|| MsgAlert( 'Não é possível retornar a página anterior' ), .F.})
            oNewPag:SetNextAction({|| lExecute:= .T.,.T.})

        oStepWiz:Activate()


        oStepWiz:Destroy()

        If lExecute
            FwMsgRun(,{|obj|TafProcExc(@lExcTrans, @lExcRej, @lExcPen, aFiliais,cAliasEvts,oTempEvts,dDtIni,dDtFim,aItensExc)},"Exclusao de Eventos em Lote","Processando ...")
            ShowLogExc(aItensExc,@lLogGrv) 
        EndIf 

        If __lTempInDb
            If oTempEvts != Nil 
                If !TafDelTempTable(oTempEvts:GetRealName(),@cErroSQL)
                    MsgInfo (cErroSQL,"Exclusão Tabela Temporária") 
                EndIf 
            EndIf 
        EndIf 

    Else
        cError := " O usuário " + cUserName + " não pertence ao grupo de administradores, entre em contato com o administrador do sistema."

        MsgStop( cError, "Usuário sem acesso" )
    EndIf
    
Return Nil 

//-------------------------------------------------------------------
/*/{Protheus.doc} loadFils
Valida se a Filial foi preenchida antes de chamar o proximo panel

@param oWizard - Objeto Dialog
@param aFils - Filiais Selecionadas
@param oPanEvt - Painel que o evento será criado
@param LExcTrans - Indica se exclui eventos transmitidos
@param lExcRej   - Indica se exclui eventos Rejeitados pelo Governo
@param lExcPen   - Indica se Exclui eventos pendentes de envio ao Governo
@param cAliasEvts - Alias utilizado no objeto Mark
@param oTempTable - Objeto referente a tabela temporaria 

@author Rodrigo Aguilar
@since 22/01/2019
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function loadFils(oWizard,aFils,oPanEvt,lExcTrans,lExcRej,lExcPen,cAliasEvts,oTempEvts)

    aFils := xFunTelaFil(.T.,,.T.,.F.,.F.,,,.T.)
    While  Empty(aFils)
        If MsgYesNo("Atenção, ao cancelar a seleção de filiais a Wizard será encerrada, deseja continuar e encerrar o processo?" , "Prosseguir ?") 
            oWizard:oOwner:End()
            Exit
        Else
            aFils := xFunTelaFil(.T.,,.T.,.F.,.F.,,,.T.) 
        EndIf
    EndDo

    If Len(aFils) > 0
        MsgRun("Carregando os Registros", "Carregando...", {||TafMarkEvt(oPanEvt,@lExcTrans,@lExcRej,@lExcPen,cAliasEvts,@oTempEvts)})
    EndIf 

Return !Empty(aFils)

//-------------------------------------------------------------------
/*/{Protheus.doc} validEventos
Valida se foi selecionado ao menos 1 tipo de evento e se os campos
de data foram preenchidos.

@param LExcTrans - Indica se exclui eventos transmitidos
@param lExcRej   - Indica se exclui eventos Rejeitados pelo Governo
@param lExcPen   - Indica se Exclui eventos pendentes de envio ao Governo
@param dDtIni    - Data Inicial
@param dDtFim    - Data Final 

@author Rodrigo Aguilar
@since 22/01/2019
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function validEventos(lExcTrans,lExcRej,lExcPen,dDtIni,dDtFim)

    If !(lExcTrans .Or. lExcRej .Or. lExcPen)
        MsgInfo("É necessário Selecionar uma opção de eventos.","SELECIONE UMA OPÇÃO")
        Return .F.
    EndIf 

    If Empty(dDtIni) .Or. Empty(dDtFim)
        MsgInfo("É necessário informar a Data Inicial e Final para a seleção dos eventos.","DATA INVÁLIDA")
        Return .F.
    EndIf 

Return MsgYesNo("Atenção, ao avançar não será possível retornar para redefinir os filtros, deseja continuar ?" , "Prosseguir ?") 

//-------------------------------------------------------------------
/*/{Protheus.doc} TafBVindas
Boas Vindas a rotina de exclusão em lote

@Param oPanel - Painel onde serão criados os objetos da tela

@author Rodrigo Aguilar
@since 28/12/2018
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function TafBVindas( oPanel, lCheck )

Local cDescr    := ""
Local nLin      := 0
Local nCol      := 0
Local nWidth    := 0
Local nHeight   := 0

nWidth  := oPanel:NCLIENTWIDTH * 0.47
nCol    := 10
nHeight := 100

nLin := 10

cDescr := 'Bem vindo a rotina de exclusão em lote do eSocial !'
WizSay(cDescr,oPanel,nLin,nCol,6,"#0c9abe",,.T.,.F.,1,nWidth,020)

nLin +=40
cDescr := 'O objetivo desta rotina é excluir da base de dados do TAF eventos que estão pendentes de transmissão ou que foram rejeitados pelo governo, dentro de um período parametrizável. '
WizSay(cDescr,oPanel,nLin,nCol,5,"#737373",,.F.,.F.,1,nWidth,nHeight)

nLin +=40
cDescr := 'Não serão afetados os eventos que já foram transmitidos e aceitos pelo governo, ou seja, os eventos que possuem o número de recibo preenchido no TAF. Portanto, essa rotina NÃO gerará eventos do tipo S-3000.'
WizSay(cDescr,oPanel,nLin,nCol,5,"#737373",,.F.,.F.,1,nWidth,nHeight)

/*
nLin := oPanel:NCLIENTHEIGHT - (oPanel:NCLIENTHEIGHT * 0.64)
cDescr := 'TODA exclusão realizada por essa rotina será registrada internamente no sistema para possibilidade de posterior consulta.'
WizSay(cDescr,oPanel,nLin,nCol,4,"#000000",,.F.,.F.,1,nWidth,nHeight)
*/

nLin := oPanel:NCLIENTHEIGHT - (oPanel:NCLIENTHEIGHT * 0.65)
cDescr := 'ATENÇÃO: Os processos realizados por essa rotina podem causar problemas de paridade com seu produto de RH, deve-se utilizar essa rotina somente como saída contorno para tratamentos pontuais de acerto de base.'
WizSay(cDescr,oPanel,nLin,nCol,4,"#ff0000",,.F.,.F.,1,nWidth,nHeight)

nLin := oPanel:NCLIENTHEIGHT - (oPanel:NCLIENTHEIGHT * 0.55)
oCheck := TCheckBox():New(nLin,nCol,'Li e compreendi que ao executar esta rotina estarei sujeito à problemas de paridade com meu produto de RH.',{||lCheck},oPanel,nWidth,nHeight,,{||lCheck := !lCheck},,,,,,.T.,,,)

Return Nil 

//-------------------------------------------------------------------
/*/{Protheus.doc} TafGrpEvt
Cria primeira página da Wizard

@Param oPanel  - Painel onde serão criados os objetos da tela
       lTabela - Define se os eventos de tabela foram selecionados 
       lNper   - Define se os eventos não períodicos foram selecionados
       lPer    - Define se os eventos periódicos forma selecionados

@author Rodrigo Aguilar
@since 28/12/2018
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function TafGrpEvt( oPanel, lTabela, lNper, lPer )

Local cDescr    := ""
Local oCheck1   := Nil 
Local oCheck2   := Nil 
Local oCheck3   := Nil
Local oFontC    := Nil 
Local nLin      := 0
Local nCol      := 0
Local nWidth    := 0

nWidth  := oPanel:NCLIENTWIDTH * 0.47
nCol    := 10
nLin    := 10
nHeight := 100

oFontC  := TFont():New('Arial',,14,,.T.)

cDescr := 'Selecione qual o grupo de eventos que deseja excluir do TAF, você poderá refinar os filtros nas próximas etapas desta rotina:'
WizSay(cDescr,oPanel,nLin,nCol,4,"#3C769C",,.T.,.F.,1,nWidth,020)

nLin += 40 
oCheck1 := TCheckBox():New( nLin,nCol,'Eventos de Tabela'       ,{||lTabela} ,oPanel,nWidth,20,,{||lTabela},,,CLR_GRAY,,,.T.,,,)
oCheck1:lReadOnly := .T.

nLin += 15
oCheck2 := TCheckBox():New(nLin,nCol,'Eventos Não Periódicos'   ,{||lNper}   ,oPanel,nWidth,20,,{||lNper},,,CLR_GRAY,,,.T.,,,)
oCheck2:lReadOnly := .T.

nLin += 15
oCheck3 := TCheckBox():New(nLin,nCol,'Eventos Periódicos'       ,{||lPer}   ,oPanel,nWidth,20,,{||lPer},oFontC,,,,,.T.,,,)
oCheck3:lReadOnly := .T.

nLin := oPanel:NCLIENTHEIGHT - (oPanel:NCLIENTHEIGHT * 0.58)
cDescr := 'ATENÇÃO: Os processos realizados por essa rotina podem causar problemas de paridade com seu produto de RH, deve-se utilizar essa rotina somente como saída contorno para tratamentos pontuais de acerto de base.'
WizSay(cDescr,oPanel,nLin,nCol,4,"#ff0000",,.F.,.F.,1,nWidth,nHeight)


Return

//-------------------------------------------------------------------
/*/{Protheus.doc} TafParFil
Cria segunda página da Wizard

@Param oPanel - Painel onde serão criados os objetos da tela
       LExcTrans - Indica se exclui eventos transmitidos
       lExcRej   - Indica se exclui eventos Rejeitados pelo Governo
       lExcPen   - Indica se Exclui eventos pendentes de envio ao Governo
       dDtIni    - Data Inicial
       dDtFim    - Data Final 

@author Rodrigo Aguilar
@since 28/12/2018
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function TafParFil( oPanel, lExcTrans, lExcRej, lExcPen, dDtIni, dDtFim)

Local cDescr    := ""
Local oCheck1   := Nil 
Local oCheck2   := Nil 
Local oCheck3   := Nil
Local oFontC    := Nil 
Local nLin      := 0
Local nCol      := 0
Local nWidth    := 0

nWidth  := oPanel:NCLIENTWIDTH * 0.47
nCol    := 10
nLin    := 10
nHeight := 100
oFontC  := TFont():New('Arial',,15,,.F.)


cDescr := 'Refine os filtros de acordo com os grupos selecionados na etapa anterior:'
WizSay(cDescr,oPanel,nLin,nCol,4,"#3C769C",,.T.,.F.,1,nWidth,020)

nLin += 35
cDescr := "Data Inicial"
WizSay(cDescr,oPanel,nLin,nCol,3,"#000000",,.F.,.F.,1,100,20)
TGet():New(nLin-2,nCol+30,{|u|If( PCount()==0,dDtIni,dDtIni := u )},oPanel,065,009,"@!",,0,,,.F.,,.T.,,.F.,,.F.,.F.,,.F.,.F.,,"Data Inicial",,,,.T.) 

cDescr := "Data Final"
WizSay(cDescr,oPanel,nLin,nCol+115,3,"#000000",,.F.,.F.,1,100,20)
TGet():New(nLin-2,nCol+144,{|u|If( PCount()==0,dDtFim,dDtFim := u )},oPanel,065,009,"@!",,0,,,.F.,,.T.,,.F.,,.F.,.F.,,.F.,.F.,,"Data Inicial",,,,.T.) 

nLin+=12
cDescr := "* Para eventos Periódicos será considerado apenas Mês/Ano da competência conforme previsto no Layout do eSocial, se as datas não forem informadas serão processados todos os registros dos eventos selecionados "
WizSay(cDescr,oPanel,nLin,nCol,3,"#888",,.T.,.F.,1,nWidth,25)
/*
nLin+=20

cDescr := 'Exclui Eventos já Transmitidos ao Governo ( Gerar S-3000 )'
oCheck1 := TCheckBox():New(085,010,cDescr, { || LExcTrans }, oPanel,nWidth,020,,{|| LExcTrans := !LExcTrans },,,CLR_GRAY,,,.T.,,,)
oCheck1:lReadOnly := .T.
*/
nLin+=40

cDescr := 'Excluir eventos rejeitados pelo Governo da base do TAF'
oCheck2 := TCheckBox():New(nLin,010,cDescr, { || lExcRej }, oPanel,nWidth,020,,{|| lExcRej := !lExcRej },oFontC,,,,,.T.,,,)
//oCheck2:lReadOnly := .T.

nLin+=20
cDescr := 'Excluir eventos pendentes de envio ao Governo da base do TAF'
oCheck3 := TCheckBox():New(nLin,010,cDescr, { || lExcPen }, oPanel,nWidth,020,,{|| lExcPen := !lExcPen },oFontC,,,,,.T.,,,)
//oCheck3:lReadOnly := .T.


nLin := oPanel:NCLIENTHEIGHT - (oPanel:NCLIENTHEIGHT * 0.58)
cDescr := 'ATENÇÃO: Os processos realizados por essa rotina podem causar problemas de paridade com seu produto de RH, deve-se utilizar essa rotina somente como saída contorno para tratamentos pontuais de acerto de base.'
WizSay(cDescr,oPanel,nLin,nCol,4,"#ff0000",,.F.,.F.,1,nWidth,nHeight)

Return .T.

//-------------------------------------------------------------------
/*/{Protheus.doc} TafMarkEvt
Seleciona os eventos do eSocial que devem ser processados

@Param oPanel - Painel onde serão criados os objetos da tela
       LExcTrans - Indica se exclui eventos transmitidos
       lExcRej   - Indica se exclui eventos Rejeitados pelo Governo
       lExcPen   - Indica se Exclui eventos pendentes de envio ao Governo
       cAliasEvts - Alias utilizado no objeto Mark
       oTempTable - Objeto referente a tabela temporaria 

@author Rodrigo Aguilar
@since 28/12/2018
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function TafMarkEvt(oPanel,lExcTrans,lExcRej,lExcPen,cAliasEvts,oTempTable)

Local lInverte  := .F.
Local aStruct   := {}
Local aInfo     := {}
Local aEvteSoc  := {}
Local nli       := 0
Local cMark     := GetMark()
Local cDescr    := ""
Local nLin      := 0
Local nCol      := 0
Local nWidth    := 0
Local nHeight   := 0

nWidth  := oPanel:NCLIENTWIDTH * 0.485
nCol    := 10
nLin    := 10
nHeight := 100


//------------------------------
//Estrutura da tabela temporaria
//------------------------------
Aadd( aStruct,{ "OK"     , "C" , 2    , 0 } )
Aadd( aStruct,{ "Grupo"  , "C" , 30   , 0 } )
Aadd( aStruct,{ "CodEvt" , "C" , 20   , 0 } )
Aadd( aStruct,{ "DesEvt" , "C" , 200  , 0 } )

If __lTempInDb

    oTempTable := FWTemporaryTable():New(cAliasEvts)
    oTempTable:SetFields(aStruct)
	oTempTable:AddIndex("I1",{"CodEvt"})
	oTempTable:Create()
Else 
    /*Se necessário Implementar o uso da rotina com criaTrab para versao11*/
    //cArq := Criatrab( aStruct, .T. )
    //dbUseArea(.T., ,cArq,cAliasEvts )
EndIf 

//Retornar os eventos do eSocial
aEvteSoc := TAFRotinas(,,,2)

For nli := 1 To Len( aEvteSoc )

    If Alltrim( aEvteSoc[ nli, 4] ) $ ( 'S-1200|S-1210|S-1202') //Tratamento para primeira versão que trata apenas S-1200 e S-1210
        //Por haver apenas 2 itens não vale a pena usar o INSERT INTO na tabela temporaria
        RecLock( cAliasEvts, .T. )
            (cAliasEvts)->Grupo  := "Evento Periódico"
            (cAliasEvts)->CodEvt := aEvteSoc[ nli, 4]
            (cAliasEvts)->DesEvt := iif( Alltrim( aEvteSoc[ nli, 4] ) $ ( 'S-1200'), 'Folha de Pagamento', iif( Alltrim( aEvteSoc[ nli, 4] ) $ ( 'S-1202'), 'Folha de Servidor', 'Pagamento Mensal') )
        (cAliasEvts)->( MsUnlock() )
    EndIf 
Next
(cAliasEvts)->( dbGotop() )

//Definindo a visualização das informações
aCpoBro := { { "OK"     , , " "   , "@!" } ,;
             { "Grupo"  , , "Grupo de Eventos"  , "@!" } ,;
             { "CodEvt" , , "Código do Evento"     , "@!" },;
             { "DesEvt" , , "Descrição do Evento"    ,"@!" } }


cDescr := 'Selecione os Eventos que deseja processar a exclusão em Lote:'
WizSay(cDescr,oPanel,nLin,nCol,4,"#3C769C",,.T.,.F.,1,nWidth,020)

nLin += 15
TButton():New(nLin,nCol, "Marcar / Desmarcar todos", oPanel, { || TafMark( cAliasEvts, cMark ) }, 85,15,,,.F.,.T.,.F.,,.F.,,,.F. )

nLin += 20
nHeight := oPanel:NCLIENTHEIGHT - (oPanel:NCLIENTHEIGHT * 0.60)
MsSelect():New(cAliasEvts,"OK","",aCpoBro,@lInverte,@cMark,{nLin,nCol,nHeight,nWidth},,,oPanel,,{})


nWidth  := oPanel:NCLIENTWIDTH * 0.47
nLin := oPanel:NCLIENTHEIGHT - (oPanel:NCLIENTHEIGHT * 0.58)
cDescr := 'ATENÇÃO: Os processos realizados por essa rotina podem causar problemas de paridade com seu produto de RH, deve-se utilizar essa rotina somente como saída contorno para tratamentos pontuais de acerto de base.'
WizSay(cDescr,oPanel,nLin,nCol,4,"#ff0000",,.F.,.F.,1,nWidth,nHeight)

Return Nil 

//-------------------------------------------------------------------
/*/{Protheus.doc} TafMark
Marca/Desmarca os Eventos

@Param cAliasTRB - Arquivo temporário
       cMark     - Mark de seleção

@author Rodrigo Aguilar
@since 30/12/2018
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function TafMark( cAliasTRB, cMark ) 

dbSelectArea( cAliasTRB ) 
(cAliasTRB)->( dbGotop() )

Do While (cAliasTRB)->( !EoF() )
    
    If RecLock( cAliasTRB, .F. ) 

        If (cAliasTRB)->OK == cMark

            (cAliasTRB)->OK  := ' '
        Else

            (cAliasTRB)->OK  := cMark
        Endif
        
        (cAliasTRB)->( MsUnLock() )
    EndIf 

    (cAliasTRB)->( dbSkip() )
EndDo 

(cAliasTRB)->( dbGotop() )

Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} TafProcExc
Carrega os evento marcado para exclusão conforme os parâmetros 
selecionados.

@param lExcTrans - Indica se exclui eventos transmitidos
@param lExcRej   - Indica se exclui eventos Rejeitados pelo Governo
@param lExcPen   - Indica se Exclui eventos pendentes de envio ao Governo
@param aFiliais  - Filiais 
@oaram cAliasEvts - Alias referente ao arquivo de trabalho utilizado no
objeto Mark (eventos selecionados)
@param oTempEvts - Objeto referente ao FWTemporaryTable utilizado no Mark
@param dDataIni - Data de Inicio
@param dDataFim - Data de Fim
@param aItensExc - Array com os itens Excluidos

@author Evandro dos Santos Oliveira
@since 22/01/2019
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function TafProcExc(lExcTrans,lExcRej,lExcPen,aFiliais,cAliasEvts,oTempEvts,dDataIni,dDataFim,aItensExc)

    Local cStatus       := ""
    Local cSql          := ""
    Local aEvento       := {}
    Local cLayout       := ""
    Local cOk	        := ""
    Local cAliasEvt     := ""
    Local cEvento       := ""
    Local cIdTrab       := ""
    Local nRecno        := 0
    Local nX            := 0
    Local oTempFil      := Nil
    Local cFonte        := ""
    Local cTextoFin     := ""
    Local cAliasTemp    := ""
    Local cIndApu       := ""

    cStatus := IIf(lExcPen,cStatus := "' ','0','1'","")

    If lExcRej
        cStatus += IIf(Empty(cStatus),"",",")
        cStatus += "'3'"
    EndIf 

    (cAliasEvts)->(dbGotop())

    While (cAliasEvts)->(!Eof()) 

        cLayout := AllTrim((cAliasEvts)->CodEvt)
        cOk		:= AllTrim((cAliasEvts)->OK)

        If !Empty(cLayout) .And. !Empty(cOk)

            aEvento     := TAFRotinas(cLayout,4,.F.,2)
            cFonte      := aEvento[01]
            cAliasEvt   := aEvento[03]
            cEvento     := aEvento[04]
            cTipoEvt    := aEvento[12]
            cCmpData    := aEvento[06]
            cIdTrab     := aEvento[11]

            If cTipoEvt != 'T' .And. TAFAlsInDic(cAliasEvt)
            
                cSql := " SELECT '" + cEvento + "' EVENTO " 
                cSql += " ,"  + cAliasEvt + "_FILIAL FILIAL "
                cSql += " ,"  + cAliasEvt + "_STATUS STATUS "
                cSql += " ,'" + cAliasEvt + "' ALIASEVT "

                If Empty(cIdTrab)
                    cSql += " ,' ' IDTRABAL "
                Else
                    cSql += " ,"  + cIdTrab   + " IDTRABAL "
                EndIf 

                cSql += " , R_E_C_N_O_  RECNO "
                cSql += " FROM  "   + RetSqlName(cAliasEvt)  
                cSql += " WHERE " 

                cSql += getSqlFiliais(cAliasEvt,aFiliais,@oTempFil,cAliasTemp)
                cSql += " AND " + cAliasEvt + "_ATIVO = '1' " 

                If cAliasEvt == "C9V" .Or. cAliasEvt == "C91" 

                    cSql += " AND " + cAliasEvt +"_NOMEVE = '" + StrTran(cLayout,"-","") + "'"

                    If cAliasEvt == "C9V"
                        cSql += " AND C9V_NOMEVE != 'TAUTO' "
                    EndIf 
                EndIf

                If  cTipoEvt == "M"
                    
                    If lLaySimplif
                    
                        cIndApu := Space(GetSx3Cache(cAliasEvt + "_INDAPU", "X3_TAMANHO"))
                    
                    EndIf

                    cSql += " AND ( "

                    If !lLaySimplif

                        cSql += " (" + cAliasEvt + "_INDAPU = '1' "

                    Else

                        cSql += " ((" + cAliasEvt + "_INDAPU = '1' "
                        cSql += " OR " + cAliasEvt + "_INDAPU = '" + cIndApu + "') "

                    EndIf

                    cSql += " AND " + cAliasEvt + "_PERAPU >= '" + AnoMes(dDataIni) + "'"
                    cSql += " AND " + cAliasEvt + "_PERAPU <= '" + AnoMes(dDataFim) + "')"

                    If !lLaySimplif

                        cSql += " OR (" + cAliasEvt + "_INDAPU = '2' "

                    Else

                        cSql += " OR ((" + cAliasEvt + "_INDAPU = '2' "
                        cSql += " OR " + cAliasEvt + "_INDAPU = '" + cIndApu + "') "

                    EndIf

                    cSql += " AND " + cAliasEvt +  "_PERAPU BETWEEN '" + AllTrim(Str(Year(dDataIni))) + "' AND '" + AllTrim(Str(Year(dDataFim))) + "')"
                    cSql += " OR (" + cAliasEvt + "_INDAPU = '" + cIndApu + "' "
                    cSql += " AND " + cCmpData + " = ' ' AND '" + cAliasEvt + "' = 'CMJ')" //Gera o evento 3000 quando nao for mensal.
                    cSql += ")"
                ElseIf cTipoEvt == "E" .And. !Empty(AllTrim(cCmpData)) .And. cAliasEvt != "CMJ"
                    cSql += " AND " + cCmpData + " >= '" + DtoS(dDataIni) + "'"
                    cSql += " AND " + cCmpData + " <= '" + DtoS(dDataFim) + "'"
                EndIf

                cSql += " AND "
                cSql += cAliasEvt + "_STATUS IN (" + cStatus + ")" 
                cSql += " AND D_E_L_E_T_ = ' ' "

                execExclusao(cSql,cFonte,aItensExc,cAliasEvt)
            EndIf 
        EndIf 

        (cAliasEvts)->(dbSkip())
    EndDo

  Return Nil 

//-------------------------------------------------------------------
/*/{Protheus.doc} getSqlFiliais
Retorna trecho da query referente ao filtro das filiais. Para não
haver estouro de tamanho é utilizado um temporary table para o 
armazenamento das filiais.

@param cAliasEvt - Alias referente ao evento que será excluido
@param aFiliais - Array com as filias que deverão compor a query
@param oTempFil - Objeto referente ao Temporary Table utilizado
para armazenar as filias (@referência)

@author Evandro dos Santos Oliveira
@since 22/01/2019
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function getSqlFiliais(cAliasEvt,aFiliais,oTempFil,cAliasTemp)

    Local cSqlFils      := ""
    Local cSqlRet       := ""
    Local aStruct       := {}
    Local nX            := 0

    Default oTempFil := Nil 

    If __lTempInDb

        If oTempFil == Nil 

            cAliasTemp := GetNextAlias()

            Aadd( aStruct,{"EVENTO","C",6, 0 } )
            Aadd( aStruct,{"FILIAL","C",GetSx3Cache("C1E_CODFIL","X3_TAMANHO"), 0 } )

            oTempFil := FWTemporaryTable():New(cAliasTemp)
            oTempFil:SetFields(aStruct)
            oTempFil:AddIndex("I1",{"FILIAL"})
            oTempFil:Create()
        EndIf 
        
        For nX := 1 To Len(aFiliais)

            If aFiliais[nX][1]

                cSqlFils := " INSERT INTO " + oTempFil:GetRealName()
                cSqlFils += " (EVENTO,FILIAL)"
                
                If cAliasEvt == "C1E"
                    cSqlFils += " VALUES ('" + cAliasEvt + "," + aFiliais[nX][2] + "')"
                Else 
                    cSqlFils += " VALUES ('" + cAliasEvt + "','" + xFilial(cAliasEvt,aFiliais[nX][2]) + "')"
                EndIf 

                If TCSQLExec (cSqlFils) < 0
                    MsgStop(TCSQLError(),"Tabela Temporaria Filial")
                    nX := Len(aFiliais)+1
                EndIf
            EndIf
        Next nX 

        If cAliasEvt == "C1E"
            cSqlRet := " " + cAliasEvt + "_FILTAF "
        Else
            cSqlRet := " " + cAliasEvt + "_FILIAL"
        EndIf 

        cSqlRet += " IN (SELECT FILIAL FROM " + oTempFil:GetRealName() + " WHERE EVENTO = '"+ cAliasEvt +  "')" 

        If cAliasEvt == "C1E"
            cSqlRet += " AND C1E_MATRIZ = 'T' "
        EndIf 

    Else
        //Se necessario criar mecanismo para seleção de filias atraves do array a Filiais.. não eh possivel usar tempTable na 11
    EndIf 

Return cSqlRet

//-------------------------------------------------------------------
/*/{Protheus.doc} execExclusao
Executa a Exclusão lógica dos registros 

@param cSql - Query preparada de acordo com os parâmetros selecionados
@param cFonte - Nome do Fonte relativo ao modelo que será utilizado
para excluir os registros.

@author Evandro dos Santos Oliveira
@since 22/01/2019
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function execExclusao(cSql,cFonte,aItensExc,cAliasTAF)

    Local cChave    := ""
    Local cEvento   := ""
    Local cIdTrab   := ""
    Local nRecno    := 0

    dbSelectArea("C9V")
    
    TCQuery cSql New Alias 'rsFilial'
    
    While rsFilial->(!Eof())

        cStatus := rsFilial->STATUS
        cFilAlias := rsFilial->FILIAL
        cEvento := rsFilial->EVENTO 
        nRecno  := rsFilial->RECNO 
        cIdTrab := rsFilial->IDTRABAL 

        (cAliasTAF)->(dbGoTo(nRecno))

        If (cAliasTAF)->(!Eof())

            oModel := FWLoadModel(cFonte)
            oModel := getModelCache(cFonte)
            FwFormCommit(oModel)
            oModel:DeActivate()

            //Reabre registro anterior
            cChave := (cAliasTAF)->&(cAliasTAF + "_ID" + "+" + cAliasTAF + "_VERANT")
            TAFRastro(cAliasTAF,1,cChave,.T.)

            aAdd(aItensExc,{cAliasTAF,(cAliasTAF)->&(cAliasTAF+"_ID"),(cAliasTAF)->&(cAliasTAF+"_VERSAO"),getDescricao(cEvento,cIdTrab,cFilAlias),nRecno, cFilAlias, cEvento, cStatus})
        Else
            TafConOut('Recno ' + cValToChar(nRecno) + ' não encontrado na tabela ' + cAliasTAF)
        EndIf 

        rsFilial->(dbSkip())
    EndDo

    rsFilial->(dbCloseArea())

Return Nil 

//-------------------------------------------------------------------
/*/{Protheus.doc} getDescricao
Retorna a descrição do evento que está sendo excluido

@param cEvento - Evento excluido
@param cIdTrab - Id do Trabalhador

@author Evandro dos Santos Oliveira
@since 22/01/2019
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function getDescricao(cEvento,cIdTrab,cFilAlias)

    Local cDesc         := ""
    
    Default cEvento     := ""
    Default cIdTrab     := ""
    Default cFilAlias   := xFilial("C9V")

    Do Case 

        Case cEvento $ "S-1200|S-1210|S-1202"

            If cEvento == "S-1200" 
                
                cDesc := AllTrim(C91->C91_NOME)
            EndIf 

            If Empty(cDesc)
                C9V->(dbSetOrder(2))
                C9V->(MsSeek(xFilial('C9V',cFilAlias)+cIdTrab+"1"))
                cDesc := cEvento + " - " + AllTrim(C9V->C9V_NOME)
            EndIf 

    End Case 

Return cDesc 

//-------------------------------------------------------------------
/*/{Protheus.doc} getModelCache
Retorna o Modelo a ser utilizado. Essa função faz um cache no modelo
para que o mesmo não seja criado a cada execução.

@param cFonte - Nome do Fonte relativo ao modelo a ser excluido

@author Evandro dos Santos Oliveira
@since 22/01/2019
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function getModelCache(cFonte)

    Local oModel := Nil 
    Local nPosModel := 0
    Local lCacheVazio := .F.

    If __aModels == Nil 
        lCacheVazio := .T. 
        __aModels := {}
    EndIf 

    If lCacheVazio

        oModel := FWLoadModel(cFonte)
        aAdd(__aModels,{cFonte,oModel})

        oModel:SetOperation(5)
        oModel:Activate()
    Else

        nPosModel := aScan(__aModels,{|m|m[1] == cFonte})
        If nPosModel > 0

            If __aModels[nPosModel][2]:IsActive()
			    __aModels[nPosModel][2]:DeActivate()
		    EndIf

            __aModels[nPosModel][2]:SetOperation(5)
            __aModels[nPosModel][2]:Activate()

            oModel := __aModels[nPosModel][2]
        Else

            oModel := FWLoadModel(cFonte)
            aAdd(__aModels,{cFonte,oModel})

            oModel:SetOperation(5)
            oModel:Activate()
        EndIf 
    EndIf 

Return oModel 

//---------------------------------------------------------------------
/*/{Protheus.doc} ShowLogExc

Log de Finalização

@param aItensExc - Array com os Itens para o Log
@param lLogGrv - Informa se o log está gravando

@Author		Evandro dos Santos Oliveira
@Since		22/01/2019
@Version	1.0
/*/
//---------------------------------------------------------------------
Static Function ShowLogExc(aItensExc,lLogGrv)

    Local oModal
    Local oList 
    Local oContainer
    Local cTitulo := "Processo Finalizado"
    Local cHeader := ""
    Local cTextoFin := ""
    Local nX := 0
    Local aButtons := {}

    Default lLogGrv := .F.

    If Empty(aItensExc)

        cTextoFin := "Processo Finalizado." + CRLF 
        cTextoFin += "Não há eventos a excluir considerando os parâmetros selecionados. "
    
         MsgInfo(cTextoFin,"SEM MOVIMENTO")
    Else

        If TAFAlsInDic("V3H")
            TafExcGrv(aItensExc)
        EndIf

        aAdd(aButtons,{'',"Salvar Log",{||saveLog(aItensExc,@lLogGrv)},"Salvar Log",0,.F.,.F.})

        cHeader := CRLF + "Relação de Itens excluídos neste processamento."

        oModal  := FWDialogModal():New()       
        oModal:SetEscClose(.T.)
        oModal:SetTitle(cTitulo)
        oModal:SetSubTitle(cHeader)
        
        //Seta a largura e altura da janela em pixel
        oModal:SetSize(200, 350)
    
        oModal:CreateDialog()
        oModal:AddCloseButton(Nil,"Fechar")
        oModal:AddButtons(aButtons)

        oContainer := TPanel():New( ,,, oModal:getPanelMain() )
        //oContainer:SetCss("TPanel{background-color : red;}")
        oContainer:Align := CONTROL_ALIGN_ALLCLIENT

        
        @ 000,000 LISTBOX oList FIELDS ;
            HEADER 'TABELA','ID','VERSÃO','DESCRIÇÃO','RECNO'; 
            COLSIZES 30,70,30,80,10 ;
            SIZE 000,000 OF oContainer PIXEL

        oList:SetArray( aItensExc )
        oList:bLine := {|| { 	aItensExc[oList:nAt][01] ,;
                                aItensExc[oList:nAt][02] ,;
                                aItensExc[oList:nAt][03] ,;
                                aItensExc[oList:nAt][04] ,;
                                aItensExc[oList:nAt][05] }}

        oList:Align    	:= CONTROL_ALIGN_ALLCLIENT

        oModal:Activate()
    EndIF 

Return

//---------------------------------------------------------------------
/*/{Protheus.doc} saveLog

Salva Arquivo de Log.

@Param aItensExc - Array com os Itens para o Log

@Author		Evandro dos Santos Oliveira
@Since		22/01/2019
@Version	1.0
/*/
//---------------------------------------------------------------------
Static Function saveLog(aItensExc,lLogGrv)

    Local nX         := 0
    Local nHandle    := 0
    Local cNameFile  := 'TSTLOG' //TAFEXCESOCIAL_' + DToS(dDataBase) + STRTRAN(TIME(),":","") 
    Local cPathFile  := ""
    Local cLine      := ""
    Local nBytes     := 0
    Local nTamTab    := 006
    Local nTamId     := 040
    Local nTamVersao := 020
    Local nTamDescr  := 070
    Local nTamRecno  := 005
    Local nTamLinha  := nTamTab+nTamId+nTamVersao+nTamDescr+nTamRecno+9
    Local nCont      := 0
    Local lClosed    := .F.

    RpcSetType( 3 )
    RpcSetEnv(FWGrpCompany(),,,,"TAF","TAFEXCESOCIAL",,,,.T.,)

	cDir := cGetFile( "Diretorio|*.*", OemToAnsi( "Selecione um diretorio para gravação do arquivo." ), 0,, .T., GETF_LOCALHARD + GETF_RETDIRECTORY, .T. )

	cPathFile := cDir + cNameFile

    nHandle := FCREATE(cPathFile + ".txt", FC_NORMAL)

    cLine += "Registros Excluidos através da rotina TAFEXCESOCIAL" + CRLF 
    cLine += "Data: " + DTOC(dDataBase) + CRLF 
    cLine += "Hora: " + Time() + CRLF 

    cLine += CRLF
    cLine += Replicate("-",nTamLinha)
    cLine += CRLF

    cLine += formatStr('Tabela'     ,nTamTab     ,0,4) 
    cLine += formatStr('Id'         ,nTamId      ,0,0)
    cLine += formatStr('Versão'     ,nTamVersao  ,0,0)
    cLine += formatStr('Descrição'  ,nTamDescr   ,0,0)
    cLine += formatStr('Recno'      ,nTamRecno   ,0,5) 
    cLine += CRLF 

    cLine += Replicate("-",nTamLinha)
    cLine += CRLF 

    nBytes := FWrite(nHandle,cLine)

    If nHandle > 0

        For nX := 1 To Len(aItensExc)

            cLine := formatStr(aItensExc[nX][1],nTamTab     ,1,4)
            cLine += formatStr(aItensExc[nX][2],nTamId      ,0,0)
            cLine += formatStr(aItensExc[nX][3],nTamVersao  ,0,0)
            cLine += formatStr(aItensExc[nX][4],nTamDescr   ,0,0)
            cLine += formatStr(aItensExc[nX][5],nTamRecno   ,1,5) 
            cLine += CRLF

            nBytes := FWrite(nHandle,cLine)

            If nBytes < 1 
                nX := Len(aItensExc)+1
            Else
                nCont++
            EndIf 
        Next nX 

    EndIf 

    If nBytes > 0

        cLine := CRLF
        cLine += "Quantidade de registros Excluidos: " + cValToChar(nCont)
        nBytes := FWrite(nHandle,cLine)
    EndIf 

    lClosed := FClose(nHandle)

    If nBytes < 1 .And. lClosed

        MsgStop("Erro na Escrita da mensagem.")
    Else

        MsgInfo("Processo Finalizado. Arquivo Gerado: " + cPathFile + ".txt","GRAVAÇÃO LOG")
        lLogGrv := .T. 
        If lClosed
            ShellExecute("OPEN",cPathFile + ".txt","","",1)
        EndIf
    EndIf 

    If !lClosed
        MsgStop("Erro ao Fechar Arquivo de Log:" + Str(FError(0)),"GRAVAÇÃO LOG")
    EndIf 

Return Nil 

//-------------------------------------------------------------------
/*/{Protheus.doc} WizSay
Objeto TSay com propriedades HTML

@param cTexto       - Texto a ser exibido
@param oOwner       - Objeto que será exibido o texto
@param nRow         - Indica a coordenada vertical em pixels ou caracteres
@param nCol         - Indica a coordenada horizontal em pixels ou caracteres
@param nFontSize    - Tamanho da fonte
@param cFontColor   - Cor da fonte (hexadecimal)
@param lNegrito     - Aplica o estilo negrito no texto
@param lItalico     - Habilita o estilo italico no texto
@param nQtdBr       - Quantidade de quebras de linha
@param nWidth       - Indica a largura em pixels do objeto
@param nHeight      - Indica a altura em pixels do objeto
@param oObj         - Objeto criado (referência)

@author Evandro dos Santos Oliveira
@since 22/01/2019
@version 1.0
/*/
//-------------------------------------------------------------------
Function WizSay(cTexto,oOwner,nRow,nCol,nFontSize,cFontColor,cFontFace,lNegrito,lItalico,nQtdBr,nWidth,nHeight,oObj)

    Local cTextoSay := ""
    Local nX := 0

    Default nRow        := 0
    Default nCol        := 0
    Default nWidth      := 0
    Default nHeight     := 0
    Default oObj        := Nil 
    Default nFontSize   := 2
    Default cFontColor  := "#000000"
    Default lNegrito    := .F. 
    Default lItalico    := .F. 
    Default nQtdBr      := 1
    Default cFontFace   := ""


// !GetRemoteType() == REMOTE_HTML
    cTextoSay := '<p align="justify">'
    cTextoSay += '<font size="' + cValToChar(nFontSize) + '" ' 
    cTextoSay += IIf (!Empty(cFontFace),'font face="' + cFontFace + '" ','')
    cTextoSay += 'color="' + cFontColor +'">'

    cTexto := IIf(lNegrito,'<b>' + cTexto + '</b>',cTexto)
    cTexto := IIf(lItalico,'<u>' + cTexto + '</u>',cTexto)

    cTextoSay += cTexto + '</font>'

    cTextoSay += '</p>'

    For nX := 1 To nQtdBr
        cTextoSay += '<br/>'
    Next nX 

    oObj := TSay():New(nRow,nCol,{||cTextoSay},oOwner,,/* oTFont1*/,,,,.T.,,,nWidth,nHeight,,,,,,.T.)

Return Nil 

//------------------------------------------------------------------------------------------
/* {Protheus.doc} formatStr
Realiza a formatação dos campos de acordo com o alinhamento e tamanho especificados.

@author    Evandro dos Santos Oliveira 
@version   1.0
@since     01/08/2018

@param cString 	- Texto a ser formatado
@param nTamanho - Tamanho da coluna que será inserido o texto
@param nAlign 	- nAling - Alinhamento do texto (0-esquerda,1-cento,2-direita)
@param nSpace   - Espaçamento Texto

@return cData - Data no formato dd/mm/aa

*/
//------------------------------------------------------------------------------------------
 Static Function formatStr(cString,nTamanho,nAlign,nSpace)

	Default nAlign := 0
    Default nSpace := 0

	Do Case 
		Case nAlign == 0 // Esquerda
			cString := PADR(cString,nTamanho)
		Case nAlign == 1 // Centro
			cString := PADC(cString,nTamanho)
		Case nAlign == 2 // Direita
			cString := PADL(cString,nTamanho)
	End Case 

    If nSpace > 0
        cString += Space(nSpace)
    EndIf 

 Return cString

 
//---------------------------------------------------------------------
/*/{Protheus.doc} ModelDef
@type           Static function
@description    Construção do Model Def V3H
@author         Eduardo Sukeda
@since          06/02/2019
/*/
//----------------------------------------------------------------------

Static Function ModelDef()

Local oModel := MPFormModel():New('TAFEXCESOCIAL') 
Local oStructV3H := FWFormStruct( 1 , "V3H" )

oModel:AddFields( "MODEL_V3H" ,, oStructV3H )   
oModel:GetModel( 'MODEL_V3H' ):SetPrimaryKey({'V3H_FILIAL','V3H_ID'})

Return oModel

//---------------------------------------------------------------------
/*/{Protheus.doc} TafExcGrv
@type           Static function
@description    Gravação na Tabela V3H com o conteúdo do Log
@author         Eduardo Sukeda
@since          06/02/2019
/*/
//----------------------------------------------------------------------

Static Function TafExcGrv(aItensExc)

Local oModel    := FWLoadModel('TAFEXCESOCIAL')
Local cStatus   := ''
Local cTpExcl   := ''

Local nX        := 0

For nX := 1 To Len(aItensExc)

    If aItensExc[nX][8] $ " |0|1"
        cTpExcl := "1"
    ElseIf aItensExc[nX][8] $ "3"
        cTpExcl := "2"
    EndIf

    oModel:SetOperation(MODEL_OPERATION_INSERT)
    oModel:Activate()

    oModel:LoadValue( "MODEL_V3H", "V3H_FILIAL"	    , xFilial(""+ aItensExc[nX][6]+""))
    oModel:LoadValue( "MODEL_V3H", "V3H_ID"	        , TafGeraId(cValToChar(nX)))
    oModel:LoadValue( "MODEL_V3H", "V3H_DATA"	    , Date())
    oModel:LoadValue( "MODEL_V3H", "V3H_HORA"	    , Time())
    oModel:LoadValue( "MODEL_V3H", "V3H_USER"	    , cUserName)
    oModel:LoadValue( "MODEL_V3H", "V3H_NOMEVE"	    , aItensExc[nX][7])
    oModel:LoadValue( "MODEL_V3H", "V3H_TPEXCL"	    , cTpExcl)
    oModel:LoadValue( "MODEL_V3H", "V3H_TABELA"	    , aItensExc[nX][1])
    oModel:LoadValue( "MODEL_V3H", "V3H_IDTAB"	    , aItensExc[nX][2])
    oModel:LoadValue( "MODEL_V3H", "V3H_VERTAB"	    , aItensExc[nX][3])
    oModel:LoadValue( "MODEL_V3H", "V3H_DESCRI"	    , aItensExc[nX][4])
    oModel:LoadValue( "MODEL_V3H", "V3H_RECTAB"	    , aItensExc[nX][5])

    If oModel:VldData()
        oModel:CommitData()
    EndIf

    oModel:DeActivate()

Next nX

oModel:Destroy()

Return Nil
