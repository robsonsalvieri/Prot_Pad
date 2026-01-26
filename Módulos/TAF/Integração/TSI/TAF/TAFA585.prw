#INCLUDE "PROTHEUS.CH" 
#INCLUDE "TOPCONN.CH"
#INCLUDE "FWMVCDEF.CH"

Static lV80AliE := V80->( FieldPos("V80_ALIERP") ) > 0

/*----------------------------------------------------------------------
{Protheus.doc} WsTSIProc()
Funcao responsável iniciar o processamento do Post ou Put da apuração ICMS
@param oBjWS, objeto, Json do cadastro mvc
@param lERP, lógico, indica se o cadastro veio do ERP ou de fora
@param oHashPai, objeto, objeto do cadastro pai

@author Karen Honda
@since 15/07/2021
@return Nil, nulo, não tem retorno. 
//----------------------------------------------------------------------*/
Function WsTSIProc( oBjWS, lERP, oHashPai, cUltStmp, aREGxV80 )

Local cJsonResp  := ""
Local cFilProc   := ""
Local xRet       := Nil
Local oBjJson    := JsonObject():New() // Requisição
Local oJsonResp	 := JsonObject():New() // retorno
Local nQtd       := 0
Local nAte       := 0
Local aRetJs     := {}
Local cKey       := ''

Local oModel     := Nil
Local cArea      := ""   
Local nOrder     := 0
Local cSource    := ""
Local cTagId     := ""
Local lDelTsiMov := .T.

Default oBjWS    := Nil 
Default lERP     := .F.
Default oHashPai := Nil
Default cUltStmp := ''
Default aREGxV80 := {}

If lERP
    oBjJson := oBjWS
elseIf VldExecute( oBjWS:sourceBranch, @oJsonResp, @cFilProc )
    cBody := oBjWS:GetContent( )
    xRet := oBjJson:fromJSON( cBody ) // quando xRet nulo eh sucesso no parser
endIf

hmget( oHashPai, "a_r_e_a_"    , @cArea    )
hmget( oHashPai, "o_r_d_e_r_"  , @nOrder   ) 
hmget( oHashPai, "s_o_u_r_c_e_", @cSource  )
hmget( oHashPai, "t_a_g_i_d_"  , @cTagId   )
hmget( oHashPai, "k_e_y_"      , @cKey     )

If ValType(xRet) == "U" .And. ValType( oBjJson[cTagId] ) == 'A'  //JsonObject populado com sucesso
    nAte := len( oBjJson[cTagId] )

    DbSelectArea("V5R")
    V5R->(DbSetOrder(1)) //V5R_FILIAL, V5R_CODFIL, V5R_ALIAS, V5R_REGKEY

    DbSelectArea(cArea)
    (cArea)->(DbSetOrder(nOrder)) 

    oModel  := FwLoadModel( cSource ) //Carrego modelo fora do laco
    TAFConOut( "TSILOG00017 Inicio " +time()+ ": Cadastro do model " + cSource)
    lDelTsiMov := .T. //Devido a integração da apuração de CPRB, controle através dessa variavel se será executada a função DelTsiMov
    for nQtd := 1 to nAte
        if nQtd == 1
            oJsonResp[cTagId] := {}
            if cArea == 'C1G' .or. cArea == 'C1H'
                lDelTsiMov := .F.
            endif
        else
            if cArea == 'C5M'
                lDelTsiMov := .F. //Atribuo false pois o movimento no periodo a ser integrado já foi excluido da C5M quando nQtd == 1
            endif
        endif
        WsTSIPutPost( oBjJson[cTagId][nQtd], @aRetJs, @oJsonResp, @oModel,oHashPai, lDelTsiMov, @cUltStmp, @aREGxV80 )
    next nQtd

    SetErroJs(@oJsonResp, cTagId, @aRetJs,,'403') //Retorna possíveis erros que possam ter ocorrido na integração.
    TAFConOut( "TSILOG00018 Fim " +time()+ ": Cadastro do model " + cSource)
