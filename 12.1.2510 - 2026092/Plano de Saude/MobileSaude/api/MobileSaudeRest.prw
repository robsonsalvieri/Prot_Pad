#INCLUDE 'protheus.ch'
#INCLUDE 'restful.ch'


//-------------------------------------------------------------------
/*/{Protheus.doc} mobileSaude

API de verificação de usuário
@author  Geraldo (Mobile Saude) / Renan Sakai
@version P12
@since   06/09/18
/*/
//-------------------------------------------------------------------
WsRestful mobileSaude Description "Serviços Rest dedicados a integração do módulo PLS x Mobile Saúde" Format APPLICATION_JSON
	
	WsData usuario_login As String Optional
	WsData usuario_psw	As String Optional
    WsData apiVersion As String Optional

	//Jornada Acesso
	WsMethod POST login Description "Login de usuário";
		WSsyntax "{apiVersion}/login/";
		Path "{apiVersion}/login/" PRODUCES APPLICATION_JSON

	WsMethod POST novoUsuario Description "Cria o usuário no primeiro acesso";
		WSsyntax"{apiVersion}/novoUsuario";
		Path "{apiVersion}/novoUsuario" PRODUCES APPLICATION_JSON

	WsMethod POST reiniciarSenha Description "Recupera a senha do usuário";
		WSsyntax "{apiVersion}/reiniciarSenha";
		Path "{apiVersion}/reiniciarSenha" PRODUCES APPLICATION_JSON

	WsMethod POST trocarSenha Description "Troca a senha do usuário";
		WSsyntax "{apiVersion}/trocarSenha";
		Path "{apiVersion}/trocarSenha" PRODUCES APPLICATION_JSON

	//Jornada Utilizacao
	WsMethod POST exUtilizacao Description "Retorna o extrato de utilização";
		WSsyntax "{apiVersion}/extrato";
		Path "{apiVersion}/extrato" PRODUCES APPLICATION_JSON
		
	//Jornada Financeira
	WsMethod POST listaDebitos Description "Lista de débitos";
		WSsyntax "{apiVersion}/listaDebitos";
		Path "{apiVersion}/listaDebitos" PRODUCES APPLICATION_JSON

	WsMethod POST detalheDebito Description "Detalhes do débito selecionado";
		WSsyntax "{apiVersion}/detalheDebito";
		Path "{apiVersion}/detalheDebito" PRODUCES APPLICATION_JSON

	WsMethod POST boletoPdf Description "Retorna o boleto em PDF";
		WSsyntax "{apiVersion}/boletoPdf";
		Path "{apiVersion}/boletoPdf" PRODUCES APPLICATION_JSON

	WsMethod POST extratoFaturaPdf Description "Retorna a composição da cobrança em PDF";
		WSsyntax "{apiVersion}/extratoFaturaPdf";
	 	Path "{apiVersion}/extratoFaturaPdf" PRODUCES APPLICATION_JSON

	//Token
	WsMethod POST token Description "Gera um token de acesso";
		WSsyntax "{apiVersion}/token";
		Path "{apiVersion}/token" PRODUCES APPLICATION_JSON   

	// Jornada Extrato de Autorizações (Guia)
	WsMethod POST guiaAutorizacoes Description "Retorna uma lista com as guias de autorização";
		WSsyntax "{apiVersion}/extratoAutorizacao";
		Path "{apiVersion}/extratoAutorizacao" PRODUCES APPLICATION_JSON  

	WsMethod POST guiaDetalhe Description "Retorna eventos(itens) da guia de autorização";
		WSsyntax "{apiVersion}/detalheAutorizacao";
		Path "{apiVersion}/detalheAutorizacao" PRODUCES APPLICATION_JSON

	WsMethod POST guiaPdf Description "Retorna a guia completa em PDF";
		WSsyntax "{apiVersion}/guiaPdf";
		Path "{apiVersion}/guiaPdf" PRODUCES APPLICATION_JSON

	WsMethod POST guiaStatus Description "Retorna os status de autorização";
		WSsyntax "{apiVersion}/statusAutorizacao";
		Path "{apiVersion}/statusAutorizacao" PRODUCES APPLICATION_JSON 
	
	// Jornada Declarações
	WsMethod POST declaracoes Description "Retorna uma lista de declarações";
		WSsyntax "{apiVersion}/listarDeclaracoes";
		Path "{apiVersion}/listarDeclaracoes" PRODUCES APPLICATION_JSON  

	WsMethod POST pdfDeclaracao Description "Retorna a declaração em PDF";
		WSsyntax "{apiVersion}/declaracaoPdf";
		Path "{apiVersion}/declaracaoPdf" PRODUCES APPLICATION_JSON

	// Jornada Extrato de Reembolso
	WsMethod POST reeExtrato Description "Retorna uma lista com os protocolos de reembolso";
		WSsyntax "{apiVersion}/extratoReembolso";
		Path "{apiVersion}/extratoReembolso" PRODUCES APPLICATION_JSON  

	WsMethod POST reeDetalhe Description "Retorna os itens de um protocolo especifico";
		WSsyntax "{apiVersion}/detalheReembolso";
		Path "{apiVersion}/detalheReembolso" PRODUCES APPLICATION_JSON

	WsMethod POST reeHistorico Description "Retorna o histórico de alterações de status do protocolo de reembolso";
		WSsyntax "{apiVersion}/historicoReembolso";
		Path "{apiVersion}/historicoReembolso" PRODUCES APPLICATION_JSON

	WsMethod POST reeStatus Description "Retorna os status do protocolo de reembolso";
		WSsyntax "{apiVersion}/statusReembolso";
		Path "{apiVersion}/statusReembolso" PRODUCES APPLICATION_JSON

	// Jornada Atualização Cadastral
	WsMethod POST submit_formulario Description "Inserir um nova solicitação de atualização cadastral do beneficiário para análise";
		WSsyntax "{apiVersion}/submit_formulario";
		Path "{apiVersion}/submit_formulario" PRODUCES APPLICATION_JSON
		
	//Gera do protocolo de Reembolso
	WsMethod POST geraProtocolo Description "Gera do protocolo de Reembolso";
		WSsyntax "{apiVersion}/geraProtocolo";
		Path "{apiVersion}/geraProtocolo" PRODUCES APPLICATION_JSON   
	

