#INCLUDE 'PROTHEUS.CH'
#INCLUDE 'FWMVCDEF.CH'
#INCLUDE 'GTPA903.CH'

Static aResultGIM   := {}
Static aPlanExec    := {}
Static c903BCodigo  := ""
Static oG903Model   := Nil

//------------------------------------------------------------------------------------------
/*/{Protheus.doc} GTPA903()
Cadastro de Apuração de contrato
@sample		GTPA903()
@return		oBrowse  Retorna o Cadastro de Apuração de contrato
@author	GTP
@since		01/12/2020
@version	P12
/*/
//------------------------------------------------------------------------------------------

Function GTPA903()

Local oBrowse	:= Nil
Local cMsgErro  := ''

If ( !FindFunction("GTPHASACCESS") .Or.; 
	( FindFunction("GTPHASACCESS") .And. GTPHasAccess() ) ) 
        
    If G900VldDic(@cMsgErro)
        oBrowse:=FWMBrowse():New()
        oBrowse:SetAlias("GQR")
        oBrowse:SetDescription(STR0001)		// "Apuração de contrato"
        If GQR->(FieldPos("GQR_STATUS")) > 0
            oBrowse:AddLegend('GQR_STATUS == "1"',"YELLOW","Em apuração")
            oBrowse:AddLegend('GQR_STATUS == "2"',"GREEN" ,"Apuração efetivada")
            oBrowse:AddLegend('GQR_STATUS == "3"',"RED"	  ,"Erro na geração")
        EndIf
        If !(IsBlind())
            oBrowse:Activate()
        EndIf
    Else
        FwAlertHelp(cMsgErro, STR0029,)	// "Dicionário desatualizado", "Atualize o dicionário para utilizar esta rotina"
    Endif 

EndIf

Return()

//------------------------------------------------------------------------------------------
/*/{Protheus.doc} ModelDef()
Definição do modelo de Dados
@sample		ModelDef()
@return		oModel - Retorna o Modelo de dados 
@author	GTP
@since		01/12/2020
@version	P12
/*/
//------------------------------------------------------------------------------------------
Static Function ModelDef()

    Local oStruGQR as object
    Local oStruG9W as object
    Local oStruG54 as object
    Local oStruGYN as object
    Local bCommit  as block

    oStruGQR := FWFormStruct(1, 'GQR' ) //Apuração de contrato
    oStruG9W := FWFormStruct(1, 'G9W' ) //Orcamentos apuracao contratos 
    oStruG54 := FWFormStruct(1, 'G54' ) //Totais Linha Apuracao Orcament
    oStruGYN := FwFormStruct(1, 'GYN' ) //Viagens 
    bCommit  := {|oModel| G903Commit(oModel)}

    oG903Model := MPFormModel():New('GTPA903',,{|oModel|TP903TudOK(oModel)})

    SetStruct('M',oStruGQR, oStruG9W, oStruG54, oStruGYN)

    //campos do cabeçalho
    oG903Model:AddFields('GQRMASTER',/*cOwner*/,oStruGQR)
    // Orçamentos de contrato
    oG903Model:AddGrid("G9WDETAIL","GQRMASTER",oStruG9W)

    //Totais por Linha da Apuracao Orcamento de Contrato
    oG903Model:AddGrid("G54DETAIL","G9WDETAIL",oStruG54)

    //Viagens por linha - Listagem
    oG903Model:AddGrid('GYNDETAIL','G54DETAIL',oStruGYN)
    
    oG903Model:GetModel("G54DETAIL" ):SetOptional( .T. )
    oG903Model:GetModel("G54DETAIL" ):SetDescription( STR0002 ) //"Totalizador Linha"

    If AliasInDic("G9W") .AND. AliasInDic("GQR")
        oG903Model:SetRelation( 'G9WDETAIL', { { 'G9W_FILIAL', 'xFilial( "GQR" )' }, { 'G9W_CODGQR'	, 'GQR_CODIGO' } } , G9W->(IndexKey(1))) 
    EndIf
    If AliasInDic("G9W") .AND. AliasInDic("G54")
        oG903Model:SetRelation('G54DETAIL', {{'G54_FILIAL', 'xFilial("G9W")'},;
                                        {'G54_CODGQR', 'G9W_CODGQR'} ,;  
                                        {'G54_NUMGY0','G9W_NUMGY0'},;
                                        {'G54_REVISA','G9W_REVISA'}}, G54->(IndexKey(1)))
    EndIf
    If AliasInDic("G54")
        oG903Model:SetRelation( 'GYNDETAIL', { { 'GYN_FILIAL', 'xFilial("G54")' },;
                                        { 'GYN_APUCON', 'G54_CODGQR' },;
                                        { 'GYN_LINCOD', 'G54_CODGI2'}} , GYN->(IndexKey(9))) 
    EndIf
    //Permite grid sem dados
    oG903Model:GetModel('GYNDETAIL'):SetOptional(.T.)
    oG903Model:GetModel('GYNDETAIL'):SetOnlyQuery(.T.)

    oG903Model:SetDescription(STR0001)
    oG903Model:GetModel('GYNDETAIL'):SetDescription(STR0003)	// "Viagens por Linha"
    oG903Model:SetPrimaryKey({"GQR_FILIAL","GQR_CODIGO"})

    oG903Model:GetModel('G9WDETAIL'):SetNoInsertLine(.T.)
    oG903Model:GetModel('G9WDETAIL'):SetNoDeleteLine(.T.)

    oG903Model:GetModel('G54DETAIL'):SetNoInsertLine(.T.)
    oG903Model:GetModel('G54DETAIL'):SetNoDeleteLine(.T.)

    oG903Model:GetModel('GYNDETAIL'):SetNoInsertLine(.T.)
    oG903Model:GetModel('GYNDETAIL'):SetNoUpdateLine(.T.)
    oG903Model:GetModel('GYNDETAIL'):SetNoDeleteLine(.T.)

    oG903Model:SetVldActivate({|oModel| G903VldAct(oModel)})

    oG903Model:SetCommit(bCommit)

Return(oG903Model)
//------------------------------------------------------------------------------------------
/*/{Protheus.doc} ViewDef()
Definição da interface
@sample		ViewDef()
@return		oView - Retorna a View
@author	GTP
@since		01/12/2020
@version	P12
/*/
//------------------------------------------------------------------------------------------
Static Function ViewDef()

    Local oModel   as object
    Local oView    as object
    Local oStruGQR as object
    Local oStruG9W as object
    Local oStruG54 as object
    Local oStruGYN as object
    
    oModel   := ModelDef()
    oView    := FWFormView():New()
    oStruGQR := FWFormStruct(2, 'GQR' )
    oStruG9W := FWFormStruct(2, 'G9W' )
    oStruG54 := FWFormStruct(2, 'G54' )
    oStruGYN := FWFormStruct(2, 'GYN' )
    
    SetStruct('V',oStruGQR, oStruG9W, oStruG54, oStruGYN)
    
    oView:SetModel(oModel)
    
    oView:AddField('VIEW_GQR', oStruGQR,'GQRMASTER')
    oView:AddGRID('VIEW_G9W', oStruG9W, 'G9WDETAIL')
    oView:AddGRID('VIEW_G54', oStruG54, "G54DETAIL")
    
    oView:CreateHorizontalBox('HEADER', 25)
    oView:CreateHorizontalBox('GRIDCONTRATO', 35)
    oView:CreateHorizontalBox('GRIDLINHA', 40)
    
    oView:SetOwnerView('VIEW_GQR','HEADER')
    oView:SetOwnerView('VIEW_G9W','GRIDCONTRATO')
    oView:SetOwnerView('VIEW_G54','GRIDLINHA')
    
    // Liga a identificacao do componente
    oView:EnableTitleView('VIEW_GQR',STR0001)//'Apuração de contrato'
    oView:EnableTitleView('VIEW_G9W',STR0043)//'Contratos'
    oView:EnableTitleView('VIEW_G54',STR0004)//'Totais por Linha')
    
    oView:SetViewProperty('VIEW_G9W', 'CHANGELINE', {{|oView, oViewId| LineChange(oView, oViewId)}})
    oView:SetViewProperty('VIEW_G54', 'CHANGELINE', {{|oView, oViewId| LineChange(oView, oViewId)}})

    oView:AddUserButton(STR0044, "", {|oModel| ConsultaVia(oModel)},,VK_F5 )   // 'Consulta Viagens (F5)'
    
    If ( GTPxVldDic("H6Q",,.T.,.T.,/*@cMsgErro*/) )
        oView:AddUserButton(STR0045, "", {|oView| G903Rateio(oView)},,VK_F6 ) //'Cons. Rateio Produto (F6)'
    EndIf

Return( oView )

//------------------------------------------------------------------------------------------
/*/{Protheus.doc} MenuDef()
Definição do Menu
@sample		MenuDef()
@return		aRotina - Array de opções do menu
@author	GTP
@since		01/12/2020
@version	P12
/*/
//------------------------------------------------------------------------------------------
Static Function MenuDef()

    Local aRotina as array

    aRotina := {}

    ADD OPTION aRotina TITLE STR0005    ACTION 'VIEWDEF.GTPA903'    OPERATION 2 ACCESS 0 // Visualizar
    ADD OPTION aRotina TITLE STR0006    ACTION 'GTPA903Ger'         OPERATION 3 ACCESS 0 // Gerar Apuração
    ADD OPTION aRotina TITLE STR0030    ACTION 'VIEWDEF.GTPA903'    OPERATION 4 ACCESS 0 // Alterar
    ADD OPTION aRotina TITLE STR0007    ACTION 'VIEWDEF.GTPA903'    OPERATION 5 ACCESS 0 // Excluir
    ADD OPTION aRotina TITLE STR0031    ACTION 'GTPA903B'           OPERATION 4 ACCESS 0 // Gerar Medição
    ADD OPTION aRotina TITLE STR0032    ACTION 'GTPA903C'           OPERATION 4 ACCESS 0 // Estornar Medição

    If FindFunction( 'GTPA903D' )
        ADD OPTION aRotina TITLE STR0038    ACTION 'GTPA903D()'     OPERATION 4 ACCESS 0 // Checklist Documentos da Apuração
    EndIf

    If FindFunction( 'GTPR550' )
        ADD OPTION aRotina TITLE STR0046 ACTION 'GTPR550'     OPERATION 8 ACCESS 0 // Relatório de Apuração
    EndIf   

Return aRotina

//------------------------------------------------------------------------------------------
/*/{Protheus.doc} TP903TudOK()
Validação do Modelo 
@sample	TP903TudOK(oModel)
@param		oModel   Modelo de Dados
@return	lRet - Retorna a validacao do modelo de dados (TudoOK)
@author	Inovação
@since		01/12/2020
@version	P12
/*/
//------------------------------------------------------------------------------------------
Static Function TP903TudOK(oModel)
    Local nOperation	:= oModel:GetOperation()
    Local lRet			:= .T.

    // Se já existir a chave no banco de dados no momento do commit, a rotina 
    If (nOperation == MODEL_OPERATION_INSERT .OR. nOperation == MODEL_OPERATION_UPDATE)
    	If (!ExistChav("GQR", oModel:GetModel('GQRMASTER'):GetValue("GQR_CODIGO")))
    		Help( ,, 'Help',"TP903TdOK", STR0008, 1, 0 )//Chave duplicada!
           lRet := .F.
        EndIf
    EndIf

    If !ValidMarks(oModel)
        lRet := .F.
        oModel:SetErrorMessage(oModel:GetId(),"",oModel:GetId(),"","ValidMarks", STR0033) //"Selecione ao menos um contrato e uma linha para finalizar a apuração"
    Endif

Return lRet

/*/{Protheus.doc} GTPA903Ger
//TODO Descrição auto-gerada.
@author flavio.martins
@since 06/04/2021
@version 1.0
@return ${return}, ${return_description}
@type function
/*/
Function GTPA903Ger()

    If !(IsBlind())
        Pergunte("GTPA903A",.F.)
        If !Empty(MV_PAR01)
            SA1->(DbSetOrder(1))
            SA1->(DbSeek( xFilial('SA1')+MV_PAR01 ))
        EndIf 
        If Pergunte("GTPA903A",.T.)
            FwMsgRun(, {|| GTP903Proc() }, , STR0034) //'Gerando apuração, aguarde...'
        Endif
    Else
        GTP903Proc()
    Endif

Return

