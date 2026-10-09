#INCLUDE "TOTVS.CH"
#INCLUDE "FWMVCDEF.CH"

class VO_ResumoInter from VO_Guia
	
	data numGuiSolInt  as String  HIDDEN
	data dadAut        as Object  HIDDEN //Classe VO_Autorizacao
	data carAtend      as String  HIDDEN
	data tipFat        as String  HIDDEN
	data dtIniFat      as Date    HIDDEN
	data hrIniFat      as String  HIDDEN
	data dtFimFat      as Date    HIDDEN
	data hrFimFat      as String  HIDDEN
	data tpInt         as String  HIDDEN
	data regInt        as String  HIDDEN
	data decNascVivo 		as String  HIDDEN
	data diagObito     as String  HIDDEN
	data decObito      as String  HIDDEN
	data indDORN       as Logical HIDDEN
	data diagnostico   as String  HIDDEN
	data indAcidente   as Logical HIDDEN
	data motEncer      as String  HIDDEN
	data valTot        as Object  HIDDEN //Classe VO_ValorTotal
	//data procedimentos as Array   HIDDEN //Classe VO_ProcGeral
	data cCid2          	as String  HIDDEN
	data cCid3          	as String  HIDDEN
	data cCid4          	as String  HIDDEN
	data oContExec     	as Object  HIDDEN //classe de VO_Contratado
	data oProfExec     	as Object  HIDDEN //classe de VO_Profissional
	data oProfSol	     	as Object  HIDDEN //classe de VO_Profissional
	data aProcedimentos 	as Array   HIDDEN //Classe VO_ProcGeral
	data cCidObito    	as String  HIDDEN
	data grpInt			as String  HIDDEN
	data obsFim			as String  HIDDEN
	data padCon			as String  HIDDEN
	data tpCom				as String  HIDDEN
	
	method New() Constructor
	
	method setNumGuiSolInt()
	method getNumGuiSolInt()
	
	method setDadAut()
	method getDadAut()
	
	method setCarAtend()
	method getCarAtend()
	
	method setTipFat()
	method getTipFat()
	
	method setDtIniFat()
	method getDtIniFat()
	
	method setHrIniFat()
	method getHrIniFat()
	
	method setDtFimFat()
	method getDtFimFat()
	
	method setHrFimFat()
	method getHrFimFat()
	
	method setTpInt()
	method getTpInt()
	
	method setGrpInt()
	method getGrpInt()
	
	method setRegInt()
	method getRegInt()
	
	method setdecNascVivo()
	method getdecNascVivo()
	
	method setDiagObito()
	method getDiagObito()
	
	method setDecObito()
	method getDecObito()
	
	method setIndDORN()
	method getIndDORN()
	
	method setDiagnostico()
	method getDiagnostico()
	
	method setIndAcidente()
	method getIndAcidente()
	
	method setMotEncer()
	method getMotEncer()
	
	method setValTot()
	method getValTot()
	
	method setProcedimentos()
	method getProcedimentos()
	
	method setCid2()
	method getCid2()
	
	method setCid3()
	method getCid3()	
	
	method setCid4()
	method getCid4()
		
	method setContExec()
	method getContExec()
	
	method setProfExec()
	method getProfExec()
	
	method setCidObito()
	method getCidObito()
	
	method setobsFim()
	method getobsFim()
	
	method setpadCon()
	method getpadCon()	
	
	method settpCom()
	method gettpCom()

endClass

method new() class VO_ResumoInter

	::numGuiSolInt  := ""
	//::dadAut        := VO_Autorizacao():New()
	::carAtend      := ""
	::tipFat        := ""
	::dtIniFat      := Date()
	::hrIniFat      := ""  
	::dtFimFat      := Date()
	::hrFimFat      := ""
	::tpInt         := ""
	::grpInt		  := ""
	::regInt        := ""
	::decNascVivo   := ""
	::diagObito     := ""
	::decObito      := ""
	::indDORN       := ""
	::diagnostico   := ""
	::indAcidente   := .F.
	::motEncer      := ""
	::valTot        := VO_ValorTotal():New()
	::cCid2		  := ""
	::cCid3		  := ""
	::cCid4		  := ""
	::oContExec		:= VO_Contratado():New()
	::oProfExec  	:= VO_Profissional():New()
	::oProfSol  	:= VO_Profissional():New()	
	::aProcedimentos:= {}
	::cCidObito   := ""	
	//atributos da superclasse VO_GUIA
   	_Super:New() 

return self


