#INCLUDE "PROTHEUS.CH" 

Function GFEXFBB()
Return Nil

//---------------------------------------------------------------------------------------------------
/*/{Protheus.doc} GFEXFBB
Classe de Funções Relacionadas a GFEXFUNB
Generica

@author Leandro Conradi Zmovirzynski
@since 23/03/2018
@version 1.0
/*/
//---------------------------------------------------------------------------------------------------

CLASS GFEXFBB FROM LongNameClass
    
	DATA cNrCalc
	DATA cFilCalc
	DATA cOrigem 
	DATA lDeleta
	DATA lStatus
	DATA cMensagem
	DATA lVldOrigem
	
	METHOD New() CONSTRUCTOR
	METHOD Validar()
	METHOD Deletar()
	METHOD Destroy(oObject)
	METHOD ClearData()

	METHOD setNrCalc(cNrCalc)
	METHOD setFilCalc(cFilCalc)
	METHOD setOrigem(cOrigem) 
	METHOD setDeleta(lDeleta)
	METHOD setStatus(lStatus)
	METHOD setMensagem(cMensagem)
	METHOD setVldOrigem(lVldOrigem)
	
	METHOD getNrCalc()
	METHOD getFilCalc()
	METHOD getOrigem()
	METHOD getDeleta()
	METHOD getStatus()
	METHOD getMensagem()
	METHOD getVldOrigem()
ENDCLASS


//---------------------------------------------------------------------------------------------------
/*/{Protheus.doc}GFEXFBB:Validar()
Verifica se os cálculos podem ser deletados.
Uso: Para utilizar os métodos classe é necessário instancialá:
@sample Local oObjeto := GFEXFBB():New()

Passar as informações necessárias para a classe: Número do Cálculo/Origem do Cálculo
@sample oObjeto:SetNrCalc("00000001")
@sample oObjeto:SetOrigem("2")

Chamar o método de válidação:
@sample oObjeto:Validar()

O método Validar() Grava informações em 2 atributos do objeto instanciado:
	DATA lStatus
	DATA cMensagem

Verificando valores contidos nos atributos: 
	oObjeto:getStatus()
	oObjeto:getMensagem()

@author Leandro Conradi Zmovirzynski
@since 23/03/2018
@version 1.0
/*/
//---------------------------------------------------------------------------------------------------

METHOD New() Class GFEXFBB
	Self:ClearData()
Return

METHOD Destroy(oObject) CLASS GFEXFBB
	FreeObj(oObject)
Return

METHOD ClearData() Class GFEXFBB
	Self:cNrCalc	  := PadR("", TamSx3("GWF_NRCALC")[1])
	Self:cFilCalc	  := xFilial("GWF")
	Self:cOrigem	  := PadR("", TamSx3("GWF_ORIGEM")[1])
	Self:lDeleta	  := .F.
	Self:lStatus	  := .F.
	Self:cMensagem  := ""
	Self:lVldOrigem := .T.
Return


METHOD Validar() Class GFEXFBB
	
	If Self:getVldOrigem()
		If Self:getOrigem() != '2'
			Self:setMensagem("Não há como desfazer o frete combinado de Romaneios que já possuam outros cálculos.")
			Self:setStatus(.F.)
			Return 
		EndIf
	EndIf
		
	If !GFEVldDocFrete(Self:getNrCalc(), , Self:getFilCalc())
		Self:setMensagem("Um dos documentos de carga do cálculo " + Self:getNrCalc() + " está vinculado a documento de frete.") 
		Self:setStatus(.F.)
		Return
    EndIf
    
    If !GFEVldPreFat(Self:getNrCalc(), Self:getFilCalc()) 
		Self:SetMensagem("Cálculo " + Self:getNrCalc() + " está associado a pré-fatura de frete.") 
		Self:SetStatus(.F.)
		Return 
    EndIf

    If !GFEVldContr(Self:getNrCalc(), Self:getFilCalc())
        Self:setMensagem("Cálculo " + Self:getNrCalc() + " está associado a contrato com autônomo.")
        Self:setStatus(.F.)
        Return 
    EndIf
    
Self:setStatus(.T.)
Return 