//------------------------------------------------------------------------------------------
/*/{Protheus.doc} GTP903Proc()
Gera Apuração
@sample	GTP903Proc()
@author	GTP
@since		01/12/2020
@version	P12
/*/
//------------------------------------------------------------------------------------------
Static Function GTP903Proc()

    Local lRet      as logical
    Local cAliasAUX as character
    Local cAliasGYN as character
    Local oModel    as object
    Local aAreaGYN  as array
    Local cApuracao as character
    Local cOrcContr as character
    Local cAuxG9W   as character
    Local cAuxG54   as character
    Local cSelect   as character
    Local cWhere    as character
    Local cWhereGy0 as character
    Local cInner    as character
    Local cExtCmp   as character
    Local cCmpGYD   as character
    Local cXMLPlan := ''
    Local cXMLExt  := ''
    Local aSomaKM  := {}
    Local cContrato:= ''
    Local cDBUse    := AllTrim( TCGetDB() )

    Private lPackage9535 := G54->(FieldPos('G54_KMPROV')) > 0 .And. G54->(FieldPos('G54_KMREAL')) > 0 .And. G54->(FieldPos('G54_KMPREX')) > 0 .And. G54->(FieldPos('G54_KMREEX')) > 0
    Private lPackage10459:= G54->(FieldPos('G54_VLFAT1')) > 0 .And. G54->(FieldPos('G54_VLFAT2')) > 0 .And. GYD->(FieldPos('GYD_VLFAT1')) > 0 .And. GYD->(FieldPos('GYD_VLFAT2')) > 0 
    
    lRet      := .T.
    cAliasAUX := ''
    cAliasGYN := ''
    oModel    := Nil
    aAreaGYN  := GYN->(GetArea())
    cApuracao := ''
    cOrcContr := ''
    cAuxG9W   := ''
    cAuxG54   := ''
    cSelect   := '%%'
    cWhere    := '%%'
    cWhereGy0 := '%%'
    cInner    := '%%'
    cExtCmp   := '%%'
    cCmpGYD   := '%%'

    ChkCntrCanc()

    cAliasAUX := GetNextAlias()

    IF (LEN(ALLTRIM(MV_PAR03)) > 0 .OR. LEN(ALLTRIM(MV_PAR04)) > 0)
        cOrcContr := "%GY0_NUMERO BETWEEN '" + MV_PAR03 + "' AND '" + MV_PAR04 + "'%"
    else
        cOrcContr := "%GY0_NUMERO > '0'%"
    EndIf

    If !(EMPTY(MV_PAR05)) .OR. !(EMPTY(MV_PAR06))
        cWhere := "% AND GYN_DTFIM BETWEEN '" + DtoS(MV_PAR05) + "'  AND '" + DtoS(MV_PAR06) + "' %"
    EndIf

    If GY0->(FieldPos("GY0_REVISA")) > 0
        cSelect := '%GY0_REVISA,%'
        cInner  := '% AND GYD_REVISA = GY0_REVISA %'
    EndIf

    If GY0->(FieldPos("GY0_ATIVO")) > 0
        cWhereGy0 := "% AND GY0_ATIVO = '1' %"
    EndIf

    If GYD->(FieldPos("GYD_IDPLEX")) > 0 .AND. GYD->(FieldPos("GYD_PLEXTR")) > 0 .AND. GYD->(FieldPos("GYD_IDPLCO")) > 0 .AND. GYD->(FieldPos("GYD_PLCONV")) > 0

        cCmpGYD := "% GYD_IDPLEX, "
        cCmpGYD += "GYD_PLEXTR, "
        cCmpGYD += "GYD_IDPLCO, "
        cCmpGYD += "GYD_PLCONV, "

    Else

        cCmpGYD := "% ' ' GYD_IDPLEX, "
        cCmpGYD += "' ' GYD_PLEXTR, "
        cCmpGYD += "' ' GYD_IDPLCO, "
        cCmpGYD += "' ' GYD_PLCONV, "

    EndIf

    If lPackage10459

        cCmpGYD += "GYD_VLFAT1, "
        cCmpGYD += "GYD_VLFAT2, "

    Else
        cCmpGYD += "0 GYD_VLFAT1, "
        cCmpGYD += "0 GYD_VLFAT2, "
    EndIf    

	Do Case
		Case cDBUse == 'ORACLE'
			cCmpGYD += "COALESCE(GYD_FILIAL || GYD_NUMERO || GYD_CODGYD, ' ') AS LOCPLAN, "
		OtherWise
			cCmpGYD += "GYD_FILIAL+GYD_NUMERO+GYD_CODGYD AS LOCPLAN, "
	End Case

    If ( GYD->(FieldPos("GYD_CLIENT")) > 0 .And. GYD->(FieldPos("GYD_LOJACL")) > 0 )

        cCmpGYD += "GYD_CLIENT, "
        cCmpGYD += "GYD_LOJACL, %"

    Else
        cCmpGYD += "' ' GYD_CLIENT, "
        cCmpGYD += "' ' GYD_LOJACL, %"
    EndIf
    
    If GYN->(FieldPos("GYN_EXTCMP")) > 0

    	cExtCmp := "% AND GYN_EXTCMP = " + "'T'"  + "%"

        BeginSql alias cAliasAUX

            SELECT      
                GY0_NUMERO,	                //--[01]
                %Exp:cSelect%               //--[02] 
                GY0_CODCN9,	                //--[03]
                GY0_CLIENT,	                //--[04]
                GY0_LOJACL,	                //--[05]
                GY0_TPCTO,	                //--[06]
                GY0_TIPPLA,	                //--[07]
                GY0_TABPRC,	                //--[08]
                (
                    CASE WHEN 
                        COALESCE(GYD_PRODUT,' ') = ' '
                    THEN
                        H6Q.H6Q_PRODUT
                    ELSE
                        GYD_PRODUT    
                    END
                ) GYD_PRODUT,	             //--[09]
                (
                    CASE WHEN 
                        COALESCE(GYD_PRONOT,' ') = ' '
                    THEN
                        H6Q.H6Q_PRODUT
                    ELSE
                        GYD_PRONOT    
                    END
                ) GYD_PRONOT,	            //--[10]
                GYD_CODGI2,	                //--[11]
                GYD_CODGYD,	                //--[12]
                GYD_VLRTOT,	                //--[13]
                GYD_VLREXT,	                //--[14]
                GYD_PRECON,	                //--[15]
                GYD_PREEXT,	                //--[16]
                GYD_VLRACO,	                //--[17]
                %Exp:cCmpGYD%	            //--[18] [19] [20] [21] [22] [23] 
                SB1.B1_DESC,                //--[24]
                SB1NT.B1_DESC PRODNT,	    //--[25]
                GYN_FILIAL,	                //--[26]
                GYN_CODIGO,	                //--[27]
                GYN_TIPO,	                //--[28]
                GYN_LINCOD,	                //--[29]
                GYN_DTINI,	                //--[30]
                GYN_HRINI,	                //--[31]
                GYN_DTFIM,	                //--[32]
                GYN_HRFIM,	                //--[33]
                GYN_LOCORI,	                //--[34]
                GYN_LOCDES,	                //--[35]
                GYN_APUCON,	                //--[36]
                GI1ORI.GI1_DESCRI DSCORI,	//--[37]
                GI1DES.GI1_DESCRI DSCDES,	//--[38]
                GYN.R_E_C_N_O_	            //--[39]
            FROM 
                %Table:GY0% GY0
            INNER JOIN 
                %Table:GYD% GYD 
            ON 
                GYD_FILIAL = GY0_FILIAL 
                AND GYD_NUMERO = GY0_NUMERO 
                %Exp:cInner%
                AND GYD.%NotDel%
            INNER JOIN 
                %Table:GI2% GI2 
            ON 
                GI2_FILIAL = GYD_FILIAL 
                AND GI2_COD = GYD_CODGI2 
                AND GI2.%NotDel%
            INNER JOIN 
                %Table:GYN% GYN 
            ON 
                GYN_FILIAL = GI2_FILIAL 
                AND GYN_LINCOD = GI2_COD 
                AND GYN.%NotDel%
            INNER JOIN 
                %Table:GI1% GI1ORI 
            ON 
                GI1ORI.GI1_FILIAL = %xFilial:GI1%
                AND GI1ORI.GI1_COD = GYN.GYN_LOCORI
                AND GI1ORI.%NotDel%
            INNER JOIN 
                %Table:GI1% GI1DES 
            ON 
                GI1DES.GI1_FILIAL = %xFilial:GI1%
                AND GI1DES.GI1_COD = GYN.GYN_LOCDES
                AND GI1DES.%NotDel%
            LEFT JOIN 
                %Table:SB1% SB1 
            ON 
                SB1.B1_FILIAL = %xFilial:SB1%
                AND SB1.B1_COD = GYD.GYD_PRODUT
                AND SB1.%NotDel%
            LEFT JOIN 
                %Table:SB1% SB1NT 
            ON 
                SB1NT.B1_FILIAL = %xFilial:SB1%
                AND SB1NT.B1_COD = GYD.GYD_PRONOT
                AND SB1NT.%NotDel%
            LEFT JOIN
                %Table:H6A% H6A
            ON
                H6A.H6A_FILIAL = %xFilial:H6A%
                AND H6A.H6A_CLIENT = GYD.GYD_CLIENT
                AND H6A.H6A_LOJA = GYD.GYD_LOJACL
                AND H6A.H6A_STATUS = '1'
                AND H6A.%NotDel%
            LEFT JOIN 
                %Table:H6Q% H6Q 
            ON
                H6Q.H6Q_FILIAL = H6A.H6A_FILIAL
                AND H6Q.H6Q_CODH6A = H6A_CODIGO
                AND H6Q.%NotDel%
            WHERE 
                GY0.%NotDel% 
                AND GY0_FILIAL  = %xFilial:GY0%
                AND GY0_CLIENT = %Exp:MV_PAR01%
                AND GY0_LOJACL = %Exp:MV_PAR02%
                AND %Exp:cOrcContr% 
                AND GYN_FINAL = '1' 
                %Exp:cWhere%
                AND GYN_APUCON = ' '	 
                %Exp:cWhereGy0%
                AND GYN_TIPO = '3' 

            UNION 

            SELECT                      
                GY0_NUMERO,                 //--[01]
                %Exp:cSelect%	            //--[02]
                GY0_CODCN9,                 //--[03] 
                GY0_CLIENT,                 //--[04] 
                GY0_LOJACL,                 //--[05] 
                GY0_TPCTO,                  //--[06] 
                GY0_TIPPLA,                 //--[07] 
                GY0_TABPRC,                 //--[08] 
                GY0_PRDEXT	GYD_PRODUT,     //--[09]                         
                GY0_PRONOT	GYD_PRONOT,     //--[10]                         
                ' '			GYD_CODGI2,     //--[11]                         
                GYD_CODGYD,                 //--[12]
                0			GYD_VLRTOT,     //--[13]                        
                GY0_VLRACO	GYD_VLREXT,     //--[14]                        
                ' '			GYD_PRECON,     //--[15]                        
                GY0_PREEXT	GYD_PREEXT,     //--[16]                        
                GYD_VLREXT  GYD_VLRACO,     //--[17]
                ' '         GYD_IDPLEX,     //--[18] 
                ' '	        GYD_PLEXTR,     //--[19]
                GY0_IDPLCO	GYD_IDPLCO,     //--[20]
                GY0_PLCONV	GYD_PLCONV,     //--[21]
                0         GYD_VLFAT1,
                0         GYD_VLFAT2,
                ' '	        LOCPLAN,                
                ' '         GYD_CLIENT,     //--[22]
                ' '         GYD_LOJACL,     //--[23]
                SB1.B1_DESC,                //--[24]
                SB1NT.B1_DESC PRODNT,       //--[25]                           
                GYN_FILIAL,                 //--[26]
                GYN_CODIGO,                 //--[27]
                GYN_TIPO,                   //--[28]
                GYN_LINCOD,                 //--[29]     
                GYN_DTINI,                  //--[30]     
                GYN_HRINI,                  //--[31]     
                GYN_DTFIM,                  //--[32]     
                GYN_HRFIM,                  //--[33]     
                GYN_LOCORI,                 //--[34]     
                GYN_LOCDES,                 //--[35] 
                GYN_APUCON,                 //--[36]
                GI1ORI.GI1_DESCRI DSCORI,   //--[37]
                GI1DES.GI1_DESCRI DSCDES,   //--[38]
                GYN.R_E_C_N_O_              //--[39]
            FROM 
                %Table:GY0% GY0
            INNER JOIN 
                %Table:GYD% GYD 
            ON 
                GYD_FILIAL = GY0_FILIAL 
                AND GYD_NUMERO = GY0_NUMERO 
                %Exp:cInner%
                AND GYD.%NotDel%
            INNER JOIN 
                %Table:GYN% GYN 
            ON 
                GYN_FILIAL = %xFilial:GYN%
                AND GYN_CODGY0 = GY0_NUMERO 
                AND GYN.%NotDel%
            INNER JOIN 
                %Table:GI1% GI1ORI 
            ON 
                GI1ORI.GI1_FILIAL = %xFilial:GI1%
                AND GI1ORI.GI1_COD = GYN.GYN_LOCORI
                AND GI1ORI.%NotDel%
            INNER JOIN 
                %Table:GI1% GI1DES 
            ON 
                GI1DES.GI1_FILIAL = %xFilial:GI1%
                AND GI1DES.GI1_COD = GYN.GYN_LOCDES
                AND GI1DES.%NotDel%
            INNER JOIN 
                %Table:SB1% SB1 
            ON 
                SB1.B1_FILIAL = %xFilial:SB1%
                AND SB1.B1_COD = GY0.GY0_PRODUT
                AND SB1.%NotDel%
            INNER JOIN 
                %Table:SB1% SB1NT 
            ON 
                SB1NT.B1_FILIAL = %xFilial:SB1%
                AND SB1NT.B1_COD = GY0.GY0_PRONOT
                AND SB1NT.%NotDel%
            WHERE
                GY0.%NotDel% 
                AND GY0_FILIAL  = %xFilial:GY0% 
                AND GY0_CLIENT = %Exp:MV_PAR01% 
                AND GY0_LOJACL = %Exp:MV_PAR02% 
                AND %Exp:cOrcContr%  
                AND GYN_FINAL = '1'  
                %Exp:cWhere%
                AND GYN_APUCON = ' '	 
                %Exp:cWhereGy0%
                AND GYN_TIPO = '2' 
                %Exp:cExtCmp%
            ORDER BY 
                GY0_NUMERO, 
                GYN_LINCOD

       EndSql

    Else
        BeginSql alias cAliasAUX

            SELECT  
                GY0_NUMERO,
                %Exp:cSelect%
                GY0_CODCN9,
                GY0_CLIENT,
                GY0_LOJACL,
                GY0_TPCTO,
                GY0_TIPPLA,
                GY0_TABPRC,
                GYD_PRODUT,
                GYD_PRONOT,
                GYD_CODGI2,
                GYD_CODGYD,
                GYD_VLRTOT,
                GYD_VLREXT,
                GYD_PRECON,
                GYD_PREEXT,
                GYD_VLRACO,
                %Exp:cCmpGYD%
                SB1.B1_DESC,
                SB1NT.B1_DESC PRODNT,
                GYN_FILIAL,
                GYN_CODIGO,
                GYN_TIPO,
                GYN_LINCOD,
                GYN_DTINI,
                GYN_HRINI,
                GYN_DTFIM,
                GYN_HRFIM,
                GYN_LOCORI,
                GYN_LOCDES,
                GYN_APUCON,
                GI1ORI.GI1_DESCRI DSCORI,
                GI1DES.GI1_DESCRI DSCDES,
                GYN.R_E_C_N_O_
            FROM 
                %Table:GY0% GY0
            INNER JOIN 
                %Table:GYD% GYD 
            ON 
                GYD_FILIAL=GY0_FILIAL 
                AND GYD_NUMERO = GY0_NUMERO 
                %Exp:cInner%
                AND GYD.%NotDel%
            INNER JOIN
                %Table:GI2% GI2
            ON
                GI2_FILIAL=GYD_FILIAL 
                AND GI2_COD=GYD_CODGI2 
                AND GI2.%NotDel%
            INNER JOIN
                %Table:GYN% GYN
            ON
                GYN_FILIAL=GI2_FILIAL 
                AND GYN_LINCOD=GI2_COD 
                AND GYN.%NotDel%
            INNER JOIN
                %Table:GI1% GI1ORI
            ON
                GI1ORI.GI1_FILIAL = %xFilial:GI1%
                AND GI1ORI.GI1_COD = GYN.GYN_LOCORI
                AND GI1ORI.%NotDel%
            INNER JOIN
                %Table:GI1% GI1DES
            ON
                GI1DES.GI1_FILIAL = %xFilial:GI1%
                AND GI1DES.GI1_COD = GYN.GYN_LOCDES
                AND GI1DES.%NotDel%
            INNER JOIN
                %Table:SB1% SB1
            ON
                SB1.B1_FILIAL = %xFilial:SB1%
                AND SB1.B1_COD = GYD.GYD_PRODUT
                AND SB1.%NotDel%
            INNER JOIN
                %Table:SB1% SB1NT
            ON
                SB1NT.B1_FILIAL = %xFilial:SB1%
                AND SB1NT.B1_COD = GYD.GYD_PRONOT
                AND SB1NT.%NotDel%
            WHERE
                GY0.%NotDel% 
                AND GY0_FILIAL=%xFilial:GY0% 
                AND GY0_CLIENT = %Exp:MV_PAR01% 
                AND GY0_LOJACL = %Exp:MV_PAR02% 
                AND %Exp:cOrcContr% 
                AND GYN_FINAL = '1' 
                %Exp:cWhere%
                AND GYN_APUCON =' '	
                %Exp:cWhereGy0%
                AND GYN_TIPO = '3' 
            ORDER BY 
                GY0_NUMERO, 
                GYN_LINCOD

        EndSql	
    EndIf

    If !(cAliasAUX)->(Eof())

        oModel:= FwLoadModel("GTPA903")
        oModel:SetOperation(MODEL_OPERATION_INSERT)

        oModel:GetModel('G9WDETAIL'):SetNoInsertLine(.F.)
        oModel:GetModel('G9WDETAIL'):SetNoDeleteLine(.F.)
        oModel:GetModel('G54DETAIL'):SetNoInsertLine(.F.)
        oModel:GetModel('G54DETAIL'):SetNoDeleteLine(.F.)
        oModel:GetModel('GYNDETAIL'):SetNoInsertLine(.F.)
        oModel:GetModel('GYNDETAIL'):SetNoUpdateLine(.F.)
        oModel:GetModel('GYNDETAIL'):SetNoDeleteLine(.F.)

        If oModel:Activate()

            oModel:GetModel('GQRMASTER'):LoadValue('GQR_CLIENT',	(cAliasAUX)->GY0_CLIENT)
            oModel:GetModel('GQRMASTER'):LoadValue('GQR_LOJA',      AllTrim((cAliasAUX)->GY0_LOJACL))
            oModel:GetModel('GQRMASTER'):LoadValue('GQR_DTINIA',	MV_PAR05)
            oModel:GetModel('GQRMASTER'):LoadValue('GQR_DTFINA',	MV_PAR06)

            cApuracao := oModel:GetModel('GQRMASTER'):GetValue('GQR_CODIGO')

            oModel:GetModel('GQRMASTER'):LoadValue('GQR_USUAPU', __cUserId)

        Else
            Return .F.
        Endif

        While (cAliasAUX)->(!Eof())

            cContrato := (cAliasAUX)->GY0_NUMERO

            If cAuxG9W != (cAliasAUX)->GY0_NUMERO
                If !oModel:GetModel('G9WDETAIL'):SeekLine({{'G9W_NUMGY0',(cAliasAUX)->GY0_NUMERO}},,.T.)
                    cAuxG9W := (cAliasAUX)->GY0_NUMERO

                    If !(oModel:GetModel('G9WDETAIL'):IsEmpty())
                        oModel:GetModel('G9WDETAIL'):AddLine()
                    Endif

                    oModel:GetModel('G9WDETAIL'):LoadValue('G9W_MARK', .T.)
                    oModel:GetModel('G9WDETAIL'):LoadValue('G9W_CODGQR', cApuracao)
                    oModel:GetModel('G9WDETAIL'):LoadValue('G9W_CONTRA', (cAliasAUX)->GY0_CODCN9)
                    oModel:GetModel('G9WDETAIL'):LoadValue('G9W_NUMGY0', (cAliasAUX)->GY0_NUMERO)
                    oModel:GetModel('G9WDETAIL'):LoadValue('G9W_REVISA', (cAliasAUX)->GY0_REVISA)
                    oModel:GetModel('G9WDETAIL'):LoadValue('G9W_DTINIA', MV_PAR05)
                    oModel:GetModel('G9WDETAIL'):LoadValue('G9W_TPCTO' , (cAliasAUX)->GY0_TPCTO) 
                    oModel:GetModel('G9WDETAIL'):LoadValue('G9W_TIPPLA', (cAliasAUX)->GY0_TIPPLA)
                    oModel:GetModel('G9WDETAIL'):LoadValue('G9W_TABPRC', (cAliasAUX)->GY0_TABPRC)
                    oModel:GetModel('G9WDETAIL'):LoadValue('G9W_TOTAPU', 0)

                Endif
            Endif  

            If cAuxG54 != (cAliasAUX)->GYN_LINCOD

                cAuxG54 := (cAliasAUX)->GYN_LINCOD

                If !(oModel:GetModel('G54DETAIL'):IsEmpty())
                    oModel:GetModel('G54DETAIL'):AddLine()
                Endif

                oModel:GetModel('G54DETAIL'):LoadValue('G54_MARK', .T.)
                oModel:GetModel('G54DETAIL'):LoadValue('G54_NUMGY0', (cAliasAUX)->GY0_NUMERO)
                oModel:GetModel('G54DETAIL'):LoadValue('G54_REVISA', (cAliasAUX)->GY0_REVISA)
                oModel:GetModel('G54DETAIL'):LoadValue('G54_CODGQR', cApuracao)
                oModel:GetModel('G54DETAIL'):LoadValue('G54_PRODUT', (cAliasAUX)->GYD_PRODUT)
                oModel:GetModel('G54DETAIL'):LoadValue('G54_PRODNT', (cAliasAUX)->GYD_PRONOT)
                oModel:GetModel('G54DETAIL'):LoadValue('G54_DPRONT', Posicione("SB1",1,XFilial("SB1")+(cAliasAux)->GYD_PRODUT,"B1_DESC"))   // oModel:GetModel('G54DETAIL'):LoadValue('G54_DPRONT', (cAliasAUX)->PRODNT)
                oModel:GetModel('G54DETAIL'):LoadValue('G54_DPROD' , Posicione("SB1",1,XFilial("SB1")+(cAliasAux)->GYD_PRONOT,"B1_DESC"))   // oModel:GetModel('G54DETAIL'):LoadValue('G54_DPROD' , (cAliasAUX)->B1_DESC)
                oModel:GetModel('G54DETAIL'):LoadValue('G54_CODGYD', (cAliasAUX)->GYD_CODGYD)
                oModel:GetModel('G54DETAIL'):LoadValue('G54_CODGI2', (cAliasAUX)->GYD_CODGI2)
                oModel:GetModel('G54DETAIL'):LoadValue('G54_PRECON', (cAliasAUX)->GYD_PRECON)
                oModel:GetModel('G54DETAIL'):LoadValue('G54_PREEXT', (cAliasAUX)->GYD_PREEXT)
                oModel:GetModel('G54DETAIL'):LoadValue('G54_VLRACO', (cAliasAUX)->GYD_VLRACO)

                If lPackage10459
                    oModel:GetModel('G54DETAIL'):LoadValue('G54_VLFAT1', (cAliasAUX)->GYD_VLFAT1)
                    oModel:GetModel('G54DETAIL'):LoadValue('G54_VLFAT2', (cAliasAUX)->GYD_VLFAT2)
                EndIf 

                If lPackage9535
                    aSomaKM := GetKMProvReal(cContrato,DtoS(MV_PAR05),DtoS(MV_PAR06),cAuxG54)
                    oModel:GetModel('G54DETAIL'):LoadValue('G54_KMPROV', aSomaKM[1])
                    oModel:GetModel('G54DETAIL'):LoadValue('G54_KMREAL', aSomaKM[2])
                    oModel:GetModel('G54DETAIL'):LoadValue('G54_KMPREX', aSomaKM[3])
                    oModel:GetModel('G54DETAIL'):LoadValue('G54_KMREEX', aSomaKM[4])
                EndIf 

                If GYD->(FieldPos("GYD_PLCONV")) > 0 .AND. GYD->(FieldPos("GYD_IDPLCO")) > 0
                    oModel:GetModel('G54DETAIL'):LoadValue('G54_PLCONV', Alltrim((cAliasAUX)->GYD_PLCONV)) 
                    oModel:GetModel('G54DETAIL'):LoadValue('G54_IDPLCO', (cAliasAUX)->GYD_IDPLCO)
                EndIf

                If GYD->(FieldPos("GYD_PLEXTR")) > 0
                    oModel:GetModel('G54DETAIL'):LoadValue('G54_PLEXTR', (cAliasAUX)->GYD_PLEXTR)   

                    If GYD->(FieldPos("GYD_IDPLEX")) > 0
                        oModel:GetModel('G54DETAIL'):LoadValue('G54_IDPLEX', (cAliasAUX)->GYD_IDPLEX)
                    EndIf

                    If ( (cAliasAUX)->GYD_PLEXTR != '1' )
                        oModel:GetModel('G54DETAIL'):LoadValue('G54_VLREXT', (cAliasAUX)->GYD_VLREXT)
                    Else   
                        oModel:GetModel('G54DETAIL'):LoadValue('G54_VLREXT', GA903Calc((cAliasAUX)->GYD_IDPLEX,,(cAliasAUX)->LOCPLAN,@cXMLExt,oModel,.T.))
                        If G54->(FieldPos("G54_XMLPEX")) > 0
                            oModel:GetModel('G54DETAIL'):LoadValue('G54_XMLPEX', cXMLExt)
                        EndIF                         
                    EndIf
                Else
                    oModel:GetModel('G54DETAIL'):LoadValue('G54_VLREXT', (cAliasAUX)->GYD_VLREXT)
                EndIf 

                If GYD->(FieldPos("GYD_PLCONV")) > 0
                    If ( (cAliasAUX)->GYD_PLCONV != '1' )
                        oModel:GetModel('G54DETAIL'):LoadValue('G54_VLRCON', (cAliasAUX)->GYD_VLRTOT)
                    Else
                        oModel:GetModel('G54DETAIL'):LoadValue('G54_VLRCON', GA903Calc((cAliasAUX)->GYD_IDPLCO,,(cAliasAUX)->LOCPLAN,@cXMLPlan,oModel))
                        oModel:GetModel('G54DETAIL'):LoadValue('G54_XMLPLA', cXMLPlan )
                    EndIf
                Else
                    oModel:GetModel('G54DETAIL'):LoadValue('G54_VLRCON', (cAliasAUX)->GYD_VLRTOT)
                EndIf

                If ( oModel:GetModel('G54DETAIL'):HasField("G54_CLIENT") .And.;
                     oModel:GetModel('G54DETAIL'):HasField("G54_LOJACL"))

                    oModel:GetModel('G54DETAIL'):SetValue('G54_CLIENT', Iif( Empty( (cAliasAUX)->GYD_CLIENT ),(cAliasAUX)->GY0_CLIENT,(cAliasAUX)->GYD_CLIENT))
                    oModel:GetModel('G54DETAIL'):SetValue('G54_LOJACL', Iif( Empty( (cAliasAUX)->GYD_LOJACL ),(cAliasAUX)->GY0_LOJACL,(cAliasAUX)->GYD_LOJACL))
                    oModel:GetModel('G54DETAIL'):LoadValue('G54_NOMECL', Posicione('SA1',1,xFilial('SA1') + (cAliasAUX)->GYD_CLIENT + (cAliasAUX)->GYD_LOJACL,'A1_NOME'))

                EndIf

                TotaisVia(oModel)
                TotalLinha(oModel)

                oModel:GetModel('G9WDETAIL'):LoadValue('G9W_TOTCAL',;
                oModel:GetModel('G9WDETAIL'):GetValue('G9W_TOTAPU'))

            Endif

            If !(oModel:GetModel('GYNDETAIL'):IsEmpty())
                oModel:GetModel('GYNDETAIL'):AddLine()
            Endif

            oModel:GetModel('GYNDETAIL'):LoadValue('GYN_CODIGO', (cAliasAUX)->GYN_CODIGO)
            oModel:GetModel('GYNDETAIL'):LoadValue('GYN_TIPO', (cAliasAUX)->GYN_TIPO)
            oModel:GetModel('GYNDETAIL'):LoadValue('GYN_LINCOD', (cAliasAUX)->GYN_LINCOD)
            oModel:GetModel('GYNDETAIL'):LoadValue('GYN_DTINI', StoD((cAliasAUX)->GYN_DTINI))
            oModel:GetModel('GYNDETAIL'):LoadValue('GYN_HRINI', (cAliasAUX)->GYN_HRINI)
            oModel:GetModel('GYNDETAIL'):LoadValue('GYN_DTFIM', StoD((cAliasAUX)->GYN_DTFIM))
            oModel:GetModel('GYNDETAIL'):LoadValue('GYN_HRFIM', (cAliasAUX)->GYN_HRFIM)
            oModel:GetModel('GYNDETAIL'):LoadValue('GYN_LOCORI', (cAliasAUX)->GYN_LOCORI)
            oModel:GetModel('GYNDETAIL'):LoadValue('GYN_DSCORI', (cAliasAUX)->DSCORI)
            oModel:GetModel('GYNDETAIL'):LoadValue('GYN_LOCDES', (cAliasAUX)->GYN_LOCDES)
            oModel:GetModel('GYNDETAIL'):LoadValue('GYN_DSCDES', (cAliasAUX)->DSCDES)
            oModel:GetModel('GYNDETAIL'):LoadValue('GYN_APUCON', cApuracao)

            (cAliasAUX)->(DbSkip())   
        End

        SomaContrato(oModel)

        oModel:GetModel('G9WDETAIL'):SetNoInsertLine(.T.)
        oModel:GetModel('G9WDETAIL'):SetNoDeleteLine(.T.)
        oModel:GetModel('G54DETAIL'):SetNoInsertLine(.T.)
        oModel:GetModel('G54DETAIL'):SetNoDeleteLine(.T.)
        oModel:GetModel('GYNDETAIL'):SetNoInsertLine(.T.)
        oModel:GetModel('GYNDETAIL'):SetNoUpdateLine(.T.)
        oModel:GetModel('GYNDETAIL'):SetNoDeleteLine(.T.)

        oG903Model := oModel

        FwExecView(STR0019, "VIEWDEF.GTPA903", 3, , {|| .T. } , /*bOk*/ , /*nPercReducao*/, /*aEnableButtons*/, /*bCancel*/, /*cOperatId*/ , /*cToolBar*/ , oG903Model)	//  "Apuração" 

    Else
        cAliasGYN := GetNextAlias()

        BeginSQL alias cAliasGYN

            SELECT  GYN.R_E_C_N_O_
            FROM %Table:GY0% GY0
            INNER JOIN %Table:GYD% GYD ON GYD_FILIAL=GY0_FILIAL 
                AND GYD_NUMERO = GY0_NUMERO 
                %Exp:cInner%
                AND GYD.%NotDel%
            INNER JOIN %Table:GI2% GI2 ON GI2_FILIAL=GYD_FILIAL 
                AND GI2_COD=GYD_CODGI2 
                AND GI2.%NotDel%
            INNER JOIN %Table:GYN% GYN ON GYN_FILIAL=GI2_FILIAL 
                AND GYN_LINCOD = GI2_COD
                %Exp:cWhere%
                AND GYN_APUCON =' '	
                AND GYN_TIPO = '3' 
                AND GYN_FINAL != '1' 
                AND GYN.%NotDel%
            INNER JOIN %Table:GI1% GI1ORI ON GI1ORI.GI1_FILIAL = %xFilial:GI1%
                AND GI1ORI.GI1_COD = GYN.GYN_LOCORI
                AND GI1ORI.%NotDel%
            INNER JOIN %Table:GI1% GI1DES ON GI1DES.GI1_FILIAL = %xFilial:GI1%
                AND GI1DES.GI1_COD = GYN.GYN_LOCDES
                AND GI1DES.%NotDel%
            INNER JOIN %Table:SB1% SB1 ON SB1.B1_FILIAL = %xFilial:SB1%
                AND SB1.B1_COD = GYD.GYD_PRODUT
                AND SB1.%NotDel%
            WHERE
                GY0_FILIAL=%xFilial:GY0% 
                AND GY0_CLIENT = %Exp:MV_PAR01% 
                AND GY0_LOJACL = %Exp:MV_PAR02% 
                AND %Exp:cOrcContr%  
                AND GY0.%NotDel%                 
                %Exp:cWhereGy0%
        EndSql

        If (cAliasGYN)->(!Eof())
            Help(,,"GTPA903Ger",, STR0035, 1,0) //"Existem viagens não finalizadas, finalize elas antes de efetuar a apuração!", 1,0
        Else
            Help(,,"GTPA903Ger",, STR0018, 1,0)	//'Nenhum registro foi encontrado para apuração.'
        EndIf

        (cAliasGYN)->(DbCloseArea())
    EndIf

    (cAliasAUX)->(DbCloseArea())
    RestArea(aAreaGYN)

