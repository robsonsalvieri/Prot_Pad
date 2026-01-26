#INCLUDE 'PROTHEUS.CH'
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "TAFA448.CH"

PUBLISH MODEL REST NAME TAFA448 

//--------------------------------------------------------------------
/*/{Protheus.doc} TAFA448
Cadastro MVC Cadastro de Recibo/Fatura          

@author Evandro dos S. Oliveira Teixeira
@since 17/08/2016
@version 1.0
/*/
//--------------------------------------------------------------------
Function TAFA448(lAutomato)
 
local cTitulo   := ''
local cMensagem := ''
Local oBrowse 

Private cIndOpe := '' //Varivel utilizada na consulta padrão para o documento fiscal ( TAFA062 )

Default lAutomato := .F.
if !TAFAlsInDic( "LEM",.F. )
	
	cTitulo   := "Dicionário Incompatível" 
	cMensagem := "Inconsistência: O Ambiente do TAF está com o dicionário de dados incompatível com a versão dos fontes no repositório de dados. "
	cMensagem += "Para utilizar a rotina verifique os procedimentos necessários para atualização através do link abaixo:" + chr(13) + chr(10)
	cMensagem += "http://tdn.totvs.com/pages/viewpage.action?pageId=248579149"
	
	Aviso( cTitulo, cMensagem, { "Encerrar" }, 3 )
	
else
	oBrowse :=	FWmBrowse():New()
	oBrowse:SetDescription(STR0001) //"Cadastro de Recibo/Fatura"
	oBrowse:SetAlias("LEM")
	oBrowse:SetMenuDef("TAFA448")
	If !lAutomato
		oBrowse:Activate()
	EndIf
endif

	
Return Nil 

//-------------------------------------------------------------------
/*/{Protheus.doc} MenuDef
FuncaoMVC com as opcoes de menu

@author Evandro dos S. Oliveira Teixeira
@since 17/08/2016
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function MenuDef() 
	
	Local aRotina := {}
	Local nPosDel := 0

	aRotina := FWMVCMenu("TAFA448")

	//Tratamento para excluir a opção copiar
	nPosDel	:=	aScan( aRotina , { | aX | AllTrim( aX[ 1 ] ) == "Copiar" } )

	If nPosDel > 0
		aDel( aRotina , nPosDel )
		aSize( aRotina , Len( aRotina ) - 1 )
	EndIf

	//Inclusão do VIEWDEF.TAFA535 para habilitar, quando usado com privilégio.
	aadd(aRotina,{"Visualizar","VIEWDEF.TAFA535",0,2,0,nil,nil,nil})
	aadd(aRotina,{"Incluir"	  ,"VIEWDEF.TAFA535",0,3,0,nil,nil,nil})
	aadd(aRotina,{"Alterar"	  ,"VIEWDEF.TAFA535",0,4,0,nil,nil,nil})
	aadd(aRotina,{"Excluir"	  ,"VIEWDEF.TAFA535",0,5,0,nil,nil,nil})
	aadd(aRotina,{"Pagamentos","TAFA535(LEM->LEM_NUMERO,LEM->LEM_PREFIX,LEM->LEM_IDPART)",0,9,0,nil,nil,nil})

Return aRotina 

//-------------------------------------------------------------------
/*/{Protheus.doc} ModelDef
Funcao generica MVC do model

@return oModel - Objeto do Modelo MVC

@author Evandro dos S. Oliveira Teixeira
@since 17/08/2016
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function ModelDef()

Local oModel   := Nil
Local oStruLEM := Nil
Local oStruT5M := Nil
Local oStruT51 := Nil
Local oStruT5P := Nil
Local oStruT52 := Nil
Local oStruT9E := Nil
Local oStruV3S := Nil
Local oStruV47 := Nil
Local oStruV4L := Nil
Local oStruV83 := Nil
Local oStruV89 := Nil
Local oStruV96 := Nil
Local oStruV4M := Nil
Local lReinf   := TAFAlsInDic( "T9E",.F. )
Local lReinf21 := TafVfV3S() .And. AliasInDic("V83")

oModel := MpFormModel():New("TAFA448",,{ | oModel | ValidModel( oModel, lReinf21 ) }, { |oModel| SaveModel( oModel ) } )

oStruLEM := FWFormStruct(1,"LEM")
oStruT5M := FWFormStruct(1,"T5M")
oStruT51 := FWFormStruct(1,'T51')

// Necessário exibir o campo virtual LEM_PARTIC como obrigatório, pois a obrigatoriedade do participante de fato é no campo LEM_IDPART que está "escondido" na tela
// confundindo o usuário caso não preencha LEM_PARTIC
oStruLEM:SetProperty( 'LEM_PARTIC', MODEL_FIELD_OBRIGAT , .t.  )

//No Reinf 2.0 T5P e T52 ainda não se tornam obsoletos, pois usamos no R-2030/R-2040 pela baixa

oStruT5P := FWFormStruct(1,'T5P')
oStruT52 := FWFormStruct(1,'T52')


oModel:AddFields("MODEL_LEM", /*cOwner*/, oStruLEM)
oModel:GetModel("MODEL_LEM"):SetPrimaryKey({"LEM_FILIAL", "LEM_PREFIX","LEM_NUMERO","LEM_IDPART","LEM_DTEMIS"}) //,"LEM_IDPCRP","LEM_IDPCRA"

oModel:AddGrid('MODEL_T5M','MODEL_LEM',oStruT5M)
oModel:GetModel('MODEL_T5M'):SetUniqueLine({'T5M_IDTSER'})
oModel:SetRelation('MODEL_T5M',{{'T5M_FILIAL','xFilial("T5M")'},{"T5M_ID","LEM_ID"},{"T5M_IDPART","LEM_IDPART"},{'T5M_NUMFAT','LEM_NUMERO'}},T5M->(IndexKey(1)))
oModel:GetModel( "MODEL_T5M" ):SetOptional(.T.)

oModel:AddGrid('MODEL_T51','MODEL_LEM',oStruT51)
oModel:GetModel('MODEL_T51'):SetUniqueLine({'T51_NUMPAR'})
oModel:SetRelation('MODEL_T51',{{'T51_FILIAL','xFilial("T51")'},{"T51_ID","LEM_ID"},{"T51_IDPART","LEM_IDPART"}},T51->(IndexKey(1))) 
oModel:GetModel( "MODEL_T51" ):SetOptional(.T.)

//No Reinf 2.0 T5P e T52 ainda não se tornam obsoletos, pois usamos no R-2030/R-2040 pela baixa
oModel:AddGrid('MODEL_T5P','MODEL_T51',oStruT5P)
oModel:GetModel('MODEL_T5P'):SetUniqueLine({'T5P_DTPGTO'})
oModel:SetRelation('MODEL_T5P',{{'T5P_FILIAL','xFilial("T5P")'},{"T5P_ID","LEM_ID"},{"T5P_IDPART","LEM_IDPART"},{"T5P_NUMFAT","LEM_NUMERO"},{"T5P_NUMPAR","T51_NUMPAR"}},T5P->(IndexKey(1))) 
oModel:GetModel( "MODEL_T5P" ):SetOptional(.T.)

