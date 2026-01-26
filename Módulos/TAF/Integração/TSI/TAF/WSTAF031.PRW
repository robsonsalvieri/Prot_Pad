#INCLUDE "TOTVS.CH"
#INCLUDE "RESTFUL.CH"
#INCLUDE "FWMVCDEF.CH"

Static cTagJs := 'substituteEstablishment'

/*/{Protheus.doc} WSTAF031
WS para operações GET/POST/PUT e DELETE do Cadastro de Inscrição do Estabelecimento Substituto 
@author Henrique Fabiano Pateno Pereira    
@since 27/07/2020
@version 1.0
*/

WSRESTFUL tsiSubstituteEstablishment DESCRIPTION "TAF Service Integration - Cadastro de Inscrição do Estabelecimento Substituto"  
	
    WSDATA sourceBranch                 as string
    WSDATA page			                as integer	optional 
	WSDATA pageSize 	                as integer	optional 
    WSDATA order                        as string  optional
    WSDATA substituteEstablishmentOf    as string  optional // Uf de 
    WSDATA substituteEstablishmentUp    as string  optional // UF até
    WSDATA id                           as string  optional 
  
	WSMETHOD GET tsiSubstituteEstablishment;
    DESCRIPTION "Retorna uma lista de Inscrição do Estabelecimento Substituto";
    PATH 'api/tsi/v1/tsiSubstituteEstablishment/';
    TTALK "tsiSubstituteEstablishment";
    WSSYNTAX "/tsiSubstituteEstablishment";
    PRODUCES APPLICATION_JSON 

    WSMETHOD GET idtsiSubstituteEstablishment;
    DESCRIPTION "Retorna uma Inscrição do Estabelecimento Substituto";
    PATH 'api/tsi/v1/tsiSubstituteEstablishment/{id}';
    TTALK "idtsiSubstituteEstablishment";
    WSSYNTAX "/tsiSubstituteEstablishment";
    PRODUCES APPLICATION_JSON  

    WSMETHOD POST tsiSubstituteEstablishment; 
    DESCRIPTION "Inclui/altera uma lista de Inscrição do Estabelecimento Substituto";
    PATH 'api/tsi/v1/tsiSubstituteEstablishment/';
    TTALK "tsiSubstituteEstablishment";
    WSSYNTAX "/tsiSubstituteEstablishment";
    PRODUCES APPLICATION_JSON 
 
    WSMETHOD PUT tsiSubstituteEstablishment; 
    DESCRIPTION "Altera uma Inscrição do Estabelecimento Substituto";
    PATH 'api/tsi/v1/tsiSubstituteEstablishment/{id}';
    TTALK "tsiSubstituteEstablishment";
    WSSYNTAX "/tsiSubstituteEstablishment";
    PRODUCES APPLICATION_JSON 

    WSMETHOD DELETE tsiSubstituteEstablishment;
    DESCRIPTION "Delete uma lista de Inscrição do Estabelecimento Substituto";
    PATH 'api/tsi/v1/tsiSubstituteEstablishment/';
    TTALK "tsiSubstituteEstablishment";
    WSSYNTAX "/tsiSubstituteEstablishment";
    PRODUCES APPLICATION_JSON 

END WSRESTFUL 

/*
Metodo responsável por consultar o cadastro de produto ao TAF
@author Henrique Fabiano Pateno Pereira
@since 27/07/2020
@version 1.0 
*/ 

WSMETHOD GET tsiSubstituteEstablishment WSREST tsiSubstituteEstablishment 
Local cJsonResp     as character
Local cInscEstDe    as character
Local cInscEstAte   as character
Local cAlias        as character
Local cOrder        as character
Local xOrder        as character
Local cUrl          as character
Local cFilProc       as character
Local nPage         as numeric 
Local nPageSize     as numeric 
Local nStruct       as numeric 
Local nPos          as numeric
Local nPageAux      as numeric
Local lHasNext      as logical
Local aStruct       as array 
Local oHash         as object
Local oJsonResp     as object