//-------------------------------------------------------------------
/*/{Protheus.doc} setCid2
Seta o valor cCid2
@author Renan Martins
@since 03/2017
@version P12
/*/
//-------------------------------------------------------------------
method setCidObito(cCidObito) class VO_ResumoInter
    ::cCidObito := cCidObito
return 

//-------------------------------------------------------------------
/*/{Protheus.doc} getCid2
Retorna o valor cCid2
@author Renan Martins
@since 03/2017
@version P12
/*/
//-------------------------------------------------------------------
method getCidObito() class VO_ResumoInter
return(::cCidObito)

//-------------------------------------------------------------------
/*/{Protheus.doc} setNumGuiSolInt
Seta o valor numGuiSolInt
@author Karine Riquena Limp
@since 24/05/2016
@version P12
/*/
//-------------------------------------------------------------------
method setNumGuiSolInt(numGuiSolInt) class VO_ResumoInter
    ::numGuiSolInt := numGuiSolInt
return 

//-------------------------------------------------------------------
/*/{Protheus.doc} getNumGuiSolInt
Retorna o valor numGuiSolInt
@author Karine Riquena Limp
@since 24/05/2016
@version P12
/*/
//-------------------------------------------------------------------
method getNumGuiSolInt() class VO_ResumoInter
return(::numGuiSolInt)

//-------------------------------------------------------------------
/*/{Protheus.doc} setDadAut
Seta o valor dadAut
@author Karine Riquena Limp
@since 24/05/2016
@version P12
/*/
//-------------------------------------------------------------------
method setDadAut(dadAut) class VO_ResumoInter
    ::dadAut := dadAut
return 

//-------------------------------------------------------------------
/*/{Protheus.doc} getDadAut
Retorna o valor dadAut
@author Karine Riquena Limp
@since 24/05/2016
@version P12
/*/
//-------------------------------------------------------------------
method getDadAut() class VO_ResumoInter
return(::dadAut)

//-------------------------------------------------------------------
/*/{Protheus.doc} setCarAtend
Seta o valor carAtend
@author Karine Riquena Limp
@since 24/05/2016
@version P12
/*/
//-------------------------------------------------------------------
method setCarAtend(carAtend) class VO_ResumoInter
    ::carAtend := carAtend
return 

//-------------------------------------------------------------------
/*/{Protheus.doc} getCarAtend
Retorna o valor carAtend
@author Karine Riquena Limp
@since 24/05/2016
@version P12
/*/
//-------------------------------------------------------------------
method getCarAtend() class VO_ResumoInter
return(::carAtend)

//-------------------------------------------------------------------
/*/{Protheus.doc} setTipFat
Seta o valor tipFat
@author Karine Riquena Limp
@since 24/05/2016
@version P12
/*/
//-------------------------------------------------------------------
method setTipFat(tipFat) class VO_ResumoInter
    ::tipFat := tipFat
return 

//-------------------------------------------------------------------
/*/{Protheus.doc} getTipFat
Retorna o valor tipFat
@author Karine Riquena Limp
@since 24/05/2016
@version P12
/*/
//-------------------------------------------------------------------
method getTipFat() class VO_ResumoInter
return(::tipFat)

//-------------------------------------------------------------------
/*/{Protheus.doc} setDtIniFat
Seta o valor dtIniFat
@author Karine Riquena Limp
@since 24/05/2016
@version P12
/*/
//-------------------------------------------------------------------
method setDtIniFat(dtIniFat) class VO_ResumoInter
    ::dtIniFat := dtIniFat
return 

//-------------------------------------------------------------------
/*/{Protheus.doc} getDtIniFat
Retorna o valor dtIniFat
@author Karine Riquena Limp
@since 24/05/2016
@version P12
/*/
//-------------------------------------------------------------------
method getDtIniFat() class VO_ResumoInter
return(::dtIniFat)

//-------------------------------------------------------------------
/*/{Protheus.doc} setHrIniFat
Seta o valor hrIniFat
@author Karine Riquena Limp
@since 24/05/2016
@version P12
/*/
//-------------------------------------------------------------------
method setHrIniFat(hrIniFat) class VO_ResumoInter
    ::hrIniFat := hrIniFat
return 

//-------------------------------------------------------------------
/*/{Protheus.doc} getHrIniFat
Retorna o valor hrIniFat
@author Karine Riquena Limp
@since 24/05/2016
@version P12
/*/
//-------------------------------------------------------------------
method getHrIniFat() class VO_ResumoInter
return(::hrIniFat)