oModel:AddGrid('MODEL_T52','MODEL_T5P',oStruT52)
oModel:GetModel('MODEL_T52'):SetUniqueLine({"T52_CODTRI","T52_CODPAG"})
oModel:SetRelation('MODEL_T52',{{'T52_FILIAL','xFilial("T52")'},{"T52_ID","LEM_ID"},{"T52_IDPART","LEM_IDPART"},{"T52_NUMFAT","LEM_NUMERO"},{"T52_NUMPAR","T51_NUMPAR"},{"T52_DTPGTO","T5P_DTPGTO"}},T52->(IndexKey(1))) 
oModel:GetModel( "MODEL_T52" ):SetOptional(.T.)

if lReinf
	oStruT9E := FWFormStruct(1,'T9E')

	oModel:AddGrid('MODEL_T9E','MODEL_LEM',oStruT9E)
	oModel:GetModel('MODEL_T9E'):SetUniqueLine({"T9E_NUMPRO", "T9E_IDSUSP", "T9E_CODTRI", "T9E_TPPROC"})
	oModel:SetRelation('MODEL_T9E',{{'T9E_FILIAL','xFilial("T9E")'},{"T9E_ID","LEM_ID"},{"T9E_IDPART","LEM_IDPART"},{"T9E_NUMFAT","LEM_NUMERO"}},T9E->(IndexKey(1)))
	oModel:GetModel( "MODEL_T9E" ):SetOptional(.T.)
endif

if lReinf21
	oStruV3S := FWFormStruct(1,'V3S')
	oModel:AddGrid('MODEL_V3S','MODEL_LEM', oStruV3S,, { |oModel| TafVlV3S( oModel) })
	oModel:GetModel('MODEL_V3S'):SetUniqueLine({"V3S_IDNATR", "V3S_DECTER"})
	oModel:SetRelation('MODEL_V3S',{{'V3S_FILIAL','xFilial("V3S")'},{"V3S_ID","LEM_ID"},{"V3S_IDPART","LEM_IDPART"},{"V3S_NUMFAT","LEM_NUMERO"}},V3S->(IndexKey(1)))
	oModel:GetModel( "MODEL_V3S" ):SetOptional(.T.)

	oStruV47 := FWFormStruct(1,'V47')
	oModel:AddGrid('MODEL_V47','MODEL_V3S',oStruV47)
	oModel:GetModel('MODEL_V47'):SetUniqueLine({"V47_IDTRIB"})
	oModel:SetRelation('MODEL_V47',{{'V47_FILIAL','xFilial("V47")'},{"V47_ID","LEM_ID"},{"V47_IDPART","LEM_IDPART"},{"V47_NUMFAT","LEM_NUMERO"},{"V47_IDNATR","V3S_IDNATR"},{"V47_DECTER","V3S_DECTER"}},V47->(IndexKey(1)))
	oModel:GetModel( "MODEL_V47" ):SetOptional(.T.)
	oStruV47:SetProperty( 'V47_IDTRIB', MODEL_FIELD_VALID, { || TafVlV47( oModel) } )

	oStruV4L := FWFormStruct(1,'V4L')
	oModel:AddGrid('MODEL_V4L','MODEL_V47',oStruV4L)
	oModel:GetModel('MODEL_V4L'):SetUniqueLine({"V4L_TPDEDU"})
	oModel:SetRelation('MODEL_V4L',{{'V4L_FILIAL','xFilial("V4L")'},{"V4L_ID","LEM_ID"},{"V4L_IDPART","LEM_IDPART"},{"V4L_NUMFAT","LEM_NUMERO"},{"V4L_IDNATR","V3S_IDNATR"},{"V4L_DECTER","V3S_DECTER"},{"V4L_IDTRIB","V47_IDTRIB"}},V4L->(IndexKey(1)))
	oModel:GetModel( "MODEL_V4L" ):SetOptional(.T.)

	oStruV83 := FWFormStruct(1,'V83')
	oModel:AddGrid('MODEL_V83','MODEL_V4L',oStruV83,,{|oModelGrid| TafVldV83(oModelGrid)} /*blinepost*/ )
	oModel:GetModel('MODEL_V83'):SetUniqueLine({"V83_CODDEP"})
	oModel:SetRelation('MODEL_V83',{{'V83_FILIAL','xFilial("V83")'},{"V83_ID","LEM_ID"},{"V83_IDPART","LEM_IDPART"},{"V83_NUMFAT","LEM_NUMERO"},{"V83_IDNATR","V3S_IDNATR"},{"V83_DECTER","V3S_DECTER"},{"V83_IDTRIB","V47_IDTRIB"},{"V83_TPDEDU","V4L_TPDEDU"}},V83->(IndexKey(1)))
	oModel:GetModel( "MODEL_V83" ):SetOptional(.T.)

	oStruV89 := FWFormStruct(1,'V89')
	oModel:AddGrid('MODEL_V89','MODEL_T9E',oStruV89,,{|oModelGrid| TafVldV89(oModelGrid)} /*blinepost*/)
	oModel:GetModel('MODEL_V89'):SetUniqueLine({"V89_TPDEDU"})
	oModel:SetRelation('MODEL_V89',{{'V89_FILIAL','xFilial("V89")'},{"V89_ID","LEM_ID"},{"V89_IDPT9E","LEM_IDPART"},{"V89_NFAT9E","LEM_NUMERO"},{"V89_NUMPRO","T9E_NUMPRO"},{"V89_IDSUSP","T9E_IDSUSP"},{"V89_CODTRI","T9E_CODTRI"},{"V89_TPPROC","T9E_TPPROC"}},V89->(IndexKey(1)))
	oModel:GetModel( "MODEL_V89" ):SetOptional(.T.)

	oStruV96 := FWFormStruct(1,'V96')
	oModel:AddGrid('MODEL_V96','MODEL_V89',oStruV96,,{|oModelGrid| TafVldV96(oModelGrid)} /*blinepost*/)
	oModel:GetModel('MODEL_V96'):SetUniqueLine({"V96_CODDEP"})
	oModel:SetRelation('MODEL_V96',{{'V96_FILIAL','xFilial("V96")'},{"V96_ID","LEM_ID"},{"V96_IDPART","LEM_IDPART"},{"V96_NUMFAT","LEM_NUMERO"},{"V96_NUMPRO","T9E_NUMPRO"},{"V96_IDSUSP","T9E_IDSUSP"},{"V96_CODTRI","T9E_CODTRI"},{"V96_TPPROC","T9E_TPPROC"},{"V96_TPDEDU","V89_TPDEDU"}},V96->(IndexKey(1)))
	oModel:GetModel( "MODEL_V96" ):SetOptional(.T.)
	

	oStruV4M := FWFormStruct(1,'V4M')
	oModel:AddGrid('MODEL_V4M','MODEL_V47',oStruV4M)
	oModel:GetModel('MODEL_V4M'):SetUniqueLine({"V4M_CTPISE"})
	oModel:SetRelation('MODEL_V4M',{{'V4M_FILIAL','xFilial("V4M")'},{"V4M_ID","LEM_ID"},{"V4M_IDPART","LEM_IDPART"},{"V4M_NUMFAT","LEM_NUMERO"},{"V4M_IDNATR","V3S_IDNATR"},{"V4M_DECTER","V3S_DECTER"},{"V4M_IDTRIB","V47_IDTRIB"}},V4M->(IndexKey(1)))
	oModel:GetModel( "MODEL_V4M" ):SetOptional(.T.)
