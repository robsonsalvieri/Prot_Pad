#Include "protheus.ch"
#Include "TopConn.ch"

static lCTBA080	:= ( 'CTBA080' == funName() )

/*/{Protheus.doc} PLSCTP02
Busca dinamica da conta, conforme configuracao flexivel   
no arquivos especificos B0H.                              
Conta débito, lancamento P21 - Despesa Prod.Médica        
Conta crébito, lancamento PA9 - Transit.Desp.Prod.Médica  

Este programa fara uma busca de conta conforme a string busca
(cBusca) que será montada. Esta string ira variar conforme a 
combinacao de informacoes que serao avaliadas.               
Os arquivos estao sempre posicionados no momento do          
lancamento, portanto somente sera posicionado o arquivo de   
combinacoes de contas.                                       

Inicializa Parametros:                                            
MV_PLCT01 --> Classes de Procedimentos para Consultas            
MV_PLCT02 --> Classes de Procedimentos para Exames / Terapias    
MV_PLCT03 --> Classes de Procedimentos para Demais Despesas      
MV_PLCT04 --> Codigo do RDA para o SUS                           
MV_PLCT11 --> Classes de Procedimentos para HM                   
MV_PLCT14 --> Codigo do Tipo de Prestador existente p/Operadoras.
MV_PLCT19 --> Codigo dos RDA's para desconsiderar Tipo Prestador.
MV_PLCT20 --> Tipo de Prestador fixo nos RDAs param. MV_PLCT19. 

@author  PLS TEAM
@version P12
@since   21.03.17
/*/
function PLSCTP02(notUSED, cAliasCab, cAliasP, lB5F)
local aArea			:= getArea()
local nI			:= 0
local cCtpl04 		:= getNewPar('MV_PLCT04','SUS')
local cCtpl14 		:= getNewPar('MV_PLCT14','OPE/UNI')
local cCtpl19 		:= getNewPar('MV_PLCT19','')
local cCtpl20 		:= getNewPar('MV_PLCT20','PAT')
local cRet			:= ''
local cBusca		:= ''
local cProc			:= ''
local cOpeRda		:= ''

local cPlano     	:= ''
local cCodPla    	:= ''
local cOpeOri    	:= ''
local cCodInt		:= ''
local cBi3ModPag 	:= ''
local cBi3ApoSrg 	:= ''
local cBi3TipCon 	:= ''
local cBi3Tipo   	:= ''
local cBi3CodSeg 	:= ''
local cBi3TpBen  	:= ''
local cTipoBG9		:= ''
local cPatroc		:= ''
local cContac		:= ''
local cGruOpe		:= ''
local cBauTipPre 	:= ""
local cBauCopCre 	:= ""
local cBauRecPro 	:= ""
local cBauTPPag		:= ""
local cBauEst		:= ""
local cCodBenef		:= ''
local cCodRDA		:= ''
local cCodPad 		:= ''
local cCodPro		:= ''
local cRotina		:= 'PLSCTP02'
local dData			:= ctod('')
local aRet 			:= {}
local aAux			:= {}
local lAchou		:= .f.

default cAliasP 	:= "BD7"  //o padrão é BD7, por causa de várias funções usar tal tabela.
default cAliasCab	:= 'BMS'
default notUSED 	:= nil

if lCTBA080
	return('1')
endIf

B0H->(dbSetOrder(1)) //B0H_FILIAL+B0H_TPBENE+B0H_TIPPRE+B0H_TPPRES+B0H_CODPRO+B0H_GRUOPE

//Incluida condição para contemplar lançamentos deb/crd, que não 
//tem como buscar o beneficiário.                                
if cAliasCab == 'BMS'

	cBusca := '1'

elseIf cAliasCab == 'B4D' .and. cAliasP == "BVO"

	//Posiciona na B4D para recuperar os dados da matrícula
	B4D->(dbSetOrder(6)) //B4D_FILIAL, B4D_SEQB4D, B4D_SEQREC, R_E_C_N_O_, D_E_L_E_T_
	if B4D->(msSeek(xFilial("B4D")+BVO->BVO_SEQB4D))
		
		cCodBenef	:= xFilial('BA1') + B4D->( B4D_OPEUSR + B4D_CODEMP + B4D_MATRIC + B4D_TIPREG ) 
		cCodRda		:= B4D->B4D_CODRDA 
		cCodPad 	:= BVO->BVO_CODPAD
		cCodPro		:= BVO->BVO_CODPRO
		dData		:= BVO->BVO_DATREC

	endIf

