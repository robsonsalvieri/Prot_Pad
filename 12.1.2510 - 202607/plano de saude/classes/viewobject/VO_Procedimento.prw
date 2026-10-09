#INCLUDE "TOTVS.CH"
#INCLUDE "FWMVCDEF.CH"

class VO_Procedimento
	
	//Campos para o Reembolso que não devem ser Replicados da BD5
	data cMatAnt as String HIDDEN //BD5_MATANT | BD6_MATANT
	data cNomUsr as String HIDDEN //BD5_NOMUSR | BD6_NOMUSR
	data cMatric as String HIDDEN //BD5_MATRIC | BD6_MATRIC
	
	//Campos da BD6 que não são replicados 
	data cSeqMov        as String  HIDDEN//BD6->BD6_SEQUEN
	data cCodPad        as String  HIDDEN//BD6->BD6_CODPAD  
	
	data cSlvPad        as String  HIDDEN//BD6->BD6_SLVPAD
	data cCodPro        as String  HIDDEN//BD6->BD6_CODPRO
	data cSlvPro        as String  HIDDEN//BD6->BD6_SLVPRO
	data cDesPro        as String  HIDDEN//BD6->BD6_DESPRO

	data cProtoc        as String  HIDDEN//BD6->BD6_PROTOC

	data cNivel         as String  HIDDEN//BD6->BD6_NIVEL
	data nVlrApr        as Numeric HIDDEN//BD6->BD6_VLRAPR
	data nVlrMan		as Numeric HIDDEN
	data nQtd           as Numeric HIDDEN//BD6->BD6_QTDPRO - BD6->BD6_QTDAPR
	data nPerVia        as Numeric HIDDEN//BD6->BD6_PERVIA
	data cCodVia        as String  HIDDEN//BD6->BD6_VIA
	data cProcCirurgico as String  HIDDEN//BD6->BD6_PROCCI
	data dDtPro         as Date    HIDDEN//BD6->BD6_DATPRO
	data cHorIni        as String  HIDDEN//BD6->BD6_HORPRO
	data cHorFim        as String  HIDDEN//BD6->BD6_HORFIM

	data cIncAut        as String  HIDDEN//BD6->BD6_INCAUT
	data cStatus        as String  HIDDEN//BD6->BD6_STATUS
	data cChvNiv        as String  HIDDEN//BD6->BD6_CHVNIV
	data cNivAut        as String  HIDDEN//BD6->BD6_NIVAUT

	data cCodTab        as String  HIDDEN//BD6->BD6_CODTAB
	data cAliaTb        as String  HIDDEN//BD6->BD6_ALIATB
	data cBloqPag       as String  HIDDEN//BD6->BD6_BLOPAG
	data cInterc        as String  HIDDEN//BD6->BD6_INTERC
	data cTipInt        as String  HIDDEN//BD6->BD6_TIPINT
	data cTecUti 	    as String  HIDDEN//BD6->BD6_TECUTI
	data cCodDes        as String  HIDDEN//BX6->BX6_CODDES
	data lAoDesp        as Logical HIDDEN//BX6->BX6_AODESP
	data nPrPrRl        as Float   HIDDEN//BD6->BD6_PRPRRL // PERCENTUAL DE REDUCAO DE ACRESCIMO	
	data aPart          as Array   HIDDEN	
	data nSeqModel		as Numeric HIDDEN
	data cTpProc		as String  HIDDEN//BR8->BR8_TPPROC
	
	//Campos adicionais da guia outras despesas
	data cAutFun		as String HIDDEN
	data cRefMatFab		as String HIDDEN
	data cRegAnvisa		as String HIDDEN
	data cUniMedida		as String HIDDEN
		
	method New() Constructor
	
	method setSeqMov()
	method getSeqMov()
	
	method setCodPad()
	method getCodPad()
	
	method setSlvPad()
	method getSlvPad()
	
	method setCodPro()
	method getCodPro()

	method setProtoc()
	method getProtoc()
	
	method setSlvPro()
	method getSlvPro()
	
	method setDesPro()
	method getDesPro()
	
	method setNivel()
	method getNivel()
	
	method setVlrApr()
	method getVlrApr()
	
	method setVlrMan()
	method getVlrMan()
	
	method setQtd()
	method getQtd()
	
	method setPerVia()
	method getPerVia()
	
	method setCodVia()
	method getCodVia()
	
	method setProcCirurgico()
	method getProcCirurgico()
	
	method setDtPro()
	method getDtPro()
	
	method setHorIni()
	method getHorIni()
	
	method setHorFim()
	method getHorFim()
	
	
	method setIncAut()
	method getIncAut()
	
	method setStatus()
	method getStatus()
	
	method setChvNiv()
	method getChvNiv()
	
	method setNivAut()
	method getNivAut()
	
	method setCodTab()
	method getCodTab()
	
	method setAliaTb()
	method getAliaTb()
	
	method setBloqPag()
	method getBloqPag()
	
	method setInterc()
	method getInterc()
	
	method setTipInt()
	method getTipInt()
	
	method getTecUti()
	method setTecUti()
	
	method getCodDes()
	method setCodDes()
	
	method getAoDesp()
	method setAoDesp()
	
	method getPrPrRl()
	method setPrPrRl()
	
	method setPart()
	method getPart()
	
	method setSeqModel()
	method getSeqModel()
	
	method getAutFun()
	method setAutFun()
	
	method getRefMatFab()
	method setRefMatFab()
	
	method setRegAnvisa()
	method getRegAnvisa()
	
	method setUniMedida()
	method getUniMedida()
	
	method setMatAnt()
	method getMatAnt()
	
	method setNomUsr()
	method getNomUsr()
	
	method setMatric()
	method getMatric()
	
	method setTpProc()
	method getTpProc()

