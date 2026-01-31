#INCLUDE "TOTVS.CH"
#INCLUDE "FWMVCDEF.CH"

class VO_Beneficiario
	
	data cOpeUsr 	as String HIDDEN //BD5_OPEUSR | BD6_OPEUSR
	data cMatAnt 	as String HIDDEN //BD5_MATANT | BD6_MATANT
	data cNomUsr 	as String HIDDEN //BD5_NOMUSR | BD6_NOMUSR
	data cMatXml 	as String HIDDEN //BD5_MATXML |
	data cCodEmp 	as String HIDDEN //BD5_CODEMP | BD6_CODEMP
	data cMatric 	as String HIDDEN //BD5_MATRIC | BD6_MATRIC
	data cTipReg 	as String HIDDEN //BD5_TIPREG | BD6_TIPREG
	data cCpfUsr 	as String HIDDEN //BD5_CPFUSR | 
	data cIdUsr  	as String HIDDEN //BD5_IDUSR  | BD6_IDUSR
	data cDatNas 	as String HIDDEN //BD5_DATNAS | BD6_DATNAS
	data cDigito 	as String HIDDEN //BD5_DIGITO | BD6_DIGITO
	data cConEmp 	as String HIDDEN //BD5_CONEMP | BD6_CONEMP
	data cVerCon 	as String HIDDEN //BD5_VERCON | BD6_VERCON
	data cSubCon 	as String HIDDEN //BD5_SUBCON | BD6_SUBCON
	data cVerSub 	as String HIDDEN //BD5_VERSUB | BD6_VERSUB
	data cMatVid 	as String HIDDEN //BD5_MATVID | BD6_MATVID
	data cTipPac 	as String HIDDEN //BD5_TIPPAC | 
   	data cMatUsa 	as String HIDDEN //BD5_MATUSA | BD6_MATUSA
   	data cAteRna 	as String HIDDEN //BD5_ATERNA |
	data cPadCon 	as String HIDDEN //BD5_PADCON |
	data cPadInt 	as String HIDDEN //BD5_PADINT |
	data cValCar 	as String HIDDEN 
	data cCrtNS  	as String HIDDEN

	data cOpeOri 	as String HIDDEN	//BD6_OPEORI
	data cCodPla 	as String HIDDEN	//BD6_CODPLA
	data cModPag 	as String HIDDEN	//BD6_MODCOB
	data cTipUsr 	as String HIDDEN	//BD6_TIPUSR
	data cInterc 	as String HIDDEN 	//BD6_INTERC
	data cNomSocG 	as String HIDDEN
	
	method setOpeUsr()
	method getOpeUsr()
	
	method setMatAnt()
	method getMatAnt()
	
	method setNomUsr()
	method getNomUsr()
	
	method setMatXml()
	method getMatXml()
	
	method setCodEmp()
	method getCodEmp()
	
	method setMatric()
	method getMatric()
	
	method setTipReg()
	method getTipReg()
	
	method setCpfUsr()
	method getCpfUsr()
	
	method setIdUsr()
	method getIdUsr()
	
	method setDatNas()
	method getDatNas()
	
	method setDigito()
	method getDigito()
	
	method setConEmp()
	method getConEmp()
	
	method setVerCon()
	method getVerCon()
	
	method setSubCon()
	method getSubCon()
	
	method setVerSub()
	method getVerSub()
	
	method setMatVid()
	method getMatVid()
	
	method setTipPac()
	method getTipPac()
	
	method setMatUsa()
	method getMatUsa()
	
	method setAteRna()
	method getAteRna()
	
	method setPadCon()
	method getPadCon()
	
	method setPadInt()
	method getPadInt()
	
	method setOpeOri()
	method getOpeOri()
	
	method setCodPla()
	method getCodPla()
	
	method setModPag()
	method getModPag()
	
	method setTipUsr()
	method getTipUsr()
	
	method setInterc()
	method getInterc()
	
	method setValCar()
	method getValCar()
	
	method setCrtCNS()
	method getCrtCNS()

	method setNomSoci()
	method getNomSoci()	
	
	method New() Constructor
	
