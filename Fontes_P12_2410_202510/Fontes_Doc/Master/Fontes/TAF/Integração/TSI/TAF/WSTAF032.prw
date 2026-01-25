#INCLUDE "TOTVS.CH"
#INCLUDE "RESTFUL.CH"
#INCLUDE "FWMVCDEF.CH"

Static __cTagJs   := 'referencedProcesses'
Static __cUrl     := 'https://api.totvs.com.br/'
Static __oHashC1G := HashProcRef( )
Static __oHashT5L := HashT5L()

/*/{Protheus.doc} WSTAF032
WS para operações GET/POST/PUT e DELETE do Cadastro de Processo Referenciado
@author Henrique Fabiano Pateno Pereira    
@since 27/08/2020
@version 1.0
*/

WSRESTFUL tsiReferentialProcesses DESCRIPTION "TAF Service Integration - Cadastro de Processo Referenciado"  
	
    WSDATA sourceBranch                 as string
    WSDATA page			                as integer	optional 
	WSDATA pageSize 	                as integer	optional 
    WSDATA order                        as string  optional
    WSDATA referencedProcessesOf        as string  optional 
    WSDATA referencedProcessesUp        as string  optional
    WSDATA processOriginIndicatorOf     as string  optional 
    WSDATA proceedingOriginIndicatUp    as string  optional   
  
	WSMETHOD GET tsiReferentialProcesses;
    DESCRIPTION "Retorna uma lista de Processos Referenciados";
    PATH 'api/tsi/v1/tsiReferentialProcesses/';
    TTALK "tsiReferentialProcesses";
    WSSYNTAX "/tsiReferentialProcesses";
    PRODUCES APPLICATION_JSON 

    WSMETHOD GET idtsiReferentialProcesses;
    DESCRIPTION "Retorna Processos Referenciados com base no Númeroo do processo";
    PATH 'api/tsi/v1/tsiReferentialProcesses/{referencedProcessesOf}';
    TTALK "idtsiReferentialProcesses";
    WSSYNTAX "/tsiReferentialProcesses"; 
    PRODUCES APPLICATION_JSON   

    WSMETHOD GET id2tsiReferentialProcesses;
    DESCRIPTION "Retorna um único Processo Referenciado com base no Número do processo e Indicador Origem de Processo ";
    PATH 'api/tsi/v1/tsiReferentialProcesses/{referencedProcessesOf}/{processOriginIndicatorOf}';
    TTALK "id2tsiReferentialProcesses";
    WSSYNTAX "/tsiReferentialProcesses";
    PRODUCES APPLICATION_JSON   

    WSMETHOD POST tsiReferentialProcesses; 
    DESCRIPTION "Inclui/altera uma lista de Processos Referenciados";
    PATH 'api/tsi/v1/tsiReferentialProcesses/';  
    TTALK "tsiReferentialProcesses"; 
    WSSYNTAX "/tsiReferentialProcesses";
    PRODUCES APPLICATION_JSON 
 
    WSMETHOD PUT tsiReferentialProcesses; 
    DESCRIPTION "Altera um punico Processo Referenciado";
    PATH 'api/tsi/v1/tsiReferentialProcesses/{referencedProcessesOf}/{processOriginIndicatorOf}';
    TTALK "tsiReferentialProcesses";
    WSSYNTAX "/tsiReferentialProcesses";
    PRODUCES APPLICATION_JSON 

    WSMETHOD DELETE tsiReferentialProcesses;
    DESCRIPTION "Delete uma lista de Processos Referenciados";
    PATH 'api/tsi/v1/tsiReferentialProcesses/';
    TTALK "tsiReferentialProcesses";
    WSSYNTAX "/tsiReferentialProcesses";
    PRODUCES APPLICATION_JSON 

END WSRESTFUL 

/*
Metodo responsável por consultar o cadastro de Processos Referenciados
@author Henrique Fabiano Pateno Pereira
@since 27/08/2020
@version 1.0 
*/ 

