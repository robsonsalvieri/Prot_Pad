#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "TAFA546.CH"

//-------------------------------------------------------------------
/*/{Protheus.doc} TAFA546
Cadastro MVC do R-4020 - Retenções na Fonte - Pessoa Jurídica 
Tabelas espelhos

@author Katielly Feitosa Rezende 		
@since 12/08/2019
@version 1.0
*/
Function TAFA546()

If TAFAlsInDic( "V5C" )
	BrowseDef()
Else
	Aviso(STR0001, TafAmbInvMsg(), { STR0002 }, 3 ) //O ambiente do TAF encontra-se desatualizado. //Finalizar
EndIf

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} MenuDef
Funcao MVC com as opcoes de menu 

@author Katielly Rezende			
@since 12/08/2019
@version 1.0
/*/
Static Function MenuDef()

Local aFuncao   as array
Local aRotina   as array
Local lReinf20  as logical

aFuncao := {}
aRotina := {}
lReinf20 := AllTrim(StrTran(SuperGetMv('MV_TAFVLRE',.F.,''),'_','')) >= '20101'

If lReinf20
	aAdd( aFuncao, { "", "xFunNewHis( 'V5C', 'TAFA546' )", "3" } )
	aAdd( aFuncao, { "", "TAF546Xml", "1" } )
	aAdd( aFuncao, { "", "TAFXmlLote( 'V5C', 'R-4020', 'RetPJ', 'TAF546Xml', 5, oBrowse)", "5" } )
	aRotina := TAFMenuReinf( "TAFA546", aFuncao )
	
	ADD OPTION aRotina Title STR0046 Action 'TAF620Rel' OPERATION 2 ACCESS 0

else
	ADD OPTION aRotina Title STR0045 Action 'VIEWDEF.TAFA546' OPERATION 2 ACCESS 0
EndIf

Return (aRotina ) 

//-------------------------------------------------------------------
/*/{Protheus.doc} ModelDef
Funcao  MVC do model

@return oModel - Objeto do Modelo MVC