cJsonResp   :=  ''
cInscEstDe     :=  iif(valtype( self:substituteEstablishmentOf ) <> 'U' .and. !empty(self:substituteEstablishmentOf),self:substituteEstablishmentOf," ")
cInscEstAte    :=  iif(valtype( self:substituteEstablishmentUp ) <> 'U' .and. !empty(self:substituteEstablishmentUp),self:substituteEstablishmentUp,"ZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZ")
cAlias      :=  ''
cTagJson    :=  ''
xOrder      :=  ''
cOrder      :=  '' 
cFilProc    :=  ''
cUrl      := 'https://api.totvs.com.br/' // Url de mensagem de help
nPage       :=  0
nPageSize   :=  10
nStruct     :=  0
nPos        :=  0
nPageAux    :=  0
lHasNext    :=  .f.
aStruct     :=  {}
oJsonResp	:= JsonObject():New()
oHash := HashInscEst( .t. )

xOrder  :=  iif(valtype( self:order ) <> 'U' .and. !empty(self:order),self:order," ")    

        hmget( oHash, xOrder,@cOrder)
        
        // ajusta os cam
        if "#F3#"$cOrder .or. "#DT#"$cOrder  
            cOrder := SubStr( cOrder, 1, Len( cOrder ) - 4 )  
        endif

        if VldExecute( self:sourceBranch, @oJsonResp, @cFilProc )  
            
            DbSelectArea('C1F')
            
            // Obtenho o ID da C1E tabekla PAI de C1F, para que o relacionamento ocorra
            cFilProc := getTafId( 'C1E', cFilProc, 3 )

            // Validação de paginação
            If valtype( self:page ) <> 'U' .and. self:page > 0
                nPage := self:page
                if valtype( self:pageSize ) <> 'U' .and. self:pageSize > 0
                    nPageSize := self:pageSize
                endif
            endif

            // Executa a query de pesquisa ao  Cadastro de Inscrição do Estabelecimento Substituto para retorno da lista GET list
            cAlias := GetInscEst(cInscEstDe, cInscEstAte, nPage, nPageSize, cOrder, cFilProc)

            // Monto a estrutura na mão ao invés de usa DbStruct()
            aadd(aStruct,{'C1F_IEST','C',20,0})
            aadd(aStruct,{'C09_UF','C',2,0})

            // Percorrendo alias para montagem do jSon de Resposta
            if (cAlias)->(eof())                  
                // se não houve retorno na query, alimento  oJsonResp (objeto de resposta ) para itens não encontrados          
                SetErroJs( @oJsonResp, cTagJs, , cUrl, '404' )
            else 
                // Percorrendo alias para montagem do jSon de Resposta
                while (cAlias)->(!eof())  
                        nPageAux++
                        
                        // nó proncipal do json de resposta
                        if nPageAux == 1
                            oJsonResp[cTagJs] := {} 
                        endif
                        
                        // controle de paginação
                        // Se ainda existe um item na query (nPageSize+1 ) lHasNext = .t.
                        if nPageAux < nPageSize+1 

                            aAdd( oJsonResp[cTagJs],JsonObject():New())  
                            // percorre a estrutura dos campos e monta do objheto de resposta  
                            for nStruct := 1 to len(aStruct)
                    
                                if hmget( oHash, alltrim(aStruct[nStruct][1]) + "#DT#", @cTagJson ) 
                                    nPos := Len(oJsonResp[cTagJs])
                                if valtype( &('(cAlias)->'+aStruct[nStruct][1])) == 'C'                                   
                                        oJsonResp[cTagJs][nPos][cTagJson] := dtoc(stod( &('(cAlias)->'+aStruct[nStruct][1])))
                                    else // tipo data
                                        oJsonResp[cTagJs][nPos][cTagJson] :=  dtoc(&('(cAlias)->'+aStruct[nStruct][1]))
                                    endif
                                    //Busca Demais Campos 
                                elseif  hmget( oHash, alltrim(aStruct[nStruct][1]), @cTagJson ) 
                                    nPos := Len(oJsonResp[cTagJs])
                                    oJsonResp[cTagJs][nPos][cTagJson] := alltrim(&('(cAlias)->'+aStruct[nStruct][1]))
                                endif

                            Next nStruct
                        else 
                            // controle de paginação, ainda existe registros para os parâmetros enviados 
                            lHasNext := .t. 
                            exit

                        endif
                            
                    (cAlias)->(DbSkip())
                enddo
            endif
        endif

        oJsonResp["hasnext"] := lHasNext 

        //------------------------------------------------------------------- 
        // Serializa objeto Json 
        //-------------------------------------------------------------------
        cJsonResp := FwJsonSerialize( oJsonResp ) 
        Self:SetResponse( cJsonResp )   
        freeobj(oJsonResp)
        freeobj(oHash)
        fwFreeArray(aStruct)
        cJsonResp := ''
 
