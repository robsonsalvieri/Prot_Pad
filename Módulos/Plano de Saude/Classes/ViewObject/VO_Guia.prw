#INCLUDE "TOTVS.CH"
#INCLUDE "FWMVCDEF.CH"

class VO_Guia
	
	data cRegAns	as String  
	data cCodOpe	as String  
	data cCodLdp	as String  
	data cCodPeg	as String  
	data cNumero	as String  
	data cNumAut	as String  
	data cFase		as String  
	data cSituac	as String  
	data dDatPro	as Date    
	data cHorPro	as String  	
	data cNumImp	as String  
	data cNraOpe	as String  
	data cLotGui	as String                       
	data cTipGui	as String  
	data cGuiOri	as String  
	data dDtDigi	as Date    
	data cMesPag	as String  
	data cAnoPag	as String  
	data cPacote	as String  
	data cOriMov	as String  
	data cGuiAco	as String  
	data cLibera	as String  
	data cRgImp	 	as String  
	data cTpGrv	 	as String  
	data cTipAte	as String  
	data cCid		as String  
	data cTipFat	as String  
	data nQtdEve	as Numeric 
	data cIndAci	as String  
	data cTipSai	as String  
	data cTipAdm	as String  
	data cMsg01	 	as String  
	data cMsg02	 	as String  
	data cUtpDoe	as String  
	data nTpOdoe	as Numeric 
	data cTipDoe	as String  
	data cNrlBor	as String  
	data cGuiPri	as String  
	data cSenha	 	as String  
	data cTipCon  	as String   
	data cTipAto	As String  
	data cObs		As String  
	data cProtoc	As String 
	data cGuiInt    as String 
	data cNumAux	as String
	data dDatAutO	as Date
	data dVldSenO	as Date
	data cProcLib 	as String
	data cVlOutS	as String
	data cCobEspG	as String
	data cTmRegaG	as String
	data cSauOcuG	as String
	
	data oDadBenef as Object   //classe VO_Beneficiário
	data cErro		 as String 
		
	method New() Constructor
	
	method setRegAns()
	method getRegAns()
	
	method setCodOpe()
	method getCodOpe()
	
	method setCodLdp()
	method getCodLdp()
	
	method setCodPeg()
	method getCodPeg()
	
	method setNumero()
	method getNumero()
	
	method setNumAut()
	method getNumAut()
	
	method setFase()
	method getFase()
	
	method setSituac()
	method getSituac()
	
	method setDatPro()
	method getDatPro()
	
	method setHorPro()
	method getHorPro()
	
	method setNumImp()
	method getNumImp()
	
	method setNraOpe()
	method getNraOpe()
	
	method setLotGui()
	method getLotGui()
	
	method setTipGui()
	method getTipGui()
	
	method setGuiOri()
	method getGuiOri()
	
	method setDtDigi()
	method getDtDigi()
	
	method setMesPag()
	method getMesPag()
	
	method setAnoPag()
	method getAnoPag()
	
	method setPacote()
	method getPacote()
	
	method setOriMov()
	method getOriMov()
	
	method setGuiAco()
	method getGuiAco()
	
	method setLibera()
	method getLibera()
	
	method setRgImp()
	method getRgImp()
	
	method setTpGrv()
	method getTpGrv()
	
	method setTipAte()
	method getTipAte()
	
	method setCid()
	method getCid()
	
	method setTipFat()
	method getTipFat()
	
	method setQtdEve()
	method getQtdEve()
	
	method setIndAci()
	method getIndAci()
	
	method setTipSai()
	method getTipSai()
	
	method setTipAdm()
	method getTipAdm()
	
	method setMsg01()
	method getMsg01()
	
	method setMsg02()
	method getMsg02()
	
	method setUtpDoe()
	method getUtpDoe()
	
	method setTpOdoe()
	method getTpOdoe()
	
	method setTipDoe()
	method getTipDoe()
	
	method setNrlBor()
	method getNrlBor()
	
	method setGuiPri()
	method getGuiPri()
		
	method setSenha()
	method getSenha()
	
	method setDadBenef()
	method getDadBenef()
	
	method setTipCon()
	method getTipCon()

	method setTipAto()
	method getTipAto()
	
	method setObs()
	method getObs()
	
	method setProtoc()
	method getProtoc()

	method setErro()
	method getErro()
	
	method setGuiInt()
	method getGuiInt()

	method setNumAux()
	method getNumAux()

	method setDatAutO()
	method getDatAutO()
	
	method setVldSenO()
	method getVldSenO()
	
	method setProcLib()
	method getProcLib()		

	method setVlOutS()
	method getVlOutS()

	method setCobEsp()
	method getCobEsp()

	method setTmRega()
	method getTmRega()

	method setSauOcu()
	method getSauOcu()

