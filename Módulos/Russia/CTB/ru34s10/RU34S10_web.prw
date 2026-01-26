#INCLUDE "RU34S10_web.ch"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWBROWSE.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "RESTFUL.CH"

#DEFINE  _CCUBEENT    CT0->CT0_ENTIDA
#DEFINE  _CCUBECHV    ALLTRIM(CT0->CT0_CPOCHV)
#DEFINE  _CCUBEDSC    ALLTRIM(CT0->CT0_CPODSC)
#DEFINE  _CCUBEALIAS  CT0->CT0_ALIAS
#DEFINE  _CCUBESUP    CT0->CT0_CPOSUP
#DEFINE  _NSIZEENT    TamSX3(ALLTRIM(CT0->CT0_CPOCHV))[1]

/* START MODEL F61 */
STATIC aUserGroups

/* START STANDARD ACCOUNTING PARAMETERS */

WSRESTFUL RU34S10 DESCRIPTION STR0001 //"Turnover sheet"
	WSDATA count						As Number
	WSDATA startIndex					As Number
	WSDATA level0 					As character
	WSDATA level1 					As character
	WSDATA level2 					As character
	WSDATA level3 					As character
	WSDATA level4 					As character
	WSDATA level5 					As character
	WSDATA level6 					As character
	WSDATA level7 					As character
	WSDATA level8 					As character
	WSDATA level9 					As character
	WSDATA baselevel 				As character
	WSDATA parent     			As character
	WSDATA indent     			As character
	WSDATA currency 				As character
	WSDATA balance					As character
	WSDATA workingBranch			As character
	WSDATA locale     			As character
   

WSMETHOD GET params ;
    DESCRIPTION STR0002 ; //"Get parametrization for report"
    WSSYNTAX "params/" ;
    PATH "params/"  
/*
WSMETHOD GET analytics ;
    DESCRIPTION "Get analytics entities for summarizing entities" ;
    WSSYNTAX "postings/" ;
    PATH "postings/"  
*/
WSMETHOD POST  ;
    DESCRIPTION STR0012 ; //"Insert parametrization"
    WSSYNTAX "MVCparams" ;
    PATH "MVCparams"  

WSMETHOD PUT  ;
    DESCRIPTION STR0003 ; //"Update parametrization"
    WSSYNTAX "MVCparams/{pk}" ;
    PATH "MVCparams/{pk}"  

WSMETHOD DELETE  ;
    DESCRIPTION STR0004 ; //"Delete parametrization"
    WSSYNTAX "MVCparams/{pk}" ;
    PATH "MVCparams/{pk}"  

WSMETHOD POST getcube ;
    DESCRIPTION STR0005 ; //"Get cube data"
    WSSYNTAX "getcube" ;
    PATH "getcube"  

END WSRESTFUL 


WSMETHOD GET params  WSSERVICE RU34S10
Local lRet	:=	.T.
Local cResponse:=""
Local cIdiomBkp := FwRetIdiom()
If self:locale <> nil .and. self:locale $ 'pt-BR/ru/en/es/pt-PT'
   FwSetIdiom(self:locale)
Endif

/*
This method will return:
-Entities available for balances
*/
// define return type

::SetContentType("application/json; charset=UTF-8")  
If Len(::aURLParms) <> 1
   lRet := .F.
	cResponse := '{'+;
						'"type": "error",'+;
    					'"code": "590",'+;
    					'"message": "'+STR0008+'",'+; //"Incorrect parameter count"
    					'"detailedMessage": "'+I18n(STR0007,{Alltrim(str(Len(::aURLParms)))})+'"'+; //1 parameters expected, received #1"
						'}'
   ::SetResponse(EncodeUTF8(cResponse))
Else
	cResponse:=	GetParams()
	If Len(cResponse) >2
		::SetResponse(EncodeUTF8(cResponse))
	Else
		cResponse := '{'+;
						'"type": "warning",'+;
    					'"code": "591",'+;
    					'"message":"'+STR0008+'",'+; //"Query returned no data"
    					'"detailedMessage": "'+STR0008+'"'+; //"Query returned no data"
						'}'
		::SetResponse(EncodeUTF8(cResponse))
	Endif	
Endif
FwSetIdiom(cIdiomBkp)

Return lRet

WSMETHOD PUT WSREST RU34S10
Local cBody			   := Self:GetContent()
Local cMsg			:= ""
Local cJson	    	:= ""
Local lRet			:= .T.
Local cIdiomBkp := FwRetIdiom()
If self:locale <> nil .and. self:locale $ 'pt-BR/ru/en/es/pt-PT'
   FwSetIdiom(self:locale)
Endif
SetCurrentBranch(::WorkingBranch)

If !Empty(cBody)
   If !GrvRecord(cBody, @cMsg,4,::aURLParms[2] )
      oItem        			   := JsonObject():New() //&cJsonObj
      oItem["type"] 	        := 'error'
      oItem["code"] 	        := "592"
      oItem["message"] 	        := STR0014
      oItem["detailedMessage"] 	:= cMsg
      cJson := FWJsonSerialize(oItem, .F., .F., .T.)
      Self:SetResponse(cJson)
   Else
      Self:SetResponse('{"ok": true, "message":"'+cMsg+'"}')
	EndIf
Else
   SetRestFault(500,STR0013) 
   lRet := .f.
EndIf
FwSetIdiom(cIdiomBkp)

Return( lRet )

WSMETHOD DELETE  WSREST RU34S10
Local cBody			   := Self:GetContent()
Local cMsg			:= ""
Local cJson	    	:= ""
Local lRet			:= .T.
Local cIdiomBkp := FwRetIdiom()
If self:locale <> nil .and. self:locale $ 'pt-BR/ru/en/es/pt-PT'
   FwSetIdiom(self:locale)
Endif

If !Empty(::aURLParms[1])
   If !GrvRecord(cBody, @cMsg,5 ,::aURLParms[2] )
      oItem        			   := JsonObject():New() //&cJsonObj
      oItem["type"] 	        := 'error'
      oItem["code"] 	        := "592"
      oItem["message"] 	        := STR0014
      oItem["detailedMessage"] 	:= cMsg
      cJson := FWJsonSerialize(oItem, .F., .F., .T.)
      Self:SetResponse(cJson)
   Else
      Self:SetResponse('{"ok": true, "message":"'+cMsg+'"}')
	EndIf
EndIf
FwSetIdiom(cIdiomBkp)

Return( lRet )

WSMETHOD POST getcube WSREST RU34S10
Local cBody			   := Self:GetContent()
Local lRet			:= .T.
Local cIdiomBkp := FwRetIdiom()
Default oItemDetail	:= JsonObject():New()
If self:locale <> nil .and. self:locale $ 'pt-BR/ru/en/es/pt-PT'
   FwSetIdiom(self:locale)
Endif
oItemDetail:FromJson(cBody)
Conout(STR0016)
cRet := CTBS34(oItemDetail,self)
cRet := EncodeUTF8(cRet)
Self:SetResponse('{"ok": true, "message":'+cRet+'}')

FwSetIdiom(cIdiomBkp)

Return lRet
WSMETHOD POST  WSREST RU34S10
Local cBody			   := Self:GetContent()
Local cMsg			:= ""
Local cJson	    	:= ""
Local lRet			:= .T.
Local cIdiomBkp := FwRetIdiom()
If self:locale <> nil .and. self:locale $ 'pt-BR/ru/en/es/pt-PT'
   FwSetIdiom(self:locale)
Endif

If !Empty(cBody)
   If !GrvRecord(cBody, @cMsg,3 )
      oItem        			   := JsonObject():New() 
      oItem["type"] 	        := 'error'
      oItem["code"] 	        := "592"
      oItem["message"] 	        := STR0014
      oItem["detailedMessage"] 	:= cMsg
      
      cJson := FWJsonSerialize(oItem, .F., .F., .T.)
      Self:SetResponse(cJson)
   Else
      Self:SetResponse('{"ok": true, "message":"'+cMsg+'"}')
	EndIf
Else
   SetRestFault(500,STR0015) 
EndIf
FwSetIdiom(cIdiomBkp)

Return( lRet )


Static Function GetParams()
Local cQuery    as character
Local cAliasQry as character
Local cRet as Character
Local cError as Character
Local cBalances as Character
Local cCurrencies as Character
Local nX as Numeric
Local aGroups := FWSFAllGrps()
Local aUsers := FWSFALLUSERS(,{"USR_NOME"})
local cLookup
cAliasQry   :=  GetNextAlias()
cError      :=  ""
cRet        :=  ""
DbSelectArea('CT1')
DbSelectArea('CT2')
If (EMPTY(xFilial('CT1')) .and.!EMPTY(xFilial('CT2')<> ''))
    cRet += ',{"id":"00","description":"'+STR0009+'","entity":"SM0","codent":"","lookup":'+GetLookup("SM0","M0_CODFIL")+',"key":"M0_CODFIL","desc_field":"M0_FILIAL","father":""}' //"Branch"
Endif

cQuery := " SELECT * FROM "+RetSqlName('CT0')
cQuery += " WHERE "
cQuery += " CT0_FILIAL = '"+xFilial('CT0')+"' "
cQuery += " AND CT0_CONTR = '1' "
cQuery += " AND D_E_L_E_T_ = ' ' "
cQuery += " ORDER BY CT0_ID "

dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasQry,.T.,.F.)

dbSelectArea ( cAliasQry )

