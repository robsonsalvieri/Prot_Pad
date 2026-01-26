#Include "RUS34S10C_CT2MVC.ch"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"

#DEFINE  _CCUBEENT    CT0->CT0_ENTIDA
#DEFINE  _CCUBECHV    ALLTRIM(CT0->CT0_CPOCHV)
#DEFINE  _CCUBEDSC    ALLTRIM(CT0->CT0_CPODSC)
#DEFINE  _CCUBEALIAS  CT0->CT0_ALIAS
#DEFINE  _CCUBESUP    CT0->CT0_CPOSUP
#DEFINE  _NSIZEENT    TamSX3(ALLTRIM(CT0->CT0_CPOCHV))[1]
#DEFINE  _CCUBEID     CT0->CT0_ID

/*MAINTENANCE FOR PROJECTS Appointments (simple model to be used in web forms for VISUALIZATION)*/
STATIC lGetSubModel := .T.
PUBLISH MODEL REST NAME CT2FWMODEL RESOURCE OBJECT oModelCT2

Class oModelCT2 From FwRestModel
DATA CORDER as string
DATA FILTER00 as string
DATA FILTER01 as string
DATA FILTER02 as string
DATA FILTER03 as string
DATA FILTER04 as string
DATA FILTER05 as string
DATA FILTER06 as string
DATA FILTER07 as string
DATA FILTER08 as string
DATA FILTER09 as string
DATA ENTITY01 as string
DATA ENTITY02 as string
DATA ENTITY03 as string
DATA ENTITY04 as string
DATA ENTITY05 as string
DATA ENTITY06 as string
DATA ENTITY07 as string
DATA ENTITY08 as string
DATA ENTITY09 as string
DATA workingBranch As string

Method Activate()
Method Seek()
Method Total()
//Method DeActivate()
//Method SetAlias()
//Method Skip()
//Method Seek()

EndClass

Method Seek(cPK) Class oModelCT2
Local lRet := SEEKMethod(@self,cPK)
lGetSubModel := .T. //!Empty(cPk)
Return lRet

Method TOTAL() Class oModelCT2
Local cQry := createQueryAlias(@self:cQryAlias, self:cAlias, self:cFilter,self:cOrder,self,.F.)
Local cAlias:= GetNextAlias()
Local nRet := 0

cQry  := " SELECT COUNT(*) AS RECORDS FROM ("+cqry+") A "
cQry  := ChangeQuery(cQry)
dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQry),cAlias,.T.,.F.)
DbSelectArea(cAlias)
nRet:=   RECORDS
DbCloseArea()
DbSelectArea('CT2')

Return nRet

Method Activate() Class oModelCT2
local lRet as logical
// Set query order if received
self:cOrder := self:GetQSValue("order")
//So os permitidos
SetCurrentBranch(self:GetQSValue("workingBranch"))

If _Super:Activate()
  If .f. //!MPUserHasAccess('PMSA320').And.!MPUserHasAccess('PMSA321')
        _Super:setfilter("1=2") 
        lRet := .F.
        self:SetStatusResponse(403, STR0001)  //"Forbidden access to routine "
    Else
        // Set standard filter for model
        FilterOnActivate(@self,'CT2FWMODEL')
        lRet := .T.      
   EndIf   
Else
   lRet := .F.
EndIf
Return lRet


Function RUS34S10C()
        /*Declarando as variáveis que serão utilizadas*/
	Local aArea := CT2->(GetArea())
	Private oBrowse
   Private aRotina:= MenuDef()
   //Iniciamos a construção básica de um Browse.
	oBrowse := FWMBrowse():New()

        //Definimos a tabela que será exibida na Browse utilizando o método SetAlias
	oBrowse:SetAlias("CT2")

        //Definimos o título que será exibido como método SetDescription
	oBrowse:SetDescription(STR0002) //"Lancamentos"
	
	//Adiciona um filtro ao browse
	//oBrowse:SetFilterDefault( "X5_TABELA == '21'" )
	
	//Desliga a exibição dos detalhes
	//oBrowse:DisableDetails()
	
   //Ativamos a classe
	oBrowse:Activate()
   RestArea(aArea)
