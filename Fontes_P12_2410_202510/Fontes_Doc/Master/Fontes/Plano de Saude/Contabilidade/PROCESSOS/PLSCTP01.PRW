#include 'protheus.ch'
#include 'topconn.ch'

static lCTBA080	:= ( 'CTBA080' == funName() )

/*/{Protheus.doc} PLSCTP01 
Busca dinamica da conta, conforme configuracao flexivel o arquivo BBH para contabilizar custo da guia.

Inicializa Parametros:                                            
MV_PLCT01 --> Classes de Procedimentos para Consultas            
MV_PLCT04 --> Codigo do RDA para o SUS                           
MV_PLCT06 --> Codigo de Consultas							    
MV_PLCT11 --> Classes de Procedimentos para HM                   
MV_PLCT12 --> Locais para Digitação de Guias de Intercâmbio      
MV_PLCT14 --> Codigo do Tipo de Prestador existente p/Operadoras.
Tabela padrao BR8- CAMPO BR8_CLASSE

@author  PLS TEAM
@version P12
@since   02.12.16
/*/
function PLSCTP01(notUSED, cAliasCab, cTipCta, notUSED, cTipDC, lB5F)
local aArea		:= getArea()
local nI		:= 0
local cCtpl04 	:= getNewPar('MV_PLCT04','SUS')
local cCtpl12 	:= getNewPar('MV_PLCT12','0004')
local cCtpl14 	:= getNewPar('MV_PLCT14','OPE')
local cRet		:= '' 
local cBusca	:= '' 
local cPatroc	:= ''
local cContac	:= '' 
local cTipoBG9	:= ''
local cBi3ModPag:= ''
local cBi3ApoSrg:= ''
local cBi3TipCon:= ''
local cBi3Tipo 	:= ''
local cBi3CodSeg:= ''
local cLog 		:= ''
local cLog1 	:= ''
local cPlano 	:= ''
local cBi3TpBen := ''
local cMatric	:= ''
local cCodPad 	:= ''
local cCodPro 	:= ''
local cBauEst   := ""
local cBauTipPre:= ""
local cBauCopCre:= ""
local cBauRecPro:= ""
local cBauTPPag	:= ""
local cOpeRda	:= ""
local cCodPla   := space(4)
local cGruOpe 	:= space(2)
local cOpeOri	:= ""
local cCodInt	:= ""	
local cCodRda 	:= ""                         
local cCompbus	:= ""   
local cTpServ	:= ""
local cChvBen 	:= ""
local cChvB5T	:= ""
local cCodLDP	:= ""
local cCodAto	:= ""
local cSegmento := ""
local cRotina	:= 'PLSCTB01'
local aRetPe    := {}   
local aAux		:= {}           
local nInd 		:= 1
local dData		:= ctod('')
local lRDAInt   := .f.

default notUSED		:= NIL
default cAliasCab  	:= 'BD7'
default cTipDC	   	:= 'D' 
default cTipCta 	:= "P"

if lCTBA080
	return('1')
endIf

BBH->(dbSetOrder(1)) //BBH_FILIAL+BBH_TPBENE+BBH_TPUNIM+BBH_TPPRES+BBH_MODCOB+BBH_TPATO+BBH_REGPLN+BBH_TPPLN+BBH_PATROC+BBH_SEGMEN+BBH_CODPRO+BBH_GRUOPE

do case

	//custo total
	case cTipCta == "P"
	
		cCampoCtb := "BBH->BBH_CONTA"
	
	//Glosa
	case cTipCta == "G"
	
		cCampoCtb := "BBH->BBH_CGLOSA"
	
	//Reembolso
	case cTipCta == "R"       
	
		cCampoCtb := "BBH->BBH_CREEMB"
	
	//Copart - Conta credito
	case cTipCta == "CC"
	
		cCampoCtb := "BBH->BBH_CCOCRD"
	
	//Copart - Conta debito
	case cTipCta == "CD"       
	
		cCampoCtb := "BBH->BBH_CCODEB"
	
	//Reembolso
	case cTipCta == "GR"       
	
		cCampoCtb := "BBH->BBH_CGLREE"

endCase

