// ######################################################################################
// Projeto: DATA WAREHOUSE
// Modulo : SigaDW
// Fonte  : Alert - Objeto TAlert, contem definição de Alert
// ---------+-------------------+--------------------------------------------------------
// Data     | Autor             | Descricao
// ---------+-------------------+--------------------------------------------------------
// 01.06.01 | 0548-Alan Candido |
// 06.01.06 |2481-Paulo R Vieira| DW Fase 3
// 02.06.08 | 0548-Alan Candido | BOPS 146687
//          |                   | Correção nos procedimentos de aplicação de alertas
//          |                   | Otimização na geração de expressão do alerta
// --------------------------------------------------------------------------------------

#include "dwincs.ch"
#include "alert.ch"
#include "dwalert.ch"

/*
--------------------------------------------------------------------------------------
Classe: TAlert
Uso   : Contem definição de alerta
--------------------------------------------------------------------------------------
*/
class TAlert from TFilAlm  
  data fcExpPrep

	method New(anID, aoOwner) constructor
	method Free()
	method NewAlert(anID, aoOwner) 
	method FreeAlert()
               
	method DoLoad()
	method DoSave()
	method DoSaveNew()
	method DoDelete()
	
	method Tipo(acValue)
	method MsgT(acValue)
	method MsgF(acValue)
	method CorTF(acValue)
	method CorFF(acValue)
	method CorTB(acValue)
	method CorFB(acValue)
	method FonteT(acValue)
	method FonteF(acValue)
	method Apply2(aaRecord)
	method Sample()
	method SampleMessages(aaExemplo, acID, alTrue, acMainDivClass, alShowExpr)
	method ColorsPalete(aaExample, acColorsID, acGeneralID, acCloseID)
	method Clear()
endclass

/*
--------------------------------------------------------------------------------------
Construtor e destrutor da classe
Args: 
--------------------------------------------------------------------------------------
*/
method New(anID, aoOwner) class TAlert
               
	_Super:New(anID, aoOwner)
	
return

method Free() class TAlert

	_Super:Free()

return

/*
--------------------------------------------------------------------------------------
Propriedade Tipo
--------------------------------------------------------------------------------------
*/                         
method Tipo(acValue) class TAlert
	
return ::Props(ID_TIPO, acValue)

/*
--------------------------------------------------------------------------------------
Propriedade Mensagem quando verdadeiro
--------------------------------------------------------------------------------------
*/                         
method MsgT(acValue) class TAlert
	
return ::Props(ID_MSGT, acValue)

/*
--------------------------------------------------------------------------------------
Propriedade Mensagem quando false
--------------------------------------------------------------------------------------
*/                         
method MsgF(acValue) class TAlert
	
return ::Props(ID_MSGF, acValue)

/*
--------------------------------------------------------------------------------------
Ajusta o valor das propriedades cores
--------------------------------------------------------------------------------------
*/                         
static function AdjustColor(acValue)	
	local cRet := acValue
	
	if valType(cRet) == "C" .and. upper(cRet) == "FFFFFF"
		cRet := ""
	endif

return cRet

/*
--------------------------------------------------------------------------------------
Propriedade cor da fonte quando verdadeiro
--------------------------------------------------------------------------------------
*/                         
method CorTF(acValue) class TAlert

	acValue := AdjustColor(acValue)	

return ::Props(ID_CORTF, acValue)

/*
--------------------------------------------------------------------------------------
Propriedade cor da fonte quando false
--------------------------------------------------------------------------------------
*/                         
method CorFF(acValue) class TAlert

	acValue := AdjustColor(acValue)		

return ::Props(ID_CORFF, acValue)

/*
--------------------------------------------------------------------------------------
Propriedade cor de fundo quando verdadeiro
--------------------------------------------------------------------------------------
*/                         
method CorTB(acValue) class TAlert

	acValue := AdjustColor(acValue)		

return ::Props(ID_CORTB, acValue)

/*
--------------------------------------------------------------------------------------
Propriedade cor de fundo quando falso
--------------------------------------------------------------------------------------
*/                         
method CorFB(acValue) class TAlert

	acValue := AdjustColor(acValue)		

return ::Props(ID_CORFB, acValue)

/*
--------------------------------------------------------------------------------------
Propriedade fonte quando verdedeiro
--------------------------------------------------------------------------------------
*/                         
method FonteT(acValue) class TAlert
	
return ::Props(ID_FONTET, acValue)

/*
--------------------------------------------------------------------------------------
Propriedade fonte quando falso
--------------------------------------------------------------------------------------
*/                         
method FonteF(acValue) class TAlert
	