endClass

method new() class VO_Procedimento

	::cSeqMov 		 := ""
	::cCodPad 		 := ""
	::cSlvPad 		 := ""
	::cCodPro 		 := ""
	::cProtoc 		 := ""
	::cSlvPro 		 := ""
	::cDesPro 		 := ""
	::cNivel		 := ""
	::nVlrApr		 := 0
	::nVlrMan		 := 0
	::nQtd	 		 := 0
	::nPerVia	 	 := 0
	::cCodVia	 	 := ""
	::cProcCirurgico := ""
	::dDtPro		 := Date()
	::cHorIni		 := ""
	::cHorFim		 := ""
	::cIncAut		 := """
	::cStatus 		 := ""
	::cChvNiv 		 := ""
	::cNivAut 		 := """
	::cCodTab		 := ""
	::cAliaTb		 := ""
	::cBloqPag   	 := ""
	::cInterc		 := ""
	::cTipInt		 := ""
	::cTecUti		 := ""
	::cCodDes		 := ""
   	::lAoDesp		 := .F.
   	::nPrPrRl		 := 0
	::aPart        	 := {}
	::nSeqModel		 := 0
	::cAutFun		 := ""
	::cRefMatFab	 := ""
	::cRegAnvisa	 := ""
	::cUniMedida	 := ""
	::cTpProc		 := ""
	
	::cMatAnt 		 := ""
	::cNomUsr		 := ""
	::cMatric		 := ""
	
return self



//-------------------------------------------------------------------
/*/{Protheus.doc} v
@author Roberto Vanderlei
@since14/02/2017
@version P12
/*/
//-------------------------------------------------------------------
method setMatAnt(cMatAnt) class VO_Procedimento
    ::cMatAnt := cMatAnt
return 

method getMatAnt() class VO_Procedimento
return(::cMatAnt)


method setNomUsr(cNomUsr) class VO_Procedimento
    ::cNomUsr := cNomUsr
return 

method getNomUsr() class VO_Procedimento
return(::cNomUsr)


method setMatric(cMatric) class VO_Procedimento
    ::cMatric := cMatric
return 