@author Katielly Rezende			
@since 12/08/2019
@version 1.0
/*/
Static Function ModelDef()

Local oModel    As object
Local oStrV5C   As object
Local oStrV5Da  As object
Local oStrV5Db  As object
Local oStrV5Dc  As object
Local oStrV4Sa  As object
Local oStrV4Sb  As object
Local oStrV4Sh  As object
Local oStrV4Si  As object
Local oStrV5F   As object
Local oStrV5G   As object

Local cGrpV5Da  As Character
Local cGrpV5Db  As Character
Local cGrpV5Dc  As Character
Local cGrpV4Sa  As Character
Local cGrpV4Sb  As Character
Local cGrpV4Sh  As Character
Local cGrpV4Si  As Character

oModel := MPFormModel():New( 'TAFA546' )

oStrV5C  := FWFormStruct( 1, 'V5C' )

oModel:AddFields( 'MODEL_V5C',, oStrV5C)
oModel:GetModel ( 'MODEL_V5C'):SetPrimaryKey( { 'V5C_PERAPU' } )

//idePgto
cGrpV5Da := "V5D_IDNTRE|V5D_CNATRE|V5D_DNATRE|V5D_OBSERV|"
oStrV5Da := FWFormStruct( 1, 'V5D', {|x| AllTrim( x ) + "|" $ cGrpV5Da} )
oModel:AddGrid ( 'MODEL_V5DA', 'MODEL_V5C', oStrV5Da )
oModel:GetModel( 'MODEL_V5DA' ):SetUniqueLine({ 'V5D_IDNTRE'})
oModel:GetModel( 'MODEL_V5DA' ):SetOptional( .F. )
oModel:GetModel( 'MODEL_V5DA' ):SetMaxLine( 100 )
oModel:SetRelation("MODEL_V5DA", { {"V5D_FILIAL","xFilial('V5D')"}, {"V5D_ID","V5C_ID"}, {"V5D_VERSAO","V5C_VERSAO"}}, V5D->(IndexKey(1)) )

//infoPgtoExt/endExt
cGrpV5Db := "V5D_LOGRAD|V5D_NRLOGR|V5D_COMPLE|V5D_BAIRRO|V5D_CIDADE|V5D_ESTADO|V5D_CEP|V5D_TELEF|"
oStrV5Db := FwFormStruct( 1, 'V5D', {|x| AllTrim( x ) + "|" $ cGrpV5Db} )    
oModel:AddGrid ( 'MODEL_V5DB', 'MODEL_V5DA', oStrV5Db )
oModel:GetModel( 'MODEL_V5DB' ):SetOptional( .t. )
oModel:GetModel( 'MODEL_V5DB' ):SetMaxLine( 1 )
oModel:SetRelation("MODEL_V5DB", { {"V5D_FILIAL","xFilial('V5D')"}, {"V5D_ID","V5C_ID"}, {"V5D_VERSAO","V5C_VERSAO"}, {"V5D_IDNTRE", "V5D_IDNTRE"}} , V5D->(IndexKey(1)) )

//infoPgtoExt/infoFiscal
cGrpV5Dc := "V5D_INDNIF|V5D_NIF|V5D_CTRIB|V5D_DTRIB|V5D_RELPGT|V5D_IDRELP|V5D_DRELPG|V5D_IDTRIB|"
oStrV5Dc := FwFormStruct( 1, 'V5D', {|x| AllTrim( x ) + "|" $ cGrpV5Dc} )
oModel:AddGrid ( 'MODEL_V5DC', 'MODEL_V5DA', oStrV5Dc )    
oModel:GetModel( 'MODEL_V5DC' ):SetOptional( .t. )
oModel:GetModel( 'MODEL_V5DC' ):SetMaxLine( 1 )
oModel:SetRelation("MODEL_V5DC", { {"V5D_FILIAL","xFilial('V5D')"}, {"V5D_ID","V5C_ID"}, {"V5D_VERSAO","V5C_VERSAO"}, {"V5D_IDNTRE", "V5D_IDNTRE"} }, V5D->(IndexKey(1)) )

//infoPgto
cGrpV4Sa := '|V4S_DATAFG|V4S_VLRTOT|V4S_INDJUD|V4S_FCISCP|V4S_NFCISC|V4S_PERSCP|V4S_PAISRE|V4S_DTESCO|V4S_OBSERV|'
oStrV4Sa := FWFormStruct( 1, 'V4S', {|x| AllTrim( x ) + "|" $ cGrpV4Sa} )
oModel:AddGrid ( 'MODEL_V4SA', 'MODEL_V5DA', oStrV4Sa )
oModel:GetModel( 'MODEL_V4SA' ):SetUniqueLine({ 'V4S_DATAFG' })
oModel:GetModel( 'MODEL_V4SA' ):SetOptional( .F. )
oModel:GetModel( 'MODEL_V4SA' ):SetMaxLine( 999 )
oModel:SetRelation("MODEL_V4SA", { {"V4S_FILIAL","xFilial('V4S')"}, {"V4S_ID","V5C_ID"}, {"V4S_VERSAO","V5C_VERSAO"}, {"V4S_IDNTRE" ,"V5D_IDNTRE"} }, V4S->(IndexKey(1)) )

//retenções
cGrpV4Sb  := "V4S_BASEIR|V4S_VLRIR|V4S_BAGREG|V4S_VAGREG|V4S_BCSLL|V4S_VLCSLL|V4S_BCOFIN|V4S_VCOFIN|V4S_BASEPP|V4S_VLRPP|"
oStrV4SB := FWFormStruct( 1, 'V4S', {|x| AllTrim( x ) + "|" $ cGrpV4Sb} )
oModel:AddGrid ( 'MODEL_V4SB', 'MODEL_V4SA', oStrV4SB)
oModel:GetModel( 'MODEL_V4SB' ):SetOptional( .T. )
oModel:GetModel( 'MODEL_V4SB' ):SetMaxLine( 1 )
oModel:SetRelation("MODEL_V4SB", { {"V4S_FILIAL","xFilial('V4S')"}, {"V4S_ID","V5C_ID"}, {"V4S_VERSAO","V5C_VERSAO"}, {"V4S_IDNTRE" ,"V5D_IDNTRE"}, {"V4S_PAISRE", "V4S_PAISRE"}, {"V4S_DATAFG", "V4S_DATAFG"} }, V4S->(IndexKey(1)) )

//infoProcRet
oStrV5F  := FWFormStruct( 1, 'V5F' ) 
oModel:AddGrid ( 'MODEL_V5F', 'MODEL_V4SA', oStrV5F)
oModel:GetModel( 'MODEL_V5F' ):SetUniqueLine({ 'V5F_TPPROC', 'V5F_NRPROC' })
oModel:GetModel( 'MODEL_V5F' ):SetOptional( .T. )
oModel:GetModel( 'MODEL_V5F' ):SetMaxLine( 99 )
oModel:SetRelation("MODEL_V5F" , { {"V5F_FILIAL","xFilial('V5F')"}, {"V5F_ID","V5C_ID"}, {"V5F_VERSAO","V5C_VERSAO"}, {"V5F_IDNTRE" ,"V5D_IDNTRE"}, {"V5F_PAISRE", "V4S_PAISRE"}, {"V5F_DATAFG", "V4S_DATAFG"} }, V5F->(IndexKey(1)) )

//infoProcJud
cGrpV4Sh := "V4S_NRPROC|V4S_ORIREC|V4S_CGCORI|V4S_DESCRI|"
oStrV4Sh := FwFormStruct( 1, 'V4S', {|x| AllTrim( x ) + "|" $ cGrpV4Sh} )    
oModel:AddGrid ( 'MODEL_V4SH', 'MODEL_V4SA', oStrV4Sh )
oModel:GetModel( 'MODEL_V4SH' ):SetOptional( .T. )
oModel:GetModel( 'MODEL_V4SH' ):SetMaxLine( 1 )
oModel:SetRelation("MODEL_V4SH", { {"V4S_FILIAL","xFilial('V4S')"}, {"V4S_ID","V5C_ID"}, {"V4S_VERSAO","V5C_VERSAO"}, {"V4S_IDNTRE" ,"V5D_IDNTRE"}, {"V4S_PAISRE", "V4S_PAISRE"}, {"V4S_DATAFG", "V4S_DATAFG"} }, V4S->(IndexKey(1)) )

//despProcJud
cGrpV4Si := "V4S_VLRCUS|V4S_VLRADV|"
oStrV4Si := FwFormStruct( 1, 'V4S', {|x| AllTrim( x ) + "|" $ cGrpV4Si} )
oModel:AddGrid ( 'MODEL_V4SI', 'MODEL_V4SH', oStrV4Si )
oModel:GetModel( 'MODEL_V4SI' ):SetOptional( .T. )
oModel:GetModel( 'MODEL_V4SI' ):SetMaxLine( 1 )
oModel:SetRelation("MODEL_V4SI", { {"V4S_FILIAL","xFilial('V4S')"}, {"V4S_ID","V5C_ID"}, {"V4S_VERSAO","V5C_VERSAO"}, {"V4S_IDNTRE" ,"V5D_IDNTRE"}, {"V4S_PAISRE", "V4S_PAISRE"}, {"V4S_DATAFG", "V4S_DATAFG"} }, V4S->(IndexKey(1)) )

//ideAdv
oStrV5G  := FWFormStruct( 1, 'V5G' )
oModel:AddGrid ( 'MODEL_V5G', 'MODEL_V4SI', oStrV5G )
oModel:GetModel( 'MODEL_V5G' ):SetUniqueLine({ 'V5G_TPINSC', 'V5G_NRINSC' })
oModel:GetModel( 'MODEL_V5G' ):SetOptional( .T. )
oModel:GetModel( 'MODEL_V5G' ):SetMaxLine( 99 ) 
oModel:SetRelation("MODEL_V5G" , { {"V5G_FILIAL","xFilial('V5G')"}, {"V5G_ID","V5C_ID"}, {"V5G_VERSAO","V5C_VERSAO"}, {"V5G_IDNTRE" ,"V5D_IDNTRE"}, {"V5G_PAISRE", "V4S_PAISRE"}, {"V5G_DATAFG", "V4S_DATAFG"} }, V5G->(IndexKey(1)) )


Return oModel

//---------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
Funcao generica MVC do View

@return oView - Objeto da View MVC

@author Katielly Rezende / Denis Souza
@since 12/08/2019
@version 1.0
/*/
Static Function ViewDef()