//carrega array static que vai ser utilizado na list box
While (cAliasQry)->( ! Eof() ) 
//CT0_FILIAL CT0_ID CT0_DESC                       CT0_CONTR CT0_ALIAS CT0_ENTIDA CT0_OBRIGA CT0_CPOSUP CT0_GRPSXG CT0_F3ENTI CT0_DSCRES CT0_CPOCHV CT0_CPODSC D_E_L_E_T_ R_E_C_N_O_           R_E_C_D_E_L_
//    cTmp := (CT0_ALIAS)
   IF empty(CT0_ENTIDA)
      cLookup := GetLookup(Alltrim(CT0_F3ENTI),CT0_CPOCHV)
   ELSE
      cLookup := GetLookup(Alltrim(CT0_F3ENTI)+ALLTRIM(CT0_ID),CT0_CPOCHV)
   ENDIF
    cRet += ',{"id":"'+Alltrim(CT0_ID)+'","description":"'+Alltrim(CT0_DESC)+'","entity":"'+CT0_ALIAS+'","codent":"'+CT0_ENTIDA+'","lookup":'+cLookup+',"key":"'+Alltrim(CT0_CPOCHV)+'","desc_field":"'+Alltrim(CT0_CPODSC)+'","father":"'+Alltrim(CT0_CPOSUP)+'"}'
    (cAliasQry)->( dbSkip() ) 
EndDo
dbSelectArea ( cAliasQry )
DbCloseArea()
DbSelectArea('CTO')
DbSetOrder(1)
DbSeek(xFilial())
cCurrencies:=""
While !EOF() .and. xFilial() == CTO_FILIAL
    cCurrencies +=  ',{"label":"'+Alltrim(CTO_SIMB)+'","value":"'+Alltrim(CTO_MOEDA)+'"}'
    DbSkip()
Enddo
DbSelectArea('SX5')
DbSetOrder(1)
DbSeek(xFilial()+"SL")
cBalances:=""
While !EOF() .and. xFilial() == X5_FILIAL .AND. X5_TABELA=='SL'
    cBalances +=  ',{"label":"'+Alltrim(StrTran(X5DESCRI(),chr(160)," "))+'","value":"'+Alltrim(X5_CHAVE)+'"}'
    DbSkip()
Enddo
cGroups := ""
For nX:=1 To Len(aGroups)
    cGroups +=  ',{"label":"'+Alltrim(aGroups[nX,4])+'","value":"'+Alltrim(aGroups[nX,2])+'"}'
Next
cUsers := ""
For nX:=1 To Len(aUsers)
    cUsers +=  ',{"label":"'+Alltrim(aUsers[nX,3])+'","value":"'+Alltrim(aUsers[nX,2])+'"}'
Next

If Len(cRet) > 0
    cRet := '{"status":200,'+;
           '"statusText":"success",'+;
           '"ok":true,'+;
           '"data": {"entitiesObj":['+Substr(cRet,2)+'],'+;
                    '"balanceTypes":['+Substr(cBalances,2)+'],'+;
                    '"users":['+Substr(cUsers,2)+'],'+;
                    '"groups":['+Substr(cGroups,2)+'],'+;
                    '"currencies":['+Substr(cCurrencies,2)+']'+;
           '}}'
Endif
Return cRet

Static Function GetLookup(cLookup,cReturn)
Local cRet     := ""
Local nX,nY
Local cTmp := ""
Static aLookups
cReturn := "datatmp"
If aLookups == Nil
    SetLookupData()
Endif

If (nX:= Ascan(aLookups,{|x| x[1] == cLookup})) > 0
    cRet := '{"lookup":"'+aLookups[nX,1]+'",'
    cRet +=  ' "returnto":"'+cReturn+'",'
    cRet +=  ' "return":"'+aLookups[nX,3]+'",'
    cTMP:=""
    For nY:=1 To Len(aLookups[nX,2])
        cTMP += ',{"property":"'+aLookups[nX,2,nY,1]+'","label":"'+aLookups[nX,2,nY,2]+'"}'
    Next
    cRet +='"columns":['+Substr(cTmp,2)+"],"
    cTMP:=""
    
    For nY:=1 To Len(aLookups[nX,4])
        cTMP += ',{"column":"'+aLookups[nX,4,nY]+'"}'
    Next
    cRet +='"show":['+Substr(cTmp,2)+"]}"
Endif
If Empty(cRet)
    cRet := "null"
Endif    
Return cRet

Static Function SetLookupData()
Local aArea := getArea()
Local aAreaSX3 := getArea()
Local aRet:={}
Local nX,nY
aLookups := {}
//Do not use NUMERIC FIELDS
AAdd(aLookups,{"SM0",{{"M0_CODFIL",STR0010},{"M0_FILIAL",STR0009}},"M0_CODFIL",{"M0_FILIAL"},'SM0',"M0_CODIGO = '"+cEmpAnt+"'"}) //"Branch Code"###"Branch"
AAdd(aLookups,{"CTO",{{"CTO_MOEDA",""},{"CTO_DESC",""},{"CTO_SIMB",""}},"CTO_MOEDA",{"CTO_DESC"},'CTO',""})
AAdd(aLookups,{"CT1",{{"CT1_CONTA",""},{"CT1_DESC01",""}},"CT1_CONTA",{"CT1_DESC01"},'CT1',""})
AAdd(aLookups,{"CTT",{{"CTT_CUSTO",""},{"CTT_DESC01",""}},"CTT_CUSTO",{"CTT_DESC01"},'CTT',""})
AAdd(aLookups,{"CTD",{{"CTD_ITEM",""},{"CTD_DESC01",""}},"CTD_ITEM",{"CTD_DESC01"},'CTD',""})
AAdd(aLookups,{"CTH",{{"CTH_CLVL",""},{"CTH_DESC01",""}},"CTH_CLVL",{"CTH_DESC01"},'CTH',""})

DbSelectArea('CT0')
DBsEToRDER(1)
If DbSeek( xFilial('CT0') + '05' )
	While CT0->(!Eof()) .And. CT0->CT0_FILIAL == xFilial('CT0')
		AAdd(aLookups,{"CV0"+CT0->CT0_ID,{{ALLTRIM(CT0->CT0_CPOCHV),""},{ALLTRIM(CT0->CT0_CPODSC),"",}},ALLTRIM(CT0->CT0_CPOCHV),{ALLTRIM(CT0->CT0_CPODSC)},CT0->CT0_ALIAS, iiF(CT0->CT0_ALIAS=='CV0',"CV0_PLANO='"+CT0->CT0_ID+"'","")})
		CT0->(DbSkip())
	EndDo
EndIf   
RestArea(aArea)
DbSelectArea('SX3')
aAreaSX3 := getArea()

SX3->(DbSetOrder(2))

aRet :=aLookups

For nX:=1 To Len(aRet)
   For nY:=1 To Len(aRet[nX,2])
      If SX3->(DbSeek(aRet[nX,2,nY,1]))
         aRet[nX,2,nY,2] := Alltrim(X3Descric())
      Endif
   Next
Next
restArea(aAreaSX3)
restArea(aArea)
Return aRet



Static Function GrvRecord(cBody,  cMsg, nExpOp,cPK )

//Local cJsonObj		:= "JsonObject():New()"
Local lRet			:= .T.
Local nX,nY
Local jFields
Local aModels     := {}
Local aStruct     := {}
Local aRecord     := {}
Local nOperation  := nExpOp
Local oModel := FwLoadModel("RU34S10B")
Private lMsHelpAuto := .T. //Variavel de controle interno do ExecAuto
Private lMsErroAuto := .F. //Variavel que informa a ocorrência de erros no ExecAuto
Private lAutoErrNoFile := .T.
Private aRotina :=   {}
Default cBody		:= ""
Default oItemDetail:= JsonObject():New() //&cJsonObj

oItemDetail:FromJson(cBody)
oItemDetail:HasProperty('models')

If nOperation <> 5 .and. (!oItemDetail:HasProperty('id') .Or. !oItemDetail:HasProperty('models') .Or. !oItemDetail:HasProperty('operation'))
   cMsg  := STR0017
   lRet  := .F.
ElseIf  nOperation <> 5 .and. oItemDetail['id'] <> "RU34S10B"
   cMsg  := STR0018+' ('+oItemDetail['id']+")" //Incorrect object ID
   lRet  := .F.
ElseIf  nOperation <> 5 .and.(oItemDetail['operation'] == 4 .or. oItemDetail['operation'] == 5) .And. (!oItemDetail:HasProperty('pk') .or. empty(oItemDetail['pk'] ) )
   cMsg  := STR0019 //"For POST verb Primary key (pk) is mandatory"
   lRet  := .F.
Else

   If nOperation <> 3
      cPK   := Decode64(cPk)

      SetCurrentBranch(Left(cPk,FwSizeFilial()))

      DbSelectArea('F61')
      DbSetOrder(1)
      If !DbSeek(cPK)
         lRet := .F.
         cMsg := STR0020 + '('+Alltrim(cPK)+')' //Record not found. PK 
      Endif
   Endif
   If lRet 
      //Automatic routine expects for data even on delete verb
      If nOperation == 5
         AADd(aModels,{'F61MASTER',{}})
         AADd(aModels[1,2],{'F61_UUID',F61->F61_UUID,NIL})
      Else
         jFields  := oItemDetail['models'][1]
         aAux  := GetColumns(oItemDetail['models'][1]['fields'])
         If nOperation == 4
            AAdd(aAux,{'F61_UUID',F61->F61_UUID})
         Endif            
         AADd(aModels,{jFields['id'],aAux})
         //Data is only needed for insert and update
         If (nOperation == 3 .Or.nOperation == 4) .and. jFields:HasProperty('models')
            For nX:=1 To Len(jFields['models'])
               aAux  := {}
               aStruct     := {}
               For nY:=1 To Len(jFields['models'][nX]['struct'])
                  AAdd(aStruct,{jFields['models'][nX]['struct'][nY]['id'],jFields['models'][nX]['struct'][nY]['order']})
               Next               
               For nY:=1 To Len(jFields['models'][nX]['items'])
                  AAdd(aAux,GetColumns(jFields['models'][nX]['items'][nY]['fields'],aStruct))
               Next               
               AADd(aModels,{jFields['models'][nx]['id'],aAux})
            Next
         Endif
      Endif
   Endif
   FreeObj(oItemDetail)

   If lRet
      For nX:=1 To Len(aModels)
         If (aModels[nX,1]=='F61MASTER')
            aRecord:= aModels[nX,2]
         Endif
      Next
      If lRet
         lMsErroAuto = .F.
 
 
         FWMVCRotAuto(oModel,"F61",nOperation,aModels)

                     
         If lMsErroAuto
            //cMsg :=MemoRead(NomeAutoLog())
            aMsg := oModel:getErrorMessage()
            cMsg := ""
            For nX:=1 to Len(aMsg)
               cMsg += Iif(aMsg[nX]<> Nil,aMsg[nX]+"\n","\n")
            Next
            lRet  := .F.
         Else
            cMsg:=   STR0021//"Operation succesfully accomplished"
         EndIf
      Endif  
   Endif    
