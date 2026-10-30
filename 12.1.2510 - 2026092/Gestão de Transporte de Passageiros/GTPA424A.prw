#Include "GTPA424A.ch"
#INCLUDE 'PROTHEUS.CH'
#INCLUDE 'PARMTYPE.CH'
#INCLUDE 'FWMVCDEF.CH'

/*/{Protheus.doc} GTPA424A
    (long_description)
    @type  Function
    @author henrique.toyada
    @since 21/11/2022
    @version version
    @param nOpc, param_type, param_descr
    @return return_var, return_type, return_description
    @example
    (examples)
    @see (links_or_references)
    /*/
Function GTPA424A(nOpc)
    Local lRet := .T.

    Private nOpcx := nOpc

    If nOpc == 5 .AND. H6O->H6O_STATUS == '1'
        MsgInfo(STR0002 ,STR0001 ) //"Atenção" //'Título não pode ser estornado, necessário gerar o titulo primeiro!'
        lRet := .F.
    EndIf

    If nOpc == 3 .AND. H6O->H6O_STATUS == '3'
        MsgInfo(STR0003 ,STR0001 ) //"Atenção" //'Título não pode ser gerado, registro já consta como todos os titulos gerados!'
        lRet := .F.
    EndIf

    If lRet
        FwExecView(STR0004, "VIEWDEF.GTPA424A", MODEL_OPERATION_UPDATE,,{|| .T.},,50,,,,,) //"Selecione as empresas"
    EndIf

Return


/*/{Protheus.doc} ModelDef
(long_description)
@type  Static Function
@author flavio.martins
@since 26/10/2022
@version 1.0
@param nil, param_type, param_descr
@return oModel, return_type, return_description
@example
(examples)
@see (links_or_references)
/*/
Static Function ModelDef()
Local oModel    := Nil
Local oStruH6O  := FwFormStruct(1, "H6O",{ |x| ALLTRIM(x)+"|" $ "H6O_FILIAL|H6O_CODIGO|H6O_CODEMP|H6O_DESEMP|H6O_STATUS|" })
Local oStruH6P  := FwFormStruct(1, "H6P") 
Local bCommit	:= {|oModel| G424ACommit(oModel)}
Local bPosValid	:= {|oModel| G424APosVld(oModel)}
Local bFldVld	:= {|oMdl,cField,uNewValue,uOldValue|FieldValid(oMdl,cField,uNewValue,uOldValue) }
Local bTrig		:= {|oMdl,cField,uVal| FieldTrigger(oMdl,cField,uVal)}
Local cStatus   := "0"

If Type("nOpcX") == 'N'
    If nOpcX == 3
        cStatus := '2'
    Else 
        cStatus := '1'
    Endif
Endif

oStruH6P:AddField("", "", "H6P_MARK" , "L", 1  , 0, NIL, NIL ,NIL, .F., { || .F.}, .F., .F., .T.)

oModel := MPFormModel():New("GTPA424A", /*bPreValid*/, bPosValid, /*bCommit*/, /*bCancel*/ )
oModel:SetDescription(STR0005) //"Geração de titulo"

oModel:AddFields("H6OMASTER",,oStruH6O)
oModel:AddGrid("H6PDETAIL","H6OMASTER", oStruH6P)

oModel:SetRelation("H6PDETAIL", {{"H6P_FILIAL","xFilial('H6P')"}, {"H6P_CODIGO","H6O_CODIGO"}}, H6P->(IndexKey(1)))

oModel:GetModel("H6PDETAIL"):SetLoadFilter(, "H6P_STATUS = '" + cStatus + "'" )

oModel:GetModel("H6PDETAIL"):SetMaxLine(999999)

oModel:GetModel("H6PDETAIL"):SetOptional(.T.)

oModel:GetModel("H6PDETAIL"):SetDescription(STR0006) //"Empresas não finalizadas"

oModel:GetModel("H6PDETAIL"):SetNoInsertLine(.T.)
oModel:GetModel("H6PDETAIL"):SetNoDeleteLine(.T.)

oStruH6P:SetProperty("*",  MODEL_FIELD_NOUPD, .T.)
oStruH6P:SetProperty("H6P_MARK",  MODEL_FIELD_NOUPD, .F.)
oStruH6P:SetProperty("H6P_CODSA2",  MODEL_FIELD_NOUPD, .F.)
oStruH6P:SetProperty("H6P_LOJSA2",  MODEL_FIELD_NOUPD, .F.)

oModel:SetPrimaryKey({"H6O_FILIAL","H6O_CODEMP"})