Local oModel   As Object
Local oView	   As Object
Local oStrV5Ca As Object
Local oStrV5Cb As Object
Local oStrV5Da As Object
Local oStrV5Db As Object
Local oStrV5Dc As Object
Local oStrV4Sa As Object
Local oStrV4Sb As Object
Local oStrV4Sh As Object
Local oStrV4Si As Object
Local oStrV5F  As Object
Local oStrV5G  As Object

Local cGrpV5Cb As Character
Local cGrpV5Da As Character
Local cGrpV5Db As Character
Local cGrpV5Dc As Character
Local cGrpV4Sa As Character
Local cGrpV4Sb As Character
Local cGrpV4Sh As Character
Local cGrpV4Si As Character
Local cGrpV5F  As Character
Local cGrpV5G  As Character
Local cGrpCom1 As Character
Local cGrpCom2 As Character
Local aCmpGrp1 As Array
Local aCmpGrp2 As Array
Local nI       As Numeric
Local lReinf212 As Logical

lReinf212   := TAFColumnPos( "V5C_EVADIC" )

oModel   := FWLoadModel( 'TAFA546' )
oView    := FWFormView():New()
oStrV5Ca := FWFormStruct( 2, 'V5C')

oStrV5Ca:AddGroup( "GRP_01", STR0040, "", 1 ) //"ideEstab ( Identificação do Estabelecimento )"
oStrV5Ca:AddGroup( "GRP_02", STR0041, "", 1 ) //"ideBenef ( Identificação do Beneficiário do Rendimento )"

cGrpCom1 := "V5C_VERSAO|V5C_VERANT|V5C_PROTPN|V5C_EVENTO|V5C_ATIVO|V5C_PERAPU|V5C_IDESTA|V5C_DESTAB|V5C_TPINSC|V5C_NRINSC|" 
If lReinf212
	cGrpCom1 += "V5C_EVADIC|"
EndIf	
aCmpGrp1 := StrToKArr(cGrpCom1, "|")
For nI := 1 To Len( aCmpGrp1 )
    oStrV5Ca:SetProperty( aCmpGrp1[nI], MVC_VIEW_GROUP_NUMBER, "GRP_01" )
Next nI

cGrpCom2 := "V5C_IDPART|V5C_CNPJBN|V5C_NMBENE|V5C_ISEIMU|"
aCmpGrp2 := StrToKArr(cGrpCom2,"|")
For nI := 1 To Len( aCmpGrp2 )
    oStrV5Ca:SetProperty( aCmpGrp2[nI], MVC_VIEW_GROUP_NUMBER, "GRP_02" )
Next nI

oStrV5Ca:RemoveField( "V5C_ID"     )
oStrV5Ca:RemoveField( "V5C_PROTUL" )
oStrV5Ca:RemoveField( "V5C_XMLID"  )
oStrV5Ca:RemoveField( "V5C_IDPART" )

cGrpV5Cb := "V5C_PROTUL|"
oStrV5Cb := FwFormStruct( 2, 'V5C', {|x| AllTrim( x ) + "|" $ cGrpV5Cb} )

cGrpV5Da := "V5D_IDNTRE|V5D_CNATRE|V5D_DNATRE|V5D_OBSERV|"
oStrV5Da := FwFormStruct( 2, 'V5D', {|x| AllTrim( x ) + "|" $ cGrpV5Da} )

cGrpV5Db := "V5D_LOGRAD|V5D_NRLOGR|V5D_COMPLE|V5D_BAIRRO|V5D_CIDADE|V5D_ESTADO|V5D_CEP|V5D_TELEF|"
oStrV5Db := FwFormStruct( 2, 'V5D', {|x| AllTrim( x ) + "|" $ cGrpV5Db} )

cGrpV5Dc := "V5D_INDNIF|V5D_NIF|V5D_CTRIB|V5D_DTRIB|V5D_RELPGT|V5D_DRELPG|"
oStrV5Dc := FwFormStruct( 2, 'V5D', {|x| AllTrim( x ) + "|" $ cGrpV5Dc} )

cGrpV4Sa := '|V4S_DATAFG|V4S_VLRTOT|V4S_INDJUD|V4S_FCISCP|V4S_NFCISC|V4S_PERSCP|V4S_PAISRE|V4S_DTESCO|V4S_OBSERV|'
oStrV4Sa := FwFormStruct( 2, 'V4S', {|x| AllTrim( x ) + "|" $ cGrpV4Sa} )

cGrpV4Sb := "V4S_BASEIR|V4S_VLRIR|V4S_BAGREG|V4S_VAGREG|V4S_BCSLL|V4S_VLCSLL|V4S_BCOFIN|V4S_VCOFIN|V4S_BASEPP|V4S_VLRPP|"
oStrV4Sb := FwFormStruct( 2, 'V4S', {|x| AllTrim( x ) + "|" $ cGrpV4Sb} )

