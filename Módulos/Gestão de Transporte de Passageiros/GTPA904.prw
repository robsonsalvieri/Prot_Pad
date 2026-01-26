#Include "GTPA904.ch"
#INCLUDE 'PROTHEUS.CH'
#INCLUDE 'PARMTYPE.CH'
#INCLUDE 'FWMVCDEF.CH'

Static lG904Rateio := .F.

/*/{Protheus.doc} GTPA904
(long_description)
@type  Function
@author user
@since 02/08/2022
@version version
@param param_name, param_type, param_descr
@return return_var, return_type, return_description
@example
(examples)
@see (links_or_references)
/*/
Function GTPA904()

    Local oBrowse    := Nil

    Local aFieldsH6A := {}
    Local aFieldsH6B := {}

    Local cMsgErro   := ""

    If ( !FindFunction("GTPHASACCESS") .Or.; 
        ( FindFunction("GTPHASACCESS") .And. GTPHasAccess() ) ) 

        aFieldsH6A := {'H6A_CODIGO','H6A_CLIENT','H6A_LOJA','H6A_STATUS'}
        aFieldsH6B := {'H6B_CODIGO','H6B_SEQ','H6B_CODG6U','H6B_TPPERI','H6B_QTDPER','H6B_DATAUL','H6B_EXPIRA','H6B_EXIGEN'}

        If GTPxVldDic("H6A",aFieldsH6A,.T.,.T.,@cMsgErro) .And.;
            GTPxVldDic("H6B",aFieldsH6B,.T.,.T.,@cMsgErro)

            UsaRateioCnt()
            
            oBrowse    := FWMBrowse():New()
            oBrowse:SetAlias('H6A')
            //isso é fretamento continuo
            oBrowse:SetDescription(STR0001) //"Parâmetro cliente Fretamento contínuo"
            
            If H6A->(FIELDPOS("H6A_STATUS")) > 0
                oBrowse:AddLegend("H6A_STATUS == '1'"   ,"GREEN"   ,STR0002    ) //'Ativo'
                oBrowse:AddLegend("H6A_STATUS == '2'"   ,"RED"     ,STR0003  ) //'Inativo'
            EndIf

            oBrowse:Activate()
            oBrowse:Destroy()

        EndIf

        If !(EMPTY(cMsgErro))
            FwAlertWarning(cMsgErro)
        EndIf

    EndIf

Return()

//------------------------------------------------------------------------------
/*/{Protheus.doc} MenuDef
Função responsavel pela definição do menu
@type Static Function
@author henrique.toyada
@since 09/07/2019
@version 1.0
@return aRotina, retorna as opções do menu
/*/
//------------------------------------------------------------------------------
Static Function MenuDef()
Local aRotina := {} 

    ADD OPTION aRotina TITLE STR0004 ACTION 'VIEWDEF.GTPA904' OPERATION OP_VISUALIZAR  ACCESS 0 //"Visualizar"
    ADD OPTION aRotina TITLE STR0005 ACTION 'VIEWDEF.GTPA904' OPERATION OP_INCLUIR	   ACCESS 0 //"Incluir"
    ADD OPTION aRotina TITLE STR0006 ACTION 'VIEWDEF.GTPA904' OPERATION OP_ALTERAR	   ACCESS 0 //"Alterar"
    ADD OPTION aRotina TITLE STR0007 ACTION 'VIEWDEF.GTPA904' OPERATION OP_EXCLUIR	   ACCESS 0 //"Excluir"

Return aRotina

