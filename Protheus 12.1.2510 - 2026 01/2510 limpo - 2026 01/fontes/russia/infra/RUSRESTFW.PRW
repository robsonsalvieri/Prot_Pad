#Include "RUSRESTFW.ch"
#INCLUDE "TOTVS.CH"
#INCLUDE "protheus.CH"
#INCLUDE "RESTFUL.CH"

#INCLUDE "FWMVCDEF.CH"

WSRESTFUL RUSRESTFW  DESCRIPTION STR0001 FORMAT APPLICATION_JSON //"REST services to be used with PO-UI - Developed by NP russian team"

//WSRESTFUL SalesOrder DESCRIPTION 'API para manuten??o de pedidos de venda'

WSDATA count AS INTEGER
WSDATA startIndex AS INTEGER 
WSDATA page AS INTEGER
WSDATA pageSize AS INTEGER 
WSDATA filterparams AS string
WSDATA filter AS string
WSDATA filterlookup AS string
WSDATA notfound AS string

WSMETHOD GET cfglookup ;
DESCRIPTION STR0002 ; //"Get lookup columns setup"
WSSYNTAX "cfglookup/{alias_returnfield}" ;
PATH "cfglookup/{alias_returnfield}"

WSMETHOD GET V2cfglookup ;
DESCRIPTION STR0002 + "(v2)"; //"Get lookup setup"
WSSYNTAX "cfglookup/v2/{lookupCodes}" ;
PATH "cfglookup/v2/{lookupCodes}"

WSMETHOD GET lookup ;
DESCRIPTION STR0003 ; //"Get lookup data"
WSSYNTAX "lookup/{lookupcode} || lookup/{lookupcode}/{key}" 

WSMETHOD GET vlookup ;
DESCRIPTION STR0004 ; //"Get lookup value"
WSSYNTAX "vlookup/{lookupcode}/{key}" ;
PATH "vlookup/{lookupcode}/{key}" 

WSMETHOD GET MVCModelStruct ;
DESCRIPTION STR0011 ; //"Get model structure"
WSSYNTAX "getstruct/{modelname}" ;
PATH "getstruct/{modelname}" 

END WSRESTFUL 

WSMETHOD GET cfglookup  WSSERVICE RUSRESTFW
Local lRet	:=	.T.
Local cResponse:=""

// define o tipo de retorno do m?todo
::SetContentType("application/json; charset=UTF-8")  
//::SetContentType("application/json; charset=Windows-1251")  
// verifica se recebeu parametro pela URL
// exemplo: http://localhost:8080/sample/1
If Len(::aURLParms) <> 2
   lRet := .F.
   SetRestFault(001,STR0005) //"Incorrect parameter count"
Else
//::SetResponse('{"datefrom":' + ::aURLParms[1] + ', "dateto":"'+ ::aURLParms[2]+'"}')
	//cResponse:= '{"items":[{"code":"1","description":"nick1"},{"code":"2","description":"nick2"}]}'

   cResponse:= GetLookup(::aURLParms[2])
	If Len(cResponse) >0
		::SetResponse(cResponse)
	Else
		SetRestFault(002,STR0006) //"Query returned no data "
	Endif	
Endif
Return lRet

WSMETHOD GET V2cfglookup  WSSERVICE RUSRESTFW
Local lRet	:=	.T.
Local oResponse as Json
Local oResp as Json
Local aLookups := {} as ARRAY
Local nX
// define o tipo de retorno do m?todo
::SetContentType("application/json; charset=UTF-8")  
//::SetContentType("application/json; charset=Windows-1251")  
// verifica se recebeu parametro pela URL
// exemplo: http://localhost:8080/sample/1
If Len(::aURLParms) <> 3
   lRet := .F.
   SetRestFault(001,STR0005) //"Incorrect parameter count"
Else
//::SetResponse('{"datefrom":' + ::aURLParms[1] + ', "dateto":"'+ ::aURLParms[2]+'"}')
	//cResponse:= '{"items":[{"code":"1","description":"nick1"},{"code":"2","description":"nick2"}]}'
   aLookups:= StrTokArr(::aURLParms[3],",")
   oResponse := JsonObject():New()
   oResponse['items'] := {}
   For  nX:=1 To Len(aLookups)
      oResp:= RUSRESTFW1_LUpsDefJson(aLookups[nX])
      If oResp <> Nil
         AAdd(oResponse['items'], oResp)
      Endif
   Next
	If oResponse <> Nil
		::SetResponse(oResponse)
	Else
		SetRestFault(002,'Error retrieving Lookup ') //"Query returned no data "
	Endif	
Endif
Return lRet

WSMETHOD GET lookup WSRECEIVE FilterParams,Filter,page,pageSize,filterlookup WSSERVICE RUSRESTFW
Local lRet	:=	.T.
Local cResponse:=""
Local cFilter := ""
// define o tipo de retorno do m?todo
::SetContentType("application/json; charset=UTF-8")  
// verifica se recebeu parametro pela URL
// exemplo: http://localhost:8080/sample/1
If Len(::aURLParms) <> 2 .and.Len(::aURLParms) <> 3
   lRet := .F.
   SetRestFault(001,STR0005) //"Incorrect parameter count"