endif


Return(oModel)

//-------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
Funcao generica MVC do View

@return oView - Objeto da View MVC

@author Evandro dos S. Oliveira Teixeira
@since 17/08/2016
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function ViewDef()

Local oModel 	:= Nil
Local oStruLEM 	:= Nil 
Local oStruT51 	:= Nil
Local oStruT52 	:= Nil
Local oStruT5M	:= Nil
Local oStruT5P	:= Nil
Local oStruT9E	:= Nil
Local oStruV3S	:= Nil
Local oStruV47	:= Nil
Local oStruV4L	:= Nil
Local oStruV83	:= Nil
Local oStruV89	:= Nil
Local oStruV96	:= Nil
Local oStruV4M	:= Nil
Local oView 	:= Nil
Local cExclCmp	:= ""

Local cCmpsView	:= ""
Local aCmpLEM	:= {}
Local nI		:= 0
Local lReinf 	:= TAFAlsInDic( "T9E",.F. )
Local nOrdAba   := 1
Local cDescAba  := ""
Local lReinf21  := TafVfV3S() .and. AliasInDic("V83")

oModel 	:= 	FWLoadModel('TAFA448')
oView 	:= 	FWFormView():New()
cExclCmp := ""
lMenuDif := Iif( Type( "lMenuDif" ) == "U", .F., lMenuDif )
oView:SetModel( oModel )
oView:SetContinuousForm(.T.)

cExclCmp := "LEM_FILIAL|LEM_ID|LEM_STATUS|"


aCmpLEM := xFunGetSX3("LEM",cExclCmp,.T.)

For nI := 1 To Len(aCmpLEM)
	cCmpsView += AllTrim(aCmpLEM[nI][2]) + "|"
Next nI

oStruLEM := FWFormStruct(2,"LEM",{|x|AllTrim(x)$ cCmpsView } ) 
oView:AddField("VIEW_LEM",oStruLEM,"MODEL_LEM")
oView:CreateHorizontalBox("BOXH_LEM",030)
oView:SetOwnerView("VIEW_LEM","BOXH_LEM")

oStruLEM:AddGroup ("GRP_DOCUMENTO"			,STR0004	, '' , 1 )	//"Informações da Fatura/Recibo"	
oStruLEM:AddGroup ("GRP_RRA"				,STR0005	, '' , 1 )	//"Rendimentos Recebidos Acumuladamente"
oStruLEM:AddGroup ("GRP_DEMAIS_RENDIMENTOS"	,STR0006	, '' , 1 )	//"Demais Rendimentos Decorrentes de Decusão Judicial"

For nI := 1 To Len(aCmpLEM)
	If AllTrim(aCmpLEM[nI][2]) # "LEM_DPCRRA|LEM_DPRODM|" //LEM_IDPRRA|LEM_NATRRA|LEM_QTDRRA|LEM_IDPCDM|LEM_IORIRE|LEM_CNPJDM|
		oStruLEM:SetProperty(AllTrim(aCmpLEM[nI][2]),MVC_VIEW_GROUP_NUMBER ,"GRP_DOCUMENTO")
	EndIf
Next nI

oStruLEM:RemoveField("LEM_ID")

oView:CreateHorizontalBox("BOX_CHILDRENS",070)
oView:CreateFolder("FOLDER_CHILDRENS","BOX_CHILDRENS") 

cDescAba := "ABA" + cValToChar(nOrdAba++)
oView:AddSheet("FOLDER_CHILDRENS", cDescAba ,STR0010) //"Serviços/Parcelas/Pagamentos/Tributos"
oView:CreateHorizontalBox("BOXH_TIPO_SERVICO"	,025,,,"FOLDER_CHILDRENS",cDescAba)
oView:CreateHorizontalBox("BOXH_PARCELAS"		,025,,,"FOLDER_CHILDRENS",cDescAba)
oView:CreateHorizontalBox("BOXH_PAGAMENTOS"		,025,,,"FOLDER_CHILDRENS",cDescAba)
oView:CreateHorizontalBox("BOXH_TRIBUTOS"		,025,,,"FOLDER_CHILDRENS",cDescAba)

oStruT5M := FwFormStruct(2,"T5M")
oView:AddGrid("VIEW_T5M",oStruT5M,"MODEL_T5M")
oView:EnableTitleView("VIEW_T5M",STR0011) //"Tipo de Serviço"

oStruT51 := FwFormStruct(2,"T51")
oView:AddGrid("VIEW_T51",oStruT51,"MODEL_T51")
oView:EnableTitleView("VIEW_T51",STR0008) //"Parcelas da Fatura/Recibo"

//No Reinf 2.0 T5P e T52 ainda não se tornam obsoletos, pois usamos no R-2030/R-2040 pela baixa
oStruT5P := FwFormStruct(2,"T5P")
oView:AddGrid("VIEW_T5P",oStruT5P,"MODEL_T5P")
oView:EnableTitleView("VIEW_T5P",STR0012) //"Pagamento das Parcelas Fatura/Recibo"

if TAFColumnPos("T5P_PROCID")
	oStruT5P:RemoveField("T5P_PROCID")
endif

oStruT52 := FwFormStruct(2,"T52")
oView:AddGrid("VIEW_T52",oStruT52,"MODEL_T52")
oView:EnableTitleView("VIEW_T52",STR0007) //"Tributos da Parcela Fatura/Recibo"


