#Include 'Protheus.ch'
#Include 'FWMVCDEF.CH'
#Include 'FWBROWSE.CH'
#Include 'topconn.ch'
#include 'PLSA298.CH'
#INCLUDE "PLSMCCR.CH"
#INCLUDE "TOTVS.CH"
#include "PLSMGER.CH"

//-------------------------------------------------------------------
/*/ {Protheus.doc} PLSA298
Nota Fiscal x Guias
@since 12/2022
@version P12 
/*/
//-------------------------------------------------------------------
Function PLSA298(lAutoma)
local oBrowse	:= nil
local lExsCmp   := B19->(FieldPos("B19_PRINCI")) > 0
local cFiltro   := "@(B19_FILIAL = '" + xFilial("B19") + "') "
default lAutoma := iif( valtype(lAutoma) <> "L", .f., lAutoma )

if lExsCmp
    cFiltro   := "@(B19_FILIAL = '" + xFilial("B19") + "') "
endif

oBrowse := FWMBrowse():New()
oBrowse:SetAlias("B19")
oBrowse:SetDescription(STR0001) // "Cadastro de NF Entrada x Guias"
oBrowse:SetFilterDefault(cFiltro)
iif(!lAutoma, oBrowse:Activate(), '')

Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} MenuDef
Menus
@since 12/2022
@version P12 
/*/
//-------------------------------------------------------------------
Static Function MenuDef()
Local aRotina := {}

Add Option aRotina Title   STR0029 	Action 'VIEWDEF.PLSA298' 	Operation 2 Access 0  //Visualizar
Add Option aRotina Title   STR0027  Action "VIEWDEF.PLSA298" 	Operation 3 Access 0  //Incluir
Add Option aRotina Title   STR0028	Action "VIEWDEF.PLSA298" 	Operation 4 Access 0  //Alterar
Add Option aRotina Title   STR0030  Action "VIEWDEF.PLSA298"	Operation 5 Access 0  //Excluir

Return aRotina


//-------------------------------------------------------------------
/*/{Protheus.doc} ModelDef
Definição do modelo de Dados.
@since 12/2022
@version P12
/*/
//-------------------------------------------------------------------
Static Function ModelDef()
Local oModel 
Local oStrBR	:= FWFormModelStruct():New()
Local oStrB19G	:= FWFormStruct(1,'B19')
local nTamForn  := Tamsx3("A2_COD")[1]
local nTamLoja  := Tamsx3("A2_LOJA")[1]
local nTamSerie := Tamsx3("F1_SERIE")[1]
local nTamDoc   := Tamsx3("F1_DOC")[1]
local nTamNmFr  := Tamsx3("A2_NOME")[1]
local lAut      :=  IIf( type('lAut298G') == 'U', .F., lAut298G ) // Variavel declarada para fins de automação  

oModel := MPFormModel():New( 'PLSA298', , { |oModel| PL298OK(oModel) }, {|oModel| PlsSavMdl(oModel,lAut)}) 
oStrBR:AddField('B19_FORNEC', STR0031, 'B19_FORNEC' , 'C', nTamForn , 0, {|| PlVldNota(oModel, "1")}, {|| PlEditC(oModel)}, {}, .F., , .F., .F., .T., , ) //Fornecedor
oStrBR:AddField('B19_LOJA'  , STR0032, 'B19_LOJA'   , 'C', nTamLoja , 0, {|| PlVldNota(oModel, "2")}, {|| PlEditC(oModel)}, {}, .F., , .F., .F., .T., , ) //Loja
oStrBR:AddField('DOC'       , STR0033, 'DOC'        , 'C', nTamDoc  , 0, {|| PlVldNota(oModel, "3")}, {|| PlEditC(oModel)}, {}, .F., , .F., .F., .T., , ) //Documento
oStrBR:AddField('SERIE'     , STR0034, 'SERIE'      , 'C', nTamSerie, 0, {|| PlVldNota(oModel, "4")}, {|| PlEditC(oModel)}, {}, .F., , .F., .F., .T., , ) //Série
oStrBR:AddField('NOMEFOR'   , STR0036, 'NOMEFOR'    , 'C', nTamNmFr , 0, ,{|| .t.}, {}, .F., , .F., .F., .T., , ) //Nome Fornecedor
oModel:AddFields('MASTERCAB', , oStrBR,,,{|oModel|CabLoad298(oModel)}) 
oModel:AddGrid('B19Detail', 'MASTERCAB', oStrB19G)

//Inicializador dos campos
oStrB19G:setProperty( "B19_FORNEC"  , MODEL_FIELD_INIT, { || oModel:getModel('MASTERCAB'):getValue('B19_FORNEC')} )
oStrB19G:setProperty( "B19_LOJA"    , MODEL_FIELD_INIT, { || oModel:getModel('MASTERCAB'):getValue('B19_LOJA')} )
oStrB19G:setProperty( "B19_DOC"     , MODEL_FIELD_INIT, { || oModel:getModel('MASTERCAB'):getValue('DOC')} )
oStrB19G:setProperty( "B19_SERIE"   , MODEL_FIELD_INIT, { || oModel:getModel('MASTERCAB'):getValue('SERIE')} )

//Se os dados da NF foram preenchidos no cabeçalho.
oStrB19G:setProperty( "B19_COD"     , MODEL_FIELD_VALID, {|| VldPreCab(oModel) .and. VldItemNom(oModel, "1")} )

oModel:SetRelation( 'B19Detail', { ;
	{ 'B19_FILIAL'	, 'xFilial( "B19" )' },;
    { 'B19_FORNEC'	, 'B19_FORNEC' },;
    { 'B19_LOJA'	, 'B19_LOJA' },;
    { 'B19_DOC'	    , 'DOC' },;
    { 'B19_SERIE'	, 'SERIE' } },;
    B19->( IndexKey(1) ) )

//Não pode repetir a mesma nota e item para a mesma guia e evento
oModel:GetModel( 'B19Detail' ):SetUniqueLine( { 'B19_FORNEC', 'B19_LOJA', 'B19_DOC', 'B19_SERIE', 'B19_ITEM', 'B19_COD', 'B19_GUIA'} )

oModel:GetModel('MASTERCAB'):SetDescription(STR0001) // "Cadastro de NF Entrada x Guias"
oModel:SetDescription(STR0001) //"Cadastro de NF Entrada x Guias"

oModel:SetPrimaryKey( { "B19_FILIAL", "B19_FORNEC", "B19_LOJA", "B19_DOC", "B19_SERIE", "B19_GUIA" } )
Return oModel


//-------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
Definição da interface.
@since 03/2020
@version P12
/*/
//-------------------------------------------------------------------
Static Function ViewDef()
Local oView 
Local oModel	:= FWLoadModel( 'PLSA298' )
Local oStrBR	:= FWFormViewStruct():New()
Local oStrB19G	:= FWFormStruct(2,'B19',{ |cCampo| plsGrdExb(cCampo) })