Endif
cMsg := EncodeUTF8(cMsg)

Return lRet
Static Function GetColumns(oObj,aStruct)
Local aRet := {}
Local aAux := {}
Local nX
Local xValue
Default aStruct := {}
For nX:=1 To Len(oObj)
   nOrder:= 0
   If oObj[nX]:HasProperty('order')
      nOrder := oObj[nX]['order']
   ElseIf (nPosStru := Ascan(aStruct,{|x| x[1]==oObj[nX]['id']})) > 0      
      nOrder:= aStruct[nPosStru][2]
   Endif         
   aTamSX3  := TamSX3(oObj[nX]['id'])
   xValue   := ""
   If aTamSX3[3] == 'D'
      xValue := StrTran(oObj[nX]['value'],"-")  
      xValue := StrTran(xValue,"/")  
      xValue := StrTran(xValue,".")  
      xValue := Stod(xValue)
   ElseIf aTamSX3[3] == 'N'
      If Valtype(oObj[nX]['value'])<>"N"
         xValue   := Val(oObj[nX]['value'])
      Else
         xValue   := oObj[nX]['value']
      Endif
   ElseIf aTamSX3[3] == 'L' 
      xValue   := oObj[nX]['value']=='true'
   ElseIf aTamSX3[3] == 'C' 
    If oObj[nX]['value'] == Nil .And. oObj[nX]['id'] == 'F61_ACCESS'
        oObj[nX]['value'] := &(GetSX3Cache("F61_ACCESS", "X3_RELACAO"))
    EndIf
      xValue   := decodeutf8(oObj[nX]['value'])
      xValue   := Padr(xValue,aTamSX3[1])
   ElseIf aTamSX3[3] == 'M' 
      xValue   := decodeutf8(oObj[nX]['value'])
   Endif 
   AAdd(aAux,{oObj[nX]['id'],xValue,nOrder}) 
Next
aAux  := aSort(aAux,,,{|x,y| x[3]<=y[3]})
For nX:=1 To Len(aAux)
   AAdd(aRet,{aAux[nX,1],aAux[nX,2],Nil})
Next
Return aRet 


Static Function CTBS34(oParameters,oRest)
Local aDataIni	:= {}
Local aDataFim	:= {}
Local cArqTemp	:= ""   
Local nX		:= 0
Local nY		:= 0
Local nEntidade	:= 1
//Local aTam		:= TamSx3('CT2_VALOR')  
Local aEntidades  := {}
Local aEntdIni    := Array(9)
Local aEntdFim    := Array(9)
Local aFilters    := {}
Local aSelFil     := {}
Local nLevel      := Nil
//Local cBaseLevel  := If(oRest:baselevel == Nil,"",oRest:baselevel)
Local lFilLevel   := .F.
Local aDescrParent:= Array(10)
Local cAliasQry   := getNextAlias()
Local aMoedas     := {}
Local aBalType    := {}
Local nBalTypes
Local nCurrencies
Local cTotRet  := ""
Local cCurrency := ""
Local cBalance    := ""
Local cRetFilt := ""
Local nFilters 
Local cTMP1
Local nTMP1
Local cTMP2

aDescrParent := Afill(aDescrParent,'')
aEntdIni:=AFill(aEntdIni,Nil)
//aEntdFim:=AFill(aEntdFim,replicate(chr(254),20))
aEntdFim:=AFill(aEntdFim,Nil)
//aEntdFim:=AFill(aEntdFim,replicate('z',20))
cCodCubo := '01'
// Sets currency if requested by parameter
If oRest:currency <> Nil
   cCurrency := oRest:currency
Endif
// Sets balance type if requested by parameter
If oRest:balance <> Nil
   cBalance := oRest:balance
Endif

// Qhen is DrillDown, each previous level will be informed as parameter, they are set as FROM/TO parameters
For nX:=1 To 9
   cLevelFilter := &('oRest:Level'+Alltrim(Str(nX)))
   If cLevelFilter <> "*" .And. cLevelFilter <> nil
      aEntdIni[nX]:= cLevelFilter
      aEntdFim[nX]:= cLevelFilter
   Endif
Next 

// Load balance Types requested on general parametrization
For nX:= 1 TO Len(oparameters["parameters"]["balanceType"]["selected"])
   Aadd(aBalType,oparameters["parameters"]["balanceType"]["selected"][nX])
Next   
//Load currencies requested requested on general parametrization
For nX:= 1 TO Len(oparameters["parameters"]["currency"]["selected"])
   Aadd(aMoedas,oparameters["parameters"]["currency"]["selected"][nX])
Next   


// Transforms dates to ADVPL syntax
AADD(aDataIni,Ctod('01/01/1980'))		// Initial                                             
AADD(aDataFim,Stod(StrTran(oparameters["parameters"]["dateFrom"],"-"))-1)		// Initial                                             
AADD(aDataIni,Stod(StrTran(oparameters["parameters"]["dateFrom"],"-")))		// Initial                                             
AADD(aDataFim,Stod(StrTran(oparameters["parameters"]["dateTo"],"-")))		// Final

aFilters := {}

// Load all entities needed, defined in general report parameters.
// Regardless if they are defined as filters or as drilldown entities, they will be used as filters
// The cube level is defined by higher entity level
For nX:=1 To Len(oparameters["filterEntities"])
   AAdd(aEntidades,{"F",oparameters["filterEntities"][nX]["value"]})
   cCodCubo := Iif(oparameters["filterEntities"][nX]["value"]>cCodCubo,oparameters["filterEntities"][nX]["value"],cCodCubo)
Next
lNext := .F.
For nX:=1 To Len(oparameters["drillDown"])
   AAdd(aEntidades,{"D",oparameters["drillDown"][nX]["value"]})
   cCodCubo := Iif(oparameters["drillDown"][nX]["value"]>cCodCubo,oparameters["drillDown"][nX]["value"],cCodCubo)
   cLastEntity:=oparameters["drillDown"][nX]["value"]
Next
// If baselevel is received as parameter (this is used for Drill down when using on demand option) defines level that should be returned, if not defines first Drildown entity as baselevel
If oRest:baselevel == nil
   nPosIni:= Ascan(aEntidades,{|x| x[1]=='D'})
   nLevel := Val(aEntidades[nPosIni][2])
Else
   nPosAnt:= Ascan(aEntidades,{|x| x[2]==oRest:baselevel})
   If nPosAnt < Len(aEntidades)
      nLevel := Val(aEntidades[nPosAnt+1][2])
   Else
      //Should not enter here, this means is already on last level (or use this to get CT2)
      nLevel := Val(aEntidades[nPosAnt][2])
   Endif      
Endif

// If base level is zero, means that it is BRANCH (not officially a level in CUBES), so lFilLevel is defined for Branch specific treatments
If nLevel == 0
   nLevel := 1
   lFilLevel := .T.
Endif   

