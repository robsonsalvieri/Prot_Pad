#Include "FISA196A.ch"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMBROWSE.CH"
#INCLUDE "FWMVCDEF.CH"

//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} FISA196A
  
Rotina de Visualização da Apuração do ICMS Recolhido Anteriormente.
Para o Estado de Rio Grande do SUL, o método de apuração é determinado pelo Decreto 54.308.

@author Bruce.Mello 
@since 28/01/2018
@version 1.0

/*/
//--------------------------------------------------------------------------------------------------
Function FISA196A()

Local oBrowse

Private lAutomato := Iif(IsBlind(),.T.,.F.)

If AliasIndic("F3Q") .And. AliasIndic("F3R") .And. AliasIndic("F3S") .And. AliasIndic("F3T") 
		DbSelectArea ("F3Q") // Apur. ICMS rec. anteriormente
		DbSelectArea ("F3R") // Apur. ICMS Rec. Ant. Det. Item
		DbSelectArea ("F3S") // Apur. ICMS Rec. Ant. Detalhada
		DbSelectArea ("F3T") // Cadastro de Regra

        oBrowse:= FWMBrowse():New()
        oBrowse:SetAlias("F3Q")
        oBrowse:SetDescription(STR0001) //STR0001 //"Apuração do ICMS Recolhido Anteriormente"
        If !lAutomato
            oBrowse:Activate()
        Else
            FISA196APU()
        EndIF
Else
        If !lAutomato
            MsgStop(STR0002) //STR0002 //"Dicionário de dados desatualizado. Favor aplicar as atualizações necessárias."
        EndIF
EndIf

Return


//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} MenuDef
Função para criação de menu [MVC].

@author Ulisses P. Oliveira
@since 06/11/2018
@version 1.0

/*/
//--------------------------------------------------------------------------------------------------
Static Function MenuDef()
    Local aRotina := {}

    ADD OPTION aRotina TITLE STR0003 ACTION 'VIEWDEF.FISA196A' OPERATION 2 ACCESS 0 //STR0003 //"Visualizar"
    ADD OPTION aRotina TITLE STR0004 ACTION 'FISA196DEL'      OPERATION 5 ACCESS 0 //STR0004 //"Excluir"
    ADD OPTION aRotina TITLE STR0005 ACTION 'FISA196APU'      OPERATION 3 ACCESS 0 //STR0005 //"Apuração"

Return ( aRotina )


//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} ModelDef
Função para criação do modelo [MVC].

@author Bruce.Mello
@since 28/01/2019
@version 1.0

/*/
//--------------------------------------------------------------------------------------------------
Static Function ModelDef()
    Local oModel
    Local oStructF3Q := FWFormStruct(1,"F3Q")
    Local oStructF3S := FWFormStruct(1,"F3S")    

    oModel := MPFormModel():New("FISA196A",,)
    oModel:AddFields("F3QMASTER",,oStructF3Q)
    oModel:AddGrid("F3SDETAIL","F3QMASTER",oStructF3S)
    oModel:SetRelation("F3SDETAIL",{{'F3S_FILIAL','xFilial("F3S")'},{'F3S_PERIOD','F3Q_PERIOD'}},F3S->(IndexKey(1)))
    oModel:GetModel("F3QMASTER"):SetOnlyView ( .T. )
    oModel:GetModel("F3SDETAIL"):SetOnlyView ( .T. )
    oModel:SetDescription(STR0006)                        //"Apuração do ICMS Presumido e Efetivo"
    oModel:GetModel("F3QMASTER"):SetDescription(STR0007) //STR0007 //"Apur. ICMS rec. anteriormente"
    oModel:GetModel("F3QMASTER"):SetDescription(STR0008) //STR0008 //"Apur. ICMS Rec. Ant. Detalhada"
Return oModel

//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
Função para criação da view [MVC].

@author Ulisses P. Oliveira
@since 06/11/2018
@version 1.0

/*/
//--------------------------------------------------------------------------------------------------
Static Function ViewDef()
Local oModel     := FWLoadModel("FISA196A")
Local oStructF3Q := FWFormStruct(2,"F3Q")
Local oStructF3S := FWFormStruct(2,"F3S")
Local oView

oStructF3S:SetProperty( 'F3S_ICMSEF' , MVC_VIEW_TITULO,STR0009) //'Efetivo'
oStructF3S:SetProperty( 'F3S_ICMSPR' , MVC_VIEW_TITULO,STR0010) //'Créd. Presumido'
oStructF3S:SetProperty( 'F3S_ICMSDE' , MVC_VIEW_TITULO,STR0011) //'Estorno'

oStructF3Q:SetProperty( 'F3Q_ICMSEF' , MVC_VIEW_TITULO,STR0009) //'Efetivo'
oStructF3Q:SetProperty( 'F3Q_ICMSPR' , MVC_VIEW_TITULO,STR0010) //'Créd. Presumido'
oStructF3Q:SetProperty( 'F3Q_ICMSDE' , MVC_VIEW_TITULO,STR0011) //'Estorno'
oStructF3Q:SetProperty( 'F3Q_TOTCOM' , MVC_VIEW_TITULO,STR0012) //'Valor a Complementar'
oStructF3Q:SetProperty( 'F3Q_TOTRES' , MVC_VIEW_TITULO,STR0013) //'Valor a Restituir'

oView := FWFormView():New()
oView:SetModel(oModel)
oView:AddField("VIEW_F3Q",oStructF3Q,"F3QMASTER")
oView:AddGrid("VIEW_F3S",oStructF3S,"F3SDETAIL")
oView:CreateHorizontalBox("HEADER",20)
oView:CreateHorizontalBox("DETAIL",80)
oView:EnableTitleView('VIEW_F3Q',STR0014) //STR0014 //"Totais da Apuração"
oView:EnableTitleView('VIEW_F3S',STR0015) //STR0015 //"Totais da Apuração por Regra"
oView:SetOwnerView("VIEW_F3Q","HEADER")
oView:SetOwnerView("VIEW_F3S","DETAIL") 

Return oView





//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} FISA196DEL
Função de exclusão da apuração selecionada, a partir da rotina FISA196A.

@author Bruce.Mello
@since 28/01/2018
@version 1.0

