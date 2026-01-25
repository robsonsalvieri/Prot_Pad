#include "PROTHEUS.CH"
#include "ERROR.CH"
#include "fileIO.ch"

#define CRLF chr( 13 ) + chr( 10 )

//-------------------------------------------------------------------
/*/{Protheus.doc} tissLoteGuias
WebService PTU A100

@author  Totvs
@version P12
@since   30/08/2019
/*/
//-------------------------------------------------------------------
function PTWebAEvent()

local cSoap     := ""
local cErro     := ""
local cXml      := HttpOtherContent()
local aRetObj   := {}
local lRetObj   := .F.
local cEnv      := GetEnvServer()
local cEmp      := AllTrim(GetPvProfString(cEnv,"JEMP","",GetADV97()))
local cFil      := AllTrim(GetPvProfString(cEnv,"JFIL","",GetADV97()))
Local cScheA100 := ''
Local cLayoutPTU:= ''
Local nPosIni	:= at("ptuA100_Pos_UB",cXml)
Local nPosFim	:= rat("ptuA100_Pos_UB",cXml)
Local cNameSpace:= ''
Local cNewXml	:= Substr(cXml,nPosIni	,nPosFim)
Local cNameAnt	:= Substr(cXml,(nPosIni-4),4)
Local x			:= 0
Local lNameSpace:= If(Substr(cXml,(nPosIni-4), 4)<>"ptu:",.F.,.T.)
Local cAntName	:= ''
Local cComPlemento:='ptuA100_Pos_UB  xsi:schemaLocation="http://ptu.unimed.coop.br/schemas/V1_0 ptu_A100_Pos_UB.xsd" xmlns:ptu="http://ptu.unimed.coop.br/schemas/V1_0" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">'


nPosName:= at(">",cNewXml)

cNewXml:=  Substr(cNewXml,nPosName+1, nPosFim)
cNewXml:=  cComPlemento+cNewXml


If Substr(cNewXml,(nPosIni-4), 4)<>"ptu:"

	
	cNameSpace	:= '<ptu:'
	cAntName	:='<'
	lNameSpace:=.T.
	cXml:= ""+StrTran( cNewXml, cAntName, cNameSpace )	

	cNameSpace	:= '</ptu:'
	cAntName	:='<ptu:/'
	lNameSpace:=.T.
	cXml:= "<ptu:"+StrTran( cXml, cAntName, cNameSpace )

Else
	cNameSpace:= If(Substr(cXml,(nPosIni-4), 4)<>"ptu:","ptu:","ptu:")
Endif	


RpcSetEnv( cEmp,cFil,,,cEnv,,) 


if !empty(cEmp) 
     
   
	HttpCtType( "text/xml; charset="+'UTF-8' )

	cScheA100 := GetNewPar("MV_PLWBSCH","ptu_A100_Pos_UB.xsd")
	cLayoutPTU:= GetNewPar("MV_PLTPARQ","A100")
	
	
	If !lNameSpace // outro namespace ptu:
		For x:= 1 to Len(cNameAnt)
			If Substr(cNameAnt,x,1) <>"<"
				cAntName+=Substr(cNameAnt,x,1)
			Endif	
		Next x
		cXml:= "<ptu:"+StrTran( cNewXml, cAntName, cNameSpace )	
	Endif
	 

     
	aRetObj := VldWSArqPtu(cXml,cScheA100,cLayoutPTU)
	 
	lRetObj := aRetObj[1]
    cErro   := aRetObj[2]
	cXml    := aRetObj[3] 

	// Se tudo ok, processa o arquivo	
	if lRetObj
	
		cSoap := ProcArqPtu(cXml) + chr(10)
	else
		cSoap := ProcReturnNill(cErro)
	endif  
else
    cSoap := "A ENVIRONMENT [" + cEnv + "] nÃ£o tem declarada as variaveis cEmp e cFil." 
endif

return cSoap 

//-------------------------------------------------------------------
/*/{Protheus.doc} ProcLoteGui
WebService PTU A100

@author  Totvs
@version P12
@since   30/08/2019
/*/
//-------------------------------------------------------------------
static function ProcArqPtu(cSoapXml)

Local cError	:=''
Local cWarning	:=''
Local aRetSoap	:={}

oScript := XmlParser( cSoapXml, "_", @cError, @cWarning )
 
aRetSoap := PlGrvXML(cSoapXml,oScript )