// Builds filter expressions that will be sent to the cube
For nX:=1 To Len(oparameters["filters"])
   cFilter  := ""
   iF oparameters["filters"][nX]['entity'] == "00"
      cField   := "M0_CODFIL "
   ELSE
      dbSelectArea('CT0')
      DBsEToRDER(1)
      dBSEEK(xFilial()+ oparameters["filters"][nX]['entity'] )
      cField   := CT0->CT0_CPOCHV + " "
   ENDIF      
   For nY:=1 To Len(oparameters["filters"][nX]['filter'])

      If oparameters["filters"][nX]['filter'][nY]["type"] == "1"
         If 'between' $ oparameters["filters"][nX]['filter'][nY]["code"]
            cTMP1 := DecodeUTF8(MYDECODE(decode64(oparameters["filters"][nX]['filter'][nY]["value1"])))
            cTMP2 := DecodeUTF8(MYDECODE(decode64(oparameters["filters"][nX]['filter'][nY]["value2"])))
            cFilter += " "+cField+oparameters["filters"][nX]['filter'][nY]["code"]+ " '"+NullValue(cTmp1)+"' AND '"+NullValue(cTmp2)+"' "
            nTmp1 := val(oparameters["filters"][nX]['entity'] )           
            If nTmp1 > 0 .and. 'between' == oparameters["filters"][nX]['filter'][nY]["code"]
               cLevelFilter := &('oRest:Level'+Alltrim(Str(nX-1)))
               If cLevelFilter == "*" .Or. cLevelFilter == nil
                  aEntdIni[nTmp1] := Iif(aEntdIni[nTmp1] == Nil, cTmp1, MinValue(aEntdIni[nTmp1],cTmp1))
                  aEntdFim[nTmp1] := Iif(aEntdFim[nTmp1] == Nil, cTmp2, MaxValue(aEntdFim[nTmp1],cTmp2))
               Endif
            Endif               
         Else
            cTMP1 := DecodeUTF8(MYDECODE(decode64(oparameters["filters"][nX]['filter'][nY]["value1"])))
            cFilter += " "+cField+oparameters["filters"][nX]['filter'][nY]["code"]+ " '"+NullValue(cTmp1)+"' "
            nTmp1 := val(oparameters["filters"][nX]['entity'] )           
            If nTmp1 > 0 
               cLevelFilter := &('oRest:Level'+Alltrim(Str(nX-1)))
               If cLevelFilter == "*" .Or. cLevelFilter == nil
                  If (oparameters["filters"][nX]['filter'][nY]["code"]  == '=' .Or. oparameters["filters"][nX]['filter'][nY]["code"]  == '>=')
                     aEntdIni[nTmp1] := Iif(aEntdIni[nTmp1] == Nil, cTmp1, MinValue(aEntdIni[nTmp1],cTmp1))
                  Endif
                  If (oparameters["filters"][nX]['filter'][nY]["code"]  == '=' .Or. oparameters["filters"][nX]['filter'][nY]["code"]  == '<=')
                     aEntdFim[nTmp1] := Iif(aEntdFim[nTmp1] == Nil, cTmp1, MaxValue(aEntdFim[nTmp1],cTmp1))
                  Endif
               Endif
            Endif               
         Endif
      Else
         cFilter += " "+oparameters["filters"][nX]['filter'][nY]["code"]+"  "
      Endif
   Next
   aadd(aFilters,{oparameters["filters"][nX]["entity"],Substr(cFilter,1)})

   If oparameters["filters"][nX]["entity"] <> "00"
      If aEntdIni[Val(oparameters["filters"][nX]["entity"])] == aEntdFim[Val(oparameters["filters"][nX]["entity"])]
         aFilters[Len(aFilters),2] += " AND "+cField+" = '"+aEntdFim[Val(oparameters["filters"][nX]["entity"])]+"' "
      Endif
   Endif
Next
For nX:=1 To Len(aEntdIni)
   If(aEntdIni[nX]==Nil)
      aEntdIni[nX]   := ''
   Endif
Next
For nX:=1 To Len(aEntdFim)
   If(aEntdFim[nX]==Nil)
      aEntdFim[nX]   := Replicate(chr(255),20)
      //aEntdFim[nX]   := Replicate('z',20)
   Endif
Next

// If branches are on the filters, then filter is defined by aSelFil parameter sent to cube
// TODO: Check how to send current branch to FWCALLAPP
// If aSelFil is empty, will be used current branch 
If (nPosFilial := Ascan(aFilters,{|x| x[1]=="00"})) > 0
   cQuery   := " SELECT M0_CODFIL FROM SYS_COMPANY WHERE D_E_L_E_T_= '' AND M0_CODIGO = '"+cEmpAnt+"' AND ("+aFilters[nPosFilial][2]+")"
   cQuery   := ChangeQuery(cQuery)
   dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasQry,.T.,.F.)
   dbSelectArea ( cAliasQry )

   //carrega array static que vai ser utilizado na list box
   While (cAliasQry)->( ! Eof() ) 
      aadd(aSelFil,Alltrim((cAliasQry)->M0_CODFIL))
      (cAliasQry)->( dbSkip() ) 
   EndDo
   dbSelectArea ( cAliasQry )
   DbCloseArea()
Else
   aSelFil := {cFilAnt}
Endif

// Search for level definitions
cNivRet := StrZero(nLevel,2)

//nEntidade := 3
//cCodCubo := '03'
nEntidade:= Val(cCodCubo)
/*

For nX:=1 To Len(aEntidades)
   If (aEntidades[nX,1]=='D') .And. aEntidades[nX,2] < cNivRet 
      DbSelectArea('CT0')
      DBsEToRDER(1)
      If DbSeek( xFilial('CT0') + cNivRet )

   Endif
Next
*/
DbSelectArea('CT0')
DBsEToRDER(1)

If DbSeek( xFilial('CT0') + cNivRet )
Endif

// Starts loop for all currencies on general parametrization 
For nCurrencies := 1 To Len(aMoedas)
   cMoeda   := aMoedas[nCurrencies]
   // If particular currency requested, then only this currency is evaluated
   If cCurrency == '' .Or. cMoeda == cCurrency
      // Starts loop for all balance types on general parametrization 
      For nBalTypes := 1 To Len(aBalType)
         cTpSald  := aBalType[nBalTypes]
         // If particular balance type requested, then only this balance type is evaluated
         If cBalance == '' .Or. cTpSald ==  cBalance
            oObjCubo := Ctb_Exec_Cube():New(cCodCubo,cMoeda,cTpSald,nEntidade,Len(aDataFim))
            oObjCubo:lZerado := .T.
            //  Add fields to cube that will be used for particular data to be returned to service not present in standard cube
            AAdd(oObjCubo:oStructCube:aStructCVX, {'ENTPARENT','C',_NSIZEENT,0})
            AAdd(oObjCubo:oStructCube:aStructCVX, {'LEVEL' ,'N',2,0})
            AAdd(oObjCubo:oStructCube:aStructCVX, {'NORMAL','C',1,0})
            AAdd(oObjCubo:oStructCube:aStructCVX, {'CLASSE','C',1,0})
            AAdd(oObjCubo:oStructCube:aStructCVX, {'DESCR' ,'C',60,0})
            AAdd(oObjCubo:oStructCube:aStructCVX, {'NIVRET','C',2,0})
            
            //For turnovers, balances should be kept on column where they happened, for final and initial balances, 
            //they should 
            For nX:=1 to Len(aDataFim)
               AAdd(oObjCubo:oStructCube:aStructCVX, {'SLCRTO_'+StrZero(nX,2),'N',18,2})
               AAdd(oObjCubo:oStructCube:aStructCVX, {'SLDBTO_'+StrZero(nX,2),'N',18,2})
            Next
            For nX:=1 to Len(aEntidades)   
               AAdd(oObjCubo:oStructCube:aStructCVX, {'PARENT'+aEntidades[nX,2],'C',_NSIZEENT,0})
            Next               
            For nX:=1 to Len(aEntidades)   
               AAdd(oObjCubo:oStructCube:aStructCVX, {'DESCR'+aEntidades[nX,2],'C',60,0})
            Next               
            For nX:=1 to Len(aEntidades)   
               AAdd(oObjCubo:oStructCube:aStructCVX, {'LEVEL'+aEntidades[nX,2],'N',2,0})
            Next     
            For nX:=1 to Len(aEntidades)   
               AAdd(oObjCubo:oStructCube:aStructCVX, {'CLASSE'+aEntidades[nX,2],'C',1,0})
            Next              
            For nX:=1 to Len(aEntidades)   
               AAdd(oObjCubo:oStructCube:aStructCVX, {'NORMAL'+aEntidades[nX,2],'C',1,0})
            Next              
            
            // Switches on AUTORECNO before creating temporary table, so INSERT commands can be executed in groups and not need to worry about R_E_C_N_O_
            TcInternal(30,"AUTORECNO") 
            cArqTemp :=  oObjCubo:CtbCriaTemp() 
            // Turn OFF AUTORECNO
            TcInternal(30,"OFF") 
                                                         
            /*For nY:=1 To nEntidade
               oObjCubo:Set_Level_Cube(nY)

               oObjCubo:oStructCube:Ctb_Set_IniParam(nY, aEntdIni[nY])         
               oObjCubo:oStructCube:Ctb_Set_FimParam(nY, aEntdFim[nY])			

               oObjCubo:CtbCriaQueryDim()
            Next nY	
            */
            // Sets filter expressions for each cube level, and FROM/TO expressions in case they were received as parameters
            For nY:=1 To Len(aEntidades)
               //TODO: Check levels
               If aEntidades[nY,2] <> '00'
                  nLevelCube := Val(aEntidades[nY,2])
                  oObjCubo:Set_Level_Cube(nLevelCube)
                  If !Empty(aEntdFim[nLevelCube])
                     oObjCubo:oStructCube:Ctb_Set_IniParam(nLevelCube, aEntdIni[nLevelCube])         
                     oObjCubo:oStructCube:Ctb_Set_FimParam(nLevelCube, aEntdFim[nLevelCube])			
                     oObjCubo:oStructCube:aVazio[nLevelCube] := Empty(aEntdIni[nLevelCube]) 
                  //If filtering empty entity, set this FALSE condition to force UNION Blank inside cube
                  ElseIf aEntdFim[nLevelCube] <> ''
                     oObjCubo:oStructCube:Ctb_Set_IniParam(nLevelCube, '2')         
                     oObjCubo:oStructCube:Ctb_Set_FimParam(nLevelCube, '1')			
                     oObjCubo:oStructCube:aVazio[nLevelCube] := .T.
                  Endif

                  nPosFilter := Ascan(aFilters,{|x| x[1]==aEntidades[nY,2]})
                  If nPosFilter > 0
                     oObjCubo:oStructCube:aFiltros[nLevelCube] := aFilters[nPosFilter,2]
                  Endif         
