#Include "PROTHEUS.CH"
#Include "RWMAKE.CH"
#INCLUDE "TOPCONN.CH"
#INCLUDE "FILEIO.CH"   
#INCLUDE "FWMVCDEF.CH"


#DEFINE paramStsNaoProcessados		 aParamES[1]
#DEFINE paramStsValidos		 		 aParamES[2]
#DEFINE paramStsInvalidos			 aParamES[3]
#DEFINE paramStsSemRetorno			 aParamES[4]
#DEFINE paramStsConsistente		 	 aParamES[5]
#DEFINE paramStsInconsistente		 aParamES[6]
#DEFINE paramVisao					 aParamES[7]
#DEFINE paramEtvTabelas				 aParamES[8]
#DEFINE paramEtvIniciais			 aParamES[9]
#DEFINE paramEtvPeriodicos			 aParamES[10]
#DEFINE paramEtvNaoPeriodicos		 aParamES[11]
#DEFINE paramDataInicial		 	 aParamES[12]
#DEFINE paramDataFim				 aParamES[13]
#DEFINE paramFiliais				 aParamES[14]
#DEFINE paramTAFKEY					 aParamES[15]


#DEFINE EVENTOS_INICIAIS 			 aLegEvts[1]
#DEFINE EVENTO_INICIAL_VINCULO		 aLegEvts[2]
#DEFINE EVENTOS_MENSAIS   			 aLegEvts[3]
#DEFINE EVENTOS_EVENTUAIS			 aLegEvts[4]

/*/{Protheus.doc} nomeFunction
    (long_description)
    @type  Function
    @author user
    @since 09/06/2023
    @version version
    @param param_name, param_type, param_descr
    @return return_var, return_type, return_description
    @example
    (examples)
    @see (links_or_references)
    /*/
Function TAFREAVALIATOTALIZADORES()

    Local aFiliais      as array
    Local dDtIni        as date 
    Local dDtFim        as date 
    Local lExecute      as logical
    Local lCheck        as logical
    Local cIDBrowse     as character
    Local oStepWiz      as object 
    Local oNewPag       as object 
    Local oTabFilSel    as object 

    Private aParamES		:= Array(17)
    Private aEventosParm    := {}
    Private aLegEvts		:= {}


    aFiliais    := {}
    dDtIni      := cTod( '  /  /  ' )
    dDtFim      := cTod( '  /  /  ' )
    lExecute    := .F.
    lCheck      := .F.
    cIDBrowse   := "Tabelas"
    oStepWiz    := Nil  
    oNewPag     := Nil
    oTabFilSel  := Nil


    aLegEvts := { {01,"C"};
    ,{02,"I"};
    ,{03,"M"};
    ,{04,"E"};
    }


    aParamES[1]		:=	.T.			//paramStsNaoProcessados
    aParamES[2]		:=	.T.			//paramStsValidos
    aParamES[3]		:=	.T.			//paramStsInvalidos
    aParamES[4]		:=	.T.			//paramStsSemRetorno
    aParamES[5]		:=	.T.			//paramStsConsistente
    aParamES[6]		:=	.T.			//paramStsInconsistente
    aParamES[7]		:=	1			//paramVisao
    aParamES[8]		:=	.T.			//paramEtvTabelas
    aParamES[9]		:=	.T.			//paramEtvIniciais ** Descontinuado **
    aParamES[10]	:=	.T.			//paramEtvPeriodicos
    aParamES[11]	:=	.T.			//paramEtvNaoPeriodicos
    aParamES[12]	:=	dDatabase	//paramDataInicial
    aParamES[13]	:=	dDatabase	//paramDataFim
    aParamES[14]	:=	{}			//paramFiliais
    aParamES[15]	:=	{}			//paramTAFKEY
    aParamES[16]	:=	'TODOS'		//paramERPOwner
    aParamES[17]    :=  .F.

    FRetEvts()


    If FWIsAdmin( __cUserID )
        oStepWiz:= FWWizardControl():New()

            oStepWiz:ActiveUISteps()

            oNewPag := oStepWiz:AddStep( "1" )
            oNewPag:SetStepDescription("Introdução a Rotina")
            oNewPag:SetConstruction( { | Panel | TafBVindas( Panel, @lCheck ) } )
            oNewPag:SetCancelAction({||.T.})
            oNewPag:SetNextAction( {||lCheck})

            oNewPag := oStepWiz:AddStep( "2", { | Panel | TafParFil( Panel,@dDtIni,@dDtFim), loadFils(oStepWiz,@aFiliais) } )
            oNewPag:SetStepDescription( "Parâmetros e Filtros" )
            oNewPag:SetCancelAction({||.T.})
            oNewPag:SetNextAction({|| lExecute:= validEventos(dDtIni,dDtFim) ,.T.})

        oStepWiz:Activate()

        oStepWiz:Destroy()

        If lExecute
            aParamES[14]	:= aFiliais
            TafMonPFil("C91",@oTabFilSel,@aFiliais )
            FwMsgRun(,{|obj|consultaTotalizador(,@oTabFilSel ,dDtIni,dDtFim, cIDBrowse)})

        EndIf

    Else
        cError := " O usuário " + cUserName + " não pertence ao grupo de administradores, entre em contato com o administrador do sistema."
        MsgStop( cError, "Usuário sem acesso" )

    EndIf
    