else //Erro de Estrutura
    SetErroJs( @oJsonResp,,,,'400' )
endIf

If !lERP
    cJsonResp := FwJsonSerialize( oJsonResp ) //Serializa objeto Json Apenas API
    oBjWS:SetResponse( cJsonResp )
endIf

Return Nil

/*----------------------------------------------------------------------
{Protheus.doc} WsTSIPutPost()
Funcao que efetua inclusao e alteracao do cadastro no mvc e seu respectivo filhos/netos.
@param aObjJson, array, array das propriedade pai do objeto Json 
@param aRetJs, array, com as informações se houve sucesso ou erro no cadastro
@param oJsonResp, objeto, Json para retorno de erro
@param oModel, objeto, modelo do cadastro pai
@param oHashPai, objeto, hash do cadastro pai

@author Karen Honda
@since 15/07/2021
@return Nil, nulo, não tem retorno. 
//----------------------------------------------------------------------*/
Static Function WsTSIPutPost(aObjJson, aRetJs, oJsonResp, oModel, oHashPai, lDelTsiMov, cUltStmp, aREGxV80)

Local nOpcao      := 0
Local cArea       := ''  
Local cKey        := ''
Local cKeySeek    := ''
Local cSeek       := ''
Local cWarning    := ''
Local lSucessItem := .T.
Local lFoundReg   := .F.
Local lSeek       := .F.
Local lProc       := .T.
Local lOk         := .T.
Local bAfter      := {|oModel,cID,cAlias| RunTrigger(oModel,cID,cAlias)}
Local nPosReg     := 0
Local cRegV80     := ''
Local cSource     := ''

Default aObjJson   := {}
Default aRetJs     := {}
Default oJsonResp  := Nil
Default oModel     := Nil
Default oHashPai   := Nil
Default lDelTsiMov := .T.
Default cUltStmp   := ''

hmget( oHashPai, "a_r_e_a_"    , @cArea    )
hmget( oHashPai, "k_e_y_"      , @cKeySeek )
hmget( oHashPai, "s_e_e_k_"    , @cSeek    )
hmget( oHashPai, "s_o_u_r_c_e_", @cSource  )

//Protecao para nao ocorrer erro na macroexecucao caso algum campo da chave nao seja enviado, o mesmo sera nulo e ocorrera falha nas conversoes, ex: DTOS(CTOD(null))
If FindFunction("VldChv"+cArea)
    cWarning := &("VldChv"+cArea+"(aObjJson)")