method getMatric() class VO_Procedimento
return(::cMatric)



//-------------------------------------------------------------------
/*/{Protheus.doc} setSeqMov
Seta o valor cSeqMov
@author Roberto Vanderlei
@since03/06/2016
@version P12
/*/
//-------------------------------------------------------------------
method setSeqMov(cSeqMov) class VO_Procedimento
    ::cSeqMov := cSeqMov
return 

//-------------------------------------------------------------------
/*/{Protheus.doc} getSeqMov
Retorna o valor cSeqMov
@author Roberto Vanderlei
@since 24/05/2016
@version P12
/*/
//-------------------------------------------------------------------
method getSeqMov() class VO_Procedimento
return(::cSeqMov)

//-------------------------------------------------------------------
/*/{Protheus.doc} setCodPad
Seta o valor cCodPad
@author Roberto Vanderlei
@since03/06/2016
@version P12
/*/
//-------------------------------------------------------------------
method setCodPad(cCodPad) class VO_Procedimento
    ::cCodPad := cCodPad
return 

//-------------------------------------------------------------------
/*/{Protheus.doc} getCodPad
Retorna o valor cCodPad
@author Roberto Vanderlei
@since 24/05/2016
@version P12
/*/
//-------------------------------------------------------------------
method getCodPad() class VO_Procedimento
return(::cCodPad)

//-------------------------------------------------------------------
/*/{Protheus.doc} setSlvPad
Seta o valor cSlvPad
@author Roberto Vanderlei
@since03/06/2016
@version P12
/*/
//-------------------------------------------------------------------
method setSlvPad(cSlvPad) class VO_Procedimento
    ::cSlvPad := cSlvPad
return 

//-------------------------------------------------------------------
/*/{Protheus.doc} getSlvPad
Retorna o valor cSlvPad
@author Roberto Vanderlei
@since 24/05/2016
@version P12
/*/
//-------------------------------------------------------------------
method getSlvPad() class VO_Procedimento
return(::cSlvPad)

//-------------------------------------------------------------------
/*/{Protheus.doc} setCodPro
Seta o valor cCodPro
@author Roberto Vanderlei
@since03/06/2016
@version P12
/*/
//-------------------------------------------------------------------
method setCodPro(cCodPro) class VO_Procedimento
    ::cCodPro := cCodPro
return 

//-------------------------------------------------------------------
/*/{Protheus.doc} getCodPro
Retorna o valor cCodPro
@author Roberto Vanderlei
@since 24/05/2016
@version P12
/*/
//-------------------------------------------------------------------
method getCodPro() class VO_Procedimento
return(::cCodPro)

//-------------------------------------------------------------------
/*/{Protheus.doc} setProtoc
Seta o Protocolo de reembolso
@author PLSTEAM
@since 24/04/2017
@version P12
/*/
//-------------------------------------------------------------------
method setProtoc(cProtoc) class VO_Procedimento
    ::cProtoc := cProtoc
return 

//-------------------------------------------------------------------
/*/{Protheus.doc} getProtoc
Retorna o protocolo de reembolso
@author PLSTEAM
@since 24/04/2017
@version P12
/*/
//-------------------------------------------------------------------
method getProtoc() class VO_Procedimento
return(::cProtoc)

//-------------------------------------------------------------------
/*/{Protheus.doc} setSlvPro
Seta o valor cSlvPro
@author Roberto Vanderlei
@since03/06/2016
@version P12
/*/
//-------------------------------------------------------------------
method setSlvPro(cSlvPro) class VO_Procedimento
    ::cSlvPro := cSlvPro
return 

//-------------------------------------------------------------------
/*/{Protheus.doc} getSlvPro
Retorna o valor cSlvPro
@author Roberto Vanderlei
@since 24/05/2016
@version P12
/*/
//-------------------------------------------------------------------
method getSlvPro() class VO_Procedimento
return(::cSlvPro)

