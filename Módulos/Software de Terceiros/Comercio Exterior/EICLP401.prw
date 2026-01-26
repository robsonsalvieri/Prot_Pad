#INCLUDE 'TOTVS.CH'
#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"
#Include "TOPCONN.CH"
#INCLUDE "AVERAGE.CH"
#Include 'EICLP401.CH'

#define ENTER CHR(13)+CHR(10)
#define ATRIBUTO_COMPOSTO "ATRIBUTO_COMPOSTO"
/*---------------------------------------------------------------------*/
/*/{Protheus.doc} EICLP401
   (rotina para amarração entre Formulário LPCO x N.c.m)
   @type  Function
   @author Nilson César
   @since 04/11/2020
   @version 1
   @param param, param_type, param_descr
   @return returno,return_type, return_description
   @example
   (examples)
   #@see (lINCLUDEinks_or_references) 'TOTVS.CH'
   /*/
/*---------------------------------------------------------------------*/
Function EICLP401(xRotAuto,nOpcAuto)

Local aArea       := GetArea()
Local aAreaEKO    := EKO->(GetArea())
Local aCores      := {}
Local nX
local lLibAccess  := .F.
local lExecFunc   := .F. // existFunc("FwBlkUserFunction")

Private cTitulo   := OemToAnsi(STR0001) //"Manutenção de LPCO"
Private lFormAuto := ValType(xRotAuto) == "A" .And. ValType(nOpcAuto) == "N"
Private aRotAuto  := iif( lFormAuto, aclone(xRotAuto) , nil )
Private aRotina   := MenuDef()
Private oBrowse
Private oBufSeqEK := tHashMap():New()
Private oPOUI
Private cHashPOUI := ""

if lExecFunc
   FwBlkUserFunction(.T.)
endif

lLibAccess := AmIin(17,29)

if lExecFunc
   FwBlkUserFunction(.F.)
endif

If lLibAccess .and. TEOpenApp(.T.) //Verifica se esta habilita as configurações de multiprotocolo
   aCores := {	{"EKO_INTEGR == '1' ","BR_VERDE"	   ,STR0002	},; //"Integrado"
               {"EKO_INTEGR == '2' ","BR_VERMELHO"	,STR0003	}}	 //"Não Integrado"

   If !lFormAuto 
      oBrowse := FWMBrowse():New()
      oBrowse:SetAlias("EKO")
      oBrowse:SetMenudef("EICLP401")
      oBrowse:SetDescription(STR0001) //"Manutenção de LPCO"

      //Adiciona a legenda
      For nX := 1 To Len( aCores )   	    
         oBrowse:AddLegend( aCores[nX][1], aCores[nX][2], aCores[nX][3] )
      Next nX

      //Habilita a exibição de visões e gráficos
      oBrowse:SetAttach( .T. )
      //Configura as visões padrão
      oBrowse:SetViewsDefault(LP401GetVs())
      oBrowse:CIDVIEWDEFAULT := "1" //View "1-Ativo"
      oBrowse:Activate()
   Else
      FWMVCRotAuto(ModelDef(),"EKO",nOpcAuto,{{"EKOMASTER",xRotAuto}})
   EndIf

   RestArea(aAreaEKO)
   RestArea( aArea )
EndIf
Return Nil

/*---------------------------------------------------------------------*
 | Func:  MenuDef                                                      |
 | Autor: Nilson César                                                 |
 | Data:  04/11/2020                                                   |
 | Desc:  Menu com as rotinas                                          |
 | Obs.:  /                                                            |
 *---------------------------------------------------------------------*/
Static Function MenuDef()
   Local aRot := {}

   ADD OPTION aRot TITLE STR0013 ACTION 'AxPesqui'           OPERATION 1                      ACCESS 0 //OPERATION 1 //'Pesquisar'
   ADD OPTION aRot TITLE STR0014 ACTION 'VIEWDEF.EICLP401'   OPERATION MODEL_OPERATION_VIEW   ACCESS 0 //OPERATION 2 //'Visualizar'
   ADD OPTION aRot TITLE STR0015 ACTION 'VIEWDEF.EICLP401'   OPERATION MODEL_OPERATION_INSERT ACCESS 0 //OPERATION 3 //'Incluir' 
   ADD OPTION aRot TITLE STR0016 ACTION 'VIEWDEF.EICLP401'   OPERATION MODEL_OPERATION_UPDATE ACCESS 0 //OPERATION 4 //'Alterar'
   ADD OPTION aRot TITLE STR0017 ACTION 'VIEWDEF.EICLP401'   OPERATION MODEL_OPERATION_DELETE ACCESS 0 //OPERATION 5 //'Excluir'
   ADD OPTION aRot TITLE STR0019 ACTION 'LP401Legen'         OPERATION 6                      ACCESS 0 //OPERATION 5 //'Legenda'

Return aRot

/*---------------------------------------------------------------------*
 | Func:  ModelDef                                                     |
 | Autor: Nilson César                                                 |
 | Data:  04/11/2020                                                   |
 | Desc:  Criação do modelo de dados MVC                               |
 | Obs.:  /                                                            |
 *---------------------------------------------------------------------*/
 Static Function ModelDef()

    //Criação do objeto do modelo de dados
    Local oModel    := Nil
    Local bCancel   := { || LP401CANCE("MODEL")}
    Local bPost     := {|oModel| LP401VALID("MODEL_POS") }
    Local bCommit   := {|oModel| LP401Commit(oModel) }
    Local oStEKO    := FWFormSTRuct(1, "EKO")
    Local oStEKP    := FWFormSTRuct(1, "EKP")
    Local bCodBlock := {|oGridModel, nLine, cAction, cIDField, xValue, xCurrentValue| lineGrid(oGridModel, nLine, cAction, cIDField, xValue, xCurrentValue)}
    Local oMdlEvent := LP401Event():New()
    
    aRelEKP := {{"EKP_FILIAL","EKO_FILIAL"},;
                {"EKP_ID"    ,"EKO_ID"    },;
                {"EKP_VERSAO","EKO_VERSAO"}}

    oModel := MPFormModel():New("EICLP401",/*bPreV*/, bPost ,bCommit,bCancel)
    oModel:AddFields("EKOMASTER",/*cOwner*/ ,oStEKO )
    oModel:SetPrimaryKey({'EKO_FILIAL','EKO_ID','EKO_VERSAO'})
    oModel:AddGrid( "EKPDETAIL","EKOMASTER",oStEKP, bCodBlock )
    oModel:SetRelation("EKPDETAIL",aRelEKP, EKP->(IndexKey(1)))
    oModel:SetDescription(STR0004)                       
    oModel:GetModel("EKOMASTER"):SetDescription(STR0006) //"Dados da LPCO"
    oModel:GetModel("EKPDETAIL"):SetDescription(STR0005) //"Detalhes LPCO"
    oModel:GetModel("EKPDETAIL"):SetOptional( .T. )

    oModel:InstallEvent("LP401Event", , oMdlEvent)

Return oModel

/*---------------------------------------------------------------------*
 | Func:  lineGrid                                                     |
 | Autor: Miguel Prado                                                 |
 | Data:  04/11/2020                                                   |
 | Desc:  Carregamento da linha do gridModel com dados chave.          |
 | Obs.:  /                                                            |
 *---------------------------------------------------------------------*/
function lineGrid(oMdl_EKP, nLine, cAction, cIDField, xValue, xCurrentValue)
   Local lRet := .T.
   Local oMdl := FWModelActive()
   Local oMdl_EKO := oMdl:GetModel():GetModel("EKOMASTER")

      if oMdl_EKP:IsInserted()
         oMdl_EKP:LoadValue( "EKP_FILIAL" , xFilial("EKP") )
         oMdl_EKP:LoadValue( "EKP_ID"     , oMdl_EKO:GetValue("EKO_ID" )     ) 
         oMdl_EKP:LoadValue( "EKP_VERSAO" , oMdl_EKO:GetValue("EKO_VERSAO" ) )
      endif

return lRet

/*---------------------------------------------------------------------*
 | Func:  ViewDef                                                      |
 | Autor: Nilson César                                                 |
 | Data:  04/11/2020                                                   |
 | Desc:  Criação da visão MVC                                         |
 | Obs.:  /                                                            |
 *---------------------------------------------------------------------*/
Static Function ViewDef()

    Local oModel := FWLoadModel("EICLP401")
    Local oStEKO := FWFormSTRuct(2, "EKO")  
    Local oStEKP := FWFormSTRuct(2, "EKP")  
    Local oView := Nil
    Local oPanel

    oStEKP := SetRemove(oStEKP,{"EKP_ID", "EKP_VERSAO"})
    oView := FWFormView():New()
    oView:SetModel(oModel)
    oView:AddField("VIEW_EKO", oStEKO, "EKOMASTER")
    oView:AddOtherObject("VIEW_EKP", {|oPanel,oView| GetFormPOUI(oPanel,oView, 1)},{|oPanel,oView| GetFormPOUI(oPanel,oView, 2)},{|oPanel,oView| GetFormPOUI(oPanel,oView, 3)})
    oView:SetContinuousForm(.T.)
    oView:CreateHorizontalBox( 'ACIMA' , 10)
    oView:CreateHorizontalBox( 'ABAIXO', 90)
    oView:SetOwnerView("VIEW_EKO","ACIMA" )
    oView:SetOwnerView("VIEW_EKP","ABAIXO")
    oModel:GetModel("EKOMASTER"):SetDescription(STR0006) //"Dados da LPCO"
    oModel:GetModel("EKPDETAIL"):SetDescription(STR0007) //"Detalhes da LPCO - Dados do Formulário"
    oView:EnableTitleView('VIEW_EKO', STR0006 )
    oView:EnableTitleView('VIEW_EKP', STR0007 )
    oView:SetCloseOnOk({||.T.})

Return oView

/*---------------------------------------------------------------------*
 | Func:  LP401GetVs                                                   |
 | Autor: Nilson César                                                 |
 | Data:  04/11/2020                                                   |
 | Desc:  Montar e retornar as visões Default do Browse                |
 | Obs.:  /                                                            |
 *---------------------------------------------------------------------*/
Static Function LP401GetVs()
Local aVisions    := {}
Local aColunas    := AvGetCpBrw("EKO")
Local aContextos  := {"ATIVOS","TODOS","INTEGRADOS", "NAO_INTEGRADOS"}
Local cFiltro     := ""
Local oDSView
Local i

   If aScan(aColunas, "EKO_FILIAL") == 0
      aAdd(aColunas, "EKO_FILIAL")
   EndIf

   For i := 1 To Len(aContextos)
      cFiltro := LP401GetFt(aContextos[i])            
      oDSView    := FWDSView():New()
      oDSView:SetName(AllTrim(Str(i)) + "-" + LP401GetFt(aContextos[i], .T.))
      oDSView:SetPublic(.T.)
      oDSView:SetCollumns(aColunas)
      oDSView:SetOrder(1)
      oDSView:AddFilter(AllTrim(Str(i)) + "-" + LP401GetFt(aContextos[i], .T.), cFiltro)
      oDSView:SetID(AllTrim(Str(i)))
      oDsView:SetLegend(.T.)
      aAdd(aVisions, oDSView)
   Next

Return aVisions

/*---------------------------------------------------------------------------------------------------------*
 | Func:  LP401GetFt                                                                                       |
 | Autor: Nilson César                                                                                     |
 | Data:  04/11/2020                                                                                       |
 | Desc:  Retorna a chave ou nome do filtro da tabela EKO de acordo com o contexto desejado                |
 | Obs.:  /                                                                                                |
 *--------------------------------------------------------------------------------------------------------*/
Static Function LP401GetFt(cTipo, lNome)
Local cRet     := ""
Default lNome  := .F.

   Do Case
      Case cTipo == "ATIVOS" .And. !lNome
         cRet := "EKO->EKO_ATIVO = '1' "
      Case cTipo == "ATIVOS" .And. lNome
         cRet := STR0008 //"Ativos"

      Case cTipo == "TODOS" .And. !lNome
         cRet := "AllwaysTrue() "
      Case cTipo == "TODOS" .And. lNome
         cRet := STR0009 //"Todos"

      Case cTipo == "INTEGRADOS" .And. !lNome
         cRet := "EKO->EKO_INTEGR = '1' "
      Case cTipo == "INTEGRADOS" .And. lNome
         cRet := STR0010 //"Integrados"

      Case cTipo == "NAO_INTEGRADOS" .And. !lNome
         cRet := "EKO->EKO_INTEGR = '2' "
      Case cTipo == "NAO_INTEGRADOS" .And. lNome
         cRet := STR0011 //"Não integrados"
   EndCase

Return cRet

/*---------------------------------------------------------------------*
 | Func:  LP401Legen                                                   |
 | Autor: Nilson César                                                 |
 | Data:  28/08/2020                                                   |
 | Desc:  Retorna a tela de Legendas                                   |
 | Obs.:  /                                                            |
 *---------------------------------------------------------------------*/
Function LP401Legen()
Local aCores := {}

   aCores := {	{"BR_VERDE"   ,STR0002	},; //"Integrado"
               {"BR_VERMELHO",STR0003	}}	 //"Não Integrado"

   BrwLegenda(STR0001,"Legenda",aCores)

Return .T.