Return
Static Function MenuDef() 
Local aRotina := {}
aAdd( aRotina, { STR0003   , 'VIEWDEF.RUS34S10C_CT2MVC', 0, 2, 0, NIL } ) //'View'
Return aRotina

Static Function ModelDef() 
// Cria a estrutura a ser usada no Modelo de Dados
Local oStruCT2
Local oStruCV3
Local oModel // Modelo de dados que ser? constru?do
//Local oRestModel:= oModelCT2():New()

// Creates TMP table used in standard CTBA102 To avoid errors from X3_WHEN and X3_RELACAO
Private aAltera		:= {}
Private aHeader		:= {}
CtbCrTmpBD()
Ctb105STmp() // change temporary table alias to "TMP"
oStruCT2 := FWFormStruct(  1, 'CT2' ,/*{ |cCpo| CT2->(FieldPos(ALLTRIM(cCpo))) > 0 }*/)
If lGetSubModel
   oStruCV3 := FWFormStruct(  1, 'CV3' ,{ |cCpo| CV3->(FieldPos(ALLTRIM(cCpo))) > 0 })
Endif
oModel   := MPFormModel():New('RUS34S10C_CT2MVC',,,)

//oModel:SetVldActivate( { |oModel| ACTIVATE( oModel ) } )
//oStruCT2:AddField('RECNO', '', 'R_E_C_N_O_', 'N', 10,0, , {|| .F.}/*[ bWhen ]*/, , .F.,/* [ bInit ]*/,/* <lKey >*/, .T./*[ lNoUpd ]*/, /*[ lVirtual ]*/,/* [ cValid ]*/)

//FWFORMMODELSTRUCT():AddField(<cTitulo >, <cTooltip >, <cIdField >, <cTipo >, <nTamanho >, [ nDecimal ], [ bValid ], [ bWhen ], [ aValues ], [ lObrigat ], [ bInit ], <lKey >, [ lNoUpd ], [ lVirtual ], [ cValid ])->
// Adiciona ao modelo um componente de formul?rio
oStruCT2:AddField('R_E_C_N_O_',STR0004 , 'R_E_C_N_O_', 'C',17 , /*[ nDecimal ]*/, /*[ bValid ]*/, /*[ bWhen ]*/, /*[ aValues ]*/, /*[ lObrigat ]*/, {|| CT2->(Recno())}/* [ bInit ]*/,/* <lKey >*/,/* [ lNoUpd ]*/, .T. /*[ lVirtual ]*/, /*[ cValid ]*/) //"Recno CT2"
//oStruCT2:AddField('VALUE_DEB' ,'STR0004 DEB'  , 'VALUE_DEB' , 'N',17 , 2 /*[ nDecimal ]*/, /*[ bValid ]*/, /*[ bWhen ]*/, /*[ aValues ]*/, /*[ lObrigat ]*/, {|| iif(CT2->CT2_DC $ '13',CT2->CT2_VALOR,0)}/* [ bInit ]*/,/* <lKey >*/,/* [ lNoUpd ]*/, .T. /*[ lVirtual ]*/, /*[ cValid ]*/) //"Recno CT2"
//oStruCT2:AddField('VALUE_CRED','STR0004 CRED' , 'VALUE_CRED', 'N',17 , 2 /*[ nDecimal ]*/, /*[ bValid ]*/, /*[ bWhen ]*/, /*[ aValues ]*/, /*[ lObrigat ]*/, {|| iif(CT2->CT2_DC $ '23',CT2->CT2_VALOR,0)}/* [ bInit ]*/,/* <lKey >*/,/* [ lNoUpd ]*/, .T. /*[ lVirtual ]*/, /*[ cValid ]*/) //"Recno CT2"