Return lRet

/*/{Protheus.doc} SetStruct
//TODO Descrição auto-gerada.
@author GTP
@since 01/12/2020
@version 1.0
@return ${return}, ${return_description}
@type function
/*/
Static Function SetStruct(cTipo,oStruGQR, oStruG9W, oStruG54, oStruGYN)

    Local cFldsGYN  := '' 
    Local cOrdem    := ""

    Local nX        := 0
    
    Local aFldsGYN	:= aClone(oStruGYN:GetFields())
    
    Local bFldTrig  := {|oMdl,cField,uVal| FieldTrigger(oMdl,cField,uVal)}
    Local bInit		:= {|oMdl,cField| FieldInit(oMdl,cField)}

    If cTipo == 'M'

        oStruG9W:AddField(  "",;                        // 	[01]  C   Titulo do campo 
                            "",;                        // 	[02]  C   ToolTip do campo
                            "G9W_MARK",;                // 	[03]  C   Id do Field
                            "L",;                       // 	[04]  C   Tipo do campo
                            1,;                         // 	[05]  N   Tamanho do campo
                            0,;                         // 	[06]  N   Decimal do campo
                            {|| .T.},;                  // 	[07]  B   Code-block de validação do campo
                            {|| .T.},;                  // 	[08]  B   Code-block de validação When do campo
                            {},;                        //	[09]  A   Lista de valores permitido do campo
                            .F.,;                       //	[10]  L   Indica se o campo tem preenchimento obrigatório
                            { ||.T.},;                  //	[11]  B   Code-block de inicializacao do campo
                            .F.,;                       //	[12]  L   Indica se trata-se de um campo chave
                            .F.,;                       //	[13]  L   Indica se o campo pode receber valor em uma operação de update.
                            .T.);                       // 	[14]  L   Indica se o campo é virtual
        
        oStruG54:AddField(   "",;                        // 	[01]  C   Titulo do campo 
                            "",;                        // 	[02]  C   ToolTip do campo
                            "G54_MARK",;                // 	[03]  C   Id do Field
                            "L",;                       // 	[04]  C   Tipo do campo
                            1,;                         // 	[05]  N   Tamanho do campo
                            0,;                         // 	[06]  N   Decimal do campo
                            {|| .T.},;                  // 	[08]  B   Code-block de validação When do campo
                            {|| .T.},;                  // 	[07]  B   Code-block de validação do campo
                            {},;                        //	[09]  A   Lista de valores permitido do campo
                            .F.,;                       //	[10]  L   Indica se o campo tem preenchimento obrigatório
                            { ||.T.},;                  //	[11]  B   Code-block de inicializacao do campo
                            .F.,;                       //	[12]  L   Indica se trata-se de um campo chave
                            .F.,;                       //	[13]  L   Indica se o campo pode receber valor em uma operação de update.
                            .T.)                        // 	[14]  L   Indica se o campo é virtual

        
        oStruG54:AddField(	"Nome Cliente",;	        // 	[01]  C   Titulo do campo 
                            "Nome Cliente",;	        // 	[02]  C   ToolTip do campo
                            "G54_NOMECL",;	            // 	[03]  C   Id do Field
                            "C",;		                // 	[04]  C   Tipo do campo
                            TamSx3("A1_NOME")[1],;	    // 	[05]  N   Tamanho do campo
                            0,;			                // 	[06]  N   Decimal do campo
                            Nil,;		                // 	[07]  B   Code-block de validação do campo
                            Nil,;		                // 	[08]  B   Code-block de validação When do campo
                            Nil,;		                //	[09]  A   Lista de valores permitido do campo
                            .F.,;		                //	[10]  L   Indica se o campo tem preenchimento obrigatório
                            binit,;		                //	[11]  B   Code-block de inicializacao do campo
                            .F.,;		                //	[12]  L   Indica se trata-se de um campo chave
                            .F.,;		                //	[13]  L   Indica se o campo pode receber valor em uma operação de update.
                            .T.)		                // 	[14]  L   Indica se o campo é virtual

        If AliasInDic("G9W") .AND. G9W->(FieldPos("G9W_VLACRE")) > 0
            oStruG9W:AddTrigger("G9W_VLACRE", "G9W_VLACRE" , {||.T.}, bFldTrig)    
        EndIf
        If AliasInDic("G9W") .AND. G9W->(FieldPos("G9W_VLDESC")) > 0
            oStruG9W:AddTrigger("G9W_VLDESC", "G9W_VLDESC" , {||.T.}, bFldTrig)  
        EndIf
        
        oStruG9W:AddTrigger("G9W_MARK"  , "G9W_MARK" , {||.T.}, bFldTrig)

        If AliasInDic("G9W") .AND. G9W->(FieldPos("G9W_TPCMPO")) > 0
            oStruG9W:AddTrigger("G9W_TPCMPO"  , "G9W_TPCMPO" , {||.T.}, bFldTrig) 
        EndIf
        If AliasInDic("G9W") .AND. G9W->(FieldPos("G9W_PORCEN")) > 0
            oStruG9W:AddTrigger("G9W_PORCEN"  , "G9W_PORCEN" , {||.T.}, bFldTrig)  
        EndIf
        If AliasInDic("G9W") .AND. G9W->(FieldPos("G9W_VLFIXO")) > 0
            oStruG9W:AddTrigger("G9W_VLFIXO"  , "G9W_VLFIXO" , {||.T.}, bFldTrig)  
        EndIf

        oStruG54:AddTrigger("G54_MARK"  , "G54_MARK" , {||.T.}, bFldTrig)  

        If AliasInDic("G54") .AND. G54->(FieldPos("G54_TPCMPO")) > 0
            oStruG54:AddTrigger("G54_TPCMPO"  , "G54_TPCMPO" , {||.T.}, bFldTrig)  
        EndIf
        If AliasInDic("G54") .AND. G54->(FieldPos("G54_PORCEN")) > 0
            oStruG54:AddTrigger("G54_PORCEN"  , "G54_PORCEN" , {||.T.}, bFldTrig)  
        EndIf
        If AliasInDic("G54") .AND. G54->(FieldPos("G54_VLFIXO")) > 0
            oStruG54:AddTrigger("G54_VLFIXO"  , "G54_VLFIXO" , {||.T.}, bFldTrig)  
        EndIf
        
        If AliasInDic("G54") .AND. G54->(FieldPos("G54_CLIENT")) > 0
            oStruG54:AddTrigger("G54_CLIENT"  , "G54_NOMECL" , {||.T.}, bFldTrig)  
        EndIf
    
        If AliasInDic("G54") .AND. G54->(FieldPos("G54_LOJACL")) > 0
            oStruG54:AddTrigger("G54_LOJACL"  , "G54_NOMECL" , {||.T.}, bFldTrig)  
        EndIf

        oStruG9W:SetProperty("*", MODEL_FIELD_WHEN, { || .F. })
        oStruG9W:SetProperty("G9W_MARK", MODEL_FIELD_WHEN, { || .T. })

        If AliasInDic("G9W") .AND. G9W->(FieldPos("G9W_VLACRE")) > 0
            oStruG9W:SetProperty("G9W_VLACRE", MODEL_FIELD_WHEN, { || .T. })
        EndIf
        If AliasInDic("G9W") .AND. G9W->(FieldPos("G9W_VLDESC")) > 0
            oStruG9W:SetProperty("G9W_VLDESC", MODEL_FIELD_WHEN, { || .T. })
        EndIf
        If AliasInDic("G9W") .AND. G9W->(FieldPos("G9W_MOTIVO")) > 0
            oStruG9W:SetProperty("G9W_MOTIVO", MODEL_FIELD_WHEN, { || .T. })
        EndIf
        If AliasInDic("G9W") .AND. G9W->(FieldPos("G9W_TIPCNR")) > 0
            oStruG9W:SetProperty("G9W_TIPCNR", MODEL_FIELD_WHEN, { || .T. })
        EndIf
        If AliasInDic("G9W") .AND. G9W->(FieldPos("G9W_TPCMPO")) > 0
            oStruG9W:SetProperty("G9W_TPCMPO", MODEL_FIELD_WHEN, { || .T. })
        EndIf
        If AliasInDic("G9W") .AND. G9W->(FieldPos("G9W_DESCRI")) > 0
            oStruG9W:SetProperty("G9W_DESCRI", MODEL_FIELD_WHEN, { || .T. })
        EndIf
        If AliasInDic("G9W") .AND. G9W->(FieldPos("G9W_PORCEN")) > 0
            oStruG9W:SetProperty("G9W_PORCEN", MODEL_FIELD_WHEN, { || .T. })
        EndIf
        If AliasInDic("G9W") .AND. G9W->(FieldPos("G9W_VLFIXO")) > 0
            oStruG9W:SetProperty("G9W_VLFIXO", MODEL_FIELD_WHEN, { || .F. })
        EndIf
       

        oStruGQR:SetProperty("*", MODEL_FIELD_WHEN, { || .F. })

        oStruG54:SetProperty("*", MODEL_FIELD_WHEN, { || .F. })
        oStruG54:SetProperty("G54_MARK", MODEL_FIELD_WHEN, { || .T. })

        If AliasInDic("G54") .AND. G54->(FieldPos("G54_TIPCNR")) > 0
            oStruG54:SetProperty("G54_TIPCNR", MODEL_FIELD_WHEN, { || .T. })
        EndIf
        If AliasInDic("G54") .AND. G54->(FieldPos("G54_TPCMPO")) > 0
            oStruG54:SetProperty("G54_TPCMPO", MODEL_FIELD_WHEN, { || .T. })
        EndIf
        If AliasInDic("G54") .AND. G54->(FieldPos("G54_DESCRI")) > 0
            oStruG54:SetProperty("G54_DESCRI", MODEL_FIELD_WHEN, { || .T. })
        EndIf
        If AliasInDic("G54") .AND. G54->(FieldPos("G54_PORCEN")) > 0
            oStruG54:SetProperty("G54_PORCEN", MODEL_FIELD_WHEN, { || .T. })
        EndIf
        If AliasInDic("G54") .AND. G54->(FieldPos("G54_VLFIXO")) > 0
            oStruG54:SetProperty("G54_VLFIXO", MODEL_FIELD_WHEN, { || .T. })
        EndIf
        
        If AliasInDic("G54") .AND. G54->(FieldPos("G54_CLIENT")) > 0
            oStruG54:SetProperty("G54_CLIENT", MODEL_FIELD_WHEN, { || .T. })
        EndIf
        
        If AliasInDic("G54") .AND. G54->(FieldPos("G54_LOJACL")) > 0
            oStruG54:SetProperty("G54_LOJACL", MODEL_FIELD_WHEN, { || .T. })
        EndIf

        If AliasInDic("GQR") .AND. GQR->(FieldPos("GQR_CONTRA")) > 0
            oStruGQR:RemoveField("GQR_CONTRA")
        EndIf

        If AliasInDic("GQR") .AND. GQR->(FieldPos("GQR_MOTIVO")) > 0
            oStruGQR:RemoveField("GQR_MOTIVO")
        EndIf

    Else

        oStruG9W:AddField("G9W_MARK","01","","",{""},"GET","@!",NIL,"",.T.,NIL,NIL,{},NIL,NIL,.T.)
        oStruG54:AddField("G54_MARK","01","","",{""},"GET","@!",NIL,"",.T.,NIL,NIL,{},NIL,NIL,.T.)
        
        cOrdem := '07' 
        
        If AliasInDic("G54") .AND. G54->(FieldPos("G54_CLIENT")) > 0 .AND. G54->(FieldPos("G54_LOJACL")) > 0

            oStruG54:AddField("G54_NOMECL","99","Nome Cliente","Nome Cliente",{"Nome Cliente"},"GET","@!",NIL,"",.F.,NIL,NIL,{},NIL,NIL,.T.) 

            OrdenaG54(oStruG54)

        EndIf
    
        If AliasInDic("GQR") .AND. GQR->(FieldPos("GQR_STATUS")) > 0
            oStruGQR:RemoveField("GQR_STATUS")
        EndIf
        If AliasInDic("GQR") .AND. GQR->(FieldPos("GQR_CONTRA")) > 0
            oStruGQR:RemoveField("GQR_CONTRA")
        EndIf
        If AliasInDic("GQR") .AND. GQR->(FieldPos("GQR_MOTIVO")) > 0
            oStruGQR:RemoveField("GQR_MOTIVO")
        EndIf
        
        If AliasInDic("GQR") .AND. GQR->(FieldPos("GQR_USUAPU")) > 0
            oStruGQR:RemoveField("GQR_USUAPU")
        EndIf

        If AliasInDic("G9W") .AND. G9W->(FieldPos("G9W_TIPCNR")) > 0
            oStruG9W:RemoveField("G9W_TIPCNR")
        EndIf
        If AliasInDic("G9W") .AND. G9W->(FieldPos("G9W_TPCMPO")) > 0
            oStruG9W:RemoveField("G9W_TPCMPO")
        EndIf
        If AliasInDic("G9W") .AND. G9W->(FieldPos("G9W_DESCRI")) > 0
            oStruG9W:RemoveField("G9W_DESCRI")
        EndIf
        If AliasInDic("G9W") .AND. G9W->(FieldPos("G9W_PORCEN")) > 0
            oStruG9W:RemoveField("G9W_PORCEN")
        EndIf
        If AliasInDic("G9W") .AND. G9W->(FieldPos("G9W_PORCEN")) > 0
            oStruG9W:RemoveField("G9W_PORCEN")
        EndIf
        If AliasInDic("G54") .AND. G54->(FieldPos("G54_QTDE")) > 0
            oStruG54:RemoveField("G54_QTDE")
        EndIf
        If AliasInDic("G54") .AND. G54->(FieldPos("G54_VLRTOT")) > 0
            oStruG54:RemoveField("G54_VLRTOT")
        EndIf
        If AliasInDic("G54") .AND. G54->(FieldPos("G54_SUBTOT")) > 0
            oStruG54:RemoveField("G54_SUBTOT")
        EndIf

        If AliasInDic("G9W") .AND. G9W->(FieldPos("G9W_CODCND")) > 0
            oStruG9W:RemoveField("G9W_CODCND")
            // oStruG9W:SetProperty("G9W_CODCND",MVC_VIEW_ORDEM,'19')
        EndIf

        If AliasInDic("G54") .AND. G54->(FieldPos("G54_XMLPLA")) > 0
            oStruG54:RemoveField("G54_XMLPLA")
        EndIf

        cFldsGYN := "GYN_CODIGO|"
        cFldsGYN += "GYN_TIPO|"
        cFldsGYN += "GYN_LINCOD|"
        cFldsGYN += "GYN_DTINI|"
        cFldsGYN += "GYN_HRINI|"
        cFldsGYN += "GYN_DTFIM|"
        cFldsGYN += "GYN_HRFIM|"
        cFldsGYN += "GYN_LOCORI|"
        cFldsGYN += "GYN_LOCDES|"
        cFldsGYN += "GYN_APUCON|"
        cFldsGYN += "GYN_DSCORI|"
        cFldsGYN += "GYN_DSCDES"

        For nX := 1 To Len(aFldsGYN)
            If ( !(aFldsGYN[nX,1] $ cFldsGYN) )
                oStruGYN:RemoveField(aFldsGYN[nX,1])
            EndIf
        Next

    EndIf    