//----------------------------------------------------------------------------
/*/{Protheus.doc}GFEXFBB:Deletar()
Função GFEDelCalc da GFEXFUNB Movida Para o método Deletar() da Classe GFEXFBB[26/03/2018]
Elimina o calculo de frete e seus relacionamentos

Uso: Para utilizar os métodos classe é necessário instancialá
@sample Local oObjeto := GFEXFBB():New()
Com o objeto instanciado agora é possivel utilizar todos os métodos da classe GFEXFBB

Para deletar um cálculo é necessário passar suas informações para classe.

Número do calculo de frete a eliminar
@sample oObjeto:setNrCalc("00000001")

Filial do calculo de frete a eliminar. Em branco utiliza a filial corrente
@sample oObjeto:setFilCalc("01") 	  

Opcional, evita ou permite a exclusão de cálculo ORIGEM = 4 (Simulação)
@sample oObjeto:setDeleta(lDeleta)

Chamando o método de Deletar() utilizando o objeto populado. 
@sample oObjeto:Deletar()

Destruindo o objeto instanciado.
@sample oObjeto:Destroy()

@author Leandro Conradi Zmovirzynski
@since 28/03/2018
@version 1.0
/*///----------------------------------------------------------------------------
METHOD Deletar() Class GFEXFBB

	Local aAreaGWF  := GWF->( GetArea() )
	Local aAreaGWH  := GWH->( GetArea() )
	Local aAreaGWG  := GWG->( GetArea() )
	Local aAreaGWI  := GWI->( GetArea() )
	Local aAreaGWA  := GWA->( GetArea() )
	Local aAreaGWM  := GWM->( GetArea() )
	Local aAreaGWO  := GWO->( GetArea() )
	Local cTpDoc	  := "1"

	GWF->(dbSetOrder(01))
	If GWF->(dbSeek(Self:getFilCalc() + Self:getNrCalc()))

		// Comportamento específico para esse tipo
		If GWF->GWF_ORIGEM == "4" .And. !Self:getDeleta()
			RecLock("GWF",.F.)
				GWF->GWF_NRROM := ""
				GWF->(MsUnlock())
			RestArea(aAreaGWF)
			Return
		EndIf

		cTpDoc := If(GWF->GWF_TPCALC == "8", "4", "1")

		// Documentos do calculo de frete
		GWH->(dbSetOrder(01))
		GWH->(dbSeek(Self:getFilCalc()+GWF->GWF_NRCALC))
		While !GWH->(Eof()) .and. GWH->GWH_NRCALC == GWF->GWF_NRCALC
			RecLock("GWH",.F.)
				GWH->(dbDelete())
			GWH->(MsUnLocK())
			GWH->(dbSkip())
		EndDo

		// Tabelas do calculo de frete
		dbSelectArea("GWG")
		GWG->(dbSetOrder(01))
		GWG->(dbSeek(Self:getFilCalc()+GWF->GWF_NRCALC))
		While !GWG->(eof()) .and. GWG->GWG_NRCALC == GWF->GWF_NRCALC
			RecLock("GWG",.F.)
				GWG->(dbDelete())
			GWG->(MsUnLocK())
			GWG->(dbSkip())
		EndDo

		// Componentes do calculo de frete
		GWI->(dbSetOrder(01))
		GWI->(dbSeek(Self:getFilCalc()+GWF->GWF_NRCALC))
		While !GWI->(eof()) .and. GWI->GWI_NRCALC == GWF->GWF_NRCALC
			RecLock("GWI",.F.)
				GWI->(dbDelete())
			GWI->(MsUnLocK())
			GWI->(dbSkip())
		EndDo

		// Movimentos contábeis do cálculo de frete
		GWA->(dbSetOrder(1))
		If GWA->(dbSeek(Self:getFilCalc()+cTpDoc+PadR("",5)+GWF->GWF_TRANSP+PadR("",5)+GWF->GWF_NRCALC))
			While !GWA->(Eof()) .AND. GWA->GWA_FILIAL == Self:getFilCalc();
			.AND. GWA->GWA_TPDOC  == cTpDoc /*Cálculo de frete*/;
			.AND. GWA->GWA_CDESP  == PadR("",5);
			.AND. GWA->GWA_CDEMIT == GWF->GWF_TRANSP;
			.AND. GWA->GWA_SERIE  == PadR("",5);
			.AND. AllTrim(GWA->GWA_NRDOC)  == AllTrim(GWF->GWF_NRCALC)
				RecLock("GWA",.F.)
					GWA->(dbDelete())
				GWA->(MsUnLock())
				GWA->(dbSkip())
			EndDo
		EndIf

		// Rateios contábeis do cálculo de frete
		GWM->(dbSetOrder(1))
		If GWM->(dbSeek(Self:getFilCalc()+cTpDoc+PadR("",5)+GWF->GWF_TRANSP+PadR("",5)+GWF->GWF_NRCALC))
			While !GWM->(Eof()) .And. Self:getFilCalc() == GWM->GWM_FILIAL;
			.And. GWM->GWM_TPDOC  == cTpDoc;
			.And. GWM->GWM_CDESP  == PadR("",5);
			.And. GWM->GWM_CDTRP  == GWF->GWF_TRANSP;
			.And. GWM->GWM_SERDOC == PadR("",5);
			.And. Alltrim(GWM->GWM_NRDOC) == Alltrim(GWF->GWF_NRCALC)
				RecLock("GWM",.F.)
					GWM->(dbDelete())
				GWM->(MsUnLock())
				GWM->(dbSkip())
			EndDo
		EndIf

		// Ajustes dos calculos
		GWO->(dbSetOrder(1))
		If GWO->(dbSeek(Self:getFilCalc()+GWF->GWF_NRCALC))
			While !GWO->(Eof());
			.And. Self:getFilCalc() == GWO->GWO_FILIAL;
			.And. GWO->GWO_NRCALC == GWF->GWF_NRCALC
				RecLock("GWO",.F.)
					GWO->(dbDelete())
				GWO->(MsUnLock())
				GWO->(dbSkip())
			EndDo
		EndIf
		
		If GFXCP12127("GXY_NRCT")
			// Tabelas do calculo de frete
			GXY->(dbSetOrder(2))
			GXY->(dbSeek(GWF->GWF_FILIAL+GWF->GWF_NRCALC))
			While !GXY->(eof()) .and. GXY->GXY_FILCA == GWF->GWF_FILIAL .and. GXY->GXY_NRCALC == GWF->GWF_NRCALC
				GXT->(dbSetOrder(01))
				If GXT->(dbSeek(GXY->GXY_FILIAL + GXY->GXY_NRCT))		
					RecLock("GXT",.F.)
						GXT->GXT_VLPREV := GXT->GXT_VLPREV - GXY->GXY_VLPREV
					GXT->(MsUnLocK())			
				ElseIf GXT->(dbSeek(xFilial("GXT") + GXY->GXY_NRCT))
					RecLock("GXT",.F.)
						GXT->GXT_VLPREV := GXT->GXT_VLPREV - GXY->GXY_VLPREV
					GXT->(MsUnLocK())
				EndIf
									
				RecLock("GXY",.F.)
					GXY->(dbDelete())
				GXY->(MsUnLocK())
				
				GXY->(dbSkip())
			EndDo	
		Endif	
		
		RecLock("GWF",.F.)
			GWF->(dbDelete())
		GWF->(MsUnLock())
	EndIf

	RestArea(aAreaGWF)
	RestArea(aAreaGWH)
	RestArea(aAreaGWG)
	RestArea(aAreaGWI)
	RestArea(aAreaGWA)
	RestArea(aAreaGWM)
	RestArea(aAreaGWO)
	