/*---------------------------------------------------------------------*
 | Func:  LP401Commit                                                  |
 | Autor: Nilson César                                                 |
 | Data:  28/08/2020                                                   |
 | Desc:  função de commit de capa/detalhe (EKO/EKP)                   |
 | Obs.:  /                                                            |
 *---------------------------------------------------------------------*/
Function LP401Commit(oModel)
Local oMdl := FWModelActive()
Local oMdl_EKO := oMdl:GetModel():GetModel("EKOMASTER")
Local lSeek, lRet := .T.

If lRet

   Begin Transaction

      FWFormCommit( oModel, , , , , {|oModel| lRet := LP401BTNOK("VIEW",oModel)} )

      If EKO->(Eof()) .Or. EKO->EKO_ID <> oMdl_EKO:GetValue("EKO_ID" ) .Or. EKO->EKO_VERSAO <> oMdl_EKO:GetValue("EKO_VERSAO" )
         EKO->( DbSetOrder(1) )
         lSeek := EKO->(DbSeek( xFilial("EKO") + oMdl_EKO:GetValue("EKO_ID" ) + oMdl_EKO:GetValue("EKO_VERSAO" ) ))
      Else
         lSeek := .T.
      EndIf

      If lSeek .And. lRet
         EKO->(RecLock("EKO",.F.))
         EKO->EKO_DATACR := dDataBase
         EKO->EKO_HORACR := SUBSTR(TIME(), 1, 2)+SUBSTR(TIME(), 4, 2)+SUBSTR(TIME(), 7, 2) //Hora(s) + Minuto(s)
         EKO->(MsUnlock())
      EndIf

      If InTransaction() .And. !lSeek .Or. !lRet
         DisarmTransaction()
         lRet := .F.
      EndIf

   End Transaction

EndIf

Return lRet

/*---------------------------------------------------------------------*
 | Func:  LP401CANCE                                                   |
 | Autor: Nilson César                                                 |
 | Data:  04/11/2020                                                   |
 | Desc:  Validação e execução antes do carregamento do modelo em tela |
 | Obs.:  /                                                            |
 *---------------------------------------------------------------------*/
Function LP401CANCE(cVar)
Local lRet := .T.
   If cVar == 'MODEL'
      //Limpa o ojeto das sequências para reapuração
      If IsMemVar("oBufSeqEK")
         oBufSeqEK:Clean()
      EndIf
   EndIf
Return lRet

/*---------------------------------------------------------------------*
 | Func:  LP401VALID                                                   |
 | Autor: Nilson César                                                 |
 | Data:  04/11/2020                                                   |
 | Desc:  Validação de campos                                          |
 | Obs.:  /                                                            |
 *---------------------------------------------------------------------*/
Function LP401VALID(cCpo)
Local lRet := .T.
Local oMdl := FWModelActive()
Local oMdl_EKO := oMdl:GetModel():GetModel("EKOMASTER")

Do Case
   //CAPA
   Case cCpo == 'EKO_ID'
      lRet := ExistChav( "EKO", oMdl_EKO:GetValue("EKO_ID" )+oMdl_EKO:GetValue("EKO_VERSAO" ) )

   Case cCpo == 'EKO_VERSAO'
      lRet := ExistChav( "EKO", oMdl_EKO:GetValue("EKO_ID" )+oMdl_EKO:GetValue("EKO_VERSAO" ) )

   Case cCpo == 'EKO_LPCO'
      lRet := .T.

   Case cCpo == 'EKO_ATIVO'
      lRet := oMdl_EKO:GetValue("EKO_ATIVO" ) $ "1|2"

   Case cCpo == 'EKO_ORGANU'
      lRet := ExistCpo( "SJJ", oMdl_EKO:GetValue("EKO_ORGANU" ))

   Case cCpo == 'EKO_FRMLPC'
      lRet := ExistCpo( "EKL", oMdl_EKO:GetValue("EKO_ORGANU" )+oMdl_EKO:GetValue("EKO_FRMLPC" ))
      If lRet
         lRet := HasJsForm(oMdl_EKO:GetValue("EKO_ORGANU" ),oMdl_EKO:GetValue("EKO_FRMLPC" ))
      EndIf

   Case cCpo == 'EKO_MODAL'
      lRet := oMdl_EKO:GetValue("EKO_MODAL" ) $ "1|2"

   Case cCpo == 'EKO_INTEGR'
      lRet := oMdl_EKO:GetValue("EKO_INTEGR" ) $ "1|2"

   Case cCpo == 'EKP_SQCPOF'
      lRet := .T.

   Case cCpo == 'EKP_CDCPOF'
      lRet := .T.

   Case cCpo == 'MODEL_POS'
      lRet := ExistCpo( "SJJ", oMdl_EKO:GetValue("EKO_ORGANU" ))
      If !Empty( oMdl_EKO:GetValue("EKO_FRMLPC" ) )
         lRet := ExistCpo( "EKL", oMdl_EKO:GetValue("EKO_ORGANU" )+oMdl_EKO:GetValue("EKO_FRMLPC" ))
      EndIf

End Case

Return lRet

/*---------------------------------------------------------------------*
 | Func:  LP401CONDT                                                   |
 | Autor: Nilson César                                                 |
 | Data:  04/11/2020                                                   |
 | Desc:  Condição para execução de Gatilho de campos                  |
 | Obs.:  /                                                            |
 *---------------------------------------------------------------------*/
Function LP401CONDT(cCpo)
Local oMdl := FWModelActive()
Local oMdl_EKO := oMdl:GetModel():GetModel("EKOMASTER")
Local lValue := .F.

Do Case
   Case cCpo == 'EKO_FRMLPC'
      lValue := !Empty(oMdl_EKO:GetValue("EKO_FRMLPC" ))

End Case

Return lValue

/*---------------------------------------------------------------------*
 | Func:  LP401TRIGG                                                   |
 | Autor: Nilson César                                                 |
 | Data:  04/11/2020                                                   |
 | Desc:  Gatilho de campos                                            |
 | Obs.:  /                                                            |
 *---------------------------------------------------------------------*/
Function LP401TRIGG(cCpo)
Local oMdl := FWModelActive()
Local oView := FWViewActive()
Local oMdl_EKO := oMdl:GetModel():GetModel("EKOMASTER")
Local xValue

Do Case

   Case cCpo == 'EKO_FRMLPC' //=>> 'EKO_MODAL'
      oMdl_EKO:LoadValue( "EKO_FILIAL" , xFilial("EKO") )
      xValue := If(LEFT(oMdl_EKO:GetValue("EKO_FRMLPC" ),1)=="I","1","2")
      oView:Refresh()

End Case

Return xValue

/*---------------------------------------------------------------------*
 | Func:  LP401WHEN                                                    |
 | Autor: Nilson César                                                 |
 | Data:  04/11/2020                                                   |
 | Desc:  Habilita/Desabilita alteração de campos                      |
 | Obs.:  /                                                            |
 *---------------------------------------------------------------------*/
Function LP401WHEN(cCpo)
Local oMdl := FWModelActive()
Local oMdl_EKO := oMdl:GetModel():GetModel("EKOMASTER")
// Local oMdl_EKP := oMdl:GetModel():GetModel("EKPDETAIL")
Local lRet := .T.
Local aEKOWHEN

   aEKOWHEN := {"EKO_MODAL","EKO_DATACR","EKO_HORACR","EKO_DATARG", "EKO_HORARG"}

   If oMdl:GetOperation() <> 3
      If !Empty(oMdl_EKO:GetValue("EKO_ID" ))
         aAdd(aEKOWHEN,"EKO_ID")
      EndIf
      If !Empty(oMdl_EKO:GetValue("EKO_VERSAO" ))
         aAdd(aEKOWHEN,"EKO_VERSAO")
      EndIf
      If !Empty(oMdl_EKO:GetValue("EKO_ORGANU" ))
         aAdd(aEKOWHEN,"EKO_ORGANU")
      Endif
      If !Empty(oMdl_EKO:GetValue("EKO_FRMLPC" ))
         aAdd(aEKOWHEN,"EKO_FRMLPC")
      EndIf
   EndIf

   If aScan( aEKOWHEN , cCpo ) > 0
      lRet := .F.
   EndIf   

Return lRet

/*---------------------------------------------------------------------*
 | Func:  SetRemove                                                   |
 | Autor: Nilson César                                                 |
 | Data:  04/11/2020                                                   |
 | Desc:  Remover da estrutura campos que não devem ser exibidos       |
 | Obs.:  /                                                            |
 *---------------------------------------------------------------------*/
Static Function SetRemove(oStruct,aCampos)
Local i := 0

For i := 1 To Len(aCampos)
   oStruct:RemoveField(aCampos[i])
Next

Return oStruct

/*---------------------------------------------------------------------*
 | Func:  LP401LOADV                                                   |
 | Autor: Nilson César                                                 |
 | Data:  04/11/2020                                                   |
 | Desc:  Carregar valores para determinados campos, como os virtuais  |
 | Obs.:  /                                                            |
 *---------------------------------------------------------------------*/
Function LP401LOADV(cCpo)
Local oMdl := FWModelActive()
Local oMdl_EKO := oMdl:GetModel("EKOMASTER")
Local oMdl_EKP := oMdl:GetModel("EKPDETAIL")
Local cValue   := ""


   Do Case
      Case cCpo == 'EKP_ID'
         oMdl_EKP:LoadValue( "EKP_FILIAL" , xFilial("EKP") )
         oMdl_EKP:LoadValue( "EKP_ID"     , oMdl_EKO:GetValue("EKO_ID" )     )
         oMdl_EKP:LoadValue( "EKP_VERSAO" , oMdl_EKO:GetValue("EKO_VERSAO" ) )
      Case cCpo == 'EKO_ID'
         cValue := NextSeqEK("EKO_ID")
      Case cCpo == 'EKO_VERSAO'
         cValue := NextSeqEK("EKO_VERSAO")
      Case cCpo == 'EKO_MODAL' .And. ValType(oMdl_EKO) == "O" .And. oMdl:GetOperation() <> 3
         cValue := If(LEFT(oMdl_EKO:GetValue("EKO_FRMLPC"),1)=="I","1","2")
      Case cCpo == 'EKO_ATIVO'
         cValue := "1"
      Case cCpo == 'EKO_INTEGR'
         cValue := "2"
   EndCase

Return cValue

/*---------------------------------------------------------------------*
 | Func:  LP401GCBOX                                                   |
 | Autor: Nilson César                                                 |
 | Data:  04/11/2020                                                   |
 | Desc:  Retornar conteúdo paa campos Combobox                        |
 | Obs.:  /                                                            |
 *---------------------------------------------------------------------*/
Function LP401GCBOX(cCpo)
Local cValue   := ""

   Do Case
      Case cCpo == 'EKO_ATIVO'
         cValue := "1=Sim;2=Não"
      Case cCpo == 'EKO_MODAL'
         cValue := "1=Importação;2=Exportação"
      Case cCpo == 'EKO_INTEGR'
         cValue := "1=Sim;2=Não"
   End Case

Return cValue

/*---------------------------------------------------------------------*
 | Func:  PesqModEKP                                                   |
 | Autor: Nilson César                                                 |
 | Data:  04/11/2020                                                   |
 | Desc:  Encontrar entre os detalhes algum que atenda a condição      |
 | Obs.:  /                                                            |
 *---------------------------------------------------------------------*/
Static Function PesqModEKP(oMdl_EKP,bCond,nPosAtu,cValue)
Local i, aRet := {.F.,0}

Begin Sequence
If oMdl_EKP:GetQtdLine() > 0
   For i:=1 To oMdl_EKP:GetQtdLine()
      oMdl_EKP:GoLine(i)
      If Eval(bCond)
         aRet := {.T.,i}
         Break
      EndIf
   Next i
EndIf
End Sequence

Return aRet

/*---------------------------------------------------------------------*
 | Func:  NextSeqEK                                                    |
 | Autor: Nilson César                                                 |
 | Data:  04/11/2020                                                   |
 | Desc:  Buscar próxima sequência dos campos sequenciais do modelo    |
 | Obs.:  /                                                            |
 *---------------------------------------------------------------------*/