//-------------------------------------------------------------------
/*/{Protheus.doc} setDesPro
Seta o valor cDesPro
@author Roberto Vanderlei
@since03/06/2016
@version P12
/*/
//-------------------------------------------------------------------
method setDesPro(cDesPro) class VO_Procedimento
    ::cDesPro := cDesPro
return 

//-------------------------------------------------------------------
/*/{Protheus.doc} getDesPro
Retorna o valor cDesPro
@author Roberto Vanderlei
@since 24/05/2016
@version P12
/*/
//-------------------------------------------------------------------
method getDesPro() class VO_Procedimento
return(::cDesPro)

//-------------------------------------------------------------------
/*/{Protheus.doc} setNivel
Seta o valor cNivel
@author Roberto Vanderlei
@since03/06/2016
@version P12
/*/
//-------------------------------------------------------------------
method setNivel(cNivel) class VO_Procedimento
    ::cNivel := cNivel
return 

//-------------------------------------------------------------------
/*/{Protheus.doc} getNivel
Retorna o valor cNivel
@author Roberto Vanderlei
@since 24/05/2016
@version P12
/*/
//-------------------------------------------------------------------
method getNivel() class VO_Procedimento
return(::cNivel)

//-------------------------------------------------------------------
/*/{Protheus.doc} setVlrApr
Seta o valor nVlrApr
@author Roberto Vanderlei
@since03/06/2016
@version P12
/*/
//-------------------------------------------------------------------
method setVlrApr(nVlrApr) class VO_Procedimento
    ::nVlrApr := nVlrApr
return 

//-------------------------------------------------------------------
/*/{Protheus.doc} getVlrApr
Retorna o valor nVlrApr
@author Roberto Vanderlei
@since 24/05/2016
@version P12
/*/
//-------------------------------------------------------------------
method getVlrApr() class VO_Procedimento
return(::nVlrApr)

//-------------------------------------------------------------------
/*/{Protheus.doc} setQtd
Seta o valor nQtd
@author Roberto Vanderlei
@since03/06/2016
@version P12
/*/
//-------------------------------------------------------------------
method setQtd(nQtd) class VO_Procedimento
    ::nQtd := nQtd
return 

//-------------------------------------------------------------------
/*/{Protheus.doc} getQtd
Retorna o valor nQtd
@author Roberto Vanderlei
@since 24/05/2016
@version P12
/*/
//-------------------------------------------------------------------
method getQtd() class VO_Procedimento
return(::nQtd)

//-------------------------------------------------------------------
/*/{Protheus.doc} setPerVia
Seta o valor nPerVia
@author Roberto Vanderlei
@since03/06/2016
@version P12
/*/
//-------------------------------------------------------------------
method setPerVia(nPerVia) class VO_Procedimento
    ::nPerVia := nPerVia
return 

//-------------------------------------------------------------------
/*/{Protheus.doc} getPerVia
Retorna o valor nPerVia
@author Roberto Vanderlei
@since 24/05/2016
@version P12
/*/
//-------------------------------------------------------------------
method getPerVia() class VO_Procedimento
return(::nPerVia)

//-------------------------------------------------------------------
/*/{Protheus.doc} setCodVia
Seta o valor cCodVia
@author Roberto Vanderlei
@since03/06/2016
@version P12
/*/
//-------------------------------------------------------------------
method setCodVia(cCodVia) class VO_Procedimento
    ::cCodVia := cCodVia
return 

//-------------------------------------------------------------------
/*/{Protheus.doc} getCodVia
Retorna o valor cCodVia
@author Roberto Vanderlei
@since 24/05/2016
@version P12
/*/
//-------------------------------------------------------------------
method getCodVia() class VO_Procedimento
return(::cCodVia)

//-------------------------------------------------------------------
/*/{Protheus.doc} setProcCirurgico
Seta o valor cProcCirurgico
@author Roberto Vanderlei
@since03/06/2016
@version P12
/*/
//-------------------------------------------------------------------
method setProcCirurgico(cProcCirurgico) class VO_Procedimento
    ::cProcCirurgico := cProcCirurgico