endClass

method new() class VO_Beneficiario	

	::cOpeUsr	:= ""
	::cMatAnt	:= ""
	::cNomUsr	:= ""
	::cMatXml	:= ""
	::cCodEmp	:= ""
	::cMatric	:= ""
	::cTipReg	:= ""
	::cCpfUsr	:= ""
	::cIdUsr 	:= ""
	::cDatNas	:= ""
	::cDigito	:= ""
	::cConEmp	:= ""
	::cVerCon	:= ""
	::cSubCon	:= ""
	::cVerSub	:= ""
	::cMatVid	:= ""
	::cTipPac	:= ""
	::cMatUsa	:= ""
	::cAteRna	:= ""
	::cPadCon	:= ""
	::cPadInt	:= ""
	::cValCar	:= ""
	       
	::cOpeOri 	:= ""
	::cCodPla 	:= ""
	::cModPag 	:= ""
	::cTipUsr 	:= ""
	::cInterc 	:= ""
	::cCrtNS  	:= ""	
	::cNomSocG 	:= ""	

return self

//-------------------------------------------------------------------
/*/{Protheus.doc} setOpeUsr
Seta o valor cOpeUsr
@authorKarine Riquena Limp
@since03/06/2016
@version P12
/*/
//-------------------------------------------------------------------
method setOpeUsr(cOpeUsr) class VO_Beneficiario
    ::cOpeUsr := cOpeUsr
return 

//-------------------------------------------------------------------
/*/{Protheus.doc} getOpeUsr
Retorna o valor cOpeUsr
@author Karine Riquena Limp
@since 03/06/2016
@version P12
/*/
//-------------------------------------------------------------------
method getOpeUsr() class VO_Beneficiario
return(::cOpeUsr)

//-------------------------------------------------------------------
/*/{Protheus.doc} setMatAnt
Seta o valor cMatAnt
@authorKarine Riquena Limp
@since03/06/2016
@version P12
/*/
//-------------------------------------------------------------------
method setMatAnt(cMatAnt) class VO_Beneficiario
    ::cMatAnt := cMatAnt
return 

//-------------------------------------------------------------------
/*/{Protheus.doc} getMatAnt
Retorna o valor cMatAnt
@author Karine Riquena Limp
@since 03/06/2016
@version P12
/*/
//-------------------------------------------------------------------
method getMatAnt() class VO_Beneficiario
return(::cMatAnt)

//-------------------------------------------------------------------
/*/{Protheus.doc} setNomUsr
Seta o valor cNomUsr
@authorKarine Riquena Limp
@since03/06/2016
@version P12
/*/
//-------------------------------------------------------------------
method setNomUsr(cNomUsr) class VO_Beneficiario
    ::cNomUsr := cNomUsr
return 

//-------------------------------------------------------------------
/*/{Protheus.doc} getNomUsr
Retorna o valor cNomUsr
@author Karine Riquena Limp
@since 03/06/2016
@version P12
/*/
//-------------------------------------------------------------------
method getNomUsr() class VO_Beneficiario
return(::cNomUsr)

//-------------------------------------------------------------------
/*/{Protheus.doc} setMatXml
Seta o valor cMatXml
@authorKarine Riquena Limp
@since03/06/2016
@version P12
/*/
//-------------------------------------------------------------------
method setMatXml(cMatXml) class VO_Beneficiario
    ::cMatXml := cMatXml
return 

//-------------------------------------------------------------------
/*/{Protheus.doc} getMatXml
Retorna o valor cMatXml
@author Karine Riquena Limp
@since 03/06/2016
@version P12
/*/
//-------------------------------------------------------------------
method getMatXml() class VO_Beneficiario
return(::cMatXml)