Static Function NextSeqEK(cCpo)
Local cLastSeq := "000"
Local cAlias   := Left(cCpo,3)
Local oMdl     := FWModelActive()
Local oMdl_EKO := oMdl:GetModel():GetModel("EKOMASTER")
// Local oMdl_EKP := oMdl:GetModel():GetModel("EKPDETAIL")
Local cQryMax  := cQryWhere := cQryTab := ""
Local nOldArea, cAliasQry
local cChaveHash := ""

   If !IsMemVar("oBufSeqEK") .Or. oBufSeqEK == Nil
      oBufSeqEK:= tHashMap():New()
   EndIf

   cChaveHash := cCpo
   do case
      case cCpo == "EKO_ID"
         cChaveHash := cCpo + alltrim(xFilial("EKO")) 
      case cCpo == "EKO_VERSAO"
         cChaveHash := cCpo + alltrim(xFilial("EKO"))  + alltrim(oMdl_EKO:GetValue("EKO_ID" ))
   endcase

   If !oBufSeqEK:Get(cChaveHash, @cLastSeq)

      Do Case
         Case cCpo == "EKO_ID"
            cQryMax   := "% MAX(EKO_ID) LASTSEQ %"
            cQryWhere := "% EKO_FILIAL = '"+xFilial("EKO")+"' %" 
         Case cCpo == "EKO_VERSAO"
            cQryMax   := "% MAX(EKO_VERSAO) LASTSEQ %"
            cQryWhere := "% EKO_FILIAL = '"+xFilial("EKO")+"' AND EKO_ID = '"+oMdl_EKO:GetValue("EKO_ID" )+"' %"
         Case cCpo == "EKP_SQCPOF" 
            cQryMax   := "% MAX(EKP_SQCPOF) LASTSEQ %"
            cQryWhere := "% EKP_FILIAL = '"+xFilial("EKP")+"' AND EKP_ID = '"+oMdl_EKO:GetValue("EKO_ID" )+"' AND EKP_VERSAO = '"+oMdl_EKO:GetValue("EKO_VERSAO" )+"' %"
      End Case
      cQryTab   := "% "+RetSQLName(cAlias)+" %"

      nOldArea  := Select()
      cAliasQry := GetNextAlias()
      BeginSQL Alias cAliasQry
         SELECT %Exp:cQryMax% 
         FROM   %Exp:cQryTab%
         WHERE  %Exp:cQryWhere%
         AND    D_E_L_E_T_ = ' ' //%Exp:cAlias%.%NotDel% 
      EndSql
      If (cAliasQry)->(!Eof()) .And. (cAliasQry)->(!Bof())
         cLastSeq := (cAliasQry)->LASTSEQ
      EndIf
      (cAliasQry)->(DBCloseArea())
      If( nOldArea > 0 , DbSelectArea(nOldArea) , ) 
      
   EndIf

   cLastSeq := Soma1(cLastSeq) 
   oBufSeqEK:Set(cChaveHash, cLastSeq)

Return cLastSeq

/*---------------------------------------------------------------------*
 | Func:  GetFormPOUI                                                  |
 | Autor: Nilson César                                                 |
 | Data:  29/01/2021                                                   |
 | Desc:  Cria uma instância de tela baseado em componentes do PO-UI no|
 |        objeto passado como parâmetro, utilizando as definições de   |
 |        campos contidas no .json do formulário LPCO informado na tela|
 |        de manutenção.                                               |
 | Obs.:  /                                                            |
 *---------------------------------------------------------------------*/
Static Function GetFormPOUI(oPanel,oView, nOpc)

Local cKeyForm
Local oDataForm
Local cOrgAnu   := ""
Local cFormLPCO := ""
local lActivate := .F.
local lRet := .F.

if nOpc == 1 .and. (!IsMemVar("oPOUI") .or. oPOUI == nil) // activate
   oPOUI := EasyPOUI():New(oPanel)
   lActivate := .T.
elseif nOpc == 3 // refresh
   aSize(oPOUI:oForm['listFields'], 0 )
   oPOUI:oForm['listFields'] := {}
elseif nOpc == 2 // deactivate
   oPOUI:Destroy()
   fwFreeObj(oPOUI)
EndIf

if nOpc == 1 .or. nOpc == 3
   cOrgAnu := oView:GetModel():GetModel("EKOMASTER"):GetValue("EKO_ORGANU")
   cFormLPCO := oView:GetModel():GetModel("EKOMASTER"):GetValue("EKO_FRMLPC")
   oPOUI:oEasyJS:SetTimeOut(10)
   If !lActivate .or. oPOUI:Activate()

      // Solução temporária para pegar o tema atual do protheus e setar no POUI
      oPOUI:oEasyJS:SetTheme("LPCO")

      If !Empty( cOrgAnu ) .And. !Empty( cFormLPCO )

         cKeyForm := oView:GetModel():GetModel("EKOMASTER"):GetValue("EKO_ORGANU") + oView:GetModel():GetModel("EKOMASTER"):GetValue("EKO_FRMLPC")
         oPOUI:ClearValidData()
         SetCapaLPCO(oPOUI,cKeyForm)
         // Função para pegar a NCM quando for catálogo de produtos
         oPOUI:oEasyJS:runJS("AppComponent.getNcm = function getNcm() {return runAdvpl('JsSendNcm(args[1])', this.catalogo)}")
         // Função para pegar os campos do formulário
         oPOUI:oEasyJS:runJS("AppComponent.getJsonCamposNCM = function getJsonCamposNCM() {return runAdvpl('JSsendEKM(oPOUI, args[1], args[2])', this.ncmSelected, this.catalogo)}")
         // Função para pegar a descrição da NCM
         oPOUI:oEasyJS:runJS("AppComponent.getDescNCM = function getDescNCM() {return runAdvpl('JsSendDescNcm(args[1])', this.ncmSelected)}")
         // Função para deletar do objeto do POUI no protheus quando uma aba for excluída
         oPOUI:oEasyJS:runJS("AppComponent.deleteTabProtheus = function deleteTabProtheus() {return runAdvpl('ExcNcmPOUI(args[1])', this.activeTab)}")
         // Função para incluir ou retirar campos da lista de campos obrigatorios na validacao das operações de gravação.
         oPOUI:oEasyJS:runJS("AppComponent.setCampoObrigatorioProtheus = function setCampoObrigatorioProtheus() {return runAdvpl('setCpObrig(oPOUI, args[1], args[2], args[3], args[4])', this.operacao, this.origemCampo, this.campoObrig, this.ncmItem)}")

         If oView:GetModel():GetOperation() <> MODEL_OPERATION_INSERT //Se não for inclusão, monta os dados dos itens (ncm) que possuem registro na EKP
            ItensLPCO(oPOUI, oView, oView:GetModel():GetModel("EKOMASTER"):GetValue("EKO_ID"), oView:GetModel():GetModel("EKOMASTER"):GetValue("EKO_VERSAO"))
         EndIf
         SetDataLPCO(oPOUI,cKeyForm)

         oPOUI:oEasyJS:runJSsync('AppComponent.sendAlertExibe("' + STR0031 + '",true); retAdvpl("ok")',{|x| lRet := alltrim(upper(x)) == "OK"}) // 'Carregando formulário'
         oPOUI:oEasyJS:runJS('AppComponent.loadMasterByConsole('+oPOUI:oForm:ToJSON()+'); AppComponent.sendAlertEsconde(); retAdvpl("ok")',{|x| lRet := alltrim(upper(x)) == "OK"})
         oPOUI:oEasyJS:runJSsync('AppComponent.loadItensNCM('+getNcmItem(oPOUI, oView:GetModel():GetModel("EKOMASTER"):GetValue("EKO_ID"), oView:GetModel():GetModel("EKOMASTER"):GetValue("EKO_VERSAO"))+'); retAdvpl("ok")',{|x| lRet := alltrim(upper(x)) == "OK"})
         // Bloco de execução específico para a automação de testes Protheus.
         If(EXISTBLOCK("EASYPOUI") .And. FindFunction('GetObjAutt') .And. ValType( oEasyAutTt := GetObjAutt() ) == "O" .And. ( oEasyAutTt:lRecord .Or. oEasyAutTt:lExecute ), EXECBLOCK("EASYPOUI",.F.,.F.,{"ACTIVATE",Self}), )  

         oDataForm := oPOUI:GetData()
         cHashPOUI := MD5( oDataForm:ToJSON() )

      Else

         oPOUI:oEasyJS:runJS('AppComponent.sendAlertExibe("' + STR0032 + '",false); retAdvpl("ok")',{|| lRet := .T.}) // 'Aguard. seleção do formulário'

      EndIf

   endif

endif

return

/*---------------------------------------------------------------------*
 | Func:  GetJsonLPCO                                                  |
 | Autor: Nilson César                                                 |
 | Data:  29/01/2021                                                   |
 | Desc:  Cria uma instância de tela baseado em componentes do PO-UI no|
 |        objeto passado como parâmetro, utilizando as definições de   |
 |        campos contidas no .json do formulário LPCO cadastrado no    |
 |         sistema e passado como parâmetro                            |
 | Obs.:  /                                                            |
 *---------------------------------------------------------------------*/
Static Function GetJsonLPCO(cChaveFrm)

Local cTextJson
Local oJson := Nil

EKL->(DbSetOrder(1))
If EKL->(DbSeek(xFilial("EKL")+cChaveFrm))
   cTextJson := EKL->EKL_FORMJS
   oJson := JsonObject():New()
   If ValType( ret := oJson:FromJson(cTextJson) ) == "C"
      oJson := Nil
   EndIf
EndIf

Return oJson

/*---------------------------------------------------------------------*
 | Func:  SetCapaLPCO                                                  |
 | Autor: Nilson César                                                 |
 | Data:  29/01/2021                                                   |
 | Desc:  Popula o json do PO-UI atribuindo aos campos as definições   |
 |        conforme os atributos dos campos do json oficial do LPCO dis-|
 |        ponibilizado pelo Portal único siscomex e carregado no cadas-|
 |        tro do sistema.                                              |
 | Obs.:  /                                                            |
 *---------------------------------------------------------------------*/
Static Function SetCapaLPCO(oPOUI,cKeyForm)

Local oJsonFRM, oCampo
Local i,j
Local oView := FWViewActive()
Local lComposto := .F.
Local nOrder := 0
Local cDivider:= ""
Local oDePara := DeParaPUPOUI()
Local oCondicao := jSonObject():New()
Local aCompostos := jsonObject():New()
Local oCampoUN
Local lDisabled := oView:GetModel():GetOperation() == MODEL_OPERATION_DELETE .Or. oView:GetModel():GetOperation() == MODEL_OPERATION_VIEW

oJsonFRM := GetJsonLPCO(cKeyForm)
aCompostos['listFieldsItens'] := {}

Begin Sequence

   If oJsonFRM:hasProperty('exigeNumeroLI') .And. oJsonFRM['exigeNumeroLI']
      oCampo := JsonObject():New()
      oCampo:FromJSON(getNumLI(++nOrder, oJsonFRM['modelo']['nome'], lDisabled)) //Adiciona um campo para que o numero da LI a ser enviada para o formulario seja informado
      oPOUI:SetField(oCampo)
      FreeObj(oCampo)
   EndIf 

   For i :=1 To Len(oJsonFRM["listaCamposFormulario"])
      oCampo := JsonObject():New()
      nOrder++
      lComposto := .F.
      cDivider := "Dados Gerais"
      cargaCpoPO(@oCampo, oJsonFRM["listaCamposFormulario"][i], i == 1, @lComposto, oView, oDePara, nOrder, @cDivider, oPOUI, , , oCondicao)
      If oCampo['propertyBackup'] == "QTDE_COMERCIALIZADA" .Or. oCampo['propertyBackup'] == "QTDE_ESTATISTICA"
         oCampoUN := JsonObject():New()
         oCampoUN:FromJson(getJsonUN(oCampo['propertyBackup'], ++nOrder, lDisabled, oCampo['origem']))
         If oCampo:hasProperty('unidadeMedida') .And.!Empty(oCampo['unidadeMedida'])
            oCampoUN['disabled'] := .T.
            oCampoUN['value'] := oCampo['unidadeMedida']
         EndIf
      EndIf
      // Se não for composto, adiciona o campo no POUI, caso contrário chama a função trataComposto
      IIF(!lComposto, (oPOUI:SetField(oCampo), IF(oCampoUN <> nil, oPOUI:SetField(oCampoUN),)), nOrder := trataComposto(oJsonFRM["listaCamposFormulario"][i]["subatributos"], oView, oDePara, nOrder - 1, cDivider, oPOUI, oCondicao, @aCompostos))

      FreeObj(oCampo)
      freeObj(oCampoUN)
   Next i
   
   //Adiciona ao objeto principal os atributos compostos, para que sejam os ultimos campos a serem exibidos
   If Len(aCompostos['listFieldsItens']) > 0
      For i:=1 To Len(aCompostos['listFieldsItens'])
         aCompostos['listFieldsItens'][i]['order'] := nOrder++
         oPOUI:SetField(aCompostos['listFieldsItens'][i])
      Next i
   EndIf
   //Seta a condição para os campos que possuem condição
   setCondicao(oPOUI:GetField(), oCondicao)
   FreeObj(oCondicao)

   // Verifica se exige o catálogo de produtos
   If oJsonFRM["modelo"]['requerCatalogoProduto']
      oCampo  := JsonObject():New()
      nOrder++
      oCampo['property']       :=  "listaNcm"
      oCampo['label'   ]       :=  "Catálogo de Produtos"
      oCampo['type']           :=  "string"
      oCampo['divider']        :=  "Itens do LPCO"
      oCampo['order']          :=  nOrder
      //oCampo['required']      :=  .T.
      oCampo['optional']       := .F.
      oCampo['gridColumns']    := 3
      oCampo['gridSmColumns']  := 6
      oCampo['optionsMulti']   := .F.
      oCampo['maxLength']      := 15
      // oCampo['errorMessage']   := "NCM inválido."
      // oCampo['help']           := "Informe o NCM do produto."
      If oView:GetModel():GetOperation() == MODEL_OPERATION_DELETE .Or. oView:GetModel():GetOperation() == MODEL_OPERATION_VIEW
         oCampo["disabled"] := .T.
      EndIf
      // Passando a consulta padrão com o filtro
      oPOUI:SetF3Filter(AvKey("CPLPCO","XB_ALIAS"), oCampo, "EKD.EKD_MODALI = '1' AND (EKD.EKD_STATUS = '1' OR EKD.EKD_STATUS = '6') AND EKD_IDPORT <> ' ' ")
      oPOUI:SetField(oCampo)
      FreeObj(oCampo)
   // Trata se existe listaNcm (dominioNcm) no json do LPCO. Caso exista, liste todas as NCMs desta lista
   ElseIf oJsonFRM["listaNcm"] != Nil .And. Len(oJsonFRM["listaNcm"]["dominioNcm"]) > 0
      oCampo  := JsonObject():New()
      nOrder++
      oCampo['property']      :=  "listaNcm"
      oCampo['label'   ]      :=  "NCM"
      oCampo['type']          :=  "LISTA"
      oCampo['divider']       :=  "Itens do LPCO"
      oCampo['order']         :=  nOrder
      //oCampo['required']      :=  .T.
      oCampo['optional']      :=  .T.
      oCampo['gridColumns']   := IIF(Len(oJsonFRM["listaNcm"]["dominioNcm"]) > 3, 2, 4) // Caso tenha mais que 3 campos, deixa 2 colunas, senão 4 colunas de tamanho
      oCampo['gridSmColumns'] := 6
      oCampo['options']       := {}
      ASort(oJsonFRM["listaNcm"]["dominioNcm"])
      For j:=1 To Len(oJsonFRM["listaNcm"]["dominioNcm"])
         Aadd(oCampo['options'],JsonObject():new())
         nPos := Len(oCampo['options'])
         oCampo['options'][nPos]['label' ] := Transform(oJsonFRM["listaNcm"]["dominioNcm"][j], '@R 9999.99.99')
         oCampo['options'][nPos]['value' ] := j
      Next j 
      oCampo['optionsMulti']  := .F.
      oCampo['maxLength']     := 10
      If oView:GetModel():GetOperation() == MODEL_OPERATION_DELETE .Or. oView:GetModel():GetOperation() == MODEL_OPERATION_VIEW
         oCampo["disabled"] := .T.
      EndIf
      oPOUI:SetField(oCampo)
      FreeObj(oCampo)
   Else //Não tem a lista de NCMs no Json, entao deve disponibilizar um campo com F3 para o cadastro de NCM
      oCampo  := JsonObject():New()
      nOrder++
      oCampo['property']       :=  "listaNcm"
      oCampo['label'   ]       :=  "NCM"
      oCampo['type']           :=  "string"
      oCampo['divider']        :=  "Itens do LPCO"
      oCampo['order']          :=  nOrder
      //oCampo['required']      :=  .T.
      oCampo['optional']       :=  .F.
      oCampo['gridColumns']    := 2
      oCampo['gridSmColumns']  := 6
      oCampo['optionsMulti']   := .F.
      oCampo['mask']           := "9999.99.99"
      oCampo['maskFormatModel']:= .T.
      oCampo['maxLength']      := 10
      oCampo['errorMessage']   := "NCM inválido."
      oCampo['help']           := "Informe a NCM do produto."
      If oView:GetModel():GetOperation() == MODEL_OPERATION_DELETE .Or. oView:GetModel():GetOperation() == MODEL_OPERATION_VIEW
         oCampo["disabled"] := .T.
      EndIf
      oPOUI:SetSXBF3(AvKey("SYD","XB_ALIAS"),oCampo)
      oPOUI:SetField(oCampo)
      FreeObj(oCampo)
   EndIf