endClass
//-------------------------------------------------------------------
/*/{Protheus.doc} New
Metodo construtor da classe
@author Rodrigo Morgon
@since 03/06/2016
@version P12
/*/
//-------------------------------------------------------------------
method new() class VO_Guia
	
	::cRegAns	:= "" 
	::cCodOpe	:= "" 
	::cCodLdp	:= "" 
	::cCodPeg	:= "" 
	::cNumero	:= ""
	::cNumAut	:= ""
	::cFase		:= ""  
	::cSituac	:= ""  
	::dDatPro	:= Date()
	::cHorPro	:= ""
	::cNumImp	:= ""
	::cNraOpe	:= ""
	::cLotGui	:= ""
	::cTipGui	:= ""
	::cGuiOri	:= ""
	::dDtDigi	:= Date()  
	::cMesPag	:= "" 
	::cAnoPag	:= "" 
	::cPacote	:= "" 
	::cOriMov	:= "" 
	::cGuiAco	:= "" 
	::cLibera	:= "" 
	::cRgImp	:= ""     
	::cTpGrv	:= ""     
	::cTipAte	:= "" 
	::cCid	 	:= ""
	::cTipFat	:= "" 
	::nQtdEve	:= 0 
	::cIndAci	:= ""  
	::cTipSai	:= ""  
	::cTipAdm	:= ""  
	::cMsg01	:= ""      
	::cMsg02	:= ""      
	::cUtpDoe	:= ""  
	::nTpOdoe	:= 0
	::cTipDoe	:= ""
	::cNrlBor	:= ""
	::cGuiPri	:= ""
	::cSenha	:= ""    
	::cTipCon	:= "1"
	::cErro		:= ""
	::dDatAutO	:= Date()
	::dVldSenO	:= Date()
	::cProcLib	:= "" 
	::oDadBenef := VO_Beneficiario():New()
	::cVlOutS	:= ""
	::cCobEspG	:= ""
	::cTmRegaG	:= ""
	::cSauOcuG	:= ""
	
return self

//-------------------------------------------------------------------
/*/{Protheus.doc} setRegAns
Seta o valor cRegAns
@author Rodrigo Morgon
@since 03/06/2016
@version P12
/*/
//-------------------------------------------------------------------
method setRegAns(cRegAns) class VO_Guia
    ::cRegAns := cRegAns
return 

//-------------------------------------------------------------------
/*/{Protheus.doc} getRegAns
Retorna o valor cRegAns
@author Rodrigo Morgon
@since 03/06/2016
@version P12
/*/
//-------------------------------------------------------------------
method getRegAns() class VO_Guia
return(::cRegAns)

//-------------------------------------------------------------------
/*/{Protheus.doc} setCodOpe
Seta o valor cCodOpe
@author Rodrigo Morgon
@since 03/06/2016
@version P12
/*/
//-------------------------------------------------------------------
method setCodOpe(cCodOpe) class VO_Guia
    ::cCodOpe := cCodOpe
return 

//-------------------------------------------------------------------
/*/{Protheus.doc} getCodOpe
Retorna o valor cCodOpe
@author Rodrigo Morgon
@since 03/06/2016
@version P12
/*/
//-------------------------------------------------------------------
method getCodOpe() class VO_Guia
return(::cCodOpe)

//-------------------------------------------------------------------
/*/{Protheus.doc} setCodLdp
Seta o valor cCodLdp
@author Rodrigo Morgon
@since 03/06/2016
@version P12
/*/
//-------------------------------------------------------------------
method setCodLdp(cCodLdp) class VO_Guia
    ::cCodLdp := cCodLdp
return 

//-------------------------------------------------------------------
/*/{Protheus.doc} getCodLdp
Retorna o valor cCodLdp
@author Rodrigo Morgon
@since 03/06/2016
@version P12
/*/
//-------------------------------------------------------------------
method getCodLdp() class VO_Guia
return(::cCodLdp)

//-------------------------------------------------------------------
/*/{Protheus.doc} setCodPeg
Seta o valor cCodPeg
@author Rodrigo Morgon
@since 03/06/2016
@version P12
/*/
//-------------------------------------------------------------------
method setCodPeg(cCodPeg) class VO_Guia
    ::cCodPeg := cCodPeg
return 

//-------------------------------------------------------------------
/*/{Protheus.doc} getCodPeg
Retorna o valor cCodPeg
@author Rodrigo Morgon
@since 03/06/2016
@version P12
/*/
//-------------------------------------------------------------------
method getCodPeg() class VO_Guia
return(::cCodPeg)

//-------------------------------------------------------------------
/*/{Protheus.doc} setNumero
Seta o valor cNumero
@author Rodrigo Morgon
@since 03/06/2016
@version P12
/*/
//-------------------------------------------------------------------
method setNumero(cNumero) class VO_Guia
    ::cNumero := cNumero
return 

//-------------------------------------------------------------------
/*/{Protheus.doc} getNumero
Retorna o valor cNumero
@author Rodrigo Morgon
@since 03/06/2016
@version P12
/*/
//-------------------------------------------------------------------
method getNumero() class VO_Guia
return(::cNumero)

//-------------------------------------------------------------------
/*/{Protheus.doc} setNumAut
Seta o valor cNumAut
@author Roberto Vanderlei
@since 03/06/2016
@version P12
/*/
//-------------------------------------------------------------------
method setNumAut(cNumAut) class VO_Guia
    ::cNumAut := cNumAut