/*/
//--------------------------------------------------------------------------------------------------
Function FISA196DEL()
    FWExecView(STR0016,"FISA196A",MODEL_OPERATION_DELETE,,{|| DeletApur(F3Q->F3Q_PERIOD,F3Q->F3Q_LIVRO) },,,) //STR0016 //"Exclusão"
Return


//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} DeletApur
  
Função de exclusão da apuração.

@author 
@since 
@version 1.0
/*/
//--------------------------------------------------------------------------------------------------
Static Function DeletApur(cPerApur,cLivro)
    Local cQuery    := ''    

    //---Tabela F3Q [Apuração]---//Apur. ICMS rec. anteriormente 
    F3Q->(DbSetOrder(1))
    If F3Q->(DbSeek(xFilial("F3Q")+cPerApur+cLivro))
		RecLock('F3Q',.F.)
		    F3Q->(DbDelete())
		F3Q->(MsUnLock())
    EndIf

    //---Tabela F3Q [Apuração]---//Apur. ICMS rec. anteriormente 
    F3S->(DbSetOrder(1))
    If F3S->(DbSeek(xFilial("F3S")+cPerApur))
        While !F3S->(Eof()) .And. F3S->F3S_PERIOD == cPerApur 
            If  F3S->F3S_LIVRO == cLivro
                RecLock('F3S',.F.)
                    F3S->(DbDelete())
                MsUnLock()
                
            Endif
            F3S->(DbSkip())
        EndDo		
    EndIf

    
    /*//---Tabela F3S [Detalhamento apuraçao]---//Apur. ICMS Rec. Ant. Detalhada
    cQuery := "DELETE FROM " +  RetSqlName('F3S')  + " WHERE F3S_FILIAL = " + ValToSql(xFilial('F3S')) + " AND F3S_PERIOD = " + ValToSql(cPerApur) + " AND F3S_LIVRO = " + ValToSql(cLivro)
    If !Empty(AllTrim(cQuery))
        TcSqlExec(cQuery)
    EndIf

    cQuery := ''*/

    //---Tabela F3R [Detalhamento apuraçao por item]---//Apur. ICMS Rec. Ant. Det. Item
    cQuery := "DELETE FROM " +  RetSqlName('F3R')  + " WHERE F3R_FILIAL = " + ValToSql(xFilial('F3R')) + " AND F3R_PERIOD = " + ValToSql(cPerApur) + " AND F3R_LIVRO = " + ValToSql(cLivro)
    If !Empty(AllTrim(cQuery))
        TcSqlExec(cQuery)
    EndIf

Return

//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} FISA196
  
Rotina de Apuração do Ressarcimento ou Complemento do ICMS Retido por Substituição Tributária ou Antecipado.
Para o Estado de São Paulo, o método de apuração é determinado pela portaria CAT 42/2018.

@author 
@since 
@version 1.0
/*/
//--------------------------------------------------------------------------------------------------

Function FISA196APU()
    Local aArea     := GetArea()    
    Local cPerApur  := ''
    Local lVarejo   := ''
    Local cLivro    := ''
    Local lInvent   := .F.
    Local dDtInv    := CtoD('  /  /    ')
    Local lProcess  := .T.
    Local lExist    := .F.

    If Pergunte("FISA196",.T.)
        lVarejo  := Iif(MV_PAR01 == 1,.T.,.F.)
        cPerApur := MV_PAR02
        cLivro   := MV_PAR03
        lInvent  := Iif(MV_PAR04 == 1,.T.,.F.)
        dDtInv   := MV_PAR05

        //---Verifica a existência de apuração no período selecionado---//
        lExist := CheckApur(cPerApur,cLivro)        

        If !lAutomato
            If lExist
                If (ApMsgNoYes(STR0018  + CHR(10) + CHR(13) + STR0017 ) ) //STR0018 STR0017 //"Deseja fazer o reprocessamento?" //"Apuração já realizada no período selecionado."
                    DeletApur(cPerApur,cLivro)
                Else
                    lProcess := .F.
                EndIf
            EndIf
        Else
            If lExist
                DeletApur(cPerApur,cLivro)
            EndIF
        EndIF

        If lProcess
            FwMsgRun(,{|oSay| FIS196APUR(oSay,lVarejo,cPerApur,cLivro,lInvent,dDtInv)},STR0019,"") //STR0019 //"Apuração do Ressarcimento do ICMS Retido por ST"
        EndIf

    EndIf

    RestArea(aArea)
Return

//-------------------------------------------------------------------
/*/{Protheus.doc} CheckApur()
Verifica se já existe apuração processada para este período

@return	Indica se existe ou não apuração gravada para filial e período
		