EndIf    
If Empty(cWarning) //caso nao encontre inconsistencias

    cKey := &cKeySeek //chave completa para utilizar na gravacao do log

    if cArea == 'C5M' .and. lDelTsiMov == .F.
        dbSelectArea("C5M")
        dbSetOrder(1)
        lFoundReg := C5M->(DbSeek(xFilial("C5M")+cKey))
        DBCloseArea()
        if lFoundReg
            lSucessItem := .F.
            cErro := "UNIQUELINE"
            cCodError := "A estrutura enviada fere a chave única da tabela. Verique os códigos repetidos."
            aadd(aRetJs, {lSucessItem,cKey,cErro,cCodError})
            putTsiV5r(cArea, cKey, @aRetJs, aObjJson["stamp"]) //Efetiva gravacao do erro, fora da transacao
            Return lSucessItem
        endif
    endif

    lSeek := &cSeek

	if lSeek .and. !(cArea) == 'C5M'
		nOpcao := MODEL_OPERATION_DELETE
	else
		nOpcao := MODEL_OPERATION_INSERT
	endIf

    if (cArea) == 'C1G'
        if lSeek //se achou ou altera ou exclui
            if aObjJson['opCancelation'] <> '5'     //Nao Exclui
                nOpcao := MODEL_OPERATION_UPDATE    //altera
            elseif aObjJson['opCancelation'] == '5' //5=Sim Exclui  
                //atualizar o C1G stamp antes de excluir?
                nOpcao := MODEL_OPERATION_DELETE    //exclui
                lProc := .F.                        //nao devera inserir apos exclusao
            endif
        else    //se nao achou ou inclui ou nao inclui
            if aObjJson['opCancelation'] == '5'     //5=Sim Exclui
                lOk := .F.                          //nao inclui
            elseif aObjJson['opCancelation'] <> '5' //Se nao encontrou e nao exclui entao inseri
                nOpcao := MODEL_OPERATION_INSERT    //inclui
            endif
        endIf
    elseif (cArea) == 'C1H'

        if lSeek .OR. DbSeek( xFilial('C1H') + SUBSTR(CKEY,1,1) + Padr(RTrim(aObjJson['code']) + RTrim(aObjJson['store']),60)) //se achou altera
            If aObjJson['stamp'] > C1H->C1H_STAMP
                nOpcao := MODEL_OPERATION_UPDATE
            Else 
                lOk := .F.
            EndIf
        else
            nOpcao := MODEL_OPERATION_INSERT    //inclui
        endif
    endif

    //Caso seja alteracao, apagamos os registros via MVC e inserimos o novo lote, pois no primeiro envio pode possuir x registros,
    //e no segundo envio x-y, podendo ficar ativos registros que o usuario nao deseja, alem da alteracao ficar mais custosa ao percorrer
    //todo o length em todas as grids com seekline. O risco do seek line falhar eh alto, pois pode nao ser enviado todas as tags que compoe a chave.
    if lOk
        BEGIN TRANSACTION    
            If nOpcao == MODEL_OPERATION_DELETE
                oModel:DeActivate()
                oModel:SetOperation( MODEL_OPERATION_DELETE )
                oModel:Activate()
                FwFormCommit( oModel )
                oModel:DeActivate()
                if lProc
                    nOpcao := MODEL_OPERATION_INSERT
                endif
            endIf
            if lProc
                //Em alguns layout, é necessário apagar registros anteriores ao registro atual
                if lDelTsiMov
                    DelTsiMov(cArea,oHashPai,aObjJson,@nOpcao)
                endif
                oModel:SetOperation( nOpcao )
                oModel:Activate( )

                GrvModel( @oModel, @aObjJson, @aRetJs, oHashPai, nOpcao, cKey, @lSucessItem, @cUltStmp )

                If lSucessItem //Retorno VldData
                    FwFormCommit( oModel,,bAfter )
                    aadd(aRetJs, {lSucessItem, cKey})
                    ClearV5R( cArea, cKey )
                else
                    DisarmTransaction() //Necessario caso ocorra alguma falha na alteracao, nao efetiva delecao do registro anterior.
                    putTsiV5r(cArea, cKey, @aRetJs, aObjJson["stamp"]) //Efetiva gravacao do erro, fora da transacao
                endIf

                if cSource == 'TAFA053' .and. lV80AliE//Participantes
                    cRegV80 := ''
                    if !empty( cKey )
                        cRegV80 := "C1H|" + iif( SubStr(AllTrim(cKey),1,1) == 'C', 'SA1', 'SA2' )
                        nPosReg := aScan( aREGxV80 , {|x| x[1] == cRegV80 } )
                        if nPosReg > 0
                            aREGxV80[nPosReg][2] := cUltStmp
                        endif
                    endif    
                endif    

                oModel:DeActivate( )
            endif

        END TRANSACTION
    endif
else
    lSucessItem := .F.
    cErro := "OBRIGAT"
    cCodError := "A(s) tag(s) não foram encontrada(s) e formam a chave da " + cArea + ", portanto devem ser enviadas "
    cCodError += cWarning
    aadd(aRetJs, {lSucessItem,cKey,cErro,cCodError})
    AgrupaErro( cKey, cErro, @aRetJs )
endIf

Return lSucessItem