cGrpV4Sh := "V4S_NRPROC|V4S_ORIREC|V4S_CGCORI|V4S_DESCRI|"
oStrV4Sh := FwFormStruct( 2, 'V4S', {|x| AllTrim( x ) + "|" $ cGrpV4Sh} )

cGrpV4Si := "V4S_VLRCUS|V4S_VLRADV|"
oStrV4Si := FwFormStruct( 2, 'V4S', {|x| AllTrim( x ) + "|" $ cGrpV4Si} )

cGrpV5F  := "V5F_TPPROC|V5F_NRPROC|V5F_CODSUS|V5F_VLRNIR|V5F_VDEPIR|V5F_VLNCSL|V5F_VDCSLL|V5F_VNRCOF|V5F_VDPCOF|V5F_VLNRPP|V5F_VLDPPP|V5F_BSUSIR|V5F_BSUSCS|V5F_BSUSCF|V5F_BSUSPP|"
oStrV5F  := FwFormStruct( 2, 'V5F', {|x| AllTrim( x ) + "|" $ cGrpV5F} )

cGrpV5G  := "V5G_TPINSC|V5G_NRINSC|V5G_VLRADV|"
oStrV5G  := FwFormStruct( 2, 'V5G', {|x| AllTrim( x ) + "|" $ cGrpV5G} )

oView:SetModel( oModel )
oView:SetContinuousForm( .T. )

//-------------------------------------------------
// Nivel 3( IdeEstab ) e Nivel 4( IdeBenef )
//-------------------------------------------------
oView:CreateHorizontalBox( "BOXH_MASTER", 100 )
oView:CreateFolder( "FOLDER_MASTER", "BOXH_MASTER" )
oView:AddSheet( "FOLDER_MASTER", "SHEET_MASTER", STR0012 ) //"R-4020"
oView:AddSheet( "FOLDER_MASTER", "SHEET_PROTUL", STR0013 ) //"Recibo"

oView:AddField( "VIEW_V5CA", oStrV5Ca, "MODEL_V5C" )
oView:EnableTitleView( "VIEW_V5CA", STR0014 ) //"R-4020 - Retenções na Fonte - Pessoa Juridica"
oView:CreateHorizontalBox( "PAINEL_SUPERIOR", 30, , , "FOLDER_MASTER", "SHEET_MASTER" ) //A All 100 Used 30 Remaining 70
oView:SetOwnerView( "VIEW_V5CA", "PAINEL_SUPERIOR" )

oView:AddField( "VIEW_V5CB", oStrV5Cb, "MODEL_V5C" )
oView:EnableTitleView( "VIEW_V5CB", STR0015 ) //"Recibo R-4020 - Retenções na Fonte - Pessoa Juridica"
oView:CreateHorizontalBox( "PAINEL_SUPERIORB", 100, , ,"FOLDER_MASTER","SHEET_PROTUL" )
oView:SetOwnerView( "VIEW_V5CB", "PAINEL_SUPERIORB" )

//-------------------------------------------------
// Nivel 5( IdePgto )
//-------------------------------------------------
oView:CreateHorizontalBox( "1BOXH_IDEBENEF", 70, , , "FOLDER_MASTER", "SHEET_MASTER" ) //A All 70 Used 70 Remaining 0
oView:CreateFolder( "FOLDER_IDEBENEF", "1BOXH_IDEBENEF" )   
oView:AddSheet( "FOLDER_IDEBENEF", "SHEET_IDEPGTO", STR0016 ) //"IdePgto"

oView:CreateHorizontalBox( "BOXH_IDEPGTO", 30, , , "FOLDER_IDEBENEF", "SHEET_IDEPGTO") //B All 100 Used 30 Remaining 70
oView:AddGrid( "VIEW_V5DA", oStrV5Da, "MODEL_V5DA" )
oView:EnableTitleView( "VIEW_V5DA", STR0017 ) //"Identificacao do rendimento"
oView:SetOwnerView( "VIEW_V5DA", "BOXH_IDEPGTO" )

//-------------------------------------------------
// Nivel 6( infoPgto / infoPgtoExt )
//-------------------------------------------------
oView:CreateHorizontalBox( "1BOXH_IDEPGTO", 70, , , "FOLDER_IDEBENEF", "SHEET_IDEPGTO" ) //B All 70 Used 70 Remaining 0
oView:CreateFolder( "FOLDER_IDEPGTO", "1BOXH_IDEPGTO" )
oView:AddSheet( "FOLDER_IDEPGTO", "SHEET_INFOPGTO", STR0018 ) //"infoPgto"

oView:CreateHorizontalBox( "BOXH_INFOPGTO", 40, , , "FOLDER_IDEPGTO", "SHEET_INFOPGTO" ) //C All 100 Used 40 Remaining 60
oView:AddGrid( "VIEW_V4SA", oStrV4Sa, "MODEL_V4SA" )
oView:EnableTitleView( "VIEW_V4SA", STR0019 ) //"Informações relativas ao pagamento efetuado"
oView:SetOwnerView( "VIEW_V4SA", "BOXH_INFOPGTO" )

oView:CreateHorizontalBox( "1BOXH_INFOPGTO", 30, , ,"FOLDER_IDEPGTO", "SHEET_INFOPGTO" ) //C All 60 Used 30 Remaining 30 
oView:CreateFolder( "FOLDER_INFOPGTO", "1BOXH_INFOPGTO" )

//-------------------------------------------------
// Nivel 7 Retenções ( IR / CSLL / COFINS / PP )
//-------------------------------------------------

oView:AddSheet( "FOLDER_INFOPGTO", "SHEET_RET", STR0042 ) //"Retenções"
oView:CreateHorizontalBox( "BOXH_RET", 100, , , "FOLDER_INFOPGTO", "SHEET_RET" )
oView:AddGrid( "VIEW_V4SB", oStrV4Sb, "MODEL_V4SB" )
oView:EnableTitleView( "VIEW_V4SB", STR0025 ) //"Informações Relativas à retenções(IR/CSLL/COFINS/PP)"
oView:SetOwnerView( "VIEW_V4SB", "BOXH_RET" )