oStruH6P:SetProperty("H6P_CODSA2", MODEL_FIELD_VALID, bFldVld)
oStruH6P:SetProperty("H6P_LOJSA2", MODEL_FIELD_VALID, bFldVld)

oStruH6P:AddTrigger('H6P_CODSA2', 'H6P_CODSA2',  { || .T. }, bTrig) 
oStruH6P:AddTrigger('H6P_LOJSA2', 'H6P_LOJSA2',  { || .T. }, bTrig) 

oModel:SetCommit(bCommit)

Return oModel

/*/{Protheus.doc} ViewDef
(long_description)
@type  Static Function
@author flavio.martins
@since 26/10/2022
@version 1.0
@param oView, param_type, param_descr
@return oModel, return_type, return_description
@example
(examples)
@see (links_or_references)
/*/
Static Function ViewDef()
Local oView		:= Nil
Local oModel	:= FwLoadModel('GTPA424A')
Local oStruH6O  := FwFormStruct(2, "H6O",{ |x| ALLTRIM(x)+"|" $ "H6O_CODEMP|H6O_DESEMP|" })
Local oStruH6P 	:= FwFormStruct(2,'H6P')
Local cFldsH6P  := 'H6P_MARK|H6P_SEQ|H6P_CODEMP|H6P_DESEMP|H6P_EMPDES|H6P_DSCDES|H6P_VALITM|H6P_CODSA2|H6P_LOJSA2|H6P_DESSA2'
Local nX        := 0

oStruH6P:AddField("H6P_MARK", "00", "", "", NIL, "L", "", NIL, Nil, .T., NIL, NIL, Nil, NIL, NIL, .T., NIL)

oView := FwFormView():New()
oView:SetModel(oModel)
oView:SetDescription(STR0005) //"Geração de titulo"

oView:AddField('VIEW_HEADER', oStruH6O, 'H6OMASTER')
oView:AddGrid('VIEW_DETAIL' , oStruH6P, 'H6PDETAIL')

oView:CreateHorizontalBox('HEADER', 20)
oView:CreateHorizontalBox('DETAIL', 80)

oView:SetOwnerView('VIEW_HEADER','HEADER')
oView:SetOwnerView('VIEW_DETAIL','DETAIL')

oView:EnableTitleView("VIEW_HEADER", STR0007)  //"Empresa"
oView:EnableTitleView("VIEW_DETAIL", STR0006) //"Empresas não finalizadas"

oStruH6P:RemoveField('H6P_CODIGO')
oStruH6P:RemoveField('H6P_STATUS')
oStruH6P:RemoveField('H6P_FILTIT')
oStruH6P:RemoveField('H6P_PRETIT')
oStruH6P:RemoveField('H6P_NUMTIT')
oStruH6P:RemoveField('H6P_PARTIT')
oStruH6P:RemoveField('H6P_TIPTIT')

For nX := 1 To Len(StrToKarr(cFldsH6P,"|"))
    oStruH6P:SetProperty(StrToKarr(cFldsH6P,"|")[nX], MVC_VIEW_ORDEM , StrZero(nX, 2))
Next

oView:ShowUpdateMessage(.F.)

Return oView

/*/{Protheus.doc} G424ACommit
(long_description)
@type  Static Function
@author flavio.martins
@since 26/10/2022
@version 1.0
@param nil, param_type, param_descr
@return lRet, return_type, return_description
@example
(examples)
@see (links_or_references)
/*/
Static Function G424ACommit(oModel)
Local lRet    := .T.

    If oModel:GetModel('H6PDETAIL'):SeekLine({{"H6P_MARK", .T. }})
        FwMsgRun(,{|| lRet := TP424GvFinanceiro(oModel)}, STR0009, STR0008) //"Efetuando manutenção dos titulos..." //"Aguarde"
    Else
        lRet := .F.
        oModel:SetErrorMessage(oModel:GetId(),,oModel:GetId(),,"G424ACommit",STR0019, STR0020) //"Nenhum registro foi selecionado", "Selecione ao menos um registro para gerar os títulos"
    Endif

    If lRet 
        oModel:GetModel('H6PDETAIL'):GoLine(1)

        If oModel:GetModel('H6PDETAIL'):SeekLine({{"H6P_STATUS", '1'}}) .And.;
           oModel:GetModel('H6PDETAIL'):SeekLine({{"H6P_STATUS", '2'}})
            oModel:GetModel('H6OMASTER'):SetValue('H6O_STATUS', '2')
        ElseIf oModel:GetModel('H6PDETAIL'):SeekLine({{"H6P_STATUS", '2'}})
            oModel:GetModel('H6OMASTER'):SetValue('H6O_STATUS', '1')
        Else
            oModel:GetModel('H6OMASTER'):SetValue('H6O_STATUS', '3')
        Endif

    Endif
    
    If lRet .And. oModel:VldData()
        FwFormCommit(oModel)
    Endif