End Sequence

FreeObj(oDePara)

return oPOUI

Static Function cargaCpoPO(oCampo, oJsonCampo, lDivider, lComposto, oView, oDePara, nOrder, cDivider, oPOUI, cNCM, cOrigem, oCondicao)
Local j
Local cTypeForm
Default cNCM := ""
Default cOrigem := ""

   // Está sendo acrescentado o código da NCM no nome da propriedade pois há uns componentes com comportamento estranho quando possuem o mesmo nome mas com opções diferentes. Dessa forma, mantém-se o mesmo comportamento de cade NCM, evitando variações. 
   oCampo['property']      :=  IIF(Empty(cNCM), oJsonCampo["codigo"], cNCM + '-' + oJsonCampo["codigo"])
   oCampo['propertyBackup']:=  oJsonCampo["codigo"] // Criado para não ter que realizar SubsStr depois para acessar o conteúdo original
   oCampo['label'   ]      :=  oJsonCampo["nome"  ]
   oCampo['additionalHelpTooltip'] := oCampo['propertyBackup']
   cTypeForm := oJsonCampo["tipo"]
   If lDivider .Or. cTypeForm == "ATRIBUTO_COMPOSTO" //Adiciona um título para os dados gerais (Divider)
      oCampo['divider'] := cDivider
   EndIf
   oCampo['type']          :=  getTypeCpo(oDePara, oJsonCampo)
   If cTypeForm == 'LISTA'
      oCampo['options'] := {}
      For j:=1 To Len(oJsonCampo["validacao"]["dominios"])
         Aadd(oCampo['options'],JsonObject():new())
         nPos := Len(oCampo['options'])
         oCampo['options'][nPos]['label' ] := oJsonCampo["validacao"]["dominios"][j]['descricao'] 
         oCampo['options'][nPos]['value' ] := oJsonCampo["validacao"]["dominios"][j]['id'       ]
      Next j 
      oCampo['optionsMulti'] := oJsonCampo["validacao"]["permiteMultiplosValores"]

   ElseIf cTypeForm == "ATRIBUTO_COMPOSTO"
      lComposto := .T.
      cDivider := oJsonCampo["nome"  ]
   Else
      If oCampo['type'] == "boolean"
         oCampo['booleanFalse'] := "Não"
         oCampo['booleanTrue']  := "Sim"
      EndIf
   EndIf
   oCampo['order']         :=  nOrder
   oCampo['required']      :=  oJsonCampo["validacao"]["obrigatorio"]
   oCampo['showRequired']  :=  oCampo['required']
   oCampo['optional']      :=  !oJsonCampo["validacao"]["obrigatorio"]
   oCampo['origem']        :=  cOrigem
   oCampo['maxLength']     :=  oJsonCampo["validacao"]["tamanhoMaximo"]
   oCampo['mask']          :=  oJsonCampo["validacao"]["mascara"]
   oCampo['gridColumns']   :=  6
   oCampo['gridSmColumns'] :=  12
   oCampo['condicaoPreenchimento'] := oJsonCampo["condicaoPreenchimento"] //Condição para preenchimento do campo
   oCampo['codigoAtributoPai']     := oJsonCampo["codigoAtributoPai"] //Atributo pai a ser verificado para preenchimento do campo
   //Se possuir condicao de preenchimento, esconde o campo para ser apresentado somente quando a condição for verdadeira
   If oCampo['condicaoPreenchimento'] != Nil 
      setCondAtt(oCondicao, oCampo['codigoAtributoPai'], oCampo['condicaoPreenchimento'], oCampo['property'])
      oCampo['visible'] := .F.
   Else
      oCampo['visible'] := .T.
   EndIf

   // Tratamentos condicionais que serão ajustados no próximo release - WorkItem 1073965
   If cTypeForm == "IMPORTACAO_TERCEIROS"
      oCampo['options'] := {}
      Aadd(oCampo['options'], JsonObject():new())
      oCampo['options'][1]['label' ] := " 0 - Importação Direta"
      oCampo['options'][1]['value' ] := "0"
   ElseIf cTypeForm == "FABRICANTE" .Or. cTypeForm == "OPERADOR_ESTRANGEIRO"
      oCampo['visible'] := .F.
   EndIf

   // Caso o campo seja obrigatório, será adicionado no objeto da classe POUI para futura validação
   If oJsonCampo["validacao"]["obrigatorio"] .And. oCampo['type'] != "boolean" .And. !lComposto .And. oCampo['visible']
      oPOUI:SetObrig(oJsonCampo["codigo"], cNCM, cOrigem)
   EndIf
   If oJsonCampo["tipo"] == 'VALOR_MONETARIO'
      oCampo['decimalsLength'] := oJsonCampo["validacao"]["qtdCasasDecimais"]
   EndIf

   If oJsonCampo["tipo"] == "DATA"
      oCampo["format"]     := "dd/mm/yyyy"
   EndIf

   If oView:GetModel():GetOperation() == MODEL_OPERATION_DELETE .Or. oView:GetModel():GetOperation() == MODEL_OPERATION_VIEW
      oCampo["disabled"] := .T.
   EndIf

   If oJsonCampo:hasProperty('unidadeMedida')
      oCampo['unidadeMedida'] := oJsonCampo['unidadeMedida']
   EndIf

Return

Static Function setCondAtt(oCondicao, cAttPai, cCondicao, cFilho)
If oCondicao:HasProperty(cAttPai)
   aAdd(oCondicao[cAttPai],{{cFilho, cCondicao}})
Else
   oCondicao[cAttPai] := {}
   aAdd(oCondicao[cAttPai],{{cFilho, cCondicao}})
EndIf
Return

Static Function setCondicao(oCampos, oCondicao)
Local aNames := oCondicao:getNames()
Local nI
Local nPos

For nI := 1 To Len(aNames)
   Do Case
      Case oCampos:hasProperty('listFieldsItens')
         If (nPos := aScan(oCampos['listFieldsItens'], {|x| x['propertyBackup'] == aNames[nI]})) > 0
            oCampos['listFieldsItens'][nPos]['listaCondicaoFilhos'] := aClone(oCondicao[aNames[nI]])
         EndIf
      
      Case oCampos:hasProperty('listFields')
         If (nPos := aScan(oCampos['listFields'], {|x| x['property'] == aNames[nI]})) > 0
            oCampos['listFields'][nPos]['listaCondicaoFilhos'] := aClone(oCondicao[aNames[nI]])
         EndIf
   EndCase
Next

Return

/*---------------------------------------------------------------------*
 | Func:  SetDataLPCO                                                  |
 | Autor: Nilson César                                                 |
 | Data:  05/02/2021                                                   |
 | Desc:  Carrega nos campos do objeto PO-UI os dados salvo na base de |
 |        dados em manutenção de inclusão/alteração anterior           |
 | Obs.:  Implementado apenas o carregamento dos campos de capa do mo- |
 |        delo ('listaCamposFormulario')                               |
 *---------------------------------------------------------------------*/
Static Function SetDataLPCO(oPOUI,cKeyForm)
Local oView     := FWViewActive()
Local oMdlDtLPCO:= oView:GetModel():GetModel("EKPDETAIL")
Local lRegEKP   := oMdlDtLPCO:GetQtdLine() > 0 .And. oMdlDtLPCO:GetOperation() <> 3
Local oDePara   := JsonObject():New()
Local oCPNome   := JsonObject():New() //De/Para para a gravacao dos dados do catalogo
Local i, nPosField
Local oEKPItem

