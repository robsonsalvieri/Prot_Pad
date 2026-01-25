// ######################################################################################
// Projeto: DATA WAREHOUSE
// Modulo : Main
// Fonte  : hImportMeta - Manipula e auxilia na importação de arquivos metadados
// ---------+-------------------+--------------------------------------------------------
// Data     | Autor             | Descricao
// ---------+-------------------+--------------------------------------------------------
// 06.02.06 | Paulo R Vieira    |
// 23.11.07 | 0548-Alan Candido | BOPS 136453 - Correções em procedimentos da migração de 
//          |                   |   versões anteriores a R4
// 07.12.07 | 0548-Alan Candido | BOPS 137338 - Importação e tratamento do "dono",
//          |                   |   caso o "dono" não exista em TAB_USER o mesmo será incluido
// 19.02.08 | 0548-Alan Candido | BOPS 140961 - Emulação de "rename" de tabelas, quando o sgdb
//          |                   |   é Oracle (durante processo de migração R3 para R4)
// 26.02.08 | 0548-Alan Candido | BOPS 141024 - Emulação de "rename" de tabelas, quando o sgdb
//          |                   |   é Informix ou DB2 (durante processo de migração R3 para R4)
// 17.04.08 |0548-Alan Cândido  | BOPS 144476 - ajuste na importação do meta-dados, para suportar
//          |                   | a falta do atributo "dt_create" na dimensão e expressões de 
//          |                   | alertas gerada em duplicata
// 29.04.08 |0548-Alan Cândido  | BOPS 146059 - ajuste na importação do meta-dados, para suportar
//          |                   | os atributos "rankSubTotal" e "rankTotal" da consulta
// 09.12.08 | 0548-Alan Candido | FNC 00000149278/811 (8.11) e 00000149278/912 (9.12)
//          |                   | Adequação de procedimentos para suportar ranking por
//          |                   | nivel de drill-down
// --------------------------------------------------------------------------------------

#include "dwincs.ch"
#include "hDwImportMeta.ch"

/*
--------------------------------------------------------------------------------------
Classe responsável por importar os dados oriundos de um arquivo de metadados.
Realiza a importação das
- Conexões através do método importServers())
- Dimensões através do método importDims())
- Cubos através do método importCubes())
- Consultas através do método importQuerys())
--------------------------------------------------------------------------------------
*/
Class TDWImportMeta from TDWObject
	
	data flCopyCons
	data fnIDTarget
	data fcFileName
	data foXml
	data foXmlSrvs
	data foXmlDims
	data foXmlCubs
	data foXmlQrys
	data faVirtInd
	data faQDoc     
	data flIsNativo
	
	// construtor e destrutor
	method New(acFileName, alCopyCons, anIDTarget) constructor
	method Free()
	
	// métodos principais para importação
	method ImportServes()
	method ImportDims(alRename)
	method importCubes(alRename)
	method importQuerys()
	
	// métodos auxiliares de importação de dimensões e cubos
	method ImportAttributes(oXMLAtt, oDim, oDimFields, alFato)
	method ImportVirtAttributes(oXMLAtt, oDim)
	method ImportDSs(oXMLDSs, oDim, alFato)
	method ImportScripts(oXMLScripts, aoDSN, alFato)
	method ImportScheduler(oXMLScheduler, aoDSN, alFato)
	method isMultiLine(poNode, poNodeName)
	method multiLineText(aoXML)
	method saveText(aaText, alSQL)
	
	// métodos auxiliares para importação de consultas
	method importIndVirtual(aoXML, anConsID, anCubID)
	method importCons(anType, aoXML, anConsID, anCubeID)
	method importLevel(acEixo, aoXML, aoDim, aoDimFields, aoConsulta)
	method importInd(aoXML, aoConsulta)
	method importFilters(aoXML, anConsID, anCubeID) 
	method importAlerts(aoXML, anConsID)
	method importDoc (aoXML, anConsID)
EndClass

/*
--------------------------------------------------------------------------------------
Construtor da classe
Args: 	acFileName, string, contendo o nome do arquivo de metadados
		alCopyCons, lógico, identifica se será realizada uma cópia de uma consulta
		anIDTarget, númerico, caso seja uma cópia (argumento alCopyCons) este argumento é o id a ser copiado
Ret: Não se aplica
--------------------------------------------------------------------------------------
*/
method New(acFileName, alCopyCons, anIDTarget) class TDWImportMeta
	::flCopyCons := alCopyCons
	::fnIDTarget := anIDTarget
	::fcFilename := acFileName
	::foXml := DWLoadXML(::fcFilename)
    
	if !xmlNodeExist(::foXml, "_Datawarehouse")
		DWRaise(ERR_002, SOL_002, "XML file [ " + ::fcFilename + " ]")
	endif
	
	// Verifica se o Arquivo é template para Indicadores Nativos
	if ::foXml:_Datawarehouse:_Template:TEXT == "T"
		::flIsNativo := .T.	
	endif
	
	if xmlNodeExist(::foXml:_Datawarehouse, "_Servers") .and. xmlNodeExist(::foXml:_Datawarehouse:_Servers, "_Server")
		::foXmlSrvs := ::foXml:_Datawarehouse:_Servers
	endif
	
	if xmlNodeExist(::foXml:_Datawarehouse, "_Dimensions") .and. xmlNodeExist(::foXml:_Datawarehouse:_Dimensions, "_Dimension")
		::foXmlDims := ::foXml:_Datawarehouse:_Dimensions
	endif
	
	if xmlNodeExist(::foXml:_Datawarehouse, "_Cubes") .and. xmlNodeExist(::foXml:_Datawarehouse:_Cubes, "_Cube")
		::foXmlCubs := ::foXml:_Datawarehouse:_Cubes
	endif
	
	if xmlNodeExist(::foXml:_Datawarehouse, "_Querys") .and. xmlNodeExist(::foXml:_Datawarehouse:_Querys, "_Query")
		::foXmlQrys := ::foXml:_Datawarehouse:_Querys
	endif
return

/*
--------------------------------------------------------------------------------------
Destrutor da classe
--------------------------------------------------------------------------------------
*/
method Free() class TDWImportMeta
	::flCopyCons 	:= .F.
	::fcFileName 	:= NIL
	::foXml			:= NIL
	::foXmlSrvs		:= NIL
	::foXmlDims		:= NIL
	::foXmlCubs		:= NIL
	::foXmlQrys		:= NIL
	::faVirtInd		:= NIL
	::flIsNativo 	:= NIL
return

/*
--------------------------------------------------------------------------------------
Método responsável por importar as conexões do arquivo metadados
Args: Não se aplica
Ret: Array com o resultado da importação
--------------------------------------------------------------------------------------
*/
method ImportServes() class TDWImportMeta
	local nInd, xServer, oConexao := oSigaDW:Connections(), aJaProc := {}
	local aServer
	local aReturn := {}, oImportServer
	local nId, cName, lIgnored, lSucess
	
	if !(valType(::foXmlSrvs) == "O")
		return NIL
	endif
	
	aServer := iif(valType(::foXmlSrvs:_Server)=="A", ::foXmlSrvs:_Server, { ::foXmlSrvs:_Server })
	
	for nInd := 1 to len(aServer)
		xServer := aServer[nInd]
		xServer:_Nome:Text := upper(delAspas(xServer:_Nome:Text))
		if aScan(aJaProc, { |x| x == xServer:_Nome:Text } ) > 0
			loop
		endif
		aAdd(aJaProc, xServer:_Nome:Text)
			
		cName := delAspas(xServer:_Nome:Text + "-" + xServer:_Descricao:Text)
		if oConexao:Seek(2, { delAspas(xServer:_Tipo:Text), xServer:_Nome:Text })
			lIgnored 	:= .T.
			nId			:= oConexao:value("id")
			lSucess 	:= .T.
		else
			lIgnored 	:= .F.
			aValues := { { "novo", .t. } ,;
						 { "nome", xServer:_Nome:Text } ,;
 						 { "tipo", delAspas(xServer:_Tipo:Text) } , ;
						 { "descricao", delAspas(xServer:_Descricao:Text) } ,;
						 { "caminho", delAspas(xServer:_Caminho:Text) } ,;
						 { "server", delAspas(xServer:_Server:Text) } ,;
						 { "conex_srv", delAspas(xServer:_Conex_srv:Text) } ,;
						 { "banco_srv", delAspas(xServer:_Banco_srv:Text) } ,;
						 { "alias", delAspas(xServer:_Alias:Text) } ,;
						 { "ambiente", delAspas(xServer:_Ambiente:Text) } ,;
						 { "empresa", delAspas(xServer:_Empresa:Text) } ,;
						 { "filial", delAspas(xServer:_Filial:Text) } }
			
			if oConexao:Append(aValues)
				nId		:= oConexao:value("id")
				lSucess := .T.
			else
				nId		:= 0
				lSucess	:= .F.
			endif
		endif
		
		// cria o objeto contendo o resultado da importação
		oImportServer := TDWImportServer():New(nId)
		oImportServer:Name(cName)
		oImportServer:Ignored(lIgnored)
		oImportServer:Sucess(lSucess)
		
		// adiciona o objeto da importação a array de retorno
		aAdd(aReturn, oImportServer)
		
	next
return aReturn

