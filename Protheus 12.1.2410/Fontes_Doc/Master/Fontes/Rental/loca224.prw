#INCLUDE "LOCA224.CH"
#INCLUDE "TOTVS.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "TOPCONN.CH"
#INCLUDE "RWMAKE.CH"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "MSMGADD.CH"

/*/{PROTHEUS.DOC} LOCA024.PRW
ITUP BUSINESS - TOTVS RENTAL
GERENCIAMENTO DE BENS
@TYPE FUNCTION
@AUTHOR FRANK ZWARG FUGA
@SINCE 18/03/2024
@HISTORY 18/03/2024, FRANK ZWARG FUGA, TRANSFORMAÇÃO EM MVC, COMPLEMENTAÇÂO DE ROTINA
/*/

FUNCTION LOCA224()
Local lMvLocBac := SuperGetMv("MV_LOCBAC",.F.,.F.) //Integração com Módulo de Locações SIGALOC
Local cQryLeg
Local cRet00    := ""
Local cRet10    := ""
Local cRet20    := ""
Local cRet50    := ""
Local cRet60    := ""
Local cRet70    := ""
Local oBrowse

Private aRotina   := MenuDef()
Private cCadastro := STR0004 // Gerenciamento de Bens
//Private nOpcao    := 0
Private oModelFQ4
Private cSeq := ""
Private cDes00 := ""
Private cDes10 := ""
Private cDes20 := ""
Private cDes50 := ""
Private cDes60 := ""
Private cDes70 := ""
//Private oBrowse
Private nRegOri
Private cBemSel

    If !lMvLocBac
        Help(Nil,	Nil,STR0001+alltrim(upper(Procname())),; //"RENTAL: "
		Nil,STR0002,1,0,Nil,Nil,Nil,Nil,Nil,; //"Inconsistência nos dados."
		{STR0003}) //"Uso obrigatório do parâmetro habilitado MV_LOCBAC."
        Return .F.
    EndIf

    If FindFunction( "LOCA224B1" )
        If !LOCA224B1("FQE_FILIAL", "FQE") .or. !LOCA224B1("FQF_FILIAL", "FQF")
            Help(Nil,	Nil,STR0001+alltrim(upper(Procname())),; //"RENTAL: "
            Nil,STR0002,1,0,Nil,Nil,Nil,Nil,Nil,; //"Inconsistência nos dados."
            {STR0040}) //"Não foi localizada a tabela de SubStatus."
            Return .F.
        EndIf
    EndIF

	If !AmIIn(94, 05, 19)
		Return .F.
	Endif

    If SELECT("TMPLEG") > 0
		TMPLEG->( DBCLOSEAREA() )
	EndIf

	// Se alterar a legenda aqui, precisa alterar também no LOCA250A
    cQryLeg := "SELECT FQD_STATQY , FQD_STAREN FROM "+ RETSQLNAME("FQD") +" WHERE FQD_STAREN IN ('00','10','20','30','40','50','60','70') AND D_E_L_E_T_ = '' "
    cQryLeg := CHANGEQUERY(cQryLeg)
    MPSysOpenQuery(cQryLeg,"TMPLEG")
//	TCQUERY cQryLeg NEW ALIAS "TMPLEG"

	While TMPLEG->(!EOF())
        If TMPLEG->FQD_STAREN = "00" 		    // --> 00 - DISPONIVEL               - VERDE
            cRet00 += TMPLEG->FQD_STATQY + "*"
            If !empty(TMPLEG->FQD_STATQY)
                cDes00 := Posicione("TQY",1,xfilial("TQY") + TMPLEG->FQD_STATQY,"TQY_DESTAT")
            EndIf
            If empty(cDes00) .and. !empty(TMPLEG->FQD_STAREN)
                cDes00 := Posicione("SX5",1,xFilial("SX5")+"QY"+ TMPLEG->FQD_STAREN,"X5_DESCRI")
            EndIf
            If empty(cDes00)
                cDes00 := STR0009 // Disponivel
            EndIf
        ElseIf TMPLEG->FQD_STAREN = "10" 		// --> 10 - CONTRATO GERADO          - AMARELO
            cRet10 += TMPLEG->FQD_STATQY + "*"
            If !empty(TMPLEG->FQD_STATQY)
                cDes10 := Posicione("TQY",1,xfilial("TQY") + TMPLEG->FQD_STATQY,"TQY_DESTAT")
            EndIf
            If empty(cDes10) .and. !empty(TMPLEG->FQD_STAREN)
                cDes10 := Posicione("SX5",1,xFilial("SX5")+"QY"+ TMPLEG->FQD_STAREN,"X5_DESCRI")
            EndIf
            If empty(cDes10)
                cDes10 := STR0010 // "Contrato gerado"
            EndIf
        ElseIf TMPLEG->FQD_STAREN = "20" 		// --> 20 - NF DE REMESSA GERADA     - AZUL
            cRet20 += TMPLEG->FQD_STATQY + "*"
            If !empty(TMPLEG->FQD_STATQY)
                cDes20 := Posicione("TQY",1,xfilial("TQY") + TMPLEG->FQD_STATQY,"TQY_DESTAT")
            EndIf
            If empty(cDes20) .and. !empty(TMPLEG->FQD_STAREN)
                cDes20 := Posicione("SX5",1,xFilial("SX5")+"QY"+ TMPLEG->FQD_STAREN,"X5_DESCRI")
            EndIf
            If empty(cDes20)
                cDes20 := STR0011 // "Remessa gerada"
            EndIf
        ElseIf TMPLEG->FQD_STAREN = "50" 		// --> 50 - RETORNO DE LOCACAO       - PRETO
            cRet50 += TMPLEG->FQD_STATQY + "*"
            If !empty(TMPLEG->FQD_STATQY)
                cDes50 := Posicione("TQY",1,xfilial("TQY") + TMPLEG->FQD_STATQY,"TQY_DESTAT")
            EndIf
            If empty(cDes50) .and. !empty(TMPLEG->FQD_STAREN)
                cDes00 := Posicione("SX5",1,xFilial("SX5")+"QY"+ TMPLEG->FQD_STAREN,"X5_DESCRI")
            EndIf
            If empty(cDes50)
                cDes50 := STR0012 // "Retorno locação"
            EndIf
        ElseIf TMPLEG->FQD_STAREN = "60" 		// --> 60 - NF DE RETORNO GERADA     - VERMELHO
            cRet60 += TMPLEG->FQD_STATQY + "*"
            If !empty(TMPLEG->FQD_STATQY)
                cDes60 := Posicione("TQY",1,xfilial("TQY") + TMPLEG->FQD_STATQY,"TQY_DESTAT")
            EndIf
            If empty(cDes60) .and. !empty(TMPLEG->FQD_STAREN)
                cDes60 := Posicione("SX5",1,xFilial("SX5")+"QY"+ TMPLEG->FQD_STAREN,"X5_DESCRI")
            EndIf
            If empty(cDes60)
                cDes60 := STR0013 // "Retorno gerado"
            EndIf
        ElseIf TMPLEG->FQD_STAREN = "70" 		// --> 70 - Em manutenção - Violeta
            cRet70 += TMPLEG->FQD_STATQY + "*"
            If !empty(TMPLEG->FQD_STATQY)
                cDes70 := Posicione("TQY",1,xfilial("TQY") + TMPLEG->FQD_STATQY,"TQY_DESTAT")
            EndIf
            If empty(cDes70) .and. !empty(TMPLEG->FQD_STAREN)
                cDes70 := Posicione("SX5",1,xFilial("SX5")+"QY"+ TMPLEG->FQD_STAREN,"X5_DESCRI")
            EndIf
            If empty(cDes70)
                cDes70 := STR0055 // "Em manutenção"
            EndIf
        EndIf
        TMPLEG->(DBSKIP())
    EndDo
    TMPLEG->( DBCLOSEAREA() )

    oBrowse := FwmBrowse():NEW()
    oBrowse:SetAlias("ST9")
    oBrowse:SetDescription(STR0004) //"Gerenciamento de Bens"
    oBrowse:AddLegend("T9_STATUS $ '"+cRet00+"'", 'BR_VERDE',    alltrim(cDes00))  //Disponível
    oBrowse:AddLegend("T9_STATUS $ '"+cRet10+"'", 'BR_AMARELO',  alltrim(cDes10))  //Contrato gerado
    oBrowse:AddLegend("T9_STATUS $ '"+cRet20+"'", 'BR_AZUL',     alltrim(cDes20))  //Remessa gerada
    oBrowse:AddLegend("T9_STATUS $ '"+cRet50+"'", 'BR_PRETO',    alltrim(cDes50))  //Retorno locação
    oBrowse:AddLegend("T9_STATUS $ '"+cRet60+"'", 'BR_VERMELHO', alltrim(cDes60))  //Retorno gerado
    oBrowse:AddLegend("T9_STATUS $ '"+cRet70+"'", 'BR_VIOLETA',  alltrim(cDes70))  //Retorno gerado
    oBrowse:Activate()

Return( NIL )

/*/{PROTHEUS.DOC} MenuDef
ITUP BUSINESS - TOTVS RENTAL
GERENCIAMENTO DE BENS - OPCOES DO MENU
@TYPE FUNCTION
@AUTHOR FRANK ZWARG FUGA
@SINCE 18/03/2024
@HISTORY 18/03/2024, FRANK ZWARG FUGA, TRANSFORMAÇÃO EM MVC
/*/

Static Function MenuDef()
Local aRotina   := {}
Local aRotina1  := {}

	aAdd(aRotina,{ STR0005, "PESQBRW"           ,0,2,0, NIL } ) //"Pesquisar"
    aAdd(aRotina,{ STR0006, "ExeC224a(2)"       ,0,2,0, NIL } ) //"Visualizar"
    aAdd(aRotina,{ STR0016, "ExeC224a(4)"       ,0,4,0, NIL } ) //"Sub-Status"
    aAdd(aRotina,{ STR0017, "VIEWDEF.LOCA224"   ,0,4,0, NIL } ) //"Ocorrecias Lista"
	aAdd(aRotina,{ STR0007, "LOCA224L"          ,0,6,0, NIL } ) //"Legenda"
	aAdd(aRotina,{ STR0008, "LOCR009"           ,0,6,0, NIL } ) //"Quadro Resumo"

    If FindFunction("LOCA250") .and. FindFunction("LOCA250A") .and. FindFunction("LOCA250B")
        aadd(aRotina1, {STR0054, "LOCA250"      ,0,6} ) //"Libera Equipamento"
        aadd(aRotina1, {STR0052, "LOCA250A"     ,0,2} ) //"Devolução em Lote"
        aadd(aRotina1, {STR0053, "LOCA250B"     ,0,6} ) //"Estorna"
        aadd(aRotina,{ STR0051, aRotina1        ,0,6} ) //"Dev.Equipamento"
    EndIf

    If ExistBlock("LC224ROT")
		aRotina := EXECBLOCK( "LC224ROT" , .T. , .T. , {aRotina} )
	EndIf

Return aRotina

/*/{PROTHEUS.DOC} LOCA224
ITUP BUSINESS - TOTVS RENTAL
GERENCIAMENTO DE BENS - LEGENDA
@TYPE FUNCTION
@AUTHOR FRANK ZWARG FUGA
@SINCE 18/03/2024
@HISTORY 18/03/2024, FRANK ZWARG FUGA, TRANSFORMAÇÃO EM MVC
/*/

Function LOCA224L()
Local aLegenda := {}

    aadd(aLegenda,{"BR_VERDE",    cDes00}) //Disponível
    aadd(aLegenda,{"BR_AMARELO",  cDes10}) //Contrato gerado
    aadd(aLegenda,{"BR_AZUL",     cDes20}) //Remessa gerada
    aadd(aLegenda,{"BR_PRETO",    cDes50}) //Retorno locação
    aadd(aLegenda,{"BR_VERMELHO", cDes60}) //Retorno gerado
    aadd(aLegenda,{"BR_VIOLETA",  cDes70}) //Em manutenção

    BRWLEGENDA(STR0004,STR0004,aLegenda) // Gerenciamento de bens###Legenda

return aLegenda

/*/{PROTHEUS.DOC} ModelDef
ITUP BUSINESS - TOTVS RENTAL
GERENCIAMENTO DE BENS - DEFINICAO DO MODELO DE DADOS
@TYPE FUNCTION
@AUTHOR FRANK ZWARG FUGA
@SINCE 18/03/2024
@HISTORY 18/03/2024,FRANK FUGA, Conversão para MVC
/*/