//-------------------------------------------------------------------
/*/{Protheus.doc} setCodEmp
Seta o valor cCodEmp
@authorKarine Riquena Limp
@since03/06/2016
@version P12
/*/
//-------------------------------------------------------------------
method setCodEmp(cCodEmp) class VO_Beneficiario
    ::cCodEmp := cCodEmp
return 

//-------------------------------------------------------------------
/*/{Protheus.doc} getCodEmp
Retorna o valor cCodEmp
@author Karine Riquena Limp
@since 03/06/2016
@version P12
/*/
//-------------------------------------------------------------------
method getCodEmp() class VO_Beneficiario
return(::cCodEmp)

//-------------------------------------------------------------------
/*/{Protheus.doc} setMatric
Seta o valor cMatric
@authorKarine Riquena Limp
@since03/06/2016
@version P12
/*/
//-------------------------------------------------------------------
method setMatric(cMatric) class VO_Beneficiario
    ::cMatric := cMatric
return 

//-------------------------------------------------------------------
/*/{Protheus.doc} getMatric
Retorna o valor cMatric
@author Karine Riquena Limp
@since 03/06/2016
@version P12
/*/
//-------------------------------------------------------------------
method getMatric() class VO_Beneficiario
return(::cMatric)

//-------------------------------------------------------------------
/*/{Protheus.doc} setTipReg
Seta o valor cTipReg
@authorKarine Riquena Limp
@since03/06/2016
@version P12
/*/
//-------------------------------------------------------------------
method setTipReg(cTipReg) class VO_Beneficiario
    ::cTipReg := cTipReg
return 

//-------------------------------------------------------------------
/*/{Protheus.doc} getTipReg
Retorna o valor cTipReg
@author Karine Riquena Limp
@since 03/06/2016
@version P12
/*/
//-------------------------------------------------------------------
method getTipReg() class VO_Beneficiario
return(::cTipReg)

//-------------------------------------------------------------------
/*/{Protheus.doc} setCpfUsr
Seta o valor cCpfUsr
@authorKarine Riquena Limp
@since03/06/2016
@version P12
/*/
//-------------------------------------------------------------------
method setCpfUsr(cCpfUsr) class VO_Beneficiario
    ::cCpfUsr := cCpfUsr
return 

//-------------------------------------------------------------------
/*/{Protheus.doc} getCpfUsr
Retorna o valor cCpfUsr
@author Karine Riquena Limp
@since 03/06/2016
@version P12
/*/
//-------------------------------------------------------------------
method getCpfUsr() class VO_Beneficiario
return(::cCpfUsr)

//-------------------------------------------------------------------
/*/{Protheus.doc} setIdUsr
Seta o valor cIdUsr
@authorKarine Riquena Limp
@since03/06/2016
@version P12
/*/
//-------------------------------------------------------------------
method setIdUsr(cIdUsr) class VO_Beneficiario
    ::cIdUsr := cIdUsr
return 

//-------------------------------------------------------------------
/*/{Protheus.doc} getIdUsr
Retorna o valor cIdUsr
@author Karine Riquena Limp
@since 03/06/2016
@version P12
/*/
//-------------------------------------------------------------------
method getIdUsr() class VO_Beneficiario
return(::cIdUsr)

//-------------------------------------------------------------------
/*/{Protheus.doc} setDatNas
Seta o valor cDatNas
@authorKarine Riquena Limp
@since03/06/2016
@version P12
/*/
//-------------------------------------------------------------------
method setDatNas(cDatNas) class VO_Beneficiario
    ::cDatNas := cDatNas
return 

//-------------------------------------------------------------------
/*/{Protheus.doc} getDatNas
Retorna o valor cDatNas
@author Karine Riquena Limp
@since 03/06/2016
@version P12
/*/
//-------------------------------------------------------------------
method getDatNas() class VO_Beneficiario
return(::cDatNas)

//-------------------------------------------------------------------
/*/{Protheus.doc} setDigito
Seta o valor cDigito
@authorKarine Riquena Limp
@since03/06/2016
@version P12
/*/
//-------------------------------------------------------------------
method setDigito(cDigito) class VO_Beneficiario
    ::cDigito := cDigito