Return .t.

/*
Metodo responsável por consultar um Cadastro de Inscrição do Estabelecimento Substituto de acordo com o ID enviado
@author Henrique Fabiano Pateno Pereira
@since 15/07/2020
@version 1.0 
*/ 

WSMETHOD GET idtsiSubstituteEstablishment WSREST tsiSubstituteEstablishment 
Local cJsonResp     as character
Local cInscEstDe         as character
Local cAlias        as character 
Local cUrl          as character
Local cFilProc       as character
Local nStruct       as numeric 
Local nPos          as numeric
Local nPageAux      as numeric 
Local aStruct       as array 
Local oHash         as object
Local oJsonResp     as object
Local lOk           as logical
lOk :=  valtype( self:id ) <> 'U' .and. !empty(self:id)
cJsonResp   :=  ''
cInscEstDe       :=  iif(lOk,self:id," ")
cAlias      :=  ''
cTagJson    :=  ''
cFilProc    :=  ''
cUrl := 'https://api.totvs.com.br/' // Url de mensagem de help
nStruct     :=  0
nPos        :=  0
nPageAux    :=  0
aStruct     :=  {} 
oJsonResp	:= JsonObject():New()
oHash := HashInscEst( .t. )

    if VldExecute( self:sourceBranch, @oJsonResp, @cFilProc ) 
        DbSelectArea('C1F')
       
        cFilProc := getTafId( 'C1E', cFilProc, 3 )
        
        // Efetua a consulta ao Cadastro de Inscrição do Estabelecimento Substituto 
        cAlias := GetInscEst(cInscEstDe, cInscEstDe, , , , cFilProc)
        
        // monta strutura dos campos manualmente ao invés de usar dbstruct
        aadd(aStruct,{'C1F_IEST','C',20,0})
        aadd(aStruct,{'C09_UF','C',2,0}) 
        
        // verifica se houyve retorno, caso negativo, alimento oJsonResp objeto de retorno 
        if (cAlias)->(eof()) 
            SetErroJs( @oJsonResp, cTagJs, , cUrl, '404' )
        else 
            // Percorrendo alias para montagem do jSon de Resposta
            while (cAlias)->(!eof()) 

                oJsonResp[cTagJs] := {}     
            
                aAdd( oJsonResp[cTagJs],JsonObject():New())  
                for nStruct := 1 to len(aStruct)

                    //Busca de Campo Date
                    if hmget( oHash, alltrim(aStruct[nStruct][1]) + "#DT#", @cTagJson )
                        nPos := Len(oJsonResp[cTagJs])
                        oJsonResp[cTagJs][nPos][cTagJson] := alltrim(DTOC(STOD( &('(cAlias)->'+aStruct[nStruct][1]))))

                    //Busca Demais Campos
                    elseif  hmget( oHash, alltrim(aStruct[nStruct][1]), @cTagJson )
                        nPos := Len(oJsonResp[cTagJs])
                        oJsonResp[cTagJs][nPos][cTagJson] := alltrim(&('(cAlias)->'+aStruct[nStruct][1]))
                    endif
                    
                Next nStruct  

                (cAlias)->(DbSkip()) 

            enddo

        endif
    endif

    //------------------------------------------------------------------- 
    // Serializa objeto Json 
    //-------------------------------------------------------------------
    cJsonResp := FwJsonSerialize( oJsonResp ) 
    Self:SetResponse( cJsonResp )   
    freeobj(oJsonResp)
    freeobj(oHash)
    cJsonResp := ''
    fwFreeArray(aStruct)
    lOk         :=  .f.
   
Return .t.
/*
Metodo responsável por persistir um lista ( inclusão / alteração ) os dados Cadastro de Inscrição do Estabelecimento Substituto 
@author Henrique Fabiano Pateno Pereira
@since 27/07/2020
@version 1.0 
*/ 
  
WSMETHOD POST tsiSubstituteEstablishment WSREST tsiSubstituteEstablishment 
Local cJsonResp     as character
Local cFilProc      as character
Local oBjJson       as object // Requisição
Local oJsonResp	    as object // retorno
Local nGetNames     as numeric 
Local aNames        as array 
Local aRetJs        as array 