/*----------------------------------------------------------------------
{Protheus.doc} GrvModel()
Gravacao do modelo completo, pai, filho, neto

@param oModel, objeto, modelo do cadastro pai
@param aObjJson, array, array das propriedade pai do objeto Json 
@param aRetJs, array, com as informações se houve sucesso ou erro no cadastro
@param oHashPai, objeto, hash do cadastro pai
@param nOperation, numerico, opção da operação no mvc
@param cKey, caracter, chave do registro a ser cadstrado
@param lSucessItem, lógico, se cadastrou com sucesso ou não

@author Karen Honda
@since 15/07/2021
@return Nil, nulo, não tem retorno.
//----------------------------------------------------------------------*/
Static function GrvModel( oModel, aObjJson, aRetJs, oHashPai, nOperation, cKey, lSucessItem, cUltStmp )
                
Local nlA       := 1
Local nlB       := 1
Local n1Sub     := 1

Local nAteA     := 0
Local nAteB     := 0
Local nAteSub   := 0
Local nAteSub2  := 0
Local cModel    := ''
Local cSource   := ''
Local cArea     := ''
Local nOrder    := ''
Local cKeySeek  := ''
Local cField    := ''   

Local cProp     := ''
Local lErro     := .T.
Local lAddFilho  := .T.
Local lExclFilho := .F.

Local aSubModel := {}
Local aSubModel2 := {}
Local ctagFilho := ""
Local cModelFilho := ""
Local oHashFilho := Nil
Local ctagNeto := ""
Local cModelNeto := ""
Local nPosNeto := 0
Local oHashNeto := Nil
Local cNewStamp := ''

Default oModel   := Nil
Default aObjJson := {}
Default aRetJs   := {}
Default oHashPai := Nil
Default nOperation := 0
Default cKey := ""
Default lSucessItem := .T.
Default cUltStmp := ''

hmget( oHashPai, "m_o_d_e_l_"      , @cModel    )
hmget( oHashPai, "s_o_u_r_c_e_"    , @cSource   )
hmget( oHashPai, "a_r_e_a_"        , @cArea     )
hmget( oHashPai, "o_r_d_e_r_"      , @nOrder    )
hmget( oHashPai, "k_e_y_"          , @cKeySeek  )

hmget( oHashPai, "s_u_b_m_o_d_e_l_", @aSubModel    )
hmget( oHashPai, "s_u_b_m_o_d_e_l_2", @aSubModel2   )

/*-----------------------------
|         Cabeçalho           |
------------------------------*/
TafIncReg( @oModel, aObjJson, oHashPai, @aRetJs, @lSucessItem, cModel, cKey )
if cArea == "C1G" .and. oModel:GetOperation() == MODEL_OPERATION_INSERT
    If hmget( oHashPai, "versao", @cField ) .and. !Empty(cField)
        If Empty( oModel:GetValue(cModel, cField) )
            oModel:LoadValue( cModel, cField, xFunGetVer() )
        EndIf    
    EndIf    
EndIf
//Guardo o stamp para retornar ao fonte TAFA573 e gravar na V80 (Data de corte)
cNewStamp := aObjJson["stamp"]                                         
if empty(cUltStmp) .Or. iif(FindFunction('TsiCompStamp'),TsiCompStamp(cNewStamp, cUltStmp),cNewStamp > cUltStmp)
   cUltStmp := cNewStamp
endif

If !lSucessItem
    lErro := lSucessItem 