//-------------------------------------------------------------------
/*/{Protheus.doc} setDtFimFat
Seta o valor dtFimFat
@author Karine Riquena Limp
@since 24/05/2016
@version P12
/*/
//-------------------------------------------------------------------
method setDtFimFat(dtFimFat) class VO_ResumoInter
    ::dtFimFat := dtFimFat
return 

//-------------------------------------------------------------------
/*/{Protheus.doc} getDtFimFat
Retorna o valor dtFimFat
@author Karine Riquena Limp
@since 24/05/2016
@version P12
/*/
//-------------------------------------------------------------------
method getDtFimFat() class VO_ResumoInter
return(::dtFimFat)

//-------------------------------------------------------------------
/*/{Protheus.doc} setHrFimFat
Seta o valor hrFimFat
@author Karine Riquena Limp
@since 24/05/2016
@version P12
/*/
//-------------------------------------------------------------------
method setHrFimFat(hrFimFat) class VO_ResumoInter
    ::hrFimFat := hrFimFat
return 

//-------------------------------------------------------------------
/*/{Protheus.doc} getHrFimFat
Retorna o valor hrFimFat
@author Karine Riquena Limp
@since 24/05/2016
@version P12
/*/
//-------------------------------------------------------------------
method getHrFimFat() class VO_ResumoInter
return(::hrFimFat)

//-------------------------------------------------------------------
/*/{Protheus.doc} setTpInt
Seta o valor tpInt
@author Karine Riquena Limp
@since 24/05/2016
@version P12
/*/
//-------------------------------------------------------------------
method setTpInt(tpInt) class VO_ResumoInter
    ::tpInt := tpInt
return 

//-------------------------------------------------------------------
/*/{Protheus.doc} getTpInt
Retorna o valor tpInt
@author Karine Riquena Limp
@since 24/05/2016
@version P12
/*/
//-------------------------------------------------------------------
method getTpInt() class VO_ResumoInter
return(::tpInt)

//-------------------------------------------------------------------
/*/{Protheus.doc} setRegInt
Seta o valor regInt
@author Karine Riquena Limp
@since 24/05/2016
@version P12
/*/
//-------------------------------------------------------------------
method setRegInt(regInt) class VO_ResumoInter
    ::regInt := regInt
return 

//-------------------------------------------------------------------
/*/{Protheus.doc} getRegInt
Retorna o valor regInt
@author Karine Riquena Limp
@since 24/05/2016
@version P12
/*/
//-------------------------------------------------------------------
method getRegInt() class VO_ResumoInter
return(::regInt)

//-------------------------------------------------------------------
/*/{Protheus.doc} setdecNascVivo
Seta o valor decNascVivo
@author Karine Riquena Limp
@since 24/05/2016
@version P12
/*/
//-------------------------------------------------------------------
method setdecNascVivo(decNascVivo) class VO_ResumoInter
    ::decNascVivo := decNascVivo

return 

//-------------------------------------------------------------------
/*/{Protheus.doc} getdecNascVivo
Retorna o valor decNascVivo
@author Karine Riquena Limp
@since 24/05/2016
@version P12
/*/
//-------------------------------------------------------------------
method getdecNascVivo() class VO_ResumoInter
return(::decNascVivo)

//-------------------------------------------------------------------
/*/{Protheus.doc} setDiagObito
Seta o valor diagObito
@author Karine Riquena Limp
@since 24/05/2016
@version P12
/*/
//-------------------------------------------------------------------
method setDiagObito(diagObito) class VO_ResumoInter
    ::diagObito := diagObito
return 

//-------------------------------------------------------------------
/*/{Protheus.doc} getDiagObito
Retorna o valor diagObito
@author Karine Riquena Limp
@since 24/05/2016
@version P12
/*/
//-------------------------------------------------------------------
method getDiagObito() class VO_ResumoInter
return(::diagObito)

//-------------------------------------------------------------------
/*/{Protheus.doc} setDecObito
Seta o valor decObito
@author Karine Riquena Limp
@since 24/05/2016
@version P12
/*/
//-------------------------------------------------------------------
method setDecObito(decObito) class VO_ResumoInter
    ::decObito := decObito
return 

//-------------------------------------------------------------------
/*/{Protheus.doc} getDecObito
Retorna o valor decObito
@author Karine Riquena Limp
@since 24/05/2016
@version P12
/*/
//-------------------------------------------------------------------
method getDecObito() class VO_ResumoInter
return(::decObito)

//-------------------------------------------------------------------
/*/{Protheus.doc} setIndDORN
Seta o valor indDORN
@author Karine Riquena Limp
@since 24/05/2016
@version P12
/*/
//-------------------------------------------------------------------
method setIndDORN(indDORN) class VO_ResumoInter
    ::indDORN := indDORN