oView := FWFormView():New()
oView:SetModel( oModel )
oStrBR:AddField( 'B19_FORNEC'   , '01', STR0031, 'Fornecedor'   ,, 'C' ,"@!",,"FOR   ",,,,,,,.t.,, ) //Fornecedor
oStrBR:AddField( 'B19_LOJA'     , '02', STR0032, 'B19_LOJA'     ,, 'C' ,"@!",,,,,,,,,.t.,, ) //Loja
oStrBR:AddField( 'DOC'          , '03', STR0033, 'Documento'    ,, 'C' ,"@!",,"B1VPLS",.t.,,,,,,.t.,, ) //Documento
oStrBR:AddField( 'SERIE'        , '04', STR0034, 'SERIE'        ,, 'C' ,"@!",,,.t.,,,,,,.f.,, ) //Série
oStrBR:AddField( 'NOMEFOR'      , '05', STR0036, 'NOMEFOR'      ,, 'C' ,"@!",,,.f.,,,,,,.f.,, ) //Nome Fornecedor

oView:AddField( 'VIEW_BR', oStrBR, 'MASTERCAB')
oView:CreateHorizontalBox( 'SUPERIOR', 20)
oView:CreateHorizontalBox( 'BAIXO'	 , 80)

//Adiciono o Grid
oView:AddGrid( 'ViewB19G', oStrB19G, 'B19Detail',,{||VldPreCab(oModel)} )

//Campos bloqueados. Apenas Item e Número Guia liberados para edição.
oStrB19G:SetProperty( '*', MVC_VIEW_CANCHANGE, .F.)
oStrB19G:SetProperty( 'B19_ITEM', MVC_VIEW_CANCHANGE, .T.)
oStrB19G:SetProperty( 'B19_GUIA', MVC_VIEW_CANCHANGE, .T.)

//Título
oView:EnableTitleView('ViewB19G', STR0035) // "Itens da Nota Fiscal"

oView:SetOwnerView('VIEW_BR', 'SUPERIOR' )
oView:SetOwnerView('ViewB19G' , 'BAIXO' )

Return oView


//------------------------------------------------------------------
/*/{Protheus.doc} PL298OK
Valida a inclusão do Registro.
@since 12/2022
@version P12
/*/
//-------------------------------------------------------------------
Static Function PL298OK(oModel)
Local lRet		:= .t.
Local oGrid     := oModel:getmodel("B19Detail")
local nFor      := 1
local nTamGrid  := oGrid:length()
local nOperac   := oModel:getOperation()
local cMsgErro1 := ""
local cMsgErro2 := ""
local aRet      := {}
local aRetPrinc := {.f., 0}
local lExsCmp   := B19->(FieldPos("B19_PRINCI")) > 0

If ExistBlock("PL298VLDOK")
	lRet := ExecBlock("PL298VLDOK",.F.,.F.)	// retorna verdadeiro para pular validação ao confirmar	
else

    if nOperac != MODEL_OPERATION_DELETE
        for nFor := 1 To nTamGrid
            oGrid:GoLine(nFor)
            if !(oGrid:IsDeleted()) 
                if empty(oGrid:getValue("B19_GUIA")) .or. empty(oGrid:getValue("B19_ITEM"))
                    lRet := .f.
                    cMsgErro1 += STR0051 + cValtoChar(nFor) + CRLF //Linha: 
                else
                    aRet := PlVerHisB19(oModel, oGrid:getValue("B19_GUIA"), nFor, oGrid:getValue("B19_ITEM"))
                    if (!aRet[1])
                        lRet := aRet[1]
                        cMsgErro2 += aRet[2] + CRLF
                    endif
                endif 
                //Se deletar um registro que foi gravado como B19_PRINCI = "1", tenho que registrar outro no local. Serve apenas para simplificar o browser
                if lExsCmp
                    if oGrid:getValue("B19_PRINCI") == "1"
                        aRetPrinc[1] := .t.    
                    else
                        aRetPrinc[2] := nFor    
                    endif
                endif
            endif        
        next
        
        if !aRetPrinc[1] .and. lExsCmp
            oGrid:GoLine(aRetPrinc[2])
            oGrid:LoadValue("B19_PRINCI", "1")
        endif
    endif

    if !lRet
        if !empty(cMsgErro1)
            cMsgErro1 := STR0042 + CRLF + cMsgErro1 + CRLF
        endif    
        Help(nil, nil , STR0037, nil, cMsgErro1 + CRLF + cMsgErro2, 1, 0, nil, nil, nil, nil, nil, {STR0040} ) //Atenção - Confira os dados lançados.
    endif
EndIf

Return lRet


//------------------------------------------------------------------
/*/{Protheus.doc} VldPreCab
Valida se os dados da nota fiscal foram inseridos no cabeçalho. Se branco, retorna com crítica.
@type function
@since 12/2022
/*/
//------------------------------------------------------------------
static function VldPreCab(oModel)
Local oCab  := oModel:getmodel("MASTERCAB")
local lRet  := .t.

if ( empty(oCab:getvalue("B19_FORNEC")) .or. empty(oCab:getvalue("DOC")) .or. empty(oCab:getvalue("B19_LOJA")) )
    lRet := .f.
    Help(nil, nil, STR0037, nil, STR0038, 1, 0, nil, nil, nil, nil, nil, nil ) // Atenção - Informe o número da Nota no cabeçalho, antes de continuar a lançar os dados.
ENDIF

return lRet


//------------------------------------------------------------------
/*/{Protheus.doc} CabLoad298
Load dos campos virtuais, na hora de visualizar/editar/excluir
@type function
@since 12/2022
/*/
//------------------------------------------------------------------
static function CabLoad298(oModel)
Local aLoad     := {}
local cNumFornec    := B19->B19_FORNEC
local cNumLoja      := B19->B19_LOJA
local cNumDOC       := B19->B19_DOC
local cNumSerie     := B19->B19_SERIE
local cNomFor       := Posicione("SA2", 1, xFilial("SA2") + B19->(B19_FORNEC+B19_LOJA), "A2_NOME")

