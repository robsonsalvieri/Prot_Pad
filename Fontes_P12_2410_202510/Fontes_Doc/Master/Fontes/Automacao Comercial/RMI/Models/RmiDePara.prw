#INCLUDE 'PROTHEUS.CH'
#INCLUDE 'FWMVCDEF.CH'
#INCLUDE 'RMIDEPARA.CH'


//--------------------------------------------------------
/*/{Protheus.doc} RmiDePara
Cadastro de De/Para da integração RMI

@param      Nao ha
@author  	Varejo
@version 	1.0
@since      16/09/2019
@return	    Nao ha
/*/
//--------------------------------------------------------
Function RmiDePara()
Local oBrowse := Nil

If AmIIn(12)// Acesso apenas para modulo e licença do Varejo
    oBrowse := FWMBrowse():New()
    oBrowse:SetAlias('MHM')
    oBrowse:SetDescription(STR0006) //"De/Para de Integração"
    oBrowse:Activate()
else
    MSGALERT( STR0009)//"Esta rotina deve ser executada somente pelo módulo 12 (Controle de Lojas)"
EndIf

Return Nil


//--------------------------------------------------------
/*/{Protheus.doc} RmiDePara
Funcao de definição do aRotina

@param      Nao ha
@author  	Varejo
@version 	1.0
@since      16/09/2019
@return	    Nao ha
/*/
//--------------------------------------------------------
Static Function MenuDef() 
Local aRotina:= {} //Array com os menus disponiveis

ADD OPTION aRotina Title STR0001 Action 'PesqBrw'           OPERATION 1 ACCESS 0 //"Pesquisar"
ADD OPTION aRotina Title STR0002 Action 'VIEWDEF.RmiDePara' OPERATION 2 ACCESS 0 //"Visualizar"
ADD OPTION aRotina Title STR0003 Action 'VIEWDEF.RmiDePara' OPERATION 3 ACCESS 0 //"Incluir"  
ADD OPTION aRotina Title STR0004 Action 'VIEWDEF.RmiDePara' OPERATION 4 ACCESS 0 //"Alterar" 
ADD OPTION aRotina Title STR0005 Action 'VIEWDEF.RmiDePara' OPERATION 5 ACCESS 0 //"Excluir"
							
Return aRotina

//--------------------------------------------------------
/*/{Protheus.doc} ModelDef
MVC - Camada de modelo de dados

@param      Nao ha
@author  	Varejo
@version 	1.0
@since      16/09/2019
@return	    Nao ha
/*/
//--------------------------------------------------------
Static Function ModelDef()  

Local oStruCab 	:= FWFormStruct( 1, 'MHM',{|cCampo| !(AllTrim(cCampo) $ "MHM_VLORIG|MHM_VLINT|MHM_FILINT")}) //Estrutura do Modelo de Dados Cabecalho
Local oStruGrd  := FWFormStruct( 1, 'MHM',{|cCampo| AllTrim(cCampo) $ "MHM_VLORIG|MHM_VLINT|MHM_FILINT"}) //Estrutura do Modelo de Dados Grid

Local oModel	:= MPFormModel():New('RmiDePara',{|| .T. },{|oModel| RmiPreVld(oModel) }) //Modelo de dados

oModel:SetDescription(STR0007)	//"Modelo de Dados De/Para de Integracoes"

//Definicoes do FormFields
oModel:AddFields( "MHMMASTER", Nil  , oStruCab)
oModel:AddGrid("MHMDETAILS","MHMMASTER",oStruGrd)

oModel:SetPrimaryKey( {'MHM_FILIAL','MHM_SISORI','MHM_TABELA','MHM_CAMPO','MHM_VLORIG','MHM_FILINT','MHM_VLINT'} ) //Obrigatorio setar a chave primaria (mesmo que vazia)

//O metodo SetRelation recebe os campos do cabecalho
oModel:SetRelation('MHMDETAILS',{{'MHM_FILIAL','xFilial("MHM")'},{'MHM_SISORI','MHM_SISORI'},{'MHM_TABELA','MHM_TABELA'},{'MHM_CAMPO','MHM_CAMPO'}},MHM->(IndexKey(1)))
oModel:GetModel("MHMDETAILS"):SetUniqueLine({'MHM_VLORIG','MHM_VLINT','MHM_FILINT'})

Return oModel


