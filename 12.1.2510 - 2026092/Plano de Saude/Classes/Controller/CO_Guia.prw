#INCLUDE "TOTVS.CH"
#Include 'Protheus.ch'
#INCLUDE "FWMVCDEF.CH"

#define G_CONSULTA  "01"
#define G_SADT_ODON "02"
#define G_SOL_INTER "03"
#define G_REEMBOLSO "04"
#define G_RES_INTER "05"
#define G_HONORARIO "06"
#define G_ANEX_QUIM "07"
#define G_ANEX_RADI "08"
#define G_ANEX_OPME "09"
#define G_REC_GLOSA "10"
#define G_PROR_INTE "11"

static lTiss4New := BD5->(FieldPos("BD5_COBESP")) > 0 .and. BD5->(FieldPos("BD5_SAUOCU")) > 0 .AND. BD5->(FieldPos("BD5_TMREGA")) > 0 

class CO_Guia
	//metodos de controle em comum a todas as guias	
	method New() Constructor
	
	method addGuia(aDados,aItens)
	method montaGuia(aDados, aItens)
	method addCont(cCodOpe, cCodRda, dDatPro, cCodLoc, cCodEsp, cCnes)
	method addProf(cCodOpe, cCodPExe, cEspExe)
	method addBenef(cCodOpe, cMatric, cNomUsr, cPadCon, cAteRn)
	method getLstProcedimentos(cMatric, aItens, objGuia) 
	method getProcOdo(cMatric, aItens) 
	method getProced(cMatric,  aItem, objGuia, objProcOdo)
	method getProtoc(cChvBEA)
	method loadIteMod(oModelBD6, aObjProcedimentos, oGuia, lOdonto) 
	method loadCabBD5(oModelBD5, oGuia, lOdonto) 
	method loadCabBE4(oModelBE4, oGuia) 
	method copyIteBD5(oModelBD6, oGuia)
	method grvGuia(oGuia, nOperation, cTipGui, lOdonto)
	method loadGuiaRecno(nRecno, lOdonto)
	method getProcChv( cChaveBD5, lOdonto, lOutrasDesp, lSadt )
	method altGuia(aCamposCabec, aCampoItem)
	method loadOutrasDesp(nRecGuiRef, cNumGuiRef, cTipGui)
	method altItem(aCmpOrg, cRecnoBD5)
	method excIteGuia(cCodTab, cCodProPar, cRecnoBD5)
	method incIteGuia(oGuia, aObjProcedimentos, lOdonto)
	method grvOutDes(nRecGuiRef, aAddItem, aEditItem, aDelItem, cTipGui) 
	method copyIteOutDes(oBD6,oBD5)
	method copyIteResInt(oBD6,oBE4)
	method addArrExec(aAddExec, cSeqMov)
	method grvAltOdon(cRecno, aCampoCabec, aAddItem, aEditItem, aDelItem)
	method grvAltSadt(cRecno, aCampoCabec, aAddItem, aEditItem, aDelItem)
	method grvAltHon(cRecno, aCamposCabec, aAddItem, aEditItem, aDelItem, aAddExec, aDelExec, cTpGui)
	method baixaLib(aDados,aItens)
	method loadGuiRecBE4(nRecno)
	method cntProced(cChave, cTpBusca)
	
	
endClass

/*/{Protheus.doc} new
Metodo construtor da classe
@author Karine Riquena Limp
@since 06/06/2016
@version P12
/*/
method new() class CO_Guia
return self

/*/{Protheus.doc} addGuia
Metodo que centraliza a montagem das guias
@author Roberto Vanderlei de Arruda
@since 09/06/2016
@version P12
/*/
method addGuia(aDados,aItens) class CO_Guia
	LOCAL cTipGui	 := PLSRETDAD( aDados,"TIPGUI","" ) // 1 - Consulta  2 - SADT  3 - Internação  4 - Odonto   5 - Honorário Individual
	LOCAL oObjGui := NIL
	LOCAL lOdonto := PLSRETDAD( aDados,"LODONTO","" )
	
	if cTipGui == "01"
		oObjGui := CO_Consulta():New()
		oObjGui := oObjGui:addGuiaConsulta(aDados,aItens)
	else 
	
		if cTipGui == "02" .and. !lOdonto
			oObjGui := CO_Sadt():New()
			oObjGui := oObjGui:addGuiaSADT(aDados,aItens)
		else 
		
			if cTipGui == "02" .and. lOdonto
				oObjGui := CO_Odonto():New()
				oObjGui := oObjGui:addGuiaOdonto(aDados,aItens)
			else
			
				if cTipGui == "06"
					oObjGui := CO_Honorario():New()
					oObjGui := oObjGui:addGuiaHonorario(aDados,aItens)
				else
					if cTipGui == "04" //Reembolso
				
						oObjGui := CO_Reembolso():New()
						oObjGui := oObjGui:addGuiaReembolso(aDados,aItens)
				
						else

							if cTipGui == "05" //Reembolso
								oObjGui := CO_ResumoInter():New()
								oObjGui := oObjGui:addGuiaResInt(aDados,aItens)
							endif
						
					endif
				
				endif
			
			endif
		
		endif
	endif
	
	self:grvGuia(oObjGui, 3, cTipGui, lOdonto)	
	
return oObjGui

method baixaLib(aDados,aItens) class CO_GUIA
LOCAL cOrigem    := PLSRETDAD( aDados,"ORIGEM","1" )
LOCAL cNumLib    := PLSRETDAD( aDados,"NUMLIB","" )
LOCAL lInter     := PLSRETDAD( aDados,"INTERN",.F. )
LOCAL lEvolu     := PLSRETDAD( aDados,"EVOLU",.F. )
LOCAL cMatric    := PLSRETDAD( aDados,"USUARIO","" )

LOCAL cTipo      := PLSRETDAD( aDados,"TIPO","1" )
LOCAL cCodRda    := PLSRETDAD( aDados,"CODRDA","" )
LOCAL cCodRdaPro := PLSRETDAD( aDados,"RDAPRO",cCodRda )

LOCAL cCodLoc    := PLSRETDAD( aDados,"CODLOC","" )
LOCAL cCodLocPro := PLSRETDAD( aDados,"LOCPRO","" )

LOCAL cCodEsp    := PLSRETDAD( aDados,"CODESP","" ) // == cCodEspPro
LOCAL cCodPRFExe := PLSRETDAD( aDados,"CDPFEX","" )

LOCAL cLocalExec  	:= "1"
LOCAL cHora      := PLSRETDAD( aDados,"HORAPRO","" )
LOCAL cViaCartao := PLSRETDAD( aDados,"VIACAR","" )
LOCAL cTipoMat   := PLSRETDAD( aDados,"TIPOMAT","" )
LOCAL cNomUsrCar := PLSRETDAD( aDados,"NOMUSR","" )
LOCAL cTipoGrv	 := PLSRETDAD( aDados,"TPGRV","1" )
LOCAL dDtIniFat  := PLSRETDAD( aDados,"DTINIFAT",CtoD("") )
LOCAL dDatPro    := PLSRETDAD( aDados,"DATPRO", dDtIniFat)
LOCAL dDatNasUsr := PLSRETDAD( aDados,"DATNAS",CtoD("") )
LOCAL lResInt    := PLSRETDAD( aDados,"RESINT",.F. )
LOCAL lHonor     := PLSRETDAD( aDados,"HORIND",.F. )
LOCAL lIncAutIE  := PLSRETDAD( aDados,"INCAUTIE",.F. )


LOCAL cOpeMov    := PLSRETDAD( aDados,"OPEMOV","" )
LOCAL cLibEsp     	:= "0"
LOCAL cAuditoria  	:= "0"
LOCAL cNumImp    := PLSRETDAD( aDados,"NUMIMP","" )
LOCAL lLoadRda   := .F.
LOCAL lRdaProf	 := ( cCodRda <> cCodRdaPro )
LOCAL lIncNeg    := NIl
LOCAL cEspSol 	 := PLSRETDAD( aDados,"ESPSOL","" )
LOCAL cEspExe	 := PLSRETDAD( aDados,"ESPEXE","" )
LOCAL lForBlo    := PLSRETDAD( aDados,"FORBLO",.F. )
LOCAL lNMudFase  := PLSRETDAD( aDados,"LNMUDF", ( GetNewPar("MV_PLMFSG",'1') == '0' )  )
LOCAL lEvoSADT   := PLSRETDAD( aDados,"EVOSADT",.F. )
local oBO_Guia   := BO_Guia():New()
LOCAL cTipGui 	 := PLSRETDAD( aDados,"TIPGUI","" ) // 1 - Consulta  2 - SADT  3 - Internação  4 - Odonto   5 - Honorário Individual

oBO_Guia:baixaLib(aItens, cOrigem,cNumLib, lInter, lEvolu, cMatric, cLocalExec, cHora, cViaCartao, cTipoMat, cNomUsrCar, cTipoGrv,;
		 dDatPro, dDatNasUsr, lResInt, lHonor, lIncAutIE, cOpeMov, cCodRda, cCodRdaPro, cCodLoc, cCodLocPro, cCodEsp,  cLibEsp,;
		 cAuditoria, cNumImp, lLoadRda, lRdaProf, lIncNeg, cTipo, cCodPRFExe, cEspSol, cEspExe, lForBlo, lNMudFase, lEvoSADT, cTipGui)
		 
return

//-------------------------------------------------------------------
/*/{Protheus.doc} montaGuia
Metodo que monta campos comuns entre todas as guias, isto é monta a VO_Guia
@author Karine Riquena Limp
@since 09/06/2016
@version P12
/*/
//-------------------------------------------------------------------
method montaGuia(objGuia, aDados, aItens, lGeraNum, lVerLib, lGerPeg) class CO_Guia    
local cTipGui 	:= PLSRETDAD( aDados,"TIPGUI","" ) // 1 - Consulta  2 - SADT  3 - Sol. Internação  4 - Reembolso   5 - Res. Internação 6 - Honorarios
local cCodOpe 	:= PLSRETDAD( aDados,"OPEMOV","" )
local cNumLib 	:= PLSRETDAD( aDados,"NUMLIB","" )
local dDatPro 	:= PLSRETDAD( aDados,"DATPRO", PLSRETDAD( aDados,"DTINIFAT",CtoD("") ) )
local cCodLoc 	:= PLSRETDAD( aDados,"CODLOC","" )
local cMatric 	:= PLSRETDAD( aDados,"USUARIO","" )
local cNomUsr 	:= PLSRETDAD( aDados,"NOMUSR","" )
local cCodRda 	:= PLSRETDAD( aDados,"CODRDA","" )
local cCboRda 	:= PLSRETDAD( aDados,"CBORDA","")  
local cCodLdp 	:= ''  
local cCodEsp 	:= iif( ! empty(cCboRda),cCboRda,PLSRETDAD( aDados,"CODESP","" ))
local cNraOpe 	:= ""
local aLib	  	:= {}			
local cOpeRDA 	:= ""  
local aRetFun 	:= {}   
local oBO_Guia 	:= BO_Guia():New()
local aBCI     	:= {}
local cAteRn   	:= IIF(PLSRETDAD( aDados,"ATENRN","0" ) $ "0,2", "0", "1")
local cPadCon	:= PLSRETDAD( aDados,"PADCON","" )
local cTipFat 	:= PLSRETDAD( aDados,"TIPFAT","" ) 
local cGuiPr    := PLSRETDAD( aDados,"GUIPR","" )
local cGuiInt   := ""
local lOdonto := PLSRETDAD( aDados,"LODONTO",.f. )

default lGeraNum := .T.
default lVerLib  := .T.
default lGerPeg  := .T.
	
// Se for reembolso pega do parâmetro.
if cTipGui == G_REEMBOLSO .or. cTipGui == '4' 
	cCodLdp	:= PLSRETLDP(4)
	objGuia:setGuiPri("")
else
	cCodLdp	:= PLSRETDAD( aDados,"CODLDP",IIF(RetDigGuia(),PLSRETLDP(4),IIF(PLSOBRPRDA(cCodRda),PLSRETLDP(9),PLSRETLDP(5) )) )
endif

aRetFun := PLSDADRDA(cCodOpe,cCodRda,"1",dDatPro,cCodLoc,cCodEsp,nil,nil,nil,nil,nil,nil,.T.)

if aRetFun[1]
	cOpeRDA := PLSGETRDA()[/*28*/14]
endIf

objGuia:setDadBenef(self:addBenef(cCodOpe, cMatric, cNomUsr, cPadCon, cAteRn))

if lGerPeg

	aBCI := PLSVRPEGOF(cCodOpe, cOpeRDA, cCodRda, alltrim(str(YEAR(dDatPro))) , STRZERO(val(alltrim(str(MONTH(dDatPro)))), 2, 0), cTipGui, /*cSituac*/, /*cLotGui*/,;
					 /*cFase*/, /*cCodLdp*/, /*cOrigem*/,/*cTipoInc*/, /*cNomeArq*/, dDatPro,;
					 /*dDatRecP*/, /*nQtdGuia*/, /*nQtdItens*/, /*nVlrTot*/, .T.)
					
	objGuia:setCodPeg( aBCI[1] )
	objGuia:setMesPag( aBCI[6] ) 
	objGuia:setAnoPag( aBCI[7] ) 

elseif cTipGui $ G_RES_INTER  + '|' + G_SOL_INTER

	BCI->(DbSetOrder(1)) 
	If BCI->( MsSeek(xFilial("BCI")+ BE4->BE4_CODOPE + BE4->BE4_CODLDP + BE4->BE4_CODPEG) )
		objGuia:setMesPag( BCI->BCI_MES ) 
		objGuia:setAnoPag( BCI->BCI_ANO ) 	
	endif
			
endif
					
objGuia:setRegAns(  Posicione("BA0",1,xFilial("BA0")+cCodOpe,"BA0_SUSEP") )
objGuia:setCodOpe( cCodOpe )                       
objGuia:setCodLdp( cCodLdp  )

if lGeraNum

	if cTipGui $ G_CONSULTA + '|' + G_SADT_ODON + '|' + G_REEMBOLSO + '|' + G_HONORARIO + '|' + G_REC_GLOSA
		
		objGuia:setNumero( PLSA500NUM("BD5", BCI->BCI_CODOPE, BCI->BCI_CODLDP, BCI->BCI_CODPEG) )
		objGuia:setNumAut( PlNewNAut("BD5", BCI->BCI_CODOPE, aBCI[7], aBCI[6], 3 ) )
		
	else
		
		objGuia:setNumero( PLSA500NUM("BE4", BCI->BCI_CODOPE, BCI->BCI_CODLDP, BCI->BCI_CODPEG) )
		objGuia:setNumAut( PlNewNAut("BE4", BCI->BCI_CODOPE, aBCI[7], aBCI[6], 3 ) )
		
	endif
	
endif

objGuia:setFase  ( /*aBCI[5]*/ "1") 
objGuia:setSituac( /*aBCI[4]*/ "1")  
objGuia:setDatPro( dDatPro )	
objGuia:setHorPro( PLSRETDAD( aDados,"HORAPRO","" )  )
objGuia:setNumImp( PLSRETDAD( aDados,"NUMIMP","" )  )

if lVerLib
	cNraOpe := oBO_Guia:preeNraOpe(cNumLib)
	objGuia:setNraOpe(cNraOpe)
endif

objGuia:setLotGui( PLSRETDAD( aDados,"LOTGUI","" ) )
objGuia:setTipGui( cTipGui )

if cTipGui $ G_CONSULTA + '|' + G_SADT_ODON
	objGuia:setGuiOri( PLSRETDAD( aDados,"GUIORI","" ) )
	objGuia:setCobEsp( PLSRETDAD( aDados,"COBESPW","" ) )
	objGuia:setTmRega( PLSRETDAD( aDados,"REGATDW","" ) )
	objGuia:setSauOcu( PLSRETDAD( aDados,"SADOCUW","" ) )
endIf
	
objGuia:setDtDigi( date() )

objGuia:setPacote( "0" ) //no plsxmov coloca sempre 0, verificar a utilidade desse campo
objGuia:setOriMov( "5" ) //Dig. Off-Line Criado para diferenciar as guias off-line para geraçao BCI
objGuia:setGuiAco( "0" ) //no plsxmov coloca sempre 0, verificar a utilidade desse campo
objGuia:setLibera( "0" ) //no plsxmov coloca sempre 0, verificar a utilidade desse campo
objGuia:setRgImp ( "1" ) //no plsxmov coloca sempre 1, verificar a utilidade desse campo
objGuia:setTpGrv ( "4" ) //no plsxmov coloca sempre 4, verificar a utilidade desse campo
objGuia:setTipCon( "1" )
objGuia:setTipAto( PLSRETDAD( aDados,"TIPATO", "") )
objGuia:setTipAte( Iif( ! empty( PLSRETDAD( aDados,"TIPATE","" ) ),StrZero( Val( PLSRETDAD( aDados,"TIPATE","" ) ),2 ),PLSRETDAD( aDados,"TIPATE","" ) ) )
objGuia:setCid   ( PLSRETDAD( aDados,"CIDPRI","" ) )
objGuia:setTipFat( cTipFat )
objGuia:setQtdEve( Len(aItens) )
objGuia:setIndAci( PLSRETDAD( aDados,"INDACI","" ) )
objGuia:setTipSai( PLSRETDAD( aDados,"TIPSAI","" ) )
objGuia:setObs( PLSRETDAD( aDados,"OBSGUI","" ) )

objGuia:setTipAdm( PLSRETDAD( aDados,"CARSOL","" )  )  
objGuia:setMsg01 ( PLSRETDAD( aDados,"MSG01",""  ) )
objGuia:setMsg02 ( PLSRETDAD( aDados,"MSG02",""  ) )
objGuia:setUtpDoe( PLSRETDAD( aDados,"UNDDOE","" ) )
objGuia:setTpOdoe( PLSRETDAD( aDados,"TMPDOE",0  ) )
objGuia:setTipDoe( PLSRETDAD( aDados,"TIPDOE","" ) )

//Se for odonto, informamos no campo 2 o número da guia principal
//para que a MF possa abater o saldo depois
if lOdonto
	objGuia:setGuiPri(cNumLib)
endif

if ! empty(cGuiPr)
    
    //Verifico se a guia informada no campo Guia Principal é de internação, para realizar a gravação do campo BD5_GUIINT
    cGuiInt := oBO_Guia:checkInt(cGuiPr)
    
    if ! empty(cGuiInt)
        objGuia:setGuiInt(cGuiInt)        
    endif
    
    //Gravação do BD5_GUIPRI com a guia informada
    objGuia:setGuiPri(cGuiPr)
    
endif

if lVerLib

	aLib := oBO_Guia:verificaLib(objGuia, cNumLib, objGuia:getDadBenef():getInterc() == "1")

	objGuia:setNrlBor(aLib[1])
	objGuia:setGuiOri(aLib[2])
	objGuia:setNraOpe(aLib[3]) 
	objGuia:setSenha (aLib[4]) 
	
endif

return

//-------------------------------------------------------------------
/*/{Protheus.doc} dadRdaCont
Metodo para retornar um contratado de acordo com o PLSGETRDA
@author Karine Riquena Limp
@since 06/06/2016
@version P12
/*/
//-------------------------------------------------------------------
method addCont(cCodOpe, cCodRda, dDatPro, cCodLoc, cCodEsp, cCnes) class CO_Guia
local oContrat  := VO_Contratado():New()
local aRetFun   := {}
local aDadRda   := {}
default cCodOpe := ""
default cCodRda := ""
default dDatPro := ddatabase
default cCodLoc := ""
default cCodEsp := ""
default cCnes   := ""

aRetFun := PLSDADRDA(cCodOpe,cCodRda,"1",dDatPro,cCodLoc,cCodEsp,nil,nil,nil,nil,nil,nil,.T.)

if aRetFun[1]
	aDadRDA := PLSGETRDA()
	oContrat:setCodRda(aDadRDA[2])
	oContrat:setOpeRda(aDadRDA[14])
	oContrat:setNomRda(aDadRDA[6])
	oContrat:setTipRda(aDadRDA[8])
	oContrat:setCodLoc(aDadRDA[12])
	oContrat:setLocal (aDadRDA[13])
	oContrat:setCodEsp(aDadRDA[15])
	oContrat:setCpfCnpjRda(aDadRDA[16])
	oContrat:setDesLoc(aDadRDA[19])
	oContrat:setEndLoc(aDadRDA[20])
	oContrat:setTipPre(aDadRDA[27])
	oContrat:setCnes  (cCnes)
else
	//VERIFICAR
	/*for nI:=1 To Len(aRetFun[2])
		if !Empty(aRetFun[2,nI,1])
			PLSICRI(@aCriticas,aRetFun[2,nI,1],aRetFun[2,nI,2])
		endIf
	next*/
endif
	
return oContrat

//-------------------------------------------------------------------
/*/{Protheus.doc} addProf
Metodo para retornar um profissional 
@author Karine Riquena Limp
@since 06/06/2016
@version P12
/*/
//-------------------------------------------------------------------
method addProf(cCodOpe, cCodProf, cEspProf) class CO_Guia
local   nRec  := 0
local   oProf := VO_Profissional():New()
default cCodOpe  := ""
default cCodProf := ""
default cEspProf  := ""
 
if !Empty(cCodProf)
	
	nRec := PLSIPRF(cCodOpe,cCodProf)
	
	if nRec > 0

		BB0->(DbGoTo(nRec))
		
		oProf:setCodOpe ( cCodOpe )
		oProf:setEstProf( BB0->BB0_ESTADO )
		oProf:setSigCr  ( BB0->BB0_CODSIG )
		oProf:setNumCr  ( BB0->BB0_NUMCR  )
		oProf:setNomProf( BB0->BB0_NOME   )
		oProf:setCdProf ( BB0->BB0_CODIGO )
		oProf:setEspProf(cEspProf)
			
	endif
	
endIf
	
return oProf

/*/{Protheus.doc} addBenef
Metodo para retornar um beneficiario 
@author Karine Riquena Limp
@since 06/06/2016
@version P12
/*/
method addBenef(cCodOpe, cMatric, cNomUsr, cPadCon, cAteRn) class CO_Guia
local oBenef  		:= nil
local nTamMat 		:= TamSx3("BA1_CODINT")[1]+TamSx3("BA1_CODEMP")[1]+TamSx3("BA1_MATRIC")[1]+TamSx3("BA1_TIPREG")[1]+TamSx3("BA1_DIGITO")[1]
local nTamAnt 		:= TamSx3("BA1_MATANT")[1]
local cSpaceUsuAtu 	:= Iif(Len(AllTrim(cMatric)) == 16,"",Space(nTamMat - Len(AllTrim(cMatric))))  
local cSpaceMatAnt 	:= Space(nTamAnt - Len(AllTrim(cMatric)))
local cMatricXML	:= ""
local lAchou   		:= .F.
local cCodEmp 		:= GetNewPar("MV_PLSGEIN","0001")
local cModulo   	:= IIF(FindFunction("StrTPLS"),Modulo11(StrTPLS(cCodOpe+cCodEmp+"99999999")),Modulo11(cCodOpe+cCodEmp+"99999999"))
local cMatrAntGen	:= cCodOpe+cCodEmp+"99999999"+cModulo

BA1->( DbSetOrder(2) ) //BA1_FILIAL + BA1_CODINT + BA1_CODEMP + BA1_MATRIC + BA1_TIPREG + BA1_DIGITO

lAchou := BA1->( MsSeek( xFilial("BA1") + allTrim(cMatric) + cSpaceUsuAtu))

if ! lAchou
    
    BA1->( DbSetOrder(5) )//BA1_FILIAL + BA1_MATANT + BA1_TIPANT

    lAchou := BA1->( MsSeek( xFilial("BA1") + allTrim(cMatric) + cSpaceMatAnt ) )
    
endIf

if lAchou

	oBenef := VO_Beneficiario():New() 
	
	oBenef:setOpeUsr(BA1->BA1_CODINT)
	oBenef:setMatAnt(BA1->BA1_MATANT)
	
	//r7
	oBenef:setNomSoci(BA1->BA1_NOMSOC)

	If alltrim(BA1->BA1_MATANT) == alltrim(cMatrAntGen)
		oBenef:setNomUsr(cNomUsr)
	Else
		oBenef:setNomUsr(BA1->BA1_NOMUSR)
	Endif
	
	If BA1->BA1_CODEMP == GetNewPar("MV_PLSGEIN","0050")
		oBenef:setInterc("1")
	Endif
	
	If ! Empty(cMatricXML)
		oBenef:setMatXml(cMatricXML)
	Endif
	
	oBenef:setCodEmp(BA1->BA1_CODEMP)
	oBenef:setMatric(BA1->BA1_MATRIC)
	oBenef:setTipReg(BA1->BA1_TIPREG)
	oBenef:setCpfUsr(BA1->BA1_CPFUSR)
	oBenef:setIdUsr(BA1->BA1_DRGUSR)
	oBenef:setDatNas(BA1->BA1_DATNAS)
	oBenef:setDigito(BA1->BA1_DIGITO)
	oBenef:setConEmp(BA1->BA1_CONEMP)
	oBenef:setVerCon(BA1->BA1_VERCON)
	oBenef:setSubCon(BA1->BA1_SUBCON)
	oBenef:setVerSub(BA1->BA1_VERSUB)
	oBenef:setMatVid(BA1->BA1_MATVID)
	oBenef:setTipPac(getNewPar("MV_PLSTPAA","9"))
  	oBenef:setMatUsa("1")
  	oBenef:setAteRna(cAteRn)
  	oBenef:setValcar(BA1->BA1_DTVLCR)
	oBenef:setOpeOri(BA1->BA1_OPEORI)
	
	If ! Empty(cPadCon)
		oBenef:setPadCon( cPadCon )
	Else
		oBenef:setPadCon(PLSACOMUSR(BA1->(BA1_CODINT+BA1_CODEMP+BA1_MATRIC+BA1_TIPREG),'2'))
	EndIf
	
	BA3->( DbSetOrder(1) )
	
	if BA3->( MsSeek( xFilial("BA3") + BA1->( BA1_CODINT+BA1_CODEMP+BA1_MATRIC ) ) )
	 	
	 	BI3->( DbSetOrder(1) )//BI3_FILIAL + BI3_CODINT + BI3_CODIGO + BI3_VERSAO
		BI3->(MsSeek(xFilial("BI3")+BA3->(BA3_CODINT+BA3_CODPLA+BA3_VERSAO) ) )
		
		oBenef:setPadInt(BI3->BI3_CODACO)
		oBenef:setCodPla(BA3->BA3_CODPLA)
		oBenef:setTipUsr(BA3->BA3_TIPOUS)
		oBenef:setModPag(BA3->BA3_MODPAG)
		
	endif
	
	//Carteira nacional de Saúde
	BTS->( DbSetOrder(1) ) //BTS_FILIAL + BTS_MATVID
	If BTS->( MsSeek(xFilial("BTS")+BA1->BA1_MATVID) ) 
		oBenef:setCrtCNS(BTS->BTS_NRCRNA)
	EndIf
	
endIf
	
return oBenef


/*/{Protheus.doc} getProcOdo

@author PLSTEAM
@since 06/06/2016
@version P12
/*/
method getProcOdo(cMatric, aItens, objGuia) class CO_Guia
local aObjProcedimentosOdonto 	:= {}
local oObjBoOdonto 				:= BO_Odonto():New()
local oObjProcedimento 			:= NIL
local oObjProcedimentoOdonto 	:= NIL
local nFor

local cDente					:= ''//BD6->BD6_DENREG
local cFace						:= ''//BD6->BD6_FADENT
	
For nFor := 1 To Len(aItens)

	cDente  := PLSRETDAD(aItens[nFor],"DENTE","")	//BD6->BD6_DENREG
	cFace   := PLSRETDAD(aItens[nFor],"FACE","")	//BD6->BD6_FADENT
			
	oObjProcedimento 		:= self:getProced(cMatric, aItens[nFor], objGuia)
	
	oObjProcedimentoOdonto := VO_ProcOdonto():New()
	oObjProcedimentoOdonto := self:getProced(cMatric, aItens[nFor], objGuia, oObjProcedimentoOdonto)
	
	oObjProcedimentoOdonto:setDenReg(cDente)
	oObjProcedimentoOdonto:setFaDent(cFace)	
	oObjProcedimentoOdonto:setDesReg(oObjBoOdonto:getDente(cDente))
	oObjProcedimentoOdonto:setFacDes(oObjBoOdonto:getFace(cFace))
			
	aadd(aObjProcedimentosOdonto, oObjProcedimentoOdonto) 
	
next 

return aObjProcedimentosOdonto

/*/{Protheus.doc} getLstProcedimentos

@author PLSTEAM
@since 06/06/2016
@version P12
/*/
method getLstProcedimentos(cMatric, aItens, objGuia) class CO_Guia
local nFor				:= 0
local aObjProcedimentos := {}
local oObj 				:= nil

For nFor := 1 To Len(aItens)
	oObj := self:getProced(cMatric, aItens[nFor], objGuia)
	aadd(aObjProcedimentos, oObj)
next	

return aObjProcedimentos

/*/{Protheus.doc} getProced
Recupera as informações do procedimento a partir da guia incluida 
@author PLSTEAM
@since 06/06/2016
@version P12
/*/
method getProced(cMatric, aItem, objGuia, objProcOdo) class CO_Guia
local objProcedimento
local oObjBoGuia  := BO_Guia():New() 
local cMatric
local cDesPro	
local aDadInt	
local aDadTab
local cSubEsp := ""
local aTpPar := {}

local cStatus := ""
 
cStatus := PLSRETDAD(aItem,"STPROC","")
if (cStatus $ 'S,N')
	cStatus := iif(cStatus == "N", "0", "1")
endif
	

//quando for ODONTO eu tenho a classe VO_ProcOdonto, entao ja passo o objeto pronto
if(Empty(objProcOdo))
	objProcedimento := VO_Procedimento():New()
else
	objProcedimento := objProcOdo
endIf

objProcedimento:setMatAnt(PLSRETDAD(aItem,"MATANT",Date())) //BD6->BD6_MATANT
objProcedimento:setNomUsr(PLSRETDAD(aItem,"NOMUSR",""))   //BD6->BD6_NOMUSR
objProcedimento:setMatric(PLSRETDAD(aItem,"MATRIC",""))	//BD6->BD6_MATRIC
	
