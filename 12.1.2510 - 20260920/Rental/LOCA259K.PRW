#Include "loca259k.ch"
#INCLUDE "TOTVS.CH"
#include "FWMVCDEF.CH"

/*/{Protheus.doc} MODELDEF
Definicão do modelo para Rotina Automatica de Demanda
@type function
@version 24.10 
@author Alexandre Circenis
@since 2/12/2025
@return variant, Modelo de Demanda
/*/
STATIC FUNCTION MODELDEF()
Local oStruFQT := FWFormStruct( 1, 'FQT', /*bAvalCampo*/,/*lViewUsado*/ )
Local oStruFQ5 := FwFormStruct( 1, 'FQ5', {|x| x$ "FQ5_FILIAL FQ5_AS    FQ5_DEMAND FQ5_FILORI FQ5_VIAGEM  FQ5_SOT   FQ5_NOMCLI FQ5_XPROD  FQ5_XQTD  "},/*lViewUsado*/ )
Local oStruFH2 := FwFormStruct( 1, 'FH2', {|x| x$ "FH2_FILIAL FH2_CODBEM FH2_AS"}/*bAvalCampo*/,/*lViewUsado*/ )

oModel := MPFormModel():New( 'LOCA259K', /*bPreValidacao*/, {|oMod| LOCA259KTO(oMod)},{|oMod| LOCA259KGR(oMod)}, /*bCancel*/ )
//oModel := MPFormModel():New( 'COMP012MODEL', /*bPreValidacao*/, { | oMdl | COMP012POS( oMdl ) } , /*bCommit*/, /*bCancel*/ )

oStruFQT:AddTrigger( "FQT_PROJET" , "FQT_PROJET"  , {|| .T. }  , {|| LOCA259TGA() } )
oStruFQT:AddTrigger( "FQT_OBRA"   , "FQT_OBRA"	  , {|| .T. }  , {|| LOCA259TGB() } )
// Tirar a validação conforme o dicionario for liberado
oSTruFQT:SetProperty("FQT_PRAZOH",MODEL_FIELD_VALID, FWBuildFeature( STRUCT_FEATURE_VALID, 'Vazio() .or. AtVldHora(M->FQT_PRAZOH)'))
oSTruFQT:SetProperty("FQT_PROJET",MODEL_FIELD_WHEN, {|| Empty(M->FQT_PROJET) .or. !FwIsInCallStack("Loca259DGD") } )
oSTruFQT:SetProperty("FQT_OBRA",MODEL_FIELD_WHEN, {|| Empty( M->FQT_OBRA) .or. !FwIsInCallStack("Loca259DGD") } )


oSTruFQ5:SetProperty("FQ5_AS",MODEL_FIELD_VALID, FWBuildFeature( STRUCT_FEATURE_VALID, 'LOCA259KAS()'))
oSTruFH2:SetProperty("FH2_CODBEM",MODEL_FIELD_VALID, FWBuildFeature( STRUCT_FEATURE_VALID, 'LOCA259KFH2()'))

// Adiciona ao modelo uma estrutura de formulário de edição por campo
oModel:AddFields( 'FQTMASTER', /*cOwner*/, oStruFQT, /*bPreValidacao*/, /*bPosValidacao*/, /*bCarga*/ )
oModel:AddGrid( 'FQ5PAT', "FQTMASTER", oStruFQ5, /*bPreLValidacao*/, )
oModel:AddGrid( 'FH2QTD', "FQ5PAT", oStruFH2 )

oModel:SetRelation( 'FQ5PAT', { { 'FQ5_FILIAL', 'xFilial("FQ5")' } ,{"FQ5_DEMAND","FQT_DEMAND"}}, FQ5->( IndexKey( 22 ) ) )
oModel:SetRelation( 'FH2QTD', { { 'FH2_FILIAL', 'xFilial("FH2")' } ,{"FH2_AS","FQ5_AS"}}, FH2->( IndexKey( 1 ) ) )

oModel:GetModel('FH2QTD'):SetOptional(.T.)
// Adiciona a descricao do Modelo de Dados
oModel:SetDescription( STR0001 ) //STR0001 //'Gestão de Demandas'

// Adiciona a descricao do Componente do Modelo de Dados
oModel:GetModel( 'FQTMASTER' ):SetDescription( STR0002 ) //STR0002 //'Demanda'
oModel:SetPrimaryKey({"FQT_FILIAL","FQT_DEMAND"})