else

	if cAliasCab == 'BD7'
		
		cCodBenef	:= xFilial('BA1') + BD7->( BD7_OPEUSR + BD7_CODEMP + BD7_MATRIC + BD7_TIPREG ) 
		cCodRda		:= BD7->BD7_CODRDA
		cCodPad		:= BD7->BD7_CODPAD
		cCodPro		:= BD7->BD7_CODPRO
		dData 		:= BD7->BD7_DATPRO

		if BD7->BD7_FASE $ '3|4'
			dData := BD7->BD7_DTCTBF
		else
			dData := BD7->BD7_DTDIGI
		endIf

	elseIf cAliasCab == 'B2T' 

		cCodBenef	:= xFilial('BA1') + left(B5T->B5T_MATRIC,16)
		cCodRda		:= B2T->B2T_CODRDA
		cCodPad 	:= B6T->B6T_CODPAD
		cCodPro		:= B6T->B6T_CODPRO
		dData 		:= B6T->B6T_DATPRO
		cChvB5T 	:= B5T->( B5F_OPEORI + B5T_CODLDP + B5T_CODPEG + B5T_NUMGUI )

		if cAliasP == 'B2T' 
			
			dData := B2T->B2T_DATTRA

		elseIf cAliasP == 'B5T' 
			
			if ! empty( cChvB5T )
			
				BD6->(dbSetOrder(1))//BD6_FILIAL+BD6_CODOPE+BD6_CODLDP+BD6_CODPEG+BD6_NUMERO+BD6_ORIMOV+BD6_SEQUEN+BD6_CODPAD+BD6_CODPRO                                                              
				if BD6->( msSeek( xFilial("BD6") + cChvB5T ) ) 
					dData 	:= BD6->BD6_DTDIGI
				endIf

			endIf

		endIf

	endIf

endIf

//busca plano do beneficiario
aRet 		:= plctpBA1(cCodBenef)
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

plLogDet( cBusca, 'B0H_TPBENE', 'BI3_TPBEN', 'Tipo do Beneficiario', nil, cRotina )

//classe da rda
cBusca += plctpCRD(cCodRDA, cCtpl19, cCtpl20, cBauTipPre)

plLogDet( cBusca, 'B0H_TIPPRE', 'BAU_TIPPRE', 'Classe da Rda', nil, cRotina )

//tipo de prestador
cBusca += plctpTPP(cBauCopCre, cBauRecPro, cBauTipPre, cCtpl14, cCtpl04, cBauEst, cCodPad, cCodPro)

plLogDet( cBusca, 'B0H_TPPRES', 'BAU_COPCRE', 'Tipo do Prestador', nil, cRotina )

plLogDet( cBusca+cCodPla, 'B0H_CODPRO', 'BA1_CODPLA|BA3_CODPLA', 'Plano', nil, cRotina )
plLogDet( cBusca+cCodPla+cGruOpe, 'B0H_GRUOPE', 'BA0_GRUOPE', 'Grupo Operadora', nil, cRotina )
plLogDet( cBusca+cCodPla+cBauTPPag, 'B0H_TPPAG', 'BAU_TPPAG', 'Tipo de Pagamento', nil, cRotina )

//Tratamento ao Grupo de Operadoras.                        
//Valido somente para Tipo de Beneficiario igual a          
//Exposto Nao Beneficiario (2) ou Prestacao de Servicos (4).
if subs(cBusca,1,1) $ '2/4'			

	aadd(aAux, cBusca + cCodPla  + cGruOpe  + cBauTPPag)
	aadd(aAux, cBusca + space(4) + cGruOpe  + cBauTPPag)
	aadd(aAux, cBusca + space(4) + cGruOpe)
	aadd(aAux, cBusca + cCodPla  + cGruOpe)

	for nI := 1 to len(aAux)

		if ! empty(aAux[nI])
			
			if B0H->( msSeek( xFilial('B0H') + aAux[nI], .f.) )

				cRet 	:= iIf( empty(B0H->B0H_CONTA), 'C->' + aAux[nI], B0H->B0H_CONTA)
				lAchou 	:= .t.
				exit

			endIf

		endIf

	next

	aAux := {}

endIf

// Se não achou, procura combinacao sem Grupo de Operadora
if ! lAchou

	aadd(aAux, cBusca + space(4) + space(2) + cBauTPPag)
	aadd(aAux, cBusca + cCodPla  + space(2) + cBauTPPag)
	aadd(aAux, cBusca + cCodPla)
	aadd(aAux, cBusca)

	for nI := 1 to len(aAux)

		if ! empty(aAux[nI])
			
			if B0H->( msSeek( xFilial('B0H') + aAux[nI], .f.) )

				cRet := iIf( empty(B0H->B0H_CONTA), 'C->' + aAux[nI], B0H->B0H_CONTA)
				exit

			endIf

		endIf

	next

endIf