EndIf
/*-----------------------------
|        FILHO                |
------------------------------*/
nAteSub := Len(aSubModel)
nAteSub2 := Len(aSubModel2)
If nAteSub > 0
    For n1Sub := 1 to nAteSub
        ctagFilho := aSubModel[n1Sub][2]
        cModelFilho := aSubModel[n1Sub][1]
        cHashFilho  := aSubModel[n1Sub][3]
        nAteA := 0
        If valtype( aObjJson[ctagFilho] ) == 'A'
            nAteA := len( aObjJson[ctagFilho] )
        endIf

        oMldFilho := oModel:GetModel(cModelFilho )
        oHashFilho := &(cHashFilho)
        for nlA := 1 to nAteA
            lAddFilho   := .T.
            lExclFilho  := .F.
            //Como o processo referenciado eh o unico cadastro que utiliza o motor pai e filho e eh FK em outras tabelas do TAF, nao podera ser excluido e sempre refeito por completo.
            //Devido a Integridade referencial ID+Versão, eh necessario um mecanismo que posiciona na linha para alterar ou excluir o filho, diferente das demais movimentacoes que apaga e recria (ex: apuracao icms).
            if cArea $ "C1G|C1H"
                Taf585Filho( cArea, ctagFilho, aObjJson, nlA, @oMldFilho, @lAddFilho, @lExclFilho )
            endif
            //Na alteracao, ja havia 1 suspensao integrada, posteriormente foi incluido uma segunda, o contador nlA eh 1, porem nessa situacao devera ser adicionado uma nova linha.
            if cArea $ "C1G|C1H" //cadastro
                if lAddFilho
                    If !oMldFilho:IsEmpty() //caso a grid estaja vazia, nao ira inserir nova linha na primeira ocorrencia (apenas sobrepor).
                        oMldFilho:AddLine()
                    EndIf
                endif
            else
                If nlA > 1
                    oMldFilho:AddLine()
                endif
            endif
            If !lExclFilho //se nao for exclusao inclui ou altera na linha ja posicionada para o C1G
                TafIncReg( @oModel, aObjJson[ctagFilho][nlA], oHashFilho, @aRetJs, @lSucessItem, cModelFilho, cKey )
            endif
            If !lSucessItem
                lErro := lSucessItem
            EndIf
            /*-----------------------------
            |             NETOS            |
            ------------------------------*/
            nPosNeto := aScan(aSubModel2, {|x| x[1] == cTagFilho })
            If nPosNeto > 0

                nAteB := 0
                cModelNeto := aSubModel2[nPosNeto][2]
                cTagNeto := aSubModel2[nPosNeto][3]
                cHashNeto := aSubModel2[nPosNeto][4]
                If valtype( aObjJson[ctagFilho][nlA][ctagNeto] ) == 'A'
                    nAteB := len( aObjJson[ctagFilho][nlA][cTagNeto] )
                endIf
                oMldNeto := oModel:GetModel(cModelNeto )
                oHashNeto := &(cHashNeto)
                for nlB := 1 to nAteB
                    If (nlB > 1);oMldNeto:AddLine();endIf
                    TafIncReg( @oModel, aObjJson[ctagFilho][nlA][ctagNeto][nlB], oHashNeto, @aRetJs, @lSucessItem, cModelNeto, cKey )
                    If !lSucessItem; lErro := lSucessItem ; endIf
                next nlB
            EndIf

        next nlA
        If cArea == "C1H" // apos incluir/alterar os filhos que veio no json, excluir os registros que nao estao no json
            DelFilho(@oMldFilho)
        EndIf
    Next n1Sub    
EndIf
/*-----------------------------
|    VALIDACAO DO MODELO       |
------------------------------*/
lSucessItem := oModel:VldData()
If !lSucessItem
    cField    := oModel:GetErrorMessage( )[4]
    cCodError := oModel:GetErrorMessage( )[5]
    If !Empty(cField)
        HMGet(oHashPai, cField, @cProp )
    endIf
    cErro := RetErroTaf( cProp, aObjJson, cField, cCodError )
    If !empty(cKey) //Grava tabela V5R log e alimenta aRetJs para o rest
        AgrupaErro( cKey, cErro, @aRetJs )
    endIf
endIf

//Caso o ValidData retorne verdadeiro, porem foi encontrado alguma inconsistencia no controle de validacao atribuo retorno do lErro
If lSucessItem
    lSucessItem := lErro
endIf