//------------------------------------------------------------------------------
/*/{Protheus.doc} ModelDef
Função responsavel pela definição do modelo
@type Static Function
@author henrique.toyada
@since 02/08/2022
@version 1.0
@return oModel, retorna o Objeto do Menu
/*/
//------------------------------------------------------------------------------
Static Function ModelDef()

    Local oModel	:= nil
    Local oStrH6A	:= {}
    Local oStrH6B	:= {}
    Local oStrH6Q	:= {}

    Local bPosValid := {|oModel| PosValid(oModel)}

    SetModelStruct(oStrH6A,oStrH6B,oStrH6Q)

    oModel := MPFormModel():New('GTPA904', /*bPreValidacao*/, bPosValid, /*bCommit*/, /*bCancel*/ )

    oModel:AddFields('H6AMASTER',/*cOwner*/,oStrH6A)

    oModel:AddGrid('H6BDETAIL','H6AMASTER',oStrH6B,/*bLinePre*/,/*bLinePost*/, /*bPreVal*/,/*bPosVld*/,/*BLoad*/)
    oModel:SetRelation('H6BDETAIL',{{ 'H6B_FILIAL','xFilial("H6B")'},{'H6B_CODIGO','H6A_CODIGO' }},H6B->(IndexKey(1)))

    If ( lG904Rateio )

        oModel:AddGrid('H6QDETAIL','H6AMASTER',oStrH6Q,/*bLinePre*/,/*bLinePost*/, /*bPreVal*/,/*bPosVld*/,/*BLoad*/)
        oModel:SetRelation('H6QDETAIL',{{ 'H6Q_FILIAL','xFilial("H6Q")'},{'H6Q_CODH6A','H6A_CODIGO' }},H6Q->(IndexKey(3)))//H6Q_FILIAL+H6Q_CODIGO+H6Q_SEQ+H6Q_PRODUT
        oModel:GetModel( 'H6QDETAIL' ):SetUniqueLine( { 'H6Q_PRODUT' } )
        oModel:GetModel( 'H6QDETAIL' ):SetOptional(.T.)
        oModel:GetModel( 'H6BDETAIL' ):SetOptional(.T.)

    EndIf
        
    oModel:SetDescription(STR0001) //"Parâmetro cliente Fretamento contínuo"

    oModel:SetPrimaryKey({'H6A_FILIAL','H6A_CODIGO'})

Return oModel

//------------------------------------------------------------------------------
/*/{Protheus.doc} SetModelStruct
Função responsavel pela estrutura de dados do modelo
@type Static Function
@author henrique.toyada
@since 02/08/2022
@version 1.0
@param oStrH6A, object, (Descrição do parâmetro)
@param oStrH6B, object, (Descrição do parâmetro)
@return nil, retorno nulo
@example
(examples)
@see (links_or_references)
/*/
//------------------------------------------------------------------------------
Static Function SetModelStruct(oStrH6A,oStrH6B,oStrH6Q)

    Local bTrig		:= {|oMdl,cField,uVal| FieldTrigger(oMdl,cField,uVal)}
    Local bInit		:= {|oMdl,cField,uVal,nLine,uOldValue| FieldInit(oMdl,cField,uVal,nLine,uOldValue)}
    Local bFldVld	:= {|oMdl,cField,uNewValue,uOldValue|FieldValid(oMdl,cField,uNewValue,uOldValue) }
    
    oStrH6A	:= FWFormStruct(1,'H6A')
    oStrH6B	:= FWFormStruct(1,'H6B')
    
    If ( lG904Rateio )

        oStrH6Q	:= FWFormStruct(1,'H6Q')
    
        oStrH6Q:SetProperty('H6Q_RATEIO', MODEL_FIELD_VALID, bFldVld )
        oStrH6Q:SetProperty('H6Q_PRODES', MODEL_FIELD_INIT, bInit )
        oStrH6Q:SetProperty('H6Q_SEQ'    ,MODEL_FIELD_WHEN	    ,{|| .f.})
        
        oStrH6Q:AddTrigger('H6Q_PRODUT', 'H6Q_PRODES',  { || .T. }, bTrig ) 

    EndIf

    If oStrH6A:HasField("H6A_DESCRI")//H6A->(FIELDPOS("H6A_DESCRI")) > 0
        oStrH6A:SetProperty('H6A_DESCRI', MODEL_FIELD_INIT, bInit )
    EndIf

    If oStrH6B:HasField("H6B_DESG6U")//H6B->(FIELDPOS("H6B_DESG6U")) > 0
        oStrH6B:SetProperty('H6B_DESG6U', MODEL_FIELD_INIT, bInit )
    EndIf

    If oStrH6B:HasField("H6B_EXIGEN")
        oStrH6B:SetProperty('H6B_EXIGEN', MODEL_FIELD_OBRIGAT, .T.)
    EndIf

    If H6A->(FIELDPOS("H6A_CLIENT")) > 0
        oStrH6A:AddTrigger('H6A_CLIENT', 'H6A_CLIENT',  { || .T. }, bTrig ) 
    EndIf

    If H6A->(FIELDPOS("H6A_LOJA")) > 0
        oStrH6A:AddTrigger('H6A_LOJA'  , 'H6A_LOJA'  ,  { || .T. }, bTrig ) 
        oStrH6A:SetProperty('H6A_LOJA'    ,MODEL_FIELD_VALID	    ,bFldVld)
    EndIf

    If H6B->(FIELDPOS("H6B_CODG6U")) > 0
        oStrH6B:AddTrigger('H6B_CODG6U', 'H6B_CODG6U',  { || .T. }, bTrig ) 
    EndIf

    If H6B->(FIELDPOS("H6B_DATAUL")) > 0
        oStrH6B:AddTrigger('H6B_DATAUL', 'H6B_DATAUL',  { || .T. }, bTrig ) 
    EndIf