return 

//-------------------------------------------------------------------
/*/{Protheus.doc} getNumAut
Retorna o valor cNumAut
@author Roberto Vanderlei
@since 03/06/2016
@version P12
/*/
//-------------------------------------------------------------------
method getNumAut() class VO_Guia
return(::cNumAut)

//-------------------------------------------------------------------
/*/{Protheus.doc} setFase
Seta o valor cFase
@author Rodrigo Morgon
@since 03/06/2016
@version P12
/*/
//-------------------------------------------------------------------
method setFase(cFase) class VO_Guia
    ::cFase := cFase
return 

//-------------------------------------------------------------------
/*/{Protheus.doc} getFase
Retorna o valor cFase
@author Rodrigo Morgon
@since 03/06/2016
@version P12
/*/
//-------------------------------------------------------------------
method getFase() class VO_Guia
return(::cFase)

//-------------------------------------------------------------------
/*/{Protheus.doc} setSituac
Seta o valor cSituac
@author Rodrigo Morgon
@since 03/06/2016
@version P12
/*/
//-------------------------------------------------------------------
method setSituac(cSituac) class VO_Guia
    ::cSituac := cSituac
return 

//-------------------------------------------------------------------
/*/{Protheus.doc} getSituac
Retorna o valor cSituac
@author Rodrigo Morgon
@since 03/06/2016
@version P12
/*/
//-------------------------------------------------------------------
method getSituac() class VO_Guia
return(::cSituac)

//-------------------------------------------------------------------
/*/{Protheus.doc} setDatPro
Seta o valor dDatPro
@author Rodrigo Morgon
@since 03/06/2016
@version P12
/*/
//-------------------------------------------------------------------
method setDatPro(dDatPro) class VO_Guia
    ::dDatPro := dDatPro
return 

//-------------------------------------------------------------------
/*/{Protheus.doc} getDatPro
Retorna o valor dDatPro
@author Rodrigo Morgon
@since 03/06/2016
@version P12
/*/
//-------------------------------------------------------------------
method getDatPro() class VO_Guia
return(::dDatPro)

//-------------------------------------------------------------------
/*/{Protheus.doc} setHorPro
Seta o valor cHorPro
@author Rodrigo Morgon
@since 03/06/2016
@version P12
/*/
//-------------------------------------------------------------------
method setHorPro(cHorPro) class VO_Guia
    ::cHorPro := cHorPro
return 

//-------------------------------------------------------------------
/*/{Protheus.doc} getHorPro
Retorna o valor cHorPro
@author Rodrigo Morgon
@since 03/06/2016
@version P12
/*/
//-------------------------------------------------------------------
method getHorPro() class VO_Guia
return(::cHorPro)

//-------------------------------------------------------------------
/*/{Protheus.doc} setNumImp
Seta o valor cNumImp
@author Rodrigo Morgon
@since 03/06/2016
@version P12
/*/
//-------------------------------------------------------------------
method setNumImp(cNumImp) class VO_Guia
    ::cNumImp := cNumImp
return 

//-------------------------------------------------------------------
/*/{Protheus.doc} getNumImp
Retorna o valor cNumImp
@author Rodrigo Morgon
@since 03/06/2016
@version P12
/*/
//-------------------------------------------------------------------
method getNumImp() class VO_Guia
return(::cNumImp)

//-------------------------------------------------------------------
/*/{Protheus.doc} setNraOpe
Seta o valor cNraOpe
@author Rodrigo Morgon
@since 03/06/2016
@version P12
/*/
//-------------------------------------------------------------------
method setNraOpe(cNraOpe) class VO_Guia
    ::cNraOpe := cNraOpe
return 

//-------------------------------------------------------------------
/*/{Protheus.doc} getNraOpe
Retorna o valor cNraOpe
@author Rodrigo Morgon
@since 03/06/2016
@version P12
/*/
//-------------------------------------------------------------------
method getNraOpe() class VO_Guia
return(::cNraOpe)

//-------------------------------------------------------------------
/*/{Protheus.doc} setLotGui
Seta o valor cLotGui
@author Rodrigo Morgon
@since 03/06/2016
@version P12
/*/
//-------------------------------------------------------------------
method setLotGui(cLotGui) class VO_Guia
    ::cLotGui := cLotGui
return 

//-------------------------------------------------------------------
/*/{Protheus.doc} getLotGui
Retorna o valor cLotGui
@author Rodrigo Morgon
@since 03/06/2016
@version P12
/*/
//-------------------------------------------------------------------
method getLotGui() class VO_Guia
return(::cLotGui)

//-------------------------------------------------------------------
/*/{Protheus.doc} setTipGui
Seta o valor cTipGui
@author Rodrigo Morgon
@since 03/06/2016
@version P12
/*/
//-------------------------------------------------------------------
method setTipGui(cTipGui) class VO_Guia
    ::cTipGui := cTipGui
return 