/*                  aQ := oObjCubo:CtbCriaQueryDim()
                  Conout(varinfo('aq',aq))
                  */
               Endif
            Next nY	
            // Sets Querys for cube (from '' to 'zzz'), for CUBE levels not included in current report (needed by cube stantard setup)
            For nX:=1 To Len(oObjCubo:aQueryDim)
               If oObjCubo:aQueryDim[nX] == Nil
                  oObjCubo:Set_Level_Cube(nX)
                  oObjCubo:oStructCube:Ctb_Set_IniParam(nX, aEntdIni[nX])         
                  oObjCubo:oStructCube:Ctb_Set_FimParam(nX, aEntdFim[nX])	
                  If Empty(aEntdIni[nX])
                     oObjCubo:oStructCube:aVazio[nX] := .T.
                  Endif
                  oObjCubo:CtbCriaQueryDim()
               Endif
            Next
            // nLevel defines totalizader level
            
            // lAllLevels = true generates all levels for the cube
            // lAllLevels = false generates only base level requested (used on OnDemand option)
            
            lAllLevels  := Len(oparameters["parameters"]["onDemandCheck"]["selected"]) == 0
            oObjCubo:Set_Level_Cube(nLevel) 
            oObjCubo:Set_aSelFil(aSelFil) 
                                                
            oObjCubo:CtbCriaQry(.F./*lMoviments*/, aDataIni, aDataFim, cArqTemp, lAllLevels, .F./* lFechamento*/)

            oObjCubo:CtbPopulaTemp(cArqTemp)
            cNivRet := StrZero(nLevel,2)
            cTotRet += GetData(oRest,cArqTemp,cNivRet,lFilLevel,aDataFim,aEntdIni,lAllLevels,aEntidades,oParameters)
            cRetFilt := ""
            For nFilters := 1 To Len(aFilters)
               cRetFilt += ',{"'+aFilters[nFilters,1]+'":"'+aFilters[nFilters,2]+'"}'
            NExt
         Endif
      Next
   Endif
Next   

Conout(STR0011) //'RU34S10 Service finished'
cJson := '{"data":['+SUBSTR(cTotRet,2)+'],"parsedFilters":['+substr(cRetFilt,2)+"]}"
Return cJson //"["+SUBSTR(cTotRet,2)+"]"


/*/{Protheus.doc} MinValue and MaxValue
(Static function for compare parameters)
@type  Static Function
@author ilomonosov
@since date
/*/
Static Function MaxValue(cMax,cTmp1)
Return IIF(cMax >= cTmp1, cMax, cTmp1)

Static Function MinValue(cMin,cTmp1)
Return IIF(cMin < cTmp1, cMin, cTmp1)


Static Function NullValue(cValue)
Return IIF(cValue == Nil, "",cValue)
//Static Function UPPEREntitites(oObj)


Function GetData(oRest,cArqTemp,cNivRet,lFilLevel,aDataFim,aEntdIni,lAllLevels,aEntidades,oParameters)
Local cQueryQty
Local cQuery      := ""
Local nTmpLevel
Local cTmpFil     := ""
Local lFinished   := .F.
Local nX,nZ,nY,nQ
Local nIndent     := 0
Local aParents    := {}
Local cParent     := If(oRest:parent == Nil,"",oRest:parent)
Local cIndent     := If(oRest:indent == Nil,"",oRest:indent)
Local cEntity     := ""
Local cKey        := ""
Local cParentKey  := ""
Local nPosPar     := 0
Local cAliasQry   :=  GetNextAlias()
Local cBranchParent:=""
Local aEntRet     := {}
Local nEntity
Local nTmp
Local cExpanded := ""
If lAllLevels
   For nX:=1 to len(aEntidades)
      if (aEntidades[nx][1]=='D')
         aadd(aEntRet, aEntidades[nX])
      endif
   next
Else
   aEntRet  := {{"D",cNivRet}}
Endif   

// Checks if this cube has Branch as parent
If oRest:Level0 <> Nil
   cBranchParent := oRest:Level0
Endif

DbSelectArea('CT0')
DBsEToRDER(1)

If DbSeek( xFilial('CT0') + cNivRet )

Else
   // ERRO DE CONFIGURACAO
EndIf   

cTmpFil := xFilial(_CCUBEALIAS)

// INSERTS  all superior accounts, because standard cube only generates analytic accounts
// Updates descriptions
If  lAllLevels
   UpdDescr(aEntidades,cArqTemp,cTmpFil)
   InsertSup(aEntidades,cArqTemp,cTmpFil,lAllLevels,aDatafim)
   UpdDescr(aEntidades,cArqTemp,cTmpFil)
ElseIf !lFilLevel
   UpdDescr(aEntidades,cArqTemp,cTmpFil)
   InsertSup(aEntRet,cArqTemp,cTmpFil,lAllLevels,aDatafim)
   UpdDescr(aEntRet,cArqTemp,cTmpFIl)
Endif


// Update CRED AND DEB SUMMARIZED
//IF !lFilLevel
/*
For nZ:=1 To Len(aEntRet)
   cQuery := " UPDATE  "+cArqTemp+ " SET "
   For nX:=1 to Len(aDataFim)
      cQuery += " SUMDEB_"+StrZero(nX,2) +' = CASE NORMAL'+aEntRet[nZ,2]
      cQuery += " WHEN '1' THEN (CVX_SLDB"+StrZero(nX,2)+ " - CVX_SLCR"+StrZero(nX,2)+ ") "
      cQuery += " WHEN '2' THEN (0) "
      cQuery += " WHEN ' ' THEN (CVX_SLDB"+StrZero(nX,2)+ ") "
      cQuery += " END, "
      cQuery += " SUMCRD_"+StrZero(nX,2) +' = CASE NORMAL'+aEntRet[nZ,2]
      cQuery += " WHEN '1' THEN (0) "
      cQuery += " WHEN '2' THEN (CVX_SLCR"+StrZero(nX,2)+ " - CVX_SLDB"+StrZero(nX,2)+ ") "
      cQuery += " WHEN ' ' THEN (CVX_SLCR"+StrZero(nX,2)+ ") "
      cQuery += " END, "
   Next
   cQuery := Substr(Alltrim(cQuery),1,Len(Alltrim(cQuery))-1)
   tcSqlexec(cQuery)
Next
*/
// Set Levels according to SUPERIOR accounts
If !lAllLevels
   For nZ := 1 to Len(aEntRet)
      tcSqlexec('UPDATE '+cArqTemp+ " SET LEVEL"+aEntRet[nZ,2]+" = CASE PARENT"+cNivRet+" WHEN '' THEN 0 ELSE 99 END")
      nTmpLevel := 0
      lFinished := (lFilLevel .Or. aEntRet[nZ,2] == '00')
      While !lFinished
         cQueryQty   := " SELECT CVX_NIV"+aEntRet[nZ,2]+" ENTITY FROM  "+cArqTemp+ "  WHERE CVX_NIV"+aEntRet[nZ,2]+" <> '' AND CLASSE"+aEntRet[nZ,2]+"  = '1' AND LEVEL"+aEntRet[nZ,2]+" =  "+Str(nTmpLevel)
         If lAllLevels
            cQueryQty   += " AND CVX_NIV"+aEntRet[nZ,2]+" <> '' "
            //cQueryQty   += " AND CVX_CONFIG = '"+cNivRet+"' "
         Endif
         cQueryQty   := ChangeQuery(cQueryQty)
         dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQueryQty),cAliasQry,.T.,.F.)
         dbSelectArea ( cAliasQry )
         lFinished := (cAliasQry)->(EOF())
         While !(cAliasQry)->(EOF()) 
         
            // tcSqlexec('UPDATE '+cArqTemp+ " SET LEVEL = "+Str(nTmpLevel+1)+ " WHERE  ENTPARENT = '"+(cAliasQry)->ENTITY+ "' AND CVX_CONFIG = '"+cNivRet+"' ")
            tcSqlexec('UPDATE '+cArqTemp+ " SET LEVEL"+aEntRet[nZ,2]+" = "+Str(nTmpLevel+1)+ " WHERE  PARENT"+aEntRet[nZ,2]+" = '"+(cAliasQry)->ENTITY+ "'"+ iif(lAllLevels," AND CVX_NIV"+aEntRet[nZ,2]+" <> '' ",""))
            (cAliasQry)->(DBSKIP()) 
         Enddo
         DbSelectArea(cAliasQry)
         DbCloseArea()
         nTmpLevel++
      Enddo
      cUpd99 := "UPDATE "+cArqTemp+ " SET LEVEL"+aEntRet[nZ,2]+" = B.NEWLEVEL+1 "
      cUpd99 += " FROM " 
      cUpd99 += " (SELECT MAX(TMP2.LEVEL"+aEntRet[nZ,2]+") AS  NEWLEVEL "
      cUpd99 += " FROM  "+cArqTemp+ " UPD, "+cArqTemp+ " TMP2 "
      cUpd99 += " WHERE  UPD.PARENT"+aEntRet[nZ,2]+" = TMP2.CVX_NIV"+aEntRet[nZ,2]+" "
      cUpd99 += " ) AS B "

      cUpd99 += " WHERE LEVEL"+aEntRet[nZ,2]+" = 99 "
      tcSqlexec(cUpd99)
   Next nZ

Endif
// Define levels that should be returned expanded
if lAllLevels
   For nZ := 1 to Len(aEntRet)
      If aEntRet[nZ,2] == oparameters["parameters"]["onDemand"]["selected"]
         Exit
      Endif
      cExpanded   += aEntRet[nZ,2]+"/"
   Next
Endif