aAdd(aLoad, {cNumFornec, cNumLoja, cNumDOC, cNumSerie, cNomFor}) 
aAdd(aLoad, 1)
      
Return aLoad


//------------------------------------------------------------------
/*/{Protheus.doc} PlEditC
Verifica se o campo deve ficar editável ou não. Editável apenas na inclusão e na edição, campos virtuais bloqueados.
@type function
@since 12/2022
/*/
//------------------------------------------------------------------
static function PlEditC(oModel)
local lPodEdit := iif(oModel:getOperation() == MODEL_OPERATION_INSERT, .t., .f.)
return lPodEdit


//------------------------------------------------------------------
/*/{Protheus.doc} plsGrdExb
Ocultar os campos no Grid, poi já estão no cabeçalho
@type function
@since 12/2022
/*/
//------------------------------------------------------------------
static function plsGrdExb(cCampo)
Local lRet := .t.

if alltrim(cCampo) $ 'B19_PRINCI/B19_NMFORN/B19_FORNEC/B19_LOJA/B19_SERIE/B19_DOC'
	lRet := .f.
endif

return lRet


//------------------------------------------------------------------
/*/{Protheus.doc} PlsSavMdl
Salva os dados no modelo PLSA298GRV, devido aos campos virtuais existentes no cabeçalho, que podem ocasionar erro.
@type function
@since 12/2022
/*/
//------------------------------------------------------------------
Static Function PlsSavMdl(oModel, lautoma)
Local oModelGrv     := FWLoadModel('PLSA298GRV')
local nOperation    := oModel:GetOperation()
local nFor          := 0
local oGridB19      := oModel:GetModel("B19Detail")
local nTamGrid      := oGridB19:length()
local lret          := .t.
Local oCabGrv		:= oModelGrv:GetModel('MasterB19')
local aCmpModel     := oCabGrv:GetStruct():GetFields()
local nCampos       := 0
local cValor        := ""
Default lAutoma     := .f.

Begin transaction
    //Inclusão
    if nOperation == MODEL_OPERATION_INSERT
        oModelGrv:SetOperation(MODEL_OPERATION_INSERT)
        oModelGrv:Activate()
        
        for nFor := 1 To nTamGrid
            oGridB19:Goline(nFor)

            if !(oGridB19:IsDeleted())    
                for nCampos := 1 to len(aCmpModel)
                    cValor := oGridB19:getvalue(aCmpModel[nCampos,3])
                    oModelGrv:getmodel("MasterB19"):setvalue(aCmpModel[nCampos,3], cValor)    
                next
    
                If (oModelGrv:VldData() )
                    oModelGrv:CommitData()
                EndIf   
                oModelGrv:DeActivate()
                oModelGrv:Destroy()
                oModelGrv := nil
                oModelGrv := FWLoadModel( 'PLSA298GRV' )
                oModelGrv:SetOperation(MODEL_OPERATION_INSERT)
                oModelGrv:Activate()
            endif
        next nFor

    elseif nOperation == MODEL_OPERATION_DELETE    
        oModelGrv := FWLoadModel( 'PLSA298GRV' )
        oModelGrv:SetOperation(MODEL_OPERATION_DELETE)
        oModelGrv:Activate() 

        If (oModelGrv:VldData() )
            oModelGrv:CommitData()
            FWFormCommit( oModel )  
        endif

    else //Operação Alterar
        FWFormCommit( oModel )   
    Endif

End Transaction
Return lret


//------------------------------------------------------------------
/*/{Protheus.doc} PLPESQGUIA
Pesquisa generica de pesquisa de guias 
@type function
@author TOTVS
@since 12.12.06
@version 1.0
/*/
//------------------------------------------------------------------
Function PLPESQGUIA()
Static objCENFUNLGP := CENFUNLGP():New()
Local cChave     := Space(100)
Local oDlgPesGui                       
Local oTipoPes
Local oSayGui
Local nOpca      := 0
Local aBrowGui   := {}
Local aVetPad    := { { "ENABLE", "","","","","","",CtoD(""), 0 } }
Local oBrowGui
Local bRefresh   := { || If(!Empty(cChave),PLPQGUIA(AllTrim(cChave),Subs(cTipoPes,1,1),lChkChk,aBrowGui,aVetPad,oBrowGui),.T.), If( Empty(aBrowGui[1,2]) .And. !Empty(cChave),.F.,.T. )  }
Local cValid     := "{|| Eval(bRefresh) }"
Local bOK        := { || If(!Empty(cChave),(nLin := oBrowGui:nAt, nOpca := 1,oDlgPesGui:End()),Help("",1,"PLSMCON")) }
Local bCanc      := { || nOpca := 3,oDlgPesGui:End() }
Local oGetChave
Local aTipoPes   := {}
Local nOrdem     := 1
Local cTipoPes   := ""
Local oChkChk
Local lChkChk    := .F.
Local nLin       := 1
Local aButtons 	 := {} 

aBrowGui := aClone(aVetPad)
If ExistBlock("PLSBUTDV")							
	aButtons := ExecBlock("PLSBUTDV",.F.,.F.)		
EndIf												

aTipoPes := { STR0006, STR0007, STR0008, "4-Nr. da Guia" } //"1-Nome do Usuário"###"2-Matrícula do Usuário"###"3-Matrícula Antiga"###

Define MsDialog oDlgPesGui Title STR0010 From 008.2,000 To 025,100 Of GetWndDefault() //"Pesquisa de Guias"
oGetChave := TGet():New(035,103,{ | U | If( PCOUNT() == 0, cChave, cChave := U ) },oDlgPesGui,210,008 ,"@!S30",&cValid,Nil,Nil,Nil,Nil,Nil,.T.,Nil,.F.,Nil,.F.,Nil,Nil,.F.,Nil,Nil,cChave)
oBrowGui := TcBrowse():New( 050, 008, 378, 075,,,, oDlgPesGui,,,,,,,,,,,, .F.,, .T.,, .F., )

oBrowGui:AddColumn(TcColumn():New("",Nil,;
         Nil,Nil,Nil,Nil,055,.T.,.F.,Nil,Nil,Nil,.T.,Nil))
         oBrowGui:ACOLUMNS[1]:BDATA     := { || aBrowGui[oBrowGui:nAt,1] }

oBrowGui:AddColumn(TcColumn():New(STR0011,Nil,; //"Matrícula"
         Nil,Nil,Nil,Nil,055,.F.,.F.,Nil,Nil,Nil,.F.,Nil))
         oBrowGui:ACOLUMNS[2]:BDATA     := { || aBrowGui[oBrowGui:nAt,2] }