//FWFORMMODELSTRUCT():AddField(<cTitulo >, <cTooltip >, <cIdField >, <cTipo >, <nTamanho >, [ nDecimal ], [ bValid ], [ bWhen ], [ aValues ], [ lObrigat ], [ bInit ], <lKey >, [ lNoUpd ], [ lVirtual ], [ cValid ])-> NIL
oModel:AddFields( 'CT2MASTER', /*cOwner*/, oStruCT2)
If lGetSubModel
   oStruCV3:AddField(STR0006,STR0005 , 'ORIGIN', 'M',8 , /*[ nDecimal ]*/, /*[ bValid ]*/, /*[ bWhen ]*/, /*[ aValues ]*/, /*[ lObrigat ]*/, {|| GetRecord(CV3->CV3_TABORI,CV3->CV3_RECORI)}/* [ bInit ]*/,/* <lKey >*/,/* [ lNoUpd ]*/, .T. /*[ lVirtual ]*/, /*[ cValid ]*/) //"Origin"
   oModel:addGrid('RASTCV3','CT2MASTER',oStruCV3)
Endif


oModel:getModel('CT2MASTER'):SetDescription(STR0002) //"Lan?amentos"
If lGetSubModel
   oModel:getModel('RASTCV3'):SetDescription(STR0007) //STR0007
   oModel:SetRelation('RASTCV3', { { "CV3_FILIAL" , "CT2_FILIAL" }, {"CV3_RECDES","R_E_C_N_O_"} }, CV3->(IndexKey(2)) )
Endif
oModel:SetPrimaryKey({'CT2_DATA','CT2_LOTE','CT2_SBLOTE','CT2_DOC','CT2_LINHA','CT2_EMPORI','CT2_FILORI','CT2_MOEDLC','CT2_SEQIDX'})

// Adiciona a descri??o do Modelo de Dados
//oModel:SetDescription( 'Modelo de dados de Autor/Interprete' )
// Adiciona a descri??o do Componente do Modelo de Dados
//oModel:GetModel( 'AF9MASTER' ):SetDescription( 'Dados de Autor/Interprete' )
// Retorna o Modelo de dados
//oModel:SetVldActivate( { |oModel| U_NPPMS306_PREVALID( oModel ) } )
//oModel:InstallEvent("NPPMS30Event", /*cOwner*/, oEvent)
Return oModel

Static Function UsedCT2()
Local cUsed:= IIf(EMPTY(xFilial("CT1") ) .AND. EMPTY(xFilial("CT2")),  "CT2_FILIAL",  "")


cUsed += IIf(EMPTY(xFilial("CT2")),  "CT2_FILORI",  "")

DbSelectArea('SX3')
DbSetOrder(1)
dBsEEK('CT2')
WHILE SX3->X3_ARQUIVO == 'CT2' .AND. !EOF()
   cUsed += IIf(X3USO(X3_USADO,34),","+SX3->X3_CANPO,"")
   SX3->(DbSkip())
Enddo

Return cUsed


Static Function ViewDef()
// Cria um objeto de Modelo de dados baseado no ModelDef() do fonte informado
Local oModel := FWLoadModel( 'RUS34S10C_CT2MVC' )
// Cria a estrutura a ser usada na View
Local cColumnsView := UsedCT2()
Local oStruCT2 := FWFormStruct( 2, 'CT2',{ |cCpo| cCpo $ (cColumnsView)} )
Local oStruCV3 := FWFormStruct(2, 'CV3',{ |cCpo| CV3->(FieldPos(ALLTRIM(cCpo))) > 0 }) 