return ::Props(ID_FONTEF, acValue)


/*
--------------------------------------------------------------------------------------
Le o Alert
--------------------------------------------------------------------------------------
*/                         
method DoLoad() class TAlert
	local oAlert := InitTable(TAB_ALERT)

	::Clear()

	if ::ID() <> 0 .and. oAlert:Seek( 1, { ::ID() } )
		::Name(oAlert:value("nome"))
		::Desc(oAlert:value("nome"))
		::Tipo(oAlert:value("tipo"))
		::MsgT(oAlert:value("msgT"))
		::MsgF(oAlert:value("msgF"))
		::CorTF(oAlert:value("corTF"))
		::CorFF(oAlert:value("corFF"))
		::CorTB(oAlert:value("corTB"))
		::CorFB(oAlert:value("corFB"))
		::FonteT(oAlert:value("fonteT"))
		::MsgT(oAlert:value("msgT"))
		::MsgF(oAlert:value("msgF"))
		if empty(::FonteT())
			::FonteT("N")
		endif
		::FonteF(oAlert:value("fonteF"))
		if empty(::FonteF())
			::FonteF("N")
		endif
		::Expressao(oAlert:value("expressao"))
		::IsSQL(.F.)
		::IDExpr(oAlert:value("id_expr"))
	endif
	
return

/*
--------------------------------------------------------------------------------------
Grava o Alerta
--------------------------------------------------------------------------------------
*/                         
method DoSave() class TAlert
	local oAlert := InitTable(TAB_ALERT)
	local aValues
	local cMsgError
	
	aValues := { { "ID_CONS", ::Owner():ID() } , {"nome"   , ::Name() }  , ;
					 { "tipo"   , ::Tipo() }   , { "id_expr", ::IDExpr() }, ;
					 { "msgT"   , ::MsgT() }   , { "msgF"   , ::MsgF() } ,;
					 { "corTF"  , ::CorTF() }  , { "corFF"  , ::CorFF() } ,;
					 { "corTB"  , ::CorTB() }  , { "corFB"  , ::CorFB() } ,;
					 { "fonteT" , ::FonteT() } , { "fonteF" , ::FonteF() } }
	
	if !oAlert:Seek( 2, { ::Owner():ID(), ::Tipo(), ::Name() } )
		if !oAlert:Append(aValues)
			cMsgError := oAlert:Msg(.T.)
		endif
		::ID(oAlert:value("id"), .f.)
	else
		if !oAlert:Update(aValues)
			cMsgError := oAlert:Msg(.T.)
		endif
	endif

	::Owner():Invalidate()	

return { iif (empty(cMsgError), .T., .F.), cMsgError }

/*
--------------------------------------------------------------------------------------
Grava um novo Alerta
--------------------------------------------------------------------------------------
*/                         
method DoSaveNew() class TAlert
	Local oAlert := InitTable(TAB_ALERT)
	Local aOk := { .T., "" }

	if oAlert:Seek( 2, { ::Owner():ID(), ::Tipo(), ::Name() } )
		aOk := { .F., STR0001 }  //"Registro já existe. Verifique os campos chaves."
	else
		aOk := ::DoSave()
	endif

	::Owner():Invalidate()	
	
return aOk

/*
--------------------------------------------------------------------------------------
Grava o Alera
--------------------------------------------------------------------------------------
*/                         
method DoDelete() class TAlert

	local oAlert := InitTable(TAB_ALERT)

	if oAlert:Seek(1, { ::ID() } )
		oAlert:delete()
		::Owner():Invalidate()	
	endif
	
return

/*
--------------------------------------------------------------------------------------
Inicializa as propriedade
--------------------------------------------------------------------------------------
*/                         
method Clear() class TAlert

	_Super:Clear()
	
	::Tipo("")
	::MsgT("")
	::MsgF("")
	::CorTF("")
	::CorFF("")
	::CorTB("")
	::CorFB("")
	::FonteT("")
	::FonteF("")

return