//--------------------------------------------------------
/*/{Protheus.doc} ViewDef
MVC - Camada de visualização de dados

@param      Nao ha
@author  	Varejo
@version 	1.0
@since      16/09/2019
@return	    Nao ha
/*/
//--------------------------------------------------------
Static Function ViewDef()

Local oModel    := FWLoadModel( 'RmiDePara' )  	// Modelo de Dados baseado no ModelDef do fonte informado
Local oStruCab 	:= FWFormStruct( 2, 'MHM',{|cCampo| !(AllTrim(cCampo) $ "MHM_VLORIG|MHM_VLINT|MHM_FILINT")}) //Estrutura do Modelo de Dados Cabecalho
Local oStruGrd  := FWFormStruct( 2, 'MHM',{|cCampo| AllTrim(cCampo) $ "MHM_VLORIG|MHM_VLINT|MHM_FILINT"}) //Estrutura do Modelo de Dados Grid
Local oView     := FWFormView():New()			// Objeto de visualizacao                  

oView:SetModel( oModel )     

//Definicoes do FormFields com os dados do cartao selecionado
oView:AddField( 'MASTER_MHM' , oStruCab, 'MHMMASTER' )
oView:AddGrid('DETAILS_MHM',oStruGrd,'MHMDETAILS') 

//Cria os Box's
oView:CreateHorizontalBox('CABEC',20)
oView:CreateHorizontalBox('GRID',80)

//Associa os componentes
oView:SetOwnerView('MASTER_MHM','CABEC')
oView:SetOwnerView('DETAILS_MHM','GRID')

Return oView      


//--------------------------------------------------------
/*/{Protheus.doc} RmiPreVld
Funcao responsavel em fazer a validacao dos dados digitados
para saber se alguma linha do grid ja existe cadastrado na 
base ou nao.

@param      Nao ha
@author  	Varejo
@version 	1.0
@since      16/09/2019
@return	    Nao ha
/*/
//--------------------------------------------------------
Function RmiPreVld(oModel)

Local lRet          := .T. //Variavel de retorno
Local nOperation	:= oModel:GetOperation() //Operacao executada no modelo de dados.
Local oCab          := oModel:GetModel('MHMMASTER') //Model do cabecalho
Local oItens        := oModel:GetModel('MHMDETAILS') //Model dos itens
Local aArea         := GetArea('MHM') //Guarda a area
Local nX            := 0 //Variavel de loop

If nOperation == MODEL_OPERATION_INSERT
    MHM->(dbSetOrder(1)) //MHM_FILIAL+MHM_SISORI+MHM_TABELA+MHM_CAMPO+MHM_VLORIG+MHM_FILINT+MHM_VLINT
    For nX := 1 To oItens:Length()
        oItens:GoLine(nX)
        If !oItens:IsDeleted()
            If MHM->(dbSeek(xFilial('MHM')+oCab:GetValue('MHM_SISORI')+oCab:GetValue('MHM_TABELA')+oCab:GetValue('MHM_CAMPO')+oItens:GetValue('MHM_VLORIG')+oItens:GetValue('MHM_FILINT')+oItens:GetValue('MHM_VLINT')))
                lRet := .F.
                Exit
            EndIf
        EndIf
    Next nX

    If !lRet 
        MsgAlert(STR0008) //"Registro já existe cadastrado na base!"
    EndIf
EndIf

RestArea(aArea)

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} RmiDePaGrv
Função utilizada para efetuar a manutenção no cadastro de De\Para
Inclusão e Exclusão

