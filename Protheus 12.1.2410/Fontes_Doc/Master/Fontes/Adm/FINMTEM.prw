#Include 'Protheus.ch'
#INCLUDE 'FWMVCDEF.CH' 
#include 'FINMTEM.ch'

Static __cMaster As Character
Static __cDetail As Character
Static __aRelation As Array
Static __aPK As Array

//-------------------------------------------------------------------
/*/{Protheus.doc} FINMTEM
    Modelo de dados generico utilizado nas API's

    @author Vinicius do Prado
    @since Abr|2022
    @version 12
/*/
//-------------------------------------------------------------------
Function FINMTEM()

Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} ModelDef
    Definição do modelo de dados.

    @author Vinicius do Prado
    @since Abr|2022
    @version 12
/*/
//-------------------------------------------------------------------
Static Function ModelDef()
    Local oModel  As Object
    Local oMaster As Object
    Local oDetail As Object

    If Empty(__cMaster)
        oMaster := FWFormStruct( 1, 'SEH')
    Else
        oMaster := FWFormStruct( 1, __cMaster )
    EndIf

    oModel := MPFormModel():New('FINMTEM')
    oModel:SetDescription(STR0003) //"Modelo de dados genérico"  

    oModel:addFields('MASTER',,oMaster)

    If !Empty(__aPK)
        oModel:SetPrimaryKey(__aPK)
    Endif

    If !Empty(__cDetail)
        oDetail := FWFormStruct( 1, __cDetail )
        
        oModel:addGrid('DETAIL','MASTER',oDetail)
        If !Empty(__aRelation)
            DbSelectArea(__cDetail)
            oModel:SetRelation('DETAIL',__aRelation, IndexKey(1) )
        Endif
    Endif  

Return oModel

/*/{Protheus.doc} SetMaster
    Preenche a variavel estatica da tabela MASTER do MVC
    @type  Function
    @author Vitor Duca
    @since 21/06/2022
    @version 1.0
    @param cMaster, Character, Tabela que sera usada como MASTER no MVC
/*/
Function SetMaster(cMaster As Character)
    __cMaster := cMaster
Return 

/*/{Protheus.doc} SetDetail
    Preenche a variavel estatica da tabela DETAIL do MVC
    @type  Function
    @author Vitor
    @since 21/06/2022
    @version 1.0
    @param cDetail, Character, Tabela que sera usada como DETAIL no MVC
/*/
Function SetDetail(cDetail As Character)
    __cDetail := cDetail
Return 

/*/{Protheus.doc} SetRelation
    Preenche a variavel estatica de relacionamento entre a DETAIL e MASTER do MVC
    @type  Function
    @author Vitor Duca
    @since 21/06/2022
    @version 1.0
    @param aRelation, Array, Relacionamento entre as tabelas
/*/
Function SetRelation(aRelation As Array)
    __aRelation := aRelation
Return 

/*/{Protheus.doc} SetPKModel
    (long_description)
    @type  Function
    @author user
    @since 02/11/2022
    @version version
    @param param_name, param_type, param_descr
    @return return_var, return_type, return_description
    @example
    (examples)
    @see (links_or_references)
    /*/
Function SetPKModel(aPK As array)
    __aPK := aPK
Return 