If lRegEKP
   oDePara:fromJSON('{"types": {"number": "Val(xRet)","currency": "Val(xRet)","string": "xRet","boolean": "xRet","date": "xRet" }}')
   oCPNome:fromJSON('{"PRODUTO": "EKD_COD_I","IDPORTAL": "EKD_IDPORT","VERSAO": "EKD_VATUAL", "CNPJ": "EKD_CNPJ", "SEQ_CAT": "EKD_VERSAO"}')
   For i := 1 To oMdlDtLPCO:GetQtdLine()
      oMdlDtLPCO:GoLine(i)

      //Atribuição dos valores de Capa
      Do Case
         Case Alltrim(oMdlDtLPCO:GetValue('EKP_IDCPOF')) == 'listaCamposFormulario'
            nPosField := asCan(oPOUI:oForm['listFields'], {|x| x['property'] == Alltrim(oMdlDtLPCO:GetValue('EKP_CDCPOF')) })
            xRet := oMdlDtLPCO:GetValue('EKP_VLCPOF')
            If Valtype(oPOUI:oForm['listFields'][nPosField]['options']) == "A"         //Lista de valores
               xRet   := &(oDePara["types"]['string'])
               If oPOUI:oForm['listFields'][nPosField]['optionsMulti']
                  If Valtype(oPOUI:oForm['listFields'][nPosField]['value']) == 'A'
                     aAdd(oPOUI:oForm['listFields'][nPosField]['value'],xRet)
                  Else
                     oPOUI:oForm['listFields'][nPosField]['value'] := {xret}
                  EndIf
               Else
                  oPOUI:oForm['listFields'][nPosField]['value'] := xret
               EndIf
            ElseIf Valtype(oPOUI:oForm['listFields'][nPosField]['type']) == "C"                //Valores únicos
               xRet := &(oDePara["types"][oPOUI:oForm['listFields'][nPosField]['type']])
               oPOUI:oForm['listFields'][nPosField]['value'] := xRet 
            EndIf        
         
         Case Alltrim(oMdlDtLPCO:GetValue('EKP_IDCPOF')) == 'listaCamposNcm'
            xRet := oMdlDtLPCO:GetValue('EKP_VLCPOF')
            nItem := Val(oMdlDtLPCO:GetValue('EKP_SQCPOF'))
            oEKPItem := oPOUI:GetFieldItem(nItem)
            // Utiliza o propertyBackup para adquirir o atributo pois o property possui a NCM para evitar conflitos entre os componentes POUI
            nPosField := asCan(oEKPItem['listFieldsItens'], {|x| x['propertyBackup'] == Alltrim(oMdlDtLPCO:GetValue('EKP_CDCPOF')) .And. x['origem'] == 'listaCamposNcm' })
            If nPosField > 0
               // Validação do tipo do campo, fazendo uma conversão utilizando o oDePara
               If Valtype(oEKPItem['listFieldsItens'][nPosField]['options']) == "A" // Caso seja um array
                  xRet := &(oDePara["types"]['string'])
               Else
                  xRet := &(oDePara["types"][oEKPItem['listFieldsItens'][nPosField]['type']])
               EndIf
               // Atribuição do valor processado para o campo
               oEKPItem['listFieldsItens'][nPosField]['value'] := xRet
            EndIf
         Case Alltrim(oMdlDtLPCO:GetValue('EKP_IDCPOF')) == 'listaAtributosNcm'
            xRet := oMdlDtLPCO:GetValue('EKP_VLCPOF')
            nItem := Val(oMdlDtLPCO:GetValue('EKP_SQCPOF'))
            oEKPItem := oPOUI:GetFieldItem(nItem)
            // Utiliza o propertyBackup para adquirir o atributo pois o property possui a NCM para evitar conflitos entre os componentes POUI
            nPosField := asCan(oEKPItem['listFieldsItens'], {|x| x['propertyBackup'] == Alltrim(oMdlDtLPCO:GetValue('EKP_CDCPOF')) .And. x['origem'] == 'listaAtributosNcm' })
            If nPosField > 0
               // Validação do tipo do campo, fazendo uma conversão utilizando o oDePara
               If Valtype(oEKPItem['listFieldsItens'][nPosField]['options']) == "A"         //Lista de valores
                  xRet   := &(oDePara["types"]['string'])
               Else
                  xRet := &(oDePara["types"][oEKPItem['listFieldsItens'][nPosField]['type']])
               EndIf
               // Atribuição do valor processado para o campo
               oEKPItem['listFieldsItens'][nPosField]['value'] := xRet
            EndIf
         
         Case Alltrim(oMdlDtLPCO:GetValue('EKP_IDCPOF')) $ "PRODUTO|IDPORTAL|VERSAO"
            xRet := oMdlDtLPCO:GetValue('EKP_CDCPOF')
            nItem := Val(oMdlDtLPCO:GetValue('EKP_SQCPOF'))
            oEKPItem := oPOUI:GetFieldItem(nItem)
            
            nPosField := asCan(oEKPItem['listFieldsItens'], {|x| x['propertyBackup'] == oCPNome[Alltrim(oMdlDtLPCO:GetValue('EKP_IDCPOF'))] .And. x['origem'] == 'catalogo' })
            If nPosField > 0
               // Validação do tipo do campo, fazendo uma conversão utilizando o oDePara
               xRet := &(oDePara["types"][oEKPItem['listFieldsItens'][nPosField]['type']])
               // Atribuição do valor processado para o campo
               oEKPItem['listFieldsItens'][nPosField]['value'] := xRet
            EndIf

            If Alltrim(oMdlDtLPCO:GetValue('EKP_IDCPOF')) == "PRODUTO" //Quando for o codigo do catalogo, posiciona a tabela para pegar os dados de EK9_DESC_I e EK9_DSCCOM
               EK9->(DbSetOrder(1))
               If EK9->(DbSeek(xFilial("EK9") + AvKey(xRet, "EK9_COD_I"))) //Posiciona na tabela EK9 para pegar os dados de EK9_DESC_I e EK9_DSCCOM
                  nPosField := asCan(oEKPItem['listFieldsItens'], {|x| x['propertyBackup'] == "EK9_DESC_I" .And. x['origem'] == 'catalogo' })
                  If nPosField > 0
                     oEKPItem['listFieldsItens'][nPosField]['value'] := EK9->EK9_DESC_I
                  EndIf

                  nPosField := asCan(oEKPItem['listFieldsItens'], {|x| x['propertyBackup'] == "EK9_DSCCOM" .And. x['origem'] == 'catalogo' })
                  If nPosField > 0
                     oEKPItem['listFieldsItens'][nPosField]['value'] := EK9->EK9_DSCCOM
                  EndIf
               EndIf
            EndIf

      EndCase
   Next i
EndIf

FreeObj(oDePara)
FreeObj(oCPNome)

// Tratativa para converter os valores booleanos do Protheus para os valores booleanos do Angular
cPOUIJson := StrTran(oPOUI:oForm:ToJson(), '".T."', 'true')
cPOUIJson := StrTran(cPOUIJson, '".F."', 'false')
oPOUI:oForm:FromJson(cPOUIJson)

// Mesma tratativa porém para os itens
For i := 1 to Len(oPOUI:oFormItem)
   cPOUIJson := StrTran(oPOUI:oFormItem[i]:ToJson(), '".T."', 'true')
   cPOUIJson := StrTran( cPOUIJson, '".F."', 'false')
   oPOUI:oFormItem[i]:FromJson(cPOUIJson)
Next i

oView:GetModel():lModify := .T.
oMdlDtLPCO:lUpdateLine := .T.

Return oPOUI

/*---------------------------------------------------------------------*
 | Func:  trataComposto                                                |
 | Autor: Nicolas Castellani Brisque                                   |
 | Data:  09/01/2024                                                   |
 | Desc:  Trata o atributo composto para que ocorra recursividade caso |
 |        necessário.                                                  |
 | Obs.:  /                                                            |
 *---------------------------------------------------------------------*/
Static Function trataComposto(oJsonForm, oView, oDePara, nOrder, cDivider, oPOUI, oCondicao, aCampos, cNCM, cOrigem)
Local oCampo
Local i
Local lComposto
Local oCampoUN
Local lDisabled := oView:GetModel():GetOperation() == MODEL_OPERATION_DELETE .Or. oView:GetModel():GetOperation() == MODEL_OPERATION_VIEW
//Local lCapa
Default aCampos := JsonObject():New()

// Verifica se é a capa ou um item
//lCapa := !aCampos:HasProperty('listFieldsItens')

   For i := 1 To Len(oJsonForm)
      oCampo := JsonObject():New()
      nOrder++
      lComposto := .F.
      //If lCapa
         //cargaCpoPO(@oCampo, oJsonForm[i], i == 1, @lComposto, oView, oDePara, nOrder, @cDivider, oPOUI, , , @oCondicao)
         //If !lComposto
            //oPOUI:SetField(oCampo)
         //Else
            //nOrder := trataComposto(oJsonForm[i]["subatributos"], oView, oDePara, nOrder - 1, cDivider, oPOUI, oCondicao, aCampos)
         //EndIf
      //Else
         cargaCpoPO(@oCampo, oJsonForm[i], i == 1, @lComposto, oView, oDePara, nOrder, @cDivider, oPOUI, cNCM, cOrigem, @oCondicao)
         If oCampo['propertyBackup'] == "QTDE_COMERCIALIZADA" .Or. oCampo['propertyBackup'] == "QTDE_ESTATISTICA"
            oCampoUN := JsonObject():New()
            oCampoUN:FromJson(getJsonUN(oCampo['propertyBackup'], ++nOrder, lDisabled, oCampo['origem'], cNCM))
            If oCampo:hasProperty('unidadeMedida') .And.!Empty(oCampo['unidadeMedida'])
               oCampoUN['disabled'] := .T.
               oCampoUN['value'] := oCampo['unidadeMedida']
            EndIf
         EndIf
         If !lComposto
            AAdd(aCampos['listFieldsItens'], oCampo)
            If oCampoUN <> nil
               AAdd(aCampos['listFieldsItens'], oCampoUN)
            EndIf
         Else
            nOrder := trataComposto(oJsonForm[i]["subatributos"], oView, oDePara, nOrder - 1, cDivider, oPOUI, oCondicao, aCampos, cNCM, cOrigem)
         EndIf
      //EndIf
      FreeObj(oCampo)
      freeObj(oCampoUN)
   Next i

Return nOrder

Static Function getNumLI(nOrder, cDivider, lDisable)
Local cCampoLI := ""
 
cCampoLI := '{ ' +;
            '	"property": "EXIGENUMEROLI", ' +;
            '	"propertyBackup": "EXIGENUMEROLI", ' +;
            '	"label": "Número da LI", ' +;
            '	"type": "string", ' +;
            '	"order": '+ cValToChar(nOrder) + ', ' +;
            If(!Empty(cDivider),'  "divider": "' + cDivider + '", ','') +;
            '	"required": true, ' +;
            '	"showRequired": true, ' +;
            '	"optional": false, ' +;
            '	"origem": "", ' +;
            '	"maxLength": 12, ' +;
            '	"mask": "99/9999999-9", ' +;
            '	"gridColumns": 6, ' +;
            '	"gridSmColumns": 12, ' +;
            '	"condicaoPreenchimento": null, ' +;
            '	"codigoAtributoPai": null, ' +;
            '	"visible": true , ' +;
            If (lDisable, '  "disabled": true, ', '') +;
            '  "help": "Formulário exige Número da LI." ' +;
            '}'

Return cCampoLI

Static Function getJsonUN(cProperty, nOrder, lDisabled, cOrigem, cNCM)
Local cCampoUN := ""
Local cOrder := cValToChar(nOrder)
Local cLabel

Default cNCM := ""

If (!Empty(cNCM),cNcm := cNcm+'-',"")
cLabel := IIF(cProperty == "QTDE_COMERCIALIZADA", "Comercializada", "Estatística")
cCampoUN := '{ ' +;
            '	"property": "' + cNcm + cProperty + '_UNIDADEMEDIDA", ' +;
            '	"propertyBackup": "' +  cProperty + '_UNIDADEMEDIDA", ' +;
            '	"label": "Unidade de Medida ' + cLabel + '", ' +;
            '	"type": "string", ' +;
            '	"order": '+ cOrder + ', ' +;
            '	"required": true, ' +;
            '	"showRequired": true, ' +;
            '	"optional": false, ' +;
            '	"origem": "' + cOrigem + '", ' +;
            '	"maxLength": 60, ' +;
            '	"gridColumns": 6, ' +;
            '	"gridSmColumns": 12, ' +;
            '	"condicaoPreenchimento": null, ' +;
            '	"codigoAtributoPai": null, ' +;
            '	"visible": true, '  +;
            If (lDisabled, '  "disabled": true ', '  "disabled": false ') +;
            '}'

Return cCampoUN

/*---------------------------------------------------------------------*
 | Func:  ItensLPCO                                                    |
 | Autor: Tiago Tudisco                                                |
 | Data:  12/12/2023                                                   |
 | Desc:  Monta os itens do LPCO, com base nos dados de NCM gravados na|
 |        tabela EKP com o identificador listaNcm                      |
 | Obs.:  /                                                            |
 *---------------------------------------------------------------------*/
Static Function ItensLPCO(oPOUI, oView, cID, cVersao)
//Local oMdlDtLPCO:= oView:GetModel():GetModel("EKPDETAIL")
Local i
Local aItemNCM := {}

aItemNCM := getItemNCM(cID, cVersao)
//oMdlDtLPCO:SeekLine({{"EKP_ID", cID},{"EKP_VERSAO", cVersao},{"EKP_IDCPOF","listaNcm"}})
If !Empty(aItemNCM)
   For i := 1 To Len(aItemNCM)
      JSsendEKM(oPOUI, aItemNCM[i][1], aItemNCM[i][2])
   Next
EndIf

Return

Static Function getItemNCM(cID, cVersao)
Local aRet     := {}
Local cQuery   := ""
Local cAliasEKP:= GetNextAlias()
Local oQry

cQuery := " SELECT EKP_IDCPOF, EKP_SQCPOF, EKP_CDCPOF, COALESCE((SELECT EKP_CDCPOF "
cQuery += " 											FROM  " + RetSqlName("EKP") + " PROD "
cQuery += " 											WHERE  PROD.EKP_FILIAL = EKP.EKP_FILIAL "
cQuery += " 												AND PROD.EKP_ID     = EKP.EKP_ID "
cQuery += " 												AND PROD.EKP_VERSAO = EKP.EKP_VERSAO "
cQuery += " 												AND PROD.EKP_SQCPOF = EKP.EKP_SQCPOF "
cQuery += " 												AND PROD.EKP_IDCPOF = 'PRODUTO' "
cQuery += " 												AND PROD.D_E_L_E_T_ =' '),'') AS EKP_PRODUTO "
cQuery += " FROM  " + RetSqlName("EKP") + " EKP "
cQuery += " WHERE  EKP.EKP_FILIAL    = ? "
cQuery += "     AND EKP.EKP_ID       = ? "
cQuery += "     AND EKP.EKP_VERSAO   = ? "
cQuery += "     AND EKP.EKP_IDCPOF   = 'NCM' "
cQuery += "     AND EKP.D_E_L_E_T_=' ' "
cQuery += " ORDER BY EKP.EKP_SQCPOF, EKP.EKP_IDCPOF "

oQry := FWPreparedStatement():New(cQuery)

oQry:SetString(1, xFilial("EKP"))
oQry:SetString(2, cID)
oQry:SetString(3, cVersao)

cQuery := oQry:GetFixQuery()
MPSysOpenQuery(cQuery, cAliasEKP)

While (cAliasEKP)->(!Eof())
   aAdd(aRet, {Alltrim((cAliasEKP)->EKP_CDCPOF), Alltrim((cAliasEKP)->EKP_PRODUTO)})
   (cAliasEKP)->(dbSkip())
