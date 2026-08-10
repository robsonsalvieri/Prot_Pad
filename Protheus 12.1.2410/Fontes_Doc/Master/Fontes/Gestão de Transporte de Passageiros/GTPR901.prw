#INCLUDE "rwmake.ch"
#INCLUDE "RPTDEF.CH"
#INCLUDE "FWPrintSetup.ch"
#INCLUDE "protheus.ch"
#INCLUDE "TOTVS.ch"
#INCLUDE 'GTPR901.CH'

/*/{Protheus.doc} GTPR310
Rel. Lista de passageiros
@type function
@author Flávio Martins
@since 26/01/2024
@version 1.0
@return ${return}, ${return_description}
@example
(examples)
@see (links_or_references)
/*/
Function GTPR901()
	
	Local cPerg 	:= "GTPR901"

	If  GQ8->(ColumnPos("GQ8_CODG6R")) > 0
		If Pergunte( cPerg, .T. )
			oReport := ReportDef( cPerg )
			oReport:PrintDialog()
		Endif
	else
 		Help( ,, 'Help',"GTPR901", STR0001, 1, 0 )//"Campo Cód. Orçamento não existe na Tabela."
	Endif

Return()

/*/{Protheus.doc} ReportDef
Função responsavel para definição do layout do relatório
@type function
@author Flávio Martins
@since 26/01/2024
@version 1.0
@param cAliasTmp, character, (Descrição do parâmetro)
@return ${return}, ${return_description}
@example
(examples)
@see (links_or_references)
/*/
Static Function ReportDef()

	Local oReport
	Local oSecViagem		:= Nil
	Local oSecPassag		:= Nil
	Local cTitulo 			:= '[GTPR901] - '+ "Lista de Passageiros"
	Local cAliasTmp			:= QryLista()
	
	oReport := TReport():New('GTPR901', cTitulo, , {|oReport| PrintReport(oReport,cAliasTmp)}, 'Este relatório ira imprimir a lista de passageiros' ,,,.T.  ) 
	oReport:SetLandsCape(.T.)

	//Monstando a primeira seção
	oSecViagem := TRSection():New( oReport, "Viagem" ,{cAliasTmp} )
	TRCell():New(oSecViagem , "GQ8_CODIGO"	, cAliasTmp , RetTitle("GQ8_CODIGO")	, PesqPict("GQ8","GQ8_CODIGO") 	, TamSX3("GQ8_CODIGO")[1])
	TRCell():New(oSecViagem , "GQ8_DESCRI"	, cAliasTmp , RetTitle("GQ8_DESCRI")	, PesqPict("GQ8","GQ8_DESCRI") 	, TamSX3("GQ8_DESCRI")[1])
	TRCell():New(oSecViagem , "GQ8_CODGY0"	, cAliasTmp , RetTitle("GQ8_CODGY0")	, PesqPict("GQ8","GQ8_CODGY0") 	, TamSX3("GQ8_CODGY0")[1])
	TRCell():New(oSecViagem , "GQ8_CODGYD"	, cAliasTmp , RetTitle("GQ8_CODGYD")	, PesqPict("GQ8","GQ8_CODGYD") 	, TamSX3("GQ8_CODGYD")[1])
	TRCell():New(oSecViagem , "GQ8_CODG6R"	, cAliasTmp , RetTitle("GQ8_CODG6R")	, PesqPict("GQ8","GQ8_CODG6R") 	, TamSX3("GQ8_CODG6R")[1])

	//A segunda seção, será apresentado os produtos
	oSecPassag 	:= TRSection():New(oReport, "Passageiros"	, 	{cAliasTmp}  , , .F., .T.)
	oSecPassag:SetLeftMargin(05) 
	TRCell():New(oSecPassag	, "GQB_ITEM"	, cAliasTmp , RetTitle("GQB_ITEM")   	, PesqPict("GQB","GQB_ITEM")   	, TamSX3("GQB_ITEM")[1])
   	TRCell():New(oSecPassag	, "GQB_NOME"	, cAliasTmp , RetTitle("GQB_NOME")   	, PesqPict("GQB","GQB_NOME")   	, 80)
   	TRCell():New(oSecPassag	, "GQB_CPF"	   	, cAliasTmp , RetTitle("GQB_CPF")    	, PesqPict("GQB","GQB_CPF")     , 20) 
   	TRCell():New(oSecPassag	, "GQB_CEP"	   	, cAliasTmp , RetTitle("GQB_CEP")     	, PesqPict("GQB","GQB_CEP")     , 15)
   	TRCell():New(oSecPassag	, "GQB_ENDERE"	, cAliasTmp , RetTitle("GQB_ENDERE") 	, PesqPict("GQB","GQB_ENDERE") 	, TamSX3("GQB_ENDERE")[1])
   	TRCell():New(oSecPassag	, "GQB_COMPLE"	, cAliasTmp , RetTitle("GQB_COMPLE")	, PesqPict("GQB","GQB_COMPLE") 	, TamSX3("GQB_COMPLE")[1])
   	TRCell():New(oSecPassag	, "GQB_BAIRRO"	, cAliasTmp , RetTitle("GQB_BAIRRO") 	, PesqPict("GQB","GQB_BAIRRO") 	, TamSX3("GQB_BAIRRO")[1])
   	TRCell():New(oSecPassag	, "GQB_MUNICI"	, cAliasTmp , RetTitle("GQB_MUNICI") 	, PesqPict("GQB","GQB_MUNICI") 	, TamSX3("GQB_MUNICI")[1])
   	TRCell():New(oSecPassag	, "GQB_ESTADO"	, cAliasTmp , RetTitle("GQB_ESTADO") 	, PesqPict("GQB","GQB_ESTADO") 	, TamSX3("GQB_ESTADO")[1])