//-------------------------------------------------------------------
/*/{Protheus.doc} getTipGui
Retorna o valor cTipGui
@author Rodrigo Morgon
@since 03/06/2016
@version P12
/*/
//-------------------------------------------------------------------
method getTipGui() class VO_Guia
return(::cTipGui)

//-------------------------------------------------------------------
/*/{Protheus.doc} setGuiOri
Seta o valor cGuiOri
@author Rodrigo Morgon
@since 03/06/2016
@version P12
/*/
//-------------------------------------------------------------------
method setGuiOri(cGuiOri) class VO_Guia
    ::cGuiOri := cGuiOri
return 

//-------------------------------------------------------------------
/*/{Protheus.doc} getGuiOri
Retorna o valor cGuiOri
@author Rodrigo Morgon
@since 03/06/2016
@version P12
/*/
//-------------------------------------------------------------------
method getGuiOri() class VO_Guia
return(::cGuiOri)

//-------------------------------------------------------------------
/*/{Protheus.doc} setDtDigi
Seta o valor dDtDigi
@author Rodrigo Morgon
@since 03/06/2016
@version P12
/*/
//-------------------------------------------------------------------
method setDtDigi(dDtDigi) class VO_Guia
    ::dDtDigi := dDtDigi
return 

//-------------------------------------------------------------------
/*/{Protheus.doc} getDtDigi
Retorna o valor dDtDigi
@author Rodrigo Morgon
@since 03/06/2016
@version P12
/*/
//-------------------------------------------------------------------
method getDtDigi() class VO_Guia
return(::dDtDigi)

//-------------------------------------------------------------------
/*/{Protheus.doc} setMesPag
Seta o valor cMesPag
@author Rodrigo Morgon
@since 03/06/2016
@version P12
/*/
//-------------------------------------------------------------------
method setMesPag(cMesPag) class VO_Guia
    ::cMesPag := cMesPag
return 

//-------------------------------------------------------------------
/*/{Protheus.doc} getMesPag
Retorna o valor cMesPag
@author Rodrigo Morgon
@since 03/06/2016
@version P12
/*/
//-------------------------------------------------------------------
method getMesPag() class VO_Guia
return(::cMesPag)

//-------------------------------------------------------------------
/*/{Protheus.doc} setAnoPag
Seta o valor cAnoPag
@author Rodrigo Morgon
@since 03/06/2016
@version P12
/*/
//-------------------------------------------------------------------
method setAnoPag(cAnoPag) class VO_Guia
    ::cAnoPag := cAnoPag
return 

//-------------------------------------------------------------------
/*/{Protheus.doc} getAnoPag
Retorna o valor cAnoPag
@author Rodrigo Morgon
@since 03/06/2016
@version P12
/*/
//-------------------------------------------------------------------
method getAnoPag() class VO_Guia
return(::cAnoPag)

//-------------------------------------------------------------------
/*/{Protheus.doc} setPacote
Seta o valor cPacote
@author Rodrigo Morgon
@since 03/06/2016
@version P12
/*/
//-------------------------------------------------------------------
method setPacote(cPacote) class VO_Guia
    ::cPacote := cPacote
return 

//-------------------------------------------------------------------
/*/{Protheus.doc} getPacote
Retorna o valor cPacote
@author Rodrigo Morgon
@since 03/06/2016
@version P12
/*/
//-------------------------------------------------------------------
method getPacote() class VO_Guia
return(::cPacote)

//-------------------------------------------------------------------
/*/{Protheus.doc} setOriMov
Seta o valor cOriMov
@author Rodrigo Morgon
@since 03/06/2016
@version P12
/*/
//-------------------------------------------------------------------
method setOriMov(cOriMov) class VO_Guia
    ::cOriMov := cOriMov
return 

//-------------------------------------------------------------------
/*/{Protheus.doc} getOriMov
Retorna o valor cOriMov
@author Rodrigo Morgon
@since 03/06/2016
@version P12
/*/
//-------------------------------------------------------------------
method getOriMov() class VO_Guia
return(::cOriMov)

//-------------------------------------------------------------------
/*/{Protheus.doc} setGuiAco
Seta o valor cGuiAco
@author Rodrigo Morgon
@since 03/06/2016
@version P12
/*/
//-------------------------------------------------------------------
method setGuiAco(cGuiAco) class VO_Guia
    ::cGuiAco := cGuiAco
return 

//-------------------------------------------------------------------
/*/{Protheus.doc} getGuiAco
Retorna o valor cGuiAco
@author Rodrigo Morgon
@since 03/06/2016
@version P12
/*/
//-------------------------------------------------------------------
method getGuiAco() class VO_Guia
return(::cGuiAco)

//-------------------------------------------------------------------
/*/{Protheus.doc} setLibera
Seta o valor cLibera
@author Rodrigo Morgon
@since 03/06/2016
@version P12
/*/
//-------------------------------------------------------------------
method setLibera(cLibera) class VO_Guia
    ::cLibera := cLibera
return 

