#include "protheus.ch"

// posições do aTabsTmp
#define ALIAS_TEMP  1
#define ARQ_TAB     2
#define INDEX1      3
#define INDEX2      4

// posições do aData
#define ALIAS_TB    1
#define SEMSX3      2
#define ALIAS_TMP   3
#define IND_TMP     4

function EasyTemporaryTable()
return

/*/{Protheus.doc} EasyTemporaryTable
    Classe para controle de arquivos temporarios

    @author bruno kubagawa
    @since 25/04/2023
    @version 1.0
/*/
class EasyTemporaryTable

    data cClassName
    data aTabsTmp
    data aData

    method New()
    method Destroy()
    method CreateTmp()
    method EraseTmp() 
    method ClearTmp()
    method GetData()
    method SetData()

end class

/*/{Protheus.doc} New
    Método construtor da classe EasyTemporaryTable

    @author bruno kubagawa
    @since 25/04/2023
    @version 1.0
    @param nenhum
    @return self, objeto da classe, EasyTemporaryTable
/*/
method New() class EasyTemporaryTable

    EasyTemporaryTable()

    self:cClassName := "EasyTemporaryTable"
    self:aTabsTmp := {}
    self:aData := {}

return self

/*/{Protheus.doc} Destroy
    Método limpar as propriedades e funcionalidades da classe

    @author bruno kubagawa
    @since 25/04/2023
    @version 1.0
    @param nenhum 
    @return nenhum
/*/
method Destroy() class EasyTemporaryTable

    self:EraseTmp()

    aSize(self:aTabsTmp, 0)
    self:aTabsTmp := {}

    aSize(self:aData, 0)
    self:aData := {}

return nil

/*/{Protheus.doc} CreateTmp
    Método para criação do arquivo temporario no banco

    @author bruno kubagawa
    @since 25/04/2023
    @version 1.0
    @param nenhum
    @return nenhum
/*/
method CreateTmp(cAliasTmp) class EasyTemporaryTable
    local aBckCampo  := if( isMemVar( "aCampos" ), aClone( aCampos ), {})
    local aData      := self:getData()
    local nPosTmp    := 0
    local nAliasTmp  := 0
    local cAliasTab  := ""
    local aIndexTmp  := {}
    local cArqTab    := ""
    local cIndExt    := ""
    local cIndex1    := ""
    local cIndex2    := ""
    local cIndex3    := ""
    local cIndex4    := ""

    default cAliasTmp  := ""

    aData := self:getData()
    if !empty(cAliasTmp) .and. (nPosTmp := aScan( aData, { |X| alltrim(upper(X[ALIAS_TMP])) == alltrim(upper(cAliasTmp)) } ) ) > 0 
        aData := {aData[nPosTmp]}
    endif

    for nAliasTmp := 1 to len(aData)
        cAliasTab := aData[nAliasTmp][ALIAS_TB] // 1
        aSemSX3 := aData[nAliasTmp][SEMSX3] // 2
        cAliasTmp := aData[nAliasTmp][ALIAS_TMP] // 3
        aIndexTmp := aData[nAliasTmp][IND_TMP] // 4
        cArqTab := ""
        cIndExt := ""
        cIndex := ""
        cIndex1 := ""
        cIndex2 := ""
        cIndex3 := ""
        cIndex4 := ""

        if Select(cAliasTmp) == 0
            aCampos := {}

            cArqTab := e_criatrab(cAliasTab, aSemSX3, cAliasTmp )

            if len(aIndexTmp) > 0

                cIndExt := TEOrdBagExt()
                IndexTmp(cAliasTmp, aIndexTmp[1], cArqTab, 1, cIndExt)

                if len(aIndexTmp) == 1 
                    SET INDEX TO (cArqTab+cIndExt)
                elseif len(aIndexTmp) == 2
                    cIndex1 := IndexTmp(cAliasTmp, aIndexTmp[2], cArqTab, 2, cIndExt)
                    SET INDEX TO (cArqTab+cIndExt),(cIndex1+cIndExt)
                elseif len(aIndexTmp) == 3
                    cIndex1 := IndexTmp(cAliasTmp, aIndexTmp[2], cArqTab, 2, cIndExt)
                    cIndex2 := IndexTmp(cAliasTmp, aIndexTmp[3], cArqTab, 3, cIndExt)
                    SET INDEX TO (cArqTab+cIndExt),(cIndex1+cIndExt),(cIndex2+cIndExt)
                elseif len(aIndexTmp) == 4
                    cIndex1 := IndexTmp(cAliasTmp, aIndexTmp[2], cArqTab, 2, cIndExt)
                    cIndex2 := IndexTmp(cAliasTmp, aIndexTmp[3], cArqTab, 3, cIndExt)
                    cIndex3 := IndexTmp(cAliasTmp, aIndexTmp[4], cArqTab, 4, cIndExt)
                    SET INDEX TO (cArqTab+cIndExt),(cIndex1+cIndExt),(cIndex2+cIndExt),(cIndex3+cIndExt)
                elseif len(aIndexTmp) == 5
                    cIndex1 := IndexTmp(cAliasTmp, aIndexTmp[2], cArqTab, 2, cIndExt)
                    cIndex2 := IndexTmp(cAliasTmp, aIndexTmp[3], cArqTab, 3, cIndExt)
                    cIndex3 := IndexTmp(cAliasTmp, aIndexTmp[4], cArqTab, 4, cIndExt)
                    cIndex4 := IndexTmp(cAliasTmp, aIndexTmp[5], cArqTab, 5, cIndExt)
                    SET INDEX TO (cArqTab+cIndExt),(cIndex1+cIndExt),(cIndex2+cIndExt),(cIndex3+cIndExt),(cIndex4+cIndExt)                    
                endif

            endif

            /*
                ALIAS_TEMP  1
                ARQ_TAB     2
                INDEX1      3
                INDEX2      4
            */
            aAdd( self:aTabsTmp, {cAliasTmp, cArqTab, cIndex1, cIndex2, cIndex3, cIndex4 })
        endif

    next nAliasTmp

    if( len(aBckCampo) > 0, aCampos := aClone(aBckCampo), nil)