// Interface de visualiza??o constru?da
Local oView
//oStruCT2:AddField('VALUE_DEB' , '98', 'deb', 'dev', {}, 'N', ''/*<cPicture >*/,{||''} /* <bPictVar >*/  ,''/* <cLookUp >*/,.F./* <lCanChange >*/,'' /*<cFolder >*/,''/* <cGroup >*/, /*[ aComboValues ]*/, /*[ nMaxLenCombo ]*/,'' /*<cIniBrow >*/, .T. /*<lVirtual >*/, ''/*<cPictVar >*/, /*[ lInsertLine ]*/, /*[ nWidth ]*/)
//oStruCT2:AddField('VALUE_CRED', '99', 'cred', 'cred', {}, 'N', ''/*<cPicture >*/,{||''} /* <bPictVar >*/,''/* <cLookUp >*/,.F./* <lCanChange >*/,'' /*<cFolder >*/,''/* <cGroup >*/, /*[ aComboValues ]*/, /*[ nMaxLenCombo ]*/,'' /*<cIniBrow >*/, .T. /*<lVirtual >*/, ''/*<cPictVar >*/, /*[ lInsertLine ]*/, /*[ nWidth ]*/)

//oStruCT2:SetNoFolder()
// Cria o objeto de View
oView := FWFormView():New()
// Define qual o Modelo de dados ser? utilizado na View
oView:SetModel( oModel )
// Adiciona no nosso View um controle do tipo formul?rio
// (antiga Enchoice)
oView:AddField( 'VIEW_CT2', oStruCT2, 'CT2MASTER' )
oView:AddGrid(  'RASTCV3V', oStruCV3, 'RASTCV3')  
oView:CreateHorizontalBox( 'HEADER', 50)
oView:CreateHorizontalBox( 'DETAIL', 50)

// Criar um "box" horizontal para receber algum elemento da view

// Relaciona o identificador (ID) da View com o "box" para exibi??o
oView:SetOwnerView( 'VIEW_CT2', 'HEADER' )
oView:SetOwnerView( 'RASTCV3V', 'DETAIL' )


// Retorna o objeto de View criado
Return oView


Static Function SEEKMethod (oFMModel,cPK) 
Local lRet := .F.
Local cQry
Local cPkFilter
    If oFMModel:HasAlias()
        If !Empty(cPK)
            cPkFilter := FWAToS(oFMModel:oModel:GetPrimaryKey(),"||") + " = '" + cPk + "'"
            If (oFMModel:cAlias)->(FieldPos(PrefixoCpo(oFMModel:cAlias)+"_FILIAL")) > 0
                cPkFilter := PrefixoCpo(oFMModel:cAlias)+"_FILIAL||" + cPkFilter
            EndIf
            oFMModel:SetFilter(cPkFilter)
        Endif
        cQry := createQueryAlias(@oFMModel:cQryAlias, oFMModel:cAlias, oFMModel:cFilter,oFMModel:cOrder,oFMModel)
        If oFMModel:lDebug .And. oFMModel:GetQSValue("showQuery") == "true"
            i18nConOut("[FWRESTMODELOBJECT] Query: #1#2", {CRLF, cQry})
        EndIf
        If !(oFMModel:cQryAlias)->(Eof())
            (oFMModel:cAlias)->(dbGoTo((oFMModel:cQryAlias)->R_E_C_N_O_))
            lRet := !(oFMModel:cAlias)->(Eof())
        EndIf
    Endif
Return lRet
Function FilterOnActivate(oFMModel,cModel)
Local cFixedFilter  :=""
If cFixedFilter <> ""
   If(oFMModel:cFilter) <> ""
      oFMModel:setfilter(oFMModel:cFilter + " AND ("+cFixedFilter+")")
   Else
      oFMModel:setfilter("("+cFixedFilter+")")
   Endif    
Endif
Return 

Static Function GetQueryOrder(cOrder,cTable)
If cOrder<>Nil .And. cOrder <> ""
    cOrder := StrTran(cOrder,';',"")
    cOrder := " ORDER BY ("+cOrder+")"
Else
   cOrder := " ORDER BY CT2_FILIAL"
Endif
Return cOrder