Return lRet
//-------------------------------------------------------------------  
/*/{Protheus.doc} TP410GvFinanceiro
Grava no financeiro
@type function
@author henrique.toyada
@since 21/11/2022
@version 1.0
@param ${param}, ${param_type}, ${param_descr}
@return ${return}, ${return_description}
/*///-------------------------------------------------------------------  
Function TP424GvFinanceiro(oModel)
Local aArea     := GetArea()
Local aAreaSE2  := SE2->(GetArea())
Local cParcela	:= StrZero(1, TamSx3('E2_PARCELA')[1])
Local cNatTit  	:= GPA281PAR("NATENTREMP")
Local cPrefixo	:= PadR(GPA281PAR("PREENTREMP"), TamSx3('E2_PREFIXO')[1])  
Local cTipo		:= GPA281PAR("TIPENTREMP")
Local cNum	    := ''
Local cHistSE2  := STR0010 //"Titulo entre empresa"
Local aTitPagar := {}
Local cStatus   := '2'
Local oModelH6P := oModel:GetModel("H6PDETAIL")
Local nCnt      := 0
Local lRet      := .T.
Local cMsgErro  := ''
Local cMsgSol   := ''
Private lMsErroAuto := .F.

If nOpcx == 5
    cStatus := '1'
EndIf

If Empty(cNatTit)
    lRet := .F.
    cMsgErro := STR0014 // "O parâmetro do módulo 'NATENTREMP' necessita estar preenchido para geração dos títulos"
    cMsgSol  := STR0015 // "Preencha o parâmetro antes para gerar o título"
Endif

If lRet .And. Empty(cPrefixo)
    lRet := .F.
    cMsgErro := STR0016 // "O parâmetro do módulo 'PREENTREMP' necessita estar preenchido para geração dos títulos"
    cMsgSol  := STR0015 // "Preencha o parâmetro antes para gerar o título"
Endif

If lRet .And. Empty(cTipo)
    lRet := .F.
    cMsgErro := STR0017 // "O parâmetro do módulo 'TIPENTREMP' necessita estar preenchido para geração dos títulos"
    cMsgSol  := STR0015 // "Preencha o parâmetro antes para gerar o título"
Endif