return 

/*/{Protheus.doc} EraseTmp
    Método para exclusão do arquivo temporario no banco

    @author bruno kubagawa
    @since 25/04/2023
    @version 1.0
    @param nenhum
    @return nenhum
/*/
method EraseTmp() class EasyTemporaryTable
    local nTab       := 0
    local cAliasTmp  := ""
    local cTabArq    := ""
    local cIndex1    := ""
    local cIndex2    := ""

    for nTab := 1 to len(self:aTabsTmp)
        cAliasTmp := self:aTabsTmp[nTab][ALIAS_TEMP] // 1
        cTabArq := self:aTabsTmp[nTab][ARQ_TAB] // 2
        cIndex1 := if(empty(self:aTabsTmp[nTab][INDEX1]),nil,self:aTabsTmp[nTab][INDEX1]) // 3
        cIndex2 := if(empty(self:aTabsTmp[nTab][INDEX2]),nil,self:aTabsTmp[nTab][INDEX2]) // 4
        if select(cAliasTmp) > 0
            (cAliasTmp)->(E_EraseArq(cTabArq, cIndex1, cIndex2))
        endif
    next

return 

/*/{Protheus.doc} ClearTmp
    Método para limpeza do arquivo temporario no banco

    @author bruno kubagawa
    @since 25/04/2023
    @version 1.0
    @param cAliasTmp, caractere, alias do arquivo temporario
    @return nenhum
/*/
method ClearTmp(cAliasTmp) class EasyTemporaryTable
    default cAliasTmp := ""

    if( !empty(cAliasTmp), if( select(cAliasTmp) > 0, AvZap(cAliasTmp), self:createTmp(cAliasTmp)), nil)

return self

/*/{Protheus.doc} SetData
    Método para setar informações dos arquivos temporarios

    @author bruno kubagawa
    @since 25/04/2023
    @version 1.0
    @param  cAliasTab, caractere, nome da tabela fisica
            aSemSX3, array, vetor que não estão no SX3 da tabela física
            cAliasTmp, caractere, alias do arquivo temporario
            aIndex, array, vetor para os indices da tabela temporaria (máximo 3)
    @return nenhum
/*/
method SetData(cAliasTab, aSemSX3, cAliasTmp, aIndex) class EasyTemporaryTable
    default cAliasTab := ""
    default aSemSX3   := {}
    default cAliasTmp := ""
    default aIndex    := {}

    if !empty(cAliasTmp) .and. len(aIndex) > 0 .and. aScan(self:aData, { |X| alltrim(upper(X[2])) == alltrim(upper(cAliasTmp)) } ) == 0
        /*
        ALIAS_TB    1
        SEMSX3      2
        ALIAS_TMP   3
        IND_TMP     4
        */
        aAdd( self:aData, {cAliasTab, aSemSX3, cAliasTmp, aIndex} )
    endif

return

/*/{Protheus.doc} GetData
    Método para recuperar informações dos arquivos temporarios

    @author bruno kubagawa
    @since 25/04/2023
    @version 1.0
    @param nenhum
    @return aData, array, vetor com os dados do aData
/*/
method GetData() class EasyTemporaryTable
return aClone(self:aData)

/*/{Protheus.doc} IndexTmp
    Função para criação de indice para o arquivo temporario

    @author bruno kubagawa
    @since 25/04/2023
    @version 1.0
    @param nenhum
    @return nenhum
/*/
static function IndexTmp(cAliasTmp, cFieldInd, cIndexArq, nOrder, cIndExt)
    local cIndex := ""

    default cIndexArq := ""
    default cIndExt   := TEOrdBagExt()

    if !empty(cAliasTmp) .and. !empty(cFieldInd)
        cIndex := if( nOrder == 1, cIndexArq, e_create(,.F., cAliasTmp, cIndexArq, nOrder))
        E_IndRegua( cAliasTmp , cIndex+cIndExt, cFieldInd)
    endif

return cIndex