objProcedimento:setSeqMov(PLSRETDAD(aItem,"SEQMOV")) //BD6->BD6_SEQUEN
objProcedimento:setCodPad(PLSRETDAD(aItem,"CODPAD")) //BD6->BD6_CODPAD
objProcedimento:setSlvPad(PLSRETDAD(aItem,"SLVPAD",'')) //BD6->BD6_SLVPAD
objProcedimento:setCodPro(PLSRETDAD(aItem,"CODPRO")) // BD6->BD6_CODPRO
objProcedimento:setSlvPro(PLSRETDAD(aItem,"SLVPRO",'')) //BD6->BD6_SLVPRO

cDesPro := PLSRETDAD(aItem,"DESPRO")
aTpPar	 := PLSRETDAD(aItem,"ATPPAR",{})    

objProcedimento:setVlrApr(PLSRETDAD(aItem,"VLRAPR",0)) //BD6->BD6_VLRAPR
objProcedimento:setQtd(PLSRETDAD(aItem,"QTD",0)) //BD6->BD6_QTDPRO - BD6->BD6_QTDAPR	
objProcedimento:setPerVia(PLSRETDAD(aItem,"PERVIA",0))  //BD6->BD6_PERVIA
objProcedimento:setCodVia(PLSRETDAD(aItem,"VIAAC",'')) //BD6->BD6_VIA
objProcedimento:setTecUti(alltrim(PLSRETDAD(aItem,"TECUT","1"))) //BD6->BD6_TECUTI.
objProcedimento:setPrPrRl(PLSRETDAD(aItem,"REDAC" , 1 )) //BD6->BD6_TECUTI
objProcedimento:setDtPro(PLSRETDAD(aItem,"DATPRO",Date())) //BD6->BD6_DATPRO
objProcedimento:setHorIni(PLSRETDAD(aItem,"HORINI",""))   //BD6->BD6_HORPRO
objProcedimento:setHorFim(PLSRETDAD(aItem,"HORFIM",""))	//BD6->BD6_HORFIM
	
/*Descrição do Procedimento*/		
objProcedimento:setDesPro(oObjBoGuia:getDescProcedimento(objProcedimento:getCodPro(), cDesPro, objProcedimento:getCodPad()))

objProcedimento:setNivel(BR8->BR8_NIVEL) // BD6->BD6_NIVEL

If !Empty(objProcedimento:getCodVia()) .and. objProcedimento:getCodVia() >= "1"
   	objProcedimento:setProcCirurgico("1") 	//BD6->BD6_PROCCI
Endif
 	
/*Dados Intercâmbio*/
aDadInt := oObjBoGuia:getDadIntercambio(cMatric)

if len(aDadInt) > 0
	objProcedimento:setInterc(aDadInt[1])
endif

if len(aDadInt) > 1
	objProcedimento:setTipInt(aDadInt[2])
endif

objProcedimento:setIncAut("")

if alltrim(cStatus) = "0"   
	objProcedimento:setStatus("0")
else
	objProcedimento:setStatus("1")
endif

objProcedimento:setChvNiv("")
objProcedimento:setNivAut("")
								 
objProcedimento:setBloqPag("0")

//Preenchendo dados da Tabela 

aDadTab := oObjBoGuia:getDadTabela(objProcedimento:getCodPad(),objProcedimento:getCodPro(),;
								   objProcedimento:getDtPro(),objGuia:getCodOpe(), objGuia:getContExec():getCodRda(),;
								   objGuia:getContExec():getCodEsp(),cSubEsp,objGuia:getContExec():getCodLoc(),objGuia:getContExec():getLocal(),; 
								   objGuia:getDadBenef():getOpeOri(), objGuia:getDadBenef():getCodPla(), objGuia:cTipAte)

if len(aDadTab) > 0
	objProcedimento:setCodTab(aDadTab[1]) //BD6->BD6_CODTAB
endif

if len(aDadTab) > 1
	objProcedimento:setAliaTb(aDadTab[2]) //BD6->BD6_ALIATB
endif

objProcedimento:setPart(oObjBoGuia:getPartic(aTpPar, objProcedimento:getSeqMov(), objProcedimento:getCodPad(), objProcedimento:getCodPro(), objProcedimento:getVlrApr(), objGuia:getContExec():getCodRda()))

return objProcedimento


/*/{Protheus.doc} loadIteMod

@author PLSTEAM
@since 06/06/2016
@version P12
/*/
method loadIteMod(oModelBD6, aObjProcedimentos, oGuiaConsulta, lOdonto) class CO_Guia

	local nFor
	Local lValori	:= BD6->(FieldPos("BD6_VALORI")) > 0
	default lOdonto := .F.
	
	For nFor := 1 To Len(aObjProcedimentos)
		
	if (nFor <> 1 .or. ( ( oGuiaConsulta:getTipGui() == "02" .or.  oGuiaConsulta:getTipGui() == "04" .or.  oGuiaConsulta:getTipGui() == "05" ) .and. !lOdonto .and. !Empty(oModelBD6:getValue("BD6_CODPRO") ) ) ) 			
			oModelBD6:AddLine()
		endif
		
		oModelBD6:LoadValue("BD6_SEQUEN", aObjProcedimentos[nFor]:getSeqMov())
		oModelBD6:LoadValue("BD6_CODPAD", aObjProcedimentos[nFor]:getCodPad())
		
		if oGuiaConsulta:getDadBenef() <> NIL
			oModelBD6:LoadValue("BD6_TIPUSR",oGuiaConsulta:getDadBenef():getTipUsr())
			oModelBD6:LoadValue("BD6_MODCOB",left(alltrim(oGuiaConsulta:getDadBenef():getModPag()), TamSx3("BD6_MODCOB")[1]))
			oModelBD6:LoadValue("BD6_CODPLA",oGuiaConsulta:getDadBenef():getCodPla())
			oModelBD6:LoadValue("BD6_OPEORI",oGuiaConsulta:getDadBenef():getOpeOri())
		endif
		
	//Se for reembolso, preenche o beneficiário passado por parâmetro.
	if oGuiaConsulta:getTipGui() = "04" .or. oGuiaConsulta:getTipGui() = "4" 
			oModelBD6:LoadValue("BD6_MATRIC", alltrim(aObjProcedimentos[nFor]:getMatric()))
			oModelBD6:LoadValue("BD6_MATANT", alltrim(aObjProcedimentos[nFor]:getMatAnt()))
			oModelBD6:LoadValue("BD6_NOMUSR", aObjProcedimentos[nFor]:getNomUsr())
		
			//protocolo de reembolso
			oModelBD6:LoadValue("BD6_PROTOC", aObjProcedimentos[nFor]:getProtoc())
		endif
		
		oModelBD6:LoadValue("BD6_SLVPAD", aObjProcedimentos[nFor]:getSlvPad())
		oModelBD6:LoadValue("BD6_CODPRO", aObjProcedimentos[nFor]:getCodPro())
		oModelBD6:LoadValue("BD6_SLVPRO", aObjProcedimentos[nFor]:getSlvPro())
		oModelBD6:LoadValue("BD6_DESPRO", left(aObjProcedimentos[nFor]:getDesPro(), TamSx3("BD6_DESPRO")[1])) 
		oModelBD6:LoadValue("BD6_NIVEL" , aObjProcedimentos[nFor]:getNivel())
		oModelBD6:LoadValue("BD6_VLRAPR", aObjProcedimentos[nFor]:getVlrApr())
			
		oModelBD6:LoadValue("BD6_QTDPRO", aObjProcedimentos[nFor]:getQtd())
		
		if lValori
			oModelBD6:LoadValue("BD6_VALORI", oModelBD6:getvalue("BD6_QTDPRO") * oModelBD6:getValue("BD6_VLRAPR") )
		EndIf
		
		oModelBD6:LoadValue("BD6_PERVIA", aObjProcedimentos[nFor]:getPerVia())
		oModelBD6:LoadValue("BD6_VIA"   , aObjProcedimentos[nFor]:getCodVia())
		oModelBD6:LoadValue("BD6_PROCCI", aObjProcedimentos[nFor]:getProcCirurgico())
		oModelBD6:LoadValue("BD6_DATPRO", aObjProcedimentos[nFor]:getDtPro())
		oModelBD6:LoadValue("BD6_HORPRO", aObjProcedimentos[nFor]:getHorIni())
		oModelBD6:LoadValue("BD6_HORFIM", aObjProcedimentos[nFor]:getHorFim())
		oModelBD6:LoadValue("BD6_TECUTI", aObjProcedimentos[nFor]:getTecUti())
		oModelBD6:LoadValue("BD6_PRPRRL", aObjProcedimentos[nFor]:getPrPrRl())

		oModelBD6:LoadValue("BD6_INCAUT", aObjProcedimentos[nFor]:getIncAut())
		oModelBD6:LoadValue("BD6_STATUS", aObjProcedimentos[nFor]:getStatus())
		oModelBD6:LoadValue("BD6_CHVNIV", aObjProcedimentos[nFor]:getChvNiv())
		oModelBD6:LoadValue("BD6_NIVAUT", aObjProcedimentos[nFor]:getNivAut())
		oModelBD6:LoadValue("BD6_CODTAB", aObjProcedimentos[nFor]:getCodTab())
		oModelBD6:LoadValue("BD6_ALIATB", aObjProcedimentos[nFor]:getAliaTb())
		oModelBD6:LoadValue("BD6_BLOPAG", aObjProcedimentos[nFor]:getBloqPag())
		oModelBD6:LoadValue("BD6_INTERC", aObjProcedimentos[nFor]:getInterc())
		oModelBD6:LoadValue("BD6_TIPINT", aObjProcedimentos[nFor]:getTipInt())
		
		if lOdonto
			if(!empty(aObjProcedimentos[nFor]:getDenReg()))
				oModelBD6:LoadValue("BD6_DENREG", left(aObjProcedimentos[nFor]:getDenReg(), TamSX3("BD6_DENREG")[1]))
				oModelBD6:LoadValue("BD6_DESREG", left(aObjProcedimentos[nFor]:getDesReg(), TamSX3("BD6_DESREG")[1]))
			endIf
			
			if(!empty(aObjProcedimentos[nFor]:getFaDent()))
				oModelBD6:LoadValue("BD6_FADENT", left(aObjProcedimentos[nFor]:getFaDent(), TamSX3("BD6_FADENT")[1]))
				oModelBD6:LoadValue("BD6_FACDES", left(aObjProcedimentos[nFor]:getFacDes(), TamSX3("BD6_DESREG")[1]))
			endIf
		endif
		
		oModelBD6 := self:copyIteBD5(oModelBD6, oGuiaConsulta)
		
		oModelBD6:LoadValue("BD6_ORIMOV", oGuiaConsulta:getOriMov()) 
		
		//Armazena a linha atual do model BD6 que é correspondente ao item do objeto procedimento
		aObjProcedimentos[nFor]:setSeqModel(oModelBD6:nLine)
	next
	
return oModelBD6

/*/{Protheus.doc} loadCabBE4

@author PLSTEAM
@since 06/06/2016
@version P12
/*/
method loadCabBE4(oModelBE4, oGuia) class CO_Guia

	oModelBE4:LoadValue("BE4_GUIINT", oGuia:getNumGuiSolInt())
	
	oModelBE4:LoadValue("BE4_NUMINT",oGuia:getNumAut())
	oModelBE4:LoadValue("BE4_CODOPE",oGuia:getCodOpe())
	
	//dados do beneficiario
	oModelBE4:LoadValue("BE4_ERRO", "0" )
	oModelBE4:LoadValue("BE4_TIPADM", oGuia:getTipAdm())
	oModelBE4:LoadValue("BE4_TIPALT", oGuia:getMotEncer())
	
	oModelBE4:LoadValue("BE4_TIPINT",oGuia:getTpInt())
	oModelBE4:LoadValue("BE4_GRPINT",oGuia:getGrpint())
	oModelBE4:LoadValue("BE4_CID",oGuia:getCid())
	oModelBE4:LoadValue("BE4_CIDSEC",oGuia:getCid2())
	oModelBE4:LoadValue("BE4_CID3",oGuia:getCid3())
	oModelBE4:LoadValue("BE4_CID4",oGuia:getCid4())
	oModelBE4:LoadValue("BE4_CIDOBT",oGuia:getCidObito()) 
	
	oModelBE4:LoadValue("BE4_OPEUSR",oGuia:getDadBenef():getOpeUsr())	
	oModelBE4:LoadValue("BE4_ATERNA",oGuia:getDadBenef():getAteRna())
	//oModelBE4:LoadValue("BE4_DATVAL",oGuia:getDadBenef():getMatAnt())
	//oModelBE4:LoadValue("BE4_SENHA",oGuia:getDadBenef():getMatAnt())
	
	oModelBE4:LoadValue("BE4_CODRDA",oGuia:getContExec():getCodRda())
	oModelBE4:LoadValue("BE4_NOMRDA",left(oGuia:getContExec():getNomRda(), TamSx3("BE4_NOMRDA")[1])) //oGuia:getContExec():getNomRda())	
	oModelBE4:LoadValue("BE4_OPERDA",oGuia:getContExec():getOpeRda())	
	oModelBE4:LoadValue("BE4_CODLOC",oGuia:getContExec():getCodLoc())
	
	oModelBE4:LoadValue("BE4_CODESP",oGuia:getContExec():getCodEsp())
	
	oModelBE4:LoadValue("BE4_MATRIC",oGuia:getDadBenef():getMatric())
	oModelBE4:LoadValue("BE4_MATANT",oGuia:getDadBenef():getMatAnt())
  	oModelBE4:LoadValue("BE4_NOMUSR",oGuia:getDadBenef():getNomUsr())  	
  	oModelBE4:LoadValue("BE4_TIPREG",oGuia:getDadBenef():getTipReg())
  	oModelBE4:LoadValue("BE4_DATNAS",oGuia:getDadBenef():getDatNas())
	oModelBE4:LoadValue("BE4_DIGITO",oGuia:getDadBenef():getDigito())
	oModelBE4:LoadValue("BE4_MATVID",oGuia:getDadBenef():getMatVid())
	oModelBE4:LoadValue("BE4_CODEMP",oGuia:getDadBenef():getCodEmp())
	
  	oModelBE4:LoadValue("BE4_CONEMP",oGuia:getDadBenef():getConEmp())  	
  	oModelBE4:LoadValue("BE4_VERCON",oGuia:getDadBenef():getVerCon())
	oModelBE4:LoadValue("BE4_SUBCON",oGuia:getDadBenef():getSubCon())
  	oModelBE4:LoadValue("BE4_VERSUB",oGuia:getDadBenef():getVerSub())  	

  	if alltrim(oGuia:getDadBenef():getMatric()) == ""
  		oModelBE4:LoadValue("BE4_MATUSA", "2")
  	else
  		oModelBE4:LoadValue("BE4_MATUSA", "1")
  	endif	
  	
  	oModelBE4:LoadValue("BE4_DATPRO",oGuia:getDatPro())
  	oModelBE4:LoadValue("BE4_HORPRO",oGuia:getHorPro())
  	oModelBE4:LoadValue("BE4_PADCON",oGuia:getDadBenef():getPadCon())
  	oModelBE4:LoadValue("BE4_PADINT",oGuia:getDadBenef():getPadInt())
  	
  	oModelBE4:LoadValue("BE4_CODLDP",oGuia:getCodLdp())
	oModelBE4:LoadValue("BE4_CODPEG",oGuia:getCodPeg())
	oModelBE4:LoadValue("BE4_NUMERO",left(oGuia:getNumero(), TamSx3("BE4_NUMERO")[1])) 
  	oModelBE4:LoadValue("BE4_LOCAL",oGuia:getContExec():getLocal())
  	oModelBE4:LoadValue("BE4_PACOTE",oGuia:getPacote())
  	oModelBE4:LoadValue("BE4_ORIMOV",oGuia:getOriMov())
  	oModelBE4:LoadValue("BE4_TIPGUI",oGuia:getTipGui())
  	
  	oModelBE4:LoadValue("BE4_DESOPE", "ELETRONICA")
  	oModelBE4:LoadValue("BE4_INDACI", oGuia:getIndAci())
  	oModelBE4:LoadValue("BE4_REGINT", oGuia:getRegInt())

  	oModelBE4:LoadValue("BE4_TIPFAT", oGuia:getTipFat())
  	
  	oModelBE4:LoadValue("BE4_DTINIF", oGuia:getDtIniFat())
  	oModelBE4:LoadValue("BE4_HRINIF", oGuia:getHrIniFat())
  	oModelBE4:LoadValue("BE4_DTFIMF", oGuia:getDtFimFat())
  	oModelBE4:LoadValue("BE4_HRFIMF", oGuia:getHrFimFat())
  	
  	oModelBE4:LoadValue("BE4_STTISS", "1")
  	oModelBE4:LoadValue("BE4_CANCEL", "0")
  	oModelBE4:LoadValue("BE4_COMUNI", "0")  	
  	oModelBE4:LoadValue("BE4_EMGEST", "0")
  	oModelBE4:LoadValue("BE4_ABORTO", "0")
  	oModelBE4:LoadValue("BE4_TRAGRA", "0")
  	oModelBE4:LoadValue("BE4_COMURP", "0")
  	oModelBE4:LoadValue("BE4_ATESPA", "0")
  	oModelBE4:LoadValue("BE4_COMNAL", "0")
  	oModelBE4:LoadValue("BE4_BAIPES", "0")
  	oModelBE4:LoadValue("BE4_PARCES", "0")
  	oModelBE4:LoadValue("BE4_PATNOR", "0")
  	
  	oModelBE4:LoadValue("BE4_MESPAG",STRZERO(val(oGuia:getMesPag()), 2, 0))
	oModelBE4:LoadValue("BE4_ANOPAG",oGuia:getAnoPag())
	
	oModelBE4:LoadValue("BE4_MESINT",STRZERO(val(oGuia:getMesPag()), 2, 0))
	oModelBE4:LoadValue("BE4_ANOINT",oGuia:getAnoPag())
	If ( Len(oGuia:getObsFim()) > 250 )
		oModelBE4:LoadValue("BE4_MSG01", SubStr(oGuia:getObsFim(), 1,250))
		oModelBE4:LoadValue("BE4_MSG02", SubStr(oGuia:getObsFim(),251,500))
	Else
		oModelBE4:LoadValue("BE4_MSG01", oGuia:getObsFim())
	EndIf
	oModelBE4:LoadValue("BE4_PADINT",oGuia:gettpCom())
	oModelBE4:LoadValue("BE4_PADCON",oGuia:getpadCon())
  	    	
	//Remover FIELDPOS depois da aplicação do dicionário nos ambientes
	if BE4->(fieldPos("BE4_NOMSOC")) > 0
		oModelBE4:LoadValue("BE4_NOMSOC", oGuia:getDadBenef():getNomSoci())
  	endif    	
return oModelBE4
	
/*/{Protheus.doc} loadCabBD5

@author PLSTEAM
@since 06/06/2016
@version P12
/*/	
method loadCabBD5(oModelBD5, oGuia, lOdonto) class CO_Guia
default lOdonto := .F.

	//dados do beneficiario
	oModelBD5:LoadValue("BD5_OPEUSR",oGuia:getDadBenef():getOpeUsr())
	oModelBD5:LoadValue("BD5_MATANT",oGuia:getDadBenef():getMatAnt())
  	oModelBD5:LoadValue("BD5_NOMUSR",oGuia:getDadBenef():getNomUsr())  	
  	oModelBD5:LoadValue("BD5_MATXML",oGuia:getDadBenef():getMatXml())
	oModelBD5:LoadValue("BD5_CODEMP",oGuia:getDadBenef():getCodEmp())
  	oModelBD5:LoadValue("BD5_MATRIC",oGuia:getDadBenef():getMatric())  	
  	oModelBD5:LoadValue("BD5_TIPREG",oGuia:getDadBenef():getTipReg())
	oModelBD5:LoadValue("BD5_CPFUSR",oGuia:getDadBenef():getCpfUsr())
  	oModelBD5:LoadValue("BD5_IDUSR",oGuia:getDadBenef():getIdUsr())  	
  	oModelBD5:LoadValue("BD5_DATNAS",oGuia:getDadBenef():getDatNas())
	oModelBD5:LoadValue("BD5_DIGITO",oGuia:getDadBenef():getDigito())
  	oModelBD5:LoadValue("BD5_CONEMP",oGuia:getDadBenef():getConEmp())  	
  	oModelBD5:LoadValue("BD5_VERCON",oGuia:getDadBenef():getVerCon())
	oModelBD5:LoadValue("BD5_SUBCON",oGuia:getDadBenef():getSubCon())
  	oModelBD5:LoadValue("BD5_VERSUB",oGuia:getDadBenef():getVerSub())  	
  	oModelBD5:LoadValue("BD5_MATVID",oGuia:getDadBenef():getMatVid())
	oModelBD5:LoadValue("BD5_TIPPAC",oGuia:getDadBenef():getTipPac())
  	oModelBD5:LoadValue("BD5_MATUSA",oGuia:getDadBenef():getMatUsa())  	
  	oModelBD5:LoadValue("BD5_ATERNA",oGuia:getDadBenef():getAteRna())
	oModelBD5:LoadValue("BD5_PADCON",oGuia:getDadBenef():getPadCon())
  	oModelBD5:LoadValue("BD5_PADINT",oGuia:getDadBenef():getPadInt())
  	  	  	
	oModelBD5:LoadValue("BD5_CODOPE",oGuia:getCodOpe())
	oModelBD5:LoadValue("BD5_OPEMOV",oGuia:getCodOpe())
	oModelBD5:LoadValue("BD5_CODLDP",oGuia:getCodLdp())
	oModelBD5:LoadValue("BD5_CODPEG",oGuia:getCodPeg())
	oModelBD5:LoadValue("BD5_NUMERO",left(oGuia:getNumero(), TamSx3("BD5_NUMERO")[1])) 
	oModelBD5:LoadValue("BD5_FASE",oGuia:getFase())
	oModelBD5:LoadValue("BD5_SITUAC",oGuia:getSituac())
	oModelBD5:LoadValue("BD5_DATPRO",oGuia:getDatPro())
	oModelBD5:LoadValue("BD5_HORPRO",oGuia:getHorPro())
	oModelBD5:LoadValue("BD5_NUMIMP",oGuia:getNumImp())
	oModelBD5:LoadValue("BD5_NRAOPE",oGuia:getNraOpe())
	oModelBD5:LoadValue("BD5_LOTGUI",oGuia:getLotGui())
	oModelBD5:LoadValue("BD5_TIPGUI",oGuia:getTipGui())
	oModelBD5:LoadValue("BD5_GUIORI",oGuia:getGuiOri())
	oModelBD5:LoadValue("BD5_DTDIGI",oGuia:getDtDigi())
	oModelBD5:LoadValue("BD5_MESPAG",STRZERO(val(oGuia:getMesPag()), 2, 0))
	oModelBD5:LoadValue("BD5_ANOPAG",oGuia:getAnoPag())
	oModelBD5:LoadValue("BD5_MESAUT",STRZERO(val(oGuia:getMesPag()), 2, 0))
	oModelBD5:LoadValue("BD5_ANOAUT",oGuia:getAnoPag())
	oModelBD5:LoadValue("BD5_NUMAUT",oGuia:getNumAut())
	oModelBD5:LoadValue("BD5_PACOTE",oGuia:getPacote())
	oModelBD5:LoadValue("BD5_ORIMOV",oGuia:getOriMov())
	oModelBD5:LoadValue("BD5_GUIACO",oGuia:getGuiAco())
	oModelBD5:LoadValue("BD5_LIBERA",oGuia:getLibera())
	oModelBD5:LoadValue("BD5_RGIMP",oGuia:getRgImp())
	oModelBD5:LoadValue("BD5_TPGRV",oGuia:getTpGrv())
	oModelBD5:LoadValue("BD5_TIPATE",oGuia:getTipAte())
	oModelBD5:LoadValue("BD5_CID",oGuia:getCid())
	oModelBD5:LoadValue("BD5_TIPFAT",oGuia:getTipFat())
	oModelBD5:LoadValue("BD5_QTDEVE",oGuia:getQtdEve())
	oModelBD5:LoadValue("BD5_INDACI",oGuia:getIndAci())
	oModelBD5:LoadValue("BD5_TIPSAI",left(alltrim(oGuia:getTipSai()), TamSx3("BD5_TIPSAI")[1]))
	oModelBD5:LoadValue("BD5_TIPADM",oGuia:getTipAdm())
	oModelBD5:LoadValue("BD5_UTPDOE",oGuia:getUtpDoe())
	oModelBD5:LoadValue("BD5_TPODOE",oGuia:getTpOdoe())
	oModelBD5:LoadValue("BD5_TIPDOE",oGuia:getTipDoe())
	oModelBD5:LoadValue("BD5_NRLBOR",oGuia:getNrlBor())
	oModelBD5:LoadValue("BD5_GUIPRI",oGuia:getGuiPri())
	oModelBD5:LoadValue("BD5_SENHA",oGuia:getSenha())
	
	//Consulta (Herança)
	oModelBD5:LoadValue("BD5_TIPCON",oGuia:getTipCon())
	oModelBD5:LoadValue("BD5_TIPATO",oGuia:getTipAto())
	nTamObs := (TamSX3("BD5_OBSGUI")[1])
	oModelBD5:LoadValue("BD5_OBSGUI", SubStr(AllTrim(oGuia:getObs()),1, nTamObs))
	If BD5->(FieldPos("BD5_OBSGU2")) > 0
		oModelBD5:LoadValue("BD5_OBSGU2", IIF (Len(oGuia:getObs()) > nTamObs, SubStr(oGuia:getObs(),nTamObs+1,Len(oGuia:getObs()) ), ""))
	EndIf
	
	//Contratado
	oModelBD5:LoadValue("BD5_CODRDA",oGuia:getContExec():getCodRda())
	oModelBD5:LoadValue("BD5_OPERDA",oGuia:getContExec():getOpeRda())
	oModelBD5:LoadValue("BD5_NOMRDA",left(oGuia:getContExec():getNomRda(), TamSx3("BD5_NOMRDA")[1])) //oGuia:getContExec():getNomRda())
	oModelBD5:LoadValue("BD5_TIPRDA",oGuia:getContExec():getTipRda())
	oModelBD5:LoadValue("BD5_CODLOC",oGuia:getContExec():getCodLoc())
	oModelBD5:LoadValue("BD5_LOCAL",oGuia:getContExec():getLocal())
	oModelBD5:LoadValue("BD5_CODESP",oGuia:getContExec():getCodEsp())
	oModelBD5:LoadValue("BD5_CPFRDA",oGuia:getContExec():getCpfCnpjRda())
	oModelBD5:LoadValue("BD5_DESLOC",oGuia:getContExec():getDesLoc())
	oModelBD5:LoadValue("BD5_ENDLOC",oGuia:getContExec():getEndLoc())	
	oModelBD5:LoadValue("BD5_TIPPRE",oGuia:getContExec():getTipPre())
	oModelBD5:LoadValue("BD5_CNES",oGuia:getContExec():getCnes())	
	
	//Profissional Executante
	if ( oGuia:getProfExec() <> NIL .And. (oGuia:getTipGui() <> "06") )//Não é necessário preencher 
		oModelBD5:LoadValue("BD5_OPEEXE",oGuia:getProfExec():getCodOpe())
		oModelBD5:LoadValue("BD5_ESTEXE",oGuia:getProfExec():getEstProf())
		oModelBD5:LoadValue("BD5_SIGEXE",oGuia:getProfExec():getSigCr())
		oModelBD5:LoadValue("BD5_REGEXE",oGuia:getProfExec():getNumCr())
		oModelBD5:LoadValue("BD5_NOMEXE",left(oGuia:getProfExec():getNomProf(), TamSx3("BD5_NOMEXE")[1])) 
		oModelBD5:LoadValue("BD5_CDPFRE",oGuia:getProfExec():getCdProf())
		oModelBD5:LoadValue("BD5_ESPEXE",oGuia:getProfExec():getEspProf())
	endif
	
	//Profissional Solicitante
	if oGuia:getProfSol() <> NIL
		oModelBD5:LoadValue("BD5_OPESOL",oGuia:getProfSol():getCodOpe())
		oModelBD5:LoadValue("BD5_ESTSOL",oGuia:getProfSol():getEstProf())
		oModelBD5:LoadValue("BD5_SIGLA",oGuia:getProfSol():getSigCr())
		oModelBD5:LoadValue("BD5_REGSOL",oGuia:getProfSol():getNumCr())
		oModelBD5:LoadValue("BD5_NOMSOL",left(oGuia:getProfSol():getNomProf(), TamSx3("BD5_NOMSOL")[1])) 
		oModelBD5:LoadValue("BD5_CDPFSO",oGuia:getProfSol():getCdProf())
		oModelBD5:LoadValue("BD5_ESPSOL",oGuia:getProfSol():getEspProf())
	endif
	
	if oGuia:getTipGui() == "06"
		
		oModelBD5:LoadValue("BD5_REGFOR",oGuia:getRegFor())
		oModelBD5:LoadValue("BD5_DTFTIN",oGuia:getDtIniFat())
		oModelBD5:LoadValue("BD5_DTFTFN",oGuia:getDtFimFat())
		oModelBD5:LoadValue("BD5_GUIINT",oGuia:getGuiInt())
		
	elseif oGuia:getTipGui() == "02" .and. !lOdonto

		nTaman := (TamSX3("BD5_INDCLI")[1])
		oModelBD5:LoadValue("BD5_INDCLI", SubStr(AllTrim(oGuia:getIndCli()),1, nTaman))
		oModelBD5:LoadValue("BD5_INDCL2", IIF (Len(oGuia:getIndCli()) > nTaman, SubStr(oGuia:getIndCli(),nTaman+1,Len(oGuia:getIndCli()) ), ""))

		oModelBD5:LoadValue("BD5_DATSOL",oGuia:getDatSol())
		
		oModelBD5:LoadValue("BD5_DTRLZ",oGuia:getdDtRlS())
		oModelBD5:LoadValue("BD5_DTRLZ2",oGuia:getdDtRlS2())
		oModelBD5:LoadValue("BD5_DTRLZ3",oGuia:getdDtRlS3())
		oModelBD5:LoadValue("BD5_DTRLZ4",oGuia:getdDtRlS4())
		oModelBD5:LoadValue("BD5_DTRLZ5",oGuia:getdDtRlS5())
		oModelBD5:LoadValue("BD5_DTRLZ6",oGuia:getdDtRlS6())
		oModelBD5:LoadValue("BD5_DTRLZ7",oGuia:getdDtRlS7())
		oModelBD5:LoadValue("BD5_DTRLZ8",oGuia:getdDtRlS8())
		oModelBD5:LoadValue("BD5_DTRLZ9",oGuia:getdDtRlS9())
		oModelBD5:LoadValue("BD5_DTRLZ1",oGuia:getdDtRlS1())
			
	endIf

	//Campos novos TISS 4.00
	if lTiss4New .and. oGuia:getTipGui() $ G_CONSULTA + "|" + G_SADT_ODON
		oModelBD5:LoadValue("BD5_COBESP", oGuia:getCobEsp())
		oModelBD5:LoadValue("BD5_TMREGA", oGuia:getTmRega())
		oModelBD5:LoadValue("BD5_SAUOCU", oGuia:getSauOcu())
	endif
		
	//Remover FIELDPOS depois da aplicação dos dicionários
	if BD5->(fieldPos("BD5_NOMSOC")) > 0
		oModelBD5:LoadValue("BD5_NOMSOC", oGuia:getDadBenef():getNomSoci())
  	endif 
		
