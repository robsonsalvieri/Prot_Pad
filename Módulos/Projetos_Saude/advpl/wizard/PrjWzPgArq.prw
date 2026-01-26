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

Class PrjWzPgArq From PrjWzPg
	Data oMark
	Data cFileName
	Data cOrigem
	Data cDestino
	Data nID
	Data lUnzip
	Data cURL
	Data cRequest

	Method new(aDados) Constructor
	Method getTabFlds()
	Method getTabTemp()
	Method fillTabTemp()
	Method addMoreFields()
	Method endProcess()
	Method downloadFile()
	Method extrairArq()
	Method noConnect()

EndClass

Method new(aDados) Class PrjWzPgArq
	_Super:new(aDados)
	self:cTitle 	:= "Arquivos"
	self:cDescri 	:= "Arquivos De Configuração"
	self:cFileName	:= ""
	self:cOrigem	:= ""
	self:cDestino	:= ""
	self:nID		:= 1
	self:cURL		:= "https://cobprostorage.blob.core.windows.net"
	self:cRequest	:= ""
Return self

Method getTabFlds() Class PrjWzPgArq
	
	If Empty(self:aCampos)
		//{CMPCAMPO,CMPTIPO,CMPSIZE,CMPDECIMAL,CMPTITULO,CMPEXIBE,CMPOBRIG,CMPWHEN}
		aAdd(self:aCampos,{"ID"			,"C",004,0,"Id"			,.F.,.F.,.F.})
		aAdd(self:aCampos,{"FILENAME"	,"C",060,0,"Arquivo"	,.T.,.F.,.F.})
		aAdd(self:aCampos,{"ORIGEM"		,"C",100,0,"Origem"		,.F.,.F.,.F.})
		aAdd(self:aCampos,{"DESTINO"	,"C",100,0,"Destino"	,.T.,.F.,.F.})
		aAdd(self:aCampos,{"UNZIP"		,"L",003,0,"Extrair"	,.F.,.F.,.F.})
		aAdd(self:aCampos,{"URL"		,"C",400,0,"URL"		,.F.,.F.,.F.})
		aAdd(self:aCampos,{"REQUEST"	,"C",400,0,"Caminho"	,.F.,.F.,.F.})
		aAdd(self:aCampos,{"ENVDOK"		,"C",002,0,""			,.F.,.F.,.F.})
		__aCampos := self:aCampos
	EndIf
	
Return self:aCampos

Method getTabTemp() Class PrjWzPgArq
	Local oTabTemp := _Super:getTabTemp()
	__cTabTmp := _Super:getTabTemp():getAlias()
Return oTabTemp

Method fillTabTemp() Class PrjWzPgArq
	Local nLenArqui		:= Len(self:aDados)
	Local nArquivo		:= 0
	Private cTabTemp 	:= self:getTabTemp():getAlias()
	self:nTotReg := nLenArqui
	For nArquivo := 1 TO nLenArqui
		RecLock(cTabTemp,.T.)
		(cTabTemp)->ID 			:= AllTrim(StrZero(self:nID,4))
		(cTabTemp)->FILENAME 	:= self:cFileName	:= self:aDados[nArquivo]["arquivo"]
		(cTabTemp)->ORIGEM 		:= self:cOrigem		:= self:aDados[nArquivo]["origem"]
		(cTabTemp)->DESTINO		:= self:cDestino	:= self:aDados[nArquivo]["destino"]
		(cTabTemp)->UNZIP	 	:= self:lUnzip		:= .F.
		(cTabTemp)->URL			:= self:cURL
		(cTabTemp)->REQUEST		:= self:cRequest	:= "/files" + strtran(self:cOrigem,"\","/")  + self:cFileName
		If	!Empty(self:aDados[nArquivo]["repositorio"])
			(cTabTemp)->URL 	:= self:cURL		:= self:aDados[nArquivo]["repositorio"]
			(cTabTemp)->REQUEST	:= self:cRequest	:= self:aDados[nArquivo]["uri"]
		EndIf
		(cTabTemp)->ENVDOK		:= "XX"
		If	!Empty(self:aDados[nArquivo]["unzip"])
			(cTabTemp)->UNZIP 	:= self:lUnzip		:= self:aDados[nArquivo]["unzip"]
		EndIf
		self:addMoreFields()
		(cTabTemp)->(msUnLock())
	Next nArquivo
Return

Method addMoreFields() Class PrjWzPgArq
	self:nID += 1
Return

Method endProcess() Class PrjWzPgArq
	Processa({|| self:downloadFile()}, "Baixando/Salvando Arquivos" )
Return

Method downloadFile() Class PrjWzPgArq
	Local cTabTemp		:= self:getTabTemp():getAlias()                                                                            
	Private oWzFiles	:= nil                                   

	ProcRegua(self:nTotReg)
	(cTabTemp)->(DbGoTop())
	While (cTabTemp)->(!Eof())
		If (cTabTemp)->ENVDOK == self:oMark:cMark
			self:cFileName	:= Alltrim((cTabTemp)->FILENAME)
			self:cOrigem 	:= AllTrim((cTabTemp)->ORIGEM)
			self:cDestino 	:= AllTrim((cTabTemp)->DESTINO)
			self:lUnzip		:= (cTabTemp)->UNZIP
			self:cURL 		:= AllTrim((cTabTemp)->URL)
			self:cRequest   := AllTrim((cTabTemp)->REQUEST)
			IncProc("Baixando Arquivo " + self:cFileName)
			oWzFiles := PrjWzFiles():New(self:cDestino, self:cFileName)
			If oWzFiles:getWDClient(self:cURL, self:cRequest)
				If self:lUnzip
					self:extrairArq()
				EndIf
			Else
				self:noConnect()
			EndIf
		EndIf
		FreeObj(oWzFiles)
		oWzFiles := nil
		(cTabTemp)->(dbSkip())
	Enddo
Return

Method noConnect() class PrjWzPgArq
	If !Empty(oWzFiles:getErro())
		MsgAlert(oWzFiles:getErro())
	EndIf
Return

Method extrairArq() class PrjWzPgArq
	If !oWzFiles:extrairArq() .And. !Empty(oWzFiles:getErro())
		MsgAlert(oWzFiles:getErro())
	EndIf
Return