Static Function ModelDef()
Local oModel    := Nil
Local oStPai    := FWFormStruct(1, "ST9")
Local oStFilho  := FWFormStruct(1, "FQ4")
Local oStFilh2  := FWFormStruct(1, "FQF")
Local bVldPos   := {|| LOCA224E()}
Local bFLSLinPRE := {|oModelGrid, nLine, cAction, cField| FLSLINPRE(oModelGrid,nLine,cAction,cField)}
//Local bFLSLinPOS := {|oModelGrid, nLine|FLSLINPOS(oModelGrid,nLine)}
	

    //Criando o modelo e os relacionamentos
    oModel := MPFormModel():New("LOCA224",,bVldPos)

    oModel:AddFields("ST9MASTER",,oStPai)
    oModel:AddGrid("FQ4DETAIL","ST9MASTER",oStFilho,bFLSLinPRE,,,,)
    oModel:AddGrid("FQFDETAIL","FQ4DETAIL",oStFilh2,bFLSLinPRE,,,,)

    //oModel:SetRelation('FQ4DETAIL', { { 'FQ4_FILIAL', "xFilial('FQ4')" }, { 'FQ4_CODBEM', 'T9_CODBEM'  }, { 'FQ4_SEQ', 'T9_SEQFQ4'  } }, FQ4->(IndexKey(1)) )
    oModel:SetRelation('FQ4DETAIL', { { 'FQ4_FILIAL', "xFilial('FQ4')" }, { 'FQ4_CODBEM', 'T9_CODBEM'  }, { 'FQ4_SEQ', 'LOCA224R()'  } }, FQ4->(IndexKey(1)) )
    oModel:SetRelation('FQFDETAIL', { { 'FQF_FILIAL', "xFilial('FQF')" }, { 'FQF_SEQ', 'FQ4_SEQ' } }, FQF->(IndexKey(1)) )
    oModel:SetPrimaryKey({})

    //Setando as descrições
    oModel:SetDescription(STR0004) // "Gerenciamento de Bens"
    oModel:GetModel("ST9MASTER"):SetDescription(STR0015) // "Detalhamento do bem"
    oModel:GetModel("FQ4DETAIL"):SetDescription(STR0014) // "Movimentação"
    oModel:GetModel("FQFDETAIL"):SetDescription(STR0016) // "Sub-Status"
    oModel:GetModel('FQFDETAIL'):SetOptional(.T.)

    oStFilh2:SetProperty("FQF_AS",MODEL_FIELD_INIT, FWBuildFeature( STRUCT_FEATURE_INIPAD, 'FWFldGet("FQ4_AS")'))
    oStFilh2:SetProperty("FQF_CODBEM",MODEL_FIELD_INIT, FWBuildFeature( STRUCT_FEATURE_INIPAD, 'FWFldGet("T9_CODBEM")'))
    oStFilh2:SetProperty("FQF_CONTA",MODEL_FIELD_INIT, FWBuildFeature( STRUCT_FEATURE_INIPAD, 'Posicione("ST9",1,xFilial("ST9")+FWFldGet("FQ4_COBEM"), "T9_POSCONT")'))
    oStFilh2:SetProperty("FQF_CONTA",MODEL_FIELD_INIT, FWBuildFeature( STRUCT_FEATURE_INIPAD, 'FWFldGet("T9_POSCONT")'))
    oStFilh2:SetProperty("FQF_PROJET",MODEL_FIELD_INIT, FWBuildFeature( STRUCT_FEATURE_INIPAD, 'FWFldGet("FQ4_PROJET")'))
    oStFilh2:SetProperty("FQF_SEQ",MODEL_FIELD_INIT, FWBuildFeature( STRUCT_FEATURE_INIPAD, 'FWFldGet("FQ4_SEQ")'))
    oStFilh2:SetProperty("FQF_STATUS",MODEL_FIELD_INIT, FWBuildFeature( STRUCT_FEATURE_INIPAD, 'FWFldGet("FQ4_STATUS")'))
    oStFilh2:SetProperty("FQF_DESBEM",MODEL_FIELD_INIT, FWBuildFeature( STRUCT_FEATURE_INIPAD, 'FWFldGet("T9_NOME")'))
    oStFilh2:SetProperty("FQF_DESSTA",MODEL_FIELD_INIT, FWBuildFeature( STRUCT_FEATURE_INIPAD, 'FWFldGet("FQ4_DESTAT")'))
    oStFilh2:AddTrigger( "FQF_CODBEM" , "FQF_CONTA", {|| .T. }, {|oModel| Posicione("ST9",1,xFilial("ST9")+FWFldGet("FQF_CODBEM"), "T9_POSCONT") } )
    oStFilh2:AddTrigger( "FQF_BEMRES" , "FQF_CONRES", {|| .T. }, {|oModel| Posicione("ST9",1,xFilial("ST9")+FWFldGet("FQF_BEMRES"), "T9_POSCONT") } )

Return oModel

/*/{PROTHEUS.DOC} ViewDef
ITUP BUSINESS - TOTVS RENTAL
GERENCIAMENTO DE BENS - DEFINICAO DA INTERFACE
@TYPE FUNCTION
@AUTHOR FRANK ZWARG FUGA
@SINCE 18/03/2024
@HISTORY 18/03/2024, FRANK ZWARG FUGA, TRANSFORMAÇÃO EM MVC
/*/

Static Function ViewDef()
Local oView     := Nil
Local oModel    := FWLoadModel("LOCA224")
Local oStPai    := FWFormStruct(2, "ST9")
Local oStFilho  := FWFormStruct(2, "FQ4")
Local oStFilh2
Local bVldPre   := {|| LOCA224O(1)}


    oModelFQ4 := oModel:GetModel("FQ4DETAIL")

    nRegOri := ST9->(Recno())

    oStFilh2  := FWFormStruct(2, "FQF")

    //Criando a View
    oView := FWFormView():New()
    oView:SetModel(oModel)
    oView:setOperation(MODEL_OPERATION_UPDATE)

    //oStPai:AddField( "T9_SEQFQ4"  ,"ZZ", "Sequencia"   , "Sequencia"           ,{"Sequencia"}           ,"GET","@!",,,,,,,,,,,, )

    //Adicionando os campos do cabeçalho e o grid dos filhos
    oView:AddField("VIEW_ST9",oStPai,"ST9MASTER")
    oView:AddGrid("VIEW_FQ4",oStFilho,"FQ4DETAIL")
    oView:AddGrid("VIEW_FQF",oStFilh2,"FQFDETAIL")
    oModel:SetDescription(STR0004) // "Gerenciamento de Bens"

    oView:CreateHorizontalBox( 'CABEC', 00)			// Separando a tela em duas partes iguais e atribuindo apelidos a cada parte
    oView:CreateHorizontalBox( 'GRID1', 00)
    oView:CreateHorizontalBox( 'GRID2', 100)

    oView:SetOwnerView('VIEW_ST9','CABEC')
    oView:SetOwnerView('VIEW_FQ4','GRID1')
    oView:SetOwnerView('VIEW_FQF','GRID2')

    //oView:EnableTitleView("VIEW_ST9",STR0015) // "Detalhamento do bem"
    //oView:EnableTitleView("VIEW_FQ4",STR0014) // "Movimentação"
    //oView:EnableTitleView("VIEW_FQF",STR0016) // "Sub-Status"
    //oView:SetViewProperty("VIEW_ST9", "ONLYVIEW")

    //oView:SetProperty("FQF_AS",STRUCT_FEATURE_INIPAD,FWBuildFeature(STRUCT_FEATURE_INIPAD, oModelFQ4:GetValue("FQ4_AS") ))

    oView:AddUserButton( STR0022, STR0022 , {|oView| LOCA224D() } ) // "Visualizar o projeto"
    oView:SetViewCanActivate(bVldPre)

Return oView

/*/{PROTHEUS.DOC} LOCA224E
ITUP BUSINESS - TOTVS RENTAL
GERENCIAMENTO DE BENS - POS VALIDACAO DA INTERFACE
@TYPE FUNCTION
@AUTHOR FRANK ZWARG FUGA
@SINCE 18/03/2024
/*/
Function LOCA224E()
Local lRet := .T.
Local nI
//Local nPosOld
Local nPosNew
Local cBem
Local aBindParam := {}
Local cQuery
Local cSeq
Local oModel
Local oFQF
Local cHora
Local dData
Local cSubStat
Local cBemRes
Local cStatus
Local dMoviment
Local nPos
Local lEntrada := .F.
//Local nPosOld2
Local nPosNew2
Local aAreaSt9 := ST9->(GetArea())
Local aArea := GetArea()
Local nReg := ST9->(Recno())
Local cSeqAux
Local lErroEntra := .F.
Local lErroSai := .F.
Local aValida := {}
Local aFQF := {}
Local cBemVal := ""
Local dVal := ctod("")
Local cHoraVal := ""
Local cStatVal := ""
Local cSubsVal := ""
Local cBemAux := ""
Local dAux := ctod("")
Local cHoraAux := ""
Local cStatAux := ""
Local cSubsAux := ""
Local xAux1
Local xAux2
Local xAux3
Local xAux4
Local xAux5
Local lTem
Local nX
Local cSeqFQ4 := ""

	oModel := FWModelActive()
	oFQF   := oModel:GetModel("FQFDETAIL")

    // O bem reserva é obrigatório se usar um sub-status que substituir for = Sim.
    cSubStat := oFQF:GetValue("FQF_SUBST")
    cBemRes := oFQF:GetValue("FQF_BEMRES")
    cStatus := oFQF:GetValue("FQF_STATUS")
    nPos := oFQF:GetValue("FQF_CONRES")
    dMoviment := oFQF:GetValue("FQF_DTINI")
    cHora := oFQF:GetValue("FQF_HORA")
    cSeqAux := oFQF:GetValue("FQF_SEQ")

    FQE->(dbSetOrder(2))
    FQE->(dbSeek(xFilial("FQE")+cStatus+cSubStat))
    If FQE->FQE_TIPO == "1"
        lEntrada := .T.
    EndIf
    If FQE->FQE_SUBST == "S" .and. empty(cBemRes)
        Help( ,, "LOCA224-LOCA224E",, STR0002, 1, 0,,,,,,{STR0026}) //"Inconsistência nos dados."###"O bem reserva é obrigatório."
        Return .F.
    EndIf
    If FQE->FQE_SUBST == "S" .and. (empty(nPos) .or. empty(dMoviment))
        Help( ,, "LOCA224-LOCA224E",, STR0002, 1, 0,,,,,,{STR0028}) //"Inconsistência nos dados."###"O contador do bem reserva e a data da movimentação são obrigatórios, pois o sub-status é de substituição."
        Return .F.
    EndIf

    cBemVal := ""
    FOR nI := 1 TO oFQF:Length()
        oFQF:GoLine(nI)
        IF !oFQF:IsDeleted() .and. oFQF:IsInserted()// Linha não deletada
            cSubStat := oFQF:GetValue("FQF_SUBST")
            cBemRes := oFQF:GetValue("FQF_BEMRES")
            cStatus := oFQF:GetValue("FQF_STATUS")
            cBemAux := oFQF:GetValue("FQF_CODBEM")
            dMoviment := oFQF:GetValue("FQF_DTINI")
            cHora := oFQF:GetValue("FQF_HORA")


            If empty(cBemVal)
                cBemVal := cBemAux
            Else
                If cBemVal <> cBemAux
                    Help( ,, "LOCA224-LOCA224E",, STR0002, 1, 0,,,,,,{STR0056}) //"Inconsistência nos dados."###"Não pode haver no mesmo movimento bens diferentes."
                    Return .F.
                EndIf
            EndIF

            FQE->(dbSetOrder(2))
            FQE->(dbSeek(xFilial("FQE")+cStatus+cSubStat))
            If FQE->FQE_SUBST == "S" .and. empty(cBemRes)
                Help( ,, "LOCA224-LOCA224E",, STR0002, 1, 0,,,,,,{STR0026}) //"Inconsistência nos dados."###"O bem reserva é obrigatório."
                Return .F.
            EndIf
            If FQE->FQE_SUBST == "N" .and. !empty(cBemRes)
                Help( ,, "LOCA224-LOCA224E",, STR0002, 1, 0,,,,,,{STR0027}) //"Inconsistência nos dados."###"O bem reserva não pode ser preenchido, pois o sub-status não é de substituição."
                Return .F.
            EndIf

            If !empty(cBemRes) .and. !empty(cStatus) .and. !empty(cSubStat)
                aadd(aValida,{cBemRes,cStatus,cSubStat,dMoviment,cHora})
            EndIf
        EndIf
    NEXT

    // 1. Pegar o movimento mais atual do aValida
    // 1.1 Verificar qual é o bem reserva
    // 1.2 Adicionar no aFQF todos os movimentos deste bem reserva, com excessão do que esteja na mesma data e hora
    // 2. Validar se existe outro movimento deste tipo (entrada, ou saída) imediatamente anterior a ele (com base no aFQF)
    // 2.1 Se o aValida for de entrada, o último movimento teve que ser de saída, obrigatório a existência (com base no aFQF).
    // 2.2 Se o aValida for de saída, o último movimento teve que ser de entrada, ou nenhuma ocorrência (com base no aFQF)

    // 1. e 1.1 Pegar o movimento mais atual do aValida
    cBemVal := ""
    dVal := ctod("")
    cHoraVal := ""
    cStatVal := ""
    cSubsVal := ""
    For nI := 1 to len(aValida)
        If aValida[nI,4] > dVal .or. (aValida[nI,4] == dVal .and. aValida[nI,5] > cHoraVal)
            cBemVal := aValida[nI,1]
            cStatVal := aValida[nI,2]
            cSubsVal := aValida[nI,3]
            dVal := aValida[nI,4]
            cHoraVal := aValida[nI,5]
        EndIF
    Next

    // 1.2 - Criar o aFQF
    If !empty(cBemVal)
        aFQF := {}
        FQF->(dbSetOrder(3))
        FQF->(dbSeek(xFilial("FQF")+cBemVal))
        While !FQF->(Eof()) .and. FQF->(FQF_FILIAL+FQF_BEMRES) == xFilial("FQF")+cBemVal
            //If FQF->FQF_DTINI <> dVal .and. FQF->FQF_HORA <> cHoraVal
            aadd(aFQF,{FQF->FQF_BEMRES,FQF->FQF_STATUS,FQF->FQF_SUBST,FQF->FQF_DTINI,FQF->FQF_HORA})
            //EndIF
            FQF->(dbSkip())
        EndDo

        // Ler os novos registros da Grid e adicionar no aFQF
        FOR nI := 1 TO oFQF:Length()
            oFQF:GoLine(nI)
            IF !oFQF:IsDeleted() .and. oFQF:IsInserted() // Linha não deletada
                xAux1 := oFQF:GetValue("FQF_BEMRES")
                xAux2 := oFQF:GetValue("FQF_STATUS")
                xAux3 := oFQF:GetValue("FQF_SUBST")
                xAux4 := oFQF:GetValue("FQF_DTINI")
                xAux5 := oFQF:GetValue("FQF_HORA")

                lTem := .F.
                For nX := 1 to len(aFQF)
                    If aFQF[nX,1] == xAux1 .and. aFQF[nX,2] == xAux2 .and. aFQF[nX,3] == xAux3 .and. aFQF[nX,4] == xAux4 .and. aFQF[nX,5] == xAux5
                        lTem := .T.
                        Exit
                    EndIF
                Next

                If !lTem
                    If xAux1 == cBemVal
                        aadd(aFQF,{xAux1,xAux2,xAux3,xAux4,xAux5})
                    EndIF
                EndIF

            EndIF
        Next


        lErroEntra := .F.
        lErroSai := .F.

        // 2. Validar se existe outro movimento deste tipo (entrada, ou saída) imediatamente anterior a ele (com base no aFQF)
        // 2.1 Se o aValida for de entrada, o último movimento teve que ser de saída, obrigatório a existência (com base no aFQF).
        FQE->(dbSetOrder(2))
        FQE->(dbSeek(xFilial("FQE")+cStatVal+cSubsVal))
        If FQE->FQE_TIPO == "1" // Entrada
            cBemAux := ""
            dAux := ctod("")
            cHoraAux := ""
            cStatAux := ""
            cSubsAux := ""
            For nI := 1 to len(aFQF)
                If aFQF[nI,4] < dVal .or. (aFQF[nI,4] == dVal .and. aFQF[nI,5] < cHoraVal)
                    If aFQF[nI,4] > dAux .or. (aFQF[nI,4] == dAux .and. aFQF[nI,5] > cHoraAux)
                        cBemAux := aFQF[nI,1]
                        cStatAux := aFQF[nI,2]
                        cSubsAux := aFQF[nI,3]
                        dAux := aFQF[nI,4]
                        cHoraAux := aFQF[nI,5]
                    EndIF
                EndIF
            Next