oBrowGui:AddColumn(TcColumn():New(STR0012,Nil,; //"Matricula Antiga"
         Nil,Nil,Nil,Nil,055,.F.,.F.,Nil,Nil,Nil,.F.,Nil))
         oBrowGui:ACOLUMNS[3]:BDATA     := { || aBrowGui[oBrowGui:nAt,3] }

oBrowGui:AddColumn(TcColumn():New(STR0013,Nil,; //"Nome do Usuário"
         Nil,Nil,Nil,Nil,090,.F.,.F.,Nil,Nil,Nil,.F.,Nil))
         oBrowGui:ACOLUMNS[4]:BDATA     := { || aBrowGui[oBrowGui:nAt,4] }

oBrowGui:AddColumn(TcColumn():New("Guia Operadora",Nil,; 
         Nil,Nil,Nil,Nil,070,.F.,.F.,Nil,Nil,Nil,.F.,Nil))     
         oBrowGui:ACOLUMNS[5]:BDATA     := { || aBrowGui[oBrowGui:nAt,5] } 

oBrowGui:AddColumn(TcColumn():New(STR0021,Nil,; //"Tipo de Guia"
         Nil,Nil,Nil,Nil,070,.F.,.F.,Nil,Nil,Nil,.F.,Nil))     
         oBrowGui:ACOLUMNS[6]:BDATA     := { || aBrowGui[oBrowGui:nAt,6] }	         

oBrowGui:AddColumn(TcColumn():New(STR0015,Nil,; //"Procedimento"
         Nil,Nil,Nil,Nil,040,.F.,.F.,Nil,Nil,Nil,.F.,Nil))     
         oBrowGui:ACOLUMNS[7]:BDATA     := { || aBrowGui[oBrowGui:nAt,7] }

oBrowGui:AddColumn(TcColumn():New(STR0016,Nil,; //"Descrição"
         Nil,Nil,Nil,Nil,120,.F.,.F.,Nil,Nil,Nil,.F.,Nil))     
         oBrowGui:ACOLUMNS[8]:BDATA     := { || aBrowGui[oBrowGui:nAt,8] }

oBrowGui:AddColumn(TcColumn():New(STR0017,Nil,; //"Data Proced"
         Nil,Nil,Nil,Nil,040,.F.,.F.,Nil,Nil,Nil,.F.,Nil))     
         oBrowGui:ACOLUMNS[9]:BDATA     := { || aBrowGui[oBrowGui:nAt,9] }

@ 035,008 COMBOBOX oTipoPes  Var cTipoPes ITEMS aTipoPes SIZE 090,010 OF oDlgPesGui PIXEL COLOR CLR_HBLUE
@ 035,319 CHECKBOX oChkChk   Var lChkChk PROMPT STR0018 PIXEL SIZE 080, 010 OF oDlgPesGui //"Pesquisar Palavra Chave"

//-------------------------------------------------------------------
//  LGPD
//-------------------------------------------------------------------
	if objCENFUNLGP:isLGPDAt()
		aCampos := { .F.,;
					"BD6_OPEUSR+BD6_CODEMP+BD6_MATRIC+BD6_TIPREG+BD6_DIGITO",;
					"BD6_MATANT",;
					"BD6_NOMUSR",;
					"BD6_CODOPE+BD6_CODLDP+BD6_CODPEG+BD6_NUMERO",;
					.F.,;
					"BD6_CODPRO",;
					"BD6_DESPRO",;
					"BD6_DATPRO",; 
					.F. }
		aBls := objCENFUNLGP:getTcBrw(aCampos)

		oBrowGui:aObfuscatedCols := aBls//{.T., .T., .T., .T., .T., .T., .F., .T.}
	endif

oBrowGui:SetArray(aBrowGui)
oBrowGui:bLDblClick := bOK
                                 
Activate MsDialog oDlgPesGui On Init Eval({ || EnChoiceBar(oDlgPesGui,bOK,bCanc,.F.,aButtons) }) 

If nOpca == K_OK
   If !Empty(aBrowGui[nLin,2])
      BD6->(dbGoTo(aBrowGui[nLin,10]))
   EndIf
EndIf

Return(nOpca==K_OK)


//------------------------------------------------------------------
/*/{Protheus.doc} PLPQGUIA
Pesquisa as guias na base de dados
@type function
@author TOTVS
@since 12.12.06
@version 1.0
/*/
//------------------------------------------------------------------
Static Function PLPQGUIA(cChave,cTipoPes,lChkChk,aBrowGui,aVetPad,oBrowGui)

Local aArea     := GetArea()
Local cSQL      := ""
Local cRetBD6
Local cStrFil
Local cOrderBy	:= ""
Local aPL298GUI := {}

If '"' $ cChave .Or. ;
   "'" $ cChave
   Aviso( STR0019, STR0020, { "Ok" }, 2 )
   Return(.F.)
EndIf   

cRetBD6 := RetSQLName("BD6")                                            

aBrowGui := {}
  
If ExistBlock('PL298GUI')
	  aPL298GUI := ExecBlock('PL298GUI',.F.,.F.,{cChave,cTipoPes,lChkChk,aBrowGui})  
	  If ValType(aPL298GUI) =='A'
	  	aBrowGui := aClone(aPL298GUI)
	  EndIf	