return oModelBD5

/*/{Protheus.doc} copyIteBD5

@author PLSTEAM
@since 06/06/2016
@version P12
/*/
method copyIteBD5(oBD6, oGuia) class CO_Guia

	oBD6:LoadValue("BD6_CODESP", oGuia:getContExec():getCodEsp())
	oBD6:LoadValue("BD6_NRAOPE", oGuia:getNraOpe())
	oBD6:LoadValue("BD6_CODOPE", oGuia:getCodOpe())
	oBD6:LoadValue("BD6_CODLDP",oGuia:getCodLdp())
	oBD6:LoadValue("BD6_CODPEG",oGuia:getCodPeg())
	oBD6:LoadValue("BD6_NUMERO",left(oGuia:getNumero(), TamSx3("BD6_NUMERO")[1])) 
	
	if oGuia:getTipGui() <> "05" .and. oGuia:getProfSol() <> NIL
		oBD6:LoadValue("BD6_ESPSOL",oGuia:getProfSol():getEspProf())
		oBD6:LoadValue("BD6_ESTSOL",oGuia:getProfSol():getEstProf())
		oBD6:LoadValue("BD6_SIGLA",oGuia:getProfSol():getSigCr())
		oBD6:LoadValue("BD6_REGSOL",oGuia:getProfSol():getNumCr())
		oBD6:LoadValue("BD6_NOMSOL",left(oGuia:getProfSol():getNomProf(), TamSx3("BD6_NOMSOL")[1])) 
		oBD6:LoadValue("BD6_CDPFSO",oGuia:getProfSol():getCdProf())
	endif
	
	if oGuia:getTipGui() <> "05" .and. oGuia:getProfExec() <> NIL
		oBD6:LoadValue("BD6_ESPEXE",oGuia:getProfExec():getEspProf())
		oBD6:LoadValue("BD6_ESTEXE",oGuia:getProfExec():getEstProf())
		oBD6:LoadValue("BD6_SIGEXE",oGuia:getProfExec():getSigCr())
		oBD6:LoadValue("BD6_REGEXE",oGuia:getProfExec():getNumCr())
		oBD6:LoadValue("BD6_CDPFRE",oGuia:getProfExec():getCdProf())
		oBD6:LoadValue("BD6_OPEEXE",oGuia:getProfExec():getCodOpe())		
	endif
	
	oBD6:LoadValue("BD6_CODRDA",oGuia:getContExec():getCodRda())
	oBD6:LoadValue("BD6_NOMRDA",left(oGuia:getContExec():getNomRda(), TamSx3("BD6_NOMRDA")[1])) //oGuia:getContExec():getNomRda())
	oBD6:LoadValue("BD6_TIPRDA",oGuia:getContExec():getTipRda())
	oBD6:LoadValue("BD6_CODLOC",oGuia:getContExec():getCodLoc())
	oBD6:LoadValue("BD6_LOCAL",oGuia:getContExec():getLocal())
	oBD6:LoadValue("BD6_CPFRDA",oGuia:getContExec():getCpfCnpjRda())
	oBD6:LoadValue("BD6_DESLOC",oGuia:getContExec():getDesLoc())
	oBD6:LoadValue("BD6_ENDLOC",oGuia:getContExec():getEndLoc())
	oBD6:LoadValue("BD6_OPEUSR",oGuia:getDadBenef():getOpeUsr())
	
	if oGuia:getTipGui() <> "04" .and. oGuia:getTipGui() <> "4" //Só pega esses dados do cabeçalho se não for reembolso. Caso seja Reembolso, esses itens devem ser resgatados da B1N 
		oBD6:LoadValue("BD6_MATANT",oGuia:getDadBenef():getMatAnt())
		oBD6:LoadValue("BD6_NOMUSR",oGuia:getDadBenef():getNomUsr())
		oBD6:LoadValue("BD6_MATRIC",oGuia:getDadBenef():getMatric())
	endif
	
	oBD6:LoadValue("BD6_CODEMP",oGuia:getDadBenef():getCodEmp())
	oBD6:LoadValue("BD6_TIPREG",oGuia:getDadBenef():getTipReg())
	oBD6:LoadValue("BD6_IDUSR",oGuia:getDadBenef():getIdUsr())
	oBD6:LoadValue("BD6_DATNAS",oGuia:getDadBenef():getDatNas())
	oBD6:LoadValue("BD6_DIGITO",oGuia:getDadBenef():getDigito())
	oBD6:LoadValue("BD6_CONEMP",oGuia:getDadBenef():getConEmp())
	oBD6:LoadValue("BD6_VERCON",oGuia:getDadBenef():getVerCon())
	oBD6:LoadValue("BD6_SUBCON",oGuia:getDadBenef():getSubCon())
	oBD6:LoadValue("BD6_VERSUB",oGuia:getDadBenef():getVerSub())
	oBD6:LoadValue("BD6_MATVID",oGuia:getDadBenef():getMatVid())
	oBD6:LoadValue("BD6_FASE",oGuia:getFase())
	oBD6:LoadValue("BD6_SITUAC",oGuia:getSituac())
	oBD6:LoadValue("BD6_NUMIMP",oGuia:getNumImp())
	oBD6:LoadValue("BD6_NRAOPE",oGuia:getNraOpe())
	oBD6:LoadValue("BD6_LOTGUI",oGuia:getLotGui())
	oBD6:LoadValue("BD6_TIPGUI",oGuia:getTipGui())
	oBD6:LoadValue("BD6_GUIORI",oGuia:getGuiOri())
	oBD6:LoadValue("BD6_DTDIGI",IIF(EmpTy(oGuia:getDtDigi()), Date(), oGuia:getDtDigi()))
	oBD6:LoadValue("BD6_MESPAG",oGuia:getMesPag())
	oBD6:LoadValue("BD6_ANOPAG",oGuia:getAnoPag())
	oBD6:LoadValue("BD6_MATUSA",oGuia:getDadBenef():getMatUsa())
	oBD6:LoadValue("BD6_PACOTE",oGuia:getPacote())
	oBD6:LoadValue("BD6_ORIMOV",oGuia:getOriMov())
	oBD6:LoadValue("BD6_GUIACO",oGuia:getGuiAco())
	oBD6:LoadValue("BD6_LIBERA",oGuia:getLibera())
	oBD6:LoadValue("BD6_RGIMP",oGuia:getRgImp())
	oBD6:LoadValue("BD6_TPGRV",oGuia:getTpGrv())
	oBD6:LoadValue("BD6_CID",oGuia:getCid())
	oBD6:LoadValue("BD6_TIPCON",left(oGuia:getTipCon(), TamSx3("BD6_TIPCON")[1])) 

	oBD6:LoadValue("BD6_NRLBOR",oGuia:getNrlBor())
	oBD6:LoadValue("BD6_NRAOPE",oGuia:getNraOpe())

return oBD6

/*/{Protheus.doc} grvGuia
Metodo para gravar a consulta
@author Karine Riquena Limp
@since 06/06/2016
@version P12
/*/
method grvGuia(oGuia, nOperation, cTipGui, lOdonto) class CO_Guia
local oModel	:= nil 
local oBD5 		:= nil
local oBD6 		:= nil 
local oBE4 		:= nil 
local nFor 		:= 0
local aObjProcedimentos 
Local lBe4Ok	:= .F.
Local lGrvRmbBD5 := GetNewPar("MV_GRMBBD5", .F.)

default lOdonto := .F.

aObjProcedimentos := oGuia:getProcedimentos()

if cTipGui <> "05"
	
	oModel := FWLoadModel("PLBD5MODEL")
    oBD5   := oModel:GetModel("BD5Cab")
    oBD6   := oModel:GetModel("BD6Proc")
    
else
	
	oModel := FWLoadModel("PLBE4MODEL")
	oBE4   := oModel:GetModel("BE4Cab")
    oBD6   := oModel:GetModel("BD6Proc")
    
endif
	
oModel:setOperation(nOperation)

oModel:activate()

if cTipGui <> "05"
	oBD5 := self:loadCabBD5(oBD5, oGuia, lOdonto)	
else
	oBE4 := self:loadCabBE4(oBE4, oGuia)
	lOdonto := .F.
endif
		
oBD6 := self:loadIteMod(oBD6, aObjProcedimentos, oGuia, lOdonto)

if oModel:VldData()

	begin Transaction
	
		oModel:CommitData()
		
		BD6->(dbSetOrder(1))
		
		if cTipGui <> "05"
		
			for nFor := 1 to len(aObjProcedimentos)
	
				oBD6:GoLine(nFor)
				// preciso posicionar na BD6 pois a função abaixo utiliza ela posicionada e desta 
				// forma que fizemos utilizando o model, a BD6 posicionada é sempre a ultima que foi gravada
				// portanto gravava apenas a composição do ultimo procedimento
				if BD6->(msSeek(xFilial("BD6")+BD5->(BD5_CODOPE+BD5_CODLDP+BD5_CODPEG+BD5_NUMERO+BD5_ORIMOV)+oBD6:GetValue("BD6_SEQUEN")+oBD6:GetValue("BD6_CODPAD")+oBD6:GetValue("BD6_CODPRO")))
			
						PLS720IBD7({},oBD6:GetValue("BD6_VLPGMA"),oBD6:GetValue("BD6_CODPAD"),oBD6:GetValue("BD6_CODPRO"),oBD6:GetValue("BD6_CODTAB"),;
			  											   oBD6:GetValue("BD6_CODOPE"),oBD6:GetValue("BD6_CODRDA"),oBD6:GetValue("BD6_REGEXE"),oBD6:GetValue("BD6_SIGEXE"),;
														   oBD6:GetValue("BD6_ESTEXE"),oBD6:GetValue("BD6_CDPFRE"),oBD6:GetValue("BD6_CODESP"),;
														   oBD6:GetValue("BD6_CODLOC")+oBD6:GetValue("BD6_LOCAL"),"1", oBD6:GetValue("BD6_SEQUEN"),;
	                     								   '5' /*Para internação e Honorario 2*/,cTipGui,oBD6:GetValue("BD6_DATPRO"),,,,,,,,,aObjProcedimentos[nFor]:getPart(),,IIF(cTipGui == "06",.T.,.F.)/*lHonor*/)
	                     								   
	           	If lGrvRmbBD5 .AND. cTipGui == "04" .AND. BD6->BD6_FASE == "1" //Só entra aqui na gravação do BD5 do reembolso na inclusão do protocolo
	           		//jovem... este if serve pra separar o valor apresentado no protocolo de reembolso nos BD7. sempre divide igual.
	           		//quando ele grava a autorização lá na frente, vai sobreescrever, mas é importante fazer isso aqui pra operadora
	           		//poder contabilizar a provisão no momento do conhecimento
	           		PLDISTBD7R()
	           	EndIf
			   	endIf
			next nFor
		else

			For nFor := 1 To Len(aObjProcedimentos)		
				//Posiciona no registro correto no model da BD6
				oBD6:GoLine(IIF(aObjProcedimentos[nFor]:getSeqModel() > 0, aObjProcedimentos[nFor]:getSeqModel(), nFor))
				
				oBE4:LoadValue("BE4_CODOPE",oGuia:getCodOpe())
				oBE4:LoadValue("BE4_CODLDP",oGuia:getCodLdp())
				oBE4:LoadValue("BE4_CODPEG",oGuia:getCodPeg())
				oBE4:LoadValue("BE4_NUMERO",left(oGuia:getNumero(), TamSx3("BE4_NUMERO")[1]))	
				
				cChaveBE4 := oGuia:getCodOpe() + oGuia:getCodLdp() + oGuia:getCodPeg() + left(oGuia:getNumero(), TamSx3("BE4_NUMERO")[1])
				
				BE4->(DbSetOrder(1))
				If BE4->(MsSeek(xfilial("BE4") + cChaveBE4))
					lBe4Ok := .T.
				EndIf
				// preciso posicionar na BD6 pois a função abaixo utiliza ela posicionada e desta 
				// forma que fizemos utilizando o model, a BD6 posicionada é sempre a ultima que foi gravada
				// portanto gravava apenas a composição do ultimo procedimento
				if lBe4Ok .AND. BD6->(msSeek(xFilial("BD6")+BE4->(BE4_CODOPE+BE4_CODLDP+BE4_CODPEG+BE4_NUMERO+"5")+oBD6:GetValue("BD6_SEQUEN")+oBD6:GetValue("BD6_CODPAD")+oBD6:GetValue("BD6_CODPRO")))
						PLS720IBD7({},oBD6:GetValue("BD6_VLPGMA"),oBD6:GetValue("BD6_CODPAD"),oBD6:GetValue("BD6_CODPRO"),oBD6:GetValue("BD6_CODTAB"),;
				  									       oBD6:GetValue("BD6_CODOPE"),oBD6:GetValue("BD6_CODRDA"),oBD6:GetValue("BD6_REGEXE"),oBD6:GetValue("BD6_SIGEXE"),;
													       oBD6:GetValue("BD6_ESTEXE"),oBD6:GetValue("BD6_CDPFRE"),oBD6:GetValue("BD6_CODESP"),;
													       oBD6:GetValue("BD6_CODLOC")+oBD6:GetValue("BD6_LOCAL"),"1", oBD6:GetValue("BD6_SEQUEN"),;
		                     						   BD6->BD6_ORIMOV /*Para internação e Honorario 2*/,oBD6:GetValue("BD6_TIPGUI"),oBD6:GetValue("BD6_DATPRO"),,,,,,,,,aObjProcedimentos[nFor]:getPart(),,IIF(oBD6:GetValue("BD6_TIPGUI") == "06",.T.,.F.)/*lHonor*/)
		   		endif       	       
		    next nFor	
		EndIf	   	
		
	end Transaction
   
else		
	varInfo("",oModel:GetErrorMessage())
endIf

oModel:DeActivate()

return 

//-------------------------------------------------------------------
/*/{Protheus.doc} loadGuiaRecno
Metodo para preencher uma classe a partir do recno 
@author Karine Riquena Limp
@since 06/06/2016
@version P12
/*/
//-------------------------------------------------------------------
method loadGuiaRecno(nRecno,lOdonto, lProc) class CO_Guia

local cCodOpe := ""
local cTipGui := ""
local objGuia	
local cCodRda := ""
local cCodPExe := ""
local cCodPSol := ""
local dDatPro := ""
local cCodLoc := ""
local cCodEsp := ""
local cCnes := ""
local cEspExe := ""                        
local cEspSol := ""                         
local cMatric := ""
local cNomUsr := ""
local cPadCon := ""
local cAteRn := ""
local oBoHon := NIL
local aRdaInt := {}
local cChvProtoc := ""
local oBO_GuiOdo := BO_Odonto():New()
local aLibOdon	:= {}
local cIndCli   := ""
local cObsGui   := ""
local cIndCli2 := ""
default lOdonto := .F.
default lProc := .T.

BD5->(dbGoto(nRecno))
cTipGui := BD5->BD5_TIPGUI

	DO CASE
		CASE cTipGui == G_CONSULTA
			objGuia := VO_Consulta():New()
		CASE cTipGui == G_SADT_ODON .and. !lOdonto
			objGuia := VO_SADT():New()
		CASE cTipGui == G_HONORARIO
			objGuia := VO_Honorario():New()
		CASE cTipGui == G_REEMBOLSO
			objGuia := VO_Reembolso():New()
		CASE lOdonto
			objGuia := VO_Odonto():New()
		CASE cTipGui == G_RES_INTER
			objGuia := VO_ResumoInter():New()	
			return	
	ENDCASE
   
   	cCodOpe  := BD5->BD5_CODOPE
	cCodRda  := BD5->BD5_CODRDA
	cCodPExe := BD5->BD5_CDPFRE
	cCodPSol := BD5->BD5_CDPFSO
	dDatPro  := BD5->BD5_DATPRO
	cCodLoc  := BD5->BD5_CODLOC
	cCodEsp  := BD5->BD5_CODESP
	cCnes    := BD5->BD5_CNES
	cEspExe  := BD5->BD5_ESPEXE                   
	cEspSol  := BD5->BD5_ESPSOL   
	cMatric  := BD5->(BD5_OPEUSR+BD5_CODEMP+BD5_MATRIC+BD5_TIPREG+BD5_DIGITO)
	cNomUsr  := BD5->BD5_NOMUSR
	cPadCon  := BD5->BD5_PADCON
	cAteRn   := BD5->BD5_ATERNA
	cTipAto  := BD5->BD5_TIPATO
	cChvProtoc := xFilial("BEA")+BD5->(BD5_OPEMOV+BD5_ANOAUT+BD5_MESAUT+BD5_NUMAUT+DTOS(BD5_DATPRO)+BD5_HORPRO)
   	
   	objGuia:setRegAns(  Posicione("BA0",1,xFilial("BA0")+cCodOpe,"BA0_SUSEP") )
   	objGuia:setCodOpe( cCodOpe )                       
  	objGuia:setCodLdp( BD5->BD5_CODLDP )
	objGuia:setCodPeg( BD5->BD5_CODPEG )
	objGuia:setNumero( BD5->BD5_NUMERO )
	
	
	objGuia:setFase  ( BD5->BD5_FASE ) 
	objGuia:setSituac( BD5->BD5_SITUAC )  
	objGuia:setDatPro( BD5->BD5_DATPRO )	
	objGuia:setHorPro( BD5->BD5_HORPRO )
	objGuia:setNumImp( BD5->BD5_NUMIMP )
		
	objGuia:setLotGui( BD5->BD5_LOTGUI )
	objGuia:setTipGui( BD5->BD5_TIPGUI )
	objGuia:setDtDigi( BD5->BD5_DTDIGI )
	objGuia:setMesPag( BD5->BD5_MESPAG ) 
	objGuia:setAnoPag( BD5->BD5_ANOPAG ) 
	
	objGuia:setNumAut( BD5->BD5_NUMAUT )
	
	objGuia:setPacote( BD5->BD5_PACOTE )
	objGuia:setOriMov( BD5->BD5_ORIMOV )
	objGuia:setGuiAco( BD5->BD5_GUIACO )
	objGuia:setLibera( BD5->BD5_LIBERA )
	objGuia:setRgImp ( BD5->BD5_RGIMP )
	objGuia:setTpGrv ( BD5->BD5_TPGRV )
	objGuia:setTipCon( BD5->BD5_TIPCON )
	objGuia:setTipAte( BD5->BD5_TIPATE )
	objGuia:setCid   ( BD5->BD5_CID )
	objGuia:setTipFat( BD5->BD5_TIPFAT )
	objGuia:setQtdEve( BD5->BD5_QTDEVE )
	objGuia:setIndAci( BD5->BD5_INDACI )
	objGuia:setTipSai( BD5->BD5_TIPSAI )	
	objGuia:setTipAdm( BD5->BD5_TIPADM )  
		  
	objGuia:setUtpDoe( BD5->BD5_UTPDOE )
	objGuia:setTpOdoe( BD5->BD5_TPODOE )
	objGuia:setTipDoe( BD5->BD5_TIPDOE )
	
	objGuia:setNrlBor( BD5->BD5_NRLBOR )
	
	if cTipGui $ G_CONSULTA + '|' + G_SADT_ODON
		objGuia:setGuiOri( BD5->BD5_GUIORI )
		if lTiss4New
			objGuia:setCobEsp( BD5->BD5_COBESP ) 
			objGuia:setTmRega( BD5->BD5_TMREGA )
			objGuia:setSauOcu( BD5->BD5_SAUOCU )
		endif	
	endIf	

	if (lOdonto .and. !empty(BD5->BD5_NRLBOR))
		aLibOdon := oBO_GuiOdo:getDadLib(BD5->BD5_NRLBOR)
		objGuia:setDatAutO(aLibOdon[1,1])
		objGuia:setVldSenO(aLibOdon[1,2])
		objGuia:setProcLib(aLibOdon[2,1])		
	endif 

	objGuia:setNraOpe( BD5->BD5_NRAOPE ) 
	objGuia:setSenha ( BD5->BD5_SENHA ) 
	objGuia:setTipAto( BD5->BD5_TIPATO )
	
	cObsGui := AllTrim(BD5->BD5_OBSGUI)
	cObsGui := FwCutOff(cObsGui, .T.)
	objGuia:setObs( cObsGui )
	
	objGuia:setDadBenef(self:addBenef(cCodOpe, cMatric, cNomUsr, cPadCon, cAteRn))
	objGuia:setContExec(self:addCont(cCodOpe, cCodRda, dDatPro, cCodLoc, cCodEsp, cCnes))
	objGuia:setProfExec(self:addProf(cCodOpe, cCodPExe, cEspExe))
	objGuia:setProfSol (self:addProf(cCodOpe, cCodPSol, cEspSol))
	
	if(cTipGui == G_SADT_ODON .and. !lOdonto)
		cIndCli := AllTrim(BD5->BD5_INDCLI)
		cIndCli := FwCutOff(cIndCli, .T.)
		
		if(!empty(AllTrim(BD5->BD5_INDCL2)))
			cIndCli2 := AllTrim(BD5->BD5_INDCL2)
			cIndCli2 := FwCutOff(cIndCli2, .T.)
		else
			cIndCli2 := ""
		endif

		objGuia:setIndCli( cIndCli + cIndCli2)
		objGuia:setDatSol( BD5->BD5_DATSOL )
		objGuia:setdDtRlS ( BD5->BD5_DTRLZ )
		objGuia:setdDtRlS2( BD5->BD5_DTRLZ2 )
		objGuia:setdDtRlS3( BD5->BD5_DTRLZ3 )
		objGuia:setdDtRlS4( BD5->BD5_DTRLZ4 )
		objGuia:setdDtRlS5( BD5->BD5_DTRLZ5 )
		objGuia:setdDtRlS6( BD5->BD5_DTRLZ6 )
		objGuia:setdDtRlS7( BD5->BD5_DTRLZ7 )
		objGuia:setdDtRlS8( BD5->BD5_DTRLZ8 )
		objGuia:setdDtRlS9( BD5->BD5_DTRLZ9 )
		objGuia:setdDtRlS1( BD5->BD5_DTRLZ1 )
		
	endif
	
	if (cTipGui == G_HONORARIO .or. cTipGui == G_RES_INTER)
		objGuia:setNumAux(STR(PlsVrIntPro(BD5->BD5_GUIPRI)))
	endif
	
	//Honorarios
	if cTipGui == G_HONORARIO
	
		objGuia:setGuiPri( BD5->BD5_GUIPRI )
		objGuia:setDtIniFat(BD5->BD5_DTFTIN)
		objGuia:setDtFimFat(BD5->BD5_DTFTFN)
		objGuia:setDtEmiGui(BD5->BD5_DATPRO)
		objGuia:setRegFor(BD5->BD5_REGFOR)
		
		oBoHon := BO_Honorario():New()
		
		if !empty(BD5->BD5_GUIPRI)
			aRdaInt := oBoHon:getRdaInt(BD5->BD5_GUIPRI)
		else
			aRdaInt := oBoHon:getRdaInt(BD5->BD5_NRLBOR)
		endIf
		
		if(Len(aRdaInt) = 3)
			objGuia:setCnpjRdaInt(aRdaInt[1])
			objGuia:setNomeRdaInt(aRdaInt[2])
			objGuia:setCnesRdaInt(aRdaInt[3])
		endif
		
	endif
	
	if lProc
		objGuia:setProcedimentos(self:getProcChv(BD5->(BD5_CODOPE+BD5_CODLDP+BD5_CODPEG+BD5_NUMERO+BD5_ORIMOV), lOdonto, .F., cTipGui == "02" .and. !lOdonto, cTipGui == G_RES_INTER, objGuia))
	endif
	
	if(cTipGui == G_REEMBOLSO)
		objGuia:setProtoc(self:getProtoc(cChvProtoc))
	endIf	
	
return objGuia

//-------------------------------------------------------------------
/*/{Protheus.doc} getProcChv
Metodo para preencher os procedimentos da guia pela chave da BD5
@author Karine Riquena Limp
@since 17/06/2016
@version P12
/*/
//-------------------------------------------------------------------
method getProcChv( cChaveBD5, lOdonto, lOutrasDesp, lSadt, lResumo, objTmp ) class CO_Guia
local aObjProc := {}
local oProc 
local cChaveBX6 := ""
local objBoSadt := BO_Sadt():New()
local aTipoProc	:= {{"1",0}, {"2",0}, {"3",0}, {"4",0}, {"5",0}, {"7",0}, {"8",0}} //0=Procedimento;1=Material;2=Medicamento;3=Taxas;4=Diarias;5=Ortese/Protese;6=Pacote;7=Gases Medicinais;8=Alugueis;9=Outros
local cTipoProc	:= ""
local cTemp		:= ""
local nposic	:= 0
local ni		:= 0
local lSomaOutDesp := getNewPar("MV_PLSOUTD",.F.) //Parâmetro para mostrar os totais de Outras Despesas na guia de SADT.
default lOdonto := .F.
default lOutrasDesp := .F.
default lSadt		   := .F.
default lResumo     := .F.
default objTmp	:= nil

	BD6->(DbSetorder(1))
	If BD6->(msSeek(xFilial("BD6")+cChaveBD5))

		while BD6->(!EOF()) .AND. BD6->(BD6_CODOPE+BD6_CODLDP+BD6_CODPEG+BD6_NUMERO+BD6_ORIMOV) == cChaveBD5
    
			if lOdonto
					oProc := VO_ProcOdonto():New()
					oProc:setDenReg(BD6->BD6_DENREG)
					oProc:setDesReg(BD6->BD6_DESREG)
					oProc:setFaDent(BD6->BD6_FADENT)
					oProc:setFacDes(BD6->BD6_FACDES)
			else
					oProc := VO_Procedimento():New()
			endif
			
			oProc:setSeqMov(BD6->BD6_SEQUEN)
			oProc:setCodPad(BD6->BD6_CODPAD)
		
			oProc:setSlvPad(BD6->BD6_SLVPAD)
			oProc:setCodPro(BD6->BD6_CODPRO)
			oProc:setSlvPro(BD6->BD6_SLVPRO)
			oProc:setDesPro(BD6->BD6_DESPRO)
			oProc:setNivel(BD6->BD6_NIVEL)
			oProc:setVlrApr(BD6->BD6_VLRAPR)
			oProc:setVlrMan(BD6->BD6_VLRMAN)
			
			oProc:setQtd(BD6->BD6_QTDPRO)
			
			oProc:setPerVia(BD6->BD6_PERVIA)
			oProc:setCodVia(BD6->BD6_VIA)
			oProc:setProcCirurgico(BD6->BD6_PROCCI)
			oProc:setDtPro(BD6->BD6_DATPRO)
			oProc:setHorIni(BD6->BD6_HORPRO)
			oProc:setHorFim(BD6->BD6_HORFIM)
			
			oProc:setIncAut(BD6->BD6_INCAUT)
			oProc:setStatus(BD6->BD6_STATUS)
			oProc:setChvNiv(BD6->BD6_CHVNIV)
			oProc:setNivAut(BD6->BD6_NIVAUT)
			oProc:setCodTab(BD6->BD6_CODTAB)
			oProc:setAliaTb(BD6->BD6_ALIATB)
			oProc:setBloqPag(BD6->BD6_BLOPAG)
			oProc:setInterc(BD6->BD6_INTERC)
			oProc:setTipInt(BD6->BD6_TIPINT)
			oProc:setTecUti(BD6->BD6_TECUTI)
			oProc:setPrPrRl(BD6->BD6_PRPRRL)
			oProc:setRefMatFab(BD6->BD6_REFFED)
			if lSadt .or. lResumo
				cTipoProc := objBoSadt:getTipProc(BD6->BD6_CODPAD+BD6->BD6_CODPRO)
				oProc:setTpProc(cTipoProc)
			endif
			
			if lSadt .or. lOutrasDesp .or. lResumo
				cChaveBX6 := BD6->(BD6_CODOPE+BD6_CODLDP+BD6_CODPEG+BD6_NUMERO+BD6_ORIMOV+BD6_SEQUEN+BD6_CODPAD+BD6_CODPRO)	                    
				BX6->(DbSetOrder(1))
				if ( BX6->(msSeek(xFilial("BX6")+cChaveBX6)))
					if(BX6->BX6_AODESP /*.and. lOutrasDesp*/)
						oProc:setAoDesp(BX6->BX6_AODESP)
						oProc:setCodDes(BX6->BX6_CODDES)
						oProc:setRegAnvisa(BX6->BX6_REGANV)
						oProc:setUniMedida(BX6->BX6_CODUNM)
						oProc:setAutFun(BX6->BX6_AUTFUN)
						//-- 
						If lSomaOutDesp 
							nposic := aScan( aTipoProc, { |x| alltrim(x[1]) == Alltrim(PADR(cTipoProc, AT("*",cTipoProc) - 1)) } ) 
							if ( nposic > 0 )
								aTipoProc[nposic,2] += (BD6->BD6_VLRAPR * BD6->BD6_QTDPRO)
							endif
						Endif
						iif (lOutrasDesp, aAdd(aObjProc, oProc), "")
						//--
					elseif(!BX6->BX6_AODESP .and. (lSadt .or. lResumo))
						aAdd(aObjProc, oProc)
					else
						BD6->(dbSkip())
						Loop	
					endif
				elseif lSadt .or. lResumo
					aAdd(aObjProc, oProc)
				endIf
			else
				aAdd(aObjProc, oProc)	
			endIf						
				
			
			BD6->(dbSkip())

		endDo
		
	Endif
	//--
	if (lSomaOutDesp .and. (lSadt .or. lResumo) .and. objTmp != nil .and. !empty(aTipoProc))
		for ni := 1 to len(aTipoProc)
			cTemp += aTipoProc[ni,1] + "*" + alltrim(TransForm(aTipoProc[ni,2], "@U 999,999,999.99")) + ";"
		next
		cTemp := Substr(cTemp,1, (len(cTemp) - 1))
		objTmp:setVlOutS(cTemp)
	endif
	//--