/*
            If empty(cBemAux) .or. empty(cStatAux) .or. empty(cSubsAux)
                lErroEntra := .T.
            Else
                // se o movimento anterior for de entrada esta errado
                FQE->(dbSeek(xFilial("FQE")+cStatAux+cSubsAux))
                If !FQE->(Eof()) .and. FQE->FQE_TIPO == "2"
                    lErroEntra := .F.
                Else
                    lErroEntra := .T.
                EndIF
            EndIf
*/
        EndIF

        // 2.2 Se o aValida for de saída, o último movimento teve que ser de entrada, ou nenhuma ocorrência (com base no aFQF)
/*      FQE->(dbSetOrder(2))
        FQE->(dbSeek(xFilial("FQE")+cStatVal+cSubsVal))
        If FQE->FQE_TIPO == "2" // Saída
            cBemAux := ""
            dAux := ctod("")
            cHoraAux := ""
            cStatAux := ""
            cSubsAux := ""
            For nI := 1 to len(aFQF)
                If aFQF[nI,4] < dVal .or. (aFQF[nI,4] == dVal .and. aFQF[nI,5] < cHoraVal)
                    If aFQF[nI,4] > dAux .or. (aFQF[nI,4] == dAux .and. aFQF[nI,5] > cHoraAux)
                        cBemAux := aFQF[nI,1]
                        cStatAux := aFQF[nI,2]
                        cSubsAux := aFQF[nI,3]
                        dAux := aFQF[nI,4]
                        cHoraAux := aFQF[nI,5]
                    EndIF
                EndIF
            Next

            If empty(cBemAux) .or. empty(cStatAux) .or. empty(cSubsAux)
                lErroSai := .F.
            Else
                // se o movimento anterior for de entrada esta errado
                FQE->(dbSeek(xFilial("FQE")+cStatAux+cSubsAux))
                If !FQE->(Eof()) .and. FQE->FQE_TIPO == "1"
                    lErroSai := .F.
                Else
                    lErroSai := .T.
                EndIF
            EndIf
        EndIF
*/    EndIF

    If lErroEntra
        Help( ,, "LOCA224-LOCA224E",, STR0002, 1, 0,,,,,,{STR0061}) //"Inconsistência nos dados."###"Houve um movimento de entrada sem saída anterior"
        Return .F.
    EndIF

    If lErroSai
        Help( ,, "LOCA224-LOCA224E",, STR0002, 1, 0,,,,,,{STR0060}) //"Inconsistência nos dados."###"Houve um movimento de saida sem entrada anterior"
        Return .F.
    EndIF

    BEGIN TRANSACTION
        FOR nI := 1 TO oFQF:Length()
            oFQF:GoLine(nI)
            IF !oFQF:IsDeleted() .and. oFQF:IsInserted()// Linha não deletada

                IF SELECT("TRBFQ4") > 0
                    TRBFQ4->(DBCLOSEAREA())
                ENDIF
                aBindParam := {}
                cSeq := oFQF:GetValue("FQF_SEQ")
                cQuery := " SELECT FQ4.R_E_C_N_O_ AS REG "
                cQuery += " FROM " + RETSQLNAME("FQ4") + " FQ4 (NOLOCK) "
                cQuery += " WHERE FQ4.FQ4_FILIAL = '" + XFILIAL("FQ4") + "'"
                cQuery += " AND FQ4.FQ4_CODBEM = ? "
                cQuery += " AND FQ4.FQ4_SEQ = ? "
//                aadd(aBindParam,ST9->T9_CODBEM)
                aadd(aBindParam,oFQF:GetValue("FQF_CODBEM"))
                aadd(aBindParam,cSeq)
                cQuery += " AND FQ4.D_E_L_E_T_ = '' "
                cQuery := CHANGEQUERY(cQuery)
                MPSysOpenQuery(cQuery,"TRBFQ4",,,aBindParam)
                FQ4->(DBGOTO(TRBFQ4->REG))
                TRBFQ4->(DBCLOSEAREA())

                nPosNew := oFQF:GetValue("FQF_CONTA")
                //nPosOld := oFQF:GetValue("FQF_POSOLD")

                nPosNew2 := oFQF:GetValue("FQF_CONRES")
                //nPosOld2 := oFQF:GetValue("FQF_RESOLD")
                cBemRes  := oFQF:GetValue("FQF_BEMRES")

                cBem := FQ4->FQ4_CODBEM
                cHora := oFQF:GetValue("FQF_HORA")
                dData := oFQF:GetValue("FQF_DTINI")

// Rossana - 22/10

                ST9->(dbSetOrder(1))
                ST9->(DbGoTop())
                ST9->(dbSeek(xFilial("ST9")+cBem))
                If nPosNew > ST9->T9_POSCONT
                    NGTRETCON(cBem,dData,nPosNew,cHora,1,,,"A",xFilial("ST9"))
/*                  RecLock("ST9",.F.)
                    ST9->T9_POSCONT := nPosNew
                    ST9->(MsUnLock())*/
                    
                Else
                    If nPosNew < ST9->T9_POSCONT
                        lRet := .F.
                        Help( ,, "LOCA224-LOCA224E",, "Não foi possível ajustar o contador do bem: " + alltrim(cBem), 1, 0,,,,,,{"O novo contador deve ser igual ou maior que o anterior!"})
                    ENDIF
                EndIf

                ST9->(dbSetOrder(1))
                ST9->(DbGoTop())
                ST9->(dbSeek(xFilial("ST9")+cBemRes))
                If nPosNew2 > ST9->T9_POSCONT
                    NGTRETCON(cBemRes,dData,nPosNew2,cHora,1,,,"A",xFilial("ST9"))
/*                  RecLock("ST9",.F.)
                    ST9->T9_POSCONT := nPosNew2
                    ST9->(MsUnLock()) */
                Else
                    If nPosNew2 < ST9->T9_POSCONT
                        lRet := .F.
                        Help( ,, "LOCA224-LOCA224E",, "Não foi possível ajustar o contador do bem reserva: " + alltrim(cBemRes), 1, 0,,,,,,{"O novo contador deve ser igual ou maior que o anterior!"})
                    EndIf
                EndIf

                If lRet 
                    cStatVal := oFQF:GetValue("FQF_STATUS")
                    cSubsVal := oFQF:GetValue("FQF_SUBST")
                    If FQE->(dbSeek(xFilial("FQE")+cStatVal+cSubsVal))
                        If FQE->FQE_TIPO == "1"
                            ST9->(dbSetOrder(1))
                            ST9->(DbGoTop())
                            If ST9->(dbSeek(xFilial("ST9")+cBemRes))
                                FQD->(dbSetOrder(1))
                                If FQD->(dbSeek(xFilial("FQD")+"00"))    
                                        cSeqFQ4 := GetSxeNum("FQ4","FQ4_SEQ")
                                        CONFIRMSX8()   
                                        RecLock("FQ4",.t.)
                                        FQ4->FQ4_FILIAL := xFilial("FQ4")
                                        FQ4->FQ4_CODBEM := cBemRes
                                        FQ4->FQ4_NOME   := ST9->T9_NOME
                                        FQ4->FQ4_STATUS := FQD->FQD_STATQY
                                    FQ4->FQ4_DESTAT := "Bem Reserva - Entrada"
                                        FQ4->FQ4_DTINI  := oFQF:GetValue("FQF_DTINI")
                                        FQ4->FQ4_LOG    := "Reserva do bem : " + AllTrim(cBem) + " no contrato " + oFQF:GetValue("FQF_PROJET")
                                        FQ4->FQ4_PROJET := oFQF:GetValue("FQF_PROJET")
                                        FQ4->FQ4_STSOLD := ST9->T9_STATUS
                                        FQ4->FQ4_SEQ    := cSeqFQ4
                                        FQ4->(MsUnLock()) 
                                        RecLock("ST9",.F.)
                                        ST9->T9_STATUS := FQD->FQD_STATQY
                                        ST9->(MsUnLock())
                                    EndIf
                            EndIf
                        Else
                            ST9->(dbSetOrder(1))
                            ST9->(DbGoTop())
                            If ST9->(dbSeek(xFilial("ST9")+cBemRes))
                                FQD->(dbSetOrder(1))
                                If FQD->(dbSeek(xFilial("FQD")+"10"))    
                                    cSeqFQ4 := GetSxeNum("FQ4","FQ4_SEQ")
                                    CONFIRMSX8()   
                                    RecLock("FQ4",.t.)
                                    FQ4->FQ4_FILIAL := xFilial("FQ4")
                                    FQ4->FQ4_CODBEM := cBemRes
                                    FQ4->FQ4_NOME   := ST9->T9_NOME
                                    FQ4->FQ4_STATUS := FQD->FQD_STATQY
                                    FQ4->FQ4_DESTAT := "Bem Reserva - Saída"
                                    FQ4->FQ4_DTINI  := oFQF:GetValue("FQF_DTINI")
                                    FQ4->FQ4_LOG    := "Reserva do bem : " + AllTrim(cBem) + " no contrato " + oFQF:GetValue("FQF_PROJET")
                                    FQ4->FQ4_PROJET := oFQF:GetValue("FQF_PROJET")
                                    FQ4->FQ4_STSOLD := ST9->T9_STATUS
                                    FQ4->FQ4_SEQ    := cSeqFQ4
                                    FQ4->(MsUnLock()) 
                                    RecLock("ST9",.F.)
                                    ST9->T9_STATUS := FQD->FQD_STATQY
                                    ST9->(MsUnLock())
                                EndIf
                            EndIf
                        EndIf
                    EndIf
                EndIf

                ST9->(dbgoto(nReg))
            Else
                IF oFQF:IsDeleted() 
                    cStatVal := oFQF:GetValue("FQF_STATUS")
                    cSubsVal := oFQF:GetValue("FQF_SUBST")
                    If FQE->(dbSeek(xFilial("FQE")+cStatVal+cSubsVal))
                        If FQE->FQE_TIPO == "1"