if lReinf

	oStruT9E := FwFormStruct(2,"T9E")

	cDescAba := "ABA" + cValToChar(nOrdAba++)
	oView:AddSheet("FOLDER_CHILDRENS",cDescAba,STR0013) //"Indicativo de Suspensão por processo judicial/administrativo"
	oView:CreateHorizontalBox("BOXH_T9E",50,,,"FOLDER_CHILDRENS",cDescAba)
	oView:AddGrid("VIEW_T9E",oStruT9E,"MODEL_T9E")
	oView:EnableTitleView("VIEW_T9E", "Indicativo de Suspensão por processo judicial/administrativo" )

	oStruT9E:RemoveField("T9E_IDSUSP")
    oStruT9E:RemoveField("T9E_CNATRE")

	If lReinf21
		oStruV89 := FwFormStruct(2,"V89")
		oView:CreateHorizontalBox("BOXH_V89",25,,,"FOLDER_CHILDRENS", cDescAba) 
		oView:AddGrid("VIEW_V89",oStruV89,"MODEL_V89")
		oView:EnableTitleView("VIEW_V89", STR0048) //"Deduções com exigibilidade suspensa"

		oStruV96 := FwFormStruct(2,"V96")
		oView:CreateHorizontalBox("BOXH_V96",25,,,"FOLDER_CHILDRENS", cDescAba)
		oView:AddGrid("VIEW_V96",oStruV96,"MODEL_V96")
		oView:EnableTitleView("VIEW_V96", STR0049) //"Informação das deduções suspensas por dependentes e beneficiários da pensão alimentícia."

	EndIf	
endif

if lReinf21
	oStruV3S := FwFormStruct(2,"V3S")
	oStruV47 := FwFormStruct(2,"V47")
	oStruV4L := FwFormStruct(2,"V4L")
	oStruV4M := FwFormStruct(2,"V4M")

	cDescAba := "ABA" + cValToChar(nOrdAba++)
	oView:AddSheet("FOLDER_CHILDRENS",cDescAba,STR0021) //"Tributos/Natureza Rendimento"
	oView:CreateHorizontalBox("BOXH_V3S",25,,,"FOLDER_CHILDRENS",cDescAba) 
	
	oView:AddGrid("VIEW_V3S",oStruV3S,"MODEL_V3S")
	oView:EnableTitleView("VIEW_V3S", STR0040 ) //"Natureza de Rendimento"

	oView:CreateHorizontalBox("BOXH_V47",25,,,"FOLDER_CHILDRENS", cDescAba) 
	oView:AddGrid("VIEW_V47",oStruV47,"MODEL_V47")
	oView:EnableTitleView("VIEW_V47", STR0041 ) //"Tributos"

	oView:CreateHorizontalBox("BOXH_DESISEN",50,,,"FOLDER_CHILDRENS",cDescAba)
	oView:CreateFolder("FOLDER_DESISEN","BOXH_DESISEN")

	cDescAba := "ABA" + cValToChar(nOrdAba++)
	oView:AddSheet("FOLDER_DESISEN",cDescAba,STR0032) //Deduções 
	oView:CreateHorizontalBox("BOXH_DEDUCOES",50,,,"FOLDER_DESISEN",cDescAba)
	oView:AddGrid("VIEW_V4L",oStruV4L,"MODEL_V4L")

	oStruV83 := FwFormStruct(2,"V83")
	// aba benefPen
	oView:CreateHorizontalBox("BOXH_BENEF",50,,,"FOLDER_DESISEN",cDescAba) //Beneficiários de Pensão Alimentícia
	oView:AddGrid("VIEW_V83",oStruV83,"MODEL_V83")
	oView:EnableTitleView("VIEW_V83", STR0042 )

	cDescAba := "ABA" + cValToChar(nOrdAba++)
	oView:AddSheet("FOLDER_DESISEN",cDescAba,STR0033) //Isenções
	oView:CreateHorizontalBox("BOXH_ISENCOES",100,,,"FOLDER_DESISEN",cDescAba)
	oView:AddGrid("VIEW_V4M",oStruV4M,"MODEL_V4M")

	//Removendo campos de relacionamento da tela
	oStruV3S:RemoveField("V3S_ID")
	oStruV3S:RemoveField("V3S_IDPART")
	oStruV3S:RemoveField("V3S_NUMFAT")
	oStruV3S:RemoveField("V3S_IDNATR")
	oStruV3S:RemoveField("V3S_IDPROC")
	if TAFColumnPos("V3S_IFCISC")
		oStruV3S:RemoveField("V3S_IFCISC")
	endif

	oStruV47:RemoveField("V47_ID")
	oStruV47:RemoveField("V47_IDPART")
	oStruV47:RemoveField("V47_NUMFAT")
	oStruV47:RemoveField("V47_IDTRIB")
	oStruV47:RemoveField("V47_IDNATR")
	oStruV47:RemoveField("V47_DECTER")

	oStruV4L:RemoveField("V4L_ID") 
	oStruV4L:RemoveField("V4L_IDPART")
	oStruV4L:RemoveField("V4L_NUMFAT")
	oStruV4L:RemoveField("V4L_DECTER")
	
	oStruV4M:RemoveField("V4M_ID")
	oStruV4M:RemoveField("V4M_IDPART")
	oStruV4M:RemoveField("V4M_IDTPIS")
	oStruV4M:RemoveField("V4M_NUMFAT")
	oStruV4M:RemoveField("V4M_DECTER")
endif
if TAFColumnPos("LEM_IDOBRA")
	oStruLEM:RemoveField("LEM_IDOBRA")
endif

if TAFColumnPos("LEM_UNQINT")
	oStruLEM:RemoveField("LEM_UNQINT")
endif

If TamSX3("LEM_IDPART")[1] == 36
	oStruLEM:RemoveField( "LEM_IDPART")
	oStruLEM:SetProperty( "LEM_PARTIC", MVC_VIEW_ORDEM, "07" )
EndIf

oView:SetOwnerView("VIEW_T5M","BOXH_TIPO_SERVICO")
oView:SetOwnerView("VIEW_T51","BOXH_PARCELAS")

////No Reinf 2.0 T5P e T52 ainda não se tornam obsoletos, pois usamos no R-2030/R-2040 pela baixa
oView:SetOwnerView("VIEW_T5P","BOXH_PAGAMENTOS")
oView:SetOwnerView("VIEW_T52","BOXH_TRIBUTOS")

if lReinf
	oView:SetOwnerView("VIEW_T9E","BOXH_T9E")
	If lReinf21
		oView:SetOwnerView("VIEW_V89","BOXH_V89")
		oView:SetOwnerView("VIEW_V96","BOXH_V96")
		oView:SetOwnerView("VIEW_V3S","BOXH_V3S")
		oView:SetOwnerView("VIEW_V47","BOXH_V47")
		oView:SetOwnerView("VIEW_V4L","BOXH_DEDUCOES")
		oView:SetOwnerView("VIEW_V4M","BOXH_ISENCOES")
		oView:SetOwnerView("VIEW_V83","BOXH_BENEF")
	EndIf
endif

Return (oView)

Function TAF448Vld(cAlias,nRecno,nOpc,lJob)