if cAliasCab == 'BD7'
	
	cChvBen := BD7->(BD7_OPEUSR + BD7_CODEMP + BD7_MATRIC + BD7_TIPREG) 
	cCodRda := BD7->BD7_CODRDA
	cMatric := xFilial("BA1") + BD7->(BD7_CODOPE + BD7_CODEMP + BD7_MATRIC + BD7_TIPREG)
	cCodLDP	:= BD7->BD7_CODLDP
	
	if BD7->BD7_FASE $ '3|4'
		dData := BD7->BD7_DTCTBF
	else
		dData := BD7->BD7_DTDIGI
	endIf
	
	cCodPad := BD7->BD7_CODPAD
	cCodPro := BD7->BD7_CODPRO

	cCodAto	:= BD6->BD6_CODATO

elseIf cAliasCab $ 'B2T|B5T'
	
	cChvBen := left(B5T->B5T_MATRIC,16)
	cCodRda := B2T->B2T_CODRDA
	cMatric := xFilial("BA1") + left(B5T->B5T_MATRIC,16)
	cChvB5T := B5T->( B5T_OPEORI + B5T_CODLDP + B5T_CODPEG + B5T_NUMGUI )
	cCodLDP	:= B5T->B5T_CODLDP

	cCodPad := B6T->B6T_CODPAD
	cCodPro	:= B6T->B6T_CODPRO
		
	if cAliasCab == 'B2T' 
		
		dData := B2T->B2T_DATTRA

	elseIf cAliasCab == 'B5T' 
		
		if ! empty( cChvB5T )
			
			BD6->(dbSetOrder(1))//BD6_FILIAL+BD6_CODOPE+BD6_CODLDP+BD6_CODPEG+BD6_NUMERO+BD6_ORIMOV+BD6_SEQUEN+BD6_CODPAD+BD6_CODPRO                                                              
			if BD6->( msSeek( xFilial("BD6") + cChvB5T ) ) 
				dData := BD6->BD6_DTDIGI
			endIf

			cCodAto	:= BD6->BD6_CODATO

		endIf

	endIf

endIf

//busca plano do beneficiario
aRet 		:= plctpBA1(cMatric)
cPlano     	:= aRet[1]
cCodPla    	:= aRet[2]
cCodInt    	:= aRet[3]
cBi3ModPag 	:= aRet[4]
cBi3ApoSrg 	:= aRet[5]
cBi3TipCon 	:= aRet[6]
cBi3Tipo   	:= aRet[7]
cBi3CodSeg 	:= aRet[8]
cBi3TpBen  	:= aRet[9]
cTipoBG9	:= aRet[10]
cPatroc		:= aRet[11]
cContac		:= aRet[12]
cGruOpe		:= aRet[13]
cOpeOri		:= aRet[16]

aRet 		:= plctpBAU(cCodRDA)
cBauEst		:= aRet[1]
cBauTipPre	:= aRet[2]
cBauCopCre	:= aRet[3]
cBauRecPro	:= aRet[4]
cBauTPPag	:= aRet[5]
cOpeRda		:= aRet[6]

//tipo de beneficiario
cBusca := plctpTPB(cBi3TpBen, dData, lB5F, cOpeRda)		

plLogDet( cBusca, 'BBH_TPBENE', 'BI3_TPBEN', 'Tipo de Beneficiario', nil, cRotina )

//Tipo do Servico
//Este campo analisa condicoes para classificar o tipo de servico,    
//conforme descrito no PLSXFUN.PRW, função PlTpServ( ).               
if cAliasCab == 'BD7' .or. ( cAliasCab == 'B5T' .and. ! empty( cChvB5T ) )

	if ! empty(BD7->BD7_TPEVCT)

		cBusca += BD7->BD7_TPEVCT

	else

		cTpServ := PlTpServ(cCodPad,cCodPro,cChvBen)

		BD6->(recLock("BD6",.f.))
			BD6->BD6_TPEVCT := cTpServ
		BD6->(msUnLock())

		BD7->(recLock("BD7",.f.))
			BD7->BD7_TPEVCT := cTpServ
		BD7->(msUnLock())

		cBusca += cTpServ

	endIf

else
	
	cTpServ := PlTpServ(cCodPad,cCodPro,cChvBen)
	
	cBusca += cTpServ

endIf	

plLogDet( cBusca, 'BBH_TPUNIM', 'BD7_TPEVCT', 'Classificacao do Evento', 'PLTPSERV', cRotina )

//tipo de prestador
cBusca += plctpTPP(cBauCopCre, cBauRecPro, cBauTipPre, cCtpl14, cCtpl04, cBauEst, cCodPad, cCodPro)

plLogDet( cBusca, 'BBH_TPPRES', 'BAU_COPCRE', 'Tipo de Prestador', nil, cRotina )