Return

Static Function OrdenaG54(oStruG54,aOrdem)

    Local nI            := 0
    Local nQtdOrd       := 0

    Local aOrdenado     := {}
    Local aFields       := {}
    
    Default aOrdem      := {}

    aFields := aClone(oStruG54:GetFields())

    If ( Len(aOrdem) == 0 )

        AAdd(aOrdem,"G54_MARK")
        AAdd(aOrdem,"G54_NUMGY0")	
        AAdd(aOrdem,"G54_CLIENT")	
        AAdd(aOrdem,"G54_LOJACL")	
        AAdd(aOrdem,"G54_NOMECL")	
        AAdd(aOrdem,"G54_CODGI2")	
        AAdd(aOrdem,"G54_PRODUT")	
        AAdd(aOrdem,"G54_DPROD")
        AAdd(aOrdem,"G54_PRODNT")	
        AAdd(aOrdem,"G54_DPRONT")	
        AAdd(aOrdem,"G54_TOTAL")
        AAdd(aOrdem,"G54_PLCONV")	
        AAdd(aOrdem,"G54_IDPLCO")	
        If G54->(FieldPos("G54_VLFAT1")) > 0
            aAdd(aOrdem,'G54_VLFAT1')
        Endif         
        AAdd(aOrdem,"G54_PRECON")	
        AAdd(aOrdem,"G54_QTDCON")
        AAdd(aOrdem,"G54_VLRCON")	
        AAdd(aOrdem,"G54_VLRACO")	
        AAdd(aOrdem,"G54_TOTCON")	
        AAdd(aOrdem,"G54_KMPROV")	
        AAdd(aOrdem,"G54_KMREAL")	
        AAdd(aOrdem,"G54_QVCNFI")	
        AAdd(aOrdem,"G54_QVCFIN")	
        AAdd(aOrdem,"G54_PLEXTR")	
        AAdd(aOrdem,"G54_IDPLEX")	
        If G54->(FieldPos("G54_VLFAT2")) > 0
            aAdd(aOrdem,'G54_VLFAT2')
        Endif         
        AAdd(aOrdem,"G54_PREEXT")	
        AAdd(aOrdem,"G54_QTDEXT")	
        AAdd(aOrdem,"G54_VLREXT")	
        AAdd(aOrdem,"G54_TOTEXT")	
        AAdd(aOrdem,"G54_KMPREX")
        AAdd(aOrdem,"G54_KMREEX")	
        AAdd(aOrdem,"G54_QVENFI")	
        AAdd(aOrdem,"G54_QVCNFI")	
        AAdd(aOrdem,"G54_QTVESL")	
        AAdd(aOrdem,"G54_VLVESL")	
        AAdd(aOrdem,"G54_TOTADI")	
        AAdd(aOrdem,"G54_CUSOPE")	
        AAdd(aOrdem,"G54_TIPCNR")	
        AAdd(aOrdem,"G54_TPCMPO")	
        AAdd(aOrdem,"G54_DESCRI")	
        AAdd(aOrdem,"G54_PORCEN")	
        AAdd(aOrdem,"G54_VLFIXO")	
        AAdd(aOrdem,"G54_REVISA")	
        AAdd(aOrdem,"G54_CODGQR")

    EndIf

    For nI := 1 to Len(aOrdem)

        If ( oStruG54:HasField(aOrdem[nI]) )
            oStruG54:SetProperty(aOrdem[nI] , MVC_VIEW_ORDEM, StrZero(nI,2))
            aAdd(aOrdenado,aOrdem[nI])
        EndIf

    Next nI
    
    //Fazer a lógica para os que ficariam de fora
    nQtdOrd := Len(aOrdenado)

    If ( nQtdOrd > 0 )

        For nI := 1 to Len(aFields)

            If ( AScan(aOrdenado,aFields[nI,1]) == 0 )

                nQtdOrd++
                oStruG54:SetProperty(aFields[nI,1], MVC_VIEW_ORDEM, StrZero(nQtdOrd,2))

            EndIf

        Next nI        

    EndIf