Return Nil

/*----------------------------------------------------------------------
{Protheus.doc} TafIncReg()
Prepara o modelo com oas informações do json para posterior commit

@param oModel, objeto, modelo do cadastro está sendo realizado
@param aObjJson, array, array das propriedade do objeto Json 
@param oHash, objeto, hash do cadastro que está sendo realizado
@param aRetJs, array, com as informações se houve sucesso ou erro no cadastro
@param lSucessItem, lógico, se cadastrou com sucesso ou não
@param cModelID, numerico, nome do modelo do cadastro que está sendo realizado
@param cKey, caracter, chave do registro a ser cadstrado

@author Karen Honda
@since 19/07/2021
@return Nil, nulo, não tem retorno.
//----------------------------------------------------------------------*/
Static Function TafIncReg( oModel, aObjJson, oHash, aRetJs, lSucessItem, cModelID, cKey )

Local cField    := ''
Local cChave    := ''
Local nY        := 0
Local cFunc     := '' 

Local cProperty := ''
Local cCodErro  := '' 
Local cErro     := ''

Local aProperty := {}
Local nAte      := 0
Local lErro     := .T. //variavel para acumular ao menos 1 falha.

Default oModel      := Nil
Default aObjJson    := {}
Default oHash       := Nil
Default aRetJs      := {}
Default lSucessItem := .F.  //variavel para controlar o sucesso de cada transacao
Default cModelID    := ''
Default cKey        := ''

aProperty := aObjJson:GetNames( )
nAte      := Len( aProperty )

DBSelectArea( "V5R" )
DBSetOrder( 1 ) // V5R_FILIAL, V5R_GRPERP, V5R_CODFIL, V5R_ALIAS, V5R_REGKEY

//Com a propriedade do json em mãos ( EX: aProperty := "itemId" )
//Buscamos no objeto oHash o campo a ser utilizado para gravação e retornamos na variável @cField.
//Ex: Se o Hash passado como parametro for de produto: hmget( oHash, "itemId", @cField ) | cField terá o conteúdo "C1L_CODIGO"
Begin Sequence

for nY := 1 to nAte
    lSucessItem := .T.
    
    If hmget( oHash, aProperty[nY], @cField ) .and. !Empty(cField)
        cChave := aObjJson[aProperty[nY]] // Retornamos o contéudo da propriedade que será gravado
        
        If "#F3#" $ cField //Tratamento de-para para campos F3
            cField := SubStr( cField, 1, Len( cField ) - 4 )
            If !empty( cChave )
                hmget( oHash, "#F3#"+cField, @cFunc )
                cChave := &cFunc
                If "NOTFOUND" == cChave
                    lErro := lSucessItem := .F.
                    cChave := aObjJson[aProperty[nY]]
                    cCodErro := "NOTFOUND"
                    HMGet( oHash, cField, @cProperty )
                    cErro := RetErroTaf( cProperty, aObjJson, cField, cCodErro )
                    If !empty(cKey)
                        AgrupaErro( cKey, cErro, @aRetJs )
                    endIf
                EndIf
            EndIf
        elseIf "#DT#" $ cField // Tratamento para campos tipo data
            cField := SubStr( cField, 1, Len( cField ) - 4 )
            If valtype(cChave) == 'C'
                cChave := ctod(cChave)
                If alltrim(cvaltochar(cChave)) == "/  /" .or. empty(alltrim(cvaltochar(cChave)))
                    cChave := cTod('')
                    lErro := lSucessItem := .F.
                    cCodErro := "DATE"
                    HMGet( oHash, cField, @cProperty )
                    cErro := RetErroTaf( cProperty, aObjJson, cField, cCodErro )
                    If !empty(cKey)
                        AgrupaErro( cKey, cErro, @aRetJs )
                    endIf
                endIf
            endIf
        elseIf "_ID " $ cField+" " //Ignora os campos _ID pois será criado pelo TAF
            Loop
        EndIf

        If lSucessItem
            // TafConout("---->cModelID: " + cModelID + " cField: " + cField + " cChave:" + cvaltochar(cChave) )
            If valtype( cChave ) == "U" .Or. !oModel:LoadValue( cModelID, cField, cChave )
                lErro := lSucessItem := .F. //O campo não pode sofrer atualização, invalidará a folha inteira de dados e o erro será retornado em aRetJs
                cCodError := "LOADVALUE"
                HMGet( oHash, cField, @cProperty )
                cErro := RetErroTaf( cProperty, aObjJson, cField, cCodError )
                If !empty(cKey) // Grava tabela V5R log e alimenta aRetJs para o rest
                    AgrupaErro( cKey, cErro, @aRetJs )
                endIf
            endIf
        endIf
    endIf