@author 
@since 
@version 
/*/
//-------------------------------------------------------------------
Static Function CheckApur(cPerApur,cLivro)    
    Local lExist :=  .F.

    F3Q->(DbSetOrder(1))
    If F3Q->(DbSeek(xFilial("F3Q")+cPerApur+cLivro))
        lExist := .T.
    EndIf  

     F3S->(DbSetOrder(1))
    If F3S->(DbSeek(xFilial("F3S")+cPerApur+cLivro))
        lExist := .T.
    EndIf  

     F3R->(DbSetOrder(1))
    If F3R->(DbSeek(xFilial("F3R")+cPerApur))
        lExist := .T.
    EndIf  

Return lExist

//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} 
  
Rotina de Processamento da Apuração.

@author Ulisses P. Oliveira
@since 05/11/2018
@version 1.0
/*/
//--------------------------------------------------------------------------------------------------
Function FIS196APUR(oSay,lVarejo,cPerApur,cLivro,lInvent,dDtInv)
    Local cAlias     := GetNextAlias()    
    Local dDataDe    := CtoD('  /  /    ')
    Local dDataAte   := CtoD('  /  /    ')    
    Local dOldDate    := CtoD('  /  /    ')    
    Local aDocOriApu := {}
    Local cSelect	  := ''
    Local cFrom		  := ''
    Local cWhere	  := ''    
    Local cCodajuV    := ''    
    Local cCodajuNV   := ''
    Local cApurAnt    := ''
    Local cAliasCDA   := ''
    Local nTotDed     := 0
    Local nTotCred    := 0
    Local nTotResar   := 0
    Local nTotCompl   := 0
    Local nY          := 0
    Local nDev        := 0
    Local nValicm     := 0
    Local cCST        := ""
    Local cTipoProc   :=  "M"
    Local lLote       := .F.
    Local oApuracao   := Nil 
    Local lCmpF3R     := F3R->(FieldPos("F3R_DOCENT")) > 0  .And. F3R->(FieldPos("F3R_FORNE")) > 0  .And. F3R->(FieldPos("F3R_SERENT")) > 0 .And.;
    F3R->(FieldPos("F3R_LOJENT")) > 0 .And. F3R->(FieldPos("F3R_QTDENT")) > 0 .And. F3R->(FieldPos("F3R_CHVENT")) > 0 .And.;
    F3R->(FieldPos("F3R_ITENFE")) > 0 .And. F3R->(FieldPos("F3R_ID")) > 0 .And. F3R->(FieldPos("F3R_MODENT")) > 0  .And. F3R->(FieldPos("F3R_DTENT")) > 0
    Local cSGBD := TCGetDB()
    Local cSubStrBD := ""

    dbSelectArea("F3R")
    F3R->(dbSetOrder(1))
   
    dbSelectArea("F3Q")
    F3Q->(dbSetOrder(1))

    dbSelectArea("F3S")
    F3S->(dbSetOrder(1))
    
    If !lAutomato
        oSay:cCaption := (STR0020) //STR0020 //"Iniciando processamento..."
    EndIF

    ProcessMessages()
    
    dDataDe   := StoD(Substr(cPerApur,3,4) + Substr(cPerApur,1,2) +'01')
    dDataAte  := LastDay(dDataDe)

     //Classe responsável pela apuração
    oApuracao := FISA197APURACAO():New(cPerApur,lVarejo,dDtInv,clivro)
    //Carrega Códigos de Ajuste para regras
    oApuracao:CarregaRegra()
    //Seta base x Aliq ST
    oApuracao:oMovimento:SetlApurBase(.T.)
    //Indica se deve ser utilizado a regra de movimentos
    oApuracao:oMovimento:SetlUsaRegra(.T.)

    //Processa Estoque
    //REGRA {'01','Varejista - Apropriação do crédito relativo às mercadorias em estoque'},;
    If lInvent .and. lVarejo
        oApuracao:SetRegra(oApuracao:aVCodInv[1])
        oApuracao:SetaInventario()
        oApuracao:oInvetario:ApuraEstoque()
        oApuracao:oInvetario:SetParcUtl(01)
        oApuracao:oInvetario:ParcelaTotal()
        oApuracao:SetICMSPres(oApuracao:oInvetario:GetVlrParc())
        oApuracao:SetVlrRes(oApuracao:oInvetario:GetVlrParc())
        oApuracao:TotApur()
        //oApuracao:oInvetario:ClearInv()

    Elseif !lInvent .and. lVarejo //Processa parcela de apuração anterior
        
        dOldDate :=  DaySub( dDataDe , 1 )    //Subtrai um dia      
        cApurAnt := Month2Str( dOldDate )+Year2Str( dOldDate ) //Pega data de

        If F3S->(DbSeek(xFilial("F3S")+cApurAnt+oApuracao:aVCodInv[1]+cLivro))
            IF F3S->F3S_UTLPAR < F3S->F3S_QTDPAR
                oApuracao:SetRegra(oApuracao:aVCodInv[1])            
                oApuracao:oInvetario:SetQtParc(F3S->F3S_QTDPAR)
                oApuracao:oInvetario:SetParcUtl(F3S->F3S_UTLPAR+1)
                oApuracao:oInvetario:SetVlrTotal(F3S->F3S_VLRTOT)
                oApuracao:oInvetario:SetVlrParc(F3S->F3S_VLRPAR)
                oApuracao:SetICMSPres(oApuracao:oInvetario:GetVlrParc())
                oApuracao:SetVlrRes(oApuracao:oInvetario:GetVlrParc())
                oApuracao:TotApur()
                //oApuracao:oInvetario:ClearInv()
            Endif
        Endif
    EndIf

    
    //Classe responsável pela apuração do movimento
    //oRegra    := FISA197APURACAO():CarregaRegra()
    cCodajuV  := "IN('" + oApuracao:aVJCodCred[2] + "','" + oApuracao:aVCodEst[2] + "','" + oApuracao:aVCodDeb[2] +"')"
    cCodajuNV := "IN('" + oApuracao:aNVDeb[2] + "','" + oApuracao:aNVCred[2] +"')
    
    If !lAutomato
        oSay:cCaption := (STR0021) //STR0021 //"Verificando movimento no período..."
    EndIf
    ProcessMessages()
    
    If cSGBD = 'ORACLE'
        cSubStrBD := 'SUBSTR(SFT.FT_CLASFIS,2,2)'
    Else
        cSubStrBD := 'RIGHT(SFT.FT_CLASFIS,2)'
    EndIf

    cSelect += "CDA.CDA_TPMOVI,CDA.CDA_NUMERO,CDA.CDA_SERIE,CDA.CDA_CLIFOR,CDA.CDA_LOJA,CDA.CDA_NUMITE,CDA.CDA_BASE,CDA.CDA_ALIQ,CDA.CDA_VALOR, "
    cSelect += "SFT.FT_NFISCAL,SFT.FT_SERIE,SFT.FT_NRLIVRO,SFT.FT_ITEM,SFT.FT_TIPO,SFT.FT_CLIEFOR,SFT.FT_LOJA,SFT.FT_TIPOMOV,SFT.FT_CFOP,SFT.FT_TRFICM,SFT.FT_ISENICM,SFT.FT_OUTRICM,SFT.FT_QUANT,SFT.FT_ENTRADA,SFT.FT_PRCUNIT,SFT.FT_BASEICM,SFT.FT_NFORI,SFT.FT_SERORI,SFT.FT_ITEMORI,SFT.FT_PRODUTO,SFT.FT_VALICM,SFT.FT_CLASFIS, "
    cSelect += "SD1.D1_LOTECTL,SD1.D1_NUMLOTE,SD2.D2_LOTECTL,SD2.D2_NUMLOTE,SD1.D1_VALICM, "
    cSelect += "F3T.F3T_CODIGO,F3T.F3T_REGRA, "
    cSelect += "CDA.CDA_CODLAN,CDA.R_E_C_N_O_ As RECNOCDA"

    cFrom	+=	RetSqlName("CDA") + " CDA "
    cFrom	+=	"JOIN " + RetSqlName("F3T") + " F3T ON (F3T.F3T_FILIAL='"  + xFilial("F3T") + "' AND  F3T.F3T_CODIGO = CDA.CDA_CODLAN AND F3T.D_E_L_E_T_='' )"
    cFrom	+=	"JOIN " + RetSqlName("SFT") + " SFT ON (SFT.FT_FILIAL='"  + xFilial("SFT") + "' AND  SFT.FT_TIPOMOV IN('S','E') AND SFT.FT_SERIE=CDA.CDA_SERIE AND SFT.FT_NFISCAL=CDA.CDA_NUMERO AND "
    cFrom	+=	"SFT.FT_CLIEFOR = CDA.CDA_CLIFOR AND SFT.FT_LOJA = CDA.CDA_LOJA AND SFT.FT_ITEM = CDA.CDA_NUMITE AND SFT.FT_TIPO IN(' ','D') AND SFT.D_E_L_E_T_='' AND SFT.FT_DTCANC='' AND " 
    cFrom	+=	"SFT.FT_ENTRADA BETWEEN '" + DTOS(dDataDe) + "' AND '" + DTOS(dDataAte) +"') "
    cFrom   +=  "INNER JOIN " + RetSqlName("F2W") + " F2W ON (F2W.F2W_FILIAL = '"  + xFilial("F2W") + "' AND F2W.F2W_CFOP = SFT.FT_CFOP AND F2W.D_E_L_E_T_ = ' ')"
    cFrom   +=  "INNER JOIN " + RetSqlName("F3M") + " F3M ON (F3M.F3M_FILIAL = '"  + xFilial("F3M") + " ' AND F3M.F3M_IDF2W = F2W.F2W_IDTAB  AND F3M.F3M_CSTICM = " + cSubStrBD + " AND F3M.D_E_L_E_T_ = ' ')"
    cFrom	+=	"LEFT JOIN " + RetSqlName("SD1") + " SD1 ON (SD1.D1_FILIAL='"  + xFilial("SD1") + "' AND  SD1.D1_DOC = CDA_NUMERO  AND SD1.D1_SERIE = CDA_SERIE   AND SD1.D1_FORNECE = CDA_CLIFOR   AND SD1.D1_LOJA = CDA_LOJA AND SD1.D1_ITEM = CDA_NUMITE AND SD1.D_E_L_E_T_='')"
    cFrom	+=	"LEFT JOIN " + RetSqlName("SD2") + " SD2 ON (SD2.D2_FILIAL='"  + xFilial("SD2") + "' AND  SD2.D2_DOC = CDA_NUMERO  AND SD2.D2_SERIE = CDA_SERIE   AND SD2.D2_CLIENTE = CDA_CLIFOR   AND SD2.D2_LOJA = CDA_LOJA AND SD2.D2_ITEM = CDA_NUMITE AND SD2.D_E_L_E_T_='')"

    cWhere	+= "CDA.CDA_FILIAL = '" + xFilial("CDA") + "' AND "

    
        If lVarejo
            cWhere	+= "CDA.CDA_CODLAN "+ cCodajuV+" AND " 
        Else 
            cWhere	+= "CDA.CDA_CODLAN "+ cCodajuNV+" AND "   
        EndIf
    
    If cLivro <> "*"
        cWhere  += "SFT.FT_NRLIVRO = '"+ cLivro + "' AND "
    EndIf
    cWhere	+= "CDA.D_E_L_E_T_ = '' "


    //Monta variaveis para executar a query
    cSelect	:= "%" + cSelect + "%"
    cFrom	:= "%" + cFrom	+ "%"
    cWhere	:= "%" + cWhere	+ "%"
    

    BeginSql Alias cAlias
        COLUMN FT_ENTRADA AS DATE

        SELECT %Exp:cSelect%
        FROM  %Exp:cFrom% 
        WHERE %Exp:cWhere%
        ORDER BY SFT.FT_TIPOMOV DESC, SFT.FT_ENTRADA,SFT.FT_TIPO DESC,SFT.FT_NFISCAL
        
    EndSQL

    
        If !lAutomato
            oSay:cCaption := (STR0022) //STR0022 //"Processando movimento..."
        EndIF
        ProcessMessages()

        DbSelectArea(cAlias)
        While !(cAlias)->(Eof())
            cTipoProc   :=  "U"
            lLote       := .F.
            nTotDed     := 0
            nTotCred    := 0
            nTotResar   := 0
            nTotCompl   := 0

            Begin Transaction

            oApuracao:SetaMovim((cAlias)->FT_ENTRADA,;      //---dDataMov   - Data do Movimento                                    
                                    (cAlias)->FT_TIPOMOV,;         //---cTipoMov   - Tipo do Movimento (E-Entrada / S-Saída)
                                    (cAlias)->FT_NFISCAL,;         //---cNumDoc    - Número do Documento Fiscal
                                    (cAlias)->FT_SERIE,;           //---cSerieDoc  - Série do Documento Fiscal
                                    (cAlias)->FT_ITEM,;            //---cItemDoc   - Item do Documento Fiscal                                                                
                                    (cAlias)->FT_TIPO,;            //---cTipoDoc   - Tipo do Documento (Normal / Devolução / Complemento)
                                    (cAlias)->FT_PRODUTO,;         //---cCodProd   - Código do Produto
                                    (cAlias)->FT_CLIEFOR,;         //---cCodPart   - Código do Participante
                                    (cAlias)->FT_LOJA,;            //--- Loja
                                    "",;                           //---Numero do Lote
                                    "",;                           //---Numero do CTL
                                    (cAlias)->FT_QUANT,;           //---nQtdade    - Quantidade
                                    (cAlias)->F3T_REGRA,;            //---Regra
                                    (cAlias)->CDA_CODLAN,;         //Código de Ajuste
                                    0,;                            //---ICMS Efetivo cálculado na saída
                                    0,;                            //---ICMS Presumido calculado na Entrada
                                    0,;                            //---ICMS a Estornar
                                    0,;                            //---Valor ICMS a ressarcir
                                    0)                             //---Valor ICMS a complementar

            

            //Informe Lote            
            If (cAlias)->FT_TIPOMOV =="E" .And. !Empty((cAlias)->(D1_LOTECTL))
                oApuracao:SetLote((cAlias)->D1_NUMLOTE)
                oApuracao:SetLoteCTL((cAlias)->D1_LOTECTL)
                cTipoProc := "L"
            Elseif (cAlias)->FT_TIPOMOV =="S" .and. !Empty((cAlias)->(D2_LOTECTL))
                oApuracao:SetLote((cAlias)->D2_NUMLOTE)
                oApuracao:SetLoteCTL((cAlias)->D2_LOTECTL)     
                cTipoProc := "L"
            Endif

            If lVarejo .And. (cAlias)->F3T_REGRA  == "02" //{'02','Varejista - Apropriação de crédito relativo às entradas de mercadoria recebidas'},;
                
                //cCST := Substr((cAlias)->FT_CLASFIS,2,3)
                //nValicm := IiF((cAlias)->FT_VALICM == 0 .and. cCST =='10',(cAlias)->D1_VALICM,(cAlias)->FT_VALICM)

                oApuracao:SetICMSPres((cAlias)->CDA_VALOR)
                oApuracao:SetVlrRes((cAlias)->CDA_VALOR)
                oApuracao:TotApur()
                
                
                //Grava item  - Apur. ICMS Rec. Ant. Det. Item
                GravaF3R(cPerApur,oApuracao,,lCmpF3R)

            ElseIf lVarejo .And. (cAlias)->F3T_REGRA  == "04" //{'04','Varejista - Debito'},;
                oApuracao:SetICMSEfet((cAlias)->CDA_VALOR)
                //oApuracao:SetVlrComp((cAlias)->CDA_VALOR)
                oApuracao:TotApur()

                //Grava item  - Apur. ICMS Rec. Ant. Det. Item
                GravaF3R(cPerApur,oApuracao,,lCmpF3R)
                
            ElseIf lVarejo .And. (cAlias)->F3T_REGRA  == "03" //{'03','Varejista - Estorno do crédito lançado pelas entradas ou pelo inventário do estoque'},;
               

                If cTipoProc == "L" //Utiliza lote para encontrar entrada
                    oApuracao:SetEntrada("L")
                    oApuracao:oMovimento:ICMSUnitEnt()                    
                Endif

                //Caso não encontre nota por lote utilizo ultima entrada
                If Len(oApuracao:oMovimento:aSldVlrDet) == 0
                    oApuracao:SetEntrada("U")
                    oApuracao:oMovimento:ICMSUnitEnt()                        
                Endif

                //Verifica se existe notas de entrada
                If Len(oApuracao:oMovimento:aSldVlrDet) > 0

                    For nY:= 1 to Len(oApuracao:oMovimento:aSldVlrDet)
                        
                        //Valor unitario entrada * qunt saida                        
                        nTotDed  += Round(oApuracao:oMovimento:aSldVlrDet[nY][9] * oApuracao:nQtdade, 2)
                        oApuracao:SetICMSDed(nTotDed)

                        If lCmpF3R
                            //Grava Item saída
                            GravaF3R(cPerApur,oApuracao,oApuracao:oMovimento:aSldVlrDet[nY],lCmpF3R)                   
                        EndIf                       
                    Next

                    
                    oApuracao:TotApur()

                    //Atualiza CDA
                    GravaCDA((cAlias)->RECNOCDA,nTotDed)

                    If !lCmpF3R
                        //Grava Item saída
                        GravaF3R(cPerApur,oApuracao,,lCmpF3R)                   
                    EndIf 

                    //Grava Itens entrada
                    GravaF3REnt(cPerApur,oApuracao,lCmpF3R)

                    //Limpa notas de entarda processadas
                    oApuracao:oMovimento:ClearEntrada()
                Endif

            Elseif !lVarejo .and. (cAlias)->F3T_REGRA  == "06" .and. (cAlias)->FT_TIPOMOV =="S"//{'06','Não Varejista - Debito.'},; efetivo calculado na saída
                    oApuracao:SetICMSEfet((cAlias)->CDA_VALOR)
                    //oApuracao:SetVlrComp((cAlias)->CDA_VALOR)
                    oApuracao:TotApur()

                    //Grava item  - Apur. ICMS Rec. Ant. Det. Item
                    GravaF3R(cPerApur,oApuracao,,lCmpF3R)

            Elseif !lVarejo .and. (cAlias)->F3T_REGRA  == "07" .and. (cAlias)->FT_TIPOMOV =="S"//{'07','Não Varejista - Apropriação do crédito de mercadoria recebidas com ST.'}}

                If cTipoProc == "L" //Utiliza lote para encontrar entrada
                    oApuracao:SetEntrada("L")
                    oApuracao:oMovimento:ICMSUnitEnt()                    
                Endif

                //Caso não encontre nota por lote utilizo ultima entrada
                If Len(oApuracao:oMovimento:aSldVlrDet) == 0
                    oApuracao:SetEntrada("U")
                    oApuracao:oMovimento:ICMSUnitEnt()                        
                Endif

                //Verifica se existe nota de entrada
                If Len(oApuracao:oMovimento:aSldVlrDet) > 0

                    For nY:= 1 to Len(oApuracao:oMovimento:aSldVlrDet)
                         
                        //Valor unitario entrada * qunt saida
                        nTotCred  += Round(oApuracao:oMovimento:aSldVlrDet[nY][9] * oApuracao:nQtdade, 2)
                        oApuracao:SetICMSPres(nTotCred)

                         If lCmpF3R
                            //Grava Item saída
                            GravaF3R(cPerApur,oApuracao,oApuracao:oMovimento:aSldVlrDet[nY],lCmpF3R)                   
                        EndIf
                    Next
                    
                    oApuracao:TotApur()

                    //Atualiza CDA
                    GravaCDA((cAlias)->RECNOCDA,nTotCred)
 
                    If !lCmpF3R
                        //Grava Item saída
                        GravaF3R(cPerApur,oApuracao,,lCmpF3R)                   
                    EndIf 

                    //Grava Itens entrada
                    GravaF3REnt(cPerApur,oApuracao,lCmpF3R)

                    //Limpa notas de entarda processadas
                    oApuracao:oMovimento:ClearEntrada()
                Endif                
                    
            Elseif !lVarejo .and. (cAlias)->F3T_REGRA  == "07" .And. (cAlias)->FT_TIPOMOV =="E" .and. (cAlias)->FT_TIPO =="D" .And. !Empty((cAlias)->FT_NFORI)
                //Devolução Não Varejista
                cAliasCDA		:= GetNextAlias()
                BeginSql Alias cAliasCDA
                    SELECT CDA_VALOR,CDA_CODLAN,CDA_NUMERO
                    FROM  %Table:CDA% CDA	
                    WHERE 
                    CDA.CDA_FILIAL=%xFilial:CDA% AND
                    CDA.CDA_TPMOVI="S" AND
                    CDA.CDA_NUMERO=%Exp:(cAlias)->FT_NFORI% AND
                    CDA.CDA_SERIE=%Exp:(cAlias)->FT_SERORI% AND
                    CDA.CDA_NUMITE=%Exp:(cAlias)->FT_ITEMORI% AND
                    CDA.%NotDel%
                EndSql
                

                While !(cAliasCDA)->(EOF())
                    IF AllTrim((cAliasCDA)->CDA_CODLAN) ==  oApuracao:aNVDeb[2]				
                        nDev := (cAliasCDA)->CDA_VALOR
                        //Atualiza a tabela CDA
                        CDA->(DbGoTo((cAlias)->RECNOCDA)) // se possiciona na devolução
                        If AllTrim(CDA->CDA_CODLAN) == oApuracao:aNVCred[2]
                            RecLock("CDA",.F.)
                            nDev := nDev / (cAlias)->QUANT				
                            CDA->CDA_VALOR :=	nDev * (cAlias)->FT_QUANT
                            CDA->(MsUnlock())
                            
                            oApuracao:SetICMSPres((cAlias)->CDA_VALOR)
                            //oApuracao:SetVlrRes((cAlias)->CDA_VALOR)
                            oApuracao:TotApur()               
                            
                            //Grava item  - Apur. ICMS Rec. Ant. Det. Item
                            GravaF3R(cPerApur,oApuracao,,lCmpF3R)

                        Endif			
                    ElseIf AllTrim((cAliasCDA)->CDA_CODLAN) ==  oApuracao:aNVCred[2]
                        nDev := (cAliasCDA)->CDA_VALOR
                        //Atualiza a tabela CDA
                        CDA->(DbGoTo((cAlias)->RECNOCDA)) // se possiciona na devolução
                        If AllTrim(CDA->CDA_CODLAN) == oApuracao:aNVDeb[2]
                            RecLock("CDA",.F.)
                            nDev := nDev / (cAlias)->QUANT				
                            CDA->CDA_VALOR :=	nDev * (cAlias)->FT_QUANT
                            CDA->(MsUnlock())

                            oApuracao:SetICMSEfet((cAlias)->CDA_VALOR)
                            //oApuracao:SetVlrRes((cAlias)->CDA_VALOR)
                            oApuracao:TotApur()               
                            
                            //Grava item  - Apur. ICMS Rec. Ant. Det. Item
                            GravaF3R(cPerApur,oApuracao,,lCmpF3R)

                        Endif
                    Endif
                    (cAliasCDA)->(dbSkip())
                Enddo
                (cAliasCDA)->(dbCloseArea())
            EndIf            

            End Transaction

            (cAlias)->(DbSkip())
        EndDo
        (cAlias)->(DbCloseArea())
        
        If len(oApuracao:aTotApur) > 0 //Grava Apuração
            GravaF3S(cPerApur,oApuracao)        
        Else
            MsgInfo(STR0023) //"Não foram encontradados movimentos de estoque ou notas para Apuração"
        Endif

        //Limpa Objeto
        FreeObj(oApuracao)
	    oApuracao:= nil