aParents    := getParentsKey(cArqTemp,aEntRet)
cRet := ""
For nEntity := 1 To Len(aEntRet)
   // Queries CUBE created
   If aEntRet[nEntity,1] == 'D'
      cNivRet     := aEntRet[nEntity,2]
      DbSelectArea('CT0')
      DBsEToRDER(1)
      If DbSeek( xFilial('CT0') + cNivRet )

      Else
         // ERRO DE CONFIGURACAO
      EndIf   

      nPosParent  := AScan(aParents,{|x| x[1]==cNivRet})
      lFilLevel   := (aEntRet[nEntity,2] == '00')
      If !lFilLevel
         cQuery   := " SELECT CVX_NIV"+cNivRet+" entity, LEVEL"+cNivRet+" LEVEL, PARENT"+cNivRet+", CVX_TPSALD, CVX_CONFIG , DESCR"+cNivRet+" DESCR, CLASSE"+cNivRet+" CLASSE, NORMAL"+cNivRet+" NORMAL "
      Else
         cNivRet  := '00'
         cQuery   := " SELECT CVX_FILIAL entity, PARENT"+cNivRet+", LEVEL"+cNivRet+" LEVEL, CVX_TPSALD, CVX_CONFIG , DESCR"+cNivRet+" DESCR, '1' CLASSE, ' ' NORMAL " 
      Endif
      For nQ := 1 To (nEntity-1)
         If aEntRet[nQ,2] == '00'
            cQuery += ", CVX_FILIAL"
         Else
            cQuery += ", CVX_NIV"+aEntRet[nQ,2]
         Endif
      Next
      /*If (nPosFil := Ascan(aEntidades,{|x| x[2]=="00"})) == 0 .Or. aEntidades[nPosFil,1] == "F"
         cQuery += ", CVX_FILIAL "
      Endif*/
      For nX:=1 to Len(aDataFim)
         cQuery += ", Sum(CVX_SLCR"+StrZero(nX,2)+") CVX_SLCR"+StrZero(nX,2)
         cQuery += ", Sum(CVX_SLDB"+StrZero(nX,2)+") CVX_SLDB"+StrZero(nX,2)
         cQuery += ", Sum(CVX_SALD"+StrZero(nX,2)+") CVX_SALD"+StrZero(nX,2)
         cQuery += ", Sum(SLCRTO_"+StrZero(nX,2)+") SLCRTO_"+StrZero(nX,2)
         cQuery += ", Sum(SLDBTO_"+StrZero(nX,2)+") SLDBTO_"+StrZero(nX,2)
      Next
      cQuery += " FROM "+ cArqTemp + " "
      cQuery += " WHERE " //CVX_NIV"+cNivRet+" <> '' "
      cQuery += " NIVRET IN ('', '"+cNivRet+" ') "
      /*      
      If lAllLevels
         cTmpEmp:=""
         For nX:= 1 to  nEntity
            If aEntRet[nX,2] == "00"
      //            cTmpEmp += ", CVX_FILIAL"
            Else            
               cTmpEmp += " OR CVX_NIV"+aEntRet[nX,2] + " <> '' "
            Endif
         Next
         If cTmpEmp
      */
     // Endif
      // If the branches are on the filter and not on drillDown, need to group ignoring branch
      iF lFilLevel
         cQuery += " GROUP BY CVX_FILIAL, CVX_TPSALD, LEVEL"+cNivRet+", PARENT"+cNivRet+", CVX_CONFIG,DESCR"+cNivRet+" , CLASSE"+cNivRet+" , NORMAL"+cNivRet
      Else
         cQuery += " GROUP BY CVX_NIV"+cNivRet+", CVX_TPSALD, LEVEL"+cNivRet+", PARENT"+cNivRet+", CVX_CONFIG,  DESCR"+cNivRet+", CLASSE"+cNivRet+" , NORMAL"+cNivRet
      Endif 
      For nQ := 1 To (nEntity-1)
         If aEntRet[nQ,2] == '00'
            cQuery += ", CVX_FILIAL"
         Else
            cQuery += ", CVX_NIV"+aEntRet[nQ,2]
         Endif
      Next
      cQuery += " ORDER BY "
      For nX:= 1 to  nEntity
         If aEntRet[nX,2] == "00"
            cQuery += " CVX_FILIAL,"
         Else
            cQuery += " CVX_NIV"+aEntRet[nX,2] + ","
         Endif
      Next
      cQuery := Substr(cQuery,1,Len(cQuery)-1)
      cQuery   := ChangeQuery(cQuery)
      dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasQry,.T.,.F.)
      dbSelectArea ( cAliasQry )
      nIndent := IIf(empty(cIndent),0,Val(cIndent))
      //Add escaped character lost (escaped) in QueryParams
      cParent := StrTran(cParent,'\','\\')
      nX := 1

      dbSelectArea( cAliasQry )
      While (cAliasQry)->( ! Eof() ) 
         nX++
         If !Empty((cAliasQry)->entity)
            cEntity := alltrim(entity)+"-"+alltrim(descr)
            cEntity := StrTran(cEntity,'"','\"')
         Else
            cEntity := STR0022 //"Undefined"
         Endif
         //+Alltrim(cMoeda)+Alltrim(CVX_TPSALD)+
         cParentKey := ""
         nPosPar := 0
         cParTMP := (cAliasQry)->&("PARENT"+cNivRet)  
         cKey     := ""
         // Key and parent key can be set in two diferent ways:
         // 1-If not ondemand (returning all levels) can be simplified because are managed on DXTree object on report visualization
         // 2-If ondemand must be created with the full path to the root, becuase is manually managed by DXData object
         If lAllLevels
            //Adds all previous levels to the key
            For nTmp := 1 to nEntity-1
               If(aEntRet[nTmp,2] <> "00")
                  cParentKey += aEntRet[nTmp,2]+Alltrim(&("CVX_NIV"+aEntRet[nTmp,2]))+Alltrim(cMoeda)+Alltrim(CVX_TPSALD)  
               Else
                  cParentKey += aEntRet[nTmp,2]+Alltrim(CVX_FILIAL)+Alltrim(cMoeda)+Alltrim(CVX_TPSALD)  
               Endif
            Next
            cKey := cParentKey + cNivRet+Alltrim(entity)+Alltrim(cMoeda)+Alltrim(CVX_TPSALD)
            //Adds Summarizing entity to the key
            If !Empty(cParTMP)
               nPosPar := Ascan(aParents[nPosParent][2],{|x| x[1]==cParTMP})
               If nPosPar > 0
                  cParentKey += cNivRet+Alltrim(aParents[nPosParent][2][nPosPar,1])+Alltrim(cMoeda)+Alltrim(CVX_TPSALD) 
               Endif                     
            Endif
         Else
            If !Empty(cParTMP) .and. nPosParent > 0
               nPosPar := Ascan(aParents[nPosParent][2],{|x| x[1]==cParTMP})
               cParentKey := cNivRet+Padr(Alltrim(cParTMP),_NSIZEENT)+Alltrim(cMoeda)+Alltrim(CVX_TPSALD)   + IIf(empty(cParentKey),"","\\"+cParentKey)
               For nY:= Len(aParents[nPosParent][2][nPosPar,2]) to 1 STEP -1
                  cParentKey := cNivRet+Padr(Alltrim(aParents[nPosParent][2][nPosPar,2,nY]),_NSIZEENT)+Alltrim(cMoeda)+Alltrim(CVX_TPSALD)   + IIf(empty(cParentKey),"","\\"+cParentKey)
               Next
               If !Empty(cParent)
                  cParentKey := cParent +IIF(empty(cParentKey),"","\\"+cParentKey)
               Endif
            Elseif(!Empty(cParent))
               cParentKey  := Iif(!Empty(cParent),cParent, cNivRet+Replicate(" ",_NSIZEENT)+Alltrim(cMoeda)+Alltrim(CVX_TPSALD))
            Endif
            cKey        := iif(Empty(cParentKey),"",cParentKey+"\\")+cNivRet+Padr(Alltrim(entity),_NSIZEENT)+Alltrim(cMoeda)+Alltrim(CVX_TPSALD)
         Endif
         cRet += ',{"entity":"'+cEntity+'",'+;
                  '"parent_entity":"'+Alltrim(cParTMP)+'",'+;
                  '"parent_key":"'+cParentKey+'",'+;
                  '"key":"'+cKey+'",'+;
                  '"level":"'+cNivRet+'",'+;
                  '"class":"'+iif((cAliasQry)->CLASSE  == '1' , '1' ,'2')+'",'+;
                  '"type":"'+Alltrim(NORMAL)+'",'+;
                  '"baltype":"'+Alltrim(CVX_TPSALD)+'",'+;
                  '"currency":"'+Alltrim(cMoeda)+'",'+;
                  '"level":"'+cNivRet+'",'+;
                  '"level00":"'+If(cNivRet=='00',alltrim(entity),IIF(cBranchParent=="","*",cBranchParent))+'",'
         If lAllLevels               
            cLevelParent := ''
            If nEntity > 1
               cLevelParent := aEntRet[nEntity-1,2]
            Endif
            cRet  += '"level_parent":"'+cLevelParent+'",'
            //If parentKey is expanded
            If cNivRet $ cExpanded //Empty(cLevelParent) .Or
               cRet += '"expanded":1,'
            Else
               cRet += '"expanded":'+iif((cAliasQry)->CLASSE  == '1' , '1' ,iif(cLastEntity==cNivRet .and. (cAliasQry)->CLASSE  $ ' 2','0','-1'))+','
            Endif
            cRet += '"hasnext":'+iif((cAliasQry)->CLASSE == '1' .Or. cLastEntity!=cNivRet , 'true' ,'false')+','
            For nZ:=1 to Len(aEntRet)
               If nZ<=nEntity
                  //cRet += '"level'+aEntRet[nZ,2]+'":"'+If(cNivRet==aEntRet[nZ,2],alltrim(entity),IIf(Empty(&("CVX_NIV"+aEntRet[nZ,2])),"*",&("CVX_NIV"+aEntRet[nZ,2])))+'",'
                  If(aEntRet[nZ,2] <> "00" .OR. cNivRet==aEntRet[nZ,2] )
                     cRet += '"level'+aEntRet[nZ,2]+'":"'+If(cNivRet==aEntRet[nZ,2],alltrim(entity),&("CVX_NIV"+aEntRet[nZ,2]))+'",'
                  Else
                     cRet += '"level'+aEntRet[nZ,2]+'":"'+CVX_FILIAL+'",'
                  Endif
               Else
                  cRet += '"level'+aEntRet[nZ,2]+'":"*",'
               Endif
            Next               
         Else
            cRet += '"expanded":'+iif((cAliasQry)->CLASSE  == '1' , '1' ,iif(cLastEntity==cNivRet .and. (cAliasQry)->CLASSE  $ ' 2','0','-1'))+','
            cRet += '"indent":'+Alltrim(Str(nIndent+(cAliasQry)->level))+','
            For nZ:=1 to 9
               cLevel := &("oRest:level"+Alltrim(Str(nZ)))
               cRet += '"level'+StrZero(nZ,2)+'":"'+If(cNivRet==StrZero(nZ,2),alltrim(entity),IIf(cLevel==Nil,"*",cLevel))+'",'
               //   cRet += '"level'+StrZero(nZ,2)+'":"'+If(cNivRet==StrZero(nZ,2),alltrim(entity),IIf(aEntdIni[nZ]=="","*",aEntdIni[nZ]))+'",'
            Next               
         Endif
         cNormal := NORMAL
         nDebStart   := (CVX_SLDB01)
         nDebFinish  := (CVX_SLDB02)
         nCredStart   := (CVX_SLCR01)
         nCredFinish    := (CVX_SLCR02)
         nStartBalance  := CVX_SALD01
         nFinishBalance := CVX_SALD02
         nSumDebStart    := nDebStart
         nSumDebFinish   := nDebFinish
         nSumCredStart   := nCredStart
         nSumCredFinish  := nCredFinish

         If cNormal == '1'
            nSumDebStart    := (CVX_SLDB01 - CVX_SLCR01)
            nSumDebFinish   := (CVX_SLDB02 - CVX_SLCR02)
            nSumCredStart   := 0
            nSumCredFinish  := 0
         ElseIf cNormal == '2'
            nSumDebStart    := 0
            nSumDebFinish   := 0
            nSumCredStart   := (CVX_SLCR01 - CVX_SLDB01)
            nSumCredFinish  := (CVX_SLCR02 - CVX_SLDB02)
         Endif
         If ((cAliasQry)->CLASSE !="1")
            //If the account is detailed, then balances are always ON CREDIT or DEBIT (always "summarized" by type of account)
            nDebStart    := nSumDebStart
            nDebFinish   := nSumDebFinish
            nCredStart   := nSumCredStart
            nCredFinish  := nSumCredFinish
            nCrdTO       :=  CVX_SLCR02-CVX_SLCR01
            nDBTO        :=  CVX_SLDB02-CVX_SLDB01
         Else
            //If the account is summarized, the turnovers values are stored in a specific field
            nCrdTO       :=  SLCRTO_02 - SLCRTO_01
            nDBTO        :=  SLDBTO_02 - SLDBTO_01
         Endif
         If cNormal == '1'
            nFinishBalance  := nFinishBalance * -1
            nStartBalance   := nStartBalance * -1
         Endif
         /*
         cRet +=  '"sumcredit_start":'+Alltrim(Str(nCredStart))+','+;
                  '"sumdebit_start":'+Alltrim(Str(nDebStart))+','+;
                  '"sumcredit_finish":'+Alltrim(Str(nCredFinish))+','+;
                  '"sumdebit_finish":'+Alltrim(Str(nDebFinish))+','+;
                  '"startcredit":'+Alltrim(Str(nCredStart))+','+;
                  '"startdebit":'+Alltrim(Str(nDebStart))+','+;
                  '"startbalance":'+Alltrim(Str(nStartBalance))+','+;
                  '"credit_movement":'+Alltrim(Str(CVX_SLCR02-CVX_SLCR01))+','+;
                  '"debit_movement":'+Alltrim(Str(CVX_SLDB02-CVX_SLDB01))+','+;
                  '"balance_variation":'+Alltrim(Str(CVX_SALD02-CVX_SALD01))+','+;
                  '"balance":'+Alltrim(Str(nFinishBalance))+;
                  '}'

         */
                  cRet +=  '"sumcredit_start":'+Alltrim(Str(nSumCredStart))+','+;
                           '"sumdebit_start":'+Alltrim(Str(nSumDebStart))+','+;
                           '"startcredit":'+Alltrim(Str(nCredStart))+','+;
                           '"startdebit":'+Alltrim(Str(nDebStart))+','+;
                           '"sumcredit_finish":'+Alltrim(Str(nSumCredFinish))+','+;
                           '"sumdebit_finish":'+Alltrim(Str(nSumDebFinish))+','+;
                           '"finishcredit":'+Alltrim(Str(nCredFinish))+','+;
                           '"finishdebit":'+Alltrim(Str(nDebFinish))+','+;
                           '"startbalance":'+Alltrim(Str(nStartBalance))+','+;
                           '"finishbalance":'+Alltrim(Str(nFinishBalance))+','+;
                           '"credit_movement":'+Alltrim(Str(nCrdTO))+','+;
                           '"debit_movement":'+Alltrim(Str(nDBTO))+;
                           '}'


         (cAliasQry)->( dbSkip() ) 

      EndDo
      dbSelectArea ( cAliasQry )
      DbCloseArea()
   Endif
Next
dbSelectArea ( cArqTemp )
DbCloseArea()

If .T. //!lAllLevels
   tcDelFile(cArqTemp)
Endif   

//cTotRet += cRet
Return cRet            
Static Function InsertSup(aEntities,cArqTemp,cTmpFil,lAllLevels,aDatafim,lSecondRun)
Local cNivRet
Local nTmpLevel   := 0
Local cQuery
Local cQueryQty
Local nX,nZ
Local cAliasQry := GetNextAlias()

For nZ := 1 To Len(aEntities)
   If aEntities[nZ,1] == "D" .AND. aEntities[nZ,2] <> '00'
      cNivRet := aEntities[nZ,2]
      DbSelectArea('CT0')
      DBsEToRDER(1)
      If DbSeek( xFilial('CT0') + cNivRet )

      Else
         // ERRO DE CONFIGURACAO
      EndIf   
      cGroupBy := ""
      For nX :=  1 to nZ // Len(aEntities)
         If aEntities[nX,2] <> "00" .And. aEntities[nX,2] <> cNivRet
            cGroupBy += ', CVX_NIV'+(aEntities[nX,2])
         Endif                  
      Next
      cQueryQty := " SELECT count(*) CONTA FROM  "+cArqTemp+ " TMP, "+RETSQLNAME(_CCUBEALIAS)+" "+_CCUBEALIAS+" WHERE PARENT"+cNivRet+" = '' AND "
      cQueryQty += _CCUBEALIAS+".D_E_L_E_T_ = '' AND "+_CCUBECHV +"= CVX_NIV" +cNivRet +" AND "+_CCUBESUP+" <> '' "
      If !Empty(cTMPFil)
         cQueryQty += " AND CVX_FILIAL = " +_CCUBEALIAS+"_FILIAL"
      Endif   

      cQueryQty   := ChangeQuery(cQueryQty)
      dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQueryQty),cAliasQry,.T.,.F.)
      dbSelectArea ( cAliasQry )
      nTmpLevel := 0
      While (cAliasQry)->CONTA > 0
         dbSelectArea ( cAliasQry )
         DbCloseArea()
         cQuery := " UPDATE  "+cArqTemp+ " SET  PARENT"+cNivRet+" = ( SELECT T2."+_CCUBESUP //+", NORMAL= T2."+_CCUBEALIAS+"_NORMAL 
         cQuery += " FROM "+RETSQLNAME(_CCUBEALIAS)+" T2 WHERE T2.D_E_L_E_T_ = '' AND T2."+_CCUBECHV +"= "+cArqTemp+".CVX_NIV" +cNivRet
         If !Empty(cTMPFil)
            cQuery += " AND "+cArqTemp+".CVX_FILIAL = T2." +_CCUBEALIAS+"_FILIAL"
         Endif   
         If !Empty(_CCUBEENT)
            cQuery += " AND T2.CV0_PLANO = '" +_CCUBEENT+"' "
         Endif   
         cQuery   += ") WHERE LEVEL = "+str(nTmpLevel)
         //avoid nulls
         If !Empty(_CCUBEENT)
            cQuery   += " AND CVX_NIV"+cNivRet+" IN (SELECT "+_CCUBECHV+" FROM  "+RETSQLNAME(_CCUBEALIAS)+" WHERE D_E_L_E_T_ = '' AND CV0_PLANO = '" + cNivRet + "' )"
         Else
            cQuery   += " AND CVX_NIV"+cNivRet+" IN (SELECT "+_CCUBECHV+" FROM  "+RETSQLNAME(_CCUBEALIAS)+" WHERE D_E_L_E_T_ = ''  )"
         Endif
         
         /*
         If lAllLevels
            //   cQuery   += " AND CVX_NIV"+cNivRet+" <> '' "
            cQuery   += " AND CVX_CONFIG = '"+cNivRet+"' "
         Endif
         */
         tcSqlexec(cQuery)

         cQuery := "INSERT INTO "+cArqTemp+" (LEVEL, CLASSE"+ cNivRet+", CVX_FILIAL, CVX_NIV"+ cNivRet+", CVX_TPSALD, CVX_MOEDA, CVX_CONFIG, NIVRET "+cGroupBy
         For nX:=1 to Len(aDataFim)
            cQuery += ", CVX_SLCR"+StrZero(nX,2)
            cQuery += ", CVX_SLDB"+StrZero(nX,2)
            cQuery += ", CVX_SALD"+StrZero(nX,2)
            cQuery += ", SLCRTO_"+StrZero(nX,2)
            cQuery += ", SLDBTO_"+StrZero(nX,2)
         Next
         cQuery += ") SELECT "+Str(nTmpLevel+1)+", '1', CVX_FILIAL, PARENT"+cNivRet+", CVX_TPSALD, CVX_MOEDA, CVX_CONFIG, '"+cNivRet+"' "+cGroupBy