Return()

/*/{Protheus.doc} FieldTrigger
//TODO Descrição auto-gerada.
@author flavio.martins
@since 25/02/2021
@version 1.0
@return ${return}, ${return_description}
@type function
/*/
Static Function FieldTrigger(oMdl as object, cField as character, uVal)

    Local nX as numeric
    Local nValor as numeric

    nX := 0
    nValor := 0

    If cField == 'G9W_VLACRE'
        oMdl:LoadValue('G9W_TOTCAL', oMdl:GetValue('G9W_TOTAPU') -;
             oMdl:GetValue('G9W_VLDESC') + uVal)
    Endif

    If cField == 'G9W_VLDESC'
        oMdl:LoadValue('G9W_TOTCAL', oMdl:GetValue('G9W_TOTAPU') +;
             oMdl:GetValue('G9W_VLACRE ') - uVal)
    Endif

    If cField == 'G9W_TPCMPO' .AND. uVal == '2'
        oMdl:LoadValue('G9W_TOTCAL', oMdl:GetValue('G9W_TOTCAL') - oMdl:GetValue('G9W_VLFIXO'))
        oMdl:ClearField('G9W_VLFIXO')
    Endif

    If cField == 'G9W_TPCMPO' .AND. uVal == '1'
        oMdl:ClearField('G9W_PORCEN')
        oMdl:LoadValue('G9W_TOTCAL', oMdl:GetValue('G9W_TOTCAL') - oMdl:GetValue('G9W_VLFIXO'))
        oMdl:ClearField('G9W_VLFIXO')
    Endif

    If cField == 'G9W_PORCEN'
        If oMdl:GetValue('G9W_TPCMPO') == '2'
            oMdl:LoadValue('G9W_VLFIXO', oMdl:GetValue('G9W_TOTAPU') * (uVal/100))
        EndIf
    Endif

    If cField == 'G54_TPCMPO' .AND. uVal == '2'
        oMdl:LoadValue('G54_TOTAL', oMdl:GetValue('G54_TOTAL') - oMdl:GetValue('G54_VLFIXO'))
        oMdl:ClearField('G54_VLFIXO')
    Endif

    If cField == 'G54_TPCMPO' .AND. uVal == '1'
        oMdl:ClearField('G54_PORCEN')
        oMdl:LoadValue('G54_TOTAL', oMdl:GetValue('G54_TOTAL') - oMdl:GetValue('G54_VLFIXO'))
        oMdl:ClearField('G54_VLFIXO')
    Endif

    If cField == 'G54_PORCEN'
        If oMdl:GetValue('G54_TPCMPO') == '2'
            oMdl:LoadValue('G54_VLFIXO', oMdl:GetValue('G54_TOTAL') * (uVal/100))
        EndIf
    Endif

    If cField == 'G54_VLFIXO'
        oMdl:LoadValue('G54_TOTAL', oMdl:GetValue('G54_TOTAL') + uVal)
        For nX := 1 To oMdl:GetModel():GetModel('G54DETAIL'):Length()
            nValor += oMdl:GetValue("G54_VLFIXO",nX)
        Next
        oMdl:GetModel():GetModel("G9WDETAIL"):LoadValue("G9W_VLFIXO",nValor)
        oMdl:GetModel():GetModel("G9WDETAIL"):LoadValue("G9W_TOTCAL",;
            oMdl:GetModel():GetModel("G9WDETAIL"):GetValue("G9W_TOTAPU") +;
            oMdl:GetModel():GetModel("G9WDETAIL"):GetValue("G9W_VLACRE") -;
            oMdl:GetModel():GetModel("G9WDETAIL"):GetValue("G9W_VLDESC") + nValor)
    Endif

    If ( cField == "G54_LOJACL" )
        oMdl:LoadValue("G54_NOMECL",Posicione('SA1',1,xFilial('SA1') + oMdl:GetValue("G54_CLIENT") + oMdl:GetValue("G54_LOJACL"),'A1_NOME'))
    EndIf

    If cField $ 'G9W_MARK|G54_MARK|G9W_VLACRE|G9W_VLDESC|G54_VLFIXO|G9W_VLFIXO'
        SomaContrato(oMdl)
    Endif

Return

/*/{Protheus.doc} SomaContrato
//TODO Descrição auto-gerada.
@author flavio.martins
@since 31/03/2021
@version 1.0
@return ${return}, ${return_description}
@type function
/*/
Static Function SomaContrato( oMdl as object )

    Local nTotAcre as numeric
    Local nTotDesc as numeric
    Local nTotApu  as numeric
    Local nTotCal  as numeric
    Local nFinal   as numeric
    Local nLinhas  as numeric
    Local nX       as numeric
    Local nI       as numeric
    Local oModel   as object
    Local aSaveLines := FWSaveRows()

    nTotAcre := 0
    nTotDesc := 0
    nTotApu  := 0
    nTotCal  := 0
    nFinal   := 0
    nLinhas  := 0
    nX       := 0
    nI       := 0
    oModel   := oMdl:GetModel()

    For nX := 1 To oModel:GetModel('G9WDETAIL'):Length()
        oModel:GetModel("G9WDETAIL"):GoLine(nX)

        If nX > 1
            nLinhas := 0
        EndIf

        If oModel:GetModel('G9WDETAIL'):GetValue('G9W_MARK', nX)

            nTotAcre += oModel:GetModel('G9WDETAIL'):GetValue('G9W_VLACRE', nX)
            nTotDesc += oModel:GetModel('G9WDETAIL'):GetValue('G9W_VLDESC', nX)
            nTotApu  += oModel:GetModel('G9WDETAIL'):GetValue('G9W_TOTAPU', nX)
            nTotCal  += oModel:GetModel('G9WDETAIL'):GetValue('G9W_TOTCAL', nX)

            For nI := 1 To oModel:GetModel('G54DETAIL'):Length()
                oModel:GetModel("G54DETAIL"):GoLine(nI)

                If oModel:GetModel('G54DETAIL'):GetValue('G54_MARK', nI)
                    nLinhas += oModel:GetModel('G54DETAIL'):GetValue('G54_TOTAL', nI)
                    nFinal += oModel:GetModel('G54DETAIL'):GetValue('G54_TOTAL', nI)
                EndIf
            Next

            If !Empty(nTotAcre)
                nLinhas += oModel:GetModel('G9WDETAIL'):GetValue('G9W_VLACRE', nX) 
                nFinal += oModel:GetModel('G9WDETAIL'):GetValue('G9W_VLACRE', nX) 
            EndIf

            If !Empty(nTotDesc)
                nLinhas -= oModel:GetModel('G9WDETAIL'):GetValue('G9W_VLDESC', nX)
                nFinal -= oModel:GetModel('G9WDETAIL'):GetValue('G9W_VLDESC', nX)
            EndIf

            If !IsBlind()
                oModel:GetModel('GQRMASTER'):LoadValue('GQR_VLACRE', nTotAcre)
                oModel:GetModel('GQRMASTER'):LoadValue('GQR_VLDESC', nTotDesc)
                oModel:GetModel('GQRMASTER'):LoadValue('GQR_TOTAPU', nTotApu)
                oModel:GetModel('GQRMASTER'):LoadValue('GQR_TOTCAL', nFinal)
                //oModel:GetModel('G9WDETAIL'):LoadValue('G9W_TOTAPU', nLinhas)
                oModel:GetModel('G9WDETAIL'):LoadValue('G9W_TOTCAL', nLinhas)
            EndIf 

        Else                
            oModel:GetModel('GQRMASTER'):LoadValue('GQR_VLACRE', nTotAcre)
            oModel:GetModel('GQRMASTER'):LoadValue('GQR_VLDESC', nTotDesc)
            oModel:GetModel('GQRMASTER'):LoadValue('GQR_TOTAPU', nTotApu)
            oModel:GetModel('GQRMASTER'):LoadValue('GQR_TOTCAL', nFinal)
        Endif
    Next

    FWRestRows( aSaveLines )

Return