End

(cAliasEKP)->(dbCloseArea())
fwFreeObj(oQry)

Return aClone(aRet)
/*---------------------------------------------------------------------*
 | Func:  GrvModPOUI                                                   |
 | Autor: Nilson César                                                 |
 | Data:  29/01/2021                                                   |
 | Desc:  Grava o modelo MVC conforme os campos carregados no formulá- |
 |        rio PO-UI.                                                   |
 | Obs.:  /                                                            |
 *---------------------------------------------------------------------*/
Static Function GrvModPOUI()

Local jDataEKP := oPOUI:GetData()
Local oView    := FWViewActive()
Local oMdl     := FWModelActive()
Local oMdl_EKO := oMdl:GetModel("EKOMASTER")
Local oMdl_EKP := oMdl:GetModel("EKPDETAIL")
Local cKeyForm := oView:GetModel():GetModel("EKOMASTER"):GetValue("EKO_ORGANU") + oView:GetModel():GetModel("EKOMASTER"):GetValue("EKO_FRMLPC")
Local oJsonFRM := GetJsonLPCO(cKeyForm)
Local aNames   := {}
Local nLinha,i,j
Local oCPNome := JsonObject():New() //De/Para para a gravacao dos dados do catalogo
local xValue 
local oCampoAdd
//Limpa todas as linhas do model 
For nLinha:=1 To oMdl_EKP:Length()
   oMdl_EKP:GoLine(nLinha)
   oMdl_EKP:DeleteLine()
Next nLinha

If oJsonFRM:hasProperty('exigeNumeroLI') .And. oJsonFRM['exigeNumeroLI']
   oCampoAdd := JsonObject():New()
   oCampoAdd['codigo'] := "EXIGENUMEROLI"
   aAdd(oJsonFRM["listaCamposFormulario"], oCampoAdd)
   FreeObj(oCampoAdd)
EndIf

If jDataEKP:hasProperty('QTDE_ESTATISTICA_UNIDADEMEDIDA')
   oCampoAdd := JsonObject():New()
   oCampoAdd['codigo'] := "QTDE_ESTATISTICA_UNIDADEMEDIDA"
   aAdd(oJsonFRM["listaCamposFormulario"], oCampoAdd)
   FreeObj(oCampoAdd)
EndIf
If jDataEKP:hasProperty('QTDE_COMERCIALIZADA_UNIDADEMEDIDA')
   oCampoAdd := JsonObject():New()
   oCampoAdd['codigo'] := "QTDE_COMERCIALIZADA_UNIDADEMEDIDA"
   aAdd(oJsonFRM["listaCamposFormulario"], oCampoAdd)
   FreeObj(oCampoAdd)
EndIf

//Preecnhe com os dados do Json
For i:=1 To Len(oJsonFRM["listaCamposFormulario"])
   If ValType( jDataEKP[oJsonFRM["listaCamposFormulario"][i]["codigo"]] ) == "A" // Campos tipo combobox (lista) com múltipla seleção.
      For j:=1 To Len(jDataEKP[oJsonFRM["listaCamposFormulario"][i]["codigo"]])
         ForceAddLine(oMdl_EKP)
         oMdl_EKP:LoadValue( "EKP_FILIAL" , xFilial("EKP") )
         oMdl_EKP:LoadValue( "EKP_ID"     , oMdl_EKO:GetValue("EKO_ID" )     ) 
         oMdl_EKP:LoadValue( "EKP_VERSAO" , oMdl_EKO:GetValue("EKO_VERSAO" ) )
         oMdl_EKP:SetValue(  "EKP_IDCPOF" , "listaCamposFormulario" )
         oMdl_EKP:SetValue(  "EKP_CDCPOF" , oJsonFRM["listaCamposFormulario"][i]["codigo"] ) 
         oMdl_EKP:SetValue(  "EKP_VLCPOF" , cValToChar( jDataEKP[oJsonFRM["listaCamposFormulario"][i]["codigo"]][j] ) )        
      Next j
   ElseIf oJsonFRM["listaCamposFormulario"][i]["tipo"] == ATRIBUTO_COMPOSTO //"ATRIBUTO_COMPOSTO"
      For j:=1 To Len(oJsonFRM["listaCamposFormulario"][i]["subatributos"])
         ForceAddLine(oMdl_EKP)
         oMdl_EKP:LoadValue( "EKP_FILIAL" , xFilial("EKP") )
         oMdl_EKP:LoadValue( "EKP_ID"     , oMdl_EKO:GetValue("EKO_ID" )     ) 
         oMdl_EKP:LoadValue( "EKP_VERSAO" , oMdl_EKO:GetValue("EKO_VERSAO" ) )
         oMdl_EKP:SetValue(  "EKP_IDCPOF" , "listaCamposFormulario" )
         oMdl_EKP:SetValue(  "EKP_CDCPOF" , oJsonFRM["listaCamposFormulario"][i]["subatributos"][j]["codigo"] ) 
         xValue := cValToChar( jDataEKP[oJsonFRM["listaCamposFormulario"][i]["subatributos"][j]["codigo"]] )
         xValue := if(empty(xValue) .and. oJsonFRM["listaCamposFormulario"][i]["subatributos"][j]["tipo"] == "BOOLEANO", ".F.", xValue)
         oMdl_EKP:SetValue(  "EKP_VLCPOF" , xValue )
      Next j
   Else
      ForceAddLine(oMdl_EKP)
      oMdl_EKP:LoadValue( "EKP_FILIAL" , xFilial("EKP") )
      oMdl_EKP:LoadValue( "EKP_ID"     , oMdl_EKO:GetValue("EKO_ID" )     ) 
      oMdl_EKP:LoadValue( "EKP_VERSAO" , oMdl_EKO:GetValue("EKO_VERSAO" ) )
      oMdl_EKP:SetValue(  "EKP_IDCPOF" , "listaCamposFormulario" )
      oMdl_EKP:SetValue(  "EKP_CDCPOF" , oJsonFRM["listaCamposFormulario"][i]["codigo"] ) 
      xValue := cValToChar( jDataEKP[oJsonFRM["listaCamposFormulario"][i]["codigo"]] )
      xValue := if(empty(xValue) .and. oJsonFRM["listaCamposFormulario"][i]["tipo"] == "BOOLEANO", ".F.", xValue)
      oMdl_EKP:SetValue(  "EKP_VLCPOF" , xValue )
   EndIf
Next i

// Caso exista listaNcm (dominioNcm) no json do LPCO, preenche os campos
If !Empty(jDataEKP['LISTANCM']) .And. Len(jDataEKP['LISTANCM']) > 0
   oCPNome:fromJSON('{"EKD_COD_I": "PRODUTO","EKD_IDPORT": "IDPORTAL","EKD_VATUAL": "VERSAO", "EKD_CNPJ": "CNPJ", "EKD_VERSAO":"SEQ_CAT"}')
   For i:=1 To Len(jDataEKP['LISTANCM'])
      //Grava a NCM
      ForceAddLine(oMdl_EKP)
      oMdl_EKP:LoadValue( "EKP_FILIAL" , xFilial("EKP") )
      oMdl_EKP:LoadValue( "EKP_ID"     , oMdl_EKO:GetValue("EKO_ID" )     )
      oMdl_EKP:LoadValue( "EKP_VERSAO" , oMdl_EKO:GetValue("EKO_VERSAO" ) )
      oMdl_EKP:SetValue(  "EKP_IDCPOF" , "NCM" )
      oMdl_EKP:SetValue(  "EKP_SQCPOF" , StrZero(i, 3))
      oMdl_EKP:SetValue(  "EKP_CDCPOF" , jDataEKP['LISTANCM'][i]['ncm'])

      // Adquire os nomes da propriedade listaCamposCatalogo
      If jDataEKP['LISTANCM'][i]:hasProperty('listaCamposCatalogo')
         aNames := oCPNome:GetNames()
         For j := 1 To Len(aNames)
            ForceAddLine(oMdl_EKP)
            oMdl_EKP:LoadValue( "EKP_FILIAL" , xFilial("EKP") )
            oMdl_EKP:LoadValue( "EKP_ID"     , oMdl_EKO:GetValue("EKO_ID" )   ) 
            oMdl_EKP:LoadValue( "EKP_VERSAO" , oMdl_EKO:GetValue("EKO_VERSAO"))
            oMdl_EKP:SetValue(  "EKP_IDCPOF" , oCPNome[aNames[j]] )
            oMdl_EKP:SetValue(  "EKP_SQCPOF" , StrZero(i, 3))
            oMdl_EKP:SetValue(  "EKP_CDCPOF" , jDataEKP['LISTANCM'][i]['listaCamposCatalogo'][aNames[j]] ) 
         Next
      EndIf

      // Adquire os nomes da propriedade listaCamposNCM
      If jDataEKP['LISTANCM'][i]:hasProperty('listaCamposNcm')
         aNames := jDataEKP['LISTANCM'][i]['listaCamposNcm']:GetNames()
         For j := 1 To Len(aNames)
            ForceAddLine(oMdl_EKP)
            oMdl_EKP:LoadValue( "EKP_FILIAL" , xFilial("EKP") )
            oMdl_EKP:LoadValue( "EKP_ID"     , oMdl_EKO:GetValue("EKO_ID" )     ) 
            oMdl_EKP:LoadValue( "EKP_VERSAO" , oMdl_EKO:GetValue("EKO_VERSAO" ) )
            oMdl_EKP:SetValue(  "EKP_IDCPOF" , "listaCamposNcm" )
            oMdl_EKP:SetValue(  "EKP_SQCPOF" , StrZero(i, 3))
            oMdl_EKP:SetValue(  "EKP_CDCPOF" , aNames[j] ) 
            oMdl_EKP:SetValue(  "EKP_VLCPOF" , cValToChar( jDataEKP['LISTANCM'][i]['listaCamposNcm'][aNames[j]] ) )
         Next
      EndIf

      // Adquire os nomes da propriedade listaAtributosNCM
      If jDataEKP['LISTANCM'][i]:hasProperty('listaAtributosNcm')
         aNames := jDataEKP['LISTANCM'][i]['listaAtributosNcm']:GetNames()
         For j := 1 To Len(aNames)
            ForceAddLine(oMdl_EKP)
            oMdl_EKP:LoadValue( "EKP_FILIAL" , xFilial("EKP") )
            oMdl_EKP:LoadValue( "EKP_ID"     , oMdl_EKO:GetValue("EKO_ID" )     ) 
            oMdl_EKP:LoadValue( "EKP_VERSAO" , oMdl_EKO:GetValue("EKO_VERSAO" ) )
            oMdl_EKP:SetValue(  "EKP_IDCPOF" , "listaAtributosNcm" )
            oMdl_EKP:SetValue(  "EKP_SQCPOF" , StrZero(i, 3))
            oMdl_EKP:SetValue(  "EKP_CDCPOF" , aNames[j] ) 
            oMdl_EKP:SetValue(  "EKP_VLCPOF" , cValToChar( jDataEKP['LISTANCM'][i]['listaAtributosNcm'][aNames[j]] ) )
         Next
      EndIf
   Next i
EndIf
Return

/*---------------------------------------------------------------------*
 | Func:  ForceAddLine                                                 |
 | Autor: Nilson César                                                 |
 | Data:  29/01/2021                                                   |
 | Desc:  Força a inclusão de nova linha no modelo MVC                 |
 | Obs.:  /                                                            |
 *---------------------------------------------------------------------*/
Static Function ForceAddLine(oModelGrid)
Local lDel := .F.

If oModelGrid:Length() >= oModelGrid:AddLine()
   oModelGrid:GoLine(1)
   If !oModelGrid:IsDeleted()
      oModelGrid:DeleteLine()
      lDel := .T.
   EndIf
   oModelGrid:AddLine()
   oModelGrid:GoLine(1)
   If lDel
      oModelGrid:UnDeleteLine()
   EndIf
   oModelGrid:GoLine(oModelGrid:Length())
EndIf

Return .T.

/*---------------------------------------------------------------------*
 | Func:  LP401BTNOK                                                   |
 | Autor: Nilson César                                                 |
 | Data:  04/11/2020                                                   |
 | Desc:  Validação própria da rotina ao clicar no botão 'Confirmar'   |
 |        antes de commitar o modelo.                                  |
 | Obs.:  /                                                            |
 *---------------------------------------------------------------------*/
Function LP401BTNOK(cVar,oModel,cModelId)

Local lRet := .T.
Local cHashPOUIF := ""
Local oView := FWViewActive()
Local oMdl_EKO := oView:GetModel("EKOMASTER")
Local cNcmError := ""