Else
//::SetResponse('{"datefrom":' + ::aURLParms[1] + ', "dateto":"'+ ::aURLParms[2]+'"}')
   //cResponse:= {GetSXBData}(::aURLParms[2])
   If(::FilterParams<>nil .and.::FilterParams<>"")
      cFilter := ::FilterParams
   ElseIf(::filter<>nil .And.::Filter<>"")
      cFilter := ::Filter
   Endif
   If Len(::aURLParms) == 2
      cResponse   := GetLookupData(::aURLParms[2],::page,::pageSize,,cFilter,,::filterlookup)
   Else
      cResponse   := GetLookupData(::aURLParms[2],::page,::pageSize,::aURLParms[3],cFilter,.F.,::filterlookup)
   Endif
	//cResponse:= '{"hasNext":false,"items":[{"A1_COD":"1","A1_LOJA":"1","A1_NREDUZ":"nick1"},{"A1_COD":"2","A1_LOJA":"1","A1_NREDUZ":"nick2"}]}'
   If Len(cResponse) >0
		::SetResponse(cResponse)
	Else
		SetRestFault(002,STR0006) //"Query returned no data "
	Endif	
Endif
Return lRet

WSMETHOD GET vlookup WSRECEIVE FilterParams,page,pageSize,notfound WSSERVICE RUSRESTFW
Local lRet	:=	.T.
Local cResponse:=""

// define o tipo de retorno do m?todo
::SetContentType("application/json; charset=UTF-8")  
// verifica se recebeu parametro pela URL
// exemplo: http://localhost:8080/sample/1
If Len(::aURLParms) <> 3
   lRet := .F.
   SetRestFault(001,STR0005) //"Incorrect parameter count"
Else
//::SetResponse('{"datefrom":' + ::aURLParms[1] + ', "dateto":"'+ ::aURLParms[2]+'"}')
   //cResponse:= {GetSXBData}(::aURLParms[2])
   cResponse   := GetLookupData(::aURLParms[2],::page,::pageSize,::aURLParms[3],::FilterParams,/*lEncoded*/,/*cFilterLookup*/,::notfound/*S=Same,E=Empty*/)
   If Len(cResponse) >0
		::SetResponse(cResponse)
	Else
		SetRestFault(002,STR0006) //"Query returned no data "
	Endif	
Endif
Return lRet

Static Function GetLookupData(cLookupCode,nPage,nPageSize,cValue,cFilterPar,lEncoded,cFilterLookup,cNotFound)
Local cRet := ""
Local cRecord
Local aLookup:=LookupsDef()
Local cQuery:=""
Local aFields
Local nX
Local cTempAlias:=GetNextAlias()
Local nPos
Local cColumns
Local cFilFieldName
Local cFilter
Local cWhere:=""
Local cWhereTMP:=""
Local cQueryCnt:=""
Local nCount:=0
Local aFiedsFunc:={}
Local nPosFunc

DEFAULT nPage := 1
DEFAULT nPageSize := 20
DEFAULT lEncoded := .T.
DEFAULT cNotFound := "E"
If (cFilterPar<> Nil .AND. cFilterPar<> "")
   cFilter     := dECODEutf8(MyDecode(Decode64(cFilterPar)))
   //Not working with cyrillic in some cases
   if(cFilter == Nil)
      cFilter := ((cFilterPar))
   Endif
   //cFilter:=   Upper(Substr(cFilter,2,Len(cFilter)-2))
   cFilter:=   Upper(cFilter)
Endif   
/*
If (cFilterLookup<> Nil .AND. cFilterLookup<> "")
   cFilter     := dECODEutf8(MyDecode(Decode64(cFilterPar)))
   //cFilter:=   Upper(Substr(cFilter,2,Len(cFilter)-2))
   cFilter:=   Upper(cFilter)
Endif   
*/
If lEncoded.And.(cValue<> Nil .AND. cValue<> "")
   cValue     := dECODEutf8(MyDecode(Decode64(cValue)))