cJsonResp     := ""
cFilProc      := ""
oBjJson       := JsonObject():New() // Requisição
oJsonResp	  := JsonObject():New() // retorno
nGetNames     := 0 
aNames        := {} 
aRetJs        := {} 

        // valida parâmetro <source branch>
        if VldExecute( self:sourceBranch, @oJsonResp, @cFilProc ) 
           
            // obtem o body enviado
            cBody := self:GetContent( )  
            oBjJson:fromJSON( cBody )
            
            // percorre json enviado
            if len( oBjJson:GetNames( ) )>0
                for nGetNames := 1 to len( oBjJson:GetNames() )
                    aNames := oBjJson:GetJsonObject( oBjJson:GetNames()[nGetNames] )

                    if  oBjJson:GetNames()[nGetNames] == cTagJs 
                        
                        //TAFA565( HashInscEst( ), aNames, nil, @aRetJs ) 
                        Ws031Post( aNames, cFilProc, @aRetJs, HashInscEst( ), @oJsonResp )   
                    endif

                next
            else

               //Alimenta oJsonResp com retorno 
               SetErroJs( @oJsonResp,,,,'400' ) 

            endif  

        endif
        
        //------------------------------------------------------------------- 
        // Serializa objeto Json 
        //-------------------------------------------------------------------
        cJsonResp := FwJsonSerialize( oJsonResp )
        Self:SetResponse( cJsonResp )   
return .T.

/*
Metodo responsável por persistir operações de alteração de cadastro produto ao TAF
@author Henrique Fabiano Pateno Pereira
@since 15/07/2020
@version 1.0 
*/ 

WSMETHOD PUT tsiSubstituteEstablishment WSREST tsiSubstituteEstablishment 
Local cJsonResp     as character
Local cSeek         as character
Local cUrl          as character
Local cFilProc      as character
Local oBjJson       as object
Local oJsonResp	    as object
Local nGetNames     as numeric
Local nTamUfSt      as numeric
Local aNames        as array
Local aRetJs        as array
Local lOk           as logical

cJsonResp   := ""
cUrl        := 'https://api.totvs.com.br/'
oBjJson     := JsonObject():New()
oJsonResp	:= JsonObject():New() 
aRetJs      := {}
nGetNames   := 0
aNames      := {}
lOk         := valtype( self:id ) <> 'U' .and. !empty(self:id)

cFilProc    :=  ''

    if lOk

        if VldExecute( self:sourceBranch, @oJsonResp, @cFilProc )
            
            //pego o valor enviado em {id}
            nTamUfSt    := TamSX3( "C1F_UFST" )[1]
            cSeek :=  padr(self:id,nTamUfSt) 

            //pego o body enviado para alteração
            cBody := self:GetContent( ) 
            oBjJson:fromJSON( cBody ) 

            // percorrendo json para lteração
            if len(oBjJson:GetNames())>0

                for nGetNames := 1 to len( oBjJson:GetNames() )
                    aNames := oBjJson:GetJsonObject( oBjJson:GetNames()[nGetNames] )
                    
                    // Validação do body enviado 
                    if  oBjJson:GetNames()[nGetNames] == cTagJs
                        
                       // TAFA565( HashInscEst( ), aNames, MODEL_OPERATION_UPDATE, @aRetJs, cSeek )  
                        Ws031Put( aNames, cFilProc, @aRetJs, HashInscEst( ), @oJsonResp, cSeek ) 
                    endif
                next   
            else
                SetErroJs( @oJsonResp,,,,'400' )                 
            endif
        endif
    else
        SetErroJs( @oJsonResp,,,cUrl,'401' )
    endif    

    //------------------------------------------------------------------- 
    // Serializa objeto Json 
    //-------------------------------------------------------------------
    cJsonResp := FwJsonSerialize( oJsonResp )
    Self:SetResponse( cJsonResp ) 
    fwFreeArray(aNames)
    cSeekAux    :=  '' 

Return .t.

/*
Metodo responsável por persistir operações de deleção do Cadastro de Inscrição do Estabelecimento Substituto 
@author Henrique Fabiano Pateno Pereira
@since 15/07/2020
@version 1.0 
*/ 