Return

//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} GravaF3S
  
Função que grava, nas tabelas F3S

cGrava = 1 - Estoque
cGrava = 2 - Movimento

@author 
@since 
@version 
/*/
//--------------------------------------------------------------------------------------------------
Static Function GravaF3S(cPerApur,oApuracao)
Local nPos   :=0
Local nMontPresu := 0
Local nMontEfet := 0

If len(oApuracao:aTotApur) > 0
    For nPos := 1 to len(oApuracao:aTotApur)

        RecLock('F3S',.T.)
        F3S->F3S_FILIAL := xFilial("F3S")
        F3S->F3S_PERIOD := oApuracao:cMesAno
        F3S->F3S_LIVRO  := oApuracao:clivro        

        //---Dados do Movimento---//
        F3S->F3S_REGRA  := oApuracao:aTotApur[nPos][1]
        F3S->F3S_ICMSEF := oApuracao:aTotApur[nPos][2]
        F3S->F3S_ICMSPR := oApuracao:aTotApur[nPos][3]
        F3S->F3S_ICMSDE := oApuracao:aTotApur[nPos][4]        

        F3S->F3S_VLRTOT := oApuracao:aTotApur[nPos][7]        
        F3S->F3S_VLRPAR := oApuracao:aTotApur[nPos][8]        
        F3S->F3S_QTDPAR := oApuracao:aTotApur[nPos][9]        
        F3S->F3S_UTLPAR := oApuracao:aTotApur[nPos][10]
        F3S->(MsUnlock())
    


        //Gravação F3Q
        If nPos == 1
            RecLock('F3Q',.T.)
                F3Q->F3Q_FILIAL := xFilial("F3Q")
                F3Q->F3Q_PERIOD := oApuracao:cMesAno
                F3Q->F3Q_LIVRO  := oApuracao:clivro        

                //---Dados do Movimento---//        
                F3Q->F3Q_ICMSEF += oApuracao:aTotApur[nPos][2]
                F3Q->F3Q_ICMSPR += oApuracao:aTotApur[nPos][3]
                F3Q->F3Q_ICMSDE += oApuracao:aTotApur[nPos][4]
                //F3Q->F3Q_TOTCOM += oApuracao:aTotApur[nPos][5]
                //F3Q->F3Q_TOTRES += oApuracao:aTotApur[nPos][6]+oApuracao:aTotApur[nPos][8]
            F3Q->(MsUnlock())
        Else
            RecLock('F3Q',.F.)
                F3Q->F3Q_ICMSEF += oApuracao:aTotApur[nPos][2]
                F3Q->F3Q_ICMSPR += oApuracao:aTotApur[nPos][3]
                F3Q->F3Q_ICMSDE += oApuracao:aTotApur[nPos][4]
                //F3Q->F3Q_TOTCOM += oApuracao:aTotApur[nPos][5]
                //F3Q->F3Q_TOTRES += oApuracao:aTotApur[nPos][6]+oApuracao:aTotApur[nPos][8]
            F3Q->(MsUnlock())
        Endif        
    Next

    
    
    //Montante do Imposto Presumido
    nMontPresu := F3Q->F3Q_ICMSPR - F3Q->F3Q_ICMSDE
    //Montante do Imposto Efetivo menos Montante do Imposto Presumido
    nMontEfet := F3Q->F3Q_ICMSEF - nMontPresu
    
    RecLock('F3Q',.F.)
        //Ressarcir
        If nMontEfet > 0
            F3Q->F3Q_TOTCOM := nMontEfet
        Else 
            //Complementar
            F3Q->F3Q_TOTRES := nMontEfet*(-1)
        Endif
        
    F3Q->(MsUnlock())

Endif


Return

//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} GravaF3R
  
Função que grava, nas tabelas F3R

@author 
@since 
@version 
/*/
//--------------------------------------------------------------------------------------------------
Static Function GravaF3R(cPerApur,oApuracao, aNfe, lCmpF3R)
Local cTipoMov := oApuracao:cTipoMov
Local cSerie := oApuracao:cSerieDoc
Local cNfiscal := oApuracao:cNumDoc
Local cPartic := oApuracao:cCodPart
Local cLojPart := oApuracao:cLojPart
Local cItem := oApuracao:cItemDoc
Local cProd := oApuracao:cCodProd
Local nMontPresu := 0
Local nMontEfet := 0