if empty(cRet)

	// Se for operadora, despreza o tipo de cooperado e tenta achar a conta novamente
	if subs(cBusca,2,3) $ cCtpl14

		if B0H->( msSeek( xFilial('B0H') + subs(cBusca,1,4), .f.) )
			cRet := Iif(empty(B0H->B0H_CONTA), 'C->' + subs(cBusca,1,4), B0H->B0H_CONTA )
		endIf

	endIf
	
	if empty(cRet)
		
		if ' ' $ cBusca
			cRet := 'L->' + cBusca + cCodPla + cGruOpe + cBauTPPag
		else
			cRet := 'N->' + cBusca + cCodPla + cGruOpe + cBauTPPag
		endIf

	endIf

endIf

//ponto de entrada para corrigir ou implemnetar a chave de busca
if existBlock("PLCTPBUS")

	cRet := execBlock("PLCTPBUS", .f., .f., { cRotina, 'B0H', cBusca, cRet } )
	
	plLogDet( cRet, 'PLCTPBUS', '', 'Ajustado por ponto de entrada', nil, cRotina )		
	
endIf

if cAliasP == "BD7"

	// Grava em memoria o procedimento
	cProc :=  BD7->BD7_CODPAD + '/' + BD7->BD7_CODPRO
	
	// Aciona gravacao de Log
	cLog := 'Chave:' + cBusca + cCodPla + cGruOpe + cBauTPPag + '|Conta:' + cRet
	cLog += '|Imp:' + BD7->BD7_NUMIMP+'|LDP:'+BD7->BD7_CODLDP+'|PEG:'+BD7->BD7_CODPEG+'|Guia:'+BD7->BD7_NUMERO+"|Proc:"+cProc+"|Comp:"+BD7->BD7_MESPAG+"/"+BD7->BD7_ANOPAG
	
	// Adicao dos campos Valor, Codigo Novo e Antigo do Usuario, Plano, Grupo Empresa, Contrato e Subcontrato
	// conforme solicitacao de Minou em 27/03/06 - Roger / Raquel
	
	cLog1	:= '|Valor:'+ Stuff( strZero(BD7->BD7_VLRPAG,14,2), AT('.',strZero(BD7->BD7_VLRPAG,14,2)), 1, ',' )
	cLog1	+= '|Matric:'+BD7->BD7_OPEUSR+BD7->BD7_CODEMP+BD7->BD7_MATRIC+BD7->BD7_TIPREG
	cLog1	+= '|Cod.Plano:'+cPlano
	cLog1	+= '|Cod.RDA:'+BD7->BD7_CODRDA
	cLog1	+= '|Centro de Custo:'+Iif(BA3->BA3_TIPOUS=="1",BI3->BI3_CC,(Iif(empty(BT6->BT6_CC),BI3->BI3_CC,BT6->BT6_CC)))

elseIf cAliasP $ "B2T|B5T|B6T"

	// Grava em memoria o procedimento
	cProc :=  B6T->B6T_CODPAD + '/' + B6T->B6T_CODPRO
	
	// Aciona gravacao de Log
	cLog := 'Chave:' + cBusca + cCodPla + cGruOpe + cBauTPPag + '|Conta:' + cRet
	cLog += '|LDP:'+B5T->B5T_CODLDP+'|PEG:'+B5T->B5T_CODPEG+'|Guia:'+B5T->B5T_NUMGUI+"|Proc:"+cProc
	
	// Adicao dos campos Valor, Codigo Novo e Antigo do Usuario, Plano, Grupo Empresa, Contrato e Subcontrato
	// conforme solicitacao de Minou em 27/03/06 - Roger / Raquel
	
	cLog1	:= '|Valor:'+ Stuff( strZero(B6T->B6T_VLRPRO,14,2), AT('.',strZero(B6T->B6T_VLRPRO,14,2)), 1, ',' )
	cLog1	+= '|Matric:'+B6T->B6T_VLRPRO
	cLog1	+= '|Cod.Plano:'+cPlano
	cLog1	+= '|Cod.RDA:'+B2T->B2T_CODRDA
	cLog1	+= '|Centro de Custo:'+Iif(BA3->BA3_TIPOUS=="1",BI3->BI3_CC,(Iif(empty(BT6->BT6_CC),BI3->BI3_CC,BT6->BT6_CC)))

endIf

// se vier do P21-P22-P23 (BMS)	
if cAliasCab == "BMS"
	cTpLog	:= 'DEB/PRD'
else				
	cTpLog	:= 'CRD/EVT'
endIf

// Aciona gravacao de Log
if subs(cRet,1,1) $ 'CLN'

	if subs(cRet,1,1) $ 'C'
		cLog1	+= '|Falta Conta para Combinacao'
	elseIf subs(cRet,1,1) $ 'N'
		cLog1	+= '|Falta Combinacao'
	else
		cLog1	+= '|Combinacao Invalida'
	endIf
	
	// Grava log de registro com problema
	PlGrvLog(cLog+cLog1, cTpLog, 1)
	
endIf

//Grava detalhamento
plLogDet(nil, nil, nil, nil, nil, cRotina, ( subs(cRet,1,1) $ 'CLN' ) )

restArea(aArea)

return(cRet)