return 

//-------------------------------------------------------------------
/*/{Protheus.doc} getProcCirurgico
Retorna o valor cProcCirurgico
@author Roberto Vanderlei
@since 24/05/2016
@version P12
/*/
//-------------------------------------------------------------------
method getProcCirurgico() class VO_Procedimento
return(::cProcCirurgico)

//-------------------------------------------------------------------
/*/{Protheus.doc} setDtPro
Seta o valor dDtPro
@author Roberto Vanderlei
@since03/06/2016
@version P12
/*/
//-------------------------------------------------------------------
method setDtPro(dDtPro) class VO_Procedimento
    ::dDtPro := dDtPro
return 

//-------------------------------------------------------------------
/*/{Protheus.doc} getDtPro
Retorna o valor dDtPro
@author Roberto Vanderlei
@since 24/05/2016
@version P12
/*/
//-------------------------------------------------------------------
method getDtPro() class VO_Procedimento
return(::dDtPro)

//-------------------------------------------------------------------
/*/{Protheus.doc} setHorIni
Seta o valor cHorIni
@author Roberto Vanderlei
@since03/06/2016
@version P12
/*/
//-------------------------------------------------------------------
method setHorIni(cHorIni) class VO_Procedimento
    ::cHorIni := cHorIni
return 

//-------------------------------------------------------------------
/*/{Protheus.doc} getHorIni
Retorna o valor cHorIni
@author Roberto Vanderlei
@since 24/05/2016
@version P12
/*/
//-------------------------------------------------------------------
method getHorIni() class VO_Procedimento
return(::cHorIni)

//-------------------------------------------------------------------
/*/{Protheus.doc} setHorFim
Seta o valor cHorFim
@author Roberto Vanderlei
@since03/06/2016
@version P12
/*/
//-------------------------------------------------------------------
method setHorFim(cHorFim) class VO_Procedimento
    ::cHorFim := cHorFim
return 

//-------------------------------------------------------------------
/*/{Protheus.doc} getHorFim
Retorna o valor cHorFim
@author Roberto Vanderlei
@since 24/05/2016
@version P12
/*/
//-------------------------------------------------------------------
method getHorFim() class VO_Procedimento
return(::cHorFim)

//-------------------------------------------------------------------
/*/{Protheus.doc} setIncAut
Seta o valor cIncAut
@author Roberto Vanderlei
@since03/06/2016
@version P12
/*/
//-------------------------------------------------------------------
method setIncAut(cIncAut) class VO_Procedimento
    ::cIncAut := cIncAut
return 

//-------------------------------------------------------------------
/*/{Protheus.doc} getIncAut
Retorna o valor cIncAut
@author Roberto Vanderlei
@since 24/05/2016
@version P12
/*/
//-------------------------------------------------------------------
method getIncAut() class VO_Procedimento
return(::cIncAut)

//-------------------------------------------------------------------
/*/{Protheus.doc} setStatus
Seta o valor cStatus
@author Roberto Vanderlei
@since03/06/2016
@version P12
/*/
//-------------------------------------------------------------------
method setStatus(cStatus) class VO_Procedimento
    ::cStatus := cStatus
return 

//-------------------------------------------------------------------
/*/{Protheus.doc} getStatus
Retorna o valor cStatus
@author Roberto Vanderlei
@since 24/05/2016
@version P12
/*/
//-------------------------------------------------------------------
method getStatus() class VO_Procedimento
return(::cStatus)

//-------------------------------------------------------------------
/*/{Protheus.doc} setChvNiv
Seta o valor cChvNiv
@author Roberto Vanderlei
@since03/06/2016
@version P12
/*/
//-------------------------------------------------------------------
method setChvNiv(cChvNiv) class VO_Procedimento
    ::cChvNiv := cChvNiv
return 

//-------------------------------------------------------------------
/*/{Protheus.doc} getChvNiv
Retorna o valor cChvNiv
@author Roberto Vanderlei
@since 24/05/2016
@version P12
/*/
//-------------------------------------------------------------------
method getChvNiv() class VO_Procedimento
return(::cChvNiv)