@author
@version 1.0
/*/
//-------------------------------------------------------------------
Function RmiDePaGrv(cSisOri  , cTabela, cCampo, cChaveExt, cChaveInt,;
                    lInclusao,cUuIdOri)

    Local lExiste := .F.
    Local lUIDORI       := MHM->(ColumnPos("MHM_UIDORI" )) > 0       

    Default  cSisOri    := ""
    Default  cTabela    := ""
    Default  cCampo     := ""
    Default  cChaveExt  := ""
    Default  cChaveInt  := ""
    Default  lInclusao  := .T.
    Default  cUuIdOri   := ""

    MHM->( DbSetOrder(4) )  //MHM_FILIAL + MHM_SISORI + MHM_TABELA + MHM_VLORIG
    lExiste := MHM->( DbSeek(xFilial("MHM") + PadR(cSisOri, TamSx3("MHM_SISORI")[1]) + PadR(cTabela, TamSx3("MHM_TABELA")[1]) + cChaveExt) )
    
    If lInclusao

        If !lExiste
            RecLock("MHM", .T.)

                MHM->MHM_FILIAL := xFilial("MHM")
                MHM->MHM_SISORI := cSisOri
                MHM->MHM_TABELA := cTabela
                MHM->MHM_CAMPO  := cCampo
                MHM->MHM_VLORIG := cChaveExt
                MHM->MHM_FILINT := xFilial(cTabela)
                MHM->MHM_VLINT  := cChaveInt
                IIF(lUIDORI   , MHM->MHM_UIDORI  := cUuIdOri,)//Grava UUID Origem do De/para automatico.                
            MHM->( MsUnLock() )
        Else
            If MHM->MHM_TABELA == "SF1" .And. Alltrim(MHM->MHM_VLORIG) == Alltrim(cChaveExt) .And. Empty(MHM->MHM_VLINT)
               RecLock("MHM", .F.)
                    MHM->MHM_FILINT := xFilial(cTabela)
                    MHM->MHM_VLINT  := cChaveInt
                MHM->( MsUnLock() )   
                LjGrvLog("RmiDePaGrv","[AltDePara] Atualizando o Registro ->",{MHM->MHM_SISORI,MHM->MHM_TABELA,MHM->MHM_CAMPO,MHM->MHM_VLORIG,MHM->MHM_UIDORI})
            Endif
        EndIf

    Else
        If lExiste .AND. !Empty(MHM->MHM_UIDORI)
            RecLock("MHM", .F.)
                MHM->( DbDelete() )
            MHM->( MsUnLock() )            
            LjGrvLog("RmiDePaGrv","[DelDePara] Deletando o Registro ->",{MHM->MHM_SISORI,MHM->MHM_TABELA,MHM->MHM_CAMPO,MHM->MHM_VLORIG,MHM->MHM_UIDORI})
        Endif
    EndIf        

Return lExiste

//-------------------------------------------------------------------
/*/{Protheus.doc} RmiDePaRet
Alimenta o Atributo aArrayFil para controle de filial no processo.

@Param cSisOri        Sintema Origem exemplo Chef ou Live
@Param cAlias         exemplo SB1,SA1...
@Param cPesDePara     exemplo conteudo a ser pesquisado na MHM
@Param lOrigem        exemplo (.T. MHM_VLORIG) (.F. Retorna MHM_VLINT)
@author  Everson S. P. Junior
@version 1.0
/*/
//-------------------------------------------------------------------
Function RmiDePaRet(cSisOri, cAlias, cPesDePara, lOrigem)

    Local aArea     := GetArea() 
    Local aAreaMHM  := MHM->(GetArea())
    Local cRet      := ''

    default cSisOri     := ''
    default cAlias      := ''
    default cPesDePara  := ''
    default lOrigem     := .F.

    cSisOri := PadR(cSisOri,TamSx3('MHM_SISORI')[1])
    cAlias  := PadR(cAlias,TamSx3('MHM_TABELA')[1])

	//Retorna campo Origem da tabela De/para
    DbSelectArea("MHM")
    If lOrigem

        cPesDePara:= PadR(cPesDePara, TamSx3('MHM_VLINT')[1])

        MHM->(dbSetOrder(5))	//MHM_FILIAL+MHM_SISORI+MHM_TABELA+MHM_VLINT
        If MHM->(dbSeek( xFilial("MHM") + cSisOri + cAlias + cPesDePara) )
            cRet := RTrim(MHM->MHM_VLORIG)
        EndIf

	//Retorna campo Valor Integracao da tabela De/para
    Else
    
		cPesDePara:= PadR(cPesDePara, TamSx3('MHM_VLORIG')[1])
		
        MHM->(dbSetOrder(4))	//MHM_FILIAL+MHM_SISORI+MHM_TABELA+MHM_VLORIG
        If MHM->( dbSeek(xFilial("MHM") + cSisOri + cAlias + cPesDePara) )
            cRet := RTrim(MHM->MHM_VLINT)
        EndIf
    EndIf
    
    IF ExistBlock("RetDePFim")
        LjGrvLog("RMIDEPARA","Antes da execução do PE RetDePFim", {cSisOri,cAlias,cPesDePara,lOrigem,cRet} )
        cRet := ExecBlock("RetDePFim",.F.,.F., {cSisOri,cAlias,cPesDePara,lOrigem,cRet})
        LjGrvLog("RMIDEPARA","Depois da execução do PE RetDePFim", cRet)
    EndIf  
    
    RestArea(aAreaMHM)
    RestArea(aArea)
Return cRet


//-------------------------------------------------------------------
/*/{Protheus.doc} RmixGetCat()
Função responsável por retornar a categoria do produto e fazer o de/para
da categoria com o que foi cadastrado no sistema de origem.