/*
--------------------------------------------------------------------------------------
Método responsável por importar as dimensões do arquivo de metadados
Args: Não se aplica
Ret: Array com o resultado da importação
--------------------------------------------------------------------------------------
*/
method ImportDims(alRename) class TDWImportMeta
	local nInd, oDim := InitTable(TAB_DIMENSAO)
	local aDim
	local aReturn := {}
	local oImportDim
	local nId, cName, lOverrided, lSucess, aAttributes, aDataSources
  local lOk
	
	default alRename := .f.
	
	if !(valType(::foXmlDims) == "O")
		return NIL
	endif
	
	aDim := iif(valType(::foXmlDims:_Dimension)=="A", ::foXmlDims:_Dimension, { ::foXmlDims:_Dimension })
	
	for nInd := 1 to len(aDim)
	  lOk := .f.
		xDim := aDim[nInd]
		
		cName := delAspas(xDim:_Nome:Text) + "-" + delAspas(xDim:_Descricao:Text)
		
		if !::flIsNativo
			if oDim:Seek(2, { upper(delAspas(xDim:_Nome:Text)) })
				oSigaDW:dropDim(oDim:value("id"))
				lOverrided := .T.
			else
				lOverrided := .F.
			endif
		else
			lOverrided := .F.
		endif
		aValues := { { "nome", upper(delAspas(xDim:_Nome:Text)) } ,;
		           { "descricao", delAspas(xDim:_Descricao:Text) } ,;
		   		   { "dt_create", iif(xmlNodeExist(xDim, "_dt_create"), ctod(delAspas(xDim:_Dt_Create:Text)), date()) } ,;
				   { "hr_create", delAspas(xDim:_Hr_Create:Text) } ,;
			 	   { "notificar", delAspas(iif(xmlNodeExist(xDim, "_Notificar"), xDim:_Notificar:Text, "F")) == "T" } ,;
				   { "autoupd", delAspas(iif(xmlNodeExist(xDim, "_Autoupd"), xDim:_Autoupd:Text, "F")) == "T" } ,;
				   { "importado", .T. } }
					 
		if !oDim:Append(aValues)
			lSucess := .F.
		endif
		
		if xmlNodeExist(xDim, "_Attributes") .and. xmlNodeExist(xDim:_Attributes, "_Attribute")
			aAttributes := ::ImportAttributes(xDim:_Attributes, oDim, InitTable(TAB_DIM_FIELDS), .f.)
		else
			aAttributes := {}
		endif
		
		if xmlNodeExist(xDim, "_Datasources") .and. xmlNodeExist(xDim:_Datasources, "_Datasource")
			aDataSources := ::ImportDSs(xDim:_Datasources, oDim, .f.)
		else
			aDataSources := {}
		endif
		
		oDim:update({ {"dt_process", ctod("  /  /  ")}, {"hr_process",""} })
		DWWaitJob(JOB_INITDIM, { oDim:Value("id") },, .T. )
		lSucess := .T.
		
		if alRename
			if sgdb() == DB_ORACLE .or. sgdb() == DB_INFORMIX
				cOldTable := prepOldName(xDim:_DWPrefixo:text, xDim:_Tableid:text, DWDimName(oDim:Value("id")))
				aFields := {}
				
				oSource := TTable():New(cOldTable)
				oSource:open()
				if oSource:isOpen()
					aEval(oSource:fields(), { |x| aAdd(aFields, x[FLD_NAME] )})
					aFields := aSort(aFields)
					aAdd(aFields, "R_E_C_N_O_")
					oSource:close()
				
					oSource := TQuery():new(dwMakeName("INS"))
					oSource:fromList(cOldTable)
					oSource:FieldList(dwConcatWSep(",", aFields))
					oTarget := oSigaDW:OpenDim(oDim:Value("id"))
					aFields := {}
					aEval(oTarget:fields(), { |x| aAdd(aFields, x[FLD_NAME] )})
					oTarget:close()
					aFields := aSort(aFields)
					aAdd(aFields, "R_E_C_N_O_")
         	DWDelAllRec(oTarget:tableName())
					oSource:execSQL(oSource:InsertInto(aFields, DWDimName(oDim:Value("id")),,,.f. ))
					tcDelFile(cOldTable)
  	      lOk := .t.
				endif
			else
				renameTable(prepOldName(xDim:_DWPrefixo:text, xDim:_Tableid:text, DWDimName(oDim:Value("id"))), DWDimName(oDim:Value("id")))
        lOk := .t.
			endif
		else
			lOk := .t.
		endif
		
		// cria o objeto contendo o resultado da importação
    if lOk
		oImportDim := TDWImportDimension():New(nId)
		oImportDim:Name(cName)
		oImportDim:Attributes(aAttributes)
		oImportDim:DataSources(aDataSources)
		oImportDim:Overrided(lOverrided)
		oImportDim:Sucess(lSucess)
		
		// adiciona o objeto da importação a array de retorno
		aAdd(aReturn, oImportDim)
	 endif
	next

return aReturn

/*
--------------------------------------------------------------------------------------
Método responsável por importar os cubos do arquivo de metadados
Args: Não se aplica
Ret: Array com o resultado da importação
--------------------------------------------------------------------------------------
*/
method importCubes(alRename) class TDWImportMeta
	local aCubes
	local nInd, xCube
	local aReturn := {}
	local oImportCube
	local nId, cName, lOverrided, lSucess, aAttributes, aVirtAttr, aDataSources
	local oTarget, oSource, aFields := {}, cOldTable
	local lOk
	
	default alRename := .f.
	
	if !(valType(::foXmlCubs) == "O")
		return NIL
	endif
	
	aCubes := iif(valType(::foXmlCubs:_Cube)=="A", ::foXmlCubs:_Cube, { ::foXmlCubs:_Cube })

	for nInd := 1 to len(aCubes)
		lOk := .f.
		xCube := aCubes[nInd]
		oCubes := oSigaDW:Cubes():CubeList()
		
		if !::flIsNativo
			
			cName := delAspas(xCube:_Nome:Text)
			
			if oCubes:Seek(2, { upper(delAspas(xCube:_Nome:Text)) })
				oSigaDW:dropCube(oCubes:value("id"))
				lOverrided := .T.
			else
				lOverrided := .F.
			endif
		else
			lOverrided := .F.
		endif
		
		aValues := { { "nome", upper(delAspas(xCube:_Nome:Text)) } ,;
		{ "descricao", delAspas(xCube:_Descricao:Text) } ,;
		{ "dt_create", ctod(delAspas(xCube:_Dt_Create:Text)) } ,;
		{ "hr_create", delAspas(xCube:_Hr_Create:Text) } ,;
		{ "importado", .T. } ,;
		{ "notificar", delAspas(iif (xmlNodeExist(xCube, "_Notificar"), xCube:_Notificar:Text, "F")) == "T" } }
		
		if !oCubes:Append(aValues)
			lSucess := .F.
		endif
		
		if xmlNodeExist(xCube, "_Attributes") .and. xmlNodeExist(xCube:_Attributes, "_Attribute")
			aAttributes := ::ImportAttributes(xCube:_Attributes, oCubes, InitTable(TAB_FACTFIELDS), .t.)
			aVirtAttr	:= ::ImportVirtAttributes(xCube:_Attributes, oCubes)
		else
			aAttributes := {}
			aVirtAttr	:= {}
		endif
		
		if xmlNodeExist(xCube, "_Datasources")
			aDataSources := ::importDSs(xCube:_Datasources, oCubes, .t.)
		else
			aDataSources := {}
		endif

		if alRename
			cOldTable := prepOldName(xCube:_DWPrefixo:text, xCube:_Tableid:text, DWCubeName(oCubes:value("id")))
			aFields := {}
			
			oSource := TTable():New(cOldTable)
			oSource:open()
			
			if oSource:isOpen()
				aEval(oSource:fields(), { |x| aAdd(aFields, x[FLD_NAME] )})
				aAdd(aFields, "D_E_L_E_T_")
				aAdd(aFields, "R_E_C_N_O_")
				aFields := aSort(aFields)
				oSource:close()
				
				oSource := TQuery():new(dwMakeName("INS"))
				oSource:fromList(cOldTable)
				oSource:FieldList(dwConcatWSep(",", aFields))
				oTarget := oSigaDW:OpenCube(oCubes:value("id")):fact()
				aFields := {}
				aEval(oTarget:fields(), { |x| aAdd(aFields, x[FLD_NAME] )})
				oTarget:close()
				aAdd(aFields, "D_E_L_E_T_")
				aAdd(aFields, "R_E_C_N_O_")
				aFields := aSort(aFields)
				oSource:execSQL(oSource:InsertInto(aFields, DWCubeName(oCubes:value("id")),,,.f. ))
				tcDelFile(cOldTable)
				lOk := .t.
			endif
		else
			lOk := .t.
		endif
		
		// cria o objeto contendo o resultado da importação
		if lOk
			oImportCube := TDWImportCube():New(nId)
			oImportCube:Name(cName)
			oImportCube:Attributes(aAttributes)
			oImportCube:VirtAttributes(aVirtAttr)
			oImportCube:DataSources(aDataSources)
			oImportCube:Overrided(lOverrided)
			oImportCube:Sucess(lSucess)
			
			// adiciona o objeto da importação a array de retorno
			aAdd(aReturn, oImportCube)
		endif
	next

return aReturn