Else

	cSQL := "SELECT BD6_OPEUSR, BD6_CODEMP, BD6_MATRIC, BD6_TIPREG, BD6_DIGITO, "
	cSQL += "       BD6_MATANT, BD6_CODLDP, BD6_CODPEG, BD6_NUMERO, BD6_NOMUSR, "
	cSQL += "       BD6_CODOPE, BD6_ANOINT, BD6_MESINT, BD6_NUMINT, BD6_TIPGUI, BR8_ALTCUS, "
	cSQL += "       BD6_CODPAD, BD6_CODPRO, BD6_DESPRO, BD6_DATPRO, BD6.R_E_C_N_O_ AS RECBD6 "
	cSQL += "  FROM " + cRetBD6 + " BD6 "
	cSQL += " INNER JOIN " + RetSqlName("BR8") + " BR8 "
	cSQL += " ON BR8.BR8_FILIAL = '" + xFilial("BR8") + "' "
	cSQL += " AND BR8.BR8_CODPAD = BD6.BD6_CODPAD "
	cSQL += " AND BR8.BR8_CODPSA = BD6.BD6_CODPRO "
	cSQL += " AND BR8.BR8_ALTCUS = '1' "
	cSQL += " AND BR8.D_E_L_E_T_ = ' ' "
	cSql += " INNER JOIN " + RetSQLName("BA1") + " BA1 "
	cSql += " ON BA1.BA1_FILIAL = '" + xFilial("BA1") + "' "
	cSql += " AND BD6_OPEUSR = BA1_CODINT "
	cSql += " AND BD6_CODEMP = BA1_CODEMP "
	cSql += " AND BD6_MATRIC = BA1_MATRIC "
	cSql += " AND BD6_TIPREG = BA1_TIPREG "
	cSql += " AND BD6_DIGITO = BA1_DIGITO "
	cSql += " AND BA1.D_E_L_E_T_ = ' ' "
	cSQL += " WHERE "
	cSQL += " BD6_FILIAL = '"+xFilial("BD6")+"' AND "
	If cTipoPes == "1" // Nome do Usuario			
		If lChkChk
			cSQL += "BD6_NOMUSR LIKE '%" + AllTrim(cChave) + "%' AND "
		Else
			cSQL += "BD6_NOMUSR LIKE '" + AllTrim(cChave) + "%' AND "
		EndIf	

		cOrderBy := " ORDER BY BD6_FILIAL,BD6_NOMUSR "

	ElseIf cTipoPes == "2" // Matricula do Usuario    		   
		If lChkChk
			cSQL += "BD6_OPEUSR || BD6_CODEMP || BD6_MATRIC || BD6_TIPREG LIKE '%" + AllTrim(cChave) + "%' AND "
		Else
			cSQL += "BD6_OPEUSR || BD6_CODEMP || BD6_MATRIC || BD6_TIPREG LIKE '" + AllTrim(cChave) + "%' AND "
		EndIf

		cOrderBy := " ORDER BY BD6_FILIAL,BD6_OPEUSR,BD6_CODEMP,BD6_MATRIC,BD6_TIPREG "

	ElseIf cTipoPes == "3" // Matricula Antiga		
		If lChkChk
			cSQL += "BD6_MATANT LIKE '%" + AllTrim(cChave) + "%' AND "
		Else
			cSQL += "BD6_MATANT LIKE '" + AllTrim(cChave) + "%' AND "
		EndIf	

		cOrderBy := " ORDER BY BD6_FILIAL,BD6_OPEUSR,BD6_CODEMP,BD6_MATRIC,BD6_TIPREG,BD6_DIGITO "

	ElseIf cTipoPes == "4" // Numero da Guia
		
		If lChkChk
			cSQL += "BD6_CODOPE||BD6_CODLDP||BD6_CODPEG||BD6_NUMERO LIKE '%" + AllTrim(cChave) + "%' AND "
		Else
			cSQL += "BD6_CODOPE||BD6_CODLDP||BD6_CODPEG||BD6_NUMERO LIKE '" + AllTrim(cChave) + "%' AND "
		EndIf
		
		cOrderBy := " ORDER BY BD6_FILIAL,BD6_NOMUSR "
	EndIf   
	
	cSQL += "BD6_TIPGUI  IN ('02','03','05') AND "
	cSQL += "BD6_FASE   IN ('1','2') AND "
	cSQL += "BD6.D_E_L_E_T_ = ' '"
	If FindFunction("PLSRESTOP")
		cStrFil := PLSRESTOP("U")   // retorna string com filtro para restricao do operador
		If !Empty(cStrFil)
			cSQL += " AND " + cStrFil
		EndIf
	EndIf	

	cSQL += cOrderBy

	If ExistBlock("PL298PESBD")
	   cSQL := ExecBlock("PL298PESBD",.F.,.F.,{cSQL})
	Endif
	
	cSql := ChangeQuery(cSql)
	dbUseArea(.T.,"TOPCONN",TCGENQRY(,,cSQL),"TrbPes",.F.,.T.)	
	
	Do While !TrbPes->(Eof())		
	    TrbPes->(aAdd(aBrowGui, {  "ENABLE",;
									TrbPes->BD6_OPEUSR+"."+TrbPes->BD6_CODEMP+"."+TrbPes->BD6_MATRIC+"."+TrbPes->BD6_TIPREG+"-"+TrbPes->BD6_DIGITO,;
									TrbPes->BD6_MATANT,;
									TrbPes->BD6_NOMUSR,;
									TrbPes->BD6_CODOPE+"."+TrbPes->BD6_CODLDP+"."+TrbPes->BD6_CODPEG+"."+TrbPes->BD6_NUMERO,;
									If(TrbPes->BD6_TIPGUI=='03',"Solicitação de Internação",(If(TrbPes->BD6_TIPGUI=='02',"SADT","Resumo de internação"))),;
									TrbPes->BD6_CODPRO,;
									TrbPes->BD6_DESPRO,;
									stod(TrbPes->BD6_DATPRO),; 
									TrbPes->RECBD6 }))
	
		TrbPes->(DbSkip())
	EndDo
	      
	TrbPes->(DbCloseArea()) 

EndIf 

RestArea(aArea)

If Len(aBrowGui) == 0
	aBrowGui := aClone(aVetPad)   
EndIf       

oBrowGui:nAt := 1 // Configuro nAt para um 1 pois estava ocorrendo erro de "array out of bound" qdo se fazia
                  // uma pesquisa mais abrangante e depois uma nova pesquisa menos abrangente
                  // Exemplo:
                  // 1a. Pesquisa: "A" - Tecle <END> para ir ao final e retorne ate a primeira linha do browse
                  // (via seta para cima ou clique na primeira linha)
                  // 2a. Pesquisa: "AV" - Ocorria o erro
oBrowGui:SetArray(aBrowGui)
oBrowGui:Refresh() 
oBrowGui:SetFocus()

Return(.T.)


//------------------------------------------------------------------
/*/{Protheus.doc} PL298VLGUI
Valida a Guia e item, junto com os dados da Nota Fiscal.
A funcão é chamada no SX3, no campo B19_GUIA (X3_VALID)
@type function
@since 12/2022
/*/
//------------------------------------------------------------------
Function PL298VLGUI()
local aRetFun   := {}
Local lRet      := .T.
local oModel    := FWModelActive()
local oGridB19  := oModel:GetModel("B19Detail")
local cNumGuia  := oGridB19:GetValue("B19_GUIA")
local cSD1Item  := oGridB19:GetValue("B19_ITEM")
local cSD1Cod   := oGridB19:GetValue("B19_COD")
local nLinha    := oGridB19:GetLine()
local cMgsErro  := ""
local cDetErro  := ""

