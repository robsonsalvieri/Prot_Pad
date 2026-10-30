#Include 'protheus.ch'

static lCTBA080	:= ( 'CTBA080' == funName() )

/*/{Protheus.doc} PLSCTP03 
Busca dinamica da conta, conforme configuracao flexivel
no arquivo especifico BB5 - Lanctos Deb/Cred RDA.

Este programa fara uma busca de conta conforme a string busca
(cBusca) que será montada. Esta string ira variar conforme a 
combinacao de informacoes que serao avaliadas.               
Os arquivos estao sempre posicionados no momento do  ,        
lancamento, portanto somente sera posicionado o arquivo de   
combinacoes de contas.                                       

@author  PLS TEAM
@version P12
@since   02.12.16
/*/
function PLSCTP03()
local aArea		:= getArea()
local cRet		:= ''
local cBusca	:= ''
local cProc		:= ''
local cConReg	:= ''
local cCodPla	:= BBB->BBB_CODPLA
local cRotina	:= 'PLSCTP03'
local cTpLog	:= 'DC/RDA'

if lCTBA080
	return('1')
endIf

//codigo do lancamento
//Utiliza o codigo do lancamento do cadastro de tipos de 
//lancamento Deb/Cred da RDA.                            
cBusca := BBB->BBB_CODSER

plLogDet( cBusca, 'BB5_CODLAN', 'BBB_CODSER', 'Codigo do Lancamento', nil, cRotina )

//classe da rda
//Assume a classe da RDA configurada em RDA Cadastro.
//Se for Operadora, nao exige preenchimento
cBusca	+= BAU->BAU_TIPPRE

plLogDet( cBusca, 'BB5_TIPPRE', 'BAU_TIPPRE', 'Classe da Rda', nil, cRotina )

//tipo do prestador
//Identifica qual o tipo de prestador conforme cadastro da RDA.
//As opcoes sao:                                               
//1 - Cooperado                                                
//2 - Credenciado                                              
//3 - Funcionario                                              
//4 - Nao Cooperado                                            
cBusca	+= BAU->BAU_COPCRE

plLogDet( cBusca, 'BB5_COPCRE', 'BAU_COPCRE', 'Tipo do Prestador', nil, cRotina )

//codigo do conselho regional
//Inclue na procura o codigo do conselho regional do RDA.
cConReg	:= BAU->BAU_CONREG

plLogDet( cBusca+cConReg, 'BAU_CONREG', 'BB5_CONREG', 'Conselho Regional', nil, cRotina )

BB5->(dbSetOrder(1))

do case

	//Verifica chave completa
	case BB5->(msSeek(xFilial("BB5")+cBusca+cConReg+cCodPla, .f.))

		cRet := if(empty(BB5->BB5_CCRED), 'C->'+cBusca+cConReg+cCodPla, BB5->BB5_CCRED)
		
	//Verifica chave com a conta contábil padrão, levando em consideração o grupo
	case BB5->(msSeek(xFilial('BB5')+cBusca+cConReg+space(4), .f.))

		cRet := if(empty(BB5->BB5_CCRED), 'C->'+cBusca+cConReg+space(4), BB5->BB5_CCRED)
		
	//Despreza o plano e verifica se existe cadastro com o grupo informado
	case BB5->(msSeek(xFilial('BB5')+cBusca+cConReg, .f.))

		cRet := if(empty(BB5->BB5_CCRED), 'C->'+cBusca+cConReg, BB5->BB5_CCRED)
		
	//Despreza o CRM e verifica se existe Tipo de Cooperado
	case BB5->(msSeek(xFilial('BB5')+cBusca,.f.))

		cRet := Iif(empty(BB5->BB5_CCRED), 'C->'+cBusca, BB5->BB5_CCRED )
		
	// Despreza o CRM e verifica se existe Tipo de Cooperado
	case BB5->(msSeek(xFilial('BB5')+subs(cBusca,1,7)+space(10),.f.))

		cRet := Iif(empty(BB5->BB5_CCRED), 'C->'+cBusca, BB5->BB5_CCRED )
		
	// Despreza o tipo de cooperado e tenta achar pelo tipo de prestador
	case BB5->(msSeek(xFilial('BB5')+subs(cBusca,1,6)+space(11),.f.))

		cRet := Iif(empty(BB5->BB5_CCRED), 'C->'+cBusca, BB5->BB5_CCRED )
		
	// Despreza o tipo de prestador e tenta achar pelo tipo de lancamento
	case BB5->(msSeek(xFilial('BB5')+subs(cBusca,1,3)+space(14),.f.))

		cRet := Iif(empty(BB5->BB5_CCRED), 'C->'+cBusca, BB5->BB5_CCRED )
		
	otherWise

		if ' ' $ cBusca
			cRet	:= 'L->'+cBusca
		Else
			cRet	:= 'N->'+cBusca
		endIf

Endcase

//ponto de entrada para corrigir ou implemnetar a chave de busca
if existBlock("PLCTPBUS")

	cRet := execBlock("PLCTPBUS", .f., .f., { cRotina, 'BB5', cBusca, cRet } )
	
	plLogDet( cRet, 'PLCTPBUS', '', 'Ajustado por ponto de entrada', nil, cRotina )		
	
endIf

cProc := '|Oper.:'+BMS->BMS_OPELOT+'|RDA:'+BMS->BMS_CODRDA+'|Ano:'+BMS->BMS_ANOLOT+'|Mes:'+BMS->BMS_MESLOT
cProc += '|Num.Lote:'+BMS->BMS_NUMLOT+'|Chave:'+cBusca

// Aciona gravacao de Log
if subs(cRet,1,1) $ 'CLN'
	
	if subs(cRet,1,1) $ 'L'
		cProc	+= '|Impossivel montar combinacao'
	elseIf subs(cRet,1,1) $ 'C'
		cProc	+= '|Falta Conta para Combinacao'
	elseIf subs(cRet,1,1) $ 'N'
		cProc	+= '|Falta Combinacao'
	endIf

	PlGrvLog(cProc, cTpLog, 1)
	
endIf

//Grava detalhamento
plLogDet(nil, nil, nil, nil, nil, cRotina, ( subs(cRet,1,1) $ 'CLN' ) )

restArea(aArea)

return(cRet)