//------------------------------------------------------------------------------------------------------------------
                            aBindParam := {}
                            cSeq := oFQF:GetValue("FQF_SEQ")
                            cQuery := " SELECT * "
                                    cQuery += " FROM " + RETSQLNAME("FQ4") + " FQ4 (NOLOCK) "
                                    cQuery += " WHERE FQ4.FQ4_FILIAL = '" + XFILIAL("FQ4") + "'"
                                    cQuery += " AND FQ4.FQ4_CODBEM = ? "
                            cQuery += " AND FQ4.FQ4_SEQ > ? "
                                    aadd(aBindParam,cBemRes)
                                    aadd(aBindParam,cSeq)
                                    cQuery += " AND FQ4.D_E_L_E_T_ = '' "
                            cQuery += "ORDER BY FQ4_CODBEM, FQ4_SEQ"
                                    cQuery := CHANGEQUERY(cQuery)
                                    MPSysOpenQuery(cQuery,"TRBFQ4",,,aBindParam)
                            TRBFQ4->(DBGoTop())
                                    If TRBFQ4->(Eof())                                
                                ST9->(dbSetOrder(1))
                                ST9->(DbGoTop())
                                If ST9->(dbSeek(xFilial("ST9")+cBemRes))
                                    FQD->(dbSetOrder(1))
                                    If FQD->(dbSeek(xFilial("FQD")+"10"))    
                                        cSeqFQ4 := GetSxeNum("FQ4","FQ4_SEQ")
                                        CONFIRMSX8()   
                                        RecLock("FQ4",.t.)
                                        FQ4->FQ4_FILIAL := xFilial("FQ4")
                                        FQ4->FQ4_CODBEM := cBemRes
                                        FQ4->FQ4_NOME   := ST9->T9_NOME
                                        FQ4->FQ4_STATUS := FQD->FQD_STATQY
                                        FQ4->FQ4_DESTAT := "Exclusao Bem Reserva - Entrada"
                                        FQ4->FQ4_DTINI  := oFQF:GetValue("FQF_DTINI")
                                        FQ4->FQ4_LOG    := "Reserva do bem : " + AllTrim(cBem) + " no contrato " + oFQF:GetValue("FQF_PROJET")
                                        FQ4->FQ4_PROJET := oFQF:GetValue("FQF_PROJET")
                                        FQ4->FQ4_STSOLD := ST9->T9_STATUS
                                        FQ4->FQ4_SEQ    := cSeqFQ4
                                        FQ4->(MsUnLock()) 
                                        RecLock("ST9",.F.)
                                        ST9->T9_STATUS := FQD->FQD_STATQY
                                        ST9->(MsUnLock())
                                    EndIf
                    EndIf
                            Else
                                lRet := .F.
                                Help( ,, "LOCA224-LOCA224E",, "Não foi possível excluir o registro!", 1, 0,,,,,, ;
                                          {"O bem reserva já está em uso no bem " + AllTrim(cBem) + ;
                                          " Status " + cStatVal + " no contrato " + oFQF:GetValue("FQF_PROJET")})
                EndIf
                            TRBFQ4->(DBCLOSEAREA())

//------------------------------------------------------------------------------------------------------------------

            Else
                ST9->(dbSetOrder(1))
                ST9->(DbGoTop())
                If ST9->(dbSeek(xFilial("ST9")+cBemRes))
                    FQD->(dbSetOrder(1))
                    If FQD->(dbSeek(xFilial("FQD")+"00"))    
                            cSeqFQ4 := GetSxeNum("FQ4","FQ4_SEQ")
                            CONFIRMSX8()   
                            RecLock("FQ4",.t.)
                            FQ4->FQ4_FILIAL := xFilial("FQ4")
                            FQ4->FQ4_CODBEM := cBemRes
                            FQ4->FQ4_NOME   := ST9->T9_NOME
                            FQ4->FQ4_STATUS := FQD->FQD_STATQY
                                    FQ4->FQ4_DESTAT := "Exclusao Bem Reserva - Saída"
                            FQ4->FQ4_DTINI  := oFQF:GetValue("FQF_DTINI")
                            FQ4->FQ4_LOG    := "Reserva do bem : " + AllTrim(cBem) + " no contrato " + oFQF:GetValue("FQF_PROJET")
                            FQ4->FQ4_PROJET := oFQF:GetValue("FQF_PROJET")
                            FQ4->FQ4_STSOLD := ST9->T9_STATUS
                            FQ4->FQ4_SEQ    := cSeqFQ4
                            FQ4->(MsUnLock()) 
                            RecLock("ST9",.F.)
                            ST9->T9_STATUS := FQD->FQD_STATQY
                            ST9->(MsUnLock())
                        EndIf
                    ENDIF
                        EndIf
                    EndIf
                EndIf

                ST9->(dbgoto(nReg))

            ENDIF
        NEXT nI
        If !lRet
            DISARMTRANSACTION()
        EndIF
    END TRANSACTION
    ST9->(RestArea(aAreaSt9))
    ST9->(dbGoto(nReg))
    RestArea(aArea)
Return lRet

/*/{PROTHEUS.DOC} LOCA224F
ITUP BUSINESS - TOTVS RENTAL
VALIDACAO DO CAMPO FQF_SUBST
@TYPE FUNCTION
@AUTHOR FRANK ZWARG FUGA
@SINCE 26/03/2024
/*/
Function LOCA224F
Local lRet := .T.
Local aArea := GetArea()
Local oModel := FWModelActive()
Local oModelFQF := oModel:GetModel("FQFDETAIL")

    If empty(oModelFQF:GetValue("FQF_STATUS"))
        FQE->(dbSetOrder(1))
        if !FQE->(dbSeek(xFilial("FQE")+oModelFQF:GetValue("FQF_SUBST")))
            Help( ,, "LOCA224-LOCA224F",, STR0020, 1, 0,,,,,,{STR0021}) //"Sub-Status inválido."###"O sub-status não foi localizado, ou não está vinculado com o status do bem."
            lRet := .F.
        EndIf
    Else
        FQE->(dbSetOrder(2))
        if !FQE->(dbSeek(xFilial("FQE")+oModelFQF:GetValue("FQF_STATUS")+oModelFQF:GetValue("FQF_SUBST")))
            Help( ,, "LOCA224-LOCA224F",, STR0020, 1, 0,,,,,,{STR0021}) //"Sub-Status inválido."###"O sub-status não foi localizado, ou não está vinculado com o status do bem."
            lRet := .F.
        EndIf
    EndIF
    RestArea(aArea)
Return lRet


/*/{PROTHEUS.DOC} LOCA224D
ITUP BUSINESS - TOTVS RENTAL
GERENCIAMENTO DE BENS - VISUALIZAR O PROJETO
@TYPE FUNCTION
@AUTHOR FRANK ZWARG FUGA
@SINCE 18/03/2024
/*/
Function LOCA224D()
Local oModel
Local oFQ4
Local cProjeto
Local aArea := GetArea()
Private lImplemento := .F.

    If FindFunction( "LOCA224B1" )
        If LOCA224B1("FQG_FILIAL", "FQG")
			lImplemento := .T.
		EndIf
	EndIf

    oModel := FWModelActive()
	oFQ4   := oModel:GetModel("FQ4DETAIL")
    cProjeto := oFQ4:GetValue("FQ4_PROJET")

    If !empty(cProjeto)
        FP0->(dbSetOrder(1))
        FP0->(dbSeek(xFilial("FP0")+cProjeto))
        LOCA00110(cProjeto)
    Else
        Help( ,, "LOCA224-LOCA224D",, STR0023, 1, 0,,,,,,{STR0024}) //"Projeto não localizado"###"Verifique no movimento do bem se o campo Projeto está preenchido"
    EndIf
    restarea(aArea)

Return


/*/{PROTHEUS.DOC} LOCA224H
ITUP BUSINESS - TOTVS RENTAL
GERENCIAMENTO DE BENS - AJUSTE DOS CAMPOS DE CC
@TYPE FUNCTION
@AUTHOR FRANK ZWARG FUGA
@SINCE 27/03/2024
/*/
Function LOCA224H()
Local aArea := GetArea()
Local aAreaFQF := FQF->(GetArea())
Local cFilFPA := xFilial("FPA")
Local cFilFQF := xFilial("FQF")
Local cFilFQ4 := xFilial("FQ4")

    FPA->(dbSetOrder(3))
    FQF->(dbSetOrder(2))
    // Neste ponto já está posicionado no registro correto
    While !FQ4->(Eof()) .and. FQ4->FQ4_CODBEM == ST9->T9_CODBEM .and. FQ4->FQ4_FILIAL == cFilFQ4
        If !empty(FQ4->FQ4_AS)
            If FPA->(dbSeek(cFilFPA+FQ4->FQ4_AS))
                If !empty(FPA->FPA_CUSTO)
                    If FQF->(dbSeek(cFilFQF+FQ4->FQ4_SEQ))
                        While !FQF->(Eof()) .and. FQF->(FQF_FILIAL+FQF_SEQ) == cFilFQF+FQ4->FQ4_SEQ
                            If empty(FQF->FQF_CC)
                                FQF->(RecLock("FQF"),.F.)
                                FQF->FQF_CC := FPA->FPA_CUSTO
                                FQF->(MsUnlock())
                            EndIf
                            FQF->(dbSkip())
                        EndDo
                    EndIF
                EndIf
            EndIF
        EndIf
        FQ4->(dbSkip())
    EndDo
    FQF->(restarea(aAreaFQF))
    restarea(aArea)

Return .T.

/*/{PROTHEUS.DOC} LOCA224I
ITUP BUSINESS - TOTVS RENTAL
GERENCIAMENTO DE BENS - SXB - ST9REN - Filtro
Cada registro da ST9 passa pelas regras aqui dispostas, então precisamos fazer que seja rápido
Esta mesma rotina usamos na validação do campo bem reserva da FQF, deve funcionar tando no SXB quando no valid.
@TYPE FUNCTION
@AUTHOR FRANK ZWARG FUGA
@SINCE 03/04/2024
/*/
Function LOCA224I(lMens,lValid)
Local lRet
Local aArea := GetArea()
Local oModel := FWModelActive()
Local oModelFQF := oModel:GetModel("FQFDETAIL")
Local oModelFQ4 := oModel:GetModel("FQ4DETAIL")
Local cSub := ""
Local cStatus := ""
Local cAs := ""
Local cProjeto := ""
Local nX
Local nY
Local cTipo
Local cBem
Local cBemRes
Local nRegOri := ST9->(Recno())


Default lMens := .F.
Default lValid := .F. // indica que a chamada veio do SXB

    If lValid // indica que vem da validação do sx3 e não do sxb
        ST9->(dbSetOrder(1))
        If !ST9->(dbSeek(xFilial("ST9")+&(ReadVar())))
            Help( ,, "LOCA224-LOCA224I",, STR0002, 1, 0,,,,,,{STR0042}) //"Inconsistência nos dados."###"Bem não localizado."
            ST9->(dbGoto(nRegOri))
            Return .F.
        EndIF
    EndIF

    If ST9->T9_SITMAN <> 'A'
        If lMens
            Help( ,, "LOCA224-LOCA224I",, STR0002, 1, 0,,,,,,{STR0043}) //"Inconsistência nos dados."###"A situação do bem para manutenção não está como ativa."
        EndIf
        RestArea(aArea)
        Return .F.
    EndIf

    If ST9->T9_SITBEM <> 'A'
        If lMens
            Help( ,, "LOCA224-LOCA224I",, STR0002, 1, 0,,,,,,{STR0044}) //"Inconsistência nos dados."###"A situação do bem não está como ativa."
        EndIF
        RestArea(aArea)
        Return .F.
    EndIf

    // Trava para não trazer o bem posicionado
    If M->T9_CODBEM == ST9->T9_CODBEM
        If lMens
            Help( ,, "LOCA224-LOCA224I",, STR0002, 1, 0,,,,,,{STR0045}) //"Inconsistência nos dados."###"Foi usado o mesmo bem para a substituição."
        EndIf
        RestArea(aArea)
        Return .F.
    EndIF

    cSub := oModelFQF:GetValue("FQF_SUBST")
    cStatus := oModelFQF:GetValue("FQF_STATUS")
    cAs := oModelFQF:GetValue("FQF_AS")