//-------------------------------------------------------------------
/*/{Protheus.doc} getLibera
Retorna o valor cLibera
@author Rodrigo Morgon
@since 03/06/2016
@version P12
/*/
//-------------------------------------------------------------------
method getLibera() class VO_Guia
return(::cLibera)

//-------------------------------------------------------------------
/*/{Protheus.doc} setRgImp
Seta o valor cRgImp
@author Rodrigo Morgon
@since 03/06/2016
@version P12
/*/
//-------------------------------------------------------------------
method setRgImp(cRgImp) class VO_Guia
    ::cRgImp := cRgImp
return 

//-------------------------------------------------------------------
/*/{Protheus.doc} getRgImp
Retorna o valor cRgImp
@author Rodrigo Morgon
@since 03/06/2016
@version P12
/*/
//-------------------------------------------------------------------
method getRgImp() class VO_Guia
return(::cRgImp)

//-------------------------------------------------------------------
/*/{Protheus.doc} setTpGrv
Seta o valor cTpGrv
@author Rodrigo Morgon
@since 03/06/2016
@version P12
/*/
//-------------------------------------------------------------------
method setTpGrv(cTpGrv) class VO_Guia
    ::cTpGrv := cTpGrv
return 

//-------------------------------------------------------------------
/*/{Protheus.doc} getTpGrv
Retorna o valor cTpGrv
@author Rodrigo Morgon
@since 03/06/2016
@version P12
/*/
//-------------------------------------------------------------------
method getTpGrv() class VO_Guia
return(::cTpGrv)

//-------------------------------------------------------------------
/*/{Protheus.doc} setTipAte
Seta o valor cTipAte
@author Rodrigo Morgon
@since 03/06/2016
@version P12
/*/
//-------------------------------------------------------------------
method setTipAte(cTipAte) class VO_Guia
    ::cTipAte := cTipAte
return 

//-------------------------------------------------------------------
/*/{Protheus.doc} getTipAte
Retorna o valor cTipAte
@author Rodrigo Morgon
@since 03/06/2016
@version P12
/*/
//-------------------------------------------------------------------
method getTipAte() class VO_Guia
return(::cTipAte)

//-------------------------------------------------------------------
/*/{Protheus.doc} setCid
Seta o valor cCid
@author Rodrigo Morgon
@since 03/06/2016
@version P12
/*/
//-------------------------------------------------------------------
method setCid(cCid) class VO_Guia
    ::cCid := cCid
return 

//-------------------------------------------------------------------
/*/{Protheus.doc} getCid
Retorna o valor cCid
@author Rodrigo Morgon
@since 03/06/2016
@version P12
/*/
//-------------------------------------------------------------------
method getCid() class VO_Guia
return(::cCid)

//-------------------------------------------------------------------
/*/{Protheus.doc} setTipFat
Seta o valor cTipFat
@author Rodrigo Morgon
@since 03/06/2016
@version P12
/*/
//-------------------------------------------------------------------
method setTipFat(cTipFat) class VO_Guia
    ::cTipFat := cTipFat
return 

//-------------------------------------------------------------------
/*/{Protheus.doc} getTipFat
Retorna o valor cTipFat
@author Rodrigo Morgon
@since 03/06/2016
@version P12
/*/
//-------------------------------------------------------------------
method getTipFat() class VO_Guia
return(::cTipFat)

//-------------------------------------------------------------------
/*/{Protheus.doc} setQtdEve
Seta o valor nQtdEve
@author Rodrigo Morgon
@since 03/06/2016
@version P12
/*/
//-------------------------------------------------------------------
method setQtdEve(nQtdEve) class VO_Guia
    ::nQtdEve := nQtdEve
return 

//-------------------------------------------------------------------
/*/{Protheus.doc} getQtdEve
Retorna o valor nQtdEve
@author Rodrigo Morgon
@since 03/06/2016
@version P12
/*/
//-------------------------------------------------------------------
method getQtdEve() class VO_Guia
return(::nQtdEve)

//-------------------------------------------------------------------
/*/{Protheus.doc} setIndAci
Seta o valor cIndAci
@author Rodrigo Morgon
@since 03/06/2016
@version P12
/*/
//-------------------------------------------------------------------
method setIndAci(cIndAci) class VO_Guia
    ::cIndAci := cIndAci
return 

//-------------------------------------------------------------------
/*/{Protheus.doc} getIndAci
Retorna o valor cIndAci
@author Rodrigo Morgon
@since 03/06/2016
@version P12
/*/
//-------------------------------------------------------------------
method getIndAci() class VO_Guia
return(::cIndAci)

//-------------------------------------------------------------------
/*/{Protheus.doc} setTipSai
Seta o valor cTipSai
@author Rodrigo Morgon
@since 03/06/2016
@version P12
/*/
//-------------------------------------------------------------------
method setTipSai(cTipSai) class VO_Guia
    ::cTipSai := cTipSai
return 

//-------------------------------------------------------------------
/*/{Protheus.doc} getTipSai
Retorna o valor cTipSai
@author Rodrigo Morgon
@since 03/06/2016
@version P12
/*/
//-------------------------------------------------------------------
method getTipSai() class VO_Guia
return(::cTipSai)