/*
--------------------------------------------------------------------------------------
Método auxiliar responsável por importar os atributos de uma dimensão OU cubo
Args: 	oXMLAtt, objeto, contendo o nó xml que contem os atributos
		oDim, objeto, contem um objeto do tipo dimensão ou cubo
		oDimFields, objeto, contem os campos de um objeto dimensão ou cubo
		alFato, lógico, indica se a importação será feita com base em um objeto cubo
Ret: Array com o resultado da importação
--------------------------------------------------------------------------------------
*/
method ImportAttributes(oXMLAtt, oDim, oDimFields, alFato) class TDWImportMeta
	local xAtts := iif(valType(oXMLAtt:_Attribute)=="A", oXMLAtt:_Attribute, { oXMLAtt:_Attribute })
	local xAtt, nInd2, aValues, oDimension := iif(alFato, InitTable(TAB_DIMENSAO), nil)
	local oDimCubes := iif(alFato, InitTable(TAB_DIM_CUBES),nil), nSeq := 0
	local aReturn := {}
	local oImportAttribute
	local nId, cName, nKeySeq, cClasse, lSucess, cDimName, lDimExist
	
	for nInd2 := 1 to len(xAtts)
		xAtt := xAtts[nInd2]
		cName := upper(delAspas(xAtt:_Nome:Text))
		aValues := { { "nome", upper(delAspas(xAtt:_Nome:Text)) } ,;
					 { "Descricao", delAspas(xAtt:_Descricao:Text) } ,{ "Mascara", delAspas(xAtt:_Mascara:Text) } ,;
					 { "Tipo", delAspas(xAtt:_Tipo:Text) } , { "NDec", dwval(delAspas(xAtt:_NDec:Text)) } ,;
					 { "Tam", dwVal(delAspas(xAtt:_Tam:Text)) } }
		if xmlNodeExist(xAtt, "_KeySeq")
			aAdd(aValues, { "KeySeq", dwVal(delAspas(xAtt:_KeySeq:Text)) })
			nKeySeq := dwVal(delAspas(xAtt:_KeySeq:Text))
		endif
		if xmlNodeExist(xAtt, "_Visible")
			aAdd(aValues, { "Visible", delAspas(xAtt:_Visible:Text) == "T" })
		else
			aAdd(aValues, { "Visible", .t. })
		endif
		lDimExist := .F.
		if alFato
			if !empty(delAspas(xAtt:_DimName:Text))
				cDimName := upper(delAspas(xAtt:_DimName:Text))
				if !oDimension:Seek(2, { upper(delAspas(xAtt:_DimName:Text)) })
					loop
				endif
				lDimExist := .T.
				aAdd( aValues, { "dimensao", oDimension:value("id")})
			endif
			aAdd( aValues, { "id_cubes", oDim:value("id")})
			aAdd( aValues, { "classe", delAspas(xAtt:_Classe:Text)})
			aAdd( aValues, { "mascara", delAspas(xAtt:_Mascara:Text)})
			cClasse := delAspas(xAtt:_Classe:Text)
		else
			lDimExist := .T.
			aAdd( aValues, { "id_dim", oDim:value("id")})
		endif
		
		if oDimFields:append(aValues)
			if xmlNodeExist(xAtt, "_KeySeq") .and. oDimFields:value("keyseq") != dwVal(delAspas(xAtt:_KeySeq:Text))
				oDimFields:update( { { "KeySeq", dwVal(delAspas(xAtt:_KeySeq:Text))}})
			endif
			cClasse := oDimFields:value("classe")
			if oDimFields:value("classe") == "D"
				nSeq++
				if !oDimCubes:Seek(2, { oDimFields:value("id_cubes"), oDimFields:value("dimensao") })
					oDimCubes:append({ { "id_cube", oDimFields:value("id_cubes") }, ;
					 				   { "id_dim", oDimFields:value("dimensao") }, ;
									   { "seq", nSeq } })
				endif
			endif
		endif
		cClasse := oDimFields:value("classe")
		if oDimFields:value("KeySeq") != 0 .or. oDimFields:value("classe") == "D"
		   	aAdd( aValues, oDimFields:value("nome", .t.) + " (" + dwStr(oDimFields:value("KeySeq")) + ")" )
		else
			aAdd( aValues, oDimFields:value("nome", .t.) )
		endif
		
		// cria o objeto contendo o resultado da importação
		oImportAttribute := TDWImportAttribute():New(nId)
		oImportAttribute:Name(cName)
		oImportAttribute:KeySeq(nKeySeq)
		oImportAttribute:Classe(cClasse)
		oImportAttribute:DimExist(lDimExist)
		oImportAttribute:DimName(cDimName)
		oImportAttribute:Sucess(lSucess)
		
		// adiciona o objeto da importação a array de retorno
		aAdd(aReturn, oImportAttribute)
		
	next
	
return aReturn
	
/*
--------------------------------------------------------------------------------------
Método auxiliar responsável por importar os atributos virtuais de uma dimensão OU cubo
Args: 	oXMLAtt, objeto, contendo o nó xml que contem os atributos
		oDim, objeto, contem um objeto do tipo dimensão ou cubo
Ret: Array com o resultado da importação
--------------------------------------------------------------------------------------
*/
method ImportVirtAttributes(oXMLAtt, oDim) class TDWImportMeta
	
	local oCalc
	local nInd
	local xAtts := iif(valType(oXMLAtt:_Attribute)=="A", oXMLAtt:_Attribute, { oXMLAtt:_Attribute })
	local xAtt
	local aReturn := {}
	local oImportAttribute, lOK
	
	// virtuais
	if xmlNodeExist(oXMLAtt, "_Virtual")
		xAtts := iif(valType(oXMLAtt:_Virtual)=="A", oXMLAtt:_Virtual, { oXMLAtt:_Virtual })
		oCalc := InitTable(TAB_FACTVIRTUAL)
		for nInd := 1 to len(xAtts)
			xAtt := xAtts[nInd]
			aValues := { { "nome", upper(delAspas(xAtt:_Nome:Text)) } ,;
						 { "Descricao", delAspas(xAtt:_Descricao:Text) }, ;
						 { "Mascara", delAspas(xAtt:_Mascara:Text) } ,;
	                     { "NDec", dwval(delAspas(xAtt:_NDec:Text)) } ,;
	                     { "Tam", dwVal(delAspas(xAtt:_Tam:Text)) } ,;
			             { "id_expr", ::saveText(xAtt:_Expression:Text, .t.) } }
			aAdd( aValues, { "id_cubes", oDim:value("id")})
			lOK := oCalc:append(aValues)
			
			// cria o objeto contendo o resultado da importação
			oImportAttribute := TDWImportAttribute():New(oCalc:value("id"))
			oImportAttribute:Name(oCalc:value("nome"))
			oImportAttribute:DimExist(.T.)
			oImportAttribute:DimName(oDim:value("nome"))
			oImportAttribute:Sucess(lOK)
			
			// adiciona o objeto da importação a array de retorno
			aAdd(aReturn, oImportAttribute)
		next
	endif
	
return aReturn

