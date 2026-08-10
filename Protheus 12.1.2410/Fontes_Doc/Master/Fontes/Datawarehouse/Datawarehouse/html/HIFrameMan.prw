// ######################################################################################
// Projeto: DATA WAREHOUSE
// Modulo : Htm
// Fonte  : HIFramMan - Objeto THIFrameMan, responsável pelo gerenciamento de iframes
// ---------+-------------------+--------------------------------------------------------
// Data     | Autor             | Descricao
// ---------+-------------------+--------------------------------------------------------
// 12.06.06 | 0548-Alan Candido |
// --------------------------------------------------------------------------------------

#include "dwincs.ch"

/*
--------------------------------------------------------------------------------------
Classe: THIFrameMan
Uso   : Gerenciamento de iframes
--------------------------------------------------------------------------------------
*/
class THIFrameMan from TDWObject
  data faIFrames
  data fcAction
  data faParams
  data fnWidth
  data fnHeight
  data flScroll
  
  method New() constructor
  method Free()       
  method Buffer(aaBuffer)
  method AddFrame(acName, acCaption, anWidth, anHeight, aaParams)
  method Action(acValue)
  method Params(aaValue)
  method Width(anValue)
  method Height(anValue)
  method ScrollBar(alValue)
endclass

/*
--------------------------------------------------------------------------------------
Construtor e destrutor da classe
--------------------------------------------------------------------------------------
*/
method New() class THIFrameMan

  _Super:New()
  
  ::faIFrames := {}
  ::fcAction := AC_NONE
  ::faParams := {}
  ::flScroll := .f.
  
return

method Free() class THIFrameMan

  _Super:Free()

return

/*
--------------------------------------------------------------------------------------
Código HTM para o item
Arg: aaBuffer -> array, local de geração do HTML
Ret: 
--------------------------------------------------------------------------------------
*/                         
method Buffer(aaBuffer) class THIFrameMan
  local nInd, aParams
  local cStyle := ""  
  local aBuffer := {}
  
  aAdd(aaBuffer, "<!-- THIFrameMan begin -->")

  if !empty(::Width())
	  cStyle += "width:" + buildMeasure(::Width()) + ";"
  endif

  if !empty(::Height())
	  cStyle += "height:" + buildMeasure(::Height()) + ";"
  endif
  
  aAdd(aaBuffer, "<table class='buildForm' style='"+cStyle+"' summary=''>")

  // prepara "area" container
  for nInd := 1 to len(::faIFrames)
    aIFrame := aClone(::faIFrames[nInd])
    aAdd(aaBuffer, "<col style='width:"+buildMeasure(aIFrame[IFRAME_WIDTH])+"'>")
  next

  aAdd(aaBuffer, "<tr>")

  for nInd := 1 to len(::faIFrames)
    aIFrame := aClone(::faIFrames[nInd])
    if nInd == 1
   	  aAdd(aaBuffer, "<td>") 
    else
      aAdd(aaBuffer, "<td style='border-left:2px groove gray;'>")
    endif
    aParams := aClone(::faParams)
    aAdd(aParams, { "iframe", aIFrame[IFRAME_ID] })
    aAdd(aParams, { "jscript", CHKBOX_ON} )
    aEval(aIFrame[IFRAME_PARAMS], { |x| aAdd(aParams, { x[1], x[2] } )})
    buildIframe(aaBuffer, ::fcAction, aParams, aIFrame[IFRAME_ID], 1, aIFrame[IFRAME_HEIGHT], ::ScrollBar())
    aAdd(aaBuffer, "</td>")
  next

  aAdd(aaBuffer, "</tr>")
  aAdd(aaBuffer, "</table>")
  aAdd(aaBuffer, "<!-- THIFrameMan end -->")
return 

/*
--------------------------------------------------------------------------------------
Adiciona iFrames
Arg: 
Ret: lRet -> lógico, indica que o iFrame foi adicionado
--------------------------------------------------------------------------------------
*/              
method AddFrame(acName, acCaption, anWidth, anHeight, aaParams) class THIFrameMan
  local lRet := .f., aAux
  
  default anWidth := 1
  default anHeight := 350
  default aaParams := {}
    
  if ascan(::faIFrames , { |x| x[IFRAME_ID] == acName}) == 0
    aAux := array(IFRAME_SIZE)            
    aAux[IFRAME_ID] := acName
    aAux[IFRAME_CAPTION] := acCaption
    aAux[IFRAME_WIDTH] := anWidth
    aAux[IFRAME_HEIGHT] := anHeight
    aAux[IFRAME_PARAMS] := aClone(aaParams)
    aAdd(::faIFrames, aAux)
	lRet := .t.
  endif

return lRet

/*
--------------------------------------------------------------------------------------
Propriedade "action"
--------------------------------------------------------------------------------------
*/                         
method Action(acValue) class THIFrameMan

  property ::fcAction := acValue
  
return ::fcAction

/*
--------------------------------------------------------------------------------------
Propriedade "params"
--------------------------------------------------------------------------------------
*/                         
method Params(aaValue) class THIFrameMan

  property ::faParams := aClone(aaValue)
  
return ::faParams

/*
--------------------------------------------------------------------------------------
Propriedade "Width"
--------------------------------------------------------------------------------------
*/                         
method Width(anValue) class THIFrameMan

  property ::fnWidth := anValue
  
return ::fnWidth

/*
--------------------------------------------------------------------------------------
Propriedade "Height"
--------------------------------------------------------------------------------------
*/                         
method Height(anValue) class THIFrameMan

  property ::fnHeight := anValue
  
return ::fnHeight

/*
--------------------------------------------------------------------------------------
Propriedade "ScrollBar"
--------------------------------------------------------------------------------------
*/
method ScrollBar(alValue) class THIFrameMan
	
	property ::flScroll := alValue
	
return ::flScroll