local aLogErro := {}

Return aLogErro

//-------------------------------------------------------------------
/*/{Protheus.doc} SaveModel
Funcao de gravacao dos dados, chamada no final, no momento da
confirmacao do modelo

@param  oModel -> Modelo de dados
@return .T.

@author Denis Naves
@since 23/02/2014
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function SaveModel(oModel)

Local nOperation := oModel:GetOperation()
Local lOK        := .T.
Local lApurBx	:= SuperGetMv('MV_TAFRECD',.F.,"1") == "2" .and. TAFColumnPos("T5P_PROCID")// "1"- Emissão ; "2" - Baixa 
Local nRecnoLEM := 0

If nOperation == MODEL_OPERATION_DELETE
	
	lOK := VldExcl( oModel )

Elseif TAFAlsInDic("V4M")
	//Dedução
	if FWFLDGET( "V4L_TPDEDU" ) $ '234' .And. Empty(FWFLDGET("V4L_NUMPRE") ) 
		lOk := .F.	
		oModel:SetErrorMessage( ,,,,, STR0034, STR0036,, ) //"O N° de Inscrição da Previdêcia se torna obrigatório quando o Tipo Dedução é igual 2,3 ou 4."
	//Isenção
	elseif 	 FWFLDGET("V4M_CTPISE") $ '99' .And. Empty( FWFLDGET( "V4M_DRENDI") ) 
		lOk := .F.	
		oModel:SetErrorMessage( ,,,,, STR0035, STR0036,, ) //"A descrição da isenção se torna obrigatória quando o Tipo da Isenção é igual 99=Outros"
	endif
EndIf

If lOK
	
	Begin Transaction
		If nOperation == MODEL_OPERATION_UPDATE
			TAFAltStat( "LEM", " " )
		EndIf
		If FwFormCommit( oModel )
			If nOperation == MODEL_OPERATION_UPDATE .or. nOperation == MODEL_OPERATION_INSERT
				nRecnoLEM := LEM->(Recno())
				If FindFunction('TafEndGRV') 
					TafEndGRV( "LEM","LEM_PROCID", '', nRecnoLEM )
					If lApurBx
						LimpaT5P()
					EndIf				
				EndIf
				If TAFColumnPos("LEM_PRID40" ) 
					TafEndGRV( "LEM","LEM_PRID40", '', nRecnoLEM )
				EndIf
			Endif
		EndIf
	End Transaction

EndIf

Return lOK

//-------------------------------------------------------------------
/*{Protheus.doc} VldExcl

Função utilizada para validar a exclusão do registro.
Se o registro tiver sido apurado, é necessário informar o usuário da perda de vínculo das informações caso a exclusão seja confirmada.

@return lRet .T. = A exclusão será executada / .F. = A exclusão não será executada

@author Wesley Pinheiro
@since 14/11/2018
@version 1.0
*/
//-------------------------------------------------------------------

Static Function VldExcl( oModel )

	Local oModelLEM  := oModel:GetModel( "MODEL_LEM" )
	Local cFil       := oModelLEM:GetValue( "LEM_FILIAL" )
	Local cPrefix    := Alltrim( oModelLEM:GetValue( "LEM_PREFIX" ) )
	Local cNum       := Alltrim( oModelLEM:GetValue( "LEM_NUMERO" ) )
	Local cIdPartic  := oModelLEM:GetValue( "LEM_IDPART" )
	Local cDtEmis    := Dtos( oModelLEM:GetValue( "LEM_DTEMIS" ) )
	Local cTipo      := oModelLEM:GetValue( "LEM_NATTIT" )
	Local lRet       := .T.
	Local lTemApur   := .F.
	Local cFilMatriz := TafGetMtrz( cFil )

	if( cTipo == "0" ) // Título a pagar -> fatura
		lTemApur := T448T96Exc( cFil, cPrefix, cNum, cIdPartic, cDtEmis, cFilMatriz )
	else
		// Título a receber -> recibo
		lTemApur := T448CROExc( cFil, cPrefix, cNum, cIdPartic, cDtEmis, cFilMatriz )
	Endif

	if lTemApur
		// "Integridade do registro." "Esta fatura/recibo possui vínculo com o registro apurado no Reinf que já foi transmitido ou aguarda retorno do RET."
		// "Deseja prosseguir com a exclusão mesmo assim?"
		if !MsgYesNo( STR0014 + CRLF + CRLF + STR0015  + CRLF + CRLF + STR0016 )
			oModel:SetErrorMessage( ,,,,, STR0017, STR0018,, ) // "Operação cancelada.", "Retorne e selecione a opção desejada."
			lRet := .F.
		endif

	EndIf

Return lRet

//-------------------------------------------------------------------
/*{Protheus.doc} T448T96Exc

Função utilizada para validar se existe apuração enviada ao RET para a fatura que está sendo deletada

@return lRet .T. = Existe apuração / .F. = Não existe apuração

@author Wesley Pinheiro
@since 14/11/2018
@version 1.0
*/
//-------------------------------------------------------------------
Static Function T448T96Exc( cFil, cPrefix, cNum, cIdPartic, cDtEmis, cFilMatriz )

	Local lRet 		 := .F.
	Local cSelect  	 := ""
	Local cFrom    	 := ""
	Local cInnerT96  := ""
	Local cInnerT95  := ""
	Local cWhere  	 := ""
	Local cPrefixAux := "0"
	Local cAliasQry	 := GetNextAlias( )

	/*
		Esse tratamento é necessário porque o campo LEM_PREFIX tem valor default '' 
		e o campo T96_SERIE da tabela temporária aApuracao utilizada para gravar as informações no Model
		tem tratamento para inserir valor "0" caso o retorno da query de apuração seja vazio
		@see TAFAPRCP.prw -> function RegPrinc
	*/
	if( !Empty( cPrefix ) )
		cPrefixAux := cPrefix
	EndIf

	cSelect   := " COUNT(*) QTD "
	cFrom     := RetSqlName( "LEM" ) + " LEM "

	cInnerT96 := RetSqlName( "T96" ) + " T96 "
	cInnerT96 += "   ON LEM.LEM_NUMERO = T96.T96_NUMFAT "
	cInnerT96 += "   AND T96.T96_SERIE = '" + cPrefixAux + "' "
	cInnerT96 += "   AND LEM.LEM_DTEMIS = T96.T96_DTEMIS "
	cInnerT96 += "   AND T96.T96_FILIAL = '" + cFilMatriz + "' "
	cInnerT96 += "   AND LEM.D_E_L_E_T_ = T96.D_E_L_E_T_ "

	cInnerT95 := RetSqlName( "T95" ) + " T95 "
	cInnerT95 += "   ON T95.T95_ID = T96.T96_ID "
	cInnerT95 += "   AND LEM.LEM_IDPART = T95.T95_IDPART "
	cInnerT95 += "   AND T95.T95_FILIAL = '" + cFilMatriz + "' "
	cInnerT95 += "   AND T95.D_E_L_E_T_ = T96.D_E_L_E_T_ "
	cInnerT95 += "   AND T95.T95_ATIVO = '1' "
	cInnerT95 += "   AND T95.T95_STATUS IN ( '2','4','6','7' ) "
	
	cWhere    := " LEM.LEM_FILIAL = '" + cFil + "' "
	cWhere    += "   AND LEM.LEM_PREFIX = '" + cPrefix + "' "
	cWhere    += "   AND LEM.LEM_NUMERO = '" + cNum + "' "
	cWhere    += "   AND LEM.LEM_IDPART = '" + cIdPartic + "' "
	cWhere    += "   AND LEM.LEM_DTEMIS = '" + cDtEmis + "' "
	cWhere    += "   AND LEM.D_E_L_E_T_ = ' ' "

	cSelect   := "%" + cSelect + "%"
	cFrom     := "%" + cFrom + "%"
	cInnerT96 := "%" + cInnerT96 + "%"
	cInnerT95 := "%" + cInnerT95 + "%"
	cWhere	  := "%" + cWhere + "%"

	BeginSql Alias cAliasQry
		SELECT
			%Exp:cSelect%
		FROM
			%Exp:cFrom%
		INNER JOIN
			%Exp:cInnerT96%
		INNER JOIN
			%Exp:cInnerT95%
		WHERE
			%Exp:cWhere%
	EndSql

	IIf( ( cAliasQry )->QTD > 0, lRet := .T., lRet := .F. )