/*
--------------------------------------------------------------------------------------
Método auxiliar responsável por importar fontes de dados  de uma dimensão OU cubo
Args: 	oXMLDSs, objeto, contendo o nó xml que contem as fontes de dados
		oDim, objeto, contem um objeto do tipo dimensão ou cubo
		alFato, lógico, indica se a importação será feita com base em um objeto cubo
Ret: Array com o resultado da importação
--------------------------------------------------------------------------------------
*/
method ImportDSs(oXMLDSs, oDim, alFato) class TDWImportMeta
	local aDS
	local nInd2, xDS, aValues
	local oDSN := InitTable(TAB_DSN), oConexao := oSigaDW:Connections()
	local aReturn := {}
	local oImportDS
	local nId, cName, cTypeConn, lSucess, aScripts, aSchedulers

	if xmlNodeExist(oXMLDSs, "_Datasource")
		if valType(oXMLDSs:_Datasource)=="A"
			aDS := oXMLDSs:_Datasource
		else
			aDS := { oXMLDSs:_Datasource }
		endif
	else
		return NIL
	endif
	
	for nInd2 := 1 to len(aDS)
		aAux := {}
		xDS := aDS[nInd2]
		if valType(xDS) == "O" .and. xmlNodeExist(xDS, "_Tipo_Conn")
			xDS:_Connector:Text := upper(delAspas(xDS:_Connector:Text))
			
			/*Recupera as informaçãoes da fontes de dados a partir do metadado.*/
			cName 		:= delAspas(xDS:_Nome:Text)
			cTypeConn 	:= delAspas(xDS:_Tipo_Conn:Text) 

			if xmlNodeExist(xDS, "_EmbedSql")
				cEmbedSql := dwConvTo("L", xDS:_EmbedSql:Text)
			else
				cEmbedSql := .F.
			endif
			xDS:_Tipo:Text := delAspas(xDS:_Tipo:Text)
      		xDS:_Tipo:Text := iif(xDS:_Tipo:Text=="F", "C", xDS:_Tipo:Text)
			if oConexao:Seek(2, { delAspas(xDS:_Tipo_Conn:Text), xDS:_Connector:Text })
				aValues := { { "tipo", xDS:_Tipo:Text } ,;
							 { "id_table", oDim:value("id") } ,;
		 					 { "nome", delAspas(xDS:_Nome:Text) } ,;
				  		 	 { "Descricao", delAspas(xDS:_Descricao:Text) } ,;
							 { "id_connect", oConexao:value("id") } ,;
							 { "empfil", delAspas(xDS:_EmpFil:Text) } ,;
							 { "caminho", iif(!empty(xDS:_Caminho:Text), delAspas(xDS:_Caminho:Text), oConexao:value("caminho")) } ,;
							 { "arquivo", delAspas(xDS:_Arquivo:Text) } ,;							 
							 { "ProcInv", delAspas(xDS:_ProcInv:Text) } ,;							  
							 { "UpdMethod", delAspas(xDS:_UpdMethod:Text) } ,; 
							 { "RptInval", delAspas(xDS:_RptInval:Text) } ,; 
							 { "ProcCons", iif( delAspas(xDS:_ProcCons:Text) == "T", .T., .F.) } ,; 							 
							 { "embedsql", cEmbedSql } ,;
							 { "alias", delAspas(xDS:_Alias:Text) }}
				if ::isMultiLine(xDS, "_Sql")
					aAdd(aValues, { "id_sql" , ::saveText(::multiLineText(xDS:_SQl), .t.) })
				elseif xmlNodeExist(xDS, "_Sql") .and. !empty(xDS:_SQl:Text)
					aAdd(aValues, { "id_sql" , ::saveText(xDS:_SQl:Text, .t.) })
				endif
				if ::isMultiLine(xDS, "_SqlStruc")
					aAdd(aValues, { "id_sqlstru" , ::saveText(::multiLineText(xDS:_SqlStruc), .t.) })
				elseif xmlNodeExist(xDS, "_SqlStruc") .and. !empty(xDS:_SQlStruc:Text)
					aAdd(aValues, { "id_sqlstru" , ::saveText(xDS:_SQlStruc:Text, .t.) })
				endif
				if ::isMultiLine(xDS, "_Filter")
					aAdd(aValues, { "id_filter" , ::saveText(::multiLineText(xDS:_Filter), .t.) })
				elseif xmlNodeExist(xDS, "_Filter") .and. !empty(xDS:_Filter:Text)
					aAdd(aValues, { "id_Filter" , ::saveText(xDS:_Filter:Text, .f.) })
				endif
				if ::isMultiLine(xDS, "_BeforeExec")
					aAdd(aValues, { "id_b_exec" , ::saveText(::multiLineText(xDS:_BeforeExec), .t.) })
				elseif xmlNodeExist(xDS, "_BeforeExec") .and. !empty(xDS:_BeforeExec:Text)
					aAdd(aValues, { "id_b_exec" , ::saveText(xDS:_BeforeExec:Text, .f.) })
				endif
				if ::isMultiLine(xDS, "_AfterExec")
					aAdd(aValues, { "id_a_exec" , ::saveText(::multiLineText(xDS:_AfterExec), .t.) })
				elseif xmlNodeExist(xDS, "_AfterExec") .and. !empty(xDS:_AfterExec:Text)
					aAdd(aValues, { "id_a_exec" , ::saveText(xDS:_AfterExec:Text, .f.) })
				endif
				if ::isMultiLine(xDS, "_ForZap")
					aAdd(aValues, { "id_forZap" , ::saveText(::multiLineText(xDS:_ForZap), .t.) })
				elseif xmlNodeExist(xDS, "_ForZap") .and. !empty(xDS:_ForZap:Text)
					aAdd(aValues, { "id_ForZap" , ::saveText(xDS:_ForZap:Text, .f.) })
				endif
				if ::isMultiLine(xDS, "_Valida")
					aAdd(aValues, { "id_Valida" , ::saveText(::multiLineText(xDS:_Valida), .t.) })
				elseif xmlNodeExist(xDS, "_Valida") .and. !empty(xDS:_Valida:Text)
					aAdd(aValues, { "id_Valida" , ::saveText(xDS:_Valida:Text, .f.) })
				endif
				
				if oDSN:append(aValues)
					lSucess := .T.
				else
					oDSN:Seek(3, { aValues[5,2] })
					lSucess := .F.
				endif
				
				if xmlNodeExist(xDS, "_Scripts") .and. xmlNodeExist(xDS:_Scripts, "_Script")
					aScripts := ::ImportScripts(xDS:_Scripts, oDSN, alFato)
				else
					aScripts := {}
				endif
				
				if xmlNodeExist(xDS, "_Schedulers") .and. xmlNodeExist(xDS:_Schedulers, "_Scheduler")
					aSchedulers := ::ImportScheduler(xDS:_Schedulers, oDSN, alFato)
				else
					aSchedulers := {}
				endif
			else
				lSucess := .F.
			endif
		endif
	
		// cria o objeto contendo o resultado da importação
		oImportDS := TDWImportDS():New(nId)
		oImportDS:Name(cName)
		oImportDS:TypeConn(cTypeConn)
		oImportDS:Scripts(aScripts)
		oImportDS:Schedulers(aSchedulers)
		oImportDS:Sucess(lSucess)
		
		// adiciona o objeto da importação a array de retorno
		aAdd(aReturn, oImportDS)
		
	next
	
return aReturn

/*
--------------------------------------------------------------------------------------
Método auxiliar responsável por importar scripts de fonte de dados de uma dimensão OU cubo
Args: 	oXMLScripts, objeto, contendo o nó xml que contem os scripts de fontes de dados
		aoDSN, objeto, contem um objeto do tipo de fonte de dados
		alFato, lógico, indica se a importação será feita com base em um objeto cubo
Ret: Array com o resultado da importação
--------------------------------------------------------------------------------------
*/
method ImportScripts(oXMLScripts, aoDSN, alFato) class TDWImportMeta
	local aScripts := iif(valType(oXMLScripts:_Script)=="A", oXMLScripts:_Script, { oXMLScripts:_Script })
	local nInd2, xScript, aValues
	local oFields := InitTable(iif(aoDSN:value("Tipo")=="D", TAB_DIM_FIELDS, TAB_FACTFIELDS))
	local oDSNConf := initTable(TAB_DSNCONF)
	local aReturn := {}
	local oImportScript, nId, cName, cField, cCpoorig, cExpression, lSucess
	
	for nInd2 := 1 to len(aScripts)
		xScript := aScripts[nInd2]                    
		xScript:_Field:Text := upper(delAspas(xScript:_Field:Text))
		cField := xScript:_Field:Text
		if oFields:Seek(2, { aoDSN:value("id_table"),  xScript:_Field:Text})
			aValues := { { "id_dsn", aoDSN:value("id") } ,;
						 { "id_field", oFields:value("id") } ,;
						 { "cpoorig", delAspas(xScript:_CpoOrig:Text) } }
			if xmlNodeExist(xScript, "_Expr") .and. !empty(delAspas(xScript:_Expr:Text))
				aAdd(aValues, { "id_expr" , ::saveText(delAspas(xScript:_Expr:Text), .f.) })
			endif
			if xmlNodeExist(xScript, "_Valida") .and. !empty(delAspas(xScript:_Valida:Text))
				aAdd(aValues, { "id_Valida" , ::saveText(delAspas(xScript:_Valida:Text), .f.) })
			endif
			
			if oDSNConf:append(aValues)
				lSucess := .T.
			else
				lSucess := .F.
			endif
			
			cName 		:= oFields:value("nome", .t.)
			cCpoorig 	:= oDSNConf:value("cpoorig")
			if oDSNConf:value("id_expr") != 0
				cExpression := delAspas(xScript:_Expr:Text)
			endif
		else
			lSucess := .F.
		endif
		
		// cria o objeto contendo o resultado da importação
		oImportScript := TDWImportScript():New(nId)
		oImportScript:Name(cName)
		oImportScript:Field(cField)
		oImportScript:Cpoorig(cCpoorig)
		oImportScript:Expression(cExpression)
		oImportScript:Sucess(lSucess)
		
		// adiciona o objeto da importação a array de retorno
		aAdd(aReturn, oImportScript)
	next
	
return aReturn

/*
--------------------------------------------------------------------------------------
Método auxiliar responsável por importar os agendamentos das fontes de dados
Args: 	oXMLScheduler, objeto, contendo o nó xml que contem os agendamentos
		aoDSN, objeto, contem um objeto do tipo de fonte de dados
		alFato, lógico, indica se a importação será feita com base em um objeto cubo
Ret: Array com o resultado da importação
--------------------------------------------------------------------------------------
*/
method ImportScheduler(oXMLScheduler, aoDSN, alFato) class TDWImportMeta
	local aSchedulers := iif(valType(oXMLScheduler:_Scheduler)=="A", oXMLScheduler:_Scheduler, { oXMLScheduler:_Scheduler })
	local nInd2, xScheduler, aValues
	local oSXM := InitTable(TAB_SXM)
	local aReturn := {}
	local oImportScheduler, lOK
	
	for nInd2 := 1 to len(aSchedulers)
		xScheduler := aSchedulers[nInd2]
		aValues := { { "id_dsn"      , aoDSN:value("id") } , ;
					 { "agtipo"      , dwVal(delAspas(xScheduler:_Agtipo:Text)) } , ;
 					 { "XM_TIPO"     , dwVal(delAspas(xScheduler:_XM_Tipo:Text)) } , ;
					 { "XM_ATIVO"    , delAspas(xScheduler:_XM_Ativo:Text) == "T" } , ;
					 { "XM_DTINI"    , cToD(delAspas(xScheduler:_XM_DtIni:Text)) } , ;
					 { "XM_HRINI"    , delAspas(xScheduler:_XM_HrIni:Text) } , ;
					 { "XM_DTFIM"    , cToD(delAspas(xScheduler:_XM_DtFim:Text)) } , ;
					 { "XM_HRFIM"    , delAspas(xScheduler:_XM_HrFim:Text) } , ;
					 { "XM_INTERV"   , delAspas(xScheduler:_XM_Interv:Text) } , ;
					 { "XM_SEMANA"   , delAspas(xScheduler:_XM_Semana:Text) } , ;
					 { "XM_MENSAL"   , delAspas(xScheduler:_XM_Mensal:Text) } }
		lOK := oSXM:append(aValues)
		
		// cria o objeto contendo o resultado da importação
		oImportScheduler := TDWImportScheduler():New(aoDSN:value("id"))
		oImportScheduler:DateBegin(DwStr(oSXM:value("XM_DtIni")))
		oImportScheduler:HourBegin(DwStr(oSXM:value("XM_HrIni")))
		oImportScheduler:DateEnd(DwStr(oSXM:value("XM_DtFim")))
		oImportScheduler:HourEnd(DwStr(oSXM:value("XM_HrFim")))
		oImportScheduler:Sucess(lOK)
		
		// adiciona o objeto da importação a array de retorno
		aAdd(aReturn, oImportScheduler)
		
	next