// Rossana
/*    FQE->(DbSetOrder(2))
    If FQE->(dbSeek(xFilial("FQE")+cStatus+cSub))
        If FQE->FQE_TIPO == "1"
            IF SELECT("TRBFQF") > 0
                TRBFQF->(DBCLOSEAREA())
            ENDIF
            aBindParam := {}
            cQuery := " SELECT FQF_BEMRES "
            cQuery += " FROM " + RETSQLNAME("FQF") + " FQF "
            cQuery += " WHERE FQF_FILIAL = '" + XFILIAL("FQF") + "'"
            cQuery += " AND FQF_CODBEM = ? "
            aadd(aBindParam,oModelFQ4:GetValue("FQ4_CODBEM"))
            cQuery += " AND D_E_L_E_T_ = '' "
            cQuery += " ORDER BY FQF.FQF_COD DESC "
            cQuery := CHANGEQUERY(cQuery)
            MPSysOpenQuery(cQuery,"TRBFQF",,,aBindParam)
            If !TRBFQF->(Eof())
                If M->FQF_BEMRES <> TRBFQF->FQF_BEMRES
                    If lMens
                        Help( ,, "LOCA224-LOCA224I",, STR0002, 1, 0,,,,,,{" Bem reserva deve ser o mesmo da ultima saida."}) //"Inconsistência nos dados."###" Bem reserva deve ser o mesmo da ultima saida."
                    EndIf
                    RestArea(aArea)
                    TRBFQF->(DBCLOSEAREA())
                    Return .F.
                EndIf 
            EndIf
            TRBFQF->(DBCLOSEAREA())
        EndIf
    EndIf
*/
    // O bem reserva deve pertencer a mesma caracteristica dos status x sub-status
    lRet := .F.
    FQE->(dbSetOrder(2))
    If FQE->(dbSeek(xFilial("FQE")+cStatus+cSub))
        If FQE->FQE_SUBST = "S"
            STB->(dbSetOrder(1))
            If  STB->(dbSeek(xFilial("STB")+ST9->T9_CODBEM))
                While !STB->(Eof()) .and. STB->TB_CODBEM == ST9->T9_CODBEM
                    If STB->TB_CARACTE == FQE->FQE_CARACT
                        lRet := .T.
                        Exit
                    EndIf
                    STB->(dbSkip())
                EndDo
            endif
        EndIf
    EndIf
    If !lRet
        If lMens
            Help( ,, "LOCA224-LOCA224I",, STR0002, 1, 0,,,,,,{STR0046}) //"Inconsistência nos dados."###"O bem informado não possui a mesma característica."
        EndIF
        RestArea(aArea)
        Return .F.
    EndIF

    // Se o status for zerado, ou se for diferente de 00 disponível, o bem reserva precisa ser do mesmo contrato
    // Comentado de acordo com Lui - 07/11/24
/*  If empty(ST9->T9_STATUS) .or. ST9->T9_STATUS <> LOCA224K()
        FQE->(dbSetOrder(2))
        If FQE->(dbSeek(xFilial("FQE")+cStatus+cSub))
            If FQE->FQE_SUBST = "S" 
                If FQE->FQE_TIPO == "2"
        If empty(cAs)
            If lMens
                Help( ,, "LOCA224-LOCA224I",, STR0002, 1, 0,,,,,,{STR0047}) //"Inconsistência nos dados."###"Não foi informado a AS para localizar os bens correspondentes."
            EndIf
            RestArea(aArea)
            Return .F.
        EndIf
        lRet := .F.
        FPA->(dbSetOrder(3))
        
        If FPA->(dbSeek(xFilial("FPA")+cAs))
            cProjeto := FPA->FPA_PROJET
            FPA->(dbSetOrder(1))
            FPA->(dbSeek(xFilial("FPA")+cProjeto))
            While !FPA->(Eof()) .and. FPA->FPA_FILIAL == xFilial("FPA") .and. FPA->FPA_PROJET == cProjeto
                // Não estamos levando em consideração o status da FPA
                If FPA->FPA_GRUA == ST9->T9_CODBEM
                    lRet := .T.
                    Exit
                EndIF
                FPA->(dbSkip())
            EndDo
        EndIf
        If !lRet
            If lMens
                Help( ,, "LOCA224-LOCA224I",, STR0002, 1, 0,,,,,,{STR0048}) //"Inconsistência nos dados."###"Não foi localizado no projeto bens correspondentes."
            EndIf
            RestArea(aArea)
            Return .F.
    EndIF
            EndIf
        EndIf
    EndIf
    EndIf*/

    // Validacao das saidas x entradas para evitar tudas saidas do mesmo bem, ou duas entradas
/*    If !LOCA224V(lMens)
        RestArea(aArea)
        If lValid
            ST9->(dbGoto(nRegOri))
        EndIf
        Return .F.
    Else
        lRet := .T.
        // Validar linha a linha da grid quanto a duas saidas do mesmo bem, ou duas entradas.
      FOR nX := 1 TO oModelFQF:Length()
            oModelFQF:GoLine(nX)
            IF !oModelFQF:IsDeleted() // Linha não deletada

                cSub    := oModelFQF:GetValue("FQF_SUBST")
                cStatus := oModelFQF:GetValue("FQF_STATUS")
                cBem    := oModelFQF:GetValue("FQF_BEMRES")

                If !empty(cBem)
                    FQE->(dbSetOrder(2))
                    If FQE->(dbSeek(xFilial("FQE")+cStatus+cSub))
                        If FQE->FQE_SUBST = "S"
                            cTipo := FQE->FQE_TIPO

                            FOR nY := 1 TO oModelFQF:Length()
                                oModelFQF:GoLine(nY)
                                IF !oModelFQF:IsDeleted() // Linha não deletada
                                    If nX <> nY
                                        // Verificar se é o mesmo bem
                                        If cBem == oModelFQF:GetValue("FQF_BEMRES")
                                            cSub := oModelFQF:GetValue("FQF_SUBST")
                                            cStatus := oModelFQF:GetValue("FQF_STATUS")
                                            FQE->(dbSetOrder(2))
                                            If FQE->(dbSeek(xFilial("FQE")+cStatus+cSub))
                                                If FQE->FQE_SUBST = "S" .and. !Empty(FQE->FQE_TIPO)

                                                    // Verificar se é do mesmo tipo
                                                    If cTipo == FQE->FQE_TIPO
                                                        lRet := .F.
                                                        Exit
                                                    else // Atualiza ultimo tipo 
                                                        cTipo := FQE->FQE_TIPO
                                                    EndIf
                                                EndIf
                                            EndIf
                                        EndIf
                                    EndIf
                                EndIf
                            Next
                        EndIf
                    EndIf
                EndIf
            EndIF
            If !lRet
                Exit
            EndIf
        Next 
        If !lRet
            If lMens
                Help( ,, "LOCA224-LOCA224V-1",, STR0002, 1, 0,,,,,,{STR0049}) //"Inconsistência nos dados."###"Movimento conflitante entre entrada e saída."
            EndIf
            RestArea(aArea)
            If lValid
                ST9->(dbGoto(nRegOri))
            EndIf
            Return .F.
        Else
            RestArea(aArea)
        EndIf
    EndIF*/

    RestArea(aArea)
    If lValid
        M->FQF_BEMRES := ST9->T9_CODBEM
        ST9->(dbGoto(nRegOri))
    EndIf

Return .T.

/*/{PROTHEUS.DOC} LOCA224J
ITUP BUSINESS - TOTVS RENTAL
GERENCIAMENTO DE BENS - SX3 - FQF_BEMRES - VALID
@TYPE FUNCTION
@AUTHOR FRANK ZWARG FUGA
@SINCE 03/04/2024
/*/
Function LOCA224J
Local lRet := .T.
Local aArea := GetArea()
Local oModel := FWModelActive()
Local oModelFQF := oModel:GetModel("FQFDETAIL")
Local cSub := ""
Local cStatus := ""
Local cBem
Local dMoviment
Local nPos
Local aBindParam := {}
Local cQuery
Local cCod := oModelFQF:GetValue("FQF_COD")
Local lSaida := .F.
Local lEntrada := .F.
Local dTemp
Local cTime
Local cCod2
Local cTipo
Local cTpTemp
Local cAs
Local aAreaFQ9 := FQ9->(GetArea())
Local cHora := ""

    nPos := oModelFQF:GetValue("FQF_CONRES")
    dMoviment := oModelFQF:GetValue("FQF_DTINI")
    cHora := oModelFQF:GetValue("FQF_HORA")

    cSub := oModelFQF:GetValue("FQF_SUBST")
    cStatus := oModelFQF:GetValue("FQF_STATUS")
    cBem := oModelFQF:GetValue("FQF_BEMRES")
    cAS := oModelFQF:GetValue("FQF_AS")

    // O bem reserva é obrigatório se usar um sub-status que substituir for = Sim.
    FQE->(dbSetOrder(2))
    FQE->(dbSeek(xFilial("FQE")+cStatus+cSub))
    If FQE->FQE_SUBST == "S" .and. empty(cBem)
        Help( ,, "LOCA224-LOCA224E",, STR0002, 1, 0,,,,,,{STR0026}) //"Inconsistência nos dados."###"O bem reserva é obrigatório."
        lRet := .F.
    EndIf

    If lRet .and. FQE->FQE_SUBST == "S"
        cTipo := FQE->FQE_TIPO
        ST9->(dbSetOrder(1))
        If ST9->(dbSeek(xFilial("ST9")+cBem))
            lRet := .F.
            If FQE->FQE_SUBST = "S"
                STB->(dbSetOrder(1))
                STB->(dbSeek(xFilial("STB")+ST9->T9_CODBEM))
                While !STB->(Eof()) .and. STB->TB_CODBEM == ST9->T9_CODBEM
                    If STB->TB_CARACTE == FQE->FQE_CARACT
                        lRet := .T.
                        Exit
                    EndIf
                    STB->(dbSkip())
                EndDo
            EndIf
            If ST9->T9_SITMAN <> 'A' .OR. ST9->T9_SITBEM <> 'A' .OR. (ST9->T9_STATUS <> LOCA224K() .AND. ST9->T9_STATUS <> '  ')
                lRet := .F.
            EndIf
            If !lRet
                Help( ,, "LOCA224-LOCA224J",, STR0002, 1, 0,,,,,,{STR0025}) //"Inconsistência nos dados."###"Bem não localizado, ou inválido. Verifique o status do bem e as características."
            EndIF

            If lRet
                // Nao permitir uma saida se aguarda a entrada do bem
                If SELECT("TRBFQF") > 0
                    TRBFQF->( DBCLOSEAREA() )
                EndIf
                cQuery := " SELECT FQF.FQF_DTINI, FQF.FQF_HORA, FQF.FQF_COD "
                cQuery += " FROM " + RETSQLNAME("FQF") + " FQF (NOLOCK) "
                cQuery += " INNER JOIN " + RETSQLNAME("FQE") + " FQE (NOLOCK) "
                cQuery += " ON FQE.FQE_FILIAL = '"+xFilial("FQE")+"' "
                cQuery += " AND FQE.FQE_CODSTA = FQF.FQF_STATUS "
                cQuery += " AND FQE.FQE_CODIGO = FQF.FQF_SUBST "
                cQuery += " AND FQE.D_E_L_E_T_ = '' "
                cQuery += " AND FQE.FQE_TIPO = '2' "
                cQuery += " WHERE FQF.FQF_FILIAL = '" + XFILIAL("FQF") + "'"
                cQuery += " AND FQF.FQF_BEMRES = ? "
                aadd(aBindParam,cBem)
                cQuery += " AND FQF.FQF_COD <> ? "
                aadd(aBindParam,cCod)
                cQuery += " AND FQF.D_E_L_E_T_ = '' "
                cQuery += " AND FQF.FQF_STATUS <> '' "
                cQuery += " AND FQF.FQF_SUBST <> '' "
                cQuery := CHANGEQUERY(cQuery)
                MPSysOpenQuery(cQuery,"TRBFQF",,,aBindParam)
                If !TRBFQF->(Eof())
                    lSaida := .T.
                    dTemp := TRBFQF->FQF_DTINI
                    cTime := TRBFQF->FQF_HORA
                    cCod2 := TRBFQF->FQF_COD
                EndIF
                TRBFQF->(DBCLOSEAREA())

                If lSaida
                    cQuery := " SELECT FQF.FQF_DTINI, FQF.FQF_HORA "
                    cQuery += " FROM " + RETSQLNAME("FQF") + " FQF (NOLOCK) "
                    cQuery += " INNER JOIN " + RETSQLNAME("FQE") + " FQE (NOLOCK) "
                    cQuery += " ON FQE.FQE_FILIAL = '"+xFilial("FQE")+"' "
                    cQuery += " AND FQE.FQE_CODSTA = FQF.FQF_STATUS "
                    cQuery += " AND FQE.FQE_CODIGO = FQF.FQF_SUBST "
                    cQuery += " AND FQE.D_E_L_E_T_ = '' "
                    cQuery += " AND FQE.FQE_TIPO = '1' "
                    cQuery += " WHERE FQF.FQF_FILIAL = '" + XFILIAL("FQF") + "'"
                    cQuery += " AND FQF.FQF_BEMRES = ? "
                    aadd(aBindParam,cBem)
                    cQuery += " AND FQF.FQF_COD <> ? "
                    aadd(aBindParam,cCod)
                    cQuery += " AND FQF.D_E_L_E_T_ = '' "
                    cQuery += " AND FQF.FQF_STATUS <> '' "
                    cQuery += " AND FQF.FQF_SUBST <> '' "
                    cQuery += " AND (FQF.FQF_DTINI > ? OR (FQF.FQF_DTINI = ? AND FQF.FQF_HORA > ? ))
                    cQuery += " AND FQF.FQF_COD >= ?"
                    aadd(aBindParam,dTemp)
                    aadd(aBindParam,cTime)
                    aadd(aBindParam,cCod2)
                    cQuery := CHANGEQUERY(cQuery)
                    MPSysOpenQuery(cQuery,"TRBFQF",,,aBindParam)
                    If !TRBFQF->(Eof())
                        lEntrada := .T.
                    EndIf
                    TRBFQF->(DBCLOSEAREA())

                    If !lEntrada
                        // Não foi localizado na base a entrada, mas pode ser que o registro que esta sendo
                        // digitado seja a requerida entrada.
                        If FQE->FQE_TIPO == '1' // Entrada
                            If dtos(dMoviment) > dTemp .or. (dtos(dMoviment) == dTemp .and. cHora > cTime)
                                lEntrada := .T.
                            EndIf
                        EndIf
                    EndIF

                Else
                    lRet := .T.
                EndIF
                If lSaida .and. !lEntrada
                    Help( ,, "LOCA224-LOCA224J-BEMRES",, STR0002, 1, 0,,,,,,{STR0033+cBem}) //"Inconsistência nos dados."###"Houve uma saída sem o retorno do bem: "
                    lRet := .F.
                EndIF

                If lRet
                    // O ultimo movimento deste mesmo bem, não pode ser do tipo do movimento que esta sendo feito
                    cTpTemp := ""
                    FQF->(dbSetOrder(3))
                    If FQF->(dbSeek(xFilial("FQF")+cBem))
                        While !FQF->(Eof()) .and. FQF->(FQF_FILIAL+FQF_BEMRES) == xFilial("FQF")+cBem
                            FQE->(dbSetOrder(2))
                            If FQE->(dbSeek(xFilial("FQE")+FQF->FQF_STATUS+FQF->FQF_SUBST))
                                If FQE->FQE_SUBST == "S"
                                    cTpTemp := FQE->FQE_TIPO
                                EndIF
                            EndIf
                            FQF->(dbSkip())
                        Enddo
                        If !empty(cTpTemp) .and. cTpTemp == cTipo
                            lRet := .F.
                            Help( ,, "LOCA224-LOCA224J",, STR0002, 1, 0,,,,,,{STR0034}) //"O tipo de movimento (Entrada, ou Saída) é o mesmo que o movimento anterior deste bem."
                        EndIF
                    EndIf
                EndIf

            EndIf
        Else
            Help( ,, "LOCA224-LOCA224J-AS",, STR0002, 1, 0,,,,,,{STR0025}) //"Inconsistência nos dados."###"Bem não localizado, ou inválido. Verifique o status do bem e as características."
            lRet := .F.
        EndIF
    EndIF

    If FQE->FQE_SUBST == "N"
        lRet := .T.
        If !empty(cBem)
            Help( ,, "LOCA224-LOCA224J",, STR0002, 1, 0,,,,,,{STR0027}) //"Inconsistência nos dados."###"O bem reserva não pode ser preenchido, pois o sub-status não é de substituição."
            lRet := .F.
        EndIf
        If !empty(dMoviment) .or. !empty(nPos)
            Help( ,, "LOCA224-LOCA224J",, STR0002, 1, 0,,,,,,{STR0029}) //"Inconsistência nos dados."###"O contador do bem reserva e a data da movimentação não podem ser preenchidas, pois o sub-status não é de substituição."
            lRet := .F.
        EndIf
    EndIf

    If M->T9_CODBEM == ST9->T9_CODBEM
        Help( ,, "LOCA224-LOCA224J",, STR0002, 1, 0,,,,,,{STR0036}) //"Inconsistência nos dados."###"O bem reserva não pode ser o mesmo que o posicionado."
        lRet := .F.
    EndIF

    FQ9->(RestArea(aAreaFQ9))
    RestArea(aArea)