Endif   
If (nPos:=Ascan(aLookup,{|x| x[1]==cLookupCode})) > 0
   cQuery   := 'SELECT '
   aFields  := {}
   //Fields to be shown in lookup table
   For nX:=1 To Len(aLookup[nPos,2])
      If(Ascan(aFields,aLookup[nPos,2,nX,1])) ==0
         aadd(aFields,aLookup[nPos,2,nX,1])
         If(Len(aLookup[nPos,2,nX,2])>2 .And. aLookup[nPos,2,nX,3]<>"")
            aadd(aFiedsFunc,{aLookup[nPos,2,nX,1],aLookup[nPos,2,nX,3]})
         Endif
      Endif
   Next
   //Fields to Fill calling field on interface
   For nX:=1 To Len(aLookup[nPos,4])
      If(Ascan(aFields,aLookup[nPos,4,nX])) == 0
         aadd(aFields,aLookup[nPos,4,nX])
         If(Len(aLookup[nPos,2,nX,2])>2 .And. aLookup[nPos,2,nX,3]<>"")
            aadd(aFiedsFunc,{aLookup[nPos,2,nX,1],aLookup[nPos,2,nX,3]})
         Endif
      Endif
   Next
   //Return Field
   If(Ascan(aFields,aLookup[nPos,3])) == 0
      aadd(aFields,aLookup[nPos,3])
   Endif

   cColumns := ""
   For nX:=1 To Len(aFields)
      cColumns += ","+aFields[nX]
   Next
   cFilFieldName := If(Left(aLookup[nPos,5],1)=="S",Substr(aLookup[nPos,5],2,2),aLookup[nPos,5])+"_FILIAL"
   IF (aLookup[nPos,5]=='SX5')
      cQuery      := 'SELECT R_E_C_N_O_ RECSX5,'+Substr(cColumns,2)+ " FROM "+RetSqlName(aLookup[nPos,5])
   ElseIF (aLookup[nPos,5]=='SM0')
      cQuery      := 'SELECT '+Substr(cColumns,2)+ " FROM SYS_COMPANY "
   Else
      cQuery      := 'SELECT '+Substr(cColumns,2)+ " FROM "+RetSqlName(aLookup[nPos,5])
   ENDIF
   IF (aLookup[nPos,5]=='SM0')
      cQueryCnt   := 'SELECT Count(*) as REC_COUNT FROM SYS_COMPANY '
   Else
      cQueryCnt   := 'SELECT Count(*) as REC_COUNT FROM '+RetSqlName(aLookup[nPos,5])
   Endif
   IF (aLookup[nPos,5]=='SM0')
      cWhere := ' WHERE 1=1 '
   Else
      cWhere := ' WHERE '+cFilFieldName+"='"+xFilial(aLookup[nPos,5])+"' "
   Endif
   cWhere += " AND D_E_L_E_T_='' "
   If cValue <> NIL
      cWhere += " AND "+aLookup[nPos,3]+"='"+cValue+"' "
   Endif
   cWhereTMP:=""
   IF (aLookup[nPos,6]<>"")
      if(Left(aLookup[nPos,6],1)<>'&')
         cWhere += "AND "+aLookup[nPos,6]+" "
      ElseIf (cFilterLookup<> Nil .AND. cFilterLookup<> "")
         cWhere += "AND ("+i18n(Substr(aLookup[nPos,6],2),{cFilterLookup})+")) "
      Endif         
   Endif
   If cFilter <> Nil
      For nX:=1 To Len(aFields)
         cWhereTMP += " OR Upper("+aFields[nX]+") like '%"+cFilter+"%' "
      Next
      cWhere   += "AND ("+SubStr(cWhereTMP,4)+") "
   Endif
   cQueryCnt+= cWhere 
   cQuery   += cWhere
   cQuery += " ORDER BY "+cFilFieldName+","+aLookup[nPos,3]
   cOffset:= Str((nPage-1) * nPageSize)
   
   If(TCGETDB()=='ORACLE')
      cQuery+= ' ROWNUM BETWEEN '+cOffset+" AND "+Str(Val(cOffset)+nPageSize)
    //ROWNUM <= 10
   ElseIf('MSSQL'$TCGETDB())
      cQuery+= ' OFFSET '+cOffset+" ROWS FETCH FIRST "+Str(nPageSize)+" ROWS ONLY "
      //OFFSET 10 ROWS FETCH FIRST 20 ROWS ONLY
   Else //POtsgreSql and others
      cQuery+= " LIMIT "+Str(nPageSize)+" OFFSET "+cOffset
      //LIMIT 3 OFFSET 2
   Endif
   DbUseArea( .T. , 'TOPCONN' , TcGenQry( ,, cQueryCNT) , cTempAlias , .T. , .T. )
   nCount := (cTempAlias)->REC_COUNT-(Val(cOffset))
   (cTempAlias)->(DbCloseArea())

   DbUseArea( .T. , 'TOPCONN' , TcGenQry( ,, cQuery) , cTempAlias , .T. , .T. )
   While !(cTempAlias)->(Eof())
      cRecord:=""
      If cValue <> Nil
         // DATA,VALUE,$SELECTED and LABEL are due to harcoded values on POLOOKUP component and in POLOOKUP component in Dynamic Form
         cRet  :='{"data":"'+ Alltrim(StrTran(FieldGet( FieldPos(aLookup[nPos,3]) ),'"','\"'))+'","$selected":true'
         cRet  +=',"value":"'+Alltrim(StrTran(FieldGet( FieldPos(aLookup[nPos,3]) ),'"','\"'))+'"'
         cLabel := Alltrim(StrTran(FieldGet( FieldPos(aLookup[nPos,3]) ),'"','\"'))
         For nX:=1 To Len(aLookup[nPos,2])
            cRet  +=',"'+aLookup[nPos,2,nX,1]+'":"'+ Alltrim(StrTran(FieldGet( FieldPos(aLookup[nPos,2,nX,1]) ),'"','\"'))+'"'
         Next
         For nX:=1 To Len(aLookup[nPos,4])
            cLabel += "-"+Alltrim(StrTran(FieldGet( FieldPos(aLookup[nPos,4,nX]) ),'"','\"'))
         Next
         cRet  +=',"label":"'+Substr(cLabel,1)+'"'

         cRet+="}"
         Exit
      Else
         IF (aLookup[nPos,5]=='SX5')
            SX5->(MsGoTo((cTempAlias)->RECSX5))
         Endif
         For nX:=1 To Len(aFields)
            cRecord += ',"'+aFields[nX]+'":'
            xValue   := FieldGet( FieldPos(aFields[nX]) )
            If (nPosFunc:=ascan(aFiedsFunc,{|x| x[1]==aFields[nX]}))>0
               xValue   := &(aFiedsFunc[nPosFunc][2])
            Endif
            If ValType(xValue)=="N"
               cRecord += Alltrim(Str(xValue))
            Else
               cRecord += '"'+Alltrim(StrTran(xValue,'"','\"'))+'"'
            Endif
         Next
         cRecord  +=',"value":"'+Alltrim(StrTran(FieldGet( FieldPos(aLookup[nPos,3]) ),'"','\"'))+'"'
         cLabel := Alltrim(StrTran(FieldGet( FieldPos(aLookup[nPos,3]) ),'"','\"'))
         For nX:=1 To Len(aLookup[nPos,4])
            cLabel += "-"+Alltrim(StrTran(FieldGet( FieldPos(aLookup[nPos,4,nX]) ),'"','\"'))
         Next
         cRecord  +=',"label":"'+Substr(cLabel,1)+'"'

         cRet += ",{"+Substr(cRecord,2)+"}"
         nCount--
         (cTempAlias)->(DbSkip())
      Endif
   Enddo
   DbCloseArea()
   If (cValue==Nil)
      cRet := Substr(cRet,2)
      cRet := '{"hasNext":'+Iif(nCount>0,'true','false')+',"items":['+cRet+"]}"
   ElseIf EMPTY(cRet)
      if(cNotFound<>"S")
         //If value received is not encoded (using directly in dynamic form ), return error
         //Otherwise is being used from a manual lookup and should return same value received
         If lEncoded
            cRet  :='{"data":"'+ cValue+'","$selected":true'
            For nX:=1 To Len(aLookup[nPos,2])
               cRet  +=',"'+aLookup[nPos,2,nX,1]+'":""'
            Next
            cRet+="}"
         Else
            cRet := '{"error":"'+STR0009+'"}'
         Endif
      Else
         cRet  :='{"data":"'+ cValue+'","value":"'+ cValue+'","$selected":true,"label":"'+cValue+'"}'
      Endif
   Endif      