WSMETHOD GET tsiReferentialProcesses WSREST tsiReferentialProcesses 
Local cJsonResp     as character
Local cRefProcDe    as character
Local cRefProcAte   as character
Local xOrder        as character
Local cFilProc      as character
Local nPage         as numeric 
Local nPageSize     as numeric 
Local oJsonResp     as object
Local lOk           As Logical

cJsonResp   :=  ''
cRefProcDe  :=  iIf(valtype( self:referencedProcessesOf ) <> 'U' .and. !empty(self:referencedProcessesOf),self:referencedProcessesOf," ")
cRefProcAte :=  iIf(valtype( self:referencedProcessesUp ) <> 'U' .and. !empty(self:referencedProcessesUp),self:referencedProcessesUp,"ZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZ")
xOrder      :=  ''
cFilProc    :=  ''
nPage       :=  0
nPageSize   :=  10
lOk         := .F.
oJsonResp	:= JsonObject():New()

// VaLida source branch 
If VldExecute( self:sourceBranch, @oJsonResp, @cFilProc )  
    // Pega a ordem enviada via URL
    If valtype( self:order ) <> 'U' .and. !Empty(self:order)
        xOrder  := self:order
    EndIf

    // Validação de paginação
    If valtype( self:page ) <> 'U' .and. self:page > 0
        nPage := self:page
        If valtype( self:pageSize ) <> 'U' .and. self:pageSize > 0
            nPageSize := self:pageSize
        EndIf
    EndIf

    getWS032(oJsonResp, cRefProcDe, cRefProcAte,,, cFilProc, @lOk, nPage, nPageSize, xOrder)
    If !lOk
        SetErroJs( @oJsonResp, __cTagJs, , __cUrl, '404' )
    EndIf
EndIf

cJsonResp := FwJsonSerialize( oJsonResp ) //Serializa objeto Json
Self:SetResponse( cJsonResp )
freeobj(oJsonResp)
cJsonResp := ''
 
Return .t.

/*
Metodo responsável por consultar um cadastro de Processos Referenciados
@author Henrique Fabiano Pateno Pereira
@since 27/08/2020
@version 1.0 
*/ 

WSMETHOD GET idtsiReferentialProcesses WSREST tsiReferentialProcesses 
Local cJsonResp     as character
Local cRefProcDe    as character
Local cFilProc      as character
Local oJsonResp     as object
Local lOk           as logical

cJsonResp   := ''
cRefProcDe  := ''
cFilProc    := ''
lOk         := .F.
oJsonResp	:= JsonObject():New()

// VaLida source branch 
If VldExecute( self:sourceBranch, @oJsonResp, @cFilProc )  
    If valtype( self:referencedProcessesOf ) <> 'U' .and. !empty(self:referencedProcessesOf)
        cRefProcDe  :=  self:referencedProcessesOf
        getWS032(oJsonResp, cRefProcDe, cRefProcDe,,, cFilProc, @lOk,,,)
        If !lOk
            SetErroJs( @oJsonResp, __cTagJs, , __cUrl, '404' )
        EndIf
    Else
        SetErroJs( @oJsonResp, __cTagJs, , __cUrl, '400',,,,.F. )
    EndIf    
EndIf

cJsonResp := FwJsonSerialize( oJsonResp ) //Serializa objeto Json
Self:SetResponse( cJsonResp )
freeobj(oJsonResp)
cJsonResp := ''

Return .t.

/*
Metodo responsável por consultar um cadastro de Processos Referenciados
@author Henrique Fabiano Pateno Pereira
@since 27/08/2020
@version 1.0 
*/ 

WSMETHOD GET id2tsiReferentialProcesses WSREST tsiReferentialProcesses 
Local cJsonResp     as character
Local cRefProcDe    as character
Local cIndProcDe    as character
Local cFilProc      as character
Local oJsonResp     as object
Local lOk           as logical

cJsonResp   :=  ''
cRefProcDe  :=  ''
cIndProcDe  :=  ''
cFilProc    :=  ''
lOK         := .T.

oJsonResp	:=  JsonObject():New()