Next nY

//O lSucessItem pode estar "ok", ja que recebe incremento a cada Tags, porem se existir no minimo uma falha devera impedir a gravacao.
lSucessItem := lErro

End Sequence

Return Nil

/*/{Protheus.doc} delMovAntST
Deleta movimentos antigos do layout, para a chave posicionada
@author Renan Gomes
@since 12/08/2021
/*/
Function DelTsiMov(cArea,oHash,aObjJson,nOpcao)

Local aAreaAtu   := {}
Local aAreaDel   := {}
Local cUf        := ""
Local cDataDe    := ""
Local cDataAte   := ""
Local cSource    := ""
Default cArea    := ""

aAreaAtu := getArea()

if cArea == "C3J"
    hmget( oHash, "#F3#C3J_UF", @cUf )
    hmget( oHash, "#DT#C3J_DTINI", @cDataDe )
    hmget( oHash, "#DT#C3J_DTFIN", @cDataAte )
    hmget( oHash, "s_o_u_r_c_e_", @cSource  )
    
    cUf      := &cUf    
    cDataDe  := &cDataDe
    cDataAte := &cDataAte
    
    aAreaC3J  := C3J->(getArea())
    C3J->(DbSetOrder(1))   //C3J_FILIAL+C3J_UF+DTOS(C3J_DTINI)+DTOS(C3J_DTFIN)+C3J_INDMOV
    C3J->(dbGoTop())
    C3J->(DbSeek(xFilial("C3J")+cUf+cDataDe+cDataAte,.T.)) //Não filtro o indmov pq qro ver todos os registros desta UF e periodo
    
    while C3J->(!EOF()) .AND.  C3J->(C3J_FILIAL+C3J_UF+DTOS(C3J_DTINI)+DTOS(C3J_DTFIN)) == xFilial("C3J")+cUf+cDataDe+cDataAte
        
        oModel := FWLoadModel( cSource )
        oModel:SetOperation( 5 )
        oModel:Activate()
        FwFormCommit( oModel ) 
        C3J->(dbSkip())
    end

Endif

if cArea == 'C5M'
    hmget( oHash, '#DT#C5M_DTINI' , @cDataDe )
    hmget( oHash, '#DT#C5M_DTFIM' , @cDataAte )
    hmget( oHash, "s_o_u_r_c_e_"  , @cSource  )
     
    cDataDe  := &cDataDe
    cDataAte := &cDataAte

    aAreaDel := C5M->(getArea())

    C5M->(DbSetOrder(1))   //C5M_FILIAL+DTOS(C5M_DTINI)+DTOS(C5M_DTFIM)+C5M_CODATI+STR(C5M_ALQCON)+C5M_CODCTA
    C5M->(dbGoTop())
    C5M->(DbSeek(xFilial("C5M")+cDataDe+cDataAte,.T.)) //Não filtro o restante da chave pois quero excluir todo o movimento do
                                                               //periodo informado.

    while C5M->(!EOF()) .AND.  C5M->(C5M_FILIAL+DTOS(C5M_DTINI)+DTOS(C5M_DTFIM)) == xFilial("C5M")+cDataDe+cDataAte
        oModel := FWLoadModel( cSource )
        oModel:SetOperation( 5 )
        oModel:Activate()
        FwFormCommit( oModel ) 
        C5M->(dbSkip())
    enddo                                                          