return aReturn

/*
--------------------------------------------------------------------------------------
Método auxiliar responsável verificar se um nó existe e se este é do tipo multiline
Args: 	poNode, objeto, contem o nó raiz a ser verificado
		poNodeName, string, nome do nó
Ret: .T. caso exista e seja multiline, .F. caso contrário
--------------------------------------------------------------------------------------
*/
method isMultiLine(poNode, poNodeName) class TDWImportMeta
	local lRet := .f., oAux

	if xmlNodeExist(poNode, poNodeName)
		oAux := getXmlNode(poNode, poNodeName)
		lRet := xmlNodeExist(oAux, "_MULTILINE")
		lRet := lRet .and. xmlNodeExist(oAux, "_Line")
	endif

return lRet

/*
--------------------------------------------------------------------------------------
Método auxiliar responsável recuperar o multilinetext de um nó existe
Args: 	aoXML, objeto, contem o nó raiz
Ret: Array, contendo os conteúdos do multilinetext para o nó passado como argumento
--------------------------------------------------------------------------------------
*/
method multiLineText(aoXML) class TDWImportMeta
	local aAux := iif(valType(aoXML:_Line) == "A", aoXML:_Line, { aoXML:_Line })
	local cTrab := "", nInd
	local aRet := {}

	for nInd := 1 to len(aAux)
		cTrab := delAspas(aAux[nInd]:Text)
		aadd(aRet, strTran(cTrab, "&#0D;", CRLF))
	next

return aRet

/*
--------------------------------------------------------------------------------------
Método auxiliar responsável acrescentar um registro a tabela de expressões do banco de
dados com o(s) valor(es) do argumento aaText
Args: 	aaText, array ou string, contem o valor a ser acrescentado
		alSQL, lógico, indica se o valor é do tipo SQL
Ret: Inteiro, contem o id do último elemento inserido na base de dadoos
--------------------------------------------------------------------------------------
*/
method saveText(aaText, alSQL) class TDWImportMeta
	local aSource := {}, nInd
	local nID := 0, oDataset := InitTable(TAB_EXPR)
	local acText := ""
	
	default alSQL := .f.
	
	If ValType(aaText) != "A"
		If aaText == Nil		
			Return ::saveText({}, alSQL)
		Else
			Return ::saveText(DwToken(aaText, LF, .T.), alSQL)
		EndIf
	EndIf
	
	If Len(aaText) != 0
		for nInd := 1 to len(aaText)
		  acText := strTran(DwStr(aaText[nInd]), chr(10), chr(13))
		  aadd(aSource, DWTrataImpXML(acText))
		next
	EndIf
	
	if len(aSource) != 0
		oDataset:Append({ { "seq", 1 } })
		nID := oDataset:value("id")
		for nInd := 1 to len(aSource)
			if len(aSource[nInd])!=0
				if oDataset:Seek(2, { nID, nInd })
					oDataset:update( { { "linha", aSource[nInd]}, { "issql", alSQL }})
				else
					oDataset:append( { { "id", nID}, { "seq", nInd }, { "linha", aSource[nInd], { "issql", alSQL }} })
				endif
			endif
		next
	endif
return nID

/*
--------------------------------------------------------------------------------------
Método responsável por importar as consultas do arquivo de metadados
Args: Não se aplica
Ret: Array com o resultado da importação
--------------------------------------------------------------------------------------
*/
method importQuerys() class TDWImportMeta
	local aQuery
	local nInd, xQuery, oCons := InitTable(TAB_CONSULTAS)
	local oCubes := oSigaDW:Cubes():CubeList(), lOk := .t.
	local aReturn := {}
	local oImportQuery
	local nId, cName, lOverrided, lSucess, cCubeName, lCubeExist, aVirtIndicators, aTables, aGraphics, aFilters, aAlerts, aDoc
	local oTabUser
	local nIDUser := iif(valType(oUserDw) == "U", 0, oUserDw:UserID()), nIDGrupo

	if !(valType(::foXmlQrys) == "O")
		return NIL
	endif
	
	oTabUser := initTable(TAB_USER)
	oTabUser:seek(2, { "GRP_USR" }, .F.)
	nIDGrupo := oTabUser:value("id")

	aQuery := iif(valType(::foXmlQrys:_Query)=="A", ::foXmlQrys:_Query, { ::foXmlQrys:_Query })
	for nInd := 1 to len(aQuery)
		xQuery := aQuery[nInd]
		::faVirtInd := {}
		
		cName := delAspas(xQuery:_Nome:Text)
		if ::flCopyCons
			if oCons:Seek(1, { ::fnIDTarget } )
				xQuery:_Nome:Text := oCons:value("nome")
				xQuery:_Descricao:Text := oCons:value("descricao")
			endif
		else
			if !::flIsNativo
				if xmlNodeExist(xQuery, "_Login")
				  	xQuery:_Login:Text := delAspas(xQuery:_Login:Text)
			      	if !oTabUser:seek(3, { xQuery:_Login:Text }, .f.)
	    		    	oTabUser:append( { { "login"   , xQuery:_Login:Text }, ;
										           { "senha"   , DWCripto(pswencript("_ADM_"), PASSWORD_SIZE, 0) }, ;
										           { "nome"    , xQuery:_Login:Text }, ;
										           { "tipo"    , "U" }, ;
										           { "id_grupo", nIDGrupo }, ;
										           { "email"   , "" }, ;
										           { "cargo"   , "" }, ;
										           { "admin"   , .F. }, ;
										           { "ativo"   , .F. }, ;
										           { "us_siga" , .F. } } )
		      		endif
	        		nIDUser := oTabUser:value("id")
	        	else
	        		nIDUser := oUserDW:UserID()
	        	endif
				if oCons:Seek(8, { delAspas(xQuery:_Tipo:Text), nIDUser, upper(delAspas(xQuery:_Nome:Text)) }, .f.)
					oSigaDW:DropCons(oCons:value("id"))
					lOverrided := .T.
				else
					lOverrided := .F.
				endif
			else
				lOverrided := .F.
			endif
		endif
		cCubeName := upper(delAspas(xQuery:_Cube:Text))
		if oCubes:Seek(2, { cCubeName }, .f.)
			aValues := { { "tipo", delAspas(xQuery:_Tipo:Text) },;
						 { "excel", xQuery:_Excel:Text == "T" }, ;
						 { "nome", upper(delAspas(xQuery:_Nome:Text)) },;
						 { "publica", delAspas(xQuery:_Publica:Text) == "T" },;
						 { "descricao", delAspas(xQuery:_Descricao:Text) },;
						 { "id_cube", oCubes:value("id") }, ;
						 { "valida", .f. },;
						 { "valgra", .f. },;
						 { "id_user", nIDUser } }
			
			lCubeExist	:= .T.
			if !::flCopyCons
				lOk := oCons:append(aValues)
			else
				lOk := .t.
			endif
			
			lSucess := lOk
			
			if lOk
				if xmlNodeExist(xQuery, "_virtualFields") .and. xmlNodeExist(xQuery:_virtualFields, "_Field")
					aVirtIndicators := ::importIndVirtual(xQuery:_VirtualFields, oCons:value("id"), oCubes:value("id"))
				else
					aVirtIndicators := {}
				endif
	
				if xmlNodeExist(xQuery, "_Table")
				  	conout("... " + STR0001 + " " + oCons:value("nome") + ' - Prop. ' + oCons:value("login")) //###"processando consulta (tabela)"
					aTables := ::importCons(TYPE_TABLE, xQuery:_Table, oCons:value("id"), oCubes:value("id"))
				else
					aTables := {}
				endif
				
				if xmlNodeExist(xQuery, "_Graphic")
				  	conout("... " + STR0002 + oCons:value("nome") + ' - Prop. ' + oCons:value("login")) //###"processando consulta (gráfico)"
					aGraphics := ::importCons(TYPE_GRAPH, xQuery:_Graphic, oCons:value("id"), oCubes:value("id"))
				else
					aGraphics := {}
				endif
							
				if xmlNodeExist(xQuery, "_Filters") .and. xmlNodeExist(xQuery:_Filters, "_Filter")
					aFilters := ::importFilters(xQuery:_Filters, oCons:value("id"), oCons:value("id_cube"))
				else
					aFilters := {}
				endif
				
				if xmlNodeExist(xQuery, "_Alerts") .and. xmlNodeExist(xQuery:_Alerts, "_Alert")
					aAlerts := ::importAlerts(xQuery:_Alerts, oCons:value("id"))
				else
					aAlerts := {}
				endif
				
				if ::isMultiLine(xQuery, "_Doc")
					oCons:update ({ { "id_docto", ::saveText(::multiLineText(xQuery:_Doc), .t.) } } )
				endif
				
			endif
		else
			lCubeExist := .F.
		endif
		
		// cria o objeto contendo o resultado da importação
		oImportQuery := TDWImportQuery():New(nId)
		oImportQuery:Name(cName)
		oImportQuery:Overrided(lOverrided)
		oImportQuery:Sucess(lSucess)
		oImportQuery:CubeName(cCubeName)
		oImportQuery:CubeExist(lCubeExist)
		oImportQuery:VirtIndicators(aVirtIndicators)
		oImportQuery:Tables(aTables)
		oImportQuery:Graphics(aGraphics)
		oImportQuery:Filters(aFilters)
		oImportQuery:Alerts(aAlerts) 
		oImportQuery:Doc(aDoc)
		
		// adiciona o objeto da importação a array de retorno
		aAdd(aReturn, oImportQuery)
		
	next
	::faVirtInd := {}