If lRet .And. oModelH6P:Length() > 0

    For nCnt := 1 To oModelH6P:Length()
        If oModelH6P:GetValue("H6P_MARK",nCnt)

            oModelH6P:GoLine(nCnt)

            dbSelectArea("SE2")
            SE2->(dbSetORder(1))//E2_FILIAL, E2_PREFIXO, E2_NUM, E2_PARCELA, E2_TIPO, E2_FORNECE, E2_LOJA, R_E_C_N_O_, D_E_L_E_T_
            if !SE2->(dbSeek(xFilial("SE2")+cPrefixo+cNum+cParcela+cTipo+oModelH6P:GetValue("H6P_CODSA2")+oModelH6P:GetValue("H6P_LOJSA2")))

                If nOpcx == 3

                    cNum := GetSxEnum('SE2', 'E2_NUM')
                
                    aTitPagar := {	{"E2_PREFIXO"	, cPrefixo		, Nil },; //Prefixo
                                    {"E2_NUM"    	, cNum			, Nil },; //Numero								
                                    {"E2_PARCELA"	, cParcela		, Nil },; //Parcela
                                    {"E2_TIPO"   	, cTipo			, Nil },; //Tipo
                                    {"E2_NATUREZ"	, cNatTit		, Nil },; //Natureza
                                    {"E2_FORNECE"	, oModelH6P:GetValue("H6P_CODSA2")	, Nil },; //Fornecedor
                                    {"E2_LOJA"   	, oModelH6P:GetValue("H6P_LOJSA2")	, Nil },; //Loja
                                    {"E2_EMISSAO"	, DATE()		, Nil },; //Emissão
                                    {"E2_VENCTO"	, DATE()		, Nil },; //Vencimento
                                    {"E2_VENCREA"	, DATE()		, Nil },; //Vencimento Real
                                    {"E2_VENCORI"	, DATE()		, Nil },; //Vencimento Original      
                                    {"E2_EMIS1"  	, DATE()		, Nil },; //Emissão
                                    {"E2_VALOR"  	, oModelH6P:GetValue("H6P_VALITM")	, Nil },; //Valor
                                    {"E2_VLCRUZ" 	, oModelH6P:GetValue("H6P_VALITM")	, Nil },; //Vl R$
                                    {"E2_HIST" 		, cHistSE2 		, Nil },;
                                    {"E2_ORIGEM" 	, "GTPA424"		, Nil }}  //Origem
                Else
                    dbSelectArea("SE2")
                    SE2->(dbSetORder(1))//E2_FILIAL, E2_PREFIXO, E2_NUM, E2_PARCELA, E2_TIPO, E2_FORNECE, E2_LOJA, R_E_C_N_O_, D_E_L_E_T_
                    If SE2->(dbSeek(oModelH6P:GetValue("H6P_FILTIT")+oModelH6P:GetValue("H6P_PRETIT")+oModelH6P:GetValue("H6P_NUMTIT")+;
                                    oModelH6P:GetValue("H6P_PARTIT")+oModelH6P:GetValue("H6P_TIPTIT")+oModelH6P:GetValue("H6P_CODSA2")+;
                                    oModelH6P:GetValue("H6P_LOJSA2")))
                        aTitPagar := {	{ "E2_FILIAL"	, SE2->E2_FILIAL			        , Nil },; 
                                        { "E2_NUM"		, SE2->E2_NUM  					    , Nil },; 				
                                        { "E2_PREFIXO"	, SE2->E2_PREFIXO		            , Nil },; 					
                                        { "E2_PARCELA"	, SE2->E2_PARCELA				    , Nil },; 
                                        { "E2_TIPO"		, SE2->E2_TIPO					    , Nil },; 
                                        { "E2_NATUREZ"	, SE2->E2_NATUREZ			        , Nil },; 
                                        { "E2_FORNECE"	, SE2->E2_FORNECE				    , Nil },; 
                                        { "E2_LOJA"		, SE2->E2_LOJA			 		    , Nil },; 
                                        { "E2_EMISSAO"	, SE2->E2_EMISSAO		         	, Nil }; 
                                    } 
                    EndIf
                EndIf

                MSExecAuto({|x,y,z| FINA050(x,y,z)}, aTitPagar, , nOpcx)
                    
                If lMsErroAuto
                
                    MostraErro()
                    SE2->(RollBackSx8())

                    lRet     := .F.
                    cMsgErro := STR0018 // "Erro na geração do título"
                    cMsgSol  := ""
                    Exit
                    
                Else
                    
                    SE2->(ConfirmSX8())

                    If cStatus == '2'

                        oModel:GetModel('H6PDETAIL'):GoLine(nCnt)

                        oModel:GetModel('H6PDETAIL'):LoadValue("H6P_STATUS", '1')
                        oModel:GetModel('H6PDETAIL'):LoadValue("H6P_FILTIT", SE2->E2_FILIAL)
                        oModel:GetModel('H6PDETAIL'):LoadValue("H6P_PRETIT", SE2->E2_PREFIXO)
                        oModel:GetModel('H6PDETAIL'):LoadValue("H6P_NUMTIT", SE2->E2_NUM)
                        oModel:GetModel('H6PDETAIL'):LoadValue("H6P_PARTIT", SE2->E2_PARCELA)
                        oModel:GetModel('H6PDETAIL'):LoadValue("H6P_TIPTIT", SE2->E2_TIPO)

                    Else 
                        oModel:GetModel('H6PDETAIL'):LoadValue("H6P_STATUS", '2')
                        oModel:GetModel('H6PDETAIL'):ClearField("H6P_FILTIT")
                        oModel:GetModel('H6PDETAIL'):ClearField("H6P_PRETIT")
                        oModel:GetModel('H6PDETAIL'):ClearField("H6P_NUMTIT")
                        oModel:GetModel('H6PDETAIL'):ClearField("H6P_PARTIT")
                        oModel:GetModel('H6PDETAIL'):ClearField("H6P_TIPTIT")

                    Endif
                 
                Endif

            EndIf
        EndIf

    Next
EndIf

If lRet 

    If nOpcX == 3
        FwAlertSuccess(STR0012,STR0011) //"Sucesso" //"Gerado titulos com sucesso!"
    Else 
        FwAlertSuccess(STR0013,STR0011) //"Excluído titulos com sucesso!" //"Sucesso"
    Endif

Else
    oModel:GetModel():SetErrorMessage(oModel:GetId(),,oModel:GetId(),,"TP424GvFinanceiro",cMsgErro,cMsgSol,,)
Endif

RestArea(aAreaSE2)
RestArea(aArea)

Return lRet 

//--------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} FieldTrigger
Função que preenche trigger