Else
   cRet := '{"error":"'+i18n(STR0010,{cLookupCode})+'","'+aLookup[nPos,3]+'":"NOT FOUND"}' //"Lookup #1 not found
Endif
cRet := EncodeUTF8(cRet)

Return cRet

Static Function GetLookup(cAlias)
Local cRet     := ""
Local aAlias   := StrTokArr(cAlias,",")
Local aLookups := {}//GetSXBData(aAlias)
Local nX,nY,nZ
Local aTMP:={}
Local cError:=""
For nZ:=1 To Len(aAlias)
   aTmp     := StrTokArr(aAlias[nZ],":")  
   If(len(aTMP)<>2)
      cError := STR0007 //"Incorrect parameter syntax. Inform LOOKUPCODE1|RETURNFIELD1,LOOKUPCODE2|RETURNFIELD2,"
   Else
      aLookups := GetSXBData(aTMP[1])
      For nX:=1 To Len(aLookups)
         cRet += ',{"lookup":"'+aLookups[nX,1]+'",'
         cRet +=  ' "returnto":"'+aTmp[2]+'",'
         cRet +=  ' "return":"'+aLookups[nX,3]+'",'
         cTMP:=""
         For nY:=1 To Len(aLookups[nX,2])
            cTMP += ',{"code":"'+aLookups[nX,2,nY,1]+'","description":"'+aLookups[nX,2,nY,2]+'"}'
         Next
         cRet +='"columns":['+Substr(cTmp,2)+"],"
         cTMP:=""
         
         For nY:=1 To Len(aLookups[nX,4])
            cTMP += ',{"column":"'+aLookups[nX,4,nY]+'"}'

         Next
         cRet +='"show":['+Substr(cTmp,2)+"]"
         cRet +='}'
      Next
   Endif
Next
If Empty(cError)
   cRet := '{"ok":"ok","items":['+Substr(cRet,2)+"]}"
Else
   cRet := '{"error":"'+cError+'","items":['+Substr(cRet,2)+"]}"
Endif
cRet := EncodeUTF8(cRet)

Return cRet

Static Function GetSXBData(cAlias)
Local aArea := getArea()
Local aAreaSX3 := getArea()
Local nPos:=0
Local aLookups:={}
Local aRet:={}
Local nX,nY
aLookups:=LookupsDef()
DbSelectArea('SX3')
aAreaSX3 := getArea()

SX3->(DbSetOrder(2))
If (nPos := Ascan(aLookups,{|x| x[1]==cAlias})) > 0
   aadd(aRet,aLookups[nPos])
Endif
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