Return (oReport)

/*/{Protheus.doc} PrintReport
(long_description)
@type function
@author Flávio Martins
@since 26/01/2024
@version 1.0
@param oReport, objeto, (objeto de relatorio)
@param cAliasTmp, character, (alias de coleção de dados)
@return ${return}, ${return_description}
@example
(examples)
@see (links_or_references)
/*/
Static Function PrintReport( oReport, cAliasTmp )
 
	Local oSecViagem 	:=	oReport:Section(1)
	Local oSecPassag	:=	oReport:Section(2)
	Local cCodigo 		:=	""
	
	DbSelectArea(cAliasTmp)
	(cAliasTmp)->(dbGoTop())

	While (cAliasTmp)->(!Eof())
		
		If (cAliasTmp)->GQ8_CODIGO <> cCodigo	
		
			oSecViagem:Init()
			oSecViagem:Cell("GQ8_CODIGO"	):SetValue((cAliasTmp)->GQ8_CODIGO	)
			oSecViagem:Cell("GQ8_DESCRI"	):SetValue((cAliasTmp)->GQ8_DESCRI	)	
			oSecViagem:Cell("GQ8_CODGY0"	):SetValue((cAliasTmp)->GQ8_CODGY0	)
			oSecViagem:Cell("GQ8_CODGYD"	):SetValue((cAliasTmp)->GQ8_CODGYD	)
			oSecViagem:Cell("GQ8_CODG6R"	):SetValue((cAliasTmp)->GQ8_CODG6R	)

			oSecViagem:PrintLine()
			oSecViagem:Finish()				
			
			oSecPassag:Init()			

			cCodigo := (cAliasTmp)->GQ8_CODIGO	

		Endif 

		oSecPassag:Cell("GQB_ITEM"   ):SetValue((cAliasTmp)->GQB_ITEM  )
		oSecPassag:Cell("GQB_NOME"   ):SetValue((cAliasTmp)->GQB_NOME  )
		oSecPassag:Cell("GQB_CPF"    ):SetValue((cAliasTmp)->GQB_CPF   )
		oSecPassag:Cell("GQB_CEP"    ):SetValue((cAliasTmp)->GQB_CEP   )
		oSecPassag:Cell("GQB_ENDERE" ):SetValue((cAliasTmp)->GQB_ENDERE)
		oSecPassag:Cell("GQB_COMPLE" ):SetValue((cAliasTmp)->GQB_COMPLE)		
		oSecPassag:Cell("GQB_BAIRRO" ):SetValue((cAliasTmp)->GQB_BAIRRO)
		oSecPassag:Cell("GQB_MUNICI" ):SetValue((cAliasTmp)->GQB_MUNICI)
		oSecPassag:Cell("GQB_ESTADO" ):SetValue((cAliasTmp)->GQB_ESTADO)
		oSecPassag:PrintLine()
		
		(cAliasTmp)->(dbSkip())
      	
		If (cAliasTmp)->GQ8_CODIGO <> cCodigo
	    	oSecPassag:Finish()
			oReport:EndPage()
      	EndIf
   
   EndDo
	
	oReport:EndPage()
	
Return

/*/{Protheus.doc} QryLista
(long_description)
@type function
@author Flávio Martins
@since 26/01/2024
@version 1.0
@return ${return}, ${return_description}
@example
(examples)
@see (links_or_references)
/*/
Static Function QryLista()

Local cAliasTmp	:= GetNextAlias()
Local cOrder     := "%GQ8_CODIGO%"

BeginSql Alias cAliasTmp

	SELECT GQ8.GQ8_CODIGO,
	GQ8.GQ8_DESCRI,
	GQ8.GQ8_CODGY0,
	GQ8.GQ8_CODGYD,
	GQ8.GQ8_CODG6R,
	GQB.GQB_ITEM,
	GQB.GQB_NOME,
	GQB.GQB_CPF,
	GQB.GQB_CEP,
	GQB.GQB_ENDERE,
	GQB.GQB_COMPLE,
	GQB.GQB_BAIRRO,
	GQB.GQB_MUNICI,
	GQB.GQB_ESTADO
	FROM 
	%Table:GQ8% GQ8
	INNER JOIN 
	%Table:GQB% GQB ON
	GQB.GQB_FILIAL = %Exp:xfilial('GQB')% AND 
	GQB.GQB_CODIGO = GQ8.GQ8_CODIGO AND
	GQB.%NotDel%
	WHERE 
	GQ8.GQ8_FILIAL = %Exp:xfilial('GQ8')% AND 
	GQ8.GQ8_CODGY0 BETWEEN %Exp:MV_PAR01% AND %Exp:MV_PAR01% AND 
	GQ8.GQ8_CODGYD BETWEEN %Exp:MV_PAR02% AND %Exp:MV_PAR03%  AND
	GQ8.GQ8_CODG6R BETWEEN %Exp:MV_PAR04% AND %Exp:MV_PAR04% AND 
	GQ8.%NotDel%
	ORDER BY %Exp:cOrder%	

EndSql

Return cAliasTmp