return 

//-------------------------------------------------------------------
/*/{Protheus.doc} getIndDORN
Retorna o valor indDORN
@author Karine Riquena Limp
@since 24/05/2016
@version P12
/*/
//-------------------------------------------------------------------
method getIndDORN() class VO_ResumoInter
return(::indDORN)

//-------------------------------------------------------------------
/*/{Protheus.doc} setDiagnostico
Seta o valor diagnostico
@author Karine Riquena Limp
@since 24/05/2016
@version P12
/*/
//-------------------------------------------------------------------
method setDiagnostico(diagnostico) class VO_ResumoInter
    ::diagnostico := diagnostico
return 

//-------------------------------------------------------------------
/*/{Protheus.doc} getDiagnostico
Retorna o valor diagnostico
@author Karine Riquena Limp
@since 24/05/2016
@version P12
/*/
//-------------------------------------------------------------------
method getDiagnostico() class VO_ResumoInter
return(::diagnostico)

//-------------------------------------------------------------------
/*/{Protheus.doc} setIndAcidente
Seta o valor indAcidente
@author Karine Riquena Limp
@since 24/05/2016
@version P12
/*/
//-------------------------------------------------------------------
method setIndAcidente(indAcidente) class VO_ResumoInter
    ::indAcidente := indAcidente
return 

//-------------------------------------------------------------------
/*/{Protheus.doc} getIndAcidente
Retorna o valor indAcidente
@author Karine Riquena Limp
@since 24/05/2016
@version P12
/*/
//-------------------------------------------------------------------
method getIndAcidente() class VO_ResumoInter
return(::indAcidente)

//-------------------------------------------------------------------
/*/{Protheus.doc} setMotEncer
Seta o valor motEncer
@author Karine Riquena Limp
@since 24/05/2016
@version P12
/*/
//-------------------------------------------------------------------
method setMotEncer(motEncer) class VO_ResumoInter
    ::motEncer := motEncer
return 

//-------------------------------------------------------------------
/*/{Protheus.doc} getMotEncer
Retorna o valor motEncer
@author Karine Riquena Limp
@since 24/05/2016
@version P12
/*/
//-------------------------------------------------------------------
method getMotEncer() class VO_ResumoInter
return(::motEncer)

//-------------------------------------------------------------------
/*/{Protheus.doc} setValTot
Seta o valor valTot
@author Karine Riquena Limp
@since 24/05/2016
@version P12
/*/
//-------------------------------------------------------------------
method setValTot(valTot) class VO_ResumoInter
    ::valTot := valTot
return 


//-------------------------------------------------------------------
/*/{Protheus.doc} setCid2
Seta o valor cCid2
@author Renan Martins
@since 03/2017
@version P12
/*/
//-------------------------------------------------------------------
method setCid2(cCid2) class VO_ResumoInter
    ::cCid2 := cCid2
return 

//-------------------------------------------------------------------
/*/{Protheus.doc} getCid2
Retorna o valor cCid2
@author Renan Martins
@since 03/2017
@version P12
/*/
//-------------------------------------------------------------------
method getCid2() class VO_ResumoInter
return(::cCid2)


//-------------------------------------------------------------------
/*/{Protheus.doc} setCid3
Seta o valor cCid3
@author Renan Martins
@since 03/2017
@version P12
/*/
//-------------------------------------------------------------------
method setCid3(cCid3) class VO_ResumoInter
    ::cCid3 := cCid3
return 

//-------------------------------------------------------------------
/*/{Protheus.doc} getCid3
Retorna o valor cCid3
@author Renan Martins
@since 03/2017
@version P12
/*/
//-------------------------------------------------------------------
method getCid3() class VO_ResumoInter
return(::cCid3)


//-------------------------------------------------------------------
/*/{Protheus.doc} setCid4
Seta o valor cCid4
@author Renan Martins
@since 03/2017
@version P12
/*/
//-------------------------------------------------------------------
method setCid4(cCid4) class VO_ResumoInter
    ::cCid4 := cCid4
return 

//-------------------------------------------------------------------
/*/{Protheus.doc} getCid4
Retorna o valor cCid4
@author Renan Martins
@since 03/2017
@version P12
/*/
//-------------------------------------------------------------------
method getCid4() class VO_ResumoInter
return(::cCid4)



//-------------------------------------------------------------------
/*/{Protheus.doc} getValTot
Retorna o valor valTot
@author Karine Riquena Limp
@since 24/05/2016
@version P12
/*/
//-------------------------------------------------------------------
method getValTot() class VO_ResumoInter
return(::valTot)