return 

//-------------------------------------------------------------------
/*/{Protheus.doc} getDigito
Retorna o valor cDigito
@author Karine Riquena Limp
@since 03/06/2016
@version P12
/*/
//-------------------------------------------------------------------
method getDigito() class VO_Beneficiario
return(::cDigito)

//-------------------------------------------------------------------
/*/{Protheus.doc} setConEmp
Seta o valor cConEmp
@authorKarine Riquena Limp
@since03/06/2016
@version P12
/*/
//-------------------------------------------------------------------
method setConEmp(cConEmp) class VO_Beneficiario
    ::cConEmp := cConEmp
return 

//-------------------------------------------------------------------
/*/{Protheus.doc} getConEmp
Retorna o valor cConEmp
@author Karine Riquena Limp
@since 03/06/2016
@version P12
/*/
//-------------------------------------------------------------------
method getConEmp() class VO_Beneficiario
return(::cConEmp)

//-------------------------------------------------------------------
/*/{Protheus.doc} setVerCon
Seta o valor cVerCon
@authorKarine Riquena Limp
@since03/06/2016
@version P12
/*/
//-------------------------------------------------------------------
method setVerCon(cVerCon) class VO_Beneficiario
    ::cVerCon := cVerCon
return 

//-------------------------------------------------------------------
/*/{Protheus.doc} getVerCon
Retorna o valor cVerCon
@author Karine Riquena Limp
@since 03/06/2016
@version P12
/*/
//-------------------------------------------------------------------
method getVerCon() class VO_Beneficiario
return(::cVerCon)

//-------------------------------------------------------------------
/*/{Protheus.doc} setSubCon
Seta o valor cSubCon
@authorKarine Riquena Limp
@since03/06/2016
@version P12
/*/
//-------------------------------------------------------------------
method setSubCon(cSubCon) class VO_Beneficiario
    ::cSubCon := cSubCon
return 

//-------------------------------------------------------------------
/*/{Protheus.doc} getSubCon
Retorna o valor cSubCon
@author Karine Riquena Limp
@since 03/06/2016
@version P12
/*/
//-------------------------------------------------------------------
method getSubCon() class VO_Beneficiario
return(::cSubCon)

//-------------------------------------------------------------------
/*/{Protheus.doc} setVerSub
Seta o valor cVerSub
@authorKarine Riquena Limp
@since03/06/2016
@version P12
/*/
//-------------------------------------------------------------------
method setVerSub(cVerSub) class VO_Beneficiario
    ::cVerSub := cVerSub
return 

//-------------------------------------------------------------------
/*/{Protheus.doc} getVerSub
Retorna o valor cVerSub
@author Karine Riquena Limp
@since 03/06/2016
@version P12
/*/
//-------------------------------------------------------------------
method getVerSub() class VO_Beneficiario
return(::cVerSub)

//-------------------------------------------------------------------
/*/{Protheus.doc} setMatVid
Seta o valor cMatVid
@authorKarine Riquena Limp
@since03/06/2016
@version P12
/*/
//-------------------------------------------------------------------
method setMatVid(cMatVid) class VO_Beneficiario
    ::cMatVid := cMatVid
return 

//-------------------------------------------------------------------
/*/{Protheus.doc} getMatVid
Retorna o valor cMatVid
@author Karine Riquena Limp
@since 03/06/2016
@version P12
/*/
//-------------------------------------------------------------------
method getMatVid() class VO_Beneficiario
return(::cMatVid)

//-------------------------------------------------------------------
/*/{Protheus.doc} setTipPac
Seta o valor cTipPac
@authorKarine Riquena Limp
@since03/06/2016
@version P12
/*/
//-------------------------------------------------------------------
method setTipPac(cTipPac) class VO_Beneficiario
    ::cTipPac := cTipPac
return 