//-------------------------------------------------------------------
/*/{Protheus.doc} setTipAdm
Seta o valor cTipAdm
@author Rodrigo Morgon
@since 03/06/2016
@version P12
/*/
//-------------------------------------------------------------------
method setTipAdm(cTipAdm) class VO_Guia
    ::cTipAdm := cTipAdm
return 

//-------------------------------------------------------------------
/*/{Protheus.doc} getTipAdm
Retorna o valor cTipAdm
@author Rodrigo Morgon
@since 03/06/2016
@version P12
/*/
//-------------------------------------------------------------------
method getTipAdm() class VO_Guia
return(::cTipAdm)

//-------------------------------------------------------------------
/*/{Protheus.doc} setMsg01
Seta o valor cMsg01
@author Rodrigo Morgon
@since 03/06/2016
@version P12
/*/
//-------------------------------------------------------------------
method setMsg01(cMsg01) class VO_Guia
    ::cMsg01 := cMsg01
return 

//-------------------------------------------------------------------
/*/{Protheus.doc} getMsg01
Retorna o valor cMsg01
@author Rodrigo Morgon
@since 03/06/2016
@version P12
/*/
//-------------------------------------------------------------------
method getMsg01() class VO_Guia
return(::cMsg01)

//-------------------------------------------------------------------
/*/{Protheus.doc} setMsg02
Seta o valor cMsg02
@author Rodrigo Morgon
@since 03/06/2016
@version P12
/*/
//-------------------------------------------------------------------
method setMsg02(cMsg02) class VO_Guia
    ::cMsg02 := cMsg02
return 

//-------------------------------------------------------------------
/*/{Protheus.doc} getMsg02
Retorna o valor cMsg02
@author Rodrigo Morgon
@since 03/06/2016
@version P12
/*/
//-------------------------------------------------------------------
method getMsg02() class VO_Guia
return(::cMsg02)

//-------------------------------------------------------------------
/*/{Protheus.doc} setUtpDoe
Seta o valor cUtpDoe
@author Rodrigo Morgon
@since 03/06/2016
@version P12
/*/
//-------------------------------------------------------------------
method setUtpDoe(cUtpDoe) class VO_Guia
    ::cUtpDoe := cUtpDoe
return 

//-------------------------------------------------------------------
/*/{Protheus.doc} getUtpDoe
Retorna o valor cUtpDoe
@author Rodrigo Morgon
@since 03/06/2016
@version P12
/*/
//-------------------------------------------------------------------
method getUtpDoe() class VO_Guia
return(::cUtpDoe)

//-------------------------------------------------------------------
/*/{Protheus.doc} setTpOdoe
Seta o valor nTpOdoe
@author Rodrigo Morgon
@since 03/06/2016
@version P12
/*/
//-------------------------------------------------------------------
method setTpOdoe(nTpOdoe) class VO_Guia
    ::nTpOdoe := nTpOdoe
return 

//-------------------------------------------------------------------
/*/{Protheus.doc} getTpOdoe
Retorna o valor nTpOdoe
@author Rodrigo Morgon
@since 03/06/2016
@version P12
/*/
//-------------------------------------------------------------------
method getTpOdoe() class VO_Guia
return(::nTpOdoe)

//-------------------------------------------------------------------
/*/{Protheus.doc} setTipDoe
Seta o valor cTipDoe
@author Rodrigo Morgon
@since 03/06/2016
@version P12
/*/
//-------------------------------------------------------------------
method setTipDoe(cTipDoe) class VO_Guia
    ::cTipDoe := cTipDoe
return 

//-------------------------------------------------------------------
/*/{Protheus.doc} getTipDoe
Retorna o valor cTipDoe
@author Rodrigo Morgon
@since 03/06/2016
@version P12
/*/
//-------------------------------------------------------------------
method getTipDoe() class VO_Guia
return(::cTipDoe)

//-------------------------------------------------------------------
/*/{Protheus.doc} setNrlBor
Seta o valor cNrlBor
@author Rodrigo Morgon
@since 03/06/2016
@version P12
/*/
//-------------------------------------------------------------------
method setNrlBor(cNrlBor) class VO_Guia
    ::cNrlBor := cNrlBor
return 

//-------------------------------------------------------------------
/*/{Protheus.doc} getNrlBor
Retorna o valor cNrlBor
@author Rodrigo Morgon
@since 03/06/2016
@version P12
/*/
//-------------------------------------------------------------------
method getNrlBor() class VO_Guia
return(::cNrlBor)

//-------------------------------------------------------------------
/*/{Protheus.doc} setGuiPri
Seta o valor cGuiPri
@author Rodrigo Morgon
@since 03/06/2016
@version P12
/*/
//-------------------------------------------------------------------
method setGuiPri(cGuiPri) class VO_Guia
    ::cGuiPri := cGuiPri
return 

//-------------------------------------------------------------------
/*/{Protheus.doc} getGuiPri
Retorna o valor cGuiPri
@author Rodrigo Morgon
@since 03/06/2016
@version P12
/*/
//-------------------------------------------------------------------
method getGuiPri() class VO_Guia
return(::cGuiPri)