return aReturn

/*
--------------------------------------------------------------------------------------
Método auxiliar responsável por importar os indicadores virtuais de um consulta
Args: 	aoXML, objeto, contendo o nó com os indicadores virtuais
		anConsID, numérico, contendo o ID da consulta
		anCubID, numérico, contendo o ID do cubo relacionado com a consulta
Ret: Array com o resultado da importação
--------------------------------------------------------------------------------------
*/
method importIndVirtual(aoXML, anConsID, anCubID) class TDWImportMeta
	local oCalc := InitTable(TAB_CALC)
	local oFactVirt := InitTable(TAB_FACTVIRTUAL)
	local aFields := iif(valType(aoXML:_Field) == "A", aoXML:_Field, { aoXML:_Field })
	local xField, nInd, lSQL, cAux, cExpSQL := ""
	local aReturn := {}
	local lOK, lOkVrtFld := .F., oImportAttribute
	
	for nInd := 1 to len(aFields)
    	xField := aFields[nInd]
    	cAux := delAspas(iif(xmlNodeExist(xField, '_Name'), upper(xField:_Name:Text), ""))
    	if empty(cAux)
	    	cAux := delAspas(iif(xmlNodeExist(xField, '_Nome'), upper(xField:_Nome:Text), ""))
	    endif
    	if empty(cAux) .or. !xmlNodeExist(xField, "_Descricao")
			loop
		endif
		lOkVrtFld := .F.
		lOK := oCalc:Seek(2, { anConsID, cAux })
		// verifica se o campo virtual é de cubo
		If xmlNodeExist(xField, "_virtual")
			// pesquisa nos campos virtuais de cubo
			If oFactVirt:Seek(2, { anCubID,  cAux })
				// se achar o campo específico nos campos virtuais de cubo, realiza a sincronização desses campos
				sincVirtualFlds(oFactVirt, anCubID, anConsID)
				// pesquisa novamente para recuperar o campo virtual sincronizado para o campo virtual importado
				oCalc:Seek(2, { anConsID, cAux })
				lOk := .T.
				lOkVrtFld := .T.
			Else
				// força a criação do campo virtual na consulta
				lOK := .F.
			EndIf
		EndIf
		
		If !lOk
			lSQL := iif(xmlNodeExist(xField, "_Expression") .and. xmlNodeExist(xField:_Expression, "_IsSQL"), "T" $ xField:_Expression:_IsSQL:Text, .F.)
			if lSQL 
				cExpSQL := ::saveText(xField:_Expression:Text, lSQL)
			else
				cExpSQL := 0
			endif
			lOK := oCalc:Append({{ "ID_CONS", anConsID } ,;
			              { "nome", cAux },;
			              { "descricao", delAspas(xField:_Descricao:Text) },;
			              { "tipo", "N" },;
			              { "tam", dwVal(delAspas(xField:_Tam:Text)) },;
			              { "ndec", dwVal(delAspas(xField:_NDec:Text)) },;
			              { "mascara", delAspas(xField:_Mascara:Text) },;     
			              { "id_expr", cExpSQL } } )
			aAdd(::faVirtInd, { dwval("-"+dwstr(oCalc:Value("ID"))), delAspas(xField:_Nome:Text), dwVal(delAspas(xField:_Tam:Text)), dwVal(delAspas(xField:_NDec:Text)), delAspas(xField:_Descricao:Text), delAspas(xField:_Mascara:Text), "N" } )
		ElseIf lOkVrtFld
			aAdd(::faVirtInd, { dwval("-"+dwstr(oCalc:Value("ID"))), delAspas(xField:_Nome:Text), dwVal(delAspas(xField:_Tam:Text)), dwVal(delAspas(xField:_NDec:Text)), delAspas(xField:_Descricao:Text), delAspas(xField:_Mascara:Text), "N" } )
		else
			lOK := .F.
		endif
		
		// cria o objeto contendo o resultado da importação
		oImportAttribute := TDWImportAttribute():New(oCalc:value("id"))
		oImportAttribute:Name(cAux)
		oImportAttribute:Sucess(lOK)
		
		// adiciona o objeto da importação a array de retorno
		aAdd(aReturn, oImportAttribute)
		
 	next

return aReturn

/*
--------------------------------------------------------------------------------------
Método auxiliar responsável por importar as informações de uma consula
Args: 	anType, númerico, contendo o tipo da consulta
		aoXML, objeto, contendo o nó com os indicadores virtuais
		anConsID, numérico, contem o ID da consulta
		anCubeID, numérico, contem o ID do cubo relacionado a consulta
Ret: Array com o resultado da importação
--------------------------------------------------------------------------------------
*/
method importCons(anType, aoXML, anConsID, anCubeID) class TDWImportMeta
	local oConsulta, oDim := InitTable(TAB_DIMENSAO)
	local oDimFields := InitTable(TAB_DIM_FIELDS)
	local oFactFields := InitTable(TAB_FACTFIELDS)
	local lLevel := .f., aAuxRank, aAux := {}, aIndice := {}
	local nReg, nInd
	local cId
	Local aReturn := {}, oImportAgregados, aAgregY, aAgregX, aMeasures
	
	oConsulta := TConsulta():New(anConsID, anType, .f.)
	oConsulta:AddCube(anCubeID)
	
	//oConsulta:RecLimit(dwVal(delAspas(aoXML:_RecLimit:Text)))
	oConsulta:FatorEscala(iif (xmlNodeExist(aoXML, "_FatorEscala"), dwVal(delAspas(aoXML:_FatorEscala:Text)), 0))
	oConsulta:IndSobrePosto("T" $ iif (xmlNodeExist(aoXML, "_IndSobrePosto"), aoXML:_IndSobrePosto:Text, "F"))
	oConsulta:EmptyCell("T" $ iif (xmlNodeExist(aoXML, "_EmptyCell"), aoXML:_EmptyCell:Text, "F"))
	oConsulta:AlertOn("T" $ iif (xmlNodeExist(aoXML, "_AlertOn"), aoXML:_AlertOn:Text, "F"))
	oConsulta:HintOn("T" $ iif (xmlNodeExist(aoXML, "_HintOn"), aoXML:_HintOn:Text, "F"))
	oConsulta:Filtered("T" $ iif (xmlNodeExist(aoXML, "_Filtered"), aoXML:_Filtered:Text, "F"))
	oConsulta:Total("T" $ iif (xmlNodeExist(aoXML, "_Total"), aoXML:_Total:Text, "F"))

	if xmlNodeExist(aoXML, "_RankOn")
		oConsulta:RankOn("T" $ aoXML:_RankOn:Text)
	endif

	if xmlNodeExist(aoXML, "_RankOu")
		oConsulta:RankOutros("T" $ aoXML:_RankOu:Text)
	endif

	if xmlNodeExist(aoXML, "_RankSubTotal")
		oConsulta:RankSubTotal("T" $ aoXML:_RankSubTotal:Text)
	endif

	if xmlNodeExist(aoXML, "_RankTotal")
		oConsulta:RankTotal("T" $ aoXML:_RankTotal:Text)
	endif
	
	if xmlNodeExist(aoXML, "_DimY") .and. xmlNodeExist(aoXML:_DimY,"_Attributes")
		lLevel 	:= .t.
		aAgregY := ::importLevel("Y", aoXML:_DimY, oDim, oDimFields, oConsulta)
	else
		aAgregY := {}
	endif
	if xmlNodeExist(aoXML, "_DimX") .and. xmlNodeExist(aoXML:_DimX,"_Attributes")
		lLevel := .t.
		aAgregX := ::importLevel("X", aoXML:_DimX, oDim, oDimFields, oConsulta)
	else
		aAgregX := {}
	endif
	
	if xmlNodeExist(aoXML, "_Measures")
		aMeasures := ::importInd(aoXML:_Measures, oConsulta)
	else
		aMeasures := {}
	endif
	
	if xmlNodeExist(aoXML, "_RankStyle")
    	oConsulta:rankStyle(delAspas(aoXML:_RankStyle:Text))
	endif
	
	if xmlNodeExist(aoXML, "_Rank")
		aAux := dwToken(delAspas(aoXML:_Rank:Text), ";",.F.)
		if !(isnull(aAux[1]))
			//verificar a existencia do indice
			aIndice := {"ID_CUBES","NOME"}
	    	nReg := oFactFields:SearchIndex(aIndice, .T.)
			if nReg > 0 //troca nome do campo por id
				if oFactFields:Seek(nReg, {anCubeId,aAux[1]} )
					cId := dwStr(oFactFields:value("ID"))
					aAux[1] := cId
				endif
			endif
		
			//Trata caso só exista 2 parâmetros
			if len(aAux) == 2
				aSize(aAux,3)
				if valtype(aAux[2]) == "C"
					aAux[2] := val(aAux[2])
				endif
				if aAux[2] < 0
					aAux[2] := aAux[2] * -1
					aAux[3] := RNK_MENORES
				else
					aAux[3] := RNK_MAIORES
				endif
			endif
		endif
		
    	if aAux[3] == "x" // RNK_ZERA
			oConsulta:rankStyle(RNK_STY_CLEAR)
    	elseif aAux[3] == "A" // RNK_CURVAABC
			oConsulta:rankStyle(RNK_STY_CURVA_ABC)
    	else
		  	oConsulta:rankStyle(RNK_STY_PADRAO)
		  	oConsulta:RankDef(1, aAux[1], aAux[2], aAux[3]) //#### Alan - VALIDAR 
		endif    
	endif
	
	if xmlNodeExist(aoXML, "_RankDef")
		aAux := dwToken(delAspas(aoXML:_RankDef:Text), "|", .F.)
		
		If valType(aAux) == "A"
			// verificar a existencia do indice
  			aIndice := {"ID_CUBES","NOME"}
      		nReg := oFactFields:SearchIndex(aIndice, .T.)
			
			for nInd := 1 to len(aAux)
				aAuxRank := dwToken(aAux[nInd], ";", .F.)
				if !isnull(aAuxRank[1])
	  				if nReg > 0 //troca nome do campo por id
		  				if oFactFields:Seek(nReg, {anCubeId, aAuxRank[1]} )
			 				aAuxRank[1] := oFactFields:value("ID")
			   			endif
				  	endif
			  	endif
			  	oConsulta:rankDef(nInd, DwVal(aAuxRank[1]), DwVal(aAuxRank[2]), aAuxRank[3])
			next
		EndIf
	endif

  	if xmlNodeExist(aoXML, "_CurvaABC")
		oConsulta:CurvaABC(&(delAspas(strTran(aoXML:_CurvaABC:Text, "&apos;", "'"))))
	endif
	
	if anType == TYPE_GRAPH
		if xmlNodeExist(aoXML, "_GraphClass")
			oConsulta:GraphClass(delAspas(aoXML:_GraphClass:Text))
		endif
		if xmlNodeExist(aoXML, "_GraphProps")
			oConsulta:GraphProps(delAspas(aoXML:_GraphProps:Text))
		endif
		if xmlNodeExist(aoXML, "_GraphYProps")
			oConsulta:GraphYProps(delAspas(aoXML:_GraphYProps:Text))
		endif
		if xmlNodeExist(aoXML, "_GraphY2Props")
			oConsulta:GraphY2Props(delAspas(aoXML:_GraphY2Props:Text))
		endif
	endif
	
	// salva a consulta
	oConsulta:doSave(oConsulta:Name(),,.f.)
	
	// cria o objeto contendo o resultado da importação
	oImportAgregados := TDWImportAgregados():New(anConsID)
	oImportAgregados:AgregY(aAgregY)
	oImportAgregados:AgregX(aAgregX)
	oImportAgregados:Measures(aMeasures)
	oImportAgregados:Sucess(.T.)
	
	// adiciona o objeto da importação a array de retorno
	aAdd(aReturn, oImportAgregados)
	
