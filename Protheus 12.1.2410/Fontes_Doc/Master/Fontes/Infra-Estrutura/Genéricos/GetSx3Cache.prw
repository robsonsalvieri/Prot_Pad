#include "protheus.ch"
#DEFINE FIELD_CBOX		"X3_CBOX|X3_CBOXSPA|X3_CBOXENG"
#DEFINE FIELD_DESCRIC	"X3_DESCRIC|X3_DESCSPA|X3_DESCENG" 
#DEFINE FIELD_TITULO	"X3_TITULO|X3_TITENG|X3_TITSPA"
static __oHashSX3Pos
static __oHashCache := initSx3Cache()
//Atencão a funcao de inicialização static precisar sempre ser chamada depois de todas a declaracoes de staticas

//-------------------------------------------------------------------
/*/{Protheus.doc} initSx3Cache
Inicializa o cache se for possivel

/*/
//-------------------------------------------------------------------
static function initSx3Cache()    
    if __oHashCache == Nil
        __oHashSX3Pos:= JsonObject():New()
        __oHashCache := JsonObject():New()
    endif
return __oHashCache
//-------------------------------------------------------------------
/*/{Protheus.doc} _GtSx3Cached
Refactory da SuperGetMV

@author  Rodrigo Antonio - Eng. Protheus
@param cSX3Campo
@param cCampo
@return Se existir retorna o conteudo do campo
/*/
//-------------------------------------------------------------------

function _GtSx3Cached(cSX3Campo,cCampo) 
    local xResultado
    local cKey
    local nFieldPosOnSX3
    Local lRetIdom := cCampo  $ (FIELD_CBOX+"|"+FIELD_DESCRIC+"|"+ FIELD_TITULO)

    cSX3Campo := PadR( cSX3Campo , 10 )    
    cKey := cCampo + cSX3Campo + iif(lRetIdom, fwRetIdiom(),"")
    if (xResultado := __oHashCache[cKey]) == nil 
        //Busca no Cache de fieldpos a coluna do SX3        
        if (nFieldPosOnSX3 := __oHashSX3Pos[cCampo]) == nil 
            nFieldPosOnSX3 := SX3->( FieldPos( cCampo ) )
            if (nFieldPosOnSX3 == 0)
                UserException("Invalid SX3 field.")
            Endif

            __oHashSX3Pos[cCampo] := nFieldPosOnSX3
            
        endif
        If cSX3Campo != SX3->X3_CAMPO
            nOrdSX3 := SX3->( IndexOrd() )
            if nOrdSX3 != 2
                SX3->( dbSetOrder( 2 ) )
            endif
            If SX3->( MsSeek( cSX3Campo ) )
                If lRetIdom
                    xResultado :=_sx3SetIdi(cCampo)
                Else
                    xResultado := SX3->( FieldGet( nFieldPosOnSX3 ) )
                Endif
                __oHashCache[cKey] := xResultado
            EndIf
            if nOrdSX3 != 2
                SX3->( dbSetOrder( nOrdSX3 ) )
            endif
        Else
            If lRetIdom
                xResultado :=_sx3SetIdi(cCampo)
            Else
                xResultado := SX3->( FieldGet( nFieldPosOnSX3 ) )
            Endif
            __oHashCache[cKey] := xResultado
        Endif
    endif
    
return xResultado


//-------------------------------------------------------------------
/*/{Protheus.doc} _sgetmvreset
Limpa o cache da GetSx3Cache
@author  Rodrigo Antonio - Eng. Protheus

/*/
//-------------------------------------------------------------------
function _sgtsx3reset()    
    __oHashCache:FromJson('{}')
return

/*/{Protheus.doc} _sx3SetIdi
	Efetua o tratamento nos campos que tem tratamento de idioma e retorna os valores no idioma correto para o cache
	@type  Static Function
	@author eduardo.Flima
	@since 12/04/2025
	@version 12
	@param cField	, Character	, Nome do campo a ser tratado
	@return cValue	, Character	, Valor no idioma corrente do sistema
/*/
Static Function _sx3SetIdi(cField as Character)
	Local cValue := "" as Character 	
	Do Case
	Case ( cField $ FIELD_CBOX )
		cValue := X3CBox()
	Case ( cField $ FIELD_DESCRIC )
		cValue := X3Descric()
	Case ( cField $ FIELD_TITULO )
		cValue := X3Titulo()
	EndCase
Return cValue