// VaLida source branch 
If VldExecute( self:sourceBranch, @oJsonResp, @cFilProc )  
    If valtype( self:referencedProcessesOf ) <> 'U' .and. !empty(self:referencedProcessesOf)
        cRefProcDe  :=  self:referencedProcessesOf
    Else
        lOk := .F.
    EndIf

    If valtype( self:processOriginIndicatorOf ) <> 'U' .and. !empty(self:processOriginIndicatorOf)
        cIndProcDe  :=  self:processOriginIndicatorOf
    Else
        lOk := .F.
    EndIf

    If lOK    
        getWS032(oJsonResp, cRefProcDe, cRefProcDe, cIndProcDe, cIndProcDe, cFilProc, @lOk,,,)
        If !lOk
            SetErroJs( @oJsonResp, __cTagJs, , __cUrl, '404' )
        EndIf
    Else
        SetErroJs( @oJsonResp, __cTagJs, , __cUrl, '400',,,,.F. )
    EndIf    
EndIf

cJsonResp := FwJsonSerialize( oJsonResp ) //Serializa objeto Json
Self:SetResponse( cJsonResp )
freeobj(oJsonResp)
cJsonResp := ''
 
Return .t.

/*
Metodo responsável por persistir um lista ( inclusão / alteração ) os dados cadastro de Processos Referenciados
@author Henrique Fabiano Pateno Pereira
@since 27/08/2020
@version 1.0 
*/ 
WSMETHOD POST tsiReferentialProcesses WSREST tsiReferentialProcesses 
    WsTSIProc( self, .F., __oHashC1G )
return .T.

/*
Metodo responsável por persistir operações de alteração de cadastro de Processos Referenciados
@author Henrique Fabiano Pateno Pereira
@since 27/08/2020
@version 1.0 
*/ 
WSMETHOD PUT tsiReferentialProcesses WSREST tsiReferentialProcesses 
    WsTSIProc( self, .F., __oHashC1G ) 
Return .t.

/*
Metodo responsável por persistir operações de deleção do Cadastro de Inscrição do Estabelecimento Substituto 
@author Henrique Fabiano Pateno Pereira
@since 15/07/2020
@version 1.0 
*/ 
WSMETHOD DELETE tsiReferentialProcesses WSREST tsiReferentialProcesses 
Local cJsonResp     as character
Local cSeek         as character
Local cFilProc      as character
Local oBjJson       as object 
Local oJsonResp	    as object 
Local aRetJs        as array
Local aNames        as array 
Local nGetNames     as numeric
Local cBody         as character

 
cJsonResp     := ""
cSeek         := ""
cFilProc      := ""
oBjJson       := JsonObject():New()
oJsonResp	  := JsonObject():New()
aRetJs        :=  {}
nGetNames     := 0
aNames        := {} 
cBody         := ""  
// valida sourceBranch eviado
if VldExecute( self:sourceBranch, @oJsonResp, @cFilProc )
    
    // obtem o body contendo a tag de id dos cadastros que serão deletados
    cBody := self:GetContent( ) 
    oBjJson:fromJSON( cBody )

    if len(oBjJson:GetNames())>0
        
        for nGetNames := 1 to len(oBjJson:GetNames())             
            aNames := oBjJson:GetJsonObject( oBjJson:GetNames()[nGetNames] )
            if  oBjJson:GetNames()[nGetNames] == __cTagJs
                Ws032Del( aNames, cFilProc, @aRetJs, @oJsonResp ) 
            endif 
        next

    else
        SetErroJs( @oJsonResp,,,,'400' )
    endif
endif

//------------------------------------------------------------------- 
// Serializa objeto Json 
//-------------------------------------------------------------------
cJsonResp := FwJsonSerialize( oJsonResp )
Self:SetResponse( cJsonResp )   
freeobj(oJsonResp)
Return .t.

/*--------------------------------------------------------------------------------
{Protheus.doc} HashProcRef()
(Cria Hash de "De|Para" do identificador do Json para o campo de gravação no TAF)
@author Henrique Pereira
@since 27/08/2020
@return Nil, nulo, não tem retorno.
//------------------------------------------------------------------------------*/
Function HashProcRef()