return aObjProc

//-------------------------------------------------------------------
/*/{Protheus.doc} altGuia
Metodo para Alterar as guias
@author Roberto Vanderlei
@since 21/06/2016
@version P12

/*/
//-------------------------------------------------------------------
method altGuia(aCamposCabec, aCampoItem, cRecnoBD5) class CO_Guia
	local oModel := FWLoadModel("PLBD5MODEL")
	local oBD5 := oModel:GetModel("BD5Cab")
	local oBD6 := oModel:GetModel("BD6Proc")
	local nFor
	local lRet := .T.
	
	
	if(val(cRecnoBD5) != BD5->(recno()))
		BD5->(DbGoTo(val(cRecnoBD5)))
	endif
	
	oModel:SetOperation(4)
	
	oModel:Activate()
	
	for nFor := 1 to len(aCamposCabec)
		oBD5:LoadValue(aCamposCabec[nFor][1],aCamposCabec[nFor][2])
	next 
	
	for nFor := 1 to len(aCampoItem)
		oBD6:LoadValue(aCampoItem[nFor][1],aCampoItem[nFor][2])
	next 
	
	IF oModel:VldData()	
		oModel:CommitData()
	Else		
		VarInfo("",oModel:GetErrorMessage())	
		lRet := .F.
	endif
	
	oModel:DeActivate()

return {lRet, alltrim(BD5->BD5_CODOPE) + alltrim(BD5->BD5_ANOAUT) + alltrim(BD5->BD5_MESAUT) + alltrim(BD5->BD5_NUMAUT)}

//-------------------------------------------------------------------
/*/{Protheus.doc} loadOutrasDesp
Metodo para preencher uma classe de outras despesas a partir do recno da guia referenciada
@author Karine Riquena Limp
@since 30/06/2016
@version P12
/*/
//-------------------------------------------------------------------
method loadOutrasDesp(nRecGuiRef, cNumGuiRef, cTipGui) class CO_Guia

local cCodOpe := ""
local objGuia := VO_OutrasDesp():New()
local cCodRda := ""
local dDatPro := ""
local cCodLoc := ""
local cCodEsp := ""
local cCnes := ""                                             
local cAteRn := ""
local cCid := ""
If cTipGui <> "5"

	BD5->(dbGoto(nRecGuiRef))
	cTipGui := BD5->BD5_TIPGUI
  

   	cCodOpe  := BD5->BD5_CODOPE
	cCodRda  := BD5->BD5_CODRDA
	dDatPro  := BD5->BD5_DATPRO
	cCodLoc  := BD5->BD5_CODLOC
	cCodEsp  := BD5->BD5_CODESP
	cCnes    := BD5->BD5_CNES
	
	//ESSES CAMPOS SÃO NECESSÁRIOS PARA VALIDAÇÃO DO PROCEDIMENTO
	cAteRn   := BD5->BD5_ATERNA
	cCid     := BD5->BD5_CID
   	
   	objGuia:setRegAns   (  Posicione("BA0",1,xFilial("BA0")+cCodOpe,"BA0_SUSEP") )
   	objGuia:setNumGuiRef(  cNumGuiRef )
   	objGuia:setAteRn( cAteRn )
   	objGuia:setCid( cCid )
	objGuia:setContExec (self:addCont(cCodOpe, cCodRda, dDatPro, cCodLoc, cCodEsp, cCnes))	
	objGuia:setCodOpe(cCodOpe)
	
	objGuia:setProcedimentos(self:getProcChv(BD5->(BD5_CODOPE+BD5_CODLDP+BD5_CODPEG+BD5_NUMERO+BD5_ORIMOV), .F., .T.))
ElseIf cTipGui == "5"
	BE4->(dbGoto(nRecGuiRef))
	cTipGui	:= BE4->BE4_TIPGUI
   	cCodOpe	:= BE4->BE4_CODOPE
	cCodRda	:= BE4->BE4_CODRDA
	dDatPro	:= BE4->BE4_DATPRO
	cCodLoc	:= BE4->BE4_CODLOC
	cCodEsp	:= BE4->BE4_CODESP
	cCnes	:= BE4->BE4_CNES

	//ESSES CAMPOS SÃO NECESSÁRIOS PARA VALIDAÇÃO DO PROCEDIMENTO
	cAteRn   := BE4->BE4_ATERNA
	cCid     := BE4->BE4_CID
   	
   	objGuia:setRegAns   (  Posicione("BA0",1,xFilial("BA0")+cCodOpe,"BA0_SUSEP") )
   	objGuia:setNumGuiRef(  cNumGuiRef )
   	objGuia:setAteRn( cAteRn )
   	objGuia:setCid( cCid )
	objGuia:setContExec (self:addCont(cCodOpe, cCodRda, dDatPro, cCodLoc, cCodEsp, cCnes))	
	objGuia:setCodOpe(cCodOpe)
	
	objGuia:setDtIniFat(BE4->BE4_DTINIF)
	objGuia:setDtFimFat(BE4->BE4_DTFIMF)
	
	objGuia:setProcedimentos(self:getProcChv(BE4->(BE4_CODOPE+BE4_CODLDP+BE4_CODPEG+BE4_NUMERO+BE4_ORIMOV), .F., .T.))
EndIf
return objGuia

//-------------------------------------------------------------------
/*/{Protheus.doc} excIteGuia
Metodo para gravar a consulta
@author Roberto Vanderlei
@since 06/06/2016
@version P12
/*/
//-------------------------------------------------------------------
method excIteGuia(cCodTab, cCodProPar, cRecnoBD5) class CO_Guia

	local cCodPad
	local cCodPro
	local lRet := .T.
	
	
	if(val(cRecnoBD5) != BD5->(recno()))
		BD5->(DbGoTo(val(cRecnoBD5)))
	endif
	
	cCodPad := AllTrim(cCodTab)+Space(TamSX3("BD6_CODPAD")[1]-Len(AllTrim(cCodTab))) 
	cCodPro := AllTrim(cCodProPar)+Space(TamSX3("BD6_CODPRO")[1]-Len(AllTrim(cCodProPar))) 
	
	//Posiciona na BD6
	
	BD6->(DbSetorder(6))
	If BD6->(msSeek(xFilial("BD6")+BD5->(BD5_CODOPE+BD5_CODLDP+BD5_CODPEG+BD5_NUMERO+BD5_ORIMOV)+cCodPad+cCodPro))
		If BD7->(MsSeek(xFilial("BD7")+BD6->(BD6_CODOPE+BD6_CODLDP+BD6_CODPEG+BD6_NUMERO+BD6_ORIMOV+BD6_SEQUEN)))
			While ! BD7->(Eof()) .And. BD7->(BD7_FILIAL+BD7_CODOPE+BD7_CODLDP+BD7_CODPEG+BD7_NUMERO+BD7_ORIMOV+BD7_SEQUEN) == ;
									xFilial("BD6")+BD6->(BD6_CODOPE+BD6_CODLDP+BD6_CODPEG+BD6_NUMERO+BD6_ORIMOV+BD6_SEQUEN)      
				                                        
				BD7->(Reclock("BD7",.F.))
				BD7->(DbDelete())
				BD7->(MsUnlock())
				BD7->(DbSkip())
			End
			
		EndIf         
		RecLock( "BD6" , .F. )
		DBDelete() 
		BD6->(MsUnLock())
		 
	else
		lRet := .F.
	endif
	
return {lRet, alltrim(BD5->BD5_CODOPE) + alltrim(BD5->BD5_ANOAUT) + alltrim(BD5->BD5_MESAUT) + alltrim(BD5->BD5_NUMAUT)}

//-------------------------------------------------------------------
/*/{Protheus.doc} altItem
Metodo para Alterar as guias
@author Roberto Vanderlei
@since 21/06/2016
@version P12
/*/
//-------------------------------------------------------------------
method altItem(aCmpOrg, cRecnoBD5) class CO_Guia
	local oModel := FWLoadModel("PLBD5MODEL")
	local oBD6 := oModel:GetModel("BD6Proc")
	local nFor
	local cCodPad
	local cCodPro
	local lRet := .T.
	local nM := 1
	local cOriMov := ""
	
	if(val(cRecnoBD5) != BD5->(recno()))
		BD5->(DbGoTo(val(cRecnoBD5)))
	endif
	
	//Para pegar o local correto da origem, pois posso ter guias da Off-Line ou autorização.
	cOrimov := BD5->BD5_ORIMOV

	cCodPad := AllTrim(aCmpOrg[2][2])+Space(TamSX3("BD6_CODPAD")[1]-Len(AllTrim(aCmpOrg[2][2]))) 
	cCodPro := AllTrim(aCmpOrg[1][2])+Space(TamSX3("BD6_CODPRO")[1]-Len(AllTrim(aCmpOrg[1][2]))) 
	
	//Posiciona na BD6
	
	BD6->(DbSetorder(6))
	If BD6->(msSeek(xFilial("BD6")+BD5->(BD5_CODOPE+BD5_CODLDP+BD5_CODPEG+BD5_NUMERO+BD5_ORIMOV)+cCodPad+cCodPro))
		oModel:SetOperation(4)
	
		oModel:Activate()
	
		//Posiciona corretamente na model pois, caso não seja feito, a alteração será efetuada sempre no primeiro registro existente na model
		for nM := 1 to oBD6:Length()
			//Posiciona em cada linha do model
			oBD6:goLine(nM)
			
			//São verificados os códigos de tabela e procedimento da linha posicionada da model com os valores do item alterado.
			if alltrim(cCodPad) == alltrim(oBD6:getValue("BD6_CODPAD")) .and. alltrim(cCodPro) == alltrim(oBD6:getValue("BD6_CODPRO"))
				//Caso os valores sejam encontrados, os campos na model são alterados.
				for nFor := 3 to len(aCmpOrg)
					oBD6:LoadValue(aCmpOrg[nFor][1],aCmpOrg[nFor][2])
				next				
				//Encontrou a linha esperada, sai do laço for
				exit
			endif
		next nM 
	
		IF oModel:VldData()
			oModel:CommitData()
		Else		
			VarInfo("",oModel:GetErrorMessage())
			lRet := .F.	
		endif
				
		oModel:DeActivate()
		
		//Deleta os registros da BD7 vinculados ao procedimento
		//EXCEÇÃO!! Guais de reembolso quando a operadora utiliza o MV_GRMBBD5 como .T., pois os BD7 gerados já podem ter sido contabilizados e serão
		//somente sobrescritos qando for gerada a autorização, não pode deletar aqui
		If lRet .AND. !(BD5->BD5_TIPGUI == "04" .AND. GetNewPar("MV_GRMBBD5", .F.))
			If BD7->(MsSeek(xFilial("BD7")+BD6->(BD6_CODOPE+BD6_CODLDP+BD6_CODPEG+BD6_NUMERO+BD6_ORIMOV+BD6_SEQUEN)))
				While ! BD7->(Eof()) .And. BD7->(BD7_FILIAL+BD7_CODOPE+BD7_CODLDP+BD7_CODPEG+BD7_NUMERO+BD7_ORIMOV+BD7_SEQUEN) == ;
										xFilial("BD6")+BD6->(BD6_CODOPE+BD6_CODLDP+BD6_CODPEG+BD6_NUMERO+BD6_ORIMOV+BD6_SEQUEN)      
					                                        
					BD7->(Reclock("BD7",.F.))
					BD7->(DbDelete())
					BD7->(MsUnlock())
					BD7->(DbSkip())
				End
				PLS720IBD7("0",BD6->BD6_VLPGMA,BD6->BD6_CODPAD,BD6->BD6_CODPRO,BD6->BD6_CODTAB,BD6->BD6_CODOPE,BD6->BD6_CODRDA,BD6->BD6_REGEXE,BD6->BD6_SIGEXE,BD6->BD6_ESTEXE,;
						BD6->BD6_CDPFRE,BD6->BD6_CODESP,BD6->BD6_CODLOC+BD6->BD6_LOCAL,"1",BD6->BD6_SEQUEN,;
	                  	cOrimov ,BD5->BD5_TIPGUI,BD6->BD6_DATPRO,,,,,,,,,,,IiF(BD5->BD5_TIPGUI == "06",.T.,.F.)/*lHonor*/)
			EndIf  
		EndIf                 			
	EndIf
	
return {lRet, alltrim(BD5->BD5_CODOPE) + alltrim(BD5->BD5_ANOAUT) + alltrim(BD5->BD5_MESAUT) + alltrim(BD5->BD5_NUMAUT)}

//-------------------------------------------------------------------
/*/{Protheus.doc} incIteGuia
Metodo para incluir item na guia (procedimento)
@author Roberto Vanderlei
@since 06/06/2016
@version P12
/*/
//-------------------------------------------------------------------
method incIteGuia(oGuia, aObjProcedimentos, lOdonto) class CO_Guia
	local oModel
	local oBD5
	local oBD6
	local nFor
	local lRet := .T.
	Local cChaveBE4 := ""
	Local lBe4Ok := .F.
	
	default lOdonto := .F.
		
	
	if alltrim(oGuia:getCodOpe()) <> alltrim(BE4->BE4_CODOPE) .or. ;
	   alltrim(oGuia:getCodLdp()) <> alltrim(BE4->BE4_CODLDP) .or. ;
	   alltrim(oGuia:getCodPeg()) <> alltrim(BE4->BE4_CODPEG) .or. ;
	   alltrim(oGuia:getNumero()) <> alltrim(BE4->BE4_NUMERO)

		BE4->(dbSetOrder(1)) //BE4_FILIAL+BE4_CODOPE+BE4_CODLDP+BE4_CODPEG+BE4_NUMERO+BE4_SITUAC+BE4_FASE
		BE4->(msSeek(xFilial("BE4")+oGuia:getCodOpe()+oGuia:getCodLdp()+oGuia:getCodPeg() + left(oGuia:getNumero(), TamSx3("BE4_NUMERO")[1])))   
						
	endif
		
		
	if oGuia:getTipGui() <> "05"
		
		oModel := FWLoadModel("PLBD5MODEL")
	    oBD5   := oModel:GetModel("BD5Cab")
	    oBD6   := oModel:GetModel("BD6Proc")
	else
		oModel := FWLoadModel("PLBE4MODEL")
		oBE4   := oModel:GetModel("BE4Cab")
	    oBD6   := oModel:GetModel("BD6Proc")
	endif
	
	oModel:SetOperation(4)	
	oModel:Activate()
		
	if oGuia:getTipGui() <> "05"	
		oBD5:LoadValue("BD5_CODOPE",oGuia:getCodOpe())
		oBD5:LoadValue("BD5_CODLDP",oGuia:getCodLdp())
		oBD5:LoadValue("BD5_CODPEG",oGuia:getCodPeg())
		oBD5:LoadValue("BD5_NUMERO",left(oGuia:getNumero(), TamSx3("BD5_NUMERO")[1])) 
	else
		oBE4:LoadValue("BE4_CODOPE",oGuia:getCodOpe())
		oBE4:LoadValue("BE4_CODLDP",oGuia:getCodLdp())
		oBE4:LoadValue("BE4_CODPEG",oGuia:getCodPeg())
		oBE4:LoadValue("BE4_NUMERO",left(oGuia:getNumero(), TamSx3("BE4_NUMERO")[1]))	
		
		cChaveBE4 := oGuia:getCodOpe() + oGuia:getCodLdp() + oGuia:getCodPeg() + left(oGuia:getNumero(), TamSx3("BE4_NUMERO")[1])
		
	endif 
	
	oBD6 := self:loadIteMod(oBD6, aObjProcedimentos, oGuia, lOdonto)
                     						                        							
	IF oModel:VldData()	
		oModel:CommitData()		
		
		if oGuia:getTipGui() <> "05"		
			BD6->(dbSetOrder(1))
			For nFor := 1 To Len(aObjProcedimentos)		
				//Posiciona no registro correto no model da BD6
				oBD6:GoLine(IIF(aObjProcedimentos[nFor]:getSeqModel() > 0, aObjProcedimentos[nFor]:getSeqModel(), nFor))
				
				// preciso posicionar na BD6 pois a função abaixo utiliza ela posicionada e desta 
				// forma que fizemos utilizando o model, a BD6 posicionada é sempre a ultima que foi gravada
				// portanto gravava apenas a composição do ultimo procedimento
				if BD6->(msSeek(xFilial("BD6")+BD5->(BD5_CODOPE+BD5_CODLDP+BD5_CODPEG+BD5_NUMERO+BD5_ORIMOV)+oBD6:GetValue("BD6_SEQUEN")+oBD6:GetValue("BD6_CODPAD")+oBD6:GetValue("BD6_CODPRO")))
						PLS720IBD7({},oBD6:GetValue("BD6_VLPGMA"),oBD6:GetValue("BD6_CODPAD"),oBD6:GetValue("BD6_CODPRO"),oBD6:GetValue("BD6_CODTAB"),;
				  									       oBD6:GetValue("BD6_CODOPE"),oBD6:GetValue("BD6_CODRDA"),oBD6:GetValue("BD6_REGEXE"),oBD6:GetValue("BD6_SIGEXE"),;
													       oBD6:GetValue("BD6_ESTEXE"),oBD6:GetValue("BD6_CDPFRE"),oBD6:GetValue("BD6_CODESP"),;
													       oBD6:GetValue("BD6_CODLOC")+oBD6:GetValue("BD6_LOCAL"),"1", oBD6:GetValue("BD6_SEQUEN"),;
		                     						       BD6->BD6_ORIMOV /*Para internação e Honorario 2*/,oBD6:GetValue("BD6_TIPGUI"),oBD6:GetValue("BD6_DATPRO"),,,,,,,,,aObjProcedimentos[nFor]:getPart(),,IIF(oBD6:GetValue("BD6_TIPGUI") == "06",.T.,.F.)/*lHonor*/)
		   		endif       	       
		    next nFor	    
		else
			BD6->(dbSetOrder(1))
			For nFor := 1 To Len(aObjProcedimentos)		
				//Posiciona no registro correto no model da BD6
				oBD6:GoLine(IIF(aObjProcedimentos[nFor]:getSeqModel() > 0, aObjProcedimentos[nFor]:getSeqModel(), nFor))
				
				BE4->(DbSetOrder(1))
				If BE4->(MsSeek(xfilial("BE4") + cChaveBE4))
					lBe4Ok := .T.
				EndIf
				// preciso posicionar na BD6 pois a função abaixo utiliza ela posicionada e desta 
				// forma que fizemos utilizando o model, a BD6 posicionada é sempre a ultima que foi gravada
				// portanto gravava apenas a composição do ultimo procedimento
				if lBe4Ok .AND. BD6->(msSeek(xFilial("BD6")+BE4->(BE4_CODOPE+BE4_CODLDP+BE4_CODPEG+BE4_NUMERO+BE4_ORIMOV)+oBD6:GetValue("BD6_SEQUEN")+oBD6:GetValue("BD6_CODPAD")+oBD6:GetValue("BD6_CODPRO")))
						PLS720IBD7({},oBD6:GetValue("BD6_VLPGMA"),oBD6:GetValue("BD6_CODPAD"),oBD6:GetValue("BD6_CODPRO"),oBD6:GetValue("BD6_CODTAB"),;
				  									       oBD6:GetValue("BD6_CODOPE"),oBD6:GetValue("BD6_CODRDA"),oBD6:GetValue("BD6_REGEXE"),oBD6:GetValue("BD6_SIGEXE"),;
													       oBD6:GetValue("BD6_ESTEXE"),oBD6:GetValue("BD6_CDPFRE"),oBD6:GetValue("BD6_CODESP"),;
													       oBD6:GetValue("BD6_CODLOC")+oBD6:GetValue("BD6_LOCAL"),"1", oBD6:GetValue("BD6_SEQUEN"),;
		                     						       BD6->BD6_ORIMOV /*Para internação e Honorario 2*/,oBD6:GetValue("BD6_TIPGUI"),oBD6:GetValue("BD6_DATPRO"),,,,,,,,,aObjProcedimentos[nFor]:getPart(),,IIF(oBD6:GetValue("BD6_TIPGUI") == "06",.T.,.F.)/*lHonor*/)
		   		endif       	       
		    next nFor				
		endif
			    
	Else		
		VarInfo("",oModel:GetErrorMessage())
		lRet := .F.	
	endif
		
	oModel:DeActivate()
	
return {lRet, oGuia:getCodOpe() + oGuia:getAnoPag() + oGuia:getMesPag() + oGuia:getNumAut()}   

//-------------------------------------------------------------------
/*/{Protheus.doc} CO_Guia
Método para gravar outras despesas
@author Karine Riquena Limp
@since 07/07/2016
@version P12
/*/
//-------------------------------------------------------------------
method grvOutDes(nRecGuiRef, aAddItem, aEditItem, aDelItem, cTipGui) class CO_Guia
local lRet := .T.
local oModel := Iif(cTipGui <> "5",FWLoadModel("PLBD5MODEL"),FWLoadModel("PLBE4MODEL"))
local oBD6 := oModel:GetModel("BD6Proc")
local oObjBoGuia := BO_Guia():New()
local nI := 1
local nJ := 1
local nW := 1
local nX := 1
local nPosCodPad := 0
local nPosCodPro := 0
local nPosSeqMov := 0
local nPosCodDes := 0
local nPosCodUnm := 0
local nPosRegAnv := 0
local nPosAutFun := 0
local aBX6 := {}
local aAuxBX6 := {}
local aAuxBD7 := {}
local aKeyDel := {}
local aDadTab := {}
local cSql		:= ""
local cSeq		:= ""
Local lRetMudFase	:= .F.
Local aEditBX6 := {}
Local aObEditBX6 := {}
Local aCriticas := {}
Local cOriMov		:= ""
Local nRedAcre	:= 0
Local nVlrApr	:= 0
Local nVlrTotal	:= 0

If cTipGui <> "5" //diferente de resumo de internação
	BD5->(DbGoTo(nRecGuiRef))
	BA1->(DbSetOrder(2))//BA1_FILIAL+BA1_CODINT+BA1_CODEMP+BA1_MATRIC+BA1_TIPREG+BA1_DIGITO                                                                                                                                                                                   
	BA1->(DbSeek(xFilial("BD5")+BD5->(BD5_CODOPE+BD5_CODEMP+BD5_MATRIC+BD5_TIPREG+BD5_DIGITO)))
	BA3->(DbSetOrder(1))//BA3_FILIAL+BA3_CODINT+BA3_CODEMP+BA3_MATRIC+BA3_CONEMP+BA3_VERCON+BA3_SUBCON+BA3_VERSUB                                                                         
	BA3->(DbSeek(xFilial("BA3")+BD5->BD5_CODOPE+BD5->BD5_CODEMP+BD5->BD5_MATRIC+BA1->BA1_CONEMP+BA1->BA1_VERCON+BA1->BA1_SUBCON+BA1->BA1_VERSUB))
	//Se diferente de status Digitação de Guias, muda a fase
	If BD5->BD5_FASE <> "1"
		lRetMudFase := PLSBACKGUI(Str(nRecGuiRef), Val(BD5->BD5_TIPGUI))
	EndIf
	
	//Para garantir pegar o local de origem correto conforme a guia
	cOrimov := BD5->BD5_ORIMOV

	oModel:SetOperation(4)
	oModel:Activate()
	
	//Faço primeiro a edição e deleção dos itens para percorrer uma model de bd6 menor
	
	for nI := 1 to len(aDelItem)
	    //pego a chave do procedimento
		nPosCodPad := aScan( aDelItem[nI], { |x| x[1] == "BD6_CODPAD" } )
		nPosCodPro := aScan( aDelItem[nI], { |x| x[1] == "BD6_CODPRO" } )
		nPosSeqMov := aScan( aDelItem[nI], { |x| x[1] == "BD6_SEQUEN" } ) 
		if(nPosCodPad > 0 .and. nPosCodPro > 0 .and. nPosSeqMov > 0)	
		
			for nJ := 1 to oBD6:Length()
					
				oBD6:GoLine( nJ ) 
				
				if 	alltrim(oBD6:GetValue("BD6_CODPAD")) == alltrim(aDelItem[nI][nPosCodPad][2]) .AND. ;
					alltrim(oBD6:GetValue("BD6_CODPRO")) == alltrim(aDelItem[nI][nPosCodPro][2]) .AND. ;
					alltrim(oBD6:GetValue("BD6_SEQUEN")) == alltrim(aDelItem[nI][nPosSeqMov][2]) 
					
						oBD6:DeleteLine()
						aAdd(aKeyDel, BD5->(BD5_CODOPE+BD5_CODLDP+BD5_CODPEG+BD5_NUMERO+BD5_ORIMOV)+;
										aDelItem[nI][nPosSeqMov][2])
				
				endIf
				
			next nJ
		
		endIf
	
	next nI
	
	for nI := 1 to len(aEditItem)
	    //pego a chave do procedimento, que é sempre a primeira posição do item editado
		nPosCodPad := aScan( aEditItem[nI][1], { |x| x[1] == "BD6_CODPAD" } )
		nPosCodPro := aScan( aEditItem[nI][1], { |x| x[1] == "BD6_CODPRO" } )
		nPosSeqMov := aScan( aEditItem[nI][1], { |x| x[1] == "BD6_SEQUEN" } ) 
		if(nPosCodPad > 0 .and. nPosCodPro > 0 .and. nPosSeqMov > 0)	
		
			for nJ := 1 to oBD6:Length()
					
				oBD6:GoLine( nJ ) 
				
				if 	alltrim(oBD6:GetValue("BD6_CODPAD")) == alltrim(aEditItem[nI][1][nPosCodPad][2]) .AND. ;
					alltrim(oBD6:GetValue("BD6_CODPRO")) == alltrim(aEditItem[nI][1][nPosCodPro][2]) .AND. ;
					alltrim(oBD6:GetValue("BD6_SEQUEN")) == alltrim(aEditItem[nI][1][nPosSeqMov][2]) 
					
					//Preciso saber se o usuário editou o código do procedimento ou a tabela
					//pois nesse caso, é necessário excluir e inserir um novo
					if(aScan( aEditItem[nI][2], { |x| x[1] == "BD6_CODPAD" } ) > 0 .or. ;
					   aScan( aEditItem[nI][2], { |x| x[1] == "BD6_CODPRO" } ) > 0)	
					
						oBD6:DeleteLine()
						//adiciono no array de addedItems para ser incluido um BD6 novo
						aAdd(aAddItem, aEditItem[nI][2])
						//guardo a chave para excluir a BX6 e a BD7 referenciada
						aAdd(aKeyDel, BD5->(BD5_CODOPE+BD5_CODLDP+BD5_CODPEG+BD5_NUMERO+BD5_ORIMOV)+;
										aEditItem[nI][1][nPosSeqMov][2])
							
					else 
								 
						for nW := 1 to len(aEditItem[nI][2])
																		
							if(!("BX6" $ aEditItem[nI][2][nW][1]))
								oBD6:LoadValue(aEditItem[nI][2][nW][1], aEditItem[nI][2][nW][2])
							else
								//Adicionar campos
								aadd(aEditBX6, {aEditItem[nI][2][nW][1],  aEditItem[nI][2][nW][2]})
							endif
							
						next nW
						
						//Existe item para edição na BX6
						if len(aEditBX6) > 0
							aadd(aObEditBX6, { BD5->(BD5_CODOPE+BD5_CODLDP+BD5_CODPEG+BD5_NUMERO+BD5_ORIMOV)+aEditItem[1][1][3][2]+aEditItem[1][1][1][2]+aEditItem[1][1][2][2],aEditBX6 })
							aEditBX6 := {}
						endif
						
					endIf
				
				endIf
				
			next nJ
		
		endIf
	
	next nI
	
	for nI := 1 to len(aAddItem)
		
		oBD6:AddLine()
		
		aAuxBX6 := {}
		aAuxBD7 := {}
		for nJ := 1 to len(aAddItem[nI])
			//garanto que o campo não é da BX6, pois não temos ela dentro da model
			if(!("BX6" $ aAddItem[nI][nJ][1]))
				oBD6:LoadValue(aAddItem[nI][nJ][1], aAddItem[nI][nJ][2])
				//verifico se o campo é o CODPAD ou CODPRO para gravar a BX6
				if("BD6_CODPAD" $ aAddItem[nI][nJ][1])
					aAdd(aAuxBX6, {"BD6_CODPAD",aAddItem[nI][nJ][2] })
				elseif("BD6_CODPRO" $ aAddItem[nI][nJ][1])
					aAdd(aAuxBX6, {"BD6_CODPRO",aAddItem[nI][nJ][2] })
				endif
			else
				if("BX6_CODDES" $ aAddItem[nI][nJ][1])
					aAdd(aAuxBX6, {"BX6_CODDES",aAddItem[nI][nJ][2] })
				elseif("BX6_CODUNM" $ aAddItem[nI][nJ][1])
					aAdd(aAuxBX6, {"BX6_CODUNM",aAddItem[nI][nJ][2] })
				elseif("BX6_REGANV" $ aAddItem[nI][nJ][1])
					aAdd(aAuxBX6, {"BX6_REGANV",aAddItem[nI][nJ][2] })
				elseif("BX6_AUTFUN" $ aAddItem[nI][nJ][1])
					aAdd(aAuxBX6, {"BX6_AUTFUN",aAddItem[nI][nJ][2] })
				endif 
			endIf
			
		next nJ
		
		 /*Descrição do Procedimento*/		
	    oBD6:LoadValue("BD6_DESPRO",subStr(oObjBoGuia:getDescProcedimento(oBD6:getValue("BD6_CODPRO"), "",oBD6:getValue("BD6_CODPAD")),1,50))	
    		
		self:copyIteOutDes(oBD6)
		
		if(len(aAuxBX6) > 0)
			//garanto o sequen correto
			//não considero o D_E_L_E_T_ na query para nao dar problema no X2_UNICO que foi colocado na BD6 
			//para o primeiro item incluido ainda, os demais precisam seguir o primeiro+1
			if(nI == 1)
				cSql := "SELECT MAX(BD6_SEQUEN) AS MAXSEQ FROM " + RetSqlName("BD6") 
				cSql += " WHERE BD6_FILIAL 	= '" + xFilial("BD6")  + "'"
				cSql += " AND BD6_CODOPE 	= '" + BD5->BD5_CODOPE + "'"
				cSql += " AND BD6_CODLDP 	= '" + BD5->BD5_CODLDP + "'"
				cSql += " AND BD6_CODPEG 	= '" + BD5->BD5_CODPEG + "'"
				cSql += " AND BD6_NUMERO 	= '" + BD5->BD5_NUMERO + "'"
				cSql += " AND BD6_ORIMOV 	= '" + BD5->BD5_ORIMOV + "'"
				
				
				dbUseArea(.T.,"TOPCONN",TcGenQry(,,cSql),"TRBBD6",.T.,.F.)
				oBD6:LoadValue("BD6_SEQUEN", iif( TRBBD6->(!EOF()) ,Soma1( TRBBD6->MAXSEQ ), "001"))
								
				TRBBD6->(dbCloseArea())
			else
				cSeq := Soma1( cSeq )
				oBD6:LoadValue("BD6_SEQUEN", cSeq)
			endif
			
			cSeq := oBD6:GetValue("BD6_SEQUEN")
			aAdd(aAuxBX6, {"BD6_SEQUEN", oBD6:GetValue("BD6_SEQUEN") })
			
			aDadTab := oObjBoGuia:getDadTabela(oBD6:GetValue("BD6_CODPAD"),oBD6:GetValue("BD6_CODPRO"),;
									   oBD6:GetValue("BD6_DATPRO"),oBD6:GetValue("BD6_CODOPE"), oBD6:GetValue("BD6_CODRDA"),;
									   oBD6:GetValue("BD6_CODESP"),"",oBD6:GetValue("BD6_CODLOC"),oBD6:GetValue("BD6_LOCAL"),; 
									   oBD6:GetValue("BD6_OPEORI"), oBD6:GetValue("BD6_CODPLA"))

			if len(aDadTab) > 0
				oBD6:LoadValue("BD6_CODTAB",aDadTab[1])
			endif
	
			if len(aDadTab) > 1
				oBD6:LoadValue("BD6_ALIATB", aDadTab[2])
			endif
			
			aAdd(aAuxBD7,{;
				oBD6:GetValue("BD6_VLPGMA"),;	
				oBD6:GetValue("BD6_CODPAD"),;	
				oBD6:GetValue("BD6_CODPRO"),;	
				oBD6:GetValue("BD6_CODTAB"),;	
			 	oBD6:GetValue("BD6_CODOPE"),;	
			 	oBD6:GetValue("BD6_CODRDA"),;	
			 	oBD6:GetValue("BD6_REGEXE"),;	
			 	oBD6:GetValue("BD6_SIGEXE"),;	
				oBD6:GetValue("BD6_ESTEXE"),;	
				oBD6:GetValue("BD6_CDPFRE"),;	
				oBD6:GetValue("BD6_CODESP"),;	
				oBD6:GetValue("BD6_CODLOC"),;	
				oBD6:GetValue("BD6_LOCAL"),;	
				oBD6:GetValue("BD6_SEQUEN"),;	
	          	oBD6:GetValue("BD6_DATPRO")})
	
			aAdd(aBX6, {aAuxBX6, aAuxBD7})
		endIf
    				
	next nI

	if oModel:VldData()
		oModel:CommitData()
		Begin Transaction
					
			//Inclusão da BX6
			for nI := 1 to len(aBX6)
			   nPosCodPad := aScan( aBX6[nI][1], { |x| x[1] == "BD6_CODPAD" } )
			   nPosCodPro := aScan( aBX6[nI][1], { |x| x[1] == "BD6_CODPRO" } )
			   nPosSeqMov := aScan( aBX6[nI][1], { |x| x[1] == "BD6_SEQUEN" } ) 
			   nPosCodDes := aScan( aBX6[nI][1], { |x| x[1] == "BX6_CODDES" } ) 
			   nPosCodUnm := aScan( aBX6[nI][1], { |x| x[1] == "BX6_CODUNM" } )
			   nPosRegAnv := aScan( aBX6[nI][1], { |x| x[1] == "BX6_REGANV" } )
			   nPosAutFun := aScan( aBX6[nI][1], { |x| x[1] == "BX6_AUTFUN" } )
			   			   
				if(nPosCodPad > 0 .and. nPosCodPro > 0 .and. nPosSeqMov > 0 .and. nPosCodDes)
					BX6->(RecLock("BX6", .T.))
						BX6->BX6_FILIAL := xFilial("BX6")
						BX6->BX6_CODOPE := BD5->BD5_CODOPE
						BX6->BX6_CODLDP := BD5->BD5_CODLDP
						BX6->BX6_CODPEG := BD5->BD5_CODPEG
						BX6->BX6_NUMERO := BD5->BD5_NUMERO
						BX6->BX6_ORIMOV := BD5->BD5_ORIMOV
						BX6->BX6_SEQUEN := aBX6[nI][1][nPosSeqMov][2]
						BX6->BX6_CODPAD := aBX6[nI][1][nPosCodPad][2]
						BX6->BX6_CODPRO := aBX6[nI][1][nPosCodPro][2]
						BX6->BX6_CODDES := aBX6[nI][1][nPosCodDes][2]
						BX6->BX6_CODUNM := aBX6[nI][1][nPosCodUnm][2]
						BX6->BX6_REGANV := aBX6[nI][1][nPosRegAnv][2]
						BX6->BX6_AUTFUN := aBX6[nI][1][nPosAutFun][2]
						BX6->BX6_AODESP := .T.				
					BX6->(MsUnlock())
					BD6->(DbSetOrder(1))
					BD6->(msSeek(xFilial("BD6")+BD5->(BD5_CODOPE+BD5_CODLDP+BD5_CODPEG+BD5_NUMERO+BD5_ORIMOV)+aBX6[nI][1][nPosSeqMov][2]+aBX6[nI][1][nPosCodPad][2]+aBX6[nI][1][nPosCodPro][2]))
					
					PLS720IBD7({},aBX6[nI][2][1][1],aBX6[nI][2][1][2],aBX6[nI][2][1][3],aBX6[nI][2][1][4],;
			  									       aBX6[nI][2][1][5],aBX6[nI][2][1][6],aBX6[nI][2][1][7],aBX6[nI][2][1][8],;
												       aBX6[nI][2][1][9],aBX6[nI][2][1][10],aBX6[nI][2][1][11],;
												       aBX6[nI][2][1][12]+aBX6[nI][2][1][13],"1", aBX6[nI][2][1][14],;
	                     						       cOriMov,BD5->BD5_TIPGUI,aBX6[nI][2][1][15],,,,,,,,,{},,.F.)
	                     						       
				endIf
								
			next nI
			
			BX6->(DbSetOrder(1))
			BD7->(DbSetOrder(1))
			for nI := 1 to Len(aKeyDel)
			
				if(BX6->(msSeek(xFilial("BX6")+aKeyDel[nI])))
					BX6->(Reclock("BX6",.F.))
						BX6->(DbDelete())
					BX6->(MsUnlock())
				endIf
				
				If BD7->(MsSeek(xFilial("BD7")+aKeyDel[nI]))
					While ! BD7->(Eof()) .And. BD7->(BD7_FILIAL+BD7_CODOPE+BD7_CODLDP+BD7_CODPEG+BD7_NUMERO+BD7_ORIMOV+BD7_SEQUEN) == ;
						xFilial("BD7")+aKeyDel[nI]      
				                                        
						BD7->(Reclock("BD7",.F.))
							BD7->(DbDelete())
						BD7->(MsUnlock())
						
						BD7->(DbSkip())
					EndDo	
				EndIf  
				
			next nI
			
			//Edição da BX6 quando o item for editado
			BX6->(DbSetOrder(1))
			for nI := 1 to Len(aObEditBX6)
				if(BX6->(msSeek(xFilial("BX6")+aObEditBX6[nI][1]))) .and. len(aObEditBX6[1][2]) > 0
					
					BX6->(Reclock("BX6",.F.))										
					
					for nX := 1 to len(aObEditBX6[1][2])
						&("BX6->" + aObEditBX6[1][2][nX][1] ) := aObEditBX6[1][2][nX][2]
					next nX
					
					BX6->(MsUnlock())		
				endIf
			next nI
			
		End Transaction
		
	else	
		lRet := .F.	
		VarInfo("",oModel:GetErrorMessage())	
	endif