if (!VldPreCab(oModel))
    lRet := .f. 
endif

if lRet
    If !Empty(cNumGuia)
        lRet := ExistCpo("BD6", cNumGuia) 
        
        if lRet
            //Verifamos se a guia não foi lançada em outra nota ou se o item da NF não foi lançado mais de uma vez para a mesma guia
            aRetFun := PlVerHisB19(oModel, cNumGuia, nLinha, cSD1Item)
            if (!aRetFun[1])
                cMgsErro := aRetFun[2]
                cDetErro := STR0040 //"Confira os dados lançados."
                lRet := .f.
            endif
        endif

        if lRet
            //Verificamos agora a questão do Saldo de Itens e os cálculos, para o campo B19_VLRTNF r7
            aRetFun := PlSldVlr298(oModel, cNumGuia, nLinha, cSD1Item, cSD1Cod)
            if (!aRetFun[1])
                cMgsErro := aRetFun[2]
                //Necessário revisar a ligação entre eventos Guia x item da NF, pois a quantidade do item na NF é menor que o total utilizado pelas guias.
                cDetErro := STR0050
                lRet := .f.
            endif
        endif
      
    EndIf
endif

if !lRet
    Help(nil, nil , STR0037, nil, cMgsErro, 1, 0, nil, nil, nil, nil, nil, {cDetErro} ) //Atenção
else
    VldItemNom(oModel, "2") //Atualizo o nome do usuário no grid
endif

Return lRet


//------------------------------------------------------------------
/*/{Protheus.doc} PlVldNota
verifica se os dados da NF inseridos são válidos, para preencher o grid com os itens da NF.
cTipo 1 - Valida Fornecedor / 2 - Valida Loja / 3 - Valida Documento / 4 - Valida Serie (final)
@type function
@since 12/2022
/*/
//------------------------------------------------------------------
Function PlVldNota(oModel, cTipo)
local oGrid         := oModel:getmodel("B19Detail")
local oCab          := oModel:getmodel("MASTERCAB")
local cNumFornec    := oCab:getvalue("B19_FORNEC")
local cNumLoja      := oCab:getvalue("B19_LOJA")
local cNumDOC       := oCab:getvalue("DOC")
local cNumSerie     := oCab:getvalue("SERIE")
local lRet          := .t.
local nCount        := 1
local lExsCmp       := B19->(FieldPos("B19_PRINCI")) > 0

//Verifico se a nota já não está cadastrada no sistema
if oModel:GetOperation() == MODEL_OPERATION_INSERT

    if (cTipo == "1")
        lRet := ExistCpo("SA2", cNumFornec)
    elseif (cTipo == "2")
        lRet := ExistCpo("SA2", cNumFornec + cNumLoja)
    elseif (cTipo == "3")
        lRet := ExistCpo("SF1", cNumFornec + cNumLoja + cNumDOC, 2)                                                      
    else
        B19->(DbSetOrder(1)) //B19_FILIAL, B19_DOC, B19_SERIE, B19_FORNEC, B19_LOJA, R_E_C_N_O_, D_E_L_E_T_
        if B19->(MsSeek(xFilial("B19") + cNumDOC + cNumSerie + cNumFornec + cNumLoja))
            //"Nota Fiscal cadastrada no sistema." "Se precisa adicionar guias nessa nota, localize-a no browse e edite."
            Help(nil, nil , STR0037, nil, STR0053, 1, 0, nil, nil, nil, nil, nil, {STR0054} )
            lRet := .f.
        else
            //Atribuir nome do fornecedor
            oCab:loadvalue("NOMEFOR", Posicione("SA2", 1, xFilial("SA2") + cNumFornec+cNumLoja, "A2_NOME"))
            PlExclLinhas(oModel)
            SF1->(DbSetOrder(1))
            If SF1->(MsSeek(xFilial("SF1") + cNumDOC + cNumSerie + cNumFornec + cNumLoja))
                SD1->(DbSetOrder(1))
                SD1->(MsSeek(xFilial("SD1")+SF1->(F1_DOC+F1_SERIE+F1_FORNECE+F1_LOJA)))

                Do While SD1->(!Eof()) .And. SD1->(D1_FILIAL+D1_DOC+D1_SERIE+D1_FORNECE+D1_LOJA) == xFilial("SD1")+SF1->(F1_DOC+F1_SERIE+F1_FORNECE+F1_LOJA)
                    if(nCount > 1)
                        oGrid:AddLine()
                    endif
                    oGrid:Goline( nCount )
                    oGrid:LoadValue("B19_FILIAL"    , xFilial("B19") )
                    oGrid:LoadValue("B19_FORNEC"    , Alltrim(cNumFornec) )
                    oGrid:LoadValue("B19_LOJA"      , Alltrim(cNumLoja) )
                    oGrid:LoadValue("B19_DOC"       , Alltrim(cNumDOC) )
                    oGrid:LoadValue("B19_SERIE"     , Alltrim(cNumSerie) )
                    oGrid:LoadValue("B19_ITEM"      , Alltrim(SD1->D1_ITEM) )
                    oGrid:LoadValue("B19_COD"       , Alltrim(SD1->D1_COD) )
                    oGrid:LoadValue("B19_DESC"      , Alltrim(Posicione("SB1", 1, xFilial("SB1") + SD1->D1_COD, "B1_DESC")) )
                    oGrid:LoadValue("B19_NOMUSR"    , "")
                    if lExsCmp
                        oGrid:LoadValue("B19_PRINCI"    , iif(nCount == 1, "1", "0"))
                    endif
                    nCount++
                    SD1->(DbSkip())
                EndDo
                oGrid:Goline(1)
            else
                lRet := .f.
                Help(nil, nil , STR0037, nil, STR0005, 1, 0, nil, nil, nil, nil, nil, nil )//Documento/série inválido para o fornecedor/loja introduzido!
            endif    
        
        endIf
    endif
endif    
	
Return lRet


//------------------------------------------------------------------
/*/{Protheus.doc} PlExclLinhas
Ao trocar o documento no cabeçalho, limpar as linhas do grid e trazer apenas os dados da NF selecionada
@type function
@since 12/2022
/*/
//------------------------------------------------------------------
static function PlExclLinhas(oModel)
Local oB19Itens	:= oModel:getmodel("B19Detail")
Local nFor      := 0
local nTamGrid  := oB19Itens:Length()

For nFor := 1 to nTamGrid
    oB19Itens:GoLine(nFor)
    oB19Itens:DeleteLine()