Return lRet


/*/{PROTHEUS.DOC} LOCA224K
ITUP BUSINESS - TOTVS RENTAL
GERENCIAMENTO DE BENS - RETORNA COM O STATUS CORRESPONDENTE AO 00 DA FQD
@TYPE FUNCTION
@AUTHOR FRANK ZWARG FUGA
@SINCE 03/04/2024
/*/
Function LOCA224K
Local aArea := GetArea()
Local cRet := "  "
    FQD->(dbSetOrder(2))
    If FQD->(dbSeek(xFilial("FQD")+"00"))
        cRet := FQD->FQD_STAREN
    EndIf
    RestArea(aArea)
Return cRet


/*/{PROTHEUS.DOC} LOCA224M
ITUP BUSINESS - TOTVS RENTAL
GERENCIAMENTO DE BENS - X3_RELACAO FQF_COD
@TYPE FUNCTION
@AUTHOR FRANK ZWARG FUGA
@SINCE 05/04/2024
/*/
Function LOCA224M
Local cCod
    cCod := GetSx8Num("FQF","FQF_COD")
    ConfirmSx8()
Return cCod


/*/{PROTHEUS.DOC} LOCA224N
ITUP BUSINESS - TOTVS RENTAL
GERENCIAMENTO DE BENS - GATILHO DO FQF_BEMRES
@TYPE FUNCTION
@AUTHOR FRANK ZWARG FUGA
@SINCE 05/04/2024
/*/
Function LOCA224N
Local nRet := 0
Local aArea := GetArea()
Local oModel := FWModelActive()
Local oModelFQF := oModel:GetModel("FQFDETAIL")
Local cBem
Local nReg := ST9->(Recno())
    cBem := oModelFQF:GetValue("FQF_BEMRES")
    ST9->(dbSetOrder(1))
    ST9->(dbSeek(xFilial("ST9")+cBem))
    nRet := ST9->T9_POSCONT
    ST9->(dbGoto(nReg))
    RestArea(aArea)
Return nRet


/*/{PROTHEUS.DOC} LOCA224O
ITUP BUSINESS - TOTVS RENTAL
GERENCIAMENTO DE BENS - GERAR FQ4 SE AINDA NAO EXISTIR
@TYPE FUNCTION
@AUTHOR FRANK ZWARG FUGA
@SINCE 05/04/2024
/*/
Function LOCA224O(nModelo)
Local nReg
Default nModelo := 2
    FQ4->(dbSetOrder(1))
    If !FQ4->(dbSeek(xFilial("FQ4")+ST9->T9_CODBEM))
        LOCXITU21("",ST9->T9_STATUS,"","","")
        FQ4->(RecLock("FQ4",.F.))
        FQ4->FQ4_OBRA   := ""
        FQ4->FQ4_AS     := ""
        FQ4->FQ4_CODCLI := ""
        FQ4->FQ4_NOMCLI := ""
        FQ4->FQ4_CODMUN := ""
        FQ4->FQ4_MUNIC  := ""
        FQ4->FQ4_EST    := ""
        FQ4->FQ4_DTINI  := ctod("")
        FQ4->FQ4_DTFIM  := ctod("")
        FQ4->FQ4_PREDES := ctod("")
        FQ4->FQ4_LOJCLI := ""
        If empty(FQ4->FQ4_PROJET)
            FQ4->FQ4_AS := ""
        EndIf
        FQ4->(MsUnlock())
    EndIF

    // Posicionar no último registro
    If nModelo == 1
        While !FQ4->(Eof()) .and. FQ4->FQ4_CODBEM == ST9->T9_CODBEM .and. FQ4->FQ4_FILIAL == xFilial("FQ4")
            nReg := FQ4->(Recno())
            FQ4->(dbSkip())
        EndDo
        FQ4->(dbGoto(nReg))
    EndIf

Return .T.


/*/{PROTHEUS.DOC} LOCA224P
ITUP BUSINESS - TOTVS RENTAL
GERENCIAMENTO DE BENS - INICIALIZADOR PADRAO DOS CAMPOS VIRTUAIS
@TYPE FUNCTION
@AUTHOR FRANK ZWARG FUGA
@SINCE 05/04/2024
/*/
Function LOCA224P()
Local cRet := ""
Local oModel := FWModelActive()
Local oModelFQ4 := oModel:GetModel("FQ4DETAIL")
Local cStatus := oModelFQ4:GetValue("FQ4_STATUS")

    cRet := POSICIONE("FQD",1,XFILIAL("FQD")+cStatus,"FQD_DESTQY")

Return cRet

/*/{PROTHEUS.DOC} LOCA224R
ITUP BUSINESS - TOTVS RENTAL
GERENCIAMENTO DE BENS - TRATAMENTO PARA TRAZER NO MODELO SIMPLIFICADO SEMPRE A ULTIMA FQ4
@TYPE FUNCTION
@AUTHOR FRANK ZWARG FUGA
@SINCE 09/04/2024
/*/

Function LOCA224R
Local nReg := 0
    While !FQ4->(Eof()) .and. FQ4->FQ4_CODBEM == ST9->T9_CODBEM .and. FQ4->FQ4_FILIAL == xFilial("FQ4")
        nReg := FQ4->(Recno())
        FQ4->(dbSkip())
    EndDo
    If nReg > 0
        FQ4->(dbGoto(nReg))
    Else
        LOCXITU21("",ST9->T9_STATUS,"","","")
        FQ4->(RecLock("FQ4",.F.))
        FQ4->FQ4_OBRA   := ""
        FQ4->FQ4_AS     := ""
        FQ4->FQ4_CODCLI := ""
        FQ4->FQ4_NOMCLI := ""
        FQ4->FQ4_CODMUN := ""
        FQ4->FQ4_MUNIC  := ""
        FQ4->FQ4_EST    := ""
        FQ4->FQ4_DTINI  := ctod("")
        FQ4->FQ4_DTFIM  := ctod("")
        FQ4->FQ4_PREDES := ctod("")
        FQ4->FQ4_LOJCLI := ""
        If empty(FQ4->FQ4_PROJET)
            FQ4->FQ4_AS := ""
        EndIf
        FQ4->(MsUnlock())
    EndIf
Return FQ4->FQ4_SEQ


/*/{PROTHEUS.DOC} LOCA224S
ITUP BUSINESS - TOTVS RENTAL
GERENCIAMENTO DE BENS - TRATAMENTO PARA X3_WHEN CAMPO FQF_AS
@TYPE FUNCTION
@AUTHOR FRANK ZWARG FUGA
@SINCE 09/04/2024
/*/

Function LOCA224S
Local lRet := .T.
Local oModel := FWModelActive()
Local oModelFQF := oModel:GetModel("FQFDETAIL")
Local cAS := oModelFQF:GetValue("FQF_AS")
    If !empty(cAS)
        lRet := .F.
    EndIf
Return lRet

/*/{PROTHEUS.DOC} LOCA224T
ITUP BUSINESS - TOTVS RENTAL
GERENCIAMENTO DE BENS - USO NO SXB FQFAS
@TYPE FUNCTION
@AUTHOR FRANK ZWARG FUGA
@SINCE 09/04/2024
/*/

Function LOCA224T
Local oModel := FWModelActive()
Local oModelFQF := oModel:GetModel("FQFDETAIL")
Local cBem := oModelFQF:GetValue("FQF_CODBEM")
Return cBem


/*/{PROTHEUS.DOC} LOCA224U
ITUP BUSINESS - TOTVS RENTAL
GERENCIAMENTO DE BENS - USO NO SX3 FQF_AS
@TYPE FUNCTION
@AUTHOR FRANK ZWARG FUGA
@SINCE 09/04/2024
/*/

Function LOCA224U
Local lRet := .T.
Local aArea := GetArea()
Local oModel := FWModelActive()
Local oModelFQF := oModel:GetModel("FQFDETAIL")
Local cBem := oModelFQF:GetValue("FQF_CODBEM")

    FQ5->(dbSetOrder(9))
    If FQ5->(dbSeek(xFilial("FQ5")+M->FQF_AS))
        If FQ5->FQ5_GUINDA <> cBem
            Help( ,, "LOCA224-LOCA224U",, STR0002, 1, 0,,,,,,{STR0031+cBem}) //"Inconsistência nos dados."###"A AS informada não pertence ao bem: "
            lRet := .F.
        EndIF
        If lRet .and. FQ5->FQ5_STATUS <> "6"
            Help( ,, "LOCA224-LOCA224U",, STR0002, 1, 0,,,,,,{STR0032}) //"Inconsistência nos dados."###"A AS informada não está em um status válido."
            lRet := .F.
        EndIF
    Else
        Help( ,, "LOCA224-LOCA224U",, STR0002, 1, 0,,,,,,{STR0030}) //"Inconsistência nos dados."###"A AS informada não foi localizada."
        lRet := .F.
    EndIF
    RestArea(aArea)
Return lRet