Else
	
	BE4->(DbGoTo(nRecGuiRef))
	BA1->(DbSetOrder(2))//BA1_FILIAL+BA1_CODINT+BA1_CODEMP+BA1_MATRIC+BA1_TIPREG+BA1_DIGITO                                                                                                                                                                                   
	BA1->(DbSeek(xFilial("BA1")+BE4->(BE4_CODOPE+BE4_CODEMP+BE4_MATRIC+BE4_TIPREG+BE4_DIGITO)))
	BA3->(DbSetOrder(1))//BA3_FILIAL+BA3_CODINT+BA3_CODEMP+BA3_MATRIC+BA3_CONEMP+BA3_VERCON+BA3_SUBCON+BA3_VERSUB                                                                         
	BA3->(DbSeek(xFilial("BA3")+BE4->BE4_CODOPE+BE4->BE4_CODEMP+BE4->BE4_MATRIC+BA1->BA1_CONEMP+BA1->BA1_VERCON+BA1->BA1_SUBCON+BA1->BA1_VERSUB))
	//Se diferente de status Digitação de Guias, muda a fase
	If BE4->BE4_FASE <> "1"
		lRetMudFase := PLSBACKGUI(Str(nRecGuiRef), Val(BE4->BE4_TIPGUI))
	EndIf
	
	BE4->(DbGoTo(nRecGuiRef)) //A mudança de fase estava desposicionando a BE4.
	
	//Para garantir pegar o local de origem correto conforme a guia
	cOrimov := BE4->BE4_ORIMOV

	oModel:SetOperation(4)
	oModel:Activate()
	
	//Faço primeiro a edição e deleção dos itens para percorrer uma model de bd6 menor
	
	for nI := 1 to len(aDelItem)
	    //pego a chave do procedimento
		nPosCodPad := aScan( aDelItem[nI], { |x| x[1] == "BD6_CODPAD" } )
		nPosCodPro := aScan( aDelItem[nI], { |x| x[1] == "BD6_CODPRO" } )
		nPosSeqMov := aScan( aDelItem[nI], { |x| x[1] == "BD6_SEQUEN" } ) 
		if(nPosCodPad > 0 .and. nPosCodPro > 0 .and. nPosSeqMov > 0)	
		
			for nJ := 1 to oBD6:Length()
					
				oBD6:GoLine( nJ ) 
				
				if 	alltrim(oBD6:GetValue("BD6_CODPAD")) == alltrim(aDelItem[nI][nPosCodPad][2]) .AND. ;
					alltrim(oBD6:GetValue("BD6_CODPRO")) == alltrim(aDelItem[nI][nPosCodPro][2]) .AND. ;
					alltrim(oBD6:GetValue("BD6_SEQUEN")) == alltrim(aDelItem[nI][nPosSeqMov][2]) 
					
						oBD6:DeleteLine()
						aAdd(aKeyDel, BE4->(BE4_CODOPE+BE4_CODLDP+BE4_CODPEG+BE4_NUMERO+BE4_ORIMOV)+;
										aDelItem[nI][nPosSeqMov][2])
				
				endIf
				
			next nJ
		
		endIf
	
	next nI
	
	for nI := 1 to len(aEditItem)
	    //pego a chave do procedimento, que é sempre a primeira posição do item editado
		nPosCodPad := aScan( aEditItem[nI][1], { |x| x[1] == "BD6_CODPAD" } )
		nPosCodPro := aScan( aEditItem[nI][1], { |x| x[1] == "BD6_CODPRO" } )
		nPosSeqMov := aScan( aEditItem[nI][1], { |x| x[1] == "BD6_SEQUEN" } ) 
		if(nPosCodPad > 0 .and. nPosCodPro > 0 .and. nPosSeqMov > 0)	
		
			for nJ := 1 to oBD6:Length()
					
				oBD6:GoLine( nJ ) 
				
				if 	alltrim(oBD6:GetValue("BD6_CODPAD")) == alltrim(aEditItem[nI][1][nPosCodPad][2]) .AND. ;
					alltrim(oBD6:GetValue("BD6_CODPRO")) == alltrim(aEditItem[nI][1][nPosCodPro][2]) .AND. ;
					alltrim(oBD6:GetValue("BD6_SEQUEN")) == alltrim(aEditItem[nI][1][nPosSeqMov][2]) 
					
					//Preciso saber se o usuário editou o código do procedimento ou a tabela
					//pois nesse caso, é necessário excluir e inserir um novo
					if(aScan( aEditItem[nI][2], { |x| x[1] == "BD6_CODPAD" } ) > 0 .or. ;
					   aScan( aEditItem[nI][2], { |x| x[1] == "BD6_CODPRO" } ) > 0)	
					
						oBD6:DeleteLine()
						//adiciono no array de addedItems para ser incluido um BD6 novo
						aAdd(aAddItem, aEditItem[nI][2])
						//guardo a chave para excluir a BX6 e a BD7 referenciada
						aAdd(aKeyDel, BE4->(BE4_CODOPE+BE4_CODLDP+BE4_CODPEG+BE4_NUMERO+BE4_ORIMOV)+;
										aEditItem[nI][1][nPosSeqMov][2])
							
					else 
								 
						for nW := 1 to len(aEditItem[nI][2])
																		
							if(!("BX6" $ aEditItem[nI][2][nW][1]))
								oBD6:LoadValue(aEditItem[nI][2][nW][1], aEditItem[nI][2][nW][2])
							else
								//Adicionar campos
								aadd(aEditBX6, {aEditItem[nI][2][nW][1],  aEditItem[nI][2][nW][2]})
							endif
							
						next nW
						
						//Existe item para edição na BX6
						if len(aEditBX6) > 0
							aadd(aObEditBX6, { BE4->(BE4_CODOPE+BE4_CODLDP+BE4_CODPEG+BE4_NUMERO+BE4_ORIMOV)+aEditItem[1][1][3][2]+aEditItem[1][1][1][2]+aEditItem[1][1][2][2],aEditBX6 })
							aEditBX6 := {}
						endif
						
					endIf
				
				endIf
				
			next nJ
		
		endIf
	
	next nI
	
	for nI := 1 to len(aAddItem)
		
		oBD6:AddLine()
		
		aAuxBX6 := {}
		aAuxBD7 := {}
		for nJ := 1 to len(aAddItem[nI])
			//garanto que o campo não é da BX6, pois não temos ela dentro da model
			if(!("BX6" $ aAddItem[nI][nJ][1]))
				oBD6:LoadValue(aAddItem[nI][nJ][1], aAddItem[nI][nJ][2])
				//verifico se o campo é o CODPAD ou CODPRO para gravar a BX6
				if("BD6_CODPAD" $ aAddItem[nI][nJ][1])
					aAdd(aAuxBX6, {"BD6_CODPAD",aAddItem[nI][nJ][2] })
				elseif("BD6_CODPRO" $ aAddItem[nI][nJ][1])
					aAdd(aAuxBX6, {"BD6_CODPRO",aAddItem[nI][nJ][2] })
				endif
			else
				if("BX6_CODDES" $ aAddItem[nI][nJ][1])
					aAdd(aAuxBX6, {"BX6_CODDES",aAddItem[nI][nJ][2] })
				elseif("BX6_CODUNM" $ aAddItem[nI][nJ][1])
					aAdd(aAuxBX6, {"BX6_CODUNM",aAddItem[nI][nJ][2] })
				elseif("BX6_REGANV" $ aAddItem[nI][nJ][1])
					aAdd(aAuxBX6, {"BX6_REGANV",aAddItem[nI][nJ][2] })
				elseif("BX6_AUTFUN" $ aAddItem[nI][nJ][1])
					aAdd(aAuxBX6, {"BX6_AUTFUN",aAddItem[nI][nJ][2] })
				endif 
			endIf
			
			// Atualizando o Valor Aprovado
			if("BD6_PRPRRL" $ aAddItem[nI][nJ][1])
				nRedAcre := aAddItem[nI][nJ][2]
			endif
			
			if("BD6_VLRAPR" $ aAddItem[nI][nJ][1])
				nVlrApr := aAddItem[nI][nJ][2]
			endif
			
			nVlrTotal := nRedAcre * nVlrApr
			
			oBD6:LoadValue("BD6_VLRAPR", nVlrTotal)
					
		next nJ
		
		 /*Descrição do Procedimento*/		
	    oBD6:LoadValue("BD6_DESPRO",subStr(oObjBoGuia:getDescProcedimento(oBD6:getValue("BD6_CODPRO"), "",oBD6:getValue("BD6_CODPAD")),1,50))	
    		
		self:copyIteResInt(oBD6)
		
		if(len(aAuxBX6) > 0)
			//garanto o sequen correto
			//não considero o D_E_L_E_T_ na query para nao dar problema no X2_UNICO que foi colocado na BD6 
			//para o primeiro item incluido ainda, os demais precisam seguir o primeiro+1
			if(nI == 1)
				cSql := "SELECT MAX(BD6_SEQUEN) AS MAXSEQ FROM " + RetSqlName("BD6") 
				cSql += " WHERE BD6_FILIAL 	= '" + xFilial("BD6")  + "'"
				cSql += " AND BD6_CODOPE 	= '" + BE4->BE4_CODOPE + "'"
				cSql += " AND BD6_CODLDP 	= '" + BE4->BE4_CODLDP + "'"
				cSql += " AND BD6_CODPEG 	= '" + BE4->BE4_CODPEG + "'"
				cSql += " AND BD6_NUMERO 	= '" + BE4->BE4_NUMERO + "'"
				cSql += " AND BD6_ORIMOV 	= '" + BE4->BE4_ORIMOV + "'"
				
				
				dbUseArea(.T.,"TOPCONN",TcGenQry(,,cSql),"TRBBD6",.T.,.F.)
				oBD6:LoadValue("BD6_SEQUEN", iif( TRBBD6->(!EOF()) ,Soma1( TRBBD6->MAXSEQ ), "001"))
								
				TRBBD6->(dbCloseArea())
			else
				cSeq := Soma1( cSeq )
				oBD6:LoadValue("BD6_SEQUEN", cSeq)
			endif
			
			cSeq := oBD6:GetValue("BD6_SEQUEN")
			aAdd(aAuxBX6, {"BD6_SEQUEN", oBD6:GetValue("BD6_SEQUEN") })
			
			aDadTab := oObjBoGuia:getDadTabela(oBD6:GetValue("BD6_CODPAD"),oBD6:GetValue("BD6_CODPRO"),;
									   oBD6:GetValue("BD6_DATPRO"),oBD6:GetValue("BD6_CODOPE"), oBD6:GetValue("BD6_CODRDA"),;
									   oBD6:GetValue("BD6_CODESP"),"",oBD6:GetValue("BD6_CODLOC"),oBD6:GetValue("BD6_LOCAL"),; 
									   oBD6:GetValue("BD6_OPEORI"), oBD6:GetValue("BD6_CODPLA"))

			if len(aDadTab) > 0
				oBD6:LoadValue("BD6_CODTAB",aDadTab[1])
			endif
	
			if len(aDadTab) > 1
				oBD6:LoadValue("BD6_ALIATB", aDadTab[2])
			endif
			
			aAdd(aAuxBD7,{;
				oBD6:GetValue("BD6_VLPGMA"),;	
				oBD6:GetValue("BD6_CODPAD"),;	
				oBD6:GetValue("BD6_CODPRO"),;	
				oBD6:GetValue("BD6_CODTAB"),;	
			 	oBD6:GetValue("BD6_CODOPE"),;	
			 	oBD6:GetValue("BD6_CODRDA"),;	
			 	oBD6:GetValue("BD6_REGEXE"),;	
			 	oBD6:GetValue("BD6_SIGEXE"),;	
				oBD6:GetValue("BD6_ESTEXE"),;	
				oBD6:GetValue("BD6_CDPFRE"),;	
				oBD6:GetValue("BD6_CODESP"),;	
				oBD6:GetValue("BD6_CODLOC"),;	
				oBD6:GetValue("BD6_LOCAL"),;	
				oBD6:GetValue("BD6_SEQUEN"),;	
	          	oBD6:GetValue("BD6_DATPRO")})
	
			aAdd(aBX6, {aAuxBX6, aAuxBD7})
		endIf
    				
	next nI

	if oModel:VldData()
		oModel:CommitData()
		Begin Transaction
					
			//Inclusão da BX6
			for nI := 1 to len(aBX6)
			   nPosCodPad := aScan( aBX6[nI][1], { |x| x[1] == "BD6_CODPAD" } )
			   nPosCodPro := aScan( aBX6[nI][1], { |x| x[1] == "BD6_CODPRO" } )
			   nPosSeqMov := aScan( aBX6[nI][1], { |x| x[1] == "BD6_SEQUEN" } ) 
			   nPosCodDes := aScan( aBX6[nI][1], { |x| x[1] == "BX6_CODDES" } ) 
			   nPosCodUnm := aScan( aBX6[nI][1], { |x| x[1] == "BX6_CODUNM" } )
			   nPosRegAnv := aScan( aBX6[nI][1], { |x| x[1] == "BX6_REGANV" } )
			   nPosAutFun := aScan( aBX6[nI][1], { |x| x[1] == "BX6_AUTFUN" } )
			   			   
				if(nPosCodPad > 0 .and. nPosCodPro > 0 .and. nPosSeqMov > 0 .and. nPosCodDes)
					BX6->(RecLock("BX6", .T.))
						BX6->BX6_FILIAL := xFilial("BX6")
						BX6->BX6_CODOPE := BE4->BE4_CODOPE
						BX6->BX6_CODLDP := BE4->BE4_CODLDP
						BX6->BX6_CODPEG := BE4->BE4_CODPEG
						BX6->BX6_NUMERO := BE4->BE4_NUMERO
						BX6->BX6_ORIMOV := BE4->BE4_ORIMOV
						BX6->BX6_SEQUEN := aBX6[nI][1][nPosSeqMov][2]
						BX6->BX6_CODPAD := aBX6[nI][1][nPosCodPad][2]
						BX6->BX6_CODPRO := aBX6[nI][1][nPosCodPro][2]
						BX6->BX6_CODDES := aBX6[nI][1][nPosCodDes][2]
						BX6->BX6_CODUNM := aBX6[nI][1][nPosCodUnm][2]
						BX6->BX6_REGANV := aBX6[nI][1][nPosRegAnv][2]
						BX6->BX6_AUTFUN := aBX6[nI][1][nPosAutFun][2]
						BX6->BX6_AODESP := .T.				
					BX6->(MsUnlock())
					BD6->(DbSetOrder(1))
					BD6->(msSeek(xFilial("BD6")+BE4->(BE4_CODOPE+BE4_CODLDP+BE4_CODPEG+BE4_NUMERO+BE4_ORIMOV)+aBX6[nI][1][nPosSeqMov][2]+aBX6[nI][1][nPosCodPad][2]+aBX6[nI][1][nPosCodPro][2]))
					
					PLS720IBD7({},aBX6[nI][2][1][1],aBX6[nI][2][1][2],aBX6[nI][2][1][3],aBX6[nI][2][1][4],;
			  									       aBX6[nI][2][1][5],aBX6[nI][2][1][6],aBX6[nI][2][1][7],aBX6[nI][2][1][8],;
												       aBX6[nI][2][1][9],aBX6[nI][2][1][10],aBX6[nI][2][1][11],;
												       aBX6[nI][2][1][12]+aBX6[nI][2][1][13],"1", aBX6[nI][2][1][14],;
	                     						       cOriMov,BE4->BE4_TIPGUI,aBX6[nI][2][1][15],,,,,,,,,{},,.F.)
	                     						       
				endIf
								
			next nI
			
			BX6->(DbSetOrder(1))
			BD7->(DbSetOrder(1))
			for nI := 1 to Len(aKeyDel)
			
				if(BX6->(msSeek(xFilial("BX6")+aKeyDel[nI])))
					BX6->(Reclock("BX6",.F.))
						BX6->(DbDelete())
					BX6->(MsUnlock())
				endIf
				
				If BD7->(MsSeek(xFilial("BD7")+aKeyDel[nI]))
					While ! BD7->(Eof()) .And. BD7->(BD7_FILIAL+BD7_CODOPE+BD7_CODLDP+BD7_CODPEG+BD7_NUMERO+BD7_ORIMOV+BD7_SEQUEN) == ;
						xFilial("BD7")+aKeyDel[nI]      
				                                        
						BD7->(Reclock("BD7",.F.))
							BD7->(DbDelete())
						BD7->(MsUnlock())
						
						BD7->(DbSkip())
					EndDo	
				EndIf  
				
			next nI
			
			//Edição da BX6 quando o item for editado
			BX6->(DbSetOrder(1))
			for nI := 1 to Len(aObEditBX6)
				if(BX6->(msSeek(xFilial("BX6")+aObEditBX6[nI][1]))) .and. len(aObEditBX6[1][2]) > 0
					
					BX6->(Reclock("BX6",.F.))										
					
					for nX := 1 to len(aObEditBX6[1][2])
						&("BX6->" + aObEditBX6[1][2][nX][1] ) := aObEditBX6[1][2][nX][2]
					next nX
					
					BX6->(MsUnlock())		
				endIf
			next nI
			
		End Transaction
		
	else	
		lRet := .F.	
		VarInfo("",oModel:GetErrorMessage())	
	endif

EndIf	
	
	oModel:DeActivate()

return ({lRet, aCriticas, lRetMudFase})