//-------------------------------------------------------------------
/*/{Protheus.doc} setSenha
Seta o valor cSenha
@author Rodrigo Morgon
@since 03/06/2016
@version P12
/*/
//-------------------------------------------------------------------
method setSenha(cSenha) class VO_Guia
    ::cSenha := cSenha
return 

//-------------------------------------------------------------------
/*/{Protheus.doc} getSenha
Retorna o valor cSenha
@author Rodrigo Morgon
@since 03/06/2016
@version P12
/*/
//-------------------------------------------------------------------
method getSenha() class VO_Guia
return(::cSenha)

//-------------------------------------------------------------------
/*/{Protheus.doc} setTipCon
Seta o valor TipCon
@author Karine Riquena Limp
@since 24/05/2016
@version P12
/*/
//-------------------------------------------------------------------
method setTipCon(cTipCon) class VO_Guia
    ::cTipCon := cTipCon
return 

//-------------------------------------------------------------------
/*/{Protheus.doc} getTipCon
Retorna o valor TipCon
@author Karine Riquena Limp
@since 24/05/2016
@version P12
/*/
//-------------------------------------------------------------------
method getTipCon() class VO_Guia
return(::cTipCon)


//-------------------------------------------------------------------
/*/{Protheus.doc} setTipCon
Seta o valor TipCon
@author Karine Riquena Limp
@since 24/05/2016
@version P12
/*/
//-------------------------------------------------------------------
method setTipAto(cTipAto) class VO_Guia
    ::cTipAto := cTipAto
return 


//-------------------------------------------------------------------
/*/{Protheus.doc} getTipCon
Retorna o valor TipCon
@author Karine Riquena Limp
@since 24/05/2016
@version P12
/*/
//-------------------------------------------------------------------
method getTipAto() class VO_Guia
return(::cTipAto)


//-------------------------------------------------------------------
/*/{Protheus.doc} getObs
Retorna o valor da observação
@author Rogério Tabosa
@since 18/07/2016
@version P12
/*/
//-------------------------------------------------------------------
method getObs() class VO_Guia
return(::cObs)


//-------------------------------------------------------------------
/*/{Protheus.doc} setObs
Atribui o valor da observação
@author Rogério Tabosa
@since 18/07/2016
@version P12
/*/
//-------------------------------------------------------------------
method setObs(cObs) class VO_Guia
    ::cObs := cObs
return 

//-------------------------------------------------------------------
/*/{Protheus.doc} getProtoc
Retorna o valor da protocolo
@author Francisco Edcarlo
@since 02/02/2017
@version P12
/*/
//-------------------------------------------------------------------
method getProtoc() class VO_Guia
return(::cProtoc)

//-------------------------------------------------------------------
/*/{Protheus.doc} setProtoc
Atribui o valor do protocolo
@author Francisco Edcarlo
@since 02/02/2017
@version P12
/*/
//-------------------------------------------------------------------
method setProtoc(cProtoc) class VO_Guia
    ::cProtoc := cProtoc
return 

//-------------------------------------------------------------------
/*/{Protheus.doc} setGuiInt
Seta o valor cGuiInt
@author Rodrigo Morgon
@since 16/01/2018
@version P12
/*/
//-------------------------------------------------------------------
method setGuiInt(cGuiInt) class VO_Guia
    ::cGuiInt := cGuiInt
return 

//-------------------------------------------------------------------
/*/{Protheus.doc} getGuiInt
Retorna o valor cGuiInt
@author Rodrigo Morgon
@since 16/01/2018
@version P12
/*/
//-------------------------------------------------------------------
method getGuiInt() class VO_Guia
return(::cGuiInt)

//-------------------------------------------------------------------
/*/{Protheus.doc} setErro
Seta o erro do modelo
@author Rodrigo Morgon
@since 06/07/2016
@version P12
/*/
//-------------------------------------------------------------------
method setErro(cErro) class VO_Guia
    ::cErro := cErro
return 

//-------------------------------------------------------------------
/*/{Protheus.doc} getErro
Retorna o valor do erro do modelo
@author Rodrigo Morgon
@since 06/07/2016
@version P12
/*/
//-------------------------------------------------------------------
method getErro() class VO_Guia
return(::cErro)

//-------------------------------------------------------------------
/*/{Protheus.doc} setDadBenef
Seta o valor cSenha
@author Rodrigo Morgon
@since 03/06/2016
@version P12
/*/
//-------------------------------------------------------------------
method setDadBenef(oDadBenef) class VO_Guia
    ::oDadBenef := oDadBenef
return 

//-------------------------------------------------------------------
/*/{Protheus.doc} getDadBenef
Retorna o valor cSenha
@author Rodrigo Morgon
@since 03/06/2016
@version P12
/*/
//-------------------------------------------------------------------
method getDadBenef() class VO_Guia
return(::oDadBenef)