Return


//-----------------------------------
// Setters
//-----------------------------------

METHOD setNrCalc(cNrCalc) CLASS GFEXFBB
	Self:cNrCalc := cNrCalc
Return

METHOD setFilCalc(cFilCalc) CLASS GFEXFBB
	Self:cFilCalc := cFilCalc 
Return

METHOD setOrigem(cOrigem) Class GFEXFBB
	Self:cOrigem := cOrigem
Return 

METHOD setDeleta(lDeleta) Class GFEXFBB
	Self:lDeleta := lDeleta
Return 

METHOD setStatus(lStatus) Class GFEXFBB
	Self:lStatus := lStatus
Return

METHOD setMensagem(cMensagem) CLASS GFEXFBB
	Self:cMensagem := cMensagem
Return

METHOD setVldOrigem(lVldOrigem) CLASS GFEXFBB
	Self:lVldOrigem := lVldOrigem
Return
//-----------------------------------
// Getters
//-----------------------------------

METHOD getNrCalc() CLASS GFEXFBB
Return Self:cNrCalc

METHOD getFilCalc() CLASS GFEXFBB
Return Self:cFilCalc

METHOD getOrigem() Class GFEXFBB
Return Self:cOrigem

METHOD getDeleta() Class GFEXFBB
Return Self:lDeleta 

METHOD getStatus() Class GFEXFBB
Return Self:lStatus

METHOD getMensagem()Class GFEXFBB
Return Self:cMensagem

METHOD getVldOrigem() CLASS GFEXFBB
Return Self:lVldOrigem