@sample	GA850ATrig()

@author henrique.toyada
@since 02/08/2022
@version	P12
/*/
//--------------------------------------------------------------------------------------------------------
Static Function FieldTrigger(oMdl,cField,uVal)
Local oModel	:= oMdl:GetModel()
Local oModelH6P := oModel:GetModel("H6PDETAIL")

	Do Case 
        Case cField == "H6P_CODSA2"
            oModelH6P:LoadValue("H6P_DESSA2", POSICIONE("SA2",1,XFILIAL("SA2")+uVal+oModelH6P:GETVALUE("H6P_LOJSA2"),"A2_NOME")) 
        Case cField == "H6P_LOJSA2"
            If !(Empty(oModelH6P:GetValue("H6P_CODSA2")))
                oModelH6P:LoadValue("H6P_DESSA2", POSICIONE("SA2",1,XFILIAL("SA2")+oModelH6P:GETVALUE("H6P_CODSA2")+uVal,"A2_NOME")) 
            Endif
	EndCase 

Return uVal

//-------------------------------------------------------------------  
/*/{Protheus.doc} FieldValid()
Função de validação de campos
@type function
@author flavio.martins
@since 16/02/2023
@version 1.0
@param ${param}, ${param_type}, ${param_descr}
@return ${return}, ${return_description}
/*///-------------------------------------------------------------------  
Static Function FieldValid(oMdl,cField,uNewValue,uOldValue)
Local lRet		:= .T.
Local oModel	:= oMdl:GetModel()
Local cMdlId	:= oMdl:GetId()
Local cMsgErro	:= ""
Local cMsgSol	:= ""

If cField == 'H6P_CODSA2'

    If !Empty(uNewValue)

        SA2->(dbSetOrder(1))

        If !(SA2->(dbSeek(xFilial('SA2')+uNewValue)))
            lRet     := .F.
            cMsgErro := STR0021 // 'Fornecedor não encontrado'
            cMsgSol  := STR0022 // 'Verifique o código do fornecedor informado'
        Endif

    Endif

Endif 

If cField == 'H6P_LOJSA2' 

    If !Empty(uNewValue)

        If Empty(oMdl:GetValue('H6P_CODSA2'))
            lRet     := .F.
            cMsgErro := STR0023 // 'Código do Fornecedor não preenchido'
            cMsgSol  := STR0024 //'Informe o código do fornecedor antes de informar a loja'
        Else
            SA2->(dbSetOrder(1))

            If !(SA2->(dbSeek(xFilial('SA2')+oMdl:GetValue('H6P_CODSA2')+oMdl:GetValue('H6P_LOJSA2'))))
                lRet     := .F.
                cMsgErro := STR0025 //'Fornecedor/loja não encontrado'
                cMsgSol  := STR0026 //'Verifique os dados informados'
            Endif
        Endif    

    Endif

Endif

If !lRet .and. !Empty(cMsgErro)
	oModel:SetErrorMessage(cMdlId,cField,cMdlId,cField,"FieldValid",cMsgErro,cMsgSol,uNewValue,uOldValue)
Endif

Return lRet

//-------------------------------------------------------------------  
/*/{Protheus.doc} G424APosVld()
Função de validação do modelo
@type function
@author flavio.martins
@since 16/02/2023
@version 1.0
@param ${param}, ${param_type}, ${param_descr}
@return ${return}, ${return_description}
/*///-------------------------------------------------------------------  
Static Function G424APosVld(oModel)
Local lRet := .T.
Local nX := 0

SA2->(dbSetOrder(1))

For nX := 1 To oModel:GetModel('H6PDETAIL'):Length()
    
    If oModel:GetModel('H6PDETAIL'):GetValue('H6P_MARK', nX)

        If !(SA2->(dbSeek(xFilial('SA2')+oModel:GetModel('H6PDETAIL'):GetValue('H6P_CODSA2', nX)+oModel:GetModel('H6PDETAIL'):GetValue('H6P_LOJSA2', nX))))
            lRet     := .F.
            cMsgErro := STR0027 + oModel:GetModel('H6PDETAIL'):GetValue('H6P_SEQ', nX)  //'Fornecedor/loja não encontrado para a sequência '
            cMsgSol  := STR0028                                                         //'Informe um fornecedor e loja válido para gerar os títulos'
            Exit
        Endif

    Endif

Next

If !lRet .and. !Empty(cMsgErro)
	oModel:SetErrorMessage(oModel:GetId(),,oModel:GetId(),,"G424APosVld",cMsgErro,cMsgSol,,)
Endif


Return lRet