Next
oB19Itens:cleardata()
return


//------------------------------------------------------------------
/*/{Protheus.doc} VldItemNom
Inserir nome do item da NF, buscando o dado na SB1
@type function
@since 12/2022
/*/
//------------------------------------------------------------------
static function VldItemNom(oModel, cTipo)
local oGrid     := oModel:getmodel("B19Detail")
local cCodItem  := oGrid:getvalue("B19_COD")
local cCodGuia  := oGrid:getvalue("B19_GUIA")
default cTipo   := "1"

if (cTipo == "1")
    oGrid:LoadValue("B19_DESC", Alltrim(Posicione("SB1", 1, xFilial("SB1") + cCodItem, "B1_DESC")) )
else
    oGrid:LoadValue("B19_NOMUSR", Alltrim(Posicione("BD6", 1, xFilial("BD6") + cCodGuia, "BD6_NOMUSR")) )
endif
return .t.


//------------------------------------------------------------------
/*/{Protheus.doc} PlVerHisB19
Função para analisar se a guia e item lançada já consta em outra Nota Fiscal, para bloqueio
@type function
@since 12/2022
/*/
//-------------------------------------------------------------------
static function PlVerHisB19(oModel, cNumGuia, nLinha, cD1Item)
local cAliasMov := GetNextAlias()
local aLinhaSlv := FwSaveRows()
local oGridB19  := oModel:GetModel("B19Detail")
local nTamGrid  := oGridB19:length()
local nFor      := 0
local lRet      := .t.
local cMgsErro  := ""
local cFornec   := oGridB19:GetValue("B19_FORNEC") 
local cLoja     := oGridB19:GetValue("B19_LOJA")
local cDoc      := oGridB19:GetValue("B19_DOC")
local cSerie    := oGridB19:GetValue("B19_SERIE")

for nFor := 1 to nTamGrid
    oGridB19:GoLine(nFor)
    if ( !oGridB19:IsDeleted() .and. nLinha != nFor )
        if ( oGridB19:GetValue("B19_GUIA") == cNumGuia .and. oGridB19:GetValue("B19_ITEM") == cD1Item ) 
            lRet := .f.
            //Guia já informada para o mesmo item dessa NF. / Item: / Documento: / Linha: 
            cMgsErro := STR0039 + CRLF + STR0052 + oGridB19:GetValue("B19_ITEM") + " - " + ;
                        STR0033 + ": " + oGridB19:GetValue("B19_DOC") + " - " + STR0051 + cValtoChar(nFor)
        elseif ( oGridB19:GetValue("B19_GUIA") == cNumGuia .and. oGridB19:GetValue("B19_ITEM") != cD1Item ) 
            lRet := .f.
            cMgsErro := STR0048 + CRLF + STR0049 + CRLF + STR0052 + oGridB19:GetValue("B19_ITEM")+ " - " +; //Guia/Evento já informada para outro item da Nota Fiscal. - Não é possível relacionar um evento de guia para mais de um item de NF.
                        STR0033 + ": " + oGridB19:GetValue("B19_DOC") + " - " + STR0051 + cValtoChar(nFor) //Documento / Item: / Documento: / Linha: 
        endif          
    endif
Next

if lRet
    BeginSql Alias cAliasMov

        SELECT B19.B19_FORNEC FORNEC, B19.B19_LOJA LOJA, B19.B19_DOC DOC, B19.B19_SERIE SERIE, B19.R_E_C_N_O_ REC FROM  %table:B19% B19 
            WHERE
                B19.B19_FILIAL      =  %xfilial:B19% 
                AND B19.B19_GUIA    =  %exp:cNumGuia%
                AND 
                (B19.B19_FORNEC     <> %exp:cFornec%
                OR B19.B19_LOJA     <> %exp:cLoja%
                OR B19.B19_DOC      <> %exp:cDoc%
                OR B19.B19_SERIE    <> %exp:cSerie%)  
                AND B19.%notDel%
    EndSql  

    if !(cAliasMov)->( Eof() )
        lRet := .f.
        //Guia já informada para o seguinte Fornecedor / Loja / Nº Documento / Série: 
        cMgsErro := STR0041 + CRLF + (cAliasMov)->FORNEC + " / " + (cAliasMov)->LOJA + " / " +;
                    (cAliasMov)->DOC + " / " + (cAliasMov)->SERIE + CRLF
    endif
    (cAliasMov)->(DbCloseArea())

endif
FWRestRows( aLinhaSlv )
return {lRet, cMgsErro}


//------------------------------------------------------------------
/*/{Protheus.doc} PlSldVlr298
Função para analisar saldos e valores,d e acordo com a Guia e Nota Fiscal.
@type function
@since 12/2022
/*/
//-------------------------------------------------------------------
static function PlSldVlr298(oModel, cNumGuia, nLinha, cD1Item, cSD1Cod)
local aAreaBD6  := BD6->(GetArea())
local aLinhaSlv := FwSaveRows()
Local oB19Itens	:= oModel:getmodel("B19Detail")
Local nFor      := 0
local nTamGrid  := oB19Itens:Length()
local nQtdBD6T  := 0
local aRetDS1   := {}
local lRet      := .f.
local nValorCmp := 0
local nQtdPosic := 0
local cDetalhes := ""

//1º Vamos verificar se já existem outras guias associadas a nota, em itens diferentes, para verificar a quantidade.
For nFor := 1 to nTamGrid
    oB19Itens:GoLine(nFor)
    if !oB19Itens:IsDeleted() .and. oB19Itens:GetValue("B19_COD") == cSD1Cod .and. oB19Itens:GetValue("B19_ITEM") == cD1Item
        nQtdBD6T += PlVerifBD6(oB19Itens:GetValue("B19_GUIA"), @cDetalhes)
    endif
Next

//2º Vamos verificar a quantidade do item direto na SD1
aRetDS1 := PlVerifSD1( oB19Itens:GetValue("B19_DOC")  + oB19Itens:GetValue("B19_SERIE") + oB19Itens:GetValue("B19_FORNEC") + ;
                       oB19Itens:GetValue("B19_LOJA") + cSD1Cod + cD1Item)

//3º Vamos pegar a quantidade apenas do item que está sendo lançado na BD6
nQtdPosic := PlVerifBD6(cNumGuia)

//4º Vamos comparar se pode lançar, ou seja, se a quantidade de itens da NF é maior que o total usado na BD6
if aRetDS1[1] >= nQtdBD6T
    lRet := .t.