endif

RestArea(aAreaAtu)

Return 

/*/{Protheus.doc} Taf585Filho
Funcao responsavel por apagar a linha (caso seja exclusao) ou posicionar na linha caso seja alteracao
@author Denis Souza
@since 12/08/2021
/*/
Static Function Taf585Filho( cArea, ctagFilho, aObjJson, nlA, oMldFilho, lAddFilho, lExclFilho )

Local aSeek := {}

Default cArea      := ""
Default ctagFilho  := ""
Default aObjJson   := {}
Default nlA        := 1
Default oMldFilho  := Nil
Default lAddFilho  := .T.
Default lExclFilho := .F.

if cArea == "C1G" //Filho T5L_UNQ -> T5L_FILIAL, T5L_ID, T5L_VERSAO, T5L_CODSUS
    aSeek := { {"T5L_FILIAL" , aObjJson['branch'] }, {"T5L_ID" , aObjJson['id'] } , {"T5L_VERSAO", aObjJson['versao'] }, {"T5L_CODSUS", aObjJson[ctagFilho][nlA]["suspensionIndicativeCode"] } }

elseif cArea == "C1H" //V3R_FILIAL, V3R_ID, V3R_CODIGO, R_E_C_N_O_, D_E_L_E_T_
    aSeek := { {"V3R_FILIAL" , C1H->C1H_FILIAL }, {"V3R_ID" , C1H->C1H_ID } , {"V3R_CODIGO", aObjJson[ctagFilho][nlA]["dependentCode"] } }
endif

if oMldFilho:SeekLine( aSeek )

    lAddFilho := .F. //se encontrou sera uma alteracao na linha posicionada, portanto nao devera incluir uma linha nova

    //Caso a tag generica opCancelation seja uma operacao de cancelamento, ira apagar a o filho.
    if aObjJson[ctagFilho][nlA]["opCancelation"] == "5"
        if !oMldFilho:IsDeleted()
            oMldFilho:DeleteLine()
            lExclFilho := .T.
        endif
    endif
else //se nao encontrou verifica operacao, se for cancelado nao devera inserir a linha ( sera ignorado )
    if aObjJson[ctagFilho][nlA]["opCancelation"] == "5"
        lAddFilho  := .F.
        lExclFilho := .T.
    endif
endif

Return Nil


/*{Protheus.doc} RunTrigger()
Função responsável por gravar os valores de ID em seus respectivos campos.
Quando um campo possui um gatilho cujo valor será gravado em um campo direferente
do que esta sendo editado é mecessário usar essa função, isso porque os valores
dos campos do submodel estão sendo atribuidas atrabés do método "LoadValue"

@author Carlos Edurdo
@since 03/10/2022*/
Static function RunTrigger(oModel,cIdModel,cAlias)
Local lRet := .t.

if cIdModel == 'MODEL_V3R'
    V3R->V3R_CREDEP := GetTafId( 'V3Q', oModel:GetValue('V3R_RELDEP'), 2 )
    lRet := .t.
endif

return lRet
/*----------------------------------------------------------------------
{Protheus.doc} DelFilho()
Funcão que exclui os registros que estão no model mas nao veio no json

@param oModel, objeto, modelo do cadastro está sendo realizado

@author Karen Honda
@since 06/12/2022
@return Nil, nulo, não tem retorno.
//----------------------------------------------------------------------*/
Static Function DelFilho(oModel)
Local nX as Numeric

For nX := 1 to oModel:Length()
    oModel:GoLine(nX)
    If ! (oModel:IsUpdated() .or. oModel:IsInserted()) // se a linha nao foi atualizada ou inserida, excluir pois nao veio no json
        oModel:DeleteLine()
    EndIf    
Next nX

Return