Return lRet

//-------------------------------------------------------------------
/*{Protheus.doc} T448CROExc

Função utilizada para validar se existe apuração enviada ao RET para o recibo que está sendo deletado

@return lRet .T. = Existe apuração / .F. = Não existe apuração

@author Wesley Pinheiro
@since 14/11/2018
@version 1.0
*/
//-------------------------------------------------------------------
Static Function T448CROExc( cFil, cPrefix, cNum, cIdPartic, cDtEmis, cFilMatriz )
 
	Local lRet 		 := .F.
	Local cSelect  	 := ""
	Local cFrom    	 := ""
	Local cInnerCRO  := ""
	Local cInnerCMN  := ""
	Local cWhere  	 := ""
	Local cPrefixAux := "0"
	Local cAliasQry	 := GetNextAlias( )

	/*
		Esse tratamento é necessário porque o campo LEM_PREFIX tem valor default '' 
		e o campo CRO_SERIE da tabela temporária aApuracao utilizada para gravar as informações no Model
		tem tratamento para inserir valor "0" caso o retorno da query de apuração seja vazio
		@see TAFAPRCP.prw -> function RegPrinc
	*/
	if( !Empty( cPrefix ) )
		cPrefixAux := cPrefix
	EndIf

	cSelect   := " COUNT(*) QTD "
	cFrom     := RetSqlName( "LEM" ) + " LEM "

	cInnerCRO := RetSqlName( "CRO" ) + " CRO "
	cInnerCRO += "   ON LEM.LEM_NUMERO = CRO.CRO_NUMFAT "
	cInnerCRO += "   AND CRO.CRO_SERIE = '" + cPrefixAux + "' "
	cInnerCRO += "   AND LEM.LEM_DTEMIS = CRO.CRO_DTEMIS "
	cInnerCRO += "   AND CRO.CRO_FILIAL = '" + cFilMatriz + "' "
	cInnerCRO += "   AND LEM.D_E_L_E_T_ = CRO.D_E_L_E_T_ "

	cInnerCMN := RetSqlName( "CMN" ) + " CMN "
	cInnerCMN += "   ON CMN.CMN_ID = CRO.CRO_ID "
	cInnerCMN += "   AND CMN.CMN_FILIAL = '" + cFilMatriz + "' "
	cInnerCMN += "   AND CMN.D_E_L_E_T_ = CRO.D_E_L_E_T_ "
	cInnerCMN += "   AND CMN.CMN_ATIVO = '1' "
	cInnerCMN += "   AND CMN.CMN_STATUS IN ( '2','4','6','7' ) "
	
	cWhere    := " LEM.LEM_FILIAL = '" + cFil + "' "
	cWhere    += "   AND LEM.LEM_PREFIX = '" + cPrefix + "' "
	cWhere    += "   AND LEM.LEM_NUMERO = '" + cNum + "' "
	cWhere    += "   AND LEM.LEM_IDPART = '" + cIdPartic + "' "
	cWhere    += "   AND LEM.LEM_DTEMIS = '" + cDtEmis + "' "
	cWhere    += "   AND LEM.D_E_L_E_T_ = ' ' "

	cSelect   := "%" + cSelect + "%"
	cFrom     := "%" + cFrom + "%"
	cInnerCRO := "%" + cInnerCRO + "%"
	cInnerCMN := "%" + cInnerCMN + "%"
	cWhere	  := "%" + cWhere + "%"

	BeginSql Alias cAliasQry
		SELECT
			%Exp:cSelect%
		FROM
			%Exp:cFrom%
		INNER JOIN
			%Exp:cInnerCRO%
		INNER JOIN
			%Exp:cInnerCMN%
		WHERE
			%Exp:cWhere%
	EndSql

	IIf( ( cAliasQry )->QTD > 0, lRet := .T., lRet := .F. )

Return lRet