If oView:GetModel():GetOperation() != MODEL_OPERATION_DELETE .And. oView:GetModel():GetOperation() != MODEL_OPERATION_VIEW
   Begin Sequence 

   oPOUI:oEasyJS:runJSsync('AppComponent.sendAlertExibe("' + STR0037 + '",true); retAdvpl("ok")') //"Validando dados do Formulário LPCO"
   If cVar == "VIEW"
      If isMemVar("oPOUI") .And. (cHashPOUIF := MD5( oPOUI:GetData():ToJSON() ) ) <> cHashPOUI 
         If !ValCposPOUI(oPOUI, @cNcmError)
            //MsgStop(STR0029, STR0012) //"Existem campos com valor inválido no formulário! Revise os campos destacados em vermelho!" // Aviso
            oModel:SetErrorMessage("","","","","OBRIGATORIO",STR0033, STR0034 + IIF(Empty(cNcmError), STR0035, STR0036 + cNcmError))//"Existem campos obrigatórios que não foram preenchidos!"####"Verifique os campos obrigatórios "###"do formulário."###"da NCM: "
            lRet := .F.
            Break
         Else
            oPOUI:oEasyJS:runJSsync('AppComponent.sendAlertExibe("' + STR0038 + '",true); retAdvpl("ok")') //"Gravando dados do Formulário LPCO"
            GrvModPOUI()
         EndIf
      Else
         If oView:GetModel():GetOperation() == MODEL_OPERATION_UPDATE .And. !oMdl_EKO:IsModified()
            //MsgInfo(STR0024, STR0012) //"Não foi detectada nenhuma alteração nos dados da LPCO, capa ou detalhes do formulário!" // Aviso
            oModel:SetErrorMessage("","","","","SEMALTERACAO", STR0039) //"Não foi detectada nenhuma alteração nos dados da LPCO, capa ou detalhes do formulário!"
            lRet := .F.
            Break
         EndIf
      EndIf

   ElseIf cVar == "MODEL"
      If oView:GetModel():GetOperation() == MODEL_OPERATION_INSERT
         If isMemVar("oPOUI")
            If !ValCposPOUI(oPOUI, @cNcmError)
               //MsgStop(STR0029, STR0012) //"Existem campos com valor inválido no formulário! Revise os campos destacados em vermelho!" // Aviso
               oModel:SetErrorMessage("","","","","OBRIGATORIO", STR0033, STR0034 + IIF(Empty(cNcmError), STR0035, STR0036 + cNcmError)) //"Existem campos obrigatórios que não foram preenchidos!"####"Verifique os campos obrigatórios "###"do formulário."###"da NCM: "
               lRet := .F.
               Break
            EndIf
         EndIf 
      EndIf
   EndIf

   End Sequence

   oPOUI:oEasyJS:runJS('AppComponent.sendAlertEsconde(); retAdvpl("ok")')

   If oView <> Nil
      oView:lModify 		   := .T.
      oView:oModel:lModify	:= .T.
   EndIf
EndIf
Return lRet

/*---------------------------------------------------------------------*
 | Func:  HasJsForm                                                    |
 | Autor: Nilson César                                                 |
 | Data:  04/11/2020                                                   |
 | Desc:  Validar se há modelo cadastrado para o formulário do órgão   |
 |        anuente informado e se o mesmo é válido para carregamento dos|
 |        campos no objeto PO-UI.                                      |
 | Obs.:  /                                                            |
 *---------------------------------------------------------------------*/
Static Function HasJsForm(cOrgAnu,cFormLPCO)
Local lRet      := .F.
Local oJsonForm
Local cChaveEKL := xFilial("EKL") + cOrgAnu + cFormLPCO

   If ( EKL->( xFilial("EKL") + EKL_CODIGO + EKL_CODFOR ) == cChaveEKL )  .Or. EKL->(DbSeek(xFilial("EKL") + cOrgAnu + cFormLPCO ))
      If !Empty(EKL->EKL_FORMJS)
         oJsonForm := JsonObject():New()
         xRet := oJsonForm:FromJson(EKL->EKL_FORMJS)
         If ValType(xRet) == "C"
            MsgStop(STR0026+STR0028) //"Não foi possível carregar o modelo deste formulário! " # "Verifique o cadastro do órgão anuente deste formulário e realize a integração com o portal único siscomex para atualizar o modelo deste formulário antes de utilizá-lo novamente!"
         ElseIf oJsonFoRM["listaCamposFormulario"] == Nil .Or. Len(oJsonFoRM["listaCamposFormulario"]) == 0
            MsgStop(STR0030)//"O template disponibilizado para este formulário não possui as definições dos campos de capa para preenchimento na tela. Verifique e atualize o template na rotina de integração de formulários LPCO! (deve haver pelo ao menos uma ocorrência da palavra chave 'ListaCamposFormulario' no texto do campo 'Formul.LPCO')"
         Else
            lRet := .T.
            FreeObj(oJsonForm)
         EndIf
      Else
         MsgStop(STR0027+STR0028) //"Este formulário não possui um modelo informado! " # "Verifique o cadastro do órgão anuente deste formulário e realize a integração com o portal único siscomex para atualizar o modelo deste formulário antes de utilizá-lo novamente!"
      EndIf
   EndIf

Return lRet

/*---------------------------------------------------------------------*
 | Func:  ValCposPOUI                                                  |
 | Autor: Nilson César                                                 |
 | Data:  04/03/2021                                                   |
 | Desc:  Verificar se existem campos com valor inválido no formulário |
 |        do PO-UI                                                     |
 | Obs.:  /                                                            |
 *---------------------------------------------------------------------*/
Static Function ValCposPOUI(oPOUI, cNcmError)
Local aCampos := oPOUI:GetData()
Local aCapaObrig := oPOUI:GetCapaObrig()
Local oItemObrig := oPOUI:GetItemObrig()
Local i, j
Local lRet := .T.
Local cNCM
Local oCampo

Begin Sequence
   // Verificação para validar se os campos obrigatórios da capa estão preenchidos
   For i := 1 To Len(aCapaObrig)
      If aCampos[aCapaObrig[i]] == Nil .Or. Empty(aCampos[aCapaObrig[i]]) .Or. (ValType(aCampos[aCapaObrig[i]]) == 'C' .And. FwNoAccent(Upper(aCampos[aCapaObrig[i]])) == "VALOR INVALIDO")
         lRet := .F.
         break
      EndIf
   Next i

   // Verificação para validar se os campos obrigatórios de cada item está preenchido
   If Len(oItemObrig:GetNames()) > 0 .And. Len(aCampos['LISTANCM']) > 0
      // Iterando sobre cada item no LISTANCM
      For i := 1 To Len(aCampos['LISTANCM'])
         // Definindo a NCM numa variável para ficar mais legível o código
         cNCM := aCampos['LISTANCM'][i]['ncm']
         // Verifica se existe a NCM do formulário no array de itens obrigatórios
         If oItemObrig[cNCM] != Nil
            // Iterando sobre cada campo obrigatório do item
            For j := 1 To Len(oItemObrig[cNCM])
               // Definindo o nome do campo numa variável para ficar mais legível o código
               oCampo := oItemObrig[cNCM][j]
               // Verifica se o campo obrigatório existe ou se está vazio
               If (!aCampos['LISTANCM'][i][oCampo['origem']]:hasProperty(oCampo['campo']) .Or. Empty(aCampos['LISTANCM'][i][oCampo['origem']][oCampo['campo']])) .Or. (ValType(aCampos['LISTANCM'][i][oCampo['origem']][oCampo['campo']]) == 'C' .And. FwNoAccent(Upper(aCampos['LISTANCM'][i][oCampo['origem']][oCampo['campo']])) == "VALOR INVALIDO")
                  lRet := .F.
                  cNcmError := IIF(Empty(cNcmError), Transform(cNCM, "@R 9999.99.99"), cNcmError + ', ' + Transform(cNCM, "@R 9999.99.99"))
                  Exit
               EndIf
            Next j
         EndIf
      Next i
   EndIf
End Sequence

// Tira da memória o objeto de campos obrigatórios das NCMs
FreeObj(oItemObrig)

Return lRet

// Função De Para do Portal Único para o POUI (angular)
Static Function DeParaPUPOUI()
Local oDePara

oDePara := JsonObject():New()
oDePara:fromJSON('{"types": {"NUMERO_INTEIRO": "number","NUMERO_REAL": "number","VALOR_MONETARIO": "currency","VALOR_COM_UNIDADE_MEDIDA": "number","TEXTO": "string","LISTA": "options","BOOLEANO": "boolean","DATA": "date","CRONOGRAMA": "string", "CPF_CNPJ": "string"}}')

Return oDePara

// Função De Para do Protheus para o POUI (angular)
Static Function DeParaProtPOUI(cValor, cTipo)
// Cria um novo objeto
Local oDePara := JsonObject():New()
// Adiciona as conversões para converter com a macro
oDePara:fromJSON('{"types": {"number": "Val(cValor)","currency": "Val(cValor)","string": "cValor","boolean": "cValor","date": "cValor", "options": "cValor" }}')
// Retorna o valor convertido
Return &(oDePara["types"][cTipo])

Static Function getTypeCpo(oDePara, oJsonCampo)
Local cRet
cRet := oDePara['types'][oJsonCampo["tipo"]]
If Empty(cRet)
   cRet := 'string'
EndIf
Return cRet
/*---------------------------------------------------------------------*
 | Func:  JSsendEKM                                                    |
 | Autor: Tiago Tudisco                                                |
 | Data:  17/11/2023                                                   |
 | Desc:  Envia o json da NCM selecionada no Angular                   |
 | Obs.:  /                                                            |
 *---------------------------------------------------------------------*/
Function JSsendEKM(oPOUI, cNCM, cCatalogo)
Local oMdl := FWModelActive()
Local oMdl_EKO := oMdl:GetModel():GetModel("EKOMASTER")
Local ojRet := JsonObject():New()
Local oDePara := DeParaPUPOUI()
Local oCampo
Local aCampos := jsonObject():New()
Local oView := FWViewActive()
Local i, nOrder := 0
Local lComposto := .F.
Local cDivider := ""
Local lTemEkm := .F.
Local lTemEkl := .F.
Local oCatalogo
Local lTemCatalogo
Local aDominioNcm := {}
Local oCondicao := JsonObject():New()
local lSeekEKD := .F.
local cSeqCat  := ""
local oCampoUN
Local lDisabled := oView:GetModel():GetOperation() == MODEL_OPERATION_DELETE .Or. oView:GetModel():GetOperation() == MODEL_OPERATION_VIEW

Default cCatalogo := ""

aCampos['listFieldsItens'] := {}
lTemCatalogo := !Empty(cCatalogo)

// Se tiver catálogo de produtos
If lTemCatalogo
   lSeekEKD := PosEKD(cCatalogo)
   If lSeekEKD .and. EK9->(dbSeek(xFilial("EK9") + cCatalogo))
      cSeqCat := EKD->EKD_VERSAO
      oCatalogo := JsonObject():New()
      // Adiciona o campo ID Portal, Versão Atual, Descrição NCM, Descrição e Descrição Complementar;
      oCatalogo := criaCampoCp({"EKD_COD_I", "EKD_IDPORT","EKD_VATUAL", "EKD_CNPJ", "EKD_VERSAO", "EK9_DESC_I", "EK9_DSCCOM"})
      // Itera sobre os campos criados para mandar para a função cargaCpoPO
      For i := 1 To Len(oCatalogo['listaCamposCatalogo'])
         oCampo := JsonObject():New()
         // Incrementa o contador de ordem
         nOrder++
         // Caso seja o primeiro, adiciona o Divider "Dados do Catálogo de Produto"
         IIF(i == 1, cDivider := "Dados do Catálogo de Produto", cDivider := "")
         // Manda para a função cargaCpoPO para carregar o campo
         cargaCpoPO(@oCampo, oCatalogo['listaCamposCatalogo'][i], .T., .F., oView, oDePara, nOrder, @cDivider, oPOUI,, "catalogo", @oCondicao)
         // If oCampo['propertyBackup'] == "QTDE_COMERCIALIZADA" .Or. oCampo['propertyBackup'] == "QTDE_ESTATISTICA"
         //    oCampoUN := JsonObject():New()
         //    oCampoUN:FromJson(getJsonUN(oCampo['propertyBackup'], ++nOrder, lDisabled, oCampo['origem']))
         //    If oCampo:hasProperty('unidadeMedida') .And.!Empty(oCampo['unidadeMedida'])
         //       oCampoUN['disabled'] := .T.
         //       oCampoUN['value'] := oCampo['unidadeMedida']
         //    EndIf
         // EndIf
         // Desativa o campo para não ser editável
         oCampo["disabled"] := .T.
         // Atribui o valor que está na EK9 para o campo
         oCampo['value'] := if( "EK9_" $ oCampo['property'], AllTrim(&("EK9->" + oCampo['property'])), AllTrim(&("EKD->" + oCampo['property'])))
         // Desativa a exibição do campo se é obrigatório ou opcional
         oCampo['showRequired'] := .F.
         // Adiciona o campo no array de campos
         AAdd(aCampos['listFieldsItens'], oCampo)
         // If oCampoUN <> nil
         //    AAdd(aCampos['listFieldsItens'], oCampoUN)
         // EndIf
         // Libera o objeto criado da memória
         FreeObj(oCampo)
         //freeObj(oCampoUN)
      Next i
      // Libera objeto do catalogo da memória
      FreeObj(oCatalogo)
   EndIf
EndIf