//modalidade de cobranca                                      
cBusca += plctpMDC(cBi3ModPag)

plLogDet( cBusca, 'BBH_MODCOB', 'BI3_MODPAG', 'Modalidade de Cobranca', nil, cRotina )

//tipo de ato      
cBusca += plctpTPA(cBauTipPre, cBauCopCre, cBauRecPro, cCodAto, cCtpl14, cCodLDP, cCtpl12)                                                    

plLogDet( cBusca, 'BBH_TPATO', '', 'Tipo de Ato', nil, cRotina )

//plano regulamentado
cBusca += plctpPLR(cBi3ApoSrg)

plLogDet( cBusca, 'BBH_REGPLN', 'BI3_APOSRG', 'Plano regulamentado', nil, cRotina )

//tipo de plano/contrato
cBusca += plctpPLC(cBi3Tipo, cBi3TipCon)

plLogDet( cBusca, 'BBH_TPPLN', 'BI3_TIPO|BI3_TIPCON', 'Tipo de Plano/Contrato', nil, cRotina )

//patrocino                                              
cBusca += plctpPTC(cBi3Tipo, cTipoBG9, cPatroc)

plLogDet( cBusca, 'BBH_PATROC', 'BQC_PATROC|BG9_TIPO|BI3_TIPO', 'Patrocinio', nil, cRotina )

//segmentacao
cSegmento := plctpSEG(cBi3CodSeg)

plLogDet( cBusca + cSegmento, 'BBH_SEGMEN', 'BI3_CODSEG', 'Segmentacao', nil, cRotina )
plLogDet( cBusca + cSegmento + cCodPla, 'BBH_CODPRO', 'BA1_CODPLA|BA3_CODPLA', 'Plano', nil, cRotina )
plLogDet( cBusca + cSegmento + cCodPla + cGruOpe, 'BBH_GRUOPE', 'BA0_GRUOPE', 'Grupo Operadora', nil, cRotina )
plLogDet( cBusca + cSegmento + cCodPla + cGruOpe + cBauTPPag, 'BBH_TPPAG', 'BAU_TPPAG', 'Tipo de Pagamento', nil, cRotina )

//Tratamento ao Grupo de Operadoras.
//Valido somente para Tipo de Beneficiario igual a
//Exposto Nao Beneficiario (2) ou Prestacao de Servicos (4).
lRetNick := .f.

//Ponto de entrada para complementar a busca
if existBlock("PCTP01COM")

	aRetPE := execBlock("PCTP01COM",.f.,.f.)
	
	if valtype(aRetPE) == "A"
		
		cCompbus := aRetPE[1]
		nInd     := aRetPE[2]
		
		BBH->(dbSetOrder(nInd))
		
	endIf
	
endIf

aadd(aAux, cBusca + cSegmento  + cCodPla  + cGruOpe  + cBauTPPag + cCompbus)
aadd(aAux, cBusca + cSegmento  + cCodPla  + cGruOpe  + cBauTPPag)

aadd(aAux, cBusca + cSegmento  + cCodPla  + space(2) + cBauTPPag)
aadd(aAux, cBusca + cSegmento  + space(4) + cGruOpe  + cBauTPPag)
aadd(aAux, cBusca + cSegmento  + space(4) + space(2) + cBauTPPag)
aadd(aAux, cBusca + cSegmento  + space(4) + cGruOpe)
aadd(aAux, cBusca + cSegmento  + cCodPla  + cGruOpe)

aadd(aAux, cBusca + space(3)   + cCodPla  + cGruOpe)
aadd(aAux, cBusca + space(3)   + cCodPla  + cGruOpe  + cBauTPPag)
aadd(aAux, cBusca + space(3)   + cCodPla  + space(2) + cBauTPPag)
aadd(aAux, cBusca + space(3)   + cCodPla)

aadd(aAux, cBusca + space(3)   + space(4) + cGruOpe  + cBauTPPag)
aadd(aAux, cBusca + space(3)   + space(4) + cGruOpe)
aadd(aAux, cBusca + space(3)   + space(4) + space(2) + cBauTPPag)

aadd(aAux, cBusca + cSegmento  + cCodPla)
aadd(aAux, cBusca + cSegmento)
aadd(aAux, cBusca)

for nI := 1 to len(aAux)

	if ! empty(aAux[nI])
		
		if BBH->( msSeek( xFilial('BBH') + aAux[nI], .f.) )

			cRet := iIf( empty( &(cCampoCtb) ), 'C->' + aAux[nI], &(cCampoCtb) ) 
			exit
			
		endIf

	endIf