//-------------------------------------------------------------------
/*{Protheus.doc} ValidModel

Função utilizada para validar a gravação do Model.
Validação: Evitar gravar fatura/recibo com os mesmos valores da chave mais forte da tabela LEM
indice 2 -> LEM_FILIAL + LEM_PREFIX + LEM_NUMERO + LEM_IDPART + LEM_DTEMIS

@return lRet .T. = Gravação será realizada ( Não existe chave ) / .F. = Gravação não será realizada ( existe chave )

@author Wesley Pinheiro
@since 30/08/2019
@version 1.0
*/
//-------------------------------------------------------------------
Static Function ValidModel( oModel, lReinf21 )
	Local cPrefix  		as Character
	Local cNum     		as Character
	Local cIdPartic		as Character
	Local cDtEmis 		as Character
	Local cKeyLEM  		as Character

	Local oModelLEM 	as Object

	Local nOperation 	as Numeric

	Local lSeek			as Logical
	Local lRet			as Logical

	Local aAreaLEM		as Array

	oModelLEM  := oModel:GetModel("MODEL_LEM")
	nOperation := oModel:GetOperation()
	aAreaLEM   := LEM->(GetArea())
	lSeek      := .T.
	lRet       := .T.
	cPrefix    := ""
	cNum       := ""
	cIdPartic  := ""
	cDtEmis    := ""
	cKeyLEM    := ""
	
	If nOperation == MODEL_OPERATION_INSERT .or. nOperation == MODEL_OPERATION_UPDATE

		LEM->( DbSetOrder( 2 ) ) // LEM_FILIAL + LEM_PREFIX + LEM_NUMERO + LEM_IDPART + LEM_DTEMIS

		cPrefix   := oModelLEM:GetValue( "LEM_PREFIX" )
		cNum      := oModelLEM:GetValue( "LEM_NUMERO" )
		cIdPartic := oModelLEM:GetValue( "LEM_IDPART" )
		cDtEmis   := Dtos( oModelLEM:GetValue( "LEM_DTEMIS" ) )

		/*
			Caso a operação seja de alteração,
			valido a existência da chave do índice 2 apenas se as mesmas foram alteradas ( devido os campos serem abertos para edição )
			Por isso a comparação dos valores do Model com o registro posicionado.
		*/
		If nOperation == MODEL_OPERATION_UPDATE

			cKeyLEM := LEM->( LEM_FILIAL + LEM_PREFIX + LEM_NUMERO + LEM_IDPART + Dtos( LEM_DTEMIS) )

			If cKeyLEM == ( xFilial( "LEM" ) + cPrefix + cNum + cIdPartic + cDtEmis )
				lSeek := .F.
			EndIf

		EndIf

		If lSeek
			If LEM->( DbSeek( xFilial( "LEM" ) + cPrefix + cNum + cIdPartic + cDtEmis ) )
				lRet := .F.
				Help( ,1, "HELP",, STR0019, 1, 0,,,,,,{STR0020} ) // "Já existe um número e prefixo de fatura/recibo para o participante nesta data de emissão." "Altere o conteúdo dos campos informados acima!"
			EndIf
		EndIf
	EndIf

	RestArea( aAreaLEM )

Return lRet

//---------------------------------------------------------------------
/*/{Protheus.doc} TafVfV3S

Rotina para verificar se existem os campos utilizados no Reinf 2.0

@Param

@Author Denis Souza
@Since 28/05/2019
@Version 1.0
/*/
//---------------------------------------------------------------------
Function TafVfV3S()

	Local aGetArea 	:= GetArea()
	Local lRf20  	:= .F.

	If AliasIndic("V3S") .And. Empty(Select("V3S"))
		DbSelectArea("V3S")
		V3S->(DbSetOrder(1))
	endif

	If TafColumnPos("V3S_IDNATR")
		lRf20 := .T.
	endif

	RestArea(aGetArea)

Return lRf20

//---------------------------------------------------------------------
/*/{Protheus.doc} Vld448

Rotina para validar o correto preenchimento dos campos de dedução(V4L) e isenção(V4M) da REINF 2.0.

@Author José Mauro/Katielly Rezende
@Since 31/07/2019
@Version 1.0
/*/
//---------------------------------------------------------------------
Function Vld448( cCampo )

Local lOk := .T.

Default cCampo:= "0"

If cCampo=='1'
	If FwFldGet("V4L_TPDEDU")$'234' .And. Empty(FwFldGet("V4L_NUMPRE")) 
		Help("",1,"Help","Help",STR0034, 1, 0, NIL, NIL, NIL, NIL, NIL, {STR0036}) //"O N° de Inscrição da Previdêcia se torna obrigatório quando o Tipo Dedução é igual 2,3 ou 4."
		lOk := .F.
	EndIf
ElseIf cCampo=='2'
	If FwFldGet("V4M_CTPISE")$'99' .And. Empty(FwFldGet("V4M_DRENDI")) 
		Help("",1,"Help","Help",STR0035, 1, 0, NIL, NIL, NIL, NIL, NIL, {STR0036}) //"A descrição da isenção se torna obrigatória quando o Tipo da Isenção é igual 99=Outros"
		lOk := .F.
	EndIf
EndIf

Return lOk

//---------------------------------------------------------------------
/*/{Protheus.doc} TAF448Cbox

Função de ComboBox para carregar os tipos de deduções para o REINF 2.0. 
Função chamada no campo V4L_TPDEDU

@Author José Mauro/Katielly Rezende
@Since 31/07/2019
@Version 1.0
/*/
//---------------------------------------------------------------------
Function TAF448Cbox( cCampo ) 

Local cString   :=  ""
    cString := "1=" + STR0025
    cString += "2=" + STR0026
    cString += "3=" + STR0027 
    cString += "4=" + STR0028
    cString += "5=" + STR0029
	cString += "7=" + STR0031
	cString += "8=" + STR0050
Return( cString )

//-------------------------------------------------------------------
 /*{Protheus.doc} TafVlV47
Função que verifica se a natureza de rendimento for igual a 000006 os campos de tributo não deverão ser preenchidos 

@author Leticia Campos da Silva
@since 15/08/2019
@version 1.0
/*/
//---------------------------------------------------------------------
Function TafVlV47( oModel )

Local oModelV3S as Object         
Local cNatRen   as Character 
Local lRetorno  as Logical

oModelV3S := oModel:GetModel( "MODEL_V3S" )
cNatRen	  := oModelV3S:GetValue( "V3S_IDNATR" )
lRetorno  := .T.

DBSelectArea("V3O")
V3O->(DbSetOrder(2)) 
V3O->(DbGoTop())
If V3O->(DbSeek( xFilial("V3O") + cNatRen )) .AND. (V3O->V3O_TRIB == ' ')
	oModel:SetErrorMessage( ,,,, "ATENÇÃO", STR0038 ) //A natureza de rendimento "Lucro e Dividendo", não possui tributação!
	lRetorno := .F.
Endif

Return lRetorno

//-------------------------------------------------------------------
 /*{Protheus.doc} TafVlV3S 
Função que verifica se o tipo de Despesa Processual informada existe na V4F

@author Katielly Feitosa
@since 23/10/2019
@version 1.0
/*/
//---------------------------------------------------------------------
Static Function TafVlV3S( oModel )

Local cNrProc  		as Character
Local cTpProc  		as Character
Local cIndRRA  		as Character
Local cID		    as Character
Local oModelV3S 	as Object
Local lRet			as Logical

oModelV3S  := oModel:GetModel("MODEL_V3S")
cNrProc    := "" 
cTpProc    := ""
cIndRRA    := "" 
cID		   := ""
lRet	   := .T.

cIndRRA := oModel:GetValue( "V3S_INDRRA" ) 
cTpProc := oModel:GetValue( "V3S_TPPROC" )
cNrProc := oModel:GetValue( "V3S_NRPROC" )