//F3R_FILIAL+F3R_PERIOD+F3R_TIPO+F3R_SERIE+F3R_NFISCA+F3R_PARTIC+F3R_LOJA+F3R_ITEM+F3R_PRODUT
//F3R_FILIAL+F3R_PERIOD+F3R_TIPO+F3R_SERIE+F3R_NFISCA+F3R_PARTIC+F3R_LOJA+F3R_ITEM+F3R_PRODUT                                                                     
Local lAchouF3R := F3R->(MsSeek(xFilial("F3R")+cPerApur+cTipoMov+cSerie+cNfiscal+cPartic+cLojPart+cItem+cProd))

Default aNfe := {}
//Default lCmpF3R := .F.


IF  lAchouF3R .And. !lCmpF3R
    RecLock('F3R',.F.)
    F3R->F3R_ICMSEF += oApuracao:nICMSEfet
    F3R->F3R_ICMSPR += oApuracao:nICMSPres
    F3R->F3R_ICMSDE += oApuracao:nICMSDed
    //F3R->F3R_VLRRES := oApuracao:nVlrRes
    //F3R->F3R_VLRCOM := oApuracao:nVlrComp
    F3R->(MsUnlock())
ElseIf lCmpF3R .Or. !lAchouF3R
    If lAchouF3R
        RecLock('F3R',.F.)
    Else
        RecLock('F3R',.T.)
    EndIf
    F3R->F3R_FILIAL := xFilial("F3R")
    F3R->F3R_PERIOD := oApuracao:cMesAno
    F3R->F3R_LIVRO  := oApuracao:clivro

    //---Dados do Movimento---//
    F3R->F3R_ICMSEF += oApuracao:nICMSEfet
    F3R->F3R_ICMSPR := oApuracao:nICMSPres
    F3R->F3R_ICMSDE += oApuracao:nICMSDed
    F3R->F3R_NFISCA := oApuracao:cNumDoc
    F3R->F3R_SERIE  := oApuracao:cSerieDoc
    F3R->F3R_ITEM   := oApuracao:cItemDoc
    F3R->F3R_PARTIC := oApuracao:cCodPart
    F3R->F3R_LOJA   := oApuracao:cLojPart
    F3R->F3R_PRODUT := oApuracao:cCodProd
    F3R->F3R_LOTE   := oApuracao:cLoteCTL
    F3R->F3R_TIPO   := oApuracao:cTipoMov
    F3R->F3R_QTDMOV := oApuracao:nQtdade
    F3R->F3R_DTMOV  := oApuracao:dDataMov

    If lCmpF3R .And. Len(aNfe) > 0
        F3R->F3R_DOCENT := aNfe[1]
        F3R->F3R_SERENT := aNfe[2]
        F3R->F3R_FORNE  := aNfe[3]
        F3R->F3R_LOJENT := aNfe[4]
        F3R->F3R_ITENFE := aNfe[5]
        F3R->F3R_QTDENT := aNfe[7]
        F3R->F3R_CHVENT := aNfe[13]
        F3R->F3R_ID     := FWUUID("FISA196")
        F3R->F3R_MODENT := aNfe[14]
        F3R->F3R_DTENT  := aNfe[12]
    ElseIf lCmpF3R
        F3R->F3R_ID     := FWUUID("FISA196")
    EndIf

    F3R->(MsUnlock())   