WSMETHOD DELETE tsiSubstituteEstablishment WSREST tsiSubstituteEstablishment 
Local cJsonResp     as character
Local cSeek         as character
Local cFilProc      as character
Local oBjJson       as object 
Local oJsonResp	    as object 
Local aRetJs        as array
Local aNames        as array 
Local nGetNames     as numeric

 
cJsonResp     := ""
cSeek         := ""
cFilProc      := ""
oBjJson       := JsonObject():New()
oJsonResp	  := JsonObject():New()
aRetJs        :=  {}
nGetNames     := 0
aNames        := {} 
        // valida sourceBranch eviado
        if VldExecute( self:sourceBranch, @oJsonResp, @cFilProc )
            
            // obtem o body contendo a tag de id dos cadastros que serão deletados
            cBody := self:GetContent( ) 
            oBjJson:fromJSON( cBody )

            if len(oBjJson:GetNames())>0
                for nGetNames := 1 to len(oBjJson:GetNames())
                
                    aNames := oBjJson:GetJsonObject( oBjJson:GetNames()[nGetNames] )
                    if  oBjJson:GetNames()[nGetNames] == cTagJs
                        Ws031Del( aNames, cFilProc, @aRetJs ) 
                    endif 
                next
            else
                SetErroJs( @oJsonResp,,,,'400' )
            endif
            oJsonResp[cTagJs] := {} 
            // adiciona mensagem de erro ao objeto oJsonResp de retorno   
            SetErroJs(@oJsonResp, cTagJs, @aRetJs,, "403",,'substituteEstablishmentId' )
        endif
        
        //------------------------------------------------------------------- 
        // Serializa objeto Json 
        //-------------------------------------------------------------------
        cJsonResp := FwJsonSerialize( oJsonResp )
        Self:SetResponse( cJsonResp )   

Return .t.

/*--------------------------------------------------------------------------------
{Protheus.doc} HashInscEst()
(Cria Hash de "De|Para" do identificador do Json para o campo de gravação no TAF)
@author Henrique Pereira
@since 15/07/2020
@return Nil, nulo, não tem retorno.
//------------------------------------------------------------------------------*/
Function HashInscEst(lTblB) 
Local oHash := HMNew( )  

Default lTblB := .f.

// Infos genéricas
HMSet(oHash, 'm_o_d_e_l_'   , 'MODEL_C1F'   )
HMSet(oHash, 's_o_u_r_c_e_' , 'TAFA050'     )
HMSet(oHash, 'a_r_e_a_'     , 'C1F'         )  
HMSet(oHash, 'o_r_d_e_r_'   , 1             )
HMSet(oHash, 'k_e_y_'       , "aObjJson[nI]['unitFederativeId']")
HMSet(oHash, 'k_e_y_f_a_t_h_e_r'       , "aObjJson[nI]['branch']")
HMSet(oHash, 's_e_e_k_'     , "TsiSkInsc(xfilial('C1F') + getTafId( 'C1E', aObjJson[nI]['branch'], 3 ) + TsiIdInsc(aObjJson[nI]['unitFederativeId']))" ) 
HMSet(oHash, 't_a_g_i_d_'    , "unitFederativeId"      )
HMSet(oHash, 'f_i_e_l_d_i_d_'    , "C1F_UFST"      )

// Propriedades e Campos
SetHashKey(oHash, 'unitFederativeId'    , 'C1F_UFST#F3#' )
SetHashKey(oHash, 'stateRegistration'   , 'C1F_IEST' )
SetHashKey(oHash, 'branch'              , 'C1F_ID#F3#' )
if lTblB
    SetHashKey(oHash, 'unitFederativeId'    , 'C09_UF' )
    SetHashKey(oHash, 'branch'              , 'C09_ID' )
endif  

// #F3#
HMSet(oHash, '#F3#C1F_UFST'     , "TsiIdInsc( cChave )") 
HMSet(oHash, '#F3#C1F_ID'       , "getTafId( 'C1E', cIdFather, 3 )") 

Return oHash    
/*
Função responsável por executar a consulta ao cadastro de centro de custo
@author Henrique Fabiano Pateno Pereira
@since 15/07/2020
@version 1.0 
*/ 
function GetInscEst( cItemDe, cItemAte, nPage, nPageSize, cOrder, cFilProc )
Local cQry          := ''
Local cAlias        := getNextAlias()  
Default cItemDe     :=  ''
Default cItemAte    :=  ''
Default cOrder      :=  ''
Default cFilProc    :=  ''
Default nPage       := 0 
Default nPageSize   := 0 

cQry :=  GetInscQry(cItemDe, cItemAte, nPage, nPageSize, cOrder, cFilProc)   
dbUseArea(.T., "TOPCONN", TCGenQry(, , cQry), cAlias, .F., .T.)  
Return cAlias