EKM->(dbSetOrder(1)) //EKM_FILIAL, EKM_ORGANU, EKM_FRMLPC, EKM_NCM
EKL->(dbSetOrder(1)) //EKL_FILIAL, EKL_ORGANU, EKL_FRMLPC
EKI->(dbSetOrder(1)) //EKI_FILIAL+EKI_COD_I+EKI_VERSAO+EKI_CODATR+EKI_CONDTE
lTemEkm := EKM->(dbSeek(xFilial("EKM") + oMdl_EKO:GetValue("EKO_ORGANU" ) + oMdl_EKO:GetValue("EKO_FRMLPC" ) + AvKey(cNCM,"EKM_NCM")))
lTemEkl := EKL->(dbSeek(xFilial("EKL") + oMdl_EKO:GetValue("EKO_ORGANU" ) + oMdl_EKO:GetValue("EKO_FRMLPC" )))
If lTemEkm .Or. lTemEkl
   If lTemEkm
      // Caso tenha na EKM que é específica da NCM, pode ter o listaAtributosNcm e quando houver catálogo de produto, é necessário verificar
      // no dominioNcm se a NCM está lá porém este só se encontra na EKL, por isso essas atribuições para pegar o dominioNcm
      If !Empty(EKM->EKM_FRMDEF)
         If lTemCatalogo .and. lTemEkl
            ojRet:fromJSON(EKL->EKL_FORMJS)
            aDominioNcm := ojRet['listaNcm']['dominioNcm']
            freeObj(ojRet)
            ojRet := JsonObject():New()
         EndIf
         ojRet:fromJSON(EKM->EKM_FRMDEF)
      ElseIf lTemEkl
         ojRet:fromJSON(EKL->EKL_FORMJS)
         ojRet['listaCamposNcm'] := ojRet['listaNcm']['listaCamposNcm']
         If lTemCatalogo
            aDominioNcm := ojRet['listaNcm']['dominioNcm']
         EndIf
      EndIf
   ElseIf lTemEkl
      ojRet:fromJSON(EKL->EKL_FORMJS)
      If ojRet:hasProperty('listaNcm') .And. ojRet['listaNcm']:hasProperty('listaCamposNcm') 
         ojRet['listaCamposNcm'] := ojRet['listaNcm']['listaCamposNcm']
      EndIf
      //ojRet := ojRet['listaNcm']
      If lTemCatalogo
         aDominioNcm := ojRet['listaNcm']['dominioNcm']
      EndIf
   EndIf

   // Tratamento de campos do ListaCamposNcm
   If ojRet:hasProperty("listaCamposNcm") .And. Len(ojRet["listaCamposNcm"]) > 0
      For i := 1 To Len(ojRet["listaCamposNcm"])
         oCampo  := JsonObject():New()
         nOrder++
         lComposto := .F.
         cDivider := "Dados Gerais"
         cargaCpoPO(@oCampo, ojRet["listaCamposNcm"][i], i == 1, @lComposto, oView, oDePara, nOrder, @cDivider, oPOUI, cNCM, "listaCamposNcm", @oCondicao)
         If oCampo['propertyBackup'] == "QTDE_COMERCIALIZADA" .Or. oCampo['propertyBackup'] == "QTDE_ESTATISTICA"
            oCampoUN := JsonObject():New()
            oCampoUN:FromJson(getJsonUN(oCampo['propertyBackup'], ++nOrder, lDisabled, oCampo['origem'], cNCM))
            If oCampo:hasProperty('unidadeMedida') .And.!Empty(oCampo['unidadeMedida'])
               oCampoUN['disabled'] := .T.
               oCampoUN['value'] := oCampo['unidadeMedida']
            EndIf
         EndIf
         // Verifica se tem catálogo e se tiver, adiciona o valor e desabilita o campo para editar
         If lTemCatalogo .And. EKI->(dbSeek(xFilial("EKI") + cCatalogo + cSeqCat + oCampo['propertyBackup']))
            oCampo['value'] := DeParaProtPOUI(EKI->EKI_VALOR, oCampo['type'])
            oCampo['disabled'] := .T.
         EndIf
         // Se não for composto, adiciona o campo no array, caso contrário chama a função trataComposto
         IIF(!lComposto, (AAdd(aCampos['listFieldsItens'], oCampo),IF(oCampoUN <> nil,AAdd(aCampos['listFieldsItens'], oCampoUN),)), nOrder := trataComposto(ojRet["listaCamposNcm"][i]["subatributos"], oView, oDePara, nOrder - 1, cDivider, oPOUI, oCondicao, @aCampos, cNCM, "listaCamposNcm"))
         FreeObj(oCampo)
         freeObj(oCampoUN)
      Next
   EndIf
   // Tratamento de campos do listaAtributosNcm
   If lTemEkm .And. ojRet:hasProperty("listaAtributosNcm") .And. Len(ojRet["listaAtributosNcm"]) > 0
      // Caso tenha catálogo, verifica se a NCM está no dominioNcm, se não for catálogo, segue o processamento padrão
      If (lTemCatalogo .And. Len(aDominioNcm) > 0 .And. AScan(aDominioNcm, cNcm) > 0) .Or. !lTemCatalogo
         For i := 1 To Len(ojRet["listaAtributosNcm"])
            oCampo  := JsonObject():New()
            nOrder++
            lComposto := .F.
            cDivider := ""
            cargaCpoPO(@oCampo, ojRet["listaAtributosNcm"][i], i == 1, @lComposto, oView, oDePara, nOrder, @cDivider, oPOUI, cNCM, "listaAtributosNcm", @oCondicao)
            If oCampo['propertyBackup'] == "QTDE_COMERCIALIZADA" .Or. oCampo['propertyBackup'] == "QTDE_ESTATISTICA"
               oCampoUN := JsonObject():New()
               oCampoUN:FromJson(getJsonUN(oCampo['propertyBackup'], ++nOrder, lDisabled, oCampo['origem'], cNCM))
               If oCampo:hasProperty('unidadeMedida') .And.!Empty(oCampo['unidadeMedida'])
                  oCampoUN['disabled'] := .T.
                  oCampoUN['value'] := oCampo['unidadeMedida']
               EndIf
            EndIf
            // Verifica se tem catálogo e se tiver, adiciona o valor e desabilita o campo para editar
            If lTemCatalogo .And. EKI->(dbSeek(xFilial("EKI") + cCatalogo + cSeqCat + oCampo['propertyBackup']))
               oCampo['value'] := DeParaProtPOUI(EKI->EKI_VALOR, oCampo['type'])
               oCampo['disabled'] := .T.
            EndIf
            // Se não for composto, adiciona o campo no array, caso contrário chama a função trataComposto
            IIF(!lComposto, (AAdd(aCampos['listFieldsItens'], oCampo),IF(oCampoUN <> nil,AAdd(aCampos['listFieldsItens'], oCampoUN),)), nOrder := trataComposto(ojRet["listaAtributosNcm"][i]["subatributos"], oView, oDePara, nOrder - 1, cDivider, oPOUI, oCondicao, @aCampos, cNCM, "listaAtributosNcm"))
            FreeObj(oCampo)
            freeObj(oCampoUN)
         Next
      EndIf
   EndIf
   oPOUI:SetFieldItem(aCampos)
   setCondicao(oPOUI:GetFieldItem(), oCondicao)
   FreeObj(oCondicao)
EndIf

Return oPOUI:GetFieldItem()

// Função auxiliar para criar um objeto com os campos recebidos para serem enviados a função cargaCpoPO
Static Function CriaCampoCp(aCampos)
Local oJson
Local oRet := JsonObject():New()
Local i

// Cria a propriedade listaCamposCatalogo no retorno
oRet['listaCamposCatalogo'] := {}

// Itera sobre cada campo no array recebido
For i := 1 to Len(aCampos)
   oJson := JsonObject():New()
   oJson['codigo'] := aCampos[i]
   // Pega o nome do campo na tabela SX3
   oJson['nome'] := AvSX3(aCampos[i], 5)
   // Adiciona o tipo TEXTO para ser convertido em string posteriormente
   oJson['tipo'] := "TEXTO"
   // Cria um objeto dentro de validação
   oJson['validacao'] := JsonObject():New()
   // Define que o campo não é obrigatório
   oJson['validacao']['obrigatorio'] := .F.
   // Pega o tamanho do campos de acordo com a tabela SX3
   oJson['validacao']['tamanhoMaximo'] := AvSX3(aCampos[i], 3)
   // Define que o campo não possui máscara
   oJson['validacao']['mascara'] := Nil
   // Adiciona o objeto criado no array de campos
   AAdd(oRet['listaCamposCatalogo'], oJson)
   // Libera o objeto criado da memória
   FreeObj(oJson)
Next i

Return oRet

// Função para retornar a NCM e seus atributos quando se trata de catálogo de produtos
Function JsSendNcm(cCatalogo)
Local cNcm := ""

// Define o indice da EK9
EK9->(dbSetOrder(1)) // EK9_FILIAL, EK9_COD_I, EK9_VATUAL

// Caso encontre o registro na EK9, retorna a NCM
If EK9->(dbSeek(xFilial("EK9") + cCatalogo))
   cNcm := AllTrim(EK9->EK9_NCM)
EndIf

Return cNcm

// Função pare retornar a descrição da NCM
Function JsSendDescNcm(cNCM)
Local cDescNCM

// Define a ordem de busca na tabela SYD
SYD->(DbSetOrder(1)) //YD_FILIAL, YD_TEC, YD_EX_NCM, YD_EX_NBM, YD_DESTAQU
If SYD->(dbSeek(xFilial("SYD") + AvKey(cNCM,"EKM_NCM")))
   cDescNCM := SYD->YD_DESC_P
Else // Num caso em que não exista a NCM, retorna a própria NCM para não ter erros
   cDescNCM := cNCM
EndIf

Return cDescNCM

Static Function getNcmItem(oPOUI, cID, cVersao)
Local jItens := oPOUI:GetFieldItem(,.T.)
Local aNCMs  := getItemNCM(cID, cVersao)
Local i
Local cRet := jsonobject():new()
//criar um FOR que percorra o objeto jItens e adicione o campo NCM
For i := 1 To Len(jItens)
   jItens[i]['ncm'] := aNCMs[i][1]
   jItens[i]['ncm_desc'] := JsSendDescNcm(aNCMs[i][1])
   jItens[i]['catalogo'] := aNCMs[i][2]
Next i
cRet['listaNcm'] := jItens
Return cRet:ToJson()

Function ExcNcmPOUI(nItem)
If isMemVar("oPOUI")
   oPOUI:DelFieldItem(nItem + 1) //soma 1, pois no angular o array inicia de 0
EndIf
Return

Function setCpObrig(oPOUI, cOperacao, cOrigem, cCampo, cNCM)

Do Case
   Case cOperacao == 'ADICIONA' //Adicionar um campo na lista de Obrigatorios
      oPOUI:SetObrig(cCampo, cNCM, cOrigem)
   Case cOperacao == 'REMOVE' //Remover um campo da lista de Obrigatorios
      oPOUI:remObrig(cCampo, cNCM)
EndCase

Return

/*---------------------------------------------------------------------*
 | Classe:  LP401Event                                                 |
 | Autor: Nilson César                                                 |
 | Data:  04/02/2021                                                   |
 | Desc:  Classe com herança para interceptação do Commit              |
 | Obs.:  /                                                            |
 *---------------------------------------------------------------------*/
Class LP401Event FROM FWModelEvent     
   Method New()
   //Method BeforeTTS()
   Method ModelPosVld()

End Class

Method New() Class LP401Event
Return
/*
Method BeforeTTS(oModel,cModelId) Class LP401Event
   Return LP401BTNOK("VIEW",oModel,cModelId)
*/
Method ModelPosVld(oModel,cModelId) Class LP401Event
Return LP401BTNOK("MODEL",oModel,cModelId)

/*/{Protheus.doc} PosEKD
   Posiciona na tabela EKD da sequencia integrada ou registrada manualmente do catalogo de produto

   @type  Static Function
   @author user
   @since 14/02/2024
   @version version
   @param cCatalogo, caracter, Código chave do catalogo do produto
   @return lSeek, logico, .T. se encontrou e .F. se não encontrou
   @example
   (examples)
   @see (links_or_references)
/*/
static function PosEKD(cCatalogo)
   local lSeek      := .F.
   local cQuery     := ""
   local cAliasEKD  := ""
   local oQry

   default cCatalogo  := ""

   if !empty(cCatalogo)
      cAliasEKD  := GetNextAlias()

      cQuery := " SELECT EKD.R_E_C_N_O_ EKDREC "
      cQuery += " FROM  " + RetSqlName("EKD") + " EKD "
      cQuery += " WHERE EKD.EKD_FILIAL   = ? "
      cQuery += "     AND EKD.EKD_COD_I  = ? "
      cQuery += "     AND EKD.EKD_MODALI = '1' AND (EKD.EKD_STATUS = '1' OR EKD.EKD_STATUS = '6') AND EKD_IDPORT <> ' ' "
      cQuery += "     AND EKD.D_E_L_E_T_= ' ' "

      oQry := FWPreparedStatement():New(cQuery)

      oQry:SetString(1, xFilial("EKD"))
      oQry:SetString(2, cCatalogo)

      cQuery := oQry:GetFixQuery()
      MPSysOpenQuery(cQuery, cAliasEKD)
      (cAliasEKD)->(dbGoTop())
      if !(cAliasEKD)->(Eof())
         EKD->(dbGoTo((cAliasEKD)->EKDREC))
         lSeek := EKD->(recno()) == (cAliasEKD)->EKDREC
      endif
      (cAliasEKD)->(dbCloseArea())
      fwFreeObj(oQry)

   endif

return lSeek