Local oHash     As Object
Local cSeek     As Char
Local cKey      As Char
Local cTmNrPro  As Char
Local cTmIndPro As Char

cTmNrPro  := cValToChar( GetSx3Cache( "C1G_NUMPRO", "X3_TAMANHO" ) )
cTmIndPro := cValToChar( GetSx3Cache( "C1G_INDPRO", "X3_TAMANHO" ) )

oHash := HMNew( )

cKey := " padr(aObjJson['processNumber']," + cTmNrPro+ ")+" //C1G_NUMPRO
cKey += " padr(aObjJson['processOriginIndicator']," + cTmIndPro+ ")" //C1G_INDPRO

cSeek := " C1G->(DbSeek(xfilial('C1G')+ " //C1G_FILIAL
cSeek += " padr(aObjJson['processNumber']," + cTmNrPro + ")+" //C1G_NUMPRO 
cSeek += " padr(aObjJson['processOriginIndicator']," + cTmIndPro+ ") ))" //C1G_INDPRO 

// Infos genéricas
HMSet(oHash, 'm_o_d_e_l_'         , 'MODEL_C1G'           )
HMSet(oHash, 's_o_u_r_c_e_'       , 'TAFA051'             )
HMSet(oHash, 'a_r_e_a_'           , 'C1G'                 )
HMSet(oHash, 'o_r_d_e_r_'         , 1                     ) //C1G_FILIAL, C1G_NUMPRO, C1G_INDPRO
HMSet(oHash, 'k_e_y_'             , cKey                  )
HMSet(oHash, 't_a_g_i_d_'         , "referencedProcesses" )
HMSet(oHash, 's_e_e_k_'           , cSeek                 )
HMSet(oHash, 'f_i_e_l_d_i_d_'     , "C1G_NUMPRO"          )
HMSet(oHash, 's_u_b_m_o_d_e_l_'   , {{'MODEL_T5L'/*model filho*/,'suspension' /* tag filho*/, 'HashT5L()' /* hash filho*/ }} )

// Propriedades e Campos
SetHashKey(oHash, 'processNumber'          , 'C1G_NUMPRO')
SetHashKey(oHash, 'processOriginIndicator' , 'C1G_INDPRO') //0Sefaz 1J.Federal 2J.Est 3Secex 9Outros
SetHashKey(oHash, 'courtIdentification'    , 'C1G_VARA')
SetHashKey(oHash, 'processType'            , 'C1G_TPPROC') //1Jud 2Adm 3DCom,NB 4 FAP
SetHashKey(oHash, 'state'                  , 'C1G_UFVARA#F3#')
SetHashKey(oHash, 'cityCode'               , 'C1G_CODMUN#F3#')
SetHashKey(oHash, 'proceduralStart'        , 'C1G_DTINI') //C 6 @R 99/9999
SetHashKey(oHash, 'proceduralEnd'          , 'C1G_DTFIN') //C 6 @R 99/9999
SetHashKey(oHash, "versao" 		           , "C1G_VERSAO")
SetHashKey(oHash, "stamp" 		           , "C1G_STAMP")
SetHashKey(oHash, "id" 		               , "C1G_ID")
SetHashKey(oHash, "branch"	               , "C1G_FILIAL")
SetHashKey(oHash, "opCancelation"          , "") // tag de controle: 5-Excluir 0-Não excluir 

HMSet(oHash, '#F3#C1G_UFVARA', "getTafId( 'C09', aObjJson['state'], 1 )") //C09_FILIAL, C09_UF
HMSet(oHash, '#F3#C1G_CODMUN', "getTafId( 'C07', getTafId( 'C09', aObjJson['state'], 1 )+aObjJson['cityCode'], 1 )") //C07_FILIAL, C07_UF, C07_CODIGO