Return() 

//------------------------------------------------------------------------------
/* /{Protheus.doc} FieldInit

@type Function
@author henrique.toyada 
@since 02/08/2022
@version 1.0
@param , character, (Descrição do parâmetro)
@return , return_description
@example
(examples)
@see (links_or_references)
/*/
//------------------------------------------------------------------------------
Static Function FieldInit(oMdl,cField,uVal,nLine,uOldValue)

    Local uRet      := nil
    Local oModel	:= oMdl:GetModel()
    Local lInsert	:= oModel:GetOperation() == MODEL_OPERATION_INSERT 
    Local aArea     := GetArea()

    Do Case 
        Case cField == "H6A_DESCRI"
            uRet := If(!lInsert,Posicione('SA1',1,xFilial('SA1') + H6A->H6A_CLIENT + H6A->H6A_LOJA,'A1_NOME'),'')
        Case cField == "H6B_DESG6U"
            uRet := If(!lInsert,SUBSTR(Posicione('G6U',1,xFilial('G6U') + H6B->H6B_CODG6U,'G6U_DESCRI'),0,TamSX3("G6U_DESCRI")[1]),'')
        Case cField == "H6Q_PRODES"
            uRet := If( !lInsert ,SB1->(GetAdvFVal("SB1","B1_DESC",XFilial("SB1") + H6Q->H6Q_PRODUT)),'')
    EndCase 

    RestArea(aArea)

Return uRet

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

    Local xRet  := Nil

	Do Case 
		Case cField == 'H6A_CLIENT'
			oMdl:SetValue("H6A_LOJA" ,Posicione('SA1',1,xFilial('SA1')+uVal,"A1_LOJA" ))
			oMdl:SetValue("H6A_DESCRI" ,SUBSTR(Posicione('SA1',1,xFilial('SA1')+uVal+Posicione('SA1',1,xFilial('SA1')+uVal,"A1_LOJA" ),"A1_NOME" ),0,TamSX3("H6A_DESCRI")[1]))
		Case cField == 'H6A_LOJA'
			oMdl:SetValue("H6A_DESCRI" ,SUBSTR(Posicione('SA1',1,xFilial('SA1')+oMdl:GetValue('H6A_CLIENT')+uVal,"A1_NOME" ),0,TamSX3("H6A_DESCRI")[1]))
        Case cField == "H6B_CODG6U"
            SetFieldG6U(oMdl,uVal)
        Case cField == "H6Q_PRODUT"
            xRet := SB1->(GetAdvFVal("SB1","B1_DESC",XFilial("SB1") + uVal,1,""))
	EndCase 

Return xRet