If !Empty(cIndRRA) .Or. !Empty(cTpProc) .Or. !Empty(cNrProc) 
	DBSelectArea("V4F")
	V4F->(DbSetOrder(2)) // V4F_FILIAL + V4F_INDRRA + V4F_TPPROC + V4F_NRPROC
	V4F->(DbGoTop())
	If V4F->(DbSeek( xFilial("V4F") + cIndRRA + cTpProc + cNrProc)) 
		cID:= V4F->V4F_ID
		oModel:LoadValue( 'V3S_IDPROC', cID)
		lRet := .T.
	Else
		oModel:GetModel():SetErrorMessage('MODEL_V3S',,,, "ATENÇÃO", STR0039)
		lRet := .F.
	EndIf
EndIf

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} LimpaT5P()
Limpa o campo T5P_PROCID quando apuração for na baixa

@author Karen Honda
@since 20/05/2021
@version 1.0
/*/ 
//-------------------------------------------------------------------
Static Function LimpaT5P()

DBSelectArea("T5P")
T5P->( DbSetOrder(1) )
If T5P->( DbSeek(xFilial("T5P")  + LEM->LEM_ID + LEM->LEM_IDPART + LEM->LEM_NUMERO) )
	While T5P->( !Eof() ) .and. T5P->(T5P_FILIAL + T5P_ID + T5P_IDPART + T5P_NUMFAT) == xFilial("T5P") + LEM->(LEM_ID + LEM_IDPART + LEM_NUMERO)
		RecLock("T5P", .F.)
		T5P->T5P_PROCID = " " 
		T5P->( MsUnlock() )
		T5P->( DbSkip() )
	EndDo	
EndIf

Return


//-------------------------------------------------------------------
/*/	{Protheus.doc} TafVldV83
Validacao de campo para proteger erro de chave duplicada da V83-Dependentes

@param  
@return lRet
@author  Karen
@since   04/02/2022
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function TafVldV83(oMdlDep)

Local lRet 		 as Logical
Local aAreaV83   as Array

lRet 		:= .T.
aAreaV83 	:= V83->( GetArea() )

If !IsBlind()
	dbSelectArea("V83")
	V83->(dbSetOrder(1)) //V83_FILIAL, V83_ID, V83_IDPART, V83_NUMFAT, V83_IDNATR, V83_DECTER, V83_IDTRIB, V83_TPDEDU, V83_CODDEP, R_E_C_D_E_L_

	If oMdlDep:IsInserted() .or. oMdlDep:IsUpdated()
		If Empty(FwFldGet("V83_CODDEP"))
			lRet := .F.
			Help("",1,"Help","Help",STR0043, 1, 0, NIL, NIL, NIL, NIL, NIL, {STR0044}) //"O campo código do dependente não pode estar em branco." "Informe um contéudo."
		EndIf
		If lRet .and. V83->(DBSeek(xFilial("V83") +  FwFldGet("LEM_ID") + FwFldGet("LEM_IDPART") + FwFldGet("LEM_NUMERO") + FwFldGet("V3S_IDNATR") + FwFldGet("V3S_DECTER") + FwFldGet("V47_IDTRIB")+ FwFldGet("V4L_TPDEDU")+ FwFldGet("V83_CODDEP") ) )
			If oMdlDep:GetDataId() != V83->( Recno() )
				lRet := .F.
				Help("",1,"Help","Help",STR0045, 1, 0, NIL, NIL, NIL, NIL, NIL, {STR0046}) //"O conteúdo preenchido forma uma chave já cadastrada.""Informe outro contéudo."
			EndIf	
		EndIf
	EndIf
	RestArea( aAreaV83 )
endif

Return lRet

//-------------------------------------------------------------------
/*/	{Protheus.doc} TafVldV89
Validacao de campo para proteger erro de chave duplicada da V89-Detalhes deducoes suspensas

@param  
@return lRet
@author  Karen
@since   04/02/2022
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function TafVldV89(oMdlDet)

Local lRet 		 as Logical
Local aAreaV89   as Array

lRet 		:= .T.
aAreaV89 	:= V89->( GetArea() )

If !IsBlind()
	dbSelectArea("V89")
	V89->(dbSetOrder(1)) //V89_FILIAL, V89_ID, V89_IDPT9E, V89_NFAT9E, V89_NUMPRO, V89_IDSUSP, V89_CODTRI, V89_TPPROC, V89_TPDEDU, R_E_C_N_O_, D_E_L_E_T_

	If oMdlDet:IsInserted() .or. oMdlDet:IsUpdated()
		If lRet .and. V89->(DBSeek(xFilial("V89") +  FwFldGet("LEM_ID") + FwFldGet("LEM_IDPART") + FwFldGet("LEM_NUMERO") + FwFldGet("T9E_NUMPRO") + FwFldGet("T9E_IDSUSP") + FwFldGet("T9E_CODTRI")+ FwFldGet("T9E_TPPROC")+ FwFldGet("V89_TPDEDU") ) )
			If oMdlDet:GetDataId() != V89->( Recno() )
				lRet := .F.
				Help("",1,"Help","Help",STR0045, 1, 0, NIL, NIL, NIL, NIL, NIL, {STR0046}) //"O conteúdo preenchido forma uma chave já cadastrada.""Informe outro contéudo."
			EndIf	
		EndIf
	EndIf
	RestArea( aAreaV89 )
endif

Return lRet

//-------------------------------------------------------------------
/*/	{Protheus.doc} TafVldV96
Validacao de campo para proteger erro de chave duplicada da V89-Detalhes deducoes suspensas

@param  
@return lRet
@author  Karen
@since   04/02/2022
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function TafVldV96(oMdlDet)

Local lRet 		 as Logical
Local aAreaV96   as Array

lRet 		:= .T.
aAreaV96 	:= V96->( GetArea() )

If !IsBlind()
	dbSelectArea("V96")
	V96->(dbSetOrder(1))//V96_FILIAL, V96_ID, V96_IDPART, V96_NUMFAT, V96_NUMPRO, V96_IDSUSP, V96_CODTRI, V96_TPPROC, V96_CODDEP, V96_TPDEDU                                                                   

	If oMdlDet:IsInserted() .or. oMdlDet:IsUpdated()
		If lRet .and. V96->(DBSeek(xFilial("V96") +  FwFldGet("LEM_ID") + FwFldGet("LEM_IDPART") + FwFldGet("LEM_NUMERO") + FwFldGet("T9E_NUMPRO") + FwFldGet("T9E_IDSUSP") + FwFldGet("T9E_CODTRI")+ FwFldGet("T9E_TPPROC")+ FwFldGet("V89_TPDEDU") + FwFldGet("V96_CODDEP") ) )
			If oMdlDet:GetDataId() != V96->( Recno() )
				lRet := .F.
				Help("",1,"Help","Help",STR0045, 1, 0, NIL, NIL, NIL, NIL, NIL, {STR0046}) //"O conteúdo preenchido forma uma chave já cadastrada.""Informe outro contéudo."
			EndIf	
		EndIf
	EndIf
	RestArea( aAreaV96 )
endif

Return lRet