/*
Função responsável por montar a consulta ao Cadastro de Inscrição do Estabelecimento Substituto 
@author Henrique Fabiano Pateno Pereira
@since 15/07/2020
@version 1.0 
*/ 

static function GetInscQry(cItemDe, cItemAte, nPage, nPageSize, cOrder, cFilProc) 
Local cQry          := ''

Default cFilProc :=  '' 

if nPage == 0 
    nPage := 1
endif

if nPageSize == 0
    nPageSize := 10
endif
if Empty(cItemAte)
    cItemAte := 'ZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZ'
endif

cQry  += " SELECT C1F.C1F_IEST , "
cQry  += " C09.C09_UF , "
cQry  += " C09.C09_ID "
cQry  += " FROM "+RetSqlName("C1F")+" C1F "
cQry  += " INNER JOIN "+RetSqlName("C09")+" C09 "
cQry  += " ON C09.C09_ID = C1F.C1F_UFST " 
cQry  += " AND C09.C09_UF between '"+cItemDe+"' AND '"+cItemAte+"' "
cQry  += " where C1F.C1F_FILIAL = '"+xFilial("C1F") +"'" 
if !empty(cFilProc)
    cQry  += " AND C1F.C1F_ID = '"+cFilProc+"'" 
endif
cQry  += " AND C1F.C1F_ATIVO <> '2' "
cQry  += " AND C1F.D_E_L_E_T_ = ' ' "
if !empty(cOrder)
    if 'C1F' $ cOrder
        cQry  += " order by C1F."+cOrder 
    else
        cQry  += " order by C09."+cOrder
    endif
else
    cQry  += " order by 1 "
endif
cQry  += " OFFSET ( "+cValToChar(nPage-1)+" * "+cValToChar(nPageSize)+" ) ROWS "
cQry  += " FETCH NEXT "+cValToChar(nPageSize+1)+" ROWS ONLY "  

Return cQry 

/*----------------------------------------------------------------------
{Protheus.doc} IntInscTSI()
(Teste de integração. Deve ser retirada apos criação do JOB de execução.
@author Henrique Pereira
@since 07/07/2020
@return Nil, nulo, não tem retorno.
//----------------------------------------------------------------------*/
Function IntInscTSI()
Local oObj      := TSICC():new(cEmpAnt+cFilAnt)
Local cPropN1   := oObj:GetJsn():GetNames()[1] //Retorna um array com todas as propriedades disponíveis no primeiro nível do JsonObject.
Local aJS       := oObj:GetJsn():GetJsonObject(cPropN1)  //Retorna um objeto do tipo JsonObject com o conteúdo da propriedade informada.

freeobj( oObj ) 
TAFA565( HashInscEst( ), aJS )

return .t.

/*----------------------------------------------------------------------
{Protheus.doc} TsiIdInsc()
(Retorna o ID da tabela C09
@author Henrique Pereira
@since 07/07/2020
@return Nil, nulo, não tem retorno.
//----------------------------------------------------------------------*/ 
function TsiIdInsc(cId) 
Local cIdInscEst    := ''
   
    dbSelectArea('C09')
    If C09->(DBSeek(xFilial("C09") + cId ) )
        cIdInscEst  := C09->C09_ID
    else
        cIdInscEst    := 'NOTFOUND'
    endif

return cIdInscEst

/*----------------------------------------------------------------------
{Protheus.doc} TsiSkInsc()
(Executa o seek na abela C1F
@author Henrique Pereira
@since 03/08/2020
@return Nil, nulo, não tem retorno.
//----------------------------------------------------------------------*/ 

function TsiSkInsc( cChave ) 
Local lRet as logical

lRet := .f.

    if C1F->(DbSeek(cChave))
        lRet := .t.
    endif