Endif

iF !oApuracao:lVarejo .And. !lCmpF3R
    //Montante do Imposto Presumido
    nMontPresu := F3R->(F3R_ICMSPR - F3R_ICMSDE)
    //Montante do Imposto Efetivo menos Montante do Imposto Presumido
    nMontEfet := F3R->F3R_ICMSEF - nMontPresu

    RecLock('F3R',.F.)
    //Ressarcir
    If nMontEfet > 0
        F3R->F3R_VLRCOM := nMontEfet
    Else 
        //Complementar
        F3R->F3R_VLRRES := nMontEfet*(-1)
    Endif
            
    F3Q->(MsUnlock())
EndIf



Return

//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} GravaF3R
  
Função que grava itens da entrada, nas tabelas F3R

@author 
@since 
@version 
/*/
//--------------------------------------------------------------------------------------------------
Static Function GravaF3REnt(cPerApur,oApuracao,lCmpF3R)
Local nY := 0
Local cTipoMov     := ""
Local cSerie    := ""
Local cNfiscal  := ""
Local cPartic   := ""
Local cLojPart  := ""
Local cItem     := ""
Local cProd     := ""
Local cType     := ""

For nY:= 1 to Len(oApuracao:oMovimento:aSldVlrDet)

    cTipoMov    := oApuracao:oMovimento:aSldVlrDet[nY][11]
    cSerie      := oApuracao:oMovimento:aSldVlrDet[nY][2]
    cNfiscal    := oApuracao:oMovimento:aSldVlrDet[nY][1]
    cPartic     := oApuracao:oMovimento:aSldVlrDet[nY][3]
    cLojPart    := oApuracao:oMovimento:aSldVlrDet[nY][4]
    cItem       := oApuracao:oMovimento:aSldVlrDet[nY][5]
    cProd       := oApuracao:oMovimento:aSldVlrDet[nY][6]

    IF F3R->(MsSeek(xFilial("F3R")+cPerApur+cTipoMov+cSerie+cNfiscal+cPartic+cLojPart+cItem+cProd))
        RecLock('F3R',.F.)
            //F3R->F3R_ICMSEF += oApuracao:nICMSEfet
            F3R->F3R_ICMSPR += oApuracao:nICMSPres
            //F3R->F3R_ICMSDE += oApuracao:nICMSDed
            //F3R->F3R_VLRRES := oApuracao:nVlrRes
            //F3R->F3R_VLRCOM := oApuracao:nVlrComp
        F3R->(MsUnlock())
    Else
        RecLock('F3R',.T.)
        F3R->F3R_FILIAL := xFilial("F3R")
        F3R->F3R_PERIOD := oApuracao:cMesAno
        F3R->F3R_LIVRO  := oApuracao:clivro

        //---Dados do Movimento---//
        //F3R->F3R_ICMSEF := oApuracao:nICMSEfet
        F3R->F3R_ICMSPR := oApuracao:nICMSPres
        //F3R->F3R_ICMSDE := oApuracao:nICMSDed
        //F3R->F3R_VLRRES := oApuracao:nVlrRes
        //F3R->F3R_VLRCOM := oApuracao:nVlrComp

        F3R->F3R_NFISCA := oApuracao:oMovimento:aSldVlrDet[nY][1]
        F3R->F3R_SERIE  := oApuracao:oMovimento:aSldVlrDet[nY][2]
        F3R->F3R_PARTIC := oApuracao:oMovimento:aSldVlrDet[nY][3]
        F3R->F3R_LOJA   := oApuracao:oMovimento:aSldVlrDet[nY][4]
        F3R->F3R_ITEM   := oApuracao:oMovimento:aSldVlrDet[nY][5]    
        F3R->F3R_PRODUT := oApuracao:oMovimento:aSldVlrDet[nY][6]
        F3R->F3R_QTDMOV := oApuracao:oMovimento:aSldVlrDet[nY][7]
        F3R->F3R_LOTE   := oApuracao:oMovimento:aSldVlrDet[nY][10]
        F3R->F3R_TIPO   := oApuracao:oMovimento:aSldVlrDet[nY][11]    
        
        cType:= ValType(oApuracao:oMovimento:aSldVlrDet[nY][12])
        If cType =="D"
            F3R->F3R_DTMOV  := oApuracao:oMovimento:aSldVlrDet[nY][12]
        Elseif cType =="C"
            F3R->F3R_DTMOV  := cTod(oApuracao:oMovimento:aSldVlrDet[nY][12])
        Endif

        If lCmpF3R
            F3R->F3R_CHVENT := oApuracao:oMovimento:aSldVlrDet[nY][13]
            F3R->F3R_ID     := FWUUID("FISA196")
            F3R->F3R_MODENT := oApuracao:oMovimento:aSldVlrDet[nY][14]
            F3R->F3R_DTENT  := oApuracao:oMovimento:aSldVlrDet[nY][12]
        EndIf

        F3R->(MsUnlock())
    Endif
Next

Return


//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} GravaCDA
  
Função que grava itens da entrada, nas tabelas F3R

@author 
@since 
@version 
/*/
//--------------------------------------------------------------------------------------------------
Static Function GravaCDA(cRECNOCDA,nValor)
    
    CDA->(DbGoTo(cRECNOCDA))
    RecLock("CDA",.F.)    
        CDA->CDA_VALOR :=	nValor    
    CDA->(MsUnlock())