//-------------------------------------------------------------------
/*/{Protheus.doc} setProcedimentos
Seta o valor procedimentos
@author Karine Riquena Limp
@since 24/05/2016
@version P12
/*/
//-------------------------------------------------------------------
method setProcedimentos(aProcedimentos) class VO_ResumoInter
    ::aProcedimentos := aProcedimentos
return 

//-------------------------------------------------------------------
/*/{Protheus.doc} getProcedimentos
Retorna o valor procedimentos
@author Karine Riquena Limp
@since 24/05/2016
@version P12
/*/
//-------------------------------------------------------------------
method getProcedimentos() class VO_ResumoInter
return(::aProcedimentos)

//-------------------------------------------------------------------
/*/{Protheus.doc} setContExec
Seta o valor oContExec
@authorKarine Riquena Limp
@since03/06/2016
@version P12
/*/
//-------------------------------------------------------------------
method setContExec(oContExec) class VO_ResumoInter
    ::oContExec := oContExec
return 

//-------------------------------------------------------------------
/*/{Protheus.doc} getContExec
Retorna o valor oContExec
@author Karine Riquena Limp
@since 03/06/2016
@version P12
/*/
//-------------------------------------------------------------------
method getContExec() class VO_ResumoInter
return(::oContExec)

//-------------------------------------------------------------------
/*/{Protheus.doc} setProfExec
Seta o valor oProfExec
@authorKarine Riquena Limp
@since03/06/2016
@version P12
/*/
//-------------------------------------------------------------------
method setProfExec(oProfExec) class VO_ResumoInter
    ::oProfExec := oProfExec
return 

//-------------------------------------------------------------------
/*/{Protheus.doc} getProfExec
Retorna o valor oProfExec
@author Karine Riquena Limp
@since 03/06/2016
@version P12
/*/
//-------------------------------------------------------------------
method getProfExec() class VO_ResumoInter
return(::oProfExec)

//-------------------------------------------------------------------
/*/{Protheus.doc} setGrpInt
Seta o valor GrpInt
@author Renan Martins
@since 09/2017
/*/
//-------------------------------------------------------------------
method setGrpInt(grpInt) class VO_ResumoInter
    ::grpInt := grpInt
return 

//-------------------------------------------------------------------
/*/{Protheus.doc} getGrpInt
Recupera o valor GrpInt
@author Renan Martins
@since 09/2017
/*/
//-------------------------------------------------------------------
method getGrpInt() class VO_ResumoInter
return(::grpInt)


//-------------------------------------------------------------------
/*/{Protheus.doc} setobsFim
Seta o valor Observação
@author Renan Martins
@since 09/2017
/*/
//-------------------------------------------------------------------
method setobsFim(obsFim) class VO_ResumoInter
    ::obsFim := obsFim
return 

//-------------------------------------------------------------------
/*/{Protheus.doc} getobsFim
Recupera o valor Observação
@author Renan Martins
@since 09/2017
/*/
//-------------------------------------------------------------------
method getobsFim() class VO_ResumoInter
return(::obsFim)

//-------------------------------------------------------------------
/*/{Protheus.doc} setPadCon
Seta padrão de Conforto
@author Renan Martins
@since 10/2017
/*/
//-------------------------------------------------------------------
method setpadCon(padCon) class VO_ResumoInter
    ::padCon := padCon
return 

//-------------------------------------------------------------------
/*/{Protheus.doc} getpadCon
Recupera o valor padrão de conforto
@author Renan Martins
@since 10/2017
/*/
//-------------------------------------------------------------------
method getpadCon() class VO_ResumoInter
return(::padCon)


//-------------------------------------------------------------------
/*/{Protheus.doc} settpCom
Seta tipo apartamento
@author Renan Martins
@since 10/2017
/*/
//-------------------------------------------------------------------
method settpCom(tpCom) class VO_ResumoInter
    ::tpCom := tpCom
return 

//-------------------------------------------------------------------
/*/{Protheus.doc} gettpCom
Recupera apartamento
@author Renan Martins
@since 10/2017
/*/
//-------------------------------------------------------------------
method gettpCom() class VO_ResumoInter
return(::tpCom)


//-------------------------------------------------------------------
/*/{Protheus.doc} VO_ResumoInter
Somente para compilar a classe
@author Karine Riquena Limp
@since 20/05/2016
@version P12
/*/
//-------------------------------------------------------------------
Function VO_ResumoInter
Return