return lRet
/*----------------------------------------------------------------------
{Protheus.doc} Ws031Del()
Funçãi que delete a tabela C1F 
@author Henrique Pereira
@since 07/07/2020
@return Nil, nulo, não tem retorno.
//----------------------------------------------------------------------*/
static function Ws031Del(aObjJson, cFilProc, aRetJs) 
Local nI            :=  0
Local cProperty     :=  ''
Local lSucessItem   :=  .f.
Local cCodErro      :=  ''
Local cErro         :=  ''
Local cKey          :=  ''
Local cId           :=  getTafId( 'C1E', cFilProc, 3 )
    
    for nI := 1 to Len( aObjJson )
        cKey          :=  TsiIdInsc(aObjJson[nI]['unitFederativeId'])  
        if C1F->(DbSeek(xfilial('C1F') + cId + cKey))
                RecLock("C1F",.F. )
                C1F->( DBDelete() ) 
                C1F->( MsUnlock() )
                lSucessItem := .t.
        else
                lSucessItem := .f. 

                // prepara a mensagem
                cCodErro := 'NOTEXIST'
                cProperty := aObjJson[nI]["unitFederativeId"]    

                cErro := RetErroTaf( cProperty, aObjJson[nI], 'unitFederativeId' , cCodErro, aObjJson[nI]['unitFederativeId'] )
        endif 
        aadd(aRetJs,{ lSucessItem ,aObjJson[nI]['unitFederativeId'], cCodErro, cErro} ) 
    next
return


/*----------------------------------------------------------------------
{Protheus.doc} Ws031Post()
Funçãi que efetua inclusão e alteração de item em lote C1F 
@author Henrique Pereira
@since 07/07/2020
@return Nil, nulo, não tem retorno.
//----------------------------------------------------------------------*/
function Ws031Post(aObjJson, cFilProc, aRetJs, oHash, oJsonResp, cSeek) 
Local nI            :=  0
Local lSucessItem   :=  .t.
Local cKey          :=  '' 
Local cId           :=  getTafId( 'C1E', cFilProc, 3 )
Local nY            :=  0

Local cUfst         := ''
Local cIest         := ''

Default    cSeek    :=  ''

    DBSelectArea( "C1F" ) 
    DBSetOrder( 1 ) 
    DBSelectArea( "V5R" )
    DBSetOrder( 1 ) // V5R_FILIAL, V5R_GRPERP, V5R_CODFIL, V5R_ALIAS, V5R_REGKEY

    for nI := 1 to Len( aObjJson )
    
        cKey := TsiIdInsc(aObjJson[nI]['unitFederativeId'])
        lSucessItem := .t.
        if nI == 1
            oJsonResp[cTagJs] := {} 
        endif
       
        if cKey <> 'NOTFOUND'
            
            if C1F->(DbSeek(xfilial('C1F') + cId + cKey)) 
                RecLock("C1F", .F.)
            else
                RecLock("C1F", .T.)
            endif

            aProperty := aObjJson[nI]:GetNames( )  
            for nY := 1 to Len( aProperty )
                do case
                    case aProperty[nY] == 'unitFederativeId' 
                        cUfst   := cKey
                    case aProperty[nY] == 'branch' 
                        cId    := iif( !empty(cId), cId, '' )
                    case aProperty[nY] == 'stateRegistration' 
                        cIest   :=  aObjJson[nI]['stateRegistration']
                endcase
            
            Next nY
                            
                if cId <> 'NOTFOUND'  .and. !empty(cId)         
                    C1F->C1F_ID     := cId
                else
                        // popula o oJsonResp com a mensagem de NotFound
                    t031NotFnd(@oJsonResp, 'branch', aObjJson ,cId, 'C1F_ID' )
                endif                      
                C1F->C1F_UFST   := cUfst 
                C1F->C1F_IEST   := cIest 
                C1F->(MsUnlock())

                aadd( aRetJs,{ lSucessItem ,aObjJson[nI]['unitFederativeId']} ) 
                SetErroJs(@oJsonResp, cTagJs, aRetJs,,"403" )
                aRetJs := {}  
        else
            // popula o oJsonResp com a mensagem de NotFound
            t031NotFnd(@oJsonResp, 'unitFederativeId', aObjJson[ni],  aObjJson[nI]['unitFederativeId'], 'C1F_UFST' )
        endif
    next
return


/*----------------------------------------------------------------------
{Protheus.doc} Ws031Put()
Função que altera a tabela C1F 
@author Henrique Pereira
@since 07/07/2020
@return Nil, nulo, não tem retorno.
//----------------------------------------------------------------------*/
function Ws031Put(aObjJson, cFilProc, aRetJs, oHash, oJsonResp, cSeek) 

Local cKey          :=  ''
Local cId           :=  getTafId( 'C1E', cFilProc, 3 )

Local cIest         := ''