oView:AddSheet( "FOLDER_INFOPGTO", "SHEET_INFOPRET", "infoProcRet" ) //"infoProcRet"
oView:CreateHorizontalBox( "BOXH_INFOPRET", 100, , , "FOLDER_INFOPGTO", "SHEET_INFOPRET" )
oView:AddGrid( "VIEW_V5F", oStrV5F, "MODEL_V5F" )
oView:EnableTitleView( "VIEW_V5F", STR0031 ) //"Informações de processos relacionados a não retenção de tributos ou depï¿½sitos judiciais"
oView:SetOwnerView( "VIEW_V5F", "BOXH_INFOPRET" )

oView:AddSheet( "FOLDER_INFOPGTO", "SHEET_INFOPJUD", STR0043 ) //"infoProcJud"
oView:CreateHorizontalBox( "BOXH_INFOPJUD", 50, , , "FOLDER_INFOPGTO", "SHEET_INFOPJUD" ) //D All 100 Used 50 Remaining 50
oView:AddGrid( "VIEW_V4SH", oStrV4Sh, "MODEL_V4SH" )
oView:EnableTitleView( "VIEW_V4SH", STR0032 ) //"Informações complementares relativas a rendimentos decorrentes de decisão judicial"
oView:SetOwnerView( "VIEW_V4SH", "BOXH_INFOPJUD" )

oView:AddSheet( "FOLDER_INFOPGTO", "SHEET_INFOPGTOEX", STR0044 ) //"InfoPgtoExt"
oView:CreateHorizontalBox( "BOXH_IPE", 40, , , "FOLDER_INFOPGTO", "SHEET_INFOPGTOEX" )
oView:AddGrid( "VIEW_V5DC", oStrV5Dc, "MODEL_V5DC" )
oView:EnableTitleView( "VIEW_V5DC",STR0039 ) //Informações complementares relativas a pagamentos no Exterior
oView:SetOwnerView( "VIEW_V5DC", "BOXH_IPE" )

//Nivel abaixo das informações do InfoPgtoExt
oView:CreateHorizontalBox( '1BOXH_ENDEXT', 60,,,"FOLDER_INFOPGTO","SHEET_INFOPGTOEX")
oView:CreateFolder("FOLDER_ENDEXT","1BOXH_ENDEXT")

oView:AddSheet( 'FOLDER_ENDEXT', 'SHEET_INFOPGTOEX', STR0021 ) //"EndExt"
oView:CreateHorizontalBox( 'BOXH_ENDEXT', 100,,,"FOLDER_ENDEXT","SHEET_INFOPGTOEX" )
oView:AddGrid("VIEW_V5DB", oStrV5Db, "MODEL_V5DB" ) 
oView:EnableTitleView("VIEW_V5DB", STR0023 ) //"Endereço do beneficiário residente ou domiciliado no exterior"
oView:SetOwnerView( "VIEW_V5DB", "BOXH_ENDEXT" )


// //-------------------------------------------------
// // Nivel 8 ( despProcJud / origemRec )
// //-------------------------------------------------

oView:CreateHorizontalBox( "1BOXH_INFOPJUD", 50, , ,"FOLDER_INFOPGTO", "SHEET_INFOPJUD" ) //D All 50 Used 50 Remaining 0
oView:CreateFolder( "FOLDER_INFOPJUD", "1BOXH_INFOPJUD" )
oView:AddSheet( "FOLDER_INFOPJUD", "SHEET_DESPJUD", STR0033 ) //"despProcJud"
oView:CreateHorizontalBox( "BOX_DESPJUD", 50, , , "FOLDER_INFOPJUD", "SHEET_DESPJUD" ) //E All 100 Used 50 Remaining 50

oView:AddGrid( "VIEW_V4SI", oStrV4Si, "MODEL_V4SI" )
oView:EnableTitleView( "VIEW_V4SI", STR0035 ) //"Detalhamento das despesas com processo judicial"
oView:SetOwnerView( "VIEW_V4SI", "BOX_DESPJUD" )

// //-------------------------------------------------
// // Nivel 9 ( ideAdv )
// //-------------------------------------------------
oView:CreateHorizontalBox( "BOXH_IDEADV", 50, , , "FOLDER_INFOPJUD", "SHEET_DESPJUD" ) //E All 50 Used 50 Remaining 0
oView:CreateFolder( "FOLDER_IDEADV", "BOXH_IDEADV" )
oView:AddSheet( "FOLDER_IDEADV", "SHEET_IDEADV", STR0037 ) //"ideAdv"
oView:CreateHorizontalBox( "1BOXH_IDEADV", 100, , , "FOLDER_IDEADV", "SHEET_IDEADV" )
oView:AddGrid( "VIEW_V5G", oStrV5G, "MODEL_V5G" )
oView:EnableTitleView( "VIEW_V5G", STR0038 ) //"Identificação do Advogado"
oView:SetOwnerView( "VIEW_V5G", "1BOXH_IDEADV" )

xFunRmFStr( @oStrV5Ca, "V5C" ) 

Return ( oView )

//-------------------------------------------------------------------
/*/{Protheus.doc} BrowseDef
Browse 

@author Katielly Rezende
@since 12/08/2019
@version 1.0
/*/
Static Function BrowseDef()
Private oBrowse  as object

oBrowse := FWmBrowse():New()	
oBrowse:SetDescription( STR0003 )// "R-4020 - Retenções na Fonte - Pessoa Jurídica
oBrowse:SetAlias( 'V5C')
oBrowse:SetMenuDef( 'TAFA546' )	
oBrowse:SetFilterDefault( "V5C_ATIVO == '1'" )    

TAFLegReinf( 'V5C', oBrowse)