oModel:AddRules('FQTMASTER', "FQT_OBRA", 'FQTMASTER', "FQT_PROJET", 3)
oModel:SetOnlyQuery("FQ5PAT", .T.)
oModel:SetOnlyQuery("FH2QTD", .T.)
oModel:GetModel( 'FQ5PAT' ):SetUniqueLine({"FQ5_AS"})
oModel:GetModel( 'FH2QTD' ):SetUniqueLine({"FH2_CODBEM"})
oModel:GetModel( 'FH2QTD' ):SetNoInsertLine(.T.)
oModel:GetModel( 'FH2QTD' ):SetNoUpdateLine(.T.)
oModel:GetModel( 'FH2QTD' ):SetNoDeleteLine(.T.)
oModel:GetModel( 'FQ5PAT' ):SetMaxLine(9000)
oModel:GetModel( 'FH2QTD' ):SetMaxLine(9000)

Return oModel

/*/{Protheus.doc} ViewDef
Define a View da Demanda
@type function
@version 24.10 
@author Alexandre Circenis
@since 2/12/2025
@return variant, Retorna a view da demanda
/*/
STATIC FUNCTION VIEWDEF()
Local oView     := FwFormView():New()
Local oStrFQT   := FWFormStruct(2,'FQT', )
Local oStrFQ5	:= FWFormStruct(2,'FQ5',  {|x| x$ "FQ5_AS     FQ5_DEMAND"})
Local oStrFH2   := FWFormStruct(2,'FH2',  {|x| x$ "FH2_CODBEM"})
Local oModel    := FWLoadModel( "LOCA259K")

   oStrFH2:SetProperty("FH2_CODBEM", MVC_VIEW_CANCHANGE, .T.)

    // Seta o Modelo da View
    oView:SetModel( oModel )

	oView:CreateHorizontalBox( 'CAB', 50 )
	oView:CreateHorizontalBox( 'INFERIOR', 50 )

	oView:CreateFolder("PRINCIPAL", "INFERIOR")
	oView:AddSheet( 'PRINCIPAL'   , 'ITENS','A.S.' )   //"A.S. Bem" //
	oView:AddSheet( 'PRINCIPAL'   , 'BENSQ', STR0004 )   //"A.S. Bem Quanti" //"A.S. Bem Quantificavel" //"Bem Quantificavel"
	//
	oView:CreateHorizontalBox( 'BOXFQ5', 100,,, 'PRINCIPAL', 'ITENS')
	oView:CreateHorizontalBox( 'BOXFH2', 100,,, 'PRINCIPAL', 'BENSQ' )
	
    oView:AddField("VIEW_MASTER",oStrFQt,"FQTMASTER")
	oView:AddGrid("VIEWFQ5" ,oStrFQ5,"FQ5PAT")
	oView:AddGrid("VIEWFH2"  ,oStrFH2 ,"FH2QTD")

	oView:SetOwnerView('VIEW_MASTER', 'CAB') 
	oView:SetOwnerView('VIEWFQ5', 'BOXFQ5')
	oView:SetOwnerView('VIEWFH2', 'BOXFH2')

Return oView