//-------------------------------------------------------------------
/*/{Protheus.doc} setNivAut
Seta o valor cNivAut
@author Roberto Vanderlei
@since03/06/2016
@version P12
/*/
//-------------------------------------------------------------------
method setNivAut(cNivAut) class VO_Procedimento
    ::cNivAut := cNivAut
return 

//-------------------------------------------------------------------
/*/{Protheus.doc} getNivAut
Retorna o valor cNivAut
@author Roberto Vanderlei
@since 24/05/2016
@version P12
/*/
//-------------------------------------------------------------------
method getNivAut() class VO_Procedimento
return(::cNivAut)

//-------------------------------------------------------------------
/*/{Protheus.doc} setCodTab
Seta o valor cCodTab
@author Roberto Vanderlei
@since03/06/2016
@version P12
/*/
//-------------------------------------------------------------------
method setCodTab(cCodTab) class VO_Procedimento
    ::cCodTab := cCodTab
return 

//-------------------------------------------------------------------
/*/{Protheus.doc} getCodTab
Retorna o valor cCodTab
@author Roberto Vanderlei
@since 24/05/2016
@version P12
/*/
//-------------------------------------------------------------------
method getCodTab() class VO_Procedimento
return(::cCodTab)

//-------------------------------------------------------------------
/*/{Protheus.doc} setAliaTb
Seta o valor cAliaTb
@author Roberto Vanderlei
@since03/06/2016
@version P12
/*/
//-------------------------------------------------------------------
method setAliaTb(cAliaTb) class VO_Procedimento
    ::cAliaTb := cAliaTb
return 

//-------------------------------------------------------------------
/*/{Protheus.doc} getAliaTb
Retorna o valor cAliaTb
@author Roberto Vanderlei
@since 24/05/2016
@version P12
/*/
//-------------------------------------------------------------------
method getAliaTb() class VO_Procedimento
return(::cAliaTb)

//-------------------------------------------------------------------
/*/{Protheus.doc} setBloqPag
Seta o valor cBloqPag
@author Roberto Vanderlei
@since03/06/2016
@version P12
/*/
//-------------------------------------------------------------------
method setBloqPag(cBloqPag) class VO_Procedimento
    ::cBloqPag := cBloqPag
return 

//-------------------------------------------------------------------
/*/{Protheus.doc} getBloqPag
Retorna o valor cBloqPag
@author Roberto Vanderlei
@since 24/05/2016
@version P12
/*/
//-------------------------------------------------------------------
method getBloqPag() class VO_Procedimento
return(::cBloqPag)

//-------------------------------------------------------------------
/*/{Protheus.doc} setInterc
Seta o valor cInterc
@author Roberto Vanderlei
@since03/06/2016
@version P12
/*/
//-------------------------------------------------------------------
method setInterc(cInterc) class VO_Procedimento
    ::cInterc := cInterc
return 

//-------------------------------------------------------------------
/*/{Protheus.doc} getInterc
Retorna o valor cInterc
@author Roberto Vanderlei
@since 24/05/2016
@version P12
/*/
//-------------------------------------------------------------------
method getInterc() class VO_Procedimento
return(::cInterc)

//-------------------------------------------------------------------
/*/{Protheus.doc} setTipInt
Seta o valor cTipInt
@author Roberto Vanderlei
@since03/06/2016
@version P12
/*/
//-------------------------------------------------------------------
method setTipInt(cTipInt) class VO_Procedimento
    ::cTipInt := cTipInt
return 

//-------------------------------------------------------------------
/*/{Protheus.doc} getTipInt
Retorna o valor cTipInt
@author Roberto Vanderlei
@since 24/05/2016
@version P12
/*/
//-------------------------------------------------------------------
method getTipInt() class VO_Procedimento
return(::cTipInt)