oBrowse:Activate()

Return( oBrowse ) 

//---------------------------------------------------------------------
/*/{Protheus.doc} GerarEvtExc
@type			function
@description	Função com o objetivo de gerar o Evento de Exclusão
@author			Carlos Eduardo
@since			04/11/2022
@version		1.0
@param			oModel	-	Modelo de dados
@param			nRecno	-	Número do registro
@param			lRotExc	-	Variavel que controla se a function é chamada pelo TafIntegraESocial
/*/
//---------------------------------------------------------------------
Static Function GerarEvtExc( oModel, nRecno, lRotExc )
Local lRet 		:= .t.
Local lSubModel	:= .f.
Local i 		:= 0
Local J			:= 0
Local oJsonGrv	:= JsonObject():New()
Local cModel	:= ''
Local cVersao	:= ''
Local cField	:= ''
Local xValue	:= nil
Local cType		:= ''
Local cVerAnt	:= ''
Local cRecibo	:= ''

//Transforma dos dados do Model em Json e guarda no objeto para ser usado na nova gravação.
oJsonGrv:FromJson( oModel:GetJSONData(.t.,,.f.,.f.,.t.))

//Posiciono a tabela Pai no registro que esta sendo alterado
DBSelectArea('V5C')
V5C->(DBGoTo(nRecno))

//Informações para gravação do rastro
cVerAnt := V5C->V5C_VERSAO
cRecibo := V5C->V5C_PROTUL

//Gero uma nova versão para o registro que será incluido!
cVersao := xFunGetVer() 

Begin Transaction

	//Seto o registro como Inativo
	FAltRegAnt( 'V5C', '2' )

	//Operação de inclusão do novo registro
	oModel:DeActivate()
	oModel:SetOperation(3)
	oModel:Activate()
	
	//Grava as informações do Model e Submodel
	for i := 1 to len(oJsonGrv['models'])
		
		//Pega o nome do Model Principal
		cModel := oJsonGrv['models'][i]['id']
		
		//Pega nome e conteudo dos campos que precisam ser gravado e carrega no model
		for j := 1 to len(oJsonGrv['models'][i]['fields'])
			cField := oJsonGrv['models'][i]['fields'][j]['id']
			if x3uso(getSx3Cache(cField,'X3_USADO')) 
				do case //Campos com tratamentos específicos para inclusão do novo registro.
					case '_VERSAO' $ cField
						xValue := cVersao
					case '_VERANT' $ cField
						xValue := cVerAnt
					case '_PROTPN' $ cField
						xValue := cRecibo
					case '_PROTUL' $ cField
						xValue := ''
					case '_EVENTO' $ cField
						xValue	:= 'E'
					case '_ATIVO'  $ cField
						xValue := '1'
					otherwise
						xValue := oJsonGrv['models'][i]['fields'][j]:GetJsonText('value') 
				endcase
				
				if xValue == 'null'; xValue := ''; endif
				cType := oJsonGrv['models'][i]['fields'][j]['datatype'] //Pega o tipo de dado do campo
				//Comverte para o tipo correto de dado
				if cType == 'C'		
					xValue := decodeutf8(xValue)
				endif		
				//Carrega o dado no model
				lRet := oModel:LoadValue( cModel, cField , xValue )	

			endif	
		next

		//Verifica se existem submodels para serem gravados
		lSubModel := aScan( oJsonGrv['models'][i]:GetNames(), {|x| x == 'models'}) > 0
		if lSubModel
			//Faz a chamada da função de gravação dos submodes caso seja necessário
			for j := 1 to len(oJsonGrv['models'][i]['models'])
				GrvSubMdl(oModel, oJsonGrv['models'][i]['models'][j] )
			next
		endif		

		//Commita o novo registro
		FWFormCommit( oModel )
		TAFAltStat( 'V5C', '6' ) 

	next	

end Transaction

return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} TAF546Xml
Funcao de geracao do XML para atender o registro R-4020
Quando a rotina for chamada o registro deve estar posicionado

@Return:cXml
cXml - Estrutura do Xml do Layout R-4020

@author Jose Felipe|Verônica Almeida
@since 17/11/2022

@version 1.0