/*        For nX:=1 to Len(aDataFim)
            cQuery += ", Sum(CVX_SLCR"+StrZero(nX,2)+")"
            cQuery += ", Sum(CVX_SLDB"+StrZero(nX,2)+")"
            cQuery += ", Sum(CVX_SALD"+StrZero(nX,2)+")"
         Next
         */
         For nX:=1 to Len(aDataFim)
           cQuery += ", Sum(CASE NORMAL"+cNivRet
            cQuery += " WHEN '1' THEN (0) "
            cQuery += " WHEN '2' THEN (CVX_SLCR"+StrZero(nX,2)+ " - CVX_SLDB"+StrZero(nX,2)+" ) "
            cQuery += " WHEN ' ' THEN (CVX_SLCR"+StrZero(nX,2)+ ") "
            cQuery += " END ) "
            cQuery += ", Sum(CASE NORMAL"+cNivRet
            cQuery += " WHEN '1' THEN (CVX_SLDB"+StrZero(nX,2)+ " - CVX_SLCR"+StrZero(nX,2)+ ") "
            cQuery += " WHEN '2' THEN (0) "
            cQuery += " WHEN ' ' THEN (CVX_SLDB"+StrZero(nX,2)+ ") "
            cQuery += " END ) "
          
            cQuery += ", Sum(CVX_SALD"+StrZero(nX,2)+")"
            cQuery += ", Sum(CASE CLASSE"+cNivRet
            cQuery += "       WHEN '1'  THEN SLCRTO_"+StrZero(nX,2)
            cQuery += "       ELSE CVX_SLCR"+StrZero(nX,2)
            cQuery += "       END)
            cQuery += ", Sum(CASE CLASSE"+cNivRet
            cQuery += "       WHEN '1'  THEN SLDBTO_"+StrZero(nX,2)
            cQuery += "       ELSE CVX_SLDB"+StrZero(nX,2)
            cQuery += "       END)
         Next
         //cQuery += ", Sum(SUMCRD_B), SUM(SUMDEB_B), SUM(SUMCRD_E), SUM(SUMDEB_E) "
         cQuery += " FROM "+ cArqTemp
         cQuery += " WHERE LEVEL ="+Str(nTmpLevel)
         cQuery += " AND  PARENT"+cNivRet+" <> '' "
         // do not add totalizers FROM PREVIOUS LEVELS
         For nX := 1 To (nZ-1)
            If aEntities[nX,2]<> '00'
               cQuery += " AND CLASSE"+aEntities[nX,2]+" IN ('2', '') "
            Endif               
         Next
         cQuery += " GROUP BY CVX_FILIAL, CVX_TPSALD, CVX_MOEDA, CVX_CONFIG, PARENT"+cNivRet+" "+cGroupBy
         tcSqlexec(cQuery)
         
         dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQueryQty),cAliasQry,.T.,.F.)
         dbSelectArea ( cAliasQry )
         nTmpLevel++
      Enddo
      dbSelectArea ( cAliasQry )
      DbCloseArea()
   Endif