//------------------------------------------------------------------------------
/*/{Protheus.doc} FieldValid(oMdl,cField,uNewValue,uOldValue)
Função responsavel pela validação dos campos
@type Static Function
@author henrique.toyada
@since 09/07/2019
@version 1.0
@param oMdl, character, (Descrição do parâmetro)
@param cField, character, (Descrição do parâmetro)
@param uNewValue, character, (Descrição do parâmetro)
@param uOldValue, character, (Descrição do parâmetro)
@return lRet, retorno logico dizendo se a validação é com sucesso ou erro
/*/
//------------------------------------------------------------------------------
Static Function FieldValid(oMdl,cField,uNewValue,uOldValue)
Local lRet		:= .T.
Local oModel	:= oMdl:GetModel()
Local cMdlId	:= oMdl:GetId()
Local cMsgErro	:= ""
Local cMsgSol	:= ""

Do Case
    Case Empty(uNewValue)
		lRet := .T.
    Case cField == "H6A_LOJA"
        If GTPExistCpo('H6A',oMdl:GetValue('H6A_CLIENT') + uNewValue,2)
            lRet		:= .F.
            cMsgErro	:= STR0009//"Cliente e loja já cadastrado"
            cMsgSol		:= STR0010//"Verifique se o mesmo se encontra cadastrado e ativo para uso"
        Endif
    Case ( cField == "H6Q_RATEIO" )

        If ( !(oMdl:IsDeleted()) )

            If ( uNewValue < 0 )

                lRet := .F.
            
                cMsgErro	:= STR0025  //"Valor de percentual de rateio não pode ser inferior a zero."
                cMsgSol		:= STR0026  //"Digite um valor maior que zero."
                
            Else

                nSumRateio := SomaRateio(oMdl,oMdl:GetLine())
                
                If ( (nSumRateio + uNewValue) > 100 )
                    
                    lRet := .F.

                    cMsgErro	:= STR0011  //"A somatória dos valores rateados não pode ser superior a 100%"
                    cMsgSol		:= STR0012  //"Avalie os valores de rateio e ajuste de acordo."

                EndIf

            EndIf

        EndIf
EndCase        

If !lRet .and. !Empty(cMsgErro)
	oModel:SetErrorMessage(cMdlId,cField,cMdlId,cField,"FieldValid",cMsgErro,cMsgSol,uNewValue,uOldValue)
Endif

Return lRet

//------------------------------------------------------------------------------
/*/{Protheus.doc} GetDtVigencia
Função responsavel para calcular a proxima data
@type Static Function
@author henrique.toyada
@since 08/07/2019
@version 1.0
@param dDtIni, date, (Descrição do parâmetro)
@param cTpVigen, character, (Descrição do parâmetro)
@param nTempVig, numeric, (Descrição do parâmetro)
@return dDtFim, retorna a proxima data de acordo com os parametros informados
@example
(examples)
@see (links_or_references)
/*/
//------------------------------------------------------------------------------
Static Function GetDtVigencia(dDtIni,cTpVigen,nTempVig)
Local dDtFim    := dDtIni

Do Case
    Case cTpVigen == "1" //Ano
        dDtFim  := YearSum(dDtIni,nTempVig)
    Case cTpVigen == "2" //Mes
        dDtFim  := MonthSum(dDtIni,nTempVig)
    Case cTpVigen == "3" //Dia
        dDtFim  := DaySum(dDtIni,nTempVig)
EndCase

Return dDtFim

//------------------------------------------------------------------------------
/*/{Protheus.doc} SetFieldG6U
Função responsavel pelo preenchimento dos campos do tipo de documento
@type Static Function
@author henrique.toyada
@since 02/08/2022
@version 1.0
@param oMdl, object, (Descrição do parâmetro)
@param cCodG6U, character, (Descrição do parâmetro)
@return nil, retorna nulo
@example
(examples)
@see (links_or_references)
/*/
//------------------------------------------------------------------------------
Static Function SetFieldG6U(oMdl,cCodG6U)
Local aAreaG6U  := G6U->(GetArea())

G6U->(DbSetOrder(1))//G6U_FILIAL+G6U_CODIGO
If G6U->(DbSeek(xFilial('G6U')+cCodG6U))

    oMdl:SetValue('H6B_TPPERI',G6U->G6U_TPVIGE)
    oMdl:SetValue('H6B_QTDPER',G6U->G6U_TEMPVI)
    oMdl:SetValue("H6B_DESG6U",SUBSTR(G6U->G6U_DESCRI,0,TamSX3("G6U_DESCRI")[1]))