Static Function LookupsDef()
Local aLookups:={}
//Do not use NUMERIC FIELDS
AAdd(aLookups,{"SA1",{{"A1_COD",""},{"A1_LOJA",""},{"A1_NREDUZ",""}},"A1_COD",{"A1_NREDUZ"},'SA1',""})
//AAdd(aLookups,{"SA1BRANCH",{{"A1_LOJA",""},{"A1_NREDUZ",""}},"A1_LOJA",{""},'SA1',""})
AAdd(aLookups,{"SA2",{{"A2_COD",""},{"A2_LOJA",""},{"A2_NREDUZ",""}},"A2_COD",{"A2_NREDUZ"},'SA2',""})
AAdd(aLookups,{"SB1",{{"B1_COD",""},{"B1_DESCRI",""}},"B1_COD",{"B1_DESC"},'SB1',""})
AAdd(aLookups,{"SH7",{{"H7_CODIGO",""},{"H7_DESCRI",""}},"H7_CODIGO",{"H7_DESCRI"},'SH7',""})
AAdd(aLookups,{"AEA",{{"AEA_COD"  ,""},{"AEA_DESCRI",""}},"AEA_COD",{"AEA_DESCRI"},'AEA',""})
AAdd(aLookups,{"AED",{{"AED_EQUIP",""},{"AED_DESCRI",""}},"AED_EQUIP",{"AED_DESCRI"},'AED',""})
AAdd(aLookups,{"FE",{{"X5_CHAVE",""},{"X5_DESCRI",STR0008,'X5DESCRI()'}},"X5_CHAVE",{"X5_DESCRI"},'SX5',"X5_TABELA='FE'"}) //"Description"
//TODO: Filter projects by client access
AAdd(aLookups,{"AF8",{{"AF8_PROJET",""},{"AF8_DESCRI",""}},"AF8_PROJET",{"AF8_DESCRI"},'AF8',""})
AAdd(aLookups,{"AE8",{{"AE8_RECURS",""},{"AE8_RECURS",""},{"AE8_DESCRI",""}},"AE8_RECURS",{"AE8_DESCRI"},'AE8',""})
AAdd(aLookups,{"AE5",{{"AE5_GRPCOM",""},{"AE5_GRPCOM",""},{"AE5_DESCRI",""}},"AE5_GRPCOM",{"AE5_DESCRI"},'AE5',""})
AAdd(aLookups,{"AE7",{{"AE7_CODIGO",""},{"AE7_CODIGO",""},{"AE7_DESCRI",""}},"AE7_CODIGO",{"AE7_DESCRI"},'AE7',""})
AAdd(aLookups,{"AF9",{{"AF9_TAREFA",""},{"AF9_DESCRI",""}},"AF9_TAREFA",{"AF9_DESCRI"},'AF9',;
               "&(AF9_PROJET ='#1[]#' AND AF9_REVISA IN (SELECT AF8_REVISA FROM "+RETSQLNAME('AF8')+" AF8 WHERE AF8_FILIAL='"+XfILIAL('AF8')+"' AND AF8.D_E_L_E_T_='' AND AF8_PROJET=AF9_PROJET)"})

AAdd(aLookups,{"SM0",{{"M0_CODFIL",""},{"M0_FILIAL",""}},"M0_CODFIL",{"M0_FILIAL"},'SM0',"M0_CODIGO = '"+cEmpAnt+"'"})
AAdd(aLookups,{"CTO",{{"CTO_MOEDA",""},{"CTO_DESC",""},{"CTO_SIMB",""}},"CTO_MOEDA",{"CTO_DESC"},'CTO',""})

AAdd(aLookups,{"CT1",{{"CT1_CONTA",""},{"CT1_CONTA",""},{"CT1_DESC01",""}},"CT1_CONTA",{"CT1_DESC01"},'CT1',""})
AAdd(aLookups,{"CTT",{{"CTT_CUSTO",""},{"CTT_CUSTO",""},{"CTT_DESC01",""}},"CTT_CUSTO",{"CTT_DESC01"},'CTT',""})
AAdd(aLookups,{"CTD",{{"CTD_ITEM",""},{"CTD_ITEM",""},{"CTD_DESC01",""}},"CTD_ITEM",{"CTD_DESC01"},'CTD',""})
AAdd(aLookups,{"CTH",{{"CTH_CLVL",""},{"CTH_CLVL",""},{"CTH_DESC01",""}},"CTH_CLVL",{"CTH_DESC01"},'CTH',""})
aArea := GetArea()
DbSelectArea('CT0')
DBsEToRDER(1)
If DbSeek( xFilial('CT0') + '05' )
	While CT0->(!Eof()) .And. CT0->CT0_FILIAL == xFilial('CT0')
		AAdd(aLookups,{"CV0"+CT0->CT0_ID,{{CT0->CT0_CPOCHV,""},{ALLTRIM(CT0->CT0_CPODSC),"",}},CT0->CT0_CPOCHV,{ALLTRIM(CT0->CT0_CPODSC)},CT0->CT0_ALIAS, iiF(CT0->CT0_ALIAS=='CV0',"CV0_PLANO='"+CT0->CT0_ID+"'","")})
		CT0->(DbSkip())
	EndDo
EndIf   
RestArea(aArea)
Return aLookups


Function RUSRESTFW1_LUpsDefJson(cSXB)
Local oJsonRet := JsonObject():New() as Json
Local cRet := "" as character
Local oRet as Json
Local cMessage as character
cSXB := Alltrim(cSXB)
//Local aLookups := {} as ARRAY

   Do Case