//-------------------------------------------------------------------
/*/{Protheus.doc} setTecUti
Seta o valor cTecUti
@author Roberto Vanderlei
@since03/06/2016
@version P12
/*/
//-------------------------------------------------------------------
method setTecUti(cTecUti) class VO_Procedimento
    ::cTecUti := cTecUti
return 

//-------------------------------------------------------------------
/*/{Protheus.doc} getTecUti
Retorna o valor cTecUti
@author Roberto Vanderlei
@since 24/05/2016
@version P12
/*/
//-------------------------------------------------------------------
method getTecUti() class VO_Procedimento
return(::cTecUti)

//-------------------------------------------------------------------
/*/{Protheus.doc} setCodDes
Seta o valor cCodDes
@author Roberto Vanderlei
@since03/06/2016
@version P12
/*/
//-------------------------------------------------------------------
method setCodDes(cCodDes) class VO_Procedimento
    ::cCodDes := cCodDes
return 

//-------------------------------------------------------------------
/*/{Protheus.doc} getCodDes
Retorna o valor cCodDes
@author Roberto Vanderlei
@since 24/05/2016
@version P12
/*/
//-------------------------------------------------------------------
method getCodDes() class VO_Procedimento
return(::cCodDes)

//-------------------------------------------------------------------
/*/{Protheus.doc} setAoDesp
Seta o valor lAoDesp
@author Roberto Vanderlei
@since03/06/2016
@version P12
/*/
//-------------------------------------------------------------------
method setAoDesp(lAoDesp) class VO_Procedimento
    ::lAoDesp := lAoDesp
return 

//-------------------------------------------------------------------
/*/{Protheus.doc} getAoDesp
Retorna o valor lAoDesp
@author Roberto Vanderlei
@since 24/05/2016
@version P12
/*/
//-------------------------------------------------------------------
method getAoDesp() class VO_Procedimento
return(::lAoDesp)

//-------------------------------------------------------------------
/*/{Protheus.doc} setPrPrRl
Seta o valor nPrPrRl
@author Roberto Vanderlei
@since03/06/2016
@version P12
/*/
//-------------------------------------------------------------------
method setPrPrRl(nPrPrRl) class VO_Procedimento
    ::nPrPrRl := nPrPrRl
return 

//-------------------------------------------------------------------
/*/{Protheus.doc} getPrPrRl
Retorna o valor nPrPrRl
@author Roberto Vanderlei
@since 24/05/2016
@version P12
/*/
//-------------------------------------------------------------------
method getPrPrRl() class VO_Procedimento
return(::nPrPrRl)

//-------------------------------------------------------------------
/*/{Protheus.doc} setVlrMan
Seta o valor nVlrMan
@author Roberto Vanderlei
@since03/06/2016
@version P12
/*/
//-------------------------------------------------------------------
method setVlrMan(nVlrMan) class VO_Procedimento
    ::nVlrMan := nVlrMan
return 

//-------------------------------------------------------------------
/*/{Protheus.doc} getVlrMan
Retorna o valor VlrMan
@author Roberto Vanderlei
@since 24/05/2016
@version P12
/*/
//-------------------------------------------------------------------
method getVlrMan() class VO_Procedimento
return(::nVlrMan)


//-------------------------------------------------------------------
/*/{Protheus.doc} setPart
Seta o valor aPart
@author Karine Riquena Limp
@since 24/05/2016
@version P12
/*/
//-------------------------------------------------------------------
method setPart(aPart) class VO_Procedimento
    ::aPart := aPart
return 

//-------------------------------------------------------------------
/*/{Protheus.doc} getPart
Retorna o valor aPart
@author Karine Riquena Limp
@since 24/05/2016
@version P12
/*/
//-------------------------------------------------------------------
method getPart() class VO_Procedimento
return(::aPart)

//-------------------------------------------------------------------
/*/{Protheus.doc} setSeqModel
Seta o valor nSeqModel
@author Rodrigo Morgon
@since 19/07/2016
@version P12
/*/
//-------------------------------------------------------------------
method setSeqModel(nSeqModel) class VO_Procedimento
    ::nSeqModel := nSeqModel
