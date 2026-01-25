#INCLUDE "TOTVS.CH"
#INCLUDE "FWMVCDEF.CH"

/*/{Protheus.doc} GFEFreightComponents
Adapter do resource FreightComponents

Verbos disponíveis: POST, GET, PUT, DELETE
@author Leandro Conradi Zmovirzynski

Código Base : TMSGroupOfRegionstAdapter - TMSA115I.prw
@author Izac Silvério Ciszevski
/*/

CLASS GFEFreightComponentsAdapter FROM BaseResourceAdapter
                                       
    METHOD New()
    METHOD FieldMap()
    METHOD SendObject()
    /*
    METHOD ReceiveObject()
    METHOD CreateQuery() 
    */
    METHOD PostAction()
    METHOD PutAction()
    METHOD DeleteAction()

EndClass

METHOD New( oRestObj ) CLASS GFEFreightComponentsAdapter
    Self := _Super:New( oRestObj )
    ::SetMainAlias( "GV2" )

Return Self

METHOD FieldMap() CLASS GFEFreightComponentsAdapter
    Local aFieldMap as Array

    aFieldMap := { ;
                    { "BranchId"                         ,  "GV2_FILIAL"   } ,  ;
                    { "Code"                             ,  "GV2_CDCOMP"   } ,  ;
                    { "Description"                      ,  "GV2_DSCOMP"   } ,  ;
                    { "AttributeForCalculation"          ,  "GV2_ATRCAL"   } ,  ;
                    { "SuframaTable"                     ,  "GV2_TABSUF"   } ,  ;
                    { "ValueCategory"                    ,  "GV2_CATVAL"   } ,  ;
                    { "Service"                          ,  "GV2_SERVI"    } ,  ;
                    { "ValuePerLoadManifest"             ,  "GV2_IDVLRC"   } ,  ;
                    { "DailyValueFreelanceCalculation"   ,  "GV2_VLDIAR"   } ,  ;
                    { "GroupValues"                      ,  "GV2_IDVLAG"   } ,  ;
                    { "ServiceTypeCode"                  ,  "GV2_CDTPSE"   } ,  ;
                    { "CalculateService"                 ,  "GV2_CALSER"   } ,  ;
                    { "CalculationUnitizing"             ,  "GV2_UNIT"     } ;
                }

Return aFieldMap

METHOD SendObject() Class GFEFreightComponentsAdapter
    
    Local aObj := {; 
                    {   "CompanyId"                       ,{ |cAlias, xValue| cEmpAnt                                  } },;
                    {   "BranchId"                        ,{ |cAlias, xValue| cFilAnt                                  } },;
                    {   "InternalId"                      ,{ |cAlias, xValue| ( cAlias )->( GV2_FILIAL + GV2_CDCOMP )  } },;
                    {   "Code"                            ,{ |cAlias, xValue| ( cAlias )->( GV2_CDCOMP )               } },;
                    {   "CompanyInternalId"               ,{ |cAlias, xValue| cEmpAnt + cFilAnt                        } },;
                    {   "Description"                    },;
                    {   "AttributeForCalculation"        },;
                    {   "SuframaTable"                   },;
                    {   "ValueCategory"                  },;
                    {   "Service"                        },;
                    {   "ValuePerLoadManifest"           },;
                    {   "DailyValueFreelanceCalculation" },;
                    {   "GroupValues"                    },;
                    {   "ServiceTypeCode"                },;
                    {   "CalculateService"               },;
                    {   "CalculationUnitizing"           };
                }   
return aObj

METHOD DeleteAction( nRecno ) CLASS GFEFreightComponentsAdapter
    Local aError  := {}
    Local aCampos := {}

    GV2->( DbGoTo (nRecno) )
    If !( lOk := ManutReg( MODEL_OPERATION_DELETE, aCampos, @aError ))
        Self:SetError(aError[5], , aError[6])
    EndIf

Return lOk

METHOD PutAction( nRecno, aCampos ) CLASS GFEFreightComponentsAdapter
    Local aError := {}

    GV2->( DbGoTo (nRecno) )
    If !( lOk := ManutReg( MODEL_OPERATION_UPDATE, aCampos, @aError ))
        Self:SetError(aError[5], , aError[6])
    EndIf

Return lOk

METHOD PostAction( aCampos ) CLASS GFEFreightComponentsAdapter
    Local aError := {}

    If !( lOk := ManutReg( MODEL_OPERATION_INSERT, aCampos, @aError ))
        Self:SetError(aError[5], , aError[6])
    Else
        ::AddFilter( "Code" , GV2->GV2_CDCOMP )
    EndIf

Return lOk

Static Function ManutReg( nOperation, aCampos, aError, cRetorno ) 
    Local lOk := .T.
    Local nCampo := 1
    Local oModel:= Nil 
    Local oModelFields:= Nil 
    Local aError := {}
    Local cFonte := "GFEA060"
    Local cModelo := "GFEA060_GV2"

    Local oModelAnt := FwModelActive()
    
    Default aCampos  := {}
    Default cRetorno := "" 

    BEGIN SEQUENCE

        oModel:= FwLoadModel( cFonte )
        oModel:SetOperation( nOperation )
        oModel:Activate()

        If nOperation != MODEL_OPERATION_DELETE
            lOk := .f.
            oModelFields := oModel:GetModel( cModelo )
            For nCampo := 1 To Len ( aCampos )
                If oModelFields:CanSetValue( aCampos[nCampo][1] )
                    If ! ( lOk := oModelFields:SetValue( aCampos[nCampo][1], aCampos[nCampo][2] ) )
                        Exit
                    EndIf
                EndIf
            Next
        EndIf
        
        If !(lOk .and. (lOk := oModel:VldData() .and. oModel:CommitData() ) ) 
            aError := oModel:getErrorMessage()
            cRetorno := aError[5] + " | " +  aError[7] + " | " + aError[7]
        EndIf

        oModel:Destroy()
    RECOVER
        cRetorno := "MVC - Falha não identificada"
            lOk := .F.
    END SEQUENCE
    
    If ValType( oModelAnt ) == "O"
        FwModelActive( oModelAnt )
    EndIf
Return lOk