//Posicione ( utilizado no get )
HMSet(oHash, 'C1G_UFVARA#POSIC#', "Posicione('C09', 3, xFilial('C09') + &('oMdl:GetValue(aStruct[nStruct][1])'), 'C09_UF' )") 
HMSet(oHash, 'C1G_CODMUN#POSIC#', "Posicione('C07', 3, xFilial('C07') + &('oMdl:GetValue(aStruct[nStruct][1])'), 'C07_CODIGO' )") 

Return oHash

/*--------------------------------------------------------------------------------
{Protheus.doc} HashT5L()
Cria Hash de "De|Para" do identIficador do Json para o campo de gravação no TAF

@author Denis Souza
@since 25/10/2021
@return Nil, nulo, não tem retorno.
//------------------------------------------------------------------------------*/
Function HashT5L()

Local oHash   := HMNew( )

// Propriedades e Campos
SetHashKey(oHash, 'suspensionIndicativeCode', 'T5L_CODSUS')
SetHashKey(oHash, 'suspensionIndicativeInfo', 'T5L_INDDEC#F3#')
SetHashKey(oHash, 'decisionDate'            , 'T5L_DTDEC#DT#')
SetHashKey(oHash, 'fullAmount'              , 'T5L_INDDEP')
SetHashKey(oHash, "opCancelation"           , "") // tag de controle: 5-Excluir 0-Não excluir 

//#F3# usado na gravação ou alteração dos tributos dos itens
HMSet(oHash, '#F3#T5L_INDDEC', "getTafId( 'C8S', aObjJson['suspensionIndicativeInfo'], 2 )") //C8S_FILIAL, C8S_CODIGO

//Posicione ( utilizado no get )
HMSet(oHash, 'T5L_INDDEC#POSIC#', "Posicione('C8S', 1, xFilial('C8S') + &('oMdl:GetValue(aStruct[nStruct][1])'), 'C8S_CODIGO' )") 

Return oHash

/*
Função responsável por executar a consulta ao cadastro de Processos Referenciados
@author Henrique Fabiano Pateno Pereira
@since 27/08/2020
@version 1.0 
*/ 
function GetPorcProcces( cItemDe, cItemAte, nPage, nPageSize, cOrder, cFilProc, cIndProcDe, cIndProcAte )
Local cQry          as character
Local cAlias        as character

Default cItemDe     :=  ''
Default cItemAte    :=  ''
Default cOrder      :=  ''
Default cFilProc    :=  ''
Default cIndProcDe  :=  ''
Default cIndProcAte :=  ''
Default nPage       := 0 
Default nPageSize   := 0 

cAlias  := getNextAlias()
cQry :=  GetQry(cItemDe, cItemAte, nPage, nPageSize, cOrder, cFilProc, cIndProcDe, cIndProcAte)   
dbUseArea(.T., "TOPCONN", TCGenQry(, , cQry), cAlias, .F., .T.)  

Return cAlias

/*
Função responsável por montar a consulta ao cadastro de Processos Referenciados
@author Henrique Fabiano Pateno Pereira
@since 27/08/2020
@version 1.0 
*/ 

static function GetQry(cItemDe, cItemAte, nPage, nPageSize, cOrder, cFilProc, cIndProcDe, cIndProcAte) 
Local cQry  as character

cQry    := ''

if nPage == 0 
    nPage := 1
endif

if nPageSize == 0
    nPageSize := 10
endif
if Empty(cItemAte)
    cItemAte := 'ZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZ'
endif

if Empty(cIndProcAte)
    cIndProcAte := 'ZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZ'
endif
 