If Len(aRetSoap) > 0
	If aRetSoap[1]

		cSoap := "<?xml version="+'"1.0"'+" encoding="+'"UTF-8"'+"?>"+ Chr(13)+Chr(10)
		cSoap += "<ptuA105 xsi:schemaLocation="+'"http://ptu.unimed.coop.br/schemas/V1_0 ptu_A100_Pos_UB.xsd" xmlns:ptu="http://ptu.unimed.coop.br/schemas/V1_0" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">'+ Chr(13)+Chr(10)
		cSoap += "<cabecalho>"+ Chr(13)+Chr(10)
		cSoap += "<nrVerTra_PTU>1</nrVerTra_PTU>"+ Chr(13)+Chr(10)
		cSoap += "<unimed>"+ Chr(13)+Chr(10)
		cSoap += "<cd_Uni_Destino>"+aRetSoap[4,1]+"</cd_Uni_Destino>"+ Chr(13)+Chr(10)
		cSoap += "<cd_Uni_Origem>"+aRetSoap[4,2]+"</cd_Uni_Origem>"+ Chr(13)+Chr(10)
		cSoap += "</unimed>"+ Chr(13)+Chr(10)
		cSoap += "<dt_geracao>"+Dtos(Date())+"</dt_geracao>"+ Chr(13)+Chr(10)
		cSoap += "<nr_transacao>"+aRetSoap[4,3]+"</nr_transacao>"+ Chr(13)+Chr(10)
		cSoap += "</cabecalho>"+ Chr(13)+Chr(10)
		cHash := MD5(cSoap,2)
		cSoap += "<hash>"+cHash+"</hash>"+ Chr(13)+Chr(10)
		cSoap += "</ptuA105>"+ Chr(13)+Chr(10)
	Else	

		cSoap := "<?xml version="+'"1.0"'+" encoding="+'"UTF-8"'+"?>"+ Chr(13)+Chr(10)
		cSoap += "<ptuA105 xsi:schemaLocation="+'"http://ptu.unimed.coop.br/schemas/V1_0 ptu_A100_Pos_UB.xsd" xmlns:ptu="http://ptu.unimed.coop.br/schemas/V1_0" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">'+ Chr(13)+Chr(10)
		cSoap += "<cabecalho>"+ Chr(13)+Chr(10)
		cSoap += "<nr_transacao>"+aRetSoap[2]+"</nr_transacao>"+ Chr(13)+Chr(10)
		cSoap += "</cabecalho>"+ Chr(13)+Chr(10)
		cHash := MD5(cSoap,2)
		cSoap += "<hash>"+cHash+"</hash>"+ Chr(13)+Chr(10)
		cSoap += "</ptuA105>"+ Chr(13)+Chr(10)


	EndIf
EndIf

return cSoap 

