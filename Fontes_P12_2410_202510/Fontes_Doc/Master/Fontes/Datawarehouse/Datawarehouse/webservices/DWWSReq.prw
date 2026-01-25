// ######################################################################################
// Projeto: DATA WAREHOUSE
// Modulo : 
// Fonte  : htmlLib - funções de geração de HTML de uso geral
// ---------+-------------------+--------------------------------------------------------
// Data     | Autor             | Descricao
// ---------+-------------------+--------------------------------------------------------
// 27.12.06 | 0548-Alan Candido | Versão 3
// --------------------------------------------------------------------------------------

#include "dwincs.ch"

/*
--------------------------------------------------------------------------------------
Processa as requisição do webService
--------------------------------------------------------------------------------------
*/
function DWProcWSRequest(acCommand)
	local aBuffer := {}
	local nDW_ID := -1 
	
    
	IF( RAT('/',acCommand) > 0 )
		aBuffer:= aBIToken( acCommand, '/', .F. )
		nDW_ID:= nBIVAL(aBuffer[2])
		acCommand:= aBuffer[1]
		aBuffer:={}
	ENDIF	     
		
	
	if acCommand == CMD_GETLISTDW   
		getListDW(aBuffer)
	elseif acCommand == CMD_GETXMLCUBOS
		getXmlCbs(aBuffer)
	elseif acCommand == CMD_GETXMLCUBO
		getXmlCb(aBuffer, dwVal(HttpGet->IDCube))
	elseif acCommand == CMD_GETXMLCONSULTAS
		getXmlConsultas(aBuffer,nDW_ID)
	elseif acCommand == CMD_GETCONSTRUCT
		getConStruct(aBuffer, dwVal(HttpPost->idConsulta), HttpPost->listValues == "true")
	endif

return dwConcatWSep("!", aBuffer)

static function getListDW(aaBuffer)
	local nInd, x
	local aDWList := oSigaDW:DWList():Items()

	for nInd := 1 to len(aDWList)
		x := aDWList[nInd]                                         
		if oUserDW:UserIsAdm() .or. (x[DW_DISP] .and. oUserDW:GetDwAcessPerm(x[DW_ID]))
			aAdd(aaBuffer, x[DW_NAME] + "|" + dwStr(x[DW_ID]))
		endif
	next

return

static function getXmlCbs(aaBuffer)
	local oTblCubes		:= initTable(TAB_CUBESLIST)
	local oXMLCubos		:= TBIXMLNode():New("CUBESLIST")
	local oXmlNode		:= nil
	local aTmpReg     := {}
	local nReg        := 0
	
	oTblCubes:open()
	oTblCubes:seek(2, { "" })
	
	while ! oTblCubes:eof() .and. oTblCubes:value("ID_DW") == oSigaDW:DWCurrId()
		//Verificacao de acesso a um cubo.
		if  oUserDW:GetCubAcessPerm(oSigaDW:DWCurrId(), oTblCubes:value("ID")) .and. oTblCubes:value("ID") # 0
			oXmlNode:=	oXMLCubos:oAddChild(TBIXMLNode():New("CUBELIST"))
			aTmpReg	:=	oTblCubes:record(1,{"DT_CREATE","HR_CREATE","DT_PROCESS","HR_PROCESS","IMPORTADO","NOTIFICAR","F_L_A_G_W"})
			for nReg := 1 to len(aTmpReg)
				oXmlNode:oAddChild(TBIXMLNode():New(aTmpReg[nReg,1],aTmpReg[nReg,2]))
			next nReg
		endif
		oTblCubes:_Next()
	end
	aAdd(aaBuffer, oXMLCubos:cXMLString(.t., "ISO-8859-1"))
		
return 


static function getXmlCb(aaBuffer, anCubeID)
	local oCube := oSigaDW:OpenCube(anCubeID, .t.)

	oCube:Close()

return