//-------------------------------------------------------------------
/*/{Protheus.doc} getTipPac
Retorna o valor cTipPac
@author Karine Riquena Limp
@since 03/06/2016
@version P12
/*/
//-------------------------------------------------------------------
method getTipPac() class VO_Beneficiario
return(::cTipPac)

//-------------------------------------------------------------------
/*/{Protheus.doc} setMatUsa
Seta o valor cMatUsa
@authorKarine Riquena Limp
@since03/06/2016
@version P12
/*/
//-------------------------------------------------------------------
method setMatUsa(cMatUsa) class VO_Beneficiario
    ::cMatUsa := cMatUsa
return 

//-------------------------------------------------------------------
/*/{Protheus.doc} getMatUsa
Retorna o valor cMatUsa
@author Karine Riquena Limp
@since 03/06/2016
@version P12
/*/
//-------------------------------------------------------------------
method getMatUsa() class VO_Beneficiario
return(::cMatUsa)

//-------------------------------------------------------------------
/*/{Protheus.doc} setAteRna
Seta o valor cAteRna
@authorKarine Riquena Limp
@since03/06/2016
@version P12
/*/
//-------------------------------------------------------------------
method setAteRna(cAteRna) class VO_Beneficiario
    ::cAteRna := cAteRna
return 

//-------------------------------------------------------------------
/*/{Protheus.doc} getAteRna
Retorna o valor cAteRna
@author Karine Riquena Limp
@since 03/06/2016
@version P12
/*/
//-------------------------------------------------------------------
method getAteRna() class VO_Beneficiario
return(::cAteRna)

//-------------------------------------------------------------------
/*/{Protheus.doc} setPadCon
Seta o valor cPadCon
@authorKarine Riquena Limp
@since03/06/2016
@version P12
/*/
//-------------------------------------------------------------------
method setPadCon(cPadCon) class VO_Beneficiario
    ::cPadCon := cPadCon
return 

//-------------------------------------------------------------------
/*/{Protheus.doc} getPadCon
Retorna o valor cPadCon
@author Karine Riquena Limp
@since 03/06/2016
@version P12
/*/
//-------------------------------------------------------------------
method getPadCon() class VO_Beneficiario
return(::cPadCon)

//-------------------------------------------------------------------
/*/{Protheus.doc} setPadInt
Seta o valor cPadInt
@authorKarine Riquena Limp
@since03/06/2016
@version P12
/*/
//-------------------------------------------------------------------
method setPadInt(cPadInt) class VO_Beneficiario
    ::cPadInt := cPadInt
return 

//-------------------------------------------------------------------
/*/{Protheus.doc} getPadInt
Retorna o valor cPadInt
@author Karine Riquena Limp
@since 03/06/2016
@version P12
/*/
//-------------------------------------------------------------------
method getPadInt() class VO_Beneficiario
return(::cPadInt)

//-------------------------------------------------------------------
/*/{Protheus.doc} setOpeOri
Seta o valor cOpeOri
@authorKarine Riquena Limp
@since03/06/2016
@version P12
/*/
//-------------------------------------------------------------------
method setOpeOri(cOpeOri) class VO_Beneficiario
    ::cOpeOri := cOpeOri
return 

//-------------------------------------------------------------------
/*/{Protheus.doc} getOpeOri
Retorna o valor cOpeOri
@author Karine Riquena Limp
@since 03/06/2016
@version P12
/*/
//-------------------------------------------------------------------
method getOpeOri() class VO_Beneficiario
return(::cOpeOri)

//-------------------------------------------------------------------
/*/{Protheus.doc} setCodPla
Seta o valor cCodPla
@authorKarine Riquena Limp
@since03/06/2016
@version P12
/*/
//-------------------------------------------------------------------
method setCodPla(cCodPla) class VO_Beneficiario
    ::cCodPla := cCodPla
return 

//-------------------------------------------------------------------
/*/{Protheus.doc} getCodPla
Retorna o valor cCodPla
@author Karine Riquena Limp
@since 03/06/2016
@version P12
/*/
//-------------------------------------------------------------------
method getCodPla() class VO_Beneficiario
return(::cCodPla)