//-------------------------------------------------------------------
/*/{Protheus.doc} setNumAux
Atribui Numero de Auxiliares
@author Renan Martins
@since 01/2018
@version P12
/*/
//-------------------------------------------------------------------
method setNumAux(cNumAux) class VO_Guia
return ::cNumAux := cNumAux
 

//-------------------------------------------------------------------
/*/{Protheus.doc} setNumAux
Seta o valor Numero de Auxiliares
@author Renan Martins
@since 01/2018
@version P12
/*/
//-------------------------------------------------------------------
method getNumAux(cNumAux) class VO_Guia
return(::cNumAux)


//-------------------------------------------------------------------
/*/{Protheus.doc} setDatAutO
Atribui Data Autorização Liberação odontológica
@author Renan Martins
@since 06/2018
@version P12
/*/
//-------------------------------------------------------------------
method setDatAutO(dDatAutO) class VO_Guia
return ::dDatAutO := dDatAutO
 

//-------------------------------------------------------------------
/*/{Protheus.doc} getDatAutO
Recupera Data Autorização Liberação odontológica
@author Renan Martins
@since 06/2018
@version P12
/*/
//-------------------------------------------------------------------
method getDatAutO(dDatAutO) class VO_Guia
return(::dDatAutO)


//-------------------------------------------------------------------
/*/{Protheus.doc} setVldSenO
Atribui Data Autorização Liberação odontológica
@author Renan Martins
@since 06/2018
@version P12
/*/
//-------------------------------------------------------------------
method setVldSenO(dVldSenO) class VO_Guia
return ::dVldSenO := dVldSenO


//-------------------------------------------------------------------
/*/{Protheus.doc} getVldSenO
Recupera Data Autorização Liberação odontológica
@author Renan Martins
@since 06/2018
@version P12
/*/
//-------------------------------------------------------------------
method getVldSenO(dVldSenO) class VO_Guia
return(::dVldSenO)


//-------------------------------------------------------------------
/*/{Protheus.doc} setProcLib
Atribui Proc Liberação
@author Renan Martins
@since 06/2018
@version P12
/*/
//-------------------------------------------------------------------
method setProcLib(cProcLib) class VO_Guia
return ::cProcLib := cProcLib


//-------------------------------------------------------------------
/*/{Protheus.doc} getProcLib
Recupera Procs Liberação
@author Renan Martins
@since 06/2018
@version P12
/*/
//-------------------------------------------------------------------
method getProcLib(cProcLib) class VO_Guia
return(::cProcLib)


//-------------------------------------------------------------------
/*/{Protheus.doc} setVlOutS
Atribui Valor da guia de Outras Despesas
@author Silvia Sant'Anna
@since 09/2018
@version P12
/*/
//-------------------------------------------------------------------
method setVlOutS(cVlOutS) class VO_Guia
return ::cVlOutS := cVlOutS


//-------------------------------------------------------------------
/*/{Protheus.doc} getVlOutS
Recupera Valor da guia de Outras Despesas
@author Silvia Sant'Anna
@since 09/2018
@version P12
/*/
//-------------------------------------------------------------------
method getVlOutS(cVlOutS) class VO_Guia
return(::cVlOutS)



//-------------------------------------------------------------------
/*/{Protheus.doc} setCobEsp
Seta Cobertura Especial
@since 04/2022
@version P12
/*/
//-------------------------------------------------------------------
method setCobEsp(cCobEspG) class VO_Guia
return ::cCobEspG := cCobEspG


//-------------------------------------------------------------------
/*/{Protheus.doc} getVlOutS
Recupera Cobertura Especial
@since 04/2022
@version P12
/*/
//-------------------------------------------------------------------
method getCobEsp(cCobEspG) class VO_Guia
return(::cCobEspG)



//-------------------------------------------------------------------
/*/{Protheus.doc} setTmRega
Seta Regime de Atendimento
@since 04/2022
@version P12
/*/
//-------------------------------------------------------------------
method setTmRega(cTmRegaG) class VO_Guia
return ::cTmRegaG := cTmRegaG


//-------------------------------------------------------------------
/*/{Protheus.doc} getTmRega
Recupera Regime de Atendimento
@since 04/2022
@version P12
/*/
//-------------------------------------------------------------------
method getTmRega(cTmRegaG) class VO_Guia
return(::cTmRegaG)



//-------------------------------------------------------------------
/*/{Protheus.doc} setTmRega
Seta Saúde Ocupacional
@since 04/2022
@version P12
/*/
//-------------------------------------------------------------------
method setSauOcu(cSauOcuG) class VO_Guia
return ::cSauOcuG := cSauOcuG


//-------------------------------------------------------------------
/*/{Protheus.doc} getTmRega
Recupera Saúde Ocupacional
@since 04/2022
@version P12
/*/
//-------------------------------------------------------------------
method getSauOcu(cSauOcuG) class VO_Guia
return(::cSauOcuG)



//-------------------------------------------------------------------
/*/{Protheus.doc} VO_Guia
Somente para compilar a classe
@author Karine Riquena Limp
@since 20/05/2016
@version P12
/*/
//-------------------------------------------------------------------
Function VO_Guia
Return