/*   Case cSXB == "SA1" 
      BeginContent var cRet as Json
       { "SA1":
        {
         "dataFields"   :  [{ "field": "A1_COD"},{"field": "A1_LOJA"},{ "field": "A1_FILIAL"},{"field": "A1_NREDUZ"}],
         "idFields"     :  [{ "field": "A1_COD"},{"field": "A1_LOJA"}],
         "labelFields"  :  [{ "field": "A1_COD"},{"field": "A1_LOJA"},{"field": "A1_NREDUZ"}],
         "returnFields" :  [{ "field": "A1_COD"},{"field": "A1_LOJA"}],
         "endPoint"     :  "FWMODEL/MATA030",
         "endPointKey"  :  [{ "field": "A1_FILIAL"},{ "field": "A1_COD"},{"field": "A1_LOJA"}]
        }
      }
      EndContent
   Case cSXB == "SA2" 
      BeginContent var cRet as Json
      { "SA2":
        {
         "dataFields"   :  [{ "field": "A2_COD"},{"field": "A2_LOJA"},{ "field": "A2_FILIAL"},{"field": "A2_NREDUZ"}],
         "idFields"     :  [{ "field": "A2_COD"},{"field": "A2_LOJA"}],
         "labelFields"  :  [{ "field": "A2_COD"},{"field": "A2_LOJA"},{"field": "A2_NREDUZ"}],
         "returnFields" :  [{ "field": "A2_COD"},{"field": "A2_LOJA"}],
         "endPoint"     :  "FWMODEL/MATA020",
         "endPointKey"  :  [{ "field": "A2_FILIAL"},{ "field": "A2_COD"},{"field": "A2_LOJA"}]
        }
    }
      EndContent
  */
   Case cSXB == "SB1" 
      BeginContent var cRet as Json
      { "SB1":
        {
         "dataFields"   :  [{ "field": "B1_COD"},{ "field": "B1_FILIAL"},{"field": "B1_DESC"}],
         "idFields"     :  [{ "field": "B1_COD"}],
         "labelFields"  :  [{"field": "B1_DESC"}],
         "returnFields" :  [{ "field": "B1_COD"}],
         "endPoint"     :  "/FWMODEL/MATA010/",
         "endPointKey"  :  [{ "field": "B1_FILIAL"},{ "field": "B1_COD"}]
        }
      }
      EndContent
      /*
   Case cSXB == "SH7" 
      BeginContent var cRet as Json
      { "SH7":
        {
         "dataFields"   :  [{ "field": "H7_CODIGO"},{ "field": "H7_FILIAL"},{"field": "H7_DESCRI"}],
         "idFields"     :  [{ "field": "H7_CODIGO"}],
         "labelFields"  :  [{ "field": "H7_CODIGO"},{"field": "H7_DESCRI"}],
         "returnFields" :  [{ "field": "H7_CODIGO"}],
         "endPoint"     :  "FWMODEL/MATA010????",
         "endPointKey"  :  [{ "field": "H7_FILIAL"},{ "field": "H7_CODIGO"}]
        }
    }
      EndContent
   */
   /*
   Case cSXB == "AEA" 
      BeginContent var cRet as Json
      { "AEA":
        {
         "dataFields"   :  [{ "field": "AEA_COD"},{ "field": "AEA_FILIAL"},{"field": "AEA_DESCRI"}],
         "idFields"     :  [{ "field": "AEA_COD"}],
         "labelFields"  :  [{ "field": "AEA_COD"},{"field": "AEA_DESCRI"}],
         "returnFields" :  [{ "field": "AEA_COD"}],
         "endPoint"     :  "FWMODEL/MATA010????",
         "endPointKey"  :  [{ "field": "AEA_FILIAL"},{ "field": "AEA_COD"}]
        }
      }
      EndContent
   */
   Case cSXB == "AED" 
      BeginContent var cRet as Json
      { "AED":
        {
         "dataFields"   :  [{ "field": "AED_EQUIP"},{ "field": "AED_FILIAL"},{"field": "AED_DESCRI"}],
         "idFields"     :  [{ "field": "AED_EQUIP"}],
         "labelFields"  :  [{ "field": "AED_DESCRI"}],
         "returnFields" :  [{ "field": "AED_EQUIP"}],
         "endPoint"     :  "/FWMODEL/RU44W080/",
         "isMVC"        :  true,
         "endPointKey"  :  [{ "field": "AED_FILIAL"},{ "field": "AED_EQUIP"}]
        }
      }
      ENDCONTENT
   Case cSXB == "AF8" 
      BeginContent var cRet as Json
      { "AF8":
        {
         "dataFields"   :  [{ "field": "AF8_PROJET"},{ "field": "AF8_FILIAL"},{"field": "AF8_DESCRI"}],
         "idFields"     :  [{ "field": "AF8_PROJET"}],
         "labelFields"  :  [{"field": "AF8_DESCRI"}],
         "returnFields" :  [{ "field": "AF8_PROJET"}],
         "endPoint"     :  "/FWMODEL/RU44W200/",
         "isMVC"        :  true,
         "endPointKey"  :  [{ "field": "AF8_FILIAL"},{ "field": "AF8_PROJET"}]
        }
      }
      ENDCONTENT
   Case cSXB == "AE8" 
      BeginContent var cRet as Json
      { "AE8":
        {
         "dataFields"   :  [{ "field": "AE8_RECURS"},{ "field": "AE8_FILIAL"},{"field": "AE8_DESCRI"}],
         "idFields"     :  [{ "field": "AE8_RECURS"}],
         "labelFields"  :  [{ "field": "AE8_DESCRI"}],
         "returnFields" :  [{ "field": "AE8_RECURS"}],
         "endPoint"     :  "/FWMODEL/RU44W050/",
         "isMVC"        :  true,
         "endPointKey"  :  [{ "field": "AE8_FILIAL"},{ "field": "AE8_RECURS"}]
        }
      }
      ENDCONTENT

   Case cSXB == "AE5" 
      BeginContent var cRet as Json
      { "AE5":
        {
         "dataFields"   :  [{ "field": "AE5_GRPCOM"},{ "field": "AE5_FILIAL"},{"field": "AE5_DESCRI"}],
         "idFields"     :  [{ "field": "AE5_GRPCOM"}],
         "labelFields"  :  [{"field": "AE5_DESCRI"}],
         "returnFields" :  [{ "field": "AE5_GRPCOM"}],
         "endPoint"     :  "/FWMODEL/RU44W020/",
         "isMVC"        :  true,
         "endPointKey"  :  [{ "field": "AE5_FILIAL"},{ "field": "AE5_GRPCOM"}]
        }
      }
      ENDCONTENT