return 

//-------------------------------------------------------------------
/*/{Protheus.doc} getSeqModel
Retorna o valor nSeqModel
@author Rodrigo Morgon
@since 19/07/2016
@version P12
/*/
//-------------------------------------------------------------------
method getSeqModel() class VO_Procedimento
return(::nSeqModel)
	
//-------------------------------------------------------------------
/*/{Protheus.doc} setRegAnvisa
Seta o valor cRegAnvisa
@author Rodrigo Morgon
@since 20/07/2016
@version P12
/*/
//-------------------------------------------------------------------
method setRegAnvisa(cRegAnvisa) class VO_Procedimento
    ::cRegAnvisa := cRegAnvisa
return 

//-------------------------------------------------------------------
/*/{Protheus.doc} getRegAnvisa
Retorna o valor cRegAnvisa
@author Rodrigo Morgon
@since 20/07/2016
@version P12
/*/
//-------------------------------------------------------------------
method getRegAnvisa() class VO_Procedimento
return(::cRegAnvisa)

//-------------------------------------------------------------------
/*/{Protheus.doc} setUniMedida
Seta o valor cUniMedida
@author Rodrigo Morgon
@since 20/07/2016
@version P12
/*/
//-------------------------------------------------------------------
method setUniMedida(cUniMedida) class VO_Procedimento
    ::cUniMedida := cUniMedida
return 

//-------------------------------------------------------------------
/*/{Protheus.doc} getUniMedida
Retorna o valor cUniMedida
@author Rodrigo Morgon
@since 20/07/2016
@version P12
/*/
//-------------------------------------------------------------------
method getUniMedida() class VO_Procedimento
return(::cUniMedida)

//-------------------------------------------------------------------
/*/{Protheus.doc} setRefMatFab
Seta o valor cRefMatFab
@author Rodrigo Morgon
@since 20/07/2016
@version P12
/*/
//-------------------------------------------------------------------
method setRefMatFab(cRefMatFab) class VO_Procedimento
    ::cRefMatFab := cRefMatFab
return 

//-------------------------------------------------------------------
/*/{Protheus.doc} getRefMatFab
Retorna o valor cRefMatFab
@author Rodrigo Morgon
@since 20/07/2016
@version P12
/*/
//-------------------------------------------------------------------
method getRefMatFab() class VO_Procedimento
return(::cRefMatFab)

//-------------------------------------------------------------------
/*/{Protheus.doc} setAutFun
Seta o valor cAutFun
@author Rodrigo Morgon
@since 20/07/2016
@version P12
/*/
//-------------------------------------------------------------------
method setAutFun(cAutFun) class VO_Procedimento
    ::cAutFun := cAutFun
return 

//-------------------------------------------------------------------
/*/{Protheus.doc} getAutFun
Retorna o valor cAutFun
@author Rodrigo Morgon
@since 20/07/2016
@version P12
/*/
//-------------------------------------------------------------------
method getAutFun() class VO_Procedimento
return(::cAutFun)

//-------------------------------------------------------------------
/*/{Protheus.doc} setTpProc
Seta o valor TpProc
@author Pablo Alipio
@since 30/07/2018
@version P12
/*/
//-------------------------------------------------------------------
method setTpProc(cTpProc) class VO_Procedimento
    ::cTpProc := cTpProc
return 

//-------------------------------------------------------------------
/*/{Protheus.doc} getTpProc
Retorna o valor TpProc
@author Pablo Alipio
@since 30/07/2018
@version P12
/*/
//-------------------------------------------------------------------
method getTpProc() class VO_Procedimento
return(::cTpProc)

//-------------------------------------------------------------------
/*/{Protheus.doc} VO_Procedimento
Somente para compilar a classe
@author Karine Riquena Limp
@since 20/05/2016
@version P12
/*/
//-------------------------------------------------------------------
Function VO_Procedimento
Return