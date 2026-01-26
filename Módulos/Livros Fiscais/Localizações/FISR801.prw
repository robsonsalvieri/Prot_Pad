#INCLUDE "protheus.ch" 
#INCLUDE "fisr801.ch"
#INCLUDE "RPTDEF.CH"
/*/{Protheus.doc} FISR801
	función de inicio para imprimir el informe de base y valores de un impuesto en específic
	@author adrian.perez
	@since 03/10/2022
	@param param_name, param_type, param_descr
	@return nil
	/*/
Function FISR801()	

Local oReport	:= Nil
local cPerg := 'FISR801' //Grupo de preguntas para parámetros 
local cAlias := getNextAlias()

	oReport := reportDef(cAlias ,cPerg)
	oReport:printDialog()

return

/*/{Protheus.doc} ReportPrint
	Imprime el informe de base y valores de un impuesto en específico de acuerdo a los filtros 
	@author adrian.perez
	@since 03/10/2022
	@param oReport,objeto, definición de la estructura del informe
	@return nil
	/*/

Static Function ReportPrint(oReport)

Local oSection1	:= oReport:Section(1)
Local nBastot:=0
Local nValtot:=0
Local cAreaQuery:=GetNextAlias()
Local cCpo:=""
Local cfechaIni:=dtoc(mv_par02)
Local cfechaFin:=dtoc(mv_par03)
Local cEspecie:=IIF(MV_PAR04==1,"NCP|NDI","NCC|NDE")
Local nAux:=0
Local nAux1:=0
Local aAux:={}
	

	IF !EMPTY(ALLTRIM(MV_PAR01))
		
		aAux:=QueryFBTES()
		cCpo:=aAux[1]
		If Empty(cCpo)
				Help(STR0002+ALLTRIM(MV_PAR01),1,STR0002+ALLTRIM(MV_PAR01) , NIL,STR0003+ALLTRIM(MV_PAR01)+STR0004, 1, 0, NIL, NIL, NIL, NIL, NIL,{STR0005}) //STR0002 Informe de impuestos ,STR0003 "Impuesto ", STR0004 " no encontrado", STR0005 "Verifique impuesto"
			Return .F.
		ENDIF
		
		DBUseArea(.T., "TOPCONN", TCGenQry(,,Query(cCpo,aAux[2])), cAreaQuery, .T., .T.)
		
			oReport:PrintText(OemToAnsi(STR0006) + ALLTRIM(MV_PAR01)) //STR0006 "Informe de la base y valores de impuesto ref al impuesto-"
			oReport:SkipLine()
			oReport:PrintText(OemToAnsi(STR0007) +cfechaIni+STR0008+  cfechaFin) //STR0007 "Periodo Desde:",  "STR0008  Hasta:"
			oReport:SkipLine()
			oReport:PrintText(IIF(MV_PAR04==1,STR0023,STR0024)) //STR0023"Documentos de entrada.","Documentos de salida.
			oReport:SkipLine()
			oSection1:Init()
			
			while !(cAreaQuery)->(Eof())
				nAux:=IIF(ALLTRIM((cAreaQuery)->F3_ESPECIE) $ cEspecie ,((cAreaQuery)->F3_BASIMP)*-1,(cAreaQuery)->F3_BASIMP)
				nAux1:=IIF(ALLTRIM((cAreaQuery)->F3_ESPECIE) $cEspecie,((cAreaQuery)->F3_VALIMP)*-1,(cAreaQuery)->F3_VALIMP) 
				oSection1:Cell("F3_ENTRADA"):SetBlock({||	STOD((cAreaQuery)->F3_ENTRADA)  })
				oSection1:Cell("F3_EMISSAO"):SetBlock({||	STOD((cAreaQuery)->F3_EMISSAO) })
				oSection1:Cell("F3_CLIEFOR"):SetBlock({||	(cAreaQuery)->F3_CLIEFOR })
				oSection1:Cell("F3_LOJA"):SetBlock({||		(cAreaQuery)->F3_LOJA })
				oSection1:Cell("A_NOME"):SetBlock({||		(cAreaQuery)->A_NOME })
				oSection1:Cell("F3_ESPECIE"):SetBlock({||	(cAreaQuery)->F3_ESPECIE })
				oSection1:Cell("F3_SERIE"):SetBlock({||		(cAreaQuery)->F3_SERIE })
				oSection1:Cell("F3_NFISCAL"):SetBlock({||	(cAreaQuery)->F3_NFISCAL })
				oSection1:Cell("F3_BASIMP"):SetBlock({||	 nAux})
				oSection1:Cell("F3_ALQIMP"):SetBlock({||	(cAreaQuery)->F3_ALQIMP })
				oSection1:Cell("F3_VALIMP"):SetBlock({||	nAux1})
				oSection1:PrintLine()
				nBastot+= nAux
				nValtot+=nAux1
				(cAreaQuery)->(DBSkip())
			enddo
		DBCloseArea()

		oReport:SkipLine()
		oReport:ThinLine()
		oSection1:Cell("F3_ENTRADA"):SetBlock({||	STR0011 })//TOTALES
		oSection1:Cell("F3_EMISSAO"):SetBlock({||	" " })
		oSection1:Cell("F3_CLIEFOR"):SetBlock({||	" "})
		oSection1:Cell("F3_LOJA"):SetBlock({||		" " })
		oSection1:Cell("A_NOME"):SetBlock({||		" "})
		oSection1:Cell("F3_ESPECIE"):SetBlock({||	" " })
		oSection1:Cell("F3_SERIE"):SetBlock({||		" " })
		oSection1:Cell("F3_NFISCAL"):SetBlock({||	" " })
		oSection1:Cell("F3_BASIMP"):SetBlock({||	nBastot })
		oSection1:Cell("F3_ALQIMP"):SetBlock({||	" " })
		oSection1:Cell("F3_VALIMP"):SetBlock({||	nValtot })
		oSection1:PrintLine()
		oSection1:Finish()

	ENDIF