/*   Case cSXB == "AEA" 
      BeginContent var cRet as Json
      { "AEA":
        {
         "idFields"     :  [{ "field": "AEA_COD"}],
         "labelFields"  :  [{ "field": "AEA_COD"},{"field": "AEA_DESCRI"}],
         "endPoint"     :  "/api/pms/v1/ru44w120/md/AEA/AEA_COD/AEA_DESCRI/",
         "isMVC"        :  false
        }
      }
      ENDCONTENT
      */

   Case cSXB == "AE7" 
      BeginContent var cRet as Json
      { "AE7":
        {
         "dataFields"   :  [{ "field": "AE7_CODIGO"},{ "field": "AE7_FILIAL"},{"field": "AE7_DESCRI"}],
         "idFields"     :  [{ "field": "AE7_CODIGO"}],
         "labelFields"  :  [{ "field": "AE7_CODIGO"},{"field": "AE7_DESCRI"}],
         "returnFields" :  [{ "field": "AE7_CODIGO"}],
         "endPoint"     :  "FWMODEL/RU44W040/",
         "endPointKey"  :  [{ "field": "AE7_FILIAL"},{ "field": "AE7_CODIGO"}]
        }
      }
      ENDCONTENT
   Case cSXB == "AF9" 
      BeginContent var cRet as Json
      
      { "AF9":
        {
         "dataFields"   :  [{ "field": "AF9_TAREFA"},{ "field": "AF9_FILIAL"},{"field": "AF9_DESCRI"}],
         "idFields"     :  [{ "field": "AF9_TAREFA"}],
         "labelFields"  :  [{ "field": "AF9_DESCRI"}],
         "returnFields" :  [{ "field": "AF9_TAREFA"}],
         "endPoint"     :  "FWMODEL/RU44W201/",
         "endPointKey"  :  [{ "field": "AF9_FILIAL"},{ "field": "AF9_PROJET"},{ "field": "AF9_TAREFA"}],
         "fixedFilter"  :  "(AF9_PROJET ='?' AND AF9_REVISA IN (SELECT AF8_REVISA FROM AF8990 AF8 WHERE AF8_FILIAL='?' AND AF8.D_E_L_E_T_='' AND AF8_PROJET=AF9_PROJET)"
        }
      }
      ENDCONTENT
   Otherwise
      // Just to return a JSON
      BeginContent var cRet as Json
      { 
         "message": "Lookup %Exp:cSXB% not avaliable"
      }
      ENDCONTENT

   End Case

oRet     := JsonObject():New()
cMessage := oRet:FromJson(cRet)
If Empty(cMessage)
   If oRet[cSXB] <> Nil
      oJsonRet['lookup']  :=  cSXB
      oJsonRet['data']    :=  oRet[cSXB]
      oJsonRet["success"] := .T.
   Else
      oJsonRet['lookup']  := cSXB
      oJsonRet["message"] := oRet['message']
      oJsonRet["success"] := .F.
   Endif
Else
   oJsonRet["message"] := cMessage
   oJsonRet["success"] := .F.
Endif
Return oJsonRet