/*/{PROTHEUS.DOC} LOCA224V
ITUP BUSINESS - TOTVS RENTAL
GERENCIAMENTO DE BENS - USO NO SXB ST9REN
@TYPE FUNCTION
@AUTHOR FRANK ZWARG FUGA
@SINCE 10/04/2024
/*/
/*
Function LOCA224V(lMens,lQuery)
//Local cBemPos := ST9->T9_CODBEM
Local lRet := .T.
Local aArea := GetArea()
Local oModel := FWModelActive()
Local oModelFQF := oModel:GetModel("FQFDETAIL")
Local cCod := oModelFQF:GetValue("FQF_COD")
Local cStatus := oModelFQF:GetValue("FQF_STATUS")
Local cSubSta := oModelFQF:GetValue("FQF_SUBST")
Local cTpTemp
Local cTipo

Private dTemp := ctod("")
Private cTime := ""

Default lMens := .F.
Default lQuery := .F.

    lRet := LOCA2244(cCod) // valida se houve saidas e entradas do bem

    If lRet .and. !empty(cStatus) .and. !empty(cSubSta)
        // O ultimo movimento deste mesmo bem, não pode ser do tipo do movimento que esta sendo feito
        cTpTemp := ""

        FQE->(dbSetOrder(2))
        If FQE->(dbSeek(xFilial("FQE")+cStatus+cSubSta))
            If FQE->FQE_SUBST == "S"
                cTipo := FQE->FQE_TIPO
                FQF->(dbSetOrder(3))
                If FQF->(dbSeek(xFilial("FQF")+ If(lQuery,TST9->T9_CODBEM,ST9->T9_CODBEM) ))
                    While !FQF->(Eof()) .and. FQF->(FQF_FILIAL+FQF_BEMRES) == xFilial("FQF")+If(lQuery,TST9->T9_CODBEM,ST9->T9_CODBEM)
                        FQE->(dbSetOrder(2))
                        If FQE->(dbSeek(xFilial("FQE")+FQF->FQF_STATUS+FQF->FQF_SUBST))
                            If FQE->FQE_SUBST == "S"
                                cTpTemp := FQE->FQE_TIPO
                            EndIF
                        EndIf
                        FQF->(dbSkip())
                    Enddo
                    If !empty(cTpTemp) .and. cTpTemp == cTipo
                        lRet := .F.
                    EndIF
                EndIf
            EndIF
        EndIf
    EndIf

    If !lRet .and. lMens
        Help( ,, "LOCA224-LOCA224V-2",, STR0002, 1, 0,,,,,,{STR0049}) //"Inconsistência nos dados."###"Movimento conflitante entre entrada e saída."
    EndIF

    RestArea(aArea)
Return lRet
*/
/*/{PROTHEUS.DOC} LOCA224X
ITUP BUSINESS - TOTVS RENTAL
GERENCIAMENTO DE BENS - VALIDACAO DO HORARIO
@TYPE FUNCTION
@AUTHOR FRANK ZWARG FUGA
@SINCE 10/04/2024
/*/

Function LOCA224X
Local lRet := .T.
Local cHora := M->FQF_HORA
    If substr(cHora,1,2) > "24"
        lRet := .F.
    EndIf
    If substr(cHora,1,2) == "24" .and. substr(cHora,4,2) > "00"
        lRet := .F.
    EndIf
    If !lRet
        Help( ,, "LOCA224-LOCA224X",, STR0002, 1, 0,,,,,,{STR0035}) //"Inconsistência nos dados."###"Horário inválido."
    EndIF
Return lRet

/*/{PROTHEUS.DOC} LOCA224Z
ITUP BUSINESS - TOTVS RENTAL
GERENCIAMENTO DE BENS - VALIDACAO DA AS
@TYPE FUNCTION
@AUTHOR FRANK ZWARG FUGA
@SINCE 10/04/2024
/*/

Function LOCA224Z
Local lRet := .T.
Local aArea := GetArea()

    FQ5->(dbSetOrder(9))
    If !FQ5->(dbSeek(xFilial("FQ5")+M->FQF_AS))
        lRet := .F.
        Help( ,, "LOCA224-LOCA224Z",, STR0002, 1, 0,,,,,,{STR0037}) //"Inconsistência nos dados."###"AS não localizada."
    EndIf
    If lRet
        If FQ5->FQ5_GUINDA <> LOCA224T() .OR. FQ5->FQ5_STATUS <> '6'
            lRet := .F.
            Help( ,, "LOCA224-LOCA224Z",, STR0002, 1, 0,,,,,,{STR0038}) //"Inconsistência nos dados."###"Verifique o stauts da AS e o bem relacionado."
        EndIF
    EndIF
    RestArea(aArea)

Return lRet

/*/{PROTHEUS.DOC} LOCA2243
ITUP BUSINESS - TOTVS RENTAL
GERENCIAMENTO DE BENS - VALIDACAO DA AS
@TYPE FUNCTION
@AUTHOR FRANK ZWARG FUGA
@SINCE 10/04/2024
/*/

Function LOCA2243
Local lRet := .T.
Local aArea := GetArea()
Local oModel := FWModelActive()
Local oModelFQ4 := oModel:GetModel("FQ4DETAIL")
Local oModelFQF := oModel:GetModel("FQFDETAIL")
Local nI
Local nLinha
Local cTipo
Local cTipoDig := ""

    FQE->(dbSetOrder(2))
    If !FQE->(dbSeek(xFilial("FQE")+oModelFQ4:GetValue("FQ4_STATUS")+M->FQF_SUBST))
        lRet := .F.
        Help( ,, "LOCA224-LOCA224Z",, STR0002, 1, 0,,,,,,{STR0039}) //"Inconsistência nos dados."###"Vínculo Status/Sub-Status não localizado."
    Else
        cTipoDig := FQE->FQE_TIPO
    EndIF

    // Verificar na grid se houve um movimento anterior que conflite com entrada, ou saída independente
    // do bem reserva
    If lRet .and. !empty(cTipoDig)
        nLinha := oModelFQF:GetLine()
        cSubStat := ""
        cTipo := ""
        FQE->(dbSetOrder(2))
        FOR nI := 1 TO oModelFQF:Length()
            oModelFQF:GoLine(nI)
            IF !oModelFQF:IsDeleted() // Linha não deletada
                If nI < nLinha
                    cSubStat := oModelFQF:GetValue("FQF_SUBST")
                    If FQE->(dbSeek(xFilial("FQE")+oModelFQ4:GetValue("FQ4_STATUS")+cSubStat))
                        If !empty(FQE->FQE_TIPO)
                            cTipo := FQE->FQE_TIPO
                        EndIF
                    EndIF
                EndIF
            EndIF
        NEXT
        If !empty(cTipo)
            If cTipo == cTipoDig
                lRet := .F.
                Help( ,, "LOCA224-LOCA224Z",, STR0002, 1, 0,,,,,,{STR0057}) //"Inconsistência nos dados."###"Não pode haver movimentos de entrada e saída repetidos."
            EndIF
        EndIf
    EndIF

    RestArea(aArea)
Return lRet


/*/{PROTHEUS.DOC} LOCA2244
ITUP BUSINESS - TOTVS RENTAL
GERENCIAMENTO DE BENS - VERIFICA SE O BEM TEVE ALGUMA SAIDA
@TYPE FUNCTION
@AUTHOR FRANK ZWARG FUGA
@SINCE 30/04/2024
/*/

Function LOCA2244(cCod)
Local lRet := .T.
Return lRet

/*/{PROTHEUS.DOC} LOCA224B1
ITUP BUSINESS - TOTVS RENTAL
VALIDA SE UM CAMPO EXISTE NO SX3
@TYPE FUNCTION
@AUTHOR FRANK ZWARG FUGA
@SINCE 15/05/2024
/*/

Function LOCA224B1(cCampo, cAlias)
Local a1Struct
Local nP
Local lRet := .F.
    If !empty(cCampo) .and. !empty(cAlias)
        a1Struct := FWSX3Util():GetListFieldsStruct( cAlias, .F.)
        For nP := 1 to len(a1Struct)
            If upper(alltrim(a1Struct[nP][01])) == upper(alltrim(cCampo))
                lRet := .T.
                exit
            EndIf
        Next
    EndIF
Return lRet

/*/{PROTHEUS.DOC} LOCA224B2
ITUP BUSINESS - TOTVS RENTAL
VALID NO CAMPO FPA_GRUA
@TYPE FUNCTION
@AUTHOR FRANK ZWARG FUGA
@SINCE 15/05/2024
/*/

Function LOCA224B2()
Local lImplemento := .F.
Local lRet := .T.
Local cBem := &(ReadVar())
Local cQuery
Local aBindParam
Local lPrim

    If FindFunction( "LOCA224B1" )
        If LOCA224B1("FQE_FILIAL", "FQE") .and. LOCA224B1("FQF_FILIAL", "FQF")
            lImplemento := .T.
        EndIF
    EndIF

    If !lImplemento
        lRet := .T.
    Else
        If !empty(cBem)

            IF SELECT("TRBFQF") > 0
                TRBFQF->(DBCLOSEAREA())
            ENDIF
            aBindParam := {}
            cQuery := " SELECT FQF_SUBST, FQF_STATUS "
            cQuery += " FROM " + RETSQLNAME("FQF") + " FQF "
            cQuery += " WHERE FQF_FILIAL = '" + XFILIAL("FQF") + "'"
            cQuery += " AND FQF_BEMRES = ? "
            aadd(aBindParam,cBem)
            cQuery += " AND D_E_L_E_T_ = '' "
            cQuery += " ORDER BY FQF.FQF_COD DESC "
            cQuery := CHANGEQUERY(cQuery)
            MPSysOpenQuery(cQuery,"TRBFQF",,,aBindParam)
            lPrim := .T.
            lRet := .T.
            // Esta ordenado pela sequencia dos movimentos (decrescente)
            While !TRBFQF->(Eof())
                FQE->(dbSetOrder(2))
                If FQE->(dbSeek(xFilial("FQE")+TRBFQF->FQF_STATUS+TRBFQF->FQF_SUBST))
                    If FQE->FQE_TIPO == "1" .and. lPrim // movimento de entrada
                        lPrim := .F.
                        lRet := .T.
                    EndIf
                    If FQE->FQE_TIPO == "2" .and. lPrim // movimento de saída
                        lPrim := .F.
                        lRet := .F.
                    EndIf
                EndIF
                TRBFQF->(dbSkip())
            EndDo
            TRBFQF->(DBCLOSEAREA())
        EndIF
    EndIf

    If !lRet
        Help(Nil,	Nil,STR0001+alltrim(upper(Procname())),; //"RENTAL: "
                    Nil,STR0002+STR0041,1,0,Nil,Nil,Nil,Nil,Nil,; //"Inconsistência nos dados."###"O último movimento deste bem nas ocorrências do gerenciamento, aguarda um retorno."
                    {""})
    EndIf

Return lRet

/*/{PROTHEUS.DOC} LOCA224B3
ITUP BUSINESS - TOTVS RENTAL
ST9RE2 - SXB - Bem reserva
@TYPE FUNCTION
@AUTHOR FRANK ZWARG FUGA
@SINCE 13/06/2024
/*/

Function LOCA224B3()
Local oOk
Local oNo
Local cTitulo := "Seleção do bem reserva" // "Seleção do bem reserva"
Local oDlg
Local cTemp
Local nTemp
Local cVarGrp
Local lContinua
Local nGrava := 0
Local nX
Local oModel := FWModelActive()
Local oModelFQF := oModel:GetModel("FQFDETAIL")
Local cSub      := "" 

Private oListP5
Private aItens := {}

    oOk := LoadBitmap( GetResources(), "LBOK")
    oNo := LoadBitmap( GetResources(), "LBNO")

    Processa( {|| lContinua := LOCA224B4() }, "Localizando os bens válidos" ) //"Localizando os bens válidos"

    If !lContinua
        cBemSel := ""
        Return .F.
    EndIf

    DEFINE MSDIALOG oDlg TITLE cTitulo From 05,00 To 400,600 of oMainWnd PIXEL

    @ 35,05 LISTBOX oListP5 VAR cVarGrp FIELDS HEADER "";
    SIZE 294,160 ON DBLCLICK ( LOCA224B5() ) OF oDlg PIXEL

    aadd(oListP5:aheaders,"Código do bem") //"Código do bem"
    aadd(oListP5:aheaders,"Nome do bem") //"Nome do bem"
    aadd(oListP5:aheaders,"Família do bem") //"Família do bem"

    oListP5:REFRESH()

    oListP5:SetArray(aItens)
    oListP5:REFRESH()
    //oListP5:bChange := {|| LOCA086D()}
    //oListP5:bHeaderClick = {|| LOCA086E()}

    cTemp := "{||{ If(aItens[oListP5:nAt,1],oOk,oNo),"
    cTemp += "aItens[oListP5:nAt,2],"
    cTemp += "aItens[oListP5:nAt,3],"
    cTemp += "aItens[oListP5:nAt,4]"
    cTemp += "}}"

    nTemp := 4

    oListP5:bLine := &(cTemp)
    oListP5:REFRESH()

    Activate MsDialog oDlg CENTERED On Init EnchoiceBar(oDlg,{|| If(MsgYesNo("Confirma a seleção","Bem reserva"),If(.T.,(nGrava:=1,oDlg:end()),.F.) ,.F.)},{|| oDlg:end()},,) //"Confirma a seleção"###"Bem reserva"

    If nGrava == 1
        For nX := 1 to len(aItens)
            If aItens[nX,1]
                cBemSel := aItens[nX,2]
                Exit
            EndIf
        Next
    Else
        cBemSel := ""
    EndIF