cQry  += " SELECT "
cQry  += " C1G.C1G_NUMPRO,  "
cQry  += " C1G.C1G_INDPRO,  " 
cQry  += " C1G.C1G_VARA,    "
cQry  += " C1G.C1G_TPPROC,  "
cQry  += " C1G.C1G_UFVARA,  "
cQry  += " C1G.C1G_CODMUN,  "
cQry  += " C1G.C1G_DTINI ,  "
cQry  += " C1G.C1G_DTFIN ,  "
cQry  += " C1G.C1G_ID ,  "
cQry  += " C1G.C1G_STAMP,  "
cQry  += " C1G.R_E_C_N_O_ RECNO  "
cQry  += " FROM " + RetSqlName("C1G") + " C1G "
cQry  += " where C1G.C1G_FILIAL = '"+xFilial("C1G") +"'" 
cQry  += " AND C1G.C1G_ATIVO <> '2' " 
cQry  += " AND C1G.D_E_L_E_T_ = ' ' "
cQry  += " AND C1G.C1G_NUMPRO BETWEEN '"+cItemDe+"' AND '"+cItemAte+"' "
cQry  += " AND C1G.C1G_INDPRO BETWEEN '"+cIndProcDe+"' AND '"+cIndProcAte+"' "

if !empty(cOrder) .and. !('getTafId' $ cOrder)
   cQry  += " ORDER BY C1G."+cOrder 
else
    cQry  += " ORDER BY 1 "
endif
cQry  += " OFFSET ( "+cValToChar(nPage-1)+" * "+cValToChar(nPageSize)+" ) ROWS "
cQry  += " FETCH NEXT "+cValToChar(nPageSize+1)+" ROWS ONLY "  

Return cQry 

/*----------------------------------------------------------------------
{Protheus.doc} Ws032Del()
Função que via modelo a entidade C1G TAFA051
@author Henrique Pereira
@since 27/08/2020
@return Nil, nulo, não tem retorno.
//----------------------------------------------------------------------*/

static function Ws032Del(aObjJson, cFilProc, aRetJs, oJsonResp) 
Local nI            :=  0
Local nTamProc      :=  0
Local nTamIndP      :=  0
Local cProperty     :=  ''
Local lSucessItem   :=  .f.
Local lOk           :=  .f.
Local cCodErro      :=  '' 
Local cErro         :=  ''
Local aTags         :=  {}  
Local oModel        := FwLoadModel( 'TAFA051' )   

oJsonResp[__cTagJs] := {}    
nTamProc    := TamSx3('C1G_NUMPRO')[1] 
nTamIndP    := TamSx3('C1G_INDPRO')[1]
    
    for nI := 1 to Len( aObjJson )
                  
        DBSelectArea( "C1G" ) 
        DBSetOrder( 1 )        

        //valida o bodu enviado
        lOk := valtype( aObjJson[nI]['processNumber'] ) <> 'U' .and. !empty( aObjJson[nI]['processNumber'] ) .and. valtype( aObjJson[nI]['processOriginIndicator'] ) <> 'U' //.and. !empty( aObjJson[nI]['processOriginIndicator'] )

        if  lOk
            cSeek :=  padr(aObjJson[nI]['processNumber'],nTamProc)+padr(aObjJson[nI]['processOriginIndicator'],nTamIndP)
            // executa o seek ao registro que será deletado e o deleta se encontrar
            if C1G->( DbSeek( xfilial( 'C1G') + cSeek )) 
                oModel:SetOperation( MODEL_OPERATION_DELETE )
                oModel:Activate( )
                FwFormCommit( oModel )
                oModel:DeActivate( ) 
                lSucessItem := .t.
                aadd( aRetJs,{ lSucessItem ,aObjJson[nI]['processNumber'], aObjJson[nI]['processOriginIndicator']} )  
                aadd(aTags,{'processNumber','processOriginIndicator'}) 
            else
                // o seek falhou, prepara e mensagem json de resposta insformando que o item não foi encontrado na base de dados
                lSucessItem := .f. 
                cCodErro := 'NOTEXIST'
                cProperty := aObjJson[nI]["unitFederativeId"]    

                cErro := RetErroTaf( cProperty, aObjJson[nI], 'unitFederativeId' , cCodErro, aObjJson[nI]['unitFederativeId'] )
                aadd(aRetJs,{ lSucessItem ,aObjJson[nI]['unitFederativeId'], cCodErro, cErro} ) 
                aadd(aTags,{'processNumber','processOriginIndicator'}) 
            endif 
            // aadd(aRetJs,{ lSucessItem ,aObjJson[nI]['unitFederativeId'], cCodErro, cErro} ) 
            if len( aRetJs ) > 0                       
                SetErroJs(@oJsonResp, __cTagJs, aRetJs,,"403",,,aTags) 
                aRetJs := {}
            endif 
        else
            SetErroJs( @oJsonResp,,,__cUrl, )
        EndIf   
    next