return

/*/{Protheus.doc} ReportDef
	Define la esctructura del informe de base y valores de un impuesto en específico de acuerdo a los filtros 
	@author adrian.perez
	@since 03/10/2022
	@param cAlias, carácter, código para ser utilizado por el dbUseArea
	@param cPerg, carácter,grupo de preguntas FISR801
	@return return_var, return_type, return_description
	/*/

Static Function ReportDef(cAlias ,cPerg)

local oReport
local oSection1

DEFAULT cAlias:=getNextAlias()
DEFAULT cPerg:='FISR801' 

	Pergunte(cPerg, .f.)

	oReport := TReport():New('FISR801',STR0009,cPerg,{|oReport|ReportPrint(oReport)},STR0010) // STR0009  Informe de base y valores de impuestos, STR0010   "Permite generar un informe de la base y valores por impuesto"
	oSection1 := TRSection():New(oReport,"InformeFISR801",{cAlias})

	TRCell():New(oSection1,"F3_ENTRADA",cAlias,OemToAnsi(STR0012)) //STR0012"Fecha Digitación"
	TRCell():New(oSection1,"F3_EMISSAO",cAlias,OemToAnsi(STR0013)) //STR0013 "Fecha Emisión"
	TRCell():New(oSection1,"F3_CLIEFOR",cAlias,OemToAnsi(STR0014)) // STR0014 "Código Prov"
	TRCell():New(oSection1,"F3_LOJA",cAlias,OemToAnsi(STR0015))	//STR0015 "Tienda Prov"
	TRCell():New(oSection1,"A_NOME",cAlias,STR0016)	//STR0016 "Nombre Prov"
	TRCell():New(oSection1,"F3_ESPECIE",cAlias,STR0017) //STR0017"Tipo Doc"
	TRCell():New(oSection1,"F3_SERIE",cAlias,STR0018)	//STR0018 "Serie"
	TRCell():New(oSection1,"F3_NFISCAL",cAlias,STR0019,X3Picture("F3_NFISCAL")) // STR0019 "Documento"
	TRCell():New(oSection1,"F3_BASIMP",cAlias,STR0020,X3Picture("F3_BASIMP1")) //"@E 9,999,999,999.99")	//STR0020"Base impuesto"
	TRCell():New(oSection1,"F3_ALQIMP",cAlias,OemToAnsi(STR0021),X3Picture("F3_ALIMP1"))
	TRCell():New(oSection1,"F3_VALIMP",cAlias,STR0022,X3Picture("F3_VALIMP1")) //"Valor Impuesto")

Return(oReport)

/*/{Protheus.doc} Query
	se construye la query en base a los filtros del grupo de preguntas FISR801
	@author adrian.perez
	@since 05/10/2022
	@param cCpo, carácter, número de campo asignado al impuesto para uso en los libros fiscales
	@return cQuerySQL,carácter, consulta SQL para extraer información de la tabla SF3 e imprimir en el reporte
	/*/
Static Function Query(cCpo,cTES)

