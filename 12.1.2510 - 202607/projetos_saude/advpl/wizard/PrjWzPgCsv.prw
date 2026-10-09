#include 'protheus.ch'
#include 'fwschedule.ch'
#include 'FWMVCDEF.CH'

#DEFINE CMPCAMPO	1
#DEFINE CMPTIPO		2
#DEFINE CMPSIZE		3
#DEFINE CMPDECIMAL	4
#DEFINE CMPTITULO	5
#DEFINE CMPEXIBE	6
#DEFINE CMPOBRIG	7
#DEFINE CMPWHEN 	8

Static __cTabTmp := ""
Static __aCampos := {}

Class PrjWzPgCsv From PrjWzPgArq
	Data lIsjob as logical

	Method new(aDados) Constructor
	Method getTabFlds()
	Method getTabTemp()
	Method addMoreFields()
	Method endProcess()
	Method noConnect()
	Method ImportaCsv()
	Method extrairArq()

EndClass

Method new(aDados) Class PrjWzPgCsv
	_Super:new(aDados)
	self:cTitle 	:= "Carga BD"
	self:cDescri 	:= "Importação de arquivo .CSV"
Return self

Method getTabFlds() Class PrjWzPgCsv
	Local aPrimeiro := {}
	If Empty(self:aCampos)
		//{CMPCAMPO,CMPTIPO,CMPSIZE,CMPDECIMAL,CMPTITULO,CMPEXIBE,CMPOBRIG,CMPWHEN}
		_Super:getTabFlds()
		aAdd(self:aCampos,{"ROTINA"		,"C",015	,0,"Rotina"		,.T.,.F.,.F.})
		aPrimeiro := ATail(self:aCampos)
		aIns(self:aCampos,1)
		aFill(self:aCampos,aPrimeiro,1,1)
		aAdd(self:aCampos,{"PARAMS"		,"M",900	,0,"Parametros"	,.F.,.F.,.F.})
		aAdd(self:aCampos,{"JOB"		,"L",010	,0,"Job"		,.F.,.F.,.F.})
		__aCampos := self:aCampos
	EndIf
Return self:aCampos

Method getTabTemp() Class PrjWzPgCsv
	Local oTabTemp := _Super:getTabTemp()
	__cTabTmp := _Super:getTabTemp():getAlias()
Return oTabTemp

Method addMoreFields() Class PrjWzPgCsv
	Local aRotina	:= {}
	Local cParams	:= ""
	(cTabTemp)->ROTINA		:= "NAO_EXISTE"
	(cTabTemp)->PARAMS		:= cParams
	self:lIsjob				:= .F.
	If ValType(self:aDados[self:nID]["rotina"]) == "J"
		aRotina	:= self:aDados[self:nID]["rotina"]
		If !Empty(aRotina["nome"])
			(cTabTemp)->ROTINA		:= aRotina["nome"]
		EndIf
		If !Empty(aRotina["configuracoes"])
			cParams	:= ArrTokStr(aRotina["configuracoes"])
			(cTabTemp)->PARAMS		:= cParams
		EndIf
	EndIf
	If	!Empty(self:aDados[self:nID]["isjob"])
		self:lIsjob		:= self:aDados[self:nID]["isjob"]
	EndIf
	(cTabTemp)->JOB 	:= self:lIsjob
	self:nID += 1
Return

Method endProcess() Class PrjWzPgCsv
	Processa({|| self:downloadFile()}, "Baixando/Salvando Arquivos" )
	Processa({|| self:ImportaCsv()}, "Importando Tabelas" )
Return

Method extrairArq() class PrjWzPgCsv
	oWzFiles:extrairArq(.T.)
Return

Method noConnect() class PrjWzPgCsv
	Local cExt := "*.*"
	Local aFiles := {}
	SplitPath(self:cFileName, /* @cDrive*/, /* @cDiretorio*/,  /*@cNome*/, @cExt)
	If self:lUnzip
		aFiles := oWzFiles:getFileNames(cExt)
		self:extrairArq()
	else
		aFiles := oWzFiles:getFileNames(cExt)
	EndIf
	If Empty(aFiles) .And. !Empty(oWzFiles:getErro())
		MsgAlert(oWzFiles:getErro())
	EndIf
Return

Method ImportaCsv() Class PrjWzPgCsv
	Local cTabTemp	:= self:getTabTemp():getAlias()
	Local cRotina	:= ""
	Local cParams	:= ""
	Local aParams	:= {}
	Local cNome		:= ""
	Local cErro		:= ""
	ProcRegua(self:nTotReg)
	(cTabTemp)->(DbGoTop())
	While (cTabTemp)->(!Eof())
		If (cTabTemp)->ENVDOK == self:oMark:cMark
			self:cFileName	:= Alltrim((cTabTemp)->FILENAME)
			self:cDestino 	:= AllTrim((cTabTemp)->DESTINO)
			cRotina			:= AllTrim((cTabTemp)->ROTINA)
			cParams 		:= AllTrim((cTabTemp)->PARAMS)
			self:lIsjob		:= (cTabTemp)->JOB
			self:lUnzip		:= (cTabTemp)->UNZIP
			If self:lUnzip
				SplitPath(self:cFileName, /* @cDrive*/, /* @cDiretorio*/,  @cNome, /*@cExt*/)
				self:cDestino += cNome + "\"
			EndIf
			aParams := StrTokArr(cParams,"|")
			cExec := cRotina + "(" + '"' + PrjWzLinux(self:cDestino) + '"'
			If !Empty(aParams)
				cExec += "," + 'aParams'
			EndIf
			//cExec += ", cEmpAnt, cFilAnt"
			cExec += ")"
			IncProc("Executando rotina " + cRotina)
			If !PrjExtFunc(@cErro,{cRotina})
				MsgAlert(cErro,"Wizard Saude")
				cErro := ""
			ElseIf self:lIsjob
				MsgInfo("A rotina " + cRotina + " será realizada em segundo plano.","TOTVS")
				StartJob( cRotina, GetEnvServer(), .F., PrjWzLinux(self:cDestino), aParams, cEmpAnt, xFilial() )
			Else
				&(cExec)
			EndIf
		EndIf
		(cTabTemp)->(dbSkip())
	Enddo
Return