return aReturn

/*
--------------------------------------------------------------------------------------
Método auxiliar responsável por importar os valores das coordenadas X e Y de uma tabela ou gráfico
Args: 	acEixo, string, eixo da coordenada. Valores possíveis: X ou Y
		aoXML, objeto, contendo o nó com os valores das coordenadas (X ou Y)
		oDim, objeto, contem um objeto do tipo dimensão
		oDimFields, objeto, contem os campos de um objteo dimensão
		aoConsulta, objeto, contem o objeto Consulta
Ret: Array com o resultado da importação
--------------------------------------------------------------------------------------
*/
method importLevel(acEixo, aoXML, aoDim, aoDimFields, aoConsulta) class TDWImportMeta
	local aLevel := iif(valType(aoXML:_Attributes) == "A", aoXML:_Attributes, { aoXML:_Attributes })
	local nInd, xLevel
	local aReturn := {}
	local oImportAgdo, lOK, lDimExist
	
	for nInd := 1 to len(aLevel)
		
		xLevel := aLevel[nInd]
		xLevel:_Dimension:Text := delAspas(xLevel:_Dimension:Text)
		if aoDim:Seek(2, { xLevel:_Dimension:Text }) .or. aoDim:Seek(2, { dwCapitilize(xLevel:_Dimension:Text) })
			lDimExist := .T.
			if aoDimFields:Seek(2, { aoDim:value("id"), delAspas(xLevel:_Field:Text)})
				aoConsulta:AddDimFields(acEixo, delAspas(xLevel:_Options:Text)+DWStr(aoDimFields:value("id")))
				lOK := .T.
			else
				lOK := .F.
			endif
		else
			lDimExist 	:= .F.
			lOK 		:= .F.
		endif
		
		// cria o objeto contendo o resultado da importação
		oImportAgdo := TDWImportAgdo():New(aoConsulta:ID())
		oImportAgdo:DimExist(lDimExist)
		oImportAgdo:DimID(aoDim:value("id"))
		oImportAgdo:DimName(delAspas(xLevel:_Dimension:Text))
		oImportAgdo:FieldName(delAspas(xLevel:_Field:Text))
		oImportAgdo:FieldValue(delAspas(xLevel:_Options:Text))
		oImportAgdo:Sucess(lOK)
		
		// adiciona o objeto da importação a array de retorno
		aAdd(aReturn, oImportAgdo)
		
	next
	
return aReturn

/*
--------------------------------------------------------------------------------------
Método auxiliar responsável por importar os indicadores de um consulta
Args: 	aoXML, objeto, contendo o nó com os indicadores
		aoConsulta, objeto, contem o objeto Consulta
Ret: Array com o resultado da importação
--------------------------------------------------------------------------------------
*/
method importInd(aoXML, aoConsulta) class TDWImportMeta
	local aLevel := {}
	local nInd, nOrdem, xLevel, nOper, aOptions, aInd, aAppInd :={}, nIndID
	local aReturn := {}, aAux
	local lIndExist, oImportMeasure
	
	// resgatar indicadores
	aInd := aoConsulta:Cube():GetIndicadores()
	aEval(::faVirtInd, { |x| aAdd( aAppInd, { x[2], X[1] } ) } )
	aEval(aInd, { |x| aAdd( aAppInd, {iif(x[7] == "N","","~")+alltrim(upper(x[2])), x[1]} )})
	
	if xmlNodeExist(aoXML, "_Attributes")
		if valType(aoXML:_Attributes) == "A"
			aLevel := aoXML:_Attributes
		else
			aLevel := { aoXML:_Attributes }
		endif
	endif
	
	for nInd := 1 to len(aLevel)
		nOrdem := nInd
		xLevel := aLevel[nInd]
		cAux := upper(delAspas(xLevel:_Field:Text))
		nIndID := ascan(aAppInd, { |x| x[1] == cAux})
		if nIndID > 0
			lIndExist := .T.
			nIndID := aAppInd[nIndID, 2]
			aOptions := dwToken(delAspas(xLevel:_Options:Text), ";")
			nOper := dwVal(aOptions[1])
			
			// indicador adicionado automaticamente pela presença em um campo virtual
			if len(aOptions) >= 3 .and. aOptions[2] < 0
				nOrdem *= -1
			endif
			//												se for gráfico, passa a cor do indicador
			aoConsulta:AddIndicador(nOper, nIndID, nOrdem, iif(len(aOptions) >= 3, DwStr(aOptions[3]), ""))
		else
			lIndExist := .F.
		endif
		
		// cria o objeto contendo o resultado da importação
		oImportMeasure := TDWImportMeasure():New(aoConsulta:ID())
		oImportMeasure:IndExist(lIndExist)
		oImportMeasure:MeasureField(delAspas(xLevel:_Field:Text))
		oImportMeasure:MeasureValue(xLevel:_Options:Text)
		oImportMeasure:Sucess(.T.)
		
		// adiciona o objeto da importação a array de retorno
		aAdd(aReturn, oImportMeasure)
	next
	
return aReturn