End WsRestful


//-------------------------------------------------------------------
//    Jornada Acesso
//------------------------------------------------------------------- 
WsMethod POST login WsService mobileSaude
    PMobIniEnd("AUT","/mobileSaude/login", "login", self)
Return .T.


WsMethod POST reiniciarSenha WsService mobileSaude
	PMobIniEnd("AUT","/mobileSaude/reiniciarSenha", "reiniciarSenha", self)
Return .T.


WsMethod POST trocarSenha WsService mobileSaude
	PMobIniEnd("AUT","/mobileSaude/trocarSenha", "trocarSenha", self)	
Return .T.


WsMethod POST novoUsuario WsService mobileSaude
	PMobIniEnd("AUT","/mobileSaude/novoUsuario", "novoUsuario", self)
Return .T.


//-------------------------------------------------------------------
//    Jornada Utilizacao
//------------------------------------------------------------------- 
WsMethod POST exUtilizacao WsRestful mobileSaude
	PMobIniEnd("UTZ","/mobileSaude/extrato", "extrato", self)
Return .T.


//-------------------------------------------------------------------
//    Jornada Financeiro
//------------------------------------------------------------------- 
WsMethod POST listaDebitos WsRestful mobileSaude
	PMobIniEnd("FIN","/mobileSaude/listaDebitos", "listaDebitos", self)
Return .T.


WsMethod POST detalheDebito WsRestful mobileSaude
	PMobIniEnd("FIN","/mobileSaude/detalheDebito", "detalheDebito", self)
Return .T.


WsMethod POST boletoPdf WsRestful mobileSaude
	PMobIniEnd("FIN","/mobileSaude/boletoPdf", "boletoPdf", self)
Return .T.


WsMethod POST extratoFaturaPdf WsRestful mobileSaude
	PMobIniEnd("FIN","/mobileSaude/extratoFaturaPdf", "extratoFaturaPdf", self)
Return .T.

//-------------------------------------------------------------------
//    Token
//------------------------------------------------------------------- 
WsMethod POST token WsService mobileSaude
	PMobIniEnd("TOK","/mobileSaude/token", "GetToken" , self)
Return .T.

//-------------------------------------------------------------------
//    Jornada Extrato Autorizações (Guias)
//------------------------------------------------------------------- 
WsMethod POST guiaAutorizacoes WsRestful mobileSaude
	PMobIniEnd("GUI", "/mobileSaude/guiaAutorizacoes", "guiaAutorizacoes", self)
Return .T.

WsMethod POST guiaDetalhe WsRestful mobileSaude
	PMobIniEnd("GUI", "/mobileSaude/guiaDetalhe", "guiaDetalhe", self)
Return .T.

WsMethod POST guiaPdf WsRestful mobileSaude
	PMobIniEnd("GUI", "/mobileSaude/guiaPdf", "guiaPdf", self)
Return .T.

WsMethod POST guiaStatus WsRestful mobileSaude
	PMobIniEnd("GUI", "/mobileSaude/guiaStatus", "guiaStatus", self)
Return .T.

//-------------------------------------------------------------------
//    Jornada Declarações
//------------------------------------------------------------------- 
WsMethod POST declaracoes WsRestful mobileSaude
	PMobIniEnd("DEC", "/mobileSaude/declaracoes", "declaracoes", self)
Return .T.

WsMethod POST pdfDeclaracao WsRestful mobileSaude
	PMobIniEnd("DEC", "/mobileSaude/pdfDeclaracao", "pdfDeclaracao", self)
Return .T.

//-------------------------------------------------------------------
//    Jornada Extrato de Reembolso
//------------------------------------------------------------------- 
WsMethod POST reeExtrato WsRestful mobileSaude
	PMobIniEnd("EXREE", "/mobileSaude/reeExtrato", "reeExtrato", self)
Return .T.

WsMethod POST reeDetalhe WsRestful mobileSaude
	PMobIniEnd("EXREE", "/mobileSaude/reeDetalhe", "reeDetalhe", self)
Return .T.

WsMethod POST reeHistorico WsRestful mobileSaude
	PMobIniEnd("EXREE", "/mobileSaude/reeHistorico", "reeHistorico", self)
Return .T.

WsMethod POST reeStatus WsRestful mobileSaude
	PMobIniEnd("EXREE", "/mobileSaude/reeStatus", "reeStatus", self)
Return .T.

//-------------------------------------------------------------------
//    Jornada Atualização Cadastral
//------------------------------------------------------------------- 
WsMethod POST submit_formulario WsRestful mobileSaude
	PMobIniEnd("ATUCAD", "/mobileSaude/submit_formulario", "submit_formulario", self)
Return .T.


//-------------------------------------------------------------------
//    Gera do protocolo de Reembolso
//------------------------------------------------------------------- 
WsMethod POST geraProtocolo WsService mobileSaude
	PMobIniEnd("PROT","/mobileSaude/geraProtocolo", "PMobReembDao" , self)
Return .T.