/*/{Protheus.doc} LOCA259KAS
Valida o codigo da AS informado no romaneio
@type function
@version 25.10
@author Alexandre Circenis
@since 22/07/2026
@return variant, Retorna .T. se a AS informada estaive valida
/*/
FUNCTION LOCA259KAS()
Local lRet := .T.
Local aArea := {GetArea()}
Local oModel   := FWModelActive()
Local oMaster := oModel:GetModel( 'FQTMASTER' )
Local oGrdFH2 := oModel:GetModel('FH2QTD')
Local nX

    FQ5->(dbSetOrder(9))
    if !FQ5->(dbSeek(xFilial("FQ5")+M->FQ5_AS))
        oModel:SetErrorMessage("","","","","LOCA259K_01",STR0005,)  //"A.S. não encontrada, confira os itens do contrato."
	    lRet := .F.
    elseif FQ5->(FQ5_SOT+FQ5_OBRA) <> M->FQT_PROJET+M->FQT_OBRA
        oModel:SetErrorMessage("","","","","LOCA259K_02",STR0006,)  //"A.S. informada inválida, não está definida para o projeto e obra informados."
	    lRet := .F.
    elseif !Empty(FQ5->FQ5_DEMAND)
        oModel:SetErrorMessage("","","","","LOCA259K_03",STR0007+FQ5->FQ5_DEMAND,)  //"A.S. informada já se encontra na demanda "
	    lRet := .F.
    else
        Aadd(aArea, FPA->(GetArea()))
        FPA->(dbSetOrder(2))
        FPA->(dbSeek(xFilial("FPA")+M->FQT_PROJET+M->FQT_OBRA+M->FQ5_AS))
        if !Empty(FPA->FPA_NFREM) 
            oModel:SetErrorMessage("","","","","LOCA259K_04",STR0008,)  //"A.S. informada já tem nota de remessa."
	        lRet := .F.
        endif

        if lRet 
            Aadd(aArea, FQ3->(GetArea()))
            FQ3->(dbSetOrder(3))
            if FQ3->(dbSeek(xFilial("FQ3")+M->FQ5_AS))
                oModel:SetErrorMessage("","","","","LOCA259K_05",STR0009,)  //"A.S. informada já foi informada no romaneio antigo."
	            lRet := .F.
            endif
        endif
    endif

    // Verifica se o Produto é um Bem Quantificavel
    if lRet

        oMaster:SetValue( "FQT_ITENS" , FwFldGet("FQT_ITENS") + 1, .F. )
        oMaster:SetValue( "FQT_QTDPRO", FwFldGet("FQT_QTDPRO") + FQ5->FQ5_XQTD, .F. )
        oMaster:SetValue( "FQT_QTD2"  , FwFldGet("FQT_QTD2")   + FQ5->FQ5_QTD2, .F. )
        if FQ5->FQ5_STATUS = '6'
            oMaster:SetValue( "FQT_SEPARA", FwFldGet("FQT_SEPARA") + FQ5->FQ5_XQTD, .F. )
        else
            oMaster:SetValue( "FQT_PENDEN", FwFldGet("FQT_PENDEN") + FQ5->FQ5_XQTD, .F. )
        endif
        

        if LOCXITU28( FQ5->FQ5_XPROD)
            oGrdFH2:SetNoInsertLine(.F.)
            oGrdFH2:SetNoUpdateLine(.F.)
        else
            oGrdFH2:SetNoInsertLine(.T.)
            oGrdFH2:SetNoUpdateLine(.T.)

        endif
    endif

    for nX := Len(aArea) to 1 step -1
        RestArea(aArea[nX])
    next

Return lRet

/*/{Protheus.doc} LOCA259KFH2
Valida o bem quantaifcavel informado na demanda
@type function
@version 25.10
@author Alexandre Circenis
@since 22/07/2026
@return variant, Retorna .t. se o o bem informado for valido
/*/
FUNCTION LOCA259KFH2()
Local lRet := .T.
Local aArea := {GetArea()}
Local oModel   := FWModelActive()
Local oGrdFQ5 := oModel:GetModel('FQ5PAT')
Local cProduto
Local nX

    FQ5->(dbSetOrder(9))
    FQ5->(dbSeek(xFilial("FQ5")+oGrdFQ5:GetValue("FQ5_AS")))
    cProduto := FQ5->FQ5_XPROD
    if !LOCXITU28( cProduto) // Verifica se produto é um bem quantificavel
        oModel:SetErrorMessage("","","","","LOCA259K_11",STR0010,)  //"Produto da Demanda não é bem quantificavel e não poderá ter bem informado."
	    lRet := .F.
    else // Valida o bem
        Aadd( aArea , ST9->(GetArea()))
        ST9->(dbSetOrder(1))
	    if !ST9->(dbSeek(xFilial("ST9")+ Padr(Alltrim(M->FH2_CODBEM), TamSx3("T9_CODBEM")[1]))) // Bem
		    lRet := .F.
			Help(" ",1,"LOCA259K_12",, STR0011,1,0)  //"Código não encontrato na tabelas de Bens." //"Código do bem informado não encontrado no cadstro de bens (ST9)!"
	    	ST9->(dbSetOrder(1))
	    elseif ST9->T9_CODESTO <> cProduto  // O produto do bem não é igual ao da Grid
		    lRet := .F.
		    Help(" ",1,"LOCA25K_13",, STR0012,1,0)   //"O produto associado a bem informado não corresponde ao produto selecionado na grid superior." //"O produto associado a bem informado não corresponde ao produto selecionado na grid de itens da demanda."
    	elseif !ST9->T9_STATUS $ LOCA00194() 
	    	lRet := .F.
		    Help(" ",1,"LOCA259K_14",, STR0013,1,0)    //"O bem informado não está com o status disponivel."
    	elseif !Loca259EVA(ST9->T9_CODBEM)
	    	lRet := .F.
    	endif

	endif
    for nX := Len(aArea) to 1 step -1
        RestArea(aArea[nX])
    next