return

/*----------------------------------------------------------------------
{Protheus.doc} getWS032()
Executa a query de consulta para o retorno ao método get dos processos referenciados, e monta o jason de resposta
@author Karen Honda
@since 03/12/2021
//----------------------------------------------------------------------*/
Function getWS032(oJsonResp, cRefProcDe, cRefProcAte,cIndProcDe, cIndProcDe, cFilProc, lOk, nPage, nPageSize, xOrder)
         
Local cAlias     as Character
Local cOrder     as Character
Local nPageAux   as Numeric
Local nlA        as Numeric
Local nlB        as Numeric
Local lHasNext   as Logical
Local aStructC1G as array
Local aStructT5L as array

Local oModel     as Object
Local oMdlC1G    as Object
Local oMdlT5L    as Object

Local oJsonT5L   as Object
Local nTmT5L     as Numeric

Default cRefProcDe := ""
Default cRefProcAte := ""
Default cIndProcDe := "" 
Default cIndProcDe := ""
Default cFilProc := ""
Default nPage     := 0
Default nPageSize := 10
Default xOrder    := ''

cAlias     := ''
cOrder     := ''
nPageAux   := 0
nlA        := 0
nlB        := 0
lHasNext   := .F.

oJsonT5L  := JsonObject():New()

oModel  := Nil
oMdlC1G := Nil
oMdlT5L := Nil

//monto As estruturas para serem passadas a getJson
aStructC1G := C1G->(DBStruct())
aStructT5L := T5L->(DBStruct())

If !Empty(xOrder)
    hmget( __oHashC1G, xOrder, @cOrder )
EndIf    
If !Empty(cOrder)
    cOrder := StrTran(StrTran(cOrder, "#DT#", ""),"#F3#", "")
EndIf

// query dos processos
cAlias := GetPorcProcces(cRefProcDe, cRefProcAte, nPage, nPageSize, cOrder, cFilProc, cIndProcDe, cIndProcDe)

DbSelectArea("C1G")
C1G->(dbSetOrder(3)) //C1G_FILIAL, C1G_ID, C1G_VERSAO, C1G_ATIVO

//Carrega Modelo fora do laco
oModel := FwLoadModel( 'TAFA051' )  

while (cAlias)->(!eof())
    C1G->(DbGoTo((cAlias)->RECNO ))
    nPageAux++
    lOk := .T.
    oModel:SetOperation( 1 )
    oModel:Activate()

    oMdlC1G := oModel:GetModel("MODEL_C1G")

    If nPageAux <= nPageSize
        /*-----------------------------------
        |               CAPA                |
        ------------------------------------*/
        TsiGetJson( @oJsonResp, __oHashC1G, aStructC1G, @oMdlC1G, __cTagJs, nPageAux,"referencedProcesses|suspension|" )
        /*-----------------------------------
        |               FILHO                |
        ------------------------------------*/
        oMdlT5L := oModel:GetModel("MODEL_T5L")
        nTmT5L  := oMdlT5L:Length()
        
        for nlA := 1 to nTmT5L
            oMdlT5L:GoLine( nlA )
            TsiGetJson( @oJsonT5L, __oHashT5L, aStructT5L, @oMdlT5L, 'suspension', nlA, "referencedProcesses|suspension|" )
        next nlA

    Else
        lHasNext := .T.
    EndIf
    oJsonResp[__cTagJs][len(oJsonResp[__cTagJs])]['suspension']:=  oJsonT5L['suspension']

    oModel:DeActivate()

    (cAlias)->(DbSkip())
EndDo

oJsonResp["hasnext"] := lHasNext

If Select(cAlias) > 0; (cAlias)->(dbCloseArea()); EndIf

Return oJsonResp