/*
//TODO: Filter projects by client access
AAdd(aLookups,{"AF8",{{"AF8_PROJET",""},{"AF8_DESCRI",""}},"AF8_PROJET",{"AF8_DESCRI"},'AF8',""})
AAdd(aLookups,{"AE8",{{"AE8_RECURS",""},{"AE8_RECURS",""},{"AE8_DESCRI",""}},"AE8_RECURS",{"AE8_DESCRI"},'AE8',""})
AAdd(aLookups,{"AE5",{{"AE5_GRPCOM",""},{"AE5_GRPCOM",""},{"AE5_DESCRI",""}},"AE5_GRPCOM",{"AE5_DESCRI"},'AE5',""})
AAdd(aLookups,{"AE7",{{"AF9_CODIGO",""},{"AE7_CODIGO",""},{"AE7_DESCRI",""}},"AE7_CODIGO",{"AE7_DESCRI"},'AE7',""})
AAdd(aLookups,{"AF9",{{"AF9_TAREFA",""},{"AF9_DESCRI",""}},"AF9_TAREFA",{"AF9_DESCRI"},'AF9',;
               "&(AF9_PROJET ='#1[]#' AND AF9_REVISA IN (SELECT AF8_REVISA FROM "+RETSQLNAME('AF8')+" AF8 WHERE AF8_FILIAL='"+XfILIAL('AF8')+"' AND AF8.D_E_L_E_T_='' AND AF8_PROJET=AF9_PROJET)"})

AAdd(aLookups,{"SM0",{{"M0_CODFIL",""},{"M0_FILIAL",""}},"M0_CODFIL",{"M0_FILIAL"},'SM0',"M0_CODIGO = '"+cEmpAnt+"'"})
AAdd(aLookups,{"CTO",{{"CTO_MOEDA",""},{"CTO_DESC",""},{"CTO_SIMB",""}},"CTO_MOEDA",{"CTO_DESC"},'CTO',""})

AAdd(aLookups,{"CT1",{{"CT1_CONTA",""},{"CT1_CONTA",""},{"CT1_DESC01",""}},"CT1_CONTA",{"CT1_DESC01"},'CT1',""})
AAdd(aLookups,{"CTT",{{"CTT_CUSTO",""},{"CTT_CUSTO",""},{"CTT_DESC01",""}},"CTT_CUSTO",{"CTT_DESC01"},'CTT',""})
AAdd(aLookups,{"CTD",{{"CTD_ITEM",""},{"CTD_ITEM",""},{"CTD_DESC01",""}},"CTD_ITEM",{"CTD_DESC01"},'CTD',""})
AAdd(aLookups,{"CTH",{{"CTH_CLVL",""},{"CTH_CLVL",""},{"CTH_DESC01",""}},"CTH_CLVL",{"CTH_DESC01"},'CTH',""})
aArea := GetArea()
DbSelectArea('CT0')
DBsEToRDER(1)
If DbSeek( xFilial('CT0') + '05' )
   While CT0->(!Eof()) .And. CT0->CT0_FILIAL == xFilial('CT0')
      AAdd(aLookups,{"CV0"+CT0->CT0_ID,{{CT0->CT0_CPOCHV,""},{ALLTRIM(CT0->CT0_CPODSC),"",}},CT0->CT0_CPOCHV,{ALLTRIM(CT0->CT0_CPODSC)},CT0->CT0_ALIAS, iiF(CT0->CT0_ALIAS=='CV0',"CV0_PLANO='"+CT0->CT0_ID+"'","")})
      CT0->(DbSkip())
   EndDo
EndIf   
RestArea(aArea)

Return aLookups
*/
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

WSMETHOD GET MVCModelStruct WSRECEIVE WSSERVICE RUSRESTFW
    Local lRet	    :=	.T.
    Local cResponse := ""

    // define o tipo de retorno do m?todo
    ::SetContentType("application/json; charset=UTF-8")  
    // verifica se recebeu parametro pela URL
    // exemplo: http://localhost:8080/sample/1
    If Len(::aURLParms) <> 2
        lRet := .F.
        SetRestFault(001,STR0005) //"Incorrect parameter count"
    Else
        cResponse   := GetMVCStructure(::aURLParms[2])
        If Len(cResponse) > 0
            ::SetResponse(cResponse)
        Else
            SetRestFault(002,STR0012 + " " + ::aURLParms[2]) //"Query returned no data "
        Endif
    Endif
Return lRet

/*/{Protheus.doc} GetMVCStructure()
    This function needs for get model structure

    @type static function
    @param cModelName, string with model name
    @return cRet

    @author Dmitry Borisov
    @since 2024/05/20
    @example GetMVCStructure(cModelName)
*/
Static Function GetMVCStructure(cModelName)
    Local cRet   := ""
    Local oModel := FWLoadModel(cModelName)
    Local aTriggers := {}
    Local oJson := JsonObject():New()
    Local nX
    Local xValidation
    //TODO: Implement for complex MVC Structures (more than one model)
    If oModel != Nil
       //cRet := oModel:GetJSONData(.T.)
      oModel:SetOperation(MODEL_OPERATION_INSERT)
      oModel:Activate()
      //([ lDetail ], [ nOperation ], [ lVirtual ], [ lDeleted ], [ lEmpty ])
      cRet := oModel:GetJSONData(.T.,MODEL_OPERATION_INSERT,.T.,,.T.)
      oJson:FromJson(cRet)
      aTriggers := oModel:GetModelStruct(oJson['models'][1]['id'])[3]:oFormModelStruct:getTriggers()
      For nX:=1 To Len(oJson['models'][1]['fields'])
         aValues:= oModel:getModelStruct(oJson['models'][1]['id'])[3]:oformmodelstruct:getproperty(oJson['models'][1]['fields'][nX]['id'],9)
         If len(aValues)>0
            oJson['models'][1]['fields'][nX]['options'] = aValues
         Endif
         xValidation := oModel:getModelStruct(oJson['models'][1]['id'])[3]:oformmodelstruct:getproperty(oJson['models'][1]['fields'][nX]['id'],MODEL_FIELD_VALID)
         If xValidation <> Nil  .And. StrTran(GetCbSource(xValidation), " ","") <> "{||.T.}"
            oJson['models'][1]['fields'][nX]['hasValidation'] = .T.
         Endif
         If Ascan(aTriggers,{ |x| x[1] == oJson['models'][1]['fields'][nX]['id']}) > 0
            oJson['models'][1]['fields'][nX]['hasTrigger'] = .T.
         Endif
      Next
      cRet := oJson:ToJson()
      FreeObj(oJson)
      oModel:DeActivate()
    EndIf

Return cRet
                   
//Merge Russia R14 
                   