/*
--------------------------------------------------------------------------------------
Aplicação do alerta
--------------------------------------------------------------------------------------
*/                         
method Apply2(aaRecord, aoInd) class TAlert
	local xRet := ''
	local cExp, cCubeName := ::Owner():Cube():Name(), aFormat
	local nInd, cRet := ""

  if valType(::fcExpPrep) == "U"
		::fcExpPrep := ::Owner():prepareSQL(::Expressao(), .T.)
	endif
	cExp := ::fcExpPrep
	  
  if aoInd:alias() $ cExp
		for nInd := 1 to len(aaRecord) 
			cExp := strTran(cExp, aaRecord[nInd,1], dwStr(aaRecord[nInd,2],.t.))
		next

		cExp := strTran(strTran(cExp, "Fato->", ""), "FATO->", "")
		aFormat := {}
		if DWStr(&(cExp), .t.) == ".T."
			cRet := "T"
			if !empty(::CorTB())
				aAdd(aFormat, "@B" + ::FonteT() + ::CorTB())
   		endif
			if !empty(::CorTF())
  			aAdd(aFormat, "@F" + ::FonteT() + ::CorTF())
			endif
		else
	    cRet := "F"
			if !empty(::CorFB())
      	aAdd(aFormat, "@B" + ::FonteF() + ::CorFB())
			endif
			if !empty(::CorFF())
   	  	aAdd(aFormat, "@F" + ::FonteF() + ::CorFF())
   		endif
		endif		                            
		aAdd(aFormat, xRet)		
		xRet := cRet + DWConcatWSep(";", aFormat)
	endif
	
return xRet

/*
--------------------------------------------------------------------------------------
Método Sample (monta um exemplo)
--------------------------------------------------------------------------------------
*/
method Sample() class TAlert
	local aExemplo := {}
	local cID := "sample"+::Name()
	
	//####TODO - aplicar as formatações nos blocos (Verdeiro) e (Falso)
	
	aAdd(aExemplo, tagJSLib("alertsample.js"))
	
	::SampleMessages(aExemplo, cID, .t.)
	
return dwConcatWSep(CRLF, aExemplo)

/*
--------------------------------------------------------------------------------------
Método Sample para exibir mensagens em caso verdadeiro/true E/OU não verdadeiro/false
para este alerta (monta um exemplo)
--------------------------------------------------------------------------------------
*/
method SampleMessages(aaExemplo, acID, alTrue, acMainDivClass, alShowExpr) class TAlert
	Local lReturn := .F.
	
	default acMainDivClass 	:= 'alertSampleMessage'
	default alShowExpr		:= .T.
	
	if valType(aaExemplo) == "U"
		aaExemplo 	:= {}
		lReturn		:= .T.
	endif
	
	//####TODO ajustar para as divs TRUE e FALSE, ficarem sobrepostas
	aAdd(aaExemplo, "<div id='"+acID+"' class='" + acMainDivClass + "'>")

	if alShowExpr
		aAdd(aaExemplo, "  <div id='"+acID+"Exp' class='alertSampleExpr'>")
		aAdd(aaExemplo, ::ExpHtml()[3])
		aAdd(aaExemplo, "  </div>")
	endif
	
	aAdd(aaExemplo, "  <div id='"+acID+"MsgText' class='alertSampleMessageBody'>")
	if alTrue
		aAdd(aaExemplo, 		buildDWTags(::MsgT()))
	else
		aAdd(aaExemplo, 		buildDWTags(::MsgF()))
	endif
	aAdd(aaExemplo, "  </div>")
	aAdd(aaExemplo, "  <div class='alertSampleMessageEnd'>")
	aAdd(aaExemplo, 		tagButton(BT_JAVA_SCRIPT, STR0002, "alertSample_close("+ASPAS_D+acID+ASPAS_D+")"))  //"Fechar"
	aAdd(aaExemplo, "  </div>")
	
	aAdd(aaExemplo, "</div>")
	
return iif (lReturn, DwConcatWSep(CRLF, aaExemplo), NIL)

/*
--------------------------------------------------------------------------------------
Método para criação de uma paleta de cores
--------------------------------------------------------------------------------------
*/
method ColorsPalete(aaExample, acColorsID, acGeneralID, acCloseID) class TAlert
	
	Local lReturn := .F.
	
	default acCloseID := 'DwColorClose'
	
	if valType(aaExample) == "U"
		aaExample 	:= {}
		lReturn		:= .T.
	endif
	
	aAdd(aaExample, tagJSLib("alertsample.js"))
	
	aAdd(aaExample, "<div id='" + acGeneralID + "' class='" + acGeneralID + "'>")
	aAdd(aaExample, "	<div id='" + acColorsID + "' class='" + acColorsID + "'>") // aqui será inserido a tabela com as cores
	aAdd(aaExample, "	</div>")
	aAdd(aaExample, "  	<div class='alertSampleMessageEnd'>")
	aAdd(aaExample, 		tagButton(BT_JAVA_SCRIPT, STR0002, "alertSampleColors_close('" + acGeneralID + "', '" + acColorsID + "')"))  //"Fechar"
	aAdd(aaExample, "  	</div>")
	aAdd(aaExample, "</div>")
	
return iif (lReturn, DwConcatWSep(CRLF, aaExample), NIL)