next

//ponto de entrada para corrigir ou implemnetar a chave de busca
if existBlock("PLCTPBUS")

	cRet := execBlock("PLCTPBUS", .f., .f., { cRotina, 'BBH', cBusca, cRet } )
	
	plLogDet( cRet, 'PLCTPBUS', '', 'Ajustado por ponto de entrada', nil, cRotina )		
	
endIf

if empty(cRet)

	if ' ' $ cBusca
		cRet := 'L->' + cBusca + cSegmento + cCodPla + cGruOpe + cBauTPPag + cCompbus
	else
		cRet := 'N->' + cBusca + cSegmento + cCodPla + cGruOpe + cBauTPPag + cCompbus
	endIf

endIf

if cTipoBG9 == "2" .and. ! empty(cContac)		
	cRet := cContac
endIf

cProc := cCodPad + '/' + cCodPro

if cAliasCab == 'BD7' .or. ( cAliasCab == 'B5T' .and. ! empty( cChvB5T ) )
	cLog  := 'Chave:' + cBusca + cSegmento + cCodPla + cGruOpe + cBauTPPag + cCompbus + '|Conta:'+cRet+'|Imp:'+BD7->BD7_NUMIMP+'|LDP:'+BD7->BD7_CODLDP+'|PEG:'+BD7->BD7_CODPEG+'|Guia:'+BD7->BD7_NUMERO+"|Proc:"+cProc+"|Proc.Contab:"+cCodPro+"|Comp:"+BD7->BD7_MESPAG+"/"+BD7->BD7_ANOPAG
else
	cLog  := 'Chave:' + cBusca + cSegmento + cCodPla + cGruOpe + cBauTPPag + cCompbus + '|Conta:'+'|LDP:'+B5T->B5T_CODLDP+'|PEG:'+B5T->B5T_CODPEG+'|Guia:'+B5T->B5T_NUMGUI+"|Proc:"+cProc+"|Proc.Contab:"+cCodPro
endIf

if cAliasCab == 'BD7' .or. cAliasCab == 'B5T'
	cCT5Vlr := 'BD7->BD7_VLRPAG'
else
	cCT5Vlr := 'B6T->B6T_VLRPRO'
endIf	
 
cLog1	:= '|Valor:' 			+ stuff( strZero(&cCT5Vlr,14,2), AT('.',strZero(&cCT5Vlr,14,2)), 1, ',' )
cLog1	+= '|Matric:' 			+ BA1->(BA1_CODINT+BA1_CODEMP+BA1_MATRIC+BA1_TIPREG+BA1_DIGITO)
cLog1	+= '|MatAnt:' 			+ BA1->BA1_MATANT
cLog1	+= '|Cod.Plano:' 		+ BI3->BI3_CODIGO+'/'+BI3->BI3_VERSAO
cLog1	+= '|Cod.RDA:' 	 		+ cCodRDA
cLog1	+= '|Centro de Custo:' 	+ iIf(BA3->BA3_TIPOUS=="1",BI3->BI3_CC,(iIf(empty(BT6->BT6_CC),BI3->BI3_CC,BT6->BT6_CC)))
cLog1	+= '|Cod.Grupo Ct:'    	+ substring(cBusca,2,2)

//Pessoa Fisica
if cTipoBG9 == "1" 
	cLog1	+= '|Grp.Fis:' + BG9->BG9_CODIGO
else
	cLog1	+= '|Grp.Emp:' + BG9->BG9_CODIGO + '|Contr:' + BT5->BT5_NUMCON + '/' + BT5->BT5_VERSAO
	cLog1	+= '|Subcont:' + BQC->BQC_SUBCON +'/' + BQC->BQC_VERSUB
endIf

if subs(cRet,1,1) $ 'CLN'

	if subs(cRet,1,1) $ 'C'
		cLog1	+= '|Falta Conta para Combinacao'
	elseIf subs(cRet,1,1) $ 'N'
		cLog1	+= '|Falta Combinacao'
	else
		cLog1	+= '|Combinacao Invalida'
	endIf
	
	// Grava log de registro com problema
	PlGrvLog(cLog+cLog1, iIf(cTipDC=="C","CRD/EVT","DEB/EVT"), 1 )
	
endIf

//Grava detalhamento
plLogDet(nil, nil, nil, nil, nil, cRotina, ( subs(cRet,1,1) $ 'CLN' ) )

restArea(aArea)

return(cRet)