Static Function createQueryAlias(cQryAlias, cTable, cFilter,cOrder,oFMModel,lUseOrder)
Local oStatement
Local cQuery  := ""
DEFAULT lUseOrder := .T.
    cQuery += "SELECT R_E_C_N_O_"
    cQuery += GetFromQryAlias(cTable)
    cQuery += GetWhereQryAlias(oFMModel, cFilter)
    If lUseOrder
      cQuery += GetQueryOrder(cOrder,cTable)
    Endif
    oStatement := FWPreparedStatement():New(cQuery)
    cQuery     := oStatement:getFixQuery()
    cQuery     := ChangeQuery(cQuery)
    MPSysOpenQuery(cQuery, @cQryAlias)
    oStatement:Destroy()
    FwFreeObj(oStatement)
Return cQuery
/*
Funcao responsavel por retornar a clausula from da query de dados
@param cTable Tablea principal
@return cFrom Clausula from da query
@author Felipe Bonvicini Conti
@since 05/04/2016
@version P11, P12
/*/

//-------------------------------------------------------------------
Static Function GetFromQryAlias(cTable)
Return " FROM " + RetSqlName( cTable ) + " "+cTable
//-------------------------------------------------------------------
/*/{Protheus.doc} GetWhereQryAlias
Funcao responsavel por retornar a clausula where da query de dados
@param cTable   Tablea principal
@param cFilter  Filtro da query
@return cWhere Clausula where da query
@author Felipe Bonvicini Conti
@since 05/04/2016
@version P11, P12
/*/
//-------------------------------------------------------------------
Static Function GetWhereQryAlias(oFMModel, cFilter)
Local cWhere
Local nX,nZ
Local cWhereC     := ''
Local cWhereD     := ''
Local cSeekKey    := ""
    cWhere := " WHERE D_E_L_E_T_ = ' ' AND CT2_VALOR <> 0 "
    If !'CT2_FILIAL' $ cFilter
      If Empty(xFilial('CT2'))
         cWhere += " AND CT2_FILIAL = '"+xFilial('CT2')+"' "
      ElseIf !Empty(oFMModel:GetQSValue("ENTITY00")) 
         cWhere += " AND CT2_FILIAL = '"+DecodeUTF8(StaticCall(RUSRESTFW,MYDECODE,decode64(oFMModel:GetQSValue("ENTITY00") )))+"' "
      ElseIf !Empty(oFMModel:GetQSValue("FILTER00"))
         cWhere += " AND CT2_FILIAL IN (SELECT M0_CODFIL FROM SYS_COMPANY WHERE D_E_L_E_T_= '' AND M0_CODIGO = '"+cEmpAnt+"' AND ("+DecodeUTF8(StaticCall(RUSRESTFW,MYDECODE,decode64(oFMModel:GetQSValue("ENTITY00") )))+")"+") "
      Else 
         cWhere += " AND CT2_FILIAL = '"+xFilial('CT2')+"' "
      Endif
   Endif
    //Introduz a seguran?a padr?o de acesso as filiais do sistema
   // TODO: INCLUIR FILIAIS
    For nX:=1 to 9
      cIn:= ""
      cFltTmp := ""
      dbSelectArea('CT0')
      DBsEToRDER(1)
      dBSEEK(xFilial()+ STRZERO(nX,2) )
      If !Empty(oFMModel:GetQSValue("FILTER"+StrZero(nX,2))) //.Or. !Empty(oFMModel:GetQSValue("ENTITY"+StrZero(nX,2)))
         /*       
         cIn   := " SELECT " + _CCUBECHV+ " FROM "+RETSQLNAME(_CCUBEALIAS)+" WHERE D_E_L_E_T_ = ''  "
         cIn   += " AND "+_CCUBEALIAS+"_CLASSE ='2' "
         If !Empty(oFMModel:GetQSValue("FILTER"+StrZero(nX,2))) 
            cIn   += " AND ("+oFMModel:GetQSValue("FILTER"+StrZero(nX,2))+") "
         Endif
         */
         cFltTmp  := " OR ("+DecodeUTF8(StaticCall(RUSRESTFW,MYDECODE,decode64(oFMModel:GetQSValue("FILTER"+StrZero(nX,2)) )))+") "
      Endif
      If !Empty(oFMModel:GetQSValue("ENTITY"+StrZero(nX,2)))
         If oFMModel:GetQSValue("ENTITY"+StrZero(nX,2)) != '__blank__'
            DbSelectArea(_CCUBEALIAS)
            DbSetOrder(1)
            If (_CCUBEALIAS) == "CV0"
               cSeekKey := _CCUBEID + DecodeUTF8(StaticCall(RUSRESTFW,MYDECODE,decode64(oFMModel:GetQSValue("ENTITY"+StrZero(nX,2)))))
            Else
               cSeekKey := DecodeUTF8(StaticCall(RUSRESTFW,MYDECODE,decode64(oFMModel:GetQSValue("ENTITY"+StrZero(nX,2)))))
            Endif
            If dBSEEK(xFilial()+cSeekKey)
               If (_CCUBEALIAS)->(FieldGet(FieldPos(_CCUBEALIAS+"_CLASSE"))) == "1"
                  aChildren := {}
                  GetEnts(aChildren,DecodeUTF8(StaticCall(RUSRESTFW,MYDECODE,decode64(oFMModel:GetQSValue("ENTITY"+StrZero(nX,2))))))
                  cIn2 := ""
                  For nZ:= 1 To Len(aChildren)
                     cIn2 += ",'"+aChildren[nZ]+"'"
                  Next
                  If !Empty(cIn2)
                     cFltTmp   += " AND "+_CCUBECHV+ " IN ("+Substr(cIn2,2)+") "
                  Endif
               Else
                  cFltTmp := " AND "+_CCUBECHV +" = '"+DecodeUTF8(StaticCall(RUSRESTFW,MYDECODE,decode64(oFMModel:GetQSValue("ENTITY"+StrZero(nX,2)))))+"'"
               Endif
            Endif
         Else 
            cFltTmp := " OR  "+_CCUBECHV +" = '' "
         Endif
      Endif
      If !EMPTY(cFltTmp)
            // Direct entity filter
         Do Case
            CASE _CCUBEALIAS == 'CT1'
               cFltTmpC := StrTran(Substr(cFltTmp,5),'CT1_CONTA','CT2_CREDIT')   
               cFltTmpD := StrTran(Substr(cFltTmp,5),'CT1_CONTA','CT2_DEBITO' )   
            CASE _CCUBEALIAS == 'CTT'