Return


//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} ResICMSST
Função que adiciona na apuração valor e descrição da parcela do inventario / regra 01

@author 
@since 
@version 
/*/
//--------------------------------------------------------------------------------------------------
Function ResICMSST()
Local aValor := {0,0,0,0,0}
Local cPar   :=  ""
Local cLivro := cValToChar(MV_PAR03)
Local cChave := ""

cPar   := Iif(Len(AllTrim(cValtochar(MV_PAR01))) == 1,"0","") + cValtochar(MV_PAR01) + cValtochar(MV_PAR02)
cChave := cPar+cLivro

DbSelectArea ("F3S")    

If cLivro == "*"
    cChave := cPar
Else
    //Utilizado somente na SubApuração
    IF F3S->(MsSeek(xFilial("F3S")+cPar+'01'+cLivro))
        //cMsg := cValToChar(F3S->F3S_UTLPAR) +"/"+ cValToChar(F3S->F3S_QTDPAR)
        //Retorna Valor inventario
        aValor[1] := F3S->F3S_VLRPAR    
    Endif
Endif

//F3Q_FILIAL+F3Q_PERIOD+F3Q_LIVRO                                                                                                                                 
If  F3Q->(MsSeek(xFilial("F3Q")+cChave))      

    //Retorna valor a Restituir    
    aValor[2] := F3Q->F3Q_TOTRES

    //Retorna valor a Complementar 
    aValor[3] := F3Q->F3Q_TOTCOM

    
Endif

Return aValor