Return lRet

/*/{Protheus.doc} LOCA259KGR
Grava os dados que não estão no model
@type function
@version 25.10
@author Alexandre Circenis
@since 22/07/2026
@param oModel, object, Objeto model que será gravado
@return variant, Retorna .t. se a gravação for bem sucedida 
/*/
Static Function LOCA259KGR(oModel)
Local lRet         := .T.
Local oModelFQT    := oModel:GetModel("FQTMASTER")
Local oModelFQ5    := oModel:GetModel("FQ5PAT")
Local oModelFH2    := oModel:GetModel("FH2QTD")
Local nLFQ5        := 0
Local nLFH2        := 0
Local cDemanda     := oModelFQT:GetValue("FQT_DEMAND")
if oModel:VldData()
    Begin TRANSACTION 
        // 1. Gravação padrão da tabela Master (FQT) usando o comando interno do MVC

        lRet := FWFormCommit(oModel)

        if lRet
            // 2. Processamento da FQ5 (Grid de Itens já preenchidos)
            For nLFQ5 := 1 To oModelFQ5:Length()
                oModelFQ5:GoLine(nLFQ5)
                
                // Ignora linhas deletadas visualmente pelo usuário se houver
                If oModelFQ5:IsDeleted()
                    Loop
                EndIf
                
                FQ5->(dbSetOrder(9))
                FQ5->(dbSeek(xFilial("FQ5")+oModelFQ5:GetValue("FQ5_AS")))
                RecLock("FQ5",.F.)
                FQ5->FQ5_DEMAND :=  cDemanda
                FQ5->FQ5_STDEMA := IF(FQ5->FQ5_STATUS = '6' ,'2','1')
                FQ5->(msUnLock())

                // 3. Processamento da FH2 (Sub-itens vinculados à linha atual da FQ5)
                // O MVC posiciona automaticamente o grid filho (FH2) de acordo com a linha ativa do pai (FQ5)
                For nLFH2 := 1 To oModelFH2:Length()
                    oModelFH2:GoLine(nLFH2)
                    
                    // Verifica se a linha do sub-item está vazia ou deletada
                    If oModelFH2:IsDeleted() .Or. Empty(oModelFH2:GetValue("FH2_CODBEM"))
                        Loop
                    EndIf
                    if LocxItu30K(oModelFH2:GetValue("FH2_CODBEM"), "10")
                        // Como é um processo de inclusão customizado para a FH2, inserimos via RecLock
                        FH2->(RecLock("FH2", .T.))
                        FH2->FH2_FILIAL := xFilial("FH2")
                        FH2->FH2_AS     := FQ5->FQ5_AS
                        FH2->FH2_CONTRA := FQ5->FQ5_SOT
                        FH2->FH2_OBRA   := FQ5->FQ5_OBRA"
                        FH2->FH2_PROD   := FQ5->FQ5_XPROD"
                        FH2->FH2_CODBEM := oModelFH2:GetValue("FH2_CODBEM")
                        FH2->FH2_ROMREM := FQ5->FQ5_XROMAN
                        FH2->(MsUnLock())
                    else
                        DisarmTransaction()
                    endif
                Next nLFH2
                
            Next nLFQ5
        EndIf

    END TRANSACTION
endif

Return lRet
/*/{Protheus.doc} LOCA259KTO
Validação "TUDO OK" do model
@type function
@version 25.10
@author Alexandre Circenis
@since 22/07/2026
@param oModel, object, Objeto Model que será validado
@return variant, Retorna .T. se o model for validado
/*/
Function LOCA259KTO(oModel)
Local lRet         := .T.
Local oModelFQ5    := oModel:GetModel("FQ5PAT")
Local oModelFH2    := oModel:GetModel("FH2QTD")
Local nLFQ5        := 0


// Valida se todas as linhas da FQ5 Separadas que são BM_XACESS = '3'
// tem a quantidade correta de bems informados na FH2