/*
--------------------------------------------------------------------------------------
Método auxiliar responsável por importar os filtros de um consulta
Args: 	aoXML, objeto, contendo o nó com os filtros
		anConsID, númerico, ID da consulta
		anCubeID, númerico, ID do cubo relacionado à consulta
Ret: Array com o resultado da importação
--------------------------------------------------------------------------------------
*/
method importFilters(aoXML, anConsID, anCubeID) class TDWImportMeta
	local aFilters := iif(valType(aoXML:_Filter) == "A", aoXML:_Filter, { aoXML:_Filter })
	local nInd, nInd2, nConsType, i, xFilter, aValues
	local oWhere := InitTable(TAB_WHERE)
	local aExpressions, xExpression
	local oDim := InitTable(TAB_DIMENSAO)
	local oDimFields := InitTable(TAB_DIM_FIELDS)
	local oWhereExp := InitTable(TAB_WHERE_COND)
	local nDimID := nWhereID := nFieldID := 0
	local cTipo := ""
	local oFactFields := InitTable(TAB_FACTFIELDS)
	local oWhereCons := InitTable(TAB_CONS_WHE)
	local oConsType := InitTable(TAB_CONSTYPE)
	local aReturn := {}
	local oImportFilter, oImportExpression, aFltrExpr := {}, lOK, lOKExpr, lIsSQL, cDimName, cFldName, lDimExist
	
	for nInd := 1 to len(aFilters)
		xFilter := aFilters[nInd]
		if xmlNodeExist(xFilter, "_Tipo")
			cTipo := delAspas(xFilter:_Tipo:Text)
		elseif "T" $ xFilter:_Secure:Text
			cTipo := FILTER_SECURE
		else
			cTipo := FILTER_NORMAL
		endif
		
		If !oWhere:Seek(2, { anConsID, cTipo, upper(delAspas(xFilter:_Nome:Text)) })
			aValues := {{ "nome", upper(delAspas(xFilter:_Nome:Text)) },;
						{ "id_cons", anConsID },;
						{ "descricao", delAspas(xFilter:_Descricao:Text) },;
						{ "tipo", cTipo } }
			
			if oWhere:Append(aValues)
				lOK := .T.
				nWhereID := oWhere:value("id")
						
				if xmlNodeExist(xFilter, "_Expression")
					aExpressions := iif(valType(xFilter:_Expression) == "A", xFilter:_Expression, { xFilter:_Expression })
					for nInd2 := 1 to len(aExpressions)
						xExpression := aExpressions[nInd2]
						nDimID 		:= 0
						lDimExist	:= .F.
						nFieldID 	:= 0
						cDimName 	:= ""
						cFldName	:= ""
		                if xmlNodeExist(xExpression, "_Dimension")
		                	lIsSQL 		:= .F.
		                	lDimExist 	:= .T.
		                	cDimName	:= delAspas(xExpression:_Dimension:Text)
							if !empty(cDimName)
								if oDim:Seek(2, { cDimName })
									nDimID := oDim:value("id")
									cFldName := delAspas(xExpression:_Field:Text)
									if oDimFields:Seek(2, { nDimID, cFldName })
										nFieldID := oDimFields:value("id")
									endif
								endif
							else
								cFldName 	:= delAspas(xExpression:_Field:Text)
								if oFactFields:Seek(2, { anCubeID, cFldName })
									nFieldID := oFactFields:value("id")
								endif
							endif
							if nFieldID != 0
								aValues := {{ "seq", dwVal(delAspas(xExpression:_Sequence:Text)) },;
											{ "id_where", nWhereID }, ;
											{ "id_dim", nDimID },;
											{ "id_field", nFieldID},;
											{ "qbe", delAspas(xExpression:_Expression:Text) }, ;
											{ "last_value", iif(xmlNodeExist(xExpression:_Expression, "_LastValue"), xExpression:_Expression:_LastValue:Text, "") } }
											
								oWhereExp:append(aValues)
							endif
						else
							lIsSQL := .T.
							oWhere:update( {{ "id_expr", ::saveText(delAspas(xExpression:_Expression:Text), .t.) } })
						endif
						
						// cria o objeto contendo o resultado da importação desta expressão
						oImportExpression := TDWImportExpression():New()
						oImportExpression:IsSQL(lIsSQL)
						oImportExpression:DimExist(lDimExist)
						oImportExpression:DimID(nDimID)
						oImportExpression:DimName(cDimName)
						oImportExpression:DimFldExist(iif (nFieldID == 0, .F., .T.))
						oImportExpression:DimFldID(nFieldID)
						oImportExpression:DimFldName(cFldName)
						oImportExpression:Sucess(lOKExpr)
						
						// adiciona o objeto da importação da expressão ao array de expressões
						aAdd(aFltrExpr, oImportExpression)
						
					next
				endif
			else
				lOK := .F.
			endif
		// realiza as devidas validações para filtros de cubo
		ElseIf xmlNodeExist(xFilter, "_virtual") .AND. "T" $ xFilter:_Virtual:Text
			If oWhere:Seek(2, { anConsID, cTipo, upper(delAspas(xFilter:_Nome:Text)) })
				nWhereId := oWhere:value("id")
				lOk := .T.
			EndIf
		EndIf
		
		// realiza a amarração dos filtros com os filtros aplicados/selecionados
		if lOk .AND. xmlNodeExist(xFilter, "_FilterSelT") .AND. xmlNodeExist(xFilter, "_FilterSelG")		
			aTypeCons := {{TYPE_TABLE,xFilter:_FilterSelT:Text},{TYPE_GRAPH,xFilter:_FilterSelG:Text}}
			for i := 1 to len(aTypeCons)
				if DwConvTo("L",aTypeCons[i,2]) // se o filtro estiver ativo para a TABELA/GRÁFICO
				   if oConsType:seek(2, { anConsId, aTypeCons[i,1]})
		   				nConsType := oConsType:value("id")
  						oWhereCons:Append({ { "id_cons", nConsType }, { "id_where", nWhereId } })
				   endif
				endif
			next
		endif
		
		// cria o objeto contendo o resultado da importação
		oImportFilter := TDWImportFilter():New(anConsID)
		oImportFilter:Name(upper(delAspas(xFilter:_Nome:Text)))
		oImportFilter:Type(cTipo)
		oImportFilter:Expressions(aFltrExpr)
		oImportFilter:Sucess(.T.)
		
		// adiciona o objeto da importação a array de retorno
		aAdd(aReturn, oImportFilter)
		
	next
	
return aReturn

/*
--------------------------------------------------------------------------------------
Método auxiliar responsável por importar os alertas de um consulta
Args: 	aoXML, objeto, contendo o nó com os alertas
		anConsID, númerico, ID da consulta
Ret: Array com o resultado da importação
--------------------------------------------------------------------------------------
*/
method importAlerts(aoXML, anConsID) class TDWImportMeta
 	local aAlerts := iif(valType(aoXML:_Alert) == "A", aoXML:_Alert, { aoXML:_Alert })
	local oAlert := InitTable(TAB_ALERT)
	local oQryAlert := InitTable(TAB_CONS_ALM)
	local xAlert, nInd, aValues := {}
	local cAlertSel
	local bFrmtColor := { |cColor| iif ( (left(cColor, 1) == "#") .Or. (cColor == ""), "", "#") + cColor }
	
	for nInd := 1 to len(aAlerts)
		xAlert := aAlerts[nInd]
    	aValues := {}
		aAdd(aValues, { "ID_CONS", anConsID } )
		aAdd(aValues, { "corFB", eval(bFrmtColor, iif (xmlNodeExist(xAlert, "_CorFB"), delAspas(xAlert:_CorFB:Text), nil)) } )
		aAdd(aValues, { "corFF", eval(bFrmtColor, iif (xmlNodeExist(xAlert, "_CorFF"), delAspas(xAlert:_CorFF:Text), nil)) } )
		aAdd(aValues, { "corTB", eval(bFrmtColor, iif (xmlNodeExist(xAlert, "_CorTB"), delAspas(xAlert:_CorTB:Text), nil)) } )
		aAdd(aValues, { "corTF", eval(bFrmtColor, iif (xmlNodeExist(xAlert, "_CorTF"), delAspas(xAlert:_CorTF:Text), nil)) } )
		
		
		if xmlNodeExist(xAlert, "_Expression")
      		if valType(xAlert:_Expression) == "O"
				aAdd(aValues, { "id_expr", ::saveText(xAlert:_Expression:Text, .t.) } )
			else
				aAdd(aValues, { "id_expr", ::saveText(xAlert:_Expression[1]:Text, .t.) } )
			endif
		endif
		aAdd(aValues, { "fonteF", delAspas(xAlert:_FonteF:Text) } )
		aAdd(aValues, { "fonteT", delAspas(xAlert:_FonteT:Text) } )
		aAdd(aValues, { "msgF", delAspas(xAlert:_MsgF:Text) } )
		aAdd(aValues, { "msgT", delAspas(xAlert:_MsgT:Text) } )
		aAdd(aValues, { "nome", delAspas(xAlert:_Nome:Text) } )
		aAdd(aValues, { "tipo", delAspas(xAlert:_Tipo:Text) } )
		oAlert:append(aValues)
		
		// verifica se o alerta está selecionado
		if xmlNodeExist(xAlert, "_AlertSel")
			cAlertSel := xAlert:_AlertSel:Text
			if valType(cAlertSel) == "C" .and. "T" $ cAlertSel
				oQryAlert:Append( { {"ID_CONS",anConsID}, {"ID_ALERT", oAlert:value("ID")} } )
			endif			
		endif
	next
	
return

method importDoc( aDoc ) class TDWImportMeta
	local aValues := {}, nInd
	local oDoc := InitTable(TAB_EXPR)                                    
	
	for nInd := 1 to len(aDoc)
		xAlert := aAlerts[nInd]
		aValues := { { "SEQ", nInd }, ;
					 { "IsSQL", .F. }, ;
					 { "Linha", aDoc[nInd] } }
		oDoc:append(aValues)
	next
return     

/*
--------------------------------------------------------------------------------------
Renomeia uma tabela (usada na migração de versão anteriores a R4)
--------------------------------------------------------------------------------------
*/
static function renameTable(acOldName, acNewName)
	local oQuery

	if !(acOldName == acNewName)

		oQuery := TQuery():New()
  	oQuery:execute(EX_REN_TABLE, acOldName, acNewName)
//      oSource := TTable():New(acOldName)
//      oSource:open()
//      oSource:CopyTo(acNewName)
//      oSource:close()
//      oSource:dropTable()
//conout("---------------")
	endif
	
return

/*
--------------------------------------------------------------------------------------
Prepara o nome antigo da tabela
--------------------------------------------------------------------------------------
*/                             
static function prepOldName(acOldPrefixo, acOldID, acBase)

return left(acBase, 2) + acOldPrefixo + dwInt2Hex(dwVal(acOldID), 4)