/*/{Protheus.doc} AtuViagens
//TODO Descrição auto-gerada.
@author flavio.martins
@since 24/02/2021
@version 1.0
@return ${return}, ${return_description}
@param oModel
@type function
/*/
Static Function AtuViagens(oModel)
    Local lRet      := .T.
    Local aAreaGYN	:= GYN->(GetArea())
    Local cCodApur  := ''
    Local n1        := 0
    Local n2        := 0
    Local n3        := 0

    dbSelectArea('GYN')
    GYN->(dbSetOrder(1))

    For n1 := 1 To oModel:GetModel('G9WDETAIL'):Length()

        oModel:GetModel('G9WDETAIL'):GoLine(n1)

        For n2 := 1 To oModel:GetModel('G54DETAIL'):Length()

            oModel:GetModel('G54DETAIL'):GoLine(n2)

            If oModel:GetModel('G9WDETAIL'):GetValue('G9W_MARK') .And.;
                oModel:GetModel('G54DETAIL'):GetValue('G54_MARK') .And.;
                oModel:GetOperation() != MODEL_OPERATION_DELETE
                cCodApur := oModel:GetModel('GQRMASTER'):GetValue('GQR_CODIGO')
            Else
                cCodApur := ''
            Endif

            For n3 := 1 To oModel:GetModel('GYNDETAIL'):Length()

                If GYN->(dbSeek(xFilial('GYN')+oModel:GetModel('GYNDETAIL'):GetValue('GYN_CODIGO', n3)))
                    RecLock("GYN", .F.)
                        GYN->GYN_APUCON := cCodApur 
                    MsUnLock()
                Endif

            Next

        Next

    Next

    RestArea(aAreaGYN)

Return lRet

/*/{Protheus.doc} G903Commit
//TODO Descrição auto-gerada.
@author flavio.martins
@since 24/02/2021
@version 1.0
@return ${return}, ${return_description}
@param oModel
@type function
/*/
Static Function G903Commit(oModel)
    Local lRet := .T.

    If oModel:GetOperation() != MODEL_OPERATION_INSERT
        If oModel:GetModel('GQRMASTER'):GetValue('GQR_STATUS') == '2'
            lRet := .F.
            oModel:GetModel():SetErrorMessage(oModel:GetId(),,oModel:GetId(),, STR0036, STR0037) //"Atenção", "Não é possível efetuar manutenção em apuração com medição efetivada!"
        EndIf
    Endif

    If lRet
        If oModel:GetOperation() != MODEL_OPERATION_DELETE
            DelNoMarks(oModel)
        Endif

        If oModel:VldData()

            Begin Transaction

                If !AtuViagens(oModel) .Or. !FwFormCommit(oModel)
                    DisarmTransaction()
                    lRet := .F.
                    oModel:GetModel():SetErrorMessage(oModel:GetId(),,oModel:GetId(),,STR0023, STR0024) //"Erro","Erro ao gravar apuração"
                Endif

                If oModel:GetOperation() == MODEL_OPERATION_INSERT
                    lRet := GTPA903B()
                EndIf
            End Transaction

        Endif
    Endif

Return lRet

/*/{Protheus.doc} TotaisVia
//TODO Descrição auto-gerada.
@author flavio.martins
@since 04/05/2021
@version 1.0
@return ${return}, ${return_description}
@param oModel
@type function
/*/
Static Function TotaisVia(oModel)
    Local cAliasTmp := GetNextAlias()
    Local cContrato := oModel:GetModel('G9WDETAIL'):GetValue('G9W_NUMGY0')
    Local cDataIni  := oModel:GetModel('GQRMASTER'):GetValue('GQR_DTINIA')
    Local cDataFim  := oModel:GetModel('GQRMASTER'):GetValue('GQR_DTFINA')
    Local cCodLinha := oModel:GetModel('G54DETAIL'):GetValue('G54_CODGI2')   
    Local cExtCmp   := '%%'

    If GYN->(FieldPos("GYN_EXTCMP")) > 0
    	cExtCmp := '%,GYN_EXTCMP%'
    EndIf

    BeginSql Alias cAliasTmp

        SELECT GYN_FINAL,
               GYN_EXTRA,
               COUNT(GYN_CODIGO) QTDVIAGENS
        FROM %Table:GYN%
        WHERE GYN_FILIAL = %xFilial:GYN%
          AND GYN_CODGY0 = %Exp:cContrato%
          AND GYN_LINCOD = %EXP:cCodLinha%
          AND GYN_DTINI BETWEEN %Exp:cDataIni% AND %Exp:cDataFim%
          AND %NotDel%
        GROUP BY GYN_FINAL, GYN_EXTRA %Exp:cExtCmp%

    EndSql

    While (cAliasTmp)->(!Eof())

        If (cAliasTmp)->GYN_FINAL = '1' .And. (cAliasTmp)->GYN_EXTRA = 'F'
            oModel:GetModel('G54DETAIL'):LoadValue('G54_QVCFIN', (cAliasTmp)->QTDVIAGENS)    
        ElseIf (cAliasTmp)->GYN_FINAL = '1' .And. (cAliasTmp)->GYN_EXTRA = 'T'
            oModel:GetModel('G54DETAIL'):LoadValue('G54_QVEFIN', (cAliasTmp)->QTDVIAGENS)    
        ElseIf (cAliasTmp)->GYN_FINAL = '2' .And. (cAliasTmp)->GYN_EXTRA = 'F'
            oModel:GetModel('G54DETAIL'):LoadValue('G54_QVCNFI', (cAliasTmp)->QTDVIAGENS)    
        ElseIf (cAliasTmp)->GYN_FINAL = '2' .And. (cAliasTmp)->GYN_EXTRA = 'T'
            oModel:GetModel('G54DETAIL'):LoadValue('G54_QVENFI', (cAliasTmp)->QTDVIAGENS)
        Endif

        (cAliasTmp)->(dbSkip())

    End

    (cAliasTmp)->(dbCloseArea())

Return

/*/{Protheus.doc} TotalLinha
//TODO Descrição auto-gerada.
@author flavio.martins
@since 31/03/2021
@version 1.0
@return ${return}, ${return_description}
@param oModel
@type function
/*/
Static Function TotalLinha(oModel)
    Local cAliasTmp     := GetNextAlias()
    Local cCliente      := oModel:GetModel('GQRMASTER'):GetValue('GQR_CLIENT')
    Local cLoja         := oModel:GetModel('GQRMASTER'):GetValue('GQR_LOJA')
    Local cContrato     := oModel:GetModel('G9WDETAIL'):GetValue('G9W_NUMGY0')
    Local cItem         := oModel:GetModel('G54DETAIL'):GetValue('G54_CODGYD')
    Local cDataIni      := oModel:GetModel('GQRMASTER'):GetValue('GQR_DTINIA')
    Local cDataFim      := oModel:GetModel('GQRMASTER'):GetValue('GQR_DTFINA')
    Local cPrecoCon     := oModel:GetModel('G54DETAIL'):GetValue('G54_PRECON')
    Local cPrecoExt     := oModel:GetModel('G54DETAIL'):GetValue('G54_PREEXT')
    Local cLinha        := oModel:GetModel('G54DETAIL'):GetValue('G54_CODGI2')
    Local nQtdViaCon    := oModel:GetModel('G54DETAIL'):GetValue('G54_QVCFIN')
    Local nQtdViaExt    := oModel:GetModel('G54DETAIL'):GetValue('G54_QVEFIN')
    Local nVlrCon       := oModel:GetModel('G54DETAIL'):GetValue('G54_VLRCON')
    Local nVlrExt       := oModel:GetModel('G54DETAIL'):GetValue('G54_VLREXT')
    Local nVlrAco       := oModel:GetModel('G54DETAIL'):GetValue('G54_VLRACO')
    Local nG54_KMPROV   := 0
    Local nG54_KMREAL   := 0
    Local nG54_KMPREX   := 0
    Local nG54_KMREEX   := 0
    Local nQtdCon       := 0
    Local nQtdExt       := 0
    Local nTotCon       := 0
    Local nTotExt       := 0
    Local nVlrAdic      := 0
    Local nVlrOper      := 0
    Local nVlrTot       := 0
    Local nVlrTotGer    := 0
    Local nTotalApur    := 0
    Local nQtdVESL      := 0
    Local cExtCmp       := '%%'
    Local nKMTprev      := 0
    Local nKMTprExtra   := 0

    If GYN->(FieldPos("GYN_EXTCMP")) > 0
        cExtCmp:= "% AND GYN_EXTCMP = 'T' %"
    EndIf

    If lPackage9535
        nG54_KMPROV   := oModel:GetModel('G54DETAIL'):GetValue('G54_KMPROV')
        nG54_KMREAL   := oModel:GetModel('G54DETAIL'):GetValue('G54_KMREAL')
        nG54_KMPREX   := oModel:GetModel('G54DETAIL'):GetValue('G54_KMPREX')
        nG54_KMREEX   := oModel:GetModel('G54DETAIL'):GetValue('G54_KMREEX')
    EndIf 

    BeginSql Alias cAliasTmp

        SELECT GYD.GYD_NUMERO,
            GYD.GYD_CODGYD,
            (GYD.GYD_KMIDA  +
             GYD.GYD_KMVOLT +
             GYD.GYD_KMGRRD +
             GYD.GYD_KMRDGR) AS KMTOTAL,
             GYD.GYD_CODGI2,
        (SELECT COALESCE(SUM(GYX_VALTOT), 0) AS GYX_VALTOT
        FROM %Table:GYX%
        WHERE GYX_FILIAL = GYD.GYD_FILIAL
            AND GYX_CODIGO = GYD.GYD_NUMERO
            AND GYX_REVISA = GYD.GYD_REVISA
            AND GYX_ITEM = GYD.GYD_CODGYD
            AND %NotDel%) GYX_VALTOT,
        (SELECT COALESCE(SUM(GQZ_VALTOT), 0) AS GQZ_VALTOT
        FROM %Table:GQZ%
        WHERE GQZ_FILIAL = GYD.GYD_FILIAL
            AND GQZ_CODIGO = GYD.GYD_NUMERO
            AND GQZ_REVISA = GYD.GYD_REVISA
            AND GQZ_ITEM = GYD.GYD_CODGYD
            AND %NotDel%) GQZ_VALTOT,
        (SELECT COALESCE(SUM(GQJ_VALTOT), 0) AS GQJ_VALTOT
        FROM %Table:GQJ%
        WHERE GQJ_FILIAL = GYD.GYD_FILIAL
            AND GQJ_CODIGO = GYD.GYD_NUMERO
            AND GQJ_REVISA = GYD.GYD_REVISA
            AND %NotDel%) GQJ_VALTOT,
        (SELECT COUNT(DISTINCT(GYN_DTINI)) 
        FROM %Table:GYN%
        WHERE GYN_FILIAL = %xFilial:GYN%
            AND GYN_CODGY0 = GYD.GYD_NUMERO
            AND GYN_LINCOD = GYD.GYD_CODGI2
            AND GYN_DTINI BETWEEN %Exp:cDataIni% AND %Exp:cDataFim%
            AND GYN_TIPO = '3'
            AND GYN_EXTRA = 'F'
            AND GYN_FINAL = '1'
            AND %NotDel%) AS QTDDIASCON,
        (SELECT COUNT(DISTINCT(GYN_DTINI)) 
        FROM %Table:GYN%
        WHERE GYN_FILIAL = %xFilial:GYN%
            AND GYN_CODGY0 = GYD.GYD_NUMERO
            AND GYN_LINCOD = GYD.GYD_CODGI2
            AND GYN_DTINI BETWEEN %Exp:cDataIni% AND %Exp:cDataFim%
            AND GYN_TIPO = '3'
            AND GYN_EXTRA = 'T'
            AND GYN_FINAL = '1'
            AND %NotDel%) AS QTDDIASEXT,
        (SELECT COUNT(GYN_CODIGO) 
        FROM %Table:GYN%
        WHERE GYN_FILIAL = %xFilial:GYN%
            AND GYN_CODGY0 = GYD.GYD_NUMERO
            AND GYN_DTINI BETWEEN %Exp:cDataIni% AND %Exp:cDataFim%
            AND GYN_TIPO = '2'
            %Exp:cExtCmp%
            AND GYN_FINAL = '1'
            AND %NotDel%) AS QTDVESL
        FROM %Table:GY0% GY0
        INNER JOIN %Table:GYD% GYD ON GYD.GYD_FILIAL = GY0.GY0_FILIAL
        AND GYD.GYD_NUMERO = GY0.GY0_NUMERO
        AND GYD.GYD_REVISA = GY0.GY0_REVISA
        AND GYD.GYD_CODGYD = %Exp:cItem%
        AND GYD.%NotDel%
        WHERE GY0.GY0_FILIAL = %xFilial:GY0%
        AND GY0.GY0_CLIENT = %Exp:cCliente%
        AND GY0.GY0_LOJACL = %Exp:cLoja%
        AND GY0.GY0_NUMERO = %Exp:cContrato%
        AND GY0.GY0_ATIVO = '1'
        AND GY0.%NotDel%
    EndSql

    nVlrAdic := IIF((cAliasTmp)->GYX_VALTOT > 0,(cAliasTmp)->GYX_VALTOT,(cAliasTmp)->GQJ_VALTOT)
    nVlrOper := (cAliasTmp)->GQZ_VALTOTT

    nQTDVESL := (cAliasTmp)->QTDVESL

    nKMTprev    := Iif(nG54_KMREAL>0,nG54_KMREAL,nG54_KMPROV)
    nKMTprExtra := Iif(nG54_KMREEX>0,nG54_KMREEX,nG54_KMPREX)

    If cPrecoCon = '1' // Preço Fixo
       // nVlrRef     := (cAliasTmp)->GYD_VLRTOT
        nQtdCon     := 1
        nTotCon     := nVlrCon
        nVlrTot     := nVlrCon + nVlrAdic + nVlrOper
        nVlrTotGer  := nVlrTot
    ElseIf cPrecoCon = '2' // Preço por KM    -- Manutencao[9535]
        nQtdCon     := nKMTprev 
        nTotCon     := (nQtdCon * nVlrCon) + nVlrAco
        nVlrTot     := nTotCon + nVlrAdic + nVlrOper
        nVlrTotGer  := nVlrTot
    ElseIf cPrecoCon = '3' // Preço por Viagem
        nQtdCon     := nQtdViaCon
        nTotCon     := (nQtdCon * nVlrCon) + nVlrAco
        nVlrTot     := nTotCon + nVlrAdic + nVlrOper
        nVlrTotGer  := nVlrTot
    ElseIf cPrecoCon = '4' // Preço por Diaria
        nQtdCon     := (cAliasTmp)->QTDDIASCON
        nTotCon     := (nQtdCon * nVlrCon) + nVlrAco
        nVlrTot     := nTotCon + nVlrAdic + nVlrOper
        nVlrTotGer  := nVlrTot
    Endif

    If cPrecoExt = '1'      // Horas
        nQtdExt := RetHrsVia(oModel)
        nTotExt := nQtdExt * nVlrExt
    ElseIf cPrecoExt = '2' // Diaria
        nQtdExt := (cAliasTmp)->QTDDIASEXT
        nTotExt := nQtdExt * nVlrExt
    ElseIf cPrecoExt = '3' // KM -- Manutencao[9535]
        nQtdExt := nKMTprExtra
        nTotExt := nQtdExt * nVlrExt
    ElseIf cPrecoExt = '4' // Preço Fixo
        nQtdExt := 1
        nTotExt := nVlrExt
    ElseIf cPrecoExt = '5' // Preço por Viagem
        nQtdExt := nQtdViaExt
        nTotExt := nQtdExt * nVlrExt
    Endif

    If ( nQtdExt == 0 .And. nVlrExt > 0 )
        /*nQtdExt := 1
        nTotExt := nVlrExt*/
        nTotExt := 0
        nVlrExt := 0
    EndIf

    nTotalApur = nVlrTot + nTotExt
    oModel:GetModel('G54DETAIL'):LoadValue('G54_TOTADI', nVlrAdic)
    oModel:GetModel('G54DETAIL'):LoadValue('G54_CUSOPE', nVlrOper)
    oModel:GetModel('G54DETAIL'):LoadValue('G54_TOTAL' , nTotalApur)
    oModel:GetModel('G54DETAIL'):LoadValue('G54_QTDCON', nQtdCon)
    oModel:GetModel('G54DETAIL'):LoadValue('G54_QTDEXT', nQtdExt)
    oModel:GetModel('G54DETAIL'):LoadValue('G54_TOTCON', nTotCon)
    oModel:GetModel('G54DETAIL'):LoadValue('G54_TOTEXT', nTotExt)
    oModel:GetModel('G54DETAIL'):LoadValue('G54_VLREXT', nVlrExt)

    If Empty(Alltrim(cLinha))
        oModel:GetModel('G54DETAIL'):LoadValue('G54_QTVESL', nQTDVESL)
        oModel:GetModel('G54DETAIL'):LoadValue('G54_VLVESL', nTotExt)
    Else
        oModel:GetModel('G54DETAIL'):LoadValue('G54_TOTEXT', nTotExt)
    EndIf

    oModel:GetModel('G9WDETAIL'):LoadValue('G9W_TOTAPU', oModel:GetModel('G9WDETAIL'):GetValue('G9W_TOTAPU') + nTotalApur)

    (cAliasTmp)->(dbCloseArea())