static function getConStruct(aaBuffer, anID, alListValues)
	local oTblConsulta := initTable(TAB_CONSULTAS)
	local oXMLConsulta := TBIXMLNode():New("CONSULTAS")
	local oXMLFldY     := TBIXMLNode():New("DIMENSIONS_Y")
	local oXMLFldX     := TBIXMLNode():New("DIMENSIONS_X")
	local oXMLIndexs   := TBIXMLNode():New("INDICADORES")
	local aDimX        := {}
	local aDimY        := {}
	local aInds        := {}
	local oXmlNode     := nil
	private oConsulta
	
	if oTblConsulta:seek(1, { anID }) .and. oUserDW:GetQryAcessPerm(oSigaDW:DWCurrId(), oTblConsulta:value("ID"))
		oConsulta  := TConsulta():New(anID,1)

		oXmlNode:=	oXMLConsulta:oAddChild(TBIXMLNode():New("CONSULTA"))
		oXmlNode:oAddChild(TBIXMLNode():New("NAME",oTblConsulta:FCALIAS))
		oXmlNode:oAddChild(TBIXMLNode():New("ALIAS",oTblConsulta:FCDESCRICAO))
		oXmlNode:oAddChild(TBIXMLNode():New("DESCRIPTION",oTblConsulta:FCDESCRICAO))
		oXmlNode:oAddChild(TBIXMLNode():New("ID",anID))
		
		//Adicionado estrutura do eixo Y.
		aDimY	:=	oConsulta:DimFieldsY()
		addFieldsProp(oXMLFldY,aDimY ,"DIMENSION_Y",alListValues)
		oXmlNode:oAddChild(oXMLFldY)
		
		//Adicionado estrutura do eixo X.
		aDimX	:=	oConsulta:DimFieldsX()
		addFieldsProp(oXMLFldX,aDimX ,"DIMENSION_X",alListValues)
		oXmlNode:oAddChild(oXMLFldX)
		
		//Adicionado estrutura os indicadores.
		aInds := oConsulta:Indicadores(.t.)
		addFieldsProp(oXMLIndexs,aInds ,"INDICADOR",alListValues)
		oXmlNode:oAddChild(oXMLIndexs)

	aAdd(aaBuffer, oXMLConsulta:cXMLString(.t., "ISO-8859-1"))
endif
		
return 

/*
*Adiciona a propriedade dos campos.
*/
static function addFieldsProp(oXml,aFieldStru,cType,lAddValues)
	local oConDados	:= oConsulta:getDSForExport({})
	local oXmlField	:=	nil
	local nItem		:=	0
		
	for nItem := 1 to len(aFieldStru)
		oXmlField	:=	oXml:oAddChild(TBIXMLNode():New(cType))
		oXmlField:oAddChild(TBIXMLNode():New("NAME"		,aFieldStru[nItem]:Name()	))
		oXmlField:oAddChild(TBIXMLNode():New("DESC"		,aFieldStru[nItem]:Desc()	))
		oXmlField:oAddChild(TBIXMLNode():New("TYPE"		,aFieldStru[nItem]:Tipo()	))
		oXmlField:oAddChild(TBIXMLNode():New("SIZE"		,aFieldStru[nItem]:Tam()	))
		oXmlField:oAddChild(TBIXMLNode():New("DECIMAL"	,aFieldStru[nItem]:nDec()	))
		oXmlField:oAddChild(TBIXMLNode():New("ID"		,aFieldStru[nItem]:id()		))
		oXmlField:oAddChild(TBIXMLNode():New("TEMPORAL"	,aFieldStru[nItem]:Temporal()))

		//Adicionando os valores para os indicadores;
		if(lAddValues)
			cCmpAlias	:=	aFieldStru[nItem]:Alias() 
			oXmlField	:=	oXmlField:oAddChild(TBIXMLNode():New("VALUES"))
			oConDados:goTop()
			n := 1
			while ! oConDados:eof()

				if(aFieldStru[nItem]:Tipo() == "D" .and.  aFieldStru[nItem]:Temporal() == 0)
					oXmlField:oAddChild(TBIXMLNode():New("VALUE",dtos(cTod(oConDados:value(cCmpAlias)))))
				else
					oXmlField:oAddChild(TBIXMLNode():New("VALUE",oConDados:value(cCmpAlias)))
				endif				
				n++			
				oConDados:_Next()
			end
		endif			
	next nItem

return .t.

static function getXmlConsultas(aaBuffer,pn_DWID)
	local oTblConsulta := initTable(TAB_CONSULTAS)
    local oXMLConsulta	:=	TBIXMLNode():New("CONSULTAS")
	local oXmlNode		:=	nil	   
	local aTmpReg		:=	{}
	local nReg			:=	0
	default pn_DWID:= oSigaDW:DWCurrId()

	oTblConsulta:open()
	oTblConsulta:seek(2, { "" } )
	oTblConsulta:gotop()
		
	while ! oTblConsulta:eof()   
 	   if oTblConsulta:value("ID_DW") == pn_DWID
			if oUserDW:GetQryAcessPerm(pn_DWID, oTblConsulta:value("ID"))
				oXmlNode:=	oXMLConsulta:oAddChild(TBIXMLNode():New("CONSULTA"))
				aTmpReg	:=	oTblConsulta:record(1,{"SOGRUPO","PUBLIC","ID_CONS","ID_CUBE","VALIDA","VALGRA","ID_USER","ID_GRUPO","PUBURL","EXCEL","F_L_A_G_W"})
				for nReg := 1 to len(aTmpReg)
					oXmlNode:oAddChild(TBIXMLNode():New(aTmpReg[nReg,1],aTmpReg[nReg,2]))
				next nReg
			endif               
		endif
		oTblConsulta:_Next()
	end

	aAdd(aaBuffer, oXMLConsulta:cXMLString(.t., "ISO-8859-1"))
return 