@author		Bruno Almeida
@version	P12
@since		21/03/2020
@return		Codigo da categoria do sistema de origem
/*/
//-------------------------------------------------------------------
Function RmixGetCat(cCodProd, cCodGrupo, cSisOri)
	Local aRet			:= {}
    Local nCatRet       := 0
    Local nSubCatRet    := 0
	Local aArea			:= GetArea()
	Local lPorProdut	:= .F.
	Local lPorGrupo		:= .F.
	Local cCategory		:= ""
	Local cACUFil		:= xFilial("ACU")
	Local cACVFil		:= xFilial("ACV")
	Local nCont			:= 0

    Default cCodProd    := ""
    Default cCodGrupo   := ""
    Default cSisOri     := "CHEF"           //Default CHEF para manter o legado, porque esta função é utilizada no layout do CHEF - retirar futuramente

    LjGrvLog("BUSCA_CATEGORIA", "Retorna categoria e sub-categoria, parametros de entrada: [cCodProd, cCodGrupo, cSisOri]", {cCodProd, cCodGrupo, cSisOri} )
    
    ACU->(DBSetOrder(1)) //ACU_FILIAL+ACU_COD

    //Primeiro verifica se possui amarração por produto
    ACV->(DBSetOrder(5)) //ACV_FILIAL+ACV_CODPRO+ACV_CATEGO
    If ACV->(DBSeek( cACVFil + PadR(cCodProd,TamSx3("B1_COD")[1]) ))
        lPorProdut := .T.
        LjGrvLog( "BUSCA_CATEGORIA", "Encontrou informacao na tabela ACV com o conteudo do parametro cCodProd", cCodProd )
    Else
        LjGrvLog( "BUSCA_CATEGORIA", "Nao encontrou informacao na tabela ACV com o conteudo do parametro cCodProd", cCodProd )
    EndIf

    //Caso nao tenho sido encontrado por produto, verifica por grupo de produto
    If !lPorProdut .And. !Empty(cCodGrupo)
        ACV->(DBSetOrder(2)) //ACV_FILIAL+ACV_GRUPO+ACV_CODPRO+ACV_CATEGO
        If ACV->(DBSeek( cACVFil + PadR(cCodGrupo,TamSx3("B1_GRUPO")[1]) ))
            lPorGrupo := .T.
            LjGrvLog( "BUSCA_CATEGORIA", "Encontrou informacao na tabela ACV com o conteudo do parametro cCodGrupo", cCodGrupo )
        Else
            LjGrvLog( "BUSCA_CATEGORIA", "Nao encontrou informacao na tabela ACV com o conteudo do parametro cCodGrupo", cCodGrupo )
        EndIf
    EndIf

    If lPorProdut .Or. lPorGrupo

        cCategory := ACV->ACV_CATEGO //Mais baixo nivel de categoria

        While (!Empty(cCategory))

            If ACU->(DBSeek( cACUFil + cCategory ))
                nCont++

                aAdd(aRet, { nCont, cACUFil, ACU->ACU_COD, AllTrim(ACU->ACU_DESC), ACU->ACU_CODPAI } )

                cCategory := ACU->ACU_CODPAI //Busca a categoria do pai

            Else
                cCategory := ""
            EndIf
        End

        //Ordena o contador do maior para menor (para que seja do maior (pai) nivel para mais baixo nivel (filhas/netas) da categoria)
        aSort(aRet,,,{|x,y| x[1]>y[1]})
        LjGrvLog( "BUSCA_CATEGORIA", "Conteudo do array aRet", aRet )

    EndIf

    If Len(aRet) == 1
        nCatRet     := IIF(cSisOri=="CHEF",RmiDePaRet(cSisOri, "ACU", xFilial("ACU") + "|" + aRet[1][3], .T.),aRet[1][3])
        nSubCatRet  := IIF(cSisOri=="CHEF",'0',"")
    ElseIf Len(aRet) > 1
        nCatRet     := IIF(cSisOri=="CHEF",RmiDePaRet(cSisOri, "ACU", xFilial("ACU") + "|" + aRet[1][3], .T.) ,aRet[1][3])                   
        nSubCatRet  := IIF(cSisOri=="CHEF",RmiDePaRet(cSisOri, "ACU", xFilial("ACU") + "|" + aRet[Len(aRet)][3], .T.),aRet[Len(aRet)][3])
    EndIf

    LjGrvLog( "BUSCA_CATEGORIA", "Conteudo da variavel nCatRet", nCatRet )
    LjGrvLog( "BUSCA_CATEGORIA", "Conteudo da variavel nSubCatRet", nSubCatRet )

    If cSisOri=="CHEF"
        If Empty(nCatRet) .AND. Empty(nSubCatRet)
            nCatRet := 0
            nSubCatRet := 0
        Else
            If !Empty(nCatRet)
                
                nCatRet := Val(nCatRet)

                If !Empty(nSubCatRet)
                    nSubCatRet := Val(nSubCatRet)
                EndIf
                
            EndIf
        EndIf
    
    ElseIf cSisOri == "MOTOR PROMOCOES" //Sempre retorna na posição 1 Subcategoria para o produto MOTOR PROMOÇOES.
        If !Empty(nSubCatRet)
            nCatRet := nSubCatRet 
        EndIf   
    EndIf
    RestArea(aArea)

Return {nCatRet, nSubCatRet}


//-------------------------------------------------------------------
/*/{Protheus.doc} RmiDePaAut
Verifica se a tabela tem regra para criar Depara automatico
Caso tenha cria e valida com retorno do de/para