//-------------------------------------------------------------------
/*/{Protheus.doc} VldWSArqPtu
Ajusta um soap de recebimento para montagem do objeto de trabalho

@author  Lucas Nonato
@version P12
@since   05/10/2018
/*/
//------------------------------------------------------------------- 
static function VldWSArqPtu(cSoap,cSchema,cLayout)
local cSoapAux   := ""   
local cMsg       := ""
local cErro      := ""
local cAviso     := ""
local cNameSpace := ""
local lRet       := .T. 
local cPathProc  := GetNewPar("MV_PLWBPRC","\plsptu\A100\processados\") // CAMINHO DOS ARQUIVOS JA PROCESSADOS
local cPathEntr  := GetNewPar("MV_PLDRARQ","\plsptu\a100\entradas\")


// Cria diretorios                                   					     ï¿½

If !ExistDir("\plsptu")
	If MakeDir(GetSrvProfString ("ROOTPATH","")+"\plsptu\") == 3  
		cErro := "Não foi possivel criar o diretorio \plsptu"     //
	EndIf      
EndIf

If !ExistDir("\plsptu\"+cLayout)
	If MakeDir(GetSrvProfString ("ROOTPATH","")+"\plsptu\"+cLayout) == 3  
		cErro := "Não foi possivel criar o diretorio \plsptu\"   +cLayout //
	EndIf      
EndIf

If !ExistDir(cPathEntr)
	If MakeDir(GetSrvProfString ("ROOTPATH","")+cPathEntr) == 3  
		cErro := "Não foi possivel criar o diretorio "   +cPathEntr //
	EndIf      
EndIf

If !ExistDir(cPathProc)
	If MakeDir(GetSrvProfString ("ROOTPATH","")+cPathProc) == 3  
		cErro := "Não foi possivel criar o diretorio"   +cPathProc //
	EndIf      
EndIf


If !ExistDir("\plsptu\"+cLayout+"\schemas\")
	If MakeDir(GetSrvProfString ("ROOTPATH","")+"\plsptu\"+cLayout+"\schemas\") == 3
		cErro := "Não foi possivel criar o diretorio \plsptu\"+cLayout+"\schemas\" //"NÃ£o foi possivel criar o diretorio \plsptu\"
	EndIf 
EndIf  


// Se houve erro fatal finaliza operaï¿½ï¿½o 
if !empty(cErro)
	return {.F.,cErro,"",""}
endif


// Monta texto para montagem do arquivo para validacao.
//Atenï¿½ï¿½o: alguns prestadores enviam o XML em formato estranho, que faz cair o encodeutf8, mas que contem arquivo vï¿½lido.

cSoapXml := EncodeUTF8(cSoap)
if empty(cSoapXml) .or. valtype(cSoapXml) == "U"
	cSoapXml := cSoapAux
endif	



If (!XmlSVldSch( cSoapXml, "\plsptu\"+cLayout+"\schemas\"+cSchema, @cErro,@cAviso)) 
	cMsg := Iif( !Empty(cErro),"Erro: " +cErro,"") //"Erro: "
	cMsg += Iif( !Empty(cAviso),"Aviso: "+cAviso,"") //"Aviso: "
 	lRet := .F.
EndIf


return {lRet,cMsg,cSoapXml,cNameSpace}

//-------------------------------------------------------------------
/*/{Protheus.doc} PlgeraXML
Gera arquivo xml no servidor

@author  Totvs
@version P12
@since   30/08/2019
/*/
//------------------------------------------------------------------- 
Static function PlGrvXML(cSoap,oScript)
Local cDir		:= GetNewPar("MV_PLDRARQ","\plsptu\a100\entradas\")
Local nArq  	:= 0
Local cArq		:= ""
Local lret 		:= .T. 	
Local lArqJaImp := .F.



dBselectArea("BX0")
BX0->(DbSetOrder(1))
	

cCodUniDes	:= StrZero(VaL(oScript:_PTU_PTUA100_POS_UB:_PTU_CABECALHO:_PTU_UNIMED:_PTU_CD_UNI_DESTINO:TEXT),4)
cCodUniOri	:= StrZero(VaL(oScript:_PTU_PTUA100_POS_UB:_PTU_CABECALHO:_PTU_UNIMED:_PTU_CD_UNI_ORIGEM:TEXT),4)
cHash		:= oScript:_PTU_PTUA100_POS_UB:_PTU_HASH:TEXT
dDtGerXML	:= Stod(oScript:_PTU_PTUA100_POS_UB:_PTU_CABECALHO:_PTU_DT_GERACAO:TEXT)

cArq := cHash +  ".xml"

If BX0->(DbSeek(xFilial("BX0")+cCodUniDes+cHash))
	lArqJaImp := .T.
EndIf

nArq := fCreate( cDir+cArq )


if nArq > 0 .and. !lArqJaImp 		
	fWrite( nArq,cSoap )
    fClose( nArq )

	RecLock("BX0",.T.)
	BX0->(BX0_FILIAL)	:= xFilial("BX0")
	BX0->(BX0_NRTRAN)	:= GetSx8Num("BX0","BX0_NRTRAN");CONFIRMSX8()
	BX0->(BX0_OPEDES)	:= cCodUniDes
	BX0->(BX0_OPEORI)	:= cCodUniOri
	BX0->(BX0_DTGERA)	:= If(Empty(dDtGerXML),msDate(),dDtGerXML)
	BX0->(BX0_HASH)		:= cHash
	BX0->(BX0_ARQUIV)	:= cDir+cArq
	BX0->(MsUnlock())

else
	lret :=  .F.
	If lArqJaImp .and. 	nArq > 0 
		cDir:= "Arquivo já importado"
	Else	
		cDir:= "Arquivo não foi criado na pasta "+cDir+ ". Verificar o parâmetro MV_PLDRARQ !"
	EndIf
endif

return {lret,cDir,cArq,{cCodUniDes,cCodUniOri,BX0->(BX0_NRTRAN)}}


//-------------------------------------------------------------------
/*/{Protheus.doc} PlgeraXML
Gera arquivo xml de retuno caso tenha erro

@author  Totvs
@version P12
@since   30/08/2019
/*/
//------------------------------------------------------------------- 
Static function ProcReturnNill(cMensagem)

HttpCtType( "text/xml; charset="+'UTF-8' )

cret := '<?xml version="1.0" encoding="UTF-8"?>'
cret += '<soap:Envelope xmlns:soap="http://schemas.xmlsoap.org/soap/envelope/" >'
cret += '<soap:Body>'
cret += '<ptu:ptua105 xsi:schemalocation="http://ptu.unimed.coop.br/schemas/V1_0 ptu:ptu_A100_Pos_UB.xsd" xmlns:ptu="http://ptu.unimed.coop.br/schemas/V1_0" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"><ptu:cabecalho><ptu:nr_transacao>'+substr(cMensagem,1,50)+'</ptu:nr_transacao></ptu:cabecalho></ptu:ptua105>'
cret += '</soap:Body>'
cret += '</soap:Envelope>'



Return cRet 