for nLFQ5 := 1 to oModelFQ5:Length()

    oModelFQ5:GoLine(nLFQ5) // Vai para a linha da FQ5

    FQ5->(dbSetOrder(9))
    FQ5->(dbSeek(xFilial("FQ5")+oModelFQ5:GetValue("FQ5_AS")))
    
    if LOCXITU28( FQ5->FQ5_XPROD) // se tiver acessório verificar se o tamanho corresponde a quantidade da FQ5

        if oModelFH2:Length() <> FQ5->FQ5_XQTD
            lRet := .F.
		    Help(" ",1,"LOCA259K_21",, STR0015+AllTrim(oModelFQ5:GetValue("FQ5_AS"))+STR0014+; //" foram informados " //"Para A.S. "
            AllTrim(Str(oModelFH2:Length()))+ STR0016+ AllTrim(Str(FQ5->FQ5_XQTD)),1,0) //" bens e na A.S. foi informado "
        elseif Empty(oModelFH2:GetValue("FH2_CODBEM"))
            lRet := .F.
		    Help(" ",1,"LOCA259K_22",, STR0015+Alltrim(oModelFQ5:GetValue("FQ5_AS"))+STR0017,1,0) //" a lista de Bens está vazia " //"Para A.S. "
        endif

    endif

next

Return lRet

/*/
*****  Exemplo de Execauto da rotina de DEMANDA
Function ExeLoca259()
Local oModel := FWLoadModel("LOCA259K") // Ex: MATA020, MATA010
Local aErros := {}
Local cRet := ''
    
    // Define a operação (ex: Inclusão)
    oModel:SetOperation(MODEL_OPERATION_INSERT) // MODEL_OPERATION_UPDATE para alterar
    
    // Ativa o model para iniciar a carga de dados
    oModel:Activate()
    
    // Preenche o Master (Cabeçalho)
    oModel:GetModel("FQTMASTER"):SetValue( "FQT_DESC", "TESTE DE EXECAUTO")
    oModel:GetModel("FQTMASTER"):SetValue( "FQT_PROJET", "202600339")
    oModel:GetModel("FQTMASTER"):SetValue( "FQT_OBRA", "001")
    
    // Se a rotina tiver itens, preenche o Detail

    if oModel:SetValue("FQ5PAT", "FQ5_AS", "3000339001009D MG 01       ")

        if oModel:GetModel("FH2QTD"):SetValue( "FH2_CODBEM", "BEMMNT030") 
            oModel:GetModel("FH2QTD"):AddLIne()
            IF oModel:GetModel("FH2QTD"):SetValue( "FH2_CODBEM", "BEMMNT032") 
                oModel:GetModel("FH2QTD"):AddLIne()
                IF oModel:GetModel("FH2QTD"):SetValue( "FH2_CODBEM", "BEMMNT033") 

                EndIf
            EndIf
        EndIf    
    endif

    // Executa a validação e gravação
    If oModel:VldData()
        oModel:CommitData()
        cRet += "Registro gravado com sucesso!"
    Else
        // A estrutura do vetor com erro é:
			// [1] identificador (ID) do formulário de origem
			// [2] identificador (ID) do campo de origem
			// [3] identificador (ID) do formulário de erro
			// [4] identificador (ID) do campo de erro
			// [5] identificador (ID) do erro
			// [6] mensagem do erro
			// [7] mensagem da solução
			// [8] Valor atribuído
			// [9] Valor anterior
        aErros := oModel:GetErrorMessage()
        if !Empty(aErros[4]) .or. !Empty(aErros[8]) // Erro em um campo
            cRet += "Campo: " + aErros[4]+" Valor: "+aErros[8]
        endif
        cRet += "erro "+aErros[5]+" - "+aErros[6]

    EndIf
    
   	oModel:DeActivate()
	oModel:Destroy()
	oModel := NIL
    
Return cRet
/*/

/*/{Protheus.doc} LocxItu30
Define um novo status para um bem
@type function
@version 25.10
@author Alexandre Circenis
@since 09/01/2026
@param cCodBem   , character, Codigo do bem
@param cNewStatus, character, Novo status Rental para o bem
00 - Disponivel
10 - Contrato Gerado
20 - Remessa Gerada
50 - Retorno de Locação
60 - NF de Retorno gerada
70 - Manutenção
90 - Em parceiro
@return variant, .T. se a combinação já tiver sido utilizada
/*/
Function LocxItu30K(cCodBem, cNewStatus)
Local aArea := GetArea()
Local lRet := .F.

    ST9->(dbSetOrder(1))
	ST9->(dbSeek(xFilial("ST9")+cCodBem))
	FQD->(dbSetOrder(1))
	if FQD->(DBSEEK(XFILIAL("FQD")+ cNewStatus))
		LOCXITU21(ST9->T9_STATUS, FQD->FQD_STATQY, FPA->FPA_PROJET, "", "", ,cNewStatus)
		RecLock("ST9",.F.)
		ST9->T9_STATUS := FQD->FQD_STATQY
		ST9->(MSUNLOCK())
        lRet := .T.
	endif

    RestArea(aArea)

Return lRet