/*/
//-------------------------------------------------------------------
Function TAF546Xml(cAlias,nRecno,nOpc,lJob)

Local cXml    	as character
Local cLayout 	as character
Local cReg    	as character
Local cPeriodo	as character
Local cNumDoc	as character
Local cNameXSD  as character
Local cDataFg 	as character
Local lReinf212 as logical

Default lJob 	:= .F.
Default cAlias 	:= "V5C"
Default nRecno	:= 1
Default nOpc	:= 1

cLayout 	:= "4020"
cXml    	:= ""
cReg    	:= "RetPJ" 
cPeriodo	:= Substr(V5C->V5C_PERAPU,3) + "-" + Substr(V5C->V5C_PERAPU,1,2) 
cNumDoc		:= ""
cNameXSD	:= '4020PagtoBeneficiarioPJ'
cDataFg 	:= ""
lReinf212   := TAFColumnPos( "V5C_EVADIC" )

If lJob .And. nRecno > 0
	DBSelectArea( "V5C" )
	V5C->( DBSetOrder( 1 ) )
	V5C->( DBGoTo( nRecno ) )
EndIf

V5D->( DBSetOrder( 1 ) )
V4S->( DBSetOrder( 1 ) )
V5F->( DBSetOrder( 1 ) )
V5G->( DBSetOrder( 1 ) )

cXml +=		"<ideEstab>"	
cXml +=			xTafTag("tpInscEstab",V5C->V5C_TPINSC)
cXml +=			xTafTag("nrInscEstab",V5C->V5C_NRINSC)
cXml +=			"<ideBenef>"
cXml +=				xTafTag("cnpjBenef",V5C->V5C_CNPJBN,,.T.)

If Empty(V5C->V5C_CNPJBN)
	cXml +=				xTafTag("nmBenef" ,V5C->V5C_NMBENE)
Endif

cXml +=			xTafTag("isenImun",V5C->V5C_ISEIMU,,.T.)
If lReinf212
	cXml +=		xTafTag("ideEvtAdic", V5C->V5C_EVADIC,,.T.)
EndIf


If V5D->( MsSeek( xFilial( "V5D", V5C->V5C_FILIAL) + V5C->(V5C_ID + V5C_VERSAO) ) )
	While V5D->(!Eof()) .And. V5D->( V5D_FILIAL + V5D_ID + V5D_VERSAO) == V5C->( V5C_FILIAL + V5C_ID + V5C_VERSAO)

		cXml +=		"<idePgto>"
		cXml +=			xTafTag("natRend",V5D->V5D_CNATRE)
		cXml +=			xTafTag("observ" ,V5D->V5D_OBSERV,,.T.)

		If V4S->( MsSeek( xFilial( "V4S", V5C->V5C_FILIAL ) + V5C->( V5C_ID + V5C_VERSAO) + V5D->V5D_IDNTRE) )
			While V4S->(!Eof()) .And. V4S->( V4S_FILIAL + V4S_ID + V4S_VERSAO + V4S_IDNTRE) == V5C->( V5C_FILIAL + V5C_ID + V5C_VERSAO) + V5D->V5D_IDNTRE
				
				cDataFg := DToS(V4S->V4S_DATAFG)

				cXml += "<infoPgto>"					
				cXml +=		xTafTag("dtFG",Substr(cDataFg,1,4) + '-' + Substr(cDataFg,5,2)+ '-' + Substr(cDataFg,7,2))
				cXml +=		xTafTag("vlrBruto",V4S->V4S_VLRTOT, "@E 9999999999999.99",,.F.)
				cXml +=		xTafTag("indFciScp",V4S->V4S_FCISCP,,.T.)
				cXml +=		xTafTag("nrInscFciScp",V4S->V4S_NFCISC,,.T.)
				cXml +=		xTafTag("percSCP",V4S->V4S_PERSCP,"@E 999.9",.T.,.F.,.F.)

				If V4S->V4S_INDJUD == '1'
					cXml +=	xTafTag("indJud","S")
				elseif V4S->V4S_INDJUD == '2'
					cXml +=	xTafTag("indJud","N")
				Endif

				cXml +=		xTafTag("paisResidExt",V4S->V4S_PAISRE,,.T.)
				If lReinf212 
					If V5D->V5D_CNATRE == "12052" .and. !Empty(V4S->V4S_DTESCO)
						cXml +=	xTafTag("dtEscrCont", Substr(DTOS(V4S->V4S_DTESCO),1,4) + '-' + Substr(DTOS(V4S->V4S_DTESCO),5,2)+ '-' + Substr(DTOS(V4S->V4S_DTESCO),7,2))
					EndIf	
					cXml +=	xTafTag("observ", V4S->V4S_OBSERV,,.T.)
				EndIf

				xTafTagGroup("retencoes",{;
							{"vlrBaseIR",V4S->V4S_BASEIR, "@E 9999999999999.99",.T.,.F.},;
							{"vlrIR",V4S->V4S_VLRIR, "@E 9999999999999.99",.T.,.F.},;
							{"vlrBaseAgreg",V4S->V4S_BAGREG, "@E 9999999999999.99",.T.,.F.},;
							{"vlrAgreg",V4S->V4S_VAGREG, "@E 9999999999999.99",.T.,.F.},;
							{"vlrBaseCSLL",V4S->V4S_BCSLL, "@E 9999999999999.99",.T.,.F.},;
							{"vlrCSLL",V4S->V4S_VLCSLL, "@E 9999999999999.99",.T.,.F.},;
							{"vlrBaseCofins",V4S->V4S_BCOFIN, "@E 9999999999999.99",.T.,.F.},;
							{"vlrCofins",V4S->V4S_VCOFIN, "@E 9999999999999.99",.T.,.F.},;
							{"vlrBasePP",V4S->V4S_BASEPP, "@E 9999999999999.99",.T.,.F.},;
							{"vlrPP",V4S->V4S_VLRPP, "@E 9999999999999.99",.T.,.F.}},;					
						@cXml)
					

				If V5F->( MsSeek( xFilial( "V5F", V5C->V5C_FILIAL ) + V5C->( V5C_ID + V5C_VERSAO) + V5D->V5D_IDNTRE + V4S->(V4S_PAISRE + DtoS(V4S_DATAFG))) )
					While V5F->(!Eof()) .And. V5F->( V5F_FILIAL + V5F_ID + V5F_VERSAO + V5F_IDNTRE + V5F_PAISRE + DtoS(V5F_DATAFG)) ==;
						V5C->( V5C_FILIAL + V5C_ID + V5C_VERSAO) + V5D->V5D_IDNTRE + V4S->(V4S_PAISRE + DtoS(V4S_DATAFG))

						xTafTagGroup("infoProcRet",{;
									{"tpProcRet",V5F->V5F_TPPROC},;
									{"nrProcRet",V5F->V5F_NRPROC},;
									{"codSusp",V5F->V5F_CODSUS,,.T.},;
									{"vlrBaseSuspIR",V5F->V5F_BSUSIR,"@E 9999999999999.99",.T.,.F.},;
									{"vlrNIR",V5F->V5F_VLRNIR,"@E 9999999999999.99",.T.,.F.},;
									{"vlrDepIR",V5F->V5F_VDEPIR,"@E 9999999999999.99",.T.,.F.},;
									{"vlrBaseSuspCSLL",V5F->V5F_BSUSCS,"@E 9999999999999.99" ,.T.,.F.},;
									{"vlrNCSLL",V5F->V5F_VLNCSL,"@E 9999999999999.99",.T.,.F.},;
									{"vlrDepCSLL",V5F->V5F_VDCSLL,"@E 9999999999999.99",.T.,.F.},;
									{"vlrBaseSuspCofins",V5F->V5F_BSUSCF,"@E 9999999999999.99",.T.,.F.},;
									{"vlrNCofins",V5F->V5F_VNRCOF,"@E 9999999999999.99",.T.,.F.},;
									{"vlrDepCofins",V5F->V5F_VDPCOF,"@E 9999999999999.99",.T.,.F.},;
									{"vlrBaseSuspPP",V5F->V5F_BSUSPP,"@E 9999999999999.99",.T.,.F.},;
									{"vlrNPP",V5F->V5F_VLNRPP, "@E 9999999999999.99",.T.,.F.},;
									{"vlrDepPP",V5F->V5F_VLDPPP,"@E 9999999999999.99",.T.,.F.}},;
								@cXml)

						V5F->(Dbskip())

					End Do
				Endif

				If !Empty(V4S->V4S_NRPROC) .Or. !Empty(V4S->V4S_ORIREC)

					cXml += "<infoProcJud>"
					cXml +=		xTafTag("nrProc",V4S->V4S_NRPROC)
					cXml +=		xTafTag("indOrigRec",V4S->V4S_ORIREC)
					cXml +=		xTafTag("cnpjOrigRecurso",V4S->V4S_CGCORI,,.T.)
					cXml +=		xTafTag("desc",V4S->V4S_DESCRI,,.T.)

					If V4S->V4S_VLRCUS + V4S->V4S_VLRADV > 0
						cXml +=		"<despProcJud>"
						cXml +=		xTafTag("vlrDespCustas",V4S->V4S_VLRCUS,"@E 9999999999999.99",.F.,.F.,.T.,,.T.)
						cXml +=		xTafTag("vlrDespAdvogados",V4S->V4S_VLRADV,"@E 9999999999999.99",.F.,.F.,.T.,,.T.)

						If V5G->( MsSeek( xFilial( "V5G", V5C->V5C_FILIAL ) + V5C->( V5C_ID + V5C_VERSAO) + V5D->V5D_IDNTRE + V4S->(V4S_PAISRE + DtoS(V4S_DATAFG))) )
							While V5G->(!Eof()) .And. V5G->( V5G_FILIAL + V5G_ID + V5G_VERSAO + V5G_IDNTRE + V5G_PAISRE + DtoS(V5G_DATAFG)) ==;
								V5C->( V5C_FILIAL + V5C_ID + V5C_VERSAO) + V5D->V5D_IDNTRE + V4S->(V4S_PAISRE + DtoS(V4S_DATAFG))

								cXml +=  "<ideAdv>"
								cXml +=		xTafTag("tpInscAdv",IIf(V5G->V5G_TPINSC =='1','2','1'))
								cXml +=		xTafTag("nrInscAdv",V5G->V5G_NRINSC)
								cXml +=		xTafTag("vlrAdv",V5G->V5G_VLRADV,"@E 9999999999999.99",.T.,.F.,.F.,,.T.)
								cXml +=  "</ideAdv>"
						
								V5G->(Dbskip())
							End Do
						Endif
						cXml += 	"</despProcJud>"
					Endif
					cXml += "</infoProcJud>"
				Endif

				If !Empty(V5D->V5D_INDNIF) .Or. !Empty(V5D->V5D_RELPGT) .Or. !Empty(V5D->V5D_CTRIB) 
					cXml +=  "<infoPgtoExt>"

					cXml +=		xTafTag("indNIF",V5D->V5D_INDNIF)
					cXml +=		xTafTag("nifBenef",V5D->V5D_NIF,,.T.)
					cXml +=		xTafTag("relFontPg",V5D->V5D_RELPGT)
					cXml +=		xTafTag("frmTribut",V5D->V5D_CTRIB)
						
					If !Empty(V5D->V5D_LOGRAD) .Or. !Empty(V5D->V5D_NRLOGR) .Or. !Empty(V5D->V5D_COMPLE) .Or. ;
						!Empty(V5D->V5D_BAIRRO) .Or. !Empty(V5D->V5D_CIDADE) .Or. !Empty(V5D->V5D_ESTADO) .Or. ;
						!Empty(V5D->V5D_CEP) .Or. !Empty(V5D->V5D_TELEF) 
						cXml += "<endExt>"
						cXml +=		xTafTag("dscLograd",V5D->V5D_LOGRAD,,.T.)
						cXml +=		xTafTag("nrLograd",V5D->V5D_NRLOGR,,.T.)
						cXml +=		xTafTag("complem",V5D->V5D_COMPLE,,.T.)
						cXml +=		xTafTag("bairro",V5D->V5D_BAIRRO,,.T.)
						cXml +=		xTafTag("cidade",V5D->V5D_CIDADE,,.T.)
						cXml +=		xTafTag("estado",V5D->V5D_ESTADO,,.T.)
						cXml +=		xTafTag("codPostal",V5D->V5D_CEP,,.T.)
						cXml +=		xTafTag("telef",V5D->V5D_TELEF,,.T.)
						cXml += "</endExt>"
					EndIf
					cXml +=  "</infoPgtoExt>"
				EndIf

				cXml += 	"</infoPgto>"
				V4S->(Dbskip())
			End Do
		Endif				
					
		cXml += "</idePgto>"
		V5D->(Dbskip())		
	End Do
Endif

cXml +=		"</ideBenef>"
cXml +=	"</ideEstab>"

cXml := TAFXmlReinf( cXml, "V5C", cLayout, cReg, cPeriodo,, cNameXSD)

If !lJob
	xTafGerXml(cXml,cLayout,,,,,,"R-" )
EndIf

If lJob .And. nRecno > 0
	V5C->( DBCloseArea( ) )
EndIf

Return(cXml)