//               cWhere   += " AND (CT2_CCD IN ("+cIn+") OR CT2_CCC IN ("+cIn+")  ) "
               cFltTmpC := StrTran(Substr(cFltTmp,5),'CTT_CUSTO','CT2_CCC')   
               cFltTmpD := StrTran(Substr(cFltTmp,5),'CTT_CUSTO','CT2_CCD' )   
            CASE _CCUBEALIAS == 'CTD'
//               cWhere   += " AND (CT2_ITEMD IN ("+cIn+") OR CT2_ITEMC IN ("+cIn+")  ) "
               cFltTmpC := StrTran(Substr(cFltTmp,5),'CTD_ITEM','CT2_ITEMC')   
               cFltTmpD := StrTran(Substr(cFltTmp,5),'CTD_ITEM','CT2_ITEMD' )   
            CASE _CCUBEALIAS == 'CTH'
               //cWhere   += " AND (CT2_CLVLDB IN ("+cIn+") OR CT2_CLVLCR IN ("+cIn+")  ) "
               cFltTmpC := StrTran(Substr(cFltTmp,5),'CTH_CLVL','CT2_CLVLCR')   
               cFltTmpD := StrTran(Substr(cFltTmp,5),'CTH_CLVL','CT2_CLVLDB' )   
            CASE _CCUBEALIAS == 'CV0'
  //             cWhere   += " AND (CT2_EC"+_CCUBEID+"CR IN ("+cIn+") OR CT2_EC"+_CCUBEID+"DB IN ("+cIn+")  ) "
               cFltTmpC := StrTran(Substr(cFltTmp,5),'CV0_CODIGO','CT2_EC'+_CCUBEID+'CR')   
               cFltTmpD := StrTran(Substr(cFltTmp,5),'CV0_CODIGO','CT2_EC'+_CCUBEID+'DB') 
         ENDCASE
         If oFMModel:GetQSValue("TPPOSTINGS") == "CD"
            cWhereC   +=  " AND ("+ cFltTmpC +") "
            cWhereD   +=  " AND ("+ cFltTmpD +") "
         ElseIf oFMModel:GetQSValue("TPPOSTINGS") == "D"
            cWhere   +=  " AND ("+ cFltTmpD +") "
         ElseIf oFMModel:GetQSValue("TPPOSTINGS") == "C"
            cWhere   +=  " AND ("+ cFltTmpC +") "
         Endif
      Endif
    Next
  /* If !Empty(oFMModel:GetQSValue("ENTITY00"))
      cWhere   += " AND CT2_FILIAL = '"+self:GetQSValue("ENTITY00")+"' "
   Endif*/
   If oFMModel:GetQSValue("TPPOSTINGS") == "CD" .Or. oFMModel:GetQSValue("TPPOSTINGS") == "DC" 
      cWhere += " AND ("+Substr(cWhereC,5)+ " OR "+Substr(cWhereD,5)+") "
   Endif
   If !Empty(cFilter)
      cWhere    += " AND (" + cFilter+")"
   Endif