Return

/*/{Protheus.doc} RetHrsVia
//TODO Descrição auto-gerada.
@author flavio.martins
@since 04/05/2021
@version 1.0
@return ${return}, ${return_description}
@param oModel
@type function
/*/
Static Function RetHrsVia(oModel)
    Local cAliasTmp := GetNextAlias()
    Local cContrato := oModel:GetModel('G9WDETAIL'):GetValue('G9W_NUMGY0')
    Local cDataIni  := oModel:GetModel('GQRMASTER'):GetValue('GQR_DTINIA')
    Local cDataFim  := oModel:GetModel('GQRMASTER'):GetValue('GQR_DTFINA')
    Local nHoras    := 0
    Local cExtEmp   := ''

    IIf(GYN->(ColumnPos("GYN_EXTCMP")) > 0,cExtEmp := "% (GYN_EXTRA = 'T' OR GYN_EXTCMP = 'T' ) %",cExtEmp := "% GYN_EXTRA = 'T' %")

    BeginSql Alias cAliasTmp

        SELECT GYN_DTINI,
               GYN_DTFIM,
               GYN_HRINI,
               GYN_HRFIM
        FROM %Table:GYN%
        WHERE GYN_FILIAL = %xFilial:GYN%
          AND GYN_CODGY0 = %Exp:cContrato%
          AND GYN_DTINI BETWEEN %Exp:cDataIni% AND %Exp:cDataFim%
          AND %Exp:cExtEmp%
          AND GYN_FINAL = '1'
          AND %NotDel%

    EndSql

    While !(cAliasTmp)->(Eof())

        nHoras += SubHoras( Transform((cAliasTmp)->GYN_HRFIM, "@R 99:99"), Transform((cAliasTmp)->GYN_HRINI, "@R 99:99"))
    
        (cAliasTmp)->(dbSkip())
    End

    (cAliasTmp)->(dbCloseArea())

Return nHoras

/*/{Protheus.doc} G900VldDic
//TODO Descrição auto-gerada.
@author flavio.martins
@since 31/03/2021
@version 1.0
@return ${return}, ${return_description}
@param
@type function
/*/

Function G900VldDic(cMsgErro)
    Local lRet          := .T.
    Local aTables       := {'GY0','GYD','GQI','GQZ','GYX','GQJ','GQR','G9W','G54'}
    Local aFields       := {}
    Local nX            := 0
    Default cMsgErro    := ''

    aFields := {'GQR_VLACRE','GQR_VLDESC','GQR_USUAPU',;
                'GQR_TOTAPU','GQR_TOTCAL','G9W_CODGQR',;
                'G9W_VLACRE','G9W_VLDESC','G9W_NUMGY0',;
                'G9W_CONTRA','G9W_DTINIA','G9W_TPCTO',;
                'G9W_TIPPLA','G9W_TABPRC','G9W_VLACRE',;
                'G9W_VLDESC','G9W_TOTAPU','G9W_TOTCAL',;
                'G9W_MOTIVO','G54_NUMGY0','G54_CODGQR',;
                'G54_PRODUT','G54_CODGI2','G54_QTDE',;
                'G54_VLRTOT','G54_VLREXT','G54_SUBTOT',;
                'G54_TOTADI','G54_CUSOPE','G54_TOTAL',;
                'G9W_TIPCNR','G9W_TPCMPO','G9W_DESCRI',;
                'G9W_PORCEN','G9W_VLFIXO','G54_TIPCNR',;
                'G54_TPCMPO','G54_DESCRI','G54_PORCEN',;
                'G54_VLFIXO','G54_PRECON','G54_PREEXT',;
                'G54_CODGYD','G54_QVCFIN','G54_QVCNFI',;
                'G54_QVEFIN','G54_QVENFI','G54_QTDCON',;
                'G54_QTDEXT','G54_VLRCON','G54_TOTCON',;
                'G54_TOTEXT','GY0_REVISA','GY0_ATIVO',;
                'G54_REVISA','G54_VLRACO','G9W_REVISA'}

    For nX := 1 To Len(aTables)
        If !(GTPxVldDic(aTables[nX], {}, .T., .F., @cMsgErro))
            lRet := .F.
            Exit
        Endif
    Next

    For nX := 1 To Len(aFields)
        If !(Substr(aFields[nX],1,3))->(FieldPos(aFields[nX]))
            lRet := .F.
            cMsgErro := I18n("Campo #1 não se encontra no dicionário",{aFields[nX]})
            Exit
        Endif
    Next

Return lRet

/*/{Protheus.doc} G903VldAct
//TODO Descrição auto-gerada.
@author flavio.martins
@since 31/03/2021
@version 1.0
@return ${return}, ${return_description}
@param
@type function
/*/
Static Function G903VldAct(oModel)
    Local lRet      := .T.
    Local cMsgErro  := ''
    Local cMsgSol   := ''

    If !G900VldDic(@cMsgErro)
        lRet := .F.
        cMsgSol := STR0029 // "Atualize o dicionário para utilizar esta rotina" 
        FwAlertHelp(cMsgErro, STR0029) // "Dicionário desatualizado", "Atualize o dicionário para utilizar esta rotina" 
    Endif

Return lRet

/*/{Protheus.doc} LineChange
//TODO Descrição auto-gerada.
@author flavio.martins
@since 01/04/2021
@version 1.0
@return ${return}, ${return_description}
@param oView, cViewId
@type function
/*/
Static Function LineChange(oView, cViewId)
    Local oModel := oView:GetModel()

    If cViewId = 'G9WDETAIL'
        oModel:GetModel('G54DETAIL'):GoLine(1)
        oModel:GetModel('GYNDETAIL'):GoLine(1)
    ElseIf cViewId = 'G54DETAIL'
        oModel:GetModel('GYNDETAIL'):GoLine(1)
    Endif  

Return

/*/{Protheus.doc} DelNoMarks
//TODO Descrição auto-gerada.
@author flavio.martins
@since 07/04/2021
@version 1.0
@return ${return}, ${return_description}
@param oModel
@type function
/*/
Static Function DelNoMarks(oModel)
    Local nX := 0

    oModel:GetModel('G9WDETAIL'):SetNoDeleteLine(.F.)
    oModel:GetModel('G54DETAIL'):SetNoDeleteLine(.F.)

    For nX := 1 To oModel:GetModel('G54DETAIL'):Length()
        If !(oModel:GetModel('G54DETAIL'):GetValue('G54_MARK', nX))
            oModel:GetModel('G54DETAIL'):GoLine(nX)
            oModel:GetModel('G54DETAIL'):DeleteLine()
        Endif
    Next

    For nX := 1 To oModel:GetModel('G9WDETAIL'):Length()
        If !(oModel:GetModel('G9WDETAIL'):GetValue('G9W_MARK', nX))
            oModel:GetModel('G9WDETAIL'):GoLine(nX)
            oModel:GetModel('G9WDETAIL'):DeleteLine()
        Endif
    Next

    oModel:GetModel('G9WDETAIL'):SetNoDeleteLine(.T.)
    oModel:GetModel('G54DETAIL'):SetNoDeleteLine(.T.)

Return

/*/{Protheus.doc} ConsultaVia
//TODO Descrição auto-gerada.
@author flavio.martins
@since 07/04/2021
@version 1.0
@return ${return}, ${return_description}
@param oModel
@type function
/*/
Static Function ConsultaVia(oModel)
    Local oMdl903A  := FwLoadModel('GTPA903A')
    Local nX        := 0
    Local nY        := 0
    Local cContrDe  := ''
    Local cContrAte := ''
    Local cLinhaDe  := ''
    Local cLinhaAte := ''

    For nX := 1 To oModel:GetModel('G9WDETAIL'):Length()

        oModel:GetModel('G9WDETAIL'):GoLine(nX)

        If cContrDe = ''
            cContrDe := oModel:GetModel('G9WDETAIL'):GetValue('G9W_NUMGY0')
        Endif

        cContrAte := oModel:GetModel('G9WDETAIL'):GetValue('G9W_NUMGY0')

        For nY := 1 To oModel:GetModel('G54DETAIL'):Length()

            If cLinhaDe = '' .Or. (oModel:GetModel('G54DETAIL'):GetValue('G54_CODGI2',nY) < cLinhaDe)
                cLinhaDe :=  oModel:GetModel('G54DETAIL'):GetValue('G54_CODGI2', nY)
            Endif

            If oModel:GetModel('G54DETAIL'):GetValue('G54_CODGI2',nY) > cLinhaAte
                cLinhaAte := oModel:GetModel('G54DETAIL'):GetValue('G54_CODGI2',nY)
            Endif

        Next 

    Next

    oMdl903A:GetModel('HEADER'):GetStruct():SetProperty('CODCLI', MODEL_FIELD_WHEN, { || .F.})
    oMdl903A:GetModel('HEADER'):GetStruct():SetProperty('LOJCLI', MODEL_FIELD_WHEN, { || .F.})
    oMdl903A:GetModel('HEADER'):GetStruct():SetProperty('DATADE', MODEL_FIELD_WHEN, { || .F.})
    oMdl903A:GetModel('HEADER'):GetStruct():SetProperty('DATAATE', MODEL_FIELD_WHEN, { || .F.})

    oMdl903A:SetOperation(MODEL_OPERATION_INSERT)

    oMdl903A:Activate()

    If !(IsBlind()) .And. oMdl903A:IsActive()
        oMdl903A:GetModel('HEADER'):LoadValue('CODCLI',oModel:GetModel('GQRMASTER'):GetValue('GQR_CLIENT'))
        oMdl903A:GetModel('HEADER'):LoadValue('LOJCLI', oModel:GetModel('GQRMASTER'):GetValue('GQR_LOJA'))
        oMdl903A:GetModel('HEADER'):LoadValue('CONTRATODE', cContrDe)
        oMdl903A:GetModel('HEADER'):LoadValue('CONTRATOATE', cContrAte)
        oMdl903A:GetModel('HEADER'):LoadValue('DATADE', oModel:GetModel('GQRMASTER'):GetValue('GQR_DTINIA'))
        oMdl903A:GetModel('HEADER'):LoadValue('DATAATE', oModel:GetModel('GQRMASTER'):GetValue('GQR_DTFINA'))
        oMdl903A:GetModel('HEADER'):LoadValue('LINHADE', cLinhaDe)
        oMdl903A:GetModel('HEADER'):LoadValue('LINHAATE', cLinhaAte)

        GA903APesq(oMdl903A)
        GTPA903A(oMdl903A)
    Endif

Return

/*/{Protheus.doc} ValidMarks
//TODO Descrição auto-gerada.
@author flavio.martins
@since 07/04/2021
@version 1.0
@return ${return}, ${return_description}
@param oModel
@type function
/*/
Static Function ValidMarks(oModel)
    Local lRet      := .F.
    Local lVldG9W   := .F.
    Local lVldG54   := .F.
    Local nX        := 0
    Local nY        := 0

    For nX := 1 To oModel:GetModel('G9WDETAIL'):Length()

        lVldG9W := oModel:GetModel('G9WDETAIL'):GetValue('G9W_MARK', nX)

        If lVldG9W

            For nY := 1 To oModel:GetModel('G54DETAIL'):Length()
                lVldG54 := oModel:GetModel('G54DETAIL'):GetValue('G54_MARK', nY)

                If lVldG54 
                    Exit
                Endif
            Next

            If lVldG9W .And. lVldG54
                lRet := .T.
                Exit
            Endif

        Endif

    Next

Return lRet