Next
/*
if !lSecondRun
   InsertSup(aEntities,cArqTemp,cTmpFil,lAllLevels,aDatafim,.T.)
Endif*/
Return

Static Function UpdDescr(aEntities,cArqTemp,cTmpFil)
Local cNivRet
Local cQuery
Local nZ
Local cFrom
For nZ := 1 To Len(aEntities)
   If aEntities[nZ,1] == "D"
      if aEntities[nZ,2] <> '00'
         cNivRet := aEntities[nZ,2]
         DbSelectArea('CT0')
         DBsEToRDER(1)
         If DbSeek( xFilial('CT0') + cNivRet )
         Else
            // ERRO DE CONFIGURACAO
         EndIf   
         // Update entities descriptions and account class

         cFrom  := " FROM "+RETSQLNAME(_CCUBEALIAS)+" T2 WHERE T2.D_E_L_E_T_ = '' AND T2."+_CCUBECHV +"= "+cArqTemp+".CVX_NIV" +cNivRet
         // TODO: Consider entity sharing mode to be different to balances IE: '1020' to '102030'
         If !Empty(cTMPFil)
            cFrom += " AND "+cArqTemp+".CVX_FILIAL = T2." +_CCUBEALIAS+"_FILIAL"
         Endif   
         If !Empty(_CCUBEENT)
            cFrom += " AND T2.CV0_PLANO = '" +_CCUBEENT+"' "
         Endif   
         cFrom   += ") WHERE CVX_NIV"+cNivRet+" <> '' " 
         //avoid nulls
         cFrom   += " AND CVX_NIV"+cNivRet+" IN (SELECT "+_CCUBECHV+" FROM  "+RETSQLNAME(_CCUBEALIAS)+" WHERE D_E_L_E_T_ = ''  )"

         cQuery := " UPDATE  "+cArqTemp+ " SET  DESCR"+cNivRet+"  = (SELECT T2."+_CCUBEDSC + cFrom
         tcSqlexec(cQuery)
         cQuery := " UPDATE  "+cArqTemp+ " SET  NORMAL"+cNivRet+" = (SELECT T2."+_CCUBEALIAS+"_NORMAL " + cFrom
         tcSqlexec(cQuery)
         cQuery := " UPDATE  "+cArqTemp+ " SET  CLASSE"+cNivRet+" = (SELECT T2."+_CCUBEALIAS+"_CLASSE " + cFrom
         tcSqlexec(cQuery)
      Else
         //Updates branch description
         cQuery := " UPDATE  "+cArqTemp+ " SET  DESCR00 = (SELECT M0_FILIAL FROM SYS_COMPANY WHERE D_E_L_E_T_ = '' AND CVX_FILIAL = M0_CODFIL )"
         tcSqlexec(cQuery)

      Endif
   Endif
Next
Return

Static function getParentsKey(cArqTemp,aEntRet)
Local cQueryQty
Local cAliasQry   :=   getNextAlias()
Local aParents := {}
Local nZ
Local cNextParent
Local nPosParent
Local cNivRet

For nZ:=1 to Len(aEntRet)
   If aEntRet[nZ,1] == "D" .and. aEntRet[nZ,2] <> "00"
      cNivRet := aEntRet[nZ,2]
         
      DbSelectArea('CT0')
      DBsEToRDER(1)

      If DbSeek( xFilial('CT0') + cNivRet )
      Else
         // ERRO DE CONFIGURACAO
      EndIf   

      /* Define full ENTPARENT KEY, needed to on interface for ordering correctly */
      cQueryQty   := " SELECT DISTINCT PARENT"+cNivRet+" FROM  "+cArqTemp+ "  WHERE CVX_NIV"+cNivRet+" <> '' and PARENT"+cNivRet+" <> '' "
      cQueryQty   := ChangeQuery(cQueryQty)
      dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQueryQty),cAliasQry,.T.,.F.)
      dbSelectArea ( cAliasQry )

      AAdd(aParents,{cNivRet,{}})
      nPosParent := Len(aParents)
      While !(cAliasQry)->(EOF()) 
         AADD(aParents[nPosParent][2],{&("PARENT"+cNivRet),{}})
         cNextParent := ""
         (_CCUBEALIAS)-> (DbSetOrder(1))
         (_CCUBEALIAS)-> (DbSeek(xFilial()+cNextParent)) //TRATAR CV0
         WHILE (_CCUBEALIAS)->(Found()) .AND. cNextParent <> "" .AND. (_CCUBEALIAS)->(FieldGet(FieldPos(_CCUBESUP))) <> ""
            AADD(aParents[nPosParent][2][len(aParents)][2], (_CCUBEALIAS)->(FieldGet(FieldPos(_CCUBESUP))))
            cNextParent := (_CCUBEALIAS)->(FieldGet(FieldPos(_CCUBESUP)))
            (_CCUBEALIAS)-> (DbSeek(cNextParent))
         ENDDo
         (cAliasQry)->(DBSKIP()) 
      Enddo
      DbSelectArea(cAliasQry)
      DbCloseArea()
   Endif
Next   
Return aParents

Static Function getEntRec(cParent,aEnt)
Local cQuery
Local cAliasQry   := getNextAlias()
Local aArea := GetArea()
cQuery   := "SELECT "+_CCUBECHV+" ENTITY, "+_CCUBESUP+" SUPERIOR, "+_CCUBEALIAS+"_CLASSE CLASSE "
cQuery   += " FROM "+RetSqlName(_CCUBEALIAS)
cQuery   += " WHERE D_E_L_E_T_ = '' "
cQuery   += " AND  "+_CCUBECHV+" = '"+cParent+"' "
dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasQry,.T.,.F.)
dbSelectArea( cAliasQry )
While !EOF()
   If !Empty(SUPERIOR)
      GetEntRec(SUPERIOR,@aEnt)
   Endif
   AAdd(aEnt,{ENTITY,SUPERIOR,CLASSE})
   DbSkip()
Enddo
DbSelectArea(cAliasQry)
DbCloseArea()
RestArea(aArea)
Return

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

/*
Funcao encoding filter
@param cString Character filter
@return cRet Character from da query
@author Alexandra Velmozhnaya
@since 25/04/2022
@version P11, P12
/*/
Static Function MyDecode(cString)
Local cRet := ""
Local nX
Local cChar    := ""
Local cCharAnt := ""

For nX := 1 To Len(cString)
	cChar := Substr(cString, nX, 1)
	If cChar=="%".And.cCharAnt<>'\'
		cRet += (Chr(__HEXTODEC(Substr(cString,nX+1,2))))
      nX+=2
	Else
		cRet += cChar
	Endif
   cCharAnt:=cChar
Next
Return cRet
                   
//Merge Russia R14 
                   