Return cWhere

Static Function GetEnts(aRet,cEntity)
Local cQuery   := ""
Local cAlias   := GetNextAlias()
Local aArea    := GetArea()
//DEFAULT cBranch := xFilial('CT2')

cQuery := " SELECT "+_CCUBEALIAS+"_CLASSE CLASSE , "+(_CCUBECHV)+" ENTITY "
cQuery += " FROM  "+RETSQLNAME(_CCUBEALIAS) 
cQuery += " WHERE  "+_CCUBEALIAS +"_FILIAL = '"+xFilial(_CCUBEALIAS) + "' "
cQuery += " AND   "+_CCUBESUP+" = '"+(cEntity) + "' "
cQuery += Iif(_CCUBEALIAS=='CV0',"AND CV0_PLANO='"+_CCUBEID+"'","")
cQuery += " AND   D_E_L_E_T_ =  '' "
cQuery   := ChangeQuery(cQuery)
//TODO: CheckFilial
dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAlias,.T.,.F.)
DbSelectArea(cAlias)
while !EOF()
   If (CLASSE == '2')
      AAdd(aRet,ENTITY)
   Else
      GetEnts(aRet,ENTITY)
   Endif
   DbSkip()
Enddo
DbSelectArea(cAlias)
DbCloseArea()
RestArea(aArea)
Return 

Static Function GetRecord(cTab,cRec)
Local cRet
Local oView
//cRec := Str(9969)
//cTab := "SD1"
//CV3->(DbGoto(9969))
SX2->(DbSetOrder(1))
If lGetSubModel
   If cTab <> "CT2" .AND. SX2->(DbSeek(cTab)) .And. Val(cRec) > 0
      DbSelectArea(cTab)
      DbGoto(Val(cRec))
      oView:=FWLoadView( 'RUS34S10D')
      oView:oModel:ACTIVATE()
      cRet := decodeutf8(oView:oModel:GetJSONData(.T., 1 /*[ nOperation ]*/, .t. /*[ lVirtual ]*/, /*[ lDeleted ]*/, /*[ lEmpty ]*/))
      oView:oModel:DEACTIVATE()
   Endif
Endif
Return cRet

Static Function SetCurrentBranch(cBranch)
Local aArea := getArea()
cBranch := Padr(cBranch,FwSizeFilial())
If !Empty(cBranch) .And. FWFilExist(cEmpAnt, cBranch)
   dbSelectArea("SM0")
   dbSetOrder(1)
   dbSeek(cEmpAnt+cBranch)
   cFilAnt := SM0->M0_CODFIL 
   RestArea(aArea)
Endif  
Return
                   
//Merge Russia R14 
                   