@Param cSisOri        Sintema Origem exemplo Chef ou Live
@Param cAlias         exemplo SB1,SA1...
@Param cPesDePara     exemplo conteudo a ser pesquisado na MHM
@Param lOrigem        exemplo (.T. MHM_VLORIG) (.F. Retorna MHM_VLINT)

@author Rafael Pessoa
@version 1.0
/*/
//-------------------------------------------------------------------
Function RmiDePaAut(cSisOri, cAlias, cPesDePara, lOrigem)

    Local cRet      := ""

    Default cSisOri     := ''
    Default cAlias      := ''
    Default cPesDePara  := ''
    Default lOrigem     := .F.

    Do Case
        //Geração Automática De/Para forma de pagamento para LIVE
        Case  Upper(AllTrim(cAlias)) == "SX5" .And. Upper(AllTrim(cSisOri)) == "LIVE"            
            cRet := DePaLive(cAlias, cPesDePara, lOrigem)

        //Retorna vazio quando nao tem tratamento
        OTherWise
            cRet := ""
            
    End Case

Return cRet


//-------------------------------------------------------------------
/*/{Protheus.doc} DePaLive
Cadastra De/Para Automáticos Exclusivos do Live

@Param cAlias         exemplo SB1,SA1...
@Param cPesDePara     exemplo conteudo a ser pesquisado na MHM
@Param lOrigem        exemplo (.T. MHM_VLORIG) (.F. Retorna MHM_VLINT)

@author Rafael Pessoa
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function DePaLive(cAlias, cPesDePara, lOrigem)

    Local aArea     := GetArea() 
    Local cRet      := ""
    Local cValInt   := ""
    
    Default cAlias      := ''
    Default cPesDePara  := ''
    Default lOrigem     := .F.

    cAlias      := Upper(AllTrim(cAlias)) 
    cPesDePara  := Upper(AllTrim(cPesDePara)) 

    Do Case

        Case  cAlias = "SX5" //Forma de Pagamento
            
            Do Case
                Case  cPesDePara == "1"  //Dinheiro
                    cValInt := "R$"

                Case  cPesDePara $ "2|3" //Cheque
                    cValInt := "CH"

                Case  cPesDePara == "80" //Cartão Débito
                    cValInt := "CD"

                Case  cPesDePara == "81" //Cartão Crédito
                    cValInt := "CC"
            End Case

            If !Empty(cValInt)
                //Grava De/Para
                RmiDePaGrv( "LIVE", "SX5", "X5_TABELA ", cPesDePara, xFilial("SX5") + "|24|" + cValInt ) 
                //Busca novamente De/Para apos inclusao automática
                cRet := RmiDePaRet("LIVE", cAlias, cPesDePara , lOrigem)
            EndIf
               
    End Case

    RestArea(aArea)

Return cRet