/*/{Protheus.doc} GA903Calc
Retorna o valor da planilha de custos.
@author Fernando Radu Muscalu
@since 22/07/2022
@version 1.0
@return ${nValue, numérico}, ${Valor que foi calculado na planilha de custos}
@param  cIdCusto, caractere, código da planilha de custos 
        cFilSeek, caractere, código da filial da planilha de custos
@type function
/*/
Function GA903Calc(cIdCusto,cFilSeek,cChvPlan,cXMLPlan,oMdl,lPlExtra)
    
    Local oModel     := Nil
    Local oMdlGQR    := Nil
    Local oMdlG9W    := Nil
    Local oMdlG54    := Nil
    Local oWorkSheet := FWUIWorkSheet():New(/*oWinPlanilha*/,.F. , /*WS_ROWS*/, /*WS_COLS*/)

    Local nValue		:= 0
    Local cLocPlan      := ""
    Local nCell         := 0
    Local xValue        := Nil
    Local lCalc         := .F.

    Default cFilSeek    := xFilial("GIM")
    Default cChvPlan    := ""
    Default cXMLPlan    := ""
    Default lPlExtra    := .f.

    If (lCalc := ValType(oMdl) == 'O')
        oModel     := oMdl:GetModel()
        oMdlGQR    := oModel:GetModel( 'GQRMASTER' )
        oMdlG9W    := oModel:GetModel( 'G9WDETAIL' )
        oMdlG54    := oModel:GetModel( 'G54DETAIL' )    

        If lPlExtra .And. GYD->(FieldPos("GYD_PLAEXT")) > 0 .And. !Empty(cChvPlan)
            GYD->(DbSetOrder(1))    //GYD_FILIAL+GYD_NUMERO+GYD_CODGYD

            If GYD->(DbSeek( cChvPlan ) )
                cLocPlan   := GYD->GYD_IDPLEX
                cXMLPlan   := GYD->GYD_PLAEXT
            Endif
        Else 
            If GYD->(FieldPos("GYD_CODPLA")) > 0 .And. !Empty(cChvPlan)
                GYD->(DbSetOrder(1))    //GYD_FILIAL+GYD_NUMERO+GYD_CODGYD

                If GYD->(DbSeek( cChvPlan ) )
                    cLocPlan   := GYD->GYD_IDPLCO
                    cXMLPlan   := GYD->GYD_CODPLA
                Endif
            Endif
        Endif    
        
        If !Empty(cLocPlan) .And. Empty(cXMLPlan)
            GIM->(DbSetOrder(1))
            If GIM->(DbSeek(xFilial("GIM")+cLocPlan))
                cXMLPlan := GIM->GIM_PLAN
            EndIf 
        EndIf  

        If !Empty(cXMLPlan)

            oWorkSheet:lShow := .F.
            oWorkSheet:LoadXmlModel(cXMLPlan)

            For nCell := 2 To oWorkSheet:NTOTALLINES			

                If oWorkSheet:CellExists("A"+ cValTochar(nCell))
                    
                    cCellValue	:= oWorkSheet:GetCellValue("A"+ cValTochar(nCell))
                    cCellValue	:= AllTrim(cCellValue) 

                    Do Case
                        Case oMdlGQR:GetStruct():HasField(cCellValue)
                            xValue := oMdlGQR:GetValue(cCellValue)
                            oWorkSheet:SetCellValue("C" + cValToChar(nCell), xValue)
                        Case oMdlG9W:GetStruct():HasField(cCellValue)
                            xValue := oMdlG9W:GetValue(cCellValue)
                            oWorkSheet:SetCellValue("C" + cValToChar(nCell), xValue)
                        Case oMdlG54:GetStruct():HasField(cCellValue)
                            xValue := oMdlG54:GetValue(cCellValue)
                            oWorkSheet:SetCellValue("C" + cValToChar(nCell), xValue)
                    EndCase

                EndIf

            Next nCell 

            If oWorkSheet:CellExists("D2") 	
                nValue := oWorkSheet:GetCellValue("D2")
            EndIf

        EndIf 

    EndIf     

    oWorkSheet:Close()

    GTPDestroy(oWorkSheet)
    
Return(nValue)

/*/{Protheus.doc} ChkCntrCanc
//TODO Descrição auto-gerada.
@author flavio.martins
@since 31/10/2022
@version 1.0
@return ${return}, ${return_description}
@param 
@type function
/*/
Static Function ChkCntrCanc()
    Local cAliasTmp := GetNextAlias()
    Local oGtpLog 	:= GtpLog():New(STR0042) // "Contratos Cancelados"

    If GY0->(FieldPos('GY0_DTCANC')) > 0

        BeginSql Alias cAliasTmp

            SELECT GY0.GY0_NUMERO, GY0.GY0_DTCANC,
                COUNT(GYN.GYN_CODIGO) AS TOTVIA
            FROM %Table:GY0% GY0
            LEFT JOIN %Table:GYN% GYN ON GYN.GYN_FILIAL = %xFilial:GYN%
            AND GYN.GYN_DTINI BETWEEN %Exp:DtoS(MV_PAR05)% AND %Exp:DtoS(MV_PAR06)%
            AND GYN.GYN_APUCON = ' '
            AND GYN.GYN_CODGY0 = GY0.GY0_NUMERO
            AND GYN.%NotDel%
            WHERE GY0.GY0_FILIAL = %xFilial:GY0%
            AND GY0.GY0_STATUS = '3'
            AND GY0.GY0_NUMERO BETWEEN %Exp:MV_PAR03% AND %Exp:MV_PAR04%
            AND GY0.%NotDel%
            GROUP BY GY0.GY0_NUMERO, GY0.GY0_DTCANC

        EndSql

        While (cAliasTmp)->(!Eof())

            If (cAliastmp)->TOTVIA == 0

                If !(oGtpLog:HasInfo())
                    oGtpLog:SetText(STR0039) // 'Os contratos selecionados abaixo estão cancelados e não possuem mais viagens a apurar:'
                Endif

                oGtpLog:SetText(STR0040 + (cAliasTmp)->GY0_NUMERO + STR0041 + DtoC(StoD((cAliasTmp)->GY0_DTCANC))) // 'Contrato: ', ' - Data do Cancelamento: '

            Endif

            (cAliasTmp)->(dbSkip())

        EndDo

        If oGtpLog:HasInfo() 
            oGtpLog:ShowLog()
        Endif

    Endif

    oGtpLog:Destroy()

Return

//------------------------------------------------------------------------------
/* /{Protheus.doc} G903Rateio
Função que abre a tela com as informações do Rateio de produtos, quando existe um.
@type Function
@author Fernando Radu Muscalu
@since 25/07/2023
@version 1.0
@param  oView, objeto, instância da classe FwFormView
@return nil
@example
(examples)
@see (links_or_references)
/*/
//------------------------------------------------------------------------------
Function G903Rateio(oView)

    Local oMdl409a   := FwLoadModel("GTPA904A")
    Local oMdlG54    := oView:GetModel("G54DETAIL")

    oMdl409a:SetOperation(MODEL_OPERATION_VIEW)
    
    H6A->(DbSetOrder(2))    //H6A_FILIAL, H6A_CLIENT, H6A_LOJA, R_E_C_N_O_, D_E_L_E_T_
    
    If ( H6A->(DbSeek(xFilial("H6A") + oMdlG54:GetValue("G54_CLIENT") + oMdlG54:GetValue("G54_LOJACL"))) )
        oMdl409a:Activate()
        FwExecView("Consulta de Rateio de Produtos", "VIEWDEF.GTPA904A", MODEL_OPERATION_VIEW, , {|| .T. } , /*bOk*/ , /*nPercReducao*/, /*aEnableButtons*/, /*bCancel*/, /*cOperatId*/ , /*cToolBar*/ , oMdl409a)	//  "Apuração" 
    EndIf

Return()

//------------------------------------------------------------------------------
/* /{Protheus.doc} FieldInit

Função de Inicialização de campo

@type Function
@author Fernando Radu Muscalu
@since 25/07/2023
@version 1.0
@param  oMdl, objeto, instância da classe FwFormGrid
        cField, caractere, nome do campo que será inicializado
        uVal, qualquer, valor
@return uRet, qualquer, retorna o conteúdo para a incialização do campo em cfield
@example
(examples)
@see (links_or_references)
/*/
//------------------------------------------------------------------------------
Static Function FieldInit(oMdl,cField)

    Local uRet      := nil
    Local oModel	:= oMdl:GetModel()
    Local lInsert	:= oModel:GetOperation() == MODEL_OPERATION_INSERT 
    Local aArea     := GetArea()

    Do Case 
    
        Case cField == "G54_NOMECL"
            uRet := If(!lInsert,Posicione('SA1',1,xFilial('SA1') + G54->G54_CLIENT + G54->G54_LOJACL,'A1_NOME'),'')        
    
    EndCase 

    RestArea(aArea)

Return uRet

//------------------------------------------------------------------------------
/* /{Protheus.doc} G903Modelo

Função que retorna objeto estático do modelo de dados GTPA903

@type Function
@author Fernando Radu Muscalu
@since 25/07/2023
@version 1.0
@param  
@return oG903Model, objeto, retorna a instância de FwFormModel
@example
(examples)
@see (links_or_references)
/*/
//------------------------------------------------------------------------------
Function G903Modelo()

Return(oG903Model)

//------------------------------------------------------------------------------
/* /{Protheus.doc} G903IsActive

Função que avalia se o modelo de dados GTPA903 está ativo

@type Function
@author Fernando Radu Muscalu
@since 25/07/2023
@version 1.0
@param  
@return lActived, lógico, .t. = ativo; .f. = não ativo ou instânciado
@example
(examples)
@see (links_or_references)
/*/
//------------------------------------------------------------------------------
Function G903IsActive()

    Local lActived := ValType(oG903Model) == "O" .And. oG903Model:IsActive()

    If ( !lActived )
        oG903Model := FwModelActive()
        lActived := oG903Model:GetId() == "GTPA903"
    EndIf

Return(lActived)


/*/{Protheus.doc} GetKMProvReal
(long_description)
@type function
@author jose.darocha
@since 13/03/2024
@version 1.0
@return ${return}, ${return_description}
@example
(examples)
@see (links_or_references)
/*/

Static Function GetKMProvReal(cCodContrato,cDataIni,cDataFim,cAuxG54)
    Local aAreaAtu  := GetArea()
    Local cAliasQry := GetNextAlias()
    Local aRetorno  := {0, 0, 0, 0}

    BeginSql Alias cAliasQry

        SELECT SUM(GYN_KMPROV) AS GYN_KMPROV
            ,SUM(GYN_KMREAL) AS GYN_KMREAL
            ,GYN_EXTRA
        FROM %Table:GYN%
        WHERE GYN_FILIAL = %xFilial:GYN%
            AND GYN_CODGY0 = %Exp:cCodContrato%
            AND GYN_DTINI BETWEEN %Exp:cDataIni% AND %Exp:cDataFim%
            AND GYN_FINAL = '1'
            AND GYN_LINCOD = %Exp:cAuxG54%
            AND %NotDel%
        GROUP BY GYN_EXTRA         

    EndSql

    While (cAliasQry)->(!Eof())
        If (cAliasQry)->GYN_EXTRA == 'F'
            aRetorno[1] := GYN_KMPROV
            aRetorno[2] := GYN_KMREAL
        Else 
            aRetorno[3] := GYN_KMPROV
            aRetorno[4] := GYN_KMREAL
        EndIf 

        (cAliasQry)->(DbSkip())
    EndDo 

    (cAliasQry)->(DbCloseArea())

    RestArea(aAreaAtu)     

Return aRetorno 

//------------------------------------------------------------------------------------------
/*/{Protheus.doc} G903BRFil()
Função de retorno da consulta padrão especifica na GY0
@sample		G903BRFil()
@return 	cRet, caracter, Retorna o contrato selecionado.
@author		Mick William da Silva
@since		18/03/2024
@version	P12
/*/
//------------------------------------------------------------------------------------------
Function G903BRFil()

    Local cRet :='' 
    
    cRet:=	c903BCodigo

Return cRet

//------------------------------------------------------------------------------------------
/*/{Protheus.doc} G903BFil
Montagem da consulta padrão especifica na GY0
@sample		G903BFil
@return		lRet, Lógico, .T. ou .F.
@author		Mick William da Silva
@since		18/03/2024
@version	P12
/*/
//------------------------------------------------------------------------------------------
Function G903BFil()

    Local aRetorno 		:= {}
    Local cQryGY0       := ""      
    Local lRet     		:= .F.
    Local oLookUp  		:= Nil
    Local   cDBUse      := AllTrim( TCGetDB() )

    If Valtype(MV_PAR01) == "C" .And. Valtype(MV_PAR02) == "C"

        cQryGY0:= " SELECT DISTINCT GY0.GY0_FILIAL,GY0.GY0_NUMERO, "
		Do Case
			Case cDBUse == 'ORACLE'
                cQryGY0+= " (SELECT GY0_REVISA FROM " +RetSqlName("GY0")+ " GY02 WHERE GY02.GY0_FILIAL = GY0.GY0_FILIAL AND "
                cQryGY0+= " GY02.GY0_NUMERO=GY0.GY0_NUMERO AND GY02.GY0_DTINIC = GY0.GY0_DTINIC AND "
                cQryGY0+= " GY02.GY0_CLIENT = GY0.GY0_CLIENT AND GY02.GY0_LOJACL = GY0.GY0_LOJACL AND GY02.D_E_L_E_T_=' ' "
                cQryGY0+= " ORDER BY GY02.GY0_REVISA DESC  fetch first 1 rows only) AS GY0_REVISA, "
                cQryGY0+= " GY0.GY0_DTINIC,GY0.GY0_CLIENT,GY0.GY0_LOJACL "
			OtherWise
                cQryGY0+= " (SELECT TOP 1 GY0_REVISA FROM " +RetSqlName("GY0")+ " GY02 WHERE GY02.GY0_FILIAL = GY0.GY0_FILIAL AND "
                cQryGY0+= " GY02.GY0_NUMERO=GY0.GY0_NUMERO AND GY02.GY0_DTINIC = GY0.GY0_DTINIC AND "
                cQryGY0+= " GY02.GY0_CLIENT = GY0.GY0_CLIENT AND GY02.GY0_LOJACL = GY0.GY0_LOJACL AND GY02.D_E_L_E_T_=' ' "
                cQryGY0+= " ORDER BY GY02.GY0_REVISA DESC) AS GY0_REVISA, "
                cQryGY0+= " GY0.GY0_DTINIC,GY0.GY0_CLIENT,GY0.GY0_LOJACL "
        EndCase
        cQryGY0+= " FROM " + RetSqlName("GY0") + " GY0  "
        cQryGY0+= " WHERE GY0.GY0_FILIAL = '"+xFilial('GY0')+"' " 
        cQryGY0+= " AND GY0.GY0_CLIENT='"+MV_PAR01+"' AND GY0.GY0_LOJACL='"+MV_PAR02+"'
        cQryGY0+= " AND (GY0.GY0_NUMERO >= '"+MV_PAR03+"'" + " AND GY0.GY0_NUMERO <= '"+MV_PAR04+"')"+" 
        cQryGY0+= " AND GY0_STATUS IN ('2', '6') AND GY0.D_E_L_E_T_=' ' "

        cQryGY0 := ChangeQuery(cQryGY0)

        oLookUp := GTPXLookUp():New(StrTran(cQryGY0, '#', '"'), {"GY0_FILIAL","GY0_NUMERO","GY0_REVISA", "GY0_DTINIC","GY0_CLIENT","GY0_LOJACL"})

        oLookUp:AddIndice("Filial"		, "GY0_FILIAL")
        oLookUp:AddIndice("Numero"		, "GY0_NUMERO")
        oLookUp:AddIndice("Revisao"		, "GY0_REVISA")
        oLookUp:AddIndice("Data Inicio" , "GY0_DTINIC")
        oLookUp:AddIndice("Cliente"		, "GY0_CLIENT")
        oLookUp:AddIndice("Loja"		, "GY0_LOJACL")

        If oLookUp:Execute()
            lRet       := .T.
            aRetorno   := oLookUp:GetReturn()
            c903BCodigo := aRetorno[2]
        EndIf   

        FreeObj(oLookUp)

    EndIF

Return lRet