//-------------------------------------------------------------------
/*/{Protheus.doc} copyIteOutDes
Método para copiar os itens da outras despesas com a BD5 posicionada
@author Karine Riquena Limp
@since 08/07/2016
@version P12
/*/
//-------------------------------------------------------------------
method copyIteOutDes(oBD6, oBD5) class CO_Guia
Local cGrpEmpInt := GetNewPar("MV_PLSGEIN","0050")
	if Empty(oBD5)
		oBD6:LoadValue("BD6_CODESP", BD5->BD5_CODESP )
		oBD6:LoadValue("BD6_NRAOPE", BD5->BD5_NRAOPE )				
		oBD6:LoadValue("BD6_CODOPE", BD5->BD5_CODOPE )
		oBD6:LoadValue("BD6_CODLDP", BD5->BD5_CODLDP )
		oBD6:LoadValue("BD6_CODPEG", BD5->BD5_CODPEG )
		oBD6:LoadValue("BD6_NUMERO", BD5->BD5_NUMERO ) 	
		oBD6:LoadValue("BD6_ESPSOL", BD5->BD5_ESPSOL )
		oBD6:LoadValue("BD6_ESTSOL", BD5->BD5_ESTSOL )
		oBD6:LoadValue("BD6_SIGLA" , BD5->BD5_SIGLA  )
		oBD6:LoadValue("BD6_REGSOL", BD5->BD5_REGSOL )
		oBD6:LoadValue("BD6_NOMSOL", BD5->BD5_NOMSOL ) 
		oBD6:LoadValue("BD6_CDPFSO", BD5->BD5_CDPFSO )
		oBD6:LoadValue("BD6_ESPEXE", BD5->BD5_ESPEXE )
		oBD6:LoadValue("BD6_ESTEXE", BD5->BD5_ESTEXE )
		oBD6:LoadValue("BD6_SIGEXE", BD5->BD5_SIGEXE )
		oBD6:LoadValue("BD6_REGEXE", BD5->BD5_REGEXE )
		oBD6:LoadValue("BD6_CDPFRE", BD5->BD5_CDPFRE )
		oBD6:LoadValue("BD6_OPEEXE", BD5->BD5_OPEEXE )	
		oBD6:LoadValue("BD6_CODRDA", BD5->BD5_CODRDA )
		oBD6:LoadValue("BD6_NOMRDA", left(BD5->BD5_NOMRDA, TamSx3("BD6_NOMRDA")[1])) //BD5->BD5_NOMRDA )
		oBD6:LoadValue("BD6_TIPRDA", BD5->BD5_TIPRDA )
		oBD6:LoadValue("BD6_CODLOC", BD5->BD5_CODLOC )
		oBD6:LoadValue("BD6_LOCAL" , BD5->BD5_LOCAL  )
		oBD6:LoadValue("BD6_CPFRDA", BD5->BD5_CPFRDA )
		oBD6:LoadValue("BD6_DESLOC", BD5->BD5_DESLOC )
		oBD6:LoadValue("BD6_ENDLOC", BD5->BD5_ENDLOC )
		oBD6:LoadValue("BD6_OPEUSR", BD5->BD5_OPEUSR )
		oBD6:LoadValue("BD6_MATANT", BD5->BD5_MATANT )
		oBD6:LoadValue("BD6_NOMUSR", BD5->BD5_NOMUSR )
		oBD6:LoadValue("BD6_CODEMP", BD5->BD5_CODEMP )
		oBD6:LoadValue("BD6_MATRIC", BD5->BD5_MATRIC )
		oBD6:LoadValue("BD6_TIPREG", BD5->BD5_TIPREG )
		oBD6:LoadValue("BD6_IDUSR" , BD5->BD5_IDUSR  )
		oBD6:LoadValue("BD6_DATNAS", BD5->BD5_DATNAS )
		oBD6:LoadValue("BD6_DIGITO", BD5->BD5_DIGITO )
		oBD6:LoadValue("BD6_CONEMP", BD5->BD5_CONEMP )
		oBD6:LoadValue("BD6_VERCON", BD5->BD5_VERCON )
		oBD6:LoadValue("BD6_SUBCON", BD5->BD5_SUBCON )
		oBD6:LoadValue("BD6_VERSUB", BD5->BD5_VERSUB )
		oBD6:LoadValue("BD6_MATVID", BD5->BD5_MATVID )
		oBD6:LoadValue("BD6_FASE"  , BD5->BD5_FASE   )
		oBD6:LoadValue("BD6_SITUAC", BD5->BD5_SITUAC )
		oBD6:LoadValue("BD6_NUMIMP", BD5->BD5_NUMIMP )
		oBD6:LoadValue("BD6_LOTGUI", BD5->BD5_LOTGUI )
		oBD6:LoadValue("BD6_TIPGUI", BD5->BD5_TIPGUI )
		oBD6:LoadValue("BD6_GUIORI", BD5->BD5_GUIORI )
		oBD6:LoadValue("BD6_DTDIGI", IIF(EmpTy(BD5->BD5_DTDIGI), Date(), BD5->BD5_DTDIGI) )
		oBD6:LoadValue("BD6_MESPAG", BD5->BD5_MESPAG )
		oBD6:LoadValue("BD6_ANOPAG", BD5->BD5_ANOPAG )
		oBD6:LoadValue("BD6_MATUSA", BD5->BD5_MATUSA )
		oBD6:LoadValue("BD6_PACOTE", BD5->BD5_PACOTE )
		oBD6:LoadValue("BD6_ORIMOV", BD5->BD5_ORIMOV )
		oBD6:LoadValue("BD6_GUIACO", BD5->BD5_GUIACO )
		oBD6:LoadValue("BD6_LIBERA", BD5->BD5_LIBERA )
		oBD6:LoadValue("BD6_RGIMP" , BD5->BD5_RGIMP  )
		oBD6:LoadValue("BD6_TPGRV" , BD5->BD5_TPGRV  )
		oBD6:LoadValue("BD6_CID"   , BD5->BD5_CID    )
		oBD6:LoadValue("BD6_TIPCON", BD5->BD5_TIPCON ) 
		oBD6:LoadValue("BD6_NRLBOR", BD5->BD5_NRLBOR )
		oBD6:LoadValue("BD6_INTERC", If(BA3->BA3_CODEMP==cGrpEmpInt,"1","0") )
		oBD6:LoadValue("BD6_TIPUSR", BA3->BA3_TIPOUS )
		oBD6:LoadValue("BD6_MODCOB", Left(alltrim(BA3->BA3_MODPAG), TamSx3("BD6_MODCOB")[1])) 
		oBD6:LoadValue("BD6_CODPLA", BA3->BA3_CODPLA )
		oBD6:LoadValue("BD6_OPEORI", BA1->BA1_OPEORI )
	Else
		oBD6:LoadValue("BD6_CODESP", oBD5:getValue("BD5_CODESP"))
		oBD6:LoadValue("BD6_NRAOPE", oBD5:getValue("BD5_NRAOPE"))				
		oBD6:LoadValue("BD6_CODOPE", oBD5:getValue("BD5_CODOPE"))
		oBD6:LoadValue("BD6_CODLDP", oBD5:getValue("BD5_CODLDP"))
		oBD6:LoadValue("BD6_CODPEG", oBD5:getValue("BD5_CODPEG"))
		oBD6:LoadValue("BD6_NUMERO", oBD5:getValue("BD5_NUMERO"))
		oBD6:LoadValue("BD6_ESPSOL", oBD5:getValue("BD5_ESPSOL"))
		oBD6:LoadValue("BD6_ESTSOL", oBD5:getValue("BD5_ESTSOL"))
		oBD6:LoadValue("BD6_SIGLA" , oBD5:getValue("BD5_SIGLA"))
		oBD6:LoadValue("BD6_REGSOL", oBD5:getValue("BD5_REGSOL"))
		oBD6:LoadValue("BD6_NOMSOL", oBD5:getValue("BD5_NOMSOL")) 
		oBD6:LoadValue("BD6_CDPFSO", oBD5:getValue("BD5_CDPFSO"))
		oBD6:LoadValue("BD6_ESPEXE", oBD5:getValue("BD5_ESPEXE"))
		oBD6:LoadValue("BD6_ESTEXE", oBD5:getValue("BD5_ESTEXE"))
		oBD6:LoadValue("BD6_SIGEXE", oBD5:getValue("BD5_SIGEXE"))
		oBD6:LoadValue("BD6_REGEXE", oBD5:getValue("BD5_REGEXE"))
		oBD6:LoadValue("BD6_CDPFRE", oBD5:getValue("BD5_CDPFRE"))
		oBD6:LoadValue("BD6_OPEEXE", oBD5:getValue("BD5_OPEEXE"))	
		oBD6:LoadValue("BD6_CODRDA", oBD5:getValue("BD5_CODRDA"))
		oBD6:LoadValue("BD6_NOMRDA", left(oBD5:getValue("BD5_NOMRDA"), TamSx3("BD6_NOMRDA")[1])) //oBD5:getValue("BD5_NOMRDA"))
		oBD6:LoadValue("BD6_TIPRDA", oBD5:getValue("BD5_TIPRDA"))
		oBD6:LoadValue("BD6_CODLOC", oBD5:getValue("BD5_CODLOC"))
		oBD6:LoadValue("BD6_LOCAL" , oBD5:getValue("BD5_LOCAL"))
		oBD6:LoadValue("BD6_CPFRDA", oBD5:getValue("BD5_CPFRDA"))
		oBD6:LoadValue("BD6_DESLOC", oBD5:getValue("BD5_DESLOC"))
		oBD6:LoadValue("BD6_ENDLOC", oBD5:getValue("BD5_ENDLOC"))
		oBD6:LoadValue("BD6_OPEUSR", oBD5:getValue("BD5_OPEUSR"))
		oBD6:LoadValue("BD6_MATANT", oBD5:getValue("BD5_MATANT"))
		oBD6:LoadValue("BD6_NOMUSR", oBD5:getValue("BD5_NOMUSR"))
		oBD6:LoadValue("BD6_CODEMP", oBD5:getValue("BD5_CODEMP"))
		oBD6:LoadValue("BD6_MATRIC", oBD5:getValue("BD5_MATRIC"))
		oBD6:LoadValue("BD6_TIPREG", oBD5:getValue("BD5_TIPREG"))
		oBD6:LoadValue("BD6_IDUSR" , oBD5:getValue("BD5_IDUSR"))
		oBD6:LoadValue("BD6_DATNAS", oBD5:getValue("BD5_DATNAS"))
		oBD6:LoadValue("BD6_DIGITO", oBD5:getValue("BD5_DIGITO"))
		oBD6:LoadValue("BD6_CONEMP", oBD5:getValue("BD5_CONEMP"))
		oBD6:LoadValue("BD6_VERCON", oBD5:getValue("BD5_VERCON"))
		oBD6:LoadValue("BD6_SUBCON", oBD5:getValue("BD5_SUBCON"))
		oBD6:LoadValue("BD6_VERSUB", oBD5:getValue("BD5_VERSUB"))
		oBD6:LoadValue("BD6_MATVID", oBD5:getValue("BD5_MATVID"))
		oBD6:LoadValue("BD6_FASE"  , oBD5:getValue("BD5_FASE"))
		oBD6:LoadValue("BD6_SITUAC", oBD5:getValue("BD5_SITUAC"))
		oBD6:LoadValue("BD6_NUMIMP", oBD5:getValue("BD5_NUMIMP"))
		oBD6:LoadValue("BD6_LOTGUI", oBD5:getValue("BD5_LOTGUI"))
		oBD6:LoadValue("BD6_TIPGUI", oBD5:getValue("BD5_TIPGUI"))
		oBD6:LoadValue("BD6_GUIORI", oBD5:getValue("BD5_GUIORI"))
		oBD6:LoadValue("BD6_DTDIGI", IIF( empty(oBD5:getValue("BD5_DTDIGI")), Date(), oBD5:getValue("BD5_DTDIGI")))
		oBD6:LoadValue("BD6_MESPAG", oBD5:getValue("BD5_MESPAG"))
		oBD6:LoadValue("BD6_ANOPAG", oBD5:getValue("BD5_ANOPAG"))
		oBD6:LoadValue("BD6_MATUSA", oBD5:getValue("BD5_MATUSA"))
		oBD6:LoadValue("BD6_PACOTE", oBD5:getValue("BD5_PACOTE"))
		oBD6:LoadValue("BD6_ORIMOV", oBD5:getValue("BD5_ORIMOV"))
		oBD6:LoadValue("BD6_GUIACO", oBD5:getValue("BD5_GUIACO"))
		oBD6:LoadValue("BD6_LIBERA", oBD5:getValue("BD5_LIBERA"))
		oBD6:LoadValue("BD6_RGIMP" , oBD5:getValue("BD5_RGIMP"))
		oBD6:LoadValue("BD6_TPGRV" , oBD5:getValue("BD5_TPGRV"))
		oBD6:LoadValue("BD6_CID"   , oBD5:getValue("BD5_CID"))
		oBD6:LoadValue("BD6_TIPCON", oBD5:getValue("BD5_TIPCON")) 
		oBD6:LoadValue("BD6_NRLBOR", oBD5:getValue("BD5_NRLBOR"))		
		oBD6:LoadValue("BD6_INTERC", If(BA3->BA3_CODEMP==cGrpEmpInt,"1","0") )
		oBD6:LoadValue("BD6_TIPUSR", BA3->BA3_TIPOUS )
		oBD6:LoadValue("BD6_MODCOB", Left(alltrim(BA3->BA3_MODPAG), TamSx3("BD6_MODCOB")[1])) 
		oBD6:LoadValue("BD6_CODPLA", BA3->BA3_CODPLA )
		oBD6:LoadValue("BD6_OPEORI", BA1->BA1_OPEORI )
	EndIf
	
	
return

//-------------------------------------------------------------------
/*/{Protheus.doc} copyIteResInt
Método para copiar os itens do resumo de internação com a BE4 posicionada
@author Karine Riquena Limp
@since 17/03/2017
@version P12
/*/
//-------------------------------------------------------------------
method copyIteResInt(oBD6, oBE4) class CO_Guia
Local cGrpEmpInt := GetNewPar("MV_PLSGEIN","0050")
	if Empty(oBE4)
		oBD6:LoadValue("BD6_CODESP", BE4->BE4_CODESP )
		oBD6:LoadValue("BD6_NRAOPE", BE4->BE4_NRAOPE )				
		oBD6:LoadValue("BD6_CODOPE", BE4->BE4_CODOPE )
		oBD6:LoadValue("BD6_CODLDP", BE4->BE4_CODLDP )
		oBD6:LoadValue("BD6_CODPEG", BE4->BE4_CODPEG )
		oBD6:LoadValue("BD6_NUMERO", BE4->BE4_NUMERO ) 	
		oBD6:LoadValue("BD6_ESPSOL", BE4->BE4_ESPSOL )
		oBD6:LoadValue("BD6_ESTSOL", BE4->BE4_ESTSOL )
		oBD6:LoadValue("BD6_SIGLA" , BE4->BE4_SIGLA  )
		oBD6:LoadValue("BD6_REGSOL", BE4->BE4_REGSOL )
		oBD6:LoadValue("BD6_NOMSOL", BE4->BE4_NOMSOL ) 
		oBD6:LoadValue("BD6_CDPFSO", BE4->BE4_CDPFSO )
		oBD6:LoadValue("BD6_ESPEXE", BE4->BE4_ESPEXE )
		oBD6:LoadValue("BD6_ESTEXE", BE4->BE4_ESTEXE )
		//oBD6:LoadValue("BD6_SIGEXE", BE4->BE4_SIGEXE )
		oBD6:LoadValue("BD6_REGEXE", BE4->BE4_REGEXE )
		oBD6:LoadValue("BD6_CDPFRE", BE4->BE4_CDPFRE )
		oBD6:LoadValue("BD6_OPEEXE", BE4->BE4_OPEEXE )	
		oBD6:LoadValue("BD6_CODRDA", BE4->BE4_CODRDA )
		oBD6:LoadValue("BD6_NOMRDA", left(BE4->BE4_NOMRDA, TamSx3("BD6_NOMRDA")[1])) //BD5->BD5_NOMRDA )
		//oBD6:LoadValue("BD6_TIPRDA", BE4->BE4_TIPRDA )
		oBD6:LoadValue("BD6_CODLOC", BE4->BE4_CODLOC )
		oBD6:LoadValue("BD6_LOCAL" , BE4->BE4_LOCAL  )
		//oBD6:LoadValue("BD6_CPFRDA", BE4->BE4_CPFRDA )
		//oBD6:LoadValue("BD6_DESLOC", BE4->BE4_DESLOC )
		//oBD6:LoadValue("BD6_ENDLOC", BE4->BE4_ENDLOC )
		oBD6:LoadValue("BD6_OPEUSR", BE4->BE4_OPEUSR )
		oBD6:LoadValue("BD6_MATANT", BE4->BE4_MATANT )
		oBD6:LoadValue("BD6_NOMUSR", BE4->BE4_NOMUSR )
		oBD6:LoadValue("BD6_CODEMP", BE4->BE4_CODEMP )
		oBD6:LoadValue("BD6_MATRIC", BE4->BE4_MATRIC )
		oBD6:LoadValue("BD6_TIPREG", BE4->BE4_TIPREG )
		oBD6:LoadValue("BD6_IDUSR" , BE4->BE4_IDUSR  )
		oBD6:LoadValue("BD6_DATNAS", BE4->BE4_DATNAS )
		oBD6:LoadValue("BD6_DIGITO", BE4->BE4_DIGITO )
		oBD6:LoadValue("BD6_CONEMP", BE4->BE4_CONEMP )
		oBD6:LoadValue("BD6_VERCON", BE4->BE4_VERCON )
		oBD6:LoadValue("BD6_SUBCON", BE4->BE4_SUBCON )
		oBD6:LoadValue("BD6_VERSUB", BE4->BE4_VERSUB )
		oBD6:LoadValue("BD6_MATVID", BE4->BE4_MATVID )
		oBD6:LoadValue("BD6_FASE"  , BE4->BE4_FASE   )
		oBD6:LoadValue("BD6_SITUAC", BE4->BE4_SITUAC )
		oBD6:LoadValue("BD6_NUMIMP", BE4->BE4_NUMIMP )
		oBD6:LoadValue("BD6_LOTGUI", BE4->BE4_LOTGUI )
		oBD6:LoadValue("BD6_TIPGUI", BE4->BE4_TIPGUI )
		oBD6:LoadValue("BD6_GUIORI", BE4->BE4_GUIORI )
		oBD6:LoadValue("BD6_DTDIGI", IIF(EmpTy(BE4->BE4_DTDIGI), date(), BE4->BE4_DTDIGI) )
		oBD6:LoadValue("BD6_MESPAG", BE4->BE4_MESPAG )
		oBD6:LoadValue("BD6_ANOPAG", BE4->BE4_ANOPAG )
		oBD6:LoadValue("BD6_MATUSA", BE4->BE4_MATUSA )
		oBD6:LoadValue("BD6_PACOTE", BE4->BE4_PACOTE )
		oBD6:LoadValue("BD6_ORIMOV", BE4->BE4_ORIMOV )
		oBD6:LoadValue("BD6_RGIMP" , BE4->BE4_RGIMP  )
		oBD6:LoadValue("BD6_CID"   , BE4->BE4_CID    )
		oBD6:LoadValue("BD6_TIPCON", BE4->BE4_TIPCON ) 
		oBD6:LoadValue("BD6_INTERC", If(BA3->BA3_CODEMP==cGrpEmpInt,"1","0") )
		oBD6:LoadValue("BD6_TIPUSR", BA3->BA3_TIPOUS )
		oBD6:LoadValue("BD6_MODCOB", Left(alltrim(BA3->BA3_MODPAG), TamSx3("BD6_MODCOB")[1])) 
		oBD6:LoadValue("BD6_CODPLA", BA3->BA3_CODPLA )
		oBD6:LoadValue("BD6_OPEORI", BA1->BA1_OPEORI )
	Else
		oBD6:LoadValue("BD6_CODESP", oBE4:getValue("BE4_CODESP"))
		oBD6:LoadValue("BD6_NRAOPE", oBE4:getValue("BE4_NRAOPE"))				
		oBD6:LoadValue("BD6_CODOPE", oBE4:getValue("BE4_CODOPE"))
		oBD6:LoadValue("BD6_CODLDP", oBE4:getValue("BE4_CODLDP"))
		oBD6:LoadValue("BD6_CODPEG", oBE4:getValue("BE4_CODPEG"))
		oBD6:LoadValue("BD6_NUMERO", oBE4:getValue("BE4_NUMERO")) 	
		oBD6:LoadValue("BD6_ESPSOL", oBE4:getValue("BE4_ESPSOL"))
		oBD6:LoadValue("BD6_ESTSOL", oBE4:getValue("BE4_ESTSOL"))
		oBD6:LoadValue("BD6_SIGLA" , oBE4:getValue("BE4_SIGLA"))
		oBD6:LoadValue("BD6_REGSOL", oBE4:getValue("BE4_REGSOL"))
		oBD6:LoadValue("BD6_NOMSOL", oBE4:getValue("BE4_NOMSOL")) 
		oBD6:LoadValue("BD6_CDPFSO", oBE4:getValue("BE4_CDPFSO"))
		oBD6:LoadValue("BD6_ESPEXE", oBE4:getValue("BE4_ESPEXE"))
		oBD6:LoadValue("BD6_ESTEXE", oBE4:getValue("BE4_ESTEXE"))
		//oBD6:LoadValue("BD6_SIGEXE", oBE4:getValue("BE4_SIGEXE"))
		oBD6:LoadValue("BD6_REGEXE", oBE4:getValue("BE4_REGEXE"))
		oBD6:LoadValue("BD6_CDPFRE", oBE4:getValue("BE4_CDPFRE"))
		oBD6:LoadValue("BD6_OPEEXE", oBE4:getValue("BE4_OPEEXE"))	
		oBD6:LoadValue("BD6_CODRDA", oBE4:getValue("BE4_CODRDA"))
		oBD6:LoadValue("BD6_NOMRDA", left(oBD5:getValue("BE4_NOMRDA"), TamSx3("BD6_NOMRDA")[1])) //oBD5:getValue("BD5_NOMRDA"))
		//oBD6:LoadValue("BD6_TIPRDA", oBE4:getValue("BE4_TIPRDA"))
		oBD6:LoadValue("BD6_CODLOC", oBE4:getValue("BE4_CODLOC"))
		oBD6:LoadValue("BD6_LOCAL" , oBE4:getValue("BE4_LOCAL"))
		//oBD6:LoadValue("BD6_CPFRDA", oBE4:getValue("BE4_CPFRDA"))
		//oBD6:LoadValue("BD6_DESLOC", oBE4:getValue("BE4_DESLOC"))
		//oBD6:LoadValue("BD6_ENDLOC", oBE4:getValue("BE4_ENDLOC"))
		oBD6:LoadValue("BD6_OPEUSR", oBE4:getValue("BE4_OPEUSR"))
		oBD6:LoadValue("BD6_MATANT", oBE4:getValue("BE4_MATANT"))
		oBD6:LoadValue("BD6_NOMUSR", oBE4:getValue("BE4_NOMUSR"))
		oBD6:LoadValue("BD6_CODEMP", oBE4:getValue("BE4_CODEMP"))
		oBD6:LoadValue("BD6_MATRIC", oBE4:getValue("BE4_MATRIC"))
		oBD6:LoadValue("BD6_TIPREG", oBE4:getValue("BE4_TIPREG"))
		oBD6:LoadValue("BD6_IDUSR" , oBE4:getValue("BE4_IDUSR"))
		oBD6:LoadValue("BD6_DATNAS", oBE4:getValue("BE4_DATNAS"))
		oBD6:LoadValue("BD6_DIGITO", oBE4:getValue("BE4_DIGITO"))
		oBD6:LoadValue("BD6_CONEMP", oBE4:getValue("BE4_CONEMP"))
		oBD6:LoadValue("BD6_VERCON", oBE4:getValue("BE4_VERCON"))
		oBD6:LoadValue("BD6_SUBCON", oBE4:getValue("BE4_SUBCON"))
		oBD6:LoadValue("BD6_VERSUB", oBE4:getValue("BE4_VERSUB"))
		oBD6:LoadValue("BD6_MATVID", oBE4:getValue("BE4_MATVID"))
		oBD6:LoadValue("BD6_FASE"  , oBE4:getValue("BE4_FASE"))
		oBD6:LoadValue("BD6_SITUAC", oBE4:getValue("BE4_SITUAC"))
		oBD6:LoadValue("BD6_NUMIMP", oBE4:getValue("BE4_NUMIMP"))
		oBD6:LoadValue("BD6_LOTGUI", oBE4:getValue("BE4_LOTGUI"))
		oBD6:LoadValue("BD6_TIPGUI", oBE4:getValue("BE4_TIPGUI"))
		oBD6:LoadValue("BD6_GUIORI", oBE4:getValue("BE4_GUIORI"))
		oBD6:LoadValue("BD6_DTDIGI", IIF( empTy(oBE4:getValue("BE4_DTDIGI")), Date(), oBE4:getValue("BE4_DTDIGI")))
		oBD6:LoadValue("BD6_MESPAG", oBE4:getValue("BE4_MESPAG"))
		oBD6:LoadValue("BD6_ANOPAG", oBE4:getValue("BE4_ANOPAG"))
		oBD6:LoadValue("BD6_MATUSA", oBE4:getValue("BE4_MATUSA"))
		oBD6:LoadValue("BD6_PACOTE", oBE4:getValue("BE4_PACOTE"))
		oBD6:LoadValue("BD6_ORIMOV", oBE4:getValue("BE4_ORIMOV"))
		oBD6:LoadValue("BD6_RGIMP" , oBE4:getValue("BE4_RGIMP"))
		oBD6:LoadValue("BD6_CID"   , oBE4:getValue("BE4_CID"))
		oBD6:LoadValue("BD6_TIPCON", oBE4:getValue("BE4_TIPCON")) 
	EndIf	
return

/*/{Protheus.doc} grvAltOdon
Metodo para gravação de alteração das guias odontologicas

@author Rodrigo Morgon
@since 11/07/2016
@version P12
/*/
method grvAltOdon(cRecno, aCamposCabec, aAddItem, aEditItem, aDelItem) class CO_Guia
	local oModel 		:= FWLoadModel("PLBD5MODEL")
	local oBD5 			:= oModel:GetModel("BD5Cab")
	local oBD6 			:= oModel:GetModel("BD6Proc")
	local nFor 			:= 0
	local lRet 			:= .T.
	local oObjBoGuia 	:= BO_Guia():New()
	local nI 			:= 1
	local nJ 			:= 1
	local nW 			:= 1
	local nA 			:= 0
	local nPosCodPad 	:= 0
	local nPosCodPro 	:= 0
	local nPosSeqMov 	:= 0
	local nPosDentReg	:= 0
	local nPosFace 		:= 0
	local aAuxBD7 		:= {}
	local aKeyDel 		:= {}
	local aDadTab 		:= {}
	local cSql			:= ""
	local cSeq			:= ""
	local aItens 		:= {}
    local cCodPro		:= ""
    local cCodPad		:= ""
    local cSequen		:= ""
	local cOriMov 		:= ""
	

	//Posiciona na BD5, caso ainda não esteja posicionado.
	if(cRecno != BD5->(recno()))
		BD5->(DbGoTo(cRecno))
	endif

	cOriMov := BD5->BD5_ORIMOV

	//Define a opção 4 para o model - alteração
	oModel:SetOperation(4)
	
	//Ativa o modelo
	oModel:Activate()
	
	//Para cada campo do cabecalho, carrega o valor na BD5
	for nFor := 1 to len(aCamposCabec)
		oBD5:LoadValue(aCamposCabec[nFor][1],aCamposCabec[nFor][2])
	next

	//Faço primeiro a edição e deleção dos itens para percorrer uma model de bd6 menor
	for nI := 1 to len(aDelItem)

		nPosCodPad 	:= aScan( aDelItem[nI], { |x| x[1] == "BD6_CODPAD" } )
		nPosCodPro 	:= aScan( aDelItem[nI], { |x| x[1] == "BD6_CODPRO" } )
		nPosDentReg	:= aScan( aDelItem[nI], { |x| x[1] == "BD6_DENREG" } )
		nPosFace	:= aScan( aDelItem[nI], { |x| x[1] == "BD6_FADENT" } )
		nPosSeqMov 	:= aScan( aDelItem[nI], { |x| x[1] == "BD6_SEQUEN" } ) 		
					
		if(nPosCodPad > 0 .and. nPosCodPro > 0 .and. nPosSeqMov > 0)		
			for nJ := 1 to oBD6:Length()					
				oBD6:GoLine( nJ ) 				
				if 	alltrim(oBD6:GetValue("BD6_CODPAD")) == alltrim(aDelItem[nI][nPosCodPad][2]) .AND. ;
					alltrim(oBD6:GetValue("BD6_CODPRO")) == alltrim(aDelItem[nI][nPosCodPro][2]) .AND. ;
					alltrim(oBD6:GetValue("BD6_DENREG")) == alltrim(aDelItem[nI][nPosDentReg][2]) .AND. ;
					alltrim(oBD6:GetValue("BD6_FADENT")) == alltrim(aDelItem[nI][nPosFace][2]) .AND. ;
					alltrim(oBD6:GetValue("BD6_SEQUEN")) == alltrim(aDelItem[nI][nPosSeqMov][2])
					
					oBD6:DeleteLine()
					aAdd(aKeyDel, BD5->(BD5_CODOPE+BD5_CODLDP+BD5_CODPEG+BD5_NUMERO+BD5_ORIMOV)+aDelItem[nI][nPosSeqMov][2])
				endIf				
			next nJ		
		endIf		
	next nI
	
	for nI := 1 to len(aEditItem)

		nPosCodPad 	:= aScan( aEditItem[nI][1], { |x| x[1] == "BD6_CODPAD" } )
		nPosCodPro 	:= aScan( aEditItem[nI][1], { |x| x[1] == "BD6_CODPRO" } )
		nPosDentReg	:= aScan( aEditItem[nI][1], { |x| x[1] == "BD6_DENREG" } )
		nPosFace	 	:= aScan( aEditItem[nI][1], { |x| x[1] == "BD6_FADENT" } )
		nPosSeqMov 	:= aScan( aEditItem[nI][1], { |x| x[1] == "BD6_SEQUEN" } )
		
		if(nPosCodPad > 0 .and. nPosCodPro > 0 .and. nPosDentReg > 0 .and. nPosFace > 0 .and. nPosSeqMov > 0)		
		
			for nJ := 1 to oBD6:Length()					
				oBD6:GoLine( nJ )
								
				if 	alltrim(oBD6:GetValue("BD6_CODPAD")) == alltrim(aEditItem[nI][1][nPosCodPad][2]) .AND. ;
					alltrim(oBD6:GetValue("BD6_CODPRO")) == alltrim(aEditItem[nI][1][nPosCodPro][2]) .AND. ;
					alltrim(oBD6:GetValue("BD6_DENREG")) == alltrim(aEditItem[nI][1][nPosDentReg][2]) .AND. ;
					alltrim(oBD6:GetValue("BD6_FADENT")) == alltrim(aEditItem[nI][1][nPosFace][2]) .AND. ;
					alltrim(oBD6:GetValue("BD6_SEQUEN")) == alltrim(aEditItem[nI][1][nPosSeqMov][2]) 
					
					//Preciso saber se o usuário editou o código do procedimento ou a tabela
					//pois nesse caso, é necessário excluir e inserir um novo
				if(aScan( aEditItem[nI][2], { |x| x[1] == "BD6_CODPAD" } ) > 0 .or. aScan( aEditItem[nI][2], { |x| x[1] == "BD6_CODPRO" } ) > 0)
					
						oBD6:DeleteLine()

						aAdd(aAddItem, aEditItem[nI][2])
						aAdd(aKeyDel, BD5->(BD5_CODOPE+BD5_CODLDP+BD5_CODPEG+BD5_NUMERO+BD5_ORIMOV)+aEditItem[nI][1][nPosSeqMov][2])

					else 								 

						for nW := 1 to len(aEditItem[nI][2])
							oBD6:LoadValue(aEditItem[nI][2][nW][1], aEditItem[nI][2][nW][2])	
						next nW
						
						self:copyIteOutDes(oBD6,oBD5)

					endIf

				endIf		
				
				if oObjBoGuia:verificaProc(aItens, cCodPad, cCodPro)
					aadd(aItens,  {{ "SEQMOV"	    ,  cSequen},;											
								   { "CODPAD"		,  cCodPad},;
								   { "CODPRO"		,  cCodPro},;
								   { "DESCRI"		, .F. 		 },;
								   { "QTD"		, oBD6:GetValue("BD6_QTDPRO") },;
								   { "QTDAUT"		, oBD6:GetValue("BD6_QTDPRO") },;
								   { "DENTE"		, oBD6:GetValue("BD6_DENREG") },;
								   { "FACE"		, oBD6:GetValue("BD6_FADENT") },;
								   { "STPROC"		, oBD6:GetValue("BD6_STATUS") }})
								   
					nA := len(aItens) 
					aItens[nA] := WsAutoOpc(aItens[nA])
				endif			   
														
			next nJ
		endIf
	next nI
	
	for nI := 1 to len(aAddItem)
	
		if oBD6:length() > 1 .or. !Empty(oBD6:getValue("BD6_CODPRO")) //Se o registro atual da model tiver o procedimento preenchido, adiciona novo.
			oBD6:AddLine()
		endif
		
		aAuxBD7 := {}
		
		for nJ := 1 to len(aAddItem[nI])
			oBD6:LoadValue(aAddItem[nI][nJ][1], aAddItem[nI][nJ][2])
		next nJ
			
    	oBD6:LoadValue("BD6_DESPRO",subStr(oObjBoGuia:getDescProcedimento(oBD6:getValue("BD6_CODPRO"), "",oBD6:getValue("BD6_CODPAD")),1,50))
    	self:copyIteOutDes(oBD6,oBD5)
		
		//garanto o sequen correto
		//não considero o D_E_L_E_T_ na query para nao dar problema no X2_UNICO que foi colocado na BD6 
		//para o primeiro item incluido ainda, os demais precisam seguir o primeiro+1
		if(nI == 1)
			cSql := "SELECT MAX(BD6_SEQUEN) AS MAXSEQ FROM " + RetSqlName("BD6") 			
			cSql += " WHERE BD6_FILIAL 	= '" + xFilial("BD6")  + "'"
			cSql += " AND BD6_CODOPE 	= '" + BD5->BD5_CODOPE + "'"
			cSql += " AND BD6_CODLDP 	= '" + BD5->BD5_CODLDP + "'"
			cSql += " AND BD6_CODPEG 	= '" + BD5->BD5_CODPEG + "'"
			cSql += " AND BD6_NUMERO 	= '" + BD5->BD5_NUMERO + "'"
			cSql += " AND BD6_ORIMOV 	= '" + BD5->BD5_ORIMOV + "'"

			cSql := ChangeQuery(cSql)	
			dbUseArea(.T.,"TOPCONN",TcGenQry(,,cSql),"TRBBD6",.T.,.F.)
			
			oBD6:LoadValue("BD6_SEQUEN", iif( TRBBD6->(!EOF()) ,Soma1( TRBBD6->MAXSEQ ), "001"))
			
			TRBBD6->(dbCloseArea())
		else
			cSeq := Soma1( cSeq )
			oBD6:LoadValue("BD6_SEQUEN", cSeq)
		endif
			
		cSeq := oBD6:GetValue("BD6_SEQUEN")
			
		aDadTab := oObjBoGuia:getDadTabela(oBD6:GetValue("BD6_CODPAD"),oBD6:GetValue("BD6_CODPRO"),;
								   oBD6:GetValue("BD6_DATPRO"),oBD6:GetValue("BD6_CODOPE"), oBD6:GetValue("BD6_CODRDA"),;
								   oBD6:GetValue("BD6_CODESP"),"",oBD6:GetValue("BD6_CODLOC"),oBD6:GetValue("BD6_LOCAL"),; 
								   oBD6:GetValue("BD6_OPEORI"), oBD6:GetValue("BD6_CODPLA"))

		if len(aDadTab) > 0
			oBD6:LoadValue("BD6_CODTAB",aDadTab[1])
		endif
	
		if len(aDadTab) > 1
			oBD6:LoadValue("BD6_ALIATB", aDadTab[2])
		endif
			
	aAdd(aAuxBD7,{	oBD6:GetValue("BD6_VLPGMA"),;
			oBD6:GetValue("BD6_CODPAD"),;	
			oBD6:GetValue("BD6_CODPRO"),;	
			oBD6:GetValue("BD6_CODTAB"),;	
		 	oBD6:GetValue("BD6_CODOPE"),;	
		 	oBD6:GetValue("BD6_CODRDA"),;	
		 	oBD6:GetValue("BD6_REGEXE"),;	
		 	oBD6:GetValue("BD6_SIGEXE"),;	
			oBD6:GetValue("BD6_ESTEXE"),;	
			oBD6:GetValue("BD6_CDPFRE"),;	
			oBD6:GetValue("BD6_CODESP"),;	
			oBD6:GetValue("BD6_CODLOC"),;	
			oBD6:GetValue("BD6_LOCAL"),;	
			oBD6:GetValue("BD6_SEQUEN"),;	
	      	oBD6:GetValue("BD6_DATPRO")})	   
			
		if oObjBoGuia:verificaProc(aItens, cCodPad, cCodPro)
	
			aadd(aItens,  {{ "SEQMOV"	    , oBD6:GetValue("BD6_SEQUEN") },;											
						   { "CODPAD"		, oBD6:GetValue("BD6_CODPAD") },;
						   { "CODPRO"		, oBD6:GetValue("BD6_CODPRO") },;
						   { "DESCRI"		, .F. 		 },;
						   { "QTD"		, oBD6:GetValue("BD6_QTDPRO") },;
						   { "QTDAUT"		, oBD6:GetValue("BD6_QTDPRO") },;
						   { "DENTE"		, oBD6:GetValue("BD6_DENREG") },;
						   { "FACE"		, oBD6:GetValue("BD6_FADENT") },;
						   { "STPROC"		, oBD6:GetValue("BD6_STATUS") }})	
						   
			aItens[nI] := WsAutoOpc(aItens[nI])
		endif    						
	
	next nI
	
	if oModel:VldData()
	
		oModel:CommitData()
	
		Begin Transaction			
	
			for nI := 1 to len(aAuxBD7)		
					
					PLS720IBD7(	{},aAuxBD7[nI][1],aAuxBD7[nI][2],aAuxBD7[nI][3],aAuxBD7[nI][4],;
			  					aAuxBD7[nI][5],aAuxBD7[nI][6],aAuxBD7[nI][7],aAuxBD7[nI][8],;
								aAuxBD7[nI][9],aAuxBD7[nI][10],aAuxBD7[nI][11],;
								aAuxBD7[nI][12]+aAuxBD7[nI][13],"1", aAuxBD7[nI][14],;
								cOriMov,BD5->BD5_TIPGUI,aAuxBD7[nI][15],,,,,,,,,{},,.F.)
			next nI
			
			BD7->(DbSetOrder(1))
		
			for nI := 1 to Len(aKeyDel)			
		
				If BD7->(MsSeek(xFilial("BD7")+aKeyDel[nI]))
		
				While ! BD7->(Eof()) .And. BD7->(BD7_FILIAL+BD7_CODOPE+BD7_CODLDP+BD7_CODPEG+BD7_NUMERO+BD7_ORIMOV+BD7_SEQUEN) == xFilial("BD7")+aKeyDel[nI]
				                                        
						BD7->(Reclock("BD7",.F.))
							BD7->(DbDelete())
						BD7->(MsUnlock())
						
						BD7->(DbSkip())
					EndDo	
				EndIf			
			next nI			
		
		End Transaction
	
	else	
		lRet := .F.	
		VarInfo("",oModel:GetErrorMessage())	
	endif
	
	oModel:DeActivate()
	