Local cQuerySQL:=""
Local cTipoMov:=IIF(MV_PAR04==1,"C","V")
Local cEspecie:=IIF(MV_PAR04==1,"'NCP','NDP','NDI','NCI','NF'","'NCC','NDC','NDE','NCE','NF'")
Local cTabla:=IIF(MV_PAR04==1,"2","1")
DEFAULT cCpo:=""
DEFAULT cTES:=""
	IF !Empty(ALLTRIM(mv_par01))
		
		IF !Empty(cCpo)
			
			cQuerySQL := "SELECT  "
			cQuerySQL +=" SUM(F3_BASIMP"+cCpo +") F3_BASIMP,F3_ALQIMP"+cCpo+" F3_ALQIMP,SUM(F3_VALIMP"+cCpo+") F3_VALIMP,"
			cQuerySQL +=" F3_ENTRADA,"
			cQuerySQL +=" F3_EMISSAO,"
			cQuerySQL +=" F3_CLIEFOR,"
			cQuerySQL +=" F3_LOJA,"
			cQuerySQL +=" F3_TIPOMOV,"
			cQuerySQL +=" F3_NFISCAL,"
			cQuerySQL +=" F3_SERIE,"
			cQuerySQL +=" A"+cTabla+"_NOME A_NOME,"
			cQuerySQL +=" F3_ESPECIE"
			cQuerySQL +=" FROM " +RetsqlName("SF3")+" SF3 "
			cQuerySQL +=" LEFT JOIN "+RetsqlName(("SA"+cTabla))+" SA"+cTabla+" ON SF3.F3_CLIEFOR=SA"+cTabla+".A"+cTabla+"_COD"
			cQuerySQL +=" AND SF3.F3_LOJA=SA"+cTabla+".A"+cTabla+"_LOJA"
			cQuerySQL +=" WHERE F3_ESPECIE IN ("+cEspecie+")"
			cQuerySQL +=" AND F3_TIPOMOV='"+cTipoMov+"'"
			cQuerySQL +=" AND F3_ENTRADA >= '" + DTOS(mv_par02) + "'" 
			IF !EMPTY(ALLTRIM(DTOS(mv_par03)))
				cQuerySQL +=" AND  F3_ENTRADA <='" + DTOS(mv_par03) + "'"
			ENDIF
			cQuerySQL +=" AND F3_BASIMP"+cCpo+">0"
			cQuerySQL+= " AND F3_TES IN("+cTES+")"
			cQuerySQL +=" AND SA"+cTabla+".D_E_L_E_T_='' "
			cQuerySQL +=" AND SF3.D_E_L_E_T_='' "

			cQuerySQL +=" GROUP BY F3_ENTRADA,F3_EMISSAO,F3_CLIEFOR,F3_LOJA,F3_TIPOMOV,"
			cQuerySQL +=" F3_ALQIMP"+cCpo+",F3_NFISCAL,F3_SERIE,A"+cTabla+"_NOME,F3_ESPECIE"
			cQuerySQL +=" ORDER BY F3_ENTRADA ASC"
			cQuerySQL := ChangeQuery(cQuerySQL) 
		ENDIF

	ENDIF
Return cQuerySQL

/*/{Protheus.doc} QueryFBTES
    Extrae las TES donde se usa el impuesto filtrado por MV_PAR01, así como el campo usado  de libros fiscales
    @type  Static Function
    @author adrian.perez
    @since 13/10/2022
    @return {}, array, retorna un arreglo con dos posiciones posición 1 campo de libros fiscales usado campo2 cadena con TES
    para filtrar
/*/
Static Function QueryFBTES()
Local cQuery:=""
Local cAreaQuery:=GetNextAlias()
Local cTES:=""
Local cCpo:=""

	cQuery="SELECT FB_CPOLVRO,FC_TES FROM "+RetsqlName("SFB")+" SFB "
	cQuery+=" LEFT JOIN " +RetsqlName("SFC")+" SFC "
	cQuery+=" ON SFB.FB_CODIGO=SFC.FC_IMPOSTO "
	cQuery+=" WHERE  FB_CODIGO='"+ALLTRIM(mv_par01)+"' "
	cQuery+=" AND  SFB.D_E_L_E_T_=''"
	cQuery+=" AND SFC.D_E_L_E_T_=''"
	cQuery := ChangeQuery(cQuery) 

	DBUseArea(.T., "TOPCONN", TCGenQry(,,cQuery), cAreaQuery, .T., .T.)
		WHILE !(cAreaQuery)->(Eof())
			cTES+="'" +(cAreaQuery)->FC_TES+"',"
			(cAreaQuery)->(DBSkip())
		ENDDO
		DBGoTop()
		cCpo:= (cAreaQuery)->FB_CPOLVRO
	DBCloseArea()

	cTES:= SubStr( cTES, 1 , len(cTES)-1  )
Return {cCpo,cTES}