endif

//Restaurar a linha correta
FWRestRows( aLinhaSlv )

//5º Fazer os cálculos para preencher o campo B19_VLRTNF
if lRet
    if aRetDS1[3] == "1"
        //Valor total D1_CUSTO, dividido pela quantidade da BD6
        nValorCmp := round( (aRetDS1[2] / nQtdPosic), 2 )
    else
        //Valor de ((D1_TOTAL – D1_VALDES) / D1_QUANT), vezes a quantidade da BD6 ( ((D1_TOTAL – D1_VALDES) / D1_QUANT) x BD6_QTDPRO )
        nValorCmp := round( (aRetDS1[2] * nQtdPosic) , 2) 
    endif
    oB19Itens:LoadValue("B19_VLRTNF", nValorCmp )
endif

if !lRet
    //"A quantidade de eventos das Guias usando o mesmo item é maior que a quantidade do item na NF - Quantidade NF: "
    cDetalhes := STR0046 + cvaltochar(aRetDS1[1]) + CRLF + cDetalhes 
endif

RestArea(aAreaBD6)
return {lRet, cDetalhes}


//------------------------------------------------------------------
/*/{Protheus.doc} PlVerifBD6
Função para buscar dados na BD6, das guias que atendam ao critério de busca
@type function
@since 12/2022
/*/
//-------------------------------------------------------------------
static function PlVerifBD6(cNumGuia, cDetalhes)
local nQuantid      := 0
default cDetalhes   := ""

BD6->(DbSetOrder(1))
if BD6->(DbSeek(xFilial("BD6") + cNumGuia))
    nQuantid := BD6->BD6_QTDPRO
    cDetalhes += STR0044 + cNumGuia + " - " + STR0045 + cvaltochar(nQuantid) + CRLF //Guia:  - Quantidade: 
endif
return nQuantid


//------------------------------------------------------------------
/*/{Protheus.doc} PlVerifSD1
Função para buscar dados na SD1, para verificar quantidade e valor da NF.
@type function
@since 12/2022
/*/
//-------------------------------------------------------------------
static function PlVerifSD1(cNumNota)
local aDadosSD1 := {0, 0, ""}
local cValParam := getNewPar('MV_PLAPCUS','0')

//D1_FILIAL, D1_DOC, D1_SERIE, D1_FORNECE, D1_LOJA, D1_COD, D1_ITEM, R_E_C_N_O_, D_E_L_E_T_
SD1->(DbSetOrder(1))
if SD1->(DbSeek(xFilial("SD1") + cNumNota))
    aDadosSD1[1] := SD1->D1_QUANT
    if (cValParam == "1")
        //Se estiver parametrizado pelo custo, pegamos o campo D1_CUSTO
        aDadosSD1[2] := SD1->D1_CUSTO
    else
        //Se estiver parametrizado pelo total, fazemos o cálculo entre ((D1_TOTAL – D1_VALDESC) / D1_QUANT)
        aDadosSD1[2] := Round(((SD1->D1_TOTAL - SD1->D1_VALDESC) / SD1->D1_QUANT), 2)
    endif 
    aDadosSD1[3] := cValParam
endif
return aDadosSD1


//------------------------------------------------------------------
/*/{Protheus.doc} PlItem298
Função para validar se o item inserido no grid existe na SD1, e para preencher os demais campos.
A funcão é chamada no SX3, no campo B19_ITEM (X3_VALID)
@type function
@since 12/2022
/*/
//-------------------------------------------------------------------
function PLItem298()
local oModel        := FWModelActive()
local oGridB19      := oModel:GetModel("B19Detail")
local cNumFornec    := oGridB19:getvalue("B19_FORNEC")
local cNumLoja      := oGridB19:getvalue("B19_LOJA")
local cNumDOC       := oGridB19:getvalue("B19_DOC")
local cNumSerie     := oGridB19:getvalue("B19_SERIE")
local cItemInse     := oGridB19:getvalue("B19_ITEM")
local cFilSD1       := xFilial("SD1")
local cChave        := cFilSD1 + cNumDOC + cNumSerie + cNumFornec + cNumLoja
local lRet          := .f.

SD1->(DbSetOrder(1))
if SD1->(MsSeek(cChave))
    Do While SD1->(!Eof()) .And. SD1->(D1_FILIAL+D1_DOC+D1_SERIE+D1_FORNECE+D1_LOJA) == cChave
        if (cItemInse == SD1->D1_ITEM)
            lRet := .t.
            oGridB19:LoadValue("B19_COD"    , Alltrim(SD1->D1_COD) ) 
            oGridB19:LoadValue("B19_DESC"   , Alltrim(Posicione("SB1", 1, xFilial("SB1") + SD1->D1_COD, "B1_DESC")) )
            exit
        endif
        SD1->(DbSkip())
    enddo
endif
if !lRet
    Help(nil, nil , STR0037, nil, STR0047, 1, 0, nil, nil, nil, nil, nil, nil ) //Atenção - Código do item inserido não existe na Nota Fiscal.
endif
return lRet


//------------------------------------------------------------------
/*/{Protheus.doc} PL298GrLd
Função para retornar a descrição do produto ou nome do usuário.
Se linha for zero, significa que estamos no load do form, devemos carregar o inicializador, pois é linha a linha.
Se  diferente de zero - sempre na última linha do grid salvo, significa que estamos inserindo/alterando, o valor deve ser vazio
Outra forma, ao inserir nova linha, fica descrição e nome de usuário 'fantasma', retornando da 1ª linha grid 
A funcão é chamada no SX3, no campo B19_COD e B19_GUIA (X3_RELACAO)
@type function
@since 12/2022
/*/
//-------------------------------------------------------------------
function PL298GrLd(cTipo)
local oModel        := FWModelActive()
local oGridB19      := oModel:GetModel("B19Detail")
local nNumLin       := oGridB19:getline()
local nOperac       := oModel:getOperation()
local cValor        := ""
default cTipo       := "1"

if ( nOperac != MODEL_OPERATION_INSERT .and. nNumLin == 0 )
    if cTipo == "1" .and. !empty(B19->B19_COD)
        cValor :=  Alltrim(Posicione("SB1", 1, xFilial("SB1") + B19->B19_COD, "B1_DESC"))
    elseif cTipo == "2" .and. !empty(B19->B19_GUIA)
        cValor :=  Alltrim(Posicione("BD6", 1, xFilial("BD6") + B19->B19_GUIA, "BD6_NOMUSR"))
    endif
endif

return cValor