Return 

/*/{Protheus.doc} loadFils
Valida se a Filial foi preenchida antes de chamar o proximo panel

@param oWizard - Objeto Dialog
@param aFils - Filiais Selecionadas
*/
Static Function loadFils(oWizard as object ,aFils as array)

    aFils := xFunTelaFil(.T.,,.T.,.F.,.F.,,,.T.)
    
    While  Empty(aFils)
        If MsgYesNo("Atenção, ao cancelar a seleção de filiais a Wizard será encerrada, deseja continuar e encerrar o processo?" , "Prosseguir ?") 
            oWizard:oOwner:End()
            Exit
        Else
            aFils := xFunTelaFil(.T.,,.T.,.F.,.F.,,,.T.) 
        EndIf
    EndDo

Return !Empty(aFils)


/*/{Protheus.doc} validEventos
Valida se foi selecionado ao menos 1 tipo de evento e se os campos
de data foram preenchidos.
@param dDtIni    - Data Inicial
@param dDtFim    - Data Final 
@version 1.0
/*/
Static Function validEventos(dDtIni as date ,dDtFim as date)


    If Empty(dDtIni) .Or. Empty(dDtFim)
        MsgInfo("É necessário informar a Data Inicial e Final para a seleção dos eventos.","DATA INVÁLIDA")
        Return .F.
    EndIf 

Return MsgYesNo("Atenção, ao avançar não será possível retornar para redefinir os filtros, deseja continuar ?" , "Prosseguir ?") 


//-------------------------------------------------------------------
/*/{Protheus.doc} TafBVindas
Boas Vindas da rotina

@Param oPanel - Painel onde serão criados os objetos da tela
*/
Static Function TafBVindas( oPanel as object , lCheck as logical )

    Local cDescr    as character 
    Local nLin      as numeric
    Local nCol      as numeric
    Local nWidth    as numeric
    Local nHeight   as numeric

    nWidth  := oPanel:NCLIENTWIDTH * 0.47
    nCol    := 10
    nHeight := 100

    nLin := 10

    cDescr := 'Bem vindo a rotina de reavaliação de Totalizadores !'
    WizSay(cDescr,oPanel,nLin,nCol,6,"#0c9abe",,.T.,.F.,1,nWidth,020)

    nLin +=30
    cDescr := 'O objetivo desta rotina é reavaliar os eventos Totalizadores que não foram gravados ou foram gravados incorretamente no TAF.'
    WizSay(cDescr,oPanel,nLin,nCol,5,"#737373",,.F.,.F.,1,nWidth,nHeight)

    nLin +=30
    cDescr := 'Não serão afetados os eventos que já foram transmitidos e aceitos pelo governo, ou seja, os eventos que possuem o número de recibo preenchido no TAF. '
    WizSay(cDescr,oPanel,nLin,nCol,5,"#737373",,.F.,.F.,1,nWidth,nHeight)

    nLin := oPanel:NCLIENTHEIGHT - (oPanel:NCLIENTHEIGHT * 0.68)
    cDescr := 'ATENÇÃO: Esta é uma funcionalidade temporaria que, em breve, será disponibilizada no Monitor PO-UI'
    WizSay(cDescr,oPanel,nLin,nCol,4,"#ff0000",,.F.,.F.,1,nWidth,nHeight)

    nLin := oPanel:NCLIENTHEIGHT - (oPanel:NCLIENTHEIGHT * 0.58)
    oCheck := TCheckBox():New(nLin,nCol,'Li e compreendi que a execução desta rotina deve ser solicitada pelo time suporte após análise do ambiente.',{||lCheck},oPanel,nWidth,nHeight,,{||lCheck := !lCheck},,,,,,.T.,,,)

Return Nil 


/*/{Protheus.doc} TafParFil
Cria segunda página da Wizard

@Param   oPanel - Painel onde serão criados os objetos da tela
@Param   dDtIni    - Data Inicial
@Param   dDtFim    - Data Final 

@version 1.0
/*/
//-------------------------------------------------------------------
Static Function TafParFil( oPanel as object , dDtIni as date , dDtFim as date)

    Local cDescr    as character
    Local nLin      as numeric
    Local nCol      as numeric
    Local nWidth    as numeric
    Local oFontC    as object 

    nWidth  := oPanel:NCLIENTWIDTH * 0.47
    nCol    := 10
    nLin    := 10
    nHeight := 100
    oFontC  := TFont():New('Arial',,15,,.F.)


    cDescr := 'Defina o periodo que será considerado na execução'
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

Return .T.