Return .t.

/*/{PROTHEUS.DOC} LOCA224B4
ITUP BUSINESS - TOTVS RENTAL
ST9RE2 - SXB - Bem reserva - Localiza os bens válidos para seleção
@TYPE FUNCTION
@AUTHOR FRANK ZWARG FUGA
@SINCE 13/06/2024
/*/

Function LOCA224B4()
Local cQuery
Local aBindParam := {}
Local aArea := GetArea()
Local oModel := FWModelActive()
Local oModelFQF := oModel:GetModel("FQFDETAIL")
Local cSub := ""
Local cStatus := ""
Local cAs := ""
Local cProjeto := ""
Local lRet := .T.

    ProcRegua(0)

    cQuery := "SELECT ST9.T9_CODBEM, ST9.T9_STATUS, ST9.T9_NOME, ST9.T9_CODFAMI "
    cQuery += "FROM "+RetSqlName("ST9")+" ST9 "
    cQuery += "WHERE ST9.D_E_L_E_T_ = '' AND "
    cQuery += "T9_SITMAN = 'A' AND "
    cQuery += "T9_SITBEM = 'A' AND "
    cQuery += "T9_CODBEM <> ? AND "
    aadd(aBindParam,ST9->T9_CODBEM)
    cQuery += "T9_FILIAL = '"+xFilial("ST9")+"' "
    cQuery += "ORDER BY T9_CODBEM "

    If Select("TST9") > 0
        TST9->(dbCloseArea())
    EndIf
    cQuery := CHANGEQUERY(cQuery)
    MPSysOpenQuery(cQuery,"TST9",,,aBindParam)

    While !TST9->(Eof())
        IncProc()

        cSub    := oModelFQF:GetValue("FQF_SUBST")
        cStatus := oModelFQF:GetValue("FQF_STATUS")
        cAs     := oModelFQF:GetValue("FQF_AS")

        // O bem reserva deve pertencer a mesma caracteristica dos status x sub-status
        lRet := .F.
        FQE->(dbSetOrder(2))
        If FQE->(dbSeek(xFilial("FQE")+cStatus+cSub))
            If FQE->FQE_SUBST = "S"
                STB->(dbSetOrder(1))
                STB->(dbSeek(xFilial("STB")+TST9->T9_CODBEM))
                While !STB->(Eof()) .and. STB->TB_CODBEM == TST9->T9_CODBEM
                    If STB->TB_CARACTE == FQE->FQE_CARACT
                        lRet := .T.
                        Exit
                    EndIf
                    STB->(dbSkip())
                EndDo
            EndIf
        EndIf
        If !lRet
            TST9->(dbSkip())
            Loop
        EndIF

        // Se o status for zerado, ou se for diferente de 00 disponível, o bem reserva precisa ser do mesmo contrato
/* 
        If empty(TST9->T9_STATUS) .or. TST9->T9_STATUS <> LOCA224K()
            If empty(cAs)
                TST9->(dbSkip())
                Loop
            EndIf
            lRet := .F.
            FPA->(dbSetOrder(3))
            If FPA->(dbSeek(xFilial("FPA")+cAs))
                cProjeto := FPA->FPA_PROJET
                FPA->(dbSetOrder(1))
                FPA->(dbSeek(xFilial("FPA")+cProjeto))
                While !FPA->(Eof()) .and. FPA->FPA_FILIAL == xFilial("FPA") .and. FPA->FPA_PROJET == cProjeto
                    // Não estamos levando em consideração o status da FPA
                    If FPA->FPA_GRUA == TST9->T9_CODBEM
                        lRet := .T.
                        Exit
                    EndIF
                    FPA->(dbSkip())
                EndDo
            EndIf
            If !lRet
                TST9->(dbSkip())
                Loop
            EndIf
        EndIF

        // Validacao das saidas x entradas para evitar tudas saidas do mesmo bem, ou duas entradas
        If !LOCA224V(.F.,.T.)
            TST9->(dbSkip())
            Loop
        EndIF
*/
        aadd(aItens,{.F.,TST9->T9_CODBEM,TST9->T9_NOME,TST9->T9_CODFAMI})
        TST9->(dbSkip())

    EndDo
    TST9->(dbCloseArea())
    RestArea(aArea)

    If len(aItens) == 0
        Help(Nil,	Nil,STR0001+alltrim(upper(Procname())),; //"RENTAL: "
		Nil,STR0002,1,0,Nil,Nil,Nil,Nil,Nil,; //"Inconsistência nos dados."
		{STR0050}) //"Não foram localizados bens válidos para a seleção."
        Return .F. //aadd(aItens,{.F.,"","",""})
    EndIf

Return .T.


/*/{PROTHEUS.DOC} LOCA224B5
ITUP BUSINESS - TOTVS RENTAL
Controle na seleção do bem reserva na listbox
@TYPE FUNCTION
@AUTHOR FRANK ZWARG FUGA
@SINCE 13/06/2024
/*/

Function LOCA224B5()
Local nX
    aItens[oListP5:nAt,1] := !aItens[oListP5:nAt,1]
    For nX := 1 to len(aItens)
        If nX <> oListP5:nAt
            aItens[nX,1] := .F.
        EndIf
    Next
    oListP5:Refresh()
Return .T.


// NÃO ESTÁ SENDO CHAMADA EM NENHUM LUGAR NEM SXB
/*
Function LOCA224Y()
//Local cBemPos := ST9->T9_CODBEM
Local lRet := .T.
Local aArea := GetArea()
Local oModel := FWModelActive()
Local oModelFQF := oModel:GetModel("FQFDETAIL")
Local cCod := oModelFQF:GetValue("FQF_COD")
Local cStatus := oModelFQF:GetValue("FQF_STATUS")
Local cSubSta := oModelFQF:GetValue("FQF_SUBST")
Local cTpTemp
Local cTipo

Private dTemp := ctod("")
Private cTime := ""

Default lMens := .F.
Default lQuery := .F.

    If lRet .and. !empty(cStatus) .and. !empty(cSubSta)
    // O ultimo movimento deste mesmo bem, não pode ser do tipo do movimento que esta sendo feito
    cTpTemp := ""

        FQE->(dbSetOrder(2))
        If FQE->(dbSeek(xFilial("FQE")+cStatus+cSubSta))
            If FQE->FQE_SUBST == "S"
                cTipo := FQE->FQE_TIPO
                FQF->(dbSetOrder(3))
                If FQF->(dbSeek(xFilial("FQF")+ If(lQuery,TST9->T9_CODBEM,ST9->T9_CODBEM) ))
                    While !FQF->(Eof()) .and. FQF->(FQF_FILIAL+FQF_BEMRES) == xFilial("FQF")+If(lQuery,TST9->T9_CODBEM,ST9->T9_CODBEM)
                        FQE->(dbSetOrder(2))
                        If FQE->(dbSeek(xFilial("FQE")+FQF->FQF_STATUS+FQF->FQF_SUBST))
                            If FQE->FQE_SUBST == "S"
                                cTpTemp := FQE->FQE_TIPO
                            EndIF
                        EndIf
                        FQF->(dbSkip())
                    Enddo
                    If !empty(cTpTemp) .and. cTpTemp == cTipo
//                        lRet := .F.
                    EndIF
                EndIf
            EndIF
        EndIf
    EndIf

    If !lRet .and. lMens
        Help( ,, "LOCA224-LOCA224V-3",, STR0002, 1, 0,,,,,,{STR0049}) //"Inconsistência nos dados."###"Movimento conflitante entre entrada e saída."
    EndIF

    RestArea(aArea)
Return lRet
*/

Function LOCA224G(cCodBem, lMens)
Local lRet := .F.
Local nReg := 0

DEFAULT lMens := .T.

if FQE->(FIELDPOS("FQE_LOCBLQ")) > 1
    dbSelectArea("FQ4")
    dbSeek(xFilial("FQ4")+cCodBem)
    While !FQ4->(Eof()) .and. FQ4->FQ4_CODBEM == cCodBem .and. FQ4->FQ4_FILIAL == xFilial("FQ4")
        nReg := FQ4->(Recno())
        FQ4->(dbSkip())
    EndDo
    // Verificar se eoncontrou dados no gerenciamento de bens

    If nReg > 0
        FQ4->(dbGoto(nReg))
        // Buscar o ultimo substatus se houver
        dbSelectArea("FQF")
        dbSetOrder(2) // Pela Seguencia
        dbSeek(xFilial("FQF")+FQ4->FQ4_SEQ)
        if !Eof()
            while !Eof() .and. FQF->(FQF_FILIAL+FQF_SEQ) = xFilial("FQF")+FQ4->FQ4_SEQ
                lRet := Posicione("FQE",2, xFilial("FQE")+FQF->FQF_STATUS+FQF->FQF_SUBST, "FQE_LOCBLQ") = '1'
                FQF->(dbSkip())
            enddo

        endif
    EndIf
endif

If !lRet .and. lMens
    Help( ,, "LOCA224-LOCA224G",, STR0063, 1, 0,,,,,,{STR0062}) //"Inconsistência nos dados."###"Movimento conflitante entre entrada e saída." //"Avalie o substatus atual do aquipamento." //"O Equipamento está bloqueado para locação!"
endif

Return lRet

//------------------------------------------------------------------------------------------------------------------

Function LOCA224GT

Local aArea := GetArea()
Local oModel := FWModelActive()
Local oModelFQF := oModel:GetModel("FQFDETAIL")
Local oModelFQ4 := oModel:GetModel("FQ4DETAIL")
Local cSub := ""
Local cStatus := ""
Local cAs := ""
Local cBemRes := ""
Local cQuery

    cSub := oModelFQF:GetValue("FQF_SUBST")
    cStatus := oModelFQF:GetValue("FQF_STATUS")
    cAs := oModelFQF:GetValue("FQF_AS")
 
// Rossana
    FQE->(DbSetOrder(2))
    If FQE->(dbSeek(xFilial("FQE")+cStatus+cSub))
        If FQE->FQE_TIPO == "1"
            aBindParam := {}
            cQuery := " SELECT FQF_BEMRES "
            cQuery += " FROM " + RETSQLNAME("FQF") + " FQF "
            cQuery += " WHERE FQF_FILIAL = '" + XFILIAL("FQF") + "'"
            cQuery += " AND FQF_CODBEM = ? "
            aadd(aBindParam,oModelFQ4:GetValue("FQ4_CODBEM"))
            cQuery += " AND D_E_L_E_T_ = '' "
            cQuery += " ORDER BY FQF.FQF_COD DESC "
            cQuery := CHANGEQUERY(cQuery)
            MPSysOpenQuery(cQuery,"TRBFQF",,,aBindParam)
            If !TRBFQF->(Eof())
                cBemRes := TRBFQF->FQF_BEMRES
            EndIf
            TRBFQF->(DBCLOSEAREA())
        EndIf
    EndIf

    RestArea(aArea)

    Return cBemRes

//------------------------------------------------------------------------------------------------------------------

Function LOCA224WH

Local lRet := .T.
Local aArea := GetArea()
Local oModel := FWModelActive()
Local oModelFQF := oModel:GetModel("FQFDETAIL")
Local cSub := ""
Local cStatus := ""

    cSub := oModelFQF:GetValue("FQF_SUBST")
    cStatus := oModelFQF:GetValue("FQF_STATUS")
 
// Rossana
    FQE->(DbSetOrder(2))
    If FQE->(dbSeek(xFilial("FQE")+cStatus+cSub))
        If FQE->FQE_TIPO == "1"
            lRet := .f.
        EndIf
    EndIf

    RestArea(aArea)

    Return lRet


//------------------------------------------------------------
/*/{Protheus.doc} FLSLINPRE
Função para validar se as linhas da Grid poderão ser alteradas 

@author Pedro Alencar	
@since 28/10/2013	
@version 11.90 
@param oModelGrid, Grid do Modelo de Dados
@param nLine, Linha posicionada na grid
@param cAction, Ação que está sendo realizada na linha
@param cField, Campo posicionado
@return lRet, Se .T. a linha poderá ser editada, se .F. não 
/*/
//------------------------------------------------------------
Static Function FLSLINPRE (oModelGrid,nLine,cAction,cField)
	Local lRet := .T. 
	
	If cAction=="CANSETVALUE" 
		If oModelGrid:IsInserted()
			If nLine < oModelGrid:Length()
//				lRet := .F.			
			Endif
		Else
			lRet := .F.
		Endif
	Endif
	 	
	If cAction=="DELETE"
		If nLine = oModelGrid:Length()
		Else
			lRet := .F.		
		Endif	
	Endif	
	

Return lRet