//-------------------------------------------------------------------
/*/{Protheus.doc} setModPag
Seta o valor cModPag
@authorKarine Riquena Limp
@since03/06/2016
@version P12
/*/
//-------------------------------------------------------------------
method setModPag(cModPag) class VO_Beneficiario
    ::cModPag := cModPag
return 

//-------------------------------------------------------------------
/*/{Protheus.doc} getModPag
Retorna o valor cModPag
@author Karine Riquena Limp
@since 03/06/2016
@version P12
/*/
//-------------------------------------------------------------------
method getModPag() class VO_Beneficiario
return(::cModPag)

//-------------------------------------------------------------------
/*/{Protheus.doc} setTipUsr
Seta o valor cTipUsr
@authorKarine Riquena Limp
@since03/06/2016
@version P12
/*/
//-------------------------------------------------------------------
method setTipUsr(cTipUsr) class VO_Beneficiario
    ::cTipUsr := cTipUsr
return 

//-------------------------------------------------------------------
/*/{Protheus.doc} getTipUsr
Retorna o valor cTipUsr
@author Karine Riquena Limp
@since 03/06/2016
@version P12
/*/
//-------------------------------------------------------------------
method getTipUsr() class VO_Beneficiario
return(::cTipUsr)

//-------------------------------------------------------------------
/*/{Protheus.doc} setInterc
Seta o valor cInterc
@authorKarine Riquena Limp
@since03/06/2016
@version P12
/*/
//-------------------------------------------------------------------
method setInterc(cInterc) class VO_Beneficiario
    ::cInterc := cInterc
return 

//-------------------------------------------------------------------
/*/{Protheus.doc} getInterc
Retorna o valor cInterc
@author Karine Riquena Limp
@since 03/06/2016
@version P12
/*/
//-------------------------------------------------------------------
method getInterc() class VO_Beneficiario
return(::cInterc)


/*/{Protheus.doc} getValCar
Retorna o valor da validade Carteirinha
@author Renan Martins
@since03/2017
@version P12
/*/
//-------------------------------------------------------------------
method getValCar() class VO_Beneficiario
return(::cValcar)

//-------------------------------------------------------------------
/*/{Protheus.doc} setValCar
Seta o valor da validade carteirinha
@author Renan Martins
@since03/2017
@version P12
/*/
//-------------------------------------------------------------------
method setValCar(cValCar) class VO_Beneficiario
    ::cValCar := cValCar
return 

/*/{Protheus.doc} getCrtCNS
Retorna o número da CNS
@author Renan Martins
@since03/2017
@version P12
/*/
//-------------------------------------------------------------------
method getCrtCNS() class VO_Beneficiario
return(::cCrtNS)

//-------------------------------------------------------------------
/*/{Protheus.doc} setCrtCNS
Seta o valor da CNS
@author Renan Martins
@since03/2017
@version P12
/*/
//-------------------------------------------------------------------
method setCrtCNS(cCrtNS) class VO_Beneficiario
    ::cCrtNS := cCrtNS
return 


/*/{Protheus.doc} getCrtCNS
Retorna Nome Social
@since 04/2022
@version P12
/*/
//-------------------------------------------------------------------
method getNomSoci() class VO_Beneficiario
return(::cNomSocG)

//-------------------------------------------------------------------
/*/{Protheus.doc} setCrtCNS
Seta Nome Social
@since 04/2022
@version P12
/*/
//-------------------------------------------------------------------
method setNomSoci(cNomSocG) class VO_Beneficiario
    ::cNomSocG := cNomSocG
return 




//-------------------------------------------------------------------
/*/{Protheus.doc} VO_Beneficiario
Somente para compilar a classe
@author Karine Riquena Limp
@since 20/05/2016
@version P12
/*/
//-------------------------------------------------------------------
Function VO_Beneficiario
Return