Endif

RestArea(aAreaG6U)
GtpDestroy(aAreaG6U)
Return nil

//------------------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
Função responsavel pela definição da view
@type Static Function
@author henrique.toyada
@since 02/08/2022
@version 1.0
@return oView, retorna o Objeto da View
/*/
//------------------------------------------------------------------------------
Static Function ViewDef()

    Local oView		:= FWFormView():New()
    Local oModel	:= FwLoadModel('GTPA904')
    Local oStrH6A	:= {}
    Local oStrH6B	:= {}
    Local oStrH6Q	:= {}
    
    SetViewStruct(oStrH6A,oStrH6B,oStrH6Q)

    oView:SetModel(oModel)

    oView:AddField('VIEW_H6A',  oStrH6A,    'H6AMASTER')
    oView:AddGrid('VIEW_H6B',   oStrH6B,    'H6BDETAIL')
    
    If ( lG904Rateio )
        oView:AddGrid('VIEW_H6Q',   oStrH6Q,    'H6QDETAIL')
    EndIf

    oView:CreateHorizontalBox('UPPER'   , 20)
    oView:CreateHorizontalBox('BOTTOM'  , 80)

    oView:SetOwnerView('VIEW_H6A','UPPER')

    If ( lG904Rateio )

        oView:CreateFolder("FOLDER", "BOTTOM")
        oView:AddSheet("FOLDER", "ABA01", STR0015)    //"Documentação Solicitada"
        oView:AddSheet("FOLDER", "ABA02", STR0016)    //"Rateio de Produtos para Contrato"
        oView:CreateVerticalBox("DOCUMENT", 100,,, 'FOLDER', 'ABA01')
        oView:CreateVerticalBox("RATEIO",  100,,, 'FOLDER', 'ABA02')
    
        oView:SetOwnerView('VIEW_H6B','DOCUMENT')
        oView:SetOwnerView('VIEW_H6Q','RATEIO')
    
        oView:AddIncrementField('VIEW_H6Q','H6Q_SEQ')

    Else
        oView:SetOwnerView('VIEW_H6B','BOTTOM')
    EndIf

    If H6B->(FIELDPOS("H6B_SEQ")) > 0
        oView:AddIncrementField('VIEW_H6B','H6B_SEQ')
    EndIf

    oView:SetDescription(STR0008) //"Parâmetro cliente encomendas"

Return oView

//------------------------------------------------------------------------------
/*/{Protheus.doc} SetViewStruct
Função responsavel pela estrutura de dados da view
@type Static Function
@author henrique.toyada
@since 02/08/2022
@version 1.0
@param oStrH6A, object, (Descrição do parâmetro)
@param oStrH6B, object, (Descrição do parâmetro)
@return nil, retorno nulo
@example
(examples)
@see (links_or_references)
/*/
//------------------------------------------------------------------------------
Static Function SetViewStruct(oStrH6A,oStrH6B,oStrH6Q)

    oStrH6A	:= FWFormStruct(2, 'H6A')
    oStrH6B	:= FWFormStruct(2, 'H6B')

    If H6A->(FIELDPOS("H6A_CODIGO")) > 0
        oStrH6A:RemoveField('H6A_CODIGO')
    EndIf

    If H6B->(FIELDPOS("H6B_CODIGO")) > 0
        oStrH6B:RemoveField('H6B_CODIGO')
    EndIf

    If ( lG904Rateio )
        oStrH6Q	:= FWFormStruct(2, 'H6Q')
        oStrH6Q:RemoveField('H6Q_CODIGO')
        oStrH6Q:RemoveField('H6Q_CODH6A')
    EndIf

Return


/*/{Protheus.doc} SomaRateio
Função responsável por efetuar a soma e percentual de rateio
(gtrid dados da linha)
@type  Static Function
@author Fernando Radu Muscalu
@since 14/07/2023
@version 1.0
@param 
	oMdlRateio, objeto, instância da classe FwFormGrid ('H6QDETAIL')
	nLine, numérico, nro da linha do Grid de rateio
		