return IIF(lRet,alltrim(BD5->BD5_CODOPE) + alltrim(BD5->BD5_ANOAUT) + alltrim(BD5->BD5_MESAUT) + alltrim(BD5->BD5_NUMAUT),"")

/*/{Protheus.doc} grvAltSadt
Metodo para gravação de alteração das guias sadt

@author Karine Riquena Limp
@since 28/08/2016
@version P12
/*/
method grvAltSadt(cRecno, aCamposCabec, aAddItem, aEditItem, aDelItem) class CO_Guia
local oModel 	 := FWLoadModel("PLBD5MODEL")
local oBD5 	 	 := oModel:GetModel("BD5Cab")
local oBD6 	 	 := oModel:GetModel("BD6Proc")
local nFor	 	 := 0
local lRet	 	 := .t.
local oObjBoGuia := BO_Guia():New()
local nI 		 := 1
local nJ 		 := 1
local nW 		 := 1
local nA		 := 0
local nPosCodPad := 0
local nPosCodPro := 0
local nPosSeqMov := 0
local aAuxBD7 	 := {}
local aKeyDel 	 := {}
local aDadTab 	 := {}
local cSql		 := ""
local cSeq		 := ""
local oBO_Guia	 := BO_Guia():New()
local aItens 	 := {}
local cCodPro	 := ""
local cCodPad	 := ""
local cSequen	 := ""
local cOriMov 	 := ""
	
//Posiciona na BD5, caso ainda não esteja posicionado.
if(cRecno != BD5->(recno()))
	BD5->(DbGoTo(cRecno))
endif

//Para garantir o local correto de origem por causa das guias
cOriMov := BD5->BD5_ORIMOV

//Define a opção 4 para o model - alteração
oModel:setOperation(4)

//Ativa o modelo
oModel:activate()

//Para cada campo do cabecalho, carrega o valor na BD5
for nFor := 1 to len(aCamposCabec)

	if(valtype(aCamposCabec[nFor][2]) == "C")
		aCamposCabec[nFor][2] := left(alltrim(aCamposCabec[nFor][2]), TamSx3(aCamposCabec[nFor][1])[1])
	endIf
	
	oBD5:LoadValue(aCamposCabec[nFor][1],aCamposCabec[nFor][2])

next

//Faço primeiro a edição e deleção dos itens para percorrer uma model de bd6 menor
for nI := 1 to len(aDelItem)

	nPosCodPad 	:= aScan( aDelItem[nI], { |x| x[1] == "BD6_CODPAD" } )
	nPosCodPro 	:= aScan( aDelItem[nI], { |x| x[1] == "BD6_CODPRO" } )
	nPosSeqMov 	:= aScan( aDelItem[nI], { |x| x[1] == "BD6_SEQUEN" } ) 		
				
	if(nPosCodPad > 0 .and. nPosCodPro > 0 .and. nPosSeqMov > 0)		

		for nJ := 1 to oBD6:Length()					

			oBD6:GoLine( nJ ) 				

			if 	alltrim(oBD6:GetValue("BD6_CODPAD")) == alltrim(aDelItem[nI][nPosCodPad][2]) .AND. ;
				alltrim(oBD6:GetValue("BD6_CODPRO")) == alltrim(aDelItem[nI][nPosCodPro][2]) .AND. ;
				alltrim(oBD6:GetValue("BD6_SEQUEN")) == alltrim(aDelItem[nI][nPosSeqMov][2])
				
				oBD6:DeleteLine()
				aAdd(aKeyDel, BD5->(BD5_CODOPE+BD5_CODLDP+BD5_CODPEG+BD5_NUMERO+BD5_ORIMOV)+aDelItem[nI][nPosSeqMov][2])
			endIf				
		
		next nJ		
	
	endIf	

next nI

for nI := 1 to len(aEditItem)

	nPosCodPad 	:= aScan( aEditItem[nI][1], { |x| x[1] == "BD6_CODPAD" } )
	nPosCodPro 	:= aScan( aEditItem[nI][1], { |x| x[1] == "BD6_CODPRO" } )
	nPosSeqMov 	:= aScan( aEditItem[nI][1], { |x| x[1] == "BD6_SEQUEN" } )
	
	if(nPosCodPad > 0 .and. nPosCodPro > 0 .and. nPosSeqMov > 0)		

		for nJ := 1 to oBD6:Length()					

			oBD6:GoLine( nJ )
							
			if 	alltrim(oBD6:GetValue("BD6_CODPAD")) == alltrim(aEditItem[nI][1][nPosCodPad][2]) .and. ;
				alltrim(oBD6:GetValue("BD6_CODPRO")) == alltrim(aEditItem[nI][1][nPosCodPro][2]) .and. ;
				alltrim(oBD6:GetValue("BD6_SEQUEN")) == alltrim(aEditItem[nI][1][nPosSeqMov][2]) 
				
				cCodPro := oBD6:GetValue("BD6_CODPRO")
				cCodPad := oBD6:GetValue("BD6_CODPAD")
				cSequen := oBD6:GetValue("BD6_SEQUEN")
			
				//Preciso saber se o usuário editou o código do procedimento ou a tabela
				//pois nesse caso, é necessário excluir e inserir um novo
			if(aScan( aEditItem[nI][2], { |x| x[1] == "BD6_CODPAD" } ) > 0 .or.aScan( aEditItem[nI][2], { |x| x[1] == "BD6_CODPRO" } ) > 0)
									
				    nPosCodPad2 	:= aScan( aEditItem[nI][2], { |x| x[1] == "BD6_CODPAD" } )
				    nPosCodPro2 	:= aScan( aEditItem[nI][2], { |x| x[1] == "BD6_CODPRO" } )
	
				    cCodPro := aEditItem[nI][2][nPosCodPro2][2]
				    cCodPad := aEditItem[nI][2][nPosCodPad2][2]

					oBD6:DeleteLine()
					aAdd(aAddItem, aEditItem[nI][2])
					aAdd(aKeyDel, BD5->(BD5_CODOPE+BD5_CODLDP+BD5_CODPEG+BD5_NUMERO+BD5_ORIMOV)+aEditItem[nI][1][nPosSeqMov][2])

				else 								 

					for nW := 1 to len(aEditItem[nI][2])

						if(aEditItem[nI][2][nW][1] != "TELA_SEQ")
							oBD6:LoadValue(aEditItem[nI][2][nW][1], aEditItem[nI][2][nW][2])
						endif	
					
					next nW
					
					self:copyIteOutDes(oBD6,oBD5)
				endIf
			
			endIf	

			if oObjBoGuia:verificaProc(aItens, cCodPad, cCodPro)
		
				aadd(aItens,  {{ "SEQMOV"	    ,  cSequen},;											
							   { "CODPAD"		,  cCodPad},;
							   { "CODPRO"		,  cCodPro},;
							   { "DESCRI"		, .F. 		 },;
							   { "QTD"		, oBD6:GetValue("BD6_QTDPRO") },;
							   { "QTDAUT"		, oBD6:GetValue("BD6_QTDPRO") },;
							   { "DENTE"		, oBD6:GetValue("BD6_DENREG") },;
							   { "FACE"		, oBD6:GetValue("BD6_FADENT") },;
							   { "STPROC"		, oBD6:GetValue("BD6_STATUS") }})
							   
				nA := len(aItens) 
				aItens[nA] := WsAutoOpc(aItens[nA])
			endif			   
									
		next nJ
	endIf
next nI

//Isso é uma solução temporária!!
//Os valores dos campos abaixo estão chegando em branco na gravação, o que faz dar a crítica 540 (erro controlado)
//Estamos pegando os alores do primeiro procediemento (que sempre vai existir na alteração) para replicar nos registros que forem adicionados
//quando encontrarmos um lugar melhor para aplicar esse tratamento, remover ele daqui
nBkpLinZZ	:= oBD6:GetLine()
oBD6:GoLine(1)

aBkpZZZ :=	{oBD6:GetValue("BD6_INTERC"), oBD6:getValue("BD6_TIPUSR"), oBD6:getValue("BD6_MODCOB"), oBD6:getValue("BD6_CODPLA"), oBD6:getValue("BD6_OPEORI")}	
oBD6:GoLine(nBkpLinZZ)

aAuxBD7 := {}

for nI := 1 to len(aAddItem)

	if oBD6:length() > 1 .or. ! empty(oBD6:getValue("BD6_CODPRO")) //Se o registro atual da model tiver o procedimento preenchido, adiciona novo.
		oBD6:AddLine()
	endif
	
	for nJ := 1 to len(aAddItem[nI])
	
		if(aAddItem[nI][nJ][1] != "TELA_SEQ")
			oBD6:LoadValue(aAddItem[nI][nJ][1], aAddItem[nI][nJ][2])
		endif
	
	next nJ
		
	oBD6:LoadValue("BD6_DESPRO",subStr(oObjBoGuia:getDescProcedimento(oBD6:getValue("BD6_CODPRO"), "",oBD6:getValue("BD6_CODPAD")),1,50))
	
	self:copyIteOutDes(oBD6,oBD5)
	
	//garanto o sequen correto
	//não considero o D_E_L_E_T_ na query para nao dar problema no X2_UNICO que foi colocado na BD6 
	//para o primeiro item incluido ainda, os demais precisam seguir o primeiro+1
	if(nI == 1)
		cSql := "SELECT MAX(BD6_SEQUEN) AS MAXSEQ FROM " + RetSqlName("BD6") 
		cSql += " WHERE BD6_FILIAL 	= '" + xFilial("BD6")  + "'"
		cSql += " AND BD6_CODOPE 	= '" + BD5->BD5_CODOPE + "'"
		cSql += " AND BD6_CODLDP 	= '" + BD5->BD5_CODLDP + "'"
		cSql += " AND BD6_CODPEG 	= '" + BD5->BD5_CODPEG + "'"
		cSql += " AND BD6_NUMERO 	= '" + BD5->BD5_NUMERO + "'"
		cSql += " AND BD6_ORIMOV 	= '" + BD5->BD5_ORIMOV + "'"
		
		dbUseArea(.T.,"TOPCONN",TcGenQry(,,ChangeQuery(cSql)),"TRBBD6",.T.,.F.)
		
		oBD6:LoadValue("BD6_SEQUEN", iif( TRBBD6->(!EOF()) ,Soma1( TRBBD6->MAXSEQ ), "001"))
		
		TRBBD6->(dbCloseArea())
	else
		cSeq := Soma1( cSeq )
		oBD6:LoadValue("BD6_SEQUEN", cSeq)
	endif
		
	cSeq 	:= oBD6:GetValue("BD6_SEQUEN")
		
	aDadTab := oObjBoGuia:getDadTabela(	oBD6:GetValue("BD6_CODPAD"),oBD6:GetValue("BD6_CODPRO"),;
							   			oBD6:GetValue("BD6_DATPRO"),oBD6:GetValue("BD6_CODOPE"), oBD6:GetValue("BD6_CODRDA"),;
							   			oBD6:GetValue("BD6_CODESP"),"",oBD6:GetValue("BD6_CODLOC"),oBD6:GetValue("BD6_LOCAL"),; 
							   			oBD6:GetValue("BD6_OPEORI"), oBD6:GetValue("BD6_CODPLA"))

	if len(aDadTab) > 0
		oBD6:LoadValue("BD6_CODTAB",aDadTab[1])
	endif

	if len(aDadTab) > 1
		oBD6:LoadValue("BD6_ALIATB", aDadTab[2])
	endif
		
	aAdd(aAuxBD7,{	oBD6:GetValue("BD6_VLPGMA"),;
					oBD6:GetValue("BD6_CODPAD"),;	
					oBD6:GetValue("BD6_CODPRO"),;	
					oBD6:GetValue("BD6_CODTAB"),;	
			 		oBD6:GetValue("BD6_CODOPE"),;	
			 		oBD6:GetValue("BD6_CODRDA"),;	
			 		oBD6:GetValue("BD6_REGEXE"),;	
			 		oBD6:GetValue("BD6_SIGEXE"),;	
					oBD6:GetValue("BD6_ESTEXE"),;	
					oBD6:GetValue("BD6_CDPFRE"),;	
					oBD6:GetValue("BD6_CODESP"),;	
					oBD6:GetValue("BD6_CODLOC"),;	
					oBD6:GetValue("BD6_LOCAL"),;	
					oBD6:GetValue("BD6_SEQUEN"),;	
		      		oBD6:GetValue("BD6_DATPRO")})	      		
      	
	oBD6:LoadValue("BD6_INTERC", aBkpZZZ[1])
	oBD6:LoadValue("BD6_TIPUSR", aBkpZZZ[2])
	oBD6:LoadValue("BD6_MODCOB", aBkpZZZ[3])
	oBD6:LoadValue("BD6_CODPLA", aBkpZZZ[4])
	oBD6:LoadValue("BD6_OPEORI", aBkpZZZ[5])
	oBD6:LoadValue("BD6_VALORI", oBD6:getvalue("BD6_QTDPRO") * oBD6:getValue("BD6_VLRAPR") )
	 
	if oObjBoGuia:verificaProc(aItens, cCodPad, cCodPro)

			aadd(aItens,  {{ "SEQMOV"	, oBD6:GetValue("BD6_SEQUEN") },;											
						   { "CODPAD"	, oBD6:GetValue("BD6_CODPAD") },;
						   { "CODPRO"	, oBD6:GetValue("BD6_CODPRO") },;
						   { "DESCRI"	, .f. 		 },;
						   { "QTD"		, oBD6:GetValue("BD6_QTDPRO") },;
						   { "QTDAUT"	, oBD6:GetValue("BD6_QTDPRO") },;
						   { "DENTE"	, oBD6:GetValue("BD6_DENREG") },;
						   { "FACE"		, oBD6:GetValue("BD6_FADENT") },;
						   { "STPROC"	, oBD6:GetValue("BD6_STATUS") }})	
						   
		   aItens[nI] := WsAutoOpc(aItens[nI])

	endIf

next nI

if len(aItens) > 0 

	oBO_Guia:addExcLib(BD5->(BD5_CODOPE + BD5_CODLDP + BD5_CODPEG + BD5_NUMERO + BD5_ORIMOV), BD5->BD5_NRLBOR)
	
	oBO_Guia:baixaLib(aItens, "1",BD5->BD5_NRLBOR, .F., .F., BD5->(BD5_OPEUSR+BD5_CODEMP+BD5_MATRIC+BD5_TIPREG), BD5->BD5_CODLOC, BD5->BD5_HORPRO, "", "", BD5->BD5_NOMUSR, "2",;
		 				BD5->BD5_DATPRO, BD5->BD5_DATNAS, .F., .F., .F., BD5->BD5_OPEMOV, BD5->BD5_CODRDA, BD5->BD5_CODRDA, BD5->BD5_CODLOC, BD5->BD5_CODLOC, BD5->BD5_CODESP,  "",;
		 				.F., "", .F., .F., .F., alltrim(str(val(BD5->BD5_TIPGUI))), "", BD5->BD5_CODESP, BD5->BD5_CODESP, .F., .F., .F., BD5->BD5_TIPGUI)
	
endIf

if oModel:VldData()

	oModel:CommitData()

	Begin Transaction			
	
		for nI := 1 to len(aAuxBD7)		
			
			//seekar por cada item da bd6
			BD6->(DbSetOrder(1))
			if BD6->(msSeek(xFilial("BD6")+BD5->(BD5_CODOPE+BD5_CODLDP+BD5_CODPEG+BD5_NUMERO+BD5_ORIMOV)+aAuxBD7[nI][14]+aAuxBD7[nI][2]+aAuxBD7[nI][3]))							
			
				PLS720IBD7({},aAuxBD7[nI][1],aAuxBD7[nI][2],aAuxBD7[nI][3],aAuxBD7[nI][4],;
						       aAuxBD7[nI][5],aAuxBD7[nI][6],aAuxBD7[nI][7],aAuxBD7[nI][8],;
						       aAuxBD7[nI][9],aAuxBD7[nI][10],aAuxBD7[nI][11],;
						       aAuxBD7[nI][12]+aAuxBD7[nI][13],"1", aAuxBD7[nI][14],;
     						   cOriMov,BD5->BD5_TIPGUI,aAuxBD7[nI][15],,,,,,,,,{},,.F.)
     		endif
     						  	
		next nI
		
		BD7->(DbSetOrder(1))
		for nI := 1 to Len(aKeyDel)			
		
			If BD7->(MsSeek(xFilial("BD7")+aKeyDel[nI]))
			
				While ! BD7->(Eof()) .And. BD7->(BD7_FILIAL+BD7_CODOPE+BD7_CODLDP+BD7_CODPEG+BD7_NUMERO+BD7_ORIMOV+BD7_SEQUEN) == xFilial("BD7")+aKeyDel[nI]
			                                        
					BD7->(Reclock("BD7",.F.))
						BD7->(DbDelete())
					BD7->(MsUnlock())
					
					BD7->(DbSkip())
				EndDo	
			
			EndIf			
		
		next nI			
	
	End Transaction
else	
	lRet := .F.	
	VarInfo("",oModel:GetErrorMessage())	
endif

oModel:DeActivate()

return IIF(lRet,alltrim(BD5->BD5_CODOPE) + "." + alltrim(BD5->BD5_ANOAUT) + "." + alltrim(BD5->BD5_MESAUT) + "-" + alltrim(BD5->BD5_NUMAUT),"")


