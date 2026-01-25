#INCLUDE "TOTVS.CH"
#INCLUDE 'protheus.ch'
#INCLUDE 'topconn.ch'

#DEFINE DELETEFILE .F.
#DEFINE FIELDNAME 1
#DEFINE FIELDDESC 2
#DEFINE FIELDTYPE 3
#DEFINE FIELDVISIBLE 4
#DEFINE TYPEFORMAT 5
#DEFINE DECIMAFORMAT 6
#DEFINE STRCOLM 4 // columns for String, Numeric has more columns
#DEFINE DEFAULTPARVAL '*'

/*/{Protheus.doc} RU06XREP01, formerly fill_db_field
    fills an array for creation of the temporary DB table based on SX3 data
    @author Maxim Popenker
    @since  29/01/2024
    @type
    @version 12.1.2310
    @param  aStruc,  Array,      list of the fields for selected data table  and their properties.
    @param  cFieldname, Char,    field name from the SX3 table
/*/
function RU06XREP01_Fill_Field_From_DB(aStruc, cFieldname)

    aadd(aStruc,{cFieldname ,GetSx3Cache(cFieldname,"X3_TIPO"), GetSx3Cache(cFieldname,"X3_TAMANHO"), GetSx3Cache( cFieldname, "X3_DECIMAL" )})

Return 


/*/{Protheus.doc} RU06XREP02, formerly Fill_json_colums
    generates Json columns for a table
    @author Maxim Popenker
    @since  29/01/2024
    @param  aFields,  Array,      list of the fields for selected data structure and their properties.
    @param  oDataGridOut, Object,      Json grid object
    @version 12.1.2310
/*/

function RU06XREP02_Fill_Json_Columns( aFieldsIn, oDataGridOut)
    local nX
    local oCol
    local oFormat 
    local oJsonCSS 

   For nX:=1 To Len(aFieldsIn)
      oCol := GetDxModel('columns')
      oCol['dataField'] := aFieldsIn[nX,FIELDNAME]
      oCol['caption']   := Alltrim(aFieldsIn[nX,FIELDDESC])
      oCol['dataType']  := aFieldsIn[nX,FIELDTYPE]
      oFormat  := JsonObject():New()
      oJsonCSS := JsonObject():New()

      If (aFieldsIn[nX,FIELDTYPE]=="number")
         If len(aFieldsIn[nX])>STRCOLM .and. !empty(aFieldsIn[nX,TYPEFORMAT])
            oFormat['type'] := aFieldsIn[nX,TYPEFORMAT]
            if !Empty(aFieldsIn[nX,DECIMAFORMAT])
               oFormat['precision'] := aFieldsIn[nX,DECIMAFORMAT]
            Endif
            oCol['format'] := oFormat
         Endif

         oJsonCSS:FromJson('{"rowType":"header","settings": [{"cssKey":"text-align","value":"center"}]}')
         oCol['__customCss']:= {}
         aadd(oCol['__customCss'],oJsonCSS)
      Else
        oCol['allowGrouping']   := .T.
        If (aFieldsIn[nX,FIELDTYPE]=="date")
            oCol['format'] := "dd.MM.yyyy"
        endif
      Endif

      aadd(oDataGridOut['columns'], oCol)
      FreeObj(oCol)
      FreeObj(oJsonCSS)
      FreeObj(oFormat)
    Next
    
Return


/*/{Protheus.doc} RU06XREP03
    generates and returns complete json string for report
    @type  Function
    @author Dsidorenko
    @since 05/03/2024
    @version 12.1.2310
    @param aGrarr, array, array with all grids for report
    @oDD, object, DxModel for drildown
    @oDDdef, object, drilldown defeninition
    @aTitle, array, array with grid titles for report
    @aCode, array, array with grid codes for report
    @cMainTitle, Character, report title
    @cDDType, Character, drilldown type
    @return cRet, Character, complete JSON
/*/
Function RU06XREP03_Fill_Final_String(aGrarr, oDD, oDDdef, aTitle, aCode, cMainTitle, cDDType)

    Local nCount
    Local cRet 
    default oDD := GetDxModel('main')

    cRet :=  '{"data": { "sections": ['
    For nCount := 1 To Len(aGrarr) 
        if nCount != 1
            cRet += ','
        ENDIF
        cRet += '{"dxDataGridSetup": '+aGrarr[nCount]:toJSon()+", "
        cRet += ' "title": "'+aTitle[nCount]+'",'
        cRet += ' "code": "'+aCode[nCount]+'",'
        cRet += ' "section": '+(CVALTOCHAR(nCount - 1))+','
        cRet += ' "file": "SECTION'+ CVALTOCHAR(nCount)+'"}' 
    Next

    cRet += '],'

    cRet +=         '"drillDowns": ['+;
                    '{'
    If !Empty(oDD['height'])
        cRet +=     '"dxDataGridSetup": '+oDD:toJSon()+', '
    Endif
    cRet +=                         ' "title": "DrillDown1",'+;
                                    ' "code": "'+ oDDdef['drillDownGridId'] +'",'+;
                                    ' "section": '+CVALTOCHAR(len(aGrarr) + 1)+','+;
                                    ' "drillDownType": "' + cDDType +'"}'+;
                                    '],'
    cRet +=         ' "drillDownDefs": [' +;
                                        oDDdef:toJSon()+;
                                    '],'

    cRet +=         ' "showRecall": false, '+;
                    ' "showFlatView": false,'+;
                   ' "sectionsQuantity": ' + CVALTOCHAR(Len(aGrarr)) +','+;
                   ' "mainTitle": "' + cMainTitle +'" },'
    cRet += ' "status": "ok",'+;
            ' "ok": "ok",'+;
            ' "statusText": "ok"}'

Return cRet

/*/{Protheus.doc} RU06XREP04, formerly fill_ndb_field
    fills an array for creation of the temporary DB table
    @author Maxim Popenker
    @since  13/02/2023
    @type
    @version 12.1.2310
    @param  aStruc,  Array,      list of the fields for selected data table  and their properties.
    @param  cFieldname, Char,    field name from the SX3 table
/*/
Function RU06XREP04_Fill_Custom_Field(aStruc, cFieldname,nLen,nDec, cType)
Default cType := 'N'

    aadd(aStruc,{cFieldname ,cType, nLen, nDec})

Return
                   
//Merge Russia R14 
                   