@return nSum, numérico, soma dos percentuais de rateio.
@example
(examples)
@see (links_or_references)
/*/
Static Function SomaRateio(oMdlRateio,nLine)

    Local nSum  := 0
    Local nI    := 0

    Default nLine   := 0

    For nI := 1 to oMdlRateio:Length()

        If ( nI <> nLine .And. !(oMdlRateio:IsDeleted(nI))  )
            nSum += oMdlRateio:GetValue("H6Q_RATEIO",nI)
        EndIf

    Next nI

Return(nSum)

/*/{Protheus.doc} WrongWay
Função que avalia se o itinerário possui o mesmo sentido que a linha
(gtrid dados da linha)
@type  Static Function
@author Teixeira
@since 25/05/2023
@version 1.0
@param 
	oModel, objeto, instância do modelo de dados 
	cSentido, caracter, sentido do trecho (ida ou volta)
	cMsgErro, caractere, parâmetro passado por referência para 
	ser atualizado com mensagem de erro, caso haja.
	nLnGQI, numerico, linha do submodelo GQIDETAIL
	nLnGYD, numerico, linha do submodelo GYDDETAIL
	
@return LRet, lógico, .t. sentido está correto; .f. não está correto
@example
(examples)
@see (links_or_references)
/*/
Static Function PosValid(oModel)

    Local lRet          := .T.
    Local lAllDeleted   := .F.

    Local cMsgErro	:= ""
    Local cMsgSol	:= ""

    Local nSoma     := 0
    
    Local oMdlH6Q   := oModel:GetModel("H6QDETAIL")
    Local oMdlH6B   := oModel:GetModel("H6BDETAIL")

    If ( oModel:GetOperation() == MODEL_OPERATION_INSERT .Or.;
        oModel:GetOperation() == MODEL_OPERATION_UPDATE )

        //-------------------------------------------------------------------------------------------------
        //Validações da Aba Rateio [início]
        //-------------------------------------------------------------------------------------------------
        If ( lG904Rateio )
            
            lAllDeleted := GridAllDeleted(oMdlH6Q)

            //Valida se as grids de Documentos Solicitados e Rateio dos produtos estão vazias
            lVazio := oMdlH6B:IsEmpty() .And. oMdlH6Q:IsEmpty() 
            
            If ( !lAllDeleted .And. lVazio )
                
                lRet := .F.
                
                cMsgErro    := STR0017  //"Quando se informa a parametrização para os clientes de fretameto contínuo, exige-se o preenchimento de pelo menos uma das abas do formulário."
                cMsgSol     := STR0018 + STR0015 + STR0019 + STR0016 + "' "    //"Informe pelo menos um item ou na 'Aba "#"' ou na 'Aba "
                
            Else

                If ( !lAllDeleted .And. oMdlH6Q:IsModified() )
                
                    //Avalia se há preenchimento de Rateio com código de produto em branco
                    lVazio :=  oMdlH6Q:SeekLine({{"H6Q_PRODUT",Space(TamSx3("H6Q_PRODUT")[1])}})
                
                    If ( lVazio )
                        
                        lRet := .F.

                        cMsgErro	:= STR0013  //"Há dados preenchidos na Aba Rateio de Produtos para Contrato, mas não há identificação de protudo em uma das linhas."
                        cMsgSol		:= STR0014  //"Quando há preenchimento de dados na citada Aba, há necessidade de preencher o produto que será rateado."

                    Else

                        //Validação da soma de percentual rateado
                        nSoma := SomaRateio(oMdlH6Q)
                        
                        If ( nSoma > 100 )
                            
                            lRet := .F.

                            cMsgErro	:= STR0011  //"A somatória dos valores rateados não pode ser superior a 100%"
                            cMsgSol		:= STR0012  //"Avalie os valores de rateio e ajuste de acordo."
                        
                        ElseIf ( nSoma < 100 )                        
                        
                            lRet := .f.

                            cMsgErro    := STR0027  //"A somatória dos valores rateados não pode ser inferior a 100%"
                            cMsgSol		:= STR0012  //"Avalie os valores de rateio e ajuste de acordo."
                        ElseIf ( nSoma == 0 )                        
                            
                            lRet := .F.

                            cMsgErro	:= STR0020  //"Valor rateado está zerado."
                            cMsgSol		:= STR0021  //"A soma dos rateios entre os produtos listado deverá ser maior que 0% e menor que 100%"
                        
                        EndIf
                        
                        //Avalia se há algum produto listado para rateio que pode ter valor 0 de rateio
                        If ( lRet )
                            
                            oMdlH6Q:GoLine(1)
                            
                            lVazio := oMdlH6Q:SeekLine({{"H6Q_RATEIO",0}})

                            If ( lVazio )
                                
                                lRet := .F.

                                cMsgErro	:= STR0022 + STR0016 + STR0023    //"Pelo menos um dos produtos listado (Aba '"#"') está com valor de rateio igual a 0%."
                                cMsgSol		:= STR0024  //"Veja o produto da sequência Listada "
                                cMsgSol		+= oMdlH6Q:GetValue("H6Q_SEQ")

                            EndIf

                        EndIf

                    EndIf

                EndIf

            EndIf
            
            If ( !lRet )
                oModel:SetErrorMessage("H6QDETAIL","H6Q_RATEIO","H6QDETAIL","H6Q_RATEIO","PosValid",cMsgErro,cMsgSol)//,,)
            EndIf

            //-------------------------------------------------------------------------------------------------
            //Validações da Aba Rateio [fim]
            //-------------------------------------------------------------------------------------------------
        EndIf
    
    EndIf

Return(lRet)

/*/{Protheus.doc} UsaRateioCnt