/*/{Protheus.doc} grvAltHon
Metodo para gravação de alteração das guias honorario e resumo de internação

@author Karine Riquena Limp
@since 28/08/2016
@version P12
/*/
method grvAltHon(cRecno, aCamposCabec, aAddItem, aEditItem, aDelItem, aAddExec, aDelExec, cTpGui) class CO_Guia
local oModel		:= nil
local oCab			:= nil
local oBD6			:= {}
local nFor			:= 0
local lRet 			:= .T.
local oObjBoGuia 	:= BO_Guia():New()
local nI 			:= 1
local nJ 			:= 1
local nW 			:= 1
local nV 			:= 1
local nPosCodPad 	:= 0
local nPosCodPro 	:= 0
local nPosSeqMov 	:= 0
local nPosTelaSeq 	:= 0
local aAuxBD7 		:= {}
local aPartic 		:= {}
local aKeyDel 		:= {}
local aDadTab 		:= {}
local aExecAdd		:= {}
local aExecDel		:= {}
local aAuxExecAdd	:= {}
local aAuxExecDel	:= {}
local aVetTab		:= {}
local cSql			:= ""
local cSeq			:= ""
local cCodOpe		:= ""
local cCodLdp		:= ""
local cCodPeg		:= ""
local cNumero		:= ""
local cOrimov		:= ""
local cAnoAut		:= ""
local cMesAut		:= ""
local cNumAut		:= ""
local cCodEsp		:= ""
local cCodCbo 		:= ""
local cType			:= ""
local cBD6PArt		:= ""
local nBkpLinZZ 	:= 0
local lVerSql		:= .F.
Local aBKCInfo		:= {}
local nTam			:= 0

	if(cTpGui != "5")
	
		oModel := FWLoadModel("PLBD5MODEL")
		oCab := oModel:GetModel("BD5Cab")
		oBD6 := oModel:GetModel("BD6Proc")
		oBD7 := oModel:GetModel("BD7Part")
	
		//Posiciona na BD5, caso ainda não esteja posicionado.
		if(cRecno != BD5->(recno()))
			BD5->(DbGoTo(cRecno))
		endif
	
		cCodOpe	:=  BD5->BD5_CODOPE
		cCodLdp	:=  BD5->BD5_CODLDP
		cCodPeg	:=  BD5->BD5_CODPEG
		cNumero	:=  BD5->BD5_NUMERO
		cOrimov	:=  BD5->BD5_ORIMOV
		cAnoAut	:=  BD5->BD5_ANOAUT
		cMesAut	:=  BD5->BD5_MESAUT
		cNumAut	:=  BD5->BD5_NUMAUT

	else
	
		oModel := FWLoadModel("PLBE4MODEL")
		oCab := oModel:GetModel("BE4Cab")
		oBD6 := oModel:GetModel("BD6Proc")
		
		//Posiciona na BE4, caso ainda não esteja posicionado.
		if(cRecno != BE4->(recno()))
			BE4->(DbGoTo(cRecno))
		endif
		
		 cCodOpe	:=  BE4->BE4_CODOPE
		 cCodLdp	:=  BE4->BE4_CODLDP
		 cCodPeg	:=  BE4->BE4_CODPEG
		 cNumero	:=  BE4->BE4_NUMERO
		 cOrimov	:=  BE4->BE4_ORIMOV
		 cAnoAut	:=  BE4->BE4_ANOINT
		 cMesAut	:=  BE4->BE4_MESINT
		 cNumAut	:=  BE4->BE4_NUMINT

	endif

	
	//Define a opção 4 para o model - alteração
	oModel:SetOperation(4)
	
	//Ativa o modelo
	oModel:Activate()
	
	//Para cada campo do cabecalho, carrega o valor na BD5/BE4
	for nFor := 1 to len(aCamposCabec)
		
		cType := valtype(aCamposCabec[nFor][2])
		
		if(cType  == "C") .and. valType(&( iif(cTpGui != "5","BD5->", "BE4->") + aCamposCabec[nFor][1])) <> "D"
			aCamposCabec[nFor][2] := left(alltrim(aCamposCabec[nFor][2]), TamSx3(aCamposCabec[nFor][1])[1])
		endIf
		
		if valType(&( iif(cTpGui != "5","BD5->", "BE4->") + aCamposCabec[nFor][1])) == "D" .and. cType <> "D"
			aCamposCabec[nFor][2] := ctod(aCamposCabec[nFor][2])
		endIf
		
		oCab:LoadValue(aCamposCabec[nFor][1],aCamposCabec[nFor][2])
	next

	//Faço primeiro a edição e deleção dos itens para percorrer uma model de bd6 menor
	for nI := 1 to len(aDelItem)

		nPosCodPad 	:= aScan( aDelItem[nI], { |x| x[1] == "BD6_CODPAD" } )
		nPosCodPro 	:= aScan( aDelItem[nI], { |x| x[1] == "BD6_CODPRO" } )
		nPosSeqMov 	:= aScan( aDelItem[nI], { |x| x[1] == "BD6_SEQUEN" } ) 		
					
		if(nPosCodPad > 0 .and. nPosCodPro > 0 .and. nPosSeqMov > 0)		

			for nJ := 1 to oBD6:Length()					

				oBD6:GoLine( nJ ) 				

				if 	alltrim(oBD6:GetValue("BD6_CODPAD")) == alltrim(aDelItem[nI][nPosCodPad][2]) .AND. ;
					alltrim(oBD6:GetValue("BD6_CODPRO")) == alltrim(aDelItem[nI][nPosCodPro][2]) .AND. ;
					alltrim(oBD6:GetValue("BD6_SEQUEN")) == alltrim(aDelItem[nI][nPosSeqMov][2])
					
					oBD6:DeleteLine()
					aAdd(aKeyDel, cCodOpe+cCodLdp+cCodPeg+cNumero+cOrimov+aDelItem[nI][nPosSeqMov][2])
																			
				endIf				
			
			next nJ		
		
		endIf	

	next nI
	
	for nI := 1 to len(aEditItem)
	   
	   aAuxBD7 := {}
	   
	    //pego a chave do procedimento, que é sempre a primeira posição do item editado
		nPosCodPad 	:= aScan( aEditItem[nI][1], { |x| x[1] == "BD6_CODPAD" } )
		nPosCodPro 	:= aScan( aEditItem[nI][1], { |x| x[1] == "BD6_CODPRO" } )
		nPosSeqMov 	:= aScan( aEditItem[nI][1], { |x| x[1] == "BD6_SEQUEN" } )
		nPosTelaSeq	:= aScan( aEditItem[nI][2], { |x| x[1] == "TELA_SEQ" } )
		
		if(nPosCodPad > 0 .and. nPosCodPro > 0 .and. nPosSeqMov > 0)		
	
			for nJ := 1 to oBD6:Length()					
	
				oBD6:GoLine( nJ )
								
				if 	alltrim(oBD6:GetValue("BD6_CODPAD")) == alltrim(aEditItem[nI][1][nPosCodPad][2]) .AND. ;
					alltrim(oBD6:GetValue("BD6_CODPRO")) == alltrim(aEditItem[nI][1][nPosCodPro][2]) .AND. ;
					alltrim(oBD6:GetValue("BD6_SEQUEN")) == STRZERO(Val(alltrim(aEditItem[nI][1][nPosSeqMov][2])), 3) 
					
					
					//Preciso saber se o usuário editou o código do procedimento ou a tabela
					//pois nesse caso, é necessário excluir e inserir um novo
				if(aScan( aEditItem[nI][2], { |x| x[1] == "BD6_CODPAD" } ) > 0 .or. aScan( aEditItem[nI][2], { |x| x[1] == "BD6_CODPRO" } ) > 0)
					
						oBD6:DeleteLine()
					
						aAdd(aAddItem, aEditItem[nI][2])
						aAdd(aKeyDel,cCodOpe+cCodLdp+cCodPeg+cNumero+cOrimov+aEditItem[nI][1][nPosSeqMov][2])					
											
					else 								 
						for nW := 1 to len(aEditItem[nI][2])

							if(aEditItem[nI][2][nW][1] != "TELA_SEQ")
								oBD6:LoadValue(aEditItem[nI][2][nW][1], aEditItem[nI][2][nW][2])	
							endIf

						next nW
						
						if(len(aAddExec) > 0)
						
						aAdd(aAuxBD7,{	oBD6:GetValue("BD6_CODPAD"),;
								oBD6:GetValue("BD6_CODPRO"),;							
								oBD6:GetValue("BD6_SEQUEN")})
							
							//verifico se tem algum executante adicionado vindo para esse procedimento
							//vou adicionar os campos necessários o array aExecAdd para rodar o PLSA720IBD7 depois
							aEval(aAddExec, { |x| iif(x[10] == strzero(val(aEditItem[nI][2][nPosTelaSeq][2]), 3),aAdd(aAuxExecAdd, aClone(x)),) } )
							
							if(aEditItem[nI][1][nPosSeqMov][2] != strzero(val(aEditItem[nI][2][nPosTelaSeq][2]), 3))
								self:addArrExec(@aAuxExecAdd, aEditItem[nI][1][nPosSeqMov][2])
							endIf
							
							aAdd(aExecAdd,{aAuxExecAdd, aAuxBD7})
							
							aAuxExecAdd := {}
							
						endIf
						
						if(len(aDelExec) > 0)
						
							aEval(aDelExec, { |x| iif(x[10] == strzero(val(aEditItem[nI][2][nPosTelaSeq][2]),3), aAdd(aAuxExecDel, aClone(x)), ) }) 
							
							for nV := 1 to len(aAuxExecDel)
								aAdd(aExecDel, cCodOpe+cCodLdp+cCodPeg+cNumero+cOrimov+aEditItem[nI][1][nPosSeqMov][2]+aAuxExecDel[nV][1]+aAuxExecDel[nV][9])
							next nV
							
						endIf
												
						if cTpGui <> "5"
							self:copyIteOutDes(oBD6)
						else
							self:copyIteResInt(oBD6)
						endIf	
																
					endIf
				endIf								
			next nJ
		endIf
	next nI
	
	//Isso é uma solução temporária!!
	//Os valores dos campos abaixo estão chegando em branco na gravação, o que faz dar a crítica 540 (erro controlado)
	//Estamos pegando os alores do primeiro procediemento (que sempre vai existir na alteração) para replicar nos registros que forem adicionados
	//quando encontrarmos um lugar melhor para aplicar esse tratamento, remover ele daqui
	nBkpLinZZ	:= oBD6:GetLine()
	oBD6:GoLine(1)

	aBkpZZZ :=	{oBD6:GetValue("BD6_INTERC"), oBD6:getValue("BD6_TIPUSR"), oBD6:getValue("BD6_MODCOB"), oBD6:getValue("BD6_CODPLA"), oBD6:getValue("BD6_OPEORI")}	
	oBD6:GoLine(nBkpLinZZ)
		
	for nI := 1 to len(aAddItem)
	
		aAuxBD7 := {}
		
		nPosTelaSeq	:= aScan( aAddItem[nI], { |x| x[1] == "TELA_SEQ" } )
		
		if oBD6:length() > 1 .or. !Empty(oBD6:getValue("BD6_CODPRO")) //Se o registro atual da model tiver o procedimento preenchido, adiciona novo.
			oBD6:AddLine()
		endif
		
		for nJ := 1 to len(aAddItem[nI])
			if(aAddItem[nI][nJ][1] != "TELA_SEQ")
				oBD6:LoadValue(aAddItem[nI][nJ][1], aAddItem[nI][nJ][2])
			endIf
		next nJ
			
    	oBD6:LoadValue("BD6_DESPRO",subStr(oObjBoGuia:getDescProcedimento(oBD6:getValue("BD6_CODPRO"), "",oBD6:getValue("BD6_CODPAD")),1,50))
    	
    	if cTpGui <> "5"
			self:copyIteOutDes(oBD6)
		else
			self:copyIteResInt(oBD6)
		endIf
		
		//garanto o sequen correto
		//não considero o D_E_L_E_T_ na query para nao dar problema no X2_UNICO que foi colocado na BD6 
		//para o primeiro item incluido ainda, os demais precisam seguir o primeiro+1
		if(nI == 1)
			cSql := "SELECT MAX(BD6_SEQUEN) AS MAXSEQ FROM " + RetSqlName("BD6") 
			cSql += " WHERE BD6_FILIAL 	= '" + xFilial("BD6")  + "'"
			cSql += " AND BD6_CODOPE 	= '" + cCodOpe + "'"
			cSql += " AND BD6_CODLDP 	= '" + cCodLdp + "'"
			cSql += " AND BD6_CODPEG 	= '" + cCodPeg + "'"
			cSql += " AND BD6_NUMERO 	= '" + cNumero + "'"
			cSql += " AND BD6_ORIMOV 	= '" + cOrimov + "'"
			
			cSql := ChangeQuery(cSql)	
			dbUseArea(.T.,"TOPCONN",TcGenQry(,,cSql),"TRBBD6",.T.,.F.)
			
			oBD6:LoadValue("BD6_SEQUEN", iif( TRBBD6->(!EOF()) ,Soma1( TRBBD6->MAXSEQ ), "001"))
			
			TRBBD6->(dbCloseArea())
		else
			cSeq := Soma1( cSeq )
			oBD6:LoadValue("BD6_SEQUEN", cSeq)
		endif
			
		cSeq := oBD6:GetValue("BD6_SEQUEN")
					
		aDadTab := oObjBoGuia:getDadTabela(oBD6:GetValue("BD6_CODPAD"),oBD6:GetValue("BD6_CODPRO"),;
								   oBD6:GetValue("BD6_DATPRO"),oBD6:GetValue("BD6_CODOPE"), oBD6:GetValue("BD6_CODRDA"),;
								   oBD6:GetValue("BD6_CODESP"),"",oBD6:GetValue("BD6_CODLOC"),oBD6:GetValue("BD6_LOCAL"),; 
								   oBD6:GetValue("BD6_OPEORI"), oBD6:GetValue("BD6_CODPLA"), "06")

		if len(aDadTab) > 0
			oBD6:LoadValue("BD6_CODTAB",aDadTab[1])
		endif
	
		if len(aDadTab) > 1
			oBD6:LoadValue("BD6_ALIATB", aDadTab[2])
		endif
		
		//campos da solução temporária
		oBD6:LoadValue("BD6_INTERC", aBkpZZZ[1])
		oBD6:LoadValue("BD6_TIPUSR", aBkpZZZ[2])
		oBD6:LoadValue("BD6_MODCOB", aBkpZZZ[3])
		oBD6:LoadValue("BD6_CODPLA", aBkpZZZ[4])
		oBD6:LoadValue("BD6_OPEORI", aBkpZZZ[5])
					
		if(len(aAddExec) > 0)
			
		aAdd(aAuxBD7,{	oBD6:GetValue("BD6_CODPAD"),;
				oBD6:GetValue("BD6_CODPRO"),;							
				oBD6:GetValue("BD6_SEQUEN")})	
	      	
	      	//verifico se tem algum executante adicionado vindo para esse procedimento
			//vou adicionar os campos necessários o array aExecAdd para rodar o PLSA720IBD7 depois
			aEval(aAddExec, { |x| iif(x[10] == cSeq .and. val(x[10]) == val(aAddItem[nI,nPosTelaSeq,2]), aAdd(aAuxExecAdd, aClone(x) ), )  })
									
			self:addArrExec(@aAuxExecAdd, cSeq)
							
			aAdd(aExecAdd,{aAuxExecAdd, aAuxBD7})
							
			aAuxExecAdd := {}
				      	
			//Ajuste necessário, pois caso tenhamos apenas um procedimento na guia, seja salva e depois excluído este procedimento, o sistema não encontrava mais o executante, pois o cSeq fica 002, de acordo com o banco e na tela, fica como 001.
			//Aqui embaixo, garantimos que caso ocorra essa situação, o sistema irá se comportar de maneira correta e gravar executantes.
			if ( len(aExecAdd[nI,1]) == 0 ) 
				
				nTam := len(aExecAdd)
				aDel(aExecAdd,nI)
				aSize(aExecAdd,nTam-1)
								
				aEval(aAddExec, { |x| iif(val(x[10]) == val(aAddItem[nI,nPosTelaSeq,2]), aAdd(aAuxExecAdd, aClone(x) ), )  })
				self:addArrExec(@aAuxExecAdd, cSeq)			
				aAdd(aExecAdd,{aAuxExecAdd, aAuxBD7})			
				aAuxExecAdd := {}
			endif
				      	 
		endIf    
	      						
	next nI
	
	if oModel:VldData()
		
		oModel:CommitData()
		
		Begin Transaction	
			
			//Gravação deve ser Diferente quando Resumo, pois nem sempre informo executantes e pdoe vir vazio ou parcial
			if cTpGui <> "5"
			
				for nI := 1 to len(aExecAdd)		
					
					aPartic := {}
					
					BD6->(DbSetOrder(1))
					if BD6->(msSeek(xFilial("BD6")+cCodOpe+cCodLdp+cCodPeg+cNumero+cOrimov+aExecAdd[nI][2][1][3]+aExecAdd[nI][2][1][1]+aExecAdd[nI][2][1][2]))
						
						aVetTab := oObjBoGuia:getDadTabela(BD6->BD6_CODPAD,BD6->BD6_CODPRO,;
									   BD6->BD6_DATPRO,BD6->BD6_CODOPE, BD6->BD6_CODRDA,;
									   BD6->BD6_CODESP,"",BD6->BD6_CODLOC,BD6->BD6_LOCAL,; 
									   BD6->BD6_OPEORI, BD6->BD6_CODPLA)
								
						for nJ := 1 to len(aExecAdd[nI][1])
					
							//tem algumas guias que o cbos na vdd vem com o codigo da BAQ, especialidade ai tenho como pegar o cbos
							//se vier o cbos não tenho como pegar qual é a especialidade pois há mais de uma especialidade para o mesmo cbos
							if(len(aExecAdd[nI][1][nJ][11]) == 3)
								cCodEsp := alltrim(aExecAdd[nI][1][nJ][11])
								cCodCbo := BAQ->(Posicione("BAQ",1,xFilial("BAQ")+BD6->BD6_OPERDA+cCodEsp,"BAQ_CBOS"))
							else						
								cCodEsp := ""
								cCodCbo := alltrim(aExecAdd[nI][1][nJ][11])
							endIf
	
						
						aadd(aPartic, {	aExecAdd[nI][1][nJ][1],;			//[1] BD7_CODTPA
									BD6->BD6_SEQUEN,;					//[2] BD7_SEQUEN
									BD6->(BD6_CODPAD+BD6_CODPRO),;	//[3] BD7_CODPAD + BD7_CODPRO
									0,;									//[4] 
									aExecAdd[nI][1][nJ][5],;			//[5] BD7_SIGLA
									aExecAdd[nI][1][nJ][4],;			//[6] BD7_REGPRE
									aExecAdd[nI][1][nJ][6],;			//[7] BD7_ESTPRE
									0,;									//[8]
									aExecAdd[nI][1][nJ][9],;			//[9]  BD7_CDPFPR
									BD6->BD6_CODRDA,;					//[10] BD7_CODRDA
									"",;								//[11] BD7_NOMRDA
									cCodEsp,;							//[12] BD7_ESPEXE
									PlRetUnp(aExecAdd[nI][1][nJ][1]),;								//[13] 
									cCodCbo})							//[14] BD7_CBOEXE
	
									
												
						next nJ
						
						PLS720IBD7({},BD6->BD6_VLPGMA,BD6->BD6_CODPAD,BD6->BD6_CODPRO,aVetTab[1],;
				  						BD6->BD6_CODOPE,BD6->BD6_CODRDA,BD6->BD6_REGEXE,BD6->BD6_SIGEXE,;
										BD6->BD6_ESTEXE,BD6->BD6_CDPFRE,BD6->BD6_CODESP,BD6->BD6_CODLOC+BD6->BD6_LOCAL,;
										"1", BD6->BD6_SEQUEN,BD6->BD6_ORIMOV, Iif(cTpGui == "6", "06","05") ,BD6->BD6_DATPRO,,,,,,,,;
										nil,aPartic,,Iif (cTpGui == "6",.T.,.F.))
						
					endIf  
						
				next nI
			
			Else													
				If !Empty(aExecAdd)
			
					for nI := 1 to len(aExecAdd)							
				
						aPartic  := {}		
						aBKCInfo := {}
						lVerSql  := .T.		
									
						BD6->(DbSetOrder(1))
						
						if BD6->(msSeek(xFilial("BD6")+cCodOpe+cCodLdp+cCodPeg+cNumero+cOrimov+aExecAdd[nI][2][1][3]+aExecAdd[nI][2][1][1]+aExecAdd[nI][2][1][2]))
						
							cBD6Part += AllTrim(STR(BD6->(RECNO()))) + ','		
							
							aVetTab := oObjBoGuia:getDadTabela(BD6->BD6_CODPAD,BD6->BD6_CODPRO,;
										   BD6->BD6_DATPRO,BD6->BD6_CODOPE, BD6->BD6_CODRDA,;
										   BD6->BD6_CODESP,"",BD6->BD6_CODLOC,BD6->BD6_LOCAL,; 
										   BD6->BD6_OPEORI, BD6->BD6_CODPLA)								
							
							for nJ := 1 to len(aExecAdd[nI][1])
							
								//Estava deletando todos os registros, condição para desviar caso seja outra participação.
								BD7->(DbSetOrder(15))		
								If BD7->(MsSeek(xFilial("BD7")+BD6->(BD6_CODOPE+BD6_CODLDP+BD6_CODPEG+BD6_NUMERO+BD6_ORIMOV+BD6_SEQUEN)))
								
									While ! BD7->(Eof()) .And. BD7->(BD7_FILIAL+BD7_CODOPE+BD7_CODLDP+BD7_CODPEG+BD7_NUMERO+BD7_ORIMOV+BD7_SEQUEN) == ;
										xFilial("BD7")+BD6->(BD6_CODOPE+BD6_CODLDP+BD6_CODPEG+BD6_NUMERO+BD6_ORIMOV+BD6_SEQUEN)     				                                       										
				                    
				                     //Aqui todos os BD7 são deletados para serem recriados considerando as participaçõe sinformadas.
				                     //o aBKCinfo vai guardar as informações pra sabermos qual posição do aPartic vai ir com executante informado.
				                    	if ( !empty(BD7->BD7_REGPRE) )
											aadd(aBKCInfo, {BD7->BD7_CODUNM, BD7->BD7_CODTPA, Len(aPartic) + 1, BD7->BD7_REGPRE, BD7->BD7_CDPFPR})
										else 					
											BD7->(Reclock("BD7",.F.))
												BD7->(DbDelete())
											BD7->(MsUnlock())
										endif										
										BD7->(DbSkip()) 
									EndDo	
								EndIf	
							
								//tem algumas guias que o cbos na vdd vem com o codigo da BAQ, especialidade ai tenho como pegar o cbos
								//se vier o cbos não tenho como pegar qual é a especialidade pois há mais de uma especialidade para o mesmo cbos
								if(len(aExecAdd[nI][1][nJ][11]) == 3)
									cCodEsp := alltrim(aExecAdd[nI][1][nJ][11])
									cCodCbo := BAQ->(Posicione("BAQ",1,xFilial("BAQ")+BD6->BD6_CODOPE+cCodEsp,"BAQ_CBOS"))
								else						
									cCodEsp := ""
									cCodCbo := alltrim(aExecAdd[nI][1][nJ][11])
								endIf
								
							   //Montar o aPartic
								aadd(aPartic, {	aExecAdd[nI][1][nJ][1],;			//[1] BD7_CODTPA
											BD6->BD6_SEQUEN,;					//[2] BD7_SEQUEN
											BD6->(BD6_CODPAD+BD6_CODPRO),;	    //[3] BD7_CODPAD + BD7_CODPRO
											0,;									//[4] 
											aExecAdd[nI][1][nJ][5],;			//[5] BD7_SIGLA
											aExecAdd[nI][1][nJ][4],;			//[6] BD7_REGPRE
											aExecAdd[nI][1][nJ][6],;			//[7] BD7_ESTPRE
											0,;									//[8]
											aExecAdd[nI][1][nJ][9],;			//[9]  BD7_CDPFPR
											BD6->BD6_CODRDA,;					//[10] BD7_CODRDA
											"",;								//[11] BD7_NOMRDA
											cCodEsp,;							//[12] BD7_ESPEXE
											PlRetUnp(aExecAdd[nI][1][nJ][1]),;								//[13] 
											cCodCbo})	
							next nJ
					
					
							PLS720IBD7({},BD6->BD6_VLPGMA,BD6->BD6_CODPAD,BD6->BD6_CODPRO,aVetTab[1],;
			  						BD6->BD6_CODOPE,BD6->BD6_CODRDA,BD6->BD6_REGEXE,BD6->BD6_SIGEXE,;
									BD6->BD6_ESTEXE,BD6->BD6_CDPFRE,BD6->BD6_CODESP,BD6->BD6_CODLOC+BD6->BD6_LOCAL,;
									"1", BD6->BD6_SEQUEN,BD6->BD6_ORIMOV, Iif(cTpGui == "6", "06","05") ,BD6->BD6_DATPRO,,,,,,,,;
									nil,aPartic,,.t.) 
					
						endIf  					
					next nI												
				
				Elseif ( Empty(aExecAdd) .Or. lVerSql )
				
					cAliBd6 := RetSqlname("BD6") 
				
					cSql := " SELECT BD6.R_E_C_N_O_ REC FROM " + cAliBd6 + " BD6 "
					cSql += " WHERE BD6_FILIAL = '" + xFilial("BD6") + "' AND "
					cSql += " BD6_CODOPE = '" + cCodOpe + "' AND "
					cSql += " BD6_CODLDP = '" + cCodLdp + "' AND "
					cSql += " BD6_CODPEG = '" + cCodPeg + "' AND "
					cSql += " BD6_NUMERO = '" + cNumero + "' AND "
					cSql += " BD6_ORIMOV = '" + cOrimov + "' AND "
				
					If lVerSql
						cBD6PArt := Left(cBD6PArt,Len(cBD6PArt)-1)//Retiro a vírgula
						cSql += " BD6.R_E_C_N_O_ NOT IN (" + cBD6PArt + ") AND "
					EndIf
					cSql += "BD6.D_E_L_E_T_ = '' "
				
				dbUseArea(.T.,"TOPCONN",TcGenQry(,,ChangeQuery(cSql)),"TRBD6IN",.T.,.F.)
					
					While !TRBD6IN->(Eof())
						
						BD6->(DbGoTo(TRBD6IN->REC))
						
						aVetTab := oObjBoGuia:getDadTabela(BD6->BD6_CODPAD,BD6->BD6_CODPRO,;
									BD6->BD6_DATPRO,BD6->BD6_CODOPE, BD6->BD6_CODRDA,;
									BD6->BD6_CODESP,"",BD6->BD6_CODLOC,BD6->BD6_LOCAL,; 
									BD6->BD6_OPEORI, BD6->BD6_CODPLA)
									
						If !(BD7->(MsSeek(xFilial("BD7")+BD6->(BD6_CODOPE+BD6_CODLDP+BD6_CODPEG+BD6_NUMERO+BD6_ORIMOV+BD6_SEQUEN))))
						
							PLS720IBD7({},BD6->BD6_VLPGMA,BD6->BD6_CODPAD,BD6->BD6_CODPRO,aVetTab[1],	BD6->BD6_CODOPE,BD6->BD6_CODRDA,BD6->BD6_REGEXE,BD6->BD6_SIGEXE,;
										 BD6->BD6_ESTEXE,BD6->BD6_CDPFRE,BD6->BD6_CODESP,BD6->BD6_CODLOC+BD6->BD6_LOCAL,"1", BD6->BD6_SEQUEN,BD6->BD6_ORIMOV,;
										 Iif(cTpGui == "6", "06","05") ,BD6->BD6_DATPRO,,,,,,,,nil,,,iif(Len(aPartic) == 0, .f., .t.))	//Se passar como true direto, no IBD7 verifica que não tem apartic e não grava
						EndIf
						TRBD6IN->(DbSkip())
					EndDo	
					TRBD6IN->(DbCloseArea())
				EndIf			
			EndIf
												
		End Transaction
	else	
		lRet := .F.	
		VarInfo("",oModel:GetErrorMessage())	
	endif
	
	oModel:DeActivate()
	
return IIF( lRet, alltrim(cCodOpe) + "." + cAnoAut + "." + cMesAut + "-" + cNumAut,"")

/*/{Protheus.doc} addArrExec
Adicionar os executantes que serão gravados e colocar o seqmov certo no apartic
@author Karine Riquena Limp
@since 25/05/2016
@version P12
/*/
method addArrExec(aAddExec, cSeqMov) class Co_Guia

local nI := 1

	for nI := 1 to len(aAddExec)
		aAddExec[nI][10] := cSeqMov	
	next nI

return

//-------------------------------------------------------------------
/*/{Protheus.doc} getProtoc
Busca o protocolo da guia
@author Francisco Edcarlo
@since 02/02/2017
@version P12
/*/
//-------------------------------------------------------------------
method getProtoc(cChvBEA) class CO_Guia
local cProtoc := ""

if BEA->(MsSeek(cChvBEA))
	cProtoc := BEA->BEA_PROATE
endif

return cProtoc

//-------------------------------------------------------------------
/*/{Protheus.doc} loadGuiRecBE4
Metodo para preencher uma classe a partir do recno 
@author Renan Martins
@since 03/2017
@version P12
/*/
//-------------------------------------------------------------------
method loadGuiRecBE4(nRecno) class CO_Guia

local cCodOpe 			:= ""
local objGuia			:= nil
local objAutorizacao	:= nil
local objBoRes 			:= BO_ResumoInter():New() 
local cCodRda 			:= ""
local cCodPExe 			:= ""
local cCodPSol 			:= ""
local dDatPro 			:= ""
local cCodLoc 			:= ""
local cCodEsp 			:= ""
local cCnes 			:= ""
local cEspExe 			:= ""                        
local cEspSol 			:= ""                         
local cMatric 			:= ""
local cNomUsr 			:= ""
local cPadCon 			:= ""
local cAteRn 			:= ""
Local aDadSol 			:= {}
Local cMens				:= ""

BE4->(dbGoto(nRecno))

	objGuia := VO_ResumoInter():New()
	objAutorizacao := VO_Autorizacao():New()	 	   

   	cCodOpe  := BE4->BE4_CODOPE
	cCodRda  := BE4->BE4_CODRDA
	cCodPExe := BE4->BE4_CDPFRE
	cCodPSol := BE4->BE4_CDPFSO
	dDatPro  := BE4->BE4_DATPRO
	cCodLoc  := BE4->BE4_CODLOC
	cCodEsp  := BE4->BE4_CODESP
	cCnes    := BE4->BE4_CNES
	cEspExe  := BE4->BE4_ESPEXE                   
	cEspSol  := BE4->BE4_ESPSOL   
	cMatric  := BE4->(BE4_OPEUSR+BE4_CODEMP+BE4_MATRIC+BE4_TIPREG+BE4_DIGITO)
	cNomUsr  := BE4->BE4_NOMUSR
	cPadCon  := BE4->BE4_PADCON
	cAteRn   := BE4->BE4_ATERNA
	//cChvProtoc := xFilial("BEA")+BE4->(BE4_OPERDA+BE4_ANOINT+BE4_MESINT+BE4_NUMINT+DTOS(BE4_DATPRO)+BE4_HORPRO)
   	
   	objGuia:setRegAns(  Posicione("BA0",1,xFilial("BA0")+cCodOpe,"BA0_SUSEP") )
   	objGuia:setCodOpe( cCodOpe )                       
  	objGuia:setCodLdp( BE4->BE4_CODLDP )
	objGuia:setCodPeg( BE4->BE4_CODPEG )
	objGuia:setNumero( BE4->BE4_NUMERO )
	
	objGuia:setFase  ( BE4->BE4_FASE ) 
	objGuia:setSituac( BE4->BE4_SITUAC )  
	objGuia:setDatPro( BE4->BE4_DATPRO )	
	objGuia:setHorPro( BE4->BE4_HORPRO )
	objGuia:setNumImp( BE4->BE4_NUMIMP )
		
	objGuia:setLotGui( BE4->BE4_LOTGUI )
	objGuia:setTipGui( BE4->BE4_TIPGUI )
	objGuia:setDtDigi( BE4->BE4_DTDIGI )
	objGuia:setMesPag( BE4->BE4_MESPAG ) 
	objGuia:setAnoPag( BE4->BE4_ANOPAG ) 
	
	objGuia:setNumAut( BE4->BE4_NUMINT )
	oBjGuia:setTpInt(BE4->BE4_TIPINT)
	oBjGuia:setGrpInt(BE4->BE4_GRPINT)
	
	objGuia:setPacote( BE4->BE4_PACOTE )
	objGuia:setOriMov( BE4->BE4_ORIMOV )
	objGuia:setRgImp ( BE4->BE4_RGIMP )
	objGuia:setTipCon( BE4->BE4_TIPCON )
	objGuia:setCid( BE4->BE4_CID )
	objGuia:setCid2( BE4->BE4_CIDSEC )
	objGuia:setCid3( BE4->BE4_CID3 )
	objGuia:setCid4( BE4->BE4_CID4 )
	objGuia:setdiagObito( BE4->BE4_CIDOBT )
	
	objGuia:setdecNascVivo( BE4->BE4_NRDCNV )
	objGuia:setDecObito ( BE4->BE4_NRDCOB )
	
	objGuia:setTipFat( BE4->BE4_TIPFAT )
	objGuia:setQtdEve( BE4->BE4_QTDEVE )
	objGuia:setIndAci( BE4->BE4_INDACI )
	objGuia:setTipSai( BE4->BE4_TIPALT )	
	objGuia:setTipAdm( BE4->BE4_TIPADM )  
	objGuia:setRegInt( BE4->BE4_REGINT )  
		  
	objGuia:setUtpDoe( BE4->BE4_UTPDOE )
	objGuia:setTpOdoe( BE4->BE4_TPODOE )
	objGuia:setTipDoe( BE4->BE4_TIPDOE )
	
	aDadSol := StrToArray(objBoRes:getNumInt(BE4->BE4_GUIINT), "|") 
	 
	objGuia:setNrlBor( aDadSol[1]  )	
	objAutorizacao:setDataAut( ctod(aDadSol[2]))
	objGuia:setDadAut(objAutorizacao)
	
	objGuia:setNumAux(STR(PlsVrIntPro(aDadSol[1])))
	
	objGuia:setNraOpe( BE4->BE4_NRAOPE ) 
	objGuia:setSenha ( aDadSol[3] ) 
	If (!Empty(BE4->BE4_MSG02))
		cMens := AllTrim(BE4->BE4_MSG01) + " " + AllTrim(BE4->BE4_MSG02)
		cMens := FwCutOff(cMens, .T.)  //Função que retira caracteres especias, como quebra de linha e outros, visto que o valor vem do HTML
		objGuia:setObsFim(cMens)
	Else
		cMens := AllTrim(BE4->BE4_MSG01)
		cMens := FwCutOff(cMens, .T.)
		objGuia:setObsFim( AllTrim(cMens)) 
	EndIf	
	
	objGuia:setDadBenef(self:addBenef(cCodOpe, cMatric, cNomUsr, cPadCon, cAteRn))
	objGuia:setContExec(self:addCont(cCodOpe, cCodRda, dDatPro, cCodLoc, cCodEsp, cCnes))
	objGuia:setProfExec(self:addProf(cCodOpe, cCodPExe, cEspExe))
	
	objGuia:setDtIniFat(BE4->BE4_DTINIF)
	objGuia:setDtFimFat(BE4->BE4_DTFIMF)
	objGuia:setHrIniFat(BE4->BE4_HRINIF)
	objGuia:setHrFimFat(BE4->BE4_HRFIMF)		
	objGuia:setIndDORN (BE4->BE4_OBTPRE) 
	
	
	objGuia:setProcedimentos(self:getProcChv(BE4->(BE4_CODOPE+BE4_CODLDP+BE4_CODPEG+BE4_NUMERO+BE4_ORIMOV), .F., .F., .F., .T., objGuia))
		
return objGuia



//-------------------------------------------------------------------
/*/{Protheus.doc} cntProced
Metodo para contar quantidade de guias

@author Renan Martins
@since 04/2017
@version P12
/*/
//-------------------------------------------------------------------
method cntProced (cChave, cTpBusca, cAliasCabec) class CO_Guia
Local cSql 		:= ""
Local nQtdProc	:= 0
Local lPosic		:= .F.

Default cAliasCabec := "BD5"
Default cTpBusca	:= "0"  //Recno

 
//Posiciona na BD5, caso ainda não esteja posicionado.
If (cTpBusca == "0")
	if(cChave != &(cAliasCabec)->(recno()))
		&(cAliasCabec)->(DbGoTo(cChave))
	endif
Else
	&(cAliasCabec)->(DbSetOrder(17))//BD5_FILIAL + BD5_CODOPE + BD5_CODLDP + BD5_CODPEG + BD5_NUMERO + BD5_SITUAC + BD5_FASE + dtos(BD5_DATPRO) + BD5_OPERDA + BD5_CODRDA
	If &(cAliasCabec)->(DbSeek(xFilial(cAliasCabec)+cChave))	
		lPosic := .T.
	EndIf
EndIf

//Query para contar quantos procedimentos tenho para a guia em questão, para saber se iremos usar a Multithread ou não na MF
cSql := "SELECT COUNT(*) AS QTD FROM " + RetSqlName("BD6") 
cSql += " WHERE BD6_FILIAL 	= '" + xFilial("BD6")  + "'"
cSql += " AND BD6_CODOPE 	= '" + &(cAliasCabec+"->"+cAliasCabec+"_CODOPE") + "'"
cSql += " AND BD6_CODLDP 	= '" + &(cAliasCabec+"->"+cAliasCabec+"_CODLDP") + "'"
cSql += " AND BD6_CODPEG 	= '" + &(cAliasCabec+"->"+cAliasCabec+"_CODPEG") + "'"
cSql += " AND BD6_NUMERO 	= '" + &(cAliasCabec+"->"+cAliasCabec+"_NUMERO") + "'"
cSql += " AND BD6_ORIMOV 	= '" + &(cAliasCabec+"->"+cAliasCabec+"_ORIMOV") + "'"

cSql := ChangeQuery(cSql)	
dbUseArea(.T.,"TOPCONN",TcGenQry(,,cSql),"QtdProc",.T.,.F.)

nQtdProc :=  QtdProc->QTD 

QtdProc->(dbCloseArea())

Return nQtdProc



//-------------------------------------------------------------------
/*/{Protheus.doc} CO_Guia
Somente para compilar a classe
@author Karine Riquena Limp
@since 25/05/2016
@version P12
/*/
//-------------------------------------------------------------------
Function CO_Guia
Return