Default    cSeek    :=  ''

    t031OpnTbl() 
    oJsonResp[cTagJs] := {} 
     
        cKey := TsiIdInsc(cSeek) 
        if C1F->(DbSeek(xfilial('C1F') + cId + cKey)) 
            RecLock("C1F", .F.)                
            cIest   :=  aObjJson[1]['stateRegistration']      
            C1F->C1F_IEST   := cIest 
            C1F->(MsUnlock())            
         
            aadd( aRetJs,{ .t. ,cSeek} ) 
            SetErroJs(@oJsonResp, cTagJs, aRetJs,,"403",cSeek,'unitFederativeId' )
            aRetJs := {}  
       
        else
            
            // popula o oJsonResp com a mensagem de NotFound
            t031NotFnd(@oJsonResp, 'unitFederativeId', aObjJson[1],  cSeek, 'C1F_UFST' ) 

        endif
return
/*----------------------------------------------------------------------
{Protheus.doc} t031OpnTbl()
Função estática para abertura e posicionamento das tabelas C1F e V5R 
@author Henrique Pereira
@since 07/07/2020
@return Nil, nulo, não tem retorno.
//--------------------------------------------------- -------------------*/
static function t031OpnTbl()    
    DBSelectArea( "C1F" )   
    DBSetOrder( 1 ) 
    DBSelectArea( "V5R" )
    DBSetOrder( 1 ) // V5R_FILIAL, V5R_GRPERP, V5R_CODFIL, V5R_ALIAS, V5R_REGKEY
Return 
/*----------------------------------------------------------------------
{Protheus.doc} t031NotFnd()
Função estática para: 
- Adicionar a mensagem de NOTFOUND no oJsonResp (objeto de resposta)
- Popular a tabela V5R
@author Henrique Pereira
@since 01/08/2020
@return Nil, nulo, não tem retorno.
//--------------------------------------------------- -------------------*/
static function t031NotFnd(oJsonResp, cProperty, aObjJson, cId, cField )
Local aRetJs        := {}
Local cCodError     := 'NOTFOUND'

        cErro := RetErroTaf(  cProperty, aObjJson,  cField, cCodError, cId )
        aadd( aRetJs,{ .f. , cId, cCodError, cErro} )
        
        // Grava tabela de log (V5R) e alimenta o aRetJs para retorno ao rest
        AgrupaErro( cId, cErro, @aRetJs )
        PutTsiV5r( "C1F", cId, aRetJs )
         
        SetErroJs(@oJsonResp, cTagJs, aRetJs,,"403",,'unitFederativeId' )          
        aRetJs := {}

return
/*----------------------------------------------------------------------
{Protheus.doc} tsiBranch()
Função estática que: 
Alimenta o oJsonResp ( objeto de resposta ) com a mensagem de retorno de 
<branch> (body) incoerente com o parâmetro <sourceBranch>
@author Henrique Pereira
@since 01/08/2020
@return Nil, nulo, não tem retorno.
//--------------------------------------------------- -------------------*/
static Function tsiBranch( oJsonResp, cBranch, cId, cFilProc, cUf )
Local cEmpAux       := PadR( cEmpAnt, TamSX3( "V5R_GRPERP" )[1] )
Local cFilAux       := PadR( cFilAnt, TamSX3( "V5R_CODFIL" )[1] ) 
Local cUrl          := 'https://api.totvs.com.br/'

    lSucessItem := .f.
    cCodError := "A filial "+ cBranch +" enviada no corpo da mensagem difere da filial "+ cFilProc +" enviada no parâmetro <sourceBranch>"
    cErro := 'WRONG'                    

    // Grava tabela de log (V5R) e alimenta o aRetJs para retorno ao rest
    AgrupaErro( cBranch, cErro, @aRetJs )
    PutTsiV5r( "C1F", cBranch, aRetJs )

    aadd(oJsonResp[cTagJs], JsonObject():New() )
    nLenObjJs := len(oJsonResp[cTagJs])
    oJsonResp[cTagJs][nLenObjJs]['unitFederativeId']    := cUf 
    oJsonResp[cTagJs][nLenObjJs]['sucess']                     := .f.
    oJsonResp[cTagJs][nLenObjJs]['code']                       := '400'
    oJsonResp[cTagJs][nLenObjJs]['message']                    := EncodeUTF8('Body Incoerênte') 
    oJsonResp[cTagJs][nLenObjJs]['detailedMessage']            := EncodeUTF8(cCodError)
    oJsonResp[cTagJs][nLenObjJs]['helpUrl']                    := EncodeUTF8( cUrl )    
Return