Função que avalia se o dicionário de dados possui a tabela para Rateio de Produtos
do contrato de fretamento contínuo - H6Q
(gtrid dados da linha)

@type  Static Function
@author Fernando Radu Muscalu
@since 14/07/2023
@version 1.0
@param
@return lG904Rateio, lógico e estática, .t. possui a tabela H6Q; .f. não possui
@example
(examples)
@see (links_or_references)
/*/
Static Function UsaRateioCnt()

    Local aFieldsH6Q := {'H6Q_CODIGO','H6Q_SEQ','H6Q_PRODUT','H6Q_RATEIO'}
    
    If ( !lG904Rateio .And. GTPxVldDic("H6Q",aFieldsH6Q,.T.,.T.,/*@cMsgErro*/) )
        G904RateioOnOff()
    EndIf

Return(lG904Rateio)

/*/{Protheus.doc} GridAllDeleted

Função que avalia se todos os itens do Grid estão "deletados"

@type Function
@author Fernando Radu Muscalu
@since 14/07/2023
@version 1.0
@param 
	lAllDeleted, lógico, .f. nem todos estão deletados / .t. todos estão deletados
	
@return nil
@example
(examples)
@see (links_or_references)
/*/
Function GridAllDeleted(oGrid)
    
    Local lAllDeleted  := .f.

    Local nI    := 0
    Local nDel  := 0

    For nI := 1 to oGrid:Length()

        If ( oGrid:IsDeleted(nI) )
            nDel++
        EndIf

    Next nI
    
    lAllDeleted := nDel == oGrid:Length()

Return(lAllDeleted)

/*/{Protheus.doc} G904RateioOnOff

Função que liga ou desliga o rateio de produtos do fretamento contínuo
[uso interno para o desenvolvimento - dummy para cobertura e debug de fonte]

@type Function
@author Fernando Radu Muscalu
@since 14/07/2023
@version 1.0
@param 
	lOn, lógico, .f. desliga o uso de rateio / .t. liga o uso
	
@return nil
@example
(examples)
@see (links_or_references)
/*/
Function G904RateioOnOff(lOn)
    
    Default lOn := .T.
    
    lG904Rateio := GTPGetRules("GTPDUMMYON",,